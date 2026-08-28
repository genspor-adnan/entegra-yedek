using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Uts;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// ÜTS İŞ AKIŞLARI (UTSService) - bildirim gönder / iptal / sorgular /
/// askıdakiler senkronu. Ekranlar YALNIZ bunu çağırır; endpoint, JSON ve DB
/// burada ve alt katmanlardadır (Delphi'de hepsi formun içindeydi).
///
/// Delphi'deki UTS_BILDIRIM_TUR endpoint tablosunun karşılığı AŞAĞIDAKİ SABİT
/// KATALOG: 7 servis yolu koda gömülü. Alma bildiriminin İPTALİ YOKTUR
/// (doküman s96) - katalogda iptal yolu null.
///
/// Bildirim akışı: doğrula → durum=0 kaydet-COMMIT (HTTP öncesi iz) → POST →
/// SNC varsa durum=1, HATA varsa durum=2 + özet; ham cevap her durumda yazılır.
/// </summary>
public sealed class UtsServisi
{
    private readonly VeriKaynagi _veri;
    private readonly UtsDeposu _depo;
    private readonly IHttpClientFactory _http;

    public UtsServisi(VeriKaynagi veri, UtsDeposu depo, IHttpClientFactory http)
    {
        _veri = veri;
        _depo = depo;
        _http = http;
    }

    // ------------------------------------------------------ yol kataloğu ----
    public const short TurAlma = 1, TurVerme = 2, TurKullanim = 3,
                       TurUretim = 4, TurIthalat = 5, TurHek = 6, TurImha = 7;

    private static readonly Dictionary<short, (string Ad, string EkleYolu, string? IptalYolu)>
        Turler = new()
        {
            [TurAlma] = ("Alma", "/UTS/uh/rest/bildirim/alma/ekle", null),
            [TurVerme] = ("Verme", "/UTS/uh/rest/bildirim/verme/ekle",
                          "/UTS/uh/rest/bildirim/verme/iptal"),
            [TurKullanim] = ("Kullanım", "/UTS/uh/rest/bildirim/kullanim/ekle",
                             "/UTS/uh/rest/bildirim/kullanim/iptal"),
            [TurUretim] = ("Üretim", "/UTS/uh/rest/bildirim/uretim/ekle",
                           "/UTS/uh/rest/bildirim/uretim/iptal"),
            [TurIthalat] = ("İthalat", "/UTS/uh/rest/bildirim/ithalat/ekle",
                            "/UTS/uh/rest/bildirim/ithalat/iptal"),
            [TurHek] = ("Kayıp/HEK", "/UTS/uh/rest/bildirim/hekZayiat/ekle",
                        "/UTS/uh/rest/bildirim/hekZayiat/iptal"),
            [TurImha] = ("İmha/Bertaraf", "/UTS/uh/rest/bildirim/imhaBertaraf/ekle",
                         "/UTS/uh/rest/bildirim/imhaBertaraf/iptal"),
        };

    private const string YolTekilUrun = "/UTS/uh/rest/tekilUrun/sorgula";
    private const string YolAskidakilerOffset = "/UTS/uh/rest/bildirim/verme/askidakiler/offset";
    private const string YolAskidakilerSayfa = "/UTS/uh/rest/bildirim/verme/askidakiler";
    private const string YolBildirimDetay = "/UTS/uh/rest/bildirim/detay/sorgula";
    // Doküman (s170) "/uh"suz yazar ama CANLIDA o yol 404 - Delphi'nin
    //   kullandığı "/uh"lu adres çalışıyor (UUTSDlg:965 ile aynı).
    private const string YolAyrintili = "/UTS/uh/rest/ayrintiliTekilUrun/sorgula";

    private HttpClient Istemci() => _http.CreateClient("uts");

    private async Task<UtsHesabi> HesapAsync(int? subeId, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await UtsIstemcisi.HesapAsync(baglanti, subeId, iptal);
    }

    /// <summary>Hesap özeti - token asla tam dönmez (DOLU/BOŞ + son 4).</summary>
    public async Task<object> HesapDurumAsync(int? subeId, CancellationToken iptal)
    {
        var h = await HesapAsync(subeId, iptal);
        return new
        {
            kurumNo = h.KurumNo,
            testMi = h.TestMi,
            url = h.Taban,
            tokenVar = h.Token.Length > 0,
            tokenSonu = h.Token.Length >= 4 ? h.Token[^4..] : ""
        };
    }

    // ------------------------------------------------------- bildirimler ----

    /// <summary>Elle ya da envanterden ALMA bildirimi. Envanter satırı verildiyse
    /// VBI oradan gelir ve başarıda askı adeti düşer.</summary>
    public async Task<object> AlmaBildirAsync(int? envanterId, string? vbi, decimal adet,
        int? subeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        string bid; string kurumNo = ""; string urunNo = ""; string lotNo = ""; string seriNo = "";
        int? stokId = null;

        if (envanterId is > 0)
        {
            var e = await _depo.EnvanterOkuAsync(envanterId.Value, iptal);
            if (e.Durum != 1)
                throw GentegreHatasi.IsKurali("Bu kayıt askıda değil (alınmış ya da kaybolmuş).");
            if (adet <= 0 || adet > e.AskiAdet) adet = e.AskiAdet;
            (bid, kurumNo, urunNo, lotNo, seriNo, stokId) =
                (e.Bid, e.KurumNo, e.UrunNo, e.LotNo, e.SeriNo, e.StokId);
        }
        else
        {
            bid = (vbi ?? "").Trim();
            if (bid.Length is 0 or > 36)
                throw GentegreHatasi.Dogrulama("Verme bildirimi kimliği (VBI) zorunludur.",
                    new AlanHatasi("vbi", "Karşı tarafın verme bildirimi GUID'i."));
            if (adet <= 0) adet = 1;
        }

        var istek = new UtsAlmaIstek(Vbi: bid,
            Adt: string.IsNullOrEmpty(seriNo) && adet > 0 ? adet : null);

        var sonuc = await GonderAsync(TurAlma, istek, subeId, baglam,
            stokId, null, null, null, adet, null,
            kurumNo, "", urunNo, lotNo, seriNo, null, null, iptal);

        if (sonuc.Basarili && envanterId is > 0)
            await _depo.EnvanterAlindiAsync(envanterId.Value, adet, baglam, iptal);
        return sonuc.Yanit;
    }

    /// <summary>VERME bildirimi: karşı kurum KUN'u zorunlu (cari kartından ya da elle).</summary>
    public async Task<object> VermeBildirAsync(string? uno, string? lotNo, string? seriNo,
        decimal adet, string? kurumNo, string? belgeNo, DateTime? git,
        int? stokId, int? seriLotId, int? belgeId, int? belgeSatirId,
        int? subeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        var u = UtsDogrulama.Uno(uno);
        var l = UtsDogrulama.LotNo(lotNo);
        var s = UtsDogrulama.SeriNo(seriNo);
        var k = UtsDogrulama.KurumNo(kurumNo);
        var b = UtsDogrulama.BelgeNo(belgeNo);
        var adt = UtsDogrulama.AdetKurali(s, l, adet);

        var istek = new UtsVermeIstek(Uno: u, Kun: k, Bno: b, Lno: l, Sno: s, Adt: adt,
            Git: git is null ? null : UtsDogrulama.Tarih(git, "git", "Gerçek işlem tarihi"));

        var sonuc = await GonderAsync(TurVerme, istek, subeId, baglam,
            stokId, seriLotId, belgeId, belgeSatirId, adt ?? 1, git,
            k, b, u, l ?? "", s ?? "", null, null, iptal);
        return sonuc.Yanit;
    }

    /// <summary>KULLANIM bildirimi (hasta alanları ilk sürümde elle).</summary>
    public async Task<object> KullanimBildirAsync(string? uno, string? lotNo, string? seriNo,
        decimal adet, DateTime? git, string? hastaTckn, string? hastaAdi, string? hastaSoyadi,
        int? stokId, int? seriLotId, int? belgeId, int? belgeSatirId,
        int? subeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        var u = UtsDogrulama.Uno(uno);
        var l = UtsDogrulama.LotNo(lotNo);
        var s = UtsDogrulama.SeriNo(seriNo);
        var adt = UtsDogrulama.AdetKurali(s, l, adet);
        var tarih = UtsDogrulama.Tarih(git, "git", "Kullanım tarihi");

        var tckn = (hastaTckn ?? "").Trim();
        var istek = new UtsKullanimIstek(Uno: u, Git: tarih, Lno: l, Sno: s, Adt: adt,
            Tkn: tckn.Length > 0 ? tckn : null,
            HastaAdi: Bosalt(hastaAdi), HastaSoyadi: Bosalt(hastaSoyadi));

        var sonuc = await GonderAsync(TurKullanim, istek, subeId, baglam,
            stokId, seriLotId, belgeId, belgeSatirId, adt ?? 1, git,
            "", "", u, l ?? "", s ?? "", null, null, iptal);
        return sonuc.Yanit;

        static string? Bosalt(string? d) =>
            string.IsNullOrWhiteSpace(d) ? null : d.Trim();
    }

    /// <summary>ÜRETİM bildirimi (s24): ürün sistemde bu bildirimle doğar.</summary>
    public async Task<object> UretimBildirAsync(string? uno, string? lotNo, string? seriNo,
        decimal adet, DateTime? urt, DateTime? skt,
        int? subeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        var u = UtsDogrulama.Uno(uno);
        var l = UtsDogrulama.LotNo(lotNo);
        var sn = UtsDogrulama.SeriNo(seriNo);
        var adt = UtsDogrulama.AdetKurali(sn, l, adet);
        var istek = new UtsUretimIstek(Uno: u,
            Urt: UtsDogrulama.Tarih(urt, "urt", "Üretim tarihi"),
            Lno: l, Sno: sn, Adt: adt,
            Skt: skt is null ? null : UtsDogrulama.Tarih(skt, "skt", "Son kullanma"));
        var sonuc = await GonderAsync(TurUretim, istek, subeId, baglam,
            null, null, null, null, adt ?? 1, urt, "", "", u, l ?? "", sn ?? "",
            urt, skt, iptal);
        return sonuc.Yanit;
    }

    /// <summary>İTHALAT bildirimi (s27): ülke kodları ÜTS sayısal (TR 792).</summary>
    public async Task<object> IthalatBildirAsync(string? uno, string? lotNo, string? seriNo,
        decimal adet, DateTime? urt, DateTime? skt, int? ithalUlke, int? menseiUlke,
        string? gumrukBeyanname, int? subeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        var u = UtsDogrulama.Uno(uno);
        var l = UtsDogrulama.LotNo(lotNo);
        var sn = UtsDogrulama.SeriNo(seriNo);
        var adt = UtsDogrulama.AdetKurali(sn, l, adet);
        if (ithalUlke is null or <= 0 || menseiUlke is null or <= 0)
            throw GentegreHatasi.Dogrulama(
                "İthal edildiği ülke (IEU) ve menşei ülke (MEU) kodları zorunludur (Türkiye 792).",
                new AlanHatasi("ithalUlke", "ÜTS sayısal ülke kodu."));
        var gbn = (gumrukBeyanname ?? "").Trim();
        var istek = new UtsIthalatIstek(Uno: u,
            Urt: UtsDogrulama.Tarih(urt, "urt", "Üretim tarihi"),
            IthalUlke: ithalUlke, MenseiUlke: menseiUlke,
            Lno: l, Sno: sn, Adt: adt,
            Skt: skt is null ? null : UtsDogrulama.Tarih(skt, "skt", "Son kullanma"),
            GumrukBeyanname: gbn.Length > 0 ? gbn : null);
        var sonuc = await GonderAsync(TurIthalat, istek, subeId, baglam,
            null, null, null, null, adt ?? 1, urt, "", gbn, u, l ?? "", sn ?? "",
            urt, skt, iptal);
        return sonuc.Yanit;
    }

    /// <summary>KAYIP / HEK / Zayiat (s74): TUR zorunlu; DIGER'de açıklama şart.</summary>
    public async Task<object> HekBildirAsync(string? uno, string? lotNo, string? seriNo,
        decimal adet, string? tur, string? digerAciklama,
        int? subeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        var u = UtsDogrulama.Uno(uno);
        var l = UtsDogrulama.LotNo(lotNo);
        var sn = UtsDogrulama.SeriNo(seriNo);
        var adt = UtsDogrulama.AdetKurali(sn, l, adet);
        var t = (tur ?? "").Trim();
        if (t.Length == 0)
            throw GentegreHatasi.Dogrulama("Kayıp/HEK türü zorunludur.",
                new AlanHatasi("tur", "HEK, DOGAL_AFET, YANGIN, CALINMA, STOK_DUZELTME, DIGER."));
        var dta = (digerAciklama ?? "").Trim();
        if (t == "DIGER" && dta.Length == 0)
            throw GentegreHatasi.Dogrulama("Türü 'Diğer' ise açıklama zorunludur.",
                new AlanHatasi("digerAciklama", "Gerekçeyi yazın."));
        var istek = new UtsHekIstek(Uno: u, Tur: t, Lno: l, Sno: sn, Adt: adt,
            DigerAciklama: dta.Length > 0 ? dta : null);
        var sonuc = await GonderAsync(TurHek, istek, subeId, baglam,
            null, null, null, null, adt ?? 1, null, "", "", u, l ?? "", sn ?? "",
            null, null, iptal);
        return sonuc.Yanit;
    }

    /// <summary>İMHA / Bertaraf (s83): gerekçe listesi + zorunlu imha belge no.</summary>
    public async Task<object> ImhaBildirAsync(string? uno, string? lotNo, string? seriNo,
        decimal adet, string? gerekce, string? digerAciklama, string? belgeNo,
        int? subeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        var u = UtsDogrulama.Uno(uno);
        var l = UtsDogrulama.LotNo(lotNo);
        var sn = UtsDogrulama.SeriNo(seriNo);
        var adt = UtsDogrulama.AdetKurali(sn, l, adet);
        var g = (gerekce ?? "").Trim();
        if (g.Length == 0)
            throw GentegreHatasi.Dogrulama("İmha gerekçesi zorunludur.",
                new AlanHatasi("gerekce", "GRK listesinden bir değer seçin."));
        var b = UtsDogrulama.BelgeNo(belgeNo);
        var dga = (digerAciklama ?? "").Trim();
        if (g == "DIGER" && dga.Length == 0)
            throw GentegreHatasi.Dogrulama("Gerekçe 'Diğer' ise açıklama zorunludur.",
                new AlanHatasi("digerAciklama", "Gerekçeyi yazın."));
        var istek = new UtsImhaIstek(Uno: u, Gerekce: g, BelgeNo: b,
            Lno: l, Sno: sn, Adt: adt,
            DigerAciklama: dga.Length > 0 ? dga : null);
        var sonuc = await GonderAsync(TurImha, istek, subeId, baglam,
            null, null, null, null, adt ?? 1, null, "", b, u, l ?? "", sn ?? "",
            null, null, iptal);
        return sonuc.Yanit;
    }

    /// <summary>Ortak gönderim: kaydet(durum 0) → POST → sonucu yaz.</summary>
    private async Task<(bool Basarili, string Mesaj, object Yanit)> GonderAsync<T>(
        short tur, T istek, int? subeId, YazmaBaglami baglam,
        int? stokId, int? seriLotId, int? belgeId, int? belgeSatirId,
        decimal adet, DateTime? git,
        string kurumNo, string belgeNo, string urunNo, string lotNo, string seriNo,
        DateTime? urt, DateTime? skt, CancellationToken iptal)
    {
        var hesap = await HesapAsync(subeId, iptal);
        var govde = JsonSerializer.Serialize(istek, UtsJson.Ayarlar);

        var bildirimId = await _depo.BildirimEkleAsync(
            tur, baglam, hesap.TestMi, stokId, seriLotId, belgeId, belgeSatirId,
            adet, git, kurumNo, belgeNo, urunNo, lotNo, seriNo, urt, skt, govde, iptal);

        var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
            Istemci(), hesap, Turler[tur].EkleYolu, govde,
            $"ÜTS {Turler[tur].Ad} bildirimi", iptal);

        var mesajlar = UtsIstemcisi.MesajlariAyikla(cevap);
        var snc = UtsIstemcisi.SncAyikla(cevap);
        var basarili = httpKodu == 200 && !string.IsNullOrEmpty(snc)
                       && mesajlar.All(m => m.Tip != "HATA");
        var (kod, mesaj) = UtsIstemcisi.HataOzeti(mesajlar);

        await _depo.SonucYazAsync(bildirimId, (short)(basarili ? 1 : 2),
            snc ?? "", cevap, httpKodu, kod, mesaj, baglam, iptal);

        var ozet = basarili
            ? $"ÜTS {Turler[tur].Ad} bildirimi başarılı."
            : (mesaj.Length > 0 ? mesaj : "ÜTS bildirimi reddetti.");
        return (basarili, ozet, new
        {
            bildirimId,
            basarili,
            utsBildirimId = snc ?? "",
            mesajlar,
            mesaj = ozet
        });
    }

    /// <summary>Bildirim iptali - alma bildirimi ÜTS'de iptal EDİLEMEZ.</summary>
    public async Task<object> IptalAsync(int bildirimId, YazmaBaglami baglam,
        CancellationToken iptal)
    {
        var b = await _depo.BildirimOkuAsync(bildirimId, iptal);
        if (b.Durum != 1)
            throw GentegreHatasi.IsKurali("Yalnız BAŞARILI bildirim iptal edilebilir.");
        var iptalYolu = Turler.TryGetValue(b.Tur, out var t) ? t.IptalYolu : null;
        if (iptalYolu is null)
            throw GentegreHatasi.IsKurali(
                "Alma bildirimi ÜTS'de iptal edilemez (karşı taraf verme bildirimini iptal etmelidir).");
        if (string.IsNullOrEmpty(b.UtsBildirimId))
            throw GentegreHatasi.IsKurali("Bildirimin ÜTS kimliği (BID) yok.");

        var hesap = await HesapAsync(b.SubeId, iptal);
        var govde = JsonSerializer.Serialize(new UtsIptalIstek(b.UtsBildirimId), UtsJson.Ayarlar);
        var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
            Istemci(), hesap, iptalYolu, govde, $"ÜTS {t.Ad} iptali", iptal);

        var mesajlar = UtsIstemcisi.MesajlariAyikla(cevap);
        var basarili = httpKodu == 200 && mesajlar.All(m => m.Tip != "HATA");
        var (kod, mesaj) = UtsIstemcisi.HataOzeti(mesajlar);
        if (basarili)
            await _depo.SonucYazAsync(bildirimId, 3, b.UtsBildirimId, cevap, httpKodu,
                kod, "İptal edildi.", baglam, iptal);

        return new
        {
            bildirimId, basarili, mesajlar,
            mesaj = basarili ? "Bildirim ÜTS'de iptal edildi."
                             : (mesaj.Length > 0 ? mesaj : "ÜTS iptali reddetti.")
        };
    }

    /// <summary>Hatalı (durum 2) bildirimi AYNI gövdeyle tekrar gönderir.</summary>
    public async Task<object> YenidenGonderAsync(int bildirimId, YazmaBaglami baglam,
        CancellationToken iptal)
    {
        var b = await _depo.BildirimOkuAsync(bildirimId, iptal);
        if (b.Durum != 2)
            throw GentegreHatasi.IsKurali("Yalnız HATALI bildirim yeniden gönderilebilir.");
        if (b.IstekJson.Length == 0)
            throw GentegreHatasi.IsKurali("Bildirimin kayıtlı isteği yok.");

        var hesap = await HesapAsync(b.SubeId, iptal);
        var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
            Istemci(), hesap, Turler[b.Tur].EkleYolu, b.IstekJson,
            $"ÜTS {Turler[b.Tur].Ad} bildirimi (yeniden)", iptal);

        var mesajlar = UtsIstemcisi.MesajlariAyikla(cevap);
        var snc = UtsIstemcisi.SncAyikla(cevap);
        var basarili = httpKodu == 200 && !string.IsNullOrEmpty(snc)
                       && mesajlar.All(m => m.Tip != "HATA");
        var (kod, mesaj) = UtsIstemcisi.HataOzeti(mesajlar);

        await _depo.SonucYazAsync(bildirimId, (short)(basarili ? 1 : 2),
            snc ?? b.UtsBildirimId, cevap, httpKodu, kod, mesaj, baglam, iptal);

        return new
        {
            bildirimId, basarili, mesajlar,
            mesaj = basarili ? "Bildirim başarıyla gönderildi."
                             : (mesaj.Length > 0 ? mesaj : "ÜTS bildirimi yine reddetti.")
        };
    }

    // ---------------------------------------------------------- sorgular ----

    /// <summary>Tekil ürün sorgusu - DB'ye bildirim satırı AÇMAZ, ham cevabı döndürür.
    /// Boş dönerse UNO'nun GTIN 13/14 varyantıyla ikinci deneme yapılır
    /// (Delphi davranışı - baştaki '0' farkı sık yaşanıyor).</summary>
    public async Task<object> TekilUrunSorgulaAsync(string? uno, string? lotNo, string? seriNo,
        int? subeId, CancellationToken iptal)
    {
        var u = UtsDogrulama.Uno(uno);
        var hesap = await HesapAsync(subeId, iptal);
        var l = UtsDogrulama.LotNo(lotNo);
        var sn = UtsDogrulama.SeriNo(seriNo);

        foreach (var varyant in UtsDogrulama.UnoVaryantlari(u))
        {
            var govde = JsonSerializer.Serialize(
                new UtsTekilUrunSorgu(varyant, l, sn), UtsJson.Ayarlar);
            var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
                Istemci(), hesap, YolTekilUrun, govde, "ÜTS tekil ürün sorgusu", iptal);
            var yanit = SorguYaniti(httpKodu, cevap);
            if (SonucDoluMu(yanit)) return yanit;
        }
        // Iki varyant da bos: son (bos) cevabi standart zarfla dondur.
        return new { basarili = true, sonuc = Array.Empty<object>(),
                     mesajlar = Array.Empty<UtsMesaj>() };
    }

    private static bool SonucDoluMu(object yanit)
    {
        var p = yanit.GetType().GetProperty("sonuc")?.GetValue(yanit);
        return p switch
        {
            null => false,
            System.Collections.ICollection k => k.Count > 0,
            _ => true
        };
    }

    /// <summary>Kendi bildirimimizin ÜTS'deki detayını sorgular.</summary>
    public async Task<object> BildirimDetayAsync(int bildirimId, CancellationToken iptal)
    {
        var b = await _depo.BildirimOkuAsync(bildirimId, iptal);
        if (string.IsNullOrEmpty(b.UtsBildirimId))
            throw GentegreHatasi.IsKurali("Bildirimin ÜTS kimliği (BID) yok - önce başarıyla gönderilmeli.");
        var hesap = await HesapAsync(b.SubeId, iptal);
        var govde = JsonSerializer.Serialize(
            new UtsBildirimDetaySorgu(b.UtsBildirimId), UtsJson.Ayarlar);
        var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
            Istemci(), hesap, YolBildirimDetay, govde, "ÜTS bildirim detayı", iptal);
        return SorguYaniti(httpKodu, cevap);
    }

    /// <summary>Ayrıntılı tekil ürün - ürünün TEKİLLERİNİ listeler (Delphi'nin
    /// yalnız-UNO akışı). Boş dönerse GTIN varyantıyla tekrar denenir.</summary>
    public async Task<object> AyrintiliSorgulaAsync(string? uno, string? lotNo, string? seriNo,
        int? subeId, CancellationToken iptal)
    {
        var hesap = await HesapAsync(subeId, iptal);
        var u = string.IsNullOrWhiteSpace(uno) ? null : uno!.Trim();
        var varyantlar = u is null ? new string?[] { null }
                                   : UtsDogrulama.UnoVaryantlari(u).Cast<string?>().ToArray();

        object? son = null;
        foreach (var varyant in varyantlar)
        {
            // SAY sayfalamasi: TUM sayfalar toplanir (100'erlik; Delphi de
            //   boyle geziyordu) - tek sayfada kalinca "411'in 100'u" gorunuyordu.
            var tumu = new List<object>();
            var mesajlar = new List<UtsMesaj>();
            var basarili = true;
            for (var sayfa = 0; sayfa < 100; sayfa++)   // emniyet: 10.000 kayit
            {
                var istek = new
                {
                    UNO = varyant,
                    LNO = string.IsNullOrWhiteSpace(lotNo) ? null : lotNo!.Trim(),
                    SNO = string.IsNullOrWhiteSpace(seriNo) ? null : seriNo!.Trim(),
                    ADT = (int?)100, SAY = (int?)sayfa
                };
                var govde = JsonSerializer.Serialize(istek, UtsJson.Ayarlar);
                var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
                    Istemci(), hesap, YolAyrintili, govde, "ÜTS ayrıntılı ürün sorgusu", iptal);
                mesajlar.AddRange(UtsIstemcisi.MesajlariAyikla(cevap));
                if (httpKodu != 200) { basarili = tumu.Count > 0; break; }
                var parca = SayfaKayitlari(cevap);
                if (parca.Count == 0) break;
                tumu.AddRange(parca);
                if (parca.Count < 100) break;           // son sayfa
            }
            son = new { basarili, sonuc = tumu, mesajlar };
            if (tumu.Count > 0) return son;
        }
        return son!;

        static List<object> SayfaKayitlari(string cevap)
        {
            var liste = new List<object>();
            try
            {
                using var belge = JsonDocument.Parse(cevap);
                if (belge.RootElement.ValueKind == JsonValueKind.Object
                    && belge.RootElement.TryGetProperty("SNC", out var snc)
                    && snc.ValueKind == JsonValueKind.Array)
                    foreach (var e in snc.EnumerateArray())
                        liste.Add(JsonSerializer.Deserialize<object>(e.GetRawText())!);
            }
            catch (JsonException) { }
            return liste;
        }
    }

    private static object SorguYaniti(int httpKodu, string cevap)
    {
        var mesajlar = UtsIstemcisi.MesajlariAyikla(cevap);
        object? snc = null;
        try
        {
            using var belge = JsonDocument.Parse(cevap);
            if (belge.RootElement.ValueKind == JsonValueKind.Object
                && belge.RootElement.TryGetProperty("SNC", out var s))
                snc = JsonSerializer.Deserialize<object>(s.GetRawText());
        }
        catch (JsonException) { }
        return new { basarili = httpKodu == 200 && mesajlar.All(m => m.Tip != "HATA"),
                     sonuc = snc, mesajlar };
    }

    // -------------------------------------------------- belge köprüsü (226) ----

    public sealed record BelgeBildirimSonucu(string Stok, string SeriNo, string LotNo,
        decimal Adet, string Islem, bool Basarili, string Mesaj);

    /// <summary>
    /// Belgeden toplu ÜTS bildirimi: SATIŞ belgesinde (14/15/16) her seri/lot
    /// için VERME, ALIŞ belgesinde (10/11/12) askıdaki envanterle eşleştirip
    /// ALMA. Sonuç satır satır raporlanır - bir satırın hatası diğerlerini
    /// durdurmaz. Daha önce bildirilmiş (bekleyen/başarılı) seri/lot atlanır.
    /// </summary>
    public async Task<object> BelgedenBildirAsync(int belgeId, YazmaBaglami baglam,
        CancellationToken iptal)
    {
        var b = await _depo.BelgeOzetAsync(belgeId, iptal);
        var satisMi = b.Tur is 14 or 15 or 16;
        var alisMi = b.Tur is 10 or 11 or 12;
        if (!satisMi && !alisMi)
            throw GentegreHatasi.IsKurali(
                "ÜTS bildirimi yalnız alış/satış irsaliye, fatura ve fişlerinden yapılır.");

        var tur = satisMi ? TurVerme : TurAlma;
        var izlemler = await _depo.BelgeIzlemleriAsync(belgeId, tur, iptal);
        if (izlemler.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Belgede seri/lot izlemi yok - ÜTS bildirimi seri/lot takipli kalemlerden yapılır.");
        if (satisMi && b.TarafUtsNo.Length == 0)
            throw GentegreHatasi.IsKurali(
                $"\"{b.TarafUnvan}\" carisinin ÜTS Kurum No'su boş. "
                + "Cari kartı › Fatura Bilgileri › ÜTS Kurum No alanına girin.");

        var sonuclar = new List<BelgeBildirimSonucu>();
        foreach (var i in izlemler)
        {
            var islemAdi = satisMi ? "Verme" : "Alma";
            try
            {
                if (i.Bildirildi)
                {
                    sonuclar.Add(new(i.StokAdi, i.SeriNo, i.LotNo, i.Adet, islemAdi,
                        true, "Daha önce bildirilmiş - atlandı."));
                    continue;
                }
                if (satisMi)
                    sonuclar.Add(await SatirVermeAsync(i));
                else
                    sonuclar.Add(await SatirAlmaAsync(i));
            }
            catch (GentegreHatasi h)
            {
                sonuclar.Add(new(i.StokAdi, i.SeriNo, i.LotNo, i.Adet, islemAdi,
                    false, h.Message));
            }
        }

        var basarili = sonuclar.Count(x => x.Basarili);
        return new
        {
            belgeNo = b.BelgeNo,
            toplam = sonuclar.Count,
            basarili,
            hatali = sonuclar.Count - basarili,
            sonuclar,
            mesaj = $"{b.BelgeNo}: {basarili}/{sonuclar.Count} satır bildirildi."
        };

        async Task<BelgeBildirimSonucu> SatirVermeAsync(UtsDeposu.BelgeIzlemSatiri i)
        {
            if (i.UrunNo.Length == 0)
                return new(i.StokAdi, i.SeriNo, i.LotNo, i.Adet, "Verme", false,
                    "Stok kartında ÜTS ürün no (GTIN) boş.");
            var adt = UtsDogrulama.AdetKurali(i.SeriNo, i.LotNo, i.Adet);
            var istek = new UtsVermeIstek(
                Uno: i.UrunNo, Kun: b.TarafUtsNo, Bno: b.BelgeNo,
                Lno: i.LotNo.Length > 0 ? i.LotNo : null,
                Sno: i.SeriNo.Length > 0 ? i.SeriNo : null,
                Adt: adt,
                Git: b.BelgeTarihi.ToString("yyyy-MM-dd",
                    System.Globalization.CultureInfo.InvariantCulture));
            var sonuc = await GonderAsync(TurVerme, istek, b.SubeId, baglam,
                i.StokId, i.SeriLotId, belgeId, i.BelgeSatirId, adt ?? 1, b.BelgeTarihi,
                b.TarafUtsNo, b.BelgeNo, i.UrunNo, i.LotNo, i.SeriNo, null, null, iptal);
            return new(i.StokAdi, i.SeriNo, i.LotNo, i.Adet, "Verme",
                sonuc.Basarili, sonuc.Mesaj);
        }

        async Task<BelgeBildirimSonucu> SatirAlmaAsync(UtsDeposu.BelgeIzlemSatiri i)
        {
            var varyantlar = i.UrunNo.Length > 0
                ? UtsDogrulama.UnoVaryantlari(i.UrunNo) : Array.Empty<string>();
            var es = varyantlar.Length > 0
                ? await _depo.EnvanterEsleAsync(b.SubeId, varyantlar, i.SeriNo, i.LotNo, iptal)
                : null;
            if (es is null)
                return new(i.StokAdi, i.SeriNo, i.LotNo, i.Adet, "Alma", false,
                    "Askıdakilerde eşleşme yok - önce \"Askıdakileri Getir\" çalıştırın "
                    + "ya da karşı firma verme bildirimini yapmamış.");
            var adet = Math.Min(i.Adet, es.Value.AskiAdet);
            var istek = new UtsAlmaIstek(Vbi: es.Value.Bid,
                Adt: i.SeriNo.Length == 0 && adet > 0 ? adet : null);
            var sonuc = await GonderAsync(TurAlma, istek, b.SubeId, baglam,
                i.StokId, i.SeriLotId, belgeId, i.BelgeSatirId, adet, b.BelgeTarihi,
                "", b.BelgeNo, i.UrunNo, i.LotNo, i.SeriNo, null, null, iptal);
            if (sonuc.Basarili)
                await _depo.EnvanterAlindiAsync(es.Value.Id, adet, baglam, iptal);
            return new(i.StokAdi, i.SeriNo, i.LotNo, i.Adet, "Alma",
                sonuc.Basarili, sonuc.Mesaj);
        }
    }

    // ------------------------------------------------ askıdakiler senkron ----

    /// <summary>
    /// Askıdaki tekil ürünleri çekip uts_envanter'e upsert eder. Önce /offset
    /// (OFF imleci) denenir; ÜTS kabul etmezse 10'luk SAN sayfalamasına düşer
    /// (Delphi'deki heuristiğin düzenli hali). Senkronda görülmeyen askıdaki
    /// kayıtlar durum 0 (kayboldu) olur.
    /// </summary>
    public async Task<object> AskidakilerSenkronAsync(int? subeIdIstek, int subeIdVarsayilan,
        CancellationToken iptal)
    {
        var subeId = subeIdIstek ?? subeIdVarsayilan;
        var hesap = await HesapAsync(subeId, iptal);
        var gorulen = new List<string>();
        var toplam = 0;
        // ÜTS'nin dondurdugu HATA/UYARI'lar YUTULMAZ (ilk surumde 400
        //   sessizce "0 kayit" gorunuyordu) - kullaniciya aynen tasinir.
        var utsMesajlari = new List<UtsMesaj>();

        var offsetCalisti = await OffsetIleAsync();
        if (!offsetCalisti)
            await SayfaIleAsync();

        var kaybolan = await _depo.EnvanterEksikleriIsaretleAsync(subeId, gorulen, iptal);
        var hatalar = utsMesajlari.Where(m => m.Tip is "HATA" or "UYARI")
            .Select(m => m.Met).Where(m => !string.IsNullOrEmpty(m)).Distinct().ToList();
        return new { toplam, kaybolan, mesajlar = utsMesajlari,
                     mesaj = $"{toplam} askıdaki kayıt senkronlandı"
                           + (kaybolan > 0 ? $", {kaybolan} kayıt askıdan düştü." : ".")
                           + (hatalar.Count > 0 ? " ÜTS: " + string.Join(" | ", hatalar) : "")
                           + (hesap.TestMi ? " (TEST ortamı)" : " (CANLI)") };

        async Task<bool> OffsetIleAsync()
        {
            string? off = null;
            var tur = 0;
            while (true)
            {
                if (++tur > 200) break;    // emniyet: 200 x 100 = 20.000 kayıt
                var govde = JsonSerializer.Serialize(
                    new UtsAskidakilerSorgu(Adt: 100, Off: off), UtsJson.Ayarlar);
                var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
                    Istemci(), hesap, YolAskidakilerOffset, govde,
                    "ÜTS askıdakiler sorgusu", iptal);
                utsMesajlari.AddRange(UtsIstemcisi.MesajlariAyikla(cevap));
                if (httpKodu != 200) return tur > 1;   // ilk istekte 400 → uç yok say
                var (satirlar, yeniOff) = ListeAyikla(cevap);
                foreach (var s in satirlar) await IsleAsync(s);
                if (satirlar.Count == 0 || string.IsNullOrEmpty(yeniOff) || yeniOff == off)
                    return true;
                off = yeniOff;
            }
            return true;
        }

        async Task SayfaIleAsync()
        {
            for (var sayfa = 0; sayfa < 500; sayfa++)
            {
                var govde = JsonSerializer.Serialize(
                    new UtsAskidakilerSayfaSorgu(San: sayfa), UtsJson.Ayarlar);
                var (httpKodu, cevap) = await UtsIstemcisi.PostAsync(
                    Istemci(), hesap, YolAskidakilerSayfa, govde,
                    "ÜTS askıdakiler sorgusu", iptal);
                utsMesajlari.AddRange(UtsIstemcisi.MesajlariAyikla(cevap));
                if (httpKodu != 200) break;
                var (satirlar, _) = ListeAyikla(cevap);
                if (satirlar.Count == 0) break;
                foreach (var s in satirlar) await IsleAsync(s);
            }
        }

        async Task IsleAsync(UtsAskidakiSatir s)
        {
            if (string.IsNullOrEmpty(s.Bid)) return;
            gorulen.Add(s.Bid);
            var uno = (s.Uno ?? "").Trim();
            int? stokId = uno.Length > 0
                ? await _depo.StokEsleAsync(UtsDogrulama.UnoVaryantlari(uno), iptal)
                : null;
            // BZA metin tarih ("2026-08-24 10:14:44"); cozulemezse bos gecilir.
            DateTime? bza = DateTime.TryParse(s.Bza, System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out var t) ? t : null;
            await _depo.EnvanterUpsertAsync(subeId, s.Bid,
                s.Kun?.ToString() ?? "", s.Aku ?? "", uno, s.Lno ?? "", s.Sno ?? "",
                s.Bno ?? "", s.Bti ?? "", bza,
                s.Mme ?? "", s.Adt ?? 1, stokId, iptal);
            toplam++;
        }

        static (List<UtsAskidakiSatir> Satirlar, string? Off) ListeAyikla(string cevap)
        {
            var satirlar = new List<UtsAskidakiSatir>();
            string? off = null;
            try
            {
                using var belge = JsonDocument.Parse(cevap);
                var kok = belge.RootElement;
                // SNC { LST: [...], OFF: "..." } ya da doğrudan SNC: [...]
                if (kok.ValueKind == JsonValueKind.Object
                    && kok.TryGetProperty("SNC", out var snc))
                {
                    var liste = snc;
                    if (snc.ValueKind == JsonValueKind.Object)
                    {
                        if (snc.TryGetProperty("OFF", out var o)
                            && o.ValueKind == JsonValueKind.String)
                            off = o.GetString();
                        if (snc.TryGetProperty("LST", out var l)) liste = l;
                    }
                    if (liste.ValueKind == JsonValueKind.Array)
                        foreach (var e in liste.EnumerateArray())
                            try
                            {
                                var s = JsonSerializer.Deserialize<UtsAskidakiSatir>(
                                    e.GetRawText(), UtsJson.Ayarlar);
                                if (s is not null) satirlar.Add(s);
                            }
                            catch (JsonException)
                            {
                                // Tek satirin beklenmedik alani TUM listeyi
                                //   dusurmesin (BZA metin tarihi vakasi).
                            }
                }
            }
            catch (JsonException) { }
            return (satirlar, off);
        }
    }
}

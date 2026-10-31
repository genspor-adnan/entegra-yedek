using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// BANKA HAREKETLERİ (1157, mockup Ekranlar/ERP/banka_hareketleri.html) — ÇEK → ÖNER → İŞLE.
///
/// <para><b>Çek:</b> banka hesabının "Banka Bağlantısı" ayarı (kaynak API, Entegrasyonlar'daki satır, onay no,
/// şube / hesap no, IBAN) ile Garanti BBVA <c>gettransactions</c> çağrılır; her hareket <c>banka_hareket</c>
/// satırı olur - (hesap, banka işlem no) tekil, tekrar çekmek kopya üretmez. Son hareketin işlem sonrası
/// bakiyesi hesabın "banka bakiyesi" olur. Yeni hareketlere öneri (fn_banka_oneri) üretilir; hesapta
/// otomatik işleme açıksa %95+ öneriler kendiliğinden işlenir.</para>
/// <para><b>Benzetim:</b> entegrasyon TEST ortamında ve anahtarı boşsa bankaya gidilmez, örnek hareket
/// üretilir (kaynak 3) - MERNİS / Medula deseni. Ekranda "benzetim" yazar; gerçek banka verisi değildir.
/// <b>Örnek sunucu:</b> test adresi API'nin kendi Garanti taklidi (GarantiOrnekUclari, yalnız geliştirme /
/// demo) ise gerçek istemci yolu (jeton, sayfalama, yanıt çözümü) uçtan uca çalışır; yine kaynak 3.</para>
/// <para><b>İşle:</b> kararla (öneri ya da kullanıcı seçimi) kasa işlemi yazılır - kasa akışının KENDİSİ
/// (KasaDeposu.KaydetAsync, kesin): tahsilat 22, ödeme 32, virman 43, POS aktarımı 44, masraf 32 + kalem.
/// Virmanın karşı bacağı (kendi öteki hesabındaki ters hareket) aynı kasa işlemine bağlanır - iki kez
/// yazılmaz.</para>
/// </summary>
public sealed class BankaHareketServisi(VeriKaynagi veri, KasaDeposu kasa, IHttpClientFactory http,
                                        ILogger<BankaHareketServisi> gunluk)
{
    public sealed record CekimSonucu(int Hesap, int Yeni, int Toplam, int Islenen, bool Benzetim, string Mesaj);
    public sealed record Karar(string Tur, int? TarafId, int? BelgeId, int? HedefHesapId, int? MasrafId,
                               bool IbanEkle = false, string? Kural = null);

    private sealed record Kaynakli(Baglanti Bag, short Kaynak);
    private sealed record Baglanti(int HesapId, string HesapAd, int SubeId, string Doviz, string Iban, string SubeKodu,
        string HesapNo, string OnayNo, DateTime? IlkTarih, bool OtomatikIsle, int EntegrasyonId, string Kod,
        bool Test, string Url, string TestUrl, string ClientId, string Secret, string Scope);

    // ================================================================= çek ====
    public async Task<CekimSonucu> CekAsync(int hesapId, DateTime? bas, DateTime? bit, int kullanici, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var g = await b.TekAsync("""
            select x.id, x.ad, coalesce(x.sube_id, 0), coalesce(nullif(x.doviz_cinsi, ''), 'TL'), coalesce(x.iban, ''),
                   coalesce(x.banka_sube_kodu, ''), coalesce(x.hesap_no, ''), coalesce(x.banka_onay_no, ''), x.banka_ilk_tarih,
                   x.banka_otomatik_isle = 1, coalesce(e.id, 0), coalesce(e.kod, ''), coalesce(e.test_mi, 0) = 1,
                   coalesce(e.url, ''), coalesce(e.test_url, ''), coalesce(e.kullanici_adi, ''), coalesce(e.sifre, ''),
                   x.banka_kaynak, coalesce(e.ayarlar->>'scope', '')
              from public.hesap x left join public.entegrasyon_hesap e on e.id = x.banka_entegrasyon_id
             where x.id = @p0
            """, null, [hesapId], o => new Kaynakli(new Baglanti(o.GetInt32(0), o.GetString(1), o.GetInt32(2), o.GetString(3),
                o.GetString(4), o.GetString(5), o.GetString(6), o.GetString(7), o.IsDBNull(8) ? null : o.GetDateTime(8),
                o.GetBoolean(9), o.GetInt32(10), o.GetString(11), o.GetBoolean(12), o.GetString(13), o.GetString(14),
                o.GetString(15), GizliMetin.Coz(o.GetString(16)), o.GetString(18)), o.GetInt16(17)), iptal)
            ?? throw GentegreHatasi.Bulunamadi("Banka hesabı bulunamadı.");
        var bag = g.Bag;
        if (g.Kaynak != 1) throw GentegreHatasi.IsKurali($"{bag.HesapAd}: hareket kaynağı 'Banka API' değil (kartın Banka Bağlantısı sekmesi).");
        if (bag.EntegrasyonId == 0) throw GentegreHatasi.IsKurali($"{bag.HesapAd}: entegrasyon seçilmemiş.");
        if (bag.Kod != "GARANTI") throw GentegreHatasi.IsKurali($"{bag.Kod}: bu banka için API istemcisi henüz yok.");

        var bitis = (bit ?? Saat.Simdi).Date.AddDays(1).AddMilliseconds(-1);
        var baslangic = (bas ?? await b.TekDegerAsync<DateTime?>(
            "select max(islem_tarihi) from public.banka_hareket where hesap_id = @p0", null, [hesapId], iptal)
            ?? bag.IlkTarih ?? Saat.Simdi.Date.AddDays(-7)).Date;
        if ((bitis - baslangic).TotalDays > 92) baslangic = bitis.Date.AddDays(-92);   // banka sınırı: 3 ay

        // Gerçek banka verisi olmayan iki yol: anahtarsız test hesabı (yerinde benzetim) ve yerel örnek sunucu
        //   (GarantiOrnekUclari - gerçek istemci yolu, bankanın yanıt biçimi). İkisi de kaynak 3.
        var benzetim = bag.Test && (bag.ClientId == "" || bag.Secret == "");
        var ornek = !benzetim && bag.Kod == "GARANTI" && OrnekSunucu((bag.Test && bag.TestUrl != "" ? bag.TestUrl : bag.Url).TrimEnd('/'));
        var sahte = benzetim || ornek;
        List<BankaHareketSatiri> hareketler;
        try
        {
            hareketler = benzetim ? Benzetim(bag, baslangic, bitis, await BenzetimOrnekAsync(b, bag.HesapId, iptal))
                                  : await GarantiAsync(bag, baslangic, bitis, iptal);
        }
        catch (Exception h) when (h is not GentegreHatasi)
        {
            gunluk.LogWarning(h, "Banka çekimi hata verdi (hesap {Hesap}).", hesapId);
            await b.CalistirAsync("update public.hesap set banka_son_sonuc = @p1 where id = @p0", null,
                                  [hesapId, Kisa("Hata: " + h.Message, 300)], iptal);
            throw GentegreHatasi.IsKurali($"Bankadan çekilemedi: {h.Message}");
        }

        var yeni = 0; var yeniIdler = new List<long>();
        await using (var tx = await b.BeginTransactionAsync(iptal))
        {
            foreach (var x in hareketler)
            {
                var id = await b.TekDegerAsync<long?>("""
                    insert into public.banka_hareket (hesap_id, sube_id, kaynak, banka_islem_no, islem_tarihi, valor_tarihi,
                           tutar, doviz_cinsi, bakiye, aciklama, karsi_ad, karsi_iban, karsi_vkn, fatura_metni, sinif, ham)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p15::jsonb)
                    on conflict (hesap_id, banka_islem_no) do nothing
                    returning id
                    """, tx, [hesapId, bag.SubeId, (short)(sahte ? 3 : 1), x.IslemNo, x.Tarih, x.Valor, x.Tutar,
                              x.Doviz == "" ? bag.Doviz : x.Doviz, x.Bakiye, Kisa(x.Aciklama, 500), Kisa(x.KarsiAd, 200),
                              Kisa(x.KarsiIban, 34), Kisa(x.KarsiVkn, 11), Kisa(x.Fatura, 200), Kisa(x.Sinif, 60), x.Ham], iptal);
                if (id is { } y) { yeni++; yeniIdler.Add(y); }
            }
            foreach (var id in yeniIdler)
                await b.CalistirAsync("select public.fn_banka_oneri(@p0)", tx, [id], iptal);
            var son = hareketler.Where(x => x.Bakiye is not null).OrderBy(x => x.Tarih).LastOrDefault();
            await b.CalistirAsync("""
                update public.hesap set banka_son_cekim = now(), banka_son_sonuc = @p1,
                       banka_bakiye = coalesce(@p2, banka_bakiye), banka_bakiye_zaman = case when @p2 is null then banka_bakiye_zaman else now() end
                 where id = @p0
                """, tx, [hesapId, Kisa($"{(benzetim ? "Benzetim · " : ornek ? "Örnek sunucu · " : "")}{hareketler.Count} hareket, {yeni} yeni", 300), son?.Bakiye], iptal);
            await tx.CommitAsync(iptal);
        }

        // Otomatik işleme: yalnız %95+ öneriler.
        var islenen = 0;
        if (bag.OtomatikIsle)
            foreach (var id in yeniIdler)
            {
                var guven = await b.TekDegerAsync<int?>(
                    "select (oneri ->> 'guven')::int from public.banka_hareket where id = @p0 and durum = 1", null, [id], iptal);
                if (guven is >= 95)
                    try { await OneriyiIsleAsync(id, kullanici, bag.SubeId, iptal); islenen++; }
                    catch (Exception h) { gunluk.LogWarning(h, "Otomatik işleme atlandı (hareket {Id}).", id); }
            }
        return new CekimSonucu(hesapId, yeni, hareketler.Count, islenen, sahte,
            $"{bag.HesapAd}: {hareketler.Count} hareket, {yeni} yeni" + (islenen > 0 ? $", {islenen} otomatik işlendi" : "")
            + (benzetim ? " (BENZETİM - gerçek banka verisi değil)" : ornek ? " (ÖRNEK SUNUCU - gerçek banka verisi değil)" : ""));
    }

    /// <summary>Çekilecek adres: test ortamında test adresi. Yerel örnek sunucu (GarantiOrnekUclari) dışında HTTPS şart.</summary>
    private static string Kok(Baglanti bag)
    {
        var kok = (bag.Test && bag.TestUrl != "" ? bag.TestUrl : bag.Url).TrimEnd('/');
        if (!kok.StartsWith("https://", StringComparison.OrdinalIgnoreCase) && !(bag.Test && OrnekSunucu(kok)))
            throw GentegreHatasi.IsKurali("Garanti adresi HTTPS olmalı (yalnız yerel örnek sunucu http olabilir).");
        return kok;
    }

    /// <summary>Adres API'nin kendi örnek sunucusu mu (http://localhost…/api/banka-ornek/garanti) - gerçek banka verisi değil.</summary>
    private static bool OrnekSunucu(string kok)
        => Uri.TryCreate(kok, UriKind.Absolute, out var u) && u.IsLoopback
           && u.AbsolutePath.TrimEnd('/').EndsWith(Uclar.GarantiOrnekUclari.YolKoku, StringComparison.OrdinalIgnoreCase);

    // ------------------------------------------------------------- Garanti --
    private async Task<List<BankaHareketSatiri>> GarantiAsync(Baglanti bag, DateTime bas, DateTime bit, CancellationToken iptal)
    {
        if (bag.OnayNo == "") throw GentegreHatasi.IsKurali($"{bag.HesapAd}: onay no (consentId) girilmemiş.");
        if (bag.ClientId == "" || bag.Secret == "") throw GentegreHatasi.IsKurali("Garanti entegrasyonunda Client ID / Secret boş.");
        var kok = Kok(bag);
        var istemci = http.CreateClient("banka");
        istemci.Timeout = TimeSpan.FromSeconds(60);

        // Garanti kuralı: her istek için YENİ erişim jetonu (scope ve yeniden deneme: GarantiJeton).
        //   İlk jetonu veren scope sonraki sayfalarda da kullanılır (her sayfada yeniden deneme olmaz).
        string? scope = bag.Scope == "" ? null : bag.Scope;
        async Task<string> JetonAsync()
        {
            var j = await GarantiJeton.AlAsync(istemci, kok, bag.ClientId, bag.Secret, scope, iptal);
            scope = j.Scope;
            return j.Jeton ?? throw new InvalidOperationException($"jeton alınamadı ({j.Kod}): {Kisa(j.Govde, 200)}");
        }

        var sonuc = new List<BankaHareketSatiri>();
        const int Boyut = 100;
        for (var sayfa = 1; sayfa <= 100; sayfa++)
        {
            var jeton = await JetonAsync();
            using var istek = new HttpRequestMessage(HttpMethod.Post,
                kok + "/balancesandmovements/accountinformation/transaction/v1/gettransactions");
            istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
            istek.Headers.TryAddWithoutValidation("GUID", Guid.NewGuid().ToString());
            var t = (DateTime d) => d.ToString("yyyy-MM-dd'T'HH:mm:ss.fff", CultureInfo.InvariantCulture);
            istek.Content = new StringContent(JsonSerializer.Serialize(new Dictionary<string, object?>
            {
                ["consentId"] = bag.OnayNo, ["unitNum"] = bag.SubeKodu, ["accountNum"] = bag.HesapNo,
                ["IBAN"] = bag.Iban.Replace(" ", ""), ["startDate"] = t(bas),
                // API tarifinde "endtDate", örnekte "endDate" - ikisi de gönderilir.
                ["endDate"] = t(bit), ["endtDate"] = t(bit),
                ["transactionId"] = "", ["pageIndex"] = sayfa, ["pageSize"] = Boyut,
            }), Encoding.UTF8, "application/json");
            using var yanit = await istemci.SendAsync(istek, iptal);
            var govde = await yanit.Content.ReadAsStringAsync(iptal);
            if (!yanit.IsSuccessStatusCode)
                throw new InvalidOperationException($"hareket servisi {(int)yanit.StatusCode}: {Kisa(govde, 200)}");
            using var j = JsonDocument.Parse(govde);
            var sayfaSatirlari = GarantiCevirici.Liste(j.RootElement);   // yanıt biçimi: GarantiCevirici
            sonuc.AddRange(sayfaSatirlari);
            if (sayfaSatirlari.Count < Boyut) break;
        }
        return sonuc;
    }

    // ------------------------------------------------------------ benzetim --
    /// <summary>Test ortamında anahtarsız: hesabın son 3 gününe deterministik örnek hareketler.</summary>
    /// <summary>Benzetimin karşı tarafları - öneri motoru boşa dönmesin diye kurumun kendi kayıtlarından.</summary>
    private sealed record BenzetimOrnegi(string MusteriAd, string MusteriVkn, string MusteriIban, string TedarikciAd,
                                         string TedarikciVkn, string KendiAd, string KendiIban);

    private static async Task<BenzetimOrnegi> BenzetimOrnekAsync(Npgsql.NpgsqlConnection b, int hesapId, CancellationToken iptal)
        => await b.TekAsync("""
            select coalesce(m.unvan, 'ORNEK MUSTERI AS'), coalesce(m.vkno, ''),
                   coalesce((select tb.iban from public.taraf_banka tb
                              where tb.taraf_id = m.id and tb.aktif = 1 and coalesce(tb.iban, '') <> '' limit 1), ''),
                   coalesce(t.unvan, 'ORNEK TEDARIKCI LTD'), coalesce(t.vkno, ''), coalesce(k.ad, ''), coalesce(k.iban, '')
              from (select 1) bos
              left join lateral (select x.id, x.unvan, x.vkno from public.taraf x where x.musteri = 1
                                    and length(coalesce(x.vkno, '')) in (10, 11) order by x.id limit 1) m on true
              left join lateral (select x.unvan, x.vkno from public.taraf x where x.tedarikci = 1
                                    and length(coalesce(x.vkno, '')) in (10, 11) order by x.id limit 1) t on true
              left join lateral (select x.ad, x.iban from public.hesap x where x.tur = 'B' and x.id <> @p0
                                    and length(coalesce(x.iban, '')) = 26 and coalesce(x.durum, 1) = 1
                                  order by x.id limit 1) k on true
            """, null, [hesapId], o => new BenzetimOrnegi(o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3),
                o.GetString(4), o.GetString(5), o.GetString(6)), iptal)
           ?? new BenzetimOrnegi("ORNEK MUSTERI AS", "", "", "ORNEK TEDARIKCI LTD", "", "", "");

    private static List<BankaHareketSatiri> Benzetim(Baglanti bag, DateTime bas, DateTime bit, BenzetimOrnegi o)
    {
        var liste = new List<BankaHareketSatiri>();
        var gun = bit.Date;
        var ornek = new (int saat, decimal tutar, string aciklama, string ad, string iban, string vkn)[]
        {
            (10, 4800m,   $"FAST GELEN {o.MusteriAd.ToUpperInvariant()} ODEMESI", o.MusteriAd, o.MusteriIban, o.MusteriVkn),
            (11, -1250m,  $"EFT GIDEN {o.TedarikciAd.ToUpperInvariant()} FATURA ODEMESI", o.TedarikciAd, "", o.TedarikciVkn),
            (14, -20000m, "HESAPLAR ARASI VIRMAN", o.KendiAd, o.KendiIban, ""),
            (15, -26.25m, "HESAP ISLETIM UCRETI", "", "", ""),
            (17, 984m,    "POS GUN SONU 41203388 BLOKESIZ", "", "", ""),
        };
        decimal bakiye = 100000m;
        for (var g = 0; g < 3; g++)
        {
            var d = gun.AddDays(-g);
            if (d < bas.Date) break;
            foreach (var (saat, tutar, aciklama, ad, iban, vkn) in ornek)
            {
                bakiye += tutar;
                liste.Add(new BankaHareketSatiri($"BNZ-{bag.HesapId}-{d:yyyyMMdd}-{saat}", d.AddHours(saat), d, tutar, bag.Doviz, bakiye,
                    aciklama, ad, iban, vkn, "", "BENZETIM", "{\"benzetim\": true}"));
            }
        }
        return liste;
    }

    private static Dictionary<string, System.Text.Json.JsonElement> Bacak(params (string Ad, object Deger)[] alanlar)
        => alanlar.ToDictionary(a => a.Ad, a => System.Text.Json.JsonSerializer.SerializeToElement(a.Deger));

    // ================================================================ işle ====
    public Task<int> OneriyiIsleAsync(long hareketId, int kullanici, int sube, CancellationToken iptal)
        => IsleAsync(hareketId, null, kullanici, sube, iptal);

    /// <summary>Hareketi işler: karar yoksa öneri. Döner: kasa işlemi id.</summary>
    public async Task<int> IsleAsync(long hareketId, Karar? karar, int kullanici, int sube, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var h = await b.TekAsync("""
            select h.id, h.hesap_id, h.tutar, h.islem_tarihi, h.aciklama, h.banka_islem_no, h.durum,
                   coalesce(h.oneri::text, '{}'), h.karsi_iban, coalesce(x.doviz_cinsi, 'TL'), h.sube_id
              from public.banka_hareket h join public.hesap x on x.id = h.hesap_id where h.id = @p0
            """, null, [hareketId], o => new
            {
                Id = o.GetInt64(0), Hesap = o.GetInt32(1), Tutar = o.GetDecimal(2), Tarih = o.GetDateTime(3),
                Aciklama = o.GetString(4), No = o.GetString(5), Durum = o.GetInt16(6), Oneri = o.GetString(7),
                KarsiIban = o.GetString(8), Doviz = o.GetString(9), Sube = o.GetInt32(10),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
        if (h.Durum == 2) throw GentegreHatasi.IsKurali("Bu hareket zaten işlendi.");
        if (h.Durum == 3) throw GentegreHatasi.IsKurali("Yoksayılan hareket işlenemez - önce geri alın.");

        if (karar is null)
        {
            using var j = JsonDocument.Parse(h.Oneri);
            var r = j.RootElement;
            int? I(string ad) => r.TryGetProperty(ad, out var v) && v.TryGetInt32(out var n) ? n : null;
            var tur = r.TryGetProperty("tur", out var tv) ? tv.GetString() ?? "" : "";
            if (tur == "") throw GentegreHatasi.IsKurali("Bu hareket için öneri yok - ne yapılacağını seçin.");
            karar = new Karar(tur, I("tarafId"), I("belgeId"), I("hedefHesapId"), I("masrafId"));
        }

        if (karar.Tur == "yoksay")
        {
            await b.CalistirAsync("update public.banka_hareket set durum = 3, isleyen = @p1, isleme_zamani = now() where id = @p0",
                                  null, [h.Id, kullanici], iptal);
            return 0;
        }

        var tutar = Math.Abs(h.Tutar);
        var gelen = h.Tutar > 0;
        var islem = new Dictionary<string, object?>
        {
            ["islemTarihi"] = h.Tarih, ["tutar"] = tutar, ["dovizCinsi"] = h.Doviz,
            ["aciklama"] = Kisa($"{h.Aciklama} · banka ref {h.No}", 200),
        };
        int? belge = null;
        List<Dictionary<string, System.Text.Json.JsonElement>>? bacaklar = null;
        switch (karar.Tur)
        {
            case "tahsilat" or "tediye":
                if (karar.TarafId is not > 0) throw GentegreHatasi.IsKurali("Cari seçilmeli.");
                islem["tur"] = (long)(gelen ? 22 : 32);
                islem["hesapId"] = (long)h.Hesap;
                islem["tarafId"] = (long)karar.TarafId.Value;
                belge = karar.BelgeId;
                break;
            case "virman" or "pos":
                if (karar.HedefHesapId is not > 0) throw GentegreHatasi.IsKurali("Karşı hesap seçilmeli.");
                // Ana hesap = paranın ÇIKTIĞI, karşı = GİRDİĞİ (kasa_islem_turu 43 / 44).
                islem["tur"] = (long)(karar.Tur == "pos" ? 44 : 43);
                islem["hesapId"] = (long)(gelen ? karar.HedefHesapId.Value : h.Hesap);
                islem["karsiHesapId"] = (long)(gelen ? h.Hesap : karar.HedefHesapId.Value);
                break;
            case "masraf":
                if (karar.MasrafId is not > 0) throw GentegreHatasi.IsKurali("Masraf kalemi seçilmeli.");
                // Banka Ödeme (32) şablonu cari bacağı ister; masrafta cari yok - bacaklar açık verilir:
                //   masraf borç, banka alacak.
                islem["tur"] = 32L;
                islem["hesapId"] = (long)h.Hesap;
                islem["masrafId"] = (long)karar.MasrafId.Value;
                bacaklar =
                [
                    Bacak(("masrafId", karar.MasrafId.Value), ("yon", "borc"), ("tutar", tutar)),
                    Bacak(("hesapId", h.Hesap), ("yon", "alacak"), ("tutar", tutar)),
                ];
                break;
            default: throw GentegreHatasi.Dogrulama($"Bilinmeyen işlem: {karar.Tur}");
        }

        var (kasaId, _) = await kasa.KaydetAsync(islem, bacaklar,
            new KasaSecenekleri { Taslak = false, Plan = false, BelgeId = belge },
            new YazmaBaglami(kullanici, h.Sube, "banka-hareket"), iptal);

        await using var tx = await b.BeginTransactionAsync(iptal);
        await b.CalistirAsync("""
            update public.banka_hareket set durum = 2, kasa_islem_id = @p1, isleyen = @p2, isleme_zamani = now(),
                   oneri = coalesce(oneri, '{}'::jsonb) || jsonb_build_object('islenen', @p3::text)
             where id = @p0
            """, tx, [h.Id, kasaId, kullanici, karar.Tur], iptal);
        // Virmanın karşı bacağı: öteki kendi hesabındaki ters tutarlı, ±2 gün, işlenmemiş hareket.
        if (karar.Tur == "virman")
            await b.CalistirAsync("""
                update public.banka_hareket set durum = 2, kasa_islem_id = @p1, isleyen = @p2, isleme_zamani = now()
                 where id = (select id from public.banka_hareket
                              where hesap_id = @p3 and durum in (0, 1, 4) and tutar = -@p4
                                and islem_tarihi between @p5 - interval '2 day' and @p5 + interval '2 day'
                              order by abs(extract(epoch from islem_tarihi - @p5)) limit 1)
                """, tx, [h.Id, kasaId, kullanici, karar.HedefHesapId!.Value, h.Tutar, h.Tarih], iptal);
        // Gönderen IBAN'ını carinin Banka / IBAN listesine ekle (1153) - bir sonraki hareket kendiliğinden eşleşir.
        if (karar.IbanEkle && karar.TarafId is > 0 && h.KarsiIban != "")
            await b.CalistirAsync("""
                insert into public.taraf_banka (taraf_id, banka_adi, iban, aciklama, ekleyen)
                select @p0, 'Banka hareketinden', @p1, 'Banka hareketi ' || @p2, @p3
                 where not exists (select 1 from public.taraf_banka where taraf_id = @p0 and public.fn_banka_iban(iban) = public.fn_banka_iban(@p1))
                """, tx, [karar.TarafId.Value, h.KarsiIban, h.No, kullanici], iptal);
        // Açıklamadan kural: metin -> bu cari.
        if (!string.IsNullOrWhiteSpace(karar.Kural))
            await b.CalistirAsync("""
                insert into public.banka_kural (sira, ad, kosul_tur, kosul_metin, yon, sonuc, hedef_taraf_id, hedef_hesap_id, hedef_masraf_id, ekleyen)
                values (100, left(@p0, 120), 'aciklama', left(@p0, 120), @p1, @p2, @p3, @p4, @p5, @p6)
                """, tx, [karar.Kural!.Trim(), (short)(gelen ? 1 : -1),
                          karar.Tur is "tahsilat" or "tediye" ? "cari" : karar.Tur,
                          karar.TarafId, karar.HedefHesapId, karar.MasrafId, kullanici], iptal);
        await tx.CommitAsync(iptal);
        return kasaId;
    }

    // ============================================================ eşleştir ====
    public sealed record EslesmeSonucu(int HesapId, decimal BankaTutar, decimal KasaTutar, string IslemNo);

    /// <summary>
    /// EŞLEŞTİR (1178, Banka Mutabakat İcmali): hareketi VAR OLAN kesin kasa işlemine bağlar - yeni kasa
    /// işlemi YAZILMAZ (çifte kayıt olmasın). İşlemin bu hesaptaki bacağının işaretli tutarı (borç − alacak)
    /// hareketin tutarına <paramref name="tolerans"/> içinde eşit olmalı (karar 25.10.2026: tolerans dışında
    /// eşleştirme yok; fark banka masrafıysa ayrı masraf işlemi). Bacak başka bir hareketle eşleşmişse
    /// reddedilir. Kasa işlemi iptal edilince 1157 tetiği hareketi yine bekleyene döndürür.
    /// </summary>
    public async Task<EslesmeSonucu> EslestirAsync(long hareketId, int kasaIslemId, decimal tolerans, int kullanici,
                                                    CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        await using var tx = await b.BeginTransactionAsync(iptal);
        var h = await b.TekAsync("""
            select h.hesap_id, h.tutar, h.durum from public.banka_hareket h where h.id = @p0 for update
            """, tx, [hareketId], o => new { Hesap = o.GetInt32(0), Tutar = o.GetDecimal(1), Durum = o.GetInt16(2) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
        if (h.Durum == 2) throw GentegreHatasi.IsKurali("Bu hareket zaten işlendi.");
        if (h.Durum == 3) throw GentegreHatasi.IsKurali("Yoksayılan hareket eşleştirilemez - önce geri alın.");
        var bacak = await b.TekAsync("""
            select coalesce(sum(m.borc - m.alacak), 0), count(*)::int, coalesce(max(m.islem_no), '')
              from public.v_mali_hareket_ek m
             where m.kasa_islem_id = @p0 and m.hesap_id = @p1 and m.hesap_ekstre = 1 and m.islem_durum = 2
            """, tx, [kasaIslemId, h.Hesap], o => new { Tutar = o.GetDecimal(0), Adet = o.GetInt32(1), No = o.GetString(2) }, iptal);
        if (bacak is null || bacak.Adet == 0)
            throw GentegreHatasi.IsKurali("Kasa işleminin bu hesapta kesin bir hareketi yok.");
        var fark = Math.Abs(bacak.Tutar - h.Tutar);
        if (fark > Math.Max(0, tolerans))
            throw GentegreHatasi.IsKurali(
                $"Tutar tutmuyor (banka {h.Tutar:N2}, kasa işlemi {bacak.Tutar:N2}, fark {fark:N2}). Fark banka masrafıysa ayrı masraf işlemi girin.");
        var bagli = await b.TekDegerAsync<long?>("""
            select id from public.banka_hareket where hesap_id = @p0 and kasa_islem_id = @p1 and durum = 2 and id <> @p2 limit 1
            """, tx, [h.Hesap, kasaIslemId, hareketId], iptal);
        if (bagli is not null) throw GentegreHatasi.IsKurali($"Bu kasa işlemi başka bir banka hareketiyle (#{bagli}) eşleşmiş.");
        await b.CalistirAsync("""
            update public.banka_hareket set durum = 2, kasa_islem_id = @p1, isleyen = @p2, isleme_zamani = now(),
                   oneri = coalesce(oneri, '{}'::jsonb) || jsonb_build_object('islenen', 'esles')
             where id = @p0
            """, tx, [hareketId, kasaIslemId, kullanici], iptal);
        await tx.CommitAsync(iptal);
        return new EslesmeSonucu(h.Hesap, h.Tutar, bacak.Tutar, bacak.No);
    }

    private static string Kisa(string? s, int n) => s is null ? "" : s.Length <= n ? s : s[..n];
}

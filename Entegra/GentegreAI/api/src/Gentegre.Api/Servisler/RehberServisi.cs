using System.Diagnostics;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// AI REHBER (447) — "ne nerede, nasıl yapılır" sorularını cevaplar.
///
/// <b>Asistan operatör değil REHBERDİR.</b> Bu servis hiçbir iş verisine
/// yazmaz; yalnız katalog okur ve metin üretir. Kayıt açma, değiştirme,
/// silme, onaylama yoktur - kullanıcıyı doğru ekrana ve doğru sıraya
/// yönlendirir.
///
/// <b>Bağlam serbest metin DB erişimi DEĞİL, güvenli metadata:</b> ekran
/// kataloğu (`ai_rehber_ekran`), konu kataloğu (`ai_rehber_konu`), aksiyon
/// kataloğu ve kullanıcının çözülmüş yetkileri. Model bağlanacaksa da aynı
/// bağlamı görecek - hasta/cari verisi rehber katmanına hiç girmez.
///
/// <b>Yetki sunucuda:</b> öneri listesi kullanıcının GÖREBİLECEĞİ ekranlara
/// süzülür. Yetkisi olmayan bir işlem sorulduğunda adımlar verilmez; "şu
/// yetki gerekiyor" denir - görmeye yetkili olmadığı işlemi tarif etmek,
/// yetkiyi delmenin yolunu anlatmaktır.
///
/// <b>Kontör:</b> katalogdan üretilen cevap ücretsizdir (dış maliyet yok).
/// Dil modeli bağlandığında çağrı başına `ai_kontor.cagri_ucreti` düşülür;
/// bakiye yoksa asistan kapanmaz, katalog cevabı vermeye devam eder.
/// </summary>
public sealed class RehberServisi(VeriKaynagi veri)
{
    /// <summary>Panelden gelen istek. `aktifSayfa` bağlamsal yardım içindir.</summary>
    public sealed record Istek(string KullaniciMesaji, short? AktifMod, string? AktifSayfa,
                               string? SeciliKaynak);

    public sealed record EkranOnerisi(string Kaynak, string Ad, string Rota, string Yol,
                                      string MenuGrup);
    public sealed record AksiyonOnerisi(string Kod, string Ad, string Ekran);
    public sealed record Adim(int No, string Metin, string? Ekran, string? Rota);

    public sealed record Yanit(
        string Cevap,
        IReadOnlyList<Adim> Adimlar,
        IReadOnlyList<EkranOnerisi> OnerilenEkranlar,
        IReadOnlyList<AksiyonOnerisi> OnerilenAksiyonlar,
        decimal GuvenSkoru,
        string? EksikBilgiSorusu,
        IReadOnlyList<string> Uyarilar,
        string KonuKod,
        short KaynakTuru,
        decimal KontorBakiye);

    /// <summary>Soruyu ayırt etmeyen kelimeler: skorlamada gürültü yaparlar.</summary>
    private static readonly HashSet<string> Durak = new(StringComparer.Ordinal)
    {
        "nasil", "nerede", "nereden", "nedir", "icin", "bir", "bu", "su", "ile",
        "ben", "biz", "yapilir", "yaparim", "yapmak", "istiyorum", "acilir",
        "acmak", "olur", "lazim", "gerekir", "hangi", "kim", "mi", "mu", "ne",
        "var", "yok", "sistem", "sistemde", "ekran", "ekrani", "menu", "nasıl",
    };

    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }

    /// <summary>Türkçe harfleri ASCII'ye indirger - `fn_ara_metin` ile aynı kural.</summary>
    private static string Sadelestir(string metin)
    {
        var kaynak = "ÇĞİIÖŞÜçğıiöşü";
        var hedef  = "CGIIOSUcgiiosu";
        var sb = new System.Text.StringBuilder(metin.Length);
        foreach (var h in metin)
        {
            var i = kaynak.IndexOf(h);
            sb.Append(i >= 0 ? char.ToLowerInvariant(hedef[i]) : char.ToLowerInvariant(h));
        }
        return sb.ToString();
    }

    /// <summary>Sorudan anlamlı kelimeleri çıkarır (3+ harf, durak değil).</summary>
    public static string[] Kelimeler(string soru) =>
        Sadelestir(soru)
            .Split(new[] { ' ', '\t', '\n', '\r', ',', '.', '?', '!', ':', ';', '/', '(', ')', '\'', '"' },
                   StringSplitOptions.RemoveEmptyEntries)
            .Where(k => k.Length >= 3 && !Durak.Contains(k))
            .Distinct(StringComparer.Ordinal)
            .Take(12)
            .ToArray();

    public async Task<Yanit> CevaplaAsync(Istek istek, IstekBaglami baglam,
                                          CancellationToken iptal)
    {
        var kronometre = Stopwatch.StartNew();
        var soru = (istek.KullaniciMesaji ?? "").Trim();
        if (soru.Length == 0)
            throw GentegreHatasi.IsKurali("Soru boş olamaz.");
        if (soru.Length > 600) soru = soru[..600];

        var kelimeler = Kelimeler(soru);
        await using var baglanti = await veri.AcAsync(iptal);

        // ÜRÜN MODU sunucudan: istemcinin gönderdiği `aktifMod` yalnız ipucu.
        //   HBYS ekranını ERP kurulumunda önermek, olmayan menüyü tarif etmek
        //   olurdu.
        var modMetin = await baglanti.TekDegerAsync<string>(
            "select deger from public.referans where anahtar = 'genel.urun_modu'",
            null, [], iptal);
        var urunModu = short.TryParse(modMetin, out var m) ? m : (short)1;

        var uyarilar = new List<string>();
        var kontorBakiye = await baglanti.TekDegerAsync<decimal>(
            "select bakiye from public.ai_kontor where id = 1", null, [], iptal);

        // ---------------------------------------------------------- konular
        var konular = kelimeler.Length == 0 ? new List<IDictionary<string, object?>>()
            : await baglanti.ListeAsync("""
                select k.kod, k.baslik, k.urun_modu as "urunModu", k.modul,
                       k.ekran_kaynak as "ekranKaynak", k.yetki_kodu as "yetkiKodu",
                       k.adimlar, k.uyarilar,
                       -- KELIME SINIRI: 'kart' aramasi 'hasta karti'na da
                       --   vurmali ama 'stok' arayan 'hasta'ya vurmamali;
                       --   bu yuzden anahtarin BASINDA/ICINDE kelime baslangici
                       --   aranir (bosluk + w).
                       (select count(*) from unnest(@p1::text[]) w
                         where ' ' || public.fn_ara_metin(k.anahtar || ' ' || k.baslik)
                               like '% ' || w || '%') as vurus,
                       similarity(public.fn_ara_metin(k.anahtar),
                                  public.fn_ara_metin(@p0)) as benzerlik
                  from public.ai_rehber_konu k
                 -- ERP cekirdegi (fatura, stok, kasa) HBYS kurulumunda da
                 --   vardir; yalniz HBYS-OZEL konu (2) ERP'de gizlenir.
                 where k.durum = 0 and (k.urun_modu <> 2 or @p2 = 2)
                 order by vurus desc, benzerlik desc, k.sira
                 limit 4
                """, null, [soru, kelimeler, urunModu], Satir, iptal);

        var enIyi = konular.FirstOrDefault();
        var vurus = enIyi is null ? 0 : Convert.ToInt32(enIyi["vurus"]);
        var benzerlik = enIyi is null ? 0f : Convert.ToSingle(enIyi["benzerlik"]);

        // GÜVEN: kaç anahtar kelime tuttu + metin benzerliği. Tek kelime tutan
        //   bir eşleşmeyi "kesin cevap" gibi sunmak, kullanıcıyı yanlış ekrana
        //   göndermekten daha kötüdür - orada bir de kendine güvenir.
        var oran = kelimeler.Length == 0 ? 0m : (decimal)vurus / kelimeler.Length;
        var guven = Math.Round(Math.Min(1m, oran * 0.7m + (decimal)benzerlik * 1.5m), 2);

        if (enIyi is not null && vurus >= 1 && guven >= 0.30m)
            return await KonuYanitiAsync(baglanti, enIyi, konular, soru, guven, urunModu,
                                         baglam, uyarilar, kontorBakiye, kronometre, iptal);

        // ------------------------------------------------- ekran eşleşmesi
        var ekranlar = await EkranAraAsync(baglanti, soru, kelimeler, urunModu, baglam,
                                           6, iptal);
        if (ekranlar.Count > 0)
        {
            var e = ekranlar[0];
            var cevap = $"Tam eşleşen bir rehber konusu bulamadım. Aradığınız iş "
                      + $"büyük olasılıkla **{e.Yol}** ekranında; oradan başlayın. "
                      + "Ne yapmak istediğinizi bir cümleyle daha açarsanız adımları "
                      + "sırayla verebilirim.";
            await LogAsync(baglanti, baglam, soru, 2, "", 0.35m, istek, kronometre, iptal);
            return new Yanit(cevap, [], ekranlar,
                             await AksiyonlariAsync(e.Kaynak, baglam), 0.35m,
                             "Hangi işlemi yapmak istiyorsunuz: kayıt açma, listeleme "
                             + "yoksa belge gönderme?",
                             uyarilar, "", 2, kontorBakiye);
        }

        // --------------------------------------------------- cevap yok
        await LogAsync(baglanti, baglam, soru, 0, "", 0m, istek, kronometre, iptal);
        return new Yanit(
            "Bu soruya bakabileceğim bir rehber konusu bulamadım. Sorunuzu işin adıyla "
            + "yazarsanız (örneğin \"hasta kaydı\", \"satış faturası\", \"numune kabul\") "
            + "adımları çıkarabilirim.",
            [], [], [], 0m,
            "Hangi modülde çalışıyorsunuz: hasta/randevu (HBYS) mu, fatura/stok (ERP) mü?",
            uyarilar, "", 0, kontorBakiye);
    }

    // ------------------------------------------------------------- konu ----
    private async Task<Yanit> KonuYanitiAsync(
        NpgsqlConnection baglanti, IDictionary<string, object?> konu,
        List<IDictionary<string, object?>> hepsi, string soru, decimal guven,
        short urunModu, IstekBaglami baglam, List<string> uyarilar,
        decimal kontorBakiye, Stopwatch kronometre, CancellationToken iptal)
    {
        var kod = konu["kod"]?.ToString() ?? "";
        var baslik = konu["baslik"]?.ToString() ?? "";
        var yetkiKodu = konu["yetkiKodu"]?.ToString() ?? "";
        var modul = konu["modul"]?.ToString() ?? "";

        // YETKİ: yetkisi olmayana adım verilmez. "Şuraya git, şu düğmeye bas"
        //   demek, göremediği işlemi tarif etmektir.
        if (yetkiKodu != "" && !baglam.Yetkiler.Var(yetkiKodu, Islem.Gor))
        {
            await LogAsync(baglanti, baglam, soru, 1, kod, guven, null, kronometre, iptal);
            var yonetim = await EkranAraAsync(baglanti, "roller yetki", ["yetki", "rol"],
                                              urunModu, baglam, 2, iptal);
            return new Yanit(
                $"**{baslik}** için sizde yetki görünmüyor (gereken yetki: `{yetkiKodu}`). "
                + "Adımları paylaşamıyorum; yöneticinizden bu yetkiyi istemeniz gerekiyor.",
                [], yonetim, [], guven, null,
                [$"Gereken yetki: {yetkiKodu}"], kod, 1, kontorBakiye);
        }

        // MODÜL: kapalı modülün ekranı menüde hiç yoktur.
        if (modul != "")
        {
            var acik = await baglanti.TekDegerAsync<bool>(
                "select public.fn_kurum_modul_acik(@p0, @p1)", null,
                [modul, baglam.SubeId], iptal);
            if (!acik)
                uyarilar.Add($"\"{modul}\" modülü bu kurulumda kapalı görünüyor; "
                           + "ekran menüde çıkmayabilir (Yönetim › Modül Ayarları).");
        }

        // Adımlar + her adımın ekranı (yetki süzgecinden geçmiş rota).
        var adimlar = new List<Adim>();
        var ekranKodlari = new List<string>();
        if (konu["adimlar"] is string ham && ham.Length > 0)
        {
            using var belge = JsonDocument.Parse(ham);
            var no = 0;
            foreach (var oge in belge.RootElement.EnumerateArray())
            {
                no++;
                var metin = oge.TryGetProperty("metin", out var mv) ? mv.GetString() ?? "" : "";
                var ekran = oge.TryGetProperty("ekran", out var ev) ? ev.GetString() : null;
                string? rota = null;
                if (!string.IsNullOrEmpty(ekran))
                {
                    var bilgi = await EkranBilgisiAsync(baglanti, ekran!, urunModu, baglam, iptal);
                    // Yetkisi yoksa adım kalır ama DÜĞME çizilmez: iş akışını
                    //   anlatmak başka, göremediği ekrana yollamak başka.
                    if (bilgi is not null) { rota = bilgi.Rota; ekranKodlari.Add(ekran!); }
                }
                adimlar.Add(new Adim(oge.TryGetProperty("no", out var nv) && nv.TryGetInt32(out var n)
                                         ? n : no,
                                     metin, ekran, rota));
            }
        }

        var konuUyari = konu["uyarilar"]?.ToString() ?? "";
        if (konuUyari.Length > 0) uyarilar.Add(konuUyari);

        var anaEkran = konu["ekranKaynak"]?.ToString() ?? "";
        var oneriler = new List<EkranOnerisi>();
        foreach (var k in (string.IsNullOrEmpty(anaEkran) ? ekranKodlari
                                                          : ekranKodlari.Prepend(anaEkran))
                          .Distinct(StringComparer.Ordinal))
        {
            var bilgi = await EkranBilgisiAsync(baglanti, k, urunModu, baglam, iptal);
            if (bilgi is not null && !oneriler.Any(o => o.Rota == bilgi.Rota))
                oneriler.Add(bilgi);
        }

        // Yakın diğer konular: "bunu mu demek istediniz" yerine ekran önerisi.
        var cevap = $"**{baslik}** — {adimlar.Count} adım:";
        if (guven < 0.55m)
            cevap = $"Sanırım **{baslik}** konusunu soruyorsunuz. Farklı bir şey "
                  + "kastettiyseniz sorunuzu biraz açar mısınız?";

        await LogAsync(baglanti, baglam, soru, 1, kod, guven, null, kronometre, iptal);
        return new Yanit(cevap, adimlar, oneriler,
                         await AksiyonlariAsync(anaEkran, baglam), guven,
                         guven < 0.45m ? "Aradığınız bu değilse hangi ekranda "
                                       + "çalıştığınızı yazın." : null,
                         uyarilar, kod, 1, kontorBakiye);
    }

    // ------------------------------------------------------------ ekranlar --
    private async Task<List<EkranOnerisi>> EkranAraAsync(
        NpgsqlConnection baglanti, string soru, string[] kelimeler, short urunModu,
        IstekBaglami baglam, int adet, CancellationToken iptal)
    {
        if (kelimeler.Length == 0) return [];
        var satirlar = await baglanti.ListeAsync("""
            select e.kaynak, e.baslik, e.rota, e.yol, e.menu_grup as "menuGrup",
                   e.yetki_kodu as "yetkiKodu", e.modul,
                   (select count(*) from unnest(@p1::text[]) w
                     where ' ' || public.fn_ara_metin(e.anahtar)
                           like '% ' || w || '%') as vurus,
                   similarity(public.fn_ara_metin(e.anahtar),
                              public.fn_ara_metin(@p0)) as benzerlik
              from public.ai_rehber_ekran e
             where e.durum = 0 and e.menu_gizli = 0
               and (e.urun_modu <> 2 or @p2 = 2)
             order by vurus desc, benzerlik desc, e.baslik
             limit 20
            """, null, [soru, kelimeler, urunModu], Satir, iptal);

        return satirlar
            .Where(s => Convert.ToInt32(s["vurus"]) >= 1)
            .Where(s => YetkiVar(s["yetkiKodu"]?.ToString(), baglam))
            .Take(adet)
            .Select(s => new EkranOnerisi(
                s["kaynak"]?.ToString() ?? "", s["baslik"]?.ToString() ?? "",
                s["rota"]?.ToString() ?? "", s["yol"]?.ToString() ?? "",
                s["menuGrup"]?.ToString() ?? ""))
            .ToList();
    }

    /// <summary>Kaynak koduna göre TEK ekran (yetkisi yoksa null).</summary>
    private async Task<EkranOnerisi?> EkranBilgisiAsync(
        NpgsqlConnection baglanti, string kaynak, short urunModu, IstekBaglami baglam,
        CancellationToken iptal)
    {
        var s = await baglanti.TekAsync("""
            select e.kaynak, e.baslik, e.rota, e.yol, e.menu_grup as "menuGrup",
                   e.yetki_kodu as "yetkiKodu"
              from public.ai_rehber_ekran e
             -- Ekran kodu ROTA da olabilir: ayni kaynagi (belge) on dort
             --   ekran paylasiyor; konu "/belge" (Satis Faturalari) diyerek
             --   dogru olani secer, "belge" derse ilk gorunen ekran gelir.
             where (e.rota = @p0 or e.rota = '/' || @p0 or e.kaynak = @p0)
               and e.durum = 0
               and (e.urun_modu <> 2 or @p1 = 2)
             order by e.menu_gizli, e.id
             limit 1
            """, null, [kaynak, urunModu], Satir, iptal);
        if (s is null || !YetkiVar(s["yetkiKodu"]?.ToString(), baglam)) return null;
        return new EkranOnerisi(s["kaynak"]?.ToString() ?? "", s["baslik"]?.ToString() ?? "",
                                s["rota"]?.ToString() ?? "", s["yol"]?.ToString() ?? "",
                                s["menuGrup"]?.ToString() ?? "");
    }

    private static bool YetkiVar(string? yetkiKodu, IstekBaglami baglam) =>
        string.IsNullOrEmpty(yetkiKodu) || baglam.Yetkiler.Var(yetkiKodu, Islem.Gor);

    /// <summary>
    /// Ekranın araç çubuğundaki, kullanıcının YETKİLİ olduğu aksiyonlar.
    /// Aksiyon kataloğu ekran adını `&lt;kaynak&gt;-liste` kalıbıyla tutuyor.
    /// </summary>
    private static Task<IReadOnlyList<AksiyonOnerisi>> AksiyonlariAsync(
        string kaynak, IstekBaglami baglam)
    {
        if (string.IsNullOrEmpty(kaynak))
            return Task.FromResult<IReadOnlyList<AksiyonOnerisi>>([]);
        var ekranAdi = kaynak + "-liste";
        var aksiyonlar = AksiyonKatalogu.Ekran(ekranAdi);
        if (aksiyonlar is null)
            return Task.FromResult<IReadOnlyList<AksiyonOnerisi>>([]);
        IReadOnlyList<AksiyonOnerisi> sonuc = aksiyonlar
            .Where(a => AksiyonKatalogu.Yetkili(a, baglam.Yetkiler))
            .Take(6)
            .Select(a => new AksiyonOnerisi(a.Kod, a.Ad, ekranAdi))
            .ToList();
        return Task.FromResult(sonuc);
    }

    // ---------------------------------------------------------------- log --
    private static async Task LogAsync(
        NpgsqlConnection baglanti, IstekBaglami baglam, string soru, short kaynak,
        string konuKod, decimal guven, Istek? istek, Stopwatch kronometre,
        CancellationToken iptal)
    {
        // Cevapsız soru = eksik rehber konusu. Günlük olmadan "asistan işe
        //   yaramıyor" geri bildirimi ölçülemez.
        await baglanti.CalistirAsync("""
            insert into public.ai_rehber_log
                   (kullanici_id, sube_id, soru, kaynak, konu_kod, guven,
                    aktif_mod, aktif_sayfa, sure_ms)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
            """, null,
            [baglam.KullaniciId, baglam.SubeId, soru, kaynak, konuKod, guven,
             (short)(istek?.AktifMod ?? 0), istek?.AktifSayfa ?? "",
             (int)kronometre.ElapsedMilliseconds], iptal);
    }
}

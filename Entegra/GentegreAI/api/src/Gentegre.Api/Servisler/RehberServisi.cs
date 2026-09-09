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
public sealed class RehberServisi(VeriKaynagi veri, RehberModeli? model = null)
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
        /// <summary>1 katalog · 2 ekran · 3 bağlamsal · 5 model destekli · 0 yok.</summary>
        short KaynakTuru,
        decimal KontorBakiye,
        /// <summary>Cevabı dil modeli mi yazdı? (katalog cevabı ücretsizdir)</summary>
        bool ModelKullanildi = false,
        string Model = "");






    public async Task<Yanit> CevaplaAsync(Istek istek, IstekBaglami baglam,
                                          CancellationToken iptal)
    {
        var kronometre = Stopwatch.StartNew();
        var soru = (istek.KullaniciMesaji ?? "").Trim();
        if (soru.Length == 0)
            throw GentegreHatasi.IsKurali("Soru boş olamaz.");
        if (soru.Length > 600) soru = soru[..600];

        var kelimeler = RehberMetin.Kelimeler(soru);
        await using var baglanti = await veri.AcAsync(iptal);

        // ÜRÜN MODU sunucudan: istemcinin gönderdiği `aktifMod` yalnız ipucu.
        //   HBYS ekranını ERP kurulumunda önermek, olmayan menüyü tarif etmek
        //   olurdu.
        //   Mod SUBENIN PROFILINDEN gelir (489).
        var urunModu = (short)await baglanti.TekDegerAsync<short>(
            "select public.fn_urun_modu(@p0)", null, [baglam.SubeId ?? 0], iptal);

        var uyarilar = new List<string>();
        var kontorBakiye = await baglanti.TekDegerAsync<decimal>(
            "select bakiye from public.ai_kontor where id = 1", null, [], iptal);

        // ------------------------------------------------- bağlamsal yardım
        // "Bu ekranda ne yapabilirim?" sorusunun cevabı DURDUĞUNUZ ekrana
        //   bağlıdır: ekranın kendisi, yetkili düğmeleri ve o ekranla ilgili
        //   rehber konuları. Katalog araması bunu bilemez.
        if (RehberMetin.BaglamsalMi(soru) && !string.IsNullOrWhiteSpace(istek.AktifSayfa))
        {
            var yardim = await BaglamsalYardimAsync(baglanti, istek, soru, urunModu,
                                                    baglam, uyarilar, kontorBakiye,
                                                    kronometre, iptal);
            if (yardim is not null) return yardim;
        }

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
                 where k.durum = 0 and (k.urun_modu <> 2 or @p2 in (2, 3))
                 order by vurus desc, benzerlik desc, k.sira
                 limit 4
                """, null, [soru, kelimeler, urunModu], OkuyucuGenisletmeleri.Sozluk, iptal);

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

        // --------------------------------------------------------- model
        // Katalog konuyu bulamadı. MODEL BURADA DEVREYE GİRER: doğru cevabı
        //   katalogdan üretemediğimiz yerde, kullanıcının kendi cümlesine
        //   uyan yol tarifini yazsın. Bağlam yine katalogdur - model yalnız
        //   ANLATIR, ekran uyduramaz (beyaz liste doğrulaması).
        var modelEkranlari = await EkranAraAsync(baglanti, soru, kelimeler, urunModu,
                                                 baglam, 12, iptal);
        var modelYaniti = await ModelDeneAsync(baglanti, istek, soru, urunModu, konular,
                                               modelEkranlari, baglam, uyarilar,
                                               kronometre, iptal);
        if (modelYaniti is not null) return modelYaniti;

        // ------------------------------------------------- ekran eşleşmesi
        var ekranlar = modelEkranlari.Count > 0 ? modelEkranlari.Take(6).ToList()
            : await EkranAraAsync(baglanti, soru, kelimeler, urunModu, baglam, 6, iptal);
        if (ekranlar.Count > 0)
        {
            var e = ekranlar[0];
            var cevap = $"Tam eşleşen bir rehber konusu bulamadım. Aradığınız iş "
                      + $"büyük olasılıkla **{e.Yol}** ekranında; oradan başlayın. "
                      + "Ne yapmak istediğinizi bir cümleyle daha açarsanız adımları "
                      + "sırayla verebilirim.";
            await LogAsync(baglanti, baglam, soru, 2, "", 0.35m, istek, kronometre, iptal);
            return new Yanit(cevap, [], ekranlar,
                             Aksiyonlar(null, e.Kaynak, baglam), 0.35m,
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

    // ---------------------------------------------------------------- model --
    /// <summary>
    /// Katalog cevaplayamadığında modeli dener. Üç kapı sırayla: <b>model
    /// hazır mı</b> (anahtar + ayar), <b>kontör var mı</b> (kurumsal açma,
    /// bakiye, günlük tavan), <b>çıktı geçerli mi</b> (beyaz liste). Herhangi
    /// biri tutmazsa <c>null</c> döner ve katalog akışı devam eder - asistan
    /// susmaz, yalnız üslubu sadeleşir.
    /// </summary>
    private async Task<Yanit?> ModelDeneAsync(
        NpgsqlConnection baglanti, Istek istek, string soru, short urunModu,
        List<IDictionary<string, object?>> konular, List<EkranOnerisi> ekranlar,
        IstekBaglami baglam, List<string> uyarilar, Stopwatch kronometre,
        CancellationToken iptal)
    {
        if (model is null || !model.Hazir || ekranlar.Count == 0) return null;

        var (izin, ucret, sebep) = await KontorDurumAsync(baglanti, iptal);
        if (!izin)
        {
            if (sebep.Length > 0) uyarilar.Add(sebep);
            return null;
        }

        // MODELE GİDEN BAĞLAM: yalnız güvenli metadata. Ekranlar zaten yetki
        //   süzgecinden geçti; konu başlıkları katalogdan. Hasta/cari/belge
        //   verisi bu katmana hiç girmez.
        var konuOzetleri = konular
            .Where(k => YetkiVar(k["yetkiKodu"]?.ToString(), baglam))
            .Take(3)
            .Select(k => new RehberModeli.KonuOzeti(
                k["baslik"]?.ToString() ?? "", AdimOzeti(k["adimlar"]?.ToString())))
            .ToList();

        var cikti = await model.DeneAsync(new RehberModeli.Girdi(
            soru, urunModu, istek.AktifSayfa,
            ekranlar.Select(e => new RehberModeli.Ekran(e.Kaynak, e.Rota, e.Yol)).ToList(),
            konuOzetleri), iptal);
        if (cikti is null) return null;

        var adimlar = cikti.Adimlar
            .Select((a, i) => new Adim(i + 1, a.Metin,
                                       ekranlar.FirstOrDefault(e => e.Rota == a.Ekran)?.Kaynak,
                                       a.Ekran))
            .ToList();

        // Kullanılan ekranlar önerilere; model ekran vermediyse aramanın ilk üçü.
        var oneriler = adimlar.Where(a => a.Rota is not null)
            .Select(a => ekranlar.First(e => e.Rota == a.Rota))
            .DistinctBy(e => e.Rota).ToList();
        if (oneriler.Count == 0) oneriler = ekranlar.Take(3).ToList();

        var jeton = cikti.GirisJeton + cikti.CikisJeton;
        var logId = await LogAsync(baglanti, baglam, soru, 5, "model", cikti.Guven, istek,
                                   kronometre, iptal, cikti.Model, cikti.GirisJeton,
                                   cikti.CikisJeton, ucret);
        // KONTÖR ÇAĞRI BAŞARILI OLUNCA DÜŞÜLÜR: ödemediğimiz bir çağrı için
        //   müşteriden kontör almak savunulamaz.
        await KontorDusAsync(baglanti, baglam, ucret, jeton, logId, cikti.Model, iptal);

        return new Yanit(cikti.Cevap, adimlar, oneriler,
                         Aksiyonlar(null, oneriler.FirstOrDefault()?.Kaynak ?? "", baglam),
                         cikti.Guven, cikti.EksikBilgiSorusu, uyarilar, "model", 5,
                         await BakiyeAsync(baglanti, iptal), true, cikti.Model);
    }

    /// <summary>Konu adımlarını modele tek satır özet olarak verir.</summary>
    private static string AdimOzeti(string? adimlarJson)
    {
        if (string.IsNullOrWhiteSpace(adimlarJson)) return "";
        try
        {
            using var belge = JsonDocument.Parse(adimlarJson);
            var metinler = belge.RootElement.EnumerateArray()
                .Select(o => o.TryGetProperty("metin", out var m) ? m.GetString() ?? "" : "")
                .Where(m => m.Length > 0)
                .Take(6);
            return string.Join(" → ", metinler);
        }
        catch (JsonException) { return ""; }
    }

    /// <summary>
    /// Model çağrısı yapılabilir mi? Üç kapı: kurum modeli kapatmış olabilir,
    /// bakiye yetmeyebilir, günlük tavan dolmuş olabilir. Kapı kapalıysa
    /// kullanıcıya SEBEP söylenir - sessizce sade cevap vermek "asistan
    /// bozuldu" diye algılanır.
    /// </summary>
    private static async Task<(bool Izin, decimal Ucret, string Sebep)> KontorDurumAsync(
        NpgsqlConnection baglanti, CancellationToken iptal)
    {
        var satir = await baglanti.TekAsync("""
            select k.bakiye, k.cagri_ucreti as "ucret", k.model_aktif as "aktif",
                   k.gunluk_cagri_siniri as "sinir",
                   (select count(*) from public.ai_rehber_log l
                     where l.kaynak = 5 and l.tarih >= current_date) as "bugun"
              from public.ai_kontor k where k.id = 1
            """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (satir is null) return (false, 0m, "");

        var ucret = Convert.ToDecimal(satir["ucret"]);
        if (Convert.ToInt16(satir["aktif"]) != 1) return (false, ucret, "");

        var bakiye = Convert.ToDecimal(satir["bakiye"]);
        if (bakiye < ucret)
            return (false, ucret,
                    "AI kontörü bitti; cevaplar şimdilik katalogdan üretiliyor "
                    + "(Yönetim › Yapay Zeka › Kontör).");

        var sinir = Convert.ToInt32(satir["sinir"]);
        if (sinir > 0 && Convert.ToInt64(satir["bugun"]) >= sinir)
            return (false, ucret,
                    "Bugünkü AI çağrı sınırına ulaşıldı; cevaplar katalogdan üretiliyor.");

        return (true, ucret, "");
    }

    private static async Task<decimal> BakiyeAsync(NpgsqlConnection baglanti,
                                                   CancellationToken iptal) =>
        await baglanti.TekDegerAsync<decimal>(
            "select bakiye from public.ai_kontor where id = 1", null, [], iptal);

    /// <summary>Kontörü düşer ve hareketi yazar (tur 2 = harcama).</summary>
    private static async Task KontorDusAsync(
        NpgsqlConnection baglanti, IstekBaglami baglam, decimal ucret, int jeton,
        long? logId, string modelAdi, CancellationToken iptal)
    {
        if (ucret <= 0) return;
        await baglanti.CalistirAsync("""
            update public.ai_kontor
               set bakiye = greatest(0, bakiye - @p0), degistirme_tarihi = now()
             where id = 1
            """, null, [ucret], iptal);
        await baglanti.CalistirAsync("""
            insert into public.ai_kontor_hareket
                   (tur, miktar, bakiye, aciklama, kullanici_id, rehber_log_id, jeton)
            values (2, @p0, (select bakiye from public.ai_kontor where id = 1),
                    @p1, @p2, @p3, @p4)
            """, null,
            [ucret, "AI rehber cevabı (" + modelAdi + ")", baglam.KullaniciId, logId, jeton],
            iptal);
    }

    // -------------------------------------------------- bağlamsal yardım ---
    /// <summary>
    /// Aktif ekranın kendisini anlatır: ne işe yarar, hangi düğmeler açık
    /// (yetkiliyse) ve o ekranla ilgili rehber konuları. Alan sorusuysa
    /// kolon metadata'sından cevaplar.
    ///
    /// <b>Kolonlar da yetkiye tabidir</b>: alan yetkisi kapalı bir kolonu
    /// "şu alan şunu gösterir" diye anlatmak, görmediği veriyi tarif etmektir.
    /// </summary>
    private async Task<Yanit?> BaglamsalYardimAsync(
        NpgsqlConnection baglanti, Istek istek, string soru, short urunModu,
        IstekBaglami baglam, List<string> uyarilar, decimal kontorBakiye,
        Stopwatch kronometre, CancellationToken iptal)
    {
        var rota = (istek.AktifSayfa ?? "").Trim();
        if (rota.Length == 0) return null;
        // "/hasta/5057" -> "/hasta": kart rotası da o listenin ekranıdır.
        var kok = "/" + rota.TrimStart('/').Split('/')[0];

        var ekran = await baglanti.TekAsync("""
            select e.kaynak, e.baslik, e.rota, e.yol, e.menu_grup as "menuGrup",
                   e.yetki_kodu as "yetkiKodu", e.modul, e.aciklama,
                   e.aksiyon_ekrani as "aksiyonEkrani"
              from public.ai_rehber_ekran e
             where (e.rota = @p0 or e.rota = @p1) and e.durum = 0
             order by case when e.rota = @p0 then 0 else 1 end, e.id
             limit 1
            """, null, [rota, kok], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (ekran is null) return null;

        var kaynak = ekran["kaynak"]?.ToString() ?? "";
        var yetkiKodu = ekran["yetkiKodu"]?.ToString() ?? "";
        var ad = ekran["baslik"]?.ToString() ?? "";
        var yol = ekran["yol"]?.ToString() ?? "";
        if (!YetkiVar(yetkiKodu, baglam)) return null;   // oraya zaten giremezdi

                var alanSorusu = RehberMetin.AlanSorusuMu(soru);

        // ------------------------------------------------------ alan sorusu
        if (alanSorusu)
        {
            var kolon = KolonBul(kaynak, soru, baglam);
            if (kolon is not null)
            {
                var (kAd, kBaslik, kTip, kFiltre) = kolon.Value;
                var tipMetni = kTip switch
                {
                    "para" => "para tutarı", "sayi" => "sayı", "tarih" => "tarih",
                    "kod" => "kod listesinden gelen değer",
                    "mantik" => "evet/hayır", _ => "metin",
                };
                var yardim = await baglanti.TekDegerAsync<string>("""
                    select metin from public.help
                     where anahtar = @p0 or anahtar = @p1 limit 1
                    """, null, [kaynak + "." + kAd, "ayar." + kaynak + "." + kAd], iptal);

                await LogAsync(baglanti, baglam, soru, 3, "alan:" + kAd, 0.8m, istek,
                               kronometre, iptal);
                var metin = "**" + kBaslik + "** — " + ad + " ekranında bir " + tipMetni
                          + " alanı" + (kFiltre ? "; süzgeçte kullanılabilir." : ".");
                if (!string.IsNullOrWhiteSpace(yardim)) metin += " " + yardim;
                return new Yanit(metin, [], [], [], 0.8m, null, uyarilar, "", 3,
                                 kontorBakiye);
            }
        }

        // -------------------------------------------- "bu ekranda ne yapılır"
        var aksiyonlar = Aksiyonlar(ekran["aksiyonEkrani"]?.ToString(), kaynak, baglam);
        var konular = await baglanti.ListeAsync("""
            select k.kod, k.baslik
              from public.ai_rehber_konu k
             where k.durum = 0 and (k.urun_modu <> 2 or @p1 in (2, 3))
               and (k.ekran_kaynak = @p0 or k.ekran_kaynak = @p2)
             order by k.sira limit 4
            """, null, [kaynak, urunModu, rota], OkuyucuGenisletmeleri.Sozluk, iptal);

        var adimlar = new List<Adim>();
        var no = 0;
        foreach (var k in konular)
        {
            no++;
            // Konu adı ile sorulunca adımlar zaten geliyor; burada YOL GÖSTERİR.
            adimlar.Add(new Adim(no, (k["baslik"]?.ToString() ?? "")
                                     + " — adımları görmek için bunu sorun.", null, null));
        }

        var aciklama = ekran["aciklama"]?.ToString() ?? "";
        var cevap = "**" + yol + "** ekranındasınız."
                  + (aciklama.Length > 0 ? " " + aciklama : "")
                  + (aksiyonlar.Count > 0
                     ? " Burada açık olan işlemler: "
                       + string.Join(" · ", aksiyonlar.Select(a => a.Ad)) + "."
                     : " Bu ekranda size açık bir işlem düğmesi görünmüyor.");

        await LogAsync(baglanti, baglam, soru, 3, "ekran:" + kaynak, 0.8m, istek,
                       kronometre, iptal);
        return new Yanit(cevap, adimlar,
                         [new EkranOnerisi(kaynak, ad, ekran["rota"]?.ToString() ?? "",
                                           yol, ekran["menuGrup"]?.ToString() ?? "")],
                         aksiyonlar, 0.8m, null, uyarilar, "", 3, kontorBakiye);
    }

    /// <summary>
    /// Sorudaki kelimelere en çok uyan KOLONU bulur. Alan yetkisi kapalıysa
    /// kolon yok sayılır - görünmeyen alanı tarif etmek de bir sızıntıdır.
    /// </summary>
    private static (string Ad, string Baslik, string Tip, bool Filtre)? KolonBul(
        string kaynak, string soru, IstekBaglami baglam)
    {
        var tanim = KaynakKatalogu.Bul(kaynak);
        if (tanim is null) return null;
        var kelimeler = RehberMetin.AlanAramaKelimeleri(soru);
        if (kelimeler.Length == 0) return null;

        (string Ad, string Baslik, string Tip, bool Filtre)? enIyi = null;
        var enPuan = 0;
        foreach (var k in tanim.Kolonlar)
        {
            // ALAN YETKİSİ kapalı kolon hiç aranmaz: görmediği alanı tarif
            //   etmek de bir sızıntıdır.
            if (!baglam.Yetkiler.AlanOkunur(kaynak, k.YetkiAlani ?? k.Ad)) continue;
            var puan = RehberMetin.KolonPuani(k.Baslik, k.Ad, kelimeler);
            if (puan <= enPuan) continue;
            enPuan = puan;
            enIyi = (k.Ad, k.Baslik, k.Tip, k.Filtrelenebilir);
        }
        return enPuan > 0 ? enIyi : null;
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
        // ADIMLAR ÖNCE, ÇEKİNCE SONRA. Eski metin düşük güvende yalnız
        //   "sanırım şunu soruyorsunuz?" diyordu; adımlar altta dursa da
        //   kullanıcı bunu "cevap vermedi, ekran önerdi" diye okuyordu.
        var cevap = $"**{baslik}** — {adimlar.Count} adım:";
        if (guven < 0.45m)
            cevap += " (tam emin değilim; başka bir şey kastettiyseniz sorunuzu açın)";

        var anaAksiyon = await baglanti.TekDegerAsync<string>(
            "select aksiyon_ekrani from public.ai_rehber_ekran "
            + " where (rota = @p0 or rota = '/' || @p0 or kaynak = @p0) "
            + "   and durum = 0 order by menu_gizli, id limit 1",
            null, [anaEkran], iptal);

        await LogAsync(baglanti, baglam, soru, 1, kod, guven, null, kronometre, iptal);
        return new Yanit(cevap, adimlar, oneriler,
                         Aksiyonlar(anaAksiyon, anaEkran, baglam), guven,
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
               and (e.urun_modu <> 2 or @p2 in (2, 3))
             order by vurus desc, benzerlik desc, e.baslik
             limit 20
            """, null, [soru, kelimeler, urunModu], OkuyucuGenisletmeleri.Sozluk, iptal);

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
               and (e.urun_modu <> 2 or @p1 in (2, 3))
             order by e.menu_gizli, e.id
             limit 1
            """, null, [kaynak, urunModu], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (s is null || !YetkiVar(s["yetkiKodu"]?.ToString(), baglam)) return null;
        return new EkranOnerisi(s["kaynak"]?.ToString() ?? "", s["baslik"]?.ToString() ?? "",
                                s["rota"]?.ToString() ?? "", s["yol"]?.ToString() ?? "",
                                s["menuGrup"]?.ToString() ?? "");
    }

    private static bool YetkiVar(string? yetkiKodu, IstekBaglami baglam) =>
        string.IsNullOrEmpty(yetkiKodu) || baglam.Yetkiler.Var(yetkiKodu, Islem.Gor);

    /// <summary>
    /// Ekranın araç çubuğundaki, kullanıcının YETKİLİ olduğu aksiyonlar.
    ///
    /// Aksiyon ekranının adı katalogda saklanır (`aksiyon_ekrani`); yoksa
    /// `&lt;kaynak&gt;-liste` kalıbına düşülür. Kalıp her ekranda tutmuyor:
    /// Radyoloji Çalışma Listesi'nin kaynağı `radyoloji-istem`, aksiyon
    /// ekranı `radyoloji-liste` - tahminle o ekranda hiçbir düğme
    /// sayılamıyordu ve asistan "size açık işlem yok" diyordu.
    /// </summary>
    private static IReadOnlyList<AksiyonOnerisi> Aksiyonlar(
        string? aksiyonEkrani, string kaynak, IstekBaglami baglam)
    {
        var ad = string.IsNullOrWhiteSpace(aksiyonEkrani)
            ? (string.IsNullOrEmpty(kaynak) ? "" : kaynak + "-liste")
            : aksiyonEkrani!;
        if (ad.Length == 0) return [];
        var aksiyonlar = AksiyonKatalogu.Ekran(ad);
        if (aksiyonlar is null) return [];
        return aksiyonlar
            .Where(a => AksiyonKatalogu.Yetkili(a, baglam.Yetkiler))
            .Take(6)
            .Select(a => new AksiyonOnerisi(a.Kod, a.Ad, ad))
            .ToList();
    }

    // ---------------------------------------------------------------- log --
    private static async Task<long?> LogAsync(
        NpgsqlConnection baglanti, IstekBaglami baglam, string soru, short kaynak,
        string konuKod, decimal guven, Istek? istek, Stopwatch kronometre,
        CancellationToken iptal, string model = "", int girisJeton = 0,
        int cikisJeton = 0, decimal kontor = 0m)
    {
        // Cevapsız soru = eksik rehber konusu. Günlük olmadan "asistan işe
        //   yaramıyor" geri bildirimi ölçülemez. Model cevabında jeton da
        //   yazılır: kontör fiyatı ancak gerçek tüketimle ölçülür.
        var satir = await baglanti.TekAsync("""
            insert into public.ai_rehber_log
                   (kullanici_id, sube_id, soru, kaynak, konu_kod, guven,
                    aktif_mod, aktif_sayfa, sure_ms, model, giris_jeton, cikis_jeton,
                    kontor)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12)
            returning id
            """, null,
            [baglam.KullaniciId, baglam.SubeId, soru, kaynak, konuKod, guven,
             (short)(istek?.AktifMod ?? 0), istek?.AktifSayfa ?? "",
             (int)kronometre.ElapsedMilliseconds, model, girisJeton, cikisJeton, kontor],
            OkuyucuGenisletmeleri.Sozluk, iptal);
        return satir is null ? null : Convert.ToInt64(satir["id"]);
    }
}

using System.Diagnostics;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler.Yardim;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// AI REHBER / BAĞLAMSAL YARDIM (447 · 871) — "ne nerede, nasıl yapılır" ve
/// "bu ekranda ne yapabilirim" sorularını cevaplar.
///
/// <b>Asistan operatör değil REHBERDİR.</b> Bu servis hiçbir iş verisine
/// yazmaz; yalnız katalog ve yardım belgesi okur, metin üretir. Kayıt açma,
/// değiştirme, silme, onaylama yoktur - kullanıcıyı doğru ekrana ve doğru
/// sıraya yönlendirir.
///
/// <b>Bağlam serbest metin DB erişimi DEĞİL, sunucunun doğruladığı metadata:</b>
/// istemcinin gönderdiği ekran ipucu (rota, kaynak, kayıt no, sekme, hata
/// kodu, dil) <see cref="EkranBaglamiCozucu"/> ile ekran kataloğu, kaynak /
/// kart / aksiyon katalogları ve kullanıcının çözülmüş yetkileriyle
/// doğrulanır; uymayan parça atılır. Kayıt İÇERİĞİ hiçbir katmana girmez.
///
/// <b>Kaynak önceliği:</b> doğrulanmış ekran bağlamı → yetkili ekran listesi →
/// yardım belgeleri (<see cref="YardimDizini"/>) → rehber konuları → model.
/// Model yalnız katalogun cevaplayamadığı yerde ve yalnız bu kaynaklarla
/// çalışır; tıbbi karar sorusu modele hiç gitmez.
///
/// <b>Yetki sunucuda:</b> öneri listesi kullanıcının GÖREBİLECEĞİ ekranlara
/// süzülür. Yetkisi olmayan bir işlem sorulduğunda adımlar verilmez; "şu
/// yetki gerekiyor" denir. "Yetki yok" ile "bulunamadı" ayrı cevaplardır.
///
/// <b>Gizlilik:</b> soru günlüğe ve sağlayıcıya <see cref="PiiMaske"/>'den
/// geçerek gider; sohbet geçmişi modele hiç verilmez (her soru bağımsızdır -
/// eski izinle görülen bir şey yeni soruya taşınamaz).
///
/// <b>Kontör:</b> katalog/belge cevabı ücretsizdir. Model çağrısı başına
/// `ai_kontor.cagri_ucreti` düşülür; bakiye yoksa asistan kapanmaz.
/// </summary>
public sealed class RehberServisi(VeriKaynagi veri, RehberModeli? model = null,
                                  YardimDizini? dizin = null)
{
    /// <summary>
    /// Panelden gelen istek. `baglam` (871) sunucuda doğrulanan ekran ipucu;
    /// `aktifSayfa` eski istemciler için geriye uyumlu rota ipucudur.
    /// </summary>
    public sealed record Istek(string KullaniciMesaji, short? AktifMod, string? AktifSayfa,
                               string? SeciliKaynak, IstemciBaglami? Baglam = null);

    public sealed record EkranOnerisi(string Kaynak, string Ad, string Rota, string Yol,
                                      string MenuGrup);
    public sealed record AksiyonOnerisi(string Kod, string Ad, string Ekran);
    public sealed record Adim(int No, string Metin, string? Ekran, string? Rota,
                              string? Aksiyon = null);
    /// <summary>Cevabın dayandığı yardım belgesi parçası (panel "kaynak" satırı).</summary>
    public sealed record KaynakAtfi(string Id, string Baslik, string Belge);
    /// <summary>Doğrulanmış ekran bağlamının panele dönen özeti - içerik yok.</summary>
    public sealed record EkranOzeti(bool Bulundu, bool Yetkili, string Kaynak, string Rota,
                                    string Baslik, string Yol, string? Sekme, bool KayitVar,
                                    string? HataKodu);

    public sealed record Yanit(
        string Cevap,
        IReadOnlyList<Adim> Adimlar,
        IReadOnlyList<EkranOnerisi> OnerilenEkranlar,
        IReadOnlyList<AksiyonOnerisi> OnerilenAksiyonlar,
        decimal GuvenSkoru,
        string? EksikBilgiSorusu,
        IReadOnlyList<string> Uyarilar,
        string KonuKod,
        /// <summary>1 katalog · 2 ekran · 3 bağlamsal · 5 model · 6 rol · 7 kapsam dışı · 8 yardım belgesi · 0 yok.</summary>
        short KaynakTuru,
        decimal KontorBakiye,
        bool ModelKullanildi = false,
        string Model = "",
        EkranOzeti? Ekran = null,
        IReadOnlyList<KaynakAtfi>? Kaynaklar = null,
        string Dil = "tr");

    public const short KaynakKatalog = 1, KaynakEkran = 2, KaynakBaglamsal = 3,
                       KaynakModel = 5, KaynakRol = 6, KaynakKapsamDisi = 7, KaynakBelge = 8;

    /// <summary>
    /// EKRAN BAĞLAMI UCU (871): panel açılınca / rota değişince çağrılır -
    /// "şu ekran hakkında soruyorsunuz" satırı ve önerilen sorular. Cevap
    /// üretmez, kontör harcamaz, günlüğe yazmaz.
    /// </summary>
    public async Task<(EkranOzeti Ekran, IReadOnlyList<string> OnerilenSorular,
                       IReadOnlyList<AksiyonOnerisi> Aksiyonlar)>
        EkranBaglamiAsync(IstemciBaglami istemci, IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await veri.AcAsync(iptal);
        var urunModu = await UrunModuAsync(baglanti, baglam, iptal);
        var ekran = await EkranBaglamiCozucu.CozAsync(baglanti, istemci, baglam, urunModu, iptal);
        var sorular = new List<string>();
        if (ekran is { Bulundu: true, Yetkili: true })
        {
            sorular.Add("Bu ekranda ne yapabilirim?");
            if (dizin is not null)
                sorular.AddRange(dizin.OnerilenSorular(ekran, baglam, urunModu, ekran.Dil, 4));
            if (ekran.KayitId is > 0 && ekran.Alanlar.Count > 0) sorular.Add("Bu kartta hangi alanlar zorunlu?");
            if (ekran.HataKodu is { Length: > 0 }) sorular.Insert(0, "Bu hata ne demek?");
        }
        else if (ekran.Bulundu) sorular.Add("Bu ekran için hangi yetki gerekiyor?");
        else sorular.Add("Yeni hasta kaydı nasıl açılır?");
        sorular.Add("Rolüm ne yapabilir?");
        return (Ozet(ekran), sorular.Distinct().Take(6).ToList(),
                ekran.Aksiyonlar.Select(a => new AksiyonOnerisi(a.Kod, a.Ad, a.Ekran)).ToList());
    }

    private static EkranOzeti Ozet(DogrulanmisBaglam e) =>
        new(e.Bulundu, e.Yetkili, e.Kaynak, e.Rota, e.Baslik, e.Yol, e.Sekme, e.KayitId is > 0,
            e.HataKodu);

    private static async Task<short> UrunModuAsync(NpgsqlConnection baglanti, IstekBaglami baglam,
                                                   CancellationToken iptal) =>
        // ÜRÜN MODU sunucudan: istemcinin gönderdiği `aktifMod` yalnız ipucu.
        //   Mod ŞUBENİN PROFİLİNDEN gelir (489).
        (short)await baglanti.TekDegerAsync<short>(
            "select public.fn_urun_modu(@p0)", null, [baglam.SubeId ?? 0], iptal);

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
        var urunModu = await UrunModuAsync(baglanti, baglam, iptal);

        // EKRAN BAĞLAMI (871): istemcinin ipucu sunucuda doğrulanır. Eski
        //   istemci yalnız aktifSayfa gönderir; o da aynı yoldan geçer.
        var istemciBaglami = istek.Baglam ?? new IstemciBaglami(Rota: istek.AktifSayfa);
        var ekran = await EkranBaglamiCozucu.CozAsync(baglanti, istemciBaglami, baglam, urunModu, iptal);
        var dil = ekran.Dil;
        var enjeksiyon = RehberMetin.EnjeksiyonMu(soru);

        var uyarilar = new List<string>();
        var kontorBakiye = await baglanti.TekDegerAsync<decimal>(
            "select bakiye from public.ai_kontor where id = 1", null, [], iptal);

        // ------------------------------------------------- klinik kapsam dışı
        // Tanı / tedavi / doz / sonuç yorumu sorusu MODELE HİÇ GİTMEZ: asistan
        //   HBYS'nin işleyişini anlatır, tıbbi karar vermez. Sabit cevap,
        //   günlükte kaynak 7.
        if (RehberMetin.KlinikSoruMu(soru))
        {
            await LogAsync(baglanti, baglam, soru, KaynakKapsamDisi, "klinik", 1m, istek, ekran,
                           kronometre, iptal, enjeksiyon: enjeksiyon);
            return new Yanit(
                "Bu asistan HBYS'nin işleyişini anlatır; tanı, tedavi, ilaç seçimi, doz ya da "
                + "sonuç yorumu gibi tıbbi konularda yardımcı olamam - bunlar için hekime "
                + "danışın. Ekranın nasıl kullanıldığını (istem açma, sonuç görüntüleme, "
                + "reçete kaydı) sorabilirsiniz.",
                [], [], [], 1m, null, uyarilar, "klinik", KaynakKapsamDisi, kontorBakiye,
                Ekran: Ozet(ekran), Dil: dil);
        }

        // ---------------------------------------------------- hata açıklaması
        // Ekranda görülen hata kodu bağlamda ve soru "bu ne demek" ise cevap
        //   sabit açıklamadır (kod → ne oldu → ne yapılır); model gerekmez.
        if (ekran.HataKodu is { Length: > 0 } hk && RehberMetin.HataSorusuMu(soru)
            && HataAciklamalari.Bul(hk) is { } aciklama)
        {
            await LogAsync(baglanti, baglam, soru, KaynakBaglamsal, "hata:" + hk, 0.9m, istek, ekran,
                           kronometre, iptal, enjeksiyon: enjeksiyon);
            var adimlar = new List<Adim>
            {
                new(1, aciklama.Ne, null, null),
                new(2, aciklama.NeYapilir, null, null),
            };
            if (hk == HataKodu.Yasak)
                adimlar.Add(new Adim(3, "Bu asistan yetkiniz olmayan işlemin adımlarını anlatmaz; yetkiyi yöneticiniz verir.", null, null));
            return new Yanit($"**{aciklama.Kod} — {aciklama.Baslik}**"
                             + (ekran.Bulundu ? $" ({ekran.Yol} ekranında)" : ""),
                             adimlar, [], [], 0.9m, null, uyarilar, "hata:" + hk, KaynakBaglamsal,
                             kontorBakiye, Ekran: Ozet(ekran), Dil: dil);
        }

        // "Bu hata ne demek" ama bağlamda hata kodu yok: uydurma açıklama yerine
        //   ne gerektiğini söyle (ekran hatayı gösterdiyse kod izde olurdu).
        if (ekran.HataKodu is null && RehberMetin.HataSorusuMu(soru)
            && RehberMetin.Sadelestir(soru) is var sadeHata
            && (sadeHata.Contains("bu hata", StringComparison.Ordinal)
                || sadeHata.Contains("su hata", StringComparison.Ordinal)
                || sadeHata.Contains("hata ne demek", StringComparison.Ordinal)))
        {
            await LogAsync(baglanti, baglam, soru, KaynakBaglamsal, "hata:yok", 0.6m, istek, ekran,
                           kronometre, iptal, enjeksiyon: enjeksiyon);
            return new Yanit(
                "Bu ekranda az önce gösterilmiş bir hata kodu görmedim; o yüzden hangi hatayı "
                + "sorduğunuzu bilemiyorum. Hata kutusundaki kodu ya da mesajı olduğu gibi yazarsanız "
                + "(örneğin \"YASAK\" ya da \"iş kuralı: ...\") ne anlama geldiğini ve ne yapılacağını anlatırım.",
                [], [], [], 0.6m, "Hatanın kodu ya da mesajı neydi?", uyarilar, "hata:yok",
                KaynakBaglamsal, kontorBakiye, Ekran: Ozet(ekran), Dil: dil);
        }

        // ------------------------------------------------------ rol sorusu
        if (RehberMetin.RolSorusuMu(soru))
        {
            var rolYaniti = await RolYanitiAsync(baglanti, soru, urunModu, baglam, uyarilar,
                                                 kontorBakiye, istek, ekran, kronometre, iptal);
            if (rolYaniti is not null) return rolYaniti with { Ekran = Ozet(ekran), Dil = dil };
        }

        // ------------------------------------------------- bağlamsal yardım
        if (RehberMetin.BaglamsalMi(soru) && ekran.Bulundu)
        {
            var yardim = await BaglamsalYardimAsync(baglanti, istek, soru, urunModu, baglam,
                                                    ekran, uyarilar, kontorBakiye, kronometre, iptal);
            if (yardim is not null) return yardim;
        }

        // ---------------------------------------------------------- konular
        var konular = kelimeler.Length == 0 ? new List<IDictionary<string, object?>>()
            : await baglanti.ListeAsync("""
                select k.kod, k.baslik, k.urun_modu as "urunModu", k.modul,
                       k.ekran_kaynak as "ekranKaynak", k.yetki_kodu as "yetkiKodu",
                       k.adimlar, k.uyarilar,
                       (select count(*) from unnest(@p1::text[]) w
                         where ' ' || public.fn_ara_metin(k.anahtar || ' ' || k.baslik)
                               like '% ' || w || '%') as vurus,
                       similarity(public.fn_ara_metin(k.anahtar),
                                  public.fn_ara_metin(@p0)) as benzerlik
                  from public.ai_rehber_konu k
                 where k.durum = 0 and (k.urun_modu <> 2 or @p2 in (2, 3))
                 order by vurus desc, benzerlik desc, k.sira
                 limit 4
                """, null, [soru, kelimeler, urunModu], OkuyucuGenisletmeleri.Sozluk, iptal);

        var enIyi = konular.FirstOrDefault();
        var vurus = enIyi is null ? 0 : Convert.ToInt32(enIyi["vurus"]);
        var benzerlik = enIyi is null ? 0f : Convert.ToSingle(enIyi["benzerlik"]);
        var oran = kelimeler.Length == 0 ? 0m : (decimal)vurus / kelimeler.Length;
        var guven = Math.Round(Math.Min(1m, oran * 0.7m + (decimal)benzerlik * 1.5m), 2);

        if (enIyi is not null && vurus >= 1 && guven >= 0.30m)
        {
            var k = await KonuYanitiAsync(baglanti, enIyi, konular, soru, guven, urunModu, baglam,
                                          uyarilar, kontorBakiye, istek, ekran, kronometre, iptal);
            return k with { Ekran = Ozet(ekran), Dil = dil };
        }

        // ------------------------------------------------- yardım belgeleri
        var vuruslar = dizin?.Ara(soru, ekran, baglam, urunModu, dil, 4) ?? [];

        // --------------------------------------------------------- model
        var modelEkranlari = await EkranAraAsync(baglanti, soru, kelimeler, urunModu, baglam, 12, iptal);
        if (ekran is { Bulundu: true, Yetkili: true } && modelEkranlari.All(e => e.Rota != ekran.Rota))
            modelEkranlari.Insert(0, new EkranOnerisi(ekran.Kaynak, ekran.Baslik, ekran.Rota,
                                                      ekran.Yol, ekran.MenuGrup));
        var modelYaniti = await ModelDeneAsync(baglanti, istek, soru, urunModu, konular,
                                               modelEkranlari, vuruslar, ekran, enjeksiyon, baglam,
                                               uyarilar, kronometre, iptal);
        if (modelYaniti is not null) return modelYaniti;

        // ------------------------------------ yardım belgesi (modelsiz cevap)
        if (vuruslar.Count > 0 && vuruslar[0].Puan >= 3)
        {
            var belgeYaniti = await BelgeYanitiAsync(baglanti, vuruslar, soru, urunModu, baglam,
                                                     uyarilar, kontorBakiye, istek, ekran,
                                                     kronometre, iptal, enjeksiyon);
            return belgeYaniti;
        }

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
            await LogAsync(baglanti, baglam, soru, KaynakEkran, "", 0.35m, istek, ekran, kronometre,
                           iptal, enjeksiyon: enjeksiyon);
            return new Yanit(cevap, [], ekranlar, Aksiyonlar(null, e.Kaynak, baglam), 0.35m,
                             "Hangi işlemi yapmak istiyorsunuz: kayıt açma, listeleme "
                             + "yoksa belge gönderme?",
                             uyarilar, "", KaynakEkran, kontorBakiye, Ekran: Ozet(ekran), Dil: dil);
        }

        // --------------------------------------------------- cevap yok
        await LogAsync(baglanti, baglam, soru, 0, "", 0m, istek, ekran, kronometre, iptal,
                       enjeksiyon: enjeksiyon);
        var ekranNotu = !ekran.Bulundu && istemciBaglami.Rota is { Length: > 1 }
            ? " Bulunduğunuz ekranı tanıyamadım; bu ekran için yardım belgesi henüz yazılmamış olabilir."
            : "";
        return new Yanit(
            "Bu soruya dayanak olacak bir rehber konusu ya da yardım belgesi bulamadım; "
            + "uydurmak yerine söyleyeyim: elimdeki bilgi yetmiyor." + ekranNotu
            + " Sorunuzu işin adıyla yazarsanız (örneğin \"hasta kaydı\", \"satış faturası\", "
            + "\"numune kabul\") adımları çıkarabilirim.",
            [], [], [], 0m,
            "Hangi modülde çalışıyorsunuz: hasta/randevu (HBYS) mu, fatura/stok (ERP) mü?",
            uyarilar, "", 0, kontorBakiye, Ekran: Ozet(ekran), Dil: dil);
    }

    // ---------------------------------------------------------------- model --
    /// <summary>
    /// Katalog cevaplayamadığında modeli dener. Kapılar sırayla: model hazır
    /// mı, kontör var mı, çıktı geçerli mi (beyaz liste / aksiyon / kaynak
    /// atfı). Herhangi biri tutmazsa <c>null</c> döner ve katalog akışı devam
    /// eder. Modele giden bağlam: doğrulanmış ekran + yetkili ekranlar +
    /// yardım parçaları + konu özetleri; soru maskeden geçer.
    /// </summary>
    private async Task<Yanit?> ModelDeneAsync(
        NpgsqlConnection baglanti, Istek istek, string soru, short urunModu,
        List<IDictionary<string, object?>> konular, List<EkranOnerisi> ekranlar,
        IReadOnlyList<YardimDizini.Vurus> vuruslar, DogrulanmisBaglam ekran, bool enjeksiyon,
        IstekBaglami baglam, List<string> uyarilar, Stopwatch kronometre, CancellationToken iptal)
    {
        if (model is null || !model.Hazir) return null;
        if (ekranlar.Count == 0 && vuruslar.Count == 0) return null;   // dayanak yok

        var (izin, ucret, sebep) = await KontorDurumAsync(baglanti, iptal);
        if (!izin)
        {
            if (sebep.Length > 0) uyarilar.Add(sebep);
            return null;
        }

        var konuOzetleri = konular
            .Where(k => YetkiVar(k["yetkiKodu"]?.ToString(), baglam))
            .Take(3)
            .Select(k => new RehberModeli.KonuOzeti(
                k["baslik"]?.ToString() ?? "", AdimOzeti(k["adimlar"]?.ToString())))
            .ToList();

        var kaynaklar = vuruslar
            .Select((v, i) => new RehberModeli.Kaynak("K" + (i + 1), v.Parca.Id,
                                                     v.Belge.Baslik + " › " + v.Parca.Baslik,
                                                     v.Parca.Metin))
            .ToList();

        var cikti = await model.DeneAsync(new RehberModeli.Girdi(
            soru, urunModu, istek.AktifSayfa,
            ekranlar.Select(e => new RehberModeli.Ekran(e.Kaynak, e.Rota, e.Yol)).ToList(),
            konuOzetleri, ekran, kaynaklar, ekran.Dil, enjeksiyon), iptal);
        if (cikti is null) return null;

        var jeton = cikti.GirisJeton + cikti.CikisJeton;
        var atiflar = cikti.Kaynaklar
            .Select(kim => kaynaklar.First(k => k.Kimlik == kim))
            .Select(k => new KaynakAtfi(k.BelgeId, k.Baslik, k.BelgeId.Split('#')[0]))
            .ToList();

        if (cikti.KapsamDisi)
        {
            var logK = await LogAsync(baglanti, baglam, soru, KaynakKapsamDisi, "model:kapsam-disi",
                                      cikti.Guven, istek, ekran, kronometre, iptal, cikti.Model,
                                      cikti.GirisJeton, cikti.CikisJeton, ucret, enjeksiyon: enjeksiyon);
            await KontorDusAsync(baglanti, baglam, ucret, jeton, logK, cikti.Model, iptal);
            return new Yanit(
                "Bu konu asistanın kapsamı dışında (tıbbi karar ya da sistem dışı bir istek). "
                + "Ekranın nasıl kullanıldığını sorabilirsiniz.",
                [], [], [], 1m, null, uyarilar, "kapsam-disi", KaynakKapsamDisi,
                await BakiyeAsync(baglanti, iptal), true, cikti.Model, Ozet(ekran), [], ekran.Dil);
        }

        var adimlar = cikti.Adimlar
            .Select((a, i) => new Adim(i + 1, a.Metin,
                                       ekranlar.FirstOrDefault(e => e.Rota == a.Ekran)?.Kaynak,
                                       a.Ekran, a.Aksiyon))
            .ToList();

        var oneriler = adimlar.Where(a => a.Rota is not null)
            .Select(a => ekranlar.First(e => e.Rota == a.Rota))
            .DistinctBy(e => e.Rota).ToList();
        if (oneriler.Count == 0) oneriler = ekranlar.Take(3).ToList();

        var logId = await LogAsync(baglanti, baglam, soru, KaynakModel, "model", cikti.Guven, istek,
                                   ekran, kronometre, iptal, cikti.Model, cikti.GirisJeton,
                                   cikti.CikisJeton, ucret,
                                   string.Join(",", atiflar.Select(a => a.Id)), enjeksiyon);
        // KONTÖR ÇAĞRI BAŞARILI OLUNCA DÜŞÜLÜR.
        await KontorDusAsync(baglanti, baglam, ucret, jeton, logId, cikti.Model, iptal);

        var aksiyonKaynagi = ekran is { Bulundu: true, Yetkili: true } ? ekran.Kaynak
                             : oneriler.FirstOrDefault()?.Kaynak ?? "";
        var aksiyonEkrani = ekran is { Bulundu: true, Yetkili: true } ? ekran.AksiyonEkrani : null;
        return new Yanit(cikti.Cevap, adimlar, oneriler,
                         Aksiyonlar(aksiyonEkrani, aksiyonKaynagi, baglam),
                         cikti.Guven, cikti.EksikBilgiSorusu, uyarilar, "model", KaynakModel,
                         await BakiyeAsync(baglanti, iptal), true, cikti.Model, Ozet(ekran),
                         atiflar, ekran.Dil);
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

    // ------------------------------------------------- yardım belgesi ----
    /// <summary>
    /// Model yokken yardım belgesinden doğrudan cevap: en iyi parçanın metni
    /// (kırpılmış), belgenin ekranı yetkiliyse düğmesi, atıf satırı. Belge
    /// kurumun onaylı metnidir; ücretsiz ve denetlenebilir.
    /// </summary>
    private async Task<Yanit> BelgeYanitiAsync(
        NpgsqlConnection baglanti, IReadOnlyList<YardimDizini.Vurus> vuruslar, string soru,
        short urunModu, IstekBaglami baglam, List<string> uyarilar, decimal kontorBakiye,
        Istek istek, DogrulanmisBaglam ekran, Stopwatch kronometre, CancellationToken iptal,
        bool enjeksiyon)
    {
        var v = vuruslar[0];
        var metin = v.Parca.Metin.Length > 900 ? v.Parca.Metin[..900] + "…" : v.Parca.Metin;
        var oneriler = new List<EkranOnerisi>();
        var kaynakKodu = v.Belge.Ekran.Length > 0 ? v.Belge.Ekran : v.Belge.Rota;
        if (kaynakKodu.Length > 0)
        {
            var bilgi = await EkranBilgisiAsync(baglanti, kaynakKodu, urunModu, baglam, iptal);
            if (bilgi is not null) oneriler.Add(bilgi);
        }
        var atiflar = vuruslar.Take(2)
            .Select(x => new KaynakAtfi(x.Parca.Id, x.Belge.Baslik + " › " + x.Parca.Baslik, x.Belge.Id))
            .ToList();
        var guven = Math.Min(0.85m, 0.4m + v.Puan * 0.08m);
        if (v.Belge.Dogrulama != "kod-incelemesi")
            uyarilar.Add("Bu yardım belgesi henüz insan doğrulamasından geçmedi; ekranda görünenle çelişirse ekran doğrudur.");

        await LogAsync(baglanti, baglam, soru, KaynakBelge, "belge:" + v.Belge.Id, guven, istek, ekran,
                       kronometre, iptal, kaynaklar: string.Join(",", atiflar.Select(a => a.Id)),
                       enjeksiyon: enjeksiyon);
        return new Yanit($"**{v.Belge.Baslik} › {v.Parca.Baslik}**\n\n{metin}", [], oneriler,
                         Aksiyonlar(null, oneriler.FirstOrDefault()?.Kaynak ?? "", baglam), guven,
                         null, uyarilar, "belge:" + v.Belge.Id, KaynakBelge, kontorBakiye,
                         Ekran: Ozet(ekran), Kaynaklar: atiflar, Dil: ekran.Dil);
    }

    // ------------------------------------------------------------- kontör --
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
                    "AI kontörü bitti; cevaplar şimdilik katalog ve yardım belgelerinden üretiliyor "
                    + "(kontör yüklemesi yönetici işi).");

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

    // -------------------------------------------------------- rol tanımı ---
    /// <summary>
    /// "Şu rol ne yapabilir?" sorusunu ROL TANIMINDAN cevaplar. Kendi rolünü
    /// herkes sorabilir; BAŞKA bir rolün dökümü `rol` yetkisi ister.
    /// Düğmeler soran kişinin kendi yetkisine göre çizilir.
    /// </summary>
    private async Task<Yanit?> RolYanitiAsync(
        NpgsqlConnection baglanti, string soru, short urunModu, IstekBaglami baglam,
        List<string> uyarilar, decimal kontorBakiye, Istek istek, DogrulanmisBaglam ekran,
        Stopwatch kronometre, CancellationToken iptal)
    {
        var kelimeler = RehberMetin.RolAramaKelimeleri(soru);
        var kendi = RehberMetin.KendiRoluMu(soru) && baglam.RolId > 0;
        if (kelimeler.Length == 0 && !kendi) return null;

        var adaylar = await baglanti.ListeAsync("""
            select r.id, r.kod, r.ad, r.amac, r.aktif, r.sistem,
                   (select count(*) from public.taraf_kullanici k
                     where k.rol_id = r.id and k.aktif = 1) as kisi,
                   (select count(*) from unnest(@p1::text[]) w
                     where ' ' || public.fn_ara_metin(r.ad || ' ' || r.kod)
                           like '% ' || w || '%') as vurus,
                   similarity(public.fn_ara_metin(r.ad), public.fn_ara_metin(@p0)) as benzerlik
              from public.rol r
             where @p2 = 0 or r.id = @p2
             order by vurus desc, benzerlik desc, r.ad
             limit 3
            """, null, [soru, kelimeler, kendi ? baglam.RolId : 0],
            OkuyucuGenisletmeleri.Sozluk, iptal);

        var rol = adaylar.FirstOrDefault();
        if (rol is null) return null;
        if (!kendi && Convert.ToInt32(rol["vurus"]) < 1) return null;

        var rolId = Convert.ToInt32(rol["id"]);
        var rolAd = rol["ad"]?.ToString() ?? "";

        if (rolId != baglam.RolId && !baglam.Yetkiler.Var("rol", Islem.Gor))
        {
            await LogAsync(baglanti, baglam, soru, KaynakRol, "rol:yetkisiz", 0.5m, istek, ekran,
                           kronometre, iptal);
            return new Yanit(
                $"**{rolAd}** rolünün yetki dökümünü paylaşamıyorum: başka bir rolün "
                + "neye erişebildiği kurumun yetki haritasıdır ve bunun için `rol` "
                + "yetkisi gerekiyor. Kendi rolünüzü sorabilirsiniz: "
                + "\"rolüm ne yapabilir\".",
                [], [], [], 0.5m, null, uyarilar, "rol", KaynakRol, kontorBakiye);
        }

        var satirlar = await baglanti.ListeAsync("""
            select y.kod, y.ad, y.grup, y.tur, y.deger_alir as "degerAlir",
                   ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger
              from public.rol_yetki ry
              join public.yetki y on y.id = ry.yetki_id
             where ry.rol_id = @p0 and y.aktif = 1
               and (y.urun_modu <> 2 or @p1 in (2, 3))
               and (ry.gor = 1 or ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1)
             order by y.tur, (ry.ekle + ry.degistir) desc, y.grup, y.sira, y.ad
            """, null, [rolId, urunModu], OkuyucuGenisletmeleri.Sozluk, iptal);

        var sistem = Convert.ToInt16(rol["sistem"]) == 1;
        var aktif = Convert.ToInt16(rol["aktif"]) == 1;
        var kisi = Convert.ToInt64(rol["kisi"]);
        var amac = rol["amac"]?.ToString() ?? "";

        var baslik = $"**{rolAd}** — " + (sistem ? "sistem rolü · " : "")
                   + (aktif ? "" : "PASİF · ")
                   + (kisi == 0 ? "kullanıcısı yok" : $"{kisi} kullanıcı");
        if (amac.Length > 0) baslik += ". " + amac;
        if (!aktif)
            uyarilar.Add("Bu rol pasif: yeni kullanıcıya atanamaz "
                       + "(Yönetim › Roller ekranından aktif edilebilir).");

        if (satirlar.Count == 0)
        {
            await LogAsync(baglanti, baglam, soru, KaynakRol, "rol:" + rol["kod"], 0.8m, istek, ekran,
                           kronometre, iptal);
            return new Yanit(
                baslik + " Bu rolde tanımlı hiçbir yetki yok: rolü taşıyan kullanıcı "
                + "hiçbir ekranı açamaz.",
                [], [], [], 0.8m, null, uyarilar, "rol:" + rol["kod"], KaynakRol, kontorBakiye);
        }

        static bool Bayrak(IDictionary<string, object?> s, string alan) =>
            Convert.ToInt16(s[alan]) == 1;
        static string Ad(IDictionary<string, object?> s) => s["ad"]?.ToString() ?? "";

        var ekranlar = satirlar.Where(s => Convert.ToInt16(s["tur"]) == 0).ToList();
        var yazabildigi = ekranlar.Where(s => Bayrak(s, "ekle") || Bayrak(s, "degistir"))
                                  .Select(Ad).ToList();
        var saltOkur = ekranlar.Where(s => Bayrak(s, "gor") && !Bayrak(s, "ekle")
                                        && !Bayrak(s, "degistir") && !Bayrak(s, "sil"))
                               .Select(Ad).ToList();
        var silebildigi = ekranlar.Where(s => Bayrak(s, "sil")).Select(Ad).ToList();
        var islemler = satirlar.Where(s => Convert.ToInt16(s["tur"]) == 1
                                        && Convert.ToInt16(s["degerAlir"]) == 0)
                               .Select(Ad).ToList();
        var sinirlar = satirlar
            .Where(s => Convert.ToInt16(s["degerAlir"]) == 1
                     && (s["deger"]?.ToString() ?? "").Trim() is { Length: > 0 } d
                     && d != "0")
            .Select(s => Ad(s) + ": " + s["deger"])
            .ToList();

        var adimlar = new List<Adim>();
        void Bolum(string etiket, IReadOnlyList<string> liste, int azami = 10)
        {
            if (liste.Count == 0) return;
            var metin = string.Join(" · ", liste.Take(azami));
            if (liste.Count > azami) metin += $" (+{liste.Count - azami})";
            adimlar.Add(new Adim(adimlar.Count + 1,
                                 $"{etiket} ({liste.Count}): {metin}", null, null));
        }

        Bolum("Açabildiği ekranlar", ekranlar.Select(Ad).ToList(), 12);
        Bolum("Kayıt açıp değiştirebildiği", yazabildigi);
        Bolum("Silebildiği", silebildigi, 6);
        Bolum("Yalnız görebildiği (salt okuma)", saltOkur, 8);
        Bolum("İşlem yetkileri", islemler, 10);
        if (sinirlar.Count > 0)
            adimlar.Add(new Adim(adimlar.Count + 1,
                                 "Sınırlar — " + string.Join(" · ", sinirlar), null, null));

        var oneriler = (await baglanti.ListeAsync("""
            select e.kaynak, e.baslik, e.rota, e.yol, e.menu_grup as "menuGrup",
                   e.yetki_kodu as "yetkiKodu"
              from public.ai_rehber_ekran e
              join public.yetki y on y.kod = e.yetki_kodu
              join public.rol_yetki ry on ry.yetki_id = y.id and ry.rol_id = @p0
             where e.durum = 0 and e.menu_gizli = 0 and ry.gor = 1
               and (e.urun_modu <> 2 or @p1 in (2, 3))
             order by (ry.ekle + ry.degistir) desc, y.sira, e.baslik
             limit 30
            """, null, [rolId, urunModu], OkuyucuGenisletmeleri.Sozluk, iptal))
            .Where(s => YetkiVar(s["yetkiKodu"]?.ToString(), baglam))
            .Select(s => new EkranOnerisi(
                s["kaynak"]?.ToString() ?? "", s["baslik"]?.ToString() ?? "",
                s["rota"]?.ToString() ?? "", s["yol"]?.ToString() ?? "",
                s["menuGrup"]?.ToString() ?? ""))
            .DistinctBy(e => e.Rota)
            .Take(5)
            .ToList();

        var ikinci = adaylar.Skip(1)
            .Where(a => Convert.ToInt32(a["vurus"]) >= Convert.ToInt32(rol["vurus"]))
            .Select(a => a["ad"]?.ToString() ?? "").ToList();

        await LogAsync(baglanti, baglam, soru, KaynakRol, "rol:" + rol["kod"], 0.85m, istek, ekran,
                       kronometre, iptal);
        return new Yanit(
            baslik, adimlar, oneriler, [], 0.85m,
            ikinci.Count > 0
                ? "Şunu mu kastettiniz: " + string.Join(" / ", ikinci) + "?"
                : null,
            uyarilar, "rol:" + rol["kod"], KaynakRol, kontorBakiye);
    }

    // -------------------------------------------------- bağlamsal yardım ---
    /// <summary>
    /// Aktif ekranın kendisini anlatır: ne işe yarar, hangi düğmeler açık
    /// (yetkiliyse), sekmeleri, o ekranla ilgili rehber konuları ve yardım
    /// belgeleri. Alan sorusuysa kolon/alan metadata'sından cevaplar.
    /// Ekran bulunmuş ama YETKİSİZSE içerik anlatılmaz; "yetki gerekiyor"
    /// denir - bulunamayan ekrandan ayrı bir cevaptır.
    /// </summary>
    private async Task<Yanit?> BaglamsalYardimAsync(
        NpgsqlConnection baglanti, Istek istek, string soru, short urunModu,
        IstekBaglami baglam, DogrulanmisBaglam ekran, List<string> uyarilar,
        decimal kontorBakiye, Stopwatch kronometre, CancellationToken iptal)
    {
        if (!ekran.Bulundu) return null;
        var kaynak = ekran.Kaynak;
        var ad = ekran.Baslik;
        var yol = ekran.Yol;

        if (!ekran.Yetkili)
        {
            await LogAsync(baglanti, baglam, soru, KaynakBaglamsal, "ekran:yetkisiz", 0.8m, istek,
                           ekran, kronometre, iptal);
            return new Yanit(
                $"**{yol}** ekranı için sizde görüntüleme yetkisi görünmüyor"
                + (ekran.YetkiKodu.Length > 0 ? $" (gereken yetki: `{ekran.YetkiKodu}`)" : "")
                + ". Bu ekranın içeriğini ve işlemlerini anlatamam; yetkiyi yöneticiniz "
                + "(Yönetim › Roller) verebilir.",
                [], [], [], 0.8m, null, uyarilar, "ekran:yetkisiz", KaynakBaglamsal, kontorBakiye,
                Ekran: Ozet(ekran), Dil: ekran.Dil);
        }

        // ------------------------------------------------------ alan sorusu
        if (RehberMetin.AlanSorusuMu(soru))
        {
            var kolon = KolonBul(kaynak, soru, baglam) ?? AlanBul(ekran, soru);
            if (kolon is not null)
            {
                var (kAd, kBaslik, kTip, kFiltre) = kolon.Value;
                var tipMetni = kTip switch
                {
                    "para" => "para tutarı", "sayi" => "sayı", "ondalik" => "sayı", "tarih" => "tarih",
                    "zaman" => "tarih-saat", "kod" => "kod listesinden gelen değer",
                    "mantik" => "evet/hayır", _ => "metin",
                };
                var yardim = await baglanti.TekDegerAsync<string>("""
                    select metin from public.help
                     where anahtar = @p0 or anahtar = @p1 limit 1
                    """, null, [kaynak + "." + kAd, "ayar." + kaynak + "." + kAd], iptal);

                await LogAsync(baglanti, baglam, soru, KaynakBaglamsal, "alan:" + kAd, 0.8m, istek,
                               ekran, kronometre, iptal);
                var metin = "**" + kBaslik + "** — " + ad + " ekranında bir " + tipMetni
                          + " alanı" + (kFiltre ? "; süzgeçte kullanılabilir." : ".");
                if (!string.IsNullOrWhiteSpace(yardim)) metin += " " + yardim;
                return new Yanit(metin, [], [], [], 0.8m, null, uyarilar, "", KaynakBaglamsal,
                                 kontorBakiye, Ekran: Ozet(ekran), Dil: ekran.Dil);
            }
        }

        // -------------------------------------------- "bu ekranda ne yapılır"
        var aksiyonlar = ekran.Aksiyonlar
            .Take(6).Select(a => new AksiyonOnerisi(a.Kod, a.Ad, a.Ekran)).ToList();
        var konular = await baglanti.ListeAsync("""
            select k.kod, k.baslik
              from public.ai_rehber_konu k
             where k.durum = 0 and (k.urun_modu <> 2 or @p1 in (2, 3))
               and (k.ekran_kaynak = @p0 or k.ekran_kaynak = @p2)
             order by k.sira limit 4
            """, null, [kaynak, urunModu, ekran.Rota], OkuyucuGenisletmeleri.Sozluk, iptal);

        var adimlar = new List<Adim>();
        var no = 0;
        foreach (var k in konular)
        {
            no++;
            adimlar.Add(new Adim(no, (k["baslik"]?.ToString() ?? "")
                                     + " — adımları görmek için bunu sorun.", null, null));
        }

        var atiflar = new List<KaynakAtfi>();
        var belgeler = dizin?.Belgeler.Where(b => YardimDizini.EkranUyar(b, ekran)
                                                 && (b.Yetki.Length == 0 || baglam.Yetkiler.Var(b.Yetki, Islem.Gor)))
                                       .Take(2).ToList() ?? [];
        foreach (var b in belgeler)
        {
            no++;
            var amac = b.Parcalar.FirstOrDefault(p => RehberMetin.Sadelestir(p.Baslik).StartsWith("amac", StringComparison.Ordinal));
            var ozet = b.Ozet.Length > 0 ? b.Ozet
                     : amac is null ? "" : (amac.Metin.Length > 240 ? amac.Metin[..240] + "…" : amac.Metin);
            adimlar.Add(new Adim(no, $"Yardım belgesi: {b.Baslik}" + (ozet.Length > 0 ? " — " + ozet : ""), null, null));
            atiflar.Add(new KaynakAtfi(b.Id, b.Baslik, b.Id));
        }

        var cevap = "**" + yol + "** ekranındasınız"
                  + (ekran.Sekme is { Length: > 0 } ? $" (sekme: {ekran.Sekme})" : "") + "."
                  + (ekran.Sekmeler.Count > 0 && ekran.KayitId is > 0
                     ? " Kartın sekmeleri: " + string.Join(" · ", ekran.Sekmeler) + "."
                     : "")
                  + (aksiyonlar.Count > 0
                     ? " Burada size açık olan işlemler: "
                       + string.Join(" · ", aksiyonlar.Select(a => a.Ad)) + "."
                     : " Bu ekranda size açık bir işlem düğmesi görünmüyor.");

        await LogAsync(baglanti, baglam, soru, KaynakBaglamsal, "ekran:" + kaynak, 0.8m, istek, ekran,
                       kronometre, iptal, kaynaklar: string.Join(",", atiflar.Select(a => a.Id)));
        return new Yanit(cevap, adimlar,
                         [new EkranOnerisi(kaynak, ad, ekran.Rota, yol, ekran.MenuGrup)],
                         aksiyonlar, 0.8m, null, uyarilar, "", KaynakBaglamsal, kontorBakiye,
                         Ekran: Ozet(ekran), Kaynaklar: atiflar, Dil: ekran.Dil);
    }

    /// <summary>Sorudaki kelimelere en çok uyan KOLONU bulur (alan yetkisi kapalıysa yok sayılır).</summary>
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
            if (!baglam.Yetkiler.AlanOkunur(kaynak, k.YetkiAlani ?? k.Ad)) continue;
            var puan = RehberMetin.KolonPuani(k.Baslik, k.Ad, kelimeler);
            if (puan <= enPuan) continue;
            enPuan = puan;
            enIyi = (k.Ad, k.Baslik, k.Tip, k.Filtrelenebilir);
        }
        return enPuan > 0 ? enIyi : null;
    }

    /// <summary>Kart ALANLARI arasında arar (bağlam zaten alan yetkisinden geçmiş).</summary>
    private static (string Ad, string Baslik, string Tip, bool Filtre)? AlanBul(
        DogrulanmisBaglam ekran, string soru)
    {
        var kelimeler = RehberMetin.AlanAramaKelimeleri(soru);
        if (kelimeler.Length == 0) return null;
        (string Ad, string Baslik, string Tip, bool Filtre)? enIyi = null;
        var enPuan = 0;
        foreach (var a in ekran.Alanlar)
        {
            var puan = RehberMetin.KolonPuani(a.Baslik, a.Ad, kelimeler);
            if (puan <= enPuan) continue;
            enPuan = puan;
            enIyi = (a.Ad, a.Baslik + (a.Zorunlu ? " (zorunlu)" : ""), a.Tip, false);
        }
        return enPuan > 0 ? enIyi : null;
    }

    // ------------------------------------------------------------- konu ----
    private async Task<Yanit> KonuYanitiAsync(
        NpgsqlConnection baglanti, IDictionary<string, object?> konu,
        List<IDictionary<string, object?>> hepsi, string soru, decimal guven,
        short urunModu, IstekBaglami baglam, List<string> uyarilar,
        decimal kontorBakiye, Istek istek, DogrulanmisBaglam ekran, Stopwatch kronometre,
        CancellationToken iptal)
    {
        var kod = konu["kod"]?.ToString() ?? "";
        var baslik = konu["baslik"]?.ToString() ?? "";
        var yetkiKodu = konu["yetkiKodu"]?.ToString() ?? "";
        var modul = konu["modul"]?.ToString() ?? "";

        if (yetkiKodu != "" && !baglam.Yetkiler.Var(yetkiKodu, Islem.Gor))
        {
            await LogAsync(baglanti, baglam, soru, KaynakKatalog, kod, guven, istek, ekran, kronometre, iptal);
            var yonetim = await EkranAraAsync(baglanti, "roller yetki", ["yetki", "rol"],
                                              urunModu, baglam, 2, iptal);
            return new Yanit(
                $"**{baslik}** için sizde yetki görünmüyor (gereken yetki: `{yetkiKodu}`). "
                + "Adımları paylaşamıyorum; yöneticinizden bu yetkiyi istemeniz gerekiyor.",
                [], yonetim, [], guven, null,
                [$"Gereken yetki: {yetkiKodu}"], kod, KaynakKatalog, kontorBakiye);
        }

        if (modul != "")
        {
            var acik = await baglanti.TekDegerAsync<bool>(
                "select public.fn_kurum_modul_acik(@p0, @p1)", null,
                [modul, baglam.SubeId], iptal);
            if (!acik)
                uyarilar.Add($"\"{modul}\" modülü bu kurulumda kapalı görünüyor; "
                           + "ekran menüde çıkmayabilir (Yönetim › Modül Ayarları).");
        }

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
                var ekranKodu = oge.TryGetProperty("ekran", out var ev) ? ev.GetString() : null;
                string? rota = null;
                if (!string.IsNullOrEmpty(ekranKodu))
                {
                    var bilgi = await EkranBilgisiAsync(baglanti, ekranKodu!, urunModu, baglam, iptal);
                    if (bilgi is not null) { rota = bilgi.Rota; ekranKodlari.Add(ekranKodu!); }
                }
                adimlar.Add(new Adim(oge.TryGetProperty("no", out var nv) && nv.TryGetInt32(out var n)
                                         ? n : no,
                                     metin, ekranKodu, rota));
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

        var cevap = $"**{baslik}** — {adimlar.Count} adım:";
        if (guven < 0.45m)
            cevap += " (tam emin değilim; başka bir şey kastettiyseniz sorunuzu açın)";

        var anaAksiyon = await baglanti.TekDegerAsync<string>(
            "select aksiyon_ekrani from public.ai_rehber_ekran "
            + " where (rota = @p0 or rota = '/' || @p0 or kaynak = @p0) "
            + "   and durum = 0 order by menu_gizli, id limit 1",
            null, [anaEkran], iptal);

        await LogAsync(baglanti, baglam, soru, KaynakKatalog, kod, guven, istek, ekran, kronometre, iptal);
        return new Yanit(cevap, adimlar, oneriler,
                         Aksiyonlar(anaAksiyon, anaEkran, baglam), guven,
                         guven < 0.45m ? "Aradığınız bu değilse hangi ekranda "
                                       + "çalıştığınızı yazın." : null,
                         uyarilar, kod, KaynakKatalog, kontorBakiye);
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

    /// <summary>Ekranın araç çubuğundaki, kullanıcının YETKİLİ olduğu aksiyonlar.</summary>
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
    /// <summary>
    /// Soru günlüğü. SORU MASKELİ yazılır (kimlik no, telefon, e-posta,
    /// IBAN, uzun numara) - günlük bir hasta listesine dönmesin. Ekran
    /// bağlamından yalnız kaynak kodu ve sekme adı yazılır; kayıt numarası
    /// yazılmaz.
    /// </summary>
    private static async Task<long?> LogAsync(
        NpgsqlConnection baglanti, IstekBaglami baglam, string soru, short kaynak,
        string konuKod, decimal guven, Istek? istek, DogrulanmisBaglam? ekran,
        Stopwatch kronometre, CancellationToken iptal, string model = "", int girisJeton = 0,
        int cikisJeton = 0, decimal kontor = 0m, string kaynaklar = "", bool enjeksiyon = false)
    {
        var maskeli = PiiMaske.Uygula(soru);
        var maskelendi = maskeli != soru;
        var kaynakNotu = kaynaklar;
        if (enjeksiyon) kaynakNotu = (kaynakNotu.Length > 0 ? kaynakNotu + "," : "") + "!enjeksiyon";
        if (kaynakNotu.Length > 400) kaynakNotu = kaynakNotu[..400];
        var satir = await baglanti.TekAsync("""
            insert into public.ai_rehber_log
                   (kullanici_id, sube_id, soru, kaynak, konu_kod, guven,
                    aktif_mod, aktif_sayfa, sure_ms, model, giris_jeton, cikis_jeton,
                    kontor, ekran_kaynak, sekme, dil, kaynaklar, pii_maske)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12,
                    @p13, @p14, @p15, @p16, @p17)
            returning id
            """, null,
            [baglam.KullaniciId, baglam.SubeId, maskeli, kaynak, konuKod, guven,
             (short)(istek?.AktifMod ?? 0),
             (ekran?.Rota is { Length: > 0 } r ? r : istek?.AktifSayfa ?? "") is var sayfa && sayfa.Length > 120 ? sayfa[..120] : sayfa,
             (int)kronometre.ElapsedMilliseconds, model, girisJeton, cikisJeton, kontor,
             ekran?.Kaynak ?? "", ekran?.Sekme ?? "", ekran?.Dil ?? "tr", kaynakNotu,
             (short)(maskelendi ? 1 : 0)],
            OkuyucuGenisletmeleri.Sozluk, iptal);
        return satir is null ? null : Convert.ToInt64(satir["id"]);
    }
}

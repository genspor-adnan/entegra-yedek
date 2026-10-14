namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PATOLOJİ KARTLARI (1104) — vaka (istem + materyaller + ek inceleme + raporlar),
/// dış lab gönderimi, tanımlar.
///
/// Mockup: Ekranlar/Patoloji/patoloji_istem.html (istem ve numune hazırlama),
/// patoloji_gonderim.html, patoloji_sonuc.html, KurumIci/patoloji_arsiv_tanimlar.html.
///
/// <b>Klinik bilgi ve ön tanı ZORUNLU</b>: dış lab hastayı görmez; elindeki tek
/// bilgi istem formudur - eksik klinik bilgi telefonla aramaya ya da yanlış
/// tanıya yol açar.
/// <b>Durum kartta yazılmaz</b>: hazırlandı → gönderildi → kabul → rapor → gördüm
/// adımları aksiyonlardan yürür (PatolojiUclari); serbest düzenlenen bir durum,
/// TAT ve kayıp numune izini bozar.
/// </summary>
public static partial class KartKatalogu
{
    private const int PatVakaLog = 1390, PatMateryalLog = 1391, PatEkLog = 1392, PatRaporLog = 1393,
                      PatGonderimLog = 1394, PatMateryalTipiLog = 1395, PatBoyaLog = 1396,
                      PatRetLog = 1397, PatDisKodLog = 1398;

    internal static readonly Dictionary<string, string> PatVakaDurumKodlari = new()
    {
        ["1"] = "İstendi", ["2"] = "Hazırlandı", ["3"] = "Gönderildi", ["4"] = "Kabul edildi",
        ["5"] = "Makroskopide", ["6"] = "Doku takibinde", ["7"] = "Kesit / boyama", ["8"] = "Mikroskopide",
        ["9"] = "Ek inceleme", ["10"] = "Ön rapor", ["11"] = "Rapor geldi", ["12"] = "Hekim gördü",
        ["90"] = "Reddedildi", ["0"] = "İptal",
    };
    private static readonly Dictionary<string, string> PatVakaTuruKodlari = new()
        { ["1"] = "Histopatoloji", ["2"] = "Sitoloji", ["3"] = "Frozen", ["4"] = "Konsültasyon" };
    private static readonly Dictionary<string, string> PatCalismaYeriKodlari = new()
        { ["1"] = "🚚 Dış laboratuvar", ["2"] = "🏠 Kurum içi" };
    private static readonly Dictionary<string, string> PatOncelikKodlari = new()
        { ["1"] = "Rutin", ["2"] = "Acil" };
    private static readonly Dictionary<string, string> PatFiksatifKodlari = new()
        { ["1"] = "%10 tamponlu formalin", ["2"] = "Taze", ["3"] = "Alkol", ["4"] = "Sıvı bazlı sitoloji", ["9"] = "Diğer" };
    private static readonly Dictionary<string, string> PatKabulKodlari = new()
        { ["0"] = "Bekliyor", ["1"] = "Uygun", ["2"] = "Koşullu kabul", ["3"] = "Ret" };
    private static readonly Dictionary<string, string> PatEkKaynakKodlari = new()
        { ["1"] = "Lab istedi", ["2"] = "Patolog istedi" };
    private static readonly Dictionary<string, string> PatEkOnayKodlari = new()
        { ["0"] = "Gerekmez", ["1"] = "Onay bekliyor", ["2"] = "Onaylandı", ["3"] = "Reddedildi", ["4"] = "Otomatik (sözleşme)" };
    private static readonly Dictionary<string, string> PatEkDurumKodlari = new()
        { ["1"] = "İstendi", ["2"] = "Çalışıldı", ["3"] = "Değerlendirildi" };
    private static readonly Dictionary<string, string> PatRaporTurKodlari = new()
        { ["1"] = "Ana rapor", ["2"] = "Ek rapor", ["3"] = "Revize", ["4"] = "Frozen" };
    private static readonly Dictionary<string, string> PatRaporKaynakKodlari = new()
        { ["1"] = "Dış lab", ["2"] = "Kurum içi" };
    private static readonly Dictionary<string, string> PatRaporDurumKodlari = new()
        { ["1"] = "Taslak", ["2"] = "Ön rapor", ["3"] = "Onaylı" };
    private static readonly Dictionary<string, string> PatGonderimDurumKodlari = new()
        { ["1"] = "Hazırlanıyor", ["2"] = "Yolda", ["3"] = "Lab teslim aldı", ["0"] = "İptal" };
    private static readonly Dictionary<string, string> PatIletimKodlari = new()
        { ["0"] = "İletilmedi", ["1"] = "İletildi", ["2"] = "Hata" };
    private static readonly Dictionary<string, string> PatTasimaKodlari = new()
        { ["1"] = "Oda sıcaklığı · formalinde", ["2"] = "Soğuk (2-8 °C)", ["3"] = "Taze (hemen)" };
    private static readonly Dictionary<string, string> PatBoyaTurKodlari = new()
        { ["1"] = "Rutin", ["2"] = "Özel boya", ["3"] = "İHK", ["4"] = "Moleküler", ["5"] = "Ek kesit" };
    private static readonly Dictionary<string, string> PatRetDavranisKodlari = new()
        { ["1"] = "Ret · hekime bildirim", ["2"] = "Koşullu kabul", ["3"] = "Bekletilir · istem istenir" };
    private static readonly Dictionary<string, string> PatAktifKodlari = new() { ["1"] = "Aktif", ["0"] = "Pasif" };
    private static readonly Dictionary<string, string> PatSerbestKodlari = new()
        { ["1"] = "Çalışılabilir", ["0"] = "⏳ Başvuru kaydı bekliyor (banko)" };
    private static readonly Dictionary<string, string> PatEvetHayirKodlari = new() { ["1"] = "Evet", ["0"] = "Hayır" };

    private static KartTanimi PatolojiVakaKarti() => new(
        Ad: "patoloji-vaka",
        YetkiKodu: "patoloji.vaka",
        Tablo: "public.pat_vaka",
        LogTabloId: PatVakaLog,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1, ["calismaYeri"] = (short)1, ["oncelik"] = (short)1, ["durum"] = (short)1,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.pat_rapor", "vaka_id", "Raporu olan vaka silinemez."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("vakaNo", "vaka_no", "metin", Yazilabilir: false, Baslik: "Vaka No", Grup: "İstem"),
            new("durum", "durum", "kod", Yazilabilir: false, SabitKodlar: PatVakaDurumKodlari, Baslik: "Durum", Grup: "İstem"),
            new("hastaId", "hasta_id", "kod", Zorunlu: true, YalnizYeniKayitta: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta", Grup: "İstem"),
            new("tur", "tur", "kod", Zorunlu: true, SabitKodlar: PatVakaTuruKodlari, Baslik: "Vaka Türü", Grup: "İstem"),
            new("isteyenId", "isteyen_id", "kod", KodTablosu: "public.v_hekim_lookup", Baslik: "İsteyen Hekim", Grup: "İstem"),
            new("bolumId", "bolum_id", "kod", KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm", Grup: "İstem"),
            new("istemYeri", "istem_yeri", "metin", EnFazlaUzunluk: 120, Baslik: "İstem Yeri (ameliyathane, endoskopi…)", Grup: "İstem"),
            new("oncelik", "oncelik", "kod", SabitKodlar: PatOncelikKodlari, Baslik: "Öncelik", Grup: "İstem"),
            new("serbest", "serbest", "kod", Yazilabilir: false, SabitKodlar: PatSerbestKodlari, Baslik: "Başvuru Kapısı", Grup: "İstem"),
            new("istemZamani", "istem_zamani", "zaman", Yazilabilir: false, Baslik: "İstem Zamanı", Grup: "İstem"),

            // Labın patoloğu tanıyı buna göre koyar - ZORUNLU.
            new("klinikBilgi", "klinik_bilgi", "metin", Zorunlu: true, EnFazlaUzunluk: 4000,
                Baslik: "Klinik Bilgi", Grup: "Klinik Bilgi"),
            new("onTani", "on_tani", "kod", Zorunlu: true, KodTablosu: "public.v_icd_lookup", AramaKaynagi: "icd",
                Baslik: "Ön Tanı (ICD-10)", Grup: "Klinik Bilgi"),
            new("oncekiPatoloji", "onceki_patoloji", "metin", EnFazlaUzunluk: 200, Baslik: "Önceki Patoloji", Grup: "Klinik Bilgi"),

            // NEREDE: materyal tipinden / kurum ayarından önerilir, değiştirilebilir.
            new("calismaYeri", "calisma_yeri", "kod", Zorunlu: true, SabitKodlar: PatCalismaYeriKodlari, Baslik: "Nerede Çalışılacak", Grup: "Nerede"),
            new("disLabId", "dis_lab_id", "kod", KodTablosu: "public.v_pat_dis_lab_lookup", Baslik: "Dış Laboratuvar", Grup: "Nerede"),
            new("labVakaNo", "lab_vaka_no", "metin", EnFazlaUzunluk: 40, Baslik: "Lab Vaka No", Grup: "Nerede"),
            new("patolojiNo", "patoloji_no", "metin", Yazilabilir: false, Baslik: "Patoloji No (kurum içi)", Grup: "Nerede"),
            new("kabulZamani", "kabul_zamani", "zaman", Yazilabilir: false, Baslik: "Kabul", Grup: "Nerede"),
            new("raporZamani", "rapor_zamani", "zaman", Yazilabilir: false, Baslik: "Rapor", Grup: "Nerede"),
            new("gorduZamani", "gordu_zamani", "zaman", Yazilabilir: false, Baslik: "Hekim Gördü", Grup: "Nerede"),
            new("gonderimId", "gonderim_id", "kod", Yazilabilir: false, KodTablosu: "public.v_pat_gonderim_lookup", Baslik: "Gönderim", Grup: "Nerede"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 600, Baslik: "Açıklama", Grup: "Nerede"),
        },
        Detaylar: new DetayTanimi[]
        {
            // HER SATIR BİR KAP: etiket kaba yapıştırılır. Soğuk iskemi = alım → fiksatife giriş.
            new("materyaller", "public.pat_materyal", "vaka_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("harf", "harf", "metin", EnFazlaUzunluk: 3, Baslik: "Kap"),
                new("materyalTipiId", "materyal_tipi_id", "kod", Zorunlu: true, KodTablosu: "public.v_pat_materyal_tipi_lookup", Baslik: "Materyal Tipi"),
                new("lokalizasyon", "lokalizasyon", "metin", EnFazlaUzunluk: 200, Baslik: "Lokalizasyon / Not"),
                new("fiksatif", "fiksatif", "kod", SabitKodlar: PatFiksatifKodlari, Baslik: "Fiksatif"),
                new("alimZamani", "alim_zamani", "zaman", Baslik: "Alım"),
                new("fiksasyonZamani", "fiksasyon_zamani", "zaman", Baslik: "Fiksatife Giriş"),
                new("barkod", "barkod", "metin", EnFazlaUzunluk: 40, Baslik: "Kap Barkodu"),
                new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_hizmet_lookup", AramaKaynagi: "hizmet", Baslik: "Hizmet (SUT)"),
                new("labFiyat", "lab_fiyat", "para", Baslik: "Lab Fiyatı (alış)"),
                new("kabul", "kabul", "kod", Yazilabilir: false, SabitKodlar: PatKabulKodlari, Baslik: "Kabul"),
            }, Sirala: "harf, id", Baslik: "Materyaller", LogTabloId: PatMateryalLog),

            // EK İNCELEME: lab "İHK / özel boya gerekli" derse ek ücrettir - onay aksiyonla.
            new("ekIncelemeler", "public.pat_ek_inceleme", "vaka_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("blok", "blok", "metin", EnFazlaUzunluk: 20, Baslik: "Blok"),
                new("boyaId", "boya_id", "kod", KodTablosu: "public.v_pat_boya_lookup", Baslik: "Boya / Antikor"),
                new("testAdi", "test_adi", "metin", EnFazlaUzunluk: 200, Baslik: "İstenen (lab metni)"),
                new("gerekce", "gerekce", "metin", EnFazlaUzunluk: 400, Baslik: "Gerekçe"),
                new("kaynak", "kaynak", "kod", SabitKodlar: PatEkKaynakKodlari, Baslik: "Kaynak"),
                new("fiyat", "fiyat", "para", Baslik: "Ek Ücret (alış)"),
                new("onay", "onay", "kod", Yazilabilir: false, SabitKodlar: PatEkOnayKodlari, Baslik: "Onay"),
                new("sonuc", "sonuc", "metin", EnFazlaUzunluk: 200, Baslik: "Sonuç"),
                new("durum", "durum", "kod", SabitKodlar: PatEkDurumKodlari, Baslik: "Durum"),
            }, Sirala: "id", Baslik: "Ek İnceleme", LogTabloId: PatEkLog),

            // RAPOR SÜRÜMLÜ: onaylı rapor değiştirilmez (tg_pat_rapor_kilit); ek / revize yeni satır.
            //   PDF kartın "Doküman" sekmesinde (doküman deposu).
            new("raporlar", "public.pat_rapor", "vaka_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("surum", "surum", "sayi", Baslik: "Sürüm"),
                new("tur", "tur", "kod", SabitKodlar: PatRaporTurKodlari, Baslik: "Tür"),
                new("kaynak", "kaynak", "kod", SabitKodlar: PatRaporKaynakKodlari, Baslik: "Geliş"),
                new("durum", "durum", "kod", SabitKodlar: PatRaporDurumKodlari, Baslik: "Durum"),
                new("tani", "tani", "metin", EnFazlaUzunluk: 4000, Baslik: "Tanı"),
                new("makro", "makro", "metin", EnFazlaUzunluk: 8000, Baslik: "Makroskopi"),
                new("mikro", "mikro", "metin", EnFazlaUzunluk: 8000, Baslik: "Mikroskopi"),
                new("icdoTopografi", "icdo_topografi", "metin", EnFazlaUzunluk: 20, Baslik: "ICD-O Topografi"),
                new("icdoMorfoloji", "icdo_morfoloji", "metin", EnFazlaUzunluk: 20, Baslik: "ICD-O Morfoloji"),
                new("ptnm", "ptnm", "metin", EnFazlaUzunluk: 60, Baslik: "pTNM"),
                new("raporlayan", "raporlayan", "metin", EnFazlaUzunluk: 120, Baslik: "Raporlayan Patolog"),
                new("imzaDogrulandi", "imza_dogrulandi", "kod", SabitKodlar: PatEvetHayirKodlari, Baslik: "e-İmza Doğrulandı"),
                new("raporZamani", "rapor_zamani", "zaman", Baslik: "Rapor Zamanı"),
                new("gerekce", "gerekce", "metin", EnFazlaUzunluk: 400, Baslik: "Revize Gerekçesi"),
            }, Sirala: "surum, id", Baslik: "Raporlar", LogTabloId: PatRaporLog),
        });

    /// <summary>
    /// DIŞ LAB GÖNDERİMİ - paket. Vakalar pakete "Pakete Ekle" aksiyonuyla girer
    /// (aynı vaka iki pakete giremez); kurye / iletim / teslim adımları aksiyonla.
    /// </summary>
    private static KartTanimi PatolojiGonderimKarti() => new(
        Ad: "patoloji-gonderim",
        YetkiKodu: "patoloji.gonderim",
        Tablo: "public.pat_gonderim",
        LogTabloId: PatGonderimLog,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["iletimDurumu"] = (short)0, ["tasimaKosulu"] = (short)1 },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.pat_vaka", "gonderim_id", "Pakette vaka var - önce vakaları paketten çıkarın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("gonderimNo", "gonderim_no", "metin", Yazilabilir: false, Baslik: "Gönderim No", Grup: "Gönderim"),
            new("disLabId", "dis_lab_id", "kod", Zorunlu: true, YalnizYeniKayitta: true,
                KodTablosu: "public.v_pat_dis_lab_lookup", Baslik: "Laboratuvar", Grup: "Gönderim"),
            new("durum", "durum", "kod", Yazilabilir: false, SabitKodlar: PatGonderimDurumKodlari, Baslik: "Durum", Grup: "Gönderim"),
            new("tasimaKosulu", "tasima_kosulu", "kod", SabitKodlar: PatTasimaKodlari, Baslik: "Taşıma", Grup: "Gönderim"),
            new("kurye", "kurye", "metin", EnFazlaUzunluk: 120, Baslik: "Kurye", Grup: "Gönderim"),
            new("teslimEden", "teslim_eden", "metin", EnFazlaUzunluk: 120, Baslik: "Teslim Eden", Grup: "Gönderim"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 600, Baslik: "Açıklama", Grup: "Gönderim"),
            new("iletimDurumu", "iletim_durumu", "kod", Yazilabilir: false, SabitKodlar: PatIletimKodlari, Baslik: "Laba İletim", Grup: "İz"),
            new("iletimZamani", "iletim_zamani", "zaman", Yazilabilir: false, Baslik: "İletim Zamanı", Grup: "İz"),
            new("iletimMesaji", "iletim_mesaji", "metin", Yazilabilir: false, Baslik: "Lab Yanıtı", Grup: "İz"),
            new("kuryeZamani", "kurye_zamani", "zaman", Yazilabilir: false, Baslik: "Kurye Teslim Aldı", Grup: "İz"),
            new("teslimZamani", "teslim_zamani", "zaman", Yazilabilir: false, Baslik: "Lab Teslim Aldı", Grup: "İz"),
            new("teslimAlan", "teslim_alan", "metin", EnFazlaUzunluk: 120, Baslik: "Labda Teslim Alan", Grup: "İz"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("vakalar", "public.pat_vaka", "gonderim_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("vakaNo", "vaka_no", "metin", Yazilabilir: false, Baslik: "Vaka"),
                new("hastaId", "hasta_id", "kod", Yazilabilir: false, KodTablosu: "public.v_hasta_lookup", Baslik: "Hasta"),
                new("labVakaNo", "lab_vaka_no", "metin", Yazilabilir: false, Baslik: "Lab Vaka No"),
                new("durum", "durum", "kod", Yazilabilir: false, SabitKodlar: PatVakaDurumKodlari, Baslik: "Durum"),
            }, Sirala: "id", Baslik: "Paketteki Vakalar", SaltOkunur: true, LogTabloId: PatVakaLog),
        });

    private static KartTanimi PatolojiMateryalTipiKarti() => new(
        Ad: "patoloji-materyal-tipi",
        YetkiKodu: "patoloji.tanim.materyal",
        Tablo: "public.pat_materyal_tipi",
        LogTabloId: PatMateryalTipiLog,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["vakaTuru"] = (short)1, ["calismaYeri"] = (short)1, ["tatGun"] = (short)3, ["aktif"] = (short)1 },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.pat_materyal", "materyal_tipi_id", "Bu materyal tipi vakalarda kullanılmış - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", EnFazlaUzunluk: 20, Baslik: "Kod", Grup: "Materyal Tipi"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Adı", Grup: "Materyal Tipi"),
            new("vakaTuru", "vaka_turu", "kod", Zorunlu: true, SabitKodlar: PatVakaTuruKodlari, Baslik: "Vaka Türü", Grup: "Materyal Tipi"),
            new("calismaYeri", "calisma_yeri", "kod", Zorunlu: true, SabitKodlar: PatCalismaYeriKodlari, Baslik: "Varsayılan: Nerede", Grup: "Materyal Tipi"),
            new("disLabId", "dis_lab_id", "kod", KodTablosu: "public.v_pat_dis_lab_lookup", Baslik: "Varsayılan Dış Lab", Grup: "Materyal Tipi"),
            new("tatGun", "tat_gun", "sayi", Baslik: "TAT (iş günü)", Grup: "Materyal Tipi"),
            new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_hizmet_lookup", AramaKaynagi: "hizmet", Baslik: "Hizmet (ücret · SUT)", Grup: "Materyal Tipi"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Materyal Tipi"),
            new("aktif", "aktif", "kod", SabitKodlar: PatAktifKodlari, Baslik: "Durum", Grup: "Materyal Tipi"),
            new("makroSablon", "makro_sablon", "metin", EnFazlaUzunluk: 4000, Baslik: "Makro Şablonu ({etiket}, {fiksatif}, {tumor_boyut}…)", Grup: "Makro Şablonu"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Makro Şablonu"),
        });

    private static KartTanimi PatolojiBoyaKarti() => new(
        Ad: "patoloji-boya",
        YetkiKodu: "patoloji.tanim.boya",
        Tablo: "public.pat_boya",
        LogTabloId: PatBoyaLog,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)3, ["aktif"] = (short)1 },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.pat_ek_inceleme", "boya_id", "Bu boya / antikor istenmiş - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Adı", Grup: "Boya / Antikor"),
            new("tur", "tur", "kod", Zorunlu: true, SabitKodlar: PatBoyaTurKodlari, Baslik: "Tür", Grup: "Boya / Antikor"),
            new("klon", "klon", "metin", EnFazlaUzunluk: 40, Baslik: "Klon", Grup: "Boya / Antikor"),
            new("platform", "platform", "metin", EnFazlaUzunluk: 80, Baslik: "Platform", Grup: "Boya / Antikor"),
            new("sonucBicimi", "sonuc_bicimi", "metin", EnFazlaUzunluk: 80, Baslik: "Sonuç Biçimi", Grup: "Boya / Antikor"),
            new("kontrolDoku", "kontrol_doku", "metin", EnFazlaUzunluk: 80, Baslik: "Kontrol Doku", Grup: "Boya / Antikor"),
            new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_hizmet_lookup", AramaKaynagi: "hizmet", Baslik: "Hizmet (ücret)", Grup: "Boya / Antikor"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Boya / Antikor"),
            new("aktif", "aktif", "kod", SabitKodlar: PatAktifKodlari, Baslik: "Durum", Grup: "Boya / Antikor"),
        });

    private static KartTanimi PatolojiRetNedeniKarti() => new(
        Ad: "patoloji-ret-nedeni",
        YetkiKodu: "patoloji.tanim.ret",
        Tablo: "public.pat_ret_nedeni",
        LogTabloId: PatRetLog,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["davranis"] = (short)1, ["aktif"] = (short)1 },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.pat_vaka", "ret_nedeni_id", "Bu ret nedeni vakalarda kullanılmış - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Ret Nedeni", Grup: "Ret Nedeni"),
            new("davranis", "davranis", "kod", Zorunlu: true, SabitKodlar: PatRetDavranisKodlari, Baslik: "Davranış", Grup: "Ret Nedeni"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Ret Nedeni"),
            new("aktif", "aktif", "kod", SabitKodlar: PatAktifKodlari, Baslik: "Durum", Grup: "Ret Nedeni"),
        });

    /// <summary>Dış lab kartına (Lab ile ORTAK) eklenen patoloji kod eşlemesi detayı.</summary>
    private static DetayTanimi PatolojiDisKodDetayi() =>
        new("patolojiKodlari", "public.pat_dis_kod", "dis_lab_id", new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("materyalTipiId", "materyal_tipi_id", "kod", KodTablosu: "public.v_pat_materyal_tipi_lookup", Baslik: "Materyal Tipi"),
            new("boyaId", "boya_id", "kod", KodTablosu: "public.v_pat_boya_lookup", Baslik: "Boya / Antikor"),
            new("disKod", "dis_kod", "metin", EnFazlaUzunluk: 40, Baslik: "Labın Kodu"),
            new("disAd", "dis_ad", "metin", EnFazlaUzunluk: 200, Baslik: "Labdaki Adı"),
            new("birimFiyat", "birim_fiyat", "para", Baslik: "Fiyat (alış)"),
            new("tatGun", "tat_gun", "sayi", Baslik: "TAT (gün)"),
            new("otomatikOnay", "otomatik_onay", "kod", SabitKodlar: PatEvetHayirKodlari, Baslik: "Ek İnceleme Otomatik Onay"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari, Baslik: "Durum"),
        }, Sirala: "id", Baslik: "Patoloji Kod Eşleme", LogTabloId: PatDisKodLog);
}

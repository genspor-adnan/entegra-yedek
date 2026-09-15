namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// GÖZ (OFTALMOLOJİ) KARTLARI (691/693) — mockuplar <c>Ekranlar/Goz/*.html</c>.
///
/// <para><b>Ölçümler DETAY SEKMESİDİR, alan değil.</b> Göz muayenesinde her
/// ölçüm göz bazlı ve tekrarlıdır (otoref → subjektif → sikloplejik); kart
/// alanı olarak <c>od_sph</c> / <c>os_sph</c> açmak, aynı ziyaretteki ikinci
/// ölçümü kaydedecek yer bırakmazdı. Bu yüzden Görme, Refraksiyon, Tonometri,
/// Ön Segment, Fundus ve Ek Test birer <see cref="DetayTanimi"/>.</para>
///
/// <para><b>Motilite tek satır</b> (<c>TekSatir: true</c>): şaşılık, stereopsis
/// ve konverjans iki gözün BİRLİKTE davranışıdır — OD/OS satırlarına bölmek
/// ölçümün anlamını bozar.</para>
///
/// <para><b>İşlem kartında tür detayları birbirini dışlar:</b> enjeksiyon,
/// lazer ve ameliyat sekmeleri <c>TekSatir</c>'dır ve yalnız ilgili tür
/// seçilince doldurulur. Üç ayrı kart yapmak, "bu hastaya bugüne kadar ne
/// yapıldı" sorusunu üç ekrana bölerdi.</para>
/// </summary>
public static partial class KartKatalogu
{
    // ISLEMLOG tablo kodları (691) — 1100 bloğu göze ayrıldı.
    private const int LogGozMuayene     = 1100;
    private const int LogGozGoruntuleme = 1101;
    private const int LogGozIslem       = 1102;
    private const int LogGozGozlukRecete= 1103;
    private const int LogGozTakip       = 1104;
    private const int LogGozCihaz       = 1105;
    private const int LogGozOlcum       = 1106;   // muayene ölçüm detayları
    private const int LogGozIslemDetay  = 1107;   // enjeksiyon / lazer / ameliyat
    private const int LogGozCizim       = 1108;   // göz şeması (705)
    private const int LogDikteTerim     = 1109;   // dikte sözlüğü (705)

    /// <summary>Sözlük satırının ne olduğu: kelime mi, komut mu, hazır cümle mi.</summary>
    private static readonly Dictionary<string, string> DikteTurKodlari =
        new() { ["1"] = "Terim", ["2"] = "Komut", ["3"] = "Sık cümle" };

    /// <summary>OD/OS/OU — her ölçüm satırında aynı seçim.</summary>
    private static readonly Dictionary<string, string> GozTarafKodlari =
        new() { ["1"] = "OD (sağ)", ["2"] = "OS (sol)", ["3"] = "OU (her iki)" };

    /// <summary>Ölçümü kim aldı: cihaz ölçümü hekim onaylayana kadar ÖN VERİDİR.</summary>
    private static readonly Dictionary<string, string> GozKaynakKodlari =
        new() { ["1"] = "Hekim", ["2"] = "Tekniker", ["3"] = "Cihaz", ["4"] = "Hasta beyanı" };

    // ====================================================== göz muayenesi ====
    private static KartTanimi GozMuayeneKarti() => new(
        Ad: "goz-muayene",
        YetkiKodu: "goz.muayene",
        Tablo: "public.goz_muayene",
        LogTabloId: LogGozMuayene,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["muayeneTuru"] = (short)1,   // Tam muayene
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // Göz muayenesi genel muayenenin UZANTISIDIR (1:1): hasta, hekim,
            //   tarih ve tanı orada durur. Buradan değiştirilemez - iki yerde
            //   iki ayrı doğru olmasın.
            new("muayeneId", "muayene_id", "sayi", Yazilabilir: false,
                Baslik: "Muayene", Grup: "Genel"),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Genel"),
            new("muayeneTuru", "muayene_turu", "kod", KodListesi: "goz.muayene_turu",
                Baslik: "Muayene Türü", Grup: "Genel"),
            // DİLATASYON bir alan değil bir DURUM: dilate göz muayenesinde
            //   fundus bakısı geçerli, refraksiyon ise güvenilmezdir. Ölçümü
            //   okuyan hekimin bunu bilmesi gerekir.
            new("dilate", "dilate", "mantik", Baslik: "Dilate edildi", Grup: "Genel"),
            new("dilatasyonIlac", "dilatasyon_ilac", "metin", EnFazlaUzunluk: 60,
                Baslik: "Dilatasyon İlacı", Grup: "Genel"),
            new("takipId", "takip_id", "kod", KodTablosu: "public.v_goz_takip_lookup",
                Baslik: "Hastalık Takibi", Grup: "Genel"),
            new("kontrolGun", "kontrol_gun", "sayi", Baslik: "Kontrol (gün)", Grup: "Genel"),

            new("degerlendirme", "degerlendirme", "metin",
                Baslik: "Değerlendirme", Grup: "Tanı & Plan", EnFazlaUzunluk: 2000),
            new("plan", "plan", "metin",
                Baslik: "Plan", Grup: "Tanı & Plan", EnFazlaUzunluk: 2000),
            new("hastaEgitimi", "hasta_egitimi", "metin", EnFazlaUzunluk: 600,
                Baslik: "Hasta Eğitimi", Grup: "Tanı & Plan"),
        },
        Detaylar: new DetayTanimi[]
        {
            // GÖRME: aynı gözde UCVA, pinhole ve BCVA ayrı satırlardır —
            //   "düzeltmeyle ne kadar görüyor" sorusunun cevabı ancak ikisi
            //   yan yana durunca verilir.
            new("gorme", "public.goz_gorme", "goz_muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("tur", "tur", "kod", KodListesi: "goz.va_tur", Baslik: "Tür"),
                new("esel", "esel", "kod", KodListesi: "goz.va_esel", Baslik: "Eşel"),
                new("degerOndalik", "deger_ondalik", "ondalik", Baslik: "Ondalık"),
                new("degerSnellen", "deger_snellen", "metin", EnFazlaUzunluk: 10, Baslik: "Snellen"),
                // logMAR karşılaştırma için: 0,1 ile 0,2 arasındaki fark,
                //   0,8 ile 0,9 arasındakiyle aynı değildir.
                new("degerLogmar", "deger_logmar", "ondalik", Baslik: "logMAR"),
                // PH / EH / IH: sayıyla ifade edilemeyen görme düzeyleri.
                new("degerMetin", "deger_metin", "metin", EnFazlaUzunluk: 20, Baslik: "PH/EH/IH"),
                new("yakinJaeger", "yakin_jaeger", "metin", EnFazlaUzunluk: 6, Baslik: "Yakın (J)"),
                new("kaynak", "kaynak", "kod", SabitKodlar: GozKaynakKodlari, Baslik: "Kaynak"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("notMetin", "not_metin", "metin", EnFazlaUzunluk: 100, Baslik: "Not"),
            }, SubeKolonu: null, Sirala: "goz, tur, zaman", LogTabloId: LogGozOlcum,
               Baslik: "Görme & Refraksiyon"),

            new("refraksiyon", "public.goz_refraksiyon", "goz_muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("tur", "tur", "kod", KodListesi: "goz.ref_tur", Baslik: "Tür"),
                new("sph", "sph", "ondalik", Baslik: "Sph"),
                new("cyl", "cyl", "ondalik", Baslik: "Cyl"),
                new("aks", "aks", "sayi", Baslik: "Aks"),
                new("addYakin", "add_yakin", "ondalik", Baslik: "Add"),
                new("va", "va", "ondalik", Baslik: "VA"),
                new("k1", "k1", "ondalik", Baslik: "K1"),
                new("k2", "k2", "ondalik", Baslik: "K2"),
                new("pdUzak", "pd_uzak", "ondalik", Baslik: "PD Uzak"),
                new("pdYakin", "pd_yakin", "ondalik", Baslik: "PD Yakın"),
                new("kaynak", "kaynak", "kod", SabitKodlar: GozKaynakKodlari, Baslik: "Kaynak"),
                new("cihazId", "cihaz_id", "kod", KodTablosu: "public.v_goz_cihaz_lookup",
                    Baslik: "Cihaz"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
            }, SubeKolonu: null, Sirala: "goz, tur, zaman", LogTabloId: LogGozOlcum,
               Baslik: "Refraksiyon"),

            new("tonometri", "public.goz_tonometri", "goz_muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("yontem", "yontem", "kod", KodListesi: "goz.tono_yontem", Baslik: "Yöntem"),
                new("gib", "gib", "ondalik", Baslik: "GİB (mmHg)"),
                new("cctUm", "cct_um", "sayi", Baslik: "CCT (µm)"),
                new("duzeltilmisGib", "duzeltilmis_gib", "ondalik", Baslik: "Düzeltilmiş GİB"),
                new("hedefGib", "hedef_gib", "ondalik", Baslik: "Hedef GİB"),
                // BAYRAK veritabanında hesaplanır (>21 yüksek, >30 panik):
                //   yazılabilir olsaydı, panik değer "normal" işaretlenebilirdi.
                new("bayrak", "bayrak", "sayi", Yazilabilir: false, Baslik: "Uyarı"),
                new("damlaSonrasiDk", "damla_sonrasi_dk", "sayi", Baslik: "Damladan Sonra (dk)"),
                new("kaynak", "kaynak", "kod", SabitKodlar: GozKaynakKodlari, Baslik: "Kaynak"),
                new("cihazId", "cihaz_id", "kod", KodTablosu: "public.v_goz_cihaz_lookup",
                    Baslik: "Cihaz"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
            }, SubeKolonu: null, Sirala: "goz, zaman", LogTabloId: LogGozOlcum,
               Baslik: "Tonometri & Pakimetri"),

            // ÖN SEGMENT alan bazlı satırdır (kapak, kornea, ön kamara, lens…):
            //   sabit kolonlar açmak, yeni bir bulgu alanını şema
            //   değişikliğine bağlardı.
            new("onSegment", "public.goz_on_segment", "goz_muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("alan", "alan", "metin", Zorunlu: true, EnFazlaUzunluk: 40, Baslik: "Alan"),
                new("normal", "normal", "mantik", Baslik: "Normal"),
                new("degerKod", "deger_kod", "metin", EnFazlaUzunluk: 20,
                    Baslik: "Kod (LOCS / Van Herick)"),
                new("degerSayi", "deger_sayi", "ondalik", Baslik: "Sayı (BUT / Schirmer)"),
                new("degerMetin", "deger_metin", "metin", Baslik: "Bulgu", EnFazlaUzunluk: 600),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
            }, SubeKolonu: null, Sirala: "goz, alan", LogTabloId: LogGozOlcum,
               Baslik: "Ön Segment"),

            new("fundus", "public.goz_fundus", "goz_muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("yontem", "yontem", "kod", KodListesi: "goz.fundus_yontem", Baslik: "Yöntem"),
                new("dilate", "dilate", "mantik", Baslik: "Dilate"),
                new("cdYatay", "cd_yatay", "ondalik", Baslik: "C/D Yatay"),
                new("cdDikey", "cd_dikey", "ondalik", Baslik: "C/D Dikey"),
                new("isntIhlal", "isnt_ihlal", "mantik", Baslik: "ISNT ihlali"),
                new("diskKanama", "disk_kanama", "mantik", Baslik: "Disk kanaması"),
                // DR ve AMD evresi kodludur: tarama programının, sevkin ve
                //   anti-VEGF endikasyonunun ortak dili.
                new("drEvre", "dr_evre", "kod", KodListesi: "goz.dr_evre", Baslik: "DR Evresi"),
                new("dmo", "dmo", "kod", KodListesi: "goz.dmo", Baslik: "DMÖ"),
                new("amdEvre", "amd_evre", "kod", KodListesi: "goz.amd_evre", Baslik: "AMD Evresi"),
                new("diskMetin", "disk_metin", "metin", Baslik: "Disk", EnFazlaUzunluk: 600),
                new("makulaMetin", "makula_metin", "metin", Baslik: "Maküla", EnFazlaUzunluk: 600),
                new("periferiMetin", "periferi_metin", "metin", Baslik: "Periferi", EnFazlaUzunluk: 600),
                new("vitreus", "vitreus", "metin", EnFazlaUzunluk: 100, Baslik: "Vitreus"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
            }, SubeKolonu: null, Sirala: "goz, zaman", LogTabloId: LogGozOlcum,
               Baslik: "Fundus"),

            // MOTİLİTE TEK SATIR: iki gözün BİRLİKTE davranışı - OD/OS'e
            //   bölmek ölçümün anlamını bozar.
            new("motilite", "public.goz_motilite", "goz_muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("coverUzak", "cover_uzak", "metin", EnFazlaUzunluk: 40, Baslik: "Cover Uzak"),
                new("coverYakin", "cover_yakin", "metin", EnFazlaUzunluk: 40, Baslik: "Cover Yakın"),
                new("stereopsis", "stereopsis", "metin", EnFazlaUzunluk: 20, Baslik: "Stereopsis"),
                new("worth", "worth", "metin", EnFazlaUzunluk: 20, Baslik: "Worth"),
                new("nistagmus", "nistagmus", "metin", EnFazlaUzunluk: 60, Baslik: "Nistagmus"),
                new("kynCm", "kyn_cm", "sayi", Baslik: "KYN (cm)"),
                new("pupilOdMm", "pupil_od_mm", "ondalik", Baslik: "Pupil OD (mm)"),
                new("pupilOsMm", "pupil_os_mm", "ondalik", Baslik: "Pupil OS (mm)"),
                // RAPD tek taraflı optik sinir hastalığının en güçlü
                //   bulgusudur; serbest metne yazılırsa aranamaz.
                new("rapd", "rapd", "kod", SabitKodlar: new Dictionary<string, string>
                    { ["0"] = "Yok", ["1"] = "OD", ["2"] = "OS" }, Baslik: "RAPD"),
                new("renkGorme", "renk_gorme", "metin", EnFazlaUzunluk: 20, Baslik: "Renk Görme"),
                new("konfrontasyon", "konfrontasyon", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Konfrontasyon"),
                new("hertelOd", "hertel_od", "sayi", Baslik: "Hertel OD"),
                new("hertelOs", "hertel_os", "sayi", Baslik: "Hertel OS"),
                new("mrd1Od", "mrd1_od", "ondalik", Baslik: "MRD1 OD"),
                new("mrd1Os", "mrd1_os", "ondalik", Baslik: "MRD1 OS"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
            }, SubeKolonu: null, LogTabloId: LogGozOlcum, Baslik: "Motilite · Pupil · Alan",
               TekSatir: true),

            new("ekTest", "public.goz_ek_test", "goz_muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("test", "test", "metin", Zorunlu: true, EnFazlaUzunluk: 40, Baslik: "Test"),
                new("degerSayi", "deger_sayi", "ondalik", Baslik: "Değer"),
                new("degerMetin", "deger_metin", "metin", Baslik: "Bulgu", EnFazlaUzunluk: 600),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
            }, SubeKolonu: null, Sirala: "test, goz", LogTabloId: LogGozOlcum,
               Baslik: "Gonyoskopi & Ek Testler"),
        });

    // ======================================================== görüntüleme ====
    private static KartTanimi GozGoruntulemeKarti() => new(
        Ad: "goz-goruntuleme",
        YetkiKodu: "goz.goruntuleme",
        Tablo: "public.goz_goruntuleme",
        LogTabloId: LogGozGoruntuleme,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,   // İstendi
            ["goz"] = (short)3,     // OU
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // MUAYENE BAGI ARKA PLANDA (Gizli): kayit bir muayeneden
            //   dogduysa hangi muayene oldugu KAYDEDILIR - ekranda ham
            //   id gostermenin degeri yok, ama bagin kaybolmasinin
            //   bedeli var: "bu goruntulemeyi kim, hangi muayenede
            //   istedi" sorusu sonra cevapsiz kalir. Muayene kartindaki
            //   kisayol bu alani URL ile doldurur.
            new("muayeneId", "muayene_id", "sayi", Gizli: true),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "İstem"),
            new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari,
                Baslik: "Göz", Grup: "İstem"),
            new("tetkik", "tetkik", "kod", Zorunlu: true, KodListesi: "goz.tetkik",
                Baslik: "Tetkik", Grup: "İstem"),
            // Ücretin kaynağı hizmet satırıdır; tetkik kodu klinik, hizmet
            //   mali taraf. İkisi ayrı alan - biri değişince öteki yanlış
            //   olmasın diye tek alana sıkıştırılmadı.
            new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_goz_tetkik_lookup",
                Baslik: "Hizmet (ücret)", Grup: "İstem"),
            new("durum", "durum", "kod", KodListesi: "goz.goruntuleme_durum",
                Baslik: "Durum", Grup: "İstem"),
            new("istemZamani", "istem_zamani", "zaman", Baslik: "İstem Zamanı", Grup: "İstem"),

            new("cihazId", "cihaz_id", "kod", KodTablosu: "public.v_goz_cihaz_lookup",
                Baslik: "Cihaz", Grup: "Çekim"),
            new("cekimZamani", "cekim_zamani", "zaman", Baslik: "Çekim Zamanı", Grup: "Çekim"),
            new("teknisyenId", "teknisyen_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Teknisyen", Grup: "Çekim"),
            new("dilate", "dilate", "mantik", Baslik: "Dilate", Grup: "Çekim"),
            // KALİTE klinik bir filtredir: düşük sinyalli OCT'nin ölçümü
            //   trende girerse "incelme" sanılan şey aslında kötü çekimdir.
            new("kalite", "kalite", "sayi", Baslik: "Kalite / Sinyal", Grup: "Çekim"),
            new("studyUid", "study_uid", "metin", EnFazlaUzunluk: 64,
                Baslik: "DICOM Study UID", Grup: "Çekim"),

            new("degerlendirme", "degerlendirme", "metin",
                Baslik: "Değerlendirme", Grup: "Değerlendirme", EnFazlaUzunluk: 2500),
            new("degerlendirenId", "degerlendiren_id", "kod",
                KodTablosu: "public.v_hekim_lookup",
                Baslik: "Değerlendiren", Grup: "Değerlendirme"),
            new("degerlendirmeZamani", "degerlendirme_zamani", "zaman",
                Baslik: "Değerlendirme Zamanı", Grup: "Değerlendirme"),
        },
        Detaylar: new DetayTanimi[]
        {
            // AYRIŞTIRILMIŞ ÖLÇÜM trendin kaynağıdır. PDF'in içinde bırakılsaydı
            //   "RNFL iki yılda ne kadar inceldi" sorusu elle okunarak
            //   cevaplanırdı.
            new("olcumler", "public.goz_goruntuleme_olcum", "goruntuleme_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("olcum", "olcum", "metin", Zorunlu: true, EnFazlaUzunluk: 40, Baslik: "Ölçüm"),
                new("deger", "deger", "ondalik", Baslik: "Değer"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 10, Baslik: "Birim"),
                // Cihaz normatif yüzdesi YALNIZ BAYRAK içindir: üreticinin
                //   normal aralığı tanı ölçütü değildir.
                new("normalPct", "normal_pct", "ondalik", Baslik: "Normatif %"),
                new("bayrak", "bayrak", "sayi", Baslik: "Bayrak"),
            }, SubeKolonu: null, Sirala: "goz, olcum", LogTabloId: LogGozGoruntuleme,
               Baslik: "Ölçümler"),

            // BİYOMETRİ tek satır: bir gözün bir çekiminde tek biyometri olur.
            new("biyometri", "public.goz_biyometri", "goruntuleme_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari, Baslik: "Göz"),
                new("al", "al", "ondalik", Baslik: "AL (mm)"),
                new("k1", "k1", "ondalik", Baslik: "K1"),
                new("k2", "k2", "ondalik", Baslik: "K2"),
                new("acd", "acd", "ondalik", Baslik: "ACD"),
                new("lt", "lt", "ondalik", Baslik: "LT"),
                new("wtw", "wtw", "ondalik", Baslik: "WTW"),
                new("snr", "snr", "sayi", Baslik: "SNR"),
                new("hedefRef", "hedef_ref", "ondalik", Baslik: "Hedef Refraksiyon"),
                new("secilenIolModel", "secilen_iol_model", "metin", EnFazlaUzunluk: 60,
                    Baslik: "IOL Modeli"),
                new("aSabiti", "a_sabiti", "ondalik", Baslik: "A Sabiti"),
                new("guc", "guc", "ondalik", Baslik: "Güç (D)"),
                new("torikSilindir", "torik_silindir", "ondalik", Baslik: "Torik Silindir"),
                new("torikAks", "torik_aks", "sayi", Baslik: "Torik Aks"),
            }, SubeKolonu: null, LogTabloId: LogGozGoruntuleme, Baslik: "Biyometri / IOL",
               TekSatir: true),
        });

    // ============================================================= işlemler ====
    private static KartTanimi GozIslemKarti() => new(
        Ad: "goz-islem",
        YetkiKodu: "goz.islem",
        Tablo: "public.goz_islem",
        LogTabloId: LogGozIslem,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,   // Planlı
            ["tur"] = (short)1,     // İntravitreal enjeksiyon
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // MUAYENE BAGI ARKA PLANDA (Gizli): kayit bir muayeneden
            //   dogduysa hangi muayene oldugu KAYDEDILIR - ekranda ham
            //   id gostermenin degeri yok, ama bagin kaybolmasinin
            //   bedeli var: "bu goruntulemeyi kim, hangi muayenede
            //   istedi" sorusu sonra cevapsiz kalir. Muayene kartindaki
            //   kisayol bu alani URL ile doldurur.
            new("muayeneId", "muayene_id", "sayi", Gizli: true),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "İşlem"),
            // TARAF ZORUNLU: yanlış göz cerrahisi önlenebilir bir olaydır ve
            //   önlemenin ilk adımı, kaydın kendisinde boş bırakılamamasıdır.
            new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari,
                Baslik: "Göz", Grup: "İşlem"),
            new("tur", "tur", "kod", Zorunlu: true, KodListesi: "goz.islem_tur",
                Baslik: "İşlem Türü", Grup: "İşlem"),
            new("endikasyonIcd", "endikasyon_icd", "metin", EnFazlaUzunluk: 10,
                Baslik: "Endikasyon (ICD)", Grup: "İşlem"),
            new("islemKod", "islem_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "SUT Kodu", Grup: "İşlem"),
            new("durum", "durum", "kod", KodListesi: "goz.islem_durum",
                Baslik: "Durum", Grup: "İşlem"),

            new("planlananTarih", "planlanan_tarih", "zaman",
                Baslik: "Planlanan", Grup: "Planlama"),
            new("uygulamaZamani", "uygulama_zamani", "zaman",
                Baslik: "Uygulama", Grup: "Planlama"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Hekim", Grup: "Planlama"),
            new("salon", "salon", "metin", EnFazlaUzunluk: 30, Baslik: "Salon", Grup: "Planlama"),
            new("anestezi", "anestezi", "kod", KodListesi: "goz.anestezi",
                Baslik: "Anestezi", Grup: "Planlama"),
            new("anesteziKonsultasyon", "anestezi_konsultasyon", "mantik",
                Baslik: "Anestezi konsültasyonu", Grup: "Planlama"),
            new("postopProtokolId", "postop_protokol_id", "kod",
                KodTablosu: "public.v_goz_protokol_lookup",
                Baslik: "Postop Protokolü", Grup: "Planlama"),

            new("bulgular", "bulgular", "metin", Baslik: "Bulgular", Grup: "Sonuç", EnFazlaUzunluk: 2000),
            // KOMPLİKASYON kodlu: endoftalmi ve PCR oranı kalite göstergesidir
            //   ve serbest metinden toplanamaz.
            new("komplikasyon", "komplikasyon", "kod", KodListesi: "goz.komplikasyon",
                Baslik: "Komplikasyon", Grup: "Sonuç"),
            new("komplikasyonNotu", "komplikasyon_notu", "metin", EnFazlaUzunluk: 400,
                Baslik: "Komplikasyon Notu", Grup: "Sonuç"),
        },
        Detaylar: new DetayTanimi[]
        {
            // Tür detayları BİRBİRİNİ DIŞLAR ve TekSatir'dır: bir işlem ya
            //   enjeksiyondur ya lazerdir ya ameliyat.
            new("enjeksiyon", "public.goz_enjeksiyon", "islem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("ilac", "ilac", "kod", KodListesi: "goz.enj_ilac", Baslik: "İlaç"),
                new("dozMg", "doz_mg", "ondalik", Baslik: "Doz (mg)"),
                // DOZ NO seri içindeki sıradır: "kaçıncı enjeksiyon" hem
                //   endikasyon hem geri ödeme sorusudur.
                new("dozNo", "doz_no", "sayi", Baslik: "Doz No"),
                new("protokol", "protokol", "kod", KodListesi: "goz.enj_protokol",
                    Baslik: "Protokol"),
                new("aralikHafta", "aralik_hafta", "sayi", Baslik: "Aralık (hafta)"),
                new("girisYeri", "giris_yeri", "metin", EnFazlaUzunluk: 40, Baslik: "Giriş Yeri"),
                new("islemSonrasiGib", "islem_sonrasi_gib", "ondalik", Baslik: "İşlem Sonrası GİB"),
                new("isikHissi", "isik_hissi", "mantik", Baslik: "Işık hissi var"),
                new("sonrakiPlanlanan", "sonraki_planlanan", "tarih", Baslik: "Sonraki Planlanan"),
            }, SubeKolonu: null, LogTabloId: LogGozIslemDetay, Baslik: "Enjeksiyon",
               TekSatir: true),

            new("lazer", "public.goz_lazer", "islem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("lazerTur", "lazer_tur", "kod", KodListesi: "goz.lazer_tur", Baslik: "Lazer Türü"),
                new("dalgaBoyuNm", "dalga_boyu_nm", "sayi", Baslik: "Dalga Boyu (nm)"),
                new("gucMw", "guc_mw", "ondalik", Baslik: "Güç (mW)"),
                new("enerjiMj", "enerji_mj", "ondalik", Baslik: "Enerji (mJ)"),
                new("spotUm", "spot_um", "sayi", Baslik: "Spot (µm)"),
                new("sureMs", "sure_ms", "sayi", Baslik: "Süre (ms)"),
                new("spotSayisi", "spot_sayisi", "sayi", Baslik: "Spot Sayısı"),
                new("alan", "alan", "metin", EnFazlaUzunluk: 60, Baslik: "Alan (360° / kadran)"),
                new("lens", "lens", "metin", EnFazlaUzunluk: 40, Baslik: "Kontakt Lens"),
                new("seansNo", "seans_no", "sayi", Baslik: "Seans No"),
            }, SubeKolonu: null, LogTabloId: LogGozIslemDetay, Baslik: "Lazer", TekSatir: true),

            new("ameliyat", "public.goz_ameliyat", "islem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("ameliyatTur", "ameliyat_tur", "kod", KodListesi: "goz.ameliyat_tur",
                    Baslik: "Ameliyat Türü"),
                // IOL gücü biyometriye BAĞLANIR: çift kontrol refraktif
                //   sürprizin tek koruması.
                new("biyometriId", "biyometri_id", "sayi", Baslik: "Biyometri"),
                new("iolModel", "iol_model", "metin", EnFazlaUzunluk: 60, Baslik: "IOL Modeli"),
                new("iolGuc", "iol_guc", "ondalik", Baslik: "IOL Gücü (D)"),
                new("iolAks", "iol_aks", "sayi", Baslik: "IOL Aks"),
                new("sureDk", "sure_dk", "sayi", Baslik: "Süre (dk)"),
                new("intraopKomplikasyon", "intraop_komplikasyon", "kod",
                    KodListesi: "goz.komplikasyon", Baslik: "İntraop Komplikasyon"),
                new("teknik", "teknik", "metin", Baslik: "Teknik", EnFazlaUzunluk: 1200),
                new("ameliyatNotu", "ameliyat_notu", "metin", Baslik: "Ameliyat Notu", EnFazlaUzunluk: 4000),
                new("patolojiGonderildi", "patoloji_gonderildi", "mantik",
                    Baslik: "Patolojiye gönderildi"),
                new("preopChecklistTamam", "preop_checklist_tamam", "mantik",
                    Baslik: "Preop kontrol listesi tamam"),
            }, SubeKolonu: null, LogTabloId: LogGozIslemDetay, Baslik: "Ameliyat", TekSatir: true),

            // TIME-OUT / PREOP KONTROL: maddeler işlem türüne göre üretilir;
            //   "yapıldı" demek de "yapılmadı" demek de kayıtsız kalmasın.
            new("kontrolListesi", "public.goz_ameliyat_kontrol", "islem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("madde", "madde", "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Madde"),
                new("durum", "durum", "kod", SabitKodlar: new Dictionary<string, string>
                    { ["0"] = "Bekliyor", ["1"] = "Tamam", ["2"] = "Uygulanamaz" }, Baslik: "Durum"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("notMetin", "not_metin", "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, SubeKolonu: null, Sirala: "id", LogTabloId: LogGozIslemDetay,
               Baslik: "Kontrol Listesi"),

            new("malzemeler", "public.goz_islem_malzeme", "islem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "kod", AramaKaynagi: "hizmet",
                    KodTablosu: "public.v_stok_lookup", Baslik: "Malzeme"),
                new("adet", "adet", "ondalik", Baslik: "Adet"),
                // Seri/lot IOL ve intravitreal ilaçta ZORUNLU izdir: UTS
                //   bildirimi ve geri çağırma bununla yapılır.
                new("seriLotId", "seri_lot_id", "sayi", Baslik: "Seri / Lot"),
            }, SubeKolonu: null, Sirala: "id", LogTabloId: LogGozIslemDetay,
               Baslik: "Malzeme"),
        });

    // ===================================================== gözlük reçetesi ====
    private static KartTanimi GozGozlukReceteKarti() => new(
        Ad: "goz-gozluk-recete",
        YetkiKodu: "goz.recete",
        Tablo: "public.goz_gozluk_recetesi",
        LogTabloId: LogGozGozlukRecete,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,   // Taslak
            ["tur"] = (short)1,     // Uzak
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // MUAYENE BAGI ARKA PLANDA (Gizli): kayit bir muayeneden
            //   dogduysa hangi muayene oldugu KAYDEDILIR - ekranda ham
            //   id gostermenin degeri yok, ama bagin kaybolmasinin
            //   bedeli var: "bu goruntulemeyi kim, hangi muayenede
            //   istedi" sorusu sonra cevapsiz kalir. Muayene kartindaki
            //   kisayol bu alani URL ile doldurur.
            new("muayeneId", "muayene_id", "sayi", Gizli: true),
            new("receteNo", "recete_no", "metin", Yazilabilir: false, EnFazlaUzunluk: 20,
                Baslik: "Reçete No", Grup: "Genel"),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Genel"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Hekim", Grup: "Genel"),
            new("tur", "tur", "kod", KodListesi: "goz.gozluk_tur", Baslik: "Tür", Grup: "Genel"),
            new("durum", "durum", "kod", KodListesi: "goz.recete_durum",
                Baslik: "Durum", Grup: "Genel"),
            // GEÇERLİLİK: refraksiyon değişir; süresiz reçete yıllar sonra
            //   yanlış camla gelen hasta demektir.
            new("gecerlilikBitis", "gecerlilik_bitis", "tarih",
                Baslik: "Geçerlilik Bitişi", Grup: "Genel"),

            // OD VE OS TEK GRUPTA, ALT ALTA (mockup goz_gozluk_recetesi.html
            //   `.odos`): reçete optikte iki gözün DEĞERLERİ KARŞILAŞTIRILARAK
            //   okunur. Ayrı iki sekmeye koyulduğunda "sağ -2,00 sol -1,75" gibi
            //   tek bakışta görülmesi gereken fark, sekme değiştirerek
            //   aranıyordu. Alan sırası OD dörtlüsü + OS dörtlüsü: dört sütunlu
            //   ızgarada iki göz kendiliğinden hizalı iki satır olur.
            new("odSph", "od_sph", "ondalik", Baslik: "OD Sph", Grup: "Reçete (OD / OS)"),
            new("odCyl", "od_cyl", "ondalik", Baslik: "OD Cyl", Grup: "Reçete (OD / OS)"),
            new("odAks", "od_aks", "sayi", Baslik: "OD Aks", Grup: "Reçete (OD / OS)"),
            new("odAdd", "od_add", "ondalik", Baslik: "OD Add", Grup: "Reçete (OD / OS)"),
            new("osSph", "os_sph", "ondalik", Baslik: "OS Sph", Grup: "Reçete (OD / OS)"),
            new("osCyl", "os_cyl", "ondalik", Baslik: "OS Cyl", Grup: "Reçete (OD / OS)"),
            new("osAks", "os_aks", "sayi", Baslik: "OS Aks", Grup: "Reçete (OD / OS)"),
            new("osAdd", "os_add", "ondalik", Baslik: "OS Add", Grup: "Reçete (OD / OS)"),
            // Prizma ve PD günlük reçetede çoğu zaman boş: dört sütunun
            //   ritmini bozmasınlar diye ikinci sıraya alındı.
            new("odPrizma", "od_prizma", "ondalik", Baslik: "OD Prizma", Grup: "Reçete (OD / OS)"),
            new("odPd", "od_pd", "ondalik", Baslik: "OD PD", Grup: "Reçete (OD / OS)"),
            new("osPrizma", "os_prizma", "ondalik", Baslik: "OS Prizma", Grup: "Reçete (OD / OS)"),
            new("osPd", "os_pd", "ondalik", Baslik: "OS PD", Grup: "Reçete (OD / OS)"),

            new("pdYakin", "pd_yakin", "ondalik", Baslik: "Yakın PD", Grup: "Cam & Optik"),
            new("camMalzeme", "cam_malzeme", "kod", KodListesi: "goz.cam_malzeme",
                Baslik: "Cam Malzemesi", Grup: "Cam & Optik"),
            new("tasarim", "tasarim", "metin", EnFazlaUzunluk: 60,
                Baslik: "Tasarım", Grup: "Cam & Optik"),
            new("notOptik", "not_optik", "metin", EnFazlaUzunluk: 600,
                Baslik: "Optiğe Not", Grup: "Cam & Optik"),
            // SGK cam/çerçeve hakkı: hastaya "hakkınız var mı" sorusunu
            //   optikte sordurmamak için reçetede durur.
            new("sgkHak", "sgk_hak", "mantik", Baslik: "SGK hakkı var", Grup: "Cam & Optik"),
            new("optikTarafId", "optik_taraf_id", "kod", KodTablosu: "public.v_cari_lookup",
                Baslik: "Anlaşmalı Optik", Grup: "Cam & Optik"),
            new("optikTeslim", "optik_teslim", "tarih", Baslik: "Teslim", Grup: "Cam & Optik"),
        });

    // ===================================================== hastalık takibi ====
    private static KartTanimi GozTakipKarti() => new(
        Ad: "goz-takip",
        YetkiKodu: "goz.takip",
        Tablo: "public.goz_hastalik_takip",
        LogTabloId: LogGozTakip,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["progresyonDurum"] = (short)1,   // Stabil
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Takip"),
            // Takip GÖZ BAZLIDIR: aynı hastanın iki gözü farklı evrede olabilir
            //   ve hedef GİB de farklı konur.
            new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari,
                Baslik: "Göz", Grup: "Takip"),
            new("hastalik", "hastalik", "kod", Zorunlu: true, KodListesi: "goz.hastalik",
                Baslik: "Hastalık", Grup: "Takip"),
            new("icdKod", "icd_kod", "metin", EnFazlaUzunluk: 10, Baslik: "ICD-10", Grup: "Takip"),
            new("evre", "evre", "metin", EnFazlaUzunluk: 30, Baslik: "Evre", Grup: "Takip"),
            new("baslangic", "baslangic", "tarih", Baslik: "Başlangıç", Grup: "Takip"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Takip Hekimi", Grup: "Takip"),
            new("durum", "durum", "mantik", Baslik: "Aktif", Grup: "Takip"),

            // HEDEF GİB glokomun tedavi ölçütüdür: "GİB 18" tek başına iyi ya
            //   da kötü değildir, hedefe göre okunur.
            new("hedefGib", "hedef_gib", "ondalik", Baslik: "Hedef GİB", Grup: "Protokol"),
            new("kontrolPeriyotAy", "kontrol_periyot_ay", "sayi",
                Baslik: "Kontrol Periyodu (ay)", Grup: "Protokol"),
            new("gaPeriyotAy", "ga_periyot_ay", "sayi",
                Baslik: "Görme Alanı (ay)", Grup: "Protokol"),
            new("octPeriyotAy", "oct_periyot_ay", "sayi", Baslik: "OCT (ay)", Grup: "Protokol"),
            new("sonrakiKontrol", "sonraki_kontrol", "tarih",
                Baslik: "Sonraki Kontrol", Grup: "Protokol"),

            new("progresyonDurum", "progresyon_durum", "kod", KodListesi: "goz.progresyon",
                Baslik: "Progresyon", Grup: "Değerlendirme"),
            new("sonAnaliz", "son_analiz", "zaman", Baslik: "Son Analiz", Grup: "Değerlendirme"),
            new("tedaviOzeti", "tedavi_ozeti", "metin",
                Baslik: "Tedavi Özeti", Grup: "Değerlendirme", EnFazlaUzunluk: 2000),
        });

    // ============================================================= cihazlar ====
    /// <summary>
    /// DİKTE SÖZLÜĞÜ KARTI (705). Komut satırının "eylem" alanı teknik bir
    /// dizedir (<c>hedef:fundus.disk</c>, <c>goz:1</c>, <c>noktalama:.</c>):
    /// sözlüğü yöneten kişi ne yazacağını bilmeli diye ipucu alanda duruyor.
    /// </summary>
    private static KartTanimi DikteTerimKarti() => new(
        Ad: "dikte-terim",
        YetkiKodu: "goz.dikte_sozluk",
        Tablo: "public.dikte_terim",
        LogTabloId: LogDikteTerim,
        // Sözlük kurum geneli: şube damgası yazılmaz (liste de süzmüyor).
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,      // Terim
            ["kapsam"] = (short)1,   // Kurum
            ["aktif"] = (short)1,
            ["sira"] = 500,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("tur", "tur", "kod", Zorunlu: true, SabitKodlar: DikteTurKodlari,
                Baslik: "Tür", Grup: "Genel"),
            new("kapsam", "kapsam", "kod", Zorunlu: true, KodListesi: "dikte.kapsam",
                Baslik: "Kapsam", Grup: "Genel"),
            // Kişisel terim kime ait: boşsa kurum sözlüğüdür.
            new("kullaniciId", "kullanici_id", "kod",
                KodTablosu: "public.v_kullanici_lookup",
                Baslik: "Kullanıcı", Grup: "Genel"),
            new("soylenen", "soylenen", "metin", Zorunlu: true, EnFazlaUzunluk: 80,
                Baslik: "Söyleniş", Grup: "Genel"),
            new("yazilan", "yazilan", "metin", EnFazlaUzunluk: 120,
                Baslik: "Yazılan", Grup: "Genel"),
            new("eylem", "eylem", "metin", EnFazlaUzunluk: 60,
                Baslik: "Komut eylemi", Grup: "Genel"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Genel"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Genel"),
        });

    private static KartTanimi GozCihazKarti() => new(
        Ad: "goz-cihaz",
        YetkiKodu: "goz.cihaz",
        Tablo: "public.goz_cihaz",
        LogTabloId: LogGozCihaz,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1,
            ["protokol"] = (short)2,   // Seri metin
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // GRUP ADI "Genel" (Kimlik DEĞİL): "Kimlik" adlı grup kartın üst
            //   şeridine çıkar ve SEKME OLARAK ÇİZİLMEZ (kartSekmeleri.ts
            //   KIMLIK_GRUP) - o zaman kartta tek sekme kalır ve sekme şeridi
            //   hiç görünmez. Kullanıcı kartında da aynı tuzağa düşülmüştü.
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Genel"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Cihaz Adı", Grup: "Genel"),
            new("tur", "tur", "kod", Zorunlu: true, KodListesi: "goz.cihaz_tur",
                Baslik: "Tür", Grup: "Genel"),
            new("uretici", "uretici", "metin", EnFazlaUzunluk: 80, Baslik: "Üretici", Grup: "Genel"),
            new("model", "model", "metin", EnFazlaUzunluk: 80, Baslik: "Model", Grup: "Genel"),
            new("seriNo", "seri_no", "metin", EnFazlaUzunluk: 60, Baslik: "Seri No", Grup: "Genel"),
            // Demirbaş bağı: cihaz hem klinik kaynak hem sabit kıymet. Bakım,
            //   amortisman ve garanti orada; ölçüm burada.
            // Demirbaş bağı SAYI olarak durur: demirbaş için lookup görünümü
            //   yok ve göz modülü için bir tane açmak, aynı listeyi ikinci kez
            //   tanımlamak olurdu - bağ kurulduğunda ortak lookup eklenecek.
            new("demirbasId", "demirbas_id", "sayi", Baslik: "Demirbaş", Grup: "Genel"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Genel"),

            new("protokol", "protokol", "kod", KodListesi: "goz.cihaz_protokol",
                Baslik: "Protokol", Grup: "Bağlantı"),
            new("baglanti", "baglanti", "metin", EnFazlaUzunluk: 120,
                Baslik: "Bağlantı (AE / COM / klasör)", Grup: "Bağlantı"),
            new("mwl", "mwl", "mantik", Baslik: "DICOM çalışma listesi (MWL)", Grup: "Bağlantı"),
            new("sonMesaj", "son_mesaj", "zaman", Yazilabilir: false,
                Baslik: "Son Mesaj", Grup: "Bağlantı"),
            // ÖLÇÜM EŞLEMESİ olmadan gelen değer "ham" kalır: yanlış eşlenmiş
            //   bir RNFL değeri, sessizce yanlış trend üretir.
            new("olcumEsleme", "olcum_esleme", "json",
                Baslik: "Ölçüm Eşlemesi (JSON)", Grup: "Bağlantı", EnFazlaUzunluk: 4000),
        });
}

using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// STANDART ROLLER (712, kullanıcı: "standart rolleri kur düğmesini ekle").
/// Kurum tipine göre hazır rol şablonları (Kayıt Kabul, Hekim, Hemşire,
/// Muhasebe, Diş Hekimi, Radyolog, Lab Teknisyeni…). Şablon = rol + yetki
/// kalıpları (yetki kodu deseni × gör/ekle/değiştir/sil). Kurulum sonrası
/// yönetici rolleri tek tek elle açıp 150 yetkiyi işaretliyordu; tipin
/// standart seti tek tıkla kurulur, sonra yetki matrisinden inceltilir.
///
/// Kurallar: var olan rol (aynı kod) EZİLMEZ - yalnız `guncelle` istenirse
/// yetkileri şablona çekilir; rol tüm aktif şubelere yazma hakkıyla bağlanır;
/// modülü kapalı kurumda o modülün yetkileri yine yazılır (modül açılınca
/// rol hazır olsun), ekranda görünmezler (`fn_kurum_modul_acik`).
/// </summary>
public static class StandartRolUclari
{
    /// <summary>Yetki kalıbı: `desen` SQL LIKE (yetki.kod), `tam` = kodların birebir listesi.</summary>
    private sealed record Kural(string Desen, bool Gor = true, bool Ekle = false, bool Degistir = false, bool Sil = false);
    private sealed record Sablon(string Kod, string Ad, string Amac, string[] Tipler,
                                Kural[] Kurallar, short PortalTuru = 0);

    private const string TUM = "*";
    private static readonly string[] Klinik = ["muayenehane", "dal_goz", "dal_ftr", "goruntuleme", "lab", "goruntuleme_lab", "dis", "tip_merkezi", "hastane", "osgb"];
    /// <summary>
    /// HER KURULUMDA olan roller (795): muhasebe, yonetim goruntuleyici, kalite,
    /// bilgi islem ve iskonto kademeleri is koluna bagli degildir - ERP
    /// kurulumunda da aynen gecerli. Klinik listesine 'erp' eklenmis hali.
    /// </summary>
    private static readonly string[] Hepsi = [.. Klinik, "erp"];

    // Her rolde: ana sayfa, mesaj, görev, dökümler, AI rehber (gör).
    private static readonly Kural[] Ortak = [new("panel"), new("mesaj", true, true, true), new("gorev", true, true, true), new("dokum"), new("ai"), new("ai.rehber"), new("dokuman", true, true)];
    private static Kural[] K(params Kural[] k) => [.. Ortak, .. k];
    /// <summary>
    /// PORTAL ROLU (795): `Ortak` seti VERILMEZ. Gorev, mesaj, dokuman ve ana
    /// sayfa kurum ICI ekranlardir - dis kurumun personel gorev listesinde,
    /// kurum panosunda isi yok. Ustelik bu ekranlarin verisi liste/kart
    /// disindaki uclardan da geliyor; portal kapsami oralara henuz baglanmadi.
    /// Portal rolune yalniz kapsami YAZILMIS kaynaklar verilir.
    /// </summary>
    private static Kural[] P(params Kural[] k) => [new("ai.rehber"), .. k];
    private static Kural T(string d) => new(d, true);                       // gör
    private static Kural Y(string d) => new(d, true, true, true);           // gör+ekle+değiştir
    private static Kural H(string d) => new(d, true, true, true, true);     // hepsi
    private static Kural A(string d) => new(d, true);                        // aksiyon (tur 1): gör = izin

    private static readonly Kural[] HekimTemel =
    [
        Y("muayene"), T("hasta"), Y("randevu"), T("belge"), T("belge_satir"), T("taraf"), Y("lab"), T("lab.sonuc"),
        Y("radyoloji-istem"), A("rad.istem_ac"), A("rad.istem_iptal"), T("radyoloji"), T("katalog"), Y("onam"),
        T("prim.kendi"), Y("medula.recete"), Y("medula.hizmet"), T("medula"), T("hizmet"), T("kurum"), T("klinik_kalite.olgu"),
        T("islem_log"),
    ];
    private static readonly Kural[] KayitKabulTemel =
    [
        Y("hasta"), Y("randevu"), Y("belge"), Y("belge_satir"), Y("taraf"), Y("cari"), T("kurum"), T("hizmet"), T("fiyat_listesi"),
        Y("sigorta"), A("sigorta.provizyon"), A("sigorta.iptal"), Y("medula.provizyon"), T("medula"), Y("kasa_islem"), Y("mali_hareket"),
        T("hesap"), A("kasa.makbuz-yazdir"), Y("onam"), T("bildirim"), T("iskonto_onay"), T("muayene"), Y("aday"),
        // ISKONTO BIRIM BASAMAGI BURADA DEGIL (787, kullanici: "kayıt kabul
        //   (banko) sorumlusu bulamadım, iskonto talebi ilk olarak ona
        //   gitmeyecek miydi"): 785 basamagi `kayit_kabul` rolune vermisti ve
        //   bu, HER BANKO CALISANINI birim onaycisi yapiyordu - talebi acan
        //   kendi talebini onaylayamasa da (783) yanindaki mesai arkadasi
        //   onaylayabiliyordu. Denetim degil karsilikli imza olurdu.
        //   Basamak ayri bir role tasindi: `kayit_kabul_sorumlu`.
    ];

    /// <summary>
    /// BANKO SEFI (787): bankonun yaptigi isin tamami + iskonto talebinin
    /// BIRIM imzasi. Ayri rol, cunku "sorumlu" kadro unvanidir - ekranlar ayni,
    /// imza yetkisi farkli.
    /// </summary>
    private static readonly Kural[] KayitKabulSorumluTemel =
    [
        .. KayitKabulTemel,
        T("belge.iskonto_onay_birim"),
        // Karar veren denetim izini de gormeli (685).
        Y("iskonto_onay"),
        // Banko sefi vardiyayi da kapatir.
        Y("kasa_kapatma"), A("kasa.kapat"), A("kasa.kesinlestir"),
    ];
    private static readonly Kural[] MuhasebeTemel =
    [
        H("belge"), H("belge_satir"), H("cari"), H("taraf"), H("kasa_islem"), H("mali_hareket"), H("hesap"), H("hesap_plani"), H("muhasebe_fis"),
        H("cek_senet"), H("kredi"), H("masraf"), H("masraf_merkezi"), H("kasa_kapatma"), T("kasa_islem_turu"), H("e_belge"), T("ebelge_seri"),
        T("ebelge_xslt"), H("fiyat_listesi"), A("fiyat_listesi.uret"), H("kurum"), T("hasta"), T("hizmet"), Y("medula.fatura"), T("medula"),
        T("medula.ayar"), T("sigorta"), H("prim"), T("doviz_kur"), T("demirbas"), T("stok"), T("islem_log"),
        A("belge.kesinlestir"), A("belge.iptal"), A("belge.donustur"), A("kasa.%"), A("ceksenet.%"), A("ebelge.%"), A("fis.ters-kayit"),
        A("muhasebe.donem-kilitle"), A("kredi.taksit-ode"), A("prim.%"), A("veri.disa-aktar"), A("basvuru.iskonto"),
        // Onay ekraninin denetim izi (685) - muhasebe kararlari GORUR.
        T("iskonto_onay"),
        // TELERADYOLOJI TICARI TARAFI (797): kurum sozlesmesi, tarife ve donem
        //   faturasi muhasebenin isi; calisma listesi degil.
        Y("teleradyoloji.kurum"), Y("teleradyoloji.sozlesme"), A("telerad.faturala"),
        // ISKONTO MALI BASAMAGI BURADA DEGIL (788, 787 ile ayni gerekce):
        //   basamagi `muhasebe` rolune vermek, muhasebedeki HER calisani mali
        //   onayci yapiyordu. Imza kadro unvanina ait: `muhasebe_sorumlu`.
    ];

    /// <summary>
    /// MALI ISLER MUDURU (788): muhasebenin yaptigi isin tamami + iskonto
    /// talebinin MALI imzasi.
    /// </summary>
    private static readonly Kural[] MuhasebeSorumluTemel =
    [
        .. MuhasebeTemel,
        T("belge.iskonto_onay_mali"), Y("iskonto_onay"),
        // TALEP ONAY ZINCIRININ "MALI ISLER" BASAMAGI (738): avans, masraf,
        //   demirbas onarimi ve satinalma odemesi bu imzadan geciyor. Yetki
        //   hicbir sablonda yoktu - basamagin sahibi yalniz sistem
        //   yoneticisiydi ve zincir orada bekliyordu.
        A("ik.avans_onay_mali"), A("ik.masraf_onay_mali"),
        A("demirbas.onarim_onay_mali"), A("satinalma.odeme_onay"),
    ];

    /// <summary>
    /// UST YONETIM (788): mesul mudur / genel mudur - zincirin SON imzasi.
    /// Ekranlari "Yonetim Goruntuleyici" gibi salt okumadir; farki imzadir.
    /// Ayri rol, cunku `rapor_goruntuleyici` bilerek KARAR VERMEYEN roldur.
    /// </summary>
    private static readonly Kural[] UstYonetimTemel =
    [
        T("%"), new("ayar", false), new("rol", false), new("kullanici", false),
        new("sube", false), new("referans", false), new("entegrasyon", false),
        new("dokuman.ozel_nitelikli", false),
        T("belge.iskonto_onay_ust"), Y("iskonto_onay"),
        // ZINCIRIN SON IMZASI (738): `T("%")` aksiyonlari KAPSAMAZ (aksiyon
        //   acikca istenir) - bu yuzden her onay basamagi tek tek yazilir.
        A("ik.izin_onay_ust"), A("ik.avans_onay_ust"), A("ik.masraf_onay_ust"),
        A("satinalma.onay_ust"), A("demirbas.onarim_onay_ust"), A("dokuman.onay"),
    ];

    /// <summary>
    /// ŞABLON -> KURUM MODÜLÜ (785, kullanici: "bir de kurum profiline gore
    /// gelebilsin"). Kurum tipi "hangi is kolu" sorusunu, modul "bu kurulumda
    /// acik mi" sorusunu cevaplar: tip merkezi olup dis modulu kapali olan
    /// kuruma "Dis Hekimi" rolu onermek, kullanmayacagi bir rolu listeye
    /// koymaktir.
    ///
    /// Haritada OLMAYAN sablon her kurulumda gecerlidir (kayit kabul, muhasebe,
    /// yonetim gorutuleyici, bilgi islem...): onlar modulden bagimsiz.
    /// </summary>
    private static readonly Dictionary<string, string> SablonModul = new(StringComparer.Ordinal)
    {
        ["hekim"] = "muayene", ["hemsire"] = "muayene",
        // Cagri merkezi RANDEVU modulune bagli: randevu kapaliysa telefonla
        //   randevu alacak bir ekip de yoktur.
        ["cagri_ajani"] = "randevu", ["cagri_sorumlu"] = "randevu",
        // medula_sorumlu BURAYA YAZILMAZ: "medula" bir `kurum_modul` kodu
        //   degil (SGK baglantisi entegrasyon ayari). Haritaya konulsa
        //   modul hicbir kurumda "acik" gorunmez ve rol HIC onerilmez.
        //   Hangi kurumda cikacagini sablonun `Tipler` listesi belirler.
        ["dis_hekimi"] = "dis", ["dis_asistan"] = "dis",
        ["tedavi_danismani"] = "dis", ["dis_lab_sorumlu"] = "dis",
        ["goz_hekimi"] = "goz", ["optometrist"] = "goz", ["goz_teknisyen"] = "goz",
        ["ftr_uzmani"] = "ftr", ["fizyoterapist"] = "ftr",
        ["radyolog"] = "radyoloji", ["rad_teknisyen"] = "radyoloji",
        ["teleradyoloji_hekim"] = "teleradyoloji",
        ["lab_uzmani"] = "lab", ["lab_teknisyen"] = "lab",
        ["numune_kabul"] = "lab", ["dis_istem_kurumu"] = "lab",
        ["eczane_depo"] = "eczane",
        ["yatan_hemsire"] = "yatan_hasta", ["yatis_ofisi"] = "yatan_hasta",
        ["isyeri_hekimi"] = "isg", ["isg_uzmani"] = "isg", ["dsp"] = "isg",
        ["osgb_sekreter"] = "isg", ["firma_yetkilisi"] = "isg",
        // ERP rolleri de kendi modullerine bagli (795): stok modulu kapaliysa
        //   depo sorumlusu onerilmez.
        ["erp_satis"] = "erp_satis", ["erp_alis"] = "satinalma",
        ["erp_depo"] = "stok", ["erp_uretim"] = "uretim",
        // `erp_servis` MODULSUZ (831): `servis` modulu `kurum_tipi_modul`
        //   matrisinde HIC tanimli degil - hicbir tipte "acik" sayilmadigi
        //   icin rol her kurulumda listeden dusuyordu ve demirbas onariminin
        //   teknik imzasi sahipsiz kaliyordu. Ekranlar zaten `servis` /
        //   `demirbas` yetkileriyle korunuyor.
        ["erp_ik"] = "ik", ["ik_personel"] = "ik",
        // Eczaci ve teknisyen eczane modulune bagli; acil hekimi acile.
        ["eczaci"] = "eczane", ["eczane_teknisyen"] = "eczane",
        ["acil_hekimi"] = "acil",
        // Kalite gorevlisi, bilgi islem personeli ve birim amiri MODULSUZ:
        //   kalite/kullanici yonetimi/onay zinciri her kurulumda var.
    };

    private static readonly Sablon[] Sablonlar =
    [
        new("kayit_kabul", "Kayıt Kabul / Banko", "Hasta kaydı, randevu, başvuru, provizyon, fiş ve tahsilat.", Klinik, K(KayitKabulTemel)),
        new("kayit_kabul_sorumlu", "Kayıt Kabul Sorumlusu (Banko Şefi)",
            "Bankonun tüm işleri + iskonto talebinin birim imzası, vardiya/kasa kapatma.", Klinik,
            K(KayitKabulSorumluTemel)),
        // AD "Doktor" (790, kullanici: "Hekim rename Doktor") - KOD `hekim`
        //   kalir: basamaklar, sablonlar ve menu suzgeci koda bakiyor.
        // CAGRI MERKEZI (791, kullanici: "Çağrı Merkezi Ajanı ve Çağrı Merkezi
        //   Sorumlusu da ekle"): telefonla randevu alan ekip. Ajan randevu ve
        //   hasta kaydi acar; HASTANIN PARASINI GORMEZ (belge/kasa yetkisi
        //   yok) - telefonda borc konusmak bankonun isidir.
        new("cagri_ajani", "Çağrı Merkezi Ajanı",
            "Telefonla randevu alma/değiştirme, hasta ve aday kaydı, hekim uygunluğu.",
            Klinik,
            K(Y("randevu"), T("randevu.plan"), Y("hasta"), Y("aday"), T("firsat"),
              T("kurum"), T("hizmet"), T("bildirim"), T("muayene"))),
        new("cagri_sorumlu", "Çağrı Merkezi Sorumlusu",
            "Ajanların işi + randevu iptali, hatırlatma şablonları, kuyruk ve günlük takibi.",
            Klinik,
            K(H("randevu"), T("randevu.plan"), Y("hasta"), H("aday"), Y("firsat"),
              T("kurum"), T("hizmet"), Y("bildirim"), Y("bildirim_sablon"),
              T("muayene"), T("islem_log"))),
        new("hekim", "Doktor", "Muayene, tanı, istem, reçete ve rapor; kendi hakedişi.", ["muayenehane", "tip_merkezi", "hastane"], K(HekimTemel)),
        new("hemsire", "Hemşire", "Vital, enjeksiyon, pansuman, numune; muayene kaydına yardım.", ["tip_merkezi", "hastane", "dal_ftr"],
            K(T("hasta"), Y("muayene"), T("randevu"), Y("lab.numune"), T("lab"), Y("onam"), T("katalog"), T("belge"))),
        // ---- TIBBI YONETIM (kullanici: "Başhemşire ve Başhekim ve Başhekim
        //      Yardımcısı ekle rol olarak").
        //
        //      UCU DE HEKIM/HEMSIRENIN ISINI YAPMAYA DEVAM EDER, USTUNE
        //      KADRO VE AKIS YONETIMI ALIR. Ayrimi "kimin isini imzaliyor"
        //      belirliyor:
        //        Bashekim            : tibbi hizmetin tamami + hekim kadrosu
        //                              + klinik kalite hedefi + prim onayi
        //        Bashekim Yardimcisi : ayni ekranlar, KURUM CAPINDA IMZA YOK
        //                              (prim onayi ve kalite kesinlestirme
        //                              bashekimde kalir)
        //        Bashemsire          : hemsire kadrosu, calisma plani, yatan
        //                              ve ameliyathane hemsirelik akisi
        //
        //      Ucu de BIRIM AMIRIDIR: izin/avans/masraf zincirinin ilk imzasi
        //      (738, sahip_turu 3 - kimin talebini imzalayacagini kadro agaci
        //      soyler, rol yalnizca "imzalayabilir" der).
        new("bashekim", "Başhekim",
            "Tıbbi hizmetin tamamı: hekim kadrosu ve çalışma planı, poliklinik/yatan/ameliyathane akışı, klinik kalite hedefi, prim onayı ve ekibinin izin imzası.",
            ["tip_merkezi", "hastane"],
            K([.. HekimTemel,
               // Kadro ve plan: kimin hangi gun calistigi baShekimin isi.
               // Bölüm/Görev ekranı da `personel` yetkisiyle açılır (ayrı kod yok).
               Y("personel"), Y("randevu.plan"),
               // Klinik akisin tamami - yatan, ameliyathane, acil.
               Y("yatan"), A("yatan.kabul"), A("yatan.taburcu"), A("yatan.nakil"),
               A("yatan.order.imza"), Y("ameliyathane"), Y("ameliyathane.plan"),
               Y("ameliyathane.talep"), T("ameliyathane.salon"),
               A("ameliyathane.not_imzala"), A("ameliyathane.iptal"),
               T("acil"), T("acil.pano"),
               // Kalite: hedefi belirleyen ve donemi kesinlestiren imza.
               H("klinik_kalite"), H("klinik_kalite.%"), A("klinik_kalite.%"),
               // Hakedis: hekim primini onaylayan tibbi imza.
               T("prim"), A("prim.onayla"),
               // Birim amiri basamagi.
               T("ik.izin"), T("ik.avans"), T("ik.masraf"),
               A("ik.izin_onay_amir"), A("ik.avans_onay_amir"), A("ik.masraf_onay_amir"),
               T("dokuman.onayla"), A("dokuman.onay")])),
        new("bashekim_yardimcisi", "Başhekim Yardımcısı",
            "Başhekimin ekranları; kurum çapında imza yok - prim onayı ve kalite dönemini kesinleştirme başhekimde kalır.",
            ["tip_merkezi", "hastane"],
            K([.. HekimTemel,
               // Bölüm/Görev ekranı da `personel` yetkisiyle açılır (ayrı kod yok).
               Y("personel"), Y("randevu.plan"),
               Y("yatan"), A("yatan.kabul"), A("yatan.taburcu"), A("yatan.nakil"),
               A("yatan.order.imza"), Y("ameliyathane"), Y("ameliyathane.plan"),
               Y("ameliyathane.talep"), T("ameliyathane.salon"),
               T("acil"), T("acil.pano"),
               // KALITE: veriyi gorur ve hesaplatir; HEDEF ve KESINLESTIRME
               //   bashekimin imzasi (ayni gerekce Kalite Gorevlisi'nde de var).
               Y("klinik_kalite"), Y("klinik_kalite.olgu"), T("klinik_kalite.donem"),
               A("klinik_kalite.hesapla"),
               T("prim.kendi"),
               T("ik.izin"), T("ik.avans"), T("ik.masraf"),
               A("ik.izin_onay_amir"), A("ik.avans_onay_amir"), A("ik.masraf_onay_amir")])),
        new("bashemsire", "Başhemşire",
            "Hemşire kadrosu ve çalışma planı, yatan hasta ve ameliyathane hemşirelik akışı, sarf ve sterilizasyon; ekibinin izin imzası.",
            ["tip_merkezi", "hastane"],
            K(T("hasta"), Y("muayene"), T("randevu"), Y("randevu.plan"),
              Y("lab.numune"), T("lab"), T("lab.sonuc"), Y("onam"), T("katalog"), T("belge"),
              // Yatan ve ameliyathane: hemsirelik akisinin kendisi.
              Y("yatan"), Y("yatan.izlem"), Y("yatan.order"), T("yatan.yatak"),
              Y("ameliyathane"), Y("ameliyathane.plan"), Y("ameliyathane.salon"),
              T("ameliyathane.talep"), A("ameliyathane.stok_dus"),
              // Kadro: hemsire kadrosu ve nobet plani.
              Y("personel"),
              // Sarf ve sterilizasyon deposu.
              Y("stok"), T("depo"), T("uts"),
              T("klinik_kalite.olgu"),
              // Birim amiri basamagi.
              T("ik.izin"), T("ik.avans"), T("ik.masraf"),
              A("ik.izin_onay_amir"), A("ik.avans_onay_amir"), A("ik.masraf_onay_amir"))),
        new("muhasebe", "Muhasebe / Finans", "Fatura, kasa-banka, dönem sonlandırma, kesinti ve itiraz.", Hepsi, K(MuhasebeTemel)),
        new("muhasebe_sorumlu", "Mali İşler Müdürü",
            "Muhasebenin tüm işleri + iskonto talebinin mali imzası.", Hepsi,
            K(MuhasebeSorumluTemel)),
        new("ust_yonetim", "Üst Yönetim (Mesul Müdür / Genel Müdür)",
            "Salt okuma dökümler + iskonto zincirinin son imzası.", Hepsi,
            K(UstYonetimTemel)),
        new("vezne", "Vezne", "Tahsilat, makbuz, fatura kapatma.", ["tip_merkezi", "hastane"],
            K(Y("kasa_islem"), Y("mali_hareket"), T("hesap"), Y("kasa_kapatma"), A("kasa.kapat"), A("kasa.makbuz-yazdir"), A("kasa.kesinlestir"), T("belge"), T("hasta"), T("cari"))),
        new("rapor_goruntuleyici", "Yönetim Görüntüleyici", "Kurum sahibi / mesul müdür: salt okuma dökümler ve günlük.", Hepsi,
            K(T("%"), new("ayar", false), new("rol", false), new("kullanici", false), new("sube", false), new("referans", false), new("entegrasyon", false), new("dokuman.ozel_nitelikli", false))),
        new("kalite", "Kalite Sorumlusu", "Hepsi kalite göstergeleri, dönem hesabı, doküman onayı; klinik ekranlar salt okuma.", Hepsi,
            K(H("klinik_kalite"), H("klinik_kalite.%"), A("klinik_kalite.%"), Y("dokuman.onayla"),
              // KUYRUGU GORMEK KARAR VERMEK DEGIL: `dokuman.onayla`
              //   ekrandir (tur 0), karar `dokuman.onay` aksiyonudur -
              //   kalite rolu kuyrugu goruyor ama imzalayamiyordu.
              A("dokuman.onay"), T("islem_log"), T("hasta"), T("muayene"), T("lab"), T("radyoloji"), T("yatan"))),
        // TELERADYOLOJI IDARI (797): kurum tanimi, sozlesme, donem faturasi -
        //   isin klinik tarafi degil TICARI tarafi. Muhasebe rolune eklendi
        //   (asagida MuhasebeTemel), burada yalniz sablon sirasi korunuyor.
        new("medula_sorumlu", "Medula Sorumlusu", "SGK kuyruğu, hizmet kaydı, fatura, dönem sonlandırma, kesinti.", ["tip_merkezi", "hastane", "dal_goz", "dal_ftr", "dis", "goruntuleme", "goruntuleme_lab"],
            K(H("medula"), H("medula.%"), A("medula.donem"), T("kurum"), T("belge"), T("hasta"), T("hizmet"))),
        new("bilgi_islem", "Bilgi İşlem Sorumlusu", "Kullanıcı, rol ve şube tanımı, ayarlar, entegrasyon ve cihaz hesapları, işlem günlüğü; hasta verisi görmez.", Hepsi,
            K(H("kullanici"), A("kullanici.parola-sifirla"), H("rol"), H("sube"), H("ayar"), H("referans"), H("entegrasyon"), H("cihaz"), A("cihaz.isle"),
              H("kod_liste"), H("numara_sablonu"), H("bildirim_sablon"), Y("bildirim"), T("islem_log"), A("log.geri-al"), H("dokuman"), H("katalog"),
              T("medula.ayar"), A("sigorta.ayar"), H("goz.cihaz"), H("lab.cihaz"), H("ebelge_seri"), H("ebelge_xslt"), A("veri.iceri-al"), A("veri.disa-aktar"))),
        // ---- diş
        new("dis_hekimi", "Diş Hekimi", "Odontogram, tedavi planı, seans, yapıldı ve ücretlendirme.", ["dis", "tip_merkezi", "hastane"],
            K([.. HekimTemel, H("dis"), H("dis.%"), A("dis.plan.onayla"), A("dis.seans.bitir"), A("dis.plan.fiyat_degistir"), T("dis.unit")])),
        new("dis_asistan", "Diş Asistanı", "Seans sarf ve sterilizasyon, hekim adına odontogram girişi, lab iş emri.", ["dis"],
            K(Y("dis.hasta"), Y("dis.seans"), Y("dis.lab"), Y("dis.muayene"), T("dis"), T("dis.plan"), T("hasta"), T("randevu"), T("stok"))),
        new("tedavi_danismani", "Tedavi Danışmanı", "Proforma sunma, hasta onayı, ödeme planı ve tahsilat takibi.", ["dis"],
            K(Y("dis.plan"), A("dis.plan.onayla"), H("dis.odeme"), T("dis"), T("dis.hasta"), T("hasta"), Y("randevu"), Y("kasa_islem"), T("belge"), T("fiyat_listesi"))),
        new("dis_lab_sorumlu", "Lab Sorumlusu (Protez)", "Lab iş emirleri, kurye, aşama takibi, lab faturası eşleme.", ["dis"],
            K(H("dis.lab"), T("dis"), T("dis.unit"), T("dis.hasta"), T("hasta"), T("cari"))),
        // ---- göz
        new("goz_hekimi", "Göz Hekimi", "Göz muayenesi, görüntüleme değerlendirme, işlem, reçete, takip.", ["dal_goz", "tip_merkezi", "hastane"],
            K([.. HekimTemel, H("goz"), H("goz.%"), A("goz.goruntuleme.degerlendir"), A("goz.islem.uygula")])),
        new("optometrist", "Optometrist / Refraksiyonist", "Ön tetkik, ölçüm, gözlük-lens reçetesi hazırlığı.", ["dal_goz"],
            K(Y("goz.on_tetkik"), Y("goz.recete"), Y("goz.goruntuleme"), T("goz"), T("goz.muayene"), T("hasta"), T("randevu"))),
        new("goz_teknisyen", "Göz Teknisyeni", "Görüntüleme (OCT, FFA), cihaz, ön tetkik.", ["dal_goz"],
            K(Y("goz.on_tetkik"), Y("goz.goruntuleme"), T("goz.cihaz"), T("goz"), Y("cihaz"), A("cihaz.isle"), T("hasta"), T("randevu"))),
        // ---- FTR
        new("ftr_uzmani", "FTR Uzmanı", "Değerlendirme, program, seans onayı.", ["dal_ftr"], K(HekimTemel)),
        new("fizyoterapist", "Fizyoterapist", "Seans uygulama ve seans notu.", ["dal_ftr", "tip_merkezi", "hastane"],
            K(Y("muayene"), T("hasta"), Y("randevu"), T("belge"), Y("onam"), T("prim.kendi"))),
        // ---- görüntüleme
        new("radyolog", "Radyolog", "Rapor yazma ve onay, sonuç teslimi.", ["goruntuleme", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(H("radyoloji"), H("radyoloji-istem"), A("rad.rapor_yaz"), A("rad.rapor_onayla"), A("rad.teslim"), A("rad.istem_iptal"), T("hasta"), T("katalog"), T("muayene"), T("prim.kendi"),
              // TELERADYOLOJI (797): kurumun kendi radyologu dis kurum
              //   isteklerini de okur - calisma listesi ve atama onda.
              Y("teleradyoloji"), A("telerad.ata"), A("telerad.teslim"))),
        new("rad_teknisyen", "Radyoloji Teknisyeni", "Çekim, cihaz, sonuç teslimi.", ["goruntuleme", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(Y("radyoloji"), Y("radyoloji-istem"), Y("cihaz"), A("cihaz.isle"), A("rad.teslim"), T("hasta"), T("randevu"))),
        // TELERADYOLOJI HEKIMI (797 ile genisledi): calisma listesi + atama +
        //   raporlama. Kurum/sozlesme ekranlari IDARI - onda yok.
        new("teleradyoloji_hekim", "Teleradyoloji Hekimi (dış)", "Teleradyoloji çalışma listesi, rapor yazma ve onay; kayıt/kabul görmez.", ["goruntuleme", "goruntuleme_lab"],
            K(T("radyoloji"), T("radyoloji-istem"), A("rad.rapor_yaz"), A("rad.rapor_onayla"),
              Y("teleradyoloji"), A("telerad.ata"), A("telerad.teslim"))),
        // ---- laboratuvar
        new("lab_uzmani", "Lab Uzmanı", "Sonuç onayı, kalite kontrol serbest bırakma, katalog.", ["lab", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(H("lab"), H("lab.%"), A("lab.onay"), A("lab.kk.onay"), T("hasta"), T("katalog"), T("cihaz"), T("prim.kendi"))),
        new("lab_teknisyen", "Lab Teknisyeni", "Numune, cihaz, sonuç girişi, iç-dış kalite kontrol.", ["lab", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(Y("lab"), Y("lab.numune"), Y("lab.sonuc"), Y("lab.kk"), Y("lab.cihaz"), Y("lab.kultur"), T("lab.mikro"), T("lab.tetkik"), Y("cihaz"), A("cihaz.isle"), T("hasta"))),
        new("numune_kabul", "Numune Kabul", "Numune kabul, barkod, dış laboratuvar gönderimi.", ["lab", "goruntuleme_lab"],
            K(Y("lab"), H("lab.numune"), Y("lab.dislab"), T("lab.sonuc"), Y("hasta"), Y("belge"), T("randevu"))),
        // DIS DOKTOR PORTAL ROLU (796, kullanici: "Disardan hasta gonderen 'Dis
        //   Doktor' gonderdigi hastalarin sonuclarini gorecek"): `portal_turu = 1`.
        //   Bag iki yerde olabilir - lab isteminde `personel_id`, basvuru
        //   satirinda "Gonderen" rolu (belge_satir_rol, rol = 1); radyolojide
        //   dogrudan `istek_hekim_id`.
        //
        //   ISTEM ACABILIR (lab + radyoloji): dis hekim portali "sonuc
        //   bakma" ekrani degil, is akisinin bir ucu - hastayi gonderen kisi
        //   istemi de oradan girer. Kurum istemezse yetkiyi kaldirir.
        new("dis_doktor", "Dış Doktor (portal)",
            "Dışarıdan hasta gönderen hekim: kendi gönderdiği hastanın istemi, numunesi ve sonucu.",
            ["lab", "goruntuleme", "goruntuleme_lab", "tip_merkezi", "hastane"],
            P(new("lab", true, true), T("lab.sonuc"), T("lab.numune"),
              // DAR YETKI: yalniz calisma listesi + kart. `radyoloji` yetkisi
              //   cihaz/sablon/protokol ekranlarini da acardi.
              new("radyoloji-istem", true, true), T("hasta")),
            PortalTuru: 1),
        // DIS KURUM PORTAL ROLU (795): `portal_turu = 2` - yalniz KENDI
        //   gonderdigi istemi, onun sonucunu ve o hastayi gorur. Kural kaynak
        //   ve kart kataloglarinda (PortalKosullari), rol yalniz damgayi
        //   tasir. Kurum ici ekranlar (gorev/mesaj/dokuman/panel) VERILMEZ.
        new("dis_istem_kurumu", "Dış İstem Kurumu (portal)", "Anlaşmalı kurum: istem girer, kendi gönderdiği hastanın sonucunu görür.", ["lab", "goruntuleme_lab"],
            P(new("lab", true, true), T("lab.sonuc"), T("lab.numune"), T("hasta")),
            PortalTuru: 2),
        // ---- eczane / depo
        new("eczane_depo", "Eczane / Depo", "İlaç-sarf stoğu, karekod (ÜTS), depo hareketleri.", ["tip_merkezi", "hastane"],
            K(H("stok"), H("depo"), T("katalog"), H("uts"), A("uts.%"), T("yatan"), T("belge"), Y("belge_satir"))),
        // ---- yatan hasta
        new("yatan_hemsire", "Yatan Hasta Hemşiresi", "Order uygulama, ilaç, hemşire gözlemi.", ["hastane"],
            K(Y("yatan"), T("hasta"), T("muayene"), T("katalog"), Y("lab.numune"), T("lab"), Y("onam"))),
        new("yatis_ofisi", "Yatış / Taburcu Ofisi", "Yatış, oda-yatak, taburcu ve tahakkuk.", ["hastane"],
            K(Y("yatan"), Y("hasta"), Y("belge"), Y("belge_satir"), Y("randevu"), T("kurum"), Y("medula.provizyon"), T("medula"))),
        // ---- işyeri hekimliği (741): OSGB ya da hastane/tıp merkezi İSG birimi.
        new("isyeri_hekimi", "İşyeri Hekimi", "Ek-2 muayene, kanaat, ziyaret, olay, periyodik takvim; firma ve çalışan tanımı.", ["osgb", "tip_merkezi", "hastane"],
            K(Y("isg"), Y("isg.pano"), Y("isg.firma"), Y("isg.calisan"), Y("isg.muayene"), Y("isg.takvim"), Y("isg.ziyaret"), Y("isg.olay"), Y("isg.asi"),
              Y("form"), Y("form.istek"), Y("form.gonder"), Y("form.doldur"), Y("form.aktar"), T("form.sablon"),
              Y("muayene"), T("hasta"), Y("randevu"), Y("lab"), T("lab.sonuc"), Y("radyoloji-istem"), T("radyoloji"), T("kurum"), Y("onam"))),
        new("isg_uzmani", "İSG Uzmanı", "Ziyaret tutanağı, olay/kaza kaydı, öneri defteri; sağlık verisi görmez.", ["osgb", "tip_merkezi", "hastane"],
            K(T("isg"), T("isg.pano"), T("isg.firma"), T("isg.calisan"), Y("isg.ziyaret"), Y("isg.olay"), T("kurum"))),
        new("dsp", "Diğer Sağlık Personeli (DSP)", "Çalışan kaydı, aşı, tetkik takibi, periyodik takvim, form gönderimi; kanaat yazmaz.", ["osgb", "tip_merkezi", "hastane"],
            K(T("isg"), T("isg.pano"), T("isg.firma"), Y("isg.calisan"), T("isg.muayene"), Y("isg.takvim"), Y("isg.asi"), T("isg.olay"),
              Y("form.istek"), Y("form.gonder"), Y("form.doldur"), Y("hasta"), Y("randevu"), Y("lab"), T("kurum"))),
        new("osgb_sekreter", "OSGB Sekreteri", "Firma ve çalışan kaydı, sözleşme dakikası, randevu, form gönderimi; muayene içeriği görmez.", ["osgb"],
            K(T("isg"), T("isg.pano"), Y("isg.firma"), Y("isg.calisan"), Y("isg.takvim"), T("isg.olay"), Y("form.gonder"), Y("hasta"), Y("randevu"), Y("belge"), Y("cari"), Y("kurum"))),
        // FIRMA YETKILISI ARTIK GERCEKTEN PORTAL ROLU (830, kullanici:
        //   "portal rolü olsun"): adinda "(portal)" yaziyordu ama
        //   `portal_turu = 0` idi - kurum ICI ekranlari (gorev, mesaj, pano)
        //   aliyor ve kurum tipi rol haritasiyla kapatilabiliyordu.
        //
        //   Tur 2 (kurum): kapsam kimligi firmanin CARI kaydi. Kaynak
        //   kurallari `KaynakKatalogu.Isg.cs`'te: firma karti ve calisan
        //   listesi KENDI firmasiyla sinirli; muayene, ziyaret ve olay
        //   portalda KAPALI (saglik verisi).
        //
        //   `P()` kullanilir: portal rolune kurum ici ekranlar verilmez.
        //   Pano ve periyodik takvim OZEL SAYFA (liste kaynagi yok) - portal
        //   menusunde gorunmezler; yetki ileride o ekranlara kapsam
        //   yazilirsa ise yarar.
        new("firma_yetkilisi", "Firma Yetkilisi (portal)", "Kendi firmasının çalışan listesi ve sağlık gözetimi takibi (vade, kanaat); muayene içeriği ve ziyaret tutanağı görmez.", ["osgb"],
            P(T("isg"), T("isg.firma"), T("isg.calisan")),
            PortalTuru: 2),
        // ---- ERP (795, kullanici: "bir de standart ERP rolleri var, bunlari
        //      da dusunelim"): ERP kurulumunun bugune kadar HIC sablon rolu
        //      yoktu - "Standart rolleri kur" dugmesi ERP'de bos liste
        //      donuyordu ve yonetici 150 yetkiyi elle isaretliyordu.
        //      Ayrim TICARI AKISA gore: satan, alan, mal hareketini yazan,
        //      ureten, serviste calisan. Muhasebe/yonetim/bilgi islem/kalite
        //      rolleri zaten her tipte (Klinik listesine 'erp' eklendi).
        new("erp_satis", "Satış Sorumlusu",
            "Müşteri, teklif, sipariş, irsaliye, fatura ve tahsilat takibi; stok ve fiyat görür.",
            ["erp"],
            K(Y("cari"), Y("taraf"), Y("aday"), Y("firsat"), Y("belge"), Y("belge_satir"),
              H("e_belge"), A("belge.kesinlestir"), A("belge.donustur"), A("ebelge.%"),
              T("stok"), T("hizmet"), T("fiyat_listesi"), T("depo"), T("kasa_islem"),
              T("mali_hareket"), A("basvuru.iskonto"))),
        // TIPLER GENISLETILDI (831): `satinalma` modulu matriste YALNIZ
        //   hastanede acik; rol ise yalniz "erp" tipinde oneriliyordu - yani
        //   modulun acik oldugu tek kurumda Satinalma Sorumlusu hic
        //   listelenmiyordu ve `satinalma.onay_satinalma` basamagi sahipsiz
        //   kaliyordu. Modul kapisi (`SablonModul`) zaten koruyor: modulu
        //   kapali kurumda rol yine cikmaz.
        new("erp_alis", "Satınalma Sorumlusu",
            "Talep, teklif, sipariş, mal kabul ve tedarikçi faturası; bütçe ve sözleşme takibi.",
            ["erp", "tip_merkezi", "hastane"],
            K(Y("satinalma"), Y("satinalma.talep"), Y("satinalma.teklif"), Y("satinalma.siparis"),
              Y("satinalma.kabul"), Y("satinalma.fatura"), Y("satinalma.tedarikci"),
              T("satinalma.butce"), Y("satinalma.sozlesme"),
              Y("cari"), Y("belge"), Y("belge_satir"), T("stok"), T("depo"), T("hizmet"),
              T("fiyat_listesi"),
              // SATINALMA BASAMAGI (738): talebin ikinci imzasi.
              A("satinalma.onay_satinalma"))),
        new("erp_depo", "Depo / Sevkiyat Sorumlusu",
            "Stok giriş-çıkış, sayım, transfer, irsaliye ve sevkiyat; fiyat görmez.",
            ["erp"],
            K(Y("stok"), Y("depo"), Y("belge"), Y("belge_satir"), T("cari"), T("uts"),
              A("veri.disa-aktar"))),
        new("erp_uretim", "Üretim Sorumlusu",
            "İş emri, reçete, üretim girişi ve sarf; depo hareketleriyle birlikte.",
            ["erp"],
            K(Y("uretim"), Y("stok"), Y("depo"), T("belge"), T("hizmet"), T("demirbas"))),
        new("erp_servis", "Teknik Servis Sorumlusu",
            "Servis kaydı, cihaz ve sözleşme takibi; müşteri ve stok görür. "
            + "Demirbaş onarımının teknik imzası bu roldedir.",
            ["erp", "tip_merkezi", "hastane"],
            K(Y("servis"), Y("servis.cihaz"), Y("servis.sozlesme"), Y("demirbas"),
              Y("demirbas.isemri"), Y("demirbas.ariza"), Y("demirbas.bakim"),
              T("cari"), T("stok"), T("belge"),
              // TEKNIK MUDUR BASAMAGI (738): onarim talebinin ilk imzasi ve
              //   kapsam disi is icin son soz.
              A("demirbas.onarim_onay_teknik"))),
        new("erp_ik", "İK Sorumlusu",
            "Personel kartı, izin, avans, masraf ve belge talepleri; prim hesabı.",
            ["erp", "tip_merkezi", "hastane"],
            K(H("personel"), Y("ik.izin"), Y("ik.izin_hak"), Y("ik.avans"), Y("ik.masraf"),
              Y("ik.belge_talep"), T("ik.tatil"), Y("prim"), T("rol"), T("islem_log"),
              // IK BASAMAGI (738): izin/avans zincirinin ikinci imzasi ve
              //   belge talebinin tek imzasi.
              A("ik.izin_onay_ik"), A("ik.avans_onay_ik"), A("ik.belge_talep_onay"))),

        // ---- ROL/YARDIMCI KADROLAR (kullanici: "şu rolleri de ekle: İK
        //      Personeli, Eczacı, Eczane Teknisyeni, Kalite Görevlisi, Bilgi
        //      İşlem Personeli, Acil Hekimi").
        //
        //      HEPSI VAR OLAN BIR "SORUMLU" ROLUN DAR HALI (Acil Hekimi
        //      disinda - onun karsiligi hic yoktu). Ayrimin tek olcusu:
        //      IMZA/ONAY ve TANIM yetkisi sorumluda kalir, gunluk is
        //      personeldedir. Ayni rolu iki kisiye verip "dikkat et" demek
        //      denetim degildir.
        new("ik_personel", "İK Personeli",
            "İzin, avans, masraf ve belge taleplerinin kaydı; personel kartı. Onay ve prim İK Sorumlusunda.",
            ["erp", "tip_merkezi", "hastane"],
            // ONAY AKSIYONLARI (ik.%_onay_ik) BILEREK YOK: talebi giren kisi
            //   kendi girdigini onaylayamamali.
            K(Y("personel"), Y("ik.izin"), Y("ik.avans"), Y("ik.masraf"),
              Y("ik.belge_talep"), T("ik.izin_hak"), T("ik.tatil"))),
        new("eczaci", "Eczacı",
            "Order karşılama, ünite doz, aseptik hazırlama, kontrollü ilaç ve imha; eczacı onayı.",
            ["tip_merkezi", "hastane"],
            // ECZACI ONAYI (eczane.onay), kontrollu ilac teslimi ve imha onayi
            //   MESLEKI SORUMLULUKTUR - teknisyene verilmez.
            K(H("eczane"), H("eczane.%"), A("eczane.%"), Y("stok"), Y("depo"), T("uts"),
              T("yatan"), T("hasta"), T("muayene"), T("katalog"), T("belge"))),
        new("eczane_teknisyen", "Eczane Teknisyeni",
            "Order hazırlama, ünite doz, iade kabulü ve stok/karekod işleri; eczacı onayı gerektiren işler hariç.",
            ["tip_merkezi", "hastane"],
            K(T("eczane"), Y("eczane.order"), Y("eczane.doz"), Y("eczane.iade"),
              Y("stok"), Y("depo"), Y("uts"), A("uts.bildir"), T("yatan"), T("katalog"))),
        new("kalite_gorevli", "Kalite Görevlisi",
            "Gösterge ve olgu verisinin girişi, dönem hesabı; hedef belirleme ve dönem kesinleştirme Kalite Sorumlusunda.",
            Hepsi,
            // KESINLESTIRME kuruma karsi imzadir: hesaplayan kisi kendi
            //   hesabini kesinlestirmesin.
            K(Y("klinik_kalite"), Y("klinik_kalite.olgu"), T("klinik_kalite.donem"),
              A("klinik_kalite.hesapla"), T("hasta"), T("muayene"), T("lab"), T("radyoloji"))),
        new("bilgi_islem_personel", "Bilgi İşlem Personeli",
            "Kullanıcı açma/parola sıfırlama, cihaz bakımı, günlük destek; rol-şube-ayar tanımı ve veri aktarımı Bilgi İşlem Sorumlusunda.",
            Hepsi,
            // `kullanici.portal` YOK: disariya kapi acmak (dis hekim / kurum /
            //   hasta hesabi) ayri bir karardir - 819'da da oyle ayrildi.
            K(Y("kullanici"), A("kullanici.parola-sifirla"), T("rol"), T("sube"), T("ayar"),
              T("referans"), T("entegrasyon"), Y("cihaz"), A("cihaz.isle"), T("kod_liste"),
              T("numara_sablonu"), Y("bildirim"), T("bildirim_sablon"), T("islem_log"))),
        // BIRIM AMIRI (738 onay omurgasi): izin/avans/masraf zincirinin ILK
        //   imzasi "Birim Âmiri" basamagi, satinalma talebininki "Birim
        //   Sorumlusu". Ikisinin de yetkisi HICBIR sablonda yoktu; sahibi
        //   yalniz sistem yoneticisiydi ve talepler ilk basamakta bekliyordu.
        //
        //   Kimin amir oldugu ROLDEN degil KISIDEN gelir
        //   (`taraf_personel.yonetici_taraf_id`, sahip_turu 3): rol yalnizca
        //   "imzalayabilir" der, kimin talebini imzalayacagini kadro agaci
        //   soyler. Bu yuzden rol genis dagitilsa bile herkes herkesin
        //   talebini goremez.
        new("birim_amiri", "Birim Âmiri / Departman Sorumlusu",
            "Ekibinin izin, avans ve masraf taleplerinin ilk imzası; birim satınalma talebi onayı.",
            Hepsi,
            K(T("personel"), T("ik.izin"), T("ik.avans"), T("ik.masraf"), T("ik.tatil"),
              A("ik.izin_onay_amir"), A("ik.avans_onay_amir"), A("ik.masraf_onay_amir"),
              Y("satinalma.talep"), A("satinalma.onay_birim"), T("satinalma"),
              T("satinalma.butce"))),
        new("acil_hekimi", "Acil Hekimi",
            "Acil başvuru, triyaj, takip panosu, çıkış ve sevk kararı; muayene, istem ve reçete.",
            ["hastane"],
            // TRIYAJ DUSURME ayri aksiyon: yesil alana kaydirmak klinik karar
            //   ve iz birakmali - hekimde durur, kayit kabulde degil.
            K([.. HekimTemel, H("acil"), Y("acil.basvuru"), Y("acil.triyaj"), T("acil.pano"),
               A("acil.cikis"), A("acil.sevk"), A("acil.triyaj_dusur"), T("acil.yatak"),
               T("yatan")])),
    ];

    public static void StandartRolUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kurum-profil/standart-roller").WithTags("KurumProfil").RequireAuthorization();

        // Önizleme: tipin şablonları + hangileri zaten var.
        grup.MapGet("/", async (string? kurumTipi, bool? tumModuller, VeriKaynagi veri,
                                BaglamCozucu cozucu, KurumProfilDeposu profil,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            var tip = kurumTipi ?? await KurumTipiAsync(profil, baglam.SubeId ?? 0, iptal);
            // KURUM PROFILINE GORE (785, kullanici: "örneğin bir lab
            //   merkezinde diş hekimi rolü görünmemeli"): tip "hangi is kolu",
            //   acik moduller "bu kurulumda ne var" sorusunu cevaplar. Kapali
            //   modulun rolu LISTEDE HIC CIKMAZ - kullanilmayacak rolu onermek
            //   yoneticiyi gereksiz secime zorlar. `tumModuller=true` ile
            //   tamami istenebilir (modulu yarin acacak kurum icin).
            var acikModuller = await profil.AcikModullerAsync(baglam.SubeId ?? 0, iptal);
            await using var b = await veri.AcAsync(iptal);
            var mevcut = await b.ListeAsync("select kod, id, ad, aktif from public.rol", null, [],
                o => new { kod = o.GetString(0), id = o.GetInt32(1), ad = o.GetString(2), aktif = o.GetInt16(3) == 1 }, iptal);
            var yetkiler = await YetkilerAsync(b, iptal);
            // PORTAL SABLONLARI BU LISTEDE YOK (829): Kurum Profili > Roller
            //   sekmesi kurum ICI kadroyu kuruyor. Portal rolleri (dis doktor,
            //   dis kurum, hasta) gocle geliyor ve kurum tipi haritasindan da
            //   muaf - onlari "kurulacak kadro" gibi gostermek, kapatilabilir
            //   sanilmalarina yol acardi.
            var liste = Sablonlar
                .Where(s => s.PortalTuru == 0
                            && (s.Tipler.Contains(tip) || s.Tipler.Contains(TUM)))
                .Select(s =>
            {
                var m = mevcut.FirstOrDefault(x => x.kod == s.Kod);
                var esle = Eslestir(s, yetkiler);
                var modul = SablonModul.GetValueOrDefault(s.Kod);
                return new { s.Kod, s.Ad, s.Amac, mevcut = m is not null, rolId = m?.id, aktif = m?.aktif,
                             modul, modulKapali = modul is not null && !acikModuller.Contains(modul),
                             yetkiSayisi = esle.Count, ekran = esle.Count(x => x.tur == 0), aksiyon = esle.Count(x => x.tur == 1) };
            }).Where(r => tumModuller == true || !r.modulKapali).ToList();
            return Results.Ok(new { kurumTipi = tip, roller = liste });
        });

        // Kur: seçilen şablonlar (boşsa tipin hepsi). Var olan rol atlanır;
        //   `guncelle` ile yetkileri şablona çekilir (rol adı/amacı korunur).
        grup.MapPost("/", async (KurIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, KurumProfilDeposu profil,
                                 HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Ekle);
            var tip = istek.KurumTipi ?? await KurumTipiAsync(profil, baglam.SubeId ?? 0, iptal);
            // KAPALI MODULUN ROLU KURULMAZ (785) - ama ACIKCA istenirse
            //   (`kodlar` ile secilerek ya da `tumModuller`) kurulur: kurum
            //   modulu yarin acacaksa rolu bugunden hazirlayabilmeli.
            var acikModuller = await profil.AcikModullerAsync(baglam.SubeId ?? 0, iptal);
            var secildi = istek.Kodlar is { Count: > 0 };
            var secim = Sablonlar.Where(s => (s.Tipler.Contains(tip) || s.Tipler.Contains(TUM))
                                          && (!secildi || istek.Kodlar!.Contains(s.Kod))
                                          && (secildi || istek.TumModuller == true
                                              || SablonModul.GetValueOrDefault(s.Kod) is not { } m
                                              || acikModuller.Contains(m))).ToList();
            if (secim.Count == 0) throw GentegreHatasi.Dogrulama("Bu kurum tipi için şablon yok.");

            await using var b = await veri.AcAsync(iptal);
            var yetkiler = await YetkilerAsync(b, iptal);
            var subeler = await b.ListeAsync("select id, varsayilan from public.sube where aktif = 1 order by id", null, [],
                o => new { id = o.GetInt32(0), varsayilan = o.GetInt16(1) == 1 }, iptal);
            var kuruldu = new List<string>(); var guncellendi = new List<string>(); var atlandi = new List<string>();
            await using var islem = await b.BeginTransactionAsync(iptal);
            foreach (var s in secim)
            {
                var rolId = await b.TekDegerAsync<int?>("select id from public.rol where kod = @p0", islem, [s.Kod], iptal);
                if (rolId is int varId)
                {
                    if (istek.Guncelle != true) { atlandi.Add(s.Ad); continue; }
                    await YetkileriYazAsync(b, islem, varId, s, yetkiler, baglam.KullaniciId, true, iptal);
                    guncellendi.Add(s.Ad);
                    await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloRol, varId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                        new { standartSablon = s.Kod, kurumTipi = tip }, iptal: iptal);
                    continue;
                }
                var yeniId = await b.TekDegerAsync<int>("""
                    -- SISTEM ROLU (785, kullanici: "standart rolleri sistem
                    --   rolu olarak ekle.. silinemesin aktif/pasif
                    --   yapilabilsin"): silinmeye karsi korunur, kullanilmayan
                    --   rol PASIFE alinir (fn_rol_sistem_koru).
                    insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen, portal_turu)
                    values (@p0, @p1, @p2, 1, 1, @p3, @p4) returning id
                    """, islem, [s.Kod, s.Ad, s.Amac, baglam.KullaniciId, s.PortalTuru], iptal);
                await YetkileriYazAsync(b, islem, yeniId, s, yetkiler, baglam.KullaniciId, false, iptal);
                foreach (var sb in subeler)
                    await b.CalistirAsync("""
                        insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen) values (@p0, @p1, @p2, 1, @p3)
                        on conflict do nothing
                        """, islem, [yeniId, sb.id, (short)(sb.varsayilan ? 1 : 0), baglam.KullaniciId], iptal);
                kuruldu.Add(s.Ad);
                await log.YazAsync(b, islem, LogIslemi.Ekle, LogTabloRol, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { standartSablon = s.Kod, kurumTipi = tip, s.Ad }, iptal: iptal);
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { kurumTipi = tip, kuruldu, guncellendi, atlandi });
        });

        // ------------------------------------------- profile göre geçerli rol --
        // GET /api/kurum-profil/standart-roller/profil-rolleri?kurumTipi=osgb
        //
        // Kullanıcı: *"profili görüntüleme yaptım bütün roller görünüyor.. isg
        //   yaptım yine bütün roller görünüyor.. böyle olmasın.. profil
        //   sayfasında altta her bir profil için geçerli (aktif) rolleri
        //   işaretleyeyim"*.
        //
        // KURULU ROLLERİN TAMAMI listelenir (şablon süzgeci burada UYGULANMAZ):
        //   işaretleme ekranı, "bu profilde neyi kapatayım" sorusunu ancak
        //   kapatılacakları da gösterirse cevaplayabilir. Şablonun kararı
        //   `varsayilan` sütununda ipucu olarak durur.
        grup.MapGet("/profil-rolleri", async (string? kurumTipi, VeriKaynagi veri,
                                              BaglamCozucu cozucu, KurumProfilDeposu profil,
                                              HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            var tip = kurumTipi ?? await KurumTipiAsync(profil, baglam.SubeId ?? 0, iptal);
            var acikModuller = await profil.AcikModullerAsync(baglam.SubeId ?? 0, iptal);

            await using var b = await veri.AcAsync(iptal);
            var harita = await b.ListeAsync(
                "select rol_kod, gecerli from public.kurum_tipi_rol where kurum_tipi = @p0",
                null, [tip], o => new { kod = o.GetString(0), gecerli = o.GetInt16(1) == 1 }, iptal);
            // PORTAL ROLLERI LISTEDE YOK (829, kullanici: "portal rollerini o
            //   listeden muaf tut"): bu harita kurum ICI kadroyu anlatiyor -
            //   "tip merkezinde dis hekimi gerekmez". Portal rolu (dis doktor,
            //   dis kurum, hasta) kadro degil DISARIYA ACILAN KAPI; kurum
            //   tipiyle ilgisi yok. Canli denemede "Hastane" profilinde
            //   isaretlenmedigi icin `dis_istem_kurumu` pasife alinmis ve dis
            //   kurumun kullanicilari giris yapamaz olmustu.
            var roller = await b.ListeAsync("""
                select r.id, r.kod, r.ad, r.amac, r.aktif, r.sistem,
                       (select count(*) from public.taraf_kullanici k
                         where k.rol_id = r.id and k.aktif = 1) as kisi
                  from public.rol r
                 where coalesce(r.portal_turu, 0) = 0
                 order by r.sistem desc, r.ad
                """, null, [],
                o => new { id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2),
                           amac = o.GetString(3), aktif = o.GetInt16(4) == 1,
                           sistem = o.GetInt16(5) == 1, kisi = o.GetInt64(6) }, iptal);

            var liste = roller.Select(r =>
            {
                var s = Sablonlar.FirstOrDefault(x => x.Kod == r.kod);
                var modul = SablonModul.GetValueOrDefault(r.kod);
                // ŞABLON VARSAYILANI: bu tip şablonda geçiyor mu + modülü açık mı.
                //   Şablonu olmayan rol (kurumun kendi açtığı) varsayılan olarak
                //   GEÇERLİDİR - kimse onu bir tipe bağlamamış.
                var varsayilan = s is null
                    || ((s.Tipler.Contains(tip) || s.Tipler.Contains(TUM))
                        && (modul is null || acikModuller.Contains(modul)));
                var kayit = harita.FirstOrDefault(h => h.kod == r.kod);
                return new
                {
                    r.id, r.kod, r.ad, r.amac, r.aktif, r.sistem, r.kisi,
                    sablon = s is not null, modul,
                    modulKapali = modul is not null && !acikModuller.Contains(modul),
                    varsayilan,
                    gecerli = kayit?.gecerli ?? varsayilan,
                    // İŞARETLENMİŞ Mİ: kurum bu tip için kaydını yazdı mı.
                    yazili = kayit is not null,
                    // KİLİTLİ: pasife alınamaz (786 tetiği) - kutu kapatılamaz.
                    kilitli = r.kod is "yonetici" or "atanmamis",
                };
            }).ToList();

            return Results.Ok(new { kurumTipi = tip, roller = liste,
                                    yazili = harita.Count > 0 });
        });
    }

    /// <summary>
    /// Profil kaydedilirken çağrılır: haritayı yazar ve `rol.aktif` alanına
    /// uygular. Uygulamayı DB'deki `fn_kurum_tipi_rol_uygula` yapar - kural
    /// tek yerde (786).
    /// </summary>
    public static async Task ProfilRolleriYazAsync(
        NpgsqlConnection b, NpgsqlTransaction? islem, string kurumTipi,
        IReadOnlyCollection<string> gecerliKodlar, IReadOnlyCollection<string> tumKodlar,
        int kullaniciId, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(kurumTipi) || tumKodlar.Count == 0) return;
        foreach (var kod in tumKodlar)
        {
            // KILITLI ROL HARITAYA DA 1 YAZILIR: `yonetici` ve `atanmamis`
            //   pasife alınamıyor (786 tetiği) - haritada 0 görünmesi, ekranda
            //   "geçersiz ama aktif" gibi okunan yalan bir satır bırakırdı.
            var gecerli = (short)(gecerliKodlar.Contains(kod)
                                  || kod is "yonetici" or "atanmamis" ? 1 : 0);
            await b.CalistirAsync("""
                insert into public.kurum_tipi_rol (kurum_tipi, rol_kod, gecerli, ekleyen)
                values (@p0, @p1, @p2, @p3)
                on conflict (kurum_tipi, rol_kod) do update
                   set gecerli = excluded.gecerli, degistiren = @p3,
                       degistirme_tarihi = now()
                """, islem, [kurumTipi, kod, gecerli, kullaniciId], iptal);
        }
        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula(@p0)",
                              islem, [kurumTipi], iptal);
    }

    /// <param name="TumModuller">
    /// KAPALI MODULUN ROLUNU DE KUR (785): varsayilan false - kurum profilinde
    /// kapali modulun rolu listede de cikmaz, kurulmaz da.
    /// </param>
    public sealed record KurIstegi(string? KurumTipi, List<string>? Kodlar, bool? Guncelle,
                                   bool? TumModuller = null);
    private const int LogTabloRol = 903;   // rol karti ile ayni (KartKatalogu.Cari.Hasta)

    private sealed record YetkiSatir(int id, string kod, short tur);

    private static async Task<string> KurumTipiAsync(KurumProfilDeposu depo, int subeId, CancellationToken iptal)
    {
        var (profil, _, _, _, _, _, _) = await depo.OkuAsync(subeId, iptal);
        return string.IsNullOrEmpty(profil.KurumTipi) ? "tip_merkezi" : profil.KurumTipi;
    }

    private static Task<List<YetkiSatir>> YetkilerAsync(NpgsqlConnection b, CancellationToken iptal)
        => b.ListeAsync("select id, kod, tur from public.yetki where aktif = 1", null, [],
            o => new YetkiSatir(o.GetInt32(0), o.GetString(1), o.GetInt16(2)), iptal);

    /// <summary>Şablon kurallarını yetki tablosuna uygular; sonraki kural öncekini ezer (ör. "%" gör + "ayar" kapalı).</summary>
    private static List<(int id, short tur, bool gor, bool ekle, bool degistir, bool sil)> Eslestir(Sablon s, List<YetkiSatir> yetkiler)
    {
        var sonuc = new Dictionary<int, (int id, short tur, bool gor, bool ekle, bool degistir, bool sil)>();
        foreach (var k in s.Kurallar)
        {
            var desen = "^" + System.Text.RegularExpressions.Regex.Escape(k.Desen).Replace("%", ".*") + "$";
            foreach (var y in yetkiler.Where(y => System.Text.RegularExpressions.Regex.IsMatch(y.kod, desen)))
            {
                // "%" gibi geniş desen aksiyonları (tur 1) kapsamaz: aksiyon açıkça istenir.
                if (k.Desen.Contains('%') && y.tur == 1 && !k.Desen.Contains('.')) continue;
                if (!k.Gor) { sonuc.Remove(y.id); continue; }
                sonuc[y.id] = (y.id, y.tur, k.Gor, k.Ekle, k.Degistir, k.Sil);
            }
        }
        return [.. sonuc.Values];
    }

    private static async Task YetkileriYazAsync(NpgsqlConnection b, NpgsqlTransaction islem, int rolId, Sablon s,
        List<YetkiSatir> yetkiler, int kullaniciId, bool temizle, CancellationToken iptal)
    {
        if (temizle) await b.CalistirAsync("delete from public.rol_yetki where rol_id = @p0", islem, [rolId], iptal);
        foreach (var e in Eslestir(s, yetkiler))
            await b.CalistirAsync("""
                insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen) values (@p0, @p1, @p2, @p3, @p4, @p5, @p6)
                on conflict (rol_id, yetki_id) do update set gor = excluded.gor, ekle = excluded.ekle, degistir = excluded.degistir, sil = excluded.sil
                """, islem, [rolId, e.id, (short)(e.gor ? 1 : 0), (short)(e.ekle ? 1 : 0), (short)(e.degistir ? 1 : 0), (short)(e.sil ? 1 : 0), kullaniciId], iptal);
        // Yetki önbelleği rol sürümüyle geçersizlenir (YetkiCozucu).
        await b.CalistirAsync("update public.rol set yetki_surumu = yetki_surumu + 1 where id = @p0", islem, [rolId], iptal);
    }
}

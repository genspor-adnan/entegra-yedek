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
    private sealed record Sablon(string Kod, string Ad, string Amac, string[] Tipler, Kural[] Kurallar);

    private const string TUM = "*";
    private static readonly string[] Klinik = ["muayenehane", "dal_goz", "dal_ftr", "goruntuleme", "lab", "goruntuleme_lab", "dis", "tip_merkezi", "hastane", "osgb"];

    // Her rolde: ana sayfa, mesaj, görev, dökümler, AI rehber (gör).
    private static readonly Kural[] Ortak = [new("panel"), new("mesaj", true, true, true), new("gorev", true, true, true), new("dokum"), new("ai"), new("ai.rehber"), new("dokuman", true, true)];
    private static Kural[] K(params Kural[] k) => [.. Ortak, .. k];
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
        new("muhasebe", "Muhasebe / Finans", "Fatura, kasa-banka, dönem sonlandırma, kesinti ve itiraz.", Klinik, K(MuhasebeTemel)),
        new("muhasebe_sorumlu", "Mali İşler Müdürü",
            "Muhasebenin tüm işleri + iskonto talebinin mali imzası.", Klinik,
            K(MuhasebeSorumluTemel)),
        new("ust_yonetim", "Üst Yönetim (Mesul Müdür / Genel Müdür)",
            "Salt okuma dökümler + iskonto zincirinin son imzası.", Klinik,
            K(UstYonetimTemel)),
        new("vezne", "Vezne", "Tahsilat, makbuz, fatura kapatma.", ["tip_merkezi", "hastane"],
            K(Y("kasa_islem"), Y("mali_hareket"), T("hesap"), Y("kasa_kapatma"), A("kasa.kapat"), A("kasa.makbuz-yazdir"), A("kasa.kesinlestir"), T("belge"), T("hasta"), T("cari"))),
        new("rapor_goruntuleyici", "Yönetim Görüntüleyici", "Kurum sahibi / mesul müdür: salt okuma dökümler ve günlük.", Klinik,
            K(T("%"), new("ayar", false), new("rol", false), new("kullanici", false), new("sube", false), new("referans", false), new("entegrasyon", false), new("dokuman.ozel_nitelikli", false))),
        new("kalite", "Kalite Sorumlusu", "Klinik kalite göstergeleri, dönem hesabı, doküman onayı; klinik ekranlar salt okuma.", Klinik,
            K(H("klinik_kalite"), H("klinik_kalite.%"), A("klinik_kalite.%"), Y("dokuman.onayla"), T("islem_log"), T("hasta"), T("muayene"), T("lab"), T("radyoloji"), T("yatan"))),
        new("medula_sorumlu", "Medula Sorumlusu", "SGK kuyruğu, hizmet kaydı, fatura, dönem sonlandırma, kesinti.", ["tip_merkezi", "hastane", "dal_goz", "dal_ftr", "dis", "goruntuleme", "goruntuleme_lab"],
            K(H("medula"), H("medula.%"), A("medula.donem"), T("kurum"), T("belge"), T("hasta"), T("hizmet"))),
        new("bilgi_islem", "Bilgi İşlem Sorumlusu", "Kullanıcı, rol ve şube tanımı, ayarlar, entegrasyon ve cihaz hesapları, işlem günlüğü; hasta verisi görmez.", Klinik,
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
            K(H("radyoloji"), H("radyoloji-istem"), A("rad.rapor_yaz"), A("rad.rapor_onayla"), A("rad.teslim"), A("rad.istem_iptal"), T("hasta"), T("katalog"), T("muayene"), T("prim.kendi"))),
        new("rad_teknisyen", "Radyoloji Teknisyeni", "Çekim, cihaz, sonuç teslimi.", ["goruntuleme", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(Y("radyoloji"), Y("radyoloji-istem"), Y("cihaz"), A("cihaz.isle"), A("rad.teslim"), T("hasta"), T("randevu"))),
        new("teleradyoloji_hekim", "Teleradyoloji Hekimi (dış)", "Yalnız rapor yazma ve onay; kayıt/kabul görmez.", ["goruntuleme", "goruntuleme_lab"],
            K(T("radyoloji"), T("radyoloji-istem"), A("rad.rapor_yaz"), A("rad.rapor_onayla"))),
        // ---- laboratuvar
        new("lab_uzmani", "Lab Uzmanı", "Sonuç onayı, kalite kontrol serbest bırakma, katalog.", ["lab", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(H("lab"), H("lab.%"), A("lab.onay"), A("lab.kk.onay"), T("hasta"), T("katalog"), T("cihaz"), T("prim.kendi"))),
        new("lab_teknisyen", "Lab Teknisyeni", "Numune, cihaz, sonuç girişi, iç-dış kalite kontrol.", ["lab", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(Y("lab"), Y("lab.numune"), Y("lab.sonuc"), Y("lab.kk"), Y("lab.cihaz"), Y("lab.kultur"), T("lab.mikro"), T("lab.tetkik"), Y("cihaz"), A("cihaz.isle"), T("hasta"))),
        new("numune_kabul", "Numune Kabul", "Numune kabul, barkod, dış laboratuvar gönderimi.", ["lab", "goruntuleme_lab"],
            K(Y("lab"), H("lab.numune"), Y("lab.dislab"), T("lab.sonuc"), Y("hasta"), Y("belge"), T("randevu"))),
        new("dis_istem_kurumu", "Dış İstem Kurumu (portal)", "Anlaşmalı kurum: istem girer, kendi sonuçlarını görür.", ["lab", "goruntuleme_lab"],
            K(new("lab", true, true), T("lab.sonuc"), T("hasta"))),
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
        new("firma_yetkilisi", "Firma Yetkilisi (portal)", "Kendi firmasının çalışan listesi, periyodik takvim ve sağlık gözetimi özeti; sağlık verisi görmez.", ["osgb"],
            K(T("isg"), T("isg.pano"), T("isg.firma"), T("isg.calisan"), T("isg.takvim"))),
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
            var liste = Sablonlar.Where(s => s.Tipler.Contains(tip) || s.Tipler.Contains(TUM)).Select(s =>
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
                    insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen) values (@p0, @p1, @p2, 1, 1, @p3) returning id
                    """, islem, [s.Kod, s.Ad, s.Amac, baglam.KullaniciId], iptal);
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
            var roller = await b.ListeAsync("""
                select r.id, r.kod, r.ad, r.amac, r.aktif, r.sistem,
                       (select count(*) from public.taraf_kullanici k
                         where k.rol_id = r.id and k.aktif = 1) as kisi
                  from public.rol r
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

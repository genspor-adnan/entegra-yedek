namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// STERİLİZASYON (868) listeleri — mockup <c>Ekranlar/Dis Klinigi/dis_steril_*.html</c>.
/// Döngüler (kayıt defteri satırı = serbest bırakılmış döngü), paketler, birimler
/// (fiziksel set / döner alet), set tanımları, cihazlar, programlar, kullanım,
/// bakım, geri çağırma. Pano, döngü kartı, izlenebilirlik ve ayarlar özel sayfa.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi SterilDongu() => new(
        Ad: "steril-dongu",
        YetkiKodu: "steril.dongu",
        Kaynak: "public.v_steril_dongu d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.baslama desc, d.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "d.id",             "sayi",  "Id", Varsayilan: false),
            new("baslama",       "d.baslama",        "zaman", "Başlangıç", Genislik: 130),
            new("cihazAdi",      "d.cihaz_adi",      "metin", "Cihaz", Genislik: 110),
            new("sayacNo",       "d.sayac_no",       "sayi",  "Döngü no", Hizalama: "orta"),
            new("programAdi",    "d.program_adi",    "metin", "Program", Genislik: 150),
            new("bitis",         "d.bitis",          "zaman", "Bitiş", Genislik: 130),
            new("sureDk",        "d.sure_dk",        "sayi",  "Süre (dk)", Hizalama: "sag"),
            new("paketSayisi",   "d.paket_sayisi",   "sayi",  "Paket", Hizalama: "orta"),
            new("yukOzeti",      "d.yuk_ozeti",      "metin", "Yük", Genislik: 240, Varsayilan: false),
            new("bdSonuc",       "d.bd_sonuc",       "sayi",  "Bowie-Dick", Hizalama: "orta", Varsayilan: false),
            new("helixSonuc",    "d.helix_sonuc",    "sayi",  "Helix", Hizalama: "orta", Varsayilan: false),
            new("kimyasalSonuc", "d.kimyasal_sonuc", "sayi",  "Sınıf 5", Hizalama: "orta", Varsayilan: false),
            new("bioSonuc",      "d.bio_sonuc",      "sayi",  "Biyolojik", Hizalama: "orta", Varsayilan: false),
            new("tepeSicaklik",  "d.tepe_sicaklik",  "sayi",  "Tepe °C", Hizalama: "sag", Varsayilan: false),
            new("platoDk",       "d.plato_dk",       "sayi",  "Plato (dk)", Hizalama: "sag", Varsayilan: false),
            new("durumAdi",      "d.durum_adi",      "metin", "Durum", Genislik: 110, Bicim: "rozet"),
            new("operatorAdi",   "d.operator_adi",   "metin", "Operatör", Genislik: 130),
            new("onaylayanAdi",  "d.onaylayan_adi",  "metin", "Onaylayan", Genislik: 130),
            new("onayZamani",    "d.onay_zamani",    "zaman", "Onay", Varsayilan: false),
            new("hataKodu",      "d.hata_kodu",      "metin", "Hata", Genislik: 80, Varsayilan: false),
            new("cihazId",       "d.cihaz_id",       "sayi",  "Cihaz Id", Varsayilan: false),
            new("durum",         "d.durum",          "sayi",  "Durum Kodu", Varsayilan: false),
            new("testProgrami",  "d.test_programi",  "sayi",  "Test", Varsayilan: false),
            new("implantVar",    "d.implant_var",    "sayi",  "İmplant", Varsayilan: false),
        });

    private static KaynakTanimi SterilPaket() => new(
        Ad: "steril-paket",
        YetkiKodu: "steril.birim",
        Kaynak: "public.v_steril_paket p",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",             "p.id",              "sayi",  "Id", Varsayilan: false),
            new("barkod",         "p.barkod",          "metin", "Paket barkodu", Genislik: 170),
            new("birimAdi",       "p.birim_adi",       "metin", "İçerik", Genislik: 200),
            new("setAdi",         "p.set_adi",         "metin", "Set", Genislik: 150, Varsayilan: false),
            new("paketTurAdi",    "p.paket_tur_adi",   "metin", "Paket türü", Genislik: 130),
            new("cihazAdi",       "p.cihaz_adi",       "metin", "Cihaz", Genislik: 100),
            new("donguNo",        "p.dongu_no",        "sayi",  "Döngü", Hizalama: "orta"),
            new("sterilTarihi",   "p.steril_tarihi",   "zaman", "Steril tarihi", Genislik: 130),
            new("skt",            "p.skt",             "tarih", "SKT"),
            new("sktKalanGun",    "p.skt_kalan_gun",   "sayi",  "Kalan gün", Hizalama: "sag"),
            new("raf",            "p.raf",             "metin", "Raf", Genislik: 70),
            new("durumAdi",       "p.durum_adi",       "metin", "Durum", Genislik: 130, Bicim: "rozet"),
            new("kullanilabilir", "p.kullanilabilir",  "sayi",  "Kullanılabilir", Hizalama: "orta", Varsayilan: false),
            new("kullanimZamani", "p.kullanim_zamani", "zaman", "Kullanım", Varsayilan: false),
            new("kullananHasta",  "p.kullanan_hasta",  "metin", "Hasta", Genislik: 160, Varsayilan: false),
            new("paketleyenAdi",  "p.paketleyen_adi",  "metin", "Paketleyen", Genislik: 120, Varsayilan: false),
            new("birimId",        "p.birim_id",        "sayi",  "Birim Id", Varsayilan: false),
            new("donguId",        "p.dongu_id",        "sayi",  "Döngü Id", Varsayilan: false),
            new("durum",          "p.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
            new("implant",        "p.implant",         "sayi",  "İmplant", Varsayilan: false),
        });

    private static KaynakTanimi SterilBirim() => new(
        Ad: "steril-birim",
        YetkiKodu: "steril.birim",
        Kaynak: "public.v_steril_birim b",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.durum, b.barkod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id", Varsayilan: false),
            new("barkod",        "b.barkod",         "metin", "Barkod", Genislik: 90),
            new("ad",            "b.ad",             "metin", "Birim", Genislik: 200),
            new("turAdi",        "b.tur_adi",        "metin", "Tür", Genislik: 90, Bicim: "rozet"),
            new("setAdi",        "b.set_adi",        "metin", "Set tanımı", Genislik: 150),
            new("durumAdi",      "b.durum_adi",      "metin", "Durum", Genislik: 150, Bicim: "rozet"),
            new("durumDk",       "b.durum_dk",       "sayi",  "Bekleme (dk)", Hizalama: "sag"),
            new("donguSayisi",   "b.dongu_sayisi",   "sayi",  "Döngü", Hizalama: "sag"),
            new("yaglamaSayisi", "b.yaglama_sayisi", "sayi",  "Yağlama", Hizalama: "sag", Varsayilan: false),
            new("sonYaglama",    "b.son_yaglama",    "zaman", "Son yağlama", Varsayilan: false),
            new("bakimZamani",   "b.bakim_zamani",   "mantik", "Bakım zamanı", Hizalama: "orta"),
            new("sonDonguNo",    "b.son_dongu_no",   "sayi",  "Son döngü", Hizalama: "orta"),
            new("skt",           "b.skt",            "tarih", "SKT"),
            new("sonKullanim",   "b.son_kullanim",   "zaman", "Son kullanım", Genislik: 130),
            new("sonHastaAdi",   "b.son_hasta_adi",  "metin", "Son hasta", Genislik: 150),
            new("konum",         "b.konum",          "metin", "Konum", Genislik: 90),
            new("paketBarkod",   "b.paket_barkod",   "metin", "Aktif paket", Genislik: 160, Varsayilan: false),
            new("aktif",         "b.aktif",          "sayi",  "Aktif", Varsayilan: false),
            new("tur",           "b.tur",            "sayi",  "Tür Kodu", Varsayilan: false),
            new("durum",         "b.durum",          "sayi",  "Durum Kodu", Varsayilan: false),
            new("setId",         "b.set_id",         "sayi",  "Set Id", Varsayilan: false),
            new("yaglamaGerekli","b.yaglama_gerekli","sayi",  "Yağlama gerekli", Varsayilan: false),
            new("implant",       "b.implant",        "sayi",  "İmplant", Varsayilan: false),
        });

    private static KaynakTanimi SterilSet() => new(
        Ad: "steril-set",
        YetkiKodu: "steril.birim",
        Kaynak: "public.v_steril_set s",
        SubeKolonu: null,
        VarsayilanSirala: "s.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "s.id",             "sayi",  "Id", Varsayilan: false),
            new("kod",           "s.kod",            "metin", "Kod", Genislik: 90),
            new("ad",            "s.ad",             "metin", "Set", Genislik: 200),
            new("paketTurAdi",   "s.paket_tur_adi",  "metin", "Paket türü", Genislik: 130),
            new("rafOmruAy",     "s.raf_omru_ay",    "sayi",  "Raf ömrü (ay)", Hizalama: "sag"),
            new("aletSayisi",    "s.alet_sayisi",    "sayi",  "Alet", Hizalama: "orta"),
            new("birimSayisi",   "s.birim_sayisi",   "sayi",  "Fiziksel set", Hizalama: "orta"),
            new("sterilDepoda",  "s.steril_depoda",  "sayi",  "Steril depoda", Hizalama: "orta"),
            new("hazirlikta",    "s.hazirlikta",     "sayi",  "Hazırlıkta", Hizalama: "orta"),
            new("kullanimda",    "s.kullanimda",     "sayi",  "Kullanımda", Hizalama: "orta"),
            new("arizali",       "s.arizali",        "sayi",  "Arızalı", Hizalama: "orta"),
            new("minStok",       "s.min_stok",       "sayi",  "Min. stok", Hizalama: "sag"),
            new("implant",       "s.implant",        "mantik", "İmplant", Hizalama: "orta"),
            new("aktifAdi",      "s.aktif_adi",      "metin", "Durum", Genislik: 70, Bicim: "rozet"),
            new("aktif",         "s.aktif",          "sayi",  "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi SterilCihaz() => new(
        Ad: "steril-cihaz",
        YetkiKodu: "steril.ayar",
        Kaynak: "public.v_steril_cihaz c",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.tur, c.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",                "c.id",                 "sayi",  "Id", Varsayilan: false),
            new("ad",                "c.ad",                 "metin", "Cihaz", Genislik: 130),
            new("turAdi",            "c.tur_adi",            "metin", "Tür", Genislik: 130, Bicim: "rozet"),
            new("markaModel",        "c.marka_model",        "metin", "Marka / model", Genislik: 160),
            new("seriNo",            "c.seri_no",            "metin", "Seri no", Genislik: 110),
            new("sinifAdi",          "c.sinif_adi",          "metin", "Sınıf", Genislik: 50, Hizalama: "orta"),
            new("kapasite",          "c.kapasite",           "metin", "Kapasite", Genislik: 100),
            new("sayac",             "c.sayac",              "sayi",  "Sayaç", Hizalama: "sag"),
            new("veriBaglanti",      "c.veri_baglanti",      "metin", "Veri", Genislik: 70),
            new("sonBakim",          "c.son_bakim",          "tarih", "Son bakım"),
            new("sonrakiBakim",      "c.sonraki_bakim",      "tarih", "Sonraki bakım"),
            new("sonValidasyon",     "c.son_validasyon",     "tarih", "Validasyon"),
            new("sonrakiValidasyon", "c.sonraki_validasyon", "tarih", "Sonraki validasyon"),
            new("bugunDongu",        "c.bugun_dongu",        "sayi",  "Bugün", Hizalama: "orta"),
            new("bdBugun",           "c.bd_bugun",           "mantik", "BD bugün", Hizalama: "orta"),
            new("durumAdi",          "c.durum_adi",          "metin", "Durum", Genislik: 110, Bicim: "rozet"),
            new("tur",               "c.tur",                "sayi",  "Tür Kodu", Varsayilan: false),
            new("durum",             "c.durum",              "sayi",  "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi SterilProgram() => new(
        Ad: "steril-program",
        YetkiKodu: "steril.ayar",
        Kaynak: "public.v_steril_program p",
        SubeKolonu: null,
        VarsayilanSirala: "p.test, p.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "p.id",         "sayi",  "Id", Varsayilan: false),
            new("ad",         "p.ad",         "metin", "Program", Genislik: 180),
            new("cihazAdi",   "p.cihaz_adi",  "metin", "Cihaz", Genislik: 120),
            new("sicaklik",   "p.sicaklik",   "sayi",  "°C", Hizalama: "sag"),
            new("platoDk",    "p.plato_dk",   "sayi",  "Plato (dk)", Hizalama: "sag"),
            new("kurutmaDk",  "p.kurutma_dk", "sayi",  "Kurutma (dk)", Hizalama: "sag"),
            new("uygunYuk",   "p.uygun_yuk",  "metin", "Uygun yük", Genislik: 220),
            new("test",       "p.test",       "mantik", "Test", Hizalama: "orta"),
            new("varsayilan", "p.varsayilan", "mantik", "Varsayılan", Hizalama: "orta"),
            new("aktifAdi",   "p.aktif_adi",  "metin", "Durum", Genislik: 70, Bicim: "rozet"),
            new("aktif",      "p.aktif",      "sayi",  "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi SterilKullanim() => new(
        Ad: "steril-kullanim",
        YetkiKodu: "steril.izleme",
        Kaynak: "public.v_steril_paket_kullanim k",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "k.zaman desc, k.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "k.id",            "sayi",  "Id", Varsayilan: false),
            new("zaman",        "k.zaman",         "zaman", "Zaman", Genislik: 130),
            new("unite",        "k.unite",         "metin", "Ünite", Genislik: 80),
            new("hastaAdi",     "k.hasta_adi",     "metin", "Hasta", Genislik: 180),
            new("dosyaNo",      "k.dosya_no",      "metin", "Dosya no", Genislik: 90, Varsayilan: false),
            new("belgeNo",      "k.belge_no",      "metin", "Başvuru / seans", Genislik: 120),
            new("hekimAdi",     "k.hekim_adi",     "metin", "Hekim", Genislik: 150),
            new("paketBarkod",  "k.paket_barkod",  "metin", "Paket", Genislik: 170),
            new("birimAdi",     "k.birim_adi",     "metin", "İçerik", Genislik: 180),
            new("cihazAdi",     "k.cihaz_adi",     "metin", "Cihaz", Genislik: 90),
            new("donguNo",      "k.dongu_no",      "sayi",  "Döngü", Hizalama: "orta"),
            new("okutanAdi",    "k.okutan_adi",    "metin", "Okutan", Genislik: 120),
            new("notu",         "k.notu",          "metin", "Not", Genislik: 200, Varsayilan: false),
            new("tarafId",      "k.taraf_id",      "sayi",  "Hasta Id", Varsayilan: false),
            new("paketId",      "k.paket_id",      "sayi",  "Paket Id", Varsayilan: false),
            new("donguId",      "k.dongu_id",      "sayi",  "Döngü Id", Varsayilan: false),
            new("bioSonuc",     "k.bio_sonuc",     "sayi",  "Biyolojik", Varsayilan: false),
        });

    private static KaynakTanimi SterilBakim() => new(
        Ad: "steril-bakim",
        YetkiKodu: "steril.ayar",
        Kaynak: "public.v_steril_bakim m",
        SubeKolonu: null,
        VarsayilanSirala: "m.tarih desc, m.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "m.id",            "sayi",  "Id", Varsayilan: false),
            new("tarih",        "m.tarih",         "tarih", "Tarih"),
            new("cihazAdi",     "m.cihaz_adi",     "metin", "Cihaz", Genislik: 130),
            new("turAdi",       "m.tur_adi",       "metin", "İşlem", Genislik: 140, Bicim: "rozet"),
            new("yapan",        "m.yapan",         "metin", "Yapan", Genislik: 130),
            new("sonuc",        "m.sonuc",         "metin", "Sonuç", Genislik: 200),
            new("sonrakiTarih", "m.sonraki_tarih", "tarih", "Sonraki"),
            new("kalanGun",     "m.kalan_gun",     "sayi",  "Kalan gün", Hizalama: "sag"),
            new("belgeNo",      "m.belge_no",      "metin", "Belge", Genislik: 90, Varsayilan: false),
            new("cihazId",      "m.cihaz_id",      "sayi",  "Cihaz Id", Varsayilan: false),
        });

    private static KaynakTanimi SterilGeriCagirma() => new(
        Ad: "steril-geri-cagirma",
        YetkiKodu: "steril.izleme",
        Kaynak: "public.v_steril_geri_cagirma g",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",              "g.id",              "sayi",  "Id", Varsayilan: false),
            new("ekleme_tarihi",   "g.ekleme_tarihi",   "zaman", "Açılış", Genislik: 130),
            new("cihazAdi",        "g.cihaz_adi",       "metin", "Cihaz", Genislik: 110),
            new("tetikDonguNo",    "g.tetik_dongu_no",  "sayi",  "Pozitif döngü", Hizalama: "orta"),
            new("etkilenenDongu",  "g.etkilenen_dongu", "sayi",  "Döngü", Hizalama: "orta"),
            new("etkilenenPaket",  "g.etkilenen_paket", "sayi",  "Paket", Hizalama: "orta"),
            new("kullanilanPaket", "g.kullanilan_paket","sayi",  "Kullanılmış", Hizalama: "orta"),
            new("hastaSayisi",     "g.hasta_sayisi",    "sayi",  "Hasta", Hizalama: "orta"),
            new("durumAdi",        "g.durum_adi",       "metin", "Durum", Genislik: 90, Bicim: "rozet"),
            new("acanAdi",         "g.acan_adi",        "metin", "Açan", Genislik: 130),
            new("kapanis",         "g.kapanis",         "zaman", "Kapanış", Varsayilan: false),
            new("aciklama",        "g.aciklama",        "metin", "Açıklama", Genislik: 260, Varsayilan: false),
            new("durum",           "g.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
        });
}

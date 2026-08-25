namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kasa, banka, cek/senet, muhasebe ve ekstre listeleri (071-080).
///
/// KaynakKatalogu tek dosyada 1389 satira ulasmisti; tanimlar konu basina
/// partial dosyalara ayrildi. Sozluk, Bul/Tumu ve kayit sirasi ana dosyada.
/// </summary>
public static partial class KaynakKatalogu
{
    // ------------------------------------------------------- mali hareket ----
    // BACAK listesi (kasa_islem basliginin altindaki tekil satirlar). 080 gocuyle
    //   "kur" ve "doviz_tutari" kolonlari DUSTU; yerine bacagin kendi dovizi
    //   (doviz_cinsi + borc/alacak) ve TL karsiligi (yerel_borc/yerel_alacak) geldi.
    private static KaynakTanimi MaliHareket() => new(
        Ad: "mali-hareket",
        YetkiKodu: "mali_hareket",
        Kaynak: """
            public.mali_hareket mh
            left join public.taraf t            on t.id  = mh.taraf_id
            left join public.hesap h            on h.id  = mh.hesap_id
            left join public.kasa_islem ki      on ki.id = mh.kasa_islem_id
            left join public.kasa_islem_turu kt on kt.kod = mh.tur
            left join public.masraf ma          on ma.id = mh.masraf_id
            left join public.hizmet hz          on hz.id = mh.hizmet_id
            left join public.proje p            on p.id  = coalesce(mh.proje_id, ki.proje_id)
            """,
        SubeKolonu: "mh.sube_id",
        KapsamKolonu: "mh.taraf_id",
        VarsayilanSirala: "mh.islem_tarihi desc, mh.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "mh.id",            "sayi",  "Id",       Varsayilan: false),
            new("islemTarihi",  "mh.islem_tarihi",  "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "kt.ad",            "metin", "Islem"),
            new("tur",          "mh.tur",           "kod",   "Tur Kodu", Hizalama: "orta", Varsayilan: false),
            new("hesapTuru",    "mh.hesap_turu",    "metin", "Hesap Turu", Hizalama: "orta", Varsayilan: false),
            new("hesapAdi",     "h.ad",             "metin", "Hesap"),
            new("makbuzNo",     "ki.islem_no",      "metin", "Makbuz No", Varsayilan: false),
            new("belgeNo",      "mh.belge_no",      "metin", "Belge No"),
            new("tarafUnvan",   "t.unvan",          "metin", "Cari",     Genislik: 200),
            new("aciklama",     "mh.aciklama",      "metin", "Aciklama", Genislik: 220),
            new("borc",         "mh.borc",          "para",  "Borc",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("alacak",       "mh.alacak",        "para",  "Alacak",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",   "mh.doviz_cinsi",   "metin", "Doviz",    Hizalama: "orta"),
            new("dovizKuru",    "mh.doviz_kuru",    "para",  "Kur",      Hizalama: "sag", Varsayilan: false),
            new("yerelBorc",    "mh.yerel_borc",    "para",  "TL Borc",  Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("yerelAlacak",  "mh.yerel_alacak",  "para",  "TL Alacak",Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("masrafAdi",    "ma.ad",            "metin", "Gider Kalemi", Varsayilan: false),
            new("hizmetAdi",    "hz.ad",            "metin", "Gelir Kalemi", Varsayilan: false),
            new("projeAdi",     "p.ad",             "metin", "Proje",    Varsayilan: false),
            new("kasaIslemId",  "mh.kasa_islem_id", "sayi",  "Islem Id", Varsayilan: false),
            new("subeId",       "mh.sube_id",       "sayi",  "Sube",     Varsayilan: false)
        });

    // ------------------------------------------------------------ e-belge ----

    // ============================================================ KASA ====

    // --------------------------------------------------------------- hesap ----
    // Kasa / banka / POS / kredi karti / kredi tek tabloda (K1). Ayni kaynak
    //   web'de 4 ayri ekran olarak kullanilir: sabitFiltre tur='K'/'B'/'P'/'V'
    //   (Musteri/Tedarikci deseni). Bakiye v_hesap_bakiye'den okunur.
    private static KaynakTanimi Hesap() => new(
        Ad: "hesap",
        YetkiKodu: "hesap",
        Kaynak: """
            public.hesap h
            left join public.v_hesap_bakiye b on b.hesap_id = h.id
            left join public.hesap bh on bh.id = h.bagli_hesap_id
            """,
        SubeKolonu: "h.sube_id",
        VarsayilanSirala: "h.tur asc, h.kod asc, h.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "h.id",            "sayi",  "Id",   Varsayilan: false),
            // Tur kolonu GIZLI: her hesap ekrani (Kasa/Banka/POS/Kredi Karti/Kredi)
            //   zaten TEK turu gosteriyor, her satirda ayni harf tekrarliyordu.
            new("tur",         "h.tur",           "metin", "Tur",  Hizalama: "orta", Varsayilan: false),
            new("kod",         "h.kod",           "metin", "Kod"),
            new("ad",          "h.ad",            "metin", "Hesap Adi", Genislik: 220),
            new("dovizCinsi",  "h.doviz_cinsi",   "metin", "Doviz", Hizalama: "orta"),
            new("bakiye",      "coalesce(b.bakiye, 0)",       "para", "Bakiye",     Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("yerelBakiye", "coalesce(b.yerel_bakiye, 0)", "para", "TL Bakiye",  Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("bankaAdi",    "h.banka_adi",     "metin", "Banka",   Varsayilan: false),
            new("iban",        "h.iban",          "metin", "IBAN",    Varsayilan: false),
            new("hesapNo",     "h.hesap_no",      "metin", "Hesap No", Varsayilan: false),
            new("bagliHesap",  "bh.ad",           "metin", "Bagli Hesap", Varsayilan: false),
            // Durum METIN olarak: liste katmani kod listesi cozmuyordu, gridde
            //   ham 0/1 gorunuyordu. Metin gelince GenGrid yesil/kirmizi rozet basar.
            new("durumAdi",    "case h.durum when 1 then 'Aktif' else 'Pasif' end",
                                                  "metin", "Durum",   Hizalama: "orta",
                                                  Genislik: 90, Filtrelenebilir: false),
            new("durum",       "h.durum",         "kod",   "Durum Kodu", Hizalama: "orta",
                                                  Varsayilan: false),
            new("subeId",      "h.sube_id",       "sayi",  "Sube",    Varsayilan: false)
        });

    // ----------------------------------------------------------- cek/senet ----

    // --------------------------------------------------------------- banka ----
    private static KaynakTanimi BankaListesi() => new(
        Ad: "banka",
        YetkiKodu: "hesap",
        Kaynak: "public.banka b",
        SubeKolonu: null,
        VarsayilanSirala: "b.sira, b.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "b.id",      "sayi",  "Id", Varsayilan: false),
            new("kod",     "b.kod",     "metin", "EFT Kodu", Hizalama: "orta"),
            new("ad",      "b.ad",      "metin", "Banka Adı", Genislik: 280),
            new("kisaAd",  "b.kisa_ad", "metin", "Kısa Ad"),
            new("swift",   "b.swift",   "metin", "SWIFT", Varsayilan: false),
            new("subeSayisi",
                "(select count(*) from public.banka_sube s where s.banka_id = b.id)",
                                        "sayi",  "Şube", Hizalama: "sag",
                                        Siralanabilir: false, Filtrelenebilir: false),
            new("durumAdi", "case b.aktif when 1 then 'Aktif' else 'Pasif' end",
                                        "metin", "Durum", Hizalama: "orta"),
            new("aktif",   "b.aktif",   "sayi",  "Durum Kodu", Varsayilan: false),
        });

    // --------------------------------------------------- stok transferi ----
    // Ayni `belge` tablosu, tur 20. Ayri kaynak: transferde CARI ve TUTAR yoktur,
    //   bunun yerine IKI DEPO ve miktar konusur - genel belge listesinin cari/tutar
    //   kolonlari burada hep bos kalirdi.

    // ----------------------------------------------------------- cek/senet ----
    private static KaynakTanimi CekSenet() => new(
        Ad: "cek-senet",
        YetkiKodu: "cek_senet",
        Kaynak: """
            public.cek_senet c
            left join public.taraf t on t.id = c.taraf_id
            left join public.hesap h on h.id = c.hesap_id
            """,
        SubeKolonu: "c.sube_id",
        KapsamKolonu: "c.taraf_id",
        VarsayilanSirala: "c.vade asc, c.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "c.id",           "sayi",  "Id",     Varsayilan: false),
            new("tur",         "c.tur",          "kod",   "Tur",    Hizalama: "orta"),
            new("yon",         "c.yon",          "kod",   "Yon",    Hizalama: "orta"),
            new("seriNo",      "c.seri_no",      "metin", "Seri No"),
            new("tarafUnvan",  "t.unvan",        "metin", "Cari",   Genislik: 200),
            new("kesideci",    "c.kesideci",     "metin", "Kesideci", Varsayilan: false),
            new("tarih",       "c.tarih",        "tarih", "Tarih",  Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("vade",        "c.vade",         "tarih", "Vade",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tutar",       "c.tutar",        "para",  "Tutar",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",  "c.doviz_cinsi",  "metin", "Doviz",  Hizalama: "orta"),
            new("yerelTutar",  "c.yerel_tutar",  "para",  "TL Tutar", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("bankaAdi",    "c.banka_adi",    "metin", "Banka",  Varsayilan: false),
            new("hesapAdi",    "h.ad",           "metin", "Bulundugu Hesap", Varsayilan: false),
            new("durum",       "c.durum",        "kod",   "Durum",  Hizalama: "orta"),
            new("subeId",      "c.sube_id",      "sayi",  "Sube",   Varsayilan: false)
        });

    // --------------------------------------------------------------- proje ----

    // --------------------------------------------------------------- proje ----
    private static KaynakTanimi Proje() => new(
        Ad: "proje",
        YetkiKodu: "proje",
        Kaynak: """
            public.proje p
            left join public.taraf t  on t.id = p.taraf_id
            left join public.taraf so on so.id = p.sorumlu_id
            """,
        VarsayilanSirala: "p.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "p.id",          "sayi",  "Id",   Varsayilan: false),
            new("kod",        "p.kod",         "metin", "Kod"),
            new("ad",         "p.ad",          "metin", "Proje Adi", Genislik: 240),
            new("tarafUnvan", "t.unvan",       "metin", "Musteri",   Genislik: 200),
            new("sorumlu",    "so.unvan",      "metin", "Sorumlu",   Varsayilan: false),
            new("baslangic",  "p.baslangic",   "tarih", "Baslangic", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("bitis",      "p.bitis",       "tarih", "Bitis",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("butceTutar", "p.butce_tutar", "para",  "Butce",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("butceDovizi","p.butce_dovizi","metin", "Doviz",     Hizalama: "orta", Varsayilan: false),
            new("durum",      "p.durum",       "kod",   "Durum",     Hizalama: "orta")
        });

    // ------------------------------------------------------ masraf merkezi ----

    // ------------------------------------------------------ masraf merkezi ----
    private static KaynakTanimi MasrafMerkezi() => new(
        Ad: "masraf-merkezi",
        YetkiKodu: "masraf_merkezi",
        Kaynak: "public.masraf_merkezi m left join public.masraf_merkezi u on u.id = m.ust_id",
        VarsayilanSirala: "m.kod asc, m.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "m.id",    "sayi",  "Id",  Varsayilan: false),
            new("kod",    "m.kod",   "metin", "Kod"),
            new("ad",     "m.ad",    "metin", "Merkez Adi", Genislik: 240),
            new("ustAd",  "u.ad",    "metin", "Ust Merkez", Varsayilan: false),
            new("durum",  "m.durum", "kod",   "Durum", Hizalama: "orta")
        });

    // ---------------------------------------------------------- hesap plani ----

    // ---------------------------------------------------------- hesap plani ----
    private static KaynakTanimi HesapPlani() => new(
        Ad: "hesap-plani",
        YetkiKodu: "hesap_plani",
        Kaynak: "public.hesap_plani hp",
        VarsayilanSirala: "hp.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "hp.id",             "sayi",  "Id",  Varsayilan: false),
            new("kod",          "hp.kod",            "metin", "Hesap Kodu"),
            new("ad",           "hp.ad",             "metin", "Hesap Adi", Genislik: 280),
            new("sinif",        "hp.sinif",          "kod",   "Sinif",  Hizalama: "orta"),
            new("seviye",       "hp.seviye",         "sayi",  "Seviye", Hizalama: "orta", Varsayilan: false),
            new("calisirMi",    "hp.calisir_mi",     "mantik","Calisir", Hizalama: "orta"),
            new("cariAltHesap", "hp.cari_alt_hesap", "mantik","Cari Alt Hesap", Hizalama: "orta", Varsayilan: false),
            new("dovizCinsi",   "hp.doviz_cinsi",    "metin", "Doviz", Hizalama: "orta", Varsayilan: false),
            new("durum",        "hp.durum",          "kod",   "Durum", Hizalama: "orta")
        });

    // ------------------------------------------------------- islem turu ----

    // ------------------------------------------------------- islem turu ----
    private static KaynakTanimi KasaIslemTuru() => new(
        Ad: "kasa-islem-turu",
        YetkiKodu: "kasa_islem_turu",
        Kaynak: "public.kasa_islem_turu t",
        VarsayilanSirala: "t.sira asc, t.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("kod",         "t.kod",          "sayi",  "Kod",  Hizalama: "sag"),
            new("ad",          "t.ad",           "metin", "Islem Turu", Genislik: 220),
            new("grup",        "t.grup",         "metin", "Grup", Hizalama: "orta"),
            new("yon",         "t.yon",          "sayi",  "Yon",  Hizalama: "orta", Varsayilan: false),
            new("cariEkstre",  "t.cari_ekstre",  "mantik","Cari Ekstre",  Hizalama: "orta"),
            new("hesapEkstre", "t.hesap_ekstre", "mantik","Hesap Ekstre", Hizalama: "orta", Varsayilan: false),
            new("bakiyeDahil", "t.bakiye_dahil", "mantik","Bakiyeye Dahil", Hizalama: "orta"),
            new("fisMi",       "t.fis_mi",       "mantik","Fis Uretir", Hizalama: "orta"),
            new("makbuzSeri",  "t.makbuz_seri",  "metin", "Seri", Hizalama: "orta", Varsayilan: false),
            new("aktif",       "t.aktif",        "mantik","Aktif", Hizalama: "orta")
        });

    // ------------------------------------------------------------- firsat ----
    // CRM satis firsati listesi (121, mockup firsat_listesi.html). AGIRLIKLI
    //   tutar gorunumde hesaplanir (tutar x olasilik) - saklanan bir kolon
    //   olsaydi olasilik degisince bayatlardi.

    // ---------------------------------------------------------- ekstreler ----
    // Yuruyen bakiye SIRAYA bagli oldugu icin bakiye kolonu siralanamaz -
    //   kullanici siralamayi degistirse "bakiye" anlamsizlasirdi.
    //
    // EKSTRELER PARA BIRIMI BAZINDA GRUPLU (111): once yerel para (TL)
    //   hareketleri ve ara toplami, sonra USD, sonra EUR... en altta yerel para
    //   cinsinden genel toplam. Farkli para birimlerini tek yuruyen bakiyede
    //   toplamak (eski hali) anlamsiz bir sayi uretiyordu.
    private static KaynakTanimi HesapEkstre() => new(
        Ad: "hesap-ekstre",
        YetkiKodu: "hesap",
        Kaynak: "public.v_hesap_ekstre e",
        SubeKolonu: "e.sube_id",
        GrupKolonu: "dovizCinsi",
        GrupSiraKolonu: "dovizSira",
        VarsayilanSirala: "e.doviz_sira asc, e.doviz_cinsi asc, e.islem_tarihi asc, e.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",            "sayi",  "Id", Varsayilan: false),
            new("hesapId",      "e.hesap_id",      "sayi",  "Hesap Id", Varsayilan: false),
            // Cift tik hedefi (gizli): satiri ureten kasa islemi / belge.
            new("kasaIslemId",  "e.kasa_islem_id", "sayi",  "Kasa Islem Id", Varsayilan: false),
            new("belgeId",      "e.belge_id",      "sayi",  "Belge Id", Varsayilan: false),
            new("hesapAdi",     "e.hesap_adi",     "metin", "Hesap", Varsayilan: false),
            new("islemTarihi",  "e.islem_tarihi",  "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "e.tur_adi",       "metin", "Islem"),
            new("islemNo",      "e.islem_no",      "metin", "Makbuz No"),
            new("belgeNo",      "e.belge_no",      "metin", "Belge No", Varsayilan: false),
            new("tarafUnvan",   "e.taraf_unvan",   "metin", "Cari", Genislik: 200),
            new("aciklama",     "e.aciklama",      "metin", "Aciklama", Genislik: 220),
            // Doviz tutarlari GRUP ICINDE toplanir; en alttaki genel toplamda yer
            //   almazlar (USD giris ile TL girisi toplamak anlamsiz).
            new("giris",        "e.giris",         "para",  "Giris",  Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            new("cikis",        "e.cikis",         "para",  "Cikis",  Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            // Bakiye TOPLANMAZ: grubun son satirindaki deger o para biriminin
            //   kapanis bakiyesidir.
            new("bakiye",       "e.bakiye",        "para",  "Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, SadeceGrupToplami: true, GrupKapanisi: true),
            // Para birimi grup basliginda yaziyor; kolon olarak da acilabilir.
            new("dovizCinsi",   "e.doviz_cinsi",   "metin", "Doviz",  Hizalama: "orta", Varsayilan: false),
            new("dovizSira",    "e.doviz_sira",    "sayi",  "Doviz Sira", Varsayilan: false),
            new("dovizKuru",    "e.doviz_kuru",    "para",  "Kur",    Hizalama: "sag", Bicim: "#,##0.0000", Varsayilan: false),
            // Yerel karsiliklar GORUNUR: gruplu ekstrede genel toplam ancak yerel
            //   parada anlamli, gizli kolonun toplami da kullaniciya ulasmaz.
            new("yerelBorc",    "e.yerel_borc",    "para",  "Yerel Giris",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelAlacak",  "e.yerel_alacak",  "para",  "Yerel Cikis",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelBakiye",  "e.yerel_bakiye",  "para",  "Yerel Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false, SadeceGrupToplami: true, GrupKapanisi: true),
            new("subeId",       "e.sube_id",       "sayi",  "Sube",   Varsayilan: false)
        });

    private static KaynakTanimi CariEkstre() => new(
        Ad: "cari-ekstre",
        YetkiKodu: "mali_hareket",
        Kaynak: "public.v_cari_ekstre e",
        SubeKolonu: "e.sube_id",
        KapsamKolonu: "e.taraf_id",
        GrupKolonu: "dovizCinsi",
        GrupSiraKolonu: "dovizSira",
        VarsayilanSirala: "e.doviz_sira asc, e.doviz_cinsi asc, e.islem_tarihi asc, e.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",           "sayi",  "Id", Varsayilan: false),
            new("tarafId",      "e.taraf_id",     "sayi",  "Cari Id", Varsayilan: false),
            // Cift tik hedefi (gizli): satiri ureten kasa islemi / belge.
            new("kasaIslemId",  "e.kasa_islem_id","sayi",  "Kasa Islem Id", Varsayilan: false),
            new("belgeId",      "e.belge_id",     "sayi",  "Belge Id", Varsayilan: false),
            new("tarafUnvan",   "e.taraf_unvan",  "metin", "Cari", Genislik: 220),
            new("islemTarihi",  "e.islem_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "e.tur_adi",      "metin", "Islem"),
            new("islemNo",      "e.islem_no",     "metin", "Makbuz No", Varsayilan: false),
            new("belgeNo",      "e.belge_no",     "metin", "Belge No"),
            new("aciklama",     "e.aciklama",     "metin", "Aciklama", Genislik: 220),
            // GRUP para biriminde: satirin kendi biriminde borc/alacak/bakiye.
            //   Grup basligi hangi birim oldugunu soyler, kolon basliginda tekrar
            //   edilmez ("Doviz Borc" gibi bir baslik gruplu ekranda gereksiz).
            new("borc",         "e.borc",         "para",  "Borc",   Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            new("alacak",       "e.alacak",       "para",  "Alacak", Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            new("dovizKuru",    "e.doviz_kuru",   "para",  "Kur",    Hizalama: "sag", Bicim: "#,##0.0000"),
            // Yerel karsilik HAREKETIN KENDI KURUYLA (kayit anindaki), ekstre
            //   gununun kuruyla degil - gecmise donuk ekstre hep ayni cikmali.
            new("yerelBorc",    "e.yerel_borc",   "para",  "Yerel Borc",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelAlacak",  "e.yerel_alacak", "para",  "Yerel Alacak", Hizalama: "sag", Bicim: "#,##0.00"),
            // Bakiye TOPLANMAZ - grubun son satirindaki deger kapanis bakiyesidir.
            new("bakiye",       "e.bakiye",       "para",  "Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, SadeceGrupToplami: true, GrupKapanisi: true),
            new("yerelBakiye",  "e.yerel_bakiye", "para",  "Yerel Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false, SadeceGrupToplami: true, GrupKapanisi: true),
            new("dovizCinsi",   "e.doviz_cinsi",  "metin", "Doviz",  Hizalama: "orta", Varsayilan: false),
            new("dovizSira",    "e.doviz_sira",   "sayi",  "Doviz Sira", Varsayilan: false),
            new("planTarihi",   "e.plan_tarihi",  "tarih", "Vade", Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("subeId",       "e.sube_id",      "sayi",  "Sube", Varsayilan: false)
        });

    // ---------------------------------------------------------- kasa islem ----
    // Baslik listesi (makbuz seviyesi). Bacaklar "mali-hareket" listesindedir;
    //   ikisi ayni veriye iki farkli granulariteden bakar.

    // ---------------------------------------------------------- kasa islem ----
    // Baslik listesi (makbuz seviyesi). Bacaklar "mali-hareket" listesindedir;
    //   ikisi ayni veriye iki farkli granulariteden bakar.
    private static KaynakTanimi KasaIslem() => new(
        Ad: "kasa-islem",
        YetkiKodu: "kasa_islem",
        Kaynak: """
            public.kasa_islem ki
            join      public.kasa_islem_turu kt on kt.kod = ki.tur
            left join public.taraf t            on t.id   = ki.taraf_id
            left join public.hesap h            on h.id   = ki.hesap_id
            left join public.hesap kh           on kh.id  = ki.karsi_hesap_id
            left join public.proje p            on p.id   = ki.proje_id
            left join public.muhasebe_fis f     on f.id   = ki.muhasebe_fis_id
            """,
        SubeKolonu: "ki.sube_id",
        KapsamKolonu: "ki.taraf_id",
        VarsayilanSirala: "ki.islem_tarihi desc, ki.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "ki.id",                "sayi",  "Id",        Varsayilan: false),
            new("islemTarihi",   "ki.islem_tarihi",      "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",        "kt.ad",                "metin", "İşlem",     Genislik: 180),
            new("tur",           "ki.tur",               "sayi",  "Tür Kodu",  Hizalama: "orta", Varsayilan: false),
            new("turGrup",       "kt.grup",              "metin", "Grup",      Hizalama: "orta", Varsayilan: false),
            new("islemNo",       "ki.islem_no",          "metin", "Makbuz No"),
            new("tarafUnvan",    "coalesce(t.unvan, ki.taraf_unvan)", "metin", "Cari", Genislik: 220),
            new("hesapAdi",      "h.ad",                 "metin", "Hesap",     Genislik: 180),
            new("karsiHesapAdi", "kh.ad",                "metin", "Karşı Hesap", Varsayilan: false),
            new("tutar",         "ki.tutar",             "para",  "Tutar",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",    "ki.doviz_cinsi",       "metin", "Döviz",     Hizalama: "orta"),
            new("dovizKuru",     "ki.doviz_kuru",        "para",  "Kur",       Hizalama: "sag", Varsayilan: false),
            new("yerelTutar",    "ki.yerel_tutar",       "para",  "TL Tutar",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("projeAdi",      "p.ad",                 "metin", "Proje",     Varsayilan: false),
            new("planTarihi",    "ki.plan_tarihi",       "tarih", "Vade",      Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("kalanTutar",    "ki.kalan_tutar",       "para",  "Kalan",     Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("fisNo",         "f.fis_no",             "metin", "Fiş No",    Varsayilan: false),
            new("muhasebeFisId", "ki.muhasebe_fis_id",   "sayi",  "Fiş Id",    Varsayilan: false),
            new("durum",         "ki.durum",             "kod",   "Durum",     Hizalama: "orta"),
            new("aciklama",      "ki.aciklama",          "metin", "Açıklama",  Genislik: 240),
            new("iptalIslemId",  "ki.iptal_islem_id",    "sayi",  "Ters İşlem", Varsayilan: false),
            // Belge kartinin "Tahsilat" sekmesi bu kolonla suzuyor (belge basina
            //   tahsilat/odeme listesi).
            new("belgeId",       "ki.belge_id",          "sayi",  "Belge Id",  Varsayilan: false),
            new("subeId",        "ki.sube_id",           "sayi",  "Şube",      Varsayilan: false)
        });

    // ------------------------------------------------------- muhasebe fisi ----

    // ------------------------------------------------------- muhasebe fisi ----
    private static KaynakTanimi MuhasebeFis() => new(
        Ad: "muhasebe-fis",
        YetkiKodu: "muhasebe_fis",
        Kaynak: """
            public.muhasebe_fis f
            left join public.muhasebe_donem d on d.id = f.donem_id
            """,
        SubeKolonu: "f.sube_id",
        VarsayilanSirala: "f.fis_tarihi desc, f.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "f.id",            "sayi",  "Id",       Varsayilan: false),
            new("fisNo",        "f.fis_no",        "metin", "Fiş No"),
            new("fisTarihi",    "f.fis_tarihi",    "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tur",          "f.tur",           "kod",   "Fiş Türü", Hizalama: "orta"),
            new("durum",        "f.durum",         "kod",   "Durum",    Hizalama: "orta"),
            new("kaynakTur",    "f.kaynak_tur",    "kod",   "Kaynak",   Hizalama: "orta"),
            new("kaynakId",     "f.kaynak_id",     "sayi",  "Kaynak Id", Varsayilan: false),
            new("toplamBorc",   "f.toplam_borc",   "para",  "Borç",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("toplamAlacak", "f.toplam_alacak", "para",  "Alacak",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("aciklama",     "f.aciklama",      "metin", "Açıklama", Genislik: 280),
            new("tersFisId",    "f.ters_fis_id",   "sayi",  "Ters Fiş", Varsayilan: false),
            new("donem",        "case when d.id is null then '' else lpad(d.ay::text, 2, '0') || '.' || d.yil::text end",
                                                    "metin", "Dönem",    Hizalama: "orta", Varsayilan: false),
            new("subeId",       "f.sube_id",       "sayi",  "Şube",     Varsayilan: false)
        });

    private static KaynakTanimi MuhasebeFisSatir() => new(
        Ad: "muhasebe-fis-satir",
        YetkiKodu: "muhasebe_fis",
        Kaynak: """
            public.muhasebe_fis_satir s
            join      public.muhasebe_fis f  on f.id  = s.fis_id
            join      public.hesap_plani hp  on hp.id = s.hesap_plani_id
            left join public.taraf t         on t.id  = s.taraf_id
            left join public.proje p         on p.id  = s.proje_id
            """,
        SubeKolonu: "f.sube_id",
        VarsayilanSirala: "f.fis_tarihi desc, s.fis_id desc, s.sira",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "s.id",         "sayi",  "Id",      Varsayilan: false),
            new("fisId",      "s.fis_id",     "sayi",  "Fiş Id",  Varsayilan: false),
            new("fisNo",      "f.fis_no",     "metin", "Fiş No"),
            new("fisTarihi",  "f.fis_tarihi", "tarih", "Tarih",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("sira",       "s.sira",       "sayi",  "Sıra",    Hizalama: "orta", Varsayilan: false),
            new("hesapKodu",  "hp.kod",       "metin", "Hesap Kodu"),
            new("hesapAdi",   "hp.ad",        "metin", "Hesap Adı", Genislik: 240),
            new("borc",       "s.borc",       "para",  "Borç",    Hizalama: "sag", Bicim: "#,##0.00"),
            new("alacak",     "s.alacak",     "para",  "Alacak",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi", "s.doviz_cinsi","metin", "Döviz",   Hizalama: "orta", Varsayilan: false),
            new("tarafUnvan", "t.unvan",      "metin", "Cari",    Varsayilan: false),
            new("projeAdi",   "p.ad",         "metin", "Proje",   Varsayilan: false),
            new("aciklama",   "s.aciklama",   "metin", "Açıklama", Genislik: 260)
        });

    // ------------------------------------------------------- vade / planlar ----
    // Acik planlar (durum 1): beklenen tahsilat/odemeler. `gecikmeGun` pozitifse
    //   vade gecmis - listenin varsayilan sirasi en gecikmisi ustte.

    // ------------------------------------------------------- vade / planlar ----
    // Acik planlar (durum 1): beklenen tahsilat/odemeler. `gecikmeGun` pozitifse
    //   vade gecmis - listenin varsayilan sirasi en gecikmisi ustte.
    private static KaynakTanimi PlanVade() => new(
        Ad: "plan-vade",
        YetkiKodu: "kasa_islem",
        Kaynak: "public.v_plan_vade v",
        SubeKolonu: "v.sube_id",
        KapsamKolonu: "v.taraf_id",
        VarsayilanSirala: "v.plan_tarihi asc, v.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",               "v.id",                "sayi",  "Id",     Varsayilan: false),
            new("planTarihi",       "v.plan_tarihi",       "tarih", "Vade",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("gecikmeGun",       "v.gecikme_gun",       "sayi",  "Gecikme (gün)", Hizalama: "sag"),
            new("turAdi",           "v.tur_adi",           "metin", "Plan Türü"),
            new("turGrup",          "v.tur_grup",          "metin", "Grup",   Hizalama: "orta", Varsayilan: false),
            new("tarafUnvan",       "v.taraf_unvan",       "metin", "Cari",   Genislik: 220),
            new("tutar",            "v.tutar",             "para",  "Plan Tutarı", Hizalama: "sag", Bicim: "#,##0.00"),
            new("gerceklesenTutar", "v.gerceklesen_tutar", "para",  "Gerçekleşen", Hizalama: "sag", Bicim: "#,##0.00"),
            new("kalanTutar",       "v.kalan_tutar",       "para",  "Kalan",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",       "v.doviz_cinsi",       "metin", "Döviz",  Hizalama: "orta"),
            new("yerelTutar",       "v.yerel_tutar",       "para",  "TL Tutar", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("projeId",          "v.proje_id",          "sayi",  "Proje Id", Varsayilan: false),
            new("aciklama",         "v.aciklama",          "metin", "Açıklama", Genislik: 240),
            new("subeId",           "v.sube_id",           "sayi",  "Şube",   Varsayilan: false)
        });

    // ------------------------------------------- stok belgeleri: ortak kolonlar ----
    // Transfer / talep / giris-cikis fisi listeleri ayni kuyrugu paylasiyor:
    //   kac kalem, toplam miktar, aciklama, durum, sube. Uc yere kopyalanmisti;
    //   yeni bir stok belgesi eklenince dorduncu kopya olacakti.
}

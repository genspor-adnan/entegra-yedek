namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Stok, depo ve stok belgesi listeleri.
///
/// KaynakKatalogu tek dosyada 1389 satira ulasmisti; tanimlar konu basina
/// partial dosyalara ayrildi. Sozluk, Bul/Tumu ve kayit sirasi ana dosyada.
/// </summary>
public static partial class KaynakKatalogu
{
    // --------------------------------------------------------------- stok ----
    /// <summary>
    /// Stok kart fiyati kolonu (128). Kural fn_stok_kart_fiyat'ta; burada yalniz
    /// hangi alanin (fiyat / doviz) ve hangi listenin (satis / alis) istendigi
    /// secilir - dort kolon ayni sarti kopyalamasin.
    /// </summary>
    private static string StokFiyatSql(bool satis, bool doviz = false)
        => $"(select {(doviz ? "doviz_cinsi" : "fiyat")} " +
           $"from public.fn_stok_kart_fiyat(s.id, {(satis ? 1 : 0)}::smallint))";

    private static KaynakTanimi Stok() => new(
        Ad: "stok",
        YetkiKodu: "stok",
        Kaynak: "public.stok s",
        VarsayilanSirala: "s.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "s.id",        "sayi",  "Id",       Varsayilan: false),
            new("kod",       "s.kod",       "metin", "Kod"),
            new("ad",        "s.ad",        "metin", "Stok Adi"),
            // Kategori ve birim ADIYLA gosterilir: kolonlar "kod" tipindeydi ve
            //   listede kod ad'a cevrilmedigi icin ekranda ham id goruluyordu.
            // KATEGORI YOLU (kullanici: "kategori icinde alt ust bilgileri de
            //   bulunsun"): yalniz yaprak adi hangi dalda oldugunu
            //   soylemiyordu - ust dal varsa "Dental El Aletleri > Frezeler".
            new("kategori",
                "(select case when u.id is null then k.ad " +
                "              else u.ad || ' > ' || k.ad end " +
                "   from public.kategori k " +
                "   left join public.kategori u on u.id = k.ust_id " +
                "  where k.id = s.kategori)",
                                            "metin", "Kategori"),
            // Kategori KIMLIGI (gizli): agac suzgeci id listesiyle suzuyor -
            //   gorunen kolon YOL metni oldugu icin onunla suzulemez.
            new("kategoriId", "s.kategori", "sayi",  "Kategori Id", Varsayilan: false),
            new("marka",     "s.marka",     "kod",   "Marka",    Varsayilan: false),
            new("model",     "s.model",     "metin", "Model",    Varsayilan: false),
            new("kdv",       "s.kdv",       "sayi",  "KDV %",    Hizalama: "sag"),
            // Kalem arama penceresi icin: VARSAYILAN depodaki kalan ve izleme
            //   turu. Kullanici "elimde var mi, seri/lot girmem gerekecek mi"
            //   sorusunu stok secerken gormeli - sonradan degil.
            new("kalan",
                "(select coalesce(sum(sd.kalan), 0) from public.stok_durum sd " +
                " join public.depo d on d.id = sd.depo_id " +
                " where sd.stok_id = s.id and d.varsayilan = 1)",
                                            "para",  "Kalan",    Hizalama: "sag", Bicim: "#,##0.##",
                                            Siralanabilir: false, Filtrelenebilir: false),
            // BIRIM, Kalan'in SAGINDA (kullanici): miktar ve birimi yan yana
            //   okumak dogal - "78 Adet".
            new("anaBirim",
                "(select kd.ad from public.kod_deger kd" +
                "   join public.kod_liste kl on kl.id = kd.liste_id" +
                "  where kl.kod = 'stok.ana_birim' and kd.deger = s.ana_birim)",
                                            "metin", "Birim",    Hizalama: "orta"),
            // Birim KODU (gizli): secim pencerelerinden gelen satirda birimi
            //   yazabilmek icin gerekli - ad ile kod eslestirmek kirilgan olurdu.
            new("anaBirimKod","s.ana_birim","sayi",  "Birim Kodu", Hizalama: "orta", Varsayilan: false),
            // YON BAYRAKLARI (141): satis belgesinde yalniz "satilan", alista
            //   yalniz "alinan" stoklar aranir. Kolon KAYNAKTA yoksa arama
            //   penceresi "Bilinmeyen alan: satilan" hatasi veriyordu - katalog
            //   filtre alanini kendi kolon listesinden dogruluyor.
            new("satilan", "s.satilan", "mantik", "Satilan", Hizalama: "orta", Varsayilan: false),
            new("alinan",  "s.alinan",  "mantik", "Alinan",  Hizalama: "orta", Varsayilan: false),
            new("izlemeAdi",
                "case s.izleme when 1 then 'Seri No' when 2 then 'Lot No' when 3 then 'SKT' " +
                "when 4 then 'Karekod' when 5 then 'Lot No + SKT' when 6 then 'Seri + Lot' else 'Yok' end",
                                            "metin", "İzleme",   Hizalama: "orta"),
            new("izleme",    "s.izleme",    "sayi",  "İzleme Kodu", Hizalama: "orta", Varsayilan: false),
            // PAKET (124): belge kalemi secimde bunu okur ve paketi ICERIGIYLE
            //   birlikte ekler.
            new("paket",     "s.paket",     "mantik","Paket",     Hizalama: "orta", Varsayilan: false),
            // Fiyat: kural TEK YERDE - fn_stok_kart_fiyat (128). Alis/satis ayri
            //   satirdir, -1 "girilmemis" demektir, en dusuk fiyat_adi esastir.
            // FIYAT ve DOVIZ stok listesinde GORUNMEZ (kullanici, hizmet
            //   listesiyle ayni karar): fiyat artik fiyat listelerinden
            //   geliyor. Kolonlar KALDIRILMADI - kalem/arama penceresi ve kur
            //   cevrimi bu alanlari okumaya devam ediyor, isteyen uc nokta
            //   menusunden geri acar.
            new("fiyat",       StokFiyatSql(satis: true),
                                            "para",  "Fiyat",    Hizalama: "sag", Bicim: "#,##0.00",
                                            Siralanabilir: false, Filtrelenebilir: false,
                                            Varsayilan: false),
            new("fiyatDovizi", $"public.fn_doviz_iso({StokFiyatSql(satis: true, doviz: true)})",
                                            "metin", "Döviz",    Hizalama: "orta",
                                            Siralanabilir: false, Filtrelenebilir: false,
                                            Varsayilan: false),
            new("alisFiyat",   StokFiyatSql(satis: false),
                                            "para",  "Alış Fiyatı", Hizalama: "sag", Bicim: "#,##0.00",
                                            Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false),
            new("alisDovizi",  StokFiyatSql(satis: false, doviz: true),
                                            "metin", "Alış Dövizi", Hizalama: "orta",
                                            Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false),
            new("minStok",   "s.min_stok",  "sayi",  "Min. Stok",Hizalama: "sag", Varsayilan: false),
            new("durum",     "s.durum",     "kod",   "Durum",    Hizalama: "orta"),
            new("urunNo",    "s.urun_no",   "metin", "Urun No",  Varsayilan: false),
            new("subeId",    "s.sube_id",   "sayi",  "Sube",     Varsayilan: false)
        });

    /// <summary>
    /// AMBALAJ BIRIMLERI (143) - kalem penceresi stok secilince bunu okur:
    /// "1 Kutu = 12 Adet". Ana birim bu listede YOKTUR (carpani 1, kartta zaten
    /// secili); arayuz onu listenin basina kendisi ekler.
    /// </summary>
    private static KaynakTanimi StokBirim() => new(
            Ad: "stok-birim",
            YetkiKodu: "stok",
            Kaynak: "public.stok_birim sb",
            VarsayilanSirala: "sb.carpan asc, sb.id asc",
            Kolonlar: new KolonTanimi[]
            {
                new("id",       "sb.id",       "sayi",  "Id", Varsayilan: false),
                new("stokId",   "sb.stok_id",  "sayi",  "Stok", Varsayilan: false),
                new("birim",    "sb.birim",    "sayi",  "Birim Kodu", Varsayilan: false),
                new("birimAdi",
                    "(select kd.ad from public.kod_deger kd" +
                    "   join public.kod_liste kl on kl.id = kd.liste_id" +
                    "  where kl.kod = 'stok.ana_birim' and kd.deger = sb.birim)",
                                               "metin", "Birim"),
                new("carpan",   "sb.carpan",   "para",  "Ana Birim Karşılığı", Hizalama: "sag"),
                new("barkod",   "sb.barkod",   "metin", "Barkod", Varsayilan: false),
                new("varsayilanAlis",  "sb.varsayilan_alis",  "mantik", "Alışta", Varsayilan: false),
                new("varsayilanSatis", "sb.varsayilan_satis", "mantik", "Satışta", Varsayilan: false),
                new("durum",    "sb.durum",    "kod",   "Durum", Hizalama: "orta", Varsayilan: false)
            });

    // ============================================================ KASA ====

    // --------------------------------------------------------------- hesap ----
    // Kasa / banka / POS / kredi karti / kredi tek tabloda (K1). Ayni kaynak
    //   web'de 4 ayri ekran olarak kullanilir: sabitFiltre tur='K'/'B'/'P'/'V'
    //   (Musteri/Tedarikci deseni). Bakiye v_hesap_bakiye'den okunur.

    // -------------------------------------------------------------- depo ----
    // Belge kartinda cikis/giris deposu ADIYLA secilir (GenLookup kaynagi).
    private static KaynakTanimi Depo() => new(
        Ad: "depo",
        YetkiKodu: "stok",
        Kaynak: "public.depo d",
        // Sube kendi depolarina EK OLARAK merkezin depolarini da gorebilir
        //   (sube.merkez_depo_kullan, 173) - duz "sube_id = X" yetmiyor.
        SubeKosulu: "d.sube_id = any(public.fn_sube_depo_subeleri({sube}))",
        VarsayilanSirala: "d.ad asc",
        // Tipi ve Durum METIN olarak uretilir: liste katmani kod listesi cozmuyor
        //   (kart cozuyor), ham kod gosterirsek kullanici sayi gorur. Ham kodlar
        //   gizli kolon olarak durur - cip/filtre onlar uzerinden calisir.
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "d.id",         "sayi",  "Id",   Varsayilan: false),
            new("ad",         "d.ad",         "metin", "Depo Adı", Genislik: 220),
            new("tipAdi",
                "case d.tip when 1 then 'Merkez' when 2 then 'Demirbaş' " +
                "when 3 then 'Konsinye Alış' when 4 then 'Konsinye Satış' else '' end",
                                              "metin", "Tipi", Genislik: 150, Filtrelenebilir: false),
            new("tip",        "d.tip",        "kod",   "Tip Kodu", Varsayilan: false),
            new("durumAdi",   "case d.durum when 1 then 'Aktif' else 'Pasif' end",
                                              "metin", "Durum", Hizalama: "orta", Genislik: 90,
                                              Filtrelenebilir: false),
            new("durum",      "d.durum",      "kod",   "Durum Kodu", Varsayilan: false),
            // Tek isaretlik kolonlar: genislik verilmezse baslik kadar yayilip
            //   satirin yarisini bos birakiyordu.
            new("maliyetiEtkilesin", "d.maliyeti_etkilesin", "mantik", "Maliyeti Etkilesin",
                                              Hizalama: "orta", Genislik: 130),
            new("varsayilan", "d.varsayilan", "mantik","Varsayılan", Hizalama: "orta", Genislik: 90),
            new("subeId",     "d.sube_id",    "sayi",  "Şube", Varsayilan: false)
        });

    // ------------------------------------------------- acik belge satirlari ----
    // "Hangi siparislerin nesi teslim edilmedi" raporu. Donusum ekrani ayri bir
    //   uctan (GET /api/belge/{id}/acik-satirlar) okur; bu liste genel gorunum.

    // ------------------------------------------- stok belgeleri: ortak kolonlar ----
    // Transfer / talep / giris-cikis fisi listeleri ayni kuyrugu paylasiyor:
    //   kac kalem, toplam miktar, aciklama, durum, sube. Uc yere kopyalanmisti;
    //   yeni bir stok belgesi eklenince dorduncu kopya olacakti.
    private static KolonTanimi[] StokBelgesiKuyrukKolonlari() => new KolonTanimi[]
    {
        // Satir-basi alt sorgu: bu listeler kucuktur (belge sayisi binlerle
        //   olculmez), maliyeti kabul edilir.
        new("kalemSayisi",
            "(select count(*) from public.belge_satir s where s.belge_id = b.id)",
                                              "sayi",  "Kalem", Hizalama: "sag",
                                              Siralanabilir: false, Filtrelenebilir: false),
        new("miktar",
            "(select coalesce(sum(s.miktar), 0) from public.belge_satir s where s.belge_id = b.id)",
                                              "para",  "Miktar", Hizalama: "sag", Bicim: "#,##0.##",
                                              Siralanabilir: false, Filtrelenebilir: false),
        new("aciklama",    "coalesce(b.aciklama, '')", "metin", "Açıklama", Genislik: 240),
        new("durumAdi",    "case b.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end",
                                              "metin", "Durum", Hizalama: "orta"),
        new("durum",       "b.durum",        "sayi",  "Durum Kodu", Hizalama: "orta", Varsayilan: false),
        new("subeId",      "b.sube_id",      "sayi",  "Şube", Varsayilan: false),
    };

    // --------------------------------------------------------------- banka ----

    // --------------------------------------------------- stok transferi ----
    // Ayni `belge` tablosu, tur 20. Ayri kaynak: transferde CARI ve TUTAR yoktur,
    //   bunun yerine IKI DEPO ve miktar konusur - genel belge listesinin cari/tutar
    //   kolonlari burada hep bos kalirdi.
    private static KaynakTanimi StokTransfer() => new(
        Ad: "stok-transfer",
        YetkiKodu: "belge",
        Kaynak: """
            public.belge b
            left join public.depo cd on cd.id = b.cikis_depo_id
            left join public.depo gd on gd.id = b.giris_depo_id
            join public.v_belge_sevkiyat sv on sv.belge_id = b.id
            left join public.taraf te on te.id = sv.teslim_eden_id
            left join public.taraf ta on ta.id = sv.teslim_alan_id
            """,
        SabitKosul: "b.tur = 20",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "b.id",           "sayi",  "Id",    Varsayilan: false),
            new("belgeNo",     "b.belge_no",     "metin", "Transfer No"),
            new("belgeTarihi", "b.belge_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("cikisDepo",   "coalesce(cd.ad, '')", "metin", "Çıkış Deposu", Genislik: 180),
            new("girisDepo",   "coalesce(gd.ad, '')", "metin", "Giriş Deposu", Genislik: 180),
            // Sorumluluk devri: eski transferlerde bos olabilir (alan 100'de eklendi).
            new("teslimEden",  "coalesce(te.unvan, '')", "metin", "Teslim Eden", Genislik: 180),
            new("teslimAlan",  "coalesce(ta.unvan, '')", "metin", "Teslim Alan", Genislik: 180),
        }.Concat(StokBelgesiKuyrukKolonlari()).ToArray());

    // ------------------------------------------------------ stoktan talep ----
    // Belge turu 105: bir birim/kisi depodan mal ISTER. Stok ve cari ETKILEMEZ
    //   (kasa_islem_turu 105: stok_etkiler=0, cari_etkiler=0) - talep karsilaninca
    //   asil hareketi stok transferi (20) yapar.

    // ------------------------------------------------------ stoktan talep ----
    // Belge turu 105: bir birim/kisi depodan mal ISTER. Stok ve cari ETKILEMEZ
    //   (kasa_islem_turu 105: stok_etkiler=0, cari_etkiler=0) - talep karsilaninca
    //   asil hareketi stok transferi (20) yapar.
    private static KaynakTanimi StokTalep() => new(
        Ad: "stok-talep",
        YetkiKodu: "belge",
        Kaynak: """
            public.belge b
            left join public.depo cd on cd.id = b.cikis_depo_id
            left join public.depo gd on gd.id = b.giris_depo_id
            left join public.v_belge_sevkiyat sv on sv.belge_id = b.id
            left join public.taraf ta on ta.id = sv.teslim_alan_id
            """,
        SabitKosul: "b.tur = 105",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "b.id",           "sayi",  "Id",    Varsayilan: false),
            new("belgeNo",     "b.belge_no",     "metin", "Talep No"),
            new("belgeTarihi", "b.belge_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("cikisDepo",   "coalesce(cd.ad, '')", "metin", "İstenen Depo", Genislik: 180),
            new("girisDepo",   "coalesce(gd.ad, '')", "metin", "Teslim Deposu", Genislik: 180),
            new("talepEden",   "coalesce(ta.unvan, '')", "metin", "Talep Eden", Genislik: 200),
            // Talep KARSILANDI mi: F8 sayaci (0 acik / 1 kismi / 2 kapandi).
            new("karsilanma",
                "case b.kapanma_durum when 2 then 'Karşılandı' when 1 then 'Kısmi' else 'Bekliyor' end",
                                                  "metin", "Karşılanma", Hizalama: "orta"),
            new("kapanmaDurum","b.kapanma_durum","sayi",  "Karşılanma Kodu", Hizalama: "orta", Varsayilan: false),
        }.Concat(StokBelgesiKuyrukKolonlari()).ToArray());

    // -------------------------------------------------------- stok fisleri ----
    // 3 Giris Fisi / 4 Cikis Fisi (101). Irsaliye gibi ama CARI YOK; TIPI fisin
    //   sebebini tasir ve listede METNE cevrilir (liste katmani kod cozmez).

    // -------------------------------------------------------- stok fisleri ----
    // 3 Giris Fisi / 4 Cikis Fisi (101). Irsaliye gibi ama CARI YOK; TIPI fisin
    //   sebebini tasir ve listede METNE cevrilir (liste katmani kod cozmez).
    private static KaynakTanimi StokFisi(int tur)
    {
        var giris = tur == 3;
        // Tip adlari 101'deki kod_deger ile ayni; liste katmani kod_liste'ye
        //   join atmaz (tek satirlik CASE hem daha hizli hem tek sorgu).
        var tipIfade = giris
            ? "case b.tipi when 1 then 'Fire' when 2 then 'Sayım Fazlası' else 'Diğer' end"
            : "case b.tipi when 1 then 'Sarf' when 2 then 'İmha (Bozuk / SKT Geçmiş)' " +
              "when 3 then 'Kayıp' when 4 then 'Fire' when 5 then 'Sayım Eksiği' else 'Diğer' end";

        return new KaynakTanimi(
            Ad: giris ? "giris-fis" : "cikis-fis",
            YetkiKodu: "belge",
            Kaynak: """
                public.belge b
                left join public.depo d on d.id = coalesce(b.giris_depo_id, b.cikis_depo_id)
                left join public.taraf sc on sc.id = b.satici_id and b.satici_id > 0
                """,
            SabitKosul: $"b.tur = {tur}",
            SubeKolonu: "b.sube_id",
            VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
            Kolonlar: new KolonTanimi[]
            {
                new("id",          "b.id",           "sayi",  "Id", Varsayilan: false),
                new("belgeNo",     "b.belge_no",     "metin", "Fiş No"),
                new("belgeTarihi", "b.belge_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
                new("tipAdi",      tipIfade,         "metin", "Tipi", Hizalama: "orta", Genislik: 170),
                // Ham kod cip filtreleri icin gizli durur.
                new("tipi",        "b.tipi",         "sayi",  "Tip Kodu", Hizalama: "orta", Varsayilan: false),
                new("depo",        "coalesce(d.ad, '')", "metin", giris ? "Giriş Deposu" : "Çıkış Deposu",
                                                      Genislik: 180),
                new("sorumlu",     "coalesce(sc.unvan, '')", "metin", "Sorumlu", Genislik: 180),
                // Tutar muhasebe fisinin (F7) matrahi - fiste KDV yok.
                new("genelToplam", "b.genel_toplam", "para",  "Tutar", Hizalama: "sag", Bicim: "#,##0.00"),
            }.Concat(StokBelgesiKuyrukKolonlari()).ToArray());
    }

    // --------------------------------------------------------------- gorev ----
    // Gorev / hatirlatma / takvim (108). Liste katmani kod cozmez: tur, durum ve
    //   oncelik SQL'de metne cevrilir, ham kodlar cip filtreleri icin gizli kalir.

    /// <summary>
    /// Hizmetin verilen TARIFE GRUBUNDAKI liste fiyati (5 Özel · 6 TTB/HUV ·
    /// 7 SUT). Fiyat listesi yazili satirdan okunur; ayni grupta birden çok
    /// liste varsa en eski (kurulusun ana tarifesi) kazanir.
    /// </summary>
    private static string TarifeFiyati(int grup) =>
        "(select round(f.fiyat, 2) from public.fiyat_listesi_satir f" +
        "   join public.fiyat_listesi l on l.id = f.liste_id" +
        "  where f.hizmet_id = h.id and f.durum = 1 and l.grup = " + grup +
        "  order by l.id limit 1)";

    // ------------------------------------------------------------- hizmet ----
    private static KaynakTanimi Hizmet() => new(
        Ad: "hizmet",
        YetkiKodu: "hizmet",
        Kaynak: "public.hizmet h",
        VarsayilanSirala: "h.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "h.id",       "sayi",  "Id",         Varsayilan: false),
            new("kod",     "h.kod",      "metin", "Kod"),
            new("ad",      "h.ad",       "metin", "Hizmet Adi"),
            // Eski `grubu` kolonu hic kullanilmamis (hepsi 0) - yerine 269'da
            //   eklenen kategori gosteriliyor.
            // KATEGORI YOLU (350/351, kullanici: "hizmet listesine de yansit"):
            //   yalniz yaprak adi ("BT", "LAB") hangi dalda oldugunu
            //   soylemiyordu - ust dal varsa "Radyoloji > BT" olarak gosterilir.
            new("kategoriAdi",
                "coalesce((select case when u.id is null then k.ad " +
                "                      else u.ad || ' > ' || k.ad end " +
                "            from public.kategori k " +
                "            left join public.kategori u on u.id = k.ust_id " +
                "           where k.id = h.kategori), '')",
                               "metin", "Kategori", Filtrelenebilir: false),
            new("kategori", "h.kategori", "sayi", "Kategori Id", Varsayilan: false),
            // MODALITE: hizmet bir RADYOLOJI tetkiki mi (BT/MR/USG...) - 459
            //   kurali modalitesiz hizmetle radyoloji istemi acilmasini
            //   engelliyor; istem ekranlari listeyi bununla suzer.
            new("modalite", "coalesce(h.modalite, 0)", "kod", "Modalite",
                                            Hizalama: "orta", Genislik: 110,
                                            Varsayilan: false),
            // KDV ve BIRIM listede GORUNMEZ (kullanici): hizmet listesinde
            //   kategori/kod/ad okunuyor, oran ve birim kartin ve kalem
            //   penceresinin isi. Kolonlar kaldirilmadi - arama/kalem
            //   pencereleri bu alanlari okumaya devam ediyor.
            new("kdv",     "h.kdv",      "sayi",  "KDV %",      Hizalama: "sag",
                                            Varsayilan: false),
            // Hizmette satis/alis ayrimi yok - tek fiyat listesi.
            // FIYAT ve DOVIZ hizmet listesinde GORUNMEZ (kullanici): fiyat artik
            //   fiyat listelerinden geliyor, listedeki "ilk fiyat" hangi listeden
            //   geldigi belirsiz bir sayiydi. Kolonlar KALDIRILMADI, yalniz
            //   varsayilan gorunumden cikarildi: kalem/arama penceresi (kur
            //   cevrimi dahil) bu alanlari okumaya devam ediyor.
            new("fiyat",
                "(select f.fiyat from public.hizmet_fiyat f " +
                " where f.hizmet_id = h.id and f.fiyat > 0 order by f.fiyat_adi limit 1)",
                                            "para",  "Fiyat",      Hizalama: "sag", Bicim: "#,##0.00",
                                            Siralanabilir: false, Filtrelenebilir: false,
                                            Varsayilan: false),
            // ISO'ya cevrilir: fiyat tablolarinda kod SEMBOL olabiliyor ('$', '€'),
            //   doviz_kur ise ISO tutuyor - kalem penceresi kuru bu kodla ariyor.
            new("fiyatDovizi",
                "public.fn_doviz_iso((select f.doviz_cinsi from public.hizmet_fiyat f " +
                " where f.hizmet_id = h.id and f.fiyat > 0 order by f.fiyat_adi limit 1))",
                                            "metin", "Döviz",      Hizalama: "orta",
                                            Siralanabilir: false, Filtrelenebilir: false,
                                            Varsayilan: false),
            // BIRIM ADIYLA (kullanici: "birimi de kod disinda anlasilir yap"):
            //   kolon "kod" tipindeyken listede 51 / 57 gibi ham sayi cikiyordu.
            //   Stok listesindeki desenin aynisi (anaBirim).
            new("birim",
                "(select kd.ad from public.kod_deger kd" +
                "   join public.kod_liste kl on kl.id = kd.liste_id" +
                "  where kl.kod = 'hizmet.birim' and kd.deger = h.birim)",
                                            "metin", "Birim",      Hizalama: "orta",
                                            Filtrelenebilir: false, Varsayilan: false),
            // Birim KODU gizli: kalem/arama penceresi satirdan birimi
            //   yazabilsin - ad ile kod eslestirmek kirilgan olurdu.
            new("birimKod", "h.birim",   "sayi",  "Birim Kodu", Hizalama: "orta",
                                            Varsayilan: false),
            // SUT KODU KOLONU YOK (521): katalog SKRS'den kuruldugundan
            //   hizmetin KODU zaten SUT kodudur; listede ayri bir sutun ayni
            //   sayiyi iki kere gosterirdi. HUV kodu ayri kalir - TTB
            //   tarifesinin kodu SUT kodundan farklidir ve ozel sigorta
            //   faturasi ona bakar.
            new("huvKodu", "h.huv_kodu", "metin", "HUV Kodu",   Genislik: 110),
            new("loinc",   "h.loinc",    "metin", "LOINC",      Genislik: 110),
            // UC TARIFE FIYATI (499, kullanici: "ozel(ucretli) fiyati, TTB
            //   (HUV fiyati), SUT Fiyati icin hizmet listesi"). Tetkik
            //   katalogda BIR kez durur (497); hangi kurum tipinin hangi
            //   fiyati odedigi sozlesmesindeki listeden cikar. Kolonlar
            //   listenin GRUBUNA bakar (5 Ozel · 6 TTB/HUV · 7 SUT) - liste
            //   id'leri kurulumdan kuruluma degisir.
            new("ozelFiyat", TarifeFiyati(5), "para", "Özel (Ücretli)",
                Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false,
                Filtrelenebilir: false, Genislik: 130),
            new("huvFiyat",  TarifeFiyati(6), "para", "TTB / HUV",
                Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false,
                Filtrelenebilir: false, Genislik: 120),
            new("sutFiyat",  TarifeFiyati(7), "para", "SUT",
                Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false,
                Filtrelenebilir: false, Genislik: 110),
            // PANEL MI: icerigi olan hizmet (496). Panelin kendi satiri da
            //   satilabilir bir kalemdir - katalogda tetkikten ayirt etmenin
            //   tek yolu icerik sayisi.
            // PANEL / PAKET bayragi (502): icerigi henuz girilmemis panel de
            //   burada gorunur - yalniz icerik sayisina bakmak onu siradan
            //   tetkikten ayirt edemiyordu.
            new("paket", "h.paket", "mantik", "Paket/Panel", Hizalama: "orta",
                Genislik: 90, Varsayilan: false),
            new("radyoloji", "h.radyoloji", "mantik", "Radyoloji", Hizalama: "orta",
                Genislik: 90, Varsayilan: false),
            // 0 yerine BOS: katalogun %95'i tekil tetkik; her satirda "0"
            //   gormek gurultu, dolu hucre ise "bu satir bir paket" demek.
            new("icerikSayisi",
                "nullif((select count(*)::int from public.hizmet_paket p" +
                "         where p.paket_hizmet_id = h.id), 0)",
                "sayi", "İçerik", Hizalama: "orta", Siralanabilir: false,
                Filtrelenebilir: false, Genislik: 90),
            new("muhKodu", "h.muh_kodu", "metin", "Muh. Kodu",  Varsayilan: false),
            new("durum",   "h.durum",    "kod",   "Durum",      Hizalama: "orta")
        });

    // ------------------------------------------------------------- masraf ----

    // ------------------------------------------------------------- masraf ----
    private static KaynakTanimi Masraf() => new(
        Ad: "masraf",
        YetkiKodu: "masraf",
        Kaynak: "public.masraf m",
        VarsayilanSirala: "m.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "m.id",       "sayi",  "Id",         Varsayilan: false),
            new("kod",     "m.kod",      "metin", "Kod"),
            new("ad",      "m.ad",       "metin", "Masraf Adi"),
            new("grubu",   "m.grubu",    "kod",   "Grup"),
            new("kdv",     "m.kdv",      "sayi",  "KDV %",      Hizalama: "sag"),
            new("birim",   "m.birim",    "kod",   "Birim",      Hizalama: "orta"),
            new("muhKodu", "m.muh_kodu", "metin", "Muh. Kodu",  Varsayilan: false),
            new("durum",   "m.durum",    "kod",   "Durum",      Hizalama: "orta")
        });

    // ------------------------------------------------------- mali hareket ----
    // BACAK listesi (kasa_islem basliginin altindaki tekil satirlar). 080 gocuyle
    //   "kur" ve "doviz_tutari" kolonlari DUSTU; yerine bacagin kendi dovizi
    //   (doviz_cinsi + borc/alacak) ve TL karsiligi (yerel_borc/yerel_alacak) geldi.
}

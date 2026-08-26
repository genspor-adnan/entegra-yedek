namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Fatura / irsaliye / e-Belge listeleri ve belge donusumu.
///
/// KaynakKatalogu tek dosyada 1389 satira ulasmisti; tanimlar konu basina
/// partial dosyalara ayrildi. Sozluk, Bul/Tumu ve kayit sirasi ana dosyada.
/// </summary>
public static partial class KaynakKatalogu
{
    // -------------------------------------------------------------- belge ----
    private static KaynakTanimi Belge() => new(
        Ad: "belge",
        YetkiKodu: "belge",
        Kaynak: "public.belge b " +
                "left join public.kasa_islem_turu bt on bt.kod = b.tur " +
                // F8 donusum zinciri: kaynak baslik bagindan okunur.
                "left join public.belge kb on kb.id = b.kaynak_id and b.kaynak_tur = 30 " +
                "left join public.kasa_islem_turu kt2 on kt2.kod = kb.tur",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        KapsamKolonu: "b.taraf_id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id",          Varsayilan: false),
            new("tur",           "b.tur",            "kod",   "Tur",         Hizalama: "orta", Genislik: 70),
            new("turAdi",        "bt.ad",            "metin", "Belge Türü",  Genislik: 130),
            // F8: siparis/irsaliye ne kadari donusturuldu (0 acik / 1 kismi / 2 kapandi)
            new("kapanmaDurum",  "b.kapanma_durum",  "kod",   "Kapanma",     Hizalama: "orta", Varsayilan: false),
            new("tipi",          "b.tipi",           "kod",   "Tipi",        Hizalama: "orta", Varsayilan: false),
            new("belgeSeri",     "b.belge_seri",     "metin", "Seri",        Genislik: 70, Varsayilan: false),
            new("belgeNo",       "b.belge_no",       "metin", "Belge No",    Genislik: 155),
            // e-BELGE DURUMU ROZET: ham kod (0/1/11/51...) listede hicbir sey
            //   anlatmiyordu. Metin hem TURU hem ASAMAYI soyler; gonderilmis
            //   belge "✓" ile ve yesil rozetle ayrilir (163/164 kodlari).
            new("efaturaDurum",
                """
                case coalesce(b.efatura_durum, 0)
                     when 0  then ''
                     when 1  then 'e-Fatura'    when 2  then 'e-Fatura ✓'
                     when 11 then 'e-Arşiv'     when 12 then 'e-Arşiv ✓'
                     when 51 then 'e-İrsaliye'  when 52 then 'e-İrsaliye ✓'
                     else 'Bilinmiyor' end
                """,                             "metin", "e-Fatura", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 110,
                                                 Siralanabilir: false, Filtrelenebilir: false),
            new("belgeTarihi",   "b.belge_tarihi",   "tarih", "Tarih",       Hizalama: "orta",
                                                                Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("tarafId",       "b.taraf_id",       "sayi",  "Cari Id",     Varsayilan: false),
            new("tarafUnvan",    "b.taraf_unvan",    "metin", "Cari",        Genislik: 260),
            // KAYNAK / HEDEF: donusum zincirinin iki ucu (irsaliye listesindeki
            //   ile ayni). Kaynak baslik bagindan; hedef SATIR bagindan turer -
            //   bir belge birden fazla belgeye bolunebilir, numaralar birlestirilir.
            //   Iptal (durum=2) hedefler sayilmaz.
            new("kaynak",
                "case when kb.id is null then '' " +
                "else coalesce(kt2.ad, '') || case when kb.belge_no <> '' " +
                "then ' ' || kb.belge_no else '' end end",
                                                      "metin", "Kaynak",      Genislik: 170,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("hedef",
                "coalesce((select string_agg(distinct coalesce(ht.ad, '') || ' ' || hb.belge_no, ', ') " +
                "            from public.belge_satir hs " +
                "            join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30 " +
                "            join public.belge hb on hb.id = hs.belge_id " +
                "            left join public.kasa_islem_turu ht on ht.kod = hb.tur " +
                "           where ks.belge_id = b.id and hb.durum <> 2), '')",
                                                      "metin", "Hedef",       Genislik: 190,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("tarafVkno",     "b.taraf_vkno",     "metin", "VKN/TCKN",    Genislik: 120, Varsayilan: false),
            new("matrah",        "b.matrah",         "para",  "Matrah",      Hizalama: "sag",
                                                                Bicim: "#,##0.00", Genislik: 120),
            new("kdvTutari",     "b.kdv_tutari",     "para",  "KDV",         Hizalama: "sag",
                                                                Bicim: "#,##0.00", Genislik: 110),
            new("genelToplam",   "b.genel_toplam",   "para",  "Genel Toplam",Hizalama: "sag",
                                                                Bicim: "#,##0.00", Genislik: 130),
            new("acikKapali",    "b.acik_kapali",    "kod",   "Acik/Kapali", Hizalama: "orta", Varsayilan: false),
            new("durum",         "b.durum",          "kod",   "Durum",       Hizalama: "orta", Genislik: 90),
            new("vadeGun",       "b.vade_gun",       "sayi",  "Vade",        Hizalama: "sag", Genislik: 80,
                                                                Varsayilan: false),
            new("aciklama",      "b.aciklama",       "metin", "Açıklama",    Genislik: 240, Varsayilan: false),
            // Alan yetkisine ornek: rol_alan_yetki'de 'belge.maliyetOrt' izin 0 ise
            //   bu kolon yanittan CIKARILIR ve /kolonlar listesinde de gorunmez.
            new("maliyetOrt",    "b.maliyet_ort",    "para",  "Ort. Maliyet",Hizalama: "sag",
                                                                            Bicim: "#,##0.0000", Varsayilan: false),
            new("subeId",        "b.sube_id",        "sayi",  "Sube",        Varsayilan: false)
        });

    // ----------------------------------------------------------- personel ----

    // ---------------------------------------------------------- irsaliye ----
    // Ekranlar/satis_irsaliye_listesi.html kolonlariyla BIREBIR. Ayni `belge`
    //   tablosu ama AYRI kaynak: irsaliye listesi sevkiyat odakli (arac/sofor,
    //   cikis deposu, kaynak siparis, faturalama durumu) - bu kolonlari genel
    //   belge listesine eklemek onu 20 kolonluk bir seye cevirirdi.
    private static KaynakTanimi Irsaliye() => new(
        Ad: "irsaliye",
        YetkiKodu: "belge",
        Kaynak: """
            public.belge b
            left join public.depo  cd on cd.id = b.cikis_depo_id
            join public.v_belge_sevkiyat sv on sv.belge_id = b.id
            left join public.taraf te on te.id = sv.teslim_eden_id
            left join public.taraf sc on sc.id = b.satici_id
            left join public.belge kb on kb.id = b.kaynak_id and b.kaynak_tur = 30
            left join public.kasa_islem_turu kt2 on kt2.kod = kb.tur
            """,
        SabitKosul: "b.tur in (10, 14, 109, 119)",
        SubeKolonu: "b.sube_id",
        KapsamKolonu: "b.taraf_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id",        Varsayilan: false),
            // Liste katmaninda kod_liste cozumu YOK (yalniz kartta var); bu yuzden
            //   kullaniciya gorunen kolonlar SQL'de metne cevrilir, ham kodlar gizli
            //   kalir (cip filtreleri onlari kullanir).
            //
            // TIP kolonu YOK: mockup SVK/NUM/IPT gosteriyor ama gocten gelen
            //   `belge.tipi` 10 farkli deger tasiyor (415 kaydin hepsi "1") ve anlami
            //   belgesiz. Ekran zaten YALNIZ satis irsaliyelerini gosterdigi icin her
            //   satirda ayni kisaltmayi tekrarlamanin bilgi degeri de yoktu.
            new("tipi",          "b.tipi",           "sayi",  "Tip Kodu",  Hizalama: "orta", Varsayilan: false),
            new("belgeNo",       "b.belge_no",       "metin", "İrsaliye No", Genislik: 155),
            // e-IRSALIYE DURUMU (kullanici: "irsaliye no saginda gidip gitmedigini
            //   anlayayim"). Kodlar e-Belge turune gore ayri: e-Irsaliye 51
            //   hazirlandi / 52 gonderildi. Eskiden burada FATURA kodlari (1/2/3/4)
            //   yaziyordu - hazirlanmis irsaliye "Kağıt" gorunuyordu.
            new("eIrsaliye",
                """
                case coalesce(b.efatura_durum, 0)
                     when 0  then 'Kağıt'
                     when 51 then 'e-İrsaliye'
                     when 52 then 'e-İrsaliye ✓'
                     when 53 then 'Kabul'
                     when 54 then 'Red'
                     else 'Bilinmiyor' end
                """,                                 "metin", "e-İrsaliye", Hizalama: "orta",
                                                      Bicim: "rozet", Genislik: 120,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("belgeTarihi",   "b.belge_tarihi",   "tarih", "Tarih",     Hizalama: "orta",
                                                      Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("tarafUnvan",    "b.taraf_unvan",    "metin", "Müşteri",   Genislik: 220),
            new("cikisDepo",     "cd.ad",            "metin", "Çıkış Deposu"),
            // KAYNAK / HEDEF: F8 donusum zincirinin iki ucu. Kaynak baslik bagindan
            //   (belge.kaynak_id) okunur; hedef ise SATIR bagindan turetilir -
            //   bir irsaliye birden fazla faturaya bolunebilir, o yuzden distinct
            //   belge numaralari birlestirilir. Iptal (durum=2) hedefler sayilmaz.
            new("kaynak",
                "case when kb.id is null then '' " +
                "else coalesce(kt2.ad, '') || case when kb.belge_no <> '' " +
                "then ' ' || kb.belge_no else '' end end",
                                                      "metin", "Kaynak",    Genislik: 170,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("hedef",
                "coalesce((select string_agg(distinct coalesce(ht.ad, '') || ' ' || hb.belge_no, ', ') " +
                "            from public.belge_satir hs " +
                "            join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30 " +
                "            join public.belge hb on hb.id = hs.belge_id " +
                "            left join public.kasa_islem_turu ht on ht.kod = hb.tur " +
                "           where ks.belge_id = b.id and hb.durum <> 2), '')",
                                                      "metin", "Hedef",     Genislik: 190,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("kaynakBelgeNo", "kb.belge_no",      "metin", "Kaynak Belge No", Varsayilan: false),
            // Plaka ve sofor tek kolonda: mockup "07 ABC 145 / Hasan Celik" gosteriyor.
            new("aracSofor",
                "case when btrim(sv.arac_plaka || sv.sofor_ad) = '' then '' " +
                "else btrim(sv.arac_plaka) || " +
                "case when sv.sofor_ad <> '' then ' / ' || sv.sofor_ad else '' end end",
                                                      "metin", "Araç / Şoför", Genislik: 170,
                                                      Varsayilan: false),
            // Teslim eden bos ise satis temsilcisi gosterilir (mockup'taki davranis).
            new("teslimEden",    "coalesce(te.unvan, sc.unvan)", "metin", "Teslim Eden",
                                                      Varsayilan: false),
            // Faturalama durumu GIZLI: Hedef kolonu zaten hangi faturaya donustugunu
            //   (ya da donusmedigini) gosteriyor; ikisi ayni bilgiyi tekrarliyordu.
            //   Cip filtreleri kapanmaDurum uzerinden calismaya devam eder.
            new("faturalama",
                "case b.kapanma_durum when 2 then 'Faturalandı' when 1 then 'Kısmi' else 'Faturalanmadı' end",
                                                      "metin", "Faturalama", Hizalama: "orta",
                                                      Varsayilan: false),
            new("kapanmaDurum",  "b.kapanma_durum",  "sayi",  "Faturalama Kodu", Hizalama: "orta", Varsayilan: false),
            new("efaturaDurum",  "b.efatura_durum",  "sayi",  "e-Belge Kodu", Hizalama: "orta", Varsayilan: false),
            // Miktar GIZLI: satir-basi alt sorgu (her satirda bir belge_satir taramasi)
            //   ve irsaliyede farkli birimler (adet/kg/metre) toplanip tek sayi olarak
            //   gosterildiginde yaniltici. Kolon seciciden acilabilir.
            new("miktar",
                "(select coalesce(sum(s.miktar), 0) from public.belge_satir s where s.belge_id = b.id)",
                                                      "para",  "Miktar",    Hizalama: "sag", Bicim: "#,##0.##",
                                                      Siralanabilir: false, Filtrelenebilir: false,
                                                      Varsayilan: false),
            new("genelToplam",   "b.genel_toplam",   "para",  "Tutar",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("teslimSekli",
                "case sv.teslim_sekli when 1 then 'Alıcı adresine teslim' when 2 then 'Alıcı kendi aracıyla' " +
                "when 3 then 'Kargo / nakliye' when 4 then 'Depoda teslim' when 5 then 'Yurt dışı sevk' " +
                "else 'Belirtilmemiş' end",
                                                      "metin", "Teslim Şekli", Hizalama: "orta", Varsayilan: false),
            new("irsaliyeTarihi","b.irsaliye_tarihi","tarih", "Sevk Zamanı", Hizalama: "orta",
                                                      Bicim: "dd.MM.yyyy HH:mm", Varsayilan: false),
            new("aracPlaka",     "sv.arac_plaka",    "metin", "Plaka",     Varsayilan: false),
            new("soforAd",       "sv.sofor_ad",      "metin", "Şoför",     Varsayilan: false),
            new("tur",           "b.tur",            "sayi",  "Tür Kodu",  Hizalama: "orta", Varsayilan: false),
            new("durumAdi",      "case b.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end",
                                                      "metin", "Durum",     Hizalama: "orta"),
            new("durum",         "b.durum",          "sayi",  "Durum Kodu", Hizalama: "orta", Varsayilan: false),
            new("subeId",        "b.sube_id",        "sayi",  "Şube",      Varsayilan: false)
        });

    // -------------------------------------------------------------- depo ----
    // Belge kartinda cikis/giris deposu ADIYLA secilir (GenLookup kaynagi).

    // ------------------------------------------------------------ e-belge ----
    private static KaynakTanimi EBelge() => new(
        Ad: "e-belge",
        YetkiKodu: "e_belge",
        Kaynak: "public.e_belge e left join public.taraf t on t.id = e.taraf_id",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.ekleme_tarihi desc, e.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",             "e.id",               "sayi",  "Id",        Varsayilan: false),
            new("eklemeTarihi",   "e.ekleme_tarihi",    "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("belgeTuru",      "e.belge_turu",       "kod",   "Belge Turu", Hizalama: "orta"),
            new("yon",            "e.yon",              "kod",   "Yon",       Hizalama: "orta"),
            new("belgeNo",        "e.belge_no",         "metin", "Belge No"),
            new("tarafUnvan",     "t.unvan",            "metin", "Cari"),
            new("gondericiVkno",  "e.gonderici_vkno",   "metin", "Gonderici VKN", Varsayilan: false),
            new("durum",          "e.durum",            "kod",   "Durum",     Hizalama: "orta"),
            new("gibDurumKodu",   "e.gib_durum_kodu",   "metin", "GIB Kodu",  Varsayilan: false),
            new("servisDurumAdi", "e.servis_durum_adi", "metin", "Servis Durumu"),
            new("uuid",           "e.uuid",             "metin", "UUID",      Varsayilan: false)
        });

    // ---------------------------------------------------------- islem log ----
    // UInfo karsiligi. islem_log tarihe gore BOLUMLENMIS: varsayilan siralama
    //   tarih desc oldugu icin son kayitlar ilk bolumden gelir.
    //
    // islem_tipi ve tablo_id ham sayisal kodlar (Gentegre.Veri.Depolar.LogIslemi /
    //   KartTanimi.LogTabloId) - burada okunabilir metne cevriliyor ki UInfo gibi
    //   kullanici "2/71" degil "Degisiklik/Cari" gorsun.
    //
    // Kod/Ad (eski LOGCOZUM karsiligi): tablo_id'ye gore DOGRU tabloya (taraf/stok/
    //   belge/rol) LEFT JOIN ile kayit_id cozulur. Yalniz kart-seviyeli tablolar
    //   (71/73 taraf, 88 stok, 30 belge, 903 rol) cozulur - detay satirlari (adres,
    //   barkod, fiyat, izin, egitim... 340-907 arasi) icin Kod/Ad bos kalir; kayit
    //   silinmisse de (join eslesmez) bos kalir - "bilgi" JSON'daki anlik degerler
    //   burada kullanilmaz, cunku alan adlari tabloya gore degisir (tek SQL'de
    //   duzgun genellenemez).

    // ------------------------------------------------- acik belge satirlari ----
    // "Hangi siparislerin nesi teslim edilmedi" raporu. Donusum ekrani ayri bir
    //   uctan (GET /api/belge/{id}/acik-satirlar) okur; bu liste genel gorunum.
    private static KaynakTanimi BelgeAcikSatir() => new(
        Ad: "belge-acik-satir",
        YetkiKodu: "belge",
        Kaynak: "public.v_belge_acik_satir a",
        SubeKolonu: "a.sube_id",
        KapsamKolonu: "a.taraf_id",
        VarsayilanSirala: "a.belge_tarihi asc, a.belge_id asc, a.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("satirId",         "a.satir_id",         "sayi",  "Satır Id", Varsayilan: false),
            new("belgeId",         "a.belge_id",         "sayi",  "Belge Id", Varsayilan: false),
            new("belgeTurAdi",     "a.belge_tur_adi",    "metin", "Belge Türü"),
            new("belgeTur",        "a.belge_tur",        "sayi",  "Tür Kodu", Hizalama: "orta", Varsayilan: false),
            new("belgeNo",         "a.belge_no",         "metin", "Belge No"),
            new("belgeTarihi",     "a.belge_tarihi",     "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("tarafUnvan",      "a.taraf_unvan",      "metin", "Cari",     Genislik: 220),
            new("stokKodu",        "a.stok_kodu",        "metin", "Stok Kodu"),
            new("stokAdi",         "a.stok_adi",         "metin", "Stok",     Genislik: 240),
            new("aciklama",        "a.aciklama",         "metin", "Açıklama", Varsayilan: false),
            new("miktar",          "a.miktar",           "para",  "Miktar",   Hizalama: "sag", Bicim: "#,##0.##"),
            new("kapatilanMiktar", "a.kapatilan_miktar", "para",  "Dönüşen",  Hizalama: "sag", Bicim: "#,##0.##"),
            new("kalanMiktar",     "a.kalan_miktar",     "para",  "Kalan",    Hizalama: "sag", Bicim: "#,##0.##"),
            new("birimFiyat",      "a.birim_fiyat",      "para",  "Birim Fiyat", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("belgeDovizi",     "a.belge_dovizi",     "metin", "Döviz",    Hizalama: "orta", Varsayilan: false),
            new("kapanmaDurum",    "a.kapanma_durum",    "kod",   "Kapanma",  Hizalama: "orta", Varsayilan: false),
            new("subeId",          "a.sube_id",          "sayi",  "Şube",     Varsayilan: false)
        });
}

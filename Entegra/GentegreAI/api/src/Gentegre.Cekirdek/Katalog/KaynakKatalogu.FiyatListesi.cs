namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FIYAT LISTESI listeleri (201/202): listelerin kendisi ve satirlari.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Fiyat listeleri - kural ve gecerlilik ozeti.</summary>
    private static KaynakTanimi FiyatListesi() => new(
        Ad: "fiyat-listesi",
        YetkiKodu: "fiyat_listesi",
        Kaynak: """
            public.fiyat_listesi l
            left join public.fiyat_listesi t on t.id = l.taban_liste_id
            """,
        SubeKolonu: "l.sube_id",
        // GRUP KOLONU DUSTU (532): tarife tipi (518) ayni soruyu
        //   soruyordu. Siralama tarife tipine gore - Ozel, TTB, SUT.
        VarsayilanSirala: "l.tarife_tipi, l.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",   "l.id",   "sayi",  "Id", Varsayilan: false),
            new("ad",   "l.ad",   "metin", "Liste Adı", Genislik: 220),
            // Yon: belge karti listeyi buna gore suzer (alis belgesinde satis
            //   listesi cikmamali). Gridde de gorunur - hangi liste ne icin.
            new("yon", "case when l.yon = 1 then 'Alış' else 'Satış' end", "metin",
                "Yön", Hizalama: "orta"),
            new("yonKodu", "l.yon", "sayi", "Yön Kodu", Varsayilan: false),
            new("varsayilan", "case when l.varsayilan = 1 then '✓' else '' end", "metin",
                "Varsayılan", Hizalama: "orta"),
            // TABAN LISTE / CARPAN / YUVARLAMA KOLONLARI KALKTI (532):
            //   turetme kurali artik satir duzeyinde (518 tarife tipi) - liste
            //   basliginda ayni kurali ikinci kez gostermek gurultuydu.
            // KDV iki degerli: kod listesi acmak yerine dogrudan metne cevrilir.
            new("kdvDahil", "case when l.kdv_dahil = 1 then 'Dahil' else 'Hariç' end", "metin",
                "KDV", Hizalama: "orta"),
            // TARIFE TIPI (518): listenin hangi kuralla calistigi - satir
            //   sutunlari ve toplu islemler buna gore degisiyor, listede de
            //   gorunsun.
            new("tarifeTipiAdi",
                "case l.tarife_tipi when 1 then 'Özel (Ücretli)' when 2 then 'TTB / HUV' " +
                "when 3 then 'SUT (SGK)' else '' end",
                "metin", "Tarife", Hizalama: "orta", Genislik: 120),
            new("tarifeTipi", "l.tarife_tipi", "kod", "Tarife Kodu", Varsayilan: false),
            new("baslangic", "l.baslangic", "tarih", "Başlama", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("bitis",     "l.bitis",     "tarih", "Bitiş",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            // Satir sayisi: listenin URETILIP uretilmedigini tek bakista gosterir.
            new("satirSayisi",
                "(select count(*) from public.fiyat_listesi_satir r where r.liste_id = l.id)",
                "sayi", "Satır", Hizalama: "sag", Filtrelenebilir: false),
            // Durum IKI kolon (hesap kaynagindaki desen): gorunen METIN
            //   (GenGrid yesil/kirmizi rozet basar) + FILTRELENEBILIR ham kod.
            //   Tek metin kolonu birakilinca "Aktif" cipi (durum = 1) hicbir
            //   satirla eslesmiyor, liste bos gorunuyordu.
            new("durumAdi", "case l.durum when 1 then 'Aktif' else 'Pasif' end", "metin",
                "Durum", Hizalama: "orta", Genislik: 90, Filtrelenebilir: false),
            new("durum", "l.durum", "kod", "Durum Kodu", Hizalama: "orta", Varsayilan: false),
            new("aciklama", "l.aciklama", "metin", "Açıklama", Genislik: 240, Varsayilan: false),
            new("subeId", "l.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    /// <summary>
    /// Liste satirlari. Kaynak GORUNUM: kod/ad/kategori kalemin kartindan gelir,
    /// satir tablosunda tutulmaz (kart duzeltilince liste yalan soylemesin).
    /// </summary>
    private static KaynakTanimi FiyatListesiSatir() => new(
        Ad: "fiyat-listesi-satir",
        YetkiKodu: "fiyat_listesi",
        Kaynak: "public.v_fiyat_listesi_satir v",
        SubeKolonu: "v.sube_id",
        VarsayilanSirala: "v.kod, v.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "v.id",       "sayi",  "Id", Varsayilan: false),
            new("listeId",  "v.liste_id", "sayi",  "Liste Id", Varsayilan: false),
            new("listeAdi", "v.liste_adi","metin", "Liste", Genislik: 180, Varsayilan: false),
            new("kod",      "v.kod",      "metin", "Kodu", Genislik: 120),
            new("ad",       "v.ad",       "metin", "Adı", Genislik: 280),
            new("kategori", "v.kategori", "metin", "Kategori", Genislik: 140),
            new("fiyat",       "v.fiyat",       "para",  "Fiyat", Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",  "v.doviz_cinsi", "metin", "Döviz", Hizalama: "orta"),
            new("kdvDahil", "case when v.kdv_dahil = 1 then 'Dahil' else 'Hariç' end", "metin",
                "KDV", Hizalama: "orta"),
            new("birim",  "v.birim",  "kod", "Birim", Hizalama: "orta"),
            new("durumAdi", "case v.durum when 1 then 'Aktif' else 'Pasif' end", "metin",
                "Durum", Hizalama: "orta", Genislik: 90, Filtrelenebilir: false),
            new("durum", "v.durum", "kod", "Durum Kodu", Hizalama: "orta", Varsayilan: false),
            // Satirin NEREDEN geldigi (214): elle / kuraldan / Excel'den.
            new("yazim",
                "case v.yazim when 1 then 'Manuel' when 3 then 'İmport' else 'Hesap' end",
                "metin", "Oluşma", Hizalama: "orta"),
            new("tabanListeAdi", "v.taban_liste_adi", "metin", "Taban Fiyat", Genislik: 160),
            new("carpan",    "v.carpan",    "para", "Çarpan", Hizalama: "sag", Bicim: "#,##0.0000"),
            new("yuvarlama", "v.yuvarlama", "kod",  "Yuvarlama", Hizalama: "orta"),
            new("tabanFiyat", "v.taban_fiyat", "para", "Taban Fiyat Değeri",
                Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("uretimTarihi", "v.uretim_tarihi", "tarih", "Üretim",
                Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Varsayilan: false),
            new("stokId",   "v.stok_id",   "sayi", "Stok Id", Varsayilan: false),
            new("hizmetId", "v.hizmet_id", "sayi", "Hizmet Id", Varsayilan: false),
            new("subeId",   "v.sube_id",   "sayi", "Şube", Varsayilan: false),
        });
}

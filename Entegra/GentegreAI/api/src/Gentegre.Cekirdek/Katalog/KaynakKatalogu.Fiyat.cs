namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// SATIS FIYAT LISTESI listeleri (201/202): listelerin kendisi ve satirlari.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Fiyat listeleri - kural ve gecerlilik ozeti.</summary>
    private static KaynakTanimi SatisListesi() => new(
        Ad: "satis-listesi",
        YetkiKodu: "satis_listesi",
        Kaynak: """
            public.satis_listesi l
            left join public.satis_listesi t on t.id = l.taban_liste_id
            """,
        SubeKolonu: "l.sube_id",
        VarsayilanSirala: "l.grup, l.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",   "l.id",   "sayi",  "Id", Varsayilan: false),
            new("ad",   "l.ad",   "metin", "Liste Adı", Genislik: 220),
            new("grup", "l.grup", "kod",   "Grubu", Hizalama: "orta"),
            // Yon: belge karti listeyi buna gore suzer (alis belgesinde satis
            //   listesi cikmamali). Gridde de gorunur - hangi liste ne icin.
            new("yon", "case when l.yon = 1 then 'Alış' else 'Satış' end", "metin",
                "Yön", Hizalama: "orta"),
            new("yonKodu", "l.yon", "sayi", "Yön Kodu", Varsayilan: false),
            new("varsayilan", "case when l.varsayilan = 1 then '✓' else '' end", "metin",
                "Varsayılan", Hizalama: "orta"),
            new("tabanListeAdi", "coalesce(t.ad, '')", "metin", "Taban Liste", Genislik: 180),
            new("carpan",    "l.carpan",    "para", "Çarpan", Hizalama: "sag", Bicim: "#,##0.0000"),
            new("yuvarlama", "l.yuvarlama", "kod",  "Yuvarlama", Hizalama: "orta"),
            new("yuvarlamaBirim", "l.yuvarlama_birim", "para", "Adım",
                Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            // KDV iki degerli: kod listesi acmak yerine dogrudan metne cevrilir.
            new("kdvDahil", "case when l.kdv_dahil = 1 then 'Dahil' else 'Hariç' end", "metin",
                "KDV", Hizalama: "orta"),
            new("baslangic", "l.baslangic", "tarih", "Başlama", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("bitis",     "l.bitis",     "tarih", "Bitiş",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            // Satir sayisi: listenin URETILIP uretilmedigini tek bakista gosterir.
            new("satirSayisi",
                "(select count(*) from public.satis_listesi_satir r where r.liste_id = l.id)",
                "sayi", "Satır", Hizalama: "sag", Filtrelenebilir: false),
            new("durum", "case when l.durum = 1 then 'Aktif' else 'Pasif' end", "metin",
                "Durum", Hizalama: "orta"),
            new("aciklama", "l.aciklama", "metin", "Açıklama", Genislik: 240, Varsayilan: false),
            new("subeId", "l.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    /// <summary>
    /// Liste satirlari. Kaynak GORUNUM: kod/ad/kategori kalemin kartindan gelir,
    /// satir tablosunda tutulmaz (kart duzeltilince liste yalan soylemesin).
    /// </summary>
    private static KaynakTanimi SatisListesiSatir() => new(
        Ad: "satis-listesi-satir",
        YetkiKodu: "satis_listesi",
        Kaynak: "public.v_satis_listesi_satir v",
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
            new("durum", "case when v.durum = 1 then 'Aktif' else 'Pasif' end", "metin",
                "Durum", Hizalama: "orta"),
            // Yururlukteki kural: satirda ezme yoksa basligin degeri gorunur.
            new("yazim", "case when v.yazim = 1 then 'Manuel' else 'Hesap' end", "metin",
                "Yazım", Hizalama: "orta"),
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

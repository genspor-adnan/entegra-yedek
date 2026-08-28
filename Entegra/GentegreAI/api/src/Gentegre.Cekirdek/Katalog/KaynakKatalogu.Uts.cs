namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ÜTS listeleri (223): bildirim geçmişi ve askıdaki/gelen ürün envanteri.
///
/// KaynakKatalogu tek dosyada büyümesin diye konu başına partial dosya
/// deseni. İki liste de standart GenGrid'den çizilir - Delphi'deki 2441
/// satırlık özel formun yerini kolon tanımı + aksiyon kataloğu alır.
/// </summary>
public static partial class KaynakKatalogu
{
    // ------------------------------------------------------- uts-bildirim ----
    private static KaynakTanimi UtsBildirim() => new(
        Ad: "uts-bildirim",
        YetkiKodu: "uts",
        Kaynak: "public.uts_bildirim b " +
                "join public.uts_bildirim_mesaj m on m.bildirim_id = b.id " +
                "left join public.stok s on s.id = b.stok_id " +
                "left join public.belge bl on bl.id = b.belge_id",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.ekleme_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",              "sayi",  "Id",          Varsayilan: false),
            new("tarih",         "b.ekleme_tarihi",   "tarih", "Tarih",       Hizalama: "orta",
                                                                             Bicim: "dd.MM.yyyy HH:mm"),
            new("turAdi",
                "case b.tur when 1 then 'Alma' when 2 then 'Verme' " +
                "when 3 then 'Kullanım' else b.tur::text end",
                                                      "metin", "Türü",       Hizalama: "orta",
                                                                             Bicim: "rozet", Genislik: 90,
                                                                             Filtrelenebilir: false),
            new("tur",           "b.tur",             "kod",   "Tür Kodu",   Hizalama: "orta",
                                                                             Varsayilan: false),
            new("durumAdi",
                "case b.durum when 0 then 'Bekliyor' when 1 then 'Başarılı' " +
                "when 2 then 'Hata' when 3 then 'İptal' else b.durum::text end",
                                                      "metin", "Durumu",     Hizalama: "orta",
                                                                             Bicim: "rozet", Genislik: 95,
                                                                             Filtrelenebilir: false),
            new("durum",         "b.durum",           "kod",   "Durum Kodu", Hizalama: "orta",
                                                                             Varsayilan: false),
            new("urunNo",        "m.urun_no",         "metin", "Ürün No (UNO)", Genislik: 140),
            new("lotNo",         "m.lot_no",          "metin", "Lot",        Genislik: 100),
            new("seriNo",        "m.seri_no",         "metin", "Seri",       Genislik: 100),
            new("adet",          "b.adet",            "sayi",  "Adet",       Hizalama: "sag", Genislik: 70),
            new("stokAdi",       "coalesce(s.ad, '')", "metin", "Stok",      Genislik: 180),
            new("kurumNo",       "m.kurum_no",        "metin", "Karşı Kurum No", Genislik: 110,
                                                                             Varsayilan: false),
            new("belgeNo",       "m.belge_no",        "metin", "Belge No",   Genislik: 120),
            new("kaynakBelgeNo", "coalesce(bl.belge_no, '')",
                                                      "metin", "Kaynak Belge", Genislik: 120,
                                                                             Varsayilan: false,
                                                                             Siralanabilir: false,
                                                                             Filtrelenebilir: false),
            new("utsBildirimId", "b.uts_bildirim_id", "metin", "ÜTS Bildirim Id", Genislik: 250,
                                                                             Varsayilan: false),
            new("sonucKodu",     "m.sonuc_kodu",      "metin", "Sonuç Kodu", Hizalama: "orta",
                                                                             Genislik: 90, Varsayilan: false),
            new("sonucMesaji",   "m.sonuc_mesaji",    "metin", "Sonuç",      Genislik: 240),
            new("testMi",
                "case b.test_mi when 1 then 'TEST' else '' end",
                                                      "metin", "Ortam",      Hizalama: "orta",
                                                                             Bicim: "rozet", Genislik: 70,
                                                                             Filtrelenebilir: false),
            new("gercekIslemTarihi", "b.gercek_islem_tarihi",
                                                      "tarih", "İşlem Tarihi", Hizalama: "orta",
                                                                             Bicim: "dd.MM.yyyy",
                                                                             Varsayilan: false),
            // İçerik penceresi (islem-log deseni): ham istek/cevap JSON.
            new("istekJson",     "m.istek_json::text", "metin", "İstek",     Varsayilan: false,
                                                                             Siralanabilir: false,
                                                                             Filtrelenebilir: false),
            new("cevapJson",     "m.cevap_json::text", "metin", "Cevap",     Varsayilan: false,
                                                                             Siralanabilir: false,
                                                                             Filtrelenebilir: false)
        });

    // ------------------------------------------------------- uts-envanter ----
    private static KaynakTanimi UtsEnvanter() => new(
        Ad: "uts-envanter",
        YetkiKodu: "uts",
        Kaynak: "public.uts_envanter e " +
                "left join public.stok s on s.id = e.stok_id",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.bildirim_zamani desc nulls last, e.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "e.id",              "sayi",  "Id",          Varsayilan: false),
            new("durumAdi",
                "case e.durum when 1 then 'Askıda' when 2 then 'Alındı' " +
                "when 0 then 'Kayboldu' else e.durum::text end",
                                                      "metin", "Durumu",     Hizalama: "orta",
                                                                             Bicim: "rozet", Genislik: 90,
                                                                             Filtrelenebilir: false),
            new("durum",         "e.durum",           "kod",   "Durum Kodu", Hizalama: "orta",
                                                                             Varsayilan: false),
            new("kurumUnvan",    "e.kurum_unvan",     "metin", "Veren Kurum", Genislik: 220),
            new("urunNo",        "e.urun_no",         "metin", "Ürün No (UNO)", Genislik: 140),
            new("lotNo",         "e.lot_no",          "metin", "Lot",        Genislik: 100),
            new("seriNo",        "e.seri_no",         "metin", "Seri",       Genislik: 100),
            new("gelenAdet",     "e.gelen_adet",      "sayi",  "Gelen",      Hizalama: "sag", Genislik: 70),
            new("askiAdet",      "e.aski_adet",       "sayi",  "Askıda",     Hizalama: "sag", Genislik: 70),
            new("stokAdi",       "coalesce(s.ad, '')", "metin", "Eşleşen Stok", Genislik: 180),
            new("belgeNo",       "e.belge_no",        "metin", "Belge No",   Genislik: 120),
            new("bildirimTipi",  "e.bildirim_tipi",   "metin", "Bildirim Tipi", Hizalama: "orta",
                                                                             Genislik: 110, Varsayilan: false),
            new("bildirimZamani", "e.bildirim_zamani", "tarih", "Bildirim Zamanı", Hizalama: "orta",
                                                                             Bicim: "dd.MM.yyyy HH:mm"),
            new("markaModel",    "e.marka_model",     "metin", "Marka / Model", Genislik: 180,
                                                                             Varsayilan: false),
            new("gelenUrt",      "e.gelen_urt",       "tarih", "ÜRT",        Hizalama: "orta",
                                                                             Bicim: "dd.MM.yyyy",
                                                                             Varsayilan: false),
            new("gelenSkt",      "e.gelen_skt",       "tarih", "SKT",        Hizalama: "orta",
                                                                             Bicim: "dd.MM.yyyy"),
            new("kurumNo",       "e.kurum_no",        "metin", "Kurum No",   Genislik: 100,
                                                                             Varsayilan: false),
            new("vermeBildirimId", "e.verme_bildirim_id",
                                                      "metin", "Verme Bildirim Id (VBI)",
                                                                             Genislik: 250,
                                                                             Varsayilan: false)
        });
}

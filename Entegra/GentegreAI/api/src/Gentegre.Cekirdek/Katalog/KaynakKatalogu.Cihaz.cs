namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// CİHAZ ARA KATMANI LİSTELERİ (432) — cihazlar ve gelen mesaj kuyruğu.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi Cihaz() => new(
        Ad: "cihaz",
        YetkiKodu: "cihaz",
        Kaynak: "public.cihaz c",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",  "c.id",  "sayi",  "Id", Varsayilan: false),
            new("kod", "c.kod", "metin", "Kod", Genislik: 110),
            new("ad",  "c.ad",  "metin", "Cihaz", Genislik: 220),
            new("turAdi",
                "case c.tur when 2 then 'Görüntüleme' when 3 then 'Göz' "
                + "when 4 then 'Vital / Monitör' when 9 then 'Diğer' "
                + "else 'Laboratuvar' end",
                                 "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false),
            new("tur", "c.tur", "kod", "Tür Kodu", Varsayilan: false),
            new("surucu", "c.surucu", "metin", "Sürücü", Hizalama: "orta", Genislik: 90),
            new("baglantiAdi",
                "case c.baglanti_turu when 2 then 'İstemci' when 3 then 'Klasör' "
                + "else 'Dinleyici' end",
                                 "metin", "Bağlantı", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 110, Filtrelenebilir: false),
            // Dinleyicide adres:port, klasor izlemede yol - tek kolonda
            //   gosterilir; iki ayri kolon satirin yarisinda bos kalirdi.
            new("hedef",
                "case when c.baglanti_turu = 3 then c.klasor_yolu "
                + "else coalesce(nullif(c.adres, ''), '0.0.0.0') || ':' || c.port::text end",
                                 "metin", "Adres / Klasör", Genislik: 260,
                                 Filtrelenebilir: false),
            new("otomatik", "c.otomatik", "mantik", "Otomatik", Hizalama: "orta",
                                 Genislik: 90),
            new("sonMesaj", "c.son_mesaj", "tarih", "Son Mesaj", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            // BUGUNKU MESAJ SAYISI: "cihaz calisiyor mu" sorusunun tek bakista
            //   cevabi - son mesaj zamani eski bir tarihse sessizce durmustur.
            new("bugunMesaj",
                "(select count(*) from public.cihaz_mesaj m "
                + "where m.cihaz_id = c.id and m.ekleme_tarihi >= current_date)",
                                 "sayi",  "Bugün", Hizalama: "orta", Genislik: 70,
                                 Filtrelenebilir: false),
            new("sonHata", "c.son_hata", "metin", "Son Hata", Genislik: 280),
            new("durumAdi",
                "case c.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "c.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// CİHAZ MESAJLARI — gelen ham mesajlar ve çözümleme durumu.
    ///
    /// Ham metin listede İÇERİK penceresinde okunur: çözümleme hatasında
    /// bakılacak tek yer orasıdır.
    /// </summary>
    private static KaynakTanimi CihazMesaj() => new(
        Ad: "cihaz-mesaj",
        YetkiKodu: "cihaz",
        Kaynak: "public.cihaz_mesaj m join public.cihaz c on c.id = m.cihaz_id",
        SubeKolonu: "m.sube_id",
        VarsayilanSirala: "m.ekleme_tarihi desc, m.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "m.id", "sayi", "Id", Varsayilan: false),
            new("eklemeTarihi", "m.ekleme_tarihi", "tarih", "Alındı", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm:ss", Genislik: 150),
            new("cihazAd", "c.kod || ' · ' || c.ad", "metin", "Cihaz", Genislik: 200),
            new("protokol", "m.protokol", "metin", "Protokol", Hizalama: "orta",
                                 Genislik: 90),
            new("mesajTipi", "m.mesaj_tipi", "metin", "Mesaj", Hizalama: "orta",
                                 Genislik: 100),
            new("ornekNo", "m.ornek_no", "metin", "Örnek No", Hizalama: "orta",
                                 Genislik: 120),
            new("istemNo", "m.istem_no", "metin", "İstem No", Hizalama: "orta",
                                 Genislik: 120),
            new("hastaNo", "m.hasta_no", "metin", "Hasta No", Hizalama: "orta",
                                 Genislik: 120),
            new("kalemSayisi", "m.kalem_sayisi", "sayi", "Sonuç", Hizalama: "orta",
                                 Genislik: 70),
            new("durumAdi",
                """
                case m.durum when 1 then 'Alındı' when 2 then 'Çözümlendi'
                             when 3 then 'İşlendi' when 4 then 'Hata'
                             when 5 then 'Yok sayıldı' else '' end
                """,             "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 110, Filtrelenebilir: false),
            new("durum", "m.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("hata", "m.hata", "metin", "Hata", Genislik: 300),
            new("kaynak", "m.kaynak", "metin", "Kaynak", Genislik: 180,
                                 Varsayilan: false),
            new("cihazZamani", "m.cihaz_zamani", "tarih", "Cihaz Zamanı",
                                 Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm",
                                 Genislik: 130, Varsayilan: false),
            new("ham", "m.ham", "metin", "Ham Mesaj", Varsayilan: false,
                                 Siralanabilir: false, Filtrelenebilir: false),
        });
}

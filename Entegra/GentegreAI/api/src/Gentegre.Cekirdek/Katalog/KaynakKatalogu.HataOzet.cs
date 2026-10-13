namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HATA ÖZETİ (1078, dokuman/17 §2.1) — hata günlüğü TÜRÜNE göre, gün gün.
///
/// hata_log her 4xx/5xx'i tutuyordu ama okunmuyordu: belge beyaz listesi
/// hatası 8 gün kayıtta durdu. Liste aynı yol + mesajı (sayılar normalize)
/// tek satırda toplar; "Yeni" o gün İLK KEZ görülen türdür - bakılacak ilk
/// yer. Ayrıntı (yığın) için izleme numarası hata_log'da aranır.
/// Salt okunur; kart yok.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi HataOzet() => new(
        Ad: "hata-ozet",
        YetkiKodu: "hata_ozet",
        Kaynak: "public.v_hata_gunluk h",
        // Önce sunucu hataları, sonra yeni türler, sonra sıklık.
        VarsayilanSirala: "h.gun desc, (h.http_durum >= 500) desc, h.yeni desc, h.adet desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "h.id",               "sayi",  "Id", Varsayilan: false),
            new("gun",          "h.gun",              "tarih", "Gün", Hizalama: "orta",
                                                      Bicim: "dd.MM.yyyy", Genislik: 95),
            new("sinif",        "h.sinif",            "metin", "Sınıf", Hizalama: "orta",
                                                      Bicim: "rozet", Genislik: 100),
            new("httpDurum",    "h.http_durum",       "sayi",  "HTTP", Hizalama: "orta", Genislik: 60),
            new("yeniAdi",      "case when h.yeni = 1 then 'Yeni' else '' end",
                                                      "metin", "Yeni", Hizalama: "orta",
                                                      Bicim: "rozet", Genislik: 70,
                                                      Filtrelenebilir: false),
            new("yeni",         "h.yeni",             "sayi",  "Yeni (kod)", Varsayilan: false),
            new("adet",         "h.adet",             "sayi",  "Adet", Hizalama: "sag", Genislik: 60),
            new("kullaniciSayisi", "h.kullanici_sayisi", "sayi", "Kullanıcı", Hizalama: "sag",
                                                      Genislik: 75),
            new("yontem",       "h.yontem",           "metin", "Yöntem", Hizalama: "orta", Genislik: 70),
            new("yol",          "h.yol_imza",         "metin", "Yol", Genislik: 260),
            new("mesaj",        "h.ornek_mesaj",      "metin", "Mesaj", Genislik: 360),
            new("kod",          "h.kod",              "metin", "Hata Kodu", Varsayilan: false),
            new("son",          "h.son",              "tarih", "Son", Hizalama: "orta",
                                                      Bicim: "HH:mm", Genislik: 60),
            new("sonIzlemeNo",  "h.son_izleme_no",    "metin", "İzleme No", Genislik: 150),
            new("ornekYol",     "h.ornek_yol",        "metin", "Örnek Yol", Varsayilan: false),
        });
}

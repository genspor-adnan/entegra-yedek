namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — KALİTE DOKÜMANLARI (1068), mockup
/// <c>Ekranlar/Kalite2/kalite_dokumanlari.html</c>. Doküman modülünün
/// "Kalite Dokümanları" kategori ağacına süzülmüş liste; kendi yetkisiyle
/// (kys.dokuman) - genel <c>dokuman</c> kaynağı doküman yetkisi istiyordu.
/// Kart Doküman modülünün kartı (/dokuman/:id), burada yeniden yazılmaz.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysDokuman() => new(
        Ad: "kys-dokuman",
        YetkiKodu: "kys.dokuman",
        Kaynak: "public.v_kalite_dokuman d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.kod, d.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "d.id",                     "sayi",  "Id", Varsayilan: false),
            new("kod",           "d.kod",                    "metin", "Kod", Genislik: 110),
            new("ad",            "d.ad",                     "metin", "Ad", Genislik: 320),
            new("tur",           "d.tur",                    "metin", "Tür", Genislik: 130),
            new("rev",           "d.rev",                    "metin", "Rev", Hizalama: "orta", Genislik: 60),
            new("yayin",         "d.yayin",                  "tarih", "Yayın"),
            new("sonrakiGozden", "d.sonraki_gozden_gecirme", "tarih", "Sonraki gözden geçirme"),
            new("durumAdi",      "d.durum_adi",              "metin", "Durum", Genislik: 140, Bicim: "rozet"),
            new("sahipAdi",      "d.sahip_adi",              "metin", "Sahip", Genislik: 140, Varsayilan: false),
            new("durum",         "d.durum",                  "sayi",  "Durum Kodu", Varsayilan: false),
            new("gozdenGecti",   "d.gozden_gecti",           "sayi",  "Gözden geçirme vakti", Varsayilan: false),
            new("kategoriId",    "d.kategori_id",            "sayi",  "Kategori Id", Varsayilan: false),
        });
}

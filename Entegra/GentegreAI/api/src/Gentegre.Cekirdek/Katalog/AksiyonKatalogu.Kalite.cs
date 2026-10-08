using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Klinik kalite (711/713): gosterge, olgu, donem.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKalite(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {

        // =========================================== KLINIK KALITE (711/713) ==
        // Donem sonuclari: hesapla / kesinlestir DONEM islemidir, satir
        //   secimi istemez. Kesinlestirme TEK YON oldugu icin ayri yetki
        //   (klinik_kalite.kesinlestir) ve kirmizi bicim - geri alinamayan
        //   islemi gundelik hesaplamayla ayni renkte gostermek yanlis
        //   dugmeye basmayi kolaylastirirdi.
        s["klinik-kalite-donem-liste"] = new AksiyonTanimi[]
        {
            new("klinik-kalite.hesapla", "🔄 Dönemi Hesapla", "klinik_kalite",
                AksiyonYetkisi: "klinik_kalite.hesapla", Sira: 10, UrunModu: 2,
                Bicim: "bir",
                Ipucu: "Dönemin tüm otomatik göstergelerini yeniden hesaplar; kesinleşmiş satıra dokunmaz"),
            new("klinik-kalite.kesinlestir", "🔒 Dönemi Kesinleştir", "klinik_kalite",
                AksiyonYetkisi: "klinik_kalite.kesinlestir", Sira: 20, UrunModu: 2,
                Bicim: "ret",
                Ipucu: "Taslak satırları dondurur - geri alınamaz"),
            new("klinik-kalite.onizle", "🔢 Göstergeyi Önizle", "klinik_kalite",
                KaynakKodu: "klinik_kalite", Islem: Islem.Gor, KayitGerekir: true,
                Sira: 30, UrunModu: 2,
                Ipucu: "Seçili göstergeyi hesaplar ama KAYDETMEZ"),
            Yazdir(),
        };

        // Gosterge katalogu: yalniz onizleme. Katalog rehberin mali,
        //   buradan donem yazilmaz.
        s["klinik-gosterge-liste"] = new AksiyonTanimi[]
        {
            new("klinik-kalite.onizle", "🔢 Bu Göstergeyi Önizle", "klinik_kalite",
                KaynakKodu: "klinik_kalite", Islem: Islem.Gor, KayitGerekir: true,
                Sira: 10, UrunModu: 2,
                Ipucu: "Seçili göstergeyi bir dönem için hesaplar ama KAYDETMEZ"),
            Yazdir(),
        };
    }
}

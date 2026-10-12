using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Kurumsal Kalite kalibrasyon (1058). Cihaz eklenmez /
/// silinmez (Sabit Varlıklar'ın kaydı); "Kalibrasyon Gir" cihaz kartını açar,
/// kayıt sekmesine satır eklenir.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysKalibrasyon(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-kalibrasyon-liste"] =
        [
            new("kys-kalibrasyon.duzenle", "✔ Kalibrasyon Gir", "kys", Kisayol: "Enter",
                KaynakKodu: "kys.kalibrasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            // Mockup (1067): "＋ Cihaz" demirbaş kartını açar (envanter Sabit
            //   Varlıklar'da, demirbaş ekleme yetkisi ister); "Kalibrasyon Planı" A4.
            new("kys.kalibrasyon-cihaz", "＋ Cihaz", "kys", KaynakKodu: "demirbas", Islem: Islem.Ekle, Sira: 5),
            new("kys.kalibrasyon-plan", "🖨️ Kalibrasyon Planı", "kys", KaynakKodu: "kys.kalibrasyon", Sira: 30),
            Yazdir(),
        ];
    }
}

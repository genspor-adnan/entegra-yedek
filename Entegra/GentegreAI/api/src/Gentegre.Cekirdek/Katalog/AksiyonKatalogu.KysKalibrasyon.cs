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
            Yazdir(),
        ];
    }
}

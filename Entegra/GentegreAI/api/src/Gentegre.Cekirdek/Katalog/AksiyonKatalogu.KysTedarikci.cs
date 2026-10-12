using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Kurumsal Kalite tedarikçi değerlendirme (1057).
/// "Yeniden değerlendir" aynı tedarikçiye yeni değerlendirme kartı açar
/// (/kys-tedarikci/yeni?tarafId=…); "DÖF aç" DÖF yetkisine (kys.dof ekle)
/// bağlı, kaynakTur 8 (tedarikçi) ve kaynakId = tedarikçinin taraf id'si.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysTedarikci(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-tedarikci-liste"] =
        [
            .. Crud("kys-tedarikci", "kys", "kys.tedarikci", ekleAdi: "＋ Değerlendir", yazdir: false),
            new("kys.tedarikci-yeniden", "↻ Yeniden değerlendir", "kys", KaynakKodu: "kys.tedarikci", Islem: Islem.Ekle, KayitGerekir: true, Sira: 35),
            new("kys.tedarikci-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
            // Mockup (1066): onaylı tedarikçilerin A4 listesi (ISO 8.4 kanıtı).
            new("kys.tedarikci-onayli", "🖨️ Onaylı Tedarikçi Listesi", "kys", KaynakKodu: "kys.tedarikci", Sira: 45),
            Yazdir(),
        ];
    }
}

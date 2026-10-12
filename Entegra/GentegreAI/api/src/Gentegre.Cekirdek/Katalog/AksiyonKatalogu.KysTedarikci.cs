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
            // Mockup Kalite2/tedarikci.html (1071): araç çubuğu "＋ Değerlendir ·
            //   🖨️ Onaylı Tedarikçi Listesi". Kartı aç / sil / yeniden değerlendir /
            //   DÖF aç sağ tık; genel Yazdır (CSV) yalnız palet.
            new("kys-tedarikci.yeni", "＋ Değerlendir", "kys", Kisayol: "Ctrl+N",
                KaynakKodu: "kys.tedarikci", Islem: Islem.Ekle, Sira: 10),
            new("kys-tedarikci.duzenle", "✎ Düzenle", "kys", Kisayol: "Enter",
                KaynakKodu: "kys.tedarikci", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("kys-tedarikci.sil", "🗑 Sil", "kys", Kisayol: "Del",
                KaynakKodu: "kys.tedarikci", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            new("kys.tedarikci-yeniden", "↻ Yeniden değerlendir", "kys", Hedef: "sagtus,palet", KaynakKodu: "kys.tedarikci", Islem: Islem.Ekle, KayitGerekir: true, Sira: 35),
            new("kys.tedarikci-dof", "🛠️ DÖF Aç", "kys", Hedef: "sagtus,palet", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
            // Mockup (1066): onaylı tedarikçilerin A4 listesi (ISO 8.4 kanıtı).
            new("kys.tedarikci-onayli", "🖨️ Onaylı Tedarikçi Listesi", "kys", KaynakKodu: "kys.tedarikci", Sira: 45),
            Yazdir() with { Hedef = "palet" },
        ];
    }
}

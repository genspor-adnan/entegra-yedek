using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Kurumsal Kalite olay bildirimi ve risk kaydı (1052).
/// Olay kaydı silinmez. "DÖF aç" DÖF yetkisine (kys.dof ekle) bağlı; ekran
/// /kys-dof/yeni'ye kaynak bilgisiyle gider (kaynakTur 2 olay, 4 risk).
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysOlayRisk(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-olay-liste"] =
        [
            // Mockup Kalite2/olay_bildirim.html (1071): araç çubuğu "＋ Yeni Bildirim ·
            //   🛠️ DÖF Aç · 🖨️ Liste". Düzenleme sağdaki kartta; "Düzenle" yalnız
            //   sağ tık / Enter (modal kart).
            new("kys-olay.yeni", "＋ Yeni Bildirim", "kys", Kisayol: "Ctrl+N",
                KaynakKodu: "kys.olay", Islem: Islem.Ekle, Sira: 10),
            new("kys-olay.duzenle", "✎ Kartı aç", "kys", Hedef: "sagtus,palet", Kisayol: "Enter",
                KaynakKodu: "kys.olay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("kys.olay-dof", "🛠️ DÖF Aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
            Yazdir() with { Ad = "🖨️ Liste" },
        ];
        s["kys-risk-liste"] =
        [
            .. Crud("kys-risk", "kys", "kys.risk", ekleAdi: "＋ Yeni Risk", silHedef: null, yazdir: false),
            new("kys.risk-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
            Yazdir(),
        ];
    }
}

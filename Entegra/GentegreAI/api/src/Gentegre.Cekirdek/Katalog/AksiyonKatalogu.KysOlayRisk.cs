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
            // Kullanıcı (12.10.2026): "ekleme butonu olan yerlerin yanına düzenle ve sil".
            new("kys-olay.duzenle", "✎ Düzenle", "kys", Kisayol: "Enter",
                KaynakKodu: "kys.olay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("kys-olay.sil", "🗑 Sil", "kys", Kisayol: "Del",
                KaynakKodu: "kys.olay", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            new("kys.olay-dof", "🛠️ DÖF Aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
            Yazdir() with { Ad = "🖨️ Liste" },
        ];
        s["kys-risk-liste"] =
        [
            // Mockup Kalite2/risk_listesi.html (1071): "＋ Yeni Risk · 🖨️ Risk Listesi";
            //   kullanıcı (12.10.2026): "riskler listesine düzenle ve sil ekle" -
            //   Düzenle / Sil araç çubuğunda. DÖF Aç sağ tık ve yandaki kartta.
            new("kys-risk.yeni", "＋ Yeni Risk", "kys", Kisayol: "Ctrl+N",
                KaynakKodu: "kys.risk", Islem: Islem.Ekle, Sira: 10),
            new("kys-risk.duzenle", "✎ Düzenle", "kys", Kisayol: "Enter",
                KaynakKodu: "kys.risk", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("kys-risk.sil", "🗑 Sil", "kys", Kisayol: "Del",
                KaynakKodu: "kys.risk", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            new("kys.risk-dof", "🛠️ DÖF Aç", "kys", Hedef: "sagtus,palet", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
            Yazdir() with { Ad = "🖨️ Risk Listesi" },
        ];
    }
}

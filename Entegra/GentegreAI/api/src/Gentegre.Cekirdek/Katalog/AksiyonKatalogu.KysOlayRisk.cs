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
            .. Crud("kys-olay", "kys", "kys.olay", ekleAdi: "＋ Olay", sil: false),
            new("kys.olay-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
        ];
        s["kys-risk-liste"] =
        [
            .. Crud("kys-risk", "kys", "kys.risk", ekleAdi: "＋ Risk", silHedef: null, yazdir: false),
            new("kys.risk-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
            Yazdir(),
        ];
    }
}

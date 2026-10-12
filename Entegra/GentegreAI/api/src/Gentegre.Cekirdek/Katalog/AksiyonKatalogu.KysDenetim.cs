using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE - İÇ DENETİM (1051, sade): CRUD + "Bulgular" (seçili
/// denetimin bulgu listesi, 1059); bulgu listesinde "DÖF aç" (kaynak_tur 1).
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysDenetim(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-denetim-liste"] =
        [
            // Mockup Kalite2/ic_denetim.html (1071): araç çubuğu "＋ Denetim Planla ·
            //   🖨️ Yıllık Plan" (yıllık plan = tarihli denetim listesinin çıktısı).
            //   Kartı aç / sil / bulgular sağ tık; bulgudan DÖF kartın içinde.
            new("kys-denetim.yeni", "＋ Denetim Planla", "kys", Kisayol: "Ctrl+N",
                KaynakKodu: "kys.denetim", Islem: Islem.Ekle, Sira: 10),
            new("kys-denetim.duzenle", "✎ Düzenle", "kys", Kisayol: "Enter",
                KaynakKodu: "kys.denetim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("kys-denetim.sil", "🗑 Sil", "kys", Kisayol: "Del",
                KaynakKodu: "kys.denetim", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            new("kys.denetim-bulgular", "📋 Bulgular / DÖF", "kys", Hedef: "sagtus,palet", KaynakKodu: "kys.denetim", KayitGerekir: true, Sira: 40),
            Yazdir() with { Ad = "🖨️ Yıllık Plan" },
        ];
        s["kys-denetim-bulgu-liste"] =
        [
            new("kys.bulgu-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 10),
            Yazdir(),
        ];
    }
}

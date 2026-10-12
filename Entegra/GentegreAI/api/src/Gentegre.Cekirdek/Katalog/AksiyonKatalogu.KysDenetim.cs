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
            .. Crud("kys-denetim", "kys", "kys.denetim", ekleAdi: "＋ Yeni Denetim", silHedef: null),
            new("kys.denetim-bulgular", "📋 Bulgular / DÖF", "kys", KaynakKodu: "kys.denetim", KayitGerekir: true, Sira: 40),
        ];
        s["kys-denetim-bulgu-liste"] =
        [
            new("kys.bulgu-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 10),
            Yazdir(),
        ];
    }
}

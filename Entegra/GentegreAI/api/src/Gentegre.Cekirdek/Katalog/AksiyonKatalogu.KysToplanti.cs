using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1053) toplantılar ve Karar Takibi: CRUD; karardan
/// "DÖF aç" (1059, kaynak_tur 6).
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysToplanti(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-toplanti-liste"] = Crud("kys-toplanti", "kys", "kys.toplanti", ekleAdi: "＋ Toplantı");
        s["kys-karar-liste"] =
        [
            .. Crud("kys-karar", "kys", "kys.toplanti", ekleAdi: "＋ Karar"),
            new("kys.karar-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
        ];
    }
}

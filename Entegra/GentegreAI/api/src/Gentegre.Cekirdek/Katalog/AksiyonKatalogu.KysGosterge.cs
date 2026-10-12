using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1053) Politika &amp; Hedefler: CRUD + hedef dışı satırdan
/// "DÖF aç" (1059, kaynak_tur 7; DÖF ekleme yetkisine bağlı).
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysGosterge(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-gosterge-liste"] =
        [
            .. Crud("kys-gosterge", "kys", "kys.gosterge", ekleAdi: "＋ Hedef"),
            new("kys.gosterge-dof", "🛠 DÖF aç", "kys", KaynakKodu: "kys.dof", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
        ];
    }
}

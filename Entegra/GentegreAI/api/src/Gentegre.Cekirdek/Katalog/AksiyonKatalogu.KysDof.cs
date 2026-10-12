using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>KURUMSAL KALİTE — DÖF (1050, sade) liste aksiyonları: generic yeni / düzenle / sil.</summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysDof(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-dof-liste"] = Crud("kys-dof", "kys", "kys.dof", ekleAdi: "＋ Yeni DÖF",
            silIpucu: "Yanlış açılan DÖF silinir; işlem görmüş DÖF'ü 'İptal' durumuna alın.");
    }
}

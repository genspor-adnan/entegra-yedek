namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1056) — eğitim listelerinin aksiyonları. Eğitim kaydı
/// özel kartta silinir (grup = birden çok personel_egitim satırı; generic
/// kart silme tek satırı bilir), listede Sil yok.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysEgitim(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-egitim-liste"] = Crud("kys-egitim", "kys", "kys.egitim", ekleAdi: "＋ Eğitim Kaydı", sil: false);
        s["kys-zorunlu-egitim-liste"] = Crud("kys-zorunlu-egitim", "kys", "kys.egitim", ekleAdi: "＋ Zorunlu Eğitim", yazdir: false);
    }
}

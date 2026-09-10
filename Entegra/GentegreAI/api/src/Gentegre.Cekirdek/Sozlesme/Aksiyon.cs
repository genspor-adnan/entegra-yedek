namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>
/// API §7 - aksiyon katalogu satiri.
///
/// Yetkisiz aksiyon bu listede HIC DONMEZ. Kosul nedeniyle kapaliysa aktif = false
/// ve pasifSebep dolu doner: menude gorunen her islem ya calisir ya sebebini soyler.
/// </summary>
public sealed record AksiyonYaniti(
    string Kod,
    string Ad,
    string Grup,
    string Hedef,
    string? Kisayol,
    bool KayitGerekir,
    bool Aktif,
    string? PasifSebep,
    /// <summary>
    /// Dugmenin VURGUSU: "onay" (yesil) · "ret" (kirmizi) · "bir" (birincil).
    /// Renk KARARI sunucudadir - istemcinin kod adina bakip renk uydurmasi,
    /// ayni aksiyonu iki ekranda iki turlu gostermeye acik kapi birakirdi.
    /// </summary>
    string? Bicim = null,
    /// <summary>
    /// IPUCU (543): dugmenin uzerinde bekleyince cikan aciklama. Ad'i IKON
    /// olan dugmelerde (fiyat listesi "🗑") adin kendisi bir sey anlatmiyor -
    /// ne yaptigi ancak burada yazili olur.
    /// </summary>
    string? Ipucu = null);

public sealed class AksiyonListesi
{
    public string Ekran { get; set; } = "";
    public long? KayitId { get; set; }
    public IReadOnlyList<AksiyonYaniti> Aksiyonlar { get; set; } = Array.Empty<AksiyonYaniti>();
}

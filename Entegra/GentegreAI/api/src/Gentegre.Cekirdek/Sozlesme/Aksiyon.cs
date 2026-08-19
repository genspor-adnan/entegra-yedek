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
    string? PasifSebep);

public sealed class AksiyonListesi
{
    public string Ekran { get; set; } = "";
    public long? KayitId { get; set; }
    public IReadOnlyList<AksiyonYaniti> Aksiyonlar { get; set; } = Array.Empty<AksiyonYaniti>();
}

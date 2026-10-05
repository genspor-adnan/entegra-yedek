namespace Gentegre.Cekirdek.Uts;

/// <summary>
/// Doğrulanmış ürün kimliği ve adet (ÜTS alan adlarıyla).
///
/// <para><c>Adt</c> NULL olabilir ve bu bir eksiklik değil: tekil (seri
/// numaralı) takipte ÜTS'ye adet GÖNDERİLMEZ - gönderilirse bildirim
/// reddedilir. Lot takibinde ise en az 1 olmak zorundadır.</para>
/// </summary>
/// <param name="Uno">Ürün numarası (GTIN).</param>
/// <param name="Lno">Lot numarası - tekil takipte boş olabilir.</param>
/// <param name="Sno">Seri numarası - lot takibinde boş olabilir.</param>
/// <param name="Adt">Adet; tekil takipte null.</param>
public sealed record UtsTekilKimlik(string Uno, string? Lno, string? Sno, decimal? Adt)
{
    /// <summary>İz kaydına yazılırken boş dize beklenen alanlar.</summary>
    public string LotMetin => Lno ?? "";
    public string SeriMetin => Sno ?? "";
    /// <summary>İz kaydının adet alanı: tekil takipte 1 satır yazılır.</summary>
    public decimal IzAdet => Adt ?? 1;
}

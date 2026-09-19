namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HEKİM KISITI — "hekim girince yalnız kendine gelen hastaları görsün".
///
/// Kullanıcı planlı bir hekimse (fn_hekim_planli = 1) buradaki kaynaklarda
/// WHERE'e <c>{kolon} = kullanıcı id</c> eklenir (SorguUretici.Nerede); hekim
/// olmayan kullanıcı (banko, yönetici, başhekim) tüm satırları görür. Kural
/// kaynak kaydının alanı olarak değil ayrı haritada durur: kaynak kaydı
/// (KaynakKatalogu.cs) sık dokunulan ortak dosya, kısıt ise iki listeyi ilgilendirir.
/// </summary>
public static partial class KaynakKatalogu
{
    private static readonly Dictionary<string, string> HekimKolonlari = new(StringComparer.Ordinal)
    {
        ["hekim-listesi"] = "bb.personel_id",   // başvurunun hekimi
        ["muayene"]       = "m.personel_id",    // muayeneyi yapan hekim
    };

    /// <summary>Kaynakta hekim kısıtı uygulanacak kolon; kısıt yoksa null.</summary>
    public static string? HekimKolonu(string kaynakAdi)
        => HekimKolonlari.TryGetValue(kaynakAdi, out var k) ? k : null;
}

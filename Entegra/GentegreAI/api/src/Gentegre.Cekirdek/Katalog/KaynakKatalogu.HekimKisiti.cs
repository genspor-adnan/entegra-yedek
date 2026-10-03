namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HEKİM KISITI — "hekim girince yalnız kendine gelen hastaları görsün".
///
/// Kullanıcı hekimse (bkz. <see cref="HekimKisitliSql"/>) buradaki kaynaklarda
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
        // RANDEVU (kullanici: "uzman doktor rolu sadece kendi adina acilmis
        //   randevulari gorur"): liste + takvim ayni uctan okur.
        ["randevu"]       = "rv.hekim_id",
    };

    /// <summary>
    /// KULLANICI HEKİM Mİ (tek tanım - liste ucu ve kayıt erişim kapısı aynı
    /// sorguyu kullanır). Çalışma planı olan hekim (fn_hekim_planli) YA DA ana
    /// rolü klinik hekim rolü olan kullanıcı. Rol koşulu eklendi (kullanıcı:
    /// "hekim kendi adıyla çalışma listesine girdiğinde diğer hekimlerin
    /// listesi de geldi"): planı henüz girilmemiş hekim kısıtsız kalıyordu.
    /// Başhekim / yardımcısı bilerek dışarıda - bütün listeyi görür.
    /// Parametre @p0 = kullanıcı id; sonuç 1/0.
    /// </summary>
    public const string HekimKisitliSql = """
        select (public.fn_hekim_planli(@p0) = 1
                or exists (select 1 from public.taraf_kullanici k
                             join public.rol r on r.id = k.rol_id
                            where k.id = @p0
                              and r.kod in ('hekim', 'pratisyen_doktor', 'acil_hekimi')))::int
        """;

    /// <summary>Kaynakta hekim kısıtı uygulanacak kolon; kısıt yoksa null.</summary>
    public static string? HekimKolonu(string kaynakAdi)
        => HekimKolonlari.TryGetValue(kaynakAdi, out var k) ? k : null;
}

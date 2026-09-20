namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TEST SEVİYESİNDE YETKİ KISITI (889 — KTS denetim maddesi L7).
///
/// Yetki modül seviyesindeydi: <c>lab.sonuc</c> yetkisi olan herkes HER
/// tetkikin sonucunu görüyordu. HIV, adli toksikoloji, genetik gibi
/// testlerde sonucu görmesi gereken kişi ile laboratuvarın tamamını gören
/// kişi aynı değildir.
///
/// Buradaki kaynaklarda WHERE'e <c>fn_lab_tetkik_izin(kolon, rol, 'gor')</c>
/// eklenir (SorguUretici.Nerede). Kısıtı olmayan tetkik herkese açıktır, yani
/// kural tanımlanana kadar hiçbir liste değişmez.
///
/// Kural kaynak kaydının alanı olarak değil ayrı haritada durur — hekim
/// kısıtındaki (KaynakKatalogu.HekimKisiti) gerekçenin aynısı: kaynak kaydı
/// sık dokunulan ortak dosya, kısıt ise birkaç listeyi ilgilendirir.
/// </summary>
public static partial class KaynakKatalogu
{
    private static readonly Dictionary<string, string> TetkikKisitKolonlari =
        new(StringComparer.Ordinal)
    {
        ["lab-sonuc"]  = "ls.tetkik_id",   // sonuç satırı - en hassas kayıt
        ["lab-kultur"] = "k.tetkik_id",    // kültür çalışma listesi
    };

    /// <summary>Kaynakta test yetki kısıtı uygulanacak tetkik kolonu; yoksa null.</summary>
    public static string? TetkikKisitKolonu(string kaynakAdi)
        => TetkikKisitKolonlari.TryGetValue(kaynakAdi, out var k) ? k : null;
}

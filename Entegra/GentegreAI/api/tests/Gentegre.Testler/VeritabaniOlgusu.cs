using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// VERİTABANI GEREKTİREN TESTLER İÇİN ORTAK BAĞLAM.
///
/// Bağlantı dizesi <c>GENTEGRE_TEST_DB</c> ortam değişkeninden gelir; yoksa
/// yerel geliştirme veritabanı denenir. Bağlanılamıyorsa test SINIFI ATLANIR
/// (hata vermez): birim testleri her makinede çalışmalı, veritabanı olmayan
/// bir CI adımında kırmızı görmek gürültüden başka bir şey değil.
///
/// <para>Testler KENDİ VERİSİNİ açar ve siler; ortak veriye dokunmaz.</para>
/// </summary>
public sealed class VeritabaniOlgusu : IDisposable
{
    public VeriKaynagi? Veri { get; }
    public string? AtlamaSebebi { get; }

    public VeritabaniOlgusu()
    {
        var dizge = Environment.GetEnvironmentVariable("GENTEGRE_TEST_DB")
            ?? "Host=localhost;Port=5434;Database=gentegre_ai;Username=postgres;Password=FETAGEN";
        try
        {
            var veri = new VeriKaynagi(dizge);
            // Gerçekten bağlanabiliyor muyuz: açılışta bir kez denenir.
            veri.TekDegerAsync<int>("select 1", null).GetAwaiter().GetResult();
            Veri = veri;
        }
        catch (Exception h)
        {
            AtlamaSebebi = $"Veritabanına bağlanılamadı ({h.GetType().Name}): {h.Message}";
        }
    }

    /// <summary>
    /// Bağlantı yoksa testi ATLAR; varsa kaynağı verir.
    ///
    /// xUnit v2'de çalışma anında "atla" yok; bu yüzden testler
    /// <see cref="Baglandi"/> ile başlar ve bağlantı yoksa sessizce döner.
    /// Kırmızı yerine "yeşil ama çalışmadı" da yanıltıcı olurdu - bu yüzden
    /// atlanan her test konsola sebebini yazar.
    /// </summary>
    public bool Baglandi(string testAdi)
    {
        if (Veri is not null) return true;
        Console.WriteLine($"[ATLANDI] {testAdi}: {AtlamaSebebi}");
        return false;
    }

    public VeriKaynagi Gerekli() => Veri!;

    public void Dispose() => Veri?.DisposeAsync().AsTask().GetAwaiter().GetResult();
}

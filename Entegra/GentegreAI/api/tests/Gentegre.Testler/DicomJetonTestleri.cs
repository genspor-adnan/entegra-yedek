using Gentegre.Api.Servisler;
using Microsoft.Extensions.Options;

namespace Gentegre.Testler;

/// <summary>
/// DICOM BAĞLANTI JETONU (DicomKaynagi; ClearCanvas + OHIF, 11.11.2026): manifest ve WADO uçları anonim ama jetonlu -
/// jeton çalışma UID'sine bağlı, süreli, imza anahtarıyla HMAC. Başka çalışma, bozuk imza ya da süresi dolmuş jeton geçmez.
/// </summary>
public sealed class DicomJetonTestleri
{
    private static DicomKaynagi Kaynak() => new(
        // 1316: ayar depodan; satır okunmaz (veri null) - DB'ye gitmeyen yol (JetonUret dakika verilmezse dosya ayarı).
        new DicomAyarDeposu(Options.Create(new DicomAyarlari { Aktif = true, JetonDakika = 60 }), null!,
                            Microsoft.Extensions.Logging.Abstractions.NullLogger<DicomAyarDeposu>.Instance),
        Options.Create(new GuvenlikAyarlari { ImzaAnahtari = "test-imza-anahtari-0123456789abcdef-uzun" }),
        new BosHttp());

    private sealed class BosHttp : IHttpClientFactory
    {
        public HttpClient CreateClient(string name) => new();
    }

    [Fact]
    public void Jeton_kendi_calismasinda_gecer_baskasinda_gecmez()
    {
        var k = Kaynak();
        var uid = "1.2.826.0.1.3680043.8.498.1";
        var j = k.JetonUret(uid);
        Assert.True(k.JetonGecerli(uid, j));
        Assert.False(k.JetonGecerli(uid + "0", j));
        Assert.False(k.JetonGecerli(uid, j[..^2] + "zz"));
        Assert.False(k.JetonGecerli(uid, null));
        Assert.False(k.JetonGecerli(uid, "bozuk"));
    }

    [Fact]
    public void Suresi_dolmus_jeton_gecmez()
    {
        var k = Kaynak();
        var uid = "1.2.3";
        var j = k.JetonUret(uid, dakika: -1);
        Assert.False(k.JetonGecerli(uid, j));
    }
}

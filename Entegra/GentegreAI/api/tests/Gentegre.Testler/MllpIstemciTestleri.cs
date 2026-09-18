using System.Net;
using System.Net.Sockets;
using System.Text;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Cihaz;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// MLLP İSTEMCİSİ — LOOPBACK (814). Veritabanı gerektirmez.
///
/// Kapsam belgesindeki *"karşı uç olmadan test"* maddesinin karşılığı: test
/// kendi TCP dinleyicisini açar, ürettiğimiz ORU'yu ona gönderir, geldiği
/// gibi doğrular ve ACK üretip döner. Böylece çerçeveleme (0x0B … 0x1C 0x0D),
/// kodlama ve ACK yorumu gerçek soketle sınanır - taklit nesneyle değil.
/// </summary>
public sealed class MllpIstemciTestleri
{
    private const byte Bas = 0x0B, Bit1 = 0x1C, Bit2 = 0x0D;

    /// <summary>Tek mesaj kabul eden minik MLLP sunucusu.</summary>
    private sealed class SahteAlici : IDisposable
    {
        private readonly TcpListener _dinleyici;
        private readonly string _ackKodu;
        private readonly bool _ackGonder;
        private readonly Encoding _kodlama;

        public string AlinanMesaj { get; private set; } = "";
        public int Port => ((IPEndPoint)_dinleyici.LocalEndpoint).Port;
        public Task Dongu { get; }

        public SahteAlici(string ackKodu = "AA", bool ackGonder = true, Encoding? kodlama = null)
        {
            _ackKodu = ackKodu;
            _ackGonder = ackGonder;
            _kodlama = kodlama ?? Encoding.UTF8;
            _dinleyici = new TcpListener(IPAddress.Loopback, 0);
            _dinleyici.Start();
            Dongu = KabulEtAsync();
        }

        private async Task KabulEtAsync()
        {
            using var istemci = await _dinleyici.AcceptTcpClientAsync();
            using var akis = istemci.GetStream();

            var tampon = new byte[8192];
            var biriken = new List<byte>();
            while (true)
            {
                var okunan = await akis.ReadAsync(tampon);
                if (okunan == 0) return;
                biriken.AddRange(tampon.AsSpan(0, okunan).ToArray());

                var son = -1;
                for (var i = 0; i < biriken.Count - 1; i++)
                    if (biriken[i] == Bit1 && biriken[i + 1] == Bit2) { son = i; break; }
                if (son < 0) continue;

                var bas = biriken.IndexOf(Bas);
                AlinanMesaj = _kodlama.GetString(
                    biriken.Skip(bas + 1).Take(son - bas - 1).ToArray());
                break;
            }

            if (!_ackGonder) return;

            var kontrol = AlinanMesaj.Split('\r')[0].Split('|') is { Length: > 9 } p
                        ? p[9] : "";
            var ack = $"MSH|^~\\&|TELETIP|TELETIP|GENOTIP|MERKEZ|20260918143000||ACK|1|P|2.3.1\r"
                    + $"MSA|{_ackKodu}|{kontrol}|{(_ackKodu == "AA" ? "" : "Hata açıklaması")}\r";
            var veri = _kodlama.GetBytes(ack);
            var cerceve = new byte[veri.Length + 3];
            cerceve[0] = Bas;
            veri.CopyTo(cerceve, 1);
            cerceve[^2] = Bit1;
            cerceve[^1] = Bit2;
            await akis.WriteAsync(cerceve);
            await akis.FlushAsync();
        }

        public void Dispose() => _dinleyici.Stop();
    }

    private static MllpIstemci Istemci() => new(NullLogger<MllpIstemci>.Instance);

    private static string OrnekMesaj() => OruUretici.Uret(new OruVerisi
    {
        Profil = Hl7Profili.Bakanlik,
        KontrolNo = "T7D1",
        HastaSoyad = "ÇELİK", HastaAd = "ŞÜKRÜ", HastaTckn = "12345678901",
        AccessionNo = "ACC-9",
        RaporBulgular = "Akciğer parankimi olağan.",
        RaporSonuc = "Patoloji yok.",
    });

    [Fact]
    public async Task Gonderilen_mesaj_aynen_ulasir()
    {
        using var alici = new SahteAlici();
        var mesaj = OrnekMesaj();

        var sonuc = await Istemci().GonderAsync($"127.0.0.1:{alici.Port}", mesaj, "UTF8",
                                                tls: false, 10, CancellationToken.None);
        await alici.Dongu;

        // ÇERÇEVE AYIKLANIR, GÖVDE DEĞİŞMEZ: tek bayt fark, karşı tarafta
        //   çözümleme hatası demek.
        Assert.Equal(mesaj, alici.AlinanMesaj);
        Assert.True(sonuc.Basarili);
        Assert.Equal("AA", sonuc.AckKodu);
    }

    [Fact]
    public async Task Turkce_windows1254_ile_bozulmaz()
    {
        // Yanlış kodlama Türkçe karakterleri bozuyor - kılavuzun "sık yapılan
        //   hatalar" listesindeki ilk madde.
        var kodlama = Encoding.GetEncoding(1254);
        using var alici = new SahteAlici(kodlama: kodlama);
        var mesaj = OrnekMesaj();

        await Istemci().GonderAsync($"127.0.0.1:{alici.Port}", mesaj, "Windows1254",
                                    tls: false, 10, CancellationToken.None);
        await alici.Dongu;

        Assert.Contains("ÇELİK^ŞÜKRÜ", alici.AlinanMesaj, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Ae_kalici_hata_sayilir()
    {
        using var alici = new SahteAlici("AE");
        var sonuc = await Istemci().GonderAsync($"127.0.0.1:{alici.Port}", OrnekMesaj(),
                                                "UTF8", false, 10, CancellationToken.None);
        await alici.Dongu;

        // AE: mesaj ulaştı ama kabul edilmedi. Aynı mesajı tekrar göndermek
        //   yine reddedilir - kuyruk sonsuza kadar dönmesin.
        Assert.False(sonuc.Basarili);
        Assert.True(sonuc.KaliciHata);
        Assert.Equal("AE", sonuc.AckKodu);
        Assert.Equal("Hata açıklaması", sonuc.Hata);
    }

    [Fact]
    public async Task Ar_gecici_rettir_tekrar_denenir()
    {
        using var alici = new SahteAlici("AR");
        var sonuc = await Istemci().GonderAsync($"127.0.0.1:{alici.Port}", OrnekMesaj(),
                                                "UTF8", false, 10, CancellationToken.None);
        await alici.Dongu;

        Assert.False(sonuc.Basarili);
        Assert.False(sonuc.KaliciHata);          // kuyrukta kalır
        Assert.Equal("AR", sonuc.AckKodu);
    }

    [Fact]
    public async Task Ack_gelmezse_basarisiz()
    {
        using var alici = new SahteAlici(ackGonder: false);
        var sonuc = await Istemci().GonderAsync($"127.0.0.1:{alici.Port}", OrnekMesaj(),
                                                "UTF8", false, 10, CancellationToken.None);
        await alici.Dongu;

        // TCP yazmanın başarılı dönmesi mesajın KABUL edildiğini söylemez.
        Assert.False(sonuc.Basarili);
        Assert.Equal("", sonuc.AckKodu);
        Assert.Contains("ACK", sonuc.Hata, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Kapali_port_hata_doner_patlamaz()
    {
        // Karşı uç kapalıyken kuyruk çalışmaya devam etmeli: istisna fırlatmak
        //   işçiyi durdururdu.
        var sonuc = await Istemci().GonderAsync("127.0.0.1:1", OrnekMesaj(), "UTF8",
                                                false, 5, CancellationToken.None);
        Assert.False(sonuc.Basarili);
        Assert.Equal("", sonuc.AckKodu);
        Assert.NotEqual("", sonuc.Hata);
    }

    [Theory]
    [InlineData("10.0.0.5:2575", "10.0.0.5", 2575)]
    [InlineData("mllp://hbys.local:6661/", "hbys.local", 6661)]
    [InlineData("hbys.local", "", 0)]
    [InlineData("", "", 0)]
    public void Adres_cozumu(string adres, string sunucu, int port)
    {
        var (s, p) = MllpIstemci.AdresCoz(adres);
        Assert.Equal(sunucu, s);
        Assert.Equal(port, p);
    }

    [Fact]
    public void Msa_olmayan_yanit_yorumlanmaz()
    {
        var (kod, metin) = MllpIstemci.AckCoz("MSH|^~\\&|X|Y|Z|W|1||ACK|1|P|2.5\r");
        Assert.Equal("", kod);
        Assert.Contains("MSA", metin, StringComparison.Ordinal);
    }
}

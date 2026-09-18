using System.Diagnostics;
using System.Net.Security;
using System.Net.Sockets;
using System.Text;

namespace Gentegre.Api.Servisler;

/// <summary>ACK yorumu: kod + açıklama + mesajın ham hâli.</summary>
public sealed record MllpSonucu(
    /// <summary>AA kabul · AE uygulama hatası · AR geçici ret · "" ulaşmadı.</summary>
    string AckKodu,
    string Hata,
    string YanitGovdesi,
    int SureMs)
{
    public bool Basarili => AckKodu == "AA" || AckKodu == "CA";
    /// <summary>AE = aynı mesaj yine reddedilir; tekrar denemek boşa gider.</summary>
    public bool KaliciHata => AckKodu is "AE" or "CE";
}

/// <summary>
/// MLLP İSTEMCİSİ (814) — ürettiğimiz ORU'yu karşı uca gönderir, ACK okur.
///
/// <para><b>Dinleyicinin aynası.</b> Çerçeve <c>0x0B … 0x1C 0x0D</c>; aynı
/// kural (432) gönderme yönünde de geçerli. "Bağlantıyı kapatınca mesaj
/// biter" varsaymak, ACK'i hiç okuyamamak demek.</para>
///
/// <para><b>ACK OKUNMADAN GÖNDERİM BAŞARILI SAYILMAZ.</b> TCP'nin yazma
/// işlemi başarılı dönmesi, mesajın kabul edildiğini değil yalnız ağa
/// verildiğini söyler; karşı taraf onu reddetmiş olabilir.</para>
///
/// <para><b>Encoding kurumdan gelir.</b> Bakanlık tarafında UTF8 dışında
/// Windows1254 kullanılacaksa önceden bildiriliyor ve mesaj o kodlamayla
/// gönderilmek zorunda - yanlış kodlama Türkçe karakterleri bozar.</para>
/// </summary>
public sealed class MllpIstemci(ILogger<MllpIstemci> gunluk)
{
    private const byte Bas = 0x0B, Bit1 = 0x1C, Bit2 = 0x0D;

    static MllpIstemci()
    {
        // Windows1254 .NET'te varsayılan olarak YOK: sağlayıcı kaydedilmezse
        //   Encoding.GetEncoding(1254) çalışma anında patlar.
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
    }

    public static Encoding Kodlama(string ad)
        => ad.Equals("Windows1254", StringComparison.OrdinalIgnoreCase)
           || ad == "1254"
         ? Encoding.GetEncoding(1254)
         : Encoding.UTF8;

    public async Task<MllpSonucu> GonderAsync(string adres, string mesaj, string encodingAdi,
                                              bool tls, int zamanAsimiSn,
                                              CancellationToken iptal)
    {
        var kronometre = Stopwatch.StartNew();
        var (sunucu, port) = AdresCoz(adres);
        if (sunucu.Length == 0 || port <= 0)
            return new MllpSonucu("", $"Teslim adresi geçersiz: '{adres}' (host:port bekleniyor).",
                                  "", 0);

        try
        {
            using var istemci = new TcpClient();
            using var zamanAsimi = CancellationTokenSource.CreateLinkedTokenSource(iptal);
            zamanAsimi.CancelAfter(TimeSpan.FromSeconds(zamanAsimiSn <= 0 ? 30 : zamanAsimiSn));

            await istemci.ConnectAsync(sunucu, port, zamanAsimi.Token);

            Stream akis = istemci.GetStream();
            if (tls)
            {
                // KVKK: rapor metni hasta verisidir. Düz TCP yalnız kapalı
                //   kurum ağında kabul edilebilir; dışarı çıkıyorsa TLS.
                var guvenli = new SslStream(akis, leaveInnerStreamOpen: false);
                await guvenli.AuthenticateAsClientAsync(sunucu);
                akis = guvenli;
            }

            var kodlama = Kodlama(encodingAdi);
            var govde = kodlama.GetBytes(mesaj);
            var cerceve = new byte[govde.Length + 3];
            cerceve[0] = Bas;
            govde.CopyTo(cerceve, 1);
            cerceve[^2] = Bit1;
            cerceve[^1] = Bit2;

            await akis.WriteAsync(cerceve, zamanAsimi.Token);
            await akis.FlushAsync(zamanAsimi.Token);

            var yanit = await CerceveOkuAsync(akis, kodlama, zamanAsimi.Token);
            kronometre.Stop();

            if (yanit.Length == 0)
                return new MllpSonucu("", "Karşı uç ACK göndermeden bağlantıyı kapattı.",
                                      "", (int)kronometre.ElapsedMilliseconds);

            var (kod, metin) = AckCoz(yanit);
            return new MllpSonucu(kod, metin, yanit, (int)kronometre.ElapsedMilliseconds);
        }
        catch (OperationCanceledException) when (!iptal.IsCancellationRequested)
        {
            kronometre.Stop();
            return new MllpSonucu("", $"Zaman aşımı ({zamanAsimiSn} sn): {sunucu}:{port}",
                                  "", (int)kronometre.ElapsedMilliseconds);
        }
        catch (Exception h)
        {
            kronometre.Stop();
            gunluk.LogWarning(h, "MLLP gönderimi başarısız: {Adres}", adres);
            return new MllpSonucu("", h.Message, "", (int)kronometre.ElapsedMilliseconds);
        }
    }

    /// <summary>"10.0.0.5:2575" → (10.0.0.5, 2575). Şema varsa atılır.</summary>
    public static (string Sunucu, int Port) AdresCoz(string adres)
    {
        var temiz = (adres ?? "").Trim();
        var sema = temiz.IndexOf("://", StringComparison.Ordinal);
        if (sema >= 0) temiz = temiz[(sema + 3)..];
        temiz = temiz.TrimEnd('/');

        var i = temiz.LastIndexOf(':');
        if (i <= 0 || i == temiz.Length - 1) return ("", 0);
        return int.TryParse(temiz[(i + 1)..], out var port) ? (temiz[..i], port) : ("", 0);
    }

    private static async Task<string> CerceveOkuAsync(Stream akis, Encoding kodlama,
                                                      CancellationToken iptal)
    {
        var tampon = new byte[4096];
        var biriken = new List<byte>(4096);
        while (true)
        {
            var okunan = await akis.ReadAsync(tampon, iptal);
            if (okunan == 0) break;
            biriken.AddRange(tampon.AsSpan(0, okunan).ToArray());

            for (var i = 0; i < biriken.Count - 1; i++)
                if (biriken[i] == Bit1 && biriken[i + 1] == Bit2)
                {
                    var bas = biriken.IndexOf(Bas);
                    var basla = bas >= 0 ? bas + 1 : 0;
                    return kodlama.GetString(biriken.Skip(basla).Take(i - basla).ToArray());
                }
        }
        // ÇERÇEVESİZ YANIT DA OKUNUR: bazı sistemler ACK'i çerçevelemeden
        //   gönderip bağlantıyı kapatıyor. Atmak yerine yorumlamak yeğdir.
        return biriken.Count > 0 ? kodlama.GetString(biriken.ToArray()).Trim('\v', '', '\r') : "";
    }

    /// <summary>MSA-1 kodu ve (varsa) MSA-3 / ERR açıklaması.</summary>
    public static (string Kod, string Metin) AckCoz(string yanit)
    {
        var satirlar = yanit.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries);
        var msa = satirlar.FirstOrDefault(x => x.StartsWith("MSA", StringComparison.Ordinal));
        if (msa is null)
            return ("", "Yanıtta MSA segmenti yok - ACK olarak yorumlanamadı.");

        var p = msa.Split('|');
        var kod = p.Length > 1 ? p[1].Trim().ToUpperInvariant() : "";
        var metin = p.Length > 3 ? p[3].Trim() : "";

        if (metin.Length == 0)
        {
            var err = satirlar.FirstOrDefault(x => x.StartsWith("ERR", StringComparison.Ordinal));
            if (err is not null) metin = err;
        }
        return (kod, metin);
    }
}

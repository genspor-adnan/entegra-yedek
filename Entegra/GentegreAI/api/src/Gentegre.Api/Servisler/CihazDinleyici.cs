using System.Net;
using System.Net.Sockets;
using System.Text;

namespace Gentegre.Api.Servisler;

/// <summary>
/// MLLP DİNLEYİCİSİ (432) — HL7 v2 cihazları TCP'den bağlanır, mesajı
/// gönderir, ACK bekler.
///
/// <para><b>MLLP çerçevesi:</b> mesaj <c>0x0B</c> ile başlar, <c>0x1C 0x0D</c>
/// ile biter. Çerçeveye bakmadan "bağlantı kapanınca mesaj bitti" varsaymak,
/// aynı bağlantıdan arka arkaya mesaj gönderen cihazlarda (çoğu analizör
/// böyle) mesajları birbirine karıştırır.</para>
///
/// <para><b>ACK ŞART.</b> Cihaz ACK almazsa sonucu kendi kuyruğunda tutar ve
/// tekrar tekrar gönderir; bazıları belli sayıda denemeden sonra sonucu SİLER.
/// Bu yüzden ACK, mesaj kaydedildikten SONRA ve kayıt başarısızsa NAK olarak
/// gönderilir - cihaz o zaman tekrar dener.</para>
///
/// <para>Dinleyici, <c>baglanti_turu = 1</c> ve <c>otomatik = 1</c> olan
/// cihazlar için açılır. Kapalı cihazın portu hiç dinlenmez.</para>
/// </summary>
public sealed class CihazDinleyici(IServiceScopeFactory kapsam,
                                   ILogger<CihazDinleyici> gunluk) : BackgroundService
{
    private const byte Bas = 0x0B, Bit1 = 0x1C, Bit2 = 0x0D;

    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        // Açılışta bir kez okunur: cihaz eklendiğinde uygulama yeniden
        //   başlatılır (port açmak zaten yeniden başlatma gerektiren bir
        //   yapılandırma işi).
        List<CihazServisi.Cihaz> cihazlar;
        try
        {
            using var k = kapsam.CreateScope();
            var servis = k.ServiceProvider.GetRequiredService<CihazServisi>();
            cihazlar = await servis.CihazlarAsync(1, true, dur);
        }
        catch (Exception h)
        {
            gunluk.LogError(h, "Cihaz dinleyici: cihaz listesi okunamadı.");
            return;
        }

        var acilanlar = cihazlar.Where(c => c.Port > 0).ToList();
        if (acilanlar.Count == 0)
        {
            gunluk.LogInformation(
                "Cihaz dinleyici: otomatik başlayan MLLP cihazı yok - port açılmadı.");
            return;
        }

        await Task.WhenAll(acilanlar.Select(c => CihazDinleAsync(c, dur)));
    }

    private async Task CihazDinleAsync(CihazServisi.Cihaz cihaz, CancellationToken dur)
    {
        TcpListener? dinleyici = null;
        try
        {
            var adres = cihaz.Adres.Length > 0 && IPAddress.TryParse(cihaz.Adres, out var a)
                      ? a : IPAddress.Any;
            dinleyici = new TcpListener(adres, cihaz.Port);
            dinleyici.Start();
            gunluk.LogInformation("Cihaz {Kod}: MLLP dinleniyor {Adres}:{Port}",
                                  cihaz.Kod, adres, cihaz.Port);

            while (!dur.IsCancellationRequested)
            {
                var istemci = await dinleyici.AcceptTcpClientAsync(dur);
                _ = BaglantiIsleAsync(cihaz, istemci, dur);
            }
        }
        catch (OperationCanceledException) { /* kapaniyor */ }
        catch (Exception h)
        {
            gunluk.LogError(h, "Cihaz {Kod}: dinleyici {Port} açılamadı.",
                            cihaz.Kod, cihaz.Port);
        }
        finally { dinleyici?.Stop(); }
    }

    private async Task BaglantiIsleAsync(CihazServisi.Cihaz cihaz, TcpClient istemci,
                                         CancellationToken dur)
    {
        using (istemci)
        {
            try
            {
                var uzak = istemci.Client.RemoteEndPoint?.ToString() ?? "";
                using var akis = istemci.GetStream();
                var tampon = new byte[8192];
                var biriken = new List<byte>(16384);

                while (!dur.IsCancellationRequested)
                {
                    var okunan = await akis.ReadAsync(tampon, dur);
                    if (okunan == 0) break;
                    biriken.AddRange(tampon.AsSpan(0, okunan).ToArray());

                    // Tamamlanan her çerçeve ayrı mesajdır: cihaz aynı
                    //   bağlantıdan arka arkaya gönderebilir.
                    int son;
                    while ((son = CerceveSonu(biriken)) > 0)
                    {
                        var bas = biriken.IndexOf(Bas);
                        var govde = biriken.Skip(bas + 1).Take(son - bas - 1).ToArray();
                        biriken.RemoveRange(0, son + 2 > biriken.Count ? biriken.Count
                                                                       : son + 2);

                        var ham = Encoding.UTF8.GetString(govde);
                        var ack = await AlVeAckAsync(cihaz, ham, uzak, dur);
                        await akis.WriteAsync(ack, dur);
                        await akis.FlushAsync(dur);
                    }
                }
            }
            catch (Exception h)
            {
                gunluk.LogError(h, "Cihaz {Kod}: bağlantı hatası.", cihaz.Kod);
            }
        }
    }

    /// <summary>0x1C 0x0D ikilisinin konumu; yoksa -1.</summary>
    private static int CerceveSonu(List<byte> veri)
    {
        for (var i = 0; i < veri.Count - 1; i++)
            if (veri[i] == Bit1 && veri[i + 1] == Bit2) return i;
        return -1;
    }

    /// <summary>
    /// Mesajı kaydeder ve ACK/NAK üretir. KAYIT BAŞARISIZSA NAK: cihaz
    /// tekrar denesin, sonuç kaybolmasın.
    /// </summary>
    private async Task<byte[]> AlVeAckAsync(CihazServisi.Cihaz cihaz, string ham,
                                            string uzak, CancellationToken dur)
    {
        string kontrolNo = "", kod = "AA";
        try
        {
            using var k = kapsam.CreateScope();
            var servis = k.ServiceProvider.GetRequiredService<CihazServisi>();
            var sonuc = await servis.AlAsync(cihaz, ham, uzak, dur);
            kontrolNo = MshKontrolNo(ham);
            // Çözümlenemeyen mesaj da KAYDEDİLDİ: cihaza AA (kabul) denir,
            //   sorun bizim tarafta - tekrar göndermesi bir şey değiştirmez.
            kod = sonuc.MesajId > 0 || sonuc.Durum == "mukerrer" ? "AA" : "AE";
        }
        catch (Exception h)
        {
            gunluk.LogError(h, "Cihaz {Kod}: mesaj kaydedilemedi.", cihaz.Kod);
            kod = "AE";
        }
        return Ack(kontrolNo, kod);
    }

    private static string MshKontrolNo(string ham)
    {
        var satir = ham.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries)
                       .FirstOrDefault(x => x.StartsWith("MSH", StringComparison.Ordinal));
        if (satir is null || satir.Length < 4) return "";
        var p = satir.Split(satir[3]);
        return p.Length > 9 ? p[9] : "";
    }

    private static byte[] Ack(string kontrolNo, string kod)
    {
        var zaman = DateTime.Now.ToString("yyyyMMddHHmmss");
        var govde = $"MSH|^~\\&|GENTEGRE|AI|CIHAZ|LAB|{zaman}||ACK|{zaman}|P|2.5\r"
                  + $"MSA|{kod}|{kontrolNo}\r";
        var veri = Encoding.UTF8.GetBytes(govde);
        var cerceve = new byte[veri.Length + 3];
        cerceve[0] = Bas;
        veri.CopyTo(cerceve, 1);
        cerceve[^2] = Bit1;
        cerceve[^1] = Bit2;
        return cerceve;
    }
}

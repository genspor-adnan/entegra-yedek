using System.Net;
using System.Net.Sockets;
using System.Text;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GELEN ORU DİNLEYİCİSİ (817) — karşı sistem raporu bize MLLP ile gönderir.
///
/// <para><b>Cihaz dinleyicisinden AYRI</b> (432): oradaki port bir cihaz
/// kartına bağlı ve mesaj lab sonucu olarak yorumlanıyor. Teleradyoloji
/// raporu cihaz değildir; kurulum için sahte bir "analizör" kartı açmak,
/// ekranlarda cihaz gibi görünen bir şey bırakırdı. Port ayardan gelir.</para>
///
/// <para><b>Port 0 = kapalı.</b> Rapor almayan kurulumda dinlenen bir kapı
/// bırakmak, kapatılması unutulan bir risktir.</para>
///
/// <para><b>IP beyaz listesi</b> (kılavuz 3.46 § 3.1.4.1): alıcı yalnız
/// Teleradyoloji'nin SBA içi IP'sinden veri kabul etmeli. Liste boşsa
/// dinleyici açılır ama her açılışta uyarı düşer - sessizce herkese açık
/// kalmasın.</para>
///
/// <para><b>ACK kayıttan SONRA</b>: mesaj saklanmadan AA demek, karşı tarafın
/// raporu "teslim edildi" sayıp bir daha göndermemesi demektir.</para>
/// </summary>
public sealed class TeleradOruDinleyici(IServiceScopeFactory kapsam, VeriKaynagi veri,
                                        ILogger<TeleradOruDinleyici> gunluk) : BackgroundService
{
    private const byte Bas = 0x0B, Bit1 = 0x1C, Bit2 = 0x0D;

    private string[] _izinliIp = [];
    private Encoding _kodlama = Encoding.UTF8;

    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        int port;
        try
        {
            await using var b = await veri.AcAsync(dur);
            port = int.TryParse(
                await AyarDeposu.MetinAsync(b, null, "telerad.oru_port", "0", dur),
                out var p) ? p : 0;
            var izinli = await AyarDeposu.MetinAsync(b, null, "telerad.oru_izinli_ip", "", dur);
            _izinliIp = izinli.Split(',', StringSplitOptions.RemoveEmptyEntries
                                        | StringSplitOptions.TrimEntries);
            var kodlamaAdi = await AyarDeposu.MetinAsync(b, null, "telerad.oru_encoding",
                                                         "UTF8", dur);
            _kodlama = MllpIstemci.Kodlama(kodlamaAdi);
        }
        catch (Exception h)
        {
            gunluk.LogError(h, "Gelen ORU dinleyicisi: ayarlar okunamadı.");
            return;
        }

        if (port <= 0)
        {
            gunluk.LogInformation(
                "Gelen ORU dinleyicisi kapalı (telerad.oru_port = 0).");
            return;
        }
        if (_izinliIp.Length == 0)
            gunluk.LogWarning("Gelen ORU dinleyicisi {Port} portunda AÇIK ve IP kısıtı YOK - "
                            + "telerad.oru_izinli_ip doldurulmalı.", port);

        TcpListener? dinleyici = null;
        try
        {
            dinleyici = new TcpListener(IPAddress.Any, port);
            dinleyici.Start();
            gunluk.LogInformation("Gelen ORU dinleniyor: {Port}", port);

            while (!dur.IsCancellationRequested)
            {
                var istemci = await dinleyici.AcceptTcpClientAsync(dur);
                _ = BaglantiIsleAsync(istemci, dur);
            }
        }
        catch (OperationCanceledException) { /* kapaniyor */ }
        catch (Exception h)
        {
            gunluk.LogError(h, "Gelen ORU dinleyicisi {Port} açılamadı.", port);
        }
        finally { dinleyici?.Stop(); }
    }

    private async Task BaglantiIsleAsync(TcpClient istemci, CancellationToken dur)
    {
        using (istemci)
        {
            var uzak = (istemci.Client.RemoteEndPoint as IPEndPoint)?.Address.ToString() ?? "";
            if (_izinliIp.Length > 0 && !_izinliIp.Contains(uzak))
            {
                // TANIMSIZ IP SESSİZCE KAPATILIR: Bakanlığın kendi kuralı da bu.
                gunluk.LogWarning("Gelen ORU: izinli olmayan adres {Ip} - bağlantı kapatıldı.",
                                  uzak);
                return;
            }

            try
            {
                using var akis = istemci.GetStream();
                var tampon = new byte[16384];
                var biriken = new List<byte>(32768);

                while (!dur.IsCancellationRequested)
                {
                    var okunan = await akis.ReadAsync(tampon, dur);
                    if (okunan == 0) break;
                    biriken.AddRange(tampon.AsSpan(0, okunan).ToArray());

                    // AYNI BAĞLANTIDAN ARKA ARKAYA MESAJ gelebilir: her
                    //   tamamlanan çerçeve ayrı rapordur.
                    int son;
                    while ((son = CerceveSonu(biriken)) > 0)
                    {
                        var bas = biriken.IndexOf(Bas);
                        var govde = biriken.Skip(bas + 1).Take(son - bas - 1).ToArray();
                        biriken.RemoveRange(0, Math.Min(son + 2, biriken.Count));

                        var ham = _kodlama.GetString(govde);
                        var ack = await AlVeAckAsync(ham, uzak, dur);
                        await akis.WriteAsync(ack, dur);
                        await akis.FlushAsync(dur);
                    }
                }
            }
            catch (Exception h)
            {
                gunluk.LogError(h, "Gelen ORU: bağlantı hatası ({Ip}).", uzak);
            }
        }
    }

    private static int CerceveSonu(List<byte> veri)
    {
        for (var i = 0; i < veri.Count - 1; i++)
            if (veri[i] == Bit1 && veri[i + 1] == Bit2) return i;
        return -1;
    }

    private async Task<byte[]> AlVeAckAsync(string ham, string ip, CancellationToken dur)
    {
        var kontrolNo = MshKontrolNo(ham);
        try
        {
            using var k = kapsam.CreateScope();
            var servis = k.ServiceProvider.GetRequiredService<TeleradGelenServisi>();
            var sonuc = await servis.AlAsync(ham, ip, dur);
            return Ack(kontrolNo, sonuc.AckKodu, sonuc.Mesaj);
        }
        catch (Exception h)
        {
            // KAYIT EDİLEMEDİYSE AR: sorun bizde, karşı taraf tekrar denesin.
            gunluk.LogError(h, "Gelen ORU kaydedilemedi ({Ip}).", ip);
            return Ack(kontrolNo, "AR", "Rapor kaydedilemedi, tekrar deneyin.");
        }
    }

    internal static string MshKontrolNo(string ham)
    {
        var satir = ham.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries)
                       .FirstOrDefault(x => x.StartsWith("MSH", StringComparison.Ordinal));
        if (satir is null || satir.Length < 4) return "";
        var p = satir.Split(satir[3]);
        return p.Length > 9 ? p[9] : "";
    }

    /// <summary>ACK^R01 — MSA-1 kodu, MSA-3 açıklama.</summary>
    internal byte[] Ack(string kontrolNo, string kod, string aciklama)
    {
        var zaman = DateTime.Now.ToString("yyyyMMddHHmmss");
        var govde = $"MSH|^~\\&|GENTEGRE|AI|TELERAD|DIS|{zaman}||ACK|{zaman}|P|2.3.1\r"
                  + $"MSA|{kod}|{kontrolNo}|{aciklama.Replace('|', ' ')}\r";
        var veri = _kodlama.GetBytes(govde);
        var cerceve = new byte[veri.Length + 3];
        cerceve[0] = Bas;
        veri.CopyTo(cerceve, 1);
        cerceve[^2] = Bit1;
        cerceve[^1] = Bit2;
        return cerceve;
    }
}

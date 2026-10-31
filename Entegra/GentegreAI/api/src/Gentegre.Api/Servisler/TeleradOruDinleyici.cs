using Gentegre.Cekirdek;
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
    // MLLP SINIRLARI (kod inceleme 30.10.2026 K38): çerçevesiz akıtılan veri belleği doldurup API'yi düşürmesin;
    //   boşta bağlantı sonsuza dek tutulmasın; aynı anda kabul edilen bağlantı sayısı sınırlı.
    private const int AzamiCerceve = 4 * 1024 * 1024;
    private static readonly TimeSpan BostaZamanAsimi = TimeSpan.FromSeconds(60);
    private static readonly SemaphoreSlim BaglantiKotasi = new(64, 64);

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
                if (!await BaglantiKotasi.WaitAsync(0, dur))
                {
                    gunluk.LogWarning("MLLP: bağlantı kotası dolu, yeni bağlantı reddedildi ({Uzak}).",
                                      istemci.Client.RemoteEndPoint);
                    istemci.Dispose();
                    continue;
                }
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
        try
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

                var aramaBasi = 0;
                while (!dur.IsCancellationRequested)
                {
                    int okunan;
                    using (var zamanAsimi = CancellationTokenSource.CreateLinkedTokenSource(dur))
                    {
                        zamanAsimi.CancelAfter(BostaZamanAsimi);
                        try { okunan = await akis.ReadAsync(tampon, zamanAsimi.Token); }
                        catch (OperationCanceledException) when (!dur.IsCancellationRequested)
                        {
                            gunluk.LogWarning("MLLP: boşta bağlantı kapatıldı ({Uzak}).", uzak);
                            break;
                        }
                    }
                    if (okunan == 0) break;
                    biriken.AddRange(tampon.AsSpan(0, okunan).ToArray());
                    if (biriken.Count > AzamiCerceve)
                    {
                        gunluk.LogWarning("MLLP: çerçeve sınırı aşıldı ({Boyut} bayt), bağlantı kapatıldı ({Uzak}).",
                                          biriken.Count, uzak);
                        break;
                    }

                    // AYNI BAĞLANTIDAN ARKA ARKAYA MESAJ gelebilir: her
                    //   tamamlanan çerçeve ayrı rapordur.
                    int son;
                    while ((son = CerceveSonu(biriken, aramaBasi)) > 0)
                    {
                        var bas = biriken.IndexOf(Bas);
                        var govde = biriken.Skip(bas + 1).Take(son - bas - 1).ToArray();
                        biriken.RemoveRange(0, Math.Min(son + 2, biriken.Count));

                        var ham = _kodlama.GetString(govde);
                        var ack = await AlVeAckAsync(ham, uzak, dur);
                        await akis.WriteAsync(ack, dur);
                        await akis.FlushAsync(dur);
                        aramaBasi = 0;
                    }
                    // Çerçeve sonu henüz yok: bir sonraki okumada taramaya son bayttan devam (O(n²) olmasın).
                    aramaBasi = Math.Max(0, biriken.Count - 1);
                }
            }
            catch (Exception h)
            {
                gunluk.LogError(h, "Gelen ORU: bağlantı hatası ({Ip}).", uzak);
            }
        }
        finally { BaglantiKotasi.Release(); }
    }

    private static int CerceveSonu(List<byte> veri, int bas = 0)
    {
        for (var i = Math.Max(0, bas); i < veri.Count - 1; i++)
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
        var zaman = Saat.Simdi.ToString("yyyyMMddHHmmss");
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

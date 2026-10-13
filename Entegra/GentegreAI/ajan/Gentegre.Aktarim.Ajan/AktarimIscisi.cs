namespace Gentegre.Aktarim.Ajan;

/// <summary>
/// Yoklama döngüsü: her <c>YoklamaSn</c>'de Delphi'nin CT versiyonuna bakar; değişmediyse
/// sunucuya gitmez (yalnız <c>NabizSn</c>'de bir durum sorar - sunucu ajanı canlı görür).
/// Hata (ağ, sunucu reddi, paketteki adım hatası) üstel bekler: 30 sn -> 10 dk.
/// </summary>
public sealed class AktarimIscisi(Ayarlar ayar, ILogger<AktarimIscisi> gunluk) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        var delphi = new DelphiOkuyucu(ayar.GercekBaglanti);
        using var api = new ApiIstemci(ayar, gunluk);
        var aktarici = new Aktarici(delphi, api, ayar, gunluk);
        gunluk.LogInformation("Aktarım ajanı başladı: {Api}", ayar.ApiAdres);

        long sonVersiyon = -1;
        var sonNabiz = DateTime.MinValue;
        var bekle = TimeSpan.FromSeconds(30);
        while (!iptal.IsCancellationRequested)
        {
            var gecikme = TimeSpan.FromSeconds(ayar.YoklamaSn);
            try
            {
                var guncel = await delphi.GuncelVersiyonAsync(iptal);
                if (guncel != sonVersiyon || DateTime.UtcNow - sonNabiz > TimeSpan.FromSeconds(ayar.NabizSn))
                {
                    var s = await aktarici.TurAsync(iptal);
                    sonNabiz = DateTime.UtcNow;
                    if (s.Hata is null)
                    {
                        sonVersiyon = s.Versiyon;
                        bekle = TimeSpan.FromSeconds(30);
                        if (!s.DegisiklikYok)
                            gunluk.LogInformation("Tur: versiyon {V}, {P} paket, {K} kök, {S} silme", s.Versiyon, s.Paket, s.Kok, s.Silinen);
                    }
                    else
                    {
                        gunluk.LogError("Tur yarım kaldı ({Hata}); {Sn} sn sonra yeniden", s.Hata, bekle.TotalSeconds);
                        gecikme = bekle;
                        bekle = TimeSpan.FromSeconds(Math.Min(bekle.TotalSeconds * 2, 600));
                    }
                }
            }
            catch (OperationCanceledException) when (iptal.IsCancellationRequested) { break; }
            catch (Exception e)
            {
                gunluk.LogError(e, "Tur başarısız; {Sn} sn sonra yeniden", bekle.TotalSeconds);
                gecikme = bekle;
                bekle = TimeSpan.FromSeconds(Math.Min(bekle.TotalSeconds * 2, 600));
            }
            try { await Task.Delay(gecikme, iptal); } catch (OperationCanceledException) { break; }
        }
    }
}

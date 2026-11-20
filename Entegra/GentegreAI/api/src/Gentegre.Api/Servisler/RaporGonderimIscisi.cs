namespace Gentegre.Api.Servisler;

/// <summary>
/// RAPOR GÖNDERİM İŞÇİSİ (1389): dakikada bir, zamanı gelen radyoloji raporu gönderimlerini işler
/// (<see cref="RaporGonderimi.SiradakileriIsleAsync"/>). Zamanlama VERİTABANINDA (planlanan) - uygulama yeniden
/// başlasa da kuyruk kaybolmaz. "Borç bekleyen" satırlar her turda yeniden bakılır: borç kapanınca kendiliğinden gider.
/// </summary>
public sealed class RaporGonderimIscisi(IServiceScopeFactory kapsam, ILogger<RaporGonderimIscisi> gunluk) : BackgroundService
{
    private static readonly TimeSpan Aralik = TimeSpan.FromSeconds(60);

    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        try { await Task.Delay(TimeSpan.FromSeconds(25), dur); }
        catch (OperationCanceledException) { return; }

        while (!dur.IsCancellationRequested)
        {
            try
            {
                using var k = kapsam.CreateScope();
                var gonderilen = await k.ServiceProvider.GetRequiredService<RaporGonderimi>().SiradakileriIsleAsync(50, dur);
                if (gonderilen > 0) gunluk.LogInformation("Rapor gönderimi: {Sayi} bildirim kuyruğa yazıldı.", gonderilen);
            }
            catch (OperationCanceledException) { break; }
            catch (Exception h) { gunluk.LogError(h, "Rapor gönderim turu başarısız."); }

            try { await Task.Delay(Aralik, dur); }
            catch (OperationCanceledException) { break; }
        }
    }
}

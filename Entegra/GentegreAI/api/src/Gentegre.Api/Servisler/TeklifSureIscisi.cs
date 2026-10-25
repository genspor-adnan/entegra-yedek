using Gentegre.Api.Uclar;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// TEKLİF SÜRE İŞÇİSİ (1186, karar 25.10.2026 "süresi geçen teklif kendiliğinden kayba çevrilsin"): saatte bir
/// <see cref="TeklifIcmalUclari.SuresiDolanlariKapatAsync"/> - geçerliliği (belge_tarihi + vade_gun) şubenin gününe
/// göre geçmiş, hiç satırı dönmemiş açık teklifi "kaybedildi · süre doldu" yapar (kullanıcı 0, loglu). Saatlik tur:
/// gün dönümü şube saat dilimine göre ayrı anlarda olur; zaten kapanmış teklif ikinci kez seçilmez.
/// Genel Ayarlar `teklif.otomatik_kayip` 0 ise iş yapmaz.
/// </summary>
public sealed class TeklifSureIscisi(IServiceProvider servisler, ILogger<TeklifSureIscisi> gunluk) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        await Task.Delay(TimeSpan.FromMinutes(3), iptal).ContinueWith(_ => { }, CancellationToken.None);
        while (!iptal.IsCancellationRequested)
        {
            try
            {
                await using var kapsam = servisler.CreateAsyncScope();
                var n = await TeklifIcmalUclari.SuresiDolanlariKapatAsync(
                    kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>(),
                    kapsam.ServiceProvider.GetRequiredService<LogDeposu>(), iptal);
                if (n > 0) gunluk.LogInformation("Teklif süresi: {Sayi} teklif kaybedildi (süre doldu).", n);
            }
            catch (OperationCanceledException) when (iptal.IsCancellationRequested) { break; }
            catch (Exception h) { gunluk.LogError(h, "Teklif süre turu hata verdi."); }
            await Task.Delay(TimeSpan.FromHours(1), iptal).ContinueWith(_ => { }, CancellationToken.None);
        }
    }
}

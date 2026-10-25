using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// PLANLI GİDER İŞÇİSİ (1177): saatte bir, bütün şubelerde POST /api/planli-gider/eslestir ile AYNI
/// mantık (dondurma + tek aday otomatik eşleşme + banka hareketi işlenen eşleşmenin taşınması) ve
/// sorumlu hatırlatmaları (<see cref="PlanliGiderMotoru.HatirlatAsync"/>). Kayıt kullanıcısı 0 (sistem).
/// Hatırlatmalar 08:00-20:00 arasında gider.
/// </summary>
public sealed class PlanliGiderIscisi(IServiceProvider servisler, ILogger<PlanliGiderIscisi> gunluk) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        await Task.Delay(TimeSpan.FromMinutes(2), iptal).ContinueWith(_ => { }, CancellationToken.None);
        while (!iptal.IsCancellationRequested)
        {
            try { await TurAsync(iptal); }
            catch (OperationCanceledException) when (iptal.IsCancellationRequested) { break; }
            catch (Exception h) { gunluk.LogError(h, "Planlı gider turu hata verdi."); }
            await Task.Delay(TimeSpan.FromHours(1), iptal).ContinueWith(_ => { }, CancellationToken.None);
        }
    }

    private async Task TurAsync(CancellationToken iptal)
    {
        await using var kapsam = servisler.CreateAsyncScope();
        var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();
        var log = kapsam.ServiceProvider.GetRequiredService<LogDeposu>();
        var (eslesen, donduruldu) = await PlanliGiderMotoru.EslestirAsync(veri, log, [], 0, null, "planli-gider-iscisi", iptal);
        var saat = Gentegre.Cekirdek.Saat.Simdi.Hour;
        var giden = 0;
        if (saat is >= 8 and < 20)
            giden = await PlanliGiderMotoru.HatirlatAsync(veri, kapsam.ServiceProvider.GetRequiredService<BildirimDeposu>(), iptal);
        if (eslesen + donduruldu + giden > 0)
            gunluk.LogInformation("Planlı gider: {Eslesen} eşleşme, {Donduruldu} dondurma, {Giden} hatırlatma.", eslesen, donduruldu, giden);
    }
}

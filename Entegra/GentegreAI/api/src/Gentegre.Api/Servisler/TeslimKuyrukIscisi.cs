namespace Gentegre.Api.Servisler;

/// <summary>
/// TESLİM KUYRUĞU İŞÇİSİ (814) — zamanı gelen teslimleri dener.
///
/// <para><b>Zamanlama veritabanında.</b> "Sıradaki deneme ne zaman" sorusunun
/// cevabı satırda (<c>sonraki_deneme</c>); işçi yalnız "zamanı gelen var mı"
/// diye sorar. Geri çekilmeyi bellekte tutsaydı uygulama her yeniden
/// başladığında bütün kuyruk aynı anda tekrar denenirdi.</para>
///
/// <para><b>Boş kuyruk ucuz:</b> kısmi indeks (<c>durum = 1</c>) sayesinde
/// sorgu birkaç satıra bakıyor - 30 saniyede bir çalışması bir maliyet
/// değil.</para>
///
/// <para>Uygulama tek örnek çalışıyor; birden çok örnek olsaydı satır
/// kilidi (<c>for update skip locked</c>) gerekirdi - o gün geldiğinde
/// eklenecek tek yer <see cref="TeleradTeslimServisi.SiradakileriIsleAsync"/>.</para>
/// </summary>
public sealed class TeslimKuyrukIscisi(IServiceScopeFactory kapsam,
                                       ILogger<TeslimKuyrukIscisi> gunluk) : BackgroundService
{
    private static readonly TimeSpan Aralik = TimeSpan.FromSeconds(30);

    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        // Açılışta bir soluk: uygulama daha veritabanına bağlanmadan kuyruğu
        //   yoklamak, her başlangıçta bir hata satırı üretirdi.
        try { await Task.Delay(TimeSpan.FromSeconds(20), dur); }
        catch (OperationCanceledException) { return; }

        while (!dur.IsCancellationRequested)
        {
            try
            {
                using var k = kapsam.CreateScope();
                var servis = k.ServiceProvider.GetRequiredService<TeleradTeslimServisi>();
                var gonderilen = await servis.SiradakileriIsleAsync(20, dur);
                if (gonderilen > 0)
                    gunluk.LogInformation("Teslim kuyruğu: {Sayi} rapor teslim edildi.",
                                          gonderilen);
            }
            catch (OperationCanceledException) { break; }
            catch (Exception h)
            {
                gunluk.LogError(h, "Teslim kuyruğu turu başarısız.");
            }

            try { await Task.Delay(Aralik, dur); }
            catch (OperationCanceledException) { break; }
        }
    }
}

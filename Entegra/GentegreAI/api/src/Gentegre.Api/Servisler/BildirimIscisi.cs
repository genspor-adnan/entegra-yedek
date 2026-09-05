using System.Diagnostics;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// BİLDİRİM İŞÇİSİ (399) — kuyruğu tüketen arka plan servisi.
///
/// Neden ayrı bir işçi: bildirimi DOĞURAN istek (randevu kaydı, panik değer)
/// SMS sağlayıcısını beklememeli. Kuyruğa satır konur, kullanıcı işine devam
/// eder; gönderim burada, tekrar denemeleriyle birlikte yapılır.
///
/// Ayarlar (appsettings <c>Bildirim</c>):
///   Aktif       : işçi çalışsın mı (varsayılan true)
///   AraliksSn   : boş kuyrukta bekleme (varsayılan 15 sn)
///   Parti       : bir turda alınacak satır (varsayılan 20)
///   KayitModu   : sağlayıcı yokken gönderilmiş SAY ve gövdeyi günlüğe yaz
///
/// KİLİTLEME kuyrukta (<c>for update skip locked</c>): birden çok sunucu
/// çalışsa da aynı SMS iki kez gitmez.
/// </summary>
public sealed class BildirimIscisi : BackgroundService
{
    private readonly IServiceProvider _servisler;
    private readonly ILogger<BildirimIscisi> _gunluk;
    private readonly bool _aktif;
    private readonly int _araliksSn;
    private readonly int _parti;

    public BildirimIscisi(IServiceProvider servisler, ILogger<BildirimIscisi> gunluk,
                          IConfiguration ayar)
    {
        _servisler = servisler;
        _gunluk = gunluk;
        _aktif = ayar.GetValue("Bildirim:Aktif", true);
        _araliksSn = Math.Clamp(ayar.GetValue("Bildirim:AralikSn", 15), 5, 300);
        _parti = Math.Clamp(ayar.GetValue("Bildirim:Parti", 20), 1, 200);
    }

    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        if (!_aktif)
        {
            _gunluk.LogInformation("Bildirim işçisi KAPALI (Bildirim:Aktif=false).");
            return;
        }

        // ASKIDA KALANLAR: önceki çalışmada "Gönderiliyor" durumunda kalan
        //   satırlar (servis çökmesi / yeniden başlatma) kuyruğa geri alınır.
        try
        {
            await using var kapsam = _servisler.CreateAsyncScope();
            var depo = kapsam.ServiceProvider.GetRequiredService<BildirimDeposu>();
            var kurtarilan = await depo.AskidakileriKurtarAsync(TimeSpan.FromMinutes(10), iptal);
            if (kurtarilan > 0)
                _gunluk.LogWarning("Bildirim: askıda kalan {Adet} satır kuyruğa geri alındı.", kurtarilan);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "Bildirim: askıdakiler kurtarılamadı.");
        }

        while (!iptal.IsCancellationRequested)
        {
            var isledi = 0;
            try
            {
                isledi = await TurAsync(iptal);
            }
            catch (OperationCanceledException) when (iptal.IsCancellationRequested)
            {
                break;
            }
            catch (Exception h)
            {
                // Tek turun hatası işçiyi DÜŞÜRMEZ: kuyruk bir sonraki turda
                //   yeniden denenir, satırlar askıda kalmaz.
                _gunluk.LogError(h, "Bildirim turu hata verdi.");
            }

            // Kuyruk doluysa hemen devam: parti dolduysa bekleyecek satır var demektir.
            if (isledi < _parti)
                await Task.Delay(TimeSpan.FromSeconds(_araliksSn), iptal).ContinueWith(_ => { }, CancellationToken.None);
        }
    }

    private async Task<int> TurAsync(CancellationToken iptal)
    {
        await using var kapsam = _servisler.CreateAsyncScope();
        var depo = kapsam.ServiceProvider.GetRequiredService<BildirimDeposu>();
        var fabrika = kapsam.ServiceProvider.GetRequiredService<BildirimGondericiFabrikasi>();

        var kayitlar = await depo.SiradakileriAlAsync(_parti, iptal);
        foreach (var kayit in kayitlar)
        {
            var kronometre = Stopwatch.StartNew();
            Cekirdek.Bildirim.GonderimSonucu sonuc;
            try
            {
                var gonderici = await fabrika.KurAsync(kayit, iptal);
                sonuc = await gonderici.GonderAsync(kayit, iptal);
            }
            catch (Exception h)
            {
                sonuc = new Cekirdek.Bildirim.GonderimSonucu(false, Hata: h.Message);
            }
            kronometre.Stop();

            // Sonuç yazımı İPTAL EDİLEMEZ: uygulama kapanırken bile satırın
            //   akıbeti yazılmalı, yoksa askıda kalır.
            await depo.SonucYazAsync(kayit, sonuc, (int)kronometre.ElapsedMilliseconds,
                                     CancellationToken.None);

            if (!sonuc.Basarili)
                _gunluk.LogWarning("Bildirim #{Id} gönderilemedi ({Deneme}. deneme): {Hata}",
                    kayit.Id, kayit.Deneme, sonuc.Hata);
        }
        return kayitlar.Count;
    }
}

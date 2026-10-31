using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// KİŞİSEL HATIRLATMA İŞÇİSİ (1139, mockup Ekranlar/Kullanici/kisisel_hatirlatici.html).
///
/// Dakikada bir: uyarı anı gelmiş (zaman - uyar_dk ≤ şimdi) ve henüz uyarısı gitmemiş açık hatırlatmalar
/// için SMS / e-posta kanallarını bildirim kuyruğuna koyar (kaynak_tur 50) ve <c>uyari_gonderildi</c>'yi
/// damgalar - ikinci tur aynı satırı almaz. Uygulama içi uyarı (zil + açılır uyarı) işçiye bağlı değil,
/// istemci aynı kayıttan okur. Alıcı: sahip ve kapatmamış seçili kişiler (birim paylaşımında yalnız
/// sahip - bütün birime SMS atmak hatırlatma değil duyurudur). Bir günden eski satır gönderilmeden
/// damgalanır (geç girilmiş geçmiş tarihli hatırlatma SMS yağdırmasın).
///
/// KİLİT: <c>for update skip locked</c> - iki sunucu aynı hatırlatmayı iki kez göndermez.
/// </summary>
public sealed class HatirlatmaIscisi(IServiceProvider servisler, ILogger<HatirlatmaIscisi> gunluk) : BackgroundService
{
    private const short KaynakHatirlatma = 50;

    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        while (!iptal.IsCancellationRequested)
        {
            try { await TurAsync(iptal); }
            catch (OperationCanceledException) when (iptal.IsCancellationRequested) { break; }
            catch (Exception h) { gunluk.LogError(h, "Hatırlatma turu hata verdi."); }
            await Task.Delay(TimeSpan.FromSeconds(60), iptal).ContinueWith(_ => { }, CancellationToken.None);
        }
    }

    private async Task TurAsync(CancellationToken iptal)
    {
        await using var kapsam = servisler.CreateAsyncScope();
        var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();
        var bildirim = kapsam.ServiceProvider.GetRequiredService<BildirimDeposu>();
        await using var bg = await veri.AcAsync(iptal);
        await using var islem = await bg.BeginTransactionAsync(iptal);
        var satirlar = await bg.ListeAsync("""
            select h.id, h.baslik, h.notu, h.zaman, h.kanal_sms, h.kanal_eposta, h.kaynak_ad, h.sahip_id, h.paylasim, h.sube_id,
                   h.zaman < now() - interval '1 day' as eski
              from public.hatirlatma h
             where h.durum = 1 and h.uyari_gonderildi is null
               and h.zaman - make_interval(mins => h.uyar_dk) <= now()
             order by h.zaman
             limit 50
             for update skip locked
            """, islem, [], r => new
            {
                id = r.GetInt32(0), baslik = r.GetString(1), notu = r.GetString(2), zaman = r.GetFieldValue<DateTimeOffset>(3).UtcDateTime,
                sms = r.GetInt16(4) == 1, eposta = r.GetInt16(5) == 1, kaynakAd = r.GetString(6), sahip = r.GetInt32(7),
                paylasim = r.GetInt16(8), sube = r.GetInt32(9), eski = r.GetBoolean(10),
            }, iptal);
        foreach (var h in satirlar)
        {
            var giden = new List<string>();
            if (!h.eski && (h.sms || h.eposta))
            {
                var alicilar = await bg.ListeAsync("""
                    select t.id, coalesce(nullif(tk.cep_tel, ''), t.cep_tel, ''), coalesce(nullif(tk.eposta, ''), t.eposta, '')
                      from public.taraf t
                      left join public.taraf_kullanici tk on tk.id = t.id
                     where t.id = @p0
                        or (@p1 = 1 and t.id in (select p.kullanici_id from public.hatirlatma_paylasim p
                                                  where p.hatirlatma_id = @p2 and p.tamamlandi is null))
                    """, islem, [h.sahip, h.paylasim, h.id], r => (id: r.GetInt32(0), tel: r.GetString(1), eposta: r.GetString(2)), iptal);
                var degisken = new Dictionary<string, string>
                {
                    ["baslik"] = h.baslik,
                    ["zaman"] = Saat.Yerel(h.zaman).ToString("dd.MM.yyyy HH:mm"),
                    ["kayit"] = h.kaynakAd.Length > 0 ? " - " + h.kaynakAd : "",
                    ["notu"] = h.notu,
                };
                foreach (var a in alicilar)
                {
                    if (h.sms && a.tel.Length > 0
                        && await bildirim.KuyrugaEkleAsync(bg, islem, new BildirimIstegi("hatirlatma.kisisel", BildirimKanali.Sms, a.tel, degisken,
                               TarafId: a.id, KullaniciId: a.id, KaynakTur: KaynakHatirlatma, KaynakId: h.id, Oncelik: 3), 0, h.sube, iptal) is not null)
                        giden.Add("SMS");
                    if (h.eposta && a.eposta.Length > 0
                        && await bildirim.KuyrugaEkleAsync(bg, islem, new BildirimIstegi("hatirlatma.kisisel.eposta", BildirimKanali.Eposta, a.eposta, degisken,
                               TarafId: a.id, KullaniciId: a.id, KaynakTur: KaynakHatirlatma, KaynakId: h.id, Oncelik: 3), 0, h.sube, iptal) is not null)
                        giden.Add("e-posta");
                }
            }
            await bg.CalistirAsync("update public.hatirlatma set uyari_gonderildi = now() where id = @p0", islem, [h.id], iptal);
            var ayrinti = h.eski ? "geç girildi - gönderilmedi"
                : giden.Count > 0 ? string.Join(", ", giden.GroupBy(x => x).Select(g => g.Count() > 1 ? $"{g.Key} ×{g.Count()}" : g.Key)) + " kuyruğa alındı"
                : (h.sms || h.eposta) ? "SMS / e-posta adresi yok - yalnız uygulama" : "uygulama (zil + açılır uyarı)";
            await bg.CalistirAsync("""
                insert into public.hatirlatma_hareket (hatirlatma_id, olay, ayrinti, kullanici_id) values (@p0, 4, @p1, 0)
                """, islem, [h.id, ayrinti], iptal);
        }
        await islem.CommitAsync(iptal);
    }
}

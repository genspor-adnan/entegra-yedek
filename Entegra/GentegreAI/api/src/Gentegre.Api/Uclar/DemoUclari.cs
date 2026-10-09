using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler.Demo;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DEMO VERİSİ (964, mockup Ekranlar/Ayarlar/demo_tohum.html).
///
/// Okuma her kurulumda açıktır (ekran "bu kurulum DEMO değil" der); yazan
/// her uç `kurulum.demo = 1` ister - canlı kurulumda demo üretilemez, veri
/// silinemez. DEMO bayrağı ekrandan AÇILMAZ (sunucuda SQL ile).
/// </summary>
public static class DemoUclari
{
    public static void DemoUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/demo").WithTags("Demo").RequireAuthorization();

        grup.MapGet("/durum", async (BaglamCozucu cozucu, DemoVeriServisi demo, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar.demo_verisi", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var demoMu = await demo.DemoMuAsync(iptal);
            var son = await b.TekAsync("""
                select id, tetik, baslangic, bitis, durum, adim, ozet::text as ozet, hata, tohum
                  from public.demo_uretim order by id desc limit 1
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            var gece = await b.TekAsync("""
                select aktif, sonraki, son_calisma as "sonCalisma", basarili, son_sonuc as "sonSonuc"
                  from public.zamanli_is where kod = 'demo.yenile'
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            var gece7 = await b.TekAsync("""
                select count(*) as toplam, count(*) filter (where durum = 1) as basarili
                  from public.demo_uretim where tetik = 'gece' and baslangic > now() - interval '7 days'
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            // BUGÜNÜN SAHNESİ: tanıtım başında ekranda görünenler.
            var sahne = await b.TekAsync("""
                select (select count(*) from public.randevu r
                         where (r.baslangic at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date
                           and r.durum <> 4) as "bugunRandevu",
                       (select count(*) from public.randevu r
                         where (r.baslangic at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date
                           and r.durum = 1 and r.baslangic > now()) as "bekleyen",
                       (select count(*) from public.demo_kayit) as "demoKayit",
                       (select count(*) from public.demo_kayit k join public.taraf t on t.id = k.kayit_id
                         where k.tablo = 'taraf' and t.hasta = 1) as hasta,
                       (select count(*) from public.demo_kayit k join public.taraf t on t.id = k.kayit_id
                         where k.tablo = 'taraf' and t.personel = 1) as personel,
                       (select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) || ' · ' ||
                               to_char(r.baslangic at time zone 'Europe/Istanbul', 'HH24:MI') || ' ' ||
                               coalesce((select d.ad from public.departman d where d.id = r.bolum), '')
                          from public.taraf t join public.randevu r on r.hasta_id = t.id
                         where t.ad = 'Elif' and t.soyad = 'Demo'
                           and t.id in (select kayit_id from public.demo_kayit where tablo = 'taraf')
                         order by r.baslangic desc limit 1) as senaryo
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            var kullanicilar = await b.ListeAsync("""
                select k.kod, coalesce(r.ad, '') as rol, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad
                  from public.taraf_kullanici k join public.taraf t on t.id = k.id
                  left join public.rol r on r.id = k.rol_id
                 where k.kod like 'demo.%' and k.aktif = 1 order by k.kod
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new
            {
                demo = demoMu, ayar = await demo.AyarOkuAsync(iptal), son, gece, gece7, sahne,
                kullanicilar, parola = DemoVeriServisi.DemoParola,
                tanimli = DemoVeriServisi.Kullanicilar.Select(k => new { k.Kod, k.Baslik, k.Acilis }),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        grup.MapPut("/ayar", async (DemoAyar ayar, BaglamCozucu cozucu, DemoVeriServisi demo, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar.demo_verisi", Islem.Degistir);
            await demo.DemoIsteAsync(iptal);
            await demo.AyarYazAsync(ayar with { Tohum = Math.Clamp(ayar.Tohum, 1, 999999) }, iptal);
            return Results.Ok(new { izlemeNo = baglam.IzlemeNo });
        });

        // ÜRET / SIFIRLA: arka planda çalışır, ekran /durum'dan ilerlemeyi okur.
        grup.MapPost("/uret", async (bool? temizleYalniz, BaglamCozucu cozucu, DemoVeriServisi demo,
            IServiceScopeFactory kapsamlar, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar.demo_verisi", Islem.Degistir);
            await demo.DemoIsteAsync(iptal);
            var ayar = await demo.AyarOkuAsync(iptal);
            var id = await demo.UretimAcAsync("elle", baglam.KullaniciId, ayar.Tohum, iptal);
            var uret = temizleYalniz != true;
            _ = Task.Run(async () =>
            {
                await using var kapsam = kapsamlar.CreateAsyncScope();
                await kapsam.ServiceProvider.GetRequiredService<DemoVeriServisi>().CalistirAsync(id, uret, CancellationToken.None);
            }, CancellationToken.None);
            return Results.Ok(new { id, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPut("/gece", async (GeceIstegi istek, BaglamCozucu cozucu, DemoVeriServisi demo, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar.demo_verisi", Islem.Degistir);
            await demo.DemoIsteAsync(iptal);
            await veri.CalistirAsync("update public.zamanli_is set aktif = @p0 where kod = 'demo.yenile'",
                [(short)(istek.Aktif ? 1 : 0)], iptal);
            return Results.Ok(new { izlemeNo = baglam.IzlemeNo });
        });

        // GİRİŞ EKRANI "Demo olarak dene": yalnız DEMO kurulumda liste döner.
        yol.MapGet("/api/demo/girisler", async (DemoVeriServisi demo, VeriKaynagi veri, CancellationToken iptal) =>
        {
            if (!await demo.DemoMuAsync(iptal)) return Results.Ok(new { demo = false, girisler = Array.Empty<object>() });
            await using var b = await veri.AcAsync(iptal);
            var aktif = (await b.ListeAsync("select kod from public.taraf_kullanici where kod like 'demo.%' and aktif = 1",
                null, [], o => o.GetString(0), iptal)).ToHashSet();
            var girisler = DemoVeriServisi.Kullanicilar.Where(k => aktif.Contains(k.Kod))
                .Select(k => new { kod = k.Kod, baslik = k.Baslik, parola = DemoVeriServisi.DemoParola });
            return Results.Ok(new { demo = true, girisler });
        }).AllowAnonymous().WithTags("Demo");
    }

    public sealed record GeceIstegi(bool Aktif);
}

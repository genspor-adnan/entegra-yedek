using System.Diagnostics;
using System.Net.Sockets;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RADYOLOJİ CİHAZ LİSTESİ + KARTI (967, mockup Ekranlar/Radyoloji/radyoloji_cihaz_*_v2.html).
///
/// Gösterge şeridi / sol panel sayıları, liste önizleme paneli, kartın
/// Kullanım ve Doz sekmeleri, bağlantı testi. "Şu an" ve doluluk
/// v_radyoloji_cihaz_durum görünümünden: liste kolonu ile kutu aynı tanımı okur.
/// Doz ve kullanım ÇEKİLMİŞ istemlerden (radyoloji_istem.cihaz_id, dlp, ctdi).
/// </summary>
public static partial class RadyolojiUclari
{
    private static void CihazEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/cihaz-gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var gosterge = await b.TekAsync("""
                select count(*) filter (where c.durum = 1)                          as aktif,
                       count(*) filter (where d.su_an_kod = 1)                       as calisiyor,
                       count(*) filter (where d.su_an_kod = 2)                       as bakim,
                       count(*) filter (where d.su_an_kod = 3)                       as ariza,
                       count(*) filter (where c.durum = 1 and d.qa_geciken > 0)      as "qaGecikti",
                       count(*) filter (where c.durum = 1 and d.goruntu_eksik > 0)   as baglanti
                  from public.radyoloji_cihaz c join public.v_radyoloji_cihaz_durum d on d.cihaz_id = c.id
                 where (@p0::int is null or c.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var konumlar = await b.ListeAsync("""
                select coalesce(nullif(trim(c.oda), ''), '(oda yok)') as oda, count(*) as sayi
                  from public.radyoloji_cihaz c where (@p0::int is null or c.sube_id = @p0)
                 group by 1 order by 1
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { gosterge, konumlar, izlemeNo = baglam.IzlemeNo });
        });

        // ÖNİZLEME: bugün, saatlik yoğunluk, yaklaşan kapatma, QA uyarısı, doz hedefi aşan protokol.
        grup.MapGet("/cihaz/{id:int}/ozet", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var cihaz = await b.TekAsync("""
                select c.kod, c.ad, concat_ws(' ', nullif(c.marka, ''), nullif(c.model, '')) as model, coalesce(c.oda, '') as oda,
                       coalesce(public.fn_taraf_ad(s.unvan, s.ad, s.soyad)::varchar(120), '') as sorumlu,
                       case when c.randevu_verilir = 1 then c.baslangic_saat || '-' || c.bitis_saat || ' · ' || c.slot_dk || ' dk'
                            else 'randevusuz' end as mesai,
                       d.su_an as "suAn", d.su_an_kod as "suAnKod", d.kapali_bitis as "kapaliBitis",
                       d.bugun_cekim as "bugunCekim", d.bugun_randevu as "bugunRandevu", d.sirada,
                       d.qa_geciken_ad as "qaGecikenAd", d.goruntu_eksik as "goruntuEksik"
                  from public.radyoloji_cihaz c left join public.taraf s on s.id = c.sorumlu_id
                  join public.v_radyoloji_cihaz_durum d on d.cihaz_id = c.id where c.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı.");
            var saatlik = await b.ListeAsync("""
                select extract(hour from r.baslangic at time zone 'Europe/Istanbul')::int as saat, count(*) as adet
                  from public.randevu r
                 where r.cihaz_id = @p0 and r.durum <> 4
                   and (r.baslangic at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date
                 group by 1 order by 1
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var bosSlot = await b.TekDegerAsync<string?>("""
                select to_char(g.t, 'HH24:MI')
                  from public.radyoloji_cihaz c,
                       generate_series(date_trunc('minute', now() at time zone 'Europe/Istanbul'),
                                       (now() at time zone 'Europe/Istanbul')::date + c.bitis_saat::time,
                                       make_interval(mins => greatest(c.slot_dk, 5))) g(t)
                 where c.id = @p0 and c.randevu_verilir = 1 and c.bitis_saat ~ '^\d{1,2}:\d{2}$'
                   and not exists (select 1 from public.randevu r where r.cihaz_id = c.id and r.durum <> 4
                                     and (r.baslangic at time zone 'Europe/Istanbul') <= g.t
                                     and (r.baslangic at time zone 'Europe/Istanbul') + make_interval(mins => greatest(coalesce(r.sure_dk, c.slot_dk), 1)) > g.t)
                 order by g.t limit 1
                """, null, [id], iptal);
            var kapatma = await b.TekAsync("""
                select k.baslangic, k.bitis, k.neden_tur as "nedenTur", coalesce(k.aciklama, '') as aciklama,
                       (select count(*) from public.randevu r where r.cihaz_id = k.cihaz_id and r.durum <> 4
                          and r.baslangic < k.bitis and r.baslangic >= k.baslangic) as etkilenen
                  from public.radyoloji_cihaz_kapatma k
                 where k.cihaz_id = @p0 and k.bitis > now() order by k.baslangic limit 1
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var dozUstu = await b.TekDegerAsync<long>(DozSql("select count(*) from doz where dlp_ort > dlp_hedef or ctdi_ort > ctdi_hedef"),
                null, [id], iptal);
            return Results.Ok(new { cihaz, saatlik, bosSlot, kapatma, dozUstu, izlemeNo = baglam.IzlemeNo });
        });

        // KULLANIM · 30 gün: çekim, doluluk, oda süresi, gelmedi / iptal, günlük dizi, arıza kaybı.
        grup.MapGet("/cihaz/{id:int}/kullanim", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ozet = await b.TekAsync("""
                with r as (select * from public.randevu where cihaz_id = @p0 and baslangic > now() - interval '30 days' and baslangic <= now())
                select (select count(*) from public.radyoloji_istem i where i.cihaz_id = @p0 and i.cekim_tarihi > now() - interval '30 days') as cekim,
                       (select count(*) from r) as randevu,
                       (select count(*) from r where r.durum in (3, 4)) as "gelmediIptal",
                       (select round(avg(coalesce(r.sure_dk, 0))) from r where r.durum = 2) as "ortSure",
                       (select round(sum(extract(epoch from (least(k.bitis, now()) - greatest(k.baslangic, now() - interval '30 days'))) / 3600.0)::numeric, 1)
                          from public.radyoloji_cihaz_kapatma k
                         where k.cihaz_id = @p0 and k.neden_tur = 2 and k.bitis > now() - interval '30 days' and k.baslangic < now()) as "arizaSaat",
                       (select hafta_kapasite from public.v_radyoloji_cihaz_durum where cihaz_id = @p0) as "haftaKapasite"
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var gunluk = await b.ListeAsync("""
                select g::date as gun, extract(isodow from g)::int as hgun,
                       (select count(*) from public.radyoloji_istem i where i.cihaz_id = @p0
                          and (i.cekim_tarihi at time zone 'Europe/Istanbul')::date = g::date) as adet
                  from generate_series((now() at time zone 'Europe/Istanbul')::date - 29, (now() at time zone 'Europe/Istanbul')::date, interval '1 day') g
                 order by 1
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { ozet, gunluk, izlemeNo = baglam.IzlemeNo });
        });

        // DOZ · 30 gün: tetkik başına ortalama CTDIvol / DLP, protokol hedefi, DRL.
        grup.MapGet("/cihaz/{id:int}/doz", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync(DozSql("""
                select tetkik, adet, ctdi_ort as "ctdiOrt", ctdi_hedef as "ctdiHedef", dlp_ort as "dlpOrt",
                       dlp_hedef as "dlpHedef", drl, drl_ustu as "drlUstu" from doz order by adet desc
                """), null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // BAĞLANTI TESTİ: cihazın IP / portuna TCP bağlantısı (DICOM C-ECHO değil - port açık mı).
        grup.MapPost("/cihaz/{id:int}/baglanti-test", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("select coalesce(ip, '') as ip, port from public.radyoloji_cihaz where id = @p0",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı.");
            var ip = (c["ip"] as string ?? "").Trim();
            var port = c["port"] is int p ? p : 104;
            if (ip.Length == 0) throw GentegreHatasi.IsKurali("Cihazın IP adresi girilmemiş (Genel › DICOM / bağlantı).");
            var sure = Stopwatch.StartNew();
            try
            {
                using var tcp = new TcpClient();
                using var zaman = CancellationTokenSource.CreateLinkedTokenSource(iptal);
                zaman.CancelAfter(TimeSpan.FromSeconds(3));
                await tcp.ConnectAsync(ip, port, zaman.Token);
                return Results.Ok(new { acik = true, ip, port, ms = sure.ElapsedMilliseconds, izlemeNo = baglam.IzlemeNo });
            }
            catch (Exception h) when (h is SocketException or OperationCanceledException)
            {
                return Results.Ok(new { acik = false, ip, port, ms = sure.ElapsedMilliseconds,
                    hata = h is OperationCanceledException ? "3 sn içinde yanıt yok" : h.Message, izlemeNo = baglam.IzlemeNo });
            }
        });
    }

    /// <summary>Son 30 gün doz özeti CTE'si (@p0 = cihaz); `son` sorgu `doz`dan okur.</summary>
    private static string DozSql(string son) => $$"""
        with doz as (
            select coalesce(h.ad, '?') as tetkik, count(*) as adet,
                   round(avg(i.ctdi)::numeric, 1) as ctdi_ort, max(p.ctdi_hedef) as ctdi_hedef,
                   round(avg(i.dlp)::numeric, 0) as dlp_ort, max(p.dlp_hedef) as dlp_hedef, max(p.drl) as drl,
                   count(*) filter (where p.drl is not null and i.dlp > p.drl) as drl_ustu
              from public.radyoloji_istem i
              join public.hizmet h on h.id = i.hizmet_id
              left join public.radyoloji_protokol p on p.hizmet_id = i.hizmet_id
             where i.cihaz_id = @p0 and i.cekim_tarihi > now() - interval '30 days'
               and (i.dlp is not null or i.ctdi is not null)
             group by h.ad)
        {{son}}
        """;
}

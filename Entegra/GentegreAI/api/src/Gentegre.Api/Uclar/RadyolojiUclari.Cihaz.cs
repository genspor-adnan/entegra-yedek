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

    /// <summary>
    /// KAPAT / BAKIMA AL (kart araç çubuğu): kapatma satırı açar; o aralıkta
    /// takvim kapalı çizilir, randevu verilmez. Etkilenen (aralıktaki) randevu
    /// sayısı döner - taşıma / SMS ayrı iştir.
    /// </summary>
    public sealed record KapatIstegi(short NedenTur, DateTimeOffset Baslangic, DateTimeOffset Bitis, string? Aciklama);

    private static void CihazAracEkle(RouteGroupBuilder grup)
    {
        grup.MapPost("/cihaz/{id:int}/kapat", async (int id, KapatIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Gentegre.Veri.Depolar.LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);
            baglam.YazmaIste();
            if (istek.Bitis <= istek.Baslangic)
                throw GentegreHatasi.Dogrulama("Bitiş başlangıçtan sonra olmalı.", new AlanHatasi("bitis", "Bitiş başlangıçtan sonra olmalı."));
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var kid = await b.TekDegerAsync<int>("""
                insert into public.radyoloji_cihaz_kapatma (cihaz_id, baslangic, bitis, neden_tur, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5) returning id
                """, islem, [id, istek.Baslangic.ToUniversalTime(), istek.Bitis.ToUniversalTime(), istek.NedenTur,
                             (istek.Aciklama ?? "").Trim(), baglam.KullaniciId], iptal);
            var etkilenen = await b.TekDegerAsync<long>("""
                select count(*) from public.randevu where cihaz_id = @p0 and durum <> 4 and baslangic >= @p1 and baslangic < @p2
                """, islem, [id, istek.Baslangic.ToUniversalTime(), istek.Bitis.ToUniversalTime()], iptal);
            await log.YazAsync(b, islem, Gentegre.Veri.Depolar.LogIslemi.Ekle, 1282, kid, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { neden = istek.NedenTur, baslangic = istek.Baslangic, bitis = istek.Bitis, istek.Aciklama, etkilenen },
                ustTabloId: 944, ustKayitId: id, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = kid, etkilenen, izlemeNo = baglam.IzlemeNo });
        });

        // BU HAFTA KAPASİTE (randevu ayarları sekmesi): gün x saat ızgarası -
        //   kapasite (mesai, öğle, slot, eşzaman), dolu (randevu), kapalı (kapatma).
        grup.MapGet("/cihaz/{id:int}/hafta", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("""
                select randevu_verilir as rv, baslangic_saat as bas, bitis_saat as bit, ogle_baslangic as ob, ogle_bitis as oe,
                       coalesce(slot_dk, 15) as slot, greatest(coalesce(eszaman, 1), 1) as es, coalesce(acil_slot, 0) as acil,
                       coalesce(calisma_gunleri, '') as gunler,
                       date_trunc('week', now() at time zone 'Europe/Istanbul')::date as pazartesi
                  from public.radyoloji_cihaz where id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı.");
            var pzt = (DateTime)c["pazartesi"]!;
            var randevular = await b.ListeAsync("""
                select (baslangic at time zone 'Europe/Istanbul') as t from public.randevu
                 where cihaz_id = @p0 and durum <> 4
                   and (baslangic at time zone 'Europe/Istanbul') >= @p1 and (baslangic at time zone 'Europe/Istanbul') < @p1 + interval '7 days'
                """, null, [id, pzt], o => o.GetDateTime(0), iptal);
            var kapatmalar = await b.ListeAsync("""
                select (baslangic at time zone 'Europe/Istanbul') as b, (bitis at time zone 'Europe/Istanbul') as e, neden_tur as n
                  from public.radyoloji_cihaz_kapatma
                 where cihaz_id = @p0 and (bitis at time zone 'Europe/Istanbul') > @p1 and (baslangic at time zone 'Europe/Istanbul') < @p1 + interval '7 days'
                """, null, [id, pzt], o => (o.GetDateTime(0), o.GetDateTime(1), o.IsDBNull(2) ? (short)9 : o.GetInt16(2)), iptal);

            static int? Dk(object? v) => v is string s && TimeOnly.TryParse(s, out var t) ? t.Hour * 60 + t.Minute : null;
            int? bas = Dk(c["bas"]), bit = Dk(c["bit"]), ob = Dk(c["ob"]), oe = Dk(c["oe"]);
            var slot = Math.Max(5, Convert.ToInt32(c["slot"])); var es = Convert.ToInt32(c["es"]);
            var gunler = ((string)c["gunler"]!).Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(x => int.TryParse(x.Trim(), out var g) ? g : 0).ToHashSet();
            if (bas is null || bit is null || Convert.ToInt32(c["rv"]) != 1)
                return Results.Ok(new { randevulu = false, satirlar = Array.Empty<object>(), izlemeNo = baglam.IzlemeNo });

            var saatler = Enumerable.Range(bas.Value / 60, (bit.Value + 59) / 60 - bas.Value / 60).ToList();
            var satirlar = saatler.Select(sa => new
            {
                saat = $"{sa:00}:00",
                gunler = Enumerable.Range(0, 7).Select(g =>
                {
                    var gun = pzt.AddDays(g);
                    var calisir = gunler.Contains(g + 1);
                    var hb = Math.Max(sa * 60, bas.Value); var he = Math.Min(sa * 60 + 60, bit.Value);
                    // Öğle ile kesişen dakikalar düşülür; saat tamamen öğledeyse "öğle".
                    var ogleDk = ob is int o1 && oe is int o2 ? Math.Max(0, Math.Min(he, o2) - Math.Max(hb, o1)) : 0;
                    var kap = calisir && he > hb ? Math.Max(0, (he - hb - ogleDk) / slot) * es : 0;
                    var bs = gun.AddMinutes(sa * 60); var bt = bs.AddHours(1);
                    var kapali = kapatmalar.Where(k => k.Item1 < bt && k.Item2 > bs).Select(k => (short?)k.Item3).FirstOrDefault();
                    var dolu = randevular.Count(t => t >= bs && t < bt);
                    var tur = !calisir || he <= hb ? "yok" : kapali is not null ? (kapali == 2 ? "ariza" : "kapali")
                            : kap == 0 && ogleDk > 0 ? "ogle" : "acik";
                    return new { tur, kapasite = kap, dolu, bos = Math.Max(0, kap - dolu) };
                }).ToArray(),
            }).ToList();
            var toplam = satirlar.Sum(s => s.gunler.Where(g => g.tur == "acik").Sum(g => g.kapasite));
            var dolu = satirlar.Sum(s => s.gunler.Where(g => g.tur == "acik").Sum(g => g.dolu));
            return Results.Ok(new { randevulu = true, pazartesi = pzt, satirlar, toplam, dolu, izlemeNo = baglam.IzlemeNo });
        });

        // ---- CİHAZ KAPATMALARI (bakım / arıza / plan dışı kapalı) ----
        //   976 öncesinde bu iki uç "PanoVeCihaz" dosyasındaydı: cihaz
        //   işleri iki dosyaya bölünmüş olduğu için kapatma uçlarını arayan
        //   kişi cihaz dosyasında bulamıyordu.
        // ----------------------------------------------- cihaz kapatmalar ----
        // TAKVIMDE GORUNURLUK (318): kapatma kurali randevuyu zaten engelliyordu
        //   (316 tetigi) ama takvim bos gosterdigi icin kullanici o saate
        //   randevu vermeye calisip hata aliyordu. Takvim bu ucu okuyup
        //   arali blok cizer. Cihazin ogle arasi da ayni listede doner:
        //   kullanici acisindan ikisi de "kapali saat".
        grup.MapGet("/cihaz-kapatma", async (
            DateTime bas, DateTime bit, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select k.id, k.cihaz_id as "cihazId", k.baslangic, k.bitis,
                       k.neden_tur as "nedenTur",
                       coalesce(nullif(k.aciklama, ''), coalesce(kd.ad, 'Kapalı')) as aciklama,
                       coalesce(kd.ad, '') as "nedenAdi",
                       coalesce(c.ad, '') as cihaz
                  from public.radyoloji_cihaz_kapatma k
                  join public.radyoloji_cihaz c on c.id = k.cihaz_id
                  left join public.kod_liste kl on kl.kod = 'rad.kapatma'
                  left join public.kod_deger kd
                         on kd.liste_id = kl.id and kd.deger = k.neden_tur
                 where k.baslangic < @p1 and k.bitis > @p0
                   and (@p2::int is null or c.sube_id = @p2)
                 order by k.cihaz_id, k.baslangic
                """, null, [bas, bit, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Cihazin OGLE ARASI: ayri tablo degil cihaz ayari - takvimde ayni
            //   bicimde cizilsin diye burada aralik satirina cevrilir.
            var cihazlar = await baglanti.ListeAsync("""
                select c.id, c.ad, c.ogle_baslangic as "ogleBaslangic",
                       c.ogle_bitis as "ogleBitis"
                  from public.radyoloji_cihaz c
                 where coalesce(c.durum, 1) = 1 and c.randevu_verilir = 1
                   and c.ogle_baslangic <> '' and c.ogle_bitis <> ''
                   and (@p0::int is null or c.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { kapatmalar = satirlar, ogleArasi = cihazlar });
        });

        // KAPATMA EKLEME (318): takvimden "Cihazı Kapat". Aralıga düsen
        //   randevular SAYILIR ve kullaniciya bildirilir - tetik yalniz
        //   yeni/degisen randevuyu denetler, mevcutlar kapali saatte kalir.
        grup.MapPost("/cihaz/{id:int}/kapatma", async (
            int id, KapatmaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);

            if (istek.Bitis <= istek.Baslangic)
                throw GentegreHatasi.IsKurali("Kapatma bitişi başlangıçtan sonra olmalı.");

            await using var baglanti = await veri.AcAsync(iptal);

            var etkilenen = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.randevu r
                 where r.cihaz_id = @p0
                   and coalesce(r.durum, 1) not in (3, 4)
                   and r.baslangic < @p2
                   and (r.baslangic + make_interval(mins => greatest(coalesce(r.sure_dk, 0), 1)))
                       > @p1
                """, null, [id, istek.Baslangic, istek.Bitis], iptal);

            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.radyoloji_cihaz_kapatma
                       (cihaz_id, baslangic, bitis, neden_tur, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5)
                returning id
                """, null,
                [id, istek.Baslangic, istek.Bitis, istek.NedenTur ?? (short)1,
                 istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            return Results.Ok(new { id = yeni, etkilenenRandevu = etkilenen });
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

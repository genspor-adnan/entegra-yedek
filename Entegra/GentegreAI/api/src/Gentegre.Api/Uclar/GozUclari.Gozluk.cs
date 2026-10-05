using System.Security.Cryptography;
using System.Text;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZLÜK REÇETESİ v2 (972, mockup Ekranlar/Goz/goz_gozluk_recetesi_v2.html ·
/// goz_gozluk_recete_listesi_v2.html).
///
/// <para><b>Kaynak</b>: kartın hasta bandı, başlık rozetleri ve "değerleri al" düğmeleri
/// tek uçtan - bu muayenenin subjektif / sikloplejik refraksiyonu, mevcut gözlük, hastanın
/// önceki reçeteleri, SGK 2 yıl kuralı. <b>İmza</b> değerleri kilitler (durum 2, özet
/// hash'i); <b>optiğe ver</b> (3) ve <b>teslim</b> (4) akışın kalanı.</para>
/// </summary>
public static partial class GozUclari
{
    private const int LogTabloGozluk = 1103;   // KartKatalogu LogGozGozlukRecete ile aynı

    private static void GozlukUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/gozluk/kaynak", async (int? receteId, int? hastaId, int? muayeneId, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.recete", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            if (receteId is int rid)
            {
                var r = await b.TekAsync("select hasta_id, muayene_id from public.goz_gozluk_recetesi where id = @p0",
                    null, [rid], o => new { H = o.GetInt32(0), M = o.IsDBNull(1) ? (int?)null : o.GetInt32(1) }, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Reçete bulunamadı.");
                hastaId = r.H; muayeneId ??= r.M;
            }
            if (hastaId is not int hid) throw GentegreHatasi.Dogrulama("Hasta gerekli.");
            var hasta = await b.TekAsync("""
                select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad, coalesce(t.kod, '') as "hastaNo",
                       case when th.dogum_tarihi is null then null::int else extract(year from age(th.dogum_tarihi))::int end as yas,
                       coalesce(th.cinsiyet, 0) as cinsiyet
                  from public.taraf t left join public.taraf_hasta th on th.id = t.id where t.id = @p0
                """, null, [hid], OkuyucuGenisletmeleri.Sozluk, iptal);
            var muayene = muayeneId is int mid ? await b.TekAsync("""
                select m.id, coalesce(m.muayene_no, '') as protokol, m.muayene_tarihi as tarih, m.personel_id as "hekimId",
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as hekim,
                       coalesce(gm.dilate, 0) as dilate, gm.id as "gozMuayeneId"
                  from public.muayene m left join public.taraf h on h.id = m.personel_id
                  left join public.goz_muayene gm on gm.muayene_id = m.id
                 where m.id = @p0
                """, null, [mid], OkuyucuGenisletmeleri.Sozluk, iptal) : null;
            // DEĞER KAYNAKLARI: bu muayenenin subjektif (2), sikloplejik (3), mevcut gözlük (5).
            var refr = muayene?["gozMuayeneId"] is int gid ? await b.ListeAsync("""
                select distinct on (r.tur, r.goz) r.tur, r.goz, r.sph, r.cyl, r.aks, r.add_yakin as "add", r.va,
                       r.pd_uzak as "pdUzak", r.pd_yakin as "pdYakin"
                  from public.goz_refraksiyon r where r.goz_muayene_id = @p0 and r.tur in (2, 3, 5) and r.goz in (1, 2)
                 order by r.tur, r.goz, r.zaman desc
                """, null, [gid], OkuyucuGenisletmeleri.Sozluk, iptal) : [];
            var oncekiler = await b.ListeAsync("""
                select r.id, r.ekleme_tarihi as tarih, r.tur, r.durum, coalesce(r.recete_no, '') as "receteNo", r.sgk_hak as sgk,
                       r.od_sph as "odSph", r.od_cyl as "odCyl", r.od_aks as "odAks", r.os_sph as "osSph", r.os_cyl as "osCyl",
                       r.os_aks as "osAks", coalesce(r.od_add, r.os_add) as "add", r.od_pd as "odPd", r.os_pd as "osPd", r.pd_yakin as "pdYakin",
                       r.cam_malzeme as "camMalzeme", r.kaplamalar, coalesce(r.tasarim, '') as tasarim
                  from public.goz_gozluk_recetesi r
                 where r.hasta_id = @p0 and r.durum >= 2 and (@p1::int is null or r.id <> @p1)
                 order by r.ekleme_tarihi desc limit 10
                """, null, [hid, receteId], OkuyucuGenisletmeleri.Sozluk, iptal);
            // SGK 2 YIL: son SGK'lı imzalı reçeteden 2 yıl geçmediyse yeni reçete SGK'dan karşılanmaz.
            var sonSgk = await b.TekDegerAsync<DateTime?>("""
                select max(r.ekleme_tarihi) from public.goz_gozluk_recetesi r
                 where r.hasta_id = @p0 and r.durum >= 2 and coalesce(r.sgk_hak, 0) = 1 and (@p1::int is null or r.id <> @p1)
                """, null, [hid, receteId], iptal);
            return Results.Ok(new
            {
                hasta, muayene, refraksiyon = refr, oncekiler,
                sonSgk, sgkHakVar = sonSgk is null || sonSgk.Value.AddYears(2) <= DateTime.UtcNow,
                sgkHakTarihi = sonSgk?.AddYears(2),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // İMZA: değerler kilitlenir (kart salt okunur olur), özet hash'i + QR kodu yazılır.
        grup.MapPost("/gozluk/{id:int}/imzala", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.recete", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var r = await b.TekAsync("""
                select durum, hasta_id, concat_ws('|', od_sph, od_cyl, od_aks, od_add, os_sph, os_cyl, os_aks, os_add, od_pd, os_pd, pd_yakin, tur),
                       coalesce(nullif(recete_no, ''), 'GR-' || id), (od_sph is null and os_sph is null and od_cyl is null and os_cyl is null)
                  from public.goz_gozluk_recetesi where id = @p0
                """, null, [id], o => new { Durum = (int)o.GetInt16(0), Hasta = o.GetInt32(1), Ozet = o.GetString(2), No = o.GetString(3), Bos = o.GetBoolean(4) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Reçete bulunamadı.");
            if (r.Durum != 1) throw GentegreHatasi.IsKurali("Yalnız taslak reçete imzalanır.");
            if (r.Bos) throw GentegreHatasi.IsKurali("Reçete değeri girilmemiş (sph / cyl).");
            var hash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{id}|{r.Ozet}|{baglam.KullaniciId}")))[..32];
            await b.CalistirAsync("""
                update public.goz_gozluk_recetesi
                   set durum = 2, imza_zamani = now(), imza_hash = @p1, qr_kod = @p2,
                       recete_no = case when coalesce(recete_no, '') = '' then @p2 else recete_no end,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0 and durum = 1
                """, null, [id, hash, r.No, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloGozluk, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "İmzalandı", hash }, tarafId: r.Hasta, iptal: iptal);
            return Results.Ok(new { id, durum = 2, receteNo = r.No, izlemeNo = baglam.IzlemeNo });
        });

        // OPTİĞE VER (3) / TESLİM (4): imzalı reçetenin akışı.
        grup.MapPost("/gozluk/{id:int}/durum/{yeni:int}", async (int id, int yeni, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.recete", Islem.Degistir);
            baglam.YazmaIste();
            if (yeni is not (3 or 4)) throw GentegreHatasi.Dogrulama("Durum 3 (optiğe verildi) ya da 4 (teslim) olmalı.");
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.goz_gozluk_recetesi
                   set durum = @p1, optik_teslim = case when @p1 = 4 then current_date else optik_teslim end,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and durum between 2 and @p1 - 1
                """, null, [id, (short)yeni, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali(yeni == 3 ? "Önce reçete imzalanmalı." : "Reçete optiğe verilmiş ya da imzalı olmalı.");
            await log.YazAsync(LogIslemi.Degistir, LogTabloGozluk, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = yeni == 3 ? "Optiğe verildi" : "Teslim edildi" }, iptal: iptal);
            return Results.Ok(new { id, durum = yeni, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/gozluk-gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.recete", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var gosterge = await b.TekAsync("""
                select count(*) filter (where (r.ekleme_tarihi at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date) as bugun,
                       count(*) filter (where r.durum = 1)                                    as taslak,
                       count(*) filter (where r.durum = 3)                                    as optikte,
                       count(*) filter (where r.durum between 2 and 3 and r.gecerlilik_bitis between current_date and current_date + 30) as "bitecek",
                       count(*) filter (where v.sgk_erken = 1)                                as "sgkErken",
                       count(*) filter (where v.sgk_hak_dogdu = 1)                            as "sgkHakDogdu"
                  from public.goz_gozluk_recetesi r join public.v_goz_gozluk_ozet v on v.recete_id = r.id
                 where (@p0::int is null or r.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var turler = await b.ListeAsync("select tur, count(*) as sayi from public.goz_gozluk_recetesi where (@p0::int is null or sube_id = @p0) group by 1 order by 1",
                null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var durumlar = await b.ListeAsync("select durum, count(*) as sayi from public.goz_gozluk_recetesi where (@p0::int is null or sube_id = @p0) group by 1 order by 1",
                null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var optikler = await b.ListeAsync("""
                select r.optik_taraf_id as id, coalesce(nullif(public.fn_taraf_ad(o.unvan, o.ad, o.soyad)::varchar(120), ''), '— hasta seçmedi') as ad, count(*) as sayi
                  from public.goz_gozluk_recetesi r left join public.taraf o on o.id = r.optik_taraf_id
                 where (@p0::int is null or r.sube_id = @p0) group by 1, 2 order by 3 desc
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { gosterge, turler, durumlar, optikler, izlemeNo = baglam.IzlemeNo });
        });

        // ÖNİZLEME (liste sağ paneli): reçete + önceki reçeteye göre fark + teslim adımları.
        grup.MapGet("/gozluk/{id:int}/onizleme", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.recete", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var r = await b.TekAsync("""
                select r.id, r.hasta_id as "hastaId", r.muayene_id as "muayeneId", coalesce(r.recete_no, '') as "receteNo",
                       r.ekleme_tarihi as tarih, r.tur, r.kullanim, r.durum,
                       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as hasta,
                       r.od_sph as "odSph", r.od_cyl as "odCyl", r.od_aks as "odAks", r.od_add as "odAdd", r.od_pd as "odPd",
                       r.os_sph as "osSph", r.os_cyl as "osCyl", r.os_aks as "osAks", r.os_add as "osAdd", r.os_pd as "osPd",
                       r.cam_malzeme as "camMalzeme", r.kaplamalar, coalesce(r.tasarim, '') as tasarim,
                       r.gecerlilik_bitis as gecerlilik, r.sgk_hak as sgk, r.imza_zamani as "imzaZamani", r.optik_teslim as teslim,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as hekim,
                       coalesce(public.fn_taraf_ad(o.unvan, o.ad, o.soyad)::varchar(120), '') as optik,
                       p.ekleme_tarihi as "oncekiTarih", r.od_sph - p.od_sph as "farkOdSph", r.os_sph - p.os_sph as "farkOsSph",
                       coalesce(r.od_add, r.os_add) - coalesce(p.od_add, p.os_add) as "farkAdd"
                  from public.goz_gozluk_recetesi r
                  join public.taraf t on t.id = r.hasta_id
                  left join public.taraf h on h.id = r.hekim_id
                  left join public.taraf o on o.id = r.optik_taraf_id
                  left join lateral (select x.* from public.goz_gozluk_recetesi x
                                      where x.hasta_id = r.hasta_id and x.id <> r.id and x.durum >= 2 and x.ekleme_tarihi < r.ekleme_tarihi
                                      order by x.ekleme_tarihi desc limit 1) p on true
                 where r.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Reçete bulunamadı.");
            return Results.Ok(new { recete = r, izlemeNo = baglam.IzlemeNo });
        });
    }
}

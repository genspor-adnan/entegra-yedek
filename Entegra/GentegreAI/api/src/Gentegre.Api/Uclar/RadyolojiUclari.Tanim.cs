using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RAPOR ŞABLONU + ÇEKİM PROTOKOLÜ TANIM EKRANLARI (965, mockup
/// Ekranlar/Radyoloji/radyoloji_sablon_*_v2.html · radyoloji_protokol_*.html).
///
/// Liste önizleme panelleri, şablon kartının Önizleme / Sürümler / Kullanım
/// sekmeleri. SÜRÜM: "Yeni sürüm" mevcut içeriği (bölüm, alan, makro)
/// `radyoloji_sablon_surum`a dondurur ve sayacı artırır - yazılmış rapor kendi
/// sürüm numarasıyla kalır (radyoloji_rapor.sablon_surum). "Geri yükle" eski
/// içeriği bugünkü sürüme yazar (sürüm numarası değişmez, iz geçmişte).
/// </summary>
public static partial class RadyolojiUclari
{
    private static void TanimEkle(RouteGroupBuilder grup)
    {
        // Şablon özeti: iskelet + makrolar + 30 gün kullanım (liste sağ paneli).
        grup.MapGet("/sablon/{id:int}/ozet", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var bolumler = await b.ListeAsync("""
                select sira, baslik, coalesce(varsayilan_metin, '') as "varsayilanMetin", zorunlu, yazdir,
                       coalesce(bakanlik_parca, 0) as "bakanlikParca"
                  from public.radyoloji_sablon_bolum where sablon_id = @p0 order by sira, id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var alanlar = await b.ListeAsync("""
                select alan_kod as "alanKod", alan_ad as "alanAd", coalesce(tip, 0) as tip, hedef_bolum as "hedefBolum"
                  from public.radyoloji_sablon_alan where sablon_id = @p0 order by sira, id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var makrolar = await b.ListeAsync("""
                select kisayol, coalesce(ad, '') as ad from public.radyoloji_sablon_makro
                 where sablon_id = @p0 order by id limit 6
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var kullanim = await b.TekAsync("""
                select count(*) as rapor,
                       (select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) || ' (' || count(*) || ')'
                          from public.radyoloji_rapor r2 join public.taraf t on t.id = r2.yazan_id
                         where r2.sablon_id = @p0 and r2.ekleme_tarihi > now() - interval '30 days'
                         group by t.id, t.unvan, t.ad, t.soyad order by count(*) desc limit 1) as "enCok"
                  from public.radyoloji_rapor r
                 where r.sablon_id = @p0 and r.ekleme_tarihi > now() - interval '30 days'
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { bolumler, alanlar, makrolar, kullanim, izlemeNo = baglam.IzlemeNo });
        });

        // Sürümler: geçmiş + her sürümle yazılmış rapor sayısı.
        grup.MapGet("/sablon/{id:int}/surumler", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var guncel = await b.TekDegerAsync<int?>("select surum from public.radyoloji_sablon where id = @p0", null, [id], iptal)
                         ?? throw GentegreHatasi.Bulunamadi("Şablon bulunamadı.");
            var satirlar = await b.ListeAsync("""
                select v.surum, v.tarih, v.kim, v.notu, v.guncel,
                       (select count(*) from public.radyoloji_rapor r where r.sablon_id = @p0 and r.sablon_surum = v.surum) as rapor
                  from (select s.surum, s.ekleme_tarihi as tarih,
                               coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as kim, s.notu, 0 as guncel
                          from public.radyoloji_sablon_surum s left join public.taraf t on t.id = s.ekleyen
                         where s.sablon_id = @p0
                        union all
                        select x.surum, coalesce(x.degistirme_tarihi, x.ekleme_tarihi),
                               coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), 'Güncel içerik', 1
                          from public.radyoloji_sablon x left join public.taraf t on t.id = coalesce(x.degistiren, x.ekleyen)
                         where x.id = @p0
                           and not exists (select 1 from public.radyoloji_sablon_surum s2 where s2.sablon_id = x.id and s2.surum = x.surum)) v
                 order by v.surum desc
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { guncel, satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // YENİ SÜRÜM: bugünkü içerik dondurulur, sayaç artar.
        grup.MapPost("/sablon/{id:int}/surum", async (int id, SurumIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var surum = await b.TekDegerAsync<int?>("select surum from public.radyoloji_sablon where id = @p0 for update", islem, [id], iptal)
                        ?? throw GentegreHatasi.Bulunamadi("Şablon bulunamadı.");
            await b.CalistirAsync($"""
                insert into public.radyoloji_sablon_surum (sablon_id, surum, notu, icerik, ekleyen)
                values (@p0, @p1, @p2, {IcerikSql}, @p3)
                on conflict (sablon_id, surum) do update set notu = excluded.notu, icerik = excluded.icerik
                """, islem, [id, surum, (istek.Notu ?? "").Trim(), baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.radyoloji_sablon set surum = surum + 1, degistiren = @p1, degistirme_tarihi = now() where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, 942, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { surum = $"{surum} -> {surum + 1}", not = istek.Notu }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { surum = surum + 1, izlemeNo = baglam.IzlemeNo });
        });

        // GERİ YÜKLE: eski sürümün içeriği bugünkü sürümün yerine yazılır.
        grup.MapPost("/sablon/{id:int}/geri-yukle/{surum:int}", async (int id, int surum, BaglamCozucu cozucu,
            VeriKaynagi veri, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var var_ = await b.TekDegerAsync<int?>(
                "select 1 from public.radyoloji_sablon_surum where sablon_id = @p0 and surum = @p1", islem, [id, surum], iptal);
            if (var_ is null) throw GentegreHatasi.Bulunamadi("Sürüm bulunamadı.");
            await b.CalistirAsync("""
                delete from public.radyoloji_sablon_bolum where sablon_id = @p0;
                delete from public.radyoloji_sablon_alan  where sablon_id = @p0;
                delete from public.radyoloji_sablon_makro where sablon_id = @p0;
                insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, zorunlu, yazdir, bakanlik_parca, ekleyen)
                select @p0, x.sira, x.baslik, x.varsayilan_metin, x.zorunlu, x.yazdir, x.bakanlik_parca, @p2
                  from public.radyoloji_sablon_surum s,
                       jsonb_to_recordset(s.icerik -> 'bolumler') as x(sira smallint, baslik varchar, varsayilan_metin text,
                                                                       zorunlu smallint, yazdir smallint, bakanlik_parca smallint)
                 where s.sablon_id = @p0 and s.surum = @p1;
                insert into public.radyoloji_sablon_alan (sablon_id, sira, alan_kod, alan_ad, tip, secenekler, zorunlu, rapora_bas,
                                                          birim, alt_sinir, ust_sinir, kalip, sifir_kalip, hedef_bolum, ekleyen)
                select @p0, x.sira, x.alan_kod, x.alan_ad, x.tip, x.secenekler, x.zorunlu, x.rapora_bas,
                       coalesce(x.birim, ''), x.alt_sinir, x.ust_sinir, coalesce(x.kalip, ''), coalesce(x.sifir_kalip, ''),
                       coalesce(x.hedef_bolum, ''), @p2
                  from public.radyoloji_sablon_surum s,
                       jsonb_to_recordset(s.icerik -> 'alanlar') as x(sira smallint, alan_kod varchar, alan_ad varchar, tip smallint,
                                                                      secenekler varchar, zorunlu smallint, rapora_bas smallint,
                                                                      birim varchar, alt_sinir numeric, ust_sinir numeric,
                                                                      kalip varchar, sifir_kalip varchar, hedef_bolum varchar)
                 where s.sablon_id = @p0 and s.surum = @p1;
                insert into public.radyoloji_sablon_makro (sablon_id, kisayol, ad, metin, hedef_bolum, ekleyen)
                select @p0, x.kisayol, x.ad, x.metin, x.hedef_bolum, @p2
                  from public.radyoloji_sablon_surum s,
                       jsonb_to_recordset(s.icerik -> 'makrolar') as x(kisayol varchar, ad varchar, metin text, hedef_bolum varchar)
                 where s.sablon_id = @p0 and s.surum = @p1;
                """, islem, [id, surum, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, 942, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { geriYuklenen = surum }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { izlemeNo = baglam.IzlemeNo });
        });

        // Kullanım: hekim bazında rapor / yazım süresi + yapılandırılmış alan dağılımı.
        grup.MapGet("/sablon/{id:int}/kullanim", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var hekimler = await b.ListeAsync("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '?') as hekim, count(*) as rapor,
                       round(avg(extract(epoch from (r.onay_tarihi - r.yazma_tarihi)) / 60.0)
                             filter (where r.onay_tarihi > r.yazma_tarihi), 1) as "ortDk",
                       count(*) filter (where r.onay_tarihi is not null) as onayli
                  from public.radyoloji_rapor r left join public.taraf t on t.id = r.yazan_id
                 where r.sablon_id = @p0 and r.ekleme_tarihi > now() - interval '30 days'
                 group by t.id, t.unvan, t.ad, t.soyad order by count(*) desc
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var dagilim = await b.ListeAsync("""
                select a.alan_ad as alan, coalesce(nullif(a.deger, ''), '(boş)') as deger, count(*) as adet
                  from public.radyoloji_rapor_alan a join public.radyoloji_rapor r on r.id = a.rapor_id
                 where r.sablon_id = @p0 and r.ekleme_tarihi > now() - interval '30 days'
                 group by a.alan_ad, coalesce(nullif(a.deger, ''), '(boş)') order by a.alan_ad, count(*) desc
                 limit 40
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { hekimler, dagilim, izlemeNo = baglam.IzlemeNo });
        });

        // Protokol özeti (liste sağ paneli): seriler, hazırlık, kontroller, sarf, cihazlar.
        grup.MapGet("/protokol/{id:int}/ozet", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var p = await b.TekAsync("""
                select coalesce(hz.ad, '') as tetkik, coalesce(p.seri_tarifi, '') as "seriKodu", p.sure_dk as "sureDk",
                       p.kontrast, coalesce(p.kontrast_ajan, '') as "kontrastAjan", coalesce(p.kontrast_doz, '') as "kontrastDoz",
                       coalesce(p.hazirlik_metni, '') as "hazirlikMetni", coalesce(p.ozel_uyari, '') as "ozelUyari",
                       p.hazirlik_once_dk as "hazirlikOnceDk"
                  from public.radyoloji_protokol p join public.hizmet hz on hz.id = p.hizmet_id where p.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Protokol bulunamadı.");
            var seriler = await b.ListeAsync(
                "select ad, faz from public.radyoloji_protokol_seri where protokol_id = @p0 order by sira, id",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var kontroller = await b.ListeAsync(
                "select ad, kural, engel from public.radyoloji_protokol_kontrol where protokol_id = @p0 order by sira, id",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var malzeme = await b.ListeAsync("""
                select coalesce(s.ad, '?') as ad, m.miktar from public.radyoloji_protokol_malzeme m
                  left join public.stok s on s.id = m.stok_id where m.protokol_id = @p0 order by m.sira, m.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var cihazlar = await b.ListeAsync("""
                select c.kod, c.ad, pc.sure_dk as "sureDk" from public.radyoloji_protokol_cihaz pc
                  join public.radyoloji_cihaz c on c.id = pc.cihaz_id where pc.protokol_id = @p0 order by c.kod
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { protokol = p, seriler, kontroller, malzeme, cihazlar, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Şablonun bugünkü içeriği (bölüm, alan, makro) tek jsonb; @p0 = sablon id.</summary>
    private const string IcerikSql = """
        jsonb_build_object(
          'bolumler', coalesce((select jsonb_agg(to_jsonb(b) - 'id' - 'sablon_id' - 'ekleyen' - 'ekleme_tarihi' - 'degistiren' - 'degistirme_tarihi' order by b.sira, b.id)
                                  from public.radyoloji_sablon_bolum b where b.sablon_id = @p0), '[]'::jsonb),
          'alanlar',  coalesce((select jsonb_agg(to_jsonb(a) - 'id' - 'sablon_id' - 'ekleyen' - 'ekleme_tarihi' - 'degistiren' - 'degistirme_tarihi' order by a.sira, a.id)
                                  from public.radyoloji_sablon_alan a where a.sablon_id = @p0), '[]'::jsonb),
          'makrolar', coalesce((select jsonb_agg(to_jsonb(m) - 'id' - 'sablon_id' - 'ekleyen' - 'ekleme_tarihi' - 'degistiren' - 'degistirme_tarihi' order by m.id)
                                  from public.radyoloji_sablon_makro m where m.sablon_id = @p0), '[]'::jsonb))
        """;

    public sealed record SurumIstegi(string? Notu);
}

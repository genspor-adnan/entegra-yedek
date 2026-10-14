using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE EPİKRİZİ (1100, mockup muayene_karti_v7) — bkz. <c>MuayeneUclari</c>.
///
/// <para><b>Ayrı kayıt:</b> epikriz muayenenin alanlarından TASLAK olarak
/// derlenir ama kaydedilen metin hekimin metnidir; imzadan sonra muayene
/// değişse de epikriz değişmez (hastaya / sevk kurumuna giden budur).</para>
///
/// <para><b>Taslak ücretsiz ve kuralla:</b> model çağrılmaz. Taslak kayda
/// yazılmaz; ekran "Karttan derle" ile alanlara koyar, hekim düzeltip kaydeder.</para>
///
/// <para><b>İmza kilitler:</b> imzalı epikriz yeniden yazılamaz (yatış
/// epikriziyle aynı kural - iki farklı metin, hangisinin verildiğini belirsizleştirir).</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void EpikrizUclariniEkle(RouteGroupBuilder grup)
    {
        // GET /api/muayene/{id}/epikriz - kayıt (yoksa null) + karttan derlenmiş taslak
        grup.MapGet("/{id:int}/epikriz", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var kayit = (await b.ListeAsync("""
                select e.id, e.sikayet, e.hikaye, e.bulgular, e.tani, e.tetkik_ozet as "tetkikOzet",
                       e.tedavi, e.oneriler, e.imza_durum as "imzaDurum", e.imza_zamani as "imzaZamani",
                       coalesce(e.degistirme_tarihi, e.ekleme_tarihi) as "kayitZamani"
                  from public.epikriz e where e.muayene_id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)).FirstOrDefault();

            var taslak = (await b.ListeAsync("""
                select coalesce(m.sikayet, '') as sikayet, coalesce(m.hikaye, '') as hikaye,
                       coalesce(m.bulgu_ozet, '') as bulgular,
                       coalesce((select string_agg(t.icd_kod || ' ' || coalesce(i.ad, '')
                                       || case when t.tur = 1 then ' (ana)' else '' end, ' · '
                                       order by t.tur, t.sira, t.id)
                                   from public.tani t left join public.icd i on i.kod = t.icd_kod
                                  where t.muayene_id = m.id), '') as tani,
                       -- TETKİK: yalnız ONAYLI sonuç (muayene sonuçlarındaki kural).
                       coalesce((select string_agg(lt.ad || ' ' || ls.deger_metin
                                       || coalesce(' ' || nullif(ls.birim, ''), '')
                                       || case when coalesce(ls.bayrak, '') <> '' then ' (' || ls.bayrak || ')' else '' end,
                                       ' · ' order by lt.ad)
                                   from public.lab_istem li
                                   join public.lab_istem_satir s on s.istem_id = li.id
                                   join public.lab_tetkik lt on lt.id = s.tetkik_id
                                   join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
                                  where li.durum <> 9
                                    and (li.belge_id = m.belge_id
                                         or exists (select 1 from public.muayene_istem mi
                                                     where mi.muayene_id = m.id and mi.hedef_tablo = 'lab_istem'
                                                       and mi.hedef_id = li.id))), '') as "tetkikOzet",
                       coalesce((select string_agg(rs.ilac_ad || coalesce(' ' || nullif(rs.doz, ''), '')
                                       || coalesce(' ' || nullif(rs.periyot, ''), ''), ' · ' order by rs.recete_id, rs.sira, rs.id)
                                   from public.recete_satir rs join public.recete r on r.id = rs.recete_id
                                  where r.muayene_id = m.id), '') as tedavi,
                       coalesce(m.karar, '')
                         || case when coalesce(m.kontrol_onerisi_gun, 0) > 0
                                 then E'\n' || 'Kontrol: ' || m.kontrol_onerisi_gun || ' gün sonra.' else '' end as oneriler
                  from public.muayene m where m.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)).FirstOrDefault()
                ?? throw GentegreHatasi.Bulunamadi();

            return Results.Ok(new { kayit, taslak });
        });

        // POST /api/muayene/{id}/epikriz - kaydet (muayene başına tek satır; imzalıysa reddedilir)
        grup.MapPost("/{id:int}/epikriz", async (
            int id, MuayeneEpikrizIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);

            var imzali = await b.TekDegerAsync<int?>(
                "select imza_durum from public.epikriz where muayene_id = @p0", null, [id], iptal);
            if (imzali == 1)
                throw GentegreHatasi.IsKurali("Epikriz imzalı; imzalı metin değiştirilemez.");

            var kayitId = await b.TekDegerAsync<int>("""
                insert into public.epikriz
                    (sube_id, muayene_id, sikayet, hikaye, bulgular, tani, tetkik_ozet, tedavi, oneriler, ekleyen)
                values (@p1, @p0, coalesce(@p2, ''), coalesce(@p3, ''), coalesce(@p4, ''), coalesce(@p5, ''),
                        coalesce(@p6, ''), coalesce(@p7, ''), coalesce(@p8, ''), @p9)
                on conflict (muayene_id) where muayene_id is not null do update
                   set sikayet = excluded.sikayet, hikaye = excluded.hikaye, bulgular = excluded.bulgular,
                       tani = excluded.tani, tetkik_ozet = excluded.tetkik_ozet, tedavi = excluded.tedavi,
                       oneriler = excluded.oneriler, degistiren = @p9, degistirme_tarihi = now()
                returning id
                """, null,
                [id, baglam.SubeId ?? 0, istek.Sikayet, istek.Hikaye, istek.Bulgular, istek.Tani,
                 istek.TetkikOzet, istek.Tedavi, istek.Oneriler, baglam.KullaniciId], iptal);

            return Results.Ok(new { id = kayitId, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/epikriz/imzala - kilitler. Ayrı adım: her kaydetme imza sayılmasın.
        grup.MapPost("/{id:int}/epikriz/imzala", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.epikriz
                   set imza_durum = 1, imza_zamani = now(), degistiren = @p1, degistirme_tarihi = now()
                 where muayene_id = @p0 and imza_durum = 0
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Epikriz yok ya da zaten imzalı. Önce kaydedin.");
            return Results.Ok(new { id, imzali = true, izlemeNo = baglam.IzlemeNo });
        });
    }

    public sealed record MuayeneEpikrizIstegi(string? Sikayet, string? Hikaye, string? Bulgular, string? Tani,
        string? TetkikOzet, string? Tedavi, string? Oneriler);
}

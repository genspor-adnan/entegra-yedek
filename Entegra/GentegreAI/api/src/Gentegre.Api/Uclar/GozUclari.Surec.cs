using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ HASTA SÜRECİ (mockup Ekranlar/Goz/goz_sureci_v2.html) — üç halka:
///
/// <para><b>1 · Kayıt açılışı.</b> Başvuru panoya alınır (Kabul istasyonu); hasta Ön tetkik
/// ya da Hekim muayenesi istasyonuna geçtiğinde, panoda "Muayeneyi aç" denince ya da hekim
/// "Muayeneye Al" dediğinde genel muayene + göz uzantısı TEK işlemde açılır. Aynı başvuruda
/// ikinci kayıt açılmaz. Tekniker ölçümleri böylece hekimin açacağı kayda yazılır.</para>
///
/// <para><b>2 · Tek kart.</b> Göz kartı genel muayenenin şikâyet / öykü, tanı, e-reçete, istem
/// ve ücret sekmelerini taşır; bu dosya öykü yazımını ve muayene → göz uzantısı bulmayı verir.</para>
///
/// <para><b>3 · Tamamla akışı yürütür.</b> Tamamla sonrası hasta görüntüleme istendiyse
/// Görüntüleme, yoksa Karar / işlem istasyonuna geçer.</para>
/// </summary>
public static partial class GozUclari
{
    public sealed record AkisEkleIstegi(int BelgeId);
    public sealed record OykuIstegi(string? Sikayet, string? Hikaye);

    /// <summary>
    /// Başvurunun genel muayenesini ve göz uzantısını açar (varsa olanı döner).
    /// Tür önerisi: hastanın önceki göz muayenesi varsa Kontrol (2), yoksa Tam muayene (1).
    /// </summary>
    internal static async Task<(int GozMuayeneId, int MuayeneId, bool Yeni)> GozMuayeneAcAsync(
        NpgsqlConnection b, NpgsqlTransaction islem, LogDeposu log, int belgeId, IstekBaglami baglam,
        CancellationToken iptal)
    {
        var bs = await b.TekAsync("""
            select b.taraf_id, bb.personel_id, bb.bolum_id, b.sube_id,
                   (select m.id from public.muayene m
                     where m.belge_id = b.id and m.ust_muayene_id is null order by m.id limit 1)
              from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
             where b.id = @p0 and b.tur = 19
             for update of b
            """, islem, [belgeId], o => new
        {
            TarafId = o.GetInt32(0),
            PersonelId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
            BolumId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
            SubeId = o.GetInt32(3),
            MuayeneId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
        }, iptal) ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");

        var yeniMuayene = bs.MuayeneId is null;
        // Numara ve kolonlar "Muayeneye Al" (hekim.al) ile aynı: iki yol iki ayrı kayıt biçimi üretmesin.
        var muayeneId = bs.MuayeneId ?? await b.TekDegerAsync<int>("""
            insert into public.muayene (belge_id, taraf_id, sube_id, bolum_id, personel_id,
                                        muayene_tarihi, tur, durum, ekleyen, muayene_no)
            values (@p0, @p1, @p2, @p3, @p4, now(), 1, 1, @p5,
                    public.fn_numara_kimlik_uret(902, @p2, 'muayene', 'muayene_no', current_date))
            returning id
            """, islem, [belgeId, bs.TarafId, bs.SubeId, bs.BolumId, bs.PersonelId, baglam.KullaniciId], iptal);

        var mevcut = await b.TekDegerAsync<int?>(
            "select id from public.goz_muayene where muayene_id = @p0", islem, [muayeneId], iptal);
        if (mevcut is int m) return (m, muayeneId, false);

        var gozId = await b.TekDegerAsync<int>("""
            insert into public.goz_muayene (sube_id, muayene_id, hasta_id, muayene_turu, ekleyen)
            values (@p0, @p1, @p2,
                    case when exists (select 1 from public.goz_muayene g where g.hasta_id = @p2) then 2 else 1 end, @p3)
            returning id
            """, islem, [bs.SubeId, muayeneId, bs.TarafId, baglam.KullaniciId], iptal);

        await log.YazAsync(b, islem, LogIslemi.Ekle, LogTabloMuayene, muayeneId, baglam.KullaniciId, baglam.SubeId,
            baglam.Ip, new { islem = "Göz muayenesi açıldı", gozMuayeneId = gozId, yeniMuayene },
            tarafId: bs.TarafId, iptal: iptal);
        return (gozId, muayeneId, true);
    }

    private static void SurecUclariniEkle(RouteGroupBuilder grup)
    {
        // PANOYA ALINABİLECEK BAŞVURULAR: son 24 saatin açık başvuruları, panoda açık satırı olmayanlar.
        grup.MapGet("/akis/basvurular", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select b.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as hasta,
                       coalesce(d.ad, '') as bolum, b.kayit_tarihi as zaman,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as hekim
                  from public.belge b
                  join public.belge_basvuru bb on bb.id = b.id
                  join public.taraf t on t.id = b.taraf_id
                  left join public.departman d on d.id = bb.bolum_id
                  left join public.taraf h on h.id = bb.personel_id
                 where b.tur = 19 and b.kayit_tarihi >= now() - interval '24 hours'
                   and (@p0::int is null or b.sube_id = @p0)
                   and not exists (select 1 from public.goz_ziyaret_istasyon i where i.belge_id = b.id and i.cikis is null)
                   and not exists (select 1 from public.muayene m where m.belge_id = b.id and m.tamamlanma is not null)
                 order by (lower(coalesce(d.ad, '')) like '%göz%') desc, b.kayit_tarihi desc
                 limit 100
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // BAŞVURUYU PANOYA AL: Kabul istasyonunda açık satır (sıra numarası günün sırası).
        grup.MapPost("/akis/ekle", async (AkisEkleIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var bs = await b.TekAsync("""
                select b.taraf_id, b.sube_id from public.belge b join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0 and b.tur = 19 for update of b
                """, islem, [istek.BelgeId], o => new { Hasta = o.GetInt32(0), Sube = o.GetInt32(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");
            var acik = await b.TekDegerAsync<long>(
                "select count(*) from public.goz_ziyaret_istasyon where belge_id = @p0 and cikis is null", islem, [istek.BelgeId], iptal);
            if (acik > 0) throw GentegreHatasi.IsKurali("Hasta zaten panoda.");
            var id = await b.TekDegerAsync<int>("""
                insert into public.goz_ziyaret_istasyon (sube_id, belge_id, hasta_id, istasyon, ekleyen, sira_no)
                values (@p0, @p1, @p2, 1, @p3,
                        coalesce((select max(i.sira_no) from public.goz_ziyaret_istasyon i
                                   where i.sube_id = @p0 and (i.giris at time zone 'Europe/Istanbul')::date
                                                           = (now() at time zone 'Europe/Istanbul')::date), 0) + 1)
                returning id
                """, islem, [bs.Sube, istek.BelgeId, bs.Hasta, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Ekle, LogTabloGozAkis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "Göz ünitesine alındı", belgeId = istek.BelgeId }, tarafId: bs.Hasta, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, izlemeNo = baglam.IzlemeNo });
        });

        // PANODAN MUAYENEYİ AÇ: kayıt yoksa açar (istasyon satırının başvurusu).
        grup.MapPost("/akis/{id:int}/muayene", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var belgeId = await b.TekDegerAsync<int?>(
                "select belge_id from public.goz_ziyaret_istasyon where id = @p0", islem, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Pano satırı bulunamadı.");
            var (gozId, muayeneId, yeni) = await GozMuayeneAcAsync(b, islem, log, belgeId, baglam, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { gozMuayeneId = gozId, muayeneId, yeni, izlemeNo = baglam.IzlemeNo });
        });

        // MUAYENE → GÖZ UZANTISI. GET yalnız bulur; POST başvuru göz ünitesindeyse (panoda satırı
        //   olmuş) uzantıyı açar - göz dışı bölümün muayenesine göz kartı açılmaz.
        grup.MapGet("/muayene-uzanti/{muayeneId:int}", async (int muayeneId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            var gozId = await veri.TekDegerAsync<int?>(
                "select id from public.goz_muayene where muayene_id = @p0", [muayeneId], iptal);
            return Results.Ok(new { gozMuayeneId = gozId, izlemeNo = baglam.IzlemeNo });
        });
        grup.MapPost("/muayene-uzanti/{muayeneId:int}", async (int muayeneId, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var belgeId = await b.TekDegerAsync<int?>("""
                select m.belge_id from public.muayene m
                 where m.id = @p0 and m.ust_muayene_id is null
                   and exists (select 1 from public.goz_ziyaret_istasyon i where i.belge_id = m.belge_id)
                """, islem, [muayeneId], iptal);
            if (belgeId is null)
            {
                var var = await b.TekDegerAsync<int?>(
                    "select id from public.goz_muayene where muayene_id = @p0", islem, [muayeneId], iptal);
                return Results.Ok(new { gozMuayeneId = var, izlemeNo = baglam.IzlemeNo });
            }
            var (gozId, _, yeni) = await GozMuayeneAcAsync(b, islem, log, belgeId.Value, baglam, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { gozMuayeneId = (int?)gozId, yeni, izlemeNo = baglam.IzlemeNo });
        });

        // ŞİKÂYET & ÖYKÜ (göz kartı sekmesi): genel muayenenin alanları, ikinci kopya yok.
        grup.MapGet("/muayene/{id:int}/oyku", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                select m.id as "muayeneId", coalesce(m.sikayet, '') as sikayet, coalesce(m.hikaye, '') as hikaye,
                       coalesce(m.ozgecmis_notu, '') as ozgecmis, coalesce(m.soygecmis_notu, '') as soygecmis,
                       (m.tamamlanma is not null) as kapali
                  from public.goz_muayene gm join public.muayene m on m.id = gm.muayene_id where gm.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");
            return Results.Ok(o);
        });
        grup.MapPost("/muayene/{id:int}/oyku", async (int id, OykuIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Degistir);
            baglam.YazmaIste();
            var sikayet = (istek.Sikayet ?? "").Trim();
            var hikaye = (istek.Hikaye ?? "").Trim();
            if (sikayet.Length > 4000 || hikaye.Length > 4000)
                throw GentegreHatasi.Dogrulama("Şikâyet / hikâye en çok 4000 karakter.");
            await using var b = await veri.AcAsync(iptal);
            var m = await b.TekAsync("""
                select m.id, gm.hasta_id, (m.tamamlanma is not null) from public.goz_muayene gm
                  join public.muayene m on m.id = gm.muayene_id where gm.id = @p0
                """, null, [id], o => new { Id = o.GetInt32(0), Hasta = o.GetInt32(1), Kapali = o.GetBoolean(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");
            if (m.Kapali) throw GentegreHatasi.IsKurali("Tamamlanmış muayenenin öyküsü değiştirilemez.");
            await b.CalistirAsync("""
                update public.muayene set sikayet = @p1, hikaye = @p2, degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, null, [m.Id, sikayet, hikaye, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloMuayene, m.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { sikayet, hikaye }, tarafId: m.Hasta, iptal: iptal);
            return Results.Ok(new { id, izlemeNo = baglam.IzlemeNo });
        });

        // TAMAMLA SONRASI İSTASYON: istenmiş (çekilmemiş) görüntüleme varsa Görüntüleme (4),
        //   yoksa Karar / işlem (5). Panoda açık satırı olmayan muayenede bir şey yapmaz.
        grup.MapPost("/muayene/{id:int}/sonraki-istasyon", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var s = await b.TekAsync("""
                select i.id, i.istasyon, i.hasta_id,
                       exists (select 1 from public.goz_goruntuleme g where g.muayene_id = m.id and g.durum = 1) as goruntu
                  from public.goz_muayene gm
                  join public.muayene m on m.id = gm.muayene_id
                  join public.goz_ziyaret_istasyon i on i.belge_id = m.belge_id and i.cikis is null
                 where gm.id = @p0
                 order by i.giris desc limit 1
                 for update of i
                """, islem, [id], o => new { Id = o.GetInt32(0), Ist = (int)o.GetInt16(1), Hasta = o.GetInt32(2), Goruntu = o.GetBoolean(3) }, iptal);
            if (s is null) return Results.Ok(new { istasyon = (int?)null, izlemeNo = baglam.IzlemeNo });
            var hedef = s.Goruntu ? 4 : 5;
            if (hedef == s.Ist) return Results.Ok(new { istasyon = (int?)hedef, izlemeNo = baglam.IzlemeNo });
            await b.CalistirAsync("update public.goz_ziyaret_istasyon set cikis = now() where id = @p0", islem, [s.Id], iptal);
            var yeniId = await b.TekDegerAsync<int>("""
                insert into public.goz_ziyaret_istasyon
                    (sube_id, belge_id, hasta_id, istasyon, oda, personel_id, dilatasyon_zamani, dilatasyon_ilac, sira_no, ekleyen)
                select sube_id, belge_id, hasta_id, @p1, '', null, dilatasyon_zamani, dilatasyon_ilac, sira_no, @p2
                  from public.goz_ziyaret_istasyon where id = @p0
                returning id
                """, islem, [s.Id, (short)hedef, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloGozAkis, yeniId, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { istasyon = IstasyonAdi[hedef], neden = "Muayene tamamlandı" }, tarafId: s.Hasta, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { istasyon = (int?)hedef, ad = IstasyonAdi[hedef], izlemeNo = baglam.IzlemeNo });
        });
    }
}

using System.Text.Json;
using System.Text.Json.Nodes;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İŞYERİ HEKİMLİĞİ (741) — liste/kart dışı uçlar: firma panosu, firma kartı
/// (bölümler, süre, sağlık gözetimi özeti), çalışan kartı (muayeneler, aşı,
/// olay, formlar, tetkik paketi), Ek-2 muayene açma (form motoru isteği:
/// SMS ile çalışan bölümü ya da iç ekran), muayeneyi işleme (form cevabından
/// kanaat/koşul/sonraki tarih), periyodik takvim, toplu gönderim, SGK bildirimi.
/// Mockuplar Ekranlar/ISG.
/// </summary>
public static class IsgUclari
{
    // 1299 (757): 1204 eczane imhasinin (EczaneUclari).
    private const int LogMuayene = 1299;
    private const int LogOlay    = 1303;

    public sealed record MuayeneAcIstegi(int? Tur, int? Kanal, int? HekimId, string? Telefon);
    public sealed record TopluIstegi(int[] CalisanIds, int? Tur, int? Kanal);
    public sealed record SgkIstegi(DateOnly? Tarih);

    public static void IsgUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/isg").WithTags("İSG").RequireAuthorization();

        // ---------------------------------------------------------- pano ----
        grup.MapGet("/pano", async (int? hekimId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var firmalar = await b.ListeAsync("select row_to_json(f)::text from public.v_isg_firma f where f.durum = 1 and (@p0::int is null or f.hekim_id = @p0) order by f.firma_adi",
                null, [hekimId], o => o.GetString(0), iptal);
            var ozet = await b.TekAsync("""
                select (select count(*) from public.isg_firma where durum = 1),
                       (select count(*) from public.isg_calisan where durum = 1),
                       (select count(*) from public.v_isg_calisan c where c.durum = 1 and c.kalan_gun between 0 and 30),
                       (select count(*) from public.v_isg_calisan c where c.durum = 1 and c.kalan_gun < 0),
                       (select count(*) from public.isg_olay o where o.tur = 1 and date_trunc('month', o.tarih) = date_trunc('month', now())),
                       (select count(*) from public.v_isg_olay o where o.sgk_gecikti = 1 and o.durum = 1),
                       (select count(*) from public.isg_muayene m where m.durum = 1),
                       (select coalesce(sum(public.fn_isg_aylik_dk(f.id)), 0) from public.isg_firma f where f.durum = 1),
                       (select coalesce(sum(m.sure_dk), 0) from public.isg_muayene m where m.durum = 2 and date_trunc('month', m.tarih) = date_trunc('month', now()))
                       + (select coalesce(sum(z.sure_dk), 0) from public.isg_ziyaret z where date_trunc('month', z.tarih) = date_trunc('month', now()))
                """, null, [], o => new
            {
                firma = o.GetInt64(0), calisan = o.GetInt64(1), vadeGelen = o.GetInt64(2), vadeGecen = o.GetInt64(3), kazaAy = o.GetInt64(4),
                sgkGeciken = o.GetInt64(5), acikMuayene = o.GetInt64(6), planDk = o.GetInt64(7), gercekDk = o.GetInt64(8),
            }, iptal);
            return Results.Content(JsonSerializer.Serialize(new { ozet, firmalar = firmalar.Select(x => JsonNode.Parse(x)).ToArray() }), "application/json");
        });

        // ----------------------------------------------------- firma kartı ----
        grup.MapGet("/firma/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.firma", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var firma = await b.TekAsync("select row_to_json(f)::text from public.v_isg_firma f where f.id = @p0", null, [id], o => o.GetString(0), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Firma bulunamadı.");
            var bolumler = await b.ListeAsync("""
                select b.id, b.ad, b.calisan_sayisi, coalesce(nullif(b.maruziyet, '')::jsonb, '[]'::jsonb)::text, b.tetkik_paketi, b.periyot_ay,
                       (select count(*) from public.isg_calisan c where c.bolum_id = b.id and c.durum = 1),
                       (select count(*) from public.v_isg_calisan c where c.bolum_id = b.id and c.durum = 1 and c.kalan_gun < 0)
                  from public.isg_firma_bolum b where b.firma_id = @p0 order by b.ad
                """, null, [id], o => new { id = o.GetInt32(0), ad = o.GetString(1), calisanSayisi = o.GetInt32(2), maruziyet = JsonNode.Parse(o.GetString(3)), tetkikPaketi = o.GetString(4), periyotAy = (int)o.GetInt16(5), aktif = o.GetInt64(6), vadeGecen = o.GetInt64(7) }, iptal);
            var aylar = await b.ListeAsync("""
                with ay as (select date_trunc('month', current_date) - make_interval(months => g) as bas from generate_series(0, 5) g)
                select to_char(ay.bas, 'YYYY-MM'),
                       (select coalesce(sum(m.sure_dk), 0) from public.isg_muayene m where m.firma_id = @p0 and m.durum = 2 and date_trunc('month', m.tarih) = ay.bas),
                       (select coalesce(sum(z.sure_dk), 0) from public.isg_ziyaret z where z.firma_id = @p0 and z.tur in (1, 5) and date_trunc('month', z.tarih) = ay.bas),
                       (select coalesce(sum(z.sure_dk), 0) from public.isg_ziyaret z where z.firma_id = @p0 and z.tur = 3 and date_trunc('month', z.tarih) = ay.bas),
                       (select coalesce(sum(z.sure_dk), 0) from public.isg_ziyaret z where z.firma_id = @p0 and z.tur = 2 and date_trunc('month', z.tarih) = ay.bas),
                       (select count(*) from public.isg_muayene m where m.firma_id = @p0 and m.durum = 2 and date_trunc('month', m.tarih) = ay.bas)
                  from ay order by ay.bas desc
                """, null, [id], o => new { ay = o.GetString(0), muayeneDk = o.GetInt64(1), ziyaretDk = o.GetInt64(2), egitimDk = o.GetInt64(3), kurulDk = o.GetInt64(4), muayene = o.GetInt64(5) }, iptal);
            // SAĞLIK GÖZETİMİ ÖZETİ: işverene giden yalnız sayı ve kanaat dağılımı.
            var ozet = await b.TekAsync("""
                select (select count(*) from public.isg_muayene m where m.firma_id = @p0 and m.durum = 2 and m.tarih >= date_trunc('year', current_date)),
                       (select count(*) from public.isg_muayene m where m.firma_id = @p0 and m.durum = 2 and m.kanaat = 1 and m.tarih >= date_trunc('year', current_date)),
                       (select count(*) from public.isg_muayene m where m.firma_id = @p0 and m.durum = 2 and m.kanaat = 2 and m.tarih >= date_trunc('year', current_date)),
                       (select count(*) from public.isg_muayene m where m.firma_id = @p0 and m.durum = 2 and m.kanaat = 3 and m.tarih >= date_trunc('year', current_date)),
                       (select count(*) from public.v_isg_calisan c where c.firma_id = @p0 and c.durum = 1 and c.kalan_gun < 0),
                       (select count(*) from public.isg_olay o where o.firma_id = @p0 and o.tur = 1 and o.tarih >= date_trunc('year', current_date)),
                       (select count(*) from public.isg_olay o where o.firma_id = @p0 and o.tur = 2 and o.tarih >= date_trunc('year', current_date)),
                       (select count(*) from public.v_isg_ziyaret z where z.firma_id = @p0 and z.termin_gecti = 1)
                """, null, [id], o => new { muayene = o.GetInt64(0), calisir = o.GetInt64(1), kosullu = o.GetInt64(2), calisamaz = o.GetInt64(3), vadeGecen = o.GetInt64(4), kaza = o.GetInt64(5), meslekHastaligi = o.GetInt64(6), terminGecen = o.GetInt64(7) }, iptal);
            var ziyaretler = await b.ListeAsync("select row_to_json(z)::text from public.v_isg_ziyaret z where z.firma_id = @p0 order by z.tarih desc limit 10", null, [id], o => o.GetString(0), iptal);
            return Results.Content(JsonSerializer.Serialize(new { firma = JsonNode.Parse(firma), bolumler, aylar, ozet, ziyaretler = ziyaretler.Select(x => JsonNode.Parse(x)).ToArray() }), "application/json");
        });

        // --------------------------------------------------- çalışan kartı ----
        grup.MapGet("/calisan/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.calisan", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var calisan = await b.TekAsync("select row_to_json(c)::text from public.v_isg_calisan c where c.id = @p0", null, [id], o => o.GetString(0), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çalışan bulunamadı.");
            var muayeneler = await b.ListeAsync("select row_to_json(m)::text from public.v_isg_muayene m where m.calisan_id = @p0 order by m.tarih desc, m.id desc", null, [id], o => o.GetString(0), iptal);
            var asilar = await b.ListeAsync("select row_to_json(a)::text from public.v_isg_asi a where a.calisan_id = @p0 order by a.tarih desc", null, [id], o => o.GetString(0), iptal);
            var olaylar = await b.ListeAsync("select row_to_json(o)::text from public.v_isg_olay o where o.calisan_id = @p0 order by o.tarih desc", null, [id], o => o.GetString(0), iptal);
            var formlar = await b.ListeAsync("select row_to_json(i)::text from public.v_form_istek i where i.hasta_id = (select hasta_id from public.isg_calisan where id = @p0) and i.kaynak_tur = 8 and i.durum <> 8 order by i.ekleme_tarihi desc", null, [id], o => o.GetString(0), iptal);
            var tibbi = await b.TekAsync("""
                select (select string_agg(coalesce(nullif(a.etken, ''), a.etken_madde, ''), ' · ') from public.hasta_alerji a where a.hasta_id = c.hasta_id and a.aktif = 1),
                       (select string_agg(coalesce(nullif(k.tani_ad, ''), k.icd_kod, ''), ' · ') from public.hasta_kronik_tani k where k.hasta_id = c.hasta_id and k.durum = 1),
                       (select string_agg(coalesce(i.ilac_ad, ''), ' · ') from public.hasta_ilac i where i.hasta_id = c.hasta_id and i.aktif = 1)
                  from public.isg_calisan c where c.id = @p0
                """, null, [id], o => new { alerji = o.IsDBNull(0) ? "" : o.GetString(0), kronik = o.IsDBNull(1) ? "" : o.GetString(1), ilac = o.IsDBNull(2) ? "" : o.GetString(2) }, iptal);
            var maruziyetAdlari = await b.ListeAsync("select d.deger, d.ad from public.kod_liste l join public.kod_deger d on d.liste_id = l.id where l.kod = 'isg.maruziyet' order by d.deger", null, [], o => new { kod = (int)o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Content(JsonSerializer.Serialize(new
            {
                calisan = JsonNode.Parse(calisan), muayeneler = muayeneler.Select(x => JsonNode.Parse(x)).ToArray(), asilar = asilar.Select(x => JsonNode.Parse(x)).ToArray(),
                olaylar = olaylar.Select(x => JsonNode.Parse(x)).ToArray(), formlar = formlar.Select(x => JsonNode.Parse(x)).ToArray(), tibbi, maruziyetAdlari,
            }), "application/json");
        });

        // ------------------------------------------------- Ek-2 muayene aç ----
        // Kanal 3 = SMS (çalışan bölümü telefondan, hekim iç ekranda tamamlar),
        //   1/2 = iç ekran / tablet. Aynı çalışanın açık muayenesi varsa o döner.
        grup.MapPost("/calisan/{id:int}/muayene-ac", async (int id, MuayeneAcIstegi g, VeriKaynagi veri, BildirimDeposu bildirim, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.muayene", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var y = await MuayeneAcAsync(b, bildirim, log, baglam, ctx, id, g.Tur ?? 2, g.Kanal ?? 3, g.HekimId, g.Telefon, iptal);
            return Results.Ok(y);
        });

        // Formu tamamlanmış muayeneyi işle (kanaat vb. isg_muayene'ye; form motoru
        //   tamamlarken de çağrılır - buradaki elle tetiklemedir).
        grup.MapPost("/muayene/{id:int}/isle", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.muayene", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var fid = await b.TekDegerAsync<int?>("select form_istek_id from public.isg_muayene where id = @p0", null, [id], iptal)
                ?? throw GentegreHatasi.IsKurali("Bu muayenenin Ek-2 formu yok; kanaati kartta yazın.");
            var sonuc = await MuayeneyiIsleAsync(b, fid, baglam.KullaniciId, iptal);
            if (sonuc is null) throw GentegreHatasi.IsKurali("Ek-2 formu henüz tamamlanmadı (hekim bölümü).");
            await log.YazAsync(LogIslemi.Degistir, LogMuayene, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, sonuc, iptal: iptal);
            return Results.Ok(sonuc);
        });

        grup.MapPost("/muayene/{id:int}/iptal", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.muayene", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("update public.isg_muayene set durum = 3, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 1", null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız açık muayene iptal edilir.");
            await b.CalistirAsync("update public.form_istek set durum = 8, belirtec_ozet = '', oturum_anahtari = '' where id = (select form_istek_id from public.isg_muayene where id = @p0) and durum in (1, 2, 3)", null, [id], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogMuayene, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { iptal = true }, iptal: iptal);
            return Results.Ok(new { id, durum = 3 });
        });

        // ------------------------------------------------ periyodik takvim ----
        grup.MapGet("/takvim", async (int? firmaId, int? bolumId, int? gun, string? tur, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.takvim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ufuk = gun ?? 30;
            var satirlar = await b.ListeAsync("""
                select row_to_json(c)::text from public.v_isg_calisan c
                 where c.durum = 1 and (@p0::int is null or c.firma_id = @p0) and (@p1::int is null or c.bolum_id = @p1)
                   and (case @p3 when 'gecen' then c.kalan_gun < 0 when 'giris' then c.muayene_sayisi = 0 else c.kalan_gun <= @p2 end)
                 order by c.kalan_gun, c.calisan_adi
                """, null, [firmaId, bolumId, ufuk, tur ?? ""], o => o.GetString(0), iptal);
            var aylar = await b.ListeAsync("""
                with ay as (select date_trunc('month', current_date) + make_interval(months => g) as bas from generate_series(0, 5) g)
                select to_char(ay.bas, 'YYYY-MM'), (select count(*) from public.v_isg_calisan c where c.durum = 1 and (@p0::int is null or c.firma_id = @p0) and date_trunc('month', c.vade) = ay.bas)
                  from ay order by ay.bas
                """, null, [firmaId], o => new { ay = o.GetString(0), sayi = o.GetInt64(1) }, iptal);
            var gecen = await b.TekDegerAsync<long>("select count(*) from public.v_isg_calisan c where c.durum = 1 and (@p0::int is null or c.firma_id = @p0) and c.kalan_gun < 0", null, [firmaId], iptal);
            return Results.Content(JsonSerializer.Serialize(new { gecen, aylar, satirlar = satirlar.Select(x => JsonNode.Parse(x)).ToArray() }), "application/json");
        });

        // Toplu: seçilen çalışanlara Ek-2 muayenesi aç + SMS (çalışan bölümü).
        grup.MapPost("/takvim/toplu", async (TopluIstegi g, VeriKaynagi veri, BildirimDeposu bildirim, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.muayene", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var acilan = 0; var hatalar = new List<string>();
            foreach (var cid in g.CalisanIds.Distinct())
            {
                try { await MuayeneAcAsync(b, bildirim, log, baglam, ctx, cid, g.Tur ?? 2, g.Kanal ?? 3, null, null, iptal); acilan++; }
                catch (GentegreHatasi h) { hatalar.Add($"#{cid}: {h.Message}"); }
            }
            return Results.Ok(new { acilan, hatalar });
        });

        // ------------------------------------------------------- olay / SGK ----
        grup.MapPost("/olay/{id:int}/sgk", async (int id, SgkIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.olay", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("update public.isg_olay set sgk_bildirim = coalesce(@p1, current_date), degistiren = @p2, degistirme_tarihi = now() where id = @p0", null, [id, g.Tarih, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogOlay, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { sgkBildirim = g.Tarih?.ToString() ?? "bugün" }, iptal: iptal);
            return Results.Ok(new { id });
        });
        grup.MapPost("/olay/{id:int}/kapat", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("isg.olay", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("update public.isg_olay set durum = 2, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogOlay, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { kapandi = true }, iptal: iptal);
            return Results.Ok(new { id, durum = 2 });
        });
    }

    // ============================================================ yardımcı ====
    /// <summary>Muayene + Ek-2 form isteği açar (form motoru gönderimi ile).</summary>
    private static async Task<object> MuayeneAcAsync(NpgsqlConnection b, BildirimDeposu bildirim, LogDeposu log, IstekBaglami baglam, HttpContext ctx,
                                                    int calisanId, int tur, int kanal, int? hekimId, string? telefon, CancellationToken iptal)
    {
        var c = await b.TekAsync("select c.hasta_id, c.firma_id, f.hekim_id, c.durum from public.isg_calisan c join public.isg_firma f on f.id = c.firma_id where c.id = @p0", null, [calisanId],
            o => new { hastaId = o.GetInt32(0), firmaId = o.GetInt32(1), hekimId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2), durum = o.GetInt16(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Çalışan bulunamadı.");
        if (c.durum != 1) throw GentegreHatasi.IsKurali("Ayrılmış çalışana muayene açılmaz.");
        var acik = await b.TekAsync("select id, form_istek_id from public.isg_muayene where calisan_id = @p0 and durum = 1 order by id desc limit 1", null, [calisanId],
            o => new { id = o.GetInt32(0), formId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1) }, iptal);
        if (acik is not null) return new { id = acik.id, formIstekId = acik.formId, mevcut = true };

        var id = await b.TekDegerAsync<int>("""
            insert into public.isg_muayene (calisan_id, hasta_id, firma_id, tur, tarih, hekim_id, durum, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, current_date, @p4, 1, @p5, @p6) returning id
            """, null, [calisanId, c.hastaId, c.firmaId, (short)tur, hekimId ?? c.hekimId, baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
        // Ek-2 form isteği: bağlam İSG (8), kaynak = muayene.
        var gonder = await FormUclari.GonderCalistirAsync(new FormUclari.GonderIstegi("ek2", null, c.hastaId, 8, id, kanal, telefon, null, null, $"Ek-2 muayene #{id}"),
                                                          b, bildirim, log, baglam, ctx, iptal);
        await b.CalistirAsync("update public.isg_muayene set form_istek_id = @p1 where id = @p0", null, [id, gonder.id], iptal);
        await log.YazAsync(LogIslemi.Ekle, LogMuayene, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { tur, kanal, formIstekId = gonder.id }, tarafId: c.hastaId, iptal: iptal);
        return new { id, formIstekId = gonder.id, gonder.kod, gonder.baglanti, gonder.bildirimId, mevcut = false };
    }

    /// <summary>
    /// Ek-2 formu tamamlanınca isg_muayene'ye kanaat/koşul/tanı/sonraki/sevk/
    /// tetkik özeti yazar ve muayeneyi kapatır. Form tamamlanmamışsa null.
    /// FormUclari cevap ucundan (kaynak_tur 8) ve /muayene/{id}/isle'den çağrılır.
    /// </summary>
    public static async Task<object?> MuayeneyiIsleAsync(NpgsqlConnection b, int formIstekId, int kullaniciId, CancellationToken iptal)
    {
        var d = await b.TekAsync("select i.durum, i.cevap::text, m.id from public.form_istek i join public.isg_muayene m on m.form_istek_id = i.id where i.id = @p0", null, [formIstekId],
            o => new { durum = o.GetInt16(0), cevap = o.GetString(1), muayeneId = o.GetInt32(2) }, iptal);
        if (d is null || d.durum != 4) return null;
        var c = JsonNode.Parse(d.cevap) as JsonObject ?? new JsonObject();
        var kanaatMetin = c["kanaat"]?.ToString() ?? "";
        short kanaat = kanaatMetin.StartsWith("Çalışam") ? (short)3 : kanaatMetin.StartsWith("Şu") ? (short)2 : kanaatMetin.StartsWith("Çalış") ? (short)1 : (short)0;
        DateOnly? sonraki = DateOnly.TryParse(c["sonraki"]?.ToString(), out var sd) ? sd : null;
        var sevk = c["sevk"] is JsonValue sv && (sv.ToString() is "true" or "Evet");
        var tetkik = string.Join(" · ", new[] { ("Odyometri", c["odyometri"]), ("SFT", c["sft"]), ("PA", c["pa"]), ("EKG", c["ekg"]), ("Lab", c["lab"]), ("Portör", c["portor"]) }
            .Where(x => x.Item2 is not null && x.Item2.ToString() != "İstenmedi").Select(x => $"{x.Item1}: {x.Item2}"));
        var tetkikNot = c["tetkik_not"]?.ToString() ?? "";
        await b.CalistirAsync("""
            update public.isg_muayene
               set kanaat = @p1, kosul = @p2, tani = @p3, sonraki_tarih = @p4, sevk = @p5, tetkik_ozet = @p6,
                   durum = 2, degistiren = @p7, degistirme_tarihi = now()
             where id = @p0
            """, null, [d.muayeneId, kanaat, (c["kosul"]?.ToString() ?? "")[..Math.Min(400, (c["kosul"]?.ToString() ?? "").Length)], (c["tani"]?.ToString() ?? "")[..Math.Min(200, (c["tani"]?.ToString() ?? "").Length)],
                        sonraki, sevk ? (short)1 : (short)0, (tetkik + (tetkikNot != "" ? $" — {tetkikNot}" : ""))[..Math.Min(400, (tetkik + (tetkikNot != "" ? $" — {tetkikNot}" : "")).Length)], kullaniciId], iptal);
        return new { muayeneId = d.muayeneId, kanaat, kanaatMetin, sonraki, sevk };
    }
}

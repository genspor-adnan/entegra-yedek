using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇAĞRI MERKEZİ — giden arama: geri arama listesi (söz + kaçan + kampanya adımı)
/// ve kampanya (kişi üret, çalıştır, durdur, kişi sonucu).
/// </summary>
public static partial class CagriUclari
{
    private static void GidenUclari(RouteGroupBuilder grup)
    {
        // ------------------------------------------------- geri arama listesi ----
        // Üç kaynak tek listede: (a) "geri aranacak" sözü (cagri.geri_arama), (b) kaçan çağrı
        //   (durum 6, aynı numara sonradan aranmamış), (c) kampanya kişisi (aranacak = 1).
        grup.MapGet("/geri-arama", async (string? tur, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.giden", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await JsonListeAsync(b, """
                with l as (
                  select 'soz' as kaynak, c.id as cagri_id, null::int as kisi_id, null::int as kampanya_id, c.taraf_id, c.taraf_adi as ad, c.arayan_no as telefon,
                         coalesce(c.konu_adi, '') || case when c.alt_konu_adi <> '' then ' › ' || c.alt_konu_adi else '' end as konu, c.notu as notu,
                         c.geri_arama as zaman, c.agent_id, c.agent_adi, 'Geri arama sözü' as kaynak_adi, c.gorev_id
                    from public.v_cagri c where c.sonuc = 2 and c.geri_arama is not null and c.geri_arama_tamam = 0
                  union all
                  select 'kacan', c.id, null, null, c.taraf_id, c.taraf_adi, c.arayan_no, coalesce(c.kuyruk_adi, ''),
                         'Kaçan çağrı · ' || c.bekleme_sn || ' sn bekledi', c.baslama, null, '', 'Kaçan çağrı', null
                    from public.v_cagri c
                   where c.durum = 6 and c.geri_arama_tamam = 0 and c.baslama >= current_date - 2
                     and not exists (select 1 from public.cagri g where g.yon = 2 and g.baslama > c.baslama and public.fn_cagri_tel_anahtar(g.arayan_no) = public.fn_cagri_tel_anahtar(c.arayan_no))
                  union all
                  select 'kampanya', x.cagri_id, x.id, p.id, x.taraf_id, x.ad, x.telefon, 'Kampanya › ' || x.kampanya_adi, x.ozet,
                         coalesce(x.son_deneme, x.ekleme_tarihi), null, '', 'Kampanya adımı', null
                    from public.v_cagri_kampanya_kisi x join public.cagri_kampanya p on p.id = x.kampanya_id
                   where p.durum = 1 and x.aranacak = 1
                )
                select json_build_object('kaynak', l.kaynak, 'kaynakAdi', l.kaynak_adi, 'cagriId', l.cagri_id, 'kisiId', l.kisi_id, 'kampanyaId', l.kampanya_id, 'tarafId', l.taraf_id, 'ad', l.ad,
                                         'telefon', l.telefon, 'konu', l.konu, 'notu', l.notu, 'zaman', l.zaman, 'agentId', l.agent_id, 'agentAdi', l.agent_adi,
                                         'gecikmis', case when l.zaman < now() - interval '1 hour' then 1 else 0 end, 'gorevId', l.gorev_id)::text
                  from l
                 where case @p0 when 'gecikmis' then l.zaman < now() - interval '1 hour'
                                when 'benim' then l.agent_id = @p1
                                when 'tumu' then true
                                else l.zaman < current_date + 1 end
                 order by l.zaman
                 limit 300
                """, [tur ?? "bugun", baglam.KullaniciId], iptal);
            var ozet = await b.TekAsync("""
                select (select count(*) from public.cagri c where c.sonuc = 2 and c.geri_arama is not null and c.geri_arama_tamam = 0 and c.geri_arama < current_date + 1)
                     + (select count(*) from public.v_cagri_kampanya_kisi x join public.cagri_kampanya p on p.id = x.kampanya_id where p.durum = 1 and x.aranacak = 1),
                       (select count(*) from public.cagri where yon = 2 and baslama >= current_date),
                       (select count(*) from public.cagri where yon = 2 and baslama >= current_date and durum = 8),
                       (select count(*) from public.cagri where sonuc = 2 and baslama >= current_date),
                       (select count(*) from public.cagri where durum = 6 and baslama >= current_date and geri_arama_tamam = 0)
                """, null, [], o => new { aranacak = o.GetInt64(0), arandi = o.GetInt64(1), ulasilamadi = o.GetInt64(2), soz = o.GetInt64(3), kacan = o.GetInt64(4) }, iptal);
            return Json(new { ozet, satirlar });
        });

        grup.MapPost("/geri-arama/{cagriId:int}/tamam", async (int cagriId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.giden", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("update public.cagri set geri_arama_tamam = 1, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [cagriId, baglam.KullaniciId], iptal);
            await b.CalistirAsync("update public.gorev set durum = 2, tamamlanma = now() where id = (select gorev_id from public.cagri where id = @p0) and tur = 2 and durum < 2", null, [cagriId], iptal);
            return Results.Ok(new { cagriId });
        });

        // ------------------------------------------------------- kampanya ----
        grup.MapGet("/kampanyalar", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            return Json(await JsonListeAsync(b, "select row_to_json(p)::text from public.v_cagri_kampanya p order by p.durum, p.id desc limit 200", [], iptal));
        });
        grup.MapGet("/kampanya/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kampanya = await JsonTekAsync(b, "select row_to_json(p)::text from public.v_cagri_kampanya p where p.id = @p0", [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kampanya bulunamadı.");
            var kisiler = await JsonListeAsync(b, "select row_to_json(x)::text from public.v_cagri_kampanya_kisi x where x.kampanya_id = @p0 order by x.durum, x.id limit 500", [id], iptal);
            return Json(new { kampanya, kisiler });
        });

        // Kişi listesini kaynaktan üret (yeni kişiler eklenir; var olanlar korunur).
        grup.MapPost("/kampanya/{id:int}/uret", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await b.TekAsync("select kaynak, parametre, sube_id from public.cagri_kampanya where id = @p0", null, [id],
                o => new { kaynak = o.GetString(0), parametre = o.GetString(1), subeId = o.GetInt32(2) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Kampanya bulunamadı.");
            var esik = decimal.TryParse(p.parametre.Replace(',', '.'), NumberStyles.Any, CultureInfo.InvariantCulture, out var e) ? e : 500m;
            var sql = KampanyaKaynakSql(p.kaynak);
            if (sql is null) return Results.Ok(new { eklenen = 0, atlanan = 0, not_ = "Serbest liste: kişiler kartın 'Kişiler' detayından eklenir." });
            var adaylar = await b.ListeAsync(sql, null, [id, esik], o => new
            {
                tarafId = SayiN(o, 0), ad = o.GetString(1), tel = o.GetString(2), kaynakTur = o.GetString(3), kaynakId = o.GetInt32(4), ozet = o.GetString(5),
            }, iptal);
            int eklenen = 0, atlanan = 0;
            foreach (var a in adaylar)
            {
                if (string.IsNullOrWhiteSpace(a.tel)) { atlanan++; continue; }
                var n = await b.CalistirAsync("""
                    insert into public.cagri_kampanya_kisi (kampanya_id, taraf_id, ad, telefon, kaynak_tur, kaynak_id, ozet, durum, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, 1, @p7, @p8)
                    on conflict (kampanya_id, kaynak_tur, kaynak_id) where kaynak_id > 0 do nothing
                    """, null, [id, a.tarafId, Kirp(a.ad, 150), Kirp(a.tel, 30), a.kaynakTur, a.kaynakId, Kirp(a.ozet, 200), p.subeId, baglam.KullaniciId], iptal);
                if (n > 0) eklenen++; else atlanan++;
            }
            await log.YazAsync(LogIslemi.Degistir, LogKampanya, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { uret = true, eklenen, atlanan }, iptal: iptal);
            return Results.Ok(new { eklenen, atlanan, not_ = "" });
        });

        // 1. adım: bekleyen kişilere şablon mesajı (bildirim kuyruğu); şablonsuz kampanyada
        //   kişiler doğrudan geri arama listesine düşer. Kampanya "çalışıyor" olur.
        grup.MapPost("/kampanya/{id:int}/calistir", async (int id, VeriKaynagi veri, BildirimDeposu bildirim, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sablon = await b.TekDegerAsync<string>("select sablon_kodu from public.cagri_kampanya where id = @p0", null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kampanya bulunamadı.");
            await b.CalistirAsync("update public.cagri_kampanya set durum = 1, baslama = coalesce(baslama, current_date), degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId], iptal);
            int gonderilen = 0, hata = 0;
            if (sablon != "")
            {
                var kurum = KurumAdi(baglam);
                var kisiler = await b.ListeAsync("select id, taraf_id, ad, telefon, ozet from public.cagri_kampanya_kisi where kampanya_id = @p0 and durum = 1 order by id", null, [id],
                    o => new { id = o.GetInt32(0), tarafId = SayiN(o, 1), ad = o.GetString(2), tel = o.GetString(3), ozet = o.GetString(4) }, iptal);
                foreach (var k in kisiler)
                {
                    try
                    {
                        // Şablonların değişken adları farklı (tarih/tetkik/tutar); özet metni hepsine verilir.
                        var bid = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(sablon, null, k.tel, new Dictionary<string, string>
                        {
                            ["ad"] = k.ad, ["kurum"] = kurum, ["tarih"] = k.ozet, ["bolum"] = "", ["tetkik"] = k.ozet, ["baglanti"] = "", ["tutar"] = k.ozet, ["saat"] = "",
                        }, TarafId: k.tarafId, KaynakTur: KaynakTurKampanyaKisi, KaynakId: k.id), baglam.KullaniciId, baglam.SubeId, iptal);
                        await b.CalistirAsync("update public.cagri_kampanya_kisi set durum = 2, deneme = deneme + 1, son_deneme = now(), bildirim_id = @p1 where id = @p0", null, [k.id, bid], iptal);
                        gonderilen++;
                    }
                    catch (InvalidOperationException) { hata++; }
                }
            }
            await log.YazAsync(LogIslemi.Degistir, LogKampanya, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { calistir = true, gonderilen, hata }, iptal: iptal);
            return Results.Ok(new { gonderilen, hata, dogrudanArama = sablon == "" });
        });

        grup.MapPost("/kampanya/{id:int}/durdur", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("update public.cagri_kampanya set durum = 2, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 1", null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { id, durum = 2 });
        });

        grup.MapPost("/kampanya-kisi/{id:int}/sonuc", async (int id, KisiSonucIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.giden", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("""
                update public.cagri_kampanya_kisi
                   set durum = @p1, sonuc = @p2, cagri_id = coalesce(@p3, cagri_id), deneme = case when @p1 = 3 then deneme + 1 else deneme end, son_deneme = now(),
                       degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.Durum, Kirp(g.Sonuc, 200), g.CagriId, baglam.KullaniciId], iptal);
            // Randevu hatırlatmada "onayladı" → randevu onaylı kalır; "iptal etti" → randevu iptal (4).
            if (g.Durum == 6)
                await b.CalistirAsync("update public.randevu set durum = 4 where id = (select kaynak_id from public.cagri_kampanya_kisi where id = @p0 and kaynak_tur = 'randevu') and durum = 1", null, [id], iptal);
            return Results.Ok(new { id, g.Durum });
        });
    }

    /// <summary>
    /// Kampanya kaynağı → aday sorgusu. Kolonlar sabit: taraf_id, ad, telefon,
    /// kaynak_tur, kaynak_id, özet. @p0 kampanya, @p1 bakiye eşiği. Serbest liste
    /// için null (kişiler karttan girilir).
    /// </summary>
    private static string? KampanyaKaynakSql(string kaynak) => kaynak switch
    {
        "randevu_yarin" => $"""
            select t.id, {TarafAdi}, {TarafTel}, 'randevu', r.id,
                   to_char(r.baslangic, 'DD.MM HH24:MI') || ' ' || coalesce(d.ad, '') || case when h.ad is not null then ' · ' || h.ad else '' end
              from public.randevu r join public.taraf t on t.id = r.hasta_id
              left join public.v_departman_lookup d on d.id = r.bolum left join public.v_hekim_lookup h on h.id = r.hekim_id
             where r.baslangic::date = current_date + 1 and r.durum = 1
            """,
        "sonuc_hazir" => $"""
            select t.id, {TarafAdi}, {TarafTel}, 'lab_istem', li.id,
                   'Lab sonucu hazır · ' || coalesce(li.istem_no, '') || ' · ' || to_char(li.sonuc_tarihi, 'DD.MM')
              from public.lab_istem li join public.taraf t on t.id = li.taraf_id
             where li.sonuc_tarihi >= now() - interval '7 days'
            """,
        "taburcu_anket" => $"""
            select t.id, {TarafAdi}, {TarafTel}, 'randevu', r.id,
                   'Ziyaret ' || to_char(r.baslangic, 'DD.MM') || ' ' || coalesce(d.ad, '')
              from public.randevu r join public.taraf t on t.id = r.hasta_id left join public.v_departman_lookup d on d.id = r.bolum
             where r.durum = 2 and r.baslangic >= current_date - 3
            """,
        "vadesi_gecen" => $"""
            select t.id, {TarafAdi}, {TarafTel}, 'taraf', t.id,
                   'Bakiye ' || to_char(b.bakiye, 'FM999G999G990D00') || ' TL'
              from (select e.taraf_id, sum(e.yerel_borc) - sum(e.yerel_alacak) as bakiye from public.v_cari_ekstre e group by e.taraf_id) b
              join public.taraf t on t.id = b.taraf_id
             where b.bakiye > @p1
            """,
        "isg_periyodik" => """
            select c.hasta_id, c.calisan_adi, c.cep_tel, 'isg_calisan', c.id,
                   'Periyodik muayene vadesi ' || to_char(c.vade, 'DD.MM.YYYY') || ' · ' || c.firma_adi
              from public.v_isg_calisan c where c.durum = 1 and c.kalan_gun <= 30
            """,
        _ => null,
    };
}

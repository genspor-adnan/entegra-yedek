using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SEVK (1110) — mockup Ekranlar/Muayene/sevk_karti_v2.html · sevk_listesi_v2.html (sade).
///
/// Kart (KartKatalogu.Sevk) yalnız taslağı yazar; burada kart dışı geçişler var: gönder
/// (zorunlu alanlar, durum 2, muayenenin sevk kolonları ve çıkış şekli senkron yazılır -
/// e-Nabız / epikriz okuyucuları değişmesin), iptal (gerekçeli), sonuç döndü. Medula sevk
/// takip no ŞİMDİLİK alınmaz (canlı Medula yok): medula_sevk_no boş kalır.
/// </summary>
public static class SevkUclari
{
    private const int LogSevk = 1550;
    private const string Yetki = "muayene.sevk";

    public sealed record GerekceIstegi(string? Gerekce);

    private sealed record Sevk(int Id, string No, short Durum, short Tur, int? MuayeneId, string TesisKodu,
                               string TesisAd, int? KlinikId, int? HedefBolumId, short Neden, short Ulasim, string Notu);

    private static async Task<Sevk> OkuAsync(NpgsqlConnection b, NpgsqlTransaction tx, int id, CancellationToken iptal)
        => await b.TekAsync("""
            select id, no, durum, tur, muayene_id, tesis_kodu, tesis_ad, klinik_id, hedef_bolum_id, neden, ulasim, notu
              from public.sevk where id = @p0 for update
            """, tx, [id], o => new Sevk(o.GetInt32(0), o.GetString(1), o.GetInt16(2), o.GetInt16(3),
                o.IsDBNull(4) ? null : o.GetInt32(4), o.GetString(5), o.GetString(6),
                o.IsDBNull(7) ? null : o.GetInt32(7), o.IsDBNull(8) ? null : o.GetInt32(8),
                o.GetInt16(9), o.GetInt16(10), o.GetString(11)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Sevk bulunamadı.");

    /// <summary>Kart dışı durum geçişi: DB tetiğinin kapısı (yalnız bu işlemde).</summary>
    private static Task KapiAc(NpgsqlConnection b, NpgsqlTransaction tx, CancellationToken iptal)
        => b.CalistirAsync("select set_config('sevk.uc', '1', true)", tx, [], iptal);

    public static void SevkUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/sevk").WithTags("Sevk").RequireAuthorization();

        // KAPSAM: liste sekmelerinin süzgeci (giden: hekim ben / bölümüm · gelen: hedef bölüm benim).
        grup.MapGet("/kapsam", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Gor);
            var bolumler = (await veri.ListeAsync("select * from public.fn_kullanici_bolumleri(@p0)", [baglam.KullaniciId],
                o => o.GetInt32(0), iptal)).Distinct().ToArray();
            return Results.Ok(new { ben = baglam.KullaniciId, bolumler });
        });

        // ÖZET (kart şeridi + ön izleme): hasta, hekim, tanı ve otomatik ekler.
        grup.MapGet("/{id:int}/ozet", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Gor);
            var o = await veri.TekAsync("""
                select s.no, coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''), coalesce(h.kod, ''),
                       coalesce(case coalesce(th.cinsiyet, 0) when 1 then 'E' when 2 then 'K' else '' end || ' '
                                || coalesce(extract(year from age(th.dogum_tarihi))::int::text, ''), ''),
                       coalesce(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::varchar(120), ''), coalesce(b.ad, ''),
                       coalesce((select t.icd_kod || ' ' || coalesce(i.ad, '') from public.tani t
                                   left join public.icd i on i.kod = t.icd_kod
                                  where t.muayene_id = s.muayene_id order by t.tur, t.id limit 1), ''),
                       exists (select 1 from public.epikriz e where e.muayene_id = s.muayene_id),
                       (select count(*) from public.lab_istem li
                         where li.belge_id = s.belge_id and s.belge_id is not null and li.durum <> 0)::int,
                       (select count(*) from public.radyoloji_istem ri
                         where ri.belge_id = s.belge_id and s.belge_id is not null and coalesce(ri.durum, 0) <> 0)::int,
                       s.medula_sevk_no, s.durum
                  from public.sevk s
                  join public.taraf h on h.id = s.taraf_id
                  left join public.taraf_hasta th on th.id = h.id
                  left join public.taraf hk on hk.id = s.hekim_id
                  left join public.departman b on b.id = s.bolum_id
                 where s.id = @p0
                """, [id], r => new
                {
                    no = r.GetString(0), hasta = r.GetString(1), hastaKod = r.GetString(2), cinsiyetYas = r.GetString(3).Trim(),
                    hekim = r.GetString(4), bolum = r.GetString(5), tani = r.GetString(6).Trim(),
                    epikriz = r.GetBoolean(7), lab = r.GetInt32(8), goruntuleme = r.GetInt32(9),
                    medulaSevkNo = r.GetString(10), durum = (int)r.GetInt16(11),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Sevk bulunamadı.");
            return Results.Ok(o);
        });

        // GÖNDER ("İmzala ve gönder"): zorunlu alanlar, durum 2. Muayenenin sevk kolonları ve
        //   çıkış şekli de yazılır (kurum dışı -> 3 "Kurum Dışına Sevk", kurum içi -> 4).
        grup.MapPost("/{id:int}/gonder", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var s = await OkuAsync(b, tx, id, iptal);
            if (s.Durum != 1) throw GentegreHatasi.IsKurali("Yalnız taslak sevk gönderilir.");
            var hatalar = new List<AlanHatasi>();
            if (s.Tur == 1 && s.TesisAd.Trim().Length == 0 && s.TesisKodu.Trim().Length == 0)
                hatalar.Add(new AlanHatasi("tesisAd", "Sevk edilen tesisi yazın."));
            if (s.Tur == 1 && s.KlinikId is null) hatalar.Add(new AlanHatasi("klinikId", "Kliniği seçin."));
            if (s.Tur != 1 && s.HedefBolumId is null) hatalar.Add(new AlanHatasi("hedefBolumId", "Bölümü seçin."));
            if (s.Notu.Trim().Length == 0) hatalar.Add(new AlanHatasi("notu", "Karşı hekime notu yazın."));
            if (hatalar.Count > 0) throw GentegreHatasi.Dogrulama("Sevk eksik.", [.. hatalar]);

            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("""
                update public.sevk set durum = 2, imza_zamani = now(), sevk_zamani = now(), degistiren = @p1 where id = @p0
                """, tx, [id, baglam.KullaniciId], iptal);
            // MUAYENE SENKRONU: okuyucular (e-Nabız, epikriz, özet) muayenenin kolonlarından okur.
            //   Tamamlanmış muayeneye dokunulmaz.
            var muayeneYazildi = s.MuayeneId is not null && await b.CalistirAsync("""
                update public.muayene m
                   set yonlendirme = case @p1 when 1 then 2 when 2 then 1 else 3 end,
                       sevk_tesis_kodu = @p2,
                       sevk_klinik_kod = coalesce((select d.skrs_kod from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                                                    where l.kod = 'klinik.kod' and d.dil = 0 and d.deger = @p3), ''),
                       sevk_neden = @p4, sevk_notu = @p5,
                       ambulans = case @p6 when 3 then 1 when 2 then 2 else 3 end,
                       cikis_sekli = case @p1 when 1 then 3 when 2 then 4 else m.cikis_sekli end,
                       degistiren = @p7, degistirme_tarihi = now()
                 where m.id = @p0 and m.durum not in (0, 3)
                """, tx, [s.MuayeneId, s.Tur, s.TesisKodu, s.KlinikId, s.Neden, s.Notu, s.Ulasim, baglam.KullaniciId], iptal) > 0;
            await tx.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogSevk, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Gönderildi" }, iptal: iptal);
            // MEDULA: canlı sevk takip no alınmıyor (Medula modülü simülasyon kapısında) - kayıt
            //   gönderildi sayılır; takip no gelince medula_sevk_no yazılacak.
            return Results.Ok(new { id, mesaj = $"{s.No} gönderildi." + (muayeneYazildi ? "" : " (Muayene tamamlanmış - muayene kaydına yazılmadı.)") });
        });

        // İPTAL (gerekçeli): taslak, gönderilmiş ya da gönderilemeyen sevk.
        grup.MapPost("/{id:int}/iptal", async (int id, GerekceIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            var gerekce = (g.Gerekce ?? "").Trim();
            if (gerekce.Length > 400) gerekce = gerekce[..400];
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var s = await OkuAsync(b, tx, id, iptal);
            if (s.Durum is not (1 or 2 or 9)) throw GentegreHatasi.IsKurali("Bu sevk iptal edilemez.");
            if (s.Durum != 1 && gerekce.Length == 0)
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.", new AlanHatasi("gerekce", "Gerekçe yazın."));
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("update public.sevk set durum = 0, iptal_gerekce = @p1, degistiren = @p2 where id = @p0",
                tx, [id, gerekce, baglam.KullaniciId], iptal);
            await tx.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogSevk, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "İptal", gerekce }, iptal: iptal);
            return Results.Ok(new { id, mesaj = $"{s.No} iptal edildi." });
        });

        // SONUÇ DÖNDÜ: karşı kurumun / bölümün sonucu geldi; sevk kapanır.
        grup.MapPost("/{id:int}/sonuc", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var s = await OkuAsync(b, tx, id, iptal);
            if (s.Durum != 2) throw GentegreHatasi.IsKurali("Yalnız gönderilmiş sevkin sonucu işlenir.");
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("update public.sevk set durum = 3, sonuc_zamani = now(), degistiren = @p1 where id = @p0",
                tx, [id, baglam.KullaniciId], iptal);
            await tx.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogSevk, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Sonuç döndü" }, iptal: iptal);
            return Results.Ok(new { id, mesaj = $"{s.No} sonucu işlendi." });
        });

        // MUAYENEDEN SEVK: hasta, başvuru, hekim ve bölüm muayeneden; TASLAK açılır.
        yol.MapPost("/api/muayene/{muayeneId:int}/sevk", async (int muayeneId, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var m = await b.TekAsync("select taraf_id, belge_id, sube_id, bolum_id, personel_id, durum from public.muayene where id = @p0",
                null, [muayeneId], o => new
                {
                    taraf = o.GetInt32(0), belge = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), sube = o.GetInt32(2),
                    bolum = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), hekim = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                    durum = o.GetInt16(5),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");
            if (m.durum == 0) throw GentegreHatasi.IsKurali("İptal edilmiş muayeneden sevk yapılamaz.");
            var id = await b.TekDegerAsync<int>("""
                insert into public.sevk (sube_id, belge_id, taraf_id, muayene_id, hekim_id, bolum_id, durum, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 1, @p6) returning id
                """, null, [m.sube, m.belge, m.taraf, muayeneId, m.hekim ?? baglam.KullaniciId, m.bolum, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Ekle, LogSevk, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { muayeneId, durum = "Taslak" }, iptal: iptal);
            return Results.Ok(new { id, mesaj = "Sevk açıldı (taslak)." });
        }).WithTags("Sevk").RequireAuthorization();
    }
}

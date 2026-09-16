using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SEANS KARTI (708) — mockup <c>dis_seans_kaydi.html</c>: yapılan işlemler
/// LİSTESİ (seans → işlem 1:N), seçili işlemin uygulama ayrıntısı, seans
/// geneli not/anestezi, sarf, ücret özeti. Generic kart yerine özel sayfa:
/// "plan satırından ekle" hastanın açık plan satırlarını, "bu seansta
/// tamamlandı" seans bitirme kuralını taşır - düz detay tablosu bunu
/// anlatamıyordu.
/// </summary>
public static partial class DisUclari
{
    public sealed record SeansGuncelleIstegi(int? HekimId, int? AsistanId, int? UnitId, string? UygulamaNotu, string? Komplikasyon,
                                             string? HastayaTalimat, string? SonrakiPlan, string? AnesteziTur, string? AnesteziIlac,
                                             string? AnesteziDoz, string? SterilizasyonPaket);
    public sealed record SeansIslemEkleIstegi(int? PlanSatirId, int? HizmetId, int? DisNo, string? Yuzeyler, bool? Tamamlandi);
    public sealed record SeansIslemGuncelleIstegi(bool? Tamamlandi, string? UygulamaNotu, string? CalismaBoyu, string? Komplikasyon,
                                                  string? SonrakiPlan, string? NotMetin, int? DisNo, string? Yuzeyler);

    private static void SeansKartUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/seans/{id:int}", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.seans", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var seans = await b.TekAsync("""
                select s.id, s.hasta_id, t.unvan, extract(year from age(current_date, th.dogum_tarihi))::int as yas,
                       s.hekim_id, coalesce(h.unvan, ''), s.asistan_id, coalesce(a.unvan, ''), s.unit_id, coalesce(u.kod || ' · ' || u.ad, ''),
                       s.plan_id, coalesce(p.plan_no, ''), s.randevu_id, s.belge_id, coalesce(bl.belge_no, ''),
                       s.baslangic, s.bitis, s.sure_dk, s.durum, s.anestezi_tur, s.anestezi_ilac, s.anestezi_doz, s.anestezi_saat,
                       s.uygulama_notu, s.komplikasyon, s.hastaya_talimat, s.sonraki_plan, s.sterilizasyon_paket,
                       (select string_agg(coalesce(nullif(x.etken, ''), x.etken_madde), ', ') from public.hasta_alerji x where x.hasta_id = s.hasta_id and x.aktif = 1) as alerji,
                       (select to_char(o.baslangic, 'DD.MM.YYYY') || ': ' || nullif(o.uygulama_notu, '') from public.dis_seans o
                         where o.hasta_id = s.hasta_id and o.id <> s.id and o.durum = 2 order by o.baslangic desc limit 1) as onceki_not,
                       (select count(*) from public.dis_seans o where o.hasta_id = s.hasta_id and o.id < s.id)::int as onceki_seans
                  from public.dis_seans s
                  join public.taraf t on t.id = s.hasta_id
                  left join public.taraf_hasta th on th.id = s.hasta_id
                  left join public.taraf h on h.id = s.hekim_id
                  left join public.taraf a on a.id = s.asistan_id
                  left join public.dis_unit u on u.id = s.unit_id
                  left join public.dis_tedavi_plani p on p.id = s.plan_id
                  left join public.belge bl on bl.id = s.belge_id
                 where s.id = @p0
                """, null, [id], o => new
            {
                id = o.GetInt32(0), hastaId = o.GetInt32(1), hasta = o.GetString(2), yas = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                hekimId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), hekim = o.GetString(5),
                asistanId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6), asistan = o.GetString(7),
                unitId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8), unit = o.GetString(9),
                planId = o.IsDBNull(10) ? (int?)null : o.GetInt32(10), planNo = o.GetString(11),
                randevuId = o.IsDBNull(12) ? (int?)null : o.GetInt32(12), belgeId = o.IsDBNull(13) ? (int?)null : o.GetInt32(13), belgeNo = o.GetString(14),
                baslangic = o.GetDateTime(15), bitis = o.IsDBNull(16) ? (DateTime?)null : o.GetDateTime(16), sureDk = (int)o.GetInt16(17),
                durum = (int)o.GetInt16(18), anesteziTur = o.GetString(19), anesteziIlac = o.GetString(20), anesteziDoz = o.GetString(21),
                anesteziSaat = o.IsDBNull(22) ? null : o.GetValue(22).ToString(),
                uygulamaNotu = o.GetString(23), komplikasyon = o.GetString(24), hastayaTalimat = o.GetString(25), sonrakiPlan = o.GetString(26),
                sterilizasyonPaket = o.GetString(27), alerji = o.Metin("alerji"), oncekiNot = o.Metin("onceki_not"), oncekiSeans = o.GetInt32(30),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");

            var islemler = await b.ListeAsync("""
                select i.id, i.plan_satir_id, i.hizmet_id, hz.ad, i.dis_no, i.yuzeyler, i.seans_no, i.tamamlandi,
                       coalesce(ps.seans_sayisi, 1), coalesce(ps.yapilan_seans, 0), coalesce(ps.ucret_kurali, 1), coalesce(ps.net, 0), coalesce(ps.durum, 0),
                       coalesce(ps.sira, 0), coalesce(p.plan_no, ''), i.uygulama_notu, i.calisma_boyu, i.komplikasyon, i.sonraki_plan, i.not_metin,
                       coalesce((select bs.tutar_kdvli from public.belge_satir bs where bs.id = i.belge_satir_id), 0),
                       coalesce(hz.sut_kodu, ''), coalesce(hz.kod, ''), coalesce(ps.lab_gerekir, 0)
                  from public.dis_seans_islem i
                  join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.dis_tedavi_plani_satir ps on ps.id = i.plan_satir_id
                  left join public.dis_tedavi_plani p on p.id = ps.plan_id
                 where i.seans_id = @p0 order by i.id
                """, null, [id], o => new
            {
                id = o.GetInt32(0), planSatirId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), hizmetId = o.GetInt32(2), islem = o.GetString(3),
                disNo = (int)o.GetInt16(4), yuzeyler = o.GetString(5), seansNo = (int)o.GetInt16(6), tamamlandi = o.GetInt16(7) == 1,
                seansSayisi = (int)o.GetInt16(8), yapilanSeans = (int)o.GetInt16(9), ucretKurali = (int)o.GetInt16(10), net = o.GetDecimal(11),
                satirDurum = (int)o.GetInt16(12), planSira = (int)o.GetInt16(13), planNo = o.GetString(14), uygulamaNotu = o.GetString(15),
                calismaBoyu = o.GetString(16), komplikasyon = o.GetString(17), sonrakiPlan = o.GetString(18), notMetin = o.GetString(19),
                ucret = o.GetDecimal(20), sutKodu = o.GetString(21), kod = o.GetString(22), labGerekir = o.GetInt16(23) == 1,
            }, iptal);

            // Hastanın açık plan satırları (bu seansa eklenmemiş olanlar) - "plan satırından ekle".
            var acikSatirlar = await b.ListeAsync("""
                select s.id, s.dis_no, s.yuzeyler, hz.ad, s.seans_sayisi, s.yapilan_seans, s.net, s.durum, p.plan_no, s.sira, s.faz
                  from public.dis_tedavi_plani_satir s
                  join public.dis_tedavi_plani p on p.id = s.plan_id
                  join public.hizmet hz on hz.id = s.hizmet_id
                 where p.hasta_id = @p0 and p.durum in (1, 2, 3, 4) and s.durum in (1, 2, 5)
                   and not exists (select 1 from public.dis_seans_islem i where i.seans_id = @p1 and i.plan_satir_id = s.id)
                 order by s.faz, s.sira
                """, null, [seans.hastaId, id], o => new
            {
                id = o.GetInt32(0), disNo = (int)o.GetInt16(1), yuzeyler = o.GetString(2), islem = o.GetString(3),
                seansSayisi = (int)o.GetInt16(4), yapilanSeans = (int)o.GetInt16(5), net = o.GetDecimal(6), durum = (int)o.GetInt16(7),
                planNo = o.GetString(8), sira = (int)o.GetInt16(9), faz = (int)o.GetInt16(10),
            }, iptal);

            var sarf = await b.ListeAsync("""
                select f.id, st.ad, f.miktar, f.birim, f.kaynak, f.maliyet
                  from public.dis_seans_sarf f join public.stok st on st.id = f.stok_id where f.seans_id = @p0 order by f.id
                """, null, [id], o => new { id = o.GetInt32(0), malzeme = o.GetString(1), miktar = o.GetDecimal(2), birim = o.GetString(3),
                                            kaynak = (int)o.GetInt16(4), maliyet = o.GetDecimal(5) }, iptal);

            var planOzet = seans.planId is int pid ? await b.TekAsync("""
                select p.net,
                       (select coalesce(sum(s.net), 0) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum = 3),
                       (select coalesce(sum(k.odenen), 0) from public.dis_odeme_plani o join public.dis_odeme_taksit k on k.odeme_plani_id = o.id where o.plan_id = p.id),
                       (select o.id from public.dis_odeme_plani o where o.plan_id = p.id)
                  from public.dis_tedavi_plani p where p.id = @p0
                """, null, [pid], o => new { net = o.GetDecimal(0), yapilan = o.GetDecimal(1), tahsil = o.GetDecimal(2),
                                             odemePlaniId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3) }, iptal) : null;

            return Results.Ok(new { seans, islemler, acikSatirlar, sarf, planOzet, simdi = DateTime.UtcNow });
        });

        grup.MapPatch("/seans/{id:int}", async (
            int id, SeansGuncelleIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.seans", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var durum = await b.TekDegerAsync<short?>("select durum from public.dis_seans where id = @p0", null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");
            if (durum != 1) throw GentegreHatasi.IsKurali("Kapanmış seans değiştirilmez.");
            await b.CalistirAsync("""
                update public.dis_seans
                   set hekim_id = coalesce(@p1, hekim_id), asistan_id = coalesce(@p2, asistan_id), unit_id = coalesce(@p3, unit_id),
                       uygulama_notu = coalesce(@p4, uygulama_notu), komplikasyon = coalesce(@p5, komplikasyon),
                       hastaya_talimat = coalesce(@p6, hastaya_talimat), sonraki_plan = coalesce(@p7, sonraki_plan),
                       anestezi_tur = coalesce(@p8, anestezi_tur), anestezi_ilac = coalesce(@p9, anestezi_ilac), anestezi_doz = coalesce(@p10, anestezi_doz),
                       anestezi_saat = case when @p9 is not null and anestezi_saat is null then localtime else anestezi_saat end,
                       sterilizasyon_paket = coalesce(@p11, sterilizasyon_paket),
                       degistiren = @p12, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.HekimId, g.AsistanId, g.UnitId, g.UygulamaNotu, g.Komplikasyon, g.HastayaTalimat, g.SonrakiPlan,
                            g.AnesteziTur, g.AnesteziIlac, g.AnesteziDoz, g.SterilizasyonPaket, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloSeans, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { alan = "seans" }, iptal: iptal);
            return Results.NoContent();
        });

        // İşlem ekle: plan satırından (seans no = yapılan + 1) ya da plan dışı hizmet.
        grup.MapPost("/seans/{id:int}/islem", async (
            int id, SeansIslemEkleIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.seans", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync("select durum, hasta_id from public.dis_seans where id = @p0", null, [id],
                o => new { durum = o.GetInt16(0), hastaId = o.GetInt32(1) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");
            if (s.durum != 1) throw GentegreHatasi.IsKurali("Kapanmış seansa işlem eklenmez.");
            int islemId;
            if (g.PlanSatirId is int psid)
            {
                var var = await b.TekDegerAsync<int?>("select id from public.dis_seans_islem where seans_id = @p0 and plan_satir_id = @p1", null, [id, psid], iptal);
                if (var is not null) throw GentegreHatasi.IsKurali("Bu plan satırı seansta zaten var.");
                var ps = await b.TekAsync("""
                    select s.hizmet_id, s.dis_no, s.yuzeyler, s.yapilan_seans, s.seans_sayisi, s.durum, p.hasta_id
                      from public.dis_tedavi_plani_satir s join public.dis_tedavi_plani p on p.id = s.plan_id where s.id = @p0
                    """, null, [psid], o => new { hizmetId = o.GetInt32(0), disNo = o.GetInt16(1), yuzey = o.GetString(2),
                        yapilan = o.GetInt16(3), toplam = o.GetInt16(4), durum = o.GetInt16(5), hastaId = o.GetInt32(6) }, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Plan satırı bulunamadı.");
                if (ps.hastaId != s.hastaId) throw GentegreHatasi.IsKurali("Plan satırı başka hastanın.");
                if (ps.durum is 3 or 4) throw GentegreHatasi.IsKurali("Yapılmış / iptal plan satırı seansa alınmaz.");
                // Tek seanslık iş varsayılan "tamamlandı"; çok seanslıda son seans değilse işaretsiz.
                var tamam = g.Tamamlandi ?? (ps.yapilan + 1 >= ps.toplam);
                islemId = await b.TekDegerAsync<int>("""
                    insert into public.dis_seans_islem (seans_id, plan_satir_id, hizmet_id, dis_no, yuzeyler, seans_no, tamamlandi, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8) returning id
                    """, null, [id, psid, ps.hizmetId, ps.disNo, ps.yuzey, (short)(ps.yapilan + 1), (short)(tamam ? 1 : 0),
                                baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
            }
            else
            {
                var hizmetId = g.HizmetId ?? throw GentegreHatasi.Dogrulama("Plan satırı ya da hizmet gerekli.");
                if (g.DisNo is int dn && dn != 0) DisNoDogrula(dn, sifirOlur: true);
                islemId = await b.TekDegerAsync<int>("""
                    insert into public.dis_seans_islem (seans_id, hizmet_id, dis_no, yuzeyler, seans_no, tamamlandi, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, 1, @p4, @p5, @p6) returning id
                    """, null, [id, hizmetId, (short)(g.DisNo ?? 0), YuzeyNormalle(g.Yuzeyler), (short)(g.Tamamlandi == false ? 0 : 1),
                                baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
            }
            await log.YazAsync(LogIslemi.Ekle, LogTabloSeans, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islemId, g.PlanSatirId, g.HizmetId }, tarafId: s.hastaId, iptal: iptal);
            return Results.Ok(new { id = islemId });
        });

        grup.MapPatch("/seans/islem/{id:int}", async (
            int id, SeansIslemGuncelleIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.seans", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var acik = await b.TekDegerAsync<int?>("select 1 from public.dis_seans_islem i join public.dis_seans s on s.id = i.seans_id where i.id = @p0 and s.durum = 1", null, [id], iptal);
            if (acik != 1) throw GentegreHatasi.IsKurali("Kapanmış seansın işlemi değiştirilmez.");
            await b.CalistirAsync("""
                update public.dis_seans_islem
                   set tamamlandi = coalesce(@p1, tamamlandi), uygulama_notu = coalesce(@p2, uygulama_notu), calisma_boyu = coalesce(@p3, calisma_boyu),
                       komplikasyon = coalesce(@p4, komplikasyon), sonraki_plan = coalesce(@p5, sonraki_plan), not_metin = coalesce(@p6, not_metin),
                       dis_no = coalesce(@p7, dis_no), yuzeyler = coalesce(@p8, yuzeyler), degistiren = @p9, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.Tamamlandi is null ? null : (short?)(g.Tamamlandi.Value ? 1 : 0), g.UygulamaNotu, g.CalismaBoyu, g.Komplikasyon,
                            g.SonrakiPlan, g.NotMetin, g.DisNo is null ? null : (short?)g.DisNo, g.Yuzeyler is null ? null : YuzeyNormalle(g.Yuzeyler),
                            baglam.KullaniciId], iptal);
            return Results.NoContent();
        });

        grup.MapDelete("/seans/islem/{id:int}", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.seans", Islem.Degistir);
            var n = await veri.CalistirAsync("""
                delete from public.dis_seans_islem i using public.dis_seans s
                 where i.id = @p0 and s.id = i.seans_id and s.durum = 1 and i.belge_satir_id is null
                """, [id], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Ücretlenmiş ya da kapanmış seansın işlemi silinmez.");
            return Results.NoContent();
        });
    }
}

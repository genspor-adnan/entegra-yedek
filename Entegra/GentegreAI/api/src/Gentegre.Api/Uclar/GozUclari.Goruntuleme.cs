using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ GÖRÜNTÜLEME v2 (974, mockup Ekranlar/Goz/goz_goruntuleme_listesi_v2.html ·
/// goz_goruntuleme_karti_v2.html).
///
/// <para><b>Akış lab / radyolojiyle aynı</b>: hekim istem sepetinden ister (başvuruya bekleyen,
/// serbest=0) → banko ücretlendirir, başvuru kaydı serbest bırakır → teknisyen çeker (2) →
/// hekim değerlendirir (3). Ödenmemiş istem çekilemez; cihaz ölçümü de beklemede kalır.</para>
/// </summary>
public static partial class GozUclari
{
    private const int LogTabloGoruntuleme = 1101;   // KartKatalogu LogGozGoruntuleme ile aynı

    private static void GoruntulemeUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/goruntuleme-gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.goruntuleme", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var gosterge = await b.TekAsync("""
                select count(*) filter (where (g.istem_zamani at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date) as bugun,
                       count(*) filter (where g.durum = 1 and g.serbest = 1)            as sirada,
                       count(*) filter (where g.durum = 1 and g.serbest = 0)            as "odemeBekliyor",
                       count(*) filter (where g.durum = 2)                              as "degerlendirmeBekleyen",
                       count(*) filter (where g.durum in (2, 3) and g.kalite < 6)       as "kaliteDusuk",
                       count(*) filter (where g.durum in (2, 3) and v.bayrak >= 1)      as "esikDisi",
                       count(*) filter (where v.yz_dikkat = 1)                          as "yzDikkat"
                  from public.goz_goruntuleme g join public.v_goz_goruntuleme_ozet v on v.goruntuleme_id = g.id
                 where g.durum <> 0 and (@p0::int is null or g.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var tetkikler = await b.ListeAsync("""
                select tetkik, count(*) as sayi from public.goz_goruntuleme
                 where durum <> 0 and (@p0::int is null or sube_id = @p0) group by 1 order by 2 desc
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var cihazlar = await b.ListeAsync("""
                select g.cihaz_id as id, c.ad, count(*) as sayi
                  from public.goz_goruntuleme g join public.goz_cihaz c on c.id = g.cihaz_id
                 where g.durum <> 0 and (@p0::int is null or g.sube_id = @p0) group by 1, 2 order by 3 desc
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var degerlendirenler = await b.ListeAsync("""
                select g.degerlendiren_id as id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad, count(*) as sayi
                  from public.goz_goruntuleme g join public.taraf t on t.id = g.degerlendiren_id
                 where (@p0::int is null or g.sube_id = @p0) group by 1, 2 order by 3 desc
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { gosterge, tetkikler, cihazlar, degerlendirenler, izlemeNo = baglam.IzlemeNo });
        });

        // İSTEM SEPETİ "Göz" sekmesi: ücret hizmeti eşlenmiş göz tetkikleri (eşlemesiz tetkik istenemez).
        grup.MapGet("/tetkik-hizmet", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select t.tetkik, t.hizmet_id as "hizmetId", coalesce(h.kod, '') as kod, coalesce(h.ad, '') as "hizmetAd"
                  from public.goz_tetkik_hizmet t join public.hizmet h on h.id = t.hizmet_id
                 where coalesce(h.durum, 1) = 1
                 order by t.tetkik
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // ÖNİZLEME (liste sağ paneli) + KART BANDI: kayıt, ölçümler, ana ölçümün eğilimi, YZ ön okuma.
        grup.MapGet("/goruntuleme/{id:int}/onizleme", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.goruntuleme", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kayit = await b.TekAsync("""
                select g.id, g.hasta_id as "hastaId", g.muayene_id as "muayeneId", g.belge_id as "belgeId",
                       g.tetkik, g.goz, g.durum, g.serbest, g.oncelik, g.kalite, g.dilate, g.sonuc,
                       g.istem_zamani as "istemZamani", g.cekim_zamani as "cekimZamani",
                       g.degerlendirme_zamani as "degerlendirmeZamani", coalesce(g.klinik_soru, '') as "klinikSoru",
                       coalesce(g.degerlendirme, '') as degerlendirme, coalesce(g.oneri, '') as oneri,
                       coalesce(g.study_uid, '') as "studyUid", coalesce(array_length(g.dokuman_ids, 1), 0) as "dokumanSay",
                       g.ai_on_okuma::text as "yzOnOkuma",
                       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as hasta,
                       v.yas, v.cinsiyet, v.hasta_no as "hastaNo", v.protokol, v.ana_olcum as "anaOlcum", v.bekleme_dk as "beklemeDk",
                       coalesce(c.ad, '') as cihaz,
                       coalesce(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::varchar(120), '') as "istekHekim",
                       coalesce(public.fn_taraf_ad(d.unvan, d.ad, d.soyad)::varchar(120), '') as degerlendiren,
                       coalesce(public.fn_taraf_ad(tk.unvan, tk.ad, tk.soyad)::varchar(120), '') as teknisyen,
                       coalesce(bb.basvuru_no, '') as "basvuruNo",
                       (select gm.id from public.goz_muayene gm where gm.muayene_id = g.muayene_id order by gm.id limit 1) as "gozMuayeneId"
                  from public.goz_goruntuleme g
                  join public.taraf t on t.id = g.hasta_id
                  join public.v_goz_goruntuleme_ozet v on v.goruntuleme_id = g.id
                  left join public.goz_cihaz c on c.id = g.cihaz_id
                  left join public.taraf ih on ih.id = g.istek_hekim_id
                  left join public.taraf d on d.id = g.degerlendiren_id
                  left join public.taraf tk on tk.id = g.teknisyen_id
                  left join lateral (select coalesce(be.belge_no, '')::varchar(40) as basvuru_no from public.belge be where be.id = g.belge_id) bb on true
                 where g.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Görüntüleme bulunamadı.");
            var olcumler = await b.ListeAsync("""
                select o.goz, o.olcum, o.deger, coalesce(o.birim, '') as birim, o.normal_pct as "normalPct", coalesce(o.bayrak, 0) as bayrak,
                       (select p.deger from public.goz_goruntuleme_olcum p join public.goz_goruntuleme pg on pg.id = p.goruntuleme_id
                         where pg.hasta_id = g.hasta_id and pg.tetkik = g.tetkik and pg.id <> g.id and pg.durum >= 2
                           and coalesce(pg.cekim_zamani, pg.istem_zamani) < coalesce(g.cekim_zamani, g.istem_zamani)
                           and p.goz = o.goz and p.olcum = o.olcum
                         order by coalesce(pg.cekim_zamani, pg.istem_zamani) desc limit 1) as onceki
                  from public.goz_goruntuleme_olcum o join public.goz_goruntuleme g on g.id = o.goruntuleme_id
                 where o.goruntuleme_id = @p0
                 order by o.olcum, o.goz
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            // EĞİLİM: aynı tetkikin ana ölçümü, hastanın son 8 çekimi (eski → yeni).
            var egilim = await b.ListeAsync("""
                select * from (
                    select coalesce(g.cekim_zamani, g.istem_zamani) as zaman, g.id, (g.id = @p0) as bu,
                           (select o.deger from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id and o.goz = 1 and o.olcum = v.ana_olcum order by o.id desc limit 1) as od,
                           (select o.deger from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id and o.goz = 2 and o.olcum = v.ana_olcum order by o.id desc limit 1) as os
                      from public.goz_goruntuleme bu
                      join public.goz_goruntuleme g on g.hasta_id = bu.hasta_id and g.tetkik = bu.tetkik and g.durum >= 2
                      join public.v_goz_goruntuleme_ozet v on v.goruntuleme_id = bu.id
                     where bu.id = @p0 and v.ana_olcum is not null
                     order by 1 desc limit 8) x
                 order by zaman
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { kayit, olcumler, egilim, izlemeNo = baglam.IzlemeNo });
        });

        // ÇEKİLDİ (teknisyen): yalnız ödenmiş (serbest) istem.
        grup.MapPost("/goruntuleme/{id:int}/cekildi", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.goruntuleme", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var r = await DurumOkuAsync(b, id, iptal);
            if (r.Serbest == 0)
                throw GentegreHatasi.IsKurali("İstem ödeme bekliyor: bankoda ücretlendirilip başvuru kaydedilmeden çekim yapılamaz.");
            if (r.Durum != 1) throw GentegreHatasi.IsKurali("Yalnız 'İstendi' durumundaki kayıt çekildi yapılır.");
            await b.CalistirAsync("""
                update public.goz_goruntuleme
                   set durum = 2, cekim_zamani = coalesce(cekim_zamani, now()), teknisyen_id = coalesce(teknisyen_id, @p1),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 1 and serbest = 1
                """, null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloGoruntuleme, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Çekildi" }, tarafId: r.Hasta, iptal: iptal);
            return Results.Ok(new { id, durum = 2, izlemeNo = baglam.IzlemeNo });
        });

        // DEĞERLENDİR (hekim): sonuç + yorum zorunlu, kayıt kilitlenir (3). Bağlı muayene istemi tamamlanır.
        grup.MapPost("/goruntuleme/{id:int}/degerlendir", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.goruntuleme", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var r = await DurumOkuAsync(b, id, iptal);
            if (r.Durum != 2) throw GentegreHatasi.IsKurali(r.Durum == 3 ? "Kayıt zaten değerlendirilmiş." : "Önce çekim yapılmalı.");
            if (r.Sonuc is null || r.Yorum.Trim().Length == 0)
                throw GentegreHatasi.IsKurali("Sonuç ve bulgu / yorum girilip kaydedilmeli.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                update public.goz_goruntuleme
                   set durum = 3, degerlendiren_id = @p1, degerlendirme_zamani = now(), degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 2
                """, islem, [id, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.muayene_istem set sonuc_durum = 2, sonuc_zamani = now()
                 where hedef_tablo = 'goz_goruntuleme' and hedef_id = @p0 and sonuc_durum < 2
                """, islem, [id], iptal);
            await islem.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloGoruntuleme, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Değerlendirildi" }, tarafId: r.Hasta, iptal: iptal);
            return Results.Ok(new { id, durum = 3, izlemeNo = baglam.IzlemeNo });
        });

        // İPTAL (hekimin İstem & Sonuç'undan sil): yalnız çekilmemiş istem; ücret satırı varsa banko iade eder.
        grup.MapPost("/goruntuleme/{id:int}/iptal", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var r = await DurumOkuAsync(b, id, iptal);
            if (r.Durum != 1) throw GentegreHatasi.IsKurali("Çekilmiş görüntüleme istemi silinemez.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("update public.goz_goruntuleme set durum = 0, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 1",
                islem, [id, baglam.KullaniciId], iptal);
            await b.CalistirAsync("update public.muayene_istem set sonuc_durum = 3 where hedef_tablo = 'goz_goruntuleme' and hedef_id = @p0",
                islem, [id], iptal);
            await islem.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloGoruntuleme, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "İptal" }, tarafId: r.Hasta, iptal: iptal);
            return Results.Ok(new { id, mesaj = r.Serbest == 1 ? "Göz görüntüleme istemi iptal edildi (ücret satırı bankoda kontrol edilmeli)." : "Göz görüntüleme istemi iptal edildi.", izlemeNo = baglam.IzlemeNo });
        });

        // YENİDEN ÇEKİM: aynı istemin ücreti alınmış - yeni kayıt serbest (ikinci ücret yok), eskisi iptal.
        grup.MapPost("/goruntuleme/{id:int}/yeniden", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.goruntuleme", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var r = await DurumOkuAsync(b, id, iptal);
            if (r.Durum != 2) throw GentegreHatasi.IsKurali("Yalnız çekilmiş, değerlendirilmemiş kayıt yeniden çekime gönderilir.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            var yeni = await b.TekDegerAsync<int>("""
                insert into public.goz_goruntuleme
                    (sube_id, muayene_id, hasta_id, goz, tetkik, hizmet_id, belge_id, serbest, oncelik,
                     istek_hekim_id, klinik_soru, istem_zamani, durum, ekleyen)
                select sube_id, muayene_id, hasta_id, goz, tetkik, hizmet_id, belge_id, 1, oncelik,
                       istek_hekim_id, left('Yeniden çekim · ' || coalesce(klinik_soru, ''), 300), now(), 1, @p1
                  from public.goz_goruntuleme where id = @p0
                returning id
                """, islem, [id, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.goz_goruntuleme set durum = 0, degistiren = @p1, degistirme_tarihi = now() where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.muayene_istem set hedef_id = @p1 where hedef_tablo = 'goz_goruntuleme' and hedef_id = @p0
                """, islem, [id, yeni], iptal);
            await islem.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloGoruntuleme, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Yeniden çekim", yeniId = yeni }, tarafId: r.Hasta, iptal: iptal);
            return Results.Ok(new { id = yeni, eskiId = id, izlemeNo = baglam.IzlemeNo });
        });
    }

    private static async Task<(int Durum, short Serbest, int Hasta, short? Sonuc, string Yorum)> DurumOkuAsync(
        Npgsql.NpgsqlConnection b, int id, CancellationToken iptal)
    {
        var r = await b.TekAsync("""
            select durum, serbest, hasta_id, sonuc, coalesce(degerlendirme, '') from public.goz_goruntuleme where id = @p0
            """, null, [id], o => new { D = (int)o.GetInt16(0), S = o.GetInt16(1), H = o.GetInt32(2),
                                         So = o.IsDBNull(3) ? (short?)null : o.GetInt16(3), Y = o.GetString(4) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Görüntüleme bulunamadı.");
        return (r.D, r.S, r.H, r.So, r.Y);
    }
}

using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TEDAVİ PLANI KARTI (710) — mockup <c>dis_tedavi_plani_karti.html</c>:
/// plan başlığı + özet kartları + sekmeler (satırlar, seans programı,
/// proforma & onay, ödeme planı, lab işleri, alternatif varyant, günlük).
/// Generic <c>dis-plan</c> kartı bunların hiçbirini gösteremiyordu: seanslar
/// ve lab işleri plana FK ile değil satırlar üzerinden bağlı, ödeme planı
/// ayrı tablo, günlük ISLEMLOG'dan. Tek soruda hepsi burada.
/// </summary>
public static partial class DisUclari
{
    public sealed record PlanAcIstegi(int HastaId, int? HekimId, int? MuayeneId, int? FiyatListesiId);
    public sealed record PlanGuncelleIstegi(int? HekimId, int? MuayeneId, int? FiyatListesiId, int? OdeyenKurumId,
                                            string? OdemeSecenegi, int? TaksitSayisi, DateOnly? GecerlilikBitis,
                                            string? Aciklama, bool? OdeyenKurumTemizle);

    private static void PlanKartUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------------- oku ----
        grup.MapGet("/plan/{id:int}", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var plan = await b.TekAsync("""
                select p.id, p.plan_no, p.hasta_id, t.unvan, coalesce(t.vkno, ''),
                       extract(year from age(current_date, th.dogum_tarihi))::int as yas, coalesce(th.cinsiyet, 0),
                       p.hekim_id, coalesce(h.unvan, ''), p.muayene_id, m.baslangic as muayene_tarih,
                       p.varyant, p.ana_plan_id, coalesce(ap.plan_no, ''), p.durum,
                       p.fiyat_listesi_id, coalesce(fl.ad, ''), p.odeyen_kurum_id, coalesce(k.ad, ''),
                       p.toplam, p.indirim, p.net, p.odeme_secenegi, coalesce(p.taksit_sayisi, 0), p.proforma_no,
                       p.gecerlilik_bitis, p.hasta_onay_zamani, p.onay_yontemi, p.aciklama, p.ekleme_tarihi,
                       (select o.plan_no from public.dis_tedavi_plani o
                         where o.hasta_id = p.hasta_id and o.id < p.id and o.durum in (5, 6, 7) order by o.id desc limit 1) as onceki_plan,
                       (select string_agg(coalesce(nullif(x.etken, ''), x.etken_madde), ', ') from public.hasta_alerji x
                         where x.hasta_id = p.hasta_id and x.aktif = 1) as alerji
                  from public.dis_tedavi_plani p
                  join public.taraf t on t.id = p.hasta_id
                  left join public.taraf_hasta th on th.id = p.hasta_id
                  left join public.taraf h on h.id = p.hekim_id
                  left join public.muayene m on m.id = p.muayene_id
                  left join public.dis_tedavi_plani ap on ap.id = p.ana_plan_id
                  left join public.v_fiyat_listesi_lookup fl on fl.id = p.fiyat_listesi_id
                  left join public.v_kurum_lookup k on k.id = p.odeyen_kurum_id
                 where p.id = @p0
                """, null, [id], o => new
            {
                id = o.GetInt32(0), planNo = o.GetString(1), hastaId = o.GetInt32(2), hasta = o.GetString(3), tckn = o.GetString(4),
                yas = o.IsDBNull(5) ? (int?)null : o.GetInt32(5), cinsiyet = (int)o.GetInt16(6),
                hekimId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7), hekim = o.GetString(8),
                muayeneId = o.IsDBNull(9) ? (int?)null : o.GetInt32(9), muayeneTarih = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10),
                varyant = o.GetString(11), anaPlanId = o.IsDBNull(12) ? (int?)null : o.GetInt32(12), anaPlanNo = o.GetString(13),
                durum = (int)o.GetInt16(14),
                fiyatListesiId = o.IsDBNull(15) ? (int?)null : o.GetInt32(15), fiyatListesi = o.GetString(16),
                odeyenKurumId = o.IsDBNull(17) ? (int?)null : o.GetInt32(17), odeyenKurum = o.GetString(18),
                toplam = o.GetDecimal(19), indirim = o.GetDecimal(20), net = o.GetDecimal(21),
                odemeSecenegi = o.GetString(22), taksitSayisi = (int)o.GetInt16(23), proformaNo = o.GetString(24),
                gecerlilikBitis = o.IsDBNull(25) ? (DateTime?)null : o.GetDateTime(25),
                hastaOnayZamani = o.IsDBNull(26) ? (DateTime?)null : o.GetDateTime(26), onayYontemi = o.GetString(27),
                aciklama = o.GetString(28), eklemeTarihi = o.GetDateTime(29),
                oncekiPlan = o.Metin("onceki_plan"), alerji = o.Metin("alerji"),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Plan bulunamadı.");

            var satirlar = await PlanSatirlariAsync(b, id, iptal);

            var ozet = await b.TekAsync("""
                select (select coalesce(sum(s.net), 0) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum = 3),
                       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum = 3)::int,
                       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum <> 4)::int,
                       (select coalesce(sum(k.odenen), 0) from public.dis_odeme_plani o join public.dis_odeme_taksit k on k.odeme_plani_id = o.id where o.plan_id = p.id),
                       (select o.id from public.dis_odeme_plani o where o.plan_id = p.id limit 1),
                       (select count(*) from public.dis_lab_isemri l join public.dis_tedavi_plani_satir s on s.id = l.plan_satir_id where s.plan_id = p.id and l.asama <> 9)::int,
                       (select count(*) from public.dis_lab_isemri l join public.dis_tedavi_plani_satir s on s.id = l.plan_satir_id where s.plan_id = p.id and l.asama in (2, 3, 4, 7))::int,
                       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.lab_gerekir = 1 and s.lab_isemri_id is null and s.durum <> 4)::int,
                       (select count(*) from public.dis_seans x where x.plan_id = p.id)::int,
                       (select count(*) from public.dis_seans x where x.plan_id = p.id and x.durum = 2)::int
                  from public.dis_tedavi_plani p where p.id = @p0
                """, null, [id], o => new
            {
                yapilan = o.GetDecimal(0), yapilanSayisi = o.GetInt32(1), satirSayisi = o.GetInt32(2), tahsil = o.GetDecimal(3),
                odemePlaniId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), labSayisi = o.GetInt32(5), labdaSayisi = o.GetInt32(6),
                labBekleyen = o.GetInt32(7), seansSayisi = o.GetInt32(8), bitenSeans = o.GetInt32(9),
            }, iptal);

            // Seans programı: plana bağlı seanslar + o seansta hangi satırlar işlendi.
            var seanslar = await b.ListeAsync("""
                select x.id, x.baslangic, x.bitis, x.sure_dk, x.durum, coalesce(u.kod || ' · ' || u.ad, ''), coalesce(h.unvan, ''),
                       coalesce((select string_agg('#' || coalesce(ps.sira, 0) || ' ' || hz.ad || case when i.plan_satir_id is null then '' else ' ' || i.seans_no || '/' || coalesce(ps.seans_sayisi, 1) end, ' · ' order by i.id)
                                   from public.dis_seans_islem i join public.hizmet hz on hz.id = i.hizmet_id
                                   left join public.dis_tedavi_plani_satir ps on ps.id = i.plan_satir_id
                                  where i.seans_id = x.id), '') as islemler,
                       x.randevu_id
                  from public.dis_seans x
                  left join public.dis_unit u on u.id = x.unit_id
                  left join public.taraf h on h.id = x.hekim_id
                 where x.plan_id = @p0
                    or exists (select 1 from public.dis_seans_islem i join public.dis_tedavi_plani_satir ps on ps.id = i.plan_satir_id
                                where i.seans_id = x.id and ps.plan_id = @p0)
                 order by x.baslangic
                """, null, [id], o => new
            {
                id = o.GetInt32(0), baslangic = o.GetDateTime(1), bitis = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                sureDk = (int)o.GetInt16(3), durum = (int)o.GetInt16(4), unit = o.GetString(5), hekim = o.GetString(6),
                islemler = o.GetString(7), randevuId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
            }, iptal);

            // Planlanmış (henüz seansa girmemiş) randevular: satır bazlı.
            var randevular = await b.ListeAsync("""
                select r.id, r.baslangic, r.sure_dk, r.durum, r.plan_satir_id, coalesce(u.kod || ' · ' || u.ad, ''), coalesce(h.unvan, '')
                  from public.randevu r
                  join public.dis_tedavi_plani_satir s on s.id = r.plan_satir_id
                  left join public.dis_unit u on u.id = r.unit_id
                  left join public.taraf h on h.id = r.hekim_id
                 where s.plan_id = @p0 and r.durum in (1, 2)
                 order by r.baslangic
                """, null, [id], o => new
            {
                id = o.GetInt32(0), baslangic = o.GetDateTime(1), sureDk = o.IsDBNull(2) ? 0 : Convert.ToInt32(o.GetValue(2)),
                durum = Convert.ToInt32(o.GetValue(3)), planSatirId = o.GetInt32(4), unit = o.GetString(5), hekim = o.GetString(6),
            }, iptal);

            var odemePlani = await b.TekAsync("""
                select o.id, o.toplam, o.pesinat, o.taksit_sayisi, o.taksit_tutar, o.ilk_vade, o.odeme_yontemi, o.durum, o.aciklama
                  from public.dis_odeme_plani o where o.plan_id = @p0 order by o.id limit 1
                """, null, [id], o => new
            {
                id = o.GetInt32(0), toplam = o.GetDecimal(1), pesinat = o.GetDecimal(2), taksitSayisi = (int)o.GetInt16(3),
                taksitTutar = o.GetDecimal(4), ilkVade = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                odemeYontemi = (int)o.GetInt16(6), durum = (int)o.GetInt16(7), aciklama = o.GetString(8),
            }, iptal);

            var taksitler = odemePlani is null ? [] : await b.ListeAsync("""
                select k.id, k.sira, k.vade, k.tutar, k.odenen, k.odeme_tarihi, k.durum, k.mali_hareket_id
                  from public.dis_odeme_taksit k where k.odeme_plani_id = @p0 order by k.sira
                """, null, [odemePlani.id], o => new
            {
                id = o.GetInt32(0), sira = (int)o.GetInt16(1), vade = o.GetDateTime(2), tutar = o.GetDecimal(3), odenen = o.GetDecimal(4),
                odemeTarihi = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5), durum = (int)o.GetInt16(6),
                maliHareketId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
            }, iptal);

            var labIsleri = await b.ListeAsync("""
                select l.id, l.isemri_no, l.plan_satir_id, coalesce(s.sira, 0), coalesce(lb.ad, ''), l.dis_nolar, l.is_turu, l.malzeme, l.renk,
                       l.gonderim_tarihi, l.beklenen_tarih, l.teslim_tarihi, l.asama, l.lab_fiyat, l.kalite_kontrol,
                       (select r.baslangic from public.randevu r where r.plan_satir_id = l.plan_satir_id and r.durum in (1, 2) and r.baslangic >= now() order by r.baslangic limit 1)
                  from public.dis_lab_isemri l
                  join public.dis_tedavi_plani_satir s on s.id = l.plan_satir_id
                  left join public.dis_lab lb on lb.id = l.lab_id
                 where s.plan_id = @p0
                 order by l.id
                """, null, [id], o => new
            {
                id = o.GetInt32(0), isemriNo = o.GetString(1), planSatirId = o.GetInt32(2), planSira = (int)o.GetInt16(3), lab = o.GetString(4),
                disNolar = o.GetString(5), isTuru = (int)o.GetInt16(6), malzeme = o.GetString(7), renk = o.GetString(8),
                gonderim = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9), beklenen = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10),
                teslim = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11), asama = (int)o.GetInt16(12), labFiyat = o.GetDecimal(13),
                kaliteKontrol = (int)o.GetInt16(14), randevu = o.IsDBNull(15) ? (DateTime?)null : o.GetDateTime(15),
            }, iptal);

            // Varyantlar: aynı ana plan ailesindeki diğer planlar (A/B/C).
            var kokId = plan.anaPlanId ?? plan.id;
            var varyantlar = await b.ListeAsync("""
                select v.id, v.plan_no, v.varyant, v.durum, v.toplam, v.indirim, v.net,
                       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = v.id and s.durum <> 4)::int,
                       v.hasta_onay_zamani
                  from public.dis_tedavi_plani v
                 where (v.id = @p0 or v.ana_plan_id = @p0) and v.id <> @p1
                 order by v.varyant, v.id
                """, null, [kokId, id], o => new
            {
                id = o.GetInt32(0), planNo = o.GetString(1), varyant = o.GetString(2), durum = (int)o.GetInt16(3),
                toplam = o.GetDecimal(4), indirim = o.GetDecimal(5), net = o.GetDecimal(6), satirSayisi = o.GetInt32(7),
                hastaOnayZamani = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8),
            }, iptal);

            // Varyant satırlarını diş bazında karşılaştırma için: her varyantın satırları (id, disNo, islem, net).
            var varyantSatirlari = await b.ListeAsync("""
                select s.plan_id, s.dis_no, s.yuzeyler, hz.ad, s.net, s.durum
                  from public.dis_tedavi_plani_satir s join public.hizmet hz on hz.id = s.hizmet_id
                 where s.plan_id in (select v.id from public.dis_tedavi_plani v where (v.id = @p0 or v.ana_plan_id = @p0) and v.id <> @p1)
                   and s.durum <> 4
                 order by s.plan_id, s.dis_no, s.sira
                """, null, [kokId, id], o => new
            {
                planId = o.GetInt32(0), disNo = (int)o.GetInt16(1), yuzeyler = o.GetString(2), islem = o.GetString(3),
                net = o.GetDecimal(4), durum = (int)o.GetInt16(5),
            }, iptal);

            // Günlük (ISLEMLOG 1130 plan / 1131 satır / 1138 ödeme planı).
            var gunluk = await b.ListeAsync("""
                select g.tarih, coalesce(k.ad, ''), g.islem_tipi, g.tablo_id, g.kayit_id, coalesce(g.bilgi::text, '')
                  from public.islem_log g
                  left join public.v_kullanici_lookup k on k.id = g.kullanici_id
                 where (g.tablo_id = 1130 and g.kayit_id = @p0)
                    or (g.tablo_id = 1131 and g.kayit_id in (select s.id from public.dis_tedavi_plani_satir s where s.plan_id = @p0))
                    or (g.tablo_id = 1138 and g.kayit_id in (select o.id from public.dis_odeme_plani o where o.plan_id = @p0))
                 order by g.tarih desc, g.id desc
                 limit 60
                """, null, [id], o => new
            {
                tarih = o.GetDateTime(0), kullanici = o.GetString(1), islemTipi = (int)o.GetInt16(2), tabloId = o.GetInt32(3),
                kayitId = o.GetInt64(4), bilgi = o.GetString(5),
            }, iptal);

            // Başlık combolarının seçenekleri (hekim, fiyat listesi, kurum).
            var hekimler = await b.ListeAsync("select id, ad from public.v_hekim_lookup where aktif = 1 order by ad limit 300", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var fiyatListeleri = await b.ListeAsync("select id, ad from public.v_fiyat_listesi_lookup where aktif = 1 order by ad limit 100", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var kurumlar = await b.ListeAsync("select id, ad from public.v_kurum_lookup where aktif = 1 order by ad limit 300", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                plan, ozet, satirlar, seanslar, randevular, odemePlani, taksitler, labIsleri, varyantlar, varyantSatirlari, gunluk,
                secenekler = new { hekimler, fiyatListeleri, kurumlar },
            });
        });

        // ------------------------------------------------------------- aç ----
        // Boş taslak plan: liste "+ Tedavi Planı" ve plan kartı "Yeni". Satırlar
        //   hasta kartındaki odontogramdan ya da bu karttan eklenir.
        grup.MapPost("/plan", async (
            PlanAcIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Ekle);
            if (istek.HastaId <= 0) throw GentegreHatasi.Dogrulama("Hasta seçin.");
            await using var b = await veri.AcAsync(iptal);
            var hastaMi = await b.TekDegerAsync<int?>("select 1 from public.taraf where id = @p0 and hasta = 1", null, [istek.HastaId], iptal);
            if (hastaMi is null) throw GentegreHatasi.Dogrulama("Seçilen kayıt hasta değil.");
            // Fiyat listesi: hastanın kurum sözleşmesi, yoksa varsayılan liste (706 kuralı, Basvuru.cs ile aynı sıra).
            var fiyatListesi = istek.FiyatListesiId ?? await b.TekDegerAsync<int?>("""
                select s.fiyat_listesi_id from public.taraf_hasta_kurum k join public.kurum_sozlesme s on s.kurum_id = k.kurum_id
                 where k.hasta_id = @p0 and k.aktif = 1 and s.durum = 1 and s.fiyat_listesi_id is not null
                   and (s.bitis is null or s.bitis >= current_date)
                 order by case k.tur when 3 then 0 when 4 then 1 when 2 then 2 else 3 end, s.id desc limit 1
                """, null, [istek.HastaId], iptal) ?? await VarsayilanFiyatListesiAsync(b, null, iptal);
            var id = await b.TekDegerAsync<int>("""
                insert into public.dis_tedavi_plani (sube_id, plan_no, hasta_id, hekim_id, muayene_id, varyant, durum, fiyat_listesi_id, ekleyen)
                values (@p0, '', @p1, @p2, @p3, 'A', 1, @p4, @p5) returning id
                """, null, [baglam.SubeId ?? 0, istek.HastaId, istek.HekimId, istek.MuayeneId, fiyatListesi, baglam.KullaniciId], iptal);
            var planNo = await b.TekDegerAsync<string>("select plan_no from public.dis_tedavi_plani where id = @p0", null, [id], iptal) ?? "";
            await log.YazAsync(LogIslemi.Ekle, LogTabloPlan, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { planNo, hastaId = istek.HastaId }, tarafId: istek.HastaId, iptal: iptal);
            return Results.Ok(new { id, planNo });
        });

        // ------------------------------------------------------- güncelle ----
        grup.MapPatch("/plan/{id:int}", async (
            int id, PlanGuncelleIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await PlanOkuAsync(b, id, iptal);
            if (p.durum is 5 or 6 or 7) throw GentegreHatasi.IsKurali("Kapanmış plan değiştirilmez.");
            // Onaylı planda fiyat listesi değişmez: satır fiyatları kilitli, liste
            //   değişse de yeniden fiyatlanmaz; yanıltıcı olurdu.
            if (p.durum >= 3 && g.FiyatListesiId is not null)
                throw GentegreHatasi.IsKurali("Onaylı planda fiyat listesi değiştirilmez.");
            await b.CalistirAsync("""
                update public.dis_tedavi_plani
                   set hekim_id = coalesce(@p1, hekim_id), muayene_id = coalesce(@p2, muayene_id),
                       fiyat_listesi_id = coalesce(@p3, fiyat_listesi_id),
                       odeyen_kurum_id = case when @p9 then null else coalesce(@p4, odeyen_kurum_id) end,
                       odeme_secenegi = coalesce(@p5, odeme_secenegi), taksit_sayisi = coalesce(@p6, taksit_sayisi),
                       gecerlilik_bitis = coalesce(@p7, gecerlilik_bitis), aciklama = coalesce(@p8, aciklama),
                       degistiren = @p10, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.HekimId, g.MuayeneId, g.FiyatListesiId, g.OdeyenKurumId, g.OdemeSecenegi,
                            g.TaksitSayisi is int ts ? (short)ts : null, g.GecerlilikBitis, g.Aciklama,
                            g.OdeyenKurumTemizle == true, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloPlan, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { g.HekimId, g.FiyatListesiId, g.OdeyenKurumId, g.OdemeSecenegi, g.TaksitSayisi, g.GecerlilikBitis }, tarafId: p.hastaId, iptal: iptal);
            return Results.Ok(new { id });
        });

        // ---------------------------------------------------------- iptal ----
        // Yapılmış satırlar kalır (ücreti doğmuş), bekleyenler iptal olur.
        grup.MapPost("/plan/{id:int}/iptal", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await PlanOkuAsync(b, id, iptal);
            if (p.durum is 5 or 6 or 7) throw GentegreHatasi.IsKurali("Plan zaten kapalı.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            var iptalSatir = await b.CalistirAsync("""
                update public.dis_tedavi_plani_satir set durum = 4, degistiren = @p1, degistirme_tarihi = now()
                 where plan_id = @p0 and durum in (1, 2, 5)
                """, islem, [id, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.dis_tedavi_plani set durum = 6, degistiren = @p1, degistirme_tarihi = now() where id = @p0;
                select public.fn_dis_plan_toplam_tazele(@p0);
                """, islem, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloPlan, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "İptal", iptalSatir }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = 6, iptalSatir });
        });

        // ----------------------------------------------------- alternatif ----
        // Aynı hasta için B/C varyantı: satırlar KOPYALANIR (fiyat, seans,
        //   faz), hekim değiştirir; onaylanan varyant sürer, öteki iptal edilir.
        grup.MapPost("/plan/{id:int}/alternatif", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var p = await PlanOkuAsync(b, id, iptal);
            var kok = await b.TekDegerAsync<int?>("select ana_plan_id from public.dis_tedavi_plani where id = @p0", null, [id], iptal) ?? id;
            var sonVaryant = await b.TekDegerAsync<string>("""
                select max(varyant) from public.dis_tedavi_plani where id = @p0 or ana_plan_id = @p0
                """, null, [kok], iptal) ?? "A";
            var yeniVaryant = ((char)(Math.Min('Y', sonVaryant.Length > 0 ? sonVaryant[0] : 'A') + 1)).ToString();
            await using var islem = await b.BeginTransactionAsync(iptal);
            var yeniId = await b.TekDegerAsync<int>("""
                insert into public.dis_tedavi_plani (sube_id, plan_no, hasta_id, hekim_id, muayene_id, varyant, ana_plan_id, durum,
                                                     fiyat_listesi_id, odeyen_kurum_id, odeme_secenegi, taksit_sayisi, aciklama, ekleyen)
                select @p1, '', hasta_id, hekim_id, muayene_id, @p2, @p3, 1, fiyat_listesi_id, odeyen_kurum_id, odeme_secenegi, taksit_sayisi,
                       'Alternatif ' || @p2 || ' — ' || plan_no, @p4
                  from public.dis_tedavi_plani where id = @p0 returning id
                """, islem, [id, baglam.SubeId ?? 0, yeniVaryant, kok, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                insert into public.dis_tedavi_plani_satir (plan_id, faz, sira, dis_no, dis_nolar, yuzeyler, hizmet_id, hekim_id, seans_sayisi,
                                                           liste_fiyat, iskonto, net, kurum_tutar, hasta_tutar, ucret_kurali, lab_gerekir,
                                                           onam_tur, durum, aciklama, sube_id, ekleyen)
                select @p1, faz, sira, dis_no, dis_nolar, yuzeyler, hizmet_id, hekim_id, seans_sayisi,
                       liste_fiyat, iskonto, net, kurum_tutar, hasta_tutar, ucret_kurali, lab_gerekir,
                       onam_tur, 1, aciklama, sube_id, @p2
                  from public.dis_tedavi_plani_satir where plan_id = @p0 and durum <> 4;
                select public.fn_dis_plan_toplam_tazele(@p1);
                """, islem, [id, yeniId, baglam.KullaniciId], iptal);
            var planNo = await b.TekDegerAsync<string>("select plan_no from public.dis_tedavi_plani where id = @p0", islem, [yeniId], iptal) ?? "";
            await log.YazAsync(b, islem, LogIslemi.Ekle, LogTabloPlan, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { planNo, varyant = yeniVaryant, anaPlan = p.planNo }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = yeniId, planNo, varyant = yeniVaryant });
        });

        // --------------------------------------------------- ana plan yap ----
        // B'yi ana yap: B'nin ana_plan_id'si kalkar, eski ana ve diğer varyantlar
        //   "iptal (seçilmedi)" olur. Yalnız taslak/sunulmuş varyantta.
        grup.MapPost("/plan/{id:int}/ana-yap", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await PlanOkuAsync(b, id, iptal);
            var kok = await b.TekDegerAsync<int?>("select ana_plan_id from public.dis_tedavi_plani where id = @p0", null, [id], iptal);
            if (kok is null) throw GentegreHatasi.IsKurali("Bu plan zaten ana plan.");
            var anaDurum = await b.TekDegerAsync<short?>("select durum from public.dis_tedavi_plani where id = @p0", null, [kok], iptal) ?? 0;
            if (anaDurum >= 3) throw GentegreHatasi.IsKurali("Ana plan onaylanmış; artık varyant değiştirilemez.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                update public.dis_tedavi_plani_satir set durum = 4 where plan_id in
                      (select v.id from public.dis_tedavi_plani v where (v.id = @p1 or v.ana_plan_id = @p1) and v.id <> @p0) and durum in (1, 2, 5);
                update public.dis_tedavi_plani set durum = 6, aciklama = trim(aciklama || ' · seçilmedi'), degistiren = @p2, degistirme_tarihi = now()
                 where (id = @p1 or ana_plan_id = @p1) and id <> @p0;
                update public.dis_tedavi_plani set ana_plan_id = null, degistiren = @p2, degistirme_tarihi = now() where id = @p0;
                """, islem, [id, kok, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloPlan, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { anaPlanYapildi = p.planNo, eskiAna = kok }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });
    }
}

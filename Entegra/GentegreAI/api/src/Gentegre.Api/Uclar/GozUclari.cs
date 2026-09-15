using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ HASTA ÖZETİ (691) — mockup <c>Ekranlar/Goz/goz_hasta_karti.html</c>.
///
/// <para>Göz hekiminin hastayı ilk gördüğünde sorduğu soru sabittir:
/// <b>"iki gözde ne kadar görüyor, basınç kaç, hangi takipte?"</b> Bu üç
/// cevap yedi ayrı tabloda ve onlarca ziyarette dağılmış durumda; her kart
/// açılışında hekimin bunları tek tek gezmesi, muayenenin ilk iki dakikasını
/// veri aramaya harcamak demek.</para>
///
/// <para><b>Özet CANLI hesaplanır, materyalize edilmez.</b> Şemada
/// <c>goz_hasta_ozet</c> tablosu duruyor ama doldurulmuyor: materyalize özetin
/// bedeli, onu güncel tutan tetikleyicilerin her ölçüm tablosuna yazılması ve
/// biri unutulduğunda özetin SESSİZCE eskimesidir. Sorgu tek geçişte (her ölçüm
/// için `distinct on`) çalışıyor; tablo, ölçüm hacmi bunu yavaşlattığında
/// devreye alınacak.</para>
///
/// <para>Ölçümler <b>göz bazlı</b> döner (OD/OS ayrı satır): hekim ikisini
/// karşılaştırarak okur, tek satırda birleştirmek bu karşılaştırmayı
/// bozar.</para>
/// </summary>
public static partial class GozUclari
{
    /// <summary>Akış hareketi kendi kaydıdır: log satırı ziyaret istasyonuna düşer.</summary>
    private const int LogTabloGozAkis = 953;

    public static void GozUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/goz").WithTags("Göz").RequireAuthorization();

        // Ünite panosu sayaçları ayrı dosyada: bu dosya HASTANIN göz özetini
        //   tutuyor, o ise ÜNİTENİN o günkü hâlini.
        UniteOzetiEkle(grup);
        AkisUclariniEkle(grup);
        SeritUcunuEkle(grup);
        MuayeneUclariniEkle(grup);
        // Cizim ve dikte (705): ikisi de MUAYENE BULGUSU yazmanin baska
        //   bir yolu - bulgu metni yazan tek uc ikisinde de ortak.
        CizimUclariniEkle(grup);
        CizimCiktiUclariniEkle(grup);
        DikteUclariniEkle(grup);

        // ----------------------------------------------- cihaz mesajı işle ----
        // Sürücü düzeltildiğinde mesaj YENİDEN İŞLENİR, yeniden yazılmaz: ham
        //   kayıt ölçümün nereden geldiğinin kanıtı (703).
        grup.MapPost("/cihaz-mesaj/{id:long}/isle", async (
            long id, Servisler.GozCihazServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.cihaz", Islem.Degistir);
            var s = await servis.CalistirAsync(1, id, iptal);
            return Results.Ok(new { s.Islenen, s.Sahipsiz, s.Hatali, s.Aciklama });
        });

        // Kuyruğun tamamı: gece işi de aynı servisi çağırıyor - iki ayrı yol,
        //   iki farklı davranış üretmesin.
        grup.MapPost("/cihaz-mesaj/kuyruk", async (
            int? enFazla, Servisler.GozCihazServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.cihaz", Islem.Degistir);
            var s = await servis.CalistirAsync(Math.Clamp(enFazla ?? 50, 1, 500), null, iptal);
            return Results.Ok(new { s.Okunan, s.Islenen, s.Sahipsiz, s.Hatali, s.Aciklama });
        });

        // --------------------------------------------------- hasta özeti ----
        grup.MapGet("/hasta/{hastaId:int}/ozet", async (
            int hastaId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Gor);

            // SON DEĞERLER göz bazlı: `distinct on` her (göz, ölçüm) için en
            //   yeni satırı verir - alt sorgu yığını yerine tek geçiş.
            var olcumler = await veri.ListeAsync("""
                with son_gorme as (
                    select distinct on (v.goz) v.goz, v.deger_ondalik, v.deger_snellen, v.zaman
                      from public.goz_gorme v
                      join public.goz_muayene gm on gm.id = v.goz_muayene_id
                     where gm.hasta_id = @p0 and v.tur = 4          -- BCVA
                     order by v.goz, v.zaman desc
                ),
                son_gib as (
                    select distinct on (o.goz) o.goz, o.gib, o.cct_um, o.hedef_gib,
                           o.bayrak, o.zaman
                      from public.goz_tonometri o
                      join public.goz_muayene gm on gm.id = o.goz_muayene_id
                     where gm.hasta_id = @p0
                     order by o.goz, o.zaman desc
                ),
                son_ref as (
                    select distinct on (r.goz) r.goz, r.sph, r.cyl, r.aks, r.zaman
                      from public.goz_refraksiyon r
                      join public.goz_muayene gm on gm.id = r.goz_muayene_id
                     where gm.hasta_id = @p0 and r.tur in (2, 6)    -- subjektif / reçete
                     order by r.goz, r.zaman desc
                ),
                son_fundus as (
                    select distinct on (f.goz) f.goz, f.cd_dikey, f.dr_evre, f.amd_evre, f.zaman
                      from public.goz_fundus f
                      join public.goz_muayene gm on gm.id = f.goz_muayene_id
                     where gm.hasta_id = @p0
                     order by f.goz, f.zaman desc
                ),
                -- RNFL trendin en çok okunan ölçümü: son değer + ondan önceki
                --   değer birlikte döner ki "inceliyor mu" tek bakışta görünsün.
                rnfl as (
                    select g.goz, o.deger, g.cekim_zamani,
                           row_number() over (partition by g.goz order by g.cekim_zamani desc) sira
                      from public.goz_goruntuleme g
                      join public.goz_goruntuleme_olcum o
                        on o.goruntuleme_id = g.id and o.goz = g.goz
                     where g.hasta_id = @p0 and o.olcum = 'rnfl_ort'
                       and g.cekim_zamani is not null
                )
                select t.goz,
                       case t.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end as goz_ad,
                       gr.deger_ondalik, gr.deger_snellen, gr.zaman as gorme_zaman,
                       gb.gib, gb.cct_um, gb.hedef_gib, gb.bayrak, gb.zaman as gib_zaman,
                       rf.sph, rf.cyl, rf.aks,
                       fn.cd_dikey, fn.dr_evre, fn.amd_evre,
                       r1.deger as rnfl_son, r1.cekim_zamani as rnfl_zaman,
                       r2.deger as rnfl_onceki, r2.cekim_zamani as rnfl_onceki_zaman
                  from (values (1::smallint), (2::smallint)) as t(goz)
                  left join son_gorme  gr on gr.goz = t.goz
                  left join son_gib    gb on gb.goz = t.goz
                  left join son_ref    rf on rf.goz = t.goz
                  left join son_fundus fn on fn.goz = t.goz
                  left join rnfl r1 on r1.goz = t.goz and r1.sira = 1
                  left join rnfl r2 on r2.goz = t.goz and r2.sira = 2
                 order by t.goz
                """, new object?[] { hastaId }, o => new
            {
                goz = o.GetInt16(0),
                gozAd = o.GetString(1),
                bcva = o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2),
                bcvaSnellen = o.IsDBNull(3) ? "" : o.GetString(3),
                bcvaZaman = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                gib = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                cct = o.IsDBNull(6) ? (int?)null : o.GetInt16(6),
                hedefGib = o.IsDBNull(7) ? (decimal?)null : o.GetDecimal(7),
                gibBayrak = o.IsDBNull(8) ? 0 : (int)o.GetInt16(8),
                gibZaman = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                sph = o.IsDBNull(10) ? (decimal?)null : o.GetDecimal(10),
                cyl = o.IsDBNull(11) ? (decimal?)null : o.GetDecimal(11),
                aks = o.IsDBNull(12) ? (int?)null : o.GetInt16(12),
                cdDikey = o.IsDBNull(13) ? (decimal?)null : o.GetDecimal(13),
                drEvre = o.IsDBNull(14) ? (int?)null : (int)o.GetInt16(14),
                amdEvre = o.IsDBNull(15) ? (int?)null : (int)o.GetInt16(15),
                rnflSon = o.IsDBNull(16) ? (decimal?)null : o.GetDecimal(16),
                rnflZaman = o.IsDBNull(17) ? (DateTime?)null : o.GetDateTime(17),
                rnflOnceki = o.IsDBNull(18) ? (decimal?)null : o.GetDecimal(18),
                rnflOncekiZaman = o.IsDBNull(19) ? (DateTime?)null : o.GetDateTime(19),
            }, iptal);

            // AKTİF TAKİPLER: hastanın açık protokolleri - "hangi hastalık,
            //   hedef ne, kontrolü gecikti mi".
            var takipler = await veri.ListeAsync("""
                select t.id, t.goz, t.hastalik, t.evre, t.hedef_gib,
                       t.sonraki_kontrol, t.progresyon_durum,
                       case when t.sonraki_kontrol is null then null
                            else (current_date - t.sonraki_kontrol) end as gecikme
                  from public.goz_hastalik_takip t
                 where t.hasta_id = @p0 and t.durum = 1
                 order by t.hastalik, t.goz
                """, new object?[] { hastaId }, o => new
            {
                id = o.GetInt32(0),
                goz = o.GetInt16(1),
                hastalik = o.GetInt16(2),
                evre = o.GetString(3),
                hedefGib = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                sonrakiKontrol = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                progresyon = (int)o.GetInt16(6),
                gecikmeGun = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
            }, iptal);

            // SON ZİYARETLER: kaç muayene, ne zaman, hangi türde.
            var ziyaretler = await veri.ListeAsync("""
                select gm.id, m.muayene_tarihi, gm.muayene_turu,
                       coalesce(h.unvan, '') as hekim, gm.dilate
                  from public.goz_muayene gm
                  join public.muayene m on m.id = gm.muayene_id
                  left join public.taraf h on h.id = m.personel_id
                 where gm.hasta_id = @p0
                 order by m.muayene_tarihi desc
                 limit 10
                """, new object?[] { hastaId }, o => new
            {
                id = o.GetInt32(0),
                tarih = o.GetDateTime(1),
                tur = (int)o.GetInt16(2),
                hekim = o.GetString(3),
                dilate = o.GetInt16(4) == 1,
            }, iptal);

            // İŞLEM GEÇMİŞİ: enjeksiyon doz sayısı ve ameliyatlar hekimin
            //   kararını doğrudan değiştirir ("kaçıncı enjeksiyon" sorusu).
            var islemler = await veri.ListeAsync("""
                select i.id, i.goz, i.tur, i.durum,
                       coalesce(i.uygulama_zamani, i.planlanan_tarih) as zaman,
                       coalesce(e.doz_no, 0) as doz_no,
                       coalesce(e.ilac, 0) as ilac,
                       coalesce(a.ameliyat_tur, 0) as ameliyat_tur,
                       coalesce(l.lazer_tur, 0) as lazer_tur
                  from public.goz_islem i
                  left join public.goz_enjeksiyon e on e.islem_id = i.id
                  left join public.goz_ameliyat  a on a.islem_id = i.id
                  left join public.goz_lazer     l on l.islem_id = i.id
                 where i.hasta_id = @p0 and i.durum <> 0
                 order by coalesce(i.uygulama_zamani, i.planlanan_tarih) desc nulls last
                 limit 20
                """, new object?[] { hastaId }, o => new
            {
                id = o.GetInt32(0),
                goz = o.GetInt16(1),
                tur = (int)o.GetInt16(2),
                durum = (int)o.GetInt16(3),
                zaman = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                dozNo = (int)o.GetInt16(5),
                ilac = (int)o.GetInt16(6),
                ameliyatTur = (int)o.GetInt16(7),
                lazerTur = (int)o.GetInt16(8),
            }, iptal);

            // SON REÇETE: optikten dönen hasta "gözlüğüm neydi" diye sorar.
            var receteler = await veri.ListeAsync("""
                select r.id, r.recete_no, r.tur, r.durum, r.ekleme_tarihi,
                       r.od_sph, r.od_cyl, r.od_aks, r.od_add,
                       r.os_sph, r.os_cyl, r.os_aks, r.os_add
                  from public.goz_gozluk_recetesi r
                 where r.hasta_id = @p0 and r.durum <> 0
                 order by r.ekleme_tarihi desc
                 limit 5
                """, new object?[] { hastaId }, o => new
            {
                id = o.GetInt32(0),
                receteNo = o.GetString(1),
                tur = (int)o.GetInt16(2),
                durum = (int)o.GetInt16(3),
                tarih = o.GetDateTime(4),
                odSph = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                odCyl = o.IsDBNull(6) ? (decimal?)null : o.GetDecimal(6),
                odAks = o.IsDBNull(7) ? (int?)null : o.GetInt16(7),
                odAdd = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                osSph = o.IsDBNull(9) ? (decimal?)null : o.GetDecimal(9),
                osCyl = o.IsDBNull(10) ? (decimal?)null : o.GetDecimal(10),
                osAks = o.IsDBNull(11) ? (int?)null : o.GetInt16(11),
                osAdd = o.IsDBNull(12) ? (decimal?)null : o.GetDecimal(12),
            }, iptal);

            return Results.Ok(new { olcumler, takipler, ziyaretler, islemler, receteler });
        });

        // ------------------------------------------------ ölçüm trend serisi ----
        // "RNFL iki yılda ne kadar inceldi" — progresyon sorusu. Ölçüm kodu
        //   PARAMETREDİR ama SQL'e metin olarak GİRMEZ: ayrıştırılmış ölçüm
        //   satırı zaten kod taşıyor, sorgu onu parametreyle karşılaştırır.
        grup.MapGet("/hasta/{hastaId:int}/trend", async (
            int hastaId, string olcum, short? goz, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Gor);

            var seri = await veri.ListeAsync("""
                select g.cekim_zamani, o.goz, o.deger, o.birim, o.bayrak,
                       g.tetkik, g.kalite
                  from public.goz_goruntuleme g
                  join public.goz_goruntuleme_olcum o
                    on o.goruntuleme_id = g.id
                 where g.hasta_id = @p0
                   and o.olcum = @p1
                   and (@p2::smallint is null or o.goz = @p2)
                   and g.cekim_zamani is not null
                 order by g.cekim_zamani
                """, new object?[] { hastaId, olcum, goz }, o => new
            {
                zaman = o.GetDateTime(0),
                goz = (int)o.GetInt16(1),
                deger = o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2),
                birim = o.GetString(3),
                bayrak = (int)o.GetInt16(4),
                tetkik = (int)o.GetInt16(5),
                // KALİTE seride durur: düşük sinyalli çekimin "incelmesi"
                //   gerçek incelme değildir - eğriyi okuyan bunu görmeli.
                kalite = o.IsDBNull(6) ? (int?)null : (int)o.GetInt16(6),
            }, iptal);

            return Results.Ok(seri);
        });
    }
}

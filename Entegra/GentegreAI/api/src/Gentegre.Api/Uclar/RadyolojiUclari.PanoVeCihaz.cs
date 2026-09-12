using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RADYOLOJİ PANOSU, cihaz kapatmaları ve randevu bekleyenler.
///
/// Uclar RadyolojiUclari.cs dosyasindan ayrildi: tek dosyada 1956 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class RadyolojiUclari
{
    private static void PanoVeCihazEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------ radyoloji panosu ----
        // Modulun "bugun ne durumdayiz" ekrani (320). Her sayac TIKLANIR ve
        //   ilgili listeyi kendi suzgeciyle acar - pano bakilacak yer degil,
        //   ise giris kapisidir. Tek uc: alti ayri istek yerine hepsi burada
        //   toplanir; sube suzmesi baglamdan gelir.
        grup.MapGet("/pano", async (
            DateTime? gun, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            var tarih = (gun ?? DateTime.Today).Date;
            await using var baglanti = await veri.AcAsync(iptal);

            // --------------------------------------------------- sayaclar ----
            var sayaclar = await baglanti.TekAsync("""
                select
                  (select count(*) from public.randevu r
                    where r.cihaz_id is not null
                      and r.baslangic::date = @p0
                      and coalesce(r.durum, 1) <> 4
                      and (@p1::int is null or r.sube_id = @p1))          as "randevu",
                  (select count(*) from public.radyoloji_istem i
                    where i.durum = 1
                      and (@p1::int is null or i.sube_id = @p1))          as "cekimBekleyen",
                  (select count(*) from public.radyoloji_istem i
                    where i.durum in (2, 3, 4)
                      and (@p1::int is null or i.sube_id = @p1))          as "raporlanacak",
                  (select count(*) from public.v_radyoloji_kritik_takip k
                    where k.takip_durum < 4
                      and (@p1::int is null or k.sube_id = @p1))          as "acikKritik",
                  (select count(*) from public.v_radyoloji_teslim_takip t
                    where t.takip_durum = 1
                      and (@p1::int is null or t.sube_id = @p1))          as "teslimBekleyen",
                  (select count(*) from public.radyoloji_rapor r
                     join public.radyoloji_istem i on i.id = r.istem_id
                    where r.onay_tarihi::date = @p0
                      and (@p1::int is null or i.sube_id = @p1))          as "tamamlanan",
                  (select count(*) from public.radyoloji_konsultasyon ks
                     join public.radyoloji_istem i on i.id = ks.istem_id
                    where ks.durum = 1
                      and (@p1::int is null or i.sube_id = @p1))          as "konsultasyon",
                  (select count(*) from public.radyoloji_istem i
                    where i.durum = 1 and i.randevu_id is null
                      and (@p1::int is null or i.sube_id = @p1))          as "randevusuz"
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // -------------------------------------------- cihaz dolulugu ----
            // Payda: cihazin o gunku MESAI dakikasi eksi ogle arasi ve kapatma.
            //   Randevusuz (walk-in) cihazda mesai hesabi anlamsizdir - ekran
            //   oran yerine "walk-in" gosterir.
            var cihazlar = await baglanti.ListeAsync("""
                with c as (
                  select c.id, c.ad, c.modalite, c.randevu_verilir,
                         c.baslangic_saat, c.bitis_saat,
                         c.ogle_baslangic, c.ogle_bitis
                    from public.radyoloji_cihaz c
                   where coalesce(c.durum, 1) = 1
                     and (@p1::int is null or c.sube_id = @p1)
                ), m as (
                  select c.*,
                         case when c.baslangic_saat <> '' and c.bitis_saat <> ''
                              then greatest(0, extract(epoch from
                                     (c.bitis_saat::time - c.baslangic_saat::time)) / 60)
                              else 0 end as mesai_dk,
                         case when c.ogle_baslangic <> '' and c.ogle_bitis <> ''
                              then greatest(0, extract(epoch from
                                     (c.ogle_bitis::time - c.ogle_baslangic::time)) / 60)
                              else 0 end as ogle_dk
                    from c
                )
                select m.id, m.ad,
                       coalesce(kd.ad, '') as "modaliteAdi",
                       m.randevu_verilir as "randevuVerilir",
                       case when m.baslangic_saat <> ''
                            then m.baslangic_saat || '-' || m.bitis_saat else '' end as mesai,
                       greatest(0, (m.mesai_dk - m.ogle_dk))::int as "mesaiDk",
                       -- Kapatmanin GUN ICINE dusen kismi (cok gunluk kapatma kirpilir).
                       coalesce((select sum(extract(epoch from
                                  (least(k.bitis, @p0::date + interval '1 day')
                                   - greatest(k.baslangic, @p0::date))) / 60)
                                   from public.radyoloji_cihaz_kapatma k
                                  where k.cihaz_id = m.id
                                    and k.baslangic < (@p0::date + interval '1 day')
                                    and k.bitis > @p0::date), 0)::int as "kapaliDk",
                       coalesce((select sum(greatest(coalesce(r.sure_dk, 0), 0))
                                   from public.randevu r
                                  where r.cihaz_id = m.id
                                    and r.baslangic::date = @p0
                                    and coalesce(r.durum, 1) not in (3, 4)), 0)::int as "doluDk",
                       (select count(*) from public.radyoloji_istem i
                         where i.cihaz_id = m.id and i.durum > 0
                           and coalesce(i.cekim_tarihi, i.ekleme_tarihi)::date = @p0)
                                                                          as "bugunIs"
                  from m
                  left join public.kod_liste kl on kl.kod = 'rad.modalite'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = m.modalite
                 order by m.modalite, m.ad
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ------------------------------------------- modalite dagilimi ----
            // Son 30 gun: tek gunluk dagilim kucuk kurumda anlamsiz dalgalanir.
            var modalite = await baglanti.ListeAsync("""
                select i.modalite, coalesce(kd.ad, '') as "modaliteAdi",
                       count(*)                                           as "toplam",
                       count(*) filter (where coalesce(i.cekim_tarihi, i.ekleme_tarihi)::date = @p0)
                                                                          as "bugun",
                       count(*) filter (where i.durum in (2, 3, 4))       as "raporsuz",
                       -- Cekimden rapor ONAYINA gecen ortalama sure: modulun
                       --   asil hiz olcusu. Onaylanmamis istem hesaba girmez.
                       coalesce(avg(extract(epoch from (r.onay_tarihi - i.cekim_tarihi)) / 60)
                                filter (where r.onay_tarihi is not null
                                          and i.cekim_tarihi is not null), 0)::int as "ortRaporDk"
                  from public.radyoloji_istem i
                  left join lateral (
                       select max(x.onay_tarihi) as onay_tarihi
                         from public.radyoloji_rapor x where x.istem_id = i.id) r on true
                  left join public.kod_liste kl on kl.kod = 'rad.modalite'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = i.modalite
                 where i.durum > 0
                   and (@p1::int is null or i.sube_id = @p1)
                   and coalesce(i.cekim_tarihi, i.ekleme_tarihi) >= (@p0::date - interval '30 day')
                 group by i.modalite, kd.ad
                 order by 3 desc
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ---------------------------------------------- radyolog yuku ----
            // Acik = yazilmis ama onaylanmamis rapor (taslak / on rapor).
            //   Asistan raporlari onaya duser: "onaylanan" uzman onayini sayar.
            var radyologlar = await baglanti.ListeAsync("""
                select coalesce(t.unvan, '(atanmamış)') as radyolog,
                       count(*) filter (where r.durum < 3)                as "acik",
                       count(*) filter (where r.onay_tarihi::date = @p0)  as "onaylanan",
                       coalesce(avg(extract(epoch from (r.onay_tarihi - r.yazma_tarihi)) / 60)
                                filter (where r.onay_tarihi is not null), 0)::int as "ortDk"
                  from public.radyoloji_rapor r
                  join public.radyoloji_istem i on i.id = r.istem_id
                  left join public.taraf t on t.id = coalesce(r.yazan_id, r.onaylayan_id)
                 where (@p1::int is null or i.sube_id = @p1)
                   and (r.durum < 3 or r.onay_tarihi::date = @p0)
                 group by t.unvan
                 order by 2 desc, 3 desc
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ------------------------------------------------- uyarilar ----
            // "Dikkat gerektirenler": her satir bir LISTEYE gider. Sayac
            //   sifirsa satir hic uretilmez - bos uyari kutusu iyi haberdir.
            var uyarilar = new List<object>();

            var gecKritik = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.v_radyoloji_kritik_takip k
                 where k.takip_durum = 1 and k.gecen_dk > 60
                   and (@p0::int is null or k.sube_id = @p0)
                """, null, [baglam.SubeId], iptal);
            if (gecKritik > 0)
                uyarilar.Add(new { tip = "teh", ik = "🚨",
                    metin = $"{gecKritik} kritik bulgu 60 dakikadır bildirilmedi.",
                    yol = "/radyoloji-kritik" });

            var eskiRandevusuz = await baglanti.TekDegerAsync<int?>("""
                select (extract(epoch from (now()::timestamp - min(i.ekleme_tarihi))) / 86400)::int
                  from public.radyoloji_istem i
                 where i.durum = 1 and i.randevu_id is null
                   and (@p0::int is null or i.sube_id = @p0)
                """, null, [baglam.SubeId], iptal);
            var randevusuz = Convert.ToInt32(sayaclar?["randevusuz"] ?? 0);
            if (randevusuz > 0)
                uyarilar.Add(new { tip = "uy", ik = "🕐",
                    metin = $"{randevusuz} istem randevusuz bekliyor"
                            + (eskiRandevusuz is > 0 ? $" - en eskisi {eskiRandevusuz} gündür sırada." : "."),
                    yol = "/randevu" });

            var eskiTeslim = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.v_radyoloji_teslim_takip t
                 where t.takip_durum = 1 and t.bekleme_dk > 7 * 24 * 60
                   and (@p0::int is null or t.sube_id = @p0)
                """, null, [baglam.SubeId], iptal);
            if (eskiTeslim > 0)
                uyarilar.Add(new { tip = "uy", ik = "📦",
                    metin = $"{eskiTeslim} sonuç 7 günden uzun süredir alınmadı - hasta aranmalı.",
                    yol = "/radyoloji-teslim" });

            var konsul = Convert.ToInt32(sayaclar?["konsultasyon"] ?? 0);
            if (konsul > 0)
                uyarilar.Add(new { tip = "uy", ik = "🧑‍⚕️",
                    metin = $"{konsul} konsültasyon cevap bekliyor.",
                    yol = "/radyoloji-konsultasyon" });

            var kapali = await baglanti.ListeAsync("""
                select coalesce(c.ad, '') as cihaz,
                       coalesce(nullif(k.aciklama, ''), coalesce(kd.ad, 'Kapalı')) as neden
                  from public.radyoloji_cihaz_kapatma k
                  join public.radyoloji_cihaz c on c.id = k.cihaz_id
                  left join public.kod_liste kl on kl.kod = 'rad.kapatma'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = k.neden_tur
                 where k.baslangic < (@p0::date + interval '1 day') and k.bitis > @p0::date
                   and (@p1::int is null or c.sube_id = @p1)
                 order by k.baslangic
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            foreach (var k in kapali)
                uyarilar.Add(new { tip = "uy", ik = "🔒",
                    metin = $"{k["cihaz"]} bugün kapalı: {k["neden"]}.",
                    yol = "/randevu" });

            return Results.Ok(new { tarih = tarih.ToString("yyyy-MM-dd"),
                                    sayaclar, cihazlar, modalite, radyologlar, uyarilar });
        });

        // ----------------------------------------------- cihaz kapatmalar ----
        // TAKVIMDE GORUNURLUK (318): kapatma kurali randevuyu zaten engelliyordu
        //   (316 tetigi) ama takvim bos gosterdigi icin kullanici o saate
        //   randevu vermeye calisip hata aliyordu. Takvim bu ucu okuyup
        //   arali blok cizer. Cihazin ogle arasi da ayni listede doner:
        //   kullanici acisindan ikisi de "kapali saat".
        grup.MapGet("/cihaz-kapatma", async (
            DateTime bas, DateTime bit, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select k.id, k.cihaz_id as "cihazId", k.baslangic, k.bitis,
                       k.neden_tur as "nedenTur",
                       coalesce(nullif(k.aciklama, ''), coalesce(kd.ad, 'Kapalı')) as aciklama,
                       coalesce(kd.ad, '') as "nedenAdi",
                       coalesce(c.ad, '') as cihaz
                  from public.radyoloji_cihaz_kapatma k
                  join public.radyoloji_cihaz c on c.id = k.cihaz_id
                  left join public.kod_liste kl on kl.kod = 'rad.kapatma'
                  left join public.kod_deger kd
                         on kd.liste_id = kl.id and kd.deger = k.neden_tur
                 where k.baslangic < @p1 and k.bitis > @p0
                   and (@p2::int is null or c.sube_id = @p2)
                 order by k.cihaz_id, k.baslangic
                """, null, [bas, bit, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Cihazin OGLE ARASI: ayri tablo degil cihaz ayari - takvimde ayni
            //   bicimde cizilsin diye burada aralik satirina cevrilir.
            var cihazlar = await baglanti.ListeAsync("""
                select c.id, c.ad, c.ogle_baslangic as "ogleBaslangic",
                       c.ogle_bitis as "ogleBitis"
                  from public.radyoloji_cihaz c
                 where coalesce(c.durum, 1) = 1 and c.randevu_verilir = 1
                   and c.ogle_baslangic <> '' and c.ogle_bitis <> ''
                   and (@p0::int is null or c.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { kapatmalar = satirlar, ogleArasi = cihazlar });
        });

        // KAPATMA EKLEME (318): takvimden "Cihazı Kapat". Aralıga düsen
        //   randevular SAYILIR ve kullaniciya bildirilir - tetik yalniz
        //   yeni/degisen randevuyu denetler, mevcutlar kapali saatte kalir.
        grup.MapPost("/cihaz/{id:int}/kapatma", async (
            int id, KapatmaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);

            if (istek.Bitis <= istek.Baslangic)
                throw GentegreHatasi.IsKurali("Kapatma bitişi başlangıçtan sonra olmalı.");

            await using var baglanti = await veri.AcAsync(iptal);

            var etkilenen = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.randevu r
                 where r.cihaz_id = @p0
                   and coalesce(r.durum, 1) not in (3, 4)
                   and r.baslangic < @p2
                   and (r.baslangic + make_interval(mins => greatest(coalesce(r.sure_dk, 0), 1)))
                       > @p1
                """, null, [id, istek.Baslangic, istek.Bitis], iptal);

            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.radyoloji_cihaz_kapatma
                       (cihaz_id, baslangic, bitis, neden_tur, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5)
                returning id
                """, null,
                [id, istek.Baslangic, istek.Bitis, istek.NedenTur ?? (short)1,
                 istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            return Results.Ok(new { id = yeni, etkilenenRandevu = etkilenen });
        });

        // ------------------------------------------- randevu bekleyenler ----
        // Randevusu olmayan (ve iptal/cekilmis olmayan) istemler: takvimin
        //   yan panelinde durur, bos slota surukleyince randevu olur.
        grup.MapGet("/randevu-bekleyen", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select i.id, i.accession_no as "accessionNo", i.modalite,
                       coalesce(kd.ad, '') as "modaliteAdi",
                       coalesce(h.unvan, '') as hasta, i.hasta_id as "hastaId",
                       coalesce(hz.ad, '') as tetkik, i.hizmet_id as "hizmetId",
                       i.oncelik,
                       -- SURE: tetkikin protokolu (314) - takvimde slot boyu bu.
                       coalesce(nullif(p.sure_dk, 0), 0) as "sureDk",
                       i.ekleme_tarihi as "istemZamani"
                  from public.radyoloji_istem i
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.radyoloji_protokol p on p.hizmet_id = i.hizmet_id
                  left join public.kod_liste kl on kl.kod = 'rad.modalite'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = i.modalite
                 where i.durum = 1 and i.randevu_id is null
                   and (@p0::int is null or i.sube_id = @p0)
                 order by i.oncelik desc, i.ekleme_tarihi
                 limit 100
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(satirlar);
        });

        // İSTEMDEN RANDEVU (316): randevu ayrı modül değil - kayıt yine
        //   public.randevu'ya gider, yalnız kaynağı CİHAZ olur. Çakışma,
        //   kapasite ve cihaz kapatma kuralı tetiktedir.
        grup.MapPost("/istem/{id:int}/randevu", async (
            int id, RandevuIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);

            var istem = await baglanti.TekAsync("""
                select i.hasta_id as "hastaId", i.hizmet_id as "hizmetId",
                       i.randevu_id as "randevuId", i.durum, i.sube_id as "subeId",
                       coalesce(nullif(p.sure_dk, 0), 0) as "protokolSure",
                       coalesce(c.varsayilan_sure, 15) as "cihazSure",
                       coalesce(c.randevu_verilir, 1) as "randevuVerilir",
                       coalesce(c.modalite, 0) as "cihazModalite",
                       coalesce(c.ad, '') as "cihazAdi",
                       coalesce(i.modalite, 0) as "istemModalite",
                       coalesce(km.ad, '') as "istemModaliteAdi",
                       coalesce(kc.ad, '') as "cihazModaliteAdi"
                  from public.radyoloji_istem i
                  left join public.radyoloji_protokol p on p.hizmet_id = i.hizmet_id
                  left join public.radyoloji_cihaz c on c.id = @p1
                  left join public.kod_liste kl on kl.kod = 'rad.modalite'
                  left join public.kod_deger km
                         on km.liste_id = kl.id and km.deger = i.modalite
                  left join public.kod_deger kc
                         on kc.liste_id = kl.id and kc.deger = c.modalite
                 where i.id = @p0
                """, null, [id, istek.CihazId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            if (Convert.ToInt32(istem["durum"]) == 0)
                throw GentegreHatasi.IsKurali("İptal edilmiş isteme randevu verilemez.");
            if (istem["randevuId"] is not null)
                throw GentegreHatasi.IsKurali("Bu istemin zaten randevusu var - önce onu taşıyın ya da iptal edin.");
            if (Convert.ToInt32(istem["randevuVerilir"]) == 0)
                throw GentegreHatasi.IsKurali("Bu cihaz randevusuz (walk-in) çalışıyor.");

            // MODALITE UYUMU: MR istemi BT cihazina randevulanamaz - surukle-birak
            //   ile yanlis sutuna dusmesi kolay oldugu icin kural sunucuda.
            var istemMod = Convert.ToInt32(istem["istemModalite"]);
            var cihazMod = Convert.ToInt32(istem["cihazModalite"]);
            if (istemMod != 0 && cihazMod != 0 && istemMod != cihazMod)
                throw GentegreHatasi.IsKurali(
                    $"Cihazın modalitesi istemle uyuşmuyor - istem: "
                    + $"{istem["istemModaliteAdi"]}, cihaz: {istem["cihazAdi"]} "
                    + $"({istem["cihazModaliteAdi"]}).");

            // SURE SIRASI: istekte verilen > tetkik protokolu (314) > cihaz varsayilani.
            var sure = istek.SureDk is > 0 ? istek.SureDk.Value
                     : Convert.ToInt16(istem["protokolSure"]) > 0
                        ? Convert.ToInt16(istem["protokolSure"])
                        : Convert.ToInt16(istem["cihazSure"]);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var randevuId = await baglanti.TekDegerAsync<int>("""
                insert into public.randevu
                    (sube_id, hasta_id, cihaz_id, hizmet_id, baslangic, sure_dk,
                     durum, tip, kaynak, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 1, 3, 1, @p6, @p7)
                returning id
                """, islem,
                [baglam.SubeId ?? istem["subeId"], istem["hastaId"], istek.CihazId,
                 istem["hizmetId"], istek.Baslangic, sure, istek.Aciklama ?? "",
                 baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.radyoloji_istem
                   set randevu_id = @p1, tekniker_id = coalesce(@p2, tekniker_id),
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, randevuId, istek.TeknikerId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloIstem, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, null, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { randevuId, sureDk = sure });
        });
    }
}

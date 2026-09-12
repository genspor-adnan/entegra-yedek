using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GENETİK — vaka, izolasyon, run, varyant, doğrulama.
///
/// Uclar LabUclari.cs dosyasindan ayrildi: tek dosyada 2103 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class LabUclari
{
    private static void GenetikEkle(RouteGroupBuilder grup)
    {
        // ----------------------------------------------------------- genetik ---

        // POST /api/lab/satir/{id}/genetik-vaka - istemden vaka açar.
        grup.MapPost("/satir/{id:int}/genetik-vaka", async (
            int id, GenetikServisi.VakaIstegi? istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Ekle);

            var (vakaId, vakaNo) = await genetik.VakaAcAsync(id,
                istek ?? new GenetikServisi.VakaIstegi(null, null, null, null, null, null),
                baglam, iptal);
            return Results.Ok(new { vakaId, vakaNo,
                mesaj = $"Genetik vaka açıldı: {vakaNo}. Rapor için ONAM kaydı şart.",
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/genetik/{id} - vaka + run + varyantlar (çalışma alanı
        //   ve raporun tek kaynağı).
        grup.MapGet("/genetik/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Gor);

            var v = await veri.TekAsync("""
                select g.id, g.vaka_no, g.durum, g.endikasyon, g.tani_icd, g.aile_oykusu,
                       g.onam_surum, g.onam_tarihi, g.tesadufi_bulgu, g.veri_saklama_yil,
                       g.arastirma_izni, g.izolasyon_tarihi, g.dna_konsantrasyon,
                       g.dna_saflik, g.kapsama_yuzde, g.ort_derinlik, g.kontaminasyon,
                       g.cinsiyet_dogrulama, g.sonuc_ozeti, g.uzman_yorum, g.oneriler,
                       g.sinirliliklar, g.onay_zamani, g.hedef_bitis, g.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
                       coalesce(p.kod || ' · ' || p.ad, ''), coalesce(r.kod, ''),
                       coalesce(n.barkod, ''), t.kod, t.ad,
                       public.fn_lab_genetik_ozet(g.id), g.istem_id, g.istem_satir_id,
                       coalesce(p.referans_genom, ''), coalesce(p.pipeline, '')
                  from public.lab_genetik_vaka g
                  join public.taraf h on h.id = g.hasta_id
                  join public.lab_tetkik t on t.id = g.tetkik_id
                  left join public.lab_genetik_panel p on p.id = g.panel_id
                  left join public.lab_genetik_run r on r.id = g.run_id
                  left join public.lab_numune n on n.id = g.numune_id
                 where g.id = @p0
                """, [id],
                o => new {
                    Id = o.GetInt32(0), VakaNo = o.GetString(1), Durum = o.GetInt16(2),
                    Endikasyon = o.GetString(3), TaniIcd = o.GetString(4),
                    AileOykusu = o.GetString(5), OnamSurum = o.GetString(6),
                    OnamTarihi = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                    TesadufiBulgu = o.GetInt16(8), VeriSaklamaYil = o.GetInt16(9),
                    ArastirmaIzni = o.GetInt16(10) == 1,
                    IzolasyonTarihi = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
                    DnaKonsantrasyon = o.IsDBNull(12) ? (decimal?)null : o.GetDecimal(12),
                    DnaSaflik = o.IsDBNull(13) ? (decimal?)null : o.GetDecimal(13),
                    KapsamaYuzde = o.IsDBNull(14) ? (decimal?)null : o.GetDecimal(14),
                    OrtDerinlik = o.IsDBNull(15) ? (decimal?)null : o.GetDecimal(15),
                    Kontaminasyon = o.IsDBNull(16) ? (decimal?)null : o.GetDecimal(16),
                    CinsiyetDogrulama = o.GetInt16(17), SonucOzeti = o.GetString(18),
                    UzmanYorum = o.GetString(19), Oneriler = o.GetString(20),
                    Sinirliliklar = o.GetString(21),
                    OnayZamani = o.IsDBNull(22) ? (DateTime?)null : o.GetDateTime(22),
                    HedefBitis = o.IsDBNull(23) ? (DateTime?)null : o.GetDateTime(23),
                    HastaId = o.GetInt32(24), Hasta = o.GetString(25),
                    Panel = o.GetString(26), Run = o.GetString(27),
                    Barkod = o.GetString(28), TetkikKod = o.GetString(29),
                    TetkikAd = o.GetString(30), Ozet = o.GetString(31),
                    IstemId = o.GetInt32(32), IstemSatirId = o.GetInt32(33),
                    ReferansGenom = o.GetString(34), Pipeline = o.GetString(35) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Genetik vaka bulunamadı.");

            // Varyantlar RAPOR SIRASIYLA: önce patojenik. Raporlanmayanlar da
            //   döner ("raporla" bayrağıyla) - uzman neyin dışarıda kaldığını
            //   görebilmeli.
            var varyantlar = await veri.ListeAsync("""
                select v.id, v.gen_sembol, v.transkript, v.hgvs_c, v.hgvs_p, v.zigosite,
                       v.kalitim, v.derinlik, v.vaf, v.gnomad_af, v.clinvar,
                       v.acmg_kriterler, v.sinif, v.sinif_elle, v.sinif_neden,
                       v.raporla, v.ikincil_bulgu, v.dogrulama, v.dogrulama_yontem,
                       v.yorum
                  from public.lab_varyant v
                 where v.vaka_id = @p0
                 order by v.sinif desc, v.gen_sembol
                """, [id],
                o => new { Id = o.GetInt32(0), GenSembol = o.GetString(1),
                           Transkript = o.GetString(2), HgvsC = o.GetString(3),
                           HgvsP = o.GetString(4), Zigosite = o.GetInt16(5),
                           Kalitim = o.GetInt16(6),
                           Derinlik = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                           Vaf = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                           GnomadAf = o.IsDBNull(9) ? (decimal?)null : o.GetDecimal(9),
                           ClinVar = o.GetString(10),
                           Acmg = o.IsDBNull(11) ? Array.Empty<string>()
                                                 : o.GetFieldValue<string[]>(11),
                           Sinif = o.GetInt16(12), SinifElle = o.GetInt16(13) == 1,
                           SinifNeden = o.GetString(14), Raporla = o.GetInt16(15) == 1,
                           IkincilBulgu = o.GetInt16(16) == 1,
                           Dogrulama = o.GetInt16(17), DogrulamaYontem = o.GetString(18),
                           Yorum = o.GetString(19) }, iptal);

            return Results.Ok(new { vaka = v, varyantlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/genetik/{id}/onam - KVKK md. 6: onamsız rapor yok.
        grup.MapPost("/genetik/{id:int}/onam", async (
            int id, GenetikServisi.OnamIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.OnamAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/izolasyon", async (
            int id, GenetikServisi.IzolasyonIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.IzolasyonAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/run", async (
            int id, GenetikServisi.RunaAlIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var (runId, runKodu) = await genetik.RunaAlAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, runId, runKodu,
                mesaj = $"Vaka {runKodu} run'ına alındı.", izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/kalite", async (
            int id, GenetikServisi.KaliteIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.KaliteAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/genetik/{id}/varyant - sınıf ACMG kanıtlarından türetilir.
        grup.MapPost("/genetik/{id:int}/varyant", async (
            int id, GenetikServisi.VaryantIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var s = await genetik.VaryantAsync(id, istek, baglam, iptal);
            return Results.Ok(new { s.Id, s.Sinif, s.SinifAdi, s.Raporlanir,
                s.BankaUyarisi,
                mesaj = $"{istek.GenSembol} {istek.HgvsC} → {s.SinifAdi}"
                      + (s.Raporlanir ? " (raporlanacak)" : " (raporlanmayacak)"),
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/varyant/{id:int}/sinif", async (
            int id, VaryantSinifIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await genetik.SinifDegistirAsync(id, istek.Sinif, istek.Neden,
                                                         istek.Raporla, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/varyant/{id}/dogrulama - 1 istendi · 2 doğrulandı ·
        //   3 doğrulanamadı (rapordan çıkar).
        grup.MapPost("/varyant/{id:int}/dogrulama", async (
            int id, DogrulamaIstegi istek, BaglamCozucu cozucu, GenetikServisi genetik,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.DogrulamaAsync(id, istek.Durum, istek.Yontem,
                                                     baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/onayla", async (
            int id, GenetikOnayIstegi? istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await genetik.OnaylaAsync(id, istek?.Yorum, istek?.Oneriler,
                                                  istek?.Sinirliliklar, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/iptal", async (
            int id, KulturIptalIstegi istek, BaglamCozucu cozucu, GenetikServisi genetik,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.IptalAsync(id, istek.Neden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/genetik/yeniden-degerlendirme - bilgi bankasındaki sınıf
        //   değişince etkilenen ONAYLI vakalar. VUS'un yıllar sonra patojenik
        //   çıkması hastayı doğrudan ilgilendirir; elle takip edilemez.
        grup.MapGet("/genetik/yeniden-degerlendirme", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select y.varyant_id, y.vaka_id, y.vaka_no, y.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
                       y.gen_sembol, y.hgvs_c, y.rapor_sinif, y.guncel_sinif,
                       y.degerlendirme_tarihi
                  from public.v_lab_varyant_yeniden y
                  join public.taraf h on h.id = y.hasta_id
                 order by y.degerlendirme_tarihi desc
                """, [],
                o => new { VaryantId = o.GetInt32(0), VakaId = o.GetInt32(1),
                           VakaNo = o.GetString(2), HastaId = o.GetInt32(3),
                           Hasta = o.GetString(4), GenSembol = o.GetString(5),
                           HgvsC = o.GetString(6), RaporSinif = o.GetInt16(7),
                           GuncelSinif = o.GetInt16(8), Tarih = o.GetDateTime(9) },
                iptal);

            return Results.Ok(new { liste, izlemeNo = baglam.IzlemeNo });
        });
    }
}

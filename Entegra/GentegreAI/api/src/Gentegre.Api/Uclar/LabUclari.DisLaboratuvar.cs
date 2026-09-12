using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DIŞ LABORATUVAR — gönderim, teslim, sonuç, fatura.
///
/// Uclar LabUclari.cs dosyasindan ayrildi: tek dosyada 2103 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class LabUclari
{
    private static void DisLaboratuvarEkle(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------- dış laboratuvar ---

        // POST /api/lab/dis/gonder - seçilen tetkikleri dış laboratuvara sevk et.
        //   Numune binadan çıkar; kurye ve soğuk zincir kaydı bu andan sonra
        //   elimizdeki tek iz.
        grup.MapPost("/dis/gonder", async (
            DisLabServisi.GonderimIstegi istek, BaglamCozucu cozucu,
            DisLabServisi dis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.dislab", Islem.Ekle);

            var (id, no, satir) = await dis.GonderAsync(istek, baglam, iptal);
            return Results.Ok(new { id, gonderimNo = no, satir,
                mesaj = $"{no} oluşturuldu · {satir} tetkik gönderildi.",
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/dis/{id:int}/yolda", async (
            int id, BaglamCozucu cozucu, DisLabServisi dis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.dislab", Islem.Degistir);
            return Results.Ok(new { id, mesaj = await dis.YoldaAsync(id, baglam, iptal),
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/dis/{id:int}/teslim", async (
            int id, DisLabServisi.TeslimIstegi istek, BaglamCozucu cozucu,
            DisLabServisi dis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.dislab", Islem.Degistir);
            return Results.Ok(new { id,
                mesaj = await dis.TeslimAsync(id, istek, baglam, iptal),
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/dis/{id}/sonuc - dış laboratuvardan gelen değer.
        //   Referans/bayrak/panik kuralları burada da işler; oto-onay KAPALI.
        grup.MapPost("/dis/{id:int}/sonuc", async (
            int id, DisLabServisi.DisSonucIstegi istek, BaglamCozucu cozucu,
            DisLabServisi dis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Ekle);
            return Results.Ok(new { id,
                mesaj = await dis.SonucAsync(id, istek, baglam, iptal),
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/dis/{id:int}/ret", async (
            int id, DisRetIstegi istek, BaglamCozucu cozucu, DisLabServisi dis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.dislab", Islem.Degistir);
            return Results.Ok(new { id,
                mesaj = await dis.RetAsync(id, istek.IstemSatirId, istek.Durum ?? 3,
                                           istek.Neden, baglam, iptal),
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/dis/{id:int}/fatura", async (
            int id, DisFaturaIstegi istek, BaglamCozucu cozucu, DisLabServisi dis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.dislab", Islem.Degistir);
            return Results.Ok(new { id,
                mesaj = await dis.FaturaAsync(id, istek.BelgeId, istek.Tutar,
                                              baglam, iptal),
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/dis/{id} - gönderim + satırlar (çalışma ekranı).
        grup.MapGet("/dis/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.dislab", Islem.Gor);

            var g = await veri.TekAsync("""
                select g.id, g.gonderim_no as "gonderimNo", g.durum,
                       g.gonderim_zamani as "gonderimZamani", g.kurye_firma as "kuryeFirma",
                       g.kurye_ad as "kuryeAd", g.kurye_tel as "kuryeTel",
                       g.tasima_kosulu as "tasimaKosulu", g.sicaklik, g.kap_sayisi as "kapSayisi",
                       g.teslim_zamani as "teslimZamani", g.teslim_alan as "teslimAlan",
                       g.dis_kabul_no as "disKabulNo", g.tutar, g.aciklama,
                       g.fatura_belge_id as "faturaBelgeId",
                       coalesce(b.belge_no, '') as "faturaNo",
                       d.id as "disLabId", d.ad as "disLab", d.sozlesme_tat_gun as "tatGun",
                       (current_date - g.gonderim_zamani::date) as "gecenGun"
                  from public.lab_dis_gonderim g
                  join public.lab_dis_lab d on d.id = g.dis_lab_id
                  left join public.belge b on b.id = g.fatura_belge_id
                 where g.id = @p0
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Gönderim bulunamadı.");

            var satirlar = await veri.ListeAsync("""
                select gs.id, gs.istem_satir_id as "istemSatirId", t.kod, t.ad,
                       gs.dis_kod as "disKod", gs.birim_fiyat as "birimFiyat",
                       gs.durum, gs.sonuc_zamani as "sonucZamani",
                       gs.ret_neden as "retNeden",
                       coalesce(n.barkod, '') as barkod, i.istem_no as "istemNo",
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan) as hasta,
                       coalesce(ls.deger_metin, '') as deger,
                       coalesce(ls.bayrak, '') as bayrak
                  from public.lab_dis_gonderim_satir gs
                  join public.lab_tetkik t on t.id = gs.tetkik_id
                  join public.lab_istem_satir s on s.id = gs.istem_satir_id
                  join public.lab_istem i on i.id = s.istem_id
                  join public.taraf h on h.id = i.taraf_id
                  left join public.lab_numune n on n.id = gs.numune_id
                  left join lateral (
                        select deger_metin, bayrak from public.lab_sonuc x
                         where x.istem_satir_id = gs.istem_satir_id and x.durum <> 4
                         order by x.id desc limit 1) ls on true
                 where gs.gonderim_id = @p0
                 order by gs.id
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { gonderim = g, satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/dis/geciken - sözleşme TAT'ını aşan gönderimler.
        //   Hastanın sonucu başka bir binada bekliyor; kimse elle takip edemez.
        grup.MapGet("/dis/geciken", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.dislab", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select id, gonderim_no as "gonderimNo", dis_lab as "disLab",
                       gonderim_zamani as "gonderimZamani",
                       sozlesme_tat_gun as "tatGun", gecikme_gun as "gecikmeGun",
                       bekleyen, toplam, durum
                  from public.v_lab_dis_geciken
                 order by gecikme_gun desc
                """, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { liste, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------ cihaz ---

        // GET /api/lab/cihaz/{id}/calisma-listesi/{barkod} - HOST QUERY.
        grup.MapGet("/cihaz/{id:int}/calisma-listesi/{barkod}", async (
            int id, string barkod, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var liste = await servis.CalismaListesiAsync(id, barkod, iptal);
            return Results.Ok(new { cihazId = id, barkod, satirlar = liste,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/cihaz-mesaj/{id}/isle - çözümlenmiş mesajı sonuca yaz.
        grup.MapPost("/cihaz-mesaj/{id:long}/isle", async (
            long id, BaglamCozucu cozucu, LabServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Ekle);

            var s = await servis.CihazMesajIsleAsync(id, baglam, iptal);
            return Results.Ok(new { id, s.Yazilan, s.Atlanan, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}

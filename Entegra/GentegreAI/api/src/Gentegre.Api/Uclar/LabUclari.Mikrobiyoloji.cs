using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MİKROBİYOLOJİ — ekim, kültür, izolat, antibiyogram.
///
/// Uclar LabUclari.cs dosyasindan ayrildi: tek dosyada 2103 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class LabUclari
{
    private static void MikrobiyolojiEkle(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------- mikrobiyoloji ---

        // POST /api/lab/satir/{id}/ekim - kültürü açar (besiyeri seti tetkikten).
        grup.MapPost("/satir/{id:int}/ekim", async (
            int id, KulturServisi.EkimIstegi? istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Ekle);

            var kulturId = await kultur.EkimAsync(id,
                istek ?? new KulturServisi.EkimIstegi(null, null, null, null, null, null),
                baglam, iptal);
            return Results.Ok(new { kulturId, mesaj = "Ekim yapıldı, inkübasyon başladı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/kultur/{id} - kültür + besiyeri + okuma + izolat +
        //   antibiyogram: çalışma alanının ve raporun tek kaynağı.
        grup.MapGet("/kultur/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Gor);

            var k = await veri.TekAsync("""
                select k.id, k.istem_id, k.istem_satir_id, t.kod, t.ad, k.durum,
                       k.ekim_zamani, k.sonraki_okuma, k.sicaklik, k.atmosfer,
                       k.direkt_baki, k.gram_sonuc, k.numune_kalite, k.on_rapor,
                       k.on_rapor_zamani, k.kritik, k.ekk_bildirim, k.uzman_yorum,
                       k.onay_zamani, coalesce(n.barkod, ''), k.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
                       public.fn_lab_kultur_ozet(k.id)
                  from public.lab_kultur k
                  join public.lab_tetkik t on t.id = k.tetkik_id
                  join public.taraf h on h.id = k.hasta_id
                  left join public.lab_numune n on n.id = k.numune_id
                 where k.id = @p0
                """, [id],
                o => new { Id = o.GetInt32(0), IstemId = o.GetInt32(1),
                           IstemSatirId = o.GetInt32(2), TetkikKod = o.GetString(3),
                           TetkikAd = o.GetString(4), Durum = o.GetInt16(5),
                           EkimZamani = o.GetDateTime(6),
                           SonrakiOkuma = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                           Sicaklik = o.GetInt16(8), Atmosfer = o.GetInt16(9),
                           DirektBaki = o.GetString(10), GramSonuc = o.GetString(11),
                           NumuneKalite = o.GetString(12), OnRapor = o.GetString(13),
                           OnRaporZamani = o.IsDBNull(14) ? (DateTime?)null : o.GetDateTime(14),
                           Kritik = o.GetInt16(15) == 1, Ekk = o.GetInt16(16) == 1,
                           UzmanYorum = o.GetString(17),
                           OnayZamani = o.IsDBNull(18) ? (DateTime?)null : o.GetDateTime(18),
                           Barkod = o.GetString(19), HastaId = o.GetInt32(20),
                           Hasta = o.GetString(21), Ozet = o.GetString(22) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kültür bulunamadı.");

            var besiyeriler = await veri.ListeAsync("""
                select kb.id, b.kod, b.ad, kb.lot, kb.sonuc
                  from public.lab_kultur_besiyeri kb
                  join public.lab_besiyeri b on b.id = kb.besiyeri_id
                 where kb.kultur_id = @p0 order by kb.sira, kb.id
                """, [id],
                o => new { Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                           Lot = o.GetString(3), Sonuc = o.GetString(4) }, iptal);

            var okumalar = await veri.ListeAsync("""
                select o.id, o.saat, o.okuma_zamani, o.ureme_var, o.bulgu, o.sonraki_adim
                  from public.lab_kultur_okuma o
                 where o.kultur_id = @p0 order by o.saat, o.id
                """, [id],
                o => new { Id = o.GetInt32(0), Saat = o.GetInt16(1),
                           Zaman = o.GetDateTime(2), UremeVar = o.GetInt16(3) == 1,
                           Bulgu = o.GetString(4), SonrakiAdim = o.GetString(5) }, iptal);

            var izolatlar = await veri.ListeAsync("""
                select u.id, u.izolat_no, o.kod, o.ad, u.koloni_sayisi, u.koloni_birim,
                       u.anlamli, u.id_yontem, u.id_guven, u.esbl, u.karbapenemaz,
                       u.mrsa, u.vre, u.ampc, u.direnc_notu, o.bildirimi_zorunlu
                  from public.lab_kultur_ureme u
                  join public.lab_organizma o on o.id = u.organizma_id
                 where u.kultur_id = @p0 and u.durum = 1
                 order by u.izolat_no
                """, [id],
                o => new { Id = o.GetInt32(0), IzolatNo = o.GetInt16(1),
                           OrganizmaKod = o.GetString(2), Organizma = o.GetString(3),
                           KoloniSayisi = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                           KoloniBirim = o.GetString(5), Anlamli = o.GetInt16(6) == 1,
                           IdYontem = o.GetInt16(7),
                           IdGuven = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                           Esbl = o.GetInt16(9), Karbapenemaz = o.GetInt16(10),
                           Mrsa = o.GetInt16(11), Vre = o.GetInt16(12),
                           Ampc = o.GetInt16(13), DirencNotu = o.GetString(14),
                           BildirimiZorunlu = o.GetInt16(15) == 1 }, iptal);

            // Antibiyogram RAPOR SIRASIYLA gelir: basamak, sonra ad. Kademeli
            //   bildirimde gizlenen satır da döner ("bildir" bayrağıyla) -
            //   uzman neyin gizlendiğini görebilmeli.
            var antibiyogram = await veri.ListeAsync("""
                select g.id, g.ureme_id, a.kod, a.ad, a.basamak, g.mic, g.mic_isaret,
                       g.zon_mm, g.yorum, g.kaynak, g.standart, g.standart_surum,
                       g.bildir, g.aciklama, g.degistirme_neden
                  from public.lab_antibiyogram g
                  join public.lab_antibiyotik a on a.id = g.antibiyotik_id
                  join public.lab_kultur_ureme u on u.id = g.ureme_id
                 where u.kultur_id = @p0
                 order by g.ureme_id, a.basamak, a.ad
                """, [id],
                o => new { Id = o.GetInt32(0), UremeId = o.GetInt32(1),
                           Kod = o.GetString(2), Ad = o.GetString(3),
                           Basamak = o.GetInt16(4),
                           Mic = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                           MicIsaret = o.GetString(6),
                           ZonMm = o.IsDBNull(7) ? (short?)null : o.GetInt16(7),
                           Yorum = o.GetString(8), Kaynak = o.GetInt16(9),
                           Standart = o.GetString(10), StandartSurum = o.GetString(11),
                           Bildir = o.GetInt16(12) == 1, Aciklama = o.GetString(13),
                           DegistirmeNeden = o.GetString(14) }, iptal);

            return Results.Ok(new { kultur = k, besiyeriler, okumalar, izolatlar,
                                    antibiyogram, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/okuma", async (
            int id, KulturServisi.OkumaIstegi istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var mesaj = await kultur.OkumaAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kultur/{id}/on-rapor - Gram / erken bulgu hekime.
        grup.MapPost("/kultur/{id:int}/on-rapor", async (
            int id, OnRaporIstegi istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var mesaj = await kultur.OnRaporAsync(id, istek.Metin, istek.Kritik ?? false,
                                                  baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/izolat", async (
            int id, KulturServisi.IzolatIstegi istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var uremeId = await kultur.IzolatAsync(id, istek, baglam, iptal);
            return Results.Ok(new { uremeId, mesaj = "İzolat kaydedildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/izolat/{id:int}/antibiyogram", async (
            int id, KulturServisi.AntibiyogramIstegi istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var (satir, bildirilen) = await kultur.AntibiyogramAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, satir, bildirilen,
                mesaj = $"{satir} antibiyotik kaydedildi; kademeli bildirimle "
                      + $"{bildirilen} tanesi raporda gösterilecek.",
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/antibiyogram/{id:int}/yorum", async (
            int id, YorumIstegi istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await kultur.YorumDegistirAsync(id, istek.Yorum,
                istek.Bildir ?? true, istek.Neden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/onayla", async (
            int id, UzmanYorumIstegi? istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await kultur.OnaylaAsync(id, istek?.Yorum, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/iptal", async (
            int id, KulturIptalIstegi istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var mesaj = await kultur.IptalAsync(id, istek.Neden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });
    }
}

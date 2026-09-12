using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KALİTE KONTROL — LJ grafiği, DKK, cihaz mesajı, durum.
///
/// Uclar LabUclari.cs dosyasindan ayrildi: tek dosyada 2103 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class LabUclari
{
    private static void KaliteKontrolEkle(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------- kalite kontrol ---

        // POST /api/lab/kk/olcum - KK ölçümü (elle ya da cihazdan).
        //   Z skoru ve Westgard değerlendirmesi SUNUCUDA; ekranda
        //   hesaplansaydı grafik ile karar ayrışırdı.
        grup.MapPost("/kk/olcum", async (
            KaliteKontrolServisi.OlcumIstegi istek, BaglamCozucu cozucu,
            KaliteKontrolServisi kk, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Ekle);

            var s = await kk.OlcumAsync(istek, baglam, iptal);
            return Results.Ok(new { s.Id, s.Z, s.Durum, s.Ihlaller, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kk/olcum/{id}/aksiyon - düzeltici faaliyet (ISO 15189)
        //   ve etkilenen hasta sonuçlarının gözden geçirilmesi.
        grup.MapPost("/kk/olcum/{id:long}/aksiyon", async (
            long id, KaliteKontrolServisi.AksiyonIstegi istek, BaglamCozucu cozucu,
            KaliteKontrolServisi kk, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Degistir);

            var mesaj = await kk.AksiyonAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/kk/lj - Levey-Jennings serisi (grafik ekranının kaynağı).
        //   Z skoru ölçümle saklandığı için burada yeniden hesaplanmaz.
        grup.MapGet("/kk/lj", async (
            int tetkikId, int? lotId, short? seviye, int? gun, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Gor);

            var seri = await veri.ListeAsync("""
                select id, olcum_zamani, deger, z, hedef, sd, durum, ihlaller,
                       seviye, cihaz_kod, materyal_ad, lot, aksiyon, kaynak
                  from public.v_lab_kk_lj
                 where tetkik_id = @p0
                   and (@p1::int is null or lot_id = @p1)
                   and (@p2::smallint is null or seviye = @p2)
                   and olcum_zamani >= now() - make_interval(days => coalesce(@p3, 30))
                 order by olcum_zamani
                """, [tetkikId, lotId, seviye, gun],
                o => new { Id = o.GetInt64(0), Zaman = o.GetDateTime(1),
                           Deger = o.GetDecimal(2),
                           Z = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
                           Hedef = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                           Sd = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                           Durum = o.GetInt16(6),
                           Ihlaller = o.GetFieldValue<string[]>(7),
                           Seviye = o.GetInt16(8), CihazKod = o.GetString(9),
                           Materyal = o.GetString(10), Lot = o.GetString(11),
                           Aksiyon = o.GetString(12), Kaynak = o.GetInt16(13) }, iptal);

            var tetkik = await veri.TekAsync("""
                select t.kod, t.ad, t.birim,
                       public.fn_lab_kk_gecerli(t.id) as gecerli
                  from public.lab_tetkik t where t.id = @p0
                """, [tetkikId],
                o => new { Kod = o.GetString(0), Ad = o.GetString(1),
                           Birim = o.GetString(2), Gecerli = o.GetBoolean(3) }, iptal);

            // CİHAZ OLAYLARI grafikle birlikte döner: kaymanın nedeni çoğu
            //   zaman kalibrasyon ya da reaktif lot değişimidir.
            var olaylar = await veri.ListeAsync("""
                select o.id, o.zaman, o.olay, o.aciklama, o.lot,
                       coalesce(c.kod, '') as cihaz
                  from public.lab_cihaz_olay o
                  left join public.cihaz c on c.id = o.cihaz_id
                 where (o.tetkik_id = @p0 or o.tetkik_id is null)
                   and o.zaman >= now() - make_interval(days => coalesce(@p1, 30))
                 order by o.zaman
                """, [tetkikId, gun],
                o => new { Id = o.GetInt32(0), Zaman = o.GetDateTime(1),
                           Olay = o.GetInt16(2), Aciklama = o.GetString(3),
                           Lot = o.GetString(4), Cihaz = o.GetString(5) }, iptal);

            return Results.Ok(new { tetkik, seri, olaylar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kk/dkk - dış kalite sonucu; SDI sunucuda hesaplanır.
        grup.MapPost("/kk/dkk", async (
            KaliteKontrolServisi.DkkIstegi istek, BaglamCozucu cozucu,
            KaliteKontrolServisi kk, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Ekle);

            var (id, sdi, degerlendirme, mesaj) = await kk.DkkAsync(istek, baglam, iptal);
            return Results.Ok(new { id, sdi, degerlendirme, mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kk/cihaz-mesaj/{id} - cihazdan gelen KONTROL mesajını
        //   KK ölçümüne çevirir (örnek numarası kontrol lotu kodudur).
        grup.MapPost("/kk/cihaz-mesaj/{id:long}", async (
            long id, BaglamCozucu cozucu, KaliteKontrolServisi kk, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Ekle);

            var yazilan = await kk.CihazMesajindanAsync(id, baglam, iptal);
            return Results.Ok(new { id, yazilan,
                mesaj = yazilan > 0 ? $"{yazilan} kontrol ölçümü kaydedildi."
                                    : "Eşleşen tetkik bulunamadı.",
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/kk/durum - testlerin KK geçerliliği (oto-onay penceresi).
        grup.MapGet("/kk/durum", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select t.id, t.kod, t.ad,
                       public.fn_lab_kk_gecerli(t.id) as gecerli,
                       (select max(o.olcum_zamani) from public.lab_kk_olcum o
                         where o.tetkik_id = t.id) as "sonOlcum",
                       (select count(*) from public.lab_kk_olcum o
                         where o.tetkik_id = t.id and o.durum = 3
                           and o.olcum_zamani >= now() - interval '30 days') as "retSayisi"
                  from public.lab_tetkik t
                 where t.durum = 0
                   and exists (select 1 from public.lab_kk_hedef h
                                where h.tetkik_id = t.id and h.durum = 0)
                 order by t.kod
                """, [],
                o => new { Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                           Gecerli = o.GetBoolean(3),
                           SonOlcum = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                           RetSayisi = o.GetInt64(5) }, iptal);

            return Results.Ok(new { liste, izlemeNo = baglam.IzlemeNo });
        });
    }
}

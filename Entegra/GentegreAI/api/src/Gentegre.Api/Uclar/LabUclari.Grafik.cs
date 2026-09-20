using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GRAFİK TİPLİ SONUÇ UÇLARI (892 — KTS denetim maddesi L10).
///
/// <para>Cihazdan gelen eğri otomatik bağlanıyor (`CihazGrafigiBaglaAsync`);
/// buradaki uçlar <b>görüntüleme</b>, <b>elle yükleme</b> (bağlantısı olmayan
/// cihazın çıktısı taranarak eklenir) ve <b>raporda göster/gösterme</b>
/// kararı içindir.</para>
///
/// <para><b>Tür ve rapor kararı kullanıcınındır:</b> HL7 eğrinin ne olduğunu
/// söylemiyor, cihazdan gelen kayıt "diğer" olarak açılıyor. Uzman türü
/// düzeltir ve ham kalibrasyon eğrisini rapordan çıkarabilir.</para>
/// </summary>
public static partial class LabUclari
{
    public sealed record GrafikDuzenleIstegi(short? Tur, string? Baslik, bool? Raporda,
                                             short? Sira, string? Aciklama);

    private static void GrafikEkle(RouteGroupBuilder grup)
    {
        // GET /api/lab/satir/{id}/grafik - tetkikin grafikleri.
        grup.MapGet("/satir/{id:int}/grafik", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Gor);

            // TEST SEVİYESİNDE YETKİ (889): grafik sonucun parçasıdır, sonucu
            //   göremeyen eğrisini de göremez.
            var izin = await veri.TekDegerAsync<bool?>("""
                select public.fn_lab_tetkik_izin(s.tetkik_id, @p1, 'gor')
                  from public.lab_istem_satir s where s.id = @p0
                """, [id, baglam.RolId], iptal);
            if (izin is false)
                throw GentegreHatasi.Yasak("Bu tetkikin sonucunu görme yetkiniz yok.");

            var satirlar = await veri.ListeAsync("""
                select id, tur, baslik, dokuman_id as "dokumanId", content_type as "contentType",
                       boyut, seri_var as "seriVar", seri::text as seri,
                       birim_x as "birimX", birim_y as "birimY", kaynak, cihaz,
                       raporda, sira, aciklama, ekleme_tarihi as "eklemeTarihi"
                  from public.v_lab_sonuc_grafik
                 where satir_id = @p0
                 order by sira, id
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/satir/{id}/grafik - elle yükleme (multipart).
        //   BAĞLANTISIZ CİHAZ GERÇEĞİ: birçok elektroforez/kromatografi
        //   cihazı çıktıyı yalnız kâğıda basar. Tarayıp buraya eklemek,
        //   grafiğin hasta dosyasında olmasının tek yoludur.
        grup.MapPost("/satir/{id:int}/grafik", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, DokumanDeposu dokumanlar,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("lab.grafik.yukle");

            var form = await ctx.Request.ReadFormAsync(iptal);
            var dosya = form.Files.GetFile("dosya")
                ?? throw GentegreHatasi.Dogrulama("Dosya gerekli.",
                       [new("dosya", "Grafik dosyası seçilmedi.")]);

            _ = short.TryParse(form["tur"].ToString(), out var tur);
            var baslik = form["baslik"].ToString().Trim();

            using var akis = new MemoryStream();
            await dosya.CopyToAsync(akis, iptal);

            var liste = await dokumanlar.EkleAsync("lab-sonuc", id,
                string.IsNullOrWhiteSpace(baslik) ? dosya.FileName : baslik,
                dosya.ContentType, akis.ToArray(), false, baglam.Yazma, iptal);
            var dokumanId = liste.Count > 0 ? liste[^1].Id : 0;

            var grafikId = await veri.TekDegerAsync<int>("""
                insert into public.lab_sonuc_grafik
                       (istem_satir_id, sonuc_id, tur, baslik, dokuman_id,
                        kaynak, raporda, ekleyen, sube_id)
                select @p0,
                       -- SONUCA BAĞLA: satırın EN SON canlı sonucu. Sonuç
                       --   yoksa grafik yine eklenir - eğri bazen sonuçtan
                       --   önce gelir (jel görüntüsü okunup sonra yorumlanır).
                       (select r.id from public.lab_sonuc r
                         where r.istem_satir_id = @p0 and r.durum <> 4
                         order by r.id desc limit 1),
                       @p1, @p2, @p3, 2, 1, @p4, coalesce(i.sube_id, 0)
                  from public.lab_istem_satir s
                  join public.lab_istem i on i.id = s.istem_id
                 where s.id = @p0
                returning id
                """,
                [id, tur > 0 ? tur : (short)9,
                 string.IsNullOrWhiteSpace(baslik) ? dosya.FileName : baslik,
                 dokumanId, baglam.KullaniciId], iptal);

            return Results.Ok(new { grafikId, dokumanId,
                mesaj = "Grafik sonuç eklendi.", izlemeNo = baglam.IzlemeNo });
        });

        // PUT /api/lab/grafik/{id} - tür / başlık / raporda bayrağı.
        grup.MapPut("/grafik/{id:int}", async (
            int id, GrafikDuzenleIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync("""
                update public.lab_sonuc_grafik
                   set tur      = coalesce(@p1, tur),
                       baslik   = coalesce(@p2, baslik),
                       raporda  = coalesce(@p3, raporda),
                       sira     = coalesce(@p4, sira),
                       aciklama = coalesce(@p5, aciklama)
                 where id = @p0
                """,
                [id, istek.Tur, istek.Baslik,
                 istek.Raporda is { } r ? (short)(r ? 1 : 0) : null,
                 istek.Sira, istek.Aciklama], iptal);

            if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("Grafik bulunamadı.");
            return Results.Ok(new { id, mesaj = "Grafik güncellendi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // DELETE /api/lab/grafik/{id} - kaydı kaldırır.
        //   DOKÜMAN SİLİNMEZ: aynı içerik başka kayıtlarda da olabilir
        //   (hash-dedup) ve doküman deposunun kendi silme/erişim kuralları
        //   var; burada yalnız sonuç-grafik bağı kopar.
        grup.MapDelete("/grafik/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync(
                "delete from public.lab_sonuc_grafik where id = @p0", [id], iptal);
            if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("Grafik bulunamadı.");

            return Results.Ok(new { id, mesaj = "Grafik kaldırıldı.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}

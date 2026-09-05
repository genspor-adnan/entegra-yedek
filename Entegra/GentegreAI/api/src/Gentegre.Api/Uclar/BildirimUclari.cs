using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BİLDİRİM UÇLARI (399) — kuyruğa koyma ve kuyruk yönetimi.
///
/// Gönderimin kendisi burada YAPILMAZ: uç yalnız satırı kuyruğa koyar,
/// <see cref="Servisler.BildirimIscisi"/> gönderir. Böylece bildirimi doğuran
/// istek (randevu kaydı, panik değer) sağlayıcıyı beklemez.
/// </summary>
public static class BildirimUclari
{
    /// <summary>Şablon kodu ya da doğrudan gövde ile kuyruğa koyma isteği.</summary>
    public sealed record KuyrukIstegi(
        string? SablonKodu, short? Kanal, string Alici,
        Dictionary<string, string>? Degiskenler, string? Konu, string? Govde,
        int? TarafId, short? KaynakTur, int? KaynakId, short? Oncelik,
        DateTime? Planlanan, int? HesapId);

    public static void BildirimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/bildirim").WithTags("Bildirim").RequireAuthorization();

        // POST /api/bildirim - kuyruğa koy
        grup.MapPost("/", async (
            KuyrukIstegi istek, BaglamCozucu cozucu, BildirimDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bildirim", Islem.Ekle);

            var id = await depo.KuyrugaEkleAsync(new BildirimIstegi(
                    istek.SablonKodu,
                    istek.Kanal is { } k ? (BildirimKanali)k : null,
                    istek.Alici ?? "",
                    istek.Degiskenler,
                    istek.Konu, istek.Govde,
                    istek.TarafId, null,
                    istek.KaynakTur ?? 9, istek.KaynakId,
                    istek.Oncelik ?? 5, istek.Planlanan, istek.HesapId),
                baglam.KullaniciId, baglam.SubeId, iptal);

            // id null = ŞABLON PASİF. Hata değil: kurulum o bildirimi kapatmış.
            return Results.Ok(new { id, kuyruga = id is not null, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/bildirim/{id}/log - deneme günlüğü
        grup.MapGet("/{id:long}/log", async (
            long id, BaglamCozucu cozucu, BildirimDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bildirim", Islem.Gor);
            return Results.Ok(new { satirlar = await depo.LogAsync(id, iptal),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/bildirim/{id}/tekrar - hatalı/vazgeçilmiş satırı yeniden kuyruğa al
        grup.MapPost("/{id:long}/tekrar", async (
            long id, BaglamCozucu cozucu, BildirimDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bildirim", Islem.Degistir);
            var adet = await depo.TekrarDeneAsync(id, iptal);
            // 0 satır = kayıt zaten gönderilmiş ya da kuyrukta; sessiz "tamam"
            //   yerine açık cevap veriliyor - ekran ne olduğunu söylesin.
            return Results.Ok(new { tekrar = adet > 0, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/bildirim/{id}/iptal
        grup.MapPost("/{id:long}/iptal", async (
            long id, BaglamCozucu cozucu, BildirimDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bildirim", Islem.Degistir);
            var adet = await depo.IptalAsync(id, iptal);
            return Results.Ok(new { iptal = adet > 0, izlemeNo = baglam.IzlemeNo });
        });
    }
}

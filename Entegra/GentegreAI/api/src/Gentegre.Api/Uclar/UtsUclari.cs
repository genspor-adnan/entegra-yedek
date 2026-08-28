using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÜTS uçları (223) - ekran YALNIZ bunları çağırır; endpoint/JSON/DB bilgisi
/// UtsServisi ve altındadır. Listeler generic /api/liste'den (uts-bildirim,
/// uts-envanter kaynakları), hesap düzenleme şube kartından (uts_hesap
/// DetayTanimi) gelir - buradakiler kart/liste sözleşmesine sığmayan işler.
///
/// Yetki: sorgular "uts" görme; bildirim göndermek "uts.bildir", iptal
/// "uts.iptal" aksiyon yetkisi (resmi işlem - görme yetkisi yetmez).
/// </summary>
public static class UtsUclari
{
    public sealed record AlmaIstegi(int? EnvanterId, string? Vbi, decimal? Adet, int? SubeId);
    public sealed record VermeIstegi(string? Uno, string? LotNo, string? SeriNo, decimal? Adet,
        string? KurumNo, string? BelgeNo, DateTime? Git,
        int? StokId, int? SeriLotId, int? BelgeId, int? BelgeSatirId, int? SubeId);
    public sealed record KullanimIstegi(string? Uno, string? LotNo, string? SeriNo, decimal? Adet,
        DateTime? Git, string? HastaTckn, string? HastaAdi, string? HastaSoyadi,
        int? StokId, int? SeriLotId, int? BelgeId, int? BelgeSatirId, int? SubeId);
    public sealed record SorguIstegi(string? Uno, string? LotNo, string? SeriNo, int? SubeId);
    public sealed record UretimIstegi(string? Uno, string? LotNo, string? SeriNo, decimal? Adet,
        DateTime? Urt, DateTime? Skt, int? SubeId);
    public sealed record IthalatIstegi(string? Uno, string? LotNo, string? SeriNo, decimal? Adet,
        DateTime? Urt, DateTime? Skt, int? IthalUlke, int? MenseiUlke,
        string? GumrukBeyanname, int? SubeId);
    public sealed record HekIstegi(string? Uno, string? LotNo, string? SeriNo, decimal? Adet,
        string? Tur, string? DigerAciklama, int? SubeId);
    public sealed record ImhaIstegi(string? Uno, string? LotNo, string? SeriNo, decimal? Adet,
        string? Gerekce, string? DigerAciklama, string? BelgeNo, int? SubeId);
    public sealed record SenkronIstegi(int? SubeId);

    public static void UtsUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/uts").WithTags("Uts").RequireAuthorization();

        // ------------------------------------------------------ hesap durum ----
        grup.MapGet("/hesap-durum", async (int? subeId, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uts", Islem.Gor);
            return Results.Ok(await servis.HesapDurumAsync(subeId ?? baglam.SubeId, iptal));
        });

        // --------------------------------------------------------- sorgular ----
        grup.MapPost("/sorgu/tekil-urun", async (SorguIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uts", Islem.Gor);
            return Results.Ok(await servis.TekilUrunSorgulaAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.SubeId ?? baglam.SubeId, iptal));
        });

        grup.MapPost("/sorgu/ayrintili", async (SorguIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uts", Islem.Gor);
            return Results.Ok(await servis.AyrintiliSorgulaAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.SubeId ?? baglam.SubeId, iptal));
        });

        grup.MapPost("/bildirim/{id:int}/detay-sorgula", async (int id, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uts", Islem.Gor);
            return Results.Ok(await servis.BildirimDetayAsync(id, iptal));
        });

        // ------------------------------------------------ askıdakiler senkron ----
        grup.MapPost("/askidakiler-senkron", async (SenkronIstegi? istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.AskidakilerSenkronAsync(
                istek?.SubeId, baglam.SubeId ?? 0, iptal));
        });

        // ------------------------------------------------------- bildirimler ----
        grup.MapPost("/bildirim/alma", async (AlmaIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.AlmaBildirAsync(
                istek.EnvanterId, istek.Vbi, istek.Adet ?? 0,
                istek.SubeId ?? baglam.SubeId, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/verme", async (VermeIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.VermeBildirAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.Adet ?? 0,
                istek.KurumNo, istek.BelgeNo, istek.Git,
                istek.StokId, istek.SeriLotId, istek.BelgeId, istek.BelgeSatirId,
                istek.SubeId ?? baglam.SubeId, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/kullanim", async (KullanimIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.KullanimBildirAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.Adet ?? 0, istek.Git,
                istek.HastaTckn, istek.HastaAdi, istek.HastaSoyadi,
                istek.StokId, istek.SeriLotId, istek.BelgeId, istek.BelgeSatirId,
                istek.SubeId ?? baglam.SubeId, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/uretim", async (UretimIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.UretimBildirAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.Adet ?? 0,
                istek.Urt, istek.Skt,
                istek.SubeId ?? baglam.SubeId, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/ithalat", async (IthalatIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.IthalatBildirAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.Adet ?? 0,
                istek.Urt, istek.Skt, istek.IthalUlke, istek.MenseiUlke,
                istek.GumrukBeyanname,
                istek.SubeId ?? baglam.SubeId, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/hek", async (HekIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.HekBildirAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.Adet ?? 0,
                istek.Tur, istek.DigerAciklama,
                istek.SubeId ?? baglam.SubeId, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/imha", async (ImhaIstegi istek, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.ImhaBildirAsync(
                istek.Uno, istek.LotNo, istek.SeriNo, istek.Adet ?? 0,
                istek.Gerekce, istek.DigerAciklama, istek.BelgeNo,
                istek.SubeId ?? baglam.SubeId, baglam.Yazma, iptal));
        });

        // Belge koprusu (226): satista verme, alista askidan eslesip alma.
        grup.MapPost("/belge/{id:int}/bildir", async (int id, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.BelgedenBildirAsync(id, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/{id:int}/iptal", async (int id, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.iptal");
            return Results.Ok(await servis.IptalAsync(id, baglam.Yazma, iptal));
        });

        grup.MapPost("/bildirim/{id:int}/yeniden-gonder", async (int id, BaglamCozucu cozucu,
            UtsServisi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("uts.bildir");
            return Results.Ok(await servis.YenidenGonderAsync(id, baglam.Yazma, iptal));
        });
    }
}

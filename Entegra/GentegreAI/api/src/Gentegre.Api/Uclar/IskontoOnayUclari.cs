using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İSKONTO ONAYI (662) — kayıt kabul talep eder, yetkili zilden onaylar.
///
/// İki taraf, iki yetki:
///   · talep açmak  — başvuru satırını görebilen herkes (indirim İSTEMEK
///     yetki gerektirmez; yetki gereken şey onu VERMEKtir),
///   · onay / ret   — `basvuru.iskonto` ve TAVANI talebi karşılayan kullanıcı.
///     Tavanı yetmeyen kişi talebi listesinde HİÇ görmez: göremediği bir şeyi
///     onaylayamaz, gördüğü ama basamadığı düğme ise onu sunucudan ret yemeye
///     gönderirdi.
/// </summary>
public static class IskontoOnayUclari
{
    /// <summary>Kalem bazli oran (673): her satirin kendi yuzdesi.</summary>
    public sealed record TalepKalemi(int SatirId, decimal Oran);
    public sealed record TalepIstegi(int BelgeId, decimal Oran, string Gerekce,
                                     IReadOnlyList<TalepKalemi> Kalemler);
    public sealed record KararIstegi(decimal Oran, string Not);

    public static void IskontoOnayUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/iskonto-talep").WithTags("İskonto")
                      .RequireAuthorization();

        // Belgenin talepleri (ücret sekmesinde durum rozetleri için).
        grup.MapGet("/belge/{belgeId:int}", async (
            int belgeId, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(await depo.BelgeTalepleriAsync(belgeId, iptal));
        });

        // ZİL: bu kullanıcının onayına düşen bekleyen talepler.
        grup.MapGet("/bekleyenler", async (
            BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var tavan = baglam.Yetkiler.AksiyonDegeri("basvuru.iskonto");
            // Yetkisi olmayana BOŞ liste - hata değil: zil herkeste var.
            if (tavan <= 0) return Results.Ok(Array.Empty<object>());
            return Results.Ok(await depo.BekleyenlerAsync(
                baglam.SubeId ?? 0, tavan, iptal));
        });

        // ISKONTO ONAY EKRANI (666): sonuclanan talepler - denetim izi.
        grup.MapGet("/gecmis", async (
            int? gun, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // ONAY EKRANININ KENDI YETKISI (685): denetim izini gormek belge
            //   gormekten ayri bir istir - kayit kabul gorevlisi basvuruyu
            //   gorur ama kimin neyi onayladigini gormesi gerekmez.
            baglam.YetkiIste("iskonto_onay", Islem.Gor);
            return Results.Ok(await depo.GecmisAsync(
                baglam.SubeId ?? 0, Math.Clamp(gun ?? 1, 1, 90), iptal));
        });

        // YETKI LIMITLERI (666): rol tavanlari - onay ekraninin limit sekmesi.
        grup.MapGet("/limitler", async (
            BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("iskonto_onay", Islem.Gor);
            return Results.Ok(await depo.LimitlerAsync(iptal));
        });

        grup.MapPost("/", async (
            TalepIstegi istek, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            if (istek.Kalemler.Count == 0)
                throw GentegreHatasi.Dogrulama("Onaya gönderilecek satır seçilmeli.",
                    new AlanHatasi("kalemler", "En az bir satır seçin."));
            if (!(istek.Oran > 0))
                throw GentegreHatasi.Dogrulama("İskonto oranı sıfırdan büyük olmalı.",
                    new AlanHatasi("oran", "Sıfırdan büyük olmalı."));
            if (istek.Gerekce.Trim().Length == 0)
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                    new AlanHatasi("gerekce", "Zorunlu."));
            // BASLIK ORANI = en yuksek kalem orani: tavan kontrolu onunla
            //   olculur, istemcinin gonderdigi degere guvenilmez.
            var enYuksek = istek.Kalemler.Max(k => k.Oran);
            var id = await depo.TalepAcAsync(istek.BelgeId, enYuksek, istek.Gerekce,
                istek.Kalemler.Select(k => (k.SatirId, k.Oran)).ToList(),
                baglam.Yazma, baglam.SubeId ?? 0, iptal);
            return Results.Ok(new { id });
        });

        grup.MapPost("/{id:int}/onay", async (
            int id, KararIstegi istek, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var tavan = baglam.Yetkiler.AksiyonDegeri("basvuru.iskonto");
            if (tavan <= 0) throw GentegreHatasi.Yetkisiz();
            if (istek.Oran > tavan)
                throw GentegreHatasi.Dogrulama(
                    $"Onaylanan oran yetkinizin üstünde (en çok %{tavan}).",
                    new AlanHatasi("oran", $"En çok %{tavan}."));
            await depo.KararAsync(id, 1, istek.Oran, istek.Not, baglam.Yazma, iptal);
            return Results.Ok(new { durum = 1 });
        });

        grup.MapPost("/{id:int}/ret", async (
            int id, KararIstegi istek, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (baglam.Yetkiler.AksiyonDegeri("basvuru.iskonto") <= 0)
                throw GentegreHatasi.Yetkisiz();
            // RED GEREKÇESİ ZORUNLU: banko onu hastaya söyleyecek.
            if (istek.Not.Trim().Length == 0)
                throw GentegreHatasi.Dogrulama("Ret gerekçesi zorunlu.",
                    new AlanHatasi("not", "Zorunlu."));
            await depo.KararAsync(id, 2, 0, istek.Not, baglam.Yazma, iptal);
            return Results.Ok(new { durum = 2 });
        });
    }
}

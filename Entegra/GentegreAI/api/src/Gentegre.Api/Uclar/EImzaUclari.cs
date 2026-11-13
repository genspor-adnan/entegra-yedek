using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Api.Uclar;

/// <summary>
/// e-İMZA AYARI VE KART LİSTESİ (1337). Ayrıntı: <see cref="EImzaServisi"/>.
///   GET /api/eimza/ayar          → {aktif, kip, url, apiKey}: istemci kipinde tarayıcı GenSigner'a bu adres ve
///                                   anahtarla gider; sunucu kipinde adres/anahtar verilmez (API kendi kullanır).
///   GET /api/eimza/sertifikalar  → sunucu kipinde sunucudaki GenSigner'ın gördüğü kartlar.
/// </summary>
public static class EImzaUclari
{
    public static void EImzaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/eimza").WithTags("e-İmza").RequireAuthorization();

        grup.MapGet("/ayar", async (EImzaServisi eimza, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var a = await eimza.AyarAsync(baglam.SubeId, iptal);
            var istemci = a.Aktif && a.Kip == EImzaServisi.KipIstemci;
            return Results.Ok(new
            {
                aktif = a.Aktif, kip = a.Kip,
                url = istemci ? a.Url : "",
                apiKey = istemci ? a.ApiKey : "",
            });
        });

        grup.MapGet("/sertifikalar", async (EImzaServisi eimza, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var a = await eimza.AyarAsync(baglam.SubeId, iptal);
            if (!a.Aktif) throw GentegreHatasi.IsKurali("e-İmza hesabı tanımlı değil (Ayarlar › Entegrasyon Hesapları › EIMZA).");
            if (a.Kip != EImzaServisi.KipSunucu)
                throw GentegreHatasi.IsKurali("İstemci kipinde kartlar hekimin bilgisayarındaki GenSigner'dan okunur.");
            return Results.Ok(new { sertifikalar = await eimza.SertifikalarAsync(a, iptal) });
        });
    }
}

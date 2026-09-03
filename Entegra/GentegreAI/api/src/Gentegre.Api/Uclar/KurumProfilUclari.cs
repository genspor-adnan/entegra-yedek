using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KURUM PROFILI (359) - Yönetim &gt; Firma Bilgileri &gt; Kurum Tipi &amp;
/// Sistem Ayarlari. Tek satirlik profil + tip/modul kataloglari.
/// </summary>
public static class KurumProfilUclari
{
    public sealed record ProfilIstegi(
        int? UrunModu, string? KurumTipi, string? AltTip, string? Basamak, string? TesisKodu,
        int? SubeYapisi, int? HekimSayisi, int? UniteSayisi, string? Dil, string? ParaBirimi,
        Dictionary<string, int>? Moduller,
        /// <summary>Hangi subenin profili (364). Verilmezse AKTIF sube; 0 = kurum geneli.</summary>
        int? SubeId);

    public static void KurumProfilUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kurum-profil").WithTags("KurumProfil").RequireAuthorization();

        // OKUMA yetki istemez: modul gorunurlugu ekranlarin DAVRANISINI belirler
        //   (menu, kart sekmeleri) - ayar okumasiyla ayni gerekce.
        // `sube` verilmezse AKTIF SUBE okunur; 0 acikca verilirse kurum geneli.
        grup.MapGet("/", async (
            int? sube, BaglamCozucu cozucu, KurumProfilDeposu depo, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var subeId = sube ?? baglam.SubeId ?? 0;
            var (profil, tipler, moduller, matris) = await depo.OkuAsync(subeId, iptal);
            return Results.Ok(new { profil, tipler, moduller, matris, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPut("/", async (
            ProfilIstegi istek, BaglamCozucu cozucu, KurumProfilDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);

            // Eksik alanlar MEVCUT degeri korur: ekran tek sekmeyi kaydederken
            //   otekilerin degerini sifirlamasin.
            // Hedef sube: istekte gelen, yoksa aktif sube (0 = kurum geneli).
            var subeId = istek.SubeId ?? baglam.SubeId ?? 0;
            var (mevcut, _, _, _) = await depo.OkuAsync(subeId, iptal);
            var yeni = new KurumProfil(
                istek.UrunModu    ?? mevcut.UrunModu,
                istek.KurumTipi   ?? mevcut.KurumTipi,
                istek.AltTip      ?? mevcut.AltTip,
                istek.Basamak     ?? mevcut.Basamak,
                istek.TesisKodu   ?? mevcut.TesisKodu,
                istek.SubeYapisi  ?? mevcut.SubeYapisi,
                istek.HekimSayisi ?? mevcut.HekimSayisi,
                istek.UniteSayisi ?? mevcut.UniteSayisi,
                istek.Dil         ?? mevcut.Dil,
                istek.ParaBirimi  ?? mevcut.ParaBirimi,
                istek.Moduller    ?? mevcut.Moduller,
                subeId);

            var sonuc = await depo.YazAsync(yeni, baglam.Yazma, iptal);
            return Results.Ok(new { profil = sonuc, izlemeNo = baglam.IzlemeNo });
        });
    }
}

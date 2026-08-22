using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

public static class ListeUclari
{
    public static void ListeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/liste").WithTags("Liste").RequireAuthorization();

        // POST /api/liste/{kaynak}
        grup.MapPost("/{kaynak}", async (
            string kaynak, ListeIstegi istek, BaglamCozucu cozucu, ListeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KaynakBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var kolonlar = GorunurKolonlar(tanim, baglam);
            if (kolonlar.Count == 0) throw GentegreHatasi.Yasak("Bu listede gorebileceginiz kolon yok.");

            var yanit = await depo.SorgulaAsync(tanim, istek ?? new ListeIstegi(), kolonlar,
                baglam.SubeId, baglam.Kapsam, baglam.IzlemeNo, baglam.KullaniciId, iptal);

            return Results.Ok(yanit);
        });

        // GET /api/liste/{kaynak}/kolonlar  - yetkisiz kolon bu listede de DONMEZ (§2.4)
        grup.MapGet("/{kaynak}/kolonlar", async (
            string kaynak, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KaynakBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var kolonlar = GorunurKolonlar(tanim, baglam)
                .Select(k => new KolonMeta(k.Ad, k.Baslik, k.Tip, k.Hizalama, k.Bicim,
                                           k.Varsayilan, k.Siralanabilir, k.Filtrelenebilir, k.Genislik))
                .ToList();

            return Results.Ok(new { kaynak = tanim.Ad, kolonlar });
        });

        // GET /api/liste  - kullanicinin gorebilecegi kaynaklar
        grup.MapGet("/", async (BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kaynaklar = KaynakKatalogu.Tumu
                .Where(k => baglam.Yetkiler.Var(k.YetkiKodu, Islem.Gor))
                .Select(k => new { k.Ad, k.YetkiKodu })
                .ToList();
            return Results.Ok(new { kaynaklar });
        });
    }

    private static KaynakTanimi KaynakBul(string ad)
        => KaynakKatalogu.Bul(ad)
           ?? throw GentegreHatasi.Bulunamadi($"Bilinmeyen liste kaynagi: {ad}");

    /// <summary>
    /// Alan yetkisi (API §8): yetkisiz kolon yanit govdesinden CIKARILMAZ -
    /// sorguya hic girmez. Boylece deger ne SQL'e ne de log'a dusrer.
    /// </summary>
    private static List<KolonTanimi> GorunurKolonlar(KaynakTanimi tanim, IstekBaglami baglam)
        => tanim.Kolonlar
                .Where(k => baglam.Yetkiler.AlanOkunur(tanim.Ad, k.AlanAdi))
                .ToList();
}

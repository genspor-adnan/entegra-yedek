using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KOD LISTESI YONETIMI (219) - jenerik: kod_liste/kod_deger CRUD'u.
///
/// Ayar combolarinin ETIKETINE tiklaninca acilan KodListesiModali bu uclari
/// kullanir; ayni uclar Yonetim'deki her kod listesine hizmet eder. Okuma
/// serbest (combo secenekleri zaten ekrana gider); yazma "ayar" yetkisine
/// bagli. Silme GERCEK silmedir: deger kayitlarda kullaniliyorsa listelerde
/// adi bos gorunur - bilincli yonetici islemi.
/// </summary>
public static class KodListeUclari
{
    public sealed record DegerIstegi(string Ad, int? Sira, int? Aktif);

    public static void KodListeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kod-liste").WithTags("KodListe").RequireAuthorization();

        // ------------------------------------------------------- degerler ----
        grup.MapGet("/{kod}", async (
            string kod, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            await cozucu.CozAsync(ctx, iptal);
            var liste = await veri.ListeAsync("""
                select d.deger, d.ad, d.sira, d.aktif
                  from public.kod_deger d
                  join public.kod_liste l on l.id = d.liste_id
                 where l.kod = @p0 and d.dil = 0
                 order by d.sira, d.deger
                """, new object?[] { kod },
                r => new { deger = r.GetInt32(0), ad = r.GetString(1),
                           sira = (int)r.GetInt16(2), aktif = (int)r.GetInt16(3) }, iptal);
            return Results.Ok(new { kod, degerler = liste });
        });

        // ---------------------------------------------------------- ekle ----
        grup.MapPost("/{kod}", async (
            string kod, DegerIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);

            var ad = (istek?.Ad ?? "").Trim();
            if (ad.Length is 0 or > 200)
                throw GentegreHatasi.Dogrulama("Ad boş olamaz.",
                    new AlanHatasi("ad", "1-200 karakter."));

            await using var baglanti = await veri.AcAsync(iptal);
            // TekDegerAsync<int?> KULLANMA: Convert.ChangeType Nullable'a
            //   cevirmez ("Invalid cast") - int al, 0 = liste yok.
            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
                select l.id,
                       coalesce((select max(d.deger) from public.kod_deger d
                                  where d.liste_id = l.id), 0) + 1,
                       @p1,
                       coalesce(@p2, coalesce((select max(d.sira) from public.kod_deger d
                                                where d.liste_id = l.id), 0) + 10),
                       1, @p3
                  from public.kod_liste l where l.kod = @p0
                returning deger
                """, null, new object?[] { kod, ad, istek!.Sira, baglam.KullaniciId }, iptal);
            return yeni == 0
                ? Results.NotFound(new { mesaj = $"Kod listesi yok: {kod}" })
                : Results.Ok(new { deger = yeni });
        });

        // ------------------------------------------------------ degistir ----
        grup.MapPut("/{kod}/{deger:int}", async (
            string kod, int deger, DegerIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);

            var ad = (istek?.Ad ?? "").Trim();
            if (ad.Length is 0 or > 200)
                throw GentegreHatasi.Dogrulama("Ad boş olamaz.",
                    new AlanHatasi("ad", "1-200 karakter."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut("""
                update public.kod_deger d
                   set ad = @p2, sira = coalesce(@p3, d.sira),
                       aktif = coalesce(@p4, d.aktif), degistiren = @p5
                  from public.kod_liste l
                 where l.id = d.liste_id and l.kod = @p0 and d.deger = @p1 and d.dil = 0
                """, null, kod, deger, ad, istek!.Sira, istek.Aktif, baglam.KullaniciId);
            return await komut.ExecuteNonQueryAsync(iptal) > 0
                ? Results.Ok(new { })
                : Results.NotFound(new { mesaj = "Kayıt bulunamadı." });
        });

        // ----------------------------------------------------------- sil ----
        grup.MapDelete("/{kod}/{deger:int}", async (
            string kod, int deger, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut("""
                delete from public.kod_deger d
                 using public.kod_liste l
                 where l.id = d.liste_id and l.kod = @p0 and d.deger = @p1
                """, null, kod, deger);
            return await komut.ExecuteNonQueryAsync(iptal) > 0
                ? Results.Ok(new { })
                : Results.NotFound(new { mesaj = "Kayıt bulunamadı." });
        });
    }
}

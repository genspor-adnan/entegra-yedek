using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Kasa (mali) islem uclari - API §9.
///
/// Yetki: kaynak "kasa_islem" + aksiyon yetkileri (kasa.kesinlestir / kasa.iptal).
/// Sube kapsami: baska subenin islemi GORUNMEZ (404 - varligi bile sizmaz).
/// </summary>
public static class KasaUclari
{
    public static void KasaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kasa-islem").WithTags("Kasa").RequireAuthorization();

        // GET /api/kasa-islem-turu - ekran tur sekmeleri + bacak sablonu
        yol.MapGet("/api/kasa-islem-turu", async (
            BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Gor);
            return Results.Ok(new { turler = await depo.TurlerAsync(iptal), izlemeNo = baglam.IzlemeNo });
        }).RequireAuthorization().WithTags("Kasa");

        // GET /api/referans/doviz-kur?cins=USD&tarih=2026-08-22&yon=1
        yol.MapGet("/api/referans/doviz-kur", async (
            string cins, DateTime? tarih, int? yon,
            BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kur = await depo.KurAsync(cins, tarih ?? DateTime.Today, yon ?? 1, iptal);
            return Results.Ok(new
            {
                dovizCinsi = cins,
                tarih = (tarih ?? DateTime.Today).Date,
                kur,
                izlemeNo = baglam.IzlemeNo
            });
        }).RequireAuthorization().WithTags("Kasa");

        // POST /api/kasa-islem
        grup.MapPost("/", async (
            KasaIslemYazmaIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);

            // Kesin kayit ayni anda kesinlestirme demektir - ayri yetki ister.
            if (!istek.Secenekler.Taslak && !istek.Secenekler.Plan)
                baglam.AksiyonIste("kasa.kesinlestir");

            var (id, uyarilar) = await depo.KaydetAsync(
                BaslikDegerleri(istek.Islem), istek.Bacaklar, istek.Secenekler,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.Uyarilar = uyarilar;
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Created($"/api/kasa-islem/{id}", kayit);
        });

        // PUT /api/kasa-islem/{id} - yalniz taslak / plan
        grup.MapPut("/{id:int}", async (
            int id, KasaIslemYazmaIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);
            if (!istek.Secenekler.Taslak && !istek.Secenekler.Plan)
                baglam.AksiyonIste("kasa.kesinlestir");

            await SubeKontrolAsync(depo, id, baglam, iptal);

            var uyarilar = await depo.GuncelleAsync(id, BaslikDegerleri(istek.Islem), istek.Bacaklar,
                istek.Secenekler, istek.Surum,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.Uyarilar = uyarilar;
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(kayit);
        });

        // GET /api/kasa-islem/{id}
        grup.MapGet("/{id:int}", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, KullaniciAramaDeposu arama,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Gor);

            var kayit = await SubeKontrolAsync(depo, id, baglam, iptal);
            await arama.IsaretleAsync(baglam.KullaniciId, "kasa-islem", id, iptal);

            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(kayit);
        });

        // POST /api/kasa-islem/{id}/kesinlestir
        grup.MapPost("/{id:int}/kesinlestir", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);
            baglam.AksiyonIste("kasa.kesinlestir");
            await SubeKontrolAsync(depo, id, baglam, iptal);

            await depo.KesinlestirAsync(id, new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(kayit);
        });

        // POST /api/kasa-islem/{id}/iptal
        grup.MapPost("/{id:int}/iptal", async (
            int id, IptalIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);
            baglam.AksiyonIste("kasa.iptal");

            if (string.IsNullOrWhiteSpace(istek?.Sebep))
                throw GentegreHatasi.Dogrulama("İptal sebebi yazılmalı.",
                    new AlanHatasi("sebep", "Zorunlu."));

            await SubeKontrolAsync(depo, id, baglam, iptal);

            var tersId = await depo.IptalAsync(id, istek.Sebep, istek.Tarih,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(new { islem = kayit.Islem, tersIslemId = tersId, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/kasa-islem/{id}/gerceklestir - plandan tahsilat/odeme uret
        grup.MapPost("/{id:int}/gerceklestir", async (
            int id, GerceklestirIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);
            baglam.AksiyonIste("kasa.gerceklestir");

            if (istek is null || istek.HesapId <= 0)
                throw GentegreHatasi.Dogrulama("Tahsilat/ödeme hesabı seçilmeli.",
                    new AlanHatasi("hesapId", "Zorunlu."));

            await SubeKontrolAsync(depo, id, baglam, iptal);

            var yeniId = await depo.PlanGerceklestirAsync(id, istek.HesapId, istek.Tutar,
                istek.Tarih, istek.Tur, new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(yeniId, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Created($"/api/kasa-islem/{yeniId}", kayit);
        });

        // DELETE /api/kasa-islem/{id} - yalniz taslak / plan (DB trigger de korur)
        grup.MapDelete("/{id:int}", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Sil);
            await SubeKontrolAsync(depo, id, baglam, iptal);

            await depo.SilAsync(id, new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(new { silindi = true, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muhasebe/fis/{id}
        yol.MapGet("/api/muhasebe/fis/{id:int}", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muhasebe_fis", Islem.Gor);
            var fis = await depo.FisOkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new { fis, izlemeNo = baglam.IzlemeNo });
        }).RequireAuthorization().WithTags("Kasa");
    }

    public sealed class IptalIstegi
    {
        public string Sebep { get; set; } = "";
        public DateTime? Tarih { get; set; }
    }

    /// <summary>Tutar bos ise planin KALANI gerceklesir; tur bos ise hesap turunden secilir.</summary>
    public sealed class GerceklestirIstegi
    {
        public int HesapId { get; set; }
        public decimal? Tutar { get; set; }
        public DateTime? Tarih { get; set; }
        public int? Tur { get; set; }
    }

    /// <summary>Baska subenin islemi yokmus gibi davranir (API §8).</summary>
    private static async Task<KasaIslemYaniti> SubeKontrolAsync(
        KasaDeposu depo, int id, IstekBaglami baglam, CancellationToken iptal)
    {
        var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();

        var kapsam = baglam.SubeId;
        if (kapsam is not null &&
            kayit.Islem.TryGetValue("subeId", out var sube) && sube is not null &&
            Convert.ToInt32(sube) != kapsam.Value)
            throw GentegreHatasi.Bulunamadi();

        return kayit;
    }

    /// <summary>
    /// Baslik alan beyaz listesi. Katalogda olmayan bir alan gelirse istek
    /// reddedilir - istemciden gelen ad hicbir zaman SQL'e girmez.
    /// </summary>
    private static Dictionary<string, object?> BaslikDegerleri(Dictionary<string, JsonElement>? gelen)
    {
        var sonuc = new Dictionary<string, object?>(StringComparer.Ordinal);
        if (gelen is null) return sonuc;

        foreach (var (ad, deger) in gelen)
        {
            if (ad is "yerelTutar" or "durum" or "islemNo" or "gerceklesenTutar" or "muhasebeFisId")
                throw GentegreHatasi.Dogrulama($"{ad} sunucuda belirlenir, istekte gönderilemez.",
                    new AlanHatasi(ad, "Sunucu alanı."));

            var tip = BaslikTipi(ad)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen kasa işlemi alanı: {ad}",
                       new AlanHatasi(ad, "Başlıkta böyle bir alan yok."));

            var cevrilmis = DegerCevirici.Cevir(deger, tip, ad, ad);

            if (Uzunluk(ad) is { } sinir && cevrilmis is string m && m.Length > sinir)
                throw GentegreHatasi.Dogrulama($"{ad}: en fazla {sinir} karakter.",
                    new AlanHatasi(ad, $"En fazla {sinir} karakter ({m.Length} geldi)."));

            sonuc[ad] = cevrilmis;
        }
        return sonuc;
    }

    private static string? BaslikTipi(string ad) => ad switch
    {
        "tur" or "tarafId" or "karsiTarafId" or "hesapId" or "karsiHesapId" or "masrafId" or
        "hizmetId" or "projeId" or "merkezId" or "cekSenetId" or "krediTaksitId" or
        "kuponTuruId" or "belgeId" or "planIslemId" or "subeId" or "girisKaynak" => "sayi",

        "tutar" or "dovizKuru" or "karsiTutar" or "karsiKur" or "masrafTutar" => "para",

        "islemTarihi" or "planTarihi" => "tarih",

        "makbuzNo" or "dovizCinsi" or "karsiDovizCinsi" or "tarafUnvan" or "aciklama" => "metin",

        _ => null
    };

    private static int? Uzunluk(string ad) => ad switch
    {
        "dovizCinsi" or "karsiDovizCinsi" => 6,
        "makbuzNo" => 30,
        "tarafUnvan" or "aciklama" => 200,
        _ => null
    };

    private static string Ip(HttpContext ctx)
        => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}

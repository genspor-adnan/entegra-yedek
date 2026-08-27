using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Genel resim/doküman galerisi ucu - {kartAdi} kullanıcının bildiği kart adı ("personel",
/// "cari", "kisi", "stok"), hem yetki kontrolü hem fiziksel `dokuman.kaynak` değerine
/// çevirmek için kullanılır (cari/kisi/personel hepsi `taraf` satırı - tek fiziksel kaynak).
/// </summary>
// KaynakId/Yon/Varsayilan yalniz e-Belge XSLT sablonlarinda kullanilir (160);
// kart dokumanlarinda gonderilmez ve mevcut deger korunur.
public sealed record DuzenleIstegi(string Ad, string? BelgeTuru,
    int? KaynakId = null, short? Yon = null, bool? Varsayilan = null);

public static class DokumanUclari
{
    public static void DokumanUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dokuman/{kartAdi}/{kaynakId:long}").WithTags("Dokuman").RequireAuthorization();

        grup.MapGet("/", async (
            string kartAdi, long kaynakId, BaglamCozucu cozucu, DokumanDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Gor);
            return Results.Ok(await depo.ListeleAsync(FizikselKaynak(kartAdi), kaynakId, iptal));
        });

        grup.MapPost("/", async (
            string kartAdi, long kaynakId, BaglamCozucu cozucu, DokumanDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);

            var form = await ctx.Request.ReadFormAsync(iptal);
            var dosya = form.Files.GetFile("dosya")
                ?? throw GentegreHatasi.Dogrulama("Dosya gerekli.", new AlanHatasi("dosya", "Dosya seçilmedi."));
            var varsayilanIstendi = form["varsayilan"].ToString() == "true";
            // 160: gelen/giden ayrimi (e-Belge XSLT). Verilmezse 0 = uygulanmaz.
            _ = short.TryParse(form["yon"].ToString(), out var yon);

            using var akis = new MemoryStream();
            await dosya.CopyToAsync(akis, iptal);

            // Tarayici .xsl/.xslt icin cogunlukla bos ya da genel tip gonderir;
            //   XSLT kaynaginda tipi biz sabitliyoruz - beyaz listeye takilmasin.
            var tip = kartAdi == "ebelge-xslt" && (string.IsNullOrWhiteSpace(dosya.ContentType)
                        || dosya.ContentType == "application/octet-stream")
                      ? "application/xslt+xml" : dosya.ContentType;

            var liste = await depo.EkleAsync(FizikselKaynak(kartAdi), kaynakId, dosya.FileName,
                tip, akis.ToArray(), varsayilanIstendi,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal, yon);
            return Results.Ok(liste);
        });

        // dokumanId "/{kaynakId}" ile ilgisiz ama URL tutarliligi icin ust grup altinda -
        // gercek anahtar dokumanId, kaynakId sadece yol icin (kullanilmiyor).
        grup.MapPost("/{dokumanId:int}/varsayilan", async (
            string kartAdi, long kaynakId, int dokumanId, BaglamCozucu cozucu, DokumanDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var liste = await depo.VarsayilanYapAsync(dokumanId,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(liste);
        });

        grup.MapPut("/{dokumanId:int}", async (
            string kartAdi, long kaynakId, int dokumanId, DuzenleIstegi istek, BaglamCozucu cozucu,
            DokumanDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var liste = await depo.DuzenleAsync(dokumanId, istek.Ad, istek.BelgeTuru,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal,
                istek.KaynakId, istek.Yon, istek.Varsayilan);
            return Results.Ok(liste);
        });

        grup.MapDelete("/{dokumanId:int}", async (
            string kartAdi, long kaynakId, int dokumanId, BaglamCozucu cozucu, DokumanDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var liste = await depo.SilAsync(dokumanId,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(liste);
        });

        grup.MapPost("/{dokumanId:int}/paylas", async (
            string kartAdi, long kaynakId, int dokumanId, BaglamCozucu cozucu, DokumanDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var kod = await depo.PaylasAsync(dokumanId,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(new { kod });
        });
    }

    // İçerik indirme ayrı bir uc - RequireAuthorization standart Bearer header ister; <img
    // src=...> bunu gönderemediği için frontend içeriği fetch+Authorization ile çekip blob
    // URL'e çevirir (istemci.ts dokumanIcerik) - token URL'de/query string'de TAŞINMAZ.
    public static void DokumanIcerikUcunuEkle(this IEndpointRouteBuilder yol)
    {
        yol.MapGet("/api/dokuman-icerik/{dokumanId:int}", async (
            int dokumanId, DokumanDeposu depo, CancellationToken iptal) =>
        {
            var icerik = await depo.IcerikAsync(dokumanId, iptal);
            return icerik is null
                ? Results.NotFound()
                : Results.File(icerik.Veri, icerik.ContentType, icerik.Ad);
        }).RequireAuthorization();

        // Kimliksiz paylaşım ucu - tahmin edilemez paylasim_kodu (128 bit) TEK erişim kontrolü.
        // Linki alan herkes içeriği görebilir, süresiz - bilerek boyle (Google Drive tarzi
        // "linki bilen goruntuler"). Auth YOK.
        yol.MapGet("/api/dokuman-paylasim/{kod}", async (
            string kod, DokumanDeposu depo, CancellationToken iptal) =>
        {
            var icerik = await depo.IcerikPaylasimKoduIleAsync(kod, iptal);
            return icerik is null
                ? Results.NotFound()
                : Results.File(icerik.Veri, icerik.ContentType, icerik.Ad);
        });
    }

    private static string FizikselKaynak(string kartAdi) => kartAdi switch
    {
        "cari" or "kisi" or "personel" or "hasta" => "taraf",
        "stok" => "stok",
        // e-Belge XSLT sablonlari (160): kart degil ama ayni depoyu kullanir.
        "ebelge-xslt" => "ebelge-xslt",
        // Firma gorselleri (193): logo / kase / imza; belge_turu hangisi
        //   oldugunu tasir, kaynak_id sube kimligidir.
        "sube" => "sube",
        _ => throw new InvalidOperationException($"Bilinmeyen kart: {kartAdi}"),
    };

    // Kisi kendi yetki kodu yok, cari'yi kullanir (bkz. KisiUclari.cs).
    private static string YetkiKodu(string kartAdi) => kartAdi switch
    {
        "kisi" => "cari",
        "hasta" => "personel",
        "ebelge-xslt" => "ebelge_xslt",
        _ => kartAdi
    };

    private static string Ip(HttpContext ctx) => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}

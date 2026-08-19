using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

public static class AksiyonUclari
{
    public static void AksiyonUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/aksiyon").WithTags("Aksiyon").RequireAuthorization();

        // GET /api/aksiyon/{ekran}?kayitId=123
        //   Arac cubugu, sag tus ve komut paleti bu tek uctan beslenir.
        grup.MapGet("/{ekran}", async (
            string ekran, long? kayitId, BaglamCozucu cozucu, BelgeDeposu belgeler,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanimlar = AksiyonKatalogu.Ekran(ekran)
                ?? throw GentegreHatasi.Bulunamadi($"Bilinmeyen ekran: {ekran}");

            var baglam = await cozucu.CozAsync(ctx, iptal);

            // Kosullu pasiflik icin belge baglami (yalniz belge ekranlarinda ve kayit secilmisse)
            IDictionary<string, object?>? belge = null;
            if (kayitId is { } id && ekran.StartsWith("belge", StringComparison.OrdinalIgnoreCase))
                belge = (await belgeler.OkuAsync((int)id, iptal))?.Belge;

            var sonuc = tanimlar
                .Where(a => AksiyonKatalogu.Yetkili(a, baglam.Yetkiler))
                .OrderBy(a => a.Sira)
                .Select(a =>
                {
                    var (aktif, sebep) = Kosul(a, baglam, kayitId, belge);
                    return new AksiyonYaniti(a.Kod, a.Ad, a.Grup, a.Hedef, a.Kisayol,
                                             a.KayitGerekir, aktif, sebep);
                })
                .ToList();

            return Results.Ok(new AksiyonListesi { Ekran = ekran, KayitId = kayitId, Aksiyonlar = sonuc });
        });

        grup.MapGet("/", (CancellationToken _) =>
            Results.Ok(new { ekranlar = AksiyonKatalogu.EkranAdlari.OrderBy(e => e).ToList() }));
    }

    /// <summary>
    /// Kosul degerlendirmesi. Yetki DISI engeller burada: salt okuma subesi, kayit
    /// secilmemis olmasi, belgenin durumu. Sebep her zaman yazilir - "neden pasif"
    /// sorusunun cevabi ekranda olsun.
    /// </summary>
    private static (bool Aktif, string? Sebep) Kosul(
        AksiyonTanimi aksiyon, IstekBaglami baglam, long? kayitId,
        IDictionary<string, object?>? belge)
    {
        // Yazma gerektiren aksiyon, salt okuma subesinde calismaz (kullanici_sube.yazma = 0)
        var yazmaGerekir = aksiyon.Islem != Cekirdek.Yetki.Islem.Gor || aksiyon.AksiyonYetkisi is not null;
        if (yazmaGerekir && !baglam.SubeYazma && aksiyon.Kod != "veri.disa-aktar")
            return (false, "Bu subede yalnizca goruntuleme yetkiniz var.");

        if (aksiyon.KayitGerekir && kayitId is null)
            return (false, "Once bir kayit secin.");

        if (belge is not null)
        {
            var durum = Sayi(belge, "durum");
            var efaturaDurum = Sayi(belge, "efaturaDurum");
            var belgeNo = belge.TryGetValue("belgeNo", out var no) ? no?.ToString() ?? "" : "";

            switch (aksiyon.Kod)
            {
                case "belge.kesinlestir" when durum != 1:
                    return (false, "Belge zaten kesinlesmis.");
                case "belge.iptal" when durum == 2:
                    return (false, "Belge zaten iptal edilmis.");
                case "ebelge.gonder" when efaturaDurum != 0:
                    return (false, "Belge zaten gonderilmis.");
                case "ebelge.gonder" when belgeNo.Length == 0:
                    return (false, "Taslak belge gonderilemez - once kesinlestirin.");
            }
        }

        return (true, null);
    }

    private static int Sayi(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt32(v) : 0;
}

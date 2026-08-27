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

            // e-BELGE MENUSU YALNIZ MUKELLEFTE (kullanici): ana salter kapaliysa
            //   ya da sube hicbir e-Belge turunde mukellef degilse bu ekranin
            //   e-Belge maddeleri HIC gosterilmez - hepsi pasif gorunup "neden
            //   calismiyor" sorusu uretmesin.
            var eBelgeVar = await belgeler.EBelgeKullanimdaAsync(baglam.SubeId, iptal);

            var sonuc = tanimlar
                // "gelen" grubu da e-Belgeye baglidir: mukellef olmayan sirkette
                //   gelen kutusu diye bir sey yoktur (kullanici istegi).
                .Where(a => eBelgeVar
                            || !(a.Grup.Equals("ebelge", StringComparison.OrdinalIgnoreCase)
                                 || a.Grup.Equals("gelen", StringComparison.OrdinalIgnoreCase)))
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

            // e-BELGE ASAMASI: 0 hazirlanmadi · 1/11/51 hazirlandi · 2/12/52
            //   gonderildi. Eski kod "efaturaDurum != 0" ise "zaten gonderilmis"
            //   diyordu - HAZIRLANMIS belgeyi de gonderilmis sayip gonderimi
            //   engelliyordu.
            var hazirlandi = efaturaDurum is 1 or 11 or 51;
            var gonderildi = efaturaDurum is 2 or 12 or 52;
            var turAdi = efaturaDurum switch
            {
                1 or 2 => "e-Fatura", 11 or 12 => "e-Arşiv", 51 or 52 => "e-İrsaliye",
                _ => "e-Belge",
            };

            switch (aksiyon.Kod)
            {
                case "belge.kesinlestir" when durum != 1:
                    return (false, "Belge zaten kesinleşmiş.");

                // GONDERILMIS BELGE DEGISTIRILEMEZ/SILINEMEZ: numarasi GIB'e
                //   gitmistir; duzeltme ancak IADE faturasiyla yapilir.
                case "belge.iptal" or "belge.sil" when gonderildi:
                    return (false, $"{turAdi} gönderilmiş; belge iptal edilemez/silinemez. "
                                 + "Düzeltme için iade faturası kesin.");
                case "belge.iptal" or "belge.sil" when hazirlandi:
                    return (false, $"{turAdi} hazırlanmış; önce \"Hazırı Geri Al\" ile "
                                 + "e-Belge kaydını kaldırın.");
                case "belge.iptal" when durum == 2:
                    return (false, "Belge zaten iptal edilmiş.");

                case "ebelge.hazirla" when gonderildi:
                    return (false, $"{turAdi} zaten gönderilmiş.");
                case "ebelge.hazirla" when hazirlandi:
                    return (false, $"{turAdi} zaten hazırlanmış. Değiştirmek için "
                                 + "\"Seri Değiştir\" ya da \"Hazırı Geri Al\" kullanın.");
                case "ebelge.hazirla" when durum == 2:
                    return (false, "İptal edilmiş belge için e-Belge hazırlanamaz.");

                case "ebelge.gonder" when gonderildi:
                    return (false, $"{turAdi} zaten gönderilmiş.");
                case "ebelge.gonder" when !hazirlandi:
                    return (false, "Önce \"Hazırla\" ile e-Belge oluşturun.");
                case "ebelge.gonder" when belgeNo.Length == 0:
                    return (false, "Taslak belge gönderilemez - önce kesinleştirin.");

                case "ebelge.seri" or "ebelge.sifirla" when gonderildi:
                    return (false, $"{turAdi} gönderilmiş; serisi değiştirilemez, geri alınamaz.");
                case "ebelge.seri" or "ebelge.sifirla" when !hazirlandi:
                    return (false, "Önce \"Hazırla\" ile e-Belge oluşturun.");
            }
        }

        return (true, null);
    }

    private static int Sayi(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt32(v) : 0;
}

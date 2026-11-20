using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇEK / SENET PORTFÖY İŞLEMLERİ (1386; kartın "⚙ İşlem ▾" menüsü - Delphi UCekListeFrame sağ tık menüsü):
///   GET  /api/cek-senet/{id}/islemler  → kıymetin şimdiki durumunda yapılabilenler + son hareket geri alınır mı
///   POST /api/cek-senet/{id}/islem     → işlem (durum + hareket + gerekiyorsa kasa işlemi, tek transaction)
///   POST /api/cek-senet/{id}/geri-al   → son hareketi geri al (Delphi "Hareketi Sil")
/// Kayıt kapsamı (şube) çek / senet listesinden; kasa işlemi yazan işlem kasa_islem ekleme yetkisi de ister.
/// </summary>
public static class CekSenetUclari
{
    private const string Kod = "cek_senet";

    public sealed record IslemIstegi(string Kod, DateTime? Tarih, int? TarafId, int? HesapId, string? BelgeNo, string? Aciklama);

    public static void CekSenetUclariniEkle(this WebApplication uygulama)
    {
        var grup = uygulama.MapGroup("/api/cek-senet").RequireAuthorization();

        grup.MapGet("/{id:int}/islemler", async (int id, BaglamCozucu cozucu, KayitErisimi erisim, KasaDeposu depo,
                                                 HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await erisim.IsteAsync(baglam, "cek-senet", id, "Çek / senet bulunamadı.", iptal);
            var (yon, durum, hesapId, islemler, geriAlinir) = await depo.CekSenetIslemleriAsync(id, iptal);
            var yazar = baglam.Yetkiler.Var(Kod, Islem.Degistir);
            return Results.Ok(new
            {
                yon, durum, hesapId,
                geriAlinir = yazar && geriAlinir,
                islemler = yazar
                    ? islemler.Select(k => new { kod = k.Kod, ad = k.Ad, ikon = k.Ikon, hedef = k.Hedef, ayrac = k.Ayrac,
                                                 kasa = CekSenetIslemleri.KasaTuru(k, false) != 0 })
                    : [],
            });
        });

        grup.MapPost("/{id:int}/islem", async (int id, IslemIstegi istek, BaglamCozucu cozucu, KayitErisimi erisim,
                                               KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            var kural = CekSenetIslemleri.Bul(istek?.Kod)
                ?? throw GentegreHatasi.Dogrulama("İşlem seçilmeli.", new AlanHatasi("kod", "Zorunlu."));
            // Cari / para etkisi olan işlem kasa işlemi yazar - kasa yetkisi olmayan çek kartından muhasebe yazamaz.
            if (CekSenetIslemleri.KasaTuru(kural, false) != 0) baglam.YetkiIste("kasa_islem", Islem.Ekle);
            baglam.YazmaIste();
            await erisim.IsteAsync(baglam, "cek-senet", id, "Çek / senet bulunamadı.", iptal);
            var s = await depo.CekSenetIslemAsync(id,
                new KasaDeposu.CekSenetIslemIstegi(istek!.Kod, istek.Tarih, istek.TarafId, istek.HesapId,
                                                   istek.BelgeNo, istek.Aciklama),
                baglam.Yazma, iptal);
            return Results.Ok(new { hareketId = s.HareketId, kasaIslemId = s.KasaIslemId, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/{id:int}/geri-al", async (int id, BaglamCozucu cozucu, KayitErisimi erisim, KasaDeposu depo,
                                                 HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            baglam.YazmaIste();
            await erisim.IsteAsync(baglam, "cek-senet", id, "Çek / senet bulunamadı.", iptal);
            await depo.CekSenetGeriAlAsync(id, baglam.Yazma, iptal);
            return Results.Ok(new { izlemeNo = baglam.IzlemeNo });
        });
    }
}

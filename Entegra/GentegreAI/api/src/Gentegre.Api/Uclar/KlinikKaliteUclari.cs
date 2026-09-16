using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

public class KlinikDonemIstegi
{
    public short Yil { get; set; }
    public short DonemNo { get; set; } = 1;
    /// <summary>3 · 6 · 12 ay. Rehberin analiz periyodu 6 aylık ve yıllık.</summary>
    public short Periyot { get; set; } = 6;
}

public sealed class KlinikOnizlemeIstegi : KlinikDonemIstegi
{
    public int GostergeId { get; set; }
}

/// <summary>
/// Klinik Kalite hesaplama uçları (db/713 motoru).
///
/// ŞUBE İSTEKTEN GELMEZ, BAĞLAMDAN. Kullanıcı gövdeye şube yazabilseydi başka
/// şubenin dönem sonucunu hesaplayıp yazabilirdi; ölçüm satırı şubeye ait bir
/// kayıttır ve 019'daki şube modeline uyar.
///
/// HESAPLAMA ve KESİNLEŞTİRME AYRI YETKİ: hesaplamayı kalite birimi sık sık
/// çalıştırır (taslak üretir, bakar, düzeltir); kesinleştirme tek yönlüdür ve
/// Bakanlığa giden sayıyı dondurur - aynı yetkiye bağlamak, geri alınamayan
/// işlemi gündelik işlemle aynı kapıya koymak olurdu.
/// </summary>
public static class KlinikKaliteUclari
{
    public static void KlinikKaliteUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/klinik-kalite").WithTags("Klinik Kalite");

        // Dönemin tüm otomatik göstergelerini hesapla ve yaz.
        grup.MapPost("/hesapla", async (
            KlinikDonemIstegi istek, BaglamCozucu cozucu, KlinikKaliteDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("klinik_kalite.hesapla");
            DonemDogrula(istek);

            var s = await depo.DonemHesaplaAsync(
                baglam.SubeId ?? 0, istek.Yil, istek.DonemNo, istek.Periyot,
                baglam.KullaniciId, iptal);

            return Results.Ok(new
            {
                yazilan = s.Yazilan,
                atlanan = s.Atlanan,      // kesinleşmiş, dokunulmadı
                kodsuz = s.Kodsuz,        // kod listesi eksik, elle girilecek
                sureMs = s.SureMs,
                izlemeNo = baglam.IzlemeNo
            });
        }).RequireAuthorization();

        // Tek göstergeyi ÖNİZLE - yazmaz.
        grup.MapPost("/onizle", async (
            KlinikOnizlemeIstegi istek, BaglamCozucu cozucu, KlinikKaliteDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("klinik_kalite", Islem.Gor);
            DonemDogrula(istek);
            if (istek.GostergeId <= 0)
                throw GentegreHatasi.Dogrulama("Gösterge seçilmedi.", new AlanHatasi("gostergeId", "Gösterge seçilmedi."));

            var o = await depo.GostergeOnizleAsync(
                istek.GostergeId, baglam.SubeId ?? 0, istek.Yil, istek.DonemNo,
                istek.Periyot, iptal);
            if (o is null)
                throw GentegreHatasi.Dogrulama("Gösterge bulunamadı.", new AlanHatasi("gostergeId", "Gösterge bulunamadı."));

            return Results.Ok(new
            {
                pay = o.Pay,
                payda = o.Payda,
                durum = o.Durum,          // ok · kod_yok · vaka_yok
                aciklama = o.Aciklama,
                izlemeNo = baglam.IzlemeNo
            });
        }).RequireAuthorization();

        // Dönemi kesinleştir - TEK YÖN.
        grup.MapPost("/kesinlestir", async (
            KlinikDonemIstegi istek, BaglamCozucu cozucu, KlinikKaliteDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("klinik_kalite.kesinlestir");
            DonemDogrula(istek);

            var n = await depo.DonemKesinlestirAsync(
                baglam.SubeId ?? 0, istek.Yil, istek.DonemNo, istek.Periyot,
                baglam.KullaniciId, iptal);

            return Results.Ok(new { kesinlesen = n, izlemeNo = baglam.IzlemeNo });
        }).RequireAuthorization();
    }

    /// <summary>
    /// Dönem alanlarını doğrular. Periyoda göre geçerli dönem numarası farklı:
    /// 3 aylıkta 1-4, 6 aylıkta 1-2, yıllıkta yalnız 1. Kontrol edilmeseydi
    /// "yıllık 3. dönem" gibi bir satır yazılır ve raporda karşılığı olmazdı.
    /// </summary>
    private static void DonemDogrula(KlinikDonemIstegi istek)
    {
        if (istek.Yil < 2000 || istek.Yil > 2100)
            throw GentegreHatasi.Dogrulama("Yıl 2000-2100 aralığında olmalı.", new AlanHatasi("yil", "Yıl 2000-2100 aralığında olmalı."));
        if (istek.Periyot is not (3 or 6 or 12))
            throw GentegreHatasi.Dogrulama("Periyot 3, 6 ya da 12 olmalı.", new AlanHatasi("periyot", "Periyot 3, 6 ya da 12 olmalı."));

        var enFazla = istek.Periyot switch { 3 => 4, 6 => 2, _ => 1 };
        if (istek.DonemNo < 1 || istek.DonemNo > enFazla)
            throw GentegreHatasi.Dogrulama(
                $"Bu periyotta dönem numarası 1-{enFazla} olmalı.",
                new AlanHatasi("donemNo", $"Bu periyotta dönem numarası 1-{enFazla} olmalı."));
    }
}

using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ADAY HASTANIN RANDEVULARINI GERÇEK KARTA TAŞI (kullanıcı 17.10.2026: "aday kart kimlik no girilince ve
/// başka kart varsa ona geçecek ve aday kart silinecek, randevu da gerçek karta bağlanacak").
///
/// Aday kartın BÜTÜN randevuları (seri / tekrarlar dahil) tek işlemde gerçek hastaya geçer; her satır
/// alan bazlı loglanır. Aday kartın silinmesi ayrıca, kartın normal silme ucundan yapılır (silme logu,
/// bağlı kayıt kontrolü orada) - bu uç yalnız taşır.
/// </summary>
public static partial class RandevuUclari
{
    public sealed record AdayTasiIstegi(int AdayId, int HedefId);

    private static void AdayTasiUcunuEkle(RouteGroupBuilder grup)
    {
        grup.MapPost("/aday-tasi", async (
            AdayTasiIstegi istek, VeriKaynagi veri, LogDeposu log,
            Servisler.RandevuHatirlatmasi hatirlatma, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Degistir);
            if (istek.AdayId == istek.HedefId) throw GentegreHatasi.Dogrulama("Aday ve hedef hasta aynı.");

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var aday = await b.TekDegerAsync<short?>(
                "select durum from public.taraf where id = @p0 and hasta = 1 for update", islem, [istek.AdayId], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Aday hasta bulunamadı.");
            if (aday != 2) throw GentegreHatasi.IsKurali("Yalnız ADAY hastanın randevuları taşınır.");
            var hedef = await b.TekDegerAsync<short?>(
                "select durum from public.taraf where id = @p0 and hasta = 1", islem, [istek.HedefId], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Hedef hasta bulunamadı.");
            if (hedef != 1) throw GentegreHatasi.IsKurali("Randevular yalnız AKTİF hasta kartına taşınır.");

            var idler = await b.ListeAsync(
                "update public.randevu set hasta_id = @p1, degistiren = @p2, degistirme_tarihi = now() where hasta_id = @p0 returning id",
                islem, [istek.AdayId, istek.HedefId, baglam.KullaniciId], o => o.GetInt32(0), iptal);
            foreach (var rid in idler)
                await log.YazAsync(b, islem, LogIslemi.Degistir, LogRandevu, rid, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string> { ["hasta_id"] = $"{istek.AdayId} -> {istek.HedefId}" },
                    tarafId: istek.HedefId, iptal: iptal);
            await islem.CommitAsync(iptal);
            foreach (var rid in idler) await hatirlatma.TazeleAsync(rid, baglam.KullaniciId, iptal);
            return Results.Ok(new { tasinan = idler.Count });
        });
    }
}

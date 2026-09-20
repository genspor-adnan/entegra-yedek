using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TEST TEKRARI TALEBİ (891 — KTS denetim maddesi L8).
///
/// <para>Tekrar ÇALIŞILDIĞINDA iz zaten kalıyordu (<c>lab_sonuc.tekrar_no</c>,
/// düzeltme yolu, ret sonrası "tekrar numune bekliyor"). Eksik olan talebin
/// kendisiydi: uzman ya da klinisyen "bu tetkiki tekrar çalışın" diyemiyor,
/// iş telefonla söyleniyordu - kuyruğa düşmüyor, gerekçesi kayıtta durmuyor,
/// karşılanıp karşılanmadığı görünmüyordu.</para>
///
/// <para><b>İki tür ayrıdır:</b> aynı tüpten tekrar çalışma (1) ile yeni
/// numune istenmesi (2) laboratuvar için bambaşka iki iştir - birincisinde
/// tüp aranır (gerekirse arşivden çıkarılır, 890), ikincisinde hastadan
/// yeniden kan alınır.</para>
///
/// <para><b>Talebi sistem kapatır:</b> aynı satıra yeni sonuç yazılınca
/// (`SonucYazAsync`) talep "karşılandı" olur. İptal ise elle yapılır ve
/// gerekçe ister - istenen iş yapılmıyorsa nedeni kayıtta durmalı.</para>
/// </summary>
public static partial class LabUclari
{
    public sealed record TekrarIstegi(short Tur, short GerekceKod, string? Gerekce, long? SonucId);
    public sealed record TekrarIptalIstegi(string Neden);

    private static void TekrarEkle(RouteGroupBuilder grup)
    {
        // POST /api/lab/satir/{id}/tekrar - tetkik için tekrar iste.
        //   AYRI AKSİYON YETKİSİ (`lab.tekrar.iste`): sonucu görebilen
        //   herkesin laboratuvara iş açması doğru değil; ama yetki hem
        //   uzmanda hem klinisyende olabilir - denetimin sorduğu "elektronik
        //   olarak istenebiliyor mu" ikisini de kapsar.
        grup.MapPost("/satir/{id:int}/tekrar", async (
            int id, TekrarIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("lab.tekrar.iste");

            var tekrarId = await KuralCalistirAsync(() => veri.TekDegerAsync<int>(
                "select public.fn_lab_tekrar_iste(@p0, @p1, @p2, @p3, @p4, @p5)",
                [id, istek.Tur, istek.GerekceKod, istek.Gerekce ?? "",
                 baglam.KullaniciId, istek.SonucId], iptal));

            // ARŞİVDEKİ TÜPÜN YERİ YANITTA (890): "aynı numuneden tekrar"
            //   talebinde teknisyenin ilk işi tüpü bulmaktır; yeri hemen
            //   söylenmezse ekran ikinci bir arama yaptırır.
            var yer = await veri.TekDegerAsync<string?>("""
                select arsiv_yeri from public.v_lab_tekrar_istegi where id = @p0
                """, [tekrarId], iptal);

            return Results.Ok(new { tekrarId, arsivYeri = yer,
                mesaj = istek.Tur == 2
                    ? "Yeni numune istendi - tetkik 'tekrar numune bekliyor' durumuna alındı."
                    : "Tekrar çalışma istendi."
                      + (string.IsNullOrEmpty(yer) ? "" : $" Tüp arşivde: {yer}."),
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/tekrar/{id}/iptal - talebi kapat (gerekçe zorunlu).
        grup.MapPost("/tekrar/{id:int}/iptal", async (
            int id, TekrarIptalIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.tekrar", Islem.Degistir);

            await KuralCalistirAsync(() => veri.TekDegerAsync<int>(
                "select public.fn_lab_tekrar_iptal(@p0, @p1, @p2)",
                [id, istek.Neden ?? "", baglam.KullaniciId], iptal));

            return Results.Ok(new { id, mesaj = "Tekrar talebi iptal edildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/tekrar/bekleyen - laboratuvarın tekrar kuyruğu.
        //   Liste ekranı da var (`lab-tekrar`); bu uç çalışma ekranlarının
        //   üst şeridi için - kaç iş bekliyor sorusu bir sayıyla cevaplanır.
        grup.MapGet("/tekrar/bekleyen", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.tekrar", Islem.Gor);

            var satirlar = await veri.ListeAsync("""
                select id, satir_id as "satirId", istem_id as "istemId",
                       istem_no as "istemNo", kod, tetkik, hasta, barkod,
                       tur, gerekce_adi as "gerekceAdi", gerekce, isteyen,
                       istek_zamani as "istekZamani", arsiv_yeri as "arsivYeri"
                  from public.v_lab_tekrar_istegi
                 where durum = 1 and (@p0 = 0 or sube_id = @p0)
                 order by istek_zamani
                """, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });
    }
}

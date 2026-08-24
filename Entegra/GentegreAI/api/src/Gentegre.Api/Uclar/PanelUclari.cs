using Gentegre.Api.AraKatman;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Ana sayfa paneli. Tek istekte butun kutular ve listeler doner - panel
/// acilisinda bes ayri cagri yapmak ilk ekrani yavaslatirdi.
/// </summary>
public static class PanelUclari
{
    public static void PanelUclariniEkle(this IEndpointRouteBuilder yol)
    {
        yol.MapGet("/api/panel", async (
            BaglamCozucu cozucu, PanelDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            // Ozel yetki YOK: panel yalnizca kullanicinin zaten gorebildigi
            //   listelerin ozetidir ve sube suzgeci baglamdan gelir. Kutuya
            //   tiklayinca acilan liste kendi yetkisini ayrica dogrular.
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Gorev/takvim KULLANICIYA ozel. taraf_kullanici.id = taraf.id
            //   oldugu icin kullanici kimligi dogrudan sorumlu_id ile eslesir;
            //   sorumlusu BOS gorevler (havuz isi) herkese gorunur.
            var p = await depo.OkuAsync(baglam.SubeId, baglam.KullaniciId, iptal);
            return Results.Ok(new
            {
                kutular = p.Kutular,
                sonBelgeler = p.SonBelgeler,
                kritikStok = p.KritikStok,
                buyukBakiyeler = p.BuyukBakiyeler,
                gorevler = p.Gorevler,
                takvim = p.Takvim,
                izlemeNo = baglam.IzlemeNo
            });
        }).WithTags("Panel").RequireAuthorization();
    }
}

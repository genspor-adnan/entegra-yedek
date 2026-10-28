using Gentegre.Veri;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// RADYOLOJİ KAYIT KAPISI (kod inceleme raporu 28.10.2026 B02): radyoloji grubunun özel uçları kaynak / aksiyon
/// iznini kontrol edip kimlikle doğrudan okuyor / yazıyordu - başka şubenin (ya da portalda başka hastanın) istemi
/// kimliği değiştirilerek açılabiliyordu. Bu filtre grubun BÜTÜN uçlarında yol kimliğini merkezi kayıt erişim
/// kapısından (<see cref="KayitErisimi"/>, liste ile aynı şube / kapsam / portal kuralı) geçirir:
/// <list type="bullet">
///   <item><c>/istem/{id}</c> ...      → istem <c>radyoloji-istem</c> kaynağında görünür mü</item>
///   <item><c>/rapor/{id}</c> ...      → raporun bağlı istemi (ana rapor / addendum) aynı kapıdan</item>
///   <item><c>/hasta/{id}</c> ...      → hasta <c>hasta</c> kaynağında görünür mü</item>
/// </list>
/// Kapsam dışı ya da olmayan kayıt aynı 404'ü alır (kimliği deneyen kayıt var mı öğrenemez). Tanım uçları
/// (cihaz / şablon / protokol / hekim) hasta verisi taşımaz, filtre onlara dokunmaz.
/// </summary>
public sealed class RadyolojiKayitKapisi : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext ctx, EndpointFilterDelegate sonraki)
    {
        var http = ctx.HttpContext;
        var desen = (http.GetEndpoint() as RouteEndpoint)?.RoutePattern.RawText ?? "";
        if (!int.TryParse(http.Request.RouteValues["id"]?.ToString(), out var id) || id <= 0)
            return await sonraki(ctx);

        var tur = desen.Contains("/istem/{id", StringComparison.Ordinal) ? "istem"
                : desen.Contains("/rapor/{id", StringComparison.Ordinal) ? "rapor"
                : desen.Contains("/hasta/{id", StringComparison.Ordinal) ? "hasta" : null;
        if (tur is null) return await sonraki(ctx);

        var iptal = http.RequestAborted;
        var hizmetler = http.RequestServices;
        var baglam = await hizmetler.GetRequiredService<BaglamCozucu>().CozAsync(http, iptal);
        var erisim = hizmetler.GetRequiredService<KayitErisimi>();

        switch (tur)
        {
            case "istem":
                await erisim.IsteAsync(baglam, "radyoloji-istem", id, "Radyoloji istemi bulunamadı.", iptal);
                break;
            case "rapor":
                var istemId = await hizmetler.GetRequiredService<VeriKaynagi>().TekDegerAsync<int?>(
                    "select istem_id from public.radyoloji_rapor where id = @p0", [id], iptal)
                    ?? throw Cekirdek.Sozlesme.GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
                await erisim.IsteAsync(baglam, "radyoloji-istem", istemId, "Rapor bulunamadı.", iptal);
                break;
            case "hasta":
                await erisim.IsteAsync(baglam, "hasta", id, "Hasta bulunamadı.", iptal);
                break;
        }
        return await sonraki(ctx);
    }
}

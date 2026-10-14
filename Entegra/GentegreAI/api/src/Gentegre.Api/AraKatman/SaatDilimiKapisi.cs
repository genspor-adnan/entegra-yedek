using System.Globalization;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek;
using Gentegre.Veri;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// SAAT DILIMI KAPISI (1097, kullanici: "sube zaman dilimini baz al"): istegin
/// SUBESININ saat dilimini (sube.zaman_dilimi, 666) istek boyunca gecerli kilar.
/// Saat.Simdi / Bugun / UtcYap ve veritabani oturumu (VeriKaynagi -> current_date,
/// ::date, to_char) bu subenin gununu gorur. Saklanan an her zaman UTC.
///
/// <para>Sube: X-Sube-Id basligi, yoksa token'daki sube - BaglamCozucu ile ayni
/// sira. Sube DOGRULAMASI burada YAPILMAZ (yetkisiz sube basligi BaglamCozucu'da
/// 403 alir); burada yalniz gun/saat secilir. Sube yoksa (anonim uc, ajan, zamanli
/// is) kurulus dilimi.</para>
///
/// <para>Sube -> dilim eslemesi 60 sn onbellekte; PostgreSQL'in tanimadigi dilim
/// adi (yanlis yazilmis IANA adi) eslenmez - baglanti acilamaz hale gelmesin.</para>
/// </summary>
public sealed class SaatDilimiKapisi(RequestDelegate sonraki)
{
    private static volatile Dictionary<int, string> _dilimler = new();
    private static DateTime _yenilendi = DateTime.MinValue;
    private static readonly SemaphoreSlim _kilit = new(1, 1);

    public async Task InvokeAsync(HttpContext ctx, VeriKaynagi veri)
    {
        var sube = SubeBul(ctx);
        string? dilim = null;
        if (sube is { } s)
        {
            var esleme = await EslemeAsync(veri, ctx.RequestAborted);
            esleme.TryGetValue(s, out dilim);
        }
        using (Saat.IstekDilimi(dilim))
            await sonraki(ctx);
    }

    private static int? SubeBul(HttpContext ctx)
    {
        if (ctx.Request.Headers.TryGetValue("X-Sube-Id", out var b)
            && int.TryParse(b.ToString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out var h)) return h;
        return int.TryParse(ctx.User.FindFirst(Talep.SubeId)?.Value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var t)
            ? t : null;
    }

    private static async Task<Dictionary<int, string>> EslemeAsync(VeriKaynagi veri, CancellationToken iptal)
    {
        if (DateTime.UtcNow - _yenilendi < TimeSpan.FromSeconds(60)) return _dilimler;
        await _kilit.WaitAsync(iptal);
        try
        {
            if (DateTime.UtcNow - _yenilendi < TimeSpan.FromSeconds(60)) return _dilimler;
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select s.id, public.fn_sube_zaman_dilimi(s.id) from public.sube s
                 where exists (select 1 from pg_timezone_names z where z.name = public.fn_sube_zaman_dilimi(s.id))
                """, null, [], o => (o.GetInt32(0), o.GetString(1)), iptal);
            _dilimler = liste.ToDictionary(x => x.Item1, x => x.Item2);
            _yenilendi = DateTime.UtcNow;
            return _dilimler;
        }
        finally { _kilit.Release(); }
    }
}

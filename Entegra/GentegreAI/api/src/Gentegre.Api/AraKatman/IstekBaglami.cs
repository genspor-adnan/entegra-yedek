using System.Globalization;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// Istegin kimlik baglami: kullanici, aktif sube, cozulmus yetkiler ve kayit
/// kapsami. Sube istekten "onerilir" (X-Sube-Id) ama SUNUCU dogrular - kullanici
/// yetkili olmadigi subeyi secemez.
/// </summary>
public sealed class IstekBaglami
{
    public int KullaniciId { get; init; }
    public int RolId { get; init; }
    public int? SubeId { get; init; }
    /// <summary>Aktif subede yazma hakki (kullanici_sube.yazma). 0 ise sube salt okunur.</summary>
    public bool SubeYazma { get; init; } = true;
    public YetkiSeti Yetkiler { get; init; } = default!;
    public IReadOnlyList<int> Kapsam { get; init; } = Array.Empty<int>();
    public IReadOnlyList<SubeOzeti> Subeler { get; init; } = Array.Empty<SubeOzeti>();
    public string IzlemeNo { get; init; } = "";

    public void YetkiIste(string kaynakKodu, Islem islem)
    {
        if (!Yetkiler.Var(kaynakKodu, islem))
            throw GentegreHatasi.Yasak();

        // Rol yetkisi yetmez: kullanici bu SUBEDE salt okuyucu olabilir.
        if (islem != Islem.Gor && !SubeYazma)
            throw GentegreHatasi.Yasak("Bu subede yalnizca goruntuleme yetkiniz var.");
    }

    public void AksiyonIste(string aksiyonKodu)
    {
        if (!Yetkiler.AksiyonVar(aksiyonKodu))
            throw GentegreHatasi.Yasak();
    }
}

public sealed class BaglamCozucu
{
    private readonly YetkiCozucu _yetkiCozucu;
    private readonly KullaniciDeposu _kullanicilar;

    public BaglamCozucu(YetkiCozucu yetkiCozucu, KullaniciDeposu kullanicilar)
    {
        _yetkiCozucu = yetkiCozucu;
        _kullanicilar = kullanicilar;
    }

    public async Task<IstekBaglami> CozAsync(HttpContext ctx, CancellationToken iptal = default)
    {
        var kullaniciId = TalepSayi(ctx, Talep.KullaniciId)
            ?? throw GentegreHatasi.Yetkisiz();
        var rolId = TalepSayi(ctx, Talep.RolId) ?? 0;

        var yetkiler = await _yetkiCozucu.CozAsync(kullaniciId, iptal);
        var kapsam = await _kullanicilar.KapsamAsync(kullaniciId, iptal);
        var subeler = await _kullanicilar.SubeleriAsync(kullaniciId, iptal);
        var subeId = SubeCoz(ctx, subeler);

        return new IstekBaglami
        {
            KullaniciId = kullaniciId,
            RolId = rolId,
            SubeId = subeId,
            SubeYazma = subeId is null || subeler.FirstOrDefault(s => s.Id == subeId)?.Yazma != false,
            Yetkiler = yetkiler,
            Kapsam = kapsam,
            Subeler = subeler,
            IzlemeNo = ctx.Items["izlemeNo"] as string ?? Izleme.YeniNo()
        };
    }

    /// <summary>
    /// Aktif sube: X-Sube-Id basligi > token'daki sube > varsayilan sube.
    /// Baslikta gelen sube kullanicinin sube listesinde YOKSA 403 - istek sessizce
    /// varsayilana dusmez.
    /// </summary>
    private static int? SubeCoz(HttpContext ctx, IReadOnlyList<SubeOzeti> subeler)
    {
        if (subeler.Count == 0) return null;

        if (ctx.Request.Headers.TryGetValue("X-Sube-Id", out var basligi) &&
            int.TryParse(basligi.ToString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out var istenen))
        {
            if (subeler.Any(s => s.Id == istenen)) return istenen;
            throw GentegreHatasi.Yasak("Bu subede calisma yetkiniz yok.");
        }

        // Token'daki sube, yoksa varsayilan sube
        var tokendan = TalepSayi(ctx, Talep.SubeId);
        if (tokendan is { } t && subeler.Any(s => s.Id == t)) return t;

        return (subeler.FirstOrDefault(s => s.Varsayilan) ?? subeler[0]).Id;
    }

    private static int? TalepSayi(HttpContext ctx, string ad)
    {
        var d = ctx.User.FindFirst(ad)?.Value;
        return int.TryParse(d, NumberStyles.Integer, CultureInfo.InvariantCulture, out var s) ? s : null;
    }
}

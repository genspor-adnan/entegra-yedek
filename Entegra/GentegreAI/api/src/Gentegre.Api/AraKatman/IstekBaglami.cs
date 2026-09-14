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
    /// <summary>Aktif subede yazma hakki (rol_sube.yazma). 0 ise sube salt okunur.</summary>
    public bool SubeYazma { get; init; } = true;
    public YetkiSeti Yetkiler { get; init; } = default!;
    public IReadOnlyList<int> Kapsam { get; init; } = Array.Empty<int>();
    public IReadOnlyList<SubeOzeti> Subeler { get; init; } = Array.Empty<SubeOzeti>();
    public string IzlemeNo { get; init; } = "";
    /// <summary>Istegi yapan istemcinin IP adresi - islem gunlugune yazilir.</summary>
    public string Ip { get; init; } = "";

    /// <summary>
    /// Depo katmaninin bekledigi yazma baglami (kullanici + sube + IP).
    /// Uc dosyalarinda 25 kez "kullanici + sube + IP" ucusu elle kuruluyordu;
    /// IP'yi unutan bir kopya islem gunlugune bos IP yazardi.
    /// </summary>
    public YazmaBaglami Yazma => new(KullaniciId, SubeId, Ip, UlkeKod, KimlikKurali, ZamanDilimi);

    /// <summary>
    /// KIMLIK NO BICIMI (679): kurum profilinden cozulmus kural. Kart yazimi
    /// ve kart meta'si ayni kurali kullanir - ekranin kabul edip sunucunun
    /// reddettigi numara olmasin.
    /// </summary>
    public Gentegre.Cekirdek.Katalog.KimlikKurali KimlikKurali { get; init; }
        = Gentegre.Cekirdek.Katalog.KimlikKurali.Varsayilan;

    /// <summary>Aktif sube kaydi (yerel ayarlariyla, 666).</summary>
    public SubeOzeti? AktifSube => Subeler.FirstOrDefault(s => s.Id == SubeId);

    /// <summary>
    /// Aktif subenin ulkesi (666). Sube secilmemisse TR: dogrulamanin
    /// SESSIZCE KAPANMASI, gereksiz yere acik kalmasindan kotudur.
    /// </summary>
    public string UlkeKod => AktifSube?.UlkeKod ?? "TR";

    /// <summary>Aktif subenin saat dilimi (666) - bos ise kurulus dilimi.</summary>
    public string ZamanDilimi => AktifSube?.ZamanDilimi ?? "";

    /// <summary>TCKN / Turkiye telefon bicimi kontrolu bu subede uygulanir mi?</summary>
    public bool YerelTurkiye => string.Equals(UlkeKod, "TR", StringComparison.OrdinalIgnoreCase);

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
    private readonly KimlikKuraliDeposu _kimlik;

    public BaglamCozucu(YetkiCozucu yetkiCozucu, KullaniciDeposu kullanicilar,
                        KimlikKuraliDeposu kimlik)
    {
        _yetkiCozucu = yetkiCozucu;
        _kullanicilar = kullanicilar;
        _kimlik = kimlik;
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
        // Kimlik bicimi (679) ONBELLEKLI okunur: her istekte sorgu atmak
        //   ayarin kendisinden pahali olurdu.
        var kimlikKurali = await _kimlik.KuralAsync(subeId ?? 0, iptal);

        return new IstekBaglami
        {
            KullaniciId = kullaniciId,
            RolId = rolId,
            SubeId = subeId,
            SubeYazma = subeId is null || subeler.FirstOrDefault(s => s.Id == subeId)?.Yazma != false,
            Yetkiler = yetkiler,
            Kapsam = kapsam,
            Subeler = subeler,
            IzlemeNo = ctx.Items["izlemeNo"] as string ?? Izleme.YeniNo(),
            // IP her uc dosyasinda ayri bir `Ip(HttpContext)` yardimcisiyla
            //   cikariliyordu (10 kopya); baglam zaten ctx'i goruyor.
            Ip = IpCoz(ctx),
            KimlikKurali = kimlikKurali
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

    /// <summary>Istemci IP adresi; cozulemezse bos metin.</summary>
    public static string IpCoz(HttpContext ctx)
        => ctx.Connection.RemoteIpAddress?.ToString() ?? "";

    private static int? TalepSayi(HttpContext ctx, string ad)
    {
        var d = ctx.User.FindFirst(ad)?.Value;
        return int.TryParse(d, NumberStyles.Integer, CultureInfo.InvariantCulture, out var s) ? s : null;
    }
}

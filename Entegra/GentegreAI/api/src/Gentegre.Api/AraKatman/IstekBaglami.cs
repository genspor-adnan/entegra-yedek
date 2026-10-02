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
    /// <summary>
    /// GUNCEL ANA ROL - veritabanindan, istek basina (denetim 28.09.2026 #7).
    /// Token'daki `rolId` talebi KULLANILMAZ: rol degisince 30 dakika eski
    /// rolle calismak demekti.
    /// </summary>
    public int RolId { get; init; }
    /// <summary>
    /// ETKILI ROL KUMESI (ana + ek, <c>fn_kullanici_rolleri</c>). Tetkik
    /// kisiti (889) bu kumeyle sorulur - tek rol parametresi ek rolleri
    /// gormuyordu.
    /// </summary>
    public IReadOnlyList<int> RolIdleri { get; init; } = Array.Empty<int>();
    public int? SubeId { get; init; }
    /// <summary>
    /// Aktif subede yazma hakki (rol_sube.yazma). 0 ise sube salt okunur.
    /// Varsayilan KAPALI: subesiz baglam yazamaz (denetim #1).
    /// </summary>
    public bool SubeYazma { get; init; }
    public YetkiSeti Yetkiler { get; init; } = default!;
    public IReadOnlyList<int> Kapsam { get; init; } = Array.Empty<int>();
    /// <summary>
    /// PORTAL TURU (794): 0 ic kullanici · 1 dis doktor · 2 dis kurum · 3 hasta.
    /// Sifirdan buyukse liste sorgulari kaynagin `PortalKosullari` kuralini
    /// EKLER; kural tanimlanmamis kaynak portal kullanicisina kapalidir.
    /// </summary>
    public short PortalTuru { get; init; }
    /// <summary>
    /// PORTAL KAPSAMININ BAGLANDIGI TARAF (819). Dis hekim ve hastada kisinin
    /// KENDISI; kurum portalinda hesabin temsil ettigi KURUM - kurum hesabi
    /// kisi basi aciliyor, kapsam ise kuruma ait.
    /// Portal disi kullanicida <see cref="KullaniciId"/> ile aynidir.
    /// </summary>
    public int PortalKimlik { get; init; }
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
        if (islem != Islem.Gor) YazmaIste();
    }

    /// <summary>
    /// YAZAN AKSIYON (denetim #2). Aksiyon yetkisi rol yetkisidir, sube salt
    /// okuma kuralini ICERMEZ: fiyat listesi uretimi yalniz bu kapidan
    /// geciyordu ve salt okuyucu subede satir yazabiliyordu. Varsayilan
    /// YAZMA sayilir - okuyan aksiyon <see cref="AksiyonGorIste"/> ile acikca
    /// ayrilir; unutulan aksiyon acik degil kapali kalsin.
    /// </summary>
    public void AksiyonIste(string aksiyonKodu)
    {
        AksiyonGorIste(aksiyonKodu);
        YazmaIste();
    }

    /// <summary>Yalniz OKUYAN aksiyon (onizleme, gecmis, sablon): salt okuma subesinde de calisir.</summary>
    public void AksiyonGorIste(string aksiyonKodu)
    {
        if (!Yetkiler.AksiyonVar(aksiyonKodu))
            throw GentegreHatasi.Yasak();
    }

    /// <summary>
    /// Aktif subede yazma hakki. Subesiz baglam da YAZAMAZ - "sube yok" hic
    /// bir zaman "her subeye yaz" anlamina gelmez.
    /// </summary>
    public void YazmaIste()
    {
        if (!SubeYazma)
            throw GentegreHatasi.Yasak("Bu subede yalnizca goruntuleme yetkiniz var.");
    }
}

/// <summary>
/// SINIRLI OTURUMDA ACIK UC (denetim 28.09.2026 #1, #4). Varsayilan olarak
/// her kimlikli uc (a) aktif bir sube ve (b) parolasi degismis bir hesap
/// ister. Yalniz bu isaretle eslenen uclar - profil, parola degistirme,
/// sube listesi - bu kosullar saglanmadan calisir. Istisna gruba degil TEK
/// UCA verilir.
/// </summary>
[Flags]
public enum SinirliOturum
{
    Yok = 0,
    /// <summary>Kullanicinin aktif subesi yokken de calisir.</summary>
    Subesiz = 1,
    /// <summary>Hesapta <c>parola_degismeli = 1</c> iken de calisir.</summary>
    ParolaDegismeli = 2,
    Hepsi = Subesiz | ParolaDegismeli
}

public sealed record SinirliOturumIzni(SinirliOturum Izin);

public static class SinirliOturumUzantilari
{
    public static TBuilder SinirliOturumaAcik<TBuilder>(this TBuilder b, SinirliOturum izin)
        where TBuilder : IEndpointConventionBuilder
        => b.WithMetadata(new SinirliOturumIzni(izin));

    public static bool SinirliOturumaAcikMi(this HttpContext ctx, SinirliOturum izin)
        => ctx.GetEndpoint()?.Metadata.GetMetadata<SinirliOturumIzni>() is { } m
           && (m.Izin & izin) == izin;
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

        // ROL KUMESI HER ISTEKTE DB'DEN (denetim #7): token'daki rol, rol
        //   degisikliginden sonra da 30 dk gecerli kaliyordu. Bos kume =
        //   hesap pasif (fn_kullanici_rolleri aktif = 1 ister).
        var roller = await _kullanicilar.RolleriAsync(kullaniciId, iptal);
        if (roller.Count == 0) throw GentegreHatasi.Yetkisiz();
        var rolId = roller.FirstOrDefault(r => r.Ana).RolId;

        var yetkiler = await _yetkiCozucu.CozAsync(kullaniciId, iptal);
        var kapsam = await _kullanicilar.KapsamAsync(kullaniciId, iptal);
        var portalTuru = await _kullanicilar.PortalTuruAsync(kullaniciId, iptal);
        // KAPSAM KIMLIGI (819): kurum portalinda hesap KISININ, kapsam
        //   KURUMUN - iki sayi ayni degil.
        var portalKimlik = portalTuru > 0
            ? await _kullanicilar.PortalKimligiAsync(kullaniciId, iptal)
            : kullaniciId;
        var subeler = await _kullanicilar.SubeleriAsync(kullaniciId, iptal);
        var subeId = SubeCoz(ctx, subeler);
        // SUBESIZ OTURUM (denetim #1): son sube yetkisi kaldirilan kullanicinin
        //   token'i gecerli kalir; subeId null iken sube suzgeci hic eklenmiyor
        //   ve "sube yok" fiilen "butun subeler" oluyordu. Sube gerektiren her
        //   uc burada kapanir; yalniz acikca isaretlenen profil/parola uclari
        //   (SinirliOturum.Subesiz) calisir.
        if (subeId is null && !ctx.SinirliOturumaAcikMi(SinirliOturum.Subesiz))
            throw GentegreHatasi.Yasak("Calisabileceginiz aktif bir sube tanimli degil.");
        // Kimlik bicimi (679) ONBELLEKLI okunur: her istekte sorgu atmak
        //   ayarin kendisinden pahali olurdu.
        var kimlikKurali = await _kimlik.KuralAsync(subeId ?? 0, iptal);

        return new IstekBaglami
        {
            KullaniciId = kullaniciId,
            RolId = rolId,
            RolIdleri = roller.Select(r => r.RolId).Distinct().ToArray(),
            SubeId = subeId,
            SubeYazma = subeId is { } sid && subeler.Any(s => s.Id == sid && s.Yazma),
            Yetkiler = yetkiler,
            Kapsam = kapsam,
            PortalTuru = portalTuru,
            PortalKimlik = portalKimlik,
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

        if (ctx.Request.Headers.TryGetValue("X-Sube-Id", out var basligi))
        {
            // BOZUK BASLIK REDDEDILIR (denetim #1): sessizce token subesine
            //   dusmek istemcinin hangi subede calistigini belirsiz birakir.
            if (!int.TryParse(basligi.ToString(), NumberStyles.Integer,
                              CultureInfo.InvariantCulture, out var istenen))
                throw GentegreHatasi.Dogrulama("X-Sube-Id basligi gecersiz.");
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

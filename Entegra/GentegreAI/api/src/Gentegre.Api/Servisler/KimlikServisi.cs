using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.Extensions.Options;

namespace Gentegre.Api.Servisler;

/// <summary>
/// Giris / yenile / cikis akisi. Karar (19.08.2026): 30 dk access token +
/// doner (rotating) refresh token; iptal edilmis refresh tekrar kullanilirsa
/// AILE komple iptal edilir.
/// </summary>
public sealed class KimlikServisi
{
    private readonly KullaniciDeposu _kullanicilar;
    private readonly OturumDeposu _oturumlar;
    private readonly GunlukDeposu _gunluk;
    private readonly VeriKaynagi _veri;
    private readonly JwtUretici _jwt;
    private readonly GuvenlikAyarlari _ayar;

    public KimlikServisi(KullaniciDeposu kullanicilar, OturumDeposu oturumlar, GunlukDeposu gunluk,
                         VeriKaynagi veri, JwtUretici jwt, IOptions<GuvenlikAyarlari> ayar)
    {
        _kullanicilar = kullanicilar;
        _oturumlar = oturumlar;
        _gunluk = gunluk;
        _veri = veri;
        _jwt = jwt;
        _ayar = ayar.Value;
    }

    public async Task<GirisYaniti> GirisAsync(GirisIstegi istek, string ip, string istemci,
                                              CancellationToken iptal = default)
    {
        var kod = (istek.Kod ?? "").Trim().ToLowerInvariant();
        if (kod.Length == 0 || string.IsNullOrEmpty(istek.Parola))
            throw GentegreHatasi.Dogrulama("Kullanici adi ve parola gerekli.",
                new AlanHatasi("kod", "Bos birakilamaz."));

        var kullanici = await _kullanicilar.KodIleBulAsync(kod, iptal);

        if (kullanici is null)
        {
            await _gunluk.GirisDenemesiAsync(kod, null, ip, istemci, false, "yok", iptal);
            // Kullanici var mi yok mu bilgisini SIZDIRMA - ayni mesaj.
            throw GentegreHatasi.Yetkisiz("Kullanici adi ya da parola hatali.");
        }

        if (!kullanici.Aktif)
        {
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "pasif", iptal);
            throw GentegreHatasi.Yetkisiz("Bu kullanici pasif durumda.");
        }

        if (kullanici.KilitBitis is { } kilit && kilit > DateTime.Now)
        {
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "kilitli", iptal);
            throw GentegreHatasi.Yetkisiz(
                $"Cok sayida hatali giris - hesap {kilit:HH:mm}'e kadar kilitli.");
        }

        var parolaDogru = kullanici.ParolaHash.Length > 0 &&
                          BCrypt.Net.BCrypt.Verify(istek.Parola, kullanici.ParolaHash);

        if (!parolaDogru)
        {
            await _kullanicilar.HataliGirisAsync(kullanici.TarafId, iptal);
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "parola", iptal);
            throw GentegreHatasi.Yetkisiz("Kullanici adi ya da parola hatali.");
        }

        await _kullanicilar.GirisBasariliAsync(kullanici.TarafId, ip, iptal);
        await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, true, "", iptal);

        var subeler = await _kullanicilar.SubeleriAsync(kullanici.TarafId, iptal);
        var subeId = SubeSec(istek.SubeId, subeler);

        // Istekte sube geldiyse yetkili olmak ZORUNDA - varsayilana sessizce dusulmez.
        if (istek.SubeId is { } istenen && subeler.All(s => s.Id != istenen))
            throw GentegreHatasi.Yasak("Bu subede calisma yetkiniz yok.");

        // Tek oturum ayari acikken yeni giris oncekileri kapatir.
        if (await AyarAsync("guvenlik.tek_oturum", 0, iptal) == 1)
            await _oturumlar.KullaniciOturumlariniKapatAsync(kullanici.TarafId, "yeni_giris", iptal);

        var yanit = await TokenUretAsync(kullanici, subeler, subeId, null, null, ip, istemci, iptal);

        // Cok subeli kullanici sube secmeden girdiyse istemci secim ekrani gosterir.
        yanit.SubeSecimiGerekli = istek.SubeId is null && subeler.Count > 1;
        return yanit;
    }

    /// <summary>
    /// Aktif subeyi degistirir: yeni access token doner ve oturum kaydinin subesi
    /// guncellenir (yenilemede de ayni sube gelsin). Refresh token DEGISMEZ.
    /// </summary>
    public async Task<GirisYaniti> SubeSecAsync(int kullaniciId, int subeId, string refreshToken,
                                                CancellationToken iptal = default)
    {
        var kullanici = await _kullanicilar.IdIleBulAsync(kullaniciId, iptal)
                        ?? throw GentegreHatasi.Yetkisiz();

        var subeler = await _kullanicilar.SubeleriAsync(kullaniciId, iptal);
        if (subeler.All(s => s.Id != subeId))
            throw GentegreHatasi.Yasak("Bu subede calisma yetkiniz yok.");

        var dakika = await AyarAsync("guvenlik.jwt_dakika", _ayar.JwtDakika, iptal);
        var (token, sonaErme) = _jwt.Uret(kullanici.TarafId, kullanici.RolId, kullanici.YetkiSurumu,
            subeId, subeler.Select(s => s.Id), dakika);

        if (!string.IsNullOrWhiteSpace(refreshToken))
            await _oturumlar.SubeGuncelleAsync(JwtUretici.Hashle(refreshToken), subeId, iptal);

        return new GirisYaniti
        {
            AccessToken = token,
            RefreshToken = refreshToken ?? "",
            SonaErme = sonaErme,
            ParolaDegismeli = kullanici.ParolaDegismeli,
            Kullanici = KullaniciOzetiKur(kullanici, subeler, subeId)
        };
    }

    public async Task<GirisYaniti> YenileAsync(string refreshToken, string ip, string istemci,
                                               CancellationToken iptal = default)
    {
        if (string.IsNullOrWhiteSpace(refreshToken))
            throw GentegreHatasi.Yetkisiz();

        var hash = JwtUretici.Hashle(refreshToken);
        var oturum = await _oturumlar.HashIleBulAsync(hash, iptal)
                     ?? throw GentegreHatasi.Yetkisiz();

        // TEKRAR KULLANIM: iptal edilmis token yeniden geldi -> aile komple iptal.
        if (oturum.IptalTarihi is not null)
        {
            await _oturumlar.AileIptalAsync(oturum.AileId, "tekrar_kullanim", iptal);
            throw GentegreHatasi.Yetkisiz("Oturum guvenlik nedeniyle sonlandirildi, yeniden giris yapin.");
        }

        if (oturum.BitisTarihi <= DateTime.Now)
            throw GentegreHatasi.Yetkisiz("Oturum suresi doldu.");

        var kullanici = await _kullanicilar.IdIleBulAsync(oturum.KullaniciId, iptal);
        if (kullanici is null || !kullanici.Aktif)
        {
            await _oturumlar.AileIptalAsync(oturum.AileId, "kullanici_pasif", iptal);
            throw GentegreHatasi.Yetkisiz();
        }

        await _oturumlar.IptalAsync(oturum.Id, "yenilendi", iptal);

        var subeler = await _kullanicilar.SubeleriAsync(kullanici.TarafId, iptal);
        var subeId = SubeSec(oturum.SubeId, subeler);

        return await TokenUretAsync(kullanici, subeler, subeId, oturum.AileId, oturum.Id, ip, istemci, iptal);
    }

    public async Task CikisAsync(string refreshToken, CancellationToken iptal = default)
    {
        if (string.IsNullOrWhiteSpace(refreshToken)) return;
        var oturum = await _oturumlar.HashIleBulAsync(JwtUretici.Hashle(refreshToken), iptal);
        if (oturum is not null) await _oturumlar.IptalAsync(oturum.Id, "cikis", iptal);
    }

    public async Task ParolaDegistirAsync(int kullaniciId, ParolaDegistirIstegi istek,
                                          CancellationToken iptal = default)
    {
        var kullanici = await _kullanicilar.IdIleBulAsync(kullaniciId, iptal)
                        ?? throw GentegreHatasi.Yetkisiz();

        // Parola hic atanmamissa (goc) eski parola sorulmaz.
        if (kullanici.ParolaHash.Length > 0 &&
            !BCrypt.Net.BCrypt.Verify(istek.EskiParola ?? "", kullanici.ParolaHash))
            throw GentegreHatasi.Dogrulama("Mevcut parola hatali.",
                new AlanHatasi("eskiParola", "Parola dogrulanamadi."));

        var enAz = await AyarAsync("guvenlik.parola_min_uzunluk", 8, iptal);
        if ((istek.YeniParola ?? "").Length < enAz)
            throw GentegreHatasi.Dogrulama($"Parola en az {enAz} karakter olmali.",
                new AlanHatasi("yeniParola", $"En az {enAz} karakter."));

        var hash = BCrypt.Net.BCrypt.HashPassword(istek.YeniParola, workFactor: 12);
        await _kullanicilar.ParolaAtaAsync(kullaniciId, hash, degismeli: false, iptal);

        // Parola degisince acik oturumlar kapanir.
        await _oturumlar.KullaniciOturumlariniKapatAsync(kullaniciId, "parola_degisti", iptal);
    }

    public async Task DilDegistirAsync(int kullaniciId, DilDegistirIstegi istek,
                                       CancellationToken iptal = default)
    {
        if (istek.Dil is < 0 or > 2)
            throw GentegreHatasi.Dogrulama("Dil secimi gecersiz.",
                new AlanHatasi("dil", "Gecerli bir dil secin."));

        await _kullanicilar.DilAtaAsync(kullaniciId, (short)istek.Dil, iptal);
    }

    // ------------------------------------------------------------------ ic ----
    private async Task<GirisYaniti> TokenUretAsync(KullaniciKaydi kullanici,
        IReadOnlyList<SubeOzeti> subeler, int? subeId, Guid? aileId, long? oncekiId,
        string ip, string istemci, CancellationToken iptal)
    {
        var dakika = await AyarAsync("guvenlik.jwt_dakika", _ayar.JwtDakika, iptal);
        var gun = await AyarAsync("guvenlik.refresh_gun", _ayar.RefreshGun, iptal);

        var (token, sonaErme) = _jwt.Uret(kullanici.TarafId, kullanici.RolId, kullanici.YetkiSurumu,
            subeId, subeler.Select(s => s.Id), dakika);

        var (refresh, hash) = JwtUretici.RefreshUret();
        var refreshBitis = DateTime.Now.AddDays(gun);

        await _oturumlar.AcAsync(kullanici.TarafId, hash, refreshBitis, aileId, oncekiId,
            subeId, ip, istemci, iptal);

        return new GirisYaniti
        {
            AccessToken = token,
            RefreshToken = refresh,
            SonaErme = sonaErme,
            RefreshSonaErme = refreshBitis,
            ParolaDegismeli = kullanici.ParolaDegismeli,
            Kullanici = KullaniciOzetiKur(kullanici, subeler, subeId)
        };
    }

    private static KullaniciOzeti KullaniciOzetiKur(KullaniciKaydi kullanici,
        IReadOnlyList<SubeOzeti> subeler, int? subeId) => new()
    {
        Id = kullanici.TarafId,
        Kod = kullanici.Kod,
        Ad = kullanici.Ad,
        RolId = kullanici.RolId,
        RolAdi = kullanici.RolAdi,
        Dil = kullanici.Dil,
        YetkiSurumu = kullanici.YetkiSurumu,
        SubeId = subeId,
        SubeYazma = subeId is null || subeler.FirstOrDefault(s => s.Id == subeId)?.Yazma != false,
        Subeler = subeler
    };

    private static int? SubeSec(int? istenen, IReadOnlyList<SubeOzeti> subeler)
    {
        if (subeler.Count == 0) return null;
        if (istenen is { } i && subeler.Any(s => s.Id == i)) return i;
        return (subeler.FirstOrDefault(s => s.Varsayilan) ?? subeler[0]).Id;
    }

    /// <summary>Guvenlik ayarlari referans tablosunda; yoksa appsettings varsayilani.</summary>
    private async Task<int> AyarAsync(string anahtar, int varsayilan, CancellationToken iptal)
    {
        try
        {
            var deger = await _veri.TekDegerAsync<string>(
                "select deger from public.referans where anahtar = @p0",
                new object?[] { anahtar }, iptal);
            return int.TryParse(deger, out var s) ? s : varsayilan;
        }
        catch
        {
            return varsayilan;
        }
    }
}

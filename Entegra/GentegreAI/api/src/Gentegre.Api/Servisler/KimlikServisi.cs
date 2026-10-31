using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// Giris / yenile / cikis akisi. Karar (19.08.2026): 30 dk access token +
/// doner (rotating) refresh token; iptal edilmis refresh tekrar kullanilirsa
/// AILE komple iptal edilir.
/// </summary>
/// <summary>Panel giriş kodunun sakladığı kimlik (K29): token değil, kullanıcı + şube.</summary>
public sealed record PanelGirisKimligi(int KullaniciId, int? SubeId, bool SubeSecimiGerekli);

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

    /// <summary>Rol atanmamis hesabin giris / oturum mesaji (tek metin).</summary>
    public const string RolYokMesaji =
        "Hesabiniza rol atanmamis - sisteme giris icin yoneticinizden rol isteyin.";

    /// <summary>Askıya alınmış kurulum (1190, ayar genel.hesap_askida = 1).</summary>
    public const string AskidaMesaji =
        "Hesabınız askıda. Lütfen bizimle iletişime geçin.";

    public async Task<GirisYaniti> GirisAsync(GirisIstegi istek, string ip, string istemci,
                                              CancellationToken iptal = default)
    {
        var (kullanici, subeler, subeId) = await GirisDogrulaAsync(istek, ip, istemci, iptal);
        return await OturumAcAsync(kullanici, subeler, subeId, istek.SubeId is null && subeler.Count > 1, ip, istemci, iptal);
    }

    /// <summary>
    /// PANEL GİRİŞ KODU (kod inceleme 30.10.2026 K29): ortak panel girişi kimliği DOĞRULAR ama oturum açmaz -
    /// eskiden access + refresh token üretilip `giris_kodu.yanit`'a düz metin yazılıyordu (DB yedeği = geçerli
    /// oturum; kullanılmayan kodun oturumu 30 gün açık kalıyordu). Artık yalnız kimlik saklanır, token kod
    /// KULLANILIRKEN üretilir (<see cref="PanelKodundanGirisAsync"/>).
    /// </summary>
    public async Task<PanelGirisKimligi> PanelGirisDogrulaAsync(GirisIstegi istek, string ip, string istemci,
                                                                CancellationToken iptal = default)
    {
        var (kullanici, subeler, subeId) = await GirisDogrulaAsync(istek, ip, istemci, iptal);
        return new PanelGirisKimligi(kullanici.TarafId, subeId, istek.SubeId is null && subeler.Count > 1);
    }

    /// <summary>Panel kodu kullanılırken oturum açar (kimlik 60 sn önce parola ile doğrulanmıştı).</summary>
    public async Task<GirisYaniti> PanelKodundanGirisAsync(PanelGirisKimligi kimlik, string ip, string istemci,
                                                           CancellationToken iptal = default)
    {
        var kullanici = await _kullanicilar.IdIleBulAsync(kimlik.KullaniciId, iptal)
                        ?? throw GentegreHatasi.Yetkisiz();
        if (!kullanici.Aktif) throw GentegreHatasi.Yetkisiz();
        var subeler = await _kullanicilar.SubeleriAsync(kullanici.TarafId, iptal);
        if (kimlik.SubeId is { } s && subeler.All(x => x.Id != s))
            throw GentegreHatasi.Yasak("Bu subede calisma yetkiniz yok.");
        return await OturumAcAsync(kullanici, subeler, kimlik.SubeId, kimlik.SubeSecimiGerekli, ip, istemci, iptal);
    }

    private async Task<GirisYaniti> OturumAcAsync(KullaniciKaydi kullanici, List<SubeOzeti> subeler, int? subeId,
                                                  bool subeSecimiGerekli, string ip, string istemci, CancellationToken iptal)
    {
        // Tek oturum ayari acikken yeni giris oncekileri kapatir.
        if (await AyarAsync("guvenlik.tek_oturum", 0, iptal) == 1)
            await _oturumlar.KullaniciOturumlariniKapatAsync(kullanici.TarafId, "yeni_giris", iptal);

        var yanit = await TokenUretAsync(kullanici, subeler, subeId, null, null, ip, istemci, iptal);

        // Cok subeli kullanici sube secmeden girdiyse istemci secim ekrani gosterir.
        yanit.SubeSecimiGerekli = subeSecimiGerekli;
        return yanit;
    }

    /// <summary>Kimlik + sube dogrulamasi (parola, aktiflik, kilit, rol, aski); oturum ACMAZ.</summary>
    private async Task<(KullaniciKaydi Kullanici, List<SubeOzeti> Subeler, int? SubeId)> GirisDogrulaAsync(
        GirisIstegi istek, string ip, string istemci, CancellationToken iptal)
    {
        var kod = (istek.Kod ?? "").Trim().ToLowerInvariant();
        if (kod.Length == 0 || string.IsNullOrEmpty(istek.Parola))
            throw GentegreHatasi.Dogrulama("Kullanici adi ve parola gerekli.",
                new AlanHatasi("kod", "Bos birakilamaz."));

        // Kullanici adi KOD, CEP, E-POSTA ya da AD SOYAD olabilir (kullanici).
        // HESAP VARLIĞI SIZMAZ (kod inceleme 30.10.2026 K30): pasif / kilitli / belirsiz cevapları parola
        //   doğrulanmadan dönüyordu - ad bilen biri hesabın var olduğunu ve durumunu öğrenebiliyordu. Artık yanlış
        //   parolada HER durumda aynı genel mesaj; hesabın durumu yalnız DOĞRU parola girene söylenir (kendi
        //   hesabı pasif ya da kilitliyse bunu bilmesi gerekir). Günlüğe gerçek neden yine yazılır.
        const string genel = "Kullanici adi ya da parola hatali.";
        var (kullanici, belirsiz) = await _kullanicilar.EsnekBulAsync(kod, iptal);
        if (belirsiz)
        {
            await _gunluk.GirisDenemesiAsync(kod, null, ip, istemci, false, "belirsiz", iptal);
            throw GentegreHatasi.Yetkisiz(genel);
        }

        if (kullanici is null)
        {
            await _gunluk.GirisDenemesiAsync(kod, null, ip, istemci, false, "yok", iptal);
            throw GentegreHatasi.Yetkisiz(genel);
        }

        // PAROLASI HIC TANIMLANMAMIS hesap: istemci dogrudan "parolani belirle"
        //   ekranini acar (kullanici: "sifre bossa user pass ekrani direk ciksin").
        //   Bilinçli istisna: ilk-parola akışı bu sinyale muhtaç; hesap aktif ve kilitsizse söylenir.
        var parolaDogru = kullanici.ParolaHash.Length > 0
                       && BCrypt.Net.BCrypt.Verify(istek.Parola, kullanici.ParolaHash);

        if (!kullanici.Aktif)
        {
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "pasif", iptal);
            throw GentegreHatasi.Yetkisiz(parolaDogru ? "Bu kullanici pasif durumda." : genel);
        }

        // 667: kilit bitisi veritabanindan UTC AN olarak gelir - duvar saatiyle
        //   karsilastirmak hesabi 3 saat erken/gec acardi.
        if (kullanici.KilitBitis is { } kilit && kilit > Saat.An)
        {
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "kilitli", iptal);
            throw GentegreHatasi.Yetkisiz(parolaDogru
                ? $"Cok sayida hatali giris - hesap {kilit:HH:mm}'e kadar kilitli."
                : genel);
        }

        if (kullanici.ParolaHash.Length == 0)
        {
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false,
                                             "parola_yok", iptal);
            throw GentegreHatasi.IlkParolaGerekli();
        }

        if (!parolaDogru)
        {
            await _kullanicilar.HataliGirisAsync(kullanici.TarafId, iptal);
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "parola", iptal);
            throw GentegreHatasi.Yetkisiz("Kullanici adi ya da parola hatali.");
        }

        // ROL ATANMAMIS HESAP GIREMEZ (kullanici). Parola DOGRULANDIKTAN sonra
        //   bakilir: once bakilsa yanlis parolayla hesabin varligi sizardi.
        if (kullanici.RolAtanmamis)
        {
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "rol_yok", iptal);
            throw GentegreHatasi.Yetkisiz(RolYokMesaji);
        }

        // HESAP ASKIDA (1190, ortak giriş paneli kararı 26.10.2026): kurulum askıya alınmışsa (sözleşme bitti)
        //   DOĞRU parola girene "askıda" denir; yanlış parolaya genel hata (yukarıda) - bilgi sızmaz.
        if (await AyarAsync("genel.hesap_askida", 0, iptal) == 1)
        {
            await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, false, "askida", iptal);
            throw GentegreHatasi.Yasak(AskidaMesaji, "HESAP_ASKIDA");
        }

        await _kullanicilar.GirisBasariliAsync(kullanici.TarafId, ip, iptal);
        await _gunluk.GirisDenemesiAsync(kod, kullanici.TarafId, ip, istemci, true, "giris", iptal);

        var subeler = await _kullanicilar.SubeleriAsync(kullanici.TarafId, iptal);
        var subeId = SubeSec(istek.SubeId, subeler);

        // Istekte sube geldiyse yetkili olmak ZORUNDA - varsayilana sessizce dusulmez.
        if (istek.SubeId is { } istenen && subeler.All(s => s.Id != istenen))
            throw GentegreHatasi.Yasak("Bu subede calisma yetkiniz yok.");

        return (kullanici, subeler, subeId);
    }

    /// <summary>
    /// Aktif subeyi degistirir: yeni access token doner ve oturum kaydinin subesi
    /// guncellenir (yenilemede de ayni sube gelsin). Refresh token DEGISMEZ.
    /// </summary>
    public async Task<GirisYaniti> SubeSecAsync(int kullaniciId, int subeId, string refreshToken,
                                                Guid aileId, CancellationToken iptal = default)
    {
        var kullanici = await _kullanicilar.IdIleBulAsync(kullaniciId, iptal)
                        ?? throw GentegreHatasi.Yetkisiz();

        var subeler = await _kullanicilar.SubeleriAsync(kullaniciId, iptal);
        if (subeler.All(s => s.Id != subeId))
            throw GentegreHatasi.Yasak("Bu subede calisma yetkiniz yok.");

        var dakika = await AyarAsync("guvenlik.jwt_dakika", _ayar.JwtDakika, iptal);
        // Aynı oturum ailesi: şube değişimi yeni oturum açmaz (OturumKapisi aileyi doğrulamıştır).
        var (token, sonaErme) = _jwt.Uret(kullanici.TarafId, kullanici.RolId, kullanici.YetkiSurumu,
            subeId, subeler.Select(s => s.Id), dakika, aileId);

        if (!string.IsNullOrWhiteSpace(refreshToken))
            await _oturumlar.SubeGuncelleAsync(JwtUretici.Hashle(refreshToken), subeId, iptal);

        return new GirisYaniti
        {
            AccessToken = token,
            RefreshToken = refreshToken ?? "",
            SonaErme = sonaErme,
            ParolaDegismeli = kullanici.ParolaDegismeli,
            Kullanici = KullaniciOzetiKur(kullanici, subeler, subeId,
                await UrunModuAsync(subeId, iptal),
                await AcikModullerAsync(subeId, iptal),
                await HekimRoluAsync(subeId, iptal),
                await KurumTipiAsync(subeId, iptal),
                await IskontoEsigiAsync(iptal),
                await _kullanicilar.PortalTuruAsync(kullanici.TarafId, iptal),
                await _kullanicilar.HekimKisitliAsync(kullanici.TarafId, iptal),
                await OrtamAsync(iptal))
        };
    }

    public async Task<GirisYaniti> YenileAsync(string refreshToken, string ip, string istemci,
                                               CancellationToken iptal = default)
    {
        if (string.IsNullOrWhiteSpace(refreshToken))
            throw GentegreHatasi.Yetkisiz();

        var hash = JwtUretici.Hashle(refreshToken);

        // ATOMIK ROTATION (denetim 28.09.2026 #6): eski satirin okunmasi,
        //   kapatilmasi ve yeni satirin acilmasi TEK baglanti + TEK islem.
        //   Satir kilidi (FOR UPDATE) ayni token'la gelen ikinci istegi
        //   bekletir; o, birincinin sonucunu (iptal edilmis satir) gorur.
        //   Islem commit edilmeden yanit donmez: yeni satir yazilamazsa eski
        //   token TUKENMEMIS kalir (rollback).
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var oturum = await OturumDeposu.KilitleAsync(baglanti, islem, hash, iptal)
                     ?? throw GentegreHatasi.Yetkisiz();

        // TEKRAR KULLANIM: iptal edilmis token yeniden geldi -> aile komple
        //   iptal. Iptal hata donmeden ONCE commit edilir; aksi halde hata
        //   yolundaki rollback aile iptalini de geri alirdi.
        if (oturum.IptalTarihi is not null)
        {
            await OturumDeposu.AileIptalAsync(baglanti, islem, oturum.AileId, "tekrar_kullanim", iptal);
            await islem.CommitAsync(iptal);
            throw GentegreHatasi.Yetkisiz("Oturum guvenlik nedeniyle sonlandirildi, yeniden giris yapin.");
        }

        if (oturum.BitisTarihi <= Saat.An)
            throw GentegreHatasi.Yetkisiz("Oturum suresi doldu.");

        var kullanici = await _kullanicilar.IdIleBulAsync(oturum.KullaniciId, iptal);
        if (kullanici is null || !kullanici.Aktif)
        {
            await OturumDeposu.AileIptalAsync(baglanti, islem, oturum.AileId, "kullanici_pasif", iptal);
            await islem.CommitAsync(iptal);
            throw GentegreHatasi.Yetkisiz();
        }
        // Rolu sonradan "Rol Atanmamis"a cekilen kisi oturumunu yenileyemez.
        if (kullanici.RolAtanmamis)
        {
            await OturumDeposu.AileIptalAsync(baglanti, islem, oturum.AileId, "rol_yok", iptal);
            await islem.CommitAsync(iptal);
            throw GentegreHatasi.Yetkisiz(RolYokMesaji);
        }
        // Askıya alınan kurulumda açık oturum da yenilenemez (1190).
        if (await AyarAsync("genel.hesap_askida", 0, iptal) == 1)
        {
            await OturumDeposu.AileIptalAsync(baglanti, islem, oturum.AileId, "askida", iptal);
            await islem.CommitAsync(iptal);
            throw GentegreHatasi.Yasak(AskidaMesaji, "HESAP_ASKIDA");
        }

        // Kilit altinda satir acik olmali; degilse (beklenmeyen) yeni dal ACILMAZ.
        if (await OturumDeposu.IptalAsync(baglanti, islem, oturum.Id, "yenilendi", iptal) != 1)
            throw GentegreHatasi.Yetkisiz();

        var subeler = await _kullanicilar.SubeleriAsync(kullanici.TarafId, iptal);
        var subeId = SubeSec(oturum.SubeId, subeler);

        var yanit = await TokenUretAsync(kullanici, subeler, subeId, oturum.AileId, oturum.Id,
                                         ip, istemci, iptal, baglanti, islem);
        await islem.CommitAsync(iptal);
        return yanit;
    }

    public async Task CikisAsync(string refreshToken, CancellationToken iptal = default)
    {
        if (string.IsNullOrWhiteSpace(refreshToken)) return;
        var oturum = await _oturumlar.HashIleBulAsync(JwtUretici.Hashle(refreshToken), iptal);
        if (oturum is not null) await _oturumlar.IptalAsync(oturum.Id, "cikis", iptal);
    }

    /// <summary>
    /// Parola degisir, ACIK OTURUMLARIN HEPSI kapanir ve bu cihaz icin YENI
    /// bir oturum (yeni aile) acilir. Eskiden yanit bos donuyordu: access
    /// token 30 dk sonra bitince refresh de iptal edilmis oldugu icin kisi
    /// parolasini degistirdigi ekrandan atiliyordu.
    /// </summary>
    public async Task<GirisYaniti> ParolaDegistirAsync(int kullaniciId, int? subeId,
        ParolaDegistirIstegi istek, string ip, string istemci, CancellationToken iptal = default)
    {
        var kullanici = await _kullanicilar.IdIleBulAsync(kullaniciId, iptal)
                        ?? throw GentegreHatasi.Yetkisiz();

        // DEMO KULLANICISI (964) parolasini degistiremez: girisler ekranda
        //   herkese acik yazili; degisirse sonraki ziyaretci giremez.
        if (kullanici.Kod.StartsWith("demo.", StringComparison.Ordinal)
            && await _veri.TekDegerAsync<string?>(
                   "select deger from public.referans where anahtar = 'kurulum.demo'", null, iptal) == "1")
            throw GentegreHatasi.IsKurali("Demo kullanıcısının parolası değiştirilemez.");

        // Parola hic atanmamissa (goc) eski parola sorulmaz.
        if (kullanici.ParolaHash.Length > 0 &&
            !BCrypt.Net.BCrypt.Verify(istek.EskiParola ?? "", kullanici.ParolaHash))
            throw GentegreHatasi.Dogrulama("Mevcut parola hatali.",
                new AlanHatasi("eskiParola", "Parola dogrulanamadi."));

        var enAz = await AyarAsync("guvenlik.parola_min_uzunluk", ParolaKurali.VarsayilanEnAz, iptal);
        ParolaKurali.Dogrula(istek.YeniParola, enAz);

        // SON n PAROLADAN FARKLI (687, kullanici: "son 3 sifreden farkli"):
        //   mevcut hash + gecmisteki (n-1) hash ile BCrypt karsilastirmasi.
        //   Duz metin saklanmaz; eslesme yalniz dogrulamayla anlasilir.
        var gecmisSayisi = await AyarAsync("guvenlik.parola_gecmis_sayi", 3, iptal);
        if (gecmisSayisi > 0)
        {
            var adaylar = new List<string>();
            if (kullanici.ParolaHash.Length > 0) adaylar.Add(kullanici.ParolaHash);
            adaylar.AddRange(await _kullanicilar.SonParolaHashleriAsync(kullaniciId, gecmisSayisi - 1, iptal));
            foreach (var eski in adaylar.Take(gecmisSayisi))
            {
                bool ayni;
                try { ayni = BCrypt.Net.BCrypt.Verify(istek.YeniParola, eski); }
                catch { ayni = false; }   // eski algoritma / bozuk hash: kiyaslanamaz, gecer
                if (ayni)
                    throw GentegreHatasi.Dogrulama($"Yeni parola son {gecmisSayisi} parolanizdan farkli olmali.",
                        new AlanHatasi("yeniParola", $"Son {gecmisSayisi} paroladan biri."));
            }
        }

        var hash = BCrypt.Net.BCrypt.HashPassword(istek.YeniParola, workFactor: 12);
        if (kullanici.ParolaHash.Length > 0)
            await _kullanicilar.ParolaGecmisineYazAsync(kullaniciId, kullanici.ParolaHash, iptal);
        await _kullanicilar.ParolaAtaAsync(kullaniciId, hash, degismeli: false, iptal);

        // Parola degisince acik oturumlar kapanir.
        await _oturumlar.KullaniciOturumlariniKapatAsync(kullaniciId, "parola_degisti", iptal);

        var guncel = await _kullanicilar.IdIleBulAsync(kullaniciId, iptal)
                     ?? throw GentegreHatasi.Yetkisiz();
        var subeler = await _kullanicilar.SubeleriAsync(kullaniciId, iptal);
        return await TokenUretAsync(guncel, subeler, SubeSec(subeId, subeler), null, null,
                                    ip, istemci, iptal);
    }

    /// <summary>
    /// VARSAYILAN ILK PAROLA (kullanici: "ilk giris sifreleri default personel
    /// kartin ID si olsun.. ama ilk giriste degistirmeye zorlasin").
    ///
    /// Personel kartinin ID'si parola olur ve <c>parola_degismeli = 1</c>
    /// yazilir: kisi giris yapar yapmaz kendi parolasini belirlemek zorunda
    /// kalir. ID gizli bir sey degildir - bu yuzden PAROLA DEGIL, tek kullanimlik
    /// bir kapidir; zorunlu degisiklik olmadan kullanilamaz.
    /// </summary>
    public static string VarsayilanParola(int tarafId) => tarafId.ToString();

    /// <summary>
    /// PERSONEL HESAPLARINI HAZIRLA: hesabi olmayan aktif personele hesap acar,
    /// PAROLASIZ hesaplara varsayilan parolayi (kart id'si) yazar.
    ///
    /// Dolu parolaya DOKUNMAZ - kisinin belirledigi parolayi varsayilana
    /// cevirmek hesabi herkese acardi. <paramref name="tarafId"/> verilirse
    /// yalniz o kisi icin calisir (kart kaydinda).
    ///
    /// <paramref name="sifirla"/> = true DOLU PAROLALARI DA varsayilana ceker
    /// (kullanici istegi: eski kayitlari toplu acmak). ADMIN disaridadir.
    /// </summary>
    public async Task<(int Acilan, int ParolaAtanan)> PersonelHesaplariHazirlaAsync(
        int? tarafId = null, bool sifirla = false, CancellationToken iptal = default)
    {
        var acilan = await _kullanicilar.OtomatikHesapAcAsync(tarafId, iptal);
        var parolasiz = await _kullanicilar.VarsayilanParolaHedefleriAsync(
            tarafId, sifirla, iptal);
        foreach (var id in parolasiz)
        {
            var hash = BCrypt.Net.BCrypt.HashPassword(VarsayilanParola(id), workFactor: 12);
            // degismeli: TRUE - ilk giriste parola degistirme ekrani zorunlu.
            await _kullanicilar.ParolaAtaAsync(id, hash, degismeli: true, iptal);
        }
        return (acilan, parolasiz.Count);
    }

    // ILK PAROLA (parolasi bos hesap) artik ParolaSifirlamaServisi'nde: TCKN
    //   son 4 tek basina parola belirleyemez, kayitli kanala giden tek
    //   kullanimlik kod gerekir (denetim 28.09.2026 #5).

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
        string ip, string istemci, CancellationToken iptal,
        NpgsqlConnection? baglanti = null, NpgsqlTransaction? islem = null)
    {
        var dakika = await AyarAsync("guvenlik.jwt_dakika", _ayar.JwtDakika, iptal);
        var gun = await AyarAsync("guvenlik.refresh_gun", _ayar.RefreshGun, iptal);

        // Yeni aile burada belirlenir (DB varsayılanına bırakılmaz): access token aynı aile kimliğini taşır (B05).
        var aile = aileId ?? Guid.NewGuid();
        var (token, sonaErme) = _jwt.Uret(kullanici.TarafId, kullanici.RolId, kullanici.YetkiSurumu,
            subeId, subeler.Select(s => s.Id), dakika, aile);

        var (refresh, hash) = JwtUretici.RefreshUret();
        // Veritabanina yazilacak: AN (UTC), duvar saati degil (667).
        var refreshBitis = Saat.An.AddDays(gun);

        // Yenilemede satir, eski satiri kapatan AYNI islemle yazilir (#6).
        if (baglanti is not null)
            await OturumDeposu.AcAsync(baglanti, islem, kullanici.TarafId, hash, refreshBitis,
                aile, oncekiId, subeId, ip, istemci, iptal);
        else
            await _oturumlar.AcAsync(kullanici.TarafId, hash, refreshBitis, aile, oncekiId,
                subeId, ip, istemci, iptal);

        return new GirisYaniti
        {
            AccessToken = token,
            RefreshToken = refresh,
            SonaErme = sonaErme,
            RefreshSonaErme = refreshBitis,
            ParolaDegismeli = kullanici.ParolaDegismeli,
            Kullanici = KullaniciOzetiKur(kullanici, subeler, subeId,
                await UrunModuAsync(subeId, iptal),
                await AcikModullerAsync(subeId, iptal),
                await HekimRoluAsync(subeId, iptal),
                await KurumTipiAsync(subeId, iptal),
                await IskontoEsigiAsync(iptal),
                await _kullanicilar.PortalTuruAsync(kullanici.TarafId, iptal),
                await _kullanicilar.HekimKisitliAsync(kullanici.TarafId, iptal),
                await OrtamAsync(iptal))
        };
    }

    /// <summary>
    /// Acik moduller (359) - giris yanitinda da doner: menu ilk cizimde dogru
    /// olsun, /ben yanitini beklemek zorunda kalmasin.
    /// </summary>
    /// <summary>
    /// AKTIF SUBENIN urun modu (489). Eskiden `referans genel.urun_modu`
    /// okunuyordu; ekran ise modu subenin profiline yaziyordu - iki kaynak
    /// ayrilinca giris yaniti ERP diyor, Firma Bilgileri HBYS gosteriyordu.
    /// </summary>
    private async Task<int> UrunModuAsync(int? subeId, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await KurumProfilDeposu.UrunModuAsync(baglanti, subeId ?? 0, iptal);
    }

    /// <summary>Aktif subenin basvuru hekim rolu (361/364).</summary>
    private async Task<int> HekimRoluAsync(int? subeId, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await KurumProfilDeposu.HekimRoluAsync(baglanti, subeId ?? 0, iptal);
    }

    /// <summary>
    /// ISKONTO ONAY ESIGI (783): bu oranin ustundeki iskonto - yetki tavani ne
    /// olursa olsun - onayli talepten gelmek zorunda. Ekran limiti bunu da
    /// hesaba katar; kural sunucuda TETIKLE korunuyor, buradaki deger yalnizca
    /// kullaniciyi bosa ugrastirmamak icin.
    /// </summary>
    /// <summary>Kurulum ortamı (1008): bilinmeyen değer canlı sayılır.</summary>
    private async Task<string> OrtamAsync(CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var m = (await AyarDeposu.MetinAsync(baglanti, null, "genel.ortam", "canli", iptal))
                .Trim().ToLowerInvariant();
        return m is "demo" or "egitim" ? m : "canli";
    }

    private async Task<decimal> IskontoEsigiAsync(CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var m = await AyarDeposu.MetinAsync(baglanti, null,
                                            "basvuru.iskonto_onay_esik", "", iptal);
        return decimal.TryParse(m, System.Globalization.NumberStyles.Any,
                   System.Globalization.CultureInfo.InvariantCulture, out var d) && d > 0
            ? d : 0m;
    }

    /// <summary>Aktif subenin kurum tipi (786) + menu tipi (905) - tek okuyucu depoda.</summary>
    private async Task<(string Kod, string Ad, short MenuBolgeli)> KurumTipiAsync(int? subeId,
        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await KurumProfilDeposu.KurumTipiAsync(baglanti, subeId ?? 0, iptal);
    }

    private async Task<IReadOnlyList<string>> AcikModullerAsync(int? subeId,
        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        // AKTIF SUBENIN profili (364): sube secimi giriste yapiliyor, menu de
        //   o subenin modulleriyle cizilsin.
        return await KurumProfilDeposu.AcikModullerAsync(baglanti, subeId ?? 0, iptal);
    }

    private static KullaniciOzeti KullaniciOzetiKur(KullaniciKaydi kullanici,
        IReadOnlyList<SubeOzeti> subeler, int? subeId, int urunModu,
        IReadOnlyList<string> moduller, int hekimRolu,
        (string Kod, string Ad, short MenuBolgeli) kurumTipi = default,
        decimal iskontoEsigi = 0m, short portalTuru = 0, bool hekimKisitli = false,
        string ortam = "canli") => new()
    {
        Ortam = ortam,
        HekimKisitli = hekimKisitli,
        // PORTAL TURU (806): giris yanitinda da tasinir - sayfa yenilenmeden
        //   once ekran portal kullanicisina anlamsiz dugmeyi gostermesin.
        PortalTuru = portalTuru,
        // PORTAL MENUSU (796 V2): kapsami ACIK kaynaklar. Yetki tek basina
        //   yetmiyor - kurali `false` olan ekran acilsa bos gelirdi.
        PortalKaynaklar = KaynakKatalogu.PortalKaynaklari(portalTuru),
        Id = kullanici.TarafId,
        Kod = kullanici.Kod,
        Ad = kullanici.Ad,
        RolId = kullanici.RolId,
        RolAdi = kullanici.RolAdi,
        EkRolAdlari = kullanici.EkRolAdlari,
        Dil = kullanici.Dil,
        ParolaDegismeli = kullanici.ParolaDegismeli,
        YetkiSurumu = kullanici.YetkiSurumu,
        SubeId = subeId,
        // Subesiz oturum YAZAMAZ (denetim #1) - istek baglamiyla ayni kural.
        SubeYazma = subeId is { } sid && subeler.Any(s => s.Id == sid && s.Yazma),
        Subeler = subeler,
        UrunModu = urunModu,
        Moduller = moduller,
        HekimRolu = hekimRolu,
        KurumTipi = kurumTipi.Kod ?? "",
        KurumTipiAdi = kurumTipi.Ad ?? "",
        MenuBolgeli = kurumTipi.MenuBolgeli,
        IskontoOnayEsigi = iskontoEsigi
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

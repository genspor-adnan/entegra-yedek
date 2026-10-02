using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.AspNetCore.Authorization;

namespace Gentegre.Api.Uclar;

public static class KimlikUclari
{
    public static void KimlikUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kimlik").WithTags("Kimlik");

        grup.MapPost("/giris", [AllowAnonymous] async (
            GirisIstegi istek, KimlikServisi servis, HttpContext ctx, CancellationToken iptal)
            => Results.Ok(await servis.GirisAsync(istek, Ip(ctx), Istemci(ctx), iptal)));

        grup.MapPost("/yenile", [AllowAnonymous] async (
            YenileIstegi istek, KimlikServisi servis, HttpContext ctx, CancellationToken iptal)
            => Results.Ok(await servis.YenileAsync(istek.RefreshToken, Ip(ctx), Istemci(ctx), iptal)));

        grup.MapPost("/cikis", [AllowAnonymous] async (
            YenileIstegi istek, KimlikServisi servis, CancellationToken iptal) =>
        {
            await servis.CikisAsync(istek.RefreshToken, iptal);
            return Results.NoContent();
        });

        // Cok subeli kullanici calisma subesini degistirir: yeni access token,
        //   refresh ayni kalir. Yetkisiz sube -> 403.
        grup.MapPost("/sube", async (
            SubeSecIstegi istek, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var refresh = ctx.Request.Headers["X-Refresh-Token"].ToString();
            return Results.Ok(await servis.SubeSecAsync(baglam.KullaniciId, istek.SubeId, refresh, iptal));
        }).RequireAuthorization();

        // Kullanicinin giris / islem yapabilecegi subeler (rolunun subeleri - rol_sube, 234).
        grup.MapGet("/subeler", async (
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            return Results.Ok(new
            {
                aktifSubeId = baglam.SubeId,
                yazma = baglam.SubeYazma,
                subeler = baglam.Subeler
            });
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Subesiz);

        grup.MapGet("/ben", async (
            BaglamCozucu cozucu, KullaniciDeposu kullanicilar, VeriKaynagi veri,
            KurumProfilDeposu kurum, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kullanici = await kullanicilar.IdIleBulAsync(baglam.KullaniciId, iptal)
                            ?? throw GentegreHatasi.Yetkisiz();
            var subeler = await kullanicilar.SubeleriAsync(baglam.KullaniciId, iptal);

            // Urun modu (215/489) - giris yanitindaki ile ayni kaynak: AKTIF
            //   SUBENIN profili. /ben acilista cagrildigi icin buradan da
            //   gelmezse istemci hep ERP sanirdi.
            var urunModu = await kurum.UrunModuAsync(baglam.SubeId ?? 0, iptal);

            return Results.Ok(new BenYaniti
            {
                Kullanici = new KullaniciOzeti
                {
                    Id = kullanici.TarafId,
                    Kod = kullanici.Kod,
                    Ad = kullanici.Ad,
                    RolId = kullanici.RolId,
                    RolAdi = kullanici.RolAdi,
                    // PORTAL TURU (806): arayuz kural yazmaz, yalniz portal
                    //   kullanicisina anlamsiz dugmeyi gostermez.
                    PortalTuru = baglam.PortalTuru,
                    Dil = kullanici.Dil,
                    // Zorunlu parola degisimi (674): /ben de tasir.
                    ParolaDegismeli = kullanici.ParolaDegismeli,
                    YetkiSurumu = baglam.Yetkiler.YetkiSurumu,
                    SubeId = baglam.SubeId,
                    SubeYazma = baglam.SubeYazma,
                    Subeler = subeler,
                    UrunModu = urunModu,
                    // Acik moduller (359): menu ve rotalar bunlara gore suzulur.
                    Moduller = await kurum.AcikModullerAsync(baglam.SubeId ?? 0, iptal),
                    // Basvuruda sorulan hekim rolu (361/364) - aktif subeye gore.
                    HekimRolu = await kurum.HekimRoluAsync(baglam.SubeId ?? 0, iptal),
                    // KURUM PROFILI (786): sol menunun Oturum bolumu yazar.
                    //   /ben'de de donmeli - sayfayi yenileyen kullanicinin
                    //   oturumu giris yanitindan degil buradan kuruluyor.
                    KurumTipi = (await kurum.KurumTipiAsync(baglam.SubeId ?? 0, iptal)).Kod,
                    KurumTipiAdi = (await kurum.KurumTipiAsync(baglam.SubeId ?? 0, iptal)).Ad,
                    // MENU TIPI (905): sol menu bolge modunu bundan okur.
                    MenuBolgeli = (await kurum.KurumTipiAsync(baglam.SubeId ?? 0, iptal)).MenuBolgeli,
                    // ISKONTO ONAY ESIGI (783): ekran limiti tavanla BIRLIKTE
                    //   bunu da gozetir - esik ustu iskonto onayli talepten
                    //   gelmek zorunda (kural sunucuda tetikle korunuyor).
                    IskontoOnayEsigi = await IskontoEsigiAsync(veri, iptal)
                },
                // Yetkisiz aksiyon HIC donmez (API §7).
                Aksiyonlar = baglam.Yetkiler.Tumu.Where(y => y.Tur == 1 && y.Gor)
                                   .Select(y => y.Kod).OrderBy(k => k).ToList(),
                // SINIRLI aksiyonlarin degeri (661): iskonto tavani gibi. Kod
                //   listede olsa da sinir 0 ise istemci islemi acmaz.
                AksiyonDegerleri = baglam.Yetkiler.Tumu
                                   .Where(y => y.Tur == 1 && y.Gor && y.Deger.Length > 0)
                                   .Select(y => new { y.Kod, D = baglam.Yetkiler.AksiyonDegeri(y.Kod) })
                                   .Where(x => x.D != 0m)
                                   .ToDictionary(x => x.Kod, x => x.D),
                Kaynaklar = baglam.Yetkiler.Tumu.Where(y => y.Tur == 0)
                                   .Select(y => new KaynakYetkisi(y.Kod, y.Gor, y.Ekle, y.Degistir, y.Sil))
                                   .OrderBy(k => k.Kod).ToList()
            });
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Hepsi);

        // MARKA (anonim, 502): giris ekrani hangi urunun kapisi oldugunu
        //   OTURUM ACILMADAN bilmeli - "Gentegre" yazan sabit baslik, HBYS
        //   kurulumunda (GenoTIP AI) yanlis urun adi gosteriyordu. Mod
        //   kurulusun profilinden gelir (fn_urun_modu, 489); veritabanina
        //   ulasilamazsa istemci kendi yolundan (BASE_URL) tahmin eder.
        grup.MapGet("/marka", [AllowAnonymous] async (
            VeriKaynagi veri, CancellationToken iptal) =>
        {
            var mod = await veri.TekDegerAsync<int>(
                "select public.fn_urun_modu(0)::int", [], iptal);
            return Results.Ok(new { urunModu = mod });
        });

        // ILK PAROLA (anonim, denetim 28.09.2026 #5): iki adim. TCKN son 4
        //   yalniz kod gondermenin on kosulu; parolayi kayitli kanala giden
        //   tek kullanimlik kod belirler (bkz. ParolaSifirlamaServisi).
        //   1. adimin cevabi HER DURUMDA aynidir - hesap varligi sizmaz.
        grup.MapPost("/ilk-parola/kod", async (
            IlkParolaIstegi istek, Servisler.ParolaSifirlamaServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            await servis.IlkParolaKodGonderAsync(istek.Kod, istek.TcknSon4, Ip(ctx), Istemci(ctx), iptal);
            return Results.Ok(new { mesaj = Servisler.ParolaSifirlamaServisi.IlkParolaGenelMesaj });
        }).AllowAnonymous();

        grup.MapPost("/ilk-parola", async (
            IlkParolaIstegi istek, Servisler.ParolaSifirlamaServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            await servis.IlkParolaBelirleAsync(istek.Kod, istek.DogrulamaKodu, istek.YeniParola,
                Ip(ctx), Istemci(ctx), iptal);
            return Results.Ok(new { mesaj = "Parolanız tanımlandı, giriş yapabilirsiniz." });
        }).AllowAnonymous();

        // PAROLAMI UNUTTUM (843, anonim): kayıtlı cep / e-postaya tek kullanımlık kod,
        //   kodla yeni parola. Hesap yoksa da aynı genel cevap (bkz. ParolaSifirlamaServisi).
        grup.MapPost("/parola-unuttum", async (
            ParolaUnuttumIstegi istek, Servisler.ParolaSifirlamaServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var s = await servis.KodGonderAsync(istek.Kod, Ip(ctx), ctx.Request.Headers.UserAgent.ToString(), iptal);
            return Results.Ok(new { s.Gonderildi, s.Kanal, s.Hedef, s.Dakika, mesaj = Servisler.ParolaSifirlamaServisi.GenelMesaj });
        }).AllowAnonymous();

        grup.MapPost("/parola-unuttum/dogrula", async (
            ParolaUnuttumDogrulaIstegi istek, Servisler.ParolaSifirlamaServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            await servis.DogrulaAsync(istek.Kod, istek.DogrulamaKodu, istek.YeniParola, Ip(ctx),
                ctx.Request.Headers.UserAgent.ToString(), iptal);
            return Results.Ok(new { mesaj = "Parolanız değiştirildi, yeni parolanızla giriş yapabilirsiniz." });
        }).AllowAnonymous();

        // PERSONEL HESAPLARI (674): hesabi olmayana hesap acar, parolasiz
        //   hesaba varsayilan parolayi (kart id) yazar. Listeye elle girilmis
        //   ya da gocle gelmis personel bu ucla girise acilir - kart ekranindan
        //   tek tek gecmek 93 kisilik listede gercekci degil.
        //   `sifirla=true` DOLU parolalari da kart id'sine ceker (admin haric).
        grup.MapPost("/personel-hesap", async (
            int? tarafId, bool? sifirla, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("personel", Gentegre.Cekirdek.Yetki.Islem.Degistir);
            var (acilan, parola) = await servis.PersonelHesaplariHazirlaAsync(
                tarafId, sifirla == true, iptal);
            return Results.Ok(new { acilan, parolaAtanan = parola });
        }).RequireAuthorization();

        grup.MapPost("/parola", async (
            ParolaDegistirIstegi istek, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Yeni token cifti doner: diger oturumlar kapanir, bu cihaz devam eder.
            return Results.Ok(await servis.ParolaDegistirAsync(baglam.KullaniciId, baglam.SubeId,
                istek, Ip(ctx), Istemci(ctx), iptal));
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Hepsi);

        grup.MapPost("/dil", async (
            DilDegistirIstegi istek, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await servis.DilDegistirAsync(baglam.KullaniciId, istek, iptal);
            return Results.NoContent();
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Subesiz);

        // ------------------------------------- KULLANICI AYARLARI (669) ----
        // Hepsi KISININ KENDI hesabi uzerinde calisir; kullanici kimligi
        //   baglamdan gelir, istekten DEGIL - "kullaniciId" parametresi alan
        //   bir uc, baskasinin hesabini okumanin kapisi olurdu. Bu yuzden
        //   yetki de istemezler: kendi e-postasini gormek icin `kullanici`
        //   yetkisi aramak, herkesin yonetici olmasini gerektirirdi.

        grup.MapGet("/hesabim", async (
            KullaniciDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var h = await depo.HesapBilgisiAsync(baglam.KullaniciId, iptal);
            if (h is null) return Results.NotFound();
            return Results.Ok(new
            {
                unvan = h.Unvan, gorev = h.Gorev,
                eposta = h.Eposta, cepTel = h.CepTel,
                parolaTarihi = h.ParolaTarihi, sonGiris = h.SonGiris,
                sonGirisIp = h.SonGirisIp, hataliGiris = h.HataliGiris,
                totpAktif = h.TotpAktif,
                anaRol = h.AnaRol,
                // Ek roller (665): tek metin degil LISTE gider - istemci
                //   rozet cizecek, virgul ayirmakla ugrasmasin.
                ekRoller = h.EkRoller.Length == 0
                    ? Array.Empty<string>()
                    : h.EkRoller.Split(", ", StringSplitOptions.RemoveEmptyEntries),
            });
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Subesiz);

        grup.MapPut("/iletisim", async (
            IletisimIstegi istek, KullaniciDeposu depo, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var eposta = (istek?.Eposta ?? "").Trim();
            var cep = (istek?.CepTel ?? "").Trim();
            if (eposta.Length > 120 || cep.Length > 30)
                throw GentegreHatasi.Dogrulama("E-posta ya da telefon çok uzun.");
            if (eposta.Length > 0 && (!eposta.Contains('@') || eposta.Contains(' ')))
                throw GentegreHatasi.Dogrulama("E-posta adresi geçersiz.");
            await depo.IletisimGuncelleAsync(baglam.KullaniciId, eposta, cep, iptal);
            return Results.NoContent();
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Subesiz);

        grup.MapGet("/oturumlar", async (
            OturumDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var liste = await depo.AcikListeAsync(baglam.KullaniciId, iptal);
            var ip = Ip(ctx);
            var istemci = Istemci(ctx);
            return Results.Ok(liste.Select(o => new
            {
                id = o.Id, ip = o.Ip, istemci = o.Istemci,
                olusma = o.OlusmaTarihi, sonKullanim = o.SonKullanim,
                bitis = o.BitisTarihi, sube = o.SubeAdi,
                // "Bu cihaz" isareti IP + tarayici esinden cikarilir: access
                //   token oturum kimligi TASIMAZ (JWT'ye oturum id gomulmedi),
                //   bu yuzden kesin degil - etiket de "bu tarayıcı" der.
                buCihaz = o.Ip == ip && o.Istemci == istemci,
            }));
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Subesiz);

        grup.MapPost("/oturumlar/{oturumId:long}/kapat", async (
            long oturumId, OturumDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Sahiplik kontrolu SQL'in icinde: baskasinin oturum kimligini
            //   yazan istek 0 satir kapatir ve 404 alir.
            var kapanan = await depo.KendiOturumunuKapatAsync(baglam.KullaniciId, oturumId, iptal);
            if (kapanan == 0) return Results.NotFound();
            return Results.Ok(new { kapanan });
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Subesiz);

        grup.MapGet("/giris-gecmisi", async (
            KullaniciDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var liste = await depo.GirisGecmisiAsync(baglam.KullaniciId, 10, iptal);
            return Results.Ok(liste.Select(g => new
            {
                tarih = g.Tarih, basarili = g.Basarili, sebep = g.Sebep,
                ip = g.Ip, istemci = g.Istemci,
            }));
        }).RequireAuthorization()
          .SinirliOturumaAcik(SinirliOturum.Subesiz);
    }

    // Giris/yenileme baglam COZULMEDEN once calisir (henuz kimlik yok) -
    //   IP'yi merkezi cozucuden dogrudan alir.
    private static string Ip(HttpContext ctx) => BaglamCozucu.IpCoz(ctx);

    private static string Istemci(HttpContext ctx)
        => ctx.Request.Headers.UserAgent.ToString();

    /// <summary>
    /// ISKONTO ONAY ESIGI (783): `basvuru.iskonto_onay_esik` ayari. Bu oranin
    /// ustundeki iskonto, yetki tavani ne olursa olsun onayli talepten gelir;
    /// ekran limiti bunu gozeterek daralir. 0 = kural kapali.
    /// </summary>
    private static async Task<decimal> IskontoEsigiAsync(VeriKaynagi veri,
                                                         CancellationToken iptal)
    {
        await using var baglanti = await veri.AcAsync(iptal);
        var m = await AyarDeposu.MetinAsync(baglanti, null,
                                            "basvuru.iskonto_onay_esik", "", iptal);
        return decimal.TryParse(m, System.Globalization.NumberStyles.Any,
                   System.Globalization.CultureInfo.InvariantCulture, out var d) && d > 0
            ? d : 0m;
    }
}

using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.AspNetCore.Authorization;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RADYOLOJİ RAPOR GÖNDERİMİ (1389-1392; mockup Ekranlar/Radyoloji/radyoloji_rapor_hasta_goruntuleme.html):
///   GET/PUT /api/radyoloji/rapor-gonderim/ayar          şube ayarı + zaman kuralları (tek Kaydet)
///   GET     /api/radyoloji/rapor-gonderim/istem/{id}    istemin bağlantıları (karekod, kart "Gönderim" bölümü)
///   POST    /api/radyoloji/rapor-gonderim/{id}/gonder   şimdi gönder / borca rağmen gönder
///   POST    /api/radyoloji/rapor-gonderim/{id}/iptal    gönderimi iptal et (bağlantı da kapanır)
///   GET     /api/acik/rapor/{kod}                       GİRİŞSİZ: hastanın / gönderen doktorun rapor sayfası
///   GET     /api/acik/rapor/{kod}/imzali                GİRİŞSİZ: imzalı asıl belge (.xml)
/// </summary>
public static class RaporGonderimUclari
{
    public sealed record KuralIstegi(short Kapsam, int? KategoriId, int? HizmetId, short ZamanTur, int Saat, int GunDakika, bool Aktif);
    public sealed record AyarIstegi(bool Otomatik, int KritikDakika, bool BorcKontrol, bool HastaSms, bool HastaEposta,
                                    int GecerlilikGun, string? WebKok, KuralIstegi[]? Kurallar, int LabPanikDakika = 0);
    public sealed record GonderIstegi(bool BorcaRagmen);

    private const string AyarYetkisi = "radyoloji.rapor_gonderim";
    /// <summary>Aynı ayar ekranının laboratuvar menüsündeki yetkisi (1395) - ikisinden biri yeter.</summary>
    private const string LabAyarYetkisi = "lab.rapor_gonderim";

    private static bool AyarYetkiVar(IstekBaglami baglam, Islem islem)
        => baglam.Yetkiler.Var(AyarYetkisi, islem) || baglam.Yetkiler.Var(LabAyarYetkisi, islem);
    private static void AyarYetkiIste(IstekBaglami baglam, Islem islem)
        => baglam.YetkiIste(baglam.Yetkiler.Var(LabAyarYetkisi, islem) ? LabAyarYetkisi : AyarYetkisi, islem);

    public static void RaporGonderimUclariniEkle(this WebApplication uygulama)
    {
        var grup = uygulama.MapGroup("/api/radyoloji/rapor-gonderim").WithTags("Radyoloji").RequireAuthorization();

        // ------------------------------------------------------------------------------------------------ ayar --
        grup.MapGet("/ayar", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            AyarYetkiIste(baglam, Islem.Gor);
            var sube = baglam.SubeId ?? throw GentegreHatasi.IsKurali("Önce bir şube seçin.");
            await using var b = await veri.AcAsync(iptal);
            var ayar = await b.TekAsync("""
                select otomatik, kritik_dakika, borc_kontrol, hasta_sms, hasta_eposta, gecerlilik_gun, web_kok, lab_panik_dakika
                  from public.radyoloji_rapor_gonderim_ayar where sube_id = @p0
                """, null, [sube], o => new
                {
                    otomatik = o.GetInt16(0) == 1, kritikDakika = o.GetInt32(1), borcKontrol = o.GetInt16(2) == 1,
                    hastaSms = o.GetInt16(3) == 1, hastaEposta = o.GetInt16(4) == 1, gecerlilikGun = o.GetInt32(5),
                    webKok = o.GetString(6), labPanikDakika = o.GetInt32(7),
                }, iptal) ?? new { otomatik = false, kritikDakika = 0, borcKontrol = true, hastaSms = true, hastaEposta = false,
                                   gecerlilikGun = 30, webKok = "", labPanikDakika = 0 };
            var kurallar = await b.ListeAsync("""
                select k.id, k.kapsam, k.kategori_id, k.hizmet_id, k.zaman_tur, k.saat, k.gun_dakika, k.aktif,
                       coalesce(kt.ad, ''), coalesce(hz.kod, ''), coalesce(hz.ad, '')
                  from public.radyoloji_rapor_gonderim_kural k
                  left join public.kategori kt on kt.id = k.kategori_id
                  left join public.hizmet hz on hz.id = k.hizmet_id
                 where k.sube_id = @p0
                 order by k.kapsam, coalesce(kt.ad, hz.ad, ''), k.id
                """, null, [sube], o => new
                {
                    id = o.GetInt32(0), kapsam = o.GetInt16(1), kategoriId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                    hizmetId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), zamanTur = o.GetInt16(4), saat = o.GetInt32(5),
                    gunDakika = o.GetInt32(6), aktif = o.GetInt16(7) == 1, kategoriAd = o.GetString(8),
                    hizmetKod = o.GetString(9), hizmetAd = o.GetString(10),
                }, iptal);
            return Results.Ok(new { ayar, kurallar, degistirebilir = AyarYetkiVar(baglam, Islem.Degistir) });
        });

        grup.MapPut("/ayar", async (AyarIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
                                    HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            AyarYetkiIste(baglam, Islem.Degistir);
            var sube = baglam.SubeId ?? throw GentegreHatasi.IsKurali("Önce bir şube seçin.");
            if (istek.KritikDakika is < 0 or > 1440)
                throw GentegreHatasi.Dogrulama("Kritik bulgu süresi 0 - 1440 dakika olmalı.", new AlanHatasi("kritikDakika", "Geçersiz."));
            if (istek.LabPanikDakika is < 0 or > 1440)
                throw GentegreHatasi.Dogrulama("Panik değer süresi 0 - 1440 dakika olmalı.", new AlanHatasi("labPanikDakika", "Geçersiz."));
            if (istek.GecerlilikGun is < 1 or > 3650)
                throw GentegreHatasi.Dogrulama("Bağlantı geçerliliği 1 - 3650 gün olmalı.", new AlanHatasi("gecerlilikGun", "Geçersiz."));
            var kok = (istek.WebKok ?? "").Trim().TrimEnd('/');
            if (kok.Length > 0 && !(Uri.TryCreate(kok, UriKind.Absolute, out var u) && u.Scheme is "http" or "https"))
                throw GentegreHatasi.Dogrulama("Bağlantı adresi http(s):// ile başlamalı.", new AlanHatasi("webKok", "Geçersiz."));

            var kurallar = istek.Kurallar ?? [];
            foreach (var k in kurallar)
            {
                var uygun = k.Kapsam switch
                {
                    RaporGonderimKurali.KapsamTumu => true,
                    RaporGonderimKurali.KapsamKategori => k.KategoriId is > 0,
                    RaporGonderimKurali.KapsamKod => k.HizmetId is > 0,
                    _ => false,
                };
                if (!uygun) throw GentegreHatasi.Dogrulama("Kural satırında kategori / tetkik seçilmeli.", new AlanHatasi("kurallar", "Eksik."));
                if (k.ZamanTur is < 0 or > 2 || k.Saat is < 0 or > 720 || k.GunDakika is < 0 or > 1439)
                    throw GentegreHatasi.Dogrulama("Kural zamanı geçersiz.", new AlanHatasi("kurallar", "Geçersiz."));
            }
            // Aynı kod / kategori iki kez girilemez; "Tümü" tek satır.
            if (kurallar.Count(k => k.Kapsam == RaporGonderimKurali.KapsamTumu) > 1)
                throw GentegreHatasi.Dogrulama("\"Tümü\" kuralı tek satır olmalı.", new AlanHatasi("kurallar", "Yinelenen."));
            if (kurallar.Where(k => k.Kapsam == RaporGonderimKurali.KapsamKategori).GroupBy(k => k.KategoriId).Any(g => g.Count() > 1)
                || kurallar.Where(k => k.Kapsam == RaporGonderimKurali.KapsamKod).GroupBy(k => k.HizmetId).Any(g => g.Count() > 1))
                throw GentegreHatasi.Dogrulama("Aynı kategori / tetkik iki kez girilemez.", new AlanHatasi("kurallar", "Yinelenen."));

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                insert into public.radyoloji_rapor_gonderim_ayar
                       (sube_id, otomatik, kritik_dakika, borc_kontrol, hasta_sms, hasta_eposta, gecerlilik_gun, web_kok, degistiren,
                        lab_panik_dakika)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
                on conflict (sube_id) do update
                   set otomatik = excluded.otomatik, kritik_dakika = excluded.kritik_dakika, borc_kontrol = excluded.borc_kontrol,
                       lab_panik_dakika = excluded.lab_panik_dakika,
                       hasta_sms = excluded.hasta_sms, hasta_eposta = excluded.hasta_eposta, gecerlilik_gun = excluded.gecerlilik_gun,
                       web_kok = excluded.web_kok, degistiren = excluded.degistiren, degistirme_tarihi = now()
                """, tx, [sube, (short)(istek.Otomatik ? 1 : 0), istek.KritikDakika, (short)(istek.BorcKontrol ? 1 : 0),
                          (short)(istek.HastaSms ? 1 : 0), (short)(istek.HastaEposta ? 1 : 0), istek.GecerlilikGun, kok,
                          baglam.KullaniciId, istek.LabPanikDakika], iptal);
            await b.CalistirAsync("delete from public.radyoloji_rapor_gonderim_kural where sube_id = @p0", tx, [sube], iptal);
            foreach (var k in kurallar)
                await b.CalistirAsync("""
                    insert into public.radyoloji_rapor_gonderim_kural
                           (sube_id, kapsam, kategori_id, hizmet_id, zaman_tur, saat, gun_dakika, aktif, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
                    """, tx, [sube, k.Kapsam, k.Kapsam == RaporGonderimKurali.KapsamKategori ? k.KategoriId : null,
                              k.Kapsam == RaporGonderimKurali.KapsamKod ? k.HizmetId : null, k.ZamanTur, k.Saat, k.GunDakika,
                              (short)(k.Aktif ? 1 : 0), baglam.KullaniciId], iptal);
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloAyar, sube, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["ayar"] = "radyoloji rapor gönderimi", ["otomatik"] = istek.Otomatik ? "1" : "0",
                    ["kritikDakika"] = istek.KritikDakika.ToString(System.Globalization.CultureInfo.InvariantCulture),
                    ["borcKontrol"] = istek.BorcKontrol ? "1" : "0",
                    ["kuralSayisi"] = kurallar.Length.ToString(System.Globalization.CultureInfo.InvariantCulture),
                }, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });

        // --------------------------------------------------------------------------------------- istemin bağlantıları --
        grup.MapGet("/istem/{istemId:int}", async (int istemId, BaglamCozucu cozucu, KayitErisimi erisim, VeriKaynagi veri,
                                                   HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await erisim.IsteAsync(baglam, "radyoloji", istemId, "İstem bulunamadı.", iptal);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select g.id, g.rapor_id, g.alici_tur, g.kod, g.kanal, g.durum, g.planlanan, g.gonderim, g.ilk_acilma,
                       g.acilma_sayisi, g.kural, g.hata, g.son_gecerli, g.web_kok, g.borca_ragmen,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), g.sms_alici, g.eposta_alici
                  from public.radyoloji_rapor_gonderim g
                  join public.radyoloji_rapor r on r.id = g.rapor_id and coalesce(r.revize, 0) = 0
                  left join public.taraf t on t.id = g.taraf_id
                 where g.istem_id = @p0
                 order by g.rapor_id desc, g.alici_tur
                """, null, [istemId], o => new
                {
                    id = o.GetInt32(0), raporId = o.GetInt32(1), aliciTur = o.GetInt16(2), kod = o.GetString(3),
                    kanal = o.GetInt16(4), durum = o.GetInt16(5),
                    planlanan = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                    gonderim = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                    ilkAcilma = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8),
                    acilmaSayisi = o.GetInt32(9), kural = o.GetString(10), hata = o.GetString(11),
                    sonGecerli = o.GetDateTime(12), webKok = o.GetString(13), borcaRagmen = o.GetInt16(14) == 1,
                    alici = o.GetString(15), sms = o.GetString(16), eposta = o.GetString(17),
                }, iptal);
            var belgeId = await b.TekDegerAsync<int?>("select belge_id from public.radyoloji_istem where id = @p0", null, [istemId], iptal);
            return Results.Ok(new
            {
                satirlar, borc = await RaporGonderimi.BorcAsync(b, null, belgeId, iptal),
                gonderebilir = baglam.Yetkiler.AksiyonVar("rad.rapor_gonder"),
                borcaRagmenGonderebilir = baglam.Yetkiler.AksiyonVar("rad.rapor_borca_ragmen"),
            });
        });

        // ------------------------------------------------------------------------------------------ gönder / iptal --
        grup.MapPost("/{id:int}/gonder", async (int id, GonderIstegi? istek, BaglamCozucu cozucu, KayitErisimi erisim,
                                                VeriKaynagi veri, RaporGonderimi servis, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_gonder");
            var borcaRagmen = istek?.BorcaRagmen == true;
            if (borcaRagmen) baglam.AksiyonIste("rad.rapor_borca_ragmen");
            await KapsamIsteAsync(veri, erisim, baglam, id, iptal);
            var durum = await servis.SimdiGonderAsync(id, borcaRagmen, baglam.KullaniciId, iptal);
            return Results.Ok(new { durum });
        });

        grup.MapPost("/{id:int}/iptal", async (int id, BaglamCozucu cozucu, KayitErisimi erisim, VeriKaynagi veri,
                                               HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_gonder");
            await KapsamIsteAsync(veri, erisim, baglam, id, iptal);
            await using var b = await veri.AcAsync(iptal);
            // Yalnız BEKLEYEN gönderim iptal edilir (planlı / borç bekleyen): satır "hazır"a döner - bağlantı (basılı
            //   karekod) yaşamaya devam eder, otomatik gönderim durur.
            var n = await b.CalistirAsync("""
                update public.radyoloji_rapor_gonderim
                   set durum = 0, planlanan = null, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum in (1, 2)
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Bekleyen gönderim yok (gönderilmiş ya da zaten iptal).");
            return Results.Ok(new { tamam = true });
        });

        // ------------------------------------------------------------------------------- GİRİŞSİZ rapor sayfası --
        var acik = uygulama.MapGroup("/api/acik/rapor").WithTags("Radyoloji (açık)").AllowAnonymous();

        acik.MapGet("/{kod}", [AllowAnonymous] async (string kod, RaporGonderimi servis, VeriKaynagi veri, DokumanDeposu dokuman,
                                                     CancellationToken iptal) =>
        {
            var a = await servis.AcAsync(kod, iptal);
            if (a is null) return Results.NotFound(new { durum = "yok" });
            await using var b = await veri.AcAsync(iptal);
            // Kurum kimliği her durumda (borç / süre ekranında telefon gösterilir).
            var kurum = await b.TekAsync("""
                select a.unvan, a.adres, a.ilce, a.il, a.telefon, a.logo_dokuman_id as "logoDokumanId"
                  from public.v_sube_antet a where a.sube_id = @p0
                """, null, [a.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            if (a.Durum != "ok")
            {
                // Rapor GÖSTERİLMEZ: yalnız tetkik adı ve tarih (bulgu / sonuç / borç tutarı yok).
                var ozet = a.Kaynak == RaporGonderimi.KaynakLab
                    ? await b.TekAsync("""
                        select @p1::text as tetkik, be.belge_tarihi as "cekimTarihi" from public.belge be where be.id = @p0
                        """, null, [a.BelgeId, RaporGonderimi.LabBolumAdi(a.LabBolum) + " laboratuvar sonuçları"], OkuyucuGenisletmeleri.Sozluk, iptal)
                    : await b.TekAsync("""
                    select coalesce(hz.ad, '') as tetkik, i.cekim_tarihi as "cekimTarihi"
                      from public.radyoloji_rapor r
                      join public.radyoloji_istem i on i.id = r.istem_id
                      left join public.hizmet hz on hz.id = i.hizmet_id where r.id = @p0
                    """, null, [a.RaporId], OkuyucuGenisletmeleri.Sozluk, iptal);
                return Results.Ok(new { durum = a.Durum, kurum, ozet, sonGecerli = a.SonGecerli });
            }

            // LABORATUVAR (1394): bölümün onaylı sonuçları - Bakanlık Tetkik Sonuç Raporu alanlarıyla.
            if (a.Kaynak == RaporGonderimi.KaynakLab)
                return Results.Ok(new
                {
                    durum = "ok", tur = "lab", aliciTur = a.AliciTur, sonGecerli = a.SonGecerli, kurum,
                    lab = await RaporGonderimi.LabRaporVerisiAsync(b, a.BelgeId, a.LabBolum, a.AliciTur == RaporGonderimi.AliciHekim, iptal),
                });

            var c = await RadyolojiUclari.CiktiVerisiAsync(b, a.RaporId, iptal);
            c.Rapor["hastaTc"] = "";                 // kimlik no açık sayfaya çıkmaz
            var imza = await b.TekAsync("""
                select r.imza_zamani, r.imza_dokuman_id, coalesce(r.imza_ozet, ''),
                       coalesce(public.fn_taraf_ad(im.unvan, im.ad, im.soyad)::varchar(120), ''),
                       coalesce(tp.brans::text, ''), coalesce(tp.tescil_no, '')
                  from public.radyoloji_rapor r
                  left join public.taraf im on im.id = coalesce(r.imzalayan_id, r.onaylayan_id)
                  left join public.taraf_personel tp on tp.id = im.id
                 where r.id = @p0
                """, null, [a.RaporId], o => new
                {
                    Zaman = o.IsDBNull(0) ? (DateTime?)null : o.GetDateTime(0), DokumanId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    Ozet = o.GetString(2), Hekim = o.GetString(3), Brans = o.GetString(4), Tescil = o.GetString(5),
                }, iptal);
            object imzaYaniti;
            if (imza?.DokumanId is { } did && await dokuman.IcerikAsync(did, iptal) is { } belge)
            {
                var bilgi = RaporGonderimi.ImzaBilgisiOku(belge.Veri);
                imzaYaniti = new
                {
                    imzali = true, gecerli = bilgi.Gecerli, hata = bilgi.Gecerli ? "" : bilgi.Hata, hekim = imza.Hekim,
                    tescil = imza.Tescil, zaman = imza.Zaman, sahip = bilgi.Sahip, veren = bilgi.Veren,
                    gecerlilikBas = bilgi.GecerlilikBas, gecerlilikBit = bilgi.GecerlilikBit, seriNo = bilgi.SeriNo, ozet = imza.Ozet,
                };
                // İMZA GEÇERSİZ (belge imzadan sonra değişmiş): rapor gösterilmez.
                if (!bilgi.Gecerli) return Results.Ok(new { durum = "gecersiz", kurum, imza = imzaYaniti, sonGecerli = a.SonGecerli });
            }
            else
                imzaYaniti = new { imzali = false, gecerli = false, hata = "", hekim = imza?.Hekim ?? "", tescil = imza?.Tescil ?? "",
                                   zaman = (DateTime?)null, sahip = "", veren = "", gecerlilikBas = (DateTime?)null,
                                   gecerlilikBit = (DateTime?)null, seriNo = "", ozet = "" };

            return Results.Ok(new
            {
                durum = "ok", aliciTur = a.AliciTur, sonGecerli = a.SonGecerli, kurum, imza = imzaYaniti,
                rapor = c.Rapor, bolumler = c.Bolumler, alanlar = c.Alanlar, ekler = c.Ekler, tipografi = c.Tipografi,
            });
        });

        acik.MapGet("/{kod}/imzali", [AllowAnonymous] async (string kod, RaporGonderimi servis, VeriKaynagi veri,
                                                            DokumanDeposu dokuman, CancellationToken iptal) =>
        {
            var a = await servis.AcAsync(kod, iptal);
            if (a is null || a.Durum != "ok") return Results.NotFound();
            var did = await veri.TekDegerAsync<int?>("select imza_dokuman_id from public.radyoloji_rapor where id = @p0",
                                                     new object?[] { a.RaporId }, iptal);
            if (did is not > 0 || await dokuman.IcerikAsync(did.Value, iptal) is not { } belge) return Results.NotFound();
            return Results.File(belge.Veri, "application/xml", $"rapor-{a.RaporId}-imzali.xml");
        });
    }

    /// <summary>islem_log tablo kodu: şube ayarı değişikliği (radyoloji_rapor_gonderim_ayar).</summary>
    private const int LogTabloAyar = 1389;

    /// <summary>Gönderim satırının kayıt kapsamı: radyolojide istem (radyoloji listesi), laboratuvarda başvuru (belge).</summary>
    private static async Task KapsamIsteAsync(VeriKaynagi veri, KayitErisimi erisim, IstekBaglami baglam, int gonderimId, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var g = await b.TekAsync("select kaynak, coalesce(istem_id, 0), coalesce(belge_id, 0) from public.radyoloji_rapor_gonderim where id = @p0",
            null, [gonderimId], o => (Kaynak: o.GetInt16(0), Istem: o.GetInt32(1), Belge: o.GetInt32(2)).ToTuple(), iptal)
            ?? throw GentegreHatasi.Bulunamadi("Gönderim kaydı bulunamadı.");
        if (g.Item1 == RaporGonderimi.KaynakLab)
        {
            baglam.YetkiIste("lab", Islem.Gor);
            await erisim.IsteAsync(baglam, "belge", g.Item3, "Gönderim kaydı bulunamadı.", iptal);
        }
        else await erisim.IsteAsync(baglam, "radyoloji", g.Item2, "Gönderim kaydı bulunamadı.", iptal);
    }
}

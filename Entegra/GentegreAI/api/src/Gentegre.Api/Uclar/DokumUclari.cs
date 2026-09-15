using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DÖKÜMLER & İSTATİSTİK (686) — mockup Ekranlar/Ayarlar/dokum_tasarimcisi.html,
/// plan dokuman/10_DOKUM_ISTATISTIK_PLANI.md.
///
/// İki yetki katmanı: ekran yetkisi `dokum` (Gor çalıştırır, Ekle/Degistir
/// tasarlar) + KAYNAĞIN kendi yetkisi (belge, kasa_islem…). Döküm paylaşımı
/// veri yetkisi VERMEZ: kaynağı göremeyen kişi dökümü listede görür ama
/// çalıştıramaz; alan yetkisi olmayan kolon tanımdan düşer.
/// </summary>
public static class DokumUclari
{
    public sealed record KaynakMeta(string Ad, string YetkiKodu, string Baslik,
                                    IReadOnlyList<KolonBoyutMeta> Kolonlar);
    public sealed record KolonBoyutMeta(string Ad, string Baslik, string Tip, bool Filtrelenebilir,
                                        bool Siralanabilir, bool Gruplanabilir, bool Olculebilir,
                                        IReadOnlyDictionary<string, string>? Kodlar);

    public static void DokumUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dokum").WithTags("Döküm").RequireAuthorization();

        // Tasarımcının kataloğu: kullanıcının GÖREBİLDİĞİ kaynaklar ve her birinin
        //   görünür kolonları (+ boyut/ölçü olabilirlik). Fonksiyon ve kesme
        //   adları da buradan - istemcide liste yok.
        grup.MapGet("/kaynaklar", async (
            BaglamCozucu cozucu, KurumProfilDeposu profil, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokum", Islem.Gor);
            var urunModu = await profil.UrunModuAsync(baglam.SubeId ?? 0, iptal);
            var kaynaklar = KaynakKatalogu.Tumu
                .Where(k => baglam.Yetkiler.Var(k.YetkiKodu, Islem.Gor))
                .Select(k => new KaynakMeta(k.Ad, k.YetkiKodu, KaynakBasligi(k),
                    GorunurKolonlar(k, baglam, urunModu)
                        .Select(c => new KolonBoyutMeta(c.Ad, c.Baslik, c.Tip, c.Filtrelenebilir,
                            c.Siralanabilir, OlcuKatalogu.Gruplanabilir(c), OlcuKatalogu.Olculebilir(c), c.Kodlar))
                        .ToList()))
                .OrderBy(k => k.Baslik)
                .ToList();
            return Results.Ok(new
            {
                kaynaklar,
                fnler = OlcuKatalogu.FnAdlari,
                kesmeler = OlcuKatalogu.KesmeAdlari,
                kurallar = ParametreCozucu.Kurallar,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // Dökümlerim: sahip + rol paylaşımı + kurum geneli; kaynağı görülemeyen
        //   döküm listede kalır ama `calistirilabilir=false`.
        grup.MapGet("/", async (
            string? kaynak, BaglamCozucu cozucu, DokumDeposu depo, KurumProfilDeposu profil,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokum", Islem.Gor);
            var tam = baglam.Yetkiler.Var("dokum", Islem.Degistir);
            var liste = await depo.ListeAsync(baglam.KullaniciId, baglam.RolId, tam, kaynak, iptal);
            // STANDART DOKUMLER KURUM PROFILINE GORE SUZULUR (688): urun modu +
            //   acik moduller - menuyle ayni kural. Uretilmez, suzulur: modul
            //   kapaninca dokum kendiliginden kaybolur, tablo degismez.
            var urunModu = await profil.UrunModuAsync(baglam.SubeId ?? 0, iptal);
            var acikModuller = await profil.AcikModullerAsync(baglam.SubeId ?? 0, iptal);
            liste = liste.Where(d => !d.Sistem
                || (UrunModlari.Uyar(d.UrunModu, urunModu)
                    && (d.Modul.Length == 0 || acikModuller.Contains(d.Modul)))).ToList();
            return Results.Ok(liste.Select(d => new
            {
                d.Id, d.Kod, d.Ad, d.Aciklama, d.Kaynak, d.Tanim, d.Surum, d.SahipId, d.Sahip,
                d.Gorunurluk, d.Roller, d.SonCalisma, d.CalismaSayisi, d.Duzenlenebilir,
                d.Sistem, d.UrunModu, d.Modul,
                calistirilabilir = KaynakKatalogu.Bul(d.Kaynak) is { } k && baglam.Yetkiler.Var(k.YetkiKodu, Islem.Gor),
            }));
        });

        grup.MapGet("/{id:int}", async (
            int id, BaglamCozucu cozucu, DokumDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokum", Islem.Gor);
            var d = await GorulenAsync(depo, id, baglam, iptal);
            var surumler = await depo.SurumlerAsync(id, iptal);
            return Results.Ok(new { dokum = d, surumler = surumler.Select(s => new { s.Surum, s.Tarih, s.Kullanici }) });
        });

        // Kaydet (yeni ya da güncelle). Tanım doğrulayıcıdan geçer: yetkisiz alan
        //   ya da bilinmeyen fn 400 ile düşer - AI taslağı da aynı kapıdan girer.
        grup.MapPost("/", async (
            DokumKaydi kayit, BaglamCozucu cozucu, DokumDeposu depo, KurumProfilDeposu profil,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokum", kayit.Id > 0 ? Islem.Degistir : Islem.Ekle);
            if (kayit.Id > 0)
            {
                var eski = await GorulenAsync(depo, kayit.Id, baglam, iptal);
                if (eski.Sistem) throw GentegreHatasi.Yasak("Standart döküm değiştirilmez - kopyalayıp kendi adınıza kaydedin.");
                if (!eski.Duzenlenebilir) throw GentegreHatasi.Yasak("Bu dökümü yalnız sahibi düzenleyebilir.");
            }
            if (string.IsNullOrWhiteSpace(kayit.Ad))
                throw GentegreHatasi.Dogrulama("Döküm adı zorunlu.", new AlanHatasi("ad", "Zorunlu."));
            var kaynak = KaynakBul(kayit.Tanim.Kaynak);
            baglam.YetkiIste(kaynak.YetkiKodu, Islem.Gor);
            kayit.Kaynak = kaynak.Ad;
            DokumDogrulayici.Dogrula(kayit.Tanim,
                GorunurKolonlar(kaynak, baglam, await profil.UrunModuAsync(baglam.SubeId ?? 0, iptal)));
            // Kurum geneli paylaşımı yalnız Degistir yetkisi olan (yönetici) açar.
            if (kayit.Gorunurluk == 2 && !baglam.Yetkiler.Var("dokum", Islem.Degistir))
                throw GentegreHatasi.Yasak("Kurum geneli paylaşım için yönetici yetkisi gerekir.");
            var id = await depo.KaydetAsync(kayit, baglam.Yazma, iptal);
            return Results.Ok(new { id, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapDelete("/{id:int}", async (
            int id, BaglamCozucu cozucu, DokumDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokum", Islem.Sil);
            var d = await GorulenAsync(depo, id, baglam, iptal);
            if (d.Sistem) throw GentegreHatasi.Yasak("Standart döküm silinmez; kurum profilinden modül kapatılınca gizlenir.");
            if (!d.Duzenlenebilir) throw GentegreHatasi.Yasak("Bu dökümü yalnız sahibi silebilir.");
            await depo.PasifeAlAsync(id, baglam.Yazma, iptal);
            return Results.Ok(new { silindi = true });
        });

        // ÇALIŞTIR: kayıtlı döküm (id) ya da önizleme (tanım istekte, id=0).
        //   Parametreler ağaca yazılır, tarih kuralı çözülür; liste ise
        //   ListeDeposu, özet ise SorguUretici.Ozet.
        grup.MapPost("/{id:int}/calistir", async (
            int id, DokumCalistirIstegi istek, BaglamCozucu cozucu, DokumDeposu depo,
            KurumProfilDeposu profil, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokum", Islem.Gor);

            DokumTanimi tanim;
            if (id > 0) tanim = (await GorulenAsync(depo, id, baglam, iptal)).Tanim;
            else tanim = istek.Tanim ?? throw GentegreHatasi.Dogrulama("Önizleme için tanım gerekli.");

            var kaynak = KaynakBul(tanim.Kaynak);
            baglam.YetkiIste(kaynak.YetkiKodu, Islem.Gor);
            var kolonlar = GorunurKolonlar(kaynak, baglam, await profil.UrunModuAsync(baglam.SubeId ?? 0, iptal));
            DokumDogrulayici.Dogrula(tanim, kolonlar);

            var filtre = ParametreCozucu.Uygula(tanim.Filtre, tanim,
                istek.Parametreler is null ? null : new Dictionary<string, object?>(istek.Parametreler, StringComparer.Ordinal),
                DateTime.Now);

            if (id > 0) await depo.CalistirildiAsync(id, iptal);

            if (tanim.Cikti == "ozet")
                return Results.Ok(await depo.OzetCalistirAsync(kaynak, tanim, filtre,
                    baglam.SubeId, baglam.Kapsam, baglam.IzlemeNo, iptal));

            var boyut = Math.Clamp(istek.Boyut, 1, ListeIstegi.EnBuyukBoyut);
            return Results.Ok(await depo.ListeCalistirAsync(kaynak, tanim, filtre, kolonlar,
                Math.Max(1, istek.Sayfa), boyut, baglam.SubeId, baglam.Kapsam, baglam.IzlemeNo,
                baglam.KullaniciId, iptal));
        });

        // Baskı anteti: aktif şubenin kimliği (logo yok - sube.logo gelince).
        grup.MapGet("/antet", async (
            BaglamCozucu cozucu, DokumDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokum", Islem.Gor);
            return Results.Ok(new { kurum = await depo.AntetAsync(baglam.SubeId, iptal),
                                    kullanici = baglam.KullaniciId, izlemeNo = baglam.IzlemeNo });
        });
    }

    private static async Task<DokumKaydi> GorulenAsync(DokumDeposu depo, int id, IstekBaglami baglam,
                                                        CancellationToken iptal)
    {
        var tam = baglam.Yetkiler.Var("dokum", Islem.Degistir);
        var d = await depo.BulAsync(id, baglam.KullaniciId, tam, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Döküm bulunamadı.");
        var gorur = tam || d.SahipId == baglam.KullaniciId || d.Gorunurluk == 2
                    || (d.Gorunurluk == 1 && d.Roller.Contains(baglam.RolId));
        if (!gorur) throw GentegreHatasi.Yasak("Bu döküm sizinle paylaşılmamış.");
        return d;
    }

    private static KaynakTanimi KaynakBul(string ad)
        => KaynakKatalogu.Bul(ad ?? "")
           ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen kaynak: {ad}", new AlanHatasi("kaynak", "Katalogda yok."));

    /// <summary>ListeUclari.GorunurKolonlar ile aynı kural: alan yetkisi + ürün modu.</summary>
    private static List<KolonTanimi> GorunurKolonlar(KaynakTanimi tanim, IstekBaglami baglam, int urunModu)
        => tanim.Kolonlar
                .Where(k => UrunModlari.Uyar(k.UrunModu, urunModu)
                            && baglam.Yetkiler.AlanOkunur(tanim.Ad, k.AlanAdi))
                .ToList();

    /// <summary>Kaynağın okunur adı: katalogda başlık yok, yetki adından türetilir.</summary>
    private static string KaynakBasligi(KaynakTanimi k)
        => k.Ad.Replace('-', ' ') switch
        {
            var s when s.Length == 0 => k.Ad,
            var s => char.ToUpperInvariant(s[0]) + s[1..],
        };
}

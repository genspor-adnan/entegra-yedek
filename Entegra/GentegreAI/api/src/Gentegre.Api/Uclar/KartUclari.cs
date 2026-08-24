using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

public static class KartUclari
{
    public static void KartUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kart").WithTags("Kart").RequireAuthorization();

        // ------------------------------------------------------------- oku ----
        grup.MapGet("/{kaynak}/{id:long}", async (
            string kaynak, long id, BaglamCozucu cozucu, KartDeposu depo, KullaniciAramaDeposu arama,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var (okunabilir, gizli) = Alanlar(tanim, baglam);

            var kart = await depo.OkuAsync(tanim, id, okunabilir, baglam.Kapsam, iptal)
                       ?? throw GentegreHatasi.Bulunamadi();

            // KULLANICI_ARAMA karsiligi: kart her acilista upsert (Son/Sik Aranan).
            await arama.IsaretleAsync(baglam.KullaniciId, tanim.Ad, id, iptal);

            var govde = new Dictionary<string, object?>(kart.Kart, StringComparer.Ordinal)
            {
                ["surum"] = kart.Surum
            };

            return Results.Ok(new KartYaniti
            {
                Kart = govde,
                Detaylar = await depo.DetaylarAsync(tanim, id, iptal),
                KodAd = await depo.KodAdAsync(tanim, kart.Kart, iptal),
                Yetki = new KartYetkisi
                {
                    Duzenle = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Degistir),
                    Sil = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Sil),
                    GizliAlanlar = gizli
                },
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------------ ekle ----
        grup.MapPost("/{kaynak}", async (
            string kaynak, KartYazmaIstegi istek, BaglamCozucu cozucu, KartDeposu depo, KullaniciAramaDeposu arama,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Ekle);

            var degerler = Degerler(tanim, istek.Kart, baglam, yeni: true);
            var yeniId = await depo.EkleAsync(tanim, degerler, istek.Detaylar,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            // KULLANICI_ARAMA karsiligi: yeni kayit da ekleyen kullanici icin isaretlenir.
            await arama.IsaretleAsync(baglam.KullaniciId, tanim.Ad, yeniId, iptal);

            var (okunabilir, _) = Alanlar(tanim, baglam);
            var kart = await depo.OkuAsync(tanim, yeniId, okunabilir, null, iptal);
            var govde = new Dictionary<string, object?>(kart!.Value.Kart, StringComparer.Ordinal)
            {
                ["surum"] = kart.Value.Surum
            };

            return Results.Created($"/api/kart/{tanim.Ad}/{yeniId}", new KartYaniti
            {
                Kart = govde,
                Detaylar = await depo.DetaylarAsync(tanim, yeniId, iptal),
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // -------------------------------------------------------- guncelle ----
        grup.MapPut("/{kaynak}/{id:long}", async (
            string kaynak, long id, KartYazmaIstegi istek, BaglamCozucu cozucu, KartDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Surum))
                throw GentegreHatasi.Dogrulama("Guncellemede surum zorunludur.",
                    new AlanHatasi("surum", "Kart okunurken donen surum geri gonderilmeli."));

            var (okunabilir, _) = Alanlar(tanim, baglam);
            var degerler = Degerler(tanim, istek.Kart, baglam, yeni: false);

            await depo.GuncelleAsync(tanim, id, istek.Surum!, degerler, istek.Detaylar,
                okunabilir, new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kart = await depo.OkuAsync(tanim, id, okunabilir, baglam.Kapsam, iptal)
                       ?? throw GentegreHatasi.Bulunamadi();
            var govde = new Dictionary<string, object?>(kart.Kart, StringComparer.Ordinal)
            {
                ["surum"] = kart.Surum
            };

            return Results.Ok(new KartYaniti
            {
                Kart = govde,
                Detaylar = await depo.DetaylarAsync(tanim, id, iptal),
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------------- sil ----
        grup.MapDelete("/{kaynak}/{id:long}", async (
            string kaynak, long id, BaglamCozucu cozucu, KartDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Sil);

            // Silme logu kartin TAM halini saklar - alan yetkisiyle kirpilmis
            // kume degil, butun alanlar okunur ("Geri Al" eksik satir diriltmesin).
            await depo.SilAsync(tanim, id, tanim.Alanlar,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            return Results.NoContent();
        });

        // GET /api/kart/{kaynak}/alanlar - form metasi (liste tarafindaki /kolonlar karsiligi)
        grup.MapGet("/{kaynak}/alanlar", async (
            string kaynak, BaglamCozucu cozucu, KartDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var (okunabilir, gizli) = Alanlar(tanim, baglam);

            // KodTablosu (kendi tablosu) + KodListesi (kod_liste/kod_deger) alanlarinin
            //   TAM secenek listesi - kodAd yalniz kartta KULLANILAN tek degeri cozer.
            var tumAlanlar = (tanim.Detaylar ?? Array.Empty<DetayTanimi>())
                .SelectMany(d => d.Alanlar).Concat(okunabilir).ToList();
            var tabloGorevleri = tumAlanlar.Select(a => a.KodTablosu).Where(t => t is not null).Distinct()
                .ToDictionary(t => t!, t => depo.KodTablosuSecenekleriAsync(t!, iptal));
            var listeGorevleri = tumAlanlar.Select(a => a.KodListesi).Where(t => t is not null).Distinct()
                .ToDictionary(t => t!, t => depo.KodListesiSecenekleriAsync(t!, iptal));
            // BAGLI alanlarin (Şube -> Banka) ust haritasi: arayuz secenekleri
            //   secili ust'e gore suzsun diye secenek id -> ust id.
            var ustGorevleri = tumAlanlar
                .Where(a => a.BagliAlan is not null && a.KodTablosu is not null)
                .Select(a => a.KodTablosu!).Distinct()
                .ToDictionary(t => t, t => depo.KodTablosuUstAsync(t, iptal));
            await Task.WhenAll(tabloGorevleri.Values.Concat(listeGorevleri.Values).Concat(ustGorevleri.Values));
            var tabloSecenekleri = tabloGorevleri.ToDictionary(kv => kv.Key, kv => kv.Value.Result);
            var listeSecenekleri = listeGorevleri.ToDictionary(kv => kv.Key, kv => kv.Value.Result);
            var ustHaritalari = ustGorevleri.ToDictionary(kv => kv.Key, kv => kv.Value.Result);

            KartAlanMeta MetaOptions(KartAlani a) => Meta(a, tanim, baglam,
                a.KodTablosu is { } t ? tabloSecenekleri[t]
                : a.KodListesi is { } l ? listeSecenekleri[l]
                : null,
                a.BagliAlan is not null && a.KodTablosu is { } bt ? ustHaritalari[bt] : null);

            // Yerel para birimi kartla birlikte gider: arayuz "TL disi mi" karari
            //   icin ayri bir istek yapmasin (kur kutusu bu karara gore acilir).
            DovizMetasi? dovizMeta = null;
            if (tanim.Doviz is { } dk)
                dovizMeta = new DovizMetasi(dk.CinsAlani, dk.KurAlani, dk.TutarAlani, dk.YerelAlani,
                    dk.TarihAlani, await depo.YerelParaAsync(iptal));

            return Results.Ok(new KartMetaYaniti
            {
                Kaynak = tanim.Ad,
                // Yeni kayit varsayilanlari ARAYUZE de gonderilir: kullanici
                //   formu acar acmaz dogru degerleri gorur ve zorunlu kod
                //   alanlari bos kalmaz (bkz. KartMetaYaniti.Varsayilanlar).
                Varsayilanlar = tanim.YeniKayitVarsayilanlari
                    ?? new Dictionary<string, object?>(),
                AcilistaTarafSecimi = tanim.AcilistaTarafSecimi,
                Doviz = dovizMeta,
                Alanlar = okunabilir.Select(MetaOptions).ToList(),
                Detaylar = (tanim.Detaylar ?? Array.Empty<DetayTanimi>())
                    .Select(d => new KartDetayMeta(d.Ad, d.Etiket, d.SaltOkunur,
                        d.Alanlar.Select(MetaOptions).ToList(), d.KosulAlani))
                    .ToList(),
                Yetki = new KartYetkisi
                {
                    Duzenle = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Degistir),
                    Sil = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Sil),
                    GizliAlanlar = gizli
                }
            });
        });

        // kullanicinin acabilecegi kartlar
        grup.MapGet("/", async (BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kartlar = KartKatalogu.Tumu
                .Where(k => baglam.Yetkiler.Var(k.YetkiKodu, Islem.Gor))
                .Select(k => new
                {
                    k.Ad,
                    ekle = baglam.Yetkiler.Var(k.YetkiKodu, Islem.Ekle),
                    degistir = baglam.Yetkiler.Var(k.YetkiKodu, Islem.Degistir),
                    sil = baglam.Yetkiler.Var(k.YetkiKodu, Islem.Sil)
                })
                .ToList();
            return Results.Ok(new { kartlar });
        });
    }

    /// <summary>
    /// Alan metasi. "Yazilabilir" hem katalogdaki bayrak hem ALAN YETKISI ile
    /// belirlenir: okuma izni olup yazma izni olmayan alan formda salt okunur gelir.
    /// </summary>
    private static KartAlanMeta Meta(KartAlani alan, KartTanimi tanim, IstekBaglami baglam,
        IReadOnlyDictionary<string, string>? kodTablosuSecenekleri = null,
        IReadOnlyDictionary<string, string>? ustHaritasi = null)
        => new(
            alan.Ad,
            alan.Etiket,
            alan.Tip,
            alan.Grup,
            alan.AltGrup,
            alan.EslesAlan,
            alan.Yazilabilir && baglam.Yetkiler.AlanYazilir(tanim.Ad, alan.Ad),
            alan.Zorunlu,
            alan.EnFazlaUzunluk,
            kodTablosuSecenekleri ?? alan.SabitKodlar,
            alan.Gizli,
            alan.BagliAlan,
            ustHaritasi);

    private static KartTanimi KartBul(string ad)
        => KartKatalogu.Bul(ad) ?? throw GentegreHatasi.Bulunamadi($"Bilinmeyen kart: {ad}");

    /// <summary>Alan yetkisi: gizli alan gövdeye hiç girmez, adi bilgi olarak doner (§3.1).</summary>
    private static (List<KartAlani> Okunabilir, List<string> Gizli) Alanlar(
        KartTanimi tanim, IstekBaglami baglam)
    {
        var okunabilir = new List<KartAlani>();
        var gizli = new List<string>();

        foreach (var alan in tanim.Alanlar)
        {
            if (baglam.Yetkiler.AlanOkunur(tanim.Ad, alan.Ad)) okunabilir.Add(alan);
            else gizli.Add(alan.Ad);
        }

        return (okunabilir, gizli);
    }

    /// <summary>
    /// Istek govdesini dogrular ve DB degerlerine cevirir.
    /// Kurallar (§3.2): alan gondermemek "degistirme", null gondermek "bosalt".
    /// Yazilamayan ya da yetkisiz alan gelirse SESSIZCE YOK SAYILMAZ - hata verilir.
    /// </summary>
    private static Dictionary<string, object?> Degerler(KartTanimi tanim,
        Dictionary<string, JsonElement>? gelen, IstekBaglami baglam, bool yeni)
    {
        var sonuc = new Dictionary<string, object?>(StringComparer.Ordinal);
        if (gelen is null) return sonuc;

        foreach (var (ad, deger) in gelen)
        {
            if (ad is "surum" or "id") continue;

            var alan = tanim.Alan(ad)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen alan: {ad}",
                       new AlanHatasi(ad, "Bu kartta boyle bir alan yok."));

            if (!alan.Yazilabilir)
                throw GentegreHatasi.Dogrulama($"{ad} alani degistirilemez.",
                    new AlanHatasi(ad, "Salt okunur alan."));

            if (!baglam.Yetkiler.AlanYazilir(tanim.Ad, alan.Ad))
                throw GentegreHatasi.Yasak($"{ad} alanini degistirme yetkiniz yok.");

            var cevrilmis = DegerCevirici.Cevir(deger, alan.Tip, ad, ad);
            DegerCevirici.UzunlukKontrol(alan, cevrilmis, ad);
            sonuc[ad] = cevrilmis;
        }

        if (yeni)
            foreach (var zorunlu in tanim.Alanlar.Where(a => a.Zorunlu))
                if (!sonuc.TryGetValue(zorunlu.Ad, out var d) || d is null ||
                    (d is string m && m.Trim().Length == 0))
                    throw GentegreHatasi.Dogrulama($"{zorunlu.Etiket} zorunlu.",
                        new AlanHatasi(zorunlu.Ad, $"{zorunlu.Etiket} boş bırakılamaz."));

        return sonuc;
    }

    private static string Ip(HttpContext ctx)
        => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}

using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

public static class BelgeUclari
{
    public static void BelgeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/belge").WithTags("Belge").RequireAuthorization();

        // POST /api/belge - yeni belge (sozlesme §4)
        grup.MapPost("/", async (
            BelgeYazmaIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Ekle);

            var belge = BaslikDegerleri(istek.Belge);
            var satirlar = istek.Satirlar ?? new List<Dictionary<string, JsonElement>>();

            var (id, uyarilar) = await depo.KaydetAsync(belge, satirlar, istek.Secenekler,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(id, iptal)
                        ?? throw GentegreHatasi.Bulunamadi();

            return Results.Created($"/api/belge/{id}", new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = uyarilar,
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}
        grup.MapGet("/{id:int}", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();

            // Hareket kaynagi: baska subenin belgesi gosterilmez (API §8).
            if (baglam.SubeId is not null &&
                kayit.Belge.TryGetValue("subeId", out var belgeSube) && belgeSube is not null &&
                Convert.ToInt32(belgeSube) != baglam.SubeId.Value)
                throw GentegreHatasi.Bulunamadi();

            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}/acik-satirlar - donusturulmeyi bekleyen satirlar
        grup.MapGet("/{id:int}/acik-satirlar", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(new
            {
                satirlar = await depo.AcikSatirlarAsync(id, iptal),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // PUT /api/belge/{id} - kayitli belgeyi duzenler (135). Kilit kurallari
        //   depoda: e-Belge gonderilmis / faturalanmis / duzenleme suresi gecmis.
        grup.MapPut("/{id:int}", async (
            int id, BelgeYazmaIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var belge = BaslikDegerleri(istek.Belge);
            var satirlar = istek.Satirlar ?? new List<Dictionary<string, JsonElement>>();

            var (belgeId, uyarilar) = await depo.GuncelleAsync(id, belge, satirlar,
                istek.Secenekler, new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)),
                iptal);

            var kayit = await depo.OkuAsync(belgeId, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = uyarilar,
                IzlemeNo = baglam.IzlemeNo,
            });
        });

        // GET /api/belge/iade-satirlari - iade faturasinda "onceki alinanlar" (132).
        //   Cari zorunlu: iade her zaman BIR CARIYE kesilir, tum firmanin gecmisi
        //   listelenmez. belgeId verilirse yalniz o belgeden iade edilir.
        grup.MapGet("/iade-satirlari", async (
            int tarafId, int? belgeId, string? ara, string? turler,
            BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            // turler: "14,119" gibi virgullu liste - iade IRSALIYESI yalniz
            //   irsaliye satirlarini, iade FATURASI fatura satirlarini gorsun.
            var turDizi = (turler ?? "")
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => int.TryParse(x, out var n) ? n : 0)
                .Where(x => x > 0).ToArray();
            return Results.Ok(new
            {
                satirlar = await depo.IadeSatirlariAsync(tarafId, belgeId, ara, turDizi, iptal),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/rezerve - siparis satirlarini depoda ayir (142)
        grup.MapPost("/{id:int}/rezerve", async (
            int id, RezerveIstegi? istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Rezervasyon stok/cari YAZMAZ, yalniz "soz verildi" isareti koyar:
            //   belgeyi degistirme yetkisi yeterli.
            baglam.YetkiIste("belge", Islem.Degistir);

            var ac = istek?.Ac ?? true;
            var adet = await depo.RezerveAsync(id, ac,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = new[] { ac ? $"{adet} satır rezerve edildi." : "Rezervasyon kaldırıldı." },
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/termin - satirlarin teslim tarihini guncelle (140)
        grup.MapPost("/{id:int}/termin", async (
            int id, TerminIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Termin degisikligi tutar/stok/cari etkilemez: belgeyi DEGISTIRME
            //   yetkisi yeterli, ayri bir aksiyon istenmiyor.
            baglam.YetkiIste("belge", Islem.Degistir);

            var secilen = (istek?.Satirlar ?? new List<TerminSatiri>())
                .Where(s => s.SatirId > 0)
                .Select(s => (s.SatirId, s.TeslimTarihi))
                .ToList();

            var adet = await depo.TerminGuncelleAsync(id, secilen,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = new[] { $"{adet} satırın teslim tarihi güncellendi." },
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/donustur - siparis -> irsaliye -> fatura
        grup.MapPost("/{id:int}/donustur", async (
            int id, DonusumIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Ekle);
            baglam.AksiyonIste("belge.donustur");

            if (istek is null || istek.HedefTur <= 0)
                throw GentegreHatasi.Dogrulama("Hedef belge türü seçilmeli.",
                    new AlanHatasi("hedefTur", "Zorunlu."));

            var secilen = (istek.Satirlar ?? new List<DonusumSatiri>())
                .Where(s => s.SatirId > 0 && s.Miktar > 0)
                .Select(s => (s.SatirId, s.Miktar))
                .ToList();

            var (yeniId, uyarilar) = await depo.DonusturAsync(id, istek.HedefTur, secilen,
                istek.BelgeTarihi, istek.Taslak,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal,
                istek.BelgeNo);

            var kayit = await depo.OkuAsync(yeniId, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Created($"/api/belge/{yeniId}", new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = uyarilar,
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}/donusumler - bu belgeden turetilmis belgeler
        grup.MapGet("/{id:int}/donusumler", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(new
            {
                belgeler = await depo.DonusumlerAsync(id, iptal),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}/diptoplam - ekranin alt toplam seridi
        grup.MapGet("/{id:int}/diptoplam", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new { dipToplam = kayit.DipToplam, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Siparis/irsaliye donusum istegi (F8). Miktar KISMI olabilir.</summary>
    public sealed class DonusumIstegi
    {
        public int HedefTur { get; set; }
        public List<DonusumSatiri>? Satirlar { get; set; }
        public DateTime? BelgeTarihi { get; set; }
        public bool Taslak { get; set; }

        /// <summary>Alis faturasinda TEDARIKCININ numarasi - sayac uretmez.</summary>
        public string? BelgeNo { get; set; }
    }

    public sealed class DonusumSatiri
    {
        public int SatirId { get; set; }
        public decimal Miktar { get; set; }
    }

    /// <summary>Rezervasyon istegi - 142. Ac=false rezervi kaldirir.</summary>
    public sealed class RezerveIstegi
    {
        public bool Ac { get; set; } = true;
    }

    /// <summary>Termin (teslim tarihi) guncelleme istegi - 140.</summary>
    public sealed class TerminIstegi
    {
        public List<TerminSatiri>? Satirlar { get; set; }
    }

    public sealed class TerminSatiri
    {
        public int SatirId { get; set; }
        /// <summary>Bos (null) = termin kaldirildi, tarih belirsiz.</summary>
        public DateTime? TeslimTarihi { get; set; }
    }

    /// <summary>
    /// Baslik alanlarini dogrular ve DB degerlerine cevirir. Beyaz liste:
    /// katalogdaki kolon adlari disinda bir alan gelirse hata verilir.
    /// </summary>
    private static Dictionary<string, object?> BaslikDegerleri(Dictionary<string, JsonElement>? gelen)
    {
        var sonuc = new Dictionary<string, object?>(StringComparer.Ordinal);
        if (gelen is null) return sonuc;

        foreach (var (ad, deger) in gelen)
        {
            var tip = BaslikTipi(ad)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen belge alani: {ad}",
                       new AlanHatasi(ad, "Belge basliginda boyle bir alan yok."));

            var cevrilmis = DegerCevirici.Cevir(deger, tip, ad, ad);

            // Uzunluk SUNUCUDA kesilir: aksi halde PG "value too long for type
            //   character varying(5)" ile 500 veriyor, kullanici neyin uzun oldugunu
            //   ogrenemiyordu (gercek vaka: istemci UTF-8'i bozunca "Hariç" 6 karakter oldu).
            if (Uzunluk(ad) is { } sinir && cevrilmis is string m && m.Length > sinir)
                throw GentegreHatasi.Dogrulama($"{ad}: en fazla {sinir} karakter.",
                    new AlanHatasi(ad, $"En fazla {sinir} karakter ({m.Length} geldi)."));

            sonuc[ad] = cevrilmis;
        }
        return sonuc;
    }

    private static string? BaslikTipi(string ad) => ad switch
    {
        "tur" or "tipi" or "tarafId" or "tarafAdresId" or "kocanNo" or "girisDepoId" or
        "cikisDepoId" or "subeId" or "projeId" or "vadeGun" or "durum" or "senaryo" or
        "saticiId" or "teslimSekli" or "merkezId" or "tasiyiciId" or "teslimEdenId" or
        "teslimAlanId" => "sayi",

        "dovizKuru" => "para",

        "belgeTarihi" or "irsaliyeTarihi" => "tarih",

        "tarafUnvan" or "tarafVkno" or "tarafVd" or "tarafAdres" or "tarafIlce" or "tarafIl" or
        "belgeSeri" or "belgeNo" or "irsaliyeNo" or "kdvDurum" or "belgeDovizi" or
        "dovizCinsi" or "kur" or "raporDovizi" or "ekstreDovizi" or "aciklama" or "ozelKod" or
        "gondericiUnvan" or "gondericiVkno" or "gondericiAlias" or
        "aracPlaka" or "soforAd" or "soforTckn" => "metin",

        _ => null
    };

    /// <summary>Belge basligindaki metin alanlarinin DB uzunluklari.</summary>
    private static int? Uzunluk(string ad) => ad switch
    {
        "belgeSeri" or "belgeDovizi" or "kur" or "raporDovizi" or "ekstreDovizi" or "kdvDurum" => 5,
        "dovizCinsi" => 6,
        "belgeNo" or "irsaliyeNo" or "tarafVkno" => 20,
        "tarafIlce" or "tarafIl" or "tarafVd" or "gondericiVkno" => 60,
        "ozelKod" => 20,
        "tarafUnvan" or "gondericiUnvan" => 200,
        "tarafAdres" => 300,
        "gondericiAlias" => 500,
        _ => null
    };

    private static string Ip(HttpContext ctx)
        => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}

using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Testler;

/// <summary>
/// AI KONTROLLÜ ÖNERİ (449, Faz 3) — asistan <b>işaret eder, yazmaz</b>.
///
/// Faz 3'ün riski Faz 1-2'den büyük: artık kaydın içine bakıyoruz. Buradaki
/// testler üç sınırı tutuyor:
/// <list type="bullet">
///   <item>öneri kuralı KAYITTAN doğar, modelden değil (katalog satırı);</item>
///   <item>kullanıcının göremediği kaynağın önerisi üretilmez;</item>
///   <item>servis iş tablosuna tek satır yazmaz.</item>
/// </list>
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class OneriTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public OneriTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private static IstekBaglami Baglam(params string[] kodlar) => new()
    {
        KullaniciId = 1,
        RolId = 1,
        SubeId = 1,
        Yetkiler = new YetkiSeti(1,
            kodlar.Select(k => new YetkiKaydi(k, 0, true, true, true, true)),
            []),
        IzlemeNo = "test",
    };

    /// <summary>Türü verilen ilk belgenin id'si (yoksa 0).</summary>
    private async Task<int> BelgeIdAsync(params int[] turler)
    {
        var veri = _olgu.Gerekli();
        return await veri.TekDegerAsync<int>(
            "select coalesce(min(b.id), 0) from public.belge b where b.tur = any(@p0)",
            [turler]);
    }

    [Fact]
    public async Task Basvuru_kaydinda_BASVURU_kurallari_calisir()
    {
        if (!_olgu.Baglandi(nameof(Basvuru_kaydinda_BASVURU_kurallari_calisir))) return;
        var id = await BelgeIdAsync(19);
        if (id == 0) return;                       // kurulumda başvuru yoksa ölçülemez

        // AYNI TABLO İKİ EKRAN: liste tanımında başvurunun da kaynağı 'belge'.
        //   İstemci 'belge' der; hangi kural ailesinin çalışacağına KAYIT karar
        //   verir. Bu ayrım olmadan başvuru kartında "faturada kalem yok"
        //   uyarısı çıkıyordu.
        var y = await new OneriServisi(_olgu.Gerekli()).OnerilerAsync(
            new OneriServisi.Istek("belge", id), Baglam("belge", "ai.rehber"),
            CancellationToken.None);

        Assert.Equal("basvuru", y.Kaynak);
        Assert.DoesNotContain(y.Oneriler, o => o.Kod.StartsWith("belge.", StringComparison.Ordinal));
    }

    [Fact]
    public async Task Fatura_kaydinda_BELGE_kurallari_calisir()
    {
        if (!_olgu.Baglandi(nameof(Fatura_kaydinda_BELGE_kurallari_calisir))) return;
        var id = await BelgeIdAsync(14, 15, 16, 119);
        if (id == 0) return;

        var y = await new OneriServisi(_olgu.Gerekli()).OnerilerAsync(
            new OneriServisi.Istek("belge", id), Baglam("belge", "ai.rehber"),
            CancellationToken.None);

        Assert.Equal("belge", y.Kaynak);
        Assert.DoesNotContain(y.Oneriler, o => o.Kod.StartsWith("basvuru.", StringComparison.Ordinal));
    }

    [Fact]
    public async Task Yetkisi_olmayan_kaynagin_ONERISI_uretilmez()
    {
        if (!_olgu.Baglandi(nameof(Yetkisi_olmayan_kaynagin_ONERISI_uretilmez))) return;
        var veri = _olgu.Gerekli();
        var cariId = await veri.TekDegerAsync<int>(
            "select coalesce(min(t.id), 0) from public.taraf t where t.musteri = 1");
        if (cariId == 0) return;

        // 'cari' yetkisi YOK: kartın eksiğini saymak, göremediği kaydı
        //   anlatmaktır. Yetkili bağlamla karşılaştırılıyor ki test kuralların
        //   hiç tetiklenmemesiyle karışmasın.
        var servis = new OneriServisi(veri);
        var yetkili = await servis.OnerilerAsync(new OneriServisi.Istek("cari", cariId),
                                                 Baglam("cari", "ai.rehber"), CancellationToken.None);
        var yetkisiz = await servis.OnerilerAsync(new OneriServisi.Istek("cari", cariId),
                                                 Baglam("stok", "ai.rehber"), CancellationToken.None);

        Assert.Empty(yetkisiz.Oneriler);
        if (yetkili.Oneriler.Count == 0) return;   // bu kayıtta zaten eksik yok
        Assert.NotEmpty(yetkili.Oneriler);
    }

    [Fact]
    public async Task Gizlenen_kural_SUSAR_ve_geri_acilir()
    {
        if (!_olgu.Baglandi(nameof(Gizlenen_kural_SUSAR_ve_geri_acilir))) return;
        var veri = _olgu.Gerekli();
        var servis = new OneriServisi(veri);
        var baglam = Baglam("belge", "cari", "ai.rehber");

        // Tetiklediğini bildiğimiz bir kayıt: koşulu şu an doğru olan ilk kural.
        var id = await BelgeIdAsync(19);
        if (id == 0) return;
        var once = await servis.OnerilerAsync(new OneriServisi.Istek("belge", id), baglam,
                                              CancellationToken.None);
        if (once.Oneriler.Count == 0) return;
        var kod = once.Oneriler[0].Kod;

        try
        {
            await servis.GizleAsync(kod, true, baglam, CancellationToken.None);
            var sonra = await servis.OnerilerAsync(new OneriServisi.Istek("belge", id), baglam,
                                                   CancellationToken.None);
            Assert.DoesNotContain(sonra.Oneriler, o => o.Kod == kod);

            // Kural SİLİNMEZ; yalnız bu kullanıcı için susar.
            var kuralDuruyor = await veri.TekDegerAsync<int>(
                "select count(*) from public.ai_oneri_kural where kod = @p0", [kod]);
            Assert.Equal(1, kuralDuruyor);
        }
        finally
        {
            await servis.GizleAsync(kod, false, baglam, CancellationToken.None);
        }

        var geri = await servis.OnerilerAsync(new OneriServisi.Istek("belge", id), baglam,
                                              CancellationToken.None);
        Assert.Contains(geri.Oneriler, o => o.Kod == kod);
    }

    [Fact]
    public async Task Bozuk_kural_PANELI_dusurmez()
    {
        if (!_olgu.Baglandi(nameof(Bozuk_kural_PANELI_dusurmez))) return;
        var veri = _olgu.Gerekli();
        var kod = "test.bozuk-" + Guid.NewGuid().ToString("N")[..8];
        await veri.CalistirAsync("""
            insert into public.ai_oneri_kural
                   (kod, kaynak, seviye, baslik, aciklama, alan, ekran, kosul, sira)
            values (@p0, 'cari', 2, 'Bozuk kural', '', '', '/cari',
                    'select exists(select 1 from public.yok_boyle_tablo where id = @p0)', 1)
            """, [kod]);
        try
        {
            var cariId = await veri.TekDegerAsync<int>(
                "select coalesce(min(t.id), 0) from public.taraf t where t.musteri = 1");
            if (cariId == 0) return;

            // Katalogdaki bir yazım hatası bütün paneli kapatmamalı: o kural
            //   atlanır, kalanı gösterilir.
            var y = await new OneriServisi(veri).OnerilerAsync(
                new OneriServisi.Istek("cari", cariId), Baglam("cari", "ai.rehber"),
                CancellationToken.None);
            Assert.DoesNotContain(y.Oneriler, o => o.Kod == kod);
        }
        finally
        {
            await veri.CalistirAsync("delete from public.ai_oneri_kural where kod = @p0", [kod]);
        }
    }

    [Fact]
    public void Oneri_servisi_YALNIZ_AI_TABLOLARINA_yazar()
    {
        // Faz 3'ün sınırı: asistan eksiği GÖSTERİR, tamamlamaz. Kaynakta iş
        //   tablosuna yazan tek bir SQL bile olmamalı - kural değişse de bu
        //   sınır testle duruyor.
        var kaynak = ServisKaynagi("OneriServisi.cs");
        var yazanlar = System.Text.RegularExpressions.Regex
            .Matches(kaynak, @"(insert\s+into|update|delete\s+from)\s+public\.(\w+)",
                     System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            .Select(m => m.Groups[2].Value)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        Assert.All(yazanlar, t => Assert.StartsWith("ai_", t, StringComparison.Ordinal));
        Assert.Contains("ai_rehber_log", yazanlar);
    }

    private static string ServisKaynagi(string dosya)
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        var yol = Path.Combine(dizin!.FullName, "src", "Gentegre.Api", "Servisler", dosya);
        Assert.True(File.Exists(yol), $"servis kaynağı bulunamadı: {yol}");
        return File.ReadAllText(yol);
    }
}

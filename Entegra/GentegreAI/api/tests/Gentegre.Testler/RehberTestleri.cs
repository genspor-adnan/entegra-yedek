using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Testler;

/// <summary>
/// AI REHBER (447) — rehberin sınırları.
///
/// Faz 1'in tek cümlesi: <b>asistan operatör değil rehberdir</b>. Buradaki
/// testler o sınırı tutuyor - yetkisi olmayana adım verilmez, kullanıcının
/// göremediği ekran önerilmez, cevap bulunamadığında uydurulmaz.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class RehberTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public RehberTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    /// <summary>Verilen kaynak kodlarına GÖR yetkisi olan bağlam.</summary>
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

    [Fact]
    public void Kolon_puani_BASLIGA_agirlik_verir()
    {
        // "Delta alanı" sorusu hem `deltaOnceki` (başlık "Önceki") hem
        //   `deltaUyari` (başlık "Delta") kolonuna vuruyordu; başlık ağırlığı
        //   olmadan listedeki ilk kolon kazanıyor ve yanlış alan anlatılıyordu.
        var kelimeler = RehberMetin.AlanAramaKelimeleri("Delta alanı ne demek");
        var onceki = RehberMetin.KolonPuani("Önceki", "deltaOnceki", kelimeler);
        var uyari  = RehberMetin.KolonPuani("Delta",  "deltaUyari",  kelimeler);
        Assert.True(uyari > onceki, $"başlık ağırlığı yok: {uyari} <= {onceki}");
    }

    [Fact]
    public void Kelime_ayiklama_SORU_KALIPLARINI_atar()
    {
        // "nasıl", "yapılır", "istiyorum" her soruda geçer; skorlamada
        //   kalırlarsa her konu her soruya eşit uzaklıkta olur.
        var k = RehberMetin.Kelimeler("Yeni hasta kaydı nasıl açılır?");
        Assert.Contains("hasta", k);
        Assert.Contains("kaydi", k);          // Türkçe harf ASCII'ye iner
        Assert.DoesNotContain("nasil", k);
        Assert.DoesNotContain("acilir", k);
    }

    [Fact]
    public async Task Bilinen_soru_KONU_ADIMLARINI_dondurur()
    {
        if (!_olgu.Baglandi(nameof(Bilinen_soru_KONU_ADIMLARINI_dondurur))) return;
        var servis = new RehberServisi(_olgu.Gerekli());

        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("Yeni hasta kaydı nasıl açılır?", null, "/panel", null),
            Baglam("personel", "belge"), CancellationToken.None);

        Assert.Equal("hasta-kayit", y.KonuKod);
        Assert.Equal(1, y.KaynakTuru);
        Assert.NotEmpty(y.Adimlar);
        Assert.True(y.GuvenSkoru >= 0.5m, $"güven düşük: {y.GuvenSkoru}");
        // İlk adım kullanıcıyı ekrana götürmeli (yetkisi var).
        Assert.Contains(y.Adimlar, a => a.Rota == "/hasta");
    }

    [Fact]
    public async Task YETKISIZ_iste_adim_verilmez()
    {
        if (!_olgu.Baglandi(nameof(YETKISIZ_iste_adim_verilmez))) return;
        var servis = new RehberServisi(_olgu.Gerekli());

        // Kullanıcının 'personel' (hasta kartı) yetkisi YOK: "şuraya git, şu
        //   düğmeye bas" demek, göremediği işlemi tarif etmektir.
        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("Yeni hasta kaydı nasıl açılır?", null, null, null),
            Baglam("stok"), CancellationToken.None);

        Assert.Equal("hasta-kayit", y.KonuKod);
        Assert.Empty(y.Adimlar);
        Assert.Contains(y.Uyarilar, u => u.Contains("personel"));
        Assert.Contains("yetki", y.Cevap, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Yetkisi_olmayan_EKRAN_onerilmez()
    {
        if (!_olgu.Baglandi(nameof(Yetkisi_olmayan_EKRAN_onerilmez))) return;
        var servis = new RehberServisi(_olgu.Gerekli());

        // Fatura konusu 'belge' yetkisiyle gelir; 'cari' yetkisi olmayan
        //   kullanıcıya cari ekranı ÖNERİLMEZ - adım metni kalır, düğmesi gitmez.
        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("Bir cariye fatura nasıl keserim?", null, null, null),
            Baglam("belge"), CancellationToken.None);

        Assert.Equal("satis-fatura", y.KonuKod);
        Assert.DoesNotContain(y.OnerilenEkranlar, e => e.Rota == "/cari");
        Assert.Contains(y.OnerilenEkranlar, e => e.Rota == "/belge");
    }

    [Fact]
    public async Task Anlamsiz_soruda_CEVAP_UYDURULMAZ()
    {
        if (!_olgu.Baglandi(nameof(Anlamsiz_soruda_CEVAP_UYDURULMAZ))) return;
        var servis = new RehberServisi(_olgu.Gerekli());

        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("zzz qqq wwww", null, null, null),
            Baglam("belge", "stok"), CancellationToken.None);

        Assert.Equal(0, y.KaynakTuru);
        Assert.Empty(y.Adimlar);
        Assert.Equal(0m, y.GuvenSkoru);
        // Emin olmadığında SORU sorar: yanlış ekrana göndermekten iyidir.
        Assert.False(string.IsNullOrWhiteSpace(y.EksikBilgiSorusu));
    }

    [Fact]
    public void Rehber_YALNIZ_KENDI_GUNLUGUNE_yazar()
    {
        // Faz 1'in sınırı: asistan operatör değil. Bunu satır sayısıyla ölçmek
        //   yarışa açık (başka testler aynı anda kayıt açıyor); onun yerine
        //   SERVİSİN KENDİSİ okunur: kaynakta iş tablosuna yazan tek bir SQL
        //   bile olmamalı.
        var kaynak = ServisKaynagi();
        var yazanlar = System.Text.RegularExpressions.Regex
            .Matches(kaynak, @"(insert\s+into|update|delete\s+from)\s+public\.(\w+)",
                     System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            .Select(m => m.Groups[2].Value)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        Assert.All(yazanlar, t => Assert.StartsWith("ai_", t, StringComparison.Ordinal));
        // Bugün yalnız günlüğe yazıyor; kontör model bağlanınca eklenecek.
        Assert.Contains("ai_rehber_log", yazanlar);
    }

    /// <summary>Servis kaynağını diskten okur (bin/Debug'dan yukarı çıkarak).</summary>
    private static string ServisKaynagi()
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        var yol = Path.Combine(dizin!.FullName, "src", "Gentegre.Api", "Servisler",
                               "RehberServisi.cs");
        Assert.True(File.Exists(yol), $"servis kaynağı bulunamadı: {yol}");
        return File.ReadAllText(yol);
    }

    [Fact]
    public async Task Soru_gunluge_yazilir()
    {
        if (!_olgu.Baglandi(nameof(Soru_gunluge_yazilir))) return;
        var veri = _olgu.Gerekli();
        var servis = new RehberServisi(veri);
        var isaret = "TEST-REHBER-" + Guid.NewGuid().ToString("N")[..8];

        // Cevapsız soru = eksik rehber konusu; günlük olmadan ölçülemez.
        await servis.CevaplaAsync(new RehberServisi.Istek(isaret, null, null, null),
                                  Baglam("belge"), CancellationToken.None);

        var kayit = await veri.TekAsync(
            "select kaynak, guven from public.ai_rehber_log where soru = @p0",
            [isaret], o => new { Kaynak = o.GetInt16(0), Guven = o.GetDecimal(1) });
        Assert.NotNull(kayit);
        Assert.Equal(0, kayit!.Kaynak);

        await veri.CalistirAsync("delete from public.ai_rehber_log where soru = @p0",
                                 [isaret]);
    }

    // ------------------------------------------------ FAZ 2: bağlamsal yardım

    [Fact]
    public async Task Bu_ekranda_ne_yapabilirim_AKTIF_EKRANI_anlatir()
    {
        if (!_olgu.Baglandi(nameof(Bu_ekranda_ne_yapabilirim_AKTIF_EKRANI_anlatir))) return;
        var servis = new RehberServisi(_olgu.Gerekli());

        // Aynı soru, farklı ekran = farklı cevap. Bağlam olmadan bu soru
        //   cevaplanamaz; katalog araması "ekran" kelimesine takılırdı.
        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("Bu ekranda ne yapabilirim?", null, "/lab-sonuc", null),
            Baglam("lab.sonuc", "lab.onay"), CancellationToken.None);

        Assert.Equal(3, y.KaynakTuru);
        Assert.Contains("Sonuçlar", y.Cevap);
        Assert.NotEmpty(y.OnerilenAksiyonlar);
    }

    [Fact]
    public async Task Baglamsal_yardim_YETKILI_dugmeleri_sayar()
    {
        if (!_olgu.Baglandi(nameof(Baglamsal_yardim_YETKILI_dugmeleri_sayar))) return;
        var servis = new RehberServisi(_olgu.Gerekli());

        // Onay yetkisi OLMAYAN kullanıcıya "Uzman Onayı" düğmesi sayılmaz:
        //   yapamayacağı işlemi saymak, ekranı yanlış tarif etmektir.
        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("bu ekranda ne yapabilirim", null, "/lab-sonuc", null),
            Baglam("lab.sonuc"), CancellationToken.None);

        Assert.Equal(3, y.KaynakTuru);
        Assert.DoesNotContain(y.OnerilenAksiyonlar, a => a.Kod.Contains("onay.uzman"));
    }

    [Fact]
    public async Task Alan_sorusu_KOLON_METADATASINDAN_cevaplanir()
    {
        if (!_olgu.Baglandi(nameof(Alan_sorusu_KOLON_METADATASINDAN_cevaplanir))) return;
        var servis = new RehberServisi(_olgu.Gerekli());

        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("referans alanı ne demek", null, "/lab-sonuc", null),
            Baglam("lab.sonuc"), CancellationToken.None);

        Assert.Equal(3, y.KaynakTuru);
        Assert.Contains("Referans", y.Cevap);
        Assert.Empty(y.Adimlar);          // alan açıklaması adım değildir
    }

    [Fact]
    public async Task Baglamsal_soru_YETKISIZ_ekranda_katalog_yoluna_duser()
    {
        if (!_olgu.Baglandi(nameof(Baglamsal_soru_YETKISIZ_ekranda_katalog_yoluna_duser)))
            return;
        var servis = new RehberServisi(_olgu.Gerekli());

        // Kullanıcı o ekranı göremiyorsa ekran yardımı verilmez; soru genel
        //   rehber yoluna düşer (uydurma "bu ekranda şunlar var" olmaz).
        var y = await servis.CevaplaAsync(
            new RehberServisi.Istek("bu ekranda ne yapabilirim", null, "/lab-sonuc", null),
            Baglam("stok"), CancellationToken.None);

        Assert.NotEqual(3, y.KaynakTuru);
    }
}

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
    public void Kelime_ayiklama_SORU_KALIPLARINI_atar()
    {
        // "nasıl", "yapılır", "istiyorum" her soruda geçer; skorlamada
        //   kalırlarsa her konu her soruya eşit uzaklıkta olur.
        var k = RehberServisi.Kelimeler("Yeni hasta kaydı nasıl açılır?");
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
    public async Task Rehber_VERI_YAZMAZ()
    {
        if (!_olgu.Baglandi(nameof(Rehber_VERI_YAZMAZ))) return;
        var veri = _olgu.Gerekli();
        var servis = new RehberServisi(veri);

        // Faz 1'in sınırı: yalnız `ai_rehber_log` büyür; iş verisine dokunulmaz.
        var oncekiHasta = await veri.TekDegerAsync<long>(
            "select count(*) from public.taraf where hasta = 1");
        var oncekiBelge = await veri.TekDegerAsync<long>(
            "select count(*) from public.belge");

        await servis.CevaplaAsync(
            new RehberServisi.Istek("hasta kaydı aç", null, null, null),
            Baglam("personel"), CancellationToken.None);

        Assert.Equal(oncekiHasta, await veri.TekDegerAsync<long>(
            "select count(*) from public.taraf where hasta = 1"));
        Assert.Equal(oncekiBelge, await veri.TekDegerAsync<long>(
            "select count(*) from public.belge"));
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
}

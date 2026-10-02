using Gentegre.Api.Servisler;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// ASİSTAN ROL SORUSUNU CEVAPLAR (789).
///
/// Kullanıcı: *"projedeki yapay zekaya bir rolü sorduğumda yapabileceklerini
/// bana söylemeli"*.
///
/// Cevap rehber kataloğundan değil ROL TANIMINDAN üretilir: rol_yetki satırları
/// ekranlara (`ai_rehber_ekran.yetki_kodu`) ve işlem yetkilerine çözülür.
/// Buradaki testler iki şeyi korur: soruyu TANIMA (yanlış tanıma, alakasız
/// soruyu rol dökümüne çevirir) ve yetki kodlarının ekranlara GERÇEKTEN
/// bağlanması (bağlanmazsa asistan "bu rol hiçbir ekranı açamaz" der).
/// </summary>
public sealed class RolRehberTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [Theory]
    [InlineData("kayıt kabul rolü ne yapabilir", true)]
    [InlineData("muhasebe rolünün yetkileri neler", true)]
    [InlineData("rolüm ne yapabilir", true)]
    [InlineData("hekim yetkileri nelerdir", true)]
    // "kontrol" içinde "rol" geçer: metin araması bu soruyu rol dökümüne
    //   çevirirdi. Kelime sınırı olmadan asistan konuyu kaybeder.
    [InlineData("kalite kontrol nasıl yapılır", false)]
    [InlineData("hasta kaydı nasıl açılır", false)]
    [InlineData("randevu kontrolü nerede", false)]
    public void Rol_sorusu_TANINIR(string soru, bool beklenen)
        => Assert.Equal(beklenen, RehberMetin.RolSorusuMu(soru));

    [Fact]
    public void Kendi_rolu_sorusu_ayrilir()
    {
        Assert.True(RehberMetin.KendiRoluMu("rolüm ne yapabilir"));
        Assert.True(RehberMetin.KendiRoluMu("benim rolüm neler yapabilir"));
        Assert.False(RehberMetin.KendiRoluMu("hekim rolü ne yapabilir"));
    }

    [Fact]
    public void Rol_adi_aramasi_KALIP_kelimeleri_atar()
    {
        // "rolü", "yetkileri", "ne yapabilir" her rol sorusunda geçer; rol
        //   adına karışırlarsa bütün roller aynı puanı alır ve eşleşme
        //   rastgeleleşir.
        var k = RehberMetin.RolAramaKelimeleri("kayıt kabul rolü ne yapabilir");
        Assert.Contains("kayit", k);
        Assert.Contains("kabul", k);
        Assert.DoesNotContain(k, x => x.StartsWith("rol", StringComparison.Ordinal));
        Assert.DoesNotContain("yapabilir", k);
    }

    [VtFact]
    public async Task Rol_yetkileri_EKRANLARA_cozulur()
    {
        if (!_olgu.Baglandi(nameof(Rol_yetkileri_EKRANLARA_cozulur))) return;
        var veri = _olgu.Gerekli();

        // Asistanın kullandığı bağ: rol_yetki -> yetki.kod -> ai_rehber_ekran.
        //   Bu bağ kopuksa (katalog kodu değişmiş, ekran satırı yazılmamış)
        //   hata çıkmaz - asistan rolü "hiçbir ekranı açamaz" diye anlatır.
        var ekran = await veri.TekDegerAsync<long>("""
            select count(*)
              from public.rol_yetki ry
              join public.rol r on r.id = ry.rol_id and r.kod = 'kayit_kabul'
              join public.yetki y on y.id = ry.yetki_id
              join public.ai_rehber_ekran e on e.yetki_kodu = y.kod and e.durum = 0
             where ry.gor = 1
            """, [], CancellationToken.None);
        Assert.True(ekran > 0,
            "Kayıt Kabul rolünün hiçbir yetkisi bir rehber ekranına bağlanmıyor.");

        // İŞLEM yetkisi (tur 1) de anlatılıyor: "ne yapabilir" sorusunun
        //   cevabı yalnız ekran listesi değil, düğmelerdir.
        var islem = await veri.TekDegerAsync<long>("""
            select count(*)
              from public.rol_yetki ry
              join public.rol r on r.id = ry.rol_id and r.kod = 'kayit_kabul'
              join public.yetki y on y.id = ry.yetki_id and y.tur = 1
             where ry.gor = 1
            """, [], CancellationToken.None);
        Assert.True(islem > 0, "Kayıt Kabul rolünde hiç işlem yetkisi yok.");
    }

    [VtFact]
    public async Task Sinir_tasiyan_yetki_ISLEM_listesinde_sayilmaz()
    {
        if (!_olgu.Baglandi(nameof(Sinir_tasiyan_yetki_ISLEM_listesinde_sayilmaz))) return;
        var veri = _olgu.Gerekli();

        // `basvuru.iskonto` bir düğme değil TAVANDIR (661): değeri "%10 iskonto
        //   yapabilir" demek. İşlem listesinde sayılırsa kullanıcı onu ayrı bir
        //   yetki sanar; asistan bu satırları "Sınırlar" başlığına ayırır.
        var degerAlir = await veri.TekDegerAsync<short>(
            "select deger_alir from public.yetki where kod = 'basvuru.iskonto'",
            [], CancellationToken.None);
        Assert.Equal((short)1, degerAlir);

        var tavan = await veri.TekDegerAsync<string>("""
            select ry.deger
              from public.rol_yetki ry
              join public.rol r on r.id = ry.rol_id and r.kod = 'kayit_kabul'
              join public.yetki y on y.id = ry.yetki_id and y.kod = 'basvuru.iskonto'
            """, [], CancellationToken.None);
        Assert.False(string.IsNullOrWhiteSpace(tavan),
            "785 kayıt kabul rolüne iskonto tavanı yazmalıydı.");
    }
}

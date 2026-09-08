using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// HİZMET CİNSİYET / YAŞ UYGUNLUĞU (482).
///
/// Kullanıcı: "doğum erkek için olmaz ve 15 yaşından aşağı da olmaz; prostat
/// sadece erkeklere ve 20 yaşından sonra olur; çok hizmet de her iki cinsiyet
/// için olur."
///
/// Kural TEK YERDE (<c>fn_hizmet_uygunluk</c>); ücret satırı ve radyoloji
/// istemi tetikleri onu çağırır. Testler hem kuralı hem KAPIYI doğrular -
/// kural doğru olup kapı açık kalırsa yanlış satır yine eklenir.
/// </summary>
public class HizmetUygunlukTestleri : IClassFixture<VeritabaniOlgusu>, IAsyncLifetime
{
    private readonly VeritabaniOlgusu _olgu;
    public HizmetUygunlukTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private const string Etiket = "TEST_UYGUNLUK";
    private readonly List<int> _hizmetler = [];
    private readonly List<int> _taraflar = [];
    private readonly List<int> _belgeler = [];

    public Task InitializeAsync() => Task.CompletedTask;

    public async Task DisposeAsync()
    {
        var veri = _olgu.Veri;
        if (veri is null) return;
        foreach (var b in _belgeler)
        {
            await veri.CalistirAsync(
                "delete from public.belge_satir_dagilim where belge_satir_id in " +
                "  (select id from public.belge_satir where belge_id = @p0)", [b]);
            await veri.CalistirAsync("delete from public.belge_satir where belge_id = @p0", [b]);
            await veri.CalistirAsync("delete from public.belge_basvuru where id = @p0", [b]);
            await veri.CalistirAsync("delete from public.belge where id = @p0", [b]);
        }
        foreach (var h in _hizmetler)
            await veri.CalistirAsync("delete from public.hizmet where id = @p0", [h]);
        foreach (var t in _taraflar)
        {
            await veri.CalistirAsync("delete from public.taraf_hasta where id = @p0", [t]);
            await veri.CalistirAsync("delete from public.taraf where id = @p0", [t]);
        }
    }

    private async Task<int> HizmetAsync(VeriKaynagi veri, string ad, short cinsiyet,
        short? yasAlt = null, short? yasUst = null)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.hizmet (kod, ad, durum, kdv, birim, cinsiyet,
                                       yas_alt, yas_ust, sube_id)
            values (@p0, @p1, 1, 20, 51, @p2, @p3, @p4,
                    (select min(id) from public.sube))
            returning id
            """, [$"{Etiket}-{Guid.NewGuid():N}"[..20], $"{Etiket} {ad}",
                  cinsiyet, yasAlt, yasUst]);
        _hizmetler.Add(id);
        return id;
    }

    private async Task<int> HastaAsync(VeriKaynagi veri, short cinsiyet, int yas)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, hasta, sube_id)
            values (@p0, 1, (select min(id) from public.sube)) returning id
            """, [$"{Etiket} HASTA"]);
        _taraflar.Add(id);
        await veri.CalistirAsync("""
            insert into public.taraf_hasta (id, cinsiyet, dogum_tarihi)
            values (@p0, @p1, (current_date - make_interval(years => @p2))::date)
            """, [id, cinsiyet, yas]);
        return id;
    }

    private async Task<int> SatirYazAsync(VeriKaynagi veri, int hastaId, int hizmetId,
        string? gerekce = null)
    {
        var belgeId = await veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id)
            values (19, now(), @p0, 0, (select min(id) from public.sube)) returning id
            """, [hastaId]);
        _belgeler.Add(belgeId);
        return await veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, adet,
                                            birim_fiyat, tutar, kdv, uygunluk_notu, sube_id)
            values (@p0, 1, 2, @p1, 1, 1, 100, 100, 0, coalesce(@p2, ''),
                    (select min(id) from public.sube))
            returning id
            """, [belgeId, hizmetId, gerekce]);
    }

    [Fact]
    public async Task Kuralsiz_hizmet_herkese_uygulanir()
    {
        if (!_olgu.Baglandi(nameof(HizmetUygunlukTestleri))) return;
        var veri = _olgu.Gerekli();

        // Hizmetlerin ÇOĞU kuralsızdır: boş bırakılan kart kimseyi engellemez.
        var hizmet = await HizmetAsync(veri, "GENEL", 0);
        var erkek = await HastaAsync(veri, 1, 40);
        var kadin = await HastaAsync(veri, 2, 8);

        Assert.Null(await veri.TekDegerAsync<string>(
            "select public.fn_hizmet_uygunluk(@p0, @p1)", [hizmet, erkek]));
        Assert.Null(await veri.TekDegerAsync<string>(
            "select public.fn_hizmet_uygunluk(@p0, @p1)", [hizmet, kadin]));
        Assert.True(await SatirYazAsync(veri, erkek, hizmet) > 0);
    }

    [Fact]
    public async Task Yanlis_cinsiyete_hizmet_eklenemez()
    {
        if (!_olgu.Baglandi(nameof(HizmetUygunlukTestleri))) return;
        var veri = _olgu.Gerekli();

        var dogum = await HizmetAsync(veri, "DOGUM", 2, yasAlt: 15);
        var erkek = await HastaAsync(veri, 1, 30);
        var kadin = await HastaAsync(veri, 2, 30);

        var sebep = await veri.TekDegerAsync<string>(
            "select public.fn_hizmet_uygunluk(@p0, @p1)", [dogum, erkek]);
        Assert.Contains("KADIN", sebep!);

        // KAPI: satır yazılamaz.
        var hata = await Assert.ThrowsAnyAsync<Exception>(
            () => SatirYazAsync(veri, erkek, dogum));
        Assert.Contains("KADIN", hata.Message);

        // Doğru cinsiyette sorun yok.
        Assert.True(await SatirYazAsync(veri, kadin, dogum) > 0);
    }

    [Fact]
    public async Task Yas_alt_siniri_altindaki_hastaya_eklenemez()
    {
        if (!_olgu.Baglandi(nameof(HizmetUygunlukTestleri))) return;
        var veri = _olgu.Gerekli();

        // "Prostat yalnız erkeklere ve 20 yaşından sonra."
        var psa = await HizmetAsync(veri, "PSA", 1, yasAlt: 20);
        var genc = await HastaAsync(veri, 1, 17);
        var yetiskin = await HastaAsync(veri, 1, 46);

        var sebep = await veri.TekDegerAsync<string>(
            "select public.fn_hizmet_uygunluk(@p0, @p1)", [psa, genc]);
        Assert.Contains("20 yaşından küçük", sebep!);
        Assert.Contains("17 yaşında", sebep!);

        await Assert.ThrowsAnyAsync<Exception>(() => SatirYazAsync(veri, genc, psa));
        Assert.True(await SatirYazAsync(veri, yetiskin, psa) > 0);
    }

    [Fact]
    public async Task Yas_ust_siniri_asilirsa_eklenemez()
    {
        if (!_olgu.Baglandi(nameof(HizmetUygunlukTestleri))) return;
        var veri = _olgu.Gerekli();

        // Çocuk polikliniği hizmeti: 18 yaş ve altı.
        var cocuk = await HizmetAsync(veri, "COCUK", 0, yasUst: 18);
        var buyuk = await HastaAsync(veri, 2, 35);

        var sebep = await veri.TekDegerAsync<string>(
            "select public.fn_hizmet_uygunluk(@p0, @p1)", [cocuk, buyuk]);
        Assert.Contains("18 yaşından büyük", sebep!);
        await Assert.ThrowsAnyAsync<Exception>(() => SatirYazAsync(veri, buyuk, cocuk));
    }

    [Fact]
    public async Task Gerekce_yazilirsa_kural_asilir_ve_iz_kalir()
    {
        if (!_olgu.Baglandi(nameof(HizmetUygunlukTestleri))) return;
        var veri = _olgu.Gerekli();

        // Gerçek istisna: erkekte meme kanseri şüphesi.
        var meme = await HizmetAsync(veri, "MEME US", 2, yasAlt: 25);
        var erkek = await HastaAsync(veri, 1, 55);

        var satirId = await SatirYazAsync(veri, erkek, meme, "Erkekte meme kanseri suphesi");
        var not = await veri.TekDegerAsync<string>(
            "select uygunluk_notu from public.belge_satir where id = @p0", [satirId]);
        Assert.Equal("Erkekte meme kanseri suphesi", not);
    }

    [Fact]
    public async Task Hasta_olmayan_carinin_faturasinda_kural_aranmaz()
    {
        if (!_olgu.Baglandi(nameof(HizmetUygunlukTestleri))) return;
        var veri = _olgu.Gerekli();

        // Kuruma kesilen faturada "hastanın cinsiyeti" diye bir şey yok.
        var meme = await HizmetAsync(veri, "MEME US", 2, yasAlt: 25);
        var kurum = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, musteri, sube_id)
            values (@p0, 1, (select min(id) from public.sube)) returning id
            """, [$"{Etiket} KURUM"]);
        _taraflar.Add(kurum);

        Assert.Null(await veri.TekDegerAsync<string>(
            "select public.fn_hizmet_uygunluk(@p0, @p1)", [meme, kurum]));
        Assert.True(await SatirYazAsync(veri, kurum, meme) > 0);
    }
}

using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// SGK (SUT) BEDELİ EKRANDAN (483).
///
/// Kullanıcı: "başvuru ekledim, TSS olarak. Bana sadece bir defa sigorta
/// ücretini sordu; oysa SGK SUT fiyatını da bulup atması gerekirdi. Eğer yoksa
/// ekrandan onu alması gerekir."
///
/// Kırılma noktası şuydu: sözleşmenin SUT listesi BOŞSA `sgk` sessizce sıfır
/// kalıyor ve tutarın tamamı sigortaya/hastaya yazılıyordu. Sessiz para hatası -
/// SGK'dan alınacak pay hiç doğmuyor. Testler üç şeyi birlikte tutar:
///   * liste boşsa eski davranış (regresyonu göstersin),
///   * ekrandan verilen bedel kovalara doğru girsin,
///   * sonraki TAZELEMELER (provizyon geldi) o bedeli EZMESİN.
/// </summary>
public class SutBedeliTestleri : IClassFixture<VeritabaniOlgusu>, IAsyncLifetime
{
    private readonly VeritabaniOlgusu _olgu;
    public SutBedeliTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private const string Etiket = "TEST_SUT_BEDELI";
    private readonly List<int> _belgeler = [];
    private readonly List<int> _sozlesmeler = [];
    private readonly List<int> _listeler = [];
    private readonly List<int> _taraflar = [];

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
        foreach (var s in _sozlesmeler)
            await veri.CalistirAsync("delete from public.kurum_sozlesme where id = @p0", [s]);
        foreach (var l in _listeler)
        {
            await veri.CalistirAsync(
                "delete from public.fiyat_listesi_satir where liste_id = @p0", [l]);
            await veri.CalistirAsync("delete from public.fiyat_listesi where id = @p0", [l]);
        }
        foreach (var t in _taraflar)
        {
            await veri.CalistirAsync("delete from public.taraf_kurum where id = @p0", [t]);
            await veri.CalistirAsync("delete from public.taraf_hasta where id = @p0", [t]);
            await veri.CalistirAsync("delete from public.taraf where id = @p0", [t]);
        }
    }

    // ------------------------------------------------------------- kurulum --

    /// <summary>
    /// Cinsiyet/yaş kuralı OLMAYAN bir hizmet: 482'nin kapısı bu testlerin
    /// konusu değil, kurulum onun yüzünden düşmesin.
    /// </summary>
    private static Task<int> HizmetAsync(VeriKaynagi veri)
        => veri.TekDegerAsync<int>(
            "select min(id) from public.hizmet " +
            " where coalesce(cinsiyet, 0) = 0 and yas_alt is null and yas_ust is null");

    /// <summary>Satırı olan liste. `bos` ise liste var ama İÇİ BOŞ (asıl vaka).</summary>
    private async Task<int> ListeAsync(VeriKaynagi veri, string ad, int hizmetId,
        decimal fiyat, bool bos = false)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.fiyat_listesi (ad, durum, yon, kdv_dahil)
            values (@p0, 1, 2, 0) returning id
            """, [$"{Etiket} {ad} {Guid.NewGuid():N}"[..40]]);
        _listeler.Add(id);
        if (!bos)
            await veri.CalistirAsync("""
                insert into public.fiyat_listesi_satir (liste_id, hizmet_id, fiyat,
                                                        durum, kdv_dahil)
                values (@p0, @p1, @p2, 1, 0)
                """, [id, hizmetId, fiyat]);
        return id;
    }

    private async Task<int> KurumAsync(VeriKaynagi veri, short tur)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, musteri, sube_id)
            values (@p0, 1, (select min(id) from public.sube)) returning id
            """, [$"{Etiket} KURUM"]);
        _taraflar.Add(id);
        await veri.CalistirAsync(
            "insert into public.taraf_kurum (id, tur) values (@p0, @p1)", [id, tur]);
        return id;
    }

    private async Task<int> SozlesmeAsync(VeriKaynagi veri, int kurumId, short altKurum,
        int? tarifeListe, int? sutListe, int? sgkKurum)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.kurum_sozlesme
                   (kurum_id, ad, alt_kurum, durum, fiyat_listesi_id,
                    sgk_fiyat_listesi_id, sgk_kurum_id)
            values (@p0, @p1, @p2, 1, @p3, @p4, @p5) returning id
            """, [kurumId, Etiket, altKurum, tarifeListe, sutListe, sgkKurum]);
        _sozlesmeler.Add(id);
        return id;
    }

    private async Task<int> SatirAsync(VeriKaynagi veri, int kurumId, int sozlesmeId,
        short altKurum, int hizmetId, decimal tutar)
    {
        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, hasta, sube_id)
            values (@p0, 1, (select min(id) from public.sube)) returning id
            """, [$"{Etiket} HASTA"]);
        _taraflar.Add(hastaId);
        await veri.CalistirAsync("""
            insert into public.taraf_hasta (id, cinsiyet, dogum_tarihi)
            values (@p0, 1, (current_date - make_interval(years => 40))::date)
            """, [hastaId]);

        var belgeId = await veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id)
            values (19, now(), @p0, 0, (select min(id) from public.sube)) returning id
            """, [hastaId]);
        _belgeler.Add(belgeId);
        await veri.CalistirAsync("""
            insert into public.belge_basvuru (id, odeyen_kurum_id, sozlesme_id,
                                              alt_kurum, sgk_kullan)
            values (@p0, @p1, @p2, @p3, 1)
            """, [belgeId, kurumId, sozlesmeId, altKurum]);

        return await veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, adet,
                                            birim_fiyat, birim_fiyat_kdvli, tutar,
                                            tutar_kdvli, kdv, sube_id)
            values (@p0, 1, 2, @p1, 1, 1, @p2, @p2, @p2, @p2, 0,
                    (select min(id) from public.sube)) returning id
            """, [belgeId, hizmetId, tutar]);
    }

    private sealed record Kova(short Rota, decimal Tutar, decimal Sgk, decimal Oss,
                               decimal SgkListe, short SgkListeElle);

    private static Task<Kova?> OkuAsync(VeriKaynagi veri, int satirId)
        => veri.TekAsync("""
            select d.rota, s.tutar, d.sgk, d.oss, d.sgk_liste, d.sgk_liste_elle
              from public.belge_satir_dagilim d
              join public.belge_satir s on s.id = d.belge_satir_id
             where d.belge_satir_id = @p0
            """, [satirId],
            o => new Kova(o.GetInt16(0), o.GetDecimal(1), o.GetDecimal(2),
                          o.GetDecimal(3), o.GetDecimal(4), o.GetInt16(5)));

    /// <summary>TSS kurulumu: tarife listesi dolu, SUT listesi BOŞ (asıl vaka).</summary>
    private async Task<int> TssSatiriAsync(VeriKaynagi veri, decimal tarife = 2000m)
    {
        var hizmet = await HizmetAsync(veri);
        var tarifeListe = await ListeAsync(veri, "TTB", hizmet, tarife);
        var sutListe = await ListeAsync(veri, "SUT", hizmet, 0m, bos: true);
        var kurum = await KurumAsync(veri, 2);
        var soz = await SozlesmeAsync(veri, kurum, 202, tarifeListe, sutListe, kurum);
        return await SatirAsync(veri, kurum, soz, 202, hizmet, tarife);
    }

    // -------------------------------------------------------------- testler --

    [Fact]
    public async Task Sut_listesi_bossa_sgk_payi_sifir_kalir()
    {
        if (!_olgu.Baglandi(nameof(SutBedeliTestleri))) return;
        var veri = _olgu.Gerekli();

        // KULLANICININ GÖRDÜĞÜ HÂL: ekran tek fiyat sordu, SGK payı doğmadı.
        //   Bu davranış kaldı - ama artık sessiz değil, ekran bedeli soruyor.
        var satirId = await TssSatiriAsync(veri);
        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);

        var k = await OkuAsync(veri, satirId);
        Assert.Equal((short)3, k!.Rota);
        Assert.Equal(0m, k.Sgk);
        Assert.Equal((short)0, k.SgkListeElle);
    }

    [Fact]
    public async Task Ekrandan_verilen_sut_bedeli_sgk_kovasina_girer()
    {
        if (!_olgu.Baglandi(nameof(SutBedeliTestleri))) return;
        var veri = _olgu.Gerekli();

        var satirId = await TssSatiriAsync(veri);
        await veri.CalistirAsync(
            "select public.fn_belge_satir_dagilim_tazele(@p0, null, null, @p1, null)",
            [satirId, 800m]);

        var k = await OkuAsync(veri, satirId);
        Assert.Equal(800m, k!.Sgk);
        Assert.Equal(800m, k.SgkListe);
        Assert.Equal((short)1, k.SgkListeElle);
        // Rota 3'te satır tutarı KOVALARDAN doğar: 800 SUT + 2000 tarife.
        Assert.Equal(2800m, k.Tutar);
        Assert.Equal(2800m, k.Sgk + k.Oss);
    }

    [Fact]
    public async Task Sonraki_tazeleme_ekrandan_gireni_ezmez()
    {
        if (!_olgu.Baglandi(nameof(SutBedeliTestleri))) return;
        var veri = _olgu.Gerekli();

        // ASIL RİSK: bedel bir kez girilir, sonra ÖSS provizyonu gelir ve
        //   dağılım yeniden hesaplanır. Bayrak olmasaydı SUT bedeli boş
        //   listeden 0'a dönerdi - kullanıcının yazdığı sessizce silinirdi.
        var satirId = await TssSatiriAsync(veri);
        await veri.CalistirAsync(
            "select public.fn_belge_satir_dagilim_tazele(@p0, null, null, @p1, null)",
            [satirId, 800m]);

        await veri.CalistirAsync(
            "select public.fn_belge_satir_dagilim_tazele(@p0, null, @p1)",
            [satirId, 1500m]);

        var k = await OkuAsync(veri, satirId);
        Assert.Equal(800m, k!.Sgk);
        Assert.Equal(800m, k.SgkListe);
        Assert.Equal(1500m, k.Oss);
        Assert.Equal((short)1, k.SgkListeElle);
    }

    [Fact]
    public async Task Sifir_da_gecerli_cevaptir_sgk_odemiyor()
    {
        if (!_olgu.Baglandi(nameof(SutBedeliTestleri))) return;
        var veri = _olgu.Gerekli();

        // "SGK bu hizmeti ödemiyor" da bir cevaptır: 0 yazılır ve SABİTLENİR -
        //   boş bırakılmış satırdan ayırt edilebilsin.
        var satirId = await TssSatiriAsync(veri);
        await veri.CalistirAsync(
            "select public.fn_belge_satir_dagilim_tazele(@p0, null, null, @p1, null)",
            [satirId, 0m]);

        var k = await OkuAsync(veri, satirId);
        Assert.Equal(0m, k!.Sgk);
        Assert.Equal((short)1, k.SgkListeElle);
    }

    [Fact]
    public async Task Sut_listesi_doluysa_bedel_sorulmadan_gelir()
    {
        if (!_olgu.Baglandi(nameof(SutBedeliTestleri))) return;
        var veri = _olgu.Gerekli();

        // Doğru kurulmuş sözleşmede ekranın soracağı bir şey yok: bedel
        //   listeden çözülür ve bayrak 0 kalır.
        var hizmet = await HizmetAsync(veri);
        var tarifeListe = await ListeAsync(veri, "TTB", hizmet, 2000m);
        var sutListe = await ListeAsync(veri, "SUT", hizmet, 800m);
        var kurum = await KurumAsync(veri, 2);
        var soz = await SozlesmeAsync(veri, kurum, 202, tarifeListe, sutListe, kurum);
        var satirId = await SatirAsync(veri, kurum, soz, 202, hizmet, 2000m);

        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);

        var k = await OkuAsync(veri, satirId);
        Assert.Equal(800m, k!.Sgk);
        Assert.Equal((short)0, k.SgkListeElle);
        Assert.Equal(2800m, k.Tutar);
    }

    [Fact]
    public async Task Oss_rotasinda_sut_bedeli_aranmaz()
    {
        if (!_olgu.Baglandi(nameof(SutBedeliTestleri))) return;
        var veri = _olgu.Gerekli();

        // ÖSS'de (rota 2) SGK payı YOKTUR: olmayan bir bedeli sormak,
        //   kullanıcıyı yanlış yere sayı yazmaya davet ederdi.
        var hizmet = await HizmetAsync(veri);
        var tarifeListe = await ListeAsync(veri, "TTB", hizmet, 1000m);
        var kurum = await KurumAsync(veri, 2);
        var soz = await SozlesmeAsync(veri, kurum, 201, tarifeListe, null, null);
        var satirId = await SatirAsync(veri, kurum, soz, 201, hizmet, 1000m);

        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);

        var k = await OkuAsync(veri, satirId);
        Assert.Equal((short)2, k!.Rota);
        Assert.Equal(0m, k.Sgk);
        Assert.Equal(1000m, k.Tutar);
    }
}

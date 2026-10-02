using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// NÖBET ÇİZELGESİ + OTOMATİK ATAMA (801).
///
/// Kullanıcı: *"nöbet çizelgesi ve atama kurallarıyla devam et"*.
///
/// 797'de atama yalnız elleydi: gece ve hafta sonu teleradyolojinin asıl iş
/// saatidir, o saatte listeye bakan kişi olmayabilir. Kural
/// <b>veritabanında</b> (`fn_telerad_radyolog_oner`) çünkü aynı kararı hem
/// ekranın "Otomatik Dağıt" düğmesi hem ileride DICOM alımından gelen iş
/// verecek - iki yerde yorumlamak iki farklı radyolog demekti.
/// </summary>
public sealed class TeleradAtamaTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Kendi kurumunu, sözleşmesini ve iki radyologunu açar.</summary>
    private static async Task<(int Kurum, int RadyologA, int RadyologB, int Sube)>
        KurulumAsync(NpgsqlConnection b, NpgsqlTransaction t)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);

        // KURAL KÜMESİ TESTİN KENDİSİDİR: dev veritabanında ekrandan
        //   girilmiş kural ve nöbet olabilir - onlar "ilk uyan kural kazanır"
        //   sırasına karışıp testi rastgele kırardı (gerçekten kırdı).
        //   İşlem geri alındığı için kalıcı etkisi yok.
        await b.CalistirAsync("update public.telerad_atama_kurali set aktif = 0",
            t, [], CancellationToken.None);
        await b.CalistirAsync("update public.telerad_nobet set aktif = 0",
            t, [], CancellationToken.None);
        var taraf = await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, kod, musteri, sube_id)
            values ('TELERAD ATAMA TEST KURUMU', 'TRATK', 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        var kurum = await b.TekDegerAsync<int>("""
            insert into public.telerad_kurum (taraf_id, yon, dicom_ae_title, sube_id)
            values (@p0, 1, '', @p1) returning id
            """, t, [taraf, sube], CancellationToken.None);
        await b.CalistirAsync("""
            insert into public.telerad_sozlesme
                   (kurum_id, baslangic, ucret_modeli, sla_acil_dk, sla_oncelikli_dk,
                    sla_rutin_dk, durum)
            values (@p0, current_date - 10, 1, 30, 240, 1440, 1)
            """, t, [kurum], CancellationToken.None);

        // TEST KENDİ RADYOLOGLARINI AÇAR: var olan personeli ödünç almak,
        //   başka sınıfın açtığı işle yük sayısını kirletirdi.
        var a = await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, kod, personel, sube_id)
            values ('TEST RADYOLOG A', 'TRADA', 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        var bRad = await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, kod, personel, sube_id)
            values ('TEST RADYOLOG B', 'TRADB', 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        return (kurum, a, bRad, sube);
    }

    private static Task<int> IstekAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int kurum, int sube, short oncelik, string erisim, short modalite = 1)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, goruntu_durum,
                    cekim_zamani, gelis_zamani, sube_id)
            values (@p0, @p1, @p2, @p3, 1, now(), now(), @p4)
            returning id
            """, t, [kurum, erisim, oncelik, modalite, sube], CancellationToken.None);

    /// <summary>Şu anı kapsayan nöbet (gece yarısını geçen aralık dâhil).</summary>
    private static Task<int> NobetAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int radyolog, int sube, short tur = 1, int azamiIs = 0, int? kurum = null)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_nobet
                   (radyolog_id, baslangic, bitis, tur, azami_is, kurum_id, sube_id)
            values (@p0, now() - interval '2 hour', now() + interval '6 hour',
                    @p2, @p3, @p4, @p1)
            returning id
            """, t, [radyolog, sube, tur, azamiIs, kurum], CancellationToken.None);

    private static Task<int> KuralAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, int sira, short hedefTur, int? hedefRadyolog = null,
        short modalite = 0, short oncelik = 0, int azamiIs = 0)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_atama_kurali
                   (ad, sira, modalite, oncelik, hedef_tur, hedef_radyolog_id,
                    azami_is, sube_id)
            values ('deneme', @p1, @p3, @p4, @p2, @p5, @p6, @p0)
            returning id
            """, t, [sube, sira, hedefTur, modalite, oncelik, hedefRadyolog, azamiIs],
            CancellationToken.None);

    private static Task<int?> OneriAsync(NpgsqlConnection b, NpgsqlTransaction t, int istek)
        => b.TekDegerAsync<int?>("select public.fn_telerad_radyolog_oner(@p0)",
                                 t, [istek], CancellationToken.None);

    [VtFact]
    public async Task Nobetci_onerilir()
    {
        if (!_olgu.Baglandi(nameof(Nobetci_onerilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, radyologA, _, sube) = await KurulumAsync(b, t);
        await NobetAcAsync(b, t, radyologA, sube);
        await KuralAcAsync(b, t, sube, 10, hedefTur: 1);           // o anki nöbetçi
        var istek = await IstekAcAsync(b, t, kurum, sube, 1, "A-001");

        Assert.Equal(radyologA, await OneriAsync(b, t, istek));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Ilk_uyan_kural_KAZANIR()
    {
        if (!_olgu.Baglandi(nameof(Ilk_uyan_kural_KAZANIR))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // SIRA KARAR SIRASIDIR: "acil BT önce Dr. A'ya" kuralı "her iş
        //   nöbetçiye" kuralının ÜSTÜNDE durur.
        var (kurum, radyologA, radyologB, sube) = await KurulumAsync(b, t);
        await NobetAcAsync(b, t, radyologB, sube);                  // nöbetçi B
        await KuralAcAsync(b, t, sube, 5, hedefTur: 2, hedefRadyolog: radyologA,
                           modalite: 1, oncelik: 3);                // acil BT -> A
        await KuralAcAsync(b, t, sube, 10, hedefTur: 1);            // gerisi nöbetçiye

        var acilBt = await IstekAcAsync(b, t, kurum, sube, 3, "A-002", modalite: 1);
        var rutinMr = await IstekAcAsync(b, t, kurum, sube, 1, "A-003", modalite: 2);

        Assert.Equal(radyologA, await OneriAsync(b, t, acilBt));
        Assert.Equal(radyologB, await OneriAsync(b, t, rutinMr));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Dolu_radyolog_ATLANIR()
    {
        if (!_olgu.Baglandi(nameof(Dolu_radyolog_ATLANIR))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // AZAMİ İŞ: otomatik dağıtım bir kişiyi boğmasın. Dolu radyologun
        //   kuralı atlanır, SONRAKİ kural denenir.
        var (kurum, radyologA, radyologB, sube) = await KurulumAsync(b, t);
        await KuralAcAsync(b, t, sube, 5, hedefTur: 2, hedefRadyolog: radyologA,
                           azamiIs: 1);
        await KuralAcAsync(b, t, sube, 10, hedefTur: 2, hedefRadyolog: radyologB);

        var ilk = await IstekAcAsync(b, t, kurum, sube, 1, "A-004");
        Assert.Equal(radyologA, await OneriAsync(b, t, ilk));

        // A'ya bir iş ver: artık azami dolu.
        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = @p1 where id = @p0",
            t, [ilk, radyologA], CancellationToken.None);

        var ikinci = await IstekAcAsync(b, t, kurum, sube, 1, "A-005");
        Assert.Equal(radyologB, await OneriAsync(b, t, ikinci));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Yedek_nobetci_EN_SONA_duser()
    {
        if (!_olgu.Baglandi(nameof(Yedek_nobetci_EN_SONA_duser))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Asıl nöbetçi varken yedeğe iş vermek çizelgeyi anlamsız kılar.
        var (kurum, radyologA, radyologB, sube) = await KurulumAsync(b, t);
        await NobetAcAsync(b, t, radyologA, sube, tur: 4);          // yedek
        await NobetAcAsync(b, t, radyologB, sube, tur: 2);          // gece (asıl)
        await KuralAcAsync(b, t, sube, 10, hedefTur: 1);

        var istek = await IstekAcAsync(b, t, kurum, sube, 1, "A-006");
        Assert.Equal(radyologB, await OneriAsync(b, t, istek));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Kural_uymazsa_is_SIRADA_kalir()
    {
        if (!_olgu.Baglandi(nameof(Kural_uymazsa_is_SIRADA_kalir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Uydurma atama YOK: nöbetçi yoksa iş sırada kalır ve listeye bakan
        //   kişi elle alır. "Bir yere ata da olsun" demek, işi görünmeyen bir
        //   kuyruğa göndermek olurdu.
        var (kurum, radyolog, _, sube) = await KurulumAsync(b, t);
        await KuralAcAsync(b, t, sube, 10, hedefTur: 1);            // nöbetçi yok
        var istek = await IstekAcAsync(b, t, kurum, sube, 1, "A-007");

        Assert.Null(await OneriAsync(b, t, istek));

        // ATANMIŞ İŞ YENİDEN DAĞITILMAZ: "yeniden atama" ayrı bir karardır.
        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = @p1 where id = @p0",
            t, [istek, radyolog], CancellationToken.None);
        Assert.Null(await OneriAsync(b, t, istek));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Ayni_radyolog_IKI_NOBETTE_olamaz()
    {
        if (!_olgu.Baglandi(nameof(Ayni_radyolog_IKI_NOBETTE_olamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Çizelge kendi içinde çelişirse "şu an kim nöbetçi" sorusunun iki
        //   cevabı olur.
        var (_, radyologA, _, sube) = await KurulumAsync(b, t);
        await NobetAcAsync(b, t, radyologA, sube);

        await b.CalistirAsync("savepoint sp_cakisma", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => NobetAcAsync(b, t, radyologA, sube, tur: 2));
        Assert.Equal("23505", h.SqlState);
        await b.CalistirAsync("rollback to savepoint sp_cakisma", t, [], CancellationToken.None);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Otomatik_atama_gecmise_OTOMATIK_diye_duser()
    {
        if (!_olgu.Baglandi(nameof(Otomatik_atama_gecmise_OTOMATIK_diye_duser))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 802: kartin kod listesinde duran "1 Otomatik (kural)" degerini
        //   yazan KIMSE YOKTU - otomatik dagitim gecmise "Elle" diye
        //   dusuyordu. Neden islem ayarindan okunur.
        var (kurum, radyolog, _, sube) = await KurulumAsync(b, t);
        var elle = await IstekAcAsync(b, t, kurum, sube, 1, "A-008");
        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = @p1 where id = @p0",
            t, [elle, radyolog], CancellationToken.None);

        var otomatik = await IstekAcAsync(b, t, kurum, sube, 1, "A-009");
        await b.CalistirAsync("select set_config('telerad.atama_nedeni', '1', true)",
            t, [], CancellationToken.None);
        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = @p1 where id = @p0",
            t, [otomatik, radyolog], CancellationToken.None);

        async Task<short> Neden(int istek) => await b.TekDegerAsync<short>(
            "select neden from public.telerad_atama where istek_id = @p0", t, [istek],
            CancellationToken.None);

        // AYAR YOKKEN ESKI DAVRANIS SURER: elle atama yapan ekranlar
        //   degismek zorunda kalmasin.
        Assert.Equal((short)2, await Neden(elle));
        Assert.Equal((short)1, await Neden(otomatik));

        await t.RollbackAsync();
    }

    [Fact]
    public void Cizelge_ve_kural_EKRANLARI_var()
    {
        // Tanım ekranları KURULUMUN yetkisiyle açılır - günlük işin
        //   (`telerad.ata`) değil: gece okuyan radyologa kural değiştirme
        //   hakkı vermeden atama hakkı verilebilsin.
        Assert.Equal("teleradyoloji.nobet", KaynakKatalogu.Bul("telerad-nobet")?.YetkiKodu);
        Assert.Equal("teleradyoloji.kural", KaynakKatalogu.Bul("telerad-kural")?.YetkiKodu);
        Assert.Equal("teleradyoloji.nobet", KartKatalogu.Bul("telerad-nobet")?.YetkiKodu);
        Assert.Equal("teleradyoloji.kural", KartKatalogu.Bul("telerad-kural")?.YetkiKodu);

        foreach (var ekran in new[] { "telerad-nobet-liste", "telerad-kural-liste" })
            Assert.True(AksiyonKatalogu.Ekran(ekran) is not null, ekran + " yok.");

        // OTOMATİK DAĞIT kayıt seçimi İSTEMEZ: işi tek tek seçtirmek "gece
        //   listeye bakan kimse yok" sorununu çözmezdi.
        var dagit = AksiyonKatalogu.Ekran("telerad-istek-liste")!
            .First(a => a.Kod == "telerad.dagit");
        Assert.False(dagit.KayitGerekir);
        Assert.Equal("telerad.ata", dagit.AksiyonYetkisi);

        // Kart alanlarının tamamı gruplu (boş "Genel" sekmesi açılmasın, 799).
        foreach (var ad in new[] { "telerad-nobet", "telerad-kural" })
            Assert.DoesNotContain(KartKatalogu.Bul(ad)!.Alanlar,
                a => a.Ad != "id" && string.IsNullOrEmpty(a.Grup));
    }
}

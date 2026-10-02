using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// HASTA AVANSI (779) — kullanıcı: *"hastadan alınan avans tahsilatı takibi
/// yapabilmeliyiz"*.
///
/// Ekranın tamamı `v_hasta_avans` görünümünün üç rakamına dayanıyor: ALINAN /
/// KULLANILAN / KALAN. Bu üçlü yanlışsa ekran yine "çalışır" ama hastaya
/// kasada olmayan parayı "kalan avansınız" diye söyler - ya da tersi, parası
/// duran hastadan ikinci kez tahsilat ister. Mantık SQL'de olduğu için tek
/// doğrulama yeri veritabanının kendisidir.
///
/// HER TEST KENDİ TRANSACTION'INDA ÇALIŞIR VE GERİ ALINIR: test verisi
/// (hasta, kasa işlemi, dağıtım) paylaşılan veritabanında iz bırakmaz - silme
/// sırası unutulduğunda yarım kalan satırlar başka testleri kırıyordu.
/// </summary>
public sealed class HastaAvansTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Tahsilat yönünde gerçek bir işlem türü (koda gömmek yerine).</summary>
    private static Task<int> TahsilatTuruAsync(NpgsqlConnection b, NpgsqlTransaction t)
        => b.TekDegerAsync<int>(
            "select kod from public.kasa_islem_turu where yon = 1 order by kod limit 1",
            t, [], CancellationToken.None);

    /// <summary>Test hastası + ona yazılmış bir tahsilat; ikisinin kimliği döner.</summary>
    private static async Task<(int HastaId, int IslemId)> AvansKurAsync(
        NpgsqlConnection b, NpgsqlTransaction t, decimal tutar, int damga, short grup = 101)
    {
        var tur = await TahsilatTuruAsync(b, t);
        // Sube VAR OLAN bir kayit olmali (fk_taraf_sube): kurulumda 0 numarali
        //   sube olmayabilir, ilk sube alinir.
        var subeId = await b.TekDegerAsync<int>(
            "select id from public.sube order by id limit 1", t, [], CancellationToken.None);
        var tarafId = await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, grup, durum, sube_id)
            values ('TEST AVANS', @p0, 1, @p1) returning id
            """, t, [grup, subeId], CancellationToken.None);
        var islemId = await b.TekDegerAsync<int>("""
            insert into public.kasa_islem
                   (tur, islem_tarihi, taraf_id, tutar, yerel_tutar, durum, avans, sube_id)
            values (@p0, current_date, @p1, @p2, @p2, 2, @p3, @p4) returning id
            """, t, [tur, tarafId, tutar, damga, subeId], CancellationToken.None);
        return (tarafId, islemId);
    }

    /// <summary>Avansı belgenin bir satırına dağıtır (mahsup).</summary>
    private static async Task DagitAsync(NpgsqlConnection b, NpgsqlTransaction t,
                                         int islemId, decimal tutar, short pay)
    {
        // Dağıtım BELGE SATIRINA bağlanır (321): var olan bir satır kullanılır,
        //   transaction geri alındığı için o satıra kalıcı bir şey yazılmaz.
        var satirId = await b.TekDegerAsync<int>(
            "select id from public.belge_satir order by id limit 1", t, [],
            CancellationToken.None);
        await b.CalistirAsync("""
            insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay, tutar)
            values (@p0, @p1, @p2, @p3)
            """, t, [islemId, satirId, pay, tutar], CancellationToken.None);
    }

    private static async Task<IDictionary<string, object>?> AvansSatiriAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int islemId)
    {
        var satirlar = await b.ListeAsync("""
            select a.alinan, a.kullanilan, a.kalan, a.durum_adi
              from public.v_hasta_avans a where a.kasa_islem_id = @p0
            """, t, [islemId], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);
        return satirlar.Count > 0 ? satirlar[0] : null;
    }

    [VtFact]
    public async Task Alinan_kullanilan_kalan_ve_durum()
    {
        if (!_olgu.Baglandi(nameof(Alinan_kullanilan_kalan_ve_durum))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (_, islemId) = await AvansKurAsync(b, t, 1000m, damga: 1);

        // 1) Hiç kullanılmamış: kalan = alınan, durum "Açık".
        var s = await AvansSatiriAsync(b, t, islemId);
        Assert.NotNull(s);
        Assert.Equal(1000m, Convert.ToDecimal(s!["alinan"]));
        Assert.Equal(0m, Convert.ToDecimal(s["kullanilan"]));
        Assert.Equal(1000m, Convert.ToDecimal(s["kalan"]));
        Assert.Equal("Açık", s["durum_adi"]?.ToString());

        // 2) Bir kısmı mahsup edildi.
        await DagitAsync(b, t, islemId, 400m, pay: 1);
        s = await AvansSatiriAsync(b, t, islemId);
        Assert.Equal(400m, Convert.ToDecimal(s!["kullanilan"]));
        Assert.Equal(600m, Convert.ToDecimal(s["kalan"]));
        Assert.Equal("Kısmen Kullanıldı", s["durum_adi"]?.ToString());

        // 3) Tamamı kullanıldı: DAMGALI avans listede KALIR - "bu avans nereye
        //    gitti" sorusu para bitince cevapsız kalmasın.
        await DagitAsync(b, t, islemId, 600m, pay: 2);
        s = await AvansSatiriAsync(b, t, islemId);
        Assert.NotNull(s);
        Assert.Equal(0m, Convert.ToDecimal(s!["kalan"]));
        Assert.Equal("Kullanıldı", s["durum_adi"]?.ToString());

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Bakiye_yalniz_KALANI_sayar()
    {
        if (!_olgu.Baglandi(nameof(Bakiye_yalniz_KALANI_sayar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (hastaId, islemId) = await AvansKurAsync(b, t, 1000m, damga: 1);
        await DagitAsync(b, t, islemId, 250m, pay: 1);

        var acik = await b.TekDegerAsync<decimal?>("""
            select b.acik_avans from public.v_hasta_avans_bakiye b where b.taraf_id = @p0
            """, t, [hastaId], CancellationToken.None);
        // Hasta şeridi bu rakamı gösteriyor: kullanılan kısım "duran para"
        //   değildir, toplam 1000 yazmak memura olmayan parayı gösterirdi.
        Assert.Equal(750m, acik ?? 0m);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Damgasiz_tahsilat_kapaninca_listeden_duser()
    {
        if (!_olgu.Baglandi(nameof(Damgasiz_tahsilat_kapaninca_listeden_duser))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Damgasız tahsilatın dağıtılmamış kısmı da avanstır (322 kuralı
        //   korunuyor); ama tamamı dağıtıldığında o sıradan bir başvuru
        //   tahsilatıdır - listede kalması her tahsilatı avans göstermek olurdu.
        var (_, islemId) = await AvansKurAsync(b, t, 500m, damga: 0);
        Assert.NotNull(await AvansSatiriAsync(b, t, islemId));

        await DagitAsync(b, t, islemId, 500m, pay: 1);
        Assert.Null(await AvansSatiriAsync(b, t, islemId));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Hasta_olmayan_carinin_avansi_listede_yok()
    {
        if (!_olgu.Baglandi(nameof(Hasta_olmayan_carinin_avansi_listede_yok))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Ekran KAYIT KABULÜN ekranı: tedarikçiye verilen/alınan avans oraya
        //   düşerse liste "hasta avansı" olmaktan çıkar.
        var (_, islemId) = await AvansKurAsync(b, t, 750m, damga: 1, grup: 1);
        Assert.Null(await AvansSatiriAsync(b, t, islemId));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Iptal_edilen_tahsilat_avans_sayilmaz()
    {
        if (!_olgu.Baglandi(nameof(Iptal_edilen_tahsilat_avans_sayilmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // İptal, ters kayıtla yapılır (076): para geri verilmiştir, kasada
        //   duran bir avans yoktur.
        var (_, islemId) = await AvansKurAsync(b, t, 300m, damga: 1);
        await b.CalistirAsync(
            "update public.kasa_islem set iptal_islem_id = id where id = @p0",
            t, [islemId], CancellationToken.None);

        Assert.Null(await AvansSatiriAsync(b, t, islemId));

        await t.RollbackAsync();
    }
}

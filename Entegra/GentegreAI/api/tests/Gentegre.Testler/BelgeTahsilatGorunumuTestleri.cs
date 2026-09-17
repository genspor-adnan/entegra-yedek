using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// BELGENİN TAHSİLAT LİSTESİ (781/782) — kullanıcı: *"avanstan kullan
/// dediğim zaman tahsilat türünün avans olması gerekir.. dün avans almışımdır
/// kasaya nakit girmiştir, bugün nakit girişi yok"*.
///
/// Mahsup yeni bir kasa işlemi açmaz (para zaten girmişti); belgenin tahsilat
/// listesi `v_belge_tahsilat` ile dağıtımdan okur. Bu testler o görünümün üç
/// sözünü tutar: avans satırı KENDİ türüyle (27) gelir, tutarı BU BELGEYE
/// dağıtılan kadardır, ve avansın kendi kasa işlemi listeye ikinci kez
/// düşmez.
/// </summary>
public sealed class BelgeTahsilatGorunumuTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Test için gerçek bir belge satırı (dağıtım ona bağlanır).</summary>
    private static async Task<(int BelgeId, int SatirId)> BelgeSatiriAsync(
        NpgsqlConnection b, NpgsqlTransaction t)
    {
        var satirlar = await b.ListeAsync(
            "select bs.id, bs.belge_id from public.belge_satir bs order by bs.id limit 1",
            t, [], o => (Id: o.GetInt32(0), BelgeId: o.GetInt32(1)), CancellationToken.None);
        Assert.Single(satirlar);
        return (satirlar[0].BelgeId, satirlar[0].Id);
    }

    private static async Task<(int Hasta, int Avans)> AvansAsync(
        NpgsqlConnection b, NpgsqlTransaction t, decimal tutar)
    {
        var tur = await b.TekDegerAsync<int>(
            "select kod from public.kasa_islem_turu where yon = 1 and aktif = 1 "
            + "order by kod limit 1", t, [], CancellationToken.None);
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube order by id limit 1", t, [], CancellationToken.None);
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, grup, durum, sube_id) "
            + "values ('TEST MAHSUP HASTA', 101, 1, @p0) returning id",
            t, [sube], CancellationToken.None);
        var avans = await b.TekDegerAsync<int>(
            "insert into public.kasa_islem "
            + "       (tur, islem_tarihi, taraf_id, tutar, yerel_tutar, durum, avans, sube_id) "
            + "values (@p0, current_date - 1, @p1, @p2, @p2, 2, 1, @p3) returning id",
            t, [tur, hasta, tutar, sube], CancellationToken.None);
        return (hasta, avans);
    }

    [Fact]
    public async Task Avans_mahsubu_KENDI_turuyle_ve_DAGITILAN_tutarla_gorunur()
    {
        if (!_olgu.Baglandi(nameof(Avans_mahsubu_KENDI_turuyle_ve_DAGITILAN_tutarla_gorunur)))
            return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (belgeId, satirId) = await BelgeSatiriAsync(b, t);
        var (_, avansId) = await AvansAsync(b, t, 1000m);

        // 1.000'lik avansın yalnız 250'si bu belgeye mahsup edildi.
        await b.CalistirAsync(
            "insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay, tutar) "
            + "values (@p0, @p1, 1, 250)", t, [avansId, satirId], CancellationToken.None);

        var satirlar = await b.ListeAsync(
            "select tur, tur_adi, tutar, hesap_adi, avans_kullanim "
            + "  from public.v_belge_tahsilat where belge_id = @p0 and kasa_islem_id = @p1",
            t, [belgeId, avansId], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);

        Assert.Single(satirlar);
        // TÜR 27: tür koduna bakan her yer (filtre, çip, döküm) bunu nakit
        //   tahsilat sayıyordu.
        Assert.Equal(27, Convert.ToInt32(satirlar[0]["tur"]));
        Assert.Contains("Avans", satirlar[0]["tur_adi"]?.ToString());
        // TUTAR: avansın tamamı (1.000) değil, bu belgeye sayılan kadarı.
        Assert.Equal(250m, Convert.ToDecimal(satirlar[0]["tutar"]));
        // HESAP BOŞ: bugün kasaya para girmedi.
        Assert.Equal("", satirlar[0]["hesap_adi"]?.ToString());
        Assert.Equal(1, Convert.ToInt32(satirlar[0]["avans_kullanim"]));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Avans_belgeye_baglansa_bile_IKI_KEZ_gorunmez()
    {
        if (!_olgu.Baglandi(nameof(Avans_belgeye_baglansa_bile_IKI_KEZ_gorunmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 322'den kalma kayıtlarda avansın `belge_id`si dolu olabilir. O
        //   satır listeye "Nakit Tahsilat · TAM tutar" olarak da düşerse aynı
        //   para iki kez tahsil edilmiş görünür.
        var (belgeId, satirId) = await BelgeSatiriAsync(b, t);
        var (_, avansId) = await AvansAsync(b, t, 400m);
        await b.CalistirAsync("update public.kasa_islem set belge_id = @p1 where id = @p0",
            t, [avansId, belgeId], CancellationToken.None);
        await b.CalistirAsync(
            "insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay, tutar) "
            + "values (@p0, @p1, 1, 400)", t, [avansId, satirId], CancellationToken.None);

        var satirlar = await b.ListeAsync(
            "select tur, tutar from public.v_belge_tahsilat "
            + " where belge_id = @p0 and kasa_islem_id = @p1",
            t, [belgeId, avansId], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);

        Assert.Single(satirlar);
        Assert.Equal(27, Convert.ToInt32(satirlar[0]["tur"]));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Normal_tahsilat_KENDI_turuyle_kalir()
    {
        if (!_olgu.Baglandi(nameof(Normal_tahsilat_KENDI_turuyle_kalir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Damgasız, belgeye bağlı tahsilat (nakit/POS) eskisi gibi görünür -
        //   avans düzeni onu değiştirmemeli.
        var (belgeId, _) = await BelgeSatiriAsync(b, t);
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube order by id limit 1", t, [], CancellationToken.None);
        var hesap = await b.TekDegerAsync<int>(
            "select id from public.hesap order by id limit 1", t, [], CancellationToken.None);
        var islemId = await b.TekDegerAsync<int>(
            "insert into public.kasa_islem "
            + "       (tur, islem_tarihi, tutar, yerel_tutar, durum, sube_id, belge_id, hesap_id) "
            + "values (21, current_date, 120, 120, 2, @p0, @p1, @p2) returning id",
            t, [sube, belgeId, hesap], CancellationToken.None);

        var satirlar = await b.ListeAsync(
            "select tur, tutar, avans_kullanim, hesap_adi from public.v_belge_tahsilat "
            + " where belge_id = @p0 and kasa_islem_id = @p1",
            t, [belgeId, islemId], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);

        Assert.Single(satirlar);
        Assert.Equal(21, Convert.ToInt32(satirlar[0]["tur"]));
        Assert.Equal(120m, Convert.ToDecimal(satirlar[0]["tutar"]));
        Assert.Equal(0, Convert.ToInt32(satirlar[0]["avans_kullanim"]));
        Assert.NotEqual("", satirlar[0]["hesap_adi"]?.ToString());

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Avans_turu_ELLE_secilemez_kasa_kartinda_cikmaz()
    {
        if (!_olgu.Baglandi(nameof(Avans_turu_ELLE_secilemez_kasa_kartinda_cikmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // 27 bir GÖSTERİM türüdür: kasa kartından seçilip işlem açılmamalı
        //   (aktif = 0), kasaya/bankaya dokunmamalı ve fiş kesmemeli - para
        //   avansın kendi işleminde zaten kasaya girdi ve fişi kesildi.
        var satirlar = await b.ListeAsync(
            "select aktif, ana_hesap_turu, bakiye_dahil, fis_mi, cari_etkiler, grup "
            + "  from public.kasa_islem_turu where kod = 27",
            null, [], o => (Aktif: o.GetInt16(0), Hesap: o.GetString(1), Bakiye: o.GetInt16(2),
                            Fis: o.GetInt16(3), Cari: o.GetInt16(4), Grup: o.GetString(5)),
            CancellationToken.None);
        Assert.Single(satirlar);
        var t = satirlar[0];

        Assert.Equal(0, t.Aktif);
        Assert.Equal("", t.Hesap);
        Assert.Equal(0, t.Bakiye);
        Assert.Equal(0, t.Fis);
        Assert.Equal(0, t.Cari);
        Assert.Equal("tahsilat", t.Grup);   // nakit/POS ile ayni raf (kullanici)
    }
}

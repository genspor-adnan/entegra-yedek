using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// GELEN RAPOR EŞLEŞTİRMESİ (817).
///
/// Mesajın çözümlenmesi ayrı sınanıyor (<see cref="OruCozumleyiciTestleri"/>);
/// burada sınanan, <b>hangi mesajın hangi işe oturduğu</b>: accession zorunlu,
/// SKRS/TCKN doğrulayıcı, birden çok aday varsa <b>hiçbiri</b>.
/// </summary>
public sealed class TeleradGelenTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static async Task<(int Kurum, int Sube)> KurumAsync(
        NpgsqlConnection b, NpgsqlTransaction t, string skrs)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var taraf = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('GELEN TEST KURUMU', @p1, 1, @p0) returning id",
            t, [sube, $"GLN{Guid.NewGuid().ToString("N")[..7]}"], Iptal);
        var kurum = await b.TekDegerAsync<int>("""
            insert into public.telerad_kurum (taraf_id, yon, sube_id, skrs_kodu)
            values (@p0, 2, @p1, @p2) returning id
            """, t, [taraf, sube, skrs], Iptal);
        return (kurum, sube);
    }

    private static Task<int> IstekAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int kurum, int sube, string accession, string tckn)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, dis_hasta_kimlik, oncelik, modalite,
                    sube_id, durum)
            values (@p0, @p2, @p3, 1, 1, @p1, 3) returning id
            """, t, [kurum, sube, accession, tckn], Iptal);

    private static Task<int?> EslesAsync(NpgsqlConnection b, NpgsqlTransaction t,
        string accession, string skrs, string tckn)
        => b.TekDegerAsync<int?>(
            "select public.fn_telerad_gelen_istek(@p0, @p1, @p2)",
            t, [accession, skrs, tckn], Iptal);

    [Fact]
    public async Task Accession_ve_skrs_ile_eslesir()
    {
        if (!_olgu.Baglandi(nameof(Accession_ve_skrs_ile_eslesir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var acc = Guid.NewGuid().ToString("N")[..12];
        var (kurum, sube) = await KurumAsync(b, t, "77001");
        var istek = await IstekAsync(b, t, kurum, sube, acc, "12345678901");

        Assert.Equal(istek, await EslesAsync(b, t, acc, "77001", ""));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Skrs_yoksa_tckn_dogrular()
    {
        if (!_olgu.Baglandi(nameof(Skrs_yoksa_tckn_dogrular))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var acc = Guid.NewGuid().ToString("N")[..12];
        var (kurum, sube) = await KurumAsync(b, t, "77002");
        var istek = await IstekAsync(b, t, kurum, sube, acc, "12345678901");

        Assert.Equal(istek, await EslesAsync(b, t, acc, "", "12345678901"));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Accession_bossa_eslesme_yok()
    {
        if (!_olgu.Baglandi(nameof(Accession_bossa_eslesme_yok))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Kılavuz § 5.2: accession eşitliği koşulsuz zorunlu.
        Assert.Null(await EslesAsync(b, null!, "", "77003", "12345678901"));
    }

    [Fact]
    public async Task Iki_aday_varsa_hicbiri_secilmez()
    {
        if (!_olgu.Baglandi(nameof(Iki_aday_varsa_hicbiri_secilmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // İKİ KURUM AYNI NUMARAYI KULLANABİLİR (numarayı onlar üretiyor).
        //   Yanlış hastanın raporunu yazmaktansa "eşleşmedi" demek yeğdir.
        var acc = Guid.NewGuid().ToString("N")[..12];
        var (k1, s1) = await KurumAsync(b, t, "77004");
        var (k2, s2) = await KurumAsync(b, t, "77005");
        await IstekAsync(b, t, k1, s1, acc, "11111111111");
        await IstekAsync(b, t, k2, s2, acc, "22222222222");

        Assert.Null(await EslesAsync(b, t, acc, "", ""));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Tek_aday_varsa_accession_yeter()
    {
        if (!_olgu.Baglandi(nameof(Tek_aday_varsa_accession_yeter))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var acc = Guid.NewGuid().ToString("N")[..12];
        var (kurum, sube) = await KurumAsync(b, t, "77006");
        var istek = await IstekAsync(b, t, kurum, sube, acc, "12345678901");

        // SKRS ve TCKN gelmedi ama tek aday var: kurum kodunu göndermeyen
        //   sistemlerde tek eşleşme yolu budur.
        Assert.Equal(istek, await EslesAsync(b, t, acc, "", ""));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Yanlis_skrs_tckn_ile_kurtarilir()
    {
        if (!_olgu.Baglandi(nameof(Yanlis_skrs_tckn_ile_kurtarilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var acc = Guid.NewGuid().ToString("N")[..12];
        var (kurum, sube) = await KurumAsync(b, t, "77007");
        var istek = await IstekAsync(b, t, kurum, sube, acc, "12345678901");

        // SKRS tutmadı ama TCKN tuttu: kimlik doğrulayıcı, engelleyici değil.
        Assert.Equal(istek, await EslesAsync(b, t, acc, "99999", "12345678901"));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Mukerrer_kontrol_no_yazilamaz()
    {
        if (!_olgu.Baglandi(nameof(Mukerrer_kontrol_no_yazilamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var no = Guid.NewGuid().ToString("N")[..16];
        await b.CalistirAsync(
            "insert into public.telerad_gelen (kontrol_no, durum) values (@p0, 1)",
            t, [no], Iptal);

        await b.CalistirAsync("savepoint sp", t, [], Iptal);
        // Karşı sistem ACK'i alamadığını sanıp aynı raporu tekrar gönderiyor.
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "insert into public.telerad_gelen (kontrol_no, durum) values (@p0, 1)",
            t, [no], Iptal));
        Assert.Equal("23505", h.SqlState);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Kontrol_nosuz_kayitlar_cakismaz()
    {
        if (!_olgu.Baglandi(nameof(Kontrol_nosuz_kayitlar_cakismaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Çözümlenemeyen mesajda kontrol numarası yoktur; benzersizlik kuralı
        //   onları kapsamaz, yoksa ikinci bozuk mesaj kaydedilemezdi.
        await b.CalistirAsync(
            "insert into public.telerad_gelen (kontrol_no, durum, ham) values ('', 0, 'x')",
            t, [], Iptal);
        await b.CalistirAsync(
            "insert into public.telerad_gelen (kontrol_no, durum, ham) values ('', 0, 'y')",
            t, [], Iptal);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Dinleme_portu_kapali_dogar()
    {
        if (!_olgu.Baglandi(nameof(Dinleme_portu_kapali_dogar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Rapor almayan kurulumda dinlenen bir kapı bırakılmaz.
        Assert.Equal("0", await b.TekDegerAsync<string>(
            "select deger from public.referans where anahtar = 'telerad.oru_port'",
            null, [], Iptal));
    }
}

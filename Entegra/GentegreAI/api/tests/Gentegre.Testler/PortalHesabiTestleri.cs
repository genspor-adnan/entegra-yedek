using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// PORTAL HESABI — KİŞİ BAŞI KURUM ERİŞİMİ (819).
///
/// Kullanıcı: *"1 ve 2'yi yap, kurum hesabı kişi başı olsun"*.
///
/// Kurum portalını kullanan bir İNSANDIR; hesap onun kaydında açılır ve
/// kapsam <c>portal_taraf_id</c> ile kuruma bağlanır. Paylaşımlı hesapta kim
/// ne yaptı bilinmez, biri ayrılınca parola herkes için değişirdi.
///
/// Testin koruduğu üç sınır: kapsam devri yalnız portal hesabında olur,
/// yalnız bir CARİ kuruma yapılır, kendi kaydına devir anlamsızdır.
/// </summary>
public sealed class PortalHesabiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static async Task<(int Kisi, int Kurum, int Sube)> ZeminAsync(
        NpgsqlConnection b, NpgsqlTransaction t)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var kisi = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, kisi, sube_id) "
            + "values ('PORTAL TEST KİŞİ', @p1, 1, @p0) returning id",
            t, [sube, $"PTK{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        var kurum = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('PORTAL TEST KURUM', @p1, 1, @p0) returning id",
            t, [sube, $"PTM{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        return (kisi, kurum, sube);
    }

    private static Task HesapAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int tarafId, int rolId, int? kapsam)
        => b.CalistirAsync("""
            insert into public.taraf_kullanici
                   (id, kod, parola_hash, rol_id, aktif, portal_taraf_id)
            values (@p0, @p1, '', @p2, 1, @p3)
            """, t, [tarafId, $"pt{Guid.NewGuid().ToString("N")[..10]}", rolId, kapsam], Iptal);

    private static Task<int> PortalRolAsync(NpgsqlConnection b, NpgsqlTransaction t, short tur)
        => b.TekDegerAsync<int>(
            "select id from public.rol where portal_turu = @p0 order by id limit 1",
            t, [tur], Iptal);

    [VtFact]
    public async Task Kurum_hesabi_kisinin_kaydinda_kapsam_kurumda()
    {
        if (!_olgu.Baglandi(nameof(Kurum_hesabi_kisinin_kaydinda_kapsam_kurumda))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kisi, kurum, _) = await ZeminAsync(b, t);
        await HesapAsync(b, t, kisi, await PortalRolAsync(b, t, 2), kurum);

        // Kapsam KURUMUN: `li.dis_kurum_id = {kullanici}` kuralına konan sayı budur.
        Assert.Equal(kurum, await b.TekDegerAsync<int>(
            "select public.fn_kullanici_portal_taraf(@p0)", t, [kisi], Iptal));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Devirsiz_hesapta_kapsam_kisinin_kendisi()
    {
        if (!_olgu.Baglandi(nameof(Devirsiz_hesapta_kapsam_kisinin_kendisi))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Dış hekim ve hastada kolon BOŞ kalır - davranış 794'teki gibi.
        var (kisi, _, _) = await ZeminAsync(b, t);
        await HesapAsync(b, t, kisi, await PortalRolAsync(b, t, 1), null);

        Assert.Equal(kisi, await b.TekDegerAsync<int>(
            "select public.fn_kullanici_portal_taraf(@p0)", t, [kisi], Iptal));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Kurum_ici_rolde_kapsam_devri_reddedilir()
    {
        if (!_olgu.Baglandi(nameof(Kurum_ici_rolde_kapsam_devri_reddedilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kisi, kurum, _) = await ZeminAsync(b, t);
        var icRol = await b.TekDegerAsync<int>(
            "select id from public.rol where coalesce(portal_turu, 0) = 0 order by id limit 1",
            t, [], Iptal);

        // Kurum içi bir hesaba kapsam devretmek, o kişiye BAŞKA bir tarafın
        //   kayıtlarını açardı.
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => HesapAsync(b, t, kisi, icRol, kurum));
        Assert.Contains("portal hesabında", h.MessageText, StringComparison.Ordinal);
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Kapsam_yalniz_cariye_devredilir()
    {
        if (!_olgu.Baglandi(nameof(Kapsam_yalniz_cariye_devredilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kisi, _, sube) = await ZeminAsync(b, t);
        var cariOlmayan = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, kisi, sube_id) "
            + "values ('PORTAL TEST KİŞİ 2', @p1, 1, @p0) returning id",
            t, [sube, $"PTX{Guid.NewGuid().ToString("N")[..8]}"], Iptal);

        var rol = await PortalRolAsync(b, t, 2);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => HesapAsync(b, t, kisi, rol, cariOlmayan));
        Assert.Contains("CARİ", h.MessageText, StringComparison.Ordinal);
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Kendi_kaydina_devir_bosa_dusurulur()
    {
        if (!_olgu.Baglandi(nameof(Kendi_kaydina_devir_bosa_dusurulur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kurumun KENDİ cari kaydında açılan hesapta devir anlamsız: kolonun
        //   boş hâli zaten bunu söylüyor.
        var (_, kurum, _) = await ZeminAsync(b, t);
        await HesapAsync(b, t, kurum, await PortalRolAsync(b, t, 2), kurum);

        Assert.Null(await b.TekDegerAsync<int?>(
            "select portal_taraf_id from public.taraf_kullanici where id = @p0",
            t, [kurum], Iptal));
        Assert.Equal(kurum, await b.TekDegerAsync<int>(
            "select public.fn_kullanici_portal_taraf(@p0)", t, [kurum], Iptal));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Portal_erisimi_ayri_yetkidir()
    {
        if (!_olgu.Baglandi(nameof(Portal_erisimi_ayri_yetkidir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Kurum içi hesap açma yetkisi bankoda birçok kişide var; dışarıya
        //   kapı açmak ayrı bir karar.
        Assert.Equal(1, await b.TekDegerAsync<int>(
            "select count(*) from public.yetki where kod = 'kullanici.portal'",
            null, [], Iptal));
    }
}

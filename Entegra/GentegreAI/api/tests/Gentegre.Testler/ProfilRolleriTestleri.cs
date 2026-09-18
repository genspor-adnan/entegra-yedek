using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// PROFİLE GÖRE GEÇERLİ ROLLER (786).
///
/// Kullanıcı: *"profili görüntüleme yaptım bütün roller görünüyor.. isg yaptım
/// yine bütün roller görünüyor.. böyle olmasın.. profil sayfasında altta her
/// bir profil için geçerli (aktif) rolleri işaretleyeyim.. üstte kaydet deyip
/// o profilin rollerine girince onlar geçerli olsun"*.
///
/// Haritayı `rol.aktif` alanına yazan TEK yer `fn_kurum_tipi_rol_uygula` -
/// API de, ileride bir betik de aynı duvara çarpsın. Buradaki testler o
/// fonksiyonun sözünü korur: haritada olmayana dokunma, kilitli rolü kapatma.
/// </summary>
public sealed class ProfilRolleriTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static Task HaritaYazAsync(NpgsqlConnection b, NpgsqlTransaction t,
                                       string tip, string kod, short gecerli)
        => b.CalistirAsync("""
            insert into public.kurum_tipi_rol (kurum_tipi, rol_kod, gecerli)
            values (@p0, @p1, @p2)
            on conflict (kurum_tipi, rol_kod) do update set gecerli = excluded.gecerli
            """, t, [tip, kod, gecerli], CancellationToken.None);

    private static Task<short> AktifAsync(NpgsqlConnection b, NpgsqlTransaction t, string kod)
        => b.TekDegerAsync<short>("select aktif from public.rol where kod = @p0",
                                  t, [kod], CancellationToken.None);

    [Fact]
    public async Task Harita_rol_aktifine_UYGULANIR()
    {
        if (!_olgu.Baglandi(nameof(Harita_rol_aktifine_UYGULANIR))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        await HaritaYazAsync(b, t, "test_tipi", "dis_hekimi", 0);
        await HaritaYazAsync(b, t, "test_tipi", "goz_hekimi", 1);
        await b.CalistirAsync("update public.rol set aktif = 1 where kod in ('dis_hekimi','goz_hekimi')",
                              t, [], CancellationToken.None);

        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('test_tipi')",
                              t, [], CancellationToken.None);

        Assert.Equal((short)0, await AktifAsync(b, t, "dis_hekimi"));   // işaretsiz -> pasif
        Assert.Equal((short)1, await AktifAsync(b, t, "goz_hekimi"));   // işaretli  -> aktif

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Haritada_OLMAYAN_role_dokunulmaz()
    {
        if (!_olgu.Baglandi(nameof(Haritada_OLMAYAN_role_dokunulmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kurumun kendi açtığı, hiçbir profile bağlanmamış rol: profil
        //   değişimi onu sessizce kapatmamalı.
        await b.CalistirAsync("update public.rol set aktif = 1 where kod = 'kalite'",
                              t, [], CancellationToken.None);
        await HaritaYazAsync(b, t, "test_tipi", "dis_hekimi", 0);

        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('test_tipi')",
                              t, [], CancellationToken.None);

        Assert.Equal((short)1, await AktifAsync(b, t, "kalite"));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Yonetici_ve_atanmamis_PASIFE_ALINAMAZ()
    {
        if (!_olgu.Baglandi(nameof(Yonetici_ve_atanmamis_PASIFE_ALINAMAZ))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Doğrudan yazma REDDEDİLİR: ikisi de kapanırsa kurum kendi sistemine
        //   giremez. Kural tetikte - ekran unutsa da tutar.
        foreach (var kod in new[] { "yonetici", "atanmamis" })
        {
            await b.CalistirAsync("savepoint sp_kilit", t, [], CancellationToken.None);
            var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
                "update public.rol set aktif = 0 where kod = @p0", t, [kod], CancellationToken.None));
            Assert.Equal("GK422", h.SqlState);
            await b.CalistirAsync("rollback to savepoint sp_kilit", t, [], CancellationToken.None);
        }

        // Harita 0 dese bile uygulama onları ATLAR: tek rol yüzünden bütün
        //   profil uygulaması durmasın.
        await HaritaYazAsync(b, t, "test_tipi", "yonetici", 0);
        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('test_tipi')",
                              t, [], CancellationToken.None);
        Assert.Equal((short)1, await AktifAsync(b, t, "yonetici"));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Bos_tip_reddedilir()
    {
        if (!_olgu.Baglandi(nameof(Bos_tip_reddedilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Tipsiz uygulama "hiçbir satır eşleşmedi" diye sessizce geçseydi,
        //   ekranın gönderdiği boş tip fark edilmeden kaybolurdu.
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "select public.fn_kurum_tipi_rol_uygula('')", t, [], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);

        await t.RollbackAsync();
    }
}

using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// PORTAL ROLLERİ KURUM PROFİLİ ROL HARİTASINDAN MUAF (829).
///
/// Kullanıcı: *"portal rollerini o listeden muaf tut"*.
///
/// <para>Canlı denemede görüldü: "Hastane" profilinde Kaydet'e basınca,
/// listede işaretlenmemiş olan <c>dis_istem_kurumu</c> pasife alındı - dış
/// kurumun klinik kullanıcıları bir anda giriş yapamaz oldu. Harita kurum
/// <b>içi kadroyu</b> anlatıyor; portal rolü kadro değil dışarıya açılan
/// kapıdır.</para>
///
/// <para>Kural üç katmanda: uygulama fonksiyonu portal rolüne dokunmaz,
/// haritaya portal satırı girmez, uç listesi portal rolünü göstermez. Bu
/// sınıf ilk ikisini (veritabanı tarafını) kilitler.</para>
/// </summary>
public sealed class PortalRolMuafiyetiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    [Fact(DisplayName = "Haritaya portal rolü yazılamaz")]
    public async Task Haritaya_portal_rolu_girmez()
    {
        if (!_olgu.Baglandi(nameof(Haritaya_portal_rolu_girmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var portalRol = await b.TekDegerAsync<string>(
            "select kod from public.rol where coalesce(portal_turu, 0) > 0 order by id limit 1",
            t, [], Iptal);
        Assert.NotNull(portalRol);

        await b.CalistirAsync(
            "insert into public.kurum_tipi_rol (kurum_tipi, rol_kod, gecerli, ekleyen) "
            + "values ('hastane', @p0, 0, 0)", t, [portalRol], Iptal);

        // Tetik satırı SESSİZCE atlar: toplu yazan çağrı tek satır yüzünden
        //   durmasın (hata fırlatsaydı profil kaydı komple düşerdi).
        Assert.Equal(0, await b.TekDegerAsync<long>(
            "select count(*) from public.kurum_tipi_rol "
            + " where kurum_tipi = 'hastane' and rol_kod = @p0", t, [portalRol], Iptal));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Harita uygulanınca portal rolü kapanmaz")]
    public async Task Uygulama_portal_rolunu_kapatmaz()
    {
        if (!_olgu.Baglandi(nameof(Uygulama_portal_rolunu_kapatmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Tetiği atlayarak ESKİ verinin taklidi: 829 öncesinde haritada böyle
        //   satırlar vardı ve uygulama onları rol.aktif'e yazıyordu.
        var portalRol = await b.TekDegerAsync<string>(
            "select kod from public.rol where coalesce(portal_turu, 0) > 0 and aktif = 1 "
            + "order by id limit 1", t, [], Iptal);
        Assert.NotNull(portalRol);
        await b.CalistirAsync("alter table public.kurum_tipi_rol disable trigger "
                              + "tg_kurum_tipi_rol_portal", t, [], Iptal);
        await b.CalistirAsync(
            "insert into public.kurum_tipi_rol (kurum_tipi, rol_kod, gecerli, ekleyen) "
            + "values ('hastane', @p0, 0, 0) "
            + "on conflict (kurum_tipi, rol_kod) do update set gecerli = 0",
            t, [portalRol], Iptal);
        await b.CalistirAsync("alter table public.kurum_tipi_rol enable trigger "
                              + "tg_kurum_tipi_rol_portal", t, [], Iptal);

        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('hastane')",
                              t, [], Iptal);

        Assert.Equal(1, await b.TekDegerAsync<short>(
            "select aktif from public.rol where kod = @p0", t, [portalRol], Iptal));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Kurum içi rol haritayla kapanmaya devam eder")]
    public async Task Ic_rol_hala_kapanir()
    {
        if (!_olgu.Baglandi(nameof(Ic_rol_hala_kapanir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Muafiyet portal rolüne özel: iç kadro listesi eskisi gibi çalışmalı,
        //   yoksa "bu profilde geçerli roller" ekranı anlamsızlaşırdı.
        var kod = $"tst{Guid.NewGuid().ToString("N")[..8]}";
        await b.CalistirAsync(
            "insert into public.rol (kod, ad, amac, aktif, sistem) values (@p0, @p0, '', 1, 0)",
            t, [kod], Iptal);
        await b.CalistirAsync(
            "insert into public.kurum_tipi_rol (kurum_tipi, rol_kod, gecerli, ekleyen) "
            + "values ('hastane', @p0, 0, 0)", t, [kod], Iptal);

        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('hastane')",
                              t, [], Iptal);

        Assert.Equal(0, await b.TekDegerAsync<short>(
            "select aktif from public.rol where kod = @p0", t, [kod], Iptal));
        await t.RollbackAsync();
    }
}

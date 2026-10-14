using Gentegre.Cekirdek;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// SUBE SAAT DILIMI (1097): veritabani oturumu istegin subesinin diliminde acilir
/// (VeriKaynagi, Saat.IstekDilimi) - current_date subenin gunu; saklanan an UTC.
/// Istek dilimi yoksa kurulus dilimi. fn_sube_zaman_dilimi bos / bilinmeyen subede
/// ilk aktif subenin dilimine, o da yoksa Europe/Istanbul'a duser.
/// </summary>
public sealed class SaatDilimiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Oturum_istegin_dilimiyle_acilir_an_ayni_kalir()
    {
        if (!_olgu.Baglandi(nameof(Oturum_istegin_dilimiyle_acilir_an_ayni_kalir))) return;
        var veri = _olgu.Gerekli();
        var ct = CancellationToken.None;

        Assert.Equal(Saat.EtkinDilimAdi, await veri.TekDegerAsync<string>("select current_setting('TimeZone')", null, ct));

        string? tokyo, gun;
        DateTime anTokyo;
        using (Saat.IstekDilimi("Asia/Tokyo"))
        {
            Assert.Equal("Asia/Tokyo", Saat.EtkinDilimAdi);
            tokyo = await veri.TekDegerAsync<string>("select current_setting('TimeZone')", null, ct);
            gun = await veri.TekDegerAsync<string>("select current_date::text", null, ct);
            anTokyo = await veri.TekDegerAsync<DateTime>("select timestamptz '2026-10-14 00:00:00+00'", null, ct);
            Assert.Equal(Saat.Bugun.ToString("yyyy-MM-dd"), gun);
        }
        Assert.Equal("Asia/Tokyo", tokyo);
        // Dispose eski dilimi geri koyar.
        Assert.NotEqual("Asia/Tokyo", Saat.EtkinDilimAdi);
        // Oturum dilimi okunan ANI değiştirmez.
        Assert.Equal(new DateTime(2026, 10, 14, 0, 0, 0, DateTimeKind.Utc), anTokyo.ToUniversalTime());
    }

    [VtFact]
    public async Task Sube_dilimi_tek_kaynaktan_bos_subede_varsayilana_duser()
    {
        if (!_olgu.Baglandi(nameof(Sube_dilimi_tek_kaynaktan_bos_subede_varsayilana_duser))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        var sube = await b.TekDegerAsync<int>("select min(id) from public.sube where aktif = 1", t, [], ct);
        await b.CalistirAsync("update public.sube set zaman_dilimi = 'Europe/Berlin' where id = @p0", t, [sube], ct);
        Assert.Equal("Europe/Berlin", await b.TekDegerAsync<string>("select public.fn_sube_zaman_dilimi(@p0)", t, [sube], ct));
        // Bilinmeyen şube: ilk aktif şubenin dilimi.
        Assert.Equal("Europe/Berlin", await b.TekDegerAsync<string>("select public.fn_sube_zaman_dilimi(-1)", t, [], ct));
        await b.CalistirAsync("update public.sube set zaman_dilimi = '' where aktif = 1", t, [], ct);
        Assert.Equal("Europe/Istanbul", await b.TekDegerAsync<string>("select public.fn_sube_zaman_dilimi(-1)", t, [], ct));
        await t.RollbackAsync();
    }
}

using Gentegre.Api.Servisler;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// İSKONTO TUTAR ONARIMI (1378, kullanıcı 18.11.2026: "evet onarım adımını hazırla"). Eski karar satıra yalnız oranı
/// yazıyordu; onarım KİLİTLİ ve tutarı hesabı tutmayan satırı kart kaydının hesabıyla düzeltir, eski hâli yedekler,
/// ikinci koşuda dokunacak şey bulmaz, belgeye dönüşmüş satırı atlar.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class IskontoTutarOnarimTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(int Belge, int Satir, int Talep)> EskiHataAsync(TestDunyasi d, int kullanici, int onayci)
    {
        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " hasta", Merkez]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var belge = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, belge_tarihi, taraf_id, durum, sube_id, genel_toplam)
            values (19, 30, now(), @p0, 0, @p1, 800) returning id
            """, [hasta, Merkez]);
        d.Temizle($"delete from public.belge where id = {belge}");
        var satir = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, miktar, adet, birim_fiyat, tutar, kdv, sube_id)
            values (@p0, 1, 2, 1, 1, 800, 800, 0, @p1) returning id
            """, [belge, Merkez]);
        d.Temizle($"delete from public.belge_satir where id = {satir}");
        d.Temizle($"delete from public._yedek_iskonto_tutar_1378 where belge_id = {belge}");
        d.Temizle($"delete from public.iskonto_talep where belge_id = {belge}");
        d.Temizle($"delete from public.iskonto_talep_satir where talep_id in (select id from public.iskonto_talep where belge_id = {belge})");
        var talep = await api.Veri.TekDegerAsync<int>("""
            insert into public.iskonto_talep (belge_id, sube_id, oran, gerekce, durum, isteyen_id, ekleyen)
            values (@p0, @p1, 25, 'test', 0, @p2, @p2) returning id
            """, [belge, Merkez, kullanici]);
        await api.Veri.CalistirAsync("""
            insert into public.iskonto_talep_satir (talep_id, belge_satir_id, birim_fiyat, onceki_iskonto, oran)
            values (@p0, @p1, 800, 0, 25)
            """, [talep, satir]);
        // ESKİ HATA: karar fonksiyonu yalnız oranı yazar -> iskonto 25, kilit 1, tutar hâlâ 800.
        await api.Veri.CalistirAsync("select public.fn_iskonto_talep_karar(@p0, 1::smallint, 25, 'ok', @p1)", [talep, onayci]);
        return (belge, satir, talep);
    }

    [VtFact]
    public async Task Kilitli_tutarsiz_satir_duzelir_yedeklenir_ikinci_kosu_dokunmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("o", "belge:g");
        var (u1, _) = await d.KullaniciAsync(rol, Merkez);
        var (u2, _) = await d.KullaniciAsync(rol, Merkez);
        var (belge, satir, _) = await EskiHataAsync(d, u1, u2);
        Assert.Equal(800m, await api.Veri.TekDegerAsync<decimal>("select tutar from public.belge_satir where id = @p0", [satir]));

        var depo = new BelgeDeposu(api.Veri, new LogDeposu());
        var (onarilan, _) = await IskontoTutarOnarici.OnarAsync(api.Veri, depo, NullLogger.Instance, CancellationToken.None);
        Assert.True(onarilan >= 1);
        Assert.Equal("600.00/1/25.0000", await api.Veri.TekDegerAsync<string>(
            "select round(tutar, 2)::text || '/' || iskonto_kilit || '/' || iskonto::text from public.belge_satir where id = @p0", [satir]));
        Assert.Equal(600m, await api.Veri.TekDegerAsync<decimal>("select genel_toplam from public.belge where id = @p0", [belge]));
        Assert.Equal("800/800", await api.Veri.TekDegerAsync<string>("""
            select round(eski_tutar)::text || '/' || round(eski_genel_toplam)::text
              from public._yedek_iskonto_tutar_1378 where belge_satir_id = @p0
            """, [satir]));

        // İkinci koşu: bu satır artık tutarlı - yedeğe ikinci kayıt düşmez.
        await IskontoTutarOnarici.OnarAsync(api.Veri, depo, NullLogger.Instance, CancellationToken.None);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public._yedek_iskonto_tutar_1378 where belge_satir_id = @p0", [satir]));
    }

    [VtFact]
    public async Task Belgeye_donusmus_satir_atlanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("o", "belge:g");
        var (u1, _) = await d.KullaniciAsync(rol, Merkez);
        var (u2, _) = await d.KullaniciAsync(rol, Merkez);
        var (_, satir, _) = await EskiHataAsync(d, u1, u2);
        await api.Veri.CalistirAsync("update public.belge_satir set kapatilan_miktar = 1 where id = @p0", [satir]);

        await IskontoTutarOnarici.OnarAsync(api.Veri, new BelgeDeposu(api.Veri, new LogDeposu()),
            NullLogger.Instance, CancellationToken.None);
        Assert.Equal(800m, await api.Veri.TekDegerAsync<decimal>("select tutar from public.belge_satir where id = @p0", [satir]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public._yedek_iskonto_tutar_1378 where belge_satir_id = @p0", [satir]));
    }

    /// <summary>
    /// Kod inceleme 18.11.2026: T1 talebi A ve B satırlarını kapsıyor, B sonradan T2 ile yeniden onaylanıp fişe
    /// dönüşmüş. A'nın tutarı yanlış olsa da T1 ATLANIR - yenileme talebin bütün satırlarını yazar, B'ye dokunulmamalı.
    /// </summary>
    [VtFact]
    public async Task Talebin_baska_satiri_donusmusse_talep_atlanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("o", "belge:g");
        var (u1, _) = await d.KullaniciAsync(rol, Merkez);
        var (u2, _) = await d.KullaniciAsync(rol, Merkez);
        var (belge, a, t1) = await EskiHataAsync(d, u1, u2);
        var b = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, miktar, adet, birim_fiyat, tutar, kdv, sube_id)
            values (@p0, 2, 2, 1, 1, 800, 800, 0, @p1) returning id
            """, [belge, Merkez]);
        d.Temizle($"delete from public.belge_satir where id = {b}");
        // T1 B'yi de kapsar (A ile aynı karar); sonra T2 B'yi yeniden onaylar ve B fişe dönüşür.
        await api.Veri.CalistirAsync("""
            insert into public.iskonto_talep_satir (talep_id, belge_satir_id, birim_fiyat, onceki_iskonto, oran)
            values (@p0, @p1, 800, 0, 25)
            """, [t1, b]);
        var t2 = await api.Veri.TekDegerAsync<int>("""
            insert into public.iskonto_talep (belge_id, sube_id, oran, gerekce, durum, isteyen_id, ekleyen)
            values (@p0, @p1, 30, 'test2', 0, @p2, @p2) returning id
            """, [belge, Merkez, u1]);
        await api.Veri.CalistirAsync("""
            insert into public.iskonto_talep_satir (talep_id, belge_satir_id, birim_fiyat, onceki_iskonto, oran)
            values (@p0, @p1, 800, 0, 30)
            """, [t2, b]);
        await api.Veri.CalistirAsync("select public.fn_iskonto_talep_karar(@p0, 1::smallint, 30, 'ok', @p1)", [t2, u2]);
        await api.Veri.CalistirAsync("update public.belge_satir set kapatilan_miktar = 1 where id = @p0", [b]);

        await IskontoTutarOnarici.OnarAsync(api.Veri, new BelgeDeposu(api.Veri, new LogDeposu()),
            NullLogger.Instance, CancellationToken.None);
        Assert.Equal(800m, await api.Veri.TekDegerAsync<decimal>("select tutar from public.belge_satir where id = @p0", [a]));
        Assert.Equal(800m, await api.Veri.TekDegerAsync<decimal>("select tutar from public.belge_satir where id = @p0", [b]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public._yedek_iskonto_tutar_1378 where belge_id = @p0", [belge]));
    }
}

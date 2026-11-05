using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// KURUŞ FARKI KAPATMA (1269): işlem türleri 60 (gider: cari alacak + masraf borç) ve 62 (gelir: cari borç +
/// hizmet alacak) kasa motorunda bacak üretir, kesinleşir ve carinin TL bakiyesini sıfırlar; ayarlar ve aksiyon
/// yetkisi tanımlıdır. İşlem içinde, geri alınır.
/// </summary>
public sealed class KurusFarkiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Kurus_farki_turleri_bakiyeyi_sifirlar()
    {
        if (!_olgu.Baglandi(nameof(Kurus_farki_turleri_bakiyeyi_sifirlar))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        Assert.Equal(2L, await b.TekDegerAsync<long>(
            "select count(*) from public.kasa_islem_turu where kod in (60, 62) and aktif = 1 and cari_etkiler = 1", t, [], ct));
        Assert.Equal(1L, await b.TekDegerAsync<long>("select count(*) from public.yetki where kod = 'finans.kurus_kapat' and tur = 1", t, [], ct));
        Assert.Equal(3L, await b.TekDegerAsync<long>(
            "select count(*) from public.referans where anahtar in ('cari.icmal_esik', 'cari.kurus_gider_id', 'cari.kurus_gelir_id')", t, [], ct));

        var sube = await b.TekDegerAsync<int>("select id from public.sube order by varsayilan desc, id limit 1", t, [], ct);
        var masraf = await b.TekDegerAsync<int?>("select id from public.masraf order by id limit 1", t, [], ct);
        var hizmet = await b.TekDegerAsync<int?>("select id from public.hizmet order by id limit 1", t, [], ct);
        Assert.NotNull(masraf); Assert.NotNull(hizmet);

        // Borçlu cari (müşteri bize 0,03 borçlu): 60 ile kapanır.
        var borclu = await b.TekDegerAsync<int>("""
            insert into public.taraf (kod, unvan, musteri, durum, sube_id) values ('KRS-B', 'Kuruş Borçlu', 1, 1, @p0) returning id
            """, t, [sube], ct);
        await b.CalistirAsync("""
            insert into public.mali_hareket (tur, hesap_turu, taraf_id, islem_tarihi, borc, alacak, yerel_borc, yerel_alacak,
                                             doviz_cinsi, doviz_kuru, durum, ekstrede_kullan, sube_id, ekleyen)
            values (15, 'C', @p0, now() - interval '10 day', 0.03, 0, 0.03, 0, 'TL', 1, 1, 1, @p1, 0)
            """, t, [borclu, sube], ct);
        var isl = await b.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, tutar, doviz_cinsi, doviz_kuru, yerel_tutar, masraf_id,
                                           aciklama, sube_id, ekleyen, durum)
            values (60, now(), @p0, 0.03, 'TL', 1, 0.03, @p1, 'Kuruş farkı testi', @p2, 0, 0) returning id
            """, t, [borclu, masraf, sube], ct);
        await b.CalistirAsync("select public.fn_kasa_islem_bacak_uret(@p0)", t, [isl], ct);
        await b.CalistirAsync("select public.fn_kasa_islem_kesinlestir(@p0, 0)", t, [isl], ct);
        Assert.Equal(2L, await b.TekDegerAsync<long>("select count(*) from public.mali_hareket where kasa_islem_id = @p0", t, [isl], ct));
        Assert.Equal(0.03m, await b.TekDegerAsync<decimal>(
            "select yerel_alacak from public.mali_hareket where kasa_islem_id = @p0 and rol = 'cari'", t, [isl], ct));
        Assert.Equal(0.03m, await b.TekDegerAsync<decimal>(
            "select yerel_borc from public.mali_hareket where kasa_islem_id = @p0 and rol = 'masraf'", t, [isl], ct));
        Assert.Equal(0m, await b.TekDegerAsync<decimal>("select coalesce(bakiye, 0) from public.v_cari_ozet where taraf_id = @p0", t, [borclu], ct));

        // Alacaklı cari (biz 0,02 borçluyuz): 62 ile kapanır.
        var alacakli = await b.TekDegerAsync<int>("""
            insert into public.taraf (kod, unvan, musteri, durum, sube_id) values ('KRS-A', 'Kuruş Alacaklı', 1, 1, @p0) returning id
            """, t, [sube], ct);
        await b.CalistirAsync("""
            insert into public.mali_hareket (tur, hesap_turu, taraf_id, islem_tarihi, borc, alacak, yerel_borc, yerel_alacak,
                                             doviz_cinsi, doviz_kuru, durum, ekstrede_kullan, sube_id, ekleyen)
            values (22, 'C', @p0, now() - interval '10 day', 0, 0.02, 0, 0.02, 'TL', 1, 1, 1, @p1, 0)
            """, t, [alacakli, sube], ct);
        var isl2 = await b.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, tutar, doviz_cinsi, doviz_kuru, yerel_tutar, hizmet_id,
                                           aciklama, sube_id, ekleyen, durum)
            values (62, now(), @p0, 0.02, 'TL', 1, 0.02, @p1, 'Kuruş farkı testi', @p2, 0, 0) returning id
            """, t, [alacakli, hizmet, sube], ct);
        await b.CalistirAsync("select public.fn_kasa_islem_bacak_uret(@p0)", t, [isl2], ct);
        await b.CalistirAsync("select public.fn_kasa_islem_kesinlestir(@p0, 0)", t, [isl2], ct);
        Assert.Equal(0.02m, await b.TekDegerAsync<decimal>(
            "select yerel_borc from public.mali_hareket where kasa_islem_id = @p0 and rol = 'cari'", t, [isl2], ct));
        Assert.Equal(0.02m, await b.TekDegerAsync<decimal>(
            "select yerel_alacak from public.mali_hareket where kasa_islem_id = @p0 and rol = 'kalem'", t, [isl2], ct));
        Assert.Equal(0m, await b.TekDegerAsync<decimal>("select coalesce(bakiye, 0) from public.v_cari_ozet where taraf_id = @p0", t, [alacakli], ct));
    }
}

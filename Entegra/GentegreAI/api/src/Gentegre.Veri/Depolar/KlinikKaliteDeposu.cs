namespace Gentegre.Veri.Depolar;

/// <summary>Dönem hesaplamasının özeti (713 motorunun döndürdüğü sayaçlar).</summary>
public sealed record KlinikHesapSonucu(int Yazilan, int Atlanan, int Kodsuz, int SureMs);

/// <summary>Bir göstergenin tek dönem önizlemesi - yazmadan.</summary>
public sealed record KlinikGostergeOnizleme(
    decimal Pay, decimal Payda, string Durum, string Aciklama);

/// <summary>
/// Klinik Kalite hesaplama motoruna (db/713) giden tek kapı.
///
/// HESAP SQL'DE, BURADA DEĞİL. Depo yalnız fonksiyonu çağırır: pay/payda
/// mantığı C#'a taşınsaydı aynı formül iki yerde olur ve gece işi ile ekrandan
/// tetiklenen hesap zamanla ayrışırdı.
/// </summary>
public sealed class KlinikKaliteDeposu
{
    private readonly VeriKaynagi _veri;

    public KlinikKaliteDeposu(VeriKaynagi veri) => _veri = veri;

    /// <summary>Dönemin tüm otomatik göstergelerini hesaplar ve yazar.</summary>
    public async Task<KlinikHesapSonucu> DonemHesaplaAsync(
        int subeId, short yil, short donemNo, short periyot, int kullaniciId,
        CancellationToken iptal = default)
    {
        var s = await _veri.TekAsync(
            "select yazilan, atlanan, kodsuz, sure_ms" +
            "  from public.fn_klinik_donem_hesapla(@p0, @p1, @p2, @p3, @p4)",
            new object?[] { subeId, yil, donemNo, periyot, kullaniciId },
            r => new KlinikHesapSonucu(
                r.GetInt32(0), r.GetInt32(1), r.GetInt32(2), r.GetInt32(3)),
            iptal);
        return s ?? new KlinikHesapSonucu(0, 0, 0, 0);
    }

    /// <summary>
    /// Tek göstergeyi ÖNİZLER - `klinik_gosterge_donem`e yazmaz. Kullanıcı
    /// kesinleştirmeden önce "bu gösterge niye böyle çıktı" diye bakabilsin
    /// diye ayrı uç; yazan yolu önizleme için kullanmak, taslak satırları
    /// kirletirdi.
    /// </summary>
    public async Task<KlinikGostergeOnizleme?> GostergeOnizleAsync(
        int gostergeId, int subeId, short yil, short donemNo, short periyot,
        CancellationToken iptal = default)
        => await _veri.TekAsync(
            "select h.pay, h.payda, h.durum, h.aciklama" +
            "  from public.fn_klinik_donem_araligi(@p0, @p1, @p2) a," +
            "       public.fn_klinik_gosterge_hesapla(@p3, @p4, a.bas, a.son) h",
            new object?[] { yil, donemNo, periyot, gostergeId, subeId },
            r => new KlinikGostergeOnizleme(
                r.GetDecimal(0), r.GetDecimal(1), r.GetString(2), r.GetString(3)),
            iptal);

    /// <summary>
    /// Dönemi kesinleştirir: satırlar bir daha hesaplanmaz. Tek yön - geri
    /// alma yok, çünkü Bakanlığa gönderilen sayının sonradan değişmesi
    /// geri bildirim raporlarıyla kurum kaydı arasında açıklanamayan fark
    /// üretir.
    /// </summary>
    public Task<int> DonemKesinlestirAsync(
        int subeId, short yil, short donemNo, short periyot, int kullaniciId,
        CancellationToken iptal = default)
        => _veri.CalistirAsync(
            "update public.klinik_gosterge_donem" +
            "   set durum = 1, degistiren = @p4, degistirme_tarihi = now()" +
            " where sube_id = @p0 and donem_yil = @p1 and donem_no = @p2" +
            "   and periyot = @p3 and durum = 0",
            new object?[] { subeId, yil, donemNo, periyot, kullaniciId },
            iptal);
}

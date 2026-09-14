namespace Gentegre.Veri.Depolar;

/// <summary>
/// KULLANICI TERCIHLERI (397): anahtar/deger, kullanici basina.
///
/// Deger istemcinin yazdigi JSON metnidir; sunucu icerigini YORUMLAMAZ - menu
/// favorileri gibi tamamen arayuze ait bir liste icin sema uydurmak, her yeni
/// tercihte gocu zorunlu kilardi. Yazilabilir anahtarlar beyaz listeli:
/// tablonun sinirsiz anahtarla cop kutusuna donmesi engellenir.
/// </summary>
public sealed class TercihDeposu
{
    private readonly VeriKaynagi _veri;
    public TercihDeposu(VeriKaynagi veri) => _veri = veri;

    /// <summary>Yazilabilen tercih anahtarlari - baskasi 400 ile reddedilir.</summary>
    public static readonly IReadOnlySet<string> Anahtarlar =
        new HashSet<string>(StringComparer.Ordinal)
        {
            "favoriler", "sonMenuler",
            // Kullanici Ayarlari (669). HESAPTA saklanirlar, tarayicida degil:
            //   kisi hangi cihazdan girerse girsin ayni duzeni bulur. TEMA
            //   bilerek DISARIDA - o cihaza aittir (poliklinikte gunduz,
            //   evde gece) ve localStorage'da kalir.
            "gorunum",   // {yogunluk, listeSatir, acilisEkrani}
            "bildirim",  // {olaylar:{<kod>:{zil,masaustu}}, sessiz:{...}}
        };

    /// <summary>Bir degerin ust siniri: favori listesi birkac yuz bayttir.</summary>
    public const int EnFazlaUzunluk = 8000;

    private const string ListeSql = """
        select anahtar, deger from public.kullanici_tercih
         where kullanici_id = @p0
        """;

    private const string YazSql = """
        insert into public.kullanici_tercih (kullanici_id, anahtar, deger)
        values (@p0, @p1, @p2)
        on conflict (kullanici_id, anahtar)
        do update set deger = excluded.deger, degistirme_tarihi = now()
        """;

    /// <summary>Kullanicinin tum tercihleri: anahtar -> deger.</summary>
    public async Task<Dictionary<string, string>> OkuAsync(
        int kullaniciId, CancellationToken iptal = default)
    {
        var satirlar = await _veri.ListeAsync(ListeSql, new object?[] { kullaniciId },
            o => (Anahtar: o.GetString(0), Deger: o.GetString(1)), iptal);
        var sonuc = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var s in satirlar) sonuc[s.Anahtar] = s.Deger;
        return sonuc;
    }

    public Task YazAsync(int kullaniciId, string anahtar, string deger,
                         CancellationToken iptal = default)
        => _veri.CalistirAsync(YazSql, new object?[] { kullaniciId, anahtar, deger }, iptal);
}

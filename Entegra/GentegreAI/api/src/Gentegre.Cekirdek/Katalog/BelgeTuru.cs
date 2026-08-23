namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BELGE TURU DAVRANISI — sunucu tarafinin tek dogruluk kaynagi.
///
/// Kodlar <c>kasa_islem_turu</c> katalogundaki (grup='belge') kod uzayidir.
/// Turun VERI etkisi (stok/cari/fis uretir mi) katalogda, ORADAN okunur;
/// burada yalnizca koda gomulu olmasi gereken YAPISAL kararlar durur:
/// stok yonu, hangi depo alani, numarayi kim uretir, hangi alanlar zorunlu.
///
/// Arayuz karsiligi: web/src/sayfalar/belgeTuru.ts (ayni gruplar).
/// </summary>
public static class BelgeTuru
{
    // ------------------------------------------------------------- gruplar ---
    /// <summary>Stok CIKISI yonundeki turler.</summary>
    private static readonly HashSet<int> CikisTurleri =
        new() { 14, 15, 16, 119, 29, 105, 133, 4 };

    /// <summary>Depolar arasi transfer: TEK satir iki depoyu birden oynatir.</summary>
    public const int Transfer = 20;

    /// <summary>Stoktan talep: stok/cari ETKILEMEZ, karsilanmasi transferle olur.</summary>
    public const int Talep = 105;

    /// <summary>Stok fisleri: 3 giris / 4 cikis - carisiz, muhasebe fisi uretir.</summary>
    private static readonly HashSet<int> StokFisleri = new() { 3, 4 };

    /// <summary>
    /// Numarasi BIZDE degil KARSI TARAFTA uretilen turler. Alis faturasinin
    /// numarasi tedarikcinindir: harf/tire icerebilir, bizim sayacimizla
    /// iliskisi yoktur (sayac tohumu eski veriden geldigi icin
    /// "3012026000357895" gibi anlamsiz numaralar uretiyordu).
    ///
    /// Alis irsaliyesi (10) ve alis fisi (12) DISARIDA: sayaclari temiz
    /// calisiyor; istenirse buraya eklenir.
    /// </summary>
    private static readonly HashSet<int> DisNumaraliTurler = new() { 11 };

    // -------------------------------------------------------------- sorular ---
    /// <summary>
    /// Stok CIKISI mi? Cari tarafi olan turlerde ayni zamanda "satis" demektir
    /// (cari BORCLANIR); cikis fisinde (4) cari yoktur, yalniz stok yonunu verir.
    /// </summary>
    public static bool CikisMi(int tur) => CikisTurleri.Contains(tur);

    public static bool TransferMi(int tur) => tur == Transfer;

    public static bool TalepMi(int tur) => tur == Talep;

    public static bool StokFisiMi(int tur) => StokFisleri.Contains(tur);

    public static bool DisNumarali(int tur) => DisNumaraliTurler.Contains(tur);

    /// <summary>
    /// Bu turde belge basliginda hangi depo alani doldurulur:
    /// cikis yonlu belge cikis deposunu, giris yonlu giris deposunu kullanir.
    /// Transferde IKISI de dolar - ayri ele alinir (bkz. StokDurumGuncelle).
    /// </summary>
    public static string DepoAlani(int tur) => CikisMi(tur) ? "cikisDepoId" : "girisDepoId";
}

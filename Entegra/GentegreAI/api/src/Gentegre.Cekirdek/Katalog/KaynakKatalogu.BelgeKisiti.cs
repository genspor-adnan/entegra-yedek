namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BELGE TÜRÜ YETKİ KISITI (998 — kullanıcı 09.10.2026: "yetki matrisinde
/// neler varsa onlar menüde görünmeli", ardından "o süzmeyi de yap").
///
/// <c>belge</c> TEK kaynaktır: Başvurular, Satış Faturaları, Alış Siparişleri,
/// Satış Teklifleri hepsi aynı tabloya <c>tur</c> süzgeciyle bakar. Yetki de
/// tek koddu (<c>belge</c>), yani kayıt kabul memuruna başvuru açtırmak için
/// satış ve alış belgelerinin tamamı da açılıyordu.
///
/// 998'de menü kodları bölündü (<c>belge.satis</c> / <c>belge.alis</c> /
/// <c>belge.stok</c>). Ama menüden düşen ekran, adresi bilen kullanıcı için
/// açık kalıyordu: kaynak yetkisi hâlâ <c>belge</c>. Burası o deliği kapatır -
/// yetkisi olmayan TÜR hiç dönmez. Satır yanıttan sonradan silinmez; sayım ve
/// toplamlar da aynı koşulu taşır (SorguUretici üç sorguyu aynı kurucudan
/// üretiyor), yoksa sayfa "12 kayıt" der, grid 3 satır çizerdi.
///
/// ÇEKİRDEK YETKİ TÜRE DEĞİL <c>tipi</c>'YE BAKAR. Tür 19 iki anlamlıdır
/// (HBYS başvurusu ile ERP satış siparişi aynı tür, ayıran <c>tipi</c>: 30 /
/// 1 — bkz. listeTanimlari.Klinik "BASVURU ile SATIS SIPARISI ayni turdur").
/// Ama iş akışı türde bitmiyor: başvurudan kesilen hasta fişi (16) ve
/// tahakkuku (17) de <c>tipi = 30</c> taşır. Çekirdeği yalnız tür 19'a
/// bağlamak kayıt kabul memurunun kendi hastasının fişini kapatırdı - dev
/// veritabanında tipi 30'un türleri 16, 17 ve 19.
///
/// Kural: <c>tipi = 30</c> başvuru bağlamıdır ve çekirdek <c>belge</c>
/// yetkisi onu açar; ERP ticari belgeleri (tipi 1 normal, 2 iade) kendi
/// kümelerinin kodunu ister.
///
/// Kısıt kaynak kaydının alanı değil ayrı harita - tetkik ve hekim
/// kısıtlarındaki gerekçenin aynısı: kaynak kaydı sık dokunulan ortak dosya.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Belge kümesi izni: yetki kodundan türetilen mantıksal ad.</summary>
    public const string BelgeKumeBasvuru = "basvuru";
    public const string BelgeKumeSatis   = "satis";
    public const string BelgeKumeAlis    = "alis";
    public const string BelgeKumeStok    = "stok";

    /// <summary>
    /// Başvuru bağlamı belge TİPİ: başvuru ve ondan türeyen hasta belgeleri
    /// (fiş, tahakkuk) bu tipi taşır. ERP ticari belgesi 1 (normal) / 2 (iade).
    /// </summary>
    public const int BelgeTipiBasvuru = 30;

    /// <summary>
    /// Küme -> o kümeye ait belge türleri. Türler Delphi'den gelen sabit
    /// kodlardır (listeTanimlari'ndaki `sabitFiltre`/`yeniBelgeTuru` ile
    /// birebir): 9-13/109 alış, 14-19/119 satış, 3/4/20/105 stok fişleri.
    /// </summary>
    private static readonly Dictionary<string, int[]> BelgeKumeTurleri =
        new(StringComparer.Ordinal)
    {
        // Satış: teklif 18, sipariş 19, irsaliye 14, fatura 15, fiş 16,
        //   tahakkuk 17, konsinye 119.
        [BelgeKumeSatis] = new[] { 14, 15, 16, 17, 18, 19, 119 },
        // Alış: sipariş 9, irsaliye 10, fatura 11, fiş 12, tahakkuk 13,
        //   konsinye 109.
        [BelgeKumeAlis]  = new[] { 9, 10, 11, 12, 13, 109 },
        // Stok: giriş 3, çıkış 4, transfer 20, talep 105.
        [BelgeKumeStok]  = new[] { 3, 4, 20, 105 },
    };

    /// <summary>
    /// Tür kısıtı uygulanan kaynaklar: (tür kolonu, tip kolonu). Yalnız çok
    /// türlü <c>belge</c> kaynağı; tek türlü kaynaklar (irsaliye, stok fişi,
    /// açık satır) kendi yetki kodunu taşır, onlarda satır süzmesi gereksiz.
    /// </summary>
    private static readonly Dictionary<string, (string Tur, string Tipi)> BelgeKisitKolonlari =
        new(StringComparer.Ordinal)
    {
        ["belge"] = ("b.tur", "b.tipi"),
    };

    /// <summary>Kaynakta belge türü kısıtı uygulanacak kolonlar; yoksa null.</summary>
    public static (string Tur, string Tipi)? BelgeKisitKolonu(string kaynakAdi)
        => BelgeKisitKolonlari.TryGetValue(kaynakAdi, out var k) ? k : null;

    /// <summary>Kümenin belge türleri; bilinmeyen küme için boş dizi.</summary>
    public static int[] BelgeKumesininTurleri(string kume)
        => BelgeKumeTurleri.TryGetValue(kume, out var t) ? t : Array.Empty<int>();

    /// <summary>
    /// Yetki kodundan belge kümesi. Çekirdek <c>belge</c> yalnız başvuruyu
    /// açar; ERP kümelerinin her biri kendi kodunu ister.
    /// </summary>
    public static string? BelgeKumesi(string yetkiKodu) => yetkiKodu switch
    {
        "belge"       => BelgeKumeBasvuru,
        "belge.satis" => BelgeKumeSatis,
        "belge.alis"  => BelgeKumeAlis,
        "belge.stok"  => BelgeKumeStok,
        _             => null,
    };

    /// <summary>Kısıtın bakacağı tüm yetki kodları - bağlam bunları sorgular.</summary>
    public static IReadOnlyList<string> BelgeYetkiKodlari { get; } =
        new[] { "belge", "belge.satis", "belge.alis", "belge.stok" };
}

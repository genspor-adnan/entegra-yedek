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
    /// <summary>
    /// Belge kümesi izni. Çekirdek <c>belge</c> başvuru bağlamını (tipi 30)
    /// açar; ERP belgelerinde KÜME = EKRAN KODU (1004 aşama 2, kullanıcı:
    /// "Satış/Alış'a geç"): Satış Faturaları yalnız faturayı, Satış
    /// Teklifleri yalnız teklifi açar.
    /// </summary>
    public const string BelgeKumeBasvuru = "basvuru";
    public const string BelgeKumeSatis   = "belge.satis";
    public const string BelgeKumeAlis    = "belge.alis";
    public const string BelgeKumeStok    = "belge.stok";
    public const string BelgeKumeKurumFatura = "belge.kurum_fatura";
    public const string BelgeKumeAlisFatura  = "belge.alis_fatura";

    /// <summary>
    /// Başvuru bağlamı belge TİPİ: başvuru ve ondan türeyen hasta belgeleri
    /// (fiş, tahakkuk) bu tipi taşır. ERP ticari belgesi 1 (normal) / 2 (iade).
    /// </summary>
    public const int BelgeTipiBasvuru = 30;

    /// <summary>
    /// Ekran kodu -> açtığı belge türleri ve başvuru tipinin hariç olup
    /// olmadığı. Türler Delphi'den gelen sabit kodlardır, ekranın
    /// `sabitFiltre`/`yeniBelgeTuru`'su ile birebir. Sipariş (19) başvuruyla
    /// aynı türdür; ekranın kendi süzgeci gibi tipi 30 DIŞARIDA.
    /// </summary>
    private static readonly Dictionary<string, (int[] Turler, bool BasvuruHaric)> BelgeKumeTurleri =
        new(StringComparer.Ordinal)
    {
        // Satış
        ["belge.satis"]            = ([18, 119], false),   // Teklifler (+ gizli Konsinyeler)
        ["belge.satis.siparis"]    = ([19], true),         // Siparişler
        ["belge.satis.irsaliye"]   = ([14], false),        // İrsaliyeler (kart)
        ["belge.satis.fatura"]     = ([15], false),        // Faturalar
        ["belge.kurum_fatura"]     = ([15], false),        // Kurumlar & Sigorta › Faturalar
        ["belge.satis.fis"]        = ([16], false),        // Fişler
        ["belge.satis.tahakkuk"]   = ([17], false),        // Tahakkuklar
        ["belge.satis.acik_satir"] = ([19], true),         // Açık Satırlar (siparişin kartı)
        // Alış
        ["belge.alis"]             = ([9], false),         // Siparişler
        ["belge.alis.irsaliye"]    = ([10], false),
        ["belge.alis_fatura"]      = ([11], false),        // Stok & Hizmet › Alış Faturaları
        ["belge.alis.fis"]         = ([12], false),
        ["belge.alis.tahakkuk"]    = ([13], false),
        ["belge.alis.konsinye"]    = ([109], false),
        // Stok fişleri (liste kendi kaynağında; kart belge ucundan açılır)
        ["belge.stok"]             = ([105], false),       // Stoktan Talep
        ["belge.stok.transfer"]    = ([20], false),
        ["belge.stok.giris"]       = ([3], false),
        ["belge.stok.cikis"]       = ([4], false),
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
        => BelgeKumeTurleri.TryGetValue(kume, out var t) ? t.Turler : Array.Empty<int>();

    /// <summary>Küme başvuru tipini (30) dışarıda bırakıyor mu.</summary>
    public static bool BelgeKumesiBasvuruHaric(string kume)
        => BelgeKumeTurleri.TryGetValue(kume, out var t) && t.BasvuruHaric;

    /// <summary>Yetki kodundan belge kümesi (çekirdek `belge` = başvuru, ERP kodu = kendisi).</summary>
    public static string? BelgeKumesi(string yetkiKodu)
        => yetkiKodu == "belge" ? BelgeKumeBasvuru
         : BelgeKumeTurleri.ContainsKey(yetkiKodu) ? yetkiKodu
         : null;

    /// <summary>
    /// Kümenin bu belgeye izin verip vermediği (tek kayıt / yazma kapısı).
    /// </summary>
    public static bool BelgeKumesiIzinVerir(string kume, int tur, int tipi)
        => kume == BelgeKumeBasvuru
           ? tipi == BelgeTipiBasvuru
           : BelgeKumesininTurleri(kume).Contains(tur)
             && !(BelgeKumesiBasvuruHaric(kume) && tipi == BelgeTipiBasvuru);

    /// <summary>
    /// Kısıtın bakacağı tüm yetki kodları - bağlam bunları TAM eşleşmeyle
    /// sorgular (YetkiSeti.VarTam): ekran kodu belge kaynağını açar ama
    /// başka kümeyi açmaz.
    /// </summary>
    public static IReadOnlyList<string> BelgeYetkiKodlari { get; } =
        new[] { "belge" }.Concat(BelgeKumeTurleri.Keys).ToArray();
}

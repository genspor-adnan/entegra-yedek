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
    /// <summary>
    /// Stok CIKISI yonundeki turler. Cari tarafi olan turlerde ayni liste
    /// "satis mi" sorusunu da cevaplar (cari BORCLANIR).
    ///
    /// 17 (Satis Tahakkuku) stok ETKILEMEZ ama SATIS tarafindadir: musteri
    /// borclanir. Numaralandirma deseni kucuk kod = ALIS, buyuk kod = SATIS
    /// (334): alis 9/10/11/12/13, satis 19/14/15/16/17 - bu yuzden alis
    /// tahakkuku (13) listede YOK, satis tahakkuku (17) VAR.
    /// </summary>
    private static readonly HashSet<int> CikisTurleri =
        new() { 17, 14, 15, 16, 119, 29, 105, 133, 4, SarfCikisi, FireCikisi };

    /// <summary>Depolar arasi transfer: TEK satir iki depoyu birden oynatir.</summary>
    public const int Transfer = 20;

    // ----------------------------------------------------------- uretim (429) ---
    /// <summary>
    /// URETIM BELGELERI (429). Kod uzayi kasa_islem_turu ile ORTAKTIR:
    /// 21-23 zaten KASA tahsilat turleridir, belge grubuna bos gorunse de
    /// doludur. Bu yuzden konsinyenin (109/119) yanindaki ust blok secildi.
    ///
    /// Ucu de carisiz stok belgesidir: uretim ic bir olaydir, karsi taraf yok.
    /// </summary>
    public const int SarfCikisi = 121;

    /// <summary>Mamul deposuna giris; kismi partiler ayni lot ile girer.</summary>
    public const int UretimGirisi = 122;

    /// <summary>Ret/fire cikisi - mamule dagilmayan kayip.</summary>
    public const int FireCikisi = 123;

    /// <summary>
    /// Uretimin urettigi belgeler emre baglanir: belge.kaynak_tur = bu deger,
    /// kaynak_id = uretim emri id. Belge donusum izinde kullanilan desenin
    /// aynisi - "bu sarf fisi hangi emirden cikti" tek sorgu.
    /// </summary>
    public const int KaynakTurUretimEmri = 60;

    /// <summary>
    /// URETIM FISI (1253): fisin kestigi sarf / fire / uretim girisi belgeleri fise baglanir (kaynak_tur = 61,
    /// kaynak_id = uretim_fisi.id). Emre bagli fisin belgeleri emrin hareketlerinde fis uzerinden gorunur (v_uretim_hareket).
    /// </summary>
    public const int KaynakTurUretimFisi = 61;

    /// <summary>Stoktan talep: stok/cari ETKILEMEZ, karsilanmasi transferle olur.</summary>
    public const int Talep = 105;

    /// <summary>
    /// SATIS SIPARISI. HASTA BASVURUSU (246) DA BU TURDUR - ayri bir tur
    /// numarasi yoktur: ayni kayit ERP kurulumunda "Satış Siparişleri",
    /// GenoTIP'te "Başvurular" ekraninda gorunur (liste tanimlari urunModu ile
    /// suzer). Hizmet/malzeme satirlarini tasir, stok ve muhasebe ETKILEMEZ;
    /// gercek hareket faturaya/fise/tahakkuka donusturulunce olusur.
    /// </summary>
    public const int SatisSiparisi = 19;

    /// <summary>e-Fatura / e-Arsiv olarak GIDEN satis faturasi.</summary>
    public const int SatisFaturasi = 15;

    /// <summary>e-Irsaliye olarak GIDEN satis irsaliyesi.</summary>
    public const int SatisIrsaliyesi = 14;

    /// <summary>Stok fisleri: 3 giris / 4 cikis - carisiz, muhasebe fisi uretir.</summary>
    private static readonly HashSet<int> StokFisleri = new() { 3, 4 };

    /// <summary>
    /// Numarasi BIZDE degil KARSI TARAFTA uretilen turler. Alis faturasinin
    /// numarasi tedarikcinindir: harf/tire icerebilir, bizim sayacimizla
    /// iliskisi yoktur (sayac tohumu eski veriden geldigi icin
    /// "3012026000357895" gibi anlamsiz numaralar uretiyordu).
    ///
    /// BUTUN ALIS BELGELERI (kullanici 02.11.2026: "alım belgelerinde alış fatno/irs no/fiş no gibi numaralandırma
    /// gelen belgedeki numara girişi ile yapılır"): alis irsaliyesi (10), alis faturasi (11), alis fisi (12) ve
    /// konsinye giris (109). Alis SIPARISI (9) DISARIDA - siparisi biz veririz, numarasi bizim sayacimizdan.
    /// </summary>
    private static readonly HashSet<int> DisNumaraliTurler = new() { 10, 11, 12, 109 };

    // -------------------------------------------------------------- sorular ---
    /// <summary>
    /// Stok CIKISI mi? Cari tarafi olan turlerde ayni zamanda "satis" demektir
    /// (cari BORCLANIR); cikis fisinde (4) cari yoktur, yalniz stok yonunu verir.
    /// </summary>
    public static bool CikisMi(int tur) => CikisTurleri.Contains(tur);

    /// <summary>
    /// IADE YONU TERSTIR: satis faturasi stoktan duser ve cariyi borclandirir;
    /// satis IADESI (tipi = 2) ayni turde ama mal geri GIRER, cari ALACAKLANIR.
    /// Yon hesabinin tek yeri burasi - stok ve cari hareketi ayni karari kullanir.
    ///
    /// TIP HER ZAMAN TURE BAGLI OKUNUR (kullanici): `tipi` tek bir kod uzayi
    /// degil - stok fisinde fisin sebebi, faturada fatura tipi, irsaliyede
    /// normal/iade, basvuruda (301) "hasta basvurusu" isaretidir. Bu yuzden
    /// iade yorumu yalniz IADESI OLAN turlerde uygulanir: siparis, teklif,
    /// transfer ve talep iade edilemez. Tur 19 zaten cikis turu degil -
    /// korumasiz birakilirsa tipi 2 onu "cikis" yapar, fatura donusumu ters
    /// yonde hesaplanirdi.
    /// </summary>
    public static bool CikisMi(int tur, int tipi) =>
        tipi == IadeTipi && !IadesizTurler.Contains(tur) ? !CikisMi(tur) : CikisMi(tur);

    /// <summary>belge.tipi = 2 -> iade (130 kod listesinde de ayni numara).</summary>
    public const int IadeTipi = 2;

    /// <summary>
    /// Iadesi OLMAYAN turler: siparis (9, 19 = basvuru), teklif (18),
    /// transfer (20), talep (105). Bunlarda mal hareketi yok ya da karsi
    /// taraf yok; `tipi = 2` iade degil, ture ozel bir isarettir.
    /// </summary>
    /// STOK FISLERI (3 giris / 4 cikis) DA IADESIZ (24.10.2026, sayim gelistirmesinde bulundu):
    /// fiste tipi fisin SEBEBIDIR (101) - giris fisi tipi 2 "Sayim Fazlasi", cikis fisi tipi 2
    /// "Imha". Kume disindayken bu ikisi iade sayiliyor, stok_durum TERS yone yaziliyordu
    /// (sayim fazlasi stoktan dusuyor, imha stoga ekliyordu); lot defteri ise dogru yondeydi.
    private static readonly HashSet<int> IadesizTurler = new() { 9, 18, 19, 20, 105, 3, 4 };

    public static bool TransferMi(int tur) => tur == Transfer;

    public static bool TalepMi(int tur) => tur == Talep;

    // SİLME DESENİ (kullanıcı 10.11.2026, 1284 → 1285 → 1286 "bütün alış/satış belgeleri için artık silme deseni
    //   böyle"): HER belge satırlarıyla silinir (BelgeDeposu.SilAsync); 1267'nin "önce satırları silin" kuralı kalktı.
    //   Tür kümesi tutulmuyor. Korumalar fn_belge_silinebilir'de: e-Belge hazır / gönderilmiş, iptal, dönüşüm, kasa, ÜTS.

    public static bool StokFisiMi(int tur) => StokFisleri.Contains(tur);

    public static bool DisNumarali(int tur) => DisNumaraliTurler.Contains(tur);

    /// <summary>
    /// Bu turde belge basliginda hangi depo alani doldurulur:
    /// cikis yonlu belge cikis deposunu, giris yonlu giris deposunu kullanir.
    /// Transferde IKISI de dolar - ayri ele alinir (bkz. StokDurumGuncelle).
    /// </summary>
    public static string DepoAlani(int tur) => CikisMi(tur) ? "cikisDepoId" : "girisDepoId";

    /// <summary>
    /// DEPO ZORUNLU (kullanıcı 11.11.2026 genel kural: "tüm alış/satış belgeleri + stoktan talep + stok transfer:
    /// varsa depo giriş/çıkış comboları seçilmiş olmalı; kalem eklenince depo(lar) değişemez"): alış (9, 10, 11, 12,
    /// 109) ve satış (14, 15, 16, 29, 119, 133) belgeleri, stok fişleri (3, 4), üretim fişleri (121-123), transfer
    /// (20, iki depo) ve talep (105, istenen + teslim deposu). Tahakkuk (13, 17), başvuru (19) ve teklif (18) dışında
    /// - stok hareketi yok; teklifte depo combosu web'de istenir, sunucu zorlamaz.
    /// </summary>
    public static bool DepoZorunlu(int tur) =>
        tur is not (13 or 17 or 18 or 19)
        && (CikisMi(tur) || tur is 9 or 10 or 11 or 12 or 109 or Transfer or UretimGirisi || StokFisiMi(tur));
    /// <summary>Transfer ve talep: başlıkta İKİ depo (çıkış / istenen + giriş / teslim), ikisi de zorunlu ve farklı.</summary>
    public static bool IkiDepolu(int tur) => tur is Transfer or Talep;
}

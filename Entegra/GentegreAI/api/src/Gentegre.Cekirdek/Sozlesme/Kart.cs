using System.Text.Json;

namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>API §3.1 - kart okuma yaniti.</summary>
public sealed class KartYaniti
{
    public IDictionary<string, object?> Kart { get; set; } = new Dictionary<string, object?>();
    public IDictionary<string, List<IDictionary<string, object?>>>? Detaylar { get; set; }
    /// <summary>Sayfali detaylarda TOPLAM satir sayisi (525) - arayuz sayfa
    /// seridini buna gore cizer. Sayfasiz detaylar burada YER ALMAZ.</summary>
    public IDictionary<string, int>? DetayToplam { get; set; }
    public IDictionary<string, IDictionary<string, string>>? KodAd { get; set; }
    public KartYetkisi Yetki { get; set; } = new();
    /// <summary>
    /// Kayit YAZILDIKTAN SONRA calisan is akislarinin soyledigi seyler
    /// (or. dis kurum numunesinin ucretlendirilmesi). Kaydi DUSURMEZ -
    /// bu yuzden hata degil uyaridir; ekran seritte gosterir.
    /// </summary>
    public List<string>? Uyarilar { get; set; }
    public string IzlemeNo { get; set; } = "";
}

public sealed class KartYetkisi
{
    public bool Duzenle { get; set; }
    public bool Sil { get; set; }
    public IReadOnlyList<string> GizliAlanlar { get; set; } = Array.Empty<string>();
}

/// <summary>
/// API §3.2 - yazma istegi. Detaylar FARK LISTESI olarak gelir (tam liste degil).
/// Kismi guncelleme yok: alan gondermemek "degistirme", null gondermek "bosalt" demektir.
/// </summary>
public sealed class KartYazmaIstegi
{
    public string? Surum { get; set; }
    public Dictionary<string, JsonElement>? Kart { get; set; }
    public Dictionary<string, DetayFarki>? Detaylar { get; set; }
}

public sealed class DetayFarki
{
    public List<Dictionary<string, JsonElement>>? Eklenen { get; set; }
    public List<Dictionary<string, JsonElement>>? Degisen { get; set; }
    public List<long>? Silinen { get; set; }
}

/// <summary>
/// Kart alan metasi. Liste tarafindaki KolonMeta'nin karsiligi: form etiketleri,
/// zorunluluk ve uzunluk sinirlari SUNUCUDAN gelir ki dogrulama iki yerde
/// ayri ayri yazilmasin. Yetkisiz alan bu listede de DONMEZ.
/// </summary>
public sealed record KartAlanMeta(
    string Ad,
    string Baslik,
    string Tip,
    string? Grup,
    string? AltGrup,
    string? EslesAlan,
    bool Yazilabilir,
    bool Zorunlu,
    int? EnFazlaUzunluk,
    IReadOnlyDictionary<string, string>? Kodlar,
    /// <summary>Formda CIZILMEZ ama degeri tasinir (arka plan alani).</summary>
    bool Gizli = false,
    /// <summary>Doluysa secenekler bu alanin degerine gore suzulur (Şube -> Banka).</summary>
    string? BagliAlan = null,
    /// <summary>Doluysa alan jenerik arama ekranindan secilir (260).</summary>
    string? AramaKaynagi = null,
    /// <summary>Bagli alanda her secenegin UST degeri: secenek id -> ust id.</summary>
    IReadOnlyDictionary<string, string>? KodUst = null,
    /// <summary>
    /// Secim kaynagi HIYERARSIK (484): arayuz secenekleri agac sirasinda ve
    /// girintili cizer. Ust baglari <see cref="KodUst"/>ten okunur.
    /// </summary>
    bool Agac = false,
    /// <summary>
    /// SECENEK KAYNAGI kod_liste ise LISTENIN KODU (544, ör. "stok.model").
    /// Kart alanin etiketini tiklanabilir yapip listeyi oradan yonetir -
    /// markanin modelleri baska hicbir ekrandan girilemiyordu.
    /// </summary>
    string? KodListesi = null,
    /// <summary>
    /// ALAN BICIM KURALI (bugun "tckn"): arayuz ayni kurali ANLIK uygular,
    /// kullanici kaydetmeyi beklemesin. Sunucu kuralin sahibi olmaya devam
    /// eder - ekranin kontrolu kolaylik, gecerlilik degil.
    /// </summary>
    string? Dogrulama = null);

/// <summary>
/// Sayfali detayin sunucu tarafi suzgeci (526): arama metni, kategori dali ve
/// cip kodu. Ifadelerin kendisi KATALOGDA - burada yalniz kullanicinin secimi.
/// </summary>
public sealed record DetaySuzgeci(string? Ara = null, int? Kategori = null, string? Cip = null);

public sealed record KartDetayMeta(
    string Ad,
    string Baslik,
    bool SaltOkunur,
    IReadOnlyList<KartAlanMeta> Alanlar,
    /// <summary>Doluysa sekme YALNIZ bu (mantik) alan isaretliyken acilir
    /// (ör. stok "Paket" sekmesi paket=1 iken).</summary>
    string? KosulAlani = null,
    /// <summary>1:1 detay - en fazla tek satir (249).</summary>
    bool TekSatir = false,
    /// <summary>
    /// SAYFA BOYU (525). 0 ise detay tek seferde gelir - kucuk detaylarda
    /// dogru olan budur. Buyuk detaylarda (fiyat listesi satiri: 14 bin)
    /// kart yaniti 4 MB'a cikiyor ve ekran donuyordu; deger verilince kartla
    /// yalniz ILK SAYFA gelir, gerisi `/detay/{ad}` ucundan istenir.
    /// </summary>
    int SayfaBoyu = 0);

public sealed class KartMetaYaniti
{
    /// <summary>
    /// YENI kayitta doldurulacak alanlar (katalogdaki YeniKayitVarsayilanlari).
    /// Arayuz bunu bilmedigi icin zorunlu kod alanlari (or. cek/senet "Yön")
    /// bos aciliyor ve kayit "zorunlu" hatasiyla donuyordu.
    /// </summary>
    public IReadOnlyDictionary<string, object?> Varsayilanlar { get; set; }
        = new Dictionary<string, object?>();

    /// <summary>
    /// Doluysa YENI kayitta taraf (cari) secim ekrani acilir; deger, secimin
    /// yazilacagi alan adidir. Kullanici isterse sonra alandan degistirir.
    /// </summary>
    public string? AcilistaTarafSecimi { get; set; }

    /// <summary>
    /// Doluysa kartta para birimi / kur / tutar ucgeni vardir: yerel para
    /// disinda bir birim secilince arayuz kuru sunucudan ceker, yerel karsiligi
    /// gosterir. Yerel tutari YINE DE sunucu hesaplar - bu yalniz onizleme.
    /// </summary>
    public DovizMetasi? Doviz { get; set; }

    public string Kaynak { get; set; } = "";
    public IReadOnlyList<KartAlanMeta> Alanlar { get; set; } = Array.Empty<KartAlanMeta>();
    public IReadOnlyList<KartDetayMeta> Detaylar { get; set; } = Array.Empty<KartDetayMeta>();
    public KartYetkisi Yetki { get; set; } = new();
}

/// <summary>Kart doviz ucgeni metasi (bkz. Katalog.DovizKurali) + yerel para birimi.</summary>
public sealed record DovizMetasi(
    string CinsAlani,
    string KurAlani,
    string TutarAlani,
    string YerelAlani,
    string? TarihAlani,
    string YerelPara);

/// <summary>
/// Silme engeli govdesi (§3.3): hata.engel = { tablo, adet, ad }.
/// `ad` KULLANICIYA gosterilen Turkce karsiliktir ("hakediş satırı");
/// `tablo` ham adi tasimaya devam eder - tani ve gunluk icin gerekli.
/// </summary>
public sealed record SilmeEngelBilgisi(string Tablo, long Adet, string Ad);

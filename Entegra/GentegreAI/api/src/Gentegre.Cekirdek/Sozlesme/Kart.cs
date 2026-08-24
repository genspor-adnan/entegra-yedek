using System.Text.Json;

namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>API §3.1 - kart okuma yaniti.</summary>
public sealed class KartYaniti
{
    public IDictionary<string, object?> Kart { get; set; } = new Dictionary<string, object?>();
    public IDictionary<string, List<IDictionary<string, object?>>>? Detaylar { get; set; }
    public IDictionary<string, IDictionary<string, string>>? KodAd { get; set; }
    public KartYetkisi Yetki { get; set; } = new();
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
    /// <summary>Bagli alanda her secenegin UST degeri: secenek id -> ust id.</summary>
    IReadOnlyDictionary<string, string>? KodUst = null);

public sealed record KartDetayMeta(
    string Ad,
    string Baslik,
    bool SaltOkunur,
    IReadOnlyList<KartAlanMeta> Alanlar);

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

/// <summary>Silme engeli govdesi (§3.3): hata.engel = { tablo, adet }.</summary>
public sealed record SilmeEngelBilgisi(string Tablo, long Adet);

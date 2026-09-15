namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>
/// DÖKÜM TANIMI (686) — dokuman/10_DOKUM_ISTATISTIK_PLANI.md §2.
///
/// Liste sözleşmesinin (ListeIstegi) üstüne dört şey ekler: boyut, ölçü,
/// kıyas ve parametre. SQL yok - tanım katalog alan adlarıyla yazılır,
/// sorguyu SorguUretici üretir. İstemciden gelen hiçbir metin SQL'e girmez.
/// </summary>
public sealed class DokumTanimi
{
    public string Kaynak { get; set; } = "";
    /// <summary>liste | ozet — liste düz satır döker, ozet boyut × ölçü.</summary>
    public string Cikti { get; set; } = "liste";
    public Kosul? Filtre { get; set; }
    public List<string>? Kolonlar { get; set; }
    public List<Siralama>? Sirala { get; set; }
    /// <summary>Liste çıktısında Σ alınan kolonlar (ListeIstegi.Toplam).</summary>
    public List<string>? Toplam { get; set; }
    /// <summary>Liste çıktısında gruplama (1-2 kolon) - ara toplam satırı için.</summary>
    public List<string>? Grup { get; set; }
    public DokumBoyut? Boyut { get; set; }
    public List<DokumOlcu>? Olcu { get; set; }
    /// <summary>yok | oncekiDonem | oncekiYil</summary>
    public string Kiyas { get; set; } = "yok";
    /// <summary>Küçük hücre gizlilik eşiği: 0 kapalı; n ise adet &lt; n olan grup düşer.</summary>
    public int Esik { get; set; }
    /// <summary>
    /// ÇALIŞTIRIRKEN SORULAN koşullar: alan adı → parametre. Tanımdaki değer
    /// yalnız varsayılandır; çalıştırma isteğinde gelen değer ağaçtaki aynı
    /// alanın yaprağına yazılır.
    /// </summary>
    public Dictionary<string, DokumParametre>? Parametreler { get; set; }
    public DokumBaski? Baski { get; set; }
}

/// <summary>Satır boyutları (1-3) ve isteğe bağlı sütun boyutu (çapraz tablo).
/// Tarih alanı "alan:kesme" yazılır: "belgeTarihi:ay".</summary>
public sealed class DokumBoyut
{
    public List<string> Satir { get; set; } = new();
    public string? Sutun { get; set; }
}

/// <summary>Ölçü: fn beyaz listeden (OlcuKatalogu), alan katalogdan.</summary>
public sealed class DokumOlcu
{
    public string Fn { get; set; } = "adet";
    public string? Alan { get; set; }
    /// <summary>Yalnız fn=oran: payda alanı.</summary>
    public string? Bolen { get; set; }
    public string? Baslik { get; set; }
}

public sealed class DokumParametre
{
    public string Ad { get; set; } = "";
    /// <summary>Tarih kuralı (bugun · dun · buHafta · gecenHafta · buAy · gecenAy ·
    /// buCeyrek · buYil · son7 · son30) ya da boş = tanımdaki değer.</summary>
    public string Kural { get; set; } = "";
}

/// <summary>Baskı ayarı - dökümle saklanır, zamanlı gönderim aynı ayarla basar.</summary>
public sealed class DokumBaski
{
    public string Yon { get; set; } = "dikey";
    public bool KurumBasligi { get; set; } = true;
    public bool ParametreKutusu { get; set; } = true;
    public bool SayfaNo { get; set; } = true;
    public bool Damga { get; set; }
    public bool Imza { get; set; }
    public string Dipnot { get; set; } = "";
    public bool OzetGostergeler { get; set; } = true;
    public bool AraToplam { get; set; } = true;
    public bool Capraz { get; set; } = true;
    public int SatirTavani { get; set; } = 2000;
    public List<string>? GizliKolonlar { get; set; }
}

/// <summary>Çalıştırma isteği: parametre değerleri + sayfalama (liste çıktısı).</summary>
public sealed class DokumCalistirIstegi
{
    public Dictionary<string, object?>? Parametreler { get; set; }
    public int Sayfa { get; set; } = 1;
    public int Boyut { get; set; } = 100;
    /// <summary>Kaydedilmeden çalıştırma (önizleme): tanım istekte gelir.</summary>
    public DokumTanimi? Tanim { get; set; }
}

/// <summary>Özet çıktısı: boyut kolonları + ölçü kolonları; her satır bir grup.</summary>
public sealed class OzetYaniti
{
    public IReadOnlyList<string> Boyutlar { get; set; } = Array.Empty<string>();
    public IReadOnlyList<OzetOlcu> Olculer { get; set; } = Array.Empty<OzetOlcu>();
    public IReadOnlyList<IDictionary<string, object?>> Satirlar { get; set; }
        = Array.Empty<IDictionary<string, object?>>();
    /// <summary>Kıyas dönemi satırları (aynı boyut/ölçü adları) - Δ istemcide.</summary>
    public IReadOnlyList<IDictionary<string, object?>>? Kiyas { get; set; }
    /// <summary>Kıyas döneminin çözülmüş tarih aralığı - başlıkta yazılır.</summary>
    public string KiyasAraligi { get; set; } = "";
    public long SureMs { get; set; }
    public string IzlemeNo { get; set; } = "";
}

public sealed record OzetOlcu(string Ad, string Baslik, string Fn, string Bicim);

/// <summary>Kayıtlı döküm satırı (liste + kart).</summary>
public sealed class DokumKaydi
{
    public int Id { get; set; }
    public string Kod { get; set; } = "";
    public string Ad { get; set; } = "";
    public string Aciklama { get; set; } = "";
    public string Kaynak { get; set; } = "";
    public DokumTanimi Tanim { get; set; } = new();
    public int Surum { get; set; }
    public int SahipId { get; set; }
    public string Sahip { get; set; } = "";
    public short Gorunurluk { get; set; }
    public int[] Roller { get; set; } = Array.Empty<int>();
    public DateTime? SonCalisma { get; set; }
    public int CalismaSayisi { get; set; }
    public bool Duzenlenebilir { get; set; }
    /// <summary>STANDART döküm (688): salt okunur, kopyalanır; kurum profiline göre süzülür.</summary>
    public bool Sistem { get; set; }
    public int UrunModu { get; set; }
    public string Modul { get; set; } = "";
}

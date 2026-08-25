namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kart alani. Yazilabilir olmayan alanlar istek govdesinde gelse bile YOK SAYILMAZ -
/// hata verilir (API §3.2: sessizce yok saymak yok).
/// </summary>
public sealed record KartAlani(
    string Ad,                     // API adi: "faturaUnvan"
    string Kolon,                  // db kolonu: "fatura_unvan"
    string Tip,                    // metin | sayi | para | tarih | kod | mantik
    bool Yazilabilir = true,
    bool Zorunlu = false,
    int? EnFazlaUzunluk = null,
    string? KodListesi = null,     // kod_liste.kod - kodAd sozlugu bundan cozulur
    IReadOnlyDictionary<string, string>? SabitKodlar = null,  // kod listesi DB'de yoksa
    // Kendi tablosu olan (kod_liste/kod_deger'e uymayan) secim kaynagi: "public.kategori".
    //   Tam secenek listesi VeriDeposu.KodTablosuBeyazListe'de whitelist'li tablolardan
    //   "select id, ad from <tablo> where aktif = 1 order by ad" ile cekilir.
    string? KodTablosu = null,
    // BAGLI SECIM: bu alanin secenekleri baska bir alanin degerine gore SUZULUR
    //   (or. Şube -> BagliAlan "bankaId"). Gorunum ust_id kolonunu doner; kart
    //   yalniz ust_id = secili ust olan satirlari gosterir. Ust degisince, artik
    //   gecerli olmayan alt deger TEMIZLENIR - yoksa "Ziraat + Akbank subesi"
    //   gibi tutarsiz kayit olusur.
    string? BagliAlan = null,
    string? Baslik = null,         // form etiketi; bos ise Ad'dan uretilir
    string? Grup = null,           // form bolumu / SEKME: "Kimlik", "Iletisim", "Mali"
    // Sekme DEGIL - ayni sekme icinde mockup'taki gibi kucuk alt-baslik
    //   (or. Genel sekmesinde "Tanım / Sınıflandırma" / "Vergi & Ana Birim").
    string? AltGrup = null,
    // Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
    //   Baska bir alanin Ad'ini gosterir; o alan kendi SATIRINI almaz, buraya eklenir.
    string? EslesAlan = null,
    // ARKA PLAN alani: formda CIZILMEZ ama degeri tasinir (kaydetmede gonderilir).
    //   Cek/senet "Tür" boyle: kagidin turu hangi listeden gelindigiyle belli,
    //   ekranda yer kaplamasi gereksiz - ama kayda dogru deger gitmeli.
    bool Gizli = false
)
{
    /// <summary>Etiket verilmediyse camelCase addan uretilir: faturaUnvan -> "Fatura Unvan".</summary>
    public string Etiket => Baslik ?? AddanEtiket(Ad);

    private static string AddanEtiket(string ad)
    {
        var sonuc = new System.Text.StringBuilder(ad.Length + 4);
        for (var i = 0; i < ad.Length; i++)
        {
            if (i > 0 && char.IsUpper(ad[i])) sonuc.Append(' ');
            sonuc.Append(i == 0 ? char.ToUpperInvariant(ad[i]) : ad[i]);
        }
        return sonuc.ToString();
    }
}

public sealed record DetayTanimi(
    string Ad,                     // "adresler"
    string Tablo,                  // "public.taraf_adres"
    string UstKolon,               // "taraf_id"
    IReadOnlyList<KartAlani> Alanlar,
    string IdKolonu = "id",
    string Sirala = "id",
    // 019'da tum sube_id kolonlari NOT NULL yapildi; detay eklerken oturumun
    //   subesi yazilir. Tabloda sube_id yoksa null verilir.
    string? SubeKolonu = "sube_id",
    // islem_log.tablo_id. 0 ise kartin tablo kodu kullanilir. Detay satirinin
    //   logu ust_tablo_id / ust_kayit_id ile karta baglanir.
    int LogTabloId = 0,
    string? Baslik = null,         // sekme basligi; bos ise Ad'dan uretilir
    bool SaltOkunur = false,       // satir ekle/sil hic gosterilmez (or. hesaplanmis/derlenmis veri)
    // Sekme KOSULLU: verilen mantik alani isaretli degilse sekme hic acilmaz
    //   (or. stok "Paket" sekmesi yalniz paket=1 iken). Bos sekme gostermek,
    //   kullaniciya doldurulacak bir sey varmis izlenimi verir.
    string? KosulAlani = null
)
{
    public string Etiket => Baslik ?? (Ad.Length > 0 ? char.ToUpperInvariant(Ad[0]) + Ad[1..] : Ad);
}

/// <summary>Silmeyi engelleyen bag. Adet > 0 ise 422 IS_KURALI doner (API §3.3).</summary>
public sealed record SilmeEngeli(string Tablo, string Kolon, string Aciklama);

/// <summary>
/// DOVIZ KURALI — karttaki para birimi / kur / tutar ucgeni.
///
/// Yerel para (ayar <c>genel.yerel_para</c>) disinda bir birim secilirse kur
/// islem tarihinin kurundan OTOMATIK gelir ve yerel karsilik hesaplanir.
/// Kullanici kuru elle degistirebilir (banka/anlasma kuru); yerel tutar HER
/// ZAMAN sunucuda tutar x kur olarak yeniden hesaplanir - arayuzden gelen
/// yerel tutara guvenilmez (API §3.2: hesaplanan alan istemciden alinmaz).
///
/// Yerel parada kur 1'e sabitlenir; "TL kaydin kuru 41" gibi bir sey olusamaz.
/// </summary>
public sealed record DovizKurali(
    string CinsAlani,      // "dovizCinsi"
    string KurAlani,       // "dovizKuru"
    string TutarAlani,     // "tutar"
    string YerelAlani,     // "yerelTutar" - Yazilabilir:false olmali
    string? TarihAlani = null);  // kurun okunacagi tarih alani ("tarih")

public sealed record KartTanimi(
    string Ad,                     // yol parcasi: "cari"
    string YetkiKodu,
    string Tablo,                  // "public.taraf"
    IReadOnlyList<KartAlani> Alanlar,
    int LogTabloId,                // ISLEMLOG.TABLOID (eski GENINI -11110 listesi)
    IReadOnlyList<DetayTanimi>? Detaylar = null,
    IReadOnlyList<SilmeEngeli>? SilmeEngelleri = null,
    string IdKolonu = "id",
    string? SabitKosul = null,
    string? SubeKolonu = null,
    string? KapsamKolonu = null,
    IReadOnlyDictionary<string, object?>? YeniKayitVarsayilanlari = null,
    // YENI kayitta acilir acilmaz taraf (cari) secim ekrani acilsin mi - deger,
    //   secimin yazilacagi alan adidir ("tarafId"). Belge kartindaki desenin
    //   generic kartlardaki karsiligi; kullanici isterse sonra degistirir.
    string? AcilistaTarafSecimi = null,
    // Kartta para birimi / kur / tutar ucgeni varsa (cek-senet): yerel para
    //   disinda bir birim secilince kur otomatik gelir, yerel tutar hesaplanir.
    DovizKurali? Doviz = null
)
{
    private Dictionary<string, KartAlani>? _dizin;

    public KartAlani? Alan(string ad)
    {
        _dizin ??= Alanlar.ToDictionary(a => a.Ad, StringComparer.Ordinal);
        return _dizin.TryGetValue(ad, out var a) ? a : null;
    }

    public DetayTanimi? Detay(string ad)
        => Detaylar?.FirstOrDefault(d => d.Ad.Equals(ad, StringComparison.Ordinal));
}

public static partial class KartKatalogu
{
    private static readonly Dictionary<string, KartTanimi> Kartlar =
        new(StringComparer.OrdinalIgnoreCase);

    public static KartTanimi? Bul(string ad) => Kartlar.TryGetValue(ad, out var k) ? k : null;
    public static IEnumerable<KartTanimi> Tumu => Kartlar.Values;

    static KartKatalogu()
    {
        Ekle(Cari());
        Ekle(Kisi());
        Ekle(Personel());
        Ekle(Hasta());
        Ekle(Rol());
        Ekle(Stok());
        // Kasa alt sistemi ana verileri (071-074). Kasa ISLEMI kart degil - belge
        //   gibi ayri sozlesme (baslik + bacak), KasaUclari ile yazilir.
        Ekle(Hesap());
        Ekle(Proje());
        Ekle(Gorev());
        Ekle(Firsat());
        Ekle(Banka());
        Ekle(MasrafMerkezi());
        Ekle(HesapPlani());
        Ekle(CekSenet());
        Ekle(Depo());
        // Belge KARTI degil, ayri sozlesme (§4 belge kaydetme) - burada yer almaz.
    }

    private static void Ekle(KartTanimi k) => Kartlar[k.Ad] = k;

}


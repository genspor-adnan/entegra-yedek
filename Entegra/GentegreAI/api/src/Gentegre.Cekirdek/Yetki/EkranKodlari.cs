namespace Gentegre.Cekirdek.Yetki;

/// <summary>
/// MENÜ YERİNE GÖRE BÖLÜNEN EKRAN KODLARI (1003 — kullanıcı 09.10.2026:
/// "genprofil ile seçtiğim menüler yetki matrisinde görünecek.. yetki
/// matrisinde gor dediğim menüler de kullanıcı menüsünde görünecek",
/// "menü koduyla yetki matrisi kodları aynı olmalı", "A grubunun hepsini böl").
///
/// Bir yetki kodu FARKLI menü gruplarındaki ekranları birlikte açıyordu
/// (`belge.satis` hem Satış'ı hem Kurumlar &amp; Sigorta › Faturalar'ı,
/// `dokum` 28 grubun Dökümler'ini). Matristeki tek kutu menüde iki ayrı yeri
/// açıp kapatıyordu. Menü yerinin dışında kalan ekran kendi kodunu aldı; ana
/// gruptaki ekranlar eski kodu korur.
///
/// İKİ AYRI İŞ, TEK HARİTA:
///   <see cref="KopyaKaynagi"/> — göç (1003) ve standart rol şablonu yeni koda
///     eski kodun haklarını AYNEN verir: kimse yetki kazanmaz ya da kaybetmez,
///     yalnız kutular ayrılır.
///   <see cref="VeriKapisiAltlari"/> — ortak KAYNAK kullanan ekranlarda eski
///     kodun sunucu kapısı yeni kodla da açılır (Tedarikçiler `cari`
///     kaynağını, Medula Kabul `medula.provizyon` uçlarını kullanır). Kendi
///     kaynağı olan ekran (`eczane.miad`, `dis_doktor`) doğrudan yeni koda
///     bağlıdır, burada yoktur. `kayit_kabul.ayar` ayrıca dar tutulur
///     (yalnız kendi ayar anahtarları, bkz. AyarUclari).
///
/// Web tarafında aynı kodlar listeTanimlari'nda ve Dökümler öğelerinde durur.
/// </summary>
public static partial class EkranKodlari
{
    /// <summary>Grubun Dökümler ekranı kodu: <c>dokum.&lt;grup&gt;</c>.</summary>
    public static readonly IReadOnlyList<string> DokumKodlari =
    [
        "dokum.yonetim", "dokum.randevu", "dokum.kayit_kabul", "dokum.muayene",
        "dokum.laboratuvar", "dokum.radyoloji", "dokum.goz", "dokum.yatan_hasta",
        "dokum.dis", "dokum.ftr", "dokum.isyeri_hekimligi", "dokum.cagri_merkezi",
        "dokum.medula", "dokum.ameliyathane", "dokum.acil", "dokum.kurumlar_sigorta",
        "dokum.cari_crm", "dokum.satis", "dokum.alis", "dokum.stok_hizmet",
        "dokum.eczane", "dokum.satinalma", "dokum.uretim", "dokum.finans",
        "dokum.muhasebe", "dokum.ik", "dokum.dokuman", "dokum.teknik_servis",
    ];

    /// <summary>Yeni ekran kodu → haklarını kopyaladığı eski kod.</summary>
    private static readonly Dictionary<string, string> Kopya = new(StringComparer.Ordinal)
    {
        ["belge.kurum_fatura"] = "belge.satis",       // Kurumlar & Sigorta › Faturalar
        ["belge.alis_fatura"]  = "belge.alis",        // Stok & Hizmet › Alış Faturaları
        ["eczane.miad"]        = "stok",              // Eczane › Miad & Tüketim
        ["kayit_kabul.ayar"]   = "ayar",              // Kayıt Kabul › Ayarlar › Kayıt Kabul
        ["cari.tedarikci"]     = "cari",              // Stok & Hizmet › Tedarikçiler
        ["dis_doktor"]         = "personel",          // Kurumlar & Sigorta › Dış Doktorlar
        ["medula.kabul"]       = "medula.provizyon",  // Kayıt Kabul › Medula Kabul
    };

    /// <summary>
    /// Eski veri kodu → onun sunucu kapısını da açan ekran kodları. Belge
    /// kodları burada `belge` çekirdeğine bağlanır; hangi TÜRÜ göreceğini
    /// yine belge kümesi (tam eşleşme) belirler.
    /// </summary>
    private static readonly Dictionary<string, string[]> VeriKapisi = new(StringComparer.Ordinal)
    {
        ["belge"]            = ["belge.kurum_fatura", "belge.alis_fatura"],
        ["cari"]             = ["cari.tedarikci"],
        ["medula.provizyon"] = ["medula.kabul"],
        ["dokum"]            = [.. DokumKodlari],
    };

    /// <summary>Ekran kodunun haklarını kopyaladığı eski kod; bölünmemiş kodda null.</summary>
    public static string? KopyaKaynagi(string kod)
        => Kopya.TryGetValue(kod, out var k) ? k
         : AyniGrupKopya.Value.TryGetValue(kod, out var a) ? a
         : kod.StartsWith("dokum.", StringComparison.Ordinal) ? "dokum"
         : null;

    // AYNI GRUP TABLOSU (1004) başka dosyada: kısmi sınıfların statik alan
    //   sırası dosyalar arasında belirsiz, sözlükler ilk kullanımda kurulur.
    private static readonly Lazy<Dictionary<string, string>> AyniGrupKopya = new(() =>
        AyniGrupEkranlari.ToDictionary(x => x.Yeni, x => x.Eski, StringComparer.Ordinal));

    private static readonly Lazy<Dictionary<string, string[]>> TumVeriKapisi = new(() =>
    {
        var d = VeriKapisi.ToDictionary(x => x.Key, x => x.Value.ToList(), StringComparer.Ordinal);
        foreach (var (yeni, eski) in AyniGrupEkranlari)
        {
            if (!d.TryGetValue(eski, out var l)) d[eski] = l = [];
            l.Add(yeni);
        }
        return d.ToDictionary(x => x.Key, x => x.Value.ToArray(), StringComparer.Ordinal);
    });

    /// <summary>Bu veri kodunun kapısını da açan ekran kodları (yoksa boş).</summary>
    public static IReadOnlyList<string> VeriKapisiAltlari(string veriKodu)
        => TumVeriKapisi.Value.TryGetValue(veriKodu, out var a) ? a : [];

    /// <summary>
    /// SATIR KISITI (kullanıcı 09.10.2026: "tedarikçi satır süzgecini de
    /// ekle"). Ekran kodu eski kodun kaynağını açtığında (VeriKapisi) yalnız
    /// O EKRANIN satırlarını görmeli: `cari.tedarikci` ile gelen kullanıcı
    /// müşteri listesini adres çubuğundan açamamalı. Kısıt, kullanıcıda eski
    /// kodun KENDİSİ yoksa uygulanır - `cari` yetkisi olan her şeyi görür.
    /// </summary>
    /// <param name="Kosul">Kaynak/kart tablosu `t` takma adıyla; sabit metin, kullanıcı girdisi yok.</param>
    /// <param name="BayrakAlani">Kartta açık kalması gereken alan (yeni kayıt / güncelleme).</param>
    /// <param name="UstAlani">Kartta, kısıtı sağlayan üst kayda işaret eden alan.</param>
    /// <param name="UstKaynak">UstAlani'nin işaret ettiği kaynak (kısıtı o kaynağın kuralı sağlar).</param>
    public sealed record SatirKisiti(string VeriKodu, string EkranKodu, string Kosul,
                                     string? BayrakAlani = null, string? UstAlani = null,
                                     string? UstKaynak = null);

    /// <summary>Kaynak/kart adı → satır kısıtı. İkisi de `public.taraf t` üzerinde.</summary>
    private static readonly Dictionary<string, SatirKisiti> SatirKisitlari = new(StringComparer.Ordinal)
    {
        // Tedarikçiler ekranı: yalnız tedarikçi bayraklı cariler.
        ["cari"] = new("cari", "cari.tedarikci", "t.tedarikci = 1", BayrakAlani: "tedarikci"),
        // Tedarikçi kartının kişileri: yalnız tedarikçiye bağlı kişiler.
        ["kisi"] = new("cari", "cari.tedarikci",
            "exists (select 1 from public.taraf u where u.id = t.bag_id and u.tedarikci = 1)",
            UstAlani: "bagId", UstKaynak: "cari"),
    };

    /// <summary>
    /// Kaynağa/karta uygulanacak satır kısıtı; kullanıcı eski kodun kendisine
    /// sahipse ya da ekran kodu yoksa null (kısıt yok).
    /// </summary>
    public static SatirKisiti? Kisit(string ad, Func<string, bool> tamVar)
        => SatirKisitlari.TryGetValue(ad, out var k) && !tamVar(k.VeriKodu) && tamVar(k.EkranKodu)
           ? k : null;

    /// <summary>
    /// Kayıt Kabul Ayarları sayfasının yazdığı anahtarlar. `kayit_kabul.ayar`
    /// yalnız bunları yazabilir - genel `ayar` kapısını açmak bütün kurum
    /// ayarlarını açmak olurdu.
    /// </summary>
    public static readonly IReadOnlySet<string> KayitKabulAyarAnahtarlari = new HashSet<string>(StringComparer.Ordinal)
    {
        "basvuru.pos_aksiyon", "basvuru.sgk_katilim_payi",
        "basvuru.sgk_katilim_kodlari", "basvuru.iskonto_onay_esik",
    };
}

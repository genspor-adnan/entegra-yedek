namespace Gentegre.Cekirdek.Katalog;

/// <summary>CİHAZ KARTI (432) — bağlantı ve sürücü tanımı.</summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> CihazTurKodlari = new()
    {
        ["1"] = "Laboratuvar", ["2"] = "Görüntüleme", ["3"] = "Göz",
        ["4"] = "Vital / Monitör", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> CihazSurucuKodlari = new()
    {
        ["HL7V2"] = "HL7 v2 (MLLP)", ["ASTM"] = "ASTM E1394",
        ["DOSYA"] = "Dosya / klasör", ["DICOM"] = "DICOM (alım)",
    };

    private static readonly Dictionary<string, string> CihazBaglantiKodlari = new()
    {
        ["1"] = "Dinleyici (cihaz bize bağlanır)",
        ["2"] = "İstemci (biz cihaza bağlanırız)",
        ["3"] = "Klasör izleme",
    };

    private static readonly Dictionary<string, string> CihazDurumKodlari = new()
        { ["0"] = "Aktif", ["1"] = "Pasif" };

    private static KartTanimi CihazKarti() => new(
        Ad: "cihaz",
        YetkiKodu: "cihaz",
        Tablo: "public.cihaz",
        LogTabloId: 1004,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1, ["surucu"] = "HL7V2", ["baglantiTuru"] = (short)1,
            ["kodlama"] = "utf-8", ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            // Mesaj gelmis cihaz silinemez: gelen sonuclarin hangi cihazdan
            //   geldigi kaybolur, ham metinler sahipsiz kalirdi.
            new("public.cihaz_mesaj", "cihaz_id", "Bu cihazdan mesaj alınmış."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 25,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Cihaz", Grup: "Kimlik"),
            new("tur", "tur", "kod", SabitKodlar: CihazTurKodlari,
                Baslik: "Tür", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: CihazDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // Baglanti: dinleyicide port, klasor izlemede yol anlamli.
            //   Ikisi de ayni sekmede - hangi alanin dolacagi surucuye gore
            //   degisir, kullanici bos birakir.
            new("surucu", "surucu", "kod", SabitKodlar: CihazSurucuKodlari,
                Baslik: "Sürücü", Grup: "Bağlantı"),
            new("baglantiTuru", "baglanti_turu", "kod", SabitKodlar: CihazBaglantiKodlari,
                Baslik: "Bağlantı Türü", Grup: "Bağlantı"),
            new("adres", "adres", "metin", EnFazlaUzunluk: 120,
                Baslik: "Adres (boş = tüm arayüzler)", Grup: "Bağlantı"),
            new("port", "port", "sayi", Baslik: "Port", Grup: "Bağlantı"),
            new("klasorYolu", "klasor_yolu", "metin", EnFazlaUzunluk: 300,
                Baslik: "İzlenen Klasör", Grup: "Bağlantı"),
            new("arsivKlasoru", "arsiv_klasoru", "metin", EnFazlaUzunluk: 300,
                Baslik: "Arşiv Klasörü", Grup: "Bağlantı"),
            new("kodlama", "kodlama", "metin", EnFazlaUzunluk: 20,
                Baslik: "Kodlama", Grup: "Bağlantı"),
            new("aeTitle", "ae_title", "metin", EnFazlaUzunluk: 40,
                Baslik: "AE Title (DICOM)", Grup: "Bağlantı"),
            // OTOMATIK: kapali cihazin portu HIC dinlenmez. Port acmak
            //   yeniden baslatma isteyen bir yapilandirma isi.
            new("otomatik", "otomatik", "mantik",
                Baslik: "Uygulama açılışında başlat", Grup: "Bağlantı"),

            new("sonMesaj", "son_mesaj", "tarih", Yazilabilir: false,
                Baslik: "Son Mesaj", Grup: "Durum"),
            new("sonHata", "son_hata", "metin", Yazilabilir: false,
                Baslik: "Son Hata", Grup: "Durum"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Durum"),
        });
}

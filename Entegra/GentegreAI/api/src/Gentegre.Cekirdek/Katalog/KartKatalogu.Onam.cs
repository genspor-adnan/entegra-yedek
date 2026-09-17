namespace Gentegre.Cekirdek.Katalog;

public static partial class KartKatalogu
{
    /// <summary>
    /// ONAM METNI KARTI (398) — metin ve SÜRÜMÜ.
    ///
    /// Metin değişince satır GÜNCELLENMEZ, yeni sürüm açılır: verilmiş onam
    /// hangi metne verildiğini bilmek zorundadır (hukuki dayanak). Kart bunu
    /// zorlamaz ama alan sırası ve açıklama bunu söyler; "Yeni Sürüm" aksiyonu
    /// F1'de eklenecek.
    /// </summary>
    private static KartTanimi OnamMetniKarti() => new(
        Ad: "onam-metni",
        YetkiKodu: "onam",
        Tablo: "public.onam_metni",
        LogTabloId: 1286,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["surum"] = (short)1,
            ["tur"] = (short)9,
            ["bicim"] = (short)0,
            ["zorunlu"] = (short)0,
            ["yururluk_bas"] = "@bugun",
        },
        Alanlar: new KartAlani[]
        {
            new("id",   "id",   "sayi", Yazilabilir: false),
            new("kod",  "kod",  "metin", Zorunlu: true, EnFazlaUzunluk: 40,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",   "ad",   "metin", Zorunlu: true, EnFazlaUzunluk: 160,
                Baslik: "Onam Adı", Grup: "Kimlik"),
            new("tur",  "tur",  "kod", Zorunlu: true, KodListesi: "onam.tur",
                Baslik: "Tür", Grup: "Kimlik"),
            // SURUM elle girilir: metin değişikliği bilinçli bir karardır.
            new("surum", "surum", "sayi", Zorunlu: true,
                Baslik: "Sürüm", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            new("yururlukBas", "yururluk_bas", "tarih", Zorunlu: true,
                Baslik: "Yürürlük Başlangıcı", Grup: "Yürürlük"),
            new("yururlukBit", "yururluk_bit", "tarih",
                Baslik: "Yürürlük Bitişi", Grup: "Yürürlük"),
            // ZORUNLU: işaretliyse ilgili akış (teletıp görüşmesi, genetik vaka)
            //   onam alınmadan ilerlemez - kural F1'de akışa bağlanır.
            new("zorunlu", "zorunlu", "mantik",
                Baslik: "Onam alınmadan işleme devam edilemez", Grup: "Yürürlük"),
            new("bicim", "bicim", "kod", SabitKodlar: OnamBicimKodlari,
                Baslik: "Metin Biçimi", Grup: "Metin"),
            new("metin", "metin", "metin", EnFazlaUzunluk: 20000,
                Baslik: "Onam Metni", Grup: "Metin"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Metin"),
        });

    private static readonly Dictionary<string, string> OnamBicimKodlari = new()
    {
        ["0"] = "Düz metin",
        ["1"] = "HTML (şablon değişkenli)",
    };

    /// <summary>
    /// BILDIRIM SABLONU KARTI (399).
    ///
    /// Gövdedeki <c>{{degisken}}</c> yer tutucuları gönderim anında doldurulur;
    /// hangi değişkenlerin geçerli olduğu <c>degiskenler</c> alanında yazar -
    /// şablonu düzenleyen kişi kod okumadan bilsin.
    ///
    /// SAAT PENCERESI: gece SMS atılmasın diye. İkisi de 0 ise sınır yoktur
    /// (panik değer bildirimi gece de gider).
    /// </summary>
    private static KartTanimi BildirimSablonKarti() => new(
        Ad: "bildirim-sablon",
        YetkiKodu: "bildirim_sablon",
        Tablo: "public.bildirim_sablon",
        LogTabloId: 1287,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["kanal"] = (short)1,
            ["saat_bas"] = (short)9,
            ["saat_bit"] = (short)20,
        },
        Alanlar: new KartAlani[]
        {
            new("id",  "id",  "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",  "ad",  "metin", Zorunlu: true, EnFazlaUzunluk: 160,
                Baslik: "Şablon Adı", Grup: "Kimlik"),
            new("kanal", "kanal", "kod", Zorunlu: true, KodListesi: "bildirim.kanal",
                Baslik: "Kanal", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            new("saatBas", "saat_bas", "sayi",
                Baslik: "Gönderim Saati (baş)", Grup: "Kimlik"),
            new("saatBit", "saat_bit", "sayi",
                Baslik: "Gönderim Saati (bit)", Grup: "Kimlik"),
            new("konu", "konu", "metin", EnFazlaUzunluk: 200,
                Baslik: "Konu (e-posta)", Grup: "Metin"),
            new("govde", "govde", "metin", EnFazlaUzunluk: 4000,
                Baslik: "Gövde", Grup: "Metin"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Metin"),
        });
}

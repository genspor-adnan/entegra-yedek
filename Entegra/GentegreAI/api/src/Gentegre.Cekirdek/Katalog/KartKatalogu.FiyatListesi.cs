namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FIYAT LISTESI karti (201/202).
///
/// Liste bir KURALDIR (taban liste x carpan -> yuvarlama), satirlar o kuralin
/// materyalize edilmis halidir. Satir gridinde kalemin kodu/adi/kategorisi
/// GORUNUR ama tabloda TUTULMAZ - stok/hizmet kartindan gelir (v_fiyat_listesi_satir).
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>Fiyat listesinin kendisi - kural ve gecerlilik araligi.</summary>
    private static KartTanimi FiyatListesi() => new(
        Ad: "fiyat-listesi",
        YetkiKodu: "fiyat_listesi",
        Tablo: "public.fiyat_listesi",
        LogTabloId: 923,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["carpan"] = 1m,
            ["yuvarlama"] = (short)0,
            ["yuvarlamaBirim"] = 1m,
            ["kdvDahil"] = (short)0,
        },
        Alanlar: new KartAlani[]
        {
            new("id",   "id",   "sayi",  Yazilabilir: false),
            new("ad",   "ad",   "metin", Zorunlu: true, EnFazlaUzunluk: 80,
                Baslik: "Liste Adı", Grup: "Genel"),
            new("grup", "grup", "kod",   KodListesi: "fiyat_listesi.grup",
                Baslik: "Grubu", Grup: "Genel"),
            // YON (204): liste alis mi satis mi? Belge turu hangi yondeyse o
            //   yonun listesi uygulanir. Taban liste AYNI YONDE olmali (DB tetigi).
            new("yon", "yon", "kod", SabitKodlar: YonKodlari,
                Baslik: "Yön", Grup: "Genel"),
            // VARSAYILAN: carisinde liste tanimlanmamis belgeler bunu kullanir.
            //   Yon basina TEK varsayilan olabilir (DB tekil indeksi).
            new("varsayilan", "varsayilan", "mantik",
                Baslik: "Varsayılan Liste", Grup: "Genel"),
            new("durum", "durum", "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Genel"),

            // GECERLILIK: bos birakilirsa sinirsiz. Bitis, baslangictan once
            //   olamaz (DB check).
            new("baslangic", "baslangic", "tarih", Baslik: "Başlama",
                Grup: "Genel", AltGrup: "Geçerlilik"),
            new("bitis",     "bitis",     "tarih", Baslik: "Bitiş",
                Grup: "Genel", AltGrup: "Geçerlilik"),

            // FIYATLAMA KURALI. Taban liste bos ise liste KOKTUR: fiyatlar
            //   kalemin kendi kartindan (stok_fiyat / hizmet_fiyat) baslar.
            new("tabanListeId", "taban_liste_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_lookup",
                Baslik: "Taban Liste", Grup: "Genel", AltGrup: "Fiyatlama"),
            new("carpan", "carpan", "para", Baslik: "Çarpan",
                Grup: "Genel", AltGrup: "Fiyatlama"),
            new("yuvarlama", "yuvarlama", "kod", KodListesi: "fiyat_listesi.yuvarlama",
                Baslik: "Yuvarlama", Grup: "Genel", AltGrup: "Fiyatlama"),
            // "En Yakin Degere" bir ADIM ister; adimsiz "en yakin" tanimsizdir.
            new("yuvarlamaBirim", "yuvarlama_birim", "para", Baslik: "Yuvarlama Adımı",
                Grup: "Genel", AltGrup: "Fiyatlama"),
            new("kdvDahil", "kdv_dahil", "kod", SabitKodlar: KdvDahilKodlari,
                Baslik: "KDV", Grup: "Genel", AltGrup: "Fiyatlama"),

            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Genel"),
            new("subeId", "sube_id", "sayi", Yazilabilir: false),
        },
        Detaylar: new[]
        {
            // SATIRLAR. Kod / Ad / Kategori kalemin kartindan gelir - burada
            //   yazilabilir alan degiller (SaltOkunur alanlar okuma icin
            //   gorunumden beslenir, yazma tabloya gider).
            new DetayTanimi("satirlar", "public.fiyat_listesi_satir", "liste_id", new KartAlani[]
            {
                new("id",        "id",        "sayi", Yazilabilir: false),
                new("stokId",    "stok_id",   "kod",  KodTablosu: "public.v_stok_lookup",
                    Baslik: "Stok"),
                new("hizmetId",  "hizmet_id", "kod",  KodTablosu: "public.v_hizmet_lookup",
                    Baslik: "Hizmet"),
                new("fiyat",     "fiyat",     "para", Zorunlu: true, Baslik: "Fiyat"),
                new("dovizCinsi","doviz_cinsi","kod", Baslik: "Döviz"),
                new("kdvDahil",  "kdv_dahil", "kod",  SabitKodlar: KdvDahilKodlari, Baslik: "KDV"),
                new("birim",     "birim",     "kod",  KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("durum",     "durum",     "kod",  SabitKodlar: DurumKodlari, Baslik: "Durum"),

                // Satir seviyesi KURAL EZMESI - bos birakilirsa basligin kurali.
                new("yazim",     "yazim",     "kod",  KodListesi: "fiyat_listesi.yazim",
                    Baslik: "Yazım"),
                new("tabanListeId", "taban_liste_id", "kod",
                    KodTablosu: "public.v_fiyat_listesi_lookup", Baslik: "Taban Fiyat"),
                new("carpan",    "carpan",    "para", Baslik: "Çarpan"),
                new("yuvarlama", "yuvarlama", "kod",  KodListesi: "fiyat_listesi.yuvarlama",
                    Baslik: "Yuvarlama"),
                new("tabanFiyat","taban_fiyat","para", Yazilabilir: false, Baslik: "Taban Fiyat Değeri"),
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 924, Baslik: "Satırlar")
        },
        SilmeEngelleri: new[]
        {
            // Baska bir liste bunu TABAN aliyorsa silinemez - zincirin ortasi
            //   cekilirse turetilen listeler fiyatsiz kalir.
            new SilmeEngeli("public.fiyat_listesi", "taban_liste_id",
                "Bu listeyi taban alan {0} liste var; önce onların tabanını değiştirin."),
        });

    /// <summary>Liste yonu - iki degerli, kod listesi acmaya degmez.</summary>
    private static readonly IReadOnlyDictionary<string, string> YonKodlari =
        new Dictionary<string, string> { ["1"] = "Alış", ["2"] = "Satış" };

    /// <summary>KDV dahil / haric - iki degerli, kod listesi acmaya degmez.</summary>
    private static readonly IReadOnlyDictionary<string, string> KdvDahilKodlari =
        new Dictionary<string, string> { ["0"] = "Hariç", ["1"] = "Dahil" };
}

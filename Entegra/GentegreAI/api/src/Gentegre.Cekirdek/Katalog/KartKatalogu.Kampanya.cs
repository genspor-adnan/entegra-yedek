namespace Gentegre.Cekirdek.Katalog;

public static partial class KartKatalogu
{
    /// <summary>
    /// KAMPANYA KARTI (268, kullanici: "kampanya tablo olustur... ayarlara liste
    /// ve kart olarak ekle").
    ///
    /// Kampanya bir FIYAT LISTESI uzerine isleyen indirim kurallari demetidir.
    /// Satirlar uc duzeyde tanimlanir: LISTE (tumu), KATEGORI, URUN. Hangi
    /// duzeyde oldugu `tip`, hangi tarafta (stok/hizmet) oldugu `kalemTuru`,
    /// hedefin kimligi `iskontoYeriId` ile tasinir - kullanicinin istedigi
    /// tek kolonluk sema.
    /// </summary>
    private static KartTanimi Kampanya() => new(
        Ad: "kampanya",
        YetkiKodu: "fiyat_listesi",
        Tablo: "public.kampanya",
        LogTabloId: 914,
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",               "sayi",  Yazilabilir: false),
            // Kod / sure / liste ZORUNLU (kullanici): kampanya hangi listeye,
            //   hangi tarih araliginda islediyse anlamlidir - eksigi fiyati
            //   sessizce degistirmeyen ölü kayit birakirdi.
            new("kod",             "kod",              "metin", Zorunlu: true,
                EnFazlaUzunluk: 20, Baslik: "Kod", Grup: "Kimlik"),
            new("ad",              "ad",               "metin", Zorunlu: true,
                EnFazlaUzunluk: 150, Baslik: "Kampanya", Grup: "Kimlik"),
            // Fiyat listesi de KIMLIK seridinde (kullanici: "tek sira kalsin"):
            //   kampanyanin uzerine isledigi liste kartin kimligi kadar temel.
            new("fiyatListesiId",  "fiyat_listesi_id", "kod",   Zorunlu: true,
                KodTablosu: "public.v_fiyat_listesi_satis_lookup",
                Baslik: "Fiyat Listesi", Grup: "Kimlik"),
            new("baslangic",       "baslangic",        "tarih", Zorunlu: true,
                Baslik: "Başlama", Grup: "Kimlik"),
            new("bitis",           "bitis",            "tarih", Zorunlu: true,
                Baslik: "Bitiş", Grup: "Kimlik"),
            new("durum",           "durum",            "mantik", Baslik: "Aktif", Grup: "Kimlik"),
            new("aciklama",        "aciklama",         "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Genel"),
        },
        Detaylar: new[]
        {
            new DetayTanimi("satirlar", "public.kampanya_satir", "kampanya_id", new KartAlani[]
            {
                new("id",            "id",              "sayi",  Yazilabilir: false),
                new("tip",           "tip",             "kod",   Zorunlu: true,
                    KodListesi: "kampanya.satir_tip", Baslik: "Tip"),
                new("kalemTuru",     "kalem_turu",      "kod",
                    KodListesi: "kampanya.kalem_turu", Baslik: "Stok / Hizmet"),
                // Liste satirinda 0; kategoride kategori id, urunde stok/hizmet
                //   id. Kart tarafinda tipe gore secici cizilir (GenDetayTablo).
                // KodTablosu KATEGORI listesini tasir: tip=Kategori hucresi bu
                //   seceneklerden secer, tip=Ürün'de arama penceresi acilir
                //   (stok/hizmet binlerce - combo'ya sigmaz).
                new("iskontoYeriId", "iskonto_yeri_id", "kod",
                    KodTablosu: "public.v_kategori_lookup", Baslik: "İskonto Yeri"),
                new("iskontoTipi",   "iskonto_tipi",    "kod",   Zorunlu: true,
                    KodListesi: "kampanya.iskonto_tipi", Baslik: "İskonto Tipi"),
                new("iskonto",       "iskonto",         "para",  Baslik: "İskonto"),
                // Doviz COMBO (kullanici): serbest metin yerine kasa/belge
                //   kartlariyla AYNI kod listesi - "TL" ile "TRY" karisikligi
                //   fiyati bozardi.
                new("dovizCinsi",    "doviz_cinsi",     "kod",   SabitKodlar: DovizKodlari,
                    Baslik: "Döviz"),
                new("durum",         "durum",           "mantik", Baslik: "Aktif"),
                new("aciklama",      "aciklama",        "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "tip, id", LogTabloId: 915, Baslik: "İndirim Satırları"),
        });
}

namespace Gentegre.Cekirdek.Katalog;

public static partial class KartKatalogu
{
    /// <summary>
    /// PRİM PLANI KARTI (324) - kampanya kartının prim karşılığı.
    ///
    /// Başlık KAPSAMI taşır (kimin, hangi kurumda, hangi tarihte), satırlar
    /// ORANI. Satırda üç kriter birlikte çalışır: hedef (hizmet/modalite),
    /// BELGE TÜRÜ (fiş/fatura %10, tahakkuk %12) ve PAY (hasta/kurum).
    /// En dar eşleşme kazanır - kural veritabanında (fn_prim_plan_satiri).
    /// </summary>
    private static KartTanimi PrimPlani() => new(
        Ad: "prim-plani",
        YetkiKodu: "prim",
        Tablo: "public.prim_plani",
        LogTabloId: 950,
        // Sube ALAN olarak girilir, otomatik damgalanmaz: bos birakilan plan
        //   KURUM GENELI'dir (tüm şubeler). SubeKolonu dolu olsaydi her plan
        //   oturumun subesine damgalanir, kurum geneli plan yazilamazdi.
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1, ["oncelik"] = (short)10,
            // Kullanici kararlari: tahsil edilen matrah, KDV haric.
            ["baz"] = (short)4, ["kdv_haric"] = (short)1,
            ["hekim_tipi"] = (short)0, ["baslangic"] = "@bugun",
        },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",        "sayi", Yazilabilir: false),
            new("kod",       "kod",       "metin", EnFazlaUzunluk: 30,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",        "ad",        "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Plan Adı", Grup: "Kimlik"),
            new("baslangic", "baslangic", "tarih", Zorunlu: true,
                Baslik: "Başlangıç", Grup: "Kimlik"),
            new("bitis",     "bitis",     "tarih", Baslik: "Bitiş", Grup: "Kimlik"),
            new("durum",     "durum",     "mantik", Baslik: "Aktif", Grup: "Kimlik"),
            new("oncelik",   "oncelik",   "sayi",
                Baslik: "Öncelik", Grup: "Kimlik"),

            // KAPSAM: boş alan "tümü" demektir (kampanya kartıyla aynı mantık).
            new("hekimId",   "hekim_id",  "kod",
                KodTablosu: "public.v_hekim_lookup", AramaKaynagi: "personel",
                Baslik: "Hekim", Grup: "Kapsam"),
            new("hekimTipi", "hekim_tipi","kod", KodListesi: "prim.hekim_tipi",
                Baslik: "Hekim Tipi", Grup: "Kapsam"),
            new("odeyenKurumId", "odeyen_kurum_id", "kod",
                KodTablosu: "public.v_kurum_lookup", AramaKaynagi: "kurum",
                Baslik: "Ödeyen Kurum", Grup: "Kapsam"),
            // BAZ ve KDV: kullanici karari - tahsil edilen matrah, KDV haric.
            //   Prim tahsil edildikce dogar; taban KDV'siz karsiliktir.
            new("baz",       "baz",       "kod", KodListesi: "prim.baz",
                Baslik: "Baz", Grup: "Kapsam"),
            new("kdvHaric",  "kdv_haric", "mantik",
                Baslik: "KDV Hariç (matrah)", Grup: "Kapsam"),
            new("subeId",    "sube_id",   "kod", KodTablosu: "public.sube",
                Baslik: "Şube (boş = tümü)", Grup: "Kapsam"),
            new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Kapsam"),
        },
        Detaylar: new DetayTanimi[]
        {
            new DetayTanimi("satirlar", "public.prim_plani_satir", "plan_id",
                new KartAlani[]
                {
                    // ID SART: yoksa kayitli satir "yeni" sanilip her kayitta
                    //   yeniden eklenir (satirlar cogalir).
                    new("id",        "id",        "sayi", Yazilabilir: false),
                    new("rol",       "rol",       "kod", Zorunlu: true,
                        KodListesi: "prim.rol", Baslik: "Rol"),
                    // HEDEF UC AYRI ALAN (327): her biri kendi listesinden
                    //   secilir; hedef TURU dolu olandan turetilir (generated
                    //   kolon), bu yuzden salt okunur. En fazla biri dolu
                    //   olabilir - ihlali tetik GK422 ile bildirir.
                    new("hedefTur",  "hedef_tur", "kod", KodListesi: "prim.hedef_tur",
                        Yazilabilir: false, Baslik: "Hedef Türü"),
                    // Hizmet BINLERCE: kod tablosu yerine arama penceresinden
                    //   secilir (GenDetayTablo'da kampanya urun satiriyla ayni
                    //   desen) - bu yuzden burada duz sayi alani.
                    new("hedefHizmetId", "hedef_hizmet_id", "sayi", Baslik: "Hizmet"),
                    new("hedefKategoriId", "hedef_kategori_id", "kod",
                        KodTablosu: "public.v_kategori_lookup", Baslik: "Kategori"),
                    new("hedefModalite", "hedef_modalite", "kod",
                        KodListesi: "rad.modalite", Baslik: "Modalite"),
                    // BELGE TURU kriteri: virgullu liste, bos = tumu.
                    //   Tur GELIR belgesinden okunur (basvuru 19 ara kayittir).
                    new("belgeTurleri", "belge_turleri", "metin", EnFazlaUzunluk: 60,
                        Baslik: "Belge Türleri"),
                    new("pay",       "pay",       "kod", KodListesi: "prim.pay",
                        Baslik: "Pay"),
                    new("oranTipi",  "oran_tipi", "kod", KodListesi: "prim.oran_tipi",
                        Baslik: "Oran Tipi"),
                    new("deger",     "deger",     "para", Baslik: "Değer"),
                    new("altSinir",  "alt_sinir", "para", Baslik: "Alt Sınır"),
                    new("ustSinir",  "ust_sinir", "para", Baslik: "Üst Sınır"),
                    new("sira",      "sira",      "sayi", Baslik: "Sıra"),
                    new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 200,
                        Baslik: "Açıklama"),
                },
                SubeKolonu: null, Baslik: "Prim Satırları", LogTabloId: 950),
        });
}

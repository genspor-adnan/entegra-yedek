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
            ["baz"] = (short)4, ["kdv_haric"] = (short)1, ["prim_zamani"] = (short)1,
            ["baslangic"] = "@bugun",
        },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",        "sayi", Yazilabilir: false),
            // PRIM ZAMANI ILK KAPI (332/333, kullanici): planin geri kalani
            //   bu karara gore okunur - tahsilatta mi faturalamada mi prim
            //   dogacak. Tahsilatta kesinti otomatik yansir; faturalamada
            //   hekim SGK'yi beklemez. Bu yuzden kartin EN BASINDA ve zorunlu.
            new("primZamani", "prim_zamani", "kod", Zorunlu: true,
                KodListesi: "prim.zaman", Baslik: "Prim Zamanı", Grup: "Kimlik"),
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
            // KİŞİ ALANI BURADA DEĞİL (375, kullanıcı): plan tek bir kişiye
            //   değil bir KİŞİ LİSTESİNE bağlanır - "Prim Alanlar" sekmesi.
            //   Aynı oranı alan otuz kişi için otuz plan açmak gerekiyordu.
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
                    // ROL COMBOSU ISARETLERLE UYUMLU (362): kod listesi yerine
                    //   v_prim_rol_lookup - her rolun yaninda o rolde ISARETLI
                    //   kisi sayisi yazar ("Yapan (15 kişi)" / "İsteyen — kişi
                    //   işaretlenmemiş") ve kurum tipinin varsayilan rolu ustte
                    //   durur. Kimse isaretlenmemis role plan yazilirsa hakedis
                    //   hic dogmaz; bu ancak ay sonunda fark edilirdi.
                    new("rol",       "rol",       "kod", Zorunlu: true,
                        KodTablosu: "public.v_prim_rol_lookup", Baslik: "Rol"),
                    // KAPSAM = KAMPANYA SATIRIYLA AYNI UCLU (328): tip +
                    //   kalem turu + kapsam. Ayni ekran iki yerde tanidik olsun
                    //   diye ayni kod listeleri kullanilir.
                    new("tip",       "tip",       "kod", Zorunlu: true,
                        KodListesi: "kampanya.satir_tip", Baslik: "Tipi"),
                    new("kalemTuru", "kalem_turu", "kod",
                        KodListesi: "kampanya.kalem_turu", Baslik: "Stok / Hizmet"),
                    // Liste satirinda bos; kategoride kategori id, urunde
                    //   stok/hizmet id. KodTablosu KATEGORI listesini tasir -
                    //   urun secimi arama penceresinden yapilir (binlerce kayit
                    //   combo'ya sigmaz), tipe gore hucre GenDetayTablo'da cizilir.
                    new("hedefId",   "hedef_id",  "kod",
                        KodTablosu: "public.v_kategori_lookup", Baslik: "Kapsam"),
                    // BELGE TURU kriteri: virgullu liste, bos = tumu.
                    //   Tur GELIR belgesinden okunur (basvuru 19 ara kayittir).
                    new("belgeTurleri", "belge_turleri", "metin", EnFazlaUzunluk: 60,
                        Baslik: "Belge Türleri"),
                    new("pay",       "pay",       "kod", KodListesi: "prim.pay",
                        Baslik: "Pay"),
                    // TAHSILAT TURU (330): "nakitte %12, POS'ta %10". Bos =
                    //   farketmez. Oran, paranin hangi araçla tahsil edildigine
                    //   de baglanabilir - POS komisyonu kurumda kalir.
                    new("tahsilatTuru", "tahsilat_turu", "kod",
                        KodTablosu: "public.v_tahsilat_turu_lookup",
                        Baslik: "Tahsilat Türü"),
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

            // PRİM ALANLAR (375, kullanıcı): planın kapsadığı kişiler.
            //   BOŞ = plan o roldeki HERKESE uyar; DOLU = yalnızca listedekilere.
            //   Listesi dolu plan, listesi boş olandan DAHA ÖZELDİR ve onu ezer -
            //   "MR Gönderen %20 (şu kişiler)" ile "%25 (bu kişiler)" böyle
            //   iki planla kurulur.
            //   Kişiler PRİM ROLÜ İŞARETLİ olanlardan seçilir (v_prim_taraf_lookup):
            //   rolsüz birine yazılan plan hiç hakediş üretmez ve bu ancak ay
            //   sonunda fark edilirdi.
            new DetayTanimi("taraflar", "public.prim_plani_taraf", "plan_id",
                new KartAlani[]
                {
                    new("id",       "id",       "sayi", Yazilabilir: false),
                    new("tarafId",  "taraf_id", "kod", Zorunlu: true,
                        KodTablosu: "public.v_prim_taraf_lookup",
                        AramaKaynagi: "personel", Baslik: "Kişi"),
                    new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                        Baslik: "Açıklama"),
                },
                SubeKolonu: null, Baslik: "Prim Alanlar", LogTabloId: 950),
        },
        // Kullanilmis plan SILINMEZ: hakedis satiri hangi kuraldan dogdugunu
        //   plan satirinda tasiyor (denetim izi). Engel KARTTA tanimli, cunku
        //   kart silme once DETAY satirlarini siler - o zaman kullaniciya
        //   "prim satiri silinemez" diye satir mesaji donuyordu.
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.hakedis_satir", "plan_id",
                            "Bu prim planından hakediş üretilmiş, plan silinemez. "
                            + "Planı pasife alabilirsiniz (Aktif kutusunu kaldırın)."),
        });
}

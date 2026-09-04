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
            ["durum"] = (short)1, ["oncelik"] = (short)10, ["rol"] = (short)1,
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
            // PRIM ROLU (379, kullanici: "bir prim planı sadece bir prim rolü
            //   için çalışır"). Eskiden her SATIRDA soruluyordu; plan "kime
            //   hangi sifatla" sorusunun cevabi oldugu icin basliga alindi -
            //   oranlar okunurken hangi satirin kime ait oldugunu aramak
            //   gerekmiyor. Combo rolun yaninda ISARETLI KISI SAYISINI da
            //   yazar: kimse isaretlenmemis role plan yazilirsa hakedis hic
            //   dogmaz ve bu ancak ay sonunda fark edilirdi.
            new("rol",       "rol",       "kod", Zorunlu: true,
                KodTablosu: "public.v_prim_rol_lookup",
                Baslik: "Prim Rolü", Grup: "Kimlik"),
            new("kod",       "kod",       "metin", EnFazlaUzunluk: 30,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",        "ad",        "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Plan Adı", Grup: "Kimlik"),
            new("baslangic", "baslangic", "tarih", Zorunlu: true,
                Baslik: "Başlangıç", Grup: "Kimlik"),
            new("bitis",     "bitis",     "tarih", Baslik: "Bitiş", Grup: "Kimlik"),
            // DURUM COMBO (kullanici) - onay kutusu degil. Kutu yalniz "isaretli
            //   mi" der; combo PASIF secenegini de adiyla gosterir ve plan
            //   yururlukten kaldirilirken ne yapildigi acik olur. Kodlar
            //   diger kartlarla ayni (1 Aktif / 0 Pasif).
            new("durum",     "durum",     "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // ÖNCELİK KARTTA YOK (kullanıcı). Kolon DURUYOR ve eşleştirme onu
            //   hâlâ okuyor; yeni planlar varsayılan 10 ile açılır, yani tüm
            //   planlar eşit öncelikte olur ve seçimi ÖZGÜLLÜK belirler -
            //   asıl kural zaten oydu. Alan, ancak bilinçli kurulmuş bir
            //   çakışmada anlamlıydı; ekranda durunca "büyük yazarsam kazanır"
            //   sanılıp özgüllüğü ezmeye çalışan ayarlar üretiyordu.

            // KAPSAM ARTIK AYRI KUTU DEĞİL (kullanıcı): aynı başlık bölümünün
            //   İKİNCİ SIRASI. Beş alan için ayrı bir çerçeve, kartı ikiye
            //   bölüp Prim Satırları'nı aşağı itiyordu; kapsam alanları da
            //   planın kimliğinin parçası - "ne zaman, kime, hangi kurumda".
            //   Boş alan "tümü" demektir (kampanya kartıyla aynı mantık).
            // KİŞİ ALANI BURADA DEĞİL (375, kullanıcı): plan tek bir kişiye
            //   değil bir KİŞİ LİSTESİNE bağlanır - "Prim Alanlar" sekmesi.
            //   Aynı oranı alan otuz kişi için otuz plan açmak gerekiyordu.
            new("odeyenKurumId", "odeyen_kurum_id", "kod",
                KodTablosu: "public.v_kurum_lookup", AramaKaynagi: "kurum",
                Baslik: "Ödeyen Kurum", Grup: "Kimlik"),
            // BAZ ve KDV: kullanici karari - tahsil edilen matrah, KDV haric.
            //   Prim tahsil edildikce dogar; taban KDV'siz karsiliktir.
            new("baz",       "baz",       "kod", KodListesi: "prim.baz",
                Baslik: "Baz", Grup: "Kimlik"),
            new("kdvHaric",  "kdv_haric", "mantik",
                Baslik: "KDV Hariç (matrah)", Grup: "Kimlik"),
            new("subeId",    "sube_id",   "kod", KodTablosu: "public.sube",
                Baslik: "Şube (boş = tümü)", Grup: "Kimlik"),
            new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Kimlik"),
        },
        Detaylar: new DetayTanimi[]
        {
            new DetayTanimi("satirlar", "public.prim_plani_satir", "plan_id",
                new KartAlani[]
                {
                    // ID SART: yoksa kayitli satir "yeni" sanilip her kayitta
                    //   yeniden eklenir (satirlar cogalir).
                    new("id",        "id",        "sayi", Yazilabilir: false),
                    // ROL SATIRDA SORULMAZ (379): plan basliginda - bir plan
                    //   tek rol icin calisir. Kolon tarihsel olarak duruyor.
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
                    // TIPI ve BOLUM (kullanici) - SALT OKUNUR, tarafin kendi
                    //   kaydindan okunur. Kopyalanmaz: kisi dis hekimken ic
                    //   personele gecerse (ya da bolumu degisirse) plan
                    //   satirinda eski deger kalirdi. Yazilabilir:false oldugu
                    //   icin insert/update'e girmez, yalniz select'te cizilir.
                    new("tipi",
                        "(select case when coalesce(pp.dis_hekim, 0) = 1 "
                        + "then 'Dış Hekim' else 'Personel' end "
                        + "from public.taraf_personel pp "
                        + "where pp.id = prim_plani_taraf.taraf_id)",
                        "metin", Yazilabilir: false, Baslik: "Tipi"),
                    new("tarafId",  "taraf_id", "kod", Zorunlu: true,
                        KodTablosu: "public.v_prim_taraf_lookup",
                        // IKI KAYNAK BIRDEN (375, kullanici): prim alan kisi
                        //   ic personel de olabilir DIS HEKIM de. Arama
                        //   penceresi ikisini de tarar; virgul iki listeyi
                        //   ayirir.
                        AramaKaynagi: "personel,dis-hekim", Baslik: "Kişi"),
                    // PRIM ROLU (377): kisinin ISARETLI rolleri. Bos ise plan
                    //   o kisi icin hicbir hakedis uretmez - eskiden bu durum
                    //   EKLEMEYI ENGELLIYORDU (kullanici: "enter dedim
                    //   eklemedi"). Engel yanlis yerdeydi: rol isaretlemesi
                    //   ayri bir kart ve sonradan doldurulabilir. Artik
                    //   engellemek yerine GORUNUR kilinir.
                    new("bolum",
                        "(select d.ad from public.departman d "
                        + "join public.taraf t on t.departman = d.id "
                        + "where t.id = prim_plani_taraf.taraf_id)",
                        "metin", Yazilabilir: false, Baslik: "Bölüm"),
                    // GOREV (kullanici) - bolumun saginda. Personel karti hem
                    //   gorev_id (tanimli kadro) hem serbest metin 'gorev'
                    //   tasiyor; ikisi de doluysa TANIMLI olan gecerlidir.
                    new("gorev",
                        "(select coalesce("
                        + "(select g.ad from public.personel_gorev g "
                        + "where g.id = t.gorev_id), t.gorev, '') "
                        + "from public.taraf t "
                        + "where t.id = prim_plani_taraf.taraf_id)",
                        "metin", Yazilabilir: false, Baslik: "Görev"),
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

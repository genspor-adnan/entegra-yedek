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
    /// <summary>
    /// Fiyat satirinin KALEMI kullanimda mi (531). Kategori kapatilinca
    /// hizmet/stok pasife duser (527); pasif kalemin fiyat satiri listede
    /// gorunmez - satir SILINMEZ, yalniz gizlenir.
    /// </summary>
    private const string KalemAktif =
        "(exists (select 1 from public.hizmet h9 "
        + "        where h9.id = fiyat_listesi_satir.hizmet_id and h9.durum = 1) "
        + " or exists (select 1 from public.stok s9 "
        + "        where s9.id = fiyat_listesi_satir.stok_id and s9.durum = 1))";

    private static KartTanimi FiyatListesi() => new(
        Ad: "fiyat-listesi",
        YetkiKodu: "fiyat_listesi",
        Tablo: "public.fiyat_listesi",
        LogTabloId: 923,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["kdvDahil"] = (short)0,
            // Yon SECILMEDEN kalmamali: kart "—" gosterip DB'ye 2 yazardi.
            //   Yeni liste cogunlukla satis listesidir.
            ["yon"] = (short)2,
        },
        Alanlar: new KartAlani[]
        {
            new("id",   "id",   "sayi",  Yazilabilir: false),
            // STANDART BASLIK SERIDI ("Kimlik" grubu): sekme degil, kartin ust
            //   seridinde her sekmede sabit durur - listeyi tanimlayan uc alan.
            new("ad",   "ad",   "metin", Zorunlu: true, EnFazlaUzunluk: 80,
                Baslik: "Liste Adı", Grup: "Kimlik"),
            // TARIFE TIPI (518): listenin HANGI KURALLA calistigini soyler -
            //   1 Özel (hasta oder, elle girilir) · 2 TTB/HUV (katsayi x carpan)
            //   · 3 SUT (fiyat SKRS'den, elle degismez). Satir sutunlari ve
            //   toplu islemler buna gore gorunur. `grup` TICARI siniftir
            //   (Perakende/Bayi/Toptan) - iki ayri soru, iki ayri kolon.
            new("tarifeTipi", "tarife_tipi", "kod",
                KodListesi: "fiyat_listesi.tarife_tipi",
                Baslik: "Tarife Tipi", Grup: "Kimlik"),
            new("yon", "yon", "kod", SabitKodlar: YonKodlari,
                Baslik: "Yön", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // VARSAYILAN: carisinde liste tanimlanmamis belgeler bunu kullanir.
            //   Yon basina TEK varsayilan olabilir (DB tekil indeksi).
            new("varsayilan", "varsayilan", "mantik",
                Baslik: "Varsayılan Liste", Grup: "Kimlik"),

            // TUM ALANLAR UST SERITTE (532, kullanici: "diger alanlari
            //   basliga 2. sira olarak tasi"). Liste kartinda alan sayisi
            //   dorde dustukten sonra ("Genel" sekmesinde yalniz iki kutu
            //   kaliyordu) ayri bir sekme acmak, tek satirlik bilgiyi iki
            //   tiklama arkasina koymak oluyordu. Serit dortlu izgara:
            //   ad / tarife / durum / varsayilan · yon / KDV / baslama /
            //   bitis · aciklama.
            //   1. SIRA (kullanici): ad · tarife · yon · durum · varsayilan
            //   2. SIRA (kullanici): baslama · bitis · KDV · aciklama (+ sube)

            // TABAN LISTE / CARPAN / YUVARLAMA LISTE BASLIGINDAN KALKTI
            //   (532, kullanici: "taban liste, carpan, yuvarlama, yuvarlama
            //   adimi da kaldir" - "fiyat liste satirda varsa kaldirma").
            //   Turetilmis liste kurali artik SATIR duzeyinde yasiyor: TTB
            //   tarifesinde katsayi x carpan satirda hesaplaniyor (518), liste
            //   basligindaki ayni dort alan ikinci bir kural gibi duruyordu.
            //   Kolonlar DURUYOR - `fn_sls_carpan_manuel` ve turetme zinciri
            //   onlari okuyor; yalniz kart alani kalktı.

            // BASLAMA / BITIS KART SERIDINDEN KALKTI (kullanici: "baslangic/
            //   bitis alanlari da kaldir"): uc tarifenin hicbirinde donem
            //   sinirlanmiyor (ucu de bos) - her kartta iki bos tarih kutusu
            //   doldurulmasi gereken bir alan izlenimi veriyordu. Kolonlar
            //   DURUYOR; donemli liste gerektiginde alanlar geri acilir.

            new("kdvDahil", "kdv_dahil", "kod", SabitKodlar: KdvDahilKodlari,
                Baslik: "KDV", Grup: "Kimlik"),
            // Tek alan kalinca "Fiyatlama" kutusu bos bir baslik oluyordu -
            //   aciklama Detay kutusuna gecti (532).
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Kimlik"),

            // SUBE DE SERITTE (532, kullanici: "genel sekmesini ve satirlar
            //   sekmelerini de kaldir"): tek alan kalinca "Genel" sekmesi bir
            //   satirlik bilgiyi tiklama arkasina koyuyordu. Grup bosalinca
            //   geriye tek sekme (Satirlar) kalir - GenForm tek sekmede serit
            //   cizmez, grid dogrudan govdede acilir.
            // SUBE ADIYLA (kullanici: "şube 1 görünüyor, anlamlı olsun"):
            //   ham id "1" hicbir sey soylemiyordu. Kod tipi + sube tablosu ->
            //   "Merkez". Yazilamaz: liste hangi subede acildiysa oradadir.
            new("subeId", "sube_id", "kod", Yazilabilir: false, Baslik: "Şube",
                KodTablosu: "public.sube", Grup: "Kimlik"),
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
                // KATEGORI ve KOD (kullanici: "tip sutunu saginda kategori
                //   (alt/ust) ve kod"): satirin kaleminden TURETILIR - stok mu
                //   hizmet mi olduguna bakip ilgili karttan okur. Yazilamaz:
                //   kalem degisince kendiliginden degisir, kopyalanmaz.
                new("kategoriYolu",
                    "(select case when u.id is null then k.ad " +
                    "              else u.ad || ' > ' || k.ad end " +
                    "   from public.kategori k " +
                    "   left join public.kategori u on u.id = k.ust_id " +
                    "  where k.id = coalesce(" +
                    "        (select s2.kategori from public.stok s2 " +
                    "          where s2.id = fiyat_listesi_satir.stok_id), " +
                    "        (select h2.kategori from public.hizmet h2 " +
                    "          where h2.id = fiyat_listesi_satir.hizmet_id)))",
                    "metin", Yazilabilir: false, Baslik: "Kategori"),
                // KATEGORI ID (kullanici: "satirlar sekmesinde arama editi
                //   saginda kategori agac combo"): combo secimi satirlari
                //   suzerken YOL METNI degil id gerekir - ayni ad iki agacta
                //   (Lab > Genel, Radyoloji > Genel) bulunabiliyor. Ekranda
                //   GIZLI: yalnizca suzgecin karsilastirdigi anahtar.
                new("kategoriId",
                    "coalesce((select s4.kategori from public.stok s4 " +
                    "           where s4.id = fiyat_listesi_satir.stok_id), " +
                    "         (select h4.kategori from public.hizmet h4 " +
                    "           where h4.id = fiyat_listesi_satir.hizmet_id))",
                    "sayi", Yazilabilir: false, Baslik: "Kategori Kodu"),
                new("kalemKodu",
                    "coalesce((select s3.kod from public.stok s3 " +
                    "           where s3.id = fiyat_listesi_satir.stok_id), " +
                    "         (select h3.kod from public.hizmet h3 " +
                    "           where h3.id = fiyat_listesi_satir.hizmet_id), '')",
                    "metin", Yazilabilir: false, Baslik: "Kod"),
                // KALEM ADI (526): gridde YOK - satirin adini arayuz zaten
                //   stok/hizmet lookup'indan cizer. Bu alan SUNUCU TARAFI
                //   ARAMASI icin var: sayfalama gelince "aktif olan tum
                //   satirlarda ara" istegi SQL'e indi ve aranacak ad
                //   ifadesinin katalogda durmasi gerekiyor.
                new("kalemAdi",
                    "coalesce((select s5.ad from public.stok s5 " +
                    "           where s5.id = fiyat_listesi_satir.stok_id), " +
                    "         (select h5.ad from public.hizmet h5 " +
                    "           where h5.id = fiyat_listesi_satir.hizmet_id), '')",
                    "metin", Yazilabilir: false, Baslik: "Kalem Adı"),
                // FIYAT: Özel'de hastanin odedigi, TTB'de provizyona giden,
                //   SUT'ta kurumdan alinacak tutar (518).
                new("fiyat",     "fiyat",     "para", Zorunlu: true, Baslik: "Fiyat"),
                // KATSAYI x CARPAN = FIYAT (TTB/HUV). Kolonlar zaten vardi
                //   (turetilmis listenin taban fiyati ve carpani); tarife
                //   tipinde adlari budur - ayni sayi iki yerde tutulmaz.
                //   Kolonlar asagida "Taban Fiyat Değeri"/"Çarpan" adiyla
                //   duruyordu (turetilmis liste izi); tarife tipinde adlari
                //   KATSAYI ve CARPAN - tek tanim, tek yer.
                new("tabanFiyat", "taban_fiyat", "para", Baslik: "Katsayı"),
                new("carpan",     "carpan",      "para", Baslik: "Çarpan"),
                // KATILIM PAYI (291): SUT bedeliyle AYNI SATIRDA durur - islem
                //   secilince ikisi birlikte gelsin. 0 ise listenin varsayilani.
                // KATKI: hastadan alinacak tutar (TTB'de TSS hastasi, SUT'ta
                //   katilim payi). Toplu uretilir (fn_fiyat_katki_uret), sonra
                //   elle degisebilir - uretim kilit koymaz.
                new("katkiTutar","katki_tutar","para", Baslik: "Katkı (hasta)"),
                // Ek katki sutunlari kalkti (532) - bkz. listenin Detay kutusu.
                new("dovizCinsi","doviz_cinsi","kod", Baslik: "Döviz"),
                // KDV SUTUNU SATIRDAN KALKTI (kullanici): KDV dahil/haric
                //   LISTENIN ozelligidir (Genel > Detay > KDV) - satirda
                //   tekrar sorulunca "hangisi gecerli" belirsizlesiyordu.
                //   Kolon duruyor ve tum satirlarda liste degerini izliyor.
                new("birim",     "birim",     "kod",  KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("durum",     "durum",     "kod",  SabitKodlar: DurumKodlari, Baslik: "Durum"),

                // Satirin NEREDEN geldigi (214): Manuel / Hesap / İmport.
                new("yazim",     "yazim",     "kod",  KodListesi: "fiyat_listesi.yazim",
                    Baslik: "Oluşma"),
                // TABAN LISTE / YUVARLAMA SUTUNLARI KALKTI (539, kullanici:
                //   "taban fiyat ve yuvarlama alanlari kullaniliyor mu?" ->
                //   "evet kaldir"). 28.328 satirin HICBIRINDE dolu degil:
                //   turetilmis liste zinciri bu kurulumda kullanilmiyor -
                //   SUT fiyati SKRS'den, TTB katsayi x carpan, Ozel uretim
                //   fonksiyonuyla geliyor (536). Kolonlar DURUYOR;
                //   `fn_fiyat_listesi_fiyat` ve `fn_sls_carpan_manuel` onlari
                //   okumaya devam ediyor - turetilmis liste kuran kurulumda
                //   sutunlar geri acilir.
            // SAYFALI (525, kullanici: "fiyat listesinde satirlar cok fazla
            //   oldugu icin yavas, paging yapsan"): SKRS'den kurulan SUT
            //   listesi 14.117 satir - kart yaniti 4,4 MB'a cikiyor, tarayici
            //   o kadar satiri cizerken kilitleniyordu. Kartla ilk sayfa
            //   gelir, gerisi sayfa seridinden istenir.
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 924, Baslik: "Satırlar",
               SayfaBoyu: 200,
               // SUZGECLER SUNUCUDA (526, kullanici: "fiyat listesi
               //   satirlardaki arama ve filtreler aktif olan TUM satirlar
               //   uzerinden olmali"): sayfalamadan sonra istemci suzgeci
               //   yalniz ekrandaki 200 satiri tariyordu.
               AraAlanlari: new[] { "kalemKodu", "kalemAdi" },
               KategoriAlani: "kategoriId",
               // PASIF KALEM GIZLI (531, kullanici: "kurum profiline girip
               //   kategorilerden girisimi kaldirdim ama fiyat listelerine
               //   geliyor"). Kategori kapatilinca altindaki hizmet/stoklar
               //   pasife duser (527) ama fiyat SATIRI durur - fiyat bilgisi
               //   kaybolmasin diye silinmiyor. Satir artik LISTELENMIYOR:
               //   kurumun yapmadigi islemin fiyatini gostermek, o islemi
               //   satilabilir gibi sunar. "Pasif" cipi onlari geri getirir.
               Cipler: new Dictionary<string, string>(StringComparer.Ordinal)
               {
                   ["aktif"]  = KalemAktif,
                   ["stok"]   = "fiyat_listesi_satir.stok_id is not null and " + KalemAktif,
                   ["hizmet"] = "fiyat_listesi_satir.hizmet_id is not null and " + KalemAktif,
                   ["pasif"]  = "not " + KalemAktif,
               },
               VarsayilanCip: "aktif")
        }
        // SILME ENGELI YOK (539): tek engel "baska liste bunu taban aliyor"
        //   kuraliydi; turetilmis liste mekanizmasi kalkinca konusu kalmadi.
        );

    /// <summary>Liste yonu - iki degerli, kod listesi acmaya degmez.</summary>
    private static readonly IReadOnlyDictionary<string, string> YonKodlari =
        new Dictionary<string, string> { ["1"] = "Alış", ["2"] = "Satış" };

    /// <summary>KDV dahil / haric - iki degerli, kod listesi acmaya degmez.</summary>
    private static readonly IReadOnlyDictionary<string, string> KdvDahilKodlari =
        new Dictionary<string, string> { ["0"] = "Hariç", ["1"] = "Dahil" };
}

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DIŞ HEKİM ve HIZLI HASTA kartları.
///
/// KartKatalogu.Cari.cs dosyasindan ayrildi: tek dosyada 1140 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>
    /// DIS DOKTOR KARTI (305) - goruntuleme merkezine hasta GONDEREN, kurum
    /// disindaki hekim.
    ///
    /// Personel kartinin kardesi: ayni taraf + taraf_personel ikilisini
    /// kullanir, ayirt eden taraf_personel.dis_hekim = 1. Ayri tablo acmak
    /// ad/telefon/adres alanlarini ikinci kez tanimlamak olurdu; ustelik ayni
    /// kisi hem kurumda calisip hem baska merkezden sevk edebiliyor.
    ///
    /// Personelden FARKI: sicil no, departman, gorev, ise giris gibi OZLUK
    /// alanlari yok - onun yerine brans, calistigi kurum ve tescil no var.
    /// </summary>
    private static KartTanimi DisHekim() => new(
        Ad: "dis-hekim",
        YetkiKodu: "personel",
        Tablo: "public.taraf",
        LogTabloId: 73,
        // taraf.sube_id NOT NULL: kayit oturumun subesiyle yazilsin diye sube
        //   kolonu ACIKCA verilir (KartTanimi varsayilani null'dur). Dis hekim
        //   subeye ait degil ama kolon dolmali - kullanicidan sorulmaz.
        SubeKolonu: "sube_id",
        // Kart YALNIZ dis hekimleri acar: kurum personeli bu ekrandan
        //   duzenlenmemeli (orada departman/gorev zorunlu).
        SabitKosul: "personel = 1 and exists (select 1 from public.taraf_personel p "
                  + "where p.id = taraf.id and p.dis_hekim = 1)",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["personel"] = (short)1,
            ["durum"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",       "id",       "sayi",  Yazilabilir: false),
            new("personel", "personel", "mantik", Gizli: true),
            // Unvan ad+soyaddan turetilir (personel kartiyla ayni kural).
            new("unvan",    "unvan",    "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Unvan", Gizli: true),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 50,
                Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",    "soyad",    "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Soyad", Grup: "Kimlik"),
            // Kod ZORUNLU DEGIL: dis hekimin bizde sicili yok - bos birakilirsa
            //   sunucu numara vermez, ad soyad yeter.
            new("kod",      "kod",      "metin", EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Kimlik"),
            // BOLUM AGAC COMBOSU, KODUN SAGINDA (577, kullanici). Alan ZATEN
            //   VARDI (309: kurum secilince dolan duz combo) - yeri ve
            //   cizimi degisti: IC HEKIMLE AYNI alan (`taraf.departman`),
            //   ayni agac. Goruntuleme/lab merkezinde basvurunun bolumu
            //   buradan cozulur, dis hekim ic hekimden farkli davranmaz.
            new("departman","departman","kod",   KodTablosu: "public.v_departman_agac_lookup",
                Agac: true, Baslik: "Bölüm", Grup: "Kimlik"),
            new("durum",    "durum",    "kod",   SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // TEMSILCI = BIZIM personelimiz (kullanici): bu hekimle ilgilenen,
            //   iliskiyi yuruten kisi - hekimin kendi kurumundaki biri degil.
            new("temsilci", "temsilci", "kod",   KodTablosu: "public.v_personel_lookup",
                Baslik: "Temsilci", Grup: "Kimlik"),
            // BOLUM (367, kullanici: "seçtim ama bölüm dolmadı"): gonderen
            //   hekimin hastayi HANGI BOLUME gonderdigi. Basvuruda hekim
            //   secilince Bölüm alani bundan doldurulur - memur ayni bilgiyi
            //   ikinci kez secmesin. Bos birakilabilir (o zaman bolum elle).
            new("cepTel",   "cep_tel",  "metin", EnFazlaUzunluk: 30, Baslik: "Cep"),
            new("telefon",  "telefon",  "metin", EnFazlaUzunluk: 30, Baslik: "Telefon"),
            new("eposta",   "eposta",   "metin", EnFazlaUzunluk: 200, Baslik: "E-posta"),
            // CALISTIGI KURUM (309): personel uzantisinda DEGIL tarafin kendi
            //   bag_id'sinde - "Bağlı Kurum" bagi kisi/cari ekranlariyla ortak,
            //   ayni bilgiyi ikinci bir kolonda tutmak gerekmiyor. Yalniz
            //   KAYITLI cari (308): kayitli degilse arama ekranindaki "+ Yeni".
            //   Combo degil JENERIK ARAMA: cari listesi binlerce kayit olabilir;
            //   KodTablosu secili kaydin ADINI cozmek icin durur.
            //   Grup "Hekim Bilgisi": sekme olarak DEGIL, Genel sekmesindeki
            //   Hekim Bilgisi kutusunun icinde cizilir (KartGrupSekmesi).
            // BRANS = JENERIK GOREV AGACI (577): eskiden `taraf_personel.brans`
            //   + `hekim.brans` KOD LISTESI idi; ayni bilgi ic hekimde
            //   `taraf.gorev_id` + `personel_gorev` TABLOSU olarak duruyordu.
            //   Tek kaynak: gorev agaci ("Hekim Branşları" dali).
            //   YERI "Hekim Bilgisi" KUTUSUNUN EN USTU (kullanici): baslikta
            //   BOLUM durur, brans hekimin mesleki bilgisidir - tescil no ve
            //   calistigi kurumla ayni kutuya aittir.
            new("gorevId",  "gorev_id", "kod",   KodTablosu: "public.v_gorev_agac_lookup",
                Agac: true, Baslik: "Branş", Grup: "Hekim Bilgisi"),
            new("kurumId",  "bag_id",   "kod",   KodTablosu: "public.v_cari_lookup",
                AramaKaynagi: "cari", Baslik: "Kurum", Grup: "Hekim Bilgisi"),
            // TC No YOK (kullanici): dis hekimin kimlik numarasini biz tutmuyoruz -
            //   sevk eden hekim icin gerekli olan iletisim ve tescil bilgisidir.
            // taraf'ta serbest not kolonu "notlar" (aciklama YOK).
            new("notlar",   "notlar",   "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            // subeId ALAN OLARAK YOK: dis hekim subeye ait degil ama taraf.sube_id
            //   NOT NULL - kart tanimindaki SubeKolonu sayesinde oturumun subesi
            //   kayit sirasinda yazilir. Personel kartinda alan VAR cunku orada
            //   "calistigi sube" gercek bir bilgi; burada degil.
        },
        Detaylar: new[]
        {
            new DetayTanimi("hekim", "public.taraf_personel", "id", new KartAlani[]
            {
                new("id",       "id",        "sayi", Yazilabilir: false),
                // BRANS ALANI BASLIGA TASINDI (577) - burada birakmak ayni
                //   bilgiyi iki yerden sordurur. Kolon duruyor (MEDULA
                //   gonderimi okuyor), yazan tek yer artik kartin basligi.
                new("bransEski","brans",     "kod", KodListesi: "hekim.brans", Gizli: true,
                    Baslik: "Branş"),
                new("tescilNo", "tescil_no", "metin", EnFazlaUzunluk: 30,
                    Baslik: "Diploma / Tescil No"),
                // taraf_personel'de ZATEN VAR - dis hekimde "kadrolu / part-time /
                //   serbest" ayrimini tasir, yeni kolon gerekmedi.
                new("calismaSekli", "calisma_sekli", "kod",
                    SabitKodlar: CalismaSekliKodlari, Baslik: "Çalışma Şekli"),
            // SubeKolonu VARSAYILAN: taraf_personel.sube_id NOT NULL - detay
            //   satiri oturumun subesiyle yazilir (null verilirse insert
            //   "subeId bos birakilamaz" ile patlar).
            }, Baslik: "Hekim Bilgisi", LogTabloId: 906, TekSatir: true,
               // Kaydi DIS hekim yapan bayrak KULLANICIDAN ISTENMEZ (305):
               //   hangi karttan girildigiyle belli. Kutu isaretlettirmek, ayni
               //   tabloyu paylasan iki kart arasindaki farki kullanicinin
               //   sorumluluguna atmak olurdu.
               YeniSatirVarsayilanlari: new Dictionary<string, object?>
               {
                   ["dis_hekim"] = (short)1,
               }),

            // ADRES (kullanici: "alta grid olarak da adres gelsin"): bir hekimin
            //   MUAYENEHANESI ve calistigi HASTANE(ler) ayri satirlardir - tek
            //   adres yetmez. Tablo cari/personel ile ayni, degisen yalniz tip
            //   listesi: burada "ev/is" degil "muayenehane/hastane" sorulur.
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: HekimAdresTurKodlari,
                    Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik"),
            }, Sirala: "varsayilan desc, id", LogTabloId: 901, Baslik: "Adres"),

            // GONDERIM GECMISI KATALOGDA DEGIL (305, kullanici: "frame kaldir
            //   ve gridi readonly gengrid yap"): detay tanimi kart formunun
            //   duzenlenebilir satir gridini cizerdi - burada gosterilen sey
            //   BASKA BIR EKRANIN kayitlari (radyoloji istemleri), duzenlenmez.
            //   Kartin "Gönderim Geçmişi" sekmesini KartGrupSekmesi ciziyor:
            //   liste ekranlarindaki GenGrid, salt okunur, hekim filtresiyle.
        });

    private static KartTanimi HastaAday() => new(
        Ad: "hasta-aday",
        YetkiKodu: "personel",
        Tablo: "public.taraf",
        LogTabloId: 71,
        SubeKolonu: null,
        SabitKosul: "hasta = 1",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["grup"] = (short)101,
            ["hasta"] = (short)1,
            ["musteri"] = (short)1,
            ["durum"] = (short)2,          // ADAY
        },
        Alanlar: new KartAlani[]
        {
            new("id",       "id",       "sayi",  Yazilabilir: false),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 50,
                Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",    "soyad",    "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Soyad", Grup: "Kimlik"),
            new("cepTel",   "cep_tel",  "metin", Zorunlu: true, EnFazlaUzunluk: 30,
                Baslik: "Cep", Grup: "Kimlik"),
            // Durum kimlik seridinde DEGIL arac cubugunda ROZET (kullanici):
            //   aday kaydinda degistirilecek bir alan degil, bir DURUM bilgisi.
            new("durum",    "durum",    "kod",   SabitKodlar: HastaDurumKodlari,
                Baslik: "Durum", Gizli: true),
            new("eposta",   "eposta",   "metin", EnFazlaUzunluk: 200, Baslik: "E-posta"),
            new("vkno",     "vkno",     "metin", EnFazlaUzunluk: 20, Baslik: "TC No"),
            // Dosya no (kod) CEP NUMARASINDAN uretilir - ekranda gosterilmez.
            new("kod",      "kod",      "metin", EnFazlaUzunluk: 20, Gizli: true),
            new("unvan",    "unvan",    "metin", EnFazlaUzunluk: 120, Gizli: true),
            // taraf.sube_id NOT NULL: alan GIZLI ama var - kart acilirken
            //   oturumun subesiyle dolar (GenForm yeni kayit varsayilani).
            new("subeId",   "sube_id",  "kod",   Gizli: true),
            new("grup",     "grup",     "kod",   Gizli: true),
            new("hasta",    "hasta",    "mantik", Gizli: true),
            new("musteri",  "musteri",  "mantik", Gizli: true),
        },
        Detaylar: new[]
        {
            // Hasta bilgisi (1:1): aday kartinda yalniz cinsiyet, dogum tarihi
            //   ve kurum - digerleri tam hasta kartinda.
            new DetayTanimi("ozluk", "public.taraf_hasta", "id", new KartAlani[]
            {
                new("id",          "id",           "sayi",  Yazilabilir: false),
                // Hasta acilirken bile ZORUNLU: yas/cinsiyet olmadan tetkik
                //   referansi ve hizmet uygunlugu kararlastirilamaz.
                new("cinsiyet",    "cinsiyet",     "kod",   Zorunlu: true,
                    KodListesi: "hasta.cinsiyet", Baslik: "Cinsiyet"),
                new("dogumTarihi", "dogum_tarihi", "tarih", Zorunlu: true,
                    Baslik: "Doğum Tarihi"),
                // Kurum KIMLIK SERIDINDE cizilir (266) - burada yalniz veri
                //   tasiyicisi olarak duruyor, ekranda tekrar gosterilmez.
                new("kurumId",     "kurum_id",     "kod",   KodTablosu: "public.v_kurum_lookup",
                    Baslik: "Kurum", Gizli: true),
            }, SubeKolonu: null, Baslik: "Hasta Bilgisi", LogTabloId: 907, TekSatir: true),
            // IL / ILCE taraf'ta degil ADRES tablosunda (taraf_adres): aday
            //   kartinda tek adres satiri yeter, tam kartta adres listesi var.
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",   "id",   "sayi",  Yazilabilir: false),
                new("il",   "il",   "metin", EnFazlaUzunluk: 60, Baslik: "İl"),
                new("ilce", "ilce", "metin", EnFazlaUzunluk: 60, Baslik: "İlçe"),
            }, LogTabloId: 901, Baslik: "Adres", TekSatir: true),
        });
}

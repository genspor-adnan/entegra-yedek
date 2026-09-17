namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// LABORATUVAR İSTEM KARTI ve e-Nabız kod eşlemesi.
///
/// KartKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1448 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi LabIstemKarti() => new(
        Ad: "lab-istem",
        YetkiKodu: "lab",
        Tablo: "public.lab_istem",
        LogTabloId: 961,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["bolum"] = (short)1,           // Biyokimya
            ["durum"] = (short)1,           // İstendi
            // ONCELIK NORMAL (kullanici). Kolonun DB varsayilani zaten 1 ama
            //   kart YENI kayitta kutuyu bos aciyordu ("—"): kullanici her
            //   istemde secmek zorunda kaliyor, unutulursa kayit sirasinda
            //   sessizce 1 yaziliyordu - ekranda gorunen ile kaydedilen
            //   ayriydi.
            ["oncelik"] = (short)1,         // Normal
            ["istemTarihi"] = "@simdi",
            // KAYNAK VARSAYILANI DIŞ KURUM (kullanici). Başvurudan doğan
            //   istem KART ÜZERİNDEN açılmaz - o yol uçta (başvuru
            //   kaydedilince kendiliğinden). Karttan "Yeni" diyen kişi
            //   pratikte dışarıdan gelen numuneyi giriyor; varsayılanı
            //   "muayene istemi" bırakmak her seferinde düzeltilecek bir
            //   değer demekti.
            ["kaynak"] = (short)4,          // Dış kurum
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // KIMLIK SERIDI (mockup lab_hasta_istem_karti.html): hasta, istem
            //   numarasi ve ONCELIK her sekmede ustte durur - acil istem
            //   sekme degistirince gozden kaybolmamali.
            new("tarafId", "taraf_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Kimlik"),
            // ISTEM NO YAZILAMAZ, SERITTE DE DURMAZ (kullanici: "Istem No
            //   editi kaldir, kaydedince otomatik olsun; duzenle diye girince
            //   baslikta gorsun" + "istem no yerine Kaynak olsun").
            //
            //   Numara kaydederken TETIKLE uretilir (641), numaralandirma
            //   ayarindaki (tur 901) on ek ve haneye gore. Elle yazilan
            //   numara sayacla cakisirdi.
            //
            //   Kartin KIMLIK SERIDINDE yerini KAYNAK aldi: numara zaten
            //   kart basliginda rozet olarak duruyor (ListeKarti.baslikEk) -
            //   ayni bilgiyi iki yerde tutmak, seritte gercekten karar
            //   degistiren bir alana (numune nereden geldi) yer birakmiyordu.
            new("kaynak", "kaynak", "kod", SabitKodlar: LabKaynakKodlari,
                Baslik: "Kaynak", Grup: "Kimlik"),
            new("oncelik", "oncelik", "kod", SabitKodlar: LabOncelikKodlari,
                Baslik: "Öncelik", Grup: "Kimlik"),
            // BOLUM ONCELIGIN SAGINDA, SERITTE (kullanici). Tetkikin hangi
            //   banka gidecegi kabul masasinin ilk sorusu; sekme icinde
            //   kalinca her bakista bir tiklama gerekiyordu.
            new("bolum", "bolum", "kod", SabitKodlar: LabBolumKodlari,
                Baslik: "Bölüm", Grup: "Kimlik"),
            // ISTEM TARIHI SERITTE, DURUMUN SOLUNDA ve SAATLI (kullanici).
            //   Tip "zaman": laboratuvarda gun yetmez - TAT saat basinda
            //   olculuyor ve "sabah mi aksam mi istendi", numunenin beklemis
            //   olup olmadigini soyleyen ilk bilgi.
            new("istemTarihi", "istem_tarihi", "zaman", Zorunlu: true,
                Baslik: "İstem Tarihi", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: LabDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // ISTEM: ne zaman, KIMDEN geldi, kim istedi (kullanici sirasi:
            //   "Istem tarihi altina sirayla Dis Kurum, Isteyen Hekim").
            //   Kart varsayilani dis kurum numunesi oldugu icin once gonderen
            //   kurum soruluyor - hekim de o kurumun hekimi.
            //   KAYNAK, BOLUM ve ISTEM TARIHI kimlik seridine tasindi
            //   (yukari bakin).
            // IKISI DE JENERIK ARAMA PENCERESIYLE (kullanici): combo binlerce
            //   kayitta kullanilmaz hale geliyor ve dis numunede aranan sey
            //   ANLASMALI KURUM ile DIS DOKTORDUR.
            new("disKurumId", "dis_kurum_id", "kod", KodTablosu: "public.v_kurum_lookup",
                AramaKaynagi: "kurum",
                Baslik: "Dış Kurum", Grup: "İstem", AltGrup: "İstem"),
            // BASVURUNUN KURUMU - YAZILAMAZ (kullanici: "kaynak Dis Kurum
            //   degilse label sadece Kurum olacak ve karsisinda basvurudaki
            //   kurum gelecek").
            //
            //   Ic istemde odeyen kurum BASVURUDA belirlenir; istemde ikinci
            //   bir kopyasini tutmak iki kaynak demekti - basvurunun kurumu
            //   degisince istemdeki eski deger kalirdi. Bu yuzden kolon
            //   degil, basvurudan COZULEN alan.
            //
            //   Ekran ikisinden yalniz BIRINI cizer: kaynak "Dis kurum" (4)
            //   ise secilebilir "Dış Kurum", degilse salt okunur "Kurum"
            //   (kartAlanCizim'deki lab-istem kurali).
            new("kurumAdi",
                "(select coalesce(t.unvan, '') from public.belge_basvuru bb "
                + "  join public.taraf t on t.id = bb.odeyen_kurum_id "
                + " where bb.id = lab_istem.belge_id)",
                "metin", Yazilabilir: false,
                Baslik: "Kurum", Grup: "İstem", AltGrup: "İstem"),
            // ISTEYEN HEKIM: once DIS DOKTOR, sonra ic personel. Karttan
            //   acilan istem genelde dis numunedir (kaynak varsayilani da o)
            //   ama ic istem de girilebiliyor - yalniz dis hekimi aratmak o
            //   yolu kapatirdi.
            new("personelId", "personel_id", "kod", KodTablosu: "public.v_personel_lookup",
                AramaKaynagi: "dis-hekim,personel",
                Baslik: "İsteyen Hekim", Grup: "İstem", AltGrup: "İstem"),
            // Numara salt okunur, tetikten geliyor (641).
            new("istemNo", "istem_no", "metin", EnFazlaUzunluk: 30,
                Yazilabilir: false, Baslik: "İstem No",
                Grup: "İstem", AltGrup: "İstem"),
            new("belgeId", "belge_id", "sayi",
                Baslik: "Başvuru (Protokol Id)", Grup: "İstem", AltGrup: "İstem"),

            // KLINIK BILGI olmadan sonuc yorumlanamaz: "neden istendi"
            //   sorusunun cevabi raporun bir parcasidir.
            new("klinikBilgi", "klinik_bilgi", "metin", EnFazlaUzunluk: 500,
                Baslik: "Klinik Bilgi", Grup: "İstem", AltGrup: "Klinik"),
            // ICD KODU METINDIR ("J03.9"), sayisal lookup id'si degil: kod
            //   tablosuna baglamak "bos deger sayiya cevrilemedi" hatasi
            //   veriyordu. Ad cozumu ekranda ICD arama penceresinden gelir.
            new("taniIcd", "tani_icd", "metin", EnFazlaUzunluk: 20,
                Baslik: "Tanı (ICD-10)", Grup: "İstem", AltGrup: "Klinik"),

            // Numune ve sonuc zamanlari AYRI: "ne zaman alindi / ne zaman cikti"
            //   laboratuvarin temel performans sorusudur.
            //
            // SAATLI (kullanici: "surec sekmesinde de zamanlarin yaninda saat
            //   olsun"). Gun cozunurlugu bu soruyu cevaplamiyor: TAT numune
            //   KABULUNDE baslar ve dakikayla olculur; gecikmenin numune
            //   alimda mi calismada mi oldugu ancak saatle gorulur. Kolonlar
            //   zaten `timestamp` - eksik olan ekrandi.
            new("numuneTarihi", "numune_tarihi", "zaman",
                Baslik: "Numune Alma", Grup: "Süreç", AltGrup: "Zaman"),
            new("sonucTarihi", "sonuc_tarihi", "zaman",
                Baslik: "Sonuç", Grup: "Süreç", AltGrup: "Zaman"),
            // HEDEF BITIS = sozu verilen sure (TAT). Saat KABULDE baslar;
            //   sunucu kabul aninda yazar, elle degistirilebilir.
            new("hedefBitis", "hedef_bitis", "zaman",
                Baslik: "Hedef Bitiş (TAT)", Grup: "Süreç", AltGrup: "Zaman"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Süreç", AltGrup: "Zaman")
        },
        Detaylar: new DetayTanimi[]
        {
            // TESTLER: istemin satirlari. Sonuc girisi de burada - ayri bir
            //   "sonuc girisi" ekrani, teknisyeni ayni kaydin iki yuzu arasinda
            //   gezdirirdi.
            // 433: tablo lab_istem_test -> lab_istem_satir olarak adlandirildi.
            //   Kart eski ada bakmaya devam ettigi icin lab istemi ACILMIYORDU
            //   ("relation public.lab_istem_test does not exist"). Yeniden
            //   adlandirma yapan gocun, o tabloyu okuyan HER yeri (liste
            //   katalogu + kart katalogu) taramasi gerekiyordu.
            //
            //   Satirdaki sonuc/birim/referans/isaret alanlari 433 oncesinden
            //   kalan ELLE GIRIS alanlaridir; asil sonuc lab_sonuc'ta durur
            //   (onay ve duzeltme gecmisi tek satira sigmiyordu) ve Sonuclar
            //   ekranindan yonetilir.
            new("satirlar", "public.lab_istem_satir", "istem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                // TETKIK KENDI LISTESINDEN SECILIR (kullanici: "tetkik
                //   ekleme arama yanlis, hizmet yerine baska sey ariyor").
                //
                //   Grid basligindaki arama dugmesi detaydaki ILK
                //   `aramaKaynagi` tanimli kod alanina yazar
                //   (`GenDetayTablo`: `alanlar.find(a => a.tip === 'kod' &&
                //   a.aramaKaynagi)`). O alan `stokId` idi: tetkik eklemek
                //   icin arama acinca HIZMET listesi geliyor ve secilen kayit
                //   `lab_istem_satir.stok_id` kolonuna yaziliyordu - o
                //   kolonun yabanci anahtari bile yok, 45 satirin hicbirinde
                //   dolu degil. Yani eklenen tetkik hicbir yere baglanmiyordu.
                //
                //   `stokId` alani KALDIRILDI, arama TETKIGE baglandi.
                //   Pencere (`TarafArama`) satirlari `unvan` alanindan
                //   ciziyordu; tetkik/hizmet/stok kaynaklarinda o kolon YOK -
                //   pencere bos adlarla acilirdi. Cizim `ad`a duser hale
                //   getirildi (ayni tuzak uretim, radyoloji ve randevu
                //   kartlarinda da vardi).
                //   ARAMA JENERIK HIZMET PENCERESI (kullanici: "tetkik
                //   ekleme icin arama ekranina jenerik hizmet arama
                //   gelmelidir"): kabul masasi SUT kodunu/adini biliyor,
                //   laboratuvarin ic tetkik kodunu degil - ustelik kategori
                //   agaciyla aranan pencere oteki ekranlarda da bu.
                //   Secilen hizmetin laboratuvar karsiligi (panel ya da tek
                //   tetkik) `/api/lab/hizmet/{id}/tetkik` ile cozulur.
                new("tetkikId", "tetkik_id", "kod",
                    KodTablosu: "public.v_lab_tetkik_lookup",
                    AramaKaynagi: "hizmet", Baslik: "Tetkik"),
                new("panelId", "panel_id", "kod",
                    KodTablosu: "public.v_lab_panel_lookup", Baslik: "Panel"),
                new("kod", "kod", "metin", EnFazlaUzunluk: 30, Baslik: "Kod"),
                new("ad", "ad", "metin", EnFazlaUzunluk: 200, Baslik: "Test Adı"),
                new("durum", "durum", "kod", SabitKodlar: LabSatirDurumKodlari,
                    Baslik: "Durum"),
                // SONUC ALANLARI KART KAYDIYLA YAZILMAZ (Yazilabilir: false).
                //   Asil sonuc `lab_sonuc`ta: referans, bayrak, panik ve delta
                //   orada hesaplanir, onay ve duzeltme gecmisi orada durur.
                //   Bu kolonlar AYNADIR - sunucu sonuc yazarken doldurur.
                //   Satir duzenleme modalinden elle yazilabildigi surece
                //   kural motorunu atlayan "sonuc"lar olusuyordu: deger
                //   satirda gorunuyor ama lab_sonuc kaydi yok, bayrak yok,
                //   onay kuyruguna girmiyor, e-Nabiz'a gitmiyor.
                //   Gridde SONUC hucresi yine yazilabilir - o hucre `POST
                //   /api/lab/sonuc` ucuna gider (GenDetayTablo.hucreYaz).
                new("sonuc", "sonuc", "metin", EnFazlaUzunluk: 100, Baslik: "Sonuç",
                    Yazilabilir: false),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim",
                    Yazilabilir: false),
                new("referans", "referans", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Referans Aralığı", Yazilabilir: false),
                new("isaret", "isaret", "kod", SabitKodlar: LabIsaretKodlari,
                    Baslik: "Değerlendirme", Yazilabilir: false),
                new("cihazId", "cihaz_id", "kod", KodTablosu: "public.v_cihaz_lookup",
                    Baslik: "Cihaz"),
                // GIRISIN KAYNAGI (kullanici: "sonucu elle degistirdigim /
                //   girdigim bilgisi nerede"): sonuc yazilirken damgalanir -
                //   "Elle · <kullanici>" ya da cihaz kodu. "Cihaz (metin)"
                //   basligi ne tasidigini soylemiyordu.
                new("cihaz", "cihaz", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Giriş", Yazilabilir: false),
                // NUMUNE BAGI (433): satir hangi tupten calisilacak. Tup plani
                //   "Barkod Üret" ile cikar; burada gorunur olmasi, "bu tetkik
                //   hangi tupte" sorusunu kart icinde cevaplar.
                new("numuneId", "numune_id", "kod", KodTablosu: "public.v_lab_numune_lookup",
                    Baslik: "Numune / Barkod"),
                new("sonucTarihi", "sonuc_tarihi", "tarih", Baslik: "Sonuç Zamanı",
                    Yazilabilir: false),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama")
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Tetkikler",
               LogTabloId: 1288),

            // NUMUNELER (mockup "Etiketler" kutusu): tup plani, alim/kabul
            //   zamanlari ve KALITE. Ret nedeni gorunur kalir - hasta ikinci
            //   kez kan verirken ayni hatayla geri gelmesin.
            new DetayTanimi("numuneler", "public.lab_numune", "istem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("barkod", "barkod", "metin", EnFazlaUzunluk: 40, Yazilabilir: false,
                    Baslik: "Barkod"),
                new("numuneTipi", "numune_tipi", "kod", SabitKodlar: LabNumuneTipiKodlari,
                    Baslik: "Numune"),
                new("tupTipi", "tup_tipi", "kod", SabitKodlar: LabTupTipiKodlari,
                    Baslik: "Tüp"),
                new("durum", "durum", "kod", SabitKodlar: LabNumuneDurumKodlari,
                    Baslik: "Durum"),
                new("alanId", "alan_id", "kod", KodTablosu: "public.v_personel_lookup",
                    Baslik: "Alan"),
                new("alimYeri", "alim_yeri", "kod", SabitKodlar: LabAlimYeriKodlari,
                    Baslik: "Alım Yeri"),
                new("alimZamani", "alim_zamani", "zaman", Baslik: "Alım"),
                new("kabulZamani", "kabul_zamani", "zaman", Baslik: "Kabul"),
                new("kalite", "kalite", "kod", SabitKodlar: LabKaliteKodlari,
                    Baslik: "Kalite"),
                // SERUM INDEKSI: sonucun guvenilirlik olcusu (hemoliz/lipemi/
                //   ikter). Esigi asan deger tetkigi otomatik reddettirir.
                new("hemolizIdx", "hemoliz_idx", "sayi", Baslik: "Hemoliz"),
                new("lipemiIdx", "lipemi_idx", "sayi", Baslik: "Lipemi"),
                new("ikterIdx", "ikter_idx", "sayi", Baslik: "İkter"),
                new("saklamaYeri", "saklama_yeri", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Saklama Yeri"),
                new("saklamaSicaklik", "saklama_sicaklik", "sayi", Baslik: "°C"),
                new("ret", "ret", "mantik", Baslik: "Ret"),
                new("retNeden", "ret_neden", "kod", SabitKodlar: LabKaliteKodlari,
                    Baslik: "Ret Nedeni"),
                new("retAciklama", "ret_aciklama", "metin", EnFazlaUzunluk: 300,
                    Baslik: "Ret Açıklaması"),
            }, SubeKolonu: "sube_id", Sirala: "id", Baslik: "Numuneler",
               LogTabloId: 1290)
        });

    /// <summary>
    /// e-NABIZ KOD EŞLEME KARTI (454).
    ///
    /// Eşleme türü SERBEST METİN değil sabit listedir: "klinik" ile "Klinik"
    /// iki ayrı tür sayılırsa paket üreticisi eşlemeyi bulamaz ve alan yine
    /// eksik kalır.
    /// </summary>
    private static KartTanimi EnabizKodEslemeKarti() => new(
        Ad: "enabiz-kod-esleme",
        YetkiKodu: "entegrasyon",
        Tablo: "public.enabiz_kod_esleme",
        LogTabloId: 1093,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("eslemeTuru", "esleme_turu", "kod", Zorunlu: true,
                SabitKodlar: EnabizEslemeTurleri, Baslik: "Eşleme Türü", Grup: "Eşleme"),
            // HANGI ALAN ESLESIR, TURE GORE DEGISIR: paket üreticisi KLINIK'te
            //   `yerel_id` (bölüm), BAŞVURU TÜRÜ'nde `yerel_kod` üzerinden
            //   arar. İkisi de kartta duruyor; başlıklar hangisinin ne zaman
            //   dolacağını söyler - yanlış alanı doldurmak eşlemeyi sessizce
            //   çalışmaz hâle getirirdi.
            new("yerelId", "yerel_id", "kod", KodTablosu: "public.v_randevu_bolum_lookup",
                Baslik: "Bölüm (KLİNİK eşlemesi için)", Grup: "Eşleme"),
            new("yerelKod", "yerel_kod", "metin", EnFazlaUzunluk: 60,
                Baslik: "Yerel Kod (başvuru türü için)", Grup: "Eşleme"),
            new("aktif", "aktif", "kod", SabitKodlar: EnabizAktifKodlari,
                Baslik: "Durum", Grup: "Eşleme"),

            new("skrsListe", "skrs_liste", "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "SKRS Listesi", Grup: "SKRS"),
            new("skrsKod", "skrs_kod", "metin", Zorunlu: true, EnFazlaUzunluk: 30,
                Baslik: "SKRS Kodu", Grup: "SKRS"),
            new("skrsAd", "skrs_ad", "metin", EnFazlaUzunluk: 200,
                Baslik: "SKRS Karşılığı", Grup: "SKRS"),
        });

    /// <summary>Eşleme türü: paket üreticisinin aradığı anahtar.</summary>
    /// <summary>
    /// Eşleme türü: paket üreticisinin ARADIĞI anahtar (büyük harf, birebir).
    ///
    /// Listede YALNIZ üreticinin bugün okuduğu türler var. Okunmayan bir tür
    /// sunmak, kullanıcıya boşuna kayıt girdirmek olurdu - satır durur ama
    /// hiçbir pakete dokunmaz. Üretici yeni tür okumaya başladığında buraya
    /// bir satır eklenir.
    /// </summary>
    private static readonly Dictionary<string, string> EnabizEslemeTurleri = new()
    {
        ["KLINIK"] = "Klinik / Bölüm (bölüm ile eşleşir)",
        ["BASVURU_TURU"] = "Başvuru Türü (yerel kod ile eşleşir)",
    };

    private static readonly Dictionary<string, string> EnabizAktifKodlari = new()
    {
        ["1"] = "Aktif",
        ["0"] = "Pasif",
    };
}

unit PrjConst;

interface

resourcestring
  //Uyarý
    sDetay_Silin = 'Önce detay bilgileri silin';
  //Onay
    SGenotipOnay = 'Gentegre Onay';
    SSilmeSorusu = 'Kaydý silmek istediðinize emin misiniz?';
    KaydetmeSorusu = 'Öncesinde yapmýþ olduðunuz deðiþikliði kaydetmek ister misiniz?';
  //Ödeme - tahsilat
    SOdeme = 'Ödeme';
    STahsilat = 'Tahsilat';
  //Fatura
    SGelenFaturaBilgileri = 'Gelen Fatura Bilgileri';
    SFaturaTarihi ='Fatura Tarihi';
    SFaturaNo='Fatura No';
    SSatisIrs='Satýþ Ýrsaliyesi';
    SSatisFat='Satýþ Faturasý';
    SSatisFis='Satýþ Fiþi';
    //UFaturalar ,UFaturaTransferListe
      idd='Ýþaretlilerin Durumunu Deðiþtir' ;
  //Fiþ
    SGelenFisBilgileri = 'Gelen Fiþ Bilgileri';
    SFisTarihi ='FiþTarihi';
    SFisNo='Fiþ No';
    SAlisIrs='Alýþ Ýrsaliyesi';
    SAlisFat='Alýþ Faturasý';
    SAlisFis='Alýþ Fiþi';
  //UMasrafGelir
    Ay_Yanlis = 'Ay bilgisi 1 ile 12 arasýnda olmalý!';
  //Banka_TEB ,Banka_Garanti
    secimyapilmadihata = 'Alýcý listesinden en az bir seçim yapýnýz.' ;
  //UHavalaeEFT
    Logayazamadihata = 'Dosya imza log veritabanýna kaydedilemedi.';
    yanlistelnohata = 'Geçerli bir telefon numarasý giriniz.';
    yanlisoperatorhata = 'Elektronik imza türkcell ve avea için kullanýlmaktadýr, operatör seçiminizi yapýnýz.';
    eimzahata = 'Elektronik imza baþarýsýz.';
    secimyokhata = 'En az bir Havale/EFT seçmelisiniz.';
    bankadanodemeyokhata = 'Seçtiðiniz tarihte banka üzerinden ödemeniz bulunmamaktadýr. Baþka bir tarih seçin yada ödeme türünüzü düzeltin.';
    Dosyaturuhata = 'Yanlýþ türde bir dosya oluþturuldu.';
    Eminmisin = 'Havale/Eft Sihirbazýndan çýkmak istediðinize emin misiniz?';

  //UHesapPlaný
    YanlisTabHata = 'Kartlar üzerinde düzenleme yapamazsýnýz, sadece hesap planýný deðiþtirebilirsiniz. Lütfen Sað Tuþ menüsünden "Görünüm \ Sadece Plan" ý seçiniz.';
  //UTakvimBankaParaTransfer
    TutarGiren = 'Tutar(Giren):  ';
    ParaGiren = 'Para Transferi(Giren)';
    TutarCikan =  'Tutar(Çýkan):  ';
    ParaCikan =  'Para Transferi(Çýkan)';
    istarih = 'Ýþlem Tarihi:  ' ;
    gerceklesen = 'Gerçekleþen ';
    pltarih =  'Plan Tarihi:  ';
    planlanan =  'Planlanan ';
    kasa111 = 'Kasa:  ';
    kasakodu = 'Kasa Kodu:  ';
    nakit = 'Nakit    ';
    banka111 = 'Banka:  ';
    sube1 = 'Þube:  ';
    hesap1 = 'Hesap:  ';
    bankakk1 = 'Banka:  ';
    subekk1 = 'Kart No:  ';
    hesapkk1 = 'Tanýmlý Kiþi:  ';
    bankakk2 = 'Banka:  ';
    subekk2 = 'POS No:  ';
    hesapkk2 = 'POS Adý:  ';
    PosCihazi = 'POS   ';
    KKarti = 'Kredi Kartý  ';
  //UTablo ,Senetler
    CekKasaHareketiHatasi=  'Tahsilatý bulunan çek kaydý silinemez!';
    CekHareketHareketiHatasi =  'Hareket görmüþ çek kaydý silinemez!';
    CekPortfoyHariciHatasi =  'Sadece Portföydeki çekler silinebilir!';

    IntBaglanti = 'Ýnternet baðlantýnýz yok';

    SGirisYapildi = 'Giriþ yapýldý';
    SOdemePlanlandi = 'Ödeme planlandý';
    SOdendi = 'Ödendi';
    SCikisYapildi = 'Çýkýþ yapýldý';
    STahsilatPlanlandi = 'Tahsilat planlandý';
    STahsilEdildi = 'Tahsil edildi';
    SBekliyor = 'Bekliyor';
    SOnaylandi = 'Onaylandý';
    SImzalandi = 'Ýmzalandý';
    SPortfoyde = 'Portföyde';
    STahsilataVerildi = 'Tahsilata verildi';
  //UKullaniciYetki  ,UKullaniciDüzenle
    gorsun = 'Görsün';
    eklesin = 'Eklesin';
    degistirsin = 'Deðiþtirsin';
    yonetici = 'Yönetici';
    kullanici = 'Kullanýcý';
    roldegishata = 'Baþlangýç Rolleri ile ilgili deðiþiklik yapýlamaz!';
    yetkileri = ' Yetkileri';
    kullanicilari =' Kullanýcýlarý';
    rolsilinemez = 'Seçili rolün tanýmlý olduðu kullanýcýlar mevcut, öncelikle bu kullanýcýlarýn rollerini deðiþtirip daha sonra silme iþlemini tekrar deneyiniz.';
    rolyonsilinemez = 'Yönetici rolü silinemez!';
    mukerrerkod = 'Seçtiðiniz kullanýcý kodu daha önce kullanýlmýþtýr, lütfen düzeltip tekrar deneyiniz..';
    kullanicisilinemez = 'Silmek istediðiniz kullanýcýnýn yapmýþ olduðu iþlemler vardýr. Önce bu iþlemleri siliniz.';
    rolyok = 'Seçili Rol Bulunamadý!';
    kullaniciyok = 'Seçili Kullanýcý Bulunamadý!!';
  //Banka_ING
    talhata =  'Talimat Hatasý: ';
    borhata =  'Bordro Hatasý: ';
  //UTakvimVirman
    ////Errors
      BozukKayit= 'Açmaya çalýþtýðýnýz kaydýn içeriði bozulmuþtur lütfen silip tekrar oluþturunuz.';
    ////captions
      islem41= 'Kasadan bankaya para transferi'; //41
      islem42= 'Bankadan kasaya  para transferi'; //42
      islem43= 'Bankadaki hesaplar arasý para transferi'; //43
      islem45= 'Kasadaki nakit paranýn bir kýsmýyla döviz alma'; //45
      islem46= 'Döviz kasasýndaki paranýn bir kýsmýný bozdurma'; //46
      islem47= 'Bankadaki nakit paranýn bir kýsmýyla döviz alma'; //47
      islem48= 'Döviz hesabýndaki paranýn bir kýsmýný bozdurma'; //48
      islem51= 'Elimzde bulunan çeki bankadan tahsil etme';  //51
      islem52= 'Elimzde bulunan senedi bankadan tahsil etme'; //52
      islem53= 'Verdiðimiz çek karþýlýðý bankadan ödeme';  //53
      islem54= 'Verdiðimiz senet karþýlýðý bankadan ödeme'; //54
      islem69= 'Alýnmýþ olan kredi taksitlerinin ödemesi'; //69
      islem95= 'Bankoda tahsil edilmiþ olan kredi kartlarýnýn giriþi';  //95
      islem91= 'Bankoda tahsil edilmiþ olan nakit ödemelerin giriþi';  //91
    ////Panels
      Tutar123='Tutar:  ';
      banka11='Banka:  ';
      sube11='Sube:  ';
      hesap11='Hesap:  ';
      kasaadi11='Kasa Adý:  ';
      kasakodu11='Kasa Kodu:  ';
      kasakur11='  ';
      posadi='Pos Adý:  ';
      poskodu='Pos Kodu:  ';
      posbankasi='Bankasý:  ';
  //UTakvimKKEkstresi
    dekstiresi=' Dönemi Ekstre Bilgileri.';
  //UGorevWizard
    SablonYap='Aþaðýdaki görevi þablon olarak kaydet.';
    SablonKaldir='Aþaðýdaki görevin þablon özelliðini kaldýr.';
  //URehberWizar
    isimeksikhata= 'Lütfen ilgili kiþinin ismini doldurarak tekrar deneyin.';
    zorunlualanhata='Lütfen farklý renk ile belirlenmiþ zorunlu alanlarýn tümünü doldurarak tekrar deneyin.';
    yenisorgugirin='Yeni sorgunuzu giriniz.';
  //USifre
    SLangChanged = 'Program dili deðiþti ("%s").'#13#10' Geçerli olabilmesi için yeniden baþlatmalýsýnýz';
  //UTalimatWizard
    BankaDeseniYok='Bu banka için desen bulunmamaktadýr..';
  //UAnaForm
    Aksiyonlar1 = 'CRM';
    Cari1 = 'Cari';
    CekSenet1 = 'ÇekSenet';
    Banka1 = 'Banka';
    Fatura1 = 'Fatura';
    Kasa1 = 'Kasa';
    Stok1 = 'Stok';
    Demirbas1 = 'Demirbaþ';
    Teklif1 = 'Teklif';
    Siparis1 = 'Sipariþ';
    Servis1 = 'Servis';
    Dokuman1 = 'Doküman';
  //TEB_Encrypter_TLB
    dtlServerPage = '(none)';
    dtlOcxPage = '(none)';
  //UDokumSart
    STextNotFound = 'Metin bulunmadý';
    SNoSelectionAvailable = 'Arama iþlemi tüm metin içerisinde yapýlsýn mý?';
  //UDemirbasWizard
    DWYeniDemirbas = 'Yeni Demirbaþ girmelisiniz.';
    DWislemYapilmaz = 'Bu demirbaþý ile iþlem yapamazsýnýz.';
    DWTransferYapilmaz = 'Bu demirbaþý transfer yapamazsýnýz.';
    DWKayitliDegil =  'Bu demirbaþ kayýtlý deðildir.';
    DWServisYapilmaz = 'Bu demirbaþ ile servis iþlemi yapamazsýnýz.';
    DWZimmetYapilmaz = 'Bu demirbaþý zimmet yapamazsýnýz.';
    DWiadeYapilmaz = 'Bu demirbaþý Ýade yapamazsýnýz.';
    DWGarTarihiGir = 'Garanti Bitiþ Tarihini büyük giriniz.';
    DWBakimPeriyoduBirimi = 'Bakým Periyodu birimini giriniz.';
  //UCekWizard
    kullanilmisserino = 'Bu çek üzerindeki Seri No daha önce kullanýlmýþtýr.' ; //UKasaWizard
    CWCekGirBilg = 'Çek Giriþ Bilgileri';
    CWCekCikBilg = 'Çek Çýkýþ Bilgileri';
    CWKontBanka = 'Banka';
    CWKontCariKod = 'Cari Kod';
    CWKontSeriNo = 'Seri No';
    CWKontKod = 'Kod';
    CWKontKesideYei = 'Keþide Yeri';
    CWKontKesideTarihi = 'Keþide Tarihi';
    CWKontTutar = 'Tutar';
    CWCekKocaniCek = 'Çek Koçaný Listesi';
    CWCekKocanBulunamadi = 'Tanýmlý çek koçaný bulunamadý!';
    CWTarihAtansinmi = 'Seçtiðiniz "Keþide Tarihi" tatil gününe denk geliyor, sonraki uygun tarih atansýn mý?';
    CWKayitIleriTarihliOlamaz = 'Kayýt tarihi ileri bir gün olamaz.';
  //UCekKocanWizard
    serinohata='Bu aralýktaki Seri Nolar diðer koçanlarda kullanýlmýþtýr.'; //UBankaCekiWizard
    CKWBankaHesapSec = 'Çek için tanýmlý bir banka hesabý seçerek devam edin.';
  //UCekHareketWizard
    icraaltbaslik = 'Bu bölümde iþlemi gerçekleþtireceðiniz avukat yada hukuk bürosunu seçiniz.';
    CHWCiroEdildi = 'Ciro Edildi';
    CHWTahsilEdildi = 'Tahsil Edildi';
    CHWTahsileverildi = 'Tahsile Verildi';
    CHWTahsilEdilemiyor = 'Tahsil Edilemiyor';
    CHWTakasaVerildi = 'Takasa Verildi';
    CHWicrayaVerildi = 'Ýcraya Verildi';
    CHWiptalEdildi ='Ýptal Edildi';
  //UKasaWizard
    KWOdemeKanali = 'Ödeme kanalý';
    KWTahsilatKanali = 'Tahsilat kanalý';
    KWYapilanHarcamaSec = 'Yapýlan harcama hangi masraf kalemine aitse listeden onu seçin';
    KWGirenGelirSec = 'Kasaya giren gelir hangi gelir kalemine aitse listeden onu seçin';
    KWAkt_KayitBulunamadi = 'Seçilen veritabanýnda aktarýlmamýþ kayýt bulunamadý.';
    KWTahsilatGirisi = ' Tahsilat Giriþi';
    KWMusteriAlacaklandir = 'Müþteri''yi alacaklandýr';
    KWMusteriBorclandir = 'Müþteri''yi borçlandýr';
    KWNakitGirisiVarsa = 'Müþteri''den TL, $, € gibi nakit giriþi varsa';
    KWNakitCikisiVarsa = 'Müþteri''ye TL, $, € gibi nakit çýkýþý varsa';
    KWHesaplarimizaGonderimYapilmissa = 'Müþteri''den banka hesaplarýmýza gönderim yapýlmýþsa';
    KWHesaplarinaOdemeYapilmissa = 'Müþteri''nin banka hesabýna ödeme  gönderilmiþse';
    KWCekveyaSenetAlinmissa = 'Müþteri''den Çek veya Senet alýnmýþsa';
    KWCekveyaSenetVerilmisse = 'Müþteri''ye Çek veya Senetle ödeme yapýlmýþsa';
    KWKrediKartiileTahsilat = 'Kredi Kartý ile tahsilat';
    KWKrediKartiileOdeme = 'Kredi Kartý ile ödeme';
    KWTahsilatPlani = 'Tahsilat Planý';
    KWDuzenliTahsilat = 'Düzenli Tahsilat';
    KWAvansTahsilati = 'Avans Tahsilatý';
    KWOdemePlani = 'Ödeme Planý';
    KWDuzenliOdeme = 'Düzenli Ödeme';
    KWPersonelMaasi = 'Personel Maaþ';
    KWAksiyonSecin = 'Bir aksiyon seçin';
    KWKasadanKasayaTransfer = 'Kasadan kasaya para transferi varsa';
    KWKasadanBankayaTransfer = 'Kasadan bankaya para transferi varsa';
    KWBankadanKasayaTransfer = 'Bankadan kasaya  para transferi varsa';
    KWBankadakiHesaplarArasiTransfer = 'Bankadaki hesaplar arasý para transferi varsa';
    KWKasadakiParaylaDovizAlirsa = 'Kasadaki nakit paranýn bir kýsmýyla döviz alýnýrsa';
    KWDovizKasasindakiBozdurulacaksa = 'Döviz kasasýndaki paranýn bir kýsmý bozdurulacaksa ';
    KWBankadakiParaylaDovizAlirsa = 'Bankadaki nakit paranýn bir kýsmýyla döviz alýnýrsa';
    KWDovizHesabindakiBozdurulacaksa = 'Döviz hesabýndaki paranýn bir kýsmý bozdurulacaksa';
    KWEldekiCekBankadanTahsilati = 'Elimizde bulunan çek bankadan tahsil edilirse';
    KWEldekiSenetBankadanTahsilati = 'Elimizde bulunan senet bankadan tahsil edilirse';
    KWCekBankadanOdenirse = 'Verdiðimiz çek karþýlýðý bankadan ödenirse';
    KWSenetBankadanOdenirse = 'Verdiðimiz senet karþýlýðý bankadan ödenirse';
    KWKrediGirisi = 'Kredi Giriþi';
    KWKrediOdemesiYapilir = 'Kredi kartý taksitlerinin ödemesi yapýlýr';
    KWAlinmisKrediOdemesiYapilir = 'Alýnmýþ olan kredi taksitlerinin ödemesi yapýlýr';
    KWNakitOdemelerinGirisiYapilir = 'Bankada tahsil edilmiþ olan nakit ödemelerin giriþi yapýlýr';
    KWKrediGirisiYapilir = 'Bankoda tahsil edilmiþ olan kredi kartlarýnýn giriþi yapýlýr';
    KWOnceOdemeKanaliSec = 'Önce ödeme kanalýný seçin!';
    KWOnceHesabiTanimla = 'Önce hesabý tanýmlayýn!';
    KWKasaVeyaBankaHesabiTanimla = 'Tanýmlý hesap bulunamadý. Kasa veya Banka hesabý tanýmlayýn!';
    KWAnaPara = 'Anapara';
    KWFaiz = 'Faiz';
    KWAnaparaveFaiz = 'Anapara+Faiz';
    KWLutfenSecin = 'Lütfen Seçin ';
    KWOdemeTuru = 'Ödeme Türü:';
    KWValorVarmi = 'Valör var mý?';
    KWOdemeEkrani = 'Ödeme Ekraný';
    KWOdemeBilgileriGir = 'Ödeme bilgilerini girin';
    KWTahsilatEkrani = 'Tahsilat Ekraný';
    KWTahsilatBilgileriGir = 'Tahsilat bilgilerini girin';
    KWAnaparaveFaizTutariGir = 'Anapara veya Faiz tutarýný girin!';
    KWBakiyedenFazlaOdenemez = 'Kredi ödemesinde Anapara veya Faiz bakiyeden fazla ödenemez!';
    KWTutariGiriniz = 'Tutarý girin!';
    KWDovizdenSonraCikisTLOlmali = 'Döviz satýþýnda çýkýþ kasasý TL olmalý';
    KWDovizdenSonraCikisTLOlamaz = 'Döviz satýþýnda çýkýþ kasasý TL olamaz';
    KWTutarKismiBosOlamaz = 'Tutar kýsmý boþ olamaz!';
    KWHedefHesapSecYoksaTanimla = 'Önce hedef hesabý seçin, yoksa tanýmlayýn!';
    KWMiktariGirin = 'Miktarý girin!';
    KWDovizKurunuGiriniz = 'Döviz Kurunu Giriniz: ?';
    KWAnaparaBorctanBuyukOlamaz = 'Ödenecek anapara kalan anapara borçtan büyük olamaz!';
    KWFaizBorctanBuyukOlamaz = 'Ödenecek faiz kalan faiz borçtan büyük olamaz!';
    KWKrediKapandiOlarakIsaretlensinmi = 'Bu kredi kapandý olarak iþaretlensin mi?';
    KWKrediKartiSec = 'Kredi Kartý Seçme';
    KWCekSenetArama = 'Çek / Senet Arama';
    KWTumu = 'Tümü';
    KWPortfoyde = 'Portföyde';
    KWTahsilEdildi = 'Tahsil Edildi';
    KWCiroEdildi ='Ciro Edildi';
    KWTahsileVerildi = 'Tahsile Verildi';
    KWTeminataVerildi ='Teminata Verildi';
    KWProtestoEdildi = 'Protesto Edildi';
    KWKarsiligiYok = 'Karþýlýðý Yok';
    KWTahsilEdilemiyor = 'Tahsil Edilemiyor';
    KWKrediSec = 'Kredi Seçme';
    KWOdenmemisler = 'Ödenmemiþler';
    KWOdenmisler = 'Ödenmiþler';
    KWListedenSec = 'Listeden seçim yapýn!';
    KWTahsilEdilmis = 'Daha önce tahsil edilmiþ!';
  //UKasaTanýmWizard
    KTWKasaKodu = 'Kasa Kodu';
    KTWKasaAdý =  'Kasa Adý';
    KTWParaBirimi ='Para Birimi';
  //UServisWizard
    SERWServis_Servis = 'Servis';
    SERWServis_Ekipman = 'Servis Ekipman';
    SERWServis_Problem = 'Servis Problem';
    SERWServis_FizikselDurum = 'Servis Fiziksel Durum';
    SERWServis_Aksesuar = 'Servis Aksesuar';
    SERWServis_Nedeni = 'Servis Nedeni';
    SERWServis_Planlanan = 'Servis Planlanan';
    SERWServis_Yapilan = 'Servis Yapýlan';
    SERWServis_Uygulama = 'Servis Uygulama';
    SERWServis_Iade = 'Servis Ýade';
    SERWServis_Testler = 'Servis Testler';
    SERWServis_Notlar = 'Servis Notlar';
    SERWServisEkipman = 'Servis Ekipmanlarý';
  //UGorevWizard
    GWGecmiseAtanamaz = '"Bitiþ Tarihi" geçmiþe atanamaz!';
    GWGecmisTarihliSecilmez = 'Görev Baþlangýç tarihi geçmiþ tarihli seçilemez';
    GWBitTarihKucukSecilemez = 'Görev Bitiþ tarihi Baþlama tarihinden küçük olamaz';
    GWGunSecimiYapilmali = 'Öncelikle gün seçimi yapmalýsýnýz';
    GWKacHaftadaBirYapilacak = 'Planlamanýn kaç haftada bir yapýlacaðýný seçiniz';
    GWYeniTarihDegeri = 'Yeni Tarih Deðeri';
    GWErtelemeTarihiGirin = 'Erteleme Tarihi girin';
    GWErtelemeTarihiBosOlmaz = 'Erteleme Tarihi Boþ Olamaz.';
    GWDegisiklikIcýnAciklamaGir = 'Durum deðiþikliðiniz için bir açýklama giriniz.';
    GWAciklamaGir = 'Açýklamayý girin';
    GWAciklamaBosOlamaz = 'Açýklama Boþ Olamaz.';
    GWDurumYeniGorevOlamaz = 'Görevin Durumu Yeni Görev olarak deðiþtirilemez!';
    GWDegisiklikKaydedilmedi = 'Hata: Deðiþiklik kaydedilemedi!';
    GWSablonYok = 'Böyle bir þablon artýk yok!';
    GWAynýisimdeSablonVar = 'Ayný isimde çok sayýda þablon var!';
    GWAktarilamayanAlanlar = 'Aktarýlamayan Alanlar:';
    GWYeniGorevOlustur = 'Yeni Görev Oluþturma Sihirbazý';
    GWGorevDuzenleme = 'Görev Düzenleme Sihirbazý';
    GWYeniGorevSablonuOlustur = 'Yeni Görev Þablonu Oluþturma Sihirbazý';
    GWGorevSablonuDuzenleme = 'Görev Þablonu Düzenleme Sihirbazý';
    GWBoyleBirGorevYok = 'Böyle bir görev yok!!!';
    GWIslemOpBelirtilmeli = 'Ýþlem Op Belirtilmeli!!';
    GWKayitlardaHatalarOlustu = 'Bazý kayýtlarda hatalar oluþtu: ';
  //UProjeWizard
    PWSilerekTekrarDeneyin = 'Detay Kayýtlarý varken bu iþlemi gerçekleþtiremessiniz, detay bilgilerini silerek tekrar deneyiniz.';
    PWHepsiSilinecektirUyari = 'Yeni þablon oluþturulurken bu bölümdeki girilmiþ tüm detay bilgileri silinecektir.';
    PWSonucBilgisiGir = 'Projeyi kapatýrken Sonuç Bilgisi girilmelidir.';
    PWBitRarihKucukSecilemez = 'Proje Bitiþ tarihi Baþlama tarihinden küçük olamaz';
    PWListefiyatiKurBilgisiGir = 'Liste Fiyatý için kur bilgisi giriniz';
    PWSatisFiyatiKurBilgisiGir = 'Satýþ Fiyatý için kur bilgisi giriniz';
    PWSeciliKaydiListedenSil = 'Seçili Kaydý listeden silmek istiyor musunuz?';
  //UFaturaWizard
    FWYuzdesiniGirin = 'Yüzdesini girin';
    FWToplamTutariGir = 'Toplam tutarý girin.';
    FWMalFazlasiGir = 'Mal fazlasý olarak verilecek miktarý girin.';
    FWGiris = 'Giriþ';
    FWCikis = 'Çýkýþ';
    FWGelen = 'Gelen ';
    FWGiden = 'Giden ';
    FWGiderPusula = 'Gider Pusulasý';
    FWIrsaliye = 'Ýrsaliye';
    FWFatura = 'Fatura';
    FWFis = 'Fiþ';
    FWBasligi = ' Baþlýðý';
    FWBilgileri = ' bilgileri';
    FWOlustur = ' Oluþtur';
    FWSeciniz = 'Seçiniz';
    FWKurumunaGiden = ' Kurumuna Giden ';
    FWKurumundanGelen = ' Kurumundan Gelen ';
    FWKayitSilinemez = 'Bu ürüne ait seri numaralarý hareket görmüþ.Kayýt silinemez.';
    FWKayitBelgeYilindanFarkliOlamaz = 'Kayýt yýlý belge yýlýndan farklý olamaz.';
    FWKayitveBelgeTarihiIleriTarihOlamaz = 'Kayýt tarihi ve belge tarihi ileri bir gün olamaz.';
    FWSadeceRakamGir = 'Fatura numarasýnda rakam dýþýnda karakter olamaz!';
    FWFaturaNoKullanilmistir = ' tarihinde bu fatura numarasý kullanýlmýþ!';
    FWFislerdeEkranKullanilmaz = 'Belge türü Fiþ olan kayýtlar için bu ekran kullanýlamaz';
    FWFirmayaAitSiparisYoktur = 'Bu firmaya ait sipariþ bulunmamaktadýr.';
    FWFirmayaAitIrsaliyeYoktur = 'Bu firmaya ait irsaliye bulunmamaktadýr.';
    FWFirmayaAitSiparisIrsaliyeYoktur = 'Bu firmaya ait Sipariþ ve Ýrsaliye bulunmamaktadýr.';
    FWFaturaninTahsilati = ' Nolu Faturanýn Tahsilatý.';
    FWFaturaninOdemesi = ' Nolu Faturanýn Ödemesi.';
  //UFatTransferWizard
    FTWTransferleriSil = 'Önce Transfer satýrlarýný silmeniz gerekiyor';
    FTWGirisDeposuBosOlamaz = 'Giriþ Deposu boþ olamaz';
    FTWCikisDeposuBosOlamaz = 'Çýkýþ Deposu boþ olamaz';
    FTWDepolarAyniOlamaz = 'Giriþ Çýkýþ Depolarý ayný olamaz';
  //UMakbuzWizard
    MWTahsilat = 'Tahsilat ' ;
    MWOdeme = 'Ödeme ';
    MWSeciliMakbuzSilinecek = 'Seçili Makbuz satýrý silinecektir. Onaylýyor musunuz?';
    MWSatirGirilmisSilinemez = 'Girilmiþ detay satýrý var, deðiþtirilemez!';
  //UTeklifWizard
    TWAlternatif = 'Alternatif ';
    TWYeniTeklifeAit = 'Teklif kopyalandý. Ekrandaki görüntü yeni teklife aittir..';
  //UTalimatWizard
    TalWBankaTalimati = 'Banka Talimatý';
    TalWTalimat = 'Talimat: ';
    TalWTarihAralikOdeme = ' tarih aralýðýndaki ödeme.';
    TalWile = ' ile ';
    TalWAlacaktanBuyukOlamaz = ' için yapýlacak ödemede Borç, Alacaktan büyük olamaz..';
    TalWTalimatSlash = 'Talimat\';
    TalWDosyayaYazilamadi = 'Dosya veritabanýna yazýlamadý!';
    TalWKaydetmedenCikacakmisin = 'Yaptýðýnýz deðiþiklikleri kaydetmeden çýkmak istediðinize emin misiniz?';
    TalWIslemIptalEdiliyor = 'Kayýt iþlemi iptal ediliyor.';
    TalW14HaneliGiriniz = 'Baþýnda 0 ile 14 haneli giriniz.';
    TalWTurkceKarakterHaric = 'Türkçe karakter içermeden giriniz';
    TalWYeni = 'Yeni ';
    TalWDegeri = ' Deðeri';
    TalWSeciliIsleminizYok = 'Seçili iþleminiz yok!';
  //UAktiviteWizard
    AWNo ='No        :';
    AWTuru = 'Türü      :';
    AWTipi = 'Tipi      :';
    AWSorumlu = 'Sorumlu   :';
    AWAtayan = 'Atayan    :';
    AWTakipci = 'Takipçi   :';
    AWBilgi = 'Bilgi     :';
    AWKonusu = 'Konusu    :';
    AWKonum = 'Konum     :' ;
    AWMusteri = 'Müþteri   :';
    AWDurum = 'Durum     :';
    AWPuan = 'Puan      :';
    AWOncelik = 'Öncelik   :';
    AWBaslangic = 'Baþlangýç :';
    AWBitis = 'Bitiþ     :';
    AWNotlar = 'Notlar    :';
    AWMusteriSecimiYap = 'Önce Müþteri Seçimi Yapmanýz gerekmektedir.';
    AWBuPersonelSecilemez = 'Seçilen personel bu tarihte izinli, bu personel seçilemez';
    AWVekaletEdenSecilecek = 'Seçilen personel bu tarihte izinli, vekalet eden personel seçilecek.';
    AWVekaletEdenSecilmemis = 'Seçilen personel bu tarihte izinli, vekalet edecek personel seçilmemiþ. Ýzinler ekranýndan gerekli ayarlamayý yapýp tekrar deneyiniz.';
    AWPersonelBuTarihteIzinli = 'Seçilen personel bu tarihte izinli';
    AWGecmisTarihliSecilemez = 'Görev Baþlangýç tarihi geçmiþ tarihli seçilemez';
    AWGorevBitisTarihiBuyukOlacak = 'Görev Bitiþ tarihi Baþlama tarihinden küçük olamaz';
    AWGunSecimiYapmalisiniz = 'Öncelikle gün seçimi yapmalýsýnýz';
    AWTurBosOlamaz = 'Tür bilgisi boþ olamaz';
    AWDetayBilgileriniSilTekrarDene = 'Detay Kayýtlarý varken bu iþlemi gerçekleþtiremessiniz, detay bilgilerini silerek tekrar deneyiniz.';
    AWAktarilamayanAlanalar = 'Aktarýlamayan Alanlar:';
    AWBoyleBirSablonArtikYok = 'Böyle bir þablon artýk yok!';
    AWAyniIsimdeSablonVar = 'Ayný isimde çok sayýda þablon var!';
    AWKaydediliyorOnayliyormusun = 'Öncelikle yaptýðýnýz deðiþikliklerin kaydedilmesi gerekmektedir. Onaylýyor musunuz?';
    AWBitisTarihiKucukOlamaz = 'Bitiþ tarihi baþlama tarihinden küçük olamaz!';
    AWOnceMusteriSecin = 'Önce müþteri seçin!';
    AWAktiviteTuru = 'Aktivite Türü';
    AWSorumluBilgisi = 'Sorumlu Bilgisi';
    AWAktiviteKonusu = 'Aktivite Konusu';
    AWYeniFirmaAdi = 'Yeni Firma Adý.';
    AWSablonAdiniGiriniz = 'Þablon Adýný Giriniz';
    AWSablonTanýmlandi = 'Þablon Tanýmlandý';
    AWSorumluOldugunAktiviteVar = 'Sorumlu olarak atandiginiz yeni bir aktivite var.Aktivite No:';
    AWTakipciOldugunAktiviteVar = 'Takipci olarak atandiginiz yeni bir aktivite var.Aktivite No:';
    AWBilgilendirilecekOldugunAktiviteVar = 'Bilgilendirilecek kisi olarak secildiginiz yeni bir aktivite var.Aktivite No:';
    AWNotGirisiSilinebilir = 'Not giriþi sadece ekleyen kullanýcý tarafýndan silinebilir';
    AWNotSahibiDuzenlemeYapabilir = 'Bu not üzerinde sadece not sahibi düzenleme yapabilir';
    AWSorumluHaricindeEklemeYapýlmazAltEkle = 'Sorumlu haricinde ekleme yapýlmaz.Ancak alta ekleme yapabilirsiniz.';
    AWSorumluHaricindeEklemeYapýlmaz = 'Sorumlu haricinde ekleme yapýlmaz.';
    AWGoreviAtayanHaricindeOnaylandiYapýlmaz = 'Görevi Atayan haricinde Onaylandý yapýlmaz.';
    AWSorumluHaricindeSilmeYapilmaz = 'Sorumlu haricinde silme yapýlmaz.';
    AWGoreviAtayanVeSorumluAyniOlamaz = 'Görevi Atayan ve Sorumlu ayný olamaz.';
  //UBankaCekiWizard
    BCWKocanEklemeYetkinYok = 'Koçan Ekleme Yetkiniz Yok!';
    BCWKocanSilmeYetkinYok ='Koçan Silme Yetkiniz Yok!';
    BCWCekKocanlariSilinemez = 'Girilmiþ çek koçanlarý var. Silinemez!';
    BCWDegisiklikYapamazsiniz = 'Çek koçanlarý üzerinde deðiþiklik yapmaya yetkili deðilsiniz!';
    BCWCekKocanýndaIslemYapilmaz = 'Bu Çek koçanýnýn bazý yapraklarý kullanýlmýþ durumda olduðundan iþlem yapýlamaz!';
  //UBankaTanimWizard
    BTWIBANGecersiz = 'IBAN Numarasý Geçersiz!';
    BTWYeniBankaGir = 'Yeni Banka Adýný Giriniz.';
    BTWBankaAdi = 'Banka Adý:';
    BTWBankaAdiBosOlamaz = 'Banka Adý Boþ Olamaz.';
    BTWYeniSubeGir = 'Yeni Þube Adýný Giriniz.';
    BTWSubeAdi = 'Þube Adý:';
    BTWSubeAdiBosOlamaz = 'Þube Adý Boþ Olamaz.';
    BTWYeniSubeKoduGir = 'Yeni Þube Kodunu Giriniz.';
    BTWSubeKoduBosOlamaz = 'Þube Kodu Boþ Olamaz.';
  //UOpsDlg
    ODlgHerYilTatikicin = ' Her yýl,  tatil için';
    ODlgTatilinAdiniGiriniz = 'Tatilin adýný giriniz :';
    ODlgGunuGiriniz = 'Günü giriniz :';
    ODlgAyiGiriniz = 'Ayý Giriniz';
    ODlgOnayliyormusunu = ' silinecektir. Onaylýyor musunuz?';
    ODlgAktifFisKocanNo = 'Aktif Fiþ Koçan No:';
    ODlgAktifFaturaKocanNo = 'Aktif Fatura Koçan No:';
    ODlgAktifIrsaliyeKocanNo = 'Aktif Ýrsaliye Koçan No:';
    ODlgAktifAlisSiparisKocanNo = 'Aktif Alýþ Sipariþi Koçan No:';
    ODlgAktifSatisSiparisKocanNo = 'Aktif SatýþSipariþi Koçan No:';
    ODlgAktifGiderPusulasiKocanNo = 'Aktif Gider Pusulasý Koçan No:';
    ODlgBayraminilkGununun = ' bayramýnýn ilk gününün';
    ODlgGununuGiriniz = 'Gününü giriniz :';
    ODlgAyiniGiriniz = 'Ayýný Giriniz';
    ODlgStilTanimiYapiniz = 'Önce stil tanýmý yapmanýz gerekmektedir.';
    ODlgStilKosulSilinecektir = 'Seçili Stil koþul tanýmý silinecektir. Onaylýyor musunuz?';
    ODlgStilSilinecektir = 'Seçili Stil tanýmý silinecektir. Onaylýyor musunuz?';
    ODlgSMSServisBosOlamaz = 'SMS Servisi Boþ Olamaz';
    ODlgBilgilerBosBirakilamaz = 'Kullanýcý Adý-Þifre-Baþlýk bilgileri boþ olamaz';
    ODlgStilAdiBosBirakilamaz = 'Stil Adý Boþ Býrakýlamaz';
  //UNakitDlg
    NDTutarDoluOlmali = 'Tutar dolu olmalý!';
    NDAlis = 'Alýþ: ';
    NDSatis = 'Satýþ: ';
    NDEfAlis = 'Ef.Alýþ: ';
    NDEfSatis = 'Ef.Satýþ: ';
    NDPos = 'POS: ';
    NDKurBilgisiBosOlamaz = 'Kur Bilgisi Boþ Olamaz';
    NDBakiyeYetersiz = 'Bakiye yetersiz!';
    NDBakiyeYetersizDevammi ='Bakiye yetersiz! Yine de devam etsin mi?';
    NDKalanBakiye = 'Kalan Bakiye:';
  //URehAraDlg
    RDAksiyonSilinsinmi = 'Bu aksiyon silinsin mi?';
    RDAnaFirmaSilinemez = 'Ana Firma Silinemez!';
    RDYoneticiKullaniciSilinemez = 'Yönetici Kullanýcý Silinemez!';
    RDKrediTanimiSilinemez = 'Kredi Tanýmý Silinemez!';
    RDBankaTanimiSilinemez = 'Banka Tanýmý Silinemez!';
    RDPlanVerisiVarSilinemez = ' tarihinde girilmiþ ödeme,tahsilat veya plan verisi var, silinemez!';
    RDFaturaVerisiVarSilinemez = 'Girilmiþ fatura verisi var, silinemez!';
    RDCekVerisiVarSilinemez = 'Girilmiþ çek verisi var, silinemez!';
    RDSenetVerisiVarSilinemez = 'Girilmiþ senet verisi var, silinemez!';
    RDPersonelBigisiVarSilinemez = 'Girilmiþ personel bilgisi var, silinemez!';
    RDiletisimBigisiVarSilinemez = 'Girilmiþ iletiþim bilgisi var, silinemez!';
    RDBankaVerisiVarSilinemez = 'Girilmiþ banka bilgisi var, silinemez!';
    RDProjeVerisiVarSilinemez = 'Girilmiþ proje bilgisi var, silinemez!';
    RDAktiviteVerisiVarSilinemez = 'Girilmiþ aktivite verisi var, silinemez!';
    RDTeklifVerisiVarSilinemez = 'Girilmiþ teklif verisi var, silinemez!';
    RDDokumanVerisiVarSilinemez = 'Girilmiþ döküman verisi var, silinemez!';
    RDYeniilgiliADSoyadGir = 'Yeni Ýlgili Adý-Soyadýný Giriniz.';
    RDAdSoyad = 'Ad-Soyad: ';
    RDGirilmisBankaBilgisiVarSilinemez = ' tarihinde girilmiþ banka bilgisi var, silinemez!';
    RDOnceAramaYapin = 'Önce arama yapýn!';
  //UTahakkukDlg
    TDTutarDoluOlmali = 'Tutar dolu olmalý!';
  //UStokListeDlg
    SDStok = 'Stok';
    SDKSeviyeMiktariBilgisi = ' için K.Seviye Miktarý Bilgisi';
    SDKSeviyeMiktariGir = 'Kritik Seviye Miktar Giriniz';
    SDBaglantiZamanAsimi = '-Baðlantý Zaman Aþýmý!';
    SDKartTanimliDegil = '-Kart Tanýmlý Deðil!';
    SDStokSayimVerisiVarSilinemez = 'Girilmiþ stok sayýmý verisi var, silinemez!';
    SDStokVerisiVarSilinemez = 'Girilmiþ stok verisi var, silinemez!';
    SDStokDetayKopyalansinMi = 'Detay bilgilerini de kopyalamak ister misiniz?';
  //UProjeListeDlg
    PDFaturaVerisiVarSilinemez = 'Girilmiþ Fatura verisi var, Silinemez';
  //UAktiviteListeDlg
    ADOkunmayan = 'Okunmayan ';
    ADAktiviteGorevBilgisiVar = ' adet aktivite-görev bilgisi var';
    ADKaydiOlusturanSilebilir = 'Bu kayýt baþkasý tarafýndan oluþturulmuþtur, Yalnýzca oluþturan kiþi kaydý silebilir';
    ADBagliAktiviteVarSilinemez = 'Bu Aktiviteye Baðlý Aktivite verisi var, Silinemez';
    ADKaydiOlusturanDegistirebilir='Bu kayýt baþkasý tarafýndan oluþturulmuþtur, Yalnýzca oluþturan kiþi kaydý deðiþtirebilir';
    ADKaydiOlusturanOnaylayabilir='Bu kayýt baþkasý tarafýndan oluþturulmuþtur,Yalnýzca oluþturan kiþi kaydý Onaylayabilir.';
  //UDemirbasListeDlg
    DDFarkliDurumVeZimmetSahibiSecilemez = 'Farklý durum ve zimmet sahibi seçilemez';
    DDDemirbasileIslemYapamazsiniz = 'Bu demirbaþý ile iþlem yapamazsýnýz.';
    DDDemirbasiIadeYapamazsin = 'Bu demirbaþý Ýade yapamazsýnýz.';
    DDDemirbasiZimmetYapamazsin = 'Bu demirbaþý Zimmet yapamazsýnýz.';
    DDDemirbasKayipIslemYapamazsin = 'Bu demirbaþ ile kayýp iþlem yapamazsýnýz.';
    DDDemirbasiTransferYapamazsin = 'Bu demirbaþý Transfer yapamazsýnýz.';
    DDDemirbasServisGonderYapamazsin = 'Bu demirbaþ ile servise gönder iþlemi yapamazsýnýz.';
    DDDemirbasServisIadeYapamazsin = 'Bu demirbaþ ile servis iade iþlemi yapamazsýnýz.';
    DDDemirbasServisIslemiYapamazsin = 'Bu demirbaþ ile servis iþlemi yapamazsýnýz.';
    DDServisHareketGormusSilinemez = 'Bu Demirbaþ servis hareketi görmüþtür.Silinemez !';
    DDSigortaHareketGormusSilinemez = 'Bu Demirbaþ sigorta hareketi görmüþtür.Silinemez !';
    DDTutanakHareketGormusSilinemez = 'Bu Demirbaþ tutanak hareketi görmüþtür.Silinemez !';
  //UKampanyaDlg
    KDDetayGirilmisSilinsinmi = 'Bu kampanyaya girilmiþ alt bilgiler vardýr.Silinsin mi ?';
  //UKrediHesapMakineDlg
    KDOdemeTakvimiHesaplanmamis = 'Ödeme takvimi hesaplanmamýþ!';
    KDSatisTutariGirilmemis = 'Satýþ tutarý girilmemiþ!';
    KDBasitFaizOrani = 'Basit Faiz Oraný';
    KDBasitFaiz = ' Basit Faiz %';
    KDOranBosOlamaz = 'Oran Boþ Olamaz.';
    KDKDVliKira = 'KDV li Kira';
    KDTaksit = 'Taksit';
  //UReplikasyon
    RBagli = 'Baðlý';
    RBaglantiYok = 'Baðlantý Yok';
    RGenotipdanRehberAl = 'Genotýpdan Rehber Al';
    RGenotipeRehberVer = 'Genotýpa Rehber Ver';
    RGenotipdanStokFaturasiAl = 'Genotýpdan Stok Faturasý Al';
    RGentegreDevirCariBankaKasa = 'Gentegre Devir(Cari,Banka,Kasa)';
    RGentegreDevirCekSenet = 'Gentegre Devir(Çek,Senet)';
    RGentegreDevirCariYýlDetay = 'Gentegre Devir(Cari Yýl Detay)';
    RGenotipdanStokKartAl = 'Genotýpdan Stok Kart Al';
    RGenotipaStokKartVer ='Genotýpa Stok Kart Ver';
    RHataliSatirSayisi = 'Hatalý/Aktarýlamayan satýr sayýsý: ';
    RAktarimBasarili = 'Tebrikler, aktarýmýnýz baþarýlý.';
    RAktarimHatasi = 'Aktarým Hatasý';
    REntegraBaglantiHatasi = 'Entegra Baðlantý Hatasý';
    RGenotipBaglantiHatasi = 'Genotýp Baðlantý Hatasý';
    RFaturaSilinmeyeUygunDegildir = 'Faturanýn Entegrada durumu silinmeye uygun deðildir.';
    REntegraFaturaSilmeHatasi = 'Entegra fatura silme hatasý';
    RFaturadaEslesmeicinFirmaKoduYok = 'Genotýp faturasýnda eþleþme için firma kodu bulunamadý!';
    ROnceRehberKayitlariniziAktarin = 'Genotýp faturasýndaki rehber kaydý Entegrada bulunamadý. lütfen ilk önce rehber kayýtlarýnýzý aktarýnýz!';
    ROdemeTarihiGirilmemis = 'Ödeme planý oluþturulamadý: Ödeme tarihi girilmemiþ.';
    RDigerTumAlanlarOpsiyoneldir = 'Rehber entegrasyonunda ''KOD'' ve ''FIRMA'' alanlarý zorunlu alanlardýr. Diðer tüm alanlar opsiyoneldir.';
    RHesapPlaniniYapilandir = 'Aktarýmdan önce Hesap Planýnýzý uygun olarak yapýlandýrmalýsýnýz.';
    RBirSonrakiKayittanDevamEdilecek = 'Aktarýmda zorunlu alanlardan birinin boþ kalmasý durumunda o kayýt atlanacak ve bir sonraki kayýttan devam edilecektir.';
    REklenecekOpsiyonelAlanlar = 'Kayýtlarda eklenecek olan opsiyonel alanlar;';
    RAdresBilgileri = 'Adres,PK,ILCE,IL,Fatura Baþlýðý,Vergi Dairesi,Vergi No,Ýþ Tel,Cep Tel,Ev Tel,E-Posta,Web Adresidir.';
    REklenecekAlanlar = 'Kayýtlarda eklenecek olan alanlar;';
    RAdresBilgileri2 = 'Kod,Ünvan,Adres,PK,ILCE,IL,Fatura Baþlýðý,Vergi Dairesi,Vergi No,Ýþ Tel,Cep Tel,Ev Tel,E-Posta,Web Adresidir.';
    RBuBolumeGecmedenOnce = 'Bu bölüme geçmeden önce;';
    RRehberAktarýmýnýTamamla = 'Hesap planýnýzý oluþturmalý ve rehber aktarýmýnýzý tamamlamalýsýnýz.';
    REntegradaTanýmlýOlmasýGerek = 'Faturalarýn ilgili kurumlarýnýn Entegrada da tanýmlý olmasý gerekmektedir. ';
    RRehberAktariminiziTamamla = 'Bu bölüme geçmeden önce daha önce yapmadýysanýz lütfen rehber aktarýmýnýzý tamamlayýnýz.';
    RBirlikteAktarilacaktir = 'Faturalar tüm satýrlarý, var ise masraf/gelir merkezleri ve planlanan ödeme tarihleri ile birlikte aktarýlacatýr.';
    RCariDevirKayitlariAktarilmayacak = 'Eklenmemiþ Rehber kayýtlarý için Cari devir kayýtlarý aktarýlmayacaktýr.';
    RBankaTanimlamalariYenidenDuzenle = 'Banka tanýmlama sistemi deðiþtiðinden; Bankalar bölümü içerisinden tüm banka tanýmlamalarýnýzý yeniden düzenlemelisiniz.';
    RLogayaTiklayarakYap = 'Bu düzenlemeleri seçmiþ olduðunuz bankanýn logosuna týklayarak kolayca yapabilirsiniz.';
    RCekVeSenetlericerisinden = 'Çek ve Senetler içerisinden;';
    RTumVerilerAktarilacaktir = 'Vade tarihi henüz gelmemiþ olanlar ile ve durumu ödendi yada iptal olarak iþaretlenmemiþ tüm veriler aktarýlacaktýr.';
    RDuzenlemeleriTamamlamisOlmali = 'Tüm diðer aktarým iþlemlerini bitirmiþ ve aktarýmlar sonrasýndaki düzenlemeleri tamamlamýþ olmanýz gerekmektedir.';
    RKayitlarSistemUzerineEklenebilir = 'Detay kayýtlarý ancak kullanýma geçmiþ bir sistem üzerine eklenebilir!';
  //UTablo
    TGorevUzerindeDegisiklikYapamaz = 'Görevle iliþkisi olmayan kiþiler görev üzerinde deðiþiklik yapamaz.';
    TIptalEdilmisGorevAktifEdilemez = 'Ýptal edilmiþ bir görev tekrar aktif edilemez';
    TDurumuAtayanDegistirebilir = 'Onaylanmýþ bir görevin durumu yalnýzca atayan kiþi tarafýndan deðiþtirilebilir';
    TGoreviAtayanOnaylar = 'Görev ancak atayan kiþi tarafýndan onaylanabilir';
    TGoreviAtayanIptalEder = 'Görev ancak atayan kiþi tarafýndan iptal edilebilir';
    TErtelemeAtayanKisiYapar = 'Görev erteleme onayý yalnýzca görevi atayan kiþi tarafýndan yapýlabilir';
    TErtelemeTarihiDoluOlmalidir = 'Görev Erteleme tarihi dolu olmalýdýr';
    TYok = '(yok)';
    TSurumBilgisiYok = 'Sürüm bilgisi yok';
    TCýkmakIstediginizKadarUrunYok = 'Stokta çýkmak istediðiniz kadar ürün yok';
    TCýkmakIstediginizKadarUrunYokYinedeCýk = 'Stokta çýkmak istediðiniz kadar ürün yok, Yine de Çýkýþ yapmak istiyor musunuz?';
    TYetkiAlanindakiPersoneller = 'Yetki Alanýndaki personeller';
    TAyniKodaSahipKayitOlamaz = 'Ayný koda sahip iki kayýt bulunamaz...';
    TBosAlanHatasi = 'Boþ alan hatasý';
    TSeriNumaraDahaOnce = 'Bu seri numarasý daha önce ' ;
    TIsimliMusterideKullanilmistir = ' isimli müþteride kullanýlmýþ!';
    TKlasorAdiniGirin = 'Klasör Adýný Giriniz';
    TKlasorResiminiSeciniz = 'Klasör Resmini Seçiniz';
    TServerAdiniGirin = 'Aktarým Yapýlacak Server Adýný Giriniz.';
    TServerAdiVeyaIpAdresi = 'Server Adý veya IP Adresi:';
    TServerAdiBosOlamaz = 'Server Adý Boþ Olamaz.';
    TVeritabaniAdiniGiriniz = 'Aktarým Yapýlacak Veritabaný Adýný Giriniz.';
    TVeritabaniAdý = 'Veritabaný Adý:';
    TVeritabaniBosOlamaz = 'Veritabaný Adý Boþ Olamaz.';
    TKullaniciAdiniGiriniz = 'Kullanýcý Adýný Giriniz.';
    TKullaniciAdi = 'Kullanýcý Adý:';
    TKullaniciAdiBosOlamaz = 'Kullanýcý Adý Boþ Olamaz.';
    TSifre = 'Þifre';
    TYeniSifreyiGiriniz = 'Yeni Þifreyi Giriniz.';
    TServerSifresiniGiriniz = 'Aktarým Yapýlacak Server Þifresini Giriniz.';
    TServerSifresi = 'Server Þifresi';
    TDikkatBulunamayanIndex = 'Dikkat! Bulunamayan Ýndeks : ';
    TVarsayilanFiyaSec = 'Kasa opsiyonlardan varsayýlan alýþ satýþ fiyatlarýný ayarlayýnýz! Hatalara sebep olabilir.';
    TEklenecekBilgiyiYaz = 'Eklemek istediðiniz bilgiyi buraya yazýnýz.';
    TDurumDegisikligiBilgisiGir = 'Durum deðiþikliði ile ilgili bilgi giriniz.';
    TYeniDurumAcýklamasiGir = 'Yeni Durum için açýklama girin.';
    TREHBERINIexTablosunda = 'REHBERINIEX tablosunda ' ;
    TBolumuIcin = ' bölümü için ' ;
    TAnahtariBulunamadi = ' Anahtarý bulunamadý!';
    TAktiviteSablonlari = 'Aktivite Þablonlarý';
    TTalimatSureciUyarisi = 'Talimat Süreci Uyarýsý';
    TEPostaHatali = 'EPosta Hatalý..';
    TBaglantiKurulamadi = 'Baðlantýda Hata(FTP): Baðlantý Kurulamadý!';
    TDosyaTransferEdilemedi = 'Baðlantýda Hata(FTP): Dosya Transfer Edilemedi!';
    TBaglantiTuruDesteklenmiyor = 'Baðlantý türü desteklenmiyor!';
    TFTPBilgileriYokyadaHatali = 'FTP Bilgileri Yok yada Hatalý!';
    TKayitIslemiGerceklestirilemedi = ' Kayýt Ýþlemi Gerçekleþtirilemedi!!';
    TAktarilamayanAlanlar = 'Aktivite Oluþturuldu, Aktarýlamayan Alanlar:';
    TAktiviteSablonuBulunamadi = 'Hata: Aktivite Þablonu Bulunamadý!';
    TAkibetAlinirkenLutfenBekleyin = 'Akibet bilgileri alýnýrken lütfen bekleyiniz..';
    TBaglantiBilgileriAliniyor = 'Baðlantý Bilgileri Alýnýyor...';
    TDesenBulunmamaktadir = 'Bu banka için desen bulunmamaktadýr..';
    TBaglantiKuruluyor = 'Baðlantý Kuruluyor..';
    TSonlandirmaIslemleriYapiliyor = 'Sonlandýrma iþlemleri yapýlýyor..';
    TTalimatImzalanirkenBekle = 'Talimat imzalanýrken lütfen bekleyiniz..';
    TTelefonNoHatali = 'Telefon no hatalý.. Rehber kayýtlarýnýza gözatýn..';
    TGSMOperatoruHatali = 'GSM Operatörü hatalý.. Rehber kayýtlarýnýza gözatýn..';
    TParmakIziAliniyor = 'Parmak izi alýnýyor...';
    TImzaGonderimHatasi = 'Ýmza Gönderim Hatasý:';
    TEimzaMesaji = 'E-imza mesaji';
    TImzaGercekDosyaKaydediliyor = 'Ýmza Gerçek, Dosya kaydediliyor..';
    TDosyaKistiriliyor = 'Dosya Sýkýþtýrýlýyor..';
    TDosyaVeritabaninaYazilamadi = 'Dosya veritabanýna yazýlamadý!';
    TDosyaBasariylaKaydedildi = 'Dosya Baþarýyla kaydedildi.';
    TGirilmisBilgiVarOnce = 'Girilmiþ bilgi var. Önce ';
    TBilgileriniSiliniz = ' bilgilerini siliniz...';
    TZimmetIadeKaydi = 'Zimmet Ýade Kaydý';
    TZimmetIadeVeren = 'Zimmet Ýade Veren';
    TZimmetIadeAlani = 'Zimmet Ýade Alan';
    TYeniZimmetKaydi = 'Yeni Zimmet Kaydý';
    TDemirbasKayipKaydi = 'Demirbaþ Kayýp Kaydý';
    TZimmetSahibi = 'Zimmet Sahibi';
    TDemirbasHurdaKaydi = 'Demirbaþ Hurda Kaydý';
    TZimmetTransferKaydi = 'Zimmet Transfer Kaydý';
  //URehberAyar
    RGirilmisBilgiVar = 'Girilmiþ bilgi var! Silinemez/Deðiþtirilemez';
  //URehberAramaEkrani
    RAEPersonelAramaEkrani = 'Personel arama ekraný';
    RAEAramaEkrani = 'Arama ekraný';
  //UOpsiyonStok
    OSIslemTamamlandi = 'Ýþlem Tamamlandý';
    OSDegisiklikKaydedilsinmi = 'Depo Tanýmlarýnda yaptýðýnýz deðiþiklik kaydedilsin mi?';
    OSDepoAdiBosOlamaz = 'Depo Adý Boþ olamaz';
  //ULisans
    LKurumKodunuGir = 'Lisans için kurum kodunu girin:';
    LKurumKoduBosOlamaz = 'Kurum Kodu Boþ Olamaz.';
    LTerminalLimitinizDolu = 'Terminal Limitiniz Dolu';
    LTerminalSayisiniAyarlayiniz = 'Lütfen Lisanslama modülünden aktif terminal sayýsýný ayarlayýnýz.';
    LTerminalAktifDegil = 'Bu terminal aktif deðil';
    LDuzenlemeYapmalisin = 'Aktif hale getirebilmek için GenLisanslama Modülünden, Terminaller bölümünden düzenleme yapmalýsýnýz';
    LTerminalKayitliDegil = 'Bu terminal tanýmlý deðil';
    LTerminaliKaydetmekicinOK = 'Terminali kaydetmek için ismi yazýp Tamama týklamalýsýnýz';
    LLisans = 'Lisans';
    LEntegraileIrtibataGec = 'Sistemin çalýþma izni yok. ENTEGRA ile irtibata geçmeniz gerekmektedir.';
    LModulLisansi = 'Modül Lisansý';
    LLisansýnBulunmamaktadir = 'Bu modül için lisansýnýz bulunmamaktadýr';
    LTerminal = 'Terminal';
    LTerminalSistemdeKayitliDegil = 'Bu terminal sistemde kayýtlý deðil.';
    LServerAyarDegismisIrtibataGec = 'Server ayarlarýnýz deðiþmiþ. Lütfen ENTEGRA ile görüþünüz.';
    LYeniBirLisansAlmanGerek = 'Yeni bir lisans almanýz gerekebilir.';
    LDemoSuresi = 'Demo süresi';
    LDemoSuresininDolmasina = 'Demo süresinin dolmasýna  ';
    LDemoSuresiDolmustur = 'Demo süresi dolmuþtur.';
    LLisansSuresi = 'Lisans süresi';
    LLisansSuresininDolmasina = 'Lisans süresinin dolmasýna ';
    LGunKalmistir = ' gün kalmýþtýr.';
    LLisansSuresiDolmustur = 'Lisans süresi dolmuþtur.';
    LLisansDondurulmustur = 'Lisans dondurulmuþtur';
    LYazilimCalismayacaktir = 'Yazýlým çalýþmayacaktýr';
    LBuisimdeKayitliTerminalVar = 'Bu isimde kayýtlý terminal var.';
    LTerminalKaydedildi = 'Terminal kaydedildi.';
  //UMaasTablo
    MTTutarSatiriBulunamadi = 'Ad Soyad - Hesapno - Tutar satýrý bulunamadý..';
    MTTutarSutunuBulunamadi = 'Tutar sütunu bulunamadý!';
    MTHesapNoSutunuBulunamadi = 'Hesap No sütunu bulunamadý!';
    MTHesapNoBulunamadi = ' Hesap No bulunamadý!';
    MTBorcluBankaHesapNoEksik = 'borçlu banka hesap numaralarý eksik!';
    MTAlacakliBankaHesapNoEksik = 'alacaklý banka hesap numaralarý eksik!';
    MTHicSecimYapilmamis = ' Hiç seçim yapýlmamýþ!';
    MTExcelTablosunuSecin = ' Excel tablosunu seçin!';
    MTKimlikNoSutunNo = 'T.C.Kimlik No Sütun No :';
    MTToplamMaasSutunNo = 'Toplam Maaþ Sütun No :';
    MTBankadanOdenecekSutunNo = 'Bankadan Ödenecek Sütun No :';
    MTAgiSutunNo = 'Agi Sütun No :';
    MTKasaSutunNo = 'Kasa Sütun No :';
    MTBankadanAvansSutunNo = 'Bankadan Avans Sütun No :';
    MTKasadanAvansSutunNo = 'Kasadan Avans Sütun No :';
    MTKasadanOdenecekSutunNo = 'Kasadan Ödenecek Sütun No :';
    MTPersonelListesindeBulunamadi = ' T.C.Kimlik No Personel listesinde bulunamadý!';
    MTAsagidakiPersonellerden = 'Aþaðýdaki personellerden ';
    MTBorcluKasaBilgisiEksik = 'borçlu kasa bilgisi eksik!';
    MTMakbuzNoVerilsinmi = 'Makbuz Numarasý verilsin mi?';
    MTMakbuzKesmeOnayi = 'Makbuz kesme onayý';
    MTParaBirimiEksik = 'para birimi eksik!';
    MTOnceMaasTablosunuBosalt = 'Yeniden oluþturmak için önce maaþ tablosunu boþaltmalýsýnýz!';
  //UKrediler
    KGirilmisOdemeTakvimiVarSilinsinmi = 'Daha önce girilmiþ ödeme takvimi var. Silinsin mi?';
    KKrediHesabinaEklensinmi = 'Kredi hesabýna eklensin mi?';
    KDahaOnceEklenmis = 'Daha önce eklenmiþ';
    KOdemePlaniTumuyleSilinsinmi = 'Ödeme planý tümüyle silinsin mi?';
    KKrediBilgisiSilinsinmi = 'Kredi bilgisi silinsin mi?';
    KOdemeBilgisiSilinsinmi = 'Ödeme bilgisi silinsin mi?';
    KBuKredinin = 'Bu kredinin ';
    KTarihindeOdemesiVarSilinemez = ' tarihinde ödemesi var silinemez!';
  //üretim
    FTWUretimleriSil = 'Önce Transfer satýrlarýný silmeniz gerekiyor';
  //HizliGiris
    HGToplam = 'Toplam';
    HGOdenmis = 'Ödenmiþ';
    HGNakitOdeme ='Nakit';
    HGKKOdeme = 'KK';
    HGDigerOdeme = 'Diðer';
    HGIadeCeki = 'Ýade Çeki';
    HGHediyeCeki = 'Hediye Çeki';
  //Genel
    TamEkran = 'Tam Ekran';
    KucukEkran = 'Küçük Ekran';
    Uyari = 'U Y A R I';
    Onay = 'O N A Y';
    Bilgi = 'B Ý L G Ý';
    HataPrj = 'H A T A';
    Dikkat = 'D Ý K K A T';
    Adres = 'Adres: ';
    isTel = 'Ýþ Tel: ';
    EPosta = 'Eposta: ';
    Seciniz = 'Seçiniz';
    SerinoSec = 'Seri No Listesi';
    GelirMerkeziSec = 'Gelir Merkezi';
    MasrafMerkeziSec = 'Masraf Merkezi';
    BosBirakilamaz = ' boþ býrakýlamaz.';
    SifirOlamaz = ' 0 olamaz.';
    HizmetSecimi = 'Hizmet Seçimi';
    StokSecimi ='Stok Kart Listesi';
    KasaListesi = 'Kasa Listesi';
    KampanyaSecimi = 'Kampanya Listesi';
    MusteriilgiliSec = 'Müþteri Ýlgili Listesi';
    AktiviteSecimi = 'Aktivite Seçimi';
    ProjeSecimi = 'Proje Seçimi';
    AksiyonSecimi = 'Aksiyon Seçin!';
    AktiviteGorevSec = 'Aktivite/Görev Listesi';
    TeklifSec ='Teklif Listesi';
    MasrafMerkeziPrj = 'Masraf Merkezi';
    MasrafAdi = 'Masraf Adý';
    GelirMerkezi = 'Gelir Merkezi';
    GelirAdi = 'Gelir Adý';
    KategoriListesi = 'Kategori Listesi';
    TabloHatali = 'Tablo Hatalý!!';
    BankaSecimi = 'Banka Seçimi';
    BaglantiBilgileri = 'Baðlantý Bilgileri';
    Tahsilat = 'Tahsilat';
    AlacakTahakkuku = 'Alacak Tahakkuku';
    Odeme = 'Ödeme';
    Alacak = 'Alacak ';
    Borc = 'Borç ';
    BorcTahakkuku = 'Borç Tahakkuku';
    NakitTahsilat = 'Nakit Tahsilat';
    GelenHavaleEFT = 'Gelen Havale / EFT';
    PosileTahsilat = 'POS ile Tahsilat ';
    NakitOdeme = 'Nakit Ödeme';
    GonderilenHavaleEFT = 'Gönderilen Havale / EFT ';
    KrediKartiileOdeme = 'Kredi Kartý ile Ödeme';
    IadeCekiileOdeme ='Ýade Çeki ile Ödeme';
    IadeCekiileTahsilat ='Ýade Çeki ile Tahsilat';
    HediyeCekiileOdeme ='Hediye Çeki ile Ödeme';
    HediyeCekiileTahsilat ='Hediye Çeki ile Tahsilat';
    KuponileOdeme ='Kupon ile Ödeme';
    KuponileTahsilat ='Kupon ile Tahsilat';

    DoluOlmali = ' dolu olmalý!';
    ConnectionNesnesiAcik = 'Connection Nesnesi Açýk';
    Server = 'Server';
    Veritabaniprj = 'Veritabaný';
    Cuma = 'Cuma';
    Cumartesi = 'Cumartesi';
    Pazar = 'Pazar';
    YeniBelgeCikisi = 'Yeni Belge Çýkýþý';
    YeniBilgiGirisi = 'Yeni bilgi giriþi';
    BaslikAdiniGirin = 'Baþlýk adýný girin';
    ilgiliAdiniGirin = 'Ýlgili adýný girin';
    IletisimAdiniGirin = 'Ýletiþim adýný girin';
    Bilgilendirma = 'Bilgilendirme';
    SeriNoGirin = 'Seri numarasýný girin!';
    BankayiSecveGirin = 'Bankayý seçin girin!';
    GecersizSeriNo = 'Geçersiz Seri Numarasý!';


    KontrolAktiviteTuru = 'Aktivite Türü';
    KontrolAktiviteKonusu = 'Aktivite Konusu';
    KontrolStokKodu = 'Stok Kodu';
    KontrolStokAdi = 'Stok Adý';
    KontrolAnaBirimi = 'Ana Birimi';
    KontrolKDV = 'KDV';
    Kontrol2Birim = '2.Birim';
    Kontrol2BirimCarpani = '2.Birim Çarpaný';
    KontrolAlimTarihi= 'Alým Tarihi';
    KontrolKabulEden = 'Kabul Eden';
    KontrolEkleyen = 'Ekleyen';
    KontrolLokasyon = 'Lokasyon';
    KontrolDurum = 'Durum';
    KontrolMaasTarih = 'Maas Tarihi';
    KontrolTuru = 'Türü';
    KontrolFiyatListeAdi = 'Fiyat Adý';
    KontrolKonusu = 'Konusu';
    KontrolSorumlu = 'Sorumlu';
    KontrolSorumluBilgisi = 'Sorumlu Bilgisi';
    KontrolAsamaSorumlusu = 'Aþama Sorumlusu';
    KontrolAsamasi = 'Aþamasý';
    KontrolGorevAtayan = 'Görev Atayan';
    KontrolGorevAtanan = 'Görev Atanan';
    KontrolBaslangisTarihi = 'Baslangýç Tarihi';
    KontrolBitisTarihi = 'Bitiþ Tarihi';
    KontrolGorevBasligi = 'Görev Baþlýðý';
    KontrolSablonAdi = 'Þablon Adý';
    KontrolFaturaAdet = 'Fatura adet';
    KontrolBirimFiyati = 'Birim Fiyat';
    KontrolFaturaTarihi = 'Fatura Tarihi';
    KontrolTarihi = ' Tarih';
    KontrolNo = ' No';
    KontrolStatu = 'Statü';
    KontrolDokumanNo = 'Döküman No';
    KontrolSurum = 'Sürüm';
    KontrolYonu = 'Yönü';
    KontrolDokumanAd = 'Döküman Ad';
    KontrolGrup = 'Grup';
    KontrolKod = 'Kod' ;
    KontrolKodAdi = 'Kod Adý' ;
    KontrolFirma = 'Firma';
    KontrolKonu = 'Konu';
    KontrolTipi = 'Tipi';
    KontrolAciklama = 'Açýklama';
    KontrolIcerikTuru = 'Ýçerik Türü';
    KontrolBankaHesabi = 'Banka Hesabý';
    KontrolCekKrediKodu = 'Çek Kredi Kodu';
    KontrolCekKrediAdi = 'Çek Kredi Adý';
    KontrolCekKrediSozlesmeNo = 'Çek Kredi Sözleþme No';
    KontrolTeminati = 'Teminatý';
    KontrolLimitTipi = 'Limit Tipi';
    KontrolMinSeviye = 'Min.Seviye';
    KontrolLimitSuresi = 'Limit Süresi';
    KontrolLimit = 'Limit';
    KontrolBankaSubesi = 'Banka Þubesi';
    KontrolHesapKodu = 'Hesap Kodu';
    KontrolHesapAdi = 'Hesap Adý';
    KontrolHesapNo = 'Hesap No';
    KontrolParaBirimi = 'Para Birimi';
    KontrolHesapTipi = 'Hesap Tipi';
    KontrolSubeAdi = 'Þube Adý';
    KontrolSubeKodu = 'Þube Kodu';
    KontrolEposta = 'EPosta';
    KontrolKullaniciAdi = 'Kullanýcý Adý';
    KontrolGonderen = 'Gönderen';
    KontrolSifre = 'Þifre';
    KontrolSunucu = 'Sunucu';
    KontrolPort = 'Port';
    KontrolKocanNo = 'Koçan No';
    KontrolBaslangicNo = 'Baþlangýç No';
    KontrolKrediKodu = 'Kredi Kodu';
    KontrolKrediAdi = 'Kredi Adý';
    KontrolSozlesmeNo = 'Sözleþme No';
    KontrolKrediTuru = 'Kredi Türü';
    KontrolBankaKoduTicari = 'Banka Kodu (Ticari)';
    KontrolKullanimSuresi = 'Kullaným Süresi';
    KontrolGelir = 'Gelir';
    KontrolMasraf = 'Masraf';
    KontrolKur = 'Kur';

    GecerliBirimTipiDegil = 'Seçilen birim bu ürün için geçerli bir birim tipi deðil';
    SeciliSatirSil = 'Seçili kayýt silinecektir. Onaylýyor musunuz?';
    cnst_SablonAdiBosOlamaz ='Þablon Adý Boþ Olamaz';
    //UItsEczaDepo
    Its_Islem_Gonderildi = 'Ýts sistemine gönderim tamamlandý.';
    Its_Islem_Secilen_Adet_Gecerli_Degil = 'Seçilen adet geçerli deðil';
    //Döküman Yönetimi
    DYIcerikSilmeSorusu = 'Ýçerikteki &Parametre& silmek istediðinize emin misiniz?';
    DYKlasor ='Klasör';
    DYDokuman ='Döküman';
    DYBelge ='Belge';
    DYKlasoru ='Klasörü';
    DYDokumani ='Dökümaný';
    DYBelgeyi ='Belgeyi';

const
    //OPSÝYONLAR
    //Genel Opsiyonlar 10___
    Ops_GenelOpsiyon_Log = -10001;
    Ops_GenelOpsiyon_GenYazilimIPAdress = -10002;
    Ops_UyariOpsiyon_YenilemeSuresi = -10003;
    Ops_UyariOpsiyon_YeniKayitSuresi = -10004;
    Ops_GenelOpsiyon_VarsayilanDoviz = -10005;
    Ops_Doküman_Dizin = -10006;
    Ops_StokHizliGiris_VarsayilanFiyat =-10007;
    Ops_StokHizliGiris_VarsayilanFiyatAlis =-10008;
    Ops_GenelOpsiyon_KesinGunu=-10010;
    Ops_GenelOpsiyon_LogEkleme = -10011;
    Ops_GenelOpsiyon_LogSilme = -10012;
    Ops_GenelOpsiyon_LogDegistirme = -10013;
    Ops_GenelOpsiyon_DovizPanelGor = -10014;
    Ops_GenelOpsiyon_DovizOtoGuncelle = -10015;
    Ops_UyariOpsiyon_Aktif = -10016;
    Ops_Doküman_Kayit_Yeri = -10017;
    Ops_Doküman_MaxBoyut = -10018;
    Ops_GenelOpsiyon_ITSHesapId = -10019;
    Ops_GenelOpsiyon_EpostaHesapId = -10020;
    Ops_GenelOpsiyon_SMSHesapId = -10021;
    Ops_GenelOpsiyon_VersiyonNo = -10022;

    Ops_GenelOpsiyon_RepGSCariHar = -10023;
    Ops_GenelOpsiyon_RepGSTahsilat = -10024;
    Ops_Entegrasyon_Ent_Server = -10025;
    Ops_Entegrasyon_Ent_DB = -10026;
    Ops_GenelOpsiyon_BSMV = -10027;
    Ops_GenelOpsiyon_KURUMADI = -10028;

    Ops_IlaçFiyatOranBilgileri_Kademe1_Barem = -10029;
    Ops_IlaçFiyatOranBilgileri_Kademe1_Etiket = -10030;
    Ops_IlaçFiyatOranBilgileri_Kademe1_DepoKar = -10031;
    Ops_IlaçFiyatOranBilgileri_Kademe1_EczaciKar = -10032;
    Ops_IlaçFiyatOranBilgileri_Kademe2_Barem = -10033;
    Ops_IlaçFiyatOranBilgileri_Kademe2_Etiket = -10034;
    Ops_IlaçFiyatOranBilgileri_Kademe2_DepoKar = -10035;
    Ops_IlaçFiyatOranBilgileri_Kademe2_EczaciKar = -10036;
    Ops_IlaçFiyatOranBilgileri_Kademe3_Barem = -10037;
    Ops_IlaçFiyatOranBilgileri_Kademe3_Etiket = -10038;
    Ops_IlaçFiyatOranBilgileri_Kademe3_DepoKar = -10039;
    Ops_IlaçFiyatOranBilgileri_Kademe3_EczaciKar = -10040;
    Ops_IlaçFiyatOranBilgileri_Kademe4_Barem = -10041;
    Ops_IlaçFiyatOranBilgileri_Kademe4_Etiket = -10042;
    Ops_IlaçFiyatOranBilgileri_Kademe4_DepoKar = -10043;
    Ops_IlaçFiyatOranBilgileri_Kademe4_EczaciKar = -10044;
    Ops_IlaçFiyatOranBilgileri_Kademe5_Barem = -10045;
    Ops_IlaçFiyatOranBilgileri_Kademe5_DepoKar = -10046;
    Ops_IlaçFiyatOranBilgileri_Kademe5_EczaciKar = -10047;
    Ops_IlaçFiyatOranBilgileri_KDVOraný = -10048;

    Ops_GenelOpsiyon_AktarimRehberKayitlari = -10049;
    Ops_GenelOpsiyon_AktarimStokKart = -10050;
    Ops_GenelOpsiyon_AktarimStokGiris = -10051;
    Ops_GenelOpsiyon_AktarimGunSonu = -10052;
    Ops_GenelOpsiyon_AktarimKurumFaturalari = -10053;

    Ops_Yedekleme_YedeklemeDizin = -10054;
    Ops_Yedekleme_YedeklemeAdi = -10055;
    Ops_Yedekleme_Acilirken = -10056;
    Ops_Yedekleme_Kapanirken = -10057;
    Ops_Yedekleme_TutulacakCheck = -10058;
    Ops_Yedekleme_TutulacakGun = -10059;
    Ops_Yedekleme_PaylasimAdi = -10060;
    Ops_Yedekleme_PaylasimYolu = -10061;
    Ops_Yedekleme_GeciciSurucu = -10062;
    Ops_Yedekleme_KullaniciAdi = -10063;
    Ops_Yedekleme_Sifre = -10064;
    Ops_Yedekleme_Rar = -10065;
    Ops_Yedekleme_Zip = -10066;
    Ops_Yedekleme_Backup = -10067;
    Ops_Yedekleme_SonYedek_Giris = -10068;
    Ops_Yedekleme_SonYedek_Cikis = -10069;

    Ops_GenelOpsiyon_Sifre = -10070;

    //CRM Opsiyonlar 21___
    Ops_GorevOpsiyon_DurumAciklama = -21001;
    Ops_GorevXgungoster = -21002;
    Ops_AktiviteOpsiyon_PersonelYetkiKontrol = -21003;
    Ops_AktiviteOpsiyon_TarihceEkleSorumlu = -21004;
    Ops_AktiviteOpsiyon_TarihceEkleTakipci = -21005;
    Ops_AktiviteOpsiyon_TarihceEkleMusteri = -21006;
    Ops_AktiviteOpsiyon_TarihceEkleDurum = -21007;
    Ops_AktiviteOpsiyon_TarihceEkleTO = -21008;
    Ops_AktiviteOpsiyon_TarihceEkleTuru = -21009;
    Ops_AktiviteOpsiyon_BagliAktiviteKullan = -21010;
    Ops_AktiviteOpsiyon_GorevAtamaIzýnKontrol = -21011;
    Ops_AktiviteOpsiyon_AmiriTakipciGetir = -21012;
    Ops_AktiviteOpsiyon_AmiriBilgilendirilecekGetir = -21013;
    Ops_ProjeOpsiyon_ProjTrhcSorumlu = -21014;
    Ops_ProjeOpsiyon_ProjTrhcAsama = -21015;
    Ops_ProjeOpsiyon_ProjTrhcDurum = -21016;
    Ops_ProjeOpsiyon_ProjTrhcSonuc = -21017;
    Ops_ProjeOpsiyon_ProjTrhcMusteriIlgili = -21018;
    Ops_ProjeOpsiyon_ProjeKoduUretme = -21019;

    Ops_AktiviteOpsiyon_AktiviteEpostaBildirimAktif = -21020;
    Ops_AktiviteOpsiyon_AktiviteSMSBildirimAktif = -21021;
    Ops_AktiviteOpsiyon_AktiviteEpostaBildirimSekli = -21022;

    Ops_Projeler_KodGrubu = -21023;
    Ops_ProjeOpsiyon_ProjTrhcAsamaSorumlu = -21024;

    //Cari Opsiyonlar  22___
    Ops_CariOpsiyon_CariKodGirisi = -22001;
    //Kasa Opsiyonlar 23___
    Ops_KasaOpsiyon_KDVOrani = -23001;
    Ops_StokHizliGiris_KasaAcilisKapanis = -23002;
    Ops_StokHizliGiris_HerGiristeKimlikDogrula = -23003;
    Ops_HizliGiris_IskontodaAciklamaSor = -23004;
    Ops_KasaOpsiyon_MakbuzNoDijitSay = -23005;
    Ops_KasaOpsiyon_MakbuzNoSifirla = -23006;
    Ops_KasaOpsiyon_OdemeMakbuzNoDijitSay = -23007;
    Ops_KasaOpsiyon_OdemeMakbuzNoSifirla = -23008;
    Ops_StokHizliGiris_TahTurNakit = -23009;
    Ops_StokHizliGiris_TahTurPOS = -23010;
    Ops_StokHizliGiris_TahTurHC = -23011;
    Ops_StokHizliGiris_TahTurIC = -23012;
    Ops_StokHizliGiris_TahTurKupon = -23013;
    Ops_StokHizliGiris_OdeTurNakit = -23014;
    Ops_StokHizliGiris_OdeTurHC = -23015;
    Ops_StokHizliGiris_OdeTurPOS = -23016;
    Ops_StokHizliGiris_OdeTurIC = -23017;
    Ops_StokHizliGiris_OdeTurKupon = -23018;
    Ops_KasaOpsiyon_BakiyeKurali = -23019;
    Ops_KasaOpsiyon_BelgeGiderMerkezi = -23020;
    Ops_KasaOpsiyon_BelgeGelirMerkezi = -23021;
    Ops_KasaOpsiyon_OdemeGiderMerkezi = -23022;
    Ops_KasaOpsiyon_TahsilatGiderMerkezi = -23023;
    Ops_StokHizliGiris_AciklamaF1 = -23024;
    Ops_StokHizliGiris_AciklamaF2 = -23025;
    Ops_StokHizliGiris_AciklamaF3 = -23026;
    Ops_StokHizliGiris_AciklamaF4 = -23027;
    Ops_StokHizliGiris_AciklamaF5 = -23028;
    Ops_StokHizliGiris_AciklamaF6 = -23029;
    Ops_StokHizliGiris_AciklamaF7 = -23030;
    Ops_StokHizliGiris_AciklamaF8 = -23031;
    Ops_StokHizliGiris_AciklamaF9 = -23032;
    Ops_StokHizliGiris_AciklamaF10 = -23033;
    Ops_StokHizliGiris_AciklamaF11 = -23034;
    Ops_StokHizliGiris_AciklamaF12 = -23035;
    Ops_StokHizliGiris_VarsayilanKDVDurum = -23036;
    Ops_KasaOpsiyon_ButceyiFaturalardanHesapla = -23037;
    Ops_HizliGiris_BaskiBelgeNoSor = -23038;
    Ops_HizliGiris_FazlaIskontoYapabilir = -23039;
    Ops_HizliGiris_FaturaBilgisiSor = -23040;

    Ops_KasaEkran_Banka = -23041;
    Ops_KasaEkran_CekveSenet = -23042;
    Ops_KasaEkran_Tahakkuk = -23043;
    Ops_KasaEkran_Kasa = -23044;
    Ops_KasaEkran_Plan = -23045;

    Ops_ExcelMaasEsles_TcKimNo = -23046;
    Ops_ExcelMaasEsles_Maas = -23047;
    Ops_ExcelMaasEsles_Banka = -23048;
    Ops_ExcelMaasEsles_Agi = -23049;
    Ops_ExcelMaasEsles_Kasa = -23050;
    Ops_ExcelMaasEsles_AvBanka = -23051;
    Ops_ExcelMaasEsles_AvKasa = -23052;
    Ops_ExcelMaasEsles_OdeBanka = -23053;
    Ops_ExcelMaasEsles_OdeKasa = -23054;
    //Alýþ-Satýþ Opsiyonlar 24___
    Ops_FaturaOpsiyon_ZorunluPlanOlustur =-24001;
    Ops_FaturaOpsiyon_OndalikDijitSayBr = -24002;
    Ops_FaturaOpsiyon_OndalikDijitSayTut =-24003;
    Ops_FaturaOpsiyon_SatirlaraVade = -24004;
    Ops_FaturaOpsiyon_BasligaVade = -24005;


    //Banka Opsiyonlar  25___
    Ops_OpsiyonBanka_MasrafTutar = 25001;
    Ops_OpsiyonBanka_MasrafMerkezi = 25002;
    //Çek-Senet Opsiyonlar  26___
    Ops_Çekler_CekSeriNoKontrolü = 26001;
    Ops_Çekler_CekRiskPayiKontrolü = 26002;
    Ops_Çekler_CekOdemedeMMAktar = 26003;
    Ops_Senetler_SenetOdemedeMMAktar = 26004;
    Ops_Çekler_CekOdemedeMMSil = 26005;

    //Stok Opsiyonlar  27___
    Ops_StokOpsiyon_StokVarsayilanBirim = -27001;
    Ops_StokOpsiyon_StokDurumKontrolKurali = -27002;
    Ops_StokOpsiyon_StokAraFocusKurali = -27003;
    Ops_StokOpsiyon_StokKodGirisi = -27004;
    Ops_StokOpsiyon_StokKalmayanlar = -27005;
    Ops_StokOpsiyon_OnayliSayimDegistirme = -27006;
    //Demirbaþ Opsiyonlar 28___

    //Teklif Opsiyonlar  29___
    Ops_TeklifOpsiyon_NoDijitSay = 29001;
    Ops_TeklifOpsiyon_NoSifirla = 29002;
    //Servis Opsiyonlar 30___

    Ops_OpsiyonServis_ProblemKullan = -30001;
    Ops_OpsiyonServis_FizikselDurumKullan = -30002;
    Ops_OpsiyonServis_AksesuarKullan   = -30003;
    Ops_OpsiyonServis_NedeniKullan   = -30004;
    Ops_OpsiyonServis_PlanlananKullan   = -30005;
    Ops_OpsiyonServis_UygulananKullan  = -30006;
    Ops_OpsiyonServis_DetayKullan   = -30007;
    Ops_OpsiyonServis_IadeAlinanKullan   = -30008;
    Ops_OpsiyonServis_TestlerKullan   = -30009;
    Ops_OpsiyonServis_ChNotlarKullan   = -30010;
    Ops_OpsiyonServis_VarsayilanServisTuru   = -30011;
    Ops_OpsiyonServis_VarsayilanServisAktifSekme   = -30012;
    //Döküman Opsiyonlar  32___

    //ÝÇERÝKLER
    //Genel Ýniler 10__
    Ops_AktifPasif = -1001;
    Ops_HaftanýnGünleri = -1003;
    Ops_KURLAR = -1004;
    Ops_KasaTürleri = -1005;
    Ops_DepoVarsayilan = -1006;
    Ops_FiyatListeAdi = -1007;
    Ops_FiyatListeAdiAlis = -1008;
    Ops_DovizEslestir = -1009;
    Ops_Belge_DurumS = -1010;
    Ops_Belge_Türü = -1011;
    Ops_TabloId= -1012;

    // CRM iniler 21__
    Ops_Aktivite_Tipi = -2101;
    Ops_Aktivite_Konum = -2102;
    Ops_Aktivite_Oncelik =-2103;
    Ops_Aktivite_Puan = -2104;
    Ops_Aktivite_Durum = -2105;
    Ops_Aktivite_Türü = -2106;
    Ops_Aktivite_Konu = -2107;

    Ops_Proje_Aplikasyon = -2111;
    Ops_Proje_Türü = -2112;
    Ops_Proje_Aþama = -2113;
    Ops_Proje_Durum = -2114;
    Ops_Proje_Sonuç = -2115;
    Ops_Proje_Tipi = -2116;
    Ops_Proje_Konusu = -2117;

    Ops_Görev_Durum=-2118;

    //Cari Ýniler  22__
    Ops_CariKart_Durum= -2201;
    Ops_CariKart_Grup  = -2202;
    Ops_CariKart_Sýnýf  = -2203;
    Ops_CariKart_Kategori  = -2204;
    Ops_CariKart_Görev = -2205;
    Ops_CariKart_Bölüm = -2206;
    Ops_CariKart_PerIzinTuru = -2208;
    Ops_CariKart_Statü =-2209;

    //Kasa Ýniler 23__
    Ops_Masraf_Türü = -2301;
    Ops_Masraf_Grubu = -2302;
    Ops_Masraf_SozlesmeTipi = -2303;
    Ops_Varsayýlan_Masraf_Gelir_Merkezleri= -2304;
    Ops_GELIRAD = -2305;
    Ops_MASRAFAD= -2306;
    Ops_TahsilatAciklama = -2307;
    Ops_OdemeAciklama = -2308;
    Ops_ExcelMaasEsles = -2309;
    //Alýþ-Satýþ Ýniler 24__
     Ops_FatDetayTur = -2401;
    //Banka Ýniler  25__
     Ops_POS_Türü = -2501;
     Ops_POS_Statüsü = -2502;

     Ops_Talimat_Durum = -2503;
    //Çek-Senet Ýniler  26__
    Ops_Cek_Durum = -2601;
    //Stok Ýniler  27__
    Ops_StokKart_Marka = -2701;
    Ops_StokKart_Anabirim = -2702;
    Ops_StokKart_Tipi = -2703;
    Ops_StokKart_Grubu = -2704 ;
    Ops_StokKart_Ozellik = -2705 ;
    Ops_StokKart_Izleme = -2706;
    Ops_StokKart_ZamanBirimi = -2707;
    Ops_StokKart_Durum = -2708;
    Ops_StokKart_IsOrtagiiliskiTuru = -2709;
    Ops_StokKart_UzunlukBirimi = -2710;
    Ops_StokKart_AlanBirimi = -2711;
    Ops_StokKart_HacimBirimi = -2712;
    Ops_StokKart_AgirlikBirimi = -2713;
    Ops_StokKart_BarkodTipi = -2714;
    Ops_StokKart_SayýmTutanakTipi = -2715;
    Ops_StokKart_Analiz = -2716;

    Ops_KampanyaTürleri = -2780;
    Ops_KampanyaKosulTürleri = -2781;
    Ops_KampanyaSonucTürleri = -2782;
    //Demirbaþ Ýniler 28__
    Ops_Demirbas_Durum = -2801;
    Ops_Demirbas_AlimSekli =-2802;
    Ops_Demirbas_Islem = -2803;
    //Teklif Ýniler  29__
    Ops_Teklif_Türü = -2901;
    Ops_Teklif_Durum = -2902;
    Ops_Teklif_Teslim_Sekli = -2903;
    Ops_Teklif_Odeme = -2904;
    Ops_Teklif_Bilgi = -2905;
    Ops_Teklif_Konusu = -2907;
    //Servis Ýniler 30__
    Ops_Servis_Teslim_Sekli = -3001;
    Ops_Servis_Kabul_Sekli = -3002;
    Ops_Servis_Bildirim_Þekli = -3003;
    Ops_Servis_Bildirim_Yazisi = -3004;
    Ops_Servis_OnaySekli = -3005;
    Ops_Servis_Turu = -3006;
    Ops_Servis_Durum = -3007;
    Ops_Servis_Ucreti = -3008;
    Ops_Servis_Konusu = -3009;
    Ops_ServisDetayGuruplari = -3010;
    Ops_Servis_TeslimAl = -3011;
    Ops_Servis_Sorunlar = -3012;

    //Döküman Ýniler  32__
    Ops_Dokuman_Modul = -3201;
    Ops_Dokuman_Bolumu = -3202;
    Ops_Dokuman_Konusu = -3203;
    Ops_Dokuman_Kategori = -3204;
    Ops_Dokuman_Yonu = -3205;
implementation

end.

unit Notlar;

interface

implementation

end.
(*
*******************************
STATÜLER
Gelen Fatura/Fiþ : Giriþ yapýldý - Ödeme Planlandý - Ödendi
Giden Fatura/Fiþ : Çýkýþ yapýldý - Tahsilat Planlandý - Tahsil edildi
Tahsilat Planý : Bekliyor - Tahsil edildi
Ödeme Planý : Bekliyor - Onaylandý - Ýmzalandý - Ödendi
Çek Senet Tahsilatý : Portföyde - Tahsilata verildi - Tahsil edildi
Çek Senet Ödeme : Bekliyor - Ödendi
Kredi : Bekliyor - Ödendi
*******************************
Takvimde kullanýlan temel Tablolar
PLANLANAN : Planlanan kasa ödemeleri, havale ve EFT ödemeleri veya tahsilatlar
            Planlanan düzenli ödemeler
CEKSENET :  Planlanan çek ve senet ödemeleri veya tahsilatlarý (Vade tarihine göre gösterilir)
PLANKREDI : Planlanan Kredi ödemeleri
PLANMAAS : Planlanan maaþ ödemeleri


*******************************  15/3/2010
Yararlý 2 adet SP yazýldý
 dbo.fn_GT_Tatilmi(Tarih) : Verilen bir tarihin tatil olup olmadýðýný seçeneklerdeki resmi tatil listeye bakarak geri döndürür. Tüm yýllara bakar. C.tesi ve pazarada bakar
 dbo.fn_GT_UygunTarihBul(Tarih, OnceSonra) : Bir tarih ve (1/0/-1) gibi parametreler verildiðinde eðer tatilse önceki/sonraki ilk günü bulur

*******************************  20/3/2010
Bir ekranda yazdýrma yapabilmek için :
Nerden yazdýrma yapýlacak? I-Frameden II-Modal Dialogdan
I-Frameden yazdýrma aþaðýdaki þekilde olacak
(Fare sað tuþ (ayarlar, kopyalama vb iþlemler için UGenelAnaSekmeFrame pmDokumAyarlar kullanýlýr )
      1. Aþaðýdaki gibi  'IAracCubuguDestegi' ekle
      type
        TCariDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IAracCubuguDestegi)
      2. Üstteki eklendiði için alttaki procedurleri de ekle
          function GezinmeAktifMi : Boolean;
          procedure GezinmeBagla(ADBNavigator : TDBNavigator);
          function YazdirmaAktifMi : Boolean;
          procedure YazdirmayaHazirla(AFastReport : TfrxReport);

          Ýlk ikisinin içeriði boþ diðerleri:

      function TCariDlg.YazdirmaAktifMi: Boolean;
      begin
        Result := True;
      end;

      procedure TCariDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
      begin
         AFastReport.EnabledDataSets.Clear;
         AFastReport.EnabledDataSets.Add(frxSQLKomut);
      end;

      3. 'Baský önizleme' menüsüne basýldýðýnda aþaðýdaki satýr bulunmalý
         YazdirmayaHazirla(FastRaporDlg.frxReport1);

      4. Sað tuþ yapýldýðýnda menünün çýkmasý içinse þunlar eklenir
      procedure TCariDlg.Gorunur;
      begin
        YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
        PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
      end;

II-Modal Dialogdan yazdýrma aþaðýdaki þekilde olacak
(Fare sað tuþ (ayarlar, kopyalama vb iþlemler için UFastRap 'deki pmDokumAyarlar kullanýlýr )
      1. Burda da YazdirmayaHazirla vardýr. Ýki þekilde çaðrýlýr:
         a. Baský önizlemede b. Ayarlar içinse YaziciYazMouseDown(...) Event'ine saðrtuþta çalýþacak þekilde
       Bunun örneðini UHavaleEFT ekranýnda bulabilirsiniz.

**************************** 24/3/2010
BANKAHESAPLARI tablosu hem kendi hesaplarýmýzý hem de müþteri hesaplarýný tanýmlamak için kullanýlmýþtýr.
REHBERID=-1 ise firmaya ait hesap aksi halde müþteriye ait hesap olduðunu anlýyoruz.

**************************** 01/04/2010
Açýlýþ Fiþleri için Kasa Ekranýnda TUR=1 kullanýlacak
Açýlýþ Fiþleri günlük kasa ekranýndan silinemeyecek veya deðiþtirilemeyecek
KASALAR, BANKALAR ve REHBER için açýlýþ fiþleri olabilir. KASA ve BANKA için birer tane REHBER içinse her para birimi için bir tane daha olabilir
Açýlýþ fiþinde kasa ve banka için alacak olamaz her zaman borçlu olur.


//2.1 Vers
- Fatbaslýk tablosunda dosyano, gelisno,kartno,carikod   silindi
  *)

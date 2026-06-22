unit Notlar;

interface

implementation

end.
(*
*******************************
STATÜLER
Gelen Fatura/Fiş : Giriş yapıldı - Ödeme Planlandı - Ödendi
Giden Fatura/Fiş : Çıkış yapıldı - Tahsilat Planlandı - Tahsil edildi
Tahsilat Planı : Bekliyor - Tahsil edildi
Ödeme Planı : Bekliyor - Onaylandı - İmzalandı - Ödendi
Çek Senet Tahsilatı : Portföyde - Tahsilata verildi - Tahsil edildi
Çek Senet Ödeme : Bekliyor - Ödendi
Kredi : Bekliyor - Ödendi
*******************************
Takvimde kullanılan temel Tablolar
PLANLANAN : Planlanan kasa ödemeleri, havale ve EFT ödemeleri veya tahsilatlar
            Planlanan düzenli ödemeler
CEKSENET :  Planlanan çek ve senet ödemeleri veya tahsilatları (Vade tarihine göre gösterilir)
PLANKREDI : Planlanan Kredi ödemeleri
PLANMAAS : Planlanan maaş ödemeleri


*******************************  15/3/2010
Yararlı 2 adet SP yazıldı
 dbo.fn_GT_Tatilmi(Tarih) : Verilen bir tarihin tatil olup olmadığını seçeneklerdeki resmi tatil listeye bakarak geri döndürür. Tüm yıllara bakar. C.tesi ve pazarada bakar
 dbo.fn_GT_UygunTarihBul(Tarih, OnceSonra) : Bir tarih ve (1/0/-1) gibi parametreler verildiğinde eğer tatilse önceki/sonraki ilk günü bulur

*******************************  20/3/2010
Bir ekranda yazdırma yapabilmek için :
Nerden yazdırma yapılacak? I-Frameden II-Modal Dialogdan
I-Frameden yazdırma aşağıdaki şekilde olacak
(Fare sağ tuş (ayarlar, kopyalama vb işlemler için UGenelAnaSekmeFrame pmDokumAyarlar kullanılır )
      1. Aşağıdaki gibi  'IAracCubuguDestegi' ekle
      type
        TCariDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IAracCubuguDestegi)
      2. Üstteki eklendiği için alttaki procedurleri de ekle
          function GezinmeAktifMi : Boolean;
          procedure GezinmeBagla(ADBNavigator : TDBNavigator);
          function YazdirmaAktifMi : Boolean;
          procedure YazdirmayaHazirla(AFastReport : TfrxReport);

          İlk ikisinin içeriği boş diğerleri:

      function TCariDlg.YazdirmaAktifMi: Boolean;
      begin
        Result := True;
      end;

      procedure TCariDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
      begin
         AFastReport.EnabledDataSets.Clear;
         AFastReport.EnabledDataSets.Add(frxSQLKomut);
      end;

      3. 'Baskı önizleme' menüsüne basıldığında aşağıdaki satır bulunmalı
         YazdirmayaHazirla(FastRaporDlg.frxReport1);

      4. Sağ tuş yapıldığında menünün çıkması içinse şunlar eklenir
      procedure TCariDlg.Gorunur;
      begin
        YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
        PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
      end;

II-Modal Dialogdan yazdırma aşağıdaki şekilde olacak
(Fare sağ tuş (ayarlar, kopyalama vb işlemler için UFastRap 'deki pmDokumAyarlar kullanılır )
      1. Burda da YazdirmayaHazirla vardır. İki şekilde çağrılır:
         a. Baskı önizlemede b. Ayarlar içinse YaziciYazMouseDown(...) Event'ine sağrtuşta çalışacak şekilde
       Bunun örneğini UHavaleEFT ekranında bulabilirsiniz.

**************************** 24/3/2010
BANKAHESAPLARI tablosu hem kendi hesaplarımızı hem de müşteri hesaplarını tanımlamak için kullanılmıştır.
REHBERID=-1 ise firmaya ait hesap aksi halde müşteriye ait hesap olduğunu anlıyoruz.

**************************** 01/04/2010
Açılış Fişleri için Kasa Ekranında TUR=1 kullanılacak
Açılış Fişleri günlük kasa ekranından silinemeyecek veya değiştirilemeyecek
KASALAR, BANKALAR ve REHBER için açılış fişleri olabilir. KASA ve BANKA için birer tane REHBER içinse her para birimi için bir tane daha olabilir
Açılış fişinde kasa ve banka için alacak olamaz her zaman borçlu olur.


//2.1 Vers
- Fatbaslık tablosunda dosyano, gelisno,kartno,carikod   silindi
  *)

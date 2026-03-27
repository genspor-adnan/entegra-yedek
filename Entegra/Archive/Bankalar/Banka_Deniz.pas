unit Banka_Deniz;

interface

Function Deniz_Dosya_Olustur:string;

implementation

uses SysUtils, Utablo, UHavaleEFT,Fetautil;
{
DenizBank Toplu Ödemeler Denizbank Dosya Deseni:

1.	Başlık Kaydı
Kayıt Tipi			        C1	Default ‘B’
Firma Kodu		          C15	Firmanın bankada tanımlı kodu veya kendi vergi numarası
Dosya Tarihi		        C8	GGAAYYYY

2.	Detay Kaydı
Kayıt Tipi			        C1	Default ‘D’
Banka Kodu		          C4	Havale / EFT’nin çıkış banka kodu
                            Örnek IBAN : TR500013400000123456700001
					                  (IBAN No ile işlem için 1. ve 4. karakterleri arası Ör : TR50)
Şube Kodu			          C5	Havale / EFT’nin çıkış şube kodu
					                  (IBAN No ile işlem için 5. ve 9. karakterleri arası Ör : 00134)
Hesap No			          C18	Havale / EFT’nin çıkış hesap numarası
 					                  (DenizBank Ek no ayırımları “-“ ile olmalı)
					                  (IBAN No ile işlem için 10. ve 26. karakterleri arası Ör: 00000123456700001)
Fark Şube Kodu		      C5	Küsürat için şube kodu (Şube Kodu Alanındaki aynen yazılır)
Ozel Alan		          	C7	7 hane boşluk
Vergi no/ Tc Kimlik No	C11	Alıcı VergiNo veya TCKNo
Karşı Banka Kodu		    C4	Havale / EFT’nin varış banka kodu
					                  Örnek IBAN : TR500013400000123456700001
					                  (IBAN No ile işlem için 1. ve 4. karakterleri arası Ör : TR50)
Karşı Şube Kodu		      C5	Havale / EFT’nin varış şube kodu
					                  (IBAN No ile işlem için 5. ve 9. karakterleri arası Ör : 00134)
Karşı Hesap No		      C18	Havale / EFT’nin varış hesap numarası
                            (Denizbank hesabı ise Ek no ayırımları “-“ ile  olmalı
					                  Ornek : 12345678-351 veya 00564584-352
					                  (IBAN No ile işlem için 10. ve 26. karakterleri arası Ör: 00000123456700001)
Satıcı/Müşteri No		    C10	ERP paketi içindeki Satıcı / Müşteri numarası
Alıcı Adı			          C40	Havale / EFT’yi alanın adı
Adres			              C40	Havale / EFT’yi alanın adresi
Telefon			            C20	Havale / EFT’yi alanın Telefon numarası
Alıcı vergi dairesi adı	C15	Vergi dairesi ad
Baba Adı			          C15	Havale / EFT’yi alanın Baba adı
Açıklama			          C40	Karşı tarafa gidecek açıklama
Referans			          C16	Firma ERP paketindeki işlem referansı
Parametre			          C40	Bankaya işlem için bilgi iletmek amaçlı
Tutar			              C18	nnnnnnnnnnnnnnn,nn (15,2)
Para Birimi		          C5	ISO standardı (TRY)
İşlem Tarihi		        C8	GGAAYYYY
İşlem Kodu		          C2	Sabit “00”
Durum Kodu		          C2	Detaylı biligi sonraki sayfada

3.	Toplam Kaydı
Kayıt Tipi			        C1	Default ‘T’
Toplam Kayıt Sayısı	    C5	Detay kayıt toplamı

Durum Kodları	:
	00		İşlem Yapılmadı
	01		İşlem Yapıldı
	02		Bakiye Yetersiz
	03		Alacak Hesap /IBAN Yok (işlemden önce silindi)
	04		Alacak Hesap / IBAN Bulunamadı
	05		Bakiye Yetersiz (blokeli)
	06		EFT Banka/Şube Kodu Hatalı
	07		Nümerik/Alfabetik Alanda Hatalı Karakter
	08		Borç Hesap Yok (İşlemden Önce Silindi)
	09		Borç Hesap Bulunamadı
	10		Alacak Hesap / IBAN Kapalı
	12		Borçlu Hesap / IBAN Tanımlanmamış
	13		Döviz Kodu Hatalı
	14		Borçlu ve Alacaklı Hesapların / IBAN ların Döviz Kodları Uyumsuz
	15		EFT için Tutar Yuvarlandı
	16		Geçersiz Tarih
  99   Bilinmeyen Hata

Dosya İsmi :
TOD134yyyymmddhhmmss_firma_unvanı.TXT
TOD 	           	Toplu Ödeme Dosyası
134 	           	Denizbank banka kodu
yyyymmdd        	  Dosya Oluşturma Tarihi
hhmmss          	  Dosya Oluşturma saat dakika saniye
_firma_unvanı      Firmanın kısa unvan bilgisi
}


Function Deniz_Dosya_Olustur;
Resourcestring
  secimyapilmadihata = 'Alıcı listesinden en az bir seçim yapınız.' ;
var
  F: Textfile;
  Firma, VDKodu, VNo, BankaKodu, SubeNo, HesapNo, FarkSubeNo, FarkHesapNo, HedefBankaKodu, HedefSubeNo, HedefHesapNo, Musterino, RehID,
  HedefAdi, HedefAdres, HedefTelefon, HedefBaba, HedefVN, HedefVD, Aciklama, HedefReferans, Parametre, Tutar, ParaBirimi, IslemTarihi,
  IslemKodu, DurumKodu ,Referans1: String[40];
  str,Dosya_Adi  : string;
  Say : SmallInt;

begin
   //Aşağıdakiler bizim hesaba ait bilgilerimiz...
   BankaKodu:=HavaleEFTEkrani.TabGonderen.FieldByName('BANKAKODU').AsString;
   HesapNo := HavaleEFTEkrani.TabGonderen.FieldByName('HESAPNO').AsString;
   SubeNo := HavaleEFTEkrani.TabGonderen.FieldByName('SUBEKODU').AsString;
   MusteriNo := HavaleEFTEkrani.TabGonderen.FieldByName('MUSTERINO').AsString;
   Firma := HavaleEFTEkrani.TabAlici.FieldByName('G_FIRMA').AsString;
   //Verileri formata uyumlu hale getirelim,
   BankaKodu := LeadingZero(BankaKodu,4);
   MusteriNo := LeadingZero(MusteriNo,8);
   SubeNo := LeadingZero(SubeNo,5);
   HesapNo := LeadingZero(HesapNo,18); //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalı
   FarkSubeNo := LeadingZero(SubeNo,5);
   FarkHesapNo := LeadingZero(HesapNo,18);

   //Text dosya adı bilgilerimiz
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   Dosya_Adi := 'TOD134'+FormatDateTime('yyyymmddhhnnss', RehberIni.BuguntrhSaat)+Firma+'.txt';
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   AssignFile(F,PAnsiChar('TextDosya\'+Dosya_Adi));
   Rewrite(F);

   VDKodu := HavaleEFTEkrani.TabAlici.FieldByName('G_VDKODU').AsString;
   VNo :=  HavaleEFTEkrani.TabAlici.FieldByName('G_VNO').AsString;

   //Text İçerik; Başlık, bizim bilgilerimiz
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   str := 'B'+LeadingZero(VNo,15)+FormatDateTime('ddmmyyyy', RehberIni.BuguntrhSaat);
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   Writeln(F, str);

   //alıcı hesap bilgileri ve tutarları (birden fazla satır olabilir)
   HavaleEFTEkrani.TabAlici.First;
   Say := 0;
   while not  HavaleEFTEkrani.TabAlici.eof do begin
      if HavaleEFTEkrani.cxGridDBTableView1SEC.EditValue = True then begin

         HedefBankaKodu:= HavaleEFTEkrani.TabAlici.FieldByName('BANKAKODU').AsString;
         HedefHesapNo := HavaleEFTEkrani.TabAlici.FieldByName('HESAPNO').AsString;
         HedefSubeNo := HavaleEFTEkrani.TabAlici.FieldByName('SUBEKODU').AsString;
         HedefVN := HavaleEFTEkrani.TabAlici.FieldByName('VNO').AsString;
         HedefVD := HavaleEFTEkrani.TabAlici.FieldByName('VD').AsString;
         RehID := HavaleEFTEkrani.TabAlici.FieldByName('REHID').AsString;
         HedefAdi := HavaleEFTEkrani.TabAlici.FieldByName('UNVAN').AsString;
         HedefAdres := HavaleEFTEkrani.TabAlici.FieldByName('ADRES').AsString;
         HedefTelefon := HavaleEFTEkrani.TabAlici.FieldByName('ISTEL').AsString;
         HedefBaba := '               ';
         Aciklama := HavaleEFTEkrani.TabAlici.FieldByName('ACIKLAMA').AsString;
         Referans1 := '                ';
         Parametre := '                                        ';
         Tutar := HavaleEFTEkrani.TabAlici.FieldByName('CIKAN').AsString;
         ParaBirimi := '  '+HavaleEFTEkrani.TabAlici.FieldByName('ISOKUR').AsString;
         IslemTarihi := FormatDateTime('ddmmyyyy', RehberIni.BuguntrhSaat);

         HedefBankaKodu := LeadingZero(HedefBankaKodu,4);
         HedefHesapNo := LeadingZero(HedefHesapNo,18);
         HedefSubeNo := LeadingZero(HedefSubeNo,5);
         HedefVN := LeadingZero(HedefVN,11);
         HedefVD := FinishingSpace(HedefVD,15);
         RehID := LeadingZero(RehID,10);
         HedefAdi := FinishingSpace(HedefAdi,40);
         HedefAdres := FinishingSpace(HedefAdres,40);
         HedefTelefon := LeadingZero(HedefTelefon,20);
         Aciklama := FinishingSpace(Aciklama,40);
         Tutar :=  FormatFloat('000000000000000,00',  strtofloat(Tutar));

         //Detay, Gönderi Bilgileri
         //*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
         str := 'D'+Bankakodu+SubeNo+HesapNo+FarkSubeNo+'       '+HedefVN+HedefBankaKodu+HedefSubeNo+HedefHesapNo+RehID+
                HedefAdi+HedefAdres+HedefTelefon+HedefVD+HedefBaba+Aciklama+Referans1+Parametre+Tutar+ParaBirimi+IslemTarihi+'00'+'00' ;
         //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*
         Writeln(F, str);
         inc(Say);
      end;
      HavaleEFTEkrani.TabAlici.next;
   end;

   //son satır toplam bilgilerimiz
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   str := 'T'+LeadingZero(inttostr(Say),5);
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   Writeln(F, str);
   CloseFile(F);

   if say=0 then
   raise exception.Create(secimyapilmadihata);
   result := dosya_adi;
end;
end.

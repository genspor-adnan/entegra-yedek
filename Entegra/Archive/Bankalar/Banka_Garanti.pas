unit Banka_Garanti;

interface

function Garanti_Dosya_Olustur : string;

implementation

uses PrjConst,SysUtils, Utablo, UHavaleEFT;
{
Genel Prensip:

Format içerisinde yer alan “N” (nümerik) alanlarýn yazýlmasýnda uzunluk sayýsýný
yakalayýncaya kadar sol tarafýna “0” (sýfýr) yazmak (Örnek Firma Þubesi: 0383),
“A” (alfanümerik) olan alanlarý ise sola yanaþýk yazarak yazdýktan sonra
uzunluk sayýsýný yakalayýncaya kadar “boþluk” býrakmak gerekmektedir.

Format:
SAHA	        UZUNLUK	    AÇIKLAMA
Sýra No	      10 N	  Kayýt sýra numarasý.
Firma Kodu	  05 N	  Firma Toplu Havale EFT Kodu
Firma Þubesi	04 N	  Firmanýn hesabýnýn þube kodu
Firma Hesabý	07 N	  Firmanýn ödemede kullanacaðý hesap
Banka Kodu	  04 N	  0062 ise iþlem havaledir.
Þube Kodu	    05 N	  Örnek: 00383 Garanti Bankasý Kozyataðý Kurumsal Þubesi
Hesap No	    19 A  	Banka Kodu = *** KONTROL ET ***0062 ise ilk 7 hane dikkate alýnýr.
Ýzahat	      40 A  	Hesap hareketlerinde kullanýlacak.
Ýsim	        30 A  	Alacak hesap sahibinin ismi
Tarih	        08 N  	yyyyAAgg formatýnda, ödeme tarihi
Tutar	        18 N    15.2 formatýnda (Kuruþ kýsmý noktadan sonra iki hane olarak girilmelidir).
Döviz Kodu	  03 A  	Döviz kodu “TL ” olarak (TL + Boþluk karakteri) gönderilmelidir.
Ýþlem Tarihi	08 N  	yyyyAAgg formatýnda, akýbet tarihi
Ýþlem Kodu	 	02 N  	Firmadan 00 gelecek.
Yedek Saha 	 	25 N
Yedek Saha 	 	40 A
IBAN no 	 	  26 A  	Zorunlu saha deðildir.
e-mail 	      50 A  	Zorunlu saha deðildir gelmesi durumunda alýcýya email gönderilir.
TC Kimlik No 	11N	    Zorunlu saha deðildir gelmesi durumunda istenirse kontrol yapýlýr
VKN 	        10N	    Zorunlu saha deðildir gelmesi durumunda istenirse kontrol yapýlýr

ÝÞLEM KODLARI
01 : Tahsil Edildi
02 : Bakiye Yetersiz
03 : Alacak Hesap Yok (Ýþlemden Önce Silindi)
04 : Alacak Hesap Bulunamadý
05 : Bakiye Yetersiz (Blokeli)
06 : EFT Banka/Þube Kodu Hatalý
07 : Nümerik/Alfabetik Alanda Hatalý Karakter
08 : Borç Hesap Yok (Ýþlemden Önce Silindi)
09 : Borç Hesap Bulunamadý
10 : Alacak Hesap Kapalý
11 : Borçlu Hesap Kapalý
12 : Borçlu Hesap Tanýmlanmamýþ
13 : Döviz Kodu Hatalý
14 : Borçlu ve Alacaklý Hesaplarýn Döviz Kodlarý Uyumsuz
28 : Ýptal – Onay Bekliyor. (Onay beklerken iptal edilen kayýt)

0000sýrano+frmno+frþb+frmhesp+bnka+0þube+hesap              +izahat                                 +alýcý ismi                   +yyyyAAgg+000000000000015.20TL bankadan gelicek            ,                 opsiyonel...
0000000001 19769 0387 6399914 0062 00329 6240049             HOSEKOARD ÖDEMESI                       SUKUR LTD STI                 20050101 000000000000070.00TL 00000000 00 0000000000000000000000000                                       TR760006701000000000169935LEYLAK@AMERIKANHASTANESI.COM.TR                              9240033232
0000000002 19769 0387 6399914 0123 00757 1002604             HOSEKOARD ÖDEMESI                       MELTEM AS                     20050101 000000000000050.00TL 00000000 00 0000000000000000000000000                                                                 K.AYKANAT@SUPERONLINE.COM                         231954061121220114115
0000000003 19769 0387 6399914 0111 00908 3233336             HOSEKOARD ÖDEMESI                       YAPRAK TRANSPORT LTD          20050101 000000000000050.00TL 00000000 00 0000000000000000000000000                                       TR820006200018300006299450ORALE@PAKIZETARZILAB.COM                                     4780056268
0000000009 19769 0387 6399914 0010 00908 451908              HOSEKOARD ÖDEMESI                       FERHAN BAYLADI                20050101 000000000000070.00TL 00000000 00 0000000000000000000000000                                       TR980004600250888000015073HIJENYAECZ@HOTMAIL.COM                            362445332025030031863
0000000010 19769 0387 6399914 0064 01069 116              HOSEKOARD ÖDEMESI                       ERKÖK APARTMANI YÖNETICILIGI  20050101 000000000000080.00TL 00000000 00 0000000000000000000000000                                                                                                                   179241458786600229064


000000000105481040066634490062000886623017            DENEME ÖDEMESÝ                          Serdar Köseoðlu               20100712000000000000001.00TL 00000000000000000000000000000000000                                                                 serdar@sonomed.com.tr
000000000119769038763999140062003296240049            HOSEKOARD ÖDEMESI                       SUKUR LTD STI                 20050101000000000000070.00TL 20050101010000000000000000000000000                                       TR760006701000000000169935LEYLAK@AMERIKANHASTANESI.COM.TR                              9240033232
000000000219769038763999140123007571002604            HOSEKOARD ÖDEMESI                       MELTEM AS                     20050101000000000000050.00TL 20050101010000000000000000000000000                                                                 K.AYKANAT@SUPERONLINE.COM                         231954061121220114115
000000000319769038763999140111009083233336            HOSEKOARD ÖDEMESI                       YAPRAK TRANSPORT LTD          20050101000000000000050.00TL 20050101010000000000000000000000000                                       TR820006200018300006299450ORALE@PAKIZETARZILAB.COM                                     4780056268
00000000091976903876399914001000908451908             HOSEKOARD ÖDEMESI                       FERHAN BAYLADI                20050101000000000000070.00TL 20050101010000000000000000000000000                                       TR980004600250888000015073HIJENYAECZ@HOTMAIL.COM                            362445332025030031863
00000000101976903876399914006401069116                HOSEKOARD ÖDEMESI                       ERKÖK APARTMANI YÖNETICILIGI  20050101000000000000080.00TL 20050101010000000000000000000000000                                                                                                                   179241458786600229064
0000000001054010400666344900320008712313              Genotýp.net                             FETA BÝLGÝSAYAR               20100602000000000000001.00TL 00000000000000000000000000000000000                                       TR234879247692384                                                           000000000000000000000
000000000105481040066634490062000886623017            DENEME ÖDEMESÝ                          Serdar Köseoðlu               20100712000000000000001.00TL 20100707090000000000000000000000000                                                                  serdar@sonomed.com.tr                                                  SERDAR KÖSEOÐLU

000000000105481040066634490062000886623017            DENEME ÖDEMESÝ                          Serdar Köseoðlu               20100712000000000000001.00TL 00000000000000000000000000000000000                                                                  serdar@sonomed.com.tr
000000000164740040066634490062000886623017            DENEME ÖDEMESÝ                          Serdar Köseoðlu               20100712000000000000001.00TL 00000000000000000000000000000000000                                                                 serdar@sonomed.com.tr
0000000001000000400382745600120915646541645           dfghd fg h                              Serdar Köseoðlu               20100720000000000000150.00TL 00000000000000000000000000000000000

}
function Garanti_Dosya_Olustur;
//Resourcestring
//  secimyapilmadihata = 'Alýcý listesinden en az bir seçim yapýnýz.' ;
var
  F: Textfile;
  Dosya_Adi,Garantideki_MailAdr, HesapNo, SubeNo, Bankakodu, MusteriNo,
  HedefBankakodu, HedefSubeNo, HedefHesapNo, izahat ,isim, IBan: String;
  str, sirano,Kur ,email,firmano,hedefvergino,hedefkimlikno: string;
  Say : SmallInt;

  Toplam : Real;

begin
   //Aþaðýdakiler bizim hesaba ait bilgilerimiz
   HesapNo := HavaleEFTEkrani.TabGonderen.FieldByName('HESAPNO').AsString;
   SubeNo := HavaleEFTEkrani.TabGonderen.FieldByName('SUBEKODU').AsString;
   Garantideki_MailAdr := Copy(HavaleEFTEkrani.TabGonderen.FieldByName('EPOSTA').AsString,1,10); //ilk 10 karakter gelecek
   MusteriNo := HavaleEFTEkrani.TabGonderen.FieldByName('MUSTERINO').AsString;
   Bankakodu := HavaleEFTEkrani.TabGonderen.FieldByName('BANKAKODU').AsString;
 //dosya adý
   while Length(HesapNo)< 7 do   //hesapno 123 gibiyse 7 karakter olana kadar önüne 0 konmalý
         HesapNo := '0'+HesapNo;

   while Length(SubeNo)< 4 do   //subeno 123 gibiyse 4 karakter olana kadar önüne 0 konmalý
         SubeNo := '0'+SubeNo;

   //txt dosya adý bilgilerimiz
   Dosya_Adi := 'grnt'+FormatDateTime('yyyymmddhhnnss', Tablo.GENINI.BuguntrhSaat)+'G'+HesapNo+SubeNo+'$.txt';
//   AssignFile(F,PAnsiChar('TextDosya\'+Dosya_Adi));
   AssignFile(F,'TextDosya\'+Dosya_Adi);
   Rewrite(F);

   while Length(Bankakodu)< 4 do   //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalý
         Bankakodu := '0'+Bankakodu;

   while Length(MusteriNo)< 8 do   //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalý
         MusteriNo := '0'+MusteriNo;

   //alýcý hesap bilgileri ve tutarlarý (birden fazla satýr olabilir)
   HavaleEFTEkrani.TabAlici.First;
   Say := 0;
   Toplam := 0;
   while not  HavaleEFTEkrani.TabAlici.eof do begin
      if HavaleEFTEkrani.cxGridDBTableView1SEC.EditValue = True then begin
         inc(Say);
         sirano:= FormatFloat('0000000000',  say);
         //Aþaðýdakiler müþteri hesabýnaa ait bilgiler
         HedefBankakodu := HavaleEFTEkrani.TabAlici.FieldByName('BANKAKODU').AsString;
              while Length(HedefBankakodu)< 4 do
              HedefBankakodu := '0'+HedefBankakodu;
         HedefSubeNo := HavaleEFTEkrani.TabAlici.FieldByName('SUBEKODU').AsString;
              while Length(HedefSubeNo)< 5 do
              HedefSubeNo := '0'+HedefSubeNo;
         HedefHesapNo := HavaleEFTEkrani.TabAlici.FieldByName('HESAPNO').AsString;
              while Length(HedefHesapNo)< 19 do
              HedefHesapNo := HedefHesapNo+ ' ';
         firmano :=  HavaleEFTEkrani.TabGonderen.FieldByName('FIRMANO').AsString;
              while Length(firmano)< 5 do
              firmano := '0'+firmano;
         izahat  :=  HavaleEFTEkrani.TabAlici.FieldByName('ACIKLAMA').AsString  ;
              while Length(izahat)< 40 do
              izahat := izahat+ ' ';
         isim:=  HavaleEFTEkrani.TabAlici.FieldByName('UNVAN').AsString  ;
              while Length(isim)< 30 do
              isim := isim+ ' ';
         Kur:=   HavaleEFTEkrani.TabAlici.FieldByName('KUR').AsString  ;
              while Length(Kur)< 3 do
              Kur := Kur+ ' ';
         IBan:=   HavaleEFTEkrani.TabAlici.FieldByName('IBAN').AsString  ;
              while Length(IBan)< 26 do
              IBan := IBan+ ' ';
         email:=   HavaleEFTEkrani.TabAlici.FieldByName('EMAIL').AsString  ;
              while Length(email)< 50 do
              email := email+ ' ';
         hedefvergino := HavaleEFTEkrani.TabAlici.FieldByName('VNO').AsString;
              while Length(hedefvergino)< 10 do
              hedefvergino := hedefvergino+ ' ';
         hedefkimlikno := HavaleEFTEkrani.TabAlici.FieldByName('TCKIMLIKNO').AsString;
              while Length(hedefkimlikno)< 11 do
              hedefkimlikno := hedefkimlikno+ ' ';

         //************************************************
         str := sirano+firmano+subeno+hesapno+HedefBankakodu+HedefSubeNo+HedefHesapNo+izahat+isim+FormatDateTime('yyyymmdd',HavaleEFTEkrani.Tarih)+FormatFloat('000000000000000.00',HavaleEFTEkrani.TabAlici.FieldByName('CIKAN').AsFloat)+Kur+'00000000000000000000000000000000000'+'                                        '+IBan+email+hedefkimlikno+hedefvergino  ;
         //************************************************
         Writeln(F, str);

      end;
      HavaleEFTEkrani.TabAlici.next;
   end;
   CloseFile(F);
   if say=0 then
   raise exception.Create(secimyapilmadihata);
   Result := Dosya_Adi;
end;
end.

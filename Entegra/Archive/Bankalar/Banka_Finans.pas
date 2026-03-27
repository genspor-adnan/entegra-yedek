(*
ALAN ADI	      Baþlangýç	  Tip	  Uzunluk	  Açýklama
KARSIBANKAKODU	    22	    N	    4	      Havale/Eft yapýlacak bankanýn bankacýlýk sistemindeki kodu.  Ýlgili alan “0111” ise ödeme HAVALE olarak iþleme alýnmaktadýr. Deðilse EFT olarak iþleme alýnacaktýr.
KARSISUBEKODU	      27	    N	    5	      Havale/Eft yapýlacak banka þubesinin bankacýlýk sistemindeki kodu.
KARSI IBAN/HESAP NO	32	    A	    26	    Havale/Eft yapýlacak karþý hesabýn IBAN NO veya HESAP NO. Hesap numarasý ile gönderimlerde Beyanname gerekmektedir.
ISLEMTARIHIGUN	    58	    N	    2	      Ýþlemin gerçekleþeceði “gün” bilgisi
ISLEMTARIHIAY	      61	    N	    2	      Ýþlemin gerçekleþeceði “ay” bilgisi
ISLEMTARIHIYIL	    64	    N	    4	      Ýþlemin gerçekleþeceði “yýl” bilgisi
TUTAR	              68	    N	    15    	Havale/Eft yapýlacak tutar bilgisi. Kuruþ sahasý “.” (nokta) ile ayrýlmaktadýr. Örnek; (000000000000.00)
UNVAN	              83	    A	    30	    Ödeme yapýlacak alýcý ünvaný
ACIKLAMA	          113	    A	    75	    Yapýlacak ödeme ile ilgili gitmesi gereken açýklama bilgisi.
ODEME TURU	        188	    N	    2	      "Yapýlacak ödemenin türü:
                                            01: Konut Kirasý Ödemeleri
                                            02: Ýþyeri Kirasý Ödemeleri
                                            03: Diðer Kira Ödemeleri
                                            99: Diðer Ödeme Türleri"
VKN / TCKN	        190	    A	    20	    Karþý hesap sahibinin tüzel kiþi ise VKNsi, gerçek kiþi ise TCKN bilgisi gelir.
V DAIRESI	          210	    A	    50	    Karþý hesap sahibinin varsa Vergi Dairesi bilgisi.
HATA KODU	          260	    N	    2	      Tarafýnýzdan "00" olarka gelmelidir. Ödemenin akibeti Bankamýzca doldurularak gönderilecektir.
SORGU NO	          262	    N	    7	      Tarafýnýzdan "000000" olarak gelmelidir. Ödeme Eft ise, sorgu numarasý Banka tarafýndan doldurularak gönderilecektir.
*)


unit Banka_Finans;

interface

Function Finans_Dosya_Olustur:string;


implementation

uses SysUtils, Utablo, UHavaleEFT,Dialogs;

Function Finans_Dosya_Olustur;
Resourcestring
  secimyapilmadihata = 'Alýcý listesinden en az bir seçim yapýnýz.' ;
  FinansIBANyokuyari = 'Lütfen alýcýlarýn tümünün IBAN numarasýný giriniz, "Finans bank" hesap numarasý ile gönderimlerde Beyanname istemektedir.' ;
var
  F: Textfile;
  Dosya_Adi,Garantideki_MailAdr, HesapNo, SubeNo, Bankakodu, MusteriNo,
  HedefBankakodu, HedefSubeNo, HedefHesapNo, izahat ,isim, IBan, VD,VNo: String;
  str, sirano,Kur ,email,firmano,IBAN_yada_Hesap,TcNo: string;
  Say : SmallInt;

  Toplam : Real;

begin
   //Aþaðýdakiler bizim hesaba ait bilgilerimiz
   HesapNo := HavaleEFTEkrani.TabGonderen.FieldByName('HESAPNO').AsString;
   SubeNo := HavaleEFTEkrani.TabGonderen.FieldByName('SUBEKODU').AsString;
   Garantideki_MailAdr := Copy(HavaleEFTEkrani.TabGonderen.FieldByName('EPOSTA').AsString,1,10); //ilk 10 karakter gelecek
   MusteriNo := HavaleEFTEkrani.TabGonderen.FieldByName('MUSTERINO').AsString;

 //dosya adý
   while Length(HesapNo)< 7 do   //hesapno 123 gibiyse 7 karakter olana kadar önüne 0 konmalý
         HesapNo := '0'+HesapNo;

   while Length(SubeNo)< 4 do   //subeno 123 gibiyse 4 karakter olana kadar önüne 0 konmalý
         SubeNo := '0'+SubeNo;

   //txt dosya adý bilgilerimiz
   Dosya_Adi := 'fnns'+FormatDateTime('mmddhhnnss', RehberIni.BuguntrhSaat)+'G'+HesapNo+SubeNo+Garantideki_MailAdr+'$.txt';
   AssignFile(F,PAnsiChar('TextDosya\'+Dosya_Adi));
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
              while Length(HedefHesapNo)< 26 do
              HedefHesapNo := HedefHesapNo+ ' ';
         firmano :=  HavaleEFTEkrani.TabAlici.FieldByName('REHID').AsString;
              while Length(firmano)< 5 do
              firmano := '0'+firmano;
         izahat  :=  HavaleEFTEkrani.TabAlici.FieldByName('ACIKLAMA').AsString  ;
              while Length(izahat)< 75 do
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
         VNo:=   HavaleEFTEkrani.TabAlici.FieldByName('G_VNO').AsString  ;
              while Length(VNo)< 20 do
              VNo := VNo+ ' ';
         VD:=   HavaleEFTEkrani.TabAlici.FieldByName('G_VD').AsString  ;
         //vergino alaný kimlikno için kullanýlmýþ ise vergi dairesi boþ gelmeli.
              if Length(HavaleEFTEkrani.TabAlici.FieldByName('G_VNO').AsString)=11 then
                 VD:=' ';
              while Length(VD)< 50 do
              VD := VD+ ' ';
         //IBAN yerine Hesapno kullanýmý durumunda uyarý.
         if IBan='00000000000000000000000000' then Begin
            IBan:=HedefHesapNo;
            showmessage(FinansIBANyokuyari);
          End;

         //************************************************
         str := '                     '+HedefBankakodu+' '+HedefSubeNo+IBan+FormatDateTime('dd mm yyyy',HavaleEFTEkrani.Tarih)+FormatFloat('000000000000.00',HavaleEFTEkrani.TabAlici.FieldByName('CIKAN').AsFloat)+isim+izahat+'99'+VNo+VD+'000000000'         ;
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

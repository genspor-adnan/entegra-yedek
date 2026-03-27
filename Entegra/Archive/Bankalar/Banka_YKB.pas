unit Banka_YKB;

interface

Function YKB_Dosya_Olustur:string;

implementation

uses SysUtils, Utablo, UHavaleEFT;
{
BANKO

Ödemeler (EFT –Havale) Serbest Dosya Deseni

	       Gerekli Sahalar:
Saha Adý	Uzunluk
Sabit Deðer	D
Ýþlem Tarihi	8N
Borçlandýrýlacak Hesap No (firmanýn ödemeleri yapacaðý hesap numarasý)	8N
Borçlandýrýlacak Hesap Þube Kodu (firmanýn ödemeleri yapacaðý hesabýn bulunduðu Yapý Kredi Þubesinin kodu)	3N
Ýþlem Para Birimi	3A
Alacaklý Ýsim Unvan	50A
Alacaklý Banka Kodu	4N
Alacaklý Þube Kodu	5N
Alacaklý Hesap No	26A
Tutar*	15 (12.2)
Açýklama	50A
Alacaklý Email Adresi*	50A

* Tutar  - Decimal içerecek ise decimal kýsým “.” ile ayrýlmalý
* Alacaklý Email Alaný zorunlu deðildir. Bu alana yazýlan alacaklý email adresine, iþlem baþarý ile tamamlanmýþ ise bilgilendirme maili gönderilir.

•	Bu sahalarýn dýþýnda istenilen ilave sahalar gönderilebilir, ancak bu sahalar firmaya iþlenmeden akýbetle geri gönderilir.
•	Yapý Kredi havalelerinde vergi no gönderilmesi durumunda Banka sistemindeki vergi no ile tutarlýlýðý kontrol edilir.
•	Açýklama sahasýnda yer alan bilgi hem gönderen hem de alýcý firmanýn hesap hareketlerinde yer alacaðý için her iki firma için de anlam taþýyan bir bilgi olmalýdýr.
Genel kullaným, gönderen firma ABC Yapý Malzemeleri … ve alýcý firma XYZ Endüstri … ise, “ABC Yapý/XYZ Endüstri …” þeklindedir.
}
Function YKB_Dosya_Olustur;
Resourcestring
  secimyapilmadihata = 'Alýcý listesinden en az bir seçim yapýnýz.' ;
var
  F: Textfile;
  Dosya_Adi,Garantideki_MailAdr, HesapNo, SubeNo, Bankakodu, MusteriNo,
  HedefBankakodu, HedefSubeNo, HedefHesapNo, izahat ,isim: String;
  str,Kur ,email: string;
  Say : SmallInt;

  Toplam : Real;

begin
   //Aþaðýdakiler bizim hesaba ait bilgilerimiz
   HesapNo := HavaleEFTEkrani.TabGonderen.FieldByName('HESAPNO').AsString;
   SubeNo := HavaleEFTEkrani.TabGonderen.FieldByName('SUBEKODU').AsString;
   MusteriNo := HavaleEFTEkrani.TabGonderen.FieldByName('MUSTERINO').AsString;

 //dosya adý
   while Length(HesapNo)< 8 do   //hesapno 123 gibiyse 7 karakter olana kadar önüne 0 konmalý
         HesapNo := '0'+HesapNo;

   while Length(SubeNo)< 3 do   //subeno 123 gibiyse 4 karakter olana kadar önüne 0 konmalý
         SubeNo := '0'+SubeNo;

   //txt dosya adý bilgilerimiz
   Dosya_Adi := 'ykb'+FormatDateTime('mmddhhnnss', RehberIni.BuguntrhSaat)+'G'+HesapNo+SubeNo+Garantideki_MailAdr+'$.txt';
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
         izahat  :=  HavaleEFTEkrani.TabAlici.FieldByName('ACIKLAMA').AsString  ;
              while Length(izahat)< 50 do
              izahat := izahat+ ' ';
         isim:=  HavaleEFTEkrani.TabAlici.FieldByName('UNVAN').AsString  ;
              while Length(isim)< 50 do
              isim := isim+ ' ';
         Kur:=   HavaleEFTEkrani.TabAlici.FieldByName('KUR').AsString  ;
              while Length(Kur)< 3 do
              Kur := Kur+ ' ';
         email:=   HavaleEFTEkrani.TabAlici.FieldByName('EMAIL').AsString  ;
              while Length(email)< 50 do
              email := email+ ' ';
         //************************************************
         str := 'D'+FormatDateTime('yyyymmdd',HavaleEFTEkrani.Tarih)+HesapNo+SubeNo+Kur+isim+HedefBankakodu+HedefSubeNo+HedefHesapNo+FormatFloat('000000000000.00',HavaleEFTEkrani.TabAlici.FieldByName('CIKAN').AsFloat)+izahat+email ;
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

unit Banka_HSBC;

interface

Function HSBC_Dosya_Olustur : string;

implementation

uses SysUtils, Utablo, UHavaleEFT,Fetautil;
{
1.	Elektronik Transfer Sistemi İş Akışı

Elektronik Transfer Sistemi (ETS) özellikle belirli günlerde yoğunlaşan ödeme talimatlarının (EFT, havale, virman) elektronik ortamda gerçekleşmesini sağlayan bir Nakit Yönetimi ürünüdür. ETS akışı dört temel adımdan oluşur.

•	Firmanız ile önceden mutabık kalınmış dosya formatında oluşturulan ödeme dosyaları çeşitli veri değişimi yöntemlerinden biri ile Bankamız sistemine aktarılır. Veri değişimi yöntemleri:
o	Şirket Internet Bankacılığı
o	sFTP (File Transfer Protocol)
•	Firmanızın gönderdiği yazılı talimat ile elektronik ortamda gönderilen ödeme kayıtları karşılaştırılır ve onay verilir.
•	İlgili ödemeler gerçekleşir.
•	Ödemelere ilişkin akıbet dosyası firmanıza gönderilir.

2.	ETS Dosya Deseni
*****************************************************
2.1	Başlık Kaydı
Kayıt Tipi					C1	Default ‘B’
Firma Kodu				C15	Firmanın vergi dairesi numarası + Firmanın vergi numarası
Dosya Tarihi				C8	GGAAYYYY
*****************************************************
2.2	Detay Kaydı
Kayıt Tipi					C1	Default ‘D’
Banka Kodu				C4	Havale / EFT’nin çıkış banka kodu
Şube Kodu				C5	Havale / EFT’nin çıkış şube kodu
Hesap No					C26	Havale / EFT’nin çıkış hesap numarası
Fark Şube Kodu				C5	Küsürat için şube kodu
Fark Hesap No				C18	Küsürat için hesap numarası
Karşı Banka Kodu				C4	Havale / EFT’nin varış banka kodu
Karşı Şube Kodu				C5	Havale / EFT’nin varış şube kodu
Karşı Hesap No veya IBAN Kodu		C26	Havale / EFT’nin varış hesap numarası veya IBAN
Satıcı/Müşteri No				C10	Firma Sistemi içindeki Satıcı / Müşteri numarası
Alıcı Adı					C40	Havale / EFT’yi alanın adı
Adres					C40	Havale / EFT’yi alanın adresi
Telefon					C20	Havale / EFT’yi alanın Telefon numarası
Baba Adı					C30	Havale / EFT’yi alanın Baba adı
Açıklama					C40	Karşı tarafa gidecek açıklama
Referans					C16	Firma Muhasebe Sistemi işlem referansı
Parametre					C40	Bankaya işlem için bilgi iletmek amaçlı
Tutar					C18	nnnnnnnnnnnnnnn,nn (15,2)
Para Birimi					C5	ISO standardı (TL  TRL, DM  DEM gibi)
İşlem Tarihi				C8	GGAAYYYY
İşlem Kodu				C2	Detaylı bilgi sonraki sayfada
Durum Kodu				C2	Detaylı biligi sonraki sayfada
*****************************************************
2.3	Toplam Kaydı
Kayıt Tipi					C1	Default ‘T’
Toplam Kayıt Sayısı			C5	Detay kayıt toplamı
*****************************************************
B16253-41100329028092006
D0123008881234567-282-00                                   00460004356345                     0000066794XYZTUY HOTEL (TOYTAŞ A.Ş.)              ULUBATLI HASAN BULVARI NO:5             0258-250 20 20                                    BEŞİKTAŞ V.D. 8590815572 / ÇOKLU ÖDEME  1100060003506611                                        000000000001773,80TRY  280920060000
D0123008881234567-282-00                                   006700538TR5800670053812345678912450000066797ABCDE PLASTİK SAN.VE TİC.LTD.ŞTİ.       SANBİR BULVARI 4.BÖLGE 9.CAD.NO:31      0212-886 17 17                                    BÜYÜKÇEKMECE VD. 0290027215 / 162298    1100060003506612                                        000000000000133,09TRY  280920060000
D0123008881234567-282-00                                   0067005681113346-1                 0000066809AYSAN BORU PROFİL (Z.SELÇUK ÖZSEVİN     MİNARELİ ÇAVUŞ MAH.DÖKÜMCÜLER SİTES     0212-411 10 74                                    ÇEKİRGE V.D. 0890309003 / 002172        1100060003506613                                        000000000017596,53TRY  280920060000
D0123008881234567-282-00                                   012300888TR5200123007010004021282000000066815ERDEM PLASTİK METİN ÖZ                  MİMAR SİNAN CAD.                        0212-375 78 54                                    MASLAK V.D. 0890309003 / 002172         1100060003506614                                        000000000056742,89TRY  280920060000
D0123008881234567-773-01                                   0123008881234999-773-01            0000066815ERDEM PLASTİK METİN ÖZ                  MİMAR SİNAN CAD.                        0212-375 78 54                                    MASLAK V.D. 0890309003 / 002172         1100060003506614                                        000000000059942,89USD  280920060000
T00005
*****************************************************

Ödeme ve akıbet dosyalarında aynı format kullanılmaktadır.

3.	Kod Açıklamaları
3.1	İşlem Kodları:
	00		Ödeme
	01		Tahsilat
	02		Ödeme İptali
	03		Tahsilat İptali

3.2	Durum Kodları:
	00		İşlem Yapılmadı
	01		Tahsil Edildi
	02		Bakiye Yetersiz
	03		Alacak Hesap Yok (işlemden önce silindi)
	04		Alacak Hesap Bulunamadı
	05		Bakiye Yetersiz (blokeli)
	06		EFT Banka/Şube Kodu Hatalı
	07		Nümerik/Alfabetik Alanda Hatalı Karakter
	08		Borç Hesap Yok (İşlemden Önce Silindi)
	09		Borç Hesap Bulunamadı
	10		Alacak Hesap Kapalı
	11		Borçlu Hesap Kapalı
	12		Borçlu Hesap Tanımlanmamış
	13		Döviz Kodu Hatalı
	14		Borçlu ve Alacaklı Hesapların Döviz Kodları Uyumsuz
	15		EFT için Tutar Yuvarlandı
  16		Geçersiz Tarih
  17		Yükleme Yapıldı

}


Function HSBC_Dosya_Olustur;
Resourcestring
  secimyapilmadihata = 'Alıcı listesinden en az bir seçim yapınız.' ;
var
  F: Textfile;
  VDKodu,VNo,BankaKodu,SubeNo,HesapNo,FarkSubeNo,FarkHesapNo,HedefBankaKodu,HedefSubeNo,HedefHesapNo,Musterino,RehID,HedefAdi,HedefAdres,
  HedefTelefon,HedefBaba,Aciklama,HedefReferans,Parametre,Tutar,ParaBirimi,IslemTarihi,IslemKodu,DurumKodu,Referans1 : String[40];
  str,Dosya_Adi  : string;
  Say : SmallInt;

begin
   //Aşağıdakiler bizim hesaba ait bilgilerimiz...
   BankaKodu:=HavaleEFTEkrani.TabGonderen.FieldByName('BANKAKODU').AsString;
   HesapNo := HavaleEFTEkrani.TabGonderen.FieldByName('HESAPNO').AsString;
   SubeNo := HavaleEFTEkrani.TabGonderen.FieldByName('SUBEKODU').AsString;
   MusteriNo := HavaleEFTEkrani.TabGonderen.FieldByName('MUSTERINO').AsString;
   //Verileri formata uyumlu hale getirelim,
   BankaKodu := LeadingZero(BankaKodu,4);
   MusteriNo := LeadingZero(MusteriNo,8);
   SubeNo := LeadingZero(SubeNo,5);
   HesapNo := LeadingZero(HesapNo,26); //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalı
   FarkSubeNo := LeadingZero(SubeNo,5);
   FarkHesapNo := LeadingZero(HesapNo,18);

   //Text dosya adı bilgilerimiz
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   Dosya_Adi := 'HSBC'+FormatDateTime('mmddhhnnss', RehberIni.BuguntrhSaat)+'G'+HesapNo+SubeNo+MusteriNo+'$.txt';
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   AssignFile(F,'TextDosya\'+Dosya_Adi);
   Rewrite(F);

   VDKodu := HavaleEFTEkrani.TabAlici.FieldByName('G_VDKODU').AsString;
   VNo :=  HavaleEFTEkrani.TabAlici.FieldByName('G_VNO').AsString;

   //Text İçerik; Başlık, bizim bilgilerimiz
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   str := 'B'+LeadingZero((VDKodu+VNo),15)+FormatDateTime('ddmmyyyy', RehberIni.BuguntrhSaat);
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
         RehID := HavaleEFTEkrani.TabAlici.FieldByName('REHID').AsString;
         HedefAdi := HavaleEFTEkrani.TabAlici.FieldByName('UNVAN').AsString;
         HedefAdres := HavaleEFTEkrani.TabAlici.FieldByName('ADRES').AsString;
         HedefTelefon := HavaleEFTEkrani.TabAlici.FieldByName('ISTEL').AsString;
         HedefBaba := '                              ';
         Aciklama := HavaleEFTEkrani.TabAlici.FieldByName('ACIKLAMA').AsString;
         Referans1 := '                ';
         Parametre := '                                        ';
         Tutar := HavaleEFTEkrani.TabAlici.FieldByName('CIKAN').AsString;
         ParaBirimi := '  '+HavaleEFTEkrani.TabAlici.FieldByName('ISOKUR').AsString;
         IslemTarihi := FormatDateTime('ddmmyyyy', RehberIni.BuguntrhSaat);

         HedefBankaKodu := LeadingZero(HedefBankaKodu,4);
         HedefHesapNo := LeadingZero(HedefHesapNo,26);
         HedefSubeNo := LeadingZero(HedefSubeNo,5);
         RehID := LeadingZero(RehID,10);
         HedefAdi := FinishingSpace(HedefAdi,40);
         HedefAdres := FinishingSpace(HedefAdres,40);
         HedefTelefon := LeadingZero(HedefTelefon,20);
         Aciklama := FinishingSpace(Aciklama,40);
         Tutar :=  FormatFloat('000000000000000,00',  strtofloat(Tutar));

         //Detay, Gönderi Bilgileri
         //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
         str := 'D'+Bankakodu+SubeNo+HesapNo+SubeNo+HesapNo+FarkSubeNo+FarkHesapNo+HedefBankaKodu+HedefSubeNo+HedefHesapNo+
                RehID+HedefAdi+HedefAdres+HedefTelefon+HedefBaba+Aciklama+Referans1+Parametre+Tutar+ParaBirimi+IslemTarihi+'00'+'00';
         //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
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
   Result := Dosya_Adi;
end;
end.

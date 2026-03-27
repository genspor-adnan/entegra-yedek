unit Banka_Ak;

interface

Function Ak_Dosya_Olustur :string ;

implementation

uses SysUtils, Utablo, UHavaleEFT,Fetautil, Classes;
{
 Toplu Ödeme Sistemi
Ödeme / Ön Akibet / Akibet Dosya Deseni (SAP Standardı)

Başlık Kaydı
Kayıt Tipi	          1   HANE	Default ‘B’
Ürün Referans Kodu	  15  HANE	Firma/Kurumun Toplu Ödemeler Sistemindeki kodu
                          Ürün Referans Kodu    7   HANE  (sola bitişik olarak) + 8 hane boşluk olacaktır.
Dosya Tarihi	        8   HANE  SAYISAL		GGAAYYYY

Detay Kaydı
Kayıt Tipi	      1 HANE        		Default ‘D’
Banka Kodu *	    4 HANE	        	Mevcut format kullanılacaksa ödemenin çıkışının yapılacağı hesabın (borçlanacak hesabın) banka kodu yazılır (Sayısal). Borçlu hesap olarak IBAN formatlı hesap no kullanılacaksa IBAN formatının 1-4 karakterleri arası yazılır (Alfanümerik).
Şube Kodu *	      5 HANE  SAYISAL		Mevcut format kullanılacaksa ödemenin çıkışının yapılacağı hesabın (borçlanacak hesabın) şube kodu yazılır. Borçlu hesap olarak IBAN formatlı hesap no kullanılacaksa IBAN formatının 5-9 karakterleri arası yazılır.
Hesap No *	      7 HANE  SAYISAL		Mevcut format kullanılacaksa ödemenin çıkışının yapılacağı  (borçlanacak) hesap numarası yazılır. Borçlu hesap olarak IBAN formatlı hesap no kullanılacaksa IBAN formatının 10-16 karakterleri arası yazılır. 7 haneden az ise başına 0 konularak 7 haneye tamamlanır.
Özel alan *	      11 HANE		        Mevcut format kullanılacaksa boşlukla doldurulacaktır. Borçlu hesap olarak IBAN formatlı hesap no kullanılacaksa IBAN formatının 17-26 karakterleri arası bu alana sola dayalı olarak yazılır.
Fark Şube Kodu	  5 HANE  SAYISAL		Küsürat için şube kodu ( 00000 girilebilir.)
Fark Hesap No	    7 HANE  SAYISAL		Küsürat için hesap numarası ( 00000000 girilebilir.)
Alıcı Vergi No	  10 HANE SAYISAL		Alıcı Vergi  Kimlik Numarası  Borç Dekontu üzerinde çıkacak bilgidir.
                                    TCKN bilgisi yazmak için sonraki alandaki boşluk alanı kullanılarak 11 hane TCKN değeri yazılabilir.
                                    VKN&TCKN kontrolü yapılması istendiği durumlarda;
	                                  Bu sahada gelen bilgi hesap üzerindeki bilgi ile karşılaştırılacaktır.
	                                  Boş bırakılırsa kontrol yapılmaz.
Boşluk	          1 HANE 		        Boşluk ile doldurulacaktır. (TCKN yazılacağı zaman TCKN nin son hanesi bu alana yazılır)
Karşı Banka Kodu 	4 HANE        		Mevcut uygulamada Havale / EFT’nin alacaklı banka kodu yazılır (Sayısal). Alacaklı hesap olarak IBAN formatlı hesap no kullanılacaksa IBAN formatının 1-4 karakterleri arası yazılır (Alfanümerik). Örnek olarak IBAN TR930004600192888000263182 ise bu alana TR93 yazılmalıdır.

Karşı Şube Kodu *	5 HANE SAYISAL		Mevcut uygulamada Havale / EFT’nin alacaklı şube kodu yazılır. Alacaklı hesap olarak IBAN formatlı hesap no kullanılacaksa IBAN formatının 5-9 karakterleri arası yazılır. Örnek olarak IBAN TR930004600192888000263182 ise bu alana 00046 yazılmalıdır.

Karşı Hesap No *	18 HANE	        	Mevcut uygulamada Havale / EFT’nin alacaklı hesap numarası yazılır. Alacaklı hesap olarak IBAN formatlı hesap no kullanılacaksa IBAN formatının 10-26 karakterleri arası bu alana sola dayalı olarak yazılır. Örnek olarak IBAN TR930004600192888000263182 ise bu alana 00192888000263182 yazılmalıdır.

Satıcı/Müşteri No	10 HANE 		      Firma sistemindeki Satıcı / Müşteri numarası
Alıcı Adı	        40 HANE	        	Havale / EFT’yi alanın adı
Adres	            40 HANE		        Havale / EFT’yi alanın adresi
Telefon	          20 HANE		        Havale / EFT’yi alanın Telefon numarası
Alıcı VD	        15 HANE 		      Borç Dekontu üzerinde çıkacak bilgidir.
Baba Adı	        15 HANE		        Havale / EFT’yi alanın Baba adı
Açıklama	        40 HANE		        Karşı tarafa gidecek açıklama
Referans	        16 HANE		        Firma işlem referansı
Parametre	        40 HANE		        Bankaya işlem için bilgi iletmek amaçlı
Tutar	            18 HANE	        	NNNNNNNNNNNNNNN,NN (15,2)
Para Birimi	      5 HANE	        	ISO standardı (TL  TRY, gibi )
İşlem Tarihi	    8 HANE SAYISAL		GGAAYYYY
İşlem Kodu	      2 HANE SAYISAL		01 : Konut Kirası,
                                    02 : İşyeri Kirası
                                    03 : Diğer Kiralar
                                    99 : Diğer ödemeler
                                    Bu değerlerin dışında bir değerin, dosyada gönderilmesi halinde, ödeme türü 99 olarak değerlendirilerek sisteme yüklenecektir.
Durum Kodu	2 HANE SAYISAL	      	Detaylı bilgi sonraki sayfada
Alacaklı IBAN 	26 HANE		          Alacaklının IBAN no bilgisidir. (Havaleler için) – Ödeme Dosyasında olmayacak, ön akıbet ve akıbet dosyalarına eklenmiştir.

Toplam Kaydı
Kayıt Tipi	        1 HANE	        	Default ‘T’
Toplam Sayı       	5 HANE  SAYISAL		Detay kayıt toplamı

Uyarı :
İşaretli olan sahalar zorunlu sahalar olup, mutlaka formata uygun özellikte bilgi ile doldurulmalıdır.

* : Borçlu ve Alacaklı hesaplarda IBAN formatının kullanılması durumunda açıklamaya ve aşağıdaki örneğe dikkat edilmelidir.

Borçlu Hesap
IBAN hesap no TR930004600192888000263182 ise,
Banka Kodu : TR93
Şube Kodu : 00046
Hesap No : 0019288
Özel Alan : “8000263182 ”

Alacaklı Hesap
IBAN hesap no TR930004600192888000263182 ise,
Karşı Banka Kodu : TR93
Karşı Şube Kodu : 00046
Karşı Hesap No : “00192888000263182 ”


•	Gelen ve giden dosya formatları aynıdır.
•	EFT ödemelerindeki küsurat rakamları küsurat hesabına aktarılır.
•	Bir dosyada ödeme hesabı tek olmalıdır.
•	Bir dosyada  fark hesabı tek olmalıdır.

DURUM KODLARI

AkibetRef	AkibetAd
0	Doğru Bilgi
1	Ödeme Gerçekleşti
2	Bakiye Yetersiz
3	Alacak Hesap Yok (işlemden önce silindi)
4	Alacak Hesap Bulunamadı
5	Bakiye Yetersiz (blokeli)
6	EFT Banka/Şube Kodu Hatalı
7	Nümerik/Alfabetik Alanda Hatalı Karakter
8	Borç Hesap Yok (İşlemden Önce Silindi)
9	Borç Hesap Bulunamadı
10	Alacak Hesap Kapalı
11	Borçlu Hesap Kapalı
12	Borçlu Hesap Tanımlanmamış
13	Döviz Kodu Hatalı
14	Borçlu ve Alacaklı Hesapların Döviz Kodları Uyumsuz
15	EFT için Tutar Yuvarlandı
16	Geçersiz Tarih
17	Fr-Isl erisim hatasi
18	Basliksiz detay var
19	Transfer-Sys-Error
20	Ayni dosyadan var
21	HDR dizi erisim hatası
22	Ayni detay var
23	DTY dizi erisim hata
24	Kayit tipi hatali
25	Sifir meblagli kayit
31	Rehinli hesap
35	IBAN Kontrol digit-borç hesap hatalı
36	IBAN Kontrol digit-alacaklı hesap hatalı
37	Provizyon yapilamaz
38	Havale yapilamaz
40	Hesap bulunamadı
41	Hesap kapalı
42	Alacaklı Hesap No girilmeli
43	Yasal tedbir
44	Vdl.Hes.Isl.yapilamaz
45	Müsteri dizisi hata
46	Hareket dizisi hata
47	Şube dizisi hata
48	Karşı Banka bulunamadı
49	Karşı Şube bulunamadı
51	İşlem Tarihi Sayısal değil
52	Bakiye yetersiz
55	Dosya iptal edilmis
57	Limit Altı Tutar
58	Limit Üstü Tutar
60	Yasal tedbir var
61	Borçlu Banka Sayısal değil
63	Borçlu Şube Sayısal değil
65	Borçlu Hesap Sayısal değil
66	Dosya islenemedi
67	Fark Şube Sayısal değil
68	Fark Hesap Sayısal değil
69	Ödeme Yasağı var
70	Alacakli Banka Sayisal degil
71	Alacakli Şube Sayisal degil
72	Alacaklı Hesap Hatalı
73	Detay Meblağ Sayısal değil
74	Firma Hesabı uyumsuz
75	Firma Fark Hesabı uyumsuz
76	Ödeme Yasağı var
77	FHGS. de tanimsiz
78	FHGS. ile uyumsuz
79	FHGS. ref. Hatali
82	Ödeme tarihi geçmiş tarihli
83	İşlem Tarihi Tatil Günü olamaz
84	Ödeme Tarihi Aynı gün olmalıdır
86	İşlem Seans süresini aşmış
88	Kısmi tahs. Yapıldı
93	Ödenmiş
94	Onaylanacak Bordro
95	Hatali detayı var
96	Detaysız dosya
97	Yükleme yapılıyor
98	İşlenecek kayıt yok
99	Dosya işleniyor

DOSYA İSİMLENDİRME ŞEKLİ

Firma, tüm dosya tipleri (Ödeme, Ön Akıbet, Akıbet, Hesap Dosyaları) için isimlendirme şeklini belirlemelidir.

   Akbank/SAP Standardı

Akbank/SAP Ödeme Dosyası İsimlendirme standardı aşağıda sunulmuştur. (Akbank Ödeme Dosyası İsimlendirme Standartı, SAP Standart yapısındadır.) Diğer Dosya Tipleri için de Akbank Standart yapısı aşağıda belirtilmiştir.

Ödeme Dosyası:

Odbbbburfyyyyaaggssdd   : Dosya adı
OD            : Ödeme
Bbbb         : Banka Kodu
URF          : Ürün Referans Kodu
Yyyyaagg  : Tarih
Ssdd         : Saat-dakika

Ön Akıbet:

TOOURFGGAAYYSSDD : Dosya Adı
TOO          : Ön Akıbet
URF          : Ürün Referans Kodu
GGAAYY    : Tarih
SSDD        : Saat-dakika

Akıbet:

TOAURFGGAAYYSSDD : Dosya Adı
TOA          : Ön Akıbet
URF          : Ürün Referans Kodu
GGAAYY    : Tarih
SSDD        : Saat-dakika
}

Function Ak_Dosya_Olustur :string ;
Resourcestring
  secimyapilmadihata = 'Alıcı listesinden en az bir seçim yapınız.' ;
var
  F: Textfile;
  VDKodu,VNo,BankaKodu,SubeNo,HesapNo,FarkSubeNo,FarkHesapNo,HedefBankaKodu,HedefSubeNo,HedefHesapNo,Musterino,RehID,HedefAdi,HedefAdres,
  HedefTelefon,HedefBaba,Aciklama,HedefReferans,Parametre,Tutar,ParaBirimi,IslemTarihi,IslemKodu,DurumKodu,HedefVNo,HedefVD,Referans1 : String[40];
  str,Dosya_Adi  : string;
  Say : SmallInt;
  A : TStringStream;

begin
   //Aşağıdakiler bizim hesaba ait bilgilerimiz...
   BankaKodu:=HavaleEFTEkrani.TabGonderen.FieldByName('BANKAKODU').AsString;
   HesapNo := HavaleEFTEkrani.TabGonderen.FieldByName('HESAPNO').AsString;
   SubeNo := HavaleEFTEkrani.TabGonderen.FieldByName('SUBEKODU').AsString;
   MusteriNo := HavaleEFTEkrani.TabGonderen.FieldByName('MUSTERINO').AsString;
   //Verileri formata uyumlu hale getirelim,
   BankaKodu := LeadingZero(BankaKodu,4);
   MusteriNo := LeadingZero(MusteriNo,7);
   SubeNo := LeadingZero(SubeNo,5);
   HesapNo := LeadingZero(HesapNo,26); //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalı
   FarkSubeNo := LeadingZero(SubeNo,5);
   FarkHesapNo := LeadingZero(HesapNo,18);

   //Text dosya adı bilgilerimiz
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   Dosya_Adi := 'AKBANK'+FormatDateTime('mmddhhnnss', RehberIni.BuguntrhSaat)+'G'+HesapNo+SubeNo+MusteriNo+'$.txt';
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   AssignFile(F,PAnsiChar('TextDosya\'+Dosya_Adi));
   Rewrite(F);

   VDKodu := HavaleEFTEkrani.TabAlici.FieldByName('G_VDKODU').AsString;
   VNo :=  HavaleEFTEkrani.TabAlici.FieldByName('G_VNO').AsString;


   //Text İçerik; Başlık, bizim bilgilerimiz
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
   str := 'B'+MusteriNo+'        '+FormatDateTime('ddmmyyyy', RehberIni.BuguntrhSaat);
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
         HedefBaba := '               ';
         Aciklama := HavaleEFTEkrani.TabAlici.FieldByName('ACIKLAMA').AsString;
         Referans1 := '                ';
         Parametre := '                                        ';
         Tutar := HavaleEFTEkrani.TabAlici.FieldByName('CIKAN').AsString;
         ParaBirimi := '  '+HavaleEFTEkrani.TabAlici.FieldByName('ISOKUR').AsString;
         IslemTarihi := FormatDateTime('ddmmyyyy', RehberIni.BuguntrhSaat);
         HedefVNo := HavaleEFTEkrani.TabAlici.FieldByName('VNO').AsString;
         HedefVD := HavaleEFTEkrani.TabAlici.FieldByName('VD').AsString;

         HedefBankaKodu := LeadingZero(HedefBankaKodu,4);
         HedefHesapNo := FinishingSpace(HedefHesapNo,18);
         HedefSubeNo := LeadingZero(HedefSubeNo,5);
         RehID := FinishingSpace(RehID,10);
         HedefAdi := FinishingSpace(HedefAdi,40);
         HedefAdres := FinishingSpace(HedefAdres,40);
         HedefTelefon := LeadingZero(HedefTelefon,20);
         Aciklama := FinishingSpace(Aciklama,40);
         Tutar :=  FormatFloat('000000000000000,00',  strtofloat(Tutar));
         if Length(HedefVNo)<11 then
            HedefVNo:=FinishingSpace(HedefVNo,10)+' ';
         HedefVD := FinishingSpace(HedefVD,15);


         //Detay, Gönderi Bilgileri
   //*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*/*\*
         str := 'D'+Bankakodu+SubeNo+HesapNo+'           '+FarkSubeNo+FarkHesapNo+HedefVNo+HedefBankaKodu+HedefSubeNo+HedefHesapNo+
                RehID+HedefAdi+HedefAdres+HedefTelefon+HedefVD+HedefBaba+Aciklama+Referans1+Parametre+Tutar+ParaBirimi+IslemTarihi+'00'+'00';
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
   Result:=Dosya_Adi;
   if say=0 then
   raise exception.Create(secimyapilmadihata);
end;
end.

// ************************************************************************ //
// Ýþ       : Ýts WebServislerinin Kullanýmý
// Baþlangýc Tarihi :Ýsmail ACET 07-10-2011
// Encoding : UTF-8
// Codegen  : SOAP
// Version  : 1.1
// Ecza Depolarý ve Hastaneler için uygulama geliþtirenler testler için
// aþaðýdaki GLN numaralarýný kullanabilirler
// Firma GLN Numalaralarý : 8680002800017, 8680016600016
// Depo GLN Numaralarý    : 8680007800012, 8680007900019
// Hastane GLN Numaralarý : 8680024500018, 8680018600014
// Eczane GLN Numaralarý  : 8680001000001, 8680001000002
//
// ************************************************************************ //
unit UitsBusiness;
{}
interface

Uses   SysUtils,SOAPHTTPClient,WinInet,SOAPHTTPTrans,Classes,
Utablo,XSBuiltIns,Dialogs,ECXMLParser,UItsAraclari,Generics.Collections,PTSPackageSenderWebService
,PTSPackageReceiverWebService,Types,ADODB,Db;

type
  UCType = Record
    Code: string[20];
    Msg: string;
  End;
    type
    TITSHesapAyarlari = record
     HesapId : integer;
     GonderenAdi : string;
     KullaniciAdi : string;
     Parola : string;
     Sunucu : string;
  end;

{$REGION 'Sabitler'}
const EzcaDepoDogrulamaBildirimiEnpointDemo  = 'http://212.174.130.240/DepoDogrulama/DepoDogrulamaReceiverService';
const EzcaDepoMalAlimBildirimiEnpointDemo    = 'http://212.174.130.240/DepoMalAlim/DepoMalAlimReceiverService';
const EzcaDepoMaliadeBildirimiEnpointDemo    = 'http://212.174.130.240/DepoMalIade/DepoMalIadeReceiverService';
const EzcaDepoSatisBildirimiEnpointDemo      = 'http://212.174.130.240/DepoSatis/DepoSatisReceiverService';
const EzcaDepoSatisiptalBildirimiEnpointDemo = 'http://212.174.130.240/DepoSatisIptal/DepoSatisIptalReceiverService';
const DeAktivasyonBildirimiEnpointDemo ='http://212.174.130.240/DeaktivasyonBildirim/DeaktivasyonBildirimReceiverService';

const {<DT>} EzcaDepoBildirimTipi = 'V';//Bu alan tek karakterlik veri içerir. Ýçerdiði deðer “V” (Doðrulama) olacaktýr. Bu alan bu mesajýn Doðrulama bildirimi olduðunu belirler.
const {<DT>} EzcaDepoMalAlimBildirimTip = 'A'; //Bu alan tek karakterlik veri içerir. Ýçerdiði deðer “A” (Alým) olacaktýr. Bu alan bu mesajýn Mal Alým Bildirimi olduðunu belirler.
const {<DT>} EzcaDepoMalIadeBildirimTipi = 'F'; //Bu alan tek karakterlik veri içerir. Ýçerdiði deðer “F” (Ýade) olacaktýr. Bu alan bu mesajýn Mal Alým Bildirimi olduðunu belirler.
const {<DT>} EzcaDepoSatisBildirimTipi = 'S';//Bu alan tek karakterlik veri içerir. Ýçerdiði deðer “S” (Satýþ) olacaktýr. Bu alan bu mesajýn Satýþ Bildirimi olduðunu belirler.
const {<DT>} EzcaDepoSatisIptalBildirimTipi = 'C';//Bu alan tek karakterlik veri içerir. Ýçerdiði deðer “C” (Satýþ Ýptal) olacaktýr. Bu alan bu mesajýn Satýþ Ýptal Bildirimi olduðunu belirler.
const {<DT>} DeAktivasyonBildirimTipi = 'D';//Bu alan tek karakterlik veri içerir. Ýçerdiði deðer D (Deaktivasyon) olacaktýr. Bu alan bu mesajýn Deaktivasyon bildirimi olduðunu belirler.

const FirmaGLNDeneme   = '8680002800017';
const DepoGLNDeneme    = '8680007800012';
const HastaneGLNDeneme = '8680024500018';
const EczaneGLNDeneme  = '8680001000001';

const DEAKTIVASYONSISTEMDENCIKARMA = '10' ;//   DeAktivasyon (<DS>) Sistemden Çýkarma
const DEAKTIVASYONFIRE             = '20' ;//   DeAktivasyon (<DS>) Üretim Fireleri
const DEAKTIVASYONGERICEKME        = '30' ;//   DeAktivasyon (<DS>) Geri Çekme Sebebiyle Ýmha
const DEAKTIVASYONMIAT             = '40' ;//   DeAktivasyon (<DS>) Miat Sebebiyle Ýmha
const DEAKTIVASYONREVIZYON         = '50' ;//   DeAktivasyon (<DS>) Revizyon
const DEAKTIVASYONSARF             = '60' ;//   DeAktivasyon (<DS>) Sarf

const
  Errors : array[1..24] of UCType = (
( Code:'11032';Msg:'Sýra Numarasý Formatý Geçersiz'),
( Code:'11035';Msg:'Ürüne Ait Son Kullaným Tarihi (XD) Formatý Uyumsuz'),
( Code:'10036';Msg:'Ürüne Ait Parti Numarasý (BN) Formatý Uyumsuz'),
( Code:'11037';Msg:'Ürüne ait GTIN numarasý Formatý Uyumsuz'),
( Code:'10007';Msg:'Bu Sýra Numarasý Zaten Kayýtlý!'),
( Code:'10008';Msg:'Tanýmlanmamýs Kayýt Hatasý.'),
( Code:'10201';Msg:'Belirtilen Ürün Sistemimizde Kayýtlý Deðildir.'),
( Code:'10202';Msg:'Ürünün Son Kullanma Tarihi Geçmistir. (Hastaya verilemez.)'),
( Code:'10203';Msg:'Ürün Bilgileri Tutarsýz.'),
( Code:'10204';Msg:'Belirtilen Ürün Önceden Satýlmýstýr.'),
( Code:'10205';Msg:'Bu Ürünün Satýsý Yasaklanmýstýr.'),
( Code:'10206';Msg:'Veritabaný Kayýt Hatasý.'),
( Code:'10207';Msg:'Bu Ürün Önceden ihraç Edilmistir.'),
( Code:'10209';Msg:'Ürün Su Anda Baska Bir Eczane Stokunda Görünüyor.'),
( Code:'10210';Msg:'Ürün Stokunuzda Görünüyor.'),
( Code:'10211';Msg:'Ürün Stokunuzda Görünmüyor!'),
( Code:'10219';Msg:'Belirtilen Ürün Tarafýnýzdan Satýlmamýstýr'),
( Code:'10220';Msg:'Ürün Geri Ödeme Kurumuna Satýlmýstýr. Satýsýn Reçete Bazlý iptal Edilmesi Gerekir'),
( Code:'10221';Msg:'Ürünün Satýsý iptal Edilemez.'),
( Code:'10222';Msg:'Ürün Üzerinize Kayýtlý Deðil'),
( Code:'10223';Msg:'Ürün Üzerinize Kayýtlý Görünüyor'),
( Code:'10224';Msg:'Ürün Eczane Tarafýndan Satýlmýstýr.'),
( Code:'10305';Msg:'Belirtilen ürün baþka bir paydaþ üzerine kayýtlýdýr.'),
( Code:'00000';Msg:'Doðru Bildirim.'));



const DurumDogru    ='00000';
const AlimDurumUzerinde ='10223';
const SatimDurumOnceden ='10204';


Const MALALIM 		  = 'P' ; //Mal Alim (Purchase) -->
Const SATIS 		    = 'S' ; //Satis (Sale) -->
Const SATISIPTAL 	  = 'C' ; //Cancel Sale (Cancel) -->
Const IADE 			    = 'R' ; //Iade (Return) -->
Const DEAKTIVASYON	= 'D' ; //Deaktivasyon (Deactivation) -->
Const URETIM 		    = 'M' ; //Uretim (Manufacture) -->
Const ITHALAT 		  = 'I' ; //Ithalat (Import) -->
Const IHRAC 		    = 'X' ; //Ihrac (eXport) -->
Const SARF 			    = 'O' ; //Sarf (cOnsume) -->
Const BILGI 		    = 'N' ; //Bilgi (iNformation) -->
Const DEVIR 		    = 'T' ; //Devir (Transfer) -->
Const DEVIRIPTAL 	  = 'L' ; //Devir Iptal (canceL Transfer) -->
Const AKTARIM 		  = 'F' ; //Aktarim (non-its transFer) -->
Const AKTARIMIPTAL	= 'K' ; //Aktarim Iptal (non-its cancel transfer) --


//ITS_BILDIRIM Tablosu için kullanýlacak
//YERI : 1 - Üretim 2 - Paket 3 - Satýþ 4 - Satýnalma 5 -Deaktivasyon
//DURUM : 1 - Yeni 2 - Gönderimde 3 - Hata 9 - Tamamlandý

// Paket bildirim için taþýma tipler 'P': Palet, 'C': Koli, 'S': Bað, 'B': Koli içi
//kutu, 'E': Küçük baðý


{$ENDREGION}
{$REGION 'Ortak Tipler' Açýklama amaçlý yapýlmýþtýr kullanýmý yoktur }

Type ItsBelgeFetaType = record
  DD : TXSDate ; //Belge Tarihi ;
  DN : string  ; //Belge Açýklamasý;
end;
Type ItsUrunFetaType = record
  GTIN :  string; //Bildirilen ürüne ait (Global Trade Item Number) Küresel Ticari Ürün Numarasý veya “barkod numarasý”dýr
  XD   : TXSDate;   { Bildirilen Ürünün Son Kullanma Tarihi bu alanda bulunur. XML-Date tipindedir.
  Son Kullaným Tarihi Bildirimin yapýldýðý tarihten önceki bir tarih olamaz. }
  BN   :  string[20]; {Ürünün Parti Numarasýný içerir. En fazla 20 Karakter uzunluðundadýr.
  Karekoda basýlan parti numarasý ile ayný olmak zorundadýr.
  ‘0’ ve Boþluk gibi doldurma karakterleri eklenmeyecektir.  }
  SN   :  string[20]; { Bildirime konu ürününün Sýra Numarasý bu alan ile bildirilir.
  En fazla 20 karakter uzunluktadýr. Ürünün karekodundaki sýra numarasý ile birebir ayný olmalýdýr.
  Doldurma karakterleri içermemelidir.}
end;
Type ItsUrunCevapFetatype = record
  URUNDURUM : string ;//Ürünlere ait bilgileri ve sistem tarafýndan iþlendikten sonra verilen uyarý kodunu geri döndürür.
  GTIN :  string; //Bildirilen ürüne ait (Global Trade Item Number) Küresel Ticari Ürün Numarasý veya “barkod numarasý”dýr
  SN   :  string[20]; { Bildirime konu ürününün Sýra Numarasý bu alan ile bildirilir.
  En fazla 20 karakter uzunluktadýr. Ürünün karekodundaki sýra numarasý ile birebir ayný olmalýdýr.
  Doldurma karakterleri içermemelidir.}
  UC   :  string[5];  //Bu alan Ürünün tekil bilgileri kaydedildikten sonra dönen uyarý kodunu barýndýrýr.
  {Beþ karakter uzunluktadýr. Bu Uyarý Kodlarý Sistem tarafýndan duyurulmaktadýr.
  Test süreçleri sonunda yapýlacak deðerlendirmeler sonrasýnda bu uyarý kodlarý deðiþebilir.
  Bu yüzden uygulama geliþtiricilerin uyarý kodlarýný iþleyen mekanizmayý parametrik olacak þekilde geliþtirmeleri önerilir.}
  HataKodu   : string;
  HataBaslik : string;

end;
Type ItsCevapFetaType = record
 BILDIRIMID : string[20];{Sisteme baþarýlý olarak ulaþmýþ her bildirime sistem tarafýndan atanan tekil bir numaradýr.
 Ýstemcilerin verilen bu numarayý kendi sistemlerine kaydetmeleri önerilir.
 Þema tarafýndan kýsýtlanmamýþ bu alan için 20 karakterlik bir alfanümerik alan ayýrmalarý gerekmektedir.}
 URUNLER : array of ItsUrunCevapFetatype;
end;
type BildirimHataType = record
  FC : string;
  FM : string;
end;
Type ItsUrunlerFetatype = record
   Urunler : array of  ItsUrunFetaType;
end;

{$ENDREGION}
function HataToMsg(Kod : string):string;
{$REGION 'ECZA DEPOLARI TARAFINDAN KULLANILACAK WEB SERVÝSLERÝ.........'}
{$REGION 'Hakkýnda'}
{Ecza Depolarý Tarafýndan Kullanýlacak Web Servisleri
Her ne kadar Ecza Depolarýnýn sisteme giriþleri ertelenmiþ olsa da isteyen ecza depolarýnýn
sisteme dâhil olabilmelerini saðlamak için gerekli web servisleri hazýrlanmýþtýr. Ecza depolarýnýn
kullanabilecekleri web servisleri þunlardýr:
• Depo Ürün Doðrulama
• Depo Mal Alým Bildirimi
• Depo Mal Ýade Bildirimi
• Depo Satýþ Bildirimi
• Depo Satýþ Ýptal Bildirimi
• Deaktivasyon Bildirimi
• Ýhracat Bildirimi
Ýlk aþamada Bu servislerden Ürün Doðrulama, Deaktivasyon, ve Ýhracat Bildirimi Depolar için önemlidir.
 Eczanelere yapacaklarý satýþlarda sorun yaþamamalarý için Üreticilerden almýþ olduklarý ürünlerin sistemde
 kayýtlý olup olmadýðýný, eczane tarafýndan iade edilen ürünlerin ise satýlabilir durumda olup olmadýðýný kontrol
 etmeleri için “Ürün Doðrulama” servisini kullanmak zorundadýrlar. Ayný zamanda çalýnan, bozulan ürünleri sistemden
 çýkarmak için Deaktivasyon bildirimine, ihracat yapýyorlarsa da Ýhracat bildirimine ihtiyaç duyacaklardýr.
Diðer bildirimler ise ileride zorunlu hale getirileceðinden þimdiden gerekli hazýrlýklarý yapmalarý gerekmektedir.
Alým, Ýade, Satýþ ve Satýþ Ýptal bildirimleri birbirleri ile alakalý bildirimlerdir. Bu yüzden herhangi birini kullanmak istediklerinde
diðerlerini de kullanmak zorundadýrlar.
Not: Üreticilerden alýnan ürünler yüksek miktarda olduðu için ürünlerin tek tek okutulmasý zor
olacaðý düþünülmektedir. Bu yüzden koli barkodlarý devreye girene kadar üreticiler ve depolar
arasýnda sevkiyat sýrasýnda kullanýlmak üzere standart bir veri iletim formatý üzerinde çalýþýlmaktadýr.
Deponun kendisine gelecek standart formattaki belge içerisindeki karekodlarý kontrol ederek
sisteme bildirebileceði bir yapý tasarlanmalýdýr. Bu belgenin ayný zamanda diðer depo, hastane
ve eczanelere yapýlacak sevkiyatlarda da düzenlenmesiyle alýcýnýn iþlemini kolaylaþtýracaktýr.}
{$ENDREGION}
  function XMLGonder(AIstek : TSoapIstek):TGenelYanit;

  function XMLGonderV12(AIstek : TSoapIstek):TGeneLYanitV12;

  function XMLGonderUretim(AIstek : TSoapIstek):TUretimBildirimYanit;
  function XMLGelenIsle (GelenYanit : TGenelYanit;GidenUrunler : TObjectList<TUrun>):string;
  function XMLGelenIsleV12 (GelenYanit : TGeneLYanitV12;GidenUrunler : TObjectList<TUrun>):string;
  //TUretimBildirimYanit
  function XMLGelenIsleUretim(GelenYanit:TUretimBildirimYanit):string;
  function XMLPtsGelenIsle(GelenYanit : TGenelYanitPTS;PaketID:Integer):string;
  function XMLPtsDetayGelenIsle(GelenYanit : TGenelDetayYanitPTS):string;
  function XMLPtsGelenAlimIsle(GelenYanit : TGenelAlimYanitPTS;TransferId:string):string;
  procedure AlimIadeIslemleri(GTIN,SN:string);
  procedure SatisIptalIslemleri(GTIN,SN:string);
  function ITSHesapBilgileriGetir(HesapId:integer): TITSHesapAyarlari;
  function XMLGonderPts(AIstek : TPTSSoapIstek):TGenelYanitPTS;
  function XMLGonderPtsAlim(AIstek :TPTSSoapIstek):TGenelAlimYanitPTS;
  function XMLGonderPtsDetay(AIstek: TPTSSoapIstek):TGenelDetayYanitPTS;
  procedure PaketGonder(Hedef, Kaynak ,HedefSube: string; PAKETID: Integer);
  procedure PaketAl(Hedef ,Kaynak : string; TransferNo: Integer);
  procedure PaketDetay(Hedef,Kaynak :string; TransferBilgi : Boolean; BasTar,BitTar : TDateTime);
  procedure PaketToXml(Hedef,HedefSube,TransferTipi:String;PaketID: Integer);
  procedure UrunOlustur(TasiyiciID:Integer;AUrunListesi:TList<TPTSUrun>);
  procedure TasiyiciOlustur(ATasiyiciListesi: TList<TTasiyici>;PaketID,TasiyiciID: Integer);
  procedure BildirimGuncelle(Yeri,YerID,Durum:Integer);
  procedure StringToStream(const AString: string; out AStream: TStream);
  procedure GlnAl(PaydasTipi : Byte;DeAktif : Boolean; PlakaKodu :Integer);
  procedure IlacAl(HepsiniGetir : Boolean);
  procedure HataAl;
  function XMLdenPtsAl(xmlyolu: string; transferId: integer = 0):string;

{$REGION 'ORTAK KULLANILACAK WEB SERVISLERI'}

{$ENDREGION}



{$ENDREGION}

var
 {<FR>} EczaDepoGLN  :string[13] = '8680052900019'; //Doðrulamayý yapan Ecza Deposunun GLN kodunu barýndýrýr.Bu alan 13 karakter uzunluktadýr ve sadece rakamlardan oluþur.
 {--------Mal Alým Servisi için FR ürünün alýndýðý depo veya üretici to ise alan depodur
 {<FR>}  MalUretenGLN :string[13] = '8680007200010'; //Bu alan, ürünün alýndýðý depo veya üreticinin GLN numarasýný barýndýrýr.
 {<TO_>} MaliAlanEczaDepoGLN :string = '8680052900019' ; //Bu alan ürünü alan deponun GLN kodunu içerir.
 //GLN Kodu ile ilgili detaylý bilgiler ÝTS Ýþletme Kýlavuzunda bulunur.
 {---------}
 {EczaDepolariKullaniciAdi   :string ='genotip';//'panates';// 'genotip';
 EczaDepolariKullaniciSifre :string ='genotip001';//'panates123';// 'genotip001';
 }
 EczaDepolariPTSKullaniciAdi : string ; //atlas1
 EczaDepolariPTSKullaniciSifre :string ;//atlas1453

 {EczaUreticiKullaniciAdi    :string = 'genyazilim';
 EczaUreticiKullaniciSifre  :string = 'genyazilim001'; }

 ITSKullaniciAdi : string;
 ITSSifre        : string;


// EczaDepoGLN :string[13] =  '8680049300013' ; PANATES
implementation
uses FetaKurulusSiniflari,FetaClassExtensions,Forms,UBekletme,KAZip,EncdDecd,ItsServisDrug,ItsServisError,ItsServisStakeholder;




  procedure StringToStream(const AString: string; out AStream: TStream);
  var
  SS: TStringStream;
  begin
  SS := TStringStream.Create(AString);
  try
    SS.Position := 0;
    AStream.CopyFrom(SS, SS.Size);  //This is where the "Abstract Error" gets thrown
  finally
    SS.Free;
  end;
  end;

  procedure GlnAl(PaydasTipi : Byte;DeAktif : Boolean; PlakaKodu :Integer);
  var
  Giden            : request;
  Gelen            : response;
  GonderilecekVeri : Stakeholder;
  Http             : THTTPRIO;
  Firmalar         : array of company;
  I , j: Integer;
  begin
   Giden := request.Create;
   case PaydasTipi of
    1: Giden.stakeholderType := 'uretici';
    2: Giden.stakeholderType := 'depo';
    3: Giden.stakeholderType := 'ihracatci';
    4: Giden.stakeholderType := 'eczane';
    5: Giden.stakeholderType := 'hastane';
   end;
   if PlakaKodu <> 0 then
    Giden.cityPlate := IntToStr(PlakaKodu) ;
   Giden.getAll := DeAktif;
   ITSHesapBilgileriGetir(ITSHesapID);
   Http := THTTPRIO.Create(nil);
   Http.HTTPWebNode.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
   GonderilecekVeri := GetStakeholder(False,'http://its.saglik.gov.tr/ReferenceServices/Stakeholder',Http);
   try
     Gelen := GonderilecekVeri.Stakeholder(Giden);
   except
      on e: exception do begin
        Abort;
      end;
   end;
   Application.CreateForm(TBekletmeDlg, BekletmeDlg);
   BekletmeDlg.Show;
   BekletmeDlg.cxProgressBar1.Properties.Max:= Length(gelen.companies) ;
   Tablo.BekletmeyiIlerlet(i,'Referans Ýþlemleri','Kayda baþlanýyor...',BekletmeDlg);
   j:= Length(gelen.companies) div 100;

    if j<=1 then  j:=2;
     for I := 0 to Length(gelen.companies) - 1 do
     begin
       Tablo.Query6.Close;
       Tablo.Query6.SQL.Text:=
       'IF NOT EXISTS (SELECT * FROM ITS_SERVIS_GLN WHERE GLN='''+gelen.companies[I].gln+''' AND ISIM = '''+StringReplace(gelen.companies[I].companyName, '''', '',[rfReplaceAll, rfIgnoreCase])+''' ) '+
       'INSERT INTO ITS_SERVIS_GLN(GLN,ISIM,AKTIF,YETKILI,EMAIL,TELEFON,IL,ILCE,ADRES,FIRMA_TUR)' +
       ' VALUES ('''+gelen.companies[I].gln+''','''+StringReplace(gelen.companies[I].companyName, '''', '',[rfReplaceAll, rfIgnoreCase])+''','+BoolToStr(gelen.companies[I].isActive) +','''+gelen.companies[I].authorized+''','''+gelen.companies[I].email+''','''+gelen.companies[I].phone+''',''' +
       ' '+gelen.companies[I].city+''','''+gelen.companies[I].town+''','''+StringReplace(gelen.companies[I].address, '''', '',[rfReplaceAll, rfIgnoreCase])+''','+IntToStr(PaydasTipi)+' )' ;
       Tablo.Query6.ExecSQL;
      if (I mod j) = 0 then
      begin
        BekletmeDlg.cxProgressBar1.Position := I;
        BekletmeDlg.LabelUstTaraf.Caption := 'Firma Adý  : '+StringReplace(gelen.companies[I].companyName, '''', '',[rfReplaceAll, rfIgnoreCase]);
        Application.ProcessMessages;
      end;
     end;

      BekletmeDlg.cxProgressBar1.Position := I;
      BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
      BekletmeDlg.close;
  end;

procedure HataAl;
  var
  Giden            : ItsServisError.Request;
  Gelen            : ItsServisError.Response;
  GonderilecekVeri : ErrorCode;
  Http             : THTTPRIO;
  Hatalar         : array of errorCode2;
  I ,j : Integer;
begin
   Giden := ItsServisError.Request.Create;
   ITSHesapBilgileriGetir(ITSHesapID);
   Http := THTTPRIO.Create(nil);
   Http.HTTPWebNode.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
   GonderilecekVeri := GetErrorCode(False,'http://its.saglik.gov.tr/ReferenceServices/ErrorCode',Http);
   try
   Application.CreateForm(TBekletmeDlg, BekletmeDlg);
   BekletmeDlg.Show;
   Tablo.BekletmeyiIlerlet(i,'Referans Ýþlemleri','Kayda baþlanýyor...',BekletmeDlg);
     Gelen := GonderilecekVeri.getErrorCodes(Giden);
   except
      on e: exception do begin
       BekletmeDlg.cxProgressBar1.Position := I;
       BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
       BekletmeDlg.close;
       Abort;
      end;
   end;


   BekletmeDlg.cxProgressBar1.Properties.Max:= Length(gelen.errorCodes) ;
   j:= Length(gelen.errorCodes) div 100;
    if j<=1 then  j:=2;
     for I := 0 to Length(gelen.errorCodes) - 1 do
     begin
       Tablo.Query6.Close;
       Tablo.Query6.SQL.Text:=
       'IF NOT EXISTS (SELECT * FROM ITS_SERVIS_HATA WHERE TIPI='''+gelen.errorCodes[I].type_+''' AND KODU = '''+StringReplace(gelen.errorCodes[I].code, '''', '',[rfReplaceAll, rfIgnoreCase])+''' ) '+
       'INSERT INTO ITS_SERVIS_HATA(TIPI,KODU,ACIKLAMA,BILGI)' +
       ' VALUES ('''+gelen.errorCodes[I].type_+''','''+StringReplace(gelen.errorCodes[I].code, '''', '',[rfReplaceAll, rfIgnoreCase])+''','''+StringReplace(gelen.errorCodes[I].message_, '''', '',[rfReplaceAll, rfIgnoreCase]) +''','''+StringReplace(gelen.errorCodes[I].description, '''', '',[rfReplaceAll, rfIgnoreCase]) + ''' ) ';
       Tablo.Query6.ExecSQL;
      if (I mod j) = 0 then
      begin
        BekletmeDlg.cxProgressBar1.Position := I;
        BekletmeDlg.LabelUstTaraf.Caption := 'Hata Adý  : '+ StringReplace(gelen.errorCodes[I].message_, '''', '',[rfReplaceAll, rfIgnoreCase]) ;
        Application.ProcessMessages;
      end;
     end;
     BekletmeDlg.cxProgressBar1.Position := I;
     BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
     BekletmeDlg.close;

end;

procedure IlacAl(HepsiniGetir : Boolean);
  var
  Giden            : ItsServisDrug.Request;
  Gelen            : ItsServisDrug.Response;
  GonderilecekVeri : Drug;
  Http             : THTTPRIO;
  Ilaclar         : array of drug2;
  I ,j : Integer;
  begin
   Giden := ItsServisDrug.Request.Create;
   Giden.getAll := HepsiniGetir;
   ITSHesapBilgileriGetir(ITSHesapID);
   Http := THTTPRIO.Create(nil);
   Http.HTTPWebNode.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
   GonderilecekVeri := GetDrug(False,'http://its.saglik.gov.tr/ReferenceServices/Drug',Http);
   try
   Application.CreateForm(TBekletmeDlg, BekletmeDlg);
   BekletmeDlg.Show;
   Tablo.BekletmeyiIlerlet(i,'Referans Ýþlemleri','Kayda baþlanýyor...',BekletmeDlg);
     Gelen := GonderilecekVeri.Drug(Giden);
   except
      on e: exception do begin
       BekletmeDlg.cxProgressBar1.Position := I;
       BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
       BekletmeDlg.close;
       Abort;
      end;
   end;

   BekletmeDlg.cxProgressBar1.Properties.Max:= Length(gelen.drugs) ;
   j:= Length(gelen.drugs) div 100;
    if j<=1 then  j:=2;
     for I := 0 to Length(gelen.drugs) - 1 do
     begin
       Tablo.Query6.Close;
       Tablo.Query6.SQL.Text:=
       'IF NOT EXISTS (SELECT * FROM ITS_SERVIS_ILAC WHERE GTIN='''+gelen.drugs[I].gtin+''' AND ADI = '''+StringReplace(gelen.drugs[I].drugName, '''', '',[rfReplaceAll, rfIgnoreCase])+''' ) '+
       'INSERT INTO ITS_SERVIS_ILAC(GTIN,ADI,URETICI_GLN,URETICI_AD,ITHAL,URETIM)' +
       ' VALUES ('''+gelen.drugs[I].gtin+''','''+StringReplace(gelen.drugs[I].drugName, '''', '',[rfReplaceAll, rfIgnoreCase])+''','''+gelen.drugs[I].manufacturerGLN +''','''+StringReplace(gelen.drugs[I].manufacturerName, '''', '',[rfReplaceAll, rfIgnoreCase]) +''','+
       ' '+BoolToStr(gelen.drugs[I].isImported)+','+BoolToStr(gelen.drugs[I].isActive)+' )' ;
       Tablo.Query6.ExecSQL;
      if (I mod j) = 0 then
      begin
        BekletmeDlg.cxProgressBar1.Position := I;
        BekletmeDlg.LabelUstTaraf.Caption := 'Ýlaç Adý  : '+StringReplace(gelen.drugs[I].drugName, '''', '',[rfReplaceAll, rfIgnoreCase]);
        Application.ProcessMessages;
      end;
     end;
     BekletmeDlg.cxProgressBar1.Position := I;
     BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
     BekletmeDlg.close;
  end;

procedure   BildirimGuncelle(Yeri,YerID,Durum:Integer);
begin
   with Veritabani.SorguBaslat(Tablo.cnn,'SELECT * FROM ITS_BILDIRIM WHERE YERI=$yeri '+
   'AND YERID= $id ',['$yeri','$id'],[Yeri,YerID] ) do
   try
   Open;
       if not Eof then
       begin
       Tablo.Query6.sql.Clear;
       Tablo.Query6.sql.Text:='UPDATE ITS_BILDIRIM SET  DURUM='+IntToStr(Durum)+'  , TARIH = GETDATE() WHERE  YERI='+IntToStr(yeri)+' AND YERID = '+IntToStr(YerID)+' ';
       Tablo.Query6.ExecSQL;
       end
       else
       begin
       Tablo.Query6.Close;
       Tablo.Query6.SQL.Text:= 'INSERT INTO ITS_BILDIRIM (TARIH,YERI,YERID,DURUM)' +
                               'VALUES (GETDATE(),'+IntToStr(yeri)+','+IntToStr(YerID)+','+IntToStr(Durum)+') ';
       Tablo.Query6.ExecSQL;
       end;
   finally
      Free;
   end;

end;
function XMLPtsDetayGelenIsle(GelenYanit : TGenelDetayYanitPTS):string;
var
I:Integer;
begin
Result := '';
   if GelenYanit.YanitHatali then
   begin
    if GelenYanit.HataServisAdi='packageTransferError' then
    begin
    //hata durumunda yapýlacaklar
   { Result := GelenYanit.FaultCode+' '+GelenYanit.FaultString;
     Tablo.Query6.sql.Clear;
     Tablo.Query6.sql.Add('INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES  ');
     Tablo.Query6.SQL.Add('('+GelenYanit.TransferID+','''+GelenYanit.HataServisAdi+''' , ');
     Tablo.Query6.SQL.Add(''''+GelenYanit.FaultCode+''','''+GelenYanit.FaultString+''' , ');
     Tablo.Query6.SQL.Add(''''+FormatDateTime('yyyy-MM-dd hh:nn',Now)+''' ) ');
     Tablo.Query6.ExecSQL;
     Tablo.Query7.Close;
     Tablo.Query7.sql.Text:='SELECT FB.ID FROM FATBASLIK FB INNER JOIN ITS_PAKET IP ON IP.FATBASID=FB.ID WHERE IP.ID = '+IntToStr(PaketID)+' ';
     Tablo.Query7.Open;
     BildirimGuncelle(2,Tablo.Query7.FieldByName('ID').AsInteger,3);   }
    end;
   end else
   begin
       //hatasýz durumda yapýlacaklar
      for I := 0 to GelenYanit.TransferDetay.Count - 1 do
      begin
      Tablo.TabPaketSorgula.Close;
      Tablo.TabPaketSorgula.SQL.Text := 'Select ID from ITS_BILDIRILMIS_PAKETLER WHERE TRANSFERID = '+IntToStr(GelenYanit.TransferDetay[I].TransferID)+' ';
      Tablo.TabPaketSorgula.Open;
        if Tablo.TabPaketSorgula.Eof then
        begin
          Tablo.TabPaketInsert.Close;
          Tablo.TabPaketInsert.SQL.Text:='INSERT INTO ITS_BILDIRILMIS_PAKETLER (KAYNAKGLN,HEDEFGLN,TRANSFERID,TRANSFERDATE) ' +
                                      'VALUES ('''+GelenYanit.TransferDetay[I].KaynakGLN+''','''+GelenYanit.TransferDetay[I].HedefGLN+''','+IntToStr(GelenYanit.TransferDetay[I].TransferID)+','''+FormatDateTime('yyyy-MM-dd',GelenYanit.TransferDetay[I].TransferTarih)+'''   )';
          Tablo.TabPaketInsert.ExecSQL;
        end;
      end;
   end;

end;

function XMLGonderPtsDetay(AIstek: TPTSSoapIstek):TGenelDetayYanitPTS;
var
     http : THTTPReqResp;
     i : Integer;
     Cevap : TStringStream;
begin
     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TStringStream.Create;
     try
       http.URL := 'http://pts.saglik.gov.tr/PTSHelper/PackageTransferHelperWebService';
       http.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
       //http.Proxy := '127.0.0.1:8888';
       http.UseUTF8InHeader := True;
       http.SoapAction := 'PackageTransferHelperService';
       http.Execute(AIstek.IcerikString,cevap);
       cevap.Position := 0;
       Result := TGenelDetayYanitPTS.Create(cevap);
     finally
       http.Free;
       cevap.Free;
     end;
end;

procedure PaketDetay(Hedef,Kaynak :string; TransferBilgi : Boolean; BasTar,BitTar : TDateTime);
var
PtsDetay : TPTSDetayIstek ;
Begin
   ITSHesapBilgileriGetir(ITSHesapID);
    PtsDetay := TPTSDetayIstek.Create;
    PtsDetay.HedefGLN:=Hedef;
    PtsDetay.KaynakGLN:=Kaynak;
    PtsDetay.TransferBilgisi := 'True';//BoolToStr(TransferBilgi);
    PtsDetay.BaslangicTarih := BasTar;
    PtsDetay.BitisTarih := BitTar;
    XMLPtsDetayGelenIsle(XMLGonderPtsDetay(PtsDetay));
end;

procedure TasiyiciOlustur(ATasiyiciListesi: TList<TTasiyici>;PaketID,TasiyiciID: Integer);
var
  I : Byte;
  r : TTasiyici;
begin
 with Veritabani.SorguBaslat(Tablo.cnn,'SELECT ID,USTID,SSCC,TASIMA_BIRIMI FROM ITS_TASIMA_BIRIMI WHERE PAKETID = $paket and USTID = $id',
    ['$paket','$id'],[PaketID,TasiyiciID]) do
 try
   Open;
   while not Eof do begin
     r := TTasiyici.Create;
     r.Etiket:= AsString['SSCC'];
     r.Tip   := AsString['TASIMA_BIRIMI'];
     ATasiyiciListesi.Add(r);
     UrunOlustur(AsInteger['ID'],r.UrunListesi);
     TasiyiciOlustur(r.IcTasiyicilar,PAketID,AsInteger['ID']);
     Next;
   end;
 finally
   Free;
 end;
end;
procedure UrunOlustur(TasiyiciID:Integer;AUrunListesi:TList<TPTSUrun>);
var
  Baslik      : String;
  Simdiki     : String;
  Item        : TPTSUrun;
begin
  Baslik := '';
  with Veritabani.SorguBaslat(Tablo.cnn,'SELECT * FROM STOKID WHERE TASIMA_BIRIMI_ID=$id',['$id'],[TasiyiciID]) do
  try
    Open;
    while not Eof do begin
      Simdiki := AsString['URUNBARKOD'] + AsString['LOTNO'] + AsString['URETIMTARIHI'] + AsString['SONKULLANIM'] + AsString['POSAYISI'];
      if Baslik <> Simdiki then begin
        Baslik := Simdiki;
        Item := TPTSUrun.Create;
        Item.GTIN := AsString['URUNBARKOD'];
        Item.UretimTarihi := AsString['URETIMTARIHI'];
        Item.SonKullanimTarihi := AsString['SONKULLANIM'];
        Item.PoSayisi := AsString['POSAYISI'];
        Item.LotNumarasi := AsString['LOTNO'];
        AUrunListesi.Add(Item);
      end;
      Item.SiraNo.Add(AsString['SIRANO']);
      Next;
    end;
  finally
    Free;
  end;
  while not Tablo.Query7.Eof do
  begin
  //if Tablo.Query7.Eof or Baslik <> Tablo.Query7.fieldbyname('URUNBARKOD').AsString +Tablo.Query7.fieldbyname('URETIMTARIHI').AsString+Tablo.Query7.fieldbyname('SONKULLANIM').AsString+Tablo.Query7.fieldbyname('POSAYISI').AsString then
  //Begin
  //  Item := TPTSUrun.Create;
  //end;
  Tablo.Query7.Next;
  end;
end;




function XMLdenPtsAl(xmlyolu: string; transferId : integer):string;
var
  xml : TECXMLParser;
  pts : TPTSXml;
  transferidEx : string;
  i:Integer;
begin
  Result := '';
  try
    xml := TECXMLParser.Create(nil);
    xml.LoadFromFile(xmlyolu);
    pts:=TPTSXml.XmldenGetir(xml.Root);
    if transferId > 0 then
      transferidEx:= Inttostr(transferId)
    else begin
      transferidEx := ExtractFileName(xmlyolu);
      i := Pos('-',  transferidEx);
      if i > 0 then
         transferidEx := Copy(transferidEx, 1, i-1);
    end;

    pts.VeriTabaniKaydet(transferidEx);
  finally
    pts.Free;
    xml.Free;
  end;
end;

function XMLPtsGelenAlimIsle(GelenYanit : TGenelAlimYanitPTS;TransferID :string):string;
var
XmlAdi: string;
GelenBinaryZip : TFileStream;
GelenStream ,GelenStream2 : TStringStream;
GelenMemoryStream : TMemoryStream;
Kzip : TKAZip;
xmlStream : TMemoryStream;
xml : TECXMLParser;
pts : TPTSXml;

begin
result := '';
   if GelenYanit.YanitHatali then
   begin
    if GelenYanit.HataServisAdi='receivepackage' then
    begin
    Result := GelenYanit.FaultCode+' '+GelenYanit.FaultString;

     Tablo.Query6.sql.Clear;
     Tablo.Query6.sql.Add('INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES  ');
     Tablo.Query6.SQL.Add('('+'0'+','''+GelenYanit.HataServisAdi+''' , ');
     Tablo.Query6.SQL.Add(''''+GelenYanit.FaultCode+''','''+GelenYanit.FaultString+''' , ');
     Tablo.Query6.SQL.Add(''''+FormatDateTime('yyyy-MM-dd hh:nn',Now)+''' ) ');
     Tablo.Query6.ExecSQL;
     ShowMessage(GelenYanit.FaultString);
    end;
   end else
   begin
      //FFileStream := TFileStream.Create('c:\B.zip',fmOpenRead);
      //Kzip oluþturuluyor ...
      kzip := TKAZip.Create(nil);
      //Bir memorystream oluþturuluyor..
      xmlStream := TMemoryStream.Create;
      //bir xmlparser oluþturuyor.
      xml := TECXMLParser.Create(nil);
      try
        //Gelen Zip dosya kzipde acýlýyor
        //FFileStream.Position:=0;
        If Not DirectoryExists('C:\Gentegre\GelenPts') Then
        If Not CreateDir('C:\Gentegre\GelenPts') then
        begin
          ShowMessage('Klasör oluþturulamadý');
          Abort;
        end;

        GelenBinaryZip := TFileStream.Create('C:\Gentegre\GelenPts\GelenPtsUrun'+FormatDateTime('yyyyMMddhhnnss',Now)+'.zip',fmCreate);
        GelenStream:= TStringStream.Create( GelenYanit.GelenString);
        GelenStream.DataString;
         GelenStream.Position:=0;
         GelenStream2 := TStringStream.Create;
         GelenStream2.Position:=0;
         DecodeStream(GelenStream,GelenStream2);
         GelenStream2.Position:=0;
        GelenBinaryZip.CopyFrom(GelenStream2,GelenStream2.Size);
        //GelenBinaryZip.CopyFrom(GelenStrStream,GelenStrStream.Size);

        //kzip.Open(GelenBinaryZip);  //kzip.Open(GelenBinaryZip); //FFileStream
        kzip.Open(GelenBinaryZip);
        // 0 ýncý entries i xmlstream e yükleniyor .
        kzip.Entries.Items[0].ExtractToStream(xmlStream);
        // memorystream 0 a getiriliyor .
        xmlStream.Position := 0;
        // token büyütülüyor.
//A        xml.DefaultLargeTokenizer := True;
        //parser a xml stream yükleeniyor.
        xml.LoadFromStream(xmlStream,TEncoding.UTF8);
        pts:=TPTSXml.XmldenGetir(xml.Root);
        pts.VeriTabaniKaydet(TransferID);
      finally
        kzip.Free;
        xmlStream.Free;
        xml.Free;
        GelenBinaryZip.Free;
        GelenStream.Free;
        GelenStream2.Free;
      end;
   end;
end;

function XMLPtsGelenIsle(GelenYanit : TGenelYanitPTS;PaketID:Integer):string;
VAR
TransferNumarasý : string;
begin
Result := '';
   if GelenYanit.YanitHatali then
   begin
    if GelenYanit.HataServisAdi='receivepackage' then
    begin
    Result := GelenYanit.FaultCode+' '+GelenYanit.FaultString;
     Tablo.Query6.sql.Clear;
     Tablo.Query6.sql.Add('INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES  ');
     Tablo.Query6.SQL.Add('('+GelenYanit.TransferID+','''+GelenYanit.HataServisAdi+''' , ');
     Tablo.Query6.SQL.Add(''''+GelenYanit.FaultCode+''','''+GelenYanit.FaultString+''' , ');
     Tablo.Query6.SQL.Add(''''+FormatDateTime('yyyy-MM-dd hh:nn',Now)+''' ) ');
     Tablo.Query6.ExecSQL;
     Tablo.Query7.Close;
     Tablo.Query7.sql.Text:='SELECT FB.ID FROM FATBASLIK FB INNER JOIN ITS_PAKET IP ON IP.FATBASID=FB.ID WHERE IP.ID = '+IntToStr(PaketID)+' ';
     Tablo.Query7.Open;
     BildirimGuncelle(2,Tablo.Query7.FieldByName('ID').AsInteger,3);
    end;
   end else
   begin
   Tablo.Query7.Close;
   Tablo.Query7.sql.Text:='SELECT FB.ID FROM FATBASLIK FB INNER JOIN ITS_PAKET IP ON IP.FATBASID=FB.ID WHERE IP.ID = '+IntToStr(PaketID)+' ';
   Tablo.Query7.Open;
   Tablo.Query6.sql.Clear;
   Tablo.Query6.sql.Add('UPDATE ITS_PAKET SET  TRANSFERID='+GelenYanit.TransferID+'  WHERE  ID = '+IntToStr(PaketID)+' ');
   Tablo.Query6.ExecSQL;
   BildirimGuncelle(2,Tablo.Query7.FieldByName('ID').AsInteger,9);
   Tablo.Query7.Close;
   Tablo.Query7.sql.Text:='SELECT * FROM ITS_PAKET WHERE ID = '+IntToStr(PaketID)+' ';
   Tablo.Query7.Open;
   TransferNumarasý :=' Transfer Numarasý : '+GelenYanit.TransferID;
   Tablo.Query6.Close;
   Tablo.Query6.sql.Clear;
   Tablo.Query6.sql.Text:='UPDATE FATBASLIK SET ACIKLAMA = '''+TransferNumarasý +'''  where ID = '+Tablo.Query7.FieldByName('FATBASID').AsString+' ';
   Tablo.Query6.ExecSQL;

   Tablo.Query6.Close;
   Tablo.Query6.sql.Clear;
   Tablo.Query6.sql.Text:='UPDATE FATBASLIK SET ACIKLAMA = '''+TransferNumarasý +'''  where ID = '+Tablo.Query7.FieldByName('FATBASID').AsString+' ';
   Tablo.Query6.ExecSQL;

   ShowMessage('Paket gönderimi hatasýz tamamlandý ve fatura güncellendi.Transfer Numarasý : '+GelenYanit.TransferID);
   end;
end;
  procedure PaketToXml(Hedef,HedefSube,TransferTipi:String;PaketID: Integer);
  var
  xml : TPTSXml;
  Etiketler,Bilgiler : TArrayOfString;
  begin
  with Veritabani.SorguBaslat(Tablo.cnn,'SELECT * FROM ITS_PAKET P INNER JOIN '+
  ' ITS_TASIMA_BIRIMI IT ON IT.PAKETID=P.ID AND USTID=-1 '+
  ' INNER JOIN FATBASLIK FB ON FB.ID=P.FATBASID ' +
  ' WHERE P.ID =$id',['$id'],[PaketID]) do
  try
    Open;
    xml :=  TPTSXml.Create;
    while not Eof do begin
      XML.KaynakGLN := GLNFirma;
      XML.HedefGLN  := Hedef;
      xml.TransferTipi  := TransferTipi;
      xml.SevkNereye    :=  HedefSube ;
      xml.BelgeNumarasi := FieldByName('FATURANO').AsString;
      XML.BelgeTarihi   := FieldByName('FATURATARIH').AsDateTime;
      XML.TransferNot   := '';
      xml.Versiyon      := '';
      TasiyiciOlustur(xml.Tasiyici,PaketID,FieldByName('USTID').AsInteger);
      XML.ZipKaydet;
      Next;
      end;
  finally
    Free;
  end;
  end;

  procedure PaketAl(Hedef ,Kaynak : string; TransferNo: Integer);
  var
  Alim : TPTSAlimIstek;
  begin
  ITSHesapBilgileriGetir(ITSHesapID);
  Alim := TPTSAlimIstek.Create;
  Alim.Kaynak := Hedef;
  Alim.TRANSFERID := IntToStr(TransferNo);
  XMLPtsGelenAlimIsle(XMLGonderPtsAlim(Alim),IntToStr(TransferNo));
  end;

  procedure PaketGonder(Hedef, Kaynak ,HedefSube : string; PAKETID: Integer);
    var
    GonPaketParams :sendFileParameters;
    GonPaketStreamParams:sendFileStreamParameters;
    GonPtsWs:PackageSenderWS;
    GelenCevap : sendFileResponse;
    http : THTTPRIO;
    i:Integer;
    Zipfile :TFileStream;
    GonStream : TMemoryStream;
    GonArray  : TByteDynArray;
    e:TExceptionRecord;
    Gonderim : TPTSGonderimIstek;
  begin
    ITSHesapBilgileriGetir(ITSHesapID);
    PaketToXml(Hedef,HedefSube,MALALIM,PAKETID);
    Gonderim := TPTSGonderimIstek.Create;
    Gonderim.HedefGLN:=Hedef;
    Gonderim.KaynakGLN:=Kaynak;
    XMLPtsGelenISle(xmlGonderPts(Gonderim),PAKETID);
    //wsdl kullanarak gönderme için kullanýlacak ..
  { GonPaketParams := sendFileParameters.Create;
    GonPaketParams.destinationGLN:=Hedef;
    GonPaketParams.sourceGLN:=Kaynak;
    GonPaketStreamParams := sendFileStreamParameters.Create;
    GonPaketStreamParams.sendFileParameters:=GonPaketParams;
    http := THTTPRIO.Create(nil);
    http.HTTPWebNode.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
    try
     GonStream := TMemoryStream.Create;
     GonStream.LoadFromFile('c:\GonderilecekXml.zip');
     setlength(GonArray,GonStream.size);
     GonStream.Position:=0;
     if GonStream.size>0 then
       move (pansichar(GonStream.memory)^,GonArray[0],GonStream.size);
     //zipfile.read(arr,zipfile.size);
    finally
     GonStream.free;
    end;
     GonPaketStreamParams.fileStreamElement := GonArray;
     GonPtsWs :=GetPackageSenderWS(False,'http://pts.saglik.gov.tr/PTS/PackageSenderWebService',http);
    try
     GelenCevap := GonPtsWs.sendFileStream(GonPaketStreamParams);
    except
      on e: exception do begin
        Abort;
      end;
    end;
 }
  end;

   function XMLGelenIsleUretim(GelenYanit:TUretimBildirimYanit):string;
   var
   I,J : integer;
   cmd ,cmd2 : TADOCommand;
   GelenBildirimId : Integer;
   begin
   Result:='';
   I:= 0;
     if GelenYanit.YanitHatali then
     begin
        if GelenYanit.BildirimId='' then GelenBildirimId:=0
        else GelenBildirimId:= StrToInt(GelenYanit.BildirimId);

        Tablo.Query6.Close;
        Tablo.Query6.sql.Text:='';
        Tablo.Query6.sql.Add('INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES  ');
        Tablo.Query6.SQL.Add('('+IntToStr(GelenBildirimId)+','''+GelenYanit.HataServisAdi+''' , ');
        Tablo.Query6.SQL.Add(''''+'0'+''','''+'0'+''' , ');
        Tablo.Query6.SQL.Add(''''+GelenYanit.FaultCode+''','''+GelenYanit.FaultString+''' , ');
        Tablo.Query6.SQL.Add(''''+FormatDateTime('yyyy-MM-dd hh:nn',Now)+''' ) ');
        Tablo.Query6.ExecSQL;
        Result:= GelenYanit.FaultString;
     end
     else
     begin
     Result := 'Servis hatasi yok ürüneri kontrol ediniz.';
        Application.CreateForm(TBekletmeDlg, BekletmeDlg);
        BekletmeDlg.Show;
        BekletmeDlg.cxProgressBar1.Properties.Max:= GelenYanit.UrunDurumlar.Count ;
        Tablo.BekletmeyiIlerlet(i,'Bildirim Ýþlemleri','Gönderime baþlanýyor...',BekletmeDlg);

        j:= GelenYanit.UrunDurumlar.Count div 100;
        if j<=1 then
             j:=2;
         cmd := Veritabani.KomutBaslat(Tablo.cnn,'UPDATE kk SET URETIM_DURUM= :drm,URETIM_BILDIRIM_TARIH =GETDATE() FROM KAREKOD kk  ' +
            'INNER JOIN STOKID si ON si.URUNBARKOD=:ubar AND si.SIRANO = :usira AND kk.STOKIDID = si.ID',[],[]);
         cmd.Parameters[0].DataType := ftString;
         cmd.Parameters[0].Size := 1000;
         cmd.Parameters[1].DataType := ftString;
         cmd.Parameters[1].Size := 30;
         cmd.Parameters[2].DataType := ftString;
         cmd.Parameters[2].Size := 30;
         cmd.Prepared := True;

         cmd2 := Veritabani.KomutBaslat(Tablo.cnn,'INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES '
           +' ( ''0'',:hataservisadi,:urungtýn,:urunsn,:hatakod,:hataaciklama,Getdate() ) ' ,[],[]);
         cmd2.Parameters[0].DataType := ftString;
         cmd2.Parameters[0].Size := 100;
         cmd2.Parameters[1].DataType := ftString;
         cmd2.Parameters[1].Size := 30;
         cmd2.Parameters[2].DataType := ftString;
         cmd2.Parameters[2].Size := 30;
         cmd2.Parameters[3].DataType := ftString;
         cmd2.Parameters[3].Size := 10;
         cmd2.Parameters[4].DataType := ftString;
         cmd2.Parameters[4].Size := 1000;
         cmd2.Prepared := True;

       for I := 0 to GelenYanit.UrunDurumlar.Count - 1 do
         begin
          cmd2.Parameters[0].Value := GelenYanit.ServisAdi;
          cmd2.Parameters[1].Value := GelenYanit.GTIN;
          cmd2.Parameters[2].Value := GelenYanit.UrunDurumlar[I].SN;
          cmd2.Parameters[3].Value := GelenYanit.UrunDurumlar[I].UC;
          cmd2.Parameters[4].Value := HataToMsg(GelenYanit.UrunDurumlar[I].UC);
          cmd2.Execute;
          cmd.Parameters[0].Value := GelenYanit.UrunDurumlar[I].UC + '-' + HataToMsg(GelenYanit.UrunDurumlar[I].UC);
          cmd.Parameters[1].Value := GelenYanit.GTIN;
          cmd.Parameters[2].Value := GelenYanit.UrunDurumlar[I].SN;
          cmd.Execute;

           if (I mod j) = 0 then
            begin
             BekletmeDlg.cxProgressBar1.Position := I;
             BekletmeDlg.LabelUstTaraf.Caption := 'Ürün SýraNo  : '+GelenYanit.UrunDurumlar[I].SN;
             Application.ProcessMessages;
            end;
         end;
      BekletmeDlg.cxProgressBar1.Position := I;
      BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
      BekletmeDlg.close;
     end;
   end;

   function XMLGelenIsle (GelenYanit : TGenelYanit;GidenUrunler : TObjectList<TUrun> ):string;
   var
   UrunDurum :array of  TUrunDurum;
   Urun : TUrun;
   I,j : integer;
   Durum , Durum_Tarih :string;
   cmd , cmd2  : TADOCommand;
   begin
   Result := '';
   I:= 0;
    if GelenYanit.YanitHatali then
    begin
      if GelenYanit.HataServisAdi='receivepackage' then
      begin
      Result := GelenYanit.FaultCode+' '+GelenYanit.FaultString;
      end
      else
      begin
       if GelenYanit.HataServisAdi = 'DepoMalAlim' then begin Durum:= 'ALIM_DURUM'; Durum_Tarih:= 'ALIM_BILDIRIM_TARIH';  end else
       if GelenYanit.HataServisAdi = 'Deaktivasyon' then begin Durum:= 'DEAKTIVASYON_DURUM'; Durum_Tarih:= 'DEAKTIVASYON_BILDIRIM_TARIH';  end else
       if GelenYanit.HataServisAdi = 'DepoDogrulama' then begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end else
       if GelenYanit.HataServisAdi = 'DepoMalIade' then begin Durum:= 'ALIM_IADE_DURUM'; Durum_Tarih:= 'ALIM_IADE_BILDIRIM_TARIH';  end else
       if (GelenYanit.HataServisAdi = 'DepoSatis') or (GelenYanit.HataServisAdi='UreticiSatis') or (GelenYanit.HataServisAdi='dispatch') then begin Durum:= 'SATIS_DURUM'; Durum_Tarih:= 'SATIS_BILDIRIM_TARIH';  end else
       if (GelenYanit.HataServisAdi = 'DepoSatisIptal') or (GelenYanit.HataServisAdi = 'UreticiSatisIptal') then begin Durum:= 'SATIS_IPTAL_DURUM'; Durum_Tarih:= 'SATIS_IPTAL_BILDIRIM_TARIH';  end
       else begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end;

       Application.CreateForm(TBekletmeDlg, BekletmeDlg);
       BekletmeDlg.Show;
       BekletmeDlg.cxProgressBar1.Properties.Max:= GidenUrunler.Count ;
       Tablo.BekletmeyiIlerlet(i,'Güncelleme Ýþlemi','Güncellemeye baþlanýyor...',BekletmeDlg);

       j:= GidenUrunler.Count div 100;
       if j<=1 then
           j:=2;
         cmd := Veritabani.KomutBaslat(Tablo.cnn,'UPDATE kk SET '+Durum+' = :drm,'+ Durum_Tarih +'= GETDATE() FROM KAREKOD kk  ' +
            'INNER JOIN STOKID si ON si.URUNBARKOD=:ubar AND si.SIRANO = :usira AND kk.STOKIDID = si.ID',[],[]);
         cmd.Parameters[0].DataType := ftString;
         cmd.Parameters[0].Size := 1000;
         cmd.Parameters[1].DataType := ftString;
         cmd.Parameters[1].Size := 30;
         cmd.Parameters[2].DataType := ftString;
         cmd.Parameters[2].Size := 30;
         cmd.Prepared := True;
         cmd2 := Veritabani.KomutBaslat(Tablo.cnn,'INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES '
         +' ( ''0'',:hataservisadi,:urungtýn,:urunsn,:hatakod,:hataaciklama,Getdate() ) ' ,[],[]);
         cmd2.Parameters[0].DataType := ftString;
         cmd2.Parameters[0].Size := 100;
         cmd2.Parameters[1].DataType := ftString;
         cmd2.Parameters[1].Size := 30;
         cmd2.Parameters[2].DataType := ftString;
         cmd2.Parameters[2].Size := 30;
         cmd2.Parameters[3].DataType := ftString;
         cmd2.Parameters[3].Size := 10;
         cmd2.Parameters[4].DataType := ftString;
         cmd2.Parameters[4].Size := 1000;
         cmd2.Prepared := True;
         for I := 0 to GidenUrunler.Count - 1 do
         begin
          //Bekleme olacak
          Urun := GidenUrunler[i];
          cmd2.Parameters[0].Value := GelenYanit.HataServisAdi;
          cmd2.Parameters[1].Value := Urun.GTIN;
          cmd2.Parameters[2].Value := Urun.SN;
          cmd2.Parameters[3].Value := GelenYanit.FaultCode;
          cmd2.Parameters[4].value := GelenYanit.FaultString;
          cmd2.Execute;
          cmd.Parameters[0].Value := GelenYanit.FaultCode + '-' + GelenYanit.FaultString;
          cmd.Parameters[1].Value := GidenUrunler[i].GTIN;
          cmd.Parameters[2].Value := GidenUrunler[i].SN;
          cmd.Execute;
          if (I mod j) = 0 then
          begin
           BekletmeDlg.cxProgressBar1.Position := I;
           BekletmeDlg.LabelUstTaraf.Caption := 'Ürün SýraNo  : '+Urun.SN;
           Application.ProcessMessages;
          end;
         end;
        BekletmeDlg.cxProgressBar1.Position := I;
        BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
        BekletmeDlg.close;
      end;
    end
    else
    begin
       if GelenYanit.ServisAdi = 'DepoMalAlimCevap' then begin Durum:= 'ALIM_DURUM'; Durum_Tarih:= 'ALIM_BILDIRIM_TARIH';  end;
       if GelenYanit.ServisAdi = 'DeaktivasyonBildirimCevap' then begin Durum:= 'DEAKTIVASYON_DURUM'; Durum_Tarih:= 'DEAKTIVASYON_BILDIRIM_TARIH';  end;
       if GelenYanit.ServisAdi = 'DepoDogrulamaBildirimCevap' then begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end;
       if GelenYanit.ServisAdi = 'DepoMalIadeCevap' then begin Durum:= 'ALIM_IADE_DURUM'; Durum_Tarih:= 'ALIM_IADE_BILDIRIM_TARIH';  end;
       if (GelenYanit.ServisAdi = 'SatisBildirimCevap') or (GelenYanit.ServisAdi='DispatchResponse')   then begin Durum:= 'SATIS_DURUM'; Durum_Tarih:= 'SATIS_BILDIRIM_TARIH';  end;
       if GelenYanit.ServisAdi = 'SatisIptalBildirimCevap' then begin Durum:= 'SATIS_IPTAL_DURUM'; Durum_Tarih:= 'SATIS_IPTAL_BILDIRIM_TARIH';  end;
       if GelenYanit.ServisAdi = 'UretimResponse' then begin Durum:= 'URETIM_DURUM'; Durum_Tarih:= 'URETIM_BILDIRIM_TARIH';  end;


       Application.CreateForm(TBekletmeDlg, BekletmeDlg);
       BekletmeDlg.Show;
       BekletmeDlg.cxProgressBar1.Properties.Max:= GidenUrunler.Count ;
       Tablo.BekletmeyiIlerlet(i,'Bildirim Ýþlemleri','Gönderime baþlanýyor...',BekletmeDlg);

       j:= GelenYanit.UrunDurumlar.Count div 100;
       if j<=1 then
           j:=2;
         cmd := Veritabani.KomutBaslat(Tablo.cnn,'UPDATE kk SET '+Durum+' = :drm,'+ Durum_Tarih +' = GETDATE() FROM KAREKOD kk  ' +
            'INNER JOIN STOKID si ON si.URUNBARKOD=:ubar AND si.SIRANO = :usira AND kk.STOKIDID = si.ID',[],[]);
         cmd.Parameters[0].DataType := ftString;
         cmd.Parameters[0].Size := 1000;
         cmd.Parameters[1].DataType := ftString;
         cmd.Parameters[1].Size := 50;
         cmd.Parameters[2].DataType := ftString;
         cmd.Parameters[2].Size := 50;
         cmd.Prepared := True;
         cmd2 := Veritabani.KomutBaslat(Tablo.cnn,'INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES '
         +' ( :bildirimID,:hataservisadi,:urungtýn,:urunsn,:hatakod,:hataaciklama,Getdate() ) ' ,[],[]);
         cmd2.Parameters[0].DataType := ftLargeint;
         cmd2.Parameters[1].DataType := ftString;
         cmd2.Parameters[1].Size := 1000;
         cmd2.Parameters[2].DataType := ftString;
         cmd2.Parameters[2].Size := 30;
         cmd2.Parameters[3].DataType := ftString;
         cmd2.Parameters[3].Size := 30;
         cmd2.Parameters[4].DataType := ftString;
         cmd2.Parameters[4].Size := 100;
         cmd2.Parameters[5].DataType := ftString;
         cmd2.Parameters[5].Size := 1000;
         cmd2.Prepared := True;
       for I := 0 to GelenYanit.UrunDurumlar.Count - 1 do
       begin
          cmd2.Parameters[0].Value := GelenYanit.BildirimId;
          cmd2.Parameters[1].Value := GelenYanit.ServisAdi;
          cmd2.Parameters[2].Value := GelenYanit.UrunDurumlar[I].GTIN;
          cmd2.Parameters[3].Value := GelenYanit.UrunDurumlar[I].SN;
          cmd2.Parameters[4].Value := GelenYanit.UrunDurumlar[I].UC;
          cmd2.Parameters[5].value := HataToMsg(GelenYanit.UrunDurumlar[I].UC);
          cmd2.Execute;
          cmd.Parameters[0].Value := GelenYanit.UrunDurumlar[I].UC + '-' + HataToMsg(GelenYanit.UrunDurumlar[I].UC);
          cmd.Parameters[1].Value := GelenYanit.UrunDurumlar[I].GTIN;
          cmd.Parameters[2].Value := GelenYanit.UrunDurumlar[I].SN;
          cmd.Execute;

           if (I mod j) = 0 then
           begin
           BekletmeDlg.cxProgressBar1.Position := I;
           BekletmeDlg.LabelUstTaraf.Caption := 'Ürün SýraNo  : '+GelenYanit.UrunDurumlar[I].SN;
           Application.ProcessMessages;
           end;

       end;
        {if (GelenYanit.ServisAdi = 'DepoMalIadeCevap') and (GelenYanit.UrunDurumlar[I].UC = '00000' ) then
        begin
          AlimIadeIslemleri(GelenYanit.UrunDurumlar[I].GTIN,GelenYanit.UrunDurumlar[I].SN);
        end;
        if (GelenYanit.ServisAdi = 'SatisIptalBildirimCevap') and ( (GelenYanit.UrunDurumlar[I].UC = '10223') or (GelenYanit.UrunDurumlar[I].UC = '00000') ) then
        begin
          SatisIptalIslemleri(GelenYanit.UrunDurumlar[I].GTIN,GelenYanit.UrunDurumlar[I].SN);
        end; }
       BekletmeDlg.cxProgressBar1.Position := I;
       BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
       BekletmeDlg.close;
       ShowMessage('Ýþlem Tamamlandý.');
    end;


   end;
   function XMLGelenIsleV12 (GelenYanit : TGeneLYanitV12;GidenUrunler : TObjectList<TUrun> ):string;
   var
   UrunDurum :array of  TUrunDurum;
   Urun : TUrun;
   I,j : integer;
   Durum , Durum_Tarih :string;
   cmd , cmd2  : TADOCommand;
   begin
   Result := '';
   I:= 0;
    if GelenYanit.YanitHatali then
    begin
      if GelenYanit.HataServisAdi='receivepackage' then
      begin
      Result := GelenYanit.FaultCode+' '+GelenYanit.FaultString;
      end
      else
      begin
       if GelenYanit.HataServisAdi = 'receipt' then begin Durum:= 'ALIM_DURUM'; Durum_Tarih:= 'ALIM_BILDIRIM_TARIH';  end else
       //if GelenYanit.HataServisAdi = 'Deaktivasyon' then begin Durum:= 'DEAKTIVASYON_DURUM'; Durum_Tarih:= 'DEAKTIVASYON_BILDIRIM_TARIH';  end else
       //if GelenYanit.HataServisAdi = 'DepoDogrulama' then begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end else
       //if GelenYanit.HataServisAdi = 'DepoMalIade' then begin Durum:= 'ALIM_IADE_DURUM'; Durum_Tarih:= 'ALIM_IADE_BILDIRIM_TARIH';  end else
       if GelenYanit.HataServisAdi = 'dispatch' then begin Durum:= 'SATIS_DURUM'; Durum_Tarih:= 'SATIS_BILDIRIM_TARIH';  end else
       if GelenYanit.HataServisAdi = 'DispatchCancellation' then begin Durum:= 'SATIS_IPTAL_DURUM'; Durum_Tarih:= 'SATIS_IPTAL_BILDIRIM_TARIH';  end
       else begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end;

       Application.CreateForm(TBekletmeDlg, BekletmeDlg);
       BekletmeDlg.Show;
       BekletmeDlg.cxProgressBar1.Properties.Max:= GidenUrunler.Count ;
       Tablo.BekletmeyiIlerlet(i,'Güncelleme Ýþlemi','Güncellemeye baþlanýyor...',BekletmeDlg);

       j:= GidenUrunler.Count div 100;
       if j<=1 then
           j:=2;
         cmd := Veritabani.KomutBaslat(Tablo.cnn,'UPDATE kk SET '+Durum+' = :drm,'+ Durum_Tarih +'= GETDATE() FROM KAREKOD kk  ' +
            'INNER JOIN STOKID si ON si.URUNBARKOD=:ubar AND si.SIRANO = :usira AND kk.STOKIDID = si.ID',[],[]);
         cmd.Parameters[0].DataType := ftString;
         cmd.Parameters[0].Size := 1000;
         cmd.Parameters[1].DataType := ftString;
         cmd.Parameters[1].Size := 30;
         cmd.Parameters[2].DataType := ftString;
         cmd.Parameters[2].Size := 30;
         cmd.Prepared := True;
         cmd2 := Veritabani.KomutBaslat(Tablo.cnn,'INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES '
         +' ( ''0'',:hataservisadi,:urungtýn,:urunsn,:hatakod,:hataaciklama,Getdate() ) ' ,[],[]);
         cmd2.Parameters[0].DataType := ftString;
         cmd2.Parameters[0].Size := 100;
         cmd2.Parameters[1].DataType := ftString;
         cmd2.Parameters[1].Size := 30;
         cmd2.Parameters[2].DataType := ftString;
         cmd2.Parameters[2].Size := 30;
         cmd2.Parameters[3].DataType := ftString;
         cmd2.Parameters[3].Size := 10;
         cmd2.Parameters[4].DataType := ftString;
         cmd2.Parameters[4].Size := 1000;
         cmd2.Prepared := True;
         for I := 0 to GidenUrunler.Count - 1 do
         begin
          //Bekleme olacak
          Urun := GidenUrunler[i];
          cmd2.Parameters[0].Value := GelenYanit.HataServisAdi;
          cmd2.Parameters[1].Value := Urun.GTIN;
          cmd2.Parameters[2].Value := Urun.SN;
          cmd2.Parameters[3].Value := GelenYanit.FaultCode;
          cmd2.Parameters[4].value := GelenYanit.FaultString;
          cmd2.Execute;
          cmd.Parameters[0].Value := GelenYanit.FaultCode + '-' + GelenYanit.FaultString;
          cmd.Parameters[1].Value := GidenUrunler[i].GTIN;
          cmd.Parameters[2].Value := GidenUrunler[i].SN;
          cmd.Execute;
          if (I mod j) = 0 then
          begin
           BekletmeDlg.cxProgressBar1.Position := I;
           BekletmeDlg.LabelUstTaraf.Caption := 'Ürün SýraNo  : '+Urun.SN;
           Application.ProcessMessages;
          end;
         end;
        BekletmeDlg.cxProgressBar1.Position := I;
        BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
        BekletmeDlg.close;
      end;
    end
    else
    begin
       if GelenYanit.ServisAdi = 'ReceiptResponse' then begin Durum:= 'ALIM_DURUM'; Durum_Tarih:= 'ALIM_BILDIRIM_TARIH';  end;
       //if GelenYanit.ServisAdi = 'DeaktivasyonBildirimCevap' then begin Durum:= 'DEAKTIVASYON_DURUM'; Durum_Tarih:= 'DEAKTIVASYON_BILDIRIM_TARIH';  end;
       //if GelenYanit.ServisAdi = 'DepoDogrulamaBildirimCevap' then begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end;
       //if GelenYanit.ServisAdi = 'DepoMalIadeCevap' then begin Durum:= 'ALIM_IADE_DURUM'; Durum_Tarih:= 'ALIM_IADE_BILDIRIM_TARIH';  end;
       if GelenYanit.ServisAdi = 'DispatchResponse'   then begin Durum:= 'SATIS_DURUM'; Durum_Tarih:= 'SATIS_BILDIRIM_TARIH';  end;
       if GelenYanit.ServisAdi = 'DispatchCancellationResponse' then begin Durum:= 'SATIS_IPTAL_DURUM'; Durum_Tarih:= 'SATIS_IPTAL_BILDIRIM_TARIH';  end;
       //if GelenYanit.ServisAdi = 'UretimResponse' then begin Durum:= 'URETIM_DURUM'; Durum_Tarih:= 'URETIM_BILDIRIM_TARIH';  end;


       Application.CreateForm(TBekletmeDlg, BekletmeDlg);
       BekletmeDlg.Show;
       BekletmeDlg.cxProgressBar1.Properties.Max:= GidenUrunler.Count ;
       Tablo.BekletmeyiIlerlet(i,'Bildirim Ýþlemleri','Gönderime baþlanýyor...',BekletmeDlg);

       j:= GelenYanit.UrunDurumlar.Count div 100;
       if j<=1 then
           j:=2;
         cmd := Veritabani.KomutBaslat(Tablo.cnn,'UPDATE kk SET '+Durum+' = :drm,'+ Durum_Tarih +' = GETDATE() FROM KAREKOD kk  ' +
            'INNER JOIN STOKID si ON si.URUNBARKOD=:ubar AND si.SIRANO = :usira AND kk.STOKIDID = si.ID',[],[]);
         cmd.Parameters[0].DataType := ftString;
         cmd.Parameters[0].Size := 1000;
         cmd.Parameters[1].DataType := ftString;
         cmd.Parameters[1].Size := 50;
         cmd.Parameters[2].DataType := ftString;
         cmd.Parameters[2].Size := 50;
         cmd.Prepared := True;
         cmd2 := Veritabani.KomutBaslat(Tablo.cnn,'INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES '
         +' ( :bildirimID,:hataservisadi,:urungtýn,:urunsn,:hatakod,:hataaciklama,Getdate() ) ' ,[],[]);
         cmd2.Parameters[0].DataType := ftLargeint;
         cmd2.Parameters[1].DataType := ftString;
         cmd2.Parameters[1].Size := 1000;
         cmd2.Parameters[2].DataType := ftString;
         cmd2.Parameters[2].Size := 30;
         cmd2.Parameters[3].DataType := ftString;
         cmd2.Parameters[3].Size := 30;
         cmd2.Parameters[4].DataType := ftString;
         cmd2.Parameters[4].Size := 100;
         cmd2.Parameters[5].DataType := ftString;
         cmd2.Parameters[5].Size := 1000;
         cmd2.Prepared := True;
       for I := 0 to GelenYanit.UrunDurumlar.Count - 1 do
       begin
          cmd2.Parameters[0].Value := GelenYanit.BildirimId;
          cmd2.Parameters[1].Value := GelenYanit.ServisAdi;
          cmd2.Parameters[2].Value := GelenYanit.UrunDurumlar[I].GTIN;
          cmd2.Parameters[3].Value := GelenYanit.UrunDurumlar[I].SN;
          cmd2.Parameters[4].Value := GelenYanit.UrunDurumlar[I].UC;
          cmd2.Parameters[5].value := HataToMsg(GelenYanit.UrunDurumlar[I].UC);
          cmd2.Execute;
          cmd.Parameters[0].Value := GelenYanit.UrunDurumlar[I].UC + '-' + HataToMsg(GelenYanit.UrunDurumlar[I].UC);
          cmd.Parameters[1].Value := GelenYanit.UrunDurumlar[I].GTIN;
          cmd.Parameters[2].Value := GelenYanit.UrunDurumlar[I].SN;
          cmd.Execute;

           if (I mod j) = 0 then
           begin
           BekletmeDlg.cxProgressBar1.Position := I;
           BekletmeDlg.LabelUstTaraf.Caption := 'Ürün SýraNo  : '+GelenYanit.UrunDurumlar[I].SN;
           Application.ProcessMessages;
           end;

       end;
        {if (GelenYanit.ServisAdi = 'DepoMalIadeCevap') and (GelenYanit.UrunDurumlar[I].UC = '00000' ) then
        begin
          AlimIadeIslemleri(GelenYanit.UrunDurumlar[I].GTIN,GelenYanit.UrunDurumlar[I].SN);
        end;
        if (GelenYanit.ServisAdi = 'SatisIptalBildirimCevap') and ( (GelenYanit.UrunDurumlar[I].UC = '10223') or (GelenYanit.UrunDurumlar[I].UC = '00000') ) then
        begin
          SatisIptalIslemleri(GelenYanit.UrunDurumlar[I].GTIN,GelenYanit.UrunDurumlar[I].SN);
        end; }
       BekletmeDlg.cxProgressBar1.Position := I;
       BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
       BekletmeDlg.close;

    end;
     ShowMessage('Ýþlem Tamamlandý.');
   end;


   function XMLGonderUretim(AIstek : TSoapIstek):TUretimBildirimYanit;
   var
     http : THTTPReqResp;
     i : Integer;
     cevap : TStringStream;
     Etiketler,Bilgiler : TArrayOfString;
   begin
     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TStringStream.Create;
     try
       http.OnBeforePost := Tablo.GenericHTTPReqRespBeforePost;
       http.URL := AIstek.ServisUrl;
       http.UseUTF8InHeader := True;

       i := Dize.TerstenAra('/',AIstek.ServisUrl);
       http.SoapAction := Copy(AIstek.ServisUrl,i + 1,(Length(AIstek.ServisUrl) - i) + 1);
       http.Execute(AIstek.IcerikString,cevap);
       cevap.Position := 0;
       Result := TUretimBildirimYanit.Create(cevap);
     finally
       InternetSetOption(Pointer( http.Tag ),INTERNET_OPTION_END_BROWSER_SESSION,nil,0);
       http.Free;
       cevap.Free;
     end;
   end;


   function XMLGonder(AIstek : TSoapIstek):TGenelYanit;
   var
     http : THTTPReqResp;
     i : Integer;
     cevap : TStringStream;
     Etiketler,Bilgiler : TArrayOfString;
   begin
     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TStringStream.Create;
     try
       http.OnBeforePost := Tablo.GenericHTTPReqRespBeforePost;
       http.URL := AIstek.ServisUrl;
       http.UseUTF8InHeader := True;
       i := Dize.TerstenAra('/',AIstek.ServisUrl);
       http.SoapAction := Copy(AIstek.ServisUrl,i + 1,(Length(AIstek.ServisUrl) - i) + 1);
       http.Execute(AIstek.IcerikString,cevap);
       cevap.Position := 0;
       Result := TGenelYanit.Create(cevap);
     finally
       InternetSetOption(Pointer( http.Tag ),INTERNET_OPTION_END_BROWSER_SESSION,nil,0);
       http.Free;
       cevap.Free;
     end;
   end;
   function XMLGonderV12(AIstek : TSoapIstek):TGeneLYanitV12;
   var
     http : THTTPReqResp;
     i : Integer;
     cevap : TStringStream;
     Etiketler,Bilgiler : TArrayOfString;
   begin
     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TStringStream.Create;
     try
       http.OnBeforePost := Tablo.GenericHTTPReqRespBeforePost;
       http.URL := AIstek.ServisUrl;
       http.UseUTF8InHeader := True;
       //http.Proxy := '127.0.0.1:8888';

       i := Dize.TerstenAra('/',AIstek.ServisUrl);
       http.SoapAction := Copy(AIstek.ServisUrl,i + 1,(Length(AIstek.ServisUrl) - i) + 1);
       http.Execute(AIstek.IcerikString,cevap);
       cevap.Position := 0;
       Result := TGeneLYanitV12.Create(cevap);
     finally
       InternetSetOption(Pointer( http.Tag ),INTERNET_OPTION_END_BROWSER_SESSION,nil,0);
       http.Free;
       cevap.Free;
     end;
   end;

   function XMLGonderPtsAlim(AIstek :TPTSSoapIstek):TGenelAlimYanitPTS;
   var
     http : THTTPReqResp;
     i : Integer;
     cevap : TStringStream;
     PtsXml :TPTSXml;
   begin
     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TStringStream.Create;
      try
     // http://pts.saglik.gov.tr/PTS/PackageReceiverWebService

       http.URL := 'http://pts.saglik.gov.tr/PTS/PackageReceiverWebService';
       http.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
       http.UseUTF8InHeader := True;
       http.SoapAction := 'PackageReceiverWebService';
       http.Execute(AIstek.IcerikString,cevap);
       cevap.Position := 0;
       Result := TGenelAlimYanitPTS.Create(cevap);
     finally
       http.Free;
       cevap.Free;
     end;
     //
   end;
   function XMLGonderPts(AIstek : TPTSSoapIstek):TGenelYanitPTS;
   var
     http : THTTPReqResp;
     i : Integer;
     cevap : TStringStream;
     PtsXml :TPTSXml;
   begin
     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TStringStream.Create;
     try
       http.URL := 'http://pts.saglik.gov.tr/PTS/PackageSenderWebService';
       http.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
       http.UseUTF8InHeader := True;
       http.SoapAction := 'PackageSenderWebService';
       http.Execute(AIstek.IcerikString,cevap);
       cevap.Position := 0;
       Result := TGenelYanitPTS.Create(cevap);
     finally
       http.Free;
       cevap.Free;
     end;
   end;
   function HataToMsg(Kod : string):string;
   Var
    i:Integer;
   begin
    Result := '';
    {for I := Low(Errors)  to High(Errors)  do
     if Errors[I].code = Kod then Exit(Errors[I].Msg);  }

    with Veritabani.SorguBaslat(Tablo.cnn,'SELECT TOP 1 ACIKLAMA FROM ITS_SERVIS_HATA WHERE KODU =$1',['$1'],[Kod] ) do
    try
      CommandTimeout := 0 ;
      Open;
      Result := FieldByName('ACIKLAMA').AsString;
    finally
        Free;
    end;

   end;

   function ITSHesapBilgileriGetir(HesapId:integer): TITSHesapAyarlari;
   begin
   with Veritabani.SorguBaslat( Tablo.cnn, 'SELECT TOP 1 * FROM ITSHESAPLARI WHERE GONDEREN =''PTS'' ',[],[] ) do
   try
    CommandTimeout:=0;
    Open;
    EczaDepolariPTSKullaniciAdi :=  FieldByName('KULLANICIADI').AsString;
    EczaDepolariPTSKullaniciSifre := FieldByName('SIFRE').AsString;
   finally
     Free;
   end;
   with Veritabani.SorguBaslat( Tablo.cnn, 'SELECT * FROM ITSHESAPLARI WHERE ID ='+inttostr(HesapId) ,[], [] ) do
   try
    CommandTimeout:=0;
    Open;
   if RecordCount<=0 then
    Result.HesapId:=-99
   else
    begin
      UItsAraclari.ServisUrlOnEki := FieldByName('SERVIS').AsString;
     { if ('EczaDepo'= FieldByName('GONDEREN').AsString) or ('EczaDepoTest'= FieldByName('GONDEREN').AsString) then
      begin
      EczaDepolariKullaniciAdi :=  FieldByName('KULLANICIADI').AsString;
      EczaDepolariKullaniciSifre := FieldByName('SIFRE').AsString;
      end;
      if ('EczaUretici'= FieldByName('GONDEREN').AsString) or ('EczaUreticiTest'= FieldByName('GONDEREN').AsString) then
      begin
      EczaUreticiKullaniciAdi   := FieldByName('KULLANICIADI').AsString;
      EczaUreticiKullaniciSifre := FieldByName('SIFRE').AsString;
      end;  }
      ITSKullaniciAdi :=  FieldByName('KULLANICIADI').AsString;
      ITSSifre        :=  FieldByName('SIFRE').AsString;
      Result.HesapId:= HesapId;
      Result.GonderenAdi := FieldByName('GONDEREN').AsString;
      Result.KullaniciAdi:= FieldByName('KULLANICIADI').AsString;
      Result.Parola:= FieldByName('SIFRE').AsString;
      Result.Sunucu:= FieldByName('SERVIS').AsString;
    end;
    finally
    Free
    end;
   end;
   procedure AlimIadeIslemleri(GTIN,SN:string);
   begin
   with Veritabani.SorguBaslat( Tablo.cnn, 'SELECT ID FROM STOKID WHERE URUNBARKOD=$1 AND SIRANO= $2 ',['$1','$2'],[GTIN,SN] ) do
    try
        CommandTimeout:=0;
        Open;
       // Tablo.Query6.sql.Clear;
       // Tablo.Query6.sql.Text:= 'UPDATE KAREKOD SET ALIM_DURUM = '''', ALIM_BILDIRIM_TARIH = '''+FormatDateTime('yyyy-MM-dd hh:nn',Now) +''' WHERE STOKIDID = '+FieldByName('ID').AsString+' ';
       // Tablo.Query6.ExecSQL;
    finally
        Free;
    end;
   end;
   procedure SatisIptalIslemleri(GTIN,SN:string);
   begin
    with Veritabani.SorguBaslat( Tablo.cnn, 'SELECT ID FROM STOKID WHERE URUNBARKOD=$1 AND SIRANO =$2 ',['$1','$2'],[GTIN,SN] ) do
    try
        CommandTimeout:=0;
        Open;
       /// Tablo.Query6.sql.Clear;
      //  Tablo.Query6.sql.Text:= 'UPDATE KAREKOD SET SATIS_DURUM = '''', SATIS_BILDIRIM_TARIH = '''+FormatDateTime('yyyy-MM-dd hh:nn',Now) +''' WHERE STOKIDID = '+FieldByName('ID').AsString+' ';
       // Tablo.Query6.ExecSQL;
    finally
        Free;
    end;
   end;


{$REGION 'Depo Doðrulama Bildirimi Web Servisi Ýslemleri'}
{Depo Ürün Doðrulama Bildirimi, Depolar tarafýndan ürünün kontrolü için kullanýlabilecek bir web servisidir.
{Ürünün sistemde bulunup bulunmadýðý, karekod bilgilerinin tutarlý olup olmadýðý, ürünün daha önceden satýlýp
satýlmadýðý gibi kontrolleri yapabilecekleri bir bildirimdir.
Kontrol iþlemi ürünler için tek tek yapýlabileceði gibi toplu halde de yapýlabilir.
Ancak doðrulama iþlemini toplu halde yapmak hem sunucularýmýzýn hem de istemci uygulamanýn
performansýný artýracak ve zamandan büyük tasarruf saðlayacaktýr.
Uygulama geliþtiricilerin doðrulama iþlemini toplu halde yapýlmasýný saðlamalarý önemlidir.
Depolar doðrulama sonucu olumlu olmayan ürünleri satýn almamalýdýrlar.}
{$ENDREGION}
{$REGION 'Depo Mal-Alým Bildirimi Web Servisi Ýslemleri'}
{Depo Mal Alým Bildirimi, üreticiden veya baþka bir depodan gelen ürünün kabulü sýrasýnda
yapýlmasý gereken bir bildirimdir. Gelen her ürün bu bildirim aracýlýðý ile depo stokuna eklenir.
Alým bildirimi yapýlmýþ bir ürün baþka bir yerde herhangi bir harekete konu olamaz.
Bu yüzden alým bildirimi yapýlan ürünlerin satýþ bildirimleri de yapýlabilmelidir.
Mal Alým Bildirimi Doðrulama Bildirimi ile ayný kontrollerden geçer ve doðrulama aþamasý
için ayný uyarý kodlarýný döndürür. Bu sebeple Eczaneye ulaþan ürünün doðrulamasý yapýlmadan
da alým bildirimi yapýlabilir.}
{$ENDREGION}
{$REGION 'Depo Mal-Ýade Bildirimi Web Servisi Ýslemleri'}
{Depo Mal Ýade Bildirimi, üreticiden veya baþka bir depodan gelen
 ve alým bildirimi yapýlmýþ bir ürünün iadesi durumunda yapýlmasý gereken bir bildirimdir.}
{$ENDREGION}
{$REGION 'Depo Mal-Satýþ Bildirimi Web Servisi Ýslemleri'}
{Depo Satýþ Bildirimi, Alým bildirimi yapýlmýþ ürünlerin baþka bir ecza deposu,
hastane veya eczaneye satýþý için kullanýlacak web servisidir. Satýþ bildirimlerinin
genel yapýsý itibariyle satýþ bildirimi yapýlmýþ bir ürün satýþ yapýlan birimin üzerine
 geçmez. Ürünün bildirimi yapan depodan çýktýðýný belirtir.
Alýcý aldýðý ürünleri üzerine kaydettirmek isterse mal alým bildirimi yapmalýdýr.}
{$ENDREGION}
{$REGION 'Depo Mal-Satýþ-Ýade Bildirimi Web Servisi Ýslemleri'}
{Depo Satýþ Ýptal Bildirimi, Satýþ bildirimi yapýlmýþ ürünlerin satýþýnýn iptal edilmesi
 için kullanýlýr. Bu bildirim sonucunda Satýþ bildirimi ile sahipliði kaybedilmiþ ürün
 tekrar deponun üzerine kaydedilir. Deponun satýþý iptal edebilmesi için ya alýcýnýn mal
 alým bildirimi yapmamýþ olmasý, eðer yapmýþsa Mal Ýade bildirimini yapmýþ olmasý gerekir.}
{$ENDREGION}
{$REGION 'DeAktivasyon Bildirimi Web Servisi Ýslemleri'}
{Çeþitli sebeplerle sistemdeki kaydýnýn çýkarýlmasý söz konusu ürünler için yapýlan
bildirimdir. Deaktivasyon Bildirimi. Üreticiler, Depolar, Eczaneler, Hastaneler ve
Sistem tarafýndan yapýlabilir. Deaktivasyon Sebebine ait kodlar için Ýlaç Takip Sistemi
Ýþletme Kýlavuzu’na bakýnýz ya da web sayfamýzý kontrol ediniz.Dikkat! Deaktivasyon
bildiriminin iptal süreci sistem tarafýndan tanýmlanmamýþtýr. Bu sebeple deaktivasyon
bildiriminin dikkatli yapýlmasý gerekmektedir.}
{$ENDREGION}


end.

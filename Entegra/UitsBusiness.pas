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
Utablo,XSBuiltIns,Dialogs,ECXMLParser,UItsAraclari,Generics.Collections;

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
  Errors : array[1..23] of UCType = (
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
( Code:'00000';Msg:'Doðru Bildirim.'));



const DurumDogru    ='00000';
const AlimDurumUzerinde ='10223';
const SatimDurumOnceden ='10204';




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
  function XMLGelenIsle (GelenYanit : TGenelYanit;GidenUrunler : TObjectList<TUrun>):string;
  procedure AlimIadeIslemleri(GTIN,SN:string);
  procedure SatisIptalIslemleri(GTIN,SN:string);
  function ITSHesapBilgileriGetir(HesapId:integer): TITSHesapAyarlari;
  function XMLGonderPts(AIstek : TPTSSoapIstek):TGenelYanit;
{$ENDREGION}

var
 {<FR>} EczaDepoGLN  :string[13] = '8680052900019'; //Doðrulamayý yapan Ecza Deposunun GLN kodunu barýndýrýr.Bu alan 13 karakter uzunluktadýr ve sadece rakamlardan oluþur.
 {--------Mal Alým Servisi için FR ürünün alýndýðý depo veya üretici to ise alan depodur
 {<FR>}  MalUretenGLN :string[13] = '8680007200010'; //Bu alan, ürünün alýndýðý depo veya üreticinin GLN numarasýný barýndýrýr.
 {<TO_>} MaliAlanEczaDepoGLN :string = '8680052900019' ; //Bu alan ürünü alan deponun GLN kodunu içerir.
 //GLN Kodu ile ilgili detaylý bilgiler ÝTS Ýþletme Kýlavuzunda bulunur.
 {---------}
 EczaDepolariKullaniciAdi   :string ='genotip';//'panates';// 'genotip';
 EczaDepolariKullaniciSifre :string ='genotip001';//'panates123';// 'genotip001';
 EczaDepolariPTSKullaniciAdi : string ; //atlas1
 EczaDepolariPTSKullaniciSifre :string ;//atlas1453


// EczaDepoGLN :string[13] =  '8680049300013' ; PANATES
implementation
uses FetaKurulusSiniflari;
   function XMLGelenIsle (GelenYanit : TGenelYanit;GidenUrunler : TObjectList<TUrun> ):string;
   var
   UrunDurum :array of  TUrunDurum;
   Urun : TUrun;
   I : integer;
   Durum , Durum_Tarih :string;
   begin
   Result := '';
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
     if GelenYanit.HataServisAdi = 'DepoSatis' then begin Durum:= 'SATIS_DURUM'; Durum_Tarih:= 'SATIS_BILDIRIM_TARIH';  end else
     if GelenYanit.HataServisAdi = 'DepoSatisIptal' then begin Durum:= 'SATIS_IPTAL_DURUM'; Durum_Tarih:= 'SATIS_IPTAL_BILDIRIM_TARIH';  end
     else begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end;
       for I := 0 to GidenUrunler.Count - 1 do
       begin
        Urun := GidenUrunler[i];
        Tablo.Query6.sql.Clear;
        Tablo.Query6.sql.Add('INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES  ');
        Tablo.Query6.SQL.Add('(''0'','''+GelenYanit.HataServisAdi+''' , ');
        Tablo.Query6.SQL.Add(''''+Urun.GTIN+''','''+Urun.SN+''' , ');
        Tablo.Query6.SQL.Add(''''+GelenYanit.FaultCode+''','''+GelenYanit.FaultString+''' , ');
        Tablo.Query6.SQL.Add(''''+FormatDateTime('yyyy-MM-dd hh:nn',Now)+''' ) ');
        Tablo.Query6.ExecSQL;
        with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT ID FROM STOKID WHERE URUNBARKOD=$1 AND SIRANO=$2 ',['$1','$2'],[GidenUrunler[i].GTIN,GidenUrunler[i].SN] ) do
        try
        ResourceOptions.CmdExecTimeout :=0;
        Open;
        Tablo.Query6.sql.Clear;
        Tablo.Query6.sql.Text:= 'UPDATE KAREKOD SET '+Durum+' = '''+GelenYanit.FaultCode+'-'+GelenYanit.FaultString+''', '+Durum_Tarih+' = '''+FormatDateTime('yyyy-MM-dd hh:nn',Now) +'''  WHERE STOKIDID = '+FieldByName('ID').AsString+' ';
        Tablo.Query6.ExecSQL;
        finally
        Free;
        end;
       end;
    end;
   end
   else
   begin
     if GelenYanit.ServisAdi = 'DepoMalAlimCevap' then begin Durum:= 'ALIM_DURUM'; Durum_Tarih:= 'ALIM_BILDIRIM_TARIH';  end;
     if GelenYanit.ServisAdi = 'DeaktivasyonBildirimCevap' then begin Durum:= 'DEAKTIVASYON_DURUM'; Durum_Tarih:= 'DEAKTIVASYON_BILDIRIM_TARIH';  end;
     if GelenYanit.ServisAdi = 'DepoDogrulamaBildirimCevap' then begin Durum:= 'DOGRULAMA_DURUM'; Durum_Tarih:= 'DOGRULAMA_TARIH';  end;
     if GelenYanit.ServisAdi = 'DepoMalIadeCevap' then begin Durum:= 'ALIM_IADE_DURUM'; Durum_Tarih:= 'ALIM_IADE_BILDIRIM_TARIH';  end;
     if GelenYanit.ServisAdi = 'SatisBildirimCevap' then begin Durum:= 'SATIS_DURUM'; Durum_Tarih:= 'SATIS_BILDIRIM_TARIH';  end;
     if GelenYanit.ServisAdi = 'SatisIptalBildirimCevap' then begin Durum:= 'SATIS_IPTAL_DURUM'; Durum_Tarih:= 'SATIS_IPTAL_BILDIRIM_TARIH';  end;
     for I := 0 to GelenYanit.UrunDurumlar.Count - 1 do
     begin
      Tablo.Query6.sql.Clear;
      Tablo.Query6.sql.Add('INSERT INTO ITS_URUNLER (BILDIRIM_ID,URUN_DURUM,URUN_BARKOD_NO,URUN_SIRA_NO,HATA_KODU,HATA_ACIKLAMA,BILDIRIM_TARIH) VALUES  ');
      Tablo.Query6.SQL.Add('('''+GelenYanit.BildirimId+''','''+GelenYanit.ServisAdi+''' , ');
      Tablo.Query6.SQL.Add(''''+GelenYanit.UrunDurumlar[I].GTIN+''','''+GelenYanit.UrunDurumlar[I].SN+''' , ');
      Tablo.Query6.SQL.Add(''''+GelenYanit.UrunDurumlar[I].UC+''','''+HataToMsg(GelenYanit.UrunDurumlar[I].UC)+''' , ');
      Tablo.Query6.SQL.Add(''''+FormatDateTime('yyyy-MM-dd hh:nn',Now)+''' ) ');
      Tablo.Query6.ExecSQL;
      with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT ID FROM STOKID WHERE URUNBARKOD=$1 AND SIRANO=$2 ',['$1','$2'],[GelenYanit.UrunDurumlar[I].GTIN,GelenYanit.UrunDurumlar[I].SN] ) do
      try
        ResourceOptions.CmdExecTimeout :=0;
        Open;
        Tablo.Query6.sql.Clear;
        Tablo.Query6.sql.Text:= 'UPDATE KAREKOD SET '+Durum+' = '''+GelenYanit.UrunDurumlar[I].UC+'-'+HataToMsg(GelenYanit.UrunDurumlar[I].UC)+''', '+Durum_Tarih+' = '''+FormatDateTime('yyyy-MM-dd hh:nn',Now) +'''  WHERE STOKIDID = '+FieldByName('ID').AsString+' ';
        Tablo.Query6.ExecSQL;
      finally
        Free;
      end;

      if (GelenYanit.ServisAdi = 'DepoMalIadeCevap') and (GelenYanit.UrunDurumlar[I].UC = '00000' ) then
      begin
        AlimIadeIslemleri(GelenYanit.UrunDurumlar[I].GTIN,GelenYanit.UrunDurumlar[I].SN);
      end;
      if (GelenYanit.ServisAdi = 'SatisIptalBildirimCevap') and ( (GelenYanit.UrunDurumlar[I].UC = '10223') or (GelenYanit.UrunDurumlar[I].UC = '00000') ) then
      begin
        SatisIptalIslemleri(GelenYanit.UrunDurumlar[I].GTIN,GelenYanit.UrunDurumlar[I].SN);
      end;
     end;
   end;
   end;
   function XMLGonder(AIstek : TSoapIstek):TGenelYanit;
   var
     http : THTTPReqResp;
     i : Integer;
     cevap : TMemoryStream;
     Etiketler,Bilgiler : TArrayOfString;
   begin

     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TMemoryStream.Create;
     try
       http.URL := AIstek.ServisUrl;
       http.UserName := EczaDepolariKullaniciAdi;
       http.Password := EczaDepolariKullaniciSifre;
       http.UseUTF8InHeader := True;
       i := Dize.TerstenAra('/',AIstek.ServisUrl);
       http.SoapAction := Copy(AIstek.ServisUrl,i + 1,(Length(AIstek.ServisUrl) - i) + 1);
       http.Execute(AIstek.IcerikString,cevap);
       cevap.Position := 0;
       Result := TGenelYanit.Create(cevap);
     finally
       http.Free;
       cevap.Free;
     end;
   end;
   function XMLGonderPts(AIstek : TPTSSoapIstek):TGenelYanit;
   var
     http : THTTPReqResp;
     i : Integer;
     cevap : TMemoryStream;
   begin
     ITSHesapBilgileriGetir(ITSHesapID);
     http := THTTPReqResp.Create(nil);
     cevap := TMemoryStream.Create;
     try
       http.URL := 'http://pts.saglik.gov.tr:80/PTS/PackageReceiverWebService';
       http.UserName := EczaDepolariPTSKullaniciAdi;
       http.Password := EczaDepolariPTSKullaniciSifre;
       http.UseUTF8InHeader := True;
       http.SoapAction := 'PackageReceiverWebService';

       http.Execute(AIstek.Icerik,cevap);
       cevap.Position := 0;
       Result := TGenelYanit.Create(cevap);
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
    for I := Low(Errors)  to High(Errors)  do
     if Errors[I].code = Kod then
      Exit(Errors[I].Msg);
   end;
   function ITSHesapBilgileriGetir(HesapId:integer): TITSHesapAyarlari;
   begin
   with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT TOP 1 * FROM ITSHESAPLARI WHERE GONDEREN =''PTS'' ',[],[] ) do
   try
    ResourceOptions.CmdExecTimeout :=0;
    Open;
    EczaDepolariPTSKullaniciAdi :=  FieldByName('KULLANICIADI').AsString;
    EczaDepolariPTSKullaniciSifre := FieldByName('SIFRE').AsString;
   finally
     Free;
   end;


   with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT * FROM ITSHESAPLARI WHERE ID ='+inttostr(HesapId) ,[], [] ) do
   try
    ResourceOptions.CmdExecTimeout :=0;
    Open;
   if RecordCount<=0 then
    Result.HesapId:=-99
   else
    begin
      UItsAraclari.ServisUrlOnEki := FieldByName('SERVIS').AsString;
      if ('EczaDepo'= FieldByName('GONDEREN').AsString) or ('EczaDepoTest'= FieldByName('GONDEREN').AsString) then
      begin
      EczaDepolariKullaniciAdi :=  FieldByName('KULLANICIADI').AsString;
      EczaDepolariKullaniciSifre := FieldByName('SIFRE').AsString;
      end;
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
   with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT ID FROM STOKID WHERE URUNBARKOD=$1 AND SIRANO= $2 ',['$1','$2'],[GTIN,SN] ) do
    try
        ResourceOptions.CmdExecTimeout :=0;
        Open;
        Tablo.Query6.sql.Clear;
        Tablo.Query6.sql.Text:= 'UPDATE KAREKOD SET ALIM_DURUM = '''', ALIM_BILDIRIM_TARIH = '''+FormatDateTime('yyyy-MM-dd hh:nn',Now) +''' WHERE STOKIDID = '+FieldByName('ID').AsString+' ';
        Tablo.Query6.ExecSQL;
    finally
        Free;
    end;
   end;
   procedure SatisIptalIslemleri(GTIN,SN:string);
   begin
    with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT ID FROM STOKID WHERE URUNBARKOD=$1 AND SIRANO =$2 ',['$1','$2'],[GTIN,SN] ) do
    try
        ResourceOptions.CmdExecTimeout :=0;
        Open;
        Tablo.Query6.sql.Clear;
        Tablo.Query6.sql.Text:= 'UPDATE KAREKOD SET SATIS_DURUM = '''', SATIS_BILDIRIM_TARIH = '''+FormatDateTime('yyyy-MM-dd hh:nn',Now) +''' WHERE STOKIDID = '+FieldByName('ID').AsString+' ';
        Tablo.Query6.ExecSQL;
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


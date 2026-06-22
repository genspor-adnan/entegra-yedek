// ************************************************************************ //
// İş       : İts WebServislerinin Kullanımı
// Başlangıc Tarihi :İsmail ACET 07-10-2011
// Encoding : UTF-8
// Codegen  : SOAP
// Version  : 1.1
// Ecza Depoları ve Hastaneler için uygulama geliştirenler testler için
// aşağıdaki GLN numaralarını kullanabilirler
// Firma GLN Numalaraları : 8680002800017, 8680016600016
// Depo GLN Numaraları    : 8680007800012, 8680007900019
// Hastane GLN Numaraları : 8680024500018, 8680018600014
// Eczane GLN Numaraları  : 8680001000001, 8680001000002
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

const {<DT>} EzcaDepoBildirimTipi = 'V';//Bu alan tek karakterlik veri içerir. İçerdiği değer “V” (Doğrulama) olacaktır. Bu alan bu mesajın Doğrulama bildirimi olduğunu belirler.
const {<DT>} EzcaDepoMalAlimBildirimTip = 'A'; //Bu alan tek karakterlik veri içerir. İçerdiği değer “A” (Alım) olacaktır. Bu alan bu mesajın Mal Alım Bildirimi olduğunu belirler.
const {<DT>} EzcaDepoMalIadeBildirimTipi = 'F'; //Bu alan tek karakterlik veri içerir. İçerdiği değer “F” (İade) olacaktır. Bu alan bu mesajın Mal Alım Bildirimi olduğunu belirler.
const {<DT>} EzcaDepoSatisBildirimTipi = 'S';//Bu alan tek karakterlik veri içerir. İçerdiği değer “S” (Satış) olacaktır. Bu alan bu mesajın Satış Bildirimi olduğunu belirler.
const {<DT>} EzcaDepoSatisIptalBildirimTipi = 'C';//Bu alan tek karakterlik veri içerir. İçerdiği değer “C” (Satış İptal) olacaktır. Bu alan bu mesajın Satış İptal Bildirimi olduğunu belirler.
const {<DT>} DeAktivasyonBildirimTipi = 'D';//Bu alan tek karakterlik veri içerir. İçerdiği değer D (Deaktivasyon) olacaktır. Bu alan bu mesajın Deaktivasyon bildirimi olduğunu belirler.

const FirmaGLNDeneme   = '8680002800017';
const DepoGLNDeneme    = '8680007800012';
const HastaneGLNDeneme = '8680024500018';
const EczaneGLNDeneme  = '8680001000001';

const DEAKTIVASYONSISTEMDENCIKARMA = '10' ;//   DeAktivasyon (<DS>) Sistemden Çıkarma
const DEAKTIVASYONFIRE             = '20' ;//   DeAktivasyon (<DS>) Üretim Fireleri
const DEAKTIVASYONGERICEKME        = '30' ;//   DeAktivasyon (<DS>) Geri Çekme Sebebiyle İmha
const DEAKTIVASYONMIAT             = '40' ;//   DeAktivasyon (<DS>) Miat Sebebiyle İmha
const DEAKTIVASYONREVIZYON         = '50' ;//   DeAktivasyon (<DS>) Revizyon
const DEAKTIVASYONSARF             = '60' ;//   DeAktivasyon (<DS>) Sarf

const
  Errors : array[1..23] of UCType = (
( Code:'11032';Msg:'Sıra Numarası Formatı Geçersiz'),
( Code:'11035';Msg:'Ürüne Ait Son Kullanım Tarihi (XD) Formatı Uyumsuz'),
( Code:'10036';Msg:'Ürüne Ait Parti Numarası (BN) Formatı Uyumsuz'),
( Code:'11037';Msg:'Ürüne ait GTIN numarası Formatı Uyumsuz'),
( Code:'10007';Msg:'Bu Sıra Numarası Zaten Kayıtlı!'),
( Code:'10008';Msg:'Tanımlanmamıs Kayıt Hatası.'),
( Code:'10201';Msg:'Belirtilen Ürün Sistemimizde Kayıtlı Değildir.'),
( Code:'10202';Msg:'Ürünün Son Kullanma Tarihi Geçmistir. (Hastaya verilemez.)'),
( Code:'10203';Msg:'Ürün Bilgileri Tutarsız.'),
( Code:'10204';Msg:'Belirtilen Ürün Önceden Satılmıstır.'),
( Code:'10205';Msg:'Bu Ürünün Satısı Yasaklanmıstır.'),
( Code:'10206';Msg:'Veritabanı Kayıt Hatası.'),
( Code:'10207';Msg:'Bu Ürün Önceden ihraç Edilmistir.'),
( Code:'10209';Msg:'Ürün Su Anda Baska Bir Eczane Stokunda Görünüyor.'),
( Code:'10210';Msg:'Ürün Stokunuzda Görünüyor.'),
( Code:'10211';Msg:'Ürün Stokunuzda Görünmüyor!'),
( Code:'10219';Msg:'Belirtilen Ürün Tarafınızdan Satılmamıstır'),
( Code:'10220';Msg:'Ürün Geri Ödeme Kurumuna Satılmıstır. Satısın Reçete Bazlı iptal Edilmesi Gerekir'),
( Code:'10221';Msg:'Ürünün Satısı iptal Edilemez.'),
( Code:'10222';Msg:'Ürün Üzerinize Kayıtlı Değil'),
( Code:'10223';Msg:'Ürün Üzerinize Kayıtlı Görünüyor'),
( Code:'10224';Msg:'Ürün Eczane Tarafından Satılmıstır.'),
( Code:'00000';Msg:'Doğru Bildirim.'));



const DurumDogru    ='00000';
const AlimDurumUzerinde ='10223';
const SatimDurumOnceden ='10204';




{$ENDREGION}
{$REGION 'Ortak Tipler' Açıklama amaçlı yapılmıştır kullanımı yoktur }

Type ItsBelgeFetaType = record
  DD : TXSDate ; //Belge Tarihi ;
  DN : string  ; //Belge Açıklaması;
end;
Type ItsUrunFetaType = record
  GTIN :  string; //Bildirilen ürüne ait (Global Trade Item Number) Küresel Ticari Ürün Numarası veya “barkod numarası”dır
  XD   : TXSDate;   { Bildirilen Ürünün Son Kullanma Tarihi bu alanda bulunur. XML-Date tipindedir.
  Son Kullanım Tarihi Bildirimin yapıldığı tarihten önceki bir tarih olamaz. }
  BN   :  string[20]; {Ürünün Parti Numarasını içerir. En fazla 20 Karakter uzunluğundadır.
  Karekoda basılan parti numarası ile aynı olmak zorundadır.
  ‘0’ ve Boşluk gibi doldurma karakterleri eklenmeyecektir.  }
  SN   :  string[20]; { Bildirime konu ürününün Sıra Numarası bu alan ile bildirilir.
  En fazla 20 karakter uzunluktadır. Ürünün karekodundaki sıra numarası ile birebir aynı olmalıdır.
  Doldurma karakterleri içermemelidir.}
end;
Type ItsUrunCevapFetatype = record
  URUNDURUM : string ;//Ürünlere ait bilgileri ve sistem tarafından işlendikten sonra verilen uyarı kodunu geri döndürür.
  GTIN :  string; //Bildirilen ürüne ait (Global Trade Item Number) Küresel Ticari Ürün Numarası veya “barkod numarası”dır
  SN   :  string[20]; { Bildirime konu ürününün Sıra Numarası bu alan ile bildirilir.
  En fazla 20 karakter uzunluktadır. Ürünün karekodundaki sıra numarası ile birebir aynı olmalıdır.
  Doldurma karakterleri içermemelidir.}
  UC   :  string[5];  //Bu alan Ürünün tekil bilgileri kaydedildikten sonra dönen uyarı kodunu barındırır.
  {Beş karakter uzunluktadır. Bu Uyarı Kodları Sistem tarafından duyurulmaktadır.
  Test süreçleri sonunda yapılacak değerlendirmeler sonrasında bu uyarı kodları değişebilir.
  Bu yüzden uygulama geliştiricilerin uyarı kodlarını işleyen mekanizmayı parametrik olacak şekilde geliştirmeleri önerilir.}
  HataKodu   : string;
  HataBaslik : string;

end;
Type ItsCevapFetaType = record
 BILDIRIMID : string[20];{Sisteme başarılı olarak ulaşmış her bildirime sistem tarafından atanan tekil bir numaradır.
 İstemcilerin verilen bu numarayı kendi sistemlerine kaydetmeleri önerilir.
 Şema tarafından kısıtlanmamış bu alan için 20 karakterlik bir alfanümerik alan ayırmaları gerekmektedir.}
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
{$REGION 'ECZA DEPOLARI TARAFINDAN KULLANILACAK WEB SERVİSLERİ.........'}
{$REGION 'Hakkında'}
{Ecza Depoları Tarafından Kullanılacak Web Servisleri
Her ne kadar Ecza Depolarının sisteme girişleri ertelenmiş olsa da isteyen ecza depolarının
sisteme dâhil olabilmelerini sağlamak için gerekli web servisleri hazırlanmıştır. Ecza depolarının
kullanabilecekleri web servisleri şunlardır:
• Depo Ürün Doğrulama
• Depo Mal Alım Bildirimi
• Depo Mal İade Bildirimi
• Depo Satış Bildirimi
• Depo Satış İptal Bildirimi
• Deaktivasyon Bildirimi
• İhracat Bildirimi
İlk aşamada Bu servislerden Ürün Doğrulama, Deaktivasyon, ve İhracat Bildirimi Depolar için önemlidir.
 Eczanelere yapacakları satışlarda sorun yaşamamaları için Üreticilerden almış oldukları ürünlerin sistemde
 kayıtlı olup olmadığını, eczane tarafından iade edilen ürünlerin ise satılabilir durumda olup olmadığını kontrol
 etmeleri için “Ürün Doğrulama” servisini kullanmak zorundadırlar. Aynı zamanda çalınan, bozulan ürünleri sistemden
 çıkarmak için Deaktivasyon bildirimine, ihracat yapıyorlarsa da İhracat bildirimine ihtiyaç duyacaklardır.
Diğer bildirimler ise ileride zorunlu hale getirileceğinden şimdiden gerekli hazırlıkları yapmaları gerekmektedir.
Alım, İade, Satış ve Satış İptal bildirimleri birbirleri ile alakalı bildirimlerdir. Bu yüzden herhangi birini kullanmak istediklerinde
diğerlerini de kullanmak zorundadırlar.
Not: Üreticilerden alınan ürünler yüksek miktarda olduğu için ürünlerin tek tek okutulması zor
olacağı düşünülmektedir. Bu yüzden koli barkodları devreye girene kadar üreticiler ve depolar
arasında sevkiyat sırasında kullanılmak üzere standart bir veri iletim formatı üzerinde çalışılmaktadır.
Deponun kendisine gelecek standart formattaki belge içerisindeki karekodları kontrol ederek
sisteme bildirebileceği bir yapı tasarlanmalıdır. Bu belgenin aynı zamanda diğer depo, hastane
ve eczanelere yapılacak sevkiyatlarda da düzenlenmesiyle alıcının işlemini kolaylaştıracaktır.}
{$ENDREGION}
  function XMLGonder(AIstek : TSoapIstek):TGenelYanit;
  function XMLGelenIsle (GelenYanit : TGenelYanit;GidenUrunler : TObjectList<TUrun>):string;
  procedure AlimIadeIslemleri(GTIN,SN:string);
  procedure SatisIptalIslemleri(GTIN,SN:string);
  function ITSHesapBilgileriGetir(HesapId:integer): TITSHesapAyarlari;
  function XMLGonderPts(AIstek : TPTSSoapIstek):TGenelYanit;
{$ENDREGION}

var
 {<FR>} EczaDepoGLN  :string[13] = '8680052900019'; //Doğrulamayı yapan Ecza Deposunun GLN kodunu barındırır.Bu alan 13 karakter uzunluktadır ve sadece rakamlardan oluşur.
 {--------Mal Alım Servisi için FR ürünün alındığı depo veya üretici to ise alan depodur
 {<FR>}  MalUretenGLN :string[13] = '8680007200010'; //Bu alan, ürünün alındığı depo veya üreticinin GLN numarasını barındırır.
 {<TO_>} MaliAlanEczaDepoGLN :string = '8680052900019' ; //Bu alan ürünü alan deponun GLN kodunu içerir.
 //GLN Kodu ile ilgili detaylı bilgiler İTS İşletme Kılavuzunda bulunur.
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


{$REGION 'Depo Doğrulama Bildirimi Web Servisi İslemleri'}
{Depo Ürün Doğrulama Bildirimi, Depolar tarafından ürünün kontrolü için kullanılabilecek bir web servisidir.
{Ürünün sistemde bulunup bulunmadığı, karekod bilgilerinin tutarlı olup olmadığı, ürünün daha önceden satılıp
satılmadığı gibi kontrolleri yapabilecekleri bir bildirimdir.
Kontrol işlemi ürünler için tek tek yapılabileceği gibi toplu halde de yapılabilir.
Ancak doğrulama işlemini toplu halde yapmak hem sunucularımızın hem de istemci uygulamanın
performansını artıracak ve zamandan büyük tasarruf sağlayacaktır.
Uygulama geliştiricilerin doğrulama işlemini toplu halde yapılmasını sağlamaları önemlidir.
Depolar doğrulama sonucu olumlu olmayan ürünleri satın almamalıdırlar.}
{$ENDREGION}
{$REGION 'Depo Mal-Alım Bildirimi Web Servisi İslemleri'}
{Depo Mal Alım Bildirimi, üreticiden veya başka bir depodan gelen ürünün kabulü sırasında
yapılması gereken bir bildirimdir. Gelen her ürün bu bildirim aracılığı ile depo stokuna eklenir.
Alım bildirimi yapılmış bir ürün başka bir yerde herhangi bir harekete konu olamaz.
Bu yüzden alım bildirimi yapılan ürünlerin satış bildirimleri de yapılabilmelidir.
Mal Alım Bildirimi Doğrulama Bildirimi ile aynı kontrollerden geçer ve doğrulama aşaması
için aynı uyarı kodlarını döndürür. Bu sebeple Eczaneye ulaşan ürünün doğrulaması yapılmadan
da alım bildirimi yapılabilir.}
{$ENDREGION}
{$REGION 'Depo Mal-İade Bildirimi Web Servisi İslemleri'}
{Depo Mal İade Bildirimi, üreticiden veya başka bir depodan gelen
 ve alım bildirimi yapılmış bir ürünün iadesi durumunda yapılması gereken bir bildirimdir.}
{$ENDREGION}
{$REGION 'Depo Mal-Satış Bildirimi Web Servisi İslemleri'}
{Depo Satış Bildirimi, Alım bildirimi yapılmış ürünlerin başka bir ecza deposu,
hastane veya eczaneye satışı için kullanılacak web servisidir. Satış bildirimlerinin
genel yapısı itibariyle satış bildirimi yapılmış bir ürün satış yapılan birimin üzerine
 geçmez. Ürünün bildirimi yapan depodan çıktığını belirtir.
Alıcı aldığı ürünleri üzerine kaydettirmek isterse mal alım bildirimi yapmalıdır.}
{$ENDREGION}
{$REGION 'Depo Mal-Satış-İade Bildirimi Web Servisi İslemleri'}
{Depo Satış İptal Bildirimi, Satış bildirimi yapılmış ürünlerin satışının iptal edilmesi
 için kullanılır. Bu bildirim sonucunda Satış bildirimi ile sahipliği kaybedilmiş ürün
 tekrar deponun üzerine kaydedilir. Deponun satışı iptal edebilmesi için ya alıcının mal
 alım bildirimi yapmamış olması, eğer yapmışsa Mal İade bildirimini yapmış olması gerekir.}
{$ENDREGION}
{$REGION 'DeAktivasyon Bildirimi Web Servisi İslemleri'}
{Çeşitli sebeplerle sistemdeki kaydının çıkarılması söz konusu ürünler için yapılan
bildirimdir. Deaktivasyon Bildirimi. Üreticiler, Depolar, Eczaneler, Hastaneler ve
Sistem tarafından yapılabilir. Deaktivasyon Sebebine ait kodlar için İlaç Takip Sistemi
İşletme Kılavuzu’na bakınız ya da web sayfamızı kontrol ediniz.Dikkat! Deaktivasyon
bildiriminin iptal süreci sistem tarafından tanımlanmamıştır. Bu sebeple deaktivasyon
bildiriminin dikkatli yapılması gerekmektedir.}
{$ENDREGION}


end.


unit UVersiyonGuncelle;
   //  genupdate.genyazilim.com/genupdate/guncelleme.aspx
   // 6  135
interface

const
  KomutNo  =  32864; // 17733;

var
  VersBaslNo  : SmallInt;

procedure VersiyonGuncelle;

implementation

uses UAnaForm,Classes, SysUtils, Utablo,GenUpdateWS,messages,Dialogs, StdCtrls,
      FetaKurulusSiniflari,StrUtils,PrjConst;

var
   komutlar : TStringList;
   GResult:ArrayOfGenUpdateWS_komutListe;

procedure VersiyonGuncelle;
var
  i,j,yapilmayanKomut,AltSorguHataSay,ToplamHataSay:integer;
begin
  yapilmayanKomut := 0;
  Tablo.TablodanSorguAc(1,'select DEGER from GENINI where BOLUM='+IntToStr(Ops_GenelOpsiyon_VersiyonNo)+' ');

  GResult:=Guncelleme.guncelleme(1,Tablo.Query1.FieldByName('DEGER').AsInteger+1,KomutNo);

  for i := 0 to Length(GResult) - 1 do begin
    AltSorguHataSay := 0;
    Tablo.GuncellemeSatiriCalistir(GResult[i].KOMUT,AltSorguHataSay);
    if AltSorguHataSay>0 then begin
      ToplamHataSay := ToplamHataSay+AltSorguHataSay;
      Inc(yapilmayanKomut);
      Tablo.OlaylarIslemleri(3,10,101,-1,0,GResult[i].VERSIYONNO,GResult[i].ACIKLAMA, 'null');
    end else
      Tablo.OlaylarIslemleri(1,10,101,-1,1,GResult[i].VERSIYONNO,GResult[i].ACIKLAMA,'null');//TUR : 1-Bilgi, 2-Uyarı, 3-Hata

    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text:= 'UPDATE GENINI SET DEGER='+IntToStr(GResult[i].VERSIYONNO)+' where BOLUM= '+IntToStr(Ops_GenelOpsiyon_VersiyonNo);
    Tablo.Query2.ExecSQL;
  end;



  if ToplamHataSay>0 then
     ToplamGuncellemeHata:= ToplamHataSay;
  //    ShowMessage( IntToStr(yapilmayanKomut)+' adet güncellemeye ait '+IntToStr(ToplamHataSay)+' adet alt sorgu yapılamamıştır.'+#13+#10+'Güncellemeler sayfasından kontrol ediniz.');

end;


end.

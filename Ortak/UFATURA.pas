unit UFatura;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
     StdCtrls, IniFiles, FetaUtil, Dialogs, SysUtils, Grids, Outline,
  ExtCtrls;

type
  TEtiket = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    FontTus: TBitBtn;
    FontDialog1: TFontDialog;
    Genis: TEdit;
    Yuksek: TEdit;
    MarjSol: TEdit;
    MarjUst: TEdit;
    SayfaUstBosluk: TEdit;
    SayfaSolBosluk: TEdit;
    YanBos: TEdit;
    AltBos: TEdit;
    GroupEtiket: TGroupBox;
    GroupYonlen: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    SayfaSagBosluk: TEdit;
    YanSay: TEdit;
    RadioDikey: TRadioButton;
    RadioYatay: TRadioButton;
    RadioSayfa: TRadioButton;
    RadioSurekli: TRadioButton;
    Image2: TImage;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FontTusClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
    Procedure DegerAtama(SiraNo:integer; AlanTuru, Tablo, AlanAdi:String;BandNo:integer;
          Sol,Ust,En,Boy:Real; Font : String; Punto : integer);
  public
    { Public declarations }
  end;

var
  Etiket: TEtiket;

implementation

uses Utabrap, UAyar, UTabDok, UTablo;

{$R *.DFM}


type
  Hata = class(Exception);
var
  EtiketTuru, EtiketYon : String[20];

Procedure TEtiket.DegerAtama(SiraNo:integer; AlanTuru, Tablo, AlanAdi:String;BandNo:integer;
          Sol,Ust,En,Boy:Real; Font : String; Punto : integer);
   Begin
      RapTablo.Ayarlar.Append;
      RapTablo.Ayarlar.FieldByName('RAPORADI').AsString := 'Etiket_';
      RapTablo.Ayarlar.FieldByName('SIRANO').AsInteger:= SiraNo;
      RapTablo.Ayarlar.FieldByName('ALANTURU').AsString := ALANTURU;
      RapTablo.Ayarlar.FieldByName('TABLO').AsString := TABLO;
      RapTablo.Ayarlar.FieldByName('ALANADI').AsString := ALANADI;
      RapTablo.Ayarlar.FieldByName('SOL').AsFloat := SOL;
      RapTablo.Ayarlar.FieldByName('UST').AsFloat := UST;
      If (En  <> 0)and(TABLO<>'BOÞLUK') Then
         RapTablo.Ayarlar.FieldByName('EN').AsFloat := En;
      If (Boy <> 0)and(TABLO<>'BOÞLUK') Then
         RapTablo.Ayarlar.FieldByName('BOY').AsFloat := BOY;
      RapTablo.Ayarlar.FieldByName('FONT').AsString := Font;
      If Punto <> 0 Then
         RapTablo.Ayarlar.FieldByName('PUNTO').AsFloat := Punto;
      If BandNo <> 0 Then
         RapTablo.Ayarlar.FieldByName('BANDNO').AsInteger := BandNo;
      RapTablo.Ayarlar.Post;
   End;

procedure TEtiket.OKBtnClick(Sender: TObject);
var
      SayfaGen, SayfaYuk, Yuk, Gen, YBos, ABos, MSol, MUst, SUstBosluk, SSolBosluk, SSagBosluk : real;
      YanYanaSay : integer;
      S    : TStringList;
begin
   if StrToInt(YanSay.Text) > 20 then begin
      ShowMessage('Yanyana etiket sayýsý 20 yi aþýyor!!!');
      ModalResult := mrNone;
   end
   else begin
//   TabloDokum.Ini.WriteString('ETIKET', 'Hitap', );
///   Tablo.RapTablo.Ayarlar.Open;
   try
      if RadioSayfa.checked then
         EtiketTuru := 'A4'
      else
         EtiketTuru := 'KULLANICI';

      if RadioDikey.checked then
         EtiketYon := '1'
      else
         EtiketYon := '2';

      YanYanaSay := StrToInt(YanSay.Text);
      SUstBosluk := StrToFloat(SayfaUstBosluk.Text);
      SSolBosluk := StrToFloat(SayfaSolBosluk.Text);
      SSagBosluk := StrToFloat(SayfaSagBosluk.Text);
      Yuk  := StrToFloat(Yuksek.Text);
      Gen  := StrToFloat(Genis.Text);
      MSol := StrToFloat(MarjSol.Text);
      MUst := StrToFloat(MarjUst.Text);
      YBos := StrToFloat(YanBos.Text);
      ABos := StrToFloat(AltBos.Text);
   except
   on exception do
      raise Hata.Create('Rakam bildiriminde hata var!');
   end;

  TabloDokum.Ini.WriteString('ETIKET','BOYUTLAR', EtiketTuru+','+EtiketYon+','+YanSay.Text+','+
       SayfaUstBosluk.Text+','+SayfaSolBosluk.Text+','+SayfaSagBosluk.Text+','+Yuksek.Text+','+
       Genis.Text+','+MarjSol.Text+','+MarjUst.Text+','+YanBos.Text+','+AltBos.Text);

     Tablo.Query1.SQL.Clear;
     Tablo.Query1.SQL.Add('Delete From Ayarlar Where RAPORADI = "ETIKET_9"');
     Tablo.Query1.ExecSQL;
     SayfaGen := SSolBosluk + YanYanaSay*Gen + (YanYanaSay-1)*YBos + SSagBosluk;
     SayfaYuk := SUstBosluk + Yuk;
     DegerAtama(1,'SAYFA', 'BOYUT', EtiketTuru, 0,0,0,SayfaGen, SayfaYuk,'',0);
//     DegerAtama(3,'SAYFA', 'BOÞLUK', '',0,0,0,0,0,'',0);
     DegerAtama(3,'SAYFA', 'BOÞLUK', '',0,SSolBosluk,SUstBosluk,SSagBosluk,0,'',0);
     DegerAtama(5,'SAYFA', 'KOLON', '',YanYanaSay,0,0,0,0,'',0);
//     if SUstBosluk > 0 then
//        DegerAtama(10,'BAND', 'SAYFABAÞI', '',0,0,0,0,SUstBosluk,'',0);
     DegerAtama(12,'BAND', 'DETAY', 'SORGU',0,0,0,0,Yuk+ABos,'',0);

     S := TStringList.Create;
     Parcala(TabloDokum.Ini.ReadString('ETIKET', 'FONT', 'Courier New,10'), S);
     DegerAtama(30,'HESAP', 'SORGU', 'EtiAdres(RAPORADI)',12,MSol,MUst,Gen-MSol,Yuk,S.Strings[0],StrToInt(S.Strings[1]));
     S.Free;
     ModalResult := mrOK;
   end;
end;


procedure TEtiket.FormShow(Sender: TObject);
var S : TStringList;
begin
   S := TStringList.Create;
   Parcala(TabloDokum.Ini.ReadString('ETIKET','BOYUTLAR','A4,1,2,0.5,0.5,0.5,3.5,7.5,0.5,1,0,0'), S);

      EtiketTuru := S.Strings[0];
      EtiketYon := S.Strings[1];
      YanSay.Text := S.Strings[2];
      SayfaUstBosluk.Text := S.Strings[3];
      SayfaSolBosluk.Text := S.Strings[4];
      SayfaSagBosluk.Text := S.Strings[5];
      Yuksek.Text := S.Strings[6];
      Genis.Text := S.Strings[7];
      MarjSol.Text := S.Strings[8];
      MarjUst.Text := S.Strings[9];
      YanBos.Text := S.Strings[10];
      AltBos.Text := S.Strings[11];
   S.Free;

      if EtiketTuru = 'A4' then
         RadioSayfa.checked := True
      else
         RadioSurekli.checked := True;

      if EtiketYon = '1' then
         RadioDikey.checked := True
      else
         RadioYatay.checked := True
end;

procedure TEtiket.FontTusClick(Sender: TObject);
var S :TStringList;
begin
  S   := TStringList.Create;
  Parcala(TabloDokum.Ini.ReadString('ETIKET', 'FONT', 'Courier New,10'), S);
  FontDialog1.Font.Name  := S.Strings[0];
  FontDialog1.Font.Size  := StrToInt(S.Strings[1]);
  S.Free;
  if FontDialog1.Execute then
     with FontDialog1.font do
          TabloDokum.Ini.WriteString('ETIKET', 'FONT', Name+','+IntToStr(Size){+','+Color+','+Style});
end;

procedure TEtiket.FormDblClick(Sender: TObject);
begin
  AyarlarDlgEkran('ETIKET_9');
end;

end.


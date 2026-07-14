unit UTeklifAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:20 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxCalendar,UTablo,
  ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, cxGraphics, cxLabel,
  cxImageComboBox, cxDBEdit, cxButtonEdit, Buttons, dxSkinLondonLiquidSky, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, DB, FireDAC.Comp.Client, dxSkinLiquidSky, cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxCoreGraphics,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TTeklifAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    Label1: TcxLabel;
    AraRevize: TcxCheckBox;
    AraTarihBas: TcxDateEdit;
    AraTarihBit: TcxDateEdit;
    AraMusteri: TcxButtonEdit;
    Label4: TcxLabel;
    AraHazirlayan: TcxButtonEdit;
    cxLabel28: TcxLabel;
    cxLabel22: TcxLabel;
    cxLabel1: TcxLabel;
    YenileTus: TSpeedButton;
    AraDurumu: TcxImageComboBox;
    AraTuru: TcxImageComboBox;
    AraKabulEdilenler: TcxCheckBox;
    AraReddedilenler: TcxCheckBox;
    AraKonusu: TcxLookupComboBox;
    TabSK: TFDQuery;
    DtsSK: TDataSource;
    cxLabel2: TcxLabel;
    AraStok: TcxTextEdit;
    LabelPNO: TcxLabel;
    AraFaturaNo: TcxTextEdit;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    ToolBarAranan: TToolBar;
    LabelTumKayitlar: TToolButton;
    LabelSonArananlar: TToolButton;
    LabelSikArananlar: TToolButton;
    procedure AraMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AraHazirlayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AraKonusuLokPropertiesInitPopup(Sender: TObject);
    procedure AraHazirlayanKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraMusteriKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraStokKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraStokMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AraFaturaNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraFaturaNoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);
  public
    { Public declarations }
  end;

implementation
      Uses PrjConst,LocOnFly;
{$R *.dfm}

{ TTeklifAramaFrame }

procedure TTeklifAramaFrame.AraFaturaNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  AraFaturaNo.PostEditValue;
end;

procedure TTeklifAramaFrame.AraFaturaNoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  AraFaturaNo.PostEditValue;
end;

procedure TTeklifAramaFrame.AraHazirlayanKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TTeklifAramaFrame.AraHazirlayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
//    st : TStringList;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID>0 then begin
    TcxButtonEdit(Sender).Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    TcxButtonEdit(Sender).Tag:=ID;
  end else
  begin
    TcxButtonEdit(Sender).Text:='';
    TcxButtonEdit(Sender).Tag:=0;
  end;{  if AButtonIndex = 0 then begin
      st := TStringList.Create;
      if Tablo.YetkiAlanindakiPersoneller(StrToInt(Kullanan), 1, Tablo.GENINI.BugunTrh, st, ModulYetki_TekSubeTum.Teklif) then begin
        TcxButtonEdit(Sender).Tag := StrToInt(st.Strings[0]);
        TcxButtonEdit(Sender).Text := st.Strings[1];
      end;
      st.Free;
  end else if AButtonIndex=1 then begin
      TcxButtonEdit(Sender).Tag := 0;
      TcxButtonEdit(Sender).Text := '';
  end;   }
//  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,nil,'');
end;

procedure TTeklifAramaFrame.AraKonusuLokPropertiesInitPopup(Sender: TObject);
begin
   TabSK.Close;
   TabSK.SQL.Text := ' select null as ID, null as KONUSU union all select SIRA as ID, ANAHTAR as KONUSU from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM='+IntToStr(Ops_Teklif_Konusu)+' order by 2'; // TcxLookupComboBox(sender).Hint
   TabSK.Open;
end;

procedure TTeklifAramaFrame.AraMusteriKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TTeklifAramaFrame.AraMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-99,AButtonIndex,nil,'');
end;

procedure TTeklifAramaFrame.AraStokKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  AraStok.PostEditValue;
end;

procedure TTeklifAramaFrame.AraStokMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  AraStok.PostEditValue;
end;

procedure TTeklifAramaFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTeklifAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTeklifAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeklifAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTeklifAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTeklifAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTeklifAramaFrame.Gorunmez;
begin

end;

procedure TTeklifAramaFrame.GorunmezOlacak;
begin

end;

procedure TTeklifAramaFrame.Gorunur;
begin

end;

procedure TTeklifAramaFrame.GorunurOlacak;
begin

end;

procedure TTeklifAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTeklifAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
//  AraTarihBit.Date := Tablo.GENINI.BugunTrh;
//  AraTarihBas.Date := AraTarihBit.Date - 20;
end;

procedure TTeklifAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeklifAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTeklifAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeklifAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TTeklifAramaFrame);
end.


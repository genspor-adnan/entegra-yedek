unit USenetAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 11:09:52}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,DateUtils,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxGraphics, cxDropDownEdit, cxImageComboBox, cxCheckBox,
  cxCalendar, cxLabel, Buttons,Utablo, cxLookAndFeels, dxCore, cxDateUtils,
  dxSkinLiquidSky;

type
  TSenetAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    btnSil: TcxButton;
    YenileTus: TSpeedButton;
    Label2: TcxLabel;
    Label3: TcxLabel;
    DateTarihBas: TcxDateEdit;
    DateTarihBit: TcxDateEdit;
    CheckTarihGor: TcxCheckBox;
    DateVadeBas: TcxDateEdit;
    DateVadeBit: TcxDateEdit;
    CheckVadeGor: TcxCheckBox;
    cxLabel7: TcxLabel;
    ComboTUR: TcxImageComboBox;
    ComboDURUM: TcxImageComboBox;
    CheckTahsilleriGor: TcxCheckBox;
    Label1: TcxLabel;
    AraKod: TcxButtonEdit;
    CheckCirolariGor: TcxCheckBox;
    CheckiptalleriGor: TcxCheckBox;
    CheckIadeleriGor: TcxCheckBox;
    procedure btnSilClick(Sender: TObject);
    procedure CheckTarihGorPropertiesEditValueChanged(Sender: TObject);
    procedure CheckVadeGorPropertiesEditValueChanged(Sender: TObject);
    procedure CheckTarihGorClick(Sender: TObject);
    procedure CheckVadeGorClick(Sender: TObject);
    procedure cxLabel7Click(Sender: TObject);
    procedure AraKodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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
      Uses LocOnFly,PrjConst;
{$R *.dfm}

{ TCekSenetAramaFrame }

procedure TSenetAramaFrame.AraKodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TSenetAramaFrame.AraKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-1,AButtonIndex,nil,'');
end;

procedure TSenetAramaFrame.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TSenetAramaFrame.btnSilClick(Sender: TObject);
var
  k : word;
begin
  AraKod.Clear;
  k := 0;
  AraKod.OnKeyUp(nil,k,[]);
end;

procedure TSenetAramaFrame.CheckTarihGorClick(Sender: TObject);
begin
  if CheckTarihGor.Checked then begin
   DateTarihBas.Date:=Now-DayOf(Now)+1;
   DateTarihBit.Date:=EndOfTheMonth(date);
  end;
end;
procedure TSenetAramaFrame.CheckTarihGorPropertiesEditValueChanged(Sender: TObject);
begin
  DateTarihBas.Enabled:= not DateTarihBas.Enabled;
  DateTarihBit.Enabled:= not DateTarihBit.Enabled;
end;

procedure TSenetAramaFrame.CheckVadeGorClick(Sender: TObject);
begin
  if CheckTarihGor.Checked then begin
   DateVadeBas.Date:=Now-DayOf(Now)+1;
   DateVadeBit.Date:=EndOfTheMonth(date);
  end;
end;

procedure TSenetAramaFrame.CheckVadeGorPropertiesEditValueChanged(Sender: TObject);
begin
  DateVadeBas.Enabled:= not DateVadeBas.Enabled;
  DateVadeBit.Enabled:= not DateVadeBit.Enabled;
end;

procedure TSenetAramaFrame.cxLabel7Click(Sender: TObject);
begin
AraKod.Text:='';
ComboTUR.Text:='';
ComboDURUM.Text:='';
DateTarihBas.Clear;
DateTarihBit.Clear;
DateVadeBas.Clear;
DateVadeBit.Clear
end;

procedure TSenetAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TSenetAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TSenetAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TSenetAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TSenetAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TSenetAramaFrame.Gorunmez;
begin

end;

procedure TSenetAramaFrame.GorunmezOlacak;
begin

end;

procedure TSenetAramaFrame.Gorunur;
begin

end;

procedure TSenetAramaFrame.GorunurOlacak;
begin

end;

procedure TSenetAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TSenetAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TSenetAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSenetAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TSenetAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSenetAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TSenetAramaFrame);
end.

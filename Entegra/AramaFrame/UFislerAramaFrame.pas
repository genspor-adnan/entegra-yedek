unit UFislerAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 11:09:52}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,DateUtils,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxGraphics, cxDropDownEdit, cxImageComboBox, cxCheckBox,
  cxCalendar, cxLabel, Buttons,Utablo, dxSkinLiquidSky, cxLookAndFeels,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxCore, cxDateUtils;

type
  TFislerAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    YenileTus: TSpeedButton;
    AraStok: TcxTextEdit;
    cxLabel2: TcxLabel;
    CalendarBas: TcxDateEdit;
    CalendarBit: TcxDateEdit;
    Label2: TcxLabel;
    Label3: TcxLabel;
    LabelSube: TcxLabel;
    ComboSube: TcxImageComboBox;
    ComboDepo: TcxImageComboBox;
    cxLabel1: TcxLabel;
    ComboTipi: TcxImageComboBox;
    cxLabel3: TcxLabel;
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

{ TCekFislerAramaFrame }

procedure TFislerAramaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TFislerAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TFislerAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFislerAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TFislerAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TFislerAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TFislerAramaFrame.Gorunmez;
begin

end;

procedure TFislerAramaFrame.GorunmezOlacak;
begin

end;

procedure TFislerAramaFrame.Gorunur;
begin

end;

procedure TFislerAramaFrame.GorunurOlacak;
begin

end;

procedure TFislerAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TFislerAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFislerAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFislerAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFislerAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFislerAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TFislerAramaFrame);
end.

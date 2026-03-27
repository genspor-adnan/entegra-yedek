unit UTalimatAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 10:00:42}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, dxSkinLondonLiquidSky, UFrameYoneticisi,
  cxCheckBox, cxDropDownEdit, cxCalendar, ExtCtrls, cxLabel,Utablo,DateUtils, cxGraphics, cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxCore, cxDateUtils;

type
  TTalimatAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    btnSil: TcxButton;
    AraKod: TcxTextEdit;
    Label1: TcxLabel;
    EditCARIID: TcxLabel;
    Panel1: TPanel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Calendar2: TcxDateEdit;
    Calendar1: TcxDateEdit;
    CheckTarihAralik: TcxCheckBox;
    procedure btnSilClick(Sender: TObject);
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

{ TTalimatAramaFrame }

procedure TTalimatAramaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Calendar1.date:=StartOfTheYear(Tablo.GENINI.BugunTrh);
  Calendar2.date:=EndOfTheDay(Tablo.GENINI.BugunTrh);

end;

procedure TTalimatAramaFrame.btnSilClick(Sender: TObject);
var
  k : word;
begin
  AraKod.Clear;
  k := 0;
  AraKod.OnKeyUp(nil,k,[]);
end;

procedure TTalimatAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTalimatAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTalimatAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTalimatAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTalimatAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTalimatAramaFrame.Gorunmez;
begin

end;

procedure TTalimatAramaFrame.GorunmezOlacak;
begin

end;

procedure TTalimatAramaFrame.Gorunur;
begin

end;

procedure TTalimatAramaFrame.GorunurOlacak;
begin

end;

procedure TTalimatAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTalimatAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTalimatAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTalimatAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTalimatAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTalimatAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TTalimatAramaFrame);
end.

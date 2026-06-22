unit UTeminatMektubuAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 09:21:48}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxLabel, cxGraphics, cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTeminatMektubuAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    btnSil: TcxButton;
    AraKod: TcxTextEdit;
    Label1: TcxLabel;
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
       Uses LocOnFly,PrjConst,Utablo;
{$R *.dfm}

{ TTeminatMektubuAramaFrame }

procedure TTeminatMektubuAramaFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTeminatMektubuAramaFrame.btnSilClick(Sender: TObject);
var
  k : word;
begin
  AraKod.Clear;
  k := 0;
  AraKod.OnKeyUp(nil,k,[]);
end;

procedure TTeminatMektubuAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTeminatMektubuAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeminatMektubuAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTeminatMektubuAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTeminatMektubuAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTeminatMektubuAramaFrame.Gorunmez;
begin

end;

procedure TTeminatMektubuAramaFrame.GorunmezOlacak;
begin

end;

procedure TTeminatMektubuAramaFrame.Gorunur;
begin

end;

procedure TTeminatMektubuAramaFrame.GorunurOlacak;
begin

end;

procedure TTeminatMektubuAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTeminatMektubuAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTeminatMektubuAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeminatMektubuAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTeminatMektubuAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeminatMektubuAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TTeminatMektubuAramaFrame);
end.

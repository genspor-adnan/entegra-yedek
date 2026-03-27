unit UDuzenliOdemeAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/06/2010 17:13:34 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, cxControls, cxContainer, cxTreeView;

type
  TDuzenliOdemeAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    TreeView1: TcxTreeView;
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

{$R *.dfm}

{ TDuzenliOdemeAramaFrame }

procedure TDuzenliOdemeAramaFrame.Baslatildi;
begin

end;

procedure TDuzenliOdemeAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDuzenliOdemeAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDuzenliOdemeAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDuzenliOdemeAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDuzenliOdemeAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDuzenliOdemeAramaFrame.Gorunmez;
begin

end;

procedure TDuzenliOdemeAramaFrame.GorunmezOlacak;
begin

end;

procedure TDuzenliOdemeAramaFrame.Gorunur;
begin

end;

procedure TDuzenliOdemeAramaFrame.GorunurOlacak;
begin

end;

procedure TDuzenliOdemeAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDuzenliOdemeAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDuzenliOdemeAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDuzenliOdemeAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDuzenliOdemeAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDuzenliOdemeAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDuzenliOdemeAramaFrame);
end.

unit UGenelGirisSayfasiFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 11:19:20}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, ExtCtrls, JvExExtCtrls,
  JvExtComponent, JvPanel,UFrameYoneticisi;

type
  TGenelGirisSayfasiFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    pnlGenel: TJvPanel;
    Label1: TLabel;
    Label4: TLabel;
    Shape1: TShape;
    procedure pnlGenelPaint(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
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
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
  public
    { Public declarations }
  end;

implementation
uses   LocOnFly,PrjConst,Utablo,
  JvJVCLUtils;

{$R *.dfm}

{ TGenelGirisSayfasiFrame }

procedure TGenelGirisSayfasiFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TGenelGirisSayfasiFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TGenelGirisSayfasiFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TGenelGirisSayfasiFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TGenelGirisSayfasiFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TGenelGirisSayfasiFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TGenelGirisSayfasiFrame.Gorunmez;
begin

end;

procedure TGenelGirisSayfasiFrame.GorunmezOlacak;
begin

end;

procedure TGenelGirisSayfasiFrame.Gorunur;
begin

end;

procedure TGenelGirisSayfasiFrame.GorunurOlacak;
begin

end;

procedure TGenelGirisSayfasiFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TGenelGirisSayfasiFrame.pnlGenelPaint(Sender: TObject);
var
  pnl : TJvPanel;
begin
  pnl := Sender as TJvPanel;
  GradientFillRect(pnl.Canvas,pnl.ClientRect,clWhite,$00FFA4A4,fdTopToBottom,255);
end;

procedure TGenelGirisSayfasiFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TGenelGirisSayfasiFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TGenelGirisSayfasiFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TGenelGirisSayfasiFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TGenelGirisSayfasiFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TGenelGirisSayfasiFrame);
end.

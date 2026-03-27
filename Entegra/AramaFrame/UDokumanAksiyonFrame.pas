unit UDokumanAksiyonFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:51:36 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi;

type
  TDokumanAksiyonFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
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

{ TDokumanAksiyonFrame }

procedure TDokumanAksiyonFrame.Baslatildi;
begin

end;

procedure TDokumanAksiyonFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumanAksiyonFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumanAksiyonFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDokumanAksiyonFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumanAksiyonFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumanAksiyonFrame.Gorunmez;
begin

end;

procedure TDokumanAksiyonFrame.GorunmezOlacak;
begin

end;

procedure TDokumanAksiyonFrame.Gorunur;
begin

end;

procedure TDokumanAksiyonFrame.GorunurOlacak;
begin

end;

procedure TDokumanAksiyonFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumanAksiyonFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDokumanAksiyonFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumanAksiyonFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumanAksiyonFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumanAksiyonFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDokumanAksiyonFrame);
end.

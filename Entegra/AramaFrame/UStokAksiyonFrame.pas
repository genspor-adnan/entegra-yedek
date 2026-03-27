unit UStokAksiyonFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:51:36 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi;

type
  TStokAksiyonFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
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
 uses LocOnFly ,PrjConst, UTablo;
{$R *.dfm}

{ TStokAksiyonFrame }

procedure TStokAksiyonFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TStokAksiyonFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TStokAksiyonFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TStokAksiyonFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TStokAksiyonFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TStokAksiyonFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TStokAksiyonFrame.Gorunmez;
begin

end;

procedure TStokAksiyonFrame.GorunmezOlacak;
begin

end;

procedure TStokAksiyonFrame.Gorunur;
begin

end;

procedure TStokAksiyonFrame.GorunurOlacak;
begin

end;

procedure TStokAksiyonFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TStokAksiyonFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TStokAksiyonFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokAksiyonFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TStokAksiyonFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokAksiyonFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TStokAksiyonFrame);
end.

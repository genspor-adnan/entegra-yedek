unit UTeklifAksiyonFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:51:29 }
interface

uses

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi;

type
  TTeklifAksiyonFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
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
     Uses LocOnFly,PrjConst, UTablo;
{$R *.dfm}

{ TTeklifAksiyonFrame }

procedure TTeklifAksiyonFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.v
end;

procedure TTeklifAksiyonFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTeklifAksiyonFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeklifAksiyonFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTeklifAksiyonFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTeklifAksiyonFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTeklifAksiyonFrame.Gorunmez;
begin

end;

procedure TTeklifAksiyonFrame.GorunmezOlacak;
begin

end;

procedure TTeklifAksiyonFrame.Gorunur;
begin

end;

procedure TTeklifAksiyonFrame.GorunurOlacak;
begin

end;

procedure TTeklifAksiyonFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTeklifAksiyonFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTeklifAksiyonFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeklifAksiyonFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTeklifAksiyonFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeklifAksiyonFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TTeklifAksiyonFrame);
end.

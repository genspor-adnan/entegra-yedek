unit UAramaYokFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, UGentegreFrameYonetimi,UFrameYoneticisi;

type
  TAramaYokFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    Label1: TLabel;
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
      Uses LocOnFly,Utablo;
{$R *.dfm}

{ TAramaYokFrame }

procedure TAramaYokFrame.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TAramaYokFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TAramaYokFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TAramaYokFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

function TAramaYokFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TAramaYokFrame.GetKapatilabilir: Boolean;
begin

end;


procedure TAramaYokFrame.Gorunmez;
begin

end;

procedure TAramaYokFrame.GorunmezOlacak;
begin

end;

procedure TAramaYokFrame.Gorunur;
begin

end;

procedure TAramaYokFrame.GorunurOlacak;
begin

end;

procedure TAramaYokFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TAramaYokFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;


procedure TAramaYokFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TAramaYokFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TAramaYokFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TAramaYokFrame.YaziciYazdir(Sender: TObject);
begin

end;


initialization
  RegisterClass(TAramaYokFrame);
end.

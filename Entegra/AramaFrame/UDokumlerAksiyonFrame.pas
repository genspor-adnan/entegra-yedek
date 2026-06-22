unit UDokumlerAksiyonFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 19/01/2010 14:31:05}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,UFrameYoneticisi;

type
  TDokumlerAksiyonFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
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

{ TDokumlerAksiyonFrame }

procedure TDokumlerAksiyonFrame.Baslatildi;
begin
    if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TDokumlerAksiyonFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumlerAksiyonFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumlerAksiyonFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDokumlerAksiyonFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumlerAksiyonFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumlerAksiyonFrame.Gorunmez;
begin

end;

procedure TDokumlerAksiyonFrame.GorunmezOlacak;
begin

end;

procedure TDokumlerAksiyonFrame.Gorunur;
begin

end;

procedure TDokumlerAksiyonFrame.GorunurOlacak;
begin

end;

procedure TDokumlerAksiyonFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumlerAksiyonFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDokumlerAksiyonFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumlerAksiyonFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumlerAksiyonFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumlerAksiyonFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDokumlerAksiyonFrame);
end.

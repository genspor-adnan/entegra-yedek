unit UBankalarDlgAracCubuguFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UGentegreFrameYonetimi;

type
  TBankalarDlgAracCubuguFrame = class(TFrame,IAracCubuguBilgiFrame)
  private
    { Private declarations }
    { IBilgiFrame üyeleri            }
    FFrameBilgi : TAracCubuguFrameBilgi;
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
    function GetFrameBilgi : TAracCubuguFrameBilgi;
    procedure SetFrameBilgi(AValue : TAracCubuguFrameBilgi);
    {********************************}
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TBankalarDlgAracCubuguFrame }

procedure TBankalarDlgAracCubuguFrame.Baslatildi;
begin

end;

procedure TBankalarDlgAracCubuguFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TBankalarDlgAracCubuguFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankalarDlgAracCubuguFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TBankalarDlgAracCubuguFrame.GetFrameBilgi: TAracCubuguFrameBilgi;
begin

end;

function TBankalarDlgAracCubuguFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TBankalarDlgAracCubuguFrame.Gorunmez;
begin

end;

procedure TBankalarDlgAracCubuguFrame.GorunmezOlacak;
begin

end;

procedure TBankalarDlgAracCubuguFrame.Gorunur;
begin

end;

procedure TBankalarDlgAracCubuguFrame.GorunurOlacak;
begin

end;

procedure TBankalarDlgAracCubuguFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TBankalarDlgAracCubuguFrame.SetFrameBilgi(
  AValue: TAracCubuguFrameBilgi);
begin

end;

procedure TBankalarDlgAracCubuguFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankalarDlgAracCubuguFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TBankalarDlgAracCubuguFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankalarDlgAracCubuguFrame.YaziciYazdir(Sender: TObject);
begin

end;

end.

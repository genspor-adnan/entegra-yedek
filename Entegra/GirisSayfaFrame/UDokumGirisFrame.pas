unit UDokumGirisFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 18/01/2010 13:55:39}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, ExtCtrls, JvExExtCtrls, JvExtComponent,
  JvPanel, UDokumAramaFrame,UFrameYoneticisi, cxGroupBox;

type
  TDokumGirisFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    pnlGenel: TJvPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Shape1: TShape;
    procedure pnlGenelPaint(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama : TDokumAramaFrame;
    FDokumEkranAdi: string;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    {----}
    procedure SetArama(const Value: TDokumAramaFrame);
    procedure SetDokumEkranAdi(const Value: string);
  public
    { Public declarations }
    Standart, Durum : Smallint;
  published
    property Arama : TDokumAramaFrame read FArama write SetArama;
    property DokumEkranAdi : string read FDokumEkranAdi write SetDokumEkranAdi;
  end;

implementation
uses
  JvJVCLUtils, FetaClassExtensions,LocOnFly,Utablo;

{$R *.dfm}

{ TDokumGirisFrame }

procedure TDokumGirisFrame.Baslatildi;
var
  a : TWinControl;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  a := FFrameBilgi.AnaFrameBilgi.AramaSayfaDenetimi.FindVisualAncestor(TcxGroupBox);
  if Assigned(a) then begin
    Label3.Top := a.Top + 45;
    Label4.Top := a.Top + 40;
  end;
end;
procedure TDokumGirisFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumGirisFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumGirisFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDokumGirisFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumGirisFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumGirisFrame.Gorunmez;
begin

end;

procedure TDokumGirisFrame.GorunmezOlacak;
begin

end;

procedure TDokumGirisFrame.Gorunur;
begin
  
end;

procedure TDokumGirisFrame.GorunurOlacak;
begin

end;

procedure TDokumGirisFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumGirisFrame.pnlGenelPaint(Sender: TObject);
var
  pnl : TJvPanel;
begin
  pnl := Sender as TJvPanel;
  GradientFillRect(pnl.Canvas,pnl.ClientRect,clWhite,$00FFA4A4,fdTopToBottom,255);
end;

procedure TDokumGirisFrame.SetArama(const Value: TDokumAramaFrame);
begin
  FArama := Value;
  with FArama do begin
    { Event Attaching  }

  end;
end;

procedure TDokumGirisFrame.SetDokumEkranAdi(const Value: string);
begin
  FDokumEkranAdi := Value;
  FArama.DokumleriYerlestir(Value, Standart, Durum);
end;

procedure TDokumGirisFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDokumGirisFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumGirisFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumGirisFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumGirisFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDokumGirisFrame);
end.

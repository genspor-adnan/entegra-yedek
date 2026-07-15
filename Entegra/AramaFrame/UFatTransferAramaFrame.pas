unit UFatTransferAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 10:00:42}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  cxCheckBox, cxDropDownEdit, cxCalendar, ExtCtrls, cxLabel,
  dxSkinLondonLiquidSky, cxGraphics, cxLookAndFeels, dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  Vcl.Buttons, cxImageComboBox, dxCoreGraphics, Vcl.ToolWin;

type
  TFatTransferAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    AraKod: TcxTextEdit;
    Label1: TcxLabel;
    EditCARIID: TcxLabel;
    AraStok: TcxTextEdit;
    cxLabel2: TcxLabel;
    CalendarBas: TcxDateEdit;
    CalendarBit: TcxDateEdit;
    Label2: TcxLabel;
    Label3: TcxLabel;
    LabelTeslimEden: TcxLabel;
    LabelTeslimAlan: TcxLabel;
    LabelTransferNo: TcxLabel;
    LabelUretimEmirNo: TcxLabel;
    LabelOzelKod: TcxLabel;
    EditTeslimEden: TcxButtonEdit;
    EditTeslimAlan: TcxButtonEdit;
    AraTransferNo: TcxTextEdit;
    AraUretimEmirNo: TcxTextEdit;
    AraOzelKod: TcxTextEdit;
    YenileTus: TSpeedButton;
    ToolBarAranan: TToolBar;
    LabelTumKayitlar: TToolButton;
    LabelSonArananlar: TToolButton;
    LabelSikArananlar: TToolButton;
    procedure btnSilClick(Sender: TObject);
    procedure EditTeslimPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

{ TFatTransferAramaFrame }

procedure TFatTransferAramaFrame.Baslatildi;
begin
     LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TFatTransferAramaFrame.btnSilClick(Sender: TObject);
var
  k : word;
begin
  AraKod.Clear;
  k := 0;
  AraKod.OnKeyUp(nil,k,[]);
end;

procedure TFatTransferAramaFrame.EditTeslimPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  ID  : Integer;
  Edt : TcxButtonEdit;
begin
  Edt := Sender as TcxButtonEdit;
  if AButtonIndex = 0 then begin           // sec (ellipsis)
    ID := Tablo.RehberAra_IDGetir(335);    // personel secim dialogu (wizard ile ayni GRUP)
    if ID > 0 then begin
      Edt.Tag  := ID;                      // secilen REHBER id -> .Tag (filtrede kullanilir)
      Edt.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    end;
  end else begin                           // temizle (-)
    Edt.Tag  := 0;
    Edt.Text := '';
  end;
end;

procedure TFatTransferAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TFatTransferAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFatTransferAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TFatTransferAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TFatTransferAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TFatTransferAramaFrame.Gorunmez;
begin

end;

procedure TFatTransferAramaFrame.GorunmezOlacak;
begin

end;

procedure TFatTransferAramaFrame.Gorunur;
begin

end;

procedure TFatTransferAramaFrame.GorunurOlacak;
begin

end;

procedure TFatTransferAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TFatTransferAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFatTransferAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFatTransferAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFatTransferAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFatTransferAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TFatTransferAramaFrame);
end.

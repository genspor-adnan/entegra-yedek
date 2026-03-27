unit UUretimAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:46:01 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxGraphics, cxCheckBox, cxMaskEdit, cxDropDownEdit,Utablo,DateUtils,
  cxControls, cxContainer, cxEdit, cxTextEdit, dxSkinLondonLiquidSky,
  cxLookAndFeelPainters, cxButtons, cxImageComboBox, cxLabel, cxCalendar, Buttons, Spin, cxSpinEdit, cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine,
  dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue, dxCore, cxDateUtils;

type
  TUretimAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    LabelTumKayitlar: TcxLabel;
    DateBas: TcxDateEdit;
    DateBitis: TcxDateEdit;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel1: TcxLabel;
    EditUretimNo: TcxTextEdit;
    YenileTus: TSpeedButton;
    LabelSube: TcxLabel;
    ComboSube: TcxImageComboBox;
    cxLabel3: TcxLabel;
    EditStokAdi: TcxTextEdit;
    cxLabel5: TcxLabel;
    EditUretimID: TcxTextEdit;
    cxLabel6: TcxLabel;
    EditStokKodu: TcxTextEdit;
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
uses
UStokListeDlg,PrjConst,LocOnFly;

{$R *.dfm}

{ TUretimAramaFrame }

procedure TUretimAramaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  ComboSube.Visible := SubeVarmi;
  LabelSube.Visible := SubeVarmi;
  DateBas.EditValue := Tablo.GENINI.BugunTrh;
  DateBas.PostEditValue;
  DateBitis.EditValue := Tablo.GENINI.BugunTrh;
  DateBitis.PostEditValue;


end;


procedure TUretimAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TUretimAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TUretimAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TUretimAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TUretimAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TUretimAramaFrame.Gorunmez;
begin

end;

procedure TUretimAramaFrame.GorunmezOlacak;
begin

end;

procedure TUretimAramaFrame.Gorunur;
begin
end;



procedure TUretimAramaFrame.GorunurOlacak;
begin

end;

procedure TUretimAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TUretimAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TUretimAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TUretimAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TUretimAramaFrame);
end.

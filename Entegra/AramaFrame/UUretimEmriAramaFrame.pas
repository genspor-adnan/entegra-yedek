unit UUretimEmriAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:46:01 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, ToolWin, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxGraphics, cxCheckBox, cxMaskEdit, cxDropDownEdit,Utablo,DateUtils,
  cxControls, cxContainer, cxEdit, cxTextEdit, dxSkinLondonLiquidSky,
  cxLookAndFeelPainters, cxButtons, cxImageComboBox, cxLabel, cxCalendar, Buttons, Spin, cxSpinEdit, cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine,
  dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue, dxCore, cxDateUtils,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TUretimEmriAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    ToolBarAranan: TToolBar;
    LabelTumKayitlar: TToolButton;
    LabelSonArananlar: TToolButton;
    LabelSikArananlar: TToolButton;
    DateBas: TcxDateEdit;
    DateBitis: TcxDateEdit;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel1: TcxLabel;
    EditUretimNo: TcxTextEdit;
    YenileTus: TSpeedButton;
    CheckPasifler: TcxCheckBox;
    cxLabel5: TcxLabel;
    EditUretimID: TcxTextEdit;
    cxLabel3: TcxLabel;
    EditStokAdi: TcxTextEdit;
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

{ TUretimEmriAramaFrame }

procedure TUretimEmriAramaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  DateBas.EditValue := StartOfTheYear(Tablo.GENINI.BugunTrh);
  DateBas.PostEditValue;
  DateBitis.EditValue := EndOfTheYear(Tablo.GENINI.BugunTrh);
  DateBitis.PostEditValue;


end;


procedure TUretimEmriAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TUretimEmriAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TUretimEmriAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TUretimEmriAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TUretimEmriAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TUretimEmriAramaFrame.Gorunmez;
begin

end;

procedure TUretimEmriAramaFrame.GorunmezOlacak;
begin

end;

procedure TUretimEmriAramaFrame.Gorunur;
begin
end;



procedure TUretimEmriAramaFrame.GorunurOlacak;
begin

end;

procedure TUretimEmriAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TUretimEmriAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TUretimEmriAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimEmriAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TUretimEmriAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimEmriAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TUretimEmriAramaFrame);
end.

unit uSocialAramaFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UGentegreFrameYonetimi, cxGraphics, StdCtrls, cxMaskEdit, cxDropDownEdit,
  cxControls, cxContainer, cxEdit, cxTextEdit, dxSkinsCore, UFrameYoneticisi,
  cxCheckBox, dxSkinLondonLiquidSky, cxDBEdit, DB, FireDAC.Comp.Client, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, cxLabel, cxImageComboBox, cxButtonEdit,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinLiquidSky, cxSpinEdit, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  Vcl.ExtCtrls, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, Vcl.ComCtrls, Vcl.ToolWin,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxCore, cxDateUtils, cxCalendar, Vcl.Menus;

type
  TSocialAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    AraFirma: TcxTextEdit;
    LabelPNO: TcxLabel;
    TabSK: TFDQuery;
    DtsSK: TDataSource;
    Label7: TcxLabel;
    ComboSinif: TcxImageComboBox;
    SpinKayitSayisi: TcxSpinEdit;
    cxLabel6: TcxLabel;
    ToolBar6: TToolBar;
    LabelTumKayitlar: TToolButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    dateEnd: TcxDateEdit;
    dateStart: TcxDateEdit;
    cxLabel3: TcxLabel;
    AraSehir: TcxTextEdit;
    comboTemsilci: TcxButtonEdit;
    lbl6: TcxLabel;
    AraUlke: TcxTextEdit;
    cxLabel4: TcxLabel;
    CheckFilreSatiri: TcxCheckBox;
    CheckPasifKayitlar: TcxCheckBox;
    buttonYenile: TToolButton;
    PopupMenu1: TPopupMenu;
    mnuMetaYenile: TMenuItem;
    mnuWebFormYenile: TMenuItem;
    N1: TMenuItem;
    mnuTumunuYenile: TMenuItem;
    CheckGroupBox: TcxCheckBox;
    procedure comboTemsilciPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure comboTemsilciKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
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
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses Utablo,LocOnFly;
{ TSocialAramaFrame }


procedure TSocialAramaFrame.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
//  ComboCariAnaliz.Visible := Tablo.YetkiVarMi(220190,1,False);
//  LabelAnaliz.Visible := ComboCariAnaliz.Visible;
  SpinKayitSayisi.text := GenRegIni.RegReadString('CariOpsiyon', 'ListeKayitSayisi', '200', 'C');
//  CheckPotansiyel.checked := GenRegIni.RegReadString('CariOpsiyon', 'CariPotansiyelAra', '0', 'C')='-1';
end;

procedure TSocialAramaFrame.comboTemsilciKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TSocialAramaFrame.comboTemsilciPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID>0 then begin
    TcxButtonEdit(Sender).Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    TcxButtonEdit(Sender).Tag:=ID;
  end else
  begin
    TcxButtonEdit(Sender).Text:='';
    TcxButtonEdit(Sender).Tag:=0;
  end;
end;

procedure TSocialAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TSocialAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TSocialAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TSocialAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TSocialAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TSocialAramaFrame.Gorunmez;
begin

end;

procedure TSocialAramaFrame.GorunmezOlacak;
begin

end;

procedure TSocialAramaFrame.Gorunur;
begin

end;

procedure TSocialAramaFrame.GorunurOlacak;
begin

end;

procedure TSocialAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;


procedure TSocialAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TSocialAramaFrame.SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   GenRegIni.RegWriteString('CariOpsiyon', 'ListeKayitSayisi', SpinKayitSayisi.text, 'C');
end;

procedure TSocialAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSocialAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TSocialAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSocialAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;
initialization
  RegisterClass(TSocialAramaFrame);
end.


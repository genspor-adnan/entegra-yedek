unit UCekAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 11:09:52}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxLabel, cxCheckBox, cxDropDownEdit, cxCalendar,
  cxGraphics, cxImageComboBox, cxDBEdit, Buttons,DateUtils, cxLookAndFeels, dxCore, cxDateUtils,
  dxSkinLiquidSky, dxSkinscxPCPainter, cxPCdxBarPopupMenu, Vcl.ExtCtrls, cxGroupBox, cxCheckGroup, cxPC, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, dxBarBuiltInMenu, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxCoreGraphics,
  Vcl.ToolWin;

type
  TCekAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    PCCekTurleri: TcxPageControl;
    SheetAlinanCekler: TcxTabSheet;
    SheetVerilenCekler: TcxTabSheet;
    cgAlinanCekler: TcxCheckGroup;
    cgVerilenCekler: TcxCheckGroup;
    Panel1: TPanel;
    Label1: TcxLabel;
    DateVadeBas: TcxDateEdit;
    DateVadeBit: TcxDateEdit;
    CheckVadeGor: TcxCheckBox;
    AraKod: TcxButtonEdit;
    AraSeriNo: TcxTextEdit;
    cxLabel1: TcxLabel;
    YenileTus: TSpeedButton;
    ToolBarAranan: TToolBar;
    LabelTumKayitlar: TToolButton;
    LabelSonArananlar: TToolButton;
    LabelSikArananlar: TToolButton;
    procedure btnSilClick(Sender: TObject);
    procedure CheckVadeGorPropertiesEditValueChanged(Sender: TObject);
    procedure CheckVadeGorClick(Sender: TObject);
    procedure AraKodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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
Uses
Utablo,LocOnFly;

{$R *.dfm}

{ TCekSenetAramaFrame }

procedure TCekAramaFrame.AraKodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key in [ VK_DELETE,VK_BACK] then begin
      TcxButtonEdit(Sender).Tag := 0;
      TcxButtonEdit(Sender).Text := '';
   end;
end;

procedure TCekAramaFrame.AraKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-1,AButtonIndex,nil,'');
end;

procedure TCekAramaFrame.Baslatildi;
var i : smallint;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
                                             {
   for i := 0 to cgAlinanCekler.Properties.Items.Count-1 do
      if GenRegIni.RegReadString('CekOpsiyon', IntToStr(cgAlinanCekler.Properties.Items[i].Tag), 'True', 'C')='True' then
         cgAlinanCekler.States[i] := cbsChecked; }
{
     if cgAlinanCekler.States[i] = cbsChecked then
         Result := Result + ',' + IntToStr(cgAlinanCekler.Properties.Items[i].Tag);
}
end;

procedure TCekAramaFrame.btnSilClick(Sender: TObject);
var
  k : word;
begin
  AraKod.Clear;
  k := 0;
  AraKod.OnKeyUp(nil,k,[]);
end;

procedure TCekAramaFrame.CheckVadeGorClick(Sender: TObject);
begin
  if CheckVadeGor.Checked then begin
    DateVadeBas.Date:=Now-DayOf(Now)+1;
    DateVadeBit.Date:=EndOfTheMonth(date);
  end;
end;

procedure TCekAramaFrame.CheckVadeGorPropertiesEditValueChanged(
  Sender: TObject);
begin
  DateVadeBas.Enabled:= not DateVadeBas.Enabled;
  DateVadeBit.Enabled:= not DateVadeBit.Enabled;
end;

procedure TCekAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TCekAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TCekAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TCekAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TCekAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TCekAramaFrame.Gorunmez;
begin

end;

procedure TCekAramaFrame.GorunmezOlacak;
begin

end;

procedure TCekAramaFrame.Gorunur;
begin

end;

procedure TCekAramaFrame.GorunurOlacak;
begin

end;

procedure TCekAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TCekAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TCekAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCekAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TCekAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCekAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TCekAramaFrame);
end.

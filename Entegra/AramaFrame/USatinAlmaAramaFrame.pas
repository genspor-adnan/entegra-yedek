unit USatinAlmaAramaFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:20 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxCalendar,UTablo,
  ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, cxGraphics, cxLabel,
  cxImageComboBox, cxDBEdit, cxButtonEdit, Buttons, dxSkinLondonLiquidSky, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, DB, FireDAC.Comp.Client, dxSkinLiquidSky, cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TSatinAlmaAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    Label1: TcxLabel;
    AraRevize: TcxCheckBox;
    AraTarihBas: TcxDateEdit;
    AraTarihBit: TcxDateEdit;
    AraMusteri: TcxButtonEdit;
    Label4: TcxLabel;
    AraHazirlayan: TcxButtonEdit;
    cxLabel28: TcxLabel;
    cxLabel22: TcxLabel;
    cxLabel1: TcxLabel;
    AraIkiTarih: TcxCheckBox;
    YenileTus: TSpeedButton;
    AraDurumu: TcxImageComboBox;
    AraTuru: TcxImageComboBox;
    AraKabulEdilenler: TcxCheckBox;
    AraReddedilenler: TcxCheckBox;
    AraKonusu: TcxLookupComboBox;
    TabSK: TFDQuery;
    DtsSK: TDataSource;
    procedure AraMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AraHazirlayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AraIkiTarihPropertiesEditValueChanged(Sender: TObject);
    procedure AraKonusuLokPropertiesInitPopup(Sender: TObject);
    procedure AraHazirlayanKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraMusteriKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
   Uses LocOnFly,PrjConst;
{$R *.dfm}

{ TTeklifAramaFrame }

procedure TSatinAlmaAramaFrame.AraHazirlayanKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TSatinAlmaAramaFrame.AraHazirlayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,nil,'');
end;

procedure TSatinAlmaAramaFrame.AraIkiTarihPropertiesEditValueChanged(Sender: TObject);
begin
  AraTarihBas.Enabled:= not AraTarihBas.Enabled;
  AraTarihBit.Enabled:= not AraTarihBit.Enabled;
end;

procedure TSatinAlmaAramaFrame.AraKonusuLokPropertiesInitPopup(Sender: TObject);
begin
   TabSK.Close;
   TabSK.SQL.Text := ' select null as ID, null as KONUSU union all select SIRA as ID, ANAHTAR as KONUSU from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM='+IntToStr(Ops_Teklif_Konusu)+' order by 2'; // TcxLookupComboBox(sender).Hint
   TabSK.Open;
end;

procedure TSatinAlmaAramaFrame.AraMusteriKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TSatinAlmaAramaFrame.AraMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-99,AButtonIndex,nil,'');
end;

procedure TSatinAlmaAramaFrame.Baslatildi;
begin

end;

procedure TSatinAlmaAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TSatinAlmaAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TSatinAlmaAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TSatinAlmaAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TSatinAlmaAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TSatinAlmaAramaFrame.Gorunmez;
begin

end;

procedure TSatinAlmaAramaFrame.GorunmezOlacak;
begin

end;

procedure TSatinAlmaAramaFrame.Gorunur;
begin

end;

procedure TSatinAlmaAramaFrame.GorunurOlacak;
begin

end;

procedure TSatinAlmaAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TSatinAlmaAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TSatinAlmaAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSatinAlmaAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TSatinAlmaAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSatinAlmaAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TSatinAlmaAramaFrame);
end.


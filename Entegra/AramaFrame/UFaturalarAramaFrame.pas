unit UFaturalarAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 10:00:42}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  cxCheckBox, cxDropDownEdit, cxCalendar, ExtCtrls, cxLabel,
  dxSkinLondonLiquidSky,Utablo, cxRadioGroup, cxGraphics, cxLookAndFeels, dxSkinLiquidSky, dxCore, cxDateUtils, cxSpinEdit, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxCoreGraphics;

type
  TFaturalarAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    EditCARIID: TcxLabel;
    Panel1: TPanel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Calendar2: TcxDateEdit;
    Calendar1: TcxDateEdit;
    CheckTarihAralik: TcxCheckBox;
    AraFaturaNo: TcxTextEdit;
    AraAciklama: TcxTextEdit;
    LabelPNO: TcxLabel;
    Label4: TcxLabel;
    Label6: TcxLabel;
    cxLabel1: TcxLabel;
    AraStok: TcxTextEdit;
    AraKod: TcxButtonEdit;
    cxLabel2: TcxLabel;
    AraBaslik: TcxTextEdit;
    RbGunluk: TcxRadioButton;
    RbAylik: TcxRadioButton;
    RbHaftalik: TcxRadioButton;
    SpinKayitSayisi: TcxSpinEdit;
    cxLabel3: TcxLabel;
    CheckEkAlanlarListelensin: TcxCheckBox;
    procedure btnSilClick(Sender: TObject);
    procedure AraKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AraKodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
        Uses LocOnfly,PrjConst;
{$R *.dfm}

{ TFaturalarAramaFrame }

procedure TFaturalarAramaFrame.AraKodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TFaturalarAramaFrame.AraKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-1,AButtonIndex,nil,'');
end;

procedure TFaturalarAramaFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   SpinKayitSayisi.text := GenRegIni.RegReadString('AlisSatisOpsiyon', 'BelgeListeKayitSayisi', '200', 'C');
end;

procedure TFaturalarAramaFrame.btnSilClick(Sender: TObject);
var
  k : word;
begin
  AraFaturaNo.Clear;
  AraKod.Clear;
  AraAciklama.Clear;
  k := 0;
  AraKod.OnKeyUp(nil,k,[]);
end;

procedure TFaturalarAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TFaturalarAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFaturalarAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TFaturalarAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TFaturalarAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TFaturalarAramaFrame.Gorunmez;
begin

end;

procedure TFaturalarAramaFrame.GorunmezOlacak;
begin

end;

procedure TFaturalarAramaFrame.Gorunur;
begin

end;

procedure TFaturalarAramaFrame.GorunurOlacak;
begin

end;

procedure TFaturalarAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TFaturalarAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFaturalarAramaFrame.SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   GenRegIni.RegWriteString('AlisSatisOpsiyon', 'BelgeListeKayitSayisi', VarToStr(SpinKayitSayisi.Text), 'C');
   //SpinKayitSayisi.PostEditValue;
end;

procedure TFaturalarAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFaturalarAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFaturalarAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFaturalarAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TFaturalarAramaFrame);
end.

unit UGunlukAksiyonAramaFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 05/01/2010 10:14:00}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, cxCheckBox,
  cxDropDownEdit, cxCalendar,UFrameYoneticisi, Buttons, dxSkinLondonLiquidSky,
  cxGraphics, cxLookAndFeels, dxCore, cxDateUtils, cxLabel, cxImageComboBox,
  cxDBEdit, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  TGunlukAksiyonAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    CheckBanka: TcxCheckBox;
    CheckKasa: TcxCheckBox;
    CheckFat: TcxCheckBox;
    CheckPlan: TcxCheckBox;
    CheckCekSenet: TcxCheckBox;
    CheckTop: TcxCheckBox;
    Calendar1: TcxDateEdit;
    YenileTus: TSpeedButton;
    ComboSube: TcxImageComboBox;
    LabelSube: TcxLabel;
    cxLabel1: TcxLabel;
    Calendar2: TcxDateEdit;
    cxLabel2: TcxLabel;
    procedure CheckTopClick(Sender: TObject);
    procedure Calendar1PropertiesCloseUp(Sender: TObject);
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

{$R *.dfm}

uses UTablo,LocOnFly,PrjConst;

{ TGunlukAksiyonAramaFrame }

procedure TGunlukAksiyonAramaFrame.Baslatildi;
var s:string;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   ComboSube.Visible := SubeVarmi;
   LabelSube.Visible := ComboSube.Visible;
   if ComboSube.Visible then begin
      S:= 'Select ID=0,FIRMA='''' union all select R.ID,R.FIRMA from REHBER R ';
      if TamYetkili then
         s:=s+' where R.ID<0'
      else
         s:=s+'inner join YETKI Y on convert(int,(''2398''+convert(varchar(10),-R.ID)))=Y.MODULID where R.ID<0 and Y.ROLID='+RolId+' and Y.HAK=1 ';
      ComboSube.Properties.Items := Tablo.imgComboboxInit(S).Items;
      ComboSube.EditValue := SubeId;
   end;
end;

procedure TGunlukAksiyonAramaFrame.Calendar1PropertiesCloseUp(Sender: TObject);
begin
   Calendar2.Date := Calendar1.Date;
end;

procedure TGunlukAksiyonAramaFrame.CheckTopClick(Sender: TObject);
begin
  {TKasaDlg.Toplam.Close;
  TKasaDlg.Toplam.Params[0].Value := FormatDateTime('YYYY-MM-DD 00:00', Calendar1.Date);
  TKasaDlg.Toplam.Params[1].Value := FormatDateTime('YYYY-MM-DD 23:59', Calendar1.Date);
  TKasaDlg.Toplam.Open;
//  TKasaDlg.Toplam.FieldByName('GIREN').AsCurrency.displayformat := '###,###,###,###.##'
  TKasaDlg.PanelToplam.Height := 24 + TKasaDlg.Toplam.RecordCount * 20;
  if TKasaDlg.PanelToplam.Height > 240 then TKasaDlg.PanelToplam.Height := 200; }
end;

procedure TGunlukAksiyonAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TGunlukAksiyonAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TGunlukAksiyonAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TGunlukAksiyonAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TGunlukAksiyonAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TGunlukAksiyonAramaFrame.Gorunmez;
begin

end;

procedure TGunlukAksiyonAramaFrame.GorunmezOlacak;
begin

end;

procedure TGunlukAksiyonAramaFrame.Gorunur;
begin

end;

procedure TGunlukAksiyonAramaFrame.GorunurOlacak;
begin

end;

procedure TGunlukAksiyonAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TGunlukAksiyonAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TGunlukAksiyonAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TGunlukAksiyonAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TGunlukAksiyonAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TGunlukAksiyonAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TGunlukAksiyonAramaFrame);
end.


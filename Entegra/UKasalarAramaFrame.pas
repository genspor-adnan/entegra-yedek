unit UKasalarAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 02/03/2010 16:37:08 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  cxLookAndFeelPainters, cxButtons, cxGraphics, cxControls, cxLookAndFeels,
  cxContainer, cxEdit, dxSkinsCore, dxSkinLondonLiquidSky, cxLabel, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxDBEdit, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  Vcl.Buttons;

type
  TKasalarAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    LabelSube: TcxLabel;
    YenileTus: TSpeedButton;
    ComboSube: TcxImageComboBox;
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

uses UTablo,LocOnFly;

{ TKasalarAramaFrame }

procedure TKasalarAramaFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   ComboSube.Visible := SubeVarmi;
   LabelSube.Visible := ComboSube.Visible;
   if ComboSube.Visible then begin
      ComboSube.Properties.Items := Tablo.imgComboboxInit('Select ID=0,FIRMA='''' union all select R.ID,R.FIRMA from REHBER R inner join YETKI Y on convert(int,(''2398''+convert(varchar(10),-R.ID)))=Y.MODULID where R.ID<0 and Y.ROLID='+RolId+' and Y.HAK=1 ').Items;
      ComboSube.EditValue := SubeId;
   end;
end;

procedure TKasalarAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TKasalarAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasalarAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKasalarAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKasalarAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TKasalarAramaFrame.Gorunmez;
begin

end;

procedure TKasalarAramaFrame.GorunmezOlacak;
begin

end;

procedure TKasalarAramaFrame.Gorunur;
begin

end;

procedure TKasalarAramaFrame.GorunurOlacak;
begin

end;

procedure TKasalarAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TKasalarAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKasalarAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKasalarAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKasalarAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKasalarAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TKasalarAramaFrame);
end.

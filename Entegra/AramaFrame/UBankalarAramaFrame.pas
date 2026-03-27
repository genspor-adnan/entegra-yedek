unit UBankalarAramaFrame;
		
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxLabel, cxGraphics, cxLookAndFeels, cxDropDownEdit,
  cxImageComboBox, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  Vcl.Buttons, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, cxCheckBox;

type
  TBankalarAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    AraKod: TcxTextEdit;
    cxLabel1: TcxLabel;
    LabelSube: TcxLabel;
    ComboSube: TcxImageComboBox;
    YenileTus: TSpeedButton;
    CheckPasifler: TcxCheckBox;
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

{ TBankalarAramaFrame }

procedure TBankalarAramaFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   ComboSube.Visible := SubeVarmi;
   LabelSube.Visible := ComboSube.Visible;
   if ComboSube.Visible then begin
      ComboSube.Properties.Items := Tablo.imgComboboxInit('Select ID=0,FIRMA='''' union all select R.ID,R.FIRMA from REHBER R inner join YETKI Y on convert(int,(''2598''+convert(varchar(10),-R.ID)))=Y.MODULID where R.ID<0 and Y.ROLID='+RolId+' and Y.HAK=1 ').Items;
      ComboSube.EditValue := SubeId;
   end;
end;

procedure TBankalarAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TBankalarAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankalarAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TBankalarAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TBankalarAramaFrame.GetKapatilabilir: Boolean;
begin

end;


procedure TBankalarAramaFrame.Gorunmez;
begin

end;

procedure TBankalarAramaFrame.GorunmezOlacak;
begin

end;

procedure TBankalarAramaFrame.Gorunur;
begin

end;

procedure TBankalarAramaFrame.GorunurOlacak;
begin

end;

procedure TBankalarAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TBankalarAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;


procedure TBankalarAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankalarAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TBankalarAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankalarAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TBankalarAramaFrame);
end.

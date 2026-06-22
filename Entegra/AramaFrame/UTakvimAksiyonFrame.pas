unit UTakvimAksiyonFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 16/01/2010 13:09:48}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,  cxDropDownEdit, cxCalendar, Buttons,
  cxCheckBox,UFrameYoneticisi,Utablo, dxSkinsCore, dxSkinLondonLiquidSky,
  cxGroupBox, cxRadioGroup, cxCheckGroup, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  cxGraphics, cxLookAndFeels, dxCore, cxDateUtils, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxImage, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  TTakvimAksiyonFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    DateTakvimBitTar: TcxDateEdit;
    DateTakvimBasTar: TcxDateEdit;
    CheckGroupSecim: TcxRadioGroup;
    GiderFiltreCheck: TcxCheckGroup;
    DateGrafikBitTar: TcxDateEdit;
    DateGrafikBasTar: TcxDateEdit;
    GelirFiltreCheck: TcxCheckGroup;
    YenileTus: TcxButton;
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

{ TTakvimAksiyonFrame }

procedure TTakvimAksiyonFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTakvimAksiyonFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTakvimAksiyonFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTakvimAksiyonFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTakvimAksiyonFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTakvimAksiyonFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTakvimAksiyonFrame.Gorunmez;
begin

end;

procedure TTakvimAksiyonFrame.GorunmezOlacak;
begin

end;

procedure TTakvimAksiyonFrame.Gorunur;
begin

end;

procedure TTakvimAksiyonFrame.GorunurOlacak;
begin

end;

procedure TTakvimAksiyonFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTakvimAksiyonFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTakvimAksiyonFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTakvimAksiyonFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTakvimAksiyonFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTakvimAksiyonFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TTakvimAksiyonFrame);
end.

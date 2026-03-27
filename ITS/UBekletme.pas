unit UBekletme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit,
  cxProgressBar,  //IWVCLBaseControl, IWBaseControl,IWBaseHTMLControl, IWControl, IWCompProgressBar,
  cxLabel, dxSkinBlack, dxSkinBlue, dxSkinCoffee, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlueprint,
  dxSkinCaramel, dxSkinDarkRoom, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast,
   dxSkinOffice2007Blue,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver,
   dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2010Black;

type
  TBekletmeDlg = class(TForm)
    cxProgressBar1: TcxProgressBar;
    LabelUstTaraf: TcxLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BekletmeDlg: TBekletmeDlg;

implementation

{$R *.dfm}

end.

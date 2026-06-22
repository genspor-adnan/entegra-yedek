unit UPrinter;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, CheckLst, Printers, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxLabel,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TPrinterDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TcxLabel;
    UpDown1: TUpDown;
    Kopya: TEdit;
    ListBox1: TListBox;
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PrinterDlg: TPrinterDlg;

implementation
  Uses
    PrjConst,LocOnFly, UTablo;

{$R *.DFM}

procedure TPrinterDlg.OKBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TPrinterDlg.FormCreate(Sender: TObject);
var Pr: TPrinter;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Pr := TPrinter.Create;
  ListBox1.Items := Pr.Printers;
  ListBox1.ItemIndex := Pr.PrinterIndex;
  Pr.free;

end;

end.

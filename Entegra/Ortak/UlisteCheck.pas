unit UListeCheck;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, FetaUtil, ExtCtrls, CheckLst, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxLabel,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TListeCheckDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Label1: TcxLabel;
    Panel1: TPanel;
    ListAmac: TCheckListBox;
    Memo1: TMemo;
    procedure ListAmacDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ListeCheckDlg: TListeCheckDlg;

implementation
  Uses PrjConst,LocOnFly, UTablo;

var
  ListeTipi : String;

{$R *.DFM}

procedure TListeCheckDlg.ListAmacDblClick(Sender: TObject);
begin
   ModalResult := mrOK;
end;

procedure TListeCheckDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TListeCheckDlg.FormShow(Sender: TObject);
begin
//   EntegreIni.ReadSection(ListeTipi, ListAmac.Items);
end;

End.

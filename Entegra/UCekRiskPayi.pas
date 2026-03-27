unit UCekRiskPayi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore,  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ComCtrls, cxContainer, cxLabel,
  ToolWin, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, FireDAC.Comp.Client,
  dxSkinLondonLiquidSky, cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue;

type
  TCekRiskPayiDlg = class(TForm)
    cxGrid3: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBTableView2ID: TcxGridDBColumn;
    cxGridDBTableView2BASTARIH: TcxGridDBColumn;
    cxGridDBTableView2BITTARIH: TcxGridDBColumn;
    cxGridDBTableView2TUTAR: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    ToolBar3: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    DtsCekRiskPayi: TDataSource;
    TabCekRiskPayi: TFDQuery;
    btnKapat: TToolButton;
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsCekRiskPayiStateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CekRiskPayiDlg: TCekRiskPayiDlg;

implementation

uses Utablo,LocOnFly;

{$R *.dfm}

procedure TCekRiskPayiDlg.btnKapatClick(Sender: TObject);
begin
   Close;
end;

procedure TCekRiskPayiDlg.DtsCekRiskPayiStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsCekRiskPayi, EkleTus,SilTus,KaydetTus,IptalTus);
end;

procedure TCekRiskPayiDlg.EkleTusClick(Sender: TObject);
begin
   TabCekRiskPayi.Append;
end;

procedure TCekRiskPayiDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TabCekRiskPayi.Open;

  Tablo.GridTurkcelestir;

end;

procedure TCekRiskPayiDlg.IptalTusClick(Sender: TObject);
begin
   TabCekRiskPayi.Cancel;
end;

procedure TCekRiskPayiDlg.KaydetTusClick(Sender: TObject);
begin
   TabCekRiskPayi.Post;
end;

procedure TCekRiskPayiDlg.SilTusClick(Sender: TObject);
begin
   TabCekRiskPayi.Delete;
end;

end.


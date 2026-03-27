unit UBildirilmisPaketler;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxCheckBox, cxImageComboBox, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ADODB, StdCtrls, ComCtrls, ToolWin, JvExControls, JvButton, JvNavigationPane, cxPC, cxSchedulerStorage, cxSchedulerCustomControls, cxSchedulerDateNavigator, cxContainer, cxDateNavigator,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxLookAndFeels, cxLookAndFeelPainters,
  cxNavigator;

type
  TBildirilmisPaketlerDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    TabBildirilmisPaketler: TADOQuery;
    DtsBildirilmisPaketler: TDataSource;
    TabAlinanPaketler: TADOQuery;
    DtsAlinanPaketler: TDataSource;
    ToolBar2: TToolBar;
    BtnGuncelle: TToolButton;
    BtnPaketAl: TToolButton;
    Panel7: TPanel;
    BtnGonderilenPaketler: TJvNavPanelButton;
    BtnAlýnanPaketler: TJvNavPanelButton;
    TabAlinanPaketlerPAKETGONDERENGLN: TStringField;
    TabAlinanPaketlerPAKETGONDERENFIRMA: TWideStringField;
    TabAlinanPaketlerID: TAutoIncField;
    TabAlinanPaketlerKAYNAKGLN: TStringField;
    TabAlinanPaketlerHEDEFGLN: TStringField;
    TabAlinanPaketlerTRANSFERID: TIntegerField;
    TabAlinanPaketlerTRANSFERDATE: TDateTimeField;
    TabAlinanPaketlerALIMTARIH: TDateTimeField;
    TabAlinanPaketlerDURUM: TBooleanField;
    TabBildirilmisPaketlerPAKETGONDERILENGLN: TStringField;
    TabBildirilmisPaketlerPAKETGONDERILENFIRMA: TWideStringField;
    TabBildirilmisPaketlerID: TAutoIncField;
    TabBildirilmisPaketlerKAYNAKGLN: TStringField;
    TabBildirilmisPaketlerHEDEFGLN: TStringField;
    TabBildirilmisPaketlerTRANSFERID: TIntegerField;
    TabBildirilmisPaketlerTRANSFERDATE: TDateTimeField;
    TabBildirilmisPaketlerALIMTARIH: TDateTimeField;
    TabBildirilmisPaketlerDURUM: TBooleanField;
    Panel3: TPanel;
    PgPaketler: TcxPageControl;
    TsGonderilmisPaketler: TcxTabSheet;
    GridBildirilmisPaketler: TcxGrid;
    TvBildirilmisPaketler: TcxGridDBTableView;
    TvBildirilmisPaketlerPAKETGONDERILENFIRMA: TcxGridDBColumn;
    TvBildirilmisPaketlerTRANSFERID: TcxGridDBColumn;
    TvBildirilmisPaketlerTRANSFERDATE: TcxGridDBColumn;
    TvBildirilmisPaketlerALIMTARIH: TcxGridDBColumn;
    TvBildirilmisPaketlerDURUM: TcxGridDBColumn;
    TvBildirilmisPaketlerID: TcxGridDBColumn;
    GlBildirilmisPaketler: TcxGridLevel;
    TsAlýnanPaketler: TcxTabSheet;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1PAKETGONDERENFIRMA: TcxGridDBColumn;
    cxGridDBTableView1TRANSFERID: TcxGridDBColumn;
    cxGridDBTableView1TRANSFERDATE: TcxGridDBColumn;
    cxGridDBTableView1ALIMTARIH: TcxGridDBColumn;
    cxGridDBTableView1DURUM: TcxGridDBColumn;
    cxGridDBTableView1ID: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    JvNavPanelHeader1: TJvNavPanelHeader;
    procedure FormShow(Sender: TObject);
    procedure BtnGuncelleClick(Sender: TObject);
    procedure BtnPaketAlClick(Sender: TObject);
    procedure BtnGonderilenPaketlerClick(Sender: TObject);
    procedure BtnAlýnanPaketlerClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BildirilmisPaketlerDlg: TBildirilmisPaketlerDlg;

implementation

uses UPaketAl,UitsBusiness,UTablo;

{$R *.dfm}

procedure TBildirilmisPaketlerDlg.BtnAlýnanPaketlerClick(Sender: TObject);
begin
  TsAlýnanPaketler.Show;
  TabAlinanPaketler.Close;
  TabAlinanPaketler.Open;
end;

procedure TBildirilmisPaketlerDlg.BtnGonderilenPaketlerClick(Sender: TObject);
begin
  TsGonderilmisPaketler.Show;
  TabBildirilmisPaketler.Close;
  TabBildirilmisPaketler.Open;
end;

procedure TBildirilmisPaketlerDlg.BtnGuncelleClick(Sender: TObject);
begin
  PaketDetay('',GLNFirma,True,Now-30,Now + 1);
  PaketDetay(GLNFirma,'',True,Now-30,Now + 1);
end;

procedure TBildirilmisPaketlerDlg.BtnPaketAlClick(Sender: TObject);
begin
  if PaketAlDlg = nil then
     Application.CreateForm(TPaketAlDlg, PaketAlDlg);
  PaketAlDlg.ShowModal;
end;

procedure TBildirilmisPaketlerDlg.FormShow(Sender: TObject);
begin



PgPaketler.HideTabs := True;

end;

end.

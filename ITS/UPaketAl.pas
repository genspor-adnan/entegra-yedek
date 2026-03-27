unit UPaketAl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxControls, cxContainer, cxEdit, cxLabel, cxTextEdit, Menus,
  cxLookAndFeelPainters, StdCtrls, cxButtons, DB, ADODB, cxGraphics, cxCustomData,
   cxStyles, cxTL, cxImageComboBox, cxMaskEdit, cxTLdxBarBuiltInMenu, cxInplaceContainer,
    cxDBTL, cxTLData, ExtCtrls, cxFilter, cxData, cxDataStorage, cxDBData, cxCheckBox,
    cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
     cxGridCustomView, cxGrid , UItsBildirim , UitsBusiness,UItsAraclari, ComCtrls, ToolWin,
  cxLookAndFeels, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinscxPCPainter, cxNavigator;

type
  TPaketAlDlg = class(TForm)
    TabAlinanPaketler: TADOQuery;
    DtsAlinanPaketler: TDataSource;
    Panel1: TPanel;
    TabAlinanTasimabirimleri: TADOQuery;
    DtsAlinanTasimaBirimleri: TDataSource;
    TabAlinanUrun: TADOQuery;
    DtsAlinanUrun: TDataSource;
    Panel2: TPanel;
    GridAlinanPaketler: TcxGrid;
    TvAlinanPaketler: TcxGridDBTableView;
    GlAlinanPaketler: TcxGridLevel;
    TabAlinanPaketlerID: TAutoIncField;
    TabAlinanPaketlerKAYNAKGLN: TStringField;
    TabAlinanPaketlerHEDEFGLN: TStringField;
    TabAlinanPaketlerTRANSFERTIPI: TStringField;
    TabAlinanPaketlerSEVKNEREYE: TStringField;
    TabAlinanPaketlerBELGENUMARASI: TStringField;
    TabAlinanPaketlerBELGETARIHI: TStringField;
    TabAlinanPaketlerTRANSFERNOT: TStringField;
    TabAlinanPaketlerVERSIYON: TStringField;
    TvAlinanPaketlerKAYNAKGLN: TcxGridDBColumn;
    TvAlinanPaketlerHEDEFGLN: TcxGridDBColumn;
    TvAlinanPaketlerTRANSFERTIPI: TcxGridDBColumn;
    TvAlinanPaketlerSEVKNEREYE: TcxGridDBColumn;
    TvAlinanPaketlerBELGENUMARASI: TcxGridDBColumn;
    TvAlinanPaketlerBELGETARIHI: TcxGridDBColumn;
    TvAlinanPaketlerTRANSFERNOT: TcxGridDBColumn;
    TvAlinanPaketlerVERSIYON: TcxGridDBColumn;
    TabAlinanUrunID: TAutoIncField;
    TabAlinanUrunGTIN: TStringField;
    TabAlinanUrunLOTNUMARASI: TStringField;
    TabAlinanUrunURETIMTARIHI: TStringField;
    TabAlinanUrunSONKULLANIMTARIHI: TStringField;
    TabAlinanUrunPOSAYISI: TStringField;
    TabAlinanUrunSIRANO: TStringField;
    TabAlinanUrunPTS_GELEN_TASIMA_BIRIMI_ID: TIntegerField;
    TabAlinanUrunPTS_GELEN_PAKET_ID: TIntegerField;
    TabAlinanTasimabirimleriID: TAutoIncField;
    TabAlinanTasimabirimleriUSTID: TIntegerField;
    TabAlinanTasimabirimleriETIKET: TStringField;
    TabAlinanTasimabirimleriTIP: TStringField;
    TabAlinanTasimabirimleriADET: TIntegerField;
    TabAlinanTasimabirimleriITS_PTS_PAKET_ID: TIntegerField;
    TabAlinanPaketlerADET: TIntegerField;
    vAlinanPaketlerColumn1: TcxGridDBColumn;
    ToolBar2: TToolBar;
    BtnGuncelle: TToolButton;
    Panel4: TPanel;
    GridPaketler: TcxGrid;
    TvPaketler: TcxGridDBTableView;
    GlPaketler: TcxGridLevel;
    Panel3: TPanel;
    TreeListTasimaBirimleri: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    GridAlinanUrun: TcxGrid;
    TvAlinanUrun: TcxGridDBTableView;
    TvAlinanUrunGTIN: TcxGridDBColumn;
    TvAlinanUrunLOTNUMARASI: TcxGridDBColumn;
    TvAlinanUrunSIRANO: TcxGridDBColumn;
    TvAlinanUrunURETIMTARIHI: TcxGridDBColumn;
    TvAlinanUrunSONKULLANIMTARIHI: TcxGridDBColumn;
    TvAlinanUrunPOSAYISI: TcxGridDBColumn;
    GlAlinanUrun: TcxGridLevel;
    DtsPaketler: TDataSource;
    TabPaketler: TADOQuery;
    TabAlinanPaketlerPAKETGONDERENGLN: TStringField;
    TabAlinanPaketlerPAKETGONDERENFIRMA: TWideStringField;
    AutoIncField1: TAutoIncField;
    StringField1: TStringField;
    StringField2: TStringField;
    TabAlinanPaketlerTRANSFERID: TIntegerField;
    TabAlinanPaketlerTRANSFERDATE: TDateTimeField;
    TabAlinanPaketlerALIMTARIH: TDateTimeField;
    TabAlinanPaketlerDURUM: TBooleanField;
    TvPaketlerPAKETGONDERENFIRMA: TcxGridDBColumn;
    TvPaketlerID: TcxGridDBColumn;
    TvPaketlerTRANSFERID: TcxGridDBColumn;
    TvPaketlerTRANSFERDATE: TcxGridDBColumn;
    TvPaketlerALIMTARIH: TcxGridDBColumn;
    TvPaketlerDURUM: TcxGridDBColumn;
    Panel5: TPanel;
    BtnXmlAl: TToolButton;
    OpenDialog1: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure TabAlinanPaketlerAfterScroll(DataSet: TDataSet);
    procedure BtnGuncelleClick(Sender: TObject);
    procedure TvPaketlerCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TreeListTasimaBirimleriClick(Sender: TObject);
    procedure BtnXmlAlClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PaketAlDlg: TPaketAlDlg;

implementation

uses UTablo;

{$R *.dfm}

procedure TPaketAlDlg.BtnGuncelleClick(Sender: TObject);
var
PtsAlim :  TPTSAlimIstek;
begin
  if not TabPaketler.FieldByName('DURUM').AsBoolean THEN
  PaketAl(TabPaketler.FieldByName('KAYNAKGLN').AsString,'',TabPaketler.FieldByName('TRANSFERID').AsInteger);
  TabPaketler.Close;
  TabPaketler.Open;
end;

procedure TPaketAlDlg.BtnXmlAlClick(Sender: TObject);
var
  Xmlyol : string;
  i , transferid: Integer;
begin
   OpenDialog1.Filter :=
    'xml files|*.xml';
  if OpenDialog1.Execute then begin
    transferId:= 0;
    if TabPaketler.Active and (not TabPaketler.FieldByName('DURUM').AsBoolean) then
      transferid:= TabPaketler.FieldByName('TRANSFERID').AsInteger;

    XMLdenPtsAl(OpenDialog1.FileName,transferId);

    if TabPaketler.Active then begin
      TabPaketler.Close;
      TabPaketler.Open;
    end;
  end;
end;

procedure TPaketAlDlg.FormShow(Sender: TObject);
begin
  TabPaketler.Close;
  TabPaketler.Open;
end;

procedure TPaketAlDlg.TabAlinanPaketlerAfterScroll(DataSet: TDataSet);
begin
 TabAlinanTasimabirimleri.Close;
 TabAlinanTasimabirimleri.Parameters.ParamByName('PAKETID').Value:= TabAlinanPaketler.FieldByName('ID').AsInteger;
 TabAlinanTasimabirimleri.Open;
 TabAlinanUrun.Close;
end;

procedure TPaketAlDlg.TreeListTasimaBirimleriClick(Sender: TObject);
begin
 TabAlinanUrun.Close;
 TabAlinanUrun.Parameters.ParamByName('TASIMABIRIMID').Value:= TabAlinanTasimabirimleri.FieldByName('ID').AsInteger;
 TabAlinanUrun.Parameters.ParamByName('PAKETID').Value:= TabAlinanPaketler.FieldByName('ID').AsInteger;
 TabAlinanUrun.Open;
end;

procedure TPaketAlDlg.TvPaketlerCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  TabAlinanPaketler.Close;
  TabAlinanPaketler.Parameters[0].Value := TabPaketler.FieldByName('TRANSFERID').AsInteger;
  TabAlinanPaketler.Open;
end;

end.

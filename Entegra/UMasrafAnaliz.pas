unit UMasrafAnaliz;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinLondonLiquidSky, cxClasses, cxCustomData, cxStyles, cxCurrencyEdit,
  dxSkinscxPCPainter, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB,
  cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGridCustomView, cxGrid, cxCustomPivotGrid, cxDBPivotGrid,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, Vcl.ComCtrls,
  JvExComCtrls, JvDateTimePicker, Vcl.ExtCtrls, FireDAC.Comp.Client, Vcl.ToolWin,
  Vcl.StdCtrls, cxSpinEdit, cxDBEdit, cxLabel, cxGridChartView,
  cxPivotGridChartConnection, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxBarBuiltInMenu, dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TMasrafAnalizDlg = class(TForm)
    ToolBar2: TToolBar;
    TabPivot: TFDQuery;
    DtsPivot: TDataSource;
    Panel1: TPanel;
    pivot: TcxDBPivotGrid;
    FGrid: TcxGrid;
    FGridTableView: TcxGridDBTableView;
    FGridTableViewGRUP: TcxGridDBColumn;
    FGridTableViewTUR: TcxGridDBColumn;
    FGridTableViewTARIH: TcxGridDBColumn;
    FGridTableViewTUTAR: TcxGridDBColumn;
    FGridDBTableView1: TcxGridDBTableView;
    FGridDBTableView1DURUM: TcxGridDBColumn;
    FGridDBTableView1VADE: TcxGridDBColumn;
    FGridDBTableView1SERINO: TcxGridDBColumn;
    FGridDBTableView1HESAPADI: TcxGridDBColumn;
    FGridDBTableView1Column1: TcxGridDBColumn;
    FGridLevel1: TcxGridLevel;
    TabPivotGRUP: TWideStringField;
    TabPivotTUR: TWideStringField;
    TabPivotYIL: TFloatField;
    TabPivotTARIH: TFloatField;
    TabPivotTARIHYAZI: TStringField;
    TabPivotPLANLANAN: TCurrencyField;
    TabPivotGERCEKLESEN: TCurrencyField;
    pivotGRUP: TcxDBPivotGridField;
    pivotTUR: TcxDBPivotGridField;
    pivotYIL: TcxDBPivotGridField;
    pivotTARIH: TcxDBPivotGridField;
    pivotTARIHYAZI: TcxDBPivotGridField;
    pivotPLANLANAN: TcxDBPivotGridField;
    pivotGERCEKLESEN: TcxDBPivotGridField;
    LabelDijit: TcxLabel;
    EditYIL: TcxSpinEdit;
    cxGrid1: TcxGrid;
    cxGrid1ChartView1: TcxGridChartView;
    cxGrid1Level1: TcxGridLevel;
    Splitter1: TSplitter;
    cxPivotGridChartConnection1: TcxPivotGridChartConnection;
    procedure FormShow(Sender: TObject);
    procedure EditYILPropertiesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshPivot;
  public
    { Public declarations }
    Gelirmi : Smallint;
  end;

var
  MasrafAnalizDlg: TMasrafAnalizDlg;

implementation

{$R *.dfm}

uses Utablo,PrjConst,LocOnFly;

procedure TMasrafAnalizDlg.RefreshPivot;
var
  LParam: TFDParam;
begin
  TabPivot.Close;
  TabPivot.SQL.Text := 'SELECT * FROM fn_ButcePivot_Aylik(:PYil,:PGider)';
  TabPivot.Params.Clear;

  LParam := TabPivot.Params.Add;
  LParam.Name := 'PYil';
  LParam.DataType := ftSmallint;
  LParam.ParamType := ptInput;
  LParam.AsSmallInt := EditYIL.Value;

  LParam := TabPivot.Params.Add;
  LParam.Name := 'PGider';
  LParam.DataType := ftBoolean;
  LParam.ParamType := ptInput;
  LParam.AsBoolean := Gelirmi <> 0;

  TabPivot.Open;
end;

procedure TMasrafAnalizDlg.EditYILPropertiesChange(Sender: TObject);
begin
  if not Showing then
    Exit;

  RefreshPivot;
end;

procedure TMasrafAnalizDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TMasrafAnalizDlg.FormShow(Sender: TObject);
var myYear, myMonth, myDay : Word;
begin
  DecodeDate(Tablo.GENINI.BugunTrh, myYear, myMonth, myDay);
  EditYIL.Value := myYear;
  RefreshPivot;
end;

end.


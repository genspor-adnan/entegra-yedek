unit uTanimGrid_DagitimFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, FireDAC.Comp.Client, cxContainer, cxTextEdit, cxDBEdit, Vcl.StdCtrls,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, cxMaskEdit, cxDropDownEdit, cxImageComboBox;

type
  TEvrakTanimDagitimFrame = class(TEvrakTanimGridFrame)
    qryDetay: TFDQuery;
    dsDetay: TDataSource;
    ViewTanimID: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
    PanelRight: TPanel;
    PanelRightTop: TPanel;
    Label1: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    Panel1: TPanel;
    PanelAlanLeft: TPanel;
    Label2: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    PanelAlanRgiht: TPanel;
    Panel5: TPanel;
    SpeedButton2: TSpeedButton;
    GridDagitim: TcxGrid;
    ViewDagitim: TcxGridDBTableView;
    ViewDagitimID: TcxGridDBColumn;
    LevelD1: TcxGridLevel;
    ViewDagitimDAGITIM_REF: TcxGridDBColumn;
    ViewDagitimKURUM_ICI_DISI: TcxGridDBColumn;
    ViewDagitimEVRAK_BIRIM_REF: TcxGridDBColumn;
    ViewDagitimALAN_ADI: TcxGridDBColumn;
    ViewDagitimARZ_RICA: TcxGridDBColumn;
    editAlanAdi: TcxDBTextEdit;
    Label3: TLabel;
    comboArzRica: TcxDBImageComboBox;
    comboEvrakBirimi: TcxDBLookupComboBox;
    comboKurumIcDis: TcxDBImageComboBox;
    qryLookupBirim: TFDQuery;
    dsLookupBirim: TDataSource;
    Label4: TLabel;
    procedure qryEvrakAfterScroll(DataSet: TDataSet);
    procedure qryDetayBeforePost(DataSet: TDataSet);
    procedure actKaydetUpdate(Sender: TObject);
    procedure actKaydetExecute(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimDagitimFrame: TEvrakTanimDagitimFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimDagitimFrame.actKaydetExecute(Sender: TObject);
begin
  // inherited;
  if (qryEvrak.State in [dsEdit, dsInsert]) then
     qryEvrak.Post;

  if (qryDetay.State in [dsEdit, dsInsert]) then
     qryDetay.Post;
end;

procedure TEvrakTanimDagitimFrame.actKaydetUpdate(Sender: TObject);
begin
  // inherited;
   TAction(Sender).Enabled := (qryEvrak.State in [dsEdit, dsInsert]) or (qryDetay.State in [dsEdit, dsInsert]);
end;

procedure TEvrakTanimDagitimFrame.qryDetayBeforePost(DataSet: TDataSet);
begin
  inherited;
  qryDetay.FieldByName('DAGITIM_REF').AsInteger := qryEvrak.FieldByName('ID').AsInteger;
end;

procedure TEvrakTanimDagitimFrame.qryEvrakAfterScroll(DataSet: TDataSet);
begin
  inherited;
  qryDetay.Close;
  qryDetay.Params[0].Value := qryEvrak.FieldByName('ID').AsInteger;
  qryDetay.Open;
end;

procedure TEvrakTanimDagitimFrame.SpeedButton1Click(Sender: TObject);
begin
  if qryDetay.State = dsBrowse then
    qryDetay.Append;
end;


procedure TEvrakTanimDagitimFrame.SpeedButton2Click(Sender: TObject);
begin
   if (not (qryDetay.State in [dsEdit, dsInsert])) and (qryDetay.RecordCount>0) then
     if Application.MessageBox(PWideChar(SSilmeSorusu), PWideChar(SGenotipOnay), MB_ICONQUESTION+MB_YESNO) = IDYES then
       qryDetay.Delete;
end;

procedure TEvrakTanimDagitimFrame.Startup;
begin
  qryEvrak.AfterScroll := Nil;
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;
  qryDetay.Open;
  qryLookupBirim.Open;
  qryEvrak.AfterScroll := qryEvrakAfterScroll;
end;

end.




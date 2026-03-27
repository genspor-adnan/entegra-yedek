unit uTanimGrid_ParafFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  uEvrakModule,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, FireDAC.Comp.Client, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, cxContainer,
  cxDBLookupComboBox, cxButtonEdit, cxTextEdit, cxDBEdit, Vcl.StdCtrls;

type
  TEvrakTanimParafFrame = class(TEvrakTanimGridFrame)
    editVeklaetVeren: TLabel;
    editParafAdi: TcxDBTextEdit;
    Label3: TLabel;
    PanelPersonel: TPanel;
    Panelbutton: TPanel;
    GridPers: TcxGrid;
    ViewPers: TcxGridDBTableView;
    ViewPersPARAF_ID: TcxGridDBColumn;
    ViewPersPERSONEL_ID: TcxGridDBColumn;
    ViewPersColumnKaldir: TcxGridDBColumn;
    LevelPers: TcxGridLevel;
    actPersonelEkle: TAction;
    qryPersonelList: TFDQuery;
    dsPersonelList: TDataSource;
    qryLookupVekalet: TFDQuery;
    dsLookupVekalet: TDataSource;
    ViewTanimID: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
    buttonPersonelEkle: TSpeedButton;
    procedure actPersonelEkleExecute(Sender: TObject);
    procedure actPersonelEkleUpdate(Sender: TObject);
    procedure qryPersonelListBeforePost(DataSet: TDataSet);
    procedure qryEvrakAfterScroll(DataSet: TDataSet);
    procedure ViewPersColumnKaldirPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ViewTanimFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord,
      AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;
    constructor Create(AOwner : TComponent); override;
  end;

var
  EvrakTanimParafFrame: TEvrakTanimParafFrame;

implementation

{$R *.dfm}

uses
  Fetautil, UTablo, PrjConst;

{ TEvrakTanimParafFrame }

procedure TEvrakTanimParafFrame.actPersonelEkleExecute(Sender: TObject);
begin
  inherited;
  qryPersonelList.Append;
end;

procedure TEvrakTanimParafFrame.actPersonelEkleUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (qryEvrak.State<> dsInsert) and (qryEvrak.RecordCount>0);
end;

constructor TEvrakTanimParafFrame.Create(AOwner: TComponent);
begin
  inherited;
  qryEvrak.AfterScroll := Nil;
end;

procedure TEvrakTanimParafFrame.qryEvrakAfterScroll(DataSet: TDataSet);
begin
  inherited;
  qryPersonelList.Close;
  qryPersonelList.Params[0].Value := qryEvrak.FieldByName('ID').AsInteger;
  qryPersonelList.Open;
end;

procedure TEvrakTanimParafFrame.qryPersonelListBeforePost(DataSet: TDataSet);
begin
  inherited;
  qryPersonelList.FieldByName('PARAF_ID').AsInteger := qryEvrak.FieldByName('ID').AsInteger;
end;

procedure TEvrakTanimParafFrame.Startup;
begin
  qryEvrak.AfterScroll := Nil;
  SetActions([actKaydet, actSil, actYeniKayit, actPersonelEkle]);
  //qryEvrak.SQL.Text := qryEvrak.SQL.Text+' EVRAK_PARAF';
  inherited;
  qryLookupVekalet.Open;
  qryEvrak.AfterScroll := qryEvrakAfterScroll;
  qryEvrakAfterScroll(qryEvrak);
  //qryPersonelList.Open;
end;

procedure TEvrakTanimParafFrame.ViewPersColumnKaldirPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  inherited;
  if Application.MessageBox(PChar(cxKayýt), PChar(SGenotipOnay), MB_YESNO) = IDYES then
    qryPersonelList.Delete;
end;

procedure TEvrakTanimParafFrame.ViewTanimFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
 i : integer;
begin
   {
   if Assigned(AFocusedRecord) then
   begin
       qryPersonelList.Close;
       qryPersonelList.SQL.Text := 'SELECT * FROM EVRAK_PARAF_PERSONEL WHERE PARAF_ID='+VarToStr(AFocusedRecord.Values[0]);
       qryPersonelList.Open;
   end;
   }
end;

end.




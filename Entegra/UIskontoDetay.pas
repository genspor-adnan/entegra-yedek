unit UIskontoDetay;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  Data.DB, cxDBData, cxTextEdit, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, FireDAC.Comp.Client,
  Vcl.ComCtrls, Vcl.ToolWin, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, UTablo;

type
  TIskontoDetayDlg = class(TForm)
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    ToolBar5: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    ToolButton2: TToolButton;
    KaydetBtn: TToolButton;
    IptalBtn: TToolButton;
    DtsIskontolar: TDataSource;
    TabIskontolar: TFDQuery;
    PanelAlt: TPanel;
    KaydetTus: TBitBtn;
    CancelBtn: TBitBtn;
    cxGrid1DBTableView1ISKONTO: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    procedure DtsIskontolarStateChange(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetBtnClick(Sender: TObject);
    procedure IptalBtnClick(Sender: TObject);
    procedure TabIskontolarNewRecord(DataSet: TDataSet);
    procedure CancelBtnClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure cxGrid1DBTableView1ISKONTOCustomDrawFooterCell(Sender: TcxGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
    procedure TabIskontolarBeforeOpen(DataSet: TDataSet);
    procedure TabIskontolarAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    IskOrani:Extended;
    Yeri,YerID,Tur:integer;

  end;

var
  IskontoDetayDlg: TIskontoDetayDlg;

implementation

{$R *.dfm}

procedure TIskontoDetayDlg.CancelBtnClick(Sender: TObject);
begin
  ModalResult := MrCancel;
end;

procedure TIskontoDetayDlg.cxGrid1DBTableView1ISKONTOCustomDrawFooterCell(Sender: TcxGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
begin
  AViewInfo.Text := FloatToStr(IskOrani);
end;

procedure TIskontoDetayDlg.DtsIskontolarStateChange(Sender: TObject);
begin
  EkleTus.Visible := DtsIskontolar.State = dsBrowse;
  SilTus.Visible := DtsIskontolar.State = dsBrowse;
  KaydetBtn.Visible := DtsIskontolar.State in [dsEdit,dsInsert];
  IptalBtn.Visible := DtsIskontolar.State in [dsEdit,dsInsert];
  KaydetTus.Enabled := (DtsIskontolar.State = dsBrowse)and(TabIskontolar.RecordCount>0);
  if DtsIskontolar.State = dsBrowse then
    cxGrid1DBTableView1ISKONTO.onCustomDrawFooterCell := cxGrid1DBTableView1ISKONTOCustomDrawFooterCell
  else
    cxGrid1DBTableView1ISKONTO.onCustomDrawFooterCell := nil;
end;

procedure TIskontoDetayDlg.EkleTusClick(Sender: TObject);
begin
  TabIskontolar.Append;
end;

procedure TIskontoDetayDlg.IptalBtnClick(Sender: TObject);
begin
  TabIskontolar.Cancel;
end;

procedure TIskontoDetayDlg.KaydetBtnClick(Sender: TObject);
begin
  TabIskontolar.Post;
end;

procedure TIskontoDetayDlg.KaydetTusClick(Sender: TObject);
begin
  ModalResult := MrOk;
end;

procedure TIskontoDetayDlg.SilTusClick(Sender: TObject);
begin
  TabIskontolar.Delete;
end;

procedure TIskontoDetayDlg.TabIskontolarAfterPost(DataSet: TDataSet);
var
  IskID:integer;
begin
  IskOrani := 0.0;
  IskID := TabIskontolar.FieldByName('ID').AsInteger;
  if TabIskontolar.RecordCount>0 then begin
    TabIskontolar.First;
    while not TabIskontolar.Eof do begin
      if IskOrani = 0.0 then
        IskOrani := TabIskontolar.FieldByName('ISKONTO').AsFloat
      else begin
        IskOrani := 100.0-((100.0-IskOrani)*((100.0-TabIskontolar.FieldByName('ISKONTO').AsFloat)/100));
      end;
      TabIskontolar.Next;
    end;
  end;
  TabIskontolar.Locate('ID',IskID,[]);
end;

procedure TIskontoDetayDlg.TabIskontolarBeforeOpen(DataSet: TDataSet);
begin
  TabIskontolar.Params[0].Value := Yeri;
  TabIskontolar.Params[1].Value := YerID;
  TabIskontolar.Params[2].Value := Tur;
end;

procedure TIskontoDetayDlg.TabIskontolarNewRecord(DataSet: TDataSet);
begin
  TabIskontolar.FieldByName('YERI').AsInteger := Yeri;
  TabIskontolar.FieldByName('YERID').AsInteger := YerId;
  TabIskontolar.FieldByName('TUR').AsInteger := Tur;
  TabIskontolar.FieldByName('EKLEYEN').AsInteger := StrToIntDef(Kullanan,0);
end;


end.

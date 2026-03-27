unit uKosulDetayAra;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, FireDAC.Comp.Client, StdCtrls, ExtCtrls, Buttons, cxLookAndFeels,
  cxLookAndFeelPainters, cxNavigator;

type
  TKosulDetayAra = class(TForm)
    DBTable: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    TabAra: TFDQuery;
    DtsAra: TDataSource;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    GroupBox2: TGroupBox;
    Kapat: TSpeedButton;
    BTNKaydet: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure KapatClick(Sender: TObject);
    procedure BTNKaydetClick(Sender: TObject);
    procedure DBTableCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  KosulDetayAra: TKosulDetayAra;
  AraSorgu:String;
  FieldStr:String;


implementation

uses
  uTablo,uDokum;

{$R *.dfm}

procedure TKosulDetayAra.FormCreate(Sender: TObject);
var
  i:integer;
begin
  
  if TabAra.Connection = nil then
    TabAra.Connection := Tablo.FDCnn;
FieldStr:=copy(TabloDokum.TabKosul.fieldbyname('COMBOICERIK').AsString,2,pos('}',TabloDokum.TabKosul.fieldbyname('COMBOICERIK').AsString)-2);
  AraSorgu:=StringReplace(FieldStr,',',' like ''%d%'' or ',[rfReplaceAll]);
  AraSorgu:=AraSorgu + ' like ''%d%''';

  TabAra.Close;
  TabAra.SQL.Text:='Select DISTINCT ' + FieldStr + ' from ' + TabloDokum.TabKosul.fieldbyname('TABLO').AsString + ' ORDER BY ' + FieldStr;
  TabAra.Open;
  
  while DBTable.ColumnCount > 0 do
    DBTable.Columns[0].Destroy;

  for i := 0 to TabAra.FieldCount - 1 do
  begin
    DBTable.CreateColumn;
    DBTable.Columns[i].DataBinding.FieldName := TabAra.Fields[i].FieldName;
    DBTable.Columns[i].Options.Editing:=FALSE;
  end;

  GroupBox1.Caption:='Ara (' + FieldStr + ')';
end;

procedure TKosulDetayAra.Edit1Change(Sender: TObject);
begin
  
  if TabAra.Connection = nil then
    TabAra.Connection := Tablo.FDCnn;
TabAra.Close;
  TabAra.SQL.Text:='Select DISTINCT ' + FieldStr + ' from ' + TabloDokum.TabKosul.fieldbyname('TABLO').AsString + ' where ' + StringReplace(AraSorgu,'%d%','%' + Edit1.Text + '%',[rfReplaceAll]) + ' ORDER BY ' + FieldStr; 
  TabAra.Open;
end;

procedure TKosulDetayAra.KapatClick(Sender: TObject);
begin
close;
end;

procedure TKosulDetayAra.BTNKaydetClick(Sender: TObject);
begin
uDokum.ComboNe.text:=tabara.Fieldbyname(tablodokum.tabkosul.fieldbyname('ALAN').asstring).asstring;
Close;
end;

procedure TKosulDetayAra.DBTableCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  BTNKaydetClick(btnKaydet);
end;

end.




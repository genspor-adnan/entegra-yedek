unit uKosulDetayAra;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, UFDCompatHelpers, StdCtrls, ExtCtrls, Buttons, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, FireDAC.Comp.Client,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

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
    procedure Edit1Change(Sender: TObject);
    procedure KapatClick(Sender: TObject);
    procedure BTNKaydetClick(Sender: TObject);
    procedure DBTableCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure FormShow(Sender: TObject);
  private
    //FDokumDlgInstance: TComponent;
    FTabKosulInstance: TDataSet;
    { Private declarations }
  public
    { Public declarations }
    //property DokumDlgInstance : TComponent read FDokumDlgInstance write SetDokumDlgInstance;
    property TabKosulInstance: TDataSet read FTabKosulInstance write FTabKosulInstance;
  end;

var
  KosulDetayAra: TKosulDetayAra;
  AraSorgu:String;
  FieldStr:String;


implementation

uses
  uTablo,uDokum;

{$R *.dfm}

procedure TKosulDetayAra.Edit1Change(Sender: TObject);
begin
  
  if TabAra.Connection = nil then
    TabAra.Connection := Tablo.FDCnn;
TabAra.Close;
//  TabAra.SQL.Text:='Select DISTINCT ' + FieldStr + ' from ' + TDokumDlg(FDokumDlgInstance).TabKosul.fieldbyname('TABLO').AsString + ' where ' + StringReplace(AraSorgu,'%d%','%' + Edit1.Text + '%',[rfReplaceAll]) + ' ORDER BY ' + FieldStr;
  TabAra.SQL.Text:=StringReplace(AraSorgu,'%d%','%' + Edit1.Text + '%',[rfReplaceAll]) + '  ' ;
  TabAra.SQL.Text:=StringReplace(AraSorgu,'<ara>',Edit1.Text,[rfReplaceAll]);
  TabAra.Open;
  DBTable.ApplyBestFit(nil);
end;

procedure TKosulDetayAra.FormShow(Sender: TObject);
var
  i:integer;
begin
  
  if TabAra.Connection = nil then
    TabAra.Connection := Tablo.FDCnn;
//2 türlü olabilir 1:select KOD,AD from MASRAFGELIR  veya 2: {KOD, AD} şeklinde
//  FieldStr := TDokumDlg(FDokumDlgInstance).TabKosul.fieldbyname('COMBOICERIK').AsString;
   FieldStr := FTabKosulInstance.fieldbyname('COMBOICERIK').AsString;
  //önce türüne bakalım
  if pos('{', FieldStr)>0 then begin
     FieldStr := copy(FieldStr,2,pos('}',FieldStr)-2);
     AraSorgu:= 'Select DISTINCT ' + FieldStr + ' from ' + FTabKosulInstance.fieldbyname('TABLO').AsString;
  end else begin
    // if Pos('ORDER', UpperCase(FieldStr))>0  then //varsa order by atalım
    //    FieldStr := Copy(FieldStr, 1, Pos('ORDER', UpperCase(FieldStr)));
     AraSorgu := FieldStr;
  end;

  //AraSorgu:=StringReplace(FieldStr,',',' like ''%d%'' or ',[rfReplaceAll]);
  //AraSorgu:=AraSorgu + ' like ''%d%''';

  TabAra.Close;
  TabAra.SQL.Text:= AraSorgu;
  TabAra.Open;

  while DBTable.ColumnCount > 0 do
    DBTable.Columns[0].Destroy;

  FieldStr:='';

//  AraSorgu := AraSorgu+' where ';
  for i := 0 to TabAra.FieldCount - 1 do begin
    DBTable.CreateColumn;
    DBTable.Columns[i].DataBinding.FieldName := TabAra.Fields[i].FieldName;
    DBTable.Columns[i].Options.Editing:=FALSE;

    FieldStr := FieldStr+TabAra.Fields[i].FieldName;
  //  AraSorgu:=AraSorgu + ' '+TabAra.Fields[i].FieldName+' like ''%d%''';
  end;

  DBTable.ApplyBestFit(nil);

  GroupBox1.Caption:='Ara (' + FieldStr + ')';

end;

procedure TKosulDetayAra.KapatClick(Sender: TObject);
begin
close;
end;


procedure TKosulDetayAra.BTNKaydetClick(Sender: TObject);
begin
   uDokum.EditNe.text:=tabara.Fieldbyname(FTabKosulInstance.fieldbyname('ALAN').asstring).asstring;
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




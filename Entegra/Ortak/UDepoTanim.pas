unit UDepoTanim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, Buttons, StdCtrls,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGrid, DBCtrls, UFDCompatHelpers,
  cxCheckBox;

type
  TDepoTanimDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    TabDepolar: TADOQuery;
    DtsDepolar: TDataSource;
    NavigatorDepolar: TDBNavigator;
    TableViewDepolar: TcxGridDBTableView;
    cxGridDepolarLevel1: TcxGridLevel;
    cxGridDepolar: TcxGrid;
    TableViewDepolarDBColumn1: TcxGridDBColumn;
    TableViewDepolarDBColumn2: TcxGridDBColumn;
    TableViewDepolarDBColumn3: TcxGridDBColumn;
    TableViewDepolarDBColumn4: TcxGridDBColumn;
    TableViewDepolarDBColumn5: TcxGridDBColumn;
    TableViewDepolarDBColumn6: TcxGridDBColumn;
    TableViewDepolarDBColumn7: TcxGridDBColumn;
    TableViewDepolarDBColumn9: TcxGridDBColumn;
    TableViewDepolarDBColumn10: TcxGridDBColumn;
    BtnKapat: TSpeedButton;
    procedure BtnKapatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckPasifGosterClick(Sender: TObject);
    procedure TabDepolarNewRecord(DataSet: TDataSet);
    procedure DtsDepolarStateChange(Sender: TObject);
    procedure TabDepolarBeforeDelete(DataSet: TDataSet);
    procedure TabDepolarAfterPost(DataSet: TDataSet);
    procedure TabDepolarPostError(DataSet: TDataSet; E: EDatabaseError;
      var Action: TDataAction);
    procedure TabDepolarBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DepoTanimDlg: TDepoTanimDlg;

implementation
Uses UTablo;

{$R *.dfm}

procedure TDepoTanimDlg.BtnKapatClick(Sender: TObject);
begin
close;
end;

procedure TDepoTanimDlg.FormCreate(Sender: TObject);
begin

  TabDepolar.Close;
  TabDepolar.Open;

end;

procedure TDepoTanimDlg.CheckPasifGosterClick(Sender: TObject);
begin
  TabDepolar.Close;
  TabDepolar.Open;
end;

procedure TDepoTanimDlg.TabDepolarNewRecord(DataSet: TDataSet);
begin
   TabDepolar.FieldByName('EKLEYEN').AsString:= Kullanan;
end;

procedure TDepoTanimDlg.DtsDepolarStateChange(Sender: TObject);
begin
  if DtsDepolar.State in [dsEdit,dsInsert] then
    NavigatorDepolar.VisibleButtons:= [nbPost, nbCancel]
  else
    NavigatorDepolar.VisibleButtons:= [nbInsert,nbDelete];   
end;

procedure TDepoTanimDlg.TabDepolarBeforeDelete(DataSet: TDataSet);
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text:= 'SELECT TOP 1 * FROM STOKDURUM WHERE YER='''+ TabDepolar.Fieldbyname('DEPOADI').AsString+''' ';
   Tablo.Query1.Open;

   if Tablo.Query1.RecordCount>=1 then
    begin
       Application.MessageBox('Bu depoda hareket görmüþ ürünler vardýr. Silinemez. Lütfen depo yu pasif yapýnýz.','H A T A', MB_OK+ MB_ICONERROR);
       Abort;
    end;
    
end;

procedure TDepoTanimDlg.TabDepolarAfterPost(DataSet: TDataSet);
begin
  TabDepolar.Close;
  TabDepolar.Open;
end;

procedure TDepoTanimDlg.TabDepolarPostError(DataSet: TDataSet;
  E: EDatabaseError; var Action: TDataAction);
begin
  if Pos('Cannot insert the value NULL into column ''DEPOKODU''',E.Message) >0 then
    ShowMessage('Depo Kodu Boþ olamaz.')
  else if Pos('Violation of UNIQUE KEY constraint ''IX_DEPOLAR_DEPOKOD''',E.Message)>0 then
    ShowMessage('Bu depo kodu daha önce baþka bir depo için kullanýlmýþ. Lütfen baþka bir depo kodu tanýmlayýnýz.')
  else if Pos('Violation of UNIQUE KEY constraint ''IX_DEPOLAR_DEPOADI''',E.Message)>0 then
    ShowMessage('Bu depo adý daha önce baþka bir depo için kullanýlmýþ. Lütfen baþka bir depo adý tanýmlayýnýz.');
 

end;

procedure TDepoTanimDlg.TabDepolarBeforePost(DataSet: TDataSet);
begin
  if TabDepolar.FieldByName('DEPOKODU').AsString='' then
    begin
       Application.MessageBox('Depo Kodu Boþ Olamaz','U Y A R I', MB_OK+ MB_ICONWARNING);
       abort;
    end;
  if TabDepolar.FieldByName('DEPOADI').AsString='' then
    begin
       Application.MessageBox('Depo Adý Boþ Olamaz','U Y A R I', MB_OK+ MB_ICONWARNING);
       abort;

    end;
end;

end.


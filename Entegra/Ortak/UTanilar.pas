unit UTanilar;

interface

uses
  Windows, Messages, Classes, SysUtils, Graphics, Controls, StdCtrls, Forms,
  Dialogs, DBCtrls, DB, DBGrids, DBTables, Grids, ExtCtrls, ComCtrls,
  ToolWin, UFDCompatHelpers;

type
  TTanilarDlg = class(TForm)
    DBGrid1: TDBGrid;
    Panel2: TPanel;
    Panel3: TPanel;
    DBGrid2: TDBGrid;
    Label1: TLabel;
    GenelTani: TADOQuery;
    DtsGenelTani: TDataSource;
    Panel4: TPanel;
    Label2: TLabel;
    DBGrid3: TDBGrid;
    Label3: TLabel;
    DtsGelisTani: TDataSource;
    GelisTani: TADOQuery;
    DtsALERJI: TDataSource;
    ALERJI: TADOQuery;
    ToolBar1: TToolBar;
    Panel5: TPanel;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    procedure GenelTaniNewRecord(DataSet: TDataSet);
    procedure GelisTaniNewRecord(DataSet: TDataSet);
    procedure ALERJINewRecord(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure GenelTaniBeforeEdit(DataSet: TDataSet);
    procedure GelisTaniBeforeEdit(DataSet: TDataSet);
    procedure ALERJIBeforeEdit(DataSet: TDataSet);
    procedure GenelTaniAfterPost(DataSet: TDataSet);
    procedure GelisTaniAfterPost(DataSet: TDataSet);
    procedure ALERJIAfterPost(DataSet: TDataSet);
    procedure ToolButton2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  TanilarDlg: TTanilarDlg;

implementation

uses UTablo;

{$R *.DFM}

var YeniKayit:Boolean;

procedure TTanilarDlg.GenelTaniNewRecord(DataSet: TDataSet);
begin
   GenelTani.Fields[1].AsString := Tablo.TabKimlik.Fields[0].AsString;
   YeniKayit := True;
end;

procedure TTanilarDlg.GelisTaniNewRecord(DataSet: TDataSet);
begin
   GelisTani.Fields[1].AsString := Tablo.TabKimlik.Fields[0].AsString;
   YeniKayit := True;
end;

procedure TTanilarDlg.ALERJINewRecord(DataSet: TDataSet);
begin
   ALERJI.Fields[1].AsString := Tablo.TabKimlik.Fields[0].AsString;
   YeniKayit := True;
end;

procedure TTanilarDlg.FormShow(Sender: TObject);
begin
   GenelTani.Parameters[0].Value:= Tablo.TabKimlik.Fields[0].AsString;
   GenelTani.Open;
   GelisTani.Parameters[0].Value:= Tablo.TabKimlik.Fields[0].AsString;
   GelisTani.Open;
   ALERJI.Parameters[0].Value:= Tablo.TabKimlik.Fields[0].AsString;
   ALERJI.Open;
end;

procedure TTanilarDlg.GenelTaniBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit := False;
end;

procedure TTanilarDlg.GelisTaniBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit := False;
end;

procedure TTanilarDlg.ALERJIBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit := False;
end;

procedure TTanilarDlg.GenelTaniAfterPost(DataSet: TDataSet);
begin
   if YeniKayit then begin;
      GenelTani.Close;
      GenelTani.Open;
   end;
end;

procedure TTanilarDlg.GelisTaniAfterPost(DataSet: TDataSet);
begin
   if YeniKayit then begin;
      GelisTani.Close;
      GelisTani.Open;
   end;
end;

procedure TTanilarDlg.ALERJIAfterPost(DataSet: TDataSet);
begin
   if YeniKayit then begin;
      ALERJI.Close;
      ALERJI.Open;
   end;
end;

procedure TTanilarDlg.ToolButton2Click(Sender: TObject);
begin
   close;
end;

end.

unit Unit1;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Grids, DBGrids, DBCtrls, Db;

type
  TLogBilgiDlg = class(TForm)
    Panel1: TPanel;
    DBMemo1: TDBMemo;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }                                                             
  end;

var
  LogBilgiDlg: TLogBilgiDlg;

implementation

{$R *.DFM}

end.

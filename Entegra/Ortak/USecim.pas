unit USecim;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, DBTables, DB, Grids, DBGrids, ExtCtrls, UFDCompatHelpers;

type
  TSecimDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    DBGrid1: TDBGrid;
    Table1: TADOTable;
    DtsSec: TDataSource;
    Label22: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SecimDlg: TSecimDlg;

implementation

{$R *.DFM}

procedure TSecimDlg.DBGrid1DblClick(Sender: TObject);
begin
  OKBtn.Click;
end;

end.


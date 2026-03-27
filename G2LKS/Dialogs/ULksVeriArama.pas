unit ULksVeriArama;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, StdCtrls, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ADODB, Buttons;

type
  TAraForm = class(TForm)
    araGridDBTableView: TcxGridDBTableView;
    araGridLevel: TcxGridLevel;
    araGrid: TcxGrid;
    tamamButton: TBitBtn;
    iptalButton: TBitBtn;
    araTable: TADOQuery;
    araTableDataSource: TDataSource;
    araGridDBTableViewDBColumn1: TcxGridDBColumn;
    araGridDBTableViewDBColumn2: TcxGridDBColumn;
    araGridDBTableViewDBColumn3: TcxGridDBColumn;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure araGridDBTableViewDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TReturnValues = array of string;

  function ShowAraForm(cnn: TADOConnection;SQL: string;searchText: string): TReturnValues;

implementation

{$R *.dfm}

function ShowAraForm(cnn: TADOConnection;SQL: string;searchText: string): TReturnValues;
var
  i : integer;
begin
  with TAraForm.Create(Application) do
    begin
      try
        araTable.Connection := cnn;
        araTable.SQL.Text := SQL;
        araTable.Open;
        araGridDBTableViewDBColumn2.Focused := True;
        if (searchText <> '') then
          araGridDBTableView.DataController.Search.Locate(0,searchText);
        if ((ShowModal = mrOK) and (araTable.RecordCount > 0)) then
          begin
            SetLength(Result,araTable.FieldCount);
            for i := 0 to araTable.FieldCount - 1 do
              Result[i] := araTable.Fields[i].AsString;
          end
        else
          begin
            SetLength(Result,1);
            Result[0] := '';
          end;
      finally
        Free;
      end;
    end;
end;

procedure TAraForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    iptalButton.Click;
end;

procedure TAraForm.araGridDBTableViewDblClick(Sender: TObject);
begin
  if (araTable.RecordCount > 0) then
    tamamButton.Click;
end;

end.

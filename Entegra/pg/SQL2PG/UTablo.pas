unit UTablo;

interface

uses
  System.SysUtils, System.Classes, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Def, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.PG, FireDAC.DApt,
  FireDAC.Comp.UI, FireDAC.VCLUI.Wait;

type
  TTablo = class(TDataModule)
    MSSQL: TFDConnection;
    PG: TFDConnection;
    QueryMSSQL: TFDQuery;
    QueryPG: TFDQuery;
    PGDriverLink: TFDPhysPgDriverLink;
    WaitCursor: TFDGUIxWaitCursor;
  end;

var
  Tablo: TTablo;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.

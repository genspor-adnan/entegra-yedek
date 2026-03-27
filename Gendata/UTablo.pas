unit UTablo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables;

type
  TTablo = class(TDataModule)
    Database1: TDatabase;
    Query1: TQuery;
    Query2: TQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Tablo: TTablo;
  Database, TabloAdi : String;

implementation

{$R *.DFM}

end.

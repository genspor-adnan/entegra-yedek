unit UTabRap;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, ADODB;

type
  TRapTablo = class(TDataModule)
    AYARLAR: TADOQuery;
    Ayar: TADOQuery;
    Kosullar: TADOTable;
    Gelisler: TADOQuery;
    Kimlik: TADOQuery;
    Rapor: TADOQuery;
    Kosullar2: TADOTable;
    Ayarayar: TADOQuery;
    AmePara: TADOQuery;
    Ameliyat: TADOQuery;
    AMESTOK: TADOQuery;
    FATURALIST: TADOQuery;
    procedure AYARLARNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RapTablo: TRapTablo;

implementation

uses Uayar,UTablo;

{$R *.DFM}

procedure TRapTablo.AYARLARNewRecord(DataSet: TDataSet);
begin
   if AyarlarDlg <> nil then
      Ayarlar.FieldByName('RAPORADI').AsString := AyarlarDlg.EkranAdi;
end;

end.

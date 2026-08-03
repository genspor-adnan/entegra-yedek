program SQL2PG;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FrmSQL2PG},
  UTablo in 'UTablo.pas' {Tablo: TDataModule},
  USQL2PGMigrator in 'USQL2PGMigrator.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SQL2PG';
  Application.CreateForm(TTablo, Tablo);
  Application.CreateForm(TFrmSQL2PG, FrmSQL2PG);
  Application.Run;
end.

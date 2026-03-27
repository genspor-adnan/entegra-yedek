program Gendata;

uses
  Forms,
  UAnaform in 'UAnaform.pas' {AnaForm},
  UTablo in 'UTablo.pas' {Tablo: TDataModule},
  USQL in 'USQL.pas' {SQLDlg},
  UYedek1 in 'UYedek1.pas' {Yedek1},
  UYedek2 in 'UYedek2.pas' {Yedek2},
  UYukle2 in 'UYukle2.pas' {Yukle2},
  UYukle1 in 'UYukle1.pas' {Yukle1},
  UYukle3 in 'UYukle3.pas' {Yukle3},
  UDuzenle in 'UDuzenle.pas' {DuzenleDlg},
  UListeDinamik in '..\Ortak\UListeDinamik.pas' {ListeDinamikDlg},
  UMesaj in '..\Ortak\Umesaj.pas' {MesajForm};

{$R *.RES}
                                       //Execute sp_addlinkedserver SONOMED01
begin
  Application.Initialize;
  Application.CreateForm(TAnaForm, AnaForm);
  Application.CreateForm(TTablo, Tablo);
  Application.CreateForm(TSQLDlg, SQLDlg);
  Application.CreateForm(TYedek1, Yedek1);
  Application.CreateForm(TYedek2, Yedek2);
  Application.CreateForm(TYukle2, Yukle2);
  Application.CreateForm(TYukle1, Yukle1);
  Application.CreateForm(TYukle3, Yukle3);
  Application.CreateForm(TDuzenleDlg, DuzenleDlg);
  Application.Run;
end.

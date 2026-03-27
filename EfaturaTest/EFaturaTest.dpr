program EFaturaTest;

uses
  Vcl.Forms,
  UTest in 'UTest.pas' {Tablo},
  Gentegre.UI.EFatura.FirmaAra in 'Gentegre.UI.EFatura.FirmaAra.pas' {EFaturaFirmaAra},
  EFaturaOIB in 'EFaturaOIB.pas',
  QNB_EFat_Service in 'QNB_EFat_Service.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTablo, Tablo);
  // Application.CreateForm(TEFaturaFirmaAra, EFaturaFirmaAra);
  Application.Run;
end.

program TrumpfAktarim;

uses
  Vcl.Forms,
  UTrumpfAktarim in 'UTrumpfAktarim.pas' {TrumpfAktarimDlg},
  FetaKurulusSiniflari in '..\Ortak\FetaKurulusSiniflari.pas',
  UGenSifre in '..\Entegra\UGenSifre.pas',
  FetaClassExtensions in '..\Ortak\FetaClassExtensions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTrumpfAktarimDlg, TrumpfAktarimDlg);
  Application.Run;
end.

program ResimAktarim;

uses
  Forms,
  SysUtils,
  Aktarim in 'Aktarim.pas' {Anaform},
  UGenSifre in 'UGenSifre.pas',
  FetaKurulusSiniflari in '..\Ortak\FetaKurulusSiniflari.pas',
  FetaClassExtensions in '..\Ortak\FetaClassExtensions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAnaform, Anaform);
  Application.Run;
end.

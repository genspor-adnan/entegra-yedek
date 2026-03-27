program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {AnaForm},
  Unit2 in 'Unit2.pas' {HareketAktarForm},
  Unit3 in 'Unit3.pas' {UrunAktarForm},
  Unit4 in 'Unit4.pas' {KampanyaForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAnaForm, AnaForm);
  Application.CreateForm(THareketAktarForm, HareketAktarForm);
  Application.CreateForm(TUrunAktarForm, UrunAktarForm);
  Application.CreateForm(TKampanyaForm, KampanyaForm);
  Application.Run;
end.

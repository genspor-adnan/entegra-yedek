program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  MD5 in 'MD5.pas',
  uEncrypt in 'uEncrypt.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

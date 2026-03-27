program MAPIOLEMailreaderTestProj;

uses
  Forms,
  MAPIOLEMailreader in 'MAPIOLEMailreader.pas' {Form1},
  GenOutLookInterface in 'GenOutLookInterface.pas',
  Outlook2010 in 'Outlook2010.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

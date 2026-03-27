program Garanti;

uses
  Vcl.Forms,
  UGaranti in 'UGaranti.pas' {GarantiDlg};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGarantiDlg, GarantiDlg);
  Application.Run;
end.

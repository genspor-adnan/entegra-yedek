program ITSProject;

uses
  Forms,
  UAnaFrom in 'UAnaFrom.pas' {AnaFromDlg},
  UItsIslemleri in 'UItsIslemleri.pas' {ITSDlg},
  UTablo in 'UTablo.pas' {Tablo: TDataModule},
  Usifre in 'Usifre.pas' {PasswordDlg},
  ULisans in 'C:\Gensoft\Delphi\Finans\Ortak\ULisans.pas' {LisansDlg},
  UItsAraclari in 'UItsAraclari.pas',
  UitsBusiness in 'UitsBusiness.pas',
  UItsEczaDepo in 'UItsEczaDepo.pas' {ITSEzcaDepoDlg};


{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAnaFromDlg, AnaFromDlg);
  Application.CreateForm(TTablo, Tablo);
  if PasswordEkrani('ITS') then begin
    Application.CreateForm(TAnaFromDlg, AnaFromDlg);
    Application.Run;
  end
  else begin
    Tablo.Destroy;
    halt;
  end;
end.

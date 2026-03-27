program RestYaz;

uses
  Vcl.Forms,
  Shellapi,
  sysutils,
  WinTypes,
  cxFormats,
  UTablo in 'UTablo.pas' {Tablo: TDataModule},
  UGENINIDuzenle in 'UGENINIDuzenle.pas' {GENINIDuzenleDlg},
  UFastRap in 'UFastRap.pas' {FastRaporDlg},
  PrjConst in '..\PrjConst.pas',
  UBaglanti in 'UBaglanti.pas' {BaglantiDlg};

{$R *.res}

begin
  Application.Initialize;
  if GetThreadLocale <> $41F then
     SetThreadLocale($41F);
  GetFormatSettings;
  cxFormatController.UseDelphiDateTimeFormats := True;

  Application.ShowMainForm := False;
  Application.CreateForm(TBaglantiDlg, BaglantiDlg);
  Application.CreateForm(TTablo, Tablo);
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.

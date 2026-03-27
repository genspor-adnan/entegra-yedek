program PersonaPROCESS;

uses
  Forms,
  sysUtils,
  ComObj,
  uAnaForm in 'uAnaForm.pas' {AnaForm},
  uTablo in 'uTablo.pas' {Tablo: TDataModule},
  uAyarForm in 'uAyarForm.pas' {AyarlarForm},
  UVersiyon in 'UVersiyon.pas' {VersiyonDlg},
  GT_About in 'GT_About.pas' {AboutBox},
  uLogo in 'uLogo.pas' {LOGO},
  RFID_103_485IO_DLL in 'RFID_103_485IO_DLL.pas',
  uCamera in 'uCamera.pas' {Camera},
  Unit2 in 'Unit2.pas',
  uAnvizProtokol in 'uAnvizProtokol.pas',
  Uizin in 'Uizin.pas' {IzinDlg},
  uFingerPrint in 'uFingerPrint.pas',
  AKSREADERLib_TLB in 'AKSREADERLib_TLB.pas',
  FK203IDLib_TLB in 'FK203IDLib_TLB.pas',
  zkemkeeper_TLB in 'zkemkeeper_TLB.pas',
  ZKRFCtrl_TLB in 'ZKRFCtrl_TLB.pas',
  UVeriAl in 'UVeriAl.pas' {FrmVeriAktarým},
  FKAttendLib_TLB in 'FKAttendLib_TLB.pas',
  UTanim in 'UTanim.pas',
  UCombo in 'UCombo.pas' {ListeAyarlaDlg},
  UGirisKutusuEx in '..\Ortak\UGirisKutusuEx.pas' {GirisKutusuEx},
  UTouchKeyboardWindow in 'UTouchKeyboardWindow.pas',
  UGENINIDuzenle in '..\Entegra\UGENINIDuzenle.pas' {GENINIDuzenleDlg},
  UGenSifre in '..\Entegra\UGenSifre.pas',
  FetaKurulusSiniflari in '..\Ortak\FetaKurulusSiniflari.pas',
  FetaClassExtensions in '..\Ortak\FetaClassExtensions.pas',
  Fetautil in '..\Ortak\Fetautil.pas',
  PrjConst in '..\Entegra\PrjConst.pas',
  Usifre in 'Usifre.pas' {PasswordDlg};

{$R *.res}

begin
  FormatSettings.CurrencyString := ' YTL';
  FormatSettings.CurrencyFormat := 3;
  FormatSettings.NegCurrFormat := 8;
  FormatSettings.ThousandSeparator := ',';
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.CurrencyDecimals := 2;
  FormatSettings.DateSeparator := '/';
  FormatSettings.ShortDateFormat := 'dd/MM/yyyy';
  FormatSettings.LongDateFormat := 'dd MMMM yyyy dddd';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.TimeAMString := '';
  FormatSettings.TimePMString := '';
  FormatSettings.ShortTimeFormat := 'hh:mm';
  FormatSettings.LongTimeFormat := 'hh:mm:ss';
  FormatSettings.ListSeparator := ';';
  if ParamCount > 0 then
  begin

    AdimAdimGoster := ParamStr(1) = '?';
  end;
  Application.Initialize;
  Adim('Application.CreateForm(TLOGO, LOGO);');
  Application.CreateForm(TLOGO, LOGO);
  Application.CreateForm(TListeAyarlaDlg, ListeAyarlaDlg);
 // Application.CreateForm(TPasswordDlg, PasswordDlg);
  Adim('Application.CreateForm(TCamera, Camera);');
  Application.CreateForm(TCamera, Camera);
  Adim(' LOGO.Show;');
  LOGO.Show;
  Adim(' LOGO.Update;');
  LOGO.Update;
  Adim(' Application.Title');
  Application.Title := 'PERSONELPROCESS';
  Adim(' Application.CreateForm(TTablo, Tablo);');
  Application.CreateForm(TTablo, Tablo);
  Adim('Tablo.TabKullan.Open;');
  Tablo.TabKullan.Open;
  Adim(' logo.Destroy;');
  logo.Destroy;
//  if SifreSor then
//    PasswordEkrani('PERSONEL');
  Adim('Application.CreateForm(TAnaForm, AnaForm);');
  try
    Application.CreateForm(TAnaForm, AnaForm);
  except

    on e: Eolesyserror do
    begin
      Adim('regsvr32 "<dll dosyasý>" komutuyla aþaðýdaki dllleri kaydetmelisiniz');
      Adim('zkemkeeper.dll');
      Adim('commpro.dll');
      Adim('msvcr71.dll');
      Adim('plce.dll');
      Adim('comms.dll');
      Adim('rscagent.dll');
      Adim('rscomm.dll');
      Adim('zkemsdk.dll');
      Adim('ör: regsvr32 "c:\persona\zkemkeeper.dll"');
      Adim('Exception:' + e.Message);
    end;
    on e: exception do
      Adim('TAnaForm  CreateForm ' + e.Message + ' ' + e.ClassName);
  end;
  Adim('Camera.OpenVideo(GENINI.ReadString');
  //Camera.OpenVideo(GENINI.ReadString('OPSIYONLAR', 'CAMERA', ''));
 
  Adim(' Application.Run;');
  Application.Run;
end.


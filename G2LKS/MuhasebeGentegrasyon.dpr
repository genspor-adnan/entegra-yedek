program MuhasebeGentegrasyon;

uses
  Forms,
  Windows,
  SysUtils,
  cxFormats,
  UAnaform in 'UAnaform.pas' {AnaForm},
  UTablo in 'UTablo.pas' {Tablo: TDataModule},
  UOpsiyon in 'UOpsiyon.pas' {OpsiyonDlg},
  Fetautil in '..\Ortak\Fetautil.pas',
  UCombo in '..\Ortak\UCombo.pas' {ListeAyarlaDlg},
  Uliste in '..\Ortak\Uliste.pas' {ListeDlg},
  UPrinter in '..\Ortak\UPrinter.pas' {PrinterDlg},
  UQuantGrid in '..\Ortak\UQuantGrid.pas' {QuantGrid: TDataModule},
  UAnaListe in 'UAnaListe.pas' {AnaListe},
  UPaylasim in '..\Ortak\UPaylasim.pas',
  UVersiyon in 'UVersiyon.pas' {VersiyonDlg},
  uParolaTanim in '..\Ortak\uParolaTanim.pas' {ParolaTanim},
  uEncrypt in '..\Ortak\uEncrypt.pas',
  GT_About in 'GT_About.pas' {AboutBox},
  ULogo in 'ULogo.pas' {Logo},
  UReferansAra in 'UReferansAra.pas' {ReferansAraDlg},
  UGenelAktarimAyarlari in 'Opsiyonlar\UGenelAktarimAyarlari.pas' {aktarimAyarlariForm: TFrame},
  UKurumEslestirmeleri in 'Opsiyonlar\UKurumEslestirmeleri.pas' {kurumEslemeForm: TFrame},
  ULogoParametreleri in 'Opsiyonlar\ULogoParametreleri.pas' {logoParametreleriForm: TFrame},
  UInfoForm in '..\Ortak\UInfoForm.pas' {infoForm},
  UGenelParametreler in 'Opsiyonlar\UGenelParametreler.pas' {GenelParametrelerForm: TFrame},
  UHataDialog in '..\Ortak\UHataDialog.pas' {ErrorDialogForm},
  ULksVeriArama in 'Dialogs\ULksVeriArama.pas' {AraForm},
  UHataKontrol in 'UHataKontrol.pas' {HataKontrolForm},
  USenaryoDuzenleyiciFrame in 'Opsiyonlar\USenaryoDuzenleyiciFrame.pas' {SenaryoDuzenleyiciFrame: TFrame},
  UAktarimSonAsamaForm in 'UAktarimSonAsamaForm.pas' {AktarimSonAsamaForm},
  UHizmetHataDuzeltmeFrame in 'HataDuzeltme\UHizmetHataDuzeltmeFrame.pas' {HizmetHataDuzeltmeFrame: TFrame},
  UReferansHataDuzeltmeFrame in 'HataDuzeltme\UReferansHataDuzeltmeFrame.pas' {ReferansHataDuzeltmeFrame: TFrame},
  UHastaHataDuzeltmeFrame in 'HataDuzeltme\UHastaHataDuzeltmeFrame.pas' {HastaHataDuzeltmeFrame: TFrame},
  UKurumHataDuzeltmeFrame in 'HataDuzeltme\UKurumHataDuzeltmeFrame.pas' {KurumHataDuzeltmeFrame: TFrame},
  UBosHataDuzeltmeFrame in 'HataDuzeltme\UBosHataDuzeltmeFrame.pas' {BosHataDuzeltmeFrame: TFrame},
  USecenekHataDuzeltmeFrame in 'HataDuzeltme\USecenekHataDuzeltmeFrame.pas' {SecenekHataDuzeltmeFrame: TFrame},
  UKayitKabulHataDuzeltmeFrame in 'HataDuzeltme\UKayitKabulHataDuzeltmeFrame.pas' {KayitKabulHataDuzeltmeFrame: TFrame},
  UKurumEslestir in 'UKurumEslestir.pas' {KurumEslestirDlg},
  UKurumAraDlg in 'UKurumAraDlg.pas' {KurumAraDlg},
  UTahsilatEslestirDlg in 'UTahsilatEslestirDlg.pas' {TahsilatEslestirDlg},
  UBelgeDosya in 'UBelgeDosya.pas' {BelgeDosyaDlg},
  PrjConst in '..\Entegra\PrjConst.pas',
  UKullaniciBilgisi in '..\Ortak\UKullaniciBilgisi.pas',
  oPENsqlsERVER in '..\Ortak\oPENsqlsERVER.pas' {OpenSQLServerForm},
  FetaKurulusSiniflari in '..\Ortak\FetaKurulusSiniflari.pas',
  FetaClassExtensions in '..\Ortak\FetaClassExtensions.pas',
  FetaClassExtensionsConsts in '..\Ortak\FetaClassExtensionsConsts.pas',
  UGentegreFrameYonetimi in '..\Entegra\UGentegreFrameYonetimi.pas',
  UFrameYoneticisi in '..\Ortak\UFrameYoneticisi.pas',
  UMultiCastEvent in '..\Ortak\UMultiCastEvent.pas',
  UGrid in '..\Ortak\UGrid.pas' {GridAyarlaDlg},
  dlgSearchText in '..\Ortak\dlgSearchText.pas' {TextSearchDialog},
  dlgReplaceText in '..\Ortak\dlgReplaceText.pas' {TextReplaceDialog},
  dlgConfirmReplace in '..\Ortak\dlgConfirmReplace.pas' {ConfirmReplaceDialog},
  SynEditTypes in 'D:\DelphiComp\Component2010\SynEdit\Source\SynEditTypes.pas',
  SynEditMiscProcs in 'D:\DelphiComp\Component2010\SynEdit\Source\SynEditMiscProcs.pas',
  UScriptEngine in '..\Ortak\UScriptEngine.pas',
  UCustomDataManager in '..\Ortak\UCustomDataManager.pas',
  UTextTable in '..\Ortak\UTextTable.pas',
  UOnayDialog in '..\Ortak\UOnayDialog.pas' {ConfirmDialogForm},
  Uaradlg in '..\Ortak\Uaradlg.pas' {AraDlg},
  UTouchKeyboardWindow in '..\Entegra\UTouchKeyboardWindow.pas',
  UGENINIDuzenle in '..\Entegra\UGENINIDuzenle.pas' {GENINIDuzenleDlg},
  Usifre in 'Ortak\Usifre.pas' {PasswordDlg},
  UFastRap in 'Ortak\UFastRap.pas' {FastRaporDlg},
  UProgramSonuDialog in 'Ortak\UProgramSonuDialog.pas',
  Compress in '..\Ortak\Compress.pas',
  lisansWS in '..\Ortak\lisansWS.pas',
  ULisans in 'Ortak\ULisans.pas' {LisansDlg},
  UGenSifre in 'Ortak\UGenSifre.pas',
  MD5 in 'MD5.pas',
  URehberAramaEkrani in '..\Entegra\URehberAramaEkrani.pas' {RehberAramaEkrani},
  UGirisKutusuEx in '..\Ortak\UGirisKutusuEx.pas' {GirisKutusuEx},
  ULKSTransformator in 'ULKSTransformator.pas',
  UBaglantiAyarlari in 'Opsiyonlar\UBaglantiAyarlari.pas' {BaglantiAyarlariForm: TFrame},
  UKullanimKlavuzu in 'UKullanimKlavuzu.pas' {KullanimKlavuzu},
  URaporAraclari in '..\Entegra\URaporAraclari.pas',
  UTabloGiris in 'Ortak\UTabloGiris.pas' {TabloGirisDlg};

{$R *.RES}

begin

//  Application.CreateForm(TLogo, Logo);
//  Logo.Show;
//  Logo.Update;
//  sleep(2000);
  Application.Initialize;
  Application.UpdateFormatSettings := False;
  GetFormatSettings;
  cxFormatController.UseDelphiDateTimeFormats := True;
  // Genotýp özel bölgesel ayarlarý.
 { CurrencyString := 'YTL';
  CurrencyFormat := 3;
  NegCurrFormat := 8;
  ThousandSeparator := ',';
  DecimalSeparator := '.';
  CurrencyDecimals := 2 ;
  DateSeparator := '/';
  ShortDateFormat := 'dd/MM/yyyy';
  LongDateFormat := 'dd MMMM yyyy dddd';
  TimeSeparator := ':';
  TimeAMString := '' ;
  TimePMString := '' ;
  ShortTimeFormat := 'hh:mm';
  LongTimeFormat := 'hh:mm:ss'; }
  FormatSettings.ListSeparator := ';';
  Application.Title := 'Gentegre --> Muhasebe Entegrasyon Modülü 1.00';
  Application.CreateForm(TTablo, Tablo);
  //Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
 // Tablo.TabKullan.Open;
  PasswordEkrani('G2LKS');
  Application.CreateForm(TAnaForm, AnaForm);
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);

  //TabloDokum.Ini := GenotipIni;

  Application.CreateForm(TAnaListe, AnaListe);
  Randomize;
  Application.Run;
 end.



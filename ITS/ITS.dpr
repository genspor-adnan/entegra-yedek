program ITS;



{$R *.dres}

uses
  Forms,
  UTablo in 'UTablo.pas' {Tablo: TDataModule},
  Usifre in 'Usifre.pas' {PasswordDlg},
  UBekletme in 'UBekletme.pas' {BekletmeDlg},
  UItsAraclari in 'UItsAraclari.pas',
  UitsBusiness in 'UitsBusiness.pas',
  UItsBildirim in 'UItsBildirim.pas' {ITSBildirimDlg},
  UBelge in 'UBelge.pas' {BelgeListeDlg},
  UUretim in 'UUretim.pas' {UretimDlg},
  UOpsiyon in 'UOpsiyon.pas' {OpsiyonDlg},
  USatis in 'USatis.pas' {SatisDlg},
  UUret in 'UUret.pas' {UretDlg},
  PrjConst in '..\Entegra\PrjConst.pas',
  UTouchKeyboardWindow in '..\Entegra\UTouchKeyboardWindow.pas',
  lisansws in '..\Entegra\lisansws.pas',
  UAlim in 'UAlim.pas' {MalAlimDlg},
  UDeAktivasyon in 'UDeAktivasyon.pas' {DeAktivasyonDlg},
  UPaketAl in 'UPaketAl.pas' {PaketAlDlg},
  KAZip in 'KAZip.pas',
  PTSPackageReceiverWebService in 'PTSPackageReceiverWebService.pas',
  PTSPackageSenderWebService in 'PTSPackageSenderWebService.pas' {$R *.res},
  UDokumlerAksiyonFrame in '..\Entegra\AramaFrame\UDokumlerAksiyonFrame.pas' {DokumlerAksiyonFrame: TFrame},
  UGenelAnaSekmeFrame in '..\Entegra\AnaFrame\UGenelAnaSekmeFrame.pas' {GenelAnaSekmeFrame: TFrame},
  UCombo in '..\Ortak\UCombo.pas' {ListeAyarlaDlg},
  Umesaj in '..\Ortak\Umesaj.pas' {MesajForm},
  FetaClassExtensions in '..\Ortak\FetaClassExtensions.pas',
  FetaClassExtensionsConsts in '..\Ortak\FetaClassExtensionsConsts.pas',
  FetaKurulusSiniflari in '..\Ortak\FetaKurulusSiniflari.pas',
  EParser in '..\Ortak\EParser.pas',
  oPENsqlsERVER in '..\Ortak\oPENsqlsERVER.pas' {OpenSQLServerForm},
  Fetautil in '..\Ortak\Fetautil.pas',
  UGirisKutusuEx in '..\Ortak\UGirisKutusuEx.pas' {GirisKutusuEx},
  UTablodanDuzenle in 'UTablodanDuzenle.pas' {TablodanDuzenleDlg},
  Uliste in '..\Ortak\Uliste.pas' {ListeDlg},
  UFastRap in '..\Ortak\UFastRap.pas' {FastRaporDlg},
  URaporAraclari in '..\Entegra\URaporAraclari.pas',
  UQuantGrid in '..\Ortak\UQuantGrid.pas' {QuantGrid: TDataModule},
  UGentegreFrameYonetimi in '..\Entegra\UGentegreFrameYonetimi.pas',
  UFrameYoneticisi in '..\Ortak\UFrameYoneticisi.pas',
  UMultiCastEvent in '..\Ortak\UMultiCastEvent.pas',
  UGenSifre in '..\Ortak\UGenSifre.pas',
  UPaylasim in '..\Ortak\UPaylasim.pas' {$R *.res},
  UDokum in '..\Ortak\UDokum.pas' {DokumDlg: TFrame},
  UGrid in '..\Ortak\UGrid.pas' {GridAyarlaDlg},
  uKosulDetayAra in '..\Ortak\uKosulDetayAra.pas' {KosulDetayAra},
  UDokumSart in '..\Entegra\IcerikFrame\UDokumSart.pas' {DokumSartDlg},
  dlgConfirmReplace in '..\Ortak\dlgConfirmReplace.pas' {ConfirmReplaceDialog},
  dlgReplaceText in '..\Ortak\dlgReplaceText.pas',
  dlgSearchText in '..\Ortak\dlgSearchText.pas' {TextSearchDialog},
  ZLIBEX in '..\Ortak\ZLIBEX.pas',
  UMultiDataSetEvent in '..\Entegra\UMultiDataSetEvent.pas',
  UDokumAramaFrame in '..\Entegra\AramaFrame\UDokumAramaFrame.pas' {DokumAramaFrame: TFrame},
  UDokumGirisFrame in '..\Entegra\GirisSayfaFrame\UDokumGirisFrame.pas' {DokumGirisFrame: TFrame},
  UAnaForm in 'UAnaForm.pas' {AnaFormDlg},
  UTasimaBirimi in 'UTasimaBirimi.pas' {TasimaBirimiGirisDlg},
  UPaketleme in 'UPaketleme.pas' {PaketlemeDlg},
  UGenelGirisSayfasiFrame in '..\Entegra\GirisSayfaFrame\UGenelGirisSayfasiFrame.pas' {GenelGirisSayfasiFrame: TFrame},
  USiparisMalSatis in 'USiparisMalSatis.pas' {SiparisMalSatisDlg},
  USatisIptal in 'USatisIptal.pas' {SatisIptalDlg},
  UHizliUrunCikis in 'UHizliUrunCikis.pas' {HizliUrunCikisDlg},
  UUrunListe in 'UUrunListe.pas' {UrunListeDlg},
  UBildirilmisPaketler in 'UBildirilmisPaketler.pas' {BildirilmisPaketlerDlg},
  UAdetEkle in 'UAdetEkle.pas' {AdetEkleDlg},
  UGENINIDuzenle in '..\Entegra\UGENINIDuzenle.pas' {GENINIDuzenleDlg},
  GenUpdateWS in '..\Entegra\GenUpdateWS.pas',
  UVersiyonGuncelle in '..\Entegra\UVersiyonGuncelle.pas';

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := rue;
  Application.Initialize;
  Application.Title := 'Ýlaç Takip Sistemi';
  Application.CreateForm(TTablo, Tablo);
  if PasswordEkrani('ITS') then begin
    Application.CreateForm(TAnaFormDlg, AnaFormDlg);
    Application.CreateForm(TFastRaporDlg, FastRaporDlg);
    TRaporAraclari.Ini := RehberIni;
  Application.Run;
  end;
  Tablo.Free;


end.

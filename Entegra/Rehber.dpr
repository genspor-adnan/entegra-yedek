program Rehber;

uses
  Forms,
  UAnaForm in 'UAnaForm.pas' {AnaForm},
  Utablo in 'Utablo.pas' {Tablo: TDataModule},
  UFIRMALAR in 'UFIRMALAR.pas' {KurumDlg},
  UTabDok in '..\Ortak\UTabDok.pas' {TabloDokum: TDataModule},
  UTabRap in 'UTabRap.pas' {RapTablo: TDataModule},
  Uayar in '..\Ortak\UAYAR.pas' {AyarlarDlg},
  URapSyf in '..\Ortak\Urapsyf.pas' {RapSyf},
  UMesaj in '..\Ortak\Umesaj.pas' {MesajForm},
  UDokum in '..\Ortak\UDokum.pas' {DokumDlg},
  UDokSart in '..\Ortak\UDokSart.pas' {DokumSartDlg},
  Fetautil in '..\Ortak\Fetautil.pas',
  UCombo in '..\Ortak\UCombo.pas' {ListeAyarlaDlg},
  UEtiAlan in '..\Ortak\UEtiAlan.pas' {EtiketAlanDlg},
  Uetiket in '..\Ortak\Uetiket.pas' {Etiket},
  UListe in '..\Ortak\Uliste.pas' {ListeDlg},
  UGrid in '..\Ortak\UGrid.pas' {GridAyarlaDlg},
  USifre in '..\Ortak\Usifre.pas' {PasswordDlg},
  UCari in 'UCari.pas' {CariDlg},
  URehAraDlg in 'UReharadlg.pas' {RehberAraDlg},
  UPrinter in '..\Ortak\UPrinter.pas' {PrinterDlg},
  UPaylasim in '..\Ortak\UPaylasim.pas',
  ULisans in '..\Ortak\ULisans.pas' {LisansDlg},
  UCariHar in 'UCariHar.PAS' {RehberCariDlg},
  UKasa in 'UKasa.PAS' {KasaDlg},
  Ulogo in 'ULOGO.PAS' {Logo},
  UFatura in 'UFatura.pas' {FaturaDlg},
  UUzunBul in '..\Kabul\Uuzunbul.pas',
  UQuantGrid in '..\Ortak\UQuantGrid.pas' {QuantGrid: TDataModule},
  UVirman in 'UVirman.pas' {VirmanDlg},
  UOpsDlg in 'UOPSDLG.pas' {OpsiyonDlg},
  UIslemSec in 'UIslemSec.pas' {IslemSecDlg},
  Udoktor in '..\Kabul\UDOKTOR.PAS' {DoktorDlg},
  URehber in '..\Kabul\URehber.pas' {RehberDlg},
  UListeCheck in '..\ortak\UlisteCheck.pas' {ListeCheckDlg},
  GT_RehberAbout in 'GT_RehberAbout.pas' {AboutBox},
  UVersiyon in 'UVersiyon.pas' {VersiyonDlg};

{$R *.RES}

begin
   Application.Initialize;
   Application.Title := 'Rehber Modülü GenoTIP 2005 HBS';
  Application.CreateForm(TTablo, Tablo);

   Tablo.TabKullan.Open;
   Tablo.TabKulHar.Open;
   PasswordEkrani('Rehber');
  Application.CreateForm(TAnaForm, AnaForm);
  Application.CreateForm(TListeCheckDlg, ListeCheckDlg);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TVersiyonDlg, VersiyonDlg);
  QuantRehCari := TQuantGrid.Create(Application);
   Application.CreateForm(TRehberCariDlg, RehberCariDlg);

   QuantKasa := TQuantGrid.Create(Application);
   Application.CreateForm(TKasaDlg, KasaDlg);

   QuantHar := TQuantGrid.Create(Application);
  Application.CreateForm(TCariDlg, CariDlg);


{   Application.CreateForm(TPasswordDlg, PasswordDlg);
   PasswordDlg.TabKullan := Tablo.TabKullan;
   PasswordDlg.Modul := 'Rehber';
   PasswordDlg.ShowModal;
   if PasswordDlg.ModalResult = idCANCEL then
      Application.Terminate();
   KullanAdi := PasswordDlg.KullanAdi;
   PasswordDlg.Destroy;
}
   Application.CreateForm(TTabloDokum, TabloDokum);
   TabloDokum.Modul := 'C';
   TabloDokum.Ini := GenotipIni;
   Application.CreateForm(TRapTablo, RapTablo);
   Application.CreateForm(TRapSyf, RapSyf);
   RaporDokumBasla(RapTablo);
   Application.CreateForm(TKurumDlg, KurumDlg);
   Application.CreateForm(TRehberAraDlg, RehberAraDlg);
   Application.Run
end.

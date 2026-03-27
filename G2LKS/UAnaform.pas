unit UAnaform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Grids, DBGrids, ExtCtrls, ComCtrls, Buttons, Mask,md5,
  DBCGrids, Menus, Db, XPMenu, ToolWin,UProgramSonuDialog, cxClasses,
  cxGridCustomPopupMenu, cxGridPopupMenu, dxBarBuiltInMenu;

type
  TAnaForm = class(TForm)
    CoolBar1: TCoolBar;
    AletCubugu: TToolBar;
    G2LKSTus: TToolButton;
    ToolButton1: TToolButton;
    EkranYaz: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton5: TToolButton;
    ToolBarNavigator: TDBNavigator;
    KimlikTus: TButton;
    GelislerTus: TButton;
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    G2Likom1: TMenuItem;
    Dkmler1: TMenuItem;
    GenelDokumler: TMenuItem;
    mnAraclar: TMenuItem;
    Opsiyonlar1: TMenuItem;
    Hakknda1: TMenuItem;
    Hakknda2: TMenuItem;
    G2Likom2: TMenuItem;
    N1: TMenuItem;
    k1: TMenuItem;
    N2: TMenuItem;
    nerimvar1: TMenuItem;
    Eletirmeler1: TMenuItem;
    KurumEletirmeleri1: TMenuItem;
    mnTahsilatEsletir: TMenuItem;
    KullanmKlavuzu1: TMenuItem;
    cxGridPopupMenu1: TcxGridPopupMenu;
    pmGridStil: TPopupMenu;
    AlanYnetimi1: TMenuItem;
    EnUygunGenilieAyarla1: TMenuItem;
    GrupAKapa1: TMenuItem;
    GrupA1: TMenuItem;
    GrupKapat1: TMenuItem;
    Kaydet: TMenuItem;
    ButunkullanclarMenu: TMenuItem;
    KullancVarsaylanolarak1: TMenuItem;
    FarklKaydet1: TMenuItem;
    DierKullancAyarlar1: TMenuItem;
    KaytlKullancAyarSil: TMenuItem;
    GridAyarlarnSfrla1: TMenuItem;
    StilOlutur1: TMenuItem;
    ExceleAktar1: TMenuItem;
    procedure Opsiyonlar1Click(Sender: TObject);
    procedure k1Click(Sender: TObject);
    procedure G2LKSTusClick(Sender: TObject);
    procedure GenelDokumlerClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EkranYazClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Hakknda2Click(Sender: TObject);
    procedure KurumEletirmeleri1Click(Sender: TObject);
    procedure mnTahsilatEsletirClick(Sender: TObject);
    procedure KullanmKlavuzu1Click(Sender: TObject);
  private
    { Private declarations }
    procedure InitYeniEkranToolbar(Dts:TDataSource; TusBaslik, AktifEkran:String);
  public
    { Public declarations }
  end;

var
  AnaForm: TAnaForm;

implementation
uses
Utablo, UOpsiyon, UAnaListe, GT_About,UVersiyon, FetaUtil,
   UKurumEslestir, UTahsilatEslestirDlg,UKullanimKlavuzu,FetaKurulusSiniflari;
{$R *.DFM}



procedure TAnaForm.InitYeniEkranToolbar(Dts:TDataSource; TusBaslik, AktifEkran:String);
begin
  if Dts = nil then
     ToolBarNavigator.Visible := False
  else begin
     ToolBarNavigator.Visible := True;
     ToolBarNavigator.DataSource := Dts;
  end;
  EkranYaz.Caption := TusBaslik;
  YaziciYaz.Caption := TusBaslik;
  //TabloDokum.EkranYaziciInit(EkranYaz, YaziciYaz);
  AnaForm.ActiveMDIChild.WindowState := wsMaximized;
end;

procedure TAnaForm.Opsiyonlar1Click(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);
  if OpsiyonDlg.ShowModal = mrOK then
    Tablo.SaveConfiguration
  else
    Tablo.LoadConfiguration;
  OpsiyonDlg.Free;
end;

procedure TAnaForm.k1Click(Sender: TObject);
begin
  Close;
end;

procedure TAnaForm.KullanmKlavuzu1Click(Sender: TObject);
begin
  Application.CreateForm(TKullanimKlavuzu,KullanimKlavuzu);
  KullanimKlavuzu.Showmodal;
  FreeAndNil(KullanimKlavuzu);
end;

procedure TAnaForm.KurumEletirmeleri1Click(Sender: TObject);
begin
  if KurumEslestirDlg=nil then
   Application.CreateForm(TKurumEslestirDlg, KurumEslestirDlg);

   KurumEslestirDlg.ShowModal;
   FreeAndNil(KurumEslestirDlg);
  
end;

procedure TAnaForm.mnTahsilatEsletirClick(Sender: TObject);
begin
  if TahsilatEslestirDlg=nil then
   Application.CreateForm(TTahsilatEslestirDlg, TahsilatEslestirDlg);
   TahsilatEslestirDlg.ShowModal;
   FreeAndNil(TahsilatEslestirDlg);
end;

procedure TAnaForm.G2LKSTusClick(Sender: TObject);
begin
   AnaListe.Show;
   InitYeniEkranToolbar(nil, 'G2LKS', 'G2LKSdlg');
//   Tablo.YetkiTuslariBelirle('Laboratuvar', '', 'AES', Tablo.DtsLabor, AnaForm.ToolBarNavigator);
end;

procedure TAnaForm.GenelDokumlerClick(Sender: TObject);
begin
//   if TabloDokum.TabDokum.RecordCount = 0 then
//      TabloDokum.GenelRaporSecClick(@Self)
end;

procedure TAnaForm.FormShow(Sender: TObject);
var Tamam : Boolean;
begin
{   TabloDokum.TabDokum.Parameters[0].Value := '%'+TabloDokum.Modul+'%';
   TabloDokum.TabDokum.Parameters[1].Value := KullanAdi;
   TabloDokum.TabDokum.Parameters[2].Value := KullanAdi;
   TabloDokum.TabDokum.Open;
   TabloDokum.TabDokum.First;
   while (GenelDokumler <>nil)and(not TabloDokum.TabDokum.eof) do begin
     Tamam := True;
     if (Tablo.KullaniciBilgisi(KullanAdi, TabloDokum.TabDokum.FieldByName('RAPORADI').AsString))then
         Tamam := False;
     if (Tamam)or(Tablo.TabKulHar.FieldByName('GORME').AsString='1')then
         TabloDokum.MenuIslemleri(GenelDokumler, TabloDokum.GenelRaporSecClick, 'Ekle', TabloDokum.TabDokum.FieldByName('RAPORADI').AsString, '',-1);
     TabloDokum.TabDokum.Next;
   end;  }
end;

procedure TAnaForm.EkranYazClick(Sender: TObject);
begin
{   if ActiveMDIChild.Name = 'DokumDlg' then begin
       DokumDlg.GenelDokumler_EkranYazici(Sender);
      exit;
   end;
   if ActiveMDIChild.Name= 'AnaListe' then
     RapTablo.FATURALIST:= Tablo.TabFaturaListesi;

   TabloDokum.Ekran_Yazici_Islemi(Sender); }
end;

procedure TAnaForm.FormCreate(Sender: TObject);
var
  cst,Ser_Name, DB_Name : string;
begin

//   InitYeniEkranToolbar(nil, 'Giykimbil', 'Analistedlg');
     cst := tablo.cnn.ConnectionString;

     Ser_Name := copy(cst, pos(';Data Source=',cst)+13, pos(';Use Procedure for Prepare=',cst)-pos(';Data Source=',cst)-13);
     DB_Name  := copy(cst, pos('Initial Catalog=',cst)+16, pos(';Data Source=',cst)-pos('Initial Catalog=',cst)-16);

     StatusBar1.Panels[0].Text := KullanAdi+' ('+Kullanan+')';
     StatusBar1.Panels[1].Text := Ser_Name+' / '+DB_Name ;
     Caption:='Gentegrasyon -->Muhasebe Aktarým '+DosyaSistemi.SurumBilgisi(ParamStr(0),False,'.',True);

     AnaForm.EkranYaz.Caption:='G2LKS';
     AnaForm.YaziciYaz.Caption:='G2LKS';

     StatusBar1.Panels[2].Text:= 'Dosya Sürümü : '+ GetFileVersion(Application.ExeName);
     Tablo.Query3.Close;
     Tablo.Query3.SQL.Text:= 'SELECT @@SPID';
     Tablo.Query3.Open;
     StatusBar1.Panels[3].Text:= 'SPID : '+Tablo.Query3.fields[0].AsString;

//     if Tablo.KullaniciBilgisi(KullanAdi,'G2LKS-Araçlar') then
//      mnAraclar.Visible:= Tablo.TabKulhar.FieldByName('GORME').AsString='1'
//     else
//      mnAraclar.Visible:=False;

end;

procedure TAnaForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  CanClose :=AskForApplicationExit; //(MessageDlg('Program kapatýlacaktýr. Onaylýyor musunuz ?',mtConfirmation,    [mbYes,mbNo],0) = mrYes);
end;

procedure TAnaForm.Hakknda2Click(Sender: TObject);
begin
  Application.CreateForm(TAboutBox,AboutBox);
  AboutBox.Showmodal;
  FreeAndNil(AboutBox);
end;

end.

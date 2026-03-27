unit UOpsiyonFatura;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, StdCtrls, cxListBox, cxControls,
  cxContainer, cxEdit, cxGroupBox, Buttons, ComCtrls, dxSkinLondonLiquidSky,
  Menus, cxButtons, cxCheckBox, ExtCtrls, ToolWin, FetaKurulusSiniflari,UGENINIDuzenle,
  cxGraphics, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel, cxRadioGroup, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, FireDAC.Comp.Client, UIskontoYetki,
  cxButtonEdit,UKodAgaci, cxImageComboBox, cxLookAndFeels, cxNavigator, UMailSablon, cxDBEdit,
  dxSkinLiquidSky, dxBarBuiltInMenu, cxPC, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations, cxCustomListBox, cxSpinEdit, dxCoreGraphics;

type
  TOpsiyonFaturaDlg = class(TForm)
    PageControl1: TPageControl;
    GelenFaturaPage: TTabSheet;
    GidenFaturaPage: TTabSheet;
    TabSheetGenel: TTabSheet;
    CheckFaturaPlaniOlustur: TcxCheckBox;
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cxGroupBox9: TcxGroupBox;
    rdSatirlaraVade: TcxRadioButton;
    rdBasligaVade: TcxRadioButton;
    GBGidFatListe: TcxGroupBox;
    GridListeDuzenle: TcxGrid;
    GridListeDuzenleDBTableView1: TcxGridDBTableView;
    GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn;
    GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn;
    GridListeDuzenleLevel1: TcxGridLevel;
    TabListeDuzenle: TFDQuery;
    DtsListeDuzenle: TDataSource;
    GBGidFatDetay: TcxGroupBox;
    GBGelFatListe: TcxGroupBox;
    GBGelFatDetay: TcxGroupBox;
    GridListeDetayDuzenle: TcxGrid;
    GridListeDetayDuzenleTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TabListeDetayDuzenle: TFDQuery;
    DtsTabListeDetayDuzenle: TDataSource;
    cxGroupBox5: TcxGroupBox;
    GelenFaturaDetaySablonList: TcxListBox;
    ToolBar1: TToolBar;
    GelenFaturaDetaySablonEkleTus: TToolButton;
    GelenFaturaDetayDuzeltTus: TToolButton;
    GelenFaturaDetaySilTus: TToolButton;
    cxGroupBox7: TcxGroupBox;
    GelenSiparisDetaySablonList: TcxListBox;
    ToolBar3: TToolBar;
    GelenSiparisDetaySablonEkleTus: TToolButton;
    GelenSiparisDetaySablonDuzenleTus: TToolButton;
    GelenSiparisDetaySablonSilTus: TToolButton;
    cxGroupBox6: TcxGroupBox;
    GidenFaturaDetaySablonList: TcxListBox;
    ToolBar2: TToolBar;
    GidenFaturaDetayEkleTus: TToolButton;
    GidenFaturaDetayDuzeltTus: TToolButton;
    GidenFaturaDetaySilTus: TToolButton;
    cxGroupBox8: TcxGroupBox;
    GidenSiparisDetaySablonList: TcxListBox;
    ToolBar4: TToolBar;
    GidenSiparisDetaySablonEkleTus: TToolButton;
    GidenSiparisDetaySablonDuzeltTus: TToolButton;
    GidenSiparisDetaySablonSilTus: TToolButton;
    cxGroupBox1: TcxGroupBox;
    ComboDijitBr: TcxComboBox;
    ComboDijitTut: TcxComboBox;
    cxLabel2: TcxLabel;
    cxLabel1: TcxLabel;
    Label1: TLabel;
    VarsayilanKlasor: TcxButtonEdit;
    Label2: TLabel;
    VarsayilanKlasorSiparis: TcxButtonEdit;
    chStkVarsKalmayanGoster: TcxCheckBox;
    cxGroupBox2: TcxGroupBox;
    btnExcelKolon: TcxButton;
    cxLabel4: TcxLabel;
    cbbelgeOlusturma: TcxImageComboBox;
    BtnIskontoYetki: TcxButton;
    CheckDovizTakibi: TcxCheckBox;
    cxButtonEdit1: TcxButtonEdit;
    cxButton1: TcxButton;
    CheckDonusumGozuksun: TcxCheckBox;
    TabSheet1: TTabSheet;
    GroupEFaturaBag: TcxGroupBox;
    cxLabel5: TcxLabel;
    Entegrator: TcxTextEdit;
    cxLabel6: TcxLabel;
    Ent_Adres: TcxTextEdit;
    cxLabel7: TcxLabel;
    EditEnt_Kullanici: TcxTextEdit;
    cxLabel8: TcxLabel;
    EditEnt_Sifre: TcxTextEdit;
    cxLabel9: TcxLabel;
    ComboSENARYO: TcxImageComboBox;
    ComboDijitMiktar: TcxComboBox;
    cxLabel10: TcxLabel;
    TevkifatOranlariTus: TcxButton;
    CheckKDVDahil: TcxCheckBox;
    cxLabel11: TcxLabel;
    EditSerbestMeslek: TcxTextEdit;
    CheckBoxEksiskontoya: TcxCheckBox;
    ComboFatKullanimi: TcxImageComboBox;
    cxLabel12: TcxLabel;
    cxGroupBox3: TcxGroupBox;
    CheckBCBaslik: TcxCheckBox;
    CheckBCAdres: TcxCheckBox;
    CheckBCIl: TcxCheckBox;
    CheckBCIlce: TcxCheckBox;
    CheckBCVNo: TcxCheckBox;
    CheckBCVD: TcxCheckBox;
    CheckBCFiyatAdi: TcxCheckBox;
    CheckBCDepo: TcxCheckBox;
    SheetSiparis: TTabSheet;
    PCSiparis: TcxPageControl;
    SheetAlinanSip: TcxTabSheet;
    SheetVerilenSip: TcxTabSheet;
    TabDurumBaglanti: TFDQuery;
    DtsDurumBaglanti: TDataSource;
    PopupDurumBglanti: TPopupMenu;
    ServisDurumlarnDzenle1: TMenuItem;
    BalantlarOlutur1: TMenuItem;
    KopmuBalantlarTemizle1: TMenuItem;
    GridDurumBaglanti: TcxGrid;
    GridDurumBaglantiDBTableView1: TcxGridDBTableView;
    GridDurumBaglantiDBTableView1ID: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1AKTIF: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1KAYNAKDURUM: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1HEDEFDURUM: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1UYARITURU: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1DISUYARITURU: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1ACILIS: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1KAPANIS: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1OTOKAPAT: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1TARIHIDESOR: TcxGridDBColumn;
    GridDurumBaglantiLevel1: TcxGridLevel;
    chkVade: TcxCheckBox;
    ChkProjeGozuksun: TcxCheckBox;
    ChkDemirbasGozuksun: TcxCheckBox;
    Panel2: TPanel;
    AlSiparisTus: TcxButton;
    VerSiparisTus: TcxButton;
    cxLabel3: TcxLabel;
    EditKira: TcxTextEdit;
    cxLabel13: TcxLabel;
    EditGiderPusulasi: TcxTextEdit;
    cxLabel14: TcxLabel;
    EFaturaDB: TcxTextEdit;
    CheckEIrsaliye: TcxCheckBox;
    CheckIhracatGonderilsin: TcxCheckBox;
    ComboProjeFirsatSec: TcxImageComboBox;
    cxLabel15: TcxLabel;
    CheckEnBoy: TcxCheckBox;
    CheckPozNo: TcxCheckBox;
    SpinEditPozNo: TcxSpinEdit;
    CheckFaturaHastaSekmesi: TcxCheckBox;
    CheckSiparisHastaSekmesi: TcxCheckBox;
    cxGroupBox4: TcxGroupBox;
    cxLabel16: TcxLabel;
    ComboOzelkod1: TcxImageComboBox;
    ComboOzelkod2: TcxImageComboBox;
    cxLabel17: TcxLabel;
    BtnOzelkodListe1: TcxButton;
    BtnOzelkodListe2: TcxButton;
    procedure FormCreate(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure GelenFaturaDetaySablonEkleTusClick(Sender: TObject);
    procedure TabSheetGenelShow(Sender: TObject);
    procedure GelenFaturaDetayDuzeltTusClick(Sender: TObject);
    procedure GelenFaturaDetaySablonListClick(Sender: TObject);
    procedure GidenFaturaDetaySablonListClick(Sender: TObject);
    procedure GidenFaturaDetayEkleTusClick(Sender: TObject);
    procedure GelenFaturaDetaySilTusClick(Sender: TObject);
    procedure GidenFaturaDetayDuzeltTusClick(Sender: TObject);
    procedure GidenSiparisDetaySablonDuzeltTusClick(Sender: TObject);
    procedure GelenSiparisDetaySablonDuzenleTusClick(Sender: TObject);
    procedure GidenFaturaDetaySilTusClick(Sender: TObject);
    procedure GelenSiparisDetaySablonSilTusClick(Sender: TObject);
    procedure GidenSiparisDetaySablonSilTusClick(Sender: TObject);
    procedure GidenSiparisDetaySablonEkleTusClick(Sender: TObject);
    procedure GelenSiparisDetaySablonListClick(Sender: TObject);
    procedure GidenSiparisDetaySablonListClick(Sender: TObject);
    procedure GelenSiparisDetaySablonEkleTusClick(Sender: TObject);
    procedure ComboDijitBrPropertiesPopup(Sender: TObject);
    procedure ComboDijitBrPropertiesCloseUp(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure GridListeDuzenleDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure GridListeDetayDuzenleTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormShow(Sender: TObject);
    procedure VarsayilanKlasorSiparisPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure btnExcelKolonClick(Sender: TObject);
    procedure BtnIskontoYetkiClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure TevkifatOranlariTusClick(Sender: TObject);
    procedure ComboFatKullanimiPropertiesEditValueChanged(Sender: TObject);
    procedure PCSiparisPageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure KopmuBalantlarTemizle1Click(Sender: TObject);
    procedure BalantlarOlutur1Click(Sender: TObject);
    procedure ServisDurumlarnDzenle1Click(Sender: TObject);
    procedure AlSiparisTusClick(Sender: TObject);
    procedure VerSiparisTusClick(Sender: TObject);
    procedure ComboOzelkod1PropertiesChange(Sender: TObject);
    procedure BtnOzelkodListe1Click(Sender: TObject);
    procedure BtnOzelkodListe2Click(Sender: TObject);
    procedure ComboOzelkod2PropertiesChange(Sender: TObject);
  private
    DoChange:boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonFaturaDlg: TOpsiyonFaturaDlg;

implementation

uses UCombo, Utablo, URehberAyar, UGirisKutusuEx,UExcelKolonAyar, UGenSifre,PrjConst,LocOnFly;


{$R *.dfm}
var
   OncekiDigitSay : string[1];

procedure TOpsiyonFaturaDlg.AlSiparisTusClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_OpsiyonSiparis_AlinanDurum);
end;

procedure TOpsiyonFaturaDlg.BalantlarOlutur1Click(Sender: TObject);
begin
  if PCSiparis.ActivePage = SheetAlinanSip then  begin
    Tablo.DurumBaglantilariniOlustur(TabNo_SIPARIS_Giden,Ops_OpsiyonSiparis_AlinanDurum);
    Tabloyenile(TabDurumBaglanti,[TabNo_SIPARIS_Giden,Ops_OpsiyonSiparis_AlinanDurum]);
  end else if PCSiparis.ActivePage = SheetVerilenSip then begin
    Tablo.DurumBaglantilariniOlustur(TabNo_SIPARIS_Gelen,Ops_OpsiyonSiparis_VerilenDurum);
    Tabloyenile(TabDurumBaglanti,[TabNo_SIPARIS_Gelen,Ops_OpsiyonSiparis_VerilenDurum]);
  end;
end;

procedure TOpsiyonFaturaDlg.btnExcelKolonClick(Sender: TObject);
begin
  Application.CreateForm(TExcelKolonAyarDlg,ExcelKolonAyarDlg);
  ExcelKolonAyarDlg.RehberID := -1;
  ExcelKolonAyarDlg.BEditFirma.Text := '';
  ExcelKolonAyarDlg.Show;
end;

procedure TOpsiyonFaturaDlg.BtnIskontoYetkiClick(Sender: TObject);
var IYDlg:TIskontoYetkiDlg;
begin
  Application.CreateForm(TIskontoYetkiDlg,IYDlg);
  IYDlg.ShowModal;
  FreeAndNil(IYDlg);
end;

procedure TOpsiyonFaturaDlg.BtnOzelkodListe1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_FaturaOpsiyon_Ozelkod1_Liste);
end;

procedure TOpsiyonFaturaDlg.BtnOzelkodListe2Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_FaturaOpsiyon_Ozelkod2_Liste);
end;

procedure TOpsiyonFaturaDlg.ComboDijitBrPropertiesCloseUp(Sender: TObject);

   { procedure Islem(Tablo1, Alan1:String);
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'alter table '+Tablo1+' drop column 	[ISKONTOLUBRMFIYAT] '+
        ' alter table '+Tablo1+'  drop column 	KDVDAHILFIYAT '+
        ' alter table '+Tablo1+'  alter column '+Alan1+' numeric(18,8) '+
        ' alter table '+Tablo1+'  add ISKONTOLUBRMFIYAT  AS ((([BIRIMFIYAT]*((100)-[ISKONTO]))*((100)-[ISKONTO2]))/(10000)) '+
        ' alter table '+Tablo1+'  add KDVDAHILFIYAT  AS (([BIRIMFIYAT]*((100)+[KDV]))/(100)) ',[],[]);
    end;  }
begin
{  if (ComboDijitBr.Text <> OncekiDigitSay) and (ComboDijitBr.ItemIndex >= 0) and
     (Application.MessageBox(PChar(KGeri_donusu_yok),
      PChar('Uyarı/Onay'), MB_YESNO + MB_ICONQUESTION)= IDYES) then
  begin
     if ComboDijitBr.EditValue > 4 then
        Islem('FATURA', 'BIRIMFIYAT');
        Islem('TEKLIFDETAY', 'BIRIMFIYAT');
        Islem('SIPARISDETAY', 'BIRIMFIYAT');
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' alter table FATURA alter column DOVIZ_BIRIMFIYAT numeric(18,8) '
                                         +' alter table TEKLIFDETAY alter column DOVIZ_BIRIMFIYAT numeric(18,8) '
                                         +' alter table SIPARISDETAY alter column DOVIZ_BIRIMFIYAT numeric(18,8) ',[],[]);
     if ComboDijitTut.EditValue>4 then
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' alter table FATURA alter column TUTAR numeric(18,8) '
                                         +' alter table FATURA alter column DOVIZ_TUTARI numeric(18,8) '
                                         +' alter table TEKLIFDETAY alter column TUTAR numeric(18,8) '
                                         +' alter table TEKLIFDETAY alter column DOVIZ_TUTARI numeric(18,8) '
                                         +' alter table SIPARISDETAY alter column TUTAR numeric(18,8) '
                                         +' alter table SIPARISDETAY alter column DOVIZ_TUTARI numeric(18,8) ',[],[]);
  end
  else
     ComboDijitBr.Text := OncekiDigitSay;   }
end;

procedure TOpsiyonFaturaDlg.ComboDijitBrPropertiesPopup(Sender: TObject);
begin
//   OncekiDigitSay := ComboDijitBr.Text
end;

procedure TOpsiyonFaturaDlg.ComboFatKullanimiPropertiesEditValueChanged(
  Sender: TObject);
begin
   GroupEFaturaBag.Visible := ComboFatKullanimi.EditValue>0;
end;

procedure TOpsiyonFaturaDlg.ComboOzelkod1PropertiesChange(Sender: TObject);
begin
    BtnOzelkodListe1.Visible := ComboOzelkod1.EditValue=1;
end;

procedure TOpsiyonFaturaDlg.ComboOzelkod2PropertiesChange(Sender: TObject);
begin
    BtnOzelkodListe2.Visible := ComboOzelkod2.EditValue=1;
end;

procedure TOpsiyonFaturaDlg.cxButton1Click(Sender: TObject);
begin
  Tablo.MailSablonYonetimi(MODUL_Alis_Satis);
end;

procedure TOpsiyonFaturaDlg.FormCreate(Sender: TObject);
begin
  DoChange := True;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  PageControl1.ActivePageIndex:=0;
  CheckFaturaPlaniOlustur.Checked :=Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_ZorunluPlanOlustur,True);  //FaturaOpsiyon  ZorunluPlanOlustur
  ComboDijitBr.ItemIndex := ComboDijitBr.Properties.Items.IndexOf(IntToStr(Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayBr,2)));
  ComboDijitTut.ItemIndex := ComboDijitTut.Properties.Items.IndexOf(IntToStr(Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2)));
  ComboDijitMiktar.ItemIndex := ComboDijitMiktar.Properties.Items.IndexOf(IntToStr(Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayMiktar,2)));
  rdSatirlaraVade.Checked :=Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_SatirlaraVade,False);  //FaturaOpsiyon','SatirlaraVade'
  rdBasligaVade.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_BasligaVade,True);  //FaturaOpsiyon','BasligaVade'
  chStkVarsKalmayanGoster.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_StokVarsayilanKalmayanBilgisi,True);
  CheckDovizTakibi.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_BelgedeDoviz, False);
  CheckDonusumGozuksun.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_DonusumGozuksun, True);
  CheckKDVDahil.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_KDVDahil, True);
  cbbelgeOlusturma.EditValue := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_BelgeOlusturma,0);
  CheckBoxEksiskontoya.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Eksiskontoya, False);
  ComboOzelkod1.EditValue := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Ozelkod1,0);
  ComboOzelkod2.EditValue := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Ozelkod2,0);

  ChkProjeGozuksun.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_ProjeGozuksun, True);
  ChkDemirbasGozuksun.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_DemirbasGozuksun, True);

  CheckEIrsaliye.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonEIrsaliye, False);
  CheckIhracatGonderilsin.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonIhracatGonder, True);

  ComboProjeFirsatSec.EditValue := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_ProjeFirsatSec, 11);

end;

procedure TOpsiyonFaturaDlg.FormShow(Sender: TObject);
begin
  PCSiparisPageChanging(Nil,PCSiparis.ActivePage,DoChange);
  tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
  VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonFatura_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
  VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);
  /// Siparis için
  VarsayilanKlasorSiparis.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonStok_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
  VarsayilanKlasorSiparis.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasorSiparis.tag);

  EditSerbestMeslek.Text := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_SerbestMeslek, '');
  EditKira.Text := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Kira, '');
  EditGiderPusulasi.Text := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_GiderPusulasi, '');

  EFaturaDB.Text := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EFaturaDB, 'EFATURA');


  ComboFatKullanimi.EditValue := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_E_FaturaKullanimda, 0);
  Entegrator.Text := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Entegrator,'');
  Ent_Adres.Text := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Adres,'');
  EditEnt_Kullanici.Text := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Kullanici,'');
  EditEnt_Sifre.Text := UGenSifre.DeSifre(Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Sifre,''));
  ComboSENARYO.EditValue := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Senaryo,1);

  CheckBCBaslik.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Baslik);
  CheckBCAdres.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Adres);
  CheckBCIlce.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Ilce);
  CheckBCIl.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Il);
  CheckBCVD.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_VD);
  CheckBCVNo.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_VNo);
  CheckBCDepo.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Depo);
  CheckBCFiyatAdi.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_FiyatAdi);
  chkVade.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Vade,false);
  CheckEnBoy.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_EnBoyAktif, False);
  CheckPozNo.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_PozNoVar, False);
  SpinEditPozNo.Value := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_PozNoAralik, 10);
  CheckFaturaHastaSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_HastaFaturaSekmesi, false);
  CheckSiparisHastaSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_HastaSiparisSekmesi, false);

  ComboOzelkod1PropertiesChange(Self);
  ComboOzelkod2PropertiesChange(Self);
end;

procedure TOpsiyonFaturaDlg.KaydetTusClick(Sender: TObject);
begin
  //Modul 2400
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_ZorunluPlanOlustur,CheckFaturaPlaniOlustur.Checked);   //ZorunluPlanOlustur
  OndalikDijitSayBr := StrToInt(ComboDijitBr.Text);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_OndalikDijitSayBr,StrToInt(ComboDijitBr.Text));        //OndalikDijitSayBr
  OndalikDijitSayTut := StrToInt(ComboDijitTut.Text);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,StrToInt(ComboDijitTut.Text));      //OndalikDijitSayTut
  OndalikDijitSayMik := StrToInt(ComboDijitMiktar.Text);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_OndalikDijitSayMiktar,StrToInt(ComboDijitMiktar.Text));

  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_SatirlaraVade,rdSatirlaraVade.Checked); //SatirlaraVade
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_BasligaVade,rdBasligaVade.Checked);     //BasligaVade

  Tablo.GENINI.WriteInteger(Ops_OpsiyonFatura_VarsayilanKlasor,VarsayilanKlasor.Tag); //OpsiyonFatura VarsayilanKlasor Dokuman için
  Tablo.GENINI.WriteInteger(Ops_OpsiyonSiparis_VarsayilanKlasor,VarsayilanKlasorSiparis.Tag); //OpsiyonSiparis VarsayilanKlasor Dokuman için
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_StokVarsayilanKalmayanBilgisi,chStkVarsKalmayanGoster.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_BelgedeDoviz, CheckDovizTakibi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_DonusumGozuksun, CheckDonusumGozuksun.Checked);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_BelgeOlusturma,cbbelgeOlusturma.EditValue);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_KDVDahil, CheckDonusumGozuksun.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Eksiskontoya, CheckBoxEksiskontoya.Checked);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_Ozelkod1,ComboOzelkod1.EditValue);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_Ozelkod2,ComboOzelkod2.EditValue);

  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_SerbestMeslek, EditSerbestMeslek.Text);
  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_Kira, EditKira.Text);
  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_GiderPusulasi, EditGiderPusulasi.Text);


  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_EFaturaDB, EFaturaDB.Text);

  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_E_FaturaKullanimda, ComboFatKullanimi.EditValue);
  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_Entegrator,Entegrator.Text);
  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_Ent_Adres,Ent_Adres.Text);
  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_Ent_Kullanici,EditEnt_Kullanici.Text);
  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_Ent_Sifre,UGenSifre.Sifre(EditEnt_Sifre.Text));
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_Senaryo,ComboSENARYO.EditValue);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_ProjeFirsatSec,ComboProjeFirsatSec.EditValue);

  Ent_Kullanici := EditEnt_Kullanici.Text;
  Ent_Sifre := EditEnt_Sifre.Text;
  EFaturaKullanimda := ComboFatKullanimi.EditValue;

  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_Baslik,CheckBCBaslik.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_Adres,CheckBCAdres.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_Ilce,CheckBCIlce.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_Il,CheckBCIl.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_VD,CheckBCVD.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_VNo,CheckBCVNo.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_Depo,CheckBCDepo.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_FiyatAdi,CheckBCFiyatAdi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_Bosluk_Vade,chkVade.Checked);

  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_EnBoyAktif, CheckEnBoy.Checked);
  EnBoyHesaplamaAktif := CheckEnBoy.Checked;

  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_PozNoVar, CheckPozNo.Checked);
  Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_PozNoAralik, SpinEditPozNo.Value);

  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_ProjeGozuksun,ChkProjeGozuksun.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_DemirbasGozuksun,ChkDemirbasGozuksun.Checked);

  Tablo.GENINI.WriteBoolean(Ops_OpsiyonEIrsaliye,CheckEIrsaliye.Checked);

  Tablo.GENINI.WriteBoolean(Ops_OpsiyonIhracatGonder, CheckIhracatGonderilsin.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_HastaFaturaSekmesi, CheckFaturaHastaSekmesi.Checked);


  Tablo.GENINI.WriteBoolean(Ops_FaturaOpsiyon_HastaSiparisSekmesi, CheckSiparisHastaSekmesi.Checked);
end;

procedure TOpsiyonFaturaDlg.KopmuBalantlarTemizle1Click(Sender: TObject);
begin
  if PCSiparis.ActivePage = SheetAlinanSip then  begin
    Tablo.KopukDurumBaglantilariniSil(TabNo_SIPARIS_Giden,Ops_OpsiyonSiparis_AlinanDurum);
    Tabloyenile(TabDurumBaglanti,[TabNo_SIPARIS_Giden,Ops_OpsiyonSiparis_AlinanDurum]);
  end else if PCSiparis.ActivePage = SheetVerilenSip then begin
    Tablo.KopukDurumBaglantilariniSil(TabNo_SIPARIS_Gelen,Ops_OpsiyonSiparis_VerilenDurum);
    Tabloyenile(TabDurumBaglanti,[TabNo_SIPARIS_Gelen,Ops_OpsiyonSiparis_VerilenDurum]);
  end;
end;

procedure TOpsiyonFaturaDlg.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage=GidenFaturaPage then begin

    GridListeDuzenle.Parent := GBGidFatListe;
    TabListeDuzenle.Close;
    TabListeDuzenle.SQL.Text := 'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DIL='+IntToStr(Dil)+' and LEN(ABS(DEGER))=4 and DEGER like ''-24__'' and ANAHTAR like ''FaturaGiden_%''';
    TabListeDuzenle.Open;

    GridListeDetayDuzenle.Parent := GBGidFatDetay;
    TabListeDetayDuzenle.Close;
    TabListeDetayDuzenle.SQL.Text := 'select * from GENINI where DIL='+IntToStr(Dil)+' AND BOLUM=0 and DIL='+IntToStr(Dil)+' and LEN(ABS(DEGER))=4 and DEGER like ''-24__'' and ANAHTAR like ''FatGitDetay_%''';
    TabListeDetayDuzenle.Open;
  end else  if PageControl1.ActivePage=GelenFaturaPage then begin

    GridListeDuzenle.Parent := GBGelFatListe;
    TabListeDuzenle.Close;
    TabListeDuzenle.SQL.Text := 'select * from GENINI where DIL='+IntToStr(Dil)+' AND BOLUM=0 and DIL='+IntToStr(Dil)+' and LEN(ABS(DEGER))=4 and DEGER like ''-24__'' and ANAHTAR like ''FaturaGelen_%''';
    TabListeDuzenle.Open;

    GridListeDetayDuzenle.Parent := GBGelFatDetay;
    TabListeDetayDuzenle.Close;
    TabListeDetayDuzenle.SQL.Text := 'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DIL='+IntToStr(Dil)+' and LEN(ABS(DEGER))=4 and DEGER like ''-24__'' and ANAHTAR like ''FatGelDetay_%''';
    TabListeDetayDuzenle.Open;

  end;
end;

procedure TOpsiyonFaturaDlg.PCSiparisPageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  GridDurumBaglanti.Parent := NewPage;
  if NewPage = SheetAlinanSip then  begin
    Tabloyenile(TabDurumBaglanti,[TabNo_SIPARIS_Giden,Ops_OpsiyonSiparis_AlinanDurum]);
    GridDurumBaglantiDBTableView1KAYNAKDURUM.RepositoryItem := Tablo.repSiparisDurumAlinan;
    GridDurumBaglantiDBTableView1HEDEFDURUM.RepositoryItem := Tablo.repSiparisDurumAlinan;
  end else if NewPage = SheetVerilenSip then begin
    Tabloyenile(TabDurumBaglanti,[TabNo_SIPARIS_Gelen,Ops_OpsiyonSiparis_VerilenDurum]);
    GridDurumBaglantiDBTableView1KAYNAKDURUM.RepositoryItem := Tablo.repSiparisDurumVerilen;
    GridDurumBaglantiDBTableView1HEDEFDURUM.RepositoryItem := Tablo.repSiparisDurumVerilen;
  end;
end;

procedure TOpsiyonFaturaDlg.ServisDurumlarnDzenle1Click(Sender: TObject);
begin
  if PCSiparis.ActivePage = SheetAlinanSip then begin
    Tablo.GeniniBaslat(Ops_OpsiyonSiparis_AlinanDurum);
    Tablo.GENINI.ReadImageSection(Ops_OpsiyonSiparis_AlinanDurum, Tablo.repSiparisDurumAlinan.Properties.Items, False);
  end else if PCSiparis.ActivePage = SheetVerilenSip then begin
    Tablo.GeniniBaslat(Ops_OpsiyonSiparis_VerilenDurum);
    Tablo.GENINI.ReadImageSection(Ops_OpsiyonSiparis_VerilenDurum, Tablo.repSiparisDurumVerilen.Properties.Items, False);
  end;
end;

procedure TOpsiyonFaturaDlg.TabSheetGenelShow(Sender: TObject);
begin
  if GelenFaturaDetaySablonList.Items.Count=0 then
     GelenFaturaDetaySablonList.Items := Tablo.ComboboxInit('SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI='+inttostr(TabNo_FATURA_GelenFatFisIrs)).Items;

  if GidenFaturaDetaySablonList.Items.Count=0 then
     GidenFaturaDetaySablonList.Items := Tablo.ComboboxInit('SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI='+inttostr(TabNo_FATURA_GidenFatFisIrs)).Items;

  if GelenSiparisDetaySablonList.Items.Count=0 then
     GelenSiparisDetaySablonList.Items := Tablo.ComboboxInit('SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI='+inttostr(TabNo_FATURA_AlisSiparis)).Items;

  if GidenSiparisDetaySablonList.Items.Count=0 then
     GidenSiparisDetaySablonList.Items := Tablo.ComboboxInit('SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI='+inttostr(TabNo_FATURA_SatisSiparis)).Items;
end;

procedure TOpsiyonFaturaDlg.TevkifatOranlariTusClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_TevkifatOranlari);
end;

procedure TOpsiyonFaturaDlg.VarsayilanKlasorPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
KodAgaciLokasyonDlg: TKodAgaciDlg;
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
    sqltext:='select ID,ROOTKOD=USTID, KOD=ID,ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID >0 ORDER BY USTID ' ;
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','Açıklama'],[true,False]) then begin
      VarsayilanKlasor.Text:=LokAciklama;
      VarsayilanKlasor.Tag:=LokID;
    end;
  end;
end;

procedure TOpsiyonFaturaDlg.VarsayilanKlasorSiparisPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
KodAgaciLokasyonDlg: TKodAgaciDlg;
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
    sqltext:='select ID,ROOTKOD=USTID, KOD=ID,ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID >0 ORDER BY USTID ' ;
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','Açıklama'],[true,False]) then begin
      VarsayilanKlasorSiparis.Text:=LokAciklama;
      VarsayilanKlasorSiparis.Tag:=LokID;
    end;
  end;
end;

procedure TOpsiyonFaturaDlg.VerSiparisTusClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_OpsiyonSiparis_VerilenDurum);
end;

procedure TOpsiyonFaturaDlg.GidenFaturaDetayDuzeltTusClick(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi:=GidenFaturaDetaySablonList.Items[GidenFaturaDetaySablonList.ItemIndex];
  ctrls := TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(KontrolSablonAdi, ctrls) = mrOk then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set BOLUM=&YeniIsim where isnull(BOLUM,'''')=&EskiIsim and YERI=&Yeri',['&YeniIsim','&EskiIsim','&Yeri'],[Bilgi,GidenFaturaDetaySablonList.Items[GidenFaturaDetaySablonList.ItemIndex],TabNo_FATURA_GidenFatFisIrs]);
    GidenFaturaDetaySablonList.DeleteSelected;
    GidenFaturaDetaySablonList.Items.Add(Bilgi);
    GidenFaturaDetaySablonList.ClearSelection;
    GidenFaturaDetaySablonList.Selected[GidenFaturaDetaySablonList.Items.Count-1]:=True;
  end;
end;

procedure TOpsiyonFaturaDlg.GidenFaturaDetayEkleTusClick(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(KontrolSablonAdi, ctrls) = mrOk then begin
    GidenFaturaDetaySablonList.Items.Add(Bilgi);
    GidenFaturaDetaySablonList.ClearSelection;
    GidenFaturaDetaySablonList.Selected[GidenFaturaDetaySablonList.Items.Count-1]:=True;
    GidenFaturaDetaySablonListClick(Self);
  end;
end;

procedure TOpsiyonFaturaDlg.GelenFaturaDetaySilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar('"'+GelenFaturaDetaySablonList.Items[GelenFaturaDetaySablonList.ItemIndex]+'" ve tüm alt öğeler silinecektir. Onaylıyor musunuz?'),PChar('ONAY'),MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERAYAR where YERI=&Yeri and isnull(BOLUM,'''')=&Bolum ',['&Yeri','&Bolum'],[TabNo_FATURA_GelenFatFisIrs,GelenFaturaDetaySablonList.Items[GelenFaturaDetaySablonList.ItemIndex]]);
     GelenFaturaDetaySablonList.DeleteSelected;
   end;
end;

procedure TOpsiyonFaturaDlg.GelenSiparisDetaySablonDuzenleTusClick(
  Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi:=GelenSiparisDetaySablonList.Items[GelenSiparisDetaySablonList.ItemIndex];
  ctrls := TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(KontrolSablonAdi, ctrls) = mrOk then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set BOLUM=&YeniIsim where isnull(BOLUM,'''')=&EskiIsim and YERI=&Yeri',['&YeniIsim','&EskiIsim','&Yeri'],[Bilgi,GelenSiparisDetaySablonList.Items[GelenSiparisDetaySablonList.ItemIndex],TabNo_FATURA_AlisSiparis]);
    GelenSiparisDetaySablonList.DeleteSelected;
    GelenSiparisDetaySablonList.Items.Add(Bilgi);
    GelenSiparisDetaySablonList.ClearSelection;
    GelenSiparisDetaySablonList.Selected[GelenSiparisDetaySablonList.Items.Count-1]:=True;
  end;

end;

procedure TOpsiyonFaturaDlg.GelenSiparisDetaySablonEkleTusClick(
  Sender: TObject);

var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(BGYeni_bolum_adi,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(BGBolum, ctrls) = mrOk then begin
    GelenSiparisDetaySablonList.Items.Add(Bilgi);
    GelenSiparisDetaySablonList.ClearSelection;
    GelenSiparisDetaySablonList.Selected[GelenSiparisDetaySablonList.Items.Count-1]:=True;
    GelenSiparisDetaySablonListClick(Self);
  end;
end;

procedure TOpsiyonFaturaDlg.GelenSiparisDetaySablonListClick(Sender: TObject);
begin
   Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
   RehberAyarDlg.Yer :=TabNo_FATURA_AlisSiparis;
   RehberAyarDlg.Bolum := GelenSiparisDetaySablonList.Items[GelenSiparisDetaySablonList.ItemIndex];
   RehberAyarDlg.ShowModal;
   if RehberAyarDlg.TabAyar.RecordCount=0 then
      GelenSiparisDetaySablonList.DeleteSelected;
   RehberAyarDlg.Destroy;

end;

procedure TOpsiyonFaturaDlg.GelenSiparisDetaySablonSilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar('"'+GelenSiparisDetaySablonList.Items[GelenSiparisDetaySablonList.ItemIndex]+'" ve tüm alt öğeler silinecektir. Onaylıyor musunuz?'),PChar('ONAY'),MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERAYAR where YERI=&Yeri and isnull(BOLUM,'''')=&Bolum ',['&Yeri','&Bolum'],[TabNo_FATURA_AlisSiparis,GelenSiparisDetaySablonList.Items[GelenSiparisDetaySablonList.ItemIndex]]);
     GelenSiparisDetaySablonList.DeleteSelected;
   end;
end;

procedure TOpsiyonFaturaDlg.GelenFaturaDetayDuzeltTusClick(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi:=GelenFaturaDetaySablonList.Items[GelenFaturaDetaySablonList.ItemIndex];
  ctrls := TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(KontrolSablonAdi, ctrls) = mrOk then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set BOLUM=&YeniIsim where isnull(BOLUM,'''')=&EskiIsim and YERI=&Yeri',['&YeniIsim','&EskiIsim','&Yeri'],[Bilgi,GelenFaturaDetaySablonList.Items[GelenFaturaDetaySablonList.ItemIndex],TabNo_FATURA_GelenFatFisIrs]);
    GelenFaturaDetaySablonList.DeleteSelected;
    GelenFaturaDetaySablonList.Items.Add(Bilgi);
    GelenFaturaDetaySablonList.ClearSelection;
    GelenFaturaDetaySablonList.Selected[GelenFaturaDetaySablonList.Items.Count-1]:=True;
  end;
end;

procedure TOpsiyonFaturaDlg.GelenFaturaDetaySablonListClick(Sender: TObject);
begin
   Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
   RehberAyarDlg.Yer := TabNo_FATURA_GelenFatFisIrs;
   RehberAyarDlg.Bolum := GelenFaturaDetaySablonList.Items[GelenFaturaDetaySablonList.ItemIndex];
   RehberAyarDlg.ShowModal;
   if RehberAyarDlg.TabAyar.RecordCount=0 then
      GelenFaturaDetaySablonList.DeleteSelected;
   RehberAyarDlg.Destroy;
end;

procedure TOpsiyonFaturaDlg.GelenFaturaDetaySablonEkleTusClick(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(BGYeni_bolum_adi,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(BGBolum, ctrls) = mrOk then begin
    GelenFaturaDetaySablonList.Items.Add(Bilgi);
    GelenFaturaDetaySablonList.ClearSelection;
    GelenFaturaDetaySablonList.Selected[GelenFaturaDetaySablonList.Items.Count-1]:=True;
    GelenFaturaDetaySablonListClick(Self);
  end;
end;

procedure TOpsiyonFaturaDlg.GidenFaturaDetaySablonListClick(Sender: TObject);
begin
   Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
   RehberAyarDlg.Yer := TabNo_FATURA_GidenFatFisIrs;
   RehberAyarDlg.Bolum := GidenFaturaDetaySablonList.Items[GidenFaturaDetaySablonList.ItemIndex];
   RehberAyarDlg.ShowModal;
   if RehberAyarDlg.TabAyar.RecordCount=0 then
      GidenFaturaDetaySablonList.DeleteSelected;
   RehberAyarDlg.Destroy;
end;

procedure TOpsiyonFaturaDlg.GidenFaturaDetaySilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar('"'+GidenFaturaDetaySablonList.Items[GidenFaturaDetaySablonList.ItemIndex]+'" ve tüm alt öğeler silinecektir. Onaylıyor musunuz?'),PChar('ONAY'),MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERAYAR where YERI=&Yeri and isnull(BOLUM,'''')=&Bolum ',['&Yeri','&Bolum'],[TabNo_FATURA_GidenFatFisIrs,GidenFaturaDetaySablonList.Items[GidenFaturaDetaySablonList.ItemIndex]]);
     GidenFaturaDetaySablonList.DeleteSelected;
   end;
end;

procedure TOpsiyonFaturaDlg.GidenSiparisDetaySablonDuzeltTusClick(
  Sender: TObject);

var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi:=GidenSiparisDetaySablonList.Items[GidenSiparisDetaySablonList.ItemIndex];
  ctrls := TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(KontrolSablonAdi, ctrls) = mrOk then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set BOLUM=&YeniIsim where isnull(BOLUM,'''')=&EskiIsim and YERI=&Yeri',['&YeniIsim','&EskiIsim','&Yeri'],[Bilgi,GidenSiparisDetaySablonList.Items[GidenSiparisDetaySablonList.ItemIndex],TabNo_FATURA_SatisSiparis]);
    GidenSiparisDetaySablonList.DeleteSelected;
    GidenSiparisDetaySablonList.Items.Add(Bilgi);
    GidenSiparisDetaySablonList.ClearSelection;
    GidenSiparisDetaySablonList.Selected[GidenSiparisDetaySablonList.Items.Count-1]:=True;
  end;
end;

procedure TOpsiyonFaturaDlg.GidenSiparisDetaySablonEkleTusClick(
  Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(KontrolSablonAdi, ctrls) = mrOk then begin
    GidenSiparisDetaySablonList.Items.Add(Bilgi);
    GidenSiparisDetaySablonList.ClearSelection;
    GidenSiparisDetaySablonList.Selected[GidenSiparisDetaySablonList.Items.Count-1]:=True;
    GidenSiparisDetaySablonListClick(Self)
  end;
end;

procedure TOpsiyonFaturaDlg.GidenSiparisDetaySablonListClick(Sender: TObject);
begin
   Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
   RehberAyarDlg.Yer := TabNo_FATURA_SatisSiparis;
   RehberAyarDlg.Bolum := GidenSiparisDetaySablonList.Items[GidenSiparisDetaySablonList.ItemIndex];
   RehberAyarDlg.ShowModal;
   if RehberAyarDlg.TabAyar.RecordCount=0 then
      GidenSiparisDetaySablonList.DeleteSelected;
   RehberAyarDlg.Destroy;
end;

procedure TOpsiyonFaturaDlg.GidenSiparisDetaySablonSilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar('"'+GidenSiparisDetaySablonList.Items[GidenSiparisDetaySablonList.ItemIndex]+'" ve tüm alt öğeler silinecektir. Onaylıyor musunuz?'),PChar('ONAY'),MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERAYAR where YERI=&Yeri and isnull(BOLUM,'''')=&Bolum ',['&Yeri','&Bolum'],[TabNo_FATURA_SatisSiparis,GidenSiparisDetaySablonList.Items[GidenSiparisDetaySablonList.ItemIndex]]);
     GidenSiparisDetaySablonList.DeleteSelected;
   end;

end;

procedure TOpsiyonFaturaDlg.GridListeDetayDuzenleTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GeniniBaslat(TabListeDetayDuzenle.FieldByName('DEGER').AsInteger);
end;

procedure TOpsiyonFaturaDlg.GridListeDuzenleDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GeniniBaslat(TabListeDuzenle.FieldByName('DEGER').AsInteger);
end;

end.





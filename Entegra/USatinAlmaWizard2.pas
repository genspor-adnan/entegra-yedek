unit USatinAlmaWizard2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, cxGraphics, dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxCurrencyEdit,
  cxLabel, cxButtonEdit, cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin,Fetautil,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, jpeg, cxImage,FetaClassExtensions,
  UGentegreFrameYonetimi, cxTreeView, dxSkinLondonLiquidSky, UTablo, cxCheckBox,
  cxExtEditRepositoryItems, cxEditRepositoryItems, cxShellEditRepositoryItems,
  cxDBEditRepository, cxDBExtLookupComboBox, cxGridCustomPopupMenu,DateUtils,
  cxGridPopupMenu, JvComponentBase, JvDragDrop, dxSkinLiquidSky, UStokHizmetAra,
  cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, cxLookAndFeels,
  cxNavigator, cxGridCustomLayoutView, UBelgeDonusum, UMailSablon,
  cxPCdxBarPopupMenu, cxPC, cxBlobEdit, dxBarBuiltInMenu, OfficePopupMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet;

type
  TSatinAlmaWizard2 = class(TForm, IPopupDialog)
    Panel1: TPanel;
    FaturaTus: TcxButton;
    DetayTus: TcxButton;
    WizardKontrol: TJvWizard;
    SiparisEkr: TJvWizardInteriorPage;
    DetayEkr: TJvWizardInteriorPage;
    cxImageComboBox1: TcxImageComboBox;
    dsAra: TDataSource;
    OpenDialog1: TOpenDialog;
    PopupMenuFatura: TPopupMenu;
    N16: TMenuItem;
    FaturaIptalIsaretle: TMenuItem;
    DtsSIPARISDETAY: TDataSource;
    DtsSIPARIS: TDataSource;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    TabRehber: TFDQuery;
    DtsRehber: TDataSource;
    SIPARISDETAY: TFDQuery;
    SIPARIS: TFDQuery;
    frxSIPARISDETAY: TfrxDBDataset;
    frxSIPARIS: TfrxDBDataset;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    ToolBar1: TToolBar;
    GridKurIlet: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    Miktarskontosu1: TMenuItem;
    Yzdeskontosu1: TMenuItem;
    KDVHaricTutargir1: TMenuItem;
    KDVDahilTutargir1: TMenuItem;
    JvDragDrop1: TJvDragDrop;
    skonto11: TMenuItem;
    skonto21: TMenuItem;
    N52: TMenuItem;
    N53: TMenuItem;
    N102: TMenuItem;
    N152: TMenuItem;
    N202: TMenuItem;
    N252: TMenuItem;
    N302: TMenuItem;
    N402: TMenuItem;
    N502: TMenuItem;
    N1001: TMenuItem;
    zel3: TMenuItem;
    N01: TMenuItem;
    N51: TMenuItem;
    N101: TMenuItem;
    N151: TMenuItem;
    N201: TMenuItem;
    N251: TMenuItem;
    N301: TMenuItem;
    N401: TMenuItem;
    N501: TMenuItem;
    N1002: TMenuItem;
    zel1: TMenuItem;
    utarDvzHesapla1: TMenuItem;
    N5: TMenuItem;
    SipariKoanAyarlar1: TMenuItem;
    lbDetaySablon: TcxLabel;
    ComboBolum: TcxDBComboBox;
    SQLDetay: TcxMemo;
    DokumanEkr: TJvWizardInteriorPage;
    dtsTOPLAMLAR: TDataSource;
    TOPLAMLAR: TFDQuery;
    PanelAlt2: TPanel;
    GridFaturaToplam: TStringGrid;
    MemoNOTLAR: TcxDBMemo;
    cxLabel17: TcxLabel;
    LabelAktivite: TcxLabel;
    LabelProje: TcxLabel;
    BeditBagliGorev: TcxButtonEdit;
    cxDBLabel3: TcxDBLabel;
    cbDovizCinsi: TcxDBComboBox;
    lbDoviz: TcxLabel;
    gridFatToplam: TcxGrid;
    tvFatToplamlar: TcxGridDBTableView;
    gridFatToplamLevel1: TcxGridLevel;
    BeditProje: TcxButtonEdit;
    EditOnaylayan: TcxButtonEdit;
    cxLabel6: TcxLabel;
    Panel3: TPanel;
    Panel2: TPanel;
    GridFatura: TcxGrid;
    GridFaturaView: TcxGridDBTableView;
    GridFaturaViewTUR: TcxGridDBColumn;
    GridFaturaViewTESLIMTARIHI: TcxGridDBColumn;
    GridFaturaViewKOD1: TcxGridDBColumn;
    GridFaturaViewAD: TcxGridDBColumn;
    GridFaturaViewACIKLAMA1: TcxGridDBColumn;
    GridFaturaViewADET1: TcxGridDBColumn;
    GridFaturaViewBIRIM1: TcxGridDBColumn;
    GridFaturaViewBIRIMFIYAT1: TcxGridDBColumn;
    GridFaturaViewISKONTO1: TcxGridDBColumn;
    GridFaturaViewISKONTO2: TcxGridDBColumn;
    GridFaturaViewKDV1: TcxGridDBColumn;
    GridFaturaViewTUTAR1: TcxGridDBColumn;
    ColumnIskTutari: TcxGridDBColumn;
    GridFaturaViewMASRAFKOD: TcxGridDBColumn;
    GridFaturaViewKUR: TcxGridDBColumn;
    GridFaturaViewMASRAFAD: TcxGridDBColumn;
    GridFaturaViewIZLEME: TcxGridDBColumn;
    GridFaturaViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn;
    GridFaturaViewDOVIZ_KURU: TcxGridDBColumn;
    GridFaturaViewDOVIZ_TUTARI: TcxGridDBColumn;
    GridFaturaViewDOVIZKURDEGERI: TcxGridDBColumn;
    GridFaturaViewPROJEKODU: TcxGridDBColumn;
    GridFaturaViewOZELKOD: TcxGridDBColumn;
    GridFaturaViewSTOKDURUM: TcxGridDBColumn;
    GridFaturaViewEKIPMAN: TcxGridDBColumn;
    GridFaturaViewSERINO: TcxGridDBColumn;
    GridFaturaLevel1: TcxGridLevel;
    ToolBar5: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    ToolButton1: TToolButton;
    ToolButton9: TToolButton;
    ToolButton13: TToolButton;
    TamEkranTus: TToolButton;
    ToolButton4: TToolButton;
    BtnDonustur: TToolButton;
    PageControlUst: TcxPageControl;
    TabSheetGenelBilgiler: TcxTabSheet;
    TabSheetEkAlanlar: TcxTabSheet;
    PanelAlt: TPanel;
    PanelUst: TPanel;
    PanelUst2: TPanel;
    Bevel2: TBevel;
    Label11: TcxLabel;
    LabelFaturaTarihi: TcxLabel;
    LabelFatNo: TcxLabel;
    Label6: TcxLabel;
    ComboSiparisDURUM: TcxDBImageComboBox;
    EditFatTarih: TcxDBDateEdit;
    EditFatNo: TcxDBTextEdit;
    EditFaturaSaat: TcxDBTimeEdit;
    cxDBLabel1: TcxDBLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    ToolBar3: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton8: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    BtnDovizKuru: TToolButton;
    editDovizKuru: TcxDBCurrencyEdit;
    GridFaturaViewID: TcxGridDBColumn;
    GridFaturaViewMF: TcxGridDBColumn;
    GridFaturaViewVADE: TcxGridDBColumn;
    GridFaturaViewISKONTOLUBRMFIYAT: TcxGridDBColumn;
    GridFaturaViewKDVDAHILFIYAT: TcxGridDBColumn;
    frxTOPLAMLAR: TfrxDBDataset;
    frxDETAY: TfrxDBDataset;
    GridFaturaViewOTVMIKTAR: TcxGridDBColumn;
    DtsHesapOzeti: TDataSource;
    TabHesapOzeti: TFDQuery;
    frxHesapOzeti: TfrxDBDataset;
    N4: TMenuItem;
    retimPlanndaGsterme1: TMenuItem;
    GridFaturaViewURETIMPLANINDAGOSTER: TcxGridDBColumn;
    GsterSeiliSatr1: TMenuItem;
    GsterTm1: TMenuItem;
    GstermeSeiliSatr1: TMenuItem;
    GstermeTm1: TMenuItem;
    cxLabel7: TcxLabel;
    cbOnaylayacak: TcxDBImageComboBox;
    GridFaturaViewMIKTAR: TcxGridDBColumn;
    GridFaturaViewBIRIM2MIKTAR: TcxGridDBColumn;
    GridFaturaViewBIRIM2AD: TcxGridDBColumn;
    BeditServis: TcxButtonEdit;
    cxLabel8: TcxLabel;
    DtsStokDetay: TDataSource;
    tabStokDetay: TFDQuery;
    frxStokDetay: TfrxDBDataset;
    GridFaturaViewSATICIADI: TcxGridDBColumn;
    tvFatToplamlarTUR: TcxGridDBColumn;
    tvFatToplamlarACIKLAMA: TcxGridDBColumn;
    tvFatToplamlarDEGER: TcxGridDBColumn;
    tvFatToplamlarKUR: TcxGridDBColumn;
    tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn;
    tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    lbSatici: TcxLabel;
    cbSatici: TcxButtonEdit;
    EditOZELKOD: TcxDBTextEdit;
    cxLabel14: TcxLabel;
    Bevel1: TBevel;
    cxLabel1: TcxLabel;
    EditDepartman: TcxButtonEdit;
    EditBirimOnaylayan: TcxButtonEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cbBirimOnaylayacak: TcxDBImageComboBox;
    GridFaturaViewRESIM: TcxGridDBColumn;
    GridFaturaViewDOKUMAN: TcxGridDBColumn;
    N6: TMenuItem;
    Deitir1: TMenuItem;
    MenuDegisTeslimTarihi: TMenuItem;
    procedure SIPARISBeforePost(DataSet: TDataSet);
    procedure SiparisEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure DetayEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure SIPARISNewRecord(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure SIPARISDETAYNewRecord(DataSet: TDataSet);
    procedure SIPARISDETAYBeforePost(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FaturaTusClick(Sender: TObject);
    procedure ButtonDuzenle;
    procedure SIPARISDETAYAfterDelete(DataSet: TDataSet);
    procedure SIPARISDETAYAfterPost(DataSet: TDataSet);
    procedure TamEkranTusClick(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure MenuMusTreeDblClick(Sender: TObject);
    procedure MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure btnFisIrsaliyeClick(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BeditBagliGorevPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelAdClick(Sender: TObject);
    procedure SIPARISAfterPost(DataSet: TDataSet);
    procedure SIPARISBeforeEdit(DataSet: TDataSet);
    procedure DtsSIPARISStateChange(Sender: TObject);
    procedure DtsSIPARISDETAYStateChange(Sender: TObject);
    function EkranAdiAl : string;
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure cxGridDBColumn4GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure cxEditRepository1ButtonItem1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KDVHaricTutargir1Click(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure N52Click(Sender: TObject);
    procedure TutarDvzHesapla1Click(Sender: TObject);
    procedure GridFaturaViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure SIPARISDETAYCalcFields(DataSet: TDataSet);
    procedure LabelKodClick(Sender: TObject);
    procedure GridFaturaViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure SiparisEkrPage(Sender: TObject);
    procedure DetayEkrPage(Sender: TObject);
    procedure PlanlamaEkrPage(Sender: TObject);
    procedure SipariKoanAyarlar1Click(Sender: TObject);
    procedure lbDetaySablonClick(Sender: TObject);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure SIPARISAfterScroll(DataSet: TDataSet);
    procedure editDovizKuruPropertiesChange(Sender: TObject);
    procedure GridFaturaViewMASRAFADGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
    procedure GridFaturaViewMASRAFADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SIPARISDETAYBeforeOpen(DataSet: TDataSet);
    procedure btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure BeditProjeDblClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnDonusturClick(Sender: TObject);
    procedure GridFaturaViewEKIPMANIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnDovizKuruClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure GridFaturaViewACIKLAMA1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbDovizCinsiPropertiesCloseUp(Sender: TObject);
    procedure GsterSeiliSatr1Click(Sender: TObject);
    procedure BeditServisDblClick(Sender: TObject);
    procedure BeditServisPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure BeditBagliGorevDblClick(Sender: TObject);
    procedure EditDepartmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbSaticiPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditBirimOnaylayanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridFaturaViewRESIMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridFaturaViewDOKUMANPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure MenuDegisTeslimTarihiClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    AraDlg : TStokHizmetAraDlg;
    sonbasilanctrl :TcxButtonEdit;
    KuraGoreFiyatHesaplamaAlani:integer ; //faturaadetchange olayında kullanılıyor bu değişken
    function BoslukKontrolu: Boolean;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure FaturaTutarHesapla(TabloAc:Boolean);
    procedure FirmaBilgileri;
    function DetaySablonTipiBul:integer;
    procedure IletisimEkleClick(Sender: TObject);
    procedure SatinAlmainsert;
    function SipKontrol:boolean;
    function ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
  public
    { Public declarations }
    IslemOp: Char;
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    SiparisTur, SiparisIdsi, RehberId, ProjeId, AktiviteId,MasrafMerkezi,ServisID,SatinAlmaID: Integer;
    iadefis, IptalSecildi: Boolean;
    Cagiran: SmallInt;

  end;

var
  SatinAlmaWizard2: TSatinAlmaWizard2;
  DYetkisonuc:DokumanYetkiSonuc;

implementation

uses ULog,UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra, UFastRap, UOPSDLG,
  UParaDegisiklik, URaporAraclari, UGenelAnaSekmeFrame,UFisIrsaliyeAraDlg,UGirisKutusuEx, UGorevDlg, UIsListesi,
  UCariFonksiyonlar, UAnaForm, URehberAyar ,IdGlobalProtocols,LocOnFly, UVeriMotor, UDFMPG;

{$R *.dfm}

var
   Belge, OncekiKDVDurumu : String[10];
   OncekiSubeID,   OncekiBirimOnaylayacak,   OncekiOnaylayacak :integer;
   Kilit, EkleDetay : Boolean;
   tab : TFDQuery;

function TSatinAlmaWizard2.DetaySablonTipiBul:integer;
begin
   Result:= TabNo_SATINALMA;
end;
procedure TSatinAlmaWizard2.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TSatinAlmaWizard2.DkmanSil1Click(Sender: TObject);
begin
if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_SATINALMA,siparis.FieldByName('ID').AsInteger]);
  end;
end;

procedure TSatinAlmaWizard2.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[TabNo_SATINALMA, SIPARIS.FieldByName('ID').AsInteger]);
end;

procedure TSatinAlmaWizard2.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
                      TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, SIPARIS.FieldByName('REHBERID').AsInteger)
end;

function TSatinAlmaWizard2.EkranAdiAl: string;
begin
  Result := 'SatinAlmaDlg';
end;

procedure TSatinAlmaWizard2.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   FatTutar : Currency;
   MusIlgiliID,PersonelID:string;
begin
  DokumAdi := YaziciYaz.Caption;
  Ekranadi := EkranAdiAl;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if SIPARIS.State in [dsEdit,dsInsert] then
     SIPARIS.Post;
  TabloYenile(SIPARIS, [SiparisIdsi]);
  if SIPARISDETAY.State in [dsEdit,dsInsert] then
     SIPARISDETAY.Post;
  TabloYenile(SIPARISDETAY, [SIPARIS.FieldByName('ID').AsInteger]);
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxSIPARIS) then
    AFastReport.EnabledDataSets.Add(frxSIPARIS)
  else begin
    frxSIPARIS.DataSet := SIPARIS;
    AFastReport.EnabledDataSets.Add(frxSIPARIS);
    AFastReport.EnabledDataSets.Add(frxSIPARISDETAY);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
    if AktifVeriMotor = vmPG then Tablo.TabMusteri.SQL.Text := PgSqlCevir(Tablo.TabMusteri.SQL.Text);
    Tablo.TabMusteri.Open;
    if SIPARIS.FieldByName('REHBERILETID').Value <> null then begin
      TabloYenile(Tablo.TabSevkAdresi,[RehberId,SIPARIS.FieldByName('REHBERILETID').AsInteger]);
      AFastReport.EnabledDataSets.Add(Tablo.frxSevkAdresi);
    end else
      Tablo.TabSevkAdresi.Close;

    TabloYenile(tabStokDetay, [SIPARIS.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxStokDetay);

    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);

    MusIlgiliID := IIF(SIPARIS.FieldByName('MUS_ILGILI').AsString='','-99',SIPARIS.FieldByName('MUS_ILGILI').AsString);
    Tablo.TabMusteriIlgili.Close;
    Tablo.TabMusteriIlgili.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1',MusIlgiliID, [rfReplaceAll]);
    if AktifVeriMotor = vmPG then Tablo.TabMusteriIlgili.SQL.Text := PgSqlCevir(Tablo.TabMusteriIlgili.SQL.Text);
    Tablo.TabMusteriIlgili.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteriIlgili);

    PersonelID := IIF(SIPARIS.FieldByName('SATICIKODU').AsString='','-99',SIPARIS.FieldByName('SATICIKODU').AsString);
    Tablo.TabPersonel.Close;
    Tablo.TabPersonel.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1',PersonelID, [rfReplaceAll]);
    if AktifVeriMotor = vmPG then Tablo.TabPersonel.SQL.Text := PgSqlCevir(Tablo.TabPersonel.SQL.Text);
    Tablo.TabPersonel.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxPersonel);

    if (DovizTakibi)and(SIPARIS.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz) then
       FatTutar := SIPARIS.FieldByName('DOVIZ_TUTARI').AsCurrency
    else
       FatTutar := SIPARIS.FieldByName('SIPARIS_TUTARI').AsCurrency;
    TabloYenile(TabHesapOzeti,[SIPARIS.FieldByName('REHBERID').AsInteger, SIPARIS.FieldByName('DOVIZ_CINSI').AsString, FatTutar]);
    AFastReport.EnabledDataSets.Add(frxHesapOzeti);

    AFastReport.EnabledDataSets.Add(frxDETAY);
    AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
  end;
  // Kullanici ek alanlari (_USER) rapora (satinalma siparis karti; SIPARIS tablosu).
  Tablo.UserAlanYazdirmaEkle(AFastReport, 'SIPARIS', SiparisIdsi);
end;

procedure TSatinAlmaWizard2.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Siparisdetay);
end;

procedure TSatinAlmaWizard2.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  KaydetTus.Click;
//  SIPARIS.Close;
//  SIPARIS.Params[0].Value := SiparisIdsi;
//  SIPARIS.Open;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARIS set YAZDIRILDI=1 where ID='+SIPARIS.FieldByName('ID').AsString,[],[]);
end;

procedure TSatinAlmaWizard2.BeditBagliGorevDblClick(Sender: TObject);
var GOREV_ID: String[15];
    GorevDlg1: TGorevDlg;
begin
   GOREV_ID:= SIPARIS.FieldByName('AKTIVITEID').AsString;
   Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',StrToInt(GOREV_ID),AtamaYapildi, YorumYapildi);
   if AtamaYapildi then
      Gorev_EPostaGonder(1, StrToIntDef(GOREV_ID,-1))
   else if YorumYapildi then
      Gorev_EPostaGonder(3, StrToIntDef(GOREV_ID,-1));
end;

procedure TSatinAlmaWizard2.BeditBagliGorevPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
begin
  if AButtonIndex = 0 then
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(AktiviteSecimi,'SELECT G.ID,TARIH=BASLAMATARIHI,EKLEYEN=R.FIRMA,DURUM=GT2.ANAHTAR,TUR=GT1.ANAHTAR,KONUSU '+
         'FROM GOREVLER G inner join REHBER R on R.ID=G.EKLEYEN left join GENINI GT1 on GT1.BOLUM=-21044 and G.TURU=GT1.DEGER '+
         'left join GENINI GT2 on GT2.BOLUM=-21042 and G.TURU=GT2.DEGER where KONUSU like ''%<ara>%'' and REHBERID=' + SIPARIS.FieldByName('REHBERID').AsString+' ORDER BY 2 DESC', st, []) then begin
         SIPARIS.Edit;
         SIPARIS.FieldByName('AKTIVITEID').AsString := st.Strings[0]+' '+st.Strings[4];
         BeditBagliGorev.Text := st.Strings[1];
      end;
    finally
      st.free;
    end
  else if AButtonIndex = 1 then begin
    SIPARIS.Edit;
    SIPARIS.FieldByName('AKTIVITEID').AsString := '-1';
    BeditBagliGorev.Text := '';
  end;
end;

procedure TSatinAlmaWizard2.BeditProjeDblClick(Sender: TObject);
begin
  if BeditProje.Text <> '' then
     Tablo.ProjeSihirbazBaslat('D', SIPARIS.FieldByName('PROJEID').AsInteger, SIPARIS.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);
end;

procedure TSatinAlmaWizard2.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
    Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_Siparisdetay);
end;

procedure TSatinAlmaWizard2.GsterSeiliSatr1Click(Sender: TObject);
begin
  if (Sender as TMenuItem).Tag = 1 then  begin//seçiliyi göster
    if StrToIntDef(VarToStrDef(SIPARISDETAY.FieldByName('URETIMPLANDETAYID').Value,'0'),0) < 0 then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = null where ID='+SIPARISDETAY.FieldByName('ID').AsString,[],[])
    else
      ShowMessage('Bu satır gösterimde ya da kullanımda. İşlem gerçekleştirilemiyor.');
  end;
  if (Sender as TMenuItem).Tag = 2 then  begin  //tümünü göster
    if SipKontrol then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = null where SIPARISID='+SIPARIS.FieldByName('ID').AsString,[],[]);
  end;
  if (Sender as TMenuItem).Tag = 3 then  begin  //seçiliyi sakla
    if StrToIntDef(VarToStrDef(SIPARISDETAY.FieldByName('URETIMPLANDETAYID').Value,'0'),0) = 0 then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = -1 where ID='+SIPARISDETAY.FieldByName('ID').AsString,[],[])
    else
      ShowMessage('Bu satır saklı ya da kullanımda. İşlem gerçekleştirilemiyor.');
  end;
  if (Sender as TMenuItem).Tag = 4 then  begin  //tümünü sakla
    if SipKontrol then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = -1 where SIPARISID='+SIPARIS.FieldByName('ID').AsString,[],[]);
  end;
   TabloYenile(SIPARISDETAY, [SIPARIS.Fields[0].AsInteger]);
end;

function TSatinAlmaWizard2.SipKontrol:boolean;
var
  plandetID:variant;
begin
  Result := True;
  SIPARISDETAY.First;
  plandetID := SIPARISDETAY.FieldByName('URETIMPLANDETAYID').Value;
  while not SIPARISDETAY.Eof do begin
    if SIPARISDETAY.FieldByName('URETIMPLANDETAYID').Value <> plandetID then begin
      ShowMessage('Kullanılmış ya da kapatılmış satırlar mevcut, lütfen her satır için ayrı işlem uygulayın.');
      Exit(False);
    end;
    SIPARISDETAY.Next;
  end;
end;

procedure TSatinAlmaWizard2.BeditProjePropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje,SIPARIS,AButtonIndex,ProjeSecimi, SIPARIS.FieldByName('REHBERID').AsInteger);
  if SIPARIS.FieldByName('PROJEID').AsInteger > 0 then
    if Tablo.UyariGoster('Proje Seçimi','Seçmiş olduğunuz proje, belgenizin tüm satırlarına uygulansın mı?',2)=MrYes then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set PROJEID=&PrjID where SIPARISID=&FatbasID',['&PrjID','&FatbasID'],[SIPARIS.FieldByName('PROJEID').AsInteger,SIPARIS.FieldByName('ID').AsInteger]);
  TabloYenile(SIPARISDETAY, [SIPARIS.FieldByName('ID').AsInteger]);
end;


procedure TSatinAlmaWizard2.BeditServisDblClick(Sender: TObject);
begin
  if (SIPARIS.FieldByName('SERVISID').Value <> null) and (SIPARIS.FieldByName('SERVISID').AsInteger>0) then
    Tablo.ServisSihirbazBaslat(False,'D',0,SIPARIS.FieldByName('SERVISID').AsInteger,SIPARIS.FieldByName('REHBERID').AsInteger);
end;

procedure TSatinAlmaWizard2.BeditServisPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  st: Tstringlist;
  SQL:string;
begin
  if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '-' then begin
    SIPARIS.Edit;
    SIPARIS.FieldByName('SERVISID').Value := Null;
    SIPARIS.Post;
    (Sender as TcxButtonEdit).Text := '';
    (Sender as TcxButtonEdit).Tag := 0;
  end else begin
    SQL:='select ID,SERVISNO,BASLAMATARIHI,BITISTARIHI,KONUSU  from SERVIS where (SERVISNO like ''%<ara>%'' or KONUSU like ''%<ara>%'') and isnull(ACKAPA,0)=0 ';
    if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '+' then
      SQL:=SQL+'and REHBERID=' + IntToStr(RehberId);
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(ServisSecimi,SQL, st, []) then begin
        SIPARIS.Edit;
        SIPARIS.FieldByName('SERVISID').AsString := st.Strings[0];
        SIPARIS.Post;
        (Sender as TcxButtonEdit).Text := st.Strings[1]+' - '+st.Strings[4];
        (Sender as TcxButtonEdit).Tag := StrToIntDef(st.Strings[0],0);
      end;
    finally
      st.free;
    end;
  end;
end;

procedure TSatinAlmaWizard2.DetayEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var Yeri : SmallInt;
begin
    TabDetay.Close;
    if AktifVeriMotor = vmPG then TabDetay.SQL.Text := SQL_PG_RehberDetay
    else TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    Tabloyenile(TabDetay, [DetaySablonTipiBul, SIPARIS.FieldByName('ID').AsInteger, ComboBolum.Text])
end;

procedure TSatinAlmaWizard2.DetayEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TSatinAlmaWizard2.DtsSIPARISStateChange(Sender: TObject);
begin
   KaydetTus.enabled := DtsSIPARIS.State in [dsEdit, dsInsert];
   IptalTus.enabled := KaydetTus.enabled;
end;

procedure TSatinAlmaWizard2.EditBirimOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var RehID : Integer;
    s:string[10];
    procedure Islem(Kod, Onaylayacak, OnayAlan, TarihAlan:string; EditOnay : TcxButtonEdit; TabNo:Integer);
    begin
      if Assigned(Sender) then begin
         RehID := Tablo.KullaniciAdiSifreSor(StringReplace(OnayYetki, '@YetkiKodu', Kod, []), SIPARIS.FieldByName(Onaylayacak).AsString);
         if RehID = 0 then
            Abort;
      end;
      SIPARIS.Edit;
      if AButtonIndex = 0 then begin
        SIPARIS.FieldByName(OnayAlan).AsInteger := RehID;
        SIPARIS.FieldByName(TarihAlan).AsDateTime := Tablo.GENINI.BugunTrhSaat;
        EditOnay.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID);
        s:='getdate()';
      end else if AButtonIndex=1 then begin
          SIPARIS.FieldByName(OnayAlan).AsInteger := 0;
          EditOnay.Text := '';
          s:='null ';
      end;
      SIPARIS.Post;
      // okundu işaretleyelim ki panodaki listeden silinsin
      VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI='+s+' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Tabno)+' and YER_ID='+SIPARIS.FieldByName('ID').AsString+')',[],[]);
    end;
begin
   if TcxButtonEdit(Sender).Name='EditOnaylayan' then
      Islem('24010852','ONAYLAYACAK', 'ONAYLAYAN','ONAYTARIHI',EditOnaylayan, TabNo_SATINALMA)
   else
      Islem('24010850','BIRIMONAYLAYACAK', 'BIRIMONAYLAYAN','BIRIMONAYTARIHI',EditBirimOnaylayan, TabNo_Satinalma_Talep);
end;

procedure TSatinAlmaWizard2.EditDepartmanPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var  ID : Integer;
begin
  ID := Tablo.RolAra_IDGetir;
  if ID<>-99 then begin
     SIPARIS.Edit;
     SIPARIS.FieldByName('BOLUM').AsInteger := ID;
     EditDepartman.text := Tablo.DepartmanGorevGetir(1, ID);
  end;
end;

procedure TSatinAlmaWizard2.editDovizKuruPropertiesChange(Sender: TObject);
begin
  if SIPARIS.State in [dsEdit,dsInsert] then
    TabloYenile(TOPLAMLAR,[SIPARIS.FieldByName('ID').AsInteger]);
end;

procedure TSatinAlmaWizard2.DtsSIPARISDETAYStateChange(Sender: TObject);
begin
   KaydetTus.enabled := DtsSIPARISDETAY.State in [dsEdit, dsInsert];
   IptalTus.enabled := KaydetTus.enabled;
end;

procedure TSatinAlmaWizard2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (IptalSecildi) and ((IslemOp = 'E') or (IslemOp='K')) then// eğer yeni kayıtsa ve iptal edildiyse kaydedilmiş bilgiler silinmesi lazım
    if (SIPARIS.Active) and (SIPARIS.Fields[0].AsString <> '') then
     begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_SIPARIS_DOKUMAN, SIPARIS.FieldByName('ID').AsInteger]);
      Tablo.SiparisSil(SIPARIS.FieldByName('ID').AsInteger);
     end;
  if not ((IptalSecildi) and ((IslemOp = 'E') or (IslemOp='K'))) then
     // FALLBACK: yeni satinalma kaydedilip loglanmadan kapatildiysa EKLEME logu kacmasin (tek sefer).
     FEkleLogland := LogKartEkle(SIPARIS, TabNo_SATINALMA, (IslemOp='E') or (IslemOp='K'), FEkleLogland) or FEkleLogland;
end;

procedure TSatinAlmaWizard2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var Ciksin : Boolean;
begin
   Ciksin := True;
   if (IptalSecildi)and((IslemOp='E')or (IslemOp='K')or( (IslemOp='D')and(KaydetTus.enabled)))then
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : begin
                Ciksin := False;
                WizardKontrolFinishButtonClick(Self);
               end;
       IDCANCEL:Ciksin := False;
      end;

   if (IslemOp='D')and(SIPARISDETAY.IsEmpty) then begin
            raise Exception.Create(UrungirilmedenKaydedilemez);
   end;

   CanClose := Ciksin;
end;

procedure TSatinAlmaWizard2.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
     Tablo.WizardTurkcelestir(WizardKontrol);

  //GridFaturaView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\SiparisSihirbazDetayGridi',true,false,[gsoUseFilter],'SiparisSihirbazDetayGridi');
  Tablo.GridAyarRestore('FatSiparisDetayGridi',GridFaturaView );
  Tablo.GridTurkcelestir;
  RehberId := -1;
  ProjeId := -1;
  AktiviteId := -1;
  iadefis:=False;
  IptalSecildi := true;
  LogID:=0;

{  cbDovizCinsi.Visible:=DovizTakibi;
  lbDoviz.Visible:=DovizTakibi;
  editDovizKuru.Visible:=DovizTakibi;
  }
  if not DovizTakibi then begin
    FreeAndNil(GridFaturaViewDOVIZKURDEGERI);
    FreeAndNil(GridFaturaViewDOVIZ_TUTARI);
    FreeAndNil(GridFaturaViewDOVIZ_BIRIMFIYAT);
    FreeAndNil(GridFaturaViewDOVIZ_KURU);
    FreeAndNil(tvFatToplamlarDOVIZTUTARI);
    FreeAndNil(tvFatToplamlarDOVIZ_KURU);
  end;

  KuraGoreFiyatHesaplamaAlani:=1; //1 birimfiyat 2 dövizbirimfiyat
  Tablo.GENINI.ReadImageSection(Ops_StokKart_Anabirim,(GridFaturaViewBIRIM1.Properties as TcxImageComboBoxProperties).Items);
end;

procedure TSatinAlmaWizard2.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if VK_RETURN = Key then Key := 0;
end;

procedure TSatinAlmaWizard2.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos :=Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bileşen Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TSatinAlmaWizard2(Self),DtsSIPARIS);
    end;
  end
  else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bileşen Düzenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
      Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(PanelUst.Name),TSatinAlmaWizard2(Self),DtsSIPARIS);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('S')) then  begin  //Bileşen Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      if ctrl.Name <> '' then begin
        Tablo.TablodanSorguAc(1,'Select CAPTION,ALANADI,TAG from ALANLAR Where TAG='+IntToStr(ctrl.Tag)+' and TUR <> 11 ');
        if Application.MessageBox(PChar(Tablo.Query1.FieldByName('CAPTION').AsString+' alanını silmek istiyor musunuz?'),'UYARI',MB_YESNO)=mrYes then  begin

          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from ALANLAR Where TAG ='+IntToStr(ctrl.Tag)+' ',[],[]);
          try
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Alter table DEMIRBAS drop column '+Tablo.Query1.FieldByName('ALANADI').AsString+' ',[],[]);
          except
          end;
          ctrl.Visible := False;
          //Tablo.AlanOlustur(FindComponent(PanelAlt.Name),TSatinAlmaWizard2(Self),-1,DtsSIPARIS);
          Tablo.AlanOlustur(TSatinAlmaWizard2(Self),-1,DtsSIPARIS);
        end;
      end;
    end;
  end;

end;

procedure TSatinAlmaWizard2.FormShow(Sender: TObject);
var
  ra: string;
  TN: TTreeNode;
  belgeno: TBelgeNo;
  aktifFrame : TGenelAnaSekmeFrame;
  kod: string;
  kullanan2: string;
  KurDegeri : currency;
begin
  SatinAlmaWizard2.Height:= Screen.Height- round(Screen.Height*0.1);
  EkleDetay := False;
  Tablo.AlanOlustur(TSatinAlmaWizard2(Self), -1,DtsSIPARIS);

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;


  Tablo.FaturaInit(SiparisTur, nil, TcxImageComboBoxProperties(GridFaturaViewTUR.Properties), TcxImageComboBoxProperties(GridFaturaViewBIRIM1.Properties));
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  if aktifFrame.ClassName = 'TGenelAnaSekmeFrame' then begin
    YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
    if aktifFrame.Name <> 'AnaGirisSayfasiFrame' then
      PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;
  end;


  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;

{  if IslemOp='K' then begin
    Tablo.TablodanSorguAc(3,'select * from SIPARISDETAY where SIPARISID=' + inttostr(SiparisIdsi));
    belgeno := SiradakiBelgeNumarasi(SiparisTur, SIPARIS.FieldByName('SIPARISTARIH').AsDateTime);
    SiparisIdsi := Tablo.SQLSatiriKopyala('SIPARIS', SiparisIdsi,['TARIH', 'SIPARISTARIH', 'EKLEYEN','SIPARISSERI', 'KOCANNO', 'SIPARISNO','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','ONAYLAYAN'],
          [Tablo.GENINI.BugunTrh, Tablo.GENINI.BugunTrhSaat, Kullanan,belgeno.SeriNo,KocannoBul(SiparisTur), belgeno.belgeno,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);
    while not Tablo.Query3.Eof do begin
      Tablo.SQLSatiriKopyala('SIPARISDETAY', Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', 'SIPARISID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI'],
          [Kullanan, SiparisIdsi,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
      Tablo.Query3.Next;
    end;
  end; }

  LabelProje.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  LabelAktivite.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  BeditProje.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  BeditBagliGorev.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  DetayEkr.EnableButton(bkNext,Tablo.YetkiVarmi(MODUL_Kasa,YetkiTur_Gorme));
  FirmaBilgileri;
  TabloYenile(SIPARIS, [SiparisIdsi]);
  Kilit := False;
  if (IslemOp='D')and(KilitKontrolEt(2, SiparisTur,SIPARIS.FieldByName('SIPARISTARIH').AsDateTime,2)) then begin
     Kilit := True;
     SIPARIS.Close;
     SIPARIS.Open;
     ToolBar5.Enabled := False;
  end;
  TabloYenile(SIPARISDETAY,[SiparisIdsi]);

  if cagiran = 5 then  begin    //SATINALMA dan geliyor
     SatinAlmainsert;
  end;

  if (IslemOp='E')and(SIPARISDETAY.IsEmpty) then
     SIPARIS.Append;

{  if Cagiran=9 then  begin           //Tekliften Oluşturulan Siparişlerde Toplamlar ve Doviz değerleri hesaplanıyor.
    SIPARIS.Edit;
    cbDovizCinsiPropertiesCloseUp(Sender);
    SIPARISDETAY.AfterPost:=nil;
    SIPARISDETAY.First;
    while not SIPARISDETAY.eof do begin
      SIPARISDETAY.Edit;
      SIPARISDETAY.Post;
      //SIPARISDETAYADETChange(SIPARISDETAYADET);
      SIPARISDETAY.Next;
    end;
    SIPARISDETAY.AfterPost:=SIPARISDETAYAfterPost;
    if SIPARIS.State in [dsEdit] then
       SIPARIS.Post;
    TabloYenile(TOPLAMLAR,[SIPARIS.FieldByName('ID').AsInteger]);
  end; }

  FaturaTusClick(WizardKontrol.ActivePage);
  LogBelge.Clear;
  if SIPARISDETAY.active then begin
    SIPARISDETAY.First;
    while not SIPARISDETAY.Eof do begin
      if LogGun>0 then begin
        Tablo.BelgeLogBelirle(SIPARISDETAY);
      end;
      SIPARISDETAY.Next;
    end;
    if (not SIPARISDETAY.IsEmpty)and(Kilit=False) then begin
        SIPARISDETAY.Edit;
        SIPARISDETAY.Cancel;
    end;
  end;

  if SIPARIS.active then  begin
    //Siparişe aktarım yapıldıysa döviz kurunun güncellenmesi gerekir..
    if (IslemOp = 'E')and(not SIPARISDETAY.IsEmpty) then begin
      if cbDovizCinsi.EditValue <> null then begin
        KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', Tablo.GENINI.BugunTrh), cbDovizCinsi.EditValue , Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
        ShowMessage(KurGuncellendi);
      end else
        KurDegeri := 0;
      if SIPARIS.FieldByName('SIPARIS_MATRAHI').AsString='' then begin
        SIPARISDETAY.Edit;
        SIPARISDETAY.Post;
      end;
      if SIPARIS.state in [dsEdit,dsInsert] then
        SIPARIS.Post;

      SIPARISDETAY.First;
      while not SIPARISDETAY.Eof do
      begin
         SIPARISDETAY.Edit;
         SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency := KurDegeri;
         SIPARISDETAY.Post;
         SIPARISDETAY.Next;
      end;
    end;

    if (SIPARIS.FieldByName('SERVISID').Value <> null) and (SIPARIS.FieldByName('SERVISID').AsInteger>0) then begin
      Tablo.TablodanSorguAc(9,'select * from SERVIS where ID='+SIPARIS.FieldByName('SERVISID').AsString);
      if not Tablo.Query9.IsEmpty then begin
        BeditServis.Text := Tablo.Query9.FieldByName('SERVISNO').AsString+' - '+Tablo.Query9.FieldByName('KONUSU').AsString;
        BeditServis.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
      end;
    end;

    if SIPARIS.FieldByName('BIRIMONAYLAYAN').AsString <> '' then
       EditBirimOnaylayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', SIPARIS.FieldByName('BIRIMONAYLAYAN').AsString);
    if SIPARIS.FieldByName('ONAYLAYAN').AsString <> '' then
       EditOnaylayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', SIPARIS.FieldByName('ONAYLAYAN').AsString);


    if SIPARIS.FieldByName('PROJEID').AsString<>'' then
       BeditProje.Text:=Tablo.AciklamaGetir('PROJELER','PROJEKODU',SIPARIS.FieldByName('PROJEID').AsInteger);
    if SIPARIS.FieldByName('AKTIVITEID').AsString<>'' then begin
       Tablo.TablodanSorguAc(1, 'SELECT BASLAMATARIHI,TUR=GT1.ANAHTAR FROM GOREVLER G left join GENINI GT1 on GT1.BOLUM=-21044 and G.TURU=GT1.DEGER '+
          'where G.ID='+SIPARIS.FieldByName('AKTIVITEID').AsString);
       BeditBagliGorev.Text:=Tablo.Query1.Fields[0].AsString+' '+Tablo.Query1.Fields[1].AsString;
    end;

    if SIPARIS.FieldByName('SATICIKODU').AsString <> '' then
       cbSatici.Text := Tablo.AciklamaGetir('REHBER','FIRMA', SIPARIS.FieldByName('SATICIKODU').AsString);

  end;

  WizardKontrol.SelectFirstPage;
  PageControlUst.ActivePageIndex := 0;
  cbBirimOnaylayacak.Properties.Items := Tablo.imgComboboxInit('select ID=0, FIRMA='''' union all select R.ID,R.FIRMA from ROLLER RO inner join KULLANICI K on K.ROLID=RO.ID inner join REHBER R on R.ID=K.REHBERID left outer join YETKI Y on RO.ID=Y.ROLID and Y.MODULID=24010850 where R.DURUM>0 and (Y.HAK=1 or RO.TY=1)',False).Items;
  cbOnaylayacak.Properties.Items      := Tablo.imgComboboxInit('select ID=0, FIRMA='''' union all select R.ID,R.FIRMA from ROLLER RO inner join KULLANICI K on K.ROLID=RO.ID inner join REHBER R on R.ID=K.REHBERID left outer join YETKI Y on RO.ID=Y.ROLID and Y.MODULID=24010852 where R.DURUM>0 and (Y.HAK=1 or RO.TY=1)',False).Items;

  OncekiBirimOnaylayacak := SIPARIS.FieldByName('BIRIMONAYLAYACAK').AsInteger;
  OncekiOnaylayacak := SIPARIS.FieldByName('ONAYLAYACAK').AsInteger;

  if not Tablo.YetkiVarmi(2431,1,False) then begin  //tutarlar gözükmesin denirse;
    GridFaturaView.OptionsView.Footer := False;
    GridFaturaView.OptionsView.GroupFooters := gfInvisible;
    //for I := 0 to GridFatListeTview.ColumnCount-1 do
      //GridFatListeTview.Columns[i].Summary.Destroy;
    Miktarskontosu1.Visible := False;
    Yzdeskontosu1.Visible := False;
    utarDvzHesapla1.Visible := False;
  end;

  if SIPARIS.FieldByName('BOLUM').AsString <> '' then
     EditDepartman.text := Tablo.DepartmanGorevGetir(1, SIPARIS.FieldByName('BOLUM').AsInteger)
end;

procedure TSatinAlmaWizard2.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TSatinAlmaWizard2.GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry:TFDQuery;
  ctrls: TGirdiDenetimleri;
  sql: Variant;
begin
  if ACellViewInfo.Item.Index=0 then begin //tıklanan etiket mi
    Qry:=(Sender as TcxGridDBTableView).DataController.DataSource.DataSet as TFDQuery;
    if Trim(Qry.FieldByName('KAYNAK').AsString)<>'' then begin
      if Pos('select',LowerCase(Qry.FieldByName('KAYNAK').AsString))>0 then begin
        sql:=Qry.FieldByName('KAYNAK').AsString;
        ctrls := TGirdiDenetimleri.Create.Memo(Qry.FieldByName('ETIKET').AsString,@sql);
        if TGirisKutusuEx.BilgiAlEx(yenisorgugirin,ctrls) = mrOk then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set KAYNAK=&Sql where ETIKET=&Etiket and GIRIS=&Giris  ',['&Sql','&Etiket','&Giris'],[sql,Qry.FieldByName('ETIKET').AsString,Qry.FieldByName('GIRIS').AsInteger]);
        end;
      end else if Qry.FieldByName('GIRIS').AsInteger in [4,6,8,9] then begin //combo
        Tablo.TablodanSorguAc(7,'select DEGER from GENINI where DIL='+IntToStr(Dil)+'  AND  BOLUM=0 and ANAHTAR='''+qry.FieldByName('KAYNAK').AsString+'''');
        Tablo.GeniniBaslat(Tablo.Query7.Fields[0].AsInteger);

      end;
      Qry.Close;
      Qry.Open;
    end;
  end;
  //ACellViewInfo.GridRecord.Index //satır index değeri
  //ACellViewInfo.Item.Index //sütun index değeri
end;

procedure TSatinAlmaWizard2.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TSatinAlmaWizard2.GridFaturaViewACIKLAMA1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := SIPARISDETAY.fieldByName('ACIKLAMA').asstring;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Memo(BGAciklama_gir, @Bilgi)) <> mrOk then    //.Edit(FWToplamTutariGir, @Tutar
      Abort;
   SIPARISDETAY.edit;
   SIPARISDETAY.fieldByName('ACIKLAMA').AsString := VarToStr(Bilgi);
end;

procedure TSatinAlmaWizard2.GridFaturaViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridFatura;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFaturaView;
  AnaForm.pmGridStil.Tags.Values[GridFatura.Name]:='FatSiparisDetayGridi';
end;

procedure TSatinAlmaWizard2.GridFaturaViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if Kilit then exit;
  Tablo.SatirGuncelle(SIPARISDETAY, SiparisTur,1, SIPARIS.FieldByName('REHBERID').AsInteger, SIPARIS.FieldByName('SIPARISTARIH').AsDateTime,[]);
end;

procedure TSatinAlmaWizard2.GridFaturaViewDOKUMANPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var Sonuclar : TStringList;
begin
//
  Sonuclar := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir(BGDepo_kullan, 'select DOKUMANAD=D.AD, DOKUMANID=D.ID '+
           ' from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '+
           ' where GY.TUR=88 and GOREVID='+SIPARISDETAY.FieldByName('URUNID').AsString+' order by 1 ', Sonuclar,  []) then
        tablo.Dokuman_Gor_Duzenle(1, StrToIntDef(Sonuclar[1], 0), Sonuclar[0]);
    finally
      FreeAndNil(Sonuclar);
    end;
end;

procedure TSatinAlmaWizard2.GridFaturaViewEKIPMANIDPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st  : Tstringlist;
  SQL : string;
begin
 SQL:='Select ER.ID, E.KOD,E.AD, E.DETAYBOLUMU , '+
      '  ER.SERINO,ER.ACIKLAMA, ILGILI=(select ADSOYAD=FIRMA from REHBER RP where RP.ID=ER.MUS_ILGILI ), '+
      '  LOKASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=ER.LOKASYONID) '+
      '  from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID '+
      '  Where  ER.REHBERID=' + SIPARIS.FieldByName('REHBERID').AsString+' and E.AD like ''%<ara>%'' ';
  SIPARISDETAY.Edit;
  if AButtonIndex = 0 then try
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(ProjeSecimi,SQL, st, []) then begin
      SIPARISDETAY.FieldByName('EKIPMANID').AsString := st.Strings[0];
      SIPARISDETAY.Post;
    end;
  finally
    st.free;
  end else if AButtonIndex = 1 then begin
    SIPARISDETAY.FieldByName('EKIPMANID').AsString := '-1';
    SIPARISDETAY.Post;
  end;
end;

procedure TSatinAlmaWizard2.GridFaturaViewMASRAFADGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
begin
 if ARecord.Values[GridFaturaViewMASRAFAD.Index]>0 then
    AText := Tablo.AciklamaGetir('MASRAFGELIR','AD',ARecord.Values[GridFaturaViewMASRAFAD.Index]);
end;

procedure TSatinAlmaWizard2.GridFaturaViewMASRAFADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
   if SiparisTur in [14..19] then
      i := 1
   else
      i := 0;
   if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      SIPARISDETAY.Edit;
      SIPARISDETAY.FieldByName('MASRAFID').AsString := MASRAFID;
   end;

end;

procedure TSatinAlmaWizard2.GridFaturaViewRESIMPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Stoklar, SIPARISDETAY.FieldByName('URUNID').AsInteger, False);
end;

procedure TSatinAlmaWizard2.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TSatinAlmaWizard2.LabelAdClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(0,SIPARIS.FieldByName('REHBERID').AsInteger,-100, -100, False);
end;

procedure TSatinAlmaWizard2.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
  Id := Tablo.RehberAra_IDGetir(-1);
  if Id>0 then begin
      RehberId := Id;
      if SIPARIS.State = dsBrowse then
         SIPARIS.Edit;
      SIPARISNewRecord(SIPARIS);
      SIPARIS.FieldByName('REHBERID').AsInteger := RehberId;
      FirmaBilgileri;
    if SiparisTur =19 then begin
      Tablo.FaturaBaslik(SIPARIS,RehberId);
    end;
  end;
end;

procedure TSatinAlmaWizard2.lbDetaySablonClick(Sender: TObject);
var
 sablonadi :Variant;
begin

 if  trim(ComboBolum.Text) ='' then
  begin
       Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),pchar(Uyari), MB_OK+ MB_ICONWARNING);
       Abort;
  end;


  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer:= DetaySablonTipiBul;

  RehberAyarDlg.Bolum := ComboBolum.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  DetayEkrPage(Self);
end;

procedure TSatinAlmaWizard2.MenuDegisTeslimTarihiClick(Sender: TObject);
var Tarih : Variant;
begin
   if SIPARISDETAY.IsEmpty then
      exit;
   Tarih := SIPARISDETAY.FieldByName('TESLIMTARIHI').AsDateTime;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.DateTimePicker(BGTeslim_Tarihi, @Tarih, dtkDate)) <> mrOk then
         Abort;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set TESLIMTARIHI='''+FormatDateTime('yyyy-mm-dd', StrToDateTime(VarToStr(Tarih)))+''' where SIPARISID=&id ',['&id'],[SIPARIS.Fields[0].AsInteger]);
   TabloYenile(SIPARISDETAY, [SIPARIS.Fields[0].AsInteger]);
end;

procedure TSatinAlmaWizard2.MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if SiparisTur < 10 then
    raise Exception.Create(Aksiyon_sec);
end;

procedure TSatinAlmaWizard2.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TSatinAlmaWizard2.MenuMusTreeDblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TSatinAlmaWizard2.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TSatinAlmaWizard2.N52Click(Sender: TObject);
var Yuzde : Variant;
    IskTipi,s : String;
begin
   IskTipi :=  TMenuItem(Sender).Hint;
   if TMenuItem(Sender).Tag < 0 then begin//özel
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(FWYuzdesiniGirin, @Yuzde, 2)) <> mrOk then
         Abort;
      Yuzde := StringReplace(Yuzde, ',', '.', []);
   end else
      Yuzde := IntToStr(TMenuItem(Sender).Tag);
   s := Yuzde;
   if IskTipi='İskonto1' then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO=&Yuzde, TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 '+
          ',DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0 where SIPARISID=&id ',['&Yuzde','&id'],[s, SIPARIS.Fields[0].AsInteger])
   else if IskTipi='İskonto2' then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO2=&Yuzde, TUTAR=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 '+
          ', DOVIZ_TUTARI=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0 where SIPARISID=&id ',['&Yuzde','&id'],[s, SIPARIS.Fields[0].AsInteger]);
   FaturaTutarHesapla(True);
   TabloYenile(SIPARISDETAY, [SIPARIS.Fields[0].AsInteger]);
end;

procedure TSatinAlmaWizard2.PlanlamaEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TSatinAlmaWizard2.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TSatinAlmaWizard2.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_SATINALMA, SIPARIS .FieldByName('ID').AsInteger, TabYorum);
end;

procedure TSatinAlmaWizard2.SatirEkleClick(Sender: TObject);
begin
  if SIPARIS.State in [dsEdit, dsInsert] then
  begin
    SIPARIS.Post;
    TabloYenile(SIPARISDETAY, [SiparisIdsi]);
  end;

  if AraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,AraDlg);

  AraDlg.FatBasID:=SIPARIS.FieldByName('ID').AsInteger;
  AraDlg.RehberID:=SIPARIS.FieldByName('REHBERID').AsInteger;
  AraDlg.TabDetayGiris:= SIPARISDETAY;
  AraDlg.TabGiris := SIPARIS;
  AraDlg.KalanAdetGetir:=True;
  AraDlg.stokhizmetaracagirantur := SIPARIS.FieldByName('TUR').AsInteger;
  AraDlg.GirisCikis:=FWGiris;
  AraDlg.FiyatlariGetir:=True;
  AraDlg.cbFiyatAdi.EditValue := SIPARIS.FieldByName('FIYAT_LISTESI').Value;
  if Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme) then begin
     if SIPARISDETAY.IsEmpty then
        AraDlg.cbStokDepo.Enabled := True //daha önce depo seçimi yapılmamış, yapİlabilir
     else            //girilmiş stok işlemi var mı?
        AraDlg.cbStokDepo.Enabled := not Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SIPARISDETAY where SIPARISID =  &FId and TUR=1', ['&FId'],[SIPARIS.FieldByName('ID').AsInteger]);
  end;
  AraDlg.ShowModal;
end;

procedure TSatinAlmaWizard2.SatirSilClick(Sender: TObject);
begin
  if SIPARISDETAY.IsEmpty then abort;
  if Application.MessageBox(PCHAR(Sil_Onay),pchar(Onay), MB_YESNO + MB_ICONQUESTION) = ID_YES then begin
    if not Tablo.SiparisSilinebilirMi(0, SIPARISDETAY.FieldByName('ID').AsInteger) then   // KILIT + DONUSUM
       exit;
    SIPARISDETAY.Delete;
  end;
end;

procedure TSatinAlmaWizard2.SipariKoanAyarlar1Click(Sender: TObject);
begin
  Tablo.KocanAyarlariniGetir(SIPARIS.FieldByName('TUR').AsInteger);
end;

procedure TSatinAlmaWizard2.SIPARISAfterPost(DataSet: TDataSet);
begin
   SiparisIdsi := SIPARIS.Fields[0].AsInteger;
   DetayTus.Enabled := True;
   TabloYenile(TOPLAMLAR,[SiparisIdsi]);
   Tablo.TablodanSorguAc(3,'select 1 from SIPARIS where REHBERID='+SIPARIS.FieldByName('REHBERID').AsString
                                                      +' and TUR='+SIPARIS.FieldByName('TUR').AsString
                                                      +' and SIPARISNO='''+SIPARIS.FieldByName('SIPARISNO').AsString
                                                      +''' ');
   Tablo.Query3.FetchAll;
   if Tablo.Query3.RecordCount>1 then
      showmessage(SipariskulNo);

end;

procedure TSatinAlmaWizard2.SIPARISBeforeEdit(DataSet: TDataSet);
begin
   OncekiKDVDurumu := SIPARIS.FieldByName('KDVDURUM').AsString;
   OncekiSubeID :=SIPARIS.FieldByName('SUBEID').AsInteger;
   if LogGun>0 then begin
     Tablo.OncekiLogBelirle(SIPARIS);
   end;

end;

procedure TSatinAlmaWizard2.SIPARISBeforePost(DataSet: TDataSet);
begin
  BoslukKontrolu;
  //Bu cariden bu sipariş no ile daha önce sipariş alınmış mı kontrolü yapalım
  //Tablo.TablodanSorguAc(2,'select ID from SIPARIS where ')


  if OncekiSubeID <> SIPARIS.FieldByName('SUBEID').AsInteger then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update SIPARISDETAY set SUBEID='+SIPARIS.FieldByName('SUBEID').AsString+' Where SIPARISID ='+IntToStr(SiparisIdsi)+' ',[],[]);
  EkleyenDegistiren(DtsSIPARIS);
end;

{procedure TSatinAlmaWizard2.FaturaTutarHesapla;
Var SIPARIS_TUTARI, DOVIZ_TUTARI,SIPARIS_MATRAHI,KDV_TUTARI:Currency;
    s:string;
begin
  Tablo.Query1.Close;
  if cbKdvDurum.Text = 'Dahil' then // kdv hesaplarken round etmeden ayrı ayrı satırlar hesaplanır toplandıktan sonra round edilir..
    Tablo.Query1.SQL.Text :=
      ' Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
      ' DOVIZARATOPLAM=isnull(SUM(ROUND(DOVIZ_TUTARI/(1+(((KDV*(100.0)/100.0)/100.0))),2)),0.0), '+
      ' KDVTOPLAM=ROUND(isnull(SUM((TUTAR*KDV)*((100.0)/100.0)/(100+KDV)),0.0),2), '+
      ' DOVIZKDVTOPLAM=ROUND(isnull(SUM((DOVIZ_TUTARI*KDV)*((100.0)/100.0)/(100+KDV)),0.0),2) '+
      ' from SIPARISDETAY where SIPARISID=' + SIPARIS.Fields[0].AsString
  else
    Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
      ' isnull(SUM(ROUND(DOVIZ_TUTARI,2)),0.0) AS DOVIZARATOPLAM,' +
      ' isnull(ROUND(sum(TUTAR*((KDV*(100.0)/100.0)/100.0)),2),0.0) AS KDVTOPLAM,  ' +
      ' isnull(ROUND(sum(DOVIZ_TUTARI*((KDV*(100.0)/100.0)/100.0)),2),0.0) AS DOVIZKDVTOPLAM  ' +
      ' from SIPARISDETAY where SIPARISID=' + SIPARIS.Fields[0].AsString;
  Tablo.Query1.Open;

  SIPARIS_MATRAHI := Tablo.Query1.FieldByName('ARATOPLAM').AsExtended;
  KDV_TUTARI     := Tablo.Query1.FieldByName('KDVTOPLAM').Value;

  if cbKdvDurum.Text = 'Hariç' then begin
    SIPARIS_TUTARI := Tablo.Query1.FieldByName('ARATOPLAM').AsExtended + Tablo.Query1.FieldByName('KDVTOPLAM').AsExtended + SIPARIS.FieldByName('EKVERGI').AsExtended;
    DOVIZ_TUTARI := Tablo.Query1.FieldByName('DOVIZARATOPLAM').AsExtended+ Tablo.Query1.FieldByName('DOVIZKDVTOPLAM').AsExtended +SIPARIS.FieldByName('EKVERGI').AsExtended
  end else begin
    SIPARIS_TUTARI:= Tablo.Query1.FieldByName('ARATOPLAM').AsExtended + SIPARIS.FieldByName('EKVERGI').AsExtended;
    DOVIZ_TUTARI := Tablo.Query1.FieldByName('DOVIZARATOPLAM').AsExtended + SIPARIS.FieldByName('EKVERGI').AsExtended
  end;


  if (DOVIZ_TUTARI>0)and(SIPARIS.FieldByName('DOVIZ_CINSI').AsString <> CariDoviz) then
      s:=',DOVIZKUR='+FCurrToStr(SIPARIS_TUTARI)+'/'+FCurrToStr(DOVIZ_TUTARI)
   else
      s:='';
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARIS SET  '+
        ' DOVIZ_CINSI=(case when DOVIZ_CINSI is null then '''+SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString+''' else DOVIZ_CINSI end), '+
        ' SIPARIS_MATRAHI='+FCurrToStr(SIPARIS_MATRAHI)+',KDV_TUTARI='+FCurrToStr(KDV_TUTARI)+
        ',SIPARIS_TUTARI='+FCurrToStr(SIPARIS_TUTARI)+', DOVIZ_TUTARI= '+FCurrToStr(DOVIZ_TUTARI)+s+
        ' where ID='+SIPARIS.Fields[0].AsString,[],[]);

  TabloYenile(SIPARIS, [SiparisIDsi]);
  TabloYenile(TOPLAMLAR, [SiparisIDsi]);
end; }

function TSatinAlmaWizard2.ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
begin
  if TOPLAMLAR.Locate('TUR', Bolum,[loPartialKey]) then
    result := TOPLAMLAR.FieldByName(TLDoviz).AsExtended
  else
    result:=-99999;
end;

procedure TSatinAlmaWizard2.FaturaTutarHesapla(TabloAc:Boolean);
var DOVIZKUR,SIPARISDETAY_MATRAHI,KDV_TUTARI,SIPARISDETAY_TUTARI,DOVIZ_TUTARI,MALIYETORT,STOPAJ : extended;
    RaporDoviz,s:String;
begin
  TabloYenile( TOPLAMLAR, [SIPARIS.Fields[0].AsInteger]);
  SIPARISDETAY_MATRAHI := ToplamGetir(4,'DEGER');
  if SIPARISDETAY_MATRAHI=-99999 then
     SIPARISDETAY_MATRAHI := ToplamGetir(1,'DEGER'); //Toplam
  SIPARISDETAY_TUTARI  := ToplamGetir(20,'DEGER');    //'Genel Toplam'
  DOVIZ_TUTARI   := ToplamGetir(20,'DOVIZTUTARI');
  KDV_TUTARI     := SIPARISDETAY_TUTARI-SIPARISDETAY_MATRAHI;

  //RaporDoviz := 'RAPORDOVIZ=(case when RAPORDOVIZ is null then '''+SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString+''' else RAPORDOVIZ end),';
    RaporDoviz := ' DOVIZ_CINSI=(case when DOVIZ_CINSI is null then '''+SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString+''' else DOVIZ_CINSI end), ';

//  if ComboFatTipi.EditValue=5 then //kur farkı ise
//     RaporDoviz := RaporDoviz+'DOVIZ_CINSI=(case when RAPORDOVIZ is null then '''+SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString+''' else RAPORDOVIZ end),EKSTREDEKULLAN=1,';

  if (DOVIZ_TUTARI<>0)and(SIPARISDETAY_TUTARI>0)and(SIPARIS.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz) then
     s:= ',DOVIZKUR='+FCurrToStr(TOPLAMLAR.fieldbyname('DEGER').ascurrency)+'/Nullif('+FCurrToStr(TOPLAMLAR.fieldbyname('DOVIZTUTARI').ascurrency)+',0)'
  else
     s:=',DOVIZKUR='+FExtToStr((DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00',SIPARIS.FieldByName('SIPARISTARIH').AsDateTime),
            SIPARIS.FieldByName('DOVIZ_CINSI').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'))),4);

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARIS SET  '+ RaporDoviz+
        'SIPARIS_MATRAHI='+FCurrToStr(SIPARISDETAY_MATRAHI)+',KDV_TUTARI='+FCurrToStr(KDV_TUTARI)+
        ',SIPARIS_TUTARI='+FCurrToStr(SIPARISDETAY_TUTARI)+', DOVIZ_TUTARI= '+FCurrToStr(DOVIZ_TUTARI)+ S+
        ' where ID='+SIPARIS.Fields[0].AsString,[],[]);

  if TabloAc then
     TabloYenile(SIPARIS, [SIPARIS.Fields[0].AsInteger]);
end;

procedure TSatinAlmaWizard2.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
end;

procedure TSatinAlmaWizard2.SIPARISDETAYAfterDelete(DataSet: TDataSet);
begin
  FaturaTutarHesapla(True);
  SIPARISDETAY.Refresh;
end;

procedure TSatinAlmaWizard2.SIPARISDETAYAfterPost(DataSet: TDataSet);
begin
   TabloYenile(SIPARISDETAY,[SIPARIS.FieldByName('ID').AsInteger]);
   TabloYenile(TOPLAMLAR,[SIPARIS.FieldByName('ID').AsInteger]);
   FaturaTutarHesapla(True);

end;

procedure TSatinAlmaWizard2.SIPARISDETAYBeforeOpen(DataSet: TDataSet);
begin
   SIPARISDETAY.SQL.Text := StringReplace(SIPARISDETAY.SQL.Text,'@Dil',IntToStr(Dil),[rfReplaceAll]);
end;

procedure TSatinAlmaWizard2.SIPARISDETAYBeforePost(DataSet: TDataSet);
var
  Kur,Dovizkuru:string;
  Tutar,Doviztutari:Extended;
  Procedure DovizliIslemler;
  begin
     if (SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsString = '')or(SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency = 0.0) then begin
          if SIPARIS.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz then
             SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', SIPARIS.FieldByName('SIPARISTARIH').AsDateTime), SIPARIS.FieldByName('DOVIZ_CINSI').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'))
          else
             SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency := 1.0;
     end;
     if SIPARISDETAY.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency > 0.0 then begin
        SIPARISDETAY.FieldByName('BIRIMFIYAT').AsCurrency := SIPARISDETAY.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency * SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency;
        if (SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString<>SIPARIS.FieldByName('DOVIZ_CINSI').AsString)and
           (SIPARIS.FieldByName('DOVIZ_CINSI').AsString = CariDoviz) then
           SIPARISDETAY.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency := SIPARISDETAY.FieldByName('BIRIMFIYAT').AsCurrency;
     end else begin
         if (SIPARISDETAY.FieldByName('BIRIMFIYAT').AsString<>'')and(SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency>0) then
             SIPARISDETAY.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency := SIPARISDETAY.FieldByName('BIRIMFIYAT').AsCurrency / SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency;
     end;
     if (SIPARIS.FieldByName('DOVIZ_CINSI').AsString<>'')and
        (SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString<>SIPARIS.FieldByName('DOVIZ_CINSI').AsString) then begin
         SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString:=SIPARIS.FieldByName('DOVIZ_CINSI').AsString;
     end;
  end;
begin
  if StrToIntDef(SIPARIS.FieldByName('ONAYLAYAN').AsString,0) <> 0 then begin
    if Tablo.UyariGoster(Uyari,'Yaptığınız değişiklik sipariş onayını kaldıracaktır, devam etmek ister misiniz?',2)=mrYes then
      EditBirimOnaylayanPropertiesButtonClick(EditOnaylayan,1)
    else
      Abort;
  end;
//  SIPARISDETAY_Hesapla;
  // tur 1 olursa stok diğerleri için hizmet..
  if (SIPARISDETAY.FieldByName('ISKONTO').AsFloat=0)and(SIPARISDETAY.FieldByName('ISKONTO2').AsFloat<>0) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGSadeceIskonto2Girilemez);
     Abort;
  end;

  // DONUSUM KURALI: adet, bu satirdan URETILMIS (donusmus) adedin altina inemez.
  //   Ust sinir yok. Yeni satirda donusum olamaz -> yalniz dsEdit'te bakilir.
  if (SIPARISDETAY.State = dsEdit) and
     (not Tablo.AdetDusurulebilirMi('SIPARISDETAY',
            SIPARISDETAY.FieldByName('ID').AsInteger,
            SIPARISDETAY.FieldByName('ADET').AsFloat)) then
    Abort;
  if SIPARISDETAY.FieldByName('BIRIMFIYAT').AsString='' then
     SIPARISDETAY.FieldByName('BIRIMFIYAT').AsFloat:=0;
  if (not Eksiskontoya)and((SIPARISDETAY.FieldByName('ISKONTO').AsFloat<0)or(SIPARISDETAY.FieldByName('ISKONTO2').AsFloat<0)) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGEksiIskontoGirilemez);
     Abort;
  end;
//  SIPARISDETAY.FieldByName('TUTAR').Value :=((100-GridFaturaViewISKONTO1.EditValue)/100)*((100-GridFaturaViewISKONTO2.EditValue)/100)*
//                                    GridFaturaViewADET1.EditValue*GridFaturaViewBIRIMFIYAT1.EditValue;
  if DovizTakibi then
     DovizliIslemler;
    //bu bölüm her durumda çalışmalı..
  if (SIPARISDETAY.FieldByName('ADET').AsString<>'')and(SIPARISDETAY.FieldByName('BIRIMFIYAT').AsString<>'') then begin
      SIPARISDETAY.FieldByName('TUTAR').Value := Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - SIPARISDETAY.FieldByName('ISKONTO').Value) / 100)*
                ((100 - SIPARISDETAY.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,SIPARISDETAY.FieldByName('ADET').Value*SIPARISDETAY.FieldByName('BIRIMFIYAT').AsExtended));
      if DovizTakibi then
         SIPARISDETAY.FieldByName('DOVIZ_TUTARI').Value :=Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - SIPARISDETAY.FieldByName('ISKONTO').Value) / 100)*
                ((100 - SIPARISDETAY.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,SIPARISDETAY.FieldByName('ADET').Value*SIPARISDETAY.FieldByName('DOVIZ_BIRIMFIYAT').AsExtended));
  end;
  if (SIPARISDETAY.FieldByName('TUR').AsInteger = 1)and(SIPARISDETAY.FieldByName('BIRIM').AsString<>'') then // stoksa
      SIPARISDETAY.FieldByName('MIKTAR').AsFloat :=(SIPARISDETAY.FieldByName('ADET').AsFloat + SIPARISDETAY.FieldByName('MF').AsFloat) * Tablo.StokCarpan(SIPARISDETAY.FieldByName('URUNID').AsInteger, SIPARISDETAY.FieldByName('BIRIM').AsInteger)
  else if SIPARISDETAY.FieldByName('TUR').AsInteger = 0 then  //Hizmetse
      SIPARISDETAY.FieldByName('MIKTAR').AsFloat :=(SIPARISDETAY.FieldByName('ADET').AsFloat + SIPARISDETAY.FieldByName('MF').AsFloat);

  if not BoslukKontrol(SIPARISDETAY.FieldByName('ADET').AsString, 'Fatura adet') then
    Abort;
  if not BoslukKontrol(SIPARISDETAY.FieldByName('KDV').AsString, 'KDV') then
    Abort;


  if (SIPARISDETAY.FieldByName('TUR').AsInteger=1)and(veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMRECETE where STOKID='+SIPARISDETAY.FieldByName('URUNID').AsString,[],[])) then
    SIPARISDETAY.FieldByName('URETIMPLANDETAYID').AsInteger := 0
  else
    SIPARISDETAY.FieldByName('URETIMPLANDETAYID').AsInteger := -1;

  EkleyenDegistiren(DtsSIPARIS);
end;

procedure TSatinAlmaWizard2.SIPARISDETAYCalcFields(DataSet: TDataSet);
begin
 //  SIPARISDETAY.FieldByName('ISKTUTAR').Value:= (SIPARISDETAY.FieldByName('BIRIMFIYAT').AsCurrency* SIPARISDETAY.FieldByName('ADET').AsFloat)- SIPARISDETAY.FieldByName('TUTAR').AsCurrency;

   if (SIPARISDETAY.FieldByName('EKIPMANID').AsString<>'')and(SIPARISDETAY.FieldByName('EKIPMANID').AsInteger > 0) then begin
       Tablo.TablodanSorguAc(1,'select ER.EKIPMANID, E.AD, ER.SERINO  from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID where ER.ID='+SIPARISDETAY.FieldByName('EKIPMANID').AsString);
       SIPARISDETAY.FieldByName('EKIPMAN').AsString := Tablo.Query1.Fields[1].AsString;
       SIPARISDETAY.FieldByName('SERINO').AsString := Tablo.Query1.Fields[2].AsString;
   end
   else begin
       SIPARISDETAY.FieldByName('EKIPMAN').AsString:='';
       SIPARISDETAY.FieldByName('SERINO').AsString:='';
   end;
end;

procedure TSatinAlmaWizard2.SIPARISDETAYNewRecord(DataSet: TDataSet);
begin
  SIPARISDETAY.FieldByName('SIPARISID').AsInteger := SIPARIS.FieldByName('ID').AsInteger;
  SIPARISDETAY.FieldByName('REHBERID').AsInteger := RehberId;
  SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency:=1;
  SIPARISDETAY.FieldByName('MASRAFID').AsInteger := SIPARIS.FieldByName('MASRAFID').AsInteger;
  SIPARISDETAY.FieldByName('EKLEYEN').AsString := Kullanan;
  SIPARISDETAY.FieldByName('ISKONTO').AsInteger := 0;
  SIPARISDETAY.FieldByName('ISKONTO2').AsInteger := 0;
  SIPARISDETAY.FieldByName('KUR').AsString := CariDoviz;
  SIPARISDETAY.FieldByName('TESLIMTARIHI').Value :=Date;
  SIPARISDETAY.FieldByName('SUBEID').AsInteger := SubeID;
  SIPARISDETAY.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  SIPARISDETAY.FieldByName('PROJEID').AsInteger := SIPARIS.FieldByName('PROJEID').AsInteger;
end;

procedure TSatinAlmaWizard2.TamEkranTusClick(Sender: TObject);
begin
  PanelUst.Visible := not PanelUst.Visible;
  PanelAlt.Visible := PanelUst.Visible;
  if PanelUst.Visible then
    TamEkranTus.Caption := 'Tam Ekran'
  else
    TamEkranTus.Caption := 'Küçük Ekran'
end;

procedure TSatinAlmaWizard2.TutarDvzHesapla1Click(Sender: TObject);
var
  Tutar,DovizTutar:Extended;
  Kur,DovizKur:string;
begin
  Tutar := SIPARISDETAY.FieldByName('BIRIMFIYAT').Value;
  if SIPARISDETAY.FieldByName('DOVIZ_TUTARI').AsString <> '' then
     DovizTutar := SIPARISDETAY.FieldByName('DOVIZ_TUTARI').Value
  else
     DovizTutar := 0;
  DovizKur := SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString;
  Kur := SIPARISDETAY.FieldByName('KUR').AsString;
  if Tablo.DovizKuruSecimi(True,SIPARIS.FieldByName('SIPARISTARIH').AsDateTime,Kur,DovizKur,Tutar,DovizTutar) then begin
    if SIPARISDETAY.State <> dsEdit then
       SIPARISDETAY.Edit;
    SIPARISDETAY.FieldByName('BIRIMFIYAT').Value := Tutar;
    SIPARISDETAY.FieldByName('KUR').Value := Kur;
    SIPARISDETAY.FieldByName('DOVIZ_TUTARI').Value := DovizTutar;
    SIPARISDETAY.FieldByName('DOVIZ_KURU').Value := DovizKur;
    SIPARISDETAY.FieldByName('TUTAR').Value :=((100-GridFaturaViewISKONTO1.EditValue)/100)*
                                      ((100-GridFaturaViewISKONTO2.EditValue)/100)*
                                      GridFaturaViewADET1.EditValue*
                                      GridFaturaViewBIRIMFIYAT1.EditValue;
    SIPARISDETAY.Post;
  end;
end;

procedure TSatinAlmaWizard2.KaydetTusClick(Sender: TObject);
begin
  if SIPARIS.State in [dsInsert, dsEdit] then begin
     SIPARIS.Post;
     if islemOp='D' then  begin
        LogKartDegisti(SIPARIS, TabNo_SATINALMA, SiparisIdsi)
    end else if (islemOp='E') or (islemOp='K') then
        // Yeni/kopya satinalma -> baslik EKLEME logu (TEK SEFER; kapanis fallback ile ortak bayrak).
        FEkleLogland := LogKartEkle(SIPARIS, TabNo_SATINALMA, True, FEkleLogland) or FEkleLogland;
  end;
  if SIPARISDETAY.State in [dsInsert, dsEdit] then begin
     SIPARISDETAY.Post;
     SayA:=0;
     if LogBelge.Count > 0 then
        Tablo.LogIslemlerBelge(SIPARISDETAY, TabNo_SATINALMA, SiparisIdsi,4,TabNo_SIPARISDETAY)   // detay: siparis satir
  end;
  if EkleDetay then
      Ekle(TabDetay, DetaySablonTipiBul ,SiparisIdsi,'Değiş')
end;

procedure TSatinAlmaWizard2.KDVHaricTutargir1Click(Sender: TObject);
var Tutar,Kur : Variant;
    Yuzde : String;
    YuzdeFloat:extended;
begin
  Kur := CariDoviz;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.create
        .CurrencyEdit(FWToplamTutariGir, @Tutar,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))
        .ComboBox(FWKurGir,@Kur,Tablo.cxEditRepository1ComboBoxItemKurlar.Properties.Items)) <> mrOk then
      Abort;
  if Kur <> CariDoviz then begin //farklı kura göre miktar iskontosu için;
    if SIPARIS.FieldByName('DOVIZ_CINSI').AsString=Kur then begin
      try
        Tutar := Tutar*SIPARIS.FieldByName('DOVIZKUR').AsCurrency;
      except
        Tablo.TablodanSorguAc(0,'select '+DbUst(1)+Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)') + ' FROM DOVIZ WHERE CINSI='''+Kur+'''  ORDER BY ABS('+DbTarihFark('HOUR', ''''+FormatDateTime('yyyy-mm-dd 00:00', SIPARIS.FieldByName('SIPARISTARIH').AsDateTime)+'''', 'TARIH')+') '+DbSinir(1));
        Tutar := Tutar*Tablo.Query0.FieldByName(Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)')).AsCurrency;
      end;
    end else begin
      Tablo.TablodanSorguAc(0,'select '+DbUst(1)+Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)') + ' FROM DOVIZ WHERE CINSI='''+Kur+'''  ORDER BY ABS('+DbTarihFark('HOUR', ''''+FormatDateTime('yyyy-mm-dd 00:00', SIPARIS.FieldByName('SIPARISTARIH').AsDateTime)+'''', 'TARIH')+') '+DbSinir(1));
      Tutar := Tutar*Tablo.Query0.FieldByName(Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)')).AsCurrency;
    end;
  end;

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO=0.0, ISKONTO2=0.0, TUTAR=ADET*BIRIMFIYAT where SIPARISID=&id ',['&id'],[SIPARIS.Fields[0].AsInteger]);
   FaturaTutarHesapla(True);
   if TMenuItem(Sender).Tag = 0 then //özel
      YuzdeFloat := 100.0* StrToFloatDef(Tutar,0)/ SIPARIS.FieldByName('SIPARIS_MATRAHI').AsCurrency
   else
      YuzdeFloat := 100.0* StrToFloatDef(Tutar,0)/ SIPARIS.FieldByName('SIPARIS_TUTARI').AsCurrency;
  Yuzde := FExtToStr(YuzdeFloat);
  if (not Eksiskontoya)and(YuzdeFloat>100.0) then///eksi iskonto izni yoksa engel oluruz
    showmessage(BGEksiIskontoGirilemez)
  else begin
    Yuzde := StringReplace(Yuzde, ',', '.', []);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO=100.0-&Yuzde,ISKONTO2=0.0, TUTAR=&Yuzde*ADET*BIRIMFIYAT/100.0 where SIPARISID=&id ',['&Yuzde','&id'],[Yuzde, SIPARIS.Fields[0].AsInteger]);
  end;
  FaturaTutarHesapla(True);
  TabloYenile(SIPARISDETAY, [SIPARIS.Fields[0].AsInteger]);
end;

Procedure TSatinAlmaWizard2.SatinAlmainsert;
var
  etiketler,bilgiler:TArrayOfString;
  belgeno: TBelgeNo;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
begin
  case IslemOp of
    'E':begin
       belgeno := SiradakiBelgeNumarasi(19,Tablo.GENINI.BugunTrh);

       Tablo.RehberIletisimAD(RehberId,REHBERILETID,REHBERILETAD,REHBERILETADHINT);
       TabloYenile(Tablo.tabCariBilgileri, [RehberId,REHBERILETID]);
       Tablo.TablodanSorguAc(9,'select * from SATINALMA where ID='+inttoStr(SatinAlmaID));

       Tablo.TablodanSorguAc(1,'INSERT INTO [SIPARIS] ([TARIH],[TUR],[TIPI],[REHBERID],[SIPARISTARIH],[SIPARISSERI],'+
        ' [KOCANNO],[SIPARISNO],[GIRISDEPO],[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[SIPARIS_MATRAHI],[KDV_TUTARI],'+
        ' [SIPARIS_TUTARI],[KUR],[DOVIZ_TUTARI],[DOVIZ_CINSI],[YERI],[YERID],[REHBERILETID],[SUBEID])'+  //  ,DOVIZKUR
        ' Values('''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',19,1,'+IntToStr(RehberId)+','''+
        FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','''+belgeno.Serino+''','''+inttoStr(KocannoBul(19))+''','''+belgeno.BelgeNo+
        ''','+Tablo.Query9.FieldByName('DEPO').AsString+','''+Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString+''','''+Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+
        ''','''+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+''','''+Tablo.tabCariBilgileri.FieldByName('IL').AsString+
        ''','''+Tablo.tabCariBilgileri.FieldByName('VERGIDAI').AsString+''','''+Tablo.tabCariBilgileri.FieldByName('VERGINO').AsString+
        ''',''Hariç'',0,0,0,''TL'',0,''TL'','+IntToStr(TabNo_SATINALMA)+','+inttoStr(SatinAlmaID)+','+inttoStr(REHBERILETID)+','+inttoStr(SubeID)+') select scope_identity() ' );

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO [SIPARISDETAY]([SIPARISID],[REHBERID],[TUR],[URUNID],[ADET],[BIRIM],[MIKTAR]'+
      ' ,[BIRIMFIYAT],[TUTAR],[ISKONTO],[KDV],[KUR],[DOVIZ_TUTARI],[DOVIZ_KURU],[ISKONTO2],[DOVIZ_BIRIMFIYAT],[YERI],[YERID],[SUBEID],[PROJEID],[TESLIMTARIHI],[SATICIKODU]) '+
      ' Select '+Tablo.Query1.Fields[0].AsString+','+IntToStr(RehberId)+',1,STOKID,ADET,BIRIM,ADET,0,0,0,KDV,''TL'',0,''TL'', '+
      ' 0,0,'+IntToStr(TabNo_SATINALMA)+',SAD.ID,SAD.SUBEID,SAD.PROJEID,SAD.TESLIMTARIHI, '+Tablo.Query9.FieldByName('TALEPEDEN').AsString +
      ' from SATINALMADETAY SAD inner join STOKLAR S on SAD.STOKID=S.ID Where SAD.SATINALMAID = '+inttoStr(SatinAlmaID)+' ',[],[]);

     IslemOp := 'D';
     SiparisIdsi := Tablo.Query1.Fields[0].AsInteger;
     TabloYenile(SIPARIS, [SiparisIdsi]);
     TabloYenile(SIPARISDETAY,[SiparisIdsi]);
    end;
  end;
end;

procedure TSatinAlmaWizard2.SIPARISNewRecord(DataSet: TDataSet);
var
  seri, FatNo : string;
  belgeno : TBelgeNo;
  Etiketler,Bilgiler : TArrayOfString;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
begin
  Tablo.FaturaBaslik(SIPARIS,-1);
  SIPARIS.FieldByName('REHBERILETID').AsInteger :=0;
  SIPARIS.FieldByName('GIRISDEPO').AsInteger:= VarsDepo;
  SIPARIS.FieldByName('SATICIKODU').AsString:=Kullanan;
//  cbSatici.Text := Tablo.AciklamaGetir('REHBER','FIRMA', SIPARIS.FieldByName('SATICIKODU').AsString);

  SIPARIS.FieldByName('SIPARISTARIH').Value := Tablo.GENINI.BugunTrhSaat;
  belgeno:= SiradakiBelgeNumarasi(SiparisTur,SIPARIS.FieldByName('SIPARISTARIH').AsDateTime);
  SIPARIS.FieldByName('SIPARISSERI').AsString := belgeno.serino; //seri
  SIPARIS.FieldByName('SIPARISNO').AsString := belgeno.belgeno; //FatNo;
  SIPARIS.FieldByName('KOCANNO').AsInteger := KocannoBul(SiparisTur); //KOCAN numarası
  SIPARIS.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrh;
  SIPARIS.FieldByName('REHBERID').AsInteger := RehberId;
  SIPARIS.FieldByName('SUBEID').AsInteger := SubeID;
  SIPARIS.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  SIPARIS.FieldByName('SERVISID').AsInteger := ServisID;


  //varsayılan iskonto bilgilerine bakalım...
{  Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_FiyatListeAdi, RehVars_Stok_Vade, RehVars_GLN],etiketler,bilgiler);
  if bilgiler[0]='' then
      SIPARIS.FieldByName('FIYAT_LISTESI').AsInteger := VarsSatisFiyatID
  else
      SIPARIS.FieldByName('FIYAT_LISTESI').AsInteger := Tablo.GENINI.DegerGetir(Ops_FiyatListeAdi,Dil,bilgiler[0],VarsSatisFiyatID);
  if bilgiler[1]<>'' then
    SIPARIS.FieldByName('VADE').Value := bilgiler[1];


  if MasrafMerkezi>0 then
    SIPARIS.FieldByName('MASRAFID').AsInteger := MasrafMerkezi
  else begin
    if SiparisTur = 19 then begin //Çıkış
      Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_Gelir_Merkezi ],Etiketler,Bilgiler);
    end else begin
      Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_Masraf_Merkezi],Etiketler,Bilgiler);
    end;
    if Bilgiler[0]<>'' then begin
      Tablo.TablodanSorguAc(5,'select ID from MASRAFGELIR where KOD=substring('''+Bilgiler[0]+''',0,(charindex('' '','''+Bilgiler[0]+''',0)))');
      SIPARIS.FieldByName('MASRAFID').AsInteger := Tablo.Query5.Fields[0].AsInteger;
    end;
  end;}

  Tablo.tablodansorguac(1, 'select SINIF from REHBER where ID = '+ SIPARIS.FieldByName('SATICIKODU').AsString);
  SIPARIS.FieldByName('BOLUM').AsInteger := Tablo.Query1.Fields[0].AsInteger;
  EditDepartman.text := Tablo.DepartmanGorevGetir(1, SIPARIS.FieldByName('BOLUM').AsInteger);

  SIPARIS.FieldByName('TUR').AsInteger := SiparisTur;
  SIPARIS.FieldByName('TIPI').AsInteger := 1;
  SIPARIS.FieldByName('DURUM').AsInteger := 1;
  SIPARIS.FieldByName('PROJEID').AsInteger := ProjeId;
  SIPARIS.FieldByName('AKTIVITEID').AsInteger := AktiviteId;
  SIPARIS.FieldByName('ACIKLAMA').AsString := '';
  SIPARIS.FieldByName('EKLEYEN').AsString := Kullanan;
  SIPARIS.FieldByName('KDVDURUM').AsString := 'Hariç';
  SIPARIS.FieldByName('KUR').AsString := CariDoviz;
//  SIPARIS.FieldByName('DOVIZ_CINSI').AsString := CariDoviz;
  SIPARIS.FieldByName('DOVIZ_TUTARI').AsCurrency := 0;
  SIPARIS.FieldByName('DOVIZKUR').AsCurrency:= 1;
  //Departmanı bulalım
 { Tablo.TablodanSorguAc(1,' select isnull(R.GOREVID,0), isnull(R.DEPARTMAN,0) FROM KULLANICI K inner join ROLLER R on K.ROLID=R.ID where K.REHBERID='+Kullanan,);
  if Tablo.Query1.RecordCount>0 then
     SIPARIS.FieldByName('TUR').AsInteger := Tablo.Query1.Fields[1].AsInteger;
  }
end;


procedure TSatinAlmaWizard2.SiparisEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  Stop := BoslukKontrolu;
end;

procedure TSatinAlmaWizard2.SiparisEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TSatinAlmaWizard2.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TSatinAlmaWizard2.WizardKontrolFinishButtonClick(Sender: TObject);
var
  Kota,Bakiye:currency;
begin
  KaydetTus.Click;
  if SIPARISDETAY.IsEmpty then
     raise Exception.Create(UrungirilmedenKaydedilemez);
  //Birim Onaylayacak değişti ise onay için duyuru yayınlanır/değiştirilir/silinir
  if OncekiBirimOnaylayacak <> SIPARIS.FieldByName('BIRIMONAYLAYACAK').AsInteger then
     Tablo.OnayYayinIslemleri('SIPARIS', TabNo_Satinalma_Talep, SIPARIS.FieldByName('ID').AsInteger, OncekiBirimOnaylayacak, SIPARIS.FieldByName('BIRIMONAYLAYACAK').AsInteger, -24);
  //Onaylayacak değişti ise onay için duyuru yayınlanır/değiştirilir/silinir
  if OncekiOnaylayacak <> SIPARIS.FieldByName('ONAYLAYACAK').AsInteger then
     Tablo.OnayYayinIslemleri('SIPARIS',TabNo_SATINALMA, SIPARIS.FieldByName('ID').AsInteger, OncekiOnaylayacak, SIPARIS.FieldByName('ONAYLAYACAK').AsInteger, -26);

  //kilitli zamana kayıt olur mu
  if not KilitKontrolEt(1,SiparisTur,EditFatTarih.Date,2) then begin
     IptalSecildi := False;
     ModalResult := mrOk;
  end;
end;

function TSatinAlmaWizard2.BoslukKontrolu: Boolean;
var i:Integer;
    s:string[20];
begin
  BoslukKontrolu := True;
  if not BoslukKontrol(EditFatTarih.Text, Belge+' Tarih') then
    Abort;
  if not TarihKontrol(EditFatTarih.Date, Belge + KontrolTarihi) then
     Abort;
  if not BoslukKontrol(EditFatNo.Text, Belge+' No') then
    Abort;

  EditFatNo.Text := trim(EditFatNo.Text);


{  if (YearOf(SIPARIS.FieldByName('TARIH').AsDateTime) <> YearOf(SIPARIS.FieldByName('SIPARISTARIH').AsDateTime)) then begin
    Application.MessageBox(Pchar(FWKayitBelgeYilindanFarkliOlamaz),pchar(Uyari),MB_OK);
    Abort;
  end else if (DateOf(SIPARIS.FieldByName('TARIH').AsDateTime) > date) or
     (Dateof(SIPARIS.FieldByName('SIPARISTARIH').AsDateTime) > date) then begin
    Application.MessageBox(Pchar(FWKayitveBelgeTarihiIleriTarihOlamaz),pchar(Uyari),MB_OK);
    Abort;
  end; }

  BoslukKontrolu := False;
end;

procedure TSatinAlmaWizard2.BtnDonusturClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
begin
  if SIPARIS.State in [dsEdit, dsInsert] then
     SIPARIS.Post;

  if SIPARISDETAY.State in [dsEdit, dsInsert] then
     SIPARISDETAY.Post;

  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.HedefBaslikTur := SIPARIS.FieldByName('TUR').AsInteger;
  BDDlg.RehID := SIPARIS.FieldByName('REHBERID').AsInteger;
  BDDlg.HedefBaslikID := SIPARIS.FieldByName('ID').AsInteger;
  BDDlg.TabDetayGiris := SIPARISDETAY;
  BDDlg.ShowModal;
  FreeAndNil(BDDlg);
  SIPARIS.Edit;
  if not SIPARISDETAY.IsEmpty then
    cbDovizCinsiPropertiesCloseUp(Sender);
end;

procedure TSatinAlmaWizard2.BtnDovizKuruClick(Sender: TObject);
var
  Bilgi : Variant;
  Kur : String;
  ctrls : TGirdiDenetimleri;
begin
  //önce hangi döviz türleri kullanılmış ona bakalım
  Tablo.TablodanSorguAc(8,'select distinct DOVIZ_KURU from SIPARISDETAY where SIPARISID='+SIPARIS.FieldByName('ID').AsString+' and DOVIZ_KURU<>'''+CariDoviz+''' ');
  while not Tablo.Query8.Eof do begin
      Bilgi := DovizKuruBul(FormatDateTime('yyyy-mm-dd 00:00',SIPARIS.FieldByName('SIPARISTARIH').AsDateTime),SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString,Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,''));

      ctrls := TGirdiDenetimleri.Create.Edit(Tablo.Query8.Fields[0].AsString+BGKur_degeri,@Bilgi);
      if (TGirisKutusuEx.BilgiAlEx(FWKurGir, ctrls) = mrOk)and(trim(Bilgi) <> '') then begin
         Kur := VarToStr(Bilgi);
         Kur := StringReplace(Kur,'.', FormatSettings.DecimalSeparator,[rfReplaceAll]);
         Kur := StringReplace(Kur,',', FormatSettings.DecimalSeparator,[rfReplaceAll]);
         SIPARISDETAY.DisableControls;
         SIPARISDETAY.First;
         while not SIPARISDETAY.Eof do begin
            if SIPARISDETAY.FieldByName('DOVIZ_KURU').AsString=Tablo.Query8.Fields[0].AsString then begin
                SIPARISDETAY.Edit;
                SIPARISDETAY.FieldByName('DOVIZKURDEGERI').AsCurrency := StrToCurrDef(Kur,1);
                SIPARISDETAY.post;
            end;
            SIPARISDETAY.next;
         end;
         SIPARISDETAY.EnableControls;
      end;
      Tablo.Query8.next;
  end;
end;

procedure TSatinAlmaWizard2.btnFisIrsaliyeClick(Sender: TObject);
begin
   // fiş düzenlerken bu ekran kullanİlmaz
  KaydetTus.Click;
  if SIPARIS.FieldByName('TUR').AsInteger in [12 ,16] then
   begin
     Application.MessageBox(PChar(Yanlis_Ekran),PCHAR(Uyari) , MB_OK+ MB_ICONWARNING) ;
     Abort;
   end;
  if FisIrsaliyeAraDlg = nil then
    Application.CreateForm(TFisIrsaliyeAraDlg, FisIrsaliyeAraDlg);

  FisIrsFirmaId := SIPARIS.FieldByName('REHBERID').AsInteger;
  FisIrsTur := SIPARIS.FieldByName('TUR').AsInteger;
  SeciliFatID := SIPARIS.FieldByName('ID').AsInteger;
  SeciliFatIrsNo:= SIPARIS.FieldByName('IRSALIYENO').AsString;
//  FisIrsaliyeAraDlg.dateBitisPropertiesCloseUp(FisIrsaliyeAraDlg.dateBitis);

  FisIrsaliyeAraDlg.ShowModal;

  SIPARIS.Refresh;
  FaturaTutarHesapla(True);
  TabloYenile(SIPARISDETAY, [SIPARIS.FieldByName('ID').AsInteger]);

end;

procedure TSatinAlmaWizard2.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_SATINALMA, SIPARIS.FieldByName('ID').AsInteger, SIPARIS.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TSatinAlmaWizard2.btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  SQLText:String;
  st:TStringList;
begin
  sonbasilanctrl:=Sender as TcxButtonEdit;
  if Not (SIPARIS.State in [dsEdit,dsInsert]) then
    SIPARIS.Edit;
  if AButtonIndex = 0 then begin
  try
    st:=TStringList.Create;
    SQLText:='select ID,AD,'+
      ' ADRES=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=2 '+DbSinir(1)+'),'+
      ' ILCE=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=6 '+DbSinir(1)+'),'+
      ' IL=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=8 '+DbSinir(1)+'),'+
      ' ID_VERGIDAI=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=20 '+DbSinir(1)+'),'+
      ' ID_VERGINO=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=22 '+DbSinir(1)+')'+
      ' FROM REHBERILETISIM Firma where REHBERID='+IntToStr(RehberId)+' ';
    if Tablo.ListedenBilgiGetir('Adres Seçiniz.',SQLText,st,[],'',IletisimEkleClick,Tablo.FDCnn,IletisimEkleClick) then begin
        SIPARIS.FieldByName(sonbasilanctrl.TextHint).AsString:=st.Strings[0];
        sonbasilanctrl.Text:=st.Strings[1];
        sonbasilanctrl.Hint:=st.Strings[2];
      end;
    finally
      st.free;
    end;
  end else if AButtonIndex=1 then begin
        SIPARIS.FieldByName(sonbasilanctrl.TextHint).AsInteger := 0;
        sonbasilanctrl.Text := '';
  end;
end;


procedure TSatinAlmaWizard2.IletisimEkleClick(Sender: TObject);
var
  AD,ADRES,ILCE,IL :Variant;
  ctrls:TGirdiDenetimleri;
  Liste:TStrings;
begin
  liste:=nil;
  liste:=TStringList.Create;
  Tablo.TablodanSorguAc(1,'select ILADI from ILLER  where ILNO<100 order by 1 ');
  while not Tablo.Query1.Eof do begin
    Liste.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Next;
  end;
  IL:=Liste.Strings[0];
  ctrls:=TGirdiDenetimleri.Create.Edit('Ad',@AD).Memo('Adres',@ADRES).Edit('İlçe',@ILCE).ComboBox(('İl'),@IL,liste);
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls)<> mrOK  then
  Abort;
   //eklenen yeni iletişim ID sini alıyoruz.
  Tablo.TablodanSorguAc(1,'INSERT INTO REHBERILETISIM (REHBERID,AD,VARSAYILAN ,AKTIF,SUBEID) values('+IntToStr(RehberId)+','''+AD+''',0,1,'+inttostr(SubeID)+' )  Select SCOPE_IDENTITY() ');
  //Adres için
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'''+ADRES+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )  ',[],[]);

  //Alre için
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'''+ILCE+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )',[],[]);

  //İl için
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'''+IL+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )',[],[]);

  SIPARIS.FieldByName(sonbasilanctrl.TextHint).AsString:=Tablo.Query1.Fields[0].AsString;
  sonbasilanctrl.Text:=AD;
end;

procedure TSatinAlmaWizard2.cbDovizCinsiPropertiesCloseUp(Sender: TObject);
var KurDegeri : String[30];
begin
   if (SIPARIS.State in [dsEdit, dsInsert])and(SIPARIS.FieldByName('ID').AsString<>'')  then begin
       if cbDovizCinsi.EditValue = CariDoviz then
          KurDegeri := '1'
       else begin
          if (SIPARIS.FieldByName('DOVIZKUR').AsString='')or(SIPARIS.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz)or(SIPARIS.FieldByName('DOVIZKUR').AsString='1')then
              KurDegeri := Float_ToStr(DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', Tablo.GENINI.BugunTrh), cbDovizCinsi.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS')))
           else
              KurDegeri := Float_ToStr(SIPARIS.FieldByName('DOVIZKUR').AsFloat);
       end;
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set DOVIZ_KURU='''+cbDovizCinsi.EditValue+''',DOVIZKURDEGERI='+KurDegeri+','+
         ' DOVIZ_BIRIMFIYAT=BIRIMFIYAT / '+KurDegeri+', DOVIZ_TUTARI= (BIRIMFIYAT / '+KurDegeri+') * ADET *((100.0-ISKONTO)/100.0)*((100.0-ISKONTO2)/100.0)'+
         ' where SIPARISID='+SIPARIS.FieldByName('ID').AsString,[],[]);
       TabloYenile(SIPARISDETAY,[SIPARIS.FieldByName('ID').AsInteger]);
       SIPARIS.Post;
       FaturaTutarHesapla(True)
   end;
   editDovizKuru.Visible:= cbDovizCinsi.EditValue <> CariDoviz;
end;

procedure TSatinAlmaWizard2.cbSaticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,SIPARIS,'SATICIKODU');

  Tablo.tablodansorguac(1, 'select SINIF from REHBER where ID = '+ SIPARIS.FieldByName('SATICIKODU').AsString);
  SIPARIS.FieldByName('BOLUM').AsInteger := Tablo.Query1.Fields[0].AsInteger;
  EditDepartman.text := Tablo.DepartmanGorevGetir(1, SIPARIS.FieldByName('BOLUM').AsInteger);

end;

procedure TSatinAlmaWizard2.ComboBolumPropertiesEditValueChanged(Sender: TObject);
var i:Integer;
begin
  if (TabDetay.Active)  then begin
    if TabDetay.State=dsEdit then
      TabDetay.Post;
    i:=0;
    if not TabDetay.IsEmpty then begin
      TabDetay.First;
      while not TabDetay.Eof do begin
        if TabDetay.FieldByName('BILGI').AsString <>'' then
          Inc(i);
        TabDetay.Next;
      end;
    end;
    if (i>0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrNo) then begin
      SIPARIS.Cancel
    end else begin
      SIPARIS.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[DetaySablonTipiBul,SIPARIS.FieldByName('ID').AsInteger]);
      DetayEkrPage(Self);
    end;
  end;
end;

procedure TSatinAlmaWizard2.ComboBolumPropertiesInitPopup(Sender: TObject);
var
 sablontipi : integer;
begin
  sablontipi:= DetaySablonTipiBul;
  if ComboBolum.Properties.Items.Count=0 then
    ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE  YERI = '+IntToStr(sablontipi)).Items;

end;

procedure TSatinAlmaWizard2.cxEditRepository1ButtonItem1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var st : Tstringlist;
  site : TcxGridSite;
begin
  st := Tstringlist.Create;
  if Tablo.ListedenBilgiGetir('Seçiniz',tab.FieldByName('KAYNAK').AsString,st,[])then begin
    TcxButtonEdit(Sender).EditValue := st.Strings[0];
    TcxButtonEdit(Sender).PostEditValue;
  end;
end;

procedure TSatinAlmaWizard2.cxGridDBColumn4GetPropertiesForEdit( Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TSatinAlmaWizard2.FaturaTusClick(Sender: TObject);
begin
  if SIPARIS.State in [dsEdit, dsInsert] then
     SIPARIS.Post;
  WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;
end;

procedure TSatinAlmaWizard2.ButtonDuzenle;
begin
  FaturaTus.Enabled := FaturaTus.tag <> WizardKontrol.ActivePageIndex;
  DetayTus.Enabled := DetayTus.tag <> WizardKontrol.ActivePageIndex;
end;

procedure TSatinAlmaWizard2.SIPARISAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TOPLAMLAR,[SIPARIS.FieldByName('ID').AsInteger]);
end;

end.











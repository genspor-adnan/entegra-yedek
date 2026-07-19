unit UStokTalepWizard;

interface

uses
  Windows,   Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, cxGraphics, dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxCurrencyEdit,
  cxLabel, cxButtonEdit, cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin,Fetautil,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, jpeg, cxImage,FetaClassExtensions,
  UGentegreFrameYonetimi, cxTreeView, dxSkinLondonLiquidSky, UTablo, ULog,
  System.Generics.Collections, cxCheckBox,
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
  dxCoreGraphics, frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TStokTalepWizard = class(TForm, IPopupDialog)
    Panel1: TPanel;
    TalepTus: TcxButton;
    WizardKontrol: TJvWizard;
    SiparisEkr: TJvWizardInteriorPage;
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
    DokumanEkr: TJvWizardInteriorPage;
    DokumanTus: TcxButton;
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
    GridFaturaViewHUCRE: TcxGridDBColumn;
    GridFaturaViewACIKLAMA1: TcxGridDBColumn;
    GridFaturaViewADET1: TcxGridDBColumn;
    GridFaturaViewBIRIM1: TcxGridDBColumn;
    GridFaturaViewMASRAFKOD: TcxGridDBColumn;
    GridFaturaViewMASRAFAD: TcxGridDBColumn;
    GridFaturaViewIZLEME: TcxGridDBColumn;
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
    frxTOPLAMLAR: TfrxDBDataset;
    DtsHesapOzeti: TDataSource;
    TabHesapOzeti: TFDQuery;
    frxHesapOzeti: TfrxDBDataset;
    N4: TMenuItem;
    retimPlanndaGsterme1: TMenuItem;
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
    cbStokDepo: TcxDBImageComboBox;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cbCikDepo: TcxDBImageComboBox;
    N6: TMenuItem;
    Dei1: TMenuItem;
    MenuDegisTeslimTarihi: TMenuItem;
    cxLabel9: TcxLabel;
    LabelAnaKaynak: TcxLabel;
    EditDETAYBOLUMU: TcxDBTextEdit;
    cxLabel11: TcxLabel;
    procedure SIPARISBeforePost(DataSet: TDataSet);
    procedure SiparisEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure SIPARISNewRecord(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure SIPARISDETAYNewRecord(DataSet: TDataSet);
    procedure SIPARISDETAYBeforePost(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
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
    procedure SipariKoanAyarlar1Click(Sender: TObject);
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
    procedure MenuDegisTeslimTarihiClick(Sender: TObject);
    procedure DokumanEkrPage(Sender: TObject);
    procedure TalepTusClick(Sender: TObject);
    procedure DokumanTusClick(Sender: TObject);
    procedure SIPARISAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    AraDlg : TStokHizmetAraDlg;
    sonbasilanctrl :TcxButtonEdit;
    KuraGoreFiyatHesaplamaAlani:integer ; //faturaadetchange olay?nda kullan?l?yor bu de?i?ken
    FDetSnap: TObjectDictionary<Integer, TStringList>;  // SIPARISDETAY orijinal satirlar (log diff icin)
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
    FOturumID: string;       // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
    SiparisTur, SiparisIdsi, RehberId, ProjeId, AktiviteId,MasrafMerkezi,ServisID,SatinAlmaID: Integer;
    iadefis, IptalSecildi: Boolean;
    Cagiran: SmallInt;

  end;

var
  StokTalepWizard : TStokTalepWizard;
  DYetkisonuc:DokumanYetkiSonuc;

implementation

Uses  UVeriMotor, UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra, UFastRap, UOPSDLG,
  UParaDegisiklik, URaporAraclari, UGenelAnaSekmeFrame,UFisIrsaliyeAraDlg,UGirisKutusuEx, UGorevDlg, UIsListesi,
  UCariFonksiyonlar, UAnaForm, URehberAyar ,IdGlobalProtocols,LocOnFly;

{$R *.dfm}

var
   Belge, OncekiKDVDurumu : String[10];
   OncekiSubeID, TabloNo,   OncekiBirimOnaylayacak,   OncekiOnaylayacak :integer;
   Kilit, EkleDetay : Boolean;
   tab : TFDQuery;

function TStokTalepWizard.DetaySablonTipiBul:integer;
begin
   Result:= TabNo_SATINALMA;
end;
procedure TStokTalepWizard.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TStokTalepWizard.DkmanSil1Click(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: dokuman silme -> yakala
if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum, [TabloNo,siparis.FieldByName('ID').AsInteger]);
  end;
end;

procedure TStokTalepWizard.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum, [TabloNo, SIPARIS.FieldByName('ID').AsInteger]);
end;

procedure TStokTalepWizard.DokumanEkrPage(Sender: TObject);
begin
     ButtonDuzenle;
end;

procedure TStokTalepWizard.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
                      TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, SIPARIS.FieldByName('REHBERID').AsInteger)
end;

procedure TStokTalepWizard.DokumanTusClick(Sender: TObject);
begin
  if BoslukKontrolu = False then
     WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;;
end;

function TStokTalepWizard.EkranAdiAl: string;
begin
  Result := 'StokTalepDlg';
end;

procedure TStokTalepWizard.YazdirmayaHazirla(AFastReport: TfrxReport);
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
  //if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxSIPARIS) then
  //   AFastReport.EnabledDataSets.Add(frxSIPARIS)
  //else begin
    frxSIPARIS.DataSet := SIPARIS;
    AFastReport.EnabledDataSets.Add(frxSIPARIS);
    AFastReport.EnabledDataSets.Add(frxSIPARISDETAY);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
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
    Tablo.TabMusteriIlgili.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteriIlgili);

    PersonelID := IIF(SIPARIS.FieldByName('SATICIKODU').AsString='','-99',SIPARIS.FieldByName('SATICIKODU').AsString);
    Tablo.TabPersonel.Close;
    Tablo.TabPersonel.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1',PersonelID, [rfReplaceAll]);
    Tablo.TabPersonel.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxPersonel);

    if (DovizTakibi)and(SIPARIS.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz) then
       FatTutar := SIPARIS.FieldByName('DOVIZ_TUTARI').AsCurrency
    else
       FatTutar := SIPARIS.FieldByName('SIPARIS_TUTARI').AsCurrency;
    TabloYenile(TabHesapOzeti,[SIPARIS.FieldByName('REHBERID').AsInteger, SIPARIS.FieldByName('DOVIZ_CINSI').AsString, FatTutar]);
    AFastReport.EnabledDataSets.Add(frxHesapOzeti);

    AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
  //end;
end;

procedure TStokTalepWizard.YorumDzenle1Click(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya duzenleme -> yakala
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Siparisdetay);
end;

procedure TStokTalepWizard.BaskiOnizlemeMenuClick(Sender: TObject);
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

procedure TStokTalepWizard.BeditBagliGorevDblClick(Sender: TObject);
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

procedure TStokTalepWizard.BeditBagliGorevPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TStokTalepWizard.BeditProjeDblClick(Sender: TObject);
begin
  if BeditProje.Text <> '' then
     Tablo.ProjeSihirbazBaslat('D', SIPARIS.FieldByName('PROJEID').AsInteger, SIPARIS.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);
end;

procedure TStokTalepWizard.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
    Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_Siparisdetay);
end;

procedure TStokTalepWizard.GsterSeiliSatr1Click(Sender: TObject);
begin
  if (Sender as TMenuItem).Tag = 1 then  begin//se?iliyi g?ster
    if StrToIntDef(VarToStrDef(SIPARISDETAY.FieldByName('URETIMPLANDETAYID').Value,'0'),0) < 0 then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = null where ID='+SIPARISDETAY.FieldByName('ID').AsString,[],[])
    else
      ShowMessage('Bu satır gösterimde ya da kullanımda. ışlem gerçekleştirilemiyor.');
  end;
  if (Sender as TMenuItem).Tag = 2 then  begin  //t?m?n? g?ster
    if SipKontrol then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = null where SIPARISID='+SIPARIS.FieldByName('ID').AsString,[],[]);
  end;
  if (Sender as TMenuItem).Tag = 3 then  begin  //se?iliyi sakla
    if StrToIntDef(VarToStrDef(SIPARISDETAY.FieldByName('URETIMPLANDETAYID').Value,'0'),0) = 0 then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = -1 where ID='+SIPARISDETAY.FieldByName('ID').AsString,[],[])
    else
      ShowMessage('Bu satır saklı ya da kullanımda. ışlem gerçekleştirilemiyor.');
  end;
  if (Sender as TMenuItem).Tag = 4 then  begin  //t?m?n? sakla
    if SipKontrol then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = -1 where SIPARISID='+SIPARIS.FieldByName('ID').AsString,[],[]);
  end;
   TabloYenile(SIPARISDETAY, [SIPARIS.Fields[0].AsInteger]);
end;

function TStokTalepWizard.SipKontrol:boolean;
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

procedure TStokTalepWizard.BeditProjePropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje,SIPARIS,AButtonIndex,ProjeSecimi, SIPARIS.FieldByName('REHBERID').AsInteger);
  if SIPARIS.FieldByName('PROJEID').AsInteger > 0 then
    if Tablo.UyariGoster('Proje Seçimi','Seçmiş olduğunuz proje, belgenizin tüm satırlarına uygulansın mı?',2)=MrYes then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set PROJEID=&PrjID where SIPARISID=&FatbasID',['&PrjID','&FatbasID'],[SIPARIS.FieldByName('PROJEID').AsInteger,SIPARIS.FieldByName('ID').AsInteger]);
  TabloYenile(SIPARISDETAY, [SIPARIS.FieldByName('ID').AsInteger]);
end;


procedure TStokTalepWizard.BeditServisDblClick(Sender: TObject);
begin
  if (SIPARIS.FieldByName('SERVISID').Value <> null) and (SIPARIS.FieldByName('SERVISID').AsInteger>0) then
    Tablo.ServisSihirbazBaslat(False,'D',0,SIPARIS.FieldByName('SERVISID').AsInteger,SIPARIS.FieldByName('REHBERID').AsInteger);
end;

procedure TStokTalepWizard.BeditServisPropertiesButtonClick(Sender: TObject;
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

procedure TStokTalepWizard.DtsSIPARISStateChange(Sender: TObject);
begin
   KaydetTus.enabled := DtsSIPARIS.State in [dsEdit, dsInsert];
   IptalTus.enabled := KaydetTus.enabled;
end;

procedure TStokTalepWizard.EditBirimOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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
      // okundu i?aretleyelim ki panodaki listeden silinsin
      VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI='+s+' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Tabno)+' and YER_ID='+SIPARIS.FieldByName('ID').AsString+')',[],[]);
    end;
begin
   if TcxButtonEdit(Sender).Name='EditOnaylayan' then
      Islem('24010852','ONAYLAYACAK', 'ONAYLAYAN','ONAYTARIHI',EditOnaylayan, TabNo_SATINALMA)
   else
      Islem('24010850','BIRIMONAYLAYACAK', 'BIRIMONAYLAYAN','BIRIMONAYTARIHI',EditBirimOnaylayan, TabNo_Satinalma_Talep);
end;

procedure TStokTalepWizard.EditDepartmanPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var  ID : Integer;
begin
  ID := Tablo.RolAra_IDGetir;
  if ID<>-99 then begin
     SIPARIS.Edit;
     SIPARIS.FieldByName('BOLUM').AsInteger := ID;
     EditDepartman.text := Tablo.DepartmanGorevGetir(1, ID);
  end;
end;

procedure TStokTalepWizard.editDovizKuruPropertiesChange(Sender: TObject);
begin
  if SIPARIS.State in [dsEdit,dsInsert] then
    TabloYenile(TOPLAMLAR,[SIPARIS.FieldByName('ID').AsInteger]);
end;

procedure TStokTalepWizard.DtsSIPARISDETAYStateChange(Sender: TObject);
begin
   KaydetTus.enabled := DtsSIPARISDETAY.State in [dsEdit, dsInsert];
   IptalTus.enabled := KaydetTus.enabled;
end;

procedure TStokTalepWizard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
  if (IptalSecildi) and ((IslemOp = 'E') or (IslemOp='K')) then// e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
      if (SIPARIS.Active) and (SIPARIS.Fields[0].AsString <> '') then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_SIPARIS_DOKUMAN, SIPARIS.FieldByName('ID').AsInteger]);
          Tablo.SiparisSil(SIPARIS.FieldByName('ID').AsInteger);
      end;

  if (IptalSecildi=False) and ((IslemOp = 'E') or (IslemOp='K')) then begin
      GenRegIni.RegWriteString('StokTalepOpsiyon','TalepVarsayilanCikisDepo', SIPARIS.FieldByName('CIKISDEPO').AsString, 'C');
      GenRegIni.RegWriteString('StokTalepOpsiyon','TalepVarsayilanGirisDepo', SIPARIS.FieldByName('GIRISDEPO').AsString, 'C');
  end;

  if not ((IptalSecildi) and ((IslemOp = 'E') or (IslemOp='K'))) then
     // FALLBACK: yeni talep kaydedilip loglanmadan kapatildiysa EKLEME logu kacmasin (tek sefer).
     FEkleLogland := LogKartEkle(SIPARIS, TabNo_STOKTALEP, (IslemOp='E') or (IslemOp='K'), FEkleLogland) or FEkleLogland;

  // Geri-alinabilir oturum (D=degistir): iptal -> ilk hale don; kaydet -> snapshot temizle.
  if (IslemOp = 'D') and (FOturumID <> '') then
  begin
    if IptalSecildi then
    begin
      if SIPARISDETAY.State in [dsEdit, dsInsert] then SIPARISDETAY.Cancel;
      if SIPARIS.State in [dsEdit, dsInsert] then SIPARIS.Cancel;
      ULog.OturumGeriAl(FOturumID);
    end
    else
      ULog.OturumBitir(FOturumID);
    FOturumID := '';
  end;

  FreeAndNil(FDetSnap);
end;

procedure TStokTalepWizard.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var Ciksin : Boolean;
begin
   Ciksin := True;
   if (IptalSecildi)and((IslemOp='E')or (IslemOp='K')or( (IslemOp='D')and(KaydetTus.enabled or ULog.OturumYakalandiMi(FOturumID) or ((SIPARIS.State in [dsEdit,dsInsert]) and SIPARIS.Modified))))then
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : begin
                Ciksin := False;
                WizardKontrolFinishButtonClick(Self);
               end;
       IDCANCEL:Ciksin := False;
      end;

   if (IslemOp='D')and(SIPARISDETAY.RecordCount<1) then begin
            raise Exception.Create(UrungirilmedenKaydedilemez);
   end;

   CanClose := Ciksin;
end;

procedure TStokTalepWizard.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
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
  FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);

  TabloNo := TabNo_SIPARIS_Gelen;
  //cbDovizCinsi.Visible:=DovizTakibi;
  //lbDoviz.Visible:=DovizTakibi;
  //editDovizKuru.Visible:=DovizTakibi;

{  if not DovizTakibi then begin
    FreeAndNil(GridFaturaViewDOVIZKURDEGERI);
    FreeAndNil(GridFaturaViewDOVIZ_TUTARI);
    FreeAndNil(GridFaturaViewDOVIZ_BIRIMFIYAT);
    FreeAndNil(GridFaturaViewDOVIZ_KURU);
    FreeAndNil(tvFatToplamlarDOVIZTUTARI);
    FreeAndNil(tvFatToplamlarDOVIZ_KURU);
  end; }

  KuraGoreFiyatHesaplamaAlani:=1; //1 birimfiyat 2 d?vizbirimfiyat
  Tablo.GENINI.ReadImageSection(Ops_StokKart_Anabirim,(GridFaturaViewBIRIM1.Properties as TcxImageComboBoxProperties).Items);
end;

procedure TStokTalepWizard.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if VK_RETURN = Key then Key := 0;
end;

procedure TStokTalepWizard.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos :=Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bile?en Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TStokTalepWizard(Self),DtsSIPARIS);
    end;
  end
  else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bile?en D?zenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
      Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(PanelUst.Name),TStokTalepWizard(Self),DtsSIPARIS);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('S')) then  begin  //Bile?en Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      if ctrl.Name <> '' then begin
        Tablo.TablodanSorguAc(1,'Select CAPTION,ALANADI,TAG from ALANLAR Where TAG='+IntToStr(ctrl.Tag)+' and TUR <> 11 ');
        if Application.MessageBox(PChar(Tablo.Query1.FieldByName('CAPTION').AsString+' alanını silmek istiyor musunuz ?'),'UYARI',MB_YESNO)=mrYes then  begin

          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from ALANLAR Where TAG ='+IntToStr(ctrl.Tag)+' ',[],[]);
          try
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Alter table DEMIRBAS drop column '+Tablo.Query1.FieldByName('ALANADI').AsString+' ',[],[]);
          except
          end;
          ctrl.Visible := False;
          //Tablo.AlanOlustur(FindComponent(PanelAlt.Name),TStokTalepWizard(Self),-1,DtsSIPARIS);
          Tablo.AlanOlustur(TStokTalepWizard(Self),-1,DtsSIPARIS);
        end;
      end;
    end;
  end;

end;

procedure TStokTalepWizard.FormShow(Sender: TObject);
var
  ra: string;
  TN: TTreeNode;
  belgeno: TBelgeNo;
  aktifFrame : TGenelAnaSekmeFrame;
  kod: string;
  kullanan2: string;
  KurDegeri : currency;
begin
  StokTalepWizard.Height:= Screen.Height- round(Screen.Height*0.1);
  EkleDetay := False;
  Tablo.AlanOlustur(TStokTalepWizard(Self), -1,DtsSIPARIS);

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

  if IslemOp='K' then begin
    Tablo.TablodanSorguAc(3,'select * from SIPARISDETAY where SIPARISID=' + inttostr(SiparisIdsi));
    belgeno := SiradakiBelgeNumarasi(SiparisTur, SIPARIS.FieldByName('SIPARISTARIH').AsDateTime);
    SiparisIdsi := Tablo.SQLSatiriKopyala('SIPARIS', SiparisIdsi,['TARIH', 'SIPARISTARIH', 'EKLEYEN','SIPARISSERI', 'KOCANNO', 'SIPARISNO','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','ONAYLAYAN'],
          [Tablo.GENINI.BugunTrh, Tablo.GENINI.BugunTrhSaat, Kullanan,belgeno.SeriNo,KocannoBul(SiparisTur), belgeno.belgeno,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);
    while not Tablo.Query3.Eof do begin
      Tablo.SQLSatiriKopyala('SIPARISDETAY', Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', 'SIPARISID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI'],
          [Kullanan, SiparisIdsi,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
      Tablo.Query3.Next;
    end;
  end;

  LabelProje.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  LabelAktivite.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  BeditProje.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  BeditBagliGorev.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  FirmaBilgileri;
  TabloYenile(SIPARIS, [SiparisIdsi]);
  Kilit := False;
  if (IslemOp='D')and(KilitKontrolEt(2, SiparisTur,SIPARIS.FieldByName('SIPARISTARIH').AsDateTime,2)) then begin
     Kilit := True;
     SIPARIS.Close;
     SIPARIS.Open;
     ToolBar5.visible := False;
     PanelUst2.Enabled := False;
     PanelAlt2.Enabled := False;
  end;
  TabloYenile(SIPARISDETAY,[SiparisIdsi]);

  if cagiran = 5 then  begin    //SATINALMA dan geliyor
     SatinAlmainsert;
  end;

  if (IslemOp='E')and(SIPARISDETAY.RecordCount=0) then
     SIPARIS.Append;

{  if Cagiran=9 then  begin           //Tekliften Olu?turulan Sipari?lerde Toplamlar ve Doviz de?erleri hesaplan?yor.
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

  //FaturaTusClick(WizardKontrol.ActivePage);
  LogBelge.Clear;
  if SIPARISDETAY.active then begin
    SIPARISDETAY.First;
    while not SIPARISDETAY.Eof do begin
      if LogGun>0 then begin
        Tablo.BelgeLogBelirle(SIPARISDETAY);
      end;
      SIPARISDETAY.Next;
    end;
    if (SIPARISDETAY.RecordCount>0)and(Kilit=False) then begin
        SIPARISDETAY.Edit;
        SIPARISDETAY.Cancel;
    end;
  end;

  if SIPARIS.active then  begin
    //Sipari?e aktar?m yap?ld?ysa d?viz kurunun g?ncellenmesi gerekir..
    if (IslemOp = 'E')and(SIPARISDETAY.RecordCount>0) then begin
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
      if Tablo.Query9.RecordCount>0 then begin
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

  if not Tablo.YetkiVarmi(2431,1,False) then begin  //tutarlar g?z?kmesin denirse;
    GridFaturaView.OptionsView.Footer := False;
    GridFaturaView.OptionsView.GroupFooters := gfInvisible;
    //for I := 0 to GridFatListeTview.ColumnCount-1 do
      //GridFatListeTview.Columns[i].Summary.Destroy;
    Miktarskontosu1.Visible := False;
    Yzdeskontosu1.Visible := False;
    utarDvzHesapla1.Visible := False;
  end;

  if SIPARIS.FieldByName('BOLUM').AsString <> '' then
     EditDepartman.text := Tablo.DepartmanGorevGetir(1, SIPARIS.FieldByName('BOLUM').AsInteger);

  // Log diff icin: yalniz DUZENLEMEDE (D) orijinal detay satirlarini yakala.
  // E/K (yeni/kopya) icin snapshot bos kalir -> tum satirlar Finish'te EKLEME loglanir.
  if (LogGun>0) and (IslemOp='D') then
     LogSnapshotAl(SIPARISDETAY, FDetSnap);

  // Geri-alinabilir oturum (yalniz D=degistir): acilistaki hali SNAPSHOT'a al -> Cancel'da
  // ilk hale don. IMAJ/DOKUMAN kapsam disi.
  FOturumID := '';
  if IslemOp = 'D' then
    FOturumID := ULog.OturumBaslatPlan('SIPARIS', SiparisIdsi,   // LAZY: plan bellekte
      [ ULog.SnapTablo(1, 'SIPARIS',      'ID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(2, 'SIPARISDETAY', 'SIPARISID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(2, 'REHBERBILGI',  'YERI=' + IntToStr(DetaySablonTipiBul) + ' and YER_ID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(2, 'GOREVYORUM',   'TUR=' + IntToStr(TabloNo) + ' and GOREVID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(3, 'DOKUMAN', 'MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabloNo) + ' and GOREVID=' + IntToStr(SiparisIdsi) + ')'),
        ULog.SnapTablo(4, 'IMAJ',    'YERI=1 and YER_ID in (select ID from DOKUMAN where MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabloNo) + ' and GOREVID=' + IntToStr(SiparisIdsi) + '))') ]);

  if IslemOp='E' then
     SIPARIS.edit;
end;

procedure TStokTalepWizard.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TStokTalepWizard.GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry:TDataSet;
  ctrls: TGirdiDenetimleri;
  sql: Variant;
begin
  if ACellViewInfo.Item.Index=0 then begin //t?klanan etiket mi
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
  //ACellViewInfo.GridRecord.Index //sat?r index de?eri
  //ACellViewInfo.Item.Index //s?tun index de?eri
end;

procedure TStokTalepWizard.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TStokTalepWizard.GridFaturaViewACIKLAMA1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := SIPARISDETAY.fieldByName('ACIKLAMA').asstring;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Memo(BGAciklama_gir, @Bilgi)) <> mrOk then    //.Edit(FWToplamTutariGir, @Tutar
      Abort;
   SIPARISDETAY.edit;
   SIPARISDETAY.fieldByName('ACIKLAMA').AsString := VarToStr(Bilgi);
end;

procedure TStokTalepWizard.GridFaturaViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridFatura;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFaturaView;
  AnaForm.pmGridStil.Tags.Values[GridFatura.Name]:='FatSiparisDetayGridi';
end;

procedure TStokTalepWizard.GridFaturaViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if Kilit then exit;
  Tablo.SatirGuncelle(SIPARISDETAY, SiparisTur,1,SIPARIS.FieldByName('REHBERID').AsInteger, SIPARIS.FieldByName('SIPARISTARIH').AsDateTime, []);
end;

procedure TStokTalepWizard.GridFaturaViewEKIPMANIDPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TStokTalepWizard.GridFaturaViewMASRAFADGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
begin
 if ARecord.Values[GridFaturaViewMASRAFAD.Index]>0 then
    AText := Tablo.AciklamaGetir('MASRAFGELIR','AD',ARecord.Values[GridFaturaViewMASRAFAD.Index]);
end;

procedure TStokTalepWizard.GridFaturaViewMASRAFADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TStokTalepWizard.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TStokTalepWizard.LabelAdClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(0,SIPARIS.FieldByName('REHBERID').AsInteger,-100, -100, False);
end;

procedure TStokTalepWizard.LabelKodClick(Sender: TObject);
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

procedure TStokTalepWizard.MenuDegisTeslimTarihiClick(Sender: TObject);
var Tarih : Variant;
begin
   if SIPARISDETAY.RecordCount<1 then
      exit;
   Tarih := SIPARISDETAY.FieldByName('TESLIMTARIHI').AsDateTime;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.DateTimePicker(BGTeslim_Tarihi, @Tarih, dtkDate)) <> mrOk then
         Abort;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set TESLIMTARIHI='''+FormatDateTime('yyyy-mm-dd', StrToDateTime(VarToStr(Tarih)))+''' where SIPARISID=&id ',['&id'],[SIPARIS.Fields[0].AsInteger]);
   TabloYenile(SIPARISDETAY, [SIPARIS.Fields[0].AsInteger]);
end;

procedure TStokTalepWizard.MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if SiparisTur < 10 then
    raise Exception.Create(Aksiyon_sec);
end;

procedure TStokTalepWizard.MenuKlasordenEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: klasorden dosya ekleme -> yakala
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TStokTalepWizard.MenuMusTreeDblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TStokTalepWizard.MenuTarayacidanEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: tarayicidan dosya ekleme -> yakala
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TStokTalepWizard.N52Click(Sender: TObject);
var Yuzde : Variant;
    IskTipi,s : String;
begin
   IskTipi :=  TMenuItem(Sender).Hint;
   if TMenuItem(Sender).Tag < 0 then begin//?zel
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(FWYuzdesiniGirin, @Yuzde, 2)) <> mrOk then
         Abort;
      Yuzde := StringReplace(Yuzde, ',', '.', []);
   end else
      Yuzde := IntToStr(TMenuItem(Sender).Tag);
   s := Yuzde;
   if IskTipi='ıskonto1' then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO=&Yuzde, TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 '+
          ',DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0 where SIPARISID=&id ',['&Yuzde','&id'],[s, SIPARIS.Fields[0].AsInteger])
   else if IskTipi='ıskonto2' then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO2=&Yuzde, TUTAR=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 '+
          ', DOVIZ_TUTARI=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0 where SIPARISID=&id ',['&Yuzde','&id'],[s, SIPARIS.Fields[0].AsInteger]);
   FaturaTutarHesapla(True);
   TabloYenile(SIPARISDETAY, [SIPARIS.Fields[0].AsInteger]);
end;

procedure TStokTalepWizard.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TStokTalepWizard.PopupYorumuSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum silme -> yakala
   Tablo.GridYorumuSil(TabloNo, SIPARIS .FieldByName('ID').AsInteger, TabYorum);
end;

procedure TStokTalepWizard.SatirEkleClick(Sender: TObject);
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
  {if Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme) then begin
     if SIPARISDETAY.RecordCount<1 then
        AraDlg.cbStokDepo.Enabled := True //daha ?nce depo se?imi yap?lmam??, yap?labilir
     else            //girilmi? stok i?lemi var m??
        AraDlg.cbStokDepo.Enabled := not Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SIPARISDETAY where SIPARISID =  &FId and TUR=1', ['&FId'],[SIPARIS.FieldByName('ID').AsInteger]);
  end; }
  AraDlg.ShowModal;
end;

procedure TStokTalepWizard.SatirSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: satir silme -> yakala
  if SIPARISDETAY.RecordCount<=0 then abort;
  if Application.MessageBox(PCHAR(Sil_Onay),pchar(Onay), MB_YESNO + MB_ICONQUESTION) = ID_YES then begin
    SIPARISDETAY.Delete;
  end;
end;

procedure TStokTalepWizard.SipariKoanAyarlar1Click(Sender: TObject);
begin
  Tablo.KocanAyarlariniGetir(SIPARIS.FieldByName('TUR').AsInteger);
end;

procedure TStokTalepWizard.SIPARISAfterOpen(DataSet: TDataSet);
begin
    LabelAnaKaynak.caption := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',SIPARIS.FieldByName('ANAKAYITID').AsInteger);
end;

procedure TStokTalepWizard.SIPARISAfterPost(DataSet: TDataSet);
begin
   SiparisIdsi := SIPARIS.Fields[0].AsInteger;
   TabloYenile(TOPLAMLAR,[SiparisIdsi]);
end;

procedure TStokTalepWizard.SIPARISBeforeEdit(DataSet: TDataSet);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: stok talep ilk degisikligi -> yakala
   OncekiKDVDurumu := SIPARIS.FieldByName('KDVDURUM').AsString;
   OncekiSubeID :=SIPARIS.FieldByName('SUBEID').AsInteger;
   if LogGun>0 then begin
     Tablo.OncekiLogBelirle(SIPARIS);
   end;

end;

procedure TStokTalepWizard.SIPARISBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: stok talep post -> yakala
  BoslukKontrolu;
  //Bu cariden bu sipari? no ile daha ?nce sipari? al?nm?? m? kontrol? yapal?m
  //Tablo.TablodanSorguAc(2,'select ID from SIPARIS where ')
  if SIPARIS.FieldByName('GIRISDEPO').AsInteger = VarsDepo then begin
     ShowMessage('Giriş Deposu "Ana Depo" seçilemez!');
     Abort;
  end;

   if SIPARIS.FieldByName('CIKISDEPO').AsInteger<=0 then
   begin
       Application.MessageBox(PChar(FTWCikisDeposuBosOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
       cbCikDepo.SetFocus;
       Abort;
   end;
   if SIPARIS.FieldByName('GIRISDEPO').AsInteger<=0 then
   begin
       Application.MessageBox(PChar(FTWGirisDeposuBosOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
       cbStokDepo.SetFocus;
       Abort;
   end;

   if SIPARIS.FieldByName('GIRISDEPO').AsInteger = SIPARIS.FieldByName('CIKISDEPO').AsInteger then
   begin
     Application.MessageBox(PChar(FTWDepolarAyniOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
     Abort;
   end;

  if KilitKontrolEt(1, SiparisTur,EditFatTarih.Date, 1) then
     abort;

  if OncekiSubeID <> SIPARIS.FieldByName('SUBEID').AsInteger then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update SIPARISDETAY set SUBEID='+SIPARIS.FieldByName('SUBEID').AsString+' Where SIPARISID ='+IntToStr(SiparisIdsi)+' ',[],[]);
  EkleyenDegistiren(DtsSIPARIS);
end;

{procedure TStokTalepWizard.FaturaTutarHesapla;
Var SIPARIS_TUTARI, DOVIZ_TUTARI,SIPARIS_MATRAHI,KDV_TUTARI:Currency;
    s:string;
begin
  Tablo.Query1.Close;
  if cbKdvDurum.Text = 'Dahil' then // kdv hesaplarken round etmeden ayr? ayr? sat?rlar hesaplan?r topland?ktan sonra round edilir..
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

function TStokTalepWizard.ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
begin
  if TOPLAMLAR.Locate('TUR', Bolum,[loPartialKey]) then
    result := TOPLAMLAR.FieldByName(TLDoviz).AsExtended
  else
    result:=-99999;
end;

procedure TStokTalepWizard.FaturaTutarHesapla(TabloAc:Boolean);
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

//  if ComboFatTipi.EditValue=5 then //kur fark? ise
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

procedure TStokTalepWizard.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
end;

procedure TStokTalepWizard.SIPARISDETAYAfterDelete(DataSet: TDataSet);
begin
  FaturaTutarHesapla(True);
  SIPARISDETAY.Refresh;
end;

procedure TStokTalepWizard.SIPARISDETAYAfterPost(DataSet: TDataSet);
begin
   TabloYenile(SIPARISDETAY,[SIPARIS.FieldByName('ID').AsInteger]);
   TabloYenile(TOPLAMLAR,[SIPARIS.FieldByName('ID').AsInteger]);
   FaturaTutarHesapla(True);

end;

procedure TStokTalepWizard.SIPARISDETAYBeforeOpen(DataSet: TDataSet);
begin
   SIPARISDETAY.SQL.Text := StringReplace(SIPARISDETAY.SQL.Text,'@Dil',IntToStr(Dil),[rfReplaceAll]);
end;

procedure TStokTalepWizard.SIPARISDETAYBeforePost(DataSet: TDataSet);
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
  ULog.OturumYakala(FOturumID);   // LAZY: stok talep satiri post -> yakala
  if StrToIntDef(SIPARIS.FieldByName('ONAYLAYAN').AsString,0) <> 0 then begin
    if Tablo.UyariGoster(Uyari,'Yaptığınız değişiklik sipariş onayını kaldıracaktır, devam etmek ister misiniz?',2)=mrYes then
      EditBirimOnaylayanPropertiesButtonClick(Nil,1)
    else
      Abort;
  end;
//  SIPARISDETAY_Hesapla;
  // tur 1 olursa stok di?erleri i?in hizmet..
  if (SIPARISDETAY.FieldByName('ISKONTO').AsFloat=0)and(SIPARISDETAY.FieldByName('ISKONTO2').AsFloat<>0) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGSadeceIskonto2Girilemez);
     Abort;
  end;
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
    //bu b?l?m her durumda ?al??mal?..
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

procedure TStokTalepWizard.SIPARISDETAYCalcFields(DataSet: TDataSet);
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

procedure TStokTalepWizard.SIPARISDETAYNewRecord(DataSet: TDataSet);
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

procedure TStokTalepWizard.TalepTusClick(Sender: TObject);
begin
     WizardKontrol.ActivePageIndex := 0;
end;

procedure TStokTalepWizard.TamEkranTusClick(Sender: TObject);
begin
  PanelUst.Visible := not PanelUst.Visible;
  PanelAlt.Visible := PanelUst.Visible;
  if PanelUst.Visible then
    TamEkranTus.Caption := 'Tam Ekran'
  else
    TamEkranTus.Caption := 'Küçük Ekran'
end;

procedure TStokTalepWizard.TutarDvzHesapla1Click(Sender: TObject);
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
{    SIPARISDETAY.FieldByName('TUTAR').Value :=((100-GridFaturaViewISKONTO1.EditValue)/100)*
                                      ((100-GridFaturaViewISKONTO2.EditValue)/100)*
                                      GridFaturaViewADET1.EditValue*
                                      GridFaturaViewBIRIMFIYAT1.EditValue; }
    SIPARISDETAY.Post;
  end;
end;

procedure TStokTalepWizard.KaydetTusClick(Sender: TObject);
begin
  if SIPARIS.State in [dsInsert, dsEdit] then begin
     // Yeni/kopya kayit her zaman Post; duzenlemede yalniz gercek degisiklik varsa.
     if (SIPARIS.State = dsInsert) or (IslemOp='E') or (IslemOp='K') or SIPARIS.Modified then
        SIPARIS.Post
     else
        SIPARIS.Cancel;
  end;
  if SIPARISDETAY.State in [dsInsert, dsEdit] then
     SIPARISDETAY.Post;
  // NOT: eski etkisiz LogIslemleri/LogIslemlerBelge(SIPARISDETAY,...) kaldirildi.
  // Loglama artik terminal noktada (WizardKontrolFinishButtonClick) yapiliyor:
  // kart -> LogKayitEkle/LogIslemleri, detay -> LogDiffKaydet(SIPARISDETAY, FDetSnap).
end;

procedure TStokTalepWizard.KDVHaricTutargir1Click(Sender: TObject);
var Tutar,Kur : Variant;
    Yuzde : String;
    YuzdeFloat:extended;
begin
  Kur := CariDoviz;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.create
        .CurrencyEdit(FWToplamTutariGir, @Tutar,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))
        .ComboBox(FWKurGir,@Kur,Tablo.cxEditRepository1ComboBoxItemKurlar.Properties.Items)) <> mrOk then
      Abort;
  if Kur <> CariDoviz then begin //farkl? kura g?re miktar iskontosu i?in;
    if SIPARIS.FieldByName('DOVIZ_CINSI').AsString=Kur then begin
      try
        Tutar := Tutar*SIPARIS.FieldByName('DOVIZKUR').AsCurrency;
      except
        Tablo.TablodanSorguAc(0,'select '+DbUst(1) + Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)') + ' FROM DOVIZ WHERE CINSI='''+Kur+'''  ORDER BY ABS('+DbTarihFark('HOUR', ''''+FormatDateTime('yyyy-mm-dd 00:00', SIPARIS.FieldByName('SIPARISTARIH').AsDateTime)+'''', 'TARIH')+') '+DbSinir(1));
        Tutar := Tutar*Tablo.Query0.FieldByName(Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)')).AsCurrency;
      end;
    end else begin
      Tablo.TablodanSorguAc(0,'select '+DbUst(1) + Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)') + ' FROM DOVIZ WHERE CINSI='''+Kur+'''  ORDER BY ABS('+DbTarihFark('HOUR', ''''+FormatDateTime('yyyy-mm-dd 00:00', SIPARIS.FieldByName('SIPARISTARIH').AsDateTime)+'''', 'TARIH')+') '+DbSinir(1));
      Tutar := Tutar*Tablo.Query0.FieldByName(Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'((ALIS+SATIS)/2)')).AsCurrency;
    end;
  end;

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO=0.0, ISKONTO2=0.0, TUTAR=ADET*BIRIMFIYAT where SIPARISID=&id ',['&id'],[SIPARIS.Fields[0].AsInteger]);
   FaturaTutarHesapla(True);
   if TMenuItem(Sender).Tag = 0 then //?zel
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

Procedure TStokTalepWizard.SatinAlmainsert;
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

procedure TStokTalepWizard.SIPARISNewRecord(DataSet: TDataSet);
var
  seri, FatNo : string;
  belgeno : TBelgeNo;
  Etiketler,Bilgiler : TArrayOfString;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
begin
  Tablo.FaturaBaslik(SIPARIS,-1);
  SIPARIS.FieldByName('REHBERILETID').AsInteger :=0;
  //SIPARIS.FieldByName('GIRISDEPO').AsInteger:= VarsDepo;
  SIPARIS.FieldByName('CIKISDEPO').AsInteger:= VarsDepo;
  SIPARIS.FieldByName('SATICIKODU').AsString:=Kullanan;
//  cbSatici.Text := Tablo.AciklamaGetir('REHBER','FIRMA', SIPARIS.FieldByName('SATICIKODU').AsString);

  SIPARIS.FieldByName('SIPARISTARIH').Value := Tablo.GENINI.BugunTrhSaat;
  belgeno:= SiradakiBelgeNumarasi(105,SIPARIS.FieldByName('SIPARISTARIH').AsDateTime);
  SIPARIS.FieldByName('SIPARISSERI').AsString := belgeno.serino; //seri
  SIPARIS.FieldByName('SIPARISNO').AsString := belgeno.belgeno; //FatNo;
  SIPARIS.FieldByName('KOCANNO').AsInteger := KocannoBul(SiparisTur); //KOCAN numaras?
  SIPARIS.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrh;
  SIPARIS.FieldByName('REHBERID').AsInteger := RehberId;
  SIPARIS.FieldByName('SUBEID').AsInteger := SubeID;
  SIPARIS.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  SIPARIS.FieldByName('SERVISID').AsInteger := ServisID;

  SIPARIS.FieldByName('CIKISDEPO').AsInteger := StrToIntDef(GenRegIni.RegReadString('StokTalepOpsiyon','TalepVarsayilanCikisDepo', '1', 'C'),1);
  SIPARIS.FieldByName('GIRISDEPO').AsInteger := StrToIntDef(GenRegIni.RegReadString('StokTalepOpsiyon','TalepVarsayilanGirisDepo', '1', 'C'),1);

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
  //Departman? bulal?m
 { Tablo.TablodanSorguAc(1,' select isnull(R.GOREVID,0), isnull(R.DEPARTMAN,0) FROM KULLANICI K inner join ROLLER R on K.ROLID=R.ID where K.REHBERID='+Kullanan,);
  if Tablo.Query1.RecordCount>0 then
     SIPARIS.FieldByName('TUR').AsInteger := Tablo.Query1.Fields[1].AsInteger;
  }


end;
procedure TStokTalepWizard.SiparisEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  Stop := BoslukKontrolu;
end;

procedure TStokTalepWizard.SiparisEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TStokTalepWizard.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   // Iptal onayi FormCloseQuery'de (KaydetmeSorusu / Gentegre Onay) soruluyor -> burada
   // TEKRAR sorMA (cift onay kaldirildi). Close -> FormCloseQuery -> KaydetmeSorusu.
   Close;
end;

procedure TStokTalepWizard.WizardKontrolFinishButtonClick(Sender: TObject);
var
  Kota,Bakiye:currency;
begin
  // Alt hareketler (SIPARISDETAY diff) ana kartin moduna gore -> tek ISLEMTIPI (UInfo tek satir).
  if (IslemOp='E') or (IslemOp='K') then LogUstModu := 1 else LogUstModu := 2;
  KaydetTus.Click;
  if SIPARISDETAY.RecordCount < 1 then
     raise Exception.Create(UrungirilmedenKaydedilemez);

  // --- ISLEMLOG: kart (baslik) + detay satir diff (fatura/siparis wizard deseni) ---
  // SIPARISDETAY.Post ve SiparisIdsi (SIPARISAfterPost) bu noktada hazir.
  if LogGun > 0 then
  try
    if (IslemOp='E') or (IslemOp='K') then
       FEkleLogland := LogKartEkle(SIPARIS, TabNo_STOKTALEP, True, FEkleLogland) or FEkleLogland
    else
       LogKartDegisti(SIPARIS, TabNo_STOKTALEP, SiparisIdsi);
    LogDiffKaydet(SIPARISDETAY, FDetSnap, TabNo_SIPARISDETAY, TabNo_STOKTALEP, SiparisIdsi);
    LogSnapshotAl(SIPARISDETAY, FDetSnap);   // mukerrer save'i onlemek icin snapshot'i tazele
  except
  end;

  //Birim Onaylayacak de?i?ti ise onay i?in duyuru yay?nlan?r/de?i?tirilir/silinir
  if OncekiBirimOnaylayacak <> SIPARIS.FieldByName('BIRIMONAYLAYACAK').AsInteger then
     Tablo.OnayYayinIslemleri('SIPARIS', TabNo_Satinalma_Talep, SIPARIS.FieldByName('ID').AsInteger, OncekiBirimOnaylayacak, SIPARIS.FieldByName('BIRIMONAYLAYACAK').AsInteger, -24);
  //Onaylayacak de?i?ti ise onay i?in duyuru yay?nlan?r/de?i?tirilir/silinir
  if OncekiOnaylayacak <> SIPARIS.FieldByName('ONAYLAYACAK').AsInteger then
     Tablo.OnayYayinIslemleri('SIPARIS',TabNo_SATINALMA, SIPARIS.FieldByName('ID').AsInteger, OncekiOnaylayacak, SIPARIS.FieldByName('ONAYLAYACAK').AsInteger, -26);
   IptalSecildi := False;
   ModalResult := mrOk;
  //kilitli zamana kay?t olur mu
 // if not KilitKontrolEt(1,SiparisTur,EditFatTarih.Date,2) then begin
 //    IptalSecildi := False;
 //    ModalResult := mrOk;
 // end;
end;

function TStokTalepWizard.BoslukKontrolu: Boolean;
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
  if not BoslukKontrol(cbStokDepo.Text, FTWGirisDeposuBosOlamaz) then
    Abort;
  if not BoslukKontrol(cbCikDepo.Text, FTWCikisDeposuBosOlamaz) then
    Abort;

  EditFatNo.Text := trim(EditFatNo.Text);

  Tablo.Query3.SQL.Text := 'select 1 from SIPARIS where REHBERID='+SIPARIS.FieldByName('REHBERID').AsString
                            +' and TUR='+SIPARIS.FieldByName('TUR').AsString
                            +' and SIPARISNO='''+SIPARIS.FieldByName('SIPARISNO').AsString+''' ';
  if SIPARIS.FieldByName('ID').AsString<>'' then
     Tablo.Query3.SQL.Add( ' and ID <> '+SIPARIS.FieldByName('ID').AsString);
   Tablo.Query3.open;
   if Tablo.Query3.RecordCount>1 then begin
      showmessage(TSeriNumaraDahaOnce);
      Abort;
   end;


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

procedure TStokTalepWizard.BtnDovizKuruClick(Sender: TObject);
var
  Bilgi : Variant;
  Kur : String;
  ctrls : TGirdiDenetimleri;
begin
  //?nce hangi d?viz t?rleri kullan?lm?? ona bakal?m
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

procedure TStokTalepWizard.btnFisIrsaliyeClick(Sender: TObject);
begin
   // fi? d?zenlerken bu ekran kullan?lmaz
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

procedure TStokTalepWizard.BtnMesajGonderClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya mesaj/dosya ekleme -> yakala
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabloNo, SIPARIS.FieldByName('ID').AsInteger, SIPARIS.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TStokTalepWizard.btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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


procedure TStokTalepWizard.IletisimEkleClick(Sender: TObject);
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
  ctrls:=TGirdiDenetimleri.Create.Edit('Ad',@AD).Memo('Adres',@ADRES).Edit('ılçe',@ILCE).ComboBox(('ıl'),@IL,liste);
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls)<> mrOK  then
  Abort;
   //eklenen yeni ileti?im ID sini al?yoruz.
  Tablo.TablodanSorguAc(1,'INSERT INTO REHBERILETISIM (REHBERID,AD,VARSAYILAN ,AKTIF,SUBEID) values('+IntToStr(RehberId)+','''+AD+''',0,1,'+inttostr(SubeID)+' )  Select SCOPE_IDENTITY() ');
  //Adres i?in
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'''+ADRES+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )  ',[],[]);

  //?l?e i?in
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'''+ILCE+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )',[],[]);

  //?l i?in
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'''+IL+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )',[],[]);

  SIPARIS.FieldByName(sonbasilanctrl.TextHint).AsString:=Tablo.Query1.Fields[0].AsString;
  sonbasilanctrl.Text:=AD;
end;

procedure TStokTalepWizard.cbDovizCinsiPropertiesCloseUp(Sender: TObject);
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

procedure TStokTalepWizard.cbSaticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,SIPARIS,'SATICIKODU');

  Tablo.tablodansorguac(1, 'select SINIF from REHBER where ID = '+ SIPARIS.FieldByName('SATICIKODU').AsString);
  SIPARIS.FieldByName('BOLUM').AsInteger := Tablo.Query1.Fields[0].AsInteger;
  EditDepartman.text := Tablo.DepartmanGorevGetir(1, SIPARIS.FieldByName('BOLUM').AsInteger);

end;

procedure TStokTalepWizard.cxEditRepository1ButtonItem1PropertiesButtonClick(
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

procedure TStokTalepWizard.cxGridDBColumn4GetPropertiesForEdit( Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TStokTalepWizard.ButtonDuzenle;
begin

  talepTus.Enabled := talepTus.tag <> WizardKontrol.ActivePageIndex;
  DokumanTus.Enabled := DokumanTus.tag <> WizardKontrol.ActivePageIndex;
end;

procedure TStokTalepWizard.SIPARISAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TOPLAMLAR,[SIPARIS.FieldByName('ID').AsInteger]);
end;

end.









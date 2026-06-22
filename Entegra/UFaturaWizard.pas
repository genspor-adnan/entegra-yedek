unit UFaturaWizard;
{E-Fat kontrolü
1- ilk fat oluşturma  IslOp=E
2- Fat gör/değiş      IslOp=D
3-Firma değişimi      IslOp=E veya IslOp=D
4-İrsaliyeden dönüşüm
5-Fat. kopyalama     IslOp=K
}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, cxGraphics, UStokHizmetAra,
  cxStyles, Fetautil, dxSkinLiquidSky, cxCheckBox, 
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxGridCustomPopupMenu,
  cxLabel, cxButtonEdit, cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, DateUtils,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons, UBelgeDonusum,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, jpeg, cxImage, cxCurrencyEdit,
  FetaClassExtensions, UBekletme, UBelgeZarflari, cxShellEditRepositoryItems,
  UGentegreFrameYonetimi, cxTreeView, dxSkinLondonLiquidSky, UTablo, JvDragDrop,
  cxExtEditRepositoryItems, cxEditRepositoryItems, JvComponentBase, cxGridPopupMenu,
  cxDBEditRepository, cxDBExtLookupComboBox, dxSkinsDefaultPainters, cxGridCardView,
  cxHyperLinkEdit, cxGridDBCardView, cxLookAndFeels, cxNavigator, UStokLokasyon,
  cxGridCustomLayoutView,UKodAgaci, UIskontoDetay, cxGroupBox, UIzleme,
  dxSkinscxPCPainter, dxBarBuiltInMenu, (*Bde.DBTables,*) OfficePopupMenu, cxPC,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, frCoreClasses, Math, FireDAC.Comp.Client, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TFaturaWizardDlg = class(TForm, IPopupDialog)
    PanelSol: TPanel;
    FaturaTus: TcxButton;
    DetayTus: TcxButton;
    PlanlaTus: TcxButton;
    WizardKontrol: TJvWizard;
    FaturaEkr: TJvWizardInteriorPage;
    DetayEkr: TJvWizardInteriorPage;
    PlanlamaEkr: TJvWizardInteriorPage;
    ToolBar4: TToolBar;
    BtnSilPlan: TToolButton;
    cxImageComboBox1: TcxImageComboBox;
    dsAra: TDataSource;
    OpenDialog1: TOpenDialog;
    PopupMenuFatura: TPopupMenu;
    N16: TMenuItem;
    FaturaKoanAyarlar1: TMenuItem;
    DtsFatura: TDataSource;
    DtsFatBaslik: TDataSource;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YaziciyaYazdirMenu: TMenuItem;
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
    TabFatura: TFDQuery;
    TabFatbaslik: TFDQuery;
    frxFATURA: TfrxDBDataset;
    frxFATBASLIK: TfrxDBDataset;
    Panel3: TPanel;
    PanelAlt: TPanel;
    GridFaturaToplam: TStringGrid;
    GridFatura: TcxGrid;
    GridFaturaView: TcxGridDBTableView;
    GridFaturaViewKOD1: TcxGridDBColumn;
    GridFaturaViewACIKLAMA1: TcxGridDBColumn;
    GridFaturaViewADET1: TcxGridDBColumn;
    GridFaturaViewBIRIM1: TcxGridDBColumn;
    GridFaturaViewBIRIMFIYAT1: TcxGridDBColumn;
    GridFaturaViewISKONTO1: TcxGridDBColumn;
    GridFaturaViewKDV1: TcxGridDBColumn;
    GridFaturaViewTUTAR1: TcxGridDBColumn;
    GridFaturaLevel1: TcxGridLevel;
    ToolBarAlet: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    ToolButton1: TToolButton;
    ToolButton9: TToolButton;
    ToolButton13: TToolButton;
    ToolButton10: TToolButton;
    TamEkranTus: TToolButton;
    GridFaturaViewTUR: TcxGridDBColumn;
    btnDonustur: TToolButton;
    ToolButton4: TToolButton;
    DETAY: TFDQuery;
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
    GridFaturaViewAD: TcxGridDBColumn;
    JvDragDrop1: TJvDragDrop;
    GridFaturaViewISKONTO2: TcxGridDBColumn;
    GridFaturaViewKUR: TcxGridDBColumn;
    GridFaturaViewDOVIZ_TUTARI: TcxGridDBColumn;
    GridFaturaViewDOVIZ_KURU: TcxGridDBColumn;
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
    ColumnIskTutari: TcxGridDBColumn;
    N5: TMenuItem;
    LabelKod: TcxLabel;
    BtnYeniPlan: TToolButton;
    TabPlan: TFDQuery;
    DtsPlan: TDataSource;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1TUR: TcxGridDBColumn;
    cxGrid1DBTableView1PLANTARIHI: TcxGridDBColumn;
    cxGrid1DBTableView1ISLEMTARIHI: TcxGridDBColumn;
    cxGrid1DBTableView1BORC: TcxGridDBColumn;
    cxGrid1DBTableView1ALACAK: TcxGridDBColumn;
    cxGrid1DBTableView1KUR: TcxGridDBColumn;
    cxGrid1DBTableView1MASRAFID: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    GridFaturaViewMF: TcxGridDBColumn;
    ComboBolum: TcxDBComboBox;
    lbDetaySablon: TcxLabel;
    SQLDetay: TcxMemo;
    DokumanTus: TcxButton;
    DokumanEkr: TJvWizardInteriorPage;
    //BelgeDuzenleTus: TToolButton;
    DtsImaj: TDataSource;
    TabImaj: TFDQuery;
    GridFaturaViewIADEDURUM: TcxGridDBColumn;
    gridFatToplam: TcxGrid;
    tvFatToplamlar: TcxGridDBTableView;
    tvFatToplamlarColumn1: TcxGridDBColumn;
    tvFatToplamlarColumn2: TcxGridDBColumn;
    tvFatToplamlarColumn3: TcxGridDBColumn;
    gridFatToplamLevel1: TcxGridLevel;
    TOPLAMLAR: TFDQuery;
    dtsTOPLAMLAR: TDataSource;
    frxTOPLAMLAR: TfrxDBDataset;
    GridFaturaViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn;
    tvFatToplamlarColumn5: TcxGridDBColumn;
    tvFatToplamlarColumn6: TcxGridDBColumn;
    GridFaturaViewDOVIZKURDEGERI: TcxGridDBColumn;
    MalFazlasDzenle1: TMenuItem;
    GridFaturaViewOZELKOD: TcxGridDBColumn;
    GridFaturaViewPROJEKODU: TcxGridDBColumn;
    frxDETAY: TfrxDBDataset;
    GridFaturaViewVADE: TcxGridDBColumn;
    GridFaturaViewKAMPANYAADI: TcxGridDBColumn;
    KampanyaDzenle1: TMenuItem;
    Timer1: TTimer;
    SatirDuzenleMenu: TMenuItem;
    Label6: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    GridFaturaViewID: TcxGridDBColumn;
    GridFaturaViewKDVMUHAFIYETI: TcxGridDBColumn;
    BtnBagliFatura: TToolButton;
    PopupBagliBelgeler: TPopupMenu;
    BelgeEkle1: TMenuItem;
    BelgeKaldr1: TMenuItem;
    Hesapla1: TMenuItem;
    GridFaturaViewEKMALIYET: TcxGridDBColumn;
    GridFaturaViewSTOKDURUMDEGIS: TcxGridDBColumn;
    Cariskonto1: TMenuItem;
    Stokskontosu1: TMenuItem;
    cxGrid1DBTableView1ID: TcxGridDBColumn;
    BtnBelgeZarfi: TToolButton;
    PopupBelgeZarfi: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    TabKaynaklar: TFDQuery;
    DtsKaynaklar: TDataSource;
    frxKaynaklar: TfrxDBDataset;
    IzlemBilgileriniDzenleMenu: TMenuItem;
    TabHesapOzeti: TFDQuery;
    DtsHesapOzeti: TDataSource;
    frxHesapOzeti: TfrxDBDataset;
    tabIzleme: TFDQuery;
    tsIzleme: TDataSource;
    frxIzleme: TfrxDBDataset;
    LabelAd: TcxLabel;
    GridFaturaViewMERKEZID: TcxGridDBColumn;
    GridFaturaViewIZLEME: TcxGridDBColumn;
    zel2: TMenuItem;
    zel4: TMenuItem;
    MemoFIFO: TMemo;
    BtnDoviz: TToolButton;
    GridFaturaViewISKONTOLUBRMFIYAT: TcxGridDBColumn;
    GridFaturaViewKDVDAHILFIYAT: TcxGridDBColumn;
    LabelSorgu: TcxLabel;
    GrpBoxEFatura: TcxGroupBox;
    ComboEFATURADURUM: TcxDBImageComboBox;
    ComboEFATURASONUC: TcxDBImageComboBox;
    GridFaturaViewDEPO: TcxGridDBColumn;
    GridFaturaViewMALIYET: TcxGridDBColumn;
    N4: TMenuItem;
    GridFaturaViewOTVMIKTAR: TcxGridDBColumn;
    GridFaturaViewKDVTUTAR: TcxGridDBColumn;
    GridFaturaViewMIKTAR: TcxGridDBColumn;
    GridFaturaViewBIRIM2MIKTAR: TcxGridDBColumn;
    GridFaturaViewBIRIM2AD: TcxGridDBColumn;
    GridFaturaViewSATICIKODU: TcxGridDBColumn;
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
    MenuItem4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    PageUst: TcxPageControl;
    SheetFatBaslik: TcxTabSheet;
    PanelUst: TPanel;
    LabelSRMMerkezi: TcxLabel;
    cbFaturaTur: TcxDBImageComboBox;
    BaslikPaneli: TPanel;
    Label22: TcxLabel;
    Label24: TcxLabel;
    Label2: TcxLabel;
    Label25: TcxLabel;
    Label3: TcxLabel;
    Label26: TcxLabel;
    EditBASLIK: TcxDBTextEdit;
    MemoFatAdres: TcxDBMemo;
    EditILCE: TcxDBTextEdit;
    EditVD: TcxDBTextEdit;
    EditVNo: TcxDBTextEdit;
    EditIL: TcxDBComboBox;
    EditButtonSevkAdresi: TcxButtonEdit;
    lblSevkAdresi: TcxLabel;
    EditSRMMerkezi: TcxButtonEdit;
    LabelFIYAT_LISTESI: TcxLabel;
    ComboFIYAT_LISTESI: TcxDBImageComboBox;
    LabelVade: TcxLabel;
    lbBelgeTuru: TcxLabel;
    lbDepo: TcxLabel;
    EditVade: TcxDBCurrencyEdit;
    cxLabel6: TcxLabel;
    LabelFATURA_GON_TARIHI: TcxLabel;
    cxLabel9: TcxLabel;
    EditOZELKOD: TcxDBTextEdit;
    ComboSENARYO: TcxDBImageComboBox;
    LabelSenaryo: TcxLabel;
    cbStokDepo2: TcxDBImageComboBox;
    LabelKonsinyeDepo: TcxLabel;
    cbStokDepo: TcxDBImageComboBox;
    ComboFatTipi: TcxDBImageComboBox;
    cbSatici: TcxButtonEdit;
    lbSatici: TcxLabel;
    SheetEkAlanlar: TcxTabSheet;
    PanelEkAlanlar: TPanel;
    ToolBar3: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton8: TToolButton;
    YaziciYaz: TToolButton;
    BtnEfatura: TToolButton;
    MemoBirlestir: TMemo;
    N6: TMenuItem;
    AyniUrunKodluSatrlarBirlestirMenu: TMenuItem;
    TabRecete: TFDQuery;
    DtsRecete: TDataSource;
    frxRecete: TfrxDBDataset;
    //Table1: TTable;
    TabStokDetay: TFDQuery;
    frxStokDetay: TfrxDBDataset;
    GridFaturaViewSERINO: TcxGridDBColumn;
    GridFaturaViewOZELKOD2: TcxGridDBColumn;
    GridFaturaViewURUNNO: TcxGridDBColumn;
    EditOZELKOD2: TcxDBTextEdit;
    PopupMenuEBelge: TPopupMenu;
    MenuKagitIrsaliyeyeCevir: TMenuItem;
    BirSatrAdetiKadarSatrlaraBolMenu: TMenuItem;
    PopupMenuTipDegis: TPopupMenu;
    MenuTipiIade: TMenuItem;
    DurumPaneli: TPanel;
    Label11: TcxLabel;
    LblSube: TcxLabel;
    ComboFaturaDURUM: TcxDBImageComboBox;
    ComboSube: TcxDBImageComboBox;
    ComboACIK_KAPALI: TcxDBImageComboBox;
    cbKdvDurum: TcxDBComboBox;
    Label5: TcxLabel;
    LabelFaturaTarihi: TcxLabel;
    LabelFatNo: TcxLabel;
    cbIrsaliyeli: TcxDBCheckBox;
    cxLabel1: TcxLabel;
    lbKaynakSeriNo: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    EditFatTarih: TcxDBDateEdit;
    EditFaturaSaat: TcxDBTimeEdit;
    cxDBSpinEdit1: TcxDBSpinEdit;
    EditFatNo: TcxDBTextEdit;
    EditFATURASERI: TcxDBTextEdit;
    DovizPaneli: TPanel;
    cxDBLabel5: TcxDBLabel;
    LabelRaporDovizi: TcxLabel;
    ComboRaporDovizi: TcxDBComboBox;
    EditKulKur: TcxDBCurrencyEdit;
    cbDovizCinsi: TcxDBComboBox;
    lbDoviz: TcxLabel;
    LabelEkVergi: TcxLabel;
    EditEkVergi: TcxDBCurrencyEdit;
    cxDBLabel3: TcxDBLabel;
    cxLabel7: TcxLabel;
    cxDBImageComboBox2: TcxDBImageComboBox;
    ComboFaturaDovizi: TcxDBComboBox;
    LabelFaturaDovizi: TcxLabel;


    GridFaturaViewEN: TcxGridDBColumn;
    GridFaturaViewBOY: TcxGridDBColumn;
    GridFaturaViewYUZEY: TcxGridDBColumn;
    GridFaturaViewSAYI: TcxGridDBColumn;
    KDVOranGir1: TMenuItem;
    SeciliSatira: TMenuItem;
    Tumune1: TMenuItem;
    GridFaturaViewPOZNO: TcxGridDBColumn;
    N7: TMenuItem;
    UTSdenAdetleriKontrolEtMenu: TMenuItem;
    ProjePanel: TPanel;
    MemoNOTLAR: TcxDBMemo;
    cxLabel17: TcxLabel;
    LabelAktivite: TcxLabel;
    LabelProje: TcxLabel;
    BeditProje: TcxButtonEdit;
    BeditBagliGorev: TcxButtonEdit;
    cxLabel3: TcxLabel;
    BeditServis: TcxButtonEdit;
    cxDBTextEdit2: TcxDBTextEdit;
    cxLabel4: TcxLabel;
    BeditDemirbas: TcxButtonEdit;
    lblDemirbas: TcxLabel;
    DOVIZ_TUTARI: TcxDBCurrencyEdit;
    SheetGenotip: TcxTabSheet;
    cxGroupBox1: TcxGroupBox;
    cxLabel2: TcxLabel;
    EditAd: TcxTextEdit;
    cxLabel5: TcxLabel;
    EditTCKN: TcxTextEdit;
    cxLabel8: TcxLabel;
    EditKimlikId: TcxTextEdit;
    cxLabel10: TcxLabel;
    EditSorumlu: TcxTextEdit;
    cxGroupBox2: TcxGroupBox;
    cxLabel11: TcxLabel;
    EditKurumu: TcxTextEdit;
    LabelPoliklinik: TcxLabel;
    EditPoliklinik: TcxTextEdit;
    cxLabel13: TcxLabel;
    EditDoktor: TcxTextEdit;
    LabelReferans: TcxLabel;
    EditReferans: TcxTextEdit;
    cxLabel15: TcxLabel;
    EditGonderen: TcxTextEdit;
    N8: TMenuItem;
    info1: TMenuItem;
    CheckSanal: TcxDBCheckBox;
    N9: TMenuItem;
    ExceldenVeriAl1: TMenuItem;
    MenuExcelDosyaSec: TMenuItem;
    MenuKolonEslestir: TMenuItem;
    ComboOZELKOD: TcxDBComboBox;
    ComboOZELKOD2: TcxDBComboBox;
    FATURA: TFDQuery;
    FATBASLIK: TFDQuery;
    TabFaturaID: TFDAutoIncField;
    TabFaturaFATBASID: TIntegerField;
    TabFaturaREHBERID: TIntegerField;
    TabFaturaSEC: TWideStringField;
    TabFaturaTUR: TSmallintField;
    TabFaturaURUNID: TIntegerField;
    TabFaturaACIKLAMA: TWideMemoField;
    TabFaturaADET: TFMTBCDField;
    TabFaturaEN: TFMTBCDField;
    TabFaturaBOY: TFMTBCDField;
    TabFaturaYUZEY: TFMTBCDField;
    TabFaturaSAYI: TFMTBCDField;
    TabFaturaMF: TFMTBCDField;
    TabFaturaBIRIM: TSmallintField;
    TabFaturaMIKTAR: TFMTBCDField;
    TabFaturaBIRIMFIYAT: TFMTBCDField;
    TabFaturaTUTAR: TFMTBCDField;
    TabFaturaKUR: TWideStringField;
    TabFaturaISKONTO: TFloatField;
    TabFaturaKDV: TSmallintField;
    TabFaturaMASRAFID: TIntegerField;
    TabFaturaIZLEMEKODU: TWideStringField;
    TabFaturaOZELKOD: TWideStringField;
    TabFaturaMUHKODU: TWideStringField;
    TabFaturaKASA: TSmallintField;
    TabFaturaONAY: TWideStringField;
    TabFaturaDOVIZ_TUTARI: TFMTBCDField;
    TabFaturaDOVIZ_KURU: TWideStringField;
    TabFaturaISKONTO2: TFloatField;
    TabFaturaIZLEME: TSmallintField;
    TabFaturaIADEADET: TFloatField;
    TabFaturaIADEFATURAID: TIntegerField;
    TabFaturaYERI: TIntegerField;
    TabFaturaYERID: TIntegerField;
    TabFaturaEKLEYEN: TIntegerField;
    TabFaturaEKLEMETARIHI: TSQLTimeStampField;
    TabFaturaDEGISTIREN: TIntegerField;
    TabFaturaDEGISTIRMETARIHI: TSQLTimeStampField;
    TabFaturaDOVIZ_BIRIMFIYAT: TFMTBCDField;
    TabFaturaDOVIZKURDEGERI: TCurrencyField;
    TabFaturaPROJEID: TIntegerField;
    TabFaturaKAMPANYAID: TIntegerField;
    TabFaturaVADE: TByteField;
    TabFaturaSTOKDURUMDEGIS: TBooleanField;
    TabFaturaSUBEID: TSmallintField;
    TabFaturaKDVMUHAFIYETI: TSmallintField;
    TabFaturaEKMALIYET: TCurrencyField;
    TabFaturaBASTAR: TSQLTimeStampField;
    TabFaturaBITTAR: TSQLTimeStampField;
    TabFaturaURETIMPLANID: TIntegerField;
    TabFaturaURETIMPLANDETAYID: TIntegerField;
    TabFaturaMERKEZID: TIntegerField;
    TabFaturaGIRISKAYNAK: TByteField;
    TabFaturaEKIPMANID: TIntegerField;
    TabFaturaGIRDEPO: TSmallintField;
    TabFaturaCIKDEPO: TSmallintField;
    TabFaturaOTVYUZDE: TBooleanField;
    TabFaturaOTVMIKTAR: TBCDField;
    TabFaturaSIRA: TIntegerField;
    TabFaturaSATICIKODU: TIntegerField;
    TabFaturaISKONTOLUBRMFIYAT: TFloatField;
    TabFaturaKDVDAHILBRMFIYAT: TFMTBCDField;
    TabFaturaKDVDAHILFIYAT: TFloatField;
    TabFaturaDEMIRBASID: TIntegerField;
    TabFaturaOZELKOD2: TWideStringField;
    TabFaturaPOZNO: TIntegerField;
    TabFaturaAD: TWideStringField;
    TabFaturaKOD: TWideStringField;
    TabFaturaURUNNO: TWideStringField;
    TabFaturaMALIYET: TCurrencyField;
    TabFaturaBIRIM2MIKTAR: TCurrencyField;
    TabFaturaBIRIM2AD: TWideStringField;
    TabFaturaPROJEKODU: TWideStringField;
    TabFaturaKAMPANYAADI: TWideStringField;
    TabFaturaSATICIADI: TWideStringField;
    TabFaturaECZANEBIRIMFIYAT: TCurrencyField;
    TabFaturaIMALATCIBIRIMFIYAT: TCurrencyField;
    TabFaturaDEPOCUBIRIMFIYAT: TCurrencyField;
    TabFaturaKDVTUTAR: TCurrencyField;
    TabFaturaBIRIMAD: TWideStringField;
    TabFaturaISKYAZI: TWideStringField;
    TabFaturaBARKOD: TWideStringField;
    TabFaturaEKIPMAN: TWideStringField;
    TabFaturaSERINO: TWideStringField;

    function EkranAdiAl: string;
    procedure FATBASLIKBeforePost(DataSet: TDataSet);
    procedure FaturaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure FATBASLIKNewRecord(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure FATURANewRecord(DataSet: TDataSet);
    procedure FATURABeforePost(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FaturaTusClick(Sender: TObject);
    procedure FATURAAfterDelete(DataSet: TDataSet);
    procedure FATURAAfterPost(DataSet: TDataSet);
    procedure TamEkranTusClick(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure LogKaydet;
    procedure MenuMusTreeDblClick(Sender: TObject);
    procedure FATURAAfterInsert(DataSet: TDataSet);
    procedure FATURABeforeEdit(DataSet: TDataSet);
    procedure FATURABeforeDelete(DataSet: TDataSet);
    procedure btnDonusturClick(Sender: TObject);
    procedure ButtonDuzenle;
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BeditBagliGorevPropertiesButtonClick
      (Sender: TObject; AButtonIndex: Integer);
    procedure LabelAdClick(Sender: TObject);
    procedure FATBASLIKAfterPost(DataSet: TDataSet);
    procedure FATBASLIKBeforeEdit(DataSet: TDataSet);
    procedure cbKdvDurumPropertiesCloseUp(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure cxGridDBColumn4GetPropertiesForEdit
      (Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure cxEditRepository1ButtonItem1PropertiesButtonClick
      (Sender: TObject; AButtonIndex: Integer);
    procedure KDVHaricTutargir1Click(Sender: TObject);
    procedure EditSRMMerkeziPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure N52Click(Sender: TObject);
    procedure FaturaKoanAyarlar1Click(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure GridFaturaViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure DetayEkrPage(Sender: TObject);
    procedure PlanlamaEkrPage(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FATURAAfterOpen(DataSet: TDataSet);
    procedure BtnYeniPlanClick(Sender: TObject);
    procedure BtnSilPlanClick(Sender: TObject);
    procedure cxGrid1DBTableView1MASRAFIDGetDisplayText
      (Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure TabPlanAfterOpen(DataSet: TDataSet);
    procedure GridFaturaViewMASRAFADPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridFaturaViewMASRAFADGetDisplayText
      (Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure lbDetaySablonClick(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure cxGrid1DBTableView1CanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FATBASLIKAfterScroll(DataSet: TDataSet);
    procedure FATURABeforeClose(DataSet: TDataSet);
    procedure DtsFatBaslikStateChange(Sender: TObject);
    procedure DtsFaturaStateChange(Sender: TObject);
    procedure TOPLAMLARCalcFields(DataSet: TDataSet);
    procedure MalFazlasDzenle1Click(Sender: TObject);
    procedure BeditProjeDblClick(Sender: TObject);
    procedure DetayEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FaturaEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FATBASLIKBeforeOpen(DataSet: TDataSet);
    procedure KampanyaDzenle1Click(Sender: TObject);
    procedure TabFaturaIptalIsaretleClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure EditButtonSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cbKdvDurumPropertiesInitPopup(Sender: TObject);
    procedure GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure cbBelgeTipiPropertiesCloseUp(Sender: TObject);
    procedure cbSaticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FATURABeforeOpen(DataSet: TDataSet);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BelgeEkle1Click(Sender: TObject);
    procedure Hesapla1Click(Sender: TObject);
    procedure Cariskonto1Click(Sender: TObject);
    procedure Stokskontosu1Click(Sender: TObject);
    procedure GridFaturaViewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure cbIrsaliyeliPropertiesEditValueChanged(Sender: TObject);
    procedure LbIrsaliyeBilgileriClick(Sender: TObject);
    procedure cbDovizCinsiPropertiesEditValueChanged(Sender: TObject);
    procedure IzlemBilgileriniDzenleMenuClick(Sender: TObject);
    procedure GridFaturaViewMERKEZIDGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure GridFaturaViewKOD1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridFaturaViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure FATURAAfterScroll(DataSet: TDataSet);
    procedure ComboBolumPropertiesCloseUp(Sender: TObject);
    procedure SatiraOzelIskontoClick(Sender: TObject);
    procedure editDovizKuruPropertiesEditValueChanged(Sender: TObject);
    procedure BtnDovizClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MemoFatAdresKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbDovizCinsiPropertiesInitPopup(Sender: TObject);
    procedure DokumanEkrPage(Sender: TObject);
    procedure cxDBComboBox1PropertiesInitPopup(Sender: TObject);
    procedure GridFaturaViewDblClick(Sender: TObject);
    procedure ComboEFATURADURUMPropertiesEditValueChanged(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure BtnEfaturaClick(Sender: TObject);
    procedure EditEkVergiClick(Sender: TObject);
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
    procedure BeditDemirbasPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure AyniUrunKodluSatrlarBirlestirMenuClick(Sender: TObject);
    procedure BeditBagliGorevDblClick(Sender: TObject);
    procedure EditILPropertiesInitPopup(Sender: TObject);
    procedure GridFaturaViewEKIPMANPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PopupMenuEBelgePopup(Sender: TObject);
    procedure MenuKagitIrsaliyeyeCevirClick(Sender: TObject);
    procedure BirSatrAdetiKadarSatrlaraBolMenuClick(Sender: TObject);
    procedure MenuTipiIadeClick(Sender: TObject);
    procedure PopupMenuTipDegisPopup(Sender: TObject);
    procedure ComboRaporDoviziPropertiesEditValueChanged(Sender: TObject);
    procedure UTSdenAdetleriKontrolEtMenuClick(Sender: TObject);
    procedure PopupMenuFaturaPopup(Sender: TObject);
    procedure ComboFIYAT_LISTESIPropertiesCloseUp(Sender: TObject);
    procedure PageUstChange(Sender: TObject);
    procedure LabelPoliklinikClick(Sender: TObject);
    procedure LabelReferansClick(Sender: TObject);
    procedure FATURAADETChange(Sender: TField);
    procedure TabFaturaENChange(Sender: TField);
    procedure info1Click(Sender: TObject);
    procedure MenuKolonEslestirClick(Sender: TObject);
    procedure MenuExcelDosyaSecClick(Sender: TObject);
    procedure TabFaturaCalcFields(DataSet: TDataSet);

  private
    { Private declarations }
    SatirVadesiKullan:Boolean;
    IskontoyaDetayGiriliyor:boolean;
    AraDlg: TStokHizmetAraDlg;
    FFrameBilgi: TIcerikFrameBilgi;
    ZorunluPlanOlustur: Boolean;
    LocateFaturaID: Integer;
    //KuraGoreFiyatHesaplamaAlani: integer; // faturaadetchange olayında kullanılıyor bu değişken
    BekletDlg: TBekletmeDlg;
    IzlemDlg:TIzlemeDlg;
    LokasyonDlg:TStokLokasyonDlg;
    function BoslukKontrolu: Boolean;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
    procedure FaturaTutarHesapla(TabloAc:Boolean);
    procedure FirmaBilgileri;
    procedure KaydetIptalButonlariAyarla;
    procedure DetayTablosuAc;
    procedure TekSatirKampanyaDuzenle(TabFaturaID:integer);
    procedure CokSatirKampanyaDuzenle(KampanyaID:integer);
    procedure IletisimEkleClick(Sender: TObject);
    procedure FaturaTipiDuzenle;
    procedure FaturadanSatirGetir(Sender: TObject);
    procedure IptalIslemleri;
    procedure EFaturaIslem(EFatura : smallint; NoSifirla : Boolean);
    procedure KonsinyeTipiDuzenle;
    procedure EkstreDoviziDuzenle(Sender: TObject);
    procedure SatirIslem(Sender: TObject);
    function IadeKontrolEt:Boolean;
    procedure BaslamaIslemleri;
    procedure Aman_Kilitle;
    procedure StokIzlemBilgisi;
    procedure SeciliSatiraSubMenuClick(Sender: TObject);
    procedure TumuneSubMenuClick(Sender: TObject);
  public
    { Public declarations }
    IslemOp: Char;
    Tur, TabFaturaIDsi, RehberId,ServisID, ProjeId, AktiviteId, MasrafMerkezi, Tipi: Integer;
    iadefis, Kilit: Boolean;
    Cagiran: SmallInt;
    OncekiStokMiktar: Real;
    OncekiBirim: Integer;
    /// FATURA satirinin urunu icin UStokHizmetAra'yi sade secim modunda
    /// (stokhizmetaracagirantur=18, TabNo_DEMIRBAS) acar. Aktif sekme Stok
    /// ise TUR=1, Hizmet ise TUR=0 atanir. Sonuc DB'ye dogrudan UPDATE FATURA
    /// ile yazilir; cagiran dataset'i refresh etmekle sorumludur.
    /// True doner: secim yapildi + UPDATE basarili.
    class function FaturaSatiriUrunSec(AConn: TFDConnection;
      AFaturaID: Integer; AFatBaslikID: Integer = 0;
      ARehberID: Integer = 0): Boolean; static;
  end;

var
  FaturaWizardDlg: TFaturaWizardDlg;

implementation

Uses UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra, UFastRap,
  UOPSDLG, UParaDegisiklik, URaporAraclari, UGenelAnaSekmeFrame, UFisIrsaliyeAraDlg,
  UGirisKutusuEx, UNakitDlg, URehberAyar, IdGlobalProtocols, LocOnFly,
  UCariFonksiyonlar, UAnaForm, UFaturalar, UFaturaGorevFrame, GenoTIP.eFatura.NativeApi, UGorevDlg, UIsListesi,
  UUTSKontrol,uUtility_my, UExceldenVeriAl;

{$R *.dfm}

var
  Belge, OncekiKDVDurumu : String[10];
  EkleDetay,   IptalSecildi, AdresDegisti,EkAlanOlustu, MaliyetGoster, TahsilatAlindi, LogAlindi,Onceki_ACIK_KAPALI,
  CarideEFatura, KilitKaldirildi: Boolean;
  Tab: TFDQuery;
  OncekiFaturaNo, OncekiDovizCinsi : string;
  OncekiSubeId, TabloNo :integer;
  KulMaxIsk1,KulMaxIsk2,KulMaxIskToplam:Extended;
  IadeOlanUrununSatisTarihi:TDateTime;
  ProjeFirsatSec : Smallint;
  BDDlg : TBelgeDonusumDlg;

procedure TFaturaWizardDlg.KaydetIptalButonlariAyarla;
begin
  if (DtsFatBaslik.State in [dsEdit, dsInsert]) or (DtsFatura.State in [dsEdit, dsInsert]) then begin
    KaydetTus.enabled := True;
    IptalTus.enabled := True;
  end else begin
    KaydetTus.enabled := False;
    IptalTus.enabled := False;
  end;
end;

procedure TFaturaWizardDlg.KaydetTusClick(Sender: TObject);
begin
  if TabFatbaslik.State in [dsInsert, dsEdit] then
     TabFatbaslik.Post;
  if TabFatura.State in [dsInsert, dsEdit] then
     TabFatura.Post;
end;

function TFaturaWizardDlg.EkranAdiAl: string;
begin
  case Tur of
    3  : Result := 'BelgeWizard';
    8  : Result := 'GiderPusulasi';
    10 : Result := 'IrsaliyeWizardAlis'; // eskisi EkranAdi:='FaturalarDlg';
    11 : Result := 'FaturaWizardAlis';
    12 : Result := 'FisWizardAlis';
    14 : Result := 'IrsaliyeWizard';
    15 : Result := 'FaturaWizard';
    16 : Result := 'FisWizard';
    109: Result := 'KonsinyeWizardAlis';
    119: Result := 'KonsinyeWizard';
  else
    Result := 'Yok';
  end;
end;


procedure TFaturaWizardDlg.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[TabloNo, TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.DokumanEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TFaturaWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
           TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabFatbaslik.FieldByName('REHBERID').AsInteger)
 end;

procedure TFaturaWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
  i : SmallInt;
  deger, FatTutar : Currency;
begin
//efatura kontrolü..
   if TabFatbaslik.FieldByName('EFATURADURUM').AsInteger>0 then begin
    if Application.MessageBox(PChar(HesapEfaturadadevamedecekmisin), PChar(''), MB_YESNO) = IDNO then
       Abort;
  end;
  //Değişkenler atanır
  for i := 0 to Tablo.repStokKDV.Properties.Items.Count-1 do begin
      if TOPLAMLAR.Locate('ACIKLAMA', 'KDV%'+Tablo.repStokKDV.Properties.Items[i], []) then
         deger := TOPLAMLAR.FieldByName('DEGER').AsCurrency
      else
         deger := 0;
      //A AFastReport.Variables.AddVariable('Fatura Değişkenleri','KDV'+inttostr(i+1), deger);
      DokumDegiskenListesi.Add('KDV'+inttostr(i+1)+'$@$'+CurrToStr(Deger));
      //FATBASLIK.FieldByName('KDV'+inttostr(i+1)).AsCurrency := deger;
  end;

//  TabloYenile(TabFatbaslik, [TabFatbaslik.FieldByName('ID').AsInteger]);
  TabloYenile(FATBASLIK, [TabFatbaslik.FieldByName('ID').AsInteger]);
  TabloYenile(FATURA, [TabFatbaslik.FieldByName('ID').AsInteger]);
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdiAl,frxFATBASLIK) then
    AFastReport.EnabledDataSets.Add(frxFATBASLIK)
  else begin
//    frxFATBASLIK.DataSet := TabFatbaslik;
    frxFATBASLIK.DataSet := FATBASLIK;
    frxFATURA.DataSet := FATURA;
    AFastReport.EnabledDataSets.Add(frxFATBASLIK);
    AFastReport.EnabledDataSets.Add(frxFATURA);
    if not DETAY.active then
      DetayTablosuAc;
    AFastReport.EnabledDataSets.Add(frxDETAY);
    AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
    Tablo.TabMusteri.Open;
    if TabFatbaslik.FieldByName('REHBERILETID').Value <> null then begin
      TabloYenile(Tablo.TabSevkAdresi,[RehberId,TabFatbaslik.FieldByName('REHBERILETID').AsInteger]);
      AFastReport.EnabledDataSets.Add(Tablo.frxSevkAdresi);
    end else
      Tablo.TabSevkAdresi.Close;
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
    TabloYenile(TabKaynaklar,[TabFatbaslik.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxKaynaklar);
    if (DovizTakibi)and(TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz) then
       FatTutar := TabFatbaslik.FieldByName('DOVIZ_TUTARI').AsCurrency
    else
       FatTutar := TabFatbaslik.FieldByName('FATURA_TUTARI').AsCurrency;
    TabloYenile(TabHesapOzeti,[TabFatbaslik.FieldByName('REHBERID').AsInteger,TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString, FatTutar]);
    AFastReport.EnabledDataSets.Add(frxHesapOzeti);
    TabloYenile(tabIzleme,[TabFatbaslik.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxIzleme);
  end;
  TabloYenile(TabRecete, [TabFatbaslik.FieldByName('ID').AsInteger]);
   AFastReport.EnabledDataSets.Add(frxRecete);
   TabloYenile(TabStokDetay,[TabFatbaslik.FieldByName('ID').Value,6]);
   AFastReport.EnabledDataSets.Add(frxStokDetay);
end;

procedure TFaturaWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
   Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
end;

procedure TFaturaWizardDlg.SatiraOzelIskontoClick(Sender: TObject);
var TSID:TIskontoDetayDlg;
begin
  IskontoyaDetayGiriliyor := True;
  Application.CreateForm(TIskontoDetayDlg,TSID);
  TSID.Yeri := TabFatbaslik.FieldByName('TUR').AsInteger;
  TSID.YerID := TabFatura.FieldByName('ID').AsInteger;
  TSID.Tur := (Sender as TMenuItem).Tag;
  TSID.TabIskontolar.Open;
  TSID.ShowModal;
  if TSID.ModalResult = mrOk then begin
     TabFatura.Edit;
     if TSID.Tur = 1 then
        TabFatura.FieldByName('ISKONTO').AsFloat  := TSID.IskOrani
     else
        TabFatura.FieldByName('ISKONTO2').AsFloat := TSID.IskOrani;
    TabFatura.Post;
  end;
  IskontoyaDetayGiriliyor := False;
end;

procedure TFaturaWizardDlg.IzlemBilgileriniDzenleMenuClick(Sender: TObject);
begin
    Tablo.IzlemBilgileriniDuzenle(IslemOp, TabFatbaslik, TabFatura, Kilit);
end;

procedure TFaturaWizardDlg.AyniUrunKodluSatrlarBirlestirMenuClick(Sender: TObject);
begin
//
   if Application.MessageBox(PChar(BirlestirAciklama), PChar(Onay),    MB_YESNO + MB_ICONQUESTION) = ID_YES then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := StringReplace(MemoBirlestir.Text,':FATBASID',TabFatbaslik.FieldByName('ID').AsString,[rfReplaceAll]);
      Tablo.Query1.ExecSQL;
      TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
   end;
end;

procedure TFaturaWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  KaydetTus.Click;
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
  Hesapla1Click(Sender);
end;

procedure TFaturaWizardDlg.BelgeEkle1Click(Sender: TObject);
var
  Sonuc: TStringList;
  Turler: string;
  I: Integer;
begin
  if TabFatbaslik.FieldByName('TUR').AsInteger = 11 then
    Turler := '11,12'
  else
    Turler := '15,16';

  Sonuc := Tablo.ListedenCokluSecim('Eklemek istediginiz belgeleri seciniz.',
    'select F.ID,F.FATURATARIH,F.TUR,R.FIRMA,FATURA_TUTARI,F.ACIKLAMA ' +
    'from FATBASLIK F inner join REHBER R on F.REHBERID=R.ID ' +
    'where isnull(BAGLIFATURAID,0)=0 and TUR in (' + Turler + ') order by 2',
    [nil,nil,Tablo.RepKasaTurleriReadOnly,nil,nil,Tablo.cxEditRepository1MemoItem1],
    ['ID','Tarih','Tur','Firma','Tutar','Aciklama']);
  try
    for I := 0 to Sonuc.Count - 1 do
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'update FATBASLIK set BAGLIFATURAID=&BagliId where ID=&Id',
        ['&BagliId','&Id'],
        [TabFatbaslik.FieldByName('ID').AsInteger, Sonuc[I]]);
  finally
    Sonuc.Free;
  end;
  Hesapla1Click(Sender);
end;
procedure TFaturaWizardDlg.BeditBagliGorevDblClick(Sender: TObject);
var
  GOREV_ID: String[15];
  GorevDlg1: TGorevDlg;
begin
  GOREV_ID := TabFatbaslik.FieldByName('AKTIVITEID').AsString;
  Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', StrToInt(GOREV_ID), AtamaYapildi, YorumYapildi);
  if AtamaYapildi then
    Gorev_EPostaGonder(1, StrToIntDef(GOREV_ID, -1))
  else if YorumYapildi then
    Gorev_EPostaGonder(3, StrToIntDef(GOREV_ID, -1));
end;

procedure TFaturaWizardDlg.BeditBagliGorevPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: TStringList;
begin
  if AButtonIndex = 0 then
    try
      st := TStringList.Create;
      if Tablo.ListedenBilgiGetir(AktiviteSecimi,
         'SELECT G.ID,TARIH=BASLAMATARIHI,EKLEYEN=R.FIRMA,DURUM=GT2.ANAHTAR,TUR=GT1.ANAHTAR,KONUSU ' +
         'FROM GOREVLER G inner join REHBER R on R.ID=G.EKLEYEN left join GENINI GT1 on GT1.BOLUM=-21044 and G.TURU=GT1.DEGER ' +
         'left join GENINI GT2 on GT2.BOLUM=-21042 and G.TURU=GT2.DEGER where KONUSU like ''%<ara>%'' and REHBERID=' + TabFatbaslik.FieldByName('REHBERID').AsString + ' ORDER BY 2 DESC',
         st, []) then
      begin
        TabFatbaslik.Edit;
        TabFatbaslik.FieldByName('AKTIVITEID').AsString := st.Strings[0];
        BeditBagliGorev.Text := st.Strings[1] + ' ' + st.Strings[4];
      end;
    finally
      st.Free;
    end
  else if AButtonIndex = 1 then
  begin
    TabFatbaslik.Edit;
    TabFatbaslik.FieldByName('AKTIVITEID').AsString := '-1';
    BeditBagliGorev.Text := '';
    TabFatbaslik.Post;
  end;
end;

procedure TFaturaWizardDlg.BeditDemirbasPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: TStringList;
begin
  if AButtonIndex = 0 then
    try
      st := TStringList.Create;
      if Tablo.ListedenBilgiGetir('Demirbas seciniz',
        'SELECT ID,DEMIRBASNO,DEMIRBASADI FROM DEMIRBAS where DEMIRBASNO like ''%<ara>%'' or DEMIRBASADI like ''%<ara>%'' ',
        st, []) then
      begin
        TabFatbaslik.Edit;
        TabFatbaslik.FieldByName('DEMIRBASID').AsString := st.Strings[0];
        BeditDemirbas.Text := st.Strings[2];
        BeditDemirbas.Tag := StrToIntDef(st.Strings[0], 0);
      end;
    finally
      st.Free;
    end
  else if AButtonIndex = 1 then
  begin
    TabFatbaslik.Edit;
    TabFatbaslik.FieldByName('DEMIRBASID').AsInteger := 0;
    BeditDemirbas.Text := '';
    BeditDemirbas.Tag := 0;
  end;
end;

procedure TFaturaWizardDlg.BeditProjeDblClick(Sender: TObject);
begin
  if BeditProje.Text <> '' then
    Tablo.ProjeSihirbazBaslat('D', TabFatbaslik.FieldByName('PROJEID').AsInteger,
      TabFatbaslik.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);
end;

procedure TFaturaWizardDlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje, TabFatbaslik, AButtonIndex, ProjeSecimi,
    TabFatbaslik.FieldByName('REHBERID').AsInteger, ProjeFirsatSec);
  if TabFatbaslik.FieldByName('PROJEID').AsInteger > 0 then
    if Tablo.UyariGoster('Proje Secimi',
      'Secmis oldugunuz proje, belgenizin tum satirlarina uygulansin mi?', 2) = mrYes then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'update FATURA set PROJEID=&PrjID where FATBASID=&FatbasID',
        ['&PrjID','&FatbasID'],
        [TabFatbaslik.FieldByName('PROJEID').AsInteger, TabFatbaslik.FieldByName('ID').AsInteger]);
  TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.BeditServisDblClick(Sender: TObject);
begin
  if (TabFatbaslik.FieldByName('SERVISID').Value <> Null) and
     (TabFatbaslik.FieldByName('SERVISID').AsInteger > 0) then
    Tablo.ServisSihirbazBaslat(False, 'D', 0, TabFatbaslik.FieldByName('SERVISID').AsInteger,
      TabFatbaslik.FieldByName('REHBERID').AsInteger);
end;

procedure TFaturaWizardDlg.BeditServisPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: TStringList;
  SQL: string;
begin
  if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '-' then
  begin
    TabFatbaslik.Edit;
    TabFatbaslik.FieldByName('SERVISID').Value := Null;
    TabFatbaslik.Post;
    (Sender as TcxButtonEdit).Text := '';
    (Sender as TcxButtonEdit).Tag := 0;
  end
  else
  begin
    SQL := 'select ID,SERVISNO,BASLAMATARIHI,BITISTARIHI,KONUSU from SERVIS where (SERVISNO like ''%<ara>%'' or KONUSU like ''%<ara>%'') and isnull(ACKAPA,0)=0 ';
    if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '+' then
      SQL := SQL + 'and REHBERID=' + IntToStr(RehberId);
    try
      st := TStringList.Create;
      if Tablo.ListedenBilgiGetir(ServisSecimi, SQL, st, []) then
      begin
        TabFatbaslik.Edit;
        TabFatbaslik.FieldByName('SERVISID').AsString := st.Strings[0];
        TabFatbaslik.Post;
        (Sender as TcxButtonEdit).Text := st.Strings[1] + ' - ' + st.Strings[4];
        (Sender as TcxButtonEdit).Tag := StrToIntDef(st.Strings[0], 0);
      end;
    finally
      st.Free;
    end;
  end;
end;
procedure TFaturaWizardDlg.BirSatrAdetiKadarSatrlaraBolMenuClick(Sender: TObject);
var ID,I,Adet:integer;
    Tutar : Extended;
begin
   ID   := TabFatura.FieldByName('ID').AsInteger;
   Adet := TabFatura.FieldByName('ADET').AsInteger;
   Tutar:= TabFatura.FieldByName('BIRIMFIYAT').AsExtended;
   for I := 2 to Adet do
      Tablo.SQLSatiriKopyala('FATURA', ID,['ADET','MIKTAR','TUTAR', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
      [1,1,Tutar,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
   //ilk satırda det ve tutarı değiştirelim
   TabFatura.Edit;
   TabFatura.FieldByName('ADET').AsInteger := 1;
   TabFatura.Post;
end;

procedure TFaturaWizardDlg.DetayTablosuAc;
begin
  DETAY.Close;
  DETAY.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID),[rfReplaceAll]);
  DETAY.Params[0].Value := Tablo.FaturaDetaySablonTipiBul(Tur);
  DETAY.Params[1].Value := TabFatbaslik.FieldByName('ID').AsInteger;
  DETAY.Params[2].Value := ComboBolum.Text;
  DETAY.Open;
  if DETAY.FindField('GIRIS') <> nil then
    DETAY.FieldByName('GIRIS').ProviderFlags := [];
  if DETAY.FindField('KAYNAK') <> nil then
    DETAY.FieldByName('KAYNAK').ProviderFlags := [];
  if DETAY.FindField('ZORUNLU') <> nil then
    DETAY.FieldByName('ZORUNLU').ProviderFlags := [];
  if DETAY.FindField('ORJINAL') <> nil then begin
    DETAY.FieldByName('ORJINAL').ReadOnly := True;
    DETAY.FieldByName('ORJINAL').ProviderFlags := [];
  end;
end;

procedure TFaturaWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TFaturaWizardDlg.DkmanSil1Click(Sender: TObject);
begin
if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabloNo, TabFatbaslik.FieldByName('ID').AsInteger]);
  end;
end;

procedure TFaturaWizardDlg.DetayEkrExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  if DETAY.State in [dsInsert, dsEdit] then
    DETAY.Post;
  if EkleDetay then begin
    Ekle(DETAY, Tablo.FaturaDetaySablonTipiBul(Tur), TabFatbaslik.FieldByName('ID').AsInteger, 'Değiş');
    EkleDetay := False;
  end;
end;

procedure TFaturaWizardDlg.DetayEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
  if not DETAY.active then
    DetayTablosuAc
end;

procedure TFaturaWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (IptalSecildi) and ((IslemOp = 'E') or (IslemOp = 'K')) and (TabFatbaslik.active) and (TabFatbaslik.Fields[0].AsString <> '')
      and (TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [0,1,11,21,31,51] )then// e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgiler silinmesi laz?m
      Tablo.FaturaSil(TabFatbaslik, TabFatura);

  if StokHizmetAraDlg <> nil then
      FreeAndNil(StokHizmetAraDlg);
end;

procedure TFaturaWizardDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var Ciksin : Boolean;
begin
   Ciksin := True;
   if (IptalSecildi)and((IslemOp='E')or(IslemOp='K')or( (IslemOp='D')and(KaydetTus.enabled)))then
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : begin
                Ciksin := False;
                WizardKontrolFinishButtonClick(Self);
               end;
       IDCANCEL:Ciksin := False;
      end;
//   else
//      if (IslemOp='D')and(FATURA.RecordCount < 1) then
//            raise Exception.Create(UrungirilmedenKaydedilemez);

   CanClose := Ciksin;
end;

procedure TFaturaWizardDlg.FormCreate(Sender: TObject);
var
  i: SmallInt;
  Item:TMenuItem;
  s: string[15];
  MyClass: TComponent;
  ComboOZELKOD: TcxDBComboBox;
begin

  if not EnBoyHesaplamaAktif then begin
     FreeAndNil(TabFaturaEN);
     FreeAndNil(TabFaturaBOY);
     FreeAndNil(TabFaturaSAYI);
     FreeAndNil(TabFaturaYUZEY);
     FreeAndNil(GridFaturaViewEN);
     FreeAndNil(GridFaturaViewBOY);
     FreeAndNil(GridFaturaViewSAYI);
     FreeAndNil(GridFaturaViewYUZEY);
  end;

  if not Tablo.FDCnn2.Connected then
  begin
    Tablo.FDCnn2.LoginPrompt := False;
    Tablo.FDCnn2.Params.Assign(Tablo.FDCnn.Params);
    Tablo.FDCnn2.ConnectionString := Tablo.FDCnn.ConnectionString;
    Tablo.FDCnn2.Params.Values['MARS_Connection'] := 'Yes';
    Tablo.FDCnn2.Params.Values['MultipleActiveResultSets'] := 'True';
    Tablo.FDCnn2.Connected := True;
  end;
  TabFatbaslik.Connection := Tablo.FDCnn2;
  TabFatura.Connection := Tablo.FDCnn2;

  if TabFatura.FindField('EKLEMETARIHI') <> nil then
    TabFatura.FieldByName('EKLEMETARIHI').AutoGenerateValue := DB.arDefault;
  if TabFatbaslik.FindField('EKLEMETARIHI') <> nil then
    TabFatbaslik.FieldByName('EKLEMETARIHI').AutoGenerateValue := DB.arDefault;

  TabFatura.UpdateOptions.FastUpdates := True;
  TabFatura.UpdateOptions.CountUpdatedRecords := False;
  TabFatura.FetchOptions.AutoClose := True;
  TabFatura.AutoCalcFields := True;
  // TabFatura SQL'inden kaldirilan gorunum alanlari runtime'da hesaplanir
  
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  Tablo.WizardTurkcelestir(WizardKontrol);
  KilitKaldirildi := False;
  EkAlanOlustu :=False;

  IptalSecildi := true;
  CheckSanal.enabled := TamYetkili;

  ProjeFirsatSec := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_ProjeFirsatSec, 11);
  if ProjeFirsatSec = 1 then
     LabelProje.Caption := 'Fırsat Kodu';

  SatirVadesiKullan := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_SatirlaraVade,False) ;  //  FaturaOpsiyon','SatirlaraVade
  ZorunluPlanOlustur := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_ZorunluPlanOlustur,False) ;  //   FaturaOpsiyon', 'ZorunluPlanOlustur
  Tablo.GridAyarRestore('FatSihirbazDetayGridi',GridFaturaView );
  Tablo.GridAyarRestore('FaturaPlanOdemeGridi',cxGrid1DBTableView1 );

  SheetGenotip.TabVisible := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_HastaFaturaSekmesi, false);

  RehberId := -1;
  ProjeId := -1;
  AktiviteId := -1;
  MasrafMerkezi := -1;
  iadefis := False;
  EkleDetay := False;
  IskontoyaDetayGiriliyor := False;
  AdresDegisti := False;
  //KuraGoreFiyatHesaplamaAlani := 1; // 1 birimfiyat 2 d?vizbirimfiyat


//  Tablo.GENINI.ReadImageSection(Ops_StokKart_Anabirim,(GridFaturaViewBIRIM1.Properties as TcxImageComboBoxProperties).Items);

  LogID := 0;
  LocateFaturaID := 0;
  if not Tablo.YetkiVarmi(2111, YetkiTur_Gorme, False) then begin // görme yoksa
    BeditProje.Visible := False;
    LabelProje.Visible := False; // görme var ama di?er yetkiler eksik ise
  end
  else if not((Tablo.YetkiVarmi(2111, YetkiTur_Ekleme, False)) and (Tablo.YetkiVarmi(2111, YetkiTur_Ekleme, False))) then begin // proje ekleme yetkisi
    BeditProje.Enabled := False;
    LabelProje.Enabled := False;
  end;
  KulMaxIsk1:=StrToFloatDef(Tablo.YetkiEkVarMi(241101),100.0);
  KulMaxIsk2:=StrToFloatDef(Tablo.YetkiEkVarMi(241102),100.0);
  KulMaxIskToplam:=100-(((100-KulMaxIsk1)*(100-KulMaxIsk2))/100);

  if not Tablo.YetkiVarmi(242112,YetkiTur_Gorme) then begin //Maliyet görme izni yoksa
       FreeAndNil(GridFaturaViewMALIYET);
       FreeAndNil(GridFaturaViewEKMALIYET);
  end;



     for i := 0 to Tablo.repStokKDV.Properties.Items.Count - 1 do begin
       Item := TMenuItem.Create(SeciliSatira);
       Item.Caption:=Tablo.repStokKDV.Properties.Items[i];
       Item.Tag :=StrToInt(Tablo.repStokKDV.Properties.Items[i]);
       Item.OnClick := SeciliSatiraSubMenuClick;
       SeciliSatira.Add(Item);
     end;
     for i := 0 to Tablo.repStokKDV.Properties.Items.Count - 1 do begin
       Item := TMenuItem.Create(Tumune1);
       Item.Caption:=Tablo.repStokKDV.Properties.Items[i];
       Item.Tag :=StrToInt(Tablo.repStokKDV.Properties.Items[i]);
       Item.OnClick := TumuneSubMenuClick;
       Tumune1.Add(Item);
     end;

  //Ek alanlar oluşturulur
  try
    if not EkAlanOlustu then begin
       Tablo.AlanOlustur(TFaturaWizardDlg(Self), -1,DtsFatBaslik);
       TabFatbaslik.Close;
       EkAlanOlustu:=True;
       PageUst.ActivePageIndex := 0;
    end;
  except
    showmessage('Ek alanlar oluşturulurken bir hata ile karşıılaçıldı.');
  end;
end;

procedure TFaturaWizardDlg.TabFaturaENChange(Sender: TField);
begin
   //OndalikDijitSayMik
   if (EnBoyHesaplamaAktif = True) and (TabFatura.FieldByName('EN').AsString <> '') and
      (TabFatura.FieldByName('BOY').AsString <> '') then begin
      TabFatura.FieldByName('YUZEY').AsFloat := (TabFatura.FieldByName('EN').AsFloat * TabFatura.FieldByName('BOY').AsFloat) / 1000000;
      TabFatura.FieldByName('ADET').AsFloat := RoundTo(TabFatura.FieldByName('YUZEY').AsFloat * TabFatura.FieldByName('SAYI').AsFloat, -1 * OndalikDijitSayMik);
   end;
end;

procedure TFaturaWizardDlg.SeciliSatiraSubMenuClick(Sender: TObject);
begin
  TabFatura.Edit;
  TabFatura.FieldByName('KDV').AsInteger := TMenuItem(Sender).Tag;
  TabFatura.Post;
end;

procedure TFaturaWizardDlg.TumuneSubMenuClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'update FATURA set KDV=&Yuzde where FATBASID=&id',['&Yuzde','&id'],
      [TMenuItem(Sender).Tag, TabFatbaslik.Fields[0].AsInteger]);
  FaturaTutarHesapla(True);
  TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;



procedure TFaturaWizardDlg.UTSdenAdetleriKontrolEtMenuClick(Sender: TObject);
begin
   Application.CreateForm(TUTSKontrolDlg, UTSKontrolDlg);
   UTSKontrolDlg.BaslikID := TabFatbaslik.FieldByName('ID').AsInteger;
   UTSKontrolDlg.UTSKontrolBtn.Enabled :=  not((EFaturaKullanimda>0)and(TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [2,12]));
   UTSKontrolDlg.ShowModal;
   UTSKontrolDlg.Destroy;
end;
procedure TFaturaWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
  i : smallint;
begin
  clientPos :=Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bileşen Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      //OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TFaturaWizardDlg(Self),DtsFatBaslik);
      Tablo.AlanOlustur(TFaturaWizardDlg(Self), -1,DtsFatBaslik);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bileşen Düzenle
      Tablo.AlanlarDlgBaslat('D',1,0,ctrlPos.X,ctrlPos.Y,0,FindComponent(PanelEkAlanlar.Name),TFaturaWizardDlg(Self),DtsFatBaslik);
      Tablo.AlanOlustur(TFaturaWizardDlg(Self), -1,DtsFatBaslik);
  end else if (GridFaturaViewMALIYET<>nil)and(Shift = [ssCtrl]) and (Key = Ord('M'))and(Tur in [15,16]) then begin   //Maliyetleri göster
       GridFaturaViewEKMALIYET.Caption := 'Son.Maliyet';
       GridFaturaViewEKMALIYET.Visible := not GridFaturaViewEKMALIYET.Visible;
       GridFaturaViewMALIYET.Visible := not GridFaturaViewMALIYET.Visible;
  end else if (Shift = [ssAlt,ssCtrl,ssShift]) and (Key = Ord('S')) and (TamYetkili) then begin   //Maliyetleri göster
    Kilit := False;
    TabFatbaslik.Close;    TabFatbaslik.Open;
    if TabFatura.Active then
       TabFatura.Close;
    TabFatura.Open;

    //GridFatura.PopupMenu := PopupMenuFatura;
    if PopupMenuFatura <> nil then
       for i := 0 to PopupMenuFatura.Items.count-1 do
        PopupMenuFatura.Items[i].enabled := True;


    //ToolBarAlet.PopupMenu := PopupMenuFatura;
    KilitKaldirildi := True;

    //ToolBarAlet.Enabled := True;
    PanelUst.Enabled := True;
    PanelAlt.Enabled := True;

    BaslikPaneli.Enabled := False;
    DurumPaneli.Enabled := False;
    ProjePanel.Enabled := False;

    DovizPaneli.Enabled := True;

    EditVade.Enabled := True;
    cbSatici.Enabled := True;
    EditOZELKOD.Enabled := True;
    EditOZELKOD2.Enabled := True;
    ShowMessage('Kilit Açıldı!');
  end;
  if (TabFatbaslik.Active=False)or(TabFatbaslik.Fields[0].AsString='') then
      TabloYenile(TabFatbaslik, [TabFaturaIDsi]);
  //Tablo.AlanOlustur(PanelUst,TFaturaWizardDlg(Self), -1,DtsFatBaslik);
end;

procedure TFaturaWizardDlg.KonsinyeTipiDuzenle;
begin
   cbStokDepo.RepositoryItem:=nil;

   LabelKonsinyeDepo.Visible:=((Tur=109)and(TabFatbaslik.FieldByName('TIPI').AsInteger=2))or((Tur=119)and(TabFatbaslik.FieldByName('TIPI').AsInteger=1));
   cbStokDepo2.Visible:=LabelKonsinyeDepo.Visible;
   if cbStokDepo2.Visible then begin
      cbStokDepo.Width:=100;
      if Tur=109 then
         cbStokDepo2.DataBinding.DataField := 'CIKISDEPO'
      else
         cbStokDepo2.DataBinding.DataField := 'GIRISDEPO';
   end else begin
      cbStokDepo2.DataBinding.DataField := '';
      cbStokDepo.Width:=289;
   end ;

   case TabFatbaslik.FieldByName('TIPI').AsInteger of
     1,5: begin //Sat??  veya ithal/ihraçı
           if Tur=109 then begin
              cbStokDepo.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN=5 and SUBEID='+IntToStr(SubeId)).Items;
              if (TabFatbaslik.state in [dsEdit, dsInsert])and(cbStokDepo.Properties.Items[0].Value<>null) then
                  TabFatbaslik.FieldByName(cbStokDepo.DataBinding.DataField).AsInteger := cbStokDepo.Properties.Items[0].Value;
           end
           else begin//119
              cbStokDepo.Properties.Items  := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN<>7 and SUBEID='+IntToStr(SubeId)).Items;
              cbStokDepo2.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN=7 and SUBEID='+IntToStr(SubeId)).Items;
              if (TabFatbaslik.state in [dsEdit, dsInsert])and(cbStokDepo2.Properties.Items[0].Value<>null) then
                 TabFatbaslik.FieldByName(cbStokDepo2.DataBinding.DataField).AsInteger := cbStokDepo2.Properties.Items[0].Value;
              //cbStokDepo2.EditValue := cbStokDepo2.Properties.Items[0].Value;
           end;
       end;
     2: begin //iade
           if Tur=109 then begin
              cbStokDepo.Properties.Items  := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN not in (5,7) and SUBEID='+IntToStr(SubeId)).Items;
              cbStokDepo2.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN=7 and SUBEID='+IntToStr(SubeId)).Items;
              if cbStokDepo2.Properties.Items[0].Value<>null then
                 TabFatbaslik.FieldByName(cbStokDepo2.DataBinding.DataField).AsInteger := cbStokDepo2.Properties.Items[0].Value;
//              cbStokDepo2.EditValue := cbStokDepo2.Properties.Items[0].Value;
           end else //119
              cbStokDepo.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN=5 and SUBEID='+IntToStr(SubeId)).Items;
       end;
   end;
   //if FATBASLIK.FieldByName(cbStokDepo.DataBinding.DataField).AsString='' then begin
      if cbStokDepo.EditValue = null then begin
         cbStokDepo.EditValue := cbStokDepo.Properties.Items[0].Value;
         TabFatbaslik.FieldByName(cbStokDepo.DataBinding.DataField).AsInteger := cbStokDepo.Properties.Items[0].Value;
      end;
end;

////////////
///
procedure TFaturaWizardDlg.BaslamaIslemleri;
var   belgeno: TBelgeNo;
begin
  ButtonDuzenle;

  Height := Screen.Height - round(Screen.Height * 0.1);
  Position := poScreenCenter;
  if (not TabFatbaslik.active) or (TabFatbaslik.FieldByName('REHBERID').AsString <> IntToStr(RehberId)) then
  begin
    case Tur of
        3, 10, 11, 12, 13, 109 :begin
          if Tur=3 then
             FaturaEkr.Title.Text := SGirisFisi
          else
             FaturaEkr.Title.Text := FWGelen;
          FaturaKoanAyarlar1.Visible := False;
        end;
         8 : begin // gider pusulası ise
          FaturaEkr.Title.Text := FWGiderPusula;
          FaturaKoanAyarlar1.Visible := True;
        end else begin
          if Tur=4 then
             FaturaEkr.Title.Text := SCikisFisi
          else
             FaturaEkr.Title.Text := FWGiden;
          FaturaKoanAyarlar1.Visible := True;
        end;
    end;
    case Tur of
      10, 14: Belge := FWIrsaliye;
      11, 15: Belge := FWFatura;
      12, 16: Belge := FWFis;
      109,119:Belge := FWKonsinye;
    end;
    BtnDonustur.Visible := Tur in[10,11,12,14,15,16,119];
    FaturaEkr.Title.Text := FaturaEkr.Title.Text + Belge;
    LabelFaturaTarihi.Caption := Belge + KontrolTarihi;
    LabelFatNo.Caption := Belge + KontrolNo + ' / ' +FWSayfa ;
    LabelKod.Caption := Tablo.AciklamaGetir('REHBER', 'KOD', RehberId);
    LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
    TabloYenile(TabFatbaslik, [TabFaturaIDsi]);
    if (IslemOp <> 'K')and(
        //Gönderilmiş e-fat veya e-arşiv ise kilitli olması lazım
       ((IslemOp = 'D')and((KilitKontrolEt(2,Tur,TabFatbaslik.FieldByName('FATURATARIH').AsDateTime,2))or (IadeKontrolEt) ))or
        (TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [2,12,22,32])

       ) then
        Aman_Kilitle;
    //e??er say?m sonucu giri? ve ??k?? fiıleri oluşmu?sa bunlar değiştirilemez
    if (TUR in [3,4]) and (TabFatbaslik.FieldByName('TIPI').AsInteger in [16,17]) and (TabFatbaslik.FieldByName('YERI').AsInteger=99) then
        Aman_Kilitle;

    TabloYenile(TabFatura, [TabFaturaIDsi]);

    FirmaBilgileri;

    case IslemOp of
      'E':
        if TabFaturaIDsi < 1 then // e?er ID 0 veya -1 ise ekleme yapıls?n, normal Id varsa d?n???m var demektir. ?rne?in irsaliyeden-->faturaya
          TabFatbaslik.Append // Ekleme
        else
          TabFatbaslik.Edit;
      'D','I':;
      'K':;
      {  begin
          Tablo.TablodanSorguAc(3,'select * from FATURA where FATBASID=' + inttostr(FaturaIDsi));
          case Tur of
            10,11,12:
              begin
                FaturaIDsi := Tablo.SQLSatiriKopyala('FATBASLIK', FATBASLIK.FieldByName('ID').AsInteger,[ 'FATURATARIH','YERI', 'YERID', 'EKLEYEN', 'FATURANO','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','MUHAKTAR'],
                  [ Tablo.GENINI.BugunTrhSaat, null, null, Kullanan, '',Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);
              end;
           14,15,16:
              begin
                belgeno := SiradakiBelgeNumarasi(Tur, FATBASLIK.FieldByName('FATURATARIH').AsDateTime);
                FaturaIDsi := Tablo.SQLSatiriKopyala('FATBASLIK', FATBASLIK.FieldByName('ID').AsInteger,[ 'FATURATARIH', 'YERI','YERID', 'EKLEYEN', 'FATURASERI', 'KOCANNO', 'FATURANO', 'EFATURADURUM','EFATURASONUC', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','MUHAKTAR'],
                    [ Tablo.GENINI.BugunTrhSaat, null, null, Kullanan,  belgeno.SeriNo, KocannoBul(Tur), belgeno.belgeno, 0,0,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);
              end;
          end;

          while not Tablo.Query3.Eof do
          begin
            Tablo.SQLSatiriKopyala('FATURA', Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', 'FATBASID','YERI', 'YERID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI'],
              [Kullanan, FaturaIDsi,null,null,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
            Tablo.Query3.Next;
          end;
          TabloYenile(FATBASLIK, [FaturaIDsi]);
          TabloYenile(FATURA, [FaturaIDsi]);
        end; }
    end;


    if TabFatbaslik.FieldByName('MERKEZID').AsString <> '' then
      EditSRMMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI',TabFatbaslik.FieldByName('MERKEZID').AsInteger);

    if TabFatbaslik.FieldByName('PROJEID').AsString <> '' then
      BeditProje.Text := Tablo.AciklamaGetir('PROJELER','PROJEKODU+'' / ''+PROJEADI', TabFatbaslik.FieldByName('PROJEID').AsInteger);
  end;

  if IslemOp ='I' then
     TabFaturaIptalIsaretleClick(Self);
end;

procedure TFaturaWizardDlg.FormShow(Sender: TObject);
var
  ra: string;
  TN: TTreeNode;
  aktifFrame:  TGenelAnaSekmeFrame;
  etiketler,  bilgiler:  TArrayOfString;
  KurDegeri : Currency;
  BelNo : Variant;
  i: integer;
  Vars : string[5];
  NewItem:  TcxImageComboBoxItem;
begin
  LogAlindi := False;
  Kilit := False;

  if EIrsaliyeKullanimda=False then
     MenuKagitIrsaliyeyeCevir.Destroy; //e-irsaliye kullanımda ise göndermeyecekleri zaman kağıda çevirmeleri gerekir

  AyniUrunKodluSatrlarBirlestirMenu.Enabled := not UTSKullanimda;
  BaslamaIslemleri;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  if ((Tur=15)and(EFaturaKullanimda>0))or((Tur=14)and(EIrsaliyeKullanimda)) then begin
     //YaziciYaz.Visible:=EFaturaKullanimda<>11; //e-arşiv varsa gürünmeyecek
     BtnEfatura.Visible:=True;
     GrpBoxEFatura.Visible:=True;
     cbStokDepo.Width := 100;
     ComboSENARYO.Visible:=True;
     //ComboSENARYO.properties.Items.AddItems(Tablo.repSenaryo.Items);tcxImageComboBox
  // 'Repository' bile?eninin ad? 'EditRepository1' olsun.
  //   RepItem := TcxEditRepositoryImageComboBoxItem(Tablo.cxEditRepository1.Items.FindItemByName('RepSenaryo'));

    // Eğer öğe bulunduysa (nil değilse), Items listesini atama yap
  //   if Assigned(RepItem) then
  //      ComboSENARYO.Properties.Items.Assign(RepItem.Items);
     ComboSENARYO.Properties.Items.Assign(TcxEditRepositoryImageComboBoxItem(Tablo.RepSenaryo).Properties.Items);
     if (UTSKullanimda)and(TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [1, 2, 21, 22]) then begin//efatura ise tıbbi cihaz da ekleyelim
        NewItem := ComboSENARYO.Properties.Items.Add;
        NewItem.Description := 'ilaç_TıbbiCihaz';
        NewItem.Value := 8;
    end;
    // ComboSENARYO.Properties.Items.Assign(RepSenaryo.Properties.Items);
     LabelSenaryo.Visible := True;
     LabelSorgu.Visible :=True;
  end;

  TahsilatAlindi:=False;

  if not DovizTakibi then begin
    BtnDoviz.Visible := DovizTakibi;
    cbDovizCinsi.Visible := DovizTakibi;
    EditKulKur.Visible := DovizTakibi;
    ComboRaporDovizi.Visible := DovizTakibi;
    LabelRaporDovizi.Visible := DovizTakibi;
    lbDoviz.Visible := DovizTakibi;
    tvFatToplamlarColumn5.Visible := DovizTakibi;
    tvFatToplamlarColumn6.Visible := DovizTakibi;
    LabelFaturaDovizi.Visible := DovizTakibi;
    ComboFaturaDovizi.Visible := DovizTakibi;

    FreeAndNil(GridFaturaViewDOVIZ_BIRIMFIYAT);
    FreeAndNil(GridFaturaViewDOVIZ_KURU);
    FreeAndNil(GridFaturaViewDOVIZ_TUTARI);
    FreeAndNil(GridFaturaViewDOVIZKURDEGERI);
  end;


//  FATURADOVIZ_BIRIMFIYAT.OnChange := FATURAADETChange;
//  FATURABIRIMFIYAT.OnChange := FATURAADETChange;

  WizardKontrol.SelectFirstPage;
  Tablo.FaturaInit(Tur, ComboFaturaDURUM.Properties,TcxImageComboBoxProperties(GridFaturaViewTUR.Properties),
        TcxImageComboBoxProperties(GridFaturaViewBIRIM1.Properties));

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;
  cbIrsaliyeli.Visible := Tur = 15;

  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;
  if IslemOp in ['E','K'] then begin
    DetayTus.Enabled := False;
    PlanlaTus.Enabled := False;
    //cbStokDepo.RepositoryItem:=Tablo.RepStokDepolarAktif;  //Yeni faturada sadece aktif depolar olmal?
    // Yeni faturada sadece aktif depolar olmal? ama al??ta kons. ??k??, sat??ta da kons giri? gelmemelii
    if Tur in [10,11,12,109] then
       Vars:='7'
    else
       Vars:='5';

    //?nce bakal?m bu kullan?c? i?in depo yetkisi var m? (hi? yoksa hepsi gelecek)
    if (TamYetkili=False)and(Veritabani.VeriVarMi(Tablo.FDCnn,'select * from  YETKI where ROLID ='+RolID+' and LEN(MODULID)>4 and MODULID like ''2470%'' ',[],[])) then
       cbStokDepo.Properties.items := Tablo.imgComboboxInit('select D.ID, D.DEPOADI from DEPOLAR D inner join YETKI Y on Y.MODULID=''2470''+CONVERT(VARCHAR(20), D.ID) '+
        'where D.DURUM=1 and D.VARSAYILAN<>'+Vars+' and (Y.ROLID ='+RolID+' or -1='+RolID+')' ).items
     else
       cbStokDepo.Properties.items := Tablo.imgComboboxInit( 'select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN<>'+Vars).items;
  end
  else
    cbStokDepo.RepositoryItem:=Tablo.RepStokDepolarTumu;  //Eski faturada pasif depolar da olabilir

  if SatirVadesiKullan then begin
     if EditVade.visible then
        EditVade.Properties.ReadOnly := True
  end else
    (GridFaturaViewVADE.Properties as TcxCurrencyEditProperties).ReadOnly := True;

  if (not Kilit)and(TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [0, 11]) then
     TabFatbaslik.Edit;

  if Tur in[3,4] then begin
    cxLabel6.OnClick := Tablo.LabelClickCombobox;
  end else begin
    cxLabel6.OnClick :=nil;
  end;

  //if (Tur in [10,11,14,15])and(cbKdvDurum.Properties.Items.Count=3) then //İrsaliye veya Fatura ise kdv dahil opsiyonu olamaz
  if cbKdvDurum.Properties.Items.Count=3 then //KDV dahili kald?rd?m
     cbKdvDurum.Properties.Items.delete(1);

  if ComboFatTipi.EditValue = 5 then begin //kur fark? ise değişmesin
     ComboRaporDovizi.Enabled := False;
     //cbDovizCinsi.Enabled := False;
     GridFaturaViewDOVIZ_BIRIMFIYAT.Options.Editing := False;
  end;

  case Tur of
    3  : TabloNo := TabNo_FIS_Gelen;
    4  : TabloNo := TabNo_FIS_Giden;
    8  : TabloNo := Tabno_GIDERPUSULASI;
    10 : TabloNo := TabNo_IRSALIYE_Gelen;
    11 : TabloNo := TabNo_FATBASLIK_Gelen;
    12 : TabloNo := TabNo_FIS_Gelen;
    14 : TabloNo := TabNo_IRSALIYE_Giden;
    15 : TabloNo := TabNo_FATBASLIK_Giden;
    16 : TabloNo := TabNo_FIS_Giden;
    109: TabloNo := TabNo_KONSINYE_GELEN;
    110: TabloNo := Tabno_GIDERPUSULASI;
    119: TabloNo := TabNo_KONSINYE_GIDEN;
  end;

  case Tur of
    0, 3, 8, 10, 11, 12, 109:
      begin
        cbStokDepo.DataBinding.DataField := 'GIRISDEPO';
        BaslikPaneli.Enabled := False;
        EditButtonSevkAdresi.Visible:=False;
        lblSevkAdresi.Visible:=False;
       // LabelMasrafMerkezi.Caption := MasrafMerkeziPrj;
        //GridFaturaViewMASRAFAD.Caption := MasrafAdi;
        ComboFIYAT_LISTESI.RepositoryItem := Tablo.RepFiyatAdlariAlis;
        lbSatici.Caption := 'Satışn Alan';
      end;
    1, 4, 14, 15, 16,110, 119:
      begin
        cbStokDepo.DataBinding.DataField := 'CIKISDEPO';
//        if Tur = 119 then //Giden konsinye ise konsinye deposuna atal?m
//           cbStokDepo2.DataBinding.DataField := 'GIRISDEPO';
        BaslikPaneli.Enabled := True;
        EditButtonSevkAdresi.Visible:= True;
        lblSevkAdresi.Visible:= True;
        if GridFaturaViewMALIYET <> nil then begin
            GridFaturaViewEKMALIYET.Visible := False;
            GridFaturaViewMALIYET.Visible := False;
        end;
        ComboFIYAT_LISTESI.RepositoryItem := Tablo.RepFiyatAdlari;
      end;
  else
    cbStokDepo.Visible := False;
    // LabelDepo.Visible := False;
  end;

  if Tur in [109,119] then //Gelen/Giden konsinye
     KonsinyeTipiDuzenle;

  LabelProje.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  LabelAktivite.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  BeditProje.Visible := (Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme)) and (Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_ProjeGozuksun, True));
  LabelProje.Visible := BEditProje.Visible;
  BEditDemirbas.Visible := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_DemirbasGozuksun, True);
  lblDemirbas.Visible := BEditDemirbas.Visible;
  BeditBagliGorev.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  PlanlaTus.Visible := Tablo.YetkiVarmi(MODUL_Kasa,YetkiTur_Gorme);
  PlanlamaEkr.Enabled := Tablo.YetkiVarmi(MODUL_Kasa,YetkiTur_Gorme);
  DetayEkr.EnableButton(bkNext, Tablo.YetkiVarmi(MODUL_Kasa,YetkiTur_Gorme));

  ButtonDuzenle;

  LogBelge.Clear;
  if TabFatura.active then begin
     if (IslemOp = 'E')and(not TabFatura.IsEmpty) then begin
        TabFatura.Edit;
        if ComboFIYAT_LISTESI.Text='' then begin
           if ComboFIYAT_LISTESI.RepositoryItem = Tablo.RepFiyatAdlari then
              TabFatbaslik.FieldByName('FIYAT_LISTESI').AsInteger := VarsSatisFiyatID
           else if ComboFIYAT_LISTESI.RepositoryItem = Tablo.RepFiyatAdlariAlis then
              TabFatbaslik.FieldByName('FIYAT_LISTESI').AsInteger := VarsAlisFiyatID
        end;
        if TabFatbaslik.FieldByName('REHBERID').AsInteger<=0 then
           TabFatbaslik.FieldByName('REHBERID').AsInteger := RehberID;
        if tur in [0, 3, 8, 10, 11, 12, 109] then
           i:=SubeId //geliş belgelerinde bağlık firma gürünmeli
        else
           i:=RehberId;
        Tablo.FaturaBaslik(TabFatbaslik,i);
        if ComboRaporDovizi.EditValue = null then
           TabFatbaslik.FieldByName('RAPORDOVIZ').AsString := CariDoviz;
        if TabFatbaslik.FieldByName('BASLIK').AsString = '' then

        OncekiFaturaNo:='0';//Faturano kontrolü yapması lazım
        if TabFatbaslik.state in [dsEdit,dsInsert] then
           TabFatbaslik.Post;
        FaturaTutarHesapla(True);
     end;

    TabFatura.First;
    while not TabFatura.Eof do
    begin
       if IslemOp = 'E' then begin//bir siparişten faturaya dönüşüm olmuşsa bugünkü döviz kuruna göre güncellemeliyiz
          if TabFatbaslik.FieldByName('FATURANO').AsString = '' then begin
             if TGirisKutusuEx.BilgiAlEx('Belge No Girişi' ,TGirdiDenetimleri.Create.Edit('Belge No:' , @BelNo)) <> mrOk then
                TabFatbaslik.FieldByName('FATURANO').AsString:='0'
             else
                TabFatbaslik.FieldByName('FATURANO').AsString := BelNo;
          end;

          if (TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString <> CariDoviz)and(TabFatura.FieldByName('DOVIZ_KURU').AsString <> CariDoviz) then begin
             TabFatura.Edit;
             KurDegeri :=DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TabFatbaslik.FieldByName('FATURATARIH').AsDateTime), TabFatura.FieldByName('DOVIZ_KURU').AsString , Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
             TabFatura.FieldByName('DOVIZKURDEGERI').AsCurrency := KurDegeri;
             TabFatura.Post;
          end;
       end;
       if LogGun > 0 then
          Tablo.BelgeLogBelirle(TabFatura);
      TabFatura.Next;
    end;
    if (IslemOp = 'E')and(TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString <> CariDoviz) then begin//bir siparişten faturaya dönüşüm olmuşsa bugünkü döviz kuruna göre güncellemeliyiz
       TabFatbaslik.Edit;
       TabFatbaslik.FieldByName('DOVIZKUR').AsCurrency := DovizKuruBul(
          formatdatetime('yyyy-mm-dd 00:00', TabFatbaslik.FieldByName('FATURATARIH').AsDateTime),
          TabFatbaslik.FieldByName('RAPORDOVIZ').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
      //FATBASLIK.Post;
      ShowMessage(KurGuncellendi);
    end;
    if (IslemOp <>'D')and(not TabFatura.IsEmpty) then
    begin
      if TabFatura.State = dsBrowse then
         TabFatura.Edit;
      TabFatura.Cancel;
    end;
  end;
  if TabFatbaslik.active then begin
    if (TabFatbaslik.FieldByName('SERVISID').Value <> null) and (TabFatbaslik.FieldByName('SERVISID').AsInteger>0) then begin
      Tablo.TablodanSorguAc(9,'select * from SERVIS where ID='+TabFatbaslik.FieldByName('SERVISID').AsString);
      if not Tablo.Query9.IsEmpty then begin
        BeditServis.Text := Tablo.Query9.FieldByName('SERVISNO').AsString+' - '+Tablo.Query9.FieldByName('KONUSU').AsString;
        BeditServis.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
      end;
    end;
    if TabFatbaslik.FieldByName('PROJEID').AsString <> '' then
       BeditProje.Text := Tablo.AciklamaGetir('PROJELER', 'isnull(PROJEKODU,'''')+'' / ''+isnull(PROJEADI,'''')', TabFatbaslik.FieldByName('PROJEID').Value);
    if TabFatbaslik.FieldByName('AKTIVITEID').AsString <> '' then begin
       Tablo.TablodanSorguAc(1, 'SELECT BASLAMATARIHI,TUR=GT1.ANAHTAR FROM GOREVLER G left join GENINI GT1 on GT1.BOLUM=-21044 and G.TURU=GT1.DEGER '+
          'where G.ID='+TabFatbaslik.FieldByName('AKTIVITEID').AsString);
       BeditBagliGorev.Text:=Tablo.Query1.Fields[0].AsString+' '+Tablo.Query1.Fields[1].AsString;
    end;
    if TabFatbaslik.FieldByName('SATICIKODU').AsString <> '' then
       cbSatici.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabFatbaslik.FieldByName('SATICIKODU').AsString);

    ToolBarAlet.Enabled := TabFatbaslik.FieldByName('DURUM').AsInteger<>6;

    if (TabFatbaslik.FieldByName('REHBERILETID').AsString <> '') then begin
       EditButtonSevkAdresi.Text := Tablo.AciklamaGetir('REHBERILETISIM','AD', TabFatbaslik.FieldByName('REHBERILETID').AsString);
       Tablo.TablodanSorguAc(1,' Select RI.ID,RI.AD,RB.BILGI from REHBERILETISIM RI '+
        ' left outer JOIn REHBERBILGI RB on RI.ID=RB.YER_ID  left outer join REHBERAYAR RA ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
        ' Where RB.YER_ID ='+TabFatbaslik.FieldByName('REHBERILETID').AsString+' and RB.YERI=1 and RA.VARSAYILAN=2 and RI.REHBERID='+TabFatbaslik.FieldByName('REHBERID').AsString+'');
       EditButtonSevkAdresi.Hint :=Tablo.Query1.FieldByName('BILGI').AsString;
    end;
  end;
  //İrsaliyeden satışı faturasına dönüşüm yapıldıüşnda faturanoyu sıfırlaması için edit moduna geçirilir. before postta 0 atılır..
  if (Tur in [15,16])and(TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [0,1,11,21,31,51])and(length(TabFatbaslik.FieldByName('FATURANO').Asstring)<12) then
     TabFatbaslik.Edit;
  if IslemOp ='I' then begin
    Timer1.Interval := 1000;
    Timer1.Enabled := True ;
  end;
  //else if (IslemOp ='K')and(Tur in [15,16])then //Kopyalandıysa, efaturaya geçmiı mi diye bakalım
  //     EFaturaIslem(Tablo.EFaturami(FATBASLIK.FieldByName('REHBERID').AsInteger), True);
   // BtnBagliFatura.Visible := Tur = 11;
  BtnBelgeZarfi.Visible := (Tur = 11)and(TabFatbaslik.FieldByName('TIPI').AsInteger in [1, 6]); //al?? ve ithal
  if (Tur =12)and(IslemOp in ['E','K']) then //gelen fi?se ve ilk ekran ise
     Onceki_ACIK_KAPALI := False
  else
     Onceki_ACIK_KAPALI := TabFatbaslik.FieldByName('ACIK_KAPALI').AsBoolean;

   if (IslemOp ='E')and((ComboFatTipi.EditValue=4)or(ComboFatTipi.EditValue=7)or(ComboFatTipi.EditValue=8)) then  //serbest meslek makbuzu ise baçıtan stopaj? soral?m
       EditEkVergiClick(Self);
{efat}
   if TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [0,1,11,21,22,31,32,41,51] = False then begin
       ToolBarAlet.Enabled := False;

       BaslikPaneli.Enabled := False;
       DurumPaneli.Enabled := False;
       DovizPaneli.Enabled := False;
       ProjePanel.Enabled := False;

       cbFaturaTur.Enabled := False;
       ComboFatTipi.Enabled := False;
       cbStokDepo.Enabled := False;

       PanelEkAlanlar.Enabled := True;
   end;

  //EkstreDoviziDuzenle;
  //cbDovizCinsi.Properties.Items.Clear;
  //cbDovizCinsi.Properties.Items.add(CariDoviz);
  if (ComboRaporDovizi.EditValue<>null)and(ComboRaporDovizi.EditValue<>CariDoviz) then
      cbDovizCinsi.Properties.Items.add(ComboRaporDovizi.EditValue);
  if TabFatbaslik.FieldByName('DEMIRBASID').AsString <>'' then begin
    BEditDemirbas.Text := Tablo.AciklamaGetir('DEMIRBAS', 'DEMIRBASADI', TabFatbaslik.FieldByName('DEMIRBASID').AsInteger);
    BEditDemirbas.Tag := TabFatbaslik.FieldByName('DEMIRBASID').AsInteger;
  end;
  PageUst.ActivePageIndex := 0;

  if not Tablo.YetkiVarmi(2431,1,False) then begin  //tutarlar gözükmesin denirse;
    GridFaturaView.OptionsView.Footer := False;
    GridFaturaView.OptionsView.GroupFooters := gfInvisible;
    //for I := 0 to GridFatListeTview.ColumnCount-1 do
      //GridFatListeTview.Columns[i].Summary.Destroy;
    Miktarskontosu1.Visible := False;
    Yzdeskontosu1.Visible := False;
    utarDvzHesapla1.Visible := False;
  end;

  EditSRMMerkezi.visible := Tur in [10,11, 14,15];
  LabelSRMMerkezi.visible := EditSRMMerkezi.visible;
  ComboFIYAT_LISTESI.visible := (Tur in [10, 11, 12, 14, 15, 16])or((Tur=4)and(TabFatbaslik.FieldByName('TIPI').AsInteger=12)); //??k?? fi?i ve imha ise gerek??e almam?z laz?m
  LabelFIYAT_LISTESI.visible := ComboFIYAT_LISTESI.visible;
  if (Tur = 4)and(TabFatbaslik.FieldByName('TIPI').AsInteger = 12) then begin //??k?? fi?i ve imha ise gerek??e almam?z laz?m
      LabelFIYAT_LISTESI.Caption := 'Gerekçe';
      ComboFIYAT_LISTESI.Width := 288;
      Tablo.GENINI.ReadImageSection(Ops_RepImhaGerekce, Tablo.RepImhaGerekce.Properties.Items, False);
      ComboFIYAT_LISTESI.RepositoryItem := Tablo.RepImhaGerekce;
      lbSatici.caption := 'Sorumlu';
      cbSatici.Width := 288;
  end;

  //DateFATURA_GON_TARIHI.visible := False;//Tur in [11, 15];
  //LabelFATURA_GON_TARIHI.visible := DateFATURA_GON_TARIHI.visible;
  EditVade.visible := Tur in [10, 11, 14, 15, 16];
  LabelVade.visible := EditVade.visible;
  LabelFaturaDovizi.Visible := Tur in [11, 15];
  ComboFaturaDovizi.Visible := Tur in [11, 15];
  PageUst.ActivePageIndex := 0;
  // opsiyonlardan özelkod edit mi combo mu ayarlanması
  if Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Ozelkod1,0) = 0 then
     ComboOZELKOD.Visible := False
  else begin
     EditOZELKOD.Visible := False;
     Tablo.GENINI.ReadSection(Ops_FaturaOpsiyon_Ozelkod1_Liste, ComboOZELKOD.Properties, False);
  end;

  if Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Ozelkod2,0) = 0 then
     ComboOZELKOD2.Visible := False
  else begin
     EditOZELKOD2.Visible := False;
     Tablo.GENINI.ReadSection(Ops_FaturaOpsiyon_Ozelkod2_Liste, ComboOZELKOD2.Properties, False);
  end;
end;

procedure TFaturaWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TFaturaWizardDlg.GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry:TFDQuery;
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
        Tablo.TablodanSorguAc(7,'select DEGER from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and ANAHTAR='''+qry.FieldByName('KAYNAK').AsString+'''');
        Tablo.GeniniBaslat(Tablo.Query7.Fields[0].AsInteger);
      end;
      Qry.Close;
      Qry.Open;
    end;
  end;
end;

procedure TFaturaWizardDlg.GridDetayViewEditChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TFaturaWizardDlg.GridFaturaViewCanFocusRecord
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridFatura;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridFaturaView;
  AnaForm.pmGridStil.Tags.Values[GridFatura.Name] := 'FatSihirbazDetayGridi';
end;

procedure TFaturaWizardDlg.GridFaturaViewDblClick(Sender: TObject);
var Degismez:string;
begin
   if Kilit then exit;
   {09/03/2025 AO  alttaki komut yerine alttaki yapıldı..
    if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM FATURA WHERE YERID ='+FATURA.FieldByName('ID').AsString, [], []) then begin
        Tablo.UyariGoster(Uyari, DonusumYapilmis);
        Degismez:= 'ADET';
   end; }
   if Tablo.FaturaSatirSilmeKontrolu(TabFatbaslik.FieldByName('TUR').AsInteger, TabFatbaslik.FieldByName('FATURATARIH').AsDateTime, TabFatura)=False then
      Degismez:= 'ADET';

  { if (UTSKullanimda)and(Tablo.IzlemBildirimSayisi(FATBASLIK.FieldByName('TUR').AsInteger, 0, FATURA.FieldByName('ID').AsInteger, FATBASLIK.FieldByName('FATURATARIH').AsDateTime)>0) then begin
        // Tablo.UyariGoster(Uyari,BildirimYapilmis);
        Degismez:= 'ADET';
   end;


  //30.03.2022 AO
  if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM STOKIZLEME S1 WHERE SATIRID = '+FATURA.FieldByName('ID').AsString+' AND '+
                             ' EXISTS(SELECT * FROM STOKIZLEME S2 WHERE S2.DONUSID = S1.ID)',[],[]) then begin
     Tablo.UyariGoster(Uyari, IzlemKullanilmis);
     Abort;
  end;
             }

   Tablo.SatirGuncelle(TabFatura, Tur, TabFatbaslik.FieldByName('REHBERID').AsInteger, TabFatbaslik.FieldByName('FATURATARIH').AsDateTime, [Degismez]);
   Tablo.TablodanSorguAc(1,' select distinct DOVIZ_KURU from FATURA where FATBASID='+TabFatbaslik.FieldByName('ID').AsString);
   Tablo.Query1.FetchAll;
   if (Tablo.Query1.RecordCount=1)and(Tablo.Query1.fields[0].AsString<>TabFatbaslik.FieldByName('RAPORDOVIZ').AsString) then begin
       TabFatbaslik.edit;
       TabFatbaslik.FieldByName('RAPORDOVIZ').AsString := Tablo.Query1.fields[0].AsString;
       //FATBASLIK.Post;
   end;
end;



procedure TFaturaWizardDlg.GridFaturaViewEKIPMANPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  st  : Tstringlist;
  SQL : string;
begin
 SQL:='Select ER.ID, E.KOD,E.AD, E.DETAYBOLUMU , '+
      '  ER.SERINO,ER.ACIKLAMA, ILGILI=(select ADSOYAD=FIRMA from REHBER RP where RP.ID=ER.MUS_ILGILI ), '+
      '  LOKASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=ER.LOKASYONID) '+
      '  from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID '+
      '  Where  ER.REHBERID=' + TabFatura.FieldByName('REHBERID').AsString+' and E.AD like ''%<ara>%'' ';
  TabFatura.Edit;
  if AButtonIndex = 0 then try
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(ProjeSecimi,SQL, st, []) then begin
      TabFatura.FieldByName('EKIPMANID').AsString := st.Strings[0];
      TabFatura.Post;
    end;
  finally
    st.free;
  end else if AButtonIndex = 1 then begin
    TabFatura.FieldByName('EKIPMANID').AsString := '-1';
    TabFatura.Post;
  end;
end;

procedure TFaturaWizardDlg.GridFaturaViewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = VK_RETURN then
      KaydetTus.Click;
end;

class function TFaturaWizardDlg.FaturaSatiriUrunSec(AConn: TFDConnection;
  AFaturaID: Integer; AFatBaslikID: Integer; ARehberID: Integer): Boolean;
// 1) STOK_ESLESTIRME'de tek satir auto-match ara; bulunursa UPDATE FATURA.
//    Oncelik: ESLESME_TURU 1>4>3>0; AKTIF=1 + EKLEMETARIHI DESC tie-break.
// 2) Eslesme yoksa UStokHizmetAra'yi sade secim modunda (18=TabNo_DEMIRBAS)
//    acar; aktif sekmeye gore
// FATURA.TUR/URUNID/BIRIM'i SQL UPDATE ile yazar. Dataset refresh ile ilgili
// degildir; cagiran tarafa birakilir.
var
  AraDlg: TStokHizmetAraDlg;
  LTur, LUrunID, LBirim: Integer;
  LPageName: string;
  LQAuto: TFDQuery;
begin
  Result := False;
  if AFaturaID <= 0 then Exit;

  // 1) Auto-match: STOK_ESLESTIRME'de eslesme varsa dialog acmadan dogrudan
  //    UPDATE FATURA + Result := True. (FATURA'da trigger var; OUTPUT clause
  //    INTO olmadan kullanilamaz, bu yuzden RowsAffected kullaniyoruz.)
  if (AConn <> nil) and (ARehberID > 0) then begin
    LQAuto := TFDQuery.Create(nil);
    try
      LQAuto.Connection := AConn;
      LQAuto.SQL.Text :=
        'UPDATE F SET F.TUR = M.TIP, F.URUNID = M.URUNID ' +
        'FROM FATURA F ' +
        'CROSS APPLY ( ' +
        '  SELECT TOP 1 E.TIP, E.URUNID ' +
        '  FROM STOK_ESLESTIRME E ' +
        '  WHERE E.REHBERID = :R AND E.AKTIF = 1 AND ( ' +
        '    (E.ESLESME_TURU IN (0,1) AND ISNULL(F.IZLEMEKODU, N'''') <> N'''' ' +
        '      AND E.GELEN_KOD = F.IZLEMEKODU) ' +
        '    OR (E.ESLESME_TURU = 4 AND E.GELEN_AD = F.ACIKLAMA) ' +
        '    OR (E.ESLESME_TURU = 3 AND ISNULL(E.GELEN_AD, N'''') <> N'''' ' +
        '      AND F.ACIKLAMA LIKE N''%'' + E.GELEN_AD + N''%'') ' +
        '  ) ' +
        '  ORDER BY ' +
        '    CASE E.ESLESME_TURU ' +
        '      WHEN 1 THEN 1 WHEN 4 THEN 2 WHEN 3 THEN 3 WHEN 0 THEN 4 ' +
        '      ELSE 99 END, ' +
        '    E.EKLEMETARIHI DESC ' +
        ') M ' +
        'WHERE F.ID = :FID';
      LQAuto.ParamByName('R').AsInteger := ARehberID;
      LQAuto.ParamByName('FID').AsInteger := AFaturaID;
      LQAuto.ExecSQL;
      if LQAuto.RowsAffected > 0 then begin
        Result := True;
        Exit;
      end;
    finally
      LQAuto.Free;
    end;
  end;

  // 2) Auto-match yok -> manuel secim dialogu
  Application.CreateForm(TStokHizmetAraDlg, AraDlg);
  try
    AraDlg.FatBasID :=  AFatBaslikID;
    AraDlg.RehberId :=  ARehberID;
    AraDlg.TabDetayGiris := nil;
    AraDlg.TabGiris := nil;
    AraDlg.KalanAdetGetir := False;
    AraDlg.stokhizmetaracagirantur := 18; // TabNo_DEMIRBAS = sade secim modu

    if AraDlg.ShowModal = mrOk then begin
      LTur := -1; LUrunID := 0; LBirim := 0;
      if AraDlg.PageControl1.ActivePage <> nil then
        LPageName := AraDlg.PageControl1.ActivePage.Name
      else
        LPageName := '';

      if SameText(LPageName, 'SheetHizmet') then begin
        if (AraDlg.TabHizmetListe <> nil) and AraDlg.TabHizmetListe.Active and
           (not AraDlg.TabHizmetListe.IsEmpty) then begin
          LTur := 0;
          LUrunID := AraDlg.TabHizmetListe.FieldByName('ID').AsInteger;
          if AraDlg.TabHizmetListe.FindField('BIRIM') <> nil then
            LBirim := AraDlg.TabHizmetListe.FieldByName('BIRIM').AsInteger;
        end;
      end else begin // SheetStok veya default
        if (AraDlg.TabStokListe <> nil) and AraDlg.TabStokListe.Active and
           (not AraDlg.TabStokListe.IsEmpty) then begin
          LTur := 1;
          LUrunID := AraDlg.TabStokListe.FieldByName('ID').AsInteger;
          if AraDlg.TabStokListe.FindField('BIRIM') <> nil then
            LBirim := AraDlg.TabStokListe.FieldByName('BIRIM').AsInteger;
        end;
      end;

      if LTur >= 0 then begin
        Veritabani.BasitKomutÇalıştır(AConn,
          'UPDATE FATURA SET TUR=&T, URUNID=&U, BIRIM=&B WHERE ID=&FID',
          ['&T', '&U', '&B', '&FID'],
          [LTur, LUrunID, LBirim, AFaturaID]);
        Result := True;

        // Manuel secimi STOK_ESLESTIRME'ye yaz: gelecek faturalarda otomatik
        // eslesme icin. Cari bilinmiyorsa atla. IZLEMEKODU varsa ESLESME_TURU=1
        // (Urun No), yoksa ESLESME_TURU=4 (Ad Tam). Mevcutsa update, yoksa insert.
        if ARehberID > 0 then begin
          var LSatirQ: TFDQuery := TFDQuery.Create(nil);
          try
            LSatirQ.Connection := AConn;
            LSatirQ.SQL.Text :=
              'SELECT ISNULL(IZLEMEKODU, N'''') AS KOD, ' +
              '       ISNULL(ACIKLAMA, N'''') AS AD ' +
              'FROM FATURA WHERE ID = :FID';
            LSatirQ.ParamByName('FID').AsInteger := AFaturaID;
            LSatirQ.Open;
            if not LSatirQ.Eof then begin
              var LGelenKod: string := Trim(LSatirQ.Fields[0].AsString);
              var LGelenAd: string := Trim(LSatirQ.Fields[1].AsString);
              LSatirQ.Close;

              var LMergeSQL: TFDQuery := TFDQuery.Create(nil);
              try
                LMergeSQL.Connection := AConn;
                if LGelenKod <> '' then begin
                  LMergeSQL.SQL.Text :=
                    'IF EXISTS (SELECT 1 FROM STOK_ESLESTIRME ' +
                    '  WHERE REHBERID=:R AND ESLESME_TURU=1 AND GELEN_KOD=:KOD) ' +
                    '  UPDATE STOK_ESLESTIRME SET TIP=:T, URUNID=:U, ' +
                    '    GELEN_AD=:AD, AKTIF=1, DEGISTIREN=:KUL, ' +
                    '    DEGISTIRMETARIHI=GETDATE() ' +
                    '  WHERE REHBERID=:R AND ESLESME_TURU=1 AND GELEN_KOD=:KOD ' +
                    'ELSE ' +
                    '  INSERT INTO STOK_ESLESTIRME ' +
                    '    (REHBERID, GELEN_KOD, GELEN_AD, ESLESME_TURU, TIP, ' +
                    '     URUNID, AKTIF, EKLEYEN, EKLEMETARIHI) ' +
                    '  VALUES (:R, :KOD, :AD, 1, :T, :U, 1, :KUL, GETDATE())';
                  LMergeSQL.ParamByName('R').AsInteger := ARehberID;
                  LMergeSQL.ParamByName('KOD').AsString := LGelenKod;
                  LMergeSQL.ParamByName('AD').AsString := LGelenAd;
                  LMergeSQL.ParamByName('T').AsInteger := LTur;
                  LMergeSQL.ParamByName('U').AsInteger := LUrunID;
                  LMergeSQL.ParamByName('KUL').AsInteger := StrToIntDef(Kullanan, 0);
                  LMergeSQL.ExecSQL;
                end else if LGelenAd <> '' then begin
                  LMergeSQL.SQL.Text :=
                    'IF EXISTS (SELECT 1 FROM STOK_ESLESTIRME ' +
                    '  WHERE REHBERID=:R AND ESLESME_TURU=4 AND GELEN_AD=:AD) ' +
                    '  UPDATE STOK_ESLESTIRME SET TIP=:T, URUNID=:U, AKTIF=1, ' +
                    '    DEGISTIREN=:KUL, DEGISTIRMETARIHI=GETDATE() ' +
                    '  WHERE REHBERID=:R AND ESLESME_TURU=4 AND GELEN_AD=:AD ' +
                    'ELSE ' +
                    '  INSERT INTO STOK_ESLESTIRME ' +
                    '    (REHBERID, GELEN_AD, ESLESME_TURU, TIP, URUNID, ' +
                    '     AKTIF, EKLEYEN, EKLEMETARIHI) ' +
                    '  VALUES (:R, :AD, 4, :T, :U, 1, :KUL, GETDATE())';
                  LMergeSQL.ParamByName('R').AsInteger := ARehberID;
                  LMergeSQL.ParamByName('AD').AsString := LGelenAd;
                  LMergeSQL.ParamByName('T').AsInteger := LTur;
                  LMergeSQL.ParamByName('U').AsInteger := LUrunID;
                  LMergeSQL.ParamByName('KUL').AsInteger := StrToIntDef(Kullanan, 0);
                  LMergeSQL.ExecSQL;
                end;
              finally
                LMergeSQL.Free;
              end;
            end else
              LSatirQ.Close;
          finally
            LSatirQ.Free;
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(AraDlg);
  end;
end;

procedure TFaturaWizardDlg.GridFaturaViewKOD1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
//   Paylasilan FaturaSatiriUrunSec'i cagirir, sonra TabFatura'yi refresh eder.
begin
  if (not TabFatura.Active) or TabFatura.IsEmpty then Exit;
  if FaturaSatiriUrunSec(Tablo.FDCnn,
       TabFatura.FieldByName('ID').AsInteger,
       TabFatbaslik.FieldByName('ID').AsInteger,
       TabFatbaslik.FieldByName('REHBERID').AsInteger) then
    TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.GridFaturaViewCellClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
// KOD hucresine tek tikla: button-edit her zaman gozukmedigi icin cell
// click ile dialogu acariz.
begin
  if AButton <> mbLeft then Exit;
  if ACellViewInfo = nil then Exit;
  if ACellViewInfo.Item = GridFaturaViewKOD1 then begin
    GridFaturaViewKOD1PropertiesButtonClick(nil, 0);
    AHandled := True;
  end;
end;

procedure TFaturaWizardDlg.cxGrid1DBTableView1CanFocusRecord
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := cxGrid1;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := cxGrid1DBTableView1;
  AnaForm.pmGridStil.Tags.Values[cxGrid1.Name] := 'FaturaPlanOdemeGridi';
end;

procedure TFaturaWizardDlg.cxGrid1DBTableView1MASRAFIDGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
var AText: string);
begin
  // if Sender<>GridFaturaViewMASRAFAD then exit;
  if ARecord.Values[cxGrid1DBTableView1MASRAFID.Index] > 0 then
    AText := Tablo.AciklamaGetir('MASRAFGELIR', 'AD',
      ARecord.Values[cxGrid1DBTableView1MASRAFID.Index]);
end;

procedure TFaturaWizardDlg.GridFaturaViewMASRAFADGetDisplayText
  (Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
begin
{  if ARecord.Values[GridFaturaViewMASRAFAD.Index] > 0 then
    AText := Tablo.AciklamaGetir('MASRAFGELIR', 'AD',
      ARecord.Values[GridFaturaViewMASRAFAD.Index]); }
end;

procedure TFaturaWizardDlg.GridFaturaViewMASRAFADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
  i: SmallInt;
begin
  if Tur in [3,4,14 .. 19] then
    i := 1
  else
    i := 0;
  if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
    if TabFatura.State = dsBrowse then
      TabFatura.Edit;
    TabFatura.FieldByName('MASRAFID').AsString := MASRAFID;
    TabFatura.Post;
  end;
end;

procedure TFaturaWizardDlg.GridFaturaViewMERKEZIDGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
begin
  if ARecord.Values[GridFaturaViewMERKEZID.Index] > 0 then
    AText := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI',
      ARecord.Values[GridFaturaViewMERKEZID.Index]);
end;

procedure TFaturaWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TFaturaWizardDlg.Hesapla1Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec sp_FaturaEkMaliyetHesapla &FatbasID',['&FatbasID'],[TabFatbaslik.FieldByName('ID').AsInteger]);
  TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.IptalTusClick(Sender: TObject);
begin
  if TabFatbaslik.State in [dsInsert, dsEdit] then
     TabFatbaslik.Cancel;
  if TabFatura.State in [dsInsert, dsEdit] then
     TabFatura.Cancel;
end;

procedure TFaturaWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TFaturaWizardDlg.LabelAdClick(Sender: TObject);
begin
  Tablo.RehberSihirbazBaslat(0, TabFatbaslik.FieldByName('REHBERID').AsInteger, -100, -100,  False);
  FirmaBilgileri;
end;

procedure TFaturaWizardDlg.EFaturaIslem(EFatura:smallint; NoSifirla:Boolean);
begin
   TabFatbaslik.Edit;

   if (Tur=14)and(EIrsaliyeKullanimda) then //e-irsaliye kullanımda ise
      TabFatbaslik.FieldByName('EFATURADURUM').AsInteger:=51  // 51:e-irsaliye
   else if (Tur=15)and(Tipi=6)and(EFaturaIhracat=False) then //e-fatura kullan?mda ama e-ihracat fat kullan?mda de?ilse drekt kağıt gelsin
      TabFatbaslik.FieldByName('EFATURADURUM').AsInteger:=0
   else
      TabFatbaslik.FieldByName('EFATURADURUM').AsInteger:=EFatura;
/// senaryoyu set edelim
   if TabFatbaslik.FieldByName('SENARYO').AsInteger < 1 then begin
       if (TabFatbaslik.FieldByName('TUR').AsInteger=15)or((TabFatbaslik.FieldByName('TUR').AsInteger=14)and(EIrsaliyeKullanimda)) then begin //herhangi bir senaryo uoksa
          if TabFatbaslik.FieldByName('TIPI').AsInteger=26 then
             TabFatbaslik.FieldByName('SENARYO').AsInteger:= 3 //giden fat ve ihracat ise senaryo ihracat olmal?
          else
             TabFatbaslik.FieldByName('SENARYO').AsInteger:= Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Senaryo,1);

          //earşiv bireysel ve kurumsal ise senaryo ilaç cihaz olamaz
          if (TabFatbaslik.FieldByName('SENARYO').AsInteger=8)and
             ((TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [11, 31])or((TabFatbaslik.FieldByName('TUR').AsInteger=14)and(EIrsaliyeKullanimda))) then
              TabFatbaslik.FieldByName('SENARYO').AsInteger:= 0;
       end
       else
          TabFatbaslik.FieldByName('SENARYO').AsInteger := 0;
   end;
////
   if ((Tur=14)and(EIrsaliyeKullanimda)) or (Tur=15) then begin
      if NoSifirla then
         TabFatbaslik.FieldByName('FATURANO').AsString :='0';
   end;     (*   if EFaturaKullanimda=0 then
   FATBASLIK.FieldByName('EFATURADURUM').AsInteger:=0
   else begin
      if (EFatura>0)or(Tipi=-1) then begin
            if EFatura=1 then
               Labelsorgu.Caption := 'Online sorgu'
            else if EFatura=1 then
               Labelsorgu.Caption := 'Veritabanı sorgu'
            else
               Labelsorgu.Caption := '';

            if FATBASLIK.FieldByName('EFATURADURUM').AsInteger = 0 then begin //durumu 2 ise 1 yapmasın
               FATBASLIK.FieldByName('VNO').AsString := StringReplace(FATBASLIK.FieldByName('VNO').AsString, ' ','',[rfReplaceAll]);
               if Length(FATBASLIK.FieldByName('VNO').AsString)=10 then
                  FATBASLIK.FieldByName('EFATURADURUM').AsInteger:= 1
               else if Length(FATBASLIK.FieldByName('VNO').AsString)=11 then
                  FATBASLIK.FieldByName('EFATURADURUM').AsInteger:= 21;
            end;

            FATBASLIK.FieldByName('SENARYO').AsInteger:= Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Senaryo,1);
            if NoSifirla then
               FATBASLIK.FieldByName('FATURANO').AsString :='0';
            //BtnEfatura.caption := 'E-Fatura';
        end; {else if (FATBASLIK.FieldByName('EFATURADURUM').AsString<>'0')or(IslemOp='K') then begin
            //FATBASLIK.Edit;
            //FATBASLIK.FieldByName('EFATURADURUM').AsInteger := EFaturaKullanimda; // 0:kağıt 1:efat 11:e-ar?iv
            case EFaturaKullanimda of
              1: FATBASLIK.FieldByName('EFATURADURUM').AsInteger := 0;
              11: begin
                    FATBASLIK.FieldByName('VNO').AsString := StringReplace(FATBASLIK.FieldByName('VNO').AsString, ' ','',[rfReplaceAll]);
                    if Length(FATBASLIK.FieldByName('VNO').AsString)=10 then
                       FATBASLIK.FieldByName('EFATURADURUM').AsInteger:= 11
                    else if Length(FATBASLIK.FieldByName('VNO').AsString)=11 then
                       FATBASLIK.FieldByName('EFATURADURUM').AsInteger:= 31;
                    FATBASLIK.FieldByName('FATURANO').AsString :='0';
                  end;
            end;
        end;
   end; *)
end;

procedure TFaturaWizardDlg.LabelKodClick(Sender: TObject);
var
  Id: Integer;
begin
    {dönüştrılmüş ise değişemez}
   if TabFatbaslik.FieldByName('DURUMNEREYE').AsString <> '' then begin
      ShowMessage(DonusturulmusDegisemez);
      Abort;
   end;


  if Tur=119 then
     showMessage(KonsinyeDeismez)
  else
    if GetKeyState(VK_CONTROL) < 0 then begin
        Id := Tablo.RehberAra_IDGetir(-1);
        if Id > 0 then begin
          RehberId := Id;
          if TabFatbaslik.State = dsBrowse then
             TabFatbaslik.Edit;
          FATBASLIKNewRecord(TabFatbaslik);
          TabFatbaslik.FieldByName('REHBERID').AsInteger := RehberId;
          Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' order by VARSAYILAN desc');
          TabFatbaslik.FieldByName('REHBERILETID').AsInteger := tablo.Query1.Fields[0].AsInteger;

          case Tur of
           14 :EFaturaIslem(0, True);//e-irsaliye ise direk yeni olarak giriş yapılır
           15 :EFaturaIslem(Tablo.EFaturami(Id,CarideEFatura,TabFatbaslik.FieldByName('VNO').AsString, TabFatbaslik.FieldByName('TIPI').AsInteger), True);
          end;
          FirmaBilgileri;
          if Tur in [14, 15, 16, 119] then begin
            Tablo.FaturaBaslik(TabFatbaslik,RehberId);
          end;
    end;
  end;
end;

procedure TFaturaWizardDlg.LabelPoliklinikClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_FaturaOpsiyon_Poliklinik);
end;

procedure TFaturaWizardDlg.LabelReferansClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_FaturaOpsiyon_Referans);
end;

procedure TFaturaWizardDlg.lbDetaySablonClick(Sender: TObject);
begin
  if trim(ComboBolum.Text) = '' then begin
    Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz), PChar(Uyari),
      MB_OK + MB_ICONWARNING);
    Abort;
  end;
  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := Tablo.FaturaDetaySablonTipiBul(Tur);
  RehberAyarDlg.Bolum := ComboBolum.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  DetayTablosuAc;
end;

procedure TFaturaWizardDlg.LbIrsaliyeBilgileriClick(Sender: TObject);
var
  sts:TStringlist;
  AYeri,AYerID,RehID:Integer;
  ABelgeno:string;
begin
  if TabFatbaslik.State=dsInsert then
     TabFatbaslik.Post;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := '';
  Tablo.Query1.SQL.Add(' select distinct    ');
  Tablo.Query1.SQL.Add(' KAYNAKTUR = case   ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407) then 9   ');
  Tablo.Query1.SQL.Add(' 	when YERI = 408 then 10         ');
  Tablo.Query1.SQL.Add(' 	when YERI in (409,410) then 19  ');
  Tablo.Query1.SQL.Add(' 	when YERI = 411 then 14         ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then -99 ');
  Tablo.Query1.SQL.Add(' end, ');
  Tablo.Query1.SQL.Add(' KAYNAKBELGENO=case ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407,409,410) then (select SIPARISNO from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID=F.YERID)) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (408,411) then (select FATURANO from FATBASLIK where ID=(select FATBASID from FATURA where ID=F.YERID))               ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then (select TEKLIFNO from TEKLIF where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))             ');
  Tablo.Query1.SQL.Add(' end, ');
  Tablo.Query1.SQL.Add(' KAYNAKID=case      ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407,409,410) then (select SIPARISID from SIPARISDETAY where ID=F.YERID ) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (408,411) then (select FATBASID from FATURA where ID=F.YERID )                ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then (SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID )           ');
  Tablo.Query1.SQL.Add(' end ');
  case TabFatbaslik.FieldByName('TUR').AsInteger of
    9,19:begin
      Tablo.Query1.SQL.Add(' from FATURA F ');
      Tablo.Query1.SQL.Add(' where SIPARISID='+TabFatbaslik.FieldByName('ID').AsString+' and ');
      Tablo.Query1.SQL.Add(' 	YERI between 406 and 413 ');
    end;
  else
    Tablo.Query1.SQL.Add(' from FATURA F  ');
    Tablo.Query1.SQL.Add(' where FATBASID='+TabFatbaslik.FieldByName('ID').AsString+' and ');
    Tablo.Query1.SQL.Add(' 	YERI between 406 and 413 ');
  end;
  Tablo.Query1.Open;
  Tablo.Query1.FetchAll;
  case Tablo.Query1.RecordCount of
    0: Abort;
    1: begin
      AYeri := Tablo.Query1.Fields[0].AsInteger;
      AYerID:= Tablo.Query1.Fields[2].AsInteger;
      ABelgeno:= Tablo.Query1.Fields[1].AsString;
    end;
  else
    try
      sts := TStringlist.Create;
      if Tablo.ListedenBilgiGetir('Kaynak Seçimi',Tablo.Query1.SQL.Text,sts,[Tablo.RepKasaTurleriReadOnly,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],'FaturalarKaynakSecimi')then begin
        AYeri := StrToInt(sts[0]);
        AYerID:= StrToInt(sts[2]);
        ABelgeno:= sts[1];
      end;
    finally
      sts.Free;
    end;
  end;
  if AYeri=-99 then begin
    Tablo.TablodanSorguAc(2,'select * from TEKLIF where ID='+IntToStr(AYerID));
    RehID := Tablo.Query2.FieldByName('REHBERID').AsInteger;
  end else
    RehID := TabFatbaslik.FieldByName('REHBERID').AsInteger;
  AnaForm.GormeDialogCagir(AYerID,AYeri,RehID,0,Tablo.GENINI.BugunTrh,ABelgeno);

end;

procedure TFaturaWizardDlg.MalFazlasDzenle1Click(Sender: TObject);
var
  MF: Variant;
  ToplamAdet: Extended;
begin
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.create.CurrencyEdit(FWMalFazlasiGir, @MF,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))) = mrOk then
  begin
    if StrToIntDef(MF, -1) < 0 then
      Abort;
    ToplamAdet := TabFatura.FieldByName('MF').AsFloat + TabFatura.FieldByName('ADET').AsFloat;
    if TabFatura.State = dsBrowse then
      TabFatura.Edit;
    TabFatura.FieldByName('MF').AsFloat := MF;
    TabFatura.FieldByName('ADET').AsFloat := ToplamAdet - MF;
    TabFatura.Post;
  end;
end;

procedure TFaturaWizardDlg.MemoFatAdresKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   AdresDegisti := True;
end;

procedure TFaturaWizardDlg.MenuExcelDosyaSecClick(Sender: TObject);
begin
    if TabFatbaslik.state in [dsEdit, dsInsert] then
       TabFatbaslik.Post;
    Excel2FaturaSatir(TabFatbaslik.FieldByName('ID').AsInteger);
    TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.MenuItem1Click(Sender: TObject);
var
  BzDlg:TBelgeZarflariDlg;
begin
  Application.CreateForm(TBelgeZarflariDlg,BzDlg);
  BzDlg.ZarfID := Tablo.BelgeZarfiZarfSecimi(0);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set ZARFID=&Zid where ID=&FBid'
                                ,['&Zid','&FBid'],[BzDlg.ZarfID,TabFatbaslik.FieldByName('ID').AsInteger]);
  BzDlg.ShowModal;
  FreeAndNil(BzDlg);
end;

procedure TFaturaWizardDlg.MenuItem2Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set ZARFID=0 where ID=&FBid',['&FBid'],[TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.MenuItem3Click(Sender: TObject);
var
  BzDlg:TBelgeZarflariDlg;
begin
  Application.CreateForm(TBelgeZarflariDlg,BzDlg);
  BzDlg.ShowModal;
  FreeAndNil(BzDlg);
end;

procedure TFaturaWizardDlg.MenuKagitIrsaliyeyeCevirClick(Sender: TObject);
begin
   TabFatbaslik.Edit;
   if TabFatbaslik.FieldByName('EFATURADURUM').AsInteger = 0 then
      TabFatbaslik.FieldByName('EFATURADURUM').AsInteger := 51
   else if TabFatbaslik.FieldByName('EFATURADURUM').AsInteger = 51 then
      TabFatbaslik.FieldByName('EFATURADURUM').AsInteger := 0;
   TabFatbaslik.Post;
end;

procedure TFaturaWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TFaturaWizardDlg.MenuKolonEslestirClick(Sender: TObject);
begin
   ///
    tablo.GeniniBaslat(Ops_Fatura_ExcelEslesme);
end;

procedure TFaturaWizardDlg.MenuMusTreeDblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TFaturaWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TFaturaWizardDlg.MenuTipiIadeClick(Sender: TObject);
begin
    TabFatbaslik.Edit;
    if TabFatbaslik.FieldByName('TIPI').AsInteger = 1 then
       TabFatbaslik.FieldByName('TIPI').AsInteger := 2
    else
       TabFatbaslik.FieldByName('TIPI').AsInteger := 1;
    TabFatbaslik.Post;
end;

procedure TFaturaWizardDlg.N52Click(Sender: TObject);
var
  Yuzde: Variant;

  IskTipi, s, Komut: String;
begin
  IskTipi := TMenuItem(Sender).Hint;
  if TMenuItem(Sender).Tag < 0 then
  begin // özel
    if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.create.CurrencyEdit(FWYuzdesiniGirin, @Yuzde,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))) <> mrOk then
      Abort;
    Yuzde := StringReplace(Yuzde, ',', FormatSettings.Decimalseparator, [rfReplaceAll]);
    Yuzde := StringReplace(Yuzde, '.', FormatSettings.Decimalseparator, [rfReplaceAll]);
    if (Yuzde <= 0.0)or(Yuzde > 100.0)  then begin
       ShowMessage(SifirYuzArasinda);
       Abort;
    end;
    // Yuzde := StringReplace(Yuzde, ',', '.', []);
  end else
    Yuzde := IntToStr(TMenuItem(Sender).Tag);
  s := Yuzde;
  if IskTipi = 'İskonto1' then begin
    Komut := ' update FATURA set ISKONTO=&Yuzde, TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 ';
    if DovizTakibi then
       Komut := Komut+',DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0';
  end else if IskTipi = 'İskonto2' then begin
    Komut:=' update FATURA set ISKONTO2=&Yuzde, TUTAR=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 ';
    if DovizTakibi then
       Komut := Komut+',DOVIZ_TUTARI=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0';
  end;
  Komut := Komut+' where FATBASID=&id ';
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, Komut, ['&Yuzde', '&id'], [StrToFloatDef(trim(Yuzde), 0), TabFatbaslik.Fields[0].AsInteger]);
  FaturaTutarHesapla(True);
  TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.PageUstChange(Sender: TObject);
begin
   if PageUst.Pages[PageUst.ActivePageIndex].Name = 'SheetGenotip' then begin
      EditAd.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFatbaslik.FieldByName('REHBERID_HASTA').AsInteger);
      if TabFatbaslik.FieldByName('REHBERID_HASTA').AsString<>'' then begin
         Tablo.TablodanSorguAc(1,'SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA '+
         ' AND RA.YERI=RB.YERI WHERE RB.YER_ID='+TabFatbaslik.FieldByName('REHBERID_HASTA').AsString+' AND RA.VARSAYILAN=22');
         if not Tablo.Query1.IsEmpty then
            EditTCKN.Text := Tablo.Query1.Fields[0].AsString;
      end;
      EditKimlikId.Text := TabFatbaslik.FieldByName('GNTP_KIMLIKID').AsString;
      EditSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFatbaslik.FieldByName('REHBERID_SORUMLU').AsInteger);
      EditKurumu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFatbaslik.FieldByName('REHBERID_KURUM').AsInteger);
     EditPoliklinik.Text := Tablo.GENINI.AnahtarGetir(-25000,  TabFatbaslik.FieldByName('POLIKLINIKID').AsInteger, -1, '');
      EditDoktor.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFatbaslik.FieldByName('REHBERID_DOKTOR').AsInteger);
      EditReferans.Text :=  Tablo.GENINI.AnahtarGetir(-25002,  TabFatbaslik.FieldByName('REFERANSID').AsInteger,-1,'');
      EditGonderen.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFatbaslik.FieldByName('REHBERID_GONDEREN').AsInteger);
   end
   else if (EkAlanOlustu)and(PageUst.Pages[PageUst.ActivePageIndex].Name = 'SheetEkAlanlar')and(TabFatbaslik.FieldByName('ID').AsInteger < 1) then
           TabFatbaslik.post;

end;

procedure TFaturaWizardDlg.PlanlamaEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
  TabPlan.Close;
  TabPlan.Params[0].Value := TabFatbaslik.FieldByName('ID').AsInteger;
  TabPlan.Open;
end;

procedure TFaturaWizardDlg.PopupMenuEBelgePopup(Sender: TObject);
begin
   if MenuKagitIrsaliyeyeCevir=nil then
      exit;
   if TabFatbaslik.FieldByName('EFATURADURUM').AsInteger = 0 then
      MenuKagitIrsaliyeyeCevir.Caption := 'E-İrsaliyeye çevir'
   else if TabFatbaslik.FieldByName('EFATURADURUM').AsInteger = 51 then
      MenuKagitIrsaliyeyeCevir.Caption := 'Kağıt İrsaliyeye çevir'
   else
      MenuKagitIrsaliyeyeCevir.Caption := '';
end;

procedure TFaturaWizardDlg.PopupMenuFaturaPopup(Sender: TObject);
begin
   UTSdenAdetleriKontrolEtMenu.Visible := TabFatbaslik.FieldByName('TUR').AsInteger in [10,11,14,15];
end;

procedure TFaturaWizardDlg.PopupMenuTipDegisPopup(Sender: TObject);
begin
   if TabFatbaslik.FieldByName('TIPI').AsInteger=1 then
      MenuTipiIade.Caption := 'Tipini İade Yap'
   else
      MenuTipiIade.Caption := 'Tipini Alış/Satışı Yap'
end;

procedure TFaturaWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TFaturaWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabloNo, TabFatbaslik.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TFaturaWizardDlg.SatirEkleClick(Sender: TObject);
begin
  if TabFatbaslik.FieldByName('TIPI').AsInteger in [2,3] then //iade
     FaturadanSatirGetir(Sender)  //iade
  else
     SatirIslem(Sender)
end;

procedure TFaturaWizardDlg.SatirIslem(Sender: TObject);
begin
  if TabFatbaslik.State in [dsEdit, dsInsert] then begin
     TabFatbaslik.Post;
     TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
  end;

  if (Tur in [14, 15, 16] )and(cbStokDepo.EditValue<>1) then begin //ilk satır eklendiğinde, konsinye ıçıkış deposu ise sadece dönüşümden ıçıkış yapılmalıdır
     Tablo.TablodanSorguAc(1,'select VARSAYILAN from DEPOLAR where ID='+IntToStr(cbStokDepo.EditValue));
     if (not Tablo.Query1.IsEmpty)and(Tablo.Query1.Fields[0].AsInteger=7) then begin
         ShowMessage('Konsinye çıkışı, dönüşüm butonu kullanılmalı!');
         Exit
     end;
  end;


  if AraDlg = nil then
     Application.CreateForm(TStokHizmetAraDlg, AraDlg);
  AraDlg.FatBasID := TabFatbaslik.FieldByName('ID').AsInteger;
  AraDlg.RehberId := TabFatbaslik.FieldByName('REHBERID').AsInteger;
  AraDlg.TabDetayGiris := TabFatura;
  AraDlg.TabGiris := TabFatbaslik;
  AraDlg.KalanAdetGetir := True;
  AraDlg.stokhizmetaracagirantur := TabFatbaslik.FieldByName('TUR').AsInteger;

  if ComboFatTipi.EditValue=5 then begin
     AraDlg.PageControl1.ActivePage := AraDlg.SheetHizmet;
     AraDlg.SheetStok.tabvisible := False;
     AraDlg.PageControl1Change(Sender);
  end;


  if Tur in [0, 3, 8, 10, 11, 12] then begin
     AraDlg.GirisCikis := FWGiris;
     // AraDlg.FiyatlariGetir:=False;
     AraDlg.KalmayanCheckGoster := False;
  end else begin
     AraDlg.GirisCikis := FWCikis;
     AraDlg.FiyatlariGetir := True;
  end;
  AraDlg.cbFiyatAdi.EditValue := TabFatbaslik.FieldByName('FIYAT_LISTESI').Value;
  AraDlg.cbFiyatAdi.Enabled := False;

  AraDlg.cbStokDepo.EditValue := cbStokDepo.EditValue;
  AraDlg.combosube.EditValue := combosube.EditValue;
//  if Modul.Stok then begin
    AraDlg.cbStokDepo.EditValue := cbStokDepo.EditValue;
    //if FATURA.Recordcount < 1 then
    //   AraDlg.cbStokDepo.Enabled := True // daha ?nce depo se?imi yapılmam??, yapılabilir
    //else // girilmiş stok işlemi var mı?
    //   AraDlg.cbStokDepo.Enabled := not Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from FATURA where FATBASID =  &FId and TUR=1', ['&FId'], [FATBASLIK.FieldByName('ID').AsInteger]);
//  end;
  AraDlg.ShowModal;
  EditKulKur.Visible := ComboRaporDovizi.Text <> CariDoviz;
  cbStokDepo.EditValue := AraDlg.cbStokDepo.EditValue;
  //cbStokDepo.Enabled := FATURA.Recordcount < 1;
  FaturaTutarHesapla(True);
end;

procedure TFaturaWizardDlg.TekSatirKampanyaDuzenle(TabFaturaID:integer);
var
  HataMesaji:string;
  TekrarSayisi,TempTS:integer;
  TSAtandi:Boolean;
begin
  if TabFatura.Locate('ID',TabFaturaID,[]) then begin
    Tablo.TablodanSorguAc(7,'select F.KAMPANYAID,K.TUR from FATURA F inner join KAMPANYA K on F.KAMPANYAID=K.ID where F.ID='+IntToStr(TabFaturaID));
    Tablo.Query7.FetchAll;
    if (Tablo.Query7.RecordCount=1)and(Tablo.Query7.FieldByName('TUR').AsInteger=1) then begin
      Tablo.TablodanSorguAc(8,'select * from KAMPANYAKOSUL where TUR in (10,20,30) and KAMPANYAID = '+Tablo.Query7.FieldByName('KAMPANYAID').AsString);
      TSAtandi := False;
      TekrarSayisi := 0;
      while not Tablo.Query8.Eof do begin //her koşul satırı için
        case Tablo.Query8.FieldByName('TUR').AsInteger of
          10:begin //Birim Fiyat(Se?ilen Satır)	10
            TempTS := Trunc(TabFatura.FieldByName('BIRIMFIYAT').AsFloat/StrToFloat(Tablo.Query8.FieldByName('KOSUL').AsString));
            if (not TSAtandi)or(TekrarSayisi>TempTS) then
              TekrarSayisi := TempTS;
            TSAtandi := True;
          end;
          20:begin //Tutar(Se?ilen Satır)	20
            //burada direkt tutar? alam?yoruz.. kampanya uyguland???nda iskonto değişiyor. iskonto uygulanmam?? haline bakmam?z laz?m. 2. kez kampanya uygulad???m?zda sonu? katlanarak artmas?n diye..
            TempTS := Trunc((TabFatura.FieldByName('ADET').Value
                                 * TabFatura.FieldByName('BIRIMFIYAT').Value)
                                 / StrToFloat(Tablo.Query8.FieldByName('KOSUL').AsString));
            if (not TSAtandi)or(TekrarSayisi>TempTS) then
              TekrarSayisi := TempTS;
            TSAtandi := True;
          end;
          30:begin //Miktar(Se?ilen Satır)	30
            TempTS := Trunc(TabFatura.FieldByName('ADET').AsFloat/StrToFloat(Tablo.Query8.FieldByName('KOSUL').AsString));
            if (not TSAtandi)or(TekrarSayisi>TempTS) then
              TekrarSayisi := TempTS;
            TSAtandi := True;
          end;
        end;
        Tablo.Query8.Next;
      end;
      if TekrarSayisi>0 then begin//uygulanacak kampanya var ise kampanya sonuc i?indeki her bir satır i?in;
        Tablo.TablodanSorguAc(8,'select * from KAMPANYASONUC where KAMPANYAID = '+Tablo.Query7.FieldByName('KAMPANYAID').AsString);
        Tablo.Query8.First;
        while not Tablo.Query8.Eof do begin //her sonu? i?in;
          case Tablo.Query8.FieldByName('TUR').AsInteger of
            10:begin //İskonto
              if TabFatura.State = dsBrowse then
                TabFatura.Edit;
              TabFatura.FieldByName('ISKONTO').AsInteger := StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
              TabFatura.FieldByName('ISKONTO2').AsInteger := 0;
            end;
            40:begin //Mal Fazlas? Ekle
              if TabFatura.State = dsBrowse then
                TabFatura.Edit;
              TabFatura.FieldByName('MF').AsInteger := TekrarSayisi*StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
            end;
            50:begin //Vade Oluştur
              if TabFatura.State = dsBrowse then
                TabFatura.Edit;
              TabFatura.FieldByName('VADE').AsInteger := StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
            end;
          end;
          Tablo.Query8.Next;
        end;
      end;
    end;
  end;
end;

procedure TFaturaWizardDlg.Timer1Timer(Sender: TObject);
begin
  TabFaturaIptalIsaretleClick(Self);
  ModalResult:=mrClose;
  Close;
end;

procedure TFaturaWizardDlg.CokSatirKampanyaDuzenle(KampanyaID:integer);
var
  HataMesaji:string;
  TekrarSayisi:integer;
begin
  Tablo.TablodanSorguAc(7,'select F.KAMPANYAID,K.TUR from FATURA F inner join KAMPANYA K on F.KAMPANYAID=K.ID where K.ID='+IntToStr(KampanyaID));
  if (not Tablo.Query7.IsEmpty)and(Tablo.Query7.FieldByName('TUR').AsInteger=2) then begin
    Tablo.TablodanSorguAc(8,'select * from KAMPANYAKOSUL where KAMPANYAID = '+Tablo.Query7.FieldByName('KAMPANYAID').AsString);
    TekrarSayisi := 0;
    while not Tablo.Query8.Eof do begin //her koşul satırı için
      case Tablo.Query7.FieldByName('TUR').AsInteger of
        2:begin //çok satır ile ilgili	 2
          case Tablo.Query8.FieldByName('TUR').AsInteger of
            40:begin //Toplam Tutar(Etkilenen Satırlar)	40
              Tablo.TablodanSorguAc(9,'select sum(ADET*BIRIMFIYAT) from FATURA where FATBASID='+TabFatbaslik.FieldByName('ID').AsString+' and KAMPANYAID='+Tablo.Query7.FieldByName('KAMPANYAID').AsString);
              TekrarSayisi := Trunc(Tablo.Query9.Fields[0].AsFloat/StrToFloat(Tablo.Query8.FieldByName('KOSUL').AsString));
            end;
            50:begin //Toplam Adet(Etkilenen Satırlar)	50
              Tablo.TablodanSorguAc(9,'select count(*) from FATURA where FATBASID='+TabFatbaslik.FieldByName('ID').AsString+' and KAMPANYAID='+Tablo.Query7.FieldByName('KAMPANYAID').AsString);
              TekrarSayisi := Trunc(Tablo.Query9.Fields[0].AsFloat/StrToFloat(Tablo.Query8.FieldByName('KOSUL').AsString));
            end;
          end;
        end;
        3:begin //Tüm satırları kapsayan 3
          TekrarSayisi := 1;
        end;
      else
        TekrarSayisi := 0;
      end;
      Tablo.Query8.Next;
    end;
    if TekrarSayisi>0 then begin//uygulanacak kampanya var ise kampanya sonuc i?indeki her bir satır i?in;
      Tablo.TablodanSorguAc(8,'select * from KAMPANYASONUC where KAMPANYAID = '+Tablo.Query7.FieldByName('KAMPANYAID').AsString);
      if Tablo.Query7.FieldByName('TUR').AsInteger=2 then
        Tablo.TablodanSorguAc(9,'select * from FATURA where FATBASID='+TabFatbaslik.FieldByName('ID').AsString+' and KAMPANYAID='+Tablo.Query7.FieldByName('KAMPANYAID').AsString+' order by TUTAR desc ' );
      Tablo.Query9.FetchAll;
      case Tablo.Query7.FieldByName('TUR').AsInteger of
        2,3:begin //çok satır ile ilgili	 2
          Tablo.Query9.First;
          while not Tablo.Query9.Eof do begin //ilgili herbir satır i?in;
            if TabFatura.Locate('ID',Tablo.Query9.FieldByName('ID').AsInteger,[]) then begin
              if TabFatura.State = dsBrowse then
                TabFatura.Edit;
              Tablo.Query8.First;
              while not Tablo.Query8.Eof do begin //her sonu? i?in;
                case Tablo.Query8.FieldByName('TUR').AsInteger of
                  10:begin //İskonto
                    TabFatura.FieldByName('ISKONTO').AsInteger := StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
                    TabFatura.FieldByName('ISKONTO2').AsInteger := 0;
                  end;
                  20:begin //En Pahal? ürüne İskonto
                    if ((Tablo.Query9.RecNo+Trunc(Tablo.Query9.RecordCount/TekrarSayisi)-1) Mod Trunc(Tablo.Query9.RecordCount/TekrarSayisi)) = 0 then
                    TabFatura.FieldByName('ISKONTO').AsInteger := StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
                    TabFatura.FieldByName('ISKONTO2').AsInteger := 0;
                  end;
                  30:begin //En Ucuz ürüne İskonto
                    if (Tablo.Query9.RecNo Mod Trunc(Tablo.Query9.RecordCount/TekrarSayisi)) = 0 then
                    TabFatura.FieldByName('ISKONTO').AsInteger := StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
                    TabFatura.FieldByName('ISKONTO2').AsInteger := 0;
                  end;
                  40:begin //Mal Fazlas? Ekle
                    TabFatura.FieldByName('MF').AsInteger := StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
                  end;
                  50:begin //Vade Oluştur
                    TabFatura.FieldByName('VADE').AsInteger := StrToIntDef(Tablo.Query8.FieldByName('SONUC').AsString,0);
                  end;
                end;
                Tablo.Query8.Next;
              end;
              TabFatura.Post;
            end;
            Tablo.Query9.Next;
          end;
        end;
      end;
    end;
  end;
end;

procedure TFaturaWizardDlg.KampanyaDzenle1Click(Sender: TObject);
var
  i:Integer;
begin
  if BekletDlg <> nil then
    FreeAndNil(BekletDlg);
  Application.CreateForm(TBekletmeDlg, BekletDlg);
  BekletDlg.cxProgressBar1.Position := 0;
  BekletDlg.Caption := 'Kampanyalar Uygulanıyor...';
  BekletDlg.Show;
  i := 0;
  while i < 5 do begin
    BekletDlg.cxProgressBar1.Position := i;
    BekletDlg.cxProgressBar1.Refresh;
    sleep(5);
    inc(i);
  end;
  Tablo.TablodanSorguAc(2,
      ' select distinct FATID=0,F.KAMPANYAID,K.TUR,K.ADI from FATURA F inner join KAMPANYA K on F.KAMPANYAID=K.ID'
      +' where K.TUR in (2,3) and F.FATBASID='+TabFatbaslik.FieldByName('ID').AsString
      +' union all'
      +' select FATID=F.ID,F.KAMPANYAID,K.TUR,K.ADI from FATURA F inner join KAMPANYA K on F.KAMPANYAID=K.ID'
      +' where K.TUR = 1 and F.FATBASID='+TabFatbaslik.FieldByName('ID').AsString );
  Tablo.Query2.FetchAll;
  while not Tablo.Query2.Eof do begin
    while i < (100*Tablo.Query2.RecNo/Tablo.Query2.RecordCount) do begin
      BekletDlg.cxProgressBar1.Position := i;
      BekletDlg.cxProgressBar1.Refresh;
      BekletDlg.LabelUstTaraf.Caption := Tablo.Query2.FieldByName('ADI').AsString;
      BekletDlg.LabelUstTaraf.Update;
      sleep(5);
      inc(i);
    end;
    if Tablo.Query2.FieldByName('TUR').AsInteger=1 then begin
      TekSatirKampanyaDuzenle(Tablo.Query2.FieldByName('FATID').AsInteger);
      if TabFatura.State in[dsEdit,dsInsert] then
        TabFatura.Post;
    end else
      CokSatirKampanyaDuzenle(Tablo.Query2.FieldByName('KAMPANYAID').AsInteger);
    Tablo.Query2.Next;
  end;
  if BekletDlg <> nil then
    FreeAndNil(BekletDlg);
end;

procedure TFaturaWizardDlg.SatirSilClick(Sender: TObject);
var
  PaketID: Integer;
begin
  if TabFatura.state = dsInsert then
     TabFatura.cancel;

  if TabFatura.IsEmpty then
     Abort;

  if Application.MessageBox(PChar(SeciliSatirSil), PChar(Onay),    MB_YESNO + MB_ICONQUESTION) = ID_YES then
     if StrToIntDef(TabFatura.FieldByName('YERI').AsString, 0) <> TabNo_ITSPaket then begin
        TabFatura.Delete;
    end else begin
        PaketID := TabFatura.FieldByName('YERID').AsInteger;
        TabFatura.First;
        while not TabFatura.Eof do
          if TabFatura.FieldByName('YERID').AsInteger = PaketID then begin
             TabFatura.Delete;
          end else
             TabFatura.Next;
    end;
end;

procedure TFaturaWizardDlg.Stokskontosu1Click(Sender: TObject);
var
  ISK2: string;
begin
  TabFatura.First;
  while not TabFatura.Eof do begin
    if TabFatura.FieldByName('TUR').AsInteger=1 then begin
      ISK2 := Tablo.AciklamaGetir('STOKLAR','ISK2',TabFatura.FieldByName('URUNID').Value);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set ISKONTO2=&Yuzde, TUTAR=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 where ID=&id ',['&Yuzde','&id'],[StrToFloatDef(ISK2,0),TabFatura.FieldByName('ID').AsInteger]);
    end;
    TabFatura.Next;
  end;
  FaturaTutarHesapla(True);
  TabloYenile(TabFatura,[TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.FATBASLIKAfterPost(DataSet: TDataSet);
var
  Sonuc: Variant;
  Ctrls: TGirdiDenetimleri;
  VFatNo, VSeri: string;
  YeniID: Integer;
begin
  TabFaturaIDsi := TabFatbaslik.Fields[0].AsInteger;

  // FireDAC + ODBC path may leave identity value as -1 after insert.
  // Recover the persisted ID using generated document no/series and reopen dataset.
  if (TabFatbaslik.State = dsBrowse) and (TabFaturaIDsi <= 0) then
  begin
    VFatNo := Trim(TabFatbaslik.FieldByName('FATURANO').AsString);
    VSeri := Trim(TabFatbaslik.FieldByName('FATURASERI').AsString);
    if VFatNo <> '' then
      YeniID := StrToIntDef(VarToStr(Veritabani.BasitKomutÇalıştır(
        Tablo.FDCnn,
        'select top 1 ID from FATBASLIK where FATURANO=&NO and FATURASERI=&SERI and TUR=&TUR and SUBEID=&SUBE order by ID desc',
        ['&NO','&SERI','&TUR','&SUBE'],
        [VFatNo, VSeri, TabFatbaslik.FieldByName('TUR').AsInteger, TabFatbaslik.FieldByName('SUBEID').AsInteger],
        True
      )), 0)
    else
      YeniID := 0;

    if YeniID > 0 then
    begin
      TabloYenile(TabFatbaslik, [YeniID]);
      TabFaturaIDsi := YeniID;
    end;
  end;
  DetayTus.Enabled := True;
  PlanlaTus.Enabled := True;
  IptalIslemleri;
  FaturaTipiDuzenle;
  TabloYenile(TOPLAMLAR, [TabFatbaslik.FieldByName('ID').AsInteger]);
  if AdresDegisti then begin
     AdresDegisti := False;
     if Application.MessageBox(PChar(Adresdegistikartguncelle),PChar(Uyari),MB_YESNO)=mrYes then begin
        Tablo.RehberBilgiGuncelle(TabFatbaslik.FieldByName('REHBERID').AsInteger,1,2,MemoFatAdres.Text);
        Tablo.RehberBilgiGuncelle(TabFatbaslik.FieldByName('REHBERID').AsInteger,1,6,EditILCE.Text);
        Tablo.RehberBilgiGuncelle(TabFatbaslik.FieldByName('REHBERID').AsInteger,1,8,EditIL.Text);
        Tablo.RehberBilgiGuncelle(TabFatbaslik.FieldByName('REHBERID').AsInteger,2,20,EditVD.Text);
        Tablo.RehberBilgiGuncelle(TabFatbaslik.FieldByName('REHBERID').AsInteger,2,22,EditVNO.Text);
     end;
  end;
end;

procedure TFaturaWizardDlg.IptalIslemleri;
begin//durum:6 iptal
  if TabFatbaslik.FieldByName('DURUM').AsInteger=6 then begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set DURUM=6,FATURA_MATRAHI=0,KDV_TUTARI=0,EKVERGI=0,FATURA_TUTARI=0,DOVIZ_TUTARI=0 where TUR=&Tur and ID=&ID'
              ,['&Tur','&ID'],[Tur,TabFatbaslik.FieldByName('ID').AsInteger]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set BIRIMFIYAT=0,TUTAR=0,DOVIZ_TUTARI=0,DOVIZ_BIRIMFIYAT=0,STOKDURUMDEGIS=0,ADET=0,MIKTAR=0 where FATBASID=&Fatbasid'
              ,['&Fatbasid'],[TabFatbaslik.FieldByName('ID').AsInteger]);
  end;
end;

procedure TFaturaWizardDlg.FATBASLIKAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TOPLAMLAR, [TabFatbaslik.FieldByName('ID').AsInteger]);
  if TabFatbaslik.FieldByName('MERKEZID').AsString <>'' then
     EditSRMMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI', TabFatbaslik.FieldByName('MERKEZID').AsInteger);
end;

procedure TFaturaWizardDlg.FATBASLIKBeforeEdit(DataSet: TDataSet);
begin
   {efat }
{ 01/11/2022 AO satıcı ve özelkod alanlarınınn değişebilmesi için burası iptal edildi
  if not(KilitKaldirildi)and(FATBASLIK.FieldByName('EFATURADURUM').AsInteger in [2, 52]) then begin  //işlem gören fat veya giden e-irs ise işlem yapılamaz
     ShowMessage(Islemgorenfaturadadegisiklikyapilmaz);
     Abort;
  end; }

  OncekiKDVDurumu := TabFatbaslik.FieldByName('KDVDURUM').AsString;
  OncekiFaturaNo := TabFatbaslik.FieldByName('FATURANO').AsString;
  OncekiDovizCinsi := TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString;
  OncekiSubeId := TabFatbaslik.FieldByName('SUBEID').AsInteger;
  if (islemOp in ['D','I'])and(not LogAlindi) then begin
     Tablo.OncekiLogBelirle(TabFatbaslik);
     LogAlindi := True;
  end;
end;

procedure TFaturaWizardDlg.FATBASLIKBeforeOpen(DataSet: TDataSet);
begin
  TabFatbaslik.SQL.Text := StringReplace(TabFatbaslik.SQL.Text,'@Dil',IntToStr(Dil),[rfReplaceAll]);
end;

procedure TFaturaWizardDlg.FATBASLIKBeforePost(DataSet: TDataSet);
begin
  if (TabFatbaslik.State <> dsInsert)and(cbIrsaliyeli.Checked)and(TabFatbaslik.FieldByName('IRSALIYELI').OldValue<>TabFatbaslik.FieldByName('IRSALIYELI').NewValue) then
      Tablo.BelgeNoIslemleri(TabFatbaslik, Tur, cbIrsaliyeli.Checked);
  BoslukKontrolu;
  if KilitKontrolEt(1,TabFatbaslik.FieldByName('TUR').AsInteger,TabFatbaslik.FieldByName('FATURATARIH').AsDateTime,1) then
     Abort;
  if (TabFatbaslik.FieldByName('TIPI').AsInteger=2)and(TabFatbaslik.FieldByName('FATURATARIH').AsDateTime <= IadeOlanUrununSatisTarihi) then begin
     Showmessage('İade tarihi, satışı tarihinden daha önce olamaz.');
     Abort;
  end;

  if (TabFatbaslik.FieldByName('EKVERGI').AsCurrency>0)and((ComboFatTipi.EditValue=4)or(ComboFatTipi.EditValue=7)or(ComboFatTipi.EditValue=8)) then //s.meslek makbuzu ise ekvergi kısmını stopaj olarak kullanırız
      TabFatbaslik.FieldByName('EKVERGI').AsCurrency:=-1*TabFatbaslik.FieldByName('EKVERGI').AsCurrency;
  if TabFatbaslik.FieldByName('EKVERGI').OldValue <> TabFatbaslik.FieldByName('EKVERGI').NewValue then
     FaturaTutarHesapla(False);
  if (TabFatbaslik.State = dsInsert) and (Pos('Perakende', LabelAd.Caption) > 0) then
      TabFatbaslik.FieldByName('ACIKLAMA').AsString := TabFatbaslik.FieldByName('ACIKLAMA').AsString + ' ' + TabFatbaslik.FieldByName('BASLIK').AsString;
  TabFatbaslik.FieldByName('EKSTREDEKULLAN').AsBoolean := (TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString<>'')and(TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString <> CariDoviz);
  if (OncekiSubeId <> TabFatbaslik.FieldByName('SUBEID').AsInteger)and(TabFatbaslik.Fields[0].AsInteger > 0 ) then
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update FATURA set SUBEID='+TabFatbaslik.FieldByName('SUBEID').AsString+' Where FATBASID ='+IntToStr(TabFaturaIDsi)+' ',[],[]);
  EkleyenDegistiren(DtsFatBaslik);
end;

function TFaturaWizardDlg.ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
begin
  if TOPLAMLAR.Locate('TUR', Bolum,[loPartialKey]) then
    result := TOPLAMLAR.FieldByName(TLDoviz).AsExtended
  else
    result:=-99999;
end;

procedure TFaturaWizardDlg.FaturaTutarHesapla(TabloAc:Boolean);
var DOVIZKUR,FATURA_MATRAHI,KDV_TUTARI,FATURA_TUTARI,DOVIZ_TUTARI,MALIYETORT,STOPAJ : extended;
    RaporDoviz,s:String;
begin
  if (TabFatbaslik.Fields[0].AsString='')or(TabFatbaslik.Fields[0].AsString='-1') then
     exit;
  TabloYenile( TOPLAMLAR, [TabFatbaslik.Fields[0].AsInteger]);
  FATURA_MATRAHI := ToplamGetir(4,'DEGER');
  if FATURA_MATRAHI=-99999 then
     FATURA_MATRAHI := ToplamGetir(1,'DEGER'); //Toplam
  FATURA_TUTARI  := ToplamGetir(20,'DEGER');    //'Genel Toplam'
  DOVIZ_TUTARI   := ToplamGetir(20,'DOVIZTUTARI');
  if (ComboFatTipi.EditValue=4)or(ComboFatTipi.EditValue=7)or(ComboFatTipi.EditValue=8) then begin//Serbest meslek makbuzu ise direk kdv yi alırız yoksa fark?
     KDV_TUTARI     := ToplamGetir(15,'DEGER');
     STOPAJ := abs(EditEkVergi.Value);  //ToplamGetir(7,'DEGER');
     FATURA_MATRAHI := FATURA_MATRAHI - STOPAJ; //Normal matrahtan stopaj? ??kar?yoruz.
  end else
     KDV_TUTARI     := FATURA_TUTARI-FATURA_MATRAHI;
   Tablo.TablodanSorguAc(1, 'select isnull(ROUND(sum(F.MIKTAR*ISNULL(SOM.BIRIMMALIYET,0.0)),2),0.0) as MALIYET_ORT '+
      ' from FATURA F left outer join STOK_ORT_MALIYET SOM on F.ID=SOM.FATURAID where F.FATBASID=' + TabFatbaslik.Fields[0].AsString);
   MALIYETORT := Tablo.Query1.FieldByName('MALIYET_ORT').AsExtended;

  {RaporDoviz := 'RAPORDOVIZ=(case when RAPORDOVIZ is null then '''+FATURA.FieldByName('DOVIZ_KURU').AsString+''' else RAPORDOVIZ end),';
   if ComboFatTipi.EditValue=5 then //kur fark? ise
      RaporDoviz := RaporDoviz+'DOVIZ_CINSI=(case when RAPORDOVIZ is null then '''+FATURA.FieldByName('DOVIZ_KURU').AsString+''' else RAPORDOVIZ end),EKSTREDEKULLAN=1,';

  if (DOVIZ_TUTARI<>0)and(FATURA_TUTARI>0)and(FATBASLIK.FieldByName('RAPORDOVIZ').AsString<>CariDoviz) then
     s:= ',DOVIZKUR='+FCurrToStr(TOPLAMLAR.fieldbyname('DEGER').ascurrency)+'/Nullif('+FCurrToStr(TOPLAMLAR.fieldbyname('DOVIZTUTARI').ascurrency)+',0)'
  else
     s:=',DOVIZKUR='+FExtToStr((DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00',FATBASLIK.FieldByName('FATURATARIH').AsDateTime),FATBASLIK.FieldByName('RAPORDOVIZ').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'))),4);
  }
  Veritabani.BasitKomutÇalıştır(
    Tablo.FDCnn,
    'update FATBASLIK set FATURA_MATRAHI=&MAT, KDV_TUTARI=&KDV, FATURA_TUTARI=&FAT, DOVIZ_TUTARI=&DOV, FATURA_MALIYETI_ORT=&MAL where ID=&ID',
    ['&MAT','&KDV','&FAT','&DOV','&MAL','&ID'],
    [FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI, DOVIZ_TUTARI, MALIYETORT, TabFatbaslik.Fields[0].AsInteger]
  );

  if TabloAc then
     TabloYenile(TabFatbaslik, [TabFatbaslik.Fields[0].AsInteger]);
end;

procedure TFaturaWizardDlg.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' order by VARSAYILAN desc');

  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  CarideEFatura := Tablo.tabCariBilgileri.FieldByName('EFATURA').AsString='True';
  //lblMusteriAdres.Caption := Adres + Tablo.tabCariBilgileri.FieldByName('ADRES').AsString + ' ' + Tablo.tabCariBilgileri.FieldByName('ILCE').AsString + ' / ' + Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  //lblMusteriTel.Caption := isTel + Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
  //lblMusteriEposta.Caption := EPosta + Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TFaturaWizardDlg.FATURAADETChange(Sender: TField);
var
s : string;
begin
  //
//  s := Sender.FieldName + ' > Dataset > '+Sender.DataSet.Name+' > Readonly > '+
//  BoolToStr(Sender.ReadOnly);
end;

procedure TFaturaWizardDlg.FATURAAfterDelete(DataSet: TDataSet);
begin
  FaturaTutarHesapla(True);
  TabFatura.Refresh;
  if TabFatura.IsEmpty then begin
     EditKulKur.Visible := False;
     TabFatbaslik.Edit;
     TabFatbaslik.FieldByName('RAPORDOVIZ').AsString := CariDoviz;
     TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString:=CariDoviz;
     TOPLAMLAR.Close
  end;
end;

procedure TFaturaWizardDlg.FATURAAfterInsert(DataSet: TDataSet);
begin
  OncekiStokMiktar := 0.0;
end;

procedure TFaturaWizardDlg.FATURAAfterOpen(DataSet: TDataSet);
begin
  cbStokDepo.Enabled := TabFatura.IsEmpty;
  if LocateFaturaID > 0 then
    TabFatura.Locate('ID', LocateFaturaID, []);
  FaturaTipiDuzenle;
end;

procedure TFaturaWizardDlg.StokIzlemBilgisi;
var
   FatSatID, GDepo, CDepo, RId, SatirId : integer;
   PasifIzleme  : boolean;
   ArananBarkod : String;
   GerekMiktar, miktar : real;
begin
   //PasifIzleme := veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from STOKIZLEME where DURUM=0 and BELGETUR = &BlgTur and BASLIKID = &BslkID and SATIRID = &StrID',['&BlgTur','&BslkID','&StrID'],[FATBASLIK.FieldByName('TUR').AsInteger,FATBASLIK.FieldByName('ID').AsInteger,FATURA.FieldByName('ID').AsInteger]);
//   if (FATURA.FieldByName('STOKDURUMDEGIS').AsBoolean=True){or(PasifIzleme=True)} then begin
     if TabFatura.State = dsEdit then
        FatSatID := TabFatura.FieldByName('ID').AsInteger
    else
        FatSatID := 0;
    if TabFatbaslik.FieldByName('GIRISDEPO').Value <> null then
       GDepo := TabFatbaslik.FieldByName('GIRISDEPO').AsInteger
    else
       GDepo := 0;
    if TabFatbaslik.FieldByName('CIKISDEPO').Value <> null then
       CDepo := TabFatbaslik.FieldByName('CIKISDEPO').AsInteger
    else
       CDepo := 0;
    //lokasyon sorma işlemleri
    if Assigned(AraDlg) then
      ArananBarkod := AraDlg.EditBarkodu.Text
    else
      ArananBarkod := '';

    Tablo.TablodanSorguAc(1,'select MIKTARSEC from STOKLAR where ID = '+TabFatura.FieldByName('URUNID').AsString);
    if Tablo.Query1.Fields[0].AsString='1' then
       GerekMiktar := 1
    else
       GerekMiktar := Abs(TabFatura.FieldByName('MIKTAR').AsFloat);

    if not PasifIzleme then
      if Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_LokasyonVar,False) then begin
        if not Anaform.StokLokasyonSor(LokasyonDlg,TabFatura.FieldByName('URUNID').AsInteger,TabFatbaslik.FieldByName('TUR').AsInteger,
               TabFatbaslik.FieldByName('ID').AsInteger, FatSatID, GDepo, CDepo, GerekMiktar) then begin
          FreeAndNil(LokasyonDlg);
          TabFatura.Cancel;
          Abort;
        end;
      end;
    //pasif izlemesi var m? kontrol?..
    //izleme bilgisi sorma; seri numarası ile arama yapılıyorsa seri no sorma ekranı açılmasın
    if (((Assigned(AraDlg))and(AraDlg.EditSerino.Text=''))or(not Assigned(AraDlg)))
          and(TabFatura.FieldByName('IZLEME').AsInteger > 0) then begin
          miktar := TabFatura.FieldByName('MIKTAR').AsFloat;
          if (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_ALIS_IRS_FAT)or
             (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_SATIS_IRS_FAT)or
             (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_SATIS_IRS_FIS)or
             (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_Gelen_Konsinye_Irsaliye)or
             (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_Gelen_Konsinye_Fatura)or
             (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_Giden_Konsinye_Fis)or
             (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_Giden_Konsinye_Irsaliye)or
             (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_Giden_Konsinye_Fatura)or
            ((TabFatura.FieldByName('YERI').AsInteger = TabNo_IADE_ALISBELGE)and(TabFatbaslik.FieldByName('TIPI').AsInteger=2))or//iade fatura ise kaynak satır al?nmal?
             ((TabFatbaslik.FieldByName('TUR').AsInteger = KasaTur_Gelen_Konsinye)and(TabFatbaslik.FieldByName('TIPI').AsInteger=2))then//iade konsinye ise kaynak satır al?nmal?
              SatirId := TabFatura.FieldByName('YERID').AsInteger
          else
              SatirId := 0;
          if not Anaform.StokIzleme(IzlemDlg,TabFatura.FieldByName('URUNID').AsInteger,TabFatura.FieldByName('IZLEME').AsInteger,
                        TabFatbaslik.FieldByName('TUR').AsInteger,TabFatbaslik.FieldByName('TIPI').AsInteger,
                        TabFatbaslik.FieldByName('ID').AsInteger, FatSatID, TabFatbaslik.FieldByName('REHBERID').AsInteger, TabFatbaslik.FieldByName('GIRISDEPO').AsInteger,  TabFatbaslik.FieldByName('CIKISDEPO').AsInteger,
                        GerekMiktar,miktar,False,ArananBarkod,0, SatirId,TabFatura.FieldByName('STOKDURUMDEGIS').AsBoolean,'0',IslemOp) then begin
             FreeAndNil(IzlemDlg);
             TabFatura.Cancel;
             if (TabFatura.recordcount>0)and(TabFatura.FieldByName('ADET').AsInteger=0) then
                 TabFatura.Delete;
             Abort;
          end;
    end;
 //end;
end;


procedure TFaturaWizardDlg.FATURAAfterPost(DataSet: TDataSet);
var
  SeriNo: Variant;
  st: Tstringlist;

{  procedure IzlemdenCikis;
  begin
    //Serino Karekod
    //tempteki bilgileri gerçek tabloya alal?m..
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,IZLEMTUR,MIKTAR,IZLEMID,IZLEM,EKLEYEN,DURUM)'+
        ' values( '+FATURA.FieldByName('URUNID').AsString+','+FATBASLIK.FieldByName('TUR').AsString+','+FATBASLIK.FieldByName('ID').AsString+','+
        FATURA.FieldByName('ID').AsString+',0,'+FATBASLIK.FieldByName('CIKISDEPO').AsString+',1,1.0,0,'''+AraDlg.EditSerino.Text+''','+Kullanan+',1)',[],[]);
  end; }
begin
  // TabloYenile(FATURA,[FATBASLIK.FieldByName('ID').AsInteger]);
  if TabFatura.FieldByName('ID').AsInteger <= 0 then begin  //yeni kayıtsa ID -1 geliyor
     TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
     TabFatura.Last;
  end;

  FaturaTutarHesapla(True);
  //Varsa masraf ve projeyi PROJEMALIYET tablosuna yazmal?y?z

  if SatirVadesiKullan then begin
    tablo.tablodansorguac(5,'select (SUM(isnull(TUTAR,0.0)*isnull(VADE,0))/SUM(isnull(TUTAR,0.0))) from FATURA where FATBASID='+TabFatbaslik.FieldByName('ID').AsString);
    TabFatbaslik.Edit;
    TabFatbaslik.FieldByName('VADE').AsInteger := Trunc(Tablo.Query5.fields[0].AsFloat);
  end;

  FaturaTipiDuzenle;
  //?zlem bilgisi var m? bakal?m serino vb.
  if IzlemDlg<>nil then begin //kaydetmesi i?in destroy etmemiz laz?m
     IzlemDlg.SatirID := TabFatura.FieldByName('ID').AsInteger;
     FreeAndNil(IzlemDlg);
  end;
  /////
  if LokasyonDlg<>nil then begin
    LokasyonDlg.SatirID := TabFatura.FieldByName('ID').AsInteger;
    FreeAndNil(LokasyonDlg);
  end;
  //if (FATURA.FieldByName('TUR').AsInteger = 1)and(FATBASLIK.FieldByName('TUR').AsInteger in[11,12]) then
  //  Veritabani.BasitKomutÇalıştır(tablo.FDCnn,'exec [dbo].[f_MaliyetHesaplama] '+FATURA.FieldByName('URUNID').AsString,[],[]);
  //if (Assigned(AraDlg))and(AraDlg.EditSerino.Text<>'') then
  //   IzlemdenCikis;
  if (TabFatbaslik.FieldByName('ZARFID').Value <> null) and (TabFatbaslik.FieldByName('ZARFID').AsInteger > 0) then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec sp_FaturaZarfHesapla &ZarfID',['&ZarfID'],[TabFatbaslik.FieldByName('ZARFID').AsInteger]);
end;

procedure TFaturaWizardDlg.FATURAAfterScroll(DataSet: TDataSet);
begin
//  GridFaturaViewKOD1.Options.Editing := FATURA.FieldByName('TUR').AsInteger = 0;
//  GridFaturaViewBIRIMFIYAT1.Properties.ReadOnly := FATURA.FieldByName('KUR').AsString<>FATURA.FieldByName('DOVIZ_KURU').AsString;
//  GridFaturaViewBIRIMFIYAT1.Options.Editing := not GridFaturaViewBIRIMFIYAT1.Properties.ReadOnly;
end;

procedure TFaturaWizardDlg.FATURABeforeClose(DataSet: TDataSet);
begin
  // after open da son kapanan satıra tekrar locate olabilmek için bilgi alınacak..
  if not TabFatura.IsEmpty then
    LocateFaturaID := TabFatura.FieldByName('ID').AsInteger
  else
    LocateFaturaID := 0;
end;

procedure TFaturaWizardDlg.FATURABeforeDelete(DataSet: TDataSet);
begin
{efat } if not(KilitKaldirildi)and(TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [2,52]) then begin
     ShowMessage(Islemgorenfaturadadegisiklikyapilmaz);
     Abort;
  end;
 {09/03/2025 AO Silme kontrolü dıı silme ile ortak olsun diye utabloda yapılmaktadır
  if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM FATURA WHERE YERID ='+FATURA.FieldByName('ID').AsString, [], []) then begin
        Tablo.UyariGoster(Uyari, DonusumYapilmis);
        Abort;
  end;

  //22.02/2022 AO
  if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM STOKIZLEME S1 WHERE SATIRID = '+FATURA.FieldByName('ID').AsString+' AND '+
                             ' EXISTS(SELECT * FROM STOKIZLEME S2 WHERE S2.DONUSID = S1.ID)',[],[]) then begin
     Tablo.UyariGoster(Uyari, DonusumYapilmis);
     Abort;
  end;


  if (FATURA.FieldByName('TUR').AsInteger = 1) and (cbStokDepo.EditValue <> null) then begin// tür stoksa

     if (not FATBASLIK.FieldByName('TUR').AsInteger in [11,15])and(Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM FATURA WHERE YERID ='+FATURA.FieldByName('ID').AsString, [], [])) then begin
        Tablo.UyariGoster(Uyari, DonusumYapilmis);
        Abort;
     end;

     if FATURA.FieldByName('IZLEME').AsInteger = 0 then begin //izlem yoksa
        if Tablo.KullanimSayisi(FATBASLIK.FieldByName('TUR').AsInteger, 0, FATURA.FieldByName('ID').AsInteger, FATURA.FieldByName('URUNID').AsInteger, FATBASLIK.FieldByName('FATURATARIH').AsDateTime)>0 then
           Abort;
     end
     else begin
        if Tablo.IzlemBildirimSayisi(FATBASLIK.FieldByName('TUR').AsInteger, 0, FATURA.FieldByName('ID').AsInteger, FATBASLIK.FieldByName('FATURATARIH').AsDateTime)>0 then
           Abort;
     end;

  }
  if Tablo.FaturaSatirSilmeKontrolu(TabFatbaslik.FieldByName('TUR').AsInteger,TabFatbaslik.FieldByName('FATURATARIH').AsDateTime, TabFatura)=False then
       Abort;
    // gider pusulasından satır siliniyorsa ilişkili fatura satırı güncellensin.
  if TabFatbaslik.FieldByName('TUR').AsInteger = 8 then
        Tablo.IadeMiktarGuncelle(TabFatura.FieldByName('IADEFATURAID').AsInteger, TabFatura.FieldByName('ADET').AsString);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where BASLIKID=&BID and SATIRID=&SID',['&BID','&SID'],[TabFatbaslik.FieldByName('ID').AsString,TabFatura.FieldByName('ID').AsString]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKLOKASYON where BASLIKID=&BID and SATIRID=&SID',['&BID','&SID'],[TabFatbaslik.FieldByName('ID').AsString,TabFatura.FieldByName('ID').AsString]);
  //end;
   //Sat??ta ekipman silinirse ve bu faturaya ait bu kay?t müşteri cari kayd?nda varsa oradan da silinir
  if TabFatbaslik.FieldByName('TUR').AsInteger = 15 then
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from EKIPMANREHBER WHERE REHBERID = '+TabFatbaslik.FieldByName('REHBERID').AsString+
         ' and SATISNO='''+TabFatbaslik.FieldByName('FATURANO').AsString+''' '+
         ' and EKIPMANID=(select E.ID from EKIPMANLAR E inner join STOKLAR S on S.ID=E.URUNID where S.ID='+TabFatura.FieldByName('URUNID').AsString+')',[],[]);

end;

procedure TFaturaWizardDlg.FATURABeforeEdit(DataSet: TDataSet);
begin
{efat } if not(KilitKaldirildi)and(TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [2, 52]) then begin
     ShowMessage(Islemgorenfaturadadegisiklikyapilmaz);
     Abort;
  end;
  OncekiStokMiktar := TabFatura.FieldByName('MIKTAR').AsFloat;
  OncekiBirim := TabFatura.FieldByName('BIRIM').AsInteger;
end;

procedure TFaturaWizardDlg.FATURABeforeOpen(DataSet: TDataSet);
begin
(*  // Bazi veritabanlarinda EN/BOY/YUZEY/SAYI kolonlari olmayabiliyor.
  // Persistent field'lar acilis hatasi vermesin diye runtime'da devre disi birak.
  if not Veritabani.VeriVarMi(Tablo.FDCnn,
    'select 1 from sys.columns where object_id = object_id(''FATURA'') and name = ''EN''', [], []) then
  begin
    EnBoyHesaplamaAktif := False;
//    if Assigned(FATURAEN) then FreeAndNil(FATURAEN);
//    if Assigned(FATURABOY) then FreeAndNil(FATURABOY);
//    if Assigned(FATURAYUZEY) then FreeAndNil(FATURAYUZEY);
//    if Assigned(FATURASAYI) then FreeAndNil(FATURASAYI);
    if Assigned(GridFaturaViewEN) then FreeAndNil(GridFaturaViewEN);
    if Assigned(GridFaturaViewBOY) then FreeAndNil(GridFaturaViewBOY);
    if Assigned(GridFaturaViewYUZEY) then FreeAndNil(GridFaturaViewYUZEY);
    if Assigned(GridFaturaViewSAYI) then FreeAndNil(GridFaturaViewSAYI);
  end;    *)

  // Hesaplanan kolonlari kaynak SQL'den almak icin clone query'yi ayni Param ile aciyoruz
  if FATURA.Active then
    FATURA.Close;
  if TabFatura.Params.FindParam('Par') <> nil then
    FATURA.ParamByName('Par').Value := TabFatura.ParamByName('Par').Value
  else if TabFatbaslik.Active then
    FATURA.ParamByName('Par').AsInteger := TabFatbaslik.FieldByName('ID').AsInteger
  else
    Exit;
  FATURA.Open;
end;

procedure TFaturaWizardDlg.FATURABeforePost(DataSet: TDataSet);
var
  Kur, Dovizkuru: string;
  Tutar, Doviztutari: Currency;
  dovizkur,Isk: Extended;

  Procedure TutarIslemler;
  begin
     if TabFatbaslik.FieldByName('TIPI').AsString = '5' then //kur fark?nda hesaplama farkl? olacak..
       TabFatura.FieldByName('DOVIZ_BIRIMFIYAT').AsExtended := 0.0;
     TabFatura.FieldByName('DOVIZ_TUTARI').Value :=Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabFatura.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabFatura.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,TabFatura.FieldByName('ADET').Value*TabFatura.FieldByName('DOVIZ_BIRIMFIYAT').AsExtended));
     if (abs(TabFatura.FieldByName('DOVIZ_BIRIMFIYAT').Value)>0.00001)and(TabFatbaslik.FieldByName('TIPI').AsString <> '5') then //kur fark?nda hesaplama farkl? olacak..
        TabFatura.FieldByName('BIRIMFIYAT').Value := TabFatura.FieldByName('DOVIZ_BIRIMFIYAT').Value * TabFatura.FieldByName('DOVIZKURDEGERI').Value;
     TabFatura.FieldByName('TUTAR').Value := Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabFatura.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabFatura.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,TabFatura.FieldByName('ADET').Value*TabFatura.FieldByName('BIRIMFIYAT').AsExtended));
  end;

begin
  // Keep clone dataset closed during post to avoid ODBC trigger/resultset conflicts on the same connection.
  if FATURA.Active then
    FATURA.Close;

  // Detail row must point to a persisted FATBASLIK row (valid FK).
  if TabFatbaslik.State in [dsInsert, dsEdit] then
    TabFatbaslik.Post;
  if TabFatbaslik.FieldByName('ID').IsNull or (TabFatbaslik.FieldByName('ID').AsInteger <= 0) then
    raise Exception.Create('Fatura basligi kaydedilemedi (FATBASLIK.ID).');
  TabFatura.FieldByName('FATBASID').AsInteger := TabFatbaslik.FieldByName('ID').AsInteger;
  if (TabFatura.FieldByName('ISKONTO').AsFloat=0)and(TabFatura.FieldByName('ISKONTO2').AsFloat<>0) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGSadeceIskonto2Girilemez);
     Abort;
  end;
  if TabFatura.FieldByname('TUR').asstring='0' then   //hizmetse
     TabFatura.FieldByname('MIKTAR').AsFloat := TabFatura.FieldByname('ADET').AsFloat
  else begin //stoksa
     TabFatura.FieldByname('MIKTAR').AsFloat := Tablo.StokMiktarHesapla(TabFatura.FieldByname('URUNID').AsInteger,TabFatura.FieldByname('ADET').AsFloat,TabFatura.FieldByname('BIRIM').AsInteger);
     if (TabFatbaslik.FieldByname('TUR').AsInteger in [14, 15, 16, 119])and
        ((TabFatura.FieldByname('STOKDURUMDEGIS').AsBoolean)and(not Tablo.StokVarmi( TabFatura.FieldByName('URUNID').AsInteger,TabFatbaslik.FieldByName(cbStokDepo.DataBinding.DataField).AsInteger, TabFatura.FieldByName('MIKTAR').AsFloat - OncekiStokMiktar))) then
        abort;
  end;


  TutarIslemler;
  //bu böl?m her durumda ?al??mal?..

  if (TabFatura.FieldByName('TUR').AsInteger = 1)and(TabFatura.FieldByName('BIRIM').AsString<>'') then // stoksa
      TabFatura.FieldByName('MIKTAR').AsFloat :=(TabFatura.FieldByName('ADET').AsFloat + TabFatura.FieldByName('MF').AsFloat) * Tablo.StokCarpan(TabFatura.FieldByName('URUNID').AsInteger, TabFatura.FieldByName('BIRIM').AsInteger)
  else if TabFatura.FieldByName('TUR').AsInteger = 0 then  //Hizmetse
      TabFatura.FieldByName('MIKTAR').AsFloat :=(TabFatura.FieldByName('ADET').AsFloat + TabFatura.FieldByName('MF').AsFloat);

  if (not Eksiskontoya)and((TabFatura.FieldByName('ISKONTO').AsFloat<0)or(TabFatura.FieldByName('ISKONTO2').AsFloat<0)) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGEksiIskontoGirilemez);
     Abort;
  end;

  if TabFatura.FieldByName('IZLEME').Value = null then
     TabFatura.FieldByName('IZLEME').AsInteger := 0;
  if not IskontoyaDetayGiriliyor then begin
     if TabFatura.FieldByName('ISKONTO').OldValue <> TabFatura.FieldByName('ISKONTO').NewValue then
        veritabani.BasitKomutÇalıştır(tablo.FDCnn,'delete from ISKONTOLAR where YERI=&Yeri and YERID=&Yer_ID and TUR=&Tur'
                                   ,['&Yeri','&Yer_ID','&Tur'],[TabFatbaslik.FieldByName('TUR').AsInteger,TabFatura.FieldByName('ID').AsInteger,1]);
     if TabFatura.FieldByName('ISKONTO2').OldValue <> TabFatura.FieldByName('ISKONTO2').NewValue then
        veritabani.BasitKomutÇalıştır(tablo.FDCnn,'delete from ISKONTOLAR where YERI=&Yeri and YERID=&Yer_ID and TUR=&Tur'
                                   ,['&Yeri','&Yer_ID','&Tur'],[TabFatbaslik.FieldByName('TUR').AsInteger,TabFatura.FieldByName('ID').AsInteger,2]);
  end;

  //Boşluk Kontrolleri
  if not  BoslukKontrol(TabFatura.FieldByName('ADET').AsString, KontrolFaturaAdet) then
     Abort;
//  if not BoslukKontrol(FATURA.FieldByName('BIRIMFIYAT').AsString, KontrolBirimFiyati) then
//     Abort;
  if not BoslukKontrol(TabFatura.FieldByName('KDV').AsString, KontrolKDV) then
     Abort;
  if (TabFatbaslik.FieldByName('DURUM').AsInteger<>6)and(not SifirKontrol(TabFatura.FieldByName('ADET').AsFloat, KontrolFaturaAdet)) then
    Abort;
  if (TabFatbaslik.FieldByName('DURUM').AsInteger<>6)and(TabFatura.FieldByName('ADET').AsFloat <= 0) then
    raise Exception.create(Adetsifirolamaz);

  //İzlem bilgisi var mı bakalım serino vb.
   if (OncekiStokMiktar<>TabFatura.FieldByName('MIKTAR').AsFloat)and(TabFatura.FieldByName('IZLEME').AsInteger > 0 ) then begin
       if (BDDlg=nil)or((BDDlg<>nil)and((BDDlg.DonusumTuru = TabNo_DONUSUM_SATIS_SIPARIS_IRS)or(BDDlg.DonusumTuru = TabNo_DONUSUM_SATIS_SIPARIS_FAT)or(BDDlg.DonusumTuru = TabNo_DONUSUM_SATIS_SIPARIS_FIS)
                                         or (BDDlg.DonusumTuru = TabNo_DONUSUM_ALIS_SIPARIS_IRS)or(BDDlg.DonusumTuru = TabNo_DONUSUM_ALIS_SIPARIS_FAT)
                                         //or(BDDlg.DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_FIS)or(BDDlg.DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_FATURA)or(BDDlg.DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_IRSALIYE)
                                         or(BDDlg.DonusumTuru = TabNo_DONUSUM_SATIS_SIPARIS_KON)))   {d?n???m de?ilse} then
          StokIzlemBilgisi;
   end;
   if TabFatura.FieldByName('BIRIMFIYAT').AsString = '' then
      TabFatura.FieldByName('BIRIMFIYAT').Value := 0.0;
end;

procedure TFaturaWizardDlg.FATURANewRecord(DataSet: TDataSet);
begin
  TabFatura.FieldByName('FATBASID').AsInteger := TabFatbaslik.FieldByName('ID').AsInteger;
  TabFatura.FieldByName('REHBERID').AsInteger := RehberId;
  TabFatura.FieldByName('MERKEZID').AsInteger := TabFatbaslik.FieldByName('MERKEZID').AsInteger;
  TabFatura.FieldByName('GIRDEPO').AsInteger := TabFatbaslik.FieldByName('GIRISDEPO').AsInteger;
  TabFatura.FieldByName('CIKDEPO').AsInteger := TabFatbaslik.FieldByName('CIKISDEPO').AsInteger;
  TabFatura.FieldByName('EKLEYEN').AsString := Kullanan;
  TabFatura.FieldByName('PROJEID').AsInteger := TabFatbaslik.FieldByName('PROJEID').AsInteger;

  TabFatura.FieldByName('STOKDURUMDEGIS').AsBoolean := True;
//  FATURAISKONTO.OnChange := nil;
//  FATURAISKONTO2.OnChange := nil;
//  FATURA.FieldByName('ISKONTO').AsInteger := 0;
//  FATURA.FieldByName('ISKONTO2').AsInteger := 0;
//  FATURAISKONTO.OnChange := FATURAADETChange;
//  FATURAISKONTO2.OnChange := FATURAADETChange;
//  FATURA.FieldByName('KUR').AsString := CariDoviz;
  if not SatirVadesiKullan then
    TabFatura.FieldByName('VADE').Value := TabFatbaslik.FieldByName('VADE').Value
  else
    TabFatura.FieldByName('VADE').Value := '0';
  TabFatura.FieldByName('SUBEID').AsInteger := SubeID;
  TabFatura.FieldByName('KDVMUHAFIYETI').AsInteger := 0;
 // FATURA.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  if PozNoAktif then begin
     Tablo.TablodanSorguAc(1, 'select isnull(max(POZNO),0)+'+IntToStr(PozNoAralik)+' from FATURA where FATBASID='+TabFatbaslik.FieldByName('ID').AsString);
     TabFatura.FieldByName('POZNO').AsInteger := Tablo.Query1.Fields[0].AsInteger;
  end;
end;

procedure TFaturaWizardDlg.TabPlanAfterOpen(DataSet: TDataSet);
begin
  cxGrid1DBTableView1.DataController.Groups.FullExpand;
end;

procedure TFaturaWizardDlg.TamEkranTusClick(Sender: TObject);
begin
  PanelUst.Visible := not PanelUst.Visible;
  PanelAlt.Visible := PanelUst.Visible;
  if PanelUst.Visible then
    TamEkranTus.Caption := TamEkran
  else
    TamEkranTus.Caption := KucukEkran
end;

procedure TFaturaWizardDlg.FaturadanSatirGetir(Sender:TObject);
var
  FatTurGrubu:string;
  SQLStr:TArrayOfString;
  st, st2:Tstringlist;
  FatBasID,IzlemId, FatSatirID,YeniFatSatirID,DonusumYeri,StkDurumDegis, Adet, DepoIade:Integer;
  Mik : Variant;
  MikAdet : string[10];
  LotluUrunler : boolean;
begin
  if TabFatbaslik.State in [dsEdit, dsInsert] then begin
     TabFatbaslik.Post;
     TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
  end;
  case TabFatbaslik.FieldByName('TUR').AsInteger of
   11,12:begin
          FatTurGrubu := '(15,16)';
          if TabFatbaslik.FieldByName('TIPI').AsInteger=2 then begin
            DonusumYeri := TabNo_IADE_ALISBELGE;
            StkDurumDegis := 1;
          end else if TabFatbaslik.FieldByName('TIPI').AsInteger=3 then begin
            DonusumYeri := TabNo_FIYATFARKI_ALISBELGE;
            StkDurumDegis := 0;
          end else
            Exit
         end;
  15,16: begin
          FatTurGrubu := '(11,12)';
          if TabFatbaslik.FieldByName('TIPI').AsInteger=2 then begin
            DonusumYeri := TabNo_IADE_SATISBELGE;
            StkDurumDegis := 1;
          end else if TabFatbaslik.FieldByName('TIPI').AsInteger=3 then begin
            DonusumYeri := TabNo_FIYATFARKI_SATISBELGE;
            StkDurumDegis := 0;
          end else
            Exit
         end;
   109:  begin
            FatTurGrubu := '(119)';
            if TabFatbaslik.FieldByName('TIPI').AsInteger=2 then begin
              DonusumYeri := TabNo_IADE_ALISBELGE;
              StkDurumDegis := 1;
              LotluUrunler := Application.MessageBox('ürünlerde Lot takibi yapıyor mu?','BİLGİ', MB_YESNO+ MB_ICONQUESTION) = ID_YES;
            end else
              Exit
         end
   else Exit;
  end;


  SetLength(SQLStr,23);
  SQLStr[0] := 'select top 100 *';
  SQLStr[1] := '';
  SQLStr[2] := ' from ';
  SQLStr[3] := '	(	select ';
  SQLStr[4] := '			Kod=CASE WHEN F.TUR IN(1,11)THEN(SELECT KOD FROM STOKLAR WHERE ID=F.URUNID )ELSE(SELECT KOD FROM MASRAFGELIR WHERE ID=F.URUNID)END, ';
  SQLStr[5] := '			UrunNo=CASE WHEN F.TUR IN(1,11)THEN(SELECT URUNNO FROM STOKLAR WHERE ID=F.URUNID )ELSE '''' END, ';
  SQLStr[6] := '			Ad=CASE WHEN F.TUR IN(1,11)THEN(SELECT STOKADI FROM STOKLAR WHERE ID=F.URUNID )ELSE(SELECT AD FROM MASRAFGELIR WHERE ID=F.URUNID)END, ';
  SQLStr[7] := '			Barkod=CASE WHEN F.TUR IN(1,11)THEN(SELECT top 1 BARKOD FROM STOKBARKOD SB WHERE SB.VARSAYILAN=1 and SB.STOKID=F.URUNID )ELSE '''' END, ';
  SQLStr[8] := '			BelgeNo=FB.FATURASERI+FB.FATURANO,SS=FB.SAYFASAY,Tarih=FB.FATURATARIH, Adet=F.ADET, ';
  //SQLStr[8] := '		  Adet=F.ADET-isnull((select sum(F2.ADET) from FATURA F2 inner join FATBASLIK FB2 on F2.FATBASID=FB2.ID where FB2.TIPI=2 and F2.TUR=1 and F2.YERI in (416,417) and F2.YERID=F.ID),0.0), ';
  SQLStr[9] := '      Birim=F.BIRIM,Birimfiyat=F.BIRIMFIYAT,Isk1=ISKONTO,Isk2=ISKONTO2,MF,Tutar=F.TUTAR,  FBID=FB.ID, FID=F.ID, Personel=(select R3.FIRMA from REHBER R3 where R3.ID=F.SATICIKODU), ';
  SQLStr[10] := ' DepoID=FB.CIKISDEPO, Depo = (select DEPOADI from DEPOLAR where ID=FB.CIKISDEPO)';
  if (TabFatbaslik.FieldByName('TUR').AsInteger = 109)and(LotluUrunler=True) then
      SQLStr[11] := '	,Kalan=SI.KALAN, SL.LOTNO, SL.SERINO '   //konsinye iade ve lotlu ürün ise
  else
      SQLStr[11] := ' ';
  SQLStr[12] := '		from ';
  if (TabFatbaslik.FieldByName('TUR').AsInteger = 109)and(LotluUrunler=True) then begin //konsinye iade ve lotlu ürün ise
     SQLStr[13] := 'FATURA F INNER JOIN FATBASLIK FB on F.FATBASID=FB.ID '+
               'LEFT OUTER JOIN STOKIZLEME SI on SI.BASLIKID=F.FATBASID and SI.SATIRID=F.ID '+
               'LEFT JOIN REHBER R ON FB.REHBERID=R.ID '+
               'LEFT  JOIN REHBER R3 ON R3.ID = F.SATICIKODU '+

               'INNER JOIN STOKSERILOT SL ON SL.ID=SI.SERILOTID '+
               'INNER JOIN STOKDURUMIZLEME SDI ON SDI.SERILOTID=SL.ID AND SDI.STOKID = SI.STOKID '+

               'INNER JOIN STOKLAR S ON SI.STOKID=S.ID AND S.DURUM=1 '+
               'LEFT JOIN STOKBARKOD SB ON SB.STOKID = S.ID  AND SB.VARSAYILAN = 1  '+

               'INNER JOIN DEPOLAR D ON D.ID = SDI.DEPOID AND D.VARSAYILAN = 7 '; //KONS ?IKI? DEPOSU
              // 'LEFT JOIN STOK_ORT_MALIYET SOM ON SOM.STOKID = S.ID AND SOM.FATBASID = FB.ID AND SOM.FATURAID = F.ID AND SOM.DEPOID = D.ID '+
              // 'LEFT JOIN KATEGORI K ON K.ID = S.KATEGORI ';

    SQLStr[14] := '	  where  SI.KALAN>0 ';
  end
  else begin
     SQLStr[13] := 'FATBASLIK FB inner join FATURA F on F.FATBASID=FB.ID ';
     SQLStr[14] := '		where 1=1 ';
  end;

  SQLStr[15] := '	 and	FB.TUR in'+FatTurGrubu+' and FB.TIPI not in (2,3) '+
                '  and FB.REHBERID='+TabFatbaslik.FieldByName('REHBERID').AsString;

  if not TabFatura.IsEmpty then
     SQLStr[16] := '	and FB.ID in(select f0.FATBASID from FATURA f0 where f0.ID='+TabFatura.FieldByName('YERID').AsString+' ) ';
  SQLStr[17] := '     ) as asd ';
  SQLStr[18] := ' where ';
  SQLStr[19] := '   Adet>0.0 and ';
  SQLStr[20] := '	  (  (asd.BelgeNo like ''%<ara>%'')or ';
  SQLStr[21] := '	     (asd.Kod like ''%<ara>%'')or  (asd.UrunNo like ''%<ara>%'')or ';
  SQLStr[22] := '	     (asd.Ad like ''%<ara>%'')or  (asd.Barkod like ''%<ara>%''))  ';
 // SQLStr[23] := '	     (asd.Barkod like ''%<ara>%'')) ';
  st := Tstringlist.create;
  if Tablo.ListedenBilgiGetir(HizmetUrunSec,SQLStr,st,[nil,nil,nil,nil,nil,nil,nil,Tablo.repStokAnaBirim,nil,nil,nil,nil,nil,nil,nil],'FaturaWizardHizmetUrunSec') then begin
     IadeOlanUrununSatisTarihi := StrToDateTimeDef(st[6], Tablo.GENINI.BugunTrh-1000);
     FatBasID := StrToIntDef(st[14],0);
     FatSatirID := StrToIntDef(st[15],0);
     Adet  := StrToIntDef(st[7],1);
     DepoIade := StrToIntDef(st[17],0);
     //iade olan depoya bakalım konsinye giriş veya ıçıkış olamaz
     Tablo.TablodanSorguAc(1,'select VARSAYILAN from DEPOLAR where ID = '+IntToStr(DepoIade));
     if TabFatura.IsEmpty then begin ///eğer iade depo konsinye ise  veya bağlıktaki depodan farklıysa
         if (Tablo.Query1.Fields[0].AsInteger in [5,7])or(TabFatbaslik.FieldByName('GIRISDEPO').AsInteger <> DepoIade) then begin
            if Tablo.Query1.Fields[0].AsInteger in [5,7] then begin //konsinyeden iade ise giriş için depo sor
               st2 := Tstringlist.Create;
               if Tablo.ListedenBilgiGetir(SDStokGirisDepo, 'select ID,DEPOADI from DEPOLAR where VARSAYILAN=1 order by 2', St2,  []) then
                   DepoIade := StrToIntDef(St2[0], 0)
                else
                   DepoIade := VarsDepo;
                FreeAndNil(St2);
             end;
         TabFatbaslik.Edit;
         TabFatbaslik.FieldByName('GIRISDEPO').AsInteger := DepoIade;
         cbStokDepo.Enabled := False;
         end;
     end
     else
         if (TabFatbaslik.FieldByName('GIRISDEPO').AsInteger <> DepoIade)and(not DepoIade in [5,7]) then begin
            ShowMessage(SFarkli_isim_var);
            Abort;
         end;


     Tablo.TablodanSorguAc(7,'select * from FATURA where YERI in (416,417) and YERID='+IntToStr(FatSatirID));
     if not Tablo.Query7.IsEmpty then
      if Application.MessageBox(PChar(Uruniadeedilmisdevamedecekmisin),PChar(Uyari),MB_YESNO)=mrNo then
        Abort;
    Tablo.TablodanSorguAc(7,'select * from FATURA where YERI in (418,419) and YERID='+IntToStr(FatSatirID));
    if not Tablo.Query7.IsEmpty then
      if Application.MessageBox(PChar(Urunfiyatfarkivardevamedecekmisin),PChar(Uyari),MB_YESNO)=mrNo then
        Abort;
    if FatSatirID>0 then begin
       if Adet = 1 then  //iade edilen miktar 1 tane ise adet sormam?za gerek yok
          MikAdet := '1'
       else begin
            Mik := 1;
            if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(KWMiktariGirin, @Mik, OndalikDijitSayMik)) <> mrOk then
               Abort;
            MikAdet := VarToStr(Mik);
            MikAdet := StringReplace(MikAdet, ',', '.', []);
      end;
      //adeti 0 giriyoruz altta gerçek adet girilecek amaçı izlem bilgisini almaktır
      YeniFatSatirID := Tablo.SQLSatiriKopyala('FATURA',FatSatirID,['FATBASID','ADET','MIKTAR','YERI','YERID','STOKDURUMDEGIS', 'EKLEYEN','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
                  [TabFatbaslik.FieldByName('ID').AsInteger,-1,-1,DonusumYeri,FatSatirID,StkDurumDegis,Kullanan, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
                      'UPDATE FATBASLIK SET YERI=&Yeri,YERID=&Yer_ID,ANAKAYITID=&Yer_ID '
                      +',ACIKLAMA='''+st[4]+' nolu, '+st[6]+' tarihli belgeden iade'''
                      +' where ID=&FatBasID'
                      ,['&FatBasID','&Yeri','&Yer_ID']
                      ,[TabFatbaslik.FieldByName('ID').AsInteger,DonusumYeri,FatBasID]);

      FreeAndNil(St);

      TabloYenile(TabFatbaslik,[TabFatbaslik.FieldByName('ID').AsInteger]);
      TabloYenile(TabFatura,[TabFatbaslik.FieldByName('ID').AsInteger]);
      //iadelerde tutarların hesaplanması için

      if (TabFatbaslik.FieldByName('TIPI').AsInteger in [2, 3])and(TabFatura.Locate('ID',YeniFatSatirID,[])) then begin//iade ise
            TabFatura.Edit;
            TabFatura.FieldByName('ADET').AsString := MikAdet;    //VarToStr(Mik);
            TabFatura.FieldByName('MIKTAR').AsString := MikAdet;  //VarToStr(Mik);
            TabFatura.Post;
      end;
    end;
  end;
end;

procedure TFaturaWizardDlg.FaturaTipiDuzenle;
begin
  if ((ComboFatTipi.EditValue=4)or(ComboFatTipi.EditValue=7)or(ComboFatTipi.EditValue=8)) then
     LabelEkVergi.Caption := 'Stopaj'
  else
     LabelEkVergi.Caption := 'Ek Vergi';

  if TabFatura.Active then begin
     //ComboFatTipi.Enabled := (FATURA.RecordCount=0)and(Tur in[3,4,KasaTur_AlisFaturasi,KasaTur_SatisFaturasi,109]);
     //
     //btnFisIrsaliye.Enabled := FATBASLIK.FieldByName('TIPI').AsInteger = 1;

     if not(Tur in[3,4]) then begin
       (* if FATBASLIK.FieldByName('TIPI').AsInteger = 3 then begin
          FATURA.FieldByName('ADET').ReadOnly := True;
          //FATURAMIKTAR.ReadOnly := True;
          FATURA.FieldByName('MF').ReadOnly := True;
          FATURA.FieldByName('BIRIM').ReadOnly := True;
          GridFaturaViewADET1.Editing := False;
          GridFaturaViewMF.Editing := False;
          GridFaturaViewBIRIM1.Editing := False;
        end else begin *)
          TabFatura.FieldByName('ADET').ReadOnly := False;
          TabFatura.FieldByName('MIKTAR').ReadOnly := False;
          TabFatura.FieldByName('MF').ReadOnly := False;
          TabFatura.FieldByName('BIRIM').ReadOnly := False;
          GridFaturaViewADET1.Editing := True;
          GridFaturaViewMF.Editing := True;
          GridFaturaViewBIRIM1.Editing := True;
       // end;
      end;
  end;
end;

procedure TFaturaWizardDlg.LogKaydet;
begin
  if islemOp in ['D','I'] then begin
     //if LogBelge.Count > 0 then begin
     //   Tablo.LogIslemlerBelge(FATURA, TabNo, FaturaIDsi, 4);
     Tablo.LogIslemleri(TabloNo, TabFaturaIDsi, 4, TabFatbaslik)
  end;
end;

procedure TFaturaWizardDlg.KDVHaricTutargir1Click(Sender: TObject);
var
  Tutar,Kur: Variant;
  oran : real;
  YeniFiyatstr, Yuzde, Deger: String;
  YuzdeFloat:extended;
  PBirimleri:TStringList;
begin
   Kur := CariDoviz;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.create
        .CurrencyEdit(FWToplamTutariGir, @Tutar,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))
        .ComboBox(FWKurGir,@Kur,cbDovizCinsi.Properties.Items)) <> mrOk then
      Abort;


  Tutar := StringReplace(Tutar, ',', FormatSettings.Decimalseparator, [rfReplaceAll]);
  Tutar := StringReplace(Tutar, '.', FormatSettings.Decimalseparator, [rfReplaceAll]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,  ' update FATURA set ISKONTO=0.0, ISKONTO2=0.0, TUTAR=ADET*BIRIMFIYAT, DOVIZ_TUTARI=ADET*DOVIZ_BIRIMFIYAT where FATBASID=&id ', ['&id'], [TabFatbaslik.Fields[0].AsInteger]);
  TabloYenile(TabFatura,[TabFatbaslik.FieldByName('ID').AsInteger]);
  FaturaTutarHesapla(True);
  TabloYenile(TOPLAMLAR,[]);
  if TMenuItem(Sender).Tag = 0 then
     TOPLAMLAR.First
  else if TMenuItem(Sender).Tag = 1 then
     TOPLAMLAR.Last;

  if Kur = CariDoviz then
     Deger:='DEGER'
  else
     Deger:='DOVIZTUTARI';

  if ToplamGetir(2,'DEGER')>0 then begin // ÖTV Varsa
    oran:= ToplamGetir(10,'DEGER')/ToplamGetir(4,'DEGER');
    Tutar:= (StrToCurrDef(trim(Tutar),0)/oran)-ToplamGetir(2,'DEGER');
    YuzdeFloat := 100.0 * Tutar / ToplamGetir(1,'DEGER');
  end else
    YuzdeFloat := 100.0 * StrToCurrDef(trim(Tutar),0)/TOPLAMLAR.FieldByName(Deger).AsExtended;

  Yuzde := FExtToStr(YuzdeFloat);


  if (not Eksiskontoya)and(YuzdeFloat>100) then///eksi iskonto izni yoksa engel oluruz
    showmessage(BGEksiIskontoGirilemez)
  else begin
    Yuzde := StringReplace(Yuzde, ',', '.', []);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATURA set ISKONTO=100.0-'+Yuzde+',ISKONTO2=0.0, TUTAR='+Yuzde+'*ADET*BIRIMFIYAT/100.0, DOVIZ_TUTARI='+Yuzde+'*ADET*DOVIZ_BIRIMFIYAT/100.0 where FATBASID=&id ', [ '&id'], [ TabFatbaslik.Fields[0].AsInteger]);
  end;

  FaturaTutarHesapla(True);
  TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.FATBASLIKNewRecord(DataSet: TDataSet);
var   VNO, VD : Variant;
  EFat : Smallint;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
begin
  OncekiFaturaNo := '';
  Tablo.FATBASLIKYeniKayit(TabFatbaslik, RehberId, Tur, Tipi, -1,-1,cbIrsaliyeli.Checked,MasrafMerkezi, ServisId, ProjeId, AktiviteId);

  if Tur in [4,14, 15, 16, 119] then begin // ??k??
     Tablo.RehberIletisimAD(RehberId,REHBERILETID,REHBERILETAD,REHBERILETADHINT);
     TabFatbaslik.FieldByName('REHBERILETID').AsInteger := REHBERILETID ;
     EditButtonSevkAdresi.Text := REHBERILETAD;
     EditButtonSevkAdresi.Hint := REHBERILETADHINT;
  end;

  if Tur in [14,15] then begin //çıkan irs veya fatura
     if TabFatbaslik.FieldByName('VNO').AsString = '' then begin//eğer vergi no boş ise ekrandan hemen alalım
        VNO:='';
        if TGirisKutusuEx.BilgiAlEx('',TGirdiDenetimleri.Create.Edit(FWVNO+':', @VNO).Edit(FWVD+':', @VD)) = mrOk then
           TabFatbaslik.FieldByName('VNO').AsString := VarToStr(VNO);
           TabFatbaslik.FieldByName('VD').AsString := VarToStr(VD);
           Tablo.RehberBilgiGuncelle(TabFatbaslik.FieldByName('REHBERID').AsInteger,2,22,VarToStr(VNO));
     end;
     if (EFaturaKullanimda>0)or(EIrsaliyeKullanimda) then begin
         EFat := Tablo.EFaturami(TabFatbaslik.FieldByName('REHBERID').AsInteger, CarideEFatura, TabFatbaslik.FieldByName('VNO').AsString, TabFatbaslik.FieldByName('TIPI').AsInteger);
         if EFat = -1 then //sorgulama yapıld?ysa
            SatirEkle.Enabled := False
         else
            EFaturaIslem(EFat, True);
     end;
  end;
  // Yeni kayıtta EFATURADURUM her zaman 0 (Olustur'da 1/11/51 olarak set edilecek)
  if TabFatbaslik.State in [dsInsert, dsEdit] then
    TabFatbaslik.FieldByName('EFATURADURUM').AsInteger := 0;
end;

function TFaturaWizardDlg.IadeKontrolEt:Boolean;
begin
   if Tur in [15,16]=False then  //fat ve fi? de?ilse bakmaya gerek yok
       Result := False
   else begin
       Tablo.TablodanSorguAc(1, 'select FATURATARIH, FATURANO from FATBASLIK WHERE ANAKAYITID= '+TabFatbaslik.FieldByName('ID').AsString+' ORDER BY ID DESC ');
       Tablo.Query1.FetchAll;
       Result := Tablo.Query1.RecordCount>0;
       if Result then
          Showmessage('Bu faturaya bağlı iade faturalar vardır; Değiştirilemez!  Adet : '+IntToStr(Tablo.Query1.RecordCount)+
             ' Tarih : '+Tablo.Query1.FieldByName('FATURATARIH').AsString+'  Fatura No : '+Tablo.Query1.FieldByName('FATURANO').AsString);
   end;
end;

procedure TFaturaWizardDlg.Aman_Kilitle;
var i : smallint;
begin
    Kilit := True;
  //  FATBASLIK.Close;
  //  FATBASLIK.LockType := ltReadOnly;
  //  FATBASLIK.Open;
    if TabFatura.Active then
       TabFatura.Close;
    ToolBarAlet.visible := False;
    //GridFatura.PopupMenu := nil;
    for i := 0 to PopupMenuFatura.Items.count-1 do
        PopupMenuFatura.Items[i].enabled := PopupMenuFatura.Items[i].name = 'IzlemBilgileriniDzenleMenu';
    ToolBarAlet.PopupMenu := nil;
    BaslikPaneli.Enabled := False;
    DurumPaneli.Enabled := False;
    ComboSENARYO.Enabled := False;
    ComboFIYAT_LISTESI.Enabled := False;
    PanelAlt.Enabled := False;
    GridFaturaView.OnDblClick := nil;
   // PopupMenuFatura.Destroy;
end;

procedure TFaturaWizardDlg.FaturaEkrExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  KaydetTus.Click;
end;

procedure TFaturaWizardDlg.FaturaEkrNextButtonClick
  (Sender: TObject; var Stop: Boolean);
begin
  Stop := BoslukKontrolu;
end;

procedure TFaturaWizardDlg.TabFaturaCalcFields(DataSet: TDataSet);
const
  CalcNames: array[0..17] of string = (
    'AD','KOD','URUNNO','MALIYET','BIRIM2MIKTAR','BIRIM2AD','PROJEKODU','KAMPANYAADI','SATICIADI',
    'ECZANEBIRIMFIYAT','IMALATCIBIRIMFIYAT','DEPOCUBIRIMFIYAT','KDVTUTAR','BIRIMAD','ISKYAZI',
    'BARKOD','EKIPMAN','SERINO');
var
  I: Integer;
  Src, Dst: TField;
  Bmk: TBookmark;
begin
  // While posting, do not touch clone query on the same connection.
  if TabFatura.State in [dsInsert, dsEdit] then
    Exit;

  for I := Low(CalcNames) to High(CalcNames) do
  begin
    Dst := TabFatura.FindField(CalcNames[I]);
    if Dst <> nil then
      Dst.Clear;
  end;

  if (not FATURA.Active) or
     ((TabFatura.Params.FindParam('Par') <> nil) and (FATURA.Params.FindParam('Par') <> nil) and
      (VarToStr(FATURA.ParamByName('Par').Value) <> VarToStr(TabFatura.ParamByName('Par').Value))) then
  begin
    FATURA.Close;
    if (TabFatura.Params.FindParam('Par') <> nil) and (FATURA.Params.FindParam('Par') <> nil) then
      FATURA.ParamByName('Par').Value := TabFatura.ParamByName('Par').Value
    else if (TabFatbaslik.Active) and (FATURA.Params.FindParam('Par') <> nil) then
      FATURA.ParamByName('Par').AsInteger := TabFatbaslik.FieldByName('ID').AsInteger;
    FATURA.Open;
  end;
  if not FATURA.Active then
    Exit;

  if (TabFatura.FindField('ID') = nil) or TabFatura.FieldByName('ID').IsNull then
    Exit;

  Bmk := nil;
  FATURA.DisableControls;
  try
    Bmk := FATURA.GetBookmark;
    if not FATURA.Locate('ID', TabFatura.FieldByName('ID').AsInteger, []) then
      Exit;

    for I := Low(CalcNames) to High(CalcNames) do
    begin
      Dst := TabFatura.FindField(CalcNames[I]);
      Src := FATURA.FindField(CalcNames[I]);
      if (Dst <> nil) and (Src <> nil) then
        Dst.Value := Src.Value;
    end;
  finally
    if Assigned(Bmk) then
    begin
      FATURA.GotoBookmark(Bmk);
      FATURA.FreeBookmark(Bmk);
    end;
    FATURA.EnableControls;
  end;
end;
procedure TFaturaWizardDlg.TabFaturaIptalIsaretleClick(Sender: TObject);
var ID,IrsaliyeTur:integer;
begin
{  if FATBASLIK.FieldByName('TUR').AsInteger=15 then
    IrsaliyeTur := 14
  else if FATBASLIK.FieldByName('TUR').AsInteger=11 then
    IrsaliyeTur := 10
  else
    IrsaliyeTur := 0;
  if (IslemOp='I')or(Application.MessageBox(PChar(Belgeiptaledilsinmi),PChar(Uyari),MB_YESNO+MB_ICONQUESTION) = mrYes) then begin
    FATBASLIK.Edit;
    FATBASLIK.FieldByName('DURUM').AsInteger := 6;
    ID:= FATURA.FieldByName('ID').AsInteger;
    if IrsaliyeTur<>0 then begin
      Tablo.TablodanSorguAc(1,'select distinct FATBASID from FATURA where ID in(select YERID from FATURA where YERI in (408,411) and FATBASID='+FATBASLIK.FieldByName('ID').AsString+')');
      if (not Tablo.Query1.IsEmpty)and (Application.MessageBox(PChar(Irsaliyedefaturaileiptaledilsinmi),PChar(Uyari),MB_YESNO+MB_ICONQUESTION) = mrYes) then begin
        Tablo.Query1.First;
        while not Tablo.Query1.Eof do begin
          Tablo.FaturaSihirbazBaslat('I',IrsaliyeTur,0,Tablo.Query1.Fields[0].AsInteger,FATBASLIK.FieldByName('REHBERID').AsInteger,1,False,0);
          Tablo.Query1.Next;
        end;
      end;
    end;
    while not FATURA.IsEmpty do
      FATURA.Delete;
  end;
  ModalResult := MrOk; }
end;

procedure TFaturaWizardDlg.FaturaKoanAyarlar1Click(Sender: TObject);
begin
  Tablo.KocanAyarlariniGetir(TabFatbaslik.FieldByName('TUR').AsInteger);

end;

procedure TFaturaWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TFaturaWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
  Kota,Bakiye:currency;
  Say:integer;
   procedure EkipmanKaydet;
   var i : smallint;
       Marka,Model : String;
   begin
      //daha önce kaydedildiyse açalım
    //  Tablo.TablodanSorguAc(8,'select top 1 ID from EKIPMANREHBER where REHBERID='+FATBASLIK.FieldByName('REHBERID').AsString+' and SATISNO='''+FATBASLIK.FieldByName('FATURANO').AsString+''' ');
    //  if Tablo.Query8.RecordCount>0  then exit;

      Tablo.TablodanSorguAc(8,'select E.ID,FB.REHBERID,EKLEYEN='+Kullanan+',USTID=0,SERINO=0,GARANTIBITTAR=case when isnull(S.GARANTISURESI,0)>0 then  '+
          ' DATEADD(month, GARANTISURESI, FB.FATURATARIH) else null end, SATISTARIHI=FB.FATURATARIH ,SATISNO=FB.FATURANO,E.SAHIP,' +
          ' MARKA=isnull(E.MARKA,''-999''), MODEL=isnull(E.MODEL,''-999''), F.ADET, S.STOKADI  '+
          ' from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID inner join STOKLAR S on F.URUNID=S.ID inner join EKIPMANLAR E on S.ID = E.URUNID '+
          ' where FB.ID='+TabFatbaslik.FieldByName('ID').AsString+' and E.ID not in (select ER.EKIPMANID from EKIPMANREHBER ER where ER.REHBERID='+TabFatbaslik.FieldByName('REHBERID').AsString+' and SATISNO='''+TabFatbaslik.FieldByName('FATURANO').AsString+''')');
      Marka := Tablo.Query8.FieldByName('MARKA').AsString;
      if Marka = '-999' then Marka :='Null';
      Model := Tablo.Query8.FieldByName('Model').AsString;
      if Model = '-999' then Model :='Null';

      if not Tablo.Query8.IsEmpty  then
         while not Tablo.Query8.EOF do begin
           if Application.MessageBox(PChar(Tablo.Query8.FieldByName('STOKADI').AsString+' '+Musteriekipmanaeklensinmi), PChar(onay), MB_YESNO + MB_ICONQUESTION) = ID_YES then
              for i := 1 to Tablo.Query8.FieldByName('ADET').AsInteger do
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into EKIPMANREHBER (EKIPMANID,REHBERID,EKLEYEN,USTID,GARANTIBITTAR,SATISTARIHI,SATISNO,SAHIP,MARKA,MODEL) values'+
                  '('+Tablo.Query8.FieldByName('ID').AsString+','+Tablo.Query8.FieldByName('REHBERID').AsString+','+Tablo.Query8.FieldByName('EKLEYEN').AsString+','+
                      Tablo.Query8.FieldByName('USTID').AsString+','''+FormatDateTime('yyyy-mm-dd',Tablo.Query8.FieldByName('GARANTIBITTAR').AsDateTime)+''','''+
                      FormatDateTime('yyyy-mm-dd',Tablo.Query8.FieldByName('SATISTARIHI').AsDateTime)+''','''+
                      Tablo.Query8.FieldByName('SATISNO').AsString+''','+IntToStr(Abs(StrToInt(BoolToStr(Tablo.Query8.FieldByName('SAHIP').AsBoolean))))+','
                  +Marka+','+Model+')',[],[]);
          Tablo.Query8.Next;
         end;
      {FATURA.First;
      while not FATURA.EOF do begin
        Tablo.TablodanSorguAc(1,'select EKIPMAN from STOKLAR where ID='+FATURA.FieldByName('URUNID').AsString);
        if Tablo.Query1.Fields[0].AsBoolean=True then begin
           Tablo.TablodanSorguAc(2,'select TOP 1 ID from EKIPMANREHBER where REHBERID='+FATBASLIK.FieldByName('REHBERID').AsString+' AND SATISNO='''+FATBASLIK.FieldByName('FATURANO').AsString+''' ');
           if (Tablo.Query2.IsEmpty)and(Application.MessageBox(PChar(FATURA.FieldByName('AD').AsString+' '+Musteriekipmanaeklensinmi), PChar(onay), MB_YESNO + MB_ICONQUESTION) = ID_YES) then
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into EKIPMANREHBER (EKIPMANID,REHBERID,EKLEYEN,USTID,SERINO,GARANTIBITTAR,SATISTARIHI,SATISNO,SAHIP,MARKA,MODEL) '+
                  ' select E.ID,'+FATBASLIK.FieldByName('REHBERID').AsString+','+Kullanan+',0,0,GARANTIBITTAR=case when isnull(GARANTISURESI,0)>0 then  DATEADD(month,GARANTISURESI,'''+FormatDateTime('yyyy-mm-dd hh:nn',FATBASLIK.FieldByName('FATURATARIH').AsDateTime)+''') else null end,'+
                  ' SATISTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn',FATBASLIK.FieldByName('FATURATARIH').AsDateTime)+''' ,SATISNO='''+FATBASLIK.FieldByName('FATURANO').AsString+''',E.SAHIP,E.MARKA,E.MODEL from STOKLAR S inner join EKIPMANLAR E on S.ID = E.URUNID '+
                  ' where S.ID='+FATURA.FieldByName('URUNID').AsString,[],[]);
        end;
        FATURA.Next;
      end;

select D.*,G.ANAHTAR from DURUMBAGLANTI D inner join GENINI G on G.BOLUM=D.BOLUM and G.DIL=-1
if not exists (select * from EKIPMANREHBER where REHBERID=1046 and SATISNO='580106') begin
insert into EKIPMANREHBER (EKIPMANID,REHBERID,EKLEYEN,USTID,SERINO,GARANTIBITTAR,SATISTARIHI,SATISNO,SAHIP,MARKA,MODEL)
select E.ID,FB.REHBERID,EKLEYEN=2,USTID=0,SERINO=0,GARANTIBITTAR=case when isnull(S.GARANTISURESI,0)>0 then  DATEADD(month, GARANTISURESI, FB.FATURATARIH) else null end,
SATISTARIHI=FB.FATURATARIH ,SATISNO=FB.FATURANO,E.SAHIP,E.MARKA,E.MODEL, F.ADET
from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID inner join STOKLAR S on F.URUNID=S.ID inner join EKIPMANLAR E on S.ID = E.URUNID
where FB.ID=2269
end}
   end;
begin
   if (((TabFatbaslik.FieldByName('TUR').AsInteger=15)and (TabFatbaslik.FieldByName('EFATURADURUM').AsInteger>0))or
      ((TabFatbaslik.FieldByName('TUR').AsInteger=14)and (EIrsaliyeKullanimda)))
       and(TabFatbaslik.FieldByName('SENARYO').AsInteger<1) then begin
       showmessage(SenaryoSecin);
       Abort;
   end;

//AO 05.10.2025 ?TS kullan?mda ve bildirimi olan ürün varsa senaryo yu otomatik ilaç_t?bbicihaz yapacağız..
  if (UTSKullanimda) and (TabFatbaslik.FieldByName('TUR').AsInteger=15)and (TabFatbaslik.FieldByName('EFATURADURUM').AsInteger in [1,21]) then begin
     if Veritabani.VeriVarMi(Tablo.FDCnn,'select  F.ID, F.IZLEME, S.BILDIRIM from FATURA F inner join STOKLAR S on S.ID = F.URUNID '+
                         ' where FATBASID = '+TabFatbaslik.Fields[0].AsString+' and F.TUR>0 and S.BILDIRIM=2 ',[],[])then begin
        if TabFatbaslik.FieldByName('SENARYO').AsInteger<>8 then begin  //ilaç t?bbicihaz de?ilse
           Tablo.TablodanSorguAc(1,'SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA '+
            ' AND RA.YERI=RB.YERI WHERE RB.YER_ID='+TabFatbaslik.FieldByName('REHBERID').AsString+' AND RA.VARSAYILAN=1');
           if Tablo.Query1.IsEmpty then begin
             // Snryo := Tablo.GENINI.DegerGetir(EFatura_Senaryo,-1, tabCariBilgileri.FieldByName('SENARYO').AsString, 1);;
              TabFatbaslik.Edit;
              TabFatbaslik.FieldByName('SENARYO').AsInteger := 8;
              showmessage(EFatSenaryoDegisti);
           end;
           //  showmessage(EFatBildirimliUrunTesbiti);
        end
      end
     else //bildirimli veri yoksa ama senaryo tıbbi cihaz seçildiyse kaydetmesin değiştirsin
        if TabFatbaslik.FieldByName('SENARYO').AsInteger = 8 then begin
           showmessage(EFatSenaryoUygunDegil);
           Abort;
        end;
   end;
  if TabFatbaslik.FieldByName('EFATURASONUC').AsInteger = 20 then begin
     TabFatbaslik.edit;
     TabFatbaslik.FieldByName('EFATURASONUC').AsInteger := 0;
  end;
  KaydetTusClick(Self);
  //daha ?nce var m? denetimi
  Say :=  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select SAY=count(*) from FATBASLIK where DURUM <> 6 '
                +' and TUR='+ TabFatbaslik.FieldByName('TUR').AsString
                +' and floor(convert(float,FATURATARIH))+2='+IntToStr(Trunc(TabFatbaslik.FieldByName('FATURATARIH').AsDateTime))
                +' and REHBERID='+ TabFatbaslik.FieldByName('REHBERID').AsString
                +' and FATURA_TUTARI='+FCurrToStr(TabFatbaslik.FieldByName('FATURA_TUTARI').AsCurrency)
          ,[],[],True);
  if Say>1 then begin
     if Application.MessageBox(PChar(MukerrerKayit), PChar(''), MB_YESNO) = IDNO then begin
        IptalSecildi := True;
        //ModalResult := mrCancel;
        exit;
     end;
  end;


  LogKaydet;
  if (Tur in[11,12,15,16])and(not TabFatura.IsEmpty)and(TabFatbaslik.FieldByName('ACIK_KAPALI').AsBoolean=True)and(Onceki_ACIK_KAPALI=False) then
      TahsilatAlindi:=Tablo.TahsilatIslemi(Tur,TabFatbaslik.FieldByName('REHBERID').AsInteger,TabFatbaslik.FieldByName('MASRAFID').AsInteger,TabFatbaslik.FieldByName('FATURA_TUTARI').AsCurrency,
              TabFatbaslik.FieldByName('KUR').AsString,TabFatbaslik.FieldByName('ACIKLAMA').AsString, TabFatbaslik.FieldByName('FATURATARIH').AsDateTime);

  if IslemOp = 'K' then
     BoslukKontrolu;
  if (TabFatura.Recordcount<1)and(IslemOp<>'I') then
    raise Exception.create(UrungirilmedenKaydedilemez);
  if DETAY.State in [dsInsert, dsEdit] then
    DETAY.Post;
  if EkleDetay then begin
    Ekle(DETAY, Tablo.FaturaDetaySablonTipiBul(Tur), TabFatbaslik.FieldByName('ID').AsInteger, 'Değiş');
    EkleDetay := False;
  end;

  //Satışıta ekipmanlar varsa; müşteri cari kaydına eklenir //silmede de çıkarşılır
  if TabFatbaslik.FieldByName('TUR').AsInteger = 15 then
     EkipmanKaydet;

  if not KilitKontrolEt(1,Tur,EditFatTarih.Date,2) then begin
     IptalSecildi := False;
     ModalResult := mrOk;
  end;

  if TabFatbaslik.FieldByName('TUR').AsInteger in[14,15,16] then begin
    Kota := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select TUTAR=isnull((select top 1 TUTAR from REHBER_KOTA where REHBERID=:PRehberID and KUR=:PKur),0.0)',[':PRehberID',':PKur'],[TabFatbaslik.FieldByName('REHBERID').AsInteger,CariDoviz],True);
    if Kota>0.0 then begin
      Bakiye := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select TUTAR=isnull((select TUTAR=sum(DOVIZ_TUTARI) from REHBER_BAKIYE where REHBERID=:PRehberID),0.0)',[':PRehberID'],[TabFatbaslik.FieldByName('REHBERID').AsInteger],True);
      if ((TabFatbaslik.FieldByName('TUR').AsInteger=14) and (Kota < Bakiye+TabFatbaslik.FieldByName('FATURA_TUTARI').AsCurrency))or ((TabFatbaslik.FieldByName('TUR').AsInteger in[15,16])and (Kota<Bakiye)) then
        Tablo.UyariGoster(Uyari,'Firma Risk Limiti   :'+Format('%m',[Kota])+CariDoviz+#13#10+'Firma Bakiyesi:'+Format('%m',[Bakiye])+CariDoviz+#13#10+
                                'Risk Limiti aşımı. Lütfen "Risk Limiti" bilgilerini güncelleyin.',1)
    end;
  end;
  //faturası oluşan irsaliye maliyetleri için kaynak belgeyi dırterek triggerı aktive ediyoruz!
  if (TabFatbaslik.FieldByName('TUR').AsInteger in[11,15]) and (not TabFatura.IsEmpty) then begin
    TabFatura.First;
    while not TabFatura.Eof do begin
      if (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_ALIS_IRS_FAT) or (TabFatura.FieldByName('YERI').AsInteger = TabNo_DONUSUM_SATIS_IRS_FAT) then
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set STOKDURUMDEGIS=STOKDURUMDEGIS where ID='+TabFatura.FieldByName('YERID').AsString,[],[],False,nil);
      TabFatura.next;
    end

  end;
end;

function TFaturaWizardDlg.BoslukKontrolu: Boolean;
var
  i: Int64;
  s: string[20];
  belgenosonuc: string;
begin
  BoslukKontrolu := True;

  if  ((TabFatbaslik.FieldByName('TUR').AsInteger=3) and (TabFatbaslik.FieldByName('TIPI').AsInteger=17)) or
      ((TabFatbaslik.FieldByName('TUR').AsInteger=4) and (TabFatbaslik.FieldByName('TIPI').AsInteger=16)) then
    Exit(False);

  if (Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Depo)) then begin
    if (cbStokDepo.DataBinding.DataField<>'')and(not BoslukKontrol(TabFatbaslik.FieldByName(cbStokDepo.DataBinding.DataField).AsString, Depo)) then
       Abort;
    if (cbStokDepo2.DataBinding.DataField<>'')and(cbStokDepo2.Visible)and(not BoslukKontrol(TabFatbaslik.FieldByName(cbStokDepo2.DataBinding.DataField).AsString, Depo)) then
       Abort;
  end;
{  if YearOf(FATBASLIK.FieldByName('FATURATARIH').AsDateTime) < YearOf(Tablo.GENINI.BugunTrh) then
     if (GecmiseEkleme=False)and(YeniYilDevriVar) then begin
         Application.MessageBox(Pchar(FWKayitBelgeYilindanFarkliOlamaz),pchar(Uyari),MB_OK);
         Abort;
     end
  else if (GelecegeEkleme=False)and(YearOf(FATBASLIK.FieldByName('FATURATARIH').AsDateTime) > YearOf(Tablo.GENINI.BugunTrh)) then begin
         Application.MessageBox(Pchar(FWKayitveBelgeTarihiIleriTarihOlamaz),pchar(Uyari),MB_OK);
         Abort;
  end; }

  if not TarihKontrol(EditFatTarih.Date, Belge + KontrolTarihi) then
     Abort;

  if (ComboFIYAT_LISTESI.visible)and(Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_FiyatAdi)) and not BoslukKontrol(ComboFIYAT_LISTESI.Text, LabelFIYAT_LISTESI.Caption) then  //  KontrolFiyatListeAdi
     Abort;
  if (Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Baslik)) and not BoslukKontrol(EditBASLIK.Text, Belge + FWBasligi) then
     Abort;
  if (Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Adres)) and not BoslukKontrol(MemoFatAdres.Text, FWAdresi) then
     Abort;
  if (Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Ilce)) and not BoslukKontrol(EditIlce.Text, FWIlcesi) then
     Abort;
  if (Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Il)) and not BoslukKontrol(EditIl.Text, FWIli) then
     Abort;
  s := StringReplace(EditVNO.Text, ' ','',[rfReplaceAll]);//e??er vno=11 ise yani tcno ise vd bakmay?z
  if (Length(s)<> 11)and(Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_VD)) and not BoslukKontrol(EditVD.Text, FWVD) then
     Abort;
  if (Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_VNo)) and not BoslukKontrol(EditVNO.Text, FWVNO) then
     Abort;

  if (EditVade.visible)and(Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bosluk_Vade,False)) and not BoslukKontrol(EditVade.Text, FWVade) then
     Abort;

  if not BoslukKontrol(EditFatTarih.Text, Belge + KontrolTarihi) then
     Abort;

  EditFATURASERI.PostEditValue;
  ComboFaturaDURUM.PostEditValue;
  ComboEFATURADURUM.PostEditValue;
  if not BoslukKontrol(TabFatbaslik.FieldByName('FATURANO').AsString, Belge + KontrolNo) then
     Abort;
  if (TabFatbaslik.FieldByName('EFATURADURUM').AsInteger = 0)and(StrToInt64Def(TabFatbaslik.FieldByName('FATURANO').AsString, -999999) = -999999) then begin
     ShowMessage(Belgenogirisiyanlis);
     Abort;
  end;
  if (TabFatbaslik.FieldByName('EFATURADURUM').AsInteger = 0)and(Tur in [14, 15, 16]) then begin
    i := StrToInt64Def(TabFatbaslik.FieldByName('FATURANO').AsString, -1);
    if i = -1 then begin
      ShowMessage(FWSadeceRakamGir);
      Abort;
    end;
    if TabFatbaslik.Fields[0].AsString <> '' then
      s := ' and ID <> ' + TabFatbaslik.Fields[0].AsString
    else
      s := '';

    if (OncekiFaturaNo <> TabFatbaslik.FieldByName('FATURANO').AsString)and( TabFatbaslik.FieldByName('FATURASERI').AsString <> '*')
       and (TabFatbaslik.FieldByName('FATURANO').AsString <> '0') then begin
      belgenosonuc := BelgeNoKullanilmismi
        (TabFatbaslik.FieldByName('ID').AsInteger, TabFatbaslik.FieldByName('TUR').AsInteger, TabFatbaslik.FieldByName('KOCANNO').AsInteger,
        TabFatbaslik.FieldByName('FATURATARIH').AsDateTime, TabFatbaslik.FieldByName('FATURANO').AsString, TabFatbaslik.FieldByName('FATURASERI').AsString);

      // Tablo.TablodanSorguAc(1, ' select TARIH from FATBASLIK where FATURASERI='''+FATBASLIK.FieldByName('FATURASERI').AsString+''' and FATURANO ='''+FATBASLIK.FieldByName('FATURANO').AsString+''' '+s);
      if belgenosonuc <> '' then begin
        ShowMessage(belgenosonuc);
        Abort;
      end;
    end;
  end;
  BoslukKontrolu := False;
end;

procedure TFaturaWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabloNo, TabFatbaslik.FieldByName('ID').AsInteger, TabFatbaslik.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TFaturaWizardDlg.BtnDovizClick(Sender: TObject);
begin
  Tablo.DovizDegistir(TabFatbaslik, TabFatura, 'RAPORDOVIZ', 'FATURATARIH','FATURA', 'FATBASID');
  FaturaTutarHesapla(True);
end;

procedure TFaturaWizardDlg.BtnEfaturaClick(Sender: TObject);
var EfatID:Integer;
    Etiketler, Bilgiler: TArrayOfString;
    YeniMail:Variant;
    MailAdr:String;
const
  INVOICE_NEW = $0001;
  INVOICE_SENT_OR_RECEVIED = $0002;
  INVOICE_ACCEPTED = $0010;
  INVOICE_REJECTED = $0020;
  INVOICE_CANCELED = $0400;
begin
    KaydetTus.Click;
    if EFaturaKullanimda in [11,31] then begin
       Tablo.RehberEkBilgileriniGetir(TabFatbaslik.FieldByName('REHBERID').AsInteger, 1, [46], Etiketler, Bilgiler);
       MailAdr := Bilgiler[0];
       if MailAdr='' then begin
          if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,
                 TGirdiDenetimleri.Create.Edit(BGMail_adres_gir, @YeniMail)) <> mrOk then
             Abort
          else
             MailAdr:= Trim(VarToStr(YeniMail));

          if (pos('@', MailAdr)=0)or(pos('.', MailAdr)=0)or(pos(' ', MailAdr)<>0) then begin
              showmessage(MGHatalikayit);
              abort;
          end
          else
              Tablo.RehberBilgiGuncelle(TabFatbaslik.FieldByName('REHBERID').AsInteger,1,46,MailAdr);
       end;
    end;

    if(not _apiInitialized) then begin
      _apiInitialized := True;
      InitializeApi(1,1);
    end;

     OpenInvoice(TabFatbaslik.fieldByName('ID').asstring, EfatID);
     showInvoicePreview(EfatID);
     if TestInvoiceStatus(EfatID, INVOICE_SENT_OR_RECEVIED) then begin
        FaturaEkr.VisibleButtons :=[bkfinish];
        //FATURA G?NDER?LM??
        Aman_Kilitle;
     end;
     //else
     //   G?NDER?LMEM??
      CloseInvoice(EfatID); //Session kapan?yor
end;

procedure TFaturaWizardDlg.btnDonusturClick(Sender: TObject);
begin
  if TabFatbaslik.State in [dsEdit, dsInsert] then
     TabFatbaslik.Post;
  if TabFatura.State in [dsEdit, dsInsert] then
     TabFatura.Post;

  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.RehID := TabFatbaslik.FieldByName('REHBERID').AsInteger;
  BDDlg.HedefBaslikID := TabFatbaslik.FieldByName('ID').AsInteger;
  BDDlg.TabKaynakBaslik := TabFatbaslik;
  BDDlg.TabDetayGiris := TabFatura;
  BDDlg.GDepo := StrToIntDef(VarToStrDef(TabFatbaslik.FieldByName('GIRISDEPO').Value,'0'),0);
  BDDlg.CDepo := StrToIntDef(VarToStrDef(TabFatbaslik.FieldByName('CIKISDEPO').Value,'0'),0);
  BDDlg.HedefBaslikTur := TabFatbaslik.FieldByName('TUR').AsInteger;
//  BDDlg.cbCagiranTur := FATBASLIK.FieldByName('TUR').AsInteger;
  BDDlg.ShowModal;
  FreeAndNil(BDDlg);

  TabFatbaslik.Edit;
//  if FATURA.RecordCount>0 then
//    ComboRaporDoviziPropertiesCloseUp(Sender);
end;

procedure TFaturaWizardDlg.EditButtonSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  SQLText:String;
  st:TStringList;
begin
  if Not (TabFatbaslik.State in [dsEdit,dsInsert]) then
    TabFatbaslik.Edit;
  if AButtonIndex = 0 then begin
    try
      st:=TStringList.Create;
      SQLText:='select ID,AD,'+
        ' ADRES=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=2),'+
        ' ILCE=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=6),'+
        ' IL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=8),'+
        ' ID_VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=20),'+
        ' ID_VERGINO=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=22)'+
        ' FROM REHBERILETISIM Firma where REHBERID='+IntToStr(RehberId)+' ';
      if Tablo.ListedenBilgiGetir('Adres Seçiniz.',SQLText,st,[],'FWizardAdresSecimi',IletisimEkleClick,Tablo.FDCnn,IletisimEkleClick) then begin
         TabFatbaslik.FieldByName('REHBERILETID').AsString:=st.Strings[0];
         EditButtonSevkAdresi.Text := st.Strings[1];
      end;
    finally
      st.free;
    end;
  end else if AButtonIndex=1 then begin
    TabFatbaslik.FieldByName('REHBERILETID').AsInteger := 0;
    EditButtonSevkAdresi.Text := '';
  end;
end;

procedure TFaturaWizardDlg.IletisimEkleClick(Sender: TObject);
var
  Id : integer;
  Ad : string;
begin
  Tablo.IletisimEkle(RehberId, Id, Ad);
  TabFatbaslik.FieldByName('REHBERILETID').AsInteger := Id;
  EditButtonSevkAdresi.Text := Ad;
end;

procedure TFaturaWizardDlg.info1Click(Sender: TObject);
begin
       Tablo.InfoGoster('FATURA',  TabFatura.FieldByName('ID').AsInteger)
end;

procedure TFaturaWizardDlg.BtnSilPlanClick(Sender: TObject);
var
  i,ID,Recordindex:integer;
begin
  if cxGrid1DBTableView1.DataController.GetSelectedCount > 0 then begin
    if Application.MessageBox(PChar(Secilisatirlarsilinsinmi),PChar(Onay), MB_YESNO) = IDYES then begin
        for I := 0 to cxGrid1DBTableView1.DataController.GetSelectedCount - 1 do begin
           Recordindex := cxGrid1DBTableView1.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
           ID := cxGrid1DBTableView1.DataController.Values[Recordindex,cxGrid1DBTableView1ID.Index];

           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where TUR in (61,71) and FATURAID='+TabFatbaslik.FieldByName('ID').AsString+' and ID='+inttoStr(ID)+' ',[],[]);
        end;
      TabPlan.Close;
      TabPlan.Open;
    end;
  end;
end;

procedure TFaturaWizardDlg.BtnYeniPlanClick(Sender: TObject);
var
  PlanID: Integer;
  EkleDegistir: Char;
  Aciklama: string;
  Tarih:TDateTime;
begin
  if TabFatbaslik.FieldByName('PLANID').AsString <> '' then begin
    EkleDegistir := 'E';
    PlanID := TabFatbaslik.FieldByName('PLANID').AsInteger;
  end else begin
    EkleDegistir := 'D';
    PlanID := -1;
  end;
  if Tur in [14, 15, 16] then begin
      Tarih:=EditFatTarih.Date;
      PlanID := Tablo.KasaSihirbazBaslat(EkleDegistir, PlanID, 61, 0, TabFatbaslik.FieldByName('REHBERID').AsInteger, Tarih,
      Tablo.GENINI.BugunTrhSaat, 0, TabFatbaslik.FieldByName('FATURA_TUTARI').AsExtended, TabFatbaslik.FieldByName('KUR').AsString,
      EditFATURASERI.Text + EditFatNo.Text + ' '+FWNoluFatura, TabFatbaslik.FieldByName('ID').AsInteger, TabFatbaslik.FieldByName('MASRAFID').AsInteger);
  end else begin
      Tarih:=EditFatTarih.Date;
    PlanID := Tablo.KasaSihirbazBaslat(EkleDegistir, PlanID, 71, 0, TabFatbaslik.FieldByName('REHBERID').AsInteger, Tarih,
      Tablo.GENINI.BugunTrhSaat, 0, TabFatbaslik.FieldByName('FATURA_TUTARI').AsExtended, TabFatbaslik.FieldByName('KUR').AsString,
      EditFATURASERI.Text +  EditFatNo.Text +' '+ FWNoluFatura, TabFatbaslik.FieldByName('ID').AsInteger, TabFatbaslik.FieldByName('MASRAFID').AsInteger);
  end;
  //efaturada patlad?
  //if FATBASLIK.State = dsBrowse then
  //  FATBASLIK.Edit;
  //FATBASLIK.FieldByName('PLANID').AsInteger := PlanID;
  TabloYenile(TabPlan,[TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.cbBelgeTipiPropertiesCloseUp(Sender: TObject);
begin
  if Tur in [109, 119] then //Gelen/Giden konsinye
     KonsinyeTipiDuzenle
  else
     FaturaTipiDuzenle;
end;

procedure TFaturaWizardDlg.cbDovizCinsiPropertiesEditValueChanged(Sender: TObject);
begin
  if TabFatbaslik.State in [dsEdit] then begin
     TabFatbaslik.Post;
     TabloYenile(TabFatbaslik,[TabFatbaslik.FieldByName('ID').AsInteger]);
  end;
end;

procedure TFaturaWizardDlg.cbDovizCinsiPropertiesInitPopup(Sender: TObject);
begin
   EkstreDoviziDuzenle(Sender);
end;

procedure TFaturaWizardDlg.cbIrsaliyeliPropertiesEditValueChanged(Sender: TObject);
begin
  if TabFatbaslik.State = dsEdit then
     TabFatbaslik.Post;
end;

procedure TFaturaWizardDlg.cbKdvDurumPropertiesCloseUp(Sender: TObject);
var
  s: string[1];
begin
  if (TabFatbaslik.Fields[0].AsString <> '') and (OncekiKDVDurumu <> cbKdvDurum.Text) then begin
    Tablo.Query1.Close;
    if (OncekiKDVDurumu='Hari?')and(cbKdvDurum.Text='Dahil') then
      s := '*'
    else if (OncekiKDVDurumu='Dahil')and(cbKdvDurum.Text='Hari?') then
      s := '/'
    else if (OncekiKDVDurumu='Dahil')and(cbKdvDurum.Text='Muaf') then
      s := '/'
    else if (OncekiKDVDurumu='Muaf')and(cbKdvDurum.Text='Dahil') then
      s := '*'
    else
      s := '';
    if S <> '' then begin
      Tablo.Query1.SQL.Text := ' Update FATURA set '
        +'BIRIMFIYAT=BIRIMFIYAT '+s+' (1.0+(KDV*((100.0-KDVMUHAFIYETI)/100)/100.0)), '
        +'TUTAR=ADET*((100.0-ISKONTO)*(100.0-ISKONTO2)/10000.0)*BIRIMFIYAT '+s+' (1.0+(KDV*((100.0-KDVMUHAFIYETI)/100)/100.0)), '
        +'DOVIZ_BIRIMFIYAT = DOVIZKURDEGERI*BIRIMFIYAT '+s+' (1.0+(KDV*((100.0-KDVMUHAFIYETI)/100)/100.0)), '
        +'DOVIZ_TUTARI=DOVIZKURDEGERI*ADET*((100.0-ISKONTO)*(100.0-ISKONTO2)/10000.0)*BIRIMFIYAT '+s+' (1.0+(KDV*((100.0-KDVMUHAFIYETI)/100)/100.0)) '
        +'Where FATBASID=' + TabFatbaslik.Fields[0].AsString;
      Tablo.Query1.ExecSQL;
      TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
    end;
   FaturaTutarHesapla(True);
  end;
end;

procedure TFaturaWizardDlg.cbKdvDurumPropertiesInitPopup(Sender: TObject);
begin
  OncekiKDVDurumu := TabFatbaslik.FieldByName('KDVDURUM').AsString;
end;

procedure TFaturaWizardDlg.cbSaticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,TabFatbaslik,'SATICIKODU');
  if TabFatbaslik.FieldByName('SATICIKODU').AsInteger > 0 then
    if Tablo.UyariGoster('Personel Seçimi','Seçmiş olduğunuz personel, belgenizin tüm satırlarına uygulansın mı?',2)=MrYes then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set SATICIKODU=&PrsID where FATBASID=&FatbasID',['&PrsID','&FatbasID'],[TabFatbaslik.FieldByName('SATICIKODU').AsInteger,TabFatbaslik.FieldByName('ID').AsInteger]);
  TabloYenile(TabFatura, [TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.ComboBolumPropertiesCloseUp(Sender: TObject);
var
  i: Integer;
begin
  if (DETAY.active)and(TabFatbaslik.active) then begin
    if DETAY.State = dsEdit then
      DETAY.Post;
    i := 0;
    if DETAY.Recordcount > 0 then begin
      DETAY.First;
      while not DETAY.Eof do begin
        if DETAY.FieldByName('BILGI').AsString <> '' then
          Inc(i);
        DETAY.Next;
      end;
    end;
    if (i > 0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),PChar(Uyari), MB_YESNO + MB_ICONWARNING) = mrNo) then begin
      // ShowMessage(PWSilerekTekrarDeneyin);
      if TabFatbaslik.State in[dsEdit,dsInsert] then
        TabFatbaslik.Cancel
    end else begin
      if TabFatbaslik.State in[dsEdit,dsInsert] then
        TabFatbaslik.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri', '&YerID'],[Tablo.FaturaDetaySablonTipiBul(Tur),TabFatbaslik.FieldByName('ID').AsInteger]);
      DetayTablosuAc
    end;
  end;

end;

procedure TFaturaWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
var
  sablontipi: integer;
begin
  sablontipi := Tablo.FaturaDetaySablonTipiBul(Tur);
  if ComboBolum.Properties.Items.Count = 0 then
    ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(sablontipi)).Items;
end;

procedure TFaturaWizardDlg.ComboEFATURADURUMPropertiesEditValueChanged( Sender: TObject);
begin
  BtnEfatura.Visible := (Tur=15)and((ComboEFATURADURUM.editvalue = 1)or(ComboEFATURADURUM.editvalue = 11)) ;
end;

procedure TFaturaWizardDlg.ComboFIYAT_LISTESIPropertiesCloseUp(Sender: TObject);
var Satis : Integer;
    Fiyat:currency;
    DovizCinsi:String;
    DovizliFiyatVar : boolean;
 procedure FiyatGetir(StokId,FiyatId, Birim, Satis:Integer; var Fiyat:currency; var DovizCinsi:String);
  begin
     Tablo.TablodanSorguAc(1,'select FIYAT,KUR,KDVDURUM from STOKFIYAT where STOKID='+IntToStr(StokId)+' and FIYATADI='+IntToStr(FiyatId)+
         ' and BIRIM='+IntToStr(Birim)+' and SATIS='+IntToStr(Satis));
     Fiyat := Tablo.Query1.Fields[0].AsCurrency;
     DovizCinsi := Tablo.Query1.Fields[1].Asstring;
  end;
begin
   if not Active then exit;//ekran hen?z açılmad?ysa ??ks?n
   if (not TabFatura.IsEmpty)and(Application.MessageBox(PCHAR(Yeniden_duzenleme), PChar(SGenotipOnay), MB_YESNO) = IDYES) then begin
         if Tur in [0,9, 10, 11, 12] then
            Satis:=0
         else
            Satis:=1;
      DovizliFiyatVar := False;
      TabFatura.first;
      while not TabFatura.eof do begin
         TabFatura.edit;
         FiyatGetir(TabFatura.FieldByName('URUNID').AsInteger, ComboFIYAT_LISTESI.EditingValue, TabFatura.FieldByName('BIRIM').AsInteger,Satis,Fiyat,DovizCinsi);
         if DovizCinsi=CariDoviz then
             TabFatura.FieldByName('DOVIZKURDEGERI').AsCurrency := 1.0
         else
             DovizliFiyatVar := True;
         TabFatura.FieldByName('DOVIZ_KURU').Asstring := DovizCinsi;
         TabFatura.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency := Fiyat;
         TabFatura.post;
         TabFatura.next;
      end;
      if DovizliFiyatVar then
         BtnDoviz.Click;
   end;
end;

procedure TFaturaWizardDlg.EkstreDoviziDuzenle(Sender: TObject);
begin
   TcxDBComboBox(Sender).Properties.Items.Clear;
   TcxDBComboBox(Sender).Properties.Items.add(CariDoviz);
   if (ComboRaporDovizi.EditValue<>null)and(ComboRaporDovizi.EditValue<>CariDoviz) then
      TcxDBComboBox(Sender).Properties.Items.add(ComboRaporDovizi.EditValue);
   //TcxDBComboBox(Sender).EditValue := CariDoviz;  bu komut olmayacak sakın
end;

procedure TFaturaWizardDlg.ComboRaporDoviziPropertiesEditValueChanged(
  Sender: TObject);
var
  KurDegeri : real;
begin
  if (TabFatbaslik.State in [dsEdit, dsInsert])and(TabFatbaslik.FieldByName('ID').AsString<>'')and(TabFatbaslik.FieldByName('ID').AsInteger>0) then begin
      EditKulKur.Visible:= ComboRaporDovizi.EditValue <> CariDoviz;

    if ComboRaporDovizi.EditValue = CariDoviz then begin
       cbDovizCinsi.EditValue := CariDoviz;
       TabFatbaslik.Edit;
       ComboFaturaDovizi.EditValue := CariDoviz;
    end;
    if ComboRaporDovizi.EditValue = CariDoviz then//TL ise
       KurDegeri := 1
    else begin
      //if (FATBASLIK.FieldByName('DOVIZKUR').AsString='')or(FATBASLIK.FieldByName('DOVIZKUR').AsString='1')then
          KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TabFatbaslik.FieldByName('FATURATARIH').AsDateTime), ComboRaporDovizi.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'))
      //else
      //    KurDegeri := Float_ToStr(FATBASLIK.FieldByName('DOVIZKUR').AsFloat);
    end;
    //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set DOVIZ_KURU='''+ComboRaporDovizi.EditValue+''',DOVIZKURDEGERI='+KurDegeri+','+
    //     ' DOVIZ_BIRIMFIYAT=BIRIMFIYAT / '+KurDegeri+', DOVIZ_TUTARI= (BIRIMFIYAT / '+KurDegeri+') * ADET * ((100.0-ISKONTO)/100.0)*((100.0-ISKONTO2)/100.0) where FATBASID='+FATBASLIK.FieldByName('ID').AsString,[],[]);
    //TabloYenile(FATURA,[FATBASLIK.FieldByName('ID').AsInteger]);

    TabFatbaslik.FieldByName('DOVIZKUR').AsFloat := KurDegeri;
    TabFatbaslik.Post;
    FaturaTutarHesapla(True);
  end;
end;

procedure TFaturaWizardDlg.cxDBComboBox1PropertiesInitPopup(Sender: TObject);
begin
   EkstreDoviziDuzenle(Sender);
end;

procedure TFaturaWizardDlg.cxEditRepository1ButtonItem1PropertiesButtonClick
  (Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
  site: TcxGridSite;
begin
  st := Tstringlist.create;
  if Tablo.ListedenBilgiGetir(FWSeciniz, tab.FieldByName('KAYNAK').AsString, st, []) then begin
     TcxButtonEdit(Sender).EditValue := st.Strings[0];
     TcxButtonEdit(Sender).PostEditValue;
  end;
end;

procedure TFaturaWizardDlg.cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TFaturaWizardDlg.EditEkVergiClick(Sender: TObject);
var
  MF: Variant;
  ToplamAdet: Extended;
begin
  MF := TabFatbaslik.FieldByName('EKVERGI').AsFloat;
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.create.CurrencyEdit('Stopaj', @MF, 2)) = mrOk then  begin
     TabFatbaslik.Edit;
     TabFatbaslik.FieldByName('EKVERGI').AsFloat := MF;
     if ((ComboFatTipi.EditValue=4)or(ComboFatTipi.EditValue=7)or(ComboFatTipi.EditValue=8))and(not TabFatura.IsEmpty) then begin //Serbest Mes.Makbuzu ise Tutarlar yeniden hesaplanmal?
        TabFatbaslik.Post;
        TabFatura.Edit;
        TabFatura.Post;
     end;
  end;
end;

procedure TFaturaWizardDlg.EditILPropertiesInitPopup(Sender: TObject);
var I:smallint;
begin
  if EditIL.Properties.Items.Count<1 then begin
     for I := 0 to Tablo.Repiller.Properties.Items.Count-1 do
       EditIL.Properties.Items.Add(Tablo.Repiller.Properties.Items[I].Description);
  end;
end;

procedure TFaturaWizardDlg.EditSRMMerkeziPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var
  st: Tstringlist;
  Gelirmi:Smallint;
begin
  if AButtonIndex = 0 then
    try

      if Tur in [0, 3, 8, 10, 11, 12] then
        Gelirmi := 0
      else
        Gelirmi := 1;

      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir('Sorumluluk Merkezi se?iniz','SELECT ID,MERKEZKODU,MERKEZADI FROM SRMMERKEZI where GELIRMI='+IntToStr(Gelirmi)+' and MERKEZADI like ''%<ara>%'' ',  st, []) then begin
        TabFatbaslik.Edit;
        TabFatbaslik.FieldByName('MERKEZID').AsString := st.Strings[0];
        EditSRMMerkezi.Text := st.Strings[2];
          TabFatura.First;
          while not TabFatura.Eof do
          begin
            if TabFatura.State = dsBrowse then
              TabFatura.Edit;
            TabFatura.FieldByName('MERKEZID').Value := st.Strings[0];
            TabFatura.Post;
            TabFatura.Next;
          end;

      end;
    finally
      st.free;
    end
  else if AButtonIndex = 1 then begin
      TabFatbaslik.Edit;
      TabFatbaslik.FieldByName('MERKEZID').AsInteger := 0;
      EditSRMMerkezi.Text := '';
  end;

end;

procedure TFaturaWizardDlg.ButtonDuzenle;
begin
  FaturaTus.Enabled := FaturaTus.Tag <> WizardKontrol.ActivePageIndex;
  DetayTus.Enabled := DetayTus.Tag <> WizardKontrol.ActivePageIndex;
  PlanlaTus.Enabled := PlanlaTus.Tag <> WizardKontrol.ActivePageIndex;
  DokumanTus.Enabled := DokumanTus.Tag <> WizardKontrol.ActivePageIndex;
end;

procedure TFaturaWizardDlg.Cariskonto1Click(Sender: TObject);
var
  etiketler,bilgiler: TArrayOfString;
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set ISKONTO=&Yuzde, TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 where FATBASID=&id ',['&Yuzde','&id'],[Tablo.RehberIskontoVarMi(RehberId,-3,-1),TabFatbaslik.FieldByName('ID').AsInteger]);
  FaturaTutarHesapla(True);
  TabloYenile(TabFatura,[TabFatbaslik.FieldByName('ID').AsInteger]);
end;

procedure TFaturaWizardDlg.DtsFatBaslikStateChange(Sender: TObject);
begin
  KaydetIptalButonlariAyarla;
  FaturaTipiDuzenle;
end;

procedure TFaturaWizardDlg.DtsFaturaStateChange(Sender: TObject);
begin
  KaydetIptalButonlariAyarla;
  //FaturaTipiDuzenle;
end;

procedure TFaturaWizardDlg.editDovizKuruPropertiesEditValueChanged(Sender: TObject);
begin
  if TabFatbaslik.State in [dsEdit, dsInsert] then begin
    TabloYenile(TOPLAMLAR, [TabFatbaslik.FieldByName('ID').AsInteger]);
    if TOPLAMLAR.Locate('ACIKLAMA', 'Genel Toplam', [loPartialKey]) then
       TabFatbaslik.FieldByName('DOVIZ_TUTARI').AsExtended := TOPLAMLAR.FieldByName('DOVIZTUTARI').AsExtended;
  end;
end;

procedure TFaturaWizardDlg.FaturaTusClick(Sender: TObject);
begin
  WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;
  // WizardKontrol.Pages.IndexOf(DokumanEkr);
end;


procedure TFaturaWizardDlg.TOPLAMLARCalcFields(DataSet: TDataSet);
var
  dovizkur: Currency;
begin
{  if FATBASLIK.State in [dsEdit, dsInsert] then
    dovizkur := editDovizKuru.Value
  else
    dovizkur := FATBASLIK.FieldByName('DOVIZKUR').AsExtended;

  if dovizkur = 0 then
    dovizkur := 1;}

 // TOPLAMLARDOVIZTUTARI.Value := TOPLAMLARDEGER.AsExtended / dovizkur;
//  TOPLAMLARSECILENDOVIZCINSI.Value := cbDovizCinsi.Text;


end;

end.

 {
   object FATURAEN: TFMTBCDField
      FieldName = 'EN'
      OnChange = TabFaturaENChange
      Precision = 12
      Size = 6
    end
    object FATURABOY: TFMTBCDField
      FieldName = 'BOY'
      OnChange = TabFaturaENChange
      Precision = 12
      Size = 6
    end
    object FATURAYUZEY: TFMTBCDField
      FieldName = 'YUZEY'
      Precision = 24
      Size = 6
    end
    object FATURASAYI: TFMTBCDField
      FieldName = 'SAYI'
      OnChange = TabFaturaENChange
      Precision = 12
      Size = 6
    end}














































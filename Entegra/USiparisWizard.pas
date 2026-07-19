unit USiparisWizard;

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
  dxCoreGraphics, cxGroupBox, frCoreClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TSiparisWizardDlg = class(TForm, IPopupDialog)
    Panel1: TPanel;
    FaturaTus: TcxButton;
    DetayTus: TcxButton;
    WizardKontrol: TJvWizard;
    SiparisEkr: TJvWizardInteriorPage;
    DetayEkr: TJvWizardInteriorPage;
    dsAra: TDataSource;
    OpenDialog1: TOpenDialog;
    PopupMenuFatura: TPopupMenu;
    N16: TMenuItem;
    FaturaIptalIsaretle: TMenuItem;
    DtsTabSiparisDetay: TDataSource;
    DtsTabSiparis: TDataSource;
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
    TabSiparisDetay: TFDQuery;
    TabSiparis: TFDQuery;
    frxTabSiparisDetay: TfrxDBDataset;
    frxTabSiparis: TfrxDBDataset;
    LabelAd: TcxLabel;
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
    LabelKod: TcxLabel;
    lblMusteriAdres: TcxLabel;
    lblMusteriTel: TcxLabel;
    lblMusteriEposta: TcxLabel;
    N5: TMenuItem;
    SipariKoanAyarlar1: TMenuItem;
    lbDetaySablon: TcxLabel;
    ComboBolum: TcxDBComboBox;
    SQLDetay: TcxMemo;
    DokumanEkr: TJvWizardInteriorPage;
    DokumanTus: TcxButton;
    dtsTOPLAMLAR: TDataSource;
    TOPLAMLAR: TFDQuery;
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
    PageUst: TcxPageControl;
    TabSheetGenelBilgiler: TcxTabSheet;
    TabSheetEkAlanlar: TcxTabSheet;
    PanelAlt: TPanel;
    PanelUst: TPanel;
    PanelUst2: TPanel;
    Bevel2: TBevel;
    LabelMasrafMerkezi: TcxLabel;
    Label11: TcxLabel;
    LabelFaturaTarihi: TcxLabel;
    LabelFatNo: TcxLabel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    ComboSiparisDURUM: TcxDBImageComboBox;
    EditFatTarih: TcxDBDateEdit;
    EditFatNo: TcxDBTextEdit;
    cbKdvDurum: TcxDBComboBox;
    cbFaturaTur: TcxDBImageComboBox;
    cbStokDepo: TcxDBImageComboBox;
    EditFaturaSaat: TcxDBTimeEdit;
    cxDBLabel1: TcxDBLabel;
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
    lblSevkAdresi: TcxLabel;
    btnSevkAdresi: TcxButtonEdit;
    EditFATURASERI: TcxDBTextEdit;
    EditMM: TcxButtonEdit;
    lblTeklifNo: TcxLabel;
    editTeklifNo: TcxDBTextEdit;
    ComboFIYAT_LISTESI: TcxDBImageComboBox;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    EditVade: TcxDBTextEdit;
    cxLabel12: TcxLabel;
    ComboTeslimSekli: TcxDBImageComboBox;
    ComboODEME: TcxDBImageComboBox;
    cxLabel14: TcxLabel;
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
    GridFaturaViewMIKTAR: TcxGridDBColumn;
    GridFaturaViewBIRIM2MIKTAR: TcxGridDBColumn;
    GridFaturaViewBIRIM2AD: TcxGridDBColumn;
    DtsStokDetay: TDataSource;
    tabStokDetay: TFDQuery;
    frxStokDetay: TfrxDBDataset;
    GridFaturaViewSATICIADI: TcxGridDBColumn;
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
    EditOZELKOD: TcxDBTextEdit;
    GridFaturaViewRESIM: TcxGridDBColumn;
    GridFaturaViewDOKUMAN: TcxGridDBColumn;
    btnEPosta: TToolButton;
    KDVOranGir1: TMenuItem;
    SeiliSatra1: TMenuItem;
    Tumune1: TMenuItem;
    EditOZELKOD2: TcxDBTextEdit;
    GridFaturaViewOZELKOD2: TcxGridDBColumn;
    N6: TMenuItem;
    BirSatrAdetiKadarSatrlaraBolMenu: TMenuItem;
    TabSiparisDetayOZELKOD: TWideStringField;
    TabSiparisDetayOZELKOD2: TWideStringField;
    TabSiparisDetayAD: TWideStringField;
    TabSiparisDetayKOD: TWideStringField;
    TabSiparisDetayURUNNO: TWideStringField;
    TabSiparisDetayHUCRE: TWideStringField;
    TabSiparisDetayRESIM: TIntegerField;
    TabSiparisDetayDOKUMAN: TIntegerField;
    TabSiparisDetayBIRIMAD: TWideStringField;
    TabSiparisDetayBIRIM2MIKTAR: TFloatField;
    TabSiparisDetayBIRIM2AD: TWideStringField;
    TabSiparisDetayPROJEKODU: TWideStringField;
    TabSiparisDetaySATICIADI: TWideStringField;
    TabSiparisDetayDONUSENMIKTAR: TFMTBCDField;
    TabSiparisDetayURETIMPLANINDAGOSTER: TIntegerField;
    TabSiparisDetayEKIPMAN: TWideStringField;
    TabSiparisDetaySERINO: TWideStringField;
    TabSiparisDetayID: TAutoIncField;
    TabSiparisDetaySIPARISID: TIntegerField;
    TabSiparisDetayREHBERID: TIntegerField;
    TabSiparisDetaySEC: TWideStringField;
    TabSiparisDetayTUR: TSmallintField;
    TabSiparisDetayURUNID: TIntegerField;
    TabSiparisDetayACIKLAMA: TWideMemoField;
    TabSiparisDetayADET: TFMTBCDField;
    TabSiparisDetayBIRIM: TSmallintField;
    TabSiparisDetayMIKTAR: TFMTBCDField;
    TabSiparisDetayBIRIMFIYAT: TFMTBCDField;
    TabSiparisDetayTUTAR: TFMTBCDField;
    TabSiparisDetayISKONTO: TFloatField;
    TabSiparisDetayKDV: TSmallintField;
    TabSiparisDetayMASRAFID: TSmallintField;
    TabSiparisDetayMUHKODU: TWideStringField;
    TabSiparisDetayKASA: TSmallintField;
    TabSiparisDetayONAY: TWideStringField;
    TabSiparisDetayKUR: TWideStringField;
    TabSiparisDetayIZLEMEKODU: TWideStringField;
    TabSiparisDetayDOVIZ_TUTARI: TFMTBCDField;
    TabSiparisDetayDOVIZ_KURU: TWideStringField;
    TabSiparisDetayISKONTO2: TFloatField;
    TabSiparisDetayIZLEME: TSmallintField;
    TabSiparisDetayMF: TFMTBCDField;
    TabSiparisDetayIADEADET: TFloatField;
    TabSiparisDetayIADESIPARISDETAYID: TIntegerField;
    TabSiparisDetayYERI: TIntegerField;
    TabSiparisDetayYERID: TIntegerField;
    TabSiparisDetayDOVIZ_BIRIMFIYAT: TFMTBCDField;
    TabSiparisDetayDOVIZKURDEGERI: TCurrencyField;
    TabSiparisDetayEKLEYEN: TIntegerField;
    TabSiparisDetayEKLEMETARIHI: TSQLTimeStampField;
    TabSiparisDetayDEGISTIREN: TIntegerField;
    TabSiparisDetayDEGISTIRMETARIHI: TSQLTimeStampField;
    TabSiparisDetayKAMPANYAID: TIntegerField;
    TabSiparisDetayVADE: TWordField;
    TabSiparisDetayPROJEID: TIntegerField;
    TabSiparisDetayTESLIMTARIHI: TSQLTimeStampField;
    TabSiparisDetaySUBEID: TSmallintField;
    TabSiparisDetayURETIMPLANID: TIntegerField;
    TabSiparisDetayURETIMPLANDETAYID: TIntegerField;
    TabSiparisDetayMERKEZID: TIntegerField;
    TabSiparisDetaySTOKDURUM: TFloatField;
    TabSiparisDetayEKIPMANID: TIntegerField;
    TabSiparisDetayGIRISKAYNAK: TWordField;
    TabSiparisDetayOTVYUZDE: TBooleanField;
    TabSiparisDetayOTVMIKTAR: TBCDField;
    TabSiparisDetaySATICIKODU: TIntegerField;
    TabSiparisDetayISKONTOLUBRMFIYAT: TFloatField;
    TabSiparisDetayKDVDAHILBRMFIYAT: TFMTBCDField;
    TabSiparisDetayKDVDAHILFIYAT: TFloatField;
    TabSiparisDetayPOZNO: TIntegerField;
    TabSiparisDetayEN: TFMTBCDField;
    TabSiparisDetayBOY: TFMTBCDField;
    TabSiparisDetayYUZEY: TFMTBCDField;
    TabSiparisDetaySAYI: TFMTBCDField;
    GridFaturaViewEN: TcxGridDBColumn;
    GridFaturaViewBOY: TcxGridDBColumn;
    GridFaturaViewYUZEY: TcxGridDBColumn;
    GridFaturaViewSAYI: TcxGridDBColumn;
    GridFaturaViewPOZNO: TcxGridDBColumn;
    TeslimTarihiGirMenu: TMenuItem;
    TeslimTarihiSeciliSatiraMenu: TMenuItem;
    TeslimTarihiTumuneMenu: TMenuItem;
    GridFaturaViewURUNNO: TcxGridDBColumn;
    PageControlAlt: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    gridFatToplam: TcxGrid;
    tvFatToplamlar: TcxGridDBTableView;
    tvFatToplamlarTUR: TcxGridDBColumn;
    tvFatToplamlarACIKLAMA: TcxGridDBColumn;
    tvFatToplamlarDEGER: TcxGridDBColumn;
    tvFatToplamlarKUR: TcxGridDBColumn;
    tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn;
    tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn;
    gridFatToplamLevel1: TcxGridLevel;
    MemoNOTLAR: TcxDBMemo;
    cxLabel17: TcxLabel;
    LabelAktivite: TcxLabel;
    LabelProje: TcxLabel;
    BeditBagliGorev: TcxButtonEdit;
    EditEkVergi: TcxDBCurrencyEdit;
    cxDBLabel3: TcxDBLabel;
    cxLabel1: TcxLabel;
    cbDovizCinsi: TcxDBComboBox;
    lbDoviz: TcxLabel;
    lbSatici: TcxLabel;
    cxLabel5: TcxLabel;
    BeditProje: TcxButtonEdit;
    cbSatici: TcxButtonEdit;
    EditOnaylayan: TcxButtonEdit;
    cxLabel6: TcxLabel;
    cxLabel21: TcxLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    editDovizKuru: TcxDBCurrencyEdit;
    cxLabel7: TcxLabel;
    cbOnaylayacak: TcxDBImageComboBox;
    BeditServis: TcxButtonEdit;
    cxLabel8: TcxLabel;
    ComboRaporDovizi: TcxDBComboBox;
    LabelRaporDovizi: TcxLabel;
    BeditMusIlgili: TcxButtonEdit;
    cxTabSheet2: TcxTabSheet;
    ADOQuery1: TFDQuery;
    DataSource1: TDataSource;
    OfficePopupMenu1: TOfficePopupMenu;
    PopupYorumDetayMenu: TPopupMenu;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuDokGoster: TMenuItem;
    MenuDokFormuAc: TMenuItem;
    MenuDokSil: TMenuItem;
    labelDetayFileName: TcxLabel;
    Panel5: TPanel;
    MemoDetayChat: TcxRichEdit;
    BtnMesajGonderDetay: TcxButton;
    GridYorumDetay: TcxGrid;
    GridYorumDetayView: TcxGridDBCardView;
    cxGridDBCardViewRow1: TcxGridDBCardViewRow;
    cxGridDBCardViewRow2: TcxGridDBCardViewRow;
    cxGridDBCardViewRow3: TcxGridDBCardViewRow;
    cxGridDBCardViewRow4: TcxGridDBCardViewRow;
    cxGridDBCardViewRow5: TcxGridDBCardViewRow;
    cxGridLevel1: TcxGridLevel;
    cxGridPopupYorumlarDetay: TcxGridPopupMenu;
    SheetGenotip: TcxTabSheet;
    cxGroupBox1: TcxGroupBox;
    cxLabel9: TcxLabel;
    EditAd: TcxTextEdit;
    cxLabel10: TcxLabel;
    EditTCKN: TcxTextEdit;
    cxLabel11: TcxLabel;
    EditKimlikId: TcxTextEdit;
    cxLabel13: TcxLabel;
    EditSorumlu: TcxTextEdit;
    cxGroupBox2: TcxGroupBox;
    cxLabel15: TcxLabel;
    EditKurumu: TcxTextEdit;
    cxLabel16: TcxLabel;
    EditPoliklinik: TcxTextEdit;
    cxLabel18: TcxLabel;
    EditDoktor: TcxTextEdit;
    cxLabel19: TcxLabel;
    EditReferans: TcxTextEdit;
    cxLabel20: TcxLabel;
    EditGonderen: TcxTextEdit;
    SIPARIS: TFDQuery;
    SIPARISDETAY: TFDQuery;
    WideStringField1: TWideStringField;
    WideStringField2: TWideStringField;
    WideStringField3: TWideStringField;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    WideStringField4: TWideStringField;
    FloatField1: TFloatField;
    WideStringField5: TWideStringField;
    WideStringField6: TWideStringField;
    WideStringField7: TWideStringField;
    FMTBCDField1: TFMTBCDField;
    IntegerField3: TIntegerField;
    WideStringField8: TWideStringField;
    WideStringField9: TWideStringField;
    AutoIncField1: TAutoIncField;
    IntegerField4: TIntegerField;
    IntegerField5: TIntegerField;
    WideStringField10: TWideStringField;
    SmallintField1: TSmallintField;
    IntegerField6: TIntegerField;
    WideMemoField1: TWideMemoField;
    FMTBCDField2: TFMTBCDField;
    SmallintField2: TSmallintField;
    FMTBCDField3: TFMTBCDField;
    FMTBCDField4: TFMTBCDField;
    FMTBCDField5: TFMTBCDField;
    FloatField2: TFloatField;
    SmallintField3: TSmallintField;
    SmallintField4: TSmallintField;
    WideStringField11: TWideStringField;
    SmallintField5: TSmallintField;
    WideStringField12: TWideStringField;
    WideStringField13: TWideStringField;
    WideStringField14: TWideStringField;
    FMTBCDField6: TFMTBCDField;
    WideStringField15: TWideStringField;
    FloatField3: TFloatField;
    SmallintField6: TSmallintField;
    FMTBCDField7: TFMTBCDField;
    FloatField4: TFloatField;
    IntegerField7: TIntegerField;
    IntegerField8: TIntegerField;
    IntegerField9: TIntegerField;
    FMTBCDField8: TFMTBCDField;
    BCDField1: TCurrencyField;
    IntegerField10: TIntegerField;
    DateTimeField1: TSQLTimeStampField;
    IntegerField11: TIntegerField;
    DateTimeField2: TSQLTimeStampField;
    IntegerField12: TIntegerField;
    WordField1: TWordField;
    IntegerField13: TIntegerField;
    DateTimeField3: TSQLTimeStampField;
    SmallintField7: TSmallintField;
    IntegerField14: TIntegerField;
    IntegerField15: TIntegerField;
    IntegerField16: TIntegerField;
    FloatField5: TFloatField;
    IntegerField17: TIntegerField;
    WordField2: TWordField;
    BooleanField1: TBooleanField;
    BCDField2: TBCDField;
    IntegerField18: TIntegerField;
    FloatField6: TFloatField;
    FMTBCDField9: TFMTBCDField;
    FloatField7: TFloatField;
    WideStringField16: TWideStringField;
    WideStringField17: TWideStringField;
    IntegerField19: TIntegerField;
    SIPARISDETAYEN: TFMTBCDField;
    SIPARISDETAYBOY: TFMTBCDField;
    SIPARISDETAYYUZEY: TFMTBCDField;
    SIPARISDETAYSAYI: TFMTBCDField;
    cxLabel22: TcxLabel;
    cxDBLabel2: TcxDBLabel;
    procedure TabSiparisBeforePost(DataSet: TDataSet);
    procedure SiparisEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure DetayEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure TabSiparisNewRecord(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure TabSiparisDetayNewRecord(DataSet: TDataSet);
    procedure TabSiparisDetayBeforePost(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FaturaTusClick(Sender: TObject);
    procedure ButtonDuzenle;
    procedure TabSiparisDetayAfterDelete(DataSet: TDataSet);
    procedure TabSiparisDetayAfterPost(DataSet: TDataSet);
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
    procedure TabSiparisAfterPost(DataSet: TDataSet);
    procedure TabSiparisBeforeEdit(DataSet: TDataSet);
    procedure cbKdvDurumPropertiesCloseUp(Sender: TObject);
    procedure DtsSIPARISStateChange(Sender: TObject);
    procedure DtsSIPARISDETAYStateChange(Sender: TObject);
    function EkranAdiAl : string;
    procedure EditEkVergiKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure cxGridDBColumn4GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure cxEditRepository1ButtonItem1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KDVHaricTutargir1Click(Sender: TObject);
    procedure EditMMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure N52Click(Sender: TObject);
    procedure TutarDvzHesapla1Click(Sender: TObject);
    procedure GridFaturaViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure TabSiparisDetayCalcFields(DataSet: TDataSet);
    procedure LabelKodClick(Sender: TObject);
    procedure GridFaturaViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure SiparisEkrPage(Sender: TObject);
    procedure DetayEkrPage(Sender: TObject);
    procedure SipariKoanAyarlar1Click(Sender: TObject);
    procedure lbDetaySablonClick(Sender: TObject);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure TabSiparisAfterScroll(DataSet: TDataSet);
    procedure TabSiparisDetayAfterOpen(DataSet: TDataSet);
    procedure editDovizKuruPropertiesChange(Sender: TObject);
    procedure GridFaturaViewMASRAFADGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
    procedure GridFaturaViewMASRAFADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabSiparisDetayBeforeOpen(DataSet: TDataSet);
    procedure BeditMusIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure GridFaturaViewPROJEKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BeditProjeDblClick(Sender: TObject);
    procedure cbSaticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabSiparisAfterOpen(DataSet: TDataSet);
    procedure BtnDonusturClick(Sender: TObject);
    procedure GridFaturaViewEKIPMANIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnDovizKuruClick(Sender: TObject);
    procedure ComboFIYAT_LISTESIPropertiesCloseUp(Sender: TObject);
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
    procedure GridFaturaViewRESIMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridFaturaViewDOKUMANPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure SeciliSatiraSubMenuClick(Sender: TObject);
    procedure TumuneSubMenuClick(Sender: TObject);
    procedure BirSatrAdetiKadarSatrlaraBolMenuClick(Sender: TObject);
    procedure TabSiparisDetayENChange(Sender: TField);
    procedure ComboRaporDoviziPropertiesEditValueChanged(Sender: TObject);
    procedure TeslimTarihiSeciliSatiraMenuClick(Sender: TObject);
    procedure TeslimTarihiTumuneMenuClick(Sender: TObject);
    procedure BtnMesajGonderDetayClick(Sender: TObject);
    procedure TabSiparisDetayAfterScroll(DataSet: TDataSet);
    procedure SiparisEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuDokGosterClick(Sender: TObject);
    procedure MenuDokFormuAcClick(Sender: TObject);
    procedure MenuDokSilClick(Sender: TObject);
    procedure PopupYorumDetayMenuPopup(Sender: TObject);
    procedure GridYorumDetayViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure PageUstChange(Sender: TObject);
    procedure cxLabel16Click(Sender: TObject);
    procedure cxLabel19Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MemoFatAdresKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FSkipDetailAfterScroll: Boolean;
    FDeferredCalcInitDone: Boolean;
    FTabSiparisDetayUpdateSQL: TFDUpdateSQL;
    FLocateSiparisDetayID: Integer;
    FLastDetayCalcID: Integer;
    FLastDetayResim: Integer;
    FLastDetayDokuman: Integer;
    FFrameBilgi : TIcerikFrameBilgi;
    AraDlg : TStokHizmetAraDlg;
    KuraGoreFiyatHesaplamaAlani:integer ; //faturaadetchange olayında kullanılıyor bu değişken
    function BoslukKontrolu: Boolean;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure FaturaToplamUpdate(TabloAc:Boolean);
    procedure FirmaBilgileri;
    procedure HazirlaSiparisDetayAlanlari;
    //procedure HazirlaSiparisDetayUpdateSQL;
    procedure YenileSiparisDetayClone;
    procedure OkuSiparisDetayGorselDurumu(AUrunID: Integer; out AResim, ADokuman: Integer);
    function DetaySablonTipiBul:integer;
    procedure IletisimEkleClick(Sender: TObject);
    procedure SatinAlmainsert;
    function SipKontrol:boolean;
    function ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
  public
    { Public declarations }
    IslemOp: Char;
    SiparisTur, SiparisIdsi, RehberId, ProjeId, AktiviteId,MasrafMerkezi,ServisID,SatinAlmaID: Integer;
    iadefis, IptalSecildi: Boolean;
    FOturumID: string;   // geri-alinabilir oturum (D modu SNAPSHOT OTURUMID); '' = yok
    Cagiran: SmallInt;
    // Loglama: yukleme aninda baslik/detay snapshot; kaydette diff (ULog).
    FBasSnap, FDetSnap: TObjectDictionary<Integer, TStringList>;
    function SiparisLogTabNo: Integer;   // 9->91 (Gelen), 19->92 (Giden)
    procedure SiparisLogSnapshotAl;      // yuklemede (D/I) cagrilir
    procedure SiparisLogKaydet;          // kaydette baslik+detay diff + snapshot yenile
  end;

var
  SiparisWizardDlg: TSiparisWizardDlg;
  DYetkisonuc:DokumanYetkiSonuc;

implementation

Uses  UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra, UFastRap, UOPSDLG,
  UParaDegisiklik, URaporAraclari, UGenelAnaSekmeFrame,UFisIrsaliyeAraDlg,UGirisKutusuEx, UGorevDlg, UIsListesi,
  UCariFonksiyonlar, UAnaForm, URehberAyar ,IdGlobalProtocols,LocOnFly, UVeriMotor;

{$R *.dfm}

var
   Belge, OncekiKDVDurumu : String[10];
   OncekiSubeID, TabloNo,   OncekiOnaylayacak :integer;
   Kilit, EkleDetay, AdresDegisti, EkAlanOlustu : Boolean;
   tab : TFDQuery;

function TSiparisWizardDlg.DetaySablonTipiBul:integer;
begin
 case SiparisTur of
   9        : Result:= TabNo_FATURA_AlisSiparis;
   10,11,12 : Result:= TabNo_FATURA_GelenFatFisIrs;
   14,15,16 : Result:= TabNo_FATURA_GidenFatFisIrs;
   19       : Result:= TabNo_FATURA_SatisSiparis;
   else Result:=0;
  end;
end;
procedure TSiparisWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TSiparisWizardDlg.DkmanSil1Click(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: dokuman silme -> yakala
if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabloNo,TabSiparis.FieldByName('ID').AsInteger]);
  end;
end;

procedure TSiparisWizardDlg.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[TabloNo, TabSiparis.FieldByName('ID').AsInteger]);

   // TANI (RAD Studio Event Log'da gorunur): kontrollerin GERCEK runtime durumu.
   OutputDebugString(PChar(Format(
     'YORUM-TANI | DokumanEkr vis=%d %dx%d | GridYorum parent=%s vis=%d b=%d,%d,%d,%d | Panel4 parent=%s vis=%d b=%d,%d,%d,%d',
     [Ord(DokumanEkr.Visible), DokumanEkr.Width, DokumanEkr.Height,
      GridYorum.Parent.Name, Ord(GridYorum.Visible), GridYorum.Left, GridYorum.Top, GridYorum.Width, GridYorum.Height,
      Panel4.Parent.Name, Ord(Panel4.Visible), Panel4.Left, Panel4.Top, Panel4.Width, Panel4.Height])));

   // DUZELTME DENEMESI: parent/gorunurluk/hizalamayi garanti et (kontroller cizilmiyorsa).
   GridYorum.Parent := DokumanEkr;
   Panel4.Parent := DokumanEkr;
   labelFileName.Parent := DokumanEkr;
   Panel4.Visible := True;
   GridYorum.Visible := True;
   MemoChat.Visible := True;
   DokumanEkr.Realign;
end;

procedure TSiparisWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
                      TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabSiparis.FieldByName('REHBERID').AsInteger)
end;

function TSiparisWizardDlg.EkranAdiAl: string;
begin
  Result := 'SiparisDlg';
end;

procedure TSiparisWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   FatTutar : Currency;
   MusIlgiliID,PersonelID:string;
begin
  DokumAdi := YaziciYaz.Caption;
  Ekranadi := EkranAdiAl;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if TabSiparis.State in [dsEdit,dsInsert] then
     TabSiparis.Post;
  if TabSiparisDetay.State in [dsEdit,dsInsert] then
     TabSiparisDetay.Post;
  TabloYenile(SIPARIS, [SiparisIdsi]);
  TabloYenile(SIPARISDETAY, [SiparisIdsi]);
  frxTabSiparis.DataSet := SIPARIS;
  frxTabSiparisDetay.DataSet := SIPARISDETAY;
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxTabSiparis) then
    AFastReport.EnabledDataSets.Add(frxTabSiparis)
  else begin
    AFastReport.EnabledDataSets.Add(frxTabSiparis);
    AFastReport.EnabledDataSets.Add(frxTabSiparisDetay);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
    Tablo.TabMusteri.Open;
    if TabSiparis.FieldByName('REHBERILETID').Value <> null then begin
      TabloYenile(Tablo.TabSevkAdresi,[RehberId,TabSiparis.FieldByName('REHBERILETID').AsInteger]);
      AFastReport.EnabledDataSets.Add(Tablo.frxSevkAdresi);
    end else
      Tablo.TabSevkAdresi.Close;

    TabloYenile(tabStokDetay, [TabSiparis.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxStokDetay);

    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);

    MusIlgiliID := IIF(TabSiparis.FieldByName('MUS_ILGILI').AsString='','-99',TabSiparis.FieldByName('MUS_ILGILI').AsString);
    Tablo.TabMusteriIlgili.Close;
    Tablo.TabMusteriIlgili.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1',MusIlgiliID, [rfReplaceAll]);
    Tablo.TabMusteriIlgili.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteriIlgili);

    PersonelID := IIF(TabSiparis.FieldByName('SATICIKODU').AsString='','-99',TabSiparis.FieldByName('SATICIKODU').AsString);
    Tablo.TabPersonel.Close;
    Tablo.TabPersonel.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1',PersonelID, [rfReplaceAll]);
    Tablo.TabPersonel.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxPersonel);

    if (DovizTakibi)and(TabSiparis.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz) then
       FatTutar := TabSiparis.FieldByName('DOVIZ_TUTARI').AsCurrency
    else
       FatTutar := TabSiparis.FieldByName('SIPARIS_TUTARI').AsCurrency;
    TabloYenile(TabHesapOzeti,[TabSiparis.FieldByName('REHBERID').AsInteger, TabSiparis.FieldByName('DOVIZ_CINSI').AsString, FatTutar]);
    AFastReport.EnabledDataSets.Add(frxHesapOzeti);

    AFastReport.EnabledDataSets.Add(frxDETAY);
    AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
  end;
end;

procedure TSiparisWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya duzenleme -> yakala
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Siparisdetay);
end;

procedure TSiparisWizardDlg.BirSatrAdetiKadarSatrlaraBolMenuClick(Sender: TObject);
var ID,I,Adet:integer;
    Tutar : Extended;
    AdetAl: Variant;
begin
   ID   := TabSiparisDetay.FieldByName('ID').AsInteger;
   AdetAl := TabSiparisDetay.FieldByName('ADET').AsInteger;
   Tutar:= TabSiparisDetay.FieldByName('BIRIMFIYAT').AsExtended;

   if TGirisKutusuEx.BilgiAlEx('Belge No Girişi' ,TGirdiDenetimleri.Create.Edit('Satır Sayısı:' , @AdetAl)) <> mrOk then
      exit;
   Adet := AdetAl;

   for I := 2 to Adet do
      Tablo.SQLSatiriKopyala('SIPARISDETAY', ID,['ADET','MIKTAR','TUTAR', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
      [1,1,Tutar,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
   //ilk satırda det ve tutarı değiştirelim
   TabSiparisDetay.Edit;
   TabSiparisDetay.FieldByName('ADET').AsInteger := 1;
   TabSiparisDetay.Post;
end;

procedure TSiparisWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s,Yol:string;
  i:smallint;
begin
  KaydetTus.Click;
//  TabSiparis.Close;
//  TabSiparis.Params[0].Value := SiparisIdsi;
//  TabSiparis.Open;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  if TToolButton(Sender).Name='btnEPosta' then begin
     i:=pos(' ', LabelAd.caption);
     if i=0 then i:=length(LabelAd.caption);
     Yol:= GetEnvironmentVariable('Temp')+Concat('\Siparis_', copy(LabelAd.caption,1,i), '_', FormatDateTime('yy_mm_dd',EditFatTarih.Date),'_',
         TabSiparis.FieldByName('SIPARISNO').AsString, '.pdf');
     FastRaporDlg.FastRapor(2, EkranAdiAl, s, Yol );
     Tablo.OrtakEPostaGonder(MODUL_Verilen_Siparis, TabSiparis, Yol, 'SIPARISDETAY', 'SIPARISID', 91)
  end else
     FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARIS set YAZDIRILDI=1 where ID='+TabSiparis.FieldByName('ID').AsString,[],[]);
end;

procedure TSiparisWizardDlg.BeditBagliGorevDblClick(Sender: TObject);
var GOREV_ID: String[15];
    GorevDlg1: TGorevDlg;
begin
   GOREV_ID:= TabSiparis.FieldByName('AKTIVITEID').AsString;
   Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',StrToInt(GOREV_ID),AtamaYapildi, YorumYapildi);
   if AtamaYapildi then
      Gorev_EPostaGonder(1, StrToIntDef(GOREV_ID,-1))
   else if YorumYapildi then
      Gorev_EPostaGonder(3, StrToIntDef(GOREV_ID,-1));
end;

procedure TSiparisWizardDlg.BeditBagliGorevPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
begin
  if AButtonIndex = 0 then
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(AktiviteSecimi,'SELECT G.ID,TARIH=BASLAMATARIHI,EKLEYEN=R.FIRMA,DURUM=GT2.ANAHTAR,TUR=GT1.ANAHTAR,KONUSU '+
         'FROM GOREVLER G inner join REHBER R on R.ID=G.EKLEYEN left join GENINI GT1 on GT1.BOLUM=-21044 and G.TURU=GT1.DEGER '+
         'left join GENINI GT2 on GT2.BOLUM=-21042 and G.TURU=GT2.DEGER where KONUSU like ''%<ara>%'' and REHBERID=' + TabSiparis.FieldByName('REHBERID').AsString+' ORDER BY 2 DESC', st, []) then begin
         TabSiparis.Edit;
         TabSiparis.FieldByName('AKTIVITEID').AsString := st.Strings[0];//+' '+st.Strings[4];
         BeditBagliGorev.Text := st.Strings[1];
      end;
    finally
      st.free;
    end
  else if AButtonIndex = 1 then begin
    TabSiparis.Edit;
    TabSiparis.FieldByName('AKTIVITEID').AsString := '-1';
    BeditBagliGorev.Text := '';
  end;
end;

procedure TSiparisWizardDlg.BeditMusIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabSiparis);
end;

procedure TSiparisWizardDlg.BeditProjeDblClick(Sender: TObject);
begin
  if BeditProje.Text <> '' then
     Tablo.ProjeSihirbazBaslat('D', TabSiparis.FieldByName('PROJEID').AsInteger, TabSiparis.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);
end;

procedure TSiparisWizardDlg.GridFaturaViewPROJEKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(nil, TabSiparisDetay,AButtonIndex,ProjeSecimi, TabSiparis.FieldByName('REHBERID').AsInteger);
end;


procedure TSiparisWizardDlg.GridFaturaViewRESIMPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Stoklar, TabSiparisDetay.FieldByName('URUNID').AsInteger, False);
end;

procedure TSiparisWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
    Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_Siparisdetay);
end;

procedure TSiparisWizardDlg.GridYorumDetayViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_SIPARISDETAY);
end;

procedure TSiparisWizardDlg.GsterSeiliSatr1Click(Sender: TObject);
begin
  if (Sender as TMenuItem).Tag = 1 then  begin//seçiliyi göster
    if StrToIntDef(VarToStrDef(TabSiparisDetay.FieldByName('URETIMPLANDETAYID').Value,'0'),0) < 0 then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = null where ID='+TabSiparisDetay.FieldByName('ID').AsString,[],[])
    else
      ShowMessage('Bu satır gösterimde ya da kullanımda. İşlem gerçekleştirilemiyor.');
  end;
  if (Sender as TMenuItem).Tag = 2 then  begin  //tümünü göster
    if SipKontrol then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = null where SIPARISID='+TabSiparis.FieldByName('ID').AsString,[],[]);
  end;
  if (Sender as TMenuItem).Tag = 3 then  begin  //seçiliyi sakla
    if StrToIntDef(VarToStrDef(TabSiparisDetay.FieldByName('URETIMPLANDETAYID').Value,'0'),0) = 0 then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = -1 where ID='+TabSiparisDetay.FieldByName('ID').AsString,[],[])
    else
      ShowMessage('Bu satır saklı ya da kullanımda. İşlem gerçekleştirilemiyor.');
  end;
  if (Sender as TMenuItem).Tag = 4 then  begin  //tümünü sakla
    if SipKontrol then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANDETAYID = -1 where SIPARISID='+TabSiparis.FieldByName('ID').AsString,[],[]);
  end;
  TabSiparisDetay.Close;
  TabSiparisDetay.Open;
end;

function TSiparisWizardDlg.SipKontrol:boolean;
var
  plandetID:variant;
begin
  Result := True;
  TabSiparisDetay.First;
  plandetID := TabSiparisDetay.FieldByName('URETIMPLANDETAYID').Value;
  while not TabSiparisDetay.Eof do begin
    if TabSiparisDetay.FieldByName('URETIMPLANDETAYID').Value <> plandetID then begin
      ShowMessage('Kullanılmış ya da kapatılmış satırlar mevcut, lütfen her satır için ayrı işlem uygulayın.');
      Exit(False);
    end;
    TabSiparisDetay.Next;
  end;
end;

procedure TSiparisWizardDlg.BeditProjePropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje,TabSiparis,AButtonIndex,ProjeSecimi, TabSiparis.FieldByName('REHBERID').AsInteger);
  if TabSiparis.FieldByName('PROJEID').AsInteger > 0 then
    if Tablo.UyariGoster('Proje Seçimi','Seçmiş olduğunuz proje, belgenizin tüm satırlarına uygulansın mı?',2)=MrYes then
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set PROJEID=&PrjID where SIPARISID=&FatbasID',['&PrjID','&FatbasID'],[TabSiparis.FieldByName('PROJEID').AsInteger,TabSiparis.FieldByName('ID').AsInteger]);
  TabloYenile(TabSiparisDetay, [TabSiparis.FieldByName('ID').AsInteger]);
end;

procedure TSiparisWizardDlg.BeditServisDblClick(Sender: TObject);
begin
  if (TabSiparis.FieldByName('SERVISID').Value <> null) and (TabSiparis.FieldByName('SERVISID').AsInteger>0) then
    Tablo.ServisSihirbazBaslat(False,'D',0,TabSiparis.FieldByName('SERVISID').AsInteger,TabSiparis.FieldByName('REHBERID').AsInteger);
end;

procedure TSiparisWizardDlg.BeditServisPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  st: Tstringlist;
  SQL:string;
begin
  if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '-' then begin
    TabSiparis.Edit;
    TabSiparis.FieldByName('SERVISID').Value := Null;
    TabSiparis.Post;
    (Sender as TcxButtonEdit).Text := '';
    (Sender as TcxButtonEdit).Tag := 0;
  end else begin
    SQL:='select ID,SERVISNO,BASLAMATARIHI,BITISTARIHI,KONUSU  from SERVIS where (SERVISNO like ''%<ara>%'' or KONUSU like ''%<ara>%'') and isnull(ACKAPA,0)=0 ';
    if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '+' then
      SQL:=SQL+'and REHBERID=' + IntToStr(RehberId);
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(ServisSecimi,SQL, st, []) then begin
        TabSiparis.Edit;
        TabSiparis.FieldByName('SERVISID').AsString := st.Strings[0];
        TabSiparis.Post;
        (Sender as TcxButtonEdit).Text := st.Strings[1]+' - '+st.Strings[4];
        (Sender as TcxButtonEdit).Tag := StrToIntDef(st.Strings[0],0);
      end;
    finally
      st.free;
    end;
  end;
end;

procedure TSiparisWizardDlg.DetayEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var Yeri : SmallInt;
begin

    TabDetay.Close;
    TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    TabDetay.Params[0].Value := DetaySablonTipiBul;
    TabDetay.Params[1].Value := TabSiparis.FieldByName('ID').AsInteger;
    TabDetay.Params[2].Value := ComboBolum.Text;
    TabDetay.Open;
    if TabDetay.FindField('GIRIS') <> nil then
      TabDetay.FieldByName('GIRIS').ProviderFlags := [];
    if TabDetay.FindField('KAYNAK') <> nil then
      TabDetay.FieldByName('KAYNAK').ProviderFlags := [];
    if TabDetay.FindField('ZORUNLU') <> nil then
      TabDetay.FieldByName('ZORUNLU').ProviderFlags := [];
    if TabDetay.FindField('ORJINAL') <> nil then begin
      TabDetay.FieldByName('ORJINAL').ReadOnly := True;
      TabDetay.FieldByName('ORJINAL').ProviderFlags := [];
    end;
end;

procedure TSiparisWizardDlg.DetayEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
    TabDetay.Close;
    TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    TabDetay.Params[0].Value := DetaySablonTipiBul;
    TabDetay.Params[1].Value := TabSiparis.FieldByName('ID').AsInteger;
    TabDetay.Params[2].Value := ComboBolum.Text;
    TabDetay.Open;
    if TabDetay.FindField('GIRIS') <> nil then
      TabDetay.FieldByName('GIRIS').ProviderFlags := [];
    if TabDetay.FindField('KAYNAK') <> nil then
      TabDetay.FieldByName('KAYNAK').ProviderFlags := [];
    if TabDetay.FindField('ZORUNLU') <> nil then
      TabDetay.FieldByName('ZORUNLU').ProviderFlags := [];
    if TabDetay.FindField('ORJINAL') <> nil then begin
      TabDetay.FieldByName('ORJINAL').ReadOnly := True;
      TabDetay.FieldByName('ORJINAL').ProviderFlags := [];
    end;
end;

procedure TSiparisWizardDlg.DtsSIPARISStateChange(Sender: TObject);
begin
   KaydetTus.Visible := DtsTabSiparis.State in [dsEdit, dsInsert];
   IptalTus.Visible := KaydetTus.Visible;
end;

procedure TSiparisWizardDlg.editDovizKuruPropertiesChange(Sender: TObject);
begin
  if TabSiparis.State in [dsEdit,dsInsert] then
    TabloYenile(TOPLAMLAR,[TabSiparis.FieldByName('ID').AsInteger]);
end;

procedure TSiparisWizardDlg.DtsSIPARISDETAYStateChange(Sender: TObject);
begin
   KaydetTus.Visible := DtsTabSiparisDetay.State in [dsEdit, dsInsert];
   IptalTus.Visible := KaydetTus.Visible;
end;

procedure TSiparisWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
  if (IptalSecildi) and ((IslemOp = 'E') or (IslemOp='K') or (Cagiran=9)) then// eğer yeni kayıtsa ve iptal edildiyse kaydedilmiş bilgiler silinmesi lazım
    if (TabSiparis.Active) and (TabSiparis.Fields[0].AsString <> '') then
     begin
      //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_SIPARIS_DOKUMAN, TabSiparis.FieldByName('ID').AsInteger]);
      Tablo.SiparisSil(TabSiparis.FieldByName('ID').AsInteger);
     end;
  // Geri-alinabilir oturum (D): iptal -> ilk hale don; kaydet -> snapshot temizle.
  // (Cagiran=9 iptalinde ustteki blok zaten SiparisSil ile sildi -> yalniz snapshot temizle.)
  if (IslemOp = 'D') and (FOturumID <> '') then
  begin
    if IptalSecildi and (Cagiran <> 9) then
    begin
      if TabSiparisDetay.State in [dsEdit, dsInsert] then TabSiparisDetay.Cancel;
      if TabSiparis.State in [dsEdit, dsInsert] then TabSiparis.Cancel;
      ULog.OturumGeriAl(FOturumID);
    end
    else
      ULog.OturumBitir(FOturumID);
    FOturumID := '';
  end;
  FreeAndNil(FBasSnap);
  FreeAndNil(FDetSnap);
end;

procedure TSiparisWizardDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var Ciksin : Boolean;
begin
   Ciksin := True;
   if (IptalSecildi)and((IslemOp='E')or (IslemOp='K')or( (IslemOp='D')and(KaydetTus.Visible or ULog.OturumYakalandiMi(FOturumID) or ((TabSiparis.State in [dsEdit,dsInsert]) and TabSiparis.Modified))))then
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : begin
                Ciksin := False;
                WizardKontrolFinishButtonClick(Self);
               end;
       IDCANCEL:Ciksin := False;
      end;

   if (IslemOp='D')and(TabSiparisDetay.IsEmpty) then begin
            raise Exception.Create(UrungirilmedenKaydedilemez);
   end;

   CanClose := Ciksin;
end;

procedure TSiparisWizardDlg.FormCreate(Sender: TObject);
var
  Item:TMenuItem;
  i:integer;
begin
  FBasSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
  FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
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
  FLocateSiparisDetayID := 0;
  FLastDetayCalcID := 0;
  FLastDetayResim := 0;
  FLastDetayDokuman := 0;
  AdresDegisti := False;
  EkAlanOlustu :=False;

  cbDovizCinsi.Visible:=DovizTakibi;
  lbDoviz.Visible:=DovizTakibi;
  editDovizKuru.Visible:=DovizTakibi;

  if not DovizTakibi then begin
    FreeAndNil(GridFaturaViewDOVIZKURDEGERI);
    FreeAndNil(GridFaturaViewDOVIZ_TUTARI);
    FreeAndNil(GridFaturaViewDOVIZ_BIRIMFIYAT);
    FreeAndNil(GridFaturaViewDOVIZ_KURU);
    FreeAndNil(tvFatToplamlarDOVIZTUTARI);
    FreeAndNil(tvFatToplamlarDOVIZ_KURU);
  end;

  if not EnBoyHesaplamaAktif then begin
     FreeAndNil(TabSiparisDetayEN);
     FreeAndNil(TabSiparisDetayBOY);
     FreeAndNil(TabSiparisDetayYUZEY);
     FreeAndNil(TabSiparisDetaySAYI);

     FreeAndNil(SIPARISDETAYEN);
     FreeAndNil(SIPARISDETAYBOY);
     FreeAndNil(SIPARISDETAYYUZEY);
     FreeAndNil(SIPARISDETAYSAYI);

     FreeAndNil(GridFaturaViewEN);
     FreeAndNil(GridFaturaViewBOY);
     FreeAndNil(GridFaturaViewSAYI);
     FreeAndNil(GridFaturaViewYUZEY);
  end;

 
  HazirlaSiparisDetayAlanlari;
  //HazirlaSiparisDetayUpdateSQL;
  KuraGoreFiyatHesaplamaAlani:=1; //1 birimfiyat 2 dövizbirimfiyat
 // cbStokDepo.Properties := Tablo.imgComboboxInit('select -1 AS ID, '''' AS DEPOADI UNION ALL SELECT ID, DEPOADI FROM DEPOLAR WHERE DURUM=1 ORDER BY 2');
  Tablo.GENINI.ReadImageSection(Ops_StokKart_Anabirim,(GridFaturaViewBIRIM1.Properties as TcxImageComboBoxProperties).Items);
  EditIL.Properties:=Tablo.ComboboxInit('select ILADI from ILLER  where ILNO<100 order by 1');
  //Tablo.OndalikKisimAyarla(GridFaturaViewBIRIMFIYAT1, OndalikDijitSayBr);
  //Tablo.OndalikKisimAyarla(GridFaturaViewTUTAR1, OndalikDijitSayTut);
  //if DovizTakibi then begin
  //   Tablo.OndalikKisimAyarla(GridFaturaViewDOVIZ_BIRIMFIYAT, OndalikDijitSayBr);
  //   Tablo.OndalikKisimAyarla(GridFaturaViewDOVIZ_TUTARI, OndalikDijitSayTut);
  //end;

      SheetGenotip.TabVisible := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_HastaSiparisSekmesi, false);

     for i := 0 to Tablo.repStokKDV.Properties.Items.Count - 1 do begin
       Item := TMenuItem.Create(SeiliSatra1);
       Item.Caption:=Tablo.repStokKDV.Properties.Items[i];
       Item.Tag :=StrToInt(Tablo.repStokKDV.Properties.Items[i]);
       Item.OnClick := SeciliSatiraSubMenuClick;
       SeiliSatra1.Add(Item);
     end;
     for i := 0 to Tablo.repStokKDV.Properties.Items.Count - 1 do begin
       Item := TMenuItem.Create(Tumune1);
       Item.Caption:=Tablo.repStokKDV.Properties.Items[i];
       Item.Tag :=StrToInt(Tablo.repStokKDV.Properties.Items[i]);
       Item.OnClick := TumuneSubMenuClick;
       Tumune1.Add(Item);
     end;


end;

{procedure TSiparisWizardDlg.HazirlaSiparisDetayUpdateSQL;
begin
  FreeAndNil(FTabSiparisDetayUpdateSQL);
  FTabSiparisDetayUpdateSQL := TFDUpdateSQL.Create(Self);
  FTabSiparisDetayUpdateSQL.Connection := Tablo.FDCnn;
  FTabSiparisDetayUpdateSQL.ModifySQL.Text :=
    'update SIPARISDETAY set ' +
    'SIPARISID=:NEW_SIPARISID, REHBERID=:NEW_REHBERID, SEC=:NEW_SEC, TUR=:NEW_TUR, URUNID=:NEW_URUNID, ' +
    'ACIKLAMA=:NEW_ACIKLAMA, ADET=:NEW_ADET, EN=:NEW_EN, BOY=:NEW_BOY, YUZEY=:NEW_YUZEY, SAYI=:NEW_SAYI, ' +
    'BIRIM=:NEW_BIRIM, MIKTAR=:NEW_MIKTAR, BIRIMFIYAT=:NEW_BIRIMFIYAT, TUTAR=:NEW_TUTAR, ' +
    'ISKONTO=:NEW_ISKONTO, KDV=:NEW_KDV, MASRAFID=:NEW_MASRAFID, MUHKODU=:NEW_MUHKODU, ' +
    'KASA=:NEW_KASA, ONAY=:NEW_ONAY, KUR=:NEW_KUR, IZLEMEKODU=:NEW_IZLEMEKODU, DOVIZ_TUTARI=:NEW_DOVIZ_TUTARI, ' +
    'DOVIZ_KURU=:NEW_DOVIZ_KURU, ISKONTO2=:NEW_ISKONTO2, IZLEME=:NEW_IZLEME, MF=:NEW_MF, IADEADET=:NEW_IADEADET, ' +
    'IADESIPARISDETAYID=:NEW_IADESIPARISDETAYID, YERI=:NEW_YERI, YERID=:NEW_YERID, DOVIZ_BIRIMFIYAT=:NEW_DOVIZ_BIRIMFIYAT, ' +
    'DOVIZKURDEGERI=:NEW_DOVIZKURDEGERI, EKLEYEN=:NEW_EKLEYEN, EKLEMETARIHI=:NEW_EKLEMETARIHI, DEGISTIREN=:NEW_DEGISTIREN, ' +
    'DEGISTIRMETARIHI=:NEW_DEGISTIRMETARIHI, KAMPANYAID=:NEW_KAMPANYAID, VADE=:NEW_VADE, PROJEID=:NEW_PROJEID, ' +
    'TESLIMTARIHI=:NEW_TESLIMTARIHI, SUBEID=:NEW_SUBEID, URETIMPLANID=:NEW_URETIMPLANID, URETIMPLANDETAYID=:NEW_URETIMPLANDETAYID, ' +
    'MERKEZID=:NEW_MERKEZID, STOKDURUM=:NEW_STOKDURUM, EKIPMANID=:NEW_EKIPMANID, GIRISKAYNAK=:NEW_GIRISKAYNAK, ' +
    'OTVYUZDE=:NEW_OTVYUZDE, OTVMIKTAR=:NEW_OTVMIKTAR, SATICIKODU=:NEW_SATICIKODU, OZELKOD=:NEW_OZELKOD, ' +
    'OZELKOD2=:NEW_OZELKOD2, POZNO=:NEW_POZNO ' +
    'where ID=:OLD_ID';
  FTabSiparisDetayUpdateSQL.DeleteSQL.Text := 'delete from SIPARISDETAY where ID=:OLD_ID';
  TabSiparisDetay.UpdateObject := FTabSiparisDetayUpdateSQL;
end;   }
procedure TSiparisWizardDlg.OkuSiparisDetayGorselDurumu(AUrunID: Integer; out AResim, ADokuman: Integer);
var
  LQry: TFDQuery;
begin
  AResim := 0;
  ADokuman := 0;
  if AUrunID <= 0 then
    Exit;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text :=
      'select ' +
      'RESIM=(select case when S.RESIM is null then 0 else 1 end from STOKLAR S where S.ID = :PID), ' +
      'DOKUMAN=(select case when exists(select GY.ID from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID where GY.TUR=88 and GOREVID=:PID) then 1 else 0 end)';
    LQry.ParamByName('PID').AsInteger := AUrunID;
    LQry.Open;
    AResim := LQry.FieldByName('RESIM').AsInteger;
    ADokuman := LQry.FieldByName('DOKUMAN').AsInteger;
  finally
    LQry.Free;
  end;
end;
procedure TSiparisWizardDlg.HazirlaSiparisDetayAlanlari;
begin
  TabSiparisDetay.AutoCalcFields := True;
  if TabSiparisDetay.FindField('RESIM') <> nil then
    TabSiparisDetay.FieldByName('RESIM').ProviderFlags := [];
  if TabSiparisDetay.FindField('DOKUMAN') <> nil then
    TabSiparisDetay.FieldByName('DOKUMAN').ProviderFlags := [];
  if TabSiparisDetay.FindField('BIRIMAD') <> nil then TabSiparisDetay.FieldByName('BIRIMAD').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('BIRIM2MIKTAR') <> nil then TabSiparisDetay.FieldByName('BIRIM2MIKTAR').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('BIRIM2AD') <> nil then TabSiparisDetay.FieldByName('BIRIM2AD').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('PROJEKODU') <> nil then TabSiparisDetay.FieldByName('PROJEKODU').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('SATICIADI') <> nil then TabSiparisDetay.FieldByName('SATICIADI').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('DONUSENMIKTAR') <> nil then TabSiparisDetay.FieldByName('DONUSENMIKTAR').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('URETIMPLANINDAGOSTER') <> nil then TabSiparisDetay.FieldByName('URETIMPLANINDAGOSTER').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('EKIPMAN') <> nil then TabSiparisDetay.FieldByName('EKIPMAN').FieldKind := fkCalculated;
  if TabSiparisDetay.FindField('SERINO') <> nil then TabSiparisDetay.FieldByName('SERINO').FieldKind := fkCalculated;

  if TabSiparisDetay.FindField('AD') <> nil then
    TabSiparisDetay.FieldByName('AD').ProviderFlags := [];
  if TabSiparisDetay.FindField('KOD') <> nil then
    TabSiparisDetay.FieldByName('KOD').ProviderFlags := [];
  if TabSiparisDetay.FindField('URUNNO') <> nil then
    TabSiparisDetay.FieldByName('URUNNO').ProviderFlags := [];
  TabSiparisDetay.UpdateOptions.UpdateTableName := 'SIPARISDETAY';
  TabSiparisDetay.UpdateOptions.KeyFields := 'ID';
end;

procedure TSiparisWizardDlg.YenileSiparisDetayClone;
begin
  if (not SIPARISDETAY.Active) or
     ((TabSiparisDetay.Params.FindParam('Par') <> nil) and (SIPARISDETAY.Params.FindParam('Par') <> nil) and
      (VarToStr(SIPARISDETAY.ParamByName('Par').Value) <> VarToStr(TabSiparisDetay.ParamByName('Par').Value))) then
  begin
    SIPARISDETAY.Close;
    if (TabSiparisDetay.Params.FindParam('Par') <> nil) and (SIPARISDETAY.Params.FindParam('Par') <> nil) then
      SIPARISDETAY.ParamByName('Par').Value := TabSiparisDetay.ParamByName('Par').Value
    else if (TabSiparis.Active) and (SIPARISDETAY.Params.FindParam('Par') <> nil) then
      SIPARISDETAY.ParamByName('Par').Value := TabSiparis.FieldByName('ID').Value;
    SIPARISDETAY.Open;
  end;
end;
procedure TSiparisWizardDlg.SeciliSatiraSubMenuClick(Sender: TObject);
begin
  TabSiparisDetay.Edit;
  TabSiparisDetay.FieldByName('KDV').AsInteger := TMenuItem(Sender).Tag;
  TabSiparisDetay.Post;
end;

procedure TSiparisWizardDlg.TumuneSubMenuClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'update SIPARISDETAY set KDV=&Yuzde where SIPARISID=&id ',['&Yuzde','&id'],
      [TMenuItem(Sender).Tag, TabSiparis.Fields[0].AsInteger]);
   FaturaToplamUpdate(True);
   TabSiparisDetay.Close;
   TabSiparisDetay.Open;
end;

procedure TSiparisWizardDlg.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if VK_RETURN = Key then Key := 0;
end;

procedure TSiparisWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TSiparisWizardDlg(Self),Tablo.UserDataSourceHazirla(TSiparisWizardDlg(Self), DtsTabSiparis, 'SIPARIS_USER'));
      Tablo.AlanOlustur(TSiparisWizardDlg(Self), -1, Tablo.UserDataSourceHazirla(TSiparisWizardDlg(Self), DtsTabSiparis, 'SIPARIS_USER'));
    end;
  end
  else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bileşen Düzenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
      Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(PanelUst.Name),TSiparisWizardDlg(Self),Tablo.UserDataSourceHazirla(TSiparisWizardDlg(Self), DtsTabSiparis, 'SIPARIS_USER'));
      Tablo.AlanOlustur(TSiparisWizardDlg(Self), -1, Tablo.UserDataSourceHazirla(TSiparisWizardDlg(Self), DtsTabSiparis, 'SIPARIS_USER'));
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
          //Tablo.AlanOlustur(FindComponent(PanelAlt.Name),TSiparisWizardDlg(Self),-1,DtsTabSiparis);
          Tablo.AlanOlustur(TSiparisWizardDlg(Self),-1,Tablo.UserDataSourceHazirla(TSiparisWizardDlg(Self), DtsTabSiparis, 'SIPARIS_USER'));
        end;
      end;
    end;
  end;

  if (TabSiparis.Active=False)or(TabSiparis.Fields[0].AsString='') then
      TabloYenile(TabSiparis, [SiparisIDsi]);
end;

procedure TSiparisWizardDlg.FormShow(Sender: TObject);
var
  ra: string;
  TN: TTreeNode;
  belgeno: TBelgeNo;
  aktifFrame : TGenelAnaSekmeFrame;
  kod: string;
  kullanan2: string;
  KurDegeri : currency;
  Guncel : boolean;
begin
  TabSiparisDetay.AutoCalcFields := False;
  FSkipDetailAfterScroll := True;
  TabSiparisDetay.DisableControls;
  try
  SiparisWizardDlg.Height:= Screen.Height- round(Screen.Height*0.1);
  EkleDetay := False;

  PageControlAlt.ActivePageIndex := 0;
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
  if cbKdvDurum.Properties.Items.Count=3 then
     cbKdvDurum.Properties.Items.delete(1);

  case SiparisTur of
   9 : ComboSiparisDURUM.RepositoryItem := Tablo.repSiparisDurumVerilen;
  19 : ComboSiparisDURUM.RepositoryItem := Tablo.repSiparisDurumAlinan;
  end;

  TabloNo := TabNo_SIPARIS_Gelen;

  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;
  if IslemOp in ['E','K'] then begin
     DetayTus.Enabled := False;
     cbStokDepo.RepositoryItem:=Tablo.RepStokDepolarAktif;  //Yeni faturada sadece aktif depolar olmalı
  end else
    cbStokDepo.RepositoryItem:=Tablo.RepStokDepolarTumu;  //Eski faturada pasif depolar da olabilir

(*
  if IslemOp='K' then begin
    Tablo.TablodanSorguAc(3,'select * from SIPARISDETAY where SIPARISID=' + inttostr(SiparisIdsi));
    case SiparisTur of
    9:  begin
        belgeno := SiradakiBelgeNumarasi(SiparisTur, TabSiparis.FieldByName('SIPARISTARIH').AsDateTime);
        SiparisIdsi := Tablo.SQLSatiriKopyala('SIPARIS', SiparisIdsi,['TARIH', 'SIPARISTARIH', 'EKLEYEN','SIPARISSERI', 'KOCANNO', 'SIPARISNO','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','ONAYLAYAN'],
          [Tablo.GENINI.BugunTrh, Tablo.GENINI.BugunTrhSaat, Kullanan,belgeno.SeriNo,KocannoBul(SiparisTur), belgeno.belgeno,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);
      end;
    19: begin
        belgeno := SiradakiBelgeNumarasi(SiparisTur, TabSiparis.FieldByName('SIPARISTARIH').AsDateTime);
        SiparisIdsi := Tablo.SQLSatiriKopyala('SIPARIS', SiparisIdsi,['TARIH', 'SIPARISTARIH', 'EKLEYEN', 'SIPARISSERI', 'KOCANNO', 'SIPARISNO', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','ONAYLAYAN'],
            [Tablo.GENINI.BugunTrh, Tablo.GENINI.BugunTrhSaat, Kullanan,  belgeno.SeriNo, KocannoBul(SiparisTur), belgeno.belgeno, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);
      end;
    end;
    while not Tablo.Query3.Eof do begin
      Tablo.SQLSatiriKopyala('SIPARISDETAY', Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', 'SIPARISID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI'],
          [Kullanan, SiparisIdsi,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
      Tablo.Query3.Next;
    end;
  end; *)

  //MenuEkr.Enabled :=  Tur in [0,1];
  case SiparisTur of
  0,9, 10, 11, 12:
    begin
      cbStokDepo.DataBinding.DataField := 'GIRISDEPO';
      //LabelDepo.Caption := 'Giriş Deposu';
      BaslikPaneli.Enabled := False;
      btnSevkAdresi.Visible:=False;
      lblSevkAdresi.Visible:=False;
      ComboFIYAT_LISTESI.RepositoryItem := Tablo.RepFiyatAdlariAlis;
      LabelMasrafMerkezi.Caption := 'Masraf Merkezi';
      GridFaturaViewMASRAFAD.Caption := MasrafAdi;
      SiparisEkr.Title.Text := 'Verilen Sipariş Bilgileri';
      lbSatici.Caption:='Satın Alan';
    end;
  1, 14, 15, 16,19:
    begin
      cbStokDepo.DataBinding.DataField := 'CIKISDEPO';
      //LabelDepo.Caption := 'Çıkış Deposu';
      BaslikPaneli.Enabled := True;
      btnSevkAdresi.Visible:=true;
      lblSevkAdresi.Visible:=true;
      ComboFIYAT_LISTESI.RepositoryItem := Tablo.RepFiyatAdlari;
      LabelMasrafMerkezi.Caption := 'Gelir Merkezi';
      GridFaturaViewMASRAFAD.Caption := GelirAdi;
      SiparisEkr.Title.Text := 'Alınan Sipariş Bilgileri';
      lbSatici.Caption:='Satıcı';
    end;
  end;

  LabelProje.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  LabelAktivite.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  BeditProje.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  BeditBagliGorev.Visible := Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme);
  DetayEkr.EnableButton(bkNext,Tablo.YetkiVarmi(MODUL_Kasa,YetkiTur_Gorme));
  TabloYenile(TabSiparis, [SiparisIdsi]);
  if not EkAlanOlustu then begin
     Tablo.AlanOlustur(TSiparisWizardDlg(Self), -1,Tablo.UserDataSourceHazirla(TSiparisWizardDlg(Self), DtsTabSiparis, 'SIPARIS_USER'));
     EkAlanOlustu:=True;
  end;
  Kilit := False;
  if (IslemOp='D')and(KilitKontrolEt(2, SiparisTur,TabSiparis.FieldByName('SIPARISTARIH').AsDateTime,2)) then begin
     Kilit := True;
     TabSiparis.Close;
     TabSiparis.Open;
     ToolBar5.visible := False;
     PanelUst2.enabled := False;
     cxTabSheet1.enabled := False;
  end;
  TabloYenile(TabSiparisDetay,[SiparisIdsi]);
  // Log: mevcut belge (D/I) yuklendiginde baslik+detay snapshot al (kaydette diff).
  if IslemOp in ['D','I'] then SiparisLogSnapshotAl;
  // Geri-alinabilir oturum (yalniz D=degistir): acilistaki hali SNAPSHOT'a al -> Cancel'da
  // ilk hale don, Finish'te temizle. (IMAJ blob + DOKUMAN dosya ilk pilotta KAPSAM DISI.)
  FOturumID := '';
  // _USER (ek alan) audit baseline: acilistaki SIPARIS_USER halini sakla -> finish'te diff.
  if LogGun > 0 then
    ULog.LogUserAcilis('SIPARIS_USER', SiparisIdsi);
  if IslemOp = 'D' then
    FOturumID := ULog.OturumBaslatPlan('SIPARIS', SiparisIdsi,   // LAZY: plan bellekte
      [ ULog.SnapTablo(1, 'SIPARIS',      'ID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(1, 'SIPARIS_USER', 'ID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(2, 'SIPARISDETAY', 'SIPARISID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(2, 'REHBERBILGI',  'YERI=' + IntToStr(DetaySablonTipiBul) + ' and YER_ID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(2, 'GOREVYORUM',   'TUR=' + IntToStr(TabNo_SIPARIS_Gelen) + ' and GOREVID=' + IntToStr(SiparisIdsi)),
        ULog.SnapTablo(3, 'DOKUMAN', 'MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabNo_SIPARIS_Gelen) + ' and GOREVID=' + IntToStr(SiparisIdsi) + ')'),
        ULog.SnapTablo(4, 'IMAJ',    'YERI=1 and YER_ID in (select ID from DOKUMAN where MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabNo_SIPARIS_Gelen) + ' and GOREVID=' + IntToStr(SiparisIdsi) + '))') ]);
  if RehberId<=0 then //yeni oluşurken buras? dolu geliyor
     RehberId := TabSiparis.FieldByName('REHBERID').AsInteger;
  FirmaBilgileri;

  if cagiran = 5 then  begin    //SATINALMA dan geliyor
     SatinAlmainsert;
  end;

  if (IslemOp='E')and(TabSiparisDetay.IsEmpty) then
     TabSiparis.Append;

  if (Cagiran in [9, 19])and(TabSiparis.FieldByName('DOVIZ_CINSI').AsString <> CariDoviz) then  begin           //Tekliften Oluşturulan Siparişlerde Toplamlar ve Doviz değerleri hesaplanıyor.
     //önce bakalım bu teklifin teklif dövizi TL mi? TL ise değişmeyecek
    //Tablo.TablodanSorguAc(1, 'select TEKLIF_DOVIZI from TEKLIF where ID='+TabSiparis.FieldByName('YERID').AsString);
//    if (Tablo.Query1.RecordCount>0)and(Tablo.Query1.Fields[0].AsString<>CariDoviz) then begin
//    if TabSiparis.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz then begin
        //cbStokDepo.Enabled:=True;
        TabSiparis.Edit;
        cbDovizCinsiPropertiesCloseUp(Sender);
        //TabSiparisDetay.AfterPost:=nil;
        TabSiparisDetay.First;
        while not TabSiparisDetay.eof do begin
          if TabSiparisDetay.FieldByName('DOVIZ_KURU').AsString <> CariDoviz then begin
             TabSiparisDetay.Edit;
             KurDegeri :=DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TabSiparis.FieldByName('SIPARISTARIH').AsDateTime),
                         TabSiparisDetay.FieldByName('DOVIZ_KURU').AsString , Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
             TabSiparisDetay.FieldByName('DOVIZKURDEGERI').AsCurrency := KurDegeri;
             TabSiparisDetay.Post;
          end;
          TabSiparisDetay.Next;
        end;
//    end;
//    TabSiparisDetay.AfterPost:=TabSiparisDetayAfterPost;
//    if TabSiparis.State in [dsEdit] then
//       TabSiparis.Post;
    TabloYenile(TOPLAMLAR,[TabSiparis.FieldByName('ID').AsInteger]);
  end;

  FaturaTusClick(WizardKontrol.ActivePage);
  LogBelge.Clear;
  if TabSiparisDetay.active then begin
    TabSiparisDetay.First;
    while not TabSiparisDetay.Eof do begin
      if LogGun>0 then begin
        Tablo.BelgeLogBelirle(TabSiparisDetay);
      end;
      TabSiparisDetay.Next;
    end;
    if (not TabSiparisDetay.IsEmpty)and(Kilit=False) then begin
        TabSiparisDetay.Edit;
        TabSiparisDetay.Cancel;
    end;
  end;

  if TabSiparis.active then  begin
    //Siparişe aktarım yapıldıysa döviz kurunun göncellenmesi gerekir..
    if (IslemOp = 'E')and(not TabSiparisDetay.IsEmpty) then begin
        if TabSiparis.FieldByName('SIPARIS_MATRAHI').AsString='' then begin
           TabSiparisDetay.Edit;
           TabSiparisDetay.Post;
        end;
        if TabSiparis.state in [dsEdit,dsInsert] then
           TabSiparis.Post;
        TabSiparisDetay.First; Guncel:=False;
        while not TabSiparisDetay.Eof do begin
           if TabSiparisDetay.FieldByName('DOVIZ_KURU').AsString <> CariDoviz then begin
              TabSiparisDetay.Edit;
              KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TabSiparisDetay.FieldByName('SIPARISTARIH').AsDateTime), TabSiparisDetay.FieldByName('DOVIZ_KURU').AsString , Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
              Guncel:=True;
              TabSiparisDetay.FieldByName('DOVIZKURDEGERI').AsCurrency := KurDegeri;
              TabSiparisDetay.Post;
           end;
           TabSiparisDetay.Next;
        end;
        if Guncel then
           ShowMessage(KurGuncellendi);
    end;

    if (TabSiparis.FieldByName('SERVISID').Value <> null) and (TabSiparis.FieldByName('SERVISID').AsInteger>0) then begin
      Tablo.TablodanSorguAc(9,'select * from SERVIS where ID='+TabSiparis.FieldByName('SERVISID').AsString);
      if not Tablo.Query9.IsEmpty then begin
        BeditServis.Text := Tablo.Query9.FieldByName('SERVISNO').AsString+' - '+Tablo.Query9.FieldByName('KONUSU').AsString;
        BeditServis.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
      end;
    end;

    if TabSiparis.FieldByName('PROJEID').AsString<>'' then
       BeditProje.Text:=Tablo.AciklamaGetir('PROJELER','PROJEKODU',TabSiparis.FieldByName('PROJEID').AsInteger);
    if TabSiparis.FieldByName('AKTIVITEID').AsString<>'' then begin
       Tablo.TablodanSorguAc(1, 'SELECT BASLAMATARIHI,TUR=GT1.ANAHTAR FROM GOREVLER G left join GENINI GT1 on GT1.BOLUM=-21044 and G.TURU=GT1.DEGER '+
          'where G.ID='+TabSiparis.FieldByName('AKTIVITEID').AsString);
       BeditBagliGorev.Text:=Tablo.Query1.Fields[0].AsString+' '+Tablo.Query1.Fields[1].AsString;
    end;
    if TabSiparis.FieldByName('MASRAFID').AsString <>'' then
       EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabSiparis.FieldByName('MASRAFID').AsInteger);
    if TabSiparis.FieldByName('SATICIKODU').AsString <> '' then
      cbSatici.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabSiparis.FieldByName('SATICIKODU').AsString);
    if TabSiparis.FieldByName('MUS_ILGILI').AsString<>'' then
       BeditMusIlgili.Text:=Tablo.AciklamaGetir('REHBER','FIRMA',TabSiparis.FieldByName('MUS_ILGILI').AsInteger);



    if TabSiparis.FieldByName('REHBERILETID').AsString <> '' then begin
       btnSevkAdresi.Text := Tablo.AciklamaGetir('REHBERILETISIM','AD', TabSiparis.FieldByName('REHBERILETID').AsString);
       Tablo.TablodanSorguAc(1,' Select RI.ID,RI.AD,RB.BILGI from REHBERILETISIM RI '+
        ' left outer JOIn REHBERBILGI RB on RI.ID=RB.YER_ID '+
        ' left outer join REHBERAYAR RA ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
        ' Where RB.YER_ID ='+TabSiparis.FieldByName('REHBERILETID').AsString+' and RB.YERI=1 and RA.VARSAYILAN=2 and RI.REHBERID='+TabSiparis.FieldByName('REHBERID').AsString+'');
       btnSevkAdresi.Hint :=Tablo.Query1.FieldByName('BILGI').AsString;
    end;
  end;

  WizardKontrol.SelectFirstPage;
  PageUst.ActivePageIndex := 0;
  if SiparisTur=9 then
    cbOnaylayacak.Properties.Items := Tablo.imgComboboxInit('select ID=0, FIRMA='''' union all '+StringReplace(OnayYetki, '@YetkiKodu', '24011150', []),False).Items
  else
    cbOnaylayacak.Properties.Items := Tablo.imgComboboxInit('select ID=0, FIRMA='''' union all '+StringReplace(OnayYetki, '@YetkiKodu', '24111150', []) ,False).Items;

  OncekiOnaylayacak := TabSiparis.FieldByName('ONAYLAYACAK').AsInteger;

  if not Tablo.YetkiVarmi(2431,1,False) then begin  //tutarlar gözükmesin denirse;
    GridFaturaView.OptionsView.Footer := False;
    GridFaturaView.OptionsView.GroupFooters := gfInvisible;
    //for I := 0 to GridFatListeTview.ColumnCount-1 do
      //GridFatListeTview.Columns[i].Summary.Destroy;
    Miktarskontosu1.Visible := False;
    Yzdeskontosu1.Visible := False;
    utarDvzHesapla1.Visible := False;
  end;

  finally
    TabSiparisDetay.EnableControls;
    FSkipDetailAfterScroll := False;
    TabSiparisDetayAfterScroll(TabSiparisDetay);
  end;

  if not FDeferredCalcInitDone then begin
    FDeferredCalcInitDone := True;
    TThread.Queue(nil,
      procedure
      begin
        if csDestroying in ComponentState then
          Exit;
        TabSiparisDetay.AutoCalcFields := True;
        if TabSiparisDetay.Active then
          TabSiparisDetay.Refresh;
      end);
  end else
    TabSiparisDetay.AutoCalcFields := True;

  if (TabSiparis.FieldByName('REHBERID').AsInteger < 0)and(TabSiparis.FieldByName('TUR').AsInteger <> 101) then
      LabelKodClick(Self);
end;

procedure TSiparisWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TSiparisWizardDlg.GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry:TDataSet;
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

procedure TSiparisWizardDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TSiparisWizardDlg.GridFaturaViewACIKLAMA1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := TabSiparisDetay.fieldByName('ACIKLAMA').asstring;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Memo(BGAciklama_gir, @Bilgi)) <> mrOk then    //.Edit(FWToplamTutariGir, @Tutar
      Abort;
   TabSiparisDetay.edit;
   TabSiparisDetay.fieldByName('ACIKLAMA').AsString := VarToStr(Bilgi);
end;

procedure TSiparisWizardDlg.GridFaturaViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridFatura;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFaturaView;
  AnaForm.pmGridStil.Tags.Values[GridFatura.Name]:='FatSiparisDetayGridi';
end;

procedure TSiparisWizardDlg.GridFaturaViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if Kilit then exit;
  Tablo.SatirGuncelle(TabSiparisDetay, SiparisTur, 1, TabSiparis.FieldByName('REHBERID').AsInteger, TabSiparis.FieldByName('SIPARISTARIH').AsDateTime,[]);
end;

procedure TSiparisWizardDlg.GridFaturaViewDOKUMANPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var Sonuclar : TStringList;
begin
//
  Sonuclar := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir(BGDepo_kullan, 'select DOKUMANAD=D.AD, DOKUMANID=D.ID '+
           ' from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '+
           ' where GY.TUR=88 and GOREVID='+TabSiparisDetay.FieldByName('URUNID').AsString+' order by 1 ', Sonuclar,  []) then
        tablo.Dokuman_Gor_Duzenle(1, StrToIntDef(Sonuclar[1], 0), Sonuclar[0]);
    finally
      FreeAndNil(Sonuclar);
    end;
end;

procedure TSiparisWizardDlg.GridFaturaViewEKIPMANIDPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st  : Tstringlist;
  SQL : string;
begin
 SQL:='Select ER.ID, E.KOD,E.AD, E.DETAYBOLUMU , '+
      '  ER.SERINO,ER.ACIKLAMA, ILGILI=(select ADSOYAD=FIRMA from REHBER RP where RP.ID=ER.MUS_ILGILI ), '+
      '  LOKASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=ER.LOKASYONID) '+
      '  from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID '+
      '  Where  ER.REHBERID=' + TabSiparis.FieldByName('REHBERID').AsString+' and E.AD like ''%<ara>%'' ';
  TabSiparisDetay.Edit;
  if AButtonIndex = 0 then try
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(ProjeSecimi,SQL, st, []) then begin
      TabSiparisDetay.FieldByName('EKIPMANID').AsString := st.Strings[0];
      TabSiparisDetay.Post;
    end;
  finally
    st.free;
  end else if AButtonIndex = 1 then begin
    TabSiparisDetay.FieldByName('EKIPMANID').AsString := '-1';
    TabSiparisDetay.Post;
  end;
end;

procedure TSiparisWizardDlg.GridFaturaViewMASRAFADGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
begin
 if ARecord.Values[GridFaturaViewMASRAFAD.Index]>0 then
    AText := Tablo.AciklamaGetir('MASRAFGELIR','AD',ARecord.Values[GridFaturaViewMASRAFAD.Index]);
end;

procedure TSiparisWizardDlg.GridFaturaViewMASRAFADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
   if SiparisTur in [14..19] then
      i := 1
   else
      i := 0;
   if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      TabSiparisDetay.Edit;
      TabSiparisDetay.FieldByName('MASRAFID').AsString := MASRAFID;
   end;

end;

procedure TSiparisWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   if WizardKontrol.ActivePage = SiparisEkr then begin
      labelDetayFileName.Visible := True;
      labelDetayFileName.Caption := ExtractFileName(Value.Strings[0]);
      labelDetayFileName.Hint := Value.Strings[0];
   end else begin
      labelFileName.Visible := True;
      labelFileName.Caption := ExtractFileName(Value.Strings[0]);
      labelFileName.Hint := Value.Strings[0];
   end;
end;

procedure TSiparisWizardDlg.LabelAdClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(0,TabSiparis.FieldByName('REHBERID').AsInteger,-100, -100, False);
end;

procedure TSiparisWizardDlg.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
  Id := Tablo.RehberAra_IDGetir(-1);
  if Id>0 then begin
      RehberId := Id;
      if TabSiparis.State = dsBrowse then
         TabSiparis.Edit;
      TabSiparisNewRecord(TabSiparis);
      TabSiparis.FieldByName('REHBERID').AsInteger := RehberId;
      Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
      TabSiparis.FieldByName('REHBERILETID').AsInteger := tablo.Query1.Fields[0].AsInteger;
      FirmaBilgileri;
    if SiparisTur =19 then begin
      Tablo.FaturaBaslik(TabSiparis,RehberId);
    end;
  end;
end;

procedure TSiparisWizardDlg.lbDetaySablonClick(Sender: TObject);
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

procedure TSiparisWizardDlg.MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if SiparisTur < 10 then
    raise Exception.Create(Aksiyon_sec);
end;

procedure TSiparisWizardDlg.MenuItem4Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDetayView, TabNo_SIPARISDETAY);
end;

procedure TSiparisWizardDlg.MenuItem5Click(Sender: TObject);
begin
    Tablo.GridYorumuSil(TabNo_SIPARISDETAY, TabSiparisDetay.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TSiparisWizardDlg.MenuDokGosterClick(Sender: TObject);
begin
   Tablo.GridYorumDokumaniGor(GridYorumDetayView);
end;

procedure TSiparisWizardDlg.MemoFatAdresKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   AdresDegisti := True;
end;

procedure TSiparisWizardDlg.MenuDokFormuAcClick(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabSiparisDetay.FieldByName('ID').AsInteger)
end;

procedure TSiparisWizardDlg.MenuDokSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: dokuman silme -> yakala
  if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_SIPARISDETAY, TabSiparisDetay.FieldByName('ID').AsInteger]);
  end;
end;

procedure TSiparisWizardDlg.MenuItem7Click(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelDetayFileName, BtnMesajGonderDetay);
end;

procedure TSiparisWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: klasorden dosya ekleme -> yakala
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TSiparisWizardDlg.MenuMusTreeDblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TSiparisWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: tarayicidan dosya ekleme -> yakala
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TSiparisWizardDlg.N52Click(Sender: TObject);
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
          ',DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0 where SIPARISID=&id ',['&Yuzde','&id'],[s, TabSiparis.Fields[0].AsInteger])
   else if IskTipi='İskonto2' then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO2=&Yuzde, TUTAR=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 '+
          ', DOVIZ_TUTARI=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*DOVIZ_BIRIMFIYAT/10000.0 where SIPARISID=&id ',['&Yuzde','&id'],[s, TabSiparis.Fields[0].AsInteger]);
   FaturaToplamUpdate(True);
   TabSiparisDetay.Close;
   TabSiparisDetay.Open;
end;

procedure TSiparisWizardDlg.PageUstChange(Sender: TObject);
begin
   if PageUst.Pages[PageUst.ActivePageIndex].Name = 'SheetGenotip' then begin
      EditAd.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSiparis.FieldByName('REHBERID_HASTA').AsInteger);
      if TabSiparis.FieldByName('REHBERID_HASTA').AsString<>'' then begin
         Tablo.TablodanSorguAc(1,'SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA '+
         ' AND RA.YERI=RB.YERI WHERE RB.YER_ID='+TabSiparis.FieldByName('REHBERID_HASTA').AsString+' AND RA.VARSAYILAN=22 '+DbSinir(1));
         if not Tablo.Query1.IsEmpty then
            EditTCKN.Text := Tablo.Query1.Fields[0].AsString;
      end;
      EditKimlikId.Text := TabSiparis.FieldByName('GNTP_KIMLIKID').AsString;
      EditSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSiparis.FieldByName('REHBERID_SORUMLU').AsInteger);
      EditKurumu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSiparis.FieldByName('REHBERID_KURUM').AsInteger);
      EditPoliklinik.Text := Tablo.GENINI.AnahtarGetir(-25000,  TabSiparis.FieldByName('POLIKLINIKID').AsInteger, -1, '');
      EditDoktor.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSiparis.FieldByName('REHBERID_DOKTOR').AsInteger);
      EditReferans.Text :=  Tablo.GENINI.AnahtarGetir(-25002,  TabSiparis.FieldByName('REFERANSID').AsInteger,-1,'');
      EditGonderen.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSiparis.FieldByName('REHBERID_GONDEREN').AsInteger);
   end
   else if (EkAlanOlustu)and(PageUst.Pages[PageUst.ActivePageIndex].Name = 'TabSheetEkAlanlar')and(TabSiparis.FieldByName('ID').AsInteger < 1) then
           TabSiparis.post;
end;

procedure TSiparisWizardDlg.PopupYorumDetayMenuPopup(Sender: TObject);
begin
    MenuDokgoster.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    MenuDokFormuAc.Visible := MenuDokgoster.Visible;
    MenuDokSil.Visible := MenuDokgoster.Visible;
end;

procedure TSiparisWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TSiparisWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum silme -> yakala
   Tablo.GridYorumuSil(TabloNo, TabSiparis .FieldByName('ID').AsInteger, TabYorum);
end;

procedure TSiparisWizardDlg.SatirEkleClick(Sender: TObject);
begin
  if TabSiparis.State in [dsEdit, dsInsert] then begin
     TabSiparis.Post;
     TabloYenile(TabSiparisDetay, [SiparisIdsi]);
  end;

  if AraDlg=nil then
     Application.CreateForm(TStokHizmetAraDlg,AraDlg);

  AraDlg.FatBasID:=TabSiparis.FieldByName('ID').AsInteger;
  AraDlg.RehberID:=TabSiparis.FieldByName('REHBERID').AsInteger;
  AraDlg.TabDetayGiris:= TabSiparisDetay;
  AraDlg.TabGiris := TabSiparis;
  AraDlg.KalanAdetGetir:=True;
  AraDlg.stokhizmetaracagirantur := TabSiparis.FieldByName('TUR').AsInteger;
  case SiparisTur of
   9 : AraDlg.GirisCikis:=FWGiris;
  19 : AraDlg.GirisCikis:=FWCikis;
  end;
  AraDlg.FiyatlariGetir:=True;
  AraDlg.cbFiyatAdi.EditValue := TabSiparis.FieldByName('FIYAT_LISTESI').Value;
  AraDlg.cbStokDepo.EditValue:=cbStokDepo.EditValue;
  if Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme) then begin
     AraDlg.cbStokDepo.EditValue := cbStokDepo.EditValue;
     if TabSiparisDetay.IsEmpty then
        AraDlg.cbStokDepo.Enabled := True //daha önce depo seçimi yapılmamış, yap?labilir
     else            //girilmiş stok i?lemi var mı?
        AraDlg.cbStokDepo.Enabled := not Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SIPARISDETAY where SIPARISID =  &FId and TUR=1', ['&FId'],[TabSiparis.FieldByName('ID').AsInteger]);
  end;
  AraDlg.ShowModal;
  editDovizKuru.Visible := ComboRaporDovizi.Text <> CariDoviz;

  cbStokDepo.EditValue := AraDlg.cbStokDepo.EditValue;
  cbStokDepo.Enabled := TabSiparisDetay.IsEmpty;

end;

procedure TSiparisWizardDlg.SatirSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: satir silme -> yakala
  if TabSiparisDetay.IsEmpty then abort;

  if Application.MessageBox(PCHAR(Sil_Onay),pchar(Onay), MB_YESNO + MB_ICONQUESTION) = ID_YES then begin
     ///önce bu satırdan dönüşüm olmu? mu bakalım
     Tablo.TablodanSorguAc(1,'select * from FATURA where YERI=409 and YERID='+TabSiparisDetay.FieldByName('ID').AsString);
     if not Tablo.Query1.IsEmpty then begin
        ShowMessage(DonusumYapilmis);
        exit;
     end;

    TabSiparisDetay.Delete;
  end;
end;

procedure TSiparisWizardDlg.SipariKoanAyarlar1Click(Sender: TObject);
begin
  Tablo.KocanAyarlariniGetir(TabSiparis.FieldByName('TUR').AsInteger);
end;

procedure TSiparisWizardDlg.TabSiparisAfterOpen(DataSet: TDataSet);
begin
  if (not TabSiparis.IsEmpty)and(TabSiparis.FieldByName('ID').AsString<>'') then begin
    if TabSiparis.FieldByName('ONAYLAYAN').AsString <> '' then
       EditOnaylayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabSiparis.FieldByName('ONAYLAYAN').AsString)
    else
       EditOnaylayan.Text := '';
  end else
       EditOnaylayan.Text := '';
end;

procedure TSiparisWizardDlg.TabSiparisAfterPost(DataSet: TDataSet);
begin
   SiparisIdsi := TabSiparis.Fields[0].AsInteger;
   DetayTus.Enabled := True;
   TabloYenile(TOPLAMLAR,[SiparisIdsi]);
   Tablo.TablodanSorguAc(3,'select 1 from SIPARIS where REHBERID='+TabSiparis.FieldByName('REHBERID').AsString
                                                      +' and TUR='+TabSiparis.FieldByName('TUR').AsString
                                                      +' and SIPARISNO='''+TabSiparis.FieldByName('SIPARISNO').AsString
                                                      +''' ');
   Tablo.Query3.FetchAll;
   if Tablo.Query3.RecordCount>1 then
      showmessage(SipariskulNo);


    if AdresDegisti then begin
       AdresDegisti := False;
       if Application.MessageBox(PChar(Adresdegistikartguncelle),PChar(Uyari),MB_YESNO)=mrYes then begin
          Tablo.RehberBilgiGuncelle(TabSiparis.FieldByName('REHBERID').AsInteger,1,2,MemoFatAdres.Text);
          Tablo.RehberBilgiGuncelle(TabSiparis.FieldByName('REHBERID').AsInteger,1,6,EditILCE.Text);
          Tablo.RehberBilgiGuncelle(TabSiparis.FieldByName('REHBERID').AsInteger,1,8,EditIL.Text);
          Tablo.RehberBilgiGuncelle(TabSiparis.FieldByName('REHBERID').AsInteger,2,20,EditVD.Text);
          Tablo.RehberBilgiGuncelle(TabSiparis.FieldByName('REHBERID').AsInteger,2,22,EditVNO.Text);
       end;
    end;
end;

procedure TSiparisWizardDlg.TabSiparisBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: siparis ilk degisikligi -> yakala
   OncekiKDVDurumu := TabSiparis.FieldByName('KDVDURUM').AsString;
   OncekiSubeID :=TabSiparis.FieldByName('SUBEID').AsInteger;
   if LogGun>0 then begin
     Tablo.OncekiLogBelirle(TabSiparis);
   end;

end;

procedure TSiparisWizardDlg.TabSiparisBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: siparis post -> yakala
  BoslukKontrolu;
  //Bu cariden bu sipari? no ile daha önce sipari? al?nm?? m? kontrolü yapal?m
  //Tablo.TablodanSorguAc(2,'select ID from SIPARIS where ')

  if TabSiparis.FieldByName('ONAYLAYACAK').AsString='0' then
    TabSiparis.FieldByName('ONAYLAYACAK').Value := null;
  if (TabSiparis.State=dsInsert)and(Pos('Perakende', LabelAd.Caption)>0)  then
      TabSiparis.FieldByName('ACIKLAMA').AsString := TabSiparis.FieldByName('ACIKLAMA').AsString+' '+TabSiparis.FieldByName('BASLIK').AsString;
  if OncekiSubeID <> TabSiparis.FieldByName('SUBEID').AsInteger then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update SIPARISDETAY set SUBEID='+TabSiparis.FieldByName('SUBEID').AsString+' Where SIPARISID ='+IntToStr(SiparisIdsi)+' ',[],[]);
  EkleyenDegistiren(DtsTabSiparis);
end;

function TSiparisWizardDlg.ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
begin
  if TOPLAMLAR.Locate('TUR', Bolum,[loPartialKey]) then
    result := TOPLAMLAR.FieldByName(TLDoviz).AsExtended
  else
    result:=-99999;
end;

procedure TSiparisWizardDlg.FaturaToplamUpdate(TabloAc:Boolean);
var DOVIZKUR,TabSiparisDetay_MATRAHI,KDV_TUTARI,TabSiparisDetay_TUTARI,DOVIZ_TUTARI,MALIYETORT,STOPAJ : extended;
    RaporDoviz,s:String;
begin
  TabloYenile( TOPLAMLAR, [TabSiparis.Fields[0].AsInteger]);
  TabSiparisDetay_MATRAHI := ToplamGetir(4,'DEGER');
  if TabSiparisDetay_MATRAHI=-99999 then
     TabSiparisDetay_MATRAHI := ToplamGetir(1,'DEGER'); //Toplam
  TabSiparisDetay_TUTARI  := ToplamGetir(20,'DEGER');    //'Genel Toplam'
  DOVIZ_TUTARI   := ToplamGetir(20,'DOVIZTUTARI');
  KDV_TUTARI     := TabSiparisDetay_TUTARI-TabSiparisDetay_MATRAHI;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARIS SET  '+ //RaporDoviz+
        'SIPARIS_MATRAHI='+FCurrToStr(TabSiparisDetay_MATRAHI)+',KDV_TUTARI='+FCurrToStr(KDV_TUTARI)+
        ',SIPARIS_TUTARI='+FCurrToStr(TabSiparisDetay_TUTARI)+', DOVIZ_TUTARI= '+FCurrToStr(DOVIZ_TUTARI)+ S+
        ' where ID='+TabSiparis.Fields[0].AsString,[],[]);

  if TabloAc then
     TabloYenile(TabSiparis, [TabSiparis.Fields[0].AsInteger]);
end;

procedure TSiparisWizardDlg.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  lblMusteriAdres.Caption:='Adres: '+ Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+' '+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+' / '+Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  lblMusteriTel.Caption:= 'İş Tel: '+Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
  lblMusteriEposta.Caption:= 'Eposta: '+Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TSiparisWizardDlg.TabSiparisDetayAfterDelete(DataSet: TDataSet);
begin
  FaturaToplamUpdate(True);
  TabSiparisDetay.Refresh;
  if TabSiparisDetay.IsEmpty then begin
     editDovizKuru.Visible := False;
     TabSiparis.Edit;
     TabSiparis.FieldByName('RAPORDOVIZ').AsString := CariDoviz;
     TabSiparis.FieldByName('DOVIZ_CINSI').AsString:=CariDoviz;
     TOPLAMLAR.Close
  end;
end;

procedure TSiparisWizardDlg.TabSiparisDetayAfterOpen(DataSet: TDataSet);
begin
  cbStokDepo.Enabled := TabSiparisDetay.IsEmpty;
end;

procedure TSiparisWizardDlg.TabSiparisDetayAfterPost(DataSet: TDataSet);
begin
   TabloYenile(TabSiparisDetay,[TabSiparis.FieldByName('ID').AsInteger]);
   TabloYenile(TOPLAMLAR,[TabSiparis.FieldByName('ID').AsInteger]);
   FaturaToplamUpdate(True);
end;

procedure TSiparisWizardDlg.TabSiparisDetayAfterScroll(DataSet: TDataSet);
begin
   if FSkipDetailAfterScroll then
      Exit;

   if TabSiparisDetay.Active then begin
      if not TabSiparisDetay.IsEmpty then
         Tabloyenile(TabYorum, [TabNo_SIPARISDETAY, TabSiparisDetay.FieldByName('ID').AsInteger])
      else
         TabYorum.Close;
   end;
end;

procedure TSiparisWizardDlg.TabSiparisDetayBeforeOpen(DataSet: TDataSet);
begin
   TabSiparisDetay.SQL.Text := StringReplace(TabSiparisDetay.SQL.Text,'@Dil',IntToStr(Dil),[rfReplaceAll]);
end;

procedure TSiparisWizardDlg.TabSiparisDetayBeforePost(DataSet: TDataSet);
var
  Kur,Dovizkuru:string;
  Tutar,Doviztutari:Extended;

  Procedure TutarIslemler;
  begin
     TabSiparisDetay.FieldByName('DOVIZ_TUTARI').Value :=Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabSiparisDetay.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabSiparisDetay.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,TabSiparisDetay.FieldByName('ADET').Value*TabSiparisDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsExtended));
     TabSiparisDetay.FieldByName('BIRIMFIYAT').AsCurrency := TabSiparisDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency * TabSiparisDetay.FieldByName('DOVIZKURDEGERI').AsCurrency;
     TabSiparisDetay.FieldByName('TUTAR').Value := Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabSiparisDetay.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabSiparisDetay.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,TabSiparisDetay.FieldByName('ADET').Value*TabSiparisDetay.FieldByName('BIRIMFIYAT').AsExtended));
  end;
begin
  ULog.OturumYakala(FOturumID);   // LAZY: siparis satiri post -> yakala
  if StrToIntDef(TabSiparis.FieldByName('ONAYLAYAN').AsString,0) <> 0 then begin
    if Tablo.UyariGoster(Uyari,'Yaptığınız değişiklik sipariş onayını kaldıracaktır, devam etmek ister misiniz?',2)=mrYes then
      EditOnaylayanPropertiesButtonClick(Nil,1)
    else
      Abort;
  end;
//  SIPARISDETAY_Hesapla;
  // tur 1 olursa stok diğerleri için hizmet..
  if (TabSiparisDetay.FieldByName('ISKONTO').AsFloat=0)and(TabSiparisDetay.FieldByName('ISKONTO2').AsFloat<>0) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGSadeceIskonto2Girilemez);
     Abort;
  end;
  if (not Eksiskontoya)and((TabSiparisDetay.FieldByName('ISKONTO').AsFloat<0)or(TabSiparisDetay.FieldByName('ISKONTO2').AsFloat<0)) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGEksiIskontoGirilemez);
     Abort;
  end;
  TutarIslemler;
    //bu bölüm her durumda çalışmalı..
  if (TabSiparisDetay.FieldByName('TUR').AsInteger = 1)and(TabSiparisDetay.FieldByName('BIRIM').AsString<>'') then // stoksa
      TabSiparisDetay.FieldByName('MIKTAR').AsFloat :=(TabSiparisDetay.FieldByName('ADET').AsFloat + TabSiparisDetay.FieldByName('MF').AsFloat) * Tablo.StokCarpan(TabSiparisDetay.FieldByName('URUNID').AsInteger, TabSiparisDetay.FieldByName('BIRIM').AsInteger)
  else if TabSiparisDetay.FieldByName('TUR').AsInteger = 0 then  //Hizmetse
      TabSiparisDetay.FieldByName('MIKTAR').AsFloat :=(TabSiparisDetay.FieldByName('ADET').AsFloat + TabSiparisDetay.FieldByName('MF').AsFloat);

  if not BoslukKontrol(TabSiparisDetay.FieldByName('ADET').AsString, 'Fatura adet') then
    Abort;
  if not BoslukKontrol(TabSiparisDetay.FieldByName('KDV').AsString, 'KDV') then
    Abort;


  if (TabSiparisDetay.FieldByName('TUR').AsInteger=1)and(veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMRECETE where STOKID='+TabSiparisDetay.FieldByName('URUNID').AsString,[],[])) then
    TabSiparisDetay.FieldByName('URETIMPLANDETAYID').AsInteger := 0
  else
    TabSiparisDetay.FieldByName('URETIMPLANDETAYID').AsInteger := -1;

  EkleyenDegistiren(DtsTabSiparisDetay);
end;

procedure TSiparisWizardDlg.TabSiparisDetayCalcFields(DataSet: TDataSet);
const
    CalcNames: array[0..8] of string = (
      'BIRIMAD','BIRIM2MIKTAR','BIRIM2AD','PROJEKODU','SATICIADI',
      'DONUSENMIKTAR','URETIMPLANINDAGOSTER','EKIPMAN','SERINO');
var
  I: Integer;
  Src, Dst: TField;
  Bmk: TBookmark;
begin
  if DataSet <> TabSiparisDetay then
    Exit;
  if TabSiparisDetay.State in [dsInsert, dsEdit] then
    Exit;

  for I := Low(CalcNames) to High(CalcNames) do
  begin
    Dst := TabSiparisDetay.FindField(CalcNames[I]);
    if Dst <> nil then
      Dst.Clear;
  end;

  if (not SIPARISDETAY.Active) or
     ((TabSiparisDetay.Params.FindParam('Par') <> nil) and (SIPARISDETAY.Params.FindParam('Par') <> nil) and
      (VarToStr(SIPARISDETAY.ParamByName('Par').Value) <> VarToStr(TabSiparisDetay.ParamByName('Par').Value))) then
  begin
    SIPARISDETAY.Close;
    if (TabSiparisDetay.Params.FindParam('Par') <> nil) and (SIPARISDETAY.Params.FindParam('Par') <> nil) then
      SIPARISDETAY.ParamByName('Par').Value := TabSiparisDetay.ParamByName('Par').Value
    else if (TabSiparis.Active) and (SIPARISDETAY.Params.FindParam('Par') <> nil) then
      SIPARISDETAY.ParamByName('Par').Value := TabSiparis.FieldByName('ID').Value;
    SIPARISDETAY.Open;
  end;
  if not SIPARISDETAY.Active then
    Exit;

  if (TabSiparisDetay.FindField('ID') = nil) or TabSiparisDetay.FieldByName('ID').IsNull then
    Exit;

  Bmk := nil;
  SIPARISDETAY.DisableControls;
  try
    Bmk := SIPARISDETAY.GetBookmark;
    if not SIPARISDETAY.Locate('ID', TabSiparisDetay.FieldByName('ID').AsInteger, []) then
      Exit;

    for I := Low(CalcNames) to High(CalcNames) do
    begin
      Dst := TabSiparisDetay.FindField(CalcNames[I]);
      Src := SIPARISDETAY.FindField(CalcNames[I]);
      if (Dst <> nil) and (Src <> nil) then
        Dst.Value := Src.Value;
    end;
  finally
    if Assigned(Bmk) then
    begin
      SIPARISDETAY.GotoBookmark(Bmk);
      SIPARISDETAY.FreeBookmark(Bmk);
    end;
    SIPARISDETAY.EnableControls;
  end;
end;
procedure TSiparisWizardDlg.TabSiparisDetayNewRecord(DataSet: TDataSet);
begin
  TabSiparisDetay.FieldByName('SIPARISID').AsInteger := TabSiparis.FieldByName('ID').AsInteger;
  TabSiparisDetay.FieldByName('REHBERID').AsInteger := RehberId;
  //TabSiparisDetay.FieldByName('DOVIZKURDEGERI').AsCurrency:=1;
  TabSiparisDetay.FieldByName('MASRAFID').AsInteger := TabSiparis.FieldByName('MASRAFID').AsInteger;
  TabSiparisDetay.FieldByName('EKLEYEN').AsString := Kullanan;
//  TabSiparisDetay.FieldByName('ISKONTO').AsInteger := 0;
//  TabSiparisDetay.FieldByName('ISKONTO2').AsInteger := 0;
//  TabSiparisDetay.FieldByName('KUR').AsString := CariDoviz;
  TabSiparisDetay.FieldByName('TESLIMTARIHI').Value :=Date;
  TabSiparisDetay.FieldByName('SUBEID').AsInteger := SubeID;
//  TabSiparisDetay.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  TabSiparisDetay.FieldByName('PROJEID').AsInteger := TabSiparis.FieldByName('PROJEID').AsInteger;
  if PozNoAktif then begin
     Tablo.TablodanSorguAc(1, 'select isnull(max(POZNO),0)+'+IntToStr(PozNoAralik)+' from SIPARISDETAY where SIPARISID='+TabSiparis.FieldByName('ID').AsString);
     TabSiparisDetay.FieldByName('POZNO').AsInteger := Tablo.Query1.Fields[0].AsInteger;
  end;
end;

procedure TSiparisWizardDlg.TabSiparisDetayENChange(Sender: TField);
begin
  // EN/BOY/YUZEY/SAYI alanlari su an devre disi; alan yoksa hesaplama yapma.
  if not EnBoyHesaplamaAktif then
    Exit;

  if (Trim(TabSiparisDetay.FieldByName('EN').AsString) <> '') and (Trim(TabSiparisDetay.FieldByName('BOY').AsString) <> '')
     and (Trim(TabSiparisDetay.FieldByName('SAYI').AsString) <> '')then
  begin
    TabSiparisDetay.FieldByName('YUZEY').AsFloat := (TabSiparisDetay.FieldByName('EN').AsFloat * TabSiparisDetay.FieldByName('BOY').AsFloat) / 1000000;
    TabSiparisDetay.FieldByName('ADET').AsFloat := TabSiparisDetay.FieldByName('YUZEY').AsFloat * TabSiparisDetay.FieldByName('SAYI').AsFloat;
  end;
end;

procedure TSiparisWizardDlg.TamEkranTusClick(Sender: TObject);
begin
  PanelUst.Visible := not PanelUst.Visible;
  PanelAlt.Visible := PanelUst.Visible;
  if PanelUst.Visible then
    TamEkranTus.Caption := 'Tam Ekran'
  else
    TamEkranTus.Caption := 'Küçük Ekran'
end;

procedure TSiparisWizardDlg.TeslimTarihiSeciliSatiraMenuClick(Sender: TObject);
var Tarih :  Variant;
    I, SipId : integer;
begin
 if GridFaturaView.Controller.SelectedRecordCount>0 then begin
    if TabSiparisDetay.FieldByName('TESLIMTARIHI').AsDateTime < Tablo.GenIni.BugunTrh - 10000  then
       Tarih := Tablo.GenIni.BugunTrh
    else
       Tarih := TabSiparisDetay.FieldByName('TESLIMTARIHI').AsDateTime;
    if TGirisKutusuEx.BilgiAlEx(BGTeslim_Tarihi ,
                              TGirdiDenetimleri.Create.DateTimePicker(BGTeslim_Tarihi+':', @Tarih,dtkDate)) <> mrOk then
                              Abort;


    for I := 0 to GridFaturaView.Controller.SelectedRecordCount-1 do begin
          SipId := StrToIntDef(VarToStr(GridFaturaView.Controller.SelectedRows[i].Values[GridFaturaViewID.Index]),0);
          if SipId > 0 then begin
             VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set TESLIMTARIHI ='''+FormatDateTime('yyyy-mm-dd 00:00', Tarih)+''' where ID = '+IntToStr(SipId),[],[]);
              //TabSiparisDetay.Edit;
              //TabSiparisDetay.FieldByName('TESLIMTARIHI').AsDateTime := TDateTime(Tarih);
              //TabSiparisDetay.Post;
          end;
    end;
    TabloYenile(TabSiparisDetay, [TabSiparis.FieldByName('ID').AsInteger]);
 end;
end;

procedure TSiparisWizardDlg.TeslimTarihiTumuneMenuClick(Sender: TObject);
var Tarih :  Variant;
begin
   if TabSiparisDetay.FieldByName('TESLIMTARIHI').AsDateTime < Tablo.GenIni.BugunTrh - 10000  then
     Tarih := Tablo.GenIni.BugunTrh
   else
     Tarih := TabSiparisDetay.FieldByName('TESLIMTARIHI').AsDateTime;
   if TGirisKutusuEx.BilgiAlEx(BGTeslim_Tarihi ,
                  TGirdiDenetimleri.Create.DateTimePicker(BGTeslim_Tarihi+':', @Tarih,dtkDate)) <> mrOk then
                  Abort;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'update SIPARISDETAY set TESLIMTARIHI=&TTarihi where SIPARISID=&id ',['&TTarihi','&id'],
      [FormatDateTime('yyyy-mm-dd', TDateTime(Tarih)), TabSiparis.Fields[0].AsInteger]);
   FaturaToplamUpdate(True);
   TabSiparisDetay.Close;
   TabSiparisDetay.Open;
end;

procedure TSiparisWizardDlg.TutarDvzHesapla1Click(Sender: TObject);
var
  Tutar,DovizTutar:Extended;
  Kur,DovizKur:string;
begin
{  Tutar := TabSiparisDetay.FieldByName('BIRIMFIYAT').Value;
  if TabSiparisDetay.FieldByName('DOVIZ_TUTARI').AsString <> '' then
     DovizTutar := TabSiparisDetay.FieldByName('DOVIZ_TUTARI').Value
  else
     DovizTutar := 0;
  DovizKur := TabSiparisDetay.FieldByName('DOVIZ_KURU').AsString;
  Kur := TabSiparisDetay.FieldByName('KUR').AsString;
  if Tablo.DovizKuruSecimi(True,TabSiparis.FieldByName('SIPARISTARIH').AsDateTime,Kur,DovizKur,Tutar,DovizTutar) then begin
     if TabSiparisDetay.State <> dsEdit then
        TabSiparisDetay.Edit;
     TabSiparisDetay.FieldByName('BIRIMFIYAT').Value := Tutar;
     TabSiparisDetay.FieldByName('KUR').Value := Kur;
     TabSiparisDetay.FieldByName('DOVIZ_TUTARI').Value := DovizTutar;
     TabSiparisDetay.FieldByName('DOVIZ_KURU').Value := DovizKur;
     TabSiparisDetay.FieldByName('TUTAR').Value :=((100-GridFaturaViewISKONTO1.EditValue)/100)*
                                      ((100-GridFaturaViewISKONTO2.EditValue)/100)*
                                      GridFaturaViewADET1.EditValue*
                                      GridFaturaViewBIRIMFIYAT1.EditValue;
     TabSiparisDetay.Post;
  end;}


end;

// SIPARIS baslik TabloID: satis(19)->92, digerleri(alis 9...)->91 (UFaturalar info ile ayni).
function TSiparisWizardDlg.SiparisLogTabNo: Integer;
begin
  if SiparisTur = 19 then Result := TabNo_SIPARIS_Giden
  else Result := TabNo_SIPARIS_Gelen;
end;

// Yuklemede baslik + detay snapshot (ULog).
procedure TSiparisWizardDlg.SiparisLogSnapshotAl;
begin
  LogSnapshotAl(TabSiparis, FBasSnap);
  LogSnapshotAl(TabSiparisDetay, FDetSnap);
end;

// Kaydette baslik (ust=kendisi) + detay (ust=baslik) diff loglama; sonra mukerrer
// save'i onlemek icin snapshot'i guncel duruma tazele. Kaydetmeyi ASLA bozmaz.
procedure TSiparisWizardDlg.SiparisLogKaydet;
var
  LTabNo, LID: Integer;
begin
  try
    if not (IslemOp in ['E','D','I','K']) then Exit;
    // Alt hareketler (SIPARISDETAY diff) ana kartin moduna gore -> tek ISLEMTIPI (UInfo tek satir).
    if (IslemOp='E') or (IslemOp='K') then LogUstModu := 1 else LogUstModu := 2;
    if (not Assigned(FBasSnap)) or (not TabSiparis.Active) then Exit;
    LTabNo := SiparisLogTabNo;
    LID := TabSiparis.FieldByName('ID').AsInteger;
    if LID <= 0 then Exit;
    // BASLIK: EDIT (D/I) zaten KaydetTusClick'teki LogIslemleri ile (TabSiparisBeforeEdit
    // -> OncekiLogBelirle) ISLEMLOG'a yaziliyor. Cift olmamasi icin burada yalnizca
    // YENI/kopya (E/K) icin baslik EKLEME logu (LogIslemleri E/K yapmaz).
    if IslemOp in ['E','K'] then
      LogDiffKaydet(TabSiparis, FBasSnap, LTabNo, LTabNo, LID);
    // DETAY: her zaman diff (SIPARISDETAY'i baska hicbir yer loglamiyor).
    LogDiffKaydet(TabSiparisDetay, FDetSnap, TabNo_SIPARISDETAY, LTabNo, LID);
    SiparisLogSnapshotAl;   // snapshot'i son duruma tazele
  except
  end;
end;

procedure TSiparisWizardDlg.KaydetTusClick(Sender: TObject);
begin
  if TabSiparis.State in [dsInsert, dsEdit] then begin
     TabSiparis.Post;
     if islemOp='D' then
        case SiparisTur of
          9  : LogKartDegisti(TabSiparis, TabNo_SIPARIS_Gelen, SiparisIdsi);
          19 : LogKartDegisti(TabSiparis, TabNo_SIPARIS_Giden, SiparisIdsi);
        end;
  end;
  Tablo.UserDataSourceKaydet(TSiparisWizardDlg(Self), 'SIPARIS_USER');
  // _USER (ek alan) audit: UserDataSourceKaydet _USER'i post ettikten SONRA logla (kart grubuna baglanir).
  if LogGun > 0 then
  begin
    var LSipTabNo: Integer := TabNo_SIPARIS_Gelen;
    if SiparisTur = 19 then LSipTabNo := TabNo_SIPARIS_Giden;
    ULog.LogUserKaydet('SIPARIS_USER', TabNo_SIPARIS_USER, LSipTabNo, SiparisIdsi, (IslemOp='E') or (IslemOp='K'));
  end;
  if TabSiparisDetay.State in [dsInsert, dsEdit] then
     TabSiparisDetay.Post;
  // NOT: eski LogIslemlerBelge(TabSiparisDetay) kaldirildi -> siparis detayi artik
  // yalniz SiparisLogKaydet (LogDiffKaydet, TabNo_SIPARISDETAY=93) ile loglanir (cift onlendi).
  if EkleDetay then
      Ekle(TabDetay, DetaySablonTipiBul ,SiparisIdsi,'Değiş');
  SiparisLogKaydet;   // ISLEMLOG: baslik + detay (degistir/ekle/sil)
end;

procedure TSiparisWizardDlg.KDVHaricTutargir1Click(Sender: TObject);
var Tutar,Kur : Variant;
    Yuzde,Deger : String;
    YuzdeFloat:extended;
    LST : Tstrings;
begin
   Kur := CariDoviz;
   LST := TstringList.Create;
   LST.Add(CariDoviz);
   LST.Add(cbDovizCinsi.Text);
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.create
        .CurrencyEdit(FWToplamTutariGir, @Tutar,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))
        .ComboBox(FWKurGir,@Kur, LST)) <> mrOk then begin
      LST.Destroy;
      Abort;
  end;
  LST.Destroy;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO=0.0, ISKONTO2=0.0, TUTAR=ADET*BIRIMFIYAT, DOVIZ_TUTARI=ADET*DOVIZ_BIRIMFIYAT where SIPARISID=&id ',['&id'],[TabSiparis.Fields[0].AsInteger]);
  TabloYenile(TabSiparisDetay,[TabSiparis.FieldByName('ID').AsInteger]);
  FaturaToplamUpdate(True);
  if TMenuItem(Sender).Tag = 0 then
     TOPLAMLAR.First
  else if TMenuItem(Sender).Tag = 1 then
     TOPLAMLAR.Last;

  if Kur = CariDoviz then
     Deger:='DEGER'
  else
     Deger:='DOVIZTUTARI';
  YuzdeFloat := 100.0 * StrToCurrDef(trim(Tutar),0)/TOPLAMLAR.FieldByName(Deger).AsExtended;

  Yuzde := FExtToStr(YuzdeFloat);
  if (not Eksiskontoya)and(YuzdeFloat>100.0) then///eksi iskonto izni yoksa engel oluruz
    showmessage(BGEksiIskontoGirilemez)
  else begin
    Yuzde := StringReplace(Yuzde, ',', '.', []);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SIPARISDETAY set ISKONTO=100.0-'+Yuzde+',ISKONTO2=0.0, TUTAR='+Yuzde+'*ADET*BIRIMFIYAT/100.0, DOVIZ_TUTARI='+Yuzde+'*ADET*DOVIZ_BIRIMFIYAT/100.0 where SIPARISID=&id ',['&id'],[TabSiparis.Fields[0].AsInteger]);
  end;
  FaturaToplamUpdate(True);
  TabSiparisDetay.Close;
  TabSiparisDetay.Open;
end;

Procedure TSiparisWizardDlg.SatinAlmainsert;
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
     TabloYenile(TabSiparis, [SiparisIdsi]);
     TabloYenile(TabSiparisDetay,[SiparisIdsi]);
    end;
  end;
end;

procedure TSiparisWizardDlg.TabSiparisNewRecord(DataSet: TDataSet);
var
  seri, FatNo : string;
  belgeno : TBelgeNo;
  Etiketler,Bilgiler : TArrayOfString;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
begin
  if SiparisTur = 19 then begin
    Tablo.FaturaBaslik(TabSiparis,RehberId);
    TabSiparis.FieldByName('CIKISDEPO').AsInteger := VarsDepo;
    /////İletişim
    Tablo.RehberIletisimAD(RehberId,REHBERILETID,REHBERILETAD,REHBERILETADHINT);
    TabSiparis.FieldByName('REHBERILETID').AsInteger := REHBERILETID ;
    btnSevkAdresi.Text := REHBERILETAD;
    btnSevkAdresi.Hint := REHBERILETADHINT;
    /////İletişim
   end else begin
    Tablo.FaturaBaslik(TabSiparis,-1);
    TabSiparis.FieldByName('REHBERILETID').AsInteger :=0;
    TabSiparis.FieldByName('GIRISDEPO').AsInteger:= VarsDepo
  end;
  TabSiparis.FieldByName('SATICIKODU').AsString:=Kullanan;
//  cbSatici.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabSiparis.FieldByName('SATICIKODU').AsString);

  TabSiparis.FieldByName('SIPARISTARIH').Value := Tablo.GENINI.BugunTrhSaat;
  belgeno:= SiradakiBelgeNumarasi(SiparisTur,TabSiparis.FieldByName('SIPARISTARIH').AsDateTime);
  TabSiparis.FieldByName('SIPARISSERI').AsString := belgeno.serino; //seri
  TabSiparis.FieldByName('SIPARISNO').AsString := belgeno.belgeno; //FatNo;
  TabSiparis.FieldByName('KOCANNO').AsInteger := KocannoBul(SiparisTur); //KOCAN numarası
  TabSiparis.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrh;
  TabSiparis.FieldByName('REHBERID').AsInteger := RehberId;
  TabSiparis.FieldByName('SUBEID').AsInteger := SubeID;
  //TabSiparis.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  TabSiparis.FieldByName('SERVISID').AsInteger := ServisID;


  //varsayılan iskonto bilgilerine bakalım...
  if SiparisTur in [0, 9, 10, 11, 12] then begin
    Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_FiyatListeAdiAlis, RehVars_Stok_Vade, RehVars_GLN],etiketler,bilgiler);
    if bilgiler[0]='' then
      TabSiparis.FieldByName('FIYAT_LISTESI').AsInteger := VarsAlisFiyatID
    else
      TabSiparis.FieldByName('FIYAT_LISTESI').AsInteger := Tablo.GENINI.DegerGetir(Ops_FiyatListeAdiAlis,Dil,bilgiler[0],VarsAlisFiyatID);
  end else begin
    Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_FiyatListeAdi, RehVars_Stok_Vade, RehVars_GLN],etiketler,bilgiler);
    if bilgiler[0]='' then
      TabSiparis.FieldByName('FIYAT_LISTESI').AsInteger := VarsSatisFiyatID
    else
      TabSiparis.FieldByName('FIYAT_LISTESI').AsInteger := Tablo.GENINI.DegerGetir(Ops_FiyatListeAdi,Dil,bilgiler[0],VarsSatisFiyatID);
  end;


  if bilgiler[1]<>'' then
     TabSiparis.FieldByName('VADE').Value := bilgiler[1];

  if MasrafMerkezi>0 then
     TabSiparis.FieldByName('MASRAFID').AsInteger := MasrafMerkezi
  else begin
    if SiparisTur = 19 then begin //Çıkış
       Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_Gelir_Merkezi ],Etiketler,Bilgiler);
    end else begin
       Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_Masraf_Merkezi],Etiketler,Bilgiler);
    end;
    if Bilgiler[0]<>'' then begin
       Tablo.TablodanSorguAc(5,'select ID from MASRAFGELIR where KOD=substring('''+Bilgiler[0]+''',0,(charindex('' '','''+Bilgiler[0]+''',0)))');
       TabSiparis.FieldByName('MASRAFID').AsInteger := Tablo.Query5.Fields[0].AsInteger;
    end;
  end;
  if TabSiparis.FieldByName('MASRAFID').AsString <>'' then
     EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabSiparis.FieldByName('MASRAFID').AsInteger);
  TabSiparis.FieldByName('TUR').AsInteger := SiparisTur;
  TabSiparis.FieldByName('TIPI').AsInteger := 1;
  TabSiparis.FieldByName('DURUM').AsInteger := 0;
  TabSiparis.FieldByName('PROJEID').AsInteger := ProjeId;
  TabSiparis.FieldByName('AKTIVITEID').AsInteger := AktiviteId;
  //TabSiparis.FieldByName('ACIKLAMA').AsString := '';
  TabSiparis.FieldByName('EKLEYEN').AsString := Kullanan;
  TabSiparis.FieldByName('KDVDURUM').AsString := 'Hariç';
  TabSiparis.FieldByName('KUR').AsString := CariDoviz;
  TabSiparis.FieldByName('RAPORDOVIZ').AsString := CariDoviz;
  TabSiparis.edit;
  TabSiparis.FieldByName('DOVIZ_CINSI').AsString := CariDoviz;
  TabSiparis.FieldByName('DOVIZ_TUTARI').AsCurrency := 0;
  TabSiparis.FieldByName('DOVIZKUR').AsCurrency:= 1;
end;
procedure TSiparisWizardDlg.SiparisEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   TabSiparisDetayAfterScroll(TabSiparisDetay);
end;

procedure TSiparisWizardDlg.SiparisEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  Stop := BoslukKontrolu;
end;

procedure TSiparisWizardDlg.SiparisEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TSiparisWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   // Iptal onayi FormCloseQuery'de (KaydetmeSorusu / Gentegre Onay) soruluyor -> burada
   // TEKRAR sorMA (cift onay kaldirildi). Close -> FormCloseQuery -> KaydetmeSorusu.
   Close;
end;

procedure TSiparisWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
  Kota,Bakiye:currency;
  tur, tabno : integer;
begin
  KaydetTus.Click;
  //Birim Onaylayacak de?i?ti ise onay için duyuru yay?nlan?r/de?i?tirilir/silinir
  if OncekiOnaylayacak <> TabSiparis.FieldByName('ONAYLAYACAK').AsInteger then begin
     if SiparisTur = 9 then begin
        tur := -32;
        tabno := TabNo_SIPARIS_Gelen
     end else begin
        tur := -34;
        tabno := TabNo_SIPARIS_Giden;
     end;
     Tablo.OnayYayinIslemleri('SIPARIS', tabno, TabSiparis.FieldByName('ID').AsInteger, OncekiOnaylayacak, TabSiparis.FieldByName('ONAYLAYACAK').AsInteger, tur);
  end;

  if SiparisTur = 19 then begin
     Kota := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select TUTAR=isnull((select '+DbUst(1)+'TUTAR from REHBER_KOTA where REHBERID=:PRehberID and KUR=:PKur '+DbSinir(1)+'),0.0)',[':PRehberID',':PKur'],[TabSiparis.FieldByName('REHBERID').AsInteger,CariDoviz],True);
     if Kota>0.0 then begin
        Bakiye := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select TUTAR=isnull((select TUTAR=sum(DOVIZ_TUTARI) from REHBER_BAKIYE where REHBERID=:PRehberID),0.0)',[':PRehberID'],[TabSiparis.FieldByName('REHBERID').AsInteger],True);
        if Kota<(Bakiye+TabSiparis.FieldByName('SIPARIS_TUTARI').AsCurrency) then
           Tablo.UyariGoster(Uyari,'Firma Risk Limiti   :'+Format('%m',[Kota])+CariDoviz+#13#10+'Firma Bakiyesi:'+Format('%m',[Bakiye])+CariDoviz+#13#10+
                                '"Risk Limiti" aşımı. Lütfen "Risk Limiti" bilgilerini güncelleyin.',1)
     end;
  end;


  if TabSiparisDetay.RecordCount < 1 then
     raise Exception.Create(UrungirilmedenKaydedilemez);
  //kilitli zamana kay?t olur mu
  if not KilitKontrolEt(1,SiparisTur,EditFatTarih.Date,1) then begin
     IptalSecildi := False;
     ModalResult := mrOk;
  end;
end;

function TSiparisWizardDlg.BoslukKontrolu: Boolean;
var i:Integer;
    s:string[20];
begin
  BoslukKontrolu := True;
  if not BoslukKontrol(cbStokDepo.Text, Belge+ ' '+Depo) then
    Abort;
  if not BoslukKontrol(ComboFIYAT_LISTESI.Text,Belge+ ' '+ KontrolFiyatListeAdi) then
    Abort;
  if not BoslukKontrol(EditBASLIK.Text, Belge+' Başlık') then
    Abort;
  if not BoslukKontrol(EditFatTarih.Text, Belge+' Tarih') then
    Abort;
  if not TarihKontrol(EditFatTarih.Date, Belge + KontrolTarihi) then
     Abort;
  if not BoslukKontrol(EditFatNo.Text, Belge+' No') then
    Abort;

  EditFatNo.Text := trim(EditFatNo.Text);


{  if (YeniYilDevriVar)and(YearOf(Tablo.GENINI.BugunTrh) <> YearOf(TabSiparis.FieldByName('SIPARISTARIH').AsDateTime)) then begin
      Application.MessageBox(Pchar(FWKayitBelgeYilindanFarkliOlamaz),pchar(Uyari),MB_OK);
      Abort;
  end else if Dateof(TabSiparis.FieldByName('SIPARISTARIH').AsDateTime) > Tablo.GENINI.BugunTrh then begin
    Application.MessageBox(Pchar(FWKayitveBelgeTarihiIleriTarihOlamaz),pchar(Uyari),MB_OK);
    Abort;
  end; }

  if SiparisTur in [14, 15, 16] then begin
     i := StrToIntdef(EditFatNo.Text, 0);
     if i=0 then begin
        ShowMessage(Yanlis_karakter);
        Abort;
     end;
     if TabSiparis.Fields[0].AsString<>'' then
       s := ' and ID <> '+TabSiparis.Fields[0].AsString
     else
       s:='';
     Tablo.TablodanSorguAc(1, ' select TARIH from SIPARIS where SIPARISSERI='''+TabSiparis.FieldByName('SIPARISSERI').AsString+''' and SIPARISNO ='''+TabSiparis.FieldByName('SIPARISNO').AsString+''' '+s);
     if Tablo.Query1.RecordCount > 0 then begin
        ShowMessage(Tablo.Query1.Fields[0].AsString + Yanlis_numara);
        Abort;
     end;
  end;
  BoslukKontrolu := False;
end;

procedure TSiparisWizardDlg.BtnDonusturClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
begin
  if TabSiparis.State in [dsEdit, dsInsert] then
     TabSiparis.Post;

  if TabSiparisDetay.State in [dsEdit, dsInsert] then
     TabSiparisDetay.Post;

  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.HedefBaslikTur := TabSiparis.FieldByName('TUR').AsInteger;
  BDDlg.RehID := TabSiparis.FieldByName('REHBERID').AsInteger;
  BDDlg.HedefBaslikID := TabSiparis.FieldByName('ID').AsInteger;
  BDDlg.TabKaynakBaslik := TabSiparis;
  BDDlg.TabDetayGiris := TabSiparisDetay;
  BDDlg.ShowModal;
  FreeAndNil(BDDlg);
  TabSiparis.Edit;
  if not TabSiparisDetay.IsEmpty then
    cbDovizCinsiPropertiesCloseUp(Sender);
end;

procedure TSiparisWizardDlg.BtnDovizKuruClick(Sender: TObject);
begin
  Tablo.DovizDegistir(TabSiparis, TabSiparisDetay, 'RAPORDOVIZ', 'SIPARISTARIH', 'SIPARISDETAY', 'SIPARISID');
end;

procedure TSiparisWizardDlg.btnFisIrsaliyeClick(Sender: TObject);
begin
   // fi? d?zenlerken bu ekran kullan?lmaz
  KaydetTus.Click;
  if TabSiparis.FieldByName('TUR').AsInteger in [12 ,16] then
   begin
     Application.MessageBox(PChar(Yanlis_Ekran),PCHAR(Uyari) , MB_OK+ MB_ICONWARNING) ;
     Abort;
   end;
  if FisIrsaliyeAraDlg = nil then
    Application.CreateForm(TFisIrsaliyeAraDlg, FisIrsaliyeAraDlg);

  FisIrsFirmaId := TabSiparis.FieldByName('REHBERID').AsInteger;
  FisIrsTur := TabSiparis.FieldByName('TUR').AsInteger;
  SeciliFatID := TabSiparis.FieldByName('ID').AsInteger;
  SeciliFatIrsNo:= TabSiparis.FieldByName('IRSALIYENO').AsString;
//  FisIrsaliyeAraDlg.dateBitisPropertiesCloseUp(FisIrsaliyeAraDlg.dateBitis);

  FisIrsaliyeAraDlg.ShowModal;

  TabSiparis.Refresh;
  FaturaToplamUpdate(True);
  TabloYenile(TabSiparisDetay, [TabSiparis.FieldByName('ID').AsInteger]);

end;

procedure TSiparisWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya mesaj/dosya ekleme -> yakala
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabloNo, TabSiparis.FieldByName('ID').AsInteger, TabSiparis.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TSiparisWizardDlg.BtnMesajGonderDetayClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoDetayChat, labelDetayFileName, TabNo_SIPARISDETAY, TabSiparisDetay.FieldByName('ID').AsInteger, TabSiparis.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TSiparisWizardDlg.btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  SQLText:String;
  st:TStringList;
begin
  if Not (TabSiparis.State in [dsEdit,dsInsert]) then
    TabSiparis.Edit;
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
       TabSiparis.FieldByName('REHBERILETID').AsString := st.Strings[0];
       btnSevkAdresi.Text := st.Strings[1];
      end;
    finally
      st.free;
    end;
  end else if AButtonIndex=1 then begin
        TabSiparis.FieldByName('REHBERILETID').AsInteger := 0;
        btnSevkAdresi.Text := '';
  end;
end;


procedure TSiparisWizardDlg.IletisimEkleClick(Sender: TObject);
var
  Id : integer;
  Ad : string;
begin
  Tablo.IletisimEkle(RehberId, Id, Ad);
  TabSiparis.FieldByName('REHBERILETID').AsInteger := Id;
  btnSevkAdresi.Text := Ad;
end;

procedure TSiparisWizardDlg.cbDovizCinsiPropertiesCloseUp(Sender: TObject);
var KurDegeri : real;
begin
   if (TabSiparis.State in [dsEdit, dsInsert])and(TabSiparis.FieldByName('ID').AsString<>'')  then begin
       if cbDovizCinsi.EditValue = CariDoviz then
          KurDegeri := 1
       else
          KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TabSiparis.FieldByName('SIPARISTARIH').AsDateTime), cbDovizCinsi.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
       TabSiparis.FieldByName('DOVIZKUR').AsFloat := KurDegeri;
       TabSiparis.Post;
       FaturaToplamUpdate(True)
   end;
   editDovizKuru.Visible:= cbDovizCinsi.EditValue <> CariDoviz;
end;

procedure TSiparisWizardDlg.cbKdvDurumPropertiesCloseUp(Sender: TObject);
var s : string[1];
begin
   if (TabSiparis.Fields[0].AsString<>'')and(OncekiKDVDurumu <> cbKdvDurum.Text) then begin
      Tablo.Query1.Close;
      if OncekiKDVDurumu = 'Hariç' then
         s:='*'
      else
         s:= '/';
      Tablo.Query1.SQL.Text:=' Update SIPARISDETAY set BIRIMFIYAT=BIRIMFIYAT'+s+'((100.0+KDV)/100.0), TUTAR = (100.0 - ISKONTO) * ADET * (BIRIMFIYAT'+s+'((100.0+KDV)/100.0)) / 100 Where SIPARISID='+TabSiparis.Fields[0].AsString;
      Tablo.Query1.ExecSQL;
      TabSiparisDetay.Close;
      TabSiparisDetay.Open;
      FaturaToplamUpdate(True);
   end;
end;

procedure TSiparisWizardDlg.cbSaticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,TabSiparis,'SATICIKODU');
end;

procedure TSiparisWizardDlg.ComboBolumPropertiesEditValueChanged(
  Sender: TObject);

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
      TabSiparis.Cancel
    end else begin
      if TabSiparis.state in [dsEdit, dsInsert] then
         TabSiparis.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[DetaySablonTipiBul,TabSiparis.FieldByName('ID').AsInteger]);
      DetayEkrPage(Self);
    end;
  end;
end;

procedure TSiparisWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
var
 sablontipi : integer;
begin
  sablontipi:= DetaySablonTipiBul;
  if ComboBolum.Properties.Items.Count=0 then
    ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE  YERI = '+IntToStr(sablontipi)).Items;

end;

procedure TSiparisWizardDlg.ComboFIYAT_LISTESIPropertiesCloseUp(Sender: TObject);
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
   if not Active then exit;//ekran henüz açılmadıysa çıksın
   if (not TabSiparisDetay.IsEmpty)and(Application.MessageBox(PCHAR(Yeniden_duzenleme), PChar(SGenotipOnay), MB_YESNO) = IDYES) then begin
         if SiparisTur in [0,9, 10, 11, 12] then
            Satis:=0
         else
            Satis:=1;
      DovizliFiyatVar := False;
      TabSiparisDetay.first;
      while not TabSiparisDetay.eof do begin
         TabSiparisDetay.edit;
         FiyatGetir(TabSiparisDetay.FieldByName('URUNID').AsInteger, ComboFIYAT_LISTESI.EditingValue, TabSiparisDetay.FieldByName('BIRIM').AsInteger,Satis,Fiyat,DovizCinsi);
         if DovizCinsi=CariDoviz then
             TabSiparisDetay.FieldByName('DOVIZKURDEGERI').AsCurrency := 1.0
         else
             DovizliFiyatVar := True;
         TabSiparisDetay.FieldByName('DOVIZ_KURU').Asstring := DovizCinsi;
         TabSiparisDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency := Fiyat;
         TabSiparisDetay.post;
         TabSiparisDetay.next;
      end;
      if DovizliFiyatVar then
         BtnDovizKuru.Click;
   end;
end;

procedure TSiparisWizardDlg.ComboRaporDoviziPropertiesEditValueChanged(Sender: TObject);
var KurDegeri : real;
begin
   if (TabSiparis.State in [dsEdit, dsInsert])and(TabSiparis.FieldByName('ID').AsString<>'')  then begin
       if ComboRaporDovizi.EditValue = CariDoviz then
          KurDegeri := 1
       else
          KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TabSiparis.FieldByName('TARIH').AsDateTime),
                                    ComboRaporDovizi.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
       TabSiparis.FieldByName('DOVIZKUR').AsFloat := KurDegeri;
       if (TabSiparis.FieldByName('DOVIZ_CINSI').AsString<>TabSiparis.FieldByName('RAPORDOVIZ').AsString)
          and(TabSiparis.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz)then
          TabSiparis.FieldByName('DOVIZ_CINSI').AsString:=CariDoviz;
       TabSiparis.Post;
       //TabloYenile(TOPLAMLAR,[TabSiparis.FieldByName('ID').AsInteger]);
       FaturaToplamUpdate(True);
   end;
   editDovizKuru.Visible:= ComboRaporDovizi.EditValue <> CariDoviz;
end;

procedure TSiparisWizardDlg.cxEditRepository1ButtonItem1PropertiesButtonClick(
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

procedure TSiparisWizardDlg.cxGridDBColumn4GetPropertiesForEdit( Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TSiparisWizardDlg.cxLabel16Click(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_FaturaOpsiyon_Poliklinik);
end;

procedure TSiparisWizardDlg.cxLabel19Click(Sender: TObject);
begin
  tablo.GeniniBaslat(Ops_FaturaOpsiyon_Referans);
end;

procedure TSiparisWizardDlg.EditEkVergiKeyUp(Sender: TObject;  var Key: Word; Shift: TShiftState);
begin
  TabSiparis.edit;
  TabSiparis.FieldByName('SIPARIS_TUTARI').AsCurrency := TabSiparis.FieldByName('SIPARIS_MATRAHI').AsCurrency+EditEkVergi.Value;
  if cbKdvDurum.Text = 'Hariç' then
     TabSiparis.FieldByName('SIPARIS_TUTARI').AsCurrency := TabSiparis.FieldByName('SIPARIS_TUTARI').AsCurrency+TabSiparis.FieldByName('KDV_TUTARI').AsCurrency  ;
end;

procedure TSiparisWizardDlg.EditMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
 if AButtonIndex = 0 then begin
   if SiparisTur in [14..19] then
      i := 1
   else
      i := 0;
   if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      TabSiparis.Edit;
      TabSiparis.FieldByName('MASRAFID').AsString := MASRAFID;
      EditMM.Text := MASRAFMERKEZI;
   end
 end else if AButtonIndex = 1  then begin
      TabSiparis.Edit;
      TabSiparis.FieldByName('MASRAFID').AsInteger := 0;
      EditMM.Text := '';
 end;
end;

procedure TSiparisWizardDlg.EditOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var RehID, TabNo : Integer;
    s:string[10];
begin
  if Assigned(Sender) then begin
    if SiparisTur=9 then begin //alış belgesi
      RehID := Tablo.KullaniciAdiSifreSor(StringReplace(OnayYetki, '@YetkiKodu', '24011150', []), TabSiparis.FieldByName('ONAYLAYACAK').AsString);
      TabNo := TabNo_SIPARIS_Gelen;
    end else begin//satış belgesi
      RehID := Tablo.KullaniciAdiSifreSor(StringReplace(OnayYetki, '@YetkiKodu', '24111152', []), TabSiparis.FieldByName('ONAYLAYACAK').AsString);
      TabNo := TabNo_SIPARIS_Giden;
    end;
    if RehID  = 0 then
      Abort;
  end;
  TabSiparis.Edit;
  if AButtonIndex = 0 then begin
    TabSiparis.FieldByName('ONAYLAYAN').AsInteger := RehID;
    TabSiparis.FieldByName('ONAYTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    EditOnaylayan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID);
    s :='getdate()';
  end else if AButtonIndex=1 then begin
      TabSiparis.FieldByName('ONAYLAYAN').AsInteger := 0;
      EditOnaylayan.Text := '';
      s:= 'null ';
  end;
  TabSiparis.Post;
  // okundu işaretleyelim ki panodaki listeden silinsin
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI='+s+' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Tabno)+' and YER_ID='+TabSiparis.FieldByName('ID').AsString+')',[],[]);
end;

procedure TSiparisWizardDlg.FaturaTusClick(Sender: TObject);
begin
  WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;
end;

procedure TSiparisWizardDlg.ButtonDuzenle;
begin
  FaturaTus.Enabled := FaturaTus.tag <> WizardKontrol.ActivePageIndex;
  DetayTus.Enabled := DetayTus.tag <> WizardKontrol.ActivePageIndex;
  DokumanTus.Enabled := DokumanTus.tag <> WizardKontrol.ActivePageIndex;
end;

procedure TSiparisWizardDlg.TabSiparisAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TOPLAMLAR,[TabSiparis.FieldByName('ID').AsInteger]);
end;

end.






































































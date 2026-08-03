unit UTeklifWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore,  cxGraphics, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,ShellApi,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxCurrencyEdit, cxTL,
  cxLabel, cxButtonEdit,  cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard, cxStyles,
  cxGridLevel, cxGridCustomTableView, cxGridTableView,  cxGridDBTableView, cxRichEdit,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, cxPivotGrid,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons,ComObj,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, cxPC, cxCheckBox, UGentegreFrameYonetimi,
  dxSkinLondonLiquidSky, Utablo, UStokHizmetAra,Math, cxGroupBox, cxTLdxBarBuiltInMenu,
  cxInplaceContainer, cxDBTL, cxTLData,UKodAgaci, JvComponentBase, JvDragDrop, cxHyperLinkEdit,
  cxGridCardView, cxGridDBCardView, dxSkinLiquidSky, cxDBRichEdit, cxCustomPivotGrid,
  cxLookAndFeels, cxPCdxBarPopupMenu, cxNavigator, cxGridCustomLayoutView, cxSplitter,
  dxBarBuiltInMenu, cxGridCustomPopupMenu, cxGridPopupMenu, OfficePopupMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxScrollbarAnnotations, dxDateRanges,
  dxCoreGraphics, frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Generics.Collections;

type
  TTeklifWizardDlg = class(TForm, IPopupDialog)
    PanelSol: TPanel;
    WizardKontrol: TJvWizard;
    TeklifEkr: TJvWizardInteriorPage;
    DokumanEkr: TJvWizardInteriorPage;
    TarihceEkr: TJvWizardInteriorPage;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    SQLTemel: TcxMemo;
    cxImageComboBox1: TcxImageComboBox;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    PopupMenuFatura: TPopupMenu;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    TabTeklifDetay: TFDQuery;
    DtsTeklifDetay: TDataSource;
    TabTeklif: TFDQuery;
    DtsTeklif: TDataSource;
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
    PageControlUst: TcxPageControl;
    TabSheetDetay: TcxTabSheet;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    cxDBLabel5: TcxDBLabel;
    TabSheetMetinler: TcxTabSheet;
    PopupMenuKopya: TPopupMenu;
    BuMusteriyeKopyala: TMenuItem;
    BaskaMusteriyeKopyala: TMenuItem;
    TabTeklifDetayYaz: TFDQuery;
    TabTeklifYaz: TFDQuery;
    Panel4: TPanel;
    PanelDetay: TPanel;
    GridTeklif: TcxGrid;
    GridTeklifWizardDetayView: TcxGridDBTableView;
    GridTeklifWizardDetayViewKOD1: TcxGridDBColumn;
    GridTeklifWizardDetayViewAD: TcxGridDBColumn;
    GridTeklifWizardDetayViewACIKLAMA1: TcxGridDBColumn;
    GridTeklifWizardDetayViewADET1: TcxGridDBColumn;
    GridTeklifWizardDetayViewBIRIM1: TcxGridDBColumn;
    GridTeklifWizardDetayViewBIRIMFIYAT1: TcxGridDBColumn;
    GridTeklifWizardDetayViewISKONTO1: TcxGridDBColumn;
    GridTeklifWizardDetayViewKDV1: TcxGridDBColumn;
    GridTeklifWizardDetayViewTUTAR1: TcxGridDBColumn;
    GridTeklifWizardDetayViewKUR: TcxGridDBColumn;
    GridTeklifWizardDetayViewDOVIZ_TUTARI: TcxGridDBColumn;
    GridTeklifWizardDetayViewDOVIZ_KURU: TcxGridDBColumn;
    GridTeklifWizardDetayViewISKONTO2: TcxGridDBColumn;
    GridTeklifLevel1: TcxGridLevel;
    ToolBar5: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    ToolButton4: TToolButton;
    ToolButton7: TToolButton;
    ToolButton13: TToolButton;
    AlternatifTus: TToolButton;
    ToolButton3: TToolButton;
    TamEkranTus: TToolButton;
    PanelAlt: TPanel;
    GridFaturaToplam: TStringGrid;
    Label1: TLabel;
    cxDBLabel2: TcxDBLabel;
    lblMusteriTel: TcxLabel;
    lblMusteriEposta: TcxLabel;
    lblMusteriAdres: TcxLabel;
    MiktarskontosuGir1: TMenuItem;
    e1: TMenuItem;
    KDVHariTutarGir1: TMenuItem;
    KDVHariTutarGir2: TMenuItem;
    skonto1: TMenuItem;
    skonto21: TMenuItem;
    N51: TMenuItem;
    N52: TMenuItem;
    N101: TMenuItem;
    N151: TMenuItem;
    N201: TMenuItem;
    N251: TMenuItem;
    N301: TMenuItem;
    N401: TMenuItem;
    N501: TMenuItem;
    N1001: TMenuItem;
    zel1: TMenuItem;
    N01: TMenuItem;
    N53: TMenuItem;
    N102: TMenuItem;
    N152: TMenuItem;
    N202: TMenuItem;
    N252: TMenuItem;
    N302: TMenuItem;
    N402: TMenuItem;
    N502: TMenuItem;
    N1002: TMenuItem;
    zel2: TMenuItem;
    DtsTeklifHareket: TDataSource;
    TabTeklifHareket: TFDQuery;
    cxGridTarihce: TcxGrid;
    cxGridTarihceDBTableView1: TcxGridDBTableView;
    cxGridTarihceLevel1: TcxGridLevel;
    TabGecmisTeklifler: TFDQuery;
    DtsGecmisTeklifler: TDataSource;
    TreeListGecmisTeklifler: TcxDBTreeList;
    TreeTARIH: TcxDBTreeListColumn;
    TreeDURUM: TcxDBTreeListColumn;
    JvDragDrop1: TJvDragDrop;
    GridTeklifWizardDetayViewTESLIMTARIHI: TcxGridDBColumn;
    GridTeklifWizardDetayViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn;
    TabStokDetay: TFDQuery;
    frxStokDetay: TfrxDBDataset;
    TabTeklifDetayResimli: TFDQuery;
    frxTeklifDetayResimli: TfrxDBDataset;
    cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridTarihceDBTableView1ESKIDURUM: TcxGridDBColumn;
    cxGridTarihceDBTableView1YENIDURUM: TcxGridDBColumn;
    cxGridTarihceDBTableView1EKLEMETARIHI: TcxGridDBColumn;
    cxGridTarihceDBTableView1FIRMA: TcxGridDBColumn;
    GridTeklifWizardDetayViewPROJEKODU: TcxGridDBColumn;
    GridTeklifWizardDetayViewTUR: TcxGridDBColumn;
    TOPLAMLAR: TFDQuery;
    dtsTOPLAMLAR: TDataSource;
    frxTOPLAMLAR: TfrxDBDataset;
    frxTEKLIFDETAY: TfrxDBDataset;
    frxTEKLIF: TfrxDBDataset;
    TabTeklifDetayYazID: TIntegerField;
    TabTeklifDetayYazTEKLIFID: TIntegerField;
    TabTeklifDetayYazALTERNATIFNO: TWordField;
    TabTeklifDetayYazREHBERID: TIntegerField;
    TabTeklifDetayYazSIRALAMA: TSmallintField;
    TabTeklifDetayYazURUNID: TIntegerField;
    TabTeklifDetayYazTUR: TSmallintField;
    TabTeklifDetayYazADET: TFMTBCDField;
    TabTeklifDetayYazBIRIM: TWideStringField;
    TabTeklifDetayYazMIKTAR: TFMTBCDField;
    TabTeklifDetayYazBIRIMFIYAT: TFMTBCDField;
    TabTeklifDetayYazISKONTO: TFloatField;
    TabTeklifDetayYazKDV: TSmallintField;
    TabTeklifDetayYazTUTAR: TFMTBCDField;
    TabTeklifDetayYazMALIYET: TCurrencyField;
    TabTeklifDetayYazKUR: TWideStringField;
    TabTeklifDetayYazKAR_YUZDE: TFloatField;
    TabTeklifDetayYazOZELKOD: TWideStringField;
    TabTeklifDetayYazMUHKODU: TWideStringField;
    TabTeklifDetayYazKASA: TSmallintField;
    TabTeklifDetayYazEKLEYEN: TSmallintField;
    TabTeklifDetayYazEKLEMETARIHI: TSQLTimeStampField;
    TabTeklifDetayYazDEGISTIREN: TSmallintField;
    TabTeklifDetayYazDEGISTIRMETARIHI: TSQLTimeStampField;
    TabTeklifDetayYazDOVIZ_TUTARI: TFMTBCDField;
    TabTeklifDetayYazDOVIZ_KURU: TWideStringField;
    TabTeklifDetayYazISKONTO2: TFloatField;
    TabTeklifDetayYazYERI: TIntegerField;
    TabTeklifDetayYazYERID: TIntegerField;
    TabTeklifDetayYazTESLIMTARIHI: TSQLTimeStampField;
    TabTeklifDetayYazDOVIZ_BIRIMFIYAT: TFMTBCDField;
    TabTeklifDetayYazKAMPANYAID: TIntegerField;
    TabTeklifDetayYazVADE: TWordField;
    TabTeklifDetayYazSUBEID: TSmallintField;
    TabTeklifDetayYazSIPBIRIMFIYAT: TCurrencyField;
    TabTeklifDetayYazSIPTUTAR: TCurrencyField;
    TabTeklifDetayYazMASRAFID: TSmallintField;
    TabTeklifDetayYazPROJEID: TIntegerField;
    TabTeklifDetayYazDOVIZKURDEGERI: TCurrencyField;
    TabTeklifDetayYazKOD: TWideStringField;
    TabTeklifDetayYazAD: TWideStringField;
    TabTeklifDetayYazBIRIMAD: TWideStringField;
    TabTeklifDetayYazMARKA_AD: TWideStringField;
    TabTeklifDetayYazMODEL_AD: TWideStringField;
    TabTeklifDetayYazSTOK_NOTLAR: TWideStringField;
    TabTeklifDetayYazRESIM: TBlobField;
    GridTeklifWizardDetayViewRESIMGOSTER: TcxGridDBColumn;
    TabTeklifDetayYazGRUBU: TStringField;
    TabTeklifDetayYazALTERNATIF: TStringField;
    TabHazirlayanDetay: TFDQuery;
    frxHazirlayanDetay: TfrxDBDataset;
    GridTeklifWizardDetayViewSIRALAMA: TcxGridDBColumn;
    Panel2: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel6: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel5: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    PMMetinler: TPopupMenu;
    PmSablon: TMenuItem;
    MemoUstbilgi1: TcxDBRichEdit;
    MemoUstBilgi2: TcxDBRichEdit;
    MemoAltBilgi1: TcxDBRichEdit;
    MemoAltBilgi2: TcxDBRichEdit;
    GridTeklifWizardDetayViewOZELKOD: TcxGridDBColumn;
    GridTeklifWizardDetayViewMUHKODU: TcxGridDBColumn;
    SheetOnaylar: TcxTabSheet;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    TabTeklifOnay: TFDQuery;
    DtsTeklifOnay: TDataSource;
    cxGridDBTableView1ROL: TcxGridDBColumn;
    cxGridDBTableView1KULLANICI: TcxGridDBColumn;
    cxGridDBTableView1ONAY: TcxGridDBColumn;
    cxGridDBTableView1ONAYTARIHI: TcxGridDBColumn;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    ToolBar4: TToolBar;
    ToolButton1: TToolButton;
    ToolButton6: TToolButton;
    GridTeklifWizardDetayViewSTOKDURUM: TcxGridDBColumn;
    GridTeklifWizardDetayViewEKIPMAN: TcxGridDBColumn;
    GridTeklifWizardDetayViewSERINO: TcxGridDBColumn;
    TabTeklifDetayYazEKIPMANID: TIntegerField;
    TabTeklifDetayYazEKIPMANSERINO: TWideStringField;
    TabTeklifDetayYazEKIPMANAD: TWideStringField;
    TabTeklifDetayYazSTOKDURUM: TFMTBCDField;
    PageControlAlt: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    PanelUst: TPanel;
    cxDBLabel7: TcxDBLabel;
    cxGroupBox1: TcxGroupBox;
    cxLabel1: TcxLabel;
    ComboIlgili: TcxButtonEdit;
    ComboHazirlayan: TcxButtonEdit;
    cxLabel2: TcxLabel;
    LabelKonusu: TcxLabel;
    ComboKONU: TcxDBComboBox;
    ComboTURU: TcxDBImageComboBox;
    LabelTURU: TcxLabel;
    cxGroupBox2: TcxGroupBox;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    cxLabel12: TcxLabel;
    cxLabel13: TcxLabel;
    cxLabel14: TcxLabel;
    SpinTESLIM_SURESI: TcxDBSpinEdit;
    SpinGECERLILIK_SURESI: TcxDBSpinEdit;
    ComboTeslimSekli: TcxDBImageComboBox;
    ComboODEME: TcxDBImageComboBox;
    SpinOLASILIK: TcxDBSpinEdit;
    cxGroupBox3: TcxGroupBox;
    LabelFatNo: TcxLabel;
    EditTeklifNo: TcxDBTextEdit;
    cxLabel3: TcxLabel;
    DateTEKLIFTARIHI: TcxDBDateEdit;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    cxLabel16: TcxLabel;
    EditTeklifSeri: TcxDBTextEdit;
    cxLabel20: TcxLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    TabSheetEkAlanlar: TcxTabSheet;
    ToolBar3: TToolBar;
    btnKaydetTus: TToolButton;
    ToolButton9: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton8: TToolButton;
    KopyalaTus: TToolButton;
    ToolButton12: TToolButton;
    RevizeTus: TToolButton;
    ToolButton10: TToolButton;
    Oncetus: TToolButton;
    SonraTus: TToolButton;
    TabTeklifDetayYazDONUSENMIKTAR: TFMTBCDField;
    BtnYenile: TToolButton;
    GridTeklifWizardDetayViewISKONTOLUBRMFIYAT: TcxGridDBColumn;
    GridTeklifWizardDetayViewKDVDAHILFIYAT: TcxGridDBColumn;
    GridTeklifWizardDetayViewSTOKMALIYET: TcxGridDBColumn;
    TabTeklifDetayYazSEC: TBooleanField;
    TabTeklifDetayYazONAY: TBooleanField;
    TabTeklifDetayYazRESIMGOSTER: TBooleanField;
    TabTeklifDetayYazTEKLIFONAY: TWordField;
    TabTeklifDetayYazIZLEME: TSmallintField;
    TabTeklifDetayYazMERKEZID: TIntegerField;
    TabTeklifDetayYazISKONTOLUBRMFIYAT: TFMTBCDField;
    TabTeklifDetayYazKDVDAHILFIYAT: TFMTBCDField;
    TabTeklifDetayYazMF: TFMTBCDField;
    TabTeklifDetayYazACIKLAMA: TWideMemoField;
    cxSplitter1: TcxSplitter;
    PanelSolUst: TPanel;
    btnAktiviteler: TcxButton;
    btnDokuman: TcxButton;
    btnTeklif: TcxButton;
    cxLabel15: TcxLabel;
    cxGroupBox4: TcxGroupBox;
    cxLabel23: TcxLabel;
    comboTeklifSonuc: TcxDBImageComboBox;
    ComboSEBEBI: TcxDBImageComboBox;
    cxLabel24: TcxLabel;
    cxLabel25: TcxLabel;
    cxDBCurrencyEdit1: TcxDBCurrencyEdit;
    ComboKAYIPKUR: TcxDBComboBox;
    ComboDURUM: TcxDBImageComboBox;
    Label11: TcxLabel;
    cxLabel5: TcxLabel;
    ComboBILGI: TcxDBImageComboBox;
    LabelCari: TcxLabel;
    Label2: TLabel;
    ComboSay: TcxComboBox;
    TabSheetFinans: TcxTabSheet;
    ToolBar6: TToolBar;
    FinYeniTus: TToolButton;
    FinSilTus: TToolButton;
    ToolButton15: TToolButton;
    FinKaydetTus: TToolButton;
    FinIptalTus: TToolButton;
    ToolButton19: TToolButton;
    GridFinansal: TcxGrid;
    GridFinansalView: TcxGridDBTableView;
    cxGridLevel2: TcxGridLevel;
    TabFinansal: TFDQuery;
    DtsFinansal: TDataSource;
    GridFinansalViewSEC: TcxGridDBColumn;
    GridFinansalViewTARIH: TcxGridDBColumn;
    GridFinansalViewKURUMAD: TcxGridDBColumn;
    GridFinansalViewACIKLAMA: TcxGridDBColumn;
    GridFinansalViewILGILIAD: TcxGridDBColumn;
    TabFinansalID: TAutoIncField;
    TabFinansalTEKLIFID: TIntegerField;
    TabFinansalSEC: TBooleanField;
    TabFinansalTARIH: TSQLTimeStampField;
    TabFinansalKURUMID: TIntegerField;
    TabFinansalILGILIID: TIntegerField;
    TabFinansalACIKLAMA: TWideStringField;
    TabFinansalKURUMAD: TStringField;
    TabFinansalILGILIAD: TStringField;
    frxFINANSMAN: TfrxDBDataset;
    TabFinansalYaz: TFDQuery;
    SQLMemoTeklifTarihce: TcxMemo;
    DtsHesapOzeti: TDataSource;
    TabHesapOzeti: TFDQuery;
    frxHesapOzeti: TfrxDBDataset;
    TabTeklifDetayYazBARKOD: TWideStringField;
    TabTeklifDetayYazKATEGORI_AD: TWideStringField;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel1: TPanel;
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
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    gridFatToplam: TcxGrid;
    tvFatToplamlar: TcxGridDBTableView;
    tvFatToplamlarTUR: TcxGridDBColumn;
    tvFatToplamlarACIKLAMA: TcxGridDBColumn;
    tvFatToplamlarDEGER: TcxGridDBColumn;
    tvFatToplamlarKUR: TcxGridDBColumn;
    tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn;
    tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn;
    gridFatToplamLevel1: TcxGridLevel;
    PanelAltSol: TPanel;
    OnaylanmadiNotu: TcxLabel;
    TabTeklifDetayYazKDVDAHILBRMFIYAT: TFMTBCDField;
    TabTeklifDetayYazGIRISKAYNAK: TWordField;
    TabTeklifDetayYazSATICIKODU: TIntegerField;
    TabTeklifDetayYazSECILEN_BIRIMFIYAT: TFMTBCDField;
    TabTeklifDetayYazSECILEN_TUTAR: TFMTBCDField;
    btnEPosta: TToolButton;
    ToolButton5: TToolButton;
    BtnDoviz: TToolButton;
    GridTeklifWizardDetayViewDOVIZKURDEGERI: TcxGridDBColumn;
    TabTeklifDetayYazOZELKOD2: TWideStringField;
    TabTeklifDetayYazURUNNO: TWideStringField;
    TabTeklifDetayYazBOYUT_EN: TFMTBCDField;
    TabTeklifDetayYazBOYUT_BOY: TFMTBCDField;
    TabTeklifDetayYazBOYUT_YUKSEKLIK: TFMTBCDField;
    TabTeklifDetayYazBOYUT_ALAN: TFMTBCDField;
    GridTeklifWizardDetayViewMEDYAVAR: TcxGridDBColumn;
    TabTeklifDetayID: TAutoIncField;
    TabTeklifDetayTEKLIFID: TIntegerField;
    TabTeklifDetayALTERNATIFNO: TWordField;
    TabTeklifDetayREHBERID: TIntegerField;
    TabTeklifDetaySEC: TBooleanField;
    TabTeklifDetayURUNID: TIntegerField;
    TabTeklifDetayTUR: TSmallintField;
    TabTeklifDetayACIKLAMA: TWideMemoField;
    TabTeklifDetayADET: TFMTBCDField;
    TabTeklifDetayBIRIM: TWideStringField;
    TabTeklifDetayMIKTAR: TFMTBCDField;
    TabTeklifDetayBIRIMFIYAT: TFMTBCDField;
    TabTeklifDetayISKONTO: TFloatField;
    TabTeklifDetayKDV: TSmallintField;
    TabTeklifDetayTUTAR: TFMTBCDField;
    TabTeklifDetayMALIYET: TCurrencyField;
    TabTeklifDetayKUR: TWideStringField;
    TabTeklifDetayKAR_YUZDE: TFloatField;
    TabTeklifDetayOZELKOD: TWideStringField;
    TabTeklifDetayMUHKODU: TWideStringField;
    TabTeklifDetayKASA: TSmallintField;
    TabTeklifDetayONAY: TBooleanField;
    TabTeklifDetayEKLEYEN: TIntegerField;
    TabTeklifDetayEKLEMETARIHI: TSQLTimeStampField;
    TabTeklifDetayDEGISTIREN: TIntegerField;
    TabTeklifDetayDEGISTIRMETARIHI: TSQLTimeStampField;
    TabTeklifDetayDOVIZ_TUTARI: TFMTBCDField;
    TabTeklifDetayDOVIZ_KURU: TWideStringField;
    TabTeklifDetayISKONTO2: TFloatField;
    TabTeklifDetayYERI: TIntegerField;
    TabTeklifDetayYERID: TIntegerField;
    TabTeklifDetayTESLIMTARIHI: TSQLTimeStampField;
    TabTeklifDetayDOVIZ_BIRIMFIYAT: TFMTBCDField;
    TabTeklifDetayKAMPANYAID: TIntegerField;
    TabTeklifDetayVADE: TWordField;
    TabTeklifDetaySUBEID: TSmallintField;
    TabTeklifDetaySIPBIRIMFIYAT: TCurrencyField;
    TabTeklifDetaySIPTUTAR: TCurrencyField;
    TabTeklifDetayMASRAFID: TSmallintField;
    TabTeklifDetayPROJEID: TIntegerField;
    TabTeklifDetayDOVIZKURDEGERI: TCurrencyField;
    TabTeklifDetayRESIMGOSTER: TBooleanField;
    TabTeklifDetayTEKLIFONAY: TWordField;
    TabTeklifDetayIZLEME: TSmallintField;
    TabTeklifDetayMERKEZID: TIntegerField;
    TabTeklifDetaySTOKDURUM: TFloatField;
    TabTeklifDetayEKIPMANID: TIntegerField;
    TabTeklifDetayMF: TFMTBCDField;
    TabTeklifDetayISKONTOLUBRMFIYAT: TFloatField;
    TabTeklifDetayKDVDAHILBRMFIYAT: TFMTBCDField;
    TabTeklifDetayKDVDAHILFIYAT: TFloatField;
    TabTeklifDetaySATICIKODU: TIntegerField;
    TabTeklifDetayGIRISKAYNAK: TWordField;
    TabTeklifDetayOZELKOD2: TWideStringField;
    TabTeklifDetayMEDYAVAR: TBooleanField;
    TabTeklifDetayEN: TFMTBCDField;
    TabTeklifDetayBOY: TFMTBCDField;
    TabTeklifDetayYUZEY: TFMTBCDField;
    TabTeklifDetaySAYI: TFMTBCDField;
    TabTeklifDetayAD: TWideStringField;
    TabTeklifDetayKOD: TWideStringField;
    TabTeklifDetayPROJEKODU: TWideStringField;
    TabTeklifDetaySTOKMALIYET: TCurrencyField;
    TabTeklifDetayDONUSENMIKTAR: TFMTBCDField;
    TabTeklifDetayEKIPMAN: TWideStringField;
    GridTeklifWizardDetayViewEN: TcxGridDBColumn;
    GridTeklifWizardDetayViewBOY: TcxGridDBColumn;
    GridTeklifWizardDetayViewYUZEY: TcxGridDBColumn;
    GridTeklifWizardDetayViewSAYI: TcxGridDBColumn;
    N5: TMenuItem;
    MenuUsteTasi: TMenuItem;
    MenuAltaTasi: TMenuItem;
    TabTeklifDetayPOZNO: TIntegerField;
    PanelAltNotlar: TPanel;
    MemoNOTLAR: TcxDBMemo;
    BeditProjeKod: TcxButtonEdit;
    LabelProje: TcxLabel;
    btnSevkAdresi: TcxButtonEdit;
    cxLabel19: TcxLabel;
    BeditServis: TcxButtonEdit;
    EditOZELKOD: TcxDBTextEdit;
    cxLabel26: TcxLabel;
    cxLabel17: TcxLabel;
    cxLabel7: TcxLabel;
    PanelAltOnay: TPanel;
    cxGroupBoxIcOnay: TcxGroupBox;
    EditOnaylayan: TcxButtonEdit;
    cxLabel4: TcxLabel;
    cxLabel18: TcxLabel;
    cbOnaylayacak: TcxDBImageComboBox;
    cxGroupBoxDisOnay: TcxGroupBox;
    cxLabel22: TcxLabel;
    cxButtonEditDisOnay: TcxButtonEdit;
    PanelAltFiyat: TPanel;
    cxLabel6: TcxLabel;
    FiyatListesi: TcxDBImageComboBox;
    cxLabel8: TcxLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    ComboKur: TcxDBComboBox;
    LabelKur: TcxLabel;
    cxLabel21: TcxLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    editDovizKuru: TcxDBCurrencyEdit;
    ComboTEKLIF_DOVIZI: TcxDBComboBox;
    cxLabel27: TcxLabel;
    procedure BelgeGorTusClick(Sender: TObject);
    procedure TabTeklifBeforePost(DataSet: TDataSet);
    procedure TeklifEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure ComboHazirlayanPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
    procedure ComboIlgiliPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure TabTeklifNewRecord(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure TabTeklifDetayNewRecord(DataSet: TDataSet);
    procedure TamEkranTusClick(Sender: TObject);
    procedure LabelTURUClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure BuMusteriyeKopyalaClick(Sender: TObject);
    procedure OncetusClick(Sender: TObject);
    procedure SonraTusClick(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure EditOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    function EkranAdiAl : string;
    procedure SatirEkleClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure PageControlUstChange(Sender: TObject);
    procedure PageControlAltPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure AlternatifTusClick(Sender: TObject);
    procedure EMail1Click(Sender: TObject);
    procedure TabTeklifDetayBeforePost(DataSet: TDataSet);
    procedure TabTeklifDetayAfterOpenPG(DataSet: TDataSet);
    procedure TabTeklifDetayAfterDelete(DataSet: TDataSet);
    procedure TabTeklifDetayAfterPost(DataSet: TDataSet);
    procedure ComboKurPropertiesCloseUp(Sender: TObject);
    procedure btnTeklifClick(Sender: TObject);
    procedure FirmaBilgileri;
    procedure LabelAdClick(Sender: TObject);
    procedure TabTeklifBeforeEdit(DataSet: TDataSet);
    procedure TabTeklifAfterPost(DataSet: TDataSet);
    procedure TabTeklifDetayCalcFields(DataSet: TDataSet);
    procedure KDVHariTutarGir1Click(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnKaydetTusClick(Sender: TObject);
    procedure DtsTeklifStateChange(Sender: TObject);
    procedure DtsTeklifDetayStateChange(Sender: TObject);
    procedure TarihceEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure GridTeklifWizardDetayViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure btnDokumanClick(Sender: TObject);
    procedure btnAktivitelerClick(Sender: TObject);
    procedure TreeListGecmisTekliflerClick(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure ComboDURUMPropertiesEditValueChanged(Sender: TObject);
    procedure btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BeditProjeKodDblClick(Sender: TObject);
    procedure ComboKurPropertiesEditValueChanged(Sender: TObject);
    procedure editDovizKuruPropertiesChange(Sender: TObject);
    procedure TabTeklifAfterScroll(DataSet: TDataSet);
    procedure SubMenuClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnYenileClick(Sender: TObject);
    procedure GridTeklifViewACIKLAMA1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure comboProjeSonucPropertiesCloseUp(Sender: TObject);
    procedure ComboSayPropertiesCloseUp(Sender: TObject);
    procedure TabTeklifAfterOpen(DataSet: TDataSet);
    procedure FinYeniTusClick(Sender: TObject);
    procedure FinSilTusClick(Sender: TObject);
    procedure FinKaydetTusClick(Sender: TObject);
    procedure FinIptalTusClick(Sender: TObject);
    procedure TabFinansalNewRecord(DataSet: TDataSet);
    procedure GridFinansalViewKURUMADPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridFinansalViewILGILIADPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabFinansalAfterPost(DataSet: TDataSet);
    procedure TabFinansalCalcFields(DataSet: TDataSet);
    procedure DtsFinansalStateChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BeditServisPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BeditServisDblClick(Sender: TObject);
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
    procedure GridTeklifWizardDetayViewCellDblClick(
      Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure ComboTEKLIF_DOVIZIPropertiesInitPopup(Sender: TObject);
    procedure BtnDovizClick(Sender: TObject);
    procedure TabTeklifDetayENChange(Sender: TField);
    procedure MenuUsteTasiClick(Sender: TObject);
  private
    { Private declarations }
    AraDlg:TStokHizmetAraDlg;
    sonbasilanctrl:TcxButtonEdit;
    // Loglama: yukleme aninda TEKLIFDETAY snapshot; kaydette diff (ULog).
    FDetSnap: TObjectDictionary<Integer, TStringList>;
    function  BoslukKontrolu: Boolean;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure Kaydet;
    procedure TeklifTutarHesapla;
    procedure StokDetayAc;
    procedure DetayKopyala(ID : Integer);
    procedure TabSheetEkle(Ad:string; AltNo:SmallInt);
    procedure Skroll;
    procedure KaydetIptalButonlariAyarla;
    procedure IletisimEkleClick(Sender: TObject);
    procedure TeklifDetayRefresh;
    procedure SatinAlmainsert;
    procedure TarihceTabloAc;
    procedure TeklifDoviziDuzenle(Sender: TObject);
    function ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
    procedure Aman_Kilitle_Ac(AcKapa:Boolean);
  public
    { Public declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    IslemOp : Char;
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    TeklifID,SatinAlmaID, RehberId,ProjeID,MasrafMerkezi,ServisID,TeklifTur,TeklifTipi : Integer;
    FOturumID: string;   // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
    Cagiran, Yeri,AlternatifNo:  SmallInt;
    RevizeGrideTiklandi, FSatirEklemeToplamErtele :boolean;
    FEkAlanKuruldu, FEkAlanKuruluyor: Boolean;   // ek-alan (TEKLIF_USER) LAZY kurulum (tek sefer / re-entry guard)
    FEkAlanTeklifID: Integer;                     // ek-alan icin cozulmus teklif ID (EkAlanSekmeHazirla var param)
  end;

var
  TeklifWizardDlg: TTeklifWizardDlg;
  IptalSecildi  : boolean;
  OncekiKDVDurumu:string;
  OncekiDurum,OncekiSubeId :integer;
  DYetkisonuc:DokumanYetkiSonuc;

implementation

Uses UVeriMotor,UAnaForm,FetaClassExtensions,UCombo, UBinarySave, PrjConst,LocOnFly, FetaKurulusSiniflari,
     URaporAraclari, UGenelAnaSekmeFrame, UFastRap,UMailDokum,UGirisKutusuEx,Fetautil,IdGlobalProtocols,
     ULog;

type
  TcxCustomTabControlAccess = class(TcxCustomTabControlProperties);

{$R *.dfm}

var
  Kilit : Boolean;
  OncekiOnaylayacak :integer;

procedure TTeklifWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  i:Integer;
  MusIlgiliID,PersonelID : string;
  FatTutar : Currency;
begin
  TabloYenile(TabTeklifYaz,[CariDoviz,TabTeklif.FieldByName('ID').AsString]);
  TabloYenile(TabTeklifDetayYaz,[CariDoviz,TabTeklif.FieldByName('ID').AsString]);
  TabloYenile(TabTeklifDetayResimli,[TabTeklif.FieldByName('ID').AsString]);
  TabloYenile(TabFinansalYaz,[TabTeklif.FieldByName('ID').AsString]);
  TabloYenile(TabHazirlayanDetay,[TabTeklif.FieldByName('HAZIRLAYAN').AsString]);
  Tablo.TabMusteri.Close;
  Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
  if AktifVeriMotor = vmPG then Tablo.TabMusteri.SQL.Text := PgSqlCevir(Tablo.TabMusteri.SQL.Text);
  Tablo.TabMusteri.Open;
  StokDetayAc;
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxTEKLIF);
  AFastReport.EnabledDataSets.Add(frxTEKLIFDETAY);
  AFastReport.EnabledDataSets.Add(frxFINANSMAN);
  AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
  AFastReport.EnabledDataSets.Add(frxTeklifDetayResimli);
  AFastReport.EnabledDataSets.Add(frxHazirlayanDetay);
  AFastReport.EnabledDataSets.Add(frxStokDetay);

  MusIlgiliID := IIF(TabTEKLIF.FieldByName('MUS_ILGILI').AsString='','-99',TabTEKLIF.FieldByName('MUS_ILGILI').AsString);
  Tablo.TabMusteriIlgili.Close;
  Tablo.TabMusteriIlgili.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1',MusIlgiliID, [rfReplaceAll]);
  if AktifVeriMotor = vmPG then Tablo.TabMusteriIlgili.SQL.Text := PgSqlCevir(Tablo.TabMusteriIlgili.SQL.Text);
  Tablo.TabMusteriIlgili.Open;
  AFastReport.EnabledDataSets.Add(Tablo.frxMusteriIlgili);

  PersonelID := IIF(TabTEKLIF.FieldByName('HAZIRLAYAN').AsString='','-99',TabTEKLIF.FieldByName('HAZIRLAYAN').AsString);
  Tablo.TabPersonel.Close;
  Tablo.TabPersonel.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1',PersonelID, [rfReplaceAll]);
  if AktifVeriMotor = vmPG then Tablo.TabPersonel.SQL.Text := PgSqlCevir(Tablo.TabPersonel.SQL.Text);
  Tablo.TabPersonel.Open;
  AFastReport.EnabledDataSets.Add(Tablo.frxPersonel);

  if (DovizTakibi)and(TabTeklif.FieldByName('KUR').AsString<>CariDoviz) then
      FatTutar := TabTeklif.FieldByName('DOVIZ_TUTARI').AsCurrency
  else
      FatTutar := TabTeklif.FieldByName('TEKLIF_TUTARI').AsCurrency;
  TabloYenile(TabHesapOzeti,[TabTeklif.FieldByName('REHBERID').AsInteger, TabTeklif.FieldByName('KUR').AsString, FatTutar]);
  AFastReport.EnabledDataSets.Add(frxHesapOzeti);

  if TabTeklif.FieldByName('REHBERILETID').Value <> null then begin
     TabloYenile(Tablo.TabSevkAdresi,[RehberId,TabTeklif.FieldByName('REHBERILETID').AsInteger]);
     AFastReport.EnabledDataSets.Add(Tablo.frxSevkAdresi);
  end else
     Tablo.TabSevkAdresi.Close;
  // Kullanici ek alanlari (_USER) rapora (teklif karti).
  Tablo.UserAlanYazdirmaEkle(AFastReport, 'TEKLIF', TabTeklif.FieldByName('ID').AsInteger);
end;

procedure TTeklifWizardDlg.StokDetayAc;
const
  SQL_PG_TEKLIF_STOK_DETAY =
    '/*PGX*/ '+
    'with urunler as ( '+
    '  select t.urunid, s.detaybolumu, s.stokadi, (t.tutar::text || t.kur) as urunfiyat, '+
    '         row_number() over(partition by s.detaybolumu order by t.urunid) as rn '+
    '  from stoklar s inner join teklifdetay t on t.tur=1 and t.urunid=s.id '+
    '  where t.teklifid=:PTeklifID and coalesce(s.detaybolumu, '''')<>'''' '+
    '), satirlar as ( '+
    '  select ra.sira, ra.etiket, ra.bolum as konu, ra.giris '+
    '  from rehberayar ra where ra.yeri=88 and exists(select 1 from urunler u where u.detaybolumu=ra.bolum) '+
    '  union all select distinct -1, ''Ürün Adı'', detaybolumu, -1 from urunler '+
    '  union all select distinct 2147483640, ''Fiyatı'', detaybolumu, 2147483640 from urunler '+
    '), degerler as ( '+
    '  select u.detaybolumu as konu, -1 as sira, ''Ürün Adı'' as etiket, u.rn, u.stokadi as bilgi, null::bytea as resim from urunler u '+
    '  union all select u.detaybolumu, 2147483640, ''Fiyatı'', u.rn, u.urunfiyat, null::bytea from urunler u '+
    '  union all '+
    '  select u.detaybolumu, rb.sira, rb.etiket, u.rn, rb.bilgi, rr.resim '+
    '  from urunler u '+
    '  inner join rehberbilgi rb on rb.yeri=88 and rb.yer_id=u.urunid '+
    '  inner join rehberayar ra on ra.bolum=u.detaybolumu and ra.sira=rb.sira and ra.etiket=rb.etiket '+
    '  left join rehberbilgiresim rr on rr.rehberbilgiid=rb.id '+
    ') '+
    'select row_number() over(order by r.konu, r.sira)::integer as "ID", r.sira as "SIRA", r.etiket as "ETIKET", r.konu as "KONU", r.giris as "GIRIS", '+
    '  max(d.bilgi) filter(where d.rn=1) as "Ürün1", decode(max(encode(d.resim,''hex'')) filter(where d.rn=1),''hex'') as "Resim1", '+
    '  max(d.bilgi) filter(where d.rn=2) as "Ürün2", decode(max(encode(d.resim,''hex'')) filter(where d.rn=2),''hex'') as "Resim2", '+
    '  max(d.bilgi) filter(where d.rn=3) as "Ürün3", decode(max(encode(d.resim,''hex'')) filter(where d.rn=3),''hex'') as "Resim3", '+
    '  max(d.bilgi) filter(where d.rn=4) as "Ürün4", decode(max(encode(d.resim,''hex'')) filter(where d.rn=4),''hex'') as "Resim4", '+
    '  max(d.bilgi) filter(where d.rn=5) as "Ürün5", decode(max(encode(d.resim,''hex'')) filter(where d.rn=5),''hex'') as "Resim5", '+
    '  max(d.bilgi) filter(where d.rn=6) as "Ürün6", decode(max(encode(d.resim,''hex'')) filter(where d.rn=6),''hex'') as "Resim6" '+
    'from satirlar r left join degerler d on d.konu=r.konu and d.sira=r.sira and d.etiket=r.etiket '+
    'group by r.sira, r.etiket, r.konu, r.giris '+
    'order by r.konu, r.sira';
begin
  TabStokDetay.Close;
  if AktifVeriMotor = vmPG then
  begin
    TabStokDetay.SQL.Text := SQL_PG_TEKLIF_STOK_DETAY;
    TabloYenile(TabStokDetay, [TabTeklif.FieldByName('ID').AsInteger]);
  end
  else
    TabloYenile(TabStokDetay,[TabTeklif.FieldByName('ID').Value,6]);
end;

procedure TTeklifWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya duzenleme -> yakala
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Teklif);
end;

procedure TTeklifWizardDlg.TabFinansalAfterPost(DataSet: TDataSet);
begin
   //TabloYenile(TabFinansal, [TabTeklif.FieldByName('ID').AsInteger]);
end;

procedure TTeklifWizardDlg.TabFinansalCalcFields(DataSet: TDataSet);
begin
   TabFinansal.FieldByName('KURUMAD').AsString := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFinansal.FieldByName('REHBERID').AsInteger);
   TabFinansal.FieldByName('ILGILIAD').AsString := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFinansal.FieldByName('ILGILIID').AsInteger);
end;

procedure TTeklifWizardDlg.TabFinansalNewRecord(DataSet: TDataSet);
begin
       TabFinansal.FieldByName('TEKLIFID').AsInteger:=TabTeklif.FieldByName('ID').AsInteger;
       TabFinansal.FieldByName('SEC').AsBoolean:=True;
       TabFinansal.FieldByName('TARIH').AsDateTime:=Tablo.GENINI.BugunTrhSaat;
       GridFinansalViewKURUMADPropertiesButtonClick(Self, 0);
end;

procedure TTeklifWizardDlg.TabSheetEkle(Ad:string; AltNo:SmallInt);
var
   tabSheet : TcxTabSheet;
begin
   TcxCustomTabControlAccess(PageControlUst).LockChangeEvent;
   tabSheet := TcxTabSheet.Create(PageControlUst) ;
   tabSheet.PageControl := PageControlUst;
   tabSheet.Caption := Ad;
   tabSheet.Tag := AltNo;
   AlternatifNo := AltNo;
   tabsheet.Name := 'TabSheetAlternatif'+inttostr(Altno-1);
   TcxCustomTabControlAccess(PageControlUst).UnLockChangeEvent;
  // PageControlUst.ActivePageIndex:=AltNo;
end;

procedure TTeklifWizardDlg.AlternatifTusClick(Sender: TObject) ;
var
  i:integer;
begin
  if TabTeklif.FieldByName('ID').AsString = '' then
     exit;
  for I := 1 to PageControlUst.PageCount-1 do begin
    if not Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from TEKLIFDETAY Where TEKLIFID='+TabTeklif.FieldByName('ID').AsString+' and ALTERNATIFNO='+IntToStr(i)+'',[],[]) then begin
      Application.MessageBox(PChar(TWDetaySatirBos),PChar(Uyari),0);
      Abort;
    end;
  end;
  TabSheetEkle(TWAlternatif+IntToStr(PageControlUst.PageCount-1), PageControlUst.PageCount)
end;


procedure TTeklifWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s,Yol,Atac:string;
  i:smallint;
begin
  Kaydet;
  s := YaziciYaz.Caption;
  Delete(s, pos('&',s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  if TToolButton(Sender).Name='btnEPosta' then begin
     i:=pos(' ', LabelAd.Caption);
     if i=0 then i:=length(LabelAd.caption);
     Yol := GetEnvironmentVariable('Temp')+Concat('\Teklif_', copy(LabelAd.caption,1,i), '_', FormatDateTime('YY_MM',DateTEKLIFTARIHI.Date),'_',
         TabTeklif.FieldByName('TEKLIFNO').AsString,'_R', TabTeklif.FieldByName('REVIZEID').AsString, '.pdf');
     FastRaporDlg.FastRapor(2, EkranAdiAl, s, Yol );
     ////ata?lanacak pdf ler
    // Tablo.TablodanSorguAc(2,'  select AD from DOKUMAN where KLASOR=-88 and MODULID in (select ID from GOREVYORUM where GOREVID='+TabTeklifDetay.FieldByName('URUNID').AsString+' and TUR=88)');
     //if Tablo.Query2.RecordCount > 0 then
     //   Atac := Tablo.Query2.Fields[0].AsString;
//     Tablo.OrtakEPostaGonder(MODUL_Teklif, TabTeklif, Yol, '', '')
     Tablo.OrtakEPostaGonder(MODUL_Teklif, TabTeklif, Yol, 'TEKLIFDETAY', ' MEDYAVAR=1 and TEKLIFID')
  end else
     FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update TEKLIF set YAZDIRILDI=1 where ID='+TabTeklif.FieldByName('ID').AsString,[],[]);
end;

procedure TTeklifWizardDlg.BeditProjeKodDblClick(Sender: TObject);
begin
  if BeditProjeKod.Text <> '' then
     Tablo.ProjeSihirbazBaslat('D', TabTeklif.FieldByName('PROJEID').AsInteger, TabTeklif.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);
end;

procedure TTeklifWizardDlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProjeKod, TabTeklif, AButtonIndex,ProjeSecimi, TabTeklif.FieldByName('REHBERID').AsInteger, 1);
end;

procedure TTeklifWizardDlg.BeditServisDblClick(Sender: TObject);
begin
  if (TabTeklif.FieldByName('SERVISID').Value <> null) and (TabTeklif.FieldByName('SERVISID').AsInteger>0) then
    Tablo.ServisSihirbazBaslat(False,'D',0,TabTeklif.FieldByName('SERVISID').AsInteger,TabTeklif.FieldByName('REHBERID').AsInteger);
end;

procedure TTeklifWizardDlg.BeditServisPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
  SQL:string;
begin
  if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '-' then begin
    TabTeklif.Edit;
    TabTeklif.FieldByName('SERVISID').Value := Null;
    TabTeklif.Post;
    (Sender as TcxButtonEdit).Text := '';
    (Sender as TcxButtonEdit).Tag := 0;
  end else begin
    SQL:='select ID,SERVISNO,BASLAMATARIHI,BITISTARIHI,KONUSU  from SERVIS where (SERVISNO like ''%<ara>%'' or KONUSU like ''%<ara>%'') and isnull(ACKAPA,0)=0 ';
    if (Sender as TcxButtonEdit).Properties.Buttons[AButtonIndex].Caption = '+' then
      SQL:=SQL+'and REHBERID=' + IntToStr(RehberId);
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(ServisSecimi,SQL, st, []) then begin
        TabTeklif.Edit;
        TabTeklif.FieldByName('SERVISID').AsString := st.Strings[0];
        TabTeklif.Post;
        (Sender as TcxButtonEdit).Text := st.Strings[1]+' - '+st.Strings[4];
        (Sender as TcxButtonEdit).Tag := StrToIntDef(st.Strings[0],0);
      end;
    finally
      st.free;
    end;
  end;
end;

procedure TTeklifWizardDlg.BelgeGorTusClick(Sender: TObject);
var Ad: string;
begin
   Ad := TabImaj.FieldByName('BELGEADI').AsString;
   if TabImaj.FieldByName('ICDIS').AsString = 'True' then //e?er dok?man klas?rde dosyada tutuluyorsa
      Tablo.TablodanSorguAc(5,' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '+TabImaj.Fields[0].AsString+' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI='''+ExtractFileExt(Ad)+'''' )
   else
      Tablo.TablodanSorguAc(5,'select ID,ICDIS,BELGE,BELGEADI from IMAJ where ID='+TabImaj.Fields[0].AsString); //e?er dok?man tabloda BELGE alan?nda ise
   KutuktenOku(Tablo.Query5, 'BELGE',ExtractFileExt(Ad) , True);
end;

procedure TTeklifWizardDlg.ComboDURUMPropertiesEditValueChanged(Sender: TObject);
begin
  if TabTeklif.State =dsEdit then
    TabTeklif.FieldByName('DURUMTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
end;

procedure TTeklifWizardDlg.ComboHazirlayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,TabTeklif,'HAZIRLAYAN');
end;

procedure TTeklifWizardDlg.ComboIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabTeklif);
end;

procedure TTeklifWizardDlg.ComboKurPropertiesCloseUp(Sender: TObject);
var KurDegeri : real;
begin
   if (TabTeklif.State in [dsEdit, dsInsert])and(TabTeklif.FieldByName('ID').AsString<>'')  then begin
       if ComboKur.EditValue = CariDoviz then
          KurDegeri := 1
       else
          KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TabTeklif.FieldByName('TARIH').AsDateTime), ComboKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
       TabTeklif.FieldByName('DOVIZKUR').AsFloat := KurDegeri;
       if (TabTeklif.FieldByName('TEKLIF_DOVIZI').AsString<>TabTeklif.FieldByName('DOVIZ_KURU').AsString)
          and(TabTeklif.FieldByName('TEKLIF_DOVIZI').AsString<>CariDoviz)then
          TabTeklif.FieldByName('TEKLIF_DOVIZI').AsString:=CariDoviz;
       TabTeklif.Post;
       TeklifTutarHesapla
   end;
   editDovizKuru.Visible:= ComboKur.EditValue <> CariDoviz;
end;

procedure TTeklifWizardDlg.ComboKurPropertiesEditValueChanged(Sender: TObject);
begin
   if DtsTeklif.State in [dsEdit, dsInsert] then
      TabTeklif.FieldByName('DOVIZKUR').AsExtended := DovizKuruBul(FormatDateTime('yyyy-mm-dd 00:00', TabTeklif.FieldByName('TARIH').AsDateTime),
                                                       TabTeklif.FieldByName('DOVIZ_KURU').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'0'));
end;

procedure TTeklifWizardDlg.comboProjeSonucPropertiesCloseUp(Sender: TObject);
var ID : integer;
begin
   if comboTeklifSonuc.EditValue=-1 then begin//rakip
      ID := Tablo.RehberAra_IDGetir(-1);
      if ID > 0 then begin
         TabTeklif.Edit;
         TabTeklif.FieldByName('CARIID').AsInteger := ID;
         LabelCari.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
      end;
   end
   else begin
         TabTeklif.Edit;
         TabTeklif.FieldByName('CARIID').AsInteger := 0;
         LabelCari.Caption := '';
   end;
end;

procedure TTeklifWizardDlg.ComboSayPropertiesCloseUp(Sender: TObject);
begin
   TarihceTabloAc;
end;

procedure TTeklifWizardDlg.TeklifDoviziDuzenle(Sender: TObject);
begin
{   TcxDBComboBox(Sender).Properties.Items.Clear;
   TcxDBComboBox(Sender).Properties.Items.add(CariDoviz);
   if (ComboKur.EditValue <> null)and(ComboKur.EditValue<>CariDoviz) then
      TcxDBComboBox(Sender).Properties.Items.add(ComboKur.EditValue);
   TcxDBComboBox(Sender).EditValue := CariDoviz;
}
   ComboTEKLIF_DOVIZI.Properties.Items.Clear;
   ComboTEKLIF_DOVIZI.Properties.Items.add(CariDoviz);
   if (ComboKur.EditValue <> null)and(ComboKur.EditValue<>CariDoviz) then
       ComboTEKLIF_DOVIZI.Properties.Items.add(ComboKur.EditValue);
//   ComboTEKLIF_DOVIZI.EditValue := CariDoviz;
end;

procedure TTeklifWizardDlg.ComboTEKLIF_DOVIZIPropertiesInitPopup(Sender: TObject);
begin
   TeklifDoviziDuzenle(Self);
end;

procedure TTeklifWizardDlg.btnTeklifClick(Sender: TObject);
begin
  TabloYenile(TabTeklif, [btnTeklif.tag]);
  WizardKontrol.ActivePageIndex := 0; //ilk sayfa
end;

procedure TTeklifWizardDlg.BtnYenileClick(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update TEKLIFDETAY set STOKDURUM = (select isnull(SUM(isnull(KALAN,0.0)),0.0) from STOKDURUM where STOKID=TEKLIFDETAY.URUNID) where TUR=1 and TEKLIFID=&TID'
                                ,['&TID'],[TabTeklif.FieldByName('ID').AsInteger]);
  TabTeklifDetay.Close;
  TabTeklifDetay.Open;
end;

procedure TTeklifWizardDlg.TreeListGecmisTekliflerClick(Sender: TObject);
begin
  if TabTeklif.State in [dsEdit, dsInsert] then
     Kaydet;
  TabloYenile(TabTeklif, [TabGecmisTeklifler.FieldByName('ID').AsInteger]);
end;

procedure TTeklifWizardDlg.LabelTURUClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TTeklifWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: klasorden dosya ekleme -> yakala
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TTeklifWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: tarayicidan dosya ekleme -> yakala
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TTeklifWizardDlg.MenuUsteTasiClick(Sender: TObject);
var seciliID, seciliSIRA : integer;
  procedure Tasi(ID1, SIRA1, ID2, SIRA2 : integer);
  begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update TEKLIFDETAY set SIRALAMA='+IntToStr(SIRA2)+' Where ID = '+IntToStr(ID1), [],[]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update TEKLIFDETAY set SIRALAMA='+IntToStr(SIRA1)+' Where ID = '+IntToStr(ID2), [],[]);
       TabloYenile(TabTeklifDetay, [TabTeklif.FieldByName('ID').AsInteger, AlternatifNo]);;
     TabTeklifDetay.Locate('ID', ID1, []);
  end;
begin
   seciliID := TabTeklifDetay.FieldByName('ID').AsInteger;
   seciliSIRA := TabTeklifDetay.FieldByName('SIRALAMA').AsInteger;
   if TMenuItem(Sender).Name = 'MenuUsteTasi' then begin
      TabTeklifDetay.Prior;
      if TabTeklifDetay.Bof then
         Showmessage(EnUstte)
      else
         Tasi(seciliID,seciliSIRA, TabTeklifDetay.FieldByName('ID').AsInteger,TabTeklifDetay.FieldByName('SIRALAMA').AsInteger)
   end else begin
      TabTeklifDetay.next;
      if TabTeklifDetay.Eof then
         Showmessage(EnAltta)
      else
         Tasi(TabTeklifDetay.FieldByName('ID').AsInteger,TabTeklifDetay.FieldByName('SIRALAMA').AsInteger,seciliID,seciliSIRA)
   end;

end;

procedure TTeklifWizardDlg.PageControlUstChange(Sender: TObject);
var
i:integer;
NewSubitem, Itemcreate: TMenuItem;
begin
   if PageControlUst.ActivePage.Name = 'TabSheetMetinler' then begin
      PageControlUst.Height := 215;
      Tablo.TablodanSorguAc(1,'Select * from GENINI Where BOLUM='+IntToStr(Ops_Teklif_BilgiSablonu)+' ');
      While not Tablo.Query1.Eof do begin
        NewSubitem := TMenuItem.Create(PMMetinler);
        NewSubitem.Tag := Tablo.Query1.FieldByName('DEGER').AsInteger;
        NewSubitem.Caption := Tablo.Query1.FieldByName('ANAHTAR').AsString;
        NewSubitem.OnClick := SubMenuClick;
        PmSablon.Add(NewSubitem);
        Tablo.Query1.Next;
      end

   end else if PageControlUst.ActivePage.Name = 'TabSheetDetay' then begin
      AlternatifNo:=1;
      GridTeklif.Parent := PanelDetay;
      ToolBar5.Parent := PanelDetay;
      // PanelDetay.Align := alClient;
      PanelAlt.Parent := PanelDetay;
      TeklifDetayRefresh;
   end;
   for i := 1 to 10 do begin
     if PageControlUst.ActivePage.Name = 'TabSheetAlternatif'+IntToStr(i) then begin
       AlternatifNo:=i+1;
       GridTeklif.Parent := PageControlUst.Pages[i+1];
       ToolBar5.Parent := PageControlUst.Pages[i+1];
       PanelAlt.Parent := PageControlUst.Pages[i+1];
       TeklifDetayRefresh;
     end;
   end;
end;

procedure TTeklifWizardDlg.PageControlAltPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  // Ek-alan (TEKLIF_USER) kontrolleri LAZY: sekmeye ilk gecince kurulur (acilisi hizlandirir).
  //   Ortak mantik Tablo.EkAlanSekmeHazirla'da (kart bos-zorunlu alan -> Abort/AllowChange=False; tek sefer).
  if NewPage = TabSheetEkAlanlar then
     Tablo.EkAlanSekmeHazirla(Self, TabTeklif, DtsTeklif, TabSheetEkAlanlar, 'TEKLIF_USER',
      FEkAlanTeklifID, FEkAlanKuruldu, FEkAlanKuruluyor, AllowChange);
end;

procedure TTeklifWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TTeklifWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum silme -> yakala
   Tablo.GridYorumuSil(Tabno_teklif,TabTeklif .FieldByName('ID').AsInteger, TabYorum);
end;

procedure TTeklifWizardDlg.SubMenuClick(Sender: TObject);
var
  c : TComponent;
begin
  if TabTeklif.State in [dsBrowse] then
    TabTeklif.Edit;

  Tablo.TablodanSorguAc(2,'Select ACIKLAMA from TEKLIFHAREKET Where TEKLIFID='+IntToStr(TMenuItem(Sender).Tag));
  c := TPopupMenu(TMenuItem(sender).owner).PopupComponent;
  TabTeklif.FieldByName(TcxDBRichEdit(c).DataBinding.DataField).AsString:=Tablo.Query2.FieldbyName('ACIKLAMA').AsString;
//  TcxDBRichEdit(c).Lines.Add(Tablo.Query2.FieldbyName('ACIKLAMA').AsString);
end;

procedure TTeklifWizardDlg.TeklifDetayRefresh;
begin
  PageControlUst.Height := 26;
  if AlternatifNo <= 0 then
    AlternatifNo := 1;
  TabloYenile(TabTeklifDetay, [TabTeklif.FieldByName('ID').AsInteger, AlternatifNo]);
  TabloYenile(TOPLAMLAR,[TabTeklif.FieldByName('ID').AsInteger,AlternatifNo]);
end;
procedure TTeklifWizardDlg.DtsFinansalStateChange(Sender: TObject);
begin
  FinKaydetTus.Visible := DtsFinansal.State=dsEdit;
  FinIptalTus.Visible := DtsFinansal.State=dsEdit;
  FinYeniTus.Visible := DtsFinansal.State<>dsEdit;
  FinSilTus.Visible := DtsFinansal.State<>dsEdit;
end;

procedure TTeklifWizardDlg.DtsTeklifDetayStateChange(Sender: TObject);
begin
KaydetIptalButonlariAyarla
end;

procedure TTeklifWizardDlg.DtsTeklifStateChange(Sender: TObject);
begin
  KaydetIptalButonlariAyarla;
end;

procedure TTeklifWizardDlg.editDovizKuruPropertiesChange(Sender: TObject);
begin
  if TabTeklif.State in [dsEdit, dsInsert] then
  begin
    TabloYenile(TOPLAMLAR, [TabTeklif.FieldByName('ID').AsInteger,AlternatifNo]);
    TOPLAMLAR.Locate('ACIKLAMA', 'Genel Toplam', [loPartialKey]);
  end;
end;

procedure TTeklifWizardDlg.KaydetIptalButonlariAyarla;
begin
  if (DtsTeklif.State in [dsEdit, dsInsert]) or (DtsTeklifDetay.State in [dsEdit, dsInsert]) then begin
    btnKaydetTus.Visible:=True;
  end else begin
    btnKaydetTus.Visible:=False;
  end;
end;

procedure TTeklifWizardDlg.EditOnaylayanPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var RehID, Onay : Integer;
    s:string[10];
begin
  RehID := Tablo.KullaniciAdiSifreSor(StringReplace(OnayYetki, '@YetkiKodu', '290150', []), TabTeklif.FieldByName('ONAYLAYACAK').AsString);
  if RehID = 0 then
    Abort;
  Aman_Kilitle_Ac(True);
  TabTeklif.Edit;
  if AButtonIndex = 0 then begin
    TabTeklif.FieldByName('ONAYLAYAN').AsInteger := RehID;
    TabTeklif.FieldByName('ONAYTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    EditOnaylayan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID);
    Onay := Tablo.GENINI.ReadInteger(Ops_OpsiyonTeklif_Onaylandi, -1);
    if Onay> -1 then
       TabTeklif.FieldByName('DURUM').AsInteger := Onay;
    s:='getdate()';
  end else if AButtonIndex=1 then begin
    TabTeklif.FieldByName('ONAYLAYAN').AsInteger := 0;
    EditOnaylayan.Text := '';
    Onay := Tablo.GENINI.ReadInteger(Ops_OpsiyonTeklif_OnayBekleme,-1);
    if Onay> -1 then
       TabTeklif.FieldByName('DURUM').AsInteger := Onay;
    s:='null ';
  end;
  TabTeklif.Post;
  Aman_Kilitle_Ac(TabTeklif.FieldByName('ONAYLAYAN').AsInteger < 1);

  // okundu i?aretleyelim ki panodaki listeden silinsin
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI='+s+' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Tabno_TEKLIF)+' and YER_ID='+TabTeklif.FieldByName('ID').AsString+')',[],[]);
 end;

procedure TTeklifWizardDlg.FinIptalTusClick(Sender: TObject);
begin
    TabFinansal.Cancel;
end;

procedure TTeklifWizardDlg.FinKaydetTusClick(Sender: TObject);
begin
   TabFinansal.post;
end;

procedure TTeklifWizardDlg.FinSilTusClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: finansal/plan silme -> yakala
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) <> ID_OK then
    Abort;
  TabFinansal.Delete;
end;

procedure TTeklifWizardDlg.FinYeniTusClick(Sender: TObject);
begin
   TabFinansal.first;
   while not TabFinansal.eof do begin
       TabFinansal.Edit;
       TabFinansal.FieldByName('SEC').AsBoolean:=False;
       TabFinansal.Post;
       TabFinansal.next;
   end;
   TabFinansal.Append;
end;

procedure TTeklifWizardDlg.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  ComboIlgili.Text := '';
  cxButtonEditDisOnay.Text := '';
  lblMusteriAdres.Caption:=Adres+ Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+' '+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+' / '+Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  lblMusteriTel.Caption:= isTel+Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
  lblMusteriEposta.Caption:= EPosta+Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TTeklifWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
   if (IptalSecildi) and ((IslemOp='E')or(IslemOp='K')) then begin //e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
      if (TabTeklif.active)and(TabTeklif.FieldByName('ID').AsString <> '')  then begin
      //varsa dokumanlar?n silinmeli
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[Yeri, TabTeklif.FieldByName('ID').AsInteger]);
      //varsa proje ba?lant?lar? silinmeli

      //sonra kendi silinir
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIFDETAY where TEKLIFID=&Id ',['&Id'], [TabTeklif.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIF where ID=&Id ',['&Id'], [TabTeklif.FieldByName('ID').AsInteger]);
      end;
   end else begin
      // FALLBACK: yeni kart kaydedilip Finish'siz kapatildiysa EKLEME logu kacmasin (tek sefer).
      FEkleLogland := LogKartEkle(TabTeklif, TabNo_TEKLIF, (IslemOp='E') or (IslemOp='K'), FEkleLogland) or FEkleLogland;
      if (IslemOp='D')and(TabTeklifDetay.IsEmpty) then
         raise Exception.Create(UrungirilmedenKaydedilemez);
   end;

   // Geri-alinabilir oturum (D=degistir): iptal -> ilk hale don; kaydet -> snapshot temizle.
   if (IslemOp = 'D') and (FOturumID <> '') then
   begin
     if IptalSecildi then
     begin
       if TabTeklifDetay.State in [dsEdit, dsInsert] then TabTeklifDetay.Cancel;
       if TabTeklif.State in [dsEdit, dsInsert] then TabTeklif.Cancel;
       ULog.OturumGeriAl(FOturumID);
     end
     else
       ULog.OturumBitir(FOturumID);
     FOturumID := '';
   end;

   if IptalSecildi then
      TeklifID := -99
   else
      TeklifID := TabTeklif.FieldByName('ID').AsInteger;

   FreeAndNil(FDetSnap);
end;

procedure TTeklifWizardDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var Ciksin : Boolean;
begin
   Ciksin := True;
   if (IptalSecildi)and((IslemOp='E')or(IslemOp='K')or((IslemOp='D')and(BtnKaydetTus.Visible or ULog.OturumYakalandiMi(FOturumID) or ((TabTeklif.State in [dsEdit,dsInsert]) and TabTeklif.Modified)))) then
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : begin
                Ciksin := False;
                WizardKontrolFinishButtonClick(Self);
               end;
       IDCANCEL:Ciksin := False;
      end;
  CanClose := Ciksin;
end;

procedure TTeklifWizardDlg.FormCreate(Sender: TObject);
var
  I: Integer;
  Q: TFDQuery;
begin
   FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   for I := 0 to ComponentCount - 1 do
     if Components[I] is TFDQuery then begin
       Q := TFDQuery(Components[I]);
       if Q.Connection = nil then
         Q.Connection := Tablo.FDCnn;
     end;

   // Use dynamic fields for reporting query to avoid persistent field type drift.
   for I := ComponentCount - 1 downto 0 do
     if (Components[I] is TField) and (TField(Components[I]).DataSet = TabTeklifDetayYaz) then
       Components[I].Free;

   if AktifVeriMotor = vmPG then
     TabTeklif.UpdateOptions.UpdateTableName := 'TEKLIF'
   else
     TabTeklif.UpdateOptions.UpdateTableName := 'dbo.TEKLIF';
   TabTeklif.UpdateOptions.UpdateMode := upWhereKeyOnly;
   TabTeklif.UpdateOptions.KeyFields := 'ID';
   TabTeklif.UpdateOptions.AutoIncFields := 'ID';
   if AktifVeriMotor = vmPG then
     TabTeklifDetay.UpdateOptions.UpdateTableName := 'TEKLIFDETAY'
   else
     TabTeklifDetay.UpdateOptions.UpdateTableName := 'dbo.TEKLIFDETAY';
   TabTeklifDetay.UpdateOptions.UpdateMode := upWhereKeyOnly;
   TabTeklifDetay.UpdateOptions.KeyFields := 'ID';
   TabTeklifDetay.UpdateOptions.AutoIncFields := 'ID';
   TabTeklifDetay.UpdateOptions.RequestLive := True;
   if AktifVeriMotor = vmPG then
     TabTeklifDetay.SQL.Text :=
       '/*PGX*/ '+
       'select T.*, '+
       'case when T.TUR in (1,11) then (select STOKADI from STOKLAR where ID = T.URUNID) else (select AD from MASRAFGELIR where ID = T.URUNID) end as AD, '+
       'case when T.TUR in (1,11) then (select KOD from STOKLAR where ID = T.URUNID) else (select KOD from MASRAFGELIR where ID = T.URUNID) end as KOD, '+
       '(select P.PROJEKODU from PROJELER P where P.ID = T.PROJEID) as PROJEKODU, '+
       'coalesce((select MALIYET from STOKMALIYET where TUR=2 and STOKID=T.URUNID and T.TUR=1 limit 1),0.0) as STOKMALIYET, '+
       'coalesce((select T.MIKTAR*(SC.ADET2/SC.ADET1) from STOKCEVRIM SC where SC.STOKID=T.URUNID and T.TUR=1 and T.BIRIM=SC.BIRIM1::varchar and SC.BIRIM2=(select DONUSUMTURU from TEKLIF TK where TK.ID=T.TEKLIFID) limit 1),0.0) as DONUSENMIKTAR, '+
       'cast((select E.AD || ''('' || ER.SERINO || '')'' from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID where ER.ID=T.EKIPMANID) as varchar(152)) as EKIPMAN '+
       'from TEKLIFDETAY T '+
       'where T.TEKLIFID = :Par1 and T.ALTERNATIFNO = :Par2 '+
       'order by T.POZNO,T.KUR,T.ID';
   // PG: hesaplanan kolonlari ProviderFlags:=[] ile DML/refresh disi birak (INSERT sonrasi
   //   ID-refresh bozulup satirin grid'den dusmesini engeller). Alanlar her acilista sifirlanir
   //   -> AfterOpen'da uygulanir. Handler kendi icinde vmPG guard'li (MSSQL'de etkisiz).
   if AktifVeriMotor = vmPG then
     TabTeklifDetay.AfterOpen := TabTeklifDetayAfterOpenPG;
   if AktifVeriMotor = vmPG then
     TabFinansal.UpdateOptions.UpdateTableName := 'TEKLIFFINANSAL'
   else
     TabFinansal.UpdateOptions.UpdateTableName := 'dbo.TEKLIFFINANSAL';
   TabFinansal.UpdateOptions.UpdateMode := upWhereKeyOnly;
   TabFinansal.UpdateOptions.KeyFields := 'ID';
   TabFinansal.UpdateOptions.AutoIncFields := 'ID';

   Tablo.WizardTurkcelestir(WizardKontrol);
   ComboKur.Visible:=DovizTakibi;
   LabelKur.Visible:=DovizTakibi;
   if not DovizTakibi then begin
      FreeAndNil(GridTeklifWizardDetayViewDOVIZ_BIRIMFIYAT);
      FreeAndNil(GridTeklifWizardDetayViewDOVIZ_KURU);
      FreeAndNil(GridTeklifWizardDetayViewDOVIZ_TUTARI);
   end;
   IptalSecildi := true;

   RehberId := -1;
   ProjeID := -1;
   //GridTeklifView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\TekliflerWizardGridi',true,False,[gsoUseFilter],'TekliflerWizardGridi');
   Tablo.GridAyarRestore('TekliflerWizardGridi',GridTeklifWizardDetayView );
   //DokumanTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\TeklifDokumanGridi',true,false,[gsoUseFilter],'TeklifDokumanGridi');

   Tablo.GridTurkcelestir;

   //sil ReherIni.ReadSection('Teklif_Konusu', comboKONU.Properties.Items);
   //sil ReherIni.ReadImageSection('FiyatListeAdi', (ComboFIYAT_LISTESI.Properties as TcxImageComboBoxProperties));
   LogID:=0;
   Yeri := 81;
   Tablo.OndalikKisimAyarla(GridTeklifWizardDetayViewBIRIMFIYAT1, OndalikDijitSayBr);
   Tablo.OndalikKisimAyarla(GridTeklifWizardDetayViewTUTAR1, OndalikDijitSayTut);
   if DovizTakibi then begin
      Tablo.OndalikKisimAyarla(GridTeklifWizardDetayViewDOVIZ_BIRIMFIYAT, OndalikDijitSayBr);
      Tablo.OndalikKisimAyarla(GridTeklifWizardDetayViewDOVIZ_TUTARI, OndalikDijitSayTut);
   end;

  if EnBoyHesaplamaAktif =False then begin
     FreeAndNil(TabTeklifDetayEN);
     FreeAndNil(TabTeklifDetayBOY);
     FreeAndNil(TabTeklifDetayYUZEY);
     FreeAndNil(TabTeklifDetaySAYI);
     FreeAndNil(GridTeklifWizardDetayViewEN);
     FreeAndNil(GridTeklifWizardDetayViewBOY);
     FreeAndNil(GridTeklifWizardDetayViewYUZEY);
     FreeAndNil(GridTeklifWizardDetayViewSAYI);
  end;

  // Ek-alan sekmesine gecince TEKLIF_USER kontrollerini LAZY kur (bkz. PageControlAltPageChanging).
  PageControlAlt.OnPageChanging := PageControlAltPageChanging;
end;

procedure TTeklifWizardDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then Key := 0;
end;

procedure TTeklifWizardDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos := Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bile?en Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TTeklifWizardDlg(Self),Tablo.UserDataSourceHazirla(TTeklifWizardDlg(Self), DtsTeklif, 'TEKLIF_USER'));
      Tablo.AlanOlustur(TTeklifWizardDlg(Self),-1,Tablo.UserDataSourceHazirla(TTeklifWizardDlg(Self), DtsTeklif, 'TEKLIF_USER'));
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bile?en D?zenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
      Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(TabSheetEkAlanlar.Name),TTeklifWizardDlg(Self),Tablo.UserDataSourceHazirla(TTeklifWizardDlg(Self), DtsTeklif, 'TEKLIF_USER'));
      Tablo.AlanOlustur(TTeklifWizardDlg(Self),-1,Tablo.UserDataSourceHazirla(TTeklifWizardDlg(Self), DtsTeklif, 'TEKLIF_USER'));
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('S')) then  begin  //Bile?en Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
     if ctrl.Name <> '' then begin
       Tablo.TablodanSorguAc(1,'Select CAPTION,ALANADI,TAG,TABLO from ALANLAR Where TAG='+IntToStr(ctrl.Tag)+' and TUR not in (11,19) ');
       if Application.MessageBox(PChar(Tablo.Query1.FieldByName('CAPTION').AsString+PCHAR(TWSilinsinmi)),PCHAR(Uyari),MB_YESNO)=mrYes then  begin
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from ALANLAR Where TAG ='+IntToStr(ctrl.Tag)+' ',[],[]);
         try
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Alter table '+Tablo.Query1.FieldByName('TABLO').AsString+' drop column '+Tablo.Query1.FieldByName('ALANADI').AsString+' ',[],[]);
         except
         end;
           ctrl.Visible := False;
           //Tablo.AlanOlustur(FindComponent(TabSheetEkAlanlar.Name),TTeklifWizardDlg(Self),-1,DtsTeklif);
           Tablo.AlanOlustur(TTeklifWizardDlg(Self),-1,Tablo.UserDataSourceHazirla(TTeklifWizardDlg(Self), DtsTeklif, 'TEKLIF_USER'));
       end;
     end;
    end;
  end;
end;

function TTeklifWizardDlg.EkranAdiAl: string;
begin
  Result := 'TekliflerDlg';
end;


procedure TTeklifWizardDlg.EMail1Click(Sender: TObject);
begin
    Kaydet;
end;

procedure TTeklifWizardDlg.TarihceTabloAc;
var s:String[20];
begin
    if AktifVeriMotor = vmPG then
    begin
      if pos('+', ComboSay.Text)>0 then
         s:=''
      else
         s:=' limit '+ComboSay.Text;

      TabGecmisTeklifler.SQL.Text :=
        'with tmpTeklif as ('+
        'select T1.ID as USTID, T1.ID as ALTID, T1.* '+
        'from TEKLIF T1 '+
        'where T1.DURUM <> 5 and T1.REHBERID = :pRehID '+
        'order by T1.TARIH desc'+s+
        ') '+
        'select * from tmpTeklif '+
        'union all '+
        'select '+
        '(select T3.ID from TEKLIF T3 where T3.DURUM<>5 and T3.REHBERID=:pRehID and T2.TEKLIFNO=T3.TEKLIFNO limit 1) as USTID, '+
        'T2.ID as ALTID, T2.* '+
        'from TEKLIF T2 '+
        'where T2.DURUM=5 and T2.REHBERID=:pRehID '+
        'and exists (select 1 from tmpTeklif Tmp where Tmp.TEKLIFNO = T2.TEKLIFNO) '+
        'order by TARIH desc';
      TabloYenile(TabGecmisTeklifler,[RehberId]); //ID
      Exit;
    end;

    if pos('+', ComboSay.Text)>0 then
       s:=''
    else
       s:=' TOP '+ComboSay.Text;
    TabGecmisTeklifler.SQL.text := StringReplace(SQLMemoTeklifTarihce.text,'--TOP10', s,[]);
    TabloYenile(TabGecmisTeklifler,[RehberId]); //ID
end;

procedure TTeklifWizardDlg.Aman_Kilitle_Ac(AcKapa:Boolean);
begin
        Kilit := not AcKapa;
{        TabTeklif.Close;
        if AcKapa then
        else
        TabTeklif.Open;

        TabTeklifDetay.Close;

        if AcKapa then
        else
        TabTeklifDetay.Open; }

        RevizeTus.Enabled := AcKapa;
        ToolBar5.Enabled := AcKapa;
        PanelUst.Enabled := AcKapa;
        //PanelAlt.Enabled := AcKapa;
        PanelAltNotlar.Enabled := AcKapa;
        PanelAltFiyat.Enabled := AcKapa;
        EditOnaylayan.Enabled := True;
    end;

procedure TTeklifWizardDlg.FormShow(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
begin
  if not TarayiciKullanimda then begin
     BtnDosyaGonder.Kind := cxbkStandard;
     BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
     BtnDosyaGonder.DropDownMenu := nil;
  end;
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  if TGenelAnaSekmeFrame(aktifFrame).Name <> 'AnaGirisSayfasiFrame' then begin
     YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(AktifFrame).pmDokumAyarlar;
     PopupMenuYaz.Images := TGenelAnaSekmeFrame(AktifFrame).ImageList1;
  end;
  ComboSay.Text:='10';

  if cagiran = 5 then      //SATINALMA dan geliyor
     SatinAlmainsert;

  Yeri := 81;

  if not SubeVarmi then begin
     LblSube.Visible:=False;
     ComboSube.Visible:=False;
  end;
  TarihceTabloAc;
  Kilit := False;
  case IslemOp of
     'E':begin //AktiviteWizardDlg.TabTeklif.Append;
            TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
            YaziciYaz.Caption := ra;
            TabloYenile(TabTeklif, [0]);
            TabTeklif.Append;
            btnTeklif.tag:=0;
            TabTeklif.Post;
            TabTeklif.Edit;
         end;
     'D': begin
            TabloYenile(TabTeklif, [TeklifID]);
            RehberId := TabTeklif.FieldByName('REHBERID').AsInteger;


            btnTeklif.tag:= TabTeklif.FieldByName('ID').AsInteger;
            if TabTeklif.FieldByName('REHBERID').AsString<>'' then begin
              LabelKod.Caption := Tablo.AciklamaGetir('REHBER','KOD', TabTeklif.FieldByName('REHBERID').AsString);
              LabelAd.Caption := Tablo.AciklamaGetir('REHBER','FIRMA', TabTeklif.FieldByName('REHBERID').AsString);
            end;
            //Buraya SablonID eklencek.
            //Tablo.TablodanSorguAc(5,' Select ID from DOKUMLER Where GRUBU='''+EkranAdiAl+''' and VARSAYILAN = 1 ');  Tablo.Query5.Fields[0].AsString
            if TabTeklif.FieldByName('SABLONID').AsString <> '' then begin
               // Iki AYRI statement (tek BasitKomut'ta yan yana 2 Update -> PG "syntax error at Update"
               //   veya prepared'da coklu-komut reddi). Ayri cagri her iki motorda da guvenli.
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update DOKUMLER set VARSAYILAN = 0 Where GRUBU='''+EkranAdiAl+''' ',[],[]);
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update DOKUMLER set VARSAYILAN = 1 Where GRUBU='''+EkranAdiAl+''' and ID = '+TabTeklif.FieldByName('SABLONID').AsString+' ',[],[]);

               if not RevizeGrideTiklandi then  begin
                 TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
                 YaziciYaz.Caption := ra;
               end;
            end;
             if TabTeklif.FieldByName('HAZIRLAYAN').AsString <> '' then
               ComboHazirlayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTeklif.FieldByName('HAZIRLAYAN').AsString);
            if TabTeklif.FieldByName('PROJEID').AsString<>'' then
               BeditProjeKod.Text:=Tablo.AciklamaGetir('PROJELER','PROJEKODU',TabTeklif.FieldByName('PROJEID').AsInteger);
            if (TabTeklif.FieldByName('SERVISID').Value <> null) and (TabTeklif.FieldByName('SERVISID').AsInteger>0) then begin
              Tablo.TablodanSorguAc(9,'select * from SERVIS where ID='+TabTeklif.FieldByName('SERVISID').AsString);
              if not Tablo.Query9.IsEmpty then begin
                BeditServis.Text := Tablo.Query9.FieldByName('SERVISNO').AsString+' - '+Tablo.Query9.FieldByName('KONUSU').AsString;
                BeditServis.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
              end;
            end;

            if TabTeklif.FieldByName('ONAYLAYAN').AsString <> '' then
               EditOnaylayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTeklif.FieldByName('ONAYLAYAN').AsString);
            if TabTeklif.FieldByName('REHBERILETID').AsString <> '' then begin
               btnSevkAdresi.Text := Tablo.AciklamaGetir('REHBERILETISIM','AD', TabTeklif.FieldByName('REHBERILETID').AsString);
               Tablo.TablodanSorguAc(1,' Select RI.ID,RI.AD,RB.BILGI from REHBERILETISIM RI '+
                ' left outer JOIn REHBERBILGI RB on RI.ID=RB.YER_ID '+
                ' left outer join REHBERAYAR RA ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
                ' Where RB.YER_ID ='+TabTeklif.FieldByName('REHBERILETID').AsString+' and RB.YERI=1 and RA.VARSAYILAN=2 and RI.REHBERID='+TabTeklif.FieldByName('REHBERID').AsString+'');
                btnSevkAdresi.Hint :=Tablo.Query1.FieldByName('BILGI').AsString;
            end;
            if TabTeklif.FieldByName('DURUM').AsInteger = 6 then begin //Onaylanmad? ise
               Tablo.TablodanSorguAc(5,'Select '+DbUst(1)+'ACIKLAMA from TEKLIFHAREKET Where TEKLIFID='+IntToStr(TeklifID)+' Order by  EKLEMETARIHI desc '+DbSinir(1));
               Tablo.Query5.FetchAll;
               if Tablo.Query5.RecordCount = 1 then
                 OnaylanmadiNotu.Caption:=Tablo.Query5.FieldByName('ACIKLAMA').AsString;
               OnaylanmadiNotu.Visible:=True;
            end;
           KopyalaTus.enabled:=true;
           RevizeTus.Visible:=true;
         end;
  end;
  // Ek-alan (TEKLIF_USER) kontrolleri artik EAGER kurulmuyor -> ek-alan sekmesine gecince LAZY kurulur
  //   (PageControlAltPageChanging -> Tablo.EkAlanSekmeHazirla). Acilis hizlanir. Flag'leri sifirla.
  FEkAlanKuruldu := False;
  FEkAlanKuruluyor := False;
  FEkAlanTeklifID := 0;
  Skroll;
  FirmaBilgileri;
////////TekliF Detay bilgileri
  LogBelge.Clear;
  if TabTeklif.FieldByName('MUS_ILGILI').AsString <> '' then
     ComboIlgili.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTeklif.FieldByName('MUS_ILGILI').AsString);
  if TabTeklif.FieldByName('DISONAY').AsString <> '' then
      cxButtonEditDisOnay.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTeklif.FieldByName('DISONAY').AsString);
  if TabTeklifDetay.active then begin
    TabTeklifDetay.First;
    while not TabTeklifDetay.Eof do begin
      if LogGun>0 then begin
        Tablo.BelgeLogBelirle(TabTeklifDetay);
      end;
      TabTeklifDetay.Next;
    end;
    if not TabTeklifDetay.IsEmpty then begin
      TabTeklifDetay.Edit;
      TabTeklifDetay.cancel
    end;
  end;
  // Belge yuklendi: TEKLIFDETAY satirlarinin baseline snapshot'ini al (ULog diff icin).
  if TabTeklifDetay.Active then
    LogSnapshotAl(TabTeklifDetay, FDetSnap);
  // Geri-alinabilir oturum (yalniz D=degistir): acilistaki hali SNAPSHOT'a al -> Cancel'da
  // ilk hale don. IMAJ(blob)+DOKUMAN kapsam disi. (TEKLIF + TEKLIFDETAY + yorum.)
  FOturumID := '';
  if LogGun > 0 then
    ULog.LogUserAcilis('TEKLIF_USER', TabTeklif.FieldByName('ID').AsInteger);
  if IslemOp = 'D' then
    FOturumID := ULog.OturumBaslatPlan('TEKLIF', TabTeklif.FieldByName('ID').AsInteger,   // LAZY: plan bellekte
      [ ULog.SnapTablo(1, 'TEKLIF',         'ID=' + TabTeklif.FieldByName('ID').AsString),
        ULog.SnapTablo(1, 'TEKLIF_USER',    'ID=' + TabTeklif.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'TEKLIFDETAY',    'TEKLIFID=' + TabTeklif.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'TEKLIFFINANSAL', 'TEKLIFID=' + TabTeklif.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'GOREVYORUM',     'TUR=' + IntToStr(TabNo_TEKLIF) + ' and GOREVID=' + TabTeklif.FieldByName('ID').AsString),
        ULog.SnapTablo(3, 'DOKUMAN', 'MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabNo_TEKLIF) + ' and GOREVID=' + TabTeklif.FieldByName('ID').AsString + ')'),
        ULog.SnapTablo(4, 'IMAJ',    'YERI=1 and YER_ID in (select ID from DOKUMAN where MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabNo_TEKLIF) + ' and GOREVID=' + TabTeklif.FieldByName('ID').AsString + '))') ]);
  if TabTeklif.FieldByName('CARIID').AsString <> '' then
      LabelCari.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabTeklif.FieldByName('CARIID').AsInteger);

  RevizeGrideTiklandi := False;
  PageControlUst.ActivePageIndex:=0;
  PageControlAlt.ActivePageIndex := TabSheetDetay.PageIndex;
  TeklifTutarHesapla;   // acilis: toplami bir kez hesapla (AfterPost'tan kaldirildi)

  cbOnaylayacak.Properties.Items := Tablo.imgComboboxInit('select ID=0, FIRMA='''' union all '+StringReplace(OnayYetki, '@YetkiKodu', '290150', []),False).Items;
  //TabTeklifDetay.FieldByName('DOVIZ_BIRIMFIYAT').OnChange:= TabTeklifDetayADETChange;
  //TabTeklifDetay.FieldByName('BIRIMFIYAT').OnChange:= TabTeklifDetayADETChange;

  OncekiOnaylayacak := TabTeklif.FieldByName('ONAYLAYACAK').AsInteger;



   if (TabTeklif.FieldByName('ONAYLAYAN').AsInteger>0)or((IslemOp='D')and(KilitKontrolEt(2,80,TabTeklif.FieldByName('TARIH').AsDateTime,2)))then
       Aman_Kilitle_Ac(False);
end;

procedure TTeklifWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TTeklifWizardDlg.GridFinansalViewILGILIADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.GridEditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabFinansal);
end;

procedure TTeklifWizardDlg.GridFinansalViewKURUMADPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var RId:Integer;
begin
    RId := Tablo.RehberAra_IDGetir(-1);
    if RId > 0 then begin
       TabFinansal.Edit;
       TabFinansal.FieldByName('REHBERID').AsInteger:=RId;
       TabFinansal.post;
    end;
end;

procedure TTeklifWizardDlg.GridTeklifViewACIKLAMA1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := TabTeklifDetay.fieldByName('ACIKLAMA').asstring;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Memo(BGAciklama_gir, @Bilgi)) <> mrOk then    //.Edit(FWToplamTutariGir, @Tutar
      Abort;
   TabTeklifDetay.edit;
   TabTeklifDetay.fieldByName('ACIKLAMA').AsString := VarToStr(Bilgi);
end;

procedure TTeklifWizardDlg.GridTeklifWizardDetayViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=GridTeklif;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTeklifWizardDetayView;
AnaForm.pmGridStil.Tags.Values[GridTeklif.Name]:='TekliflerWizardGridi';
end;

procedure TTeklifWizardDlg.GridTeklifWizardDetayViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if Kilit then exit;
  Tablo.SatirGuncelle(TabTeklifDetay, 100,1, TabTeklif.FieldByName('REHBERID').AsInteger, TabTeklif.FieldByName('TARIH').AsDateTime,[]);
end;

procedure TTeklifWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_Teklif);
end;

procedure TTeklifWizardDlg.IptalTusClick(Sender: TObject);
begin
  TabImaj.Cancel;
end;

procedure TTeklifWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TTeklifWizardDlg.KaydetTusClick(Sender: TObject);
begin
  TabImaj.post;
end;

procedure TTeklifWizardDlg.KDVHariTutarGir1Click(Sender: TObject);
var
    Tutar,Kur: Variant;
  Yuzde,Dovizkuru,Deger:string;
  TutarDv,Doviztutari:Currency;
  YuzdeFloat:extended;
begin
  TeklifDoviziDuzenle(Self);
   Kur := CariDoviz;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.create
        .CurrencyEdit(FWToplamTutariGir, @Tutar,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))
        .ComboBox(FWKurGir,@Kur, ComboTEKLIF_DOVIZI.Properties.Items)) <> mrOk then
      Abort;
   Tutar:=StringReplace(Tutar,',',FormatSettings.Decimalseparator,[rfReplaceAll]);
   Tutar:=StringReplace(Tutar,'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIFDETAY set ISKONTO=0.0, ISKONTO2=0.0,  TUTAR=ADET*BIRIMFIYAT,DOVIZ_TUTARI=ADET*DOVIZ_BIRIMFIYAT where TEKLIFID=&id and ALTERNATIFNO=&AltNo ',['&id','&AltNo'],[TabTeklif.FieldByName('ID').AsInteger,TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger]);
   TabloYenile(TabTeklifDetay,[TabTeklif.FieldByName('ID').AsInteger, AlternatifNo]);
   TeklifTutarHesapla;
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
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIFDETAY set ISKONTO=100.00-'+Yuzde+',ISKONTO2=0.0, TUTAR='+Yuzde+'*ADET*BIRIMFIYAT/100.0, DOVIZ_TUTARI='+Yuzde+'*ADET*DOVIZ_BIRIMFIYAT/100.0 where TEKLIFID=&id and ALTERNATIFNO=&ALTERNATIFNO ',['&id','&ALTERNATIFNO'],[TabTeklif.FieldByName('ID').AsInteger,TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger]);
  end;
   TeklifTutarHesapla;
   TabloYenile(TabTeklifDetay,[TabTeklif.FieldByName('ID').AsInteger, AlternatifNo]);
   TabTeklifDetay.AfterPost := TabTeklifDetayAfterPost;
end;

procedure TTeklifWizardDlg.N51Click(Sender: TObject);
var Yuzde : Variant;
    IskTipi,s : String;
    Kur,Dovizkuru:string;
    Tutar,Doviztutari:Currency;
begin
    IskTipi :=  TMenuItem(Sender).Hint;
   if TMenuItem(Sender).Tag < 0 then begin//?zel
      if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.CurrencyEdit(FWYuzdesiniGirin, @Yuzde,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))) <> mrOk then
         Abort;
       Yuzde:=StringReplace(Yuzde,',',FormatSettings.Decimalseparator,[rfReplaceAll]);
       Yuzde:=StringReplace(Yuzde,'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
      //Yuzde := StringReplace(Yuzde, ',', '.', []);
   end else
      Yuzde := IntToStr(TMenuItem(Sender).Tag);
   s := Yuzde;
   if IskTipi='İskonto1' then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIFDETAY set ISKONTO=&Yuzde, '+
      ' DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*(ADET*DOVIZ_BIRIMFIYAT)/10000.0,'+
      ' TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 where TEKLIFID=&id and ALTERNATIFNO=&AltNo',['&Yuzde','&id','&AltNo'],[StrToFloatDef(Trim(Yuzde),0), TabTeklif.FieldByName('ID').AsInteger, TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger])
   else if IskTipi='İskonto2' then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIFDETAY set ISKONTO2=&Yuzde,'+
      ' DOVIZ_TUTARI=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*(ADET*DOVIZ_BIRIMFIYAT)/10000.0,'+
      '  TUTAR=(100.0-isnull(ISKONTO,0.0))*(100.0-&Yuzde)*ADET*BIRIMFIYAT/10000.0 where TEKLIFID=&id and ALTERNATIFNO=&AltNo',['&Yuzde','&id','&AltNo'],[StrToFloatDef(Trim(Yuzde),0), TabTeklif.FieldByName('ID').AsInteger, TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger]);
      TeklifTutarHesapla;

//    TabTeklifDetay.Close;
//    TabTeklifDetay.Open;
    TabloYenile(TabTeklifDetay,[TabTeklif.FieldByName('ID').AsInteger, AlternatifNo]);


end;
procedure TTeklifWizardDlg.LabelAdClick(Sender: TObject);
begin
  Tablo.RehberSihirbazBaslat(0,TabTeklif.FieldByName('REHBERID').AsInteger,-100,-100, False);
end;

procedure TTeklifWizardDlg.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
   if Application.MessageBox(PChar(TWDikkatMusteriDegistirme),PChar(Uyari),MB_OKCANCEL+MB_ICONWARNING) <> mrOk then
      Abort;
   Id := Tablo.RehberAra_IDGetir(-1);
   if Id > 0 then begin
      RehberId := Id;
      if TabTeklif.State = dsBrowse then
         TabTeklif.Edit;
      TabTeklif.FieldByName('REHBERID').AsInteger := RehberId;
      Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
      TabTeklif.FieldByName('REHBERILETID').AsInteger := tablo.Query1.Fields[0].AsInteger;

      FirmaBilgileri;
      TabTeklif.FieldByName('MUS_ILGILI').AsInteger := 0;
      ComboIlgili.Text := '';
      cxButtonEditDisOnay.Text := '';
      TabloYenile(TabGecmisTeklifler,[RehberId]);
   end;
end;

procedure TTeklifWizardDlg.Kaydet;
var
  s:String;
  YeniTeklif:Boolean;
begin
  // Alt hareketler (TEKLIFDETAY diff) ana kartin moduna gore loglansin -> kart+detaylar
  // tek ISLEMTIPI (UInfo'da tek satir). LogYaz override eder.
  if (IslemOp='E') or (IslemOp='K') then LogUstModu := 1 else LogUstModu := 2;
  if TabTeklif.State in [dsInsert, dsEdit] then  begin
    if BeditProjeKod.Text='' then
        TabTeklif.FieldByName('PROJEID').AsInteger :=-1;

     YeniTeklif := TabTeklif.State = dsInsert;
     // Gercek degisiklik yoksa (Modified=False) Post etme -> gereksiz DEGISTIREN/log olmasin.
     if YeniTeklif or TabTeklif.Modified then
        TabTeklif.post
     else
        TabTeklif.Cancel;

     if islemOp='E' then
        btnTeklif.Tag:=TabTeklif.FieldByName('ID').AsInteger;

     // KART loglama (TEK SEFER): yeni -> LogKayitEkle, edit -> LogIslemleri.
     // Detay loglamasi (LogDiffKaydet/FDetSnap) asagida ayrica yapiliyor -> ona dokunma.
     if LogGun>0 then begin
        if YeniTeklif then
           FEkleLogland := LogKartEkle(TabTeklif, TabNo_TEKLIF, True, FEkleLogland) or FEkleLogland
        else if LogOnceki.Count>0 then
           LogKartDegisti(TabTeklif, TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger);
     end;
  end else begin
    s:=YaziciYaz.Caption;
    Delete(s, pos('&',s), 1);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIF Set SABLONID = (Select ID from DOKUMLER Where GRUBU='''+EkranAdiAl+''' and RAPORADI='''+s+''' ) Where ID='+TabTeklif.FieldByName('ID').AsString+' ',[],[]);
  end;
  Tablo.UserDataSourceKaydet(TTeklifWizardDlg(Self), 'TEKLIF_USER');
  // _USER (ek alan) audit: UserDataSourceKaydet _USER'i post ettikten SONRA logla (kart grubuna baglanir).
  if LogGun > 0 then
    ULog.LogUserKaydet('TEKLIF_USER', TabNo_TEKLIF_USER, TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger, (IslemOp='E') or (IslemOp='K'));

   if TabTeklifDetay.State in [dsInsert, dsEdit] then begin
    TabTeklifDetay.post;
    SayA:=0;
  end;
  // ISLEMLOG: TEKLIFDETAY satirlarini diff ile logla (USiparisWizard LogDiffKaydet deseni).
  // NOT: eski Tablo.LogIslemlerBelge(TabTeklifDetay,...) cagrisi kaldirildi -> LogSatir bos
  // oldugu icin etkisizdi. Kaydetmeyi ASLA bozmamak icin try icinde; sonra snapshot tazelenir.
  try
    if TabTeklifDetay.Active and (TabTeklif.FieldByName('ID').AsInteger > 0) then begin
      LogDiffKaydet(TabTeklifDetay, FDetSnap, TabNo_TEKLIFDETAY, TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger);
      LogSnapshotAl(TabTeklifDetay, FDetSnap);
    end;
  except
  end;
  if TabImaj.State in [dsInsert, dsEdit] then  begin
    TabImaj.post;
    SayA:=0;
    if LogBelge.Count > 0 then
    Tablo.LogIslemlerBelge(TabImaj,TabNo_TEKLIF,TeklifID,4);
  end;

end;
procedure TTeklifWizardDlg.DetayKopyala(ID : Integer);
begin
   TabTeklifDetay.First;
   while not TabTeklifDetay.eof do begin
      Tablo.SQLSatiriKopyala('TEKLIFDETAY', TabTeklifDetay.FieldByName('ID').AsInteger,['TEKLIFID'],[ID]);
      TabTeklifDetay.Next;
   end;
   //Kopyalanm?? sat?rlar?n stok durumunu g?ncelleyelim
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update TEKLIFDETAY set STOKDURUM = (select '+DbUst(1)+'isnull(KALAN,0) from STOKDURUM where STOKDURUM.STOKID=TEKLIFDETAY.URUNID '+DbSinir(1)+')'+
      ' where TEKLIFID='+IntToStr(ID)+' and TUR>0',[],[]);
end;

procedure TTeklifWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TTeklifWizardDlg.DkmanSil1Click(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: dokuman silme -> yakala
if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_teklif,tabteklif.FieldByName('ID').AsInteger]);
  end;
end;

procedure TTeklifWizardDlg.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[Tabno_Teklif, TabTeklif.FieldByName('ID').AsInteger]);
end;

procedure TTeklifWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
               TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabTeklif.FieldByName('REHBERID').AsInteger)

end;

procedure TTeklifWizardDlg.BuMusteriyeKopyalaClick(Sender: TObject);
var
  YeniTeklifID, RevID, RId, RehIletID : Integer;
  belgeno: TBelgeNo;
begin
   Kaydet;
   if (Sender.ClassType = TMenuItem)and( TMenuItem(Sender).Name = 'BaskaMusteriyeKopyala') then begin  //?st taraf? i?in bo? kay?t a??l?r
       RId := Tablo.RehberAra_IDGetir(-1,True);
       if RId <= 0 then exit;
       RehberId:=RId;
       FirmaBilgileri;
   end;

   YeniTeklifID := Tablo.SatirKopyala('TEKLIF', TeklifID); //teklifin ?st taraf? aynen kopyalan?r
   if Sender.ClassType = TToolButton then begin //e?er revize ise kopyalanan? revize diye i?aretle
       RevID := StrToIntDef(VarToStrDef(TabTeklif.FieldByName('REVIZEID').Value,'1'),1);
       //Teklifin ?nceki durumun "Revize" yapal?m
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIF set DURUM=5 where Id=&id ',['&id'],[TeklifID]);
       //Teklifin ?imdiki durumunu "Olu?turma", tarihi ?imdi ve haz?rlayan? da giren ki?i yapal?m
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIF set DURUM=1, REVIZEID='+IntToStr(RevID+1)+', TARIH='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',HAZIRLAYAN='+Kullanan+' where Id=&id ',['&id'],[YeniTeklifID]);
   end else begin //Kopyalama
       belgeno := SiradakiBelgeNumarasi(80,TabTeklif.FieldByName('TARIH').AsDateTime);
       RehIletID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select '+DbUst(1)+'ID from REHBERILETISIM where REHBERID='+IntToStr(RehberId)+' order by VARSAYILAN desc '+DbSinir(1)+' ',[],[],true);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIF set REHBERID=&RID, REHBERILETID=&RIlet, TEKLIFNO=&TNo , TEKLIFSERI=&TSeri, KOCANNO=&KcnNo, TARIH='''+Formatdatetime('yyyy-mm-dd hh:mm:nn.zzz', Tablo.GENINI.BugunTrhSaat)+''',DURUM=&Drm,REVIZEID=&Rvz,HAZIRLAYAN=&Hzr where Id=&id '
                                  ,['&RID','&RIlet','&TNo','&TSeri','&KcnNo','&Drm','&Rvz','&Hzr','&id']
                                  ,[RehberId,RehIletID,belgeno.belgeno,belgeno.SeriNo,KocannoBul(80),1,1,Kullanan, YeniTeklifID]);
       if (Sender.ClassType = TMenuItem)and( TMenuItem(Sender).Name = 'BaskaMusteriyeKopyala') then
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update TEKLIF set MUS_ILGILI=&MusIlgi  where Id=&id ',['&MusIlgi','&id'],[0,YeniTeklifID]);
   end;
   DetayKopyala(YeniTeklifID);
   TeklifID := YeniTeklifID;
   btnTeklif.Tag:=TeklifID;
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into TEKLIFHAREKET(TEKLIFID,EKLEYEN,EKLEMETARIHI,ESKIDURUM,YENIDURUM,ACIKLAMA,SUBEID ) VALUES('+
          IntToStr(TeklifID)+','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(OncekiDurum)+',5,''Revize olarak işaretlendi.'' ,'+IntToStr(SubeId)+')',[],[]);

   TabloYenile(TabGecmisTeklifler,[RehberId]); //,-1
   TabloYenile(TabTeklif, [TeklifID]);

   if pos('Kopyala', TMenuItem(Sender).Name)>0 then
      ShowMessage(TWYeniTeklifeAit);
end;

procedure TTeklifWizardDlg.Skroll;
var I : SmallInt;
begin
    //e?er alternatif varsa tablar g?r?necek
  while PageControlUst.PageCount > 2 do begin //?nce g?r?nmez olsun
    // PageControlUst.Tabs.Delete(PageControlUst.Tabs.VisibleTabsCount-1);
    PageControlUst.ActivePage := TabSheetDetay;
    PageControlUst.Pages[PageControlUst.PageCount-1].Destroy;
  end;
  if TabTeklif.State <> dsInsert then begin
    tablo.Query1.Close;      // 'select distinct ALTERNATIFNO from TEKLIFDETAY                                                                                          //   TEKLIFID = '+TabTeklif.FieldByName('ID').AsString+'
    tablo.Query1.SQL.Text := 'Select distinct ALTERNATIFNO from TEKLIF T left outer join TEKLIFDETAY TD on '+
    ' T.ID=TD.TEKLIFID where T.ID = '+TabTeklif.FieldByName('ID').AsString+' and  T.TEKLIFNO = '''+TabTeklif.FieldByName('TEKLIFNO').AsString+''' and T.REHBERID='+IntToStr(RehberId)+' and ALTERNATIFNO > 1 order by 1';
    if AktifVeriMotor = vmPG then tablo.Query1.SQL.Text := PgSqlCevir(tablo.Query1.SQL.Text);
    tablo.Query1.Open;
    while not tablo.Query1.eof do begin //sonra varsa a?al?m
       TabSheetEkle('Alternatif '+IntToStr(tablo.Query1.fields[0].AsInteger-1), tablo.Query1.fields[0].AsInteger);
       tablo.Query1.Next;
    end;
  end;
  if TabTeklif.FieldByName('DURUM').AsInteger = 5 then begin
    RevizeTus.Enabled:=False;
    ToolBar5.Enabled:=False;
    GridTeklifWizardDetayView.OptionsSelection.CellSelect:=False;
    PanelAlt.Enabled:=False;
    cxGroupBox1.Enabled:=False;
    cxGroupBox2.Enabled:=False;
    cxGroupBox3.Enabled:=False;
  end else begin
    RevizeTus.Enabled:=True;
    ToolBar5.Enabled:=True;
    GridTeklifWizardDetayView.OptionsSelection.CellSelect:=True;
    PanelAlt.Enabled:=True;
    cxGroupBox1.Enabled:=True;
    cxGroupBox2.Enabled:=True;
    cxGroupBox3.Enabled:=True;
  end;

  if PageControlUst.ActivePageIndex = 0 then
    PageControlUstChange(self)
  else
    PageControlUst.ActivePageIndex := 0; //burda de?i?ece?i i?in PageControlUstChange  zaten yapar
end;

procedure TTeklifWizardDlg.OncetusClick(Sender: TObject);
var
Deg:string;
begin
  if IslemOp<>'E' then begin
    Deg:=TabTeklif.FieldByName('TEKLIFNO').AsString;
    TabTeklif.Prior;
    if Deg=EditTeklifNo.Text then
      Skroll
    else
      TabTeklif.Next;
  end;
end;

procedure TTeklifWizardDlg.SatirEkleClick(Sender: TObject);
var
  LEklemeAlternatifNo, LOncekiDetayMaxID, LTeklifID: Integer;
begin
  //if TabTeklif.State in [dsEdit, dsInsert] then
  //   TabTeklif.Post;

  Kaydet;
  if AlternatifNo <= 0 then
     AlternatifNo := 1;
  LEklemeAlternatifNo := AlternatifNo;
  LTeklifID := TabTeklif.FieldByName('ID').AsInteger;
  LOncekiDetayMaxID := 0;
  if AktifVeriMotor = vmPG then
  begin
    Tablo.TablodanSorguAc(1, '/*PGX*/ select coalesce(max(ID),0) from TEKLIFDETAY');
    if not Tablo.Query1.IsEmpty then
      LOncekiDetayMaxID := Tablo.Query1.Fields[0].AsInteger;
  end;
  if not TabTeklifDetay.Active then
     Skroll;
  Application.CreateForm(TStokHizmetAraDlg,AraDlg);
  AraDlg.GirisCikis:=FWCikis;
  AraDlg.FatBasID:=TabTeklif.FieldByName('ID').AsInteger;
  AraDlg.RehberID:=TabTeklif.FieldByName('REHBERID').AsInteger;
  AraDlg.cbStokDepo.Enabled := True;
  AraDlg.FiyatlariGetir:=True;
  AraDlg.KalanAdetGetir:=True;
  AraDlg.TabDetayGiris:=TabTeklifDetay;
  AraDlg.TabGiris:=TabTeklif;
  AraDlg.cbFiyatAdi.EditValue := TabTeklif.FieldByName('FIYAT_LISTESI').Value;
  AraDlg.cbStokDepo.EditValue := VarsDepo;
  AraDlg.KalmayanCheckGoster:=True;
  AraDlg.stokhizmetaracagirantur:= 100; //15 gidiyordu, de?i?tirdim..
  FSatirEklemeToplamErtele := True;   // toplu ekleme: her satir post'unda toplam hesaplama (yavaslik)
  try
    AraDlg.ShowModal;
    if TabTeklifDetay.State in [dsEdit, dsInsert] then
      TabTeklifDetay.Post;
    if TabTeklif.State in [dsEdit, dsInsert] then
      TabTeklif.Post;
  finally
    FSatirEklemeToplamErtele := False;
    FreeAndNil(AraDlg);
  end;
  AlternatifNo := LEklemeAlternatifNo;

  editDovizKuru.Visible := ComboKur.Text <> CariDoviz;
  TabloYenile(TabTeklifDetay,[LTeklifID,LEklemeAlternatifNo]);
  TeklifTutarHesapla;
end;

procedure TTeklifWizardDlg.SatirSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: satir silme -> yakala
  if Kilit  then begin
     Application.MessageBox(PChar(Butarihoncesiislemyapilmaz),PChar(Uyari),0);
     Abort
  end;
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) <> ID_OK then
     Abort;
  TabTeklifDetay.Delete;
end;

procedure TTeklifWizardDlg.SonraTusClick(Sender: TObject);
var
Deg:string;
begin
  if IslemOp  <> 'E' then begin
    Deg :=TabTeklif.FieldByName('TEKLIFNO').AsString;
    TabTeklif.Next;
    if Deg=EditTeklifNo.Text then
      Skroll
    else
      TabTeklif.Prior;
    end;
end;


procedure TTeklifWizardDlg.TabTeklifAfterOpen(DataSet: TDataSet);
begin
   if AlternatifNo <= 0 then
     AlternatifNo := 1;
   TabloYenile(TabTeklifDetay, [TabTeklif.FieldByName('ID').AsInteger,AlternatifNo]);
   TabloYenile(TabFinansal, [TabTeklif.FieldByName('ID').AsInteger]);
end;

procedure TTeklifWizardDlg.TabTeklifDetayAfterOpenPG(DataSet: TDataSet);
const
  CHesaplananlar: array[0..5] of string =
    ('AD','KOD','PROJEKODU','STOKMALIYET','DONUSENMIKTAR','EKIPMAN');
var
  i: Integer;
begin
  if AktifVeriMotor <> vmPG then Exit;
  // PG driver kolon-koken metasi vermez -> T.* yanindaki hesaplanan (subquery) alanlar
  //   FireDAC'in INSERT sonrasi ID-refresh'ini bozuyor -> RETURNING ID gelmez, satir grid'den
  //   dusuyor (DB'ye commit olur ama gorunmez). Hesaplananlari ProviderFlags:=[] ile DML/refresh
  //   disi birak -> ID refresh calisir, satir kalir. MSSQL'de origin metasi var, etkisiz.
  for i := Low(CHesaplananlar) to High(CHesaplananlar) do
    if TabTeklifDetay.FindField(CHesaplananlar[i]) <> nil then
      TabTeklifDetay.FieldByName(CHesaplananlar[i]).ProviderFlags := [];
end;

procedure TTeklifWizardDlg.TabTeklifAfterPost(DataSet: TDataSet);
begin
  if btnTeklif.tag=0 then
     btnTeklif.tag := TabTeklif.FieldByName('ID').AsInteger;
  // KART loglama Kaydet icinde TEK SEFER yapiliyor (cift log olmasin diye buradan kaldirildi).
  // StokHizmetAra toplu ekleme sirasinda header her detay satirinda post ediliyor -> asagidaki
  //   TOPLAMLAR (EXEC SP_PRG_TeklifDipToplami) + TabTeklifOnay refresh'leri per-satir DB sorgusu =
  //   yavaslik. Bulk'ta ertele; dialog kapaninca SatirEkleClick->TeklifTutarHesapla TOPLAMLAR'i tazeler.
  if not FSatirEklemeToplamErtele then begin
    TabloYenile(TOPLAMLAR, [TabTeklif.FieldByName('ID').AsInteger,AlternatifNo]);
    TabloYenile(TabTeklifOnay, [TabTeklif.FieldByName('ID').AsInteger]);
  end;

  if TabTeklif.FieldByName('KDVDURUM').AsString = 'Muaf' then begin
    TabTeklifDetay.First;
    while not TabTeklifDetay.Eof do begin
      if TabTeklifDetay.FieldByName('KDV').AsInteger <> 0 then begin
        TabTeklifDetay.Edit;
        TabTeklifDetay.FieldByName('KDV').AsInteger := 0;
        TabTeklifDetay.Post;
      end;
      TabTeklifDetay.Next;
    end;
  end;

end;

procedure TTeklifWizardDlg.TabTeklifAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TOPLAMLAR, [TabTeklif.FieldByName('ID').AsInteger,AlternatifNo]);
  TabloYenile(TabTeklifOnay, [TabTeklif.FieldByName('ID').AsInteger]);
end;

procedure TTeklifWizardDlg.TabTeklifBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: teklif ilk degisikligi -> yakala
  OncekiKDVDurumu := TabTeklif.FieldByName('KDVDURUM').AsString;
  OncekiDurum := TabTeklif.FieldByName('DURUM').AsInteger;
  OncekiSubeId := TabTeklif.FieldByName('SUBEID').AsInteger;
  if LogGun >0 then
     Tablo.OncekiLogBelirle(TabTeklif);
end;

procedure TTeklifWizardDlg.TabTeklifBeforePost(DataSet: TDataSet);
var
  Aciklama:Variant;
  RehID:Integer;
begin
  ULog.OturumYakala(FOturumID);   // LAZY: teklif post -> yakala
  BoslukKontrolu;
  if TabTeklif.FieldByName('TEKLIF_DOVIZI').AsString='' then
     TabTeklif.FieldByName('TEKLIF_DOVIZI').AsString:=CariDoviz;
  if TabTeklif.FieldByName('ONAYLAYACAK').AsString='0' then
    TabTeklif.FieldByName('ONAYLAYACAK').Value := null;
  if KilitKontrolEt(1,80,TabTeklif.FieldByName('TARIH').AsDateTime,1) then
     Abort;
  TabTeklif.FieldByName('DEGISTIREN').AsString := Kullanan;

  TabTeklif.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;

  if TabTeklif.FieldByName('DOVIZ_KURU').Value = null then
    TabTeklif.FieldByName('DOVIZ_KURU').Value := TabTeklif.FieldByName('KUR').Value;

  if TabTeklif.FieldByName('SUBEID').OldValue <> TabTeklif.FieldByName('SUBEID').NewValue then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFDETAY set SUBEID='+TabTeklif.FieldByName('SUBEID').AsString+' Where TEKLIFID ='+IntToStr(TeklifID)+' ',[],[]);
  end;

end;

procedure TTeklifWizardDlg.TabTeklifDetayAfterDelete(DataSet: TDataSet);
begin
  TeklifTutarHesapla;
  if TabTeklifDetay.IsEmpty then begin
     editDovizKuru.Visible := False;
     TabTeklif.Edit;
     TabTeklif.FieldByName('DOVIZ_KURU').AsString := CariDoviz;
     TabTeklif.FieldByName('TEKLIF_DOVIZI').AsString:=CariDoviz;
     TOPLAMLAR.Close
  end;
end;

procedure TTeklifWizardDlg.TabTeklifDetayAfterPost(DataSet: TDataSet);
var
  TeklifIDDeger, AltNo, DetayID: Integer;
begin
  DetayID := 0;
  TeklifIDDeger := TabTeklif.FieldByName('ID').AsInteger;

  if TabTeklifDetay.FindField('ID') <> nil then
    DetayID := TabTeklifDetay.FieldByName('ID').AsInteger;

  if TabTeklifDetay.FindField('TEKLIFID') <> nil then
    TeklifIDDeger := TabTeklifDetay.FieldByName('TEKLIFID').AsInteger;

  AltNo := AlternatifNo;
  if TabTeklifDetay.FindField('ALTERNATIFNO') <> nil then
    AltNo := TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger;
  if AltNo <= 0 then
    AltNo := 1;
  AlternatifNo := AltNo;

  // Tek satir degisiminde (manuel inline edit) toplami tazele. StokHizmetAra toplu ekleme
  //   sirasinda FSatirEklemeToplamErtele=True -> her satir post'unda cagirma (yavaslik); dialog
  //   kapaninca SatirEkleClick tek sefer hesaplar.
  if not FSatirEklemeToplamErtele then
    TeklifTutarHesapla;

  if TabTeklif.State in [dsEdit, dsInsert] then
    TabTeklif.Post;

  TabloYenile(TabTeklifDetay, [TeklifIDDeger, AltNo], DetayID);
end;

procedure TTeklifWizardDlg.TabTeklifDetayBeforePost(DataSet: TDataSet);
var
  Kur,Dovizkuru:string;
  Tutar,Doviztutari:Extended;
  Procedure TutarIslemler;
  begin
     TabTeklifDetay.FieldByName('DOVIZ_TUTARI').Value :=Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabTeklifDetay.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabTeklifDetay.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,TabTeklifDetay.FieldByName('ADET').Value*TabTeklifDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsExtended));
     TabTeklifDetay.FieldByName('BIRIMFIYAT').AsCurrency := TabTeklifDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency * TabTeklifDetay.FieldByName('DOVIZKURDEGERI').AsCurrency;
     TabTeklifDetay.FieldByName('TUTAR').Value := Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabTeklifDetay.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabTeklifDetay.FieldByName('ISKONTO2').Value) / 100)*
                Tablo.KusuratAyarla(OndalikDijitSayTut,TabTeklifDetay.FieldByName('ADET').Value*TabTeklifDetay.FieldByName('BIRIMFIYAT').AsExtended));
  end;
begin
  ULog.OturumYakala(FOturumID);   // LAZY: teklif satiri post -> yakala
  if TabTeklifDetay.FindField('TEKLIFID') <> nil then
    TabTeklifDetay.FieldByName('TEKLIFID').AsInteger := TabTeklif.FieldByName('ID').AsInteger;

  if TabTeklifDetay.FindField('ALTERNATIFNO') <> nil then begin
    if TabTeklifDetay.FieldByName('ALTERNATIFNO').IsNull or
       (TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger <= 0) then
    begin
      if AlternatifNo <= 0 then
        AlternatifNo := 1;
      TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger := AlternatifNo;
    end;
    AlternatifNo := TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger;
  end;

  if (TabTeklifDetay.FieldByName('ISKONTO').AsFloat=0)and(TabTeklifDetay.FieldByName('ISKONTO2').AsFloat<>0) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGSadeceIskonto2Girilemez);
     Abort;
  end;
  if TabTeklifDetay.FieldByName('ADET').AsString = '' then  begin
     TabTeklifDetay.FieldByName('ADET').AsInteger:=0;
     TabTeklifDetay.FieldByName('MIKTAR').AsInteger:=0;
  end;

  if TabTeklifDetay.FieldByname('TUR').asstring='0' then   //hizmetse
     TabTeklifDetay.FieldByname('MIKTAR').AsFloat := TabTeklifDetay.FieldByname('ADET').AsFloat
  else begin //stoksa
     TabTeklifDetay.FieldByname('MIKTAR').AsFloat := Tablo.StokMiktarHesapla(TabTeklifDetay.FieldByname('URUNID').AsInteger,TabTeklifDetay.FieldByname('ADET').AsFloat,TabTeklifDetay.FieldByname('BIRIM').AsInteger);
  end;

  if TabTeklif.FieldByName('KDVDURUM').AsString = 'Muaf' then begin
    TabTeklifDetay.FieldByName('KDV').AsInteger := 0;
  end;
  if (not Eksiskontoya)and((TabTeklifDetay.FieldByName('ISKONTO').AsFloat<0)or(TabTeklifDetay.FieldByName('ISKONTO2').AsFloat<0)) then begin ///eksi iskonto izni yoksa engel oluruz
     showmessage(BGEksiIskontoGirilemez);
     Abort;
  end;

  TutarIslemler;
end;

procedure TTeklifWizardDlg.TabTeklifDetayCalcFields(DataSet: TDataSet);
begin
   TabTeklifDetay.FieldByName('ISKTUTAR').Value := (TabTeklifDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsFloat*TabTeklifDetay.FieldByName('ADET').AsFloat) - (((100- TabTeklifDetay.FieldByName('ISKONTO').Value)/100)*
                                 ((100-TabTeklifDetay.FieldByName('ISKONTO2').Value)/100)* (TabTeklifDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsFloat));
   if (TabTeklifDetay.FieldByName('EKIPMANID').AsString<>'')and(TabTeklifDetay.FieldByName('EKIPMANID').AsInteger > 0) then begin
       Tablo.TablodanSorguAc(1,'select ER.EKIPMANID, E.AD, ER.SERINO  from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID where ER.ID='+TabTeklifDetay.FieldByName('EKIPMANID').AsString);
       TabTeklifDetay.FieldByName('EKIPMAN').AsString := Tablo.Query1.Fields[1].AsString;
       TabTeklifDetay.FieldByName('SERINO').AsString := Tablo.Query1.Fields[2].AsString;
   end else begin
       TabTeklifDetay.FieldByName('EKIPMAN').AsString:='';
       TabTeklifDetay.FieldByName('SERINO').AsString:='';
   end;
end;

procedure TTeklifWizardDlg.TabTeklifDetayENChange(Sender: TField);
begin
   if (EnBoyHesaplamaAktif = True)and(TabTeklifDetay.FieldByName('EN').AsString<>'')and(TabTeklifDetay.FieldByName('BOY').AsString<>'') then begin
      TabTeklifDetay.FieldByName('YUZEY').AsFloat :=(TabTeklifDetay.FieldByName('EN').AsFloat * TabTeklifDetay.FieldByName('BOY').AsFloat)/1000000;
      TabTeklifDetay.FieldByName('ADET').AsFloat  := TabTeklifDetay.FieldByName('YUZEY').AsFloat * TabTeklifDetay.FieldByName('SAYI').AsFloat;
   end;
end;

function TTeklifWizardDlg.ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
begin
  if TOPLAMLAR.Locate('TUR', Bolum,[loPartialKey]) then
     result := TOPLAMLAR.FieldByName(TLDoviz).AsExtended
  else
     result:=-99999;
end;

procedure TTeklifWizardDlg.TeklifTutarHesapla;
var
  Kur,Dovizkuru:string;
  Tutar,Doviztutari,TEKLIF_MATRAHI, TEKLIF_TUTARI,DOVIZ_TUTARI,KDV_TUTARI,ISKONTO_TUTARI,DOVIZ_KDV_TUTARI,DOVIZ_ISKONTO_TUTARI,DOVIZ_MATRAHI:extended;
begin
  if (not TabTeklifDetay.Active)or(TabTeklifDetay.RecordCount < 1) then
      exit;

  TabloYenile( TOPLAMLAR, [TabTeklif.FieldByName('ID').AsInteger,AlternatifNo]);

  TEKLIF_MATRAHI := ToplamGetir(4,'DEGER');
  if TEKLIF_MATRAHI=-99999 then
     TEKLIF_MATRAHI := ToplamGetir(1,'DEGER'); //Toplam
  ISKONTO_TUTARI := ToplamGetir(3,'DEGER');
  TEKLIF_TUTARI  := ToplamGetir(20,'DEGER');    //'Genel Toplam'
  KDV_TUTARI     := TEKLIF_TUTARI-TEKLIF_MATRAHI;

  DOVIZ_MATRAHI := ToplamGetir(4,'DOVIZTUTARI');
  if DOVIZ_MATRAHI=-99999 then
     DOVIZ_MATRAHI := ToplamGetir(1,'DOVIZTUTARI'); //Toplam
  DOVIZ_ISKONTO_TUTARI := ToplamGetir(3,'DOVIZTUTARI');
  DOVIZ_TUTARI   := ToplamGetir(20,'DOVIZTUTARI');
  DOVIZ_KDV_TUTARI     := DOVIZ_TUTARI-DOVIZ_MATRAHI;

  TabTeklif.Edit;
  TabTeklif.FieldByName('TEKLIF_MATRAHI').AsFloat := TEKLIF_MATRAHI;
  TabTeklif.FieldByName('KDV_TUTARI').Value := KDV_TUTARI;
  TabTeklif.FieldByName('ISKONTO_TUTARI').Value := ISKONTO_TUTARI;
  TOPLAMLAR.Locate('ACIKLAMA', 'Genel Toplam', [loPartialKey]);
  TabTeklif.FieldByName('TEKLIF_TUTARI').AsFloat := TEKLIF_TUTARI;


  TabTeklif.FieldByName('DOVIZ_MATRAHI').AsFloat := DOVIZ_MATRAHI;
  TabTeklif.FieldByName('DOVIZ_KDV_TUTARI').Value := DOVIZ_KDV_TUTARI;
  TabTeklif.FieldByName('DOVIZ_ISKONTO_TUTARI').Value := DOVIZ_ISKONTO_TUTARI;
  TabTeklif.FieldByName('DOVIZ_TUTARI').AsFloat :=DOVIZ_TUTARI;
  TabTeklif.Post;
  //TabTeklif.Refresh;
  //TabTeklif.Edit;
end;

procedure TTeklifWizardDlg.TarihceEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  TabloYenile(TabTeklifHareket, [TabTeklif.FieldByName('ID').AsString]);
end;

procedure TTeklifWizardDlg.btnAktivitelerClick(Sender: TObject);
begin
  WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;
end;

procedure TTeklifWizardDlg.btnDokumanClick(Sender: TObject);
begin
  Kaydet;
  WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;
end;

procedure TTeklifWizardDlg.BtnDovizClick(Sender: TObject);
begin
  Tablo.DovizDegistir(TabTeklif, TabTeklifDetay, 'DOVIZ_KURU', 'TARIH', 'TEKLIFDETAY', 'TEKLIFID');

end;

procedure TTeklifWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya mesaj/dosya ekleme -> yakala
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, tabno_Teklif, tabTeklif.FieldByName('ID').AsInteger,tabTeklif.FieldByName('REHBERID').AsInteger, TabYorum);
end;

procedure TTeklifWizardDlg.btnKaydetTusClick(Sender: TObject);
begin
  Kaydet;
end;

procedure TTeklifWizardDlg.btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  SQLText:String;
  st:TStringList;
begin
  sonbasilanctrl:=Sender as TcxButtonEdit;
  if Not (tabTeklif.State in [dsEdit,dsInsert]) then
    tabTeklif.Edit;
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
      if Tablo.ListedenBilgiGetir('Adres Seçiniz.',SQLText,st,[],'',TNotifyEvent(nil),Tablo.FDCnn,IletisimEkleClick) then begin
        tabTeklif.Edit;
        tabTeklif.FieldByName(sonbasilanctrl.TextHint).AsString:=st.Strings[0];
        sonbasilanctrl.Text:=st.Strings[1];
        sonbasilanctrl.Hint:=st.Strings[2]
      end;
    finally
      st.free;
    end;
  end else if AButtonIndex=1 then begin
        TabTeklif.FieldByName(sonbasilanctrl.TextHint).AsInteger := 0;
        sonbasilanctrl.Text := '';
  end;
 // tabTeklif.Post;
end;

procedure TTeklifWizardDlg.IletisimEkleClick(Sender: TObject);
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
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls)<> mrOK  then
  Abort;                                                            //il?e 6 ,il 8
   //eklenen yeni ileti?im ID sini al?yoruz.
  Tablo.TablodanSorguAc(1,'INSERT INTO REHBERILETISIM (REHBERID,AD,VARSAYILAN ,AKTIF,SUBEID) values('+IntToStr(RehberId)+','''+AD+''',0,1,'+IntToStr(SubeId)+' )  Select SCOPE_IDENTITY() ');
  //Adres i?in
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'''+ADRES+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+' )  ',[],[]);

  //?l?e i?in
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'''+ILCE+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+' )',[],[]);

  //?l i?in
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'''+IL+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+' )',[],[]);

  tabTeklif.FieldByName(sonbasilanctrl.TextHint).AsString:=Tablo.Query1.Fields[0].AsString;
  sonbasilanctrl.Text:=AD;
  sonbasilanctrl.Hint:=ADRES;
end;
procedure TTeklifWizardDlg.TabTeklifDetayNewRecord(DataSet: TDataSet);
begin
//  Tablo.TablodanSorguAc(1,'select isnull(max(SIRALAMA),0)+1 from TEKLIFDETAY T Where TEKLIFID ='+TabTeklif.FieldByName('ID').AsString);
//  TabTeklifDetay.FieldByName('SIRALAMA').Value := Tablo.Query1.Fields[0].AsInteger;
  if AlternatifNo <= 0 then
    AlternatifNo := 1;
  TabTeklifDetay.FieldByName('TEKLIFID').AsInteger := TabTeklif.FieldByname('ID').AsInteger;
  TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger := AlternatifNo;
  TabTeklifDetay.FieldByName('REHBERID').AsInteger := RehberId;
//  TabTeklifDetay.FieldByName('ISKONTO2').Value :=0;
//  TabTeklifDetay.FieldByName('ISKONTO').Value :=0;
  TabTeklifDetay.FieldByName('TESLIMTARIHI').Value :=Date+StrToInt(SpinTESLIM_SURESI.Text);
  TabTeklifDetay.FieldByName('SUBEID').AsInteger := SubeID;
  //TabTeklifDetay.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  TabTeklifDetay.FieldByName('PROJEID').AsInteger := TabTeklif.FieldByName('PROJEID').AsInteger;
  TabTeklifDetay.FieldByName('MASRAFID').AsInteger := TabTeklif.FieldByName('MASRAFID').AsInteger;
  if PozNoAktif then begin
     Tablo.TablodanSorguAc(1, 'select isnull(max(POZNO),0)+'+IntToStr(PozNoAralik)+' from TEKLIFDETAY where TEKLIFID='+TABTEKLIF.FieldByName('ID').AsString);
     TabTeklifDetay.FieldByName('POZNO').AsInteger := Tablo.Query1.Fields[0].AsInteger;
  end;
end;

Procedure TTeklifWizardDlg.SatinAlmainsert;
var
  etiketler,bilgiler:TArrayOfString;
  belgeno: TBelgeNo;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
begin
  case IslemOp of
    'E':begin
       belgeno := SiradakiBelgeNumarasi(81,Tablo.GENINI.BugunTrh);

       Tablo.RehberIletisimAD(RehberId,REHBERILETID,REHBERILETAD,REHBERILETADHINT);

       Tablo.TablodanSorguAc(1,'insert into TEKLIF(TARIH,REHBERID,TEKLIFNO,DURUM,HAZIRLAYAN,KDVDURUM,KUR,TEKLIFTUR,TEKLIFSERI,KOCANNO,REHBERILETID,SUBEID)'+
        ' values('''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(RehberId)+','''+belgeno.BelgeNo+''',1,'+Kullanan+',''Hariç'',''TL'',81,'''+
        belgeno.Serino+''','''+inttoStr(KocannoBul(81))+''','+inttoStr(REHBERILETID)+','+IntToStr(SubeId)+') select scope_identity() ');

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into TEKLIFDETAY(TEKLIFID,ALTERNATIFNO,REHBERID,URUNID,TUR,ADET,BIRIM,MIKTAR,'+
      ' BIRIMFIYAT,ISKONTO,KDV,TUTAR,KUR,DOVIZ_TUTARI,DOVIZ_KURU,ISKONTO2,YERI,YERID,SUBEID,ONAY) '+
      ' Select '+Tablo.Query1.Fields[0].AsString+',1,'+IntToStr(RehberId)+',STOKID,1,ADET,BIRIM,ADET,0,0,KDV,0,''TL'',0,''TL'', '+
      ' 0,'+IntToStr(TabNo_SATINALMA)+',SATINALMAID,SAD.SUBEID,0 from SATINALMADETAY SAD inner join STOKLAR S on SAD.STOKID=S.ID Where SAD.SATINALMAID = '+inttoStr(SatinAlmaID)+' ',[],[]);

      IslemOp := 'D';
      TeklifID := Tablo.Query1.Fields[0].AsInteger;
      TabloYenile(TabTeklif,[RehberId]);
    end;
  end;
end;
procedure TTeklifWizardDlg.TabTeklifNewRecord(DataSet: TDataSet);
var
  etiketler,bilgiler:TArrayOfString;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
  belgeno: TBelgeNo;
begin
  TabTeklif.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrh;
  belgeno := SiradakiBelgeNumarasi(80,TabTeklif.FieldByName('TARIH').AsDateTime);
  TabTeklif.FieldByName('TEKLIFSERI').AsString := belgeno.SeriNo; // seri
  TabTeklif.FieldByName('TEKLIFNO').AsString := belgeno.belgeno; // FatNo;
  TabTeklif.FieldByName('KOCANNO').AsInteger := KocannoBul(80); // KOCAN numaras?
  TabTeklif.FieldByName('REVIZEID').AsInteger := 1;
//  TabTeklif.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  TabTeklif.FieldByName('REHBERID').AsInteger := RehberId;
  TabTeklif.FieldByName('SERVISID').AsInteger := ServisID;

  if (TabTeklif.FieldByName('SERVISID').Value <> null) and (TabTeklif.FieldByName('SERVISID').AsInteger>0) then begin
    Tablo.TablodanSorguAc(9,'select * from SERVIS where ID='+TabTeklif.FieldByName('SERVISID').AsString);
    if not Tablo.Query9.IsEmpty then begin
      BeditServis.Text := Tablo.Query9.FieldByName('SERVISNO').AsString+' - '+Tablo.Query9.FieldByName('KONUSU').AsString;
      BeditServis.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
    end;
  end;

  LabelKod.Caption := Tablo.AciklamaGetir('REHBER', 'KOD', RehberId);
  LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
  //varsay?lan iskonto bilgilerine bakal?m...
//  Tablo.RehberEkBilgileriniGetir(RehberId,2,[70, 75, 76, 78],etiketler,bilgiler);
  Tablo.RehberEkBilgileriniGetir(RehberId, 2, [RehVars_FiyatListeAdi,RehVars_Stok_Vade], etiketler,bilgiler);

  TabTeklif.FieldByName('FIYAT_LISTESI').Value := StrToIntDef(tablo.inidenDegerGetir(IntToStr(Ops_FiyatListeAdi),bilgiler[0]),-1);
  if TabTeklif.FieldByName('FIYAT_LISTESI').Value < 0 then begin
    TabTeklif.FieldByName('FIYAT_LISTESI').Value:=VarsSatisFiyatID;//StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanFiyatSatis', '1', 'C'), 1);//Tablo.GENINI.ReadInteger(Ops_StokHizliGiris_VarsayilanFiyat,1); //   VarsayilanFiyat  StokHizliGiris
  end;

 if bilgiler[1]<>'' then
  TabTeklif.FieldByName('VADE').Value := bilgiler[1];

//  TabTeklif.FieldByName('TURU').AsString := '';
  TabTeklif.FieldByName('HAZIRLAYAN').AsString := Kullanan;
  ComboHazirlayan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Kullanan);
//  TabTeklif.FieldByName('SONUC').AsInteger  := 0;
//  TabTeklif.FieldByName('PLANLAMA').Asboolean := False;
  TabTeklif.FieldByName('DURUM').AsInteger:= 1;
//  TabTeklif.FieldByName('BAGLANTI').AsInteger := 0;
  TabTeklif.FieldByName('ACIKLAMA').AsString := '';
  TabTeklif.FieldByName('DOVIZ_TUTARI').AsFloat := 0;
  TabTeklif.FieldByName('EKLEYEN').AsString := Kullanan;
  TabTeklif.FieldByName('KDVDURUM').AsString := 'Hariç';
  TabTeklif.FieldByName('KUR').AsString := CariDoviz;
  if TabTeklif.FieldByName('KUR').AsString<>CariDoviz then
     ComboKurPropertiesEditValueChanged(Self)
  else
     TabTeklif.FieldByName('DOVIZKUR').AsExtended := 1;

  TabTeklif.FieldByName('PROJEID').AsInteger := ProjeId;

  /////?leti?im
   Tablo.RehberIletisimAD(RehberId,REHBERILETID,REHBERILETAD,REHBERILETADHINT);
   TabTeklif.FieldByName('REHBERILETID').AsInteger :=REHBERILETID ;
   btnSevkAdresi.Text:= REHBERILETAD;
   btnSevkAdresi.Hint:=REHBERILETADHINT;
   /////?leti?im

  TabTeklif.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  if ProjeID <> -1 then
     BeditProjeKod.Text:=Tablo.AciklamaGetir('PROJELER','PROJEKODU',ProjeID);
  TabTeklif.FieldByName('SUBEID').AsInteger := SubeID;
  TabTeklif.FieldByName('MASRAFID').AsInteger := MasrafMerkezi;
  TabTeklif.FieldByName('TEKLIFTUR').AsInteger := TeklifTur ;
  TabTeklif.FieldByName('TEKLIFTIPI').AsInteger := TeklifTipi ;

end;

procedure TTeklifWizardDlg.TamEkranTusClick(Sender: TObject);
begin
   PageControlAlt.Visible := not PageControlAlt.Visible;
   PanelAlt.Visible := PageControlAlt.Visible;
   if PageControlAlt.Visible then
      TamEkranTus.Caption := TamEkran
   else
      TamEkranTus.Caption := KucukEkran
end;

procedure TTeklifWizardDlg.TeklifEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
   Stop := BoslukKontrolu;
end;

procedure TTeklifWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   // Iptal onayi FormCloseQuery'de (KaydetmeSorusu / Gentegre Onay) soruluyor -> burada
   // TEKRAR sorMA (cift onay kaldirildi). Close -> FormCloseQuery -> KaydetmeSorusu.
   Close;
end;

procedure TTeklifWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var  s : string;
begin
  if TabTeklifDetay.Recordcount < 1 then
    raise Exception.create(UrungirilmedenKaydedilemez);

  Kaydet;
  TeklifID := TabTeklif.FieldByName('ID').AsInteger;


  //burada bask? ?nizleme/yazd?rma i?in se?ilmi? ?ablonu teklife kaydedelim
  s := YaziciYaz.Caption;
  Delete(s, pos('&',s), 1);
  Tablo.TablodanSorguAc(1,' Select ID from DOKUMLER Where GRUBU='''+EkranAdiAl+''' and RAPORADI='''+s+''' ');
  //TabTeklif.Edit;     //buras? hata veriyor o y?zden de?i?ti..
  //TabTeklif.FieldByName('SABLONID').AsInteger := Tablo.Query1.FieldByName('ID').AsInteger;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update TEKLIF set SABLONID='+IntToStr(Tablo.Query1.FieldByName('ID').AsInteger)+' where ID='+TabTeklif.FieldByName('ID').AsString,[],[]);



  //Onaylayacak de?i?ti ise onay i?in duyuru yay?nlan?r/de?i?tirilir/silinir
  if OncekiOnaylayacak <> TabTeklif.FieldByName('ONAYLAYACAK').AsInteger then
     Tablo.OnayYayinIslemleri('TEKLIF',TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger, OncekiOnaylayacak, TabTeklif.FieldByName('ONAYLAYACAK').AsInteger, -18);





  IptalSecildi := False;
  ModalResult := mrOk;
end;

function TTeklifWizardDlg.BoslukKontrolu: Boolean;
begin
  if DtsTeklif.State <> dsEdit then
     Exit(False);
  BoslukKontrolu := True;
  if not BoslukKontrol(ComboTURU.text, KontrolTuru) then
    Abort;
  if not BoslukKontrol(ComboKONU.text, KontrolKonusu) then
    Abort;
  if not BoslukKontrol(ComboHazirlayan.text, KontrolSorumlu) then
    Abort;
  if not BoslukKontrol(ComboDURUM.text, KontrolDurum) then
    Abort;
  if not BoslukKontrol(btnSevkAdresi.text, KontrolSevkAdresi) then
    Abort;
  if not BoslukKontrol(DateTEKLIFTARIHI.Text, KontrolTarihi) then
    Abort;
  if not TarihKontrol(DateTEKLIFTARIHI.Date, KontrolTarihi) then
    Abort;

  BoslukKontrolu := False;
end;
end.


































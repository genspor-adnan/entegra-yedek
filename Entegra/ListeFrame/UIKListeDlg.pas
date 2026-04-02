
unit UIKListeDlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, DBGrids, Grids, ExtCtrls,
  Dialogs, Buttons, Mask, Menus, IniFiles, ComCtrls, FireDAC.Comp.Client, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData,
  cxTextEdit, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxControls, cxGridCustomView, cxClasses, cxGridLevel, cxGrid, ToolWin, UPirim,
  cxMaskEdit, cxDropDownEdit, cxContainer, UGentegreFrameYonetimi, UMultiCastEvent,
  URehberAramaFrame, dxSkinsCore, dxSkinscxPCPainter,UFrameYoneticisi, cxCheckBox,
  cxImageComboBox, cxMemo, cxButtonEdit, cxTimeEdit, cxCurrencyEdit,Variants,
  cxLookAndFeelPainters, cxGroupBox, cxImage, cxLabel, cxButtons, cxPC,ComObj,
  cxSplitter, frxClass, frxDBSet, cxGridCustomPopupMenu, cxGridPopupMenu,
  cxCalendar, dxSkinLondonLiquidSky, DateUtils, cxRadioGroup, OfficePopupMenu,
  JvComponentBase, JvDragDrop, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer,
  cxTLData, cxDBTL, cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, Utablo,
  JvTimer, cxSpinEdit, cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxCore,
  cxDateUtils, JvExControls, JvNavigationPane, UCariDurumDetay, URehberHareket,
  UIKDlgGenelAramaFrame, dxBarBuiltInMenu, StrUtils, dxGDIPlusClasses,
  dxSkinLiquidSky, cxGridCustomLayoutView, cxDBEdit, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxListView, cxRichEdit, dxDateRanges,
  dxScrollbarAnnotations, frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TIKListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog )
    REHBER: TFDQuery;
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
    DtsTicari: TDataSource;
    TabFirIletisim: TFDQuery;
    TabRehberIlgili: TFDQuery;
    TabRehberOdeme: TFDQuery;
    TabPerIletisim: TFDQuery;
    TabIsDeneyimi: TFDQuery;
    DtsRehberIlgili: TDataSource;
    DtsIsDeneyimi: TDataSource;
    DtsPerIletisim: TDataSource;
    DtsRehberOdeme: TDataSource;
    DtsRehber: TDataSource;
    frxSozlesme: TfrxDBDataset;
    frxGorusme: TfrxDBDataset;
    frxIlgili: TfrxDBDataset;
    frxREHBER: TfrxDBDataset;
    frxBanka: TfrxDBDataset;
    frxSozBelge: TfrxDBDataset;
    TabUcret: TFDQuery;
    DtsUcret: TDataSource;
    TabPerTemel: TFDQuery;
    DtsFirIletisim: TDataSource;
    DtsPerTemel: TDataSource;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    frxEkstre: TfrxDBDataset;
    cxGridPopupMenu1: TcxGridPopupMenu;
    TabCariListe: TFDQuery;
    DtsCariListe: TDataSource;
    PopupMenuYeni: TPopupMenu;
    Tahsilat1: TMenuItem;
    Nakit1: TMenuItem;
    HavaleEFT1: TMenuItem;
    ek1: TMenuItem;
    ek2: TMenuItem;
    Senet1: TMenuItem;
    Odeme1: TMenuItem;
    Nakit2: TMenuItem;
    HavaleEFT2: TMenuItem;
    KrediKart1: TMenuItem;
    ek3: TMenuItem;
    Senet2: TMenuItem;
    TabDemirbasBilgi: TFDQuery;
    DtsDemirbasBilgi: TDataSource;
    PERSONELIZIN: TFDQuery;
    DtsPersonelIzin: TDataSource;
    PMAksiyonlarMenu: TPopupMenu;
    Ekle1: TMenuItem;
    Sil1: TMenuItem;
    AksiyonBilgisiniGorMenu: TMenuItem;
    N4: TMenuItem;
    TahsilMenu2: TMenuItem;
    Nakit3: TMenuItem;
    HavaleEFT3: TMenuItem;
    POS1: TMenuItem;
    ek4: TMenuItem;
    Senet3: TMenuItem;
    OdemeMenu2: TMenuItem;
    NakitOdemeMenu2: TMenuItem;
    HavaleEFTOdemeMenu2: TMenuItem;
    MenuItem72: TMenuItem;
    CekOdemeMenu2: TMenuItem;
    SenetOdemeMenu2: TMenuItem;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    JvDragDrop1: TJvDragDrop;
    TabEkipmanlar: TFDQuery;
    DtsEkipmanlar: TDataSource;
    N9: TMenuItem;
    Kopyala2: TMenuItem;
    REHBERILETISIM: TFDQuery;
    DtsRehberIletisim: TDataSource;
    PopupIletisim: TPopupMenu;
    VarsaylanYap1: TMenuItem;
    N10: TMenuItem;
    letiimaddeitir1: TMenuItem;
    N13: TMenuItem;
    TabDokuman: TFDQuery;
    DtsDokuman: TDataSource;
    DtsSmsEPosta: TDataSource;
    TabSmsEPosta: TFDQuery;
    N14: TMenuItem;
    iadeAl: TMenuItem;
    Faturaile1: TMenuItem;
    GiderPusulasile1: TMenuItem;
    JvTimer1: TJvTimer;
    frxPersonelIzin: TfrxDBDataset;
    Dier1: TMenuItem;
    Dier2: TMenuItem;
    Hediyeeki1: TMenuItem;
    adeeki1: TMenuItem;
    Kupon1: TMenuItem;
    Hediyeeki2: TMenuItem;
    adeeki2: TMenuItem;
    Kupon2: TMenuItem;
    DtsHareketler: TDataSource;
    TabHareketler: TFDQuery;
    TabKesinti: TFDQuery;
    DtsKesinti: TDataSource;
    PmIzinTurleri: TPopupMenu;
    N5: TMenuItem;
    GelenTahakkuk1: TMenuItem;
    GidenTahakkuk1: TMenuItem;
    N6: TMenuItem;
    PozisyonDegisimiMenu: TMenuItem;
    IstenCikisMenu: TMenuItem;
    IstenCikisIptalMenu: TMenuItem;
    SSKBalama1: TMenuItem;
    TabGorevler: TFDQuery;
    DtsGorevler: TDataSource;
    GorevlerMenu: TOfficePopupMenu;
    DuzenleMenu: TMenuItem;
    TamamlandiIsaretleMenu: TMenuItem;
    Bayraklaretle1: TMenuItem;
    MenuItem3: TMenuItem;
    TarihBugunMenu: TMenuItem;
    arihYarn1: TMenuItem;
    TarihiKaldirMenu: TMenuItem;
    MenuItem5: TMenuItem;
    MteriSe1: TMenuItem;
    MenuItem7: TMenuItem;
    BuiiEPostaGnder1: TMenuItem;
    BuiYazdr1: TMenuItem;
    MenuItem9: TMenuItem;
    IsiKopyalaMenu: TMenuItem;
    IsiSilMenu: TMenuItem;
    Aktarm1: TMenuItem;
    N15: TMenuItem;
    ProjeAktarm1: TMenuItem;
    ListesiAktarm1: TMenuItem;
    eklifAktarm1: TMenuItem;
    ServisAktarm1: TMenuItem;
    HereyiAktar1: TMenuItem;
    N16: TMenuItem;
    MaasAvansKapamaMenu: TMenuItem;
    N17: TMenuItem;
    TabIsDeneyimiID: TAutoIncField;
    TabIsDeneyimiREHBERID: TIntegerField;
    TabIsDeneyimiTUR: TSmallintField;
    TabIsDeneyimiBASVURUTARIHI: TSQLTimeStampField;
    TabIsDeneyimiBASLAMATARIHI: TSQLTimeStampField;
    TabIsDeneyimiBITISTARIHI: TSQLTimeStampField;
    TabIsDeneyimiSEKTOR: TSmallintField;
    TabIsDeneyimiDEPARTMAN: TSmallintField;
    TabIsDeneyimiGOREV: TSmallintField;
    TabIsDeneyimiILCE: TSmallintField;
    TabIsDeneyimiIL: TSmallintField;
    TabIsDeneyimiKURUM: TWideStringField;
    TabIsDeneyimiUCRET_ALT: TCurrencyField;
    TabIsDeneyimiUCRET_UST: TCurrencyField;
    TabIsDeneyimiACIKLAMA: TWideStringField;
    TabIsDeneyimiILCEAD: TStringField;
    TabIsDeneyimiILAD: TStringField;
    TabDil: TFDQuery;
    DtsDil: TDataSource;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    TabYorum: TFDQuery;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    N8: TMenuItem;
    ExceldenVeriAlMenu: TMenuItem;
    cxPageControl1: TcxPageControl;
    TabSheetTek: TcxTabSheet;
    TabSheetGrup: TcxTabSheet;
    IKGrid: TcxGrid;
    IKGridView: TcxGridDBTableView;
    IKGridViewID: TcxGridDBColumn;
    IKGridViewKOD1: TcxGridDBColumn;
    IKGridViewVKNO: TcxGridDBColumn;
    IKGridViewFIRMA1: TcxGridDBColumn;
    IKGridViewCINSIYET: TcxGridDBColumn;
    IKGridViewDYERI: TcxGridDBColumn;
    IKGridViewUYRUGU: TcxGridDBColumn;
    IKGridViewDTARIHI: TcxGridDBColumn;
    IKGridViewOGRENIM: TcxGridDBColumn;
    IKGridViewSEKTOR: TcxGridDBColumn;
    IKGridViewDepartman: TcxGridDBColumn;
    IKGridViewGOREVI: TcxGridDBColumn;
    IKGridViewGIRISTARIHI: TcxGridDBColumn;
    IKGridViewCIKISTARIHI: TcxGridDBColumn;
    IKGridViewILCE: TcxGridDBColumn;
    IKGridViewIL: TcxGridDBColumn;
    IKGridViewSUBEID: TcxGridDBColumn;
    IKGridViewDURUMAD: TcxGridDBColumn;
    IKGridViewOZELKOD: TcxGridDBColumn;
    IKGridViewNOTLAR: TcxGridDBColumn;
    IKGridViewBAGID: TcxGridDBColumn;
    IKGridLevel1: TcxGridLevel;
    SQL_IK_Memo: TcxMemo;
    SQL_IK_Aday: TcxMemo;
    ToolBar13: TToolBar;
    YeniGrup: TToolButton;
    SilGrup: TToolButton;
    ToolButton11: TToolButton;
    Panel14: TPanel;
    ToolBar16: TToolBar;
    BtnGrupKisiEkle: TToolButton;
    ToolButton21: TToolButton;
    BtnGrupKisiSil: TToolButton;
    GridGrup: TcxGrid;
    GridGrupView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    PageControlSekme: TcxPageControl;
    TabSheetIlet: TcxTabSheet;
    ToolBar10: TToolBar;
    iletisimEkle: TToolButton;
    iletisimSil: TToolButton;
    ToolButton14: TToolButton;
    iletisimDuzenle: TToolButton;
    cxGrid7: TcxGrid;
    cxGridDBTableView5: TcxGridDBTableView;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridLevel12: TcxGridLevel;
    GridRehberIletisim: TcxGrid;
    GridRehberIletisimView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel13: TcxGridLevel;
    PanelFiyatAltSag: TPanel;
    ToolBar7: TToolBar;
    ResimYapistirTus: TToolButton;
    ToolButton3: TToolButton;
    ResimDosyadanTus: TToolButton;
    LogoResim: TcxDBImage;
    TabSheetIlgili: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGridPersoneller: TcxGridDBTableView;
    PersonelVARSAYILAN: TcxGridDBColumn;
    PersonelAdi: TcxGridDBColumn;
    PersonelNEREDE: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    Panel2: TPanel;
    GridPerIlet: TcxGrid;
    GridPerIletView: TcxGridDBTableView;
    GridPerIletViewTUR: TcxGridDBColumn;
    GridPerIletViewBILGI: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    Panel3: TPanel;
    cxLabel5: TcxLabel;
    cxLabel1: TcxLabel;
    ResimDuzenleTus: TcxButton;
    Resim: TcxImage;
    Panel9: TPanel;
    ToolBar2: TToolBar;
    IlgiliEkleTus: TToolButton;
    IlgiliSilTus: TToolButton;
    ToolButton6: TToolButton;
    IlgiliDuzenleTus: TToolButton;
    JvNavPanelHeader5: TJvNavPanelHeader;
    TabYorumMedya: TcxTabSheet;
    Panel7: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    TabSheetGorev: TcxTabSheet;
    SQLGorevMemo: TcxMemo;
    TreeListGorev: TcxDBTreeList;
    TreeListEkipmancxDBTreeListID: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListACKAPA: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListLISTEADI: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListKONUSU: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListTURU: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListCARIAD: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListATANAN1: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListTARIH: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListNOTLAR_BIT: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListYORUM_BIT: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListTEKRAR_BIT: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListANIMSAT_BIT: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListBAYRAK: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListDURUM: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListPROJEKODU: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListEKLEYENAD: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListEKLEMETARIHI: TcxDBTreeListColumn;
    TreeListGorevcxDBTreeListEKLEYEN: TcxDBTreeListColumn;
    TreeListGorevcxDBTreeListLISTEID: TcxDBTreeListColumn;
    Panel11: TPanel;
    ToolBar12: TToolBar;
    GorevEkleTus: TToolButton;
    GorevSilTus: TToolButton;
    ToolButton19: TToolButton;
    GorevDuzenleTus: TToolButton;
    JvNavPanelHeader6: TJvNavPanelHeader;
    CheckTamamlanan: TcxCheckBox;
    ComboTamamlanan: TcxImageComboBox;
    TabSheetOzluk: TcxTabSheet;
    PanelOzluk: TPanel;
    GridPerTemel: TcxGrid;
    GridPerTemelView: TcxGridDBTableView;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridLevel6: TcxGridLevel;
    ToolBar6: TToolBar;
    OzlukDuzenleTus: TToolButton;
    cxLabel3: TcxLabel;
    Panel4: TPanel;
    Panel6: TPanel;
    ToolBar5: TToolBar;
    DilEkleTus: TToolButton;
    DilSilTus: TToolButton;
    ToolButton17: TToolButton;
    DilKaydetTus: TToolButton;
    DilIptalTus: TToolButton;
    JvNavPanelHeader3: TJvNavPanelHeader;
    cxLabel11: TcxLabel;
    GridDil: TcxGrid;
    GridDilView: TcxGridDBTableView;
    GridDilViewID: TcxGridDBColumn;
    GridDilViewREHBERID: TcxGridDBColumn;
    GridDilViewDIL: TcxGridDBColumn;
    GridDilViewOKUMA: TcxGridDBColumn;
    GridDilViewYAZMA: TcxGridDBColumn;
    GridDilViewKONUSMA: TcxGridDBColumn;
    GridDilViewSINAV: TcxGridDBColumn;
    GridDilViewPUAN: TcxGridDBColumn;
    GridDilViewACIKLAMA: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TabSheetIsDeneyimi: TcxTabSheet;
    GridIKDeneyim: TcxGrid;
    GridIKDeneyimView: TcxGridDBTableView;
    GridIKDeneyimViewID: TcxGridDBColumn;
    GridIKDeneyimViewTUR: TcxGridDBColumn;
    GridIKDeneyimViewBASVURUTARIHI: TcxGridDBColumn;
    GridIKDeneyimViewBASLAMATARIHI: TcxGridDBColumn;
    GridIKDeneyimViewBITISTARIHI: TcxGridDBColumn;
    GridIKDeneyimViewSEKTOR: TcxGridDBColumn;
    GridIKDeneyimViewDEPARTMAN: TcxGridDBColumn;
    GridIKDeneyimViewGOREV: TcxGridDBColumn;
    GridIKDeneyimViewFIRMA: TcxGridDBColumn;
    GridIKDeneyimViewILCE: TcxGridDBColumn;
    GridIKDeneyimViewIL: TcxGridDBColumn;
    GridIKDeneyimViewUCRET_ALT: TcxGridDBColumn;
    GridIKDeneyimViewACIKLAMA: TcxGridDBColumn;
    GridIKDeneyimLevel1: TcxGridLevel;
    ToolBar3: TToolBar;
    DeneyimEkleTus: TToolButton;
    DeneyimSilTus: TToolButton;
    ToolButton10: TToolButton;
    DeneyimKaydet: TToolButton;
    DeneyimIptal: TToolButton;
    TabSheetMaas: TcxTabSheet;
    Panel10: TPanel;
    GridUcret: TcxGrid;
    GridUcretView: TcxGridDBTableView;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    GridUcretViewColumn1: TcxGridDBColumn;
    cxGridLevel8: TcxGridLevel;
    Panel1: TPanel;
    ToolBar4: TToolBar;
    TahakkukYeniTus: TToolButton;
    ToolButton12: TToolButton;
    ToolButton16: TToolButton;
    BankaTus: TToolButton;
    ToolButton8: TToolButton;
    BtnPirim: TToolButton;
    JvNavPanelHeader2: TJvNavPanelHeader;
    LabelBankadanOdeme: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel4: TcxLabel;
    PanelKesinti: TPanel;
    Panel12: TPanel;
    ToolBar8: TToolBar;
    KesintiEkleTus: TToolButton;
    KesintiSilTus: TToolButton;
    ToolButton20: TToolButton;
    KesintiDuzenleTus: TToolButton;
    ToolButton18: TToolButton;
    JvNavPanelHeader7: TJvNavPanelHeader;
    cxLabel9: TcxLabel;
    LabelStandartAvans: TcxLabel;
    cxLabel7: TcxLabel;
    GridKesinti: TcxGrid;
    GridKesintiView: TcxGridDBTableView;
    GridKesintiViewSEC: TcxGridDBColumn;
    GridKesintiViewID: TcxGridDBColumn;
    GridKesintiViewTARIH: TcxGridDBColumn;
    GridKesintiViewTUR: TcxGridDBColumn;
    GridKesintiViewETIKET: TcxGridDBColumn;
    GridKesintiViewTUTAR: TcxGridDBColumn;
    GridKesintiViewKUR: TcxGridDBColumn;
    GridKesintiViewSIRA: TcxGridDBColumn;
    GridKesintiViewACIKLAMA: TcxGridDBColumn;
    GridKesintiLevel: TcxGridLevel;
    TabSheetDemirbas: TcxTabSheet;
    GridDemirbas: TcxGrid;
    GridDemirbasView: TcxGridDBTableView;
    GridDemirbasViewID: TcxGridDBColumn;
    GridDemirbasViewDEMIRBASNO: TcxGridDBColumn;
    GridDemirbasViewDEMIRBASADI: TcxGridDBColumn;
    GridDemirbasViewDURUM: TcxGridDBColumn;
    GridDemirbasViewLOKASYONADI: TcxGridDBColumn;
    GridDemirbasViewKATEGORIADI: TcxGridDBColumn;
    GridDemirbasViewMARKA: TcxGridDBColumn;
    GridDemirbasViewMODEL: TcxGridDBColumn;
    GridDemirbasViewLOKASYONID: TcxGridDBColumn;
    GridDemirbasViewREHBERID: TcxGridDBColumn;
    GridDemirbasLevel3: TcxGridLevel;
    TabSheetIzinBilgileri: TcxTabSheet;
    Panel5: TPanel;
    ToolBar9: TToolBar;
    BtnYeniPerizin: TToolButton;
    BtnSilPerizin: TToolButton;
    BtnDuzenlePerizin: TToolButton;
    JvNavPanelHeader1: TJvNavPanelHeader;
    SETarihBit: TcxSpinEdit;
    SETarihBas: TcxSpinEdit;
    cxLabel6: TcxLabel;
    GridIzinListe: TcxGrid;
    GridIzinListeDBTableView1: TcxGridDBTableView;
    GridIzinListeDBTableView1ID: TcxGridDBColumn;
    GridIzinListeDBTableView1REHBERID: TcxGridDBColumn;
    GridIzinListeDBTableView1DONEM: TcxGridDBColumn;
    GridIzinListeDBTableView1BASLAMA: TcxGridDBColumn;
    GridIzinListeDBTableView1IZINBITIS: TcxGridDBColumn;
    GridIzinListeDBTableView1TUR: TcxGridDBColumn;
    GridIzinListeDBTableView1HAKEDILEN: TcxGridDBColumn;
    GridIzinListeDBTableView1KULLANILAN: TcxGridDBColumn;
    GridIzinListeDBTableView1KALAN: TcxGridDBColumn;
    GridIzinListeDBTableView1BIRIM: TcxGridDBColumn;
    GridIzinListeDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridIzinListeDBTableView1VEKIL: TcxGridDBColumn;
    cxGridLevel9: TcxGridLevel;
    TabSheetPDKS: TcxTabSheet;
    Panel13: TPanel;
    JvNavPanelHeader8: TJvNavPanelHeader;
    CheckPDKSTakibi: TcxCheckBox;
    ToolBar14: TToolBar;
    ButtonVardiyalar: TToolButton;
    ButtonVardiyaTuru: TToolButton;
    ButtonKartNo: TToolButton;
    TabSheetHareketler: TcxTabSheet;
    ToolBar15: TToolBar;
    TBtnHareketlerEkle: TToolButton;
    TBtnHareketlerSil: TToolButton;
    TBtnHareketDuzenle: TToolButton;
    TBtnHareketKaydet: TToolButton;
    TBtnHareketIptal: TToolButton;
    gridPersonelHareketler: TcxGrid;
    gridPersonelHareketlerDBTableView1: TcxGridDBTableView;
    gridPersonelHareketlerDBTableView1ID: TcxGridDBColumn;
    gridPersonelHareketlerDBTableView1REHBERID: TcxGridDBColumn;
    gridPersonelHareketlerDBTableView1TARIH: TcxGridDBColumn;
    gridPersonelHareketlerDBTableView1TUR: TcxGridDBColumn;
    gridPersonelHareketlerDBTableView1SUBE: TcxGridDBColumn;
    gridPersonelHareketlerDBTableView1DEPARTMAN: TcxGridDBColumn;
    gridPersonelHareketlerDBTableView1GOREV: TcxGridDBColumn;
    gridPersonelHareketlerDBTableView1ACIKLAMA: TcxGridDBColumn;
    gridPersonelHareketlerLevel1: TcxGridLevel;
    TabSheetEkstre: TcxTabSheet;
    cxGrid1: TcxGrid;
    cxGridHareketler: TcxGridDBTableView;
    cxGridHareketlerTARIH: TcxGridDBColumn;
    cxGridHareketlerAKSIYONTARIH: TcxGridDBColumn;
    cxGridHareketlerNO: TcxGridDBColumn;
    cxGridHareketlerTUR: TcxGridDBColumn;
    cxGridHareketlerKOD: TcxGridDBColumn;
    cxGridHareketlerBASLIK: TcxGridDBColumn;
    cxGridHareketlerAD: TcxGridDBColumn;
    cxGridHareketlerACIKLAMA: TcxGridDBColumn;
    cxGridHareketlerHESAPKODU: TcxGridDBColumn;
    cxGridHareketlerHESAPADI: TcxGridDBColumn;
    cxGridHareketlerADET: TcxGridDBColumn;
    cxGridHareketlerBIRIM: TcxGridDBColumn;
    cxGridHareketlerBIRIMFIYAT: TcxGridDBColumn;
    cxGridHareketlerBORC: TcxGridDBColumn;
    cxGridHareketlerALACAK: TcxGridDBColumn;
    cxGridHareketlerBORCBAKIYE: TcxGridDBColumn;
    cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn;
    cxGridHareketlerKUR: TcxGridDBColumn;
    cxGridHareketlerMASRAFKOD: TcxGridDBColumn;
    cxGridHareketlerMASRAFAD: TcxGridDBColumn;
    cxGridHareketlerColumn1: TcxGridDBColumn;
    cxGridHareketlerColumn2: TcxGridDBColumn;
    cxGridHareketlerCEKID: TcxGridDBColumn;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    cxGrid1DBTableView1VADE: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    cxGrid1DBTableView1HESAPADI: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    Panel8: TPanel;
    ToolBar11: TToolBar;
    EkstreEkleTus: TToolButton;
    EkstreSilTus: TToolButton;
    EkstreDegisTus: TToolButton;
    ToolButton1: TToolButton;
    JvNavPanelHeader4: TJvNavPanelHeader;
    Label1: TcxLabel;
    CalendarEkstreBas: TcxDateEdit;
    Label2: TcxLabel;
    CalendarEkstreBit: TcxDateEdit;
    CheckDetayli: TcxCheckBox;
    LabelMaasAvansi: TcxLabel;
    EditMaasAvansi: TcxCurrencyEdit;
    EditIsAvansi: TcxCurrencyEdit;
    LabelIsAvansi: TcxLabel;
    cbPerExtreTuru: TcxImageComboBox;
    cxSplitter1: TcxSplitter;
    StringGrid1: TStringGrid;
    TabGrup: TFDQuery;
    DtsGrup: TDataSource;
    SQLKullan: TMemo;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton7: TToolButton;
    DegisTus: TToolButton;
    ToolButton2: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton4: TToolButton;
    AksiyonEkleTus: TToolButton;
    ToolButton9: TToolButton;
    info1: TMenuItem;
    N7: TMenuItem;
//    N7: TMenuItem;
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure AraTusClick(Sender :TObject);
    procedure ComboBox1DropDown(Sender :TObject);
    procedure AraFirmaKeyUp(Sender :TObject; var Key :Word;  Shift :TShiftState);
    procedure EditUcretKeyUp(Sender :TObject; var Key :Word;  Shift :TShiftState);
    procedure DegisTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure IKGridViewDblClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure REHBERAfterOpen(DataSet: TDataSet);
    procedure CheckPasiflerClick(Sender: TObject);
    procedure PageControlSekmeChange(Sender: TObject);
    procedure IKGridViewSelectionChanged(
      Sender: TcxCustomGridTableView);
    procedure IlgiliEkleTusClick(Sender: TObject);
    procedure IlgiliSilTusClick(Sender: TObject);
    procedure ResimDuzenleTusClick(Sender: TObject);
    procedure TicariDuzenleTusClick(Sender: TObject);
    procedure OzlukDuzenleTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure CalendarEkstreBasPropertiesChange(Sender: TObject);
    procedure cxGridPersonellerSelectionChanged(Sender: TcxCustomGridTableView);
    procedure IlgiliDuzenleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure TabRehberIlgiliAfterOpen(DataSet: TDataSet);
    procedure TabIsDeneyimiAfterOpen(DataSet: TDataSet);
    procedure Fatura1Click(Sender: TObject);
    procedure AksiyonBilgisiniGorMenuClick(Sender: TObject);
    procedure GridDemirbasViewDblClick(Sender: TObject);
    procedure LogoResimClick(Sender: TObject);
    procedure DtsPersonelIzinStateChange(Sender: TObject);
    procedure BtnSilPerizinClick(Sender: TObject);
    procedure PageControlGiderChange(Sender: TObject);
    procedure GridIzinListeDBTableView1VEKILGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure cxGrid3DBTableView1VEKILPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridIzinListeDBTableView1IZINVERENREHBERIDGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure cxGrid3DBTableView1IZINVERENREHBERIDPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure TabPersonelIzinBeforePost(DataSet: TDataSet);
    procedure Nakit3Click(Sender: TObject);
    procedure PMAksiyonlarMenuPopup(Sender: TObject);
    procedure IKGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridPerTemelViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridDemirbasViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxGridHareketlerCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridIKDeneyimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure IKGridViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridBankaDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure cxGrid3DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridDemirbasViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridPerTemelViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridUcretViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridUcretViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure cxGridHareketlerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure PERSONELIZINAfterPost(DataSet: TDataSet);
    procedure DtsIsDeneyimiStateChange(Sender: TObject);
    procedure DeneyimIptalClick(Sender: TObject);
    procedure DeneyimKaydetClick(Sender: TObject);
    procedure checkKapaliGosterPropertiesEditValueChanged(Sender: TObject);
    procedure RBDevirliClick(Sender: TObject);
    procedure DtsImajStateChange(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure REHBERBeforeOpen(DataSet: TDataSet);
    procedure cxDBTreeList1cxDBTreeListColumn6PropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure Kopyala2Click(Sender: TObject);
    procedure cxDBTreeList1cxDBTreeListColumn2PropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure IlgiliEkleClick(Sender: TObject);
    procedure YeniletisimEkleMenuClick(Sender: TObject);
    procedure GridRehberIletisimViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure iletisimEkleClick(Sender: TObject);
    procedure iletisimSilClick(Sender: TObject);
    procedure iletisimDuzenleClick(Sender: TObject);
    procedure VarsaylanYap1Click(Sender: TObject);
    procedure letiimaddeitir1Click(Sender: TObject);
    procedure EPostaKontrol1Click(Sender: TObject);
    procedure ButtonVardiyalarClick(Sender: TObject);
    procedure Zimmet2Click(Sender: TObject);
    procedure Faturaile1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure RadioIzinTarihClick(Sender: TObject);
    procedure RadioDonemTarihClick(Sender: TObject);
    procedure SETarihBasPropertiesChange(Sender: TObject);
    procedure TBtnHareketlerSilClick(Sender: TObject);
    procedure TBtnHareketDuzenleClick(Sender: TObject);
    procedure ButtonKartNoClick(Sender: TObject);
    procedure TBtnHareketKaydetClick(Sender: TObject);
    procedure TBtnHareketIptalClick(Sender: TObject);
    procedure ButtonVardiyaTuruClick(Sender: TObject);
    procedure PERSONELIZINNewRecord(DataSet: TDataSet);
    procedure BtnDuzenlePerizinClick(Sender: TObject);
    procedure REHBERAfterScroll(DataSet: TDataSet);
    procedure KesintiDuzenleTusClick(Sender: TObject);
    procedure KesintiEkleTusClick(Sender: TObject);
    procedure KesintiSilTusClick(Sender: TObject);
    procedure GridKesintiViewDblClick(Sender: TObject);
    procedure LabelBankadanOdemeDblClick(Sender: TObject);
    procedure LabelStandartAvansDblClick(Sender: TObject);
    procedure YeniPerizinClick(Sender: TObject);
    procedure cbPerExtreTuruPropertiesEditValueChanged(Sender: TObject);
    procedure CheckDetayliPropertiesEditValueChanged(Sender: TObject);
    procedure GelenTahakkuk1Click(Sender: TObject);
    procedure cxLabel4Click(Sender: TObject);
    procedure IstenCikisMenuClick(Sender: TObject);
    procedure IstenCikisIptalMenuClick(Sender: TObject);
    procedure PopupMenuYeniPopup(Sender: TObject);
    procedure AktiviteEkleTusClick(Sender: TObject);
    procedure AktiviteSilTusClick(Sender: TObject);
    procedure AktiviteDuzenleClick(Sender: TObject);
    procedure CheckTamamlanmisAktivitePropertiesEditValueChanged(
      Sender: TObject);
    procedure SSKBalama1Click(Sender: TObject);
    procedure GorevGridDBTableView1DblClick(Sender: TObject);
    procedure TamamlandiIsaretleMenuClick(Sender: TObject);
    procedure DuzenleMenuClick(Sender: TObject);
    procedure GorevGridDBTableView1ACKAPASECIMPropertiesEditValueChanged(
      Sender: TObject);
    procedure Bayraklaretle1Click(Sender: TObject);
    procedure IsiSilMenuClick(Sender: TObject);
    procedure IsiKopyalaMenuClick(Sender: TObject);
    procedure GorevGridDBTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure ProjeAktarm1Click(Sender: TObject);
    procedure TreeListGorevDblClick(Sender: TObject);
    procedure TreeListGorevClick(Sender: TObject);
    procedure TahakkukYeniTusClick(Sender: TObject);
    procedure BankaTusClick(Sender: TObject);
    procedure DeneyimEkleTusClick(Sender: TObject);
    procedure TabIsDeneyimiNewRecord(DataSet: TDataSet);
    procedure GridIKDeneyimViewFIRMAPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridIKDeneyimViewILCEPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabIsDeneyimiCalcFields(DataSet: TDataSet);
    procedure DeneyimSilTusClick(Sender: TObject);
    procedure DilEkleTusClick(Sender: TObject);
    procedure DilSilTusClick(Sender: TObject);
    procedure DilKaydetTusClick(Sender: TObject);
    procedure DilIptalTusClick(Sender: TObject);
    procedure TabDilNewRecord(DataSet: TDataSet);
    procedure DtsDilStateChange(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure ResimYapistirTusClick(Sender: TObject);
    procedure ResimDosyadanTusClick(Sender: TObject);
    procedure ExceldenVeriAlMenuClick(Sender: TObject);
    procedure TBtnHareketlerEkleClick(Sender: TObject);
    procedure PozisyonDegisimiMenuClick(Sender: TObject);
    procedure TabHareketlerAfterScroll(DataSet: TDataSet);
    procedure GorevEkleTusClick(Sender: TObject);
    procedure GorevSilTusClick(Sender: TObject);
    procedure CheckTamamlananClick(Sender: TObject);
    procedure cxGridDBTableViewPirimCanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure BtnPirimClick(Sender: TObject);
    procedure CheckPDKSTakibiClick(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure YeniGrupClick(Sender: TObject);
    procedure SilGrupClick(Sender: TObject);
    procedure BtnGrupKisiEkleClick(Sender: TObject);
    procedure BtnGrupKisiSilClick(Sender: TObject);
    procedure GridGrupViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure info1Click(Sender: TObject);

  private
    { private declarations }
    FKayitErisimTamamlandi: TNotifyEvent;
    FKayitErisimIptalEdildi: TNotifyEvent;
    FArama : TIKDlgGenelAramaFrame;
    { IBilgiFrame ?yeleri            }
    FFrameBilgi : TIcerikFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    {********************************}
    procedure SetArama(const Value: TIKDlgGenelAramaFrame);
    function EkranAdiAl: string;
    procedure IlgiliAraEditPropertiesChange(Sender: TObject);
  public
    { public declarations }
    Gelis, AdSakla, SoyadSakla :string[20];
    Cagiran : SmallInt;
    procedure RehEkranInit;
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    property KayitErisimTamamlandi : TNotifyEvent read FKayitErisimTamamlandi
      write FKayitErisimTamamlandi;
    property KayitErisimIptalEdildi : TNotifyEvent read FKayitErisimIptalEdildi
      write FKayitErisimIptalEdildi;
  published
    property Arama : TIKDlgGenelAramaFrame read FArama write SetArama;
  end;


var
  IKListeDlg :TIKListeDlg;
  rehberdetayaktif : Boolean;
  SonAranan : Boolean;
  dene1,dene2 : string;

  procedure IzinSatirInsert(RehberId,Tur:integer; Miktar:Real; Tarih:TdateTime; Aciklama,Donem:string; Ekleme:Boolean);
  procedure IzinsureleriDoldur;
  procedure ButunPersonelinHakedilenIzinleriniEkle;

implementation

uses
  FetaUtil, UCombo, UAnaForm,UGirisKutusuEx,UKodAgaci,URehberBilgiDuzenle,
  FetaClassExtensions,FetaClassExtensionsConsts, PrjConst, UFastRap, UCariFonksiyonlar, UKasaWizard,
  UGenelAnaSekmeFrame, URaporAraclari, UGenSifre,UBekletme,UMaasListe, UGorevDlg,
  UReplikasyon, FetaKurulusSiniflari, UAcilisKaydi, UNakitDlg,UBinarySave,IdGlobalProtocols,
  UVardiyaTanimlariDlg,UFaturaKapama,LocOnFly, UIslistesi, UIKGorevFrame, UExceldenVeriAl,
  UResim;

{$R *.DFM}

var
  i,  Param, TabloNo :integer;
  s :string;
  ust:boolean;
  FieldTipi :TFieldType;
  GenotipIni :TIniFile;
  Fir, Yet, Kod, TFirma, TYet, TKod, C4 : string[100];
  YeniIzin,EkstreGorunsun, Potansiyel :boolean;
  GrupListe : TStringList;

procedure TIKListeDlg.RehEkranInit;
 var
  gf : TIKGorevFrame;
begin
  gf := TIKGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  Potansiyel := gf.FPotansiyel;

  EkstreGorunsun := Tablo.YetkiVarmi(340140,YetkiTur_Gorme);

  TabSheetEkstre.TabVisible := (not Potansiyel)and(EkstreGorunsun);
  TabSheetIlet.TabVisible:=Tablo.YetkiVarmi(340103,YetkiTur_Gorme);
  TabSheetIlgili.TabVisible :=Tablo.YetkiVarmi(340106,YetkiTur_Gorme);
  TabSheetOzluk.TabVisible := Tablo.YetkiVarmi(340110,YetkiTur_Gorme);
  TabSheetIsDeneyimi.TabVisible := Tablo.YetkiVarmi(340112,YetkiTur_Gorme);
  TabSheetMaas.TabVisible := (not Potansiyel)and(Tablo.YetkiVarmi(340115,YetkiTur_Gorme)) ;
  TabSheetDemirbas.TabVisible := (not Potansiyel)and(Tablo.YetkiVarmi(340128,YetkiTur_Gorme));
  TabSheetIzinBilgileri.TabVisible := (not Potansiyel)and(Tablo.YetkiVarmi(340118,YetkiTur_Gorme));
  TabSheetPDKS.TabVisible := (not Potansiyel)and(Tablo.YetkiVarmi(340125,YetkiTur_Gorme));
  TabSheetHareketler.TabVisible := (not Potansiyel)and(Tablo.YetkiVarmi(340130,YetkiTur_Gorme));
  tabYorumMedya.TabVisible := Tablo.YetkiVarmi(340135,YetkiTur_Gorme);
  tabSheetGorev.TabVisible := Tablo.YetkiVarmi(340145,YetkiTur_Gorme);

  TabSheetEkstre.Visible := TabSheetEkstre.TabVisible;
  TabSheetIlet.Visible := TabSheetIlet.TabVisible;
  TabSheetIlgili.Visible := TabSheetIlgili.TabVisible;
  TabSheetOzluk.Visible := TabSheetOzluk.TabVisible;
  TabSheetIsDeneyimi.Visible := TabSheetIsDeneyimi.TabVisible;
  TabSheetMaas.Visible :=  TabSheetMaas.TabVisible;
  TabSheetDemirbas.Visible := TabSheetDemirbas.TabVisible;
  TabSheetIzinBilgileri.Visible := TabSheetIzinBilgileri.TabVisible;
  TabSheetPDKS.Visible := TabSheetPDKS.TabVisible;
  TabSheetHareketler.Visible := TabSheetHareketler.TabVisible;
  tabYorumMedya.Visible := tabYorumMedya.TabVisible;
  tabSheetGorev.Visible := tabSheetGorev.TabVisible;


  IKGridViewSEKTOR.Visible := Potansiyel;
  if Potansiyel then begin
     IKGridViewGIRISTARIHI.Caption:='Baþvuru Tarihi';
     TabloNo := TabNo_IK_POTANSIYEL;
  end else begin
     IKGridViewGIRISTARIHI.Caption:='Giriþ Tarihi';
     TabloNo:=TabNo_IK;
  end;
  Rehber.Close;


  stringgrid1.Cells[0,0] := 'ID';
  stringgrid1.Cells[1,0] := GrupAdi;
  //PageControlSekme.Visible := False;
end;

function TIKListeDlg.EkranAdiAl: string;
begin
   Result := 'IKListeDlg';
end;

procedure TIKListeDlg.ResimDosyadanTusClick(Sender: TObject);
var
   i : SmallInt;
begin
   if Tablo.OpenPictureDialog1.Execute then begin
      for i := 0 to Tablo.OpenPictureDialog1.Files.Count-1 do
         ResimEkleme(Tablo.OpenPictureDialog1.Files[i], REHBER.FieldByName('ID').AsInteger, Tabno_Rehber, REHBER.FieldByName('ID').AsInteger);
      //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
      TabloYenile(TabResim, [REHBER.FieldByName('ID').AsInteger]);
   end;
end;

procedure TIKListeDlg.ResimDuzenleTusClick(Sender: TObject);
begin
   if TabRehberIlgili.State in [dsEdit, dsInsert] then
      TabRehberIlgili.Post
   else if TabRehberIlgili.IsEmpty then
      Exit;

   Tablo.ResimSihirbazBaslat(Tabno_Rehber,REHBER.Fields[0].AsInteger);
   TabloYenile(TabResim,[REHBER.Fields[0].AsInteger]);
end;

procedure TIKListeDlg.ResimYapistirTusClick(Sender: TObject);
begin
   ResimYapistir(TcxImage(logoresim), REHBER.FieldByName('ID').AsInteger, Tabno_Rehber, REHBER.FieldByName('ID').AsInteger);
   //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
   TabloYenile(TabResim, [REHBER.FieldByName('ID').AsInteger]);
end;

procedure TIKListeDlg.SetArama(const Value: TIKDlgGenelAramaFrame);
begin
  FArama := Value;
end;

procedure TIKListeDlg.SETarihBasPropertiesChange(Sender: TObject);
begin
   //TabloYenile(PERSONELIZIN, [REHBER.Fields[0].AsInteger, SETarihBas.Value, SETarihBit.Value]);
   PERSONELIZIN.SQL.Text := ' EXEC SP_Prg_IK_IzinEkstre  '+REHBER.Fields[0].AsString+','+SETarihBas.Text+','+SETarihBit.Text;
   TabloYenile(PERSONELIZIN,[]);
end;

procedure TIKListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TIKListeDlg.Sil1Click(Sender: TObject);
var
  i,Recordindex,ID,TUR,Kilitli,Planli:integer;
  Tarih: TDateTime;
begin
  Kilitli:=0;
  Planli:=0;
  if cxGridHareketler.DataController.GetSelectedCount > 0 then begin
    if Application.MessageBox(PChar(RDAksiyonSilinsinmi),PChar(Onay), MB_YESNO) = IDYES then begin
      for I := 0 to cxGridHareketler.DataController.GetSelectedCount - 1 do begin
        Recordindex := cxGridHareketler.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
        ID := cxGridHareketler.DataController.Values[Recordindex,cxGridHareketlerCEKID.Index];
        TUR    := cxGridHareketler.DataController.Values[Recordindex,cxGridHareketlerTUR.Index];
        Tarih  := cxGridHareketler.DataController.Values[Recordindex,cxGridHareketlerTARIH.Index];
        if (TUR in [10,11,12,13,14,15,16,17,21,22,23,24,25,28,29,31,32,33,34,35])or(TUR>2600) then begin
           begin
             if TUR in [11,15] then begin
               if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+IntToStr(ID)+' ',[],[]) then begin
                 Planli:=1;
               end else begin
                 Tablo.KasaSilmeIslemleri(ID, TUR);
               end;
             end else begin
               Tablo.KasaSilmeIslemleri(ID, TUR); //Kilit yok ise silsin.
             end;
           end;
        end else begin
          Tablo.KasaSilmeIslemleri(ID, TUR);
        end;
      end;
      PageControlSekmeChange(Self);
      if (Kilitli = 1) and (Planli=0) then
        Application.MessageBox(PChar(Kilitlibelgedeislemyapilmaz),PChar(Uyari),0)
      else if (Kilitli = 0) and (Planli=1) then
        Application.MessageBox(PChar(Planlibelgesilinmedi),PChar(Uyari),0)
      else if (Kilitli = 1) and (Planli=1) then
        Application.MessageBox(PChar(Kilitliveplanlibelgesilinemez),PChar(Uyari),0)
    end;
  end;


end;

procedure TIKListeDlg.SilGrupClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabGrup.Delete;
  end;
end;

procedure TIKListeDlg.SilTusClick(Sender: TObject);
begin
   Tablo.TablodanSorguAc(1,'select ISNULL(ROL.TY,0),R.ID from REHBER R inner join KULLANICI  K on R.ID = K.REHBERID'+
                           ' inner join  ROLLER ROL on K.ROLID = ROL.ID where R.ID='+REHBER.FieldByName('ID').asstring);
   if (not Tablo.Query1.IsEmpty)and(Tablo.Query1.Fields[0].AsBoolean=True) then
       raise Exception.Create(RDYoneticiKullaniciSilinemez)
   else if Pos('400.', REHBER.Fields[0].AsString)=1 then
         raise Exception.Create(RDKrediTanimiSilinemez)
   else if Pos('102.', REHBER.Fields[0].AsString)=1 then
         raise Exception.Create(RDBankaTanimiSilinemez);

  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'select top 1 ISLEMTARIHI,ID from KASA where REHBERID = '+ REHBER.FieldByName('ID').asstring;
     Tablo.Query1.Open;
     if not Tablo.Query1.IsEmpty then
        raise Exception.Create(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.Query1.Fields[0].AsDateTime)+RDPlanVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from FATBASLIK where REHBERID =  &SId', ['&SId'],[REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDFaturaVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from CEKLER where REHBERID =  &SId', ['&SId'],[REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDCekVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SENETLER where REHBERID =  &SId', ['&SId'],[REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDSenetVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from REHBERILETISIM where REHBERID =  &SId', ['&SId'],[REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDiletisimBigisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from PERS_HAREKET where REHBERID =  &SId and TUR<>1', ['&SId'],[REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDPersonelBigisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from REHBER where grup=334 and BAGID =  &SId', ['&SId'],[REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDPersonelBigisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from BANKAHESAPLAR where REHBERID =  &SId', ['&SId'],[REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDBankaVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from IMAJ where DURUM = 1 and YERI=&yeri and YER_ID=&yer_id ', ['&yeri','&yer_id'],[ TabNo_REHBER, REHBER.FieldByName('ID').asstring]) then
        raise Exception.Create(RDDokumanVerisiVarSilinemez);

    //?LET??? S?L ME !!!!!!!!!!!!!!!!!!
    //Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=1 and YER_ID=&id ',['&id'],[REHBER.Fields[0].AsInteger]);
    //ticari sil
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from KULLANICI where REHBERID=&id ',['&id'],[REHBER.Fields[0].AsInteger]);
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=2 and YER_ID=&id ',['&id'],[REHBER.Fields[0].AsInteger]);
    //kendisini sil
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBER where ID=&id ',['&id'],[REHBER.Fields[0].AsInteger]);
     //GENINI' den sil
    for I := 54 to 69 do begin       ///-10054...-10069 yedekleme ops aras?.bu aradakiler silinir.
      if Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM ='+'-100'+IntToStr(i)+REHBER.Fields[0].AsString+'  ',[],[]) then
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from GENINI where BOLUM ='+'-100'+IntToStr(i)+REHBER.Fields[0].AsString+'  ',[],[]);
    end;

    if LogGun>0 then
     Tablo.OncekiLogBelirle(REHBER);
     Tablo.LogIslemleri(TabNo_REHBER,REHBER.FieldByName('ID').AsInteger, 5, REHBER);
     LogOnceki.Clear;
    //REHBER.Close;
    //REHBER.open;
    TabloYenile(REHBER,[]);
  end;
end;

procedure TIKListeDlg.SSKBalama1Click(Sender: TObject);
var Tarih : Variant;
    Trh:TDateTime;
begin
   Tarih:=Tablo.GENINI.BugunTrh;
   if TGirisKutusuEx.BilgiAlEx(BGTarih_gir, TGirdiDenetimleri.Create.DateTimePicker(BGTarih_gir+':', @Tarih,dtkDate)) = mrOk then begin
      Trh := TDateTime(Tarih);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into [PERS_HAREKET] (REHBERID,TARIH,TUR,ACIKLAMA)values(&REHBERID,'''+FormatDateTime('yyyy-mm-dd', Trh)+''' ,&TUR,&ACIKLAMA)'
          ,['&REHBERID','&TUR','&ACIKLAMA'], [REHBER.FieldByName('ID').AsInteger,5, '']);
      PageControlSekmeChange(Self);
   end;
end;

procedure TIKListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TIKListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TIKListeDlg.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;


procedure TIKListeDlg.VarsaylanYap1Click(Sender: TObject);
begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Update REHBERILETISIM Set VARSAYILAN=0 Where AKTIF=1 and REHBERID=&RehID',['&RehID'],[REHBER.FieldByName('ID').AsInteger]);
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Update REHBERILETISIM Set VARSAYILAN=1 Where AKTIF=1 and REHBERID=&RehID and ID=&IletID',['&RehID','&IletID'],[REHBER.FieldByName('ID').AsInteger,REHBERILETISIM.FieldByName('ID').AsInteger]);
    TabloYenile(REHBERILETISIM,[REHBER.FieldByName('ID').AsInteger]);
    GridRehberIletisimView.DataController.FocusedRecordIndex:=0;
    GridRehberIletisimView.ViewData.Records[0].Selected:=True;
end;

procedure TIKListeDlg.TabDilNewRecord(DataSet: TDataSet);
begin
    TabDil.FieldByName('REHBERID').AsInteger := REHBER.FieldByName('ID').AsInteger;
end;

procedure TIKListeDlg.TabHareketlerAfterScroll(DataSet: TDataSet);
begin
   TabHareketler.FetchAll;
   TBtnHareketlerSil.Enabled := TabHareketler.RecNo=TabHareketler.RecordCount;
end;

procedure TIKListeDlg.TabIsDeneyimiAfterOpen(DataSet: TDataSet);
begin
   DeneyimSilTus.Visible   := not TabIsDeneyimi.IsEmpty;
end;

procedure TIKListeDlg.TabIsDeneyimiCalcFields(DataSet: TDataSet);
begin
   if (TabIsDeneyimi.FieldByName('IL').AsString<>'')and(TabIsDeneyimi.FieldByName('ILCE').AsString<>'') then begin
       Tablo.TablodanSorguAc(0,'select * from ILILCE where  ILNO='+TabIsDeneyimi.FieldByName('IL').AsString +' and ILCENO='+TabIsDeneyimi.FieldByName('ILCE').AsString);
    //   if Tablo.Query0.Fields[1].AsInteger<500 then
          TabIsDeneyimi.FieldByName('ILAD').AsString := Tablo.Query0.Fields[2].AsString;
    //   else
          TabIsDeneyimi.FieldByName('ILCEAD').AsString := Tablo.Query0.Fields[3].AsString;
   end;
end;

procedure TIKListeDlg.TabIsDeneyimiNewRecord(DataSet: TDataSet);
begin
   TabIsDeneyimi.FieldByName('REHBERID').Value := REHBER.FieldByName('ID').Value;
   TabIsDeneyimi.FieldByName('UCRET_ALT').Value := 0;
   TabIsDeneyimi.FieldByName('UCRET_UST').Value := 0;
end;

procedure TIKListeDlg.TabPersonelIzinBeforePost(DataSet: TDataSet);
begin
  case PERSONELIZIN.State of
    dsEdit: begin
       PERSONELIZIN.FieldByName('DEGISTIREN').AsString := Kullanan;
       PERSONELIZIN.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    end;
    dsInsert: begin
       PERSONELIZIN.FieldByName('EKLEYEN').AsString := Kullanan;
    end;
  end;
end;

procedure TIKListeDlg.PERSONELIZINAfterPost(DataSet: TDataSet);
begin
  PERSONELIZIN.Close;
  PERSONELIZIN.Open;
end;

procedure TIKListeDlg.PERSONELIZINNewRecord(DataSet: TDataSet);
begin
  PERSONELIZIN.FieldByName('IZINVERENREHBERID').Value := Kullanan;
  PERSONELIZIN.FieldByName('REHBERID').AsInteger := REHBER.FieldByName('ID').AsInteger;
  PERSONELIZIN.FieldByName('SUBEID').AsInteger := SubeID;
  PERSONELIZIN.FieldByName('DONEM').value  := StrToInt(FormatDateTime('yyyy', Tablo.GENINI.BugunTrh));
end;

procedure TIKListeDlg.REHBERAfterOpen(DataSet: TDataSet);
begin
   rehberdetayaktif:=True;
   DegisTus.Visible   := not REHBER.IsEmpty;
   SilTus.Visible := DegisTus.Visible;
   if AksiyonEkleTus.tag <> 99 then //g?rme yetkisivarsa
      AksiyonEkleTus.Visible := DegisTus.Visible;
end;

procedure TIKListeDlg.REHBERAfterScroll(DataSet: TDataSet);
begin
  if PageControlSekme.ActivePage=nil then
     PageControlSekme.ActivePageIndex := 0;
end;

procedure TIKListeDlg.TabRehberIlgiliAfterOpen(DataSet: TDataSet);
begin
   IlgiliDuzenleTus.Visible := not TabRehberIlgili.IsEmpty;
   IlgiliSilTus.Visible := IlgiliDuzenleTus.Visible;
end;

procedure TIKListeDlg.TahakkukYeniTusClick(Sender: TObject);
begin
  if Tablo.IKSihirbazBaslat(5, REHBER.Fields[0].AsInteger, -100, REHBER.Fields[0].AsInteger, False) > 0 then
     PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.TamamlandiIsaretleMenuClick(Sender: TObject);
begin
//Ad   Menu_Tamam(Sender, GorevGridDBTableView1);
   PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.TBtnHareketDuzenleClick(Sender: TObject);
begin
  if RehberPersonelHareket = nil then
     Application.CreateForm(TRehberPersonelHareket,RehberPersonelHareket);
  if not RehberPersonelHareket.Active then
     RehberPersonelHareket.Close;

  TabloYenile(RehberPersonelHareket.TabHareket,[REHBER.Fields[0].AsInteger,TabHareketler.Fields[0].AsInteger]);
  //RehberPersonelHareket.DoldurmaTuru := 3;
  RehberPersonelHareket.ShowModal;
  if RehberPersonelHareket.ModalResult = mrOk then
     TabloYenile(TabHareketler,[REHBER.Fields[0].AsInteger]);
  FreeAndNil(RehberPersonelHareket);
end;

procedure TIKListeDlg.TBtnHareketIptalClick(Sender: TObject);
begin
  if not TabHareketler.Active then Abort;
  TabHareketler.Cancel;
end;

procedure TIKListeDlg.TBtnHareketKaydetClick(Sender: TObject);
begin
  if not TabHareketler.Active then Abort;
  TabHareketler.Post;
end;

procedure TIKListeDlg.TBtnHareketlerEkleClick(Sender: TObject);
var  ROLID : Integer;
     Tarih,ACIKLAMA : Variant;
     Trh:TDateTime;
begin
  ROLID := Tablo.RolAra_IDGetir;
  if ROLID <> -99 then begin
     Tarih:=Tablo.GENINI.BugunTrh;
     if TGirisKutusuEx.BilgiAlEx(BGTarih_gir, TGirdiDenetimleri.Create.DateTimePicker(BGTarih_gir+':', @Tarih,dtkDate).Edit(BGAciklama_gir +':' , @ACIKLAMA)) = mrOk then begin
        Trh := TDateTime(Tarih);

        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update REHBER set SINIF='+IntToStr(ROLID)+',SUBEID='+Tablo.AciklamaGetir('ROLLER', 'SUBEID', ROLID)+' where ID='+REHBER.FieldByName('ID').AsString,[],[]);

{        Tablo.TablodanSorguAc(1,'select SUBEID=(select FIRMA from REHBER where ID=ROL.SUBEID),'+
        ' DEPARTMAN=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 ),'+
        ' GOREV=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 ) '+
        ' from ROLLER ROL where ROL.ID='+IntToStr(ID)); }
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into [PERS_HAREKET] (REHBERID,TARIH,TUR,ROLID,ACIKLAMA)values(&REHBERID,'''+FormatDateTime('yyyy-mm-dd', Trh)+''' ,&TUR, &ROLID, &ACIKLAMA)'
          ,['&REHBERID', '&TUR', '&ROLID', '&ACIKLAMA'], [REHBER.FieldByName('ID').AsInteger,2, ROLID, VarToStr(ACIKLAMA)]);

        PageControlSekmeChange(Self);
        TabloYenile(REHBER,[0]);
     end;
  end;
end;

procedure TIKListeDlg.TBtnHareketlerSilClick(Sender: TObject);
begin
  if not TabHareketler.Active then Abort;
  if LogGun > 0 then
  Tablo.OncekiLogBelirle(TabHareketler);
  if gridPersonelHareketlerDBTableView1.DataController.Controller.SelectedRecordCount > 0 then
  begin
    if Application.MessageBox(PWideChar(PrjConst.RAEPersonelHareketiSilme),PWideChar(PrjConst.Onay),MB_ICONQUESTION+MB_YESNO) = IDYES then
    if not TabHareketler.FieldByName('ID').IsNullOrEmpty then
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'DELETE FROM PERS_HAREKET WHERE ID=&ID',['&ID'],[TabHareketler.FieldByName('ID').AsString]);
    Tablo.LogIslemleri(TabNo_REHBERPERSONELHAREKET,TabHareketler.FieldByName('ID').AsInteger,5,TabHareketler);
    TabloYenile(TabHareketler,[REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TIKListeDlg.TicariDuzenleTusClick(Sender: TObject);
begin
  if Tablo.RehberSihirbazBaslat(2, REHBER.Fields[0].AsInteger,-1, -1, False)>0 then
    //TicariBilgisi(REHBER.FieldByName('ID').AsInteger);
    PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.ButtonKartNoClick(Sender: TObject);
var
  Sonuc:Variant;
  BilgiAlBaslik,GenIniAnahtar,GenIniDeger:string;
  RehberID:Integer;
  KayitBulundu:Boolean;
begin
  RehberID := REHBER.Fields[0].AsInteger;
  Tablo.TablodanSorguAc(1,'SELECT * FROM GENINI WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_GirisTurleri));
  Tablo.Query1.First;

  if Tablo.Query1.IsEmpty then
  begin
    ShowMessage(IKKayit_bulunamadi);
    Exit;
  end;

  while not Tablo.Query1.Eof do
  begin
    KayitBulundu := False;
    GenIniAnahtar := Tablo.Query1.FieldByName('ANAHTAR').AsString;
    BilgiAlBaslik := Concat(GenIniAnahtar,BGBilgisini_gir);
    Tablo.TablodanSorguAc(2,'SELECT * FROM REHBERBILGI WHERE YERI=11 AND SIRA=10 AND ETIKET='''+GenIniAnahtar+''' AND YER_ID='+IntToStr(RehberID));
    if not Tablo.Query2.IsEmpty then
    begin
      Sonuc := Tablo.Query2.FieldByName('BILGI').AsString;
      if TGirisKutusuEx.BilgiAlEx(BilgiAlBaslik,TGirdiDenetimleri.Create.Edit(GenIniAnahtar,@Sonuc)) = mrOk then
      begin
        Tablo.TablodanSorguAc(3,'SELECT * FROM REHBERBILGI WHERE SIRA=10 AND YERI=11 AND BILGI='''+Sonuc+'''');
        Tablo.Query3.First;
        while not Tablo.Query3.Eof do
        begin
          if (Tablo.Query3.FieldByName('YER_ID').AsInteger <> RehberID) and (not Tablo.Query3.FieldByName('BILGI').IsNullOrEmpty) then
          begin
            KayitBulundu := True;
          end;
          Tablo.Query3.Next;
        end;
        if not KayitBulundu then
        begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,
          'UPDATE REHBERBILGI SET BILGI=&BILGI,DEGISTIREN=&DEGISTIREN,DEGISTIRMETARIHI=&DEGISTIRMETARIHI WHERE YER_ID=&YER_ID AND SIRA=10 AND YERI=11 AND ETIKET='''+GenIniAnahtar+'''',
          ['&BILGI','&DEGISTIREN','&DEGISTIRMETARIHI','&YER_ID'],
          [Sonuc,Kullanan,FormatDateTime('yyyy-MM-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat),RehberID]);
        end
        else
        begin
          ShowMessage(CRIslem_basarisiz_eslesen_kayit_bulundu);
          Exit;
        end;
      end;
    end
    else
    begin
      Sonuc := '';
      if TGirisKutusuEx.BilgiAlEx(BilgiAlBaslik,TGirdiDenetimleri.Create.Edit(GenIniAnahtar,@Sonuc)) = mrOk then
      begin
        Tablo.TablodanSorguAc(3,'SELECT * FROM REHBERBILGI WHERE SIRA=10 AND YERI=11 AND BILGI='''+Sonuc+'''');
        Tablo.Query3.First;
        while not Tablo.Query3.Eof do
        begin
          if (Tablo.Query3.FieldByName('YER_ID').AsInteger <> RehberID) and (not Tablo.Query3.FieldByName('BILGI').IsNullOrEmpty) then
          begin
            KayitBulundu := True;
          end;
          Tablo.Query3.Next;
        end;
        if not KayitBulundu then
        begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,
          'INSERT INTO REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI) VALUES(11,&IDYER,10,&ETIKET,&BILGI,&EKLEYEN,&EKLEMETARIHI)',
          ['&IDYER','&ETIKET','&BILGI','&EKLEYEN','&EKLEMETARIHI'],
          [RehberID,GenIniAnahtar,Sonuc,Kullanan,FormatDateTime('yyyy-MM-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)]);
        end
        else
        begin
          ShowMessage(CRIslem_basarisiz_eslesen_kayit_bulundu);
          Exit;
        end;
      end;
    end;
    Tablo.Query1.Next
  end;
end;

procedure TIKListeDlg.ButtonVardiyaTuruClick(Sender: TObject);
var
  TurAdi:Variant;
  Ctrls:TGirdiDenetimleri;
  RehberID:Integer;
begin
  if not REHBER.FieldByName('ID').IsNullOrEmpty then
  begin
    RehberID := REHBER.FieldByName('ID').AsInteger;

    Tablo.TablodanSorguAc(4,'SELECT BILGI FROM REHBERBILGI WHERE SIRA=21 AND YERI=21 AND YER_ID='+IntToStr(RehberID));
    if not Tablo.Query4.IsEmpty then TurAdi := Tablo.Query4.Fields[0].AsString
    else TurAdi := 'Sabit Vardiya';

    Ctrls := TGirdiDenetimleri.Create.ComboBox('Vardiya Türü : ',@TurAdi,
    Tablo.ComboboxInit('Select ANAHTAR from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(Ops_OpsiyonCari_VardiyaTur)).items);

    if TGirisKutusuEx.BilgiAlEx(BGVardiya_Tur_Sec,Ctrls) <> mrOk then Abort;

    Tablo.TablodanSorguAc(1,'SELECT * from REHBERBILGI WHERE SIRA=21 AND YERI=21 AND YER_ID='+IntToStr(RehberID));
    if not Tablo.Query1.IsEmpty then
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE REHBERBILGI SET BILGI=&BILGI, DEGISTIREN=&DEGISTIREN, DEGISTIRMETARIHI=GETDATE() '+
      'WHERE YER_ID=&YERID AND SIRA=21 AND YERI=21',['&YERID','&BILGI','&DEGISTIREN'],[RehberID,TurAdi,Kullanan])
    else
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO REHBERBILGI (YER_ID, BILGI, SIRA, YERI, EKLEYEN, EKLEMETARIHI)'+
      ' VALUES(&YER_ID, &BILGI, &SIRA, &YERI, &EKLEYEN, GETDATE())',
      ['&YER_ID','&BILGI','&SIRA','&YERI','&EKLEYEN'],[RehberID,TurAdi,21,21,Kullanan]);
  end
  else
  begin
    raise Exception.Create(CRKart_bulunamadi);
  end;
end;

procedure TIKListeDlg.BtnDuzenlePerizinClick(Sender: TObject);
  procedure ilkSatirinsert(Miktar :Real;Tarih:TdateTime;Aciklama,Donem:string;IzinID:Integer);
  var
    Tur:Integer;
    izinliGunSayisi:Real;
  begin
    if FormatSettings.DateSeparator='.' then begin
     Tarih := StrToDateTime(StringReplace(DateTimeToStr(Tarih),'/',FormatSettings.DateSeparator,[rfReplaceAll]));
    end else begin
     Tarih := StrToDateTime(StringReplace(DateTimeToStr(Tarih),'.',FormatSettings.DateSeparator,[rfReplaceAll]));
    end;

    Tur := Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'SELECT IZINTURU FROM PERSONELIZIN WHERE ID=&ID',['&ID'],[IzinID],True);

    Tablo.Query6.Close;
    Tablo.Query6.SQL.Text := 'UPDATE PERSONELIZIN SET  IZINLIGUNSAYISI=:IZINLIGUNSAYISI, IZINBASLANGIC=:IZINBASLANGIC, ACIKLAMA=:ACIKLAMA,'+
                             'HAK=:HAK, IZINVERENREHBERID=:IZINVERENREHBERID, IZINBITIS=:IZINBITIS,DONEM=:DONEM, DEGISTIREN=:DEGISTIREN, '+
                             'DEGISTIRMETARIHI=:DEGISTIRMETARIHI WHERE ID='+IntToStr(IzinID);
    izinliGunSayisi := 0;
    Tablo.Query6.ParamByName('ACIKLAMA').Value := Aciklama;
    if Tur = -1 then begin
     Tablo.Query6.ParamByName('HAK').Value := Miktar;
     izinliGunSayisi:=0;
    end else begin
     Tablo.Query6.ParamByName('HAK').Value :=0;
     izinliGunSayisi := Miktar;
    end;
    Tablo.Query6.ParamByName('IZINLIGUNSAYISI').Value := izinliGunSayisi;
    Tablo.Query6.ParamByName('IZINBASLANGIC').Value := Tarih;
    Tablo.Query6.ParamByName('IZINVERENREHBERID').Value := Kullanan;
    Tablo.Query6.ParamByName('IZINBITIS').value := (Tarih) + izinliGunSayisi;
    Tablo.Query6.ParamByName('DONEM').value := Donem;
    Tablo.Query6.ParamByName('DEGISTIREN').value := Kullanan;
    Tablo.Query6.ParamByName('DEGISTIRMETARIHI').value := Tablo.GENINI.BugunTrh;
    Tablo.Query6.ExecSQL;
    PERSONELIZIN.Close;
    PERSONELIZIN.Open;
  end;
var
  ctrls:TGirdiDenetimleri;
  Hakedilen,izinTarihi,Aciklama, Donemx: Variant;
  Tipi:string;
  IzinID : Integer;
  IzinBaslangic : TDateTime;
begin
  if PERSONELIZIN.Active and (not PERSONELIZIN.IsEmpty) then
  begin
    Donemx:= PERSONELIZIN.FieldByName('DONEM').AsString;;
    Tipi := PERSONELIZIN.FieldByName('TUR').AsString;
    IzinID := PERSONELIZIN.FieldByName('ID').AsInteger;
    izinTarihi := PERSONELIZIN.FieldByName('IZINBASLANGIC').AsDateTime;
    Aciklama := PERSONELIZIN.FieldByName('ACIKLAMA').AsString;
    Hakedilen := PERSONELIZIN.FieldByName('IZINLIGUNSAYISI').AsString;

    if PERSONELIZIN.FieldByName('IZINTURU').AsInteger = -1 then
      Hakedilen := PERSONELIZIN.FieldByName('HAK').AsInteger
    else Hakedilen := PERSONELIZIN.FieldByName('IZINLIGUNSAYISI').AsInteger;


    ctrls := TGirdiDenetimleri.Create.Edit(Tipi+' Dönem',@Donemx).DateTimePicker(BGIzin_tarih_gir,@izinTarihi).Edit(Tipi+'BGGun_miktari_gir',@Hakedilen).Edit('Açýklama',@Aciklama);
    if TGirisKutusuEx.BilgiAlEx(Tipi+BGIzin_bilgi_gir, ctrls) = mrOk then begin
       Hakedilen:=StringReplace(VarToStr(Hakedilen),',',FormatSettings.Decimalseparator,[rfReplaceAll]);
       Hakedilen:=StringReplace(VarToStr(Hakedilen),'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
       Donemx := IntToStr(StrToIntDef( VarToStr(Donemx),1));
       if not Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from PERSONELIZIN Where REHBERID='+REHBER.FieldByName('ID').AsString+' and IZINTURU = 1 and BIRIM = 3 and IZINLIGUNSAYISI = 0 and DONEM='+VarToStr(Donemx)+' ',[],[]) then begin
          if (Hakedilen > 0) then
              ilkSatirinsert(Hakedilen,izinTarihi,Aciklama,VarToStr(Donemx),IzinID)
          else begin
              Application.MessageBox(PChar(Tipi+IKSifirdan_buyuk),Pchar(Uyari),0);
              Abort;
          end;
      end else
        Application.MessageBox(Pchar(Tipi+IKDolu_alan),Pchar(Uyari),0);
    end;
  end;
end;

procedure TIKListeDlg.BtnGrupKisiEkleClick(Sender: TObject);
var i : Integer;
    ID : String[15];
    Kullanicilar:TstringList;
begin
    Kullanicilar := TStringlist.Create;
    Kullanicilar := Tablo.ListedenCokluSecim('',SQLKullan.text,[nil,nil,nil,nil,nil,nil,nil],
                                               ['Id','Ad','Görev','Departman','þube','Kategori','Tür']);
    for I := 0 to Kullanicilar.Count - 1 do begin
         StringGrid1.RowCount := StringGrid1.RowCount + 1;
         ID := copy(Kullanicilar[i],2,8);
         stringgrid1.Cells[0,StringGrid1.RowCount-1] := ID;
         stringgrid1.Cells[1,StringGrid1.RowCount-1] := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
         GrupListe.Add(ID);
         veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update [REHBER] set NOTLAR='''+GrupListe.DelimitedText+''' where ID='+TabGrup.Fields[0].AsString,[],[]);
    end

   {ID := Tablo.RehberAra_IDGetir(335);
   if ID > 0 then begin
         StringGrid1.RowCount := StringGrid1.RowCount + 1;
         stringgrid1.Cells[0,StringGrid1.RowCount-1] := IntToStr(ID);
         stringgrid1.Cells[1,StringGrid1.RowCount-1] := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
         GrupListe.Add(IntToStr(ID));
         veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update [REHBER] set NOTLAR='''+GrupListe.DelimitedText+''' where ID='+TabGrup.Fields[0].AsString,[],[]);
   end}
end;

procedure TIKListeDlg.BtnGrupKisiSilClick(Sender: TObject);
var Index : integer;
    procedure DeleteRow(Grid: TStringGrid; ARow: Integer);
    var
      i: Integer;
    begin
      for i := ARow to Grid.RowCount - 2 do
        Grid.Rows[i].Assign(Grid.Rows[i + 1]);
      Grid.RowCount := Grid.RowCount - 1;
    end;
begin                              // PChar(SSilmeSorusu)
   if StringGrid1.Row = 0 then exit;
   if Application.MessageBox(PChar(stringgrid1.Cells[0,StringGrid1.Row]+' listeden çýkarýlacak..'), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
       GrupListe.Find(stringgrid1.Cells[0,StringGrid1.Row],Index);
       GrupListe.Delete(Index);
       veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update [REHBER] set NOTLAR='''+GrupListe.DelimitedText+''' where ID='+TabGrup.Fields[0].AsString,[],[]);
       DeleteRow(StringGrid1, stringgrid1.Row);
   end;
end;

procedure TIKListeDlg.BtnMesajGonderClick(Sender: TObject);
begin
   Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  TabloNo, REHBER.FieldByName('ID').AsInteger,REHBER.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TIKListeDlg.BtnPirimClick(Sender: TObject);
begin
  Application.CreateForm(TPirimDlg,PirimDlg);
  PirimDlg.RehberID := REHBER.Fields[0].AsInteger;
  PirimDlg.ShowModal;
  FreeAndNil(PirimDlg);
end;

procedure TIKListeDlg.ButtonVardiyalarClick(Sender: TObject);
var
  VardiyaTuru :String;
begin
  Tablo.TablodanSorguAc(1,'SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=3 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID='+REHBER.FieldByName('ID').AsString+' AND RA.VARSAYILAN=91 ');
  if Tablo.Query1.IsEmpty then begin
     VardiyaTuru:='Sabit'
  end else  begin
     if Tablo.Query1.FieldByName('BILGI').AsString = 'Sabit' then
        VardiyaTuru:='Sabit'
     else
        VardiyaTuru:='Deðiþken';
  end;

  Application.CreateForm(TVardiyaTanimlariDlg, VardiyaTanimlariDlg);
  VardiyaTanimlariDlg.RehberId := REHBER.FieldByName('ID').AsInteger;
  VardiyaTanimlariDlg.VardiyaTuru := VardiyaTuru;
  VardiyaTanimlariDlg.ShowModal;
  VardiyaTanimlariDlg.Free;

  { Vardiya Tür? eklenirken izlenecek yol

  //RehberAyar tablosuna eklenecek bilgiler.
   Etiket = 'Vardiya Tür?'
   Kaynak=Select '' as ANAHTAR,3 as DEGER  union Select 'Sabit',1 union Select 'Deðiþken',2
  }
end;

procedure TIKListeDlg.TreeListGorevClick(Sender: TObject);
var   TreeHitTest: TcxTreeListHitTest;
begin
     TreeHitTest := (Sender as TcxDBTreeList).HitTest;
     if not TreeHitTest.HitAtColumn  then // soldaki + alt seviye açma tuþuna bastýðýnda açma/kapatma yapmasýn diye
        exit;


   if TcxDBTreeList(Sender).FocusedColumn.tag=1 then begin
      UpdateveMail(MasaUstu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, TcxDBTreeList(Sender).FocusedNode.HasChildren);
      PlayWavFromResource('Blink');
      PageControlSekmeChange(Self);
  end;
  Abort;//Bunu kesinlikle silme (listede tek sat?r kal?nca hata verdi?i i?in eklendi)
end;

procedure TIKListeDlg.TreeListGorevDblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TIKListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
  SonAranan :=True;
  REHBER.Close;


  if Potansiyel then
      REHBER.SQL.Text:= StringReplace(SQL_IK_Aday.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll])
  else
      REHBER.SQL.Text:= StringReplace(SQL_IK_Memo.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll]);;

  if SubeVarmi then
     REHBER.SQL.Add(' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ');
//  REHBER.SQL.Add(' order by '+tcxLabel(sender).HelpKeyword+' desc');
//  if FArama.AraYetkili.Text <> '' then
//     Param := 1
//  else
     Param := 0;
  //REHBER.open;
  TabloYenile(REHBER,[Param]);
  SonAranan:=False;
end;

procedure TIKListeDlg.LabelStandartAvansDblClick(Sender: TObject);
var
  OdemeKaynagi,Tutar:Variant;
  RehberID:string;
  mResult:TModalResult;
begin
  RehberID := REHBER.FieldByName('ID').AsString;
  Tablo.TablodanSorguAc(1,'SELECT * FROM dbo.PLANMAAS WHERE YER=61 AND YERID='+RehberID);
  if not Tablo.Query1.IsEmpty then
  begin
    OdemeKaynagi := Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'SELECT TOP 1 TUR FROM PLANMAAS WHERE YER=61 AND YERID=&YERID',['&YERID'],[RehberID],True);
    Tutar := Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'SELECT TOP 1 TUTAR FROM PLANMAAS WHERE YER=61 AND YERID=&YERID',['&YERID'],[RehberID],True);
    mResult := TGirisKutusuEx.BilgiAlEx(BGAvans_miktari,TGirdiDenetimleri.Create
    .ImageComboBox('ödeme kaynaðý',@OdemeKaynagi,Tablo.FDCnn,'SELECT ''B'' TUR, ''Banka'' ADI UNION ALL SELECT ''K'' TUR, ''Kasa''')
    .CurrencyEdit('ödenecek avans miktarý',@Tutar,2));

    if mResult = mrOk then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE PLANMAAS SET TUTAR=&TUTAR, DEGISTIREN=&DEGISTIREN,'+
      ' DEGISTIRMETARIHI=GETDATE(),TUR=&TUR WHERE YER=61 AND YERID=&YERID',
        ['&TUTAR','&YERID','&DEGISTIREN','&TUR'], [FCurrToStr(Tutar),RehberID,Kullanan,OdemeKaynagi]);
      LabelStandartAvans.Caption := FCurrToStr(Tutar) + ' ' + CariDoviz;
    end;
  end else begin
    Tutar := 0;
    OdemeKaynagi := 'K';
    mResult := TGirisKutusuEx.BilgiAlEx(BGAvans_miktari,TGirdiDenetimleri.Create
    .ImageComboBox('ödeme kaynaðý',@OdemeKaynagi,Tablo.FDCnn,'SELECT ''B'' TUR, ''Banka'' ADI UNION ALL SELECT ''K'' TUR, ''Kasa''')
    .CurrencyEdit('Avans tutarý',@Tutar,2));

    if mResult = mrOk then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO PLANMAAS (TUTAR,YER,YERID,KUR,TUR,EKLEYEN,EKLEMETARIHI)'+
        ' VALUES(&TUTAR,61,&YERID,&KUR,&TUR,&EKLEYEN,GETDATE())',
        ['&TUTAR','&YERID','&KUR','&TUR','&EKLEYEN'], [FCurrToStr(Tutar),RehberID,CariDoviz,OdemeKaynagi,Kullanan]);
      LabelStandartAvans.Caption := FCurrToStr(Tutar) + ' ' + CariDoviz;;
    end;
  end;
end;

procedure TIKListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
  REHBER.Close;
  if Potansiyel then
      REHBER.SQL.Text:= StringReplace(SQL_IK_Aday.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll])
  else
      REHBER.SQL.Text:= StringReplace(SQL_IK_Memo.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll]);;
  if not FArama.CheckPasifler.Checked then
     REHBER.SQL.Add(' and R.DURUM>0 ');
  if SubeVarmi then
     REHBER.SQL.Add(' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ');
  REHBER.SQL.Add(' order by 1');
//  if FArama.AraYetkili.Text <> '' then
//     Param := 1
//  else
     Param := 0;
  //REHBER.open;
  TabloYenile(REHBER,[Param]);
end;

procedure TIKListeDlg.letiimaddeitir1Click(Sender: TObject);
var EtiAdi : Variant;
begin
   EtiAdi := REHBERILETISIM.FieldByName('AD').AsString;
   if  TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
       TGirdiDenetimleri.Create.Edit(IletisimAdiniGirin,@EtiAdi)) = mrOK then begin
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Update REHBERILETISIM Set AD='''+EtiAdi+''' Where AKTIF=1 and REHBERID=&RehID and ID=&IletID',['&RehID','&IletID'],[REHBER.FieldByName('ID').AsInteger,REHBERILETISIM.FieldByName('ID').AsInteger]);
       PageControlSekmeChange(nil);
       REHBERILETISIM.Locate('ID',REHBERILETISIM.FieldByName('ID').Value,[]);
   end;
end;

procedure TIKListeDlg.AraTusClick(Sender :TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 750;
  JvTimer1.Enabled := True;
end;

procedure TIKListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   fb : TIcerikFrameBilgi;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);

   AFastReport.EnabledDataSets.Clear;

   if (EkstreGorunsun)and(pos('EKSTRE', UpperCase(DokumAdi))>0)  then begin//ekstre ise
      if not TabCariListe.Active then begin
         CalendarEkstreBasPropertiesChange(Self);
      end;
      DokumDegiskenListesi.Add(KontrolBaslangisTarihi+'$@$'+DateToStr(CalendarEkstreBas.Date));
      DokumDegiskenListesi.Add(KontrolBitisTarihi+'$@$'+DateToStr(CalendarEkstreBit.Date));
      AFastReport.EnabledDataSets.Add(frxEkstre);
   end
   else if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxRehber) then begin
      AFastReport.EnabledDataSets.Add(frxREHBER);
      if (PageControlSekme.ActivePage = TabSheetIzinBilgileri) then
          AFastReport.EnabledDataSets.Add(frxPersonelIzin)
   end else begin
      frxREHBER.DataSet := REHBER;
      AFastReport.EnabledDataSets.Add(frxREHBER);
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TIKListeDlg.DeneyimEkleTusClick(Sender: TObject);
begin
   TabIsDeneyimi.Append;
end;

procedure TIKListeDlg.BankaTusClick(Sender: TObject);
var Tur:char;
    ID:Integer;
begin
  Tablo.TablodanSorguAc(5, 'SELECT top 1 BH.ID,VARSAYILAN, BS.BANKAKODU, BANKAADI,SUBEKODU,SUBEADI,LOGO,HESAPNO,HESAPADI,IBAN,'+
  'KUR,TIPI,HESAPACIKLAMA,DURUM '+
  'FROM BANKAHESAPLAR BH '+
	'inner join BANKASUBELER BS on BS.ID = BH.BANKASUBELERID '+
	'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU '+
  'WHERE REHBERID  = '+REHBER.Fields[0].AsString);
  if not Tablo.Query5.IsEmpty then begin
     Tur := 'D';
     ID:=Tablo.Query5.Fields[0].AsInteger;
  end else begin
     Tur := 'E';
     ID:=-1;
  end;
  Tablo.BankaTanimSihirbazBaslat(Tur, 1, ID, REHBER.Fields[0].AsInteger);
end;

procedure TIKListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   if REHBER.Active then begin
      s := YaziciYaz.Caption;
      Delete(s, pos('&',s), 1);
      YazdirmayaHazirla(FastRaporDlg.frxReport1);
      FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
   end;
end;

procedure TIKListeDlg.Baslatildi;
var ra : string;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   IKGridViewSUBEID.Visible := SubeVarmi;
   Tablo.GridAyarRestore('PersonelOZGridi',GridPerTemelView );
   Tablo.GridAyarRestore('PersDemirbasGridi', GridDemirbasView);
   Tablo.GridAyarRestore('PersIzinGridi',GridIzinListeDBTableView1 );
   Tablo.GridAyarRestore('IKIsDeneyimiGridi',GridIKDeneyimView );
   Tablo.GridAyarRestore('RehberEkstreHareket',cxGridHareketler );
   Tablo.GridAyarRestore('IKListeGridi',IKGridView );
//   Tablo.GridAyarRestore('IsListesiGridi_IK', GorevGridDBTableView1);

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

   PageControlSekme.ActivePageIndex := 0;


   Tablo.GridTurkcelestir;

   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;
   if not Tablo.YetkiVarmi(MODUL_Kasa,YetkiTur_Gorme) then begin
     AksiyonEkleTus.Visible:=False;
     AksiyonEkleTus.tag := 99;
   end;
   ComboTamamlanan.ItemIndex := 0;


  //DegisTus.visible := REHBER.Active;
  //SilTus.visible := DegisTus.visible;
  CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
  CalendarEkstreBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));
end;

procedure TIKListeDlg.Bayraklaretle1Click(Sender: TObject);
begin
//adn   Menu_Bayrak(Sender, GorevGridDBTableView1);
   PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.DeneyimIptalClick(Sender: TObject);
begin
   TabIsDeneyimi.Cancel;
end;

procedure TIKListeDlg.DeneyimKaydetClick(Sender: TObject);
begin
   TabIsDeneyimi.Post;
end;

procedure TIKListeDlg.DeneyimSilTusClick(Sender: TObject);
begin
    if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
       TabIsDeneyimi.Delete;
end;

procedure TIKListeDlg.BtnSilPerizinClick(Sender: TObject);
begin
  if not PERSONELIZIN.IsEmpty then
    if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' delete from PERSONELIZIN where ID=&DokID',['&DokID'],[PERSONELIZIN.FieldByName('ID').AsInteger]);
       PERSONELIZIN.Close;
       PERSONELIZIN.Open;
    end;
end;

procedure IzinsureleriDoldur;
begin
  IzinSure[1] :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinYil1, 5);
  IzinSure[2] :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinYil2, 10);
  IzinSure[3] :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinYil3, 50);
  IzinSure[4] :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinSure1, 14);
  IzinSure[5] :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinSure2, 20);
  IzinSure[6] :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinSure3, 26);
  IzinSure[7] :=  Abs(StrToInt(BoolToStr(Tablo.GENINI.ReadBoolean(Ops_IK_CheckIzinCumartesi, False))));
  IzinSure[8] :=  Abs(StrToInt(BoolToStr(Tablo.GENINI.ReadBoolean(Ops_IK_CheckIzinPazar, False))));
end;

procedure HakedilenIzinGunSayisiniGetir(RehberId, BuYil:Integer; var IzinTarihi:TDateTime; var Gun:integer);
var  IseGiris : TDateTime;
     GecenYil : Smallint;
begin
   Tablo.TablodanSorguAc(1,'select top 1 TARIH from PERS_HAREKET where REHBERID='+IntToStr(RehberId)+' and TUR=1 order by 1 desc');
//   Tablo.TablodanSorguAc(1,'select GIRISTARIHI from REHBER where ID='+IntToStr(RehberId));
  ////iþe giriþ tarihi boþ ise girilmesi istenir.
   Gun := 0;
   if Tablo.Query1.IsEmpty then
      showmessage(Tablo.AciklamaGetir('REHBER','FIRMA', RehberId)+' '+IKEksik_bilgi)
   else begin
     IseGiris:= Tablo.Query1.Fields[0].AsDateTime;
     IzinTarihi := StrToDate(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator, IseGiris)+IntToStr(BuYil));//iþe giriþin gün ve ayýný alalým
     GecenYil := Buyil - StrToInt(FormatDateTime('yyyy',IseGiris));
     if IzinSure[1]<1 then
        IzinsureleriDoldur;
     if (GecenYil>=1)and(GecenYil<=IzinSure[1]) then Gun := IzinSure[4]
     else if (GecenYil>IzinSure[1])and(GecenYil<=IzinSure[2]) then Gun := IzinSure[5]
     else if (GecenYil>IzinSure[2])and(GecenYil<IzinSure[3]) then Gun := IzinSure[6]
   end;
end;

procedure IzinSatirInsert(RehberId,Tur:integer; Miktar:Real; Tarih:TdateTime; Aciklama,Donem:string; Ekleme:Boolean);
var
  izinliGunSayisi : Real;
begin
  if FormatSettings.DateSeparator='.' then begin
   Tarih := StrToDateTime(StringReplace(DateTimeToStr(Tarih),'/',FormatSettings.DateSeparator,[rfReplaceAll]));
  end else begin
   Tarih := StrToDateTime(StringReplace(DateTimeToStr(Tarih),'.',FormatSettings.DateSeparator,[rfReplaceAll]));
  end;

  Tablo.Query6.Close;
  if Ekleme then
  begin
    Tablo.Query6.SQL.Text := 'INSERT INTO PERSONELIZIN(EKLEYEN, EKLEMETARIHI, IZINTURU, BIRIM, IZINLIGUNSAYISI, IZINBASLANGIC, ACIKLAMA, HAK, IZINVERENREHBERID, REHBERID, SUBEID, DONEM, IZINBITIS) '+
                             'VALUES(:EKLEYEN, :EKLEMETARIHI, :IZINTURU, :BIRIM, :IZINLIGUNSAYISI, :IZINBASLANGIC, :ACIKLAMA, :HAK, :IZINVERENREHBERID, :REHBERID, :SUBEID, :DONEM, :IZINBITIS)';
    Tablo.Query6.ParamByName('IZINTURU').Value := Tur;
    Tablo.Query6.ParamByName('BIRIM').Value := 3; //gün
    izinliGunSayisi := 0;
    Tablo.Query6.ParamByName('ACIKLAMA').Value := Aciklama;
    if Tur = -1 then begin
     Tablo.Query6.ParamByName('HAK').Value := Miktar;
     izinliGunSayisi:=0;
    end else begin
     Tablo.Query6.ParamByName('HAK').Value :=0;
     izinliGunSayisi := Miktar;
    end;
    Tablo.Query6.ParamByName('IZINLIGUNSAYISI').Value := izinliGunSayisi;
    Tablo.Query6.ParamByName('IZINBASLANGIC').Value := Tarih; // - 1/24
    Tablo.Query6.ParamByName('IZINVERENREHBERID').Value := Kullanan;
    Tablo.Query6.ParamByName('REHBERID').Value := RehberId;
    Tablo.Query6.ParamByName('SUBEID').Value := SubeID;
    Tablo.Query6.ParamByName('DONEM').Value  := Donem;
    Tablo.Query6.ParamByName('IZINBITIS').Value :=  (Tarih) + izinliGunSayisi - 1;
    Tablo.Query6.ParamByName('EKLEYEN').Value := Kullanan;
    Tablo.Query6.ParamByName('EKLEMETARIHI').Value := Tablo.GENINI.BugunTrhSaat;
  end;
  Tablo.Query6.ExecSQL;
end;

procedure ButunPersonelinHakedilenIzinleriniEkle;
var Gun:Integer;
    IzinTrh:TDateTime;
begin //Bu sene izin atanmam?? pers listesini bulal?m
   Tablo.TablodanSorguAc(8, 'Select ID from REHBER R where GRUP = 335 and DURUM = 1 '+
     ' and ID not in(select ID=REHBERID from PERSONELIZIN I where R.ID=I.REHBERID and HAK>0 and I.IZINBASLANGIC between '''+IntToStr(CariYil)+'-01-01 00:00'' and '''+IntToStr(CariYil)+'-12-31 23:59'')'+
     ' order by FIRMA');
   while not Tablo.Query8.eof do begin
     HakedilenIzinGunSayisiniGetir(Tablo.Query8.Fields[0].AsInteger, CariYil,IzinTrh, Gun);
     if Gun>0 then
        IzinSatirinsert(Tablo.Query8.Fields[0].AsInteger, -1,Gun,IzinTrh,'',IntToStr(CariYil-1),True);
     Tablo.Query8.next;
   end;
   showmessage(OSIslemTamamlandi);
end;

procedure TIKListeDlg.YeniPerizinClick(Sender: TObject);
var
  izinTur, Gun:integer;
  izinTurBirim,Hakedilen,izinTarihi,Aciklama,DonemX: Variant; // Miktar,
  ctrls: TGirdiDenetimleri;
  Tipi : PChar;
  Trh:String[10];
  IseGiris,IzinTrh : TDateTime;
begin
   Tablo.TablodanSorguAc(1,'select top 1 TARIH from PERS_HAREKET where REHBERID='+REHBER.FieldByName('ID').AsString+' and TUR=1 order by 1 desc');
//   Tablo.TablodanSorguAc(1,'select GIRISTARIHI from REHBER where ID='+REHBER.FieldByName('ID').AsString);
   if Tablo.Query1.IsEmpty then
      raise exception.create( IKEksik_bilgi);
   IseGiris:= Tablo.Query1.Fields[0].AsDateTime;

   Donemx:= FormatdateTime('yyyy', Incyear(tablo.GENINI.BugunTrh,-1));
   YeniIzin := True;
   izinTur := TMenuItem(Sender).Tag;
   izinTurBirim := 3;    //Varsayýlan olarak 'Gün' izin türü birimi geliyor
   //Miktar := 0;
  ////iþe giriþ tarihi boþ ise girilmesi istenir.
  /// Yeniye týklandýðýnda Popup button olacak orada izin türleri seçilecek ve eðer yýllýk izin ise Hak edilen miktar girilecek.
  /// yok eðer diðer izinlerden ise tek satýr eklenecek.

   if izinTur=-1 then begin
       HakedilenIzinGunSayisiniGetir(REHBER.FieldByName('ID').AsInteger, CariYil, IzinTrh, Gun);
       Tipi:='Hakedilen';
       izinTarihi := IzinTrh;
       Hakedilen := Gun;
    end else begin
       Tipi:='Kullanýlan';
       izinTarihi := Tablo.GENINI.BugunTrh;
    end;

    ctrls := TGirdiDenetimleri.Create.edit(Tipi+' Dönemi',@Donemx).DateTimePicker('ýzin Tarihini Giriniz',@izinTarihi).edit(Tipi+' Gün Miktarýný Giriniz',@Hakedilen).Edit('Açýklama',@Aciklama);
    if TGirisKutusuEx.BilgiAlEx(Tipi+' ýzin Bilgileri (ýþe Giriþ:'+FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', IseGiris)+')', ctrls) = mrOk then begin
       Hakedilen:=StringReplace(VarToStr(Hakedilen),',',FormatSettings.Decimalseparator,[rfReplaceAll]);
       Hakedilen:=StringReplace(VarToStr(Hakedilen),'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
       Donemx := IntToStr(StrToIntDef( VarToStr(Donemx),1));

      if not Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from PERSONELIZIN Where REHBERID='+REHBER.FieldByName('ID').AsString+' and IZINTURU = 1 and BIRIM = 3 and IZINLIGUNSAYISI = 0 and DONEM='+VarToStr(Donemx)+' ',[],[]) then begin
        if (Hakedilen > 0) then begin
          IzinSatirinsert(REHBER.FieldByName('ID').AsInteger,izinTur,Hakedilen,izinTarihi,Aciklama,VarTostr(Donemx),True);
          SETarihBasPropertiesChange(Self);//Refresh
        end else begin
          Application.MessageBox(PChar(Tipi+IKSifirdan_buyuk),Pchar(Uyari),0);
          Abort;
        end;
      end else
        Application.MessageBox(Pchar(Tipi+IKDolu_alan),Pchar(Uyari),0);
    end;
end;

procedure TIKListeDlg.ComboBox1DropDown(Sender :TObject);
begin
  GenotipIni.ReadSection('TABLEADLARI', TComboBox(Sender).Items)
end;

constructor TIKListeDlg.Create(AOwner: TComponent);
begin
  inherited;
  FArama := nil;
end;

procedure TIKListeDlg.cxDBTreeList1cxDBTreeListColumn2PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  st:Tstringlist;
begin
  try//rehberpersonelden aranacak
    st := Tstringlist.create;
    //IlgiliEkleClick
    if Tablo.ListedenBilgiGetir(MusteriilgiliSec,'select ID, ADSOYAD=FIRMA from REHBER where GRUP=334 AND BAGID='+REHBER.FieldByName('ID').AsString+' and FIRMA like''%<ara>%''  order by 2 ',st,[],'UIKListeFrameMilgiliSec',TNotifyEvent(nil),Tablo.FDCnn,IlgiliEkleClick) then begin
      TabEkipmanlar.Edit;
      TabEkipmanlar.FieldByName('MUS_ILGILI').AsInteger := StrToIntDef(st.Strings[0],-1);
      TabEkipmanlar.Post;
    end;
  finally
    st.free;
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TIKListeDlg.IlgiliEkleClick(Sender: TObject);
var ID : Integer;
begin
  ID := Tablo.RehberSihirbazBaslat(4,REHBER.FieldByName('ID').AsInteger,-1,-1,False);
  if ID>0 then begin
    TabEkipmanlar.Edit;
    TabEkipmanlar.FieldByName('MUS_ILGILI').AsInteger := ID;
    TabEkipmanlar.Post;
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TIKListeDlg.cxDBTreeList1cxDBTreeListColumn6PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  KodAgaciLokasyonDlg:TKodAgaciDlg;
  slist : TStringList;
begin
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,REHBERID,ID from LOKASYON where DURUM=1 and TUR='+IntToStr(Lokasyon_Genel)+'  and REHBERID='+REHBER.FieldByName('ID').AsString;
  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,False,True,LokID,LokKod,LokAciklama,slist,[nil,nil,nil],['REHBERID','TUR'],[REHBER.FieldByName('ID').AsString,IntToStr(Lokasyon_Genel)]
          ,['Kod','Açýklama','',''],[True,True,False,False],True) then try
    TabEkipmanlar.Edit;
    TabEkipmanlar.FieldByName('LOKASYONID').Value:=LokID;
    TabEkipmanlar.Post;
  finally
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
    FreeAndNil(KodAgaciLokasyonDlg);
  end;
end;

procedure TIKListeDlg.GridIzinListeDBTableView1IZINVERENREHBERIDGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
var
  ID1:Integer;
  Kod1,Ad1:string;
begin
  if ARecord.Values[GridIzinListeDBTableView1REHBERID.Index]>0 then  begin
    ID1:=ARecord.Values[GridIzinListeDBTableView1REHBERID.Index];
    Tablo.RehberBilgisiGetir(ID1,Kod1,Ad1);
    AText := Ad1;
  end;
end;

procedure TIKListeDlg.cxGrid3DBTableView1IZINVERENREHBERIDPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var ID1:Integer;
begin
  if not (PERSONELIZIN.State in [dsEdit,dsInsert]) then
    PERSONELIZIN.Edit;
  PERSONELIZIN.FieldByName('IZINVERENREHBERID').AsInteger := Tablo.RehberAra_IDGetir(335);
  //cxGrid3DBTableView1.Controller.ClearCellSelection;
 GridIzinListeDBTableView1ACIKLAMA.FocusWithSelection;

end;

procedure TIKListeDlg.cxGrid3DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TIKListeDlg.GridIzinListeDBTableView1VEKILGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
var
  ID1:Integer;
  Kod1,Ad1:string;
begin
  if ARecord.Values[GridIzinListeDBTableView1VEKIL.Index] > 0 then begin
    ID1:=ARecord.Values[GridIzinListeDBTableView1VEKIL.Index];
    Tablo.RehberBilgisiGetir(ID1,Kod1,Ad1);
    AText := Ad1;
  end;
end;

procedure TIKListeDlg.GridKesintiViewDblClick(Sender: TObject);
begin
  KesintiDuzenleTusClick(Self);
end;

procedure TIKListeDlg.cxGrid3DBTableView1VEKILPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var ID1:Integer;
begin
  if not (PERSONELIZIN.State in [dsEdit,dsInsert]) then
    PERSONELIZIN.Edit;
  PERSONELIZIN.FieldByName('VEKIL').AsInteger:=Tablo.RehberAra_IDGetir(335);
  //cxGrid3DBTableView1.Controller.ClearCellSelection;
 GridIzinListeDBTableView1ACIKLAMA.FocusWithSelection;
end;

procedure TIKListeDlg.cxGridDBTableViewPirimCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridIKDeneyim;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridIKDeneyimView;
  AnaForm.pmGridStil.Tags.Values[GridIKDeneyim.Name] := 'IKPersonelPirimGridi';
end;

procedure TIKListeDlg.cxGridHareketlerCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGrid1;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridHareketler;
  AnaForm.pmGridStil.Tags.Values[cxGrid1.Name] := 'RehberEkstreHareket';
end;

procedure TIKListeDlg.cxGridHareketlerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TIKListeDlg.cxGridPersonellerSelectionChanged(Sender: TcxCustomGridTableView);
begin
   ResimGetir(REHBER.Fields[0].AsInteger,12, TabRehberIlgili.FieldByName('ID').AsInteger, Resim);
   TabloYenile( TabPerIletisim, [TabRehberIlgili.Fields[0].AsInteger]);
end;

procedure TIKListeDlg.cxLabel4Click(Sender: TObject);
begin
  Application.CreateForm(TMaasListeDlg, MaasListeDlg);
  MaasListeDlg.showmodal;
  MaasListeDlg.destroy;
  PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.cxPageControl1Change(Sender: TObject);
begin
    if cxPageControl1.ActivePageIndex=1 then
       Tabloyenile(TabGrup,[]);
end;

procedure TIKListeDlg.LabelBankadanOdemeDblClick(Sender: TObject);
var
  Tutar:Variant;
  RehberID:string;
  mResult:TModalResult;
begin
  RehberID := REHBER.FieldByName('ID').AsString;
  Tablo.TablodanSorguAc(1,'SELECT TOP 1 isnull(TUTAR,0.0)  FROM dbo.PLANMAAS WHERE YER=51 AND YERID='+RehberID);
  if not Tablo.Query1.IsEmpty then
  begin
    Tutar := Tablo.Query1.Fields[0].AsCurrency;
    mResult := TGirisKutusuEx.BilgiAlEx(BGBankadan_odenecek_maas,TGirdiDenetimleri.Create.CurrencyEdit('Tutar',@Tutar,2));
    if mResult = mrOk then begin
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE PLANMAAS SET TUTAR=&TUTAR, DEGISTIREN=&DEGISTIREN,'+
        'DEGISTIRMETARIHI=GETDATE() WHERE YER=51 AND YERID=&YERID',
        ['&TUTAR','&YERID','&DEGISTIREN'], [Tutar,RehberID,Kullanan]);
      LabelBankadanOdeme.Caption := VarToStr(Tutar) + ' ' + CariDoviz;
    end;
  end else begin
    Tutar := 0;
    mResult := TGirisKutusuEx.BilgiAlEx(BGBankadan_odenecek_maas,TGirdiDenetimleri.Create.CurrencyEdit('Tutar',@Tutar,2));
    if mResult = mrOk then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO PLANMAAS (TUTAR,YER,YERID,KUR,EKLEYEN,EKLEMETARIHI)'+
        ' VALUES(&TUTAR,51,&YERID,&KUR,&EKLEYEN,GETDATE())',
        ['&TUTAR','&YERID','&KUR','&EKLEYEN'], [Tutar,RehberID,CariDoviz,Kullanan]);
    end;
      LabelBankadanOdeme.Caption := VarToStr(Tutar) + ' ' + CariDoviz;
  end;
end;

destructor TIKListeDlg.Destroy;
begin
   inherited;
end;

procedure TIKListeDlg.DilEkleTusClick(Sender: TObject);
begin
   TabDil.Append;
end;

procedure TIKListeDlg.DilKaydetTusClick(Sender: TObject);
begin
   TabDil.Post;
end;

procedure TIKListeDlg.DilSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabDil.Delete;
end;

procedure TIKListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TIKListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabloNo,REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TIKListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
            TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, Rehber.FieldByName('ID').AsInteger)
end;

procedure TIKListeDlg.DtsIsDeneyimiStateChange(Sender: TObject);
begin
  DeneyimKaydet.Visible := DtsIsDeneyimi.State in [dsEdit,dsInsert];
  DeneyimIptal.Visible := DeneyimKaydet.Visible;
  DeneyimEkleTus.Visible := not DeneyimKaydet.Visible;
  DeneyimSilTus.Visible := not DeneyimKaydet.Visible;
end;

procedure TIKListeDlg.DtsDilStateChange(Sender: TObject);
begin
  DilEkleTus.Visible := DtsDil.State = dsBrowse;
  DilSilTus.Visible := (DtsDil.State=dsBrowse)and(not TabDil.IsEmpty);
  DilKaydetTus.Visible := DtsDil.State in [dsEdit,dsInsert];
  DilIptalTus.Visible := DtsDil.State in [dsEdit,dsInsert];
end;

procedure TIKListeDlg.DtsImajStateChange(Sender: TObject);
begin
  //DokumanKaydetTus.Enabled:= DtsImaj.State in [dsEdit,dsInsert];
  //DokumanIptalTus.Enabled:=  DtsImaj.State in [dsEdit,dsInsert];
end;

procedure TIKListeDlg.DtsPersonelIzinStateChange(Sender: TObject);
begin
  BtnYeniPerizin.Visible := not (DtsPersonelIzin.State in [dsEdit,dsInsert]);
  BtnSilPerizin.Visible := not (DtsPersonelIzin.State in [dsEdit,dsInsert]);
end;
procedure TIKListeDlg.DuzenleMenuClick(Sender: TObject);
begin
   Menu_Duzenle(Sender, TabGorevler);
   PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TIKListeDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TIKListeDlg.Fatura1Click(Sender: TObject);
var Tur, ID : Integer;
    HesapTuru : Char;
    Tarih:TDateTime;
begin
  Tur := TMenuItem(Sender).Tag;
  case Tur of
    21,31 : HesapTuru := 'K';
    22,32 : HesapTuru := 'B';
    23,33,35 : HesapTuru := 'V';
    25    : HesapTuru := 'P';
    26,28,29,36,38,39: HesapTuru := 'H';
  else
    HesapTuru := '-';
  end;
  case Tur of
     21,22,25,26,28,29,31,32,35,36,38,39 : ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,2, -1, REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrhSaat, '-1');
     61,71  : begin Tarih:=Tablo.GENINI.BugunTrhSaat;
                    ID := Tablo.KasaSihirbazBaslat('E', -1, Tur, 0, REHBER.Fields[0].AsInteger, Tarih,Tarih,0,0,'','');
              end;
  end;
  if ID > 0 then
    PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.Faturaile1Click(Sender: TObject);
begin
  case TabCariListe.FieldByName('TUR').AsInteger of
      8,15 :begin
        Tablo.Query9.Close;
        Tablo.Query9.SQL.Text := 'Select * from FATBASLIK Where ID='+TabCariListe.FieldByName('CEKID').AsString+' ';
        Tablo.Query9.Open;

        Tablo.FaturaIadeAl(Tablo.Query9,TMenuItem(Sender).Tag );
      end;
  end;
end;

procedure TIKListeDlg.AksiyonBilgisiniGorMenuClick(Sender: TObject);
var
   Tur:Integer;
   Kilit : Boolean;
   HesapTuru : char;
begin
{
   21,22, 31,32 : Tablo.NakitSihirbazBaslat('K','D', TabCariListe.FieldByName('TUR').AsInteger,5 , TabCariListe.FieldByName('CEKID').AsInteger,
         REHBER.FieldByname('ID').AsInteger, TabCariListe.FieldByName('TARIH').AsDateTime, TabCariListe.FieldByName('NO').AsString, Kilit,-1,
         TabCariListe.FieldByName('HESAPID').AsInteger );

 }
   case TabCariListe.FieldByName('TUR').AsInteger of
    1,2:   Tablo.AcilisiFisiEkraniBaslat(1,TabCariListe.FieldByName('TUR').AsInteger, REHBER.FieldByname('ID').AsString,REHBER.FieldByname('KOD').AsString,
                          REHBER.FieldByname('FIRMA').AsString,'',TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TARIH').AsDateTime);
    40 : begin
           Tablo.TablodanSorguAc(4, 'select HESAPTURU, HESAPID from KASA where ID = '+TabCariListe.FieldByName('GERIDONUSID').AsString);
           HesapTuru := Tablo.Query4.Fields[0].AsString[1];
           if (HesapTuru='K') and (TabCariListe.FieldByName('ALACAK').AsCurrency>0) then Tur:=31
           else if (HesapTuru='K') and (TabCariListe.FieldByName('BORC').AsCurrency>0) then Tur:=21
           else if (HesapTuru='B') and (TabCariListe.FieldByName('ALACAK').AsCurrency>0) then Tur:=32
           else if (HesapTuru='B') and (TabCariListe.FieldByName('BORC').AsCurrency>0) then Tur:=22;
           Tablo.NakitSihirbazBaslat(HesapTuru,'D', Tur,Cagiran, TabCariListe.FieldByName('GERIDONUSID').AsInteger,
                 TabCariListe.FieldByName('REHBERID').AsInteger,TabCariListe.FieldByName('TARIH').AsDateTime,TabCariListe.FieldByName('NO').AsString, Kilit,
                 -1, Tablo.Query4.FieldByName('HESAPID').AsInteger);
    end;
    else
      AnaForm.GormeDialogCagir(TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TUR').AsInteger,
           TabCariListe.FieldByName('REHBERID').AsInteger, 2,TabCariListe.FieldByName('TARIH').AsDateTime, TabCariListe.FieldByName('NO').AsString);
    end;
  PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.PMAksiyonlarMenuPopup(Sender: TObject);
begin
   if REHBER.FieldByName('DURUM').AsInteger < 1 then
      raise Exception.Create(CRPasif_kayda_islem_olmaz);
   Sil1.Visible := not TabCariListe.IsEmpty;
   TahsilMenu2.Visible := (Sil1.Visible)and((TabCariListe.FieldByName('TUR').AsInteger in [15..19])or(TabCariListe.FieldByName('TUR').AsInteger = 61));
   OdemeMenu2.Visible := (Sil1.Visible)and((TabCariListe.FieldByName('TUR').AsInteger in [8,10..14])or(TabCariListe.FieldByName('TUR').AsInteger = 11));
   iadeAl.Visible := TabCariListe.FieldByName('TUR').AsInteger in [15,16];
end;


procedure TIKListeDlg.PopupMenuYeniPopup(Sender: TObject);
begin
   GelenTahakkuk1.Enabled := REHBER.FieldByName('DURUM').AsInteger=1;
   GidenTahakkuk1.Enabled := GelenTahakkuk1.Enabled;
   Tahsilat1.Enabled := GelenTahakkuk1.Enabled;
   Odeme1.Enabled := GelenTahakkuk1.Enabled;
   PozisyonDegisimiMenu.Enabled := GelenTahakkuk1.Enabled;
   IstenCikisMenu.Enabled := GelenTahakkuk1.Enabled;
   IstenCikisIptalMenu.visible := not GelenTahakkuk1.Enabled;
end;

procedure TIKListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TIKListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabloNo, REHBER.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TIKListeDlg.PozisyonDegisimiMenuClick(Sender: TObject);
begin
   TBtnHareketlerEkle.Click;
end;

procedure TIKListeDlg.AktiviteDuzenleClick(Sender: TObject);
begin
  akttarih:= Tablo.GENINI.BugunTrhSaat;
end;

procedure TIKListeDlg.AktiviteEkleTusClick(Sender: TObject);
begin
  akttarih:= Tablo.GENINI.BugunTrhSaat;
end;

procedure TIKListeDlg.AktiviteSilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      //varsa dokumanlar?n silinmeli
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[51, TabGorevler.Fields[0].AsInteger]);
      //varsa proje ba?lant?lar? silinmeli
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from AKTIVITELER where Id=&id ',['&id'],[TabGorevler.Fields[0].AsInteger]);
      PageControlSekmeChange(Self);
      Abort;
   end;
end;

procedure TIKListeDlg.AraFirmaKeyUp(Sender :TObject; var Key :Word; Shift :TShiftState);
begin
  if Key = 13 then
     IKGridViewDblClick(Self)
  else if Key = 38 then
    REHBER.Prior
  else if Key = 40 then
    REHBER.next
  else if TEdit(Sender).Text <> '' then
    AraTusClick(Self);
end;

procedure TIKListeDlg.EditUcretKeyUp(Sender :TObject; var Key :Word; Shift :TShiftState);
begin
   if TEdit(Sender).Text <> '' then
      AraTusClick(Self);
end;

procedure TIKListeDlg.EkranYazdir(Sender: TObject);
begin

end;



procedure TIKListeDlg.EPostaKontrol1Click(Sender: TObject);
begin
   Tablo.TablodanSorguAc(5, ' select BILGI from REHBERBILGI B inner join REHBERILETISIM I on B.YER_ID=I.ID '+
                            ' where I.REHBERID='+REHBER.Fields[0].AsString+' and BILGI like ''%@%'' ');
   while not Tablo.Query5.eof do begin
      Tablo.EPostaAlimIslemleri(Tablo.Query5.fields[0].AsString, StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
      Tablo.Query5.Next;
   end;
end;

procedure TIKListeDlg.ExceldenVeriAlMenuClick(Sender: TObject);
begin
    Excel2IK(Potansiyel);
end;

procedure TIKListeDlg.GelenTahakkuk1Click(Sender: TObject);
var Tur, ID : Integer;
begin
   Tur := TMenuItem(Sender).Tag;
   ID := Tablo.TahakkukSihirbaziBaslat('E', Tur,0, -1, REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrhSaat);
   if ID > 0 then
      PageControlSekmeChange(Self);
end;


function TIKListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

procedure TIKListeDlg.DegisTusClick(Sender: TObject);
begin
  if (not REHBER.Active)or(REHBER.Active and REHBER.IsEmpty) then
      raise Exception.Create(RDOnceAramaYapin);
  if Tablo.IKSihirbazBaslat(0,REHBER.Fields[0].AsInteger,-100,-100, Potansiyel) > 0 then begin
     TabloYenile(REHBER,[]);
  end;
end;

procedure TIKListeDlg.RBDevirliClick(Sender: TObject);
begin
  PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.CalendarEkstreBasPropertiesChange(Sender: TObject);
var
  fb : TIcerikFrameBilgi;
  s:string[10];
begin
  if (REHBER.Active)and(not REHBER.IsEmpty)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
//    EditMaasAvansi.Visible := REHBER.FieldByName('GRUP').AsInteger=335;
    EditIsAvansi.Visible :=  EditMaasAvansi.Visible;
    LabelMaasAvansi.Visible :=EditMaasAvansi.Visible;
    LabelIsAvansi.Visible :=EditMaasAvansi.Visible;
    if EditMaasAvansi.Visible then begin
        Tablo.TablodanSorguAc(1,' select sum(ALACAK-BORC) from KASA K inner join KASALAR KS on K.HESAPID=KS.ID'+
                                ' where K.REHBERID='+REHBER.FieldByName('ID').AsString+'  and KS.KASATUR=196');
        EditMaasAvansi.Value := Tablo.Query1.Fields[0].AsCurrency;
        Tablo.TablodanSorguAc(1,' select sum(ALACAK-BORC) from KASA K inner join KASALAR KS on K.HESAPID=KS.ID'+
                                ' where KS.REHBERID='+REHBER.FieldByName('ID').AsString+' and KS.KASATUR=195');
        EditIsAvansi.Value := Tablo.Query1.Fields[0].AsCurrency;
    end;
    TabCariListe.Close;

    s:='';
    if cbPerExtreTuru.EditValue<>1 then begin
       if cbPerExtreTuru.EditValue = 2 then
          TabCariListe.SQL.Text := 'select * from dbo.fn_Pers_Is_Avansi '
       else if cbPerExtreTuru.EditValue = 3 then
          TabCariListe.SQL.Text := 'select * from dbo.fn_Pers_Maas_Avansi ';
    end else begin
       if CheckDetayli.Checked then
          TabCariListe.SQL.Text := 'select * from dbo.fn_Cari_Detayli_Ekstre '
       else begin
          TabCariListe.SQL.Text := 'select * from dbo.fn_Cari_Ekstre ';
          s:=',0';
       end;
    end;
    TabCariListe.SQL.Add('('+REHBER.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''''+s+')');
    TabCariListe.SQL.Add('order by KUR,TARIH');
    TabloYenile(TabCariListe,[]);
  end;
end;

procedure TIKListeDlg.cbPerExtreTuruPropertiesEditValueChanged(Sender: TObject);
begin
  CalendarEkstreBasPropertiesChange(Self);
end;

procedure TIKListeDlg.CheckDetayliPropertiesEditValueChanged(Sender: TObject);
var
  MItem:TMenuItem;
begin
  try
    if CheckDetayli.Checked then
      MItem := PopupMenuYaz.Items.Find('EkstreDetay')
    else
      MItem := PopupMenuYaz.Items.Find('Ekstre');
  finally
    if MItem <> nil then
      MItem.Click;
  end;
end;

procedure TIKListeDlg.checkKapaliGosterPropertiesEditValueChanged(Sender: TObject);
begin
   PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.CheckPasiflerClick(Sender: TObject);
begin
   IKGridViewDURUMAD.Visible := FArama.CheckPasifler.Checked;
   AraTusClick(Self);
end;

procedure TIKListeDlg.CheckPDKSTakibiClick(Sender: TObject);
begin
   ButtonVardiyalar.Visible := CheckPDKSTakibi.Checked;
   ButtonVardiyaTuru.Visible := CheckPDKSTakibi.Checked;
   ButtonKartNo.Visible := CheckPDKSTakibi.Checked;
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update REHBER set TEMAS='+IntToStr(Abs(StrToInt(BoolToStr(CheckPDKSTakibi.Checked))))+' where ID='+ REHBER.Fields[0].AsString,[],[]);
end;

procedure TIKListeDlg.CheckTamamlananClick(Sender: TObject);
begin
   ComboTamamlanan.Visible := CheckTamamlanan.Checked;
   PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.CheckTamamlanmisAktivitePropertiesEditValueChanged(Sender: TObject);
begin
   PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TIKListeDlg.YeniGrupClick(Sender: TObject);
var Grup : Variant;
    ID : integer;
begin
    if TGirisKutusuEx.BilgiAlEx(BGYeni,TGirdiDenetimleri.Create.Edit('Grup Adý',@Grup)) = mrOk then begin
       ID := veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'insert into [REHBER] (FIRMA, GRUP, DURUM, EKLEYEN) values ('''+vartostr(Grup)+''',336,1,'+Kullanan+')  SELECT SCOPE_IDENTITY()',[],[],True);
       cxPageControl1Change(Self);
       TabGrup.Locate('ID', ID, []);
        GridGrupView.Control.SetFocus;
  // just in case if DataSet is UniDirectional:
  if GridGrupView.DataController.FocusedRowIndex < 0 then
    GridGrupView.DataController.FocusedRowIndex := 0;
    end;
end;

procedure TIKListeDlg.YeniletisimEkleMenuClick(Sender: TObject);var ID : Integer;
begin

end;

{function TIKListeDlg.BulveYerlestir(s:string):string;
var bas,nokta,bit:smallint; //   $REHBER.ADSOYAD$
    K1,K2:string;
    Bitti : boolean;
begin
  while pos('$', s)>0 do begin
      bas:= pos('$', s);
      nokta:= posEx('.', s, bas);
      K1 := copy(s,bas+1,nokta-bas-1);

      bit:=  posEx('$', s, nokta);
      K2 := copy(s,nokta+1,bit-nokta-1);

      if (K1='REHBER')and(Rehber.FindField(K2) <> nil) then
         s := stringReplace(s,'$'+K1+'.'+K2+'$', Rehber.FieldByName(K2).AsString, [rfReplaceAll])
      else if K1='SISTEM' then begin
         if K2='TARIH' then
            s := stringReplace(s,'$'+K1+'.'+K2+'$', FormatDateTime('dd/mm/yyyy', Tablo.GENINI.BugunTrh), [rfReplaceAll])
         else if K2='KURUMAD' then
            s := stringReplace(s,'$'+K1+'.'+K2+'$', Tablo.TabBizim.FieldByName('FIRMA').AsString, [rfReplaceAll])
         else
            s := stringReplace(s,'$'+K1+'.'+K2+'$', '', [rfReplaceAll]);
      end
      else
            s := stringReplace(s,'$'+K1+'.'+K2+'$', '', [rfReplaceAll]);

  end;
  Result := s;
end;

procedure TIKListeDlg.DuyuruYayinla(YayinId:Integer);
var ID :integer;
begin
  Tablo.TablodanSorguAc(4,'SELECT [SABLONDUYURUID]  FROM [UYARIAYAR] WHERE [KOD]='+IntToStr(YayinId));
  if (Tablo.Query4.RecordCount>0)and(Tablo.Query4.FieldByName('SABLONDUYURUID').Asstring<>'') then begin
      Tablo.TablodanSorguAc(5,'SELECT * FROM [DUYURU] WHERE [ID]='+Tablo.Query4.FieldByName('SABLONDUYURUID').Asstring);
      ID := Tablo.SQLSatiriKopyala('DUYURU', Tablo.Query4.FieldByName('SABLONDUYURUID').AsInteger,[ 'GECERLILIKTARIHI','TUR','SISTEM','KONU','DUYURU', 'EKLEYEN', 'EKLEMETARIHI'],
                [ Tablo.GENINI.BugunTrhSaat,2, 1,
                BulveYerlestir(Tablo.Query5.FieldByName('KONU').Asstring), //'@ADSOYAD',REHBER.FieldByName('ADSOYAD').Asstring,[]),
                BulveYerlestir(Tablo.Query5.FieldByName('DUYURU').Asstring),//'@ADSOYAD',REHBER.FieldByName('ADSOYAD').Asstring,[]),
                0, Tablo.GENINI.BugunTrhSaat]);
      veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'insert into [DUYURUKULLANICI] ([DUYURUID],[ALICIID],[OKUNDU])  '+
                               ' select [DUYURUID]='+inttostr(ID)+',[ALICIID],[OKUNDU]=0 from [DUYURUKULLANICI] where [DUYURUID]='+Tablo.Query4.FieldByName('SABLONDUYURUID').AsString,[],[]);
      veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'insert into DUYURUIMAJ ([DUYURUID],[IMAJID])  '+
                               ' select [DUYURUID]='+inttostr(ID)+',[IMAJID] from [DUYURUIMAJ] where [DUYURUID]='+Tablo.Query4.FieldByName('SABLONDUYURUID').AsString,[],[]);
      if Tablo.Query5.FieldByName('EPOSTA').AsBoolean then
         Tablo.Duyuru_EPostaGonder(ID);
  end;
end; }

procedure TIKListeDlg.YeniTusClick(Sender: TObject);
var
   ID : Integer;
begin
   ID := Tablo.IKSihirbazBaslat(0,-100,-100,-100, Potansiyel);
   if ID > 0 then begin
      AraTusClick(Self);
{     REHBER.Close;
      if Potansiyel then
         REHBER.SQL.Text:= StringReplace(SQL_IK_Aday.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll])
      else
         REHBER.SQL.Text:= StringReplace(SQL_IK_Memo.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll]);;

      TabloYenile(REHBER,[0]);
      REHBER.Locate('ID', ID, []);}
  end;
end;

procedure TIKListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
end;

procedure TIKListeDlg.IstenCikisMenuClick(Sender: TObject);
var Tarih, Neden: Variant;
    Trh:TDateTime;
    s,WarningStr:string;
    ShowWarning:boolean;
begin
  Tablo.Query7.Close;
  Tablo.Query7.SQL.Text :=
    ' declare @rehID int '  +
    ' set @rehID = '+REHBER.FieldByName('ID').AsString  +
    ' select  STR=''Proje - Ekleyen'',SAYI=count(*) from PROJELER where DURUM<>2 and EKLEYEN = @rehID ' +
    ' union all ' +
    ' select  STR=''Proje - Sorumlu'',SAYI=count(*) from PROJELER where DURUM<>2 and PRJ_SORUMLUSU_ID = @rehID ' +
    ' union all ' +
    ' select  STR=''Proje - Aþama Sorumlusu'',SAYI=count(*) from PROJEASAMA where DURUM<>2 and REHBERID = @rehID ' +
    ' union all ' +
    ' select  STR=''ýþ Listesi - Atayan'',SAYI=count(*) from GOREVLER where ACKAPA=0 and EKLEYEN = @rehID ' +
    ' union all ' +
    ' select  STR=''ýþ Listesi - Atanan'',SAYI=count(*) from GOREVKULLANICI where ( select distinct ACKAPA from GOREVLER G where G.ID=GOREVKULLANICI.LISTGOREVID)=0 and REHBERID = @rehID and TUR=11 '+
    ' union all ' +
    ' select  STR=''ýþ Listesi - Bilgilendirilecek'',SAYI=count(*) from GOREVKULLANICI where ( select distinct ACKAPA from GOREVLER G where G.ID=GOREVKULLANICI.LISTGOREVID)=0 and REHBERID = @rehID and TUR=12 '+
    ' union all ' +
    ' select  STR=''Teklif - Hazýrlayan'',SAYI=count(*) from TEKLIF where DURUM not in (3,6,7,8) and HAZIRLAYAN = @rehID ' +
    ' union all ' +
    ' select  STR=''Teklif - Onaylayacak'',SAYI=count(*) from TEKLIF where DURUM not in (3,6,7,8) and ONAYLAYACAK = @rehID ' +
    ' union all ' +
    ' select  STR=''Teklif - Onaylayan'',SAYI=count(*) from TEKLIF where DURUM not in (3,6,7,8) and ONAYLAYAN = @rehID ' +
    ' union all ' +
    ' select  STR=''Servis - Sorumlu'',SAYI=count(*) from SERVIS where ACKAPA = 0 and SORUMLU = @rehID ' +
    ' union all ' +
    ' select  STR=''Servis - Kabul Eden'',SAYI=count(*) from SERVIS where ACKAPA = 0 and KABUL_EDEN = @rehID ' +
    ' union all ' +
    ' select  STR=''Servis - Onay Alan'',SAYI=count(*) from SERVIS where ACKAPA = 0 and ONAYALAN = @rehID ' +
    ' union all ' +
    ' select  STR=''Servis - Onaylayacak'',SAYI=count(*) from SERVIS where ACKAPA = 0 and ONAYLAYACAK = @rehID '  +
    ' union all ' +
    ' select  STR=''Servis - Onaylayan'',SAYI=count(*) from SERVIS where ACKAPA = 0 and ONAYLAYAN = @rehID ';
  Tablo.Query7.Open;
  Tablo.Query7.First;
  ShowWarning := False;
  WarningStr := 'ýþten çýkartmakta bulunduðunuz personel daha önce;';
  while not Tablo.Query7.Eof do begin
    if Tablo.Query7.Fields[1].AsInteger > 0 then begin
      ShowWarning := True;
      WarningStr := WarningStr + #13#10 + Tablo.Query7.Fields[0].AsString + ' olarak ' + Tablo.Query7.Fields[1].AsString +' farklý yerdeki';
    end;
    Tablo.Query7.Next;
  end;
  if ShowWarning then begin
    WarningStr := WarningStr + #13#10 + 'kayýtlarda kullanýlmýþtýr.';
    WarningStr := WarningStr + #13#10 + 'Ýlgili iþleri baþka bir personele aktarmak ister misiniz? ';
    if MessageDlg(WarningStr,mtConfirmation,mbYesNoCancel,0 ) = mryes then
      ProjeAktarm1Click(HereyiAktar1);
  end;

   Tarih:=Tablo.GENINI.BugunTrh;
   if TGirisKutusuEx.BilgiAlEx(FWCikis, TGirdiDenetimleri.
                  Create.DateTimePicker(BGIsten_cikis_tarih+':', @Tarih,dtkDate).
                  imageComboBox(BGIsten_cikis_Nedeni,@Neden,Tablo.FDCnn,' select DEGER,ANAHTAR from GENINI where BOLUM=-3503',False,nil)) = mrOk then begin
      Trh := TDateTime(Tarih);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update REHBER set DURUM=0 where ID='+REHBER.FieldByName('ID').AsString,[],[]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update KULLANICI set DURUM=0 where REHBERID='+REHBER.FieldByName('ID').AsString,[],[]);
      Tablo.TablodanSorguAc(1,'select ANAHTAR from GENINI where BOLUM=-3503 and DEGER='+ VarToStr(Neden));
      Tablo.TablodanSorguAc(2,'select isnull(SINIF,0) from REHBER where ID = '+REHBER.FieldByName('ID').AsString );
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into [PERS_HAREKET] (REHBERID,TARIH,TUR,ACIKLAMA,ROLID)values(&REHBERID,'''+FormatDateTime('yyyy-mm-dd', Trh)+''' ,&TUR,&ACIKLAMA,&ROLID)'
          ,['&REHBERID','&TUR','&ACIKLAMA','&ROLID'], [REHBER.FieldByName('ID').AsInteger,99, Tablo.Query1.Fields[0].AsString, Tablo.Query2.Fields[0].AsInteger]);
      //DuyuruYayinla(3402);
      TabloYenile(REHBER,[0]);
   end;
end;

procedure TIKListeDlg.IsiKopyalaMenuClick(Sender: TObject);
begin
  Tablo.GorevKopyala(TabGorevler.Fields[0].AsInteger, TabGorevler.FieldByName('KONUSU').AsString);
  PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.IsiSilMenuClick(Sender: TObject);
begin
   if Tablo.GorevSil(TabGorevler.Fields[0].AsInteger) then
      PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.IstenCikisIptalMenuClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update REHBER set DURUM=1 where ID='+REHBER.FieldByName('ID').AsString,[],[]);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from PERS_HAREKET where TUR=99 and REHBERID='+REHBER.FieldByName('ID').AsString,[],[]);
   TabloYenile(REHBER,[0]);
end;

procedure TIKListeDlg.ProjeAktarm1Click(Sender: TObject);
var
  st: TStringList;
  i: integer;
  EskiPer,YeniPer: Variant;
  ctrls: TGirdiDenetimleri;
begin
  st:=TStringlist.Create;
  ctrls := TGirdiDenetimleri.Create.ImageComboBox('Eski Personel',@EskiPer,Tablo.FDCnn,'select R.ID,R.FIRMA from REHBER R inner join KULLANICI K on R.ID=K.REHBERID order by R.FIRMA').ImageComboBox('Yeni Personel',@YeniPer,Tablo.FDCnn,'select R.ID,R.FIRMA from REHBER R inner join KULLANICI K on R.ID=K.REHBERID order by R.FIRMA');

  if (Sender as TMenuItem).Tag = 99 then begin
    if TGirisKutusuEx.BilgiAlEx(BGPersonel_secimi, ctrls) <> mrOk then
      Abort;
    if not(EskiPer>0) and not(YeniPer>0) and not(EskiPer<>YeniPer) then
      Abort;
    st.Add('0');
    st.Add('1');
    st.Add('2');
    st.Add('3');
    st.Add('4');
  end;

  if (Sender as TMenuItem).Tag in [1,99] then begin//proje
    if (Sender as TMenuItem).Tag <> 99 then begin
      st:=Tablo.ListedenCokluSecim('Aktarýlacak Proje Bilgileri','select ID=1,ACIKLAMA=''Ekleyen'' union all select ID=2,''Proje Sorumlusu'' union all select ID=3,''Aþama Sorumlusu'' ',[Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],['ID','Açýklama']);
    end;
    if ((Sender as TMenuItem).Tag = 99)or((st.Count>0)and(TGirisKutusuEx.BilgiAlEx(BGPersonel_secimi, ctrls) = mrOk)) then begin
      if (EskiPer>0)and(YeniPer>0)and(EskiPer<>YeniPer) then begin
        for i := 0 to st.Count-1 do begin
          if st[i]='1' then //ekleyen
            Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update PROJELER set EKLEYEN='+VarToStr(YeniPer)+' where DURUM<>2 and EKLEYEN='+VarToStr(EskiPer),[],[])
          else if st[i]='2' then //proje sorumlusu
            Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update PROJELER set PRJ_SORUMLUSU_ID='+VarToStr(YeniPer)+' where DURUM<>2 and PRJ_SORUMLUSU_ID='+VarToStr(EskiPer),[],[])
          else if st[i]='3' then //a?ama sorumlusu
            Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update PROJEASAMA set REHBERID='+VarToStr(YeniPer)+' where DURUM<>2 and REHBERID='+VarToStr(EskiPer),[],[]);
        end;
      end;
    end;
  end;

  if (Sender as TMenuItem).Tag in [2,99] then begin//?? Listesi
    if (Sender as TMenuItem).Tag <> 99 then begin
      st:=Tablo.ListedenCokluSecim('Aktarýlacak ýþ Listesi Bilgileri','select ID=1,ACIKLAMA=''Ekleyen'' union all select ID=2,''Atanan'' union all select ID=3,''Bilgilendirilecek'' ',[Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],['ID','Açýklama']);
    end;
      if ((Sender as TMenuItem).Tag = 99)or((st.Count>0)and(TGirisKutusuEx.BilgiAlEx(BGPersonel_secimi, ctrls) = mrOk)) then begin
        if (EskiPer>0)and(YeniPer>0)and(EskiPer<>YeniPer) then begin
          for i := 0 to st.Count-1 do begin
            if st[i]='1' then //ekleyen
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update GOREVLER set EKLEYEN='+VarToStr(YeniPer)+' where ACKAPA = 0 and EKLEYEN='+VarToStr(EskiPer),[],[])
            else if st[i]='2' then //Atanan   tur 11
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update GOREVKULLANICI set REHBERID='+VarToStr(YeniPer)+' where (select ACKAPA from GOREVLER G where G.ID=GOREVKULLANICI.LISTGOREVID) = 0 and TUR=11 and REHBERID='+VarToStr(EskiPer),[],[])
            else if st[i]='3' then //Bilgilendirilecek    tur 12
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update GOREVKULLANICI set REHBERID='+VarToStr(YeniPer)+' where (select ACKAPA from GOREVLER G where G.ID=GOREVKULLANICI.LISTGOREVID) = 0 and TUR=12 and REHBERID='+VarToStr(EskiPer),[],[])
          end;
        end;
      end;
    end;

  if (Sender as TMenuItem).Tag in [3,99] then begin//Teklif
    if (Sender as TMenuItem).Tag <> 99 then begin
      st:=Tablo.ListedenCokluSecim('Aktarýlacak Teklif Bilgileri','select ID=1,ACIKLAMA=''Hazýrlayan'' union all select ID=2,''Onaylayacak'' union all select ID=3,''Onaylayan'' ',[Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],['ID','Açýklama']);
    end;
      if ((Sender as TMenuItem).Tag = 99)or((st.Count>0)and(TGirisKutusuEx.BilgiAlEx(BGPersonel_secimi, ctrls) = mrOk)) then begin
        if (EskiPer>0)and(YeniPer>0)and(EskiPer<>YeniPer) then begin
          for i := 0 to st.Count-1 do begin
            if st[i]='1' then //haz?rlayan
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update TEKLIF set HAZIRLAYAN='+VarToStr(YeniPer)+' where DURUM not in (3,6,7,8) and HAZIRLAYAN='+VarToStr(EskiPer),[],[])
            else if st[i]='2' then //Onaylayacak
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update TEKLIF set ONAYLAYACAK='+VarToStr(YeniPer)+' where DURUM not in (3,6,7,8) and ONAYLAYACAK='+VarToStr(EskiPer),[],[])
            else if st[i]='3' then //onaylayan
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update TEKLIF set ONAYLAYAN='+VarToStr(YeniPer)+' where DURUM not in (3,6,7,8) and ONAYLAYAN='+VarToStr(EskiPer),[],[])
          end;
        end;
      end;
    end;

  if (Sender as TMenuItem).Tag in [4,99] then begin//Servis
    if (Sender as TMenuItem).Tag <> 99 then begin
      st:=Tablo.ListedenCokluSecim('Aktarýlacak Servis Bilgileri','select ID=0,ACIKLAMA=''Sorumlu'' union all select ID=1,ACIKLAMA=''Kabul Eden'' union all select ID=2,''Onay Alan'' union all select ID=3,''Onaylayacak'' union all select ID=4,''Onaylayan'' ',[Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],['ID','Açýklama']);
    end;
      if ((Sender as TMenuItem).Tag = 99)or((st.Count>0)and(TGirisKutusuEx.BilgiAlEx(BGPersonel_secimi, ctrls) = mrOk)) then begin
        if (EskiPer>0)and(YeniPer>0)and(EskiPer<>YeniPer) then begin
          for i := 0 to st.Count-1 do begin
            if st[i]='0' then //Sorumlu
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SERVIS set SORUMLU='+VarToStr(YeniPer)+' where ACKAPA = 0 and SORUMLU='+VarToStr(EskiPer),[],[])
            else if st[i]='1' then //Kabul Eden
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SERVIS set KABUL_EDEN='+VarToStr(YeniPer)+' where ACKAPA = 0 and KABUL_EDEN='+VarToStr(EskiPer),[],[])
            else if st[i]='2' then //Onay alan
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SERVIS set ONAYALAN='+VarToStr(YeniPer)+' where ACKAPA = 0 and ONAYALAN='+VarToStr(EskiPer),[],[])
            else if st[i]='3' then //onaylayacak
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SERVIS set ONAYLAYACAK='+VarToStr(YeniPer)+' where ACKAPA = 0 and ONAYLAYACAK='+VarToStr(EskiPer),[],[])
            else if st[i]='4' then //onaylayan
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SERVIS set ONAYLAYAN='+VarToStr(YeniPer)+' where ACKAPA = 0 and ONAYLAYAN='+VarToStr(EskiPer),[],[])
          end;
        end;
      end;
    end;

  st.Free;
  AraTusClick(Self);
end;

procedure TIKListeDlg.Zimmet2Click(Sender: TObject);
var
  ID: Integer;
begin
   tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
     ID := Tablo.DokumanSihirbazBaslat('E', 0, -1,Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger),1,TabNo_REHBER,REHBER.FieldByName('ID').AsInteger,REHBER.FieldByName('ID').AsInteger);
       if ID > 0 then
          TabloYenile(TabDokuman,[REHBER.FieldByName('ID').AsInteger]);

end;

function TIKListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TIKListeDlg.GorevEkleTusClick(Sender: TObject);
var
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin
     GorevId := Tablo.GorevOlustur('', Masaustu, 0, 0, 0, 0, REHBER.Fields[0].AsInteger, 0, 0,
                                   0, 0, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat);

      Tablo.GorevSihirbazBaslat(GorevDlg1, 'E', GorevId, AtamaYapildi, YorumYapildi);
      if AtamaYapildi then
         Gorev_EPostaGonder(1, GorevId)
      else if YorumYapildi then
         Gorev_EPostaGonder(3, GorevId);
      PageControlSekmeChange(Self);
      {GorevId := YeniGorevEkle(TabGorevler, ComboIsKlasor.EditValue,0, YeniGorevEdit, Key, DateEdit1, TimeEdit1, CheckBAYRAK,0,REHBER.Fields[0].AsInteger);
      Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', GorevId, AtamaYapildi, YorumYapildi);
      if not Potansiyel then // adaylara mail gitmez
         Gorev_EPostaGonder(1, GorevId);}
end;

procedure TIKListeDlg.GorevGridDBTableView1ACKAPASECIMPropertiesEditValueChanged( Sender: TObject);
begin
   TamamlandiIsaretleMenuClick(Self);
end;

procedure TIKListeDlg.GorevGridDBTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if AcellViewinfo.Item.Tag = 1 then begin
//     TamamlandiIsaretleMenuClick(Self);
//     Menu_Tamam(GorevlerMenu, GorevGridDBTableView1, Scheduler, FArama.TabListe.Fields[0].AsInteger);
     UpdateveMail(Masaustu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean,False);
     PlayWavFromResource('Blink');
     PageControlSekmeChange(Self);
  end;
  Abort;//Bunu kesinlikle silme (listede tek sat?r kal?nca hata verdi?i i?in eklendi)
end;

procedure TIKListeDlg.GorevGridDBTableView1DblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TIKListeDlg.GorevSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) = ID_OK then begin
     Tablo.GorevSil(TabGorevler.Fields[0].AsInteger);
     PageControlSekmeChange(Self);
  end;
end;

procedure TIKListeDlg.Gorunmez;
begin

end;

procedure TIKListeDlg.GorunmezOlacak;
begin

end;

procedure TIKListeDlg.Gorunur;
begin
  GrupListe := TStringList.Create;
  GrupListe.Delimiter := ',';        // Each list item will be blank separated
  GrupListe.QuoteChar := ',';        // And each item will be quoted with |'s
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
  IKGridViewDURUMAD.Visible := False;
  //FArama.AraFirma.SetFocus;
  cxPageControl1.ActivePageIndex := 0;
  if (FArama.AraFirma.Text <> '') or (FArama.AraKod.Text <> '') then //10012008HA
      AraTusClick(nil);
end;

procedure TIKListeDlg.GorunurOlacak;
begin

end;

procedure TIKListeDlg.GridIKDeneyimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridIKDeneyim;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridIKDeneyimView;
  AnaForm.pmGridStil.Tags.Values[GridIKDeneyim.Name] := 'IKIsDeneyimiGridi';
end;

procedure TIKListeDlg.GridIKDeneyimViewFIRMAPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var RehID : Integer;
begin
    RehID := Tablo.RehberAra_IDGetir(-1);
    if RehID > 0 then begin
       TabIsDeneyimi.Edit;
       TabIsDeneyimi.FieldByName('KURUM').Value := copy(Tablo.AciklamaGetir('REHBER', 'FIRMA', RehId),1,99)
    end;
end;

procedure TIKListeDlg.GridIKDeneyimViewILCEPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
begin
  if AButtonIndex = 0 then
  begin
    st := Tstringlist.Create;
    if tablo.ListedenBilgiGetir(KategoriListesi,
       'select * from ILILCE where  ILADI like ''%<ara>%'' or ILCEADI like ''%<ara>%'' ORDER BY 1,4 ', st, []) then begin
       TabIsDeneyimi.Edit;
       TabIsDeneyimi.FieldByName('ILCE').AsString := st.Strings[1];
       TabIsDeneyimi.FieldByName('IL').AsString := st.Strings[0];
    end;
    st.free;
  end
  else if AButtonIndex = 1 then
  begin
    TabIsDeneyimi.Edit;
    TabIsDeneyimi.FieldByName('BOLGE').AsInteger := 0;
    //EditDYeri.text := '';
  end;
end;

procedure TIKListeDlg.GridBankaDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TIKListeDlg.IKGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=IKGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=IKGridView;
  AnaForm.pmGridStil.Tags.Values[IKGrid.Name] := 'IKListeGridi';
end;

procedure TIKListeDlg.IKGridViewDblClick(Sender: TObject);
var srid:integer;
begin
  if IKGridView.Controller.SelectedRecordCount > 0 then begin
      srid:=IKGridView.DataController.FocusedRecordIndex;
      DegisTus.Click;

      IKGridView.DataController.FocusedRecordIndex:=srid;
      IKGridView.ViewData.Records[srid].Selected := false;
  end;
end;


procedure TIKListeDlg.IKGridViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   //if rehberdetayaktif then
   if REHBER.Active then
      PageControlSekmeChange(Self);
   if EkstreGorunsun then begin
      TabSheetEkstre.Visible := Pos('102.',REHBER.Fieldbyname('KOD').AsString)<>1;
      if AksiyonEkleTus.tag <> 99 then //g?rme yetkisivarsa
         AksiyonEkleTus.Visible := TabSheetEkstre.Visible;
   end;

   PageControlSekme.Visible := Tablo.YetkiVarmi(3401,YetkiTur_Gorme);
   //cxSplitter1.OpenSplitter;
end;

procedure TIKListeDlg.IKGridViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TIKListeDlg.GridDemirbasViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridDemirbas;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridDemirbasView;
  AnaForm.pmGridStil.Tags.Values[GridDemirbas.Name] := 'PersDemirbasGridi';
end;

procedure TIKListeDlg.GridDemirbasViewDblClick(Sender: TObject);
begin
   if Tablo.DemirbasSihirbazBaslat('D',0,TabDemirbasBilgi.FieldByName('ID').AsInteger) > 0 then
      PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.GridDemirbasViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TIKListeDlg.GridGrupViewSelectionChanged( Sender: TcxCustomGridTableView);
begin
   GrupListe.Clear;
   StringGrid1.RowCount := 1;
   if TabGrup.FieldCount>0 then begin
      GrupListe.DelimitedText := Tablo.AciklamaGetir('REHBER', 'NOTLAR', TabGrup.Fields[0].AsInteger);

      //GrupListe.DelimitedText := TabGrup.FieldByName('NOTLAR').AsString;
      for i := 0 to GrupListe.Count-1 do begin
         StringGrid1.RowCount := StringGrid1.RowCount + 1;
         stringgrid1.Cells[0,StringGrid1.RowCount-1] := GrupListe[i];
         stringgrid1.Cells[1,StringGrid1.RowCount-1] := Tablo.AciklamaGetir('REHBER', 'FIRMA', GrupListe[i]);

      end;
   end;
end;

procedure TIKListeDlg.GridPerTemelViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridPerTemel;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridPerTemelView;
  AnaForm.pmGridStil.Tags.Values[GridPerTemel.Name] := 'PersonelOZGridi';
end;

procedure TIKListeDlg.GridPerTemelViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TIKListeDlg.GridRehberIletisimViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   TabloYenile(TabFirIletisim, [REHBERILETISIM.Fields[0].AsInteger]);
   TabloYenile(TabResim, [REHBER.FieldByName('ID').AsInteger]);
end;

procedure TIKListeDlg.GridUcretViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridUcret;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUcretView;
end;

procedure TIKListeDlg.GridUcretViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TIKListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabloNo);
end;

procedure TIKListeDlg.iletisimDuzenleClick(Sender: TObject);
var
srid,ID:integer;
begin
     srid:=GridRehberIletisimView.DataController.FocusedRecordIndex;
     ID := Tablo.IKSihirbazBaslat(1, REHBER.Fields[0].AsInteger, REHBERILETISIM.Fields[0].AsInteger,-1, Potansiyel);
     if ID > 0 then begin
       REHBERILETISIM.Locate('ID', REHBERILETISIM.Fields[0].AsInteger, []);
       PageControlSekmeChange(Self);
     end;
     GridRehberIletisimView.DataController.FocusedRecordIndex:=srid;
     GridRehberIletisimView.ViewData.Records[srid].Selected:=True;
end;

procedure TIKListeDlg.iletisimEkleClick(Sender: TObject);
var RehIletID : Integer;
begin
  RehIletID:=Tablo.IKSihirbazBaslat(1, REHBER.Fields[0].AsInteger,-1, -1, Potansiyel);
  if RehIletID > 0 then begin
    PageControlSekmeChange(Self) ;
    REHBERILETISIM.Locate('ID', RehIletID, []);
    GridRehberIletisimViewSelectionChanged(nil);
  end;
end;

procedure TIKListeDlg.iletisimSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     CariIletisimSil(REHBER.Fields[0].AsInteger,REHBERILETISIM.Fields[0].AsInteger, REHBERILETISIM.FieldByName('VARSAYILAN').AsBoolean);
     PageControlSekmeChange(Self);
  end;
end;

procedure TIKListeDlg.IlgiliDuzenleTusClick(Sender: TObject);
var
srid:integer;
begin
  srid:=cxGridPersoneller.DataController.FocusedRecordIndex;
  if Tablo.IKSihirbazBaslat(4, REHBER.Fields[0].AsInteger,-1, TabRehberIlgili.Fields[0].AsInteger, Potansiyel)>0 then begin
    TabRehberIlgili.Locate('ID', TabRehberIlgili.Fields[0].AsInteger, []);
    PageControlSekmeChange(Self);
  end;
  cxGridPersoneller.DataController.FocusedRecordIndex:=srid;
  cxGridPersoneller.ViewData.Records[srid].Selected:=True;

end;

procedure TIKListeDlg.IlgiliEkleTusClick(Sender: TObject);
var PerID : Integer;
begin
  PerID :=Tablo.IKSihirbazBaslat(4, REHBER.Fields[0].AsInteger, -1,-1, Potansiyel);
  if PerID >0 then begin
    PageControlSekmeChange(Self) ;
    TabRehberIlgili.Locate('ID', PerID, []);
    cxGridPersonellerSelectionChanged(nil);
  end;
end;

procedure TIKListeDlg.IlgiliSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     CariIlgiliSil(REHBER.Fields[0].AsInteger,TabRehberIlgili.Fields[0].AsInteger, False); //TabRehberIlgili.FieldByName('VARSAYILAN').AsBoolean
     PageControlSekmeChange(Self);
  end;
end;

procedure TIKListeDlg.info1Click(Sender: TObject);
begin
   Tablo.InfoGoster('REHBER',  REHBER.FieldByName('ID').AsInteger)
end;

procedure TIKListeDlg.DilIptalTusClick(Sender: TObject);
begin
   TabDil.Cancel;
end;

procedure TIKListeDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint;
  Value: TStrings);
var
  j: SmallInt;
  ID, i : Integer;
  Ek, Klasor : string[10];
begin
  { for i := 0 to Value.Count - 1 do begin
      Ek := ExtractFileExt(Value.Strings[i]);
      Delete(Ek, 1, 1);
      Klasor := inttostr(Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_VarsayilanKlasor,0));
      Tablo.DokumanBelgeEkleDrop(ExtractFileName(Value.Strings[i]),+
                         FileSizeByName(Value.Strings[i])/1024,+
                         Strtoint(Klasor),+
                         REHBER.FieldByName('ID').AsInteger,+
                         SubeId,+
                         TabNo_REHBER,+
                         REHBER.FieldByName('ID').AsInteger,Value.Strings[i]);
     end;
     TabloYenile(TabDokuman,[REHBER.FieldByName('ID').AsInteger]);   }
 //for j := 0 to Value.Count - 1 do
    //Tablo.BelgeEkleme(Value.Strings[j], REHBER.FieldByName('ID').AsInteger , TabNo_REHBER, REHBER.FieldByName('ID').AsInteger, TabImaj);
end;

procedure TIKListeDlg.JvTimer1Timer(Sender: TObject);
var Grup, order : String;
begin
  JvTimer1.Enabled := False;
  //cxSplitter1.CloseSplitter;
  { Arama k?sm? hen?z ba?lat?lmad? ise ??k }
  if not Assigned(FArama) then Exit;
  //Animate1.Play(1,23,0);
//  if (FArama.AraFirma.Text='')and(FArama.AraYetkili.Text='')  and(FArama.Arailler.Text='') and(FArama.AraKod.Text='')and(not IKGridViewBORC.Visible) then exit;
  s := '';
  Fir := ' R.FIRMA ';
  Yet := ' P.FIRMA ';
  Kod := ' R.KOD ';

  //Pasifleri de arayacak m?y?z?
  s := '';
  order := ' ORDER BY R.SUBEID,R.FIRMA';

  if Potansiyel then begin
     TFirma := '%'+Trim(FArama.AraFirma2.Text) + '%';
     if FArama.AraFirma2.Text <> '' then
        s := s + ' and '+ Fir + ' LIKE ''' + TFirma +'''';
     if FArama.ComboCinsiyet.Text <> '' then
        s := s + ' and  R.STATU='+IntToStr(FArama.ComboCinsiyet.EditValue);
     if FArama.ComboOgrenim.Text <> '' then
        s := s + ' and  R.KATEGORI='+IntToStr(FArama.ComboOgrenim.EditValue);
     //PERS_DENEYIM tablosundan aranacak
     if FArama.ComboSektor.Text <> '' then
        s := s + ' and  PD.SEKTOR='+IntToStr(FArama.ComboSektor.EditValue);
     if FArama.ComboDepartman.Text <> '' then
        s := s + ' and  PD.DEPARTMAN='+IntToStr(FArama.ComboDepartman.EditValue);
     if FArama.ComboGorev.Text <> '' then
        s := s + ' and  PD.GOREV='+IntToStr(FArama.ComboGorev.EditValue);
     if FArama.ComboDil1.Text <> '' then
        s := s + ' and exists(select 1 from PERS_DIL DIL where DIL.REHBERID=R.ID and DIL='+IntToStr(FArama.ComboDil1.EditValue)+')';
     if FArama.ComboDil2.Text <> '' then
        s := s + ' and exists(select 1 from PERS_DIL DIL where DIL.REHBERID=R.ID and DIL='+IntToStr(FArama.ComboDil2.EditValue)+')';;
     if FArama.ComboIl.Text <> '' then
        s := s + ' and  PD.IL='+IntToStr(FArama.ComboIl.EditValue);
     if FArama.EditUyruk.Tag > 0 then
        s := s + ' and  R.ALTBOLGE='+IntToStr(FArama.EditUyruk.Tag);
     if (FArama.EditUcret.Text <> '')and(FArama.EditUcret2.Text <> '') then
        s := s + ' and  PD.TUR=0 and PD.UCRET_ALT between '+FArama.EditUcret.Text +' and '+FArama.EditUcret2.Text;

     if not FArama.CheckPasifler2.Checked then
        s := s + ' and R.DURUM>0 ';
  end else begin
     TFirma := '%'+Trim(FArama.AraFirma.Text) + '%';
//     TYet := '%'+Trim(FArama.AraYetkili.Text) + '%';
     TKod := '%'+Trim(FArama.AraKod.Text) + '%';
     if FArama.AraFirma.Text <> '' then
        s := s + ' and '+ Fir + ' LIKE ''' + TFirma +'''';
//     if FArama.AraYetkili.Text <> '' then
//        s := s + ' and '+ Yet + ' LIKE ''' + TYet +'''';
     if FArama.AraKod.Text <> '' then begin
        s := s + ' and '+ Kod + ' LIKE ''' + TKod+'''' ;
        order :=  '  ORDER BY R.SUBEID,' + Kod;     // and gorulmeyecekkod
     end;
     if not FArama.CheckPasifler.Checked then
        s := s + ' and R.DURUM>0 ';
  end;


//  if FArama.Arailler.Text  <> '' then     //il aramasi
//     s := s + ' and  X.BILGI = '''+Arama.Arailler.Text+''' ';
  if SubeVarmi then
     s := s + ' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ';

  case ModulYetki_TekSubeTum.IK of
     1: s := s + ' AND R.TEMSILCI='+Kullanan;//sadece kendi  g?r?r
    10: s := s + ' AND R.SUBEID='+IntToStr(SubeId);//sadece kendi þube  g?r?r
  end;

    //s := s + 'and (R.SUBEID ='+IntToStr(SubeId)+' or R.SUBEID = 0) ';

  REHBER.Close;
  if Potansiyel then
      REHBER.SQL.Text:= StringReplace(SQL_IK_Aday.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll])
  else
      REHBER.SQL.Text:= StringReplace(SQL_IK_Memo.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll]);;

  //REHBER.SQL.Text:=StringReplace(REHBER.SQL.Text,'set @DIL = -1','set @DIL = '+IntToStr(Dil),[rfReplaceAll]);
  REHBER.SQL.Add(s+order);
//  if FArama.AraYetkili.Text <> '' then
//     Param := 1
//  else
     Param := 0;
  TabloYenile(REHBER,[Param]);
end;

procedure TIKListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TIKListeDlg.KapatTusClick(Sender: TObject);
begin
  if Assigned(FKayitErisimIptalEdildi) then
    FKayitErisimIptalEdildi(Self);
//  FKayitErisimIptalEdildi := nil;
end;

procedure TIKListeDlg.KesintiDuzenleTusClick(Sender: TObject);
var
  I,PlanMaasID,RehberID,mResult:Integer;
  Etiket,Aciklama,KesintiKaynagi,Tarih,Tutar,Sira:Variant;
  Sonuc:Boolean;
begin
  if GridKesintiView.DataController.Controller.SelectedRecordCount > 0 then begin
    Tarih := TabKesinti.FieldByName('TARIH').Value;
    Tutar := TabKesinti.FieldByName('TUTAR').Value;
    Sira := TabKesinti.FieldByName('SIRA').Value;
    Aciklama := TabKesinti.FieldByName('ACIKLAMA').Value;
    KesintiKaynagi := Copy(TabKesinti.FieldByName('TUR').Value,0,1);

    RehberID := REHBER.FieldByName('ID').AsInteger;
    PlanMaasID := TabKesinti.FieldByName('ID').AsInteger;

    repeat
      mResult := TGirisKutusuEx.BilgiAlEx(BGMaas_kesintisi_duzenle,TGirdiDenetimleri.Create
      .DateTimePicker('Baþlama Tarihi*',@Tarih,TDateTimeKind.dtkDate,'yyyy-MM-dd')
      .CurrencyEdit('Aylýk Tutar *',@Tutar,2)
      .ImageComboBox('Kesinti kaynaðý *',@KesintiKaynagi,Tablo.FDCnn,'SELECT ''B'' TUR, ''Banka'' ADI UNION ALL SELECT ''K'' TUR, ''Kasa''')
      .ImageComboBox('Tür *',@Sira,Tablo.FDCnn,'SELECT SIRA, ETIKET FROM REHBERAYAR WHERE YERI=6 ')
      .Memo('Açýklama',@Aciklama));

      if (mResult <> mrCancel) and ((VarTostr(Tarih)='') or (VarTostr(KesintiKaynagi)='-1') or (VarTostr(Tutar)='') or (VarTostr(Etiket)='-1')) then begin
        ShowMessage(IKDoldurun);
        Sonuc := False;
      end else Sonuc := True;

      if mResult = mrCancel then Sonuc := True;
    until (Sonuc);

    if mResult = mrOk then begin
      Etiket := Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'SELECT ETIKET FROM REHBERAYAR WHERE YERI=6 AND SIRA=&SIRA',['&SIRA'],[Sira],True);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE PLANMAAS SET ETIKET=&ETIKET, SIRA=&SIRA, TUR=&TUR, '+
        ' TUTAR=&TUTAR, TARIH=&TARIH, DEGISTIREN=&DEGISTIREN, DEGISTIRMETARIHI=GETDATE(), ACIKLAMA=&ACIKLAMA'+
        ' WHERE ID=&ID',['&ETIKET','&SIRA','&TUR','&TUTAR','&TARIH','&ID','&DEGISTIREN','&ACIKLAMA'],
        [Etiket,Sira,''+Copy(KesintiKaynagi,0,1)+'',Tutar,FormatDateTime('yyyy-mm-dd',Tarih),PlanMaasID,Kullanan,Aciklama]);
        TabloYenile(TabKesinti,[RehberID]);
    end;
  end;
end;

procedure TIKListeDlg.KesintiEkleTusClick(Sender: TObject);
var
  I,RehberID,mResult:Integer;
  Sira,Etiket,Aciklama,Tutar,Tarih,Taksit,KesintiKaynagi:Variant;
  Sonuc:Boolean;
begin
  Taksit := 1;
  Tarih := Tablo.GENINI.BugunTrhSaat;
  KesintiKaynagi := 'K';

  repeat
    mResult := TGirisKutusuEx.BilgiAlEx(BGYeni_maas_kesintisi,TGirdiDenetimleri.Create
      .DateTimePicker('Baþlama Tarihi *',@Tarih,TDateTimeKind.dtkDate,'yyyy-MM-dd')
      .ImageComboBox('Kesinti kaynaðý *',@KesintiKaynagi,Tablo.FDCnn,'SELECT ''B'' TUR, ''Banka'' ADI UNION ALL SELECT ''K'' TUR, ''Kasa''')
      .CurrencyEdit('Aylýk Tutar *',@Tutar,2)
      .CurrencyEdit('Taksit *',@Taksit,0)
      .ImageComboBox('Tür *',@Sira,Tablo.FDCnn,'SELECT SIRA, ETIKET FROM REHBERAYAR WHERE YERI=6')
      .Memo('Açýklama',@Aciklama));

    if (mResult <> mrCancel) and ((VarTostr(Tarih)='') or (VarTostr(KesintiKaynagi)='-1') or (VarTostr(Tutar)='') or (VarTostr(Taksit)='') or (VarTostr(Sira)='-1')) then begin
      ShowMessage(IKDoldurun);
      Sonuc := False;
    end else if (StrToInt(Taksit) <= 0) or (StrToInt(Taksit) > 24) then begin
      ShowMessage(IKYanlis_taksit_sayisi);
      Sonuc := False;
    end else Sonuc := True;

    if mResult = mrCancel then Sonuc := True;
  until (Sonuc);

  if mResult = mrOk then begin
    RehberID := REHBER.FieldByName('ID').AsInteger;
    Etiket := Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'SELECT ETIKET FROM REHBERAYAR WHERE YERI=6 AND SIRA=&SIRA',['&SIRA'],[Sira],True);
    for I := 1 to Taksit do begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO PLANMAAS (ETIKET,SIRA,'+
      ' TUTAR, TARIH, YERID, EKLEYEN, EKLEMETARIHI, TUR, YER, KUR, ACIKLAMA) VALUES(&ETIKET,&SIRA,&TUTAR,&TARIH,&YERID,&EKLEYEN,GETDATE(),&TUR,1,&KUR,&ACIKLAMA)',
      ['&ETIKET','&SIRA','&TUTAR','&TARIH','&YERID','&EKLEYEN','&TUR','&KUR','&ACIKLAMA'],
      [Etiket,Sira,Tutar,''+FormatDateTime('yyyy-mm-dd',Tarih)+'',RehberID, Kullanan, ''+KesintiKaynagi+'', CariDoviz, ''+Aciklama+'']);

      Tarih := IncMonth(Tarih);
    end;
    TabloYenile(TabKesinti,[REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TIKListeDlg.KesintiSilTusClick(Sender: TObject);
var
  I,MResult,PlanMaasID:Integer;
begin
  if GridKesintiView.Controller.SelectedRecordCount > 0 then
  begin
    MResult := Application.MessageBox(PChar(KKayit_silinsinmi),PWideChar(Uyari),MB_YESNO+MB_ICONWARNING);
    if MResult = mrYes then
    begin
      for I := 0 to GridKesintiView.Controller.SelectedRecordCount-1 do
      begin
        PlanMaasID := GridKesintiView.Controller.SelectedRecords[I].Values[GridKesintiViewID.Index];
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'DELETE FROM PLANMAAS WHERE ID=&ID',['&ID'],[PlanMaasID]);
      end;
      TabloYenile(TabKesinti,[REHBER.FieldByName('ID').AsInteger]);
    end;
  end;
end;

procedure TIKListeDlg.Kopyala2Click(Sender: TObject);
var ID : Integer;
begin
  if TabCariListe.FieldByName('TUR').AsInteger in [13,17] then begin


    ID := Tablo.SQLSatiriKopyala('FATBASLIK',TabCariListe.FieldByName('CEKID').AsInteger,['TARIH', 'FATURATARIH', 'EKLEYEN', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
            [Tablo.GENINI.BugunTrh, Tablo.GENINI.BugunTrhSaat, Kullanan,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
       //TabFatBaslik.Close;
       //TabFatBaslik.Params[0].Value := ID;
       //TabFatBaslik.Open;
       //end;


    Tablo.TahakkukSihirbaziBaslat('K',TabCariListe.FieldByName('TUR').AsInteger,0,ID,TabCariListe.FieldByName('REHBERID').AsInteger,-1);
    PageControlSekmeChange(Self);
  end else if TabCariListe.FieldByName('TUR').AsInteger in [11,12,15,16] then begin   //10,14      irsaliye
    Tablo.FaturaSihirbazBaslat('K', TabCariListe.FieldByName('TUR').AsInteger ,0,TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('REHBERID').AsInteger, 1,False, -1);
    PageControlSekmeChange(Self);
  end else
    ShowMessage(RDAlisveSatisBelgeKopyalayin);
end;

procedure TIKListeDlg.LogoResimClick(Sender: TObject);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Rehber,REHBER.Fields[0].AsInteger);
   TabloYenile(TabResim,[REHBER.Fields[0].AsInteger]);
end;

procedure TIKListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TIKListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TIKListeDlg.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TIKListeDlg.Nakit3Click(Sender: TObject);
var Tur : SmallInt;
    HesapTuru : Char;
    Tutar : Currency;
    Kilit : Boolean;
begin
   Tur := TMenuItem(Sender).Tag;
   case Tur of
     21,31 : HesapTuru := 'K';
     22,32 : HesapTuru := 'B';
     23,33 : HesapTuru := 'V';
     24,34 : HesapTuru := 'V';
     25    : HesapTuru := 'P';
     35    : HesapTuru := 'V';
   else
      HesapTuru := '-';
   end;
   if Tur in [21..29] then
      Tutar := TabCariListe.FieldByName('BORC').AsCurrency
   else
      Tutar := TabCariListe.FieldByName('ALACAK').AsCurrency;
   case Tur of
     10,11,12,14,15,16 : Tablo.FaturaSihirbazBaslat('E', Tur,-1, -1, TabCariListe.FieldByName('REHBERID').AsInteger);
     9,19:  Tablo.SiparisSihirbazBaslat('E', Tur,-1, -1, TabCariListe.FieldByName('REHBERID').AsInteger);
     13,17 : Tablo.TahakkukSihirbaziBaslat('E', Tur, 0, -1, TabCariListe.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrhSaat, Kilit,TabCariListe.FieldByName('MASRAFID').AsInteger);
     21,22,25,31,32,35  : begin
     //ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,0, -1, RehberId, Tablo.GENINI.BugunTrhSaat, '-1');
       Application.CreateForm(TNakitDlg, NakitDlg);
       NakitDlg.ID := -1;
       NakitDlg.Tur := Tur;
       NakitDlg.HesapTuru := HesapTuru;
       NakitDlg.IslemOp := 'E';
       NakitDlg.RehberId := TabCariListe.FieldByName('REHBERID').AsInteger;
       NakitDlg.MakbuzTarih := Tablo.GENINI.BugunTrhSaat;
       NakitDlg.LabelTarih.Visible := True; //menüden kýsayol olduðu için tarih girilebilir
       NakitDlg.EditTarih.Visible := True;
       NakitDlg.MakbuzNo := SiradakiMakbuzNumarasi(Tur);
       NakitDlg.Aciklama := TabCariListe.FieldByName('ACIKLAMA').AsString;
       NakitDlg.MasrafId:= TabCariListe.FieldByName('MASRAFID').AsInteger;
       NakitDlg.Tutar := Tutar;
       NakitDlg.Kur := TabCariListe.FieldByName('KUR').AsString;
       NakitDlg.showmodal;
       if NakitDlg.ModalResult = mrOk  then
       NakitDlg.Destroy;
     end;
     23,33 : Tablo.CekSihirbazBaslat('E', Tur, 1, 0, -1, TabCariListe.FieldByName('REHBERID').AsInteger,-1,Tablo.GENINI.BugunTrhSaat, '');
     24,34 : Tablo.CekSihirbazBaslat('E', Tur, 2, 0, -1, TabCariListe.FieldByName('REHBERID').AsInteger,-1,Tablo.GENINI.BugunTrhSaat, '');
   end;
   PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.OzlukDuzenleTusClick(Sender: TObject);
begin
  if Tablo.IKSihirbazBaslat( 3, REHBER.Fields[0].AsInteger,-1, -11,  Potansiyel) > 0 then
    PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.PageControlGiderChange(Sender: TObject);
begin
  PageControlSekmeChange(Self);
end;

procedure TIKListeDlg.IlgiliAraEditPropertiesChange(Sender: TObject);
begin
  TabloYenile( TabRehberIlgili, [REHBER.Fields[0].AsInteger]);
  if not TabRehberIlgili.IsEmpty then begin
     cxGridPersoneller.DataController.FocusedRecordIndex:=0;
     cxGridPersoneller.ViewData.Records[0].Selected:=True;
  end;

  IlgiliSilTus.Visible := not TabRehberIlgili.IsEmpty;
  IlgiliDuzenleTus.Visible := IlgiliSilTus.Visible;
end;

procedure TIKListeDlg.PageControlSekmeChange(Sender: TObject);
var AcKapa:String[1];
    GunSay : Smallint;
    ARecIndex:Integer;
begin
  if not(REHBER.Active)or(REHBER.IsEmpty) then
    Exit;
  if (PageControlSekme.ActivePageIndex > 0)and(REHBER.Fields[0].AsInteger<>SonEklenenCari) then
     Tablo.SKRehberEkle(REHBER.Fields[0].AsInteger);
  if PageControlSekme.ActivePage=TabSheetIlet then begin
     TabloYenile(REHBERILETISIM,[REHBER.Fields[0].AsInteger]);
     GridRehberIletisimViewSelectionChanged(GridRehberIletisimView);
  end else if PageControlSekme.ActivePage=TabSheetIlgili then
     IlgiliAraEditPropertiesChange(Self)
  else if PageControlSekme.ActivePage=TabSheetIsDeneyimi then
     TabloYenile(TabIsDeneyimi,[REHBER.Fields[0].AsInteger])
  else if PageControlSekme.ActivePage=TabYorumMedya then
          Tabloyenile(TabYorum,[TabloNo, REHBER.FieldByName('ID').AsInteger])
  else if PageControlSekme.ActivePage=TabSheetOzluk then begin
      TabloYenile(TabPerTemel,[REHBER.Fields[0].AsInteger]);
      TabloYenile(TabDil,[REHBER.Fields[0].AsInteger]);
  end else if PageControlSekme.ActivePage=TabSheetMaas then begin
      TabloYenile(TabUcret,[REHBER.Fields[0].AsInteger]);
      TabloYenile(TabKesinti, [REHBER.Fields[0].AsInteger]);
      Tablo.TablodanSorguAc(1,'SELECT TOP 1 TUTAR, KUR FROM PLANMAAS WHERE YER=51 AND YERID='+REHBER.Fields[0].AsString);
      Tablo.TablodanSorguAc(4,'SELECT TUTAR FROM PLANMAAS WHERE YER=61 AND YERID='+REHBER.Fields[0].AsString);
      if not Tablo.Query1.IsEmpty then
        LabelBankadanOdeme.Caption := Tablo.Query1.Fields[0].AsString + ' ' + CariDoviz
      else LabelBankadanOdeme.Caption := '---';
      if (not Tablo.Query4.IsEmpty) and (Tablo.Query4.Fields[0].AsString <> '') then
        LabelStandartAvans.Caption := Tablo.Query4.Fields[0].AsString + ' ' + CariDoviz
      else LabelStandartAvans.Caption := '---';
  end else if PageControlSekme.ActivePage=TabSheetDemirbas then begin
      TabloYenile(TabDemirbasBilgi,[REHBER.Fields[0].AsInteger]);
  end else if PageControlSekme.ActivePage=TabSheetIzinBilgileri then begin
        if PmIzinTurleri.Items.Count<1 then begin
            Tablo.TablodanSorguAc(1,'Select ANAHTAR,DEGER FROM GENINI WITH (NOLOCK) Where BOLUM='+IntToStr(Ops_IzinTurleri)+' and DIL='+IntToStr(Dil)+' Order by 2 ');
            while not Tablo.Query1.eof do begin
               PmIzinTurleri.Items.ItemOperation(moAdd,Tablo.Query1.Fields[0].AsString,YeniPerizinClick,-1,'',Tablo.Query1.Fields[1].AsInteger);
               if Tablo.Query1.Fields[1].AsInteger=-1 then //Hakediþ altýna çizgi çizelim
                  PmIzinTurleri.Items.ItemOperation(moAdd,'-',nil,-1,'',-1);
               Tablo.Query1.Next;
            end;
        end;

        SETarihBit.value:=YearOf(Tablo.GENINI.BugunTrh);
        SETarihBas.value:=SETarihBit.value-1;
        RadioIzinTarihClick(Self);
  end else  if PageControlSekme.ActivePage=TabSheetGorev then begin
    AcKapa:=IntToStr(Abs(StrToInt(BoolToStr(CheckTamamlanan.Checked))));
    if CheckTamamlanan.Checked then
       GunSay := ComboTamamlanan.EditValue
    else
       GunSay := 9999;
    TabloYenile(TabGorevler,[REHBER.FieldByName('ID').AsString, AcKapa,  GunSay]);

    //GorevGridDBTableView1.ViewData.Expand(True);

  end else if PageControlSekme.ActivePage = TabSheetHareketler then
      TabloYenile(TabHareketler,[REHBER.Fields[0].AsInteger])
  else if PageControlSekme.ActivePage=TabSheetEkstre then begin
    CalendarEkstreBasPropertiesChange(Self);
  end else if PageControlSekme.ActivePage=TabSheetPDKS then begin
     Tablo.TablodanSorguAc(1, 'select isnull(TEMAS,0) from REHBER where ID='+ REHBER.Fields[0].AsString);
     CheckPDKSTakibi.Checked := Tablo.Query1.Fields[0].AsInteger=1;
  end;

end;

procedure TIKListeDlg.RadioDonemTarihClick(Sender: TObject);
begin
      SETarihBas.visible :=False;
      SETarihBit.visible :=False;
end;

procedure TIKListeDlg.RadioIzinTarihClick(Sender: TObject);
begin
    //tarih bas?ld?
      SETarihBas.visible :=True;
      SETarihBit.visible :=True;
      SETarihBasPropertiesChange(self);
end;

procedure TIKListeDlg.REHBERBeforeOpen(DataSet: TDataSet);
begin
  rehberdetayaktif:=False;
end;


initialization
  RegisterClass(TIKListeDlg);
end.

{
procedure TIKListeDlg.TBtnHareketlerEkleClick(Sender: TObject);
begin
  if REHBER.Fields[0].IsNullOrEmpty then Exit;

  if RehberPersonelHareket = nil then
     Application.CreateForm(TRehberPersonelHareket,RehberPersonelHareket);
  if not RehberPersonelHareket.TabHareket.Active then
     RehberPersonelHareket.TabHareket.Open;

  RehberPersonelHareket.RehberID := REHBER.Fields[0].AsInteger;
  RehberPersonelHareket.TabHareket.Append;
  RehberPersonelHareket.TabHareket.FieldByName('REHBERID').Value := REHBER.Fields[0].AsInteger;
  RehberPersonelHareket.Caption := REHBER.FieldByName('ADSOYAD').AsString;
  RehberPersonelHareket.ShowModal;

  if RehberPersonelHareket.ModalResult = mrOk then
  begin
    TabloYenile(TabHareketler,[REHBER.Fields[0].AsInteger]);
  end;
  FreeAndNil(RehberPersonelHareket);
end;
}










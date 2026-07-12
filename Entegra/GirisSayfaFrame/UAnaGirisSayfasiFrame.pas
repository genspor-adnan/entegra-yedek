unit UAnaGirisSayfasiFrame;
// TUR : 1-Bilgi, 2-Uyarı, 3-Hata
// KAYNAK : 1 : Sistem
// KATEGORI : 1 Cari, 2 Kasa, 3 Banka, 4 Fatura, 5 ÇekSenet, 6 Stok, 7 Teklif

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ComCtrls,
  Dialogs, JvExControls, JvLinkLabel, ExtCtrls, JvExExtCtrls, JvExtComponent, msxmldom,
  JvPanel, StdCtrls, JvShape, UGentegreFrameYonetimi, dxGDIPlusClasses, JvTimer, xmldom,
  UFrameYoneticisi, Buttons, dxSkinsCore, cxStyles, dxSkinscxPCPainter, JvDesktopAlert,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, OverbyteIcsWSocket,
  cxDBData, cxImageComboBox, cxGridLevel, cxGridCustomTableView, dxCore, cxGridDBCardView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, //GraphicEx,
  cxGrid, cxTextEdit, cxMemo, cxDBEdit, cxContainer, cxCheckBox, DBCtrls, FireDAC.Comp.Client, ImgList,
  cxMaskEdit, cxDropDownEdit, cxImage, cxLabel, cxHyperLinkEdit, UDoviz, cxDateUtils,
  dxSkinLondonLiquidSky, cxPC, cxDataUtils, cxLookAndFeels, cxPCdxBarPopupMenu, cxNavigator,
  cxSpinEdit, Menus, cxCurrencyEdit, cxCalendar, cxLookAndFeelPainters, WinSock, XMLDoc,
  cxGroupBox, cxRadioGroup, PngImageList, cxProgressBar, cxButtonEdit, FetaKurulusSiniflari,
  cxGridChartView, cxGridDBChartView, cxButtons, cxEditRepositoryItems, cxGridCardView,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, OverbyteIcsWndControl,
  CategoryButtons, JvLED, ToolWin, JvButton, JvNavigationPane, cxTreeView, JvComponentBase,
  JvBaseDlg, XMLIntf, IdGlobalProtocols, Generics.Collections, cxGridCustomLayoutView,
  dxBarBuiltInMenu, dxSkinLiquidSky, dxCustomTileControl, dxTileControl,
  cxSchedulerRibbonStyleEventEditor, cxScheduler, cxSchedulerStorage,
  cxSchedulerCustomControls, cxSchedulerCustomResourceView, cxSchedulerDayView,
  cxSchedulerDateNavigator, cxSchedulerHolidays, cxSchedulerTimeGridView,
  cxSchedulerUtils, cxSchedulerWeekView, cxSchedulerYearView, DateUtils,
  cxSchedulerGanttView, cxSchedulerRecurrence, cxSchedulerTreeListBrowser,
  dxSkinscxSchedulerPainter, frxClass, frxDBSet, cxSchedulerDBStorage,
  cxCustomPivotGrid, cxDBPivotGrid, JvExComCtrls, JvDateTimePicker, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark, IdGlobal,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, cxGridCustomPopupMenu, cxGridPopupMenu,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, cxSchedulerAgendaView, System.ImageList, dxCoreGraphics, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;//  cxSchedulerAgendaView;

type
  TChatWindow = class;

  TFileSendInfo = class;

  TAnaGirisSayfasiFrame = class(TFrame, IAnaBilgiFrame, IBilgiFrame)
    TabMesajKisiler: TFDQuery;
    DtsMesajKisiler: TDataSource;
    TabSK: TFDQuery;
    DtsSK: TDataSource;
    PmSagClick: TPopupMenu;
    anaPanel: TPanel;
    TabKosul: TFDQuery;
    TabDokum: TFDQuery;
    DtsKosul: TDataSource;
    TabArama: TFDQuery;
    DtsArama: TDataSource;
    ChatTimer: TTimer;
    PanelOrta: TPanel;
    PageControlOrta: TcxPageControl;
    SheetArama: TcxTabSheet;
    SheetMesajlasma: TcxTabSheet;
    SheetYonetimFinans: TcxTabSheet;
    pnlHaberler: TPanel;
    Panel8: TPanel;
    Label8: TLabel;
    cxGrid1: TcxGrid;
    GridAraView: TcxGridDBTableView;
    GridAraViewID: TcxGridDBColumn;
    GridAraViewModul: TcxGridDBColumn;
    GridAraViewArananId: TcxGridDBColumn;
    GridAraViewKod: TcxGridDBColumn;
    GridAraViewAd: TcxGridDBColumn;
    GridAraViewAranan: TcxGridDBColumn;
    GridAra: TcxGridLevel;
    SQLMemoAra: TcxMemo;
    pnlMesajlasma: TPanel;
    Panel18: TPanel;
    Label12: TLabel;
    ScrollBox2: TScrollBox;
    cxGrid4: TcxGrid;
    cxGrid4DBTableViewKisiler: TcxGridDBTableView;
    cxGrid4DBTableViewKisilerColumn1: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    PanelChat: TPanel;
    PageControlChat: TcxPageControl;
    Panel4: TPanel;
    BtnMesajGonder: TcxButton;
    MemoChat: TcxRichEdit;
    SheetYonetimCRM: TcxTabSheet;
    SheetYonetimTeklif: TcxTabSheet;
    SheetYonetimServis: TcxTabSheet;
    ScrollBoxYoneticiSag: TScrollBox;
    Panel1: TPanel;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    cxButton1: TcxButton;
    cxGrid3: TcxGrid;
    cxGrid3DBCardView1: TcxGridDBCardView;
    cxGrid3DBCardView1Row1: TcxGridDBCardViewRow;
    cxGrid3DBCardView1Row2: TcxGridDBCardViewRow;
    cxGridLevel5: TcxGridLevel;
    Panel3: TPanel;
    cxButton2: TcxButton;
    pageFinans: TcxPageControl;
    PageCRM: TcxPageControl;
    PageTeklif: TcxPageControl;
    PageServis: TcxPageControl;
    PanelYoneticiUst: TPanel;
    Label11: TLabel;
    KosulButon: TSpeedButton;
    SheetGiris: TcxTabSheet;
    pnlGenel: TJvPanel;
    Label5: TLabel;
    Label6: TLabel;
    Shape1: TShape;
    MesajLED: TJvLED;
    MesajMenu: TPopupMenu;
    KonusmaGecmisiMenu: TMenuItem;
    PopupMenuGrafik: TPopupMenu;
    KosullarMenu: TMenuItem;
    YenileMenu: TMenuItem;
    N1: TMenuItem;
    DokumAyarlarMenu: TMenuItem;
    YeniDokumMenu: TMenuItem;
    DokumuKopyalaMenu: TMenuItem;
    DokumSilMenu: TMenuItem;
    N2: TMenuItem;
    DokumKaydetMenu: TMenuItem;
    Panel9: TPanel;
    btnArama: TJvNavPanelButton;
    PanelAktiviteGorev: TPanel;
    btnGorev: TJvNavPanelButton;
    btnAktivite: TJvNavPanelButton;
    PanelMesajDuyuru: TPanel;
    BtnDuyuru: TJvNavPanelButton;
    BtnMesaj: TJvNavPanelButton;
    PanelHaberPiyasa: TPanel;
    BtnKDR: TJvNavPanelButton;
    PNGImageList1: TPngImageList;
    PngImageList2: TPngImageList;
    JvDesktopAlert1: TJvDesktopAlert;
    PopupDuyuru: TPopupMenu;
    YorumYaz1: TMenuItem;
    EditAra: TcxTextEdit;
    AraTus: TcxButton;
    JvDesktopAlertStack1: TJvDesktopAlertStack;
    Panel20: TPanel;
    pnlImage: TJvPanel;
    PopHavaDurumu: TPopupMenu;
    ehirDeitir1: TMenuItem;
    Yenile1: TMenuItem;
    PngImageList3: TPngImageList;
    ImageList1: TImageList;
    XMLDocument1: TXMLDocument;
    IdHTTP1: TIdHTTP;
    Panel10: TPanel;
    MesajPersonAra: TcxButtonEdit;
    BtnDosyaGonder: TcxButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    JvTimer1: TJvTimer;
    SheetDuyurular: TcxTabSheet;
    Panel2: TPanel;
    Label2: TLabel;
    EditDuyuruArama: TcxTextEdit;
    DuyuruYenileTus: TcxButton;
    GridDuyuru: TcxGrid;
    TabDuyuruListe: TFDQuery;
    DtsDuyuruListe: TDataSource;
    GridDuyuruDBCardView: TcxGridDBCardView;
    GridDuyuruLevel1: TcxGridLevel;
    GridDuyuruDBCardViewID: TcxGridDBCardViewRow;
    GridDuyuruDBCardViewKONU: TcxGridDBCardViewRow;
    GridDuyuruDBCardViewDUYURUAD: TcxGridDBCardViewRow;
    GridDuyuruDBCardViewZAMAN: TcxGridDBCardViewRow;
    GridDuyuruDBCardViewKATEGORI: TcxGridDBCardViewRow;
    GridDuyuruDBCardViewONAY: TcxGridDBCardViewRow;
    GridDuyuruDBCardViewRED: TcxGridDBCardViewRow;
    GridDuyuruDBCardViewGUN: TcxGridDBCardViewRow;
    lblKullanici: TcxLabel;
    cxLabel1: TcxLabel;
    ProfilResim: TcxImage;
    SheetKDR: TcxTabSheet;
    TabKDR: TFDQuery;
    DtsKDR: TDataSource;
    KDRListe: TCategoryButtons;
    PanelProje: TPanel;
    btnServis: TJvNavPanelButton;
    BtnProje: TJvNavPanelButton;
    SheetNakitAkisi: TcxTabSheet;
    PageControl: TcxPageControl;
    TabSheetTakvim: TcxTabSheet;
    Scheduler: TcxScheduler;
    pnlControls: TPanel;
    Memo1: TMemo;
    GridToplam: TcxGrid;
    ToplamView: TcxGridDBTableView;
    ToplamViewYON: TcxGridDBColumn;
    ToplamViewTUR: TcxGridDBColumn;
    ToplamViewTUTAR: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    MemoFatura: TMemo;
    MemoOdeme: TMemo;
    MemoPlanButce: TMemo;
    MemoPlanKredi: TMemo;
    MemoPlanMaas: TMemo;
    MemoTakvimCekKendi: TMemo;
    MemoTakvimCekMusteri: TMemo;
    MemoTakvimOdemePlan: TMemo;
    MemoTakvimPlanKK: TMemo;
    MemoTakvimTahsilatPlan: TMemo;
    MemoTakvimSenetMusteri: TMemo;
    MemoTakvimSenetKendi: TMemo;
    MemoTakvimGider: TMemo;
    MemoTakvimGelir: TMemo;
    MemoTakvimPOS: TMemo;
    MemoBaslangic: TMemo;
    TabSheetPivot: TcxTabSheet;
    Label3: TLabel;
    Panel5: TPanel;
    LabelBittar: TJvDateTimePicker;
    cxImageComboBox1: TcxImageComboBox;
    Memo2: TMemo;
    pivot: TcxDBPivotGrid;
    pivotGRUP: TcxDBPivotGridField;
    pivotTUR: TcxDBPivotGridField;
    pivotTARIH: TcxDBPivotGridField;
    pivotTUTAR: TcxDBPivotGridField;
    FGrid: TcxGrid;
    FGridTableView: TcxGridDBTableView;
    FGridTableViewGRUP: TcxGridDBColumn;
    FGridTableViewTUR: TcxGridDBColumn;
    FGridTableViewTARIH: TcxGridDBColumn;
    FGridTableViewTUTAR: TcxGridDBColumn;
    FGridDBTableView1: TcxGridDBTableView;
    FGridDBTableView1DURUM: TcxGridDBColumn;
    FGridDBTableView1VADE: TcxGridDBColumn;
    FGridDBTableView1SERINO: TcxGridDBColumn;
    FGridDBTableView1HESAPADI: TcxGridDBColumn;
    FGridDBTableView1Column1: TcxGridDBColumn;
    FGridLevel1: TcxGridLevel;
    TabSheetGrafik: TcxTabSheet;
    GridGrafik: TcxGrid;
    GridGrafikDBChartView: TcxGridDBChartView;
    GridGrafikDBChartViewGUN: TcxGridDBChartSeries;
    GridGrafikDBChartViewAYADI: TcxGridDBChartSeries;
    GridGrafikDBChartViewBAKIYE: TcxGridDBChartSeries;
    GridGrafikLevel1: TcxGridLevel;
    SqlMemoGrafik: TMemo;
    SqlGrafikPOS: TMemo;
    SqlGrafikMaas: TMemo;
    SqlGrafikKK: TMemo;
    SqlGrafikKredi: TMemo;
    SqlGrafikGider: TMemo;
    SqlGrafikGelir: TMemo;
    SqlGrafikSenetMusteri: TMemo;
    SqlGrafikSenetKendi: TMemo;
    SqlGrafikCekKendi: TMemo;
    SqlGrafikCekMusteri: TMemo;
    SqlGrafikOdemePlan: TMemo;
    SqlGrafikTahsilatPlan: TMemo;
    TabSheetListe: TcxTabSheet;
    Panel6: TPanel;
    DateTimeListeBitis: TJvDateTimePicker;
    CheckTahsilat: TcxCheckBox;
    CheckOdeme: TcxCheckBox;
    GridListe: TcxGrid;
    GridListeView: TcxGridDBTableView;
    GridListeViewTIPI: TcxGridDBColumn;
    GridListeViewPLANTARIHI: TcxGridDBColumn;
    GridListeViewKOD: TcxGridDBColumn;
    GridListeViewFIRMA: TcxGridDBColumn;
    GridListeViewISTEL: TcxGridDBColumn;
    GridListeViewBORC: TcxGridDBColumn;
    GridListeViewKUR: TcxGridDBColumn;
    GridListeViewTAHSILAT: TcxGridDBColumn;
    GridListeViewODEME: TcxGridDBColumn;
    GridListeViewACIKLAMA: TcxGridDBColumn;
    GridListeLevel1: TcxGridLevel;
    SQLListe: TMemo;
    ToolBar1: TToolBar;
    AylikTus: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton3: TToolButton;
    YaziciYaz: TToolButton;
    SchedulerDBStorage: TcxSchedulerDBStorage;
    SchedulerDataSource: TDataSource;
    TabTakvim: TFDQuery;
    PopupMenu1: TPopupMenu;
    Gizle1: TMenuItem;
    BilgileriDegisMenu: TMenuItem;
    SilMenu: TMenuItem;
    N3: TMenuItem;
    BuguneaksiyonekleMenu: TMenuItem;
    DtsToplam: TDataSource;
    TabToplam: TFDQuery;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem3: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem4: TMenuItem;
    EMail1: TMenuItem;
    MenuItem5: TMenuItem;
    frxTAKVIM: TfrxDBDataset;
    TAKVIM: TFDQuery;
    TabGrafik: TFDQuery;
    DsTabGrafik: TDataSource;
    TabPivot: TFDQuery;
    TabPivotGRUP: TWideStringField;
    TabPivotTUR: TWideStringField;
    TabPivotTARIH: TSQLTimeStampField;
    TabPivotTUTAR: TFloatField;
    DtsPivot: TDataSource;
    pmPivot: TPopupMenu;
    ExcelPivot1: TMenuItem;
    DtsListe: TDataSource;
    TabListe: TFDQuery;
    PopupMenuListe: TPopupMenu;
    MenuListeDuzenle: TMenuItem;
    N5: TMenuItem;
    MenuListeSil: TMenuItem;
    ToolButton1: TToolButton;
    GridDuyuruDBCardViewYER: TcxGridDBCardViewRow;
    cxGridPopupMenu1: TcxGridPopupMenu;
    SheetStok: TcxTabSheet;
    dxTileControl2: TdxTileControl;
    dxTileControlGroup1: TdxTileControlGroup;
    dxTileControlGroup2: TdxTileControlGroup;
    KDR_DONEM_BASI: TdxTileControlItem;
    KDR_DONEM_SONU: TdxTileControlItem;
    KDR_STMM: TdxTileControlItem;
    dxTileControlItem5: TdxTileControlItem;
    KDR_ALIS_FATURA_TUTAR: TdxTileControlItem;
    KDR_SATIS_FATURA_TUTAR: TdxTileControlItem;
    dxTileControlItem13: TdxTileControlItem;
    KDR_BRUT_KAR_ZARAR: TdxTileControlItem;
    Panel7: TPanel;
    GridStok: TcxGrid;
    GridStokView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    dxTileControl1: TdxTileControl;
    dxTileControl1Group1: TdxTileControlGroup;
    dxTileControl1Group2: TdxTileControlGroup;
    KDR_BORCLULAR: TdxTileControlItem;
    KDR_ALINAN_CEK: TdxTileControlItem;
    KDR_ALACAKLILAR: TdxTileControlItem;
    KDR_STOK: TdxTileControlItem;
    KDR_KASA: TdxTileControlItem;
    KDR_ALINAN_SENET: TdxTileControlItem;
    KDR_BANKA: TdxTileControlItem;
    KDR_KREDILER: TdxTileControlItem;
    KDR_KREDI_KARTI: TdxTileControlItem;
    KDR_VERILEN_CEK: TdxTileControlItem;
    KDR_VERILEN_SENET: TdxTileControlItem;
    KDR_POS: TdxTileControlItem;
    dxTileControl1Item5: TdxTileControlItem;
    KDR_SONUC: TdxTileControlItem;
    TabKDRStok: TFDQuery;
    DtsKDRStok: TDataSource;
    cxLabel2: TcxLabel;
    CalendarDonemBas: TcxDateEdit;
    cxLabel3: TcxLabel;
    CalendarDonemSon: TcxDateEdit;
    ButtonDonemStokYenile: TcxButton;
    PanelKDR_Sag: TPanel;
    GridKDR: TcxGrid;
    GridKDRView: TcxGridDBTableView;
    GridKDRViewColumn1: TcxGridDBColumn;
    GridKDRViewTUR: TcxGridDBColumn;
    GridKDRViewTUTAR: TcxGridDBColumn;
    GridKDRViewAD: TcxGridDBColumn;
    GridKDRLevel1: TcxGridLevel;
    Panel11: TPanel;
    cxLabel4: TcxLabel;
    DateKDRDonemBas: TcxDateEdit;
    cxLabel5: TcxLabel;
    DateKDRDonemSon: TcxDateEdit;
    cxButton3: TcxButton;
    duyuruMemo: TcxMemo;
    procedure pnlBankaTanimlariPaint(Sender: TObject);
    procedure pnlBankaTanimlariMouseEnter(Sender: TObject);
    procedure CheckPasifPropertiesEditValueChanged(Sender: TObject);
    procedure SetHavaDurumuImage(const Value: Integer);
    procedure GorevGridViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure tvProjelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure tvAktivitelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure DokumAyarlarMenuClick(Sender: TObject);
    procedure TabDokumAfterScroll(DataSet: TDataSet);
    procedure TabKosulNewRecord(DataSet: TDataSet);
    procedure YenileMenuClick(Sender: TObject);
    procedure TabDokumNewRecord(DataSet: TDataSet);
    procedure PageCRMChange(Sender: TObject);
    procedure PageTeklifChange(Sender: TObject);
    procedure PageServisChange(Sender: TObject);
    procedure DokumKaydetMenuClick(Sender: TObject);
    procedure cxGridDBColumn2GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure SpeedButton1Click(Sender: TObject);
    procedure KosullarMenuClick(Sender: TObject);
    procedure DokumSilMenuClick(Sender: TObject);
    procedure cxEditRepository1ButtonItem1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure DokumuKopyalaMenuClick(Sender: TObject);
    procedure AraTusClick(Sender: TObject);
    procedure GridAraViewDblClick(Sender: TObject);
    procedure EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure PageControlChatPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure MsgClientConnected(Sender: TObject);
    procedure ChatTimerTimer(Sender: TObject);
    procedure pageFinansChange(Sender: TObject);
    procedure MemoChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ProfilResimClick(Sender: TObject);
    procedure cxGrid4DBTableViewKisilerCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure PageControlChatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure KonusmaGecmisiMenuClick(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure btnAramaClick(Sender: TObject);
    procedure JvDesktopAlert1MessageClick(Sender: TObject);
    procedure ehirDeitir1Click(Sender: TObject);
    procedure pnlImagePaint(Sender: TObject);
    procedure Yenile1Click(Sender: TObject);
    procedure cxGridDBTableView1OKUNMAMISYORUMSAYStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure BtnDosyaGonderClick(Sender: TObject);
    procedure PageControlChatCanClose(Sender: TObject; var ACanClose: Boolean);
    procedure JvTimer1Timer(Sender: TObject);
    procedure GorevGridViewStylesGetGroupStyle(Sender: TcxGridTableView;
      ARecord: TcxCustomGridRecord; ALevel: Integer; var AStyle: TcxStyle);
    procedure TabDokumBeforePost(DataSet: TDataSet);
    procedure GridDuyuruDBCardViewStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridDuyuruDBCardViewRow7PropertiesCustomClick(Sender: TObject);
    procedure DuyuruYenileTusClick(Sender: TObject);
    procedure EditDuyuruAramaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure pnlImageDblClick(Sender: TObject);
    procedure Panel20DblClick(Sender: TObject);
    procedure GridDuyuruDBCardViewRow7PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KDRListeCategories0Items0Click(Sender: TObject);
    procedure KDRListeCategories0Items2Click(Sender: TObject);
    procedure KDRListeCategories1Items0Click(Sender: TObject);
    procedure KDRListeCategories2Items0Click(Sender: TObject);
    procedure KDRListeCategories3Items0Click(Sender: TObject);
    procedure KDR_BORCLULARClick(Sender: TdxTileControlItem);
    procedure KDRListeCategories0Items1Click(Sender: TObject);
    procedure BuguneaksiyonekleMenuClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure DateTimeListeBitisChange(Sender: TObject);
    procedure ExcelPivot1Click(Sender: TObject);
    procedure Gizle1Click(Sender: TObject);
    procedure LabelBittarChange(Sender: TObject);
    procedure MenuListeDuzenleClick(Sender: TObject);
    procedure SchedulerDateNavigatorSelectionChanged(Sender: TObject;
      const AStart, AFinish: TDateTime);
    procedure SchedulerDblClick(Sender: TObject);
    procedure AylikTusClick(Sender: TObject);
    procedure GridListeViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure ToolButton1Click(Sender: TObject);
    procedure MenuListeSilClick(Sender: TObject);
    procedure GridDuyuruDBCardViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure GridDuyuruDBCardViewCustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo;
      var ADone: Boolean);
    procedure GridDuyuruDBCardViewONAYPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridKDRViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure KDRListeCategories4Items0Click(Sender: TObject);
    procedure cxLabel2Click(Sender: TObject);
    procedure ButtonDonemStokYenileClick(Sender: TObject);
    procedure KDR_DONEM_BASIClick(Sender: TdxTileControlItem);
    procedure GridStokViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxButton3Click(Sender: TObject);
  private
    { IBilgiFrame üyeleri }
    FFrameBilgi: TAnaFrameBilgi;
    FFrameIcerikBilgi :TIcerikFrameBilgi;
    Initialized: Boolean;
    //FHavaDurumuImage: Integer;
    FChatWindows: TObjectList<TChatWindow>;
    FOnlineUsers: TStringList;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi: TAnaFrameBilgi;
    procedure SetFrameBilgi(AValue: TAnaFrameBilgi);
    procedure IcerikFrameAktifOlacak(Sender: TIcerikFrameBilgi);
    procedure OlayListele;
    procedure GrafikOlustur(Yenile: Boolean; PageControl1: TcxPageControl);
    procedure OkunmamisDialoglariGetir;
    procedure YoneticiDokumuOlustur(Modul: string; APageControl: TcxPageControl);
    procedure Baglan;
    procedure KonusmaSekmesiAc(Sender: TObject);
    function FindDownedButton: TJvNavPanelButton;
    function OkunmamisMesajSayisiDuzenle: integer;
    function DevamedenServisDuzenle: integer;
    procedure DuyuruAlarmiVer(DuyuruID: Integer);
    procedure JvDesktopAlert2MessageClick(Sender: TObject);
    procedure MesajaGit(MesajSayfasi: Integer);
    function GetActiveChatWindow: TChatWindow;
    procedure TryCloseMainForm;
    procedure ZamanSecildi;
    procedure Grafiklendir;
    function DetayliBilgiGetir(Tur, Id : Integer; var RehberID: Integer; var Tutar:Currency) : Boolean;
    procedure TusBasildi(Tus : TToolButton);
    procedure TabloAc(var Tablo1 : TFDQuery; BasTarih, BitTarih : TDateTime);
    procedure YenileTusClick(Sender: TObject);
    procedure TakvimSil(Tur,ID:Integer);
    procedure KDR_LISTELE(RaporAd:String; Tablo1:TFDQuery; GridView: tcxGridDBTableView; TopKolonu:smallint);

  public
    UyariTabloAdi: string;
    Btn: TButtonItem;
    Alarmlar: array of TJvDesktopAlert;
    FMainFormClosing: Boolean;
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure HandleFileSends;
    function CancelFileSends: Boolean;
    function CreateChatWindow(AServerId, AUserId: Integer): TChatWindow;
    function CreateChatWindowByUserID(AUserId: Integer): TChatWindow;
    function FindChatWindowByServerId(AServerId: Integer): TChatWindow;
    function FindChatWindowByUserId(AUserId: Integer): TChatWindow;
//    property HavaDurumuImage: Integer read FHavaDurumuImage write SetHavaDurumuImage;
    property ActiveChatWindow: TChatWindow read GetActiveChatWindow;
    function OkunmamisDuyuruSayisiDuzenle: integer;

  end;

  PRSSFeedData = ^TRSSFeedData;

  TRSSFeedData = record
    Sehir: string;
    Tarih: string;
    Tahmin: string;
    Derece: string;
  end;

  TFileSendInfo = class(TObject)
  private
    FFileName: string;
    FReferenceId: Integer;
    FIsSend: Boolean;
    FFileSize: Integer;
    FLogId: Integer;
    FLogUserId: Integer;
    FFromServerId: Integer;
    FRecordIndex: Integer;
    FIsConfirming: Boolean;
    FClient: TIdTCPClient;
    FToServerId: Integer;
    FChatWindow: TChatWindow;
    FIsAborted : Boolean;
    FState: Integer;
    FFileStream: TFileStream;
    FBuffer: TIdBytes;
    FRemainingBytes: Integer;
    FSentBytes: Integer;
    FReceivedBytes: Integer;

  published
  private
    FToUserId: Integer;
    FFromUserId: Integer;
    procedure MsgClientConnected(Sender: TObject);
  public
    constructor Create(AFileName: string);
    class function CreateNew(AChatWindow: TChatWindow; AFileName: string): TFileSendInfo;
    class function FromMessage(AMsg: string): TFileSendInfo;
    procedure Abort;
    procedure PartialSend;
    procedure PartialReceive;
    procedure Send(AOrg: TIdTCPClient);
    procedure Receive(AOrg: TIdTCPClient);
    procedure PerformOperation;
    destructor Destroy; override;
    property FileName: string read FFileName write FFileName;
    property ReferenceId: Integer read FReferenceId write FReferenceId;
    property FileSize: Integer read FFileSize write FFileSize;
    property IsSend: Boolean read FIsSend write FIsSend;
    property IsConfirming: Boolean read FIsConfirming write FIsConfirming;
    property LogId: Integer read FLogId write FLogId;
    property LogUserId: Integer read FLogUserId write FLogUserId;
    property FromServerId: Integer read FFromServerId write FFromServerId;
    property FromUserId: Integer read FFromUserId write FFromUserId;
    property ToServerId: Integer read FToServerId write FToServerId;
    property ToUserId: Integer read FToUserId write FToUserId;
    property RecordIndex: Integer read FRecordIndex write FRecordIndex;
  end;

  TChatWindow = class(TObject)
  private
    FTabSheet: TcxTabSheet;
    FUserId: Integer;
    FServerId: Integer;
    FGrid: TcxGrid;
    FGridLevel: TcxGridLevel;
    FCardView: TcxGridCardView;
    FPageControl: TcxPageControl;
    FMsgClient: TIdTCPClient;
    FSaveDialog: TSaveDialog;
    FFileSends: TObjectList<TFileSendInfo>;
  published
  private
    FUserName: string;
    procedure MsgOnGetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure MsgStylesOnGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure AliciOnayIptalClick(Sender: TObject; AButtonIndex: Integer);
    procedure GonderenIptalClick(Sender: TObject; AButtonIndex: Integer);
    procedure AliciProgressIptalClick(Sender: TObject; AButtonIndex: Integer);
    procedure GonderenProgressIptalClick(Sender: TObject; AButtonIndex: Integer);
    procedure SetUserName(const Value: string);
    procedure OnFileSendReceiveCompleted(AFSI : TFileSendInfo);
  public
    class function CreateNew(AMsgClient: TIdTCPClient; APageControl: TcxPageControl; AServerId: Integer; AUserId: Integer): TChatWindow;
    procedure CreateUI;
    constructor Create(AMsgClient: TIdTCPClient);
    function FindFileSendById(ARefId: Integer): TFileSendInfo;
    procedure WriteToWindow(AUserId: Integer; AAuthor: string; ADateTime: TDateTime; AMsg: string; ARefId: Integer = 0);
    procedure EditChatMessage(AUserId:Integer;ARefId:Integer;AMsg:string;EraseRefID:Boolean);
    procedure HandleFileSends;
  published
    property TabSheet: TcxTabSheet read FTabSheet write FTabSheet;
    property Grid: TcxGrid read FGrid write FGrid;
    property GridLevel: TcxGridLevel read FGridLevel write FGridLevel;
    property CardView: TcxGridCardView read FCardView write FCardView;
    property UserId: Integer read FUserId write FUserId;
    property ServerId: Integer read FServerId write FServerId;
    property UserName: string read FUserName write SetUserName;

  end;
var
  HomePageInstance : TAnaGirisSayfasiFrame = nil;

implementation

uses
  UVeriMotor,
  UAnaForm, JvJVCLUtils, Utablo, Fetautil, PrjConst, UKasaWizard, FetaClassExtensions, UDokumSart, UFastRap, UGenelAnaSekmeFrame,
  UGirisKutusuEx, URaporAraclari, UResim, UTabloGiris, UResimOlcumleme, IdIOHandlerSocket,LocOnFly,
  UAksiyonlarGorevFrame, UServisGorevFrame, UGorevDlg, UIsListesi, UDokumGirisFrame, GenoTIP.Ortak.GridPivotUtils, ShellApi,
  UGunlukTakvim, UNakitDlg;//, AsyncCalls;

type
  TcxCustomTabControlAccess = class(TcxCustomTabControlProperties);

  var
    RefCounter: Integer = 1;
    FServerId: Integer;
    AylikHaftalikGunluk : Integer;
    DateTakvimBasTar,DateTakvimBitTar,DateGrafikBasTar,DateGrafikBitTar : TDateTime;

    //FsAsyncCall : IAsyncCall;


{$R *.dfm}
    { TAnaGirisSayfasiFrame }

  Var
    HavaIl, SonListelenenRapor: String;

procedure TAnaGirisSayfasiFrame.AraTusClick(Sender: TObject);
    function KomutOlustur: string;
    var
      s: string;
    begin
      s := '';
      // TabArama.SQL.Add(' SELECT Modul=''Cari'', ArananId = R.ID,Kod=R.KOD,Ad=R.FIRMA,Aranan=NULL FROM REHBER R WHERE R.FIRMA LIKE ''%'+Trim(EditAra.text)+'%'' ');
      // Önce modüle bakıyoruz
      if TrimRight(Tablo.Query5.fields[2].AsString) = 'REHBER' then
      begin
        // ARAMA tablosundaki herbir ayrı BAGI adı için ayrı SQL yazıyoruz
        if TrimRight(Tablo.Query5.fields[4].AsString) = 'GENINI' then
          s := 'select Modul=''Cari'',' + Tablo.Query5.fields[0].AsString +', ArananId = R.ID,Kod=R.KOD,Ad=R.FIRMA,Aranan=ANAHTAR FROM REHBER R INNER JOIN GENINI G ON R.' +
          Tablo.Query5.fields[3].AsString + '=G.DEGER WHERE G.BOLUM=' + Tablo.Query5.fields[5].AsString + ' and ANAHTAR LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = 'REHBER' then
          s := 'select Modul=''Cari'',' + Tablo.Query5.fields[0].AsString + ',ArananId = R.ID,Kod=R.KOD,Ad=R.FIRMA,Aranan=R2.FIRMA FROM REHBER R INNER JOIN REHBER R2 ON R.TEMSILCI=R2.ID WHERE R2.FIRMA LIKE ''%' +
            Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = 'REHBERILETISIM' then
          s := 'select Modul=''Cari'',' + Tablo.Query5.fields[0].AsString +  ',ArananId = R.ID,Kod=R.KOD,Ad=R.FIRMA,Aranan=R2.AD FROM REHBER R INNER JOIN REHBERILETISIM R2 ON R.ID=R2.REHBERID WHERE R2.AD LIKE ''%' +
            Trim(EditAra.text) + '%'' '
        else if (TrimRight(Tablo.Query5.fields[4].AsString) = 'REHBERBILGI')and(TrimRight(Tablo.Query5.fields[3].AsString) = 'BILGI') then
          s := 'SELECT MODUL=''Cari'',' + Tablo.Query5.fields[0].AsString + ',R.ID,R.KOD,R.FIRMA,ARANAN=RI.AD+'' / ''+RB.BILGI FROM REHBER R INNER JOIN REHBERILETISIM RI on R.ID=RI.REHBERID' +
            ' INNER JOIN REHBERBILGI RB ON RB.YERI=1 and RI.ID=RB.YER_ID WHERE R.GRUP<>334 and RB.BILGI LIKE  ''%' + Trim(EditAra.text)+ '%'' ' +
            ' union all ' +
            ' SELECT MODUL=''Cari'',' + Tablo.Query5.fields[0].AsString + ',R.BAGID,R.KOD,R.FIRMA,ARANAN=RI.AD+'' / ''+RB.BILGI FROM REHBER R INNER JOIN REHBERILETISIM RI on R.ID=RI.REHBERID' +
            ' INNER JOIN REHBERBILGI RB ON RB.YERI=1 and RI.ID=RB.YER_ID WHERE R.GRUP=334 and RB.BILGI LIKE  ''%' + Trim(EditAra.text)+ '%'' ' +
            ' union all ' +
            ' SELECT MODUL=''Cari'',' + Tablo.Query5.fields[0].AsString + ',R.ID,R.KOD,R.FIRMA,ARANAN=RB.BILGI ' +
            ' FROM REHBER R INNER JOIN REHBERBILGI RB ON RB.YERI=2 and R.ID=RB.YER_ID WHERE RB.BILGI LIKE ''%' + Trim(EditAra.text) + '%'' '

        else if TrimRight(Tablo.Query5.fields[4].AsString) = 'BANKAHESAPLAR' then
          s := 'select Modul=''Cari'',' + Tablo.Query5.fields[0].AsString + ',ArananId = R.ID,Kod = R.KOD,Ad=R.FIRMA,Aranan=BH.' + Tablo.Query5.fields[3].AsString + '+''/ Banka Hesapı'' FROM REHBER R INNER JOIN BANKAHESAPLAR BH on R.ID=BH.REHBERID  WHERE BH.' + Tablo.Query5.fields[3].AsString + ' LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = 'BANKASUBELER' then
          s := 'select Modul=''Cari'',' + Tablo.Query5.fields[0].AsString + ',ArananId = R.ID,Kod = R.KOD,Ad=R.FIRMA,Aranan=BS.' + Tablo.Query5.fields[3].AsString + ' FROM REHBER R INNER JOIN BANKAHESAPLAR BH on R.ID=BH.REHBERID inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID  WHERE BS.' +
            Tablo.Query5.fields[3].AsString + ' LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = 'BANKALAR' then
          s := 'select Modul=''Cari'',' + Tablo.Query5.fields[0].AsString + ',ArananId = R.ID,Kod = R.KOD,Ad=R.FIRMA,Aranan=B.' + Tablo.Query5.fields[3].AsString + ' FROM REHBER R INNER JOIN BANKAHESAPLAR BH on R.ID=BH.REHBERID ' +
            ' inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU  WHERE B.' + Tablo.Query5.fields[3].AsString + ' LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = '' then
          s := 'select Modul=''Cari'',' + Tablo.Query5.fields[0].AsString + ', ArananId = R.ID,Kod=R.KOD,Ad=R.FIRMA,Aranan=' + Tablo.Query5.fields[3].AsString + ' FROM REHBER R WHERE R.' + Tablo.Query5.fields[3].AsString + ' LIKE ''%' + Trim(EditAra.text) + '%'' ';
      end else if TrimRight(Tablo.Query5.fields[2].AsString) = 'STOK' then begin
        if TrimRight(Tablo.Query5.fields[4].AsString) = 'GENINI' then
          s := ' select Modul=''Stok'',' + Tablo.Query5.fields[0].AsString + ',ArananId = S.ID,Kod=S.KOD,Ad=S.STOKADI,Aranan=ANAHTAR FROM STOKLAR S INNER JOIN GENINI G ON S.' + Tablo.Query5.fields[3].AsString + '=G.DEGER WHERE G.BOLUM=' + Tablo.Query5.fields[5].AsString + ' and ANAHTAR LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = '' then
          s := ' select Modul=''Stok'',' + Tablo.Query5.fields[0].AsString + ', ArananId = S.ID,Kod=S.KOD,Ad=S.STOKADI,Aranan=' + Tablo.Query5.fields[3].AsString +' FROM STOKLAR S WHERE S.' + Tablo.Query5.fields[3].AsString + ' LIKE ''%' + Trim(EditAra.text) + '%'' ';
      end else if TrimRight(Tablo.Query5.fields[2].AsString) = 'FATURA' then begin
        if TrimRight(Tablo.Query5.fields[4].AsString) = 'GENINI' then
          s := ' select Modul=''Alış/Satış'',' + Tablo.Query5.fields[0].AsString + ',ArananId = FB.ID,Kod=''Kod'',Ad=(Case When FB.TUR in (9,19) then ''Sipariş'' When FB.TUR in (10,14) then ''İrsaliye'' When FB.TUR in (11,15) then ''Fatura'' '+
              ' When FB.TUR in (12,16) then ''Fiş'' When FB.TUR in (13,17) then ''Tahakkuk''  end),Aranan = ANAHTAR FROM FATBASLIK FB INNER JOIN GENINI G ON FB.' + Tablo.Query5.fields[3].AsString + ' = G.DEGER WHERE G.BOLUM = (Select X= (Case '+
              ' When FB.TUR in (9,10,11,12,13) then -1008 When FB.TUR in (14,15,16,17,19) then -1007 end)) and ANAHTAR LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = 'PROJELER' then
          s := ' select Modul=''Alış/Satış'',' + Tablo.Query5.fields[0].AsString + ',ArananId = FB.ID,Kod=''Kod'',Ad=''Fatura Proje Bilgisi'',Aranan = P.PROJEKODU FROM FATBASLIK FB INNER JOIN PROJELER P ON FB.' + Tablo.Query5.fields[3].AsString + ' = P.ID WHERE P.PROJEKODU LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = 'AKTIVITELER' then
          s := ' select Modul=''Alış/Satış'',' + Tablo.Query5.fields[0].AsString + ',ArananId = FB.ID,Kod=''Kod'',Ad=''Fatura Akitivite Bilgisi'',Aranan = A.NOTLAR FROM FATBASLIK FB  INNER JOIN AKTIVITELER A ON FB.' + Tablo.Query5.fields[3].AsString + ' = A.ID WHERE A.NOTLAR LIKE ''%' + Trim(EditAra.text) + '%'' '
        else  if TrimRight(Tablo.Query5.fields[4].AsString) = 'REHBER' then
          s := ' select Modul=''Alış/Satış'',' + Tablo.Query5.fields[0].AsString + ',ArananId = FB.ID,Kod=''Kod'',Ad=''Fatura Firma Bilgisi'',Aranan=R.FIRMA FROM FATBASLIK FB  INNER JOIN REHBER R ON FB.' + Tablo.Query5.fields[3].AsString + ' = R.ID WHERE FIRMA LIKE ''%' + Trim(EditAra.text) + '%'' '
        else  if TrimRight(Tablo.Query5.fields[4].AsString) = 'MASRAFGELIR' then
          s := ' select Modul=''Alış/Satış'',' + Tablo.Query5.fields[0].AsString + ',ArananId = FB.ID,Kod=''Kod'',Ad=''Masraf-Gelir'',Aranan = MG.AD FROM FATBASLIK FB INNER JOIN MASRAFGELIR MG ON FB.' + Tablo.Query5.fields[3].AsString + ' = MG.ID WHERE MG.AD LIKE ''%' + Trim(EditAra.text) + '%'' '
        else  if TrimRight(Tablo.Query5.fields[4].AsString) = 'STOKLAR' then
          s := ' select Modul=''Alış/Satış'',' + Tablo.Query5.fields[0].AsString + ',ArananId = FB.ID,Kod=''Kod'',Ad=''FATURAID = '' + cast(FB.ID as varchar(10)),Aranan = S.STOKADI FROM FATBASLIK FB INNER JOIN FATURA F on FB.ID=F.FATBASID INNER JOIN STOKLAR S ON F.' + Tablo.Query5.fields[3].AsString + ' = S.ID WHERE S.STOKADI LIKE ''%' + Trim(EditAra.text) + '%'' '
        else if TrimRight(Tablo.Query5.fields[4].AsString) = '' then
          s := ' select Modul=''Alış/Satış'',' + Tablo.Query5.fields[0].AsString + ', ArananId = FB.ID,Kod=''Kod'',Ad=''Fatura Başlık Bilgisi'',Aranan=' + Tablo.Query5.fields[3].AsString +' FROM FATBASLIK FB  WHERE FB.' + Tablo.Query5.fields[3].AsString + ' LIKE ''%' + Trim(EditAra.text) + '%'' ';

      end else if TrimRight(Tablo.Query5.fields[2].AsString) = 'SERVIS' then begin

      end else if TrimRight(Tablo.Query5.fields[2].AsString) = 'AKTIVITE' then begin

      end else if TrimRight(Tablo.Query5.fields[2].AsString) = 'PROJE' then begin

      end;
      if s <> '' then
      begin
        TabArama.Close;
        TabArama.SQL.text := ' INSERT INTO ##ARAMA_SPID_ ';
        TabArama.SQL.Add(s);
        TabArama.SQL.Add(' select * from ##ARAMA_SPID_');
        TabArama.Open;
      end;
    end;
begin
  if EditAra.text = '' then
    Abort;

  // ALANTIPI 1:yazı   2:tamsayı 3:kesirli 4:tarih   5:mantıksal (bool)
  TabArama.Close;
  // İlk iş geçici tablo oluştur
  TabArama.SQL.text := SQLMemoAra.text;
  TabArama.ExecSQL;
  // sırayla arama komutlarını tablodan almak için aç
  Tablo.TablodanSorguAc(5,'Select ID,PUAN,dbo.fn_ncstr(TABLOADI) as TABLOADI,dbo.fn_ncstr(ALANADI) as ALANADI,dbo.fn_ncstr(BAGI) as BAGI,dbo.fn_ncstr(BILGI) as BILGI,ALANTIPI from ARAMA '   +
  ' where ALANTIPI = 1 order by PUAN desc, ID');
  while not Tablo.Query5.eof do
  begin
    // her bir arama komutunu çalıştır ve geçici tabloya ekle sonra da aç
    KomutOlustur;
    Tablo.Query5.Next;
  end;
end;

procedure TAnaGirisSayfasiFrame.GridAraViewDblClick(Sender: TObject);
begin
  Tablo.TablodanSorguAc(1, 'Select ID,PUAN,dbo.fn_ncstr(TABLOADI) as TABLOADI,dbo.fn_ncstr(ALANADI) as ALANADI,dbo.fn_ncstr(BAGI) as BAGI,dbo.fn_ncstr(BILGI) as BILGI,ALANTIPI from ARAMA Where ID=' + TabArama.FieldByName('SQLID').AsString + ' ');

  if Tablo.Query1.FieldByName('TABLOADI').AsString = 'REHBER' then
  begin
    if (Tablo.Query1.FieldByName('BAGI').AsString = 'REHBER') or (Tablo.Query1.FieldByName('BAGI').AsString = '') or (Tablo.Query1.FieldByName('BAGI').AsString = 'GENINI') or (Tablo.Query1.FieldByName('BAGI').AsString = 'REHBERBILGI') then begin
      Tablo.RehberSihirbazBaslat(0, TabArama.FieldByName('ArananId').AsInteger, -100, -100, False);
//    end else if Tablo.Query1.FieldByName('BAGI').AsString = 'REHBERPERSONEL' then begin
//      Tablo.RehberSihirbazBaslat(4, TabArama.FieldByName('ArananId').AsInteger, -1, 0, False);
    end else if Tablo.Query1.FieldByName('BAGI').AsString = 'REHBERILETISIM' then begin
      Tablo.RehberSihirbazBaslat(1, TabArama.FieldByName('ArananId').AsInteger, 0, -1, False);
    end else if Tablo.Query1.FieldByName('BAGI').AsString = 'BANKAHESAPLAR' then begin

    end else if Tablo.Query1.FieldByName('BAGI').AsString = 'BANKALAR' then begin

    end else if Tablo.Query1.FieldByName('BAGI').AsString = 'BANKASUBELER' then begin

    end;
  end else if Tablo.Query1.FieldByName('TABLOADI').AsString = 'STOK' then begin
    if (Tablo.Query1.FieldByName('BAGI').AsString = '') or (Tablo.Query1.FieldByName('BAGI').AsString = 'GENINI') then
    begin
      Tablo.StokSihirbazBaslat('D', 0, TabArama.FieldByName('ArananId').AsInteger, -1,0)
    end;
  end else if Tablo.Query1.FieldByName('TABLOADI').AsString = 'FATURA' then  begin
//      Tablo.TablodanSorguAc(3,'Select REHBERID,TUR from FATBASLIK Where ID='+TabArama.FieldByName('ArananId').AsString+' ');
//      Tablo.FaturaSihirbazBaslat('D',Tablo.Query3.FieldByName('TUR').AsInteger,-1,TabArama.FieldByName('ArananId').AsInteger,Tablo.Query3.FieldByName('REHBERID').AsInteger);
  end;
end;

procedure TAnaGirisSayfasiFrame.GridDuyuruDBCardViewCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var GOREV_ID: String[15];
    GorevDlg1: TGorevDlg;
begin
//   case TabDuyuruListe.FieldByName('TUR').AsInteger of
   case TabDuyuruListe.FieldByName('YER').AsInteger of
   TabNo_SERVIS : //servis onaysa servis ekranı açılır
         Tablo.ServisSihirbazBaslat(False, 'D', 0, TabDuyuruListe.FieldByName('YER_ID').AsInteger, 0);
   TabNo_TEKLIF : //teklif onaysa teklif ekranı açılır
            Tablo.TeklifSihirbazBaslat('D', 80, 0, TabDuyuruListe.FieldByName('YER_ID').AsInteger, 0,-1);
   TabNo_SIPARIS_Gelen : //teklif onaysa teklif ekranı açılır
            Tablo.SiparisSihirbazBaslat('D',9,0,TabDuyuruListe.FieldByName('YER_ID').AsInteger, 0);
   TabNo_SIPARIS_Giden : //teklif onaysa teklif ekranı açılır
            Tablo.SiparisSihirbazBaslat('D',19,0,TabDuyuruListe.FieldByName('YER_ID').AsInteger, 0);
   TabNo_Satinalma_Talep, TabNo_SATINALMA : //teklif onaysa teklif ekranı açılır
            Tablo.SatinalmaSihirbazBaslat2('D',101,0,TabDuyuruListe.FieldByName('YER_ID').AsInteger,0);
   Tabno_URETIMOPERASYONPERSONEL : //İş emri
            Tablo.IsEmriPersonelZamanSihirbaz('D', 2, 0, TabDuyuruListe.FieldByName('YER_ID').AsInteger,0);
   -1,TabNo_GOREVLER : begin//Görevse görev ekranı açılır
          if TabDuyuruListe.FieldByName('KATEGORI').AsInteger = Servis then
             Tablo.ServisSihirbazBaslat(False, 'D',0,TabDuyuruListe.Fields[0].AsInteger, TabDuyuruListe.FieldByName('REHBERID').AsInteger)
          else begin
             GOREV_ID:= TabDuyuruListe.Fields[0].AsString;
             Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',StrToInt(GOREV_ID),AtamaYapildi, YorumYapildi);
          end;
          if AtamaYapildi then
             Gorev_EPostaGonder(1, StrToIntDef(GOREV_ID,-1))
         else if YorumYapildi then
            Gorev_EPostaGonder(3, StrToIntDef(GOREV_ID,-1));
        end
   else
      Tablo.DuyuruAc('O', 0, TabDuyuruListe.FieldByName('ID').AsInteger)
   end;
   DuyuruYenileTusClick(Self);
end;

procedure TAnaGirisSayfasiFrame.GridDuyuruDBCardViewCustomDrawCell(
  Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
{  if TcxGridDBColumn(AViewInfo.Item).Tag=9 then //'ONAY'
     TcxGridDBColumn(AViewInfo.Item).Properties  := TextEdit;
   ACardViewRow :=  TcxGridDBCardView(Sender).GetRowByFieldName('GUN'); //YER
   if (Assigned(ACardViewRow))and(ARecord.Values[ACardViewRow.Index]<0) then
      GridDuyuruDBCardViewONAY.visible := False;//ARecord.Values[ACardViewRow.Index]=105;
}
end;

procedure TAnaGirisSayfasiFrame.GridDuyuruDBCardViewONAYPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var GOREV_ID: String[15];
    AcKapa  : Boolean;
    ListeId, Ekleyen, AktifListe : Integer;
    procedure Onayla(TabloAd, OnayAlan, TarihAlan:string);
    begin
        //önce tablodan onaylandı yapalım
        VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+TabloAd+' set '+OnayAlan+'='+Kullanan+', '+TarihAlan+'=GetDate(),'+
        ' DURUM='+Tablo.GENINI.ReadString(Ops_OpsiyonTeklif_Onaylandi, '-1')+' where ID='+TabDuyuruListe.FieldByName('YER_ID').AsString,[],[]);
        //sonra okundu işaretleyelim ki listeden silinsin
        VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI=getdate() where DUYURUID='+TabDuyuruListe.FieldByName('ID').AsString,[],[]);
   end;
begin
   case TabDuyuruListe.FieldByName('YER').AsInteger of
   TabNo_SERVIS :  //servis onaysa servis ekranı açılır
                  Tablo.ServisSihirbazBaslat(False, 'D', 0, TabDuyuruListe.FieldByName('YER_ID').AsInteger, 0);
   TabNo_TEKLIF : Onayla('TEKLIF','ONAYLAYAN','ONAYTARIHI');
   TabNo_SIPARIS_Gelen,TabNo_SIPARIS_Giden : Onayla('SIPARIS','ONAYLAYAN','ONAYTARIHI');
   TabNo_Satinalma_Talep : Onayla('SIPARIS','BIRIMONAYLAYAN','BIRIMONAYTARIHI');
   TabNo_SATINALMA : Onayla('SIPARIS','ONAYLAYAN','ONAYTARIHI');
   -1 : begin//Görevse görev ekranı açılır
            GOREV_ID:= TabDuyuruListe.Fields[0].AsString;
            Ekleyen  := TabDuyuruListe.FieldByName('EKLEYEN').AsInteger;
            AcKapa := False;
            ListeId := TabDuyuruListe.FieldByName('KATEGORI').AsInteger;
            AktifListe := ListeId;
            UpdateveMail(AktifListe, ListeId, StrToInt(GOREV_ID), Ekleyen, AcKapa, False);
        end
   else
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set TUR=-1 where DUYURUID='+TabDuyuruListe.FieldByName('ID').AsString+' and ALICIID='+Kullanan+' and TUR=0',[],[]);
   end;
   DuyuruYenileTusClick(Self);
end;

procedure TAnaGirisSayfasiFrame.GridDuyuruDBCardViewRow7PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI=getdate() where DUYURUID='+TabDuyuruListe.FieldByName('ID').AsString,[],[]);
//   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set TUR=-1 where DUYURUID='+TabDuyuruListe.FieldByName('ID').AsString+' and ALICIID='+Kullanan+' and TUR=0',[],[]);
   DuyuruYenileTusClick(Self);
end;

procedure TAnaGirisSayfasiFrame.GridDuyuruDBCardViewRow7PropertiesCustomClick(
  Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI=getdate() where DUYURUID=&DID and ALICIID=&AID and OKUNMATARIHI IS NULL  '
                    ,['&DID','&AID'],[TabDuyuruListe.Fields[0].AsInteger,StrToInt(Kullanan)]);
   btnAramaClick(BtnDuyuru);
end;

procedure TAnaGirisSayfasiFrame.GridDuyuruDBCardViewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  ACardViewRow: TcxGridDBCardViewRow;
begin
  ACardViewRow :=  TcxGridDBCardView(Sender).GetRowByFieldName('GUN');
  if Assigned(ACardViewRow) then begin
     if ARecord.Values[ACardViewRow.Index]<0 then
        AStyle :=  Tablo.cxStyleDuyPasif
     else begin
        ACardViewRow :=  TcxGridDBCardView(Sender).GetRowByFieldName('KATEGORI');
        if Assigned(ACardViewRow) then
           case ARecord.Values[ACardViewRow.Index] of
             -27,1: AStyle :=  Tablo.cxStyleDuyGenel;
             2: AStyle := Tablo.cxStyleDuyHatirlatma;
             11: AStyle := Tablo.cxStyleDuyTahsil;
             12: AStyle := Tablo.cxStyleDuyOdeme;
           end;
     end;
   end;
end;

procedure TAnaGirisSayfasiFrame.Baslatildi;
var
  i : Integer;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  HomePageInstance := Self;

  Tablo.GridTurkcelestir;
  SonListelenenRapor := '';
  ResimGetir(StrToInt(Kullanan),  13, StrToInt(Kullanan), ProfilResim);

  PageControlOrta.ActivePageIndex := 0;
  // anaPanel.Height:= Self.ClientHeight;
  // PanelAyarlariniYukle;
  // PanelUyarilariYukle;
  {if (okunmayanaktivite) then begin
    Tablo.Query6.Close;
    Tablo.Query6.SQL.text := ' SELECT COUNT(ID) FROM AKTIVITELER WHERE SORUMLU=' + Kullanan + ' AND ISNULL(OKUNDU,0) = 0 ';
    Tablo.Query6.Open;
    if Tablo.Query6.fields[0].AsInteger > 0 then
      ShowMessage(PChar(AGOkunmayan_akt_gorev+ Tablo.Query6.fields[0].AsString ));
    okunmayanaktivite := false;
  end; }
  btnArama.Visible := Tablo.YetkiVarmi(2001, YetkiTur_Gorme, false);
  if (not Tablo.YetkiVarmi(2002, YetkiTur_Gorme, false)) and (not Tablo.YetkiVarmi(2003, YetkiTur_Gorme, false)) then begin
    PanelMesajDuyuru.Visible := false;
    Anaform.DuyuruMenu.destroy;
  end else if not Tablo.YetkiVarmi(2002, YetkiTur_Gorme, false) then begin
    BtnMesaj.Visible := false;
    BtnDuyuru.Align := alClient;
  end else if not Tablo.YetkiVarmi(2003, YetkiTur_Gorme, false) then begin
    BtnDuyuru.Visible := false;
    BtnMesaj.Align := alClient;
    Anaform.DuyuruMenu.destroy;
  end;
  if (not Tablo.YetkiVarmi(2004, YetkiTur_Gorme, false)) and (not Tablo.YetkiVarmi(2005, YetkiTur_Gorme, false)) then
    PanelHaberPiyasa.Visible := false
  else if not Tablo.YetkiVarmi(2004, YetkiTur_Gorme, false) then begin
    //BtnHaber.Visible := false;
    //BtnPiyasa.Align := alClient;
  end;
  PanelProje.Visible := Tablo.YetkiVarmi(2006, YetkiTur_Gorme, false);
  if (not Tablo.YetkiVarmi(2007, YetkiTur_Gorme, false)) and (not Tablo.YetkiVarmi(2008, YetkiTur_Gorme, false)) then
    PanelAktiviteGorev.Visible := false
  else if not Tablo.YetkiVarmi(2007, YetkiTur_Gorme, false) then begin
    btnAktivite.Visible := false;
    btnGorev.Align := alClient;
  end else if not Tablo.YetkiVarmi(2008, YetkiTur_Gorme, false) then begin
    btnGorev.Visible := false;
    btnAktivite.Align := alClient;
  end;
{  if (not Tablo.YetkiVarmi(2009, YetkiTur_Gorme, false)) and (not Tablo.YetkiVarmi(2010, YetkiTur_Gorme, false)) then
    PanelFinansCRM.Visible := false
  else if not Tablo.YetkiVarmi(2009, YetkiTur_Gorme, false) then begin
    BtnYonetimFinans.Visible := false;
    BtnYonetimCRM.Align := alClient;
  end else if not Tablo.YetkiVarmi(2010, YetkiTur_Gorme, false) then begin
    BtnYonetimCRM.Visible := false;
    BtnYonetimFinans.Align := alClient;
  end;
  if (not Tablo.YetkiVarmi(2011, YetkiTur_Gorme, false)) and (not Tablo.YetkiVarmi(2012, YetkiTur_Gorme, false)) then
    PanelTeklifServis.Visible := false
  else if not Tablo.YetkiVarmi(2011, YetkiTur_Gorme, false) then begin
    BtnYonetimTeklif.Visible := false;
    BtnYonetimServis.Align := alClient;
  end else if not Tablo.YetkiVarmi(2012, YetkiTur_Gorme, false) then begin
    BtnYonetimServis.Visible := false;
    BtnYonetimTeklif.Align := alClient;
  end; }

//  if not Tablo.YetkiVarmi(2111, YetkiTur_Degistirme, false) then // proje değiştirme yetkisi
//     tvProjeler.OnDblClick := Nil;
  TabMesajKisiler.Close;
  if TabMesajKisiler.Params.FindParam('PRID') = nil then
    with TabMesajKisiler.Params.Add do begin
      Name := 'PRID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  with TabMesajKisiler.ParamByName('PRID') do begin
    DataType := ftInteger;
    Size := 10;
    AsInteger := StrToIntDef(Kullanan, 0);
  end;
  TabMesajKisiler.Open;
  try
    Baglan;
  finally
    //OkunmamisDialoglariGetir;
  end;
  for I := 0 to PageControlOrta.PageCount - 1 do
    PageControlOrta.Pages[i].TabVisible := false;

  btnArama.Caption := AGS_Arama;
  BtnMesaj.Caption := AGS_Mesajlasma;
  BtnDuyuru.Caption := AGS_Duyuru;
  //BtnHaber.Caption := AGS_Haber;
  btnProje.Caption := AGS_Projeler;
  btnServis.Caption := AGS_Servis;
  btnAktivite.Caption := AGS_Aktivite;
  if btnGorev.Visible then begin
     Tablo.TablodanSorguAc(1,' exec sp_Prg_Sayi_BanaIsListesi '+Kullanan+',0,9999');
     if Tablo.Query1.Fields[0].AsInteger>0 then
        btnGorev.Caption := AGS_Gorevler+' ('+Tablo.Query1.Fields[0].AsString+')'
     else
        btnGorev.Caption := AGS_Gorevler;
  end;
  OkunmamisDuyuruSayisiDuzenle;
  OkunmamisMesajSayisiDuzenle;
  DevamedenServisDuzenle;
  lblKullanici.Caption := KullanAdi;
  if BtnDuyuru.visible then
     BtnDuyuru.Click;
end;

procedure TAnaGirisSayfasiFrame.HandleFileSends;
var
  cw : TChatWindow;
begin
  for cw in FChatWindows do
    cw.HandleFileSends;
end;

function TAnaGirisSayfasiFrame.CancelFileSends: Boolean;
var
  cw : TChatWindow;
  fsi : TFileSendInfo;
begin
  Result := True;
{  if FMainFormClosing then Exit(True);
  Result := True;
  FMainFormClosing := True;
  if MsgClient.Connected then  begin
    for cw in FChatWindows do begin
      for fsi in cw.FFileSends do begin
        if fsi.IsSend then begin
          fsi.Abort;
        end else begin
          MsgClient.Socket.WriteLn(Format('FSABORT %d %d',[fsi.FromServerId,fsi.ReferenceId * -1]));
        end;
        Result := False;
      end;
    end;
    MsgClient.Socket.WriteBufferFlush;
  end; }
end;

procedure TAnaGirisSayfasiFrame.OkunmamisDialoglariGetir;

var
  cw: TChatWindow;
Begin
  Tablo.TablodanSorguAc(4,
    'select ML.GONDERENID,ML.TARIH,ML.MESAJ from MESAJLOG ML inner join MESAJLOGKULLANICI MLK on ML.ID=MLK.MESAJLOGID where ML.TUR=1 and MLK.ALICIID='
      + Kullanan + ' and isnull(MLK.OKUNDU,0)<>1 order by ML.TARIH');
  while not Tablo.Query4.eof do begin
    if TabMesajKisiler.Locate('ID', Tablo.Query4.FieldByName('GONDERENID').AsInteger, []) then begin
      // mesajı gönderenin sayfası açık değilse tekrar oluşturalım...
      cw := CreateChatWindowByUserID(Tablo.Query4.FieldByName('GONDERENID').AsInteger);
      cw.UserName := TabMesajKisiler.FieldByName('FIRMA').AsString;
      cw.WriteToWindow(cw.UserId, TabMesajKisiler.FieldByName('FIRMA').AsString, Tablo.Query4.FieldByName('TARIH').AsDateTime,
        Tablo.Query4.FieldByName('MESAJ').AsString);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'update MESAJLOGKULLANICI set OKUNDU=1, OKUNMATARIHI=GetDate() where ALICIID=&AliciID and MESAJLOGID in(select ID from MESAJLOG where GONDERENID=&GonderenID)', ['&AliciID', '&GonderenID'], [Kullanan,cw.UserId]);
    end;
    Tablo.Query4.Next;
  end;
End;

function TAnaGirisSayfasiFrame.FindChatWindowByServerId(AServerId: Integer): TChatWindow;

var
  cw: TChatWindow;
begin
  result := nil;
  for cw in FChatWindows do begin
    if cw.ServerId = AServerId then
      exit(cw);
  end;
end;

function TAnaGirisSayfasiFrame.FindChatWindowByUserId(AUserId: Integer): TChatWindow;

var
  cw: TChatWindow;
begin
  result := nil;
  for cw in FChatWindows do begin
    if cw.UserId = AUserId then
      exit(cw);
  end;

end;

function TAnaGirisSayfasiFrame.FindDownedButton: TJvNavPanelButton;
begin
  if btnArama.Down then
    result := btnArama;
  if BtnMesaj.Down then
    result := BtnMesaj;
  if BtnDuyuru.Down then
    result := BtnDuyuru;
  if BtnKDR.Down then
    result := BtnKDR;
  if btnProje.Down then
    result := btnProje;
  if btnServis.Down then
    result := btnServis;
  if btnAktivite.Down then
    result := btnAktivite;
  if btnGorev.Down then
    result := btnGorev;
end;

procedure TAnaGirisSayfasiFrame.btnAramaClick(Sender: TObject);
var
  i, j: Integer;
begin
  if (Sender = nil) or (Sender.ClassName <> 'TJvNavPanelButton') then begin
    Sender := FindDownedButton;
  end;
  btnArama.Down := false;
  BtnMesaj.Down := false;
  BtnDuyuru.Down := false;
  BtnKDR.Down := false;
  btnProje.Down := false;
  btnServis.Down := false;
  btnAktivite.Down := false;
  btnGorev.Down := false;
  TJvNavPanelButton(Sender).Down := true;

  if TJvNavPanelButton(Sender) = btnArama then begin // arama
    PageControlOrta.ActivePage := SheetArama;
  end else if TJvNavPanelButton(Sender) = BtnMesaj then begin
    PageControlOrta.ActivePage := SheetMesajlasma;
    Baglan;
    if (not AnaFrameYoneticisi.AktifFrame.FrameYonetilebilir)and(MemoChat.Enabled=True) then
      MemoChat.SetFocus;
  end else if TJvNavPanelButton(Sender) = BtnDuyuru then begin
    //Tablo.DuyuruAc('O', 0, 1);
    PageControlOrta.ActivePage := SheetDuyurular;
    DuyuruYenileTus.Click;
  end else if TJvNavPanelButton(Sender) = btnAktivite then begin
    TAksiyonlarGorevFrame(AnaForm.FrameYoneticisi.FrameBul('CRM').GitAdaGore.GorevFrameOrnek).btnFirsatListe.Click;
  end else if TJvNavPanelButton(Sender) = btnGorev then begin
    TAksiyonlarGorevFrame(AnaForm.FrameYoneticisi.FrameBul('CRM').GitAdaGore.GorevFrameOrnek).btnGorevListe.Click;
  end else if TJvNavPanelButton(Sender) = btnProje then begin
    TAksiyonlarGorevFrame(AnaForm.FrameYoneticisi.FrameBul('CRM').GitAdaGore.GorevFrameOrnek).btnProjeListe.Click;
  end else if TJvNavPanelButton(Sender) = btnServis then begin
    TServisGorevFrame(AnaForm.FrameYoneticisi.FrameBul('Servis').GitAdaGore.GorevFrameOrnek).btnHesapKarti.Click;
  end else if TJvNavPanelButton(Sender) = BtnKDR then begin
    KDRListe.Visible := not KDRListe.Visible;
  end else begin
    PageControlOrta.ActivePage := SheetGiris;
  end;
end;

procedure TAnaGirisSayfasiFrame.BtnDosyaGonderClick(Sender: TObject);
var
  Msg: string;
  MesajLogID, MesajLogKullaniciID: Variant;
  DosyaAdi: string;
  fsi: TFileSendInfo;
begin
 { if OpenDialog1.Execute then begin
    MesajLogID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'insert into MESAJLOG(TUR,GONDERENID,MESAJ)values(&Tur,&GonderenID,&Mesaj) select scope_identity() ', ['&Tur', '&GonderenID', '&Mesaj'],
      [2, Kullanan, '<' + MsgDosyayiPaylasiyorsunuz + ':' + ExtractFileName(OpenDialog1.FileName) + '>'], true);
    MesajLogKullaniciID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'insert into MESAJLOGKULLANICI(MESAJLOGID,ALICIID)values(&MesajLogID,&AliciID) select scope_identity()', ['&MesajLogID', '&AliciID'],
      [VarToStr(MesajLogID), ActiveChatWindow.FServerId], true);
    fsi := TFileSendInfo.CreateNew(ActiveChatWindow, OpenDialog1.FileName);
    fsi.IsSend := true;
    fsi.IsConfirming := true;
    fsi.ToServerId := ActiveChatWindow.FServerId;
    fsi.FromServerId := FServerId;
    fsi.FileSize := FileSizeByName(fsi.FileName);
    // FSCONFIRM AliciServerId LogId LogKullanıcıId ReferansId DosyaAdı
    Msg := Format('FSCONFIRM %d %s %s %d %d %s', [ActiveChatWindow.FServerId, VarToStr(MesajLogID), VarToStr(MesajLogKullaniciID),fsi.ReferenceId, fsi.FileSize, ExtractFileName(OpenDialog1.FileName)]);
    MsgClient.Socket.WriteLn(Msg);
    ActiveChatWindow.WriteToWindow(ActiveChatWindow.UserId, KullanAdi, Tablo.GENINI.BugunTrhSaat, '<' + MsgDosyayiPaylasiyorsunuz + ':' + ExtractFileName(OpenDialog1.FileName) + '>',fsi.ReferenceId);
    PageControlChat.ActivePage := ActiveChatWindow.FTabSheet;
  end; }
end;

procedure TAnaGirisSayfasiFrame.BtnMesajGonderClick(Sender: TObject);
var
  Msg: string;
  MesajLogID, MesajLogKullaniciID: Variant;
  cw: TChatWindow;
begin
{  cw := ActiveChatWindow;
  if not Assigned(cw) then
    exit;

  MesajLogID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'insert into MESAJLOG(TUR,GONDERENID,MESAJ)values(&Tur,&GonderenID,&Mesaj) select scope_identity() ', ['&Tur', '&GonderenID', '&Mesaj'],
    [1, Kullanan, MemoChat.text], true);
  MesajLogKullaniciID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'insert into MESAJLOGKULLANICI(MESAJLOGID,ALICIID)values(&MesajLogID,&AliciID) select scope_identity()', ['&MesajLogID', '&AliciID'],
    [VarToStr(MesajLogID),ActiveChatWindow.FUserId], true);
  Msg := Format('SEND %d %s %s %s', [cw.ServerId, VarToStr(MesajLogID), VarToStr(MesajLogKullaniciID), Dize.SatirSonuEncode(MemoChat.text)]);
  cw.WriteToWindow(cw.UserId, KullanAdi, Tablo.GENINI.BugunTrhSaat, MemoChat.text);

  // MsgClient.Socket.WriteLn('SEND ' + IntToStr(PageControlChat.ActivePage.Tag) + ' LOGID '+ VarToStr(MesajLogID) + ' LOGKULID '+ VarToStr(MesajLogKullaniciID) +' '+ MemoChat.Text);
  MsgClient.Socket.WriteLn(Msg);
  MemoChat.Clear;
  MemoChat.SetFocus; }
end;

procedure TAnaGirisSayfasiFrame.CheckPasifPropertiesEditValueChanged(Sender: TObject);
begin
  OlayListele;
end;

procedure TAnaGirisSayfasiFrame.cxGrid4DBTableViewKisilerCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  cw : TChatWindow;
begin
  KonusmaSekmesiAc(Sender);
  cw := FindChatWindowByUserId(TabMesajKisiler.FieldByName('ID').AsInteger);
  PageControlChat.ActivePage := cw.FTabSheet;

end;

procedure TAnaGirisSayfasiFrame.KonusmaGecmisiMenuClick(Sender: TObject);

var
  Key: Word;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  TabloGirisDlg.Caption := 'İleti Geçmişi';
  TabloGirisDlg.Komut :=
    'select TARIH='+DbConv('TARIH','VARCHAR(10)',103)+',SAAT='+DbConv('TARIH','VARCHAR(10)',108)+', KIMDEN=RG.FIRMA,KIME=RA.FIRMA, MESAJ' +
    #13#10 + 'from MESAJLOG ML' + #13#10 + 'inner join MESAJLOGKULLANICI MKUL on MKUL.MESAJLOGID=ML.ID' +
    #13#10
    + 'inner join REHBER RG on RG.ID=ML.GONDERENID' + #13#10 + 'inner join REHBER RA on RA.ID=MKUL.ALICIID' +
    #13#10 + 'where ML.GONDERENID = '+IntToStr(ActiveChatWindow.FUserId)+' and MKUL.ALICIID = '+Kullanan+' ' + #13#10 + 'union all' +
    #13#10 + 'select TARIH='+DbConv('TARIH','VARCHAR(10)',103)+',SAAT='+DbConv('TARIH','VARCHAR(10)',108)+', KIMDEN=RG.FIRMA,KIME=RA.FIRMA, MESAJ' +
    #13#10 + 'from MESAJLOG ML' + #13#10 + 'inner join MESAJLOGKULLANICI MKUL on MKUL.MESAJLOGID=ML.ID' + #13#10 +
    'inner join REHBER RG on RG.ID=ML.GONDERENID' + #13#10 + 'inner join REHBER RA on RA.ID=MKUL.ALICIID' + #13#10 +
    'where ML.GONDERENID = '+Kullanan+' and MKUL.ALICIID = '+IntToStr(ActiveChatWindow.FUserId)+'' + #13#10 + 'order by 1,2';
  Key := 0;
  TabloGirisDlg.Edit1KeyUp(Self, Key, [ssShift]);
  TabloGirisDlg.ShowModal;
  TabloGirisDlg.Destroy;
end;

procedure TAnaGirisSayfasiFrame.KonusmaSekmesiAc(Sender: TObject);
var
  cw : TChatWindow;
begin
  cw := CreateChatWindowByUserID(TabMesajKisiler.FieldByName('ID').asInteger);
  cw.UserName := TabMesajKisiler.FieldByName('FIRMA').AsString;
  MemoChat.SetFocus;
end;

function TAnaGirisSayfasiFrame.OkunmamisDuyuruSayisiDuzenle: integer;
begin
  if AnaForm.DuyuruMenu = nil then exit;

  Tablo.TablodanSorguAc(8,
    'select count(*) from DUYURU D inner join DUYURUKULLANICI DK on DK.DUYURUID=D.ID where D.TUR=2 AND OKUNMATARIHI=null and DK.ALICIID=' +
      Kullanan);
  result := Tablo.Query8.fields[0].AsInteger;
  if result > 0 then begin
    BtnDuyuru.Caption := AGS_Duyuru + ' (' + inttostr(result) + ')';
    AnaForm.DuyuruMenu.caption:= inttostr(result)
  end else begin
    BtnDuyuru.Caption := AGS_Duyuru;
    AnaForm.DuyuruMenu.caption:='';
  end;
end;

function TAnaGirisSayfasiFrame.DevamedenServisDuzenle: integer;
begin
  Tablo.TablodanSorguAc(8,
    'select count(*) from SERVIS where ACKAPA=0 and SORUMLU=' + Kullanan);
  result := Tablo.Query8.fields[0].AsInteger;
  if result > 0 then begin
    btnServis.Caption := AGS_Servis + ' (' + inttostr(result) + ')';
  end else begin
    btnServis.Caption := AGS_Servis;
  end;
end;

function TAnaGirisSayfasiFrame.OkunmamisMesajSayisiDuzenle: integer;
var
  i: Integer;
begin
  result := 0;
  for I := 0 to PageControlChat.PageCount - 1 do
    if PageControlChat.Pages[i].Highlighted = true then
      Inc(result);
  if result > 0 then
    BtnMesaj.Caption := AGS_Mesajlasma + ' (' + inttostr(result) + ')'
  else
    BtnMesaj.Caption := AGS_Mesajlasma;
end;

procedure TAnaGirisSayfasiFrame.ChatTimerTimer(Sender: TObject);
var
  cmd: string;
  part, Part1, Part2, DosyaAdi: string;
  AliciID, MsgLogID, MsgLogKulID, i, RecIndx, AliciServerId: Integer;
  cw: TChatWindow;
  fsi: TFileSendInfo;
  lst: TStringList;
  Function GriddeKelimeAra(Grid: TcxGridCardView; ItemIndex: Integer; Kelime: string): Integer;
  var
    j: integer;
  begin
    result := -1;
    for j := Grid.DataController.RecordCount - 1 Downto 0 do
    begin
      if Pos(Kelime, Grid.DataController.DisplayTexts[j, ItemIndex]) > 0 then
        result := j;
    end;
  end;
begin
  // Page Hint de dosya adı yazar,
  // Page HelpKeyword de dosya gönderim satırına locate olabilmek için içeriğindeki text yazıyor..
  // Bağlı değilse buffer kontrol etmesine gerek yok çıksın
{  if not MsgClient.Connected then
    exit;
  // Bağlıysa TCP den gelen mesajları aldığı bufferdan bilgileri alsın
  if (not MsgClient.Socket.InputBufferIsEmpty) then begin
    cmd := Dize.SatirSonuDecode(MsgClient.Socket.ReadLn);
    part := Dize.SinirlandirilmisMetin(cmd, ' ');
    if part = 'MSG' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      if TabMesajKisiler.Locate('ID', AliciID, []) then begin
        // log güncelleyelim... 'LOGID=11 LOGKULID=9 asdas dasasd asd'
        MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
        MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MESAJLOGKULLANICI set ALINDI=1, ALINMATARIHI=GetDate() where ID=&ID', ['&ID'],
          [MsgLogKulID]);
        // mesajı gönderenin sayfası açık değilse tekrar oluşturalım...
        cw := CreateChatWindow(AliciServerId, AliciID);
        cw.UserName := TabMesajKisiler.FieldByName('FIRMA').AsString;
        // açık olan başka sayfaysa mesaj gelen sayfayı highligt yapalım..
        if not(AnaFrameYoneticisi.AktifFrame.FrameYonetilebilir) and (Screen.ActiveForm = AnaForm) and (PageControlChat.ActivePage = cw.FTabSheet) and (PageControlOrta.ActivePage = SheetMesajlasma) then
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MESAJLOGKULLANICI set OKUNDU=1, OKUNMATARIHI=GetDate() where ID=&ID', ['&ID'],
            [MsgLogKulID])
        else begin
          cw.FTabSheet.Highlighted := true;
          OkunmamisMesajSayisiDuzenle;
        end;
        if (AnaFrameYoneticisi.AktifFrame.FrameYonetilebilir) or (PageControlOrta.ActivePage <> SheetMesajlasma) then begin
          AnaForm.AnaSayfaDenetimi.Pages[0].Highlighted := true;
          if Length(Alarmlar) > 0 then
            for I := 0 to Length(Alarmlar) - 1 do
              if Assigned(Alarmlar[0]) then
                FreeAndNil(Alarmlar[i]);
          SetLength(Alarmlar, 1);
          Alarmlar[0] := TJvDesktopAlert.Create(Self);
          Alarmlar[0].HeaderText := 'Mesaj - ' + TabMesajKisiler.FieldByName('FIRMA').AsString;
          Alarmlar[0].MessageText := cmd;
          Alarmlar[0].Tag := cw.FTabSheet.PageIndex;
          Alarmlar[0].AlertStack := JvDesktopAlertStack1;
          Alarmlar[0].Image.Bitmap.Assign(JvDesktopAlert1.Image.Bitmap);
          Alarmlar[0].OnMessageClick := JvDesktopAlert2MessageClick;
          Alarmlar[0].StyleOptions.DisplayDuration := 10000;
          Alarmlar[0].Execute;
        end;
        // içeriye mesaj yazalım
        cw.WriteToWindow(cw.UserId, TabMesajKisiler.FieldByName('FIRMA').AsString, Tablo.GENINI.BugunTrhSaat, cmd);
      end;
    end else if part = 'USRLIST' then begin
      Tablo.repOnlinePersonel.Properties.Images := Tablo.PNGImageList2;
      if not TabMesajKisiler.Active then begin
        TabMesajKisiler.Close;
  if TabMesajKisiler.Params.FindParam('PRID') = nil then
    with TabMesajKisiler.Params.Add do begin
      Name := 'PRID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  with TabMesajKisiler.ParamByName('PRID') do begin
    DataType := ftInteger;
    Size := 10;
    AsInteger := StrToIntDef(Kullanan, 0);
  end;
  TabMesajKisiler.Open;
      end;
      FOnlineUsers.text := cmd;
      for i := 0 to Tablo.repOnlinePersonel.Properties.Items.Count - 1 do
        if FOnlineUsers.IndexOfName(VarToStr(Tablo.repOnlinePersonel.Properties.Items[i].Value)) > -1 then
          Tablo.repOnlinePersonel.Properties.Items[i].ImageIndex := 25
        else
          Tablo.repOnlinePersonel.Properties.Items[i].ImageIndex := 26;
      for cw in FChatWindows do cw.ServerId := -1;
      for I := 0 to FOnlineUsers.Count - 1 do
        for cw in FChatWindows do begin
          if cw.FUserId = StrToInt(FOnlineUsers.Names[i]) then
          begin
            cw.ServerId := StrToInt(FOnlineUsers.ValueFromIndex[i]);
          end;
        end;
    end else if part = 'Duyuru' then begin
      if (Length(Alarmlar) > 0) and (Assigned(Alarmlar[0])) then
        for I := 0 to Length(Alarmlar) do
          FreeAndNil(Alarmlar[i]);
      OkunmamisDuyuruSayisiDuzenle;
      Tablo.TablodanSorguAc(8,
        'select D.ID,D.KONU from DUYURU D inner join DUYURUKULLANICI DK on DK.DUYURUID=D.ID where D.TUR=2 and isnull(DK.OKUNDU,0)=0 and DK.ALICIID='
          + Kullanan);

      SetLength(Alarmlar, Tablo.Query8.RecordCount);
      Tablo.Query8.First;
      i := 0;
      while not Tablo.Query8.eof do begin
        Alarmlar[i] := TJvDesktopAlert.Create(Self);
        Alarmlar[i].HeaderText := 'Okunmamış Duyurunuz Var!';
        Alarmlar[i].MessageText := Tablo.Query8.FieldByName('KONU').AsString;
        Alarmlar[i].Tag := Tablo.Query8.FieldByName('ID').AsInteger;
        Alarmlar[i].AlertStack := JvDesktopAlertStack1;
        Alarmlar[i].Image.Bitmap.Assign(JvDesktopAlert1.Image.Bitmap);
        Alarmlar[i].OnMessageClick := JvDesktopAlert1MessageClick;
        Alarmlar[i].StyleOptions.DisplayDuration := 10000;
        Alarmlar[i].Execute;
        Inc(i);
        Tablo.Query8.Next;
      end;
    end else if part = 'FSCONFIRM' then begin
      fsi := TFileSendInfo.FromMessage(cmd);
      fsi.ToServerId := FServerId;
      fsi.ToUserId := StrToInt(Kullanan);
      if TabMesajKisiler.Locate('ID', fsi.FromUserId, []) then
      begin
        //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MESAJLOGKULLANICI set ALINDI=1, ALINMATARIHI=GetDate() where ID=&ID', ['&ID'],[MsgLogKulID]);
        // mesajı gönderenin sayfası açık değilse tekrar oluşturalım...

        cw := CreateChatWindow(fsi.FromServerId, fsi.FromUserId);
        cw.UserName := TabMesajKisiler.FieldByName('FIRMA').AsString;
        fsi.FChatWindow := cw;
        cw.FFileSends.Add(fsi);
        cw.WriteToWindow(fsi.FFromUserId, TabMesajKisiler.FieldByName('FIRMA').AsString, Tablo.GENINI.BugunTrhSaat,
          '<'+MsgDosyaSizinlePaylasiliyor +':' + fsi.FileName+'>', fsi.ReferenceId);
      end;
    end else if part = 'FSCONFIRMED' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(cmd);
      GtpLog.Log('File send confirmed ref : %d',[i]);

      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then begin
        fsi.IsConfirming := false;
        fsi.FileSize := FileSizeByName(fsi.FileName);
        cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasiminizKabulEdildi + ':' + fsi.FFileName + '>', False);
        fsi.Send(MsgClient);
      end;
    end else if part = 'FSDECLINED' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(cmd);
      GtpLog.Log('File send cancelled ref : %d',[i]);

      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then begin
        fsi.IsConfirming := false;
        cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasiminizReddedildi  + ':' + fsi.FFileName + '>', True);
        cw.FFileSends.Remove(fsi);
      end;
    end else if part = 'FSCANCELLED' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(cmd);
      GtpLog.Log('File send canceled ref : %d',[i]);

      fsi := cw.FindFileSendById(i*-1);
      if Assigned(fsi) then begin
        fsi.IsConfirming := false;
        cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasiminizIptalEdildi  + ':' + fsi.FFileName + '>', True);
        cw.FFileSends.Remove(fsi);
      end;
    end else if part = 'FILERECV' then begin
      GtpLog.Log('%s received',[part]);
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then
        fsi.FileSize := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '))
      else
        GtpLog.Log('File send reference %d was not found',[i]);
    end else if part = 'FSABORT' then begin // alici gönderir
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);

      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then begin
        if fsi.IsSend then
          cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasimiAliciTarafindanDurduruldu + ':' + fsi.FFileName + '>', True)
        else
          cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasimiGonderenTarafindanDurduruldu + ':' + fsi.FFileName + '>', True);
        fsi.Abort;
      end;
    end;


  end; }
end;

constructor TAnaGirisSayfasiFrame.Create(AOwner: TComponent);
var
  KulID: Integer;
begin
  inherited;
  KulID := StrToIntDef(Kullanan, 1);
  TabSK.Close;
  TabSK.SQL.Text :=
    ' select ' + DbUst(10) + ' M.MODULID, M.MODULADI from KULLANICI_ISLEM K ' +
    ' inner join MODUL M on K.ISLEMID=M.MODULID ' +
    ' where KULID=' + IntToStr(KulID) + ' order by SAY desc ' + DbSinir(10);
  TabSK.Open;
  FChatWindows := TObjectList<TChatWindow>.Create;
  FOnlineUsers := TStringList.Create;
  FOnlineUsers.NameValueSeparator := ' ';
  //FOnlineUsers.Delimiter := ',';
  FOnlineUsers.LineBreak := ',';
end;

function TAnaGirisSayfasiFrame.CreateChatWindow(AServerId, AUserId: Integer): TChatWindow;
begin
 { result := FindChatWindowByServerId(AServerId);
  if not Assigned(result) then begin
    result := TChatWindow.CreateNew(MsgClient, PageControlChat, AServerId, AUserId);
    result.CreateUI;
    FChatWindows.Add(result);
  end else begin
    if result.ServerId = -1 then
      result.ServerId := AServerId;
  end;
  if ActiveChatWindow <> result then
    result.FTabSheet.Highlighted := true; }

  // PageControlChat.ActivePage := Result.FTabSheet;
end;

function TAnaGirisSayfasiFrame.CreateChatWindowByUserID(AUserId: Integer): TChatWindow;
var
  serverId : Integer;
begin
 { result := FindChatWindowByUserId(AUserId);
  serverID := -1;
  if (FOnlineUsers.IndexOfName(IntToStr(AUserId)) > -1) then
    serverId := StrToInt(FOnlineUsers.Values[IntToStr(AUserId)]);
  if not Assigned(result) then begin
    result := TChatWindow.CreateNew(MsgClient, PageControlChat, serverId, AUserId);
    result.CreateUI;
    FChatWindows.Add(result);
  end;
  if ActiveChatWindow <> result then
    result.FTabSheet.Highlighted := true; }
end;

procedure TAnaGirisSayfasiFrame.cxButton3Click(Sender: TObject);
begin
  // if SonListelenenRapor = '' then
      KDRListeCategories0Items0Click(self);
  // else
      if SonListelenenRapor<>'' then
         KDR_LISTELE(SonListelenenRapor, TabKDR, GridKDRView,5);
end;

procedure TAnaGirisSayfasiFrame.cxEditRepository1ButtonItem1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);

var
  st: TStringList;
begin
  st := TStringList.Create;
  if Tablo.ListedenBilgiGetir(Seciniz, TabKosul.FieldByName('COMBOICERIK').AsString, st, []) then begin
    TcxButtonEdit(Sender).EditValue := st.Strings[0];
    TcxButtonEdit(Sender).PostEditValue;
  end;
end;

procedure TAnaGirisSayfasiFrame.cxGridDBColumn2GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);

var
  s: string;
begin
  case TabKosul.FieldByName('ICERIKTURU').AsInteger of
    2:
      AProperties := Tablo.cxEditRepository1SpinItem1.Properties; // rakam //cxEditRepository1CurrencyItem1.Properties; //rakam ÇALIŞMIYOR.. BUG VAR.. HEPSİNİ YAZI YAPTIM..
    5:
      AProperties := Tablo.cxEditRepository1DateItem1.Properties; // tarih
    7: // liste (combo)
      if TabKosul.FieldByName('COMBOICERIK').AsString <> '' then
      Begin
        s := TabKosul.FieldByName('COMBOICERIK').AsString;
        if Pos('SELECT', UpperCase(s)) = 0 then // selectli komut değilse bölümden getirsin
          s := 'select ANAHTAR from GENINI where BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR=''' + s + ''' and DIL=' + IntToStr(Dil)
            + ') order by SIRA';

        Tablo.cxEditRepository1ComboBoxItem1.Properties.Items.Clear;
        Tablo.Query1.Close;
        Tablo.Query1.SQL.text := s;
        Tablo.Query1.Open;
        Tablo.Query1.First;
        while Not Tablo.Query1.eof do
        begin
          Tablo.cxEditRepository1ComboBoxItem1.Properties.Items.Add(Tablo.Query1.fields[0].AsString);
          Tablo.Query1.Next;
        end;
        Tablo.cxEditRepository1ComboBoxItem1.Properties.DropDownListStyle := lsFixedList;
        AProperties := Tablo.cxEditRepository1ComboBoxItem1.Properties;
      End;
    8:
      Begin // BtnEdit
        Tablo.cxEditRepository1ButtonItem1.Properties.OnButtonClick := cxEditRepository1ButtonItem1PropertiesButtonClick;
        AProperties := Tablo.cxEditRepository1ButtonItem1.Properties;
      End;
    10: // imgcombo
      if TabKosul.FieldByName('COMBOICERIK').AsString <> '' then
      begin
        s := TabKosul.FieldByName('COMBOICERIK').AsString;
        if Pos('SELECT', UpperCase(s)) = 0 then // selectli komut değilse bölümden getirsin
          s := 'select ANAHTAR,DEGER from GENINI where BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR=''' + s + ''' and DIL=' + IntToStr
            (Dil) + ') order by SIRA';
        Tablo.cxEditRepository1ImageComboBoxItem1.Properties.Items.Clear;
        Tablo.Query1.Close;
        Tablo.Query1.SQL.text := s;
        Tablo.Query1.Open;
        Tablo.Query1.First;
        while Not Tablo.Query1.eof do
        begin
          with Tablo.cxEditRepository1ImageComboBoxItem1.Properties.Items.Add do
          begin
            Description := Tablo.Query1.fields[0].AsString;
            Value := Tablo.Query1.fields[1].AsString;
          end;
          Tablo.Query1.Next;
        end;
        AProperties := Tablo.cxEditRepository1ImageComboBoxItem1.Properties;
      End;

    11: // checkcombo
      { if TabKosul.FieldByName('COMBOICERIK').AsString <> '' then
        begin
        Tablo.cxEditRepository1CheckComboBox1.Properties.Items.Clear;
        s := TabKosul.FieldByName('COMBOICERIK').AsString;
        if Pos('SELECT', UpperCase(s)) = 0 then // selectli komut değilse bölümden getirsin
        s := 'select ANAHTAR from GENINI where BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR='''+s+''' and DIL='+IntToStr(Dil)+') order by SIRA';
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := s;
        Tablo.Query1.Open;
        Tablo.Query1.First;
        while Not Tablo.Query1.Eof do
        begin
        with Tablo.cxEditRepository1CheckComboBox1.Properties.Items.Add do  begin
        Description := trim(Tablo.Query1.Fields[0].AsString);
        DisplayName := trim(Tablo.Query1.Fields[0].AsString);
        if Tablo.Query1.FieldCount > 1 then
        ShortDescription := trim(Tablo.Query1.Fields[1].AsString)
        else
        ShortDescription := Copy(Tablo.Query1.Fields[0].AsString, 1, 5)
        end;
        Tablo.Query1.Next;
        end;
        Tablo.cxEditRepository1CheckComboBox1.Properties.Sorted := True;
        Tablo.cxEditRepository1CheckComboBox1.Properties.EditValueFormat := cvfStatesString;
        AProperties := Tablo.cxEditRepository1CheckComboBox1.Properties;
        End; }

    else
      AProperties := Tablo.cxEditRepository1TextItem1.Properties; // yazı
  end;
end;

procedure TAnaGirisSayfasiFrame.cxGridDBTableView1OKUNMAMISYORUMSAYStylesGetContentStyle(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  { if StrToIntDef(VartoStr(ARecord.Values[Sender.DataController.GetRowIndexByRecordIndex(ARecord.RecordIndex,True)]),0)>0 then
    AStyle := Tablo.cxStServerHata
    else
    AStyle := AnaForm.cxStyle1; }
end;

procedure TAnaGirisSayfasiFrame.cxLabel2Click(Sender: TObject);
begin
   CalendarDonemBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
end;

procedure TAnaGirisSayfasiFrame.GrafikOlustur(Yenile: Boolean; PageControl1: TcxPageControl);

var
  Tablo1: TFDQuery;
  Datasource1: TDataSource;
  Grid: TcxGrid;
  Level: TcxGridLevel;
  View: TcxGridDBChartView;
  Series1, Series2: TcxGridDBChartSeries;
  SQL: TStringList;
  i: SmallInt;
  s, Ustyazi, Altyazi: string;
begin
  if PageControl1.PageCount = 0 then
    exit;
  // döküme konumlanır
  TabDokum.Locate('ID', PageControl1.ActivePage.Tag, []);

  if Yenile then begin // yenileme (refresh) ise her sekme için oluşturulan componentler silinir
     Tablo1 := PageControl1.ActivePage.FindComponent('Tablo' + inttostr(PageControl1.ActivePage.Tag)) as TFDQuery;
     if Tablo1 <> nil then
        Tablo1.Free;
     Datasource1 := PageControl1.ActivePage.FindComponent('Datasource' + inttostr(PageControl1.ActivePage.Tag)) as TDataSource;
     if Datasource1 <> nil then
        Datasource1.Free;
     Grid := PageControl1.ActivePage.FindComponent('Grid' + inttostr(PageControl1.ActivePage.Tag)) as TcxGrid;
     if Grid <> nil then
        Grid.Free;
  end else if PageControl1.ActivePage.FindComponent('Tablo' + inttostr(PageControl1.ActivePage.Tag)) <> nil then
     exit // componentler varsa çıksın
  else if Trim(TabDokum.FieldByName('SQL').AsString) = '' then
     exit; // sql yoksa çıksın

  // Eğer grid varsa çıkılır
  // if (not Yenile)and(PageControl1.ActivePage.FindComponent('Tablo'+intToStr(PageControl1.ActivePage.Tag))<>nil) then
  // exit;

  // şimdi tabloyu oluşturup bağlayalım
  Tablo1 := TFDQuery.Create(PageControl1.ActivePage);
  Tablo1.Name := 'Tablo' + inttostr(PageControl1.ActivePage.Tag);
  Tablo1.Connection := Tablo.FDCnn;

  Datasource1 := TDataSource.Create(PageControl1.ActivePage);
  Datasource1.Name := 'Datasource' + inttostr(PageControl1.ActivePage.Tag);
  Datasource1.DataSet := Tablo1;
  // sql komutu alır ve açarız
  Tablo1.Close;
  Tablo1.SQL.text := TabDokum.FieldByName('SQL').AsString;

  SQL := TStringList.Create;
  SQL.Assign(TabDokum.FieldByName('SQL'));
  // Grafiğin üstüne ve altına yazılacak bilgileri alalım
  // Bunları neden önceden alıyoruz? Çünkü içinde koşul değişkeni olabilir. Örneğin SQL içindeki gibi $yil$
  // Altta koşulları okudukça SQL i değiştirdiğimiz gibi bunu da değiştiririz..
  Ustyazi := TabDokum.FieldByName('ACIKLAMA').AsString; // alandan gelir
  i := SQL.IndexOf('--Altayaz');
  if i >= 0 then
    Altyazi := Copy(SQL.Strings[i + 1], 3, 99); // alt yazı
  i := 0; // Koşulları Diziye Al
  TabKosul.First;
  while not TabKosul.eof do begin
    inc(i);
    if TabKosul.FieldByName('ICERIKTURU').AsInteger = 5 then // date
       s := FormatDateTime('mm' + FormatSettings.DateSeparator + 'dd' + FormatSettings.DateSeparator + 'yyyy', StrToDateDef(TabKosul.FieldByName('DEGER').AsString,
            Tablo.GENINI.BugunTrh)) // date
    else
       s := TabKosul.FieldByName('DEGER').AsString;
    Tablo1.SQL.text := StringReplace(Tablo1.SQL.text, '$' + TabKosul.FieldByName('KOD_ADI').AsString + '$', s, [rfReplaceAll]);
    Ustyazi := StringReplace(Ustyazi, '$' + TabKosul.FieldByName('KOD_ADI').AsString + '$', s, [rfReplaceAll]);
    Altyazi := StringReplace(Altyazi, '$' + TabKosul.FieldByName('KOD_ADI').AsString + '$', s, [rfReplaceAll]);
    TabKosul.Next;
  end;

  Tablo1.Open;
  // şimdi gridi oluşturup bağlayalım

  Grid := TcxGrid.Create(PageControl1.ActivePage);
  Grid.Parent := TPanel(PageControl1.ActivePage);
  Grid.Name := 'Grid' + inttostr(PageControl1.ActivePage.Tag);
  Grid.Align := alClient;
  // Creates a Level
  Level := Grid.Levels.Add;
  Level.Name := 'Level' + inttostr(PageControl1.ActivePage.Tag);
  // Creates a View
  View := Grid.CreateView(TcxGridDBChartView) as TcxGridDBChartView;
  View.Name := 'View' + inttostr(PageControl1.ActivePage.Tag);
  // ... and binds it to the Level
  Level.GridView := View;
  // Hooks up the View to the data

  View.DataController.DataSource := Datasource1;
  // Kategori bulalım    Ör: /*Kategori->AYADI*/
  i := SQL.IndexOf('--Kategori');
  if i >= 0 then
    View.Categories.DataBinding.FieldName := Copy(SQL.Strings[i + 1], 3, 99) // 'AYADI';
  else begin
    ShowMessage(AGGrafik_kategori_yok);
    SQL.Free;
    Abort;
  end;
  View.ToolBox.DiagramSelector := true; // diagram seçimi
  View.ToolBox.border := tbNone; // diagram seçimi sınır çizgisi olmamalı
  View.DiagramColumn.AxisValue.GridLines := true; // grid çizgileri
  View.DiagramColumn.AxisValue.TickMarkLabels := true; // Altta ayları gösterir
  View.DiagramColumn.Values.CaptionPosition := cdvcpOutsideEnd; // üstte değerlerinin görünmesini sağlar
  // View.DiagramColumn.AxisValue.
  // ... and creates all columns
  // View.DataController.CreateAllItems;
  // seileri ekleyelim Ör : --Seri:GIREN/Giren
  // --Seri:CIKAN/Çıkan
  i := SQL.IndexOf('--Seriler');
  while i < SQL.Count do begin
    if Pos('--Seri ', SQL.Strings[i]) > 0 then begin
      Series1 := View.CreateSeries;
      Series1.DataBinding.FieldName := Copy(SQL.Strings[i], 8, Pos('/', SQL.Strings[i]) - 8); // 'GIREN';
      Series1.DisplayText := Copy(SQL.Strings[i], Pos('/', SQL.Strings[i]) + 1, 99); // 'Giren';
      Series1.ValueCaptionFormat := '###,###,###,###.##'
    end;
    Inc(i);
  end;

  // Başlık
  View.Title.text := Ustyazi;
  // Alt yazı
  if Altyazi <> '' then
    View.Categories.DisplayText := Altyazi;
  // Grafiktipi
  i := SQL.IndexOf('--Grafiktipi');
  if i >= 0 then
    if SQL.Strings[i + 1] = '--Kolon' then begin
      View.DiagramColumn.Active := true;
    end else if SQL.Strings[i + 1] = '--Bar' then begin
      View.DiagramBar.Active := true;
    end else if SQL.Strings[i + 1] = '--Çizgi' then begin
      View.DiagramLine.Active := true;
    end else if SQL.Strings[i + 1] = '--Alan' then begin
      View.DiagramArea.Active := true;
    end else if SQL.Strings[i + 1] = '--Pasta' then begin
      View.DiagramPie.Active := true;
      View.DiagramPie.Values.CaptionPosition := pdvcpOutsideEndWithLeaderLines;
      // View.DiagramPie.Values.CaptionPosition.pdvciPercentage := True;
    end;

  SQL.Free;
  Grid.Show;
end;

procedure TAnaGirisSayfasiFrame.OlayListele;
begin

end;

procedure TAnaGirisSayfasiFrame.PageControlChatCanClose(Sender: TObject; var ACanClose: Boolean);
var i:Integer;
begin
  ACanClose := false;
  {for i := 0 to ActiveChatWindow.CardView.DataController.RecordCount - 1 do
    if StrToIntDef(VarToStrDef(ActiveChatWindow.CardView.DataController.Values[i,3],'0'),0)>0 then begin
      ShowMessage('Aktif dosya transferi işleminiz sonlanana yada iptal edilene kadar bu sayfayı kapatamazsınız!');
      ACanClose := false;
      Exit;
    end;  }
end;

procedure TAnaGirisSayfasiFrame.PageControlChatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbMiddle then
    PageControlChat.ActivePage.Destroy;
end;

procedure TAnaGirisSayfasiFrame.PageControlChatPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  NewPage.Highlighted := false;
  OkunmamisMesajSayisiDuzenle;
  BtnMesajGonder.Enabled := True;
  BtnDosyaGonder.Enabled := True;
  MemoChat.Enabled := True;
  if (not AnaFrameYoneticisi.AktifFrame.FrameYonetilebilir) and (PageControlOrta.ActivePage = SheetMesajlasma) then
    MemoChat.SetFocus;

end;

procedure TAnaGirisSayfasiFrame.YoneticiDokumuOlustur(Modul: string; APageControl: TcxPageControl);

var
  TabSheet: TcxTabSheet;
  I: SmallInt;
begin
  // önce tablodan bu bölüme ait dökümler okunur
  TabDokum.Close;
  TabDokum.SQL.text := 'select * from DOKUMLER where MODUL=''Y'' and GRUBU=''' + Modul + ''' order by 1';
  TabDokum.Open;
  // sonra herbir döküm için sekme oluşturulur
  if APageControl.PageCount <> TabDokum.RecordCount then
  begin
    // Eğer yeni frafik eklenmişse eski grafikleri de silip baştan oluşturmak gerekir
    try
      for I := APageControl.PageCount - 1 downto 0 do
        APageControl.Pages[I].Free;
    except

    end;
    TcxCustomTabControlAccess(APageControl).LockChangeEvent;
    while not TabDokum.eof do
    begin
      TabSheet := TcxTabSheet.Create(APageControl);
      TabSheet.PageControl := APageControl;
      TabSheet.Caption := TabDokum.FieldByName('RAPORADI').AsString;
      TabSheet.Tag := TabDokum.fields[0].AsInteger;
      TabDokum.Next
    end;
    TcxCustomTabControlAccess(APageControl).UnLockChangeEvent;
    APageControl.OnChange(Self);
  end;
end;

procedure TAnaGirisSayfasiFrame.PageCRMChange(Sender: TObject);
begin
  GrafikOlustur(false, PageCRM);
end;

procedure TAnaGirisSayfasiFrame.pageFinansChange(Sender: TObject);
begin
  GrafikOlustur(false, pageFinans);
end;

procedure TAnaGirisSayfasiFrame.PageServisChange(Sender: TObject);
begin
  GrafikOlustur(false, PageServis);
end;

procedure TAnaGirisSayfasiFrame.PageTeklifChange(Sender: TObject);
begin
  GrafikOlustur(false, PageTeklif);
end;

procedure TAnaGirisSayfasiFrame.Panel20DblClick(Sender: TObject);
begin
   Tablo.Satis2Fatura_Olustur(1);
end;

destructor TAnaGirisSayfasiFrame.Destroy;
begin
  FChatWindows.Free;
  inherited;
end;

procedure TAnaGirisSayfasiFrame.EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    AraTus.Click;
end;

procedure TAnaGirisSayfasiFrame.EditDuyuruAramaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_back then
     EditDuyuruArama.text:='';
  DuyuruYenileTus.Click;
end;

procedure TAnaGirisSayfasiFrame.ehirDeitir1Click(Sender: TObject);

var
  st: TStringList;
begin
  {st := TStringList.Create;
  if Tablo.ListedenBilgiGetir('Şehir seçimi yapınız.',
    'select ID=HAVADURUMUID,Sehir=ILADI from ILLER Where ILADI like ''%<ara>%'' AND HAVADURUMUID  IS NOT NULL', st, []) then begin
    HavaIl := st.Strings[0];
    Tablo.GENINI.WriteStringuser(Ops_HavaDurumu_Il, HavaIl);
    try
      HavaDurumuGuncelle;
    except
      lblHavaDurumu.Caption := '°C';
      HavaDurumuImage := 0;
    end;
  end;
  st.Free;              }

end;

procedure TAnaGirisSayfasiFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TAnaGirisSayfasiFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TAnaGirisSayfasiFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TAnaGirisSayfasiFrame.GetActiveChatWindow: TChatWindow;
begin
  if PageControlChat.PageCount = 0 then
    exit(nil);
  result := TChatWindow(PageControlChat.ActivePage.Tag);
end;

function TAnaGirisSayfasiFrame.GetFrameBilgi: TAnaFrameBilgi;
begin
  result := FFrameBilgi;
end;

function TAnaGirisSayfasiFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TAnaGirisSayfasiFrame.GorevGridViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TAnaGirisSayfasiFrame.GorevGridViewStylesGetGroupStyle(
  Sender: TcxGridTableView; ARecord: TcxCustomGridRecord; ALevel: Integer;
  var AStyle: TcxStyle);
begin
//Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TAnaGirisSayfasiFrame.Gorunmez;
begin

end;

procedure TAnaGirisSayfasiFrame.GorunmezOlacak;
begin

end;

procedure TAnaGirisSayfasiFrame.Gorunur;
begin

end;

procedure TAnaGirisSayfasiFrame.GorunurOlacak;
begin

end;

procedure TAnaGirisSayfasiFrame.IcerikFrameAktifOlacak(Sender: TIcerikFrameBilgi);
begin

end;

procedure TAnaGirisSayfasiFrame.JvDesktopAlert1MessageClick(Sender: TObject);
begin
  Tablo.DuyuruAc('O', 0, (Sender as TJvDesktopAlert).Tag)
end;

procedure TAnaGirisSayfasiFrame.JvDesktopAlert2MessageClick(Sender: TObject);
begin
  MesajaGit((Sender as TJvDesktopAlert).Tag);
end;

procedure TAnaGirisSayfasiFrame.JvTimer1Timer(Sender: TObject);
begin
  HandleFileSends;
  JvTimer1.Enabled := True;
end;

procedure TAnaGirisSayfasiFrame.MesajaGit(MesajSayfasi: Integer);
begin
  with (FFrameBilgi.AnaFrameYoneticisi.FrameBul(TAnaGirisSayfasiFrame).Ornek as TAnaGirisSayfasiFrame).GetFrameBilgi.Git do begin
    BtnMesaj.Click;
    PageControlChat.ActivePageIndex := MesajSayfasi;
  end;
end;

procedure TAnaGirisSayfasiFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TAnaGirisSayfasiFrame.KosullarMenuClick(Sender: TObject);
begin
  ScrollBoxYoneticiSag.Visible := true;
  KosulButon.Visible := false;
end;

procedure TAnaGirisSayfasiFrame.ProfilResimClick(Sender: TObject);

var
  DosyaAdi: string;
begin
  if Tablo.OpenPictureDialog1.Execute then
  begin
    // DosyaAdi := ResimOlcumleme(Tablo.OpenPictureDialog1.Files[0]);
    DosyaAdi := ResimKucult(Tablo.OpenPictureDialog1.Files[0], 130);
    if DosyaAdi <> '' then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from IMAJ where REHBERID=' + Kullanan + ' and YERI=13 and YER_ID=' + Kullanan, [], []);
      ResimEkleme(DosyaAdi, StrToInt(Kullanan), 13, StrToInt(Kullanan));
      ResimGetir(StrToInt(Kullanan), 13, StrToInt(Kullanan), ProfilResim);
    end;
  end;
end;

procedure TAnaGirisSayfasiFrame.MemoChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = 13) and (Shift <> [ssCtrl]) then
    BtnMesajGonderClick(Self);
end;

procedure TAnaGirisSayfasiFrame.SatirEkleClick(Sender: TObject);
begin
  DuyuruAlarmiVer(Tablo.DuyuruAc('E',0, 0));

end;

procedure TAnaGirisSayfasiFrame.DuyuruAlarmiVer(DuyuruID: Integer);

var
  st: string;
begin
  {if (DuyuruID > 0) and (MsgClient.Connected) then
  begin
    Tablo.TablodanSorguAc(7, 'select ALICIID from DUYURUKULLANICI where OKUNDU=0 and DUYURUID=' + IntToStr(DuyuruID));
    st := 'DYR ' + IntToStr(DuyuruID) + ' ';
    Tablo.Query7.First;
    while not Tablo.Query7.eof do
    begin
      st := st + Tablo.Query7.fields[0].AsString + ',';
      Tablo.Query7.Next;
    end;
    MsgClient.Socket.WriteLn(st);
  end; }

end;

procedure TAnaGirisSayfasiFrame.DuyuruYenileTusClick(Sender: TObject);
begin
   if PanelMesajDuyuru.Visible then
      TabDuyuruListe.sql.Text := duyuruMemo.Text
   else
      TabDuyuruListe.sql.Text := StringReplace(duyuruMemo.Text, '--Kategori', ' and TUR=-1 and KATEGORI=11 ', [rfReplaceAll]);

   TabloYenile(TabDuyuruListe, [StrToInt(Kullanan), '%'+EditDuyuruArama.text+'%', Tablo.GENINI.ReadInteger(Ops_UyariOpsiyon_Gorunmesin, 90)]);
end;

procedure TAnaGirisSayfasiFrame.KDR_BORCLULARClick(Sender: TdxTileControlItem);
begin
   KDR_LISTELE(TdxTileControlItem(Sender).Name, TabKDR, GridKDRView,5)
end;

procedure TAnaGirisSayfasiFrame.KDR_DONEM_BASIClick(Sender: TdxTileControlItem);
begin
   KDR_LISTELE(TdxTileControlItem(Sender).Name, TabKDRStok, GridStokView,5)
end;

procedure TAnaGirisSayfasiFrame.KDR_LISTELE(RaporAd:String; Tablo1:TFDQuery; GridView: tcxGridDBTableView; TopKolonu:smallint);
var Tplm : tcxDataSummaryItem;
    I:Smallint;
begin
   //if RaporAd = 'KDR_KREDILER' then
   //   TopKolonu := 5
   //else
   //   TopKolonu := 4;

  //önce basılan butonla ilgili dökümü açalım
   SonListelenenRapor := RaporAd;
   Tablo1.Close;
   TabDokum.Close;
   TabDokum.SQL.Text := 'select * from DOKUMLER where RAPORADI = '''+RaporAd+'''  ';
   TabloYenile(TabDokum, []);
   //eğer döküm varsa içeriği listeleyelim
   if TabDokum.recordcount>0 then begin
      Tablo1.SQL.Text := TabDokum.FieldByName('SQL').AsString;
      if Tablo1.Name='TabKDR' then
         TabloYenile(Tablo1, [FormatDateTime('yyyy-mm-dd 00:00', DateKDRDonemBas.Date), FormatDateTime('yyyy-mm-dd 23:59', DateKDRDonemSon.Date)])
      else
         TabloYenile(Tablo1, [FormatDateTime('yyyy-mm-dd 00:00', CalendarDonemBas.Date), FormatDateTime('yyyy-mm-dd 23:59', CalendarDonemSon.Date)]);

      while GridView.ColumnCount > 0 do
            GridView.Columns[0].Destroy;
      GridView.DataController.CreateAllItems;

      for I := 0 to Tablo1.fieldcount-1 do
         if Tablo1.fields[I].datatype in [ftfloat,ftCurrency, ftBCD, ftFMTBcd] then begin
            GridView.Columns[I].RepositoryItem := Tablo.RepCurrencyGenel;
            // 26.05.24 AO alt toplamlar
            Tplm := GridView.DataController.Summary.FooterSummaryItems.Add(GridView.Columns[I],spFooter,skSum);
            Tplm.format := ',0.00;(,0.00)';
         end;

(* 26.05.24      if GridView.ColumnCount > 0 then begin
         TopKolonu := Tablo1.fieldcount-1;
         GridView.DataController.Summary.FooterSummaryItems.Add(GridView.Columns[0],spFooter,skCount);
         if Tablo1.fields[TopKolonu].datatype in [ftfloat,ftCurrency] then begin
            Tplm := GridView.DataController.Summary.FooterSummaryItems.Add(GridView.Columns[TopKolonu],spFooter,skSum);
            Tplm.format := ',0.00;(,0.00)';
        end;
      end;    *)
      GridView.ApplyBestFit(nil);
   end;
end;

procedure TAnaGirisSayfasiFrame.pnlBankaTanimlariMouseEnter(Sender: TObject);
  begin
    TJvPanel(Sender).Invalidate;
  end;

  procedure TAnaGirisSayfasiFrame.pnlImageDblClick(Sender: TObject);
begin
   if Application.MessageBox(PChar('Lisans sıfırlanacaktır. Onaylıyor musunuz'), PChar(Uyari), MB_YESNO + MB_ICONQUESTION) = IDYES then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM like ''-1009_'' ',[],[]);
end;

procedure TAnaGirisSayfasiFrame.pnlImagePaint(Sender: TObject);
begin
//    pnlImage.Canvas.Brush.Color := clWhite;
//    pnlImage.Canvas.FillRect(Rect(0, 0, pnlImage.Width, pnlImage.Height));
//    PngImageList3.Draw(pnlImage.Canvas, pnlImage.Width div 2 - 18, pnlImage.Height div 2 - 18, FHavaDurumuImage);
end;

procedure TAnaGirisSayfasiFrame.pnlBankaTanimlariPaint(Sender: TObject);

var
  r: TRect;
  pnl: TJvPanel;
begin
  if pnl.MouseInClient then
  begin
    pnl := TJvPanel(Sender);
    r := pnl.ClientRect;
    GradientFillRect(pnl.Canvas, r, $00F2F9FF, $00BFE2FF, fdTopToBottom, 255);
    pnl.Canvas.Brush.Style := bsClear;
    pnl.Canvas.Pen.Color := clBtnShadow;
    pnl.Canvas.RoundRect(0, 0, r.Right, r.Bottom, 7, 7);
  end;

end;

procedure TAnaGirisSayfasiFrame.SetFrameBilgi(AValue: TAnaFrameBilgi);
begin
  FFrameBilgi := AValue;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TAnaGirisSayfasiFrame.Baglan;
begin
 { if not MsgClient.Connected then
    try
      MsgClient.Host := Tablo.GENINI.ReadString(Ops_ChatOpsiyon_Adres, '127.0.0.1');
      MsgClient.Port := StrToInt(Tablo.GENINI.ReadString(Ops_ChatOpsiyon_Port, '7777'));
      if MsgClient.Host <> '127.0.0.1' then begin
        MsgClient.Connect;
        MesajLED.Status := MsgClient.Connected;
        PanelChat.Enabled := MesajLED.Status;
        cxGrid4.Enabled := MesajLED.Status;
      end;
    except
      MesajLED.Status := false;
      PanelChat.Enabled := false;
      cxGrid4.Enabled := false;
    end;  }
end;

procedure TAnaGirisSayfasiFrame.SpeedButton1Click(Sender: TObject);
begin
  ScrollBoxYoneticiSag.Visible := false;
  KosulButon.Visible := true;
end;

procedure TAnaGirisSayfasiFrame.DokumAyarlarMenuClick(Sender: TObject);

var
  sonuc: Integer;
begin
  Application.CreateForm(TDokumSartDlg, DokumSartDlg);
  DokumSartDlg.DtsDokumler.DataSet := TabDokum;
  DokumSartDlg.DtsKosul.DataSet := TabKosul;
  if TMenuItem(Sender).Name = 'YeniDokumMenu' then
    TabDokum.Append;
  sonuc := DokumSartDlg.ShowModal;
  DokumSartDlg.Destroy;
  if TMenuItem(Sender).Name = 'YeniDokumMenu' then // 99 silinme       yeni veya silindiyse tüm sekmeler yeniden oluşmalı
    btnAramaClick(Self)
  else
    if PageControlOrta.ActivePage <> SheetKDR then
       YenileMenu.Click;
end;

procedure TAnaGirisSayfasiFrame.DokumKaydetMenuClick(Sender: TObject);
var
  DosyaAdi, Dizin: string;
  procedure Kaydet(ID: Integer; Vers, KayitAdi: String);
  begin
    Vers := TabDokum.AsString['VERSIYON'];
    Vers := StringReplace(DosyaAdi, '.', '-', []);
    Vers := StringReplace(KayitAdi, '.FR', ' #' + Vers + '.FR', [rfIgnoreCase]);
    FastRaporDlg.FastReportTextKaydet(Vers, ID); // FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl, kaynakDokum
  end;
  begin
    // kaynakDokum := TabDokum.AsString['RAPORADI'];
    Tablo.SaveDialog1.FileName := TabDokum.AsString['RAPORADI'] + '.frd'; // döküm ayarları
    Tablo.SaveDialog1.Filter := '.frd';

    if Tablo.SaveDialog1.Execute then
    begin
      if Pos('hepsinikaydet', Tablo.SaveDialog1.FileName) > 0 then
      begin // bütün raporlar kaydedilecek
        if DirectoryExists('Raporlars') then
          RemoveDir('Raporlars');
        CreateDir('Raporlars');

        Tablo.TablodanSorguAc(5, 'select ID, VERSIYON, RAPORADI, GRUBU from DOKUMLER where MODUL=''Y'' order by GRUBU');
        while not Tablo.Query5.eof do
        begin
          if not DirectoryExists('Raporlars\' + Tablo.Query5.AsString['GRUBU']) then
            CreateDir('Raporlars\' + Tablo.Query5.AsString['GRUBU']);
          Kaydet(Tablo.Query5.AsInteger['ID'], Tablo.Query5.AsString['VERSIYON'],
            'Raporlars\' + Tablo.Query5.AsString['GRUBU'] + '\' + Tablo.Query5.AsString['RAPORADI'] + '.frd');
          Tablo.Query5.Next;
        end;
      end
      else
        Kaydet(TabDokum.AsInteger['ID'], TabDokum.AsString['VERSIYON'], Tablo.SaveDialog1.FileName);
    end;
  end;

  procedure TAnaGirisSayfasiFrame.DokumSilMenuClick(Sender: TObject);
  begin
    if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
    begin
      if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from KOSULLAR where DOKUMID = $PID', ['PID'], [TabDokum.fields[0].AsInteger]) then
        raise Exception.Create(AGKosul_sil);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM AYARLARYENI WHERE DOKUMID = &ID', ['&ID'], [TabDokum.fields[0].AsInteger]);
      TabDokum.Delete;
      btnAramaClick(Self)
    end;
  end;

  procedure TAnaGirisSayfasiFrame.DokumuKopyalaMenuClick(Sender: TObject);

var
  yeniad: string;
  dokumAdi: Variant;
  kaynakDokum: string;
begin
  kaynakDokum := TabDokum.FieldByName('RAPORADI').AsString;
  dokumAdi := kaynakDokum + '1';
  if TGirisKutusuEx.BilgiAlEx(BGDokum_Rapor_Kopyala, TGirdiDenetimleri.Create.Edit(BGYeni_ad, @dokumAdi)) = mrOk then
  begin
    if Trim(dokumAdi) = '' then
      MessageDlg('Döküm/Rapor adı boş olamaz!', mtError, [mbOK], 0)
    else
    begin
      TRaporAraclari.RaporKopyala(TabDokum.fields[0].AsInteger, dokumAdi);
      btnAramaClick(Self)
    end
  end;
end;

procedure TAnaGirisSayfasiFrame.TabDokumAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabKosul, [TabDokum.fields[0].AsInteger]);
end;

procedure TAnaGirisSayfasiFrame.TabDokumBeforePost(DataSet: TDataSet);
  function VersiyonGetir(Ver:string) : string;
  var i : SmallInt;
  begin
     if Ver = '' then
        Result := '1.1'
     else begin
        i := StrToIntDef(Copy(Ver,1,pos('.', Ver)-1),1);
        Inc(i);
        Result := IntToStr(i)+'.'+Copy(Ver,pos('.', Ver)+1,10);
     end;
  end;
begin
   //if OncekiSQL <> TabDokum.FieldByName('SQL').AsString then
   TabDokum.FieldByName('VERSIYON').AsString := VersiyonGetir(TabDokum.FieldByName('VERSIYON').AsString);
   TabDokum.FieldByName('SQL').AsString := trim(TabDokum.FieldByName('SQL').AsString);
   EkleyenDegistiren(TabDokum);
end;

procedure TAnaGirisSayfasiFrame.TabDokumNewRecord(DataSet: TDataSet);
begin
  TabDokum.FieldByName('STANDART').AsBoolean:= True; // Yönetici
  TabDokum.FieldByName('MODUL').AsString := 'Y'; // Yönetici
  TabDokum.FieldByName('GRUBU').AsString := StringReplace(PageControlOrta.ActivePage.Caption, 'SheetYonetim', '', [rfReplaceAll]);
  EkleyenDegistiren(TabDokum);
end;

procedure TAnaGirisSayfasiFrame.TabKosulNewRecord(DataSet: TDataSet);
begin
  TabKosul.fields[1].AsInteger := TabDokum.fields[0].AsInteger;
end;

procedure TAnaGirisSayfasiFrame.TryCloseMainForm;
var
  cw : TChatWindow;
  fsi : TFileSendInfo;
  cls : Boolean;
begin
  if not FMainFormClosing then Exit;
  cls := True;
  for cw in FChatWindows do begin
    if cw.FFileSends.Count > 0 then
      cls := False;
  end;
  if cls then
    AnaForm.Close;  
end;

procedure TAnaGirisSayfasiFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TAnaGirisSayfasiFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TAnaGirisSayfasiFrame.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;
procedure TAnaGirisSayfasiFrame.SetHavaDurumuImage(const Value: Integer);
begin
  //FHavaDurumuImage := Value;
  pnlImage.Repaint;
end;

procedure TAnaGirisSayfasiFrame.tvAktivitelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TAnaGirisSayfasiFrame.tvProjelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TAnaGirisSayfasiFrame.MsgClientConnected(Sender: TObject);
begin
{  MsgClient.Socket.WriteLn('messaging');
  MsgClient.Socket.WriteLn(KullanAdi);
  MsgClient.Socket.WriteLn(Kullanan);
  FServerId := StrToInt(MsgClient.Socket.ReadLn); }
end;

procedure TAnaGirisSayfasiFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TAnaGirisSayfasiFrame.Yenile1Click(Sender: TObject);
begin
 { try
    HavaDurumuGuncelle;
  except
    lblHavaDurumu.Caption := '°C';
    HavaDurumuImage := 0;
  end;}
end;

procedure TAnaGirisSayfasiFrame.YenileMenuClick(Sender: TObject);
begin
  if TabKosul.State in [dsEdit, dsInsert] then
    TabKosul.Post;
  GrafikOlustur(true, TcxPageControl(FindComponent(StringReplace(PageControlOrta.ActivePage.Name, 'SheetYonetim', 'Page', []))));
end;

{ TFileSendInfo }

procedure TFileSendInfo.Abort;
begin
  FIsAborted := True;
end;

constructor TFileSendInfo.Create(AFileName: string);
begin
  FFileName := AFileName;
  FReferenceId := RefCounter;
  Inc(RefCounter);
  FState := 0;
end;

class function TFileSendInfo.CreateNew(AChatWindow: TChatWindow; AFileName: string): TFileSendInfo;
begin
  result := TFileSendInfo.Create(AFileName);
  result.FChatWindow := AChatWindow;
  if Assigned(AChatWindow) then
    AChatWindow.FFileSends.Add(result);
end;

destructor TFileSendInfo.Destroy;
begin
  if Assigned(FClient) then
    FClient.Free;
  inherited;
end;

class function TFileSendInfo.FromMessage(AMsg: string): TFileSendInfo;
begin
  result := CreateNew(nil,'');
  with result do begin
    FFromServerId := StrToInt(Dize.SinirlandirilmisMetin(AMsg, ' '));
    FFromUserId := StrToInt(Dize.SinirlandirilmisMetin(AMsg, ' '));
    FLogId := StrToInt(Dize.SinirlandirilmisMetin(AMsg, ' '));
    FLogUserId := StrToInt(Dize.SinirlandirilmisMetin(AMsg, ' '));
    FReferenceId := StrToInt(Dize.SinirlandirilmisMetin(AMsg, ' ')) * -1;
    FFileSize := StrToInt(Dize.SinirlandirilmisMetin(AMsg, ' '));
    FIsConfirming := true;
    FFileName := AMsg;
  end;
end;

procedure TFileSendInfo.MsgClientConnected(Sender: TObject);
begin

end;


procedure TFileSendInfo.PartialReceive;
var
  sck : TIdIOHandlerSocket;
  s   : string;
  msg : string;
begin
  if not Assigned(FClient) then Exit;
  if not FClient.Connected then Exit;
  sck := FClient.Socket;
  if FState = 0 then begin
    sck.WriteLn('filereceiving');
    Msg := Format('%d %d %d', [FromServerId, ToServerId, ReferenceId * -1]);
    sck.WriteLn(Msg);
    FState := 1;
    FReceivedBytes := 0;
  end else if FState = 1 then begin
    if not sck.InputBufferIsEmpty then begin
      s := sck.ReadLn(#$A,300);
      if (not sck.ReadLnTimedout) then begin
        FRemainingBytes := StrToInt(s);
        FFileStream := TFileStream.Create(FileName, fmCreate);
        SetLength(FBuffer, 104858);
        FState := 2;
      end;
    end;
  end else if FState = 2 then begin
    try
      if FRemainingBytes > 0 then begin
        if (sck.ReadByte = 1)or(not FClient.Connected) then begin
          FIsAborted := True;
          FState := 3;
          Exit;
        end;
        if FRemainingBytes >= 104858 then
        begin
          FReceivedBytes := FReceivedBytes + Length(FBuffer);
          FChatWindow.EditChatMessage(FChatWindow.FUserId, FReferenceId,'<' + MsgDosyaAliniyor + ':' + FFileName + ' - ' + FormatFloat('#####0.##',FReceivedBytes/1048576) + 'MB/'+ FormatFloat('#####0.##',FFileSize/1048576) + 'MB>',True);
          sck.ReadBytes(FBuffer, 104858,False);
          FFileStream.Write(FBuffer[0], 104858);
          FRemainingBytes := FRemainingBytes - 104858;
        end
        else
        begin
          sck.ReadBytes(FBuffer, FRemainingBytes,False);
          FFileStream.Write(FBuffer[0], FRemainingBytes);
          FRemainingBytes := 0;
        end;
      end else FState := 3;
    except
      FState := 3;
      FIsAborted := True;
    end;
  end else if FState = 3 then begin
    if not FIsAborted then
      FChatWindow.EditChatMessage(FChatWindow.FUserId, FReferenceId,'<' + MsgDosyaGonderiminizTamamlandi + ':' + FFileName + ' - ' + FormatFloat('#####0.##',FFileSize/1048576) + 'MB>',True)
    else
      FChatWindow.EditChatMessage(FChatWindow.FUserId, FReferenceId, '<' + MsgDosyaPaylasimiGonderenTarafindanDurduruldu + ':' + FFileName + '>', True); 
    FFileStream.Free;
    FClient.Disconnect;
    FChatWindow.OnFileSendReceiveCompleted(Self);
    FState := 4;
  end;
end;

procedure TFileSendInfo.PartialSend;
label __exit;
var
  sck : TIdIOHandlerSocket;
  s   : string;
  msg : string;
begin
  if not Assigned(FClient) then Exit;
  if not FClient.Connected then Exit;
  sck := FClient.Socket;
  if FState = 0 then begin
    sck.WriteLn('filesending');
    Msg := Format('%d %d %d %d', [FromServerId, ToServerId, FileSize, ReferenceId]);
    sck.WriteLn(Msg);
    FState := 1;
  end else if FState = 1 then begin
    if not sck.InputBufferIsEmpty then begin
      s := sck.ReadLn(#$A,300);
      if (not sck.ReadLnTimedout) and (s = 'beginsend') then begin
        FState := 2;
      end;
    end;
    FSentBytes := 0;
  end else if FState = 2 then begin
    SetLength(FBuffer, 104858);
    FFileStream := TFileStream.Create(FileName, fmOpenRead);
    FState := 3;
  end else if FState = 3 then begin
    try
      FRemainingBytes := FFileStream.Read(FBuffer[0], 104858);
      if FRemainingBytes > 0 then begin
        if FIsAborted then begin
          sck.Write(1);
          FState := 4;
          Exit;
        end else
          sck.Write(0);
        FSentBytes := FSentBytes + Length(FBuffer);
        FChatWindow.EditChatMessage(FChatWindow.FUserId, FReferenceId,'<' + MsgDosyaVeriliyor + ':' + FFileName + ' - ' + FormatFloat('#####0.##',FSentBytes/1048576) + 'MB/'+ FormatFloat('#####0.##',FFileSize/1048576) + 'MB>',True);
        sck.Write(FBuffer, FRemainingBytes, 0);
      end else FState := 4;
    except
      FState := 4;
      FIsAborted := True;
    end;
  end else if FState = 4 then begin
    if not FIsAborted then
      FChatWindow.EditChatMessage(FChatWindow.FUserId, FReferenceId,'<' + MsgDosyaAliminizTamamlandi + ':' + FFileName + ' - ' + FormatFloat('#####0.##',FFileSize/1048576) + 'MB>',True);
    FFileStream.Free;
    FClient.Disconnect;
    FChatWindow.OnFileSendReceiveCompleted(Self);
    FState := 5;
  end;
end;

procedure TFileSendInfo.PerformOperation;
begin
  if IsSend then
    PartialSend
  else
    PartialReceive;
end;

procedure TFileSendInfo.Receive(AOrg: TIdTCPClient);
begin
  if not Assigned(FClient) then
  begin
    FClient := TIdTCPClient.Create(nil);
    FClient.Host := AOrg.Host;
    FClient.Port := AOrg.Port;
    FClient.OnConnected := MsgClientConnected;
  end;
  FClient.Connect;
end;

procedure TFileSendInfo.Send(AOrg: TIdTCPClient);
begin
  if not Assigned(FClient) then
  begin
    FClient := TIdTCPClient.Create(nil);
    FClient.Host := AOrg.Host;
    FClient.Port := AOrg.Port;
    FClient.OnConnected := MsgClientConnected;
  end;
  FClient.Connect;
end;

{ TChatWindow }

procedure TChatWindow.AliciOnayIptalClick(Sender: TObject; AButtonIndex: Integer);
var
  Msg, Part1, Part2: string;
  MesajLogID, MesajLogKullaniciID: Variant;
  i, refId: Integer;
  fsi: TFileSendInfo;
begin
  if not Assigned(FSaveDialog) then
    FSaveDialog := TSaveDialog.Create(FPageControl.Owner);
  refId := FCardView.DataController.Values[FCardView.DataController.EditingRecordIndex, 3];
  fsi := FindFileSendById(refId);
  if Assigned(fsi) then
  begin
    if AButtonIndex = 0 then
    begin
      FSaveDialog.DefaultExt := ExtractFileExt(fsi.FFileName);
      FSaveDialog.FileName := fsi.FFileName;
      FSaveDialog.Filter := ExtractFileExt(fsi.FFileName) + '|*' + ExtractFileExt(fsi.FFileName);
      if FSaveDialog.Execute then
      begin
        for I := 0 to (Sender as TcxTextEdit).Properties.Buttons.Count - 1 do
          (Sender as TcxTextEdit).Properties.Buttons[i].Enabled := false;
        MesajLogID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'insert into MESAJLOG(TUR,GONDERENID,MESAJ)values(&Tur,&GonderenID,&Mesaj) select scope_identity() ', ['&Tur', '&GonderenID', '&Mesaj'],
          [2, Kullanan, '<' + MsgDosyaPaylasiminiKabulEttiniz + ':' + FSaveDialog.FileName + '>'], true);
        MesajLogKullaniciID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'insert into MESAJLOGKULLANICI(MESAJLOGID,ALICIID)values(&MesajLogID,&AliciID) select scope_identity()', ['&MesajLogID', '&AliciID'],
          [VarToStr(MesajLogID), FUserId], true);
        EditChatMessage(FUserId,fsi.ReferenceId,'<' + MsgDosyaPaylasiminiKabulEttiniz + ':' + FSaveDialog.FileName + '>',False);
        Msg := Format('FSCONFIRMED %d %s %s %d', [fsi.FromServerId, VarToStr(MesajLogID), VarToStr(MesajLogKullaniciID), fsi.ReferenceId * -1]);
        fsi.FileName := FSaveDialog.FileName;
        fsi.IsConfirming := false;
        FMsgClient.Socket.WriteLn(Msg);
        fsi.Receive(FMsgClient);
      end;
    end else if AButtonIndex = 1 then begin
      for I := 0 to (Sender as TcxTextEdit).Properties.Buttons.Count - 1 do (Sender as TcxTextEdit)
        .Properties.Buttons[i].Enabled := false;
      MesajLogID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into MESAJLOG(TUR,GONDERENID,MESAJ)values(&Tur,&GonderenID,&Mesaj) select scope_identity() ', ['&Tur', '&GonderenID', '&Mesaj'],
        [2, Kullanan, '<' + MsgDosyaPaylasiminiReddettiniz + ':' + fsi.FFileName + '>'], true);
      MesajLogKullaniciID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into MESAJLOGKULLANICI(MESAJLOGID,ALICIID)values(&MesajLogID,&AliciID) select scope_identity()', ['&MesajLogID', '&AliciID'],
        [VarToStr(MesajLogID), FUserId], true);
      Msg := Format('FSDECLINED %d %s %s %d', [fsi.FromServerId, VarToStr(MesajLogID), VarToStr(MesajLogKullaniciID), fsi.ReferenceId * -1]);
      fsi.IsConfirming := false;
      EditChatMessage(FUserId,fsi.ReferenceId,'<' + MsgDosyaPaylasiminiReddettiniz  + ':' + fsi.FFileName + '>',True);
      FMsgClient.Socket.WriteLn(Msg);
      fsi.FChatWindow.FFileSends.Remove(fsi);

    end;
  end;
end;

procedure TChatWindow.GonderenIptalClick(Sender: TObject; AButtonIndex: Integer);
var
  Msg: string;
  MesajLogID, MesajLogKullaniciID: Variant;
  i, refId: Integer;
  fsi: TFileSendInfo;
begin
  for I := 0 to (Sender as TcxTextEdit).Properties.Buttons.Count - 1 do
    (Sender as TcxTextEdit).Properties.Buttons[i].Enabled := false;
  refId := FCardView.DataController.Values[FCardView.DataController.EditingRecordIndex, 3];
  fsi := FindFileSendById(refId);

  MesajLogID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'insert into MESAJLOG(TUR,GONDERENID,MESAJ)values(&Tur,&GonderenID,&Mesaj) select scope_identity() ', ['&Tur', '&GonderenID', '&Mesaj'],
    [2, Kullanan, '<' + MsgDosyaPaylasiminiIptalEttiniz + ':' + fsi.FFileName + '>'], true);
  MesajLogKullaniciID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'insert into MESAJLOGKULLANICI(MESAJLOGID,ALICIID)values(&MesajLogID,&AliciID) select scope_identity()', ['&MesajLogID', '&AliciID'],
    [VarToStr(MesajLogID), FUserId], true);
  Msg := Format('FSCANCELLED %d %s %s %d', [fsi.FToServerId, VarToStr(MesajLogID), VarToStr(MesajLogKullaniciID), fsi.ReferenceId]);
  fsi.IsConfirming := false;
  EditChatMessage(FUserId, fsi.ReferenceId,'<' + MsgDosyaPaylasiminiIptalEttiniz  + ':' + fsi.FFileName + '>',True);
  FMsgClient.Socket.WriteLn(Msg);
  fsi.FChatWindow.FFileSends.Remove(fsi);
end;

procedure TChatWindow.GonderenProgressIptalClick(Sender: TObject; AButtonIndex: Integer);
var
  i: Integer;
  refId: Integer;
  fsi: TFileSendInfo;
  msg: string;
begin
  for I := 0 to (Sender as TcxTextEdit).Properties.Buttons.Count - 1 do (Sender as TcxTextEdit)
    .Properties.Buttons[i].Enabled := false;
  refId := FCardView.DataController.Values[FCardView.DataController.EditingRecordIndex, 3];
  fsi := FindFileSendById(refId);
  EditChatMessage(FUserId, fsi.ReferenceId,'<' + MsgDosyaVermeyiDurduruldunuz   + ':' + fsi.FFileName + '>',True);
  fsi.Abort;
end;

procedure TChatWindow.HandleFileSends;
var
  fs : TFileSendInfo;
begin
  for fs in FFileSends do
    fs.PerformOperation;
end;

procedure TChatWindow.AliciProgressIptalClick(Sender: TObject; AButtonIndex: Integer);
var
  i: Integer;
  refId: Integer;
  fsi: TFileSendInfo;
begin
  for I := 0 to (Sender as TcxTextEdit).Properties.Buttons.Count - 1 do
    (Sender as TcxTextEdit).Properties.Buttons[i].Enabled := false;
  refId := FCardView.DataController.Values[FCardView.DataController.EditingRecordIndex, 3];
  fsi := FindFileSendById(refId);
  EditChatMessage(FUserId, fsi.ReferenceId,'<' + MsgDosyaAlmayiDurduruldunuz + ':' + fsi.FFileName + '>',True);
  FMsgClient.Socket.WriteLn(Format('FSABORT %d %d',[fsi.FromServerId,fsi.ReferenceId * -1]));
end;

constructor TChatWindow.Create(AMsgClient: TIdTCPClient);
begin
  FMsgClient := AMsgClient;
  FFileSends := TObjectList<TFileSendInfo>.Create;
end;

class function TChatWindow.CreateNew(AMsgClient: TIdTCPClient; APageControl: TcxPageControl; AServerId, AUserId: Integer): TChatWindow;
begin
  result := TChatWindow.Create(AMsgClient);
  result.FPageControl := APageControl;
  result.FServerId := AServerId;
  result.FUserId := AUserId;
end;

procedure TChatWindow.CreateUI;

var
  CAd, CTrh, CMsg, CRefID: TcxGridCardViewRow;
begin
  FTabSheet := TcxTabSheet.Create(FPageControl.Owner);
  with FTabSheet do
  begin
    Parent := FPageControl;
    Caption := FUserName;
    //my.15.05.2025 Integer --> NativeInt
    Tag := NativeInt(Self);
  end;
  FGrid := TcxGrid.Create(FPageControl.Owner);
  with FGrid do
  begin
    Parent := FTabSheet;
    Align := alClient;
  end;
  FCardView := (FGrid.CreateView(TcxGridCardView) as TcxGridCardView);
  with FCardView do
  begin
    OptionsCustomize.RowFiltering := false;
    OptionsSelection.HideFocusRectOnExit := false;
    OptionsSelection.InvertSelect := false;
    OptionsSelection.UnselectFocusedRecordOnExit := false;
    OptionsView.ScrollBars := ssVertical;
    LayoutDirection := ldVertical;
    OptionsView.CaptionSeparator := #0;
    OptionsView.CardBorderWidth := 4;
    OptionsView.CardIndent := 0;
    OptionsView.CardWidth := 800;
    OptionsView.CategorySeparatorWidth := 1;
    OptionsView.CellAutoHeight := true;
    OptionsView.SeparatorWidth := 0;
    OptionsData.Deleting := False;
    Styles.OnGetContentStyle := MsgStylesOnGetContentStyle;
    Styles.StyleSheet := Tablo.cxGridCardViewStyleSheetMsg;
  end;
  FGridLevel := FGrid.Levels.Add;
  with FGridLevel do
  begin
    GridView := FCardView;
  end;
  CAd := FCardView.CreateRow;
  with CAd do
  begin
    Properties := Tablo.cxEditRepository1Label1.Properties;
    Options.Editing := false;
    Options.Focusing := false;
    Position.BeginsLayer := true;
  end;
  CTrh := FCardView.CreateRow;
  with CTrh do
  begin
    Properties := Tablo.cxEditRepository1DateItem1.Properties;
    Options.Editing := false;
    Options.Focusing := false;
    Position.BeginsLayer := false
  end;
  CMsg := FCardView.CreateRow;
  with CMsg do
  begin
    Properties := Tablo.cxEditRepository1ButtonItem1.Properties;
    OnGetPropertiesForEdit := MsgOnGetPropertiesForEdit;
  end;
  CRefID := FCardView.CreateRow;
  with CRefID do
  begin
    Visible := false;
  end;
end;

function TChatWindow.FindFileSendById(ARefId: Integer): TFileSendInfo;
var
  item: TFileSendInfo;
begin
  result := nil;
  for item in FFileSends do
  begin
    if item.ReferenceId = ARefId then
      exit(item);
  end;

end;


procedure TChatWindow.MsgStylesOnGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  if VarToStrDef(ARecord.Values[0],'') = KullanAdi then
    AStyle := Tablo.cxStyle6
  else
    AStyle := Tablo.cxStyle4
end;

procedure TChatWindow.MsgOnGetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);

var
  refId: Integer;
  fsi: TFileSendInfo;
begin
  // butonlar ve click evenlerini oluşturalım..
  // dosyayı gönderirken mesaj bizde <Dosya Transferi:C:\dosyayolu\dosyaadı> şeklinde gözükürken alıcıda <Dosya Transferi:dosyaadı> şeklindedir.
  refId := ARecord.Values[3];
  fsi := FindFileSendById(refId);
  AProperties.Buttons.Clear;
  AProperties.OnButtonClick := nil;
  if Assigned(fsi) then
  begin
    if fsi.IsSend then
    begin
      with AProperties.Buttons.Add do
      begin
        Caption := 'x';
        Kind := bkText;
      end;
      if fsi.IsConfirming then
        AProperties.OnButtonClick := GonderenIptalClick
      else
        AProperties.OnButtonClick := GonderenProgressIptalClick;
    end
    else
    begin
      if fsi.IsConfirming then
      begin
        with AProperties.Buttons.Add do
        begin
          Caption := #8730;
          Default := true;
          Kind := bkText;
        end;
        with AProperties.Buttons.Add do
        begin
          Caption := 'x';
          Kind := bkText;
        end;
        AProperties.OnButtonClick := AliciOnayIptalClick;
      end
      else
      begin
        with AProperties.Buttons.Add do
        begin
          Caption := 'x';
          Kind := bkText;
        end;
        AProperties.OnButtonClick := AliciProgressIptalClick;
      end;
    end;
  end;
  AProperties.ReadOnly := true;
end;

procedure TChatWindow.OnFileSendReceiveCompleted(AFSI: TFileSendInfo);
begin
  FFileSends.Remove(AFSI);
  if FFileSends.Count = 0 then
    HomePageInstance.TryCloseMainForm;
end;

procedure TChatWindow.SetUserName(const Value: string);
begin
  FUserName := Value;
  if Assigned(FTabSheet) then
    FTabSheet.Caption := Value;
end;

procedure TChatWindow.EditChatMessage(AUserId:Integer;ARefId:Integer;AMsg:string;EraseRefID:Boolean);
var
  fsi: TFileSendInfo;
begin
  fsi := FindFileSendById(ARefId);
  if Assigned(fsi) then begin
      FCardView.DataController.SetValue(fsi.FRecordIndex,2,AMsg);
      if EraseRefID then
        FCardView.DataController.SetValue(fsi.FRecordIndex,3,0);
  end;
  FCardView.DataController.Post(true);
end;

procedure TChatWindow.WriteToWindow(AUserId: Integer; AAuthor: string; ADateTime: TDateTime; AMsg: string; ARefId: Integer);
var
  fsi: TFileSendInfo;
begin
  FCardView.DataController.Append;
  FCardView.DataController.SetValue(FCardView.DataController.RecordCount - 1, 0, AAuthor);
  FCardView.DataController.SetValue(FCardView.DataController.RecordCount - 1, 1, ADateTime);
  FCardView.DataController.SetValue(FCardView.DataController.RecordCount - 1, 2, AMsg);
  FCardView.DataController.SetValue(FCardView.DataController.RecordCount - 1, 3, ARefId);
  FCardView.DataController.Post(true);
  fsi := FindFileSendById(ARefId);
  if Assigned(fsi) then
    fsi.RecordIndex := FCardView.DataController.FocusedRecordIndex;
end;

procedure TAnaGirisSayfasiFrame.KDRListeCategories0Items0Click(Sender: TObject);
var I:smallint;
    c:TComponent;
    ToplamAktif, ToplamPasif : Currency;
begin
//
   if DateKDRDonemBas.text='' then begin
      DateKDRDonemBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
      DateKDRDonemSon.Date := Tablo.GENINI.BugunTrh;
   end;

   PageControlOrta.ActivePage := SheetKDR;

{   for i := 0 to ComponentCount-1 do
       if Components[i] is TdxTileControlItem then
          TdxTileControlItem(Components[i]).visible := TdxTileControlItem(Components[i]).GroupIndex = 2;
}

   TabKDR.Close;
   TabDokum.Close;
   TabDokum.SQL.Text := 'select * from DOKUMLER where RAPORADI = ''KDR_SONUÇ''  ';
   TabloYenile(TabDokum, []);
   //eğer döküm varsa içeriği listeleyelim
   if TabDokum.recordcount>0 then begin
      ToplamAktif := 0;
      ToplamPasif := 0;
      TabKDR.SQL.Text := TabDokum.FieldByName('SQL').AsString;
      TabloYenile(TabKDR,  [FormatDateTime('yyyy-mm-dd 00:00', DateKDRDonemBas.Date), FormatDateTime('yyyy-mm-dd 23:59', DateKDRDonemSon.Date)]);
      if TabKDR.recordcount>0 then begin
         for I := 0 to TabKDR.FieldCount-1 do begin
           c := FindComponent(TabKDR.Fields[I].FieldName);
           if c <> nil then begin
              if TdxTileControlItem(c).GroupIndex = 0 then
                 ToplamAktif := ToplamAktif+TabKDR.FieldByname(TabKDR.Fields[I].FieldName).AsFloat
              else
                 ToplamPasif := ToplamPasif+TabKDR.FieldByname(TabKDR.Fields[I].FieldName).AsFloat;
              TdxTileControlItem(c).Text4.Value := Format('%m', [TabKDR.FieldByname(TabKDR.Fields[I].FieldName).AsFloat]);
           end;
         end;
         KDR_SONUC.Text4.Value := Format('%m', [ToplamAktif-ToplamPasif]);
         if ToplamAktif-ToplamPasif > 0 then
            KDR_SONUC.style.GradientBeginColor := clGreen
         else
            KDR_SONUC.style.GradientBeginColor := clRed;
      end;
   end;

end;

procedure TAnaGirisSayfasiFrame.KDRListeCategories0Items1Click(Sender: TObject);
begin
   PageControlOrta.ActivePage := SheetNakitAkisi;
   Scheduler.SelectDays([Date - 1, Date, Date + 13], True);
   //
   //bak YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   //bak PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;

   //bak   with FTakvimAksiyonlar do begin
   //bak     DateTakvimBasTar.Date := StartOfTheYear(Tablo.GENINI.BugunTrh-180);
   //bak     DateTakvimBitTar.Date := EndOfTheYear(Tablo.GENINI.BugunTrh+180);
   //bak     DateGrafikBasTar.Date := Tablo.GENINI.BugunTrh;;
   //bak     DateGrafikBitTar.Date := Tablo.GENINI.BugunTrh+365;
     DateTakvimBasTar := StartOfTheYear(Tablo.GENINI.BugunTrh-180);
     DateTakvimBitTar := DateUtils.EndOfTheYear(Tablo.GENINI.BugunTrh+180);
     DateGrafikBasTar := Tablo.GENINI.BugunTrh;;
     DateGrafikBitTar := Tablo.GENINI.BugunTrh+365;

    YenileTusClick(Self);
    SchedulerDateNavigatorSelectionChanged(self,Scheduler.DateNavigator.FirstDate,Scheduler.DateNavigator.LastDate);

   //bak   end;

   PageControl.ActivePageIndex:=0;
   AylikHaftalikGunluk:=3;
   {bak if PageControl.ActivePage=TabSheetTakvim then begin
     TakvimAksiyonlar.DateTakvimBasTar.Visible:=True;
     TakvimAksiyonlar.DateTakvimBitTar.Visible:=True;
     TakvimAksiyonlar.DateGrafikBasTar.Visible:=False;
     TakvimAksiyonlar.DateGrafikBitTar.Visible:=False;
   end else if PageControl.ActivePage=TabSheetGrafik then begin
     TakvimAksiyonlar.DateGrafikBasTar.Visible:=True;
     TakvimAksiyonlar.DateGrafikBitTar.Visible:=True;
     TakvimAksiyonlar.DateTakvimBasTar.Visible:=False;
     TakvimAksiyonlar.DateTakvimBitTar.Visible:=False;
   end;}
   DateTimeListeBitis.Date := Tablo.GENINI.BugunTrh+7;


   AylikTus.Click;//   clSpeedButton1.Click;
end;

procedure TAnaGirisSayfasiFrame.KDRListeCategories0Items2Click(Sender: TObject);
begin
    PageControlOrta.ActivePage := SheetYonetimFinans;
    PanelYoneticiUst.Parent := SheetYonetimFinans;
    ScrollBoxYoneticiSag.Parent := SheetYonetimFinans;
    YoneticiDokumuOlustur('Finans', pageFinans);
    GrafikOlustur(false, pageFinans);
end;

procedure TAnaGirisSayfasiFrame.KDRListeCategories1Items0Click(Sender: TObject);
begin
    PageControlOrta.ActivePage := SheetYonetimCRM;
    PanelYoneticiUst.Parent := SheetYonetimCRM;
    ScrollBoxYoneticiSag.Parent := SheetYonetimCRM;
    YoneticiDokumuOlustur('CRM', PageCRM);
    GrafikOlustur(false, PageCRM);
end;

procedure TAnaGirisSayfasiFrame.KDRListeCategories2Items0Click(Sender: TObject);
begin
    PageControlOrta.ActivePage := SheetYonetimTeklif;
    PanelYoneticiUst.Parent := SheetYonetimTeklif;
    ScrollBoxYoneticiSag.Parent := SheetYonetimTeklif;
    YoneticiDokumuOlustur('Teklif', PageTeklif);
    GrafikOlustur(false, PageTeklif);
end;

procedure TAnaGirisSayfasiFrame.KDRListeCategories3Items0Click(Sender: TObject);
begin
    PageControlOrta.ActivePage := SheetYonetimServis;
    PanelYoneticiUst.Parent := SheetYonetimServis;
    ScrollBoxYoneticiSag.Parent := SheetYonetimServis;
    YoneticiDokumuOlustur('Servis', PageServis);
    GrafikOlustur(false, PageServis);
end;


procedure TAnaGirisSayfasiFrame.KDRListeCategories4Items0Click(Sender: TObject);
begin
   PageControlOrta.ActivePage := SheetStok;
   if CalendarDonemBas.text='' then begin
      CalendarDonemBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
      CalendarDonemSon.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));
   end;
   ButtonDonemStokYenile.click;
end;

procedure TAnaGirisSayfasiFrame.BuguneaksiyonekleMenuClick(Sender: TObject);
var Trh, Tarih : TDateTime;
    Sonuc : Integer;
begin
   Trh := Scheduler.SelStart;
   Tarih :=  StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Trh)+
                  FormatDateTime(' hh:nn:ss', Tablo.GENINI.BugunTrhSaat));
   Sonuc := Tablo.KasaSihirbazBaslat('E', -1,-1, 0, -1,Tarih,Tablo.GENINI.BugunTrhSaat,0,0,'','');
   if Sonuc in [9,19] then
      Tablo.SiparisSihirbazBaslat('E', Sonuc,0, -1, -1)
   else if Sonuc in [10..16] then begin
      if Sonuc=11 then
        Sonuc := 0 //0:belge girişi  1:belge çıkışı
      else
        Sonuc := 1;
      Tablo.FaturaSihirbazBaslat('E', Sonuc,-1, -1,0)
   end else if Sonuc in [20..39] then
     Tablo.MakbuzSihirbazBaslat('E', Sonuc,0, -1, -1, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Trh)+
                    FormatDateTime(' hh:nn:ss', Tablo.GENINI.BugunTrhSaat)), '');
   YenileTusClick(Self);
end;

procedure TAnaGirisSayfasiFrame.ButtonDonemStokYenileClick(Sender: TObject);
var I:smallint;
    c:TComponent;
    STMM, BRUT_KAR_ZARAR : Currency;
begin
   TabKDR.Close;
   TabDokum.Close;
   TabDokum.SQL.Text := 'select * from DOKUMLER where RAPORADI = ''KDR_STOK_SONUÇ''  ';
   TabloYenile(TabDokum, []);
   //eğer döküm varsa içeriği listeleyelim
   if TabDokum.recordcount>0 then begin
      TabKDR.SQL.Text := TabDokum.FieldByName('SQL').AsString;
      TabloYenile(TabKDR, [FormatDateTime('yyyy-mm-dd 00:00', CalendarDonemBas.Date), FormatDateTime('yyyy-mm-dd 23:59', CalendarDonemSon.Date)]);

      if TabKDR.recordcount>0 then begin
         for I := 0 to TabKDR.FieldCount-1 do begin
           c := FindComponent(TabKDR.Fields[I].FieldName);
           if c <> nil then
              TdxTileControlItem(c).Text4.Value := Format('%m', [TabKDR.FieldByname(TabKDR.Fields[I].FieldName).AsFloat]);
         end;
       end;
       ///// toplamlar
         STMM := TabKDR.FieldByname('KDR_DONEM_BASI').AsFloat + TabKDR.FieldByname('KDR_ALIS_FATURA_TUTAR').AsFloat - TabKDR.FieldByname('KDR_DONEM_SONU').AsFloat;
         BRUT_KAR_ZARAR := TabKDR.FieldByname('KDR_SATIS_FATURA_TUTAR').AsFloat-STMM;
         KDR_STMM.Text4.Value := Format('%m', [STMM]);
         KDR_BRUT_KAR_ZARAR.Text4.Value := Format('%m', [BRUT_KAR_ZARAR]);

         if BRUT_KAR_ZARAR > 0 then
            KDR_BRUT_KAR_ZARAR.style.GradientBeginColor := clGreen
         else
            KDR_BRUT_KAR_ZARAR.style.GradientBeginColor := clRed;
   end;

end;

procedure TAnaGirisSayfasiFrame.PageControlChange(Sender: TObject);
var s:string;
begin
   if PageControl.ActivePage=TabSheetTakvim then begin
{bak    TakvimAksiyonlar.DateTakvimBasTar.Visible:=True;
    TakvimAksiyonlar.DateTakvimBitTar.Visible:=True;
    TakvimAksiyonlar.DateGrafikBasTar.Visible:=False;
    TakvimAksiyonlar.DateGrafikBitTar.Visible:=False;}
    ZamanSecildi;
    YenileTusClick(Sender);
  end else if PageControl.ActivePage=TabSheetPivot then begin
    if LabelBittar.Tag=0 then begin
       LabelBittar.Date:=Tablo.GENINI.BugunTrh+30;
       LabelBittar.Tag:=1;
    end;
    //AylikTusClick(self);
    ZamanSecildi;
  end else if PageControl.ActivePage=TabSheetGrafik then begin
{bak    TakvimAksiyonlar.DateGrafikBasTar.Visible:=True;
    TakvimAksiyonlar.DateGrafikBitTar.Visible:=True;
    TakvimAksiyonlar.DateTakvimBasTar.Visible:=False;
    TakvimAksiyonlar.DateTakvimBitTar.Visible:=False; }
    Grafiklendir;
  end else if PageControl.ActivePage=TabSheetListe then begin
    s:=' and ';
    if (CheckTahsilat.Checked)and(CheckOdeme.Checked) then s:=s+' (TUR=61 or TUR=71) '
    else if CheckTahsilat.Checked then s:=s+' (TUR=61) '
    else if CheckOdeme.Checked then s:=s+' (TUR=71) '
    else s:=s+' TUR=9999 ';  // hiç işaretlenmediyse
    TabListe.SQL.Text := SQLListe.Text + ' PLANTARIHI <= '''+FormatDateTime('yyyy-MM-dd 23:59', DateTimeListeBitis.Date)+''' '+s+' order by 2 ';
    TabloYenile( TabListe, []);
  end;
end;

procedure TAnaGirisSayfasiFrame.Grafiklendir;
var
  OlusanSQL: string;
begin
 OlusanSQL:='';
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[0]=cbsChecked then begin  //Odeme Planı
           OlusanSQL:= ' Union All '+SqlGrafikOdemePlan.Lines.Text;
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[0]=cbsChecked then begin  //Tahsilat Planı
           OlusanSQL:= OlusanSQL +' Union All '+SqlGrafikTahsilatPlan.Lines.Text;
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[1]=cbsChecked then begin  //KK
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikKK.Lines.Text;
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[1]=cbsChecked then begin  //POS
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikPOS.Lines.Text;
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[2]=cbsChecked then begin  //Çek
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikCekKendi.Lines.Text;
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[2]=cbsChecked then begin  //Çek
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikCekMusteri.Lines.Text;
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[3]=cbsChecked then begin  //Senet
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikSenetKendi.Lines.Text;
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[3]=cbsChecked then begin  //Senet
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikSenetMusteri.Lines.Text;
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[5]=cbsChecked then begin  //Kredi
            OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikKredi.Lines.Text;
 //bak        if FTakvimAksiyonlar.GelirFiltreCheck.States[4]=cbsChecked then begin  //Gelir
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikGelir.Lines.Text;
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[4]=cbsChecked then begin  //Gider
            OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikGider.Lines.Text;
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[6]=cbsChecked then begin  //Maaş
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikMaas.Lines.Text;
  TabGrafik.Close;
  TabGrafik.SQL.Text:=StringReplace(SqlMemoGrafik.Lines.Text,'_SQLMEMO_',OlusanSQL,[rfReplaceAll]);
    case AylikHaftalikGunluk  of
       0:begin
         TabGrafik.SQL.Add('select * from GRAFIKPLAN_SPID ORDER by TARIH');
       end;
       2:begin
         TabGrafik.SQL.Add('Select * from GRAFIKPLAN_SPID Where datename(dw,TARIH)=''Sunday'' order by TARIH  ');//Pazar günlerini listelele
       end;
       -1,3:begin
         TabGrafik.SQL.Add('select GUN,AY,BAKIYE,TARIH,'+DbConv(DbTarihEkle('dd','-(DAY('+DbTarihEkle('mm','1','TARIH')+'))',DbTarihEkle('mm','1','TARIH')),'VARCHAR(10)',112)+'  from GRAFIKPLAN_SPID'+
         ' Where TARIH='+DbConv(DbTarihEkle('dd','-(DAY('+DbTarihEkle('mm','1','TARIH')+'))',DbTarihEkle('mm','1','TARIH')),'VARCHAR(10)',112)+' and TARIH >='''+FormatDateTime('yyyy-mm-dd 00:00',DateGrafikBasTar)+'''  and TARIH <= '''+FormatDateTime('yyyy-mm-dd 23:59',DateGrafikBitTar)+''' '+
         ' Order by TARIH');
       end;
    end;
  TabGrafik.Params[0].Value:=DateGrafikBasTar;
  TabGrafik.Params[1].Value:=DateGrafikBitTar;
  TabloYenile( TabGrafik, []);
end;

procedure TAnaGirisSayfasiFrame.DateTimeListeBitisChange(Sender: TObject);
begin
   if PageControl.ActivePage=TabSheetListe then
      PageControlChange(Self);
end;

procedure TAnaGirisSayfasiFrame.GridKDRViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridKDR;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridKDRView;
  AnaForm.pmGridStil.Tags.Values[GridKDR.Name]:='KararDestekRaporlariGridi';
end;

procedure TAnaGirisSayfasiFrame.ExcelPivot1Click(Sender: TObject);
begin
  Tablo.SaveDialog1.FileName := 'Nakit Akış Pivot-'+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)+'.xlsx';
  if Tablo.SaveDialog1.Execute then begin
    if ExportToExcelPivot(Tablo.SaveDialog1.FileName,FGrid,FGridTableView,pivot) then
      ShellExecute(0,'open',PWideChar(Tablo.SaveDialog1.FileName),nil,nil,SW_SHOW);
  end;
end;

function TAnaGirisSayfasiFrame.DetayliBilgiGetir(Tur, Id : Integer; var RehberID: Integer; var Tutar:Currency) : Boolean;
begin
   Tablo.Query1.Close;
   case TUR of
     61 : Tablo.Query1.SQL.Text := 'select REHBERID,BORC  from KASA ';
     71 : Tablo.Query1.SQL.Text := 'select REHBERID,ALACAK  from KASA ';
     11, 15 : Tablo.Query1.SQL.Text := 'select REHBERID,FATURA_TUTARI  from FATBASLIK ';
   end;
   Tablo.Query1.SQL.Add(' where ID = ' + IntToStr(Id));
   Tablo.Query1.open;
   RehberID := Tablo.Query1.Fields[0].AsInteger;
   Tutar := Tablo.Query1.Fields[1].AsCurrency;

end;

procedure TAnaGirisSayfasiFrame.Gizle1Click(Sender: TObject);
var
   selectedEvent : TcxSchedulerControlEvent;
begin
  selectedEvent := Scheduler.SelectedEvents[0];
  Tablo.Query1.close;
  Tablo.Query1.SQL.Text:=' Update BUTCE SET GOR=0 where ID='+inttostr(selectedEvent.GetCustomFieldValueByName('ID2'));
  Tablo.Query1.ExecSQL;
  YenileTusClick(Self);
end;


procedure TAnaGirisSayfasiFrame.LabelBittarChange(Sender: TObject);
begin
   ZamanSecildi;
end;

procedure TAnaGirisSayfasiFrame.MenuListeDuzenleClick(Sender: TObject);
begin
   AnaForm.GormeDialogCagir(TabListe.Fields[0].AsInteger, TabListe.FieldByName('TUR').AsInteger, TabListe.FieldByName('REHBERID').AsInteger, 0,TabListe.FieldByName('PLANTARIHI').AsDateTime, '0');
   TabloYenile(TabListe, [FormatDateTime('yyyy-MM-dd 23:59', DateTimeListeBitis.Date)]);
end;

procedure TAnaGirisSayfasiFrame.TakvimSil(Tur,ID:Integer);
var   Trh : TDateTime;
begin
      if Tur in [21..39] then begin
        Tablo.Query1.Close;
        if Tur in [23,33] then
           Tablo.Query1.SQL.Text := 'select TARIH from CEKLER where ID='+IntToStr(ID)
        else if Tur in [24,34] then
           Tablo.Query1.SQL.Text := 'select TARIH from SENETLER where ID='+IntToStr(ID)
        else
           Tablo.Query1.SQL.Text := 'select ISLEMTARIHI from KASA where ID='+IntToStr(ID);
        Tablo.Query1.Open;
        Trh := Tablo.Query1.Fields[0].AsDateTime;
      end
      else
        Trh := Scheduler.SelStart;

     case Tur of
       10,11,12,13,14,15,16,17,21,22,23,24,25,31,32,33,34,35:begin
           if Tur in [11,15] then begin
           if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+IntToStr(ID)+' ',[],[]) then begin
             if  Application.MessageBox(PCHAR(TFaturaPlanliSilinsinmi),PChar(Uyari),MB_YESNO)=mrNo then begin
               Abort;
             end;
           end;
         end;
       end;
     end;
     Tablo.KasaSilmeIslemleri(ID, Tur);
end;

procedure TAnaGirisSayfasiFrame.MenuListeSilClick(Sender: TObject);
begin
   if Application.MessageBox(PCHAR(TAksiyonsil), PCHAR(Onay), MB_YESNO) = IDYES then begin
      TakvimSil(TabListe.FieldByName('TUR').AsInteger,TabListe.Fields[0].AsInteger);
      //TabloYenile(TabListe, [FormatDateTime('yyyy-MM-dd 23:59', DateTimeListeBitis.Date)]);
      PageControlChange(Self);
   end;
end;

procedure TAnaGirisSayfasiFrame.SchedulerDateNavigatorSelectionChanged(Sender: TObject; const AStart, AFinish: TDateTime);
begin
   if TabTakvim.Active then begin
     TabToplam.Close;
     TabToplam.SQL.Text := StringReplace(TabToplam.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
//     TabToplam.Params[0].value := FormatDateTime('yyyy-mm-dd 00:00', AStart);
//     TabToplam.Params[1].value := FormatDateTime('yyyy-mm-dd 00:00', AFinish);
//     TabToplam.Open;
     TabloYenile(TabToplam,[FormatDateTime('yyyy-mm-dd 00:00', AStart), FormatDateTime('yyyy-mm-dd 00:00', AFinish)]);
   end;
end;

procedure TAnaGirisSayfasiFrame.SchedulerDblClick(Sender: TObject);
begin
   if Scheduler.CurrentView.HitTest.Event <> nil then
      BilgileriDegisMenu.Click
end;

type hh = class(TcxCustomSchedulerStorage)

end;

procedure TAnaGirisSayfasiFrame.TusBasildi(Tus : TToolButton);
var i : SmallInt;
begin
   for i := 0 to ComponentCount - 1 do
       if Components[i] is TToolButton then begin
          if TToolButton(Components[i]) = Tus then
             TToolButton(Components[i]).Down := True
          else
             TToolButton(Components[i]).Down := False;
       end;
end;

procedure TAnaGirisSayfasiFrame.AylikTusClick(Sender: TObject);
begin
   AylikHaftalikGunluk := TMenuItem(Sender).Tag;
   TusBasildi(TToolButton(Sender));
   ZamanSecildi;
end;

procedure TAnaGirisSayfasiFrame.ZamanSecildi;
begin
//  if not Scheduler.ViewWeek.Active then
//    AnchorDate := Scheduler.SelectedDays[0];
//  Scheduler.SelectDays([AnchorDate], TMenuItem(Sender).Tag in [0, 1]);
if PageControl.ActivePage=TabSheetTakvim then begin
  //Takvim
  case AylikHaftalikGunluk of
    0: Scheduler.ViewDay.Active := True;
    1: Scheduler.SelectWorkDays(Date);
    2: Scheduler.ViewWeek.Active := True;
    3: Scheduler.GoToDate(Scheduler.SelectedDays[0], vmMonth);
    4: Scheduler.ViewTimeGrid.Active := True;
    5: Scheduler.ViewYear.Active := True;
  end;
end else if PageControl.ActivePage=TabSheetPivot then begin
    //Pivot
    TabPivot.Close;
    case AylikHaftalikGunluk  of
      0:begin
          LabelBittar.Date := Tablo.Genini.buguntrh + 30;
          TabPivot.SQL.Text := 'select * from [dbo].[fn_NakitAkisiPivot](:PSonTarih)'; //günlük
        end;
      2:begin
          LabelBittar.Date := Tablo.Genini.buguntrh + 90;
          TabPivot.SQL.Text := 'select * from [dbo].[fn_NakitAkisiPivot_Haftalik](:PSonTarih)'; //hafta
        end;
      3:begin
          LabelBittar.Date := Tablo.Genini.buguntrh + 365;
          TabPivot.SQL.Text := 'select * from [dbo].[fn_NakitAkisiPivot_Aylik](:PSonTarih)'; //ay
        end;
    end;
    TabloYenile(TabPivot,[LabelBittar.Date]);
end else begin
  //Grafik
    if TabGrafik.Active then
       TabGrafik.Close;
    DateGrafikBasTar := Tablo.GENINI.BugunTrh;;
    case AylikHaftalikGunluk  of
       0:begin
           DateGrafikBitTar := Tablo.GENINI.BugunTrh+30;
           TabGrafik.SQL.Text:='select * from GRAFIKPLAN_SPID Where ';
         end;
       2:begin
           DateGrafikBitTar := Tablo.GENINI.BugunTrh+90;
           TabGrafik.SQL.Text:='Select * from GRAFIKPLAN_SPID Where datename(dw,TARIH)=''Sunday'' and ';//Pazar günlerini listelele
         end;
       3:begin
           DateGrafikBitTar := Tablo.GENINI.BugunTrh+365;
           TabGrafik.SQL.Text:=' select GUN,AY,BAKIYE,TARIH,'+DbConv(DbTarihEkle('dd','-(DAY('+DbTarihEkle('mm','1','TARIH')+'))',DbTarihEkle('mm','1','TARIH')),'VARCHAR(10)',112)+'  from GRAFIKPLAN_SPID where '+
                               ' TARIH='+DbConv(DbTarihEkle('dd','-(DAY('+DbTarihEkle('mm','1','TARIH')+'))',DbTarihEkle('mm','1','TARIH')),'VARCHAR(10)',112)+' and ';
         end;
    end;
    TabGrafik.SQL.Add( '  TARIH >='''+FormatDateTime('yyyy-mm-dd 00:00',DateGrafikBasTar)+'''  and TARIH <= '''+
                        FormatDateTime('yyyy-mm-dd 00:00',DateGrafikBitTar)+'''  Order by TARIH');
    TabloYenile(TabGrafik,[]);
    GridGrafikDBChartView.DiagramColumn.AxisValue.GridLines := true; // grid çizgileri
    GridGrafikDBChartView.DiagramColumn.AxisValue.TickMarkLabels := true; // Altta ayları gösterir
    GridGrafikDBChartView.DiagramColumn.Values.CaptionPosition := cdvcpOutsideEnd; // üstte değerlerinin görünmesini sağlar
  end;
end;

procedure TAnaGirisSayfasiFrame.TabloAc(var Tablo1 : TFDQuery; BasTarih, BitTarih : TDateTime);
var s, tarih,Tbas,Tbit : String;
  I,J: Integer;
  procedure             Ekle(Komut : String);
  begin
     if I>J then begin
        J:=I;
        Tablo1.SQL.Add(' Union All ');
     end;
     Tablo1.SQL.Text := Tablo1.SQL.Text + Komut;
     inc(I);
  end;
begin
//bak   FTakvimAksiyonlar.GiderFiltreCheck.Visible := FTakvimAksiyonlar.CheckGroupSecim.ItemIndex = 0;
   Tablo1.Close;
   Tablo1.SQL.Text := MemoBaslangic.Text;
   I:=0;
   J:=0;
//bak   case FTakvimAksiyonlar.CheckGroupSecim.itemindex of
//bak     0:begin//Tablo1.SQL.Text:= Tablo1.SQL.Text+MemoPlan.Lines.Text);
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[0]=cbsChecked then   //Odeme Plan Kasa
            Ekle(MemoTakvimOdemePlan.Lines.Text);
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[0]=cbsChecked then //Tahsilat Plan Kasa
            Ekle(MemoTakvimTahsilatPlan.Lines.Text);
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[1]=cbsChecked then //KK
            Ekle(MemoTakvimPlanKK.Lines.Text);
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[2]=cbsChecked then //Çekimiz
            Ekle(MemoTakvimCekKendi.Lines.Text);
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[2]=cbsChecked then //Müşteri Çek
            Ekle(MemoTakvimCekMusteri.Lines.Text);
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[3]=cbsChecked then //Senetimiz
            Ekle(MemoTakvimSenetKendi.Lines.Text);
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[3]=cbsChecked then //Müşteri Senet
            Ekle(MemoTakvimSenetMusteri.Lines.Text);
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[6]=cbsChecked then //Maaş
            Ekle(MemoPlanMaas.Lines.Text);
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[5]=cbsChecked then //Kredi
            Ekle(MemoPlanKredi.Lines.Text);
//bak         if FTakvimAksiyonlar.GiderFiltreCheck.States[4]=cbsChecked then //Gider Bütçe
            Ekle(MemoTakvimGider.Lines.Text);
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[4]=cbsChecked then //Gelir Bütçe
            Ekle(MemoTakvimGelir.Lines.Text);
//bak         if FTakvimAksiyonlar.GelirFiltreCheck.States[1]=cbsChecked then //POS
            Ekle(MemoTakvimPOS.Lines.Text);
//bak       end;
//bak     1: Tablo1.SQL.Text:= Tablo1.SQL.Text+MemoFatura.Lines.Text;
//bak     2: Tablo1.SQL.Text:= Tablo1.SQL.Text+MemoOdeme.Lines.Text;
             Tablo1.SQL.Text:= Tablo1.SQL.Text+MemoOdeme.Lines.Text;
//bak   end;
   if Tablo1.Name = 'TAKVIM' then
      Tablo1.SQL.add(' ORDER BY YON DESC, 2 ASC')
   else
      Tablo1.SQL.add(' ORDER BY 2 ');
   Tbas:=FormatDateTime('yyyy-MM-dd', BasTarih);
   Tbit:=FormatDateTime('yyyy-MM-dd', BitTarih);
   Tablo1.SQL.add(' select * from ##TAKVIM_SPID_');
   Tablo1.SQL.Text := StringReplace(Tablo1.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
   Tablo1.SQL.Text := StringReplace(Tablo1.SQL.Text, '2020-01-01', Tbit, [RFrEPLACEaLL]) ;
   Tablo1.SQL.Text := StringReplace(Tablo1.SQL.Text, '2010-01-01', Tbas, [RFrEPLACEaLL]) ;
   Tablo1.Open;
   TabToplam.Close;
   TabToplam.SQL.Text := StringReplace(TabToplam.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
//   TabToplam.Params[0].value := FormatDateTime('yyyy-MM-dd 00:00', BasTarih);
//   TabToplam.Params[1].value := FormatDateTime('yyyy-MM-dd 00:00', BitTarih);
//   TabToplam.Open;
   TabloYenile(TabToplam,[FormatDateTime('yyyy-MM-dd 00:00', BasTarih),FormatDateTime('yyyy-MM-dd 00:00', BitTarih)]);

end;

procedure TAnaGirisSayfasiFrame.ToolButton1Click(Sender: TObject);
begin
   PageControlChange(Self);
end;

procedure TAnaGirisSayfasiFrame.YenileTusClick(Sender: TObject);
begin
   if PageControl.ActivePage=TabSheetTakvim then
      TabloAc(TabTakvim, DateTakvimBasTar, DateTakvimBitTar)
   else begin
//bak     if TakvimAksiyonlar.CheckGroupSecim.ItemIndex = 0 then
      Grafiklendir;
   end;
end;

procedure TAnaGirisSayfasiFrame.GridListeViewCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridListe;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridListeView;
  //AnaForm.pmGridStil.Tags.Values[GridListe.Name] := 'TakvimListeGridi';
end;


procedure TAnaGirisSayfasiFrame.GridStokViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridStok;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridStokView;
  AnaForm.pmGridStil.Tags.Values[GridStok.Name]:='KararDestekStokGridi';
end;

initialization

RegisterClass(TAnaGirisSayfasiFrame);

finalization

end.

















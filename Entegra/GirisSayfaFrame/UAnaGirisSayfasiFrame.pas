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
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    JvTimer1: TJvTimer;
    SheetDuyurular: TcxTabSheet;
    Panel2: TPanel;
    Label2: TLabel;
    EditDuyuruArama: TcxTextEdit;
    DuyuruYenileTus: TcxButton;
    lblDuyuruSkin: TcxLabel;
    ComboDuyuruSkin: TcxImageComboBox;
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
    procedure ChatTimerTimer(Sender: TObject);
    procedure pageFinansChange(Sender: TObject);
    procedure KonusmaGecmisiMenuClick(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure btnAramaClick(Sender: TObject);
    procedure JvDesktopAlert1MessageClick(Sender: TObject);
    procedure ehirDeitir1Click(Sender: TObject);
    procedure pnlImagePaint(Sender: TObject);
    procedure Yenile1Click(Sender: TObject);
    procedure cxGridDBTableView1OKUNMAMISYORUMSAYStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
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
    procedure ComboDuyuruSkinPropertiesEditValueChanged(Sender: TObject);
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
    FOnlineUsers: TStringList;
    FSkinSecimiYukleniyor: Boolean;
    procedure SkinSeciminiYukle;
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
    procedure YoneticiDokumuOlustur(Modul: string; APageControl: TcxPageControl);
    function FindDownedButton: TJvNavPanelButton;
    function DevamedenServisDuzenle: integer;
    procedure JvDesktopAlert2MessageClick(Sender: TObject);
    procedure MesajaGit(MesajSayfasi: Integer);
    procedure ZamanSecildi;
    procedure Grafiklendir;
    function  DetayliBilgiGetir(Tur, Id : Integer; var RehberID: Integer; var Tutar:Currency) : Boolean;
    procedure TusBasildi(Tus : TToolButton);
    procedure TabloAc(var Tablo1 : TFDQuery; BasTarih, BitTarih : TDateTime);
    procedure YenileTusClick(Sender: TObject);
    procedure TakvimSil(Tur,ID:Integer);
    procedure KDR_LISTELE(RaporAd:String; Tablo1:TFDQuery; GridView: tcxGridDBTableView; TopKolonu:smallint);

  public
    UyariTabloAdi: string;
    Btn  : TButtonItem;
    Alarmlar: array of TJvDesktopAlert;
    FMainFormClosing: Boolean;
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
//    property HavaDurumuImage: Integer read FHavaDurumuImage write SetHavaDurumuImage;
    function OkunmamisDuyuruSayisiDuzenle: integer;

  end;

  PRSSFeedData = ^TRSSFeedData;

  TRSSFeedData  = record
    Sehir: string;
    Tarih: string;
    Tahmin: string;
    Derece: string;
  end;


var
  HomePageInstance : TAnaGirisSayfasiFrame = nil;

implementation

uses
  System.StrUtils,   // IfThen (string) - eksik kosul uyari metnini kurarken
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


//  if not Tablo.YetkiVarmi(2111, YetkiTur_Degistirme, false) then // proje değiştirme yetkisi
//     tvProjeler.OnDblClick := Nil;

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
     Tablo.TablodanSorguAc(1,DbExec('sp_Prg_Sayi_BanaIsListesi',Kullanan+',0,9999'));
     if Tablo.Query1.Fields[0].AsInteger>0 then
        btnGorev.Caption := AGS_Gorevler+' ('+Tablo.Query1.Fields[0].AsString+')'
     else
        btnGorev.Caption := AGS_Gorevler;
  end;
  OkunmamisDuyuruSayisiDuzenle;

  DevamedenServisDuzenle;
  lblKullanici.Caption := KullanAdi;
  if BtnDuyuru.visible then
     BtnDuyuru.Click;
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
    // Eski sohbet sekmesi (SheetMesajlasma) kaldirildi -> yeni mesajlasma ekrani
    if Assigned(AnaForm) then AnaForm.MesajMenuClick(nil);
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

procedure TAnaGirisSayfasiFrame.CheckPasifPropertiesEditValueChanged(Sender: TObject);
begin
  OlayListele;
end;

procedure TAnaGirisSayfasiFrame.KonusmaGecmisiMenuClick(Sender: TObject);
begin
  if Assigned(AnaForm) then AnaForm.MesajMenuClick(nil);
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

procedure TAnaGirisSayfasiFrame.ChatTimerTimer(Sender: TObject);
// ESKI TCP dinleyicisi. Mesajlasma DB uzerinden yurudugu icin (UMesajlasma kendi
//   3 sn'lik yoklamasini yapar, rozeti AnaForm tazeler) burasi is yapmaz.
begin
  if Assigned(ChatTimer) then ChatTimer.Enabled := False;
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
  BosKosul: string;   // degeri girilmemis kosullarin adlari (bkz. asagidaki koruma)
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
  BosKosul := '';
  TabKosul.First;
  while not TabKosul.eof do begin
    inc(i);
    if TabKosul.FieldByName('ICERIKTURU').AsInteger = 5 then // date
       s := FormatDateTime('mm' + FormatSettings.DateSeparator + 'dd' + FormatSettings.DateSeparator + 'yyyy', StrToDateDef(TabKosul.FieldByName('DEGER').AsString,
              Tablo.GENINI.BugunTrh)) // date
    else
       s := TabKosul.FieldByName('DEGER').AsString;

    // KOSUL DEGERI BOS ise SQL'e bos string gider ve sorgu BOZULUR:
    //   '$yil$' -> ''  =>  "where year(TARIH)=  and month(TARIH)= ..."
    //   -> "Incorrect syntax near the keyword 'and'". Once tespit et, asagida uyar.
    if Trim(s) = '' then
      BosKosul := BosKosul + IfThen(BosKosul = '', '', ', ') +
                  IfThen(Trim(TabKosul.FieldByName('ACIKLAMA').AsString) <> '',
                         TabKosul.FieldByName('ACIKLAMA').AsString,
                         TabKosul.FieldByName('KOD_ADI').AsString);

    Tablo1.SQL.text := StringReplace(Tablo1.SQL.text, '$' + TabKosul.FieldByName('KOD_ADI').AsString + '$', s, [rfReplaceAll]);
    Ustyazi := StringReplace(Ustyazi, '$' + TabKosul.FieldByName('KOD_ADI').AsString + '$', s, [rfReplaceAll]);
    Altyazi := StringReplace(Altyazi, '$' + TabKosul.FieldByName('KOD_ADI').AsString + '$', s, [rfReplaceAll]);
    TabKosul.Next;
  end;

  // Eksik kosulla sorgu ACILMAZ: kullaniciya ne girmesi gerektigi soylenir. Aksi halde
  //   bozuk SQL sunucuya gidip anlasilmaz bir sozdizimi hatasi doner.
  if BosKosul <> '' then
  begin
    Application.MessageBox(
      PChar('Bu rapor icin once kosul degeri girilmeli.' + sLineBreak + sLineBreak +
            'Bos kosul(lar): ' + BosKosul + sLineBreak + sLineBreak +
            'Sag ustteki kosul alanlarindan deger secip yenileyin.'),
      PChar('Eksik Kosul'), MB_OK or MB_ICONINFORMATION);
    Tablo1.Free;
    Datasource1.Free;
    Exit;
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
  if Assigned(AnaForm) then AnaForm.MesajMenuClick(nil);
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
// Eski TCP dosya aktarimi zamanlayicisiydi (HandleFileSends kaldirildi).
begin
  JvTimer1.Enabled := False;
end;

procedure TAnaGirisSayfasiFrame.MesajaGit(MesajSayfasi: Integer);
// Eski sohbet sekmelerine gidiyordu; artik yeni mesajlasma ekranini acar.
begin
  if Assigned(AnaForm) then AnaForm.MesajMenuClick(nil);
end;
constructor TAnaGirisSayfasiFrame.Create(AOwner: TComponent);
var
  KulID: Integer;
begin
  inherited;
  SkinSeciminiYukle;
  KulID := StrToIntDef(Kullanan, 1);
  TabSK.Close;
  TabSK.SQL.Text :=
    ' select ' + DbUst(10) + ' M.MODULID, M.MODULADI from KULLANICI_ISLEM K ' +
    ' inner join MODUL M on K.ISLEMID=M.MODULID ' +
    ' where KULID=' + IntToStr(KulID) + ' order by SAY desc ' + DbSinir(10);
  TabSK.Open;
  // FChatWindows kaldirildi (eski TCP sohbet listesi)
  FOnlineUsers := TStringList.Create;
  FOnlineUsers.NameValueSeparator := ' ';
  FOnlineUsers.LineBreak := ',';
end;

procedure TAnaGirisSayfasiFrame.SkinSeciminiYukle;
var
  LQuery: TFDQuery;
begin
  FSkinSecimiYukleniyor := True;
  LQuery := TFDQuery.Create(nil);
  try
    ComboDuyuruSkin.Enabled := True;
    ComboDuyuruSkin.EditValue := 'DEFAULT';
    try
      LQuery.Connection := Tablo.FDCnn;
      LQuery.SQL.Text := 'select SKINADI from KULLANICI where ID=:ID';
      LQuery.ParamByName('ID').AsInteger := KullaniciID;
      LQuery.Open;
      if not LQuery.IsEmpty and not LQuery.FieldByName('SKINADI').IsNull and
         (Trim(LQuery.FieldByName('SKINADI').AsString) <> '') then
        ComboDuyuruSkin.EditValue := LQuery.FieldByName('SKINADI').AsString;
    except
      // Eski veritabaninda SKINADI yoksa ana sayfa calismaya devam etsin.
      ComboDuyuruSkin.Enabled := False;
    end;
  finally
    LQuery.Free;
    FSkinSecimiYukleniyor := False;
  end;
end;

procedure TAnaGirisSayfasiFrame.ComboDuyuruSkinPropertiesEditValueChanged(
  Sender: TObject);
var
  LSkin: string;
  LDeger: Variant;
begin
  if FSkinSecimiYukleniyor or not ComboDuyuruSkin.Enabled or
     (KullaniciID <= 0) then Exit;

  LSkin := Trim(VarToStr(ComboDuyuruSkin.EditValue));
  if LSkin = '' then LSkin := 'DEFAULT';
  if SameText(LSkin, 'DEFAULT') then
    LDeger := Null
  else
    LDeger := LSkin;

  try
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'update KULLANICI set SKINADI=&SKINADI where ID=&ID',
      ['&SKINADI', '&ID'], [LDeger, KullaniciID]);
  except
    SkinSeciminiYukle;
    raise;
  end;
  Tablo.KullaniciSkinUygula(LSkin);
end;

destructor TAnaGirisSayfasiFrame.Destroy;
begin
  FOnlineUsers.Free;
  inherited;
end;

procedure TAnaGirisSayfasiFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TAnaGirisSayfasiFrame.KosullarMenuClick(Sender: TObject);
begin
  ScrollBoxYoneticiSag.Visible := true;
  KosulButon.Visible := false;
end;


procedure TAnaGirisSayfasiFrame.SatirEkleClick(Sender: TObject);
begin
  // DuyuruAlarmiVer kaldirildi: govdesi zaten tamamen yorumdaydi (eski TCP
  //   "DYR" bildirimi). Duyuru ekrani acilmaya devam ediyor.
  Tablo.DuyuruAc('E', 0, 0);
end;

procedure TAnaGirisSayfasiFrame.DuyuruYenileTusClick(Sender: TObject);
begin
   if AktifVeriMotor = vmPG then begin
      // Duyuru sorgusu agir T-SQL script (declare @var/set/fn_prg_IsListesiBanaAtananlar TVF/
      //   convert/OLAYZAMANI-@Bugun). PG'ye tam portu ayri is -> pilotta duyuru paneli atlanir.
     TabDuyuruListe.Close;
     Exit;
   end;
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
   // RaporAd = TIKLANAN TILE'in BILESEN adidir ve zorunlu olarak ASCII'dir (Delphi bilesen
   //   adi Turkce harf iceremez): KDR_BORCLULAR, KDR_ALINAN_CEK, KDR_KREDILER...
   //   DOKUMLER.RAPORADI da artik ASCII'dir (kdr_rapor_adlari_ascii.sql); ancak guncellemeyi
   //   almamis kurulumda hala Turkce olabilir (KDR_BORÇLULAR...). Duz '=' o durumda eslesmez
   //   ve grid BOS kalirdi. AKSAN-DUYARSIZ (CI_AI) collation Ç=C, İ=I kabul eder -> her iki
   //   yazim da bulunur; boylece DB guncellemesi sirasi onemsiz hale gelir.
   if AktifVeriMotor = vmPG then
     TabDokum.SQL.Text := 'select * from DOKUMLER where RAPORADI = ''' + RaporAd + ''' '
   else
     TabDokum.SQL.Text := 'select * from DOKUMLER' +
                          ' where RAPORADI COLLATE Latin1_General_CI_AI = ''' + RaporAd +
                          ''' COLLATE Latin1_General_CI_AI ';
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
   // Rapor adlari ASCII'dir (kdr_rapor_adlari_ascii.sql ile cevrildi); ancak guncellemeyi
   //   almamis kurulumda ad hala Turkce olabilir -> AKSAN-DUYARSIZ (CI_AI) karsilastirma
   //   iki yazimi da bulur (Ç=C, İ=I).
   if AktifVeriMotor = vmPG then
     TabDokum.SQL.Text := 'select * from DOKUMLER where RAPORADI = ''KDR_SONUC''  '
   else
     TabDokum.SQL.Text := 'select * from DOKUMLER' +
                          ' where RAPORADI COLLATE Latin1_General_CI_AI = ''KDR_SONUC'' COLLATE Latin1_General_CI_AI ';
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
   // Rapor adlari ASCII'dir (kdr_rapor_adlari_ascii.sql ile cevrildi); ancak guncellemeyi
   //   almamis kurulumda ad hala Turkce olabilir -> AKSAN-DUYARSIZ (CI_AI) karsilastirma
   //   iki yazimi da bulur (Ç=C, İ=I).
   if AktifVeriMotor = vmPG then
     TabDokum.SQL.Text := 'select * from DOKUMLER where RAPORADI = ''KDR_STOK_SONUC''  '
   else
     TabDokum.SQL.Text := 'select * from DOKUMLER' +
                          ' where RAPORADI COLLATE Latin1_General_CI_AI = ''KDR_STOK_SONUC'' COLLATE Latin1_General_CI_AI ';
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
















unit UItsBildirim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, dxSkinsCore, dxSkinscxPCPainter, cxPC,
   cxControls, cxContainer, cxEdit, cxLabel, cxTextEdit, cxMaskEdit,
   cxDropDownEdit, cxCalendar, cxStyles, cxCustomData, cxGraphics,
   cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses,
   cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
   cxGrid, ADODB, cxCheckBox , XSBuiltIns ,UitsBusiness,UBekletme,PrjConst, JvPageList,
   JvNavigationPane, JvExControls, JvComponentBase, JvButton,
//A   dxSkinsdxNavBar2Painter,
    dxNavBarCollns, dxNavBarBase, dxNavBar,  InvokeRegistry,
    Rio, SOAPHTTPClient, SOAPHTTPTrans,Generics.Collections, ComCtrls, ToolWin,
    Menus, cxLookAndFeelPainters, cxButtons,WinInet, dxSkinLondonLiquidSky,
    cxGridDBDataDefinitions, SOAPDomConv, OPToSOAPDomConv, ShellApi,  DSCommonServer, DSHTTPCommon,
        DSHTTPWebBroker, cxImageComboBox, cxCurrencyEdit, CategoryButtons,
  cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin,
dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver,
   dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, dxBarBuiltInMenu, cxNavigator, dxSkinsdxNavBarPainter,
  dxCore, cxDateUtils, cxPCdxBarPopupMenu ;

type
  TITSBildirimDlg = class(TForm)
    Panel2: TPanel;
    PnlAra: TPanel;
    PcBildirim: TcxPageControl;
    TsDogrulamaBildirim: TcxTabSheet;
    TsMalAlim: TcxTabSheet;
    TsMalIade: TcxTabSheet;
    TsSatisBildirim: TcxTabSheet;
    TsSatisIptalBil: TcxTabSheet;
    GridMalAlimBildirim: TcxGrid;
    TvMalAlimListe: TcxGridDBTableView;
    ColSecMalAlim: TcxGridDBColumn;
    GridMalAlimBildirimLevel1: TcxGridLevel;
    Label1: TLabel;
    TvMalAlimListeFATURATARIH: TcxGridDBColumn;
    TvMalAlimListeBASLIK: TcxGridDBColumn;
    TvMalAlimListeSERINO: TcxGridDBColumn;
    TvMalAlimListeURUNKOD: TcxGridDBColumn;
    TvMalAlimListeLOTNO: TcxGridDBColumn;
    TvMalAlimListeSONKULLANIM: TcxGridDBColumn;
    TvMalAlimListeDOGRULAMA_DURUM: TcxGridDBColumn;
    TvMalAlimListeALIM_DURUM: TcxGridDBColumn;
    GridDogrulaBildirim: TcxGrid;
    TvDogrulamabildirim: TcxGridDBTableView;
    ColSecDogrulama: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    GridMalIade: TcxGrid;
    TvMalIade: TcxGridDBTableView;
    ColSecMalIade: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridDBColumn19: TcxGridDBColumn;
    cxGridDBColumn20: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    GridSatis: TcxGrid;
    TvSatis: TcxGridDBTableView;
    ColSecSatis: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn17: TcxGridDBColumn;
    cxGridDBColumn18: TcxGridDBColumn;
    cxGridDBColumn21: TcxGridDBColumn;
    cxGridDBColumn22: TcxGridDBColumn;
    cxGridDBColumn23: TcxGridDBColumn;
    cxGridDBColumn28: TcxGridDBColumn;
    cxGridDBColumn29: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    TsDeAktivasyon: TcxTabSheet;
    GridDeAktivasyon: TcxGrid;
    TvDeaktivasyon: TcxGridDBTableView;
    ColSecDeAktivasyon: TcxGridDBColumn;
    cxGridDBColumn24: TcxGridDBColumn;
    cxGridDBColumn35: TcxGridDBColumn;
    cxGridDBColumn36: TcxGridDBColumn;
    cxGridDBColumn37: TcxGridDBColumn;
    cxGridDBColumn38: TcxGridDBColumn;
    cxGridDBColumn39: TcxGridDBColumn;
    cxGridDBColumn40: TcxGridDBColumn;
    cxGridDBColumn41: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    BarBildirim: TdxNavBar;
    GroupBilYap: TdxNavBarGroup;
    GroupBilYapilmamis: TdxNavBarGroup;
    ItemDogrulama: TdxNavBarItem;
    ItemMalAlim: TdxNavBarItem;
    ItemMalAlimIade: TdxNavBarItem;
    ItemSatis: TdxNavBarItem;
    ItemSatisIptal: TdxNavBarItem;
    ItemDeAktivasyon: TdxNavBarItem;
    JvNavPanelHeader1: TJvNavPanelHeader;
    TxtUrunKodu: TcxTextEdit;
    TxtUrunSeriNo: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxButton1: TcxButton;
    BarBildirimItem1: TdxNavBarItem;
    BarBildirimItem2: TdxNavBarItem;
    BarBildirimItem3: TdxNavBarItem;
    ItemGecmis: TdxNavBarItem;
    TsGecmis: TcxTabSheet;
    GridGecmis: TcxGrid;
    TvGecmis: TcxGridDBTableView;
    cxGridLevel6: TcxGridLevel;
    TvGecmisURUN_DURUM: TcxGridDBColumn;
    TvGecmisURUN_BARKOD_NO: TcxGridDBColumn;
    TvGecmisURUN_SIRA_NO: TcxGridDBColumn;
    TvGecmisBILDIRIM_TARIH: TcxGridDBColumn;
    TvGecmisHATA_KODU: TcxGridDBColumn;
    TvGecmisHATA_ACIKLAMA: TcxGridDBColumn;
    TBItsAracCubugu: TToolBar;
    BildirTus: TToolButton;
    Panel1: TPanel;
    Panel3: TPanel;
    cxLabel3: TcxLabel;
    DtpTarih1: TcxDateEdit;
    DtpTarih2: TcxDateEdit;
    Panel4: TPanel;
    TsUretim: TcxTabSheet;
    ItemUretim: TdxNavBarItem;
    BtnGetir: TcxButton;
    GridFaturalar: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridLevel8: TcxGridLevel;
    cxGridDBTableView2TARIH: TcxGridDBColumn;
    cxGridDBTableView2ADET: TcxGridDBColumn;
    cxGridDBTableView2FIRMA: TcxGridDBColumn;
    cxGridDBTableView2STOKADI: TcxGridDBColumn;
    UretimAletCubugu: TToolBar;
    TbKarekodYaz: TToolButton;
    BtnSendPackage: TButton;
    cxTextEdit1: TcxTextEdit;
    BtnReceiverPackage: TButton;
    BtnCreateXML: TButton;
    Panel5: TPanel;
    BtnUretimBildirimi: TJvNavPanelButton;
    BtnUrunListe: TJvNavPanelButton;
    BtnSatinAlma: TJvNavPanelButton;
    BtnPaketleme1: TJvNavPanelButton;
    BtnSatis: TJvNavPanelButton;
    BtnDeAktivasyon: TJvNavPanelButton;
    BtnSatisIptal: TJvNavPanelButton;
    PcListeler: TcxPageControl;
    TsUretimListesi: TcxTabSheet;
    TsSatinAlmaListesi: TcxTabSheet;
    PnlUretimListesi: TPanel;
    ToolBar1: TToolBar;
    YeniTusUretim: TToolButton;
    ToolButton2: TToolButton;
    Panel6: TPanel;
    TsPaketlemeListesi: TcxTabSheet;
    TsSatisListesi: TcxTabSheet;
    TsDeAktivasyonListesi: TcxTabSheet;
    TsSatisIptalListesi: TcxTabSheet;
    TsAlimIptalListesi: TcxTabSheet;
    TsBosListe: TcxTabSheet;
    Label4: TLabel;
    Shape1: TShape;
    Label3: TLabel;
    Label2: TLabel;
    DateUretimBaslangic: TDateTimePicker;
    DateUretimBitis: TDateTimePicker;
    GridUretimListesi: TcxGrid;
    TvUretimListesi: TcxGridDBTableView;
    ColUretimListesiSec: TcxGridDBColumn;
    GlUretimListesi: TcxGridLevel;
    vUretimListesiColumn1: TcxGridDBColumn;
    vUretimListesiColumn2: TcxGridDBColumn;
    vUretimListesiColumn3: TcxGridDBColumn;
    vUretimListesiColumn4: TcxGridDBColumn;
    vUretimListesiColumn5: TcxGridDBColumn;
    vUretimListesiColumn6: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    pmHepsiSec: TMenuItem;
    pmTumunuKaldir: TMenuItem;
    pmSecimiTersCevir: TMenuItem;
    TabUretimListesi: TADOQuery;
    TabUretimListesiID: TAutoIncField;
    TabUretimListesiTARIH: TDateTimeField;
    TabUretimListesiBELGENO: TStringField;
    TabUretimListesiBELGEBASID: TIntegerField;
    TabUretimListesiBELGEDETAYID: TIntegerField;
    TabUretimListesiBELGETURU: TIntegerField;
    TabUretimListesiURUNID: TIntegerField;
    TabUretimListesiREHBERID: TIntegerField;
    TabUretimListesiURETIMADET: TIntegerField;
    TabUretimListesiBELGE: TWideStringField;
    TabUretimListesiFIRMA: TWideStringField;
    TabUretimListesiSTOKADI: TWideStringField;
    TabUretimListesiBARKODID: TIntegerField;
    TabUretimListesiBARKOD: TWideStringField;
    DtsUretimListesi: TDataSource;
    TabUretimListesiDURUM: TIntegerField;
    vUretimListesiColumn7: TcxGridDBColumn;
    PnlSatinAlma: TPanel;
    TbSatinAlma: TToolBar;
    ToolButton4: TToolButton;
    YazdirTusSatinAlma: TToolButton;
    BildirTusSatinAlma: TToolButton;
    ListeleTusSatinAlma: TToolButton;
    Panel8: TPanel;
    DateSatinAlmaBaslangic: TDateTimePicker;
    DateSatinAlmaBitis: TDateTimePicker;
    TabSatinAlmaListesi: TADOQuery;
    DtsSatinAlmaListesi: TDataSource;
    GridAlim: TcxGrid;
    TvAlim: TcxGridDBTableView;
    cxGridDBColumn25: TcxGridDBColumn;
    cxGridDBColumn26: TcxGridDBColumn;
    cxGridDBColumn27: TcxGridDBColumn;
    cxGridDBColumn30: TcxGridDBColumn;
    cxGridDBColumn31: TcxGridDBColumn;
    cxGridDBColumn32: TcxGridDBColumn;
    cxGridDBColumn33: TcxGridDBColumn;
    GlAlim: TcxGridLevel;
    PnlPaketlemeListesi: TPanel;
    ToolBar2: TToolBar;
    YeniTusPaketleme: TToolButton;
    SilTusPaketleme: TToolButton;
    ToolButton5: TToolButton;
    YaziciYazPaketleme: TToolButton;
    BildirTusPaketleme: TToolButton;
    ListeleTusPaketleme: TToolButton;
    Panel9: TPanel;
    DatePaketlemeBaslangic: TDateTimePicker;
    DatePaketlemeBitis: TDateTimePicker;
    TabPaketlemeListesi: TADOQuery;
    DtsPaketlemeListesi: TDataSource;
    GridPaketleme: TcxGrid;
    DbTvPaketleme: TcxGridDBTableView;
    cxGridDBColumn34: TcxGridDBColumn;
    cxGridDBColumn42: TcxGridDBColumn;
    cxGridDBColumn43: TcxGridDBColumn;
    cxGridDBColumn44: TcxGridDBColumn;
    cxGridDBColumn45: TcxGridDBColumn;
    cxGridDBColumn47: TcxGridDBColumn;
    cxGridDBColumn48: TcxGridDBColumn;
    GlPaketleme: TcxGridLevel;
    PnlSatis: TPanel;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    BtnSatisYazdir: TToolButton;
    BtnSatisBildir: TToolButton;
    Panel10: TPanel;
    DateSatisBaslangic: TDateTimePicker;
    DateSatisBitis: TDateTimePicker;
    TabSatisListesi: TADOQuery;
    DtsSatisListesi: TDataSource;
    GridSatisListesi: TcxGrid;
    TvSatisListesi: TcxGridDBTableView;
    cxGridDBColumn49: TcxGridDBColumn;
    cxGridDBColumn50: TcxGridDBColumn;
    cxGridDBColumn51: TcxGridDBColumn;
    cxGridDBColumn52: TcxGridDBColumn;
    cxGridDBColumn53: TcxGridDBColumn;
    cxGridDBColumn54: TcxGridDBColumn;
    cxGridDBColumn55: TcxGridDBColumn;
    cxGridDBColumn56: TcxGridDBColumn;
    GlSatisListesi: TcxGridLevel;
    vUretimListesiColumn8: TcxGridDBColumn;
    HTTPRIO1: THTTPRIO;
    HTTPReqResp1: THTTPReqResp;
    Panel7: TPanel;
    ToolBar4: TToolBar;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    Panel11: TPanel;
    DateDeAktivasyonBaslangic: TDateTimePicker;
    DateDeAktivasyonBitis: TDateTimePicker;
    GridDeAktivasyonGetir: TcxGrid;
    TvDeAktivasyonGetir: TcxGridDBTableView;
    cxGridDBColumn57: TcxGridDBColumn;
    cxGridDBColumn58: TcxGridDBColumn;
    cxGridDBColumn59: TcxGridDBColumn;
    cxGridDBColumn60: TcxGridDBColumn;
    cxGridDBColumn61: TcxGridDBColumn;
    cxGridDBColumn62: TcxGridDBColumn;
    cxGridDBColumn63: TcxGridDBColumn;
    cxGridDBColumn64: TcxGridDBColumn;
    GlDeAktivasyon: TcxGridLevel;
    Panel12: TPanel;
    ToolBar5: TToolBar;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    BtnBildir: TToolButton;
    Panel13: TPanel;
    DateSatisIptalBaslangic: TDateTimePicker;
    DateSatisIptalBitis: TDateTimePicker;
    GridSatisIptal: TcxGrid;
    ViewSatisIptal: TcxGridDBTableView;
    cxGridDBColumn66: TcxGridDBColumn;
    cxGridDBColumn67: TcxGridDBColumn;
    cxGridDBColumn68: TcxGridDBColumn;
    cxGridDBColumn69: TcxGridDBColumn;
    cxGridDBColumn70: TcxGridDBColumn;
    cxGridDBColumn71: TcxGridDBColumn;
    cxGridDBColumn72: TcxGridDBColumn;
    LvlSatisIptal: TcxGridLevel;
    Panel14: TPanel;
    ToolBar6: TToolBar;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    Panel15: TPanel;
    DateAlimIptalBaslangic: TDateTimePicker;
    DateAlimIptalBitis: TDateTimePicker;
    cxGrid4: TcxGrid;
    cxGridDBTableView5: TcxGridDBTableView;
    cxGridDBColumn73: TcxGridDBColumn;
    cxGridDBColumn74: TcxGridDBColumn;
    cxGridDBColumn75: TcxGridDBColumn;
    cxGridDBColumn76: TcxGridDBColumn;
    cxGridDBColumn77: TcxGridDBColumn;
    cxGridDBColumn78: TcxGridDBColumn;
    cxGridDBColumn79: TcxGridDBColumn;
    cxGridDBColumn80: TcxGridDBColumn;
    cxGridLevel10: TcxGridLevel;
    TabSatinAlmaListesiTARIH: TDateTimeField;
    TabSatinAlmaListesiBELGENO: TWideStringField;
    TabSatinAlmaListesiBELGEDETAYID: TAutoIncField;
    TabSatinAlmaListesiBELGEBASID: TAutoIncField;
    TabSatinAlmaListesiREHBERID: TIntegerField;
    TabSatinAlmaListesiFIRMA: TWideStringField;
    TabSatinAlmaListesiBELGETIPI: TWideStringField;
    TabSatinAlmaListesiSTOKADI: TWideStringField;
    TabSatinAlmaListesiADET: TFloatField;
    TabSatinAlmaListesiTUR: TSmallintField;
    TabSatinAlmaListesiURUNID: TIntegerField;
    TabSatinAlmaListesiBARKOD: TWideStringField;
    TabSatinAlmaListesiBARKODID: TAutoIncField;
    TabSatinAlmaListesiDURUM: TIntegerField;
    TabDeAktivasyon: TADOQuery;
    DtsDeAktivasyon: TDataSource;
    TabSatisListesiID: TAutoIncField;
    TabSatisListesiTARIH: TDateTimeField;
    TabSatisListesiFATURANO: TWideStringField;
    TabSatisListesiBELGETIPI: TWideStringField;
    TabSatisListesiFIRMA: TWideStringField;
    TabSatisListesiADET: TFloatField;
    TabSatisListesiREHBERID: TAutoIncField;
    TabUretimListesiDEPOID: TIntegerField;
    TabSatisIptalListesi: TADOQuery;
    DtsSatisIptalListesi: TDataSource;
    TabSatisIptalListesiBELGEDETAYID: TAutoIncField;
    TabSatisIptalListesiTARIH: TDateTimeField;
    TabSatisIptalListesiBELGENO: TWideStringField;
    TabSatisIptalListesiBELGEBASID: TAutoIncField;
    TabSatisIptalListesiREHBERID: TIntegerField;
    TabSatisIptalListesiFIRMA: TWideStringField;
    TabSatisIptalListesiBELGETIPI: TWideStringField;
    TabSatisIptalListesiSTOKADI: TWideStringField;
    TabSatisIptalListesiADET: TFloatField;
    TabSatisIptalListesiTUR: TSmallintField;
    TabSatisIptalListesiURUNID: TIntegerField;
    TabSatisIptalListesiBARKOD: TWideStringField;
    TabSatisIptalListesiBARKODID: TAutoIncField;
    TabSatisIptalListesiDURUM: TIntegerField;
    BtnAlisIptal: TJvNavPanelButton;
    BtnHizliSatis: TJvNavPanelButton;
    TabSatisListesiSATISDURUM: TIntegerField;
    TabSatisListesiPAKETDURUM: TIntegerField;
    vSatisListesiColumn1: TcxGridDBColumn;
    BtnPaketleme: TJvNavPanelButton;
    PaketTimer: TTimer;
    ListeleriGuncelleTimer: TTimer;
    BtnListeler: TJvNavPanelButton;
    PopSatisIptalDogruBildirim: TPopupMenu;
    DoruBildirimeevir1: TMenuItem;
    PopSAtinAlmaDogruBildirim: TPopupMenu;
    DogruBildirimCevir: TMenuItem;
    PopSatisDogruBildirim: TPopupMenu;
    DogruBildirim: TMenuItem;
    PopPaketleme: TPopupMenu;
    PaketDogruBildirim: TMenuItem;
    TabPaketlemeListesiID: TAutoIncField;
    TabPaketlemeListesiTARIH: TDateTimeField;
    TabPaketlemeListesiBELGENO: TStringField;
    TabPaketlemeListesiBELGETURU: TIntegerField;
    TabPaketlemeListesiREHBERID: TIntegerField;
    TabPaketlemeListesiURETIMADET: TIntegerField;
    TabPaketlemeListesiTRANSFERID: TLargeintField;
    TabPaketlemeListesiSIPARISID: TIntegerField;
    TabPaketlemeListesiSIPARISDETAYID: TIntegerField;
    TabPaketlemeListesiFATBASID: TIntegerField;
    TabPaketlemeListesiDEPOID: TIntegerField;
    TabPaketlemeListesiBELGE: TWideStringField;
    TabPaketlemeListesiFIRMA: TWideStringField;
    TabPaketlemeListesiDURUM: TIntegerField;
    procedure BarBildirimActiveGroupChanged(Sender: TObject);
    procedure BarBildirimLinkClick(Sender: TObject; ALink: TdxNavBarItemLink);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BildirTusClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure HTTPRIO1HTTPWebNode1BeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
    procedure FormCreate(Sender: TObject);
    procedure cxGridDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure pmHepsiSecClick(Sender: TObject);
    procedure GridDogrulaBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure PcBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure GridDeAktivasyonContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure BtnGetirClick(Sender: TObject);
    procedure cxGridDBTableView2CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure GridUretimBildirimiContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure TbKarekodYazClick(Sender: TObject);
    procedure BtnReceiverPackageClick(Sender: TObject);
    procedure BtnUretimBildirimiClick(Sender: TObject);
    procedure YeniTusUretimClick(Sender: TObject);
    procedure PcListelerPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure TvUretimListesiCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure GridUretimListesiContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DtsUretimListesiStateChange(Sender: TObject);
    procedure YeniTusPaketlemeClick(Sender: TObject);
    procedure SilTusPaketlemeClick(Sender: TObject);
    procedure ListeleTusPaketlemeClick(Sender: TObject);
    procedure DbTvPaketlemeCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TvSatisListesiCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TvDeAktivasyonGetirCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure ListeleTusSatinAlmaClick(Sender: TObject);
    procedure BildirTusSatinAlmaClick(Sender: TObject);
    procedure DateUretimBitisChange(Sender: TObject);
    procedure DateUretimBaslangicChange(Sender: TObject);
    procedure DateSatisBitisChange(Sender: TObject);
    procedure DateSatinAlmaBitisChange(Sender: TObject);
    procedure DateSatinAlmaBaslangicChange(Sender: TObject);
    procedure TvAlimCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure DateSatisBaslangicChange(Sender: TObject);
    procedure ViewSatisIptalCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure PaketTimerTimer(Sender: TObject);
    procedure ListeleriGuncelleTimerTimer(Sender: TObject);
    procedure DateSatisIptalBaslangicChange(Sender: TObject);
    procedure DateSatisIptalBitisChange(Sender: TObject);
    procedure DoruBildirimeevir1Click(Sender: TObject);
    procedure DogruBildirimCevirClick(Sender: TObject);
    procedure DogruBildirimClick(Sender: TObject);
    procedure PaketDogruBildirimClick(Sender: TObject);
    procedure DatePaketlemeBaslangicChange(Sender: TObject);
    procedure DatePaketlemeBitisChange(Sender: TObject);
    procedure DateDeAktivasyonBaslangicChange(Sender: TObject);

  private
    { Private declarations }




  public
    { Public declarations }
    procedure DogrulamaGonder();
    procedure MalIadeGonder();
    procedure DeAktivasyonGonder();
    procedure ListeleriGetir();
    procedure GecmisGetir();
    procedure UretimListesiGetir;
    procedure SatinAlimListesiGetir;
    procedure KarekodYazdir;
    procedure PaketlemListesiGetir;
    procedure SatisListesiGetir;
    procedure SatisIptalListesiGetir;
    procedure HizliSatisBaslat;
    procedure UrunListe;
    procedure PaketAlim;
    procedure ServisGetir;
    procedure DeAktivasyonListesiGetir;
  end;
var
  ITSBildirimDlg: TITSBildirimDlg;
  GridDC: TcxGridDBDataController; // cxGridDBDataDefinitions
  // Button Taglarý 0 : Üretim 1:SatýnAlma 2:Paketleme 3:Satýþ 4 :DeAktivasyon
  // 5 : Satýþ Ýptal 6: Alýþ Ýptal  7 : Hýzlý Mal Satýþ (Sipariþ Satýþ)
 // DED

  implementation
Uses  ECXMLParser, UItsAraclari,Utablo,UBelge,UUretim, UPaketleme,USatis, UAlim ,
USatisIptal,USiparisMalSatis, UUrunListe, UBildirilmisPaketler, UReferansServisleri, UDeAktivasyon;


{$R *.dfm}

procedure TITSBildirimDlg.BarBildirimActiveGroupChanged(Sender: TObject);
begin
 {case BarBildirim.ActiveGroup.Index of
 0 :begin
    TBItsAracCubugu.Visible := False;
    ColSecMalAlim.Visible:= False;
    ColSecSatis.Visible := False;
    ColSecDeAktivasyon.Visible:= False;
    ColSecUretim.Visible := False;
    UretimAletCubugu.Visible:=True;
    end;
 1 :begin
    TBItsAracCubugu.Visible := True;
    ColSecMalAlim.Visible:= True;
    ColSecSatis.Visible := True;
    ColSecDeAktivasyon.Visible:= True;
    ColSecUretim.Visible := True;
    UretimAletCubugu.Visible:=False;
    end;
 end;
 case BarBildirim.ActiveGroup.SelectedLinkIndex of
    0:begin  TsDogrulamaBildirim.Show; ListeleriGetir(); end;
    1:begin  TsMalAlim.Show; ListeleriGetir();    end;
    2:begin  TsMalIade.Show; ListeleriGetir();    end;
    3:begin  TsSatisBildirim.Show; ListeleriGetir(); end;
    4:begin  TsSatisIptal.Show; ListeleriGetir();  end;
    5:begin  TsDeAktivasyon.Show; ListeleriGetir(); end;
    6:begin  TsGecmis.Show;GecmisGetir(); end
    else TsBos.show;
 end;  }
end;

procedure TITSBildirimDlg.BarBildirimLinkClick(Sender: TObject; ALink: TdxNavBarItemLink);
begin
{  case ALink.Item.Tag of
    0:begin   TsDogrulamaBildirim.Show; ListeleriGetir(); end;
    1:begin  TsMalAlim.Show; ListeleriGetir();    end;
    2:begin TsMalIade.Show; ListeleriGetir();    end;
    3:begin  TsSatisBildirim.Show; ListeleriGetir(); end;
    4:begin  TsSatisIptal.Show; ListeleriGetir();  end;
    5:begin  TsDeAktivasyon.Show; ListeleriGetir(); end;
    6:begin TsGecmis.Show;GecmisGetir(); end;
    7:begin TsUretim.Show;ListeleriGetir(); end
  else TsBos.Show;
  end;   }
end;

procedure TITSBildirimDlg.Button1Click(Sender: TObject);
var
Stream: TMemoryStream;
StrStream: TStringStream;
xml1: Tstringlist;
xml : TECXMLParser;
data : TXMLItem;
//paket : receiveFileParameters;
//paketgelen :  PackageReceiverWS;
//dosya: TSOAPAttachment;
begin

{paket := receiveFileParameters.Create;
paket.sourceGLN := '';
paket.transferId := 12456987;

paketgelen:=PtsPackageReceiverWebService.GetPackageReceiverWS(False,'',HTTPRIO1);
dosya:= paketgelen.receiveFile(paket);
dosya.SaveToFile('deneme.xml');

       }
{xml1:= tstringlist.Create;
stream:=tmemorystream.Create;
try
HTTPReqResp1.URL:= 'http://212.174.130.240/DepoMalAlim/DepoMalAlimReceiverService';//'http://212.174.130.240:8080/DepoDogrulama/DepoDogrulamaReceiverService';  // bunu wsdl den aldýk
HTTPReqResp1.UseUTF8InHeader:=true;
HTTPReqResp1.SoapAction:= 'DepoMalAlimReceiverService';
HTTPReqResp1.UserName:='genotip';  //kullanýcý adý ve þifre
HTTPReqResp1.Password:='genotip001';

HTTPReqResp1.Execute(Memo1.Text,Stream);  // burada oluþturduðumuz xml i post ediyoruz. cevap Stream içinde dönecek
Strstream:= Tstringstream.Create('');
try
  Strstream.CopyFrom(stream,0);
  Memo2.Text:= Strstream.DataString;   // gelen cevabý memo içinde görebilirsin.  bunu dosyaya yazdýrýp sonra bir datasete alacaz
  xml := TECXMLParser.Create(nil);
  xml.LoadFromStream(Stream);
  data := xml.Root.SubItems[0].SubItems[0];
 // Memo2.Lines.Add := data.NamedItem['BILDIRIMID'].Text;
  xml1.Add(memo2.Text);
  xml1.SaveToFile('mal_alim_cevap.xml');  // gelen cevap bu dosyada
  finally
strstream.Free;
end;
finally
stream.Destroy;
end;   }
end;

procedure TITSBildirimDlg.Button2Click(Sender: TObject);
var
XMLdata: TStringList;
xml1: Tstringlist;
//DepoAlim : TDepoAlimIstek;
begin
{DepoAlim := TDepoAlimIstek.create;
DepoAlim.FR :=
XMLData := Tstringlist.Create;
xml1:= tstringlist.Create;
XMLData.Clear;
TabMalAlim.First;
XMLData.Add('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:depo="http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo">');
XMLData.Add('<soapenv:Header/><soapenv:Body>');
XMLData.Add('<depo:DepoMalAlim>');
XMLData.Add('<DT>A</DT> ');
XMLData.Add('<FR>'+TabMalAlim.FieldByName('MALALINANGLN').Value+'</FR>');
XMLData.Add('<TO>'+'8680052900019'+'</TO>');
XMLData.Add('<URUNLER>');   // aþaðýda veritabaný tablomuzdan karekod bilgilerini çekiyoruz
while not TabMalAlim.Eof do
begin
XMLData.Add('<URUN>');
XMLData.Add('<GTIN>'+ TabMalAlim.FieldByName('URUNKOD').Value+'</GTIN>'); //barkod
XMLData.Add('<BN>'+ TabMalAlim.FieldByName('LOTNO').Value+'</BN>');  // batch no
XMLData.Add('<SN>'+ TabMalAlim.FieldByName('SERINO').Value+'</SN>'); // seri no
XMLData.Add('<XD>'+ FormatDateTime('YYYY-MM-DD',TabMalAlim.FieldByName('SONKULLANIM').Value)+'</XD>');  // son kull tar.   YYYY-MM-DD formda string
XMLData.Add('</URUN>');
TabMalAlim.LAST;
end;
//table1.Close;
XMLData.Add('</URUNLER>');
XMLData.Add('</depo:DepoMalAlim>');
XMLData.Add('</soapenv:Body>');
XMLData.Add('</soapenv:Envelope>');  // XML sonu
memo1.Lines:=XMLData;


// bu xml i datasette görmek için kapatýp açmak yeterli
//clientdataset1.Active:=false;

//clientdataset1.Active:=true;    }
end;

procedure TITSBildirimDlg.BtnUretimBildirimiClick(Sender: TObject);
begin
  case (sender as  TJvNavPanelButton).Tag of
    0:begin  TsUretimListesi.Show; UretimListesiGetir; end;
    1:begin  TsSatinAlmaListesi.Show; SatinAlimListesiGetir;   end;
    2:begin  TsPaketlemeListesi.Show;  PaketlemListesiGetir; end;
    3:begin  TsSatisListesi.Show; SatisListesiGetir; end;
    4:begin  TsDeAktivasyonListesi.Show; DeAktivasyonListesiGetir; end;
    5:begin  TsSatisIptalListesi.Show; SatisIptalListesiGetir;     end;
    6:begin  TsAlimIptalListesi.Show;  end;
    7:begin  HizliSatisBaslat;     end;
    8:begin  UrunListe; end;
    9:begin  PaketAlim; end;
    10: begin ServisGetir; end;
  else TsBosListe.Show;
  end;
end;
procedure TITSBildirimDlg.cxButton1Click(Sender: TObject);
begin
ListeleriGetir;
end;

procedure TITSBildirimDlg.BtnGetirClick(Sender: TObject);
begin
    Tablo.TabFaturalar.Close;
    Tablo.TabFaturalar.SQL.Clear;
    Tablo.TabFaturalar.SQL.Add(' SELECT FB.TARIH,F.ID,ADET ,R.FIRMA ,S.STOKADI FROM FATURA F ');
    Tablo.TabFaturalar.SQL.Add(' INNER JOIN REHBER R ON R.ID=F.REHBERID ');
    Tablo.TabFaturalar.SQL.Add(' INNER JOIN FATBASLIK FB ON FB.ID=F.FATBASID ');
    Tablo.TabFaturalar.SQL.Add(' INNER JOIN STOKLAR S ON S.ID =F.URUNID WHERE F.IZLEME=''3'' AND  ');
    Tablo.TabFaturalar.SQL.Add(' FB.TARIH BETWEEN '''+FormatDateTime('yyyy-MM-dd',DtpTarih1.Date)+''' AND '''+FormatDateTime('yyyy-MM-dd',DtpTarih2.Date)+''' ');
    case BarBildirim.ActiveGroup.SelectedLinkIndex  of
    7: Tablo.TabFaturalar.SQL.Add(' AND FB.TUR = 11  ');   //Üretim Bildirimi
    3,4: Tablo.TabFaturalar.SQL.Add(' AND FB.TUR = 15  ');   //Satýþ  Bildirimi
    else  Tablo.TabFaturalar.SQL.Add(' AND FB.TUR IN (11,15)  ');
    end;
    Tablo.TabFaturalar.Open;
end;

procedure TITSBildirimDlg.BtnReceiverPackageClick(Sender: TObject);

var
Stream: TMemoryStream;
StrStream: TStringStream;
xml1: Tstringlist;
xml : TECXMLParser;
data : TXMLItem;
//paket : receiveFileParameters;
//paketgelen :  PackageReceiverWS;
//dosya: TSOAPAttachment;

begin

{paket := receiveFileParameters.Create;
paket.sourceGLN := '';
paket.transferId := 12456987;

paketgelen:=PtsPackageReceiverWebService.GetPackageReceiverWS(False,'',HTTPRIO1);
dosya:= paketgelen.receiveFile(paket);
dosya.SaveToFile('deneme.xml');

       }
{xml1:= tstringlist.Create;
stream:=tmemorystream.Create;
try
HTTPReqResp1.URL:= 'http://212.174.130.240/DepoMalAlim/DepoMalAlimReceiverService';//'http://212.174.130.240:8080/DepoDogrulama/DepoDogrulamaReceiverService';  // bunu wsdl den aldýk
HTTPReqResp1.UseUTF8InHeader:=true;
HTTPReqResp1.SoapAction:= 'DepoMalAlimReceiverService';
HTTPReqResp1.UserName:='genotip';  //kullanýcý adý ve þifre
HTTPReqResp1.Password:='genotip001';

HTTPReqResp1.Execute(Memo1.Text,Stream);  // burada oluþturduðumuz xml i post ediyoruz. cevap Stream içinde dönecek
Strstream:= Tstringstream.Create('');
try
  Strstream.CopyFrom(stream,0);
  Memo2.Text:= Strstream.DataString;   // gelen cevabý memo içinde görebilirsin.  bunu dosyaya yazdýrýp sonra bir datasete alacaz
  xml := TECXMLParser.Create(nil);
  xml.LoadFromStream(Stream);
  data := xml.Root.SubItems[0].SubItems[0];
 // Memo2.Lines.Add := data.NamedItem['BILDIRIMID'].Text;
  xml1.Add(memo2.Text);
  xml1.SaveToFile('mal_alim_cevap.xml');  // gelen cevap bu dosyada
  finally
strstream.Free;
end;
finally
stream.Destroy;
end;   }
end;

procedure TITSBildirimDlg.cxGridDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
Var
  AColumn1 , AColumn2: TcxCustomGridTableItem;
begin
  AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('HATA_ACIKLAMA');
  AColumn2 := (Sender as TcxGridDBTableView).GetColumnByFieldName('URUN_DURUM');
  if ARecord.Values[AColumn1.Index] = 'Doðru Bildirim.' then
     AStyle := Tablo.cxStDogruBildirim;

  if ARecord.Values[AColumn2.Index] = '' then
     AStyle := Tablo.cxStServerHata
  else
     Exit;


end;

procedure TITSBildirimDlg.cxGridDBTableView2CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
ListeleriGetir;
end;

procedure TITSBildirimDlg.TvDeAktivasyonGetirCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if DeAktivasyonDlg = nil then
    Application.CreateForm(TDeAktivasyonDlg, DeAktivasyonDlg);
  DeAktivasyonDlg.ShowModal;
end;

procedure TITSBildirimDlg.DateDeAktivasyonBaslangicChange(Sender: TObject);
begin
DeAktivasyonListesiGetir;
end;

procedure TITSBildirimDlg.DatePaketlemeBaslangicChange(Sender: TObject);
begin
PaketlemListesiGetir;
end;

procedure TITSBildirimDlg.DatePaketlemeBitisChange(Sender: TObject);
begin
PaketlemListesiGetir;
end;

procedure TITSBildirimDlg.DateSatinAlmaBaslangicChange(Sender: TObject);
begin
SatinAlimListesiGetir;
end;

procedure TITSBildirimDlg.DateSatinAlmaBitisChange(Sender: TObject);
begin
SatinAlimListesiGetir;
end;

procedure TITSBildirimDlg.DateSatisBaslangicChange(Sender: TObject);
begin
SatisListesiGetir;
end;

procedure TITSBildirimDlg.DateSatisBitisChange(Sender: TObject);
begin
DeAktivasyonListesiGetir;
end;

procedure TITSBildirimDlg.DateSatisIptalBaslangicChange(Sender: TObject);
begin
SatisIptalListesiGetir;
end;

procedure TITSBildirimDlg.DateSatisIptalBitisChange(Sender: TObject);
begin
SatisIptalListesiGetir;
end;

procedure TITSBildirimDlg.DateUretimBaslangicChange(Sender: TObject);
begin
UretimListesiGetir;
end;

procedure TITSBildirimDlg.DateUretimBitisChange(Sender: TObject);
begin
UretimListesiGetir;
end;

procedure TITSBildirimDlg.DbTvPaketlemeCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if PaketlemeDlg = nil then
    Application.CreateForm(TPaketlemeDlg, PaketlemeDlg);
  PaketlemeDlg.ShowModal;
end;

procedure TITSBildirimDlg.DeAktivasyonGonder;
var
  DeAktivasyonIstek   : TDeAktivasyonIstek;
  Urun            : TUrun;
  Yanit           : TGenelYanit;
begin
  DeAktivasyonIstek := TDeAktivasyonIstek.Create;
  DeAktivasyonIstek.FR :=GLNFirma;
  DeAktivasyonIstek.DS :='' ;
  DeAktivasyonIstek.ISACIKLAMA := '';
  DeAktivasyonIstek.BelgeDD := Tablo.TabDeAktivasyon.FieldByName('FATURATARIH').AsDateTime;
  DeAktivasyonIstek.BelgeDN := Tablo.TabDeAktivasyon.FieldByName('FATURANO').AsString;
  Tablo.TabDeAktivasyon.First;
  while not (Tablo.TabDeAktivasyon.Eof) do
     begin
       if ColSecDeAktivasyon.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabDeAktivasyon.FieldByName('URUNKOD').AsString;
        Urun.BN   := Tablo.TabDeAktivasyon.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabDeAktivasyon.FieldByName('SERINO').AsString;
        Urun.XD   := Tablo.TabDeAktivasyon.FieldByName('SONKULLANIM').AsDateTime;
        DeAktivasyonIstek.Urunler.Add(Urun);
        end;
     Tablo.TabDeAktivasyon.Next;
     end;
  XMLGelenIsle(XMLGonder(DeAktivasyonIstek),DeAktivasyonIstek.Urunler);
  DeAktivasyonIstek.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;

procedure TITSBildirimDlg.DeAktivasyonListesiGetir;
begin
TabDeAktivasyon.Close;
TabDeAktivasyon.Parameters.ParamByName('TARIH1').Value:= FormatDateTime('yyyy-MM-dd',DateDeAktivasyonBaslangic.Date); //FormatDateTime('yyyy-mm-dd 00:00:00',DateUretimBaslangic.Date);
TabDeAktivasyon.Parameters.ParamByName('TARIH2').Value:= FormatDateTime('yyyy-MM-dd',DateDeAktivasyonBitis.Date); //FormatDateTime('yyyy-mm-dd 23:59:59',DateUretimBitis.Date);
TabDeAktivasyon.Open;
end;

procedure TITSBildirimDlg.DogruBildirimCevirClick(Sender: TObject);
begin
BildirimGuncelle(3,TabSatinAlmaListesi.FieldByName('BELGEBASID').AsInteger,9);
 SatinAlimListesiGetir;
end;

procedure TITSBildirimDlg.DogruBildirimClick(Sender: TObject);
begin
BildirimGuncelle(3,TabSatisListesi.FieldByName('ID').AsInteger,9);
 SatisListesiGetir;
end;

procedure TITSBildirimDlg.DogrulamaGonder;
var
  DepoDogrulama   : TDepoDogrulamaIstek;
  Urun            : TUrun;
begin
  DepoDogrulama := TDepoDogrulamaIstek.Create;
  DepoDogrulama.FR :=GLNFirma ;
  Tablo.TabDogrulama.First;
  while not (Tablo.TabDogrulama.Eof) do
     begin
       if ColSecDogrulama.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabDogrulama.FieldByName('URUNKOD').AsString;
        Urun.BN   := Tablo.TabDogrulama.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabDogrulama.FieldByName('SERINO').AsString;
        Urun.XD   := Tablo.TabDogrulama.FieldByName('SONKULLANIM').AsDateTime;
        DepoDogrulama.Urunler.Add(Urun);
        end;
     Tablo.TabDogrulama.Next;
     end;
     XMLGelenIsle(XMLGonder(DepoDogrulama),DepoDogrulama.Urunler);
     DepoDogrulama.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;
procedure TITSBildirimDlg.DoruBildirimeevir1Click(Sender: TObject);
begin
BildirimGuncelle(3,TabSatisIptalListesi.FieldByName('BELGEBASID').AsInteger,9);
SatisIptalListesiGetir;
end;

procedure TITSBildirimDlg.DtsUretimListesiStateChange(Sender: TObject);
begin
//   Tablo.NavTusGoruntule(DtsUretimListesi,YeniTus,SilTus,DegisTus,DegisTus);
end;

procedure TITSBildirimDlg.FormCreate(Sender: TObject);
var
Etiketler,Bilgiler : TArrayOfString;
begin
  Tablo.RehberEkBilgileriniGetir(-1,2,[81],Etiketler,Bilgiler);
  GLNFirma:= Bilgiler[0];
  PcBildirim.ActivePageIndex := 6;
  DtpTarih1.Date := NOW-1;
  DtpTarih2.Date := NOW;

  if KullanimTipi=0 then
  begin
    ItemDogrulama.Visible := False;
    ItemMalAlim.Visible := False;
    ItemMalAlimIade.Visible := False;

  end;


  PaketTimer.Interval := StrToInt(RehberIni.ReadString('GenelOpsiyon', 'Paket Yenileme Zamaný', '10') ) *1000;


  DateSatisBaslangic.Date:=Now-60;
  DateSatisBitis.Date:=Now;
  DatePaketlemeBaslangic.Date:=Now-60;
  DatePaketlemeBitis.Date:=Now;
  DateUretimBaslangic.Date:=Now-60;
  DateUretimBitis.Date:=Now;
  DateSatinAlmaBaslangic.Date:=Now-60;
  DateSatinAlmaBitis.Date:=Now;

  DateDeAktivasyonBaslangic.Date:=now-60;
  DateDeAktivasyonBitis.Date:=now;

  DateSatisIptalBaslangic.Date:=now-60;
  DateSatisIptalBitis.Date:=now;

  DateAlimIptalBaslangic.Date:=now-60;
  DateAlimIptalBitis.Date:=now;


  PcListeler.HideTabs:= True;

end;

procedure TITSBildirimDlg.FormShow(Sender: TObject);
begin
BarBildirim.ActiveGroupIndex:=0;
TBItsAracCubugu.Visible := False;

//BtnUretimBildirimi.Caption := KullanimLabel + BtnUretimBildirimi.Caption ;
BtnSAtinAlma.Caption := KullanimLabel + BtnSAtinAlma.Caption;
BtnPaketleme.Caption := KullanimLabel + BtnPaketleme.Caption;
BtnSatis.Caption := KullanimLabel + BtnSatis.Caption;
BtnDeAktivasyon.Caption := KullanimLabel + BtnDeAktivasyon.Caption;
BtnAlisIptal.Caption := KullanimLabel + BtnAlisIptal.Caption;
BtnSatisIptal.Caption := KullanimLabel + BtnSatisIptal.Caption;

if KullanimTipi = 0  then
begin
BtnUretimBildirimi.Visible := True;
BtnSatinAlma.Visible := False;
BtnAlisIptal.Visible := False;
BtnHizliSatis.Visible := False;

end
else
begin
BtnUretimBildirimi.Visible := False;
BtnHizliSatis.Visible := True;

end;
 TsBosListe.Show;

DateUretimBitis.Date := Now ;
DateUretimBaslangic.Date := Now -10;


  BtnUretimBildirimi.Hint:= BtnUretimBildirimi.Caption;
  BtnPaketleme.Hint:= BtnPaketleme.Caption;
  BtnSatis.Hint:= BtnSatis.Caption;


 ListeleriGuncelleTimer.Enabled  := RehberIni.ReadBool('GenelOpsiyon', 'Listeler Güncellesin', False);
 PaketTimer.Enabled  := RehberIni.ReadBool('GenelOpsiyon', 'Paketler Güncellesin', False);

end;

procedure TITSBildirimDlg.GecmisGetir;
begin
Tablo.TabGecmis.Close;
Tablo.TabGecmis.sql.Text := 'select * from ITS_URUNLER order by BILDIRIM_TARIH DESC';
Tablo.TabGecmis.Open;
end;

procedure TITSBildirimDlg.GridDeAktivasyonContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TITSBildirimDlg.GridDogrulaBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TITSBildirimDlg.GridUretimBildirimiContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TITSBildirimDlg.GridUretimListesiContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
 GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TITSBildirimDlg.pmHepsiSecClick(Sender: TObject);
var
 i,ToplamKayit : integer;
 s,Ters,GelenBool: Boolean;
begin
    case TMenuItem(Sender).Tag of
      1 : s :=True;
      2 : s :=False;
      3 : Ters := True;
    end;
  GridDc.BeginUpdate;
// toplamKayit:= GridDc.RecordCount; // tümünü seçmek için
  ToplamKayit:= GridDc.FilteredRecordCount; // filtre kullanýlýyorsa filtrelenmiþ olanlar arasýnda tümünü seçmek için
  for i := 0 to toplamkayit - 1 do
  Begin
    if Ters then
    begin
      if GridDC.GetValue(GridDC.FilteredRecordIndex[i],ColSecMalAlim.Index) = Null then
          GelenBool := False
      else GelenBool := GridDC.GetValue(GridDC.FilteredRecordIndex[i],0);
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,not GelenBool);
    end
    else
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,s);
  End;
  GridDC.EndUpdate;
end;

procedure TITSBildirimDlg.HizliSatisBaslat;
begin
if SiparisMalSatisDlg = nil then
    Application.CreateForm(TSiparisMalSatisDlg,SiparisMalSatisDlg);
    SiparisMalSatisDlg.ShowModal;
end;

procedure TITSBildirimDlg.HTTPRIO1HTTPWebNode1BeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
begin
 if not InternetSetOption(Data, INTERNET_OPTION_USERNAME,
               PChar(Tablo.HTTPRIO1.HTTPWebNode.UserName),
               Length(Tablo.HTTPRIO1.HTTPWebNode.UserName)) then
     ShowMessage(SysErrorMessage(GetLastError));

  if not InternetSetOption(Data,
               INTERNET_OPTION_PASSWORD,
               PChar(Tablo.HTTPRIO1.HTTPWebNode.Password),
               Length (Tablo.HTTPRIO1.HTTPWebNode.Password)) then
     ShowMessage(SysErrorMessage(GetLastError));
end;

procedure TITSBildirimDlg.KarekodYazdir;
var
  F : TextFile;
  satiretiketsayisi,fi,etiketbitis: integer;
  sablon,tmpStr,basilacak : String;
  text_01,text_17,text_10 ,strUrunAdi: string;
  baskihizi,yuklemesuresi ,MaksEtiketSay: integer;
  DosyaYolu : string;
  Dosya,Baslangic ,Govde ,Son : TStringList;
  I: Integer;
  sonkayitlar : Boolean;
begin
//  ComPort1.Open;
  DosyaYolu:='C:\Gentegre\karekod.txt';
  //if not FileExists(DosyaYolu) then
  //begin
  //  Application.MessageBox(PChar(DosyaYolu) ,'DÝKKAT Dosya bulunamýyor.',MB_ICONERROR);
  //  abort;
 // end;
  //TabUretim.First;
  Govde := TStringList.Create;
  Dosya := TStringList.Create;
  Dosya.Add('{D0420,1000,0400|}');
  while not Tablo.TabUretim.Eof do
  begin
   if (Tablo.TabUretim.RecNo mod 5 )= 1 then
   begin
   Govde.Add('{XB00;0050,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0025,0150,07,07,H,11,B='+Tablo.TabUretim.FieldByName('URUNNO').asstring+'|}');
   Govde.Add('{PC01;0050,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0075,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0100,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0125,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;

   if (Tablo.TabUretim.RecNo mod 5 )= 2 then
   begin
   Govde.Add('{XB00;0250,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0225,0150,07,07,H,11,B='+Tablo.TabUretim.FieldByName('URUNNO').asstring+'|}');
   Govde.Add('{PC01;0250,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0275,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0300,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0325,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;

   if (Tablo.TabUretim.RecNo mod 5 )= 3 then
   begin
   Govde.Add('{XB00;0450,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0425,0150,07,07,H,11,B='+Tablo.TabUretim.FieldByName('URUNNO').asstring+'|}');
   Govde.Add('{PC01;0450,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0475,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0500,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0525,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;
   if (Tablo.TabUretim.RecNo mod 5 )= 4 then
   begin
   Govde.Add('{XB00;0650,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0625,0150,07,07,H,11,B='+Tablo.TabUretim.FieldByName('URUNNO').asstring+'|}');
   Govde.Add('{PC01;0650,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0675,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0700,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0725,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;
   if (Tablo.TabUretim.RecNo mod 5 )= 0 then
   begin
   Govde.Add('{XB00;0850,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0825,0150,07,07,H,11,B='+Tablo.TabUretim.FieldByName('URUNNO').asstring+'|}');
   Govde.Add('{PC01;0850,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0875,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0900,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0925,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');

   Dosya.Add('{C|}');
      for I := 0 to Govde.Count - 1 do
      begin
      Dosya.Add(Govde[I]);
      end;
   Dosya.Add('');
   Dosya.Add('{XS;I,0001,0002C5200|}');
   Govde.clear;
    //Dosya.Clear;
   end;
   if Tablo.TabUretim.RecordCount=Tablo.TabUretim.RecNo    then
   begin
   Dosya.Add('{C|}');
      for I := 0 to Govde.Count - 1 do
      begin
      Dosya.Add(Govde[I]);
      end;
   Dosya.Add('');
   Dosya.Add('{XS;I,0001,0002C5200|}');
   Govde.clear;
   end;
   Tablo.TabUretim.Next;
  end;
   DeleteFile(DosyaYolu);
   Dosya.SaveToFile(DosyaYolu);
   ShellExecute(Handle, 'open', PChar('c:\Gentegre\yazdir.bat'), nil, nil, SW_HIDE);
end;


procedure TITSBildirimDlg.BildirTusClick(Sender: TObject);
begin
 //if PcBildirim.ActivePage=TsMalAlim  then begin MalAlimGonder; ListeleriGetir; end;
 if PcBildirim.ActivePage=TsDogrulamaBildirim  then begin  DogrulamaGonder;  ListeleriGetir; end;
 if PcBildirim.ActivePage=TsMalIade  then begin  MalIadeGonder; ListeleriGetir; end;
 //if PcBildirim.ActivePage=TsSatisBildirim  then begin  SatisGonder; ListeleriGetir; end;
 //if PcBildirim.ActivePage=TsSatisIptal  then begin  SatisIptalGonder;  ListeleriGetir; end;
 if PcBildirim.ActivePage=TsDeAktivasyon  then begin  DeAktivasyonGonder; ListeleriGetir; end;
 //if PcBildirim.ActivePage=TsUretim then begin UretimGonder; ListeleriGetir; end;
 end;

procedure TITSBildirimDlg.BildirTusSatinAlmaClick(Sender: TObject);
begin
  ITSBildirimDlg.TabSatisListesi.First;
  while not (ITSBildirimDlg.TabSatisListesi.Eof) do
     begin
         Tablo.TabMalAlim.Close;
         Tablo.TabMalAlim.sql.clear;
         Tablo.TabMalAlim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,K.* ');
         Tablo.TabMalAlim.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
         Tablo.TabMalAlim.sql.Add('( SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) <> '''+DurumDogru+''' ');
         Tablo.TabMalAlim.sql.Add('AND SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) <> '''+AlimDurumUzerinde+'''  )');
        // MalAlimGonder;
     end;
end;

procedure TITSBildirimDlg.ListeleriGetir;
var
Urunkod,UrunSeri : string;
begin
Urunkod := '%'+TxtUrunKodu.Text+'%';
UrunSeri := '%'+TxtUrunSeriNo.Text+'%';
 {
if Tablo.TabFaturalar.Eof then
begin
  Abort;
end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 0  then
    begin
    if BarBildirim.ActiveGroupIndex = 1 then
      begin
      Tablo.TabDogrulama.Close;
      Tablo.TabDogrulama.sql.clear;
      Tablo.TabDogrulama.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,K.* ');
      Tablo.TabDogrulama.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      Tablo.TabDogrulama.sql.Add('SUBSTRING(ISNULL(DOGRULAMA_DURUM,''''),0,6) <> ''00000'' ');
      Tablo.TabDogrulama.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      Tablo.TabDogrulama.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 1  then //Mal Alim
    begin
    if BarBildirim.ActiveGroupIndex = 0 then     //Mal Alim Hatasýz Gonderilen Kayýtlar
      begin
      Tablo.TabMalAlim.Close;
      Tablo.TabMalAlim.sql.clear;
      Tablo.TabMalAlim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,K.* ');
      Tablo.TabMalAlim.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      Tablo.TabMalAlim.sql.Add('( SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+DurumDogru+'''  ');
      Tablo.TabMalAlim.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+AlimDurumUzerinde+'''  )');
      Tablo.TabMalAlim.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      if not Tablo.TabFaturalar.Eof then
      begin
      Tablo.TabMalAlim.sql.Add('AND  SI.GIRFATURAID ='+IntToStr(Tablo.TabFaturalarID.AsInteger)+'  ');
      end;
      Tablo.TabMalAlim.Open;
      end
    else        //Mal Alim Hatali Kayýtlar
      begin
      Tablo.TabMalAlim.Close;
      Tablo.TabMalAlim.sql.clear;
      Tablo.TabMalAlim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,K.* ');
      Tablo.TabMalAlim.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      Tablo.TabMalAlim.sql.Add('( SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) <> '''+DurumDogru+''' ');
      Tablo.TabMalAlim.sql.Add('AND SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) <> '''+AlimDurumUzerinde+'''  )');
      Tablo.TabMalAlim.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      if not Tablo.TabFaturalar.Eof then
      begin
      Tablo.TabMalAlim.sql.Add('AND  SI.GIRFATURAID ='+IntToStr(Tablo.TabFaturalarID.AsInteger)+'  ');
      end;
      Tablo.TabMalAlim.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 2  then     //Mal iade Malalim hatasýzlar ve satýþý olmayanlar gelecek.
    begin
    if BarBildirim.ActiveGroupIndex = 1 then   //Mal Alým iade için ürünün alýmý yapýlmýþ ve satýlmamaýþ olmasý gerekir.
      begin
      Tablo.TabMalIade.Close;
      Tablo.TabMalIade.sql.clear;
      Tablo.TabMalIade.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM ');
      Tablo.TabMalIade.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      Tablo.TabMalIade.sql.Add('(SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+ DurumDogru+''' ');
      Tablo.TabMalIade.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+AlimDurumUzerinde+''') ');
      Tablo.TabMalIade.sql.Add('AND SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) <> '''+Durumdogru+''' ');
      Tablo.TabMalIade.sql.Add('AND SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) <> '''+SatimDurumOnceden+''' ');
      Tablo.TabMalIade.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      Tablo.TabMalIade.Open;
      end;
    end;




    if BarBildirim.ActiveGroup.SelectedLinkIndex = 4  then
    begin
    if BarBildirim.ActiveGroupIndex = 1 then
      begin
      Tablo.TabSatisIptal.Close;
      Tablo.TabSatisIptal.sql.clear;
      Tablo.TabSatisIptal.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      Tablo.TabSatisIptal.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND  ');
      Tablo.TabSatisIptal.sql.Add('SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) = '''+DurumDogru+''' or SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) = '''+SatimDurumOnceden+''' ');
      Tablo.TabSatisIptal.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      Tablo.TabSatisIptal.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 5  then
    begin
    if BarBildirim.ActiveGroupIndex = 0 then
      begin
      Tablo.TabDeAktivasyon.Close;
      Tablo.TabDeAktivasyon.sql.clear;
      Tablo.TabDeAktivasyon.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      Tablo.TabDeAktivasyon.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND                  ');
      Tablo.TabDeAktivasyon.sql.Add('SUBSTRING(ISNULL(DEAKTIVASYON_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      Tablo.TabDeAktivasyon.sql.Add('AND (SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      Tablo.TabDeAktivasyon.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) ='''+AlimDurumUzerinde+''' ) ');
      Tablo.TabDeAktivasyon.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      Tablo.TabDeAktivasyon.Open;
      end
    else
      begin
      Tablo.TabDeAktivasyon.Close;
      Tablo.TabDeAktivasyon.sql.clear;
      Tablo.TabDeAktivasyon.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      Tablo.TabDeAktivasyon.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND                  ');
      Tablo.TabDeAktivasyon.sql.Add('SUBSTRING(ISNULL(DEAKTIVASYON_DURUM,''''),0,6) <> '''+DurumDogru+'''  ');
      Tablo.TabDeAktivasyon.sql.Add('AND (SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      Tablo.TabDeAktivasyon.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) ='''+AlimDurumUzerinde+''' ) ');
      Tablo.TabDeAktivasyon.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      Tablo.TabDeAktivasyon.Open;
      end;
    end;
    if (BarBildirim.ActiveGroup.SelectedLinkIndex = 7)  then
    begin
      if (BarBildirim.ActiveGroupIndex = 1)  then
      begin
      Tablo.TabUretim.Close;
      Tablo.TabUretim.sql.clear;
      Tablo.TabUretim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,SI.ID,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,SUBSTRING(CONVERT(VARCHAR(10),SI.SONKULLANIM,112),3,6) AS BARKODTARIH,K.URETIM_DURUM,K.URETIM_BILDIRIM_TARIH,K.MALALINANGLN,K.MALSATILANGLN,K.TRANSFERID ');
      Tablo.TabUretim.sql.Add(',SI.URETIMTIPI,SI.URUNCINSI,SI.URETIMTARIHI  FROM KAREKOD K,STOKID SI,FATBASLIK FB   WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      Tablo.TabUretim.sql.Add('SUBSTRING(ISNULL(URETIM_DURUM,''''),0,6) <> ''00000'' ');
      Tablo.TabUretim.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      Tablo.TabUretim.sql.Add('AND  SI.GIRFATURAID ='+IntToStr(Tablo.TabFaturalar.FieldByName('ID').AsInteger)+' ');
      Tablo.TabUretim.Open;
      end else
      begin
      Tablo.TabUretim.Close;
      Tablo.TabUretim.sql.clear;
      Tablo.TabUretim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,SI.ID,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,SUBSTRING(CONVERT(VARCHAR(10),SI.SONKULLANIM,112),3,6) AS BARKODTARIH,K.URETIM_DURUM,K.URETIM_BILDIRIM_TARIH,K.MALALINANGLN,K.MALSATILANGLN,K.TRANSFERID ');
      Tablo.TabUretim.sql.Add(',SI.URETIMTIPI,SI.URUNCINSI,SI.URETIMTARIHI  FROM KAREKOD K,STOKID SI,FATBASLIK FB   WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      Tablo.TabUretim.sql.Add('SUBSTRING(ISNULL(URETIM_DURUM,''''),0,6) = ''00000'' ');
      Tablo.TabUretim.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      Tablo.TabUretim.sql.Add('AND  SI.GIRFATURAID ='+IntToStr(Tablo.TabFaturalar.FieldByName('ID').AsInteger)+' ');
      Tablo.TabUretim.Open;
      end;
    end;
      }
end;

procedure TITSBildirimDlg.ListeleriGuncelleTimerTimer(Sender: TObject);
begin
//
Tablo.TabListeler.Close;
Tablo.TabListeler.Open;


if Tablo.TabListeler.FieldByName('URETIM').Asinteger <>  0 then
BtnUretimBildirimi.Caption := BtnUretimBildirimi.Hint + ' ( '+Tablo.TabListeler.FieldByName('URETIM').AsString+ ' )' ;
if Tablo.TabListeler.FieldByName('PAKET').Asinteger <>  0 then
BtnPaketleme.Caption := BtnPaketleme.Hint + ' ( '+Tablo.TabListeler.FieldByName('PAKET').AsString+ ' )' ;
if Tablo.TabListeler.FieldByName('SATIS').Asinteger <>  0 then
BtnSatis.Caption := BtnSatis.Hint + ' ( '+Tablo.TabListeler.FieldByName('SATIS').AsString+ ' )' ;

//

end;

procedure TITSBildirimDlg.ListeleTusPaketlemeClick(Sender: TObject);
begin
PaketlemListesiGetir;
end;

procedure TITSBildirimDlg.ListeleTusSatinAlmaClick(Sender: TObject);
begin
SatinAlimListesiGetir;
end;



procedure TITSBildirimDlg.MalIadeGonder;
var
 // MalIadeAlim   : TDepoAlimIadeIstek;
  Urun      : TUrun;
  Baslik    : string;
begin
//*yeni servise göre deðiþtirilecek
 { MalIadeAlim := TDepoAlimIadeIstek.Create;
  Tablo.TabMalIade.First;
  while not (Tablo.TabMalIade.Eof) do
     begin
       MalIadeAlim.FR := GLNFirma;
       MalIadeAlim._TO :=  Tablo.TabMalIade.FieldByName('MALALINANGLN').AsString;
       MalIadeAlim.BelgeDD := Tablo.TabMalIade.FieldByName('FATURATARIH').AsDateTime;
       MalIadeAlim.BelgeDN := Tablo.TabMalIade.FieldByName('FATURANO').AsString;
       Baslik :=  Tablo.TabMalIade.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabMalIade.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabMalIade.FieldByName('FATURANO').AsString;
        if ColSecMalIade.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabMalIade.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabMalIade.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabMalIade.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabMalIade.FieldByName('SONKULLANIM').AsDateTime;
        MalIadeAlim.Urunler.Add(Urun);
        end;
     Tablo.TabMalIade.Next;
     if (Baslik =  Tablo.TabMalIade.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabMalIade.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabMalIade.FieldByName('FATURANO').AsString)
     or (Tablo.TabMalIade.Eof) then
     begin
     XMLGelenIsle(XMLGonder(MalIadeAlim),MalIadeAlim.Urunler);
     MalIadeAlim.Free;
     MalIadeAlim := TDepoAlimIadeIstek.Create;
     end;
     end;
     MalIadeAlim.Free;
  ShowMessage(Its_Islem_Gonderildi);  }
end;

procedure TITSBildirimDlg.PaketAlim;
begin
  if BildirilmisPaketlerDlg = nil then
    Application.CreateForm(TBildirilmisPaketlerDlg, BildirilmisPaketlerDlg);


  BildirilmisPaketlerDlg.ShowModal;
end;

procedure TITSBildirimDlg.PaketDogruBildirimClick(Sender: TObject);
begin
BildirimGuncelle(2,TabPaketlemeListesi.FieldByName('FATBASID').AsInteger,9);
 PaketlemListesiGetir;
end;

procedure TITSBildirimDlg.ServisGetir;
begin
  if ReferansDlg = nil then
    Application.CreateForm(TReferansDlg, ReferansDlg);
  ReferansDlg.ShowModal;
end;


procedure TITSBildirimDlg.PaketlemListesiGetir;
begin
TabPaketlemeListesi.Close;
TabPaketlemeListesi.SQL.Clear;
TabPaketlemeListesi.SQL.Text:= 'SELECT IU.*,RI.ANAHTAR AS BELGE,R.FIRMA,ISNULL(IB.DURUM,1) AS DURUM  FROM ITS_PAKET IU ' +
                            'INNER JOIN GENINI RI ON RI.BOLUM = -1005 AND RI.DEGER=IU.BELGETURU ' +
                            'INNER JOIN REHBER R ON R.ID = IU.REHBERID  ' +
                            'LEFT OUTER JOIN ITS_BILDIRIM IB ON IB.YERI=2 AND IB.YERID=IU.FATBASID '+
                            'WHERE IU.TARIH BETWEEN '''+FormatDateTime('yyyy-MM-dd 00:00:00',DatePaketlemeBaslangic.Date)+''' AND '''+FormatDateTime('yyyy-MM-dd 23:59:59',DatePaketlemeBitis.Date)+''' ORDER BY IU.TARIH DESC ';
TabPaketlemeListesi.Open;
end;

procedure TITSBildirimDlg.PaketTimerTimer(Sender: TObject);
begin


PaketDetay('',GLNFirma,True,Now-100,Now);
PaketDetay(GLNFirma,'',True,Now-100,Now);

end;

procedure TITSBildirimDlg.PcBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=TvSatis.DataController;
end;

procedure TITSBildirimDlg.PcListelerPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin

  case NewPage.Tag of
  0:UretimListesiGetir;
  end;

 {case ALink.Item.Tag of
    0:begin   TsDogrulamaBildirim.Show; ListeleriGetir(); end;
    1:begin  TsMalAlim.Show; ListeleriGetir();    end;
    2:begin TsMalIade.Show; ListeleriGetir();    end;
    3:begin  TsSatisBildirim.Show; ListeleriGetir(); end;
    4:begin  TsSatisIptal.Show; ListeleriGetir();  end;
    5:begin  TsDeAktivasyon.Show; ListeleriGetir(); end;
    6:begin TsGecmis.Show;GecmisGetir(); end;
    7:begin TsUretim.Show;ListeleriGetir(); end
  else TsBos.Show;
  end;   }

end;

procedure TITSBildirimDlg.SatinAlimListesiGetir;
begin
TabSatinAlmaListesi.Close;
TabSatinAlmaListesi.SQL.Text:= ' SELECT F.ID AS BELGEDETAYID,FB.TARIH,FB.FATURANO AS BELGENO,F.ID AS BELGEDETAYID,FB.ID AS BELGEBASID,FB.REHBERID,R.FIRMA,RI.ANAHTAR AS BELGETIPI,S.STOKADI,F.ADET,FB.TUR,F.URUNID,B.BARKOD,B.ID AS BARKODID ' +
                           ' ,ISNULL(IB.DURUM,1) AS DURUM  FROM  FATBASLIK FB  ' +
 			                     ' INNER JOIN FATURA F ON F.FATBASID=FB.ID AND F.IZLEME = 3 '+
                           ' INNER JOIN REHBER R ON R.ID = F.REHBERID           '+
                           ' LEFT OUTER JOIN ITS_BILDIRIM IB ON IB.YERI = 3 AND IB.YERID = FB.ID '+
                           ' INNER JOIN GENINI RI ON RI.BOLUM = -1005 AND RI.DEGER=FB.TUR AND RI.DIL=-1 '+
                           ' INNER JOIN STOKBARKOD B ON B.STOKID = F.URUNID AND B.VARSAYILAN=1           '+
                           ' INNER JOIN STOKLAR S ON S.ID = F.URUNID '+
                           ' WHERE (FB.TUR = 11 OR FB.TUR = 12)     '+
                           ' AND R.GRUP=320 AND FB.TARIH BETWEEN '''+FormatDateTime('yyyy-MM-dd 00:00:00',DateSatinAlmaBaslangic.Date)+''' AND '''+FormatDateTime('yyyy-MM-dd 23:59:59',DateSatinAlmaBitis.Date)+''' ';

TabSatinAlmaListesi.Open;
end;



procedure TITSBildirimDlg.SatisIptalListesiGetir;
begin
TabSatisIptalListesi.Close;
TabSatisIptalListesi.SQL.Text:= ' SELECT F.ID AS BELGEDETAYID,FB.TARIH,FB.FATURANO AS BELGENO,FB.ID AS BELGEBASID,'+
                           ' FB.REHBERID,R.FIRMA,RI.ANAHTAR AS BELGETIPI,S.STOKADI,F.MIKTAR AS ADET,FB.TUR,F.URUNID,B.BARKOD,B.ID AS BARKODID ' +
                           ' ,ISNULL(IB.DURUM,1) AS DURUM  FROM  FATBASLIK FB  ' +
 			                     ' INNER JOIN FATURA F ON F.FATBASID=FB.ID AND F.IZLEME = 3 '+
                           ' INNER JOIN REHBER R ON R.ID = F.REHBERID           '+
                           ' LEFT OUTER JOIN ITS_BILDIRIM IB ON IB.YERI = 3 AND IB.YERID = FB.ID '+
                           ' INNER JOIN GENINI RI ON RI.BOLUM = -1005 AND RI.DEGER=FB.TUR AND RI.DIL=-1 '+
                           ' INNER JOIN STOKBARKOD B ON B.STOKID = F.URUNID AND B.VARSAYILAN=1           '+
                           ' INNER JOIN STOKLAR S ON S.ID = F.URUNID '+
                           ' WHERE (FB.TUR = 11 OR FB.TUR = 12)     '+
                           ' AND R.GRUP=120 AND FB.TARIH BETWEEN '''+FormatDateTime('yyyy-MM-dd 00:00:00',DateSatisIptalBaslangic.Date)+''' AND '''+FormatDateTime('yyyy-MM-dd 23:59:59',DateSatisIptalBitis.Date)+''' ';

TabSatisIptalListesi.Open;
end;

procedure TITSBildirimDlg.SatisListesiGetir;
begin

TabSatisListesi.Close;
TabSatisListesi.Parameters.ParamByName('TARIH1').Value:= FormatDateTime('yyyy-MM-dd',DateSatisBaslangic.Date); //FormatDateTime('yyyy-mm-dd 00:00:00',DateUretimBaslangic.Date);
TabSatisListesi.Parameters.ParamByName('TARIH2').Value:= FormatDateTime('yyyy-MM-dd',DateSatisBitis.Date); //FormatDateTime('yyyy-mm-dd 23:59:59',DateUretimBitis.Date);
TabSatisListesi.Open;
end;

procedure TITSBildirimDlg.SilTusPaketlemeClick(Sender: TObject);
begin
  Tablo.Query2.Close;
  Tablo.Query2.SQL.text := 'SELECT ID FROM STOKID WHERE PAKETID = '+TabPaketlemeListesi.FieldByName('ID').AsString+' ';
  Tablo.Query2.Open;
  if Tablo.Query2.RecordCount = 0 then
  begin
  Tablo.Query1.Close;
  Tablo.Query1.sql.Text:= 'UPDATE STOKID SET PAKETID = 0 , TASIMA_BIRIMI_ID = 0 WHERE PAKETID = '+TabPaketlemeListesi.FieldByName('ID').AsString+'  ';
  Tablo.Query1.ExecSQL;
  Tablo.Query1.Close;
  Tablo.Query1.sql.Text:= 'DELETE FROM ITS_TASIMA_BIRIMI WHERE PAKETID = '+TabPaketlemeListesi.FieldByName('ID').AsString+'  ';
  Tablo.Query1.ExecSQL;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.text:='DELETE FROM ITS_PAKET WHERE ID = '+TabPaketlemeListesi.FieldByName('ID').AsString+' ' ;
  Tablo.Query1.ExecSQL;
  end else
      begin
        ShowMessage('Paket içersinde ürünler var silinemez.Ýlk olarak ürünleri paketten çýkartýnýz.');
      end;
  PaketlemListesiGetir;
end;

procedure TITSBildirimDlg.TbKarekodYazClick(Sender: TObject);
var F : TextFile;
  satiretiketsayisi,fi,etiketbitis: integer;
  sablon,tmpStr,basilacak : String;
  text_01,text_17,text_10 ,strUrunAdi: string;
  baskihizi,yuklemesuresi ,MaksEtiketSay: integer;
  DosyaYolu : string;
  Dosya,Baslangic ,Govde ,Son : TStringList;
  I: Integer;
  sonkayitlar : Boolean;
begin
//  ComPort1.Open;
  DosyaYolu:='C:\Gensoft\Delphi\Finans\ITS\karekod.txt';
  if not FileExists(DosyaYolu) then
  begin
    Application.MessageBox('Þablon dosyasý belirtilmemiþ yada doðru dosya yolunu göstermiyor.','DÝKKAT',MB_ICONERROR);
    abort;
  end;
  //TabUretim.First;
  Govde := TStringList.Create;
  Dosya := TStringList.Create;
  Dosya.Add('{D0420,1000,0400|}');
  while not Tablo.TabUretim.Eof do
  begin
   if (Tablo.TabUretim.RecNo mod 5 )= 1 then
   begin
   Govde.Add('{XB00;0050,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0050,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0075,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0100,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0125,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;

   if (Tablo.TabUretim.RecNo mod 5 )= 2 then
   begin
   Govde.Add('{XB00;0250,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0250,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0275,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0300,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0325,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;

   if (Tablo.TabUretim.RecNo mod 5 )= 3 then
   begin
   Govde.Add('{XB00;0450,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0450,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0475,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0500,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0525,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;
   if (Tablo.TabUretim.RecNo mod 5 )= 4 then
   begin
   Govde.Add('{XB00;0650,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0650,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0675,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0700,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0725,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');
   end;
   if (Tablo.TabUretim.RecNo mod 5 )= 0 then
   begin
   Govde.Add('{XB00;0850,0050,Q,20,05,05,0|}');
   Govde.Add('{RB00;>101'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'21'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'>117'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'10'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0850,0150,07,07,H,11,B=(10)'+Tablo.TabUretim.FieldByName('LOTNO').asstring+'|}');
   Govde.Add('{PC01;0875,0150,07,07,H,11,B=(17)'+Tablo.TabUretim.FieldByName('BARKODTARIH').asstring+'|}');
   Govde.Add('{PC01;0900,0150,07,07,H,11,B=(21)'+Tablo.TabUretim.FieldByName('SIRANO').asstring+'|}');
   Govde.Add('{PC01;0925,0150,07,07,H,11,B=(01)'+Tablo.TabUretim.FieldByName('URUNBARKOD').asstring+'|}');

   Dosya.Add('{C|}');
      for I := 0 to Govde.Count - 1 do
      begin
      Dosya.Add(Govde[I]);
      end;
   Dosya.Add('');
   Dosya.Add('{XS;I,0001,0002C5200|}');
   Govde.clear;
    //Dosya.Clear;
   end;
   if Tablo.TabUretim.RecordCount=Tablo.TabUretim.RecNo    then
   begin
   Dosya.Add('{C|}');
      for I := 0 to Govde.Count - 1 do
      begin
      Dosya.Add(Govde[I]);
      end;
   Dosya.Add('');
   Dosya.Add('{XS;I,0001,0002C5200|}');
   Govde.clear;
   end;
   Tablo.TabUretim.Next;
  end;
   DeleteFile(DosyaYolu);
   Dosya.SaveToFile(DosyaYolu);
   ShellExecute(Handle, 'open', PChar('d:\yazdir.bat'), nil, nil, SW_HIDE);
end;


procedure TITSBildirimDlg.TvAlimCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if MalAlimDlg = nil then
    Application.CreateForm(TMalAlimDlg, MalAlimDlg);
  MalAlimDlg.ShowModal;
end;

procedure TITSBildirimDlg.TvSatisListesiCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if SatisDlg = nil then
    Application.CreateForm(TSatisDlg, SatisDlg);
  SatisDlg.ShowModal;
  SatisListesiGetir;

end;

procedure TITSBildirimDlg.TvUretimListesiCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if UretimDlg = nil then
    Application.CreateForm(TUretimDlg, UretimDlg);
  UretimDlg.ShowModal;
  UretimListesiGetir;
end;

{LPT ye göndermek için}

//  AssignFile(F,'LPT' +'1'); // '1'--paralel port numarasý
//  // AssignFile(F,'C:\BIN\A.TXT');
//  {$I-}
//  Rewrite(F);
//  {$I+}
//  Write(F,sablon);
//  CloseFile(F);

//  ComPort1.Close;
//  FANAFORM.Yazdir(sablon,iYaziciId);





procedure TITSBildirimDlg.UretimListesiGetir;
begin
TabUretimListesi.Close;
TabUretimListesi.SQL.Clear;
TabUretimListesi.SQL.Text:= 'SELECT IU.*,RI.ANAHTAR AS BELGE,R.FIRMA,S.STOKADI,B.BARKOD,(SELECT TOP 1 IB.DURUM FROM ITS_BILDIRIM IB WHERE IB.YERI=1 AND IB.YERID=IU.ID ORDER BY ID DESC) AS DURUM,IU.DEPOID FROM ITS_URETIM IU ' +
                            'INNER JOIN GENINI RI ON RI.BOLUM = -1005 AND RI.DEGER=IU.BELGETURU AND DIL=-1 ' +
                            'INNER JOIN REHBER R ON R.ID = IU.REHBERID  ' +
                            'INNER JOIN STOKLAR S ON S.ID = IU.URUNID   ' +
                            'INNER JOIN STOKBARKOD B ON B.ID = IU.BARKODID  ' +
                            'WHERE IU.TARIH BETWEEN '''+FormatDateTime('yyyy-MM-dd 00:00:00',DateUretimBaslangic.Date)+''' AND '''+FormatDateTime('yyyy-MM-dd 23:59:59',DateUretimBitis.Date)+''' ';
TabUretimListesi.Open;
end;

procedure TITSBildirimDlg.UrunListe;
begin
    if UrunListeDlg = nil then
    Application.CreateForm(TUrunListeDlg, UrunListeDlg);

    UrunListeDlg.BtnPaketeEkle.Visible:= False;
      UrunListeDlg.ShowModal;
end;

procedure TITSBildirimDlg.ViewSatisIptalCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if SatisIptalDlg = nil then
    Application.CreateForm(TSatisIptalDlg, SatisIptalDlg);
  SatisIptalDlg.ShowModal;
  SatisIptalListesiGetir;
end;

procedure TITSBildirimDlg.YeniTusPaketlemeClick(Sender: TObject);
begin
  Tablo.BelgeListesiInit('Paketleme');
  PaketlemListesiGetir;
end;

procedure TITSBildirimDlg.YeniTusUretimClick(Sender: TObject);
begin
  Tablo.BelgeListesiInit('Üretim');
  UretimListesiGetir;

end;

end.


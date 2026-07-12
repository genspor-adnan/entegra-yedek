unit uEvrakListeFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 06/01/2010 13:51:10 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxTLData, cxDBTL, cxTL, Fetautil,
  cxLookAndFeelPainters, cxButtons, DB, UFDCompatHelpers, ToolWin, ExtCtrls,
  UDokumanWizard,
  uEvrakAramaFrame, cxStyles, dxSkinsCore, UBankaKredileriListeTanimlariFrame,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  UFrameYoneticisi, cxImage, JvComponentBase, JvDragDrop, cxGridCardView,
  cxGridDBCardView, cxImageComboBox, cxDropDownEdit, UKodAgaci, cxHyperLinkEdit,
  cxSplitter, cxDBLabel, cxLabel, cxDBEdit, cxCheckBox,DateUtils, JvTimer,
  cxLookAndFeels, cxNavigator, cxGridCustomLayoutView, Vcl.OleCtnrs, dxSkinLiquidSky,
  Vcl.ImgList, PngImageList, dxBarBuiltInMenu, cxPC, cxPCdxBarPopupMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxCalendar, dxDateRanges, dxScrollbarAnnotations,
  System.ImageList, System.Actions, Vcl.ActnList, JvExComCtrls, JvComCtrls, cxGridBandedTableView,
  cxGridDBBandedTableView, cxGridCustomPopupMenu, cxGridPopupMenu;

type
  TEvrakListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsDokuman: TDataSource;
    DOKUMAN: TFDQuery;
    GridEvrak: TcxGrid;
    EvrakTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    FormAcTus: TToolButton;
    SilTus: TToolButton;
    PopupMenu1: TPopupMenu;
    KesMenu: TMenuItem;
    KopyalaMenu: TMenuItem;
    YapistirMenu: TMenuItem;
    KesTus: TToolButton;
    KopyalaTus: TToolButton;
    YapistirTus: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    VerTus: TToolButton;
    TaraTus: TToolButton;
    ToolButton9: TToolButton;
    N2: TMenuItem;
    EPostaMenu: TMenuItem;
    VerMenu: TMenuItem;
    N3: TMenuItem;
    EPostaAl1: TMenuItem;
    GridEvrakLevel1: TcxGridLevel;
    GridEvrakDBCardView1: TcxGridDBCardView;
    GridEvrakDBCardView1AD: TcxGridDBCardViewRow;
    GridEvrakDBCardView1EXT: TcxGridDBCardViewRow;
    SQLMemo: TMemo;
    Yeni1: TMenuItem;
    ara1: TMenuItem;
    N4: TMenuItem;
    SilMenu: TMenuItem;
    DegisMenu: TMenuItem;
    N5: TMenuItem;
    EPostaTus: TToolButton;
    BurayaKisayololusturMenu: TMenuItem;
    Baskayerekisayololustur1: TMenuItem;
    SQLMemo2: TMemo;
    popcop: TPopupMenu;
    Sil1: TMenuItem;
    GeriYkle1: TMenuItem;
    GeriDnmBoalt1: TMenuItem;
    Yetkilendirme1: TMenuItem;
    cxSplitter1: TcxSplitter;
    DtsKeywords: TDataSource;
    TabYetki: TFDQuery;
    DtsYetki: TDataSource;
    TabRevize: TFDQuery;
    DtsRevize: TDataSource;
    TabIlgili: TFDQuery;
    TabIlgiliDOKUMANILGILIID: TIntegerField;
    TabIlgiliAD: TWideStringField;
    TabIlgiliKLASOR: TWideStringField;
    DtsIlgili: TDataSource;
    Gortus: TToolButton;
    DuyuruOlarakYaynla1: TMenuItem;
    JvTimer1: TJvTimer;
    DegistirTus: TToolButton;
    Gr1: TMenuItem;
    Deitir1: TMenuItem;
    ToolButton1: TToolButton;
    PNGImageList1: TPngImageList;
    PageDokuman: TcxPageControl;
    TabSheetGenel: TcxTabSheet;
    PanelGenel: TPanel;
    Label2: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    Label1: TcxLabel;
    cxLabel10: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxDBLabel5: TcxDBLabel;
    LblYon: TcxDBLabel;
    LabelMasrafMerkezi: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel13: TcxLabel;
    LblKurum: TcxDBLabel;
    LblBolum: TcxDBLabel;
    LblLokasyon: TcxDBLabel;
    LblGizlilik: TcxDBLabel;
    cxDBLabel8: TcxDBLabel;
    cxLabel3: TcxLabel;
    LblSorumlu: TcxDBLabel;
    cxLabel12: TcxLabel;
    LblBoyut: TcxDBLabel;
    cxLabel14: TcxLabel;
    LblArsiv: TcxDBLabel;
    TabSheetRevize: TcxTabSheet;
    GridAktDetay: TcxGrid;
    GridRevizeView: TcxGridDBTableView;
    GridRevizeViewID: TcxGridDBColumn;
    GridRevizeViewSURUM: TcxGridDBColumn;
    GridRevizeViewEKLEMETARIHI: TcxGridDBColumn;
    GridRevizeViewACIKLAMA: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TabSheetIlgili: TcxTabSheet;
    GridIlgili: TcxGrid;
    GridIlgiliView: TcxGridDBTableView;
    GridIlgiliViewDOKUMANILGILIID: TcxGridDBColumn;
    GridIlgiliViewAD: TcxGridDBColumn;
    GridIlgiliViewKLASOR: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    TabSheetYetki: TcxTabSheet;
    GridYetki: TcxGrid;
    GridYetkiDBTableView1: TcxGridDBTableView;
    GridYetkiDBTableView1Tur: TcxGridDBColumn;
    GridYetkiDBTableView1KULLANICI: TcxGridDBColumn;
    GridYetkiDBTableView1GOR: TcxGridDBColumn;
    GridYetkiDBTableView1EKLE: TcxGridDBColumn;
    GridYetkiDBTableView1DEGISTIR: TcxGridDBColumn;
    GridYetkiDBTableView1SIL: TcxGridDBColumn;
    GridYetkiLevel1: TcxGridLevel;
    GridRevizeViewREHBERID: TcxGridDBColumn;
    GridRevizeViewONAY: TcxGridDBColumn;
    SQLMemo_SAP: TMemo;
    SQLMemo2_SAP: TMemo;
    cxLabel1: TcxLabel;
    cxDBLabel3: TcxDBLabel;
    GridRevizeViewONAYLAYACAK: TcxGridDBColumn;
    ActionListEvrak: TActionList;
    actGelen_UzerindeCalistigimYeniEvrak: TAction;
    actGelen_UzerindeCalistigimHavaleEt: TAction;
    actGelen_UzerindeCalistigimDosyayaKaldir: TAction;
    actGelen_UzerindeCalistigimIptalEt: TAction;
    act_ListeYazdir: TAction;
    act_EvrakBilgi_Altta: TAction;
    act_EvrakBilgi_Sagda: TAction;
    act_EvrakBilgi_Gizle: TAction;
    act_OtomatikTeslimAl: TAction;
    act_Yardim: TAction;
    actGelen_TeslimAl: TAction;
    actGelen_TeslimAlBarkodile: TAction;
    actGelen_TeslimALiptalEt: TAction;
    actGelen_TeslimAlGeriGonder: TAction;
    actGelen_HavaleEtigimGeriAl: TAction;
    actGelen_DosyaladigimGeriAl: TAction;
    actGelen_IptalEttigimGeriAl: TAction;
    actGiden_UzerindeCalisitimYeniEvrak: TAction;
    actGiden_UzerindeCalistigimImzayaGonder: TAction;
    actGiden_UzerindeCalistigimDosyayaKaldir: TAction;
    actGiden_UzerindeCalistigimIptalet: TAction;
    actGiden_UzerindeCalistigimGeriGonder: TAction;
    actGiden_UzerindeCalistigimEvrakNoAl: TAction;
    actGiden_UzerindeCalistigimEEvrakGonder: TAction;
    actGiden_UzerindeCalistigimEImzala: TAction;
    actGiden_UzerindeCalistigimimzala: TAction;
    actGiden_UzerindeCalistigimEditor: TAction;
    PanelTop: TPanel;
    PanelMenu: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    PageControlMenu: TJvPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    buttonGelenYeniEvrak: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    popupEvrakBilgileri: TPopupMenu;
    EvrakBilgisiAltta1: TMenuItem;
    EvrakBilgisiSada1: TMenuItem;
    EvrakBilgisiGizle1: TMenuItem;
    popupAyarlar: TPopupMenu;
    actOtomatikTeslimAl1: TMenuItem;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    butttonGidenYeniEvrak: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    actTanimlar: TAction;
    Button5: TButton;
    Button16: TButton;
    Button20: TButton;
    actGiden_HavaleEttiklerimGeriAl: TAction;
    Button21: TButton;
    actGiden_DosyaladigimGeriAl: TAction;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EvrakTviewKLASORID: TcxGridDBColumn;
    EvrakTviewKLASORUSTID: TcxGridDBColumn;
    EvrakTviewKLASORAD: TcxGridDBColumn;
    EvrakTviewID: TcxGridDBColumn;
    EvrakTviewBELGENO: TcxGridDBColumn;
    EvrakTviewDURUM: TcxGridDBColumn;
    EvrakTviewAD: TcxGridDBColumn;
    EvrakTviewKONU: TcxGridDBColumn;
    EvrakTviewTUR: TcxGridDBColumn;
    EvrakTviewKLASOR: TcxGridDBColumn;
    EvrakTviewESKIKLASOR: TcxGridDBColumn;
    EvrakTviewEKLEYEN: TcxGridDBColumn;
    EvrakTviewEKLEMETARIHI: TcxGridDBColumn;
    EvrakTviewGIZLILIKDERECESI: TcxGridDBColumn;
    EvrakTviewTARIH: TcxGridDBColumn;
    EvrakTviewGELEN_EVRAK_NUMARASI: TcxGridDBColumn;
    EvrakTviewEVRAK_DOSYA_KODU: TcxGridDBColumn;
    EvrakTviewEVRAK_ICERIGI: TcxGridDBColumn;
    EvrakTviewACIKLAMA: TcxGridDBColumn;
    EvrakTviewIMAJ_ID: TcxGridDBColumn;
    EvrakTviewVARSAYILAN: TcxGridDBColumn;
    EvrakTviewIMAJ_REHBERID: TcxGridDBColumn;
    EvrakTviewICDIS: TcxGridDBColumn;
    EvrakTviewIMAJ_YERI: TcxGridDBColumn;
    EvrakTviewIMAJ_YER_ID: TcxGridDBColumn;
    EvrakTviewIMAJ_DURUM: TcxGridDBColumn;
    EvrakTviewIMAJ_BELGENO: TcxGridDBColumn;
    EvrakTviewIMAJ_SURUM: TcxGridDBColumn;
    EvrakTviewIMAJ_TUR: TcxGridDBColumn;
    EvrakTviewIMAJ_BELGEADI: TcxGridDBColumn;
    EvrakTviewIMAJ_BELGE: TcxGridDBColumn;
    EvrakTviewIMAJ_ACIKLAMA: TcxGridDBColumn;
    EvrakTviewIMAJ_EKLEYEN: TcxGridDBColumn;
    EvrakTviewIMAJ_EKLEMETARIHI: TcxGridDBColumn;
    EvrakTviewIMAJ_DEGISTIREN: TcxGridDBColumn;
    EvrakTviewIMAJ_DEGISTIRMETARIHI: TcxGridDBColumn;
    EvrakTviewIMAJ_SUBEID: TcxGridDBColumn;
    EvrakTviewIMAJ_ONAY: TcxGridDBColumn;
    EvrakTviewIMAJ_BELGETURU: TcxGridDBColumn;
    EvrakTviewIMAJ_BOYUT: TcxGridDBColumn;
    EvrakTviewIMAJ_ONAYLAYACAK: TcxGridDBColumn;
    EvrakTviewGIDECEGI_YER: TcxGridDBColumn;
    EvrakBandedView: TcxGridDBBandedTableView;
    EvrakBandedViewKLASORID: TcxGridDBBandedColumn;
    EvrakBandedViewKLASORAD: TcxGridDBBandedColumn;
    EvrakBandedViewID: TcxGridDBBandedColumn;
    EvrakBandedViewBELGENO: TcxGridDBBandedColumn;
    EvrakBandedViewDURUM: TcxGridDBBandedColumn;
    EvrakBandedViewAD: TcxGridDBBandedColumn;
    EvrakBandedViewKONU: TcxGridDBBandedColumn;
    EvrakBandedViewTUR: TcxGridDBBandedColumn;
    EvrakBandedViewKLASOR: TcxGridDBBandedColumn;
    EvrakBandedViewESKIKLASOR: TcxGridDBBandedColumn;
    EvrakBandedViewEKLEYEN: TcxGridDBBandedColumn;
    EvrakBandedViewEKLEMETARIHI: TcxGridDBBandedColumn;
    EvrakBandedViewGIZLILIKDERECESI: TcxGridDBBandedColumn;
    EvrakBandedViewTARIH: TcxGridDBBandedColumn;
    EvrakBandedViewGELEN_EVRAK_NUMARASI: TcxGridDBBandedColumn;
    EvrakBandedViewEVRAK_DOSYA_KODU: TcxGridDBBandedColumn;
    EvrakBandedViewEVRAK_ICERIGI: TcxGridDBBandedColumn;
    EvrakBandedViewACIKLAMA: TcxGridDBBandedColumn;
    EvrakBandedViewGIDECEGI_YER: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_ID: TcxGridDBBandedColumn;
    EvrakBandedViewVARSAYILAN: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_REHBERID: TcxGridDBBandedColumn;
    EvrakBandedViewICDIS: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_YERI: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_YER_ID: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_DURUM: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_BELGENO: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_SURUM: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_TUR: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_BELGEADI: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_BELGE: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_ACIKLAMA: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_EKLEYEN: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_EKLEMETARIHI: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_DEGISTIRMETARIHI: TcxGridDBBandedColumn;
    EvrakBandedViewIMAJ_BELGETURU: TcxGridDBBandedColumn;
    PopupGelenEvrak: TPopupMenu;
    PopupGidenEvrak: TPopupMenu;
    YeniEvrak1: TMenuItem;
    dmEvrakModuleImagesEvrak1: TMenuItem;
    HavaleEt1: TMenuItem;
    DosyayaKaldr1: TMenuItem;
    ptalEt1: TMenuItem;
    N1: TMenuItem;
    eslimAl1: TMenuItem;
    BarkodleAl1: TMenuItem;
    ptalEt2: TMenuItem;
    GeriGonder1: TMenuItem;
    GeriGonder2: TMenuItem;
    HavaleGeriAl1: TMenuItem;
    DosyadanGeriAl1: TMenuItem;
    ptaliGeriAl1: TMenuItem;
    mzayaGnder1: TMenuItem;
    DosyayaKaldr2: TMenuItem;
    ptalEt3: TMenuItem;
    EvrakNoAl1: TMenuItem;
    EEvrakGnder1: TMenuItem;
    actGidenUzerindeCalistigimimzala1: TMenuItem;
    Editr1: TMenuItem;
    GeriGonder3: TMenuItem;
    N6: TMenuItem;
    HavaleGeriAl2: TMenuItem;
    DosyadanGeriAl2: TMenuItem;
    N7: TMenuItem;
    actGiden_IptalEttiklerimGeriAl: TAction;
    ptalEttiklerimiGeriAl1: TMenuItem;
    actGiden_Gor: TAction;
    Gr2: TMenuItem;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YeniTusClick(Sender: TObject);
    procedure FormAcTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DOKUMANBeforeOpen(DataSet: TDataSet);
    procedure YenileTusClick;
    procedure YenileKlasorClick(KlasorId: Integer);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure EvrakTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure EvrakTviewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure KesMenuClick(Sender: TObject);
    procedure YapistirMenuClick(Sender: TObject);
    procedure TaraTusClick(Sender: TObject);
    procedure EPostaMenuClick(Sender: TObject);
    procedure VerTusClick(Sender: TObject);
    procedure EvrakTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure EvrakTviewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DOKUMANAfterOpen(DataSet: TDataSet);
    procedure BurayaKisayololusturMenuClick(Sender: TObject);
    procedure Baskayerekisayololustur1Click(Sender: TObject);
    procedure EPostaAl1Click(Sender: TObject);
    procedure DOKUMANAfterScroll(DataSet: TDataSet);
    procedure GeriYkle1Click(Sender: TObject);
    procedure GeriDnmBoalt1Click(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure KopyalaMenuClick(Sender: TObject);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure EvrakTviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure EvrakTviewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure Yetkilendirme1Click(Sender: TObject);
    procedure GortusClick(Sender: TObject);
    procedure DuyuruOlarakYaynla1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure TabKlasorlerAfterScroll(DataSet: TDataSet);
    procedure UstuneKaydettusClick(Sender: TObject);
    procedure DegistirTusClick(Sender: TObject);
    procedure EvrakTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure PageDokumanChange(Sender: TObject);
    procedure act_EvrakBilgi_GizleExecute(Sender: TObject);
    procedure act_EvrakBilgi_SagdaExecute(Sender: TObject);
    procedure act_EvrakBilgi_AlttaExecute(Sender: TObject);
    procedure act_OtomatikTeslimAlExecute(Sender: TObject);
    procedure act_ListeYazdirExecute(Sender: TObject);
    procedure act_YardimExecute(Sender: TObject);
    procedure actGelen_UzerindeCalistigimYeniEvrakExecute(Sender: TObject);
    procedure actGelen_UzerindeCalistigimHavaleEtExecute(Sender: TObject);
    procedure actGelen_UzerindeCalistigimDosyayaKaldirExecute(Sender: TObject);
    procedure actGelen_UzerindeCalistigimIptalEtExecute(Sender: TObject);
    procedure actGelen_TeslimAlExecute(Sender: TObject);
    procedure actGelen_TeslimAlBarkodileExecute(Sender: TObject);
    procedure actGelen_TeslimALiptalEtExecute(Sender: TObject);
    procedure actGelen_TeslimAlGeriGonderExecute(Sender: TObject);
    procedure actGelen_HavaleEtigimGeriAlExecute(Sender: TObject);
    procedure actGelen_DosyaladigimGeriAlExecute(Sender: TObject);
    procedure actGelen_IptalEttigimGeriAlExecute(Sender: TObject);
    procedure actGiden_UzerindeCalisitimYeniEvrakExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimImzayaGonderExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimDosyayaKaldirExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimIptaletExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimGeriGonderExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimEvrakNoAlExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimEEvrakGonderExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimEImzalaExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimimzalaExecute(Sender: TObject);
    procedure actGiden_UzerindeCalistigimEditorExecute(Sender: TObject);
    procedure actTanimlarExecute(Sender: TObject);
    procedure actGiden_DosyaladigimGeriAlExecute(Sender: TObject);
    procedure actGiden_HavaleEttiklerimGeriAlExecute(Sender: TObject);
    procedure actGiden_GorUpdate(Sender: TObject);
    procedure actGiden_GorExecute(Sender: TObject);
  private
    { Private declarations }
    //TutulanYer, TutulanID, TutulanKisayol: Integer;
    FFrameBilgi: TIcerikFrameBilgi;
    FArama: TEvrakAramaFrame;
    KodAgaciKlasorDlg: TKodAgaciDlg;
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
    function GetFrameBilgi: TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue: TIcerikFrameBilgi);
    procedure SetArama(const Value: TEvrakAramaFrame);
    procedure PageControlDoldur;
    Procedure ActMenuAyarla( _Tag : integer; _Visible : boolean);
    procedure ActSayfaAyarla( _KlasorID : integer);
  public
    SecDokID: array of Integer; // sonişlem:kes=1,kopyala=2,Yapıştır=0;
    SonIslem: Integer;
    EvrakTuru : integer;
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
    { Public declarations }

    Constructor Create(AOwner : TComponent); override;                 {m.y Özel işlerimiz olacaktır}
  published
    property Arama: TEvrakAramaFrame read FArama write SetArama;
  end;

function GetEvrakTurGelenGiden(_EvrakKlasorTur : integer) : integer;
procedure InitGENINI_EvrakTanimlari();


const
   cGelenEvrak            =        1;
   cButunEvraklar         =      101;
   cUzerindeCalistiklarim =      102;
   cTeslimAlmadiklarim    =      103;
   cHavaleEttiklerim      =      104;
   cDosyayaKaldirdiklarim =      105;
   cIptalEttiklerim       =      106;
   cGidenEvrak            =        2;
   cImzadaBekleyenler     =      103;
   cKisiselEvrak          =        3;
   cKurumsalEvrak         =        4;

implementation

uses UAnaForm, FetaKurulusSiniflari, FetaClassExtensions,
  PrjConst, Utablo, IdGlobalProtocols, UMailKisiBulma,
  uEvrakModule, UVeriMotor,
  {$IFDEF 3Dparty}
  uUtility_my,
  Logix.Logger,
  uDebugUtils,

  {$ENDIF 3Dparty}
  uGelenEvrakKayit,
  uGidenEvrakKayit,
  uEvrak_Tanimlar,
  UBinarySave, UGirisKutusuEx, URehberAramaEkrani, UDokumanYetki,LocOnFly;
{$R *.dfm}

{ TEvrakListeFrame }
var
  DYetkisonuc: DokumanYetkiSonuc;
  //AlanlarOlusturuldu : boolean;


procedure InitGENINI_EvrakTanimlari();

  function SqlOlustur( _Bolum : integer; _Deger : integer; _Anahtar : string) : string;
  begin
     Result :=
       'BEGIN '+sLineBreak +
       '        declare @vBolum int = '+_Bolum.ToString+' '+sLineBreak +
       '        declare @vDeger int = '+_Deger.ToString+' '+sLineBreak +
       '        declare @vData nvarchar(100) = '+QuotedStr(_Anahtar)+'  '+sLineBreak +
       '  IF NOT EXISTS (SELECT * FROM GENINI  '+sLineBreak +
       '                  WHERE BOLUM = @vBolum  '+sLineBreak +
       '                  AND DEGER = @vDeger  '+sLineBreak +
       '                  AND UPPER(ANAHTAR) = Upper(@vData))  '+sLineBreak +
       '  BEGIN  '+sLineBreak +
       '      INSERT INTO GENINI (BOLUM, DEGER, ANAHTAR, SIRA)  '+sLineBreak +
       '      VALUES (@vBolum, @vDeger, @vData, @vDeger)  '+sLineBreak +
       '  END   '+sLineBreak +
       'END';
  end;

begin
  {
    GENINI doldurulacak
    PrjConst constEvrak**** "BOLUM" sabitlere göre doldurulacak
  }
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( Ops_Dokuman_Gizlilik{-3206},1,'Genel'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( Ops_Dokuman_Gizlilik{-3206},2,'Hizmete Özel'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( Ops_Dokuman_Gizlilik{-3206},3,'Özel'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( Ops_Dokuman_Gizlilik{-3206},4,'Gizli'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( Ops_Dokuman_Gizlilik{-3206},5,'Çok Gizli'),[],[]);

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakCinsi{-4002},1,'Resmi Evrak'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakCinsi{-4002},2,'Kurum İçi'),[],[]);

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakYaziDurumu{-4003},1,'Beklemede'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakYaziDurumu{-4003},2,'İnceleniyor'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakYaziDurumu{-4003},3,'Gönderildi'),[],[]);

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelenYerTur{-4004},1,'Kurum İçi'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelenYerTur{-4004},2,'Kamu'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelenYerTur{-4004},3,'Özel'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelenYerTur{-4004},4,'Tüzel'),[],[]);

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelisSekli{-4005},1,'Posta'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelisSekli{-4005},2,'Elden'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelisSekli{-4005},3,'Faks'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelisSekli{-4005},4,'e-Posta'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakGelisSekli{-4005},5,'Telgraf ile'),[],[]);

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakPostaTuru{-4006},1,'Elden'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakPostaTuru{-4006},2,'Adi Posta'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakPostaTuru{-4006},3,'İadeli Taahhütlü'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakPostaTuru{-4006},4,'Taahüttlü'),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQlOlustur( constEvrakPostaTuru{-4006},5,'APS'),[],[]);
end;

function GetEvrakTurGelenGiden(_EvrakKlasorTur : integer) : integer;
begin
  case (_EvrakKlasorTur div 1000) of
    1 : // Gelen Sekmeleri
      Result := cGelenEvrak;
    2 : // Giden Sekmeleri
      Result := cGidenEvrak;
    3 :
      Result := cKisiselEvrak;
    4 :
      Result := cKurumsalEvrak;
  end;

end;

procedure TEvrakListeFrame.actTanimlarExecute(Sender: TObject);
begin
   EvrakTanimGoster(-1, Application);
end;

procedure TEvrakListeFrame.act_EvrakBilgi_AlttaExecute(Sender: TObject);
begin
  PageDokuman.Align := alBottom;
  act_EvrakBilgi_GizleExecute(act_EvrakBilgi_Gizle);
end;

procedure TEvrakListeFrame.act_EvrakBilgi_GizleExecute(Sender: TObject);
begin
  PageDokuman.Visible := TAction(Sender).Checked;
  if PageDokuman.Visible then
   begin
     if PageDokuman.Align = alRight then begin
        cxSplitter1.AlignSplitter := salRight;
        PageDokuman.Width := 300;
      end
       else begin
         cxSplitter1.AlignSplitter := salBottom;
         PageDokuman.Height := 194;
       end;
   end;
end;

procedure TEvrakListeFrame.act_EvrakBilgi_SagdaExecute(Sender: TObject);
begin
  PageDokuman.Align := alRight;
  act_EvrakBilgi_GizleExecute(act_EvrakBilgi_Gizle);
end;

procedure TEvrakListeFrame.act_ListeYazdirExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.act_OtomatikTeslimAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.act_YardimExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 38 then
     DOKUMAN.Prior
  else if Key = 40 then
     DOKUMAN.next
  else begin
     YenileTusClick;
  end;
end;

procedure TEvrakListeFrame.Baskayerekisayololustur1Click(Sender: TObject);
var
  i, ID: integer;
  KID: Integer;
  KKod, KAciklama, sqltext: string;
  slist : TStringList;
begin
  sqltext := 'select ROOTKOD=USTID,KOD=ID,ID,ACIKLAMA=AD,RESIM from DOKUMANKLASOR where ID>0';
  if KodAgaciKlasorDlg = nil then
     Application.CreateForm(TKodAgaciDlg, KodAgaciKlasorDlg);
  if Tablo.KodAgacindanSec(KodAgaciKlasorDlg, sqltext, True, True, True, True, KID, KKod, KAciklama, slist,[], [], [], [], []) then
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DOKUMANKISAYOL(DOKUMANID, YER, YER_ID,SUBEID) values(' + DOKUMAN.Fields[0].AsString + ',' + IntToStr(TabNo_DOKUMAN)+','+
          IntToStr(KID) + ',' + inttoStr(SubeId) + ')', [], []);
end;

procedure TEvrakListeFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  if TamYetkili=False then
      TabRevize.LockType := ltReadOnly;
  FArama.PageArama.ActivePage := FArama.TabSheetKlasor;
  YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
  //Tablo.GridAyarRestore('EvrakListeGridi',EvrakTview );
  Tablo.GridTurkcelestir;
  PageDokuman.ActivePageIndex := 0;

  if KaynakDB = 'SAP' then begin
     SQLMemo.Text := StringReplace(SQLMemo_SAP.Text, 'SAP_DB_AD', SAP_DBAd, [rfReplaceAll]);
     SQLMemo2.Text := StringReplace(SQLMemo2_SAP.Text, 'SAP_DB_AD', SAP_DBAd, [rfReplaceAll]);
     YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
  end;

end;

procedure TEvrakListeFrame.EvrakTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridEvrak;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := EvrakTview;
  AnaForm.pmGridStil.Tags.Values[GridEvrak.Name] := 'EvrakListeGridi';
end;

procedure TEvrakListeFrame.EvrakTviewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Ht: TcxCustomGridHitTest;
  ad: string;
begin
  If(Screen.Cursor = crHandPoint) and (EvrakTview.Controller.SelectedRecordCount > 0) then begin
     if DegistirTus.visible then
        DegistirTus.click
     else
        GorTus.Click;
  end;
end;

procedure TEvrakListeFrame.TaraTusClick(Sender: TObject);
var
  ID: Integer;
begin
  DYetkisonuc := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
  if DYetkisonuc.Ekle = True then
  begin
      ID := Tablo.DokumanTara(FArama.TabKlasorler.FieldByName('ID').AsInteger,0);
      if ID > 0 then begin
         if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
            YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
         else
            YenileTusClick;
      end;
  end
  else
    ShowMessage(Yetkisiz_Islem);
end;

procedure TEvrakListeFrame.DegistirTusClick(Sender: TObject);
begin
   Tablo.Dokuman_Gor_Duzenle(3, Dokuman.Fields[0].AsInteger, Dokuman.FieldByName('AD').AsString);
   PageControlDoldur;
///   FArama.PageArama.Enabled :=False;
end;

procedure TEvrakListeFrame.GortusClick(Sender: TObject);
begin
     //tablo.Dokuman_Gor_Duzenle(1, Dokuman.Fields[0].AsInteger, Dokuman.FieldByName('AD').AsString);
  if GetEvrakTurGelenGiden(EvrakTuru) = cGelenEvrak then
    GelenEvrakFormEkleGoster(Self, Dokuman.FieldByName('ID').AsInteger , FArama.TabKlasorler.FieldByName('ID').AsInteger, False)
  else
    if GetEvrakTurGelenGiden(EvrakTuru) = cGidenEvrak then
     if
      GidenEvrakFormEkleGoster(Self, Dokuman.FieldByName('ID').AsInteger , FArama.TabKlasorler.FieldByName('ID').AsInteger, False) = mrCancel then
        YenileTusClick;
end;

procedure TEvrakListeFrame.TabKlasorlerAfterScroll(DataSet: TDataSet);
begin
  // DYetkisonuc:=Tablo.DokumanYetkiKontrol(322,FArama.TabKlasorler.FieldByName('ID').AsInteger);
  // if DYetkisonuc.Gor=true then
  try
    YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
  except on e: Exception do
    ShowMessage(e.Message);
  end;
end;



{ KLASOR ID değeri
   Gelen                          -1001
     Bütün Evraklar               -1101
     Üzerinde Çalıştıklarım       -1102
     Teslim Almadıklarım          -1103
     Havale Ettiklerim            -1104
     Dosyaya Kaldırdıklarım       -1105
     İptal Ettiklerim             -1106
   Giden                          -2001
     Bütün Evraklar               -2101
     Üzerinde Çalıştıklarım       -2102
     Gönderilen İşler             -2103
     İmzada Bekleyenler           -2104
     Havale Ettiklerim            -2105
     Dosyaya Kaldırdıklarım       -2106
     İptal Ettiklerim             -2107
   Kişisel                        -3001
   Kurumsal                       -4001
}



procedure TEvrakListeFrame.actGelen_DosyaladigimGeriAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_HavaleEtigimGeriAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_IptalEttigimGeriAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_TeslimAlBarkodileExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_TeslimAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_TeslimAlGeriGonderExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_TeslimALiptalEtExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_UzerindeCalistigimDosyayaKaldirExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_UzerindeCalistigimHavaleEtExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_UzerindeCalistigimIptalEtExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGelen_UzerindeCalistigimYeniEvrakExecute(Sender: TObject);
var
  ID: Integer;
begin
     //if Tablo.OpenDialog1.Execute then
     begin
        //ID := Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, Tablo.OpenDialog1.FileName);
        //                         KLASOR ID                    , Default FileName, Modul, ModulID, BelgeNoTurID=251
        ID := Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, '', 0, 0 ,251);
        {}
        GelenEvrakFormEkleGoster(Self, ID, FArama.TabKlasorler.FieldByName('ID').AsInteger, True);
        YenileTusClick;
        {}
     end
end;

procedure TEvrakListeFrame.actGiden_DosyaladigimGeriAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_GorExecute(Sender: TObject);
begin
   GortusClick(Nil);
end;

procedure TEvrakListeFrame.actGiden_GorUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := EvrakBandedView.DataController.FocusedRecordIndex>-1;
end;

procedure TEvrakListeFrame.actGiden_HavaleEttiklerimGeriAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalisitimYeniEvrakExecute(Sender: TObject);
var
  ID: Integer;
begin
   ID := 1;
     //if Tablo.OpenDialog1.Execute then
     begin
        //ID := Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, Tablo.OpenDialog1.FileName);
        ID := Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, '', 0, 0, 251);
        {}
        GidenEvrakFormEkleGoster(Self, ID, FArama.TabKlasorler.FieldByName('ID').AsInteger, True); // = mrCancel then
        YenileTusClick;
        {}
     end

end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimDosyayaKaldirExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimEditorExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimEEvrakGonderExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimEImzalaExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimEvrakNoAlExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimGeriGonderExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimimzalaExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimImzayaGonderExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.actGiden_UzerindeCalistigimIptaletExecute(Sender: TObject);
begin
//
end;

procedure TEvrakListeFrame.ActMenuAyarla(_Tag : integer; _Visible : boolean);
var
  i : integer;
begin
   {
   for i := 0 to ActionListEvrak.ActionCount-1 do
      if ActionListEvrak.Actions[i].Tag<>0 then
       if ActionListEvrak.Actions[i].Tag = _Tag then
    }
    PageControlMenu.ActivePageIndex := _Tag;
end;

procedure TEvrakListeFrame.ActSayfaAyarla(_KlasorID: integer);
begin

  case (_KlasorID div 1000) of
    1 : // Gelen Sekmeleri
      begin
         ActMenuAyarla( (_KlasorID mod 1000) - 100 - 1 + 0, True);
      end;
    2 : // Giden Sekmeleri
      begin
         ActMenuAyarla( (_KlasorID mod 1000) - 100 -1 + 6, True);
         OutputDebugString(PWideChar('GİDEN KalsorID='+_KlasorID.ToString+' _Tag = '+((_KlasorID mod 1000) - 100 -1 + 6).ToString));
      end;
  end;
end;

Procedure TEvrakListeFrame.YenileKlasorClick(KlasorId: Integer);
var
  //yetkisorgu,
  GD: string;
  etiketler,bilgiler: TArrayOfString;

  Procedure AlanlarOlustur;
  begin
      { //UNUTMA
      if not AlanlarOlusturuldu then begin
         EvrakTview.DataController.CreateAllItems(True);
         Tablo.GridAyarRestore('EvrakListeGridi',EvrakTview );
         AlanlarOlusturuldu := True;
      end;
      }
  end;


var
   sorguSQL : string;
   whereKlasor : string;
   //whereYERID : string;
begin
   // "Evrak" KlasorID değeri -1000 .. -4999 arası değer olacağından
   // iç yordamların buna göre davranacağı, gelen değerin pozitif değeri üzerinden
   // "DIV" ve "MOD" ile kıyaslanacağı varsayldı
  {-----------}
    {}   EvrakTuru := -1 * KlasorId;
  {----------}

  { "DOKUMAN" Sorgu "Bütün Evraklar" gibi klasörlerde, yalnızca "KLASOR" ID alanına göre yeniden şekillenecek}
  { Bakınız KLASOR ID değeri}
  if (EvrakTuru<1000) or (EvrakTuru>4999) then
    Exit;


   whereKlasor := '(DK.ID = '+KlasorID.ToString+')';
   //whereYERID := '(DK.YER = '+KlasorID.ToString+')';
   sorguSQL := sqlMEMO.Text;


  DOKUMAN.Close;

  EvrakBandedView.PopupMenu := Nil;
  if GetEvrakTurGelenGiden(EvrakTuru) = cGelenEvrak then
  // Gelen Evrak
    begin
        if EvrakTuru mod 1000 = 1 then
          Exit;
        EvrakBandedView.PopupMenu := PopupGelenEvrak;
        if EvrakTuru mod 1000 = cButunEvraklar then
         begin
          //whereKlasor := '(D.KLASOR < -1000 AND D.KLASOR > -2000)';
          //whereYERID := '(DK.YER < -1000 AND DK.YER > -2000)';
          whereKlasor := '( DK.ID  < -999 and DK.ID> -2000 )';
         end
    end
      else
  if GetEvrakTurGelenGiden(EvrakTuru) = cGidenEvrak then
  // Giden Evrak
    begin
        if EvrakTuru mod 1000 = 1 then
          Exit;
        EvrakBandedView.PopupMenu := PopupGidenEvrak;
        if EvrakTuru mod 1000 = cButunEvraklar then
         begin
          //whereKlasor := '(D.KLASOR < -2000 AND D.KLASOR > -3000)';
          //whereYERID := '(DK.YER < -2000 AND DK.YER > -3000)';
          whereKlasor := '( DK.ID  < -1999 and DK.ID> -3000 )';
         end
    end
      else
  if (EvrakTuru div 1000=3) then
  // Kişisel Evrak Arşivi
    begin

    end
      else
  if (EvrakTuru div 1000=4) then
  // Kurumsal Evrak Arşivi
    begin

    end;

  if TamYetkili then
  begin
    //DOKUMAN.Close;
    if FArama.TreeKlasorler.SelectionCount<=1 then begin
        DOKUMAN.SQL.Text := sqlMEMO.Text + ' WHERE ' + whereKlasor ;
        PageDokuman.Visible := False;
        cxSplitter1.Visible := False;
    end;
  end
  else begin
    SetLength(bilgiler,1);
    SetLength(etiketler,1);
    Tablo.RehberEkBilgileriniGetir(StrToInt(Kullanan),3,[79],etiketler,bilgiler);
    if bilgiler[0]='' then
       GD:='1'
    else
       GD:=bilgiler[0];

    DOKUMAN.SQL.Text := sqlMEMO.Text +
   //     ' Where D.GIZLILIKDERECESI <= '+GD+'  AND D.KLASOR ='+whereKlasor + ' '+
   //     ' AND GOR = 1 AND (DY.REHBERID=0 OR DY.REHBERID= ' + Kullanan + ' ) ';
      'WHERE DK.GIZLILIKDERECESI <= '+GD+' AND '+whereKLASOR;
  end;

  DOKUMAN.SQL.Text := DOKUMAN.SQL.Text +' ORDER BY DK.USTID DESC, DK.ID DESC, D.ID';
  //DOKUMAN.SQL.Text := DOKUMAN.SQL.Text+' '+ ' union all ' + SQLmemo2.Text + ' Where DK.YER='+IntToStr(TabNo_DOKUMAN)+' and '+whereYERID;
  // UNUTMA
  {$IFDEF 3Dparty} _LogEkle(UnitName+' YenileKlasorClick "DOKUMAN.SQL"', DOKUMAN.SQL.Text+#13#10); LoggerInterface.Flush; {$endif}

  TabloYenile(DOKUMAN,[]);
  EvrakBandedView.ViewData.Expand(True);
  { Header olunca çok çirkin görünüyor.}
  EvrakBandedView.OptionsView.GroupByBox := False;
  EvrakBandedView.OptionsView.Header := False;
  //EvrakTView.ViewData.Expand(True);
  AlanlarOlustur;
  ActSayfaAyarla(EvrakTuru);
end;

procedure TEvrakListeFrame.YenileTusClick;
begin
   if FArama.PageArama.ActivePageIndex > 0 then begin
      JvTimer1.Enabled := False;
      JvTimer1.Interval := 700;
      JvTimer1.Enabled := True;
   end;
end;

procedure TEvrakListeFrame.JvTimer1Timer(Sender: TObject);
{function KayitSayisiBelirle: string;
  begin
   if (Trim(FArama.AraDokuman.Text) <> '') or (Trim(FArama.AraKonusu.Text) <> '') or (Trim(FArama.AraAnahtar.Text) <> '') or
       (Trim(FArama.AraKurum.EditText) <> '') or (Trim(FArama.AraSorumlu.EditText) <> '') or
       (Trim(FArama.AraLokasyon.EditText) <> '') or (Trim(FArama.AraKategori.EditText) <> '') or (Trim(FArama.AraBolumu.EditText) <> '') or
       (Trim(FArama.AraModul.EditText) <> '') then
      Result := 'SELECT TOP 200 '
    else
      Result := 'SELECT  '

  end; }
var
  s,GD: string;
  etiketler,bilgiler: TArrayOfString;
begin
//  if FArama.Tasiniyor then
//    Exit;
  JvTimer1.Enabled := False;
  SetLength(bilgiler,1);  //Kullanıcı gizlilik derecesi Kontrol Ediliyor
  SetLength(etiketler,1);
  Tablo.TablodanSorguAc(4, 'select * from kullanıcı where REHBERID = ' + Kullanan);
  Tablo.RehberEkBilgileriniGetir(Tablo.Query4.FieldByName('REHBERID').AsInteger,3,[79],etiketler,bilgiler);

  s := ' where 1=1 '; // D.KLASOR > 0
  if Trim(FArama.AraDokuman.Text) <> '' then
    s := s + ' and D.AD like ''%'+Trim(FArama.AraDokuman.Text) + '%'' ';
  if Trim(FArama.AraKonusu.Text) <> '' then
    s := s + ' and  D.KONU like ''%'+Trim(FArama.AraKonusu.Text) + '%'' ';
  if Trim(FArama.AraAnahtar.Text) <> '' then
    //s := 'LEFT OUTER JOIN ANAHTAR_KELIME ANAHTAR ON ANAHTAR.DOK_ID=D.ID' + s + ' and  ANAHTAR.KELIME like ''%'+Trim(FArama.AraAnahtar.Text) + '%'' ';
    s := s + ' and  D.ANAHTAR like ''%'+Trim(FArama.AraAnahtar.Text) + '%'' ';
  if FArama.AraKurum.Text <> '' then
    s := s + ' and Firma.FIRMA like ''%'+Trim(FArama.AraKurum.Text) + '%'' ';
  if FArama.AraSorumlu.Text <> '' then
    s := s + ' and Sorumlu.FIRMA like ''%'+Trim(FArama.AraSorumlu.Text) + '%'' ';
  if FArama.AraLokasyon.Text <> '' then
    s := s + ' and Lokasyon.ACIKLAMA like ''%'+Trim(FArama.AraLokasyon.Text) + '%'' ';
  if FArama.AraBolumu.EditValue > 0 then
    s := s + ' and D.BOLUM = ' + IntToStr(FArama.AraBolumu.EditValue);
  if FArama.AraModul.EditValue > 0 then
    s := s + ' and D.MODUL = ' + IntToStr(FArama.AraModul.EditValue);
  if FArama.AraKategori.Text <> '' then
    s := s + ' and D.KATEGORI = '+IntToStr(FArama.AraKategori.EditValue) ;
  if FArama.checkPasif.Checked=false then
   s := s + '  AND D.DURUM = 1 ';
  if TamYetkili=False then
  begin
    if bilgiler[0]='' then
       GD:='1'
     else
       GD:=bilgiler[0];
    s := s + ' AND D.GIZLILIKDERECESI <= '+GD ;
  end;

  if FArama.checkTarih.Checked then begin
     s := s + ' AND D.TARIH >= ''' + FormatDateTime('yyyy-mm-dd 00:00', FArama.dateDokumanBas.Date) + ''' ';
     s := s + ' AND D.TARIH <= ''' + FormatDateTime('yyyy-mm-dd 00:00', FArama.dateDokumanBit.Date) + ''' ';
  end;
  DOKUMAN.Close;
  //if KaynakDB = 'SAP' then
//     DOKUMAN.SQL.Text :=  SQLMemo_SAP.Text
//  else
     DOKUMAN.SQL.Text :=  SQLMemo.Text;     //  KayitSayisiBelirle + ' ' +     SAP_DB_AD
  DOKUMAN.SQL.Add(s);
  DOKUMAN.SQL.Add(' union all ');
//  if KaynakDB = 'SAP' then
//     DOKUMAN.SQL.Add(SQLMemo2_SAP.Text)
//  else
     DOKUMAN.SQL.Add(SQLMemo2.Text);   //KayitSayisiBelirle + ' ' +
  DOKUMAN.SQL.Add(s);
  TabloYenile(DOKUMAN,[]);
end;

procedure TEvrakListeFrame.LabelTumKayitlarClick(Sender: TObject);
begin
  DOKUMAN.Close;
  DOKUMAN.SQL.Text := SQLMemo.Text + ' union all ' + SQLMemo2.Text;
  TabloYenile(DOKUMAN,[]);
end;

procedure TEvrakListeFrame.UstuneKaydettusClick(Sender: TObject);
begin
   //Tablo.DokumanUstuneKaydetTus(KapatTus);
end;

procedure TEvrakListeFrame.EvrakTviewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  GridHitTest: TcxCustomGridHitTest;
  TreeHitTest: TcxTreeListHitTest;
  DYetkisonucTutulanKalsor: DokumanYetkiSonuc;
  node: TcxTreeListNode;
begin
  // TutulanYer: 1=Klasör, 2=Belge
     { TODO 1 -oMücahit Yağmur -cEvrak Bilgi : Evrak TView DragOver yazılmalı mı ? }
  (*
  if State = dsDragEnter then begin
    if Sender.Classname = 'TcxGridSite' then begin
      GridHitTest := (Sender as TcxGridSite).GridView.ViewInfo.GetHitTest(X, Y);
      if GridHitTest is TcxGridRecordCellHitTest then begin
        // belge tutuldu
        TutulanYer := 1;
        TutulanID := DOKUMAN.FieldByName('ID').AsInteger;
        TutulanKisayol := DOKUMAN.FieldByName('KISAYOLID').AsInteger;
        Accept := True;
      end;
    end else if Sender.Classname = 'TcxDBTreeList' then begin
      TreeHitTest := (Sender as TcxDBTreeList).HitTest;
      // .HitState = echc_Empty
      if TreeHitTest.HitAtNode then begin
        // Klasör Tutuldu
        TutulanYer := 2;
        TutulanKisayol := 0;
        TutulanID := FArama.TabKlasorler.FieldByName('ID').AsInteger;
        Accept := TutulanID <> -1;
      end;
    end;
  end;

  if State = dsDragLeave then begin
    if (State = dsDragLeave) and (Sender.Classname = 'TcxGridSite') and (TutulanYer <> 0) and (TutulanID <> 0) then begin
      GridHitTest := (Sender as TcxGridSite).GridView.ViewInfo.GetHitTest(X, Y);
      if GridHitTest is TcxGridRecordCellHitTest then begin
        // belgeye bırakıldı
        TutulanYer := 0;
        TutulanID := 0;
        Accept := True;
      end;
    end else if (State = dsDragLeave) and (Sender.Classname = 'TcxDBTreeList') and (TutulanYer <> 0) and (TutulanID <> 0) then begin
      node := (Sender as TcxDBTreeList).GetNodeAt(X, Y);
      if Assigned(node) then begin
        DYetkisonuc := Tablo.DokumanYetkiKontrol(322, node.Values[0]);
        DYetkisonucTutulanKalsor := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
        if TutulanYer = 2 then begin// tutulan klasor mu kontrol yapılıyor
          if (DYetkisonuc.Ekle = True) and (DYetkisonucTutulanKalsor.Degistir = True) then begin
            TreeHitTest := (Sender as TcxDBTreeList).HitTest;

          end else begin
            ShowMessage(Yetkisiz_Islem);
            Abort;
          end;
        end else begin
          if DYetkisonuc.Ekle = True then begin
            TreeHitTest := (Sender as TcxDBTreeList).HitTest;
            // Klasöre Bırakıldı
          end else begin
            ShowMessage(Yetkisiz_Islem);
            Abort;
          end;
        end;
        if (TutulanYer = 1) and (TreeHitTest.HitAtNode) then begin
          if TutulanKisayol > 0 then // kisayol taşınıyor
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKISAYOL set YER_ID=&KlasorID where ID=&KisayolID', ['&KlasorID', '&KisayolID'], [(Sender as TcxDBTreeList).GetNodeAt(X, Y).Values[0], TutulanKisayol])
          else // dokuman taşınıyor
            DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);
          if DYetkisonuc.Degistir = True then begin // DOKuman Yetki Kontrolu Yapılıyor.
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMAN set YER_ID=&KlasorID where ID=&DokumanID', ['&KlasorID', '&DokumanID'], [(Sender as TcxDBTreeList).GetNodeAt(X, Y).Values[0], TutulanID]);
            TabKlasorlerAfterScroll(FArama.TabKlasorler);
          end else
            ShowMessage(Yetkisiz_Islem);
        end else if (TutulanYer = 2) and (TreeHitTest.HitAtBackground) then begin // Klasor Taşıma işlemi yapılıyor
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKLASOR set USTID=0 where ID=&ID', ['&ID'], [TutulanID]);
          TabloYenile(FArama.TabKlasorler, []);
        end else
          Accept := True;


        if (TreeHitTest.HitAtNode) or (TreeHitTest.HitAtBackground) then begin
          TutulanYer := 0;
          TutulanID := 0;
        end;
      end else begin  // Klasor Kök dizine taşınıyor.
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKLASOR set USTID=0 where ID=&ID', ['&ID'], [TutulanID]);
          FArama.TabKlasorler.Refresh;
      end;
    end;
  end;
  *)
end;

procedure TEvrakListeFrame.EvrakTviewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    SilTus.Click
  else if Key = VK_RETURN then
    FormAcTus.Click
  else if (ssCtrl in Shift) and (Key = 65) then
    EvrakTview.DataController.SelectAll;
end;

procedure TEvrakListeFrame.EvrakTviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Ht: TcxCustomGridHitTest;
begin
  Ht := TcxGridSite(Sender).GridView.Viewinfo.GetHitTest(X, Y);
  If(Ht is TcxGridRecordCellHitTest) and (TcxGridRecordCellHitTest(Ht).Item.Properties is TcxHyperLinkEditProperties) then Screen.Cursor := crHandPoint
else
  Screen.Cursor := crDefault;
end;

procedure TEvrakListeFrame.EvrakTviewSelectionChanged(  Sender: TcxCustomGridTableView);
begin
  PageDokuman.Visible := True;
  cxSplitter1.Visible := True;
  PageControlDoldur;
  // cxSplitter1.OpenSplitter;
end;

procedure TEvrakListeFrame.EvrakTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TEvrakListeFrame.FormAcTusClick(Sender: TObject);
var
  //Key: Word;
  srid: integer;
begin
  If Screen.Cursor <> crHandPoint then
  begin
    DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);
    if DYetkisonuc.Gor = True then begin
      if EvrakTview.Controller.SelectedRecordCount > 0 then begin
        srid := EvrakTview.DataController.FocusedRecordIndex;
        // Evrak Türüne göre Gelen / Giden formu açılacak
        if GetEvrakTurGelenGiden(EvrakTuru) = cGelenEvrak then
          begin

          end
        else
        if GetEvrakTurGelenGiden(EvrakTuru) = cGidenEvrak then
          begin

          end;

        {
        if Tablo.DokumanSihirbazBaslat('D', 0, DOKUMAN.Fields[0].AsInteger, FArama.TabKlasorler.FieldByName('ID').AsInteger,0,0,0,0) > 0 then
          case FArama.PageArama.ActivePageIndex of
            0 : begin
                  YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
               end;
            1 : YenileTusClick;
          end;
          }

        EvrakTview.DataController.FocusedRecordIndex := srid;
      end;
    end else
      ShowMessage(Yetkisiz_Islem);
  end;
end;

procedure TEvrakListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TEvrakListeFrame.EPostaAl1Click(Sender: TObject);
var
  IlkTarih: Variant;
begin
  IlkTarih := Tablo.GENINI.BugunTrh;
  if TGirisKutusuEx.BilgiAlEx(BGBaslama_tarih, TGirdiDenetimleri.Create.DateTimePicker(BGBaslangıc_tarih_gir, @IlkTarih)) = mrOk then
    Tablo.EPostaAlimIslemleri('', TDateTime(IlkTarih));
end;

procedure TEvrakListeFrame.EPostaMenuClick(Sender: TObject);
var
   Ad : string;
   ID : Integer;
begin
  ID := DOKUMAN.FieldByName('ID').AsInteger;
  Ad := Tablo.DokumanBelgeyiAc(ID,1,False, DOKUMAN.FieldByName('AD').AsString);

  DYetkisonuc := Tablo.DokumanYetkiKontrol(321, ID);
  if DYetkisonuc.Degistir then begin

     Tablo.OrtakEPostaGonder(MODUL_Dokuman, DOKUMAN, Ad, '', '');

     Tablo.DokumanTarihceEkle(ID,'E-Posta gönderildi',6);
     //   Tablo.DokumanBildirimDuyuruAc(6,ID,Ad);
     Tablo.TablodanSorguAc(9,'SELECT REHBERID FROM DOKUMANBILDIRIM WHERE DOKUMANID='+inttostr(ID));
     Tablo.DuyuruYayinla(Tablo.Query9, 'Doküman E-Posta / '+Ad, '"'+Ad+'" dokümanı üzerinde '+ DateTimeToStr ( Tablo.GENINI.BugunTrhSaat) + ' tarihinde "'+KullanAdi+'" kullanıcısı tarafından E-Posta işlemi gerçekleştirilmiştir.');
  end
  else
     Tablo.UyariGoster(Uyari,Yetkisiz_Islem,1);
end;

procedure TEvrakListeFrame.VerTusClick(Sender: TObject);
var
   ad,AdDokuman: string;
   i, ID: Integer;
begin
  for i := 0 to EvrakTview.Controller.SelectedRecordCount - 1 do begin
    ID := EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewID.Index];
    ad := EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewAD.Index];
    AdDokuman:=DOKUMAN.FieldByName('AD').AsString;
    tablo.DokumanDisariVer(ID,ad,AdDokuman);
  end;
end;

procedure TEvrakListeFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TEvrakListeFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TEvrakListeFrame.FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Screen.Cursor <> crDefault then
     Screen.Cursor := crDefault;
end;

procedure TEvrakListeFrame.GeriDnmBoalt1Click(Sender: TObject);
var
  i, id: Integer;
begin
  if Application.MessageBox(PChar(GDonusumSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
  begin
    EvrakTview.Controller.SelectAllRecords;
    for I := 0 to EvrakTview.Controller.SelectedRowCount - 1 do
    begin
      id := EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewID.Index];
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM IMAJ  WHERE YERI= 1 AND YER_ID =&ID ', ['&ID'], [IntToStr(id)]); // IN (SELECT ID FROM DOKUMAN D WHERE D.ID= YER_ID AND D.KLASOR = -1)',[], []);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANKISAYOL WHERE YER_ID=-1 AND DOKUMANID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMAN WHERE KLASOR= -1 AND ID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM ANAHTAR_KELIME WHERE  DOK_ID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANYETKI WHERE  YERID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANGECMIS WHERE  DOKUMANID=&ID ', ['&ID'], [IntToStr(id)]);
    end;
  end;

  if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
    YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
  else
    YenileTusClick;
end;

procedure TEvrakListeFrame.GeriYkle1Click(Sender: TObject);
begin
  if DOKUMAN.FieldByName('TIP').AsInteger = 1 then  // Dosya Geri Yükleniyor.
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DOKUMAN set KLASOR=ESKIKLASOR , ESKIKLASOR=NULL  where KLASOR=-1  and ID=&DokID', ['&DokID'], [DOKUMAN.FieldByName('ID').AsInteger]);

  if DOKUMAN.FieldByName('TIP').AsInteger = 0 then // KIsayol Geri geri yükleniyor
    if Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'select d.klasor from dokuman d inner join DOKUMANKISAYOL DK  on d.ID=dk.DOKUMANID where d.KLASOR=-1 AND dk.ID=&ID', ['&ID'], [DOKUMAN.FieldByName('KISAYOLID').AsInteger]) = -1 then
      ShowMessage(PChar(KısayolUyarı))
    else
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKISAYOL set YER_ID=ESKIKLASOR , ESKIKLASOR=NULL  where YER_ID=-1 AND ID=&ID', ['&ID'], [DOKUMAN.FieldByName('KISAYOLID').AsInteger]);

  if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
    YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
  else
    YenileTusClick;
end;

function TEvrakListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TEvrakListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TEvrakListeFrame.Gorunmez;
begin

end;

procedure TEvrakListeFrame.GorunmezOlacak;
begin

end;

procedure TEvrakListeFrame.Gorunur;
begin

end;

procedure TEvrakListeFrame.GorunurOlacak;
begin

end;

procedure TEvrakListeFrame.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
{var
  ID, i: Integer;
//  VersNo, DokNo: Variant;
}
begin
{
//AO 21.04.2020 klasör yetkilendirme durduruldu
//  DYetkisonuc := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
//  if DYetkisonuc.Ekle = True then
//  begin
    for i := 0 to Value.Count - 1 do
        Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, Value.Strings[i]);
    TabloYenile(DOKUMAN,[]);
//  end
//  else
//    ShowMessage(Yetkisiz_Islem);
}
end;

procedure TEvrakListeFrame.DuyuruOlarakYaynla1Click(Sender: TObject);
begin
  Tablo.TablodanSorguAc(7,'select '+DbUst(1)+'ID from IMAJ where YERI=1 and YER_ID='+DOKUMAN.FieldByName('ID').AsString+' order by ID desc '+DbSinir(1));
  Tablo.DuyuruAc('E',0,Tablo.Query7.FieldByName('ID').AsInteger);
end;

procedure TEvrakListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TEvrakListeFrame.KesMenuClick(Sender: TObject);
var
  i: Integer;
begin
  DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);
  if DYetkisonuc.Degistir = True then
  begin
    // KesID,KopyalaID,SonIslem:Integer;//sonişlem:kes=1,kopyala=2,Yapıştır=0;
    SonIslem := 1;
    SetLength(SecDokID, EvrakTview.Controller.SelectedRecordCount);
    for i := 0 to EvrakTview.Controller.SelectedRecordCount - 1 do
      SecDokID[i] := EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewID.Index];
    YapistirMenu.Enabled := True;
    YapistirTus.Enabled := True;
  end
  else
    ShowMessage(Yetkisiz_Islem);
end;

procedure TEvrakListeFrame.KopyalaMenuClick(Sender: TObject);
var
  i: Integer;
begin

  DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);

  if DYetkisonuc.Degistir = True then
  begin

    // KesID,KopyalaID,SonIslem:Integer;//sonişlem:kes=1,kopyala=2,Yapıştır=0;
    SonIslem := 2;
    SetLength(SecDokID, EvrakTview.Controller.SelectedRecordCount);
    for i := 0 to EvrakTview.Controller.SelectedRecordCount - 1 do
      SecDokID[i] := EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewID.Index];
    YapistirMenu.Enabled := True;
    YapistirTus.Enabled := True;
  end
  else
    ShowMessage(Yetkisiz_Islem);
end;

procedure TEvrakListeFrame.BurayaKisayololusturMenuClick(Sender: TObject);
{var
  st: TStringList;
  sqltext: string;}
begin
  // önce kısayol oluşturulacak dosyayı bulalım
  (*
  st := TStringList.Create;
  sqltext := ' select D.AD, K.AD, D.ID from DOKUMAN D inner join DOKUMANKLASOR K on D.KLASOR = K.ID where ' + ' K.ID>0 and D.KLASOR<>' + FArama.TabKlasorler.FieldByName('ID').AsString + ' and D.DURUM>0 and D.AD like ''%<ara>%'' order by 1';
  if Tablo.ListedenBilgiGetir('Doküman Listesi', sqltext, st, []) then
  begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DOKUMANKISAYOL(DOKUMANID, YER, YER_ID, SUBEID) values(' + st.Strings[2] + ',' + IntToStr(TabNo_DOKUMAN)+','+
               FArama.TabKlasorler.FieldByName('ID').AsString + ',' + inttoStr(SubeId) + ')', [], []);

    if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
      YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
    else
      YenileTusClick;
  end;
  st.Free;
  *)
end;

constructor TEvrakListeFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  PageControlMenu.ActivePageIndex := 0;
  PageControlMenu.HideAllTabs := True;
  PanelTop.Height := 42;
  Toolbar1.Visible := FALSE;
end;

procedure TEvrakListeFrame.SetArama(const Value: TEvrakAramaFrame);
var
  k: Word;
begin
  FArama := Value;
  with FArama do
  begin
    FArama.PageArama.ActivePageIndex := 0;
    dateDokumanBas.Date := StrToDateTime('01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + IntToStr(CariYil)) - 30;
    dateDokumanBit.Date := Date;
    checkTarih.Checked := false;
  end;
end;

procedure TEvrakListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TEvrakListeFrame.Sil1Click(Sender: TObject);
var
  i, ID : Integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
  begin
    for i := EvrakTview.Controller.SelectedRecordCount - 1 downto 0 do
    begin
      // Tablo.cxEditRepository2.repDokumanTip Index 1 = Belge
      //if EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewTIP.Index] = 1 then
      begin
        ID := EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewID.Index];
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMAN where ID=&DokID', ['&DokID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=1 and YER_ID=&DokID', ['&DokID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMANKISAYOL where DOKUMANID=&DokID', ['&DokID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM ANAHTAR_KELIME WHERE  DOK_ID=&ID ', ['&ID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANYETKI WHERE  YERID=&ID ', ['&ID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANGECMIS WHERE  DOKUMANID=&ID ', ['&ID'], [IntToStr(id)]);

      end;
      {
      // Tablo.cxEditRepository2.repDokumanTip Index 0 = Kısayol
      if EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewTIP.Index] = 0 then
      begin
        ID := EvrakTview.Controller.SelectedRecords[i].Values[EvrakTviewKISAYOLID.Index];
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANKISAYOL where  ID=&DokID', ['&DokID'], [ID]);
      end;
      }
    end;
    if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
      YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
    else
      YenileTusClick;

  end;
end;

procedure TEvrakListeFrame.SilTusClick(Sender: TObject);
var
   TNode: TcxTreeListNode;
   Cop : Boolean;
begin
   Cop := False;
      case FArama.PageArama.ActivePageIndex of
        0:
          begin // klasör sayfası açık
            TNode := FArama.TreeKlasorler.FocusedNode;
            while TNode.Parent.Classname <> 'TcxTreeListRootNode' do
                  TNode := TNode.Parent;
            Cop := VarToStrDef(TNode.Values[0], '0') = '-1';
          end;
        1:
          Cop := false; // arama sayfası açık
      end;

      if Tablo.DokumanSilmeBaslat(321, EvrakTview, Cop) then begin
         if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
            YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
         else
            YenileTusClick;
      end;
end;

procedure TEvrakListeFrame.PageControlDoldur;
begin
  // Dokuman Genel Bilgiler Dolduruluyor.

    { TODO 1 -oMücahit Yağmur -cEvrak Bilgi : Evrak Bilgi Paneli yeniden yazılacak }
 if PageDokuman.ActivePage = TabSheetGenel then begin
    {

    case DOKUMAN.FieldByName('YON').AsInteger of
      1 : LblYon.Caption := 'Gelen';
      2 : LblYon.Caption := 'Giden';
    else
       LblYon.Caption := 'Gelen/Giden';
    end;
    LblGizlilik.Caption := ComboGizlilik.Text;
    //LblKurum.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', DOKUMAN.FieldByName('REHBERID').AsInteger);
    //LblModul.Caption := ComboModul.Text;
    //LblBag.Caption := Tablo.AciklamaGetir('PROJELER', 'PROJEKODU', DOKUMAN.FieldByName('BAGI').AsInteger);
    LblBolum.Caption := ComboBolum.Text;
    LblLokasyon.Caption := Tablo.AciklamaGetir('LOKASYON', 'ACIKLAMA', DOKUMAN.FieldByName('LOKASYON').AsInteger);
    //LblSorumlu.Caption := DOKUMAN.FieldByName('SORUMLUAD').AsString;//Tablo.AciklamaGetir('REHBER', 'FIRMA', DOKUMAN.FieldByName('SORUMLU').AsInteger);
    LblBoyut.Caption := DOKUMAN.FieldByName('BOYUT').AsString;
    LblArsiv.Caption := DOKUMAN.FieldByName('ARSIVSURESI').AsString;
    case DOKUMAN.FieldByName('ARSIVSURETIPI').AsInteger of
       1 : LblArsiv.Caption := LblArsiv.Caption + ' gün';
       30 : LblArsiv.Caption := LblArsiv.Caption + ' ay';
       365 : LblArsiv.Caption := LblArsiv.Caption + ' yıl';
    end;
    }
 end else if PageDokuman.ActivePage = TabSheetRevize then begin
    // Revize Dolduruluyor.
    TabloYenile(TabRevize, [DOKUMAN.FieldByName('ID').AsInteger]);
 end else if PageDokuman.ActivePage = TabSheetYetki then begin
    // Yetkilendirme Dolduruluyor.
    TabloYenile(TabYetki, [321, DOKUMAN.FieldByName('ID').AsInteger]);
 end else if PageDokuman.ActivePage = TabSheetIlgili then begin
    // İlgili Dolduruluyor.
    TabloYenile(TabIlgili, [DOKUMAN.FieldByName('ID').AsInteger]);
 end;
end;

procedure TEvrakListeFrame.PageDokumanChange(Sender: TObject);
begin
   PageControlDoldur;
end;

procedure TEvrakListeFrame.DOKUMANAfterOpen(DataSet: TDataSet);
begin
  SilTus.Enabled := DOKUMAN.RecordCount > 0;
  FormacTus.Enabled := SilTus.Enabled;
  DegistirTus.Enabled := SilTus.Enabled;
  KesTus.Enabled := SilTus.Enabled;
  VerTus.Enabled := SilTus.Enabled;
  EPostaTus.Enabled := SilTus.Enabled;
  KopyalaTus.Enabled := SilTus.Enabled;
  Gortus.Enabled := SilTus.Enabled;

  SilMenu.Enabled := SilTus.Enabled;
  DegisMenu.Enabled := SilTus.Enabled;
  KesMenu.Enabled := SilTus.Enabled;
  VerMenu.Enabled := SilTus.Enabled;
  EPostaMenu.Enabled := SilTus.Enabled;
  KopyalaMenu.Enabled := SilTus.Enabled;
   EvrakTview.ApplyBestFit(nil);
end;

procedure TEvrakListeFrame.DOKUMANAfterScroll(DataSet: TDataSet);
begin
(*  if (FArama.TabKlasorler.FieldByName('ID').AsInteger <> -1){and(FArama.Tasiniyor=False)} then begin
    EvrakTview.PopupMenu := PopupMenu1;
  end else
    EvrakTview.PopupMenu := popcop; *)

   TabSheetYetki.TabVisible :=(TamYetkili)or( DOKUMAN.FieldByName('EKLEYEN').AsString = Kullanan);
end;

procedure TEvrakListeFrame.DOKUMANBeforeOpen(DataSet: TDataSet);
begin
  if not Tablo.YetkiVarmi(25510101, YetkiTur_Gorme) then
     Exit;
end;

procedure TEvrakListeFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TEvrakListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TEvrakListeFrame.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TEvrakListeFrame.YapistirMenuClick(Sender: TObject);

{var
  i : Integer;
  }
begin
  // KesID,KopyalaID,SonIslem:Integer;//sonişlem:kes=1,kopyala=2,Yapıştır=0;
  {
  if SonIslem = 1 then
    for i := 0 to Length(SecDokID) - 1 do
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMAN set KLASOR=&Klasor where ID=&ID', ['&Klasor', '&ID'], [FArama.TabKlasorler.FieldByName('ID').AsInteger, SecDokID[i]]);
      if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
        YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
      else
        YenileTusClick;
    end;
  if SonIslem = 2 then
    for i := 0 to Length(SecDokID) - 1 do
    begin // dokuman insert ediliyor.
      //klonla
      Tablo.DokumanKopyala(FArama.TabKlasorler.FieldByName('ID').AsInteger, SecDokID[i]);

      if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
        YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
      else
        YenileTusClick;

    end;
  YapistirMenu.Enabled := false;
  YapistirTus.Enabled := false;
  }
end;

procedure TEvrakListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TEvrakListeFrame.YeniTusClick(Sender: TObject);
var
  ID: Integer;
begin
//AO 28.04/2020 klasör yetkisi kaldırıldı
//  DYetkisonuc := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
//  if DYetkisonuc.Ekle = True then begin
     if Tablo.OpenDialog1.Execute then begin
        ID := Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, Tablo.OpenDialog1.FileName);
        {}
        GelenEvrakFormEkleGoster(Self, ID, FArama.TabKlasorler.FieldByName('ID').AsInteger, True);
        {}
        { UNUTMA
        if Tablo.DokumanSihirbazBaslat('E', 0, ID, FArama.TabKlasorler.FieldByName('ID').AsInteger,0,0,0,0) > 0 then
          case FArama.PageArama.ActivePageIndex of
            0 : YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
            1 : YenileTusClick;
          end;
        }
     end
     else
        abort;
//  end;
//  else
//    ShowMessage(Yetkisiz_Islem);
end;

procedure TEvrakListeFrame.Yetkilendirme1Click(Sender: TObject);
begin
  Application.CreateForm(TDokumanYetki, DokumanYetki);
  DokumanYetki.DokumanYetkiID := DOKUMAN.FieldByName('ID').AsInteger;
  DokumanYetki.DokumanYetkiTur := 321;
  DokumanYetki.Caption := DokumanYetki.Caption + ' (' + DOKUMAN.FieldByName('AD').AsString + ')';
  DokumanYetki.ShowModal;
end;

initialization

RegisterClass(TEvrakListeFrame);

end.





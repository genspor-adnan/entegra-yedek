unit UFaturalar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxImageComboBox, FireDAC.Comp.Client, StdCtrls, DBCtrls, Buttons,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, ExtCtrls, ComCtrls, DateUtils,
  ToolWin, UGentegreFrameYonetimi, Menus, cxLookAndFeelPainters,ComObj, cxGrid,
  cxButtons, UFaturalarAramaFrame, dxSkinsCore, dxSkinscxPCPainter,
  cxDBEdit, cxButtonEdit, cxLabel, cxContainer, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxCurrencyEdit, Grids, frxClass, frxDBSet,
  cxSplitter, cxPC, cxDBLabel, dxSkinLondonLiquidSky, Utablo, UFrameYoneticisi,
  cxInplaceContainer, cxVGrid, cxDBVGrid, cxMemo, cxCheckBox, dxSkinLiquidSky,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, JvTimer, dxBarBuiltInMenu,
  UMailSablon, cxHyperLinkEdit, frxExportPdf, cxGridCustomPopupMenu,
  cxGridPopupMenu, cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView,
  OfficePopupMenu, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, frCoreClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, UEBelgeGelen, UHesapKoduPicker;

type
  TFaturalarDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    FATBASLIK: TFDQuery;
    DtsFatBaslik: TDataSource;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    GridFatListe: TcxGrid;
    GridFatListeTview: TcxGridDBTableView;
    GridFatListeTviewDURUM: TcxGridDBColumn;
    GridFatListeTviewFATURATARIH: TcxGridDBColumn;
    GridFatListeTviewFATURANO: TcxGridDBColumn;
    GridFatListeTviewID: TcxGridDBColumn;
    GridFatListeTviewREHBERID: TcxGridDBColumn;
    GridFatListeTviewTUR: TcxGridDBColumn;
    GridFatListeTviewDOSYANO: TcxGridDBColumn;
    GridFatListeTviewCARIAD: TcxGridDBColumn;
    GridFatListeTviewFATURA_MATRAHI: TcxGridDBColumn;
    GridFatListeTviewKDV_TUTARI: TcxGridDBColumn;
    GridFatListeTviewFATURA_TUTARI: TcxGridDBColumn;
    GridFatListeLevel1: TcxGridLevel;
    GridFatListeTviewPLAN: TcxGridDBColumn;
    GridFatListeTviewKUR: TcxGridDBColumn;
    cxPageControl1: TcxPageControl;
    SheetDetay:  TcxTabSheet;
    cxSplitter1: TcxSplitter;
    FATURA: TFDQuery;
    DtsDetay: TDataSource;
    Panel4: TPanel;
    GridFaturaToplam: TStringGrid;
    GridFat: TcxGrid;
    GridFatView:  TcxGridDBTableView;
    GridFatLevel1: TcxGridLevel;
    SilTus: TToolButton;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    YaziciYaz: TToolButton;
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
    frxFATBASLIK: TfrxDBDataset;
    pmFatIslemler: TPopupMenu;
    mnIrsaliyeyeDonustur: TMenuItem;
    mnFaturayaDonustur: TMenuItem;
    GridFatListeTviewACIKLAMA: TcxGridDBColumn;
    GridFatViewKOD: TcxGridDBColumn;
    GridFatViewACIKLAMA: TcxGridDBColumn;
    GridFatViewADET: TcxGridDBColumn;
    GridFatViewBIRIMFIYAT: TcxGridDBColumn;
    GridFatViewTUTAR: TcxGridDBColumn;
    GridFatViewISKONTO: TcxGridDBColumn;
    GridFatViewKDV: TcxGridDBColumn;
    GridFatViewMASRAFKOD: TcxGridDBColumn;
    GridFatViewMASRAFAD: TcxGridDBColumn;
    GridFatViewTUR: TcxGridDBColumn;
    GridFatViewBIRIM: TcxGridDBColumn;
    GridFatViewAD: TcxGridDBColumn;
    GridFatListeTviewSATICIADI: TcxGridDBColumn;
    SIPARISDETAY: TFDQuery;
    GridFatListeTviewFATDURUM: TcxGridDBColumn;
    TOPLAMLAR: TFDQuery;
    dtsTOPLAMLAR: TDataSource;
    tvFatToplamlar: TcxGridDBTableView;
    gridFatToplamLevel1: TcxGridLevel;
    gridFatToplam: TcxGrid;
    Panel1: TPanel;
    Label8: TcxLabel;
    Label10: TcxLabel;
    DOVIZ_TUTARI: TcxDBLabel;
    ComboDovizKur: TcxDBLabel;
    pmBelgeDonustur: TPopupMenu;
    mnIrsaliyesiniOlustur: TMenuItem;
    mnFaturasiniOlustur: TMenuItem;
    PopupMenu1: TPopupMenu;
    Kopyala2: TMenuItem;
    N4: TMenuItem;
    GridFatViewPROJEKODU: TcxGridDBColumn;
    GridFatListeTviewDOVIZ_FATURA_MATRAHI: TcxGridDBColumn;
    GridFatListeTviewDOVIZ_KDV_TUTARI: TcxGridDBColumn;
    GridFatListeTviewDOVIZ_TUTARI: TcxGridDBColumn;
    GridFatListeTviewDOVIZ_CINSI: TcxGridDBColumn;
    GridFatListeTviewFATURASERI: TcxGridDBColumn;
    GridFatListeTviewDURUMNEREDEN: TcxGridDBColumn;
    GridFatListeTviewDURUMNEREYE: TcxGridDBColumn;
    BelgeyiAc: TMenuItem;
    N5: TMenuItem;
    KaynakBelgeyiA1: TMenuItem;
    HedefBelgeyiA1: TMenuItem;
    cxDBMemo1: TcxDBMemo;
    GridFatListeTviewTESLIMTARIHI: TcxGridDBColumn;
    GridFatListeTviewDETAYBOLUMU: TcxGridDBColumn;
    GridFatListeTviewSUBEID: TcxGridDBColumn;
    GridFatListeTviewTIPI: TcxGridDBColumn;
    GridFatListeTviewSENARYO: TcxGridDBColumn;
    N6: TMenuItem;
    IptalIsaretleMenu: TMenuItem;
    GridFatViewTESLIMTARIHI: TcxGridDBColumn;
    GridFatViewKUR: TcxGridDBColumn;
    GridFatListeTviewSAYFASAY: TcxGridDBColumn;
    GridFatListeTviewBASLIK: TcxGridDBColumn;
    N7: TMenuItem;
    ExceldenBelgeEkle2: TMenuItem;
    OpenDialog1: TOpenDialog;
    SQLExcel: TMemo;
    TabExcel: TFDQuery;
    N8: TMenuItem;
    IadeAl: TMenuItem;
    Fatura1: TMenuItem;
    Pusula1: TMenuItem;
    GridFatListeTviewFATURA_GON_TARIHI: TcxGridDBColumn;
    GridFatListeTviewOZELKOD: TcxGridDBColumn;
    GridFatListeTviewZARF: TcxGridDBColumn;
    BtnBelgeZarfi: TToolButton;
    BtnEFaturaGuncelle: TToolButton;
    PanelKayitSayisi: TPanel;
    LabelKayitSayisi: TLabel;
    GridFatListeTviewVADE: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    GridFatListeTviewISEMRIDURUM: TcxGridDBColumn;
    ExceldenBelgeEkle: TMenuItem;
    N9: TMenuItem;
    TahsilOdemeMenu: TMenuItem;
    Nakit1: TMenuItem;
    HavaleEFT1: TMenuItem;
    ek1: TMenuItem;
    Senet1: TMenuItem;
    POSMenu: TMenuItem;
    N10: TMenuItem;
    ahsilatPlanla1: TMenuItem;
    frxSIPARISDETAY: TfrxDBDataset;
    SIPARIS: TFDQuery;
    frxSIPARIS: TfrxDBDataset;
    GridFatListeTviewYAZDIRILDI: TcxGridDBColumn;
    HizliGirisTus: TToolButton;
    GridFatListeTviewDOVIZKUR: TcxGridDBColumn;
    KrediKartiMenu: TMenuItem;
    KonsinyesiniOlusturMenu: TMenuItem;
    GridFatListeTviewORTKAR: TcxGridDBColumn;
    PopupFatGiris: TPopupMenu;
    AlSat1: TMenuItem;
    StopajMenu: TMenuItem;
    adeFaturas1: TMenuItem;
    EFaturaMenu1: TMenuItem;
    FiatFark1: TMenuItem;
    CizgiMenu1: TMenuItem;
    KurFark1: TMenuItem;
    BtnDonusum: TToolButton;
    GridFatListeTviewONAYLAYACAK: TcxGridDBColumn;
    GridFatListeTviewONAYLAYAN: TcxGridDBColumn;
    GridFatListeTviewEFATURADURUM: TcxGridDBColumn;
    GridFatListeTviewEFATURASONUC: TcxGridDBColumn;
    UretimFisiniOlutur: TMenuItem;
    rnOlarak1: TMenuItem;
    Sae1: TMenuItem;
    TabYorumMedya: TcxTabSheet;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    TabSmsEPosta: TFDQuery;
    DtsSmsEPosta: TDataSource;
    GridFatListeTviewVADETARIH: TcxGridDBColumn;
    GridFatViewSATICIKODU: TcxGridDBColumn;
    tvFatToplamlarTUR: TcxGridDBColumn;
    tvFatToplamlarACIKLAMA: TcxGridDBColumn;
    tvFatToplamlarDEGER: TcxGridDBColumn;
    tvFatToplamlarKUR: TcxGridDBColumn;
    tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn;
    tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    Panel2: TPanel;
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
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    SipariiniOlutur1: TMenuItem;
    SerbestMeslekMakbuzuMenu: TMenuItem;
    KiraMenu: TMenuItem;
    GiderPusulasiMenu: TMenuItem;
    PopupKonsGiris: TPopupMenu;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    IthalatMenu: TMenuItem;
    GridFatListeTviewOZELKOD2: TcxGridDBColumn;
    IhracatMenu: TMenuItem;
    IhracKayitliMenu: TMenuItem;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    GridFatViewURUNNO: TcxGridDBColumn;
    GridFatViewPOZNO: TcxGridDBColumn;
    GridFatViewSUTKODU: TcxGridDBColumn;
    MenuDurumuGuncelle: TMenuItem;
    N12: TMenuItem;
    mnSatisFisiniOlustur: TMenuItem;
    GridFatListeTviewCIKISDEPOADI: TcxGridDBColumn;
    N13: TMenuItem;
    infoMenu: TMenuItem;
    GridFatListeTviewSANAL: TcxGridDBColumn;
    N14: TMenuItem;
    MenueFatura: TMenuItem;
    MenuOlustur: TMenuItem;
    MenuOnizle: TMenuItem;
    MenuGonder: TMenuItem;
    N15: TMenuItem;
    MenuSeriDegistir: TMenuItem;
    MenuSifirla: TMenuItem;
    MenuHTMLKaydet: TMenuItem;
    MenuPDFKaydet: TMenuItem;
    N16: TMenuItem;
    MenuXMLKaydet: TMenuItem;
    PageControlTur: TcxPageControl;
    PageControlAlt: TcxPageControl;
    TabSheetTumu: TcxTabSheet;
    N17: TMenuItem;
    N19: TMenuItem;
    MenuMesajlarGoster: TMenuItem;
    MenuYanitla: TMenuItem;
    MenuKabulEt: TMenuItem;
    MenuRedEt: TMenuItem;
    rnEletirme1: TMenuItem;
    MenuUrunEslestir: TMenuItem;
    MenuEslesmeTablosunuAc: TMenuItem;
    MenuKDVIstisna: TMenuItem;
    Menu_Ihr_Istisna: TMenuItem;
    Menu_Ihr_Satis: TMenuItem;
    Menu_Ihr_Iade: TMenuItem;
    MenuTasnifDisinaTasi: TMenuItem;
    MenuSistemeTasi: TMenuItem;
    MenuGelenKutusunaTasi: TMenuItem;
    procedure MenuEslesmeTablosunuAcClick(Sender: TObject);
    procedure MenuUrunEslestirClick(Sender: TObject);
    procedure GridFatViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure GridFatListeTviewDblClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Calendar1Change(Sender: TObject);
    procedure CheckTarihAralikClick(Sender: TObject);
    procedure CheckEkAlanlarListeClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FATBASLIKAfterOpen(DataSet: TDataSet);
    procedure mnIrsaliyeyeDonusturClick(Sender: TObject);
    procedure GridFatListeTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridFatViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridFatListeTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure TOPLAMLARAfterOpen(DataSet: TDataSet);
    procedure mnIrsaliyesiniOlusturClick(Sender: TObject);
    procedure pmBelgeDonusturPopup(Sender: TObject);
    procedure Kopyala2Click(Sender: TObject);
    procedure BelgeyiAcClick(Sender: TObject);
    procedure KaynakBelgeyiA1Click(Sender: TObject);
    procedure HedefBelgeyiA1Click(Sender: TObject);
    procedure IptalIsaretleMenuClick(Sender: TObject);
    procedure ExceldenBelgeEkle2Click(Sender: TObject);
    procedure RbGunlukClick(Sender: TObject);
    procedure Fatura1Click(Sender: TObject);
    procedure BtnBelgeZarfiClick(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure ExceldenBelgeEkleClick(Sender: TObject);
    procedure Nakit1Click(Sender: TObject);
    procedure btnEPostaGonderClick(Sender: TObject);
    procedure HizliGirisTusClick(Sender: TObject);
    procedure AlSat1Click(Sender: TObject);
    procedure BtnDonusumClick(Sender: TObject);
    function TipSecimi(Tur:integer):integer;
    procedure DokumanTviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SmsEPostaTableViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure EPostaTusClick(Sender: TObject);
    procedure cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure TaraTusClick(Sender: TObject);
    procedure BelgeEkleTusClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure MenuDurumuGuncelleClick(Sender: TObject);
    procedure GridFatListeTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure infoMenuClick(Sender: TObject);
    procedure MenuOlusturClick(Sender: TObject);
    procedure MenuSistemeTasiClick(Sender: TObject);
    procedure MenuTasnifDisinaTasiClick(Sender: TObject);
    procedure MenuGelenKutusunaTasiClick(Sender: TObject);
    procedure _GelenDurumDegistir(AYeniEfat, AYeniEArsiv: Integer;
      ATutarSifirla: Boolean = False; ATutarUBLdenDoldur: Boolean = False);
    procedure MenuOnizleClick(Sender: TObject);
    procedure MenuSifirlaClick(Sender: TObject);
    procedure MenuHTMLKaydetClick(Sender: TObject);
    procedure MenuPDFKaydetClick(Sender: TObject);
    procedure MenuXMLKaydetClick(Sender: TObject);
    procedure MenuGonderClick(Sender: TObject);
    procedure MenuSeriDegistirClick(Sender: TObject);
    procedure PageControlTurChange(Sender: TObject);
    procedure PageControlAltChange(Sender: TObject);
    procedure MenuCariKaydiOlusturClick(Sender: TObject);
    procedure MenuMesajlarGosterClick(Sender: TObject);
    procedure BtnEFaturaGuncelleClick(Sender: TObject);
    procedure MenuKabulEtClick(Sender: TObject);
    procedure MenuRedEtClick(Sender: TObject);
  private

    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama : TFaturalarAramaFrame;
    FSayfali : TSayfaliListe;   // SAYFALI liste (merkezi yardimci, Utablo)
    // "Yeni Giden" (TUR=15) sekmesi icin gonderim tarihi araligi (son 2 is gunu)
    FYeniGidenBas, FYeniGidenBit: TDateTime;
    FEBelgeStyleYeni: TcxStyle;
    FEBelgeStyleSari: TcxStyle;
    FEBelgeStyleYesil: TcxStyle;
    FEBelgeStyleKirmizi: TcxStyle;
    FEBelgeStylePasif: TcxStyle;
    function EBelgeHucreStyle(var AStyleRef: TcxStyle; ABackColor, ATextColor: TColor): TcxStyle;
    // (Eski FGonderim* alanlari kaldirildi - kimlik bilgileri TEBelgeKimlik ortak cache'inden gelir)
    //FAltTur : Smallint;
    //FMenuTur : Smallint;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure _TabsheetleriYukle(AAltTur: Integer);
    procedure _GelenSekmeUygula;
    procedure _GidenSekmeUygula;
    procedure _YeniGidenSonFatura;
    procedure FATBASLIKFilterYeniGiden(DataSet: TDataSet; var Accept: Boolean);
    procedure _GelenSQLYukle(const ADurumIn, AEkKosul: string);
    procedure _KayitSayisiGuncelle;
    procedure _MenuTagFiltrele(AParent: TMenuItem; AHedefTag: Integer);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);

    procedure FaturaAc(ID : Integer);
    procedure SetArama(const Value: TFaturalarAramaFrame);
    procedure TarihDegisti;
    procedure PopUpDynamicSubMenuClick(Sender: TObject);
    //
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
    function BelgeIptalEt(Tur, ID: Integer): Boolean;
    function Add_Column(CType:SmallInt;const ACaption, AName: string): TcxGridColumn;
    procedure EkKolonSil;
    Function EkAlanlariGetir(TabloAdi:String):String;
    procedure EskiListe(Sender: TObject);
    procedure Liste_SP_Cagir(const SP_Adi, SelectList: string; const TopN: Integer;const Tur: SmallInt;const StartDate, EndDate : variant;
   const SubeIDList, Faturano, Baslik, CariFirma, Aciklama, Stok : string);
  public
    { Public declarations }
    SQLEk:string;
    // Liste kapsami: 0 = Tumu (normal), 1 = Son Aranan, 2 = Sik Aranan.
    //   1/2'de liste KULLANICI_ARAMA kayitlariyla sinirlanir; siralama Son'da
    //   tarihe, Sik'ta kullanim sayisina gore yapilir.
    FAramaModu: Integer;
    Basladi : Boolean;
    // NOT: ALANLAR metodlardan ONCE gelmeli (E2169) - yeni alan eklerken bu blogun
    //   ustune ekleyin, asagidaki metod listesinin arasina DEGIL.
    procedure AramaModuSec(Sender: TObject);
    procedure AramaModuUygula(AMod: Integer);   // modu ve buton gorunumunu birlikte ayarlar
    procedure InitIslemler;
  published

    property Arama : TFaturalarAramaFrame read FArama write SetArama;
  end;

var
  FaturalarDlg: TFaturalarDlg;
//Resourcestring
//  idd='İşaretlilerin Durumunu Değiştir' ;

implementation

uses  Fetautil, UVeriMotor, ULog, System.StrUtils, System.JSON, UAnaForm, FetaKurulusSiniflari, FetaClassExtensions, UKasaWizard, PrjConst,UGirisKutusuEx, UImport, UGenSifre, UEBelgeKimlik,
  UFastRap, UGenelAnaSekmeFrame, URaporAraclari,UFaturaGorevFrame,UNakitDlg,UBekletme, UBelgeZarflari,
  Ubelgegiris, UBelgeDonusum,LocOnFly, GenoTIP.eFatura.NativeApi, UBinarySave, UExceldenVeriAl,
  UEBelgeAliasServis, UEBelgeOlusturucu, UEBelgeMesajDlg, UIzibizRest,
  UStokEslestirme, UFaturaWizard;

{$R *.dfm}

var
  EkAlanlar, SipEkAlanlar, FatEkAlanlar : String;
  EkAlanKolonList : TStringList;
  TabloNo : Integer;

procedure TFaturalarDlg.AramaModuUygula(AMod: Integer);
// Kapsami ayarlar ve arama panelindeki uc butonun basili gorunumunu senkronlar.
//   Gorev panelindeki liste butonu da bunu cagirir (dogrudan "Son Aranan" ile acilir).
begin
  FAramaModu := AMod;
  if FArama <> nil then
  begin
    FArama.LabelTumKayitlar.Down  := (AMod = 0);
    FArama.LabelSonArananlar.Down := (AMod = 1);
    FArama.LabelSikArananlar.Down := (AMod = 2);
  end;
end;

procedure TFaturalarDlg.AramaModuSec(Sender: TObject);
// Arama panelindeki uc buton: Tumu / Son Aranan / Sik Aranan.
//   Buton Tag'i mod degil GORSEL secim icin kullanilir; mod bileşen ADINDAN belirlenir.
begin
  if not (Sender is TComponent) then Exit;
  if      TComponent(Sender).Name = 'LabelSonArananlar' then AramaModuUygula(1)
  else if TComponent(Sender).Name = 'LabelSikArananlar' then AramaModuUygula(2)
  else                                                       AramaModuUygula(0);
  JvTimer1.Enabled := True;   // listeyi yeniden kur (debounce timer)
end;

procedure TFaturalarDlg.InitIslemler;
var
  k : word;
  Item, SubItem : TMenuItem;
  i:integer;
  gf : TFaturaGorevFrame;
begin
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  gf.FMenuTur := gf.MenuTur;
  gf.FAltTur := gf.AltTur;

  // PageControlTur sekmelerini AltTur'e gore olustur
  _TabsheetleriYukle(gf.FAltTur);

  if EkAlanKolonList = nil then
     EkAlanKolonList := TStringList.Create
  else
     if EkAlanKolonList.Count > 0 then  //başka listeye geçildi.. önceki ek kolonlar silinmeli..
        EkKolonSil;

  BtnDonusum.Enabled := gf.FAltTur <> 101;// solda satınalma talepleri butonu basıldığında üstte dönüşüm butonu pasif olur..

  case gf.FAltTur of
  11,15 : begin
             YeniTus.DropdownMenu:=PopupFatGiris;
             IthalatMenu.Visible := gf.FAltTur = 11;
             IhracatMenu.Visible := gf.FAltTur = 15;
             IhracKayitliMenu.Visible := gf.FAltTur = 15;
             {if gf.FAltTur = 11 then
                IthalatIhracatMenu.Caption:=Ithalat
             else
                IthalatIhracatMenu.Caption:=Ihracat; }
          end;
  109   : YeniTus.DropdownMenu:=PopupKonsGiris;
  else
     YeniTus.DropdownMenu:=nil;
  end;

//   Tablo.DurumDoldur(Tur, GridFatListeTviewDURUM.Properties as TcxImageComboBoxProperties);
//03.05.2025 AO  Tablo.FaturaInit(gf.FMenuTur,TcxImageComboBoxProperties(GridFatListeTviewDURUM.Properties),TcxImageComboBoxProperties(GridFatDBTableView1TUR.Properties), TcxImageComboBoxProperties(GridFatDBTableView1BIRIM.Properties));

  Try
  //popupmenü oluşturulur,
    Item := TMenuItem.Create(PopupMenu1);
    Item.Caption := idd; //resourcestring
    PopupMenu1.Items.Add(Item);
  Finally
  //submenü oluşturulur...
     for i := 0 to (GridFatListeTviewDURUM.Properties as TcxImageComboBoxProperties).Items.Count - 1 do begin
       SubItem := TMenuItem.Create(Item);
       SubItem.Caption:=(GridFatListeTviewDURUM.Properties as TcxImageComboBoxProperties).Items[i].Description;
       SubItem.Tag :=(GridFatListeTviewDURUM.Properties as TcxImageComboBoxProperties).Items[i].Tag;
       SubItem.OnClick := PopUpDynamicSubMenuClick;
       Item.Add(SubItem);
     end;
  End;
  if gf.FMenuTur = 0 then begin //Giren faturalar görünecek
    Caption := 'Alış Belgeleri Listesi';
    TahsilOdemeMenu.Caption := 'Ödeme Yap';
    TahsilOdemeMenu.tag := 10;
    KrediKartiMenu.Visible:=True;
    //GridFatListeTviewDURUM.Caption := 'Ödeme Durumu';
  end else begin
    Caption := 'Satış Belgeleri Listesi';
    TahsilOdemeMenu.Caption := 'Tahsil Et';
    TahsilOdemeMenu.tag := 0;
    KrediKartiMenu.Visible:=False;
    //GridFatListeTviewDURUM.Caption := 'Tahsilat Durumu';
  end;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  if FFrameBilgi.Baslatildi then begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
  GridFatViewSUTKODU.VisibleForCustomization:= UTSKullanimda;
  GridFatViewSUTKODU.Visible := UTSKullanimda;

  // if EkAlanKolonList.Count > 0 then  //varsa önceki ek kolonlar silinmeli..
  //    EkKolonSil;
  // Tablo.GridAyarRestore('AlisSatisListeGridi-'+IntToStr(gf.FAltTur)+'-'+BoolToStr(FArama.CheckEkAlanlarListelensin.checked, False), GridFatListeTview );


  Tablo.GridTurkcelestir;
end;

procedure TFaturalarDlg.FATBASLIKAfterOpen(DataSet: TDataSet);
begin
//   DegisTus.Visible := True;
//   SilTus.Visible := True;
  _KayitSayisiGuncelle;
  // SP/sorgu yeniden yuklendiyse mevcut sekme filtresini tekrar uygula
  // (ozellikle Tumu sekmesinde EFATURADURUM in (0,-2) filtresi devresi icin)
  if (PageControlTur <> nil) and (PageControlTur.ActivePage <> nil) and
     (Pos('/*YENIGELEN*/', FATBASLIK.SQL.Text) = 0) then
    PageControlTurChange(PageControlTur);
end;

procedure TFaturalarDlg._KayitSayisiGuncelle;
// PanelKayitSayisi artik GIZLI (kullanici istegi: gridin altindaki "Kayıt Sayısı" seridi
// kaldirildi). Panel/label duruyor: e-Fatura senkronizasyonu ilerlemesini gosteriyor,
// o islem suresince gecici olarak gorunur yapilir (BtnEFaturaGuncelleClick).
var
  LSay: Integer;
begin
  if (PanelKayitSayisi = nil) or (LabelKayitSayisi = nil) then Exit;
  if FATBASLIK.Active then
    LSay := FATBASLIK.RecordCount
  else
    LSay := 0;
  LabelKayitSayisi.Caption := 'Kay'#$131't Say'#$131's'#$131': ' + IntToStr(LSay);
end;

procedure TFaturalarDlg._MenuTagFiltrele(AParent: TMenuItem; AHedefTag: Integer);
// Alt menu item'larini Tag'e gore goster/gizle:
//   Tag = 0           -> her zaman gorunur (ayraclar/genel)
//   Tag = AHedefTag   -> gorunur
//   diger             -> gizli
var
  i: Integer;
  LItem: TMenuItem;
begin
  if AParent = nil then Exit;
  for i := 0 to AParent.Count - 1 do begin
    LItem := AParent.Items[i];
    if LItem.Tag = 0 then
      LItem.Visible := True
    else
      LItem.Visible := LItem.Tag = AHedefTag;
  end;
end;


procedure TFaturalarDlg.TaraTusClick(Sender: TObject);
var
  ID: Integer;
  DYetkisonuc: DokumanYetkiSonuc;
begin
  if FATBASLIK.FieldByName('TUR').AsInteger in [9,19] then begin
    ID := Tablo.DokumanTara(Tablo.GENINI.ReadInteger(Ops_OpsiyonSiparis_VarsayilanKlasor, -2), FATBASLIK.FieldByName('REHBERID').AsInteger,TabNo_SIPARIS_DOKUMAN,FATBASLIK.FieldByName('ID').AsInteger);
//AA    if ID > 0 then
//AA      FATBASLIKAfterScroll(FATBASLIK);
  end else begin
    ID := Tablo.DokumanTara(Tablo.GENINI.ReadInteger(Ops_OpsiyonFatura_VarsayilanKlasor, -2), FATBASLIK.FieldByName('REHBERID').AsInteger,TabNo_FATBASLIK_DOKUMAN,FATBASLIK.FieldByName('ID').AsInteger);
 //AA   if ID > 0 then
 //AA     FATBASLIKAfterScroll(FATBASLIK);
  end
end;

procedure TFaturalarDlg.TarihDegisti;
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TFaturalarDlg.btnEPostaGonderClick(Sender: TObject);
var
  RaporAdi,EkranAdi,GidecekMail :String;
  AtacDosya,konu,icerik,Ad,kime,bilgi,gizli,FirmaAdi,SiparisNo: string;
  RehberId,Mailsayi,i: integer;
  Etiketler,Bilgiler:TArrayOfString;
  maill:Mailadresleris;
  gmail : dmailadresleri;
  LFileStream: TFileStream;
  SiparisTarih: TDateTime;
  MailAdresi:Variant;
  PDFExport: TfrxPDFExport;
  procedure YazdirmayaHazirlaEPosta(AFastReport: TfrxReport);
  var i:Integer;
  begin
    TabloYenile(SIPARIS, [FATBASLIK.Fields[0].AsString]);
    TabloYenile(SIPARISDETAY,[FATBASLIK.Fields[0].AsString]);
    frxSIPARIS.DataSet := SIPARIS;
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
    if AktifVeriMotor = vmPG then Tablo.TabMusteri.SQL.Text := PgSqlCevir(Tablo.TabMusteri.SQL.Text);
    Tablo.TabMusteri.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
    AFastReport.EnabledDataSets.Add(frxSIPARIS);
    AFastReport.EnabledDataSets.Add(frxSIPARISDETAY);
    AFastReport.EnabledDataSets.Add(frxFATBASLIK);
  end;

begin
 (* EkranAdi := EkranAdiAl;

  RaporAdi := YaziciYaz.Caption;
  Delete(RaporAdi, pos('&',RaporAdi), 1);
  //Delete(RaporAdi, pos('&',RaporAdi), 1);
  YazdirmayaHazirlaEPosta(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(0, EkranAdi, RaporAdi);

  FirmaAdi := FATBASLIK.FieldByName('CARIAD').AsString;
  SiparisTarih := SIPARIS.FieldByName('TARIH').AsDateTime;
  SiparisNo := SIPARIS.FieldByName('SIPARISNO').AsString;

  if Pos(' ',FirmaAdi) > 0 then
  begin
    FirmaAdi := Copy(FirmaAdi,0,Pos(' ',FirmaAdi)-1);
  end;

  AtacDosya:= GetEnvironmentVariable('Temp')+Concat('\', FirmaAdi, '_', IntToStr(YearOf(SiparisTarih)), '_', IntToStr(MonthOfTheYear(SiparisTarih)), '_', IntToStr(DayOfTheMonth(SiparisTarih)), '_', SiparisNo, '.pdf');
  //PDF kayıt edilecek.
  LFileStream := TFileStream.Create(AtacDosya, fmCreate or fmShareDenyNone);
  try
    PDFExport:=TfrxPDFExport.Create(nil);
    PDFExport.ShowDialog := False;
    PDFExport.ShowProgress := False;
    PDFExport.OverwritePrompt := False;
    //PDFExport.FileName := 'c:\report.pdf';
    PDFExport.Stream := LFileStream;
    try
      FastRaporDlg.frxReport1.PrepareReport(True);
    except
      on E: Exception do
        raise Exception.Create('PrepareReport direct error [UFaturalar.pas]: ' + E.Message);
    end;
    FastRaporDlg.frxReport1.Export(PDFExport);
  finally
    FreeAndNil(LFileStream);
    PDFExport.Stream := NIL;
    FreeAndNil(PDFExport);
  end;
  RehberId := FATBASLIK.FieldByName('REHBERID').AsInteger;

  ///Tekliflerde öncelik: ilgilinin maili varsa ona gider, ilgili yoksa kuruma gider, ikisinde de yoksa girin uyarısı verilir.
  Tablo.TablodanSorguAc(1,'SELECT  '+DbUst(1)+'RB.BILGI,RA.YERI  FROM REHBERBILGI RB INNER JOIN REHBERILETISIM RI ON RB.YER_ID=RI.ID'+
      ' INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA  AND RA.YERI=RB.YERI WHERE RI.REHBERID = '+inttostr(RehberId)+'  AND RB.YERI = 1'+
      ' and RI.VARSAYILAN=1 and RA.VARSAYILAN=46 '+DbSinir(1));

   if Tablo.Query1.RecordCount > 0 then
     GidecekMail := Tablo.Query1.FieldByName('BILGI').AsString
   else
   begin
    if Application.MessageBox(PChar(Mailbulunamadiadresekle),PWideChar(PrjConst.Onay),MB_ICONQUESTION+MB_YESNO) = IDYES then
    begin
      if TGirisKutusuEx.BilgiAlEx(BGMail_adres_gir,TGirdiDenetimleri.Create.Edit(BGMail_adresi,@MailAdresi)) = mrOk then
      begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.REHBERBILGI(YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, EKLEMETARIHI, DEGISTIREN, DEGISTIRMETARIHI, SUBEID)'+
        'VALUES  (1,(SELECT ID FROM REHBERILETISIM WHERE REHBERID=&REHBERID),'+
        '(SELECT SIRA FROM dbo.REHBERAYAR WHERE YERI=1 AND ETIKET=&ETIKET),'+
        '(SELECT ETIKET FROM dbo.REHBERAYAR WHERE ETIKET=&ETIKET AND YERI=1),'+
        '&BILGI,&EKLEYEN,&EKLEMETARIHI,0,NULL,&SUBEID)',['&REHBERID','&BILGI','&ETIKET','&EKLEYEN','&EKLEMETARIHI','&SUBEID'],[RehberId,MailAdresi,'EPosta',Kullanan,FormatDateTime('yyyy-MM-dd hh:nn:ss',Now),SubeId]);
      end;
    end;
    FreeAndNil(LFileStream);
   end;

  Tablo.MailSablonGetir(MODUL_Alis_Satis,konu,icerik);
  Mailsayi := Tablo.EMailSayisiGetir(RehberId); //mail adetini buluyor
  if mailsayi > 1 then
  begin    // Birden fazla mail adresi varsa mail seçim ekranı getirilip oradan mail adresleri seçiliyor ve mail gönderiliyor.
    SetLength(gmail,100);
    maill.kime:=TStringList.Create;
    maill.bilgi:=TStringList.Create;

    gmail:=Tablo.EMailBilgiGetir(FATBASLIK.FieldByName('REHBERID').AsInteger,GidecekMail);
    for i:=0 to Length(gmail) -1 do
    begin
      if (i=0) or (gmail[i].kime<>'') then
        maill.kime.add(gmail[i].kime);                              //Tablo.EMailBilgiGetir(rehberid)[i].kime;
      if  (i=0) or (gmail[i].bilgi<>'') then
        maill.bilgi.add(gmail[i].bilgi);                                                    //Tablo.EMailBilgiGetir(rehberid)[i].bilgi;
    end;
    Tablo.SendMail(konu,icerik,AtacDosya,'','','',maill.kime,maill.bilgi,nil,True);
  end else
  begin
    Tablo.RehberEkBilgileriniGetir(RehberId,1,[RehVars_EPosta],Etiketler,Bilgiler); //Bir tane mail adresi var ise mail adresi alinip mail gönderiliyor.
    maill.kime := TStringList.Create;
    maill.bilgi := TStringList.Create;

    if Bilgiler[0] ='' then begin
      //ShowMessage('Mail adresi bulunamadı!');
      maill.kime.add('');
      maill.bilgi.Add('');
      maill.kime.Add(bilgiler[0]);
      Tablo.SendMail(konu,icerik, AtacDosya,'','','',maill.kime,maill.bilgi,nil,True);
    end else begin
      maill.kime.add('');
      maill.bilgi.add('');
      maill.kime.Add(bilgiler[0]);
      Tablo.SendMail(konu,icerik,AtacDosya,'','','',maill.kime,maill.bilgi,nil,True);
    end;
  end;
  maill.kime.Free;
  maill.bilgi.Free;
  FreeAndNil(LFileStream);
  DeleteFile(AtacDosya);        *)
end;

procedure TFaturalarDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabloNo, FATBASLIK.FieldByName('ID').AsInteger, FATBASLIK.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TFaturalarDlg.EskiListe(Sender: TObject);
var
  SQLPart1,SQLPart2,SQLPart11,SQLPart21,SQLPart12,SQLPart22 : string;
  gf : TFaturaGorevFrame;
  LocateID:integer;
begin
 (* JvTimer1.Enabled := False;
  if (FATBASLIK.Active)and(FATBASLIK.RecordCount>0) then
      LocateID := FATBASLIK.FieldByName('ID').AsInteger;
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  BtnBelgeZarfi.Visible := gf.FAltTur=11; //SQLEk=' and F.TUR = 11 ';
  if Length(SQLEk)>10 then begin
    if (FArama.Calendar2.Text = '')or(FArama.Calendar1.Text = '')then  // DOVIZ_FATURA_MATRAHI=((FATURA_TUTARI-KDV_TUTARI)/nullif(DOVIZKUR,0.0))
       exit;
    SQLPart1 :=  'SELECT distinct '+DbUst(FArama.SpinKayitSayisi.EditValue)+'F.ID,F.DURUM,F.ODEMEPLANI,F.FATURATARIH,F.FATURANO,F.FATURASERI,F.TIPI,F.SENARYO,F.REHBERID,F.TUR,F.SUBEID,F.BASLIK, '+
//        ' FATURA_MATRAHI=FATURA_TUTARI-KDV_TUTARI,KDV_TUTARI,FATURA_TUTARI,F.KUR,FATURA_MALIYETI_ORT,'+
        ' FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI, F.KUR, FATURA_MALIYETI_ORT,'+
        ' ORTKARORAN=round((FATURA_MATRAHI-FATURA_MALIYETI_ORT)/nullif(FATURA_MALIYETI_ORT,0)*100.0,2),'+
        ' ORTKAR=FATURA_MATRAHI-FATURA_MALIYETI_ORT,  '+
        ' F.ACIKLAMA,F.OZELKOD,F.OZELKOD2, CARIKOD=R.KOD,CARIAD=R.FIRMA,DOVIZ_CINSI=F.RAPORDOVIZ,DOVIZKUR,F.DOVIZ_TUTARI,'+
        ' DOVIZ_FATURA_MATRAHI=isnull((F.DOVIZ_TUTARI-F.DOVIZ_TUTARI*(cast(KDV_TUTARI as float)/nullif(cast(FATURA_TUTARI as float),0))),0), '+
        ' DOVIZ_KDV_TUTARI=isnull((F.DOVIZ_TUTARI*(cast(KDV_TUTARI as float)/nullif(cast(FATURA_TUTARI as float),0)) ),0),'+
        ' F.GIRISDEPO,F.CIKISDEPO,F.IRSALIYENO , F.SATICIKODU,F.DETAYBOLUMU, SATICIADI = SATICIBILGI.FIRMA,F.VADE, VADETARIH=FATURATARIH + F.VADE,  ';
    if Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_DonusumGozuksun, True) then begin
      SQLPart1 := SQLPart1 + ' DURUMNEREDEN = case  '+
          '   when exists(select F2.ID from SIPARISDETAY F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (406,407,409,410,429,473) and F1.FATBASID=F.ID)) then ''Siparişten''  '+
          '   when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (408,410,411) and F1.FATBASID=F.ID)) then ''İrsaliyeden''  '+
          '   when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (461,462,464,468,472) and F1.FATBASID=F.ID)) then ''Konsinyeden''  '+
          '   when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (425,426) and F1.FATBASID=F.ID)) then ''Üretimden''  '+
          '   else '''' end,  '+
          ' DURUMNEREYE = case '+
          '   when (F.TUR=10)and(408 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''   '+
          '   when (F.TUR=14)and(411 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''   '+
          '   when (F.TUR=109)and(461 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''   '+
          '   when (F.TUR=119)and(462 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''   '+
          '   when (F.TUR=119)and(468 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''İrsaliyeye''   '+
          '   when (F.TUR=119)and(472 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Fişe''   '+
          '   else '''' end,    ';
    end else begin
      SQLPart1 := SQLPart1 + ' DURUMNEREDEN = '''', DURUMNEREYE =  '''',   ';
    end;

    SQLPart1 := SQLPart1 + FatEkAlanlar;
    SQLPart1 := SQLPart1 + ' TESLIMTARIHI='''',F.FATURA_GON_TARIHI, '+
        ' F.ZARFID,ZARF=(select AD from BELGEZARFI B where B.ID=F.ZARFID),ISEMRIDURUM=isnull((select I.DURUM from ISEMRI I where I.YERI=F.TUR and I.YERID=F.ID),-1),F.YAZDIRILDI, ' +
        ' ONAYLAYACAK=0,ONAYLAYAN=0,EFATURADURUM,EFATURASONUC' +
        ' from FATBASLIK F (NOLOCK) inner join REHBER R on R.ID = F.REHBERID '+
        ' LEFT OUTER JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID ' ;
    if FArama.AraStok.Text<> '' then
       SQLPart1:=SQLPart1+' LEFT OUTER JOIN FATURA FD  ON F.ID = FD.FATBASID '+
                          ' left outer join STOKLAR S on S.ID=FD.URUNID '+
                          ' left outer join MASRAFGELIR MG on MG.ID=FD.URUNID ';
    SQLPart11 :=  ' where 1=1'+SQLEk;
        if FArama.AraKod.Text<>'' then SQLPart11 := SQLPart11+' and (R.KOD like ''%'+Trim(FArama.AraKod.Text)+'%'' or R.FIRMA like ''%'+Trim(FArama.AraKod.Text)+'%'')';
//        if FArama.AraStok.Text<>'' then SQLPart11 := SQLPart11+' and (S.KOD like ''%'+Trim(FArama.AraStok.Text)+'%'' or S.STOKADI like ''%'+Trim(FArama.AraStok.Text)+'%'')';
        if FArama.AraStok.Text<>'' then SQLPart11 := SQLPart11+' and (S.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or S.STOKADI like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'''+
                                        ' or S.URUNNO like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'')';
        if FArama.AraAciklama.Text<>'' then SQLPart11 := SQLPart11+' and ISNULL(F.ACIKLAMA,'''') like ''%'+Trim(FArama.AraAciklama.Text)+'%''';
        if FArama.AraBaslik.Text<>'' then SQLPart11 := SQLPart11+' and isnull(F.BASLIK,'''') like ''%'+Trim(FArama.AraBaslik.Text)+'%'' ';
        if FArama.AraFaturaNo.Text<>'' then begin
           if gf.FAltTur in [9, 19, 101] then
              SQLPart11 := SQLPart11+' and ISNULL(SIPARISNO,'''') like ''%'+Trim(FArama.AraFaturaNo.Text)+'%'' '
           else
              SQLPart11 := SQLPart11+' and ISNULL(FATURANO,'''')  like ''%'+Trim(FArama.AraFaturaNo.Text)+'%'' ';
        end;
    SQLPart2 :=   'SELECT distinct '+DbUst(FArama.SpinKayitSayisi.EditValue)+'F.ID,F.DURUM,F.ODEMEPLANI,FATURATARIH=SIPARISTARIH,FATURANO=SIPARISNO,FATURASERI=F.SIPARISSERI,F.TIPI,SENARYO=CAST(NULL AS smallint),F.REHBERID,F.TUR,F.SUBEID,F.BASLIK,'+
        ' FATURA_MATRAHI=SIPARIS_TUTARI-KDV_TUTARI,'+
        ' KDV_TUTARI,FATURA_TUTARI=SIPARIS_TUTARI,F.KUR,KURFATURA_MALIYETI_ORT=0.0,ORTKARORAN=0.0, ORTKAR=0.0  ,F.ACIKLAMA,F.OZELKOD,F.OZELKOD2,CARIKOD=R.KOD,CARIAD=R.FIRMA,DOVIZ_CINSI=F.RAPORDOVIZ,F.DOVIZKUR,DOVIZ_TUTARI=(SIPARIS_TUTARI/nullif(DOVIZKUR,0.0)), '+
        ' DOVIZ_FATURA_MATRAHI=((SIPARIS_TUTARI-KDV_TUTARI)/nullif(DOVIZKUR,0.0)),DOVIZ_KDV_TUTARI=(cast(KDV_TUTARI as float)/nullif(cast(DOVIZKUR as float),0.0)) '+
        ' ,F.GIRISDEPO,F.CIKISDEPO,F.IRSALIYENO , F.SATICIKODU,F.DETAYBOLUMU, SATICIADI = SATICIBILGI.FIRMA, F.VADE, VADETARIH=SIPARISTARIH + F.VADE,  ';
        //' FATDURUM = '''', ';
    if Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_DonusumGozuksun, True) then begin
      SQLPart2 := SQLPart2 + ' DURUMNEREDEN = case  '+
          '   when (F.TUR=9)and(412 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Teklifden''  '+
          '   when (F.TUR=19)and(413 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Teklifden'' '+
          '   when (F.TUR=9)and(83 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Servisden''  '+
          '   when (F.TUR=19)and(83 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Servisden'' '+
          '   when (F.TUR=9)and(428 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Talepten'' '+
          '   when (F.TUR=101)and(465 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Üretimden'' '+
          '   else '''' end,  '+
          ' DURUMNEREYE = case '+
          ' 	when (F.TUR=9)and(407 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''    '+
          ' 	when (F.TUR=9)and(406 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye''  '+
          ' 	when (F.TUR=101)and(428 in (select YERI from SIPARISDETAY where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Siparişe''  '+
          ' 	when (F.TUR=19)and(410 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''   '+
          ' 	when (F.TUR=19)and(409 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye'' '+
          '   when (F.TUR=19)and(473 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Fişe''    '   +
          ' 	when (F.TUR=19)and(429 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Konsinyeye'' '+
          ' 	when (F.TUR=19)and(415 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine'' '+
          ' 	when (F.TUR=19)and(420 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine'' '+
          ' 	else '''' end,    ';
    end else begin
      SQLPart2 := SQLPart2 + ' DURUMNEREDEN = '''', DURUMNEREYE =  '''',   ';
    end;
    SQLPart2 := SQLPart2 + SipEkAlanlar;

    SQLPart2 := SQLPart2 + ' TESLIMTARIHI =(Select Min(TESLIMTARIHI) from SIPARISDETAY Where SIPARISID=F.ID ), FATURA_GON_TARIHI=null, '+
        ' ZARFID=null,ZARF=null,ISEMRIDURUM=isnull((select I.DURUM from ISEMRI I where I.YERI=F.TUR and I.YERID=F.ID),-1),F.YAZDIRILDI, '+
        ' F.ONAYLAYACAK,F.ONAYLAYAN,EFATURADURUM=0,EFATURASONUC=0' +
        ' from SIPARIS F (NOLOCK) inner join REHBER R on R.ID = F.REHBERID '+
        ' LEFT OUTER JOIN SIPARISDETAY SD ON F.ID = SD.SIPARISID'+
        ' LEFT OUTER JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID ' ;
        if FArama.AraStok.Text<> '' then
          SQLPart2:=SQLPart2+' LEFT OUTER JOIN FATURA FD  ON F.ID = FD.FATBASID '+
                             ' left outer join STOKLAR S on S.ID=SD.URUNID '+
                             ' left outer join MASRAFGELIR MG on MG.ID=SD.URUNID  ';

//    SQLPart21 := ' where (ISNULL(R.KOD,'''') like ''%'+FArama.AraKod.Text+'%'' or ISNULL(R.FIRMA,'''') like ''%'+FArama.AraKod.Text+'%'') and '+
//        ' ISNULL(F.ACIKLAMA,'''') like ''%'+FArama.AraAciklama.Text+'%'' and isnull(F.BASLIK,'''') like ''%'+FArama.AraBaslik.Text+'%''  '+
//        ' and ISNULL(SIPARISNO,'''') like ''%'+FArama.AraFaturaNo.Text+'%'' '+SQLEk ;
    SQLPart21 :=  ' where 1=1'+SQLEk;
        if FArama.AraKod.Text<>'' then SQLPart21 := SQLPart21+' and (R.KOD like ''%'+Trim(FArama.AraKod.Text)+'%'' or R.FIRMA like ''%'+Trim(FArama.AraKod.Text)+'%'')';
        if FArama.AraStok.Text<>'' then SQLPart21 := SQLPart21+' and (S.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or S.STOKADI like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'''+
                                        ' or S.URUNNO like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'')';
        if FArama.AraAciklama.Text<>'' then SQLPart21 := SQLPart21+' and ISNULL(F.ACIKLAMA,'''') like ''%'+Trim(FArama.AraAciklama.Text)+'%''';
        if FArama.AraBaslik.Text<>'' then SQLPart21 := SQLPart21+' and isnull(F.BASLIK,'''') like ''%'+Trim(FArama.AraBaslik.Text)+'%'' ';
        if FArama.AraFaturaNo.Text<>'' then begin
           if gf.FAltTur in [9, 19, 101] then
              SQLPart21 := SQLPart21+' and ISNULL(SIPARISNO,'''') like ''%'+Trim(FArama.AraFaturaNo.Text)+'%'' '
           else
              SQLPart21 := SQLPart21+' and ISNULL(FATURANO,'''') like ''%'+Trim(FArama.AraFaturaNo.Text)+'%'' ';
        end;
    if gf.FAltTur<=0 then begin
      FATBASLIK.SQL.Text := SQLPart1;
      FATBASLIK.SQL.Add(SQLPart11);
      if FArama.CheckTarihAralik.checked then
         FATBASLIK.SQL.Add(' and FATURATARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', FArama.Calendar1.Date)+''' and '+
                              ' FATURATARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59:59', FArama.Calendar2.Date)+'''');
        if FArama.AraStok.Text<> '' then
           FATBASLIK.SQL.Add(' and (S.STOKADI like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or S.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or S.URUNNO like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%''  or MG.AD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or MG.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%''  )');
        if SubeVarmi then
           FATBASLIK.SQL.Add( ' and F.SUBEID in('+Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme)+') ');
//      FATBASLIK.SQL.Text:= FATBASLIK.SQL.Text+ ' GROUP BY F.ID,F.DURUM,F.ODEMEPLANI,F.FATURATARIH,F.FATURANO,F.FATURASERI,F.TIPI,F.REHBERID,F.TUR,FATURA_MATRAHI,F.SUBEID, KDV_TUTARI,(KDV_TUTARI/nullif(DOVIZKUR,0)),FATURA_TUTARI,F.KUR,' + #13#10 +
//                                     'F.ACIKLAMA,F.OZELKOD, R.KOD, R.FIRMA,F.DOVIZ_CINSI,F.DOVIZ_TUTARI,F.DOVIZKUR,F.GIRISDEPO,F.CIKISDEPO,F.IRSALIYENO,F.BAGLIFATURAID ,' + #13#10 +
//                                     'F.SATICIKODU,F.DETAYBOLUMU, SATICIBILGI.FIRMA,F.VADE,F.SUBEID,F.BASLIK,FATURA_GON_TARIHI,F.ZARFID,'+EkAlanlar+'F.YAZDIRILDI' ;
      FATBASLIK.SQL.Add( ' union all ');
      FATBASLIK.SQL.Add( SQLPart2 );
      FATBASLIK.SQL.Add(SQLPart21);
      if FArama.CheckTarihAralik.checked then
         FATBASLIK.SQL.Add(' and SIPARISTARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', FArama.Calendar1.Date)+''' and '+
                              ' SIPARISTARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59:59', FArama.Calendar2.Date)+'''');
      if FArama.AraStok.Text<> '' then
          FATBASLIK.SQL.Add(' and (S.STOKADI like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or S.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%''  or S.URUNNO like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or MG.AD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or MG.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%''  )');
      if SubeVarmi then
          FATBASLIK.SQL.Add( ' and F.SUBEID in('+Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme)+') ');

//      FATBASLIK.SQL.Text:= FATBASLIK.SQL.Text+ ' GROUP BY F.ID,F.DURUM,F.ODEMEPLANI,SIPARISTARIH,SIPARISNO,F.SIPARISSERI,F.TIPI,F.REHBERID,F.TUR,SIPARIS_MATRAHI,F.SUBEID,(KDV_TUTARI/nullif(DOVIZKUR,0)),'+
//                                           ' KDV_TUTARI,SIPARIS_TUTARI,F.KUR,F.ACIKLAMA, F.OZELKOD, R.KOD,R.FIRMA,F.DOVIZKUR,F.DOVIZ_CINSI,F.DOVIZ_TUTARI,'+
//                                           ' F.GIRISDEPO,F.CIKISDEPO,F.IRSALIYENO , F.SATICIKODU, F.DETAYBOLUMU,  SATICIBILGI.FIRMA,F.BASLIK, F.VADE,'+EkAlanlar+'F.YAZDIRILDI' ;
    end else if gf.FAltTur in [9, 19, 101] then begin
      case gf.FAltTur of
       9  : GridFatListeTviewDURUM.RepositoryItem := Tablo.repSiparisDurumVerilen;
       19 : GridFatListeTviewDURUM.RepositoryItem := Tablo.repSiparisDurumAlinan;
       101: GridFatListeTviewDURUM.RepositoryItem := Tablo.RepSatinalmaAsama;
      end;
      FATBASLIK.SQL.Text := SQLPart2;
      FATBASLIK.SQL.Add(SQLPart21);
      if FArama.CheckTarihAralik.checked then
         FATBASLIK.SQL.Add(' and SIPARISTARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', FArama.Calendar1.Date)+''' and '+
                              ' SIPARISTARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59:59', FArama.Calendar2.Date)+'''');
      if FArama.AraStok.Text<> '' then
          FATBASLIK.SQL.Add(' and (S.STOKADI like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or S.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%''  or S.URUNNO like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or MG.AD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%'' or MG.KOD like ''%'+AramaMetniTemizle(FArama.AraStok.Text)+'%''  )');
      if SubeVarmi then
          FATBASLIK.SQL.Add( ' and F.SUBEID in('+Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme)+') ');
//         FATBASLIK.SQL.Text:= FATBASLIK.SQL.Text+ ' GROUP BY F.ID,F.DURUM,F.ODEMEPLANI,SIPARISTARIH,SIPARISNO,F.SIPARISSERI,F.TIPI,F.REHBERID,F.TUR,SIPARIS_MATRAHI,F.SUBEID,(KDV_TUTARI/nullif(DOVIZKUR,0)),'+
//                                           ' KDV_TUTARI,SIPARIS_TUTARI,F.KUR,F.ACIKLAMA,F.OZELKOD,R.KOD,R.FIRMA,F.DOVIZKUR,F.DOVIZ_CINSI,F.DOVIZ_TUTARI  ,'+
//                                           ' F.GIRISDEPO,F.CIKISDEPO,F.IRSALIYENO , F.SATICIKODU, F.DETAYBOLUMU,  SATICIBILGI.FIRMA,F.VADE, F.BASLIK,'+EkAlanlar+'F.YAZDIRILDI' ;
    end else begin
      if gf.FAltTur in [11,12,13,14] then
        GridFatListeTviewDURUM.RepositoryItem := Tablo.RepFaturaGelenDurum
      else if gf.FAltTur in [15,16,17] then
        GridFatListeTviewDURUM.RepositoryItem := Tablo.RepFaturaGidenDurum;
      FATBASLIK.SQL.Text := SQLPart1;
      FATBASLIK.SQL.Add(SQLPart11);
      if FArama.CheckTarihAralik.checked then
         FATBASLIK.SQL.Add(' and FATURATARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', FArama.Calendar1.Date)+''' and '+
                              ' FATURATARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59:59', FArama.Calendar2.Date)+'''');
//      if FArama.AraStok.Text<> '' then
//        FATBASLIK.SQL.Add(' and (S.STOKADI like ''%'+FArama.AraStok.Text+'%'' or S.KOD like ''%'+FArama.AraStok.Text+'%'' or MG.AD like ''%'+FArama.AraStok.Text+'%'' or MG.KOD like ''%'+FArama.AraStok.Text+'%''  )');
      if SubeVarmi then
          FATBASLIK.SQL.Add( ' and F.SUBEID in('+Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme)+') ');
//      FATBASLIK.SQL.Text:= FATBASLIK.SQL.Text+ ' GROUP BY F.ID,F.DURUM,F.ODEMEPLANI,F.FATURATARIH,F.DOVIZKUR,F.RAPORDOVIZ,F.FATURANO,F.FATURASERI,F.TIPI,'+
//                'F.REHBERID,F.TUR,FATURA_MATRAHI,F.SUBEID, KDV_TUTARI,(KDV_TUTARI/nullif(DOVIZKUR,0)), KDV_TUTARI,FATURA_TUTARI,F.KUR,F.FATURA_MALIYETI_ORT,' + #13#10 +
//                'FATURA_MATRAHI-ISNULL(FATURA_MALIYETI_ORT,0),F.ACIKLAMA,F.OZELKOD, R.KOD, R.FIRMA,F.DOVIZ_CINSI,F.DOVIZ_TUTARI,F.BAGLIFATURAID,F.GIRISDEPO,F.CIKISDEPO,F.IRSALIYENO ,' + #13#10 +
//                'F.SATICIKODU, F.DETAYBOLUMU, SATICIBILGI.FIRMA, F.VADE, F.BASLIK,FATURA_GON_TARIHI,F.ZARFID,'+EkAlanlar+'F.YAZDIRILDI';
    end;
    FATBASLIK.SQL.Add(' ORDER BY F.ID desc,F.TUR,F.KUR '+DbSinir(FArama.SpinKayitSayisi.EditValue));
    TabloYenile(FATBASLIK,[],LocateID,'ID');

    case gf.FAltTur of
      3  : TabloNo := TabNo_FIS_Gelen;
      4  : TabloNo := TabNo_FIS_Giden;
      8  : TabloNo := Tabno_GIDERPUSULASI;
      9  : TabloNo := TabNo_SIPARIS_Gelen;
      10 : TabloNo := TabNo_IRSALIYE_Gelen;
      11 : TabloNo := TabNo_FATBASLIK_Gelen;
      12 : TabloNo := TabNo_FIS_Gelen;
      14 : TabloNo := TabNo_IRSALIYE_Giden;
      15 : TabloNo := TabNo_FATBASLIK_Giden;
      16 : TabloNo := TabNo_FIS_Giden;
      19 : TabloNo := TabNo_SIPARIS_Gelen; //TabNo_SIPARIS_Giden;
      101 : TabloNo := TabNo_SATINALMA;
      109: TabloNo := TabNo_KONSINYE_GELEN;
      110: TabloNo := Tabno_GIDERPUSULASI;
      119: TabloNo := TabNo_KONSINYE_GIDEN;
    end;

    if gf.FMenuTur=1  then begin
      GridFatDBTableView1MASRAFAD.Caption:= 'Gelir Adı';
      GridFatDBTableView1MASRAFKOD.Caption:= 'Gelir Kodu';
    end else begin
      GridFatDBTableView1MASRAFAD.Caption:= 'Masraf Adı';
      GridFatDBTableView1MASRAFKOD.Caption:= 'Masraf Kodu';
    end;
  end;
  GridFatListeTview.ViewData.Expand(True);         *)
end;

procedure TFaturalarDlg.Liste_SP_Cagir(const SP_Adi, SelectList: string; const TopN: Integer;const Tur: SmallInt;const StartDate, EndDate : variant;
   const SubeIDList, Faturano, Baslik, CariFirma, Aciklama, Stok : string);
// Diger liste SP'leri gibi 2-param JSON cagrisi: @Baslik (SELECT ek kolonlari,
// =eski SelectList) + @Kosullar (JSON filtreler). SP adi *_Json2 gelir.
var
  LKosullar: TJSONObject;
begin
    LKosullar := TJSONObject.Create;
    try
      LKosullar.AddPair('TopN', TJSONNumber.Create(TopN));
      LKosullar.AddPair('Tur', TJSONNumber.Create(Tur));
      // Tarihler yalniz filtre aciksa (null degilse) eklenir -> absent = filtre yok.
      if not (VarIsNull(StartDate) or VarIsEmpty(StartDate)) then
        LKosullar.AddPair('StartDate', VarToStr(StartDate));
      if not (VarIsNull(EndDate) or VarIsEmpty(EndDate)) then
        LKosullar.AddPair('EndDate', VarToStr(EndDate));
      LKosullar.AddPair('SubeIDList', SubeIDList);       // duz comma-sep (ornek: '-1,0,1,2')
      LKosullar.AddPair('Faturano', Faturano);
      LKosullar.AddPair('Baslik', Baslik);               // fatura basligi aramasi (eski @Baslik)
      LKosullar.AddPair('CariFirma', CariFirma);
      LKosullar.AddPair('Aciklama', Aciklama);
      LKosullar.AddPair('Stok', Stok);
      // SON ARANAN modu: gorev panelindeki liste butonu bu modu acar. Kullanicinin bu belge
      //   turunde son actigi/kestigi belgeler (KULLANICI_ARAMA) listelenir, en son dokunulan
      //   en ustte. Modul = belge turunun MODUL.MODULID'si -> her tur AYRI liste.
      if FAramaModu > 0 then
      begin
        LKosullar.AddPair('SonAranan', TJSONNumber.Create(FAramaModu));   // 1=Son, 2=Sik
        LKosullar.AddPair('Modul', TJSONNumber.Create(Tablo.BelgeModulID(Tur)));
        LKosullar.AddPair('Kul',   TJSONNumber.Create(StrToIntDef(Kullanan, 0)));
      end;

      // MOTOR SEAM (Utablo.ListeSPJson ile ayni): MSSQL EXEC dbo.sp_Prog_X ;
      //   PG SELECT * FROM fn_prog_x (ayni @Baslik+@Kosullar). fn adi = 'fn_'+lower(sp_'den-sonrasi).
      if AktifVeriMotor = vmPG then
        FATBASLIK.SQL.Text := 'SELECT * FROM fn_' + LowerCase(Copy(SP_Adi, 4, MaxInt)) + '(:Baslik, :Kosullar)'
      else
        FATBASLIK.SQL.Text := 'EXEC dbo.' + SP_Adi + ' @Baslik=:Baslik, @Kosullar=:Kosullar';
      FATBASLIK.ParamByName('Baslik').Value := SelectList;   // SELECT ek kolonlari
      FATBASLIK.ParamByName('Kosullar').Value := LKosullar.ToJSON;
    finally
       LKosullar.Free;
    end;

    FATBASLIK.DisableControls;
    TabloYenile(FATBASLIK,[]);
    FATBASLIK.EnableControls;
    FSayfali.YuklemeSonrasi;   // SAYFALI: ekran dolana kadar zincirleme sayfa
end;




procedure TFaturalarDlg.JvTimer1Timer(Sender: TObject);
var
 // SQLPart1,SQLPart2,SQLPart11,SQLPart21,SQLPart12,SQLPart22 : string;
  gf :  TFaturaGorevFrame;
  SubeIDList : string;
  TarihBas, TarihBit : variant;
  TopN : Integer;
 // LocateID:integer;
begin
   JvTimer1.Enabled := False;
   // Gelen Kutusu sekmesinde standart SP sorgusunu calistirma; FArama filtre
   // degisiminde gelen kutusu sorgusunu yeniden insa etmek icin
   // PageControlTurChange'e route et.
   if (PageControlTur.ActivePage <> nil) and (PageControlTur.ActivePage.Tag >= 1201) and (PageControlTur.ActivePage.Tag <= 1203) then begin
     FSayfali.TopN(False);   // Gelen Kutusu kendi sorgusunu kurar -> sayfalama tetikleri PASIF
     PageControlTurChange(PageControlTur);
     Exit;
   end;
 // if (FATBASLIK.Active)and(FATBASLIK.RecordCount>0) then
//      LocateID := FATBASLIK.FieldByName('ID').AsInteger;
   gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
   // Belge Zarfi e-Belge ozelligidir: gelen fatura (11) + e-Fatura kullanimda ise.
   BtnBelgeZarfi.Visible := (gf.FAltTur=11) and (EFaturaKullanimda>0);

   SubeIDList := Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme);
   if SubeIDList = '-999' then
       SubeIDList := '-1';

   if FArama.CheckEkAlanlarListelensin.checked then
      case gf.FAltTur of
        9,19,101 : if EkAlanKolonList.Count = 0 then     //if SipEkAlanlar=''
                  SipEkAlanlar := EkAlanlariGetir('SIPARIS');
        else  if EkAlanKolonList.Count = 0 then       //if FatEkAlanlar=''
                  FatEkAlanlar := EkAlanlariGetir('FATBASLIK');
      end;

   if FArama.CheckTarihAralik.Checked then begin
      TarihBas := FormatDateTime('yyyy-mm-dd 00:00', FArama.Calendar1.Date);
      TarihBit := FormatDateTime('yyyy-mm-dd 23:59', FArama.Calendar2.Date);
   end
   else begin
       TarihBas := null;
       TarihBit := null;
   end;

   // SAYFALI liste (TSayfaliListe): TOP N artik sayfa siniri; sayfa boyu GENEL OPSIYON'dan
   // (Ops_GenelOpsiyon_GridListeUzunlugu, vars.100). Ekrandaki kayit sayisi spin'i kaldirildi.
   TopN := FSayfali.TopN;

   // SON ARANAN modu yalniz "temiz" listede gecerlidir: kullanici arama kutularindan
   //   birine deger yazdiysa normal aramaya doner (aksi halde arama sonucu son-aranan
   //   kayitlariyla kesisir ve kullanici aradigini bulamaz).
   if (FAramaModu > 0) and
      ((Trim(FArama.AraFaturaNo.Text) <> '') or (Trim(FArama.AraBaslik.Text) <> '') or
       (Trim(FArama.AraKod.Text) <> '') or (Trim(FArama.AraAciklama.Text) <> '') or
       (Trim(FArama.AraStok.Text) <> '')) then
     FAramaModu := 0;

   if gf.FAltTur in [9, 19, 101] then // al sat sipariş ve satınalma talebi
      Liste_SP_Cagir('sp_Prog_AlisSatis_Siparis_Json2', SipEkAlanlar, TopN, gf.FAltTur, TarihBas, TarihBit,
      SubeIDList, Trim(FArama.AraFaturaNo.Text), Trim(FArama.AraBaslik.Text),Trim(FArama.AraKod.Text),Trim(FArama.AraAciklama.Text),Trim(FArama.AraStok.Text))
   else
      Liste_SP_Cagir('sp_Prog_AlisSatis_IrsFatFisKons_Json2', FatEkAlanlar, TopN, gf.FAltTur, TarihBas, TarihBit,
      SubeIDList, Trim(FArama.AraFaturaNo.Text), Trim(FArama.AraBaslik.Text),Trim(FArama.AraKod.Text),Trim(FArama.AraAciklama.Text),Trim(FArama.AraStok.Text));



    case gf.FAltTur of
          3  : TabloNo := TabNo_FIS_Gelen;
          4  : TabloNo := TabNo_FIS_Giden;
          8  : TabloNo := Tabno_GIDERPUSULASI;
          9  : TabloNo := TabNo_SIPARIS_Gelen;
          10 : TabloNo := TabNo_IRSALIYE_Gelen;
          11 : TabloNo := TabNo_FATBASLIK_Gelen;
          12 : TabloNo := TabNo_FIS_Gelen;
          14 : TabloNo := TabNo_IRSALIYE_Giden;
          15 : TabloNo := TabNo_FATBASLIK_Giden;
          16 : TabloNo := TabNo_FIS_Giden;
          19 : TabloNo := TabNo_SIPARIS_Gelen; //TabNo_SIPARIS_Giden;
          101 : TabloNo := TabNo_SATINALMA;
          109: TabloNo := TabNo_KONSINYE_GELEN;
          110: TabloNo := Tabno_GIDERPUSULASI;
          119: TabloNo := TabNo_KONSINYE_GIDEN;
    end;

    if gf.FMenuTur=1  then begin
      GridFatViewMASRAFAD.Caption:= 'Gelir Adı';
      GridFatViewMASRAFKOD.Caption:= 'Gelir Kodu';
    end else begin
      GridFatViewMASRAFAD.Caption:= 'Masraf Adı';
      GridFatViewMASRAFKOD.Caption:= 'Masraf Kodu';
    end;

    case gf.FAltTur of
     9  : GridFatListeTviewDURUM.RepositoryItem := Tablo.repSiparisDurumVerilen;
     19 : GridFatListeTviewDURUM.RepositoryItem := Tablo.repSiparisDurumAlinan;
     101: GridFatListeTviewDURUM.RepositoryItem := Tablo.RepSatinalmaAsama;
     11,12,13,14 : GridFatListeTviewDURUM.RepositoryItem := Tablo.RepFaturaGelenDurum;
     15,16,17 : GridFatListeTviewDURUM.RepositoryItem := Tablo.RepFaturaGidenDurum;
    end;

  Tablo.GridAyarRestore('AlisSatisListeGridi-'+IntToStr(gf.FAltTur)+'-'+BoolToStr(FArama.CheckEkAlanlarListelensin.checked, False), GridFatListeTview );

  Self.Align := alClient;
  GridFatListe.LookAndFeel.ScrollbarMode := sbmClassic;
  GridFatListeTview.OptionsView.ScrollBars := ssBoth;
  GridFatView.OptionsView.ScrollBars := ssBoth;

  MenuKabulEt.OnClick := MenuKabulEtClick;
  MenuRedEt.OnClick := MenuRedEtClick;

   GridFatListeTview.ViewData.Expand(True);
end;



procedure TFaturalarDlg.TOPLAMLARAfterOpen(DataSet: TDataSet);
begin
  tvFatToplamlar.ApplyBestFit(nil);
end;

function TFaturalarDlg.EkranAdiAl: string;
begin
  Result := 'FaturaListeDlg';
end;

procedure TFaturalarDlg.RbGunlukClick(Sender : TObject);
begin
  if FArama.RbGunluk.Checked then begin
    GenRegIni.RegWriteString('', 'RadioGunluk', '1', 'C');
    FArama.Calendar1.Date := Tablo.GENINI.BugunTrh;
    FArama.Calendar2.Date := Tablo.GENINI.BugunTrh;
  end else
    GenRegIni.RegWriteString('', 'RadioGunluk', '0', 'C');

  if FArama.RbHaftalik.Checked then begin
    GenRegIni.RegWriteString('', 'RadioHaftalik', '1', 'C');
    FArama.calendar1.Date := Tablo.GENINI.BugunTrh-7;
    FArama.Calendar2.Date := Tablo.GENINI.BugunTrh;
  end else
    GenRegIni.RegWriteString('', 'RadioHaftalik', '0', 'C');

  if FArama.RbAylik.Checked then begin
    GenRegIni.RegWriteString('', 'RadioAylik', '1', 'C');
    FArama.calendar1.Date := Tablo.GENINI.BugunTrh-30;
    FArama.Calendar2.Date := Tablo.GENINI.BugunTrh;
  end else
    GenRegIni.RegWriteString('', 'RadioAylik', '0', 'C');
  TarihDegisti;
end;

procedure TFaturalarDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxFATBASLIK) then
      AFastReport.EnabledDataSets.Add(frxFATBASLIK)
   else begin
      frxFATBASLIK.DataSet := FATBASLIK;
      frxSIPARISDETAY.DataSet := SIPARISDETAY;
      AFastReport.EnabledDataSets.Add(frxFATBASLIK);
      AFastReport.EnabledDataSets.Add(frxSIPARISDETAY);
   end;
   // Kullanici ek alanlari (_USER) rapora: baslik (kart) + satirlar (detay).
   if FATBASLIK.Active and (not FATBASLIK.IsEmpty) then begin
      Tablo.UserAlanYazdirmaEkle(AFastReport, 'FATBASLIK', FATBASLIK.FieldByName('ID').AsInteger);
      Tablo.UserAlanYazdirmaEkle(AFastReport, 'FATURA', 0,
        'select ID from FATURA where FATBASID=' + FATBASLIK.FieldByName('ID').AsString);
   end;
end;

procedure TFaturalarDlg.Calendar1Change(Sender: TObject);
begin
   TarihDegisti;
end;

procedure TFaturalarDlg.CheckEkAlanlarListeClick(Sender: TObject);
var  gf : TFaturaGorevFrame;
begin

   gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);


   if EkAlanKolonList.Count > 0 then  //varsa önceki ek kolonlar silinmeli..
      EkKolonSil;
   Gorunur;
   TarihDegisti;
//   Tablo.GridAyarRestore('AlisSatisListeGridi-'+IntToStr(gf.FAltTur)+'-'+BoolToStr(FArama.CheckEkAlanlarListelensin.checked, False), GridFatListeTview );
end;

procedure TFaturalarDlg.CheckTarihAralikClick(Sender: TObject);
begin
   FArama.Panel1.Visible:= FArama.CheckTarihAralik.Checked;
   TarihDegisti;
end;

procedure TFaturalarDlg.cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
var TabloNo :integer;
begin
   if FATBASLIK.active=False then exit;

   if FATBASLIK.FieldByName('TUR').AsInteger in [9,19,101] then begin
      DtsDetay.DataSet:= SIPARISDETAY;
      TabloYenile(SIPARISDETAY, [FATBASLIK.Fields[0].AsInteger]);
      // MOTOR SEAM: MSSQL EXEC dbo.SP ; PG SELECT * FROM fn_prg_...(id).
      if AktifVeriMotor = vmPG then
        TOPLAMLAR.SQL.Text:= 'SELECT * FROM fn_prg_siparis_diptoplami('+IntToStr(FATBASLIK.Fields[0].AsInteger)+')'
      else
        TOPLAMLAR.SQL.Text:= 'EXEC SP_PRG_Siparis_DipToplami '+IntToStr(FATBASLIK.Fields[0].AsInteger);
   end else begin
      DtsDetay.DataSet:= FATURA;
      TabloYenile(FATURA, [FATBASLIK.Fields[0].AsInteger]);
      if AktifVeriMotor = vmPG then
        TOPLAMLAR.SQL.Text:= 'SELECT * FROM fn_prg_faturadiptoplami('+IntToStr(FATBASLIK.Fields[0].AsInteger)+')'
      else
        TOPLAMLAR.SQL.Text:= 'EXEC SP_PRG_FaturaDipToplami '+IntToStr(FATBASLIK.Fields[0].AsInteger);
   end;
   TabloYenile(TOPLAMLAR, []);
   //btnEPostaGonder.Visible := True;;
   if NewPage = TabYorumMedya then begin
      case FATBASLIK.FieldByName('TUR').AsInteger  of
        3  : TabloNo := TabNo_FIS_Gelen;
        4  : TabloNo := TabNo_FIS_Giden;
        8  : TabloNo := Tabno_GIDERPUSULASI;
        9  : TabloNo := Tabno_SIPARIS_Gelen;
        10 : TabloNo := TabNo_IRSALIYE_Gelen;
        11 : TabloNo := TabNo_FATBASLIK_Gelen;
        12 : TabloNo := TabNo_FIS_Gelen;
        14 : TabloNo := TabNo_IRSALIYE_Giden;
        15 : TabloNo := TabNo_FATBASLIK_Giden;
        16 : TabloNo := TabNo_FIS_Giden;
        19 : TabloNo := Tabno_SIPARIS_Gelen;//Tabno_SIPARIS_Giden;
        101: TabloNo := Tabno_SATINALMA;
        109: TabloNo := TabNo_KONSINYE_GELEN;
        110: TabloNo := Tabno_GIDERPUSULASI;
        119: TabloNo := TabNo_KONSINYE_GIDEN;
      end;
      TabloYenile(TabYorum,[TabloNo, FATBASLIK.FieldByName('ID').AsInteger]);
      TabloYenile(TabSmsEPosta,[FATBASLIK.FieldByName('REHBERID').AsInteger]);
   end;
end;

procedure TFaturalarDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TFaturalarDlg.DkmanSil1Click(Sender: TObject);
begin
    if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
        Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
        Tabloyenile(TabYorum,[TabloNo, FATBASLIK.FieldByName('ID').AsInteger]);
      end;
end;

procedure TFaturalarDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
           TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, FATBASLIK.FieldByName('REHBERID').AsInteger)
end;

procedure TFaturalarDlg.DokumanTviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var Ht: TcxCustomGridHitTest;
begin
    Ht := TcxGridSite(Sender).GridView.Viewinfo.GetHitTest(X, Y);
    If(Ht is TcxGridRecordCellHitTest) and (TcxGridRecordCellHitTest(Ht).Item.Properties is TcxHyperLinkEditProperties) then
      Screen.Cursor := crHandPoint
    else
      Screen.Cursor := crDefault;
end;

procedure TFaturalarDlg.AlSat1Click(Sender: TObject);
begin
   YeniTusClick(Sender);
end;

procedure TFaturalarDlg.AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
 if Key = 38 then
    GridFatListeTview.DataController.DataSource.DataSet.Prior
 else if Key = 40 then
    GridFatListeTview.DataController.DataSource.DataSet.next
 else
    TarihDegisti;
end;


procedure  TFaturalarDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s:string;
begin
  if FATBASLIK.Active then begin
    s := YaziciYaz.Caption;
    Delete(s, pos('&',s), 1);
    YazdirmayaHazirla(FastRaporDlg.frxReport1);
    FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
  end;
end;

function TFaturalarDlg.Add_Column(CType:SmallInt;const ACaption, AName: string): TcxGridColumn;
begin
   try
      Result := GridFatListeTview.CreateColumn;
      case CType of
        1,4: Result.DataBinding.ValueTypeClass := TcxStringValueType;
        2: Result.DataBinding.ValueTypeClass := TcxIntegerValueType;
        3: Result.DataBinding.ValueTypeClass := TcxDateTimeValueType;
        5: Result.DataBinding.ValueTypeClass := TcxBooleanValueType; //
      end;
      TcxGridDBColumn(Result).DataBinding.FieldName:=AName;
      Result.Caption := ACaption;
      Result.Name := AName;
   except
   end;
end;
procedure TFaturalarDlg.EkKolonSil;
var
  i, Tekrar: Integer;
  Column: TcxGridDBColumn;
begin
  SipEkAlanlar:='';
  FatEkAlanlar:='';
  Tekrar := 0;
  while (EkAlanKolonList.Count > 0)and(Tekrar < 100) do begin
        for i := GridFatListeTview.ColumnCount - 1 downto 0 do
        begin
          Column := GridFatListeTview.Columns[i];
          //if SameText(Column.Name, 'TEST11') then
          if Column.DataBinding.FieldName = EkAlanKolonList.Strings[0] then
          begin
            //GridFatListeTview.Columns.Delete(i);
            Column.Destroy;
            EkAlanKolonList.Delete(0);
            Break;
          end;
        end;
        inc(Tekrar);
  end;

end;


Function TFaturalarDlg.EkAlanlariGetir(TabloAdi:String):String;
begin
  //if FaturalarDlg=nil then exit;
  if  FArama.CheckEkAlanlarListelensin.checked then begin
      Tablo.TablodanSorguAc(5,' select ALANADI,CAPTION from ALANLAR where TUR not in (11,12) and TABLO='''+TabloAdi+'''');
      Result:='';
      while not Tablo.Query5.eof do begin
       // if GridFatListeTview.GetColumnByFieldName(Tablo.Query5.Fields[0].AsString) = nil then begin
       if FindComponent(Tablo.Query5.Fields[1].AsString) = nil then begin
          Add_Column(1,Tablo.Query5.Fields[1].AsString,Tablo.Query5.Fields[0].AsString);
          EkAlanKolonList.Add(Tablo.Query5.Fields[0].AsString);
        end;
        Result:=Result+','+Tablo.Query5.Fields[0].AsString;
        Tablo.Query5.Next;
      end;
  end;
end;

procedure TFaturalarDlg.Baslatildi;
var
  ra : string;
  i : integer;

  procedure ImageComboItemEkle(AProps: TcxImageComboBoxProperties; AValue: Integer; const ADesc: string);
  var
    j: Integer;
  begin
    if AProps = nil then Exit;
    AProps.ShowDescriptions := True;
    for j := 0 to AProps.Items.Count - 1 do
      if VarToStr(AProps.Items[j].Value) = IntToStr(AValue) then begin
        AProps.Items[j].Description := ADesc;
        Exit;
      end;
    with AProps.Items.Add do begin
      Description := ADesc;
      Value := AValue;
    end;
  end;

begin

   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  cxPageControl1.ActivePageIndex := 0;
  Self.Align := alClient;
  // SAYFALI liste: merkezi yardimci; sayfa boyu GENEL OPSIYON (Liste sayfa uzunlugu).
  // Yenileme JvTimer1Timer uzerinden -> son arama baglami (tarih/filtre/alt tur) korunur.
  if FSayfali = nil then
    FSayfali := TSayfaliListe.Baglan(Self, FATBASLIK, GridFatListeTview, nil,
      procedure
      begin
        JvTimer1Timer(nil);
      end);
  GridFatListe.LookAndFeel.ScrollbarMode := sbmClassic;
  GridFatListeTview.OptionsView.ScrollBars := ssBoth;
  GridFatView.OptionsView.ScrollBars := ssBoth;

  // repEFaturaDurum, Utablo'da (tasarimcida) tanimlandigi sekilde kullanilir;
  // burada koddan doldurulmaz/degistirilmez.

  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 0, 'Yeni');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 1, 'Islemde');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 2, 'Basarili');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 3, 'Hata/Red');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 4, 'Iptal');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 5, 'Cevap Suresi Gecti');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 6, 'Yanit bekliyor');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 7, 'Taslak');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 8, 'Raporlanacak');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 9, 'GIB e Gonderildi');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 10, 'Alindi');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 11, 'Yanit gerekmiyor');
  ImageComboItemEkle(Tablo.repEFaturaSonuc.Properties, 12, 'Kanunen kabul');
  MenuKabulEt.OnClick := MenuKabulEtClick;
  MenuRedEt.OnClick := MenuRedEtClick;
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;

  EFaturaMenu1.Visible := EFaturaKullanimda>0;
   CizgiMenu1.Visible := EFaturaKullanimda>0;
   // e-Fatura kullanimda master anahtar: kapaliysa e-Belge arac cubugu butonu da gizli.
   BtnEFaturaGuncelle.Visible := EFaturaKullanimda>0;

   GridFatListeTviewSUBEID.Visible := SubeVarmi;
   if not DovizTakibi then begin
       FreeAndNil(GridFatListeTviewDOVIZ_FATURA_MATRAHI);
       FreeAndNil(GridFatListeTviewDOVIZ_KDV_TUTARI);
       FreeAndNil(GridFatListeTviewDOVIZ_TUTARI);
       FreeAndNil(GridFatListeTviewDOVIZ_CINSI);
       FreeAndNil(tvFatToplamlarDOVIZTUTARI);
       FreeAndNil(tvFatToplamlarDOVIZ_KURU);
       FreeAndNil(KurFark1);
   end;

//   if not Tablo.YetkiVarmi(242112,YetkiTur_Gorme) then begin //Maliyet görme izni yoksa
//       FreeAndNil(GridFatListeTviewFATURA_MALIYETI_ORT);
//       FreeAndNil(GridFatListeTviewORTKAR);
//   end;
   Tablo.GridAyarRestore('AlSatListeDetayGridi',GridFatView );

   if Sektor in [ Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest] then begin
      GridFatListeTviewOZELKOD.Visible := True;
      GridFatListeTviewOZELKOD.Caption := 'Masa';
      GridFatListeTviewZARF.DataBinding.FieldName := 'ZARFID';
      GridFatListeTviewZARF.Visible := True;
      GridFatListeTviewZARF.Caption := 'Kişi';
   end;

  YaziciYaz.Caption := ra;
    if StrToBool(GenRegIni.RegReadString('', 'RadioGunluk', '0', 'C')) <> False then
      FArama.RbGunluk.Checked := True;
    if StrToBool(GenRegIni.RegReadString('', 'RadioHaftalik', '0', 'C')) <> False then
      FArama.RbHaftalik.Checked := True;
    if StrToBool(GenRegIni.RegReadString('', 'RadioAylik', '1', 'C')) <> False then
      FArama.RbAylik.Checked := True;
//   FArama.Calendar1.Date := StrToDateTime(FormatDateTime('01'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh));
   FArama.Calendar2.Date := Tablo.GENINI.BugunTrh;
   Basladi := True;
   cxPageControl1.ActivePage := SheetDetay;


  if not Tablo.YetkiVarmi(2431,1,False) then begin  //tutarlar gözükmesin denirse;


    GridFatListeTview.OptionsView.Footer := False;
    GridFatListeTview.OptionsView.GroupFooters := gfInvisible;
    //for I := 0 to GridFatListeTview.ColumnCount-1 do
      //GridFatListeTview.Columns[i].Summary.Destroy;
  end;
//  BtnDonusum.Visible := True;
//  BtnBelgeZarfi.Visible := True;
//  HizliGirisTus.Visible := True;
//  YaziciYaz.Visible := True;
end;

procedure TFaturalarDlg.BelgeyiAcClick(Sender: TObject);
begin
  GridFatListeTviewDblClick(Self);
end;

procedure TFaturalarDlg.BtnBelgeZarfiClick(Sender: TObject);
var
  BzDlg:TBelgeZarflariDlg;
begin
  Application.CreateForm(TBelgeZarflariDlg,BzDlg);
  BzDlg.ShowModal;
  FreeAndNil(BzDlg);
end;

procedure TFaturalarDlg.BtnEFaturaGuncelleClick(Sender: TObject);
// Kuyruktaki gonderimleri isler, ardindan Izibiz inbox'tan gelen e-faturalari ceker.
var
  LYeni, LAtlanan, LYeniFB: Integer;
  LEArsivYeni, LEArsivAtlanan, LEArsivYeniFB: Integer;
  LHata, LFBHata, LEArsivHata, LEArsivFBHata, LMesaj, LEskiCaption: string;
  LBasarili, LFBOK, LEArsivBasarili, LEArsivFBOK, LGelenEFaturaAl,
    LEArsivAl: Boolean;
  LIlerleme: TIlerlemeOlay;
  LKGonderildi, LKHata, LKToplam: Integer;
  LKHataMesaj: string;
begin
  LogSistemIslem('E-Fatura güncelleme basıldı');
  LEskiCaption := LabelKayitSayisi.Caption;
  PanelKayitSayisi.Visible := True;   // ilerleme seridi yalniz bu islem boyunca gorunur
  LIlerleme :=
    procedure(const AMevcut, ATotal: Integer; const ABilgi: string)
    begin
      if ATotal > 0 then
        LabelKayitSayisi.Caption :=
          Format('%s: %d / %d', [ABilgi, AMevcut, ATotal])
      else
        LabelKayitSayisi.Caption := ABilgi + '...';
      Application.ProcessMessages;
    end;

  Screen.Cursor := crHourGlass;
  try
    TEBelgeOlusturucu.KuyrukGonderimleriniIsle(Tablo.FDCnn, 0,
      LKGonderildi, LKHata, LKToplam, LKHataMesaj, LIlerleme);

    LGelenEFaturaAl := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_GelenEFaturaAl, False);
    LEArsivAl := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_EArsivFaturaAktif, False);
    LBasarili := False;
    LFBOK := False;
    LEArsivBasarili := False;
    LEArsivFBOK := False;
    LYeni := 0;
    LAtlanan := 0;
    LYeniFB := 0;
    LEArsivYeni := 0;
    LEArsivAtlanan := 0;
    LEArsivYeniFB := 0;
    LHata := '';
    LFBHata := '';
    LEArsivHata := '';
    LEArsivFBHata := '';
    if LGelenEFaturaAl then begin
      LBasarili := TEBelgeGelen.Cek(Tablo.FDCnn, LYeni, LAtlanan, LHata, LIlerleme);
      if LBasarili then
        LFBOK := TEBelgeGelen.OlusturFatbaslikler(Tablo.FDCnn, LYeniFB, LFBHata,
                                                   LIlerleme);
    end;
    if LEArsivAl then begin
      LEArsivBasarili := TEBelgeGelen.Cek(Tablo.FDCnn, LEArsivYeni,
        LEArsivAtlanan, LEArsivHata, LIlerleme, True);
      if LEArsivBasarili then
        LEArsivFBOK := TEBelgeGelen.OlusturFatbaslikler(Tablo.FDCnn,
          LEArsivYeniFB, LEArsivFBHata, LIlerleme, True);
    end;
  finally
    Screen.Cursor := crDefault;
    LabelKayitSayisi.Caption := LEskiCaption;
    PanelKayitSayisi.Visible := False;   // serit tekrar gizlensin
  end;

  LMesaj := 'Senkronizasyon tamamlandi.' + sLineBreak +
            'Kuyruk toplam: ' + IntToStr(LKToplam) + sLineBreak +
            'Kuyruk gonderilen: ' + IntToStr(LKGonderildi) + sLineBreak +
            'Kuyruk hata: ' + IntToStr(LKHata);
  if Trim(LKHataMesaj) <> '' then
    LMesaj := LMesaj + sLineBreak + 'Kuyruk ilk hata: ' + LKHataMesaj;

  if (not LGelenEFaturaAl) and (not LEArsivAl) then begin
    LMesaj := LMesaj + sLineBreak + sLineBreak +
              'Gelen fatura alma opsiyonu kapalı; sadece kuyruk gönderimleri işlendi.';
  end else if not LGelenEFaturaAl then begin
    LMesaj := LMesaj + sLineBreak + sLineBreak +
              'Gelen e-Fatura alma opsiyonu kapalı.';
  end else if LBasarili then begin
    LMesaj := LMesaj + sLineBreak + sLineBreak +
              'Gelen faturalar cekildi.' + sLineBreak +
              'EBELGE yeni: ' + IntToStr(LYeni) + sLineBreak +
              'EBELGE atlanan: ' + IntToStr(LAtlanan);
    if LFBOK then
      LMesaj := LMesaj + sLineBreak + 'FATBASLIK olusturulan: ' + IntToStr(LYeniFB)
    else
      LMesaj := LMesaj + sLineBreak + 'FATBASLIK olusturma hata: ' + LFBHata;
    if Trim(LHata) <> '' then
      LMesaj := LMesaj + sLineBreak + sLineBreak + LHata;
    TabloYenile(FATBASLIK, []);
  end else
    LMesaj := LMesaj + sLineBreak + sLineBreak + 'Gelen faturalar cekilemedi: ' + LHata;

  if LEArsivAl then begin
    if LEArsivBasarili then begin
      LMesaj := LMesaj + sLineBreak + sLineBreak +
                'Gelen e-Arsiv faturalar cekildi.' + sLineBreak +
                'EBELGE yeni: ' + IntToStr(LEArsivYeni) + sLineBreak +
                'EBELGE atlanan: ' + IntToStr(LEArsivAtlanan);
      if LEArsivFBOK then
        LMesaj := LMesaj + sLineBreak + 'FATBASLIK olusturulan: ' +
          IntToStr(LEArsivYeniFB)
      else
        LMesaj := LMesaj + sLineBreak + 'FATBASLIK olusturma hata: ' +
          LEArsivFBHata;
      if Trim(LEArsivHata) <> '' then
        LMesaj := LMesaj + sLineBreak + sLineBreak + LEArsivHata;
      TabloYenile(FATBASLIK, []);
    end else
      LMesaj := LMesaj + sLineBreak + sLineBreak +
        'Gelen e-Arsiv faturalar cekilemedi: ' + LEArsivHata;
  end;

  ShowMessage(LMesaj);
end;

procedure TFaturalarDlg.MenuKabulEtClick(Sender: TObject);
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  if TEBelgeOlusturucu.GelenFaturaCevapVer(Tablo.FDCnn,
    FATBASLIK.FieldByName('ID').AsInteger, True) then
    TabloYenile(FATBASLIK, []);
end;

procedure TFaturalarDlg.MenuRedEtClick(Sender: TObject);
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  if TEBelgeOlusturucu.GelenFaturaCevapVer(Tablo.FDCnn,
    FATBASLIK.FieldByName('ID').AsInteger, False) then
    TabloYenile(FATBASLIK, []);
end;

procedure TFaturalarDlg.MenuCariKaydiOlusturClick(Sender: TObject);
// FATBASLIK'taki BASLIK/ADRES/ILCE/IL/VD/VNO bilgileriyle cari (REHBER) olustur,
// modal'i ac. Kaydedilirse FATBASLIK.REHBERID yi yeni cariye baglar.
// Ayrica ayni VNO'lu + REHBERID=4 (default) olan diger FATBASLIK kayitlarini da gunceller.
//
// Akis:
//   1) Mevcut REHBER (VNO eslesmesi) varsa -> onu kullan
//   2) Yoksa sp_Grnt_CariIslem @TIP=1 ile yeni REHBER yarat
//   3) RehberSihirbazBaslat(2, REHBERID) ile modal edit ac
//   4) mrOk ise FATBASLIK.REHBERID guncelle + benzer VNO'lulari da

  function _JSONKacis(const S: string): string;
  begin
    Result := S;
    Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
    Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
    Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
    Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  end;

  function _XMLDeger(const AXML, ATag1, ATag2: string): string;
  // ATag1 ile ATag2 arasindaki ilk metin (UBL extraction).
  var P1, P2: Integer;
  begin
    Result := '';
    P1 := Pos(ATag1, AXML);
    if P1 = 0 then Exit;
    Inc(P1, Length(ATag1));
    P2 := PosEx(ATag2, AXML, P1);
    if P2 = 0 then Exit;
    Result := Trim(Copy(AXML, P1, P2 - P1));
  end;

var
  LFatBaslikID, LRehberID, LSonucID, LEbelgeID: Integer;
  LBaslik, LVD, LVNO, LAdres, LIlce, LIl, LSpJSON, LSonucMesaj: string;
  LSP: TFDQuery;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;

  LFatBaslikID := FATBASLIK.FieldByName('ID').AsInteger;
  LBaslik := Trim(FATBASLIK.FieldByName('BASLIK').AsString);
  LVD := Trim(FATBASLIK.FieldByName('VD').AsString);
  LVNO := Trim(FATBASLIK.FieldByName('VNO').AsString);
  LAdres := Trim(FATBASLIK.FieldByName('ADRES').AsString);
  LIlce := Trim(FATBASLIK.FieldByName('ILCE').AsString);
  LIl := Trim(FATBASLIK.FieldByName('IL').AsString);

  if LBaslik = '' then begin
    ShowMessage('Bu faturada BASLIK bos. Cari olusturulamaz.');
    Exit;
  end;

  // 1) Ayni VNO ile aktif REHBER var mi?
  LRehberID := 0;
  if LVNO <> '' then begin
    Tablo.TablodanSorguAc(1,
      'SELECT '+DbUst(1)+'R.ID FROM REHBER R ' +
      'INNER JOIN REHBERBILGI RB ON RB.YER_ID=R.ID AND RB.YERI=2 ' +
      ' AND RB.ETIKET=N''Vergi No'' ' +
      'WHERE R.DURUM=1 AND REPLACE(RB.BILGI,'' '','''')=' + QuotedStr(LVNO) +
      ' ORDER BY R.ID '+DbSinir(1));
    if not Tablo.Query1.Eof then
      LRehberID := Tablo.Query1.Fields[0].AsInteger;
    Tablo.Query1.Close;
  end;

  // 2) Yoksa SP ile yarat
  if LRehberID = 0 then begin
    // EBELGE.ID: UBL_XML + GONDERICIALIAS okumak icin lazim (SP'ye gonderilmez)
    LEbelgeID := 0;
    Tablo.TablodanSorguAc(1,
      'SELECT ISNULL(GNTPID,0) FROM FATBASLIK WHERE ID=' + IntToStr(LFatBaslikID));
    if not Tablo.Query1.Eof then
      LEbelgeID := Tablo.Query1.Fields[0].AsInteger;
    Tablo.Query1.Close;

    // Cari KOD'u Delphi tarafinda urat: HESAPPLANI'dan 'GEN-SATICI' icin
    // HESAPKODU'yu bul, THesapKoduPicker.SiradakiKoduGetir ile bir sonraki
    // bos kodu hesapla. Bos ise SP kendi mantigiyla uretir.
    var LRootKod, LKod: string;
    LKod := '';
    // Cari kok kod opsiyon ekranindan secilir (HESAPPLANI'dan VARSAYILAN=320).
    // Eski varsayilan: '320.01'.
    LRootKod := Trim(Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_CariKod, ''));
    if LRootKod = '' then begin
       Showmessage('E-Fatura opsiyonlarında Cari Kod Seçimi Yapın!');
       exit;
    end;
    if LRootKod <> '' then
      LKod := THesapKoduPicker.SiradakiKoduGetir(LRootKod,
                'HESAPPLANI', 'HESAPKODU', 'HESAPADI',
                'REHBER', 'KOD');

    // Gelen e-fatura zarfindan supplier alias'ini al (varsa REHBERALIAS'a yazilir).
    // Ayrica UBL_XML'den supplier Tel/Web/Eposta'yi cikar -> REHBERBILGI.
    var LAlias, LUBL, LTel, LWeb, LEposta, LParty: string;
    LAlias := ''; LUBL := ''; LTel := ''; LWeb := ''; LEposta := '';

    if LEbelgeID > 0 then begin
      Tablo.TablodanSorguAc(1,
        'SELECT '+DbUst(1)+'ISNULL(GONDERICIALIAS, N''''), ' +
        'ISNULL(COALESCE(CAST(DECOMPRESS(UBL_XML_ZIP) AS NVARCHAR(MAX)),' +
        'CAST(UBL_XML AS NVARCHAR(MAX))), N'''') ' +
        'FROM ' + DepoTablo('EBELGE') + ' WHERE ID=' + IntToStr(LEbelgeID) + ' '+DbSinir(1));
      if not Tablo.Query1.Eof then begin
        LAlias := Trim(Tablo.Query1.Fields[0].AsString);
        LUBL := Tablo.Query1.Fields[1].AsString;
      end;
      Tablo.Query1.Close;
    end;

    // UBL'den AccountingSupplierParty bloku icindeki Contact bilgilerini al.
    if LUBL <> '' then begin
      LParty := _XMLDeger(LUBL,
                          '<cac:AccountingSupplierParty>',
                          '</cac:AccountingSupplierParty>');
      if LParty <> '' then begin
        LTel    := _XMLDeger(LParty, '<cbc:Telephone>', '</cbc:Telephone>');
        LEposta := _XMLDeger(LParty, '<cbc:ElectronicMail>', '</cbc:ElectronicMail>');
        LWeb    := _XMLDeger(LParty, '<cbc:WebsiteURI>', '</cbc:WebsiteURI>');
      end;
    end;

    LSpJSON :=
      '{' +
      '"KOD":"' + _JSONKacis(LKod) + '",' +
      '"FIRMA":"' + _JSONKacis(LBaslik) + '",' +
      '"EKLEYEN":' + Kullanan + ',' +
      '"VNO":"' + _JSONKacis(LVNO) + '",' +
      '"VD":"' + _JSONKacis(LVD) + '",' +
      '"FATURABASLIK":"' + _JSONKacis(LBaslik) + '",' +
      '"ADRES":"' + _JSONKacis(LAdres) + '",' +
      '"ILCE":"' + _JSONKacis(LIlce) + '",' +
      '"IL":"' + _JSONKacis(LIl) + '",' +
      '"ALIAS":"' + _JSONKacis(LAlias) + '",' +
      '"ALIASBELGETURU":151,' +
      '"TEL":"' + _JSONKacis(LTel) + '",' +
      '"WEB":"' + _JSONKacis(LWeb) + '",' +
      '"EPOSTA":"' + _JSONKacis(LEposta) + '"' +
      '}';

    LSP := TFDQuery.Create(nil);
    try
      LSP.Connection := Tablo.FDCnn;
      // Yeni basit cari olusturma SP'si. SONUC_ID = yeni REHBER.ID (basari)
      // veya 0/-1 (hata). Mesaj SMSG'de.
      LSP.SQL.Text :=
        'DECLARE @sid INT, @smsg VARCHAR(1000); ' +
        'EXEC sp_Grnt_CariOlustur @jsonData=:j, ' +
        ' @SONUC_ID=@sid OUTPUT, @SONUC_MESAJ=@smsg OUTPUT; ' +
        'SELECT @sid AS SID, @smsg AS SMSG';
      LSP.ParamByName('j').AsString := LSpJSON;
      LSP.Open;
      LSonucID := LSP.FieldByName('SID').AsInteger;
      LSonucMesaj := LSP.FieldByName('SMSG').AsString;
      LSP.Close;
    finally
      LSP.Free;
    end;

    if LSonucID <= 0 then begin
      ShowMessage('Cari olusturulamadi: ' + LSonucMesaj);
      Exit;
    end;
    LRehberID := LSonucID;

    // UBL'deki tum <cac:PaymentMeans> bloklarini tarayip BANKAHESAPLAR'a yaz.
    // BANKAKODU: IBAN pozisyon 5-8 (TR + 2 check + 4-digit banka kodu).
    // BANKASUBELERID: BANKALAR'da kayitli ise BANKASUBELER'den sube adi ile
    // eslestir, yoksa TOP 1 sube veya NULL.
    if LUBL <> '' then begin
      var LIdx, LBlokSon, LBankaKodu, LSubeID: Integer;
      var LBlok, LIBAN, LIBANTrim, LKur, LBankaAd, LSubeAd: string;
      var LIlkBanka: Boolean;
      LIdx := 1;
      LIlkBanka := True;
      while True do begin
        LIdx := PosEx('<cac:PaymentMeans>', LUBL, LIdx);
        if LIdx = 0 then Break;
        LBlokSon := PosEx('</cac:PaymentMeans>', LUBL, LIdx);
        if LBlokSon = 0 then Break;
        LBlok := Copy(LUBL, LIdx, LBlokSon - LIdx);
        LIdx := LBlokSon + Length('</cac:PaymentMeans>');

        LIBAN := _XMLDeger(LBlok, '<cbc:ID>', '</cbc:ID>');
        LKur := _XMLDeger(LBlok, '<cbc:CurrencyCode>', '</cbc:CurrencyCode>');
        if LKur = '' then LKur := 'TRY';
        // Sube adi: oncelikli kaynak <cac:FinancialInstitutionBranch><cbc:Name>
        LSubeAd := _XMLDeger(LBlok,
                             '<cac:FinancialInstitutionBranch>',
                             '</cac:FinancialInstitutionBranch>');
        if LSubeAd <> '' then
          LSubeAd := _XMLDeger(LSubeAd, '<cbc:Name>', '</cbc:Name>');
        LBankaAd := _XMLDeger(LBlok, '<cbc:InstructionNote>', '</cbc:InstructionNote>');
        if LBankaAd = '' then LBankaAd := LSubeAd;

        LIBANTrim := StringReplace(Trim(LIBAN), ' ', '', [rfReplaceAll]);
        if LIBANTrim = '' then Continue;

        // Ayni IBAN/REHBER zaten varsa atla.
        Tablo.TablodanSorguAc(1,
          'SELECT '+DbUst(1)+'ID FROM BANKAHESAPLAR WHERE REHBERID=' + IntToStr(LRehberID) +
          ' AND REPLACE(IBAN,'' '','''')=' + QuotedStr(LIBANTrim) + ' '+DbSinir(1));
        var LMevcut: Boolean;
        LMevcut := not Tablo.Query1.Eof;
        Tablo.Query1.Close;
        if LMevcut then Continue;

        // BANKAKODU lookup: TR + 2 check + 4-digit banka kodu (pozisyon 5-8).
        LBankaKodu := 0;
        LSubeID := 0;
        if (Length(LIBANTrim) >= 8) and SameText(Copy(LIBANTrim, 1, 2), 'TR') then
          LBankaKodu := StrToIntDef(Copy(LIBANTrim, 5, 4), 0);

        if LBankaKodu > 0 then begin
          // Once BANKALAR'da kayitli mi kontrol et.
          Tablo.TablodanSorguAc(1,
            'SELECT '+DbUst(1)+'BANKAKODU FROM BANKALAR WHERE BANKAKODU=' + IntToStr(LBankaKodu) + ' '+DbSinir(1));
          var LBankaVar: Boolean;
          LBankaVar := not Tablo.Query1.Eof;
          Tablo.Query1.Close;

          if LBankaVar then begin
            // Sube adina gore esleme dene; bulamazsa TOP 1.
            if Trim(LSubeAd) <> '' then begin
              Tablo.TablodanSorguAc(1,
                'SELECT '+DbUst(1)+'ID FROM BANKASUBELER WHERE BANKAKODU=' + IntToStr(LBankaKodu) +
                ' AND ISNULL(SUBEADI,N'''') LIKE ' + QuotedStr('%' + Trim(LSubeAd) + '%') + ' '+DbSinir(1));
              if not Tablo.Query1.Eof then
                LSubeID := Tablo.Query1.Fields[0].AsInteger;
              Tablo.Query1.Close;
            end;
            if LSubeID = 0 then begin
              Tablo.TablodanSorguAc(1,
                'SELECT '+DbUst(1)+'ID FROM BANKASUBELER WHERE BANKAKODU=' + IntToStr(LBankaKodu) +
                ' ORDER BY SUBEKODU '+DbSinir(1));
              if not Tablo.Query1.Eof then
                LSubeID := Tablo.Query1.Fields[0].AsInteger;
              Tablo.Query1.Close;
            end;
          end;
        end;

        if LSubeID > 0 then
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'INSERT INTO BANKAHESAPLAR (REHBERID, BANKASUBELERID, IBAN, KUR, ' +
            ' HESAPACIKLAMA, VARSAYILAN, DURUM, EKLEYEN, EKLEMETARIHI) VALUES ' +
            ' (&RID, &BSID, &IBAN, &KUR, &ACK, &VRS, 1, &KUL, GETDATE())',
            ['&RID', '&BSID', '&IBAN', '&KUR', '&ACK', '&VRS', '&KUL'],
            [LRehberID, LSubeID, LIBANTrim, LKur, LBankaAd,
             Ord(LIlkBanka), StrToIntDef(Kullanan, 0)])
        else
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'INSERT INTO BANKAHESAPLAR (REHBERID, IBAN, KUR, ' +
            ' HESAPACIKLAMA, VARSAYILAN, DURUM, EKLEYEN, EKLEMETARIHI) VALUES ' +
            ' (&RID, &IBAN, &KUR, &ACK, &VRS, 1, &KUL, GETDATE())',
            ['&RID', '&IBAN', '&KUR', '&ACK', '&VRS', '&KUL'],
            [LRehberID, LIBANTrim, LKur, LBankaAd,
             Ord(LIlkBanka), StrToIntDef(Kullanan, 0)]);
        LIlkBanka := False;
      end;
    end;
  end;

  if LRehberID <= 0 then begin
    ShowMessage('Olusturulan REHBER ID bulunamadi.');
    Exit;
  end;

  // 3) REHBER modal'ini edit modunda ac
  if Tablo.RehberSihirbazBaslat(2, LRehberID, -1, -1, False) <= 0 then
    Exit;

  // 4) FATBASLIK.REHBERID guncelle
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'UPDATE FATBASLIK SET REHBERID=&RID WHERE ID=&FID',
    ['&RID', '&FID'], [LRehberID, LFatBaslikID]);

  // 4b) Ayni VNO + REHBERID=4 (default) olanlari da guncelle
  if LVNO <> '' then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'UPDATE FATBASLIK SET REHBERID=&RID ' +
      'WHERE REHBERID=4 AND REPLACE(ISNULL(VNO,N''''), '' '','''')=' + QuotedStr(LVNO),
      ['&RID'], [LRehberID]);

  TabloYenile(FATBASLIK, [], LFatBaslikID, 'ID');
  ShowMessage('Cari (REHBER.ID=' + IntToStr(LRehberID) +
              ') olusturuldu/baglandi.');
end;

procedure TFaturalarDlg.MenuMesajlarGosterClick(Sender: TObject);
// Aktif FATBASLIK satirinin tum islem gecmisini ve mesajlarini gosterir.
// Grid'deki EFATURASONUC hucresine tiklamakla ayni etki.
var
  LFID: Integer;
  LFaturaNo, LBaslik: string;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  LFID :=  FATBASLIK.FieldByName('ID').AsInteger;
  LFaturaNo := Trim(FATBASLIK.FieldByName('FATURANO').AsString);
  LBaslik := Trim(FATBASLIK.FieldByName('BASLIK').AsString);
  TEBelgeMesajDlg.Goster(Self, Tablo.FDCnn, LFID, LFaturaNo, LBaslik);
end;

procedure TFaturalarDlg.MenuEslesmeTablosunuAcClick(Sender: TObject);
// Stok/hizmet eslesme tablosu dialogunu acar.
// Aktif FATBASLIK satirinin REHBERID'si onsecili olarak gelir.
var
  LRehberID: Integer;
  LCariAdi: string;
begin
  LRehberID := 0;
  LCariAdi := '';
  if FATBASLIK.Active and (not FATBASLIK.IsEmpty) then begin
    LRehberID := FATBASLIK.FieldByName('REHBERID').AsInteger;
    if FATBASLIK.FindField('CARIAD') <> nil then
      LCariAdi := Trim(FATBASLIK.FieldByName('CARIAD').AsString);
  end;
  TStokEslestirmeDlg.Goster(Self, Tablo.FDCnn, LRehberID, LCariAdi);
end;

procedure TFaturalarDlg.MenuUrunEslestirClick(Sender: TObject);
// Tum mantik TStokEslestirmeDlg.FaturayiEslestir icindedir.
var
  LFatBaslikID, LRehberID: Integer;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  LFatBaslikID := FATBASLIK.FieldByName('ID').AsInteger;
  LRehberID := FATBASLIK.FieldByName('REHBERID').AsInteger;
  if TStokEslestirmeDlg.FaturayiEslestir(Tablo.FDCnn, LFatBaslikID,
       LRehberID, StrToIntDef(Kullanan, 0)) then
    TabloYenile(FATBASLIK, [], LFatBaslikID, 'ID');
end;

procedure TFaturalarDlg.GridFatViewCellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
// KOD hucresi:  paylasilan TFaturaWizardDlg.FaturaSatiriUrunSec kullanilir.
var
  LFaturaID, LFatBaslikID, LRehberID: Integer;
begin
  if AButton <> mbLeft then Exit;
  if ACellViewInfo = nil then Exit;
  if ACellViewInfo.Item <> GridFatViewKOD then Exit;
  if (not FATURA.Active) or FATURA.IsEmpty then Exit;

  AHandled := True;
  LFaturaID := FATURA.FieldByName('ID').AsInteger;
  LFatBaslikID := 0; LRehberID := 0;
  if FATBASLIK.Active and (not FATBASLIK.IsEmpty) then begin
    LFatBaslikID := FATBASLIK.FieldByName('ID').AsInteger;
    LRehberID := FATBASLIK.FieldByName('REHBERID').AsInteger;
  end;

  if TFaturaWizardDlg.FaturaSatiriUrunSec(Tablo.FDCnn,
       LFaturaID, LFatBaslikID, LRehberID) then
    TabloYenile(FATURA, [], LFaturaID, 'ID');
end;

procedure TFaturalarDlg.BtnDonusumClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
begin
  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.RehID := 0;
  BDDlg.HedefBaslikID := 0;
  BDDlg.TabDetayGiris := nil;
  BDDlg.GDepo := VarsDepo;
  BDDlg.CDepo := VarsDepo;
  BDDlg.cxGridKaynakDBTableView1.OnCellDblClick := Nil;
  BDDlg.HedefBaslikTur := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek).FAltTur;
  BDDlg.ShowModal;
  FreeAndNil(BDDlg);
end;

procedure TFaturalarDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TFaturalarDlg.EPostaTusClick(Sender: TObject);
var
  Ad : string;
  Id, i: integer;
begin{
  Ad := TabDokuman.FieldByName('AD').AsString;
  Id := TabDokuman.FieldByName('ID').AsInteger;
  Tablo.DokumanEPostaGonder(ID,Ad);  }
end;

procedure TFaturalarDlg.ExceldenBelgeEkle2Click(Sender: TObject);
begin
   Excel2Fatura;
end;

procedure TFaturalarDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFaturalarDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFaturalarDlg.Fatura1Click(Sender: TObject);
var
  YeniFatNo  : Variant;
  FaturaIDsi : integer;
  belgeno: TBelgeNo;
begin
  Tablo.FaturaIadeAl(FATBASLIK,TMenuItem(Sender).Tag );

end;

procedure TFaturalarDlg.FaturaAc(ID : Integer);
begin
   
end;

function TFaturalarDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

procedure TFaturalarDlg.PopUpDynamicSubMenuClick(Sender: TObject);
var
  Item : TMenuItem;
  i,recordIndex:Integer;
begin
  Item := TMenuItem(Sender);
  for i := 0 to GridFatListeTview.DataController.GetSelectedCount - 1 do begin
    recordIndex := GridFatListeTview.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'update FATBASLIK set DURUM='+inttostr(Item.Tag)+' where ID='+IntToStr(GridFatListeTview.DataController.Values[recordIndex,0]); //GetRecordId(recordIndex);
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.ExecSQL;
  end;
  FATBASLIK.DisableControls;
  TabloYenile(FATBASLIK,[]);
  FATBASLIK.EnableControls;
end;

procedure TFaturalarDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabloNo, FATBASLIK.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TFaturalarDlg.BelgeEkleTusClick(Sender: TObject);
var
  ID: Integer;
begin
  if FATBASLIK.FieldByName('TUR').AsInteger in [9,19, 101] then begin
    ID := Tablo.DokumanSihirbazBaslat('E', 0, -1,Tablo.GENINI.ReadInteger(Ops_OpsiyonSiparis_VarsayilanKlasor, -2),1,TabNo_SIPARIS_DOKUMAN,FATBASLIK.FieldByName('ID').AsInteger,FATBASLIK.FieldByName('REHBERID').AsInteger);
 //AA   if ID > 0 then
//AA      FATBASLIKAfterScroll(FATBASLIK);
  end else begin
    ID := Tablo.DokumanSihirbazBaslat('E', 0, -1,Tablo.GENINI.ReadInteger(Ops_OpsiyonFatura_VarsayilanKlasor, -2),1,TabNo_FATBASLIK_DOKUMAN,FATBASLIK.FieldByName('ID').AsInteger,FATBASLIK.FieldByName('REHBERID').AsInteger);
 //AA   if ID > 0 then
 //AA     FATBASLIKAfterScroll(FATBASLIK);
  end
end;

function TFaturalarDlg.BelgeIptalEt(Tur,ID:Integer):Boolean;
Begin
  case Tur of
    9,19,101:begin
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARIS set DURUM=6,SIPARIS_MATRAHI=0,KDV_TUTARI=0,EKVERGI=0,SIPARIS_TUTARI=0,DOVIZ_TUTARI=0 where TUR=&Tur and ID=&ID'
                ,['&Tur','&ID'],[Tur,ID]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set BIRIMFIYAT=0,TUTAR=0,DOVIZ_TUTARI=0,DOVIZ_BIRIMFIYAT=0,ADET=0,MIKTAR=0 where SIPARISID=&Siparisid'
                ,['&Siparisid'],[ID]);
    end;
  else
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set DURUM=6,FATURA_MALIYETI_ORT=0,FATURA_MATRAHI=0,KDV_TUTARI=0,EKVERGI=0,FATURA_TUTARI=0,DOVIZ_TUTARI=0 where TUR=&Tur and ID=&ID'
              ,['&Tur','&ID'],[Tur,ID]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set BIRIMFIYAT=0,TUTAR=0,DOVIZ_TUTARI=0,DOVIZ_BIRIMFIYAT=0,STOKDURUMDEGIS=0,ADET=0,MIKTAR=0,YERI=0,YERID=0 where FATBASID=&Fatbasid'
              ,['&Fatbasid'],[ID]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where BELGETUR=&Tur and BASLIKID=&Fatbasid'
              ,['&Tur','&Fatbasid'],[Tur,ID]);
  end;
End;

procedure TFaturalarDlg.IptalIsaretleMenuClick(Sender: TObject);
var
  sts:TStringlist;
  AYeri,AYerID,RehID:Integer;
  ABelgeno:string;
  KaynakIptal : Boolean;
  procedure KaynakBelgeIptalIslemi;
  begin
      Tablo.Query8.Close;
      Tablo.Query8.SQL.Text := '';
      Tablo.Query8.SQL.Add(' select distinct    ');
      Tablo.Query8.SQL.Add(' KAYNAKTUR = case   ');
      Tablo.Query8.SQL.Add(' 	when YERI = 83 then 83   '); //Servis
      Tablo.Query8.SQL.Add(' 	when YERI in (406,407) then 9   ');
      Tablo.Query8.SQL.Add(' 	when YERI = 408 then 10         ');
      Tablo.Query8.SQL.Add(' 	when YERI in (409,410,473) then 19  ');
      Tablo.Query8.SQL.Add(' 	when YERI = 411 then 14         ');
      Tablo.Query8.SQL.Add(' 	when YERI in (412,413) then -99 ');
      Tablo.Query8.SQL.Add(' end, ');
      Tablo.Query8.SQL.Add(' KAYNAKBELGENO=case ');
      Tablo.Query8.SQL.Add(' 	when YERI = 83 then (select SERVISNO from SERVIS where ID=(select SERVISID from SERVISDETAY where ID=F.YERID)) ');
      Tablo.Query8.SQL.Add(' 	when YERI in (406,407,409,410,473) then (select SIPARISNO from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID=F.YERID)) ');
      Tablo.Query8.SQL.Add(' 	when YERI in (408,411) then (select FATURANO from FATBASLIK where ID=(select FATBASID from FATURA where ID=F.YERID))               ');
      Tablo.Query8.SQL.Add(' 	when YERI in (412,413) then (select TEKLIFNO from TEKLIF where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))             ');
      Tablo.Query8.SQL.Add(' end, ');
      Tablo.Query8.SQL.Add(' KAYNAKID=case      ');
      Tablo.Query8.SQL.Add(' 	when YERI = 83 then (select SERVISID from SERVISDETAY where ID=F.YERID) ');
      Tablo.Query8.SQL.Add(' 	when YERI in (406,407,409,410,473) then (select SIPARISID from SIPARISDETAY where ID=F.YERID ) ');
      Tablo.Query8.SQL.Add(' 	when YERI in (408,411) then (select FATBASID from FATURA where ID=F.YERID )                ');
      Tablo.Query8.SQL.Add(' 	when YERI in (412,413) then (SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID )           ');
      Tablo.Query8.SQL.Add(' end ');
      case FATBASLIK.FieldByName('TUR').AsInteger of
        9,19,101:begin
          Tablo.Query8.SQL.Add(' from SIPARISDETAY F ');
          Tablo.Query8.SQL.Add(' where SIPARISID='+FATBASLIK.FieldByName('ID').AsString+' and ');
          Tablo.Query8.SQL.Add(' 	YERI between 406 and 413 ');
        end;
      else
          Tablo.Query8.SQL.Add(' from FATURA F  ');
          Tablo.Query8.SQL.Add(' where FATBASID='+FATBASLIK.FieldByName('ID').AsString+' and ');
          Tablo.Query8.SQL.Add(' 	YERI between 406 and 413 ');
      end;
      if AktifVeriMotor = vmPG then Tablo.Query8.SQL.Text := PgSqlCevir(Tablo.Query8.SQL.Text);
      Tablo.Query8.Open;
  end;
  //
  //
  procedure HedefBelgeIptalIslemi;
  begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := '';
      case FATBASLIK.FieldByName('TUR').AsInteger of
        9,19,101:begin
          Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.FATURANO,FB.ID ');
          Tablo.Query1.SQL.Add(' from SIPARISDETAY SD ');
          Tablo.Query1.SQL.Add(' 	inner join FATURA F2 on SD.ID=F2.YERID and F2.YERI in (406,407,409,410,473) ');
          Tablo.Query1.SQL.Add(' 	inner join FATBASLIK FB on F2.FATBASID=FB.ID ');
          Tablo.Query1.SQL.Add(' where SD.SIPARISID='+FATBASLIK.FieldByName('ID').AsString);
        end;
      else
        Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.FATURANO,FB.ID ');
        Tablo.Query1.SQL.Add(' from FATURA F ');
        Tablo.Query1.SQL.Add(' 	inner join FATURA F2 on F.ID=F2.YERID and F2.YERI in (408,411) ');
        Tablo.Query1.SQL.Add(' 	inner join FATBASLIK FB on F2.FATBASID=FB.ID ');
        Tablo.Query1.SQL.Add(' where F.FATBASID='+FATBASLIK.FieldByName('ID').AsString);
      end;
      if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
      Tablo.Query1.Open;
      while not Tablo.Query1.Eof do begin
        BelgeIptalEt(Tablo.Query1.FieldByName('TUR').AsInteger,Tablo.Query1.FieldByName('ID').AsInteger);
        Tablo.Query1.Next;
      end;
    end;
   ////////////////
begin//durum:6 iptal
  if FATBASLIK.FieldByName('TUR').AsInteger in [11,15] then begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+FATBASLIK.FieldByName('ID').AsString+' ',[],[]) then begin
     if  Application.MessageBox(PChar(Planlifaturaiptalolsunmu),PChar(Uyari),MB_YESNO)=mrNo then begin
       Abort;
     end;
    end;
  end;

  if (FATBASLIK.FieldByName('TUR').AsInteger=119)and
     (Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM STOKIZLEME S1 WHERE BASLIKID = '+FATBASLIK.FieldByName('ID').AsString+' AND '+
                               ' EXISTS(SELECT * FROM STOKIZLEME S2 WHERE S2.DONUSID = S1.ID)',[],[])) then begin
     Tablo.UyariGoster(Uyari, IzlemKullanilmis);
     abort;
  end;

  if FATBASLIK.FieldByName('DURUM').AsInteger<>6 then begin
    KaynakIptal := False;
//    if (FATBASLIK.FieldByName('DURUMNEREDEN').AsString<>'')and (Application.MessageBox(PChar(FWKaynagaUygulansinmi),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrYes) then begin
//        KaynakBelgeIptalIslemi;
//        KaynakIptal:=True;
//    end;
//    if (FATBASLIK.FieldByName('DURUMNEREYE').AsString<>'')and(Application.MessageBox(PChar(FWHedefeUygulansinmi),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrYes) then
//        HedefBelgeIptalIslemi;
    BelgeIptalEt(FATBASLIK.FieldByName('TUR').AsInteger,FATBASLIK.FieldByName('ID').AsInteger);

    if KaynakIptal=True then
       while not Tablo.Query8.Eof do begin
         BelgeIptalEt(Tablo.Query8.FieldByName('KAYNAKTUR').AsInteger,Tablo.Query8.FieldByName('KAYNAKID').AsInteger);
         Tablo.Query8.Next;
       end;



    if (FATBASLIK.FieldByName('TUR').AsInteger in [11,15])and(FATBASLIK.FieldByName('EFATURADURUM').AsInteger = 1) then begin
        //eğer e-fat modülünde varsa silelim
        Tablo.TablodanSorguAc(1,'SELECT ID FROM '+EFaturaDB+'.dbo.INVOICE WHERE OrgInvoiceNo = '''+FATBASLIK.FieldByName('ID').AsString+''' AND Status  = 1');
        if Tablo.Query1.Recordcount>0 then
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'exec '+EFaturaDB+'.dbo.p_EFaturaSil '+Tablo.Query1.Fields[0].AsString,[],[])
    end;
  end;
  TarihDegisti;
end;

procedure TFaturalarDlg.mnIrsaliyesiniOlusturClick(Sender: TObject);
var
   belgetipi, donustipi, yeniid, i,ID, TUR : integer;
   bilgiler, etiketler : TArrayofString;
   CariUnvan, FatbssIDList :String;
begin
  //Farklı carilerin belgeleri aynı anda dönüşmez
   if GridFatListeTview.Controller.SelectedRecordCount < 1 then begin
      ShowMessage(Listeden_sec);
      exit;
   end;

   yeniid := 0;
   FatbssIDList:='';
   for I := 0 to GridFatListeTview.Controller.SelectedRecordCount - 1 do begin
     if FatbssIDList<>'' then
        FatbssIDList := FatbssIDList+',';
     ID := StrToIntDef(VarToStr(GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewID.Index]),0);
     TUR := StrToIntDef(VarToStr(GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewTUR.Index]),0);
     FatbssIDList := FatbssIDList+IntToStr(ID);

       //Eğer bu belgeden başka belgeye dönüşüm yapıldıysa kaynak silinemez    Gelen/Giden Konsinye
     if ((Tur=109)or(Tur=119))and(Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM STOKIZLEME WHERE BASLIKID='+IntToStr(ID),[],[])) then begin
        Tablo.UyariGoster(Uyari,DonusumYapilamaz);
        Abort;
     end;



     if CariUnvan='' then
        CariUnvan := VarToStr(GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewCARIAD.Index])
     else if CariUnvan <> VarToStr(GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewCARIAD.Index]) then begin
        showmessage(Farklicariberaberbelgelenmez);
        Abort;
     end;
   end;


  belgetipi := (Sender as TMenuItem).Tag;
  donustipi := Tablo.BelgeDonustur_DonusTipiBul(FATBASLIK.FieldByName('TUR').AsInteger,belgetipi);
  if GridFatListeTview.Controller.SelectedRecordCount > 0 then begin
    yeniid := 0;
    for I := 0 to GridFatListeTview.Controller.SelectedRecordCount - 1 do
      yeniid := Tablo.BelgeDonustur(donustipi,GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewID.Index],yeniid);
  end else
     yeniid := Tablo.BelgeDonustur(donustipi,FATBASLIK.FieldByName('ID').AsInteger);

  if yeniid > 0 then begin
     if belgetipi in[9,19] then
        Tablo.TablodanSorguAc(1, 'select TUR, REHBERID from SIPARIS where ID='+IntToStr(yeniid))
     else
        Tablo.TablodanSorguAc(1, 'select TUR, REHBERID from FATBASLIK where ID='+IntToStr(yeniid));

     if donustipi = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN then begin //satış siparişi üretim fişine dönüştüyse başlığa ürün id ve adet yazalım
        Tablo.TablodanSorguAc(3,'select '+DbUst(1)+'URUNID, ADET from SIPARISDETAY where SIPARISID = ' + IntToStr(ID) + ' '+DbSinir(1));
        if Tablo.Query3.RecordCount > 0 then
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATBASLIK set AKTIVITEID='+Tablo.Query3.Fields[0].AsString+',STOKISK='+StringReplace(Tablo.Query3.Fields[1].AsString,',','.',[])+
                                                    ' where ID='+IntToStr(yeniid), [],[])
     end;


     case Tablo.Query1.FieldByName('TUR').AsInteger of
       6    :Tablo.UretimSihirbazBaslat('E', 0, yeniid, FATBASLIK.FieldByName('REHBERID').AsInteger);
       9,19 :{if Tablo.Query1.FieldByName('REHBERID').AsInteger<0 then begin
                i := Tablo.RehberAra_IDGetir(-1);
                if i > 0 then begin
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update SIPARIS set REHBERID='+IntToStr(i)+' where ID='+IntToStr(yeniid),[],[]);
                   Tablo.SiparisSihirbazBaslat('D',Tablo.Query1.FieldByName('TUR').AsInteger, 0,yeniid, i);
               end;
             end else }
                 Tablo.SiparisSihirbazBaslat('D',Tablo.Query1.FieldByName('TUR').AsInteger, 0,yeniid, FATBASLIK.FieldByName('REHBERID').AsInteger);
       10,14://eğer alış veya satış irsaliyesi faturaya dönüşüyorsa, faturada irsaliye no ve tarihi de görünmeli
             begin
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set IRSALIYETARIH='''+FormatDateTime('yyyy-mm-dd hh:nn', FATBASLIK.FieldByName('FATURATARIH').AsDateTime)+''',IRSALIYENO='''+FATBASLIK.FieldByName('FATURANO').AsString+''' where ID='+IntToStr(yeniid),[],[]);
                Tablo.FaturaSihirbazBaslat('E', Tablo.Query1.FieldByName('TUR').AsInteger, 0,yeniid, FATBASLIK.FieldByName('REHBERID').AsInteger, 1,False,-1);
             end
       else
         Tablo.FaturaSihirbazBaslat('E', Tablo.Query1.FieldByName('TUR').AsInteger, 0,yeniid, FATBASLIK.FieldByName('REHBERID').AsInteger, 1,False,-1);
     end;
     TarihDegisti;
  end else
     Application.MessageBox(PChar(Belge_olusmadi),PChar(Bilgi), MB_OK+ MB_ICONWARNING);
end;

procedure TFaturalarDlg.mnIrsaliyeyeDonusturClick(Sender: TObject);
var
  belgeno:TBelgeNo;
  FaturaSeriNo,FaturaNo:string;
  KocanNo:integer;
  gf : TFaturaGorevFrame;
begin
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  if GridFatListeTview.DataController.GetSelectedCount<=0  then
    Abort
  else
  begin
         //Tur: Giren:0,Çıkan:1 AltTur: sipariş:0,irsaliye:1,Fat:2,fiş:3,Tahakkuk:4,Tümü:-1
    case (Sender as TMenuItem).Tag of
     1 : begin // irsaliyeye dönüştür
          case gf.FAltTur of
            0:begin
              case gf.FMenuTur of
                0:begin
                 if FATBASLIK.FieldByName('ANAKAYITID').AsString <> '' then begin
                  ShowMessage(Girenirsaliyelisiparis);
                 end else   begin
                   if Application.MessageBox(PChar(Irsaliyeyapilsinmi),'UYARI',MB_YESNO)=IDNO then
                   Abort;

                   Tablo.Query1.Close;
                   Tablo.Query1.SQL.Text:='INSERT INTO FATBASLIK '+
                      ' ([TUR],[TIPI],[REHBERID],[PROJEID],[AKTIVITEID],[ANAKAYITID],[FATURATARIH],[KOCANNO],[FATURANO] '+
                      ' ,[GIRISDEPO],[CIKISDEPO],[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[LOTNO],[ACIK_KAPALI],[FATURA_GON_TARIHI]'+
                      ' ,[FATURA_MATRAHI],[KDV_TUTARI],[FATURA_TUTARI],[KUR],[DOVIZ_TUTARI],[DOVIZ_CINSI],[KASA],[ONAY],[SAYFA],[MASRAFID]'+
                      ' ,[ACIKLAMA],[ISYERI],[BOLUM],[SIPARIS_MALIYETI_ORT],[SATICIKODU],[DURUM],[IRSALIYE_TIPI],[SIPARIS_MALIYETI_SON],[ODEMEPLANI],[OZELKOD],OZELKOD2 '+
                      ' ,[YETKIKODU],[R],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI],[EKVERGI],[FATURASERI],[IRSALIYENO] '+
                      ' ,[FIYAT_LISTESI],[STOKISK],[HIZMETISK],[DETAYBOLUMU],[SUBEID])'+
                      '  SELECT 10,[TIPI],[REHBERID],[PROJEID],[AKTIVITEID],[ANAKAYITID],[SIPARISTARIH],[KOCANNO],[SIPARISNO]'+
                      ' ,[GIRISDEPO],[CIKISDEPO],[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[LOTNO],[ACIK_KAPALI],[SIPARIS_GON_TARIHI]'+
                      ' ,[SIPARIS_MATRAHI],[KDV_TUTARI],[SIPARIS_TUTARI],[KUR],[DOVIZ_TUTARI],[DOVIZ_CINSI],[KASA],[ONAY],[SAYFA],[MASRAFID] '+
                      ' ,[ACIKLAMA],[ISYERI],[BOLUM],[SIPARIS_MALIYETI_ORT],[SATICIKODU],[DURUM],[IRSALIYE_TIPI],[SIPARIS_MALIYETI_SON],[ODEMEPLANI],[OZELKOD],OZELKOD2 '+
                      ' ,[YETKIKODU],[R],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI],[EKVERGI],[SIPARISSERI],[IRSALIYENO]'+
                      ' ,[FIYAT_LISTESI],[STOKISK],[HIZMETISK],[DETAYBOLUMU],[SUBEID] FROM SIPARIS Where ID=:A0 SELECT SCOPE_IDENTITY() ';
                   if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
                   Tablo.Query1.Params[0].Value:=FATBASLIK.FieldByName('ID').AsInteger ;
                   Tablo.Query1.Open;
                   Tablo.Query2.Close;
                   Tablo.Query2.SQL.Text:= ' INSERT INTO FATURA ([FATBASID],[REHBERID],[SEC],[TUR],[URUNID],[KOD],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR],[BIRIMFIYAT],[TUTAR]'+
                    ' ,[ISKONTO],[KDV],[MASRAFID],[SKT],[OZELKOD],OZELKOD2,[MUHKODU],[KASA],[ONAY],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI]'+
                    ' ,[KUR],[IZLEMEKODU],[AD],[DOVIZ_TUTARI],[DOVIZ_CINSI],[ISKONTO2],[IZLEME],[YERI],[YERID],[SUBEID]) '+
                    ' SELECT :A0,[REHBERID],[SEC],[TUR],[URUNID],[KOD],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR],[BIRIMFIYAT],[TUTAR]'+
                    ' ,[ISKONTO],[KDV],[MASRAFID],[SKT],[OZELKOD],OZELKOD2,[MUHKODU],[KASA],[ONAY],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI]'+
                    ' ,[KUR],[IZLEMEKODU],[AD],[DOVIZ_TUTARI],[DOVIZ_CINSI],[ISKONTO2],[IZLEME],'''','''',[SUBEID]  FROM SIPARISDETAY where SIPARISID=:A1 ';
                    if AktifVeriMotor = vmPG then Tablo.Query2.SQL.Text := PgSqlCevir(Tablo.Query2.SQL.Text);
                    Tablo.Query2.Params[0].Value:= Tablo.Query1.Fields[0].AsInteger;
                    Tablo.Query2.Params[1].Value:=FATBASLIK.FieldByName('ID').AsInteger;
                    Tablo.Query2.ExecSQL;

                    Tablo.Query3.Close;
                    Tablo.Query3.SQL.Text:='Update SIPARIS set ANAKAYITID:=A0 Where ID:=A1';
                    if AktifVeriMotor = vmPG then Tablo.Query3.SQL.Text := PgSqlCevir(Tablo.Query3.SQL.Text);
                    Tablo.Query3.Params[0].Value:=Tablo.Query1.Fields[0].AsInteger;;
                    Tablo.Query3.Params[0].Value:=FATBASLIK.FieldByName('ID').AsInteger;
                    Tablo.Query3.ExecSQL;
                 end;

                end;
                1:begin
                     if FATBASLIK.FieldByName('ANAKAYITID').AsString <> '' then begin
                   ShowMessage(Cikanirsaliyelisiparis);
                   end else   begin

                         belgeno:= SiradakiBelgeNumarasi(9,FATBASLIK.FieldByName('FATURATARIH').AsDateTime);
                         FaturaSeriNo := belgeno.serino; //seri
                         FaturaNo:= belgeno.belgeno; //FatNo;
                         KocanNo := KocannoBul(19); //KOCAN numaras?

                       if Application.MessageBox(PChar(Irsaliyeyapilsinmi),PChar(Uyari),MB_YESNO)=IDNO then
                       Abort;

                       Tablo.Query1.Close;
                       Tablo.Query1.SQL.Text:='INSERT INTO FATBASLIK '+
                          ' ([TUR],[TIPI],[REHBERID],[PROJEID],[AKTIVITEID],[ANAKAYITID],[FATURATARIH],[KOCANNO],[FATURANO]'+
                          ' ,[GIRISDEPO],[CIKISDEPO],[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[LOTNO],[ACIK_KAPALI],[FATURA_GON_TARIHI]'+
                          ' ,[FATURA_MATRAHI],[KDV_TUTARI],[FATURA_TUTARI],[KUR],[DOVIZ_TUTARI],[DOVIZ_CINSI],[KASA],[ONAY],[SAYFA],[MASRAFID]'+
                          ' ,[ACIKLAMA],[ISYERI],[BOLUM],[SIPARIS_MALIYETI_ORT],[SATICIKODU],[DURUM],[IRSALIYE_TIPI],[SIPARIS_MALIYETI_SON],[ODEMEPLANI],[OZELKOD] '+
                          ' ,[YETKIKODU],[R],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI],[EKVERGI],[FATURASERI],[IRSALIYENO] '+
                          ' ,[FIYAT_LISTESI],[STOKISK],[HIZMETISK],[DETAYBOLUMU],[SUBEID])'+
                          '  SELECT 14,[TIPI],[REHBERID],[PROJEID],[AKTIVITEID],[ANAKAYITID],[SIPARISTARIH],:A0,:A1'+
                          ' ,[GIRISDEPO],[CIKISDEPO],[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[LOTNO],[ACIK_KAPALI],[SIPARIS_GON_TARIHI]'+
                          ' ,[SIPARIS_MATRAHI],[KDV_TUTARI],[SIPARIS_TUTARI],[KUR],[DOVIZ_TUTARI],[DOVIZ_CINSI],[KASA],[ONAY],[SAYFA],[MASRAFID] '+
                          ' ,[ACIKLAMA],[ISYERI],[BOLUM],[SIPARIS_MALIYETI_ORT],[SATICIKODU],[DURUM],[IRSALIYE_TIPI],[SIPARIS_MALIYETI_SON],[ODEMEPLANI],[OZELKOD] '+
                          ' ,[YETKIKODU],[R],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI],[EKVERGI],:A2,[IRSALIYENO]'+
                          ' ,[FIYAT_LISTESI],[STOKISK],[HIZMETISK],[DETAYBOLUMU],[SUBEID] FROM SIPARIS Where ID=:A3 SELECT SCOPE_IDENTITY() ';
                       if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
                       Tablo.Query1.Params[0].Value:=KocanNo;
                       Tablo.Query1.Params[1].Value:=FaturaNo ;
                       Tablo.Query1.Params[2].Value:= FaturaSeriNo;
                       Tablo.Query1.Params[3].Value:=FATBASLIK.FieldByName('ID').AsInteger ;
                       Tablo.Query1.Open;
                       Tablo.Query2.Close;
                       Tablo.Query2.SQL.Text:= ' INSERT INTO FATURA ([FATBASID],[REHBERID],[SEC],[TUR],[URUNID],[KOD],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR],[BIRIMFIYAT],[TUTAR]'+
                        ' ,[ISKONTO],[KDV],[MASRAFID],[SKT],[OZELKOD],OZELKOD2,[MUHKODU],[KASA],[ONAY],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI]'+
                        ' ,[KUR],[IZLEMEKODU],[AD],[DOVIZ_TUTARI],[DOVIZ_CINSI],[ISKONTO2],[IZLEME],[YERI],[YERID],[SUBEID]) '+
                        ' SELECT :A0,[REHBERID],[SEC],[TUR],[URUNID],[KOD],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR],[BIRIMFIYAT],[TUTAR]'+
                        ' ,[ISKONTO],[KDV],[MASRAFID],[SKT],[OZELKOD],OZELKOD2,[MUHKODU],[KASA],[ONAY],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI]'+
                        ' ,[KUR],[IZLEMEKODU],[AD],[DOVIZ_TUTARI],[DOVIZ_CINSI],[ISKONTO2],[IZLEME],'''','''',[SUBEID]  FROM SIPARISDETAY where SIPARISID=:A1 ';
                        if AktifVeriMotor = vmPG then Tablo.Query2.SQL.Text := PgSqlCevir(Tablo.Query2.SQL.Text);
                        Tablo.Query2.Params[0].Value:= Tablo.Query1.Fields[0].AsInteger;
                        Tablo.Query2.Params[1].Value:=FATBASLIK.FieldByName('ID').AsInteger;
                        Tablo.Query2.ExecSQL;

                        Tablo.Query3.Close;
                        Tablo.Query3.SQL.Text:='Update SIPARIS set ANAKAYITID:=A0 , IRSALIYENO:=A1 Where ID:=A2';
                        if AktifVeriMotor = vmPG then Tablo.Query3.SQL.Text := PgSqlCevir(Tablo.Query3.SQL.Text);
                        Tablo.Query3.Params[0].Value:=Tablo.Query1.Fields[0].AsInteger;
                        Tablo.Query3.Params[1].Value:=FaturaNo;
                        Tablo.Query3.Params[2].Value:=FATBASLIK.FieldByName('ID').AsInteger;
                        Tablo.Query3.ExecSQL;
                   end;
                end;
              end;
            end;
          end;
        end;

     2 : begin      //faturaya dönüştür
          case gf.FAltTur of
            0:begin
              case gf.FMenuTur of
                0:begin
                   if FATBASLIK.FieldByName('IRSALIYENO').AsString <> Null then begin
                   ShowMessage(Girenirsaliyelisiparis);
                   end else   begin

                   end;
                end;
                1:begin
                     if FATBASLIK.FieldByName('IRSALIYENO').AsString <> Null then begin
                   ShowMessage(Cikanirsaliyelisiparis);
                   end else   begin

                   end;
                end;
              end;
            end;
            1:Begin
              case gf.FMenuTur of
                0:begin
                   if FATBASLIK.FieldByName('IRSALIYENO').AsString <> Null then begin
                   ShowMessage(Girenirsaliyelifatura);
                   end else   begin

                   end;
                end;
                1:begin
                     if FATBASLIK.FieldByName('IRSALIYENO').AsString <> Null then begin
                   ShowMessage(Cikanirsaliyelifatura);
                   end else   begin

                   end;
                end;
              end;
            End;
          end;
         end;

    end;
  end;
end;

procedure TFaturalarDlg.Nakit1Click(Sender: TObject);
var Tur, ID : Integer;
    HesapTuru : Char;
    DateSaat:TDateTime;
begin
   if TMenuItem(Sender).Tag=35 then
      Tur:=35
   else if (TMenuItem(Sender).Tag=25)and(TahsilOdemeMenu.tag=10)then
       Tur:=125 //Bir tahsil pos bir de ?deme pos var. bu ?deme pos ise 125 olmal?
   else
       Tur := TMenuItem(Sender).Tag + TahsilOdemeMenu.tag; //Ödemeler için 10 daha ekleriz.
   case Tur of
    21,31 : HesapTuru := 'K';
    22,32 : HesapTuru := 'B';
    35 : HesapTuru := 'V';
    25,125    : HesapTuru := 'P';
   else
    HesapTuru := '-';
   end;
   case Tur of
     9,19: ID := Tablo.SiparisSihirbazBaslat('E', Tur,0, -1, FATBASLIK.Fields[0].AsInteger);
     10,11,12,14,15,16 : ID := Tablo.FaturaSihirbazBaslat('E', Tur,-1, -1, FATBASLIK.Fields[0].AsInteger);
     13,17 : ID := Tablo.TahakkukSihirbaziBaslat('E', Tur,1, -1, FATBASLIK.Fields[0].AsInteger, Tablo.GENINI.BugunTrhSaat);
     23 : ID := Tablo.CekSihirbazBaslat('E', Tur,1, 0, -99, FATBASLIK.Fields[0].AsInteger,-1, Tablo.GENINI.BugunTrhSaat, '');
     33 : begin
      Tablo.TablodanSorguAc(1,'Select * from CEKLER Where TUR=23 and DURUM=1 and isnull(CIROLU,0) <> 1 ');
      if Tablo.Query1.RecordCount > 0 then begin
         DateSaat:=StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', Tablo.GENINI.BugunTrhSaat));
         Tablo.CiroEdileceklerBaslat('R',1,Tur,0,-1,FATBASLIK.Fields[0].AsInteger,-1,DateSaat,'');
      end
      else
         Tablo.CekSihirbazBaslat('E', Tur, 1, 0, -99, FATBASLIK.Fields[0].AsInteger,-1, Tablo.GENINI.BugunTrhSaat, '');
     end;
     21,22,25,31,32,35,125 : ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,0, -1, FATBASLIK.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrhSaat, '-1',False,-1,-1,-1,-1,FATBASLIK.FieldByName('ID').AsInteger);
     61,71  : begin
                DateSaat:=Tablo.GENINI.BugunTrhSaat;
                ID := Tablo.KasaSihirbazBaslat('E', -1, Tur, 0, FATBASLIK.Fields[0].AsInteger, DateSaat, DateSaat,0,0,'','');
              end;
   end;
   //if ID > 0 then
   //   PageControlSekmeChange(Self);
end;

procedure TFaturalarDlg.pmBelgeDonusturPopup(Sender: TObject);
var
  gf : TFaturaGorevFrame;
  LTur: Integer;
begin
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  MenuYanitla.Visible := False;
  mnIrsaliyesiniOlustur.Enabled:=False;
  mnFaturasiniOlustur.Enabled:=False;
  mnSatisFisiniOlustur.Enabled:=False;
  KonsinyesiniOlusturMenu.Visible := gf.FAltTur = KasaTur_SatisSiparisi; //19 ise görünsün
  UretimFisiniOlutur.Visible := gf.FAltTur = KasaTur_SatisSiparisi;
//  IptalIsaretleMenu.Enabled := FATBASLIK.FieldByName('DURUMNEREYE').AsString='';
  MenuDurumuGuncelle.Visible := (gf.FAltTur = 9)or(gf.FAltTur = 19); //alış satış siparişi ise

  if gf.FAlttur in [109,119] then begin //konsinye ise
    SipariiniOlutur1.Visible := False;
    mnIrsaliyesiniOlustur.Visible:=True;
    mnFaturasiniOlustur.Visible:=True;
    mnSatisFisiniOlustur.Visible:=True;
    KaynakBelgeyiA1.Visible:=True;
  end else if gf.FAlttur in [101] then begin //satınalma talebi ise
    SipariiniOlutur1.Visible := True;
//    SipariiniOlutur1.Enabled := FATBASLIK.FieldByName('DURUMNEREYE').AsString = '';
    mnIrsaliyesiniOlustur.Visible:=False;
    mnFaturasiniOlustur.Visible:=False;
    mnSatisFisiniOlustur.Visible:=False;
    KaynakBelgeyiA1.Visible:=False;
  end else begin
    SipariiniOlutur1.Visible := False;
    mnIrsaliyesiniOlustur.Visible:=True;
    mnFaturasiniOlustur.Visible:=True;
    mnSatisFisiniOlustur.Visible:=True;
    KaynakBelgeyiA1.Visible:=True;
  end;
  if (FATBASLIK.FieldByName('DURUM').AsInteger <> 6) and (FATBASLIK.Active)then begin //belge iptal değil ise
    case FATBASLIK.FieldByName('TUR').AsInteger of
      KasaTur_AlisSiparisi, KasaTur_SatisSiparisi : begin
             mnIrsaliyesiniOlustur.Enabled := (FATBASLIK.FieldByName('DURUMNEREYE').AsString = '')or(FATBASLIK.FieldByName('DURUMNEREYE').AsString = 'Üretim Fişine') ;
             mnFaturasiniOlustur.Enabled := (FATBASLIK.FieldByName('DURUMNEREYE').AsString = '')or(FATBASLIK.FieldByName('DURUMNEREYE').AsString = 'Üretim Fişine') ;
             mnSatisFisiniOlustur.Enabled := mnFaturasiniOlustur.Enabled;
             KonsinyesiniOlusturMenu.Enabled := (FATBASLIK.FieldByName('DURUMNEREYE').AsString = '')or(FATBASLIK.FieldByName('DURUMNEREYE').AsString = 'Üretim Fişine');
             UretimFisiniOlutur.Enabled := FATBASLIK.FieldByName('DURUMNEREYE').AsString = '';
           end;
      109,119 : begin
             mnIrsaliyesiniOlustur.Enabled := (FATBASLIK.FieldByName('DURUMNEREYE').AsString = '')and(FATBASLIK.FieldByName('TUR').AsInteger<>KasaTur_SatisIrsaliyesi);
             mnFaturasiniOlustur.Enabled := FATBASLIK.FieldByName('DURUMNEREYE').AsString = '';
           end;
      KasaTur_AlisIrsaliyesi, KasaTur_SatisIrsaliyesi: begin

             mnIrsaliyesiniOlustur.Enabled := False;
             mnFaturasiniOlustur.Enabled := FATBASLIK.FieldByName('DURUMNEREYE').AsString = '';
             mnSatisFisiniOlustur.Enabled := mnFaturasiniOlustur.Enabled;
           end;
    end;

    case FATBASLIK.FieldByName('TUR').AsInteger of
      KasaTur_AlisSiparisi, KasaTur_AlisIrsaliyesi : begin
                mnSatisFisiniOlustur.Caption := 'Alış Fişini Oluştur';
                mnIrsaliyesiniOlustur.Tag := 10;
                mnFaturasiniOlustur.Tag := 11;
                mnSatisFisiniOlustur.Tag := 12;
             end;
      KasaTur_SatisSiparisi, KasaTur_SatisIrsaliyesi : begin
                mnSatisFisiniOlustur.Caption := 'Satış Fişini Oluştur';
                mnIrsaliyesiniOlustur.Tag := 14;
                mnFaturasiniOlustur.Tag := 15;
                mnSatisFisiniOlustur.Tag := 16;
             end;
      end;
  end;
//  KaynakBelgeyiA1.Enabled := FATBASLIK.FieldByName('DURUMNEREDEN').AsString <> '';
//  HedefBelgeyiA1.Enabled := FATBASLIK.FieldByName('DURUMNEREYE').AsString <> '';
  //Tur: Giren:0,Çıkan:1 AltTur: sipariş:0,irsaliye:1,Fat:2,fiş:3,Tahakkuk:4,Tümü:-1

  //ExceldenBelgeEkle.Visible := gf.FAltTur in [14,15,19];
  //N7.Visible     := ExceldenBelgeEkle.Visible;

  IadeAl.Visible := gf.FAltTur in [15,16];
  N8.Visible     := IadeAl.Visible;
  IptalIsaretleMenu.Visible := not( gf.FAltTur in [8,9,10,11,12,13,101,109]);

  // e-Belge alt menusu:
  //   TUR=11 (alis/gelen)  -> Tag=2 olan alt menuler gorunur
  //   TUR=14/15 (giden)    -> Tag=1 olan alt menuler gorunur
  //   Tag=0 olanlar (ayraclar/genel) her zaman gorunur
  // Tek akis: TUR 14 -> 'e-İrsaliye' (e-Fatura MASTER anahtar + e-İrsaliye anahtari),
  // TUR 15/11 -> 'e-Fatura'. Gelen (11) Tag=2 alt menuleri + kosullu Yanitla;
  // giden (14/15) Tag=1 alt menuleri gorur.
  MenueFatura.Visible := False;
  if FATBASLIK.Active and not FATBASLIK.IsEmpty then begin
    LTur := FATBASLIK.FieldByName('TUR').AsInteger;
    if LTur in [EBelgeTuruEIrsaliye, EBelgeTuruEFatura, 11] then begin
      if LTur = EBelgeTuruEIrsaliye then
        MenueFatura.Caption := 'e-İrsaliye'
      else
        MenueFatura.Caption := 'e-Fatura';
      MenueFatura.Visible := (EFaturaKullanimda > 0) and
        ((LTur <> EBelgeTuruEIrsaliye) or EIrsaliyeKullanimda);
      if MenueFatura.Visible then
        if LTur = 11 then begin
          _MenuTagFiltrele(MenueFatura, 2);
          MenuYanitla.Visible := FATBASLIK.FieldByName('EFATURASONUC').AsInteger = 6;
        end else
          _MenuTagFiltrele(MenueFatura, 1);
    end;
  end;
//  if gf.FAltTur in [15,16] then
//        POSMenu.Tag := 25
//     else
//        POSMenu.Tag := 125


end;

function TFaturalarDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TFaturalarDlg.Gorunmez;
begin

end;

procedure TFaturalarDlg.GorunmezOlacak;
begin

end;

procedure TFaturalarDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TFaturalarDlg.GorunurOlacak;
begin

end;

procedure TFaturalarDlg.GridFatViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridFat;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFatView;
  AnaForm.pmGridStil.Tags.Values[GridFat.Name]:='AlSatListeDetayGridi';
end;

procedure TFaturalarDlg.GridFatListeTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
var gf : TFaturaGorevFrame;
begin
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);

  AnaForm.cxGridPopupMenu1.Grid:=GridFatListe;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFatListeTview;
  AnaForm.pmGridStil.Tags.Values[GridFatListe.Name]:='AlisSatisListeGridi-'+IntToStr(gf.FAltTur)+'-'+BoolToStr(FArama.CheckEkAlanlarListelensin.checked, False)
end;

procedure TFaturalarDlg.GridFatListeTviewDblClick(Sender: TObject);
var
   ID,Tur :integer;
   Kilit:Boolean;
   LGelenKutusu: Boolean;
begin
  // EFATURASONUC = "Hata/Red" (3) hucresine cift tikla: faturayi acmak yerine
  // e-belge mesaj gecmisini goster (gonderim/red mesajlarini gormek icin).
  if (GridFatListeTview.Controller.FocusedColumn = GridFatListeTviewEFATURASONUC) and
     FATBASLIK.Active and (not FATBASLIK.IsEmpty) and
     (FATBASLIK.FieldByName('EFATURASONUC').AsInteger = 3) then begin
    MenuMesajlarGosterClick(nil);
    Exit;
  end;

  // Gelen faturalar sekmelerinde (tag 1201-1203) cift tikla: sadece faturayi ac,
  // sonrasinda TarihDegisti vb. listeyi tazeleme/yan etki tetikleme.
  LGelenKutusu := (PageControlTur.ActivePage <> nil) and
                  (PageControlTur.ActivePage.Tag >= 1201) and (PageControlTur.ActivePage.Tag <= 1203);

  case FATBASLIK.FieldByName('TUR').AsInteger of
    13,17: Tablo.TahakkukSihirbaziBaslat('D',FATBASLIK.FieldByName('TUR').AsInteger,1,FATBASLIK.FieldByName('ID').AsInteger, FATBASLIK.FieldByName('REHBERID').AsInteger,-1);
    9,19: Tablo.SiparisSihirbazBaslat('D',FATBASLIK.FieldByName('TUR').AsInteger,0,FATBASLIK.FieldByName('ID').AsInteger, 0);
    101: Tablo.SatinalmaSihirbazBaslat2('D',FATBASLIK.FieldByName('TUR').AsInteger,0,FATBASLIK.FieldByName('ID').AsInteger, 0);
  else
    Tablo.FaturaSihirbazBaslat('D',FATBASLIK.AsInteger['TUR'],-1, FATBASLIK.AsInteger['ID'], FATBASLIK.AsInteger['REHBERID'],1,Kilit);
  end;

  if not LGelenKutusu then
    TarihDegisti;
end;

procedure TFaturalarDlg.GridFatListeTviewSelectionChanged(Sender: TcxCustomGridTableView);
var
  Page: TcxTabSheet;
  CanChange: Boolean;
begin
  Page := cxPageControl1.ActivePage; // or any index you want
  CanChange := True;

  cxPageControl1PageChanging(cxPageControl1, Page, CanChange);
{procedure TFaturalarDlg.FATBASLIKAfterScroll(DataSet: TDataSet);
var CanChange:boolean;
begin
  CanChange := True;
  cxPageControl1PageChanging(nil,cxPageControl1.ActivePage,CanChange);
end;     }
    //cxPageControl1PageChanging(Sender, cxPageControl1.ActivePage, False);
  //  GridFatListeTviewSelectionChanged(FaturalarDlg.GridFatListe.ViewData);

end;

function TFaturalarDlg.EBelgeHucreStyle(var AStyleRef: TcxStyle;
  ABackColor, ATextColor: TColor): TcxStyle;
begin
  if AStyleRef = nil then
    AStyleRef := TcxStyle.Create(Self);
  AStyleRef.Color := ABackColor;
  AStyleRef.Font.Assign(GridFatListe.Font);
  AStyleRef.Font.Color := ATextColor;
  AStyleRef.TextColor := ATextColor;
  Result := AStyleRef;
end;
procedure TFaturalarDlg.GridFatListeTviewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  LDeger: Integer;
begin
  // Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
  if (ARecord = nil) or (AItem = nil) then Exit;

  if AItem = GridFatListeTviewEFATURADURUM then begin
    LDeger := StrToIntDef(VarToStr(ARecord.Values[GridFatListeTviewEFATURADURUM.Index]), 0);
    case LDeger of
      0: AStyle := EBelgeHucreStyle(FEBelgeStyleYeni, clWhite, GridFatListe.Font.Color); // Yeni: beyaz
      1, 11, 41, 51:
         AStyle := EBelgeHucreStyle(FEBelgeStyleSari, RGB(255, 193, 7), clBlack); // Hazir: sari
      2, 12, 42, 52, -2:
         AStyle := EBelgeHucreStyle(FEBelgeStyleYesil, RGB(76, 175, 80), clWhite); // Gonderildi / iceri alindi
      -1: AStyle := EBelgeHucreStyle(FEBelgeStyleYesil, RGB(76, 175, 80), clWhite); // Gelen yeni: yesil
      -3: AStyle := EBelgeHucreStyle(FEBelgeStylePasif, RGB(158, 158, 158), clWhite); // Alinmayacak
    end;
    Exit;
  end;

  if AItem = GridFatListeTviewEFATURASONUC then begin
    LDeger := StrToIntDef(VarToStr(ARecord.Values[GridFatListeTviewEFATURASONUC.Index]), 0);
    case LDeger of
      0: AStyle := EBelgeHucreStyle(FEBelgeStyleYeni, clWhite, GridFatListe.Font.Color); // Yeni: beyaz
      1, 6, 7, 8, 9:
         AStyle := EBelgeHucreStyle(FEBelgeStyleSari, RGB(255, 193, 7), clBlack); // Bekleyen/taslak/rapor/GIB/alindi: sari
      2, 10, 11, 12: AStyle := EBelgeHucreStyle(FEBelgeStyleYesil, RGB(76, 175, 80), clWhite); // Basarili / yanit gerekmiyor / kanunen kabul
      3: AStyle := EBelgeHucreStyle(FEBelgeStyleKirmizi, RGB(244, 67, 54), clWhite); // Hata / Red
      4: AStyle := EBelgeHucreStyle(FEBelgeStylePasif, RGB(158, 158, 158), clWhite); // Iptal
      5: AStyle := EBelgeHucreStyle(FEBelgeStyleYesil, RGB(76, 175, 80), clWhite); // Cevap suresi gecti
    end;
    Exit;
  end;
end;

procedure TFaturalarDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabloNo);
end;

procedure TFaturalarDlg.HedefBelgeyiA1Click(Sender: TObject);
var
  sts:TStringlist;
  AYeri,AYerID:Integer;
  ABelgeno:string;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := '';
  case FATBASLIK.FieldByName('TUR').AsInteger of
    9,19:begin
      Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.FATURANO,FB.ID ');
      Tablo.Query1.SQL.Add(' from SIPARISDETAY SD ');
      Tablo.Query1.SQL.Add(' 	inner join FATURA F2 on SD.ID=F2.YERID and F2.YERI in (406,407,409,410,415,420,429,473) ');
      Tablo.Query1.SQL.Add(' 	inner join FATBASLIK FB on F2.FATBASID=FB.ID ');
      Tablo.Query1.SQL.Add(' where SD.SIPARISID='+FATBASLIK.FieldByName('ID').AsString);
    end;
    101:begin
      Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.SIPARISNO,FB.ID ');
      Tablo.Query1.SQL.Add(' from SIPARISDETAY SD ');
      Tablo.Query1.SQL.Add(' 	inner join SIPARISDETAY F2 on SD.ID=F2.YERID and F2.YERI in (406,407,409,410,415,420,428,473) ');
      Tablo.Query1.SQL.Add(' 	inner join SIPARIS FB on F2.SIPARISID=FB.ID ');
      Tablo.Query1.SQL.Add(' where SD.SIPARISID='+FATBASLIK.FieldByName('ID').AsString);
    end;
  else
    Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.FATURANO,FB.ID ');
    Tablo.Query1.SQL.Add(' from FATURA F ');
    Tablo.Query1.SQL.Add(' 	inner join FATURA F2 on F.ID=F2.YERID and F2.YERI in (408,411,461,424,427,462,468) ');
    Tablo.Query1.SQL.Add(' 	inner join FATBASLIK FB on F2.FATBASID=FB.ID ');
    Tablo.Query1.SQL.Add(' where F.FATBASID='+FATBASLIK.FieldByName('ID').AsString);
  end;
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.Open;
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
      if Tablo.ListedenBilgiGetir('Hedef Seçimi',Tablo.Query1.SQL.Text,sts,[Tablo.RepKasaTurleriReadOnly,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],'FaturalarHedefSecimi')then begin
        AYeri := StrToInt(sts[0]);
        AYerID:= StrToInt(sts[2]);
        ABelgeno:= sts[1];
      end;
    finally
      sts.Free;
    end;
  end;
  AnaForm.GormeDialogCagir(AYerID,AYeri,FATBASLIK.FieldByName('REHBERID').AsInteger,0,Tablo.GENINI.BugunTrh,ABelgeno);
end;

procedure TFaturalarDlg.HizliGirisTusClick(Sender: TObject);
begin
  Application.CreateForm(Tbelgegirisdlg, belgegirisdlg);
  belgegirisdlg.ShowModal;
  TarihDegisti;
end;

procedure TFaturalarDlg._TabsheetleriYukle(AAltTur: Integer);
// AltTur=11 (alis fatura): Tumu | Gelen Kutusu | Iceri Alinan | Alinmayacak | Basarili | Bekleyen | Hata/Red | Suresi Gecen
// AltTur=14/15 (giden e-belge): Tumu | Yeni | Hazir | Basarili | Bekleyen | Hata/Red | Iptal | Suresi Gecen
const
  TumuName = 'TabSheetTumu';

  procedure EkleTab(const ACaption: string; ATag: Integer);
  var TS: TcxTabSheet;
  begin
    TS := TcxTabSheet.Create(PageControlTur);
    TS.PageControl := PageControlTur;
    TS.Caption := ACaption;
    TS.Tag := ATag;
  end;

  procedure EkleAltTab(const ACaption: string; ATag: Integer);
  var TS: TcxTabSheet;
  begin
    TS := TcxTabSheet.Create(PageControlAlt);
    TS.PageControl := PageControlAlt;
    TS.Caption := ACaption;
    TS.Tag := ATag;
  end;

var
  i: Integer;
  Sheet: TcxTabSheet;
begin
  // TabSheetTumu disindaki tum sekmeleri kaldir (eski AltTur'den arta kalanlar)
  for i := PageControlTur.PageCount - 1 downto 0 do begin
    Sheet := PageControlTur.Pages[i];
    if (Sheet <> nil) and not SameText(Sheet.Name, TumuName) then
      Sheet.Free;
  end;
  // Gelen Kutusu alt seridini tamamen temizle/gizle
  for i := PageControlAlt.PageCount - 1 downto 0 do
    PageControlAlt.Pages[i].Free;
  PageControlAlt.Visible := False;
  TabSheetTumu.Caption := 'Tümü';
  TabSheetTumu.Tag := 0;

  case AAltTur of
    10, 11: begin
      // e-Fatura kullanimda master anahtardir: kapaliysa hicbir e-Belge sekmesi
      // gosterilmez (sadece "Tümü"). Acikken: gelen fatura (11); gelen irsaliye (10)
      // ayrica e-İrsaliye kullanimda ise.
      if (EFaturaKullanimda > 0) and
         ((AAltTur = 11) or ((AAltTur = 10) and EIrsaliyeKullanimda)) then begin
        // 3 ana sekme: Sistem | Gelen Kutusu | Kullanım Dışı
        TabSheetTumu.Caption := 'Sistem';   // EFATURADURUM in (0,-2,-12)
        TabSheetTumu.Tag := 1201;
        EkleTab('Gelen Kutusu', 1202);
        EkleTab('Kullanım Dışı', 1203);              // EFATURADURUM in (-3,-13)
        // Gelen Kutusu alt sekmeleri (PageControlAlt)
        EkleAltTab('Alındı', 1211);                  // EFATURADURUM in (-1,-11)
        EkleAltTab('Yanıt Bekleyen', 1212);
        EkleAltTab('Hata/Red', 1213);
        EkleAltTab('Süresi Geçen', 1214);
      end else begin
        // e-Fatura kapali (veya gelen irsaliyede e-İrsaliye kapali) -> sadece "Tümü".
        TabSheetTumu.Caption := 'Tümü';
        TabSheetTumu.Tag := 0;                          // filtresiz (tüm kayitlar)
      end;
    end;
    14, 15: begin
      // e-Fatura kullanimda master anahtardir: kapaliysa hicbir e-Belge sekmesi yok
      // (sadece "Tümü"). Acikken: giden fatura (15); giden irsaliye (14) ayrica
      // e-İrsaliye kullanimda ise.
      if (EFaturaKullanimda > 0) and
         ((AAltTur = 15) or ((AAltTur = 14) and EIrsaliyeKullanimda)) then begin
        // 4 ana sekme: Tümü | Taslak | Hazır | Gönderilmiş (alt sekmeli)
        TabSheetTumu.Caption := 'Tümü';
        TabSheetTumu.Tag := 1520;                        // tümü (filtresiz)
        EkleTab('Taslak', 1523);                         // EFATURADURUM = 0
        EkleTab('Haz'#$131'r', 1521);                    // 15: (1,11) | 14: 51
        EkleTab('G'#$F6'nderilmi'#$15F, 1522);           // Gönderilmiş (alt sekmeli)
        // Gönderilmiş alt sekmeleri (PageControlAlt)
        EkleAltTab('Yeni Giden', 1531);                  // 15: (2,12,52) | 14: 52
        EkleAltTab('Bekleyen', 1532);
        EkleAltTab('Hata/Red', 1533);
        EkleAltTab('S'#$FC'resi Ge'#$E7'en', 1534);      // Suresi Gecen
      end else begin
        // e-Fatura (15) / e-İrsaliye (14) kapali iken durum sekmeleri gizli; sadece "Tümü".
        TabSheetTumu.Caption := 'Tümü';
        TabSheetTumu.Tag := 0;                          // filtresiz (tüm kayitlar)
      end;
    end;
  end;

  PageControlTur.ActivePage := TabSheetTumu;
  // ActivePage degistirmek OnChange'i her zaman tetiklemeyebilir, manuel uygula
  PageControlTurChange(PageControlTur);
end;

procedure TFaturalarDlg.PageControlTurChange(Sender: TObject);
const
  YeniGelenMarker = '/*YENIGELEN*/';
var
  LFilter, LSent, LReady, LWaiting: string;
  gf: TFaturaGorevFrame;
  LAltTur, LTag: Integer;
  LYeniGelenAktif: Boolean;
begin
  if PageControlTur.ActivePage = nil then Exit;

  // "Yeni Giden" tarih filtresi yalnizca o sekmede gecerli; diger sekmelerde temizle.
  FATBASLIK.OnFilterRecord := nil;

  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  LAltTur := gf.FAltTur;
  LTag := PageControlTur.ActivePage.Tag;

  // GELEN (AltTur=11 fatura, e-İrsaliye kullanimda iken AltTur=10 irsaliye).
  if (LAltTur = 11) or ((LAltTur = 10) and EIrsaliyeKullanimda) then begin
    _GelenSekmeUygula;
    Exit;
  end;

  // GIDEN (AltTur=15 fatura, e-İrsaliye kullanimda iken AltTur=14 irsaliye).
  if (LAltTur = 15) or ((LAltTur = 14) and EIrsaliyeKullanimda) then begin
    _GidenSekmeUygula;
    Exit;
  end;

  // ---- GIDEN e-Belge (AltTur=14/15) ----
  LYeniGelenAktif := Pos(YeniGelenMarker, FATBASLIK.SQL.Text) > 0;
  PageControlAlt.Visible := False;
  if FArama <> nil then begin
    FArama.Enabled := True;
    FArama.CheckTarihAralik.Enabled := True;
    FArama.Calendar1.Enabled := True;
    FArama.Calendar2.Enabled := True;
    FArama.Panel1.Enabled := True;
  end;
  if LYeniGelenAktif then begin
    TarihDegisti;
    Exit;
  end;

  if not FATBASLIK.Active then Exit;

  LSent := '((EFATURADURUM = 2) OR (EFATURADURUM = 12) OR (EFATURADURUM = 52))';
  LReady := '((EFATURADURUM = 1) OR (EFATURADURUM = 11) OR (EFATURADURUM = 51))';
  LWaiting := '((EFATURASONUC IS NULL) OR (EFATURASONUC = 0) OR (EFATURASONUC = 1) OR ' +
    '(EFATURASONUC = 6) OR (EFATURASONUC = 7) OR (EFATURASONUC = 8) OR ' +
    '(EFATURASONUC = 9))';

  case LTag of
    1501: LFilter := 'EFATURADURUM = 0';
    1502: LFilter := LReady;
    1503: LFilter := LSent + ' AND (EFATURASONUC = 2)';
    1504: LFilter := LSent + ' AND ' + LWaiting;
    1505: LFilter := LSent + ' AND (EFATURASONUC = 3)';
    1506: LFilter := LSent + ' AND (EFATURASONUC = 4)';
    1507: LFilter := LSent + ' AND (EFATURASONUC = 5)';
  else
    LFilter := '';
  end;

  FATBASLIK.Filter := LFilter;
  FATBASLIK.Filtered := LFilter <> '';
  _KayitSayisiGuncelle;
end;

procedure TFaturalarDlg.PageControlAltChange(Sender: TObject);
var
  gf: TFaturaGorevFrame;
begin
  // Alt sekme degisti -> ilgili (gelen/giden) filtreyi yeniden uygula.
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  if (gf.FAltTur = 15) or ((gf.FAltTur = 14) and EIrsaliyeKullanimda) then
    _GidenSekmeUygula
  else
    _GelenSekmeUygula;
end;

// Giden faturalar (TUR=15) / giden e-İrsaliye (TUR=14) ana/alt sekme filtresi.
//   Ana sekmeler:  Tumu (filtresiz)=1520 | Taslak=1523 | Hazir=1521 | Gonderilmis=1522
//   Gonderilmis alt: Yeni Giden=1531 | Bekleyen=1532 | Hata/Red=1533 | Suresi Gecen=1534
//   e-İrsaliye'de EFATURADURUM kodlari: Hazir=51, Gonderilmis=52.
procedure TFaturalarDlg._GidenSekmeUygula;
var
  LAnaTag, LAltTag: Integer;
  LFilter, LSent, LReady, LWaiting: string;
  LGonderilmis: Boolean;
  LBugun: TDateTime;
  gf: TFaturaGorevFrame;
begin
  if PageControlTur.ActivePage = nil then Exit;
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);

  // Tarih bazli ozel filtre (Yeni Giden) varsayilan olarak kapali.
  FATBASLIK.OnFilterRecord := nil;

  // Sol arama paneli (tarih araligi dahil) aktif kalsin.
  if FArama <> nil then begin
    FArama.Enabled := True;
    FArama.CheckTarihAralik.Enabled := True;
    FArama.Calendar1.Enabled := True;
    FArama.Calendar2.Enabled := True;
    FArama.Panel1.Enabled := True;
  end;

  if not FATBASLIK.Active then begin
    PageControlAlt.Visible := False;
    Exit;
  end;

  LAnaTag := PageControlTur.ActivePage.Tag;
  LGonderilmis := (LAnaTag = 1522);
  // Alt seridi yalnizca "Gönderilmiş" ana sekmesinde goster.
  PageControlAlt.Visible := LGonderilmis;

  if gf.FAltTur = 14 then begin
    // e-İrsaliye: oluştu=51 (Hazır), gönderildi=52 (Gönderilmiş).
    LReady := '(EFATURADURUM = 51)';
    LSent  := '(EFATURADURUM = 52)';
  end else begin
    // e-Fatura / e-Arşiv.
    LReady := '((EFATURADURUM = 1) OR (EFATURADURUM = 11))';
    LSent  := '((EFATURADURUM = 2) OR (EFATURADURUM = 12) OR (EFATURADURUM = 52))';
  end;
  LWaiting := '((EFATURASONUC IS NULL) OR (EFATURASONUC = 0) OR (EFATURASONUC = 1) OR ' +
    '(EFATURASONUC = 6) OR (EFATURASONUC = 7) OR (EFATURASONUC = 8) OR ' +
    '(EFATURASONUC = 9))';

  if LGonderilmis then begin
    LAltTag := 1531;
    if PageControlAlt.ActivePage <> nil then
      LAltTag := PageControlAlt.ActivePage.Tag;
    case LAltTag of
      1531: begin
        // Yeni Giden = gönderilmiş (2,12,52) + son 2 iş günü gönderilenler.
        LFilter := LSent;
        // Tarih araligi: dün + bugün; bugün Pazartesi ise Cuma + Pazartesi.
        LBugun := Int(Tablo.GENINI.BugunTrhSaat);
        if DayOfWeek(LBugun) = 2 then     // 2 = Pazartesi
          FYeniGidenBas := LBugun - 3     // önceki Cuma
        else
          FYeniGidenBas := LBugun - 1;    // dün
        FYeniGidenBit := LBugun + 1;      // bugün dahil (üst sınır hariç)
        FATBASLIK.OnFilterRecord := FATBASLIKFilterYeniGiden;
      end;
      1532: LFilter := LSent + ' AND ' + LWaiting;         // Bekleyen
      1533: LFilter := LSent + ' AND (EFATURASONUC = 3)';  // Hata/Red
      1534: LFilter := LSent + ' AND (EFATURASONUC = 5)';  // Süresi Geçen
    else
      LFilter := LSent;
    end;
  end else begin
    case LAnaTag of
      1523: LFilter := 'EFATURADURUM = 0';   // Taslak
      1521: LFilter := LReady;                // Hazır (e-Fatura 1,11 | e-İrsaliye 51)
    else
      LFilter := '';                          // Tümü (filtresiz)
    end;
  end;

  FATBASLIK.Filter := LFilter;
  FATBASLIK.Filtered := LFilter <> '';

  // Yeni Giden: son 2 iş günü penceresi boşsa en son giden faturayı göster.
  if LGonderilmis and (LAltTag = 1531) and FATBASLIK.Active and
     (FATBASLIK.RecordCount = 0) then
    _YeniGidenSonFatura;

  _KayitSayisiGuncelle;
end;

// "Yeni Giden" penceresi (son 2 iş günü) boş kaldiginda en son gonderim
// tarihine sahip fatura(lar)i gosterir.
procedure TFaturalarDlg._YeniGidenSonFatura;
var
  LF: TField;
  LMax: TDateTime;
  LFound: Boolean;
  LBM: TBookmark;
begin
  // Tarih kisitini gecici olarak kaldir; yalnizca gonderilmisler (LSent) kalsin.
  FATBASLIK.OnFilterRecord := nil;
  FATBASLIK.Filtered := False;
  FATBASLIK.Filtered := True;
  if FATBASLIK.RecordCount = 0 then Exit;   // hic gonderilmis fatura yok

  LFound := False;
  LMax := 0;
  FATBASLIK.DisableControls;
  try
    LBM := FATBASLIK.Bookmark;
    try
      FATBASLIK.First;
      while not FATBASLIK.Eof do begin
        LF := FATBASLIK.FindField('FATURA_GON_TARIHI');
        if (LF <> nil) and (not LF.IsNull) then
          if (not LFound) or (LF.AsDateTime > LMax) then begin
            LMax := LF.AsDateTime;
            LFound := True;
          end;
        FATBASLIK.Next;
      end;
    finally
      if FATBASLIK.BookmarkValid(LBM) then
        FATBASLIK.Bookmark := LBM;
    end;
  finally
    FATBASLIK.EnableControls;
  end;

  if not LFound then Exit;   // gonderim tarihi dolu kayit yok

  // Pencereyi son gonderim anina daralt (+1 sn, ayni andaki son fatura(lar)).
  FYeniGidenBas := LMax;
  FYeniGidenBit := LMax + (1.0 / SecsPerDay);
  FATBASLIK.OnFilterRecord := FATBASLIKFilterYeniGiden;
  FATBASLIK.Filtered := False;
  FATBASLIK.Filtered := True;
end;

// "Yeni Giden" alt sekmesi: yalnizca son 2 is gununde gonderilmis faturalar.
//   FATURA_GON_TARIHI, [FYeniGidenBas, FYeniGidenBit) araliginda olmali.
procedure TFaturalarDlg.FATBASLIKFilterYeniGiden(DataSet: TDataSet; var Accept: Boolean);
var
  LGon: TField;
  LTrh: TDateTime;
begin
  LGon := DataSet.FindField('FATURA_GON_TARIHI');
  if (LGon = nil) or LGon.IsNull then begin
    Accept := False;
    Exit;
  end;
  LTrh := LGon.AsDateTime;
  Accept := (LTrh >= FYeniGidenBas) and (LTrh < FYeniGidenBit);
end;

// Gelen faturalar (TUR=11) ana/alt sekme secimine gore listeyi yukler.
//   Ana sekmeler:  Sistemde (Tumu)=0,-2,-12 | Gelen Kutusu | Tasnif Disi=-3,-13
//   Gelen Kutusu alt: Alindi=-1,-11 | Yanit Bekleyen | Hata/Red | Suresi Gecen
procedure TFaturalarDlg._GelenSekmeUygula;
var
  LAnaTag, LAltTag: Integer;
  LDurum, LEk, LWaiting: string;
  LGelenKutusu: Boolean;
begin
  if PageControlTur.ActivePage = nil then Exit;
  LAnaTag := PageControlTur.ActivePage.Tag;
  LGelenKutusu := (LAnaTag = 1202);

  // Alt seridi yalnizca "Gelen Kutusu" ana sekmesinde goster.
  PageControlAlt.Visible := LGelenKutusu;

  LWaiting := ' AND ((F.EFATURASONUC IS NULL) OR (F.EFATURASONUC=0) OR (F.EFATURASONUC=1)' +
    ' OR (F.EFATURASONUC=6) OR (F.EFATURASONUC=7) OR (F.EFATURASONUC=8) OR (F.EFATURASONUC=9))';

  LDurum := '-1,-11';
  LEk := '';
  if LGelenKutusu then begin
    LAltTag := 1211;
    if PageControlAlt.ActivePage <> nil then
      LAltTag := PageControlAlt.ActivePage.Tag;
    case LAltTag of
      1211: begin LDurum := '-1,-11'; LEk := ''; end;                      // Alindi
      1212: begin LDurum := '-1,-11'; LEk := LWaiting; end;                // Yanit Bekleyen
      1213: begin LDurum := '-1,-11'; LEk := ' AND F.EFATURASONUC=3'; end; // Hata/Red
      1214: begin LDurum := '-1,-11'; LEk := ' AND F.EFATURASONUC=5'; end; // Suresi Gecen
    else
      LDurum := '-1,-11'; LEk := '';
    end;
  end else begin
    case LAnaTag of
      1203: begin LDurum := '-3,-13'; LEk := ''; end;     // Tasnif Disi
    else
      LDurum := '0,-2,-12'; LEk := '';                    // Sistemde (Tumu) = 1201
    end;
  end;

  _GelenSQLYukle(LDurum, LEk);
end;

procedure TFaturalarDlg._GelenSQLYukle(const ADurumIn, AEkKosul: string);
const
  YeniGelenMarker = '/*YENIGELEN*/';
var
  LSQL, LFiltreEk: string;
  LTur: Integer;
  gf: TFaturaGorevFrame;
begin
  // Gelen fatura=11, gelen e-İrsaliye=10 (AltTur == TUR).
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  if gf.FAltTur = 10 then LTur := 10 else LTur := 11;
  LFiltreEk := '';
  if FArama <> nil then begin
    if Trim(FArama.AraKod.Text) <> '' then
      LFiltreEk := LFiltreEk + ' AND (R.KOD LIKE ''%' +
        StringReplace(Trim(FArama.AraKod.Text), '''', '''''', [rfReplaceAll]) +
        '%'' OR R.FIRMA LIKE ''%' +
        StringReplace(Trim(FArama.AraKod.Text), '''', '''''', [rfReplaceAll]) +
        '%'')';
    if Trim(FArama.AraBaslik.Text) <> '' then
      LFiltreEk := LFiltreEk + ' AND ISNULL(F.BASLIK,'''') LIKE ''%' +
        StringReplace(Trim(FArama.AraBaslik.Text), '''', '''''', [rfReplaceAll]) +
        '%''';
    if Trim(FArama.AraFaturaNo.Text) <> '' then
      LFiltreEk := LFiltreEk + ' AND ISNULL(F.FATURANO,'''') LIKE ''%' +
        StringReplace(Trim(FArama.AraFaturaNo.Text), '''', '''''', [rfReplaceAll]) +
        '%''';
    if Trim(FArama.AraAciklama.Text) <> '' then
      LFiltreEk := LFiltreEk + ' AND ISNULL(F.ACIKLAMA,'''') LIKE ''%' +
        StringReplace(Trim(FArama.AraAciklama.Text), '''', '''''', [rfReplaceAll]) +
        '%''';
  end;
  LSQL := YeniGelenMarker +
    ' SELECT F.*, R.KOD AS CARIKOD, R.FIRMA AS CARIAD, ' +
    '   N'''' AS YAZIYLATOPLAM ' +
    ' FROM FATBASLIK F (NOLOCK) ' +
    '   INNER JOIN REHBER R ON R.ID = F.REHBERID ' +
    ' WHERE F.TUR=' + IntToStr(LTur) + ' AND F.EFATURADURUM IN (' + ADurumIn + ')' + AEkKosul +
    LFiltreEk +
    ' ORDER BY F.FATURATARIH DESC';
  FATBASLIK.Close;
  FATBASLIK.SQL.Text := LSQL;
  if AktifVeriMotor = vmPG then FATBASLIK.SQL.Text := PgSqlCevir(FATBASLIK.SQL.Text);
  FATBASLIK.Open;
  FATBASLIK.Filter := '';
  FATBASLIK.Filtered := False;
  // Sol arama paneli aktif kalsin (sadece tarih araligi devre disi).
  if FArama <> nil then begin
    FArama.Enabled := True;
    FArama.CheckTarihAralik.Enabled := False;
    FArama.Calendar1.Enabled := False;
    FArama.Calendar2.Enabled := False;
    FArama.Panel1.Enabled := False;
  end;
  _KayitSayisiGuncelle;
end;

procedure TFaturalarDlg.MenuOlusturClick(Sender: TObject);
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  if TEBelgeOlusturucu.MenuHazirla(Tablo.FDCnn,
    FATBASLIK.FieldByName('ID').AsInteger) then
  begin
    LogEBelgeIslem(TabloNo, FATBASLIK.FieldByName('ID').AsInteger, 'Hazırla', FATBASLIK.FieldByName('REHBERID').AsInteger);
    TabloYenile(FATBASLIK, [], FATBASLIK.FieldByName('ID').AsInteger, 'ID');
  end;
end;

// Gelen faturanin durumunu hedef duruma tasir:
//   e-Fatura grubu (EFATURADURUM -1/-2/-3)   -> AYeniEfat
//   e-Arsiv grubu  (EFATURADURUM -11/-12/-13) -> AYeniEArsiv
// (Gelen Kutusu=-1/-11, Sistemde=-2/-12, Tasnif Disi=-3/-13)
procedure TFaturalarDlg._GelenDurumDegistir(AYeniEfat, AYeniEArsiv: Integer;
  ATutarSifirla: Boolean = False; ATutarUBLdenDoldur: Boolean = False);
var
  LID, LDurum, LYeni: Integer;
  LSet: string;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  LDurum := FATBASLIK.FieldByName('EFATURADURUM').AsInteger;
  if (LDurum = -1) or (LDurum = -2) or (LDurum = -3) then
    LYeni := AYeniEfat
  else if (LDurum = -11) or (LDurum = -12) or (LDurum = -13) then
    LYeni := AYeniEArsiv
  else begin
    ShowMessage('Bu islem yalnizca gelen (e-Fatura/e-Arsiv) faturalar icin yapilabilir.');
    Exit;
  end;
  if LDurum = LYeni then Exit;  // zaten hedef durumda
  LID := FATBASLIK.FieldByName('ID').AsInteger;
  LSet := 'EFATURADURUM=&D';
  // Kullanim disina alinan gelen belgenin tutarlari toplam/raporlara girmesin
  // diye sifirlanir.
  if ATutarSifirla then
    LSet := LSet +
      ', FATURA_MATRAHI=0, KDV_TUTARI=0, FATURA_TUTARI=0, DOVIZ_TUTARI=0';
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'UPDATE FATBASLIK SET ' + LSet + ' WHERE ID=&ID',
    ['&D', '&ID'], [LYeni, LID]);
  // Kullanim disindan (–3/–13) tekrar sisteme/gelen kutusuna alinirken,
  // kullanim disina alinirken sifirlanan tutarlari UBL'den geri doldur.
  if ATutarUBLdenDoldur and ((LDurum = -3) or (LDurum = -13)) then
    UEBelgeGelen.EBelgeGelenTutarlariUBLdenDoldur(Tablo.FDCnn, LID);
  // Kayit artik bu sekmenin durum filtresine uymadigindan listeyi yenile.
  PageControlTurChange(PageControlTur);
end;

procedure TFaturalarDlg.MenuSistemeTasiClick(Sender: TObject);
begin
  // Sisteme tasi: -1/-3 -> -2,  -11/-13 -> -12
  // Kullanim disindan geliniyorsa tutarlar UBL'den geri doldurulur.
  _GelenDurumDegistir(-2, -12, False, True);
end;

procedure TFaturalarDlg.MenuTasnifDisinaTasiClick(Sender: TObject);
begin
  // Kullanim disina tasi: -1/-2 -> -3,  -11/-12 -> -13
  // + tutar alanlari sifirlanir (kullanim disi belge toplamlara girmemeli).
  _GelenDurumDegistir(-3, -13, True);
end;

procedure TFaturalarDlg.MenuGelenKutusunaTasiClick(Sender: TObject);
begin
  // Gelen kutusuna tasi: -2/-3 -> -1,  -12/-13 -> -11
  // Kullanim disindan geliniyorsa tutarlar UBL'den geri doldurulur.
  _GelenDurumDegistir(-1, -11, False, True);
end;

procedure TFaturalarDlg.MenuOnizleClick(Sender: TObject);
var
  LID: Integer;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then
    Exit;
  LID := FATBASLIK.FieldByName('ID').AsInteger;
  if TEBelgeOlusturucu.MenuOnizle(Tablo.FDCnn, LID) then
  begin
    LogEBelgeIslem(TabloNo, LID, 'Önizle', FATBASLIK.FieldByName('REHBERID').AsInteger);
    TabloYenile(FATBASLIK, [], LID, 'ID');
  end;
end;

procedure TFaturalarDlg.MenuSifirlaClick(Sender: TObject);
var
  LID: Integer;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then
    Exit;
  LID := FATBASLIK.FieldByName('ID').AsInteger;
  if TEBelgeOlusturucu.MenuSifirla(Tablo.FDCnn, LID) then
  begin
    LogEBelgeIslem(TabloNo, LID, 'Hazırı Geri Al', FATBASLIK.FieldByName('REHBERID').AsInteger);
    TabloYenile(FATBASLIK, [], LID, 'ID');
  end;
end;

procedure TFaturalarDlg.MenuSeriDegistirClick(Sender: TObject);
var
  LID:  Integer;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then
    Exit;
  LID := FATBASLIK.FieldByName('ID').AsInteger;
  if TEBelgeOlusturucu.MenuSeriDegistir(Tablo.FDCnn, LID) then
  begin
    LogEBelgeIslem(TabloNo, LID, 'Seri Değiştir', FATBASLIK.FieldByName('REHBERID').AsInteger);
    TabloYenile(FATBASLIK, [], LID, 'ID');
  end;
end;

procedure TFaturalarDlg.MenuHTMLKaydetClick(Sender: TObject);
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  TEBelgeOlusturucu.MenuHTMLKaydet(Tablo.FDCnn,
    FATBASLIK.FieldByName('ID').AsInteger,
    FATBASLIK.FieldByName('CARIAD').AsString);
  LogEBelgeIslem(TabloNo, FATBASLIK.FieldByName('ID').AsInteger, 'HTML Kaydet', FATBASLIK.FieldByName('REHBERID').AsInteger);
end;


procedure TFaturalarDlg.MenuXMLKaydetClick(Sender: TObject);
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  TEBelgeOlusturucu.MenuXMLKaydet(Tablo.FDCnn,
    FATBASLIK.FieldByName('ID').AsInteger,
    FATBASLIK.FieldByName('CARIAD').AsString);
  LogEBelgeIslem(TabloNo, FATBASLIK.FieldByName('ID').AsInteger, 'XML Kaydet', FATBASLIK.FieldByName('REHBERID').AsInteger);
end;

procedure TFaturalarDlg.MenuPDFKaydetClick(Sender: TObject);
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  TEBelgeOlusturucu.MenuPDFKaydet(Tablo.FDCnn,
    FATBASLIK.FieldByName('ID').AsInteger,
    FATBASLIK.FieldByName('CARIAD').AsString);
  LogEBelgeIslem(TabloNo, FATBASLIK.FieldByName('ID').AsInteger, 'PDF Kaydet', FATBASLIK.FieldByName('REHBERID').AsInteger);
end;

procedure TFaturalarDlg.MenuGonderClick(Sender: TObject);
var
  LID: Integer;
begin
  if (not FATBASLIK.Active) or FATBASLIK.IsEmpty then Exit;
  LID := FATBASLIK.FieldByName('ID').AsInteger;
  if TEBelgeOlusturucu.MenuGonder(Tablo.FDCnn, LID) then
  begin
    LogEBelgeIslem(TabloNo, LID, 'Gönder', FATBASLIK.FieldByName('REHBERID').AsInteger);
    TabloYenile(FATBASLIK, [], LID, 'ID');
  end;

end;

procedure TFaturalarDlg.infoMenuClick(Sender: TObject);
var
  LTur, LTabNo: Integer;
begin
  LTur := FATBASLIK.FieldByName('TUR').AsInteger;
  if LTur in [ 9,19 ] then
  begin
    // SIPARIS baslik TabloID: satis(19)->92, alis(9)->91. USiparisWizard loglama ile ayni.
    if LTur = 19 then LTabNo := TabNo_SIPARIS_Giden else LTabNo := TabNo_SIPARIS_Gelen;
    Tablo.InfoGoster('SIPARIS',  FATBASLIK.FieldByName('ID').AsInteger,  LTabNo);
  end
  else
     Tablo.InfoGoster('FATBASLIK',  FATBASLIK.FieldByName('ID').AsInteger, TabloNo)
end;

procedure TFaturalarDlg.KaynakBelgeyiA1Click(Sender: TObject);
var
  sts:TStringlist;
  AYeri,AYerID,RehID:Integer;
  ABelgeno:string;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := '';
  Tablo.Query1.SQL.Add(' select distinct    ');
  Tablo.Query1.SQL.Add(' KAYNAKTUR = case   ');
  Tablo.Query1.SQL.Add(' 	when YERI =83 then 83   ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407) then 9   ');
  Tablo.Query1.SQL.Add(' 	when YERI = 408 then 10         ');
  Tablo.Query1.SQL.Add(' 	when YERI = 424 then 14         ');
  Tablo.Query1.SQL.Add(' 	when YERI = 425 then 6         ');
  Tablo.Query1.SQL.Add(' 	when YERI = 411 then 14         ');
  Tablo.Query1.SQL.Add(' 	when YERI = 427 then 10        ');
  Tablo.Query1.SQL.Add(' 	when YERI = 428 then 101        ');
  Tablo.Query1.SQL.Add(' 	when YERI = 461 then 109        ');
  Tablo.Query1.SQL.Add(' 	when YERI in (409,410,473) then 19  ');
  Tablo.Query1.SQL.Add(' 	when YERI = 462 then 119        ');
  Tablo.Query1.SQL.Add(' 	when YERI = 468 then 119        '); //kaynak : giden konsinye
  Tablo.Query1.SQL.Add(' 	when YERI = 429 then 19        ');
  Tablo.Query1.SQL.Add(' 	when YERI = 473 then 19        ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then -99 ');
  Tablo.Query1.SQL.Add(' end, ');
  Tablo.Query1.SQL.Add(' KAYNAKBELGENO=case ');
  Tablo.Query1.SQL.Add(' 	when YERI = 83 then (select SERVISNO from SERVIS where ID=(select SERVISID from SERVISDETAY where ID=F.YERID)) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407,409,410,428,429,473) then (select SIPARISNO from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID=F.YERID)) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (408,411,424,425,427,461,462,468) then (select FATURANO from FATBASLIK where ID=(select FATBASID from FATURA where ID=F.YERID))               ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then (select TEKLIFNO from TEKLIF where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))             ');
  Tablo.Query1.SQL.Add(' end, ');
  Tablo.Query1.SQL.Add(' KAYNAKID=case      ');
  Tablo.Query1.SQL.Add(' 	when YERI = 83 then (select SERVISID from SERVISDETAY where ID=F.YERID ) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407,409,410,428,429,473) then (select SIPARISID from SIPARISDETAY where ID=F.YERID ) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (408,411,424,425,427,461,462,468) then (select FATBASID from FATURA where ID=F.YERID )                ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then (SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID )           ');
  Tablo.Query1.SQL.Add(' end, ');


  Tablo.Query1.SQL.Add(' KAYNAKFIRMA=(select FIRMA from REHBER where ID=(case   ');
  Tablo.Query1.SQL.Add(' when YERI = 83 then (select REHBERID from SERVIS where ID=(select SERVISID from SERVISDETAY where ID=F.YERID))  ');
  Tablo.Query1.SQL.Add(' when YERI in (406,407,409,410,428,429,473) then (select REHBERID from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID=F.YERID))  ');
  Tablo.Query1.SQL.Add(' when YERI in (408,411,424,425,427,461,462,468) then (select REHBERID from FATBASLIK where ID=(select FATBASID from FATURA where ID=F.YERID)) ');
  Tablo.Query1.SQL.Add(' when YERI in (412,413) then (select REHBERID from TEKLIF where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))  ');
  Tablo.Query1.SQL.Add(' end ))  ');


  case FATBASLIK.FieldByName('TUR').AsInteger of
    9,19,101:begin
      Tablo.Query1.SQL.Add(' from SIPARISDETAY F ');
      Tablo.Query1.SQL.Add(' where SIPARISID='+FATBASLIK.FieldByName('ID').AsString+' and ');
      Tablo.Query1.SQL.Add(' 	YERI in (83,404,405,406,407,408,409,410,411,412,413,414,415,428,461,462,468,473) ');
    end;
  else
    Tablo.Query1.SQL.Add(' from FATURA F  ');
    Tablo.Query1.SQL.Add(' where FATBASID='+FATBASLIK.FieldByName('ID').AsString+' and ');
    Tablo.Query1.SQL.Add(' 	YERI in (83,404,405,406,407,408,409,410,411,412,413,414,415,424,425,427,429,461,462,468,473) ');
  end;
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.Open;
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
      if Tablo.ListedenBilgiGetir('Kaynak Seçimi',Tablo.Query1.SQL.Text,sts,[Tablo.RepKasaTurleri,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],'FaturalarKaynakSecimi')then begin
        AYeri := StrToInt(sts[0]);
        AYerID:= StrToInt(sts[2]);
        ABelgeno:= sts[1];
      end;
    finally
      sts.Free;
    end;
  end;
  if AYeri=83 then begin
    Tablo.TablodanSorguAc(2,'select REHBERID from SERVIS where ID='+IntToStr(AYerID));
    //RehID := Tablo.Query2.FieldByName('REHBERID').AsInteger;
    Tablo.ServisSihirbazBaslat(False, 'D',0 ,AYerID ,Tablo.Query2.FieldByName('REHBERID').AsInteger);
    Abort;
  end else
  if AYeri=-99 then begin
    Tablo.TablodanSorguAc(2,'select REHBERID from TEKLIF where ID='+IntToStr(AYerID));
    RehID := Tablo.Query2.FieldByName('REHBERID').AsInteger;
  end else
    RehID := FATBASLIK.FieldByName('REHBERID').AsInteger;
  AnaForm.GormeDialogCagir(AYerID,AYeri,RehID,0,Tablo.GENINI.BugunTrh,ABelgeno);
  //Tablo.SiparisSihirbazBaslat('D',FATBASLIK.FieldByName('TUR').AsInteger,0,FATBASLIK.FieldByName('ID').AsInteger,FATBASLIK.FieldByName('REHBERID').AsInteger);
end;

procedure TFaturalarDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TFaturalarDlg.Kopyala2Click(Sender: TObject);
var FaturaIDsi : integer;
begin
  if not (FATBASLIK.FieldByName('TUR').AsInteger in [9,19,101]) then begin //sipariş ise kontrole gerek yok
      Tablo.TablodanSorguAc(1,'select * from FATURA F where F.IZLEME <> 0 and F.FATBASID='+FATBASLIK.FieldByName('ID').AsString);
      if Tablo.Query1.RecordCount > 0 then begin
          Tablo.UyariGoster(Uyari,'Belge içeriğinde izlem bilgisi aktif ürünler var, bu işlem gerçekleştirilemez.');
          Exit;
      end;
  end;

  FaturaIDsi := Tablo.BelgeKopyala(FATBASLIK.FieldByName('ID').AsInteger, FATBASLIK.FieldByName('TUR').AsInteger,
                 FATBASLIK.FieldByName('REHBERID').AsInteger, FATBASLIK.FieldByName('FATURATARIH').AsDateTime);
  case FATBASLIK.FieldByName('TUR').AsInteger of
    13,17:begin
      Tablo.TahakkukSihirbaziBaslat('K',FATBASLIK.FieldByName('TUR').AsInteger,1, FaturaIDsi,FATBASLIK.FieldByName('REHBERID').AsInteger,-1);
    end;
    10,14,11,15,12,16:begin
      Tablo.FaturaSihirbazBaslat('K', FATBASLIK.FieldByName('TUR').AsInteger, 0, FaturaIDsi, FATBASLIK.FieldByName('REHBERID').AsInteger, 1,False,-1);
    end;
    9,19:begin
      Tablo.SiparisSihirbazBaslat('K', FATBASLIK.FieldByName('TUR').AsInteger, 0, FaturaIDsi, FATBASLIK.FieldByName('REHBERID').AsInteger, -1);
    end;

    101 : Tablo.SatinalmaSihirbazBaslat2('K', FATBASLIK.FieldByName('TUR').AsInteger,0, FaturaIDsi, -1);
  end;
   TarihDegisti;
end;

procedure TFaturalarDlg.MenuDurumuGuncelleClick(Sender: TObject);
var I, yeniid : integer;
    gf : TFaturaGorevFrame;
begin
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  if ((gf.FAltTur = 9)or(gf.FAltTur = 19))and(GridFatListeTview.Controller.SelectedRecordCount > 0) then begin
    yeniid := 0;
    for I := 0 to GridFatListeTview.Controller.SelectedRecordCount - 1 do begin
         yeniid := GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewID.Index];
         // API: siparis kapanma durumu (TM_SiparisDurumGuncelle yerine).
         //   Eski SP'de @KISMI hesabi sabit ID (10224) ile yapiliyordu, alis
         //   siparisi (TUR=9) hic islenmiyordu ve ADET=0 satirlar tamamlanmis
         //   sayiliyordu. Yenisi bunlari duzeltir ve 0/1/9 disindaki (iptal vb.)
         //   durumlara dokunmaz.
         Tablo.BelgeDurumHesapla(yeniid, 'siparis');
    end;
    JvTimer1Timer(Self);
  end;
end;




procedure TFaturalarDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TFaturalarDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TFaturalarDlg.SetArama(const Value: TFaturalarAramaFrame);
var
  k : word;
begin
  FArama := Value;
  // Kapsam butonlari (Tumu / Son Aranan / Sik Aranan): olay liste frame'inde baglanir,
  //   arama frame'i listeyi tanimaz. Butonlar "basili kalan" gruptur (Down + Allow).
  if FArama <> nil then
  begin
    FArama.LabelTumKayitlar.Style     := tbsCheck;
    FArama.LabelSonArananlar.Style    := tbsCheck;
    FArama.LabelSikArananlar.Style    := tbsCheck;
    FArama.LabelTumKayitlar.Grouped   := True;
    FArama.LabelSonArananlar.Grouped  := True;
    FArama.LabelSikArananlar.Grouped  := True;
    FArama.LabelTumKayitlar.OnClick   := AramaModuSec;
    FArama.LabelSonArananlar.OnClick  := AramaModuSec;
    FArama.LabelSikArananlar.OnClick  := AramaModuSec;
    FArama.LabelTumKayitlar.Down      := True;   // acilista TUM liste
  end;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;

procedure TFaturalarDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFaturalarDlg.SilTusClick(Sender: TObject);
var
  i,ResultID,TUR,Kilitli,Planli,TabNoID:integer;
  Tarih:TDateTime;
begin
    {dönüştürülmüş ise silinemez}
{   if FATBASLIK.FieldByName('DURUMNEREYE').AsString <> '' then begin
      ShowMessage(DonusturulmusSilinemez);
      Abort;
   end;   }


   {efat}
   if FATBASLIK.FieldByName('EFATURADURUM').AsInteger > 0 then begin  //  in [2, 52]
      ShowMessage(Islemgorenfaturadadegisiklikyapilmaz);
      Abort;
   end;

   Planli  :=0;
   Kilitli :=0;
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      if GridFatListeTview.Controller.SelectedRecordCount > 0 then begin
        for I := 0 to GridFatListeTview.Controller.SelectedRecordCount-1 do begin
          ResultID := GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewID.Index];
          TUR := GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewTUR.Index];
          Tarih := GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewFATURATARIH.Index];
          case TUR of
            9, 19, 101 : Tablo.SiparisSil(ResultID, TUR, FATBASLIK.FieldByName('FATURATARIH').AsDateTime);
          else
              if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+IntToStr(ResultID)+' ',[],[]) then
                Planli:=1
              else
                Tablo.KasaSilmeIslemleri(ResultID,TUR, FATBASLIK.FieldByName('FATURATARIH').AsDateTime);
               //Tablo.FaturaSil(FATBASLIK, FATURA,ResultID);    //IDye göre düzenlenecek
          end;
          // else begin
          //  Application.MessageBox(PChar(Hareketgormussilinemez+IntToStr(ResultID)),PChar(Uyari),MB_OK+MB_ICONWARNING);
          //end;
          if (Kilitli = 1) and (Planli=0) then
            Application.MessageBox(PChar(Kilitlibelgedeislemyapilmaz),PChar(Uyari),0)
          else if (Kilitli = 0) and (Planli=1) then
            Application.MessageBox(PChar(Planlibelgesilinmedi),PChar(Uyari),0)
          else if (Kilitli = 1) and (Planli=1) then
            Application.MessageBox(PChar(Kilitliveplanlibelgesilinemez),PChar(Uyari),0)
        end;
        TarihDegisti;
      end (*else  if GridFatListeTview.Controller.SelectedRecordCount = 1 then begin
        for I := 0 to GridFatListeTview.Controller.SelectedRecordCount-1 do begin
          ResultID := GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewID.Index];
          TUR := GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewTUR.Index];
          Tarih := GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewFATURATARIH.Index];
          if not(TUR in [9,19,101]) then begin
              begin
              if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+IntToStr(ResultID)+' ',[],[]) then begin
                if Application.MessageBox(PChar(faturaplanlisilinecekmi),PChar(Uyari),MB_YESNO)=mrYes then
                  //Tablo.FaturaSil(FATBASLIK, FATURA,ResultID)
                  Tablo.KasaSilmeIslemleri(ResultID,TUR)
                else Abort;
              end else begin
               Tablo.KasaSilmeIslemleri(ResultID,TUR);
              end;

               //Tablo.FaturaSil(FATBASLIK, FATURA,ResultID);    //IDye göre düzenlenecek
            end;
                //Silme işleminden önce faturayla ilişkili dokümanlar varsa silinsin.
            //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_FATBASLIK_DOKUMAN, ResultID]);
          end else if TUR in [9,19,101] then begin
            Tablo.SiparisSil(ResultID, TUR);
                //Silme işleminden önce faturayla ilişkili dokümanlar varsa silinsin.
           // Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_SIPARIS_DOKUMAN, ResultID]);
          end else begin
            Application.MessageBox(PChar(Hareketgormussilinemez + IntToStr(ResultID)),PChar(Uyari),MB_OK+MB_ICONWARNING);
          end;
        end;
      end;
      TarihDegisti;
   end;   09/01/2019 AO *)
end;
end;

procedure TFaturalarDlg.SmsEPostaTableViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Ad:String;
begin
{  If(Screen.Cursor = crHandPoint) and (SmsEPostaTableView.Controller.SelectedRecordCount > 0) then begin
    Tablo.TablodanSorguAc(2,'select * from IMAJ WHERE YERI= '+ TabSmsEPosta.FieldByName('YER').AsString+' AND YER_ID= '+TabSmsEPosta.FieldByName('ANAHTAR').AsString);
    Ad := Tablo.Query2.FieldByName('BELGEADI').AsString;
    if Tablo.Query2.FieldByName('ICDIS').AsString = 'True' then // eğer dosyada tutuluyorsa
      Tablo.TablodanSorguAc(5, ' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma ' + Tablo.Query2.FieldByName('ID').AsString + ' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI=''' + ExtractFileExt(Ad) + '''')
    else
      Tablo.TablodanSorguAc(5, 'select ID,ICDIS,BELGE,BELGEADI from IMAJ where ID=' + Tablo.Query2.Fields[0].AsString); // eğer doküman tabloda BELGE alanında ise
    KutuktenOku(Tablo.Query5, 'BELGE', ExtractFileExt(Ad), True);
  end else
     BelgeDuzenleTus.Click;   }
end;

procedure TFaturalarDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFaturalarDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFaturalarDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFaturalarDlg.YaziciYazdir(Sender: TObject);
begin

end;

function TFaturalarDlg.TipSecimi(Tur:integer):integer;
var
  Tip:Variant;
begin
  Result:=0;
  Tip := 99;
  if TGirisKutusuEx.BilgiAlEx(BGBelgeTipiSecimi,TGirdiDenetimleri.Create.ImageComboBox(BGBelgeTipi,@Tip,Tablo.FDCnn,'select TIP,ACIKLAMA from ISLEMTURLERI where TIP>0 and TUR='+IntToStr(Tur))) = mrOk then
    Result := StrToIntDef(VarToStrDef(Tip,'0'),0);
  if Result=0 then
    Abort;
end;

procedure TFaturalarDlg.YeniTusClick(Sender: TObject);
var ID,i,Tur : Integer;
HesapTuru :  Char;
 Tutar : Currency;
  gf : TFaturaGorevFrame;
begin
  gf := TFaturaGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  if Length(SQLEk)>18 then
    Tablo.FBtnIndex := -1;
  if gf.FAltTur in[3,4, 7, 8] then
    ID := Tablo.FaturaSihirbazBaslat('E',gf.FAltTur,1,0,-999,TipSecimi(4))
  else if gf.FAltTur in[9,19] then
    ID := Tablo.SiparisSihirbazBaslat('E', gf.FAltTur,Tablo.FBtnIndex, -1, -1)
  else if gf.FAltTur = 101 then
    ID := Tablo.SatinalmaSihirbazBaslat2('E', gf.FAltTur,Tablo.FBtnIndex, -1, -1)
  else if gf.FAltTur in[13,17] then
    ID := Tablo.TahakkukSihirbaziBaslat('E', gf.FAltTur,Tablo.FBtnIndex, -1, -1,Tablo.GENINI.BugunTrhSaat)
  else begin //110
    if Sender.ClassName='TMenuItem' then  //menüden seçilen fat tipine bakarız
       i := TMenuItem(Sender).Tag
    else
       i := 1;
    ID := Tablo.FaturaSihirbazBaslat('E',gf.FAltTur,Tablo.FBtnIndex,-1,-999,i);
  end;
  TarihDegisti;
end;


procedure TFaturalarDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
end;

procedure TFaturalarDlg.PopupYorumlarPopup(Sender: TObject);
begin
  DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString <> '';
  DokumanFormunuA1.Visible := DkmanGster1.Visible;
  DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TFaturalarDlg.ExceldenBelgeEkleClick(Sender: TObject);
var
  st: Tstringlist;
begin
  st := Tstringlist.Create;
  if Tablo.ListedenBilgiGetir('Veri Alma', ' select MODUL,ADI,ID from IMPORT  ', st,[]) then
  begin
    Application.CreateForm(TImportDlg, ImportDlg);
    ImportDlg.ImportId := StrToInt(st.Strings[2]);
    ImportDlg.ShowModal;
    ImportDlg.Destroy;
  end;
  st.Free;
end;

initialization
  Classes.RegisterClass(TFaturalarDlg);
end.










































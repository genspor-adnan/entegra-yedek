unit UStokListeDlg;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 07/12/2010 10:45:06 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons, DB, FireDAC.Comp.Client, ToolWin, ExtCtrls,UAnaForm,
  UStokAramaFrame, dxSkinsCore, cxStyles, cxCustomData, cxGraphics, cxGridPopupMenu,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxDropDownEdit, cxSplitter
  //, UGenDBNavigator
  , Grids, DBGrids, DBCtrls,
  cxProgressBar, Buttons, cxImageComboBox, cxCurrencyEdit, cxCheckBox, DateUtils,
  cxMemo, Utablo, frxClass, frxDBSet, cxImage, cxLabel, cxGridCustomPopupMenu,
  cxCalendar, cxPC, cxDBEdit, JvTimer, JvNavigationPane, dxBarBuiltInMenu,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxCore, cxDateUtils, frxExportPDF,
  cxRadioGroup, JvExControls, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView,
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
  FireDAC.Comp.DataSet
  ;

type
  TStokListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog)
    DtsStoklar: TDataSource;
    STOKLAR: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    GridStok: TcxGrid;
    GridStokView: TcxGridDBTableView;
    GridStokLevel1: TcxGridLevel;
    GridStokViewKOD: TcxGridDBColumn;
    GridStokViewSTOKADI: TcxGridDBColumn;
    GridStokViewGRUBU: TcxGridDBColumn;
    GridStokViewOZELLIK: TcxGridDBColumn;
    AraTus: TToolButton;
    cxSplitter1: TcxSplitter;
    GridStokViewDURUM: TcxGridDBColumn;
    STOKFIYAT: TFDQuery;
    DtsFiyat: TDataSource;
    GridStokViewTIPI: TcxGridDBColumn;
    GridStokViewMARKA: TcxGridDBColumn;
    GridStokViewMODEL: TcxGridDBColumn;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    tabStokDurum: TFDQuery;
    dtsStokDurum: TDataSource;
    pmStokDurum: TPopupMenu;
    KritikSeviyeMiktarnGiriniz1: TMenuItem;
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
    frxStokListe: TfrxDBDataset;
    PmStok: TPopupMenu;
    Kopyala1: TMenuItem;
    GridStokViewID: TcxGridDBColumn;
    GridStokViewSDKALAN: TcxGridDBColumn;
    SQLMemo: TcxMemo;
    TabStokHareketler: TFDQuery;
    DtsStokHareketler: TDataSource;
    Panel1: TPanel;
    PageControl1: TcxPageControl;
    tshFiyatlar: TcxTabSheet;
    GridFiyat: TcxGrid;
    GridFiyatView: TcxGridDBTableView;
    GridFiyatViewFIYATADI: TcxGridDBColumn;
    GridFiyatViewBIRIM: TcxGridDBColumn;
    GridFiyatViewFIYAT: TcxGridDBColumn;
    GridFiyatViewKUR: TcxGridDBColumn;
    GridFiyatViewKDVDURUM: TcxGridDBColumn;
    GridFiyatLevel1: TcxGridLevel;
    tshStokDurum: TcxTabSheet;
    Panel8: TPanel;
    tshHareketler: TcxTabSheet;
    GridHareket: TcxGrid;
    StokHareketler: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    DateHarBas: TcxDateEdit;
    ComboDepo: TcxImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    DateHarBit: TcxDateEdit;
    cxLabel3: TcxLabel;
    StokHareketlerOLAY: TcxGridDBColumn;
    StokHareketlerURUNID: TcxGridDBColumn;
    StokHareketlerFATBASID: TcxGridDBColumn;
    StokHareketlerTURAD: TcxGridDBColumn;
    StokHareketlerFATURATARIH: TcxGridDBColumn;
    StokHareketlerFATURASERI: TcxGridDBColumn;
    StokHareketlerFATURANO: TcxGridDBColumn;
    StokHareketlerREHBERID: TcxGridDBColumn;
    StokHareketlerDEPO: TcxGridDBColumn;
    StokHareketlerBIRIM: TcxGridDBColumn;
    StokHareketlerMIKTAR: TcxGridDBColumn;
    StokHareketlerTUTAR: TcxGridDBColumn;
    StokHareketlerKUR: TcxGridDBColumn;
    StokHareketlerFIRMA: TcxGridDBColumn;
    StokHareketlerGIREN: TcxGridDBColumn;
    StokHareketlerCIKAN: TcxGridDBColumn;
    StokHareketlerBIRIMFIYAT: TcxGridDBColumn;
    TabYorumMedya: TcxTabSheet;
    GridStokViewSTOKIZLEME: TcxGridDBColumn;
    StokHareketlerKOD: TcxGridDBColumn;
    GridStokViewSUBEID: TcxGridDBColumn;
    Panel2: TPanel;
    GridStokDurum: TcxGrid;
    GridStokDurumView: TcxGridDBTableView;
    clmDurumDepoAdi: TcxGridDBColumn;
    clmDurumGiren: TcxGridDBColumn;
    clmDurumCikan: TcxGridDBColumn;
    clmDurumKalan: TcxGridDBColumn;
    clmKritikSeviye: TcxGridDBColumn;
    GridStokDurumLevel1: TcxGridLevel;
    TabStokDurumDetay: TFDQuery;
    DtsStokDurumDetay: TDataSource;
    GridStokViewICERIK: TcxGridDBColumn;
    StokHareketlerKALAN: TcxGridDBColumn;
    GridStokDurumViewSUBEID: TcxGridDBColumn;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    BtnBarkodYazdir: TToolButton;
    CoKullanlanlarMenu: TMenuItem;
    CoKullanlanlarEkleMenu: TMenuItem;
    CoKullanlanlarSilMenu: TMenuItem;
    N5: TMenuItem;
    UretimIslemleriMenu: TMenuItem;
    YeniReceteOlusturMenu: TMenuItem;
    BaskaStoktanKopyalaMenu: TMenuItem;
    ReceteyiDuzenleMenu: TMenuItem;
    ReceteyiSilMenu: TMenuItem;
    JvTimer1: TJvTimer;
    N6: TMenuItem;
    CokKullanlanlarListeleMenu: TMenuItem;
    PanelFiyatAltSag: TPanel;
    ToolBar4: TToolBar;
    ResimYapistirTus: TToolButton;
    ResimDosyadanTus: TToolButton;
    ToolButton5: TToolButton;
    LogoResim: TcxDBImage;
    GridStokViewOZELKOD: TcxGridDBColumn;
    Barkodlemleri1: TMenuItem;
    SeilirnlereBarkodOlutur1: TMenuItem;
    BarkodsuzrnleriListele1: TMenuItem;
    GridStokViewKATEGORIAD: TcxGridDBColumn;
    GridStokDurumViewMaksimum: TcxGridDBColumn;
    GridStokDurumViewMinimum: TcxGridDBColumn;
    GridStokDurumViewKritik: TcxGridDBColumn;
    Servislemleri1: TMenuItem;
    EkipmanListesineEkle1: TMenuItem;
    GridStokViewMUHKODU: TcxGridDBColumn;
    GridStokViewBIRIM2: TcxGridDBColumn;
    GridStokViewBIRIM2MIKTAR: TcxGridDBColumn;
    GridStokViewMINSTOK: TcxGridDBColumn;
    GridStokViewNOTLAR: TcxGridDBColumn;
    GridStokViewRECETEVAR: TcxGridDBColumn;
    CokSatilanRestMenu: TMenuItem;
    ListeyeEkle1: TMenuItem;
    Listedenkar1: TMenuItem;
    N4: TMenuItem;
    okKullanlanlarListele1: TMenuItem;
    cxProgressBar1: TcxProgressBar;
    cbSifirKalanGoster: TcxCheckBox;
    cbSKTsizGrupla: TcxCheckBox;
    StokHareketlerADET: TcxGridDBColumn;
    N7: TMenuItem;
    BuUrununstokdurumunugncelle1: TMenuItem;
    Btnrnlerinstokdurumlarngncelle1: TMenuItem;
    DetayIzlemeMenu: TMenuItem;
    JvNavPanelHeader5: TJvNavPanelHeader;
    cxLabel4: TcxLabel;
    RadioFiyatSatis: TcxRadioButton;
    RadioFiyatAlis: TcxRadioButton;
    StokHareketlerBIRIMMALIYET: TcxGridDBColumn;
    StokHareketlerEKMALIYET: TcxGridDBColumn;
    PmStokHareket: TPopupMenu;
    BirUrunMaliyetGuncelleMenu: TMenuItem;
    cxLabel5: TcxLabel;
    ComboHareketTur: TcxImageComboBox;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
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
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    N8: TMenuItem;
    ExceldenVeriAlMenu: TMenuItem;
    TshEsDegerUrun: TcxTabSheet;
    ToolBar3: TToolBar;
    EUYeni: TToolButton;
    EuSil: TToolButton;
    StokEsdeger: TcxGrid;
    StokEsdegerTV: TcxGridDBTableView;
    StokEsdegerTVTUR: TcxGridDBColumn;
    StokEsdegerTVKOD: TcxGridDBColumn;
    StokEsdegerTVSTOKADI: TcxGridDBColumn;
    StokEsdegerTVACIKLAMA: TcxGridDBColumn;
    cxGridLevel6: TcxGridLevel;
    TabStokEsdeger: TFDQuery;
    DtsStokEsdeger: TDataSource;
    PopupMenuEsdeger: TPopupMenu;
    MenuTurDegis: TMenuItem;
    MenuAciklamaDegis: TMenuItem;
    ToolButton2: TToolButton;
    ButtonUTS: TToolButton;
    GridStokViewURUNNO: TcxGridDBColumn;
    GridStokViewBILDIRIM: TcxGridDBColumn;
    PageControl_SeriLot: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    TabSheetSeriLot: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGrid1DBTableViewDurum: TcxGridDBTableView;
    cxGrid1DBTableViewDurumTIP: TcxGridDBColumn;
    cxGrid1DBTableViewDurumADET: TcxGridDBColumn;
    cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn;
    cxGrid1Level2: TcxGridLevel;
    GridSeriLot: TcxGrid;
    GridSeriLotView: TcxGridDBTableView;
    cxGridLevel2: TcxGridLevel;
    TabSeriLotDurum: TFDQuery;
    DtsSeriLotDurum: TDataSource;
    GridSeriLotViewSTOKID: TcxGridDBColumn;
    GridSeriLotViewDEPOID: TcxGridDBColumn;
    GridSeriLotViewSERINO: TcxGridDBColumn;
    GridSeriLotViewLOTNO: TcxGridDBColumn;
    GridSeriLotViewSKT: TcxGridDBColumn;
    GridSeriLotViewKALAN: TcxGridDBColumn;
    ToolBar2: TToolBar;
    SeriLotDuzenle: TToolButton;
    N9: TMenuItem;
    HareketlerinzlemBilgileriniGosterMenu: TMenuItem;
    PageHareketSeriLot: TcxPageControl;
    cxTabSheet4: TcxTabSheet;
    GridSeriLotHareket: TcxGrid;
    GridSeriLotHareketView: TcxGridDBTableView;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    GridSeriLotHareketViewColumn1: TcxGridDBColumn;
    TabSeriLotHareket: TFDQuery;
    DtsSeriLotHareket: TDataSource;
    GridFiyatViewDEGISTIRMETARIHI: TcxGridDBColumn;
    GridSeriLotViewURT: TcxGridDBColumn;
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure AraStokAdiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckPasiflerClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure AramayiSifirla;
    procedure DegisTusClick(Sender: TObject);
    procedure AraTusClick(Sender: TObject);
    procedure STOKLARAfterOpen(DataSet: TDataSet);
    procedure STOKLARBeforeOpen(DataSet: TDataSet);
    procedure cbSifirKalanGosterClick(Sender: TObject);
    procedure AramaYap;
    Procedure AnalizSec;
    procedure SilTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure LogoResimClick(Sender: TObject);
    procedure tabStokDurumBeforeOpen(DataSet: TDataSet);
    procedure Kopyala1Click(Sender: TObject);
    procedure GridStokViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure AlanYnetimi2Click(Sender: TObject);
    procedure PmStilPopup(Sender: TObject);
    procedure StilDzenle1Click(Sender: TObject);
    procedure GridStokViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridFiyatViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridStokDurumViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure StokHareketlerCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure DateHarBasPropertiesEditValueChanged(Sender: TObject);
    procedure StokHareketlerCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure tabStokDurumAfterScroll(DataSet: TDataSet);
    procedure tabStokDurumAfterOpen(DataSet: TDataSet);
    procedure tabStokDurumBeforeClose(DataSet: TDataSet);
    procedure tabStokDurumAfterClose(DataSet: TDataSet);
    procedure RegKaydetVeAramaYap;
    procedure GridStokDurumViewDblClick(Sender: TObject);
    procedure BtnBarkodYazdirClick(Sender: TObject);
    procedure CoKullanlanlarEkleMenuClick(Sender: TObject);
    procedure CoKullanlanlarSilMenuClick(Sender: TObject);
    procedure YeniReceteOlusturMenuClick(Sender: TObject);
    procedure BaskaStoktanKopyalaMenuClick(Sender: TObject);
    procedure ReceteyiDuzenleMenuClick(Sender: TObject);
    procedure ReceteyiSilMenuClick(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure CokKullanlanlarListeleMenuClick(Sender: TObject);
    procedure ResimDosyadanTusClick(Sender: TObject);
    procedure ResimYapistirTusClick(Sender: TObject);
    procedure SeilirnlereBarkodOlutur1Click(Sender: TObject);
    procedure BarkodsuzrnleriListele1Click(Sender: TObject);
    procedure KritikSeviyeMiktarnGiriniz1Click(Sender: TObject);
    procedure pmStokDurumPopup(Sender: TObject);
    procedure PmStokPopup(Sender: TObject);
    procedure EkipmanListesineEkle1Click(Sender: TObject);
    procedure BuUrununstokdurumunugncelle1Click(Sender: TObject);
    procedure Btnrnlerinstokdurumlarngncelle1Click(Sender: TObject);
    procedure DetayIzlemeMenuClick(Sender: TObject);
    procedure BirUrunMaliyetGuncelleMenuClick(Sender: TObject);
    procedure GridStokViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure PageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure RadioFiyatSatisClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure ExceldenVeriAlMenuClick(Sender: TObject);
    procedure EUYeniClick(Sender: TObject);
    procedure EuSilClick(Sender: TObject);
    procedure MenuTurDegisClick(Sender: TObject);
    procedure MenuAciklamaDegisClick(Sender: TObject);
    procedure ButtonUTSClick(Sender: TObject);
    procedure SeriLotDuzenleClick(Sender: TObject);
    procedure HareketlerinzlemBilgileriniGosterMenuClick(Sender: TObject);
    procedure TabStokHareketlerAfterScroll(DataSet: TDataSet);
    procedure GridSeriLotViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama: TStokAramaFrame;
    CaptionList,FieldList : TArrayofstring;
    AlanlarOlusturuldu : Boolean;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function  GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function  GetFrameBilgi: TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue: TIcerikFrameBilgi);
    procedure StokListeDlgKapatEylemi(Sender: TObject);
    procedure SetArama(const Value: TStokAramaFrame);
    Procedure StokEkranAc(ID: Integer);
    procedure StokDurumGetir;
    procedure AnaFrameAktifOlacak(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl : string;
    procedure RecetePopupDuzenle;

  public
    { Public declarations }
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
  published
    property Arama: TStokAramaFrame read FArama write SetArama;
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, PrjConst,UGirisKutusuEx, UFastRap, URaporAraclari,
     UGenelAnaSekmeFrame, UResim, UOpsDlg, UBarkodYazdir, LocOnFly, UExceldenVeriAl, UUTSDlg;
{$R *.dfm}

var
  stokekranilkacilis: Boolean=True;
  ChangePage: Boolean=True;
  OkunanBarkod:String;
{ TStokListeDlg }

procedure TStokListeDlg.AraTusClick(Sender: TObject);
var
  Grup, durumu, s: String[100];
  Fir, Kod, TFirma, TKod: String[15];
begin
  AramaYap;
end;

procedure TStokListeDlg.CheckPasiflerClick(Sender: TObject);
begin
  GridStokViewDURUM.Visible := FArama.CheckPasifler.Checked;
  AraTus.Click;
end;

procedure TStokListeDlg.CokKullanlanlarListeleMenuClick(Sender: TObject);
begin
   STOKLAR.Close;
   STOKLAR.SQL.Text :='SELECT '+ SQLMemo.Text;
   STOKLAR.SQL.Add(' where S.KOD in (select G.ANAHTAR from GENINI G where G.BOLUM='+IntToStr(TMenuItem(Sender).Tag)+' and G.ANAHTAR = S.KOD and DIL=-1) ');
   if SubeVarmi then
    STOKLAR.SQL.Add(' and S.SUBEID in('+Tablo.YetkiliSubeleriGetir(27,YetkiTur_Gorme)+') ');
   STOKLAR.SQL.Add(' group by S.ID, S.KOD, S.STOKADI,K.AD, S.ICERIK, S.TIPI, S.MARKA, S.MODEL, S.GRUBU, S.OZELLIK, S.OZELKOD, S.MUHKODU, S.ANABIRIM, S.BIRIM2,'+
                   ' S.BIRIM2MIKTAR, S.MINSTOK, S.KDV, S.DURUM,S.HUCRE, S.IZLEME, S.BILDIRIM, S.NOTLAR, StokModel.ANAHTAR ,S.SUBEID, S.URUNNO ');
   TabloYenile(STOKLAR,[FArama.ComboPeriyot.EditValue]);
end;

procedure TStokListeDlg.CoKullanlanlarEkleMenuClick(Sender: TObject);
begin
   if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ANAHTAR from GENINI where BOLUM=&Bolum and ANAHTAR=&Anah and DIL=-1',['&Bolum', '&Anah'],
      [TMenuItem(Sender).Tag, STOKLAR.FieldByName('KOD').AsString]) then
       ShowMessage(DahaOnceEklenmis)
   else
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA) values(&BOLUM,&ANAHTAR,&DEGER,&DIL,&SIRA) ',
       ['&BOLUM','&ANAHTAR','&DEGER','&DIL','&SIRA'], [TMenuItem(Sender).Tag, STOKLAR.FieldByName('KOD').AsString, STOKLAR.FieldByName('ID').AsInteger,-1, 1]);
end;

procedure TStokListeDlg.CoKullanlanlarSilMenuClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(STOKLAR.FieldByName(STstok_adi).AsString+STListeden_cik), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from GENINI where BOLUM='+IntToStr(TMenuItem(Sender).Tag)+' and ANAHTAR = &Kod and DIL=-1 ', ['&Kod'], [STOKLAR.FieldByName('KOD').AsString]);
end;

procedure TStokListeDlg.AlanYnetimi2Click(Sender: TObject);
begin
(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).Controller.Customization:=True;
end;

procedure TStokListeDlg.AnaFrameAktifOlacak(Sender: TObject);
begin
  if (TAnaFrameBilgi(Sender).Baslik = SDStok) then begin
    GorunurOlacak;
    AramaYap;
  end;
end;

procedure TStokListeDlg.AnalizSec;
begin
  if FArama.ComboAnaliz.ItemIndex=1 then begin
    FArama.GbAnaliz.Visible:=True
  end else if FArama.ComboAnaliz.ItemIndex=0 then
    FArama.GbAnaliz.Visible:=False;
  //GridStokViewSIPARIS.Visible := FArama.GbAnaliz.Visible;
end;

procedure TStokListeDlg.RadioFiyatSatisClick(Sender: TObject);
var alwc:boolean;
begin
  alwc := True;
  PageControl1PageChanging(nil,tshFiyatlar,alwc);
end;

procedure TStokListeDlg.RecetePopupDuzenle;
var rc:integer;
begin
  case STOKLAR.FieldByName('RECETEVAR').AsInteger of
    0:begin
      YeniReceteOlusturMenu.Enabled := True;
      BaskaStoktanKopyalaMenu.Enabled := True;
      ReceteyiDuzenleMenu.Enabled := False;
      ReceteyiSilMenu.Enabled := False;
    end;
    1:begin
      YeniReceteOlusturMenu.Enabled := False;
      BaskaStoktanKopyalaMenu.Enabled := False;
      ReceteyiDuzenleMenu.Enabled := True;
      ReceteyiSilMenu.Enabled := True;
    end;
  end;
end;

procedure TStokListeDlg.ReceteyiDuzenleMenuClick(Sender: TObject);
begin
  Tablo.TablodanSorguAc(3,'select * from URETIMRECETE where STOKID='+STOKLAR.FieldByName('ID').AsString);
  case Tablo.Query3.RecordCount of
    0:ShowMessage(STRecete_bulunamadi);
    1:Tablo.ReceteSihirbazBaslat(Tablo.Query3.Fields[0].AsInteger,'D');
  else
    ShowMessage(STsil_tekrar_dene);
  end;
  RecetePopupDuzenle;
end;

procedure TStokListeDlg.ReceteyiSilMenuClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMRECETEDETAY where URETIMRECETEID in(select ID from URETIMRECETE where STOKID=&SID)',['&SID'],[STOKLAR.FieldByName('ID').AsString]);
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete  from URETIMRECETE where STOKID=&SID',['&SID'],[STOKLAR.FieldByName('ID').AsString]);
    RecetePopupDuzenle;
  end;
end;

procedure TStokListeDlg.RegKaydetVeAramaYap;
Begin
  GenRegIni.RegWriteString('StokOpsiyon', 'StokAraKayitSayisi', VarToStr(FArama.SpinKayitSayisi.EditValue), 'C');
  AramaYap;
End;

procedure TStokListeDlg.ResimDosyadanTusClick(Sender: TObject);
var
   i : SmallInt;
begin
   if Tablo.OpenPictureDialog1.Execute then begin
      for i := 0 to Tablo.OpenPictureDialog1.Files.Count-1 do
         ResimEkleme(Tablo.OpenPictureDialog1.Files[i], STOKLAR.FieldByName('ID').AsInteger, Tabno_Stoklar, STOKLAR.FieldByName('ID').AsInteger);
      //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
      TabloYenile(TabResim, [STOKLAR.FieldByName('ID').AsInteger]);
   end;
end;

procedure TStokListeDlg.ResimYapistirTusClick(Sender: TObject);
begin
   ResimYapistir(TcxImage(logoresim), STOKLAR.FieldByName('ID').AsInteger, Tabno_Stoklar, STOKLAR.FieldByName('ID').AsInteger);
   //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
  TabloYenile(TabResim, [STOKLAR.FieldByName('ID').AsInteger]);
end;

procedure TStokListeDlg.AramaYap;
Begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
End;

procedure TStokListeDlg.JvTimer1Timer(Sender: TObject);
 function KayitSayisiBelirle:string;
  begin
    if ( Trim(FArama.AraBarkod.Text) <>'' ) or
       ( Trim(FArama.EditKategori.Text)<>'') or
       ( Trim(FArama.ComboMARKA.EditText)<>'') or
       ( Trim(FArama.ComboMODEL.EditText)<>'') or
       ( Trim(FArama.ComboGRUBU.EditText)<>'') or
       ( Trim(FArama.ComboAnaliz.EditText)<>'') or
       ( Trim(FArama.ComboSUBE.EditText)<>'') then
       Result:= 'SELECT '
    else begin
      FArama.SpinKayitSayisi.EditValue := GenRegIni.RegReadString('StokOpsiyon','StokAraKayitSayisi','200','C');
      if not AlanlarOlusturuldu then
        Result:= 'SELECT TOP 1 '
      else
        Result:= 'SELECT TOP '+VarToStr(FArama.SpinKayitSayisi.EditValue)+' ';

    end;
  end;
var
  s,EkAlanlarSelect,EkAlanlarGroupBy : string;
  i:integer;
begin
  JvTimer1.Enabled := False;
  EkAlanlarSelect := '';
  EkAlanlarGroupBy := '';
  if Length(FieldList)>0 then begin
    for I := 0 to Length(FieldList)-1 do begin
      EkAlanlarSelect := EkAlanlarSelect+',['+CaptionList[i]+']='+FieldList[i];
      EkAlanlarGroupBy := EkAlanlarGroupBy+','+FieldList[i];
    end;
  end;
//  STOKLAR.SQL.Text := SQLMemo.Text;  EkAlanlarSelect
  STOKLAR.Close;
  STOKLAR.SQL.Text:= KayitSayisiBelirle+ ' '+StringReplace(SQLMemo.Text,'--EKALANLAR--',EkAlanlarSelect,[rfReplaceAll]);
  s:=' where 1=1 ';
//  if SubeVarmi then
//    s := s + ' and (S.SUBEID = 0 or S.SUBEID ='+inttostr(SubeId)+') ';
  if Trim(FArama.AraStokAdi.Text) <>'' then
    s := s+' and S.STOKADI like ''%'+Trim(FArama.AraStokAdi.Text) +'%'' ';
  if Trim(FArama.AraKod.Text) <>'' then
    s := s + ' and ( S.KOD like ''%'+Trim(FArama.AraKod.Text) +'%'' or  S.URUNNO like ''%'+Trim(FArama.AraKod.Text) +'%'') ';
  if FArama.EditKategori.Tag>0 then
    s := s + ' and S.KATEGORI = '+IntToStr(FArama.EditKategori.Tag);
  if FArama.ComboMarka.EditValue>0 then
    s := s + ' and S.MARKA = '+IntToStr(FArama.ComboMarka.EditValue);
  if FArama.ComboMODEL.EditValue>0 then
    s := s + ' and S.MODEL = '+IntToStr(FArama.ComboMODEL.EditValue);
  if FArama.ComboGrubu.EditValue > 0 then
    s := s + ' and S.GRUBU = '+IntToStr(FArama.ComboGRUBU.EditValue);
  if (FArama.ComboSUBE.EditValue<>null)and(FArama.ComboSUBE.EditValue < 1) then
    s := s + ' and S.SUBEID = '+IntToStr(FArama.ComboSUBE.EditValue);
  if FArama.AraBarkod.Text<>'' then begin
     OkunanBarkod := Trim(FArama.AraBarkod.Text);
     if (pos('01', OkunanBarkod)=1)and(pos('17', OkunanBarkod)=17) then //Karekod 01 ile baþlayýp 14 karakter stokkodu
         OkunanBarkod := copy(OkunanBarkod,3,14)
     else if (pos('(01)', OkunanBarkod)>0) then //Karekod ör : (10) BL005222511       (01) 8681489704423
         OkunanBarkod := Tablo.KarekodOku(1, OkunanBarkod)
     else
         OkunanBarkod :=  OkunanBarkod;  //yoksa kendisi


    if Uppercase(OkunanBarkod)='' then
      s := s + ' and StokBarkod.BARKOD is NULL'
    else if Uppercase(OkunanBarkod)='NULL' then
      s := s + ' and StokBarkod.BARKOD is NULL'
    else if Uppercase(OkunanBarkod)='NOT NULL' then
      s := s + ' and StokBarkod.BARKOD is NOT NULL'
    else
      s := s + ' and StokBarkod.BARKOD like '''+OkunanBarkod+'%''';
  end;

  if not FArama.CheckPasifler.Checked then
    s := s + ' and S.DURUM=1 ';
  if SubeVarmi then begin
    s := s + ' and S.SUBEID in(0,'+Tablo.YetkiliSubeleriGetir(27,YetkiTur_Gorme)+') ';
    //s := s + ' and D.SUBEID = '+IntToStr(SubeId)+' ';
  end;

  if FArama.ComboAnaliz.Text<>'' then  begin
    if (FArama.DateBas.Text <> '') and (FArama.DateBitis.Text <> '') then
      s := stringreplace(s,' where F.TUR=1',' where F.TUR=1 and (FB.FATURATARIH between '''+FormatDateTime('yyyy-mm-dd', FArama.DateBas.Date)+''' and '''+FormatDateTime('yyyy-mm-dd', FArama.DateBitis.Date)+''' )',[rfReplaceAll]);
      //s := s + ' and (FB.FATURATARIH between '''+FormatDateTime('yyyy-mm-dd', FArama.DateBas.Date)+''' and '''+FormatDateTime('yyyy-mm-dd', FArama.DateBitis.Date)+''' )';
  end;
  STOKLAR.SQL.Add(s);
  STOKLAR.SQL.Add(' group by S.ID, S.KOD, S.STOKADI,K.AD, S.ICERIK, S.TIPI, S.MARKA, S.MODEL, S.GRUBU, S.OZELLIK,'+
     'S.OZELKOD, S.MUHKODU, S.ANABIRIM, S.BIRIM2, S.BIRIM2MIKTAR, S.MINSTOK, S.KDV, S.DURUM,S.HUCRE, S.IZLEME,S.BILDIRIM,');
  STOKLAR.SQL.Add('   S.NOTLAR,  StokModel.ANAHTAR,S.SUBEID, S.URUNNO,S.MINSTOK ');
  STOKLAR.SQL.Add(EkAlanlarGroupBy);
  if FArama.ComboAnaliz.Text <> '' then  begin
    if FArama.AraAdet.Text <> '' then
     STOKLAR.SQL.Add('HAVING ISNULL( SUM( SD.CIKAN ),0) >= '''+FArama.AraAdet.Text+''' ');
  end;
//   TabloYenile(STOKLAR,[FArama.ComboPeriyot.EditValue]);
   TabloYenile(STOKLAR,[VarsDepo]);
  if not AlanlarOlusturuldu then begin
    GridStokView.DataController.CreateAllItems(True);
    //GridStokView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\StokListeGridi',true,false,[gsoUseFilter],'StokListeGridi');
    Tablo.GridAyarRestore('StokListeGridi', GridStokView);
    AlanlarOlusturuldu := True;
  end;

//  STOKLAR.Params[0].Value:=FArama.ComboPeriyot.EditValue;
//  STOKLAR.Open;

  //GridStokView.ViewData.Expand(True);

{--SIPARISTOP=(select case When (SUM( CASE WHEN FB.TUR IN (14,15,16) THEN MIKTAR ELSE 0 END )-
--ISNULL( (select SUM(ISNULL(KALAN,0)) FROM STOKDURUM WHERE STOKID = S.ID),0)) > 0 then
--((SUM( CASE WHEN FB.TUR IN (14,15,16) THEN MIKTAR ELSE 0 END )-
--ISNULL( (select SUM(ISNULL(KALAN,0)) FROM STOKDURUM WHERE STOKID = S.ID),0))/:Periyot) else 0 END
--from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID where F.TUR=1
--and F.URUNID=S.ID and FB.TUR IN (14,15,16))
}
end;

procedure TStokListeDlg.AramayiSifirla;
begin
  FArama.AraStokAdi.EditValue := '';
  FArama.AraKod.EditValue := '';
  FArama.AraBarkod.EditValue := '';
  OkunanBarkod:='';
  FArama.EditKategori.Tag := 0;
  FArama.ComboMODEL.EditValue := -1;
  FArama.ComboMarka.EditValue := -1;
  FArama.ComboGRUBU.EditValue := -1;
  FArama.ComboSUBE.EditValue := 1;
  FArama.AraStokAdi.PostEditValue;
  FArama.AraKod.PostEditValue;
  FArama.AraBarkod.PostEditValue;
  FArama.ComboMODEL.PostEditValue;
  FArama.ComboMarka.PostEditValue;
  FArama.ComboGRUBU.PostEditValue;
  FArama.ComboSUBE.PostEditValue;
  TabloYenile(STOKLAR,[FArama.ComboPeriyot.EditValue]);
end;

procedure TStokListeDlg.EkipmanListesineEkle1Click(Sender: TObject);
var
  Ad,Kod,UrunID,EkipmanID:string;
  I: Integer;
begin
  if GridStokView.DataController.Controller.SelectedRecordCount > 0 then
  begin
    for I := 0 to GridStokView.DataController.Controller.SelectedRecordCount-1 do
    begin
      Ad := GridStokView.DataController.Controller.SelectedRecords[I].Values[GridStokViewSTOKADI.Index];
      Kod := GridStokView.DataController.Controller.SelectedRecords[I].Values[GridStokViewKOD.Index];
      UrunID := GridStokView.DataController.Controller.SelectedRecords[I].Values[GridStokViewID.Index];

      EkipmanID := Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'INSERT INTO EKIPMANLAR (URUNID, EKIPMANTUR,'+
      ' KOD, AD, EKLEYEN, EKLEMETARIHI, SUBEID, DURUM, UYGULAMASURESI) VALUES(&URUNID,&EKIPMANTUR,&KOD,&AD,&EKLEYEN,&EKLEMETARIHI,&SUBEID,&DURUM,&UYGULAMASURESI); SELECT SCOPE_IDENTITY()',
      ['&URUNID','&EKIPMANTUR','&KOD','&AD','&EKLEYEN','&EKLEMETARIHI','&SUBEID','&DURUM','&UYGULAMASURESI'],[UrunID,0,
      Kod, Ad, Kullanan, FormatDateTime('yyyy-MM-dd hh:nn',Tablo.GENINI.BugunTrhSaat), SubeId, 1, 0],True);

      Tablo.TablodanSorguAc(9,'select ID from IMAJ where YERI='+IntToStr(Tabno_Stoklar)+' and YER_ID='+UrunID);//stoktaki resimler geliyor..
      Tablo.Query9.First;
      while not Tablo.Query9.Eof do begin
        Tablo.SQLSatiriKopyala('IMAJ',Tablo.Query9.FieldByName('ID').AsInteger,['REHBERID','YERI','YER_ID'],[0,TabNo_EKIPMAN,EkipmanID]);
        Tablo.Query9.Next;
      end;
    end;
  end;
end;

function TStokListeDlg.EkranAdiAl: string;
begin
  Result := 'StokListeDlg';
end;

procedure TStokListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi, Ekranadi : String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Ekranadi := EkranAdiAl;
  Delete(DokumAdi, pos('&',DokumAdi), 1);

  TabloYenile(STOKFIYAT, [STOKLAR.FieldByName('ID').AsInteger]);
  TabloYenile(TabResim, [STOKLAR.FieldByName('ID').AsInteger]);
  StokDurumGetir;
  DateHarBasPropertiesEditValueChanged(Self);
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxStokListe) then begin
    AFastReport.EnabledDataSets.Clear;
    AFastReport.EnabledDataSets.Add(frxStokListe);
  end else begin
    frxStokListe.Dataset := STOKLAR;
    AFastReport.EnabledDataSets.Clear;
    AFastReport.EnabledDataSets.Add(frxStokListe);
  end;
end;

procedure TStokListeDlg.BarkodsuzrnleriListele1Click(Sender: TObject);
begin
  FArama.AraBarkod.EditValue := 'NULL';
  FArama.AraBarkod.PostEditValue;
  AramaYap;
end;

procedure TStokListeDlg.BaskaStoktanKopyalaMenuClick(Sender: TObject);
var
  str:TStringList;
  YeniID:Integer;
begin
  str:=TStringList.Create;
  try
    if Tablo.ListedenBilgiGetir('Reçetesini Kopyalayacaðýnýz Stoku Seçiniz.','select R.ID,R.STOKID,S.KOD,S.STOKADI from STOKLAR S inner join URETIMRECETE R on S.ID=R.STOKID',str,[],'') then begin
      Tablo.TablodanSorguAc(3,'select * from URETIMRECETE where ID='+str[0]);
      Tablo.TablodanSorguAc(4,'select * from URETIMRECETEDETAY where URETIMRECETEID='+str[0]);
      Tablo.TablodanSorguAc(5,'insert into URETIMRECETE(KOD,AD,STOKID)values('''+STOKLAR.FieldByName('KOD').AsString+''','''+STOKLAR.FieldByName('STOKADI').AsString+''','+STOKLAR.FieldByName('ID').AsString+') select scope_identity()');
      Tablo.Query4.First;
      while not Tablo.Query4.Eof do begin
        if (Tablo.Query4.FieldByName('TUR').AsInteger=1)and(Tablo.Query4.FieldByName('URUNID').AsInteger=Tablo.Query3.FieldByName('STOKID').AsInteger) then begin
          YeniID := Tablo.SatirKopyala('URETIMRECETEDETAY',Tablo.Query4.FieldByName('ID').AsInteger);
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update URETIMRECETEDETAY set URETIMRECETEID=&URID, URUNID=&UrunID, BIRIM=&Brm where ID=&URDID',['&URID','&UrunID','&Brm','&URDID'],[Tablo.Query5.Fields[0].AsInteger,STOKLAR.FieldByName('ID').AsInteger,STOKLAR.FieldByName('ANABIRIM').AsInteger,YeniID]);

        end else begin
          YeniID := Tablo.SatirKopyala('URETIMRECETEDETAY',Tablo.Query4.FieldByName('ID').AsInteger);
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update URETIMRECETEDETAY set URETIMRECETEID=&URID where ID=&URDID',['&URID','&URDID'],[Tablo.Query5.Fields[0].AsInteger,YeniID]);
        end;
        Tablo.Query4.Next;
      end;
    end;
  finally
    FreeAndNil(str);
  end;
  RecetePopupDuzenle;
  Tablo.ReceteSihirbazBaslat(Tablo.Query5.Fields[0].AsInteger,'D');

end;

procedure TStokListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdi, DokumAdi);
end;


procedure TStokListeDlg.Baslatildi;
var
  ra : string;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  AlanlarOlusturuldu := False;
  Tablo.EkAlanlariBul('','StokWizardDlg','STOKLAR',CaptionList,FieldList);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;
  cbSifirKalanGoster.Checked := StrToBool(GenRegIni.RegReadString('', 'StokDurumSifirStokGoster', 'True', 'C'));
  Tablo.GridAyarRestore('StokFiyatGridi',GridFiyatView );
  Tablo.GridAyarRestore('StokDurumGridi',GridStokDurumView );
  Tablo.GridAyarRestore('StokHareketlerGridi',StokHareketler );
  Tablo.GridAyarRestore('GridSeriLotGridi',GridSeriLotView );

  Tablo.GridTurkcelestir;

  ButtonUTS.Visible := UTSKullanimda;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  //PageControl1.ActivePageIndex := 0;
  case Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_HareketBasla,1) of
    0: DateHarBas.Date:=Tablo.GENINI.BugunTrh;
    1: DateHarBas.Date:= StartOfTheMonth(Tablo.GENINI.BugunTrh);
    2: DateHarBas.Date:= StartOfTheYear(Tablo.GENINI.BugunTrh);
  end;
  DateHarBit.Date:=Tablo.GENINI.BugunTrh;
  ComboDepo.Properties.Items := Tablo.RepStokDepolarAktif.Properties.Items;
  with ComboDepo.Properties.Items.Add do begin
    Description := 'Tümü';
    Value := 0;
  end;
  ComboDepo.EditValue := VarsDepo;
  ComboDepo.PostEditValue;
  DateHarBas.Properties.OnEditValueChanged := DateHarBasPropertiesEditValueChanged;
  DateHarBit.Properties.OnEditValueChanged := DateHarBasPropertiesEditValueChanged;
  ComboDepo.Properties.OnEditValueChanged := DateHarBasPropertiesEditValueChanged;

  if Sektor = Sektor_Fayans then begin
    GridStokViewICERIK.Caption := 'Seri';
    GridStokViewOZELKOD.Caption := 'Ölçü';
  end;

end;

procedure TStokListeDlg.BirUrunMaliyetGuncelleMenuClick(Sender: TObject);
var
   Tarih : Variant;
//   Trh:String;
begin
   Tarih := DateHarBas.Date;
   if (ComboDepo.EditValue<>null)and(ComboDepo.EditValue>0)and
       (TGirisKutusuEx.BilgiAlEx(ComboDepo.Text+' deposu için baþlama tarihini girin' ,
        TGirdiDenetimleri.Create.DateTimePicker(BGBaslama_tarih+':', @Tarih,dtkDate))= mrOk)  then begin
//        Trh := StringReplace( VarToStr(Tarih),'.', FormatSettings.DateSeparator,[rfReplaceAll]);
//        Trh := StringReplace( VarToStr(Trh),'/', FormatSettings.DateSeparator,[rfReplaceAll]);
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'P_StokMaliyetGuncelleORT '+STOKLAR.FieldByName('ID').AsString+','+IntToStr(ComboDepo.EditValue)+','''+FormatDateTime('yyyy-dd-mm 00:00', TDateTime(Tarih))+''' ',[],[]);
        ShowMessage(Guncellendi);
        DateHarBasPropertiesEditValueChanged(Self);
   end;
end;

procedure TStokListeDlg.BtnBarkodYazdirClick(Sender: TObject);
var
  bydlg:TBarkodYazdirDlg;
begin
  Application.CreateForm(TBarkodYazdirDlg,bydlg);
  bydlg.StokID := STOKLAR.FieldByName('ID').AsInteger;
  bydlg.IslemOp := 'Y';
  bydlg.ShowModal;

  FreeAndNil(bydlg);
end;

procedure TStokListeDlg.BtnMesajGonderClick(Sender: TObject);
var ID : Integer;
begin
   ID := Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  Tabno_STOKLAR, STOKLAR.FieldByName('ID').AsInteger, 0,TabYorum);
   //eðer dosya eklendiyse konusuna stok kod ve adýný yazalým
   TabYorum.Last;
   if (ID>0)and(TabYorum.FieldByName('DOKUMANID').AsString<>'') then
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update DOKUMAN set KONU='''+STOKLAR.FieldByName('KOD').AsString+' / '+STOKLAR.FieldByName('STOKADI').AsString+''' where ID='+TabYorum.FieldByName('DOKUMANID').AsString,[],[]);
end;

procedure TStokListeDlg.Btnrnlerinstokdurumlarngncelle1Click(Sender: TObject);
begin
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'truncate table STOKDURUM ',[],[]);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'EXEC SP_Prg_GenelStokDuruMGuncelle 0,'''+FormatDateTime('yyyy-01-01 00:00',Tablo.GenIni.BugunTrh)+''','''+FormatDateTime('yyyy-12-31 23:59',Tablo.GenIni.BugunTrh)+''' ',[],[]);
   Application.ProcessMessages;
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'EXEC SP_Prg_GenelStokIzlemDuruMGuncelle 0,'''+FormatDateTime('yyyy-01-01 00:00',Tablo.GenIni.BugunTrh)+''','''+FormatDateTime('yyyy-12-31 23:59',Tablo.GenIni.BugunTrh)+''' ',[],[]);
   Application.ProcessMessages;
   StokDurumGetir;
   ShowMessage(Guncellendi);
end;

procedure TStokListeDlg.ButtonUTSClick(Sender: TObject);
begin
  Application.CreateForm(TUTSDlg, UTSDlg);
  UTSDlg.showModal;
  UTSDlg.Destroy;
end;

procedure TStokListeDlg.BuUrununstokdurumunugncelle1Click(Sender: TObject);
begin
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Delete from STOKDURUM Where STOKID='+STOKLAR.FieldByName('ID').AsString,[],[]);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'EXEC SP_Prg_GenelStokDuruMGuncelle '+STOKLAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-01-01 00:00',Tablo.GenIni.BugunTrh)+''','''+FormatDateTime('yyyy-12-31 23:59',Tablo.GenIni.BugunTrh)+''' ',[],[]);
   StokDurumGetir;
   ShowMessage(Guncellendi);
end;

procedure TStokListeDlg.cbSifirKalanGosterClick(Sender: TObject);
begin
  GenRegIni.RegWriteString('',  'StokDurumSifirStokGoster', BoolToStr(cbSifirKalanGoster.Checked), 'C');
  StokDurumGetir;
end;

procedure TStokListeDlg.DateHarBasPropertiesEditValueChanged(Sender: TObject);
begin   //StokMaliyetHesapYontemi 0:yok, 1:ort, 2:fifo
   if (DateHarBas.Text<>'00'+FormatSettings.DateSeparator+'00'+FormatSettings.DateSeparator+'0000')and
      (DateHarBit.Text<>'00'+FormatSettings.DateSeparator+'00'+FormatSettings.DateSeparator+'0000')and
      ((ComboDepo.EditValue<>null))and(ComboDepo.EditValue>=0) then begin

       if SQLVersion2008 then begin
         // StokHareketlerBIRIMMALIYET.DataBinding.FieldName := 'MALIYET';
          if StokMaliyetHesapYontemi=0 then begin     //maliyet yok
            TabStokHareketler.SQL.Text :='SELECT X.*,BIRIMMALIYET=0.0 FROM [dbo].[fn_PRG_StokHareket]( :PBasTar,:PBitTar,:PDepo,:PUrunID) X ';
            TabloYenile(TabStokHareketler,[FormatDateTime('yyyy-MM-dd hh:nn',DateHarBas.Date),FormatDateTime('yyyy-MM-dd 23:59:59',DateHarBit.Date),StrToIntDef(ComboDepo.EditValue,0),STOKLAR.Fields[0].AsInteger]);
          end else if StokMaliyetHesapYontemi=1 then begin   //ort maliyet
            TabStokHareketler.SQL.Text :='SELECT X.*,SO.BIRIMMALIYET FROM [dbo].[fn_PRG_StokHareket]( :PBasTar,:PBitTar,:PDepo,:PUrunID) X ';
            TabStokHareketler.SQL.Add(' left outer join STOK_ORT_MALIYET SO on X.DEPO=SO.DEPOID and X.URUNID=SO.STOKID and X.FATBASID=SO.FATBASID and X.FATURAID=SO.FATURAID ');
            TabloYenile(TabStokHareketler,[FormatDateTime('yyyy-MM-dd hh:nn',DateHarBas.Date),FormatDateTime('yyyy-MM-dd 23:59:59',DateHarBit.Date),StrToIntDef(ComboDepo.EditValue,0),STOKLAR.Fields[0].AsInteger]);
          end else if StokMaliyetHesapYontemi=2 then begin //fifo
            TabStokHareketler.SQL.Text :='SELECT X.*,BIRIMMALIYET=(SMC.GIRISTUTAR/SMC.MIKTAR) FROM [dbo].[fn_PRG_StokHareket]( :PBasTar,:PBitTar,:PDepo,:PUrunID) X ';
            TabStokHareketler.SQL.Add(' STOKMALIYET SMC on SMC.TUR=1 and X.URUNID=SMC.STOKID and X.FATURAID=SMC.CIKISSATIRID ');
            TabloYenile(TabStokHareketler,[FormatDateTime('yyyy-MM-dd hh:nn',DateHarBas.Date),FormatDateTime('yyyy-MM-dd 23:59:59',DateHarBit.Date),StrToIntDef(ComboDepo.EditValue,0),STOKLAR.Fields[0].AsInteger]);
          end;

       end else begin
         // StokHareketlerBIRIMMALIYET.DataBinding.FieldName := 'BIRIMMALIYET';
          if StokMaliyetHesapYontemi=0 then begin     //maliyet yok
            TabStokHareketler.SQL.Text :='exec sp_Stok_UrunHareketleri2012 '+
            ''''+FormatDateTime('yyyy-mm-dd 00:00:00',DateHarBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59:59',DateHarBit.Date)+''','+IntToStr(ComboDepo.EditValue)+','+STOKLAR.Fields[0].AsString;
            TabloYenile(TabStokHareketler,[]);
          end else if StokMaliyetHesapYontemi=1 then begin   //ort maliyet
            if ComboHareketTur.EditValue=1 then
               TabStokHareketler.SQL.Text :='exec sp_StokHareket_OrtMaliyet2012 '+
                ''''+FormatDateTime('yyyy-mm-dd 00:00:00',DateHarBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59:59',DateHarBit.Date)+''','+IntToStr(ComboDepo.EditValue)+','+STOKLAR.Fields[0].AsString
            else
               TabStokHareketler.SQL.Text :='select * from fn_StokHareket_OrtMaliyet2012 ('+
               ''''+FormatDateTime('yyyy-mm-dd 00:00:00',DateHarBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59:59',DateHarBit.Date)+''','+IntToStr(ComboDepo.EditValue)+','+STOKLAR.Fields[0].AsString+')';
            TabloYenile(TabStokHareketler,[]);
          end else if StokMaliyetHesapYontemi=2 then begin //fifo
            TabStokHareketler.SQL.Text :='exec sp_StokHareket_FIFO2012 '+
            ''''+FormatDateTime('yyyy-mm-dd 00:00:00',DateHarBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59:59',DateHarBit.Date)+''','+IntToStr(ComboDepo.EditValue)+','+STOKLAR.Fields[0].AsString;
            TabloYenile(TabStokHareketler,[]);
          end;

       end;
       //StokHareketlerKALAN.Visible := ComboDepo.EditValue<>0;
       StokHareketlerBIRIMMALIYET.Visible := ComboHareketTur.EditValue=2;// ComboDepo.EditValue<>0;
       StokHareketlerEKMALIYET.Visible := StokHareketlerBIRIMMALIYET.Visible;
      end;
end;

procedure TStokListeDlg.DegisTusClick(Sender: TObject);
var
//srid:
   ID : integer;
begin
  if Tablo.YetkiVarmi(2701,YetkiTur_Degistirme) then begin
    if GridStokView.Controller.SelectedRecordCount > 0 then
    begin
      //srid:=GridStokView.DataController.FocusedRecordIndex;
      ID := STOKLAR.Fields[0].AsInteger;
      if Tablo.StokSihirbazBaslat('D', 0, STOKLAR.Fields[0].AsInteger,-1,0) > 0 then begin
         //AraTusClick(nil);
         JvTimer1Timer(Self);
         STOKLAR.Locate('ID', ID, []);
      end;
    end;
  end;
end;

procedure TStokListeDlg.DetayIzlemeMenuClick(Sender: TObject);
begin
  AnaForm.StokIzlemeDetayiGoster(STOKLAR.FieldByName('IZLEME').AsInteger,STOKLAR.FieldByName('ID').AsInteger,tabStokDurum.FieldByName('DEPOID').AsInteger);
end;

procedure TStokListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TStokListeDlg.DkmanSil1Click(Sender: TObject);
begin
    if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
        Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
        Tabloyenile(TabYorum,[Tabno_STOKLAR, STOKLAR.FieldByName('ID').AsInteger]);
      end;
end;

procedure TStokListeDlg.DokumanFormunuA1Click(Sender: TObject);

begin
   Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
           TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, 0);
end;

procedure TStokListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TStokListeDlg.EuSilClick(Sender: TObject);
begin
  //TabStokEsdeger.Delete;
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Delete from STOKESDEGER Where STOKESDEGERID='+TabStokEsdeger.FieldByName('STOKESDEGERID').AsString+' ',[],[]);
  TabloYenile(TabStokEsdeger,[STOKLAR.FieldByName('ID').AsString]);
end;

procedure TStokListeDlg.EUYeniClick(Sender: TObject);
var st : Tstringlist;
  sql,Tipi:string;
begin
  Tablo.TablodanSorguAc(2,'Select * from STOKLAR Where ID='+STOKLAR.FieldByName('ID').AsString+' ');
  sql:=' SELECT S.ID,S.KOD as Kod,S.STOKADI as [Stok Adý],S.TIPI AS [Tip],S.MARKA AS Marka,'+
  ' StokModel.ANAHTAR AS Model, S.GRUBU AS Grubu,S.OZELLIK AS [Özellik],S.IZLEME AS [Ýzleme] FROM'+
  ' STOKLAR AS S '+
  ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = S.MODEL AND StokModel.BOLUM=convert(int,''-2701''+convert(varchar(10),S.MARKA))'+
  ' Where S.TIPI='+Tablo.Query2.FieldByName('TIPI').AsString+' and S.ID <> '+STOKLAR.FieldByName('ID').AsString+' ';
  //Ayný Tipe sahip ürünler eþdeðer olarak seçilebilir.
  st := Tstringlist.create;
  if Tablo.ListedenBilgiGetir(StokSecimi, sql,st,[nil,nil,Tablo.repStokTipi,Tablo.repStokMarka,nil,Tablo.repStokGrubu,Tablo.repStokOzellik,Tablo.RepStokIzleme]) then begin
  Tablo.TablodanSorguAc(1,'Select * from STOKESDEGER Where STOKID='+STOKLAR.FieldByName('ID').AsString+' and STOKESDEGERID='''+st.Strings[0]+''' ');
    if Tablo.Query1.RecordCount = 0 then begin

      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into STOKESDEGER(STOKID,STOKESDEGERID,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI) values('+STOKLAR.FieldByName('ID').AsString+','+st.Strings[0]+','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''') ',[],[]);
      TabloYenile(TabStokEsdeger,[STOKLAR.FieldByName('ID').AsInteger]);

    end else
    begin
      Application.MessageBox(PChar(STUrun_listede_var),PChar(Uyari),MB_OK);
      Abort;
    end;
  end;
  st.free;
end;

procedure TStokListeDlg.ExceldenVeriAlMenuClick(Sender: TObject);
begin
   Excel2Stoklar
end;

procedure TStokListeDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TStokListeDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TStokListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TStokListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TStokListeDlg.Gorunmez;
begin

end;

procedure TStokListeDlg.GorunmezOlacak;
begin

end;

procedure TStokListeDlg.Gorunur;
begin
 if stokekranilkacilis then
  begin
    stokekranilkacilis:=False;
    AramaYap;
  end;

  UretimIslemleriMenu.Visible := Tablo.YetkiVarmi(3321,YetkiTur_Gorme); //üretim görev framedeki reçete butonunu görme yetkisi..

  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;

  FArama.AraStokAdi.SetFocus;
  if (FArama.AraStokAdi.Text <> '') or (FArama.AraKod.Text <> '') then // 10012008HA
    AraTusClick(nil);
  if not Tablo.YetkiVarmi(27012001,YetkiTur_Gorme) then begin
    tshFiyatlar.Visible := False;
    tshFiyatlar.TabVisible := False;
  end;
  if not Tablo.YetkiVarmi(27012011,YetkiTur_Gorme) then begin
  end;
  if not Tablo.YetkiVarmi(27012031,YetkiTur_Gorme) then begin
    tshStokDurum.Visible := False;
    tshStokDurum.TabVisible := False;
  end;
  if not Tablo.YetkiVarmi(27012041,YetkiTur_Gorme) then begin
    tshHareketler.Visible := False;
    tshHareketler.TabVisible := False;
  end;

end;

procedure TStokListeDlg.GorunurOlacak;
begin

end;

procedure TStokListeDlg.GridFiyatViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridFiyat;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFiyatView;
  AnaForm.pmGridStil.Tags.Values[GridFiyat.Name]:='StokFiyatGridi';
end;

procedure TStokListeDlg.GridSeriLotViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridSeriLot;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridSeriLotView;
  AnaForm.pmGridStil.Tags.Values[GridSeriLot.Name]:='GridSeriLotGridi';
end;

procedure TStokListeDlg.GridStokDurumViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridStokDurum;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridStokDurumView;
  AnaForm.pmGridStil.Tags.Values[GridStokDurum.Name]:='StokDurumGridi';
end;

procedure TStokListeDlg.GridStokDurumViewDblClick(Sender: TObject);
begin
   DetayIzlemeMenuClick(Self);
end;

procedure TStokListeDlg.GridStokViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridStok;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridStokView;
  AnaForm.pmGridStil.Tags.Values[GridStok.Name]:='StokListeGridi';
end;

procedure TStokListeDlg.GridStokViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
  PageControl1PageChanging(Sender,PageControl1.ActivePage,ChangePage);
end;

procedure TStokListeDlg.GridStokViewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TStokListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_STOKLAR);
end;

procedure TStokListeDlg.HareketlerinzlemBilgileriniGosterMenuClick(Sender: TObject);
begin
   PageHareketSeriLot.Visible := not PageHareketSeriLot.Visible
end;

procedure TStokListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TStokListeDlg.Kopyala1Click(Sender: TObject);
var
  ID:integer;
begin
  if Tablo.YetkiVarmi(2701,YetkiTur_Ekleme) then begin
    islemKopyala:='K';
    ID := Tablo.StokSihirbazBaslat('K', 0, STOKLAR.Fields[0].AsInteger,-1,0);
    if ID > 0 then
      TabloYenile(STOKLAR,[FArama.ComboPeriyot.EditValue]);
  end;
end;

procedure TStokListeDlg.KritikSeviyeMiktarnGiriniz1Click(Sender: TObject);
var
  Kritik,Maksimum,Minimum:Variant;
  VeriVarmi:Boolean;
begin
  if not STOKLAR.Active then Abort;
  Maksimum := tabStokDurum.FieldByName('MAKSIMUM').AsFloat;
  Minimum := tabStokDurum.FieldByName('MINIMUM').AsFloat;
  Kritik := tabStokDurum.FieldByName('KRITIK').AsFloat;

  if TGirisKutusuEx.BilgiAlEx(STOKLAR.FieldByName(STstok_adi).AsString + SDKSeviyeMiktariBilgisi,TGirdiDenetimleri.Create.
     CurrencyEdit(SDKMaksimumSeviyeMiktariGir, @Maksimum, Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2)).
     CurrencyEdit(SDKMinimumSeviyeMiktariGir, @Minimum, Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2)).
     CurrencyEdit(SDKKritikSeviyeMiktariGir, @Kritik, Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))) <> mrOk then
    Abort
  else
  begin
    if not tabStokDurum.Active and not(GridStokView.DataController.Controller.SelectedRecordCount > 0) then Abort;
    VeriVarmi := Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM STOKSEVIYE WHERE STOKID=&STOKID AND DEPOID=&DEPOID',['&STOKID','&DEPOID'],[tabStokDurum.FieldByName('STOKID').AsString,tabStokDurum.FieldByName('DEPOID').AsString]);
    with Tablo.Query5 do
    begin
      if VeriVarmi then
      begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE STOKSEVIYE SET MAKSIMUM=&MAKSIMUM, KRITIK=&KRITIK, MINIMUM=&MINIMUM, '+
        'DEGISTIREN=&DEGISTIREN, DEGISTIRMETARIHI=&DEGISTIRMETARIHI WHERE STOKID=&STOKID AND DEPOID=&DEPOID',
        ['&MAKSIMUM','&KRITIK','&MINIMUM','&DEGISTIREN','&DEGISTIRMETARIHI','&STOKID','&DEPOID'],[Maksimum,Kritik,Minimum,
        Kullanan,FormatDateTime('yyyy-MM-dd hh:nn',Tablo.GENINI.BugunTrhSaat),tabStokDurum.FieldByName('STOKID').AsInteger,tabStokDurum.FieldByName('DEPOID').AsInteger])
      end
      else
      begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO STOKSEVIYE (STOKID, DEPOID, MAKSIMUM, KRITIK, MINIMUM, EKLEYEN, EKLEMETARIHI)'+
          ' VALUES(&STOKID, &DEPOID, &MAKSIMUM, &KRITIK, &MINIMUM, &EKLEYEN, &EKLEMETARIHI)',['&STOKID','&DEPOID','&MAKSIMUM',
          '&KRITIK','&MINIMUM','&EKLEYEN','&EKLEMETARIHI'],[tabStokDurum.FieldByName('STOKID').AsInteger,tabStokDurum.FieldByName('DEPOID').AsInteger,
          Maksimum,Kritik,Minimum,Kullanan,FormatDateTime('yyyy-MM-dd hh:nn',Tablo.GENINI.BugunTrhSaat)])
      end;
    end;
    tabStokDurum.Active := False;
    tabStokDurum.Active := True;
  end;
end;

procedure TStokListeDlg.LogoResimClick(Sender: TObject);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Stoklar,STOKLAR.Fields[0].AsInteger);
   TabloYenile(TabResim,[STOKLAR.Fields[0].AsInteger]);
end;

procedure TStokListeDlg.MenuAciklamaDegisClick(Sender: TObject);
var ctrls : TGirdiDenetimleri;
    Mesaj : Variant;
begin
   Mesaj := TabStokEsdeger.FieldByName('ACIKLAMA').Value;
   ctrls:= TGirdiDenetimleri.Create.Edit('Mesaj:',@Mesaj);
   if TGirisKutusuEx.BilgiAlEx(BGAciklama, ctrls) = mrOk then begin
      veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update STOKESDEGER set ACIKLAMA='''+Mesaj+''', DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=GETDATE()  where ID='+
        TabStokEsdeger.FieldByName('ID').AsString,[],[]);
      TabloYenile(TabStokEsdeger,[]);
   end;
end;

procedure TStokListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TStokListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
  Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TStokListeDlg.MenuTurDegisClick(Sender: TObject);
var ctrls : TGirdiDenetimleri;
    eskiad : Variant;
    Mesaj : string;
begin
   eskiad := '';
   ctrls := TGirdiDenetimleri.Create.ComboBox((BGYeni_tur),@eskiad,tablo.ComboboxInit('Select ANAHTAR from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM ='+IntToStr(Ops_StokKart_EsdegerTur)+' ').items); //Anabirim listesi
   if TGirisKutusuEx.BilgiAlEx(BGYeni_tur_gir,ctrls)= mrOk then begin
      Mesaj := Tablo.inidenDegerGetir(IntToStr(Ops_StokKart_EsdegerTur), eskiad);
      veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update STOKESDEGER set TUR='+Mesaj+', DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=GETDATE()  where ID='+
        TabStokEsdeger.FieldByName('ID').AsString,[],[]);
      TabloYenile(TabStokEsdeger,[]);
   end;
end;

procedure TStokListeDlg.PageControl1PageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  AllowChange := True;
  if (not STOKLAR.Active)or(STOKLAR.RecordCount<1) then exit;

  if NewPage=tshFiyatlar then begin
     if RadioFiyatSatis.Checked then begin
        TabloYenile(STOKFIYAT, [-1007,STOKLAR.FieldByName('ID').AsInteger,1]);
        //GridFiyatViewFIYATADI.RepositoryItem:= Tablo.RepFiyatAdlari;
     end else begin
        TabloYenile(STOKFIYAT, [-1008,STOKLAR.FieldByName('ID').AsInteger,0]);
     end;
  end
  else if NewPage=tshStokDurum then // stokdurum sekmesi ise
          StokDurumGetir
  else if NewPage=TabYorumMedya then
          Tabloyenile(TabYorum,[TabNo_STOKLAR, STOKLAR.FieldByName('ID').AsInteger])
  else if NewPage=tshHareketler then Begin
     if ComboDepo.EditValue<0 then
        ComboDepo.EditValue:=VarsDepo;
     DateHarBasPropertiesEditValueChanged(Self);
  end else if NewPage=TshEsDegerUrun then
     TabloYenile(TabStokEsdeger, [STOKLAR.FieldByName('ID').AsInteger]);

  TabloYenile(TabResim, [STOKLAR.FieldByName('ID').AsInteger]);
  DateHarBas.Visible := NewPage=tshHareketler;
  DateHarBit.Visible := NewPage=tshHareketler;
  ComboDepo.Visible := NewPage=tshHareketler;
  cxLabel1.Visible := NewPage=tshHareketler;
  cxLabel2.Visible := NewPage=tshHareketler;
  cxLabel3.Visible := NewPage=tshHareketler;

end;

procedure TStokListeDlg.PmStilPopup(Sender: TObject);
var
 i : Integer;
begin
    cagirangrid:=((Sender as TPopupMenu).PopupComponent as TcxGridDBTableView).Name;
    gridalanlari:= TStringList.Create;

    for i := 0 to ((Sender as TPopupMenu).PopupComponent as TcxGridDBTableView).ColumnCount-1 do
       gridalanlari.Add(  ((Sender as TPopupMenu).PopupComponent as TcxGridDBTableView).Columns[i].DataBinding.FieldName);

end;

procedure TStokListeDlg.pmStokDurumPopup(Sender: TObject);
begin
  KritikSeviyeMiktarnGiriniz1.Enabled := (GridStokDurumView.DataController.Controller.SelectedRecordCount > 0);
end;

procedure TStokListeDlg.PmStokPopup(Sender: TObject);
begin
  EkipmanListesineEkle1.Enabled := (GridStokView.DataController.Controller.SelectedRecordCount > 0);
  CokSatilanRestMenu.Visible := Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest];
end;

procedure TStokListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TStokListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_STOKLAR, STOKLAR.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TStokListeDlg.AraStokAdiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    DegisTus.Click
  else if Key = 38 then
    STOKLAR.Prior
  else if Key = 40 then
    STOKLAR.next
  else //if TEdit(Sender).Text <> '' then
    AramaYap; // AraTus.Click;
end;

procedure TStokListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
   STOKLAR.Close;
   STOKLAR.SQL.Text :='SELECT '+ SQLMemo.Text;
   if not FArama.CheckPasifler.Checked then
      STOKLAR.SQL.Add(' where S.DURUM=1 ');
   if SubeVarmi then
    STOKLAR.SQL.Add(' and S.SUBEID in('+Tablo.YetkiliSubeleriGetir(27,YetkiTur_Gorme)+') ');
   STOKLAR.SQL.Add(' group by S.ID, S.KOD, S.STOKADI,K.AD, S.ICERIK, S.TIPI, S.MARKA, S.MODEL, S.GRUBU, S.OZELLIK, S.OZELKOD, S.MUHKODU, S.ANABIRIM, S.BIRIM2, S.BIRIM2MIKTAR, S.MINSTOK, S.KDV, S.DURUM,S.HUCRE, S.IZLEME,S.BILDIRIM, S.NOTLAR, StokModel.ANAHTAR,S.SUBEID, S.URUNNO ');
   STOKLAR.SQL.Add(' order by 1 ');
   TabloYenile(STOKLAR,[FArama.ComboPeriyot.EditValue]);
//   STOKLAR.Params[0].Value:=FArama.ComboPeriyot.EditValue;
//   STOKLAR.open;
end;


procedure TStokListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin
end;

procedure TStokListeDlg.tabStokDurumAfterClose(DataSet: TDataSet);
begin
  TabStokDurumDetay.Close;
end;

procedure TStokListeDlg.tabStokDurumAfterOpen(DataSet: TDataSet);
begin
  tabStokDurum.AfterScroll:=tabStokDurumAfterScroll;
end;

procedure TStokListeDlg.tabStokDurumAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabStokDurumDetay,[STOKLAR.FieldByName('ID').AsInteger,tabStokDurum.FieldByName('DEPOID').AsInteger]);
  TabloYenile(TabSeriLotDurum,[STOKLAR.FieldByName('ID').AsInteger, tabStokDurum.FieldByName('DEPOID').AsInteger]);
  if PageControl_SeriLot.ActivePage=TabSheetSeriLot then
     GridSeriLotViewSERINO.visible := STOKLAR.FieldByName('IZLEME').AsInteger in [1,6];

end;

procedure TStokListeDlg.tabStokDurumBeforeClose(DataSet: TDataSet);
begin
  tabStokDurum.AfterScroll := nil;
end;

procedure TStokListeDlg.tabStokDurumBeforeOpen(DataSet: TDataSet);
begin
  tabStokDurum.SQL.Text := StringReplace(tabStokDurum.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
end;

procedure TStokListeDlg.SeilirnlereBarkodOlutur1Click(Sender: TObject);
var
  Barkodlar : TArrayOfString;
  ctrls: TGirdiDenetimleri;
  Brkd,Brm: Variant;
  Varsayilanmi,i,StkID:integer;
  BirimTuru:string;
begin
  if GridStokView.Controller.SelectedRecordCount>0 then begin
    Brkd := -99;
    Brm := -99;
    ctrls := TGirdiDenetimleri.Create.ImageComboBox('Barkod Tipi Seçimi',@Brkd,Tablo.FDCnn,'select ID,AD from BARKODAYARLAR ')
                                     .ImageComboBox('Birim Seçimi',@Brm,Tablo.FDCnn,'select 0,''Anabirim'' union all select 1,''Birim 2''  ');
    if TGirisKutusuEx.BilgiAlEx(BGBilgi,ctrls) = mrOk then begin
      if (Brkd<>-99)and(Brm<>-99) then begin
        Barkodlar := Tablo.BarkodUret(Brkd,GridStokView.Controller.SelectedRecordCount);
        for I := 0 to GridStokView.Controller.SelectedRecordCount-1 do begin
          StkID := StrToIntDef(VarToStr(GridStokView.Controller.SelectedRows[i].Values[GridStokViewID.Index]),0);
          if StkID>0 then begin
            Tablo.TablodanSorguAc(1,'select 1 from STOKBARKOD where STOKID='+IntToStr(StkID)+' and VARSAYILAN=1 ');
            if Tablo.Query1.RecordCount=0 then
              Varsayilanmi:=1
            else
              Varsayilanmi:=0;
            if Brm=0 then
              BirimTuru := 'ANABIRIM'
            else
              BirimTuru := 'BIRIM2';
            VeriTabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into STOKBARKOD(BARKOD,STOKID,BARKODTIPI,BARKODBIRIMI,VARSAYILAN)'+
                       'select '''+Barkodlar[i]+''',ID,'+VarToStr(Brkd)+','+BirimTuru+','+IntToStr(Varsayilanmi)+' from STOKLAR where ID='+IntToStr(StkID),[],[]);
          end;
        end;
        AramaYap;
      end;
    end;
  end;
end;

procedure TStokListeDlg.SeriLotDuzenleClick(Sender: TObject);
var URT, SKT, Lot, Seri: Variant;
begin
   URT := TabSeriLotDurum.FieldByName('URT').AsDateTime;
   SKT := TabSeriLotDurum.FieldByName('SKT').AsDateTime;
   Lot := TabSeriLotDurum.FieldByName('LOTNO').AsString;
   Seri:= TabSeriLotDurum.FieldByName('SERINO').AsString;

   if TGirisKutusuEx.BilgiAlEx(jvIzlem,TGirdiDenetimleri.Create.Edit('Seri No:',@Seri).Edit('Lot No:',@Lot)
         .DateTimePicker('Üretim Tarihi',@URT).DateTimePicker('SKT',@SKT)) <> mrOk then
        Abort;

   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update STOKSERILOT set SERINO=&SNO, LOTNO=&LNO, URT=&URT, SKT=&SKT '+
      'Where ID='+TabSeriLotDurum.FieldByName('SERILOTID').AsString+' ',['&SNO', '&LNO', '&URT', '&SKT'],
       [VarToStr(Seri),VarToStr(Lot),formatDateTime('yyyy-mm-dd hh:nn', URT),formatDateTime('yyyy-mm-dd hh:nn', SKT)]);
   TabloYenile(TabSeriLotDurum,[STOKLAR.FieldByName('ID').AsInteger, tabStokDurum.FieldByName('DEPOID').AsInteger]);
end;

procedure TStokListeDlg.SetArama(const Value: TStokAramaFrame);
begin
  FArama := Value;
end;

procedure TStokListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
  AValue.AnaFrameBilgi.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(AnaFrameAktifOlacak);
end;

procedure TStokListeDlg.SilTusClick(Sender: TObject);
begin
  if Tablo.StokSilmeIslemleri(STOKLAR.Fields[0].AsInteger) then begin
    if LogGun>0 then
      Tablo.OncekiLogBelirle(STOKLAR);
    Tablo.LogIslemleri(TabNo_STOKLAR,STOKLAR.FieldByName('ID').AsInteger, 5, STOKLAR);
    AraTus.Click;
  end;
end;

procedure TStokListeDlg.STOKLARAfterOpen(DataSet: TDataSet);
begin
  YeniTus.Visible := Tablo.YetkiVarmi(2701,YetkiTur_Ekleme);
  DegisTus.Visible := (STOKLAR.RecordCount > 0);//and(Tablo.YetkiVarmi(2701,YetkiTur_Degistirme));
  SilTus.Visible := (STOKLAR.RecordCount > 0);//and(Tablo.YetkiVarmi(2701,YetkiTur_Silme));
  DetayAktif := true;
end;

procedure TStokListeDlg.STOKLARBeforeOpen(DataSet: TDataSet);
begin
  DetayAktif := False;
  {if FArama.ComboAnaliz.Text<>'' then begin
    GridStokViewSIPARIS.Visible:=True;
  end else begin
    GridStokViewSIPARIS.Visible:=False;
  end;}
//  STOKLAR.Params[1].Value := Dil;
end;

procedure TStokListeDlg.TabStokHareketlerAfterScroll(DataSet: TDataSet);
begin
   if PageHareketSeriLot.Visible then begin
      TabloYenile(TabSeriLotHareket,[STOKLAR.FieldByName('ID').AsInteger, TabStokHareketler.FieldByName('FATURAID').AsInteger]);
      GridSeriLotHareketView.ApplyBestFit();
   end;
end;

procedure TStokListeDlg.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TStokListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TStokListeDlg.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TStokListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

Procedure TStokListeDlg.StokEkranAc(ID: Integer);
begin
end;

procedure TStokListeDlg.StokHareketlerCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridHareket;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=StokHareketler;
  AnaForm.pmGridStil.Tags.Values[GridHareket.Name]:='StokHareketlerGridi';
end;

procedure TStokListeDlg.StokHareketlerCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  AnaForm.GormeDialogCagir(TabStokHareketler.FieldByName('FATBASID').AsInteger,
                          TabStokHareketler.FieldByName('TUR').AsInteger,
                          TabStokHareketler.FieldByName('REHBERID').AsInteger, 0,
                          TabStokHareketler.FieldByName('FATURATARIH').AsDateTime,
                          TabStokHareketler.FieldByName('FATURANO').AsString);


  JvTimer1Timer(self);
  Btnrnlerinstokdurumlarngncelle1Click(Self);
end;

procedure TStokListeDlg.StilDzenle1Click(Sender: TObject);
var
 i: integer;
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);
  for i := 0 to OpsiyonDlg.PageControl1.PageCount - 1 do
    OpsiyonDlg.PageControl1.Pages[i].TabVisible := OpsiyonDlg.PageControl1.Pages[i].Name = 'shtStiller';
  OpsiyonDlg.pageStil.ActivePage:= OpsiyonDlg.shtStilKosullari;
  (OpsiyonDlg.clmStilKosulGridAdi.Properties as TcxComboBoxProperties).Items.Clear;
  (OpsiyonDlg.clmStilKosulGridAdi.Properties as TcxComboBoxProperties).Items.Add(cagirangrid);
  (OpsiyonDlg.clmStilKosulAlanAdi.Properties as TcxComboBoxProperties).Items:= gridalanlari;
  OpsiyonDlg.ShowModal;
  FreeAndNil(OpsiyonDlg);
  FreeAndNil(gridalanlari);
  cagirangrid:='';
end;

procedure TStokListeDlg.StokDurumGetir;
begin
  if not STOKLAR.Active then
    Exit;
  tabStokDurum.Close;
  tabStokDurum.SQL.Text := ' select SD.STOKID, SD.DEPOID, SS.MAKSIMUM, SS.MINIMUM, SS.KRITIK, D.DEPOADI, SUM(SD.GIREN) AS GIREN, SUM(SD.CIKAN) AS CIKAN , SUM(SD.KALAN) AS KALAN, D.SUBEID ';
  tabStokDurum.SQL.Add(' from STOKDURUM SD INNER JOIN DEPOLAR D ON SD.DEPOID = D.ID LEFT JOIN STOKSEVIYE SS ON SS.STOKID=SD.STOKID AND SS.DEPOID=SD.DEPOID INNER JOIN STOKLAR S ON SD.STOKID=S.ID '
  +'WHERE S.ID='+STOKLAR.FieldByName('ID').AsString+' AND D.DURUM = 1');
 { if SubeVarmi then
    tabStokDurum.SQL.Add(' and D.SUBEID='+IntToStr(SubeId)+' '); }
  tabStokDurum.SQL.Add(' GROUP BY SD.STOKID, SD.DEPOID, D.DEPOADI , D.SUBEID, SS.MAKSIMUM, SS.MINIMUM, SS.KRITIK');
  if not cbSifirKalanGoster.Checked then
    tabStokDurum.SQL.Add(' HAVING SUM(KALAN)<>0 ');
  TabloYenile(tabStokDurum,[]);
end;

procedure TStokListeDlg.YeniReceteOlusturMenuClick(Sender: TObject);
begin
  Tablo.TablodanSorguAc(5,'insert into URETIMRECETE(KOD,AD,STOKID)values('''+STOKLAR.FieldByName('KOD').AsString+''','''+STOKLAR.FieldByName('STOKADI').AsString+''','+STOKLAR.FieldByName('ID').AsString+') select scope_identity()');
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into URETIMRECETEDETAY(URETIMRECETEID,TUR,URUNID,ADET,BIRIM,MIKTAR,ADETHESAP)select &URID,1,ID,1,ANABIRIM,1,1 from STOKLAR where ID=&StokID',['&URID','&StokID'],[Tablo.Query5.Fields[0].AsInteger,STOKLAR.Fields[0].AsInteger]);
  Tablo.ReceteSihirbazBaslat(Tablo.Query5.Fields[0].AsInteger,'D');
  RecetePopupDuzenle;
end;

procedure TStokListeDlg.YeniTusClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := Tablo.StokSihirbazBaslat('E', 0, -1,-1,0);
  if ID > 0 then
  begin
    STOKLAR.Close;
    STOKLAR.SQL.Text:= 'SELECT '+SQLMemo.Text;
    STOKLAR.SQL.Text := STOKLAR.SQL.Text+ ' where S.ID='+inttostr(ID);
    if SubeVarmi then
      STOKLAR.SQL.Add('and S.SUBEID in('+Tablo.YetkiliSubeleriGetir(27,YetkiTur_Gorme)+') ');
    STOKLAR.SQL.Add(' group by S.ID, S.KOD, S.STOKADI,K.AD, S.ICERIK, S.TIPI, S.MARKA, S.MODEL, S.GRUBU, S.OZELLIK, S.OZELKOD, S.MUHKODU, S.ANABIRIM, S.BIRIM2, S.BIRIM2MIKTAR, S.MINSTOK, S.KDV, S.DURUM,S.HUCRE, S.IZLEME,S.BILDIRIM, S.NOTLAR, StokModel.ANAHTAR,S.SUBEID, S.URUNNO ');
    AramayiSifirla;

    //STOKLAR.Params[0].Value:=FArama.ComboPeriyot.EditValue;
    //STOKLAR.Open;
  end;
end;

procedure TStokListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Stoklar);
end;

procedure TStokListeDlg.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
var
  ID, i: Integer;
  Ek: string[10];
begin
  if {Deðiþtirme / resim ekleme yetkisi var mý DYetkisonuc.Ekle =} True then begin
     for i := 0 to Value.Count - 1 do
        ResimEkleme(Value.Strings[i], STOKLAR.FieldByName('ID').AsInteger, Tabno_Stoklar, STOKLAR.FieldByName('ID').AsInteger);
     TabResim.Close;
     TabResim.Open;
     //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
  end else
    ShowMessage(Yetkisiz_Islem);
end;

initialization

RegisterClass(TStokListeDlg);

end.








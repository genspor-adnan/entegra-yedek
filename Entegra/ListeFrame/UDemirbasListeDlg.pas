unit UDemirbasListeDlg;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 07/12/2010 10:47:54 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, Menus, System.JSON,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, UGentegreFrameYonetimi, DB,
  cxLookAndFeelPainters, cxButtons, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxLookAndFeels,
  UDemirbasAramaFrame, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses, cxGraphics,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,
  cxSplitter, cxPC, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky, Utablo,
  cxCheckBox, OfficePopupMenu, cxGridCustomPopupMenu, cxGridPopupMenu, JvTimer,
  dxSkinLiquidSky, cxNavigator, dxBarBuiltInMenu, JvExControls, UBinarySave,
  cxPCdxBarPopupMenu, cxHyperLinkEdit, UDemirbasDurumDegis, JvNavigationPane,
  cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData, ComObj,
  cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView, cxLabel, dxCore,
  cxDateUtils, cxSpinEdit, cxTimeEdit, dxGDIPlusClasses, cxImage, cxDBEdit,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark, Winapi.ShellAPI,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDemirbasListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsDemirbaslar: TDataSource;
    DEMIRBAS: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    YaziciYaz: TToolButton;
    cxSplitter1: TcxSplitter;
    PgAltDetay: TcxPageControl;
    ToolButton1: TToolButton;
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
    frxDemirbas: TfrxDBDataset;
    SilTus: TToolButton;
    ToolButton3: TToolButton;
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
    AksiyonEkle: TToolButton;
    GridDemirbas: TcxGrid;
    GridDemirbasView: TcxGridDBTableView;
    GridDemirbasLevel3: TcxGridLevel;
    GridDemirbasViewLOKASYONADI: TcxGridDBColumn;
    GridDemirbasViewZIMMETLI: TcxGridDBColumn;
    GridDemirbasViewDURUM: TcxGridDBColumn;
    GridDemirbasViewKATEGORIADI: TcxGridDBColumn;
    GridDemirbasViewID: TcxGridDBColumn;
    TabSheetHareketler: TcxTabSheet;
    TabDemirbasTutanak: TFDQuery;
    dtsTabDemirbasTutanak: TDataSource;
    GridTarihce: TcxGrid;
    GridTarihceView: TcxGridDBTableView;
    GridTarihceViewTARIH: TcxGridDBColumn;
    GridTarihceViewTUTANAK: TcxGridDBColumn;
    GridTarihceViewZIMMETALAN: TcxGridDBColumn;
    GridTarihceViewZIMMETVEREN: TcxGridDBColumn;
    GridTarihceViewLOKASYON: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    TabSheetTakip: TcxTabSheet;
    frxDemirbasTutanak: TfrxDBDataset;
    GridDemirbasViewSUBEID: TcxGridDBColumn;
    GridDemirbasViewDEMIRBASNO: TcxGridDBColumn;
    GridDemirbasViewDEMIRBASADI: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    SQLMemo: TcxMemo;
    GridDemirbasViewMARKA: TcxGridDBColumn;
    GridDemirbasViewMODEL: TcxGridDBColumn;
    GridDemirbasViewLOKASYONID: TcxGridDBColumn;
    ToolBar2: TToolBar;
    TutanakGorTus: TToolButton;
    TutanakSilTus: TToolButton;
    TabKalibrasyon: TFDQuery;
    dtsKalibrasyon: TDataSource;
    TabSheetKalibrasyon: TcxTabSheet;
    ToolBar3: TToolBar;
    KalEkleTus: TToolButton;
    KalDuzenTus: TToolButton;
    KalSilTus: TToolButton;
    ToolButton6: TToolButton;
    gridKalibrasyon: TcxGrid;
    ViewKalibrasyon: TcxGridDBTableView;
    ViewKalibrasyonTARIH: TcxGridDBColumn;
    ViewKalibrasyonGECERLILIKTARIHI: TcxGridDBColumn;
    ViewKalibrasyonSERTIFIKA: TcxGridDBColumn;
    ViewKalibrasyonGONDERILENFIRMA: TcxGridDBColumn;
    ViewKalibrasyonFIRMAPERSONELI: TcxGridDBColumn;
    ViewKalibrasyonMALIYET: TcxGridDBColumn;
    ViewKalibrasyonKUR: TcxGridDBColumn;
    ViewKalibrasyonNOTLAR: TcxGridDBColumn;
    gridKalibrasyonLevel1: TcxGridLevel;
    SQLMemoTutanak: TcxMemo;
    PopupDemirbasListe: TPopupMenu;
    DemirbasInfoMenu: TMenuItem;
    GridTarihceViewBELGENO: TcxGridDBColumn;
    GridTarihceViewNOTLAR: TcxGridDBColumn;
    GridTarihceViewFIRMA: TcxGridDBColumn;
    tabDemirbasTutanakIcerik: TFDQuery;
    DtsDemirbasTutanakIcerik: TDataSource;
    frxDemirbasTutanakIcerik: TfrxDBDataset;
    KalibrasyonBilgisiGirMenu: TMenuItem;
    TeknikServisAtaMenu: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    TeknikServisSorumlusuAtaMenu: TMenuItem;
    BilgilendirilecekAtaMenu: TMenuItem;
    GridDemirbasViewTEKNIKBILGI: TcxGridDBColumn;
    GridDemirbasViewTEKNIKSORUMLU: TcxGridDBColumn;
    PopupMenuYeniTakip: TPopupMenu;
    MenuItemTakipGorev: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItemTakipDuyuru: TMenuItem;
    GorevlerMenu: TOfficePopupMenu;
    DuzenleMenu: TMenuItem;
    TamamlandiIsaretleMenu: TMenuItem;
    Bayraklaretle1: TMenuItem;
    MenuItem3: TMenuItem;
    TarihBugunMenu: TMenuItem;
    arihYarn1: TMenuItem;
    TarihiKaldirMenu: TMenuItem;
    MenuItem5: TMenuItem;
    Atamayap1: TMenuItem;
    MenuItem6: TMenuItem;
    BuiiEPostaGnder1: TMenuItem;
    BuiYazdr1: TMenuItem;
    MenuItem9: TMenuItem;
    IsiKopyalaMenu: TMenuItem;
    IsiSilMenu: TMenuItem;
    TabGorevler: TFDQuery;
    DtsGorevler: TDataSource;
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
    DtsYorum: TDataSource;
    TabYorumMedya: TcxTabSheet;
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
    TabYorum: TFDQuery;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    Panel9: TPanel;
    ToolBar4: TToolBar;
    GorevEkleTus: TToolButton;
    GorevSilTus: TToolButton;
    ToolButton2: TToolButton;
    GorevDuzenleTus: TToolButton;
    JvNavPanelHeader5: TJvNavPanelHeader;
    CheckTamamlanan: TcxCheckBox;
    ComboTamamlanan: TcxImageComboBox;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    PanelFiyatAltSag: TPanel;
    ToolBar5: TToolBar;
    ResimYapistirTus: TToolButton;
    ToolButton5: TToolButton;
    ResimDosyadanTus: TToolButton;
    LogoResim: TcxDBImage;
    TabSheetMasraflar: TcxTabSheet;
    DtsMasraflar: TDataSource;
    TabMasraflar: TFDQuery;
    MasrafGrid: TcxGrid;
    MasrafGridView: TcxGridDBTableView;
    MasrafGridViewBelgeTipi: TcxGridDBColumn;
    MasrafGridViewSatici: TcxGridDBColumn;
    MasrafGridViewBelgeTarihi: TcxGridDBColumn;
    MasrafGridViewBelgeNo: TcxGridDBColumn;
    MasrafGridViewAciklama: TcxGridDBColumn;
    MasrafGridViewTutar: TcxGridDBColumn;
    MasrafGridViewKDV: TcxGridDBColumn;
    MasrafGridViewToplam: TcxGridDBColumn;
    MasrafGridViewKUR: TcxGridDBColumn;
    MasrafGridViewPersonel: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    PopupMasraflar: TPopupMenu;
    BtnTahakkukEkle: TMenuItem;
    N6: TMenuItem;
    Exceldenverial: TMenuItem;
    N7: TMenuItem;
    Dzenle1: TMenuItem;
    Sil1: TMenuItem;
    GridTarihceViewBELGETARIH: TcxGridDBColumn;
    GridTarihceViewTUTAR: TcxGridDBColumn;
    GridTarihceViewKUR: TcxGridDBColumn;
    GridDemirbasViewOZELLIK1: TcxGridDBColumn;
    GridDemirbasViewOZELLIK2: TcxGridDBColumn;
    GridDemirbasViewOZELLIK3: TcxGridDBColumn;
    GridDemirbasViewOZELLIK4: TcxGridDBColumn;
    GridDemirbasViewOZELLIK5: TcxGridDBColumn;
    procedure DegisTusClick(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DEMIRBASAfterOpen(DataSet: TDataSet);
    procedure PgAltDetayChange(Sender: TObject);
    procedure AraDemirbasNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridTarihceViewDblClick(Sender: TObject);
    procedure GridDemirbasViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure AlanYnetimi2Click(Sender: TObject);
    procedure StilDzenle1Click(Sender: TObject);
    procedure GridTarihceViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridTarihceViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridDemirbasViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridTakipViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridSozlesmeViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridTamirServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure SilTakipTusClick(Sender: TObject);
    procedure Kopyala1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Demirbas_Liste)
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
    procedure TutanakSilTusClick(Sender: TObject);
    procedure KalEkleTusClick(Sender: TObject);
    procedure KalDuzenTusClick(Sender: TObject);
    procedure KalSilTusClick(Sender: TObject);
    procedure ViewKalibrasyonCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure TutanakGorTusClick(Sender: TObject);
    procedure TabDemirbasTutanakAfterScroll(DataSet: TDataSet);
    procedure YeniTusClick(Sender: TObject);
    procedure checkGecmisTakipleriGosterPropertiesChange(Sender: TObject);
    procedure PopupDemirbasListePopup(Sender: TObject);
    procedure DemirbasInfoMenuClick(Sender: TObject);
    procedure KalibrasyonBilgisiGirMenuClick(Sender: TObject);
    procedure TeknikServisSorumlusuAtaMenuClick(Sender: TObject);
    procedure MenuItemTakipGorevClick(Sender: TObject);
    procedure TreeListGorevDblClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure CheckTamamlananClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure GorevEkleTusClick(Sender: TObject);
    procedure GorevSilTusClick(Sender: TObject);
    procedure ResimYapistirTusClick(Sender: TObject);
    procedure ResimDosyadanTusClick(Sender: TObject);
    procedure LogoResimClick(Sender: TObject);
    procedure BtnTahakkukEkleClick(Sender: TObject);
    procedure ExceldenverialClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure Dzenle1Click(Sender: TObject);
    procedure TabMasraflarAfterOpen(DataSet: TDataSet);
    procedure GridDemirbasViewFocusedRecordChanged(
      Sender: TcxCustomGridTableView; APrevFocusedRecord,
      AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  private
    { Private declarations }
    FFrameBilgi: TIcerikFrameBilgi;
    FArama: TDemirbasAramaFrame;
    // SAYFALI liste (merkezi TSayfaliListe, Utablo)
    FSayfali: TSayfaliListe;
    FSonMod: SmallInt;   // son Liste_SP_Cagir modu (sayfa buyutme ayni modla)
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
    procedure StokListeDlgKapatEylemi(Sender: TObject);
    procedure StokListeDlgEkranAc(Yeni: Boolean);
    procedure PopupHazirla(Durum:integer);
    procedure DemirbasDurumDegisClick(Sender: TObject);
    procedure SetArama(const Value: TDemirbasAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure TabDemirbaslarRefresh;
    function EkranAdiAl: string;
    function TakipBoslukKontrol : Boolean;
    function DurumGetir(Aksiyon:Integer):Integer;

  public
    { Public declarations }

  published
    property Arama: TDemirbasAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UDemirbasWizard, URaporAraclari, UGenelAnaSekmeFrame,
  UFastRap, PrjConst, UMesaj, UOpsDlg,UGirisKutusuEx,LocOnFly, UGorevDlg, UIsListesi, UResim, UExceldenVeriAl,
  UBekletme, ULog, UVeriMotor;
{$R *.dfm}
{ TDemirbasListeDlg }

var
  OncekiSayfaIndex, KategoriYetki: SmallInt;
  KalibrasyonYetkisi, TeknikServisYetkisi, AlanlarOlusturuldu : Boolean;
  FIlkSonAranan : Boolean;   // ilk acilista Son Aranan (5) goster (JvTimer'de)



function TDemirbasListeDlg.EkranAdiAl: string;
begin
  if PgAltDetay.ActivePage=TabSheetHareketler then
    Result := 'TutanakListeDlg'
  else
    Result := 'DemirbasListeDlg';
end;

procedure TDemirbasListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi, Ekranadi : String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Ekranadi := EkranAdiAl;
  Delete(DokumAdi, pos('&',DokumAdi), 1);


  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxDemirbas);
  if EkranAdi ='TutanakListeDlg' then begin
    AFastReport.EnabledDataSets.Add(frxDemirbasTutanak);
    TabloYenile(tabDemirbasTutanakIcerik,[TabDemirbasTutanak.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxDemirbasTutanakIcerik);
  end
  else begin
        if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxDemirbas) then begin
          AFastReport.EnabledDataSets.Clear;
          AFastReport.EnabledDataSets.Add(frxDemirbas);
        end else begin
          frxDemirbas.Dataset := DEMIRBAS;
          AFastReport.EnabledDataSets.Clear;
          AFastReport.EnabledDataSets.Add(frxDemirbas);
        end;
  end;
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  // Kullanici ek alanlari (_USER) rapora (secili demirbas karti).
  if DEMIRBAS.Active and (not DEMIRBAS.IsEmpty) then
    Tablo.UserAlanYazdirmaEkle(AFastReport, 'DEMIRBAS', DEMIRBAS.FieldByName('ID').AsInteger);
end;

procedure TDemirbasListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TDemirbasListeDlg.Baslatildi;
var
  ra: string;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  GridDemirbasViewSUBEID.Visible := SubeVarmi;
  Tablo.GridAyarRestore('DemirbasGecmis',GridTarihceView );
//  Tablo.GridAyarRestore('DemirbasTakip',GridTakipView );
  Tablo.GridAyarRestore('DemirbasKalibrasyonGridi',ViewKalibrasyon );
  Tablo.GridTurkcelestir;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;


  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;

  OncekiSayfaIndex := -1;
  PgAltDetay.ActivePageIndex := 0;
  AlanlarOlusturuldu := False;

  KalibrasyonYetkisi  := Tablo.YetkiVarmi(280102,YetkiTur_Gorme); //kalibrasyon
  TeknikServisYetkisi := Tablo.YetkiVarmi(280103,YetkiTur_Gorme); //

  if not Tablo.YetkiVarmi(2801,YetkiTur_Ekleme) then
    YeniTus.Visible:=False;
  if not Tablo.YetkiVarmi(2801,YetkiTur_Degistirme) then
    DegisTus.Tag := -1;
  if not Tablo.YetkiVarmi(2801,YetkiTur_Silme) then
    SilTus.Tag := -1;
  //16/01/2023 AO burada kullanıcının hangi kategorileri göreceğine dair yetki kontrolü yapmamız gerekiyor
  if TamYetkili then
     KategoriYetki := 1 ///herşeyi
  else begin
     Tablo.TablodanSorguAc(1,'select isnull(BILGI2,1) from YETKIEK where ROLID='+RolId+' and MODULID=2801');//demirbaş liste
     if Tablo.Query1.RecordCount>0 then
        KategoriYetki := Tablo.Query1.Fields[0].AsInteger
     else
        KategoriYetki := 1;
  end;

  // Tum/Son/Sik Aranan butonlarini list frame handler'larina bagla (SP listeleme)
  if Assigned(FArama) then begin
    FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
    FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
    FArama.LabelSikArananlar.OnClick := LabelSikArananlarClick;
    FIlkSonAranan := True;   // ilk acilis: JvTimer'de Son Aranan (5) yuklensin (KategoriYetki'den SONRA)
  end;

  // SAYFALI liste: merkezi yardimci; sayfa boyu GENEL OPSIYON (Liste sayfa uzunlugu).
  if FSayfali = nil then
    FSayfali := TSayfaliListe.Baglan(Self, DEMIRBAS, GridDemirbasView, nil,
      procedure
      begin
        Liste_SP_Cagir(FSonMod);
      end);
end;

procedure TDemirbasListeDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  Tabno_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger, DEMIRBAS.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TDemirbasListeDlg.BtnTahakkukEkleClick(Sender: TObject);
begin
  Tablo.TahakkukSihirbaziBaslat('E', 13,1, -1, -99, Tablo.GENINI.BugunTrhSaat,False,-1,DEMIRBAS.FieldByName('ID').AsInteger);
  Tabloyenile(TabMasraflar,[DEMIRBAS.FieldByName('ID').AsInteger]);
end;

procedure TDemirbasListeDlg.checkGecmisTakipleriGosterPropertiesChange( Sender: TObject);
begin
   PgAltDetayChange(Self);
end;

procedure TDemirbasListeDlg.CheckTamamlananClick(Sender: TObject);
begin
   ComboTamamlanan.Visible := CheckTamamlanan.Checked;
   PgAltDetayChange(Self);
end;

procedure TDemirbasListeDlg.TeknikServisSorumlusuAtaMenuClick(Sender: TObject);
var
  DemirbasId, RehID, srid, I: integer;
  s:string[20];
begin
  if GridDemirbasView.Controller.SelectedRecordCount > 0 then begin
     if TMenuItem(Sender).Tag =  337 then
        s:='TEKNIKBILGI'
     else
        s:='TEKNIKSORUMLU';

     srid := GridDemirbasView.DataController.FocusedRecordIndex;
     if (TMenuItem(Sender).Tag=337)or(TMenuItem(Sender).Tag=335) then
        RehID := Tablo.RehberAra_IDGetir(TMenuItem(Sender).Tag)
     else
        RehId := 0;
     if RehID >= 0 then
        for I := 0 to GridDemirbasView.Controller.SelectedRecordCount-1 do begin
           DemirbasId  := StrToIntDef(VartoStr(GridDemirbasView.Controller.SelectedRecords[i].Values[GridDemirbasViewID.Index]),0);
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS set SERVIS=1, '+s+'=&RehID where ID=&id ', ['&RehID','&id'], [RehID, DemirbasId]);
     end;
     YenileTusClick(Sender);
     GridDemirbasView.DataController.FocusedRecordIndex := srid;
     GridDemirbasView.ViewData.Records[srid].Selected := true;
  end;
end;

procedure TDemirbasListeDlg.TreeListGorevDblClick(Sender: TObject);
var  GorevDlg1: TGorevDlg;
begin
   Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', TabGorevler.FieldByName('ID').AsInteger, AtamaYapildi, YorumYapildi);
   PgAltDetayChange(Self);
end;

procedure TDemirbasListeDlg.GridTamirServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TDemirbasListeDlg.PgAltDetayChange(Sender: TObject);
var AcKapa:String[1];
    GunSay : Smallint;
    ra : string;
begin
  if (DEMIRBAS.Active)and(DEMIRBAS.RecordCount>0)and(PgAltDetay.ActivePage <> nil) then begin
      case PgAltDetay.ActivePage.Tag of
        1: begin
              //TabDemirbasTutanak.SQL.Text := StringReplace( SQLMemoTutanak.Text, '--@Zimmet', 'ZIMMETALAN = (SELECT R.FIRMA FROM REHBER R WHERE R.ID = DT.ALANID),'+
              //            'ZIMMETVEREN = (SELECT R.FIRMA FROM REHBER R WHERE R.ID = DT.VERENID),',[]);
              TabloYenile(TabDemirbasTutanak, [DEMIRBAS.FieldByName('ID').AsInteger]);
           end;
        3: TabloYenile(TabKalibrasyon, [DEMIRBAS.FieldByName('ID').AsInteger]);
        4: begin //Takip  uyarı
              //TabTakip.SQL.Text := ' select DT.* from DEMIRBAS_TAKIP DT where DEMIRBASID='+DEMIRBAS.FieldByName('ID').AsString;
              //if not checkGecmisTakipleriGoster.Checked then
              //       TabTakip.SQL.Add(' and BITISTARIHI>'''+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)+'''');
              //TabTakip.SQL.Add(' order by BASLAMATARIHI desc');
              //TabloYenile(TabTakip, [DEMIRBAS.FieldByName('ID').AsInteger]);

              AcKapa:=IntToStr(Abs(StrToInt(BoolToStr(CheckTamamlanan.Checked))));
              if CheckTamamlanan.Checked then
                 GunSay := ComboTamamlanan.EditValue
              else
                 GunSay := 9999;
              TabloYenile(TabGorevler,[Kullanan, AcKapa,  GunSay, DEMIRBAS.FieldByName('ID').AsInteger]);
           end;
        5:Tabloyenile(TabYorum,[Tabno_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger]);
        6:Tabloyenile(TabMasraflar,[DEMIRBAS.FieldByName('ID').AsInteger]);

      end;
      TabloYenile(TabResim, [DEMIRBAS.FieldByName('ID').AsInteger]);
  end;
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;
end;

procedure TDemirbasListeDlg.AraDemirbasNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
     DegisTus.Click
  else if Key = 38 then
     DEMIRBAS.Prior
  else if Key = 40 then
     DEMIRBAS.next
  else // if TEdit(Sender).Text <> '' then
     YenileTusClick(Sender);
end;

procedure TDemirbasListeDlg.YenileTusClick(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TDemirbasListeDlg.DegisTusClick(Sender: TObject);
var
  srid: Integer;
begin
  if GridDemirbasView.Controller.SelectedRecordCount > 0 then begin
     // := GridDemirbasView.DataController.FocusedRecordIndex;
     srid := DEMIRBAS.Fields[0].AsInteger;
     Tablo.AramaKaydet(MODUL_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger);   // Son/Sik Aranan takibi (kart acilinca upsert)
     if Tablo.DemirbasSihirbazBaslat('D', 0, DEMIRBAS.FieldByName('ID').AsInteger) > 0 then begin
        //YenileTusClick(Self);
        TabloYenile(DEMIRBAS,[]);
        PgAltDetayChange(Self);
        DEMIRBAS.Locate('ID', srid, []);
        GridDemirbasView.DataController.SetFocus;
        //GridDemirbasView.DataController.FocusedRecordIndex:=srid;
     end;
  end;
end;

procedure TDemirbasListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger,DEMIRBAS.FieldByName('REHBERID').AsInteger)
end;

procedure TDemirbasListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TDemirbasListeDlg.ExceldenverialClick(Sender: TObject);
begin
    Excel2Demirbas;
    FArama.YenileTus.Click;
end;


procedure TDemirbasListeDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDemirbasListeDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDemirbasListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDemirbasListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TDemirbasListeDlg.Gorunmez;
begin

end;

procedure TDemirbasListeDlg.GorunmezOlacak;
begin
  PgAltDetay.ActivePageIndex := 0;
end;

procedure TDemirbasListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TDemirbasListeDlg.GorunurOlacak;
begin

end;

procedure TDemirbasListeDlg.GridDemirbasViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TDemirbasListeDlg.GridDemirbasViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridDemirbas;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridDemirbasView;
  AnaForm.pmGridStil.Tags.Values[GridDemirbas.Name] := 'DemirbasGridi';
end;

procedure TDemirbasListeDlg.GridDemirbasViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
  TabSheetKalibrasyon.TabVisible := DEMIRBAS.FieldByName('KALIBRASYON').AsBoolean;
  TabSheetTakip.TabVisible := DEMIRBAS.FieldByName('TAKIP').AsBoolean;
  //TabloYenile(TabDokuman,[TabNo_DEMIRBAS,DEMIRBAS.FieldByName('ID').AsInteger]);
  PgAltDetayChange(Self);
end;

procedure TDemirbasListeDlg.GridTakipViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
//  AnaForm.cxGridPopupMenu1.Grid:=GridTakip;
//  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTakipView;
//  AnaForm.pmGridStil.Tags.Values[GridTakip.Name] := 'DemirbasTakip';
end;

procedure TDemirbasListeDlg.GridTarihceViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridTarihce;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTarihceView;
  AnaForm.pmGridStil.Tags.Values[GridTarihce.Name] := 'DemirbasGecmis';
end;

procedure TDemirbasListeDlg.GridSozlesmeViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TDemirbasListeDlg.GridTarihceViewDblClick(Sender: TObject);
var
  srid, srid2,ID: Integer;
begin
  if TutanakGorTus.Enabled then
     TutanakGorTus.Click;
{  if GridTarihceView.Controller.SelectedRecordCount > 0 then
  begin
    srid2 := GridTarihceView.DataController.FocusedRecordIndex;
    if GridDemirbasView.Controller.SelectedRecordCount > 0 then
    begin
      srid := GridDemirbasView.DataController.FocusedRecordIndex;
            if Tablo.DemirbasSihirbazBaslat('D', 1, DEMIRBAS.FieldByName('ID').AsInteger) > 0 then
              YenileTusClick(Self);

      GridDemirbasView.DataController.FocusedRecordIndex:=srid;
      GridDemirbasView.ViewData.Records[srid].Selected := true;
    end;
    GridTarihceView.DataController.FocusedRecordIndex:=srid2;
    GridTarihceView.ViewData.Records[srid2].Selected := false;
  end;}
end;

procedure TDemirbasListeDlg.GridTarihceViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TDemirbasListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_Demirbas);
end;

procedure TDemirbasListeDlg.GorevEkleTusClick(Sender: TObject);
var
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin
     GorevId := Tablo.GorevOlustur(DEMIRBAS.FieldByName('DEMIRBASADI').AsString, DemirbasKlasor,0, 0, 0, 0, DEMIRBAS.FieldByName('ID').AsInteger, 0, -1,
                                   TabNo_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat);

      Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', GorevId, AtamaYapildi, YorumYapildi);
      if AtamaYapildi then
         Gorev_EPostaGonder(1, GorevId)
      else if YorumYapildi then
         Gorev_EPostaGonder(3, GorevId);
      PgAltDetayChange(Self);
end;

procedure TDemirbasListeDlg.GorevSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) = ID_OK then begin
     Tablo.GorevSil(TabGorevler.Fields[0].AsInteger);
     PgAltDetayChange(Self);
  end;
end;

procedure TDemirbasListeDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  if Tablo.IlkAcilisSonArananMi(FIlkSonAranan) then begin Liste_SP_Cagir(5); Exit; end;   // ilk acilis: Son Aranan
  Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP
end;

procedure TDemirbasListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// Demirbas listesini sunucu-tarafi SP ile getirir (sp_Prog_Demirbas_Liste_Json2 - 2 PARAM JSON).
//   @Baslik   = SELECT ek kolonlari (ham SQL, app-uretimi/GUVENILIR; Demirbas'ta bos '').
//   @Kosullar = filtreler + yetki kisitlari JSON (cast/parametreli DEGERLER; guvenli escape).
//   AMod: 1=Tum (TOP yok), 3=Sik Aranan, 4=Filtre/normal, 5=Son Aranan.
//   Bos/opsiyonel filtre JSON'a EKLENMEZ (SP absent=NULL/varsayilan=filtre yok); bool 0/1 (TRY_CAST AS BIT).
var
  SubeYetki: string;
  KullaniciKisit, SubeIdP, RolIdP, KategoriYetkiP, locateid, TopN: Integer;
  j: TJSONObject;
begin
  // SAYFALI (TSayfaliListe): Mod=1 (Tum) ve Mod=4 (filtre/normal) sayfalanir;
  // Son/Sik Aranan eski davranista (dogasi geregi kucuk listeler).
  FSonMod := AMod;
  if AMod in [1, 4] then
     TopN := FSayfali.TopN
  else begin
     FSayfali.TopN(False);   // tetikleri pasiflestir
     // Son/Sik icin guvenlik supabi (bkz. UUretimListeDlg): TOP'suz tam tabloya dusmesin.
     TopN := 200;
  end;

  locateid := 0;
  if (DEMIRBAS.Active) and (DEMIRBAS.RecordCount > 0) then
    locateid := DEMIRBAS.FieldByName('ID').AsInteger;

  // Sube yetkisi (JvTimer eski mantigi birebir)
  if SubeVarmi then SubeYetki := Tablo.YetkiliSubeleriGetir(28, YetkiTur_Gorme)
  else SubeYetki := '';

  // Kullanici/kategori yetkisi (TamYetkili degilse); app varsayilan gonderince SP no-op
  KullaniciKisit := 0; SubeIdP := 0; KategoriYetkiP := 1; RolIdP := 0;
  if not TamYetkili then
  begin
    case ModulYetki_TekSubeTum.Demirbas of
      1:  KullaniciKisit := 1;                                   // sadece kendi
      5:  KullaniciKisit := 5;                                   // sadece kendi departman
      10: begin KullaniciKisit := 10; SubeIdP := SubeId; end;    // sadece kendi sube
    end;
    KategoriYetkiP := KategoriYetki;                             // Baslatildi'da hesaplandi
    RolIdP := StrToIntDef(RolId, 0);
  end;

  DEMIRBAS.AfterScroll := nil;

  j := TJSONObject.Create;
  try
    j.AddPair('Mod',   TJSONNumber.Create(AMod));
    j.AddPair('TopN',  TJSONNumber.Create(TopN));                       // 0 = TOP yok (sayfali dalda sayfa boyu)
    j.AddPair('Pasif', TJSONNumber.Create(Ord(FArama.cbPasiflerideGoster.Checked)));
    if Trim(FArama.AraDurumu.Text) <> '' then
      j.AddPair('DurumID', TJSONNumber.Create(StrToIntDef(VarToStr(FArama.AraDurumu.EditValue), 0)));
    if Trim(FArama.AraKategoribtne.Text)  <> '' then j.AddPair('KategoriAdi',   Trim(FArama.AraKategoribtne.Text));
    if Trim(FArama.AraLokasyonbtne.Text)  <> '' then j.AddPair('LokasyonAdi',   Trim(FArama.AraLokasyonbtne.Text));
    if Trim(FArama.AraZimmetAlanbtne.Text)<> '' then j.AddPair('ZimmetAlanAdi', Trim(FArama.AraZimmetAlanbtne.Text));
    if Trim(FArama.AraDemirbasNo.Text)    <> '' then j.AddPair('DemirbasNo',    Trim(FArama.AraDemirbasNo.Text));
    if Trim(FArama.AraDemirbasAdi.Text)   <> '' then j.AddPair('DemirbasAdi',   Trim(FArama.AraDemirbasAdi.Text));
    if Trim(FArama.AraSeriNo.Text)        <> '' then j.AddPair('SeriNo',        Trim(FArama.AraSeriNo.Text));
    if SubeYetki <> '' then j.AddPair('SubeYetkiList', SubeYetki);

    // Kullanici kisiti (TamYetkili degilse; varsayilan 0 -> JSON'a eklenmez -> SP no-op)
    if KullaniciKisit <> 0 then
    begin
      j.AddPair('KullaniciKisit', TJSONNumber.Create(KullaniciKisit));
      if KullaniciKisit in [1, 5] then j.AddPair('KullaniciId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));
      if KullaniciKisit = 10 then       j.AddPair('SubeId',      TJSONNumber.Create(SubeIdP));
    end;

    // Kategori yetkisi (varsayilan 1 -> JSON'a eklenmez -> SP no-op)
    if KategoriYetkiP <> 1 then
    begin
      j.AddPair('KategoriYetki', TJSONNumber.Create(KategoriYetkiP));
      if KategoriYetkiP = 2 then j.AddPair('RolId', TJSONNumber.Create(RolIdP));
    end;

    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));   // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_Demirbas));            // KULLANICI_ARAMA.MODUL

    // Generic helper: @Baslik='' (Demirbas ek-alan yok) + @Kosullar=j (JSON); helper j'yi Free eder + TabloYenile yapar.
    Tablo.ListeSPJson(DEMIRBAS, 'sp_Prog_Demirbas_Liste_Json2', '', j, locateid);
    j := nil;   // sahiplik helper'a gecti -> finally'de tekrar Free etme
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;

  if not AlanlarOlusturuldu then
  begin
    GridDemirbasView.DataController.CreateAllItems(True);
    Tablo.GridAyarRestore('DemirbasGridi', GridDemirbasView);
    AlanlarOlusturuldu := True;
  end;
  FSayfali.YuklemeSonrasi;   // ekran dolana kadar zincirleme sayfa (yalniz sayfali dalda etkin)
end;

procedure TDemirbasListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(1);   // Tum (TOP yok) -> sunucu-tarafi SP
end;

procedure TDemirbasListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA tarih desc)
end;

procedure TDemirbasListeDlg.LabelSikArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA say desc)
end;

procedure TDemirbasListeDlg.KalDuzenTusClick(Sender: TObject);
begin
   if Tablo.KalibrasyonDlgBaslat('D', 1, DEMIRBAS.FieldByName('ID').AsInteger, TabKalibrasyon.FieldByName('ID').AsInteger)>0 then
      TabloYenile(TabKalibrasyon,[DEMIRBAS.FieldByName('ID').AsInteger]);
end;

procedure TDemirbasListeDlg.KalEkleTusClick(Sender: TObject);
begin
   if Tablo.KalibrasyonDlgBaslat('E', 1, DEMIRBAS.FieldByName('ID').AsInteger,-1)>0 then
      TabloYenile(TabKalibrasyon,[DEMIRBAS.FieldByName('ID').AsInteger]);

end;

procedure TDemirbasListeDlg.KalibrasyonBilgisiGirMenuClick(Sender: TObject);
var
  srid,KalId,DemId,I: Integer;
begin
  if GridDemirbasView.Controller.SelectedRecordCount > 0 then begin
      DemId := GridDemirbasView.Controller.SelectedRecords[0].Values[GridDemirbasViewID.Index];
      KalId := Tablo.KalibrasyonDlgBaslat('E', 1, DemId,-1);
      if KalId > 0 then begin //bir tane eklendiyse bunu diğerlerine kopyalayalım
         srid := GridDemirbasView.DataController.FocusedRecordIndex;
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS set KALIBRASYON=1 where ID=&id ', ['&id'], [DemId]);
         if GridDemirbasView.Controller.SelectedRecordCount > 1 then
            for I := 1 to GridDemirbasView.Controller.SelectedRecordCount-1 do begin
                DemId := GridDemirbasView.Controller.SelectedRecords[i].Values[GridDemirbasViewID.Index];
                Tablo.SQLSatiriKopyala('KALIBRASYON', KalId, ['DEMIRBASID'], [DemId]);
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS set KALIBRASYON=1 where ID=&id ', ['&id'], [DemId]);
            end;
         YenileTusClick(Sender);
         GridDemirbasView.DataController.FocusedRecordIndex:=srid;
         GridDemirbasView.ViewData.Records[srid].Selected := true;
      end;
   end;
end;

procedure TDemirbasListeDlg.KalSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KALIBRASYON where ID='+TabKalibrasyon.FieldByName('ID').AsString, [],[]);
     TabloYenile(TabKalibrasyon,[DEMIRBAS.FieldByName('ID').AsInteger]);
  end;
end;

procedure TDemirbasListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDemirbasListeDlg.Kopyala1Click(Sender: TObject);
var  YeniDemirbasID:integer;
begin
  YeniDemirbasID := Tablo.SQLSatiriKopyala('DEMIRBAS', DEMIRBAS.FieldByName('ID').AsInteger, ['DEMIRBASNO','DURUM', 'SERVISDURUM','REHBERID','EKLEYEN', 'EKLEMETARIHI'],
          ['0',0,0,0,Kullanan, Tablo.GENINI.BugunTrhSaat]);

  if Tablo.DemirbasSihirbazBaslat('K', 0, YeniDemirbasID) > 0 then
     YenileTusClick(Self);
end;

procedure TDemirbasListeDlg.LogoResimClick(Sender: TObject);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Demirbas,DEMIRBAS.Fields[0].AsInteger);
   TabloYenile(TabResim,[DEMIRBAS.Fields[0].AsInteger]);
end;

procedure TDemirbasListeDlg.MenuItemTakipGorevClick(Sender: TObject);
var
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin

   GorevId := Tablo.GorevOlustur('', -999,0, 0, 0, 0,0,0,0, TabNo_DEMIRBAS, DEMIRBAS.FieldByName('ID').AsInteger, 0, 0);
   Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', GorevId, AtamaYapildi, YorumYapildi);
   PgAltDetayChange(Self);
   //Tabloyenile(TabTakip,[DEMIRBAS.FieldByName('ID').AsInteger]);
end;

procedure TDemirbasListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TDemirbasListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TDemirbasListeDlg.TutanakSilTusClick(Sender: TObject);
var s:string;
begin
  if Application.MessageBox(PChar(DDSilinsinmi),PChar(Uyari),MB_YESNO)=mrYes then  begin
    case TabDemirbasTutanak.FieldByName('TIP').AsInteger of
       21 :  //eğer zimmet aksiyonu silindiyse tablodaki zimmetli adı boşa gelecek
             s:=',REHBERID=0';
       22 :  //eğer zimmet iade aksiyonu silindiyse tablodaki son zimmetli adı alan kişiye gelecek
             s:= ',REHBERID=(select '+DbUst(1)+'DT.ALANID from DEMIRBAS_TUTANAK DT inner join DEMIRBAS_TUTANAK_DETAY DTD on DT.ID=DTD.TUTANAKID '+
                 ' where DTD.DEMIRBASID='+DEMIRBAS.Fields[0].AsString+' and TIP = 21  order by DT.TARIH desc '+DbSinir(1)+')';
       else  s:='';
    end;

    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'if not exists(select * from DEMIRBAS_TUTANAK_DETAY where TUTANAKID=&TId) '+
       ' delete from DEMIRBAS_TUTANAK where ID=&TId ', ['&TId'], [TabDemirbasTutanak.Fields[0].AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DEMIRBAS_TUTANAK_DETAY where TUTANAKID=&TId and DEMIRBASID=&DId', ['&TId','&DId'],
       [TabDemirbasTutanak.Fields[0].AsInteger, DEMIRBAS.Fields[0].AsInteger]);
    //eğer servis ise ve görev atanmışsa onun da silinmesi lazım
    if TabDemirbasTutanak.FieldByName('TIP').AsInteger = 23 then begin
       Tablo.TablodanSorguAc(1, 'select ID from GOREVLER where YER='+IntToStr(Tabno_Demirbas_Tutanak)+' and YER_ID='+TabDemirbasTutanak.Fields[0].AsString);
       if Tablo.Query1.RecordCount>0 then
          Tablo.GorevSil(Tablo.Query1.Fields[0].AsInteger);
    end;

    PgAltDetayChange(Self);
    TabDemirbasTutanak.Last;

    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DEMIRBAS set DURUM='+IntToStr(DurumGetir(TabDemirbasTutanak.FieldByName('TIP').AsInteger))+S+  //  Tablo.Query1.Fields[0].AsString+
          ' where ID=&Id', ['&Id'],[DEMIRBAS.Fields[0].AsInteger]);

     {   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DEMIRBAS set DURUM='+TabDemirbasTutanak.FieldByName('TIP').AsString+//case when TIP in('+Tablo.Query1.Fields[0].AsString+') then 0 end,'+
            ', LOKASYONID=  '+TabDemirbasTutanak.FieldByName('LOKASYONID').AsString+
            ', ZIMMETLIPERSONELID=0'+TabDemirbasTutanak.FieldByName('ALANID').AsString+
            ' where ID=&Id', ['&Id'],[DEMIRBAS.Fields[0].AsInteger]); }
     TabloYenile(DEMIRBAS,[]);
  end;
end;

procedure TDemirbasListeDlg.ViewKalibrasyonCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=gridKalibrasyon;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=ViewKalibrasyon;
  AnaForm.pmGridStil.Tags.Values[gridKalibrasyon.Name]:='DemirbasKalibrasyonGridi';
end;

procedure TDemirbasListeDlg.AlanYnetimi2Click(Sender: TObject);
begin
  (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).Controller.Customization:=True;
end;

procedure TDemirbasListeDlg.StilDzenle1Click(Sender: TObject);
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

procedure TDemirbasListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TDemirbasListeDlg.PopupHazirla(Durum:integer);
var
   Item : TMenuItem;
   i:smallint;
begin
   Tablo.TablodanSorguAc(0,' select ID=D.KAYNAKDURUM,AKSIYON=G.ANAHTAR from DURUMBAGLANTI D inner join GENINI G on G.BOLUM=-2801 and G.DIL=-1 and G.DEGER=D.HEDEFDURUM '+
                          ' where D.AKTIF=1 and D.YERI=18 and D.BOLUM=-2803 and D.DURUM='+IntToStr(Durum)+' order by 1 desc');

   while i<PopupDemirbasListe.Items.Count do
    if PopupDemirbasListe.Items[i].Tag>=0 then begin
       PopupDemirbasListe.Items[i].Destroy;
       //i:=0;
    end
    else
      inc(i);

   //PopupDemirbasListe.Items.Clear;
   while not Tablo.Query0.Eof do begin
    if not(Tablo.Query0.FieldbyName('ID').AsInteger in [23,25])or  //menü servis değilse ekle
         ((Tablo.Query0.FieldbyName('ID').AsInteger in [23,25])and(DEMIRBAS.FieldByName('SERVIS').AsBoolean)) then  //menü servis ise ve işaretliyse
      begin
        Item := TMenuItem.Create(PopupMenuYaz);
        Item.Caption := Tablo.Query0.FieldbyName('AKSIYON').AsString;
        Item.Tag := Tablo.Query0.FieldbyName('ID').AsInteger;
        Item.Hint := Tablo.Query0.FieldbyName('ID').AsString;
        Item.OnClick := DemirbasDurumDegisClick;
        PopupDemirbasListe.Items.Insert(0, Item);
      end;
    Tablo.Query0.Next;
  end;
  KalibrasyonBilgisiGirMenu.Visible := (KalibrasyonYetkisi)and(DEMIRBAS.FieldByName('KALIBRASYON').AsBoolean);
  TeknikServisAtaMenu.Visible := (TeknikServisYetkisi)and(DEMIRBAS.FieldByName('SERVIS').AsBoolean);
end;

procedure TDemirbasListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TDemirbasListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TDemirbasListeDlg.ResimDosyadanTusClick(Sender: TObject);
var
   i : SmallInt;
begin
   if Tablo.OpenPictureDialog1.Execute then begin
      for i := 0 to Tablo.OpenPictureDialog1.Files.Count-1 do
         ResimEkleme(Tablo.OpenPictureDialog1.Files[i], DEMIRBAS.FieldByName('ID').AsInteger, Tabno_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger);
      //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
      TabloYenile(TabResim, [DEMIRBAS.FieldByName('ID').AsInteger]);
   end;
end;

procedure TDemirbasListeDlg.ResimYapistirTusClick(Sender: TObject);
begin
   ResimYapistir(TcxImage(logoresim), DEMIRBAS.FieldByName('ID').AsInteger, Tabno_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger);
   //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
   TabloYenile(TabResim, [DEMIRBAS.FieldByName('ID').AsInteger]);
end;

procedure TDemirbasListeDlg.PopupDemirbasListePopup(Sender: TObject);
begin
  PopupHazirla(DEMIRBAS.FieldByName('DURUM').AsInteger);
end;

procedure TDemirbasListeDlg.DemirbasInfoMenuClick(Sender: TObject);
begin
  if not DEMIRBAS.IsEmpty then
    Tablo.InfoGoster('DEMIRBAS', DEMIRBAS.FieldByName('ID').AsInteger, TabNo_DEMIRBAS);
end;

procedure TDemirbasListeDlg.TutanakGorTusClick(Sender: TObject);
var
  SonDurum,OncekiDurum:integer;
  i,SeciliDurum,TutanakID,BelgeTipi: integer;
  BelgeTarihi:TDateTime;
  Tutar:Extended;
  s,Kur,HedefDeger,TutarSQL:string;
begin
    try
      Application.CreateForm(TDemirbasDurumDegisDlg,DemirbasDurumDegisDlg);
      //önce hangi ayar satırına karşılık geldiğini bulalım.. yada ilk satır mı???
      DemirbasDurumDegisDlg.SheetDemirbas.Visible := TabDemirbasTutanak.RecordCount>1; //başlangıç satırı değiştirilecek.. burada gride gerek yok..
      DemirbasDurumDegisDlg.SheetDemirbas.TabVisible := TabDemirbasTutanak.RecordCount>1;
      if TabDemirbasTutanak.FieldByName('TARIH').AsFloat <> 0.0 then
        DemirbasDurumDegisDlg.edTarih.Date := TabDemirbasTutanak.FieldByName('TARIH').AsDateTime
      else
        DemirbasDurumDegisDlg.edTarih.Date := Tablo.GENINI.BugunTrhSaat;
      DemirbasDurumDegisDlg.BeditVerenPersonel.Tag := TabDemirbasTutanak.FieldByName('VERENID').AsInteger;
      DemirbasDurumDegisDlg.BeditVerenPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabDemirbasTutanak.FieldByName('VERENID').AsInteger);
      DemirbasDurumDegisDlg.BeditAlanPersonel.Tag := TabDemirbasTutanak.FieldByName('ALANID').AsInteger;
      DemirbasDurumDegisDlg.BeditAlanPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabDemirbasTutanak.FieldByName('ALANID').AsInteger);
      DemirbasDurumDegisDlg.EdBelgeNo.Text := TabDemirbasTutanak.FieldByName('BELGENO').AsString;
      SonDurum := TabDemirbasTutanak.FieldByName('TIP').AsInteger;
      DemirbasDurumDegisDlg.MemoAciklama.Lines.Text := TabDemirbasTutanak.FieldByName('NOTLAR').AsString;
      if TabDemirbasTutanak.FieldByName('LOKASYONID').AsString <> '' then begin
        DemirbasDurumDegisDlg.EditLokasyon.Tag := TabDemirbasTutanak.FieldByName('LOKASYONID').AsInteger;
        DemirbasDurumDegisDlg.EditLokasyon.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',TabDemirbasTutanak.FieldByName('LOKASYONID').AsInteger);
      end;

      if TabDemirbasTutanak.RecordCount>1 then begin
        TabDemirbasTutanak.Prior;
        OncekiDurum := TabDemirbasTutanak.FieldByName('TIP').AsInteger;
        TabDemirbasTutanak.Next;
//        Tablo.TablodanSorguAc(7,'select * from DURUMBAGLANTI where YERI=18 and BOLUM=-2801 and KAYNAKDURUM='+IntToStr(OncekiDurum)+'  and HEDEFDURUM='+IntToStr(SonDurum));
        Tablo.TablodanSorguAc(7,'select * from DURUMBAGLANTI where YERI=18 and BOLUM=-2801 and KAYNAKDURUM='+IntToStr(SonDurum));
        if Tablo.Query7.RecordCount=0 then begin
          Tablo.UyariGoster('Dikkat!','Durum Bağlantılarını Kontrol Ederek İşlemi Tekrar Deneyin.');
          Abort;
        end;
        //ACILIS-Alış Belgesi
        DemirbasDurumDegisDlg.SheetAlisBelgesi.Visible := Tablo.Query7.FieldByName('ACILIS').AsBoolean;
        DemirbasDurumDegisDlg.SheetAlisBelgesi.TabVisible := Tablo.Query7.FieldByName('ACILIS').AsBoolean;
        //KAPANIS-Satış Belgesi
        DemirbasDurumDegisDlg.SheetSatisBelgesi.Visible := Tablo.Query7.FieldByName('KAPANIS').AsBoolean;
        DemirbasDurumDegisDlg.SheetSatisBelgesi.TabVisible := Tablo.Query7.FieldByName('KAPANIS').AsBoolean;
        //OTOKAPAT-Cari Sor
        DemirbasDurumDegisDlg.SheetCariBilgi.Visible := Tablo.Query7.FieldByName('OTOKAPAT').AsBoolean;
        DemirbasDurumDegisDlg.SheetCariBilgi.TabVisible := Tablo.Query7.FieldByName('OTOKAPAT').AsBoolean;
        //TARIHIDESOR-CariPersonelSor
        DemirbasDurumDegisDlg.BeditMusteriIlgili.Visible := Tablo.Query7.FieldByName('TARIHIDESOR').AsBoolean;
        DemirbasDurumDegisDlg.lbMusIlgili.Visible := Tablo.Query7.FieldByName('TARIHIDESOR').AsBoolean;

        if DemirbasDurumDegisDlg.SheetAlisBelgesi.TabVisible then begin
          DemirbasDurumDegisDlg.cbAlBelgeTipi.EditValue := TabDemirbasTutanak.FieldByName('BELGETIPI').AsInteger;
          DemirbasDurumDegisDlg.cbAlBelgeTipi.PostEditValue;
          if TabDemirbasTutanak.FieldByName('BELGETARIH').AsString<>'' then
            DemirbasDurumDegisDlg.DateAlBelge.Date := TabDemirbasTutanak.FieldByName('BELGETARIH').AsDateTime;
          DemirbasDurumDegisDlg.CurAlTutar.EditValue := TabDemirbasTutanak.FieldByName('TUTAR').AsCurrency;
          DemirbasDurumDegisDlg.CurAlTutar.PostEditValue;
          DemirbasDurumDegisDlg.cbAlKur.Text := TabDemirbasTutanak.FieldByName('KUR').AsString;
        end;
        if DemirbasDurumDegisDlg.SheetSatisBelgesi.TabVisible then begin
          DemirbasDurumDegisDlg.cbVerBelgeTipi.EditValue := TabDemirbasTutanak.FieldByName('BELGETIPI').AsInteger;
          DemirbasDurumDegisDlg.cbVerBelgeTipi.PostEditValue;
          DemirbasDurumDegisDlg.DateVerBelge.Date := TabDemirbasTutanak.FieldByName('BELGETARIH').AsDateTime;
          DemirbasDurumDegisDlg.CurVerTutar.EditValue := TabDemirbasTutanak.FieldByName('TUTAR').AsCurrency;
          DemirbasDurumDegisDlg.CurVerTutar.PostEditValue;
          DemirbasDurumDegisDlg.cbVerKur.Text := TabDemirbasTutanak.FieldByName('KUR').AsString;
        end;
        if DemirbasDurumDegisDlg.SheetCariBilgi.TabVisible then begin
          if TabDemirbasTutanak.FieldByName('REHBERID').AsString<>'' then begin
            DemirbasDurumDegisDlg.BeditMusteri.Tag := TabDemirbasTutanak.FieldByName('REHBERID').AsInteger;
            DemirbasDurumDegisDlg.BeditMusteri.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabDemirbasTutanak.FieldByName('REHBERID').AsInteger);
          end;
          if DemirbasDurumDegisDlg.BeditMusteriIlgili.Visible then begin
            if TabDemirbasTutanak.FieldByName('REHBERPERSONELID').AsString<>'' then begin
              DemirbasDurumDegisDlg.BeditMusteriIlgili.Tag := TabDemirbasTutanak.FieldByName('REHBERPERSONELID').AsInteger;
              DemirbasDurumDegisDlg.BeditMusteriIlgili.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabDemirbasTutanak.FieldByName('REHBERPERSONELID').AsInteger);
            end;
          end;
        end;
        //olası durumları içerisine ekleyelim..
        //DemirbasDurumDegisDlg.cbDurum.Properties.Items := Tablo.imgComboboxInit('select HEDEFDURUM,ANAHTAR from DURUMBAGLANTI DB inner join GENINI G on DB.BOLUM=G.BOLUM and DB.HEDEFDURUM=G.DEGER where DB.AKTIF=1 and G.DIL=-1 and DB.BOLUM=-2801 and DB.KAYNAKDURUM='+IntToStr(OncekiDurum)+' order by 1 ').Items;
        //DemirbasDurumDegisDlg.cbDurum.EditValue := SonDurum;
        //DemirbasDurumDegisDlg.cbDurum.PostEditValue;
        DemirbasDurumDegisDlg.Aksiyon := SonDurum;
      end else if TabDemirbasTutanak.RecordCount=1 then begin
        DemirbasDurumDegisDlg.SheetAlisBelgesi.TabVisible := True;
        DemirbasDurumDegisDlg.SheetAlisBelgesi.Visible := True;
        DemirbasDurumDegisDlg.SheetCariBilgi.TabVisible := True;
        DemirbasDurumDegisDlg.SheetCariBilgi.Visible := True;
        if TabDemirbasTutanak.FieldByName('BELGETARIH').AsString<>'' then
          DemirbasDurumDegisDlg.DateAlBelge.Date := TabDemirbasTutanak.FieldByName('BELGETARIH').AsDateTime
        else
          DemirbasDurumDegisDlg.DateAlBelge.Date := Tablo.Genini.Buguntrh;
        DemirbasDurumDegisDlg.SheetSatisBelgesi.TabVisible := False;
        DemirbasDurumDegisDlg.SheetSatisBelgesi.Visible := False;
        //DemirbasDurumDegisDlg.cbDurum.Properties.Items := Tablo.imgComboboxInit('select ID=D.KAYNAKDURUM,AKSIYON=G.ANAHTAR from DURUMBAGLANTI D '+
        //                                                   ' inner join GENINI G on G.BOLUM=-2801 and G.DIL=-1 and G.DEGER=D.HEDEFDURUM '+
        //                                                   ' where D.AKTIF=1 and D.YERI=18 and D.BOLUM=-2801 AND D.KAYNAKDURUM between 11 and 13 order by 1').Items;
        //DemirbasDurumDegisDlg.cbDurum.EditValue := SonDurum;
        DemirbasDurumDegisDlg.Aksiyon := SonDurum;
        //DemirbasDurumDegisDlg.cbDurum.PostEditValue;
        if DemirbasDurumDegisDlg.SheetCariBilgi.TabVisible then begin
          if TabDemirbasTutanak.FieldByName('REHBERID').AsString<>'' then begin
            DemirbasDurumDegisDlg.BeditMusteri.Tag := TabDemirbasTutanak.FieldByName('REHBERID').AsInteger;
            DemirbasDurumDegisDlg.BeditMusteri.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabDemirbasTutanak.FieldByName('REHBERID').AsInteger);
          end;
          if DemirbasDurumDegisDlg.BeditMusteriIlgili.Visible then begin
            if TabDemirbasTutanak.FieldByName('REHBERPERSONELID').AsString<>'' then begin
              DemirbasDurumDegisDlg.BeditMusteriIlgili.Tag := TabDemirbasTutanak.FieldByName('REHBERPERSONELID').AsInteger;
              DemirbasDurumDegisDlg.BeditMusteriIlgili.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabDemirbasTutanak.FieldByName('REHBERPERSONELID').AsInteger);
            end;
          end;
        end;
        if DemirbasDurumDegisDlg.SheetAlisBelgesi.TabVisible then begin
          DemirbasDurumDegisDlg.cbAlBelgeTipi.EditValue := TabDemirbasTutanak.FieldByName('BELGETIPI').AsInteger;
          DemirbasDurumDegisDlg.cbAlBelgeTipi.PostEditValue;
          if TabDemirbasTutanak.FieldByName('BELGETARIH').AsString<>'' then
            DemirbasDurumDegisDlg.DateAlBelge.Date := TabDemirbasTutanak.FieldByName('BELGETARIH').AsDateTime;
          DemirbasDurumDegisDlg.CurAlTutar.EditValue := TabDemirbasTutanak.FieldByName('TUTAR').AsCurrency;
          DemirbasDurumDegisDlg.CurAlTutar.PostEditValue;
          DemirbasDurumDegisDlg.cbAlKur.Text := TabDemirbasTutanak.FieldByName('KUR').AsString;
        end;
      end;
      //////   S H O W M O D A L  ////////////////////
      DemirbasDurumDegisDlg.ShowModal;
      if DemirbasDurumDegisDlg.ModalResult <> MrOk then  begin
        FreeAndNil(DemirbasDurumDegisDlg);
        Abort;
      end;
      if DemirbasDurumDegisDlg.SheetAlisBelgesi.TabVisible then begin
        BelgeTipi:=DemirbasDurumDegisDlg.cbAlBelgeTipi.EditValue;
        BelgeTarihi:=DemirbasDurumDegisDlg.DateAlBelge.Date;
        Tutar:=DemirbasDurumDegisDlg.CurAlTutar.EditValue;
        Kur:=DemirbasDurumDegisDlg.CbAlKur.Text;
      end else if DemirbasDurumDegisDlg.SheetSatisBelgesi.TabVisible then begin
        BelgeTipi:=DemirbasDurumDegisDlg.cbVerBelgeTipi.EditValue;
        BelgeTarihi:=DemirbasDurumDegisDlg.DateVerBelge.Date;
        Tutar:=DemirbasDurumDegisDlg.CurVerTutar.EditValue;
        Kur:=DemirbasDurumDegisDlg.CbVerKur.Text;
      end else begin
        BelgeTipi:=0;
        BelgeTarihi:=Tablo.GENINI.BugunTrh;
        Tutar:=0.0;
        Kur:='';
      end;
      TutarSQL := StringReplace(FormatFloat('0.############', Tutar), ',', '.', [rfReplaceAll]);
      if TutarSQL = '' then
        TutarSQL := '0';
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS_TUTANAK set '
                      +'TIP='+VarToStr(DemirbasDurumDegisDlg.cbDurum.EditValue)+','
                      +'TARIH='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',DemirbasDurumDegisDlg.edTarih.Date)+''','
                      +'VERENID='+IntToStr(DemirbasDurumDegisDlg.BeditVerenPersonel.Tag)+','
                      +'ALANID='+IntToStr(DemirbasDurumDegisDlg.BeditAlanPersonel.Tag)+','
                      +'LOKASYONID='+IntToStr(DemirbasDurumDegisDlg.EditLokasyon.Tag)+','
                      +'BELGENO='''+DemirbasDurumDegisDlg.EdBelgeNo.Text+''','
                      +'DEGISTIREN='+Kullanan+','
                      +'DEGISTIRMETARIHI=GetDate(),'
                      +'SUBEID='+IntToStr(SubeID)+','
                      +'BELGETIPI='+IntToStr(BelgeTipi)+','
                      +'BELGETARIH='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',BelgeTarihi)+''','
                      +'REHBERID='+IntToStr(DemirbasDurumDegisDlg.BeditMusteri.Tag)+','
                      +'TUTAR='+TutarSQL+','
                      +'KUR='''+Kur+''','
                      +'NOTLAR='''+DemirbasDurumDegisDlg.MemoAciklama.Lines.Text+''','
                      +'REHBERPERSONELID='+IntToStr(DemirbasDurumDegisDlg.BeditMusteriIlgili.Tag)
                      +' where ID='+TabDemirbasTutanak.FieldByName('ID').AsString, [],[]);

    //eğer servis ise ve görev atanmışsa onun da silinmesi lazım
      if DemirbasDurumDegisDlg.cbDurum.EditValue = 23 then begin
         Tablo.TablodanSorguAc(1, 'select ID from GOREVLER where YER='+IntToStr(Tabno_Demirbas_Tutanak)+' and YER_ID='+TabDemirbasTutanak.Fields[0].AsString);
         if Tablo.Query1.RecordCount>0 then
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE GOREVYORUM SET YORUM = '''+stringreplace(DemirbasDurumDegisDlg.MemoAciklama.Lines.Text,'''','',[rfReplaceAll])+''' '+
              ' WHERE TUR=1 and GOREVID='+ Tablo.Query1.Fields[0].AsString,[],[]);
      end;


 //     if DEMIRBAS.FieldByName('DURUM').AsString <> VarToStr(DemirbasDurumDegisDlg.cbDurum.EditValue) then begin
//        Tablo.TablodanSorguAc(7,'select * from DURUMBAGLANTI where YERI=18 and BOLUM=-2801 and KAYNAKDURUM='+IntToStr(OncekiDurum)+'  and HEDEFDURUM='+IntToStr(SonDurum));
        //Tablo.TablodanSorguAc(7,'select DURUM from DURUMBAGLANTI where YERI=18 and BOLUM=-2801 and KAYNAKDURUM='+IntToStr(SonDurum));
        Tablo.TablodanSorguAc(8,'select * from DEMIRBAS_TUTANAK_DETAY where TUTANAKID='+TabDemirbasTutanak.FieldByName('ID').AsString);
        Tablo.Query8.First;
        while not Tablo.Query8.Eof do begin
          {if (Tablo.Query7.RecordCount>0)and(Tablo.Query7.FieldByName('HEDEFALANADI').AsString<>'')and(Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString<>'') then begin
            if Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString='@ALANID' then
              HedefDeger  := IntToStr(DemirbasDurumDegisDlg.BeditAlanPersonel.Tag)
            else if Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString='@VERENID' then
              HedefDeger  := IntToStr(DemirbasDurumDegisDlg.BeditVerenPersonel.Tag)
            else
              HedefDeger := Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString;
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DEMIRBAS set DURUM=$Durum,'+Tablo.Query7.FieldByName('HEDEFALANADI').AsString+'='''+HedefDeger+''' where ID=$ID '
                                          ,['$Durum','$ID'],[DemirbasDurumDegisDlg.cbDurum.EditValue,Tablo.Query8.FieldByName('DEMIRBASID').AsInteger]);
          end else begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DEMIRBAS set DURUM=$Durum where ID=$ID '
                                          ,['$Durum','$ID'],[DemirbasDurumDegisDlg.cbDurum.EditValue,Tablo.Query8.FieldByName('DEMIRBASID').AsInteger]);
          end;}

            if DemirbasDurumDegisDlg.cbDurum.EditValue = 21 then  //eğer zimmet aksiyonu silindiyse tablodaki zimmetli adı boşa gelecek
               s:=',REHBERID='+IntToStr(DemirbasDurumDegisDlg.BeditAlanPersonel.Tag)
            else
               s:='';

            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DEMIRBAS set DURUM=$Durum '+s+' where ID=$ID '
                                          ,['$Durum','$ID'],[DurumGetir(SonDurum), Tablo.Query8.FieldByName('DEMIRBASID').AsInteger]);
            Tablo.Query8.Next;
//        end;
      end;
    finally
      JvTimer1Timer(JvTimer1);
      FreeAndNil(DemirbasDurumDegisDlg);
    end;

end;

function TDemirbasListeDlg.DurumGetir(Aksiyon:Integer):Integer;
begin
      if Aksiyon in [24,26] then  //eğer servis iade veya arıza giderildi gibi bir durum varsa arıza servis öncesi duruma geçirmemiz lazım
         Tablo.TablodanSorguAc(6,'select '+DbUst(1)+'DURUM = (select DURUM from DURUMBAGLANTI where YERI=18 and BOLUM=-2801 and KAYNAKDURUM=DT.TIP)'+
                                 ' from DEMIRBAS_TUTANAK DT inner join DEMIRBAS_TUTANAK_DETAY DTD on DT.ID=DTD.TUTANAKID '+
                                 ' where DTD.DEMIRBASID='+Demirbas.FieldByName('ID').AsString+' and (not TIP between 23 and 26)  order by DT.TARIH desc '+DbSinir(1)+')')
      else
         Tablo.TablodanSorguAc(6,'select DURUM from DURUMBAGLANTI where YERI=18 and BOLUM=-2801 and KAYNAKDURUM='+IntToStr(Aksiyon));//TabDemirbasTutanak.FieldByName('TIP').AsString);

      Result := Tablo.Query6.FieldByName('DURUM').AsInteger;
end;

procedure TDemirbasListeDlg.Dzenle1Click(Sender: TObject);
begin
  if TabMasraflar.RecordCount>0 then begin
    Anaform.GormeDialogCagir(TabMasraflar.FieldByName('ID').AsInteger,TabMasraflar.FieldByName('TUR').AsInteger,-99,0,Tablo.GENINI.BugunTrh,'');
    Tabloyenile(TabMasraflar,[DEMIRBAS.FieldByName('ID').AsInteger]);
  end;
end;

procedure TDemirbasListeDlg.DemirbasDurumDegisClick(Sender: TObject);
var
  GorevTuru, i, SeciliDurum, TutanakID, YeniAksiyon, BelgeTipi, ServisAksiyon, MailSablon, ServisSorumluID : integer;
  BelgeTarihi        : TDateTime;
  Tutar              : Extended;
  s, Kur, HedefDeger, TutarSQL : string;

  procedure ServisAksiyonEkle;
  var
    Id : Integer;
    GorevDlg1 : TGorevDlg;
    GrupListe : TStringList;
    i:smallint;
  begin
    Tablo.TablodanSorguAc(0, 'select DEMIRBASADI,D.REHBERID,TEKNIKBILGI, TEKNIKSORUMLU, DT.NOTLAR from DEMIRBAS D '+
                             ' inner join DEMIRBAS_TUTANAK_DETAY DTD on D.ID=DTD.DEMIRBASID '+
                             ' inner join DEMIRBAS_TUTANAK DT on DT.ID=DTD.TUTANAKID '+
                             ' where DTD.TUTANAKID = '+IntToStr(TutanakID));
    case ServisAksiyon of
       1 : begin
             Id := Tablo.GorevOlustur('Arıza Bildirimi/'+Tablo.Query0.FieldByName('DEMIRBASADI').AsString, -999,0, 0, 0, 0,0,0,0, TabNo_DEMIRBAS_TUTANAK, TabDemirbasTutanak.FieldByName('ID').AsInteger, 0, 0);
             //Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', GorevId, AtamaYapildi, YorumYapildi);
             if Tablo.Query0.FieldByName('TEKNIKSORUMLU').AsString<>'' then
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                   ' values('+IntToStr(Id)+',11,'+Tablo.Query0.FieldByName('TEKNIKSORUMLU').AsString+','+Kullanan+')', [],[]);
             if Tablo.Query0.FieldByName('TEKNIKBILGI').AsString<>'' then
                //önce bilgi verilecek kişi sayısı 1 mi yoksa grup mu?
                Tablo.TablodanSorguAc(1,'select GRUP, NOTLAR from REHBER where ID='+Tablo.Query0.FieldByName('TEKNIKBILGI').AsString);
                if Tablo.Query1.Fields[0].AsInteger=335 then //1 kişi ise
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                      ' values('+IntToStr(Id)+',11,'+Tablo.Query0.FieldByName('TEKNIKBILGI').AsString+','+Kullanan+')', [],[])
                else begin
                   GrupListe := TStringList.Create;
                   GrupListe.Delimiter := ',';        // Each list item will be blank separated
                   GrupListe.QuoteChar := ',';        // And each item will be quoted with |'s
                   GrupListe.DelimitedText := Tablo.Query1.FieldByName('NOTLAR').AsString;
                   for i := 0 to GrupListe.Count-1 do
                       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                          ' values('+IntToStr(Id)+',11,'+GrupListe[i]+','+Kullanan+')', [],[]);
                   GrupListe.Free;
                end;

           end;
       2 : if Tablo.Query0.FieldByName('TEKNIKSORUMLU').AsString<>'' then begin
              Id := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec sp_prg_Servis_Yeni 0,'+IntToStr(SubeID)+','+Tablo.Query0.FieldByName('TEKNIKSORUMLU').AsString+', ''Servis İsteği/'+Tablo.Query0.FieldByName('DEMIRBASADI').AsString+''','''+formatdatetime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+'''  ',[],[],true);
              //Tablo.TablodanSorguAc(6,'select top 1 DEGER from GENINI where BOLUM=-3007 order by DEGER'); //ilk durumu alalım
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SERVISID set MUS_ILGILI='+Kullanan+', NOTLAR='''+Tablo.Query0.FieldByName('NOTLAR').AsString+''' where ID='+IntToStr(Id) ,[],[]);
              MailSablon := Tablo.GENINI.ReadInteger(Ops_DemirbasOpsiyon_MailSablon, 0);
              //if MailSablon>0 then
              //   Mail
           end;
      3 : if Tablo.Query0.FieldByName('TEKNIKSORUMLU').AsString<>'' then begin
             //Alıcıları belirleyelim
             Tablo.TablodanSorguAc(9,'SELECT '+Tablo.Query0.FieldByName('TEKNIKSORUMLU').AsString+' union all Select '+Tablo.Query0.FieldByName('TEKNIKBILGI').AsString);
             Tablo.DuyuruYayinla(Tablo.Query9, 'Servis İsteği/'+Tablo.Query0.FieldByName('DEMIRBASADI').AsString, '"'+Tablo.Query0.FieldByName('DEMIRBASADI').AsString+'" adlı demirbaş için '+ DateTimeToStr ( Tablo.GENINI.BugunTrhSaat) + ' tarihinde "'+KullanAdi+'" kullanıcısı tarafından servis talebi gerçekleştirilmiştir.');
           end;
    end;
  end;

begin
  if GridDemirbasview.DataController.GetSelectedCount>0 then begin
     SeciliDurum := -99;
     for i := 0 to GridDemirbasview.DataController.GetRecordCount - 1 do begin
      if (GridDemirbasview.DataController.GetRowIndexByRecordIndex(i,True)>-1)and GridDemirbasview.DataController.IsRowSelected(GridDemirbasview.DataController.GetRowIndexByRecordIndex(i,True)) then begin
        if SeciliDurum=-99 then
          SeciliDurum := GridDemirbasview.DataController.GetValue(i,GridDemirbasViewDURUM.Index)
        else if SeciliDurum <> GridDemirbasview.DataController.GetValue(i,GridDemirbasViewDURUM.Index) then begin
          Tablo.UyariGoster(Uyari,DDDemirbasFarkliDurum);
          Abort;
        end;
      end;
     end;

   if SeciliDurum > -99 then begin
      YeniAksiyon := TMenuItem(Sender).Tag;
      //durum değişikliği için gerekli ayarları alalım..
//      Tablo.TablodanSorguAc(7,'select * from DURUMBAGLANTI where YERI=18 and KAYNAKDURUM='+IntToStr(SeciliDurum)+' and HEDEFDURUM='+IntToStr(YeniAksiyon));
      Tablo.TablodanSorguAc(7,'select * from DURUMBAGLANTI where YERI=18 and BOLUM=-2801 and KAYNAKDURUM='+IntToStr(YeniAksiyon)); //yeni aksiyona göre
      Application.CreateForm(TDemirbasDurumDegisDlg,DemirbasDurumDegisDlg);
      //ACILIS-Alış Belgesi
      DemirbasDurumDegisDlg.SheetAlisBelgesi.Visible := Tablo.Query7.FieldByName('ACILIS').AsBoolean;
      DemirbasDurumDegisDlg.SheetAlisBelgesi.TabVisible := Tablo.Query7.FieldByName('ACILIS').AsBoolean;
      //KAPANIS-Satış Belgesi
      DemirbasDurumDegisDlg.SheetSatisBelgesi.Visible := Tablo.Query7.FieldByName('KAPANIS').AsBoolean;
      DemirbasDurumDegisDlg.SheetSatisBelgesi.TabVisible := Tablo.Query7.FieldByName('KAPANIS').AsBoolean;
      //OTOKAPAT-Cari Sor
      DemirbasDurumDegisDlg.SheetCariBilgi.Visible := Tablo.Query7.FieldByName('OTOKAPAT').AsBoolean;
      DemirbasDurumDegisDlg.SheetCariBilgi.TabVisible := Tablo.Query7.FieldByName('OTOKAPAT').AsBoolean;
      //TARIHIDESOR-CariPersonelSor
      DemirbasDurumDegisDlg.BeditMusteriIlgili.Visible := Tablo.Query7.FieldByName('TARIHIDESOR').AsBoolean;
      DemirbasDurumDegisDlg.lbMusIlgili.Visible := Tablo.Query7.FieldByName('TARIHIDESOR').AsBoolean;

      DemirbasDurumDegisDlg.edTarih.Date := Tablo.GENINI.BugunTrhSaat;
      DemirbasDurumDegisDlg.DateAlBelge.Date := Tablo.GENINI.BugunTrh;
      DemirbasDurumDegisDlg.DateVerBelge.Date := Tablo.GENINI.BugunTrh;
      if YeniAksiyon in [23, 25] then begin
        if GridDemirbasview.DataController.GetSelectedCount>1 then begin
          Tablo.UyariGoster(Uyari,'Arıza / Servis işlemi her bir demirbaş için tek tek yapılmalıdır.',1);
          Abort;
        end;

        ServisSorumluID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select isnull(TEKNIKSORUMLU,0) from DEMIRBAS where ID='+DEMIRBAS.FieldByName('ID').AsString,[],[],True);
        if ServisSorumluID=0 then
          ServisSorumluID := StrToInt(Kullanan);
        DemirbasDurumDegisDlg.BeditAlanPersonel.Tag := ServisSorumluID;
        DemirbasDurumDegisDlg.BeditAlanPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',ServisSorumluID);
      end else begin
        DemirbasDurumDegisDlg.BeditAlanPersonel.Tag := StrToInt(Kullanan);
        DemirbasDurumDegisDlg.BeditAlanPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',StrToInt(Kullanan));
      end;
      Tablo.TablodanSorguAc(5,'select '+DbUst(1)+'ALANID,LOKASYONID from DEMIRBAS_TUTANAK DT inner join DEMIRBAS_TUTANAK_DETAY DTD on DT.ID=DTD.TUTANAKID where DTD.DEMIRBASID='+DEMIRBAS.FieldByName('ID').AsString+' order by DT.ID desc '+DbSinir(1));


      if (Tablo.Query5.RecordCount>0)and(Tablo.Query5.FieldByName('ALANID').AsInteger>0) then begin
        DemirbasDurumDegisDlg.BeditVerenPersonel.Tag := Tablo.Query5.FieldByName('ALANID').AsInteger;
        DemirbasDurumDegisDlg.BeditVerenPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query5.FieldByName('ALANID').AsInteger);
      end else begin
        DemirbasDurumDegisDlg.BeditVerenPersonel.Tag := StrToInt(Kullanan);
        DemirbasDurumDegisDlg.BeditVerenPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',StrToInt(Kullanan));
      end;

      if (Tablo.Query5.FieldByName('LOKASYONID').AsString <> '')and(Tablo.Query5.FieldByName('LOKASYONID').AsInteger > 0) then begin
        DemirbasDurumDegisDlg.EditLokasyon.Tag := Tablo.Query5.FieldByName('LOKASYONID').AsInteger;
        DemirbasDurumDegisDlg.EditLokasyon.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',Tablo.Query5.FieldByName('LOKASYONID').AsInteger);
      end;



      //olası durumları içerisine ekleyelim..
      //DemirbasDurumDegisDlg.cbDurum.Properties.Items := Tablo.imgComboboxInit('select HEDEFDURUM,ANAHTAR from DURUMBAGLANTI DB inner join GENINI G on DB.BOLUM=G.BOLUM and DB.HEDEFDURUM=G.DEGER where DB.AKTIF=1 and G.DIL=-1 and DB.BOLUM=-2801 and DB.KAYNAKDURUM='+IntToStr(SeciliDurum)+' order by 1 ').Items;
      //DemirbasDurumDegisDlg.cbDurum.EditValue := YeniAksiyon;
      //DemirbasDurumDegisDlg.cbDurum.PostEditValue;
      DemirbasDurumDegisDlg.Aksiyon := YeniAksiyon;

      DemirbasDurumDegisDlg.ShowModal;
      if DemirbasDurumDegisDlg.ModalResult <> MrOk then  begin
        FreeAndNil(DemirbasDurumDegisDlg);
        Abort;
      end;
      if DemirbasDurumDegisDlg.SheetAlisBelgesi.TabVisible then begin
        BelgeTipi:=DemirbasDurumDegisDlg.cbAlBelgeTipi.EditValue;
        BelgeTarihi:=DemirbasDurumDegisDlg.DateAlBelge.Date;
        Tutar:=DemirbasDurumDegisDlg.CurAlTutar.EditValue;
        Kur:=DemirbasDurumDegisDlg.CbAlKur.Text;
      end else if DemirbasDurumDegisDlg.SheetSatisBelgesi.TabVisible then begin
        BelgeTipi:=DemirbasDurumDegisDlg.cbVerBelgeTipi.EditValue;
        BelgeTarihi:=DemirbasDurumDegisDlg.DateVerBelge.Date;
        Tutar:=DemirbasDurumDegisDlg.CurVerTutar.EditValue;
        Kur:=DemirbasDurumDegisDlg.CbVerKur.Text;
      end else begin
        BelgeTipi:=0;
        BelgeTarihi:=Tablo.GENINI.BugunTrh;
        Tutar:=0.0;
        Kur:='';
      end;

      TutarSQL := StringReplace(FormatFloat('0.############', Tutar), ',', '.', [rfReplaceAll]);
      if TutarSQL = '' then
        TutarSQL := '0';

      TutanakID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into DEMIRBAS_TUTANAK (TIP,TARIH,VERENID,ALANID,LOKASYONID,BELGENO,EKLEYEN,SUBEID,BELGETIPI,BELGETARIH,REHBERID,TUTAR,KUR,NOTLAR,REHBERPERSONELID)values('
                      +VarToStr(DemirbasDurumDegisDlg.cbDurum.EditValue)
                      +','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',DemirbasDurumDegisDlg.edTarih.Date)+''','
                      +IntToStr(DemirbasDurumDegisDlg.BeditVerenPersonel.Tag)+','
                      +IntToStr(DemirbasDurumDegisDlg.BeditAlanPersonel.Tag)+','
                      +IntToStr(DemirbasDurumDegisDlg.EditLokasyon.Tag)+','''
                      +DemirbasDurumDegisDlg.EdBelgeNo.Text+''','
                      +Kullanan+','
                      +IntToStr(SubeID)+','
                      +IntToStr(BelgeTipi)+','
                      +''''+FormatDateTime('yyyy-mm-dd hh:nn:ss',BelgeTarihi)+''','
                      +IntToStr(DemirbasDurumDegisDlg.BeditMusteri.Tag)+','
                      +TutarSQL+','
                      +''''+Kur+''','
                      +''''+DemirbasDurumDegisDlg.MemoAciklama.Lines.Text+''','
                      +IntToStr(DemirbasDurumDegisDlg.BeditMusteriIlgili.Tag)
                      +') SELECT SCOPE_IDENTITY() ', [],[],True);


      for i := 0 to GridDemirbasview.DataController.GetRecordCount - 1 do begin
        s:='';
        //eğer zimmet aksiyonu girildiyse tablodaki zimmetli adı gelecek
        if YeniAksiyon = 21 then
           s:=',REHBERID='+IntToStr(DemirbasDurumDegisDlg.BeditAlanPersonel.Tag) //zimmeti alan
        else
        if YeniAksiyon = 22 then
           s:=',REHBERID=0';         //zimmet iade


        if (GridDemirbasview.DataController.GetRowIndexByRecordIndex(i,True)>-1)and GridDemirbasview.DataController.IsRowSelected(GridDemirbasview.DataController.GetRowIndexByRecordIndex(i,True)) then begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DEMIRBAS_TUTANAK_DETAY (TUTANAKID,DEMIRBASID)values('+IntToStr(TutanakID)+','+VarToStr(GridDemirbasview.DataController.GetValue(i,GridDemirbasViewID.Index))+')',[],[]);
            if (Tablo.Query7.FieldByName('HEDEFALANADI').AsString<>'')and(Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString<>'') then begin
                if Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString = '@ALANID' then
                   HedefDeger  := IntToStr(DemirbasDurumDegisDlg.BeditAlanPersonel.Tag)
                else if Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString = '@VERENID' then
                   HedefDeger  := IntToStr(DemirbasDurumDegisDlg.BeditVerenPersonel.Tag)
                else
                   HedefDeger := Tablo.Query7.FieldByName('HEDEFALANDEGERI').AsString;
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DEMIRBAS set DURUM=$Durum'+s+','+Tablo.Query7.FieldByName('HEDEFALANADI').AsString+'='''+HedefDeger+''' where ID=$ID '
                                          ,['$Durum','$ID'],[DurumGetir(YeniAksiyon),GridDemirbasview.DataController.GetValue(i,GridDemirbasViewID.Index)]);
            end else begin
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DEMIRBAS set DURUM=$Durum '+s+' where ID=$ID '
                                          ,['$Durum','$ID'],[DurumGetir(YeniAksiyon),GridDemirbasview.DataController.GetValue(i,GridDemirbasViewID.Index)]);
          end;
        end;
      end;
      if YeniAksiyon = 25 then begin//23 servis / 25 arıza ise
          //Eğer opsiyonlarda servise gönderildikten sonra aksiyon seçimi varsa iş listesi, servis kartı vb.
          ServisAksiyon := Tablo.GENINI.ReadInteger(Ops_OpsiyonDemirbas_OlusacakAksiyon, 0);
          //ServisAksiyon 0:yok  1:iş listesi  2:servis  3:duyuru
          if ServisAksiyon>0 then
             ServisAksiyonEkle;
//serkan
          Tablo.TablodanSorguAc(1, 'select isnull(TEKNIKBILGI,0) from DEMIRBAS where ID='+DEMIRBAS.FieldByName('ID').AsString);
          GorevTuru := Tablo.GENINI.ReadInteger(Ops_DemirbasOpsiyon_GorevTuru, 0);

          i := Tablo.GorevOlustur(Demirbas.FieldByName('DEMIRBASADI').AsString, DemirbasKlasor,0,0,  0, 0, DemirbasDurumDegisDlg.BeditAlanPersonel.Tag,
                 0, GorevTuru, TabNo_DEMIRBAS_TUTANAK, TutanakID, Tablo.Genini.buguntrhsaat, Tablo.Genini.buguntrhsaat, Tablo.Query1.Fields[0].AsInteger);
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO GOREVYORUM([GOREVID],[TUR],[YORUM],[EKLEYEN])VALUES('+IntToStr(i)+',1,'''+
                  stringreplace(DemirbasDurumDegisDlg.MemoAciklama.Lines.Text,'''','',[rfReplaceAll])+''','+Kullanan+')',[],[]);
          Gorev_EPostaGonder(1,i, False)
      end;
      FreeAndNil(DemirbasDurumDegisDlg);
      JvTimer1Timer(JvTimer1);
    end;
  end;
end;

procedure TDemirbasListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TDemirbasListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
      Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
      Tabloyenile(TabYorum,[Tabno_Demirbas, DEMIRBAS.FieldByName('ID').AsInteger]);
  end;
end;

procedure TDemirbasListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin
   FFrameBilgi.Git;
   TabloYenile(DEMIRBAS,[]);
end;

procedure TDemirbasListeDlg.YeniTusClick(Sender: TObject);
var DID:integer;
begin
  DID := Tablo.DemirbasSihirbazBaslat('E',0,-1,11);
  if DID > 0 then begin
    Tablo.AramaKaydet(MODUL_Demirbas, DID);   // yeni demirbas -> Son Aranan
    Liste_SP_Cagir(5);                         // Son Aranan (en yeni ustte)
    DEMIRBAS.Locate('ID', DID, []);
    if PgAltDetay.ActivePage <> TabSheetHareketler then
      PgAltDetay.ActivePage := TabSheetHareketler;
    PgAltDetayChange(PgAltDetay);
    TutanakGorTusClick(TutanakGorTus);
  end;
end;

procedure TDemirbasListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Demirbas);
end;

procedure TDemirbasListeDlg.SetArama(const Value: TDemirbasAramaFrame);
begin
  FArama := Value;
  with FArama do
  begin
    YenileTus.Click;
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz. }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TDemirbasListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDemirbasListeDlg.Sil1Click(Sender: TObject);
begin
  if TabMasraflar.RecordCount>0 then
    if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Tablo.KasaSilmeIslemleri(TabMasraflar.FieldByName('ID').AsInteger,TabMasraflar.FieldByName('TUR').AsInteger);
      Tabloyenile(TabMasraflar,[DEMIRBAS.FieldByName('ID').AsInteger]);
    end;
end;

procedure TDemirbasListeDlg.SilTakipTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) <> IDYES then
    Abort;
end;

procedure TDemirbasListeDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
  begin
    // varsa dokümanların silinmeli
    Tablo.TablodanSorguAc(1, ' Select count(*) from DEMIRBAS_TUTANAK_DETAY where DEMIRBASID='+DEMIRBAS.FieldByName('ID').AsString);
    if Tablo.Query1.Fields[0].AsInteger > 1 then  begin
      Application.MessageBox(PChar(DDTutanakHareketGormusSilinemez),PChar(Uyari), 0);
      Abort;
    end else if Veritabani.VeriVarMi(Tablo.FDCnn, ' Select ID from GOREVYORUM where TUR='+IntToStr(Tabno_Demirbas)+' and GOREVID=&id ', ['&id'], [DEMIRBAS.FieldByName('ID').AsInteger]) then  begin
      Application.MessageBox(PChar(DDYorumMedyaHareketGormusSilinemez),PChar(Uyari), 0);
      Abort;
    end else if Veritabani.VeriVarMi(Tablo.FDCnn, ' Select DEMIRBASID from KALIBRASYON where DEMIRBASID=&id ', ['&id'], [DEMIRBAS.FieldByName('ID').AsInteger]) then  begin
      Application.MessageBox(PChar(DDKalibrasyonHareketGormusSilinemez),PChar(Uyari), 0);
      Abort;
    end else if Veritabani.VeriVarMi(Tablo.FDCnn, ' Select ID from GOREVLER where YER='+IntToStr(Tabno_Demirbas)+' and YER_ID=&id ', ['&id'], [DEMIRBAS.FieldByName('ID').AsInteger]) then  begin
      Application.MessageBox(PChar(DDTakipHareketGormusSilinemez),PChar(Uyari), 0);
      Abort;
    end;
    Tabloyenile(TabMasraflar,[DEMIRBAS.FieldByName('ID').AsInteger]);
    if TabMasraflar.Recordcount >0 then  begin
      Application.MessageBox(PChar(DDmasrafHareketGormusSilinemez),PChar(Uyari), 0);
      Abort;
    end else begin
      Tablo.TablodanSorguAc(1,'Select * from DEMIRBAS_TUTANAK_DETAY where DEMIRBASID='+DEMIRBAS.FieldByName('ID').AsString+' ');
      if Tablo.Query1.RecordCount>0 then begin
        while not Tablo.Query1.Eof do begin
          // Master tutanak'i (DEMIRBAS_TUTANAK, ID'li) SILMEDEN ONCE logla -> Geri Al ile dirilir.
          LogKayitSil('DEMIRBAS_TUTANAK', TabNo_DEMIRBAS_TUTANAK_KART, Tablo.Query1.FieldByName('TUTANAKID').AsInteger, TabNo_DEMIRBAS, DEMIRBAS.FieldByName('ID').AsInteger);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DEMIRBAS_TUTANAK where ID=&id ', ['&id'], [Tablo.Query1.FieldByName('TUTANAKID').AsInteger]);
          Tablo.Query1.Next;
        end;
      end;
      // KART LOGU: SILMEDEN ONCE ve TABLODAN. Liste dataset'i sp_Prog_Demirbas_Liste_Json2
      //   kolonlarini tasiyor (ZIMMETLIADI/KATEGORIADI/MODELAD...) -> dataset'ten loglanirsa
      //   gercek DEMIRBAS kolonlari loga girmez, "Geri Al" kaydi EKSIK dirilir.
      LogKayitSil('DEMIRBAS', TabNo_DEMIRBAS, DEMIRBAS.FieldByName('ID').AsInteger,
                  TabNo_DEMIRBAS, DEMIRBAS.FieldByName('ID').AsInteger);
      // KART FOTOGRAFI (DEMIRBAS.RESIM blob) - log JSON'u blob'lari dislar, ayrica yedekle.
      LogBlobYedekle('DEMIRBAS', 'RESIM', DEMIRBAS.FieldByName('ID').AsInteger,
                     TabNo_DEMIRBAS, DEMIRBAS.FieldByName('ID').AsInteger);
      // Detay satirlarini SILMEDEN ONCE logla (ust=demirbas), sonra sil.
      LogDetaylariSil('DEMIRBAS_TUTANAK_DETAY', 'DEMIRBASID', TabNo_DEMIRBAS_TUTANAK, TabNo_DEMIRBAS, DEMIRBAS.FieldByName('ID').AsInteger);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DEMIRBAS_TUTANAK_DETAY where DEMIRBASID=&id ', ['&id'], [DEMIRBAS.FieldByName('ID').AsInteger]);
      // _USER (ek alan) satirini SILMEDEN ONCE logla, sonra sil (FK: kart silinmeden once _USER).
      LogDetaylariSil('DEMIRBAS_USER', 'ID', TabNo_DEMIRBAS_USER, TabNo_DEMIRBAS, DEMIRBAS.FieldByName('ID').AsInteger);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DEMIRBAS_USER where ID=&id ', ['&id'], [DEMIRBAS.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DEMIRBAS where ID=&id ', ['&id'], [DEMIRBAS.FieldByName('ID').AsInteger]);
     // Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM DEMIRBASTAKIP WHERE DEMIRBASID=&DEMIRBASID',['&DEMIRBASID'],[DEMIRBAS.FieldByName('ID').AsString])
    end;
    // NOT: kart silme logu YUKARIDA (silmeden once, tablodan) yazildi.
    YenileTusClick(Self);
    /// SQL2005 TE hataya neden olduğu için delete olayını kendimiz yapıyoruz
    Abort;
  end;
end;

procedure TDemirbasListeDlg.DEMIRBASAfterOpen(DataSet: TDataSet);
begin
  if DegisTus.Tag=0 then begin
     DegisTus.Visible := DEMIRBAS.RecordCount > 0;
     SilTus.Visible := DegisTus.Visible;
  end;
end;

procedure TDemirbasListeDlg.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TDemirbasListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDemirbasListeDlg.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TDemirbasListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TDemirbasListeDlg.TabDemirbaslarRefresh;
begin
  TabloYenile(DEMIRBAS,[]);
end;

procedure TDemirbasListeDlg.TabDemirbasTutanakAfterScroll(DataSet: TDataSet);
begin
  TabDemirbasTutanak.FetchAll;
  TutanakGorTus.Enabled := (TabDemirbasTutanak.RecordCount>0) and (TabDemirbasTutanak.RecordCount=TabDemirbasTutanak.RecNo);
  TutanakSilTus.Enabled := (TabDemirbasTutanak.RecordCount>1) and (TabDemirbasTutanak.RecordCount=TabDemirbasTutanak.RecNo);
end;

procedure TDemirbasListeDlg.TabMasraflarAfterOpen(DataSet: TDataSet);
begin
  MasrafGridView.ApplyBestFit();
end;

function TDemirbasListeDlg.TakipBoslukKontrol : Boolean;
Begin
End;

initialization

RegisterClass(TDemirbasListeDlg);

end.







unit URehAraDlg;

interface

uses
  SysUtils,   WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, DBGrids, Grids, ExtCtrls, dxCore,
  Dialogs, Buttons, Mask, Menus, IniFiles, ComCtrls, FireDAC.Comp.Client, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData,
  cxTextEdit, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, OfficePopupMenu,
  cxControls, cxGridCustomView, cxClasses, cxGridLevel, cxGrid, ToolWin, cxPCdxBarPopupMenu,
  cxMaskEdit, cxDropDownEdit, cxContainer, UGentegreFrameYonetimi, UMultiCastEvent,
  URehberAramaFrame, dxSkinsCore, dxSkinscxPCPainter,UFrameYoneticisi, cxCheckBox,
  cxImageComboBox, cxMemo, cxButtonEdit, cxTimeEdit, cxCurrencyEdit,Variants,
  cxLookAndFeelPainters, cxGroupBox, cxImage, cxLabel, cxButtons, cxPC,ComObj,
  cxSplitter, frxClass, frxDBSet, cxGridCustomPopupMenu, cxGridPopupMenu, cxNavigator,
  cxCalendar, dxSkinLondonLiquidSky,Utablo,DateUtils, cxRadioGroup, cxLookAndFeels,
  JvComponentBase, JvDragDrop, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer,
  cxTLData, cxDBTL, cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, JvTimer, cxSpinEdit,
  cxDateUtils, JvExControls, JvNavigationPane, UCariDurumDetay, URehberHareket,
  dxBarBuiltInMenu, dxGDIPlusClasses, dxSkinLiquidSky, System.Generics.Collections,
  cxGridCustomLayoutView, cxDBEdit, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, JvExExtCtrls, JvExtComponent, JvPanel,
  frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, dxCoreGraphics, System.JSON;

type
  TRehberAraDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog )
    REHBER: TFDQuery;
    KartiKopyalaMenu: TMenuItem;   // 'Kartı Kopyala' (klon API'si)
    CariGrid: TcxGrid;
    CariGridLevel1: TcxGridLevel;
    CariGridView: TcxGridDBTableView;
    CariGridViewKOD1: TcxGridDBColumn;
    CariGridViewFIRMA1: TcxGridDBColumn;
    CariGridViewBORC: TcxGridDBColumn;
    CariGridViewALACAK: TcxGridDBColumn;
    CariGridViewBAKIYE: TcxGridDBColumn;
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
    CariGridViewGRUP: TcxGridDBColumn;
    CariGridViewID: TcxGridDBColumn;
    CariGridViewKATEGORI: TcxGridDBColumn;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    CariGridViewDURUM: TcxGridDBColumn;
    SQLMemo: TcxMemo;
    CariGridViewSINIF: TcxGridDBColumn;
    CariGridViewADSOYAD: TcxGridDBColumn;
    TabTicari: TFDQuery;
    DtsTicari: TDataSource;
    TabFirIletisim: TFDQuery;
    TabRehberIlgili: TFDQuery;
    TabRehberOdeme: TFDQuery;
    TabPerIletisim: TFDQuery;
    TabProjeler: TFDQuery;
    TabBankaHesaplar: TFDQuery;
    DtsRehberIlgili: TDataSource;
    DtsBankaHesaplar: TDataSource;
    DtsPerIletisim: TDataSource;
    DtsRehberOdeme: TDataSource;
    DtsProjeler: TDataSource;
    DtsRehber: TDataSource;
    frxSozlesme: TfrxDBDataset;
    frxGorusme: TfrxDBDataset;
    frxIlgili: TfrxDBDataset;
    frxREHBER: TfrxDBDataset;
    frxBanka: TfrxDBDataset;
    frxSozBelge: TfrxDBDataset;
    TabUcret: TFDQuery;
    DtsUcret: TDataSource;
    cxSplitter1: TcxSplitter;
    DtsFirIletisim: TDataSource;
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
    frxEkstre: TfrxDBDataset;
    cxGridPopupMenu1: TcxGridPopupMenu;
    AksiyonEkleTus: TToolButton;
    TabCariListe: TFDQuery;
    DtsCariListe: TDataSource;
    SilTus: TToolButton;
    ToolButton9: TToolButton;
    PopupMenuREHBER: TPopupMenu;
    EkleMenu: TMenuItem;
    SilMenu: TMenuItem;
    GorMenu: TMenuItem;
    MenuItem1: TMenuItem;
    N18: TMenuItem;
    AcilisiFisiMenu: TMenuItem;
    DevirFisiMenu: TMenuItem;
    SQLMemoBA: TcxMemo;
    PopupMenuYeni: TPopupMenu;
    AlisBelgesiMenu: TMenuItem;
    Fatura1: TMenuItem;
    Fi1: TMenuItem;
    rsaliye1: TMenuItem;
    SatisBelgesiMenu: TMenuItem;
    Fatura2: TMenuItem;
    Fi2: TMenuItem;
    rsaliye2: TMenuItem;
    MenuItem4: TMenuItem;
    CariTahsilatMenu: TMenuItem;
    Nakit1: TMenuItem;
    HavaleEFT1: TMenuItem;
    POSTahsilMenu: TMenuItem;
    CekTahsilMenu: TMenuItem;
    SenetTahsilMenu: TMenuItem;
    CariOdemeMenu: TMenuItem;
    Nakit2: TMenuItem;
    HavaleEFT2: TMenuItem;
    KrediKartiOdeMenu: TMenuItem;
    CekOdeMenu: TMenuItem;
    SenetOdeMenu: TMenuItem;
    MenuItem2: TMenuItem;
    TahsilatPlanMenu: TMenuItem;
    OdemePlanMenu: TMenuItem;
    N5: TMenuItem;
    ahakkuk1: TMenuItem;
    N6: TMenuItem;
    ahakkuk2: TMenuItem;
    ToolButton2: TToolButton;
    PageControlSekme: TcxPageControl;
    TabSheetIlet: TcxTabSheet;
    ToolBar10: TToolBar;
    TabSheetIlgili: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGridPersoneller: TcxGridDBTableView;
    PersonelVARSAYILAN: TcxGridDBColumn;
    PersonelAdi: TcxGridDBColumn;
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
    TabSheetTicari: TcxTabSheet;
    TabSheetProje: TcxTabSheet;
    GridCariProjeler: TcxGrid;
    GridCariProjelerView: TcxGridDBTableView;
    GridCariProjelerViewBASTARIHI: TcxGridDBColumn;
    GridCariProjelerViewKONUSU: TcxGridDBColumn;
    GridCariProjelerViewTURU: TcxGridDBColumn;
    GridCariProjelerViewDURUM: TcxGridDBColumn;
    GridCariProjelerViewASAMA: TcxGridDBColumn;
    GridCariProjelerViewLISTEKUR: TcxGridDBColumn;
    GridCariProjelerViewSATISFIYATI: TcxGridDBColumn;
    GridCariProjelerViewSATISKUR: TcxGridDBColumn;
    GridCariProjelerViewNOTLAR: TcxGridDBColumn;
    GridCariProjelerViewBITTARIHI: TcxGridDBColumn;
    GridCariProjelerDBTableView1: TcxGridDBTableView;
    GridCariProjelerDBTableView1TUR: TcxGridDBColumn;
    GridCariProjelerDBTableView1BELGEADI: TcxGridDBColumn;
    GridCariProjelerLevel1: TcxGridLevel;
    TabSheetEkstre: TcxTabSheet;
    GridCariEkstre: TcxGrid;
    GridCariEkstreView: TcxGridDBTableView;
    GridCariEkstreViewTARIH: TcxGridDBColumn;
    GridCariEkstreViewAKSIYONTARIH: TcxGridDBColumn;
    GridCariEkstreViewNO: TcxGridDBColumn;
    GridCariEkstreViewKOD: TcxGridDBColumn;
    GridCariEkstreViewAD: TcxGridDBColumn;
    GridCariEkstreViewACIKLAMA: TcxGridDBColumn;
    GridCariEkstreViewHESAPKODU: TcxGridDBColumn;
    GridCariEkstreViewHESAPADI: TcxGridDBColumn;
    GridCariEkstreViewBORC: TcxGridDBColumn;
    GridCariEkstreViewALACAK: TcxGridDBColumn;
    GridCariEkstreViewBORCBAKIYE: TcxGridDBColumn;
    GridCariEkstreViewALACAKBAKIYE: TcxGridDBColumn;
    GridCariEkstreViewKUR: TcxGridDBColumn;
    GridCariEkstreDBTableView1: TcxGridDBTableView;
    GridCariEkstreDBTableView1DURUM: TcxGridDBColumn;
    GridCariEkstreDBTableView1VADE: TcxGridDBColumn;
    GridCariEkstreDBTableView1SERINO: TcxGridDBColumn;
    GridCariEkstreDBTableView1HESAPADI: TcxGridDBColumn;
    GridCariEkstreDBTableView1Column1: TcxGridDBColumn;
    GridCariEkstreLevel1: TcxGridLevel;
    TabDemirbasBilgi: TFDQuery;
    DtsDemirbasBilgi: TDataSource;
    PMAksiyonlarMenu: TPopupMenu;
    Sil1: TMenuItem;
    AksiyonBilgisiniGorMenu: TMenuItem;
    N4: TMenuItem;
    AcilisFisiGirMenu: TMenuItem;
    YaziciYaz: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    CariGridViewKUR: TcxGridDBColumn;
    GridCariEkstreViewMASRAFKOD: TcxGridDBColumn;
    GridCariEkstreViewMASRAFAD: TcxGridDBColumn;
    MemoProjeler: TMemo;
    CariGridViewSONAKTIVITEKONUSU: TcxGridDBColumn;
    CariGridViewSONAKTIVITETARIHI: TcxGridDBColumn;
    TabSheetYaslandirma: TcxTabSheet;
    TabYaslandirma: TFDQuery;
    DtsYaslandirma: TDataSource;
    GridYaslandir: TcxGrid;
    GridYaslandirView: TcxGridDBTableView;
    cxGridDBTableView3: TcxGridDBTableView;
    cxGridDBColumn28: TcxGridDBColumn;
    cxGridDBColumn29: TcxGridDBColumn;
    cxGridDBColumn30: TcxGridDBColumn;
    cxGridDBColumn31: TcxGridDBColumn;
    cxGridDBColumn32: TcxGridDBColumn;
    cxGridLevel10: TcxGridLevel;
    Panel1: TPanel;
    CariGridViewYASLANDIRMA: TcxGridDBColumn;
    CariGridViewNOTLAR: TcxGridDBColumn;
    Sipari1: TMenuItem;
    Sipari2: TMenuItem;
    PopupIlgililer: TPopupMenu;
    lgiliyiKopyala1: TMenuItem;
    PmProjeAktKopyala: TPopupMenu;
    Kopyala1: TMenuItem;
    TabSheetTeklifler: TcxTabSheet;
    ToolBar12: TToolBar;
    TeklifEkle: TToolButton;
    TeklifSil: TToolButton;
    ToolButton12: TToolButton;
    TeklifDuzenle: TToolButton;
    GridTeklif: TcxGrid;
    GridTeklifView: TcxGridDBTableView;
    GridTeklifLevel1: TcxGridLevel;
    TabTeklifler: TFDQuery;
    DtsTeklifler: TDataSource;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    Varsaylan1: TMenuItem;
    N7: TMenuItem;
    GridCariProjelerViewPROJEKODU: TcxGridDBColumn;
    TabEkipmanlar: TFDQuery;
    DtsEkipmanlar: TDataSource;
    CariGridViewILLER: TcxGridDBColumn;
    N8: TMenuItem;
    ifreOlutur1: TMenuItem;
    GridCariProjelerViewLISTEFIYATI: TcxGridDBColumn;
    N9: TMenuItem;
    Kopyala2: TMenuItem;
    DtsEkipmanEkBilgi: TDataSource;
    TabEkipmanEkBilgi: TFDQuery;
    CariGridViewSONSATBELGETARIHI: TcxGridDBColumn;
    CariGridViewSONSATTUTARI: TcxGridDBColumn;
    lgiliKurumdanAyrld1: TMenuItem;
    PersonelNEREDE: TcxGridDBColumn;
    DurumuSfrla1: TMenuItem;
    CariGridViewTEMSILCIAD: TcxGridDBColumn;
    CariGridViewOZELKOD: TcxGridDBColumn;
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
    REHBERILETISIM: TFDQuery;
    DtsRehberIletisim: TDataSource;
    PopupIletisim: TPopupMenu;
    iletisimEkle: TToolButton;
    iletisimSil: TToolButton;
    ToolButton14: TToolButton;
    iletisimDuzenle: TToolButton;
    VarsaylanYap1: TMenuItem;
    N10: TMenuItem;
    letiimaddeitir1: TMenuItem;
    CariGridViewSUBEID: TcxGridDBColumn;
    CariGridViewVADE: TcxGridDBColumn;
    CariGridViewFARK: TcxGridDBColumn;
    BtnCRM: TToolButton;
    N12: TMenuItem;
    ExceldenAksiyonAktar1: TMenuItem;
    N13: TMenuItem;
    DtsSmsEPosta: TDataSource;
    TabSmsEPosta: TFDQuery;
    GridCariEkstreViewBASLIK: TcxGridDBColumn;
    ExcelKolonAyarlar1: TMenuItem;
    N19: TMenuItem;
    GridCariEkstreViewColumn1: TcxGridDBColumn;
    GridCariEkstreViewTUR: TcxGridDBColumn;
    N14: TMenuItem;
    iadeAl: TMenuItem;
    Faturaile1: TMenuItem;
    GiderPusulasile1: TMenuItem;
    CariGridViewBOLGE: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    frxPersonelIzin: TfrxDBDataset;
    BorcAlacakKapamaMenu: TMenuItem;
    Panel6: TPanel;
    ToolBar4: TToolBar;
    ProjeEkleTus: TToolButton;
    ProjeSilTus: TToolButton;
    ToolButton7: TToolButton;
    ProjeDuzenle: TToolButton;
    JvNavPanelHeader2: TJvNavPanelHeader;
    checkKapaliProjeGoster: TcxCheckBox;
    Panel8: TPanel;
    ToolBar11: TToolBar;
    EkstreSilTus: TToolButton;
    EkstreDegisTus: TToolButton;
    ToolButton1: TToolButton;
    JvNavPanelHeader4: TJvNavPanelHeader;
    Label1: TcxLabel;
    CalendarEkstreBas: TcxDateEdit;
    Label2: TcxLabel;
    CalendarEkstreBit: TcxDateEdit;
    CheckDetayli: TcxCheckBox;
    Panel9: TPanel;
    ToolBar2: TToolBar;
    IlgiliEkleTus: TToolButton;
    IlgiliSilTus: TToolButton;
    ToolButton6: TToolButton;
    IlgiliDuzenleTus: TToolButton;
    JvNavPanelHeader5: TJvNavPanelHeader;
    IlgiliAraEdit: TcxTextEdit;
    cxLabel3: TcxLabel;
    GridCariEkstreViewColumn2: TcxGridDBColumn;
    GridCariEkstreViewCEKID: TcxGridDBColumn;
    Dier1: TMenuItem;
    Dier2: TMenuItem;
    Hediyeeki1: TMenuItem;
    adeeki1: TMenuItem;
    Kupon1: TMenuItem;
    Hediyeeki2: TMenuItem;
    adeeki2: TMenuItem;
    Kupon2: TMenuItem;
    PopupMenuEkipman: TPopupMenu;
    EkimanKopyalaMenu: TMenuItem;
    BaskacariyekopyalaMenu: TMenuItem;
    N16: TMenuItem;
    DtsHareketler: TDataSource;
    TabHareketler: TFDQuery;
    TabKesinti: TFDQuery;
    DtsKesinti: TDataSource;
    GridCariEkstreViewADET: TcxGridDBColumn;
    GridCariEkstreViewBIRIM: TcxGridDBColumn;
    GridCariEkstreViewBIRIMFIYAT: TcxGridDBColumn;
    GridCariProjelerViewPROJEADI: TcxGridDBColumn;
    GridCariEkstreViewYERELTUTAR: TcxGridDBColumn;
    GridCariEkstreViewYERELBAKIYE: TcxGridDBColumn;
    GridCariEkstreViewYERELKUR: TcxGridDBColumn;
    POSOdeMenu: TMenuItem;
    CheckPlan: TcxCheckBox;
    MasrafOdemeMenu: TMenuItem;
    MasrafNakitMenu: TMenuItem;
    HavaleEFT4: TMenuItem;
    KrediKart1: TMenuItem;
    GelirTahsilatMenu: TMenuItem;
    Nakit5: TMenuItem;
    HavaleEFT5: TMenuItem;
    N15: TMenuItem;
    FaturaAlisMenu: TMenuItem;
    ade1: TMenuItem;
    FiyatFark1: TMenuItem;
    SerbestMeslekMekabuzu1: TMenuItem;
    AlisCizgiMenu: TMenuItem;
    AlisEFaturaMenu: TMenuItem;
    FaturaSatisMenu: TMenuItem;
    ade2: TMenuItem;
    FiyatFark2: TMenuItem;
    SatisCizgiMenu: TMenuItem;
    SatisEFaturaMenu: TMenuItem;
    KurFarkGeliri1: TMenuItem;
    KurFarkGideri1: TMenuItem;
    KurFark1: TMenuItem;
    KurFark2: TMenuItem;
    CariGridViewSEKTOR: TcxGridDBColumn;
    CariGridViewALTBOLGE: TcxGridDBColumn;
    CariGridViewYETKIKODU: TcxGridDBColumn;
    CariGridViewMUHKODU: TcxGridDBColumn;
    CariGridViewILCE: TcxGridDBColumn;
    TabSheetCRM: TcxTabSheet;
    PageControlCRM: TcxPageControl;
    TabSheetServisAna: TcxTabSheet;
    PageControlServis: TcxPageControl;
    TabSheetServisListe: TcxTabSheet;
    GridCariServis: TcxGrid;
    GridCariServisView: TcxGridDBTableView;
    GridCariServisLevel1: TcxGridLevel;
    GridCariServisViewSERVISNO: TcxGridDBColumn;
    GridCariServisViewDURUM: TcxGridDBColumn;
    GridCariServisViewBASLAMA: TcxGridDBColumn;
    GridCariServisViewBITIS: TcxGridDBColumn;
    GridCariServisViewKONUSU: TcxGridDBColumn;
    GridCariServisViewSERINO: TcxGridDBColumn;
    GridCariServisViewNOTLAR: TcxGridDBColumn;
    TabCariServis: TFDQuery;
    DtsCariServis: TDataSource;
    TabSheetAlisSatis: TcxTabSheet;
    PageControlAlisSatis: TcxPageControl;
    TabSheetAlisSip: TcxTabSheet;
    TabSheetAlisIrs: TcxTabSheet;
    TabSheetAlisKons: TcxTabSheet;
    TabSheetSatisSip: TcxTabSheet;
    TabSheetSatisIrs: TcxTabSheet;
    TabSheetSatisKons: TcxTabSheet;
    GridCariBelge: TcxGrid;
    GridCariBelgeView: TcxGridDBTableView;
    GridCariBelgeLevel1: TcxGridLevel;
    GridCariBelgeViewTARIH: TcxGridDBColumn;
    GridCariBelgeViewBELGENO: TcxGridDBColumn;
    GridCariBelgeViewSERI: TcxGridDBColumn;
    GridCariBelgeViewACIKLAMA: TcxGridDBColumn;
    GridCariBelgeViewMATRAH: TcxGridDBColumn;
    GridCariBelgeViewKDV: TcxGridDBColumn;
    GridCariBelgeViewTUTAR: TcxGridDBColumn;
    GridCariBelgeViewKUR: TcxGridDBColumn;
    GridCariBelgeViewVADE: TcxGridDBColumn;
    GridCariBelgeViewKAYNAK: TcxGridDBColumn;
    GridCariBelgeViewHEDEF: TcxGridDBColumn;
    GridCariBelgeViewDEPO: TcxGridDBColumn;
    TabCariBelge: TFDQuery;
    DtsCariBelge: TDataSource;
    TabSheetGorev: TcxTabSheet;
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
    Atamayap1: TMenuItem;
    MenuItem6: TMenuItem;
    BuiiEPostaGnder1: TMenuItem;
    BuiYazdr1: TMenuItem;
    MenuItem9: TMenuItem;
    IsiKopyalaMenu: TMenuItem;
    IsiSilMenu: TMenuItem;
    CariGridViewADRES: TcxGridDBColumn;
    cxGridPersonellerColumn1: TcxGridDBColumn;
    OdemeTahsilatYapMenu: TMenuItem;
    N17: TMenuItem;
    CariGridViewALTSEKTOR: TcxGridDBColumn;
    PersonelLOKASYON: TcxGridDBColumn;
    CariGridViewColumn1: TcxGridDBColumn;
    SheetBizimEkipman: TcxTabSheet;
    SheetRakipEkipman: TcxTabSheet;
    ToolBarEkipmanDetay: TToolBar;
    BtnEkipmanDetayYeni: TToolButton;
    btnEkipmanDetaySil: TToolButton;
    ToolButton24: TToolButton;
    BtnEkipmanDetayKaydet: TToolButton;
    BtnEkipmanDetayIptal: TToolButton;
    BtnEkipmanDuzenle: TToolButton;
    TreeListEkipman: TcxDBTreeList;
    TreeListEkipmancxDBTreeListID: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn11: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn12: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListSERINO: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListColumn1: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListColumn2: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListGARANTIBITTAR: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListColumnSURE: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListSAHIP: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListMARKA: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListMODEL: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn13: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListColumn3: TcxDBTreeListColumn;
    cxSplitter2: TcxSplitter;
    GridEkEkipman: TcxGrid;
    GridEkEkipmanView: TcxGridDBTableView;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridLevel11: TcxGridLevel;
    MemoEkipmanEkleListe: TMemo;
    ToolBar8: TToolBar;
    btnRakipEkipmanYeni: TToolButton;
    btnRakipEkipmanSil: TToolButton;
    ToolButton18: TToolButton;
    btnRakipEkipmanKaydet: TToolButton;
    btnRakipEkipmanIptal: TToolButton;
    GridEkipmanRakipDBTableView1: TcxGridDBTableView;
    GridEkipmanRakipLevel1: TcxGridLevel;
    GridEkipmanRakip: TcxGrid;
    TabEkipmanRakip: TFDQuery;
    DtsEkipmanRakip: TDataSource;
    GridEkipmanRakipDBTableView1ID: TcxGridDBColumn;
    GridEkipmanRakipDBTableView1REHBERID: TcxGridDBColumn;
    GridEkipmanRakipDBTableView1MARKA: TcxGridDBColumn;
    GridEkipmanRakipDBTableView1MODEL: TcxGridDBColumn;
    GridEkipmanRakipDBTableView1TIP: TcxGridDBColumn;
    GridEkipmanRakipDBTableView1YIL: TcxGridDBColumn;
    GridEkipmanRakipDBTableView1FIYAT: TcxGridDBColumn;
    GridEkipmanRakipDBTableView1KUR: TcxGridDBColumn;
    GridTeklifViewID: TcxGridDBColumn;
    GridTeklifViewTARIH: TcxGridDBColumn;
    GridTeklifViewTEKLIFNO: TcxGridDBColumn;
    GridTeklifViewTURU: TcxGridDBColumn;
    GridTeklifViewKONUSU: TcxGridDBColumn;
    GridTeklifViewDURUM: TcxGridDBColumn;
    GridTeklifViewOLASILIK: TcxGridDBColumn;
    GridTeklifViewTEKLIF_TUTARI: TcxGridDBColumn;
    GridTeklifViewKUR: TcxGridDBColumn;
    GridTeklifViewONAYLAYAN: TcxGridDBColumn;
    GridTeklifViewACIKLAMA: TcxGridDBColumn;
    GridTeklifViewONAYLAYACAK: TcxGridDBColumn;
    TreeListGorev: TcxDBTreeList;
    cxDBTreeListColumn1: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListACKAPA: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListLISTEADI: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListKONUSU: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListTURU: TcxDBTreeListColumn;
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
    N20: TMenuItem;
    PotansiyelListesineGonderMenu: TMenuItem;
    PotansiyelListesineGnderMenu: TMenuItem;
    N21: TMenuItem;
    MusteriListesineGonderMenu: TMenuItem;
    frxYaslandirma: TfrxDBDataset;
    GridYaslandirViewColumnISLEMTARIHI: TcxGridDBColumn;
    GridYaslandirViewColumnVADESONU: TcxGridDBColumn;
    GridYaslandirViewColumnODEMETARIHI: TcxGridDBColumn;
    GridYaslandirViewColumnGECIKENGUNSAYISI: TcxGridDBColumn;
    GridYaslandirViewColumnISLEMTURU: TcxGridDBColumn;
    GridYaslandirViewColumnODEMETURU: TcxGridDBColumn;
    GridYaslandirViewColumnBORCTUTARI: TcxGridDBColumn;
    GridYaslandirViewColumnODEMETUTARI: TcxGridDBColumn;
    GridYaslandirViewColumnODENENTUTAR: TcxGridDBColumn;
    GridYaslandirViewColumnISLEMACIKLAMA: TcxGridDBColumn;
    GridYaslandirViewColumnODEMEACIKLAMA: TcxGridDBColumn;
    SifreyiEpostaAt: TMenuItem;
    GridYaslandirViewColumnGECIKENTUTAR: TcxGridDBColumn;
    CariGridViewSEC: TcxGridDBColumn;
    DtsYorum: TDataSource;
    TabYorumMedya: TcxTabSheet;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem7: TMenuItem;
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
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    GridYorumLevel2: TcxGridLevel;
    TabYorum2: TFDQuery;
    DtsYorum2: TDataSource;
    GridYorumDBTableView1: TcxGridDBTableView;
    GridYorumDBTableView1Column1: TcxGridDBColumn;
    GridYorumDBTableView1Column2: TcxGridDBColumn;
    GridYorumDBTableView1Column3: TcxGridDBColumn;
    GridYorumDBTableView1Column4: TcxGridDBColumn;
    GridYorumDBTableView1Modul: TcxGridDBColumn;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    PanelFiyatAltSag: TPanel;
    ToolBar5: TToolBar;
    ResimYapistirTus: TToolButton;
    ToolButton8: TToolButton;
    ResimDosyadanTus: TToolButton;
    LogoResim: TcxDBImage;
    ExceldenVeriAlMenu: TMenuItem;
    Panel5: TPanel;
    ToolBar6: TToolBar;
    GorevEkleTus: TToolButton;
    GorevSilTus: TToolButton;
    ToolButton15: TToolButton;
    GorevDuzenleTus: TToolButton;
    JvNavPanelHeader1: TJvNavPanelHeader;
    CheckTamamlanan: TcxCheckBox;
    ComboTamamlanan: TcxImageComboBox;
    MusteriListesineEkleMenu: TMenuItem;
    TabSheetFirsat: TcxTabSheet;
    Panel7: TPanel;
    ToolBar9: TToolBar;
    FirsatEkleTus: TToolButton;
    FirsatSilTus: TToolButton;
    ToolButton16: TToolButton;
    FirsatDuzenleTus: TToolButton;
    JvNavPanelHeader3: TJvNavPanelHeader;
    checkKapaliFirsatGoster: TcxCheckBox;
    TabFirsat: TFDQuery;
    GridFirsat: TcxGrid;
    GridFirsatView: TcxGridDBTableView;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridDBColumn17: TcxGridDBColumn;
    cxGridDBColumn20: TcxGridDBColumn;
    cxGridDBColumn21: TcxGridDBColumn;
    cxGridDBColumn22: TcxGridDBColumn;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn23: TcxGridDBColumn;
    cxGridDBColumn24: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    MemoFirsat: TMemo;
    DtsFirsat: TDataSource;
    SerbestMeslekMakbuzuMenu: TMenuItem;
    KiraMenu: TMenuItem;
    GiderPusulasiMenu: TMenuItem;
    KrediKartndanade1: TMenuItem;
    buttonSocialMedya: TToolButton;
    ToolButton11: TToolButton;
    ToolButton13: TToolButton;
    CarilerArasTransfer1: TMenuItem;
    SenetCokluPlanlamaMenu: TMenuItem;
    TekSenetEkranMenu: TMenuItem;
    CariGridViewFATBASLIK: TcxGridDBColumn;
    MutabakatKaydiEkleMenu: TMenuItem;
    cxMemo1: TcxMemo;
    cxMemo2: TcxMemo;
    CariGridViewTAKIPTE: TcxGridDBColumn;
    CariGridViewIRSALIYE: TcxGridDBColumn;
    info1: TMenuItem;
    N11: TMenuItem;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    ToolBar7: TToolBar;
    TicariDuzenleTus: TToolButton;
    ToolButton5: TToolButton;
    IskontoTus: TToolButton;
    BtnKota: TToolButton;
    GridTicari: TcxGrid;
    GridTicariView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    cxTabSheet3: TcxTabSheet;
    ToolBar3: TToolBar;
    BankaEkleTus: TToolButton;
    BankaSilTus: TToolButton;
    ToolButton10: TToolButton;
    BankaDuzenleTus: TToolButton;
    BtnKaydetBH: TToolButton;
    BtnIptalBH: TToolButton;
    GridBanka: TcxGrid;
    GridBankaDBTableView1: TcxGridDBTableView;
    GridBankaDBTableView1VARSAYILAN: TcxGridDBColumn;
    GridBankaDBTableView1BANKAADI: TcxGridDBColumn;
    GridBankaDBTableView1SUBEKODU: TcxGridDBColumn;
    GridBankaDBTableView1SUBEADI: TcxGridDBColumn;
    GridBankaDBTableView1HESAPNO1: TcxGridDBColumn;
    GridBankaDBTableView1KUR: TcxGridDBColumn;
    GridBankaDBTableView1HESAPTIPI1: TcxGridDBColumn;
    GridBankaDBTableView1IBAN1: TcxGridDBColumn;
    GridBankaDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridBankaLevel1: TcxGridLevel;
    TabSheetEBelge: TcxTabSheet;
    ToolBar13: TToolBar;
    ToolButton17: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    GridAlias: TcxGrid;
    GridAliasView: TcxGridDBTableView;
    cxGridLevel4: TcxGridLevel;
    TabAlias: TFDQuery;
    DtsAlias: TDataSource;
    GridAliasViewID: TcxGridDBColumn;
    GridAliasViewREHBERID: TcxGridDBColumn;
    GridAliasViewBELGETURU: TcxGridDBColumn;
    GridAliasViewALIAS: TcxGridDBColumn;
    GridAliasViewVARSAYILAN: TcxGridDBColumn;
    GridAliasViewAKTIF: TcxGridDBColumn;
    GridAliasViewILKKAYITTARIHI: TcxGridDBColumn;
    GridAliasViewSONKONTROLTARIHI: TcxGridDBColumn;
    GridAliasViewPASIFTARIHI: TcxGridDBColumn;
    Panel10: TPanel;
    cxLabel2: TcxLabel;
    EditEFaturaXSLT: TcxButtonEdit;
    EditEArsivXSLT: TcxButtonEdit;
    cxLabel4: TcxLabel;
    EditEIrsaliyeXSLT: TcxButtonEdit;
    cxLabel6: TcxLabel;
    ButtonFaturaDipNotu: TcxButton;
    cxLabel7: TcxLabel;
//    N7: TMenuItem;
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Cari_Liste)
    procedure ComboGrupPropertiesCloseUp(Sender: TObject);
    procedure ComboCariPropertiesCloseUp(Sender: TObject);
    procedure ComboKategoriPropertiesCloseUp(Sender: TObject);
    procedure ComboSinifPropertiesCloseUp(Sender: TObject);
    procedure ComboBolgePropertiesCloseUp(Sender: TObject);
    procedure AraTusClick(Sender :TObject);
    Procedure SubSelectGetir;
    procedure ComboBox1DropDown(Sender :TObject);
    procedure AraFirmaKeyUp(Sender :TObject; var Key :Word;  Shift :TShiftState);
    procedure DegisTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure CariGridDBTableView1DblClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure REHBERAfterOpen(DataSet: TDataSet);
    procedure CheckPasiflerClick(Sender: TObject);
    procedure CheckPotansiyelClick(Sender: TObject);
    procedure PageControlSekmeChange(Sender: TObject);
    procedure PageControlCRMChange(Sender: TObject);
    procedure CRMAltSekmeYenile;
    procedure PageControlServisChange(Sender: TObject);
    procedure ServisAltSekmeYenile;
    procedure PageControlAlisSatisChange(Sender: TObject);
    procedure AlisSatisAltSekmeYenile;
    procedure GridCariBelgeViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    function AlisSatisGridAyarAdi: string;
    procedure IlgiliEkleTusClick(Sender: TObject);
    procedure IlgiliSilTusClick(Sender: TObject);
    procedure ResimDuzenleTusClick(Sender: TObject);
    procedure TicariDuzenleTusClick(Sender: TObject);
    procedure ProjeEkleTusClick(Sender: TObject);
    procedure ProjeSilTusClick(Sender: TObject);
    procedure ProjeDuzenleClick(Sender: TObject);
    procedure OzlukDuzenleTusClick(Sender: TObject);
    procedure UcretDuzenleTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure cxGridPersonellerSelectionChanged(Sender: TcxCustomGridTableView);
    procedure IlgiliDuzenleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KartiKopyalaMenuClick(Sender: TObject);
    procedure BankaEkleTusClick(Sender: TObject);
    procedure BankaSilTusClick(Sender: TObject);
    procedure BankaDuzenleTusClick(Sender: TObject);
    procedure AcilisiFisiMenuClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure TabRehberIlgiliAfterOpen(DataSet: TDataSet);
    procedure TabBankaHesaplarAfterOpen(DataSet: TDataSet);
    procedure TabProjelerAfterOpen(DataSet: TDataSet);
    procedure Fatura1Click(Sender: TObject);
    procedure AksiyonBilgisiniGorMenuClick(Sender: TObject);
    procedure GridDemirbasViewDblClick(Sender: TObject);
    procedure LogoResimClick(Sender: TObject);
    procedure PageControlGiderChange(Sender: TObject);
    procedure Nakit3Click(Sender: TObject);
    procedure PMAksiyonlarMenuPopup(Sender: TObject);
    procedure CariGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridCariEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridCariProjelerViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridBankaDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure CariGridViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridBankaDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridProjeViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure cxGridAktivitelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridDemirbasViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridPerTemelViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridUcretViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridCariEkstreViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure CheckTamamlanmisAktivitePropertiesEditValueChanged(Sender: TObject);
    procedure TabSheetIzinBilgileriShow(Sender: TObject);
    procedure DtsBankaHesaplarStateChange(Sender: TObject);
    procedure BtnIptalBHClick(Sender: TObject);
    procedure BtnKaydetBHClick(Sender: TObject);
    procedure TabBankaHesaplarAfterPost(DataSet: TDataSet);
    // Alias sekmesi handler'larÄ±
    procedure AliasYeniTusClick(Sender: TObject);
    procedure AliasSilTusClick(Sender: TObject);
    procedure AliasDuzenleTusClick(Sender: TObject);
    procedure AliasKaydetTusClick(Sender: TObject);
    procedure AliasIptalTusClick(Sender: TObject);
    procedure TabAliasNewRecord(DataSet: TDataSet);
    procedure AliasToolbarDurumuGuncelle(DuzenlemeKipinde: Boolean);
    procedure checkKapaliGosterPropertiesEditValueChanged(Sender: TObject);
    procedure RBDevirliClick(Sender: TObject);
    procedure lgiliyiKopyala1Click(Sender: TObject);
    procedure Kopyala1Click(Sender: TObject);
    procedure TeklifEkleClick(Sender: TObject);
    procedure GridTeklifViewDblClick(Sender: TObject);
    procedure TeklifSilClick(Sender: TObject);
    procedure TeklifDuzenleClick(Sender: TObject);
    procedure REHBERBeforeOpen(DataSet: TDataSet);
    procedure Varsaylan1Click(Sender: TObject);
    procedure BtnEkipmanDetayKaydetClick(Sender: TObject);
    procedure BtnEkipmanDetayIptalClick(Sender: TObject);
    procedure btnEkipmanDetaySilClick(Sender: TObject);
    procedure BtnEkipmanDetayYeniClick(Sender: TObject);
    procedure DtsEkipmanlarStateChange(Sender: TObject);
    procedure ifreOlutur1Click(Sender: TObject);
    procedure cxDBTreeList1cxDBTreeListColumn6PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure Kopyala2Click(Sender: TObject);
    procedure TreeListEkipmanSelectionChanged(Sender: TObject);
    procedure BtnEkipmanDuzenleClick(Sender: TObject);
    procedure cxDBTreeList1cxDBTreeListColumn2PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditEFaturaXSLTPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditEArsivXSLTPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditEIrsaliyeXSLTPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ButtonFaturaDipNotuClick(Sender: TObject);
    procedure IlgiliEkleClick(Sender: TObject);
    procedure TabProjelerBeforeOpen(DataSet: TDataSet);
    procedure lgiliKurumdanAyrld1Click(Sender: TObject);
    procedure IlgiliAraEditPropertiesChange(Sender: TObject);
    procedure YeniletisimEkleMenuClick(Sender: TObject);
    procedure GridRehberIletisimViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure iletisimEkleClick(Sender: TObject);
    procedure iletisimSilClick(Sender: TObject);
    procedure iletisimDuzenleClick(Sender: TObject);
    procedure VarsaylanYap1Click(Sender: TObject);
    procedure letiimaddeitir1Click(Sender: TObject);
    procedure EPostaKontrol1Click(Sender: TObject);
    procedure btnCRMClick(Sender: TObject);
    procedure CariGridViewFARKGetDataText(Sender: TcxCustomGridTableItem; ARecordIndex: Integer; var AText: string);
    procedure lgiligemiinigster1Click(Sender: TObject);
    procedure ExceldenAksiyonAktar1Click(Sender: TObject);
    procedure ExcelKolonAyarlar1Click(Sender: TObject);
    procedure Faturaile1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure FaturaKapatma1Click(Sender: TObject);
    procedure BorAlacakKapama1Click(Sender: TObject);
    procedure GridYaslandirViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure EkimanKopyalaMenuClick(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure TBtnHareketKaydetClick(Sender: TObject);
    procedure TBtnHareketIptalClick(Sender: TObject);
    procedure ToolButton15Click(Sender: TObject);
    procedure LabelStandartAvansDblClick(Sender: TObject);
    procedure cbPerExtreTuruPropertiesEditValueChanged(Sender: TObject);
    procedure CheckDetayliPropertiesEditValueChanged(Sender: TObject);
    procedure IskontoTusClick(Sender: TObject);
    procedure PopupMenuREHBERPopup(Sender: TObject);
    procedure MasrafNakitMenuClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure CheckDetayClick(Sender: TObject);
    procedure KurFarkGeliri1Click(Sender: TObject);
    procedure GridTeklifViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridCariProjelerViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure TamamlandiIsaretleMenuClick(Sender: TObject);
    procedure DuzenleMenuClick(Sender: TObject);
    procedure GorevGridDBTableView1ACKAPAPropertiesEditValueChanged(Sender: TObject);
    procedure GorevGridDBTableView1DblClick(Sender: TObject);
    procedure Bayraklaretle1Click(Sender: TObject);
    procedure IsiSilMenuClick(Sender: TObject);
    procedure IsiKopyalaMenuClick(Sender: TObject);
    procedure GorevGridDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TreeListEkipmanDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeListEkipmanMoveTo(Sender: TcxCustomTreeList; AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode; Nodes: TList; var IsCopy, Done: Boolean);
    procedure TreeListEkipmancxDBTreeListMODELPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
    procedure TreeListEkipmancxDBTreeListMARKAPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
    procedure OdemeTahsilatYapMenuClick(Sender: TObject);
    procedure PopupMenuYeniPopup(Sender: TObject);
    procedure btnRakipEkipmanYeniClick(Sender: TObject);
    procedure btnRakipEkipmanSilClick(Sender: TObject);
    procedure btnRakipEkipmanKaydetClick(Sender: TObject);
    procedure btnRakipEkipmanIptalClick(Sender: TObject);
    procedure DtsEkipmanRakipStateChange(Sender: TObject);
    procedure TabEkipmanRakipNewRecord(DataSet: TDataSet);
    procedure TreeListGorevDblClick(Sender: TObject);
    procedure TreeListGorevClick(Sender: TObject);
    procedure PotansiyelListesineGonderMenuClick(Sender: TObject);
    procedure TabRehberIlgiliBeforeDelete(DataSet: TDataSet);
    procedure TreeListEkipmanStylesGetNodeIndentStyle(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; ALevel: Integer; var AStyle: TcxStyle);
    procedure SifreyiEpostaAtClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure ResimYapistirTusClick(Sender: TObject);
    procedure ResimDosyadanTusClick(Sender: TObject);
    procedure ExceldenVeriAlMenuClick(Sender: TObject);
    procedure GridYorumDBTableView1DblClick(Sender: TObject);
    procedure GorevEkleTusClick(Sender: TObject);
    procedure GorevSilTusClick(Sender: TObject);
    procedure CheckTamamlananClick(Sender: TObject);
    procedure BtnKotaClick(Sender: TObject);
    procedure TabEkipmanlarAfterPost(DataSet: TDataSet);
    procedure MusteriListesineEkleMenuClick(Sender: TObject);
    procedure TabFirsatAfterOpen(DataSet: TDataSet);
    procedure FirsatDuzenleTusClick(Sender: TObject);
    procedure FirsatEkleTusClick(Sender: TObject);
    procedure FirsatSilTusClick(Sender: TObject);
    procedure CariGridViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
    procedure MutabakatKaydiEkleMenuClick(Sender: TObject);
    procedure info1Click(Sender: TObject);

  private
    { private declarations }
    FKayitErisimTamamlandi: TNotifyEvent;
    FKayitErisimIptalEdildi: TNotifyEvent;
    FArama : TRehberAramaFrame;
    // SAYFALI liste (merkezi TSayfaliListe, Utablo): yalniz Mod=4 + analiz=0 dali sayfalanir.
    FSayfali: TSayfaliListe;
    FCariSonMod: SmallInt;   // son Liste_SP_Cagir modu (sayfa buyutme requery'si ayni modla)
    { IBilgiFrame ?yeleri            }
    FFrameBilgi : TIcerikFrameBilgi;
    procedure KurumXSLTSec(ABolum, ARaporID: Integer; AEdit: TcxButtonEdit; AButtonIndex: Integer);
    procedure KurumXSLTYukle;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    function GetFrameBilgi : TIcerikFrameBilgi;
    function SorguyaTabloEkle(SQL:String):String;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    {********************************}
    procedure SetArama(const Value: TRehberAramaFrame);
    function EkranAdiAl: string;
    procedure BorcAlacakKolonlari(Index : integer);
    procedure KapatAc(Kolon : TcxGridDBColumn; Gor:Boolean);
  public
    { public declarations }
    Gelis, AdSakla, SoyadSakla :string[20];
    Cagiran : SmallInt;
    procedure RehEkranInit( OwnerGorevClassFrame : TFrame = nil);
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    property KayitErisimTamamlandi : TNotifyEvent read FKayitErisimTamamlandi write FKayitErisimTamamlandi;
    property KayitErisimIptalEdildi : TNotifyEvent read FKayitErisimIptalEdildi write FKayitErisimIptalEdildi;
  published
    property Arama : TRehberAramaFrame read FArama write SetArama;
  end;

var
  RehberAraDlg :TRehberAraDlg;
  rehberdetayaktif : Boolean;
  SonAranan : Boolean;
  FIlkSonAranan : Boolean;   // ilk acilista Son Aranan (5) goster (JvTimer'de)
  dene1,dene2 : string;

implementation

uses UVeriMotor, ULog, FetaUtil, UCombo, UAnaForm,UGirisKutusuEx,UKodAgaci,URehberBilgiDuzenle, UGenNotificationUtils, System.Math,
  FetaClassExtensions,FetaClassExtensionsConsts, UResim, PrjConst, UFastRap, UCariFonksiyonlar, UKasaWizard,
  UKasalarListeFrame, UGenelAnaSekmeFrame, URaporAraclari, UGenSifre,UBekletme, UGorevDlg,
  UReplikasyon, FetaKurulusSiniflari, UAcilisKaydi, UNakitDlg,UBinarySave,IdGlobalProtocols,UExceldenVeriAl,
  UVardiyaTanimlariDlg,UExcelKolonAyar, UFaturaKapama, UIskontoDlg,LocOnFly, UIslistesi,UCariGorevFrame
  , UAksiyonlarGorevFrame
  {$IFDEF 3Dparty}
  , uUtility_my
  {$ENDIF}
  ;

{$R *.DFM}

var
  i, Param, TabloNo : integer;
  s, Paramst : string;
  ProjeImageComboBos, AktiviteImageComboBos:boolean;
  GenotipIni :TIniFile;
  Fir, Yet, Kod, TFirma, TYet, TKod : string[100];
  EkstreGorunsun :boolean;

procedure TRehberAraDlg.RehEkranInit( OwnerGorevClassFrame : TFrame = nil);
var
  gf : TCariGorevFrame;
begin
{  gf := TCariGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
  AktifSekme='TAksiyonlarGorevFrame' := gf.FPotansiyel;
  if AktifSekme='TAksiyonlarGorevFrame' then begin
     //AksiyonEkleTus.DropdownMenu := PopupMenuPotansiyel;
     //CariGrid.PopupMenu := PopupMenuPotansiyel;
     TabloNo := TabNo_REHBER_POTANSIYEL;
     FArama.CheckPotansiyel.caption := 'Caride de Ara';
  end else begin
     //AksiyonEkleTus.DropdownMenu := PopupMenuYeni;
     //CariGrid.PopupMenu := PopupMenuREHBER;
     TabloNo := TabNo_REHBER;
     FArama.CheckPotansiyel.caption := 'Potansiyelde de Ara';
  end;
  Rehber.Close;
  }
  if Assigned( OwnerGorevClassFrame) and (OwnerGorevClassFrame.ClassName = 'TAksiyonlarGorevFrame') then begin
     buttonSocialMedya.Visible  := True;// Tablo.YetkiVarmi(2105, YetkiTur_Gorme);
  end
   else
    buttonSocialMedya.Visible := False;
end;

function TRehberAraDlg.EkranAdiAl: string;
begin
  if PageControlSekme.ActivePage = TabSheetYaslandirma then
    Result := 'RehberYaslandir'
  else if PageControlSekme.ActivePage = TabSheetEkstre then
    Result := 'RehberEkstre'
  else
   Result := 'RehberAraDlg';
end;

procedure TRehberAraDlg.ResimDosyadanTusClick(Sender: TObject);
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

procedure TRehberAraDlg.ResimDuzenleTusClick(Sender: TObject);
begin
   if TabRehberIlgili.State in [dsEdit, dsInsert] then
      TabRehberIlgili.Post
   else if TabRehberIlgili.IsEmpty then
      Exit;

   Tablo.ResimSihirbazBaslat(Tabno_Rehber,REHBER.Fields[0].AsInteger);
   TabloYenile(TabResim,[REHBER.Fields[0].AsInteger]);
end;

procedure TRehberAraDlg.ResimYapistirTusClick(Sender: TObject);
begin
   ResimYapistir(TcxImage(logoresim), REHBER.FieldByName('ID').AsInteger, Tabno_Rehber, REHBER.FieldByName('ID').AsInteger);
   //ResmiVarsayilanyap(TabResim, 71, STOKLAR.FieldByName('ID').AsInteger);
   TabloYenile(TabResim, [REHBER.FieldByName('ID').AsInteger]);
end;

procedure TRehberAraDlg.SetArama(const Value: TRehberAramaFrame);
begin
  FArama := Value;
end;

procedure TRehberAraDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TRehberAraDlg.SifreyiEpostaAtClick(Sender: TObject);
var
  BodyStr, Konu, DosyaAdi: string;
  Etiketler,Bilgiler: TArrayOfString;
  Body: TStringStream;
  EpostaAlicilar, EPostaAlicilarCC: TList<TEpostaAlici>;
  EkDosya:TList<string>;
begin
  Tablo.RehberEkBilgileriniGetir(TabRehberIlgili.FieldByName('ID').AsInteger,4,[RehVars_EPosta],Etiketler,Bilgiler);
  if Bilgiler[0]='' then begin
    Tablo.UyariGoster(Uyari,'Eposta Adresi Tan�ml� De�il.');
    Abort;
  end;
  Tablo.TablodanSorguAc(0,'select * from MAILSABLON where MODULID=77 and ID=77');
  if Tablo.Query0.IsEmpty then begin
    Tablo.UyariGoster(Uyari,'Eposta �ablonu Tan�ml� De�il.');
    Abort;
  end;
  //al?c? cc vs ayar?
  EkDosya := TList<String>.Create;
  EPostaAlicilar := TList<TEpostaAlici>.Create;
  EPostaAlicilarCC := TList<TEpostaAlici>.Create;
  TEpostaAlici.ListeyeYukle(TabRehberIlgili.FieldByName('FIRMA').AsString+','+Bilgiler[0], EPostaAlicilar);
  //konu - body ayar?
  Konu := Tablo.Query0.FieldByName('KONU').AsString;
  Konu := StringReplace(Konu,'@@KONU@@','Genotip Destek Giri� Bilgileri',[rfReplaceAll]);
  BodyStr := Tablo.Query0.FieldByName('ICERIK').AsString;
  BodyStr := StringReplace(BodyStr,'@@ADSOYAD@@',TabRehberIlgili.FieldByName('FIRMA').AsString,[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@KULLANICI@@',Bilgiler[0],[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@SIFRE@@',TabRehberIlgili.FieldByName('ID').AsString,[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@FIRMAADI@@',REHBER.FieldByName('FIRMA').AsString,[rfReplaceAll]);

  Body := TStringStream.Create();
  Body.WriteString(BodyStr);
  DosyaAdi := GetEnvironmentVariable('Temp')+'\TempRehPersonel'+TabRehberIlgili.FieldByName('ID').AsString+'.html';
  Body.SaveToFile(DosyaAdi);

  try
    Tablo.UyariGoster(Uyari,'E Posta G�nderildi. '+
                      UGenNotificationUtils.EpostaGonderRapor(
                        EPostaHesapBilgileriniGetir(EpostaHesapID),
                        Konu, DosyaAdi, EkDosya, EPostaAlicilar, EPostaAlicilarCC,
                        Tablo.IdSMTP1, Tablo.iohSSLTLS,TabNo_REHBERPERSONEL,
                        TabRehberIlgili.FieldByName('ID').AsString,
                        REHBER.FieldByName('ID').AsInteger).SonucMesaji);
  finally
    FreeAndNil(EPostaAlicilar);
    FreeAndNil(EPostaAlicilarCC);
    FreeAndNil(EkDosya);
  end;

end;

procedure TRehberAraDlg.Sil1Click(Sender: TObject);
var
  i,Recordindex,ID,TUR,Kilitli,Planli:integer;
  Tarih: TDateTime;
begin
  Kilitli:=0;
  Planli:=0;
  if GridCariEkstreView.DataController.GetSelectedCount > 0 then begin
    if Application.MessageBox(PChar(RDAksiyonSilinsinmi),PChar(Onay), MB_YESNO) = IDYES then begin
      for I := 0 to GridCariEkstreView.DataController.GetSelectedCount - 1 do begin
        Recordindex := GridCariEkstreView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
        ID := GridCariEkstreView.DataController.Values[Recordindex,GridCariEkstreViewCEKID.Index];
        TUR    := GridCariEkstreView.DataController.Values[Recordindex,GridCariEkstreViewTUR.Index];
        Tarih  := GridCariEkstreView.DataController.Values[Recordindex,GridCariEkstreViewTARIH.Index];
        if (TUR in [10,11,12,13,14,15,16,17,21,22,23,24,25,28,29,31,32,33,34,35,125])or(TUR>2600) then begin
           if TUR in [11,15] then begin
             if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+IntToStr(ID)+' ',[],[]) then begin
               Planli:=1;
             end else begin
               Tablo.KasaSilmeIslemleri(ID, TUR);
             end;
           end else begin
             Tablo.KasaSilmeIslemleri(ID, TUR); //Kilit yok ise silsin.
           end;
        end else begin
          Tablo.KasaSilmeIslemleri(ID, TUR);
        end;
      end;
      PageControlSekmeChange(Self);
      if (Kilitli = 1) and (Planli=0) then
        Application.MessageBox(PChar(CRKilitli_belge_islem_yapilamaz),PChar(Uyari),0)
      else if (Kilitli = 0) and (Planli=1) then
        Application.MessageBox(PChar(CRPlanli_belge_silinemez),PChar(Uyari),0)
      else if (Kilitli = 1) and (Planli=1) then
        Application.MessageBox(PChar(CRKilitli_planli_belge_silinemez),PChar(Uyari),0)
    end;
  end;
end;

procedure TRehberAraDlg.KartiKopyalaMenuClick(Sender: TObject);
// KART KLONU: once SUNUCUDA klon olusturulur (sp_Api_Cari_Klonla_Json -> kaydet
//   API'si; kart + iletisimler + iletisim bilgileri, kod otomatik "<KOD>-K"),
//   sonra sihirbaz o kart uzerinde acilir. Kullanici vazgecerse klon SILINIR.
//   Belge klonuyla ayni desen; eski ham SQLSatiriKopyala yolu kullanilmaz.
var
  LKaynak, LYeni, LSonuc: Integer;
begin
  if REHBER.IsEmpty then Exit;
  LKaynak := REHBER.Fields[0].AsInteger;
  if LKaynak <= 0 then Exit;
  if Application.MessageBox(PChar('Bu kartın kopyası oluşturulacak. Devam edilsin mi?'),
       PChar(Onay), MB_YESNO + MB_ICONQUESTION) <> IDYES then Exit;

  LYeni := Tablo.CariKlonla(LKaynak, '', '');
  if LYeni <= 0 then Exit;

  LSonuc := Tablo.RehberSihirbazBaslat(0, LYeni, -1, -1, False);
  if LSonuc = -99 then
  begin
    Tablo.ApiSilCagir('sp_Api_Cari_Sil_Json', LYeni);   // vazgecildi -> klonu geri al
    Liste_SP_Cagir(5);
    Exit;
  end;

  // "Yeni cari" ile ayni davranis: Son/Sik Aranan'a yaz, Son Aranan ile tazele, karta git.
  Tablo.AramaKaydet(MODUL_Cari, LYeni);
  Liste_SP_Cagir(5);                    // Son Aranan (en yeni ustte)
  REHBER.Locate('ID', LYeni, []);
end;

procedure TRehberAraDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     // SILME logu artik BURADA YAZILMIYOR: Tablo.CariSil kart + tum detaylari SILMEDEN
     //   ONCE ve TABLODAN logluyor (LogKayitSil('REHBER',...)). Buradaki eski
     //   LogKartSil(REHBER,...) dataset'ten yaziyordu; liste sp_Prog_Cari_Liste_Json2
     //   kolonlarini tasidigi icin (ADSOYAD/BAKIYE/TEMSILCIAD...) gercek REHBER kolonlari
     //   (FIRMA/GRUP) loga girmiyor, "Geri Al" kaydi EKSIK diriliyordu. Ayrica mukerrer
     //   kart log satiri uretiyordu.
     LogOnceki.Clear;
     Tablo.CariSil( REHBER.Fields[0].AsInteger);
     TabloYenile(REHBER,[]);
  end;
end;

procedure TRehberAraDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TRehberAraDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TRehberAraDlg.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;


procedure TRehberAraDlg.UcretDuzenleTusClick(Sender: TObject);
begin
  if Tablo.RehberSihirbazBaslat(5, REHBER.Fields[0].AsInteger, -100, REHBER.Fields[0].AsInteger, AktifSekme='TAksiyonlarGorevFrame') > 0 then
    PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.Varsaylan1Click(Sender: TObject);
begin
  if TabRehberIlgili.FieldByName('DURUM').AsInteger = 1 then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBER Set STATU=0 Where BAGID=&RehID',['&RehID'],[REHBER.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBER Set STATU=1 Where BAGID=&RehID and ID=&PersID',['&RehID','&PersID'],[REHBER.FieldByName('ID').AsInteger,TabRehberIlgili.FieldByName('ID').AsInteger]);
     TabloYenile(TabRehberIlgili,[REHBER.FieldByName('ID').AsInteger]);
     cxGridPersoneller.DataController.FocusedRecordIndex:=0;
     cxGridPersoneller.ViewData.Records[0].Selected:=True;
  end;
end;

procedure TRehberAraDlg.VarsaylanYap1Click(Sender: TObject);
begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBERILETISIM Set VARSAYILAN=0 Where AKTIF=1 and REHBERID=&RehID',['&RehID'],[REHBER.FieldByName('ID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBERILETISIM Set VARSAYILAN=1 Where AKTIF=1 and REHBERID=&RehID and ID=&IletID',['&RehID','&IletID'],[REHBER.FieldByName('ID').AsInteger,REHBERILETISIM.FieldByName('ID').AsInteger]);
    TabloYenile(REHBERILETISIM,[REHBER.FieldByName('ID').AsInteger]);
    GridRehberIletisimView.DataController.FocusedRecordIndex:=0;
    GridRehberIletisimView.ViewData.Records[0].Selected:=True;
end;

procedure TRehberAraDlg.TabBankaHesaplarAfterOpen(DataSet: TDataSet);
begin
   BankaDuzenleTus.Visible   := not TabBankaHesaplar.IsEmpty;
   BankaSilTus.Visible := BankaDuzenleTus.Visible;
end;

procedure TRehberAraDlg.TabBankaHesaplarAfterPost(DataSet: TDataSet);
var
  BankaHesapID:Integer;
begin
  TabBankaHesaplar.AfterPost := nil;
  BankaHesapID := TabBankaHesaplar.FieldByName('ID').AsInteger;
  TabBankaHesaplar.First;
  while not TabBankaHesaplar.Eof do begin
    TabBankaHesaplar.Edit;
    if BankaHesapID <> TabBankaHesaplar.FieldByName('ID').AsInteger then
      TabBankaHesaplar.FieldByName('VARSAYILAN').Value := 0;
    TabBankaHesaplar.Post;
    TabBankaHesaplar.Next;
  end;
  TabBankaHesaplar.AfterPost := TabBankaHesaplarAfterPost;
end;

procedure TRehberAraDlg.TabEkipmanlarAfterPost(DataSet: TDataSet);
var Msg : string;
begin
  Tablo.Query8.Close;
  Tablo.Query8.SQL.Text := 'select R.KOD,R.FIRMA,E.AD,ER.SERINO ';
  Tablo.Query8.SQL.Add(' from EKIPMANREHBER ER inner join REHBER R on ER.REHBERID=R.ID inner join EKIPMANLAR E on E.ID=ER.EKIPMANID ');
  Tablo.Query8.SQL.Add(' where ER.SERINO in (SELECT SERINO FROM EKIPMANREHBER group by SERINO,EKIPMANID having count(*)>1) and ');
  Tablo.Query8.SQL.Add(' ER.SERINO= '''+TabEkipmanlar.FieldByName('SERINO').AsString+''' and ');
  Tablo.Query8.SQL.Add(' ER.EKIPMANID= '+TabEkipmanlar.FieldByName('EKIPMANID').AsString+' ');
  if AktifVeriMotor = vmPG then Tablo.Query8.SQL.Text := PgSqlCevir(Tablo.Query8.SQL.Text);
  Tablo.Query8.Open;
  if not Tablo.Query8.IsEmpty then begin
    Tablo.Query8.First;
    while not Tablo.Query8.Eof do begin
      Msg := Msg + #10 + Tablo.Query8.FieldByName('KOD').AsString +' - '+Tablo.Query8.FieldByName('FIRMA').AsString +' Ekipman:'+Tablo.Query8.FieldByName('AD').AsString  +' Serino:'+Tablo.Query8.FieldByName('SERINO').AsString + #13;
      Tablo.Query8.Next;
    end;
    ShowMessage('Bu Ekipman Daha �nce Kullan�lm��!'+ #13 + #10 + Msg);
  end;
end;

procedure TRehberAraDlg.TabEkipmanRakipNewRecord(DataSet: TDataSet);
begin
  TabEkipmanRakip.FieldByName('REHBERID').AsInteger :=  REHBER.FieldByName('ID').AsInteger;
  TabEkipmanRakip.FieldByName('YIL').AsInteger := YearOf(Tablo.GENINI.BugunTrh);
end;

procedure TRehberAraDlg.TabFirsatAfterOpen(DataSet: TDataSet);
begin
   FirsatDuzenleTus.Visible :=  not TabFirsat.IsEmpty;
   FirsatSilTus.Visible := FirsatDuzenleTus.Visible;
end;

procedure TRehberAraDlg.TabProjelerAfterOpen(DataSet: TDataSet);
begin
   ProjeDuzenle.Visible :=  not TabProjeler.IsEmpty;
   ProjeSilTus.Visible := ProjeDuzenle.Visible;
end;

procedure TRehberAraDlg.TabProjelerBeforeOpen(DataSet: TDataSet);
begin
  TabProjeler.SQL.Text:=StringReplace(TabProjeler.SQL.Text,'@PERSONEL',Kullanan,[rfReplaceAll]);
end;

procedure TRehberAraDlg.REHBERAfterOpen(DataSet: TDataSet);
begin
   rehberdetayaktif:=True;
   DegisTus.Visible :=  (not REHBER.IsEmpty) and (Tablo.YetkiVarmi(2201,YetkiTur_Degistirme));
   SilTus.Visible :=  (DegisTus.Visible) and (Tablo.YetkiVarmi(2201,YetkiTur_Silme));


   if BtnCRM.Tag<>99 then
      BtnCRM.Visible := DegisTus.Visible;
   if AksiyonEkleTus.Tag<>99 then
      AksiyonEkleTus.Visible := DegisTus.Visible;
   SilMenu.Visible:=DegisTus.Visible;
   GorMenu.Visible := DegisTus.Visible;
   N18.Visible := DegisTus.Visible;
   //ExcelKolonAyarlar1.Visible := DegisTus.Visible;
   N19.Visible := DegisTus.Visible;
   PageControlSekme.Visible := not REHBER.IsEmpty;
   //cxSplitter1.CloseSplitter;
   //cxSplitter1.OpenSplitter;
end;

procedure TRehberAraDlg.TabRehberIlgiliAfterOpen(DataSet: TDataSet);
begin
   IlgiliDuzenleTus.Visible := not TabRehberIlgili.IsEmpty;
   IlgiliSilTus.Visible := IlgiliDuzenleTus.Visible;
end;

procedure TRehberAraDlg.TabRehberIlgiliBeforeDelete(DataSet: TDataSet);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KULLANICI where REHBERID='+TabRehberIlgili.FieldByName('ID').AsString+' and PERSONEL=0', [], []);
end;

procedure TRehberAraDlg.TabSheetIzinBilgileriShow(Sender: TObject);
begin
  //Tablo.GENINI.ReadImageSection(Ops_CariKart_PerIzinTuru,((GridIzinListeDBTableView1TUR.Properties) as TcxImageComboBoxProperties).Items);  //   CariKart_PerIzinTuru
end;

procedure TRehberAraDlg.TamamlandiIsaretleMenuClick(Sender: TObject);
begin
//Ad   Menu_Tamam(Sender, GorevGridDBTableView1);
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.TBtnHareketIptalClick(Sender: TObject);
begin
  if not TabHareketler.Active then Abort;
  TabHareketler.Cancel;
end;

procedure TRehberAraDlg.TBtnHareketKaydetClick(Sender: TObject);
begin
  if not TabHareketler.Active then Abort;
  TabHareketler.Post;
end;

procedure TRehberAraDlg.TeklifDuzenleClick(Sender: TObject);
begin
  if Tablo.TeklifSihirbazBaslat('D',80,0,TabTeklifler.Fields[0].AsInteger, REHBER.Fields[0].AsInteger,-1)>0 then
    PageControlSekmeChange(nil);
end;

procedure TRehberAraDlg.TeklifEkleClick(Sender: TObject);
begin
   if Tablo.TeklifSihirbazBaslat('E',80,0,-1,REHBER.Fields[0].AsInteger,-1) > 0 then
     PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.TeklifSilClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      //varsa dokumanlar?n silinmeli
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],
         [81, TabTeklifler.Fields[0].AsInteger]);
      //varsa proje ba?lant?lar? silinmeli
      //kendisi silinir
      // Kart SILME logu: SILMEDEN ONCE, kayit dururken.
      LogKartSil(TabTeklifler, TabNo_TEKLIF, TabTeklifler.FieldByName('ID').AsInteger);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIFDETAY where TEKLIFID=&id ',['&id'],[TabTeklifler.Fields[0].AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIF where ID=&id ',['&id'],[TabTeklifler.Fields[0].AsInteger]);


      PageControlSekmeChange(Self);
        /// SQL2005 TE hataya neden oldu?u i?in delete olay?n? kendimiz yap?yoruz
       Abort;
   end;
end;

procedure TRehberAraDlg.TicariDuzenleTusClick(Sender: TObject);
begin
  if Tablo.RehberSihirbazBaslat(2, REHBER.Fields[0].AsInteger,-1, -1, AktifSekme='TAksiyonlarGorevFrame')>0 then
    //TicariBilgisi(REHBER.FieldByName('ID').AsInteger);
    PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.ToolButton13Click(Sender: TObject);
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
    ShowMessage(CROpsiyon_kaydi_bulunamadi);
    Exit;
  end;

  while not Tablo.Query1.Eof do
  begin
    KayitBulundu := False;
    GenIniAnahtar := Tablo.Query1.FieldByName('ANAHTAR').AsString;
    BilgiAlBaslik := Concat(GenIniAnahtar,BGBilgi_gir);
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
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'UPDATE REHBERBILGI SET BILGI=&BILGI,DEGISTIREN=&DEGISTIREN,DEGISTIRMETARIHI=&DEGISTIRMETARIHI WHERE YER_ID=&YER_ID AND SIRA=10 AND YERI=11 AND ETIKET='''+GenIniAnahtar+'''',
          ['&BILGI','&DEGISTIREN','&DEGISTIRMETARIHI','&YER_ID'],
          [Sonuc,Kullanan,FormatDateTime('yyyy-MM-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat),RehberID]);
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
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'INSERT INTO REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI) VALUES(11,&IDYER,10,&ETIKET,&BILGI,&EKLEYEN,&EKLEMETARIHI)',
          ['&IDYER','&ETIKET','&BILGI','&EKLEYEN','&EKLEMETARIHI'],
          [RehberID,GenIniAnahtar,Sonuc,Kullanan,FormatDateTime('yyyy-MM-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)]);
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

procedure TRehberAraDlg.ToolButton15Click(Sender: TObject);
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

    Ctrls := TGirdiDenetimleri.Create.ComboBox('Vardiya T�r� : ',@TurAdi,
    Tablo.ComboboxInit('Select ANAHTAR from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(Ops_OpsiyonCari_VardiyaTur)).items);

    if TGirisKutusuEx.BilgiAlEx(BGVardiya_Tur_Sec,Ctrls) <> mrOk then Abort;

    Tablo.TablodanSorguAc(1,'SELECT * from REHBERBILGI WHERE SIRA=21 AND YERI=21 AND YER_ID='+IntToStr(RehberID));
    if not Tablo.Query1.IsEmpty then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE REHBERBILGI SET BILGI=&BILGI, DEGISTIREN=&DEGISTIREN, DEGISTIRMETARIHI=GETDATE() '+
      'WHERE YER_ID=&YERID AND SIRA=21 AND YERI=21',['&YERID','&BILGI','&DEGISTIREN'],[RehberID,TurAdi,Kullanan])
    else
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBERBILGI (YER_ID, BILGI, SIRA, YERI, EKLEYEN, EKLEMETARIHI)'+
      ' VALUES(&YER_ID, &BILGI, &SIRA, &YERI, &EKLEYEN, GETDATE())',
      ['&YER_ID','&BILGI','&SIRA','&YERI','&EKLEYEN'],[RehberID,TurAdi,21,21,Kullanan]);
  end
  else
  begin
    raise Exception.Create(CRKart_bulunamadi);
  end;
end;


procedure TRehberAraDlg.btnCRMClick(Sender: TObject);
begin
  Tablo.RehberSihirbazBaslat(RehAyarYeri_CRM, REHBER.Fields[0].AsInteger,-1, -1, AktifSekme='TAksiyonlarGorevFrame')
end;

procedure TRehberAraDlg.ComboGrupPropertiesCloseUp(Sender: TObject);
Var
  SQL : String;
begin
  AraTusClick(nil);

  {BorcAlacakKolonlari(0);

  REHBER.Close;
  SubSelectGetir;
  SQL := SorguyaTabloEkle(StringReplace(SQLMemo.Text,'<Param>',' '+Paramst+' ',[rfReplaceAll]));
  REHBER.SQL.Text := SQL;
  if FArama.ComboGrup.EditValue > 0 then
   REHBER.SQL.Add(' and R.GRUP = '+IntToStr(FArama.ComboGrup.EditValue));
  if not FArama.CheckPasifler.Checked then
   REHBER.SQL.Add(' and R.DURUM> 1 ');
  if SubeVarmi then
   REHBER.SQL.Add(' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ');

  if FArama.AraYetkili.Text <> '' then
     Param := 1
  else
     Param := 0;
  //REHBER.open;
  TabloYenile(REHBER,[Param]); }
end;

procedure TRehberAraDlg.ComboKategoriPropertiesCloseUp(Sender: TObject);
var
  SQL : String;
begin
  AraTusClick(nil);
  {BorcAlacakKolonlari(0);

  REHBER.Close;
  SubSelectGetir;
  SQL := SorguyaTabloEkle(StringReplace(SQLMemo.Text,'<Param>',' '+Paramst+' ',[rfReplaceAll]));
  REHBER.SQL.Text := SQL;
  if FArama.ComboKategori.EditValue > 0 then
   REHBER.SQL.Add(' and R.KATEGORI = '+IntToStr(FArama.ComboKategori.EditValue));
  if SubeVarmi then
   REHBER.SQL.Add(' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ');

  if not FArama.CheckPasifler.Checked then
    REHBER.SQL.Add(' and R.DURUM> 0 ');

  if FArama.AraYetkili.Text <> '' then
     Param := 1
  else
     Param := 0;
  //REHBER.open;
  TabloYenile(REHBER,[Param]);}
end;

procedure TRehberAraDlg.ComboBolgePropertiesCloseUp(Sender: TObject);
var
  SQL : String;
begin
  AraTusClick(nil);
  {BorcAlacakKolonlari(0);

  REHBER.Close;
  SubSelectGetir;
  SQL := SorguyaTabloEkle(StringReplace(SQLMemo.Text,'<Param>',' '+Paramst+' ',[rfReplaceAll]));
  REHBER.SQL.Text := SQL;
  if FArama.ComboBolge.EditValue > 0 then
   REHBER.SQL.Add(' and R.BOLGE = '+IntToStr(FArama.ComboBolge.EditValue));
  if SubeVarmi then
   REHBER.SQL.Add(' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ');

  if not FArama.CheckPasifler.Checked then
    REHBER.SQL.Add(' and R.DURUM> 0 ');

  if FArama.AraYetkili.Text <> '' then
     Param := 1
  else
     Param := 0;
  //REHBER.open;
  TabloYenile(REHBER,[Param]);  }

end;

procedure TRehberAraDlg.ComboSinifPropertiesCloseUp(Sender: TObject);
Var
  SQL : String;
begin
  AraTusClick(nil);
  {BorcAlacakKolonlari(0);

  REHBER.Close;
  SubSelectGetir;
  SQL := SorguyaTabloEkle(StringReplace(SQLMemo.Text,'<Param>',' '+Paramst+' ',[rfReplaceAll]));
  REHBER.SQL.Text := SQL;
  if FArama.ComboSinif.ItemIndex > 0 then
   REHBER.SQL.Add(' and R.SINIF = '+IntToStr(FArama.ComboSinif.EditValue));
  if not FArama.CheckPasifler.Checked then
   REHBER.SQL.Add(' and R.DURUM> 0 ');
  if SubeVarmi then
   REHBER.SQL.Add(' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ');

  if FArama.AraYetkili.Text <> '' then
     Param := 1
  else
     Param := 0;
  //REHBER.open;
  TabloYenile(REHBER,[Param]); }

end;

procedure TRehberAraDlg.BorAlacakKapama1Click(Sender: TObject);
begin
  //
end;

procedure TRehberAraDlg.BorcAlacakKolonlari(Index : integer);
begin
   CariGridViewSEC.Visible := Index in [1..5];
   if CariGridViewSEC.Visible then
      CariGridViewSEC.Index := 0;
   CariGridViewBORC.Visible := Index in [1..5];
   CariGridViewALACAK.Visible := CariGridViewBORC.Visible;
   CariGridViewBAKIYE.Visible := CariGridViewBORC.Visible;
   CariGridViewTAKIPTE.Visible := CariGridViewBORC.Visible;
   CariGridViewIRSALIYE.Visible := CariGridViewBORC.Visible;
   CariGridViewYASLANDIRMA.Visible := Index in [3..5];
   CariGridViewVADE.Visible := CariGridViewYASLANDIRMA.Visible;
   CariGridViewFARK.Visible := CariGridViewYASLANDIRMA.Visible;
   TabSheetYaslandirma.TabVisible := CariGridViewBORC.Visible;; //bakiye var ise g?r?necek..
   CariGridViewKUR.Visible := CariGridViewBORC.Visible;

   CariGridViewSONAKTIVITEKONUSU.Visible := Index = 6;
   CariGridViewSONAKTIVITETARIHI.Visible := Index = 6;
   CariGridViewSONSATBELGETARIHI.Visible := Index = 6;
   CariGridViewSONSATTUTARI.Visible := Index = 6;
//   CariGridView.OptionsView.Footer := Gorunme;
end;

procedure TRehberAraDlg.KapatAc(Kolon : TcxGridDBColumn; Gor:Boolean);
begin
   Kolon.Visible:= Gor;
   Kolon.VisibleForCustomization := Gor;
end;

procedure TRehberAraDlg.ComboCariPropertiesCloseUp(Sender: TObject);
var s:string[3];
begin
   //soldaki cari analize g?re grid ayarlar? y?klenir
   case FArama.ComboCariAnaliz.Itemindex of
     1..5: s:='BA';
     else s:='';
     //6 :s:='CRM'
   end;

   //se?ilebilmesi i?in edit moda ge?mesi laz?m
   CariGridView.OptionsData.Editing := FArama.ComboCariAnaliz.Itemindex in [1..5];

   KapatAc(CariGridViewBORC, FArama.ComboCariAnaliz.Itemindex in [1..5]);
   KapatAc(CariGridViewALACAK, FArama.ComboCariAnaliz.Itemindex in [1..5]);
   KapatAc(CariGridViewKUR, FArama.ComboCariAnaliz.Itemindex in [1..5]);
   KapatAc(CariGridViewBAKIYE, FArama.ComboCariAnaliz.Itemindex in [1..5]);
   KapatAc(CariGridViewTAKIPTE, FArama.ComboCariAnaliz.Itemindex in [1..5]);
   KapatAc(CariGridViewIRSALIYE, FArama.ComboCariAnaliz.Itemindex in [1..5]);

   KapatAc(CariGridViewYASLANDIRMA, FArama.ComboCariAnaliz.Itemindex in [3..4]);
   KapatAc(CariGridViewVADE, FArama.ComboCariAnaliz.Itemindex in [3..4]);

   Tablo.GridAyarRestore('CariListeGridi'+s, CariGridView );

   BorcAlacakKolonlari(FArama.ComboCariAnaliz.ItemIndex);
   AraTusClick(Self);
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.CheckDetayClick(Sender: TObject);
begin
   FArama.PanelCRM.visible := FArama.CheckDetay.Checked;

   KapatAc(CariGridViewALTSEKTOR, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewNOTLAR, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewTEMSILCIAD, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewADRES, FArama.CheckDetay.Checked);

   KapatAc(CariGridViewILLER, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewILCE, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewBOLGE, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewALTBOLGE, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewSUBEID, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewOZELKOD, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewYETKIKODU, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewMUHKODU, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewSONAKTIVITEKONUSU, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewSONAKTIVITETARIHI, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewSONSATBELGETARIHI, FArama.CheckDetay.Checked);
   KapatAc(CariGridViewSONSATTUTARI, FArama.CheckDetay.Checked);

   if FArama.CheckDetay.Checked then
      s:='CRM'
   else
      s:='';
   Tablo.GridAyarRestore('CariListeGridi'+s, CariGridView );
   //AraTusClick(Self);
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.Label1Click(Sender: TObject);
begin
   CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
end;

procedure TRehberAraDlg.LabelSonArananlarClick(Sender: TObject);
begin
  // Son Aranan: KULLANICI_ARAMA (MODUL_Cari) DEGISTIRMETARIHI desc -> sunucu-tarafi SP
  if (FArama.ComboCariAnaliz.visible)and(FArama.ComboCariAnaliz.ItemIndex > 0 ) then
      FArama.ComboCariAnaliz.ItemIndex:=0;
  BorcAlacakKolonlari(0);
  CheckDetayClick(self);
  Liste_SP_Cagir(5);
end;

procedure TRehberAraDlg.LabelSikArananlarClick(Sender: TObject);
begin
  // Sik Aranan: KULLANICI_ARAMA (MODUL_Cari) SAY desc -> sunucu-tarafi SP
  if (FArama.ComboCariAnaliz.visible)and(FArama.ComboCariAnaliz.ItemIndex > 0 ) then
      FArama.ComboCariAnaliz.ItemIndex:=0;
  BorcAlacakKolonlari(0);
  CheckDetayClick(self);
  Liste_SP_Cagir(3);
end;

procedure TRehberAraDlg.LabelStandartAvansDblClick(Sender: TObject);
var
  OdemeKaynagi,Tutar:Variant;
  RehberID:string;
  mResult:TModalResult;
begin
  RehberID := REHBER.FieldByName('ID').AsString;
  Tablo.TablodanSorguAc(1,'SELECT * FROM dbo.PLANMAAS WHERE YER=61 AND YERID='+RehberID);
  if not Tablo.Query1.IsEmpty then
  begin
    OdemeKaynagi := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SELECT '+DbUst(1)+'TUR FROM PLANMAAS WHERE YER=61 AND YERID=&YERID '+DbSinir(1),['&YERID'],[RehberID],True);
    Tutar := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SELECT '+DbUst(1)+'TUTAR FROM PLANMAAS WHERE YER=61 AND YERID=&YERID '+DbSinir(1),['&YERID'],[RehberID],True);
    mResult := TGirisKutusuEx.BilgiAlEx(BGAvans_miktari,TGirdiDenetimleri.Create
    .ImageComboBox('�deme kayna��',@OdemeKaynagi,Tablo.FDCnn,'SELECT ''B'' TUR, ''Banka'' ADI UNION ALL SELECT ''K'' TUR, ''Kasa''')
    .CurrencyEdit('�denecek avans miktar�',@Tutar,2));

    if mResult = mrOk then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE PLANMAAS SET TUTAR=&TUTAR, DEGISTIREN=&DEGISTIREN,'+
      ' DEGISTIRMETARIHI=GETDATE(),TUR=&TUR WHERE YER=61 AND YERID=&YERID',
        ['&TUTAR','&YERID','&DEGISTIREN','&TUR'], [FCurrToStr(Tutar),RehberID,Kullanan,OdemeKaynagi]);
      //LabelStandartAvans.Caption := FCurrToStr(Tutar) + ' ' + CariDoviz;
    end;
  end else begin
    Tutar := 0;
    OdemeKaynagi := 'K';
    mResult := TGirisKutusuEx.BilgiAlEx(BGAvans_miktari,TGirdiDenetimleri.Create
    .ImageComboBox('�deme kayna��',@OdemeKaynagi,Tablo.FDCnn,'SELECT ''B'' TUR, ''Banka'' ADI UNION ALL SELECT ''K'' TUR, ''Kasa''')
    .CurrencyEdit('Avans tutar�',@Tutar,2));

    if mResult = mrOk then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO PLANMAAS (TUTAR,YER,YERID,KUR,TUR,EKLEYEN,EKLEMETARIHI)'+
        ' VALUES(&TUTAR,61,&YERID,&KUR,&TUR,&EKLEYEN,GETDATE())',
        ['&TUTAR','&YERID','&KUR','&TUR','&EKLEYEN'], [FCurrToStr(Tutar),RehberID,CariDoviz,OdemeKaynagi,Kullanan]);
      //LabelStandartAvans.Caption := FCurrToStr(Tutar) + ' ' + CariDoviz;;
    end;
  end;
end;

procedure TRehberAraDlg.LabelTumKayitlarClick(Sender: TObject);
begin
  // Tum Kayitlar: TOP yok, order by 1 -> sunucu-tarafi SP
  if (FArama.ComboCariAnaliz.visible)and(FArama.ComboCariAnaliz.ItemIndex > 0 ) then
      FArama.ComboCariAnaliz.ItemIndex:=0;
  BorcAlacakKolonlari(0);
  CheckDetayClick(self);
  Liste_SP_Cagir(1);
end;

procedure TRehberAraDlg.letiimaddeitir1Click(Sender: TObject);
var EtiAdi : Variant;
begin
   EtiAdi := REHBERILETISIM.FieldByName('AD').AsString;
   if  TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
       TGirdiDenetimleri.Create.Edit(IletisimAdiniGirin,@EtiAdi)) = mrOK then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBERILETISIM Set AD='''+EtiAdi+''' Where AKTIF=1 and REHBERID=&RehID and ID=&IletID',['&RehID','&IletID'],[REHBER.FieldByName('ID').AsInteger,REHBERILETISIM.FieldByName('ID').AsInteger]);
       PageControlSekmeChange(nil);
       REHBERILETISIM.Locate('ID',REHBERILETISIM.FieldByName('ID').Value,[]);
   end;
end;

procedure TRehberAraDlg.lgiligemiinigster1Click(Sender: TObject);
var st : Tstringlist;
begin

end;

procedure TRehberAraDlg.lgiliKurumdanAyrld1Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBER set STATU=0 , DURUM='+IntToStr(TMenuItem(Sender).Tag)+' where ID=&ID',['&ID'],[TabRehberIlgili.FieldByName('ID').AsInteger]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KULLANICI set DURUM=0 where REHBERID=&ID ',['&ID'],[TabRehberIlgili.FieldByName('ID').AsInteger]);
  TabRehberIlgili.close;
  TabRehberIlgili.open;
  cxGridPersonellerSelectionChanged(nil);
end;

procedure TRehberAraDlg.lgiliyiKopyala1Click(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi := TabRehberIlgili.FieldByName('FIRMA').AsString;
  ctrls := TGirdiDenetimleri.Create.Edit(RDYeniilgiliADSoyadGir,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(RDAdSoyad, ctrls) = mrOk then begin
    Tablo.TablodanSorguAc(3,('insert into REHBER(BAGID, FIRMA, STATU, GRUP, NOTLAR, DURUM,SUBEID) values('+REHBER.FieldByName('ID').AsString+','''+Bilgi+''',0,334,'''+TabRehberIlgili.FieldByName('NOTLAR').AsString+''',1,'+IntToStr(SubeId)+') select scope_identity() '));
    Tablo.TablodanSorguAc(4,('insert into REHBERILETISIM(REHBERID,AD,VARSAYILAN,AKTIF,SUBEID) values('+Tablo.Query3.Fields[0].AsString+',''Merkez'',1,1,'+IntToStr(SubeId)+') select scope_identity() '));
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,SUBEID) '+
         ' select 1,&Yer_ID,SIRA,ETIKET,BILGI,SUBEID from REHBERBILGI where YERI=1 and YER_ID=(select ID from REHBERILETISIM where REHBERID=&YerID2)',['&Yer_ID','&YerID2'],[Tablo.Query4.Fields[0].AsInteger,
          TabRehberIlgili.FieldByName('ID').AsInteger]);
    TabRehberIlgili.close;
    TabRehberIlgili.open;
    cxGridPersonellerSelectionChanged(nil);
  end;
end;

(*function TRehberAraDlg.SorguyaTabloEkle(SQL:String):string;
begin
//  if CariGridViewTEMSILCIAD.Visible then
    SQL := SQL + ' left outer join REHBER R2 on R2.ID=R.TEMSILCI ';
//  if CariGridViewKATEGORI.Visible then
//    SQL := SQL + ' left outer join GENINI CariKategori on CariKategori.BOLUM=-2204 and CariKategori.DEGER=R.KATEGORI and CariKategori.DIL='+IntToStr(Dil)+
//                 ' left outer join GENINI CariGorev on CariGorev.BOLUM=-2205 and CariGorev.DEGER=R.KATEGORI and CariGorev.DIL='+IntToStr(Dil);
//  if CariGridViewILLER.Visible then
    SQL := SQL + ' left outer join (Select R1.ID,RB.BILGI from REHBER R1 left outer join REHBERILETISIM RI on R1.ID=RI.REHBERID and RI.VARSAYILAN=1 Left outer join REHBERBILGI RB on RB.YER_ID=RI.ID '+
                 ' left outer join REHBERAYAR RA on RA.SIRA=RB.SIRA AND RA.YERI=1 Where RI.VARSAYILAN=1 and RB.YERI=1 and RA.VARSAYILAN=8) X on X.ID=R.ID  ';
    //25.07.2024 AO Fat. ba?l???nda da arayabilmesi i?in eklendi..
    SQL := SQL + ' LEFT OUTER JOIN (SELECT YER_ID,RB.BILGI FROM REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10) X1 ON X1.YER_ID = R.ID	';
    if SonAranan then
       SQL := SQL + ' inner join KULLANICI_REHBER K on K.REHBERID=R.ID and K.KULID='+Kullanan+' ';

  SQL := SQL + ' where R.GRUP<>334 and R.GRUP<>335 and R.ID > 1 ';

  Result:=SQL;
end;   *)
function TRehberAraDlg.SorguyaTabloEkle(SQL:String):string;
begin
    SQL := SQL +'LEFT OUTER JOIN REHBER R2 WITH (NOLOCK) ON R2.ID = R.TEMSILCI ' +
    DbDisApply+' ( ' +
    '    SELECT '+DbUst(1)+'RB.BILGI FROM REHBERBILGI RB WITH (NOLOCK) ' +
    '    INNER JOIN REHBERAYAR RA WITH (NOLOCK) ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10 ' +
    '    WHERE RB.YER_ID = R.ID ' +
    DbSinir(1)+') X1 '+DbApplyKosul +
    DbDisApply+' ( ' +
    '    SELECT '+DbUst(1)+'K_Inner.SAY,K_Inner.DEGISTIRMETARIHI FROM KULLANICI_ARAMA K_Inner WITH (NOLOCK) ' +
    '    WHERE K_Inner.KAYITID = R.ID AND K_Inner.KULID = '+Kullanan+' AND K_Inner.MODUL = '+IntToStr(MODUL_Cari)+' ' +
    '    ORDER BY K_Inner.DEGISTIRMETARIHI DESC ' +
    DbSinir(1)+') K '+DbApplyKosul;

    SQL := SQL + ' where R.GRUP<>334 and R.GRUP<>335 and R.ID > 1 ';

    Result:=SQL;
end;


procedure TRehberAraDlg.SubSelectGetir;
var
  Kesilen:string;
  Uzunluk:integer;
begin
  // NOT: T-SQL 'ALIAS=expr' -> standart 'expr AS ALIAS' (her iki motorda da gecerli; PG
  //   'ALIAS=expr'i esitlik saniyor -> "column adsoyad does not exist"). Kaynakta cozuldu.
  // ADSOYAD = ILGILI (kontak): P = ilgili join (aramada eslesen; gozatmada default STATU'lu kontak),
  //   yoksa ilk siradaki kontak (COALESCE fallback). TEMSILCIAD ayri (R2.FIRMA = temsilci).
  Paramst :=' R.ID, R.KOD, R.FIRMA, COALESCE(P.FIRMA, (select '+DbUst(1)+'PA.FIRMA from REHBER PA where PA.BAGID=R.ID and PA.GRUP=334 order by PA.STATU desc, PA.ID '+DbSinir(1)+')) AS ADSOYAD, X1.BILGI AS FATBASLIK, R.GRUP, R.TEMAS, R.SEKTOR, R.KATEGORI, R.SINIF, R.DURUM, R.OZELKOD, R2.FIRMA AS TEMSILCIAD ';
  if (FArama.ComboCariAnaliz.Visible)and(FArama.ComboCariAnaliz.Itemindex in [1..5]) then
        Paramst :=Paramst + ' ,TOPLAM_BORC,TOPLAM_ALACAK,KUR,TOPLAM_BORC-TOPLAM_ALACAK AS BAKIYE, TAKIPTE,IRSALIYE '
  else if FArama.CheckDetay.Checked then begin
        Paramst :=Paramst + ',ALTSEKTOR=(select ANAHTAR from GENINI G where G.DIL=-1 and G.DEGER = R.ALTSEKTOR AND G.BOLUM=cast(''-2204''+cast(R.SEKTOR as varchar(10)) as int)),ILLER= X1.BILGI, '+
          ' ADRES = (SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI RB (nolock)'+
          '   INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
          '   INNER JOIN REHBERILETISIM RI (nolock) on R.ID=RI.REHBERID and RI.VARSAYILAN=1 WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=2 '+DbSinir(1)+'), '+
          ' ILCE=(SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI RB (nolock)'+
          '   INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
          '   INNER JOIN REHBERILETISIM RI (nolock) on R.ID=RI.REHBERID and RI.VARSAYILAN=1 WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=6 '+DbSinir(1)+'), '+
          ' IL=(SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI RB (nolock)'+
          '   INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
          '   INNER JOIN REHBERILETISIM RI (nolock) on R.ID=RI.REHBERID and RI.VARSAYILAN=1 WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=8 '+DbSinir(1)+'), '+
          ' ULKE=(SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI RB (nolock)'+
          '   INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
          '   INNER JOIN REHBERILETISIM RI (nolock) on R.ID=RI.REHBERID and RI.VARSAYILAN=1 WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=9 '+DbSinir(1)+'), '+

          ' GSM=(SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI RB (nolock)'+
          '   INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
          '   INNER JOIN REHBERILETISIM RI (nolock) on R.ID=RI.REHBERID and RI.VARSAYILAN=1 WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=42 '+DbSinir(1)+'), '+
          ' VERGINO=(SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI RB (nolock)'+
          '   INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
          '   INNER JOIN REHBERILETISIM RI (nolock) on R.ID=RI.REHBERID and RI.VARSAYILAN=1 WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22 '+DbSinir(1)+'), '+


          ' R.BOLGE,ALTBOLGE=  (select ANAHTAR from GENINI G where G.DIL=-1 and G.DEGER = R.ALTBOLGE AND G.BOLUM=cast(''-2210''+cast(R.BOLGE as varchar(10)) as int)),'+
          ' R.SUBEID,NOTLAR=(Select '+DbUst(1)+'GY.YORUM from GOREVYORUM GY where R.ID=GY.GOREVID and GY.TUR=11 order by GY.TARIH desc '+DbSinir(1)+'), R.YETKIKODU, R.MUHKODU';

            Paramst :=Paramst + ' ,R.EKLEMETARIHI, SONAKTIVITEKONUSU = (SELECT '+DbUst(1)+'KONUSU FROM GOREVLER A WHERE A.REHBERID=R.ID ORDER BY BITISTARIHI DESC   '+DbSinir(1)+')';
//        if CariGridViewSONAKTIVITETARIHI.Visible then
            Paramst :=Paramst + ' ,SONAKTIVITETARIHI =  (SELECT '+DbUst(1)+DbConv('(BITISTARIHI)','DateTime',101)+' AS BITISTARIHI FROM GOREVLER A  '+
            'WHERE  A.REHBERID =R.ID  ORDER BY BITISTARIHI DESC '+DbSinir(1)+')';
  //      if CariGridViewSONSATBELGETARIHI.Visible then
            Paramst :=Paramst + ' ,SONSATBELGETARIHI = (SELECT '+DbUst(1)+' '+DbConv('(FATURATARIH)','DateTime',103)+' as FATURATARIH FROM FATBASLIK F  WHERE  F.TUR  in (10,11,12,14,15,16) and F.REHBERID =R.ID  ORDER BY FATURATARIH DESC '+DbSinir(1)+') ';
    //    if CariGridViewSONSATTUTARI.Visible then
            Paramst :=Paramst + ' ,SONSATTUTARI = (SELECT '+DbUst(1)+' FATURA_TUTARI FROM FATBASLIK F  WHERE  F.TUR  in (10,11,12,14,15,16) and F.REHBERID =R.ID  ORDER BY FATURATARIH DESC '+DbSinir(1)+') ';
  end;
  Uzunluk := Length(Paramst)-4;
  Kesilen := Copy(Paramst,Uzunluk,5);
  if pos(',',Kesilen)>0 then begin
     Kesilen := StringReplace(kesilen,',','',[rfReplaceAll]);
     Paramst   := StringReplace(Paramst, kesilen+',',kesilen,[rfReplaceAll]);
  end;
end;

procedure TRehberAraDlg.AraTusClick(Sender :TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TRehberAraDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
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
       CalendarEkstreBasPropertiesEditValueChanged(Self);
    end;
    DokumDegiskenListesi.Add(KontrolBaslangisTarihi+'$@$'+DateToStr(CalendarEkstreBas.Date));
    DokumDegiskenListesi.Add(KontrolBitisTarihi+'$@$'+DateToStr(CalendarEkstreBit.Date));
    frxREHBER.DataSet := REHBER;
    AFastReport.EnabledDataSets.Add(frxREHBER);
    AFastReport.EnabledDataSets.Add(frxEkstre);
    AFastReport.EnabledDataSets.Add(frxYaslandirma);
  end else if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxRehber) then begin
    AFastReport.EnabledDataSets.Add(frxREHBER);
  end else begin
    frxREHBER.DataSet := REHBER;
    AFastReport.EnabledDataSets.Add(frxREHBER);
    AFastReport.EnabledDataSets.Add(frxYaslandirma);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', REHBER.FieldByName('ID').AsString, [rfReplaceAll]);
    if AktifVeriMotor = vmPG then Tablo.TabMusteri.SQL.Text := PgSqlCevir(Tablo.TabMusteri.SQL.Text);
    Tablo.TabMusteri.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
  end;
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  // Kullanici ek alanlari (_USER) rapora (cari karti).
  if REHBER.Active and (not REHBER.IsEmpty) then
    Tablo.UserAlanYazdirmaEkle(AFastReport, 'REHBER', REHBER.FieldByName('ID').AsInteger);
end;

procedure TRehberAraDlg.BankaDuzenleTusClick(Sender: TObject);
begin
   Tablo.BankaTanimSihirbazBaslat('D', 1, TabBankaHesaplar.Fields[0].AsInteger, REHBER.Fields[0].AsInteger);
end;

procedure TRehberAraDlg.BankaEkleTusClick(Sender: TObject);
var ID:Integer;
    Key: Word;
begin
   ID := Tablo.BankaTanimSihirbazBaslat('E', 1, -1, REHBER.Fields[0].AsInteger);
   Key := 0;
   if ID > 0 then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.BankaSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := ' select '+DbUst(1)+'ISLEMTARIHI from KASA where HESAPTURU=''B'' and HESAPID='+TabBankaHesaplar.Fields[0].AsString+' AND TUR<>1 '+DbSinir(1);
     if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
     Tablo.Query1.Open;
     if not Tablo.Query1.IsEmpty then
        raise Exception.Create(Tablo.Query1.Fields[0].AsString+RDGirilmisBankaBilgisiVarSilinemez);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from BANKAHESAPLAR where ID=&id ',['&id'],[TabBankaHesaplar.Fields[0].AsInteger]);
     PageControlSekmeChange(Self);
  end;
end;

{ ---------- Alias sekmesi (REHBERALIAS) ---------- }

procedure TRehberAraDlg.AliasToolbarDurumuGuncelle(DuzenlemeKipinde: Boolean);
// Yeni/Sil/DÃ¼zenle butonlarÄ± normal modda gÃ¶rÃ¼nÃ¼r; Kaydet/Ä°ptal Edit/Insert modunda.
begin
  ToolButton17.Visible := not DuzenlemeKipinde;   // Yeni
  ToolButton19.Visible := not DuzenlemeKipinde;   // Sil
  ToolButton21.Visible := not DuzenlemeKipinde;   // DÃ¼zenle
  ToolButton22.Visible := DuzenlemeKipinde;       // Kaydet
  ToolButton23.Visible := DuzenlemeKipinde;       // Ä°ptal
end;

procedure TRehberAraDlg.TabAliasNewRecord(DataSet: TDataSet);
// Yeni alias satÄ±rÄ±nda zorunlu kolonlarÄ±n varsayÄ±lan deÄŸerlerini set et.
begin
  if (REHBER = nil) or REHBER.IsEmpty then Exit;
  DataSet.FieldByName('REHBERID').AsInteger        := REHBER.Fields[0].AsInteger;
  DataSet.FieldByName('BELGETURU').AsInteger       := 0;
  DataSet.FieldByName('ALIAS').AsString            := '';
  DataSet.FieldByName('VARSAYILAN').AsBoolean      := False;
  DataSet.FieldByName('AKTIF').AsBoolean           := True;
  DataSet.FieldByName('ILKKAYITTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  DataSet.FieldByName('SONKONTROLTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
end;

procedure TRehberAraDlg.AliasYeniTusClick(Sender: TObject);
begin
  if (REHBER = nil) or REHBER.IsEmpty then Exit;
  if not TabAlias.Active then begin
    TabAlias.Close;
    TabAlias.SQL.Text := 'SELECT * FROM REHBERALIAS WHERE REHBERID = ' +
                         IntToStr(REHBER.Fields[0].AsInteger);
    if AktifVeriMotor = vmPG then TabAlias.SQL.Text := PgSqlCevir(TabAlias.SQL.Text);
    TabAlias.Open;
  end;
  TabAlias.Append;
  AliasToolbarDurumuGuncelle(True);
end;

procedure TRehberAraDlg.AliasDuzenleTusClick(Sender: TObject);
begin
  if (not TabAlias.Active) or TabAlias.IsEmpty then Exit;
  TabAlias.Edit;
  AliasToolbarDurumuGuncelle(True);
end;

procedure TRehberAraDlg.AliasSilTusClick(Sender: TObject);
begin
  if (not TabAlias.Active) or TabAlias.IsEmpty then Exit;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    TabAlias.Delete;
    AliasToolbarDurumuGuncelle(False);
  end;
end;

procedure TRehberAraDlg.AliasKaydetTusClick(Sender: TObject);
begin
  if not TabAlias.Active then Exit;
  if TabAlias.State in [dsEdit, dsInsert] then begin
    // ALIAS boÅŸsa kaydetmeye izin verme
    if Trim(TabAlias.FieldByName('ALIAS').AsString) = '' then begin
      Application.MessageBox('Alias deÄŸeri boÅŸ olamaz.', PChar(SGenotipOnay),
                             MB_ICONWARNING + MB_OK);
      Exit;
    end;
    // DÃ¼zenlemede son kontrol tarihini gÃ¼ncelle
    if TabAlias.State = dsEdit then
      TabAlias.FieldByName('SONKONTROLTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    TabAlias.Post;
  end;
  AliasToolbarDurumuGuncelle(False);
end;

procedure TRehberAraDlg.AliasIptalTusClick(Sender: TObject);
begin
  if TabAlias.State in [dsEdit, dsInsert] then
    TabAlias.Cancel;
  AliasToolbarDurumuGuncelle(False);
end;

procedure TRehberAraDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   if REHBER.Active then begin
      s := YaziciYaz.Caption;
      Delete(s, pos('&',s), 1);
      YazdirmayaHazirla(FastRaporDlg.frxReport1);
      FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
   end;
end;

procedure TRehberAraDlg.Baslatildi;
var ra : string;
    i  : Integer;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   // Tum/Son/Sik Aranan toolbar butonlarini list handler'larina bagla (sunucu-tarafi SP listeleme)
   if Assigned(FArama) then begin
     FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
     FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
     FArama.LabelSIKArananlar.OnClick := LabelSikArananlarClick;
   end;
    CariGridViewSUBEID.Visible := SubeVarmi;
   TabSheetYaslandirma.TabVisible := False;
   Tablo.GridAyarRestore('RehberProjelerGridi',GridCariProjelerView );
   Tablo.GridAyarRestore('RehberTicariBilGridi',GridBankaDBTableView1 );
   Tablo.GridAyarRestore('RehberEkstreHareket',GridCariEkstreView );
   Tablo.GridAyarRestore('CariListeGridi',CariGridView );
   //Tablo.GridAyarRestore('IsListesiGridi_Cari', GorevGridDBTableView1);
   Tablo.GridAyarRestore('RehberTeklifGridi',GridTeklifView );

  if not TarayiciKullanimda then begin
    BtnDosyaGonder.Kind := cxbkStandard;
    BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
    BtnDosyaGonder.DropDownMenu := nil;
  end;

  if not DovizTakibi then begin
    FreeAndNil(GridCariEkstreViewYERELTUTAR);
    FreeAndNil(GridCariEkstreViewYERELBAKIYE);
    FreeAndNil(GridCariEkstreViewYERELKUR);
  end;
  SatisEFaturaMenu.Visible:=EFaturaKullanimda>0;
  SatisCizgiMenu.Visible:=EFaturaKullanimda>0;
  AlisEFaturaMenu.Visible:=EFaturaKullanimda>0;
  AlisCizgiMenu.Visible:=EFaturaKullanimda>0;
  ComboTamamlanan.ItemIndex := 0;
  PageControlSekme.ActivePage := TabSheetIlet;
  Tablo.GridTurkcelestir;

   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;
   //GroupBanka.Visible := Tablo.YetkiVarmi(22013011,YetkiTur_Gorme);

   if not TamYetkili then begin
      YeniTus.Visible := Tablo.YetkiVarmi(2201,YetkiTur_Ekleme);
      DegisTus.Visible := Tablo.YetkiVarmi(2201,YetkiTur_Degistirme);
      SilTus.Visible :=  Tablo.YetkiVarmi(2201,YetkiTur_Silme);
   end;
   if not(Tablo.YetkiVarmi(2201,YetkiTur_Degistirme)) then
     CariGridView.OnDblClick := nil;

  if (not Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme))and(not Tablo.YetkiVarmi(220185,YetkiTur_Gorme)) then begin
    BtnCRM.Visible:=False;
    BtnCRM.Tag:=99;
  end;

  if (not Tablo.YetkiVarmi(MODUL_Kasa,YetkiTur_Gorme))and(not Tablo.YetkiVarmi(220186,YetkiTur_Gorme)) then begin //Kasa mod?l? al?nmam??sa
    AksiyonEkleTus.Visible:=False;
    AksiyonEkleTus.Tag:=99;
  end else begin//e?er al?nm??sa POS, kredikarti, cekneler al?nd?ysa men?lerini a?al?m / Kapatal?m
    POSTahsilMenu.Visible := Tablo.YetkiVarmi(2521,YetkiTur_Gorme);//POS
    KrediKartiOdeMenu.Visible := Tablo.YetkiVarmi(253130,YetkiTur_Gorme);
    CekTahsilMenu.Visible := Tablo.YetkiVarmi(2551,YetkiTur_Gorme);
    SenetTahsilMenu.Visible := CekTahsilMenu.Visible;
    CekOdeMenu.Visible := CekTahsilMenu.Visible;
    SenetOdeMenu.Visible := CekTahsilMenu.Visible;
  end;

   if not Tablo.YetkiVarmi(220110,YetkiTur_Gorme) then TabSheetIlet.TabVisible:=False;
   if not Tablo.YetkiVarmi(220120,YetkiTur_Gorme) then TabSheetIlgili.TabVisible:=False;
   if not Tablo.YetkiVarmi(220130,YetkiTur_Gorme) then TabSheetTicari.TabVisible:=False;

   BorcAlacakKapamaMenu.Visible := Tablo.YetkiVarmi(242103,YetkiTur_Gorme);
   if (not Tablo.YetkiVarmi(MODUL_Dokuman,YetkiTur_Gorme))or(not Tablo.YetkiVarmi(220135,YetkiTur_Gorme)) then  //Dokman sat?n al?nmad?ysa direk kapat
      tabYorumMedya.TabVisible:=False
   else  //sat?n al?nd?ysa yetkisi var m??
      if not Tablo.YetkiVarmi(220135,YetkiTur_Gorme) then tabYorumMedya.TabVisible:=False;

   // ---- CRM sekmesi (Is Listesi / Satis Firsatlari / Projeler) ----
   //   Iki kademe: once MODUL LISANSI, sonra ROL yetkisi.
   //   CRM sekmesinin kendisi alt sekmelere BAGLI: ucunden hicbirini gorme
   //   yetkisi yoksa CRM sekmesi HIC gorunmez; birine bile yetki varsa CRM
   //   gorunur ve altinda yalniz yetkili olduklari kalir. (09.08.2026)
   if (not Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme)){or(not Tablo.YetkiVarmi(21,YetkiTur_Gorme))} then begin
       TabSheetGorev.TabVisible:=False;
       TabSheetProje.TabVisible:=False;
       TabSheetFirsat.TabVisible:=False;
       FArama.CheckPotansiyel.checked := False;
       FArama.CheckPotansiyel.Visible:=False;
   end else
       if TamYetkili = False then begin //al?nd?ysa yetki kontrol? yap?l?r
          TabSheetGorev.TabVisible := CRMGorevListe;
          if not Tablo.YetkiVarmi(220140,YetkiTur_Gorme) then
             TabSheetFirsat.TabVisible:=False;
          if not Tablo.YetkiVarmi(220155,YetkiTur_Gorme) then
             TabSheetProje.TabVisible:=False;
          if (not Tablo.YetkiVarmi(2111,YetkiTur_Ekleme,False)) or (not Tablo.YetkiVarmi(2111,YetkiTur_Gorme,False))then begin//proje ekleme yetkisi
             GridCariProjeler.PopupMenu := Nil;
             ProjeEkleTus.Visible := False;
          end;
          if (not Tablo.YetkiVarmi(2111,YetkiTur_Degistirme,False)) or (not Tablo.YetkiVarmi(2111,YetkiTur_Gorme,False))then begin//proje de?i?tirme yetkisi
              GridCariProjelerView.OnDblClick := Nil;
              ProjeDuzenle.Visible := False;
              ProjeSilTus.Visible := False;
          end;
        end;

   // CRM sekmesi: alt sekmelerden EN AZ BIRI gorunuyorsa gorunur.
   //   Ucu de kapaliysa bos bir sekme birakmanin anlami yok.
   TabSheetCRM.TabVisible := TabSheetGorev.TabVisible or
                             TabSheetFirsat.TabVisible or
                             TabSheetProje.TabVisible;
   if TabSheetCRM.TabVisible then begin
      // Ilk gorunen alt sekme etkin olsun (gizli sekme etkin kalirsa bos gorunur)
      if TabSheetGorev.TabVisible then
         PageControlCRM.ActivePage := TabSheetGorev
      else if TabSheetFirsat.TabVisible then
         PageControlCRM.ActivePage := TabSheetFirsat
      else
         PageControlCRM.ActivePage := TabSheetProje;
   end;


   if not Tablo.YetkiVarmi(29,YetkiTur_Gorme) or not Tablo.YetkiVarmi(220170,YetkiTur_Gorme) then begin
     TabSheetTeklifler.TabVisible:=False;
     TabSheetTeklifler.Visible:=False;
   end;
   // ---- Alis/Satis sekmesi (siparis / irsaliye / konsinye) ----
   //   CRM ile AYNI desen: once MODUL LISANSI (2401 alis, 2411 satis), sonra
   //   belge turu bazinda ROL yetkisi. Alt sekmelerin hepsi kapaliysa ust sekme
   //   hic gorunmez. Yetki kodlari fatura listesi gorev frame'i ile AYNI.
   TabSheetAlisSip.TabVisible  := Tablo.YetkiVarmi(2401,YetkiTur_Gorme) and
                                  Tablo.YetkiVarmi(240111,YetkiTur_Gorme);
   TabSheetAlisIrs.TabVisible  := Tablo.YetkiVarmi(2401,YetkiTur_Gorme) and
                                  Tablo.YetkiVarmi(240121,YetkiTur_Gorme);
   TabSheetAlisKons.TabVisible := Tablo.YetkiVarmi(2401,YetkiTur_Gorme) and
                                  Tablo.YetkiVarmi(240171,YetkiTur_Gorme);
   TabSheetSatisSip.TabVisible  := Tablo.YetkiVarmi(2411,YetkiTur_Gorme) and
                                   Tablo.YetkiVarmi(241111,YetkiTur_Gorme);
   TabSheetSatisIrs.TabVisible  := Tablo.YetkiVarmi(2411,YetkiTur_Gorme) and
                                   Tablo.YetkiVarmi(241121,YetkiTur_Gorme);
   TabSheetSatisKons.TabVisible := Tablo.YetkiVarmi(2411,YetkiTur_Gorme) and
                                   Tablo.YetkiVarmi(241161,YetkiTur_Gorme);

   TabSheetAlisSatis.TabVisible := TabSheetAlisSip.TabVisible or
                                   TabSheetAlisIrs.TabVisible or
                                   TabSheetAlisKons.TabVisible or
                                   TabSheetSatisSip.TabVisible or
                                   TabSheetSatisIrs.TabVisible or
                                   TabSheetSatisKons.TabVisible;
   if TabSheetAlisSatis.TabVisible then begin
      // Ilk GORUNEN alt sekme etkin olsun; gizli sekme etkin kalirsa grid bos gorunur.
      for i := 0 to PageControlAlisSatis.PageCount - 1 do
        if PageControlAlisSatis.Pages[i].TabVisible then begin
           PageControlAlisSatis.ActivePage := PageControlAlisSatis.Pages[i];
           Break;
        end;
   end;

   // ---- Servis sekmesi (Servis / Musteri Ekipman / Rakip Ekipman) ----
   //   CRM ile AYNI desen: once MODUL LISANSI, sonra ROL yetkisi; ust sekme
   //   alt sekmelere bagli (hepsi kapaliysa Servis sekmesi hic gorunmez).
   //   Ekipman iki alt sekmesi eskiden Ekipman icindeki AYRI bir page control
   //   idi; ayni yetki (220180) ikisini birden yonetiyor.
   if not Tablo.YetkiVarmi(MODUL_Servis,YetkiTur_Gorme) then begin
     TabSheetServisListe.TabVisible:=False;
     TabSheetServisListe.Visible:=False;
   end;
   if not Tablo.YetkiVarmi(220180,YetkiTur_Gorme) then begin
     SheetBizimEkipman.TabVisible:=False;
     SheetBizimEkipman.Visible:=False;
     SheetRakipEkipman.TabVisible:=False;
     SheetRakipEkipman.Visible:=False;
   end;

   TabSheetServisAna.TabVisible := TabSheetServisListe.TabVisible or
                                   SheetBizimEkipman.TabVisible or
                                   SheetRakipEkipman.TabVisible;
   if TabSheetServisAna.TabVisible then begin
      if TabSheetServisListe.TabVisible then
         PageControlServis.ActivePage := TabSheetServisListe
      else if SheetBizimEkipman.TabVisible then
         PageControlServis.ActivePage := SheetBizimEkipman
      else
         PageControlServis.ActivePage := SheetRakipEkipman;
   end;


  EkstreGorunsun := Tablo.YetkiVarmi(220150,YetkiTur_Gorme);//(Modul.Kasa)and(Tablo.YetkiVarmi(220150,YetkiTur_Gorme));
  TabSheetEkstre.TabVisible := EkstreGorunsun;

  SilMenu.Visible:=SilTus.Visible;
  GorMenu.Visible := DegisTus.Visible;
  N18.Visible := DegisTus.Visible;
  //ExcelKolonAyarlar1.Visible := DegisTus.Visible;
  N19.Visible := DegisTus.Visible;
  CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
  CalendarEkstreBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));

  //PopupMenuYeni i?in belge yetkileri d?zenlemesi..
  AlisBelgesiMenu.Visible := Tablo.YetkiVarmi(2401,YetkiTur_Gorme);
  SatisBelgesiMenu.Visible := Tablo.YetkiVarmi(2411,YetkiTur_Gorme);
  if AlisBelgesiMenu.Visible then begin //2401 detaylar?
    Fatura1.Visible := Tablo.YetkiVarmi(240131,YetkiTur_Gorme);
    Fi1.Visible := Tablo.YetkiVarmi(240141,YetkiTur_Gorme);
    rsaliye1.Visible := Tablo.YetkiVarmi(240121,YetkiTur_Gorme);
    ahakkuk1.Visible := Tablo.YetkiVarmi(240151,YetkiTur_Gorme);
    Sipari2.Visible := Tablo.YetkiVarmi(240111,YetkiTur_Gorme);
  end;
  if SatisBelgesiMenu.Visible then begin //2411 detaylar?
    Fatura2.Visible := Tablo.YetkiVarmi(241131,YetkiTur_Gorme);
    Fi2.Visible := Tablo.YetkiVarmi(241141,YetkiTur_Gorme);
    rsaliye2.Visible := Tablo.YetkiVarmi(241121,YetkiTur_Gorme);
    ahakkuk2.Visible := Tablo.YetkiVarmi(241151,YetkiTur_Gorme);
    Sipari1.Visible := Tablo.YetkiVarmi(241111,YetkiTur_Gorme);
  end;
  if Sektor = Sektor_OtomotivServis then
    cxDBTreeList1cxDBTreeListSERINO.Caption.Text := 'Plaka No';
  FIlkSonAranan := True;   // ilk acilis: JvTimer'de Son Aranan (5) yuklensin
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;   // Cari acilista JvTimer kendiliginden tetiklenmiyor -> tetikle
end;

procedure TRehberAraDlg.Bayraklaretle1Click(Sender: TObject);
begin
  PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.BtnEkipmanDetayIptalClick(Sender: TObject);
begin
  TabEkipmanlar.Cancel;
end;

procedure TRehberAraDlg.BtnEkipmanDetayKaydetClick(Sender: TObject);
begin
  TabEkipmanlar.Post;
end;

procedure TRehberAraDlg.btnEkipmanDetaySilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI='+IntToStr(TabNo_EKIPMANREHBER)+' and YER_ID=&id ',['&id'],[TabEkipmanlar.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from EKIPMANREHBER where ID=&id ',['&id'],[TabEkipmanlar.FieldByName('ID').AsInteger]);
    //TabEkipmanlar.Delete;
     TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TRehberAraDlg.BtnEkipmanDetayYeniClick(Sender: TObject);
var
  Sonuclar : TStringList;
  UstIDID,i:Integer;
  s1,s2,s3 : String[10];
begin
  Sonuclar := TStringList.Create;
  UstIDID := 0;
  if Tablo.ListedenBilgiGetir(SERWServis_Ekipman,
    'select ID,KOD,AD,SAHIBI=(case when SAHIP=0 then ''Rakip'' else ''Kendi'' end),'+
    '  MARKASI = (case when E.SAHIP=0 then (select '+DbUst(1)+'ANAHTAR from GENINI where BOLUM=-2727 and DEGER=E.MARKA and DIL=-1 '+DbSinir(1)+')'+
    '        else (select '+DbUst(1)+'ANAHTAR from GENINI where BOLUM=-2701 and DEGER=E.MARKA and DIL=-1 '+DbSinir(1)+') end) ,'+
    '  MODELI = (case when E.SAHIP=0 then (select '+DbUst(1)+'ANAHTAR from GENINI where BOLUM=cast(''-2727''+cast(E.MARKA as varchar(10)) as int) and DEGER=E.MODEL and DIL=-1 '+DbSinir(1)+') '+
    '        else (select '+DbUst(1)+'ANAHTAR from GENINI where BOLUM=cast(''-2701''+cast(E.MARKA as varchar(10)) as int) and DEGER=E.MODEL and DIL=-1 '+DbSinir(1)+') end), '+
    ' SAHIP, MARKA, MODEL'+
    ' from EKIPMANLAR E where DURUM=1 and EKIPMANTUR=0 and AD like ''%<ara>%'' order by 2',Sonuclar,[nil,nil,nil,nil,nil,nil,nil,nil,nil],'RehAraDlgServisEkipman') then try
    Tablo.TablodanSorguAc(1,StringReplace(MemoEkipmanEkleListe.Text,':PEkipmanID',Sonuclar[0],[rfReplaceAll]));
    //?stid ye g?re s?radan insert ederken locate olup ?stteki item?n ne oldu?unu bulmak gerekiyor..
    Tablo.TablodanSorguAc(6,StringReplace(MemoEkipmanEkleListe.Text,':PEkipmanID',Sonuclar[0],[rfReplaceAll]));
    while not Tablo.Query1.Eof do begin
      if Tablo.Query6.Locate('ALTID',Tablo.Query1.FieldByName('USTID').AsString,[]) then
        UstIDID := Tablo.Query6.FieldByName('ID').AsInteger
      else
        UstIDID := 0;//burada ekipman tablo idsini bulduk.. bize gereken az ?nce insert etti?imizdi..
      Tablo.TablodanSorguAc(5,'select '+DbUst(1)+'ID from EKIPMANREHBER where EKIPMANID='+IntToStr(UstIDID)+' and EKLEYEN='+Kullanan+' order by ID desc '+DbSinir(1));
      Tablo.Query5.FetchAll;
      if Tablo.Query5.RecordCount=1 then//de?ilse zaten ilk item ?n ?st idsi 0 gelmeli.
        UstIDID := Tablo.Query5.FieldByName('ID').AsInteger;

      if Sonuclar[6]='True' then
         s1:='1'
      else
         s1:='0';
      if Sonuclar[7]='' then
         s2:='null'
      else
         s2:=Sonuclar[7];
      if Sonuclar[8]='' then
         s3:='null'
      else
         s3:=Sonuclar[8];

      Tablo.TablodanSorguAc(4,'insert into EKIPMANREHBER(EKIPMANID,REHBERID,USTID,SAHIP,MARKA,MODEL,EKLEYEN,SUBEID) values('+
            Tablo.Query1.FieldByName('ID').AsString+','+REHBER.FieldByName('ID').AsString+','+IntToStr(UstIDID)+','+S1+','+S2+','+S3+','+Kullanan+','+IntToStr(SubeId)+') select scope_identity()');
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,SUBEID) select :PYeri,:PYerID,SIRA,ETIKET,BILGI,SUBEID from REHBERBILGI where YERI=&PYeri and YER_ID=&PYerID',
        [':PYeri',':PYerID','&PYeri','&PYerID'],
      [TabNo_EKIPMANREHBER,Tablo.Query4.Fields[0].AsInteger,TabNo_EKIPMAN,Tablo.Query1.FieldByName('ID').AsInteger]);
      Tablo.Query1.Next;
    end;
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
    // TabEkipmanlar.Locate('ID', Tablo.Query1.FieldByName('ID').AsInteger, []);
    TreeListEkipman.DataController.DataSet.First;
    TreeListEkipman.DataController.DataSet.Locate('ID', Tablo.Query1.FieldByName('ID').AsInteger, []);
  finally
    FreeAndNil(Sonuclar);
  end;
end;

procedure TRehberAraDlg.BtnEkipmanDuzenleClick(Sender: TObject);
begin
   Tablo.EkipmanDuzenle(TabEkipmanlar.FieldByName('ID').AsInteger, TabEkipmanlar.FieldByName('DETAYBOLUMU').AsString);
   TabloYenile(TabEkipmanEkBilgi, [TabNo_EKIPMANREHBER, TabEkipmanlar.Fieldbyname('ID').AsInteger]);
end;

procedure TRehberAraDlg.BtnIptalBHClick(Sender: TObject);
begin
  TabBankaHesaplar.Cancel;
end;

procedure TRehberAraDlg.BtnKaydetBHClick(Sender: TObject);
begin
  TabBankaHesaplar.Post;
end;

procedure TRehberAraDlg.BtnKotaClick(Sender: TObject);
//var str:TStringList;
var Sonuc:variant;
begin
  Sonuc := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select isnull((select '+DbUst(1)+'TUTAR from REHBER_KOTA Where REHBERID=&RehID '+DbSinir(1)+'),0.0) ',['&RehID'],[REHBER.FieldByName('ID').AsInteger],True);
  if TGirisKutusuEx.BilgiAlEx('Risk Limiti Bilgisi Giriniz.',TGirdiDenetimleri.Create.CurrencyEdit(CariDoviz+' : ',@Sonuc,2)) = mrOk then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBER_KOTA Where REHBERID=&RehID ',['&RehID'],[REHBER.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBER_KOTA(REHBERID,TUTAR,KUR) values (&RehID,&Tutar,&Kur) ',
                                  ['&RehID','&Tutar','&Kur'],[REHBER.FieldByName('ID').AsInteger,Sonuc,CariDoviz]);
  end;

  //Tablo.TabMusteri.Tag := REHBER.FieldByName('ID').AsInteger;
  //Tablo.ListedenDuzenle(Tablo.FDCnn,'Kota D?zenleme Ekran?','Select * from REHBER_KOTA where REHBERID='+REHBER.FieldByName('ID').AsString,'REHBER_KOTA',True,False,False);
  //Tablo.ListedenBilgiGetir('Kota D?zenleme Ekran?','Select * from REHBER_KOTA where REHBERID='+REHBER.FieldByName('ID').AsString,str)
end;

procedure TRehberAraDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,TabloNo , REHBER.FieldByName('ID').AsInteger,REHBER.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TRehberAraDlg.btnRakipEkipmanIptalClick(Sender: TObject);
begin
  TabEkipmanRakip.Cancel;
end;

procedure TRehberAraDlg.btnRakipEkipmanKaydetClick(Sender: TObject);
begin
  TabEkipmanRakip.Post;
end;

procedure TRehberAraDlg.btnRakipEkipmanSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    TabEkipmanRakip.Delete;
  end;
end;

procedure TRehberAraDlg.btnRakipEkipmanYeniClick(Sender: TObject);
begin
  TabEkipmanRakip.Append;
end;

procedure TRehberAraDlg.ComboBox1DropDown(Sender :TObject);
begin
  GenotipIni.ReadSection('TABLEADLARI', TComboBox(Sender).Items)
end;

constructor TRehberAraDlg.Create(AOwner: TComponent);
begin
  inherited;
  FArama := nil;
  // Alias sekmesi baÄŸlantÄ±larÄ± runtime'da kurulur
  // (DFM'de yapÄ±lan deÄŸiÅŸiklikler "invalid property value" hatasÄ±na yol aÃ§tÄ±ÄŸÄ±ndan programatik baÄŸlanÄ±yor)
  TabAlias.OnNewRecord     := TabAliasNewRecord;
  ToolButton17.OnClick     := AliasYeniTusClick;       // Yeni
  ToolButton19.OnClick     := AliasSilTusClick;        // Sil
  ToolButton21.OnClick     := AliasDuzenleTusClick;    // DÃ¼zenle
  ToolButton22.OnClick     := AliasKaydetTusClick;     // Kaydet
  ToolButton23.OnClick     := AliasIptalTusClick;      // Ä°ptal
  GridAliasView.OnDblClick := AliasDuzenleTusClick;
  GridAliasView.OnCanFocusRecord := nil;               // Banka handler'Ä± dezaktif et
  // ALIAS kolonu yazÄ±labilir olsun
  if GridAliasViewALIAS.Properties is TcxTextEditProperties then
    TcxTextEditProperties(GridAliasViewALIAS.Properties).ReadOnly := False;
  // SAYFALI cari listesi: merkezi yardimciya baglan. Sayfa boyu GENEL OPSIYON
  // (Liste sayfa uzunlugu, vars.100) -> closure nil. FArama spin'i pasiflenir
  // (arama frame'i sonradan atanir -> Baslatildi/GorunurOlacak aninda degil,
  // Liste_SP_Cagir icinde ilk kullanildiginda kapatilir).
  FSayfali := TSayfaliListe.Baglan(Self, REHBER, CariGridView, nil,
    procedure
    begin
      Liste_SP_Cagir(FCariSonMod);
    end);
end;

procedure TRehberAraDlg.cxDBTreeList1cxDBTreeListColumn2PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  st:Tstringlist;
begin
  try//rehberpersonelden aranacak
    st := Tstringlist.create;
    //IlgiliEkleClick
    if Tablo.ListedenBilgiGetir(MusteriilgiliSec,'select ID,  FIRMA from REHBER where GRUP=334 AND BAGID='+REHBER.FieldByName('ID').AsString+' and FIRMA like''%<ara>%''  order by 2 ',st,[],'RehAraDlgMilgiliSec',TNotifyEvent(nil),Tablo.FDCnn,IlgiliEkleClick) then begin
      TabEkipmanlar.Edit;
      TabEkipmanlar.FieldByName('MUS_ILGILI').AsInteger := StrToIntDef(st.Strings[0],-1);
      TabEkipmanlar.Post;
    end;
  finally
    st.free;
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
    TabloYenile(TabEkipmanRakip,[REHBER.Fields[0].AsInteger]);
  end;
end;

procedure TRehberAraDlg.IlgiliEkleClick(Sender: TObject);
var ID : Integer;
begin
  ID := Tablo.RehberSihirbazBaslat(4,REHBER.FieldByName('ID').AsInteger,-1,-1,AktifSekme='TAksiyonlarGorevFrame');
  if ID>0 then begin
    TabEkipmanlar.Edit;
    TabEkipmanlar.FieldByName('MUS_ILGILI').AsInteger := ID;
    TabEkipmanlar.Post;
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TRehberAraDlg.cxDBTreeList1cxDBTreeListColumn6PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  KodAgaciLokasyonDlg:TKodAgaciDlg;
  slist : TStringList;
begin
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,REHBERID,ID from LOKASYON where DURUM=1 and TUR='+IntToStr(Lokasyon_Genel)+'  and REHBERID='+REHBER.FieldByName('ID').AsString;
  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,False,True,LokID,LokKod,LokAciklama,slist,[nil,nil,nil],['REHBERID','TUR'],[REHBER.FieldByName('ID').AsString,IntToStr(Lokasyon_Genel)]
          ,['Kod','A��klama','',''],[True,True,False,False],True) then try
    TabEkipmanlar.Edit;
    TabEkipmanlar.FieldByName('LOKASYONID').Value:=LokID;
    TabEkipmanlar.Post;
  finally
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
    FreeAndNil(KodAgaciLokasyonDlg);
  end;
end;

procedure TRehberAraDlg.TreeListEkipmancxDBTreeListMARKAPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var
  Marka:Variant;
  MarkaId:String[7];
begin
   if TabEkipmanlar.FieldByName('SAHIP').AsBoolean  then
      MarkaId:='-2701'
   else
      MarkaId:='-2727';

   if TGirisKutusuEx.BilgiAlEx(BGTeklif_bilgi,TGirdiDenetimleri.Create
       .ImageComboBox('Marka',@Marka,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL=-1 and BOLUM='+
       MarkaId+' order by ANAHTAR ',False,nil))= mrOk then begin

       TabEkipmanlar.Edit;
       TabEkipmanlar.FieldByName('MARKA').AsInteger := StrToIntDef(VarToStr(Marka),0);
       TabEkipmanlar.Post;
       TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
   end;
end;

procedure TRehberAraDlg.TreeListEkipmancxDBTreeListMODELPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  Model:Variant;
  MarkaId:String[7];
begin
   if TabEkipmanlar.FieldByName('SAHIP').AsBoolean  then
      MarkaId:='-2701'
   else
      MarkaId:='-2727';
//  if TabEkipmanlar.FieldByName('MARKA').AsString <>'' then begin
//     Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_StokKart_Marka)+ TabEkipmanlar.FieldByName('MARKA').AsString), TcxImageComboBoxProperties(TreeListEkipmancxDBTreeListMODEL.Properties).Items,True);
//   end;

    if TGirisKutusuEx.BilgiAlEx(BGTeklif_bilgi,TGirdiDenetimleri.Create
       .ImageComboBox('Model',@Model,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL=-1 and BOLUM='+
       MarkaId+ TabEkipmanlar.FieldByName('MARKA').AsString+' order by ANAHTAR ',False,nil))= mrOk then begin

       TabEkipmanlar.Edit;
       TabEkipmanlar.FieldByName('MODEL').AsInteger := StrToIntDef(VarToStr(Model),0);
       TabEkipmanlar.Post;
       TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
    end;
end;

procedure TRehberAraDlg.TreeListEkipmanDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var   TreeHitTest: TcxTreeListHitTest;
      ANode: TcxTreeListNode;
begin
  if State = dsDragLeave then begin //
     TreeHitTest := (Sender as TcxDBTreeList).HitTest;
     if not TreeHitTest.HitAtNode then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update EKIPMANREHBER set USTID = 0 where ID='+TabEkipmanlar.Fields[0].AsString,[],[]);
        TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
     end;
  end
  else begin
      Anode := TcxTreeList(Sender).GetNodeAt(X,Y);
      if ANode <> nil then begin
         Caption := ANode.Values[0];
         Accept := True;
      end;
  end;

end;

procedure TRehberAraDlg.TreeListEkipmanMoveTo(Sender: TcxCustomTreeList;
  AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode;
  Nodes: TList; var IsCopy, Done: Boolean);
var
  dropId, dragId: Integer;
begin
  Sender.BeginUpdate;
  try
   if Nodes.Count = 1 then begin  //Projeler kapal? ve liste di?er listenin alt?na gelecekse
      dropId := TcxDBTreeListNode( AttachNode ).KeyValue;
      dragId := TcxDBTreeListNode( Nodes[0] ).Values[0];
      if (DragId>0)and(dropId>0) then begin
         //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PROJELER set ASAMA='+IntToStr(abs(dropId))+' where ID='+IntToStr(dragId),[],[]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update EKIPMANREHBER set USTID = '+IntToStr(abs(dropId))+' where ID='+IntToStr(abs(dragId)),[],[]);
         TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
      end;
    end;
  finally
    Sender.EndUpdate;
  end;
  Done := True;
end;

procedure TRehberAraDlg.TreeListEkipmanSelectionChanged(Sender: TObject);
begin
  TabloYenile(TabEkipmanEkBilgi, [TabNo_EKIPMANREHBER, TabEkipmanlar.Fieldbyname('ID').AsInteger]);
end;

procedure TRehberAraDlg.TreeListEkipmanStylesGetNodeIndentStyle(
  Sender: TcxCustomTreeList; ANode: TcxTreeListNode; ALevel: Integer;
  var AStyle: TcxStyle);
begin
  if ( ANode.Values[TreeListEkipmancxDBTreeListGARANTIBITTAR.ItemIndex] <> 0 ) then begin
     if ANode.Values[TreeListEkipmancxDBTreeListGARANTIBITTAR.ItemIndex]<Tablo.GENINI.BugunTrh then
       AStyle := Tablo.cxStyle27
     else
       AStyle := Tablo.cxStyle26
  end;
end;

procedure TRehberAraDlg.TreeListGorevClick(Sender: TObject);
var   TreeHitTest: TcxTreeListHitTest;
begin
   TreeHitTest := (Sender as TcxDBTreeList).HitTest;
   if not TreeHitTest.HitAtColumn  then // soldaki + alt seviye a?ma tu?una bast???nda a?ma/kapatma yapmas?n diye
      exit;

   if TcxDBTreeList(Sender).FocusedColumn.tag=1 then begin
      UpdateveMail(Masaustu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, TcxDBTreeList(Sender).FocusedNode.HasChildren);
      PlayWavFromResource('Blink');
      PageControlSekmeChange(Self);
   end;
   Abort;//Bunu kesinlikle silme (listede tek sat?r kal?nca hata verdi?i i?in eklendi)
end;

procedure TRehberAraDlg.TreeListGorevDblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TRehberAraDlg.cxGridAktivitelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridCariEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridCariEkstre;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridCariEkstreView;
  AnaForm.pmGridStil.Tags.Values[GridCariEkstre.Name] := 'RehberEkstreHareket';
end;

procedure TRehberAraDlg.GridCariEkstreViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.cxGridPersonellerSelectionChanged(Sender: TcxCustomGridTableView);
begin
   if TabRehberIlgili.Active then begin
      ResimGetir(REHBER.Fields[0].AsInteger,12, TabRehberIlgili.FieldByName('ID').AsInteger, Resim);
      TabloYenile( TabPerIletisim, [TabRehberIlgili.Fields[0].AsInteger]);
   end;
end;

destructor TRehberAraDlg.Destroy;
begin
   inherited;
end;

procedure TRehberAraDlg.DkmanGster1Click(Sender: TObject);
begin
//  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
   if GridYorum.ActiveView = GridYorumDBCardView1 then
      Tablo.GridYorumDokumaniGor2(TabYorum)
   else
      Tablo.GridYorumDokumaniGor2(TabYorum2)
end;

procedure TRehberAraDlg.DkmanSil1Click(Sender: TObject);
begin
   if GridYorum.ActiveView = GridYorumDBCardView1 then begin
      if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
          Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
          Tabloyenile(TabYorum,[TabloNo, Rehber.FieldByName('ID').AsInteger]);
      end
   end else begin
      if (not TabYorum2.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum2.FieldByName('EKLEYEN').AsString)) then begin
          Tablo.DokumanSil(True,TabYorum2.FieldByName('DOKUMANID').AsInteger,1,-1);
          Tabloyenile(TabYorum2,[TabloNo, Rehber.FieldByName('ID').AsInteger]);
      end
   end
end;

procedure TRehberAraDlg.DokumanFormunuA1Click(Sender: TObject);
begin
   if GridYorum.ActiveView = GridYorumDBCardView1 then
      Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger, Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
         TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, Rehber.FieldByName('ID').AsInteger)
   else
      Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum2.FieldByName('DOKUMANID').AsInteger, Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
         TabNo_GOREVYORUM,TabYorum2.FieldByName('ID').AsInteger, Rehber.FieldByName('ID').AsInteger)
end;

procedure TRehberAraDlg.DtsBankaHesaplarStateChange(Sender: TObject);
begin
  BtnKaydetBH.Visible := DtsBankaHesaplar.State=dsEdit;
  BtnIptalBH.Visible := DtsBankaHesaplar.State=dsEdit;
  BankaEkleTus.Visible := DtsBankaHesaplar.State<>dsEdit;
  BankaSilTus.Visible := DtsBankaHesaplar.State<>dsEdit;
  BankaDuzenleTus.Visible := DtsBankaHesaplar.State<>dsEdit;
end;

procedure TRehberAraDlg.DtsEkipmanlarStateChange(Sender: TObject);
begin
  BtnEkipmanDetayYeni.Visible := not (DtsEkipmanlar.State in [dsEdit,dsInsert]);
  btnEkipmanDetaySil.Visible := not (DtsEkipmanlar.State in [dsEdit,dsInsert]);
  BtnEkipmanDetayKaydet.Visible := (DtsEkipmanlar.State in [dsEdit,dsInsert]);
  BtnEkipmanDetayIptal.Visible := (DtsEkipmanlar.State in [dsEdit,dsInsert]);
end;



procedure TRehberAraDlg.DtsEkipmanRakipStateChange(Sender: TObject);
begin
  btnRakipEkipmanYeni.Visible := not (DtsEkipmanRakip.State in [dsEdit,dsInsert]);
  btnRakipEkipmanSil.Visible := not (DtsEkipmanRakip.State in [dsEdit,dsInsert]);
  btnRakipEkipmanKaydet.Visible := (DtsEkipmanRakip.State in [dsEdit,dsInsert]);
  btnRakipEkipmanIptal.Visible := (DtsEkipmanRakip.State in [dsEdit,dsInsert]);
end;

procedure TRehberAraDlg.DuzenleMenuClick(Sender: TObject);
begin
   Menu_Duzenle(Sender, TabGorevler);
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TRehberAraDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TRehberAraDlg.Fatura1Click(Sender: TObject);
var Tur, Tipi, ID : Integer;
    HesapTuru : Char;
    DateSaat:TDateTime;
begin

  Tur := TMenuItem(Sender).Tag;
  //Uyar? kontrol?
  if (REHBER.FieldByName('DURUM').AsInteger = 2)and(Tablo.Uyari_Yasak_Ekrani(Rehber.FieldS[0].AsInteger)= 13) then  //yasak varsa i?lem yap?lamaz
    exit;

  if Tur in [4,7,8] then begin //stopaj olursa serbest mes.mak
     Tipi:=Tur; Tur:=11;
  end;
  if (Tur in [111,112,113,114,115])or(Tur=-111) then begin
     if Tur<0 then Tipi:=-1
     else Tipi:=Tur-110;
     Tur := 11;
  end else
  if (Tur in [151,152,153,155])or(Tur=-115) then begin
     if Tur<0 then Tipi:=-1
     else Tipi:=Tur-150;
     Tur := 15;
  end;

  case Tur of
    21,26,31,36 : HesapTuru := 'K';
    22,32 : HesapTuru := 'B';
    23,33,35,350 : HesapTuru := 'V';
    25,125 : HesapTuru := 'P';
    28,29,38,39: HesapTuru := 'H';
    49: HesapTuru := 'C';
  else
    HesapTuru := '-';
  end;
  case Tur of
     9,19: ID := Tablo.SiparisSihirbazBaslat('E', Tur,0, -1, REHBER.Fields[0].AsInteger);
     10,11,12,14,15,16 : begin
                           if Tipi<1 then Tipi:=1;
                           ID := Tablo.FaturaSihirbazBaslat('E', Tur,-1, -1, REHBER.Fields[0].AsInteger, Tipi);
                         end;
     13,17 : ID := Tablo.TahakkukSihirbaziBaslat('E', Tur,1, -1, REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrhSaat);
     //23:ID := Tablo.CekSihirbazBaslat('E', Tur,1, 0, -99, REHBER.Fields[0].AsInteger,-1, Tablo.GENINI.BugunTrhSaat, '');
     //24:ID := Tablo.CekSihirbazBaslat('E', Tur,2, 0, -99, REHBER.Fields[0].AsInteger,-1, Tablo.GENINI.BugunTrhSaat, '');
     Sbt_Cek_Gelen,Sbt_Cek_Giden,Sbt_Senet_Gelen,Sbt_Senet_Giden:begin
               if Tur in [Sbt_Cek_Gelen, Sbt_Senet_Gelen]  then Tipi:=130
                  else Tipi:=140;
             ID := Tablo.CekSihirbazBaslat('E', Tipi,Tur, 0, -99, REHBER.Fields[0].AsInteger,-1, Tablo.GENINI.BugunTrhSaat, '');
     end;
     21,22,25,26,28,29,31,32,35,36,38,39,125,350 : ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,2, -1, REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrhSaat, '-1');
     49,52,61,71,161  : begin  DateSaat:=Tablo.GENINI.BugunTrhSaat;
                     ID := Tablo.KasaSihirbazBaslat('E', -1, Tur, 0, REHBER.Fields[0].AsInteger,DateSaat ,DateSaat,0,0,'','',-1,-1,1);
              end;
  end;
  if ID > 0 then
    PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.Faturaile1Click(Sender: TObject);
begin
  case TabCariListe.FieldByName('TUR').AsInteger of
      8,15 :begin
        Tablo.Query9.Close;
        Tablo.Query9.SQL.Text := 'Select * from FATBASLIK Where ID='+TabCariListe.FieldByName('CEKID').AsString+' ';
        if AktifVeriMotor = vmPG then Tablo.Query9.SQL.Text := PgSqlCevir(Tablo.Query9.SQL.Text);
        Tablo.Query9.Open;

        Tablo.FaturaIadeAl(Tablo.Query9,TMenuItem(Sender).Tag );
      end;
  end;
end;

procedure TRehberAraDlg.FaturaKapatma1Click(Sender: TObject);
begin
  if FaturaKapamaDlg <> nil then
    FreeAndNil(FaturaKapamaDlg);
  Application.CreateForm(TFaturaKapamaDlg,FaturaKapamaDlg);
  FaturaKapamaDlg.RehberID := REHBER.Fields[0].AsInteger;
  FaturaKapamaDlg.Caption := REHBER.FieldByName('FIRMA').Asstring + ' Bor�/Alacak Kapama';
  FaturaKapamaDlg.ShowModal;
  FreeAndNil(FaturaKapamaDlg);
end;

procedure TRehberAraDlg.FirsatDuzenleTusClick(Sender: TObject);
begin
   if Tablo.FirsatSihirbazBaslat('D', TabFirsat.Fields[0].AsInteger,REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrh) > 0 then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.FirsatEkleTusClick(Sender: TObject);
begin
   if Tablo.FirsatSihirbazBaslat('E',-1,REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrh) > 0 then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.FirsatSilTusClick(Sender: TObject);
begin
   if Tablo.ProjeSilmeIslemleri(TabFirsat, TabFirsat.Fields[0].AsInteger) then begin
      PageControlSekmeChange(Self);
      Abort;
   end;
end;

procedure TRehberAraDlg.AcilisiFisiMenuClick(Sender: TObject);
begin
   if Tablo.AcilisiFisiEkraniBaslat(1,TMenuItem(Sender).Tag, REHBER.FieldByname('ID').AsString,REHBER.FieldByname('KOD').AsString,REHBER.FieldByname('FIRMA').AsString,'', 0,Tablo.GENINI.BugunTrhSaat) then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.AksiyonBilgisiniGorMenuClick(Sender: TObject);
begin
   if TabCariListe.FieldByName('TUR').AsInteger in [0,1,2] then
      Tablo.AcilisiFisiEkraniBaslat(1,TabCariListe.FieldByName('TUR').AsInteger, REHBER.FieldByname('ID').AsString,REHBER.FieldByname('KOD').AsString,REHBER.FieldByname('FIRMA').AsString,'',TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TARIH').AsDateTime)
   else
      AnaForm.GormeDialogCagir(TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TUR').AsInteger,
           TabCariListe.FieldByName('REHBERID').AsInteger, 2,TabCariListe.FieldByName('TARIH').AsDateTime, TabCariListe.FieldByName('NO').AsString);
   TabloYenile(TabCariListe,[],0,'CEKID');
   //PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.PMAksiyonlarMenuPopup(Sender: TObject);
begin
   if REHBER.FieldByName('DURUM').AsInteger < 1 then
      raise Exception.Create(CRPasif_kayda_islem_olmaz);

   Sil1.Visible := not TabCariListe.IsEmpty;
   AksiyonBilgisiniGorMenu.Visible := SilMenu.Visible;
   OdemeTahsilatYapMenu.Visible := (SilMenu.Visible) and (TabCariListe.FieldByName('TUR').AsInteger in [11..19]);
//   TahsilMenu2.Visible := (Sil1.Visible)and((TabCariListe.FieldByName('TUR').AsInteger in [15..19])or(TabCariListe.FieldByName('TUR').AsInteger = 61));
//   OdemeMenu2.Visible := (Sil1.Visible)and((TabCariListe.FieldByName('TUR').AsInteger in [8,10..14])or(TabCariListe.FieldByName('TUR').AsInteger = 11));
   iadeAl.Visible := TabCariListe.FieldByName('TUR').AsInteger in [15,16];

end;

procedure TRehberAraDlg.AraFirmaKeyUp(Sender :TObject; var Key :Word; Shift :TShiftState);
begin
  if Key = 13 then
      DegisTusClick(Self)
  else if Key = 38 then
    REHBER.Prior
  else if Key = 40 then
    REHBER.next
  else if TEdit(Sender).Text <> '' then
    AraTusClick(Self);
end;

procedure TRehberAraDlg.EkranYazdir(Sender: TObject);
begin

end;



procedure TRehberAraDlg.EPostaKontrol1Click(Sender: TObject);
begin
   Tablo.TablodanSorguAc(5, ' select BILGI from REHBERBILGI B inner join REHBERILETISIM I on B.YER_ID=I.ID '+
                            ' where I.REHBERID='+REHBER.Fields[0].AsString+' and BILGI like ''%@%'' ');
   while not Tablo.Query5.eof do begin
      Tablo.EPostaAlimIslemleri(Tablo.Query5.fields[0].AsString, StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
      Tablo.Query5.Next;
   end;
end;

procedure TRehberAraDlg.ExceldenAksiyonAktar1Click(Sender: TObject);
var
  ExcellBelge,kitap,sayfa:Variant;
  i,j,TahTur:Integer;
  TahTutar:Currency;
  TahTutarSt, Kur, Karsilik: String[25];
  Tarih : TDateTime;
begin
  ShowMessage(CRAktarim_Kosullari);
  if OpenDialog1.Execute then begin
    ExcellBelge := CreateOleObject('Excel.Application');
    try
      kitap := ExcellBelge.Workbooks.Open(OpenDialog1.FileName);
      for I := 1 to Kitap.WorkSheets.Count do begin
        sayfa := kitap.worksheets[i];
        j:=2;
        //s?tun1(A):kod,s?tun2(B):Ad,s?tun3(C):Birim,s?tun4(D):Adet,s?tun5(E):BirimFiyat,
        // 6.s?tun:kur(DOVIZKUR) 7.s?tun:Kar??l???(DOVIZ_TUTARI)  8.s?tun:Kar??l??? Para Birimi(DOVIZ_CINSI)

        while (VarToStrDef(sayfa.Cells[j,1].Value,'')<>'')and
              (VarToStr(sayfa.Cells[j,4].Value)<>'')
        do begin //sayfa.Cells[sat?r,s?tun].Value
          if StrTocurrDef(VarToStr(sayfa.Cells[j,2].Value),0)>StrTocurrDef(VarToStr(sayfa.Cells[j,3].Value),0) then begin
            TahTur := 17;
            TahTutar := StrTocurrDef(VarToStr(sayfa.Cells[j,2].Value),0);
          end else begin
            TahTur := 13;
            TahTutar := StrTocurrDef(VarToStr(sayfa.Cells[j,3].Value),0);
          end;

          Tarih :=StrToDateTime(StringReplace( VarToStrDef(sayfa.Cells[j,1].Value, '01/01/2020'), '/', FormatSettings.DateSeparator, [rfReplaceAll]));

          TahTutarSt := StringReplace(CurrToStr(TahTutar), ',', '.', [rfReplaceAll]);
          Kur :=  VarToStrDef(sayfa.Cells[j,6].Value, '1');
          Kur :=StringReplace(Kur, ',', '.', [rfReplaceAll]);
          Karsilik :=  VarToStrDef(sayfa.Cells[j,7].Value, '1');
          Karsilik :=StringReplace(Karsilik, ',', '.', [rfReplaceAll]);
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'insert into FATBASLIK(TARIH,TUR,REHBERID,FATURATARIH,FATURANO,FATURA_TUTARI,KUR,DOVIZ_TUTARI,DOVIZ_CINSI,DOVIZKUR,'+
            'RAPORDOVIZ,TIPI,EKSTREDEKULLAN, MASRAFID,YERI, ACIKLAMA,DIL,SUBEID) '+
            'values(&TARIH,&TUR,&REHBERID,&FATURATARIH,&FATURANO,&FATURA_TUTARI,&KUR,&DOVIZ_TUTARI,&DOVIZ_CINSI,&DOVIZKUR,'+
            '&RAPORDOVIZ, &TIPI, &EKSTREDEKULLAN, &MASRAFID, &YERI, &ACIKLAMA,&DIL,&SUBEID) '
          ,['&TARIH','&TUR','&REHBERID','&FATURATARIH','&FATURANO','&FATURA_TUTARI','&KUR','&DOVIZ_TUTARI','&DOVIZ_CINSI','&DOVIZKUR',
             '&RAPORDOVIZ', '&TIPI', '&EKSTREDEKULLAN', '&MASRAFID', '&YERI','&ACIKLAMA','&DIL','&SUBEID']
          ,[  FormatDateTime('YYYY-mm-DD HH:NN', Tarih),
              TahTur,
              REHBER.FieldByName('ID').AsInteger,
              FormatDateTime('YYYY-mm-DD HH:NN',Tarih),
              '',
              TahTutarSt,
              VarToStrDef(sayfa.Cells[j,4].Value,CariDoviz),
              Karsilik,
              VarToStrDef(sayfa.Cells[j,8].Value,CariDoviz),
              Kur,
              VarToStrDef(sayfa.Cells[j,8].Value,CariDoviz),
              1,0,0,1,
              StringReplace(sayfa.Cells[j,5].Value,'''','',[rfReplaceAll]),
              -1,SubeId ]);
          inc(j);
        end;
        //sayfa.Cells[j,6].Value := 'Eksik Bilgi';
      end;
    finally
      if not VarIsEmpty(ExcellBelge) then begin
        ExcellBelge.DisplayAlerts:= False;
        //Excel mesajlar?n? g?r?nteleme
        //ExcellBelge.Save;
        ExcellBelge.Quit;
        ExcellBelge := Unassigned;
        //FreeAndNil(ExcellBelge);
        ExcellBelge:=Unassigned;
        showmessage(BAktarim_tamam);
      end;
    end;
  end;
end;

procedure TRehberAraDlg.ExceldenVeriAlMenuClick(Sender: TObject);
begin
   Excel2Cari(AktifSekme='TAksiyonlarGorevFrame');
end;

procedure TRehberAraDlg.ExcelKolonAyarlar1Click(Sender: TObject);
begin
  Application.CreateForm(TExcelKolonAyarDlg,ExcelKolonAyarDlg);
  ExcelKolonAyarDlg.RehberID := REHBER.FieldByName('ID').AsInteger;
  ExcelKolonAyarDlg.BEditFirma.Text := REHBER.FieldByName('FIRMA').AsString;
  ExcelKolonAyarDlg.Show;
end;

function TRehberAraDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

procedure TRehberAraDlg.DegisTusClick(Sender: TObject);
var ID : Integer;
begin
   ID := REHBER.Fields[0].AsInteger;
  // ID := CariGridView.Controller.SelectedRecords[i].Values[CariGridViewID.Index];
   if (not REHBER.Active)or(REHBER.Active and REHBER.IsEmpty) then
      raise Exception.Create(RDOnceAramaYapin);
//   RehberEkranAc(Self.REHBER.AsInteger['ID']);
  if Tablo.RehberSihirbazBaslat(0,REHBER.Fields[0].AsInteger,-100,-100,AktifSekme='TAksiyonlarGorevFrame') > 0 then begin
     //REHBER.Close;
     //REHBER.open;
     TabloYenile(REHBER,[],ID);
  end;
  //CariGridView.Controller.FocusRecord( CariGridView.DataController.GetRowIndexByRecordIndex(<DataSet>.RecNo, false), true);
  //REHBER.Locate('ID', ID, []);
//  CariGridView.Controller.FocusRecord( ID, true);
{GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewID.Index];
  if Assigned(KayitErisimTamamlandi) then
    KayitErisimTamamlandi(Self);
  KayitErisimTamamlandi := nil; }
end;

procedure TRehberAraDlg.RBDevirliClick(Sender: TObject);
begin
  PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.cbPerExtreTuruPropertiesEditValueChanged(Sender: TObject);
begin
  CalendarEkstreBasPropertiesEditValueChanged(Self);
end;

procedure TRehberAraDlg.CheckDetayliPropertiesEditValueChanged(Sender: TObject);
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
  CalendarEkstreBasPropertiesEditValueChanged(self);
end;

procedure TRehberAraDlg.checkKapaliGosterPropertiesEditValueChanged(
  Sender: TObject);
begin
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.CheckPasiflerClick(Sender: TObject);
begin
   AraTusClick(Self);
end;

procedure TRehberAraDlg.CheckPotansiyelClick(Sender: TObject);
begin
   GenRegIni.RegWriteString('CariOpsiyon', 'CariPotansiyelAra', BoolToStr(FArama.CheckPotansiyel.checked), 'C');
   AraTusClick(Self);
end;

procedure TRehberAraDlg.CheckTamamlananClick(Sender: TObject);
begin
   ComboTamamlanan.Visible := CheckTamamlanan.Checked;
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.CheckTamamlanmisAktivitePropertiesEditValueChanged(
  Sender: TObject);
begin
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TRehberAraDlg.YeniletisimEkleMenuClick(Sender: TObject);var ID : Integer;
begin

end;

procedure TRehberAraDlg.YeniTusClick(Sender: TObject);
var
   SQL: String;
   ID : Integer;
begin
   ID := Tablo.RehberSihirbazBaslat(0,-100,-100,-100, AktifSekme='TAksiyonlarGorevFrame');
   if ID > 0 then begin
      Tablo.AramaKaydet(MODUL_Cari, ID);   // yeni cari -> Son Aranan
      Liste_SP_Cagir(5);                    // Son Aranan (en yeni ustte)
      REHBER.Locate('ID', ID, []);
  end;
  CariGridView.DataController.FocusedRecordIndex:=0;
 // CariGridView.ViewData.Records[0].Selected := True;
end;

procedure TRehberAraDlg.YorumDzenle1Click(Sender: TObject);
begin
//  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
   if GridYorum.ActiveView = GridYorumDBCardView1 then
      Tablo.GridYorumYorumuDuzenle2(TabYorum, TabloNo, Rehber.FieldByName('ID').AsInteger)
   else
      Tablo.GridYorumYorumuDuzenle2(TabYorum2, TabloNo, Rehber.FieldByName('ID').AsInteger);
end;

function TRehberAraDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TRehberAraDlg.GorevEkleTusClick(Sender: TObject);
var
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin
     GorevId := Tablo.GorevOlustur('', Masaustu,0, 0, 0, REHBER.Fields[0].AsInteger, 0, 0, 0,
                                   0, 0, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat);

      Tablo.GorevSihirbazBaslat(GorevDlg1, 'E', GorevId, AtamaYapildi, YorumYapildi);
      if AtamaYapildi then
         Gorev_EPostaGonder(1, GorevId)
      else if YorumYapildi then
         Gorev_EPostaGonder(3, GorevId);
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.GorevGridDBTableView1ACKAPAPropertiesEditValueChanged(Sender: TObject);
begin
   TamamlandiIsaretleMenuClick(Self);
end;

procedure TRehberAraDlg.GorevGridDBTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if AcellViewinfo.Item.Tag = 1 then begin
//     TamamlandiIsaretleMenuClick(Self);
//     Menu_Tamam(GorevlerMenu, GorevGridDBTableView1, Scheduler, FArama.TabListe.Fields[0].AsInteger);
     UpdateveMail(Masaustu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, False);
     PlayWavFromResource('Blink');
     PageControlSekmeChange(Self);
  end;
  Abort;//Bunu kesinlikle silme (listede tek sat?r kal?nca hata verdi?i i?in eklendi)
end;

procedure TRehberAraDlg.GorevGridDBTableView1DblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TRehberAraDlg.GorevSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) = ID_OK then begin
     Tablo.GorevSil(TabGorevler.Fields[0].AsInteger);
     PageControlSekmeChange(Self);
  end;
end;

procedure TRehberAraDlg.Gorunmez;
begin

end;

procedure TRehberAraDlg.GorunmezOlacak;
begin

end;

procedure TRehberAraDlg.Gorunur;
var
  gf : TCariGorevFrame;
begin
  ProjeImageComboBos := True;
  AktiviteImageComboBos := True;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
  //
//  gf := TCariGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
//  Potansiyel := gf.FPotansiyel;
  if AktifSekme='TAksiyonlarGorevFrame' then begin
     //AksiyonEkleTus.DropdownMenu := PopupMenuPotansiyel;
     //CariGrid.PopupMenu := PopupMenuPotansiyel;
     TabloNo := TabNo_REHBER_POTANSIYEL;
     FArama.CheckPotansiyel.caption := 'Caride de Ara';
  end else begin
     //AksiyonEkleTus.DropdownMenu := PopupMenuYeni;
     //CariGrid.PopupMenu := PopupMenuREHBER;
     TabloNo := TabNo_REHBER;
     FArama.CheckPotansiyel.caption := 'Potansiyelde de Ara';
  end;
//  Rehber.Close;


  FArama.AraFirma.SetFocus;
  if  (FArama.AraFirma.Text <> '') or (FArama.AraYetkili.Text <> '') or (FArama.AraKod.Text <> '') then //10012008HA
      AraTusClick(nil);
end;

procedure TRehberAraDlg.GorunurOlacak;
begin

end;

procedure TRehberAraDlg.GridBankaDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridBanka;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridBankaDBTableView1;
  AnaForm.pmGridStil.Tags.Values[GridBanka.Name] := 'RehberTicariBilGridi';
end;

procedure TRehberAraDlg.GridBankaDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.CariGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
var s:string[3];
begin
  AnaForm.cxGridPopupMenu1.Grid:=CariGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=CariGridView;
  case FArama.ComboCariAnaliz.Itemindex of
    1..5: s:='BA';
  else
    s:='';
  end;
  if FArama.CheckDetay.Checked then
    s:='CRM';
  AnaForm.pmGridStil.Tags.Values[CariGrid.Name] := 'CariListeGridi'+s;
end;

procedure TRehberAraDlg.CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
var
//  fb : TIcerikFrameBilgi;
  select,s2:string;
begin
  if (REHBER.Active)and(not REHBER.IsEmpty)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
      TabCariListe.Close;
      s:='('+REHBER.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+'''';
      s2:=','+IntToStr(Abs(StrToInt(BoolToStr(CheckPlan.Checked))));

      //if SQLVersion2008 then begin
          select := 'select SIRANO,CEKID,TARIH,AKSIYONTARIH,NO,TUR,BASLIK,TURAD,REHBERID,KOD,AD,ACIKLAMA,HESAPID,HESAPKODU,HESAPADI,DURUM,BORC,'+
                    '  ALACAK,KUR,YERELKUR,MASRAFID,MASRAFKOD,MASRAFAD,BORCBAKIYE,ALACAKBAKIYE,ABS(YERELTUTAR) AS YERELTUTAR,YERELBAKIYE,SUBEID,VADETARIHI,ADET,BIRIM,BIRIMFIYAT from ';
          if CheckDetayli.Checked then
               TabCariListe.SQL.Text := select+' dbo.fn_Cari_Detayli_Ekstre '+s
          else
               TabCariListe.SQL.Text := select+' dbo.fn_Cari_Ekstre '+s+s2;

         // TabCariListe.SQL.Add(' ) where    ISNULL(ACIKLAMA,'''') NOT LIKE ''%Y?l? A??l?? Devri%'' AND ISNULL(ACIKLAMA,'''') NOT LIKE ''%Kapan?? Devr%'' ');
          TabCariListe.SQL.Add(') order by KUR,TARIH');
      {end
      else begin
          s:=REHBER.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+'''';
          if CheckDetayli.Checked then
             TabCariListe.SQL.Text := ' EXEC Sp_Prg_CariDetayEkstre2012 '+s+s2
          else
             TabCariListe.SQL.Text := ' EXEC Sp_Prg_CariEkstre2012 '+s+s2;
      end; }
      TabloYenile(TabCariListe,[]);
  end;


  (*
    if (REHBER.Active)and(not REHBER.IsEmpty)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
      TabCariListe.Close;
      s:=REHBER.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''',0';
           TabCariListe.SQL.Text := ' EXEC Sp_Prg_CariEkstre2012 '+s;
      TabloYenile(TabCariListe,[]);
  end;
*)

end;

procedure TRehberAraDlg.CariGridDBTableView1DblClick(Sender: TObject);
//var srid:integer;
begin
{  if CariGridView.Controller.SelectedRecordCount > 0 then begin
      srid:=CariGridView.DataController.FocusedRecordIndex;
      DegisTus.Click;

      CariGridView.DataController.FocusedRecordIndex:=srid;
      CariGridView.ViewData.Records[srid].Selected := false;
  end;  }
end;

procedure TRehberAraDlg.CariGridViewFARKGetDataText(Sender: TcxCustomGridTableItem; ARecordIndex: Integer; var AText: string);
begin
  try
    if (FArama.ComboCariAnaliz.ItemIndex>2)and(ARecordIndex<REHBER.RecordCount) then
      AText := IntToStr(strtointdef(vartostrdef(CariGridView.DataController.GetValue(ARecordIndex,CariGridViewYASLANDIRMA.Index),''),0) //GetDisplayText
                     -strtointdef(vartostrdef(CariGridView.DataController.GetValue(ARecordIndex,CariGridViewVADE.Index),''),0));
  except
    Exit;
  end;
end;

procedure TRehberAraDlg.CariGridViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
  //
//  TabSheetEkstre.TabVisible := Tablo.YetkiVarmi(220150000+REHBER.FieldByName('GRUP').AsInteger,YetkiTur_Gorme,False) ;
//  AksiyonEkleTus.Visible := TabSheetEkstre.TabVisible;
  AksiyonEkleTus.Enabled := REHBER.FieldByName('DURUM').AsInteger>0;
//  if rehberdetayaktif then
  if REHBER.Active then
     PageControlSekmeChange(Self);
  if EkstreGorunsun then begin
     TabSheetEkstre.TabVisible := (REHBER.FieldByName('GRUP').AsInteger<>1)and(Pos('102.',REHBER.Fieldbyname('KOD').AsString)<>1)


     //if AksiyonEkleTus.Tag<>99 then
     //   AksiyonEkleTus.Visible := TabSheetEkstre.Visible;
  end;
  PageControlSekme.Visible := (REHBER.Active)and(not REHBER.IsEmpty);
  //cxSplitter1.OpenSplitter;
//   PageControlSekmeChange(Self);
  if PageControlSekme.ActivePage=nil then
    PageControlSekme.ActivePageIndex := 0;
end;

procedure TRehberAraDlg.CariGridViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridDemirbasViewDblClick(Sender: TObject);
begin
   if Tablo.DemirbasSihirbazBaslat('D',0,TabDemirbasBilgi.FieldByName('ID').AsInteger) > 0 then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.GridDemirbasViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridPerTemelViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridCariProjelerViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridCariProjeler;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridCariProjelerView;
  AnaForm.pmGridStil.Tags.Values[GridCariProjeler.Name] := 'RehberProjelerGridi';
  PmProjeAktKopyala.Tags.Values['Grid']:='GridCariProjeler'
end;


procedure TRehberAraDlg.GridCariProjelerViewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridProjeViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridRehberIletisimViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   TabloYenile(TabFirIletisim, [REHBERILETISIM.Fields[0].AsInteger]);
   TabloYenile(TabResim, [REHBER.FieldByName('ID').AsInteger]);
//   ResimGetir(REHBER.Fields[0].AsInteger, Tabno_Rehber, REHBER.Fields[0].AsInteger, LogoResim);
end;

procedure TRehberAraDlg.GridTeklifViewDblClick(Sender: TObject);
begin
   if Tablo.TeklifSihirbazBaslat('D',80,0,TabTeklifler.Fields[0].AsInteger, REHBER.Fields[0].AsInteger,-1)>0 then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.GridTeklifViewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridUcretViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TRehberAraDlg.GridYaslandirViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridYaslandir;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridYaslandirView;
  AnaForm.pmGridStil.Tags.Values[GridCariEkstre.Name] := 'RehberYaslanHareket';
end;

procedure TRehberAraDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabloNo);
end;

procedure TRehberAraDlg.GridYorumDBTableView1DblClick(Sender: TObject);
//var
//  Ht: TcxCustomGridHitTest;
//  ad: string;  Screen.Cursor = crHandPoint) and
begin
  If GridYorumDBTableView1.Controller.SelectedRecordCount > 0 then
     Tablo.GridYorumDokumaniGor2(TabYorum2)
end;

procedure TRehberAraDlg.ifreOlutur1Click(Sender: TObject);
begin
  Tablo.TablodanSorguAc(1, 'select ID from KULLANICI where REHBERID='+TabRehberIlgili.FieldByName('ID').AsString+' ');
  if Tablo.Query1.IsEmpty then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into KULLANICI (REHBERID,SIFRE,KOD,ROLID,DURUM,EKLEYEN,EKLEMETARIHI,SUBEID,DIL) values '+
           '(&Rehber_Id,'''+UGenSifre.sifre(TabRehberIlgili.FieldByName('ID').AsString)+''',&Kod, &Rol_Id,1,&Ekleyen, getdate(),'+inttostr(SubeID)+',-1) ',
           ['&Rehber_Id','&Kod', '&Rol_Id','&Ekleyen'],
           [TabRehberIlgili.FieldByName('ID').AsInteger,TabRehberIlgili.FieldByName('ID').AsString, 0, StrToInt(Kullanan)]);
    PageControlSekmeChange(Self);
  end;
end;

procedure TRehberAraDlg.iletisimDuzenleClick(Sender: TObject);
var
     srid,ID:integer;
begin
     srid:=GridRehberIletisimView.DataController.FocusedRecordIndex;
     ID := Tablo.RehberSihirbazBaslat(1, REHBER.Fields[0].AsInteger, REHBERILETISIM.Fields[0].AsInteger,-1, AktifSekme='TAksiyonlarGorevFrame');
     if ID > 0 then begin
       REHBERILETISIM.Locate('ID', REHBERILETISIM.Fields[0].AsInteger, []);
       PageControlSekmeChange(Self);
     end;
     GridRehberIletisimView.DataController.FocusedRecordIndex:=srid;
     GridRehberIletisimView.ViewData.Records[srid].Selected:=True;
end;

procedure TRehberAraDlg.iletisimEkleClick(Sender: TObject);
var RehIletID : Integer;
begin
  RehIletID:=Tablo.RehberSihirbazBaslat(1, REHBER.Fields[0].AsInteger,-1, -1, AktifSekme='TAksiyonlarGorevFrame');
  if RehIletID > 0 then begin
     PageControlSekmeChange(Self) ;
     REHBERILETISIM.Locate('ID', RehIletID, []);
     GridRehberIletisimViewSelectionChanged(nil);
  end;
end;
procedure TRehberAraDlg.iletisimSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     CariIletisimSil(REHBER.Fields[0].AsInteger,REHBERILETISIM.Fields[0].AsInteger, REHBERILETISIM.FieldByName('VARSAYILAN').AsBoolean);
     PageControlSekmeChange(Self);
  end;
end;

procedure TRehberAraDlg.IlgiliAraEditPropertiesChange(Sender: TObject);
begin
  {TabRehberIlgili.Close;
  TabRehberIlgili.Params[0].Value := REHBER.Fields[0].AsInteger;
  TabRehberIlgili.Params[1].Value := '%'+Trim(IlgiliAraEdit.Text)+'%';
  TabRehberIlgili.Open; }
  TabloYenile(TabRehberIlgili, [REHBER.Fields[0].AsInteger, '%'+Trim(IlgiliAraEdit.Text)+'%']);
  if not TabRehberIlgili.IsEmpty then begin
    cxGridPersoneller.DataController.FocusedRecordIndex:=0;
    cxGridPersoneller.ViewData.Records[0].Selected:=True;
  end;

  IlgiliSilTus.Visible := not TabRehberIlgili.IsEmpty;
  IlgiliDuzenleTus.Visible := IlgiliSilTus.Visible;
end;

procedure TRehberAraDlg.IlgiliDuzenleTusClick(Sender: TObject);
var
srid:integer;
begin
  srid:=cxGridPersoneller.DataController.FocusedRecordIndex;
  if Tablo.RehberSihirbazBaslat(4, REHBER.Fields[0].AsInteger,-1, TabRehberIlgili.Fields[0].AsInteger, AktifSekme='TAksiyonlarGorevFrame')>0 then begin
    TabRehberIlgili.Locate('ID', TabRehberIlgili.Fields[0].AsInteger, []);
    PageControlSekmeChange(Self);
  end;
  cxGridPersoneller.DataController.FocusedRecordIndex:=srid;
  cxGridPersoneller.ViewData.Records[srid].Selected:=True;

end;

procedure TRehberAraDlg.IlgiliEkleTusClick(Sender: TObject);
var PerID : Integer;
begin
  PerID :=Tablo.RehberSihirbazBaslat(4, REHBER.Fields[0].AsInteger, -1,-1,AktifSekme='TAksiyonlarGorevFrame');
  if PerID >0 then begin
     PageControlSekmeChange(Self) ;
     TabRehberIlgili.Locate('ID', PerID, []);
     cxGridPersonellerSelectionChanged(nil);
  end;
end;

procedure TRehberAraDlg.IlgiliSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     CariIlgiliSil(REHBER.Fields[0].AsInteger,TabRehberIlgili.Fields[0].AsInteger, TabRehberIlgili.FieldByName('STATU').AsBoolean);
     PageControlSekmeChange(Self);
  end;
end;

procedure TRehberAraDlg.info1Click(Sender: TObject);
begin
   Tablo.InfoGoster('REHBER',  REHBER.FieldByName('ID').AsInteger)
end;

procedure TRehberAraDlg.IsiKopyalaMenuClick(Sender: TObject);
begin
   Tablo.GorevKopyala(TabGorevler.Fields[0].AsInteger, TabGorevler.FieldByName('KONUSU').AsString);
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.IsiSilMenuClick(Sender: TObject);
begin
   if Tablo.GorevSil(TabGorevler.Fields[0].AsInteger) then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.IskontoTusClick(Sender: TObject);
begin
   Application.CreateForm(TIskontoDlg, IskontoDlg);
   IskontoDlg.RehberId := REHBER.Fields[0].AsInteger;
   IskontoDlg.showmodal;
   IskontoDlg.Destroy
end;

procedure TRehberAraDlg.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
    // if (TRehberAraDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).pageControlSekme.ActivePage.Name = 'TabYorumMedya') and
    //    (TRehberAraDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).REHBER.RecordCount>0) then begin

   labelFileName.Visible  := True;
   labelFileName.Caption  := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint  := Value.Strings[0];
end;

procedure TRehberAraDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  { Arama kismi henuz baslatilmadi ise cik }
  if not Assigned(FArama) then Exit;
  if Tablo.IlkAcilisSonArananMi(FIlkSonAranan) then begin Liste_SP_Cagir(5); Exit; end;   // ilk acilis: Son Aranan
  { ilk acildiginda butun kayitlar listelenmesin (Adnan) - hicbir filtre yoksa cik }
  if (FArama.AraFirma.Text='')and(FArama.AraYetkili.Text='') and(FArama.comboTemsilci.Text='') and(FArama.Arailler.Text='')and(FArama.AraOzelKod.Text='')
      and(FArama.AraKod.Text='')and(FArama.ComboGrup.Text='')and(FArama.ComboKategori.Text='')and(FArama.ComboSinif.Text='')
      and(FArama.ComboBolge.Text='')and (FArama.ComboCariAnaliz.ItemIndex<=0) then exit;
  Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP (sp_Prog_Cari_Liste)
end;

procedure TRehberAraDlg.Liste_SP_Cagir(AMod: SmallInt);
// Cari/Rehber listesini sunucu-tarafi SP ile getirir (sp_Prog_Cari_Liste_Json2, 2-param JSON).
//   AMod: 1=Tum (TOP yok), 3=Sik (KA.SAY desc), 4=Filtre/normal (JvTimer), 5=Son (KA tarih desc).
//   @Baslik = Paramst (SubSelectGetir ile birebir uretilen SELECT kolonlari) -> parite garanti.
//   @Kosullar = filtreler JSON (TJSONObject ile guvenli escape/cast). PARITE MUTLAK.
// SAYFALI (TSayfaliListe, Utablo): yalniz Mod=4 + analiz=0 dali sayfalanir.
var
  AnalizIdx, VarMod, AnalizWhere, TopN, OrderCol, GrupID, BolgeID: Integer;
  KatID, SinifID, TemsilciID, TekSubeTum: Integer;
  SubeList, TemsilciAd: string;
  j: TJSONObject;
begin
  REHBER.Close;
  SubSelectGetir;   // Paramst (SELECT kolonlari) UI durumuna gore birebir doldurulur

  AnalizIdx := FArama.ComboCariAnaliz.ItemIndex;
  if not FArama.ComboCariAnaliz.Visible then AnalizIdx := 0;

  // Analiz combosu (Borclular/Alacaklilar/Yaslandirma/Son Aktivite) secildiginde grid'de
  // borc/alacak/bakiye/takipte/irsaliye/kur kolonlarini goster; diger modlarda gizle.
  // (Yalniz Filtre modu=4'te BA/analiz verisi uretilir; Tum/Son/Sik'ta gizli kalir.)
  if AMod = 4 then BorcAlacakKolonlari(AnalizIdx) else BorcAlacakKolonlari(0);

  // @Variant: BA/analiz (SQLMemoBA) sadece Filtre modunda ve ComboCariAnaliz 1..5
  if (AMod = 4) and (AnalizIdx in [1..5]) then VarMod := 1 else VarMod := 0;
  if (AMod = 4) and (AnalizIdx in [1,2,3,4]) then AnalizWhere := AnalizIdx else AnalizWhere := 0;

  // TopN: yalniz normal filtre (ItemIndex=0) TOP uygular; digerleri TOP'suz.
  // SAYFALI (TSayfaliListe): bu dal sayfalanir; analiz/Tum/Sik/Son dallari eski davranista
  // (analiz BA toplama kolonlu -> kismi listede toplam yaniltir, bilerek sayfalanmiyor).
  FCariSonMod := AMod;
  // Mod=4 (filtre, analizsiz) ve Mod=1 (Tum) SAYFALI (stok listesiyle tutarli);
  // analiz dallari (BA toplamli) ve Sik/Son (kucuk listeler) eski davranista.
  if ((AMod = 4) and (AnalizIdx = 0)) or (AMod = 1) then
     TopN := FSayfali.TopN
  else begin
     FSayfali.TopN(False);   // tetikleri pasiflestir
     TopN := 100;
  end;

  if FArama.AraKod.Text <> '' then OrderCol := 1 else OrderCol := 0;  // KOD / FIRMA
  if FArama.ComboGrup.Text  <> '' then GrupID  := StrToIntDef(VarToStr(FArama.ComboGrup.EditValue), 0)  else GrupID  := 0;
  if FArama.ComboBolge.Text <> '' then BolgeID := StrToIntDef(VarToStr(FArama.ComboBolge.EditValue), 0) else BolgeID := 0;
  if FArama.ComboKategori.EditValue > 0 then KatID := FArama.ComboKategori.EditValue else KatID := 0;
  if FArama.ComboSinif.ItemIndex > 0 then SinifID := StrToIntDef(VarToStr(FArama.ComboSinif.EditValue), 0) else SinifID := 0;
  if FArama.comboTemsilci.Tag > 0 then TemsilciID := FArama.comboTemsilci.Tag else TemsilciID := 0;
  TemsilciAd := Trim(FArama.comboTemsilci.Text);
  if SubeVarmi then SubeList := Tablo.YetkiliSubeleriGetir(22, YetkiTur_Gorme) else SubeList := '';
  TekSubeTum := ModulYetki_TekSubeTum.Cari;

  // 2-PARAM JSON forma (MSSQL): @Baslik = Paramst (SubSelectGetir ile birebir uretilen SELECT
  //   kolonlari, ham SQL/GUVENILIR); @Kosullar = filtreler (JSON; TJSONObject ile guvenli escape).
  //   Sayilar TJSONNumber (bit'ler Ord); metin filtreleri yalniz bos degilse eklenir (absent=NULL=filtre yok).
  j := TJSONObject.Create;
  try
    j.AddPair('Variant',      TJSONNumber.Create(VarMod));
    j.AddPair('TopN',         TJSONNumber.Create(TopN));
    j.AddPair('Mod',          TJSONNumber.Create(AMod));
    j.AddPair('IlgiliArama',  TJSONNumber.Create(Ord(FArama.AraYetkili.Text <> '')));
    j.AddPair('KulId',        TJSONNumber.Create(StrToIntDef(Kullanan, 0)));
    j.AddPair('Modul',        TJSONNumber.Create(MODUL_Cari));
    j.AddPair('CRM',          TJSONNumber.Create(Ord(FArama.CheckDetay.Checked)));
    if Trim(FArama.AraFirma.Text)   <> '' then j.AddPair('AraFirma',   Trim(FArama.AraFirma.Text));
    if Trim(FArama.AraYetkili.Text) <> '' then j.AddPair('AraYetkili', Trim(FArama.AraYetkili.Text));
    if Trim(FArama.AraKod.Text)     <> '' then j.AddPair('AraKod',     Trim(FArama.AraKod.Text));
    if Trim(FArama.AraOzelKod.Text) <> '' then j.AddPair('AraOzelKod', Trim(FArama.AraOzelKod.Text));
    if Trim(FArama.Arailler.Text)   <> '' then j.AddPair('Arailler',   Trim(FArama.Arailler.Text));
    if TemsilciAd <> '' then j.AddPair('TemsilciAd', TemsilciAd);
    j.AddPair('TemsilciID',   TJSONNumber.Create(TemsilciID));
    j.AddPair('GrupID',       TJSONNumber.Create(GrupID));
    j.AddPair('BolgeID',      TJSONNumber.Create(BolgeID));
    j.AddPair('KategoriID',   TJSONNumber.Create(KatID));
    j.AddPair('SinifID',      TJSONNumber.Create(SinifID));
    j.AddPair('Pasifler',     TJSONNumber.Create(Ord(FArama.CheckPasifler.Checked)));
    j.AddPair('AksiyonFrame', TJSONNumber.Create(Ord(AktifSekme='TAksiyonlarGorevFrame')));
    j.AddPair('Potansiyel',   TJSONNumber.Create(Ord(FArama.CheckPotansiyel.Checked)));
    if SubeList <> '' then j.AddPair('SubeList', SubeList);
    j.AddPair('TekSubeTum',   TJSONNumber.Create(TekSubeTum));
    j.AddPair('SubeId',       TJSONNumber.Create(SubeId));
    j.AddPair('EkipmanFiltre',TJSONNumber.Create(Ord((AMod = 4) and (AnalizIdx = 6))));
    j.AddPair('AnalizWhere',  TJSONNumber.Create(AnalizWhere));
    j.AddPair('OrderCol',     TJSONNumber.Create(OrderCol));

    // Generic helper: @Baslik=Paramst (ham SQL) + @Kosullar=j (JSON); helper j'yi Free eder + TabloYenile yapar.
    Tablo.ListeSPJson(REHBER, 'sp_Prog_Cari_Liste_Json2', Paramst, j, 0);
    j := nil;   // sahiplik helper'a gecti -> finally'de tekrar Free etme
    FSayfali.YuklemeSonrasi;   // ekran dolana kadar zincirleme sayfa (yalniz sayfali dalda etkin)
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

procedure TRehberAraDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TRehberAraDlg.KapatTusClick(Sender: TObject);
begin
  if Assigned(FKayitErisimIptalEdildi) then
    FKayitErisimIptalEdildi(Self);
//  FKayitErisimIptalEdildi := nil;
end;

procedure TRehberAraDlg.Kopyala1Click(Sender: TObject);
begin
//  if PmProjeAktKopyala.Tags.Values['Grid']='GridProje' then
  if PmProjeAktKopyala.PopupComponent.Name ='GridCariProjeler' then begin
    if Tablo.ProjeSihirbazBaslat('K',TabProjeler.FieldByName('ID').AsInteger,TabProjeler.FieldByName('REHBERID').AsInteger,Tablo.GENINI.BugunTrhSaat) > 0 then
      TabProjeler.Close;
    TabProjeler.Open;
  end;
end;

procedure TRehberAraDlg.Kopyala2Click(Sender: TObject);
var FaturaIDsi : integer;
begin
  if not (TabCariListe.FieldByName('TUR').AsInteger in [9,19,101]) then begin //sipariş ise kontrole gerek yok
      Tablo.TablodanSorguAc(1,'select * from FATURA F where F.IZLEME <> 0 and F.FATBASID='+TabCariListe.FieldByName('CEKID').AsString);
      if Tablo.Query1.RecordCount > 0 then begin
          Tablo.UyariGoster(Uyari,'Belge içeriğinde izlem bilgisi aktif ürünler var, bu işlem gerçekleştirilemez.');
          Exit;
      end;
  end;
  FaturaIDsi := Tablo.BelgeKopyala(TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TUR').AsInteger,
                 TabCariListe.FieldByName('REHBERID').AsInteger, TabCariListe.FieldByName('AKSIYONTARIH').AsDateTime);

  if TabCariListe.FieldByName('TUR').AsInteger in [13,17] then begin
    Tablo.TahakkukSihirbaziBaslat('K',TabCariListe.FieldByName('TUR').AsInteger,1, FaturaIDsi, TabCariListe.FieldByName('REHBERID').AsInteger,-1);
    PageControlSekmeChange(Self);
  end else if TabCariListe.FieldByName('TUR').AsInteger in [11,12,15,16] then begin   //10,14      irsaliye     TabCariListe.FieldByName('CEKID').AsInteger
    Tablo.FaturaSihirbazBaslat('K', TabCariListe.FieldByName('TUR').AsInteger ,0, FaturaIDsi, TabCariListe.FieldByName('REHBERID').AsInteger, 1,False,-1);
    PageControlSekmeChange(Self);
  end else
    ShowMessage(RDAlisveSatisBelgeKopyalayin);
end;

procedure TRehberAraDlg.KurFarkGeliri1Click(Sender: TObject);
begin
   Tablo.NakitSihirbazBaslat('-','E', TMenuItem(Sender).Tag,4, -1,REHBER.Fields[0].AsInteger , Tablo.GENINI.BugunTrhSaat, '-1',False,0);
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.LogoResimClick(Sender: TObject);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Rehber,REHBER.Fields[0].AsInteger);
   TabloYenile(TabResim,[REHBER.Fields[0].AsInteger]);
end;

procedure TRehberAraDlg.MasrafNakitMenuClick(Sender: TObject);
var HesapTuru : char;
begin
   // masrafta cari se?ilmez yani rehberid s?f?rd?r
   case TMenuItem(Sender).Tag of
     21,31 : HesapTuru := 'K';
     22,32 : HesapTuru := 'B';
     25,35 : HesapTuru := 'V';
   end;
   Tablo.NakitSihirbazBaslat(HesapTuru,'E', TMenuItem(Sender).Tag,1, -1, 0,
         StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',
         Tablo.GENINI.BugunTrhSaat)+FormatDateTime(' hh:nn:ss', Tablo.GENINI.BugunTrhSaat)), '-1');
end;

procedure TRehberAraDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TRehberAraDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TRehberAraDlg.MusteriListesineEkleMenuClick(Sender: TObject);
var EditKOD : String;
    YeniKod : Variant;
begin
   if tablo.GENINI.ReadInteger(Ops_OpsiyonCari_CariKodGirisi, 2) <> 2 then begin // CariOpsiyon  CariKodGirisi
      //kod manuel
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BGMusteri_kodu_gir, @YeniKod)) <> mrOk then
         Abort;
      EditKOD :=  VarToStr(YeniKod);
   end else
      EditKOD := tablo.KodBulmaSihirbazi(120, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI', 'REHBER', 'KOD',120);

   if EditKOD <> '0' then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBER Set GRUP=120, KOD='''+EditKOD+''' Where ID=&RehID',['&RehID'],[REHBER.FieldByName('ID').AsInteger]);
      CariGridView.DataController.DeleteRecord(CariGridView.DataController.FocusedRecordIndex);
   end;
end;

procedure TRehberAraDlg.MutabakatKaydiEkleMenuClick(Sender: TObject);
begin
//
  if Tablo.AcilisiFisiEkraniBaslat(1,TMenuItem(Sender).Tag, REHBER.FieldByname('ID').AsString,REHBER.FieldByname('KOD').AsString,REHBER.FieldByname('FIRMA').AsString,'', 0,Tablo.GENINI.BugunTrhSaat) then
     PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.EkimanKopyalaMenuClick(Sender: TObject);
var Id,EID,EEID : Integer;
begin
   if TmenuItem(Sender).Name='BaskacariyekopyalaMenu' then begin
      Id := Tablo.RehberAra_IDGetir(-99);
      if Id<1 then exit;
   end;

   EID := Tablo.SatirKopyala('EKIPMANREHBER', TabEkipmanlar.FieldByName('ID').AsInteger);
   if Id>1 then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE EKIPMANREHBER SET REHBERID='+IntToStr(Id)+' WHERE ID = &ID', ['&ID'],[IntToStr(EID)]);
   TabEkipmanEkBilgi.First;
   while not TabEkipmanEkBilgi.Eof do begin
      Tablo.TablodanSorguAc(5,'select * from REHBERBILGI where ID=-1');
      Tablo.Query5.Append;
      Tablo.SatirKopyala2('REHBERBILGI', TabEkipmanEkBilgi.FieldByName('ID').AsInteger, Tablo.Query5);
      Tablo.Query5.FieldByName('YER_ID').AsInteger := EID;
      Tablo.Query5.Post;
      TabEkipmanEkBilgi.Next;
   end;
   PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.Nakit3Click(Sender: TObject);
//var Tur : SmallInt;
//    HesapTuru : Char;
//    Tutar : Currency;
begin
{   Tur := TMenuItem(Sender).Tag;
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
     13,17 : Tablo.TahakkukSihirbaziBaslat('E', Tur, 1, -1, TabCariListe.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrhSaat, False,TabCariListe.FieldByName('MASRAFID').AsInteger);
     21,22,25,31,32,35  : begin
     //ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,0, -1, RehberId, Tablo.GENINI.BugunTrhSaat, '-1');
       Application.CreateForm(TNakitDlg, NakitDlg);
       NakitDlg.ID := -1;
       NakitDlg.Tur := Tur;
       NakitDlg.Cagiran:=2;
       NakitDlg.HesapTuru := HesapTuru;
       NakitDlg.IslemOp := 'E';
       NakitDlg.RehberId := TabCariListe.FieldByName('REHBERID').AsInteger;
       NakitDlg.MakbuzTarih := Tablo.GENINI.BugunTrhSaat;
       NakitDlg.LabelTarih.Visible := True; //men?den k?sayol oldu?u i?in tarih girilebilir
       NakitDlg.EditTarih.Visible := True;
       NakitDlg.MakbuzNo := Tablo.MakbuzNoGetir(Tur);
       NakitDlg.Aciklama := TabCariListe.FieldByName('ACIKLAMA').AsString;
       NakitDlg.MasrafMerkezi := TabCariListe.FieldByName('MASRAFID').AsInteger;
       NakitDlg.Tutar := Tutar;
       NakitDlg.Kur := TabCariListe.FieldByName('KUR').AsString;
       NakitDlg.showmodal;
       if NakitDlg.ModalResult = mrOk  then
       NakitDlg.Destroy;
     end;
     23,33 : Tablo.CekSihirbazBaslat('E', Tur, 0, -1, TabCariListe.FieldByName('REHBERID').AsInteger,-1,Tablo.GENINI.BugunTrhSaat, '');
     24,34 : Tablo.SenetSihirbazBaslat('E', Tur, 0, -1, TabCariListe.FieldByName('REHBERID').AsInteger,-1,Tablo.GENINI.BugunTrhSaat, '');
   end;
   PageControlSekmeChange(Self); }
end;

procedure TRehberAraDlg.OdemeTahsilatYapMenuClick(Sender: TObject);
begin
   if Tablo.TahsilatIslemi(TabCariListe.FieldByName('TUR').AsInteger,REHBER.FieldByname('ID').AsInteger,TabCariListe.FieldByName('MASRAFID').AsInteger,
      Abs(TabCariListe.FieldByName('BORC').AsCurrency-TabCariListe.FieldByName('ALACAK').AsCurrency),
              TabCariListe.FieldByName('KUR').AsString,TabCariListe.FieldByName('ACIKLAMA').AsString, Tablo.GENINI.BugunTrhSaat) then
      PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.OzlukDuzenleTusClick(Sender: TObject);
begin
  if Tablo.RehberSihirbazBaslat( 3, REHBER.Fields[0].AsInteger,-1, -11, AktifSekme='TAksiyonlarGorevFrame') > 0 then
    PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.PageControlGiderChange(Sender: TObject);
begin
  PageControlSekmeChange(Self);
end;

procedure TRehberAraDlg.KurumXSLTSec(ABolum, ARaporID: Integer;
  AEdit: TcxButtonEdit; AButtonIndex: Integer);
var
  LSecim: Variant;
  LRehberID: Integer;
  LXSLTAdi: string;
begin
  if (not REHBER.Active) or REHBER.IsEmpty then
    Exit;
  LRehberID := REHBER.FieldByName('ID').AsInteger;
  if LRehberID <= 0 then begin
    ShowMessage('Once bir cari seciniz.');
    Exit;
  end;

  // Ikinci buton ( - ) : kuruma ozel XSLT secimini temizle
  if AButtonIndex = 1 then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'delete from GENINI where BOLUM=&B and DEGER=&D',
      ['&B', '&D'], [ABolum, LRehberID]);
    AEdit.Text := '';
    Exit;
  end;

  // Ellipsis : DOKUMLER'deki ilgili turdeki XSLT'leri combo ile listele
  LSecim := Null;
  if TGirisKutusuEx.BilgiAlEx('XSLT Seciniz', TGirdiDenetimleri.Create
     .ImageComboBox('XSLT', @LSecim, Tablo.FDCnn,
       'select RAPORADI,RAPORADI from DOKUMLER where GRUBU=''XSLT'' and RAPORID=' +
       IntToStr(ARaporID) + ' order by 2', False, nil)) <> mrOk then
    Exit;
  LXSLTAdi := Trim(VarToStr(LSecim));
  if LXSLTAdi = '' then
    Exit;

  // GENINI'ye upsert: BOLUM=belge tipi, DEGER=REHBERID, ANAHTAR=XSLT adi
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'delete from GENINI where BOLUM=&B and DEGER=&D',
    ['&B', '&D'], [ABolum, LRehberID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL) values(&B,&A,&D,-1)',
    ['&B', '&A', '&D'], [ABolum, LXSLTAdi, LRehberID]);
  AEdit.Text := LXSLTAdi;
end;

procedure TRehberAraDlg.KurumXSLTYukle;
  function _Oku(ABolum: Integer): string;
  begin
    Result := '';
    Tablo.TablodanSorguAc(1,
      'select '+DbUst(1)+'ANAHTAR from GENINI where DIL=-1 and BOLUM=' +
      IntToStr(ABolum) + ' and DEGER=' + REHBER.FieldByName('ID').AsString + ' '+DbSinir(1));
    if not Tablo.Query1.Eof then
      Result := Trim(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Close;
  end;
begin
  if (not REHBER.Active) or REHBER.IsEmpty then
    Exit;
  EditEFaturaXSLT.Text := _Oku(Ops_KurumXSLT_EFatura);
  EditEArsivXSLT.Text := _Oku(Ops_KurumXSLT_EArsiv);
  EditEIrsaliyeXSLT.Text := _Oku(Ops_KurumXSLT_EIrsaliye);
end;

procedure TRehberAraDlg.EditEFaturaXSLTPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  KurumXSLTSec(Ops_KurumXSLT_EFatura, 2, EditEFaturaXSLT, AButtonIndex);
end;

procedure TRehberAraDlg.EditEArsivXSLTPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  KurumXSLTSec(Ops_KurumXSLT_EArsiv, 12, EditEArsivXSLT, AButtonIndex);
end;

procedure TRehberAraDlg.EditEIrsaliyeXSLTPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  KurumXSLTSec(Ops_KurumXSLT_EIrsaliye, 52, EditEIrsaliyeXSLT, AButtonIndex);
end;

procedure TRehberAraDlg.ButtonFaturaDipNotuClick(Sender: TObject);
var
  LMetin: Variant;
  LRehberID, LID: Integer;
  LMevcut: string;
begin
  if (not REHBER.Active) or REHBER.IsEmpty then
    Exit;
  LRehberID := REHBER.FieldByName('ID').AsInteger;
  if LRehberID <= 0 then begin
    ShowMessage('Once bir cari seciniz.');
    Exit;
  end;

  // Bu cariye ait fatura dip notu varsa hazirda getir (GOREVYORUM TUR=400)
  LMevcut := '';
  LID := 0;
  Tablo.TablodanSorguAc(1,
    'select '+DbUst(1)+'ID, YORUM from GOREVYORUM where TUR=400 and GOREVID=' +
    IntToStr(LRehberID) + ' order by ID '+DbSinir(1));
  if not Tablo.Query1.Eof then begin
    LID := Tablo.Query1.FieldByName('ID').AsInteger;
    LMevcut := Tablo.Query1.FieldByName('YORUM').AsString;
  end;
  Tablo.Query1.Close;

  LMetin := LMevcut;
  if TGirisKutusuEx.BilgiAlEx('Fatura Dip Notu',
     TGirdiDenetimleri.Create.Memo('Dip Notu', @LMetin)) <> mrOk then
    Exit;

  // GOREVYORUM'a kaydet: TUR=400, GOREVID=REHBERID, YORUM=icerik (upsert)
  if LID > 0 then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'update GOREVYORUM set YORUM=&Y, DEGISTIREN=&K, DEGISTIRMETARIHI=getdate() where ID=&ID',
      ['&Y', '&K', '&ID'], [VarToStr(LMetin), StrToIntDef(Kullanan, 0), LID])
  else
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'insert into GOREVYORUM(GOREVID,TUR,YORUM,EKLEYEN,EKLEMETARIHI) ' +
      'values(&G,400,&Y,&K,getdate())',
      ['&G', '&Y', '&K'], [LRehberID, VarToStr(LMetin), StrToIntDef(Kullanan, 0)]);
end;

procedure TRehberAraDlg.CRMAltSekmeYenile;
// CRM alt sekmelerinin (Is Listesi / Satis Firsatlari / Projeler) verisini
//   yukler. Hem ust sekme CRM'e gelince hem de alt sekme degisince cagrilir.
var
  AcKapa: String[1];
  GunSay: Smallint;
begin
  if not(REHBER.Active) or (REHBER.IsEmpty) then
    Exit;

  if PageControlCRM.ActivePage = TabSheetGorev then begin
    AcKapa:=IntToStr(Abs(StrToInt(BoolToStr(CheckTamamlanan.Checked))));
    if CheckTamamlanan.Checked then
       GunSay := ComboTamamlanan.EditValue
    else
       GunSay := 9999;
    TabloYenile(TabGorevler,[REHBER.FieldByName('ID').AsString, AcKapa,  GunSay]);
    //GorevGridDBTableView1.ViewData.Expand(True);
  end else if PageControlCRM.ActivePage = TabSheetFirsat then begin
      TabFirsat.Close;
      TabFirsat.SQL.Text:= MemoFirsat.Text;
      if not(checkKapaliFirsatGoster.Checked) then
         TabFirsat.SQL.Add(' AND P.DURUM <> 2 ');
      case ModulYetki_TekSubeTum.Proje of
        1 : TabFirsat.SQL.Add(' AND P.PRJ_SORUMLUSU_ID='+Kullanan);//sadece kendi f?rsatlar?n? g?r?r
       10 : TabFirsat.SQL.Add(' AND P.SUBEID='+IntToStr(SubeId));//sadece kendi ?ube f?rsatlar?n? g?r?r
      end;
      TabFirsat.SQL.Add(' ORDER BY BITISTARIHI DESC ');
      TabloYenile(TabFirsat,[REHBER.FieldByName('ID').AsInteger]);
  end else if PageControlCRM.ActivePage = TabSheetProje then begin
      TabProjeler.Close;
      TabProjeler.SQL.Text:= MemoProjeler.Text;
      if not(checkKapaliProjeGoster.Checked) then
         TabProjeler.SQL.Add(' AND P.DURUM <> 2 ');
      case ModulYetki_TekSubeTum.Proje of
        1 : TabProjeler.SQL.Add(' AND P.PRJ_SORUMLUSU_ID='+Kullanan);//sadece kendi projelerini g?r?r
       10 : TabProjeler.SQL.Add(' AND P.SUBEID='+IntToStr(SubeId));//sadece kendi ?ube projelerini g?r?r
      end;
      TabProjeler.SQL.Add(' ORDER BY BITISTARIHI DESC ');
      TabloYenile(TabProjeler,[REHBER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TRehberAraDlg.PageControlCRMChange(Sender: TObject);
begin
  CRMAltSekmeYenile;
end;

procedure TRehberAraDlg.ServisAltSekmeYenile;
// Servis ust sekmesinin alt sekmeleri (Servis listesi / Ekipman). Hem ust sekme
//   Servis'e gelince hem de alt sekme degisince cagrilir.
var
  j: TJSONObject;
begin
  if not(REHBER.Active) or (REHBER.IsEmpty) then
    Exit;

  if PageControlServis.ActivePage = TabSheetServisListe then begin
    // Servis listesi ile AYNI SP; farki: RehberId ile yalniz bu carinin servisleri
    //   (bu yuzden gridde cari adi kolonu da yok).
    j := TJSONObject.Create;
    try
      j.AddPair('Mod',      TJSONNumber.Create(4));
      j.AddPair('TopN',     TJSONNumber.Create(0));   // 0 = TOP yok (tumu)
      j.AddPair('Pasif',    TJSONNumber.Create(0));
      j.AddPair('RehberId', TJSONNumber.Create(REHBER.FieldByName('ID').AsInteger));
      j.AddPair('cbListe',  TJSONNumber.Create(9));   // kullanici/sube kisiti yok
      // Kapanmis servisler de gorunsun: SP'de Kapali=1 tek basina yetmez, kapali
      //   kayitlar icin bir TARIH kisiti bekler (Tamamlanan=19000 -> aralik modu).
      //   Cari kartinda TUM gecmis istendigi icin aralik olabildigince genis verilir.
      j.AddPair('Kapali',     TJSONNumber.Create(1));
      j.AddPair('Tamamlanan', TJSONNumber.Create(19000));
      j.AddPair('TarihBas',   '1900-01-01');
      j.AddPair('TarihBit',   '2999-12-31');
      Tablo.ListeSPJson(TabCariServis, 'sp_Prog_Servis_Liste_Json2', '', j, 0);
      j := nil;   // sahiplik helper'a gecti
    finally
      j.Free;
    end;
  end else if PageControlServis.ActivePage = SheetRakipEkipman then begin
    TabloYenile(TabEkipmanRakip,[REHBER.Fields[0].AsInteger]);
  end else if PageControlServis.ActivePage = SheetBizimEkipman then begin
    TabloYenile(TabEkipmanlar,[REHBER.Fields[0].AsInteger]);
    (TreeListEkipmancxDBTreeListColumn3.Properties as TcxImageComboBoxProperties).Items.Clear;
    Tablo.TablodanSorguAc(7,'select ID,AD from REHBERILETISIM where REHBERID='+REHBER.FieldByName('ID').AsString,false);
    Tablo.Query7.First;
    while not Tablo.Query7.Eof do begin
      with (TreeListEkipmancxDBTreeListColumn3.Properties as TcxImageComboBoxProperties).Items.Add do begin
        Description := Tablo.Query7.FieldByName('AD').AsString;
        Value := Tablo.Query7.FieldByName('ID').AsInteger;
        ImageIndex := -1;
      end;
      Tablo.Query7.Next;
    end;
  end;
end;

procedure TRehberAraDlg.PageControlServisChange(Sender: TObject);
begin
  ServisAltSekmeYenile;
end;

procedure TRehberAraDlg.AlisSatisAltSekmeYenile;
// Alis/Satis alt sekmeleri (siparis / irsaliye / konsinye x alis-satis).
//   Fatura listesindeki gibi TEK GRID kullanilir: alt sekme yalniz belge TURunu
//   (sekmenin Tag'i) degistirir, kolonlar aynidir. Iki SP de ayni kolon adlarini
//   dondurur (SIPARIS tarafinda FATURANO/FATURATARIH takma ad).
//   Cari adi kolonu YOK: liste zaten tek cariye ait (RehberId).
var
  j: TJSONObject;
  LSayfa: TcxTabSheet;
  LTur: Integer;
  LSP: string;
begin
  if not(REHBER.Active) or (REHBER.IsEmpty) then
    Exit;
  LSayfa := PageControlAlisSatis.ActivePage;
  if LSayfa = nil then
    Exit;
  LTur := LSayfa.Tag;
  if LTur = 0 then
    Exit;

  // Grid tek nesne; etkin sekmeye tasinir (her sekmeye ayri grid koymak yerine).
  if GridCariBelge.Parent <> LSayfa then
    GridCariBelge.Parent := LSayfa;

  if LTur in [9, 19, 101] then          // siparis/talep AYRI tabloda (SIPARIS)
    LSP := 'sp_Prog_AlisSatis_Siparis_Json2'
  else
    LSP := 'sp_Prog_AlisSatis_IrsFatFisKons_Json2';

  j := TJSONObject.Create;
  try
    j.AddPair('TopN',     TJSONNumber.Create(0));   // 0 = TOP yok (cari basina kucuk kume)
    j.AddPair('Tur',      TJSONNumber.Create(LTur));
    j.AddPair('RehberId', TJSONNumber.Create(REHBER.FieldByName('ID').AsInteger));
    Tablo.ListeSPJson(TabCariBelge, LSP, '', j, 0);
    j := nil;   // sahiplik helper'a gecti
  finally
    j.Free;
  end;

  // Kolon duzeni ALT SEKME BASINA saklanir: alis siparisi ile satis irsaliyesinin
  //   kullanisli kolonlari ayni degil (fatura listesindeki desen: ad + AltTur).
  Tablo.GridAyarRestore(AlisSatisGridAyarAdi, GridCariBelgeView);
end;

function TRehberAraDlg.AlisSatisGridAyarAdi: string;
// Grid ayar anahtari - etkin alt sekmenin belge TUR'unu tasir (Tag).
begin
  Result := 'CariAlisSatisGridi';
  if (PageControlAlisSatis <> nil) and (PageControlAlisSatis.ActivePage <> nil) then
    Result := Result + '-' + IntToStr(PageControlAlisSatis.ActivePage.Tag);
end;

procedure TRehberAraDlg.GridCariBelgeViewCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
// Ortak kolon/stil menusu (AnaForm.cxGridPopupMenu1) bu gride baglanir; kaydetme
//   anahtari alt sekmeye gore degisir -> her belge turu kendi duzenini saklar.
begin
  AnaForm.cxGridPopupMenu1.Grid := GridCariBelge;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridCariBelgeView;
  AnaForm.pmGridStil.Tags.Values[GridCariBelge.Name] := AlisSatisGridAyarAdi;
end;

procedure TRehberAraDlg.PageControlAlisSatisChange(Sender: TObject);
begin
  AlisSatisAltSekmeYenile;
end;

procedure TRehberAraDlg.PageControlSekmeChange(Sender: TObject);
var AcKapa:String[1];
    GunSay : Smallint;
    ARecIndex,i:Integer;
    ra:string;
begin

  if not(REHBER.Active)or(REHBER.IsEmpty) then
    Exit;
  if (PageControlSekme.ActivePageIndex > 0)and(REHBER.Fields[0].AsInteger<>SonEklenenCari) then begin
     // Son/Sik Aranan takibi: KULLANICI_REHBER yerine generic KULLANICI_ARAMA (MODUL_Cari)
     Tablo.AramaKaydet(MODUL_Cari, REHBER.Fields[0].AsInteger);
     SonEklenenCari := REHBER.Fields[0].AsInteger;   // ayni kart icin tekrar yazmayi engelle
  end;
  if PageControlSekme.ActivePage=TabSheetIlet then begin
     TabloYenile(REHBERILETISIM,[REHBER.Fields[0].AsInteger]);
     GridRehberIletisimViewSelectionChanged(GridRehberIletisimView);
  end else if PageControlSekme.ActivePage=TabSheetIlgili then
     IlgiliAraEditPropertiesChange(Self)
  else if PageControlSekme.ActivePage=TabSheetTicari then begin
     TabloYenile(TabTicari,[REHBER.Fields[0].AsInteger]);
     TabloYenile(TabBankaHesaplar,[REHBER.Fields[0].AsInteger]);
     KurumXSLTYukle;
     // Alias grid'i artik Ticari > E-Belge alt sekmesinde; cari degisince yenile.
     TabAlias.Close;
     TabAlias.SQL.Text := 'SELECT * FROM REHBERALIAS WHERE REHBERID = ' +
                          IntToStr(REHBER.Fields[0].AsInteger);
     if AktifVeriMotor = vmPG then TabAlias.SQL.Text := PgSqlCevir(TabAlias.SQL.Text);
     TabAlias.Open;
     AliasToolbarDurumuGuncelle(False);
  end  else if PageControlSekme.ActivePage=TabSheetCRM then
     // Uc CRM listesi artik PageControlCRM'in ALT SEKMELERI; hangisi etkinse
     //   onun verisi yuklenir. PageControlSekme.ActivePage burada daima
     //   TabSheetCRM'dir - eskisi gibi dogrudan karsilastirmak calismaz.
     CRMAltSekmeYenile
  else if PageControlSekme.ActivePage=TabSheetTeklifler then begin
    TabloYenile(TabTeklifler,[REHBER.FieldByName('ID').AsInteger]);
  //  GridTeklifView.ApplyBestFit();
  end else if PageControlSekme.ActivePage=TabyorumMedya then begin
        Tabloyenile(TabYorum,[TabloNo, REHBER.FieldByName('ID').AsInteger]);
        if AktifVeriMotor = vmPG then
        begin
          TabYorum2.Close;
          TabYorum2.SQL.Text :=
            '/*PGX*/ '+
            'select GY.ID,GY.GOREVID,GY.EKLEMETARIHI,GY.EKLEYEN, '+
            '(select ANAHTAR from GENINI where BOLUM=-11110 and DEGER=GY.TUR limit 1) as "Modül", '+
            'to_char(GY.EKLEMETARIHI,''DD Mon YYYY HH24:MI'') as TARIH, R.FIRMA as YAZAN, GY.YORUM, '+
            'case when position(''.'' in reverse(coalesce(D.AD,'''')))>0 then reverse(left(reverse(D.AD), position(''.'' in reverse(D.AD)))) else '''' end as ATAC, '+
            'D.ID as DOKUMANID, D.AD as DOKUMANAD '+
            'from GOREVYORUM GY '+
            'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '+
            'left outer join REHBER R on R.ID=GY.EKLEYEN '+
            'where (:YerID=:YerID) and ('+
            '(GY.TUR in (28,29,104,105,106,107,209,214,219) and GOREVID in (select ID from FATBASLIK where REHBERID=:PRID)) '+
            'or (GY.TUR=97 and GOREVID in (select ID from TEKLIF where REHBERID=:PRID)) '+
            'or (GY.TUR=47 and GOREVID in (select ID from KREDILER where REHBERID=:PRID)) '+
            'or (GY.TUR in (15,315,316) and GOREVID in (select ID from CEKLER where REHBERID=:PRID)) '+
            'or (GY.TUR=33 and GOREVID in (select ID from GOREVLER where REHBERID=:PRID)) '+
            'or (GY.TUR=70 and GOREVID in (select ID from PROJELER where REHBERID=:PRID)) '+
            'or (GY.TUR=83 and GOREVID in (select ID from SERVIS where REHBERID=:PRID)) '+
            'or (GY.TUR in (91,92) and GOREVID in (select ID from SIPARIS where REHBERID=:PRID))) '+
            'order by GY.GOREVID desc';
        end;
        Tabloyenile(TabYorum2,[TabloNo,REHBER.FieldByName('ID').AsInteger]);
  end else if PageControlSekme.ActivePage=TabSheetYaslandirma then begin
    TabloYenile(TabYaslandirma,[REHBER.FieldByName('ID').AsInteger, FormatDateTime('yyyy-mm-dd hh:nn', Tablo.GENINI.BugunTrhSaat), REHBER.FieldByName('KUR').AsString]); //,Tablo.GENINI.BugunTrh+1
  end else if PageControlSekme.ActivePage=TabSheetEkstre then begin
    CalendarEkstreBasPropertiesEditValueChanged(Self);
  end else if PageControlSekme.ActivePage=TabSheetServisAna then
    // Ekipman artik Servis ust sekmesinin ALT SEKMESI; yukleme oraya tasindi.
    ServisAltSekmeYenile
  else if PageControlSekme.ActivePage=TabSheetAlisSatis then
    AlisSatisAltSekmeYenile;
  //PopupMenuYaz.Items.Clear;
  for i := PopupMenuYaz.Items.Count-1 downto 0 do
    if (Assigned(PopupMenuYaz.Items[i])) and (PopupMenuYaz.Items[i].MenuIndex>N3.MenuIndex) then
      PopupMenuYaz.Items[i].Destroy;
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;
end;

procedure TRehberAraDlg.PopupMenuREHBERPopup(Sender: TObject);
begin
  BorcAlacakKapamaMenu.Enabled :=(REHBER.Active)and(not REHBER.IsEmpty)and(REHBER.FieldByName('GRUP').AsInteger<>1) ;
  GorMenu.Enabled := BorcAlacakKapamaMenu.Enabled;
  AcilisiFisiMenu.Enabled := BorcAlacakKapamaMenu.Enabled;
  DevirFisiMenu.Enabled := BorcAlacakKapamaMenu.Enabled;

  MusteriListesineGonderMenu.Visible := AktifSekme='TAksiyonlarGorevFrame';
  PotansiyelListesineGnderMenu.Visible := not MusteriListesineGonderMenu.Visible  ;
end;

procedure TRehberAraDlg.PopupMenuYeniPopup(Sender: TObject);
begin
   AlisBelgesiMenu.visible := REHBER.FieldByName('GRUP').AsInteger<>1;
   SatisBelgesiMenu.visible := AlisBelgesiMenu.visible;
   AcilisFisiGirMenu.visible := AlisBelgesiMenu.visible;
   CariOdemeMenu.visible := AlisBelgesiMenu.visible;
   CariTahsilatMenu.visible := AlisBelgesiMenu.visible;
   OdemePlanMenu.visible := AlisBelgesiMenu.visible;
   TahsilatPlanMenu.visible := AlisBelgesiMenu.visible;
   MasrafOdemeMenu.visible := AlisBelgesiMenu.visible;
   GelirTahsilatMenu.visible := AlisBelgesiMenu.visible;
   PotansiyelListesineGonderMenu.visible := AlisBelgesiMenu.visible;
   MusteriListesineEkleMenu.visible := not AlisBelgesiMenu.visible;

   if AlisBelgesiMenu.visible then begin
       AlisBelgesiMenu.Enabled := REHBER.FieldByName('DURUM').AsInteger in [1,2];
       SatisBelgesiMenu.Enabled := AlisBelgesiMenu.Enabled;
       AcilisFisiGirMenu.Enabled := AlisBelgesiMenu.Enabled;
       CariOdemeMenu.Enabled := AlisBelgesiMenu.Enabled;
       OdemePlanMenu.Enabled := AlisBelgesiMenu.Enabled;
   end;
end;

procedure TRehberAraDlg.PopupYorumlarPopup(Sender: TObject);
begin
    if GridYorum.ActiveView = GridYorumDBCardView1 then
       DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>''
    else
       DkmanGster1.Visible := TabYorum2.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TRehberAraDlg.PopupYorumuSilClick(Sender: TObject);
begin
   if GridYorum.ActiveView = GridYorumDBCardView1 then
      Tablo.GridYorumuSil(TabloNo, REHBER.FieldByName('ID').AsInteger, TabYorum)
   else
      Tablo.GridYorumuSil(TabloNo, REHBER.FieldByName('ID').AsInteger, TabYorum2);
end;

procedure TRehberAraDlg.PotansiyelListesineGonderMenuClick(Sender: TObject);
begin
   if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from FATBASLIK where REHBERID =  &RId', ['&RId'],[REHBER.FieldByName('ID').AsInteger]) then
      raise Exception.Create(Hareketgormussilinemez);
   if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from KASA where REHBERID =  &RId', ['&RId'],[REHBER.FieldByName('ID').AsInteger]) then
      raise Exception.Create(Hareketgormussilinemez);
   if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from CEKLER where REHBERID =  &RId', ['&RId'],[REHBER.FieldByName('ID').AsInteger]) then
      raise Exception.Create(Hareketgormussilinemez);

    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBER Set GRUP=1, KOD='''+REHBER.FieldByName('ID').AsString+''' Where ID=&RehID',['&RehID'],[REHBER.FieldByName('ID').AsInteger]);
    CariGridView.DataController.DeleteRecord(CariGridView.DataController.FocusedRecordIndex);
end;

procedure TRehberAraDlg.ProjeDuzenleClick(Sender: TObject);
begin
  if PageControlSekme.ActivePage=TabSheetFirsat then begin
   if Tablo.FirsatSihirbazBaslat('D',
              TabFirsat.Fields[0].AsInteger,
              REHBER.Fields[0].AsInteger,
              Tablo.GENINI.BugunTrh) > 0 then
      PageControlSekmeChange(Self);
  end else begin
   if Tablo.ProjeSihirbazBaslat('D',
              TabProjeler.Fields[0].AsInteger,
              REHBER.Fields[0].AsInteger,
              Tablo.GENINI.BugunTrh) > 0 then
      PageControlSekmeChange(Self);
  end;

end;

procedure TRehberAraDlg.ProjeEkleTusClick(Sender: TObject);
begin
  if PageControlSekme.ActivePage=TabSheetFirsat then begin
   if Tablo.FirsatSihirbazBaslat('E',-1,
            REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrh) > 0 then
      PageControlSekmeChange(Self);
  end else begin
   if Tablo.ProjeSihirbazBaslat('E',-1,
            REHBER.Fields[0].AsInteger, Tablo.GENINI.BugunTrh) > 0 then
      PageControlSekmeChange(Self);
  end;

end;

procedure TRehberAraDlg.ProjeSilTusClick(Sender: TObject);
begin
  if PageControlSekme.ActivePage=TabSheetFirsat then begin
    if Tablo.ProjeSilmeIslemleri(TabFirsat,TabFirsat.Fields[0].AsInteger) then begin
      PageControlSekmeChange(Self);
      Abort;
    end;
  end else begin
    if Tablo.ProjeSilmeIslemleri(TabProjeler,TabProjeler.Fields[0].AsInteger) then begin
      PageControlSekmeChange(Self);
      Abort;
    end;
  end;
end;

procedure TRehberAraDlg.REHBERBeforeOpen(DataSet: TDataSet);
begin
  rehberdetayaktif:=False;
end;

initialization
  RegisterClass(TRehberAraDlg);
end.

{
	--GOREV = (select top 1 BILGI from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RA.SIRA=RB.SIRA
-- AND RA.VARSAYILAN=175  where RB.YERI=4 AND RB.YER_ID=RP.ID),
	--LOKASYON = (select top 1 BILGI from REHBERBILGI RB inner join  REHBERAYAR RA on RB.ETIKET=RA.ETIKET and RB.YERI=RA.YERI
-- and RB.SIRA=RA.SIRA and RA.VARSAYILAN=88 and RB.YER_ID=RP.ID ),
}










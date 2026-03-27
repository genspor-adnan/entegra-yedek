unit UServisWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore,  cxGraphics,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxCurrencyEdit,
  cxLabel, cxButtonEdit, cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard, cxStyles,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxNavigator,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, dxBarBuiltInMenu,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons, JvDragDrop,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, cxPC, cxCheckBox, UGentegreFrameYonetimi,
  dxSkinLondonLiquidSky, Utablo, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer,
  cxTLData, cxDBTL,UStokHizmetAra,UKodAgaci,Generics.Collections,JvComponentBase,
  cxGridCardView, cxGridDBCardView, Vcl.DBCtrls, dxCore, cxDateUtils, cxBlobEdit,
  cxHyperLinkEdit, cxLookAndFeels, cxPCdxBarPopupMenu, cxGridCustomLayoutView,
  dxSkinLiquidSky, UServisSonlandir, UGenNotificationUtils, JvNavigationPane,
  cxGridCustomPopupMenu, cxGridPopupMenu, UMailGonderim, OfficePopupMenu,
  dxSkinscxPCPainter, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxSplitter, cxVGrid,
  cxOI, cxRichEdit, dxScrollbarAnnotations, dxDateRanges, dxCoreGraphics,
  frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TServisWizardDlg = class(TForm, IPopupDialog)
    Panel1: TPanel;
    WizardKontrol: TJvWizard;
    ServisEkr: TJvWizardInteriorPage;
    DetayEkr: TJvWizardInteriorPage;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    YeniTemelTus: TToolButton;
    SilTemelTus: TToolButton;
    OpenDialog1: TOpenDialog;
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
    TabServis: TFDQuery;
    DtsServis: TDataSource;
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
    frxServis: TfrxDBDataset;
    ServisPageControl: TcxPageControl;
    SheetBelgeler: TcxTabSheet;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    cxDBLabel5: TcxDBLabel;
    PopupMenuKopya: TPopupMenu;
    MenuButunServisKopyala: TMenuItem;
    MenuSadeceDetay: TMenuItem;
    TabServisBelge: TFDQuery;
    DtsServisBelge: TDataSource;
    frxServisBelge: TfrxDBDataset;
    lblMusteriAdres: TcxLabel;
    frxServisGenel: TfrxDBDataset;
    TabServisNotlar: TFDQuery;
    DtsServisNotlar: TDataSource;
    frxServisNotlar: TfrxDBDataset;
    TabEkipmanDetay: TFDQuery;
    DtsEkipmanDetay: TDataSource;
    frxEkipmanDetay: TfrxDBDataset;
    ToolBar8: TToolBar;
    BtnBelgelerYeni: TToolButton;
    BtnBelgelerSil: TToolButton;
    PanelPlanlananAlt: TPanel;
    GridFaturaToplam: TStringGrid;
    Label6: TLabel;
    cxDBLabel4: TcxDBLabel;
    PanelUst: TPanel;
    cxDBLabel6: TcxDBLabel;
    PanelSolBilgi: TPanel;
    LabelFatNo: TcxLabel;
    EditServisNo: TcxDBTextEdit;
    LabelKonusu: TcxLabel;
    cxLabel20: TcxLabel;
    EditSERINO: TcxDBTextEdit;
    BEUrunAdi: TcxButtonEdit;
    PageControl1: TcxPageControl;
    SheetTeslim: TcxTabSheet;
    cxLabel14: TcxLabel;
    CBTeslimSekli: TcxDBImageComboBox;
    cxLabel15: TcxLabel;
    BETeslimAlan: TcxButtonEdit;
    BETeslimEden: TcxButtonEdit;
    cxLabel23: TcxLabel;
    EditKargoNo: TcxDBTextEdit;
    DateTESLIMTARIHI: TcxDBDateEdit;
    JvDragDrop1: TJvDragDrop;
    LabelSeriNo: TcxLabel;
    LabelSablon: TcxLabel;
    ComboBolum: TcxDBComboBox;
    DtsDetay: TDataSource;
    TabDetay: TFDQuery;
    SQLDetay: TcxMemo;
    GridProjeDetay: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    ComboSube: TcxDBImageComboBox;
    TabGecmisServisler: TFDQuery;
    DtsGecmisServisler: TDataSource;
    TreeListGecmisServisler: TcxDBTreeList;
    cxLabel7: TcxLabel;
    BEMusIlgili: TcxButtonEdit;
    SheetGenel: TcxTabSheet;
    DtsGenel: TDataSource;
    TabGenel: TFDQuery;
    GenelTreeList: TcxDBTreeList;
    ToolBarGenel: TToolBar;
    GenelSilTus: TToolButton;
    ToolButton21: TToolButton;
    GenelKaydetTus: TToolButton;
    GenelIptalTus: TToolButton;
    ToolButton26: TToolButton;
    ToolButton27: TToolButton;
    ToolButton8: TToolButton;
    TreeListGecmisServislerTARIH: TcxDBTreeListColumn;
    TreeListGecmisServislerDURUM: TcxDBTreeListColumn;
    TreeListGecmisServislerALTID: TcxDBTreeListColumn;
    TreeListGecmisServislerUSTID: TcxDBTreeListColumn;
    EkAlanlarEkr: TcxTabSheet;
    GenelTreeListROOTKOD: TcxDBTreeListColumn;
    GenelTreeListID: TcxDBTreeListColumn;
    GenelTreeListSERVISID: TcxDBTreeListColumn;
    GenelTreeListKOD: TcxDBTreeListColumn;
    GenelTreeListGRUP: TcxDBTreeListColumn;
    GenelTreeListAD: TcxDBTreeListColumn;
    GenelTreeListACIKLAMA: TcxDBTreeListColumn;
    SERVIS: TFDQuery;
    CozumlerTus: TToolButton;
    GenelTreeListCOZUM: TcxDBTreeListColumn;
    TreeListGecmisServislerID: TcxDBTreeListColumn;
    TabGecmisServislerUSTID: TWideStringField;
    TabGecmisServislerALTID: TWideStringField;
    TabGecmisServislerID: TIntegerField;
    TabGecmisServislerTARIH: TWideStringField;
    TabGecmisServislerDURUM: TWideStringField;
    SQLGenelTekTus: TcxMemo;
    SheetOzellik: TcxTabSheet;
    DtsEkipmanEkBilgi: TDataSource;
    TabEkipmanEkBilgi: TFDQuery;
    GridEkEkipman: TcxGrid;
    GridEkEkipmanView: TcxGridDBTableView;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridLevel11: TcxGridLevel;
    TabServisNotlarID: TAutoIncField;
    TabServisNotlarSERVISID: TIntegerField;
    TabServisNotlarEKLEMETARIHI: TSQLTimeStampField;
    TabServisNotlarCOZUM: TWideStringField;
    TabServisNotlarEKLEYEN: TIntegerField;
    TabServisNotlarEKLEYENAD: TStringField;
    TabServisNotlarSERVISTUR: TSmallintField;
    TabServisNotlarACIKLAMA: TWideStringField;
    SQLKullan: TMemo;
    CheckKapali: TcxDBCheckBox;
    lblSevkAdresi: TcxLabel;
    btnSevkAdresi: TcxButtonEdit;
    TabHareketler: TFDQuery;
    DtsHareketler: TDataSource;
    cxLabel1: TcxLabel;
    CBServisTuru: TcxDBImageComboBox;
    LabelLokasyon: TcxLabel;
    BELokasyon: TcxButtonEdit;
    cxDBMemo1: TcxDBMemo;
    cxLabel13: TcxLabel;
    BeditKonusu: TcxDBButtonEdit;
    ComboDURUM: TcxDBImageComboBox;
    cbStokDepo: TcxDBImageComboBox;
    lbDepo: TcxLabel;
    cxGridBelgelerDBTableView1: TcxGridDBTableView;
    cxGridBelgelerLevel1: TcxGridLevel;
    cxGridBelgeler: TcxGrid;
    PopupYeniBelge: TPopupMenu;
    eklif1: TMenuItem;
    Sipari1: TMenuItem;
    rsaliye1: TMenuItem;
    Fatura2: TMenuItem;
    Fi1: TMenuItem;
    AlnanSipari1: TMenuItem;
    VerilenSipari1: TMenuItem;
    Al1: TMenuItem;
    Satrsaliyesi1: TMenuItem;
    AlFaturas1: TMenuItem;
    SatFaturas1: TMenuItem;
    AlFii1: TMenuItem;
    SatFii1: TMenuItem;
    cxGridBelgelerDBTableView1TUR: TcxGridDBColumn;
    cxGridBelgelerDBTableView1TARIH: TcxGridDBColumn;
    cxGridBelgelerDBTableView1BELGENO: TcxGridDBColumn;
    cxGridBelgelerDBTableView1TUTAR: TcxGridDBColumn;
    cxGridBelgelerDBTableView1KUR: TcxGridDBColumn;
    cxGridBelgelerDBTableView1KAYNAK: TcxGridDBColumn;
    cxGridBelgelerDBTableView1HEDEF: TcxGridDBColumn;
    BtnBelgelerDuzenle: TToolButton;
    PopupBelgeDonusum: TPopupMenu;
    SipariOlutur1: TMenuItem;
    rsaliyeOlutur2: TMenuItem;
    FaturaOlutur1: TMenuItem;
    FiOlutur1: TMenuItem;
    VerSipariineDntr1: TMenuItem;
    SatrsaliyesineDntr1: TMenuItem;
    SatFaturasnaDntr1: TMenuItem;
    SatFiineDntr1: TMenuItem;
    BelgeyiA1: TMenuItem;
    N6: TMenuItem;
    KaynakBelgeyiA1: TMenuItem;
    HedefBelgeyiA1: TMenuItem;
    cxGridBelgelerDBTableView1FIRMA: TcxGridDBColumn;
    cxGridBelgelerDBTableView1ACIKLAMA: TcxGridDBColumn;
    PanelKaydet: TPanel;
    JvNavPanelHeader5: TJvNavPanelHeader;
    ToolBar3: TToolBar;
    ToolButton10: TToolButton;
    YaziciYaz: TToolButton;
    ComboGaranti: TcxDBImageComboBox;
    CheckBoxDISSERVIS: TcxDBCheckBox;
    CheckBoxACIL: TcxDBCheckBox;
    cxDBCheckBox1: TcxDBCheckBox;
    cxDBDateEdit1: TcxDBDateEdit;
    Panel2: TPanel;
    btnServis: TcxButton;
    btnDetay: TcxButton;
    cxLabel3: TcxLabel;
    ComboSay: TcxComboBox;
    Label2: TLabel;
    SheetHareketlerAlt: TcxTabSheet;
    LabelProje: TcxLabel;
    BeditProje: TcxButtonEdit;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    PopupYorumuSil: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumDzenle1: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DkmanSil1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    cxSplitter2: TcxSplitter;
    PanelYorumMedya: TPanel;
    ToolBarYorum: TToolBar;
    YorumEkleTus: TToolButton;
    YorumSil: TToolButton;
    YorumDuzenle: TToolButton;
    Panel4: TPanel;
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
    PanelHrkt: TPanel;
    GridHareketler: TcxGrid;
    GridHareketlerDBTableView1: TcxGridDBTableView;
    GridHareketlerDBTableView1DURUM: TcxGridDBColumn;
    GridHareketlerDBTableView1PERSONEL: TcxGridDBColumn;
    GridHareketlerDBTableView1BASLAMA: TcxGridDBColumn;
    GridHareketlerDBTableView1BITIS: TcxGridDBColumn;
    GridHareketlerDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridHareketlerDBTableView1UYARITURU: TcxGridDBColumn;
    GridHareketlerDBTableView1DISUYARITURU: TcxGridDBColumn;
    GridHareketlerDBTableView1SURE: TcxGridDBColumn;
    GridHareketlerLevel1: TcxGridLevel;
    ToolBarHareketler: TToolBar;
    BtnHareketlerYeni: TToolButton;
    BtnHareketlerSil: TToolButton;
    ToolButton6: TToolButton;
    BtnHareketlerKaydet: TToolButton;
    BtnHareketlerIptal: TToolButton;
    BtnHareketlerDuzenle: TToolButton;
    ToolButton3: TToolButton;
    cxSplitterHareket: TcxSplitter;
    lblMusteriTel: TcxLabel;
    lblMusteriEposta: TcxLabel;
    procedure TabServisBeforePost(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure TabServisNewRecord(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure YeniSatirTusClick(Sender: TObject);
    procedure TamEkranTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure ComboKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ServisPlanEkleTusClick(Sender: TObject);
    procedure TabServisBelgeNewRecord(DataSet: TDataSet);
    procedure ComboTeslimEdenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function EkranAdiAl: string;
    procedure LabelAdClick(Sender: TObject);
    procedure TabServisAfterPost(DataSet: TDataSet);
    procedure TabServisBeforeEdit(DataSet: TDataSet);
    procedure KaydetTusClick(Sender: TObject);
    procedure DtsServisNotlarStateChange(Sender: TObject);
    function ServisBoslukKontrolu: Boolean;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure Kaydet;
    procedure FirmaBilgileri;
    function  AktifPageIndexGetir(Deger:integer): integer;
    procedure BelgeDoldur(Table1:TFDQuery;Belge:TStringList;Page:integer);
    procedure BtnEkipmanDetayKaydetClick(Sender: TObject);
    procedure BtnEkipmanDetayIptalClick(Sender: TObject);
    procedure btnEkipmanDetaySilClick(Sender: TObject);
    procedure BtnEkipmanDetayYeniClick(Sender: TObject);
    procedure TabEkipmanDetayBeforeEdit(DataSet: TDataSet);
    procedure TabEkipmanDetayBeforeDelete(DataSet: TDataSet);
    procedure ServisPageControlChange(Sender: TObject);
    procedure cxDBButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabServisProblemNewRecord(DataSet: TDataSet);
    procedure gridProblemDBTableViewProblemCanFocusRecord( Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabServisPlanPersonelNewRecord(DataSet: TDataSet);
    procedure BEBildirimYapanPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure CBTeslimSekliPropertiesCloseUp(Sender: TObject);
    procedure LabelKonusuClick(Sender: TObject);
    procedure ServisEkrLastButtonClick(Sender: TObject; var Stop: Boolean);
    procedure ServisEkrFinishButtonClick(Sender: TObject; var Stop: Boolean);
    procedure cxLabel35Click(Sender: TObject);
    procedure DetayEkrPage(Sender: TObject);
    procedure DetayEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure LabelSablonClick(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
    procedure DateBITISTARIHIKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure dateBASLAMATARIHIKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxDBDateEdit5KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DateTESLIMTARIHIKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EkleProblemTusClick(Sender: TObject);
    procedure GenelSilTusClick(Sender: TObject);
    procedure TabGenelAfterOpen(DataSet: TDataSet);
    //function Postala(Tip, SablonId:integer):string;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GenelTreeListACIKLAMAPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditFATURANOPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabServisUygulamaAfterDelete(DataSet: TDataSet);
    procedure TabServisUygulamaAfterPost(DataSet: TDataSet);
    procedure CozumlerTusClick(Sender: TObject);
    procedure GenelTreeListCOZUMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure DtsGenelStateChange(Sender: TObject);
    procedure TreeListGecmisServislerClick(Sender: TObject);
    procedure cxGridNotlarViewCOZUMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabServisNotlarCalcFields(DataSet: TDataSet);
    procedure GridEkEkipmanViewDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TabServisAfterOpen(DataSet: TDataSet);
    procedure btnSevkAdresiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure IletisimEkleClick(Sender: TObject);
    procedure DtsHareketlerStateChange(Sender: TObject);
    procedure BtnHareketlerIptalClick(Sender: TObject);
    procedure BtnHareketlerKaydetClick(Sender: TObject);
    procedure GridHareketlerDBTableView1DblClick(Sender: TObject);
    procedure BtnHareketlerYeniClick(Sender: TObject);
    procedure HareketSekmesiYeriAyarla(Durum:smallint);
    procedure BtnHareketlerSilClick(Sender: TObject);
    procedure TabHareketlerAfterPost(DataSet: TDataSet);
    procedure TabHareketlerAfterScroll(DataSet: TDataSet);
    procedure TabHareketlerAfterOpen(DataSet: TDataSet);
    procedure BeditKonusuPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BtnBelgelerSilClick(Sender: TObject);
    Procedure GenelButtonCreate;
    procedure eklif1Click(Sender: TObject);
    procedure BtnBelgelerDuzenleClick(Sender: TObject);
    procedure cxGridBelgelerDBTableView1DblClick(Sender: TObject);
    procedure SipariOlutur1Click(Sender: TObject);
    procedure TabServisBelgeAfterScroll(DataSet: TDataSet);
    procedure KaynakBelgeyiA1Click(Sender: TObject);
    procedure HedefBelgeyiA1Click(Sender: TObject);
    procedure BeditProjeDblClick(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GenelTreeListBeginDragNode(Sender: TcxCustomTreeList;
      ANode: TcxTreeListNode; var Allow: Boolean);
    procedure GenelTreeListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure YorumEkleTusClick(Sender: TObject);
    procedure YorumSilClick(Sender: TObject);
    procedure TabYorumAfterScroll(DataSet: TDataSet);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure CheckKapaliClick(Sender: TObject);
    procedure btnDetayClick(Sender: TObject);
    procedure btnServisClick(Sender: TObject);
    procedure GridYorumDBCardView1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    AraDlg:TStokHizmetAraDlg;
    KodAgaciLokasyonDlg:TKodAgaciDlg;
    sonbasilanctrl:TcxButtonEdit;
    StateInsert:Boolean;
    SonrakiHareketiEkle:Boolean;
    procedure TabloAc;
    procedure ServisNotlaraEkle(Qry: TFDQuery; Tur: Integer);
    procedure FaturaTutarHesapla;
    procedure BoslukKontrolleri;
    procedure AsamaEkle(AsamaId : smallint);
    function ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;

    //procedure TabloKaydet;
  public
    { Public declarations }
    IslemOp : Char;
    ServisID, RehberId : Integer;
    Cagiran:  SmallInt;
    SerKapsam : Boolean;
  end;

var
  ServisWizardDlg : TServisWizardDlg;
  OncekiKdvDurumu : string;
  DYetkisonuc:DokumanYetkiSonuc;
  EkleDetay,MailGonderilecek :boolean;
  OncekiSorumlu, ProjeFirsatSec : integer;

implementation

Uses UAnaForm,UCombo, UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra,URaporAraclari, UTabloGiris,
  UFastRap, USecForm, UGirisKutusuEx,FetaClassExtensions, UServisDetayPersonel, UGenelAnaSekmeFrame,
  UServisEkipmanSec, Fetautil, IdGlobalProtocols, UCariFonksiyonlar, URehberAyar,LocOnFly, USonlandir,
  UServisListeDlg, UGorevDlg;

{$R *.dfm}
var
     aktifFrame : TGenelAnaSekmeFrame;
     AraDlg : TStokHizmetAraDlg;
     IptalSecildi, Degistirildi,DegistirildiSms,TureGoreDurumVar:Boolean;


procedure TServisWizardDlg.EkleProblemTusClick(Sender: TObject);
begin
  if TabServis.State in[dsEdit,dsInsert] then
     TabServis.Post;
  Tablo.ServisBilgiyeEkle(TabGenel, ServisID, TToolButton(Sender).Tag, False);
  TabloYenile(TabGenel,[ServisID]);
end;

Procedure TServisWizardDlg.GenelButtonCreate;
var
  I: Integer;
begin
  for I := ToolBarGenel.ButtonCount-1 downto 0 do
     if ToolBarGenel.Buttons[I].Tag > 0 then
       ToolBarGenel.Buttons[I].Destroy;
  Tablo.TablodanSorguAc(9,'select * from GENINI where BOLUM='+IntToStr(Ops_Servis_Genel_Icerik)+' and DIL='+IntToStr(Dil)+' order by SIRA desc ');
  Tablo.Query9.First;
  while not Tablo.Query9.Eof do begin
    With TToolButton.Create(ToolBarGenel) do begin
      Caption := Tablo.Query9.FieldByName('ANAHTAR').AsString;
      Tag := Tablo.Query9.FieldByName('DEGER').AsInteger;
      ImageIndex := 0;
      OnClick := EkleProblemTusClick;
      Parent := ToolBarGenel;
      Left := 0;
    end;
    Tablo.Query9.Next;
  end;
end;

procedure TServisWizardDlg.eklif1Click(Sender: TObject);
var
  Tur,ID:integer;
begin
  Tur := TMenuItem(Sender).Tag;
  case Tur of
    9,19: ID := Tablo.SiparisSihirbazBaslat('E', Tur,0, -1, TabServis.FieldByName('REHBERID').AsInteger,-1,ServisID);
    10,11,12,14,15,16 : ID := Tablo.FaturaSihirbazBaslat('E', Tur,-1, -1,TabServis.FieldByName('REHBERID').AsInteger, 1,false,-1,ServisID);
    80: ID := Tablo.TeklifSihirbazBaslat('E', 80 ,-1, -1, TabServis.FieldByName('REHBERID').AsInteger, 0,-1,ServisID);
  end;
  if ID>0 then
    TabloYenile(TabServisBelge,[ServisID]);
end;

function TServisWizardDlg.EkranAdiAl: string;
begin
  if ServisPageControl.ActivePage <> nil then

   Result := 'Servis-'+copy(ServisPageControl.ActivePage.Name,6,100);
end;

procedure TServisWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   TabloYenile(SERVIS, [TabServis.Fields[0].AsInteger]);
   TabloYenile(TabEkipmanDetay, [TabServis.Fields[0].AsInteger]);
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxServis);
   AFastReport.EnabledDataSets.Add(frxEkipmanDetay);
   AFastReport.EnabledDataSets.Add(frxServisGenel);
   AFastReport.EnabledDataSets.Add(frxServisBelge);
   AFastReport.EnabledDataSets.Add(frxServisNotlar);
   Tablo.TabMusteri.Close;
   Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
   Tablo.TabMusteri.Open;
   AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
end;

procedure TServisWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TServisWizardDlg.dateBASLAMATARIHIKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if Key = VK_BACK then
       Key := VK_DELETE;
end;

procedure TServisWizardDlg.DateBITISTARIHIKeyDown(Sender: TObject;var Key: Word; Shift: TShiftState);
begin
    if Key = VK_BACK then
       Key := VK_DELETE;
end;

procedure TServisWizardDlg.DateTESLIMTARIHIKeyDown(Sender: TObject;var Key: Word; Shift: TShiftState);
begin
    if Key = VK_BACK then
       Key := VK_DELETE;
end;

procedure TServisWizardDlg.DetayEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   if EkleDetay then
      Ekle(TabDetay,TabNo_SERVIS, ServisID, 'De?i?');
end;

procedure TServisWizardDlg.DetayEkrPage(Sender: TObject);
var Yeri : SmallInt;
begin
    TabDetay.Close;
    TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    TabloYenile(TabDetay, [TabNo_SERVIS,ServisID,ComboBolum.Text])
end;

procedure TServisWizardDlg.BtnBelgelerDuzenleClick(Sender: TObject);
begin
  if not TabServisBelge.IsEmpty then begin
    case TabServisBelge.FieldByName('TUR').AsInteger of
      80:Tablo.TeklifSihirbazBaslat('D', 80 ,-1, TabServisBelge.FieldByName('ID').AsInteger, TabServis.FieldByName('REHBERID').AsInteger, 0,-1,ServisID);
      9,19:Tablo.SiparisSihirbazBaslat('D', TabServisBelge.FieldByName('TUR').AsInteger,0,TabServisBelge.FieldByName('ID').AsInteger, TabServis.FieldByName('REHBERID').AsInteger,-1,ServisID);
      10,11,12,14,15,16:Tablo.FaturaSihirbazBaslat('D', TabServisBelge.FieldByName('TUR').AsInteger,-1,TabServisBelge.FieldByName('ID').AsInteger,TabServis.FieldByName('REHBERID').AsInteger, 1,false,-1,ServisID);
    end;
    TabloYenile(TabServisBelge,[ServisID]);
  end;
end;

procedure TServisWizardDlg.BtnBelgelerSilClick(Sender: TObject);
begin
  if (not TabServisBelge.IsEmpty)and(Application.MessageBox(PChar(SSilmeSorusu),PChar(SGenotipOnay), MB_YESNO) = IDYES) then begin
    case TabServisBelge.FieldByName('TUR').AsInteger of
      80:Tablo.TeklifSil(TabServisBelge.FieldByName('ID').AsInteger);
      9,19:Tablo.SiparisSil(TabServisBelge.FieldByName('ID').AsInteger);
      10,11,12,14,15,16:Tablo.FaturaSil(nil,nil,TabServisBelge.FieldByName('ID').AsInteger);
    end;
    TabloYenile(TabServisBelge,[ServisID]);
  end;
end;

procedure TServisWizardDlg.btnDetayClick(Sender: TObject);
begin
  WizardKontrol.ActivePageIndex := 1;
end;

procedure TServisWizardDlg.BtnEkipmanDetayIptalClick(Sender: TObject);
begin
   if (Sender as TToolButton) = GenelIptalTus then
       TabGenel.Cancel;
end;

procedure TServisWizardDlg.BtnEkipmanDetayKaydetClick(Sender: TObject);
begin
   if (Sender as TToolButton) = GenelKaydetTus then
       TabGenel.Post;
end;

procedure TServisWizardDlg.ComboBolumPropertiesEditValueChanged(Sender: TObject);
var i:Integer;
begin
  if (TabDetay.Active)  then begin
    if TabDetay.State=dsEdit then
      TabDetay.Post;
    i:=0;
    if not TabDetay.IsEmpty then begin
      TabDetay.First;
      while not TabDetay.Eof do begin
        if TabDetay.FieldByName('BILGI').AsString <>'' then
          Inc(i);
        TabDetay.Next;
      end;
    end;
    if (i>0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrNo) then begin
      TabServis.Cancel
    end else begin
      TabServis.Post;
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_SERVIS,ServisID]);
      DetayEkrPage(Self);
    end;
  end;
end;

procedure TServisWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
begin
  if ComboBolum.Properties.Items.Count=0 then
     ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(TabNo_SERVIS)).Items;
end;

procedure TServisWizardDlg.ComboKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then begin
      TabServis.Edit;
      TabServis.FieldByName('KABULEDEN').AsInteger:= ID;
      //ComboKabuleden.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
   end;
end;

procedure TServisWizardDlg.SipariOlutur1Click(Sender: TObject);
var
belgetipi, donustipi, yeniid: integer;
begin
  belgetipi:= (Sender as TMenuItem).Tag;
  donustipi:= Tablo.BelgeDonustur_DonusTipiBul(TabServisBelge.FieldByName('TUR').AsInteger,belgetipi);

  if belgetipi in [9,19] then begin
    yeniid := Tablo.TeklifiSipariseDonustur(donustipi,TabServisBelge.FieldByName('ID').AsInteger);
    Tablo.SiparisSihirbazBaslat('D',belgetipi,9,yeniid,TabServis.FieldByName('REHBERID').AsInteger,-1,ServisID);
  end else begin
    yeniid := Tablo.BelgeDonustur(donustipi,TabServisBelge.FieldByName('ID').AsInteger);
    Tablo.FaturaSihirbazBaslat('E',belgetipi, 0,yeniid, TabServis.FieldByName('REHBERID').AsInteger, 1,False,-1,ServisID);
  end;
  TabloYenile(TabServisBelge,[ServisID]);
end;

procedure TServisWizardDlg.GenelSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
//     if islemOp='D' then
//        Tablo.LogIslemleri(DatasetinTabNosunuBul(TabServisUygulama),(TabServisUygulama.FieldByName('ID').AsInteger),5,TabServisUygulama);
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from SERVISBILGI where ID=&id ',['&id'],[TabGenel.FieldByName('ID').AsInteger]);
     TabloYenile(TabGenel,[ServisID])
  end;
end;

procedure TServisWizardDlg.ComboTeslimEdenPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then begin
      TabServis.Edit;
      TabServis.FieldByName('TESLIMEDEN').AsInteger:= ID;
      //ComboTeslimeden.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
   end;
end;

procedure TServisWizardDlg.CozumlerTusClick(Sender: TObject);
var
 RehID:integer;
 Firma,SQL:String;
 st :Tstringlist;
 Key: Word;
begin
  if TabGenel.FieldbyName('SERVISLISTEID').AsString='' then
     exit;

  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  TabloGirisDlg.EkranYazdirAdi := 'GecmisCozumlerDlg';
  TabloGirisDlg.Caption := 'Ge?mi? ??z?mler';
  TabloGirisDlg.Komut := 'select E.AD,SB.COZUM, SB.ID, SB.EKLEMETARIHI,EKLEYEN=R.FIRMA from SERVISBILGI SB '+
         ' inner join SERVIS S on S.ID=SB.SERVISID inner join EKIPMANLAR E on S.EKIPMANID=E.ID inner join REHBER R on R.ID=SB.EKLEYEN  '+
         ' where SB.ID<>'+TabGenel.FieldbyName('ID').AsString+' and SERVISTUR=210 and SB.SERVISLISTEID='+TabGenel.FieldbyName('SERVISLISTEID').AsString+' ORDER BY 3 DESC ';
  Key := 0;
  TabloGirisDlg.Edit1KeyUp(Self, Key, [ssShift]);
  TabloGirisDlg.GridGirisTV.GetColumnByFieldName('AD').Width := 200;
  TabloGirisDlg.GridGirisTV.GetColumnByFieldName('COZUM').Width := 400;

  TabloGirisDlg.GridGirisTV.OptionsView.CellAutoHeight := True;

  TabloGirisDlg.ShowModal;
  if (TabloGirisDlg.ModalResult=mrOK)and(Trim(TabGenel.FieldByName('COZUM').AsString)='') then begin
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' update SERVISBILGI set COZUM=&czm where ID=&id ',['&czm','&id'],
        [ TabloGirisDlg.Query1.fields[1].AsString , TabGenel.FieldByName('ID').AsInteger]);
     TabloYenile(TabGenel,[ServisID]);
  end;
  TabloGirisDlg.Destroy;

end;

procedure TServisWizardDlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
begin
  if AButtonIndex = 0 then begin
     LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Genel);
     if LokID>0 then begin
        BELokasyon.Tag:=LokID;
        BELokasyon.Text:=Tablo.AciklamaGetir('LOKASYON', 'ACIKLAMA', LokID);
        TabServis.Edit;
        TabServis.FieldByName('LOKASYONID').Value:=LokID;
     end;
  end else begin
      if not (DtsServis.State in [dsEdit,dsInsert]) then
      TabServis.Edit;
      TabServis.FieldByName('LOKASYONID').Value:=0;
      BELokasyon.Text:='';
      BELokasyon.Tag:=0;
  end;
end;

procedure TServisWizardDlg.cxDBButtonEdit1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  Sonuclar:TStringList;
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TServisEkipmanSecDlg,ServisEkipmanSecDlg);
    ServisEkipmanSecDlg.SerKapsam := SerKapsam;
    ServisEkipmanSecDlg.RehberID := RehberId;
    ServisEkipmanSecDlg.ShowModal;
    if ServisEkipmanSecDlg.ModalResult=mrOk then begin
      if TabServis.State=dsBrowse then
        TabServis.Edit;
      if ServisEkipmanSecDlg.cxPageControl1.ActivePageIndex = ServisEkipmanSecDlg.SheetRehberEkipman.PageIndex then
      TabServis.FieldByName('EKIPMANREHBERID').AsInteger:= ServisEkipmanSecDlg.TabListe.FieldByName('EKIPMANREHBERID').AsInteger;
      TabServis.FieldByName('EKIPMANID').AsInteger:= ServisEkipmanSecDlg.TabListe.FieldByName('ID').AsInteger;
      BEUrunAdi.Text:= ServisEkipmanSecDlg.TabListe.FieldByName('AD').AsString;
      TabServis.FieldByName('SERINO').Value := ServisEkipmanSecDlg.TabListe.FieldByName('SERINO').AsString;
      if (ServisEkipmanSecDlg.TabListe.FieldByName('GARANTIBITTAR').AsString<>'')and
         (ServisEkipmanSecDlg.TabListe.FieldByName('GARANTIBITTAR').AsDateTime>=Tablo.GENINI.BugunTrh) then
         TabServis.FieldByName('KAPSAM').Value:=1
      else
         TabServis.FieldByName('KAPSAM').Value:=0;
    end;
    FreeAndNil(ServisEkipmanSecDlg);
  end else if AButtonIndex = 1 then begin
    if TabServis.State=dsBrowse then
      TabServis.Edit;
    TabServis.FieldByName('EKIPMANREHBERID').AsInteger:= 0;
    TabServis.FieldByName('EKIPMANID').AsInteger:= 0;
    BEUrunAdi.Text:= '';
    TabServis.FieldByName('SERINO').Value := '';
  end;
  SheetOzellik.TabVisible :=  TabServis.Fieldbyname('EKIPMANREHBERID').AsInteger<>0;
end;

procedure TServisWizardDlg.cxDBDateEdit5KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_BACK then
     Key := VK_DELETE;
end;

procedure TServisWizardDlg.cxGridBelgelerDBTableView1DblClick(Sender: TObject);
begin
  if Tablo.YetkiVarmi(30061030,YetkiTur_Gorme) then
    BtnBelgelerDuzenleClick(Sender);
end;

procedure TServisWizardDlg.cxGridNotlarViewCOZUMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
  Bilgi := vartostr( (Sender as TcxButtonEdit).EditingValue );
   if TGirisKutusuEx.BilgiAlEx('Notlar' , TGirdiDenetimleri.Create.Memo('Notlar' , @Bilgi)) = mrOk then begin
     TabServisNotlar.Edit;
     TabServisNotlar.FieldByName('COZUM').AsString := VarToStr(Bilgi);
   end;
end;

procedure TServisWizardDlg.cxLabel35Click(Sender: TObject);
begin
  Tablo.LabelClickCombobox(Sender);
end;

procedure TServisWizardDlg.gridProblemDBTableViewProblemCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:= (Sender.Control as TcxGrid);
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:= (sender as TcxCustomGridTableView);
  if (sender as TcxGridDBTableView)=cxGridBelgelerDBTableView1 then
    AnaForm.pmGridStil.Tags.Values[(Sender.Control as TcxGrid).Name] := 'ServisBelge';
end;

procedure TServisWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
  TabHareketlerAfterScroll( TabHareketler);
end;

procedure TServisWizardDlg.GridYorumDBCardView1KeyUp(Sender: TObject;  var Key: Word; Shift: TShiftState);
var Tarih : Variant;
begin
  //

  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('T')) then  begin   //Yeni Bile?en Ekle
       //Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabNo_SERVISHAREKET);
    Tarih := TabYorum.FieldByName('EKLEMETARIHI').AsDateTime;
    //if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.DateTimePicker(BGTeslim_Tarihi, @Tarih, dtkDate)) <> mrOk then
    if TGirisKutusuEx.BilgiAlEx('Tarih', TGirdiDenetimleri.Create.DateTimePicker('Tarih:', @Tarih, dtkDate)) = mrOk then begin
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE GOREVYORUM SET EKLEMETARIHI='''+Formatdatetime('yyyy-mm-dd hh:nn', Tarih)+''' WHERE ID='+TabYorum.Fields[0].AsString, [], []);
         //Tabloyenile(TabYorum,[TabloNo, RehId]);

       TabHareketlerAfterScroll( TabHareketler);
    end;
  end;
end;

procedure TServisWizardDlg.HedefBelgeyiA1Click(Sender: TObject);
var
  sts:TStringlist;
  AYeri,AYerID:Integer;
  ABelgeno:string;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := '';
  case TabServisBelge.FieldByName('TUR').AsInteger of
    9,19:begin
      Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.FATURANO,FB.ID ');
      Tablo.Query1.SQL.Add(' from SIPARISDETAY SD ');
      Tablo.Query1.SQL.Add(' 	inner join FATURA F2 on SD.ID=F2.YERID and F2.YERI in (406,407,409,410,415,420) ');
      Tablo.Query1.SQL.Add(' 	inner join FATBASLIK FB on F2.FATBASID=FB.ID ');
      Tablo.Query1.SQL.Add(' where SD.SIPARISID='+TabServisBelge.FieldByName('ID').AsString);
    end;
  else
    Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.FATURANO,FB.ID ');
    Tablo.Query1.SQL.Add(' from FATURA F ');
    Tablo.Query1.SQL.Add(' 	inner join FATURA F2 on F.ID=F2.YERID and F2.YERI in (408,411,461,462) ');
    Tablo.Query1.SQL.Add(' 	inner join FATBASLIK FB on F2.FATBASID=FB.ID ');
    Tablo.Query1.SQL.Add(' where F.FATBASID='+TabServisBelge.FieldByName('ID').AsString);
  end;
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
      if Tablo.ListedenBilgiGetir('Hedef Se?imi',Tablo.Query1.SQL.Text,sts,[Tablo.RepKasaTurleriReadOnly,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],'FaturalarHedefSecimi')then begin
        AYeri := StrToInt(sts[0]);
        AYerID:= StrToInt(sts[2]);
        ABelgeno:= sts[1];
      end;
    finally
      sts.Free;
    end;
  end;
  AnaForm.GormeDialogCagir(AYerID,AYeri,TabServis.FieldByName('REHBERID').AsInteger,0,Tablo.GENINI.BugunTrh,ABelgeno);
  TabloYenile(TabServisBelge,[ServisID]);
end;

procedure TServisWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TServisWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TServisWizardDlg.PageControl1Change(Sender: TObject);
var
 i:integer;
 component: TComponent;
begin
 if PageControl1.ActivePage = EkAlanlarEkr then begin
   for i := 0 to TWinControl(EkAlanlarEkr).ControlCount-1 do
     if (FindComponent(TWinControl(EkAlanlarEkr).Controls[i].Name).ClassType <> TcxLabel) and (FindComponent(TWinControl(EkAlanlarEkr).Controls[i].Name).ClassType <> TcxDBLabel) then
       TcxControl(TWinControl(EkAlanlarEkr).Controls[i]).SetFocus;
 end;
end;

procedure TServisWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TServisWizardDlg.btnEkipmanDetaySilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDNO then
     Abort
end;

procedure TServisWizardDlg.BtnEkipmanDetayYeniClick(Sender: TObject);
begin
  if TabServis.State in[dsEdit,dsInsert] then
    TabServis.Post;
end;

procedure TServisWizardDlg.BtnHareketlerIptalClick(Sender: TObject);
begin
  TabHareketler.Cancel;
end;

procedure TServisWizardDlg.BtnHareketlerKaydetClick(Sender: TObject);
begin
  TabHareketler.Post;
end;

procedure TServisWizardDlg.BtnHareketlerSilClick(Sender: TObject);
begin
  TabHareketler.FetchAll;
  if TabHareketler.RecNo = TabHareketler.RecordCount then
     if not TabYorum.IsEmpty then begin
        showmessage(RDYorumMedyaVarSilinemez);
        exit;
     end;

    if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      TabHareketler.Delete;
      TabloYenile(TabHareketler,[ServisID]);
      TabHareketler.Last;
      if tabServis.FieldByName('DURUM').AsInteger <> TabHareketler.FieldByName('DURUM').AsInteger then begin
        tabServis.Edit;
        tabServis.FieldByName('DURUM').AsInteger := TabHareketler.FieldByName('DURUM').AsInteger;
        TabServis.FieldByName('ACKAPA').AsBoolean := False;
        tabServis.Post;
      end;
    end;
end;

procedure TServisWizardDlg.HareketSekmesiYeriAyarla(Durum:smallint);
begin
(*
  SheetHareketlerUst.TabVisible := Durum=1;
  SheetHareketlerUst.Visible := Durum=1;
  SheetHareketlerAlt.TabVisible := Durum=2;
  SheetHareketlerAlt.Visible := Durum=2;
  case Durum of
    1: begin
        GridHareketler.Parent := SheetHareketlerUst;
        ToolBarHareketler.Parent := SheetHareketlerUst;
        SheetHareketlerUst.TabVisible := Tablo.YetkiVarmi(300620,YetkiTur_Gorme);
        SheetHareketlerUst.Visible := Tablo.YetkiVarmi(300620,YetkiTur_Gorme);
    end;
    2: begin
        GridHareketler.Parent := SheetHareketlerAlt;
        ToolBarHareketler.Parent := SheetHareketlerAlt;
        SheetHareketlerAlt.TabVisible := Tablo.YetkiVarmi(300620,YetkiTur_Gorme);
        SheetHareketlerAlt.Visible := Tablo.YetkiVarmi(300620,YetkiTur_Gorme);
    end;
  end;
  if SheetHareketlerUst.TabVisible then
    PageControl1.ActivePage := SheetHareketlerUst;
       *)
end;

procedure TServisWizardDlg.BtnHareketlerYeniClick(Sender: TObject);
var
  OncekiHareketID,OncekiHareketDurumu:integer;
  TurBilgisi:string;
begin
  SonrakiHareketiEkle := False;
  if TabHareketler.Active then begin
    TabHareketler.Last;

  if TureGoreDurumVar then
     TurBilgisi:=' and TUR='+IntToStr(CBServisTuru.EditingValue) //e?er opsiyonda servis t?r?ne g?re durumlar gelsin se?iliyse
  else
     TurBilgisi:='';


    Application.CreateForm(TServisSonlandirDlg,ServisSonlandirDlg);
    ServisSonlandirDlg.comboDurum.Properties.Items := Tablo.ComboDurumDoldur(ServisID,0,TurBilgisi);
    if ServisSonlandirDlg.comboDurum.Properties.Items.Count=0 then begin
       //ShowMessage(Servis_Har_Baslangic);
       FreeAndNil(ServisSonlandirDlg);
       exit;
    end;
    ServisSonlandirDlg.ServisID := ServisID;
    ServisSonlandirDlg.YeniHareket := True;
    ServisSonlandirDlg.CheckBaslama.Checked := True;
    ServisSonlandirDlg.CheckBitis.Checked := False;
    ServisSonlandirDlg.CheckWhatsapp.Checked := False;
    //ServisSonlandirDlg.CheckBaslama.Visible := False;
    //ServisSonlandirDlg.CheckBitis.Visible := False;
    //ServisSonlandirDlg.CheckAciklama.Visible := False;
    ServisSonlandirDlg.DateBaslama.Date := Tablo.GENINI.BugunTrh;
    ServisSonlandirDlg.TimeBaslama.Time := Tablo.GENINI.BugunTrhSaat;
    //ServisSonlandirDlg.DateBitis.Date := ServisSonlandirDlg.DateBaslama.Date;
    //ServisSonlandirDlg.TimeBitis.Time := ServisSonlandirDlg.TimeBaslama.Time;
    ServisSonlandirDlg.EditPersonel.Tag := StrToInt(kullanan);
    ServisSonlandirDlg.EditPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',StrToInt(kullanan));
    ServisSonlandirDlg.ShowModal;
    if ServisSonlandirDlg.ModalResult = mrOk then begin
      TabHareketler.Last;
      OncekiHareketID:=TabHareketler.FieldByName('ID').AsInteger;
      OncekiHareketDurumu:=TabHareketler.FieldByName('DURUM').AsInteger;
      TabHareketler.Append;
      MailGonderilecek := True;
      Tablo.TablodanSorguAc(4,'select * from ALANLAR where EKRANADI=''ServisSonlandirDlg'' and TUR not in (11,12)');
      Tablo.Query4.First;
      while not Tablo.Query4.Eof do begin
        if ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString) <> nil then
          case Tablo.Query4.FieldByName('TUR').AsInteger of
            1 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString := TcxTextEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text;
            3 :if TcxDateEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text <> '' then
                  TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsDateTime := TcxDateEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Date;
            4 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString := TcxComboBox(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text;
            5 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsBoolean := TcxCheckBox(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Checked;
            7 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString := TcxButtonEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text;
          end;
        Tablo.Query4.Next;
      end;
      TabHareketler.FieldByName('SERVISID').AsInteger := ServisID;
      TabHareketler.FieldByName('ACIKLAMA').AsString := ServisSonlandirDlg.Memociklama.Lines.Text;
      TabHareketler.FieldByName('BITISSEC').AsBoolean := ServisSonlandirDlg.CheckBitis.Checked;
      if ServisSonlandirDlg.CheckBitis.Checked then
         TabHareketler.FieldByName('BITIS').AsDateTime := ServisSonlandirDlg.DateBitis.Date+ServisSonlandirDlg.TimeBitis.Time
      else
         TabHareketler.FieldByName('BITIS').value := Null;
      TabHareketler.FieldByName('BASLASEC').AsBoolean := ServisSonlandirDlg.CheckBaslama.Checked;
      if ServisSonlandirDlg.CheckBaslama.Checked then
         TabHareketler.FieldByName('BASLAMA').AsDateTime := ServisSonlandirDlg.DateBaslama.Date+ServisSonlandirDlg.TimeBaslama.Time
      else
         TabHareketler.FieldByName('BASLAMA').value := Null;
      TabHareketler.FieldByName('DURUM').AsInteger := ServisSonlandirDlg.comboDurum.EditValue;
      TabHareketler.FieldByName('PERSONEL').AsInteger := ServisSonlandirDlg.EditPersonel.Tag;
      TabHareketler.FieldByName('UYARITURU').AsInteger := ServisSonlandirDlg.UyariTuru;//ServisSonlandirDlg.comboUyariTuru.EditValue;
      TabHareketler.FieldByName('DISUYARITURU').AsInteger := ServisSonlandirDlg.DisUyariTuru;//ServisSonlandirDlg.comboDisUyariTuru.EditValue;
      TabHareketler.FieldByName('EKLEYEN').AsString := kullanan;
      TabHareketler.FieldByName('KAPANIS').Value := (ServisSonlandirDlg.comboDurum.Properties.Items[ServisSonlandirDlg.comboDurum.ItemIndex] as TcxImageComboBoxItem).Tag;
      TabHareketler.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
      if TabHareketler.FieldByName('KAPANIS').Value = True then begin
        TabHareketler.FieldByName('BASLAMA').AsDateTime := Tablo.GENINI.BugunTrhSaat;
        TabHareketler.FieldByName('BITIS').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      end;
      if (TabHareketler.FieldByName('BITIS').Value <> Null)and(TabHareketler.FieldByName('KAPANIS').Value = False) then begin
        SonrakiHareketiEkle := True;
      end;
      TabHareketler.Post;
      Tablo.TablodanSorguAc(8,'select * from DURUMBAGLANTI where YERI=83 '+TurBilgisi+' and KAYNAKDURUM='+IntToStr(OncekiHareketDurumu)+' and HEDEFDURUM='+TabHareketler.FieldByName('DURUM').AsString);
      if (Tablo.Query8.FieldByName('HEDEFALANADI').AsString <> '') and (Tablo.Query8.FieldByName('HEDEFALANDEGERI').AsString <> '') then begin
        TabServis.Edit;
        TabServis.FieldByName(Tablo.Query8.FieldByName('HEDEFALANADI').AsString).AsString := Tablo.Query8.FieldByName('HEDEFALANDEGERI').AsString;
        TabServis.Post;
      end;
      if Tablo.Query8.FieldByName('OTOKAPAT').AsBoolean then begin
        if TabHareketler.Locate('ID',OncekiHareketID,[]) then begin
          TabHareketler.Edit;
          if TabHareketler.FieldByName('BASLAMA').Value = Null then
            TabHareketler.FieldByName('BASLAMA').AsDateTime := Tablo.GENINI.BugunTrhSaat;
          if TabHareketler.FieldByName('BITIS').Value = Null then
            TabHareketler.FieldByName('BITIS').AsDateTime := Tablo.GENINI.BugunTrhSaat;
          TabHareketler.Post;
        end;
        TabHareketler.Last;
      end;
    end;
    FreeAndNil(ServisSonlandirDlg);
  end;
  if SonrakiHareketiEkle then
    BtnHareketlerYeniClick(Self);
end;

procedure TServisWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger, TabServis.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TServisWizardDlg.IletisimEkleClick(Sender: TObject);
var
  AD,ADRES,ILCE,IL :Variant;
  ctrls:TGirdiDenetimleri;
  Liste:TStrings;
begin
  liste:=nil;
  liste:=TStringList.Create;
  Tablo.TablodanSorguAc(1,'select ILADI from ILLER  where ILNO<100  order by 1 ');
  while not Tablo.Query1.Eof do begin
    Liste.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Next;
  end;
  IL:=Liste.Strings[0];
  ctrls:=TGirdiDenetimleri.Create.Edit('Ad',@AD).Memo('Adres',@ADRES).Edit('?l?e',@ILCE).ComboBox(('?l'),@IL,liste);
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls)<> mrOK  then
  Abort;
   //eklenen yeni ileti?im ID sini al?yoruz.
  Tablo.TablodanSorguAc(1,'INSERT INTO REHBERILETISIM (REHBERID,AD,VARSAYILAN ,AKTIF,SUBEID) values('+IntToStr(RehberId)+','''+AD+''',0,1,'+IntToStr(SubeId)+' )  Select SCOPE_IDENTITY() ');
  //Adres i?in
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select top 1 SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=2),'+
  ' (Select top 1 ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=2),'''+ADRES+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+' )  ',[],[]);

  //?l?e i?in
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select top 1 SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=6),'+
  ' (Select top 1 ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=6),'''+ILCE+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+' )',[],[]);

  //?l i?in
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select top 1 SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=8),'+
  ' (Select top 1 ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=8),'''+IL+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+' )',[],[]);

  TabServis.FieldByName(sonbasilanctrl.TextHint).AsString:=Tablo.Query1.Fields[0].AsString;
  sonbasilanctrl.Text:=AD;
end;

procedure TServisWizardDlg.btnServisClick(Sender: TObject);
begin
   WizardKontrol.ActivePageIndex := 0;
end;

procedure TServisWizardDlg.btnSevkAdresiPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var
  SQLText:String;
  st:TStringList;
begin
  sonbasilanctrl:=Sender as TcxButtonEdit;
  if Not (TabServis.State in [dsEdit,dsInsert]) then
    TabServis.Edit;
  if AButtonIndex = 0 then begin
    try
      st:=TStringList.Create;
      SQLText:='select ID,AD,'+
        ' ADRES=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=2),'+
        ' ILCE=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=6),'+
        ' IL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=8),'+
        ' ID_VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=20),'+
        ' ID_VERGINO=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=22)'+
        ' FROM REHBERILETISIM Firma where REHBERID='+IntToStr(RehberId)+' ';
      if Tablo.ListedenBilgiGetir('Adres Se?iniz.',SQLText,st,[],'FWizardAdresSecimi',IletisimEkleClick,Tablo.FDCnn,IletisimEkleClick) then begin
        TabServis.FieldByName(sonbasilanctrl.TextHint).AsString:=st.Strings[0];
        sonbasilanctrl.Text:=st.Strings[1];
        sonbasilanctrl.Hint:=st.Strings[2];
      end;
    finally
      st.free;
    end;
  end else if AButtonIndex=1 then begin
    TabServis.FieldByName(sonbasilanctrl.TextHint).AsInteger := 0;
    sonbasilanctrl.Text := '';
  end;

end;

procedure TServisWizardDlg.CBTeslimSekliPropertiesCloseUp(Sender: TObject);
begin
  if TabServis.FieldByName('TESLIM_TARIHI').Value = null then  begin
     TabServis.Edit;
     TabServis.FieldByName('TESLIM_TARIHI').Value := Tablo.GENINI.BugunTrhSaat;
  end;
end;

procedure TServisWizardDlg.CheckKapaliClick(Sender: TObject);
begin
   if (CheckKapali.Checked)and(TabHareketler.RecordCount=1)and(TabHareketler.FieldByName('BITIS').AsString='')then begin
       Showmessage(DWBitisTarihiGir);
       CheckKapali.Checked := False;
   end;
end;

procedure TServisWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger,RehberId)
end;

procedure TServisWizardDlg.EditFATURANOPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
begin
  if TabServis.FieldByName('YERID').AsString<>'' then
     case TabServis.FieldByName('YERI').AsInteger of
        TabNo_SIPARIS_Gelen  : Tablo.SiparisSihirbazBaslat('D', 19, 0, TabServis.FieldByName('YERID').AsInteger, TabServis.FieldByName('REHBERID').AsInteger);
        TabNo_IRSALIYE_Giden : Tablo.FaturaSihirbazBaslat('D', 14, 0, TabServis.FieldByName('YERID').AsInteger, TabServis.FieldByName('REHBERID').AsInteger);
        TabNo_FATBASLIK_Giden: Tablo.FaturaSihirbazBaslat('D', 15, 0, TabServis.FieldByName('YERID').AsInteger, TabServis.FieldByName('REHBERID').AsInteger);
     end;
end;

procedure TServisWizardDlg.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 ');
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  lblMusteriAdres.Caption:=Adres+ Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+' '+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+' / '+Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  lblMusteriTel.Caption:= isTel+Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString+' '+cepTel+Tablo.tabCariBilgileri.FieldByName('CEP').AsString;
  lblMusteriEposta.Caption:= EPosta+Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TServisWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (IptalSecildi) and ((IslemOp = 'E') or (IslemOp='K')) then// e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
    if (TabServis.Active) and (TabServis.Fields[0].AsString <> '') then
      Tablo.ServisSil(TabServis.FieldByName('ID').AsInteger);
   Action := caFree;
end;

procedure TServisWizardDlg.FormCloseQuery(Sender: TObject;  var CanClose: Boolean);
var Ciksin : Boolean;
begin
  Ciksin := True;
  if (IptalSecildi)and((IslemOp='E')or (IslemOp='K')or( (IslemOp='D')and(TabServis.State in [dsEdit, dsInsert])))then //
    case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
     IDYES : begin
              //Ciksin := False;
              WizardKontrolFinishButtonClick(Self);
             end;
     IDCANCEL:Ciksin := False;
    end;
  CanClose := Ciksin;
end;

function TServisWizardDlg.AktifPageIndexGetir(Deger:integer):integer;
begin
  case Deger of
//    200:Result:=SheetNotlar.PageIndex;//; // Notlar sekmesi aktif olsun
    210:Result:=SheetGenel.PageIndex;   // Problem sekmesi aktif olsun
  end;
end;

procedure TServisWizardDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
  ServisID := -1;
  RehberId := -1;
  LogID:=0;
  IptalSecildi := True;
  MailGonderilecek := False;
  Tablo.GridTurkcelestir;

  TureGoreDurumVar := Tablo.GENINI.ReadBoolean(Ops_Servis_TureDurum, False);

  SheetBelgeler.TabVisible := Tablo.YetkiVarmi(300610,YetkiTur_Gorme);
  SheetBelgeler.Visible := Tablo.YetkiVarmi(300610,YetkiTur_Gorme);

  BtnBelgelerYeni.Visible := Tablo.YetkiVarmi(30061010,YetkiTur_Gorme);
  BtnBelgelerSil.Visible := Tablo.YetkiVarmi(30061020,YetkiTur_Gorme);
  BtnBelgelerDuzenle.Visible := Tablo.YetkiVarmi(30061030,YetkiTur_Gorme);
  if Tablo.YetkiVarmi(30061040,YetkiTur_Gorme) then
    cxGridBelgelerDBTableView1.PopupMenu := PopupBelgeDonusum
  else
    cxGridBelgelerDBTableView1.PopupMenu := nil;
  Tablo.EkAlanlariGrideEkle(GridHareketlerDBTableView1,'ServisSonlandirDlg');
end;

procedure TServisWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
         Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TServisWizardDlg(Self),DtsServis);
         Tablo.AlanOlustur(TServisWizardDlg(Self), -1,DtsServis);
      end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin//Bile?en D?zenle
      Tablo.AlanlarDlgBaslat('D',1,0,ctrlPos.X,ctrlPos.Y,0,FindComponent(EkAlanlarEkr.Name),TServisWizardDlg(Self),DtsServis);
      Tablo.AlanOlustur(TServisWizardDlg(Self), -1,DtsServis);
  end;
end;

procedure TServisWizardDlg.TabloAc;
begin
  TabloYenile(TabServis,[ServisID]);
  LabelKod.Caption := Tablo.AciklamaGetir('REHBER','KOD', TabServis.FieldByName('REHBERID').AsString);
  LabelAd.Caption := Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('REHBERID').AsString);

  if TabServis.FieldByName('EKIPMANID').AsString <> '' then begin
     if TabServis.FieldByName('DEMIRBAS').AsBoolean then
        BEUrunAdi.Text := Tablo.AciklamaGetir('DEMIRBAS','DEMIRBASADI',TabServis.FieldByName('EKIPMANID').AsString)
     else
        BEUrunAdi.Text := Tablo.AciklamaGetir('EKIPMANLAR','AD',TabServis.FieldByName('EKIPMANID').AsString);

     SheetOzellik.TabVisible :=  TabServis.Fieldbyname('EKIPMANREHBERID').AsInteger<>0;
     if SheetOzellik.TabVisible then
        TabloYenile(TabEkipmanEkBilgi, [TabNo_EKIPMANREHBER,TabServis.Fieldbyname('EKIPMANREHBERID').AsInteger]);
  end else
     BEUrunAdi.Text := '';

  if TabServis.FieldByName('TESLIM_ALAN').AsString <> '' then
     BETeslimAlan.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('TESLIM_ALAN').AsString);

  if TabServis.FieldByName('TESLIM_EDEN').AsString <> '' then
     BETeslimEden.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('TESLIM_EDEN').AsString);
  if TabServis.FieldByName('LOKASYONID').AsString <> '' then
    BELokasyon.Text:=Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',TabServis.FieldByName('LOKASYONID').Value);
  //if TabServis.FieldByName('SORUMLU').AsString <> '' then
  //  BESorumlu.Text:=Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('SORUMLU').Value);
  if TabServis.FieldByName('MUS_ILGILI').AsString <> '' then begin
     if TabServis.FieldByName('DEMIRBAS').AsBoolean  then
        BEMusIlgili.Text:=Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('MUS_ILGILI').Value)
     else
        BEMusIlgili.Text:=Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('MUS_ILGILI').Value);
  end;
end;

procedure TServisWizardDlg.AsamaEkle(AsamaId : smallint);
begin

end;

procedure TServisWizardDlg.FormShow(Sender: TObject);
var I : smallint;
begin
  EkleDetay := False;
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  if TGenelAnaSekmeFrame(aktifFrame).Name <> 'AnaGirisSayfasiFrame' then begin
     YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
     PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;
  end;
  if (RolId<>'-1') then begin
      LabelSablon.Visible := False;
      ComboBolum.Visible := False;
  end;
  TabGenel.SQL.Text := SQLGenelTekTus.Text;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;


 // TabloYenile(TabGenel,[ServisID]);
  ComboSube.Visible:=SubeVarmi;
  EditSERINO.visible := Tablo.GENINI.ReadBoolean(Ops_Servis_Serino,True);
  LabelSeriNo.visible := EditSERINO.visible;

  BeditProje.Visible:= Tablo.GENINI.ReadBoolean(Ops_Servis_Proje,True);
  if BeditProje.Visible then begin
     ProjeFirsatSec := Tablo.GENINI.ReadInteger(Ops_Servis_ProjeFirsatSec, 1);
     if ProjeFirsatSec = 1 then
        LabelProje.Caption := 'F?rsat'
  end;

  LabelProje.Visible:=BeditProje.Visible;
  BELokasyon.Visible:= Tablo.GENINI.ReadBoolean(Ops_Servis_Lokasyon,True);
  LabelLokasyon.Visible:=BELokasyon.Visible;
  SheetTeslim.TabVisible := Tablo.GENINI.ReadBoolean(Ops_Servis_TeslimSekmesi,True);
  SheetTeslim.Visible := SheetTeslim.TabVisible;
  EkAlanlarEkr.TabVisible :=  Tablo.GENINI.ReadBoolean(Ops_Servis_EkAlanlarSekmesi,True);
  EkAlanlarEkr.Visible := EkAlanlarEkr.TabVisible;

  SheetOzellik.TabVisible :=  Tablo.GENINI.ReadBoolean(Ops_Servis_OzellikSekmesi,True);
  SheetOzellik.Visible := SheetOzellik.TabVisible;

  SheetBelgeler.TabVisible :=  Tablo.GENINI.ReadBoolean(Ops_Servis_BelgelerSekmesi,True);
  SheetBelgeler.Visible := SheetBelgeler.TabVisible;
  SheetGenel.TabVisible :=  Tablo.GENINI.ReadBoolean(Ops_Servis_GenelSekmesi,True);
  SheetGenel.Visible := SheetGenel.TabVisible;
//  SheetYorum.TabVisible :=  Tablo.GENINI.ReadBoolean(Ops_Servis_YorumSekmesi,True);
//  SheetYorum.Visible := SheetYorum.TabVisible;
//  HareketSekmesiYeriAyarla(Tablo.GENINI.ReadInteger(Ops_ServisHareketlerSekmesi,1));
  //ServisPageControl.ActivePageIndex:=0;
  //
  if (not TabServis.Active) then begin
    TabloYenile(TabServis,[ServisID]);
    if EkAlanlarEkr.TabVisible then
     Tablo.AlanOlustur(TServisWizardDlg(Self), -1,DtsServis);
    case IslemOp of
    'E':begin
          if RehberID<=0 then
             LabelKodClick(Self);
          ServisID:=veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'exec sp_prg_Servis_Yeni '+IntToStr(RehberID)+','+IntToStr(SubeID)+','+Kullanan+', '''', '''+formatdatetime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+'''  ',[],[],true);
          TabloYenile(TabServis,[ServisID]);
          OncekiSorumlu:=0;
        end;
    'D': begin
           ServisID:=TabServis.FieldByName('ID').AsInteger;
           TabloAc;
           OncekiSorumlu := TabServis.FieldByName('SORUMLU').AsInteger;
         end;
    end;
  end;

  GridHareketlerDBTableView1BITIS.SortOrder := soAscending;

  //PageControl1.ActivePageIndex:=0;
  Tablo.TablodanSorguAc(1,' select BASLAMASURE=dbo.fn_TarihFarkiFormatli(S.TARIH, S.BASLAMATARIHI) from SERVIS S where ID='+IntToStr(ServisID));
  cbStokDepo.Enabled := not Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SERVISDETAY where SERVISID = &FId and TUR=1', ['&FId'],[ServisID]);
  if RehberId=0 then
     RehberId := TabServis.FieldByName('REHBERID').AsInteger;
  FirmaBilgileri;
  if TabServis.FieldByName('REHBERID').AsInteger=0 then
     LabelKod.Caption := 'Firma Se?..';
//  LabelFirmaSec.Visible :=TabServis.FieldByName('REHBERID').AsInteger=0;
  LogBelge.Clear;
  LogBelge2.Clear;
  LogBelge3.Clear;
  BelgeDoldur(TabServisBelge,LogBelge2,1);
//  Tablo.GridAyarRestore('ServisNotlar',GridNotlarView );
  Tablo.GridAyarRestore('ServisBelge',cxGridBelgelerDBTableView1 );
  Tabloyenile(TabGecmisServisler, [TabServis.FieldByName('REHBERID').AsInteger,TabServis.FieldByName('REHBERID').AsInteger]);
  ServisPageControlChange(Self);
  if IslemOp='E' then begin
      TabServis.Edit;
      if (CBServisTuru.visible)AND(Tablo.repServisTuru.Properties.Items.Count>0) then begin
          TabServis.Edit;
          TabServis.FieldByName('TURU').AsInteger := Tablo.repServisTuru.Properties.Items[0].Value;
          CBServisTuru.EditValue := Tablo.repServisKabulSekli.Properties.Items[0].Value;
      end;
  end;
  GenelButtonCreate;
  if (TabServis.FieldByName('PROJEID').Value <> null) and (TabServis.FieldByName('PROJEID').AsInteger>0) then begin
    Tablo.TablodanSorguAc(9,'select ID,AD=isnull(PROJEKODU,'''')+'' / ''+isnull(PROJEADI,'''') from PROJELER where ID='+TabServis.FieldByName('PROJEID').AsString);
    if not Tablo.Query9.IsEmpty then begin
      BeditProje.Text := Tablo.Query9.FieldByName('AD').AsString;
      BeditProje.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
    end;
  end;

//  if SheetHareketlerUst.tabVisible then
//     PageControl1.ActivePage := SheetHareketlerUst;
  ServisPageControl.ActivePageIndex := 0;
  ServisPageControlChange(self);
end;

procedure TServisWizardDlg.BEBildirimYapanPropertiesButtonClick(Sender:TObject;AButtonIndex:Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabServis);
end;

procedure TServisWizardDlg.BeditKonusuPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  EkleProblemTusClick(ToolBarGenel.Buttons[0]);
end;

procedure TServisWizardDlg.BeditProjeDblClick(Sender: TObject);
begin
  if BeditProje.Text <> '' then
     Tablo.ProjeSihirbazBaslat('D', SERVIS.FieldByName('PROJEID').AsInteger, SERVIS.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);
end;

procedure TServisWizardDlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaPROJEIDGonder(BeditProje, TabServis, AButtonIndex, ProjeSecimi, TabServis.FieldByName('REHBERID').AsInteger, ProjeFirsatSec);
end;

procedure TServisWizardDlg.BelgeDoldur(Table1:TFDQuery;Belge:TStringList;Page:integer);
var
  i:integer;
begin
  Table1.Close;

  if Table1.Params.FindParam('PSerID') = nil then begin
    with Table1.Params.Add do begin
      Name := 'PSerID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  end;

  Table1.ParamByName('PSerID').AsInteger := TabServis.Fields[0].AsInteger;
  Table1.Open;
  if Table1.active then begin
    Table1.First;
    while not Table1.Eof do begin
      if LogGun>0 then begin
        if Table1.Active then
          for i := 0 to Table1.FieldCount-1 do begin
            Belge.Add(Table1.Fields[i].AsString);
          end;
      end;
      Table1.Next;
    end;
   // if Table1.Recordcount>0 then
    //  Table1.Edit;
  end;

end;

procedure TServisWizardDlg.GenelTreeListACIKLAMAPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := TabGenel.FieldByName('ACIKLAMA').AsString;
   if TGirisKutusuEx.BilgiAlEx(TabGenel.FieldByName('AD').AsString , TGirdiDenetimleri.Create.Memo('A??klama' , @Bilgi)) = mrOk then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' update SERVISBILGI set ACIKLAMA=&czm where ID=&id ',['&czm','&id'],
        [StringReplace(VarToStr(Bilgi), '''', '"',[rfReplaceAll]) , TabGenel.FieldByName('ID').AsInteger]);
       TabloYenile(TabGenel,[ServisID])
   end;
end;

procedure TServisWizardDlg.GenelTreeListBeginDragNode(Sender: TcxCustomTreeList;
  ANode: TcxTreeListNode; var Allow: Boolean);
begin
  Allow := True;
end;

procedure TServisWizardDlg.GenelTreeListCOZUMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   //Bilgi := TabGenel.FieldByName('COZUM').AsString;
   Bilgi := vartostr( (Sender as TcxButtonEdit).EditingValue );
   if TGirisKutusuEx.BilgiAlEx(TabGenel.FieldByName('AD').AsString , TGirdiDenetimleri.Create.Memo('??z?m' , @Bilgi)) = mrOk then begin
      TabGenel.Edit;
      TabGenel.FieldByName('COZUM').AsString := VarToStr(Bilgi);
   end;
end;

procedure TServisWizardDlg.GenelTreeListDragOver(Sender, Source: TObject; X,Y: Integer; State: TDragState; var Accept: Boolean);
var ANode: TcxTreeListNode;
    TreeHitTest: TcxTreeListHitTest;
    TutulanNode,BirakilanNode: TcxTreeListNode;
begin
  Accept := True;
  if State = dsDragLeave then begin
    TreeHitTest := (Sender as TcxDBTreeList).HitTest;
    if TreeHitTest.HitAtBackground then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SERVISBILGI set USTID = null where ID='+TabGenel.FieldByName('ID').AsString,[],[]);
      TabloYenile(TabGenel,[ServisID]);
      Accept := False;
    end;
  end;
end;

procedure TServisWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TServisWizardDlg.GridDetayViewEditChanged(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TServisWizardDlg.GridEkEkipmanViewDblClick(Sender: TObject);
begin
   Tablo.TablodanSorguAc(1, 'Select DETAYBOLUMU FROM EKIPMANLAR E where E.ID='+TabServis.FieldByName('EKIPMANID').AsString);
   Tablo.EkipmanDuzenle(TabServis.FieldByName('EKIPMANREHBERID').AsInteger, Tablo.Query1.Fields[0].AsString);
   TabloYenile(TabEkipmanEkBilgi, [TabNo_EKIPMANREHBER,TabServis.Fieldbyname('EKIPMANREHBERID').AsInteger]);
end;

procedure TServisWizardDlg.GridHareketlerDBTableView1DblClick(Sender: TObject);
var TurBilgisi : string;
begin
//  SonrakiHareketiEkle := False;
  Application.CreateForm(TServisSonlandirDlg,ServisSonlandirDlg);
  ServisSonlandirDlg.YeniHareket := False;
  //ServisSonlandirDlg.GroupDetay.Visible := False;
  //ServisSonlandirDlg.CheckAciklama.EditValue := False;
  Tablo.TablodanSorguAc(4,'select * from ALANLAR where EKRANADI=''ServisSonlandirDlg'' and TUR not in (11,12)');
  Tablo.Query4.First;
  while not Tablo.Query4.Eof do begin
    if ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString) <> nil then
      case Tablo.Query4.FieldByName('TUR').AsInteger of
        1 :TcxTextEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text := TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString;
        3 : if TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString <> '' then
              TcxDateEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Date := TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsDateTime;
        4 :TcxComboBox(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text := TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString;
        5 :TcxCheckBox(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Checked := TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsBoolean;
        7 :TcxButtonEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text := TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString;
      end;
    Tablo.Query4.Next;
  end;

  ServisSonlandirDlg.CheckBaslama.Checked := TabHareketler.FieldByName('BASLASEC').AsBoolean;
  ServisSonlandirDlg.CheckBitis.Checked := TabHareketler.FieldByName('BITISSEC').AsBoolean;


  if TabHareketler.FieldByName('BASLAMA').value = Null then begin
    ServisSonlandirDlg.DateBaslama.Date := Tablo.GENINI.BugunTrh;
    ServisSonlandirDlg.TimeBaslama.Time := Tablo.GENINI.BugunTrhSaat;
  end else begin
    ServisSonlandirDlg.DateBaslama.Date := TabHareketler.FieldByName('BASLAMA').AsDateTime;
    ServisSonlandirDlg.TimeBaslama.Time := TabHareketler.FieldByName('BASLAMA').AsDateTime;
  end;

  if TabHareketler.FieldByName('BITIS').value = Null then begin
    ServisSonlandirDlg.DateBitis.Date := Tablo.GENINI.BugunTrh;
    ServisSonlandirDlg.TimeBitis.Time := Tablo.GENINI.BugunTrhSaat;
  end else begin
    ServisSonlandirDlg.DateBitis.Date := TabHareketler.FieldByName('BITIS').AsDateTime;
    ServisSonlandirDlg.TimeBitis.Time := TabHareketler.FieldByName('BITIS').AsDateTime;
  end;
  ServisSonlandirDlg.ServisID := ServisID;
  if TureGoreDurumVar then
     TurBilgisi:=' and TUR='+IntToStr(CBServisTuru.EditingValue) //e?er opsiyonda servis t?r?ne g?re durumlar gelsin se?iliyse
  else
     TurBilgisi:='';

  ServisSonlandirDlg.comboDurum.Properties.Items := Tablo.ComboDurumDoldur(ServisID,TabHareketler.FieldByName('ID').AsInteger, TurBilgisi);
  ServisSonlandirDlg.comboDurum.Enabled := TabHareketler.RecordCount = TabHareketler.RecNo;
  ServisSonlandirDlg.comboDurum.EditValue := TabHareketler.FieldByName('DURUM').AsInteger;
  ServisSonlandirDlg.comboDurum.PostEditValue;
  ServisSonlandirDlg.EditPersonel.Tag := TabHareketler.FieldByName('PERSONEL').AsInteger;
  ServisSonlandirDlg.EditPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabHareketler.FieldByName('PERSONEL').AsInteger);
  ServisSonlandirDlg.Memociklama.Lines.Text := TabHareketler.FieldByName('ACIKLAMA').AsString;
  ServisSonlandirDlg.ShowModal;
  if ServisSonlandirDlg.ModalResult = mrOk then begin
    TabHareketler.Edit;
    Tablo.TablodanSorguAc(4,' select * from ALANLAR where EKRANADI=''ServisSonlandirDlg'' and TUR not in (11,12)');
    Tablo.Query4.First;
    while not Tablo.Query4.Eof do begin
      if ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString) <> nil then
        case Tablo.Query4.FieldByName('TUR').AsInteger of
          1 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString := TcxTextEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text;
          3 :if TcxDateEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text <> '' then
               TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsDateTime := TcxDateEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Date;
          4 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString := TcxComboBox(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text;
          5 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsBoolean := TcxCheckBox(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Checked;
          7 :TabHareketler.FieldByName(Tablo.Query4.FieldByName('ALANADI').AsString).AsString := TcxButtonEdit(ServisSonlandirDlg.FindComponent(Tablo.Query4.FieldByName('ALANADI').AsString)).Text;
        end;
      Tablo.Query4.Next;
    end;

    TabHareketler.FieldByName('BASLASEC').AsBoolean := ServisSonlandirDlg.CheckBaslama.Checked;
    TabHareketler.FieldByName('BITISSEC').AsBoolean := ServisSonlandirDlg.CheckBitis.Checked;

    if ServisSonlandirDlg.CheckBitis.Checked then
      TabHareketler.FieldByName('BITIS').AsDateTime := ServisSonlandirDlg.DateBitis.Date+ServisSonlandirDlg.TimeBitis.Time
    else
      TabHareketler.FieldByName('BITIS').value := Null;
    if ServisSonlandirDlg.CheckBaslama.Checked then
      TabHareketler.FieldByName('BASLAMA').AsDateTime := ServisSonlandirDlg.DateBaslama.Date+ServisSonlandirDlg.TimeBaslama.Time
    else
      TabHareketler.FieldByName('BASLAMA').value := Null;
    if ServisSonlandirDlg.CheckAciklama.Checked then begin
      if ServisSonlandirDlg.Memociklama.Lines.Text <> TabHareketler.FieldByName('ACIKLAMA').AsString then
        TabHareketler.FieldByName('ACIKLAMA').AsString := ServisSonlandirDlg.Memociklama.Lines.Text;
      if ServisSonlandirDlg.comboDurum.EditValue <> TabHareketler.FieldByName('DURUM').AsInteger then
        TabHareketler.FieldByName('DURUM').AsInteger := ServisSonlandirDlg.comboDurum.EditValue;
      if ServisSonlandirDlg.EditPersonel.Tag <> TabHareketler.FieldByName('PERSONEL').AsInteger then
        TabHareketler.FieldByName('PERSONEL').AsInteger := ServisSonlandirDlg.EditPersonel.Tag;
    end;
    TabHareketler.FieldByName('DEGISTIREN').AsString := kullanan;
    TabHareketler.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    TabHareketler.Post;
  end;
  FreeAndNil(ServisSonlandirDlg);
//  if SonrakiHareketiEkle then
//    BtnHareketlerYeniClick(Self);
end;

procedure TServisWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TServisWizardDlg.DtsGenelStateChange(Sender: TObject);
begin
  GenelKaydetTus.Visible:= DtsGenel.State in [dsEdit,dsInsert];
  GenelIptalTus.Visible:= DtsGenel.State in [dsEdit,dsInsert];
  GenelSilTus.Visible:= (DtsGenel.State = dsBrowse) and (not TabGenel.IsEmpty);


  //Tablo.NavTusGoruntule(DtsGenel, nil,GenelSilTus,GenelKaydetTus,GenelIptalTus)
end;

procedure TServisWizardDlg.DtsHareketlerStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsHareketler,BtnHareketlerYeni,BtnHareketlerSil,BtnHareketlerKaydet,BtnHareketlerIptal);
  BtnHareketlerDuzenle.Visible := not (DtsHareketler.State in [dsEdit, dsInsert])
                                  and (DtsHareketler.DataSet.Active)
                                  and (not DtsHareketler.DataSet.IsEmpty);
end;

procedure TServisWizardDlg.DtsServisNotlarStateChange(Sender: TObject);
begin
//  Tablo.NavTusGoruntule(DtsServisNotlar,BtnNotlarYeni,BtnNotlarSil,BtnNotlarKaydet,BtnNotlarIptal);
end;

procedure TServisWizardDlg.LabelAdClick(Sender: TObject);
begin
  Tablo.RehberSihirbazBaslat(0,TabServis.FieldByName('REHBERID').AsInteger,-100,-100,False);
end;

procedure TServisWizardDlg.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
   Id := Tablo.RehberAra_IDGetir(-1);
   if Id>0 then begin
      RehberId := Id;
      if TabServis.State = dsBrowse then
         TabServis.Edit;
      TabServis.FieldByName('REHBERID').AsInteger := RehberId;
      FirmaBilgileri
   end;
end;

procedure TServisWizardDlg.LabelKonusuClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TServisWizardDlg.LabelSablonClick(Sender: TObject);
begin
  if  trim(ComboBolum.Text) ='' then
   begin
     ShowMessage(cnst_SablonAdiBosOlamaz);
//     Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),pchar(Uyari), MB_OK+ MB_ICONWARNING);
     Abort;
   end;
  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := TabNo_SERVIS;
  RehberAyarDlg.Bolum := ComboBolum.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  DetayEkrPage(Self);
end;

procedure TServisWizardDlg.ServisPageControlChange(Sender: TObject);
var ra:string;
begin
   while PopupMenuYaz.Items.Count>5 do
      PopupMenuYaz.Items.Delete(PopupMenuYaz.Items.Count-1);
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
   YaziciYaz.Caption := ra;

  if ServisID>0 then begin
     Kaydet;
//    if ServisPageControl.ActivePage = SheetYorum then
//      TabloYenile(TabYorum,[TabNo_SERVIS, ServisID])
//    else
    if ServisPageControl.ActivePage = SheetGenel then
      TabloYenile(TabGenel,[ServisID])
    else if ServisPageControl.ActivePage = SheetBelgeler then
      TabloYenile(TabServisBelge,[ServisID]);;
  end;
end;

procedure TServisWizardDlg.Kaydet;
var
  bilgiler, etiketler: TArrayofString;
  epostaalicilar: TList<TEpostaAlici>;
begin
  if TabServis.State in [dsInsert, dsEdit] then
     TabServis.post;
  if TabHareketler.State in [dsInsert, dsEdit] then
     TabHareketler.post;
  if TabGenel.State in [dsInsert, dsEdit] then
     TabGenel.post;
  if TabDetay.State in [dsInsert, dsEdit] then
     TabDetay.post;
  if TabServisNotlar.State in [dsInsert, dsEdit] then
     TabServisNotlar.post;
end;

procedure TServisWizardDlg.KaydetTusClick(Sender: TObject);
begin
   Kaydet;
end;

procedure TServisWizardDlg.KaynakBelgeyiA1Click(Sender: TObject);
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
  Tablo.Query1.SQL.Add(' 	when YERI = 411 then 14         ');
  Tablo.Query1.SQL.Add(' 	when YERI = 461 then 109        ');
  Tablo.Query1.SQL.Add(' 	when YERI in (409,410) then 19  ');
  Tablo.Query1.SQL.Add(' 	when YERI = 462 then 119        ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then -99 ');
  Tablo.Query1.SQL.Add(' end, ');
  Tablo.Query1.SQL.Add(' KAYNAKBELGENO=case ');
  Tablo.Query1.SQL.Add(' 	when YERI = 83 then (select SERVISNO from SERVIS where ID=(select SERVISID from SERVISDETAY where ID=F.YERID)) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407,409,410) then (select SIPARISNO from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID=F.YERID)) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (408,411,461,462) then (select FATURANO from FATBASLIK where ID=(select FATBASID from FATURA where ID=F.YERID))               ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then (select TEKLIFNO from TEKLIF where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))             ');
  Tablo.Query1.SQL.Add(' end, ');
  Tablo.Query1.SQL.Add(' KAYNAKID=case      ');
  Tablo.Query1.SQL.Add(' 	when YERI = 83 then (select SERVISID from SERVISDETAY where ID=F.YERID ) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (406,407,409,410) then (select SIPARISID from SIPARISDETAY where ID=F.YERID ) ');
  Tablo.Query1.SQL.Add(' 	when YERI in (408,411,461,462) then (select FATBASID from FATURA where ID=F.YERID )                ');
  Tablo.Query1.SQL.Add(' 	when YERI in (412,413) then (SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID )           ');
  Tablo.Query1.SQL.Add(' end, ');
  Tablo.Query1.SQL.Add(' KAYNAKFIRMA=(select FIRMA from REHBER where ID=(case   ');
  Tablo.Query1.SQL.Add(' when YERI = 83 then (select REHBERID from SERVIS where ID=(select SERVISID from SERVISDETAY where ID=F.YERID))  ');
  Tablo.Query1.SQL.Add(' when YERI in (406,407,409,410) then (select REHBERID from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID=F.YERID))  ');
  Tablo.Query1.SQL.Add(' when YERI in (408,411,461,462) then (select REHBERID from FATBASLIK where ID=(select FATBASID from FATURA where ID=F.YERID)) ');
  Tablo.Query1.SQL.Add(' when YERI in (412,413) then (select REHBERID from TEKLIF where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))  ');
  Tablo.Query1.SQL.Add(' end ))  ');
  case TabServisBelge.FieldByName('TUR').AsInteger of
    9,19:begin
      Tablo.Query1.SQL.Add(' from SIPARISDETAY F ');
      Tablo.Query1.SQL.Add(' where SIPARISID='+TabServisBelge.FieldByName('ID').AsString+' and ');
      Tablo.Query1.SQL.Add(' 	YERI in (83,404,405,406,407,408,409,410,411,412,413,414,415,461,462) ');
    end;
  else
    Tablo.Query1.SQL.Add(' from FATURA F  ');
    Tablo.Query1.SQL.Add(' where FATBASID='+TabServisBelge.FieldByName('ID').AsString+' and ');
    Tablo.Query1.SQL.Add(' 	YERI in (83,404,405,406,407,408,409,410,411,412,413,414,415,461,462) ');
  end;
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
      if Tablo.ListedenBilgiGetir('Kaynak Se?imi',Tablo.Query1.SQL.Text,sts,[Tablo.RepKasaTurleri,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],'FaturalarKaynakSecimi')then begin
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
  end else if AYeri=-99 then begin
    Tablo.TablodanSorguAc(2,'select REHBERID from TEKLIF where ID='+IntToStr(AYerID));
    RehID := Tablo.Query2.FieldByName('REHBERID').AsInteger;
  end else
    RehID := TabServis.FieldByName('REHBERID').AsInteger;
  AnaForm.GormeDialogCagir(AYerID,AYeri,RehID,0,Tablo.GENINI.BugunTrh,ABelgeno);
  //Tablo.SiparisSihirbazBaslat('D',FATBASLIK.FieldByName('TUR').AsInteger,0,FATBASLIK.FieldByName('ID').AsInteger,FATBASLIK.FieldByName('REHBERID').AsInteger);
  TabloYenile(TabServisBelge,[ServisID]);
end;

procedure TServisWizardDlg.TabEkipmanDetayBeforeDelete(DataSet: TDataSet);
begin
  if islemOp='D' then
     Tablo.LogIslemleri(DataSet.Tag,(DataSet as TFDQuery).FieldByName('ID').AsInteger,5,DataSet);
end;

procedure TServisWizardDlg.TabEkipmanDetayBeforeEdit(DataSet: TDataSet);
begin
  if LogGun >0 then
     Tablo.OncekiLogBelirle(DataSet);
end;

procedure TServisWizardDlg.TabGenelAfterOpen(DataSet: TDataSet);
begin
  GenelTreeList.FullExpand;
end;

{function TServisWizardDlg.Postala(Tip, SablonId:integer):string;
var
   Konu, KimdenAdr, KimeAdr,BilgiAdr, AtacDosya, RaporAdi, SonucMesaj, DosyaAdi,s, Trh : string;
   EpostaAlicilar, EPostaAlicilarCC : TList<TEpostaAlici>;
   gmail : dmailadresleri;
   BodyStr,DetayStr : string;
   Body : TStringStream;
   EkDosya:TList<string>;
   YorumEkleyen : integer;

   procedure DosyalarEkle;
   begin
      Tablo.TablodanSorguAc(5, 'select I.ID,AD from DOKUMAN D inner join IMAJ I on D.ID=I.YER_ID where D.DURUM>0 AND '+
          ' MODUL =  '+IntToStr(TabNo_SERVIS)+' AND MODULID='+TabServis.FieldByName('ID').AsString);
      while not Tablo.Query5.eof do begin
          Tablo.TablodanSorguAc(6, ' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma ' + Tablo.Query5.FieldByName('ID').AsString +
           ' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI=''' + copy(Tablo.Query5.FieldByName('AD').AsString, Pos('.', Tablo.Query5.FieldByName('AD').AsString) + 1, 10) + '''');
          s := KutuktenOku(Tablo.Query6, 'BELGE','1'+ Tablo.Query5.FieldByName('AD').AsString, false);
          EkDosya.Add(s);
          Tablo.Query5.next;
      end;
   end;
begin
  EPostaAlicilar := TList<TEpostaAlici>.Create;
  EPostaAlicilarCC := TList<TEpostaAlici>.Create;
  if Tip=1 then begin //personel
    Tablo.TablodanSorguAc(0,'select * from MAILSABLON where MODULID=83 and ID='+IntToStr(SablonId));
    KimeAdr := Tablo.MailAdresiBul(1,TabHareketler.FieldByName('PERSONEL').AsInteger);
    if KimeAdr='' then
      Exit
    else
      TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA',TabHareketler.FieldByName('PERSONEL').AsInteger)+','+KimeAdr, EPostaAlicilar);
  end else if Tip=2 then begin //ilgili yada cari
    Tablo.TablodanSorguAc(0,'select * from MAILSABLON where MODULID=83 and ID='+IntToStr(SablonId));
    if StrToIntDef(TabServis.FieldByName('MUS_ILGILI').AsString,0) > 0 then begin//ilgili se?ilmi? mi
      KimeAdr := Tablo.MailAdresiBul(2,TabServis.FieldByName('MUS_ILGILI').AsInteger);
      if KimeAdr<>'' then
        TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBERPERSONEL','ADSOYAD',TabServis.FieldByName('MUS_ILGILI').AsInteger)+','+KimeAdr, EPostaAlicilar);
    end;
    if KimeAdr='' then  begin //ilgilide bi?i yoksa carinin eposta adresine bak?caz
      KimeAdr := Tablo.MailAdresiBul(1,TabServis.FieldByName('REHBERID').AsInteger);
      if KimeAdr<>'' then
        TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('REHBERID').AsInteger)+','+KimeAdr, EPostaAlicilar)
      else
        Exit;
    end;
  end else
    Exit;
  if Tablo.Query0.IsEmpty then
    Exit;
  BodyStr := Tablo.Query0.FieldByName('ICERIK').AsString;
  Konu := Tablo.Query0.FieldByName('KONU').AsString;
  if Tip=1 then begin//i? personel
    Konu := StringReplace(Konu,'@@KONU@@','Servis Atama(No:'+TabServis.FieldByName('SERVISNO').AsString+')',[rfReplaceAll]);
    BodyStr := StringReplace(BodyStr,'@@ADSOYAD@@',Tablo.AciklamaGetir('REHBER','FIRMA',TabHareketler.FieldByName('PERSONEL').AsInteger),[rfReplaceAll]);
  end else if Tip=2 then begin //d?? firma
    Konu := StringReplace(Konu,'@@KONU@@','Servis Bilgilendirme('+TabServis.FieldByName('KONUSU').AsString+')',[rfReplaceAll]);
    if StrToIntDef(TabServis.FieldByName('MUS_ILGILI').AsString,0) > 0 then
      BodyStr := StringReplace(BodyStr,'@@ADSOYAD@@',Tablo.AciklamaGetir('REHBERPERSONEL','ADSOYAD',TabServis.FieldByName('MUS_ILGILI').AsInteger),[rfReplaceAll])
    else
      BodyStr := StringReplace(BodyStr,'@@ADSOYAD@@',Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('REHBERID').AsInteger),[rfReplaceAll]);
  end;
  BodyStr := StringReplace(BodyStr,'@@FIRMA@@',Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('REHBERID').AsInteger),[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@URUN@@',BEUrunAdi.Text+' - '+EditSERINO.Text,[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@TUR@@',CBServisTuru.Text,[rfReplaceAll]);
  if TabServis.FieldByName('MUS_ILGILI').AsString <> '' then begin
    tablo.TablodanSorguAc(1, 'select TOKEN from KULLANICI where REHBERID='+TabServis.FieldByName('MUS_ILGILI').AsString);
    if Tablo.Query1.Fields[0].AsString<>'' then
       BodyStr := StringReplace(BodyStr,'@@TOKEN@@',Tablo.Query1.Fields[0].AsString,[rfReplaceAll]);
  end;
  BodyStr := StringReplace(BodyStr,'@@SERVISID@@',TabServis.FieldByName('ID').AsString,[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@ILGILIID@@',TabServis.FieldByName('MUS_ILGILI').AsString,[rfReplaceAll]);

  if tabServis.FieldByName('ACIL').AsBoolean then
    DetayStr := DetayStr + '<b> AC?L! </b> '+'<br/>';
  if tabServis.FieldByName('ONEMLI').AsBoolean then
    DetayStr := DetayStr + '<b> ?nemli! </b> '+'<br/>';
  if tabServis.FieldByName('DISSERVIS').AsBoolean then
    DetayStr := DetayStr + ' D?? Servis  '+'<br/>';
  if Tip=1 then begin//i? personel
    DetayStr := DetayStr + '<b>  Kimden : </b> '+Tablo.AciklamaGetir('REHBER','FIRMA',TabHareketler.FieldByName('EKLEYEN').AsInteger)+'<br/>';
    DetayStr := DetayStr + '<b>  Kime : </b> '+Tablo.AciklamaGetir('REHBER','FIRMA',TabHareketler.FieldByName('PERSONEL').AsInteger)+'<br/>';
    DetayStr := DetayStr + '<b>  M??teri : </b> '+Tablo.AciklamaGetir('REHBER','FIRMA',TabServis.FieldByName('REHBERID').AsInteger)+'<br/>';
    if StrToIntDef(TabServis.FieldByName('MUS_ILGILI').AsString,0) > 0 then
      DetayStr := DetayStr + '<b>  ?lgili : </b> '+Tablo.AciklamaGetir('REHBERPERSONEL','ADSOYAD',TabServis.FieldByName('MUS_ILGILI').AsInteger)+'<br/>';

  end;
  DetayStr := DetayStr + '<b>  Konusu : </b> '+tabServis.FieldByName('KONUSU').AsString+'<br/>';
  DetayStr := DetayStr + '<b>  Durum : </b> '+VarToStr(Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'select ANAHTAR from GENINI where BOLUM=-3007 and DEGER='+TabHareketler.FieldByName('DURUM').AsString+' and DIL=-1',[],[],True))+'<br/>';

  if TabHareketler.FieldByName('ACIKLAMA').AsString <> '' then
    DetayStr := DetayStr + '<b>  Not : </b> '+ TabHareketler.FieldByName('ACIKLAMA').AsString+'<br/>';
  TabloYenile(TabGenel,[ServisID]);
  if not TabGenel.IsEmpty then begin
    DetayStr := DetayStr + ' <br/> <b>  GENEL: </b> <br/>';
    TabGenel.First;
    while not TabGenel.Eof do begin
      DetayStr := DetayStr + '<b> '+TabGenel.FieldByName('KOD').AsString+' - '+TabGenel.FieldByName('GRUP').AsString+' - '+TabGenel.FieldByName('AD').AsString+'</b> '+'<br/>';
      if TabGenel.FieldByName('ACIKLAMA').AsString <> '' then
        DetayStr := DetayStr + '<b> A??klama : </b><i>'+TabGenel.FieldByName('ACIKLAMA').AsString+'</i>'+'<br/>';
      if TabGenel.FieldByName('COZUM').AsString <> '' then
        DetayStr := DetayStr + '<b> ??z?m    : </b><i>'+TabGenel.FieldByName('COZUM').AsString+'</i>'+'<br/>';
      TabGenel.Next;
    end;
  end;

  BodyStr := StringReplace(BodyStr,'@@DETAY@@',DetayStr,[rfReplaceAll]);
  EkDosya := TList<String>.Create;
  //DosyalarEkle; //bu b?l?m servis i?in kullan?lmayacak.
  Body := TStringStream.Create();
  Body.WriteString(BodyStr);
  DosyaAdi := GetEnvironmentVariable('Temp')+'\Temp'+TabHareketler.FieldByName('ID').AsString+'.html';
  Body.SaveToFile(DosyaAdi);
  try
    SonucMesaj := EpostaGonderRapor(
                    EPostaHesapBilgileriniGetir(EpostaHesapID),
                    Konu, DosyaAdi, EkDosya, EPostaAlicilar, EPostaAlicilarCC,
                    Tablo.IdSMTP1, Tablo.iohSSLTLS,TabNo_SERVIS,
                    TabHareketler.FieldByName('ID').AsString,
                    TabHareketler.FieldByName('EKLEYEN').AsInteger).SonucMesaji;
  finally
    FreeAndNil(EPostaAlicilar);
    FreeAndNil(EPostaAlicilarCC);
    FreeAndNil(EkDosya);
  end;
end;}

procedure TServisWizardDlg.TabHareketlerAfterOpen(DataSet: TDataSet);
begin
  BtnHareketlerYeni.Enabled := not Veritabani.VeriVarMi(Tablo.FDCnn,'select * from SERVISHAREKET where KAPANIS=1 and SERVISID='+IntToStr(ServisID),[],[]);
  GridHareketlerDBTableView1.ApplyBestFit();
end;

procedure TServisWizardDlg.TabHareketlerAfterPost(DataSet: TDataSet);
var
  HareketID:integer;
begin
  TabServis.Edit;
  if (TabHareketler.FieldByName('ACILIS').AsBoolean)and(TabHareketler.FieldByName('BASLAMA').Value <> Null) then
     TabServis.FieldByName('BASLAMATARIHI').AsDateTime := TabHareketler.FieldByName('BASLAMA').AsDateTime;
  if TabHareketler.RecNo=TabHareketler.RecordCount then
     TabServis.FieldByName('DURUM').AsInteger := TabHareketler.FieldByName('DURUM').AsInteger;
  SonrakiHareketiEkle := (TabHareketler.RecordCount=TabHareketler.RecNo)and(TabHareketler.FieldByName('BITIS').Value<>Null)and(TabHareketler.FieldByName('KAPANIS').Value = False);
  Tablo.TablodanSorguAc(5,'select * from SERVISHAREKET where SERVISID='+IntToStr(ServisID));
  if not Tablo.Query5.Locate('BITIS',Null,[]) then begin//i?eride biti? tarihi girilmemi? bir kay?t yok ise
     if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from SERVISHAREKET where KAPANIS=1 and SERVISID='+IntToStr(ServisID),[],[]) then begin
        TabServis.FieldByName('ACKAPA').AsBoolean := True;
        TabServis.FieldByName('BITISTARIHI').AsDateTime := TabHareketler.FieldByName('BITIS').AsDateTime;
        SonrakiHareketiEkle := False;
    end;
  end;
  TabServis.Post;
  if MailGonderilecek then begin
    if (DataSet.FieldByName('UYARITURU').AsInteger > 0)
    and(DataSet.FieldByName('EKLEYEN').AsInteger<>DataSet.FieldByName('PERSONEL').AsInteger) then
      ServisPostaGonder(ServisID,TabHareketler.FieldByName('ID').AsInteger);
    if DataSet.FieldByName('DISUYARITURU').AsInteger > 0 then
      ServisPostaGonder(ServisID,TabHareketler.FieldByName('ID').AsInteger,False);
  end;
  MailGonderilecek := False;
  TabloYenile(TabHareketler,[ServisID]);
end;

procedure TServisWizardDlg.TabHareketlerAfterScroll(DataSet: TDataSet);
begin
  TabHareketler.FetchAll;
  BtnHareketlerSil.Enabled := (DataSet.RecordCount = DataSet.RecNo) and
                              (DataSet.RecordCount > 1) and
                              (
                                  (TamYetkili) or
                                  Tablo.YetkiVarmi(30062010,YetkiTur_Gorme) or
                                  ((TabHareketler.FieldByName('EKLEYEN').AsString=Kullanan) and (TabHareketler.FieldByName('BASLAMA').value = Null)) or
                                  ((TabHareketler.FieldByName('EKLEYEN').AsString=Kullanan) and (TabHareketler.FieldByName('PERSONEL').AsString=Kullanan)) or
                                  ((TabHareketler.FieldByName('EKLEYEN').AsString=Kullanan) and (
                                                                                                (TabHareketler.FieldByName('DEGISTIREN').Value=Null)or
                                                                                                (TabHareketler.FieldByName('DEGISTIREN').AsString=Kullanan)
                                                                                                )
                                  )
                              );
  BtnHareketlerDuzenle.Enabled := (TamYetkili) or
                              Tablo.YetkiVarmi(30062010,YetkiTur_Gorme) or
                              ((TabHareketler.FieldByName('PERSONEL').AsString=Kullanan) and (TabHareketler.FieldByName('BITIS').value = Null)) or
                              ((TabHareketler.FieldByName('EKLEYEN').AsString=Kullanan) and (TabHareketler.FieldByName('PERSONEL').AsString=Kullanan)) or
                              ((TabHareketler.FieldByName('EKLEYEN').AsString=Kullanan) and (
                                                                                            (TabHareketler.FieldByName('DEGISTIREN').Value=Null)or
                                                                                            (TabHareketler.FieldByName('DEGISTIREN').AsString=Kullanan)
                                                                                            ));


  TabloYenile(TabYorum,[TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger])
end;

procedure TServisWizardDlg.TabServisAfterOpen(DataSet: TDataSet);
begin
  //TabloYenile(TabAtanan,[ServisID]);
  TabloYenile(TabHareketler,[ServisID]);

  if (TabServis.FieldByName('SERVISADRESI').AsString <> '') then begin
     btnSevkAdresi.Text := Tablo.AciklamaGetir('REHBERILETISIM','AD', TabServis.FieldByName('SERVISADRESI').AsString);
     Tablo.TablodanSorguAc(1,' Select RI.ID,RI.AD,RB.BILGI from REHBERILETISIM RI '+
      ' left outer JOIn REHBERBILGI RB on RI.ID=RB.YER_ID  left outer join REHBERAYAR RA ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
      ' Where RB.YER_ID ='+TabServis.FieldByName('SERVISADRESI').AsString+' and RB.YERI=1 and RA.VARSAYILAN=2 and RI.REHBERID='+TabServis.FieldByName('SERVISADRESI').AsString+'');
     btnSevkAdresi.Hint :=Tablo.Query1.FieldByName('BILGI').AsString;
  end;
end;

procedure TServisWizardDlg.TabServisAfterPost(DataSet: TDataSet);
begin
  Degistirildi:=true;
  DegistirildiSms:=True;
  if ServisID<=0 then
     ServisID := TabServis.FieldByName('ID').AsInteger;
  if RehberId <=0 then
     RehberId := TabServis.FieldByName('REHBERID').AsInteger;
  if islemOp='D' then
     Tablo.LogIslemleri(DataSet.Tag,(DataSet as TFDQuery).FieldByName('ID').AsInteger,4,DataSet);

  if islemOp='E' then begin
    Tablo.TablodanSorguAc(6,'select top 1 DEGER from GENINI where BOLUM=-3007 order by DEGER');
    if not Tablo.Query6.IsEmpty then begin
      TabloYenile(TabHareketler,[ServisID]);
      if TabHareketler.IsEmpty then begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into SERVISHAREKET(SERVISID,BASLAMA,DURUM,EKLEYEN,ACILIS,PERSONEL)'+
                              ' values('+IntToStr(ServisID)+',getdate(),'+Tablo.Query6.FieldByName('DEGER').AsString+','+kullanan+',1,'+kullanan+')',[],[]);
      end;
    end else
      Showmessage(Servis_Har_Baslangic);
  end;
end;

procedure TServisWizardDlg.TabServisBeforeEdit(DataSet: TDataSet);
begin
//  OncekiKdvDurumu := TabServis.FieldByName('KDVDURUM').AsString;
  if LogGun >0  then
     Tablo.OncekiLogBelirle(TabServis);
end;

function TServisWizardDlg.ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
begin

end;

procedure TServisWizardDlg.FaturaTutarHesapla;
begin

end;

procedure TServisWizardDlg.BoslukKontrolleri;
begin
  if not BoslukKontrol(EditServisNo.Text, AGS_ServisAnalizi) then
     Abort;
  //if (BEMusIlgili.visible)and(not BoslukKontrol(BEMusIlgili.Text, BildirimYapan)) then
  //   Abort;
  if (CBServisTuru.visible)and( not BoslukKontrol(CBServisTuru.Text, AWTurBosOlamaz)) then
     Abort;
end;

procedure TServisWizardDlg.TabServisBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(TabServis);
end;

procedure TServisWizardDlg.TabServisNewRecord(DataSet: TDataSet);
var
  //etiketler,bilgiler:TArrayOfString;
  Adi, Kodu : string;
  belgeno : TBelgeNo;
begin
  TabServis.FieldByName('ACIL').Value := False;
  TabServis.FieldByName('ONEMLI').Value := False;
  TabServis.FieldByName('DISSERVIS').Value := False;
  TabServis.FieldByName('REHBERID').AsInteger := RehberId;
  TabServis.FieldByName('DEMIRBAS').AsBoolean := SerKapsam;
  cbStokDepo.ItemIndex := 0;
  Tablo.RehberBilgisiGetir(RehberId,Adi,Kodu);
  LabelKod.Caption := Kodu;
  LabelAd.Caption := Adi;


  //ComboKabuleden.Text := Adi;
  TabServis.FieldByName('TARIH').AsDateTime:= Tablo.GENINI.BugunTrhSaat;
  //varsay?lan iskonto bilgilerine bakal?m...
  // Tablo.RehberEkBilgileriniGetir(RehberId,2,[70, 75, 76, 78],etiketler,bilgiler);
  TabServis.FieldByName('FIYAT_LISTESI').AsInteger:= VarsSatisFiyatID;
  TabServis.FieldByName('DEPO').AsInteger := VarsDepo;
  TabServis.FieldByName('ACKAPA').AsBoolean:= False;
//  TabServis.FieldByName('KDVDURUM').AsString:= 'Hari?';
  TabServis.FieldByName('TESLIM_SEKLI').AsInteger:= 1;
  TabServis.FieldByName('DURUM').AsInteger:=1;
  TabServis.FieldByName('BASLAMATARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
//  TabServis.FieldByName('BITISTARIHI').AsDateTime := TabServis.FieldByName('BASLAMATARIHI').AsDateTime;

  TabServis.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  TabServis.FieldByName('NOTLAR').AsString := '';
  TabServis.FieldByName('EKLEYEN').AsString := Kullanan;
  TabServis.FieldByName('KABUL_EDEN').AsString  := Kullanan;
  belgeno:= SiradakiBelgeNumarasi(TabNo_SERVIS,Tablo.GENINI.BugunTrhSaat);
  TabServis.FieldByName('KOCANNO').AsInteger := KocannoBul(TabNo_SERVIS);
  TabServis.FieldByName('SERVISNO').AsString := belgeno.belgeno;
  TabServis.FieldByName('SERVISSERI').AsString := belgeno.serino;
  TabServis.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TServisWizardDlg.TabServisNotlarCalcFields(DataSet: TDataSet);
begin
   if (TabServisNotlar.active)and(TabServisNotlar.FieldByName('EKLEYEN').AsString<> '') then begin
     Tablo.TablodanSorguAc(1, 'select FIRMA from REHBER where ID='+TabServisNotlar.FieldByName('EKLEYEN').AsString);
     if not Tablo.Query1.IsEmpty then
        TabServisNotlar.FieldByName('EKLEYENAD').AsString := Tablo.Query1.Fields[0].AsString
     else
        TabServisNotlar.FieldByName('EKLEYENAD').AsString := '';
   end;
end;

procedure TServisWizardDlg.TabServisBelgeAfterScroll(DataSet: TDataSet);
begin
   SipariOlutur1.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger = 80)and((TabServisBelge.FieldByName('HEDEF').AsString='Verilen Sipari? ')or(TabServisBelge.FieldByName('HEDEF').AsString='')));
   VerSipariineDntr1.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger = 80)and((TabServisBelge.FieldByName('HEDEF').AsString='Al?nan Sipari?')or(TabServisBelge.FieldByName('HEDEF').AsString='')));
   rsaliyeOlutur2.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger in [9])and(TabServisBelge.FieldByName('HEDEF').AsString=''));
   FaturaOlutur1.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger in [9,10])and(TabServisBelge.FieldByName('HEDEF').AsString=''));
   FiOlutur1.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger in [9,10])and(TabServisBelge.FieldByName('HEDEF').AsString=''));
   SatrsaliyesineDntr1.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger in [19])and(TabServisBelge.FieldByName('HEDEF').AsString=''));
   SatFaturasnaDntr1.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger in [14,19])and(TabServisBelge.FieldByName('HEDEF').AsString=''));
   SatFiineDntr1.Visible := ((not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('TUR').AsInteger in [14,19])and(TabServisBelge.FieldByName('HEDEF').AsString=''));

   BelgeyiA1.Enabled := not TabServisBelge.IsEmpty;
   KaynakBelgeyiA1.Enabled := (not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('KAYNAK').AsString<>'');
   HedefBelgeyiA1.Enabled := (not TabServisBelge.IsEmpty) and (TabServisBelge.FieldByName('HEDEF').AsString<>'');

end;

procedure TServisWizardDlg.TabServisBelgeNewRecord(DataSet: TDataSet);
var
  Qry:TFDQuery;
begin
  Qry := DataSet as TFDQuery;
  Qry.FieldByName('SERVISDETAYTURU').AsInteger := Qry.Tag;
  Qry.FieldByName('SERVISID').AsInteger := ServisID;
  Qry.FieldByName('REHBERID').AsInteger := RehberId;
  Qry.FieldByName('EKLEYEN').AsString := Kullanan;
  Qry.FieldByName('ISKONTO').AsInteger := 0;
  Qry.FieldByName('ISKONTO2').AsInteger := 0;
  Qry.FieldByName('KUR').AsString := CariDoviz;
  Qry.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TServisWizardDlg.TabServisPlanPersonelNewRecord(DataSet: TDataSet);
var
  Qry:TFDQuery;
begin
  Qry := DataSet as TFDQuery;
  Qry.FieldByName('SERVISDETAYTURU').AsInteger := Qry.Tag;
  Qry.FieldByName('SERVISID').AsInteger := ServisID;
  Qry.FieldByName('SERVISDETAYID').AsInteger := Qry.FieldByName('ID').AsInteger;
  Qry.FieldByName('TUR').AsInteger := Qry.FieldByName('TUR').AsInteger;
  Qry.FieldByName('URUNID').AsInteger := Qry.FieldByName('URUNID').AsInteger;
  Qry.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TServisWizardDlg.ServisNotlaraEkle(Qry:TFDQuery;Tur:Integer);
begin
  Qry.FieldByName('SERVISID').Value := ServisID;
  Qry.FieldByName('SERVISTUR').Value := Tur;
  Qry.FieldByName('EKLEMETARIHI').Value := Tablo.GENINI.BugunTrhSaat;
  Qry.FieldByName('EKLEYEN').Value := Kullanan;
end;

procedure TServisWizardDlg.ServisEkrFinishButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if not BoslukKontrol(BeditKONUSU.Text, AWKonusu) then
     Abort;
  ServisBoslukKontrolu;
  Kaydet;
end;

procedure TServisWizardDlg.ServisEkrLastButtonClick(Sender: TObject; var Stop: Boolean);
begin
  ServisBoslukKontrolu
end;

procedure TServisWizardDlg.TabServisProblemNewRecord(DataSet: TDataSet);
var Qry:TFDQuery;
begin
  Qry := DataSet as TFDQuery;
  if Qry = TabServisNotlar then
     ServisNotlaraEkle(Qry,TabNo_SERVIS_Notlar);
end;


procedure TServisWizardDlg.TabServisUygulamaAfterDelete(DataSet: TDataSet);
begin
   FaturaTutarHesapla;
end;

procedure TServisWizardDlg.TabServisUygulamaAfterPost(DataSet: TDataSet);
begin
  TabloYenile(Dataset as TFDQuery,[TabServis.FieldByName('ID').AsInteger]);
  FaturaTutarHesapla;
end;

procedure TServisWizardDlg.TabYorumAfterScroll(DataSet: TDataSet);
begin
   YorumSil.Visible := (not TabYorum.IsEmpty)and(TabYorum.FieldByName('EKLEYEN').AsString=Kullanan);
   YorumDuzenle.Visible := YorumSil.Visible;
end;

procedure TServisWizardDlg.TamEkranTusClick(Sender: TObject);
begin
  PanelUst.Visible := not PanelUst.Visible;
end;

procedure TServisWizardDlg.ServisPlanEkleTusClick(Sender: TObject);
begin
  if TabServis.State in [dsInsert, dsEdit] then
     TabServis.Post;

  if AraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,AraDlg);

  AraDlg.GirisCikis:=FWCikis;
  AraDlg.FatBasID:=TabServis.FieldByName('ID').AsInteger;
  AraDlg.RehberID:=TabServis.FieldByName('REHBERID').AsInteger;
  AraDlg.FiyatlariGetir:=True;
  AraDlg.KalanAdetGetir:=True;
  if TabServis.FieldByName('FIYAT_LISTESI').Value<>null then
    AraDlg.cbFiyatAdi.EditValue := TabServis.FieldByName('FIYAT_LISTESI').Value
  else
    AraDlg.cbFiyatAdi.EditValue := 1;
  AraDlg.cbStokDepo.EditValue:=0;
  AraDlg.ShowModal;
end;

procedure TServisWizardDlg.TreeListGecmisServislerClick(Sender: TObject);
var aindex:integer;
begin
   //if TabGecmisServisler.FieldByName('ID').AsInteger>0 then begin
   if TreeListGecmisServisler.SelectionCount>0 then begin
      aindex := TreeListGecmisServisler.GetColumnByFieldName('ID').ItemIndex;
      if (TreeListGecmisServisler.Selections[0].values[aindex]<>null)and(TreeListGecmisServisler.Selections[0].values[aindex]>0) then begin
          Kaydet;
          ServisID:=StrToInt(VarToStr(TreeListGecmisServisler.Selections[0].values[aindex]));
          TabloAc;
          ServisPageControlChange(Self);
      end;
   end;
end;

procedure TServisWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TServisWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if (TabServis.FieldByName('ID').AsString<>'') then
     BoslukKontrolleri;
   Kaydet;
   if TabDetay.State in [dsInsert, dsEdit] then
      TabDetay.post;
   if EkleDetay then
      Ekle(TabDetay,TabNo_SERVIS,ServisID,'De?i?');
   IptalSecildi:=False;
   ModalResult := mrOk;
end;

procedure TServisWizardDlg.YeniSatirTusClick(Sender: TObject);
begin
   if TabServis.State in [dsInsert, dsEdit] then
      TabServis.Post;
//   if not TabServisKabul.Active then
//      TabServisAfterScroll(TabServis);
   if HizmetAraDlg = nil then
      Application.CreateForm(THizmetAraDlg, HizmetAraDlg);
   HizmetAraDlg.Tur := 19;
   //HizmetAraDlg.TabFatura := TabServisKabul;
   HizmetAraDlg.ShowModal;
end;

procedure TServisWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
   Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabNo_SERVISHAREKET);
   //Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger]);
   TabHareketlerAfterScroll( TabHareketler);
end;

procedure TServisWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TServisWizardDlg.DkmanSil1Click(Sender: TObject);
begin
   if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
       Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
       Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger]);
   end;
end;

procedure TServisWizardDlg.YorumEkleTusClick(Sender: TObject);
begin
   YorumEkleIslemi(TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger, TabYorum);
   //Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger]);
   TabHareketlerAfterScroll( TabHareketler);
end;

procedure TServisWizardDlg.YorumSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger, TabYorum);
end;

function TServisWizardDlg.ServisBoslukKontrolu: Boolean;
begin
  Result := True;
  if TabServis.State=dsEdit then begin
    if not BoslukKontrol(BeditKonusu.text, KontrolKonusu) then Abort;
    if not BoslukKontrol(ComboDURUM.text, KontrolDurum) then Abort;
    Result := False;
  end else
    Result := False;
end;

end.
















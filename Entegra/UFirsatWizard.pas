unit UFirsatWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, cxTrackBar,
  Dialogs, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxDropDownEdit,URehberAyar,
  StdCtrls, FireDAC.Comp.Client, cxMaskEdit, cxImageComboBox, cxLabel, cxTextEdit, ExtCtrls,
  cxContainer, cxMemo, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxDBTrackBar,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, UGorevDlg,
  ToolWin, JvWizard, JvExControls, cxDBEdit, cxCheckBox, cxSpinEdit, cxTimeEdit,
  cxCalendar, cxDBLabel, Menus, cxLookAndFeelPainters, cxCurrencyEdit, cxButtons,
  cxButtonEdit, dxSkinLondonLiquidSky, JvComponentBase, JvDragDrop, AppEvnts,
  UGentegreFrameYonetimi,UCariFonksiyonlar, cxGridCustomPopupMenu, cxGridPopupMenu,
  cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, cxGroupBox,
  cxLookAndFeels, cxNavigator, cxGridCustomLayoutView, cxPC, dxBarBuiltInMenu,
  dxSkinLiquidSky, OfficePopupMenu, cxTL, UKodAgaci, UTablo,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData, dxCore,
  cxDateUtils, frxClass, frxDBSet, cxRadioGroup, JvNavigationPane, Vcl.OleCtnrs,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxScrollbarAnnotations, dxDateRanges,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet;

type
  TFirsatWizardDlg = class(TForm)
    DtsFirsatlar: TDataSource;
    TabFirsatlar: TFDQuery;
    Panel1: TPanel;
    WizardKontrol: TJvWizard;
    ProjeEkr: TJvWizardInteriorPage;
    cxDBLabel2: TcxDBLabel;
    cxImageComboBox1: TcxImageComboBox;
    btnProje: TcxButton;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    JvDragDrop1: TJvDragDrop;
    ProjeEkDetayEkr: TJvWizardInteriorPage;
    ToolBar1: TToolBar;
    GridProjeDetay: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    SQLDetay: TcxMemo;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    btnDetay: TcxButton;
    lblMusteriAdres: TcxLabel;
    lblMusteriTel: TcxLabel;
    lblMusteriEposta: TcxLabel;
    TabSonAktivite: TFDQuery;
    dtsSonAktivite: TDataSource;
    cxDBLabel5: TcxDBLabel;
    cxLabel4: TcxLabel;
    ComboBolum: TcxDBComboBox;
    LabelSablon: TcxLabel;
    btnTarihce: TcxButton;
    ProjeTarihceEkr: TJvWizardInteriorPage;
    gridAktiviteTarihce: TcxGrid;
    tvAktiviteTarihce: TcxGridDBTableView;
    tvAktiviteTarihceEKLEMETARIHI: TcxGridDBColumn;
    tvAktiviteTarihceTUR: TcxGridDBColumn;
    tvAktiviteTarihceONCEKI: TcxGridDBColumn;
    tvAktiviteTarihceSONRAKI: TcxGridDBColumn;
    tvAktiviteTarihcePERSONEL: TcxGridDBColumn;
    gridAktiviteTarihceLevel1: TcxGridLevel;
    DtsProjeGecmis: TDataSource;
    TabProjeGecmis: TFDQuery;
    cxButton1: TcxButton;
    ProjebagTeklif: TJvWizardInteriorPage;
    ToolBar3: TToolBar;
    YeniTeklifGir: TToolButton;
    GridBagTeklif: TcxGrid;
    GridBagTeklifView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    TabBagTeklif: TFDQuery;
    DtsTabBagTeklif: TDataSource;
    GridBagTeklifViewTARIH: TcxGridDBColumn;
    GridBagTeklifViewTEKLIFNO: TcxGridDBColumn;
    GridBagTeklifViewFIRMA: TcxGridDBColumn;
    GridBagTeklifViewKONUSU: TcxGridDBColumn;
    GridBagTeklifViewKUR: TcxGridDBColumn;
    GridBagTeklifViewOLASILIK: TcxGridDBColumn;
    GridBagTeklifViewGECERLILIK_SURESI: TcxGridDBColumn;
    GridBagTeklifViewHAZIRLAYANAD: TcxGridDBColumn;
    GridBagTeklifViewTEKLIFTURU: TcxGridDBColumn;
    GridBagTeklifViewTEKLIFDURUMU: TcxGridDBColumn;
    GridBagTeklifViewTEKLIF_TUTARI: TcxGridDBColumn;
    DuzenleTeklif: TToolButton;
    PmKopyala: TPopupMenu;
    Kopyala1: TMenuItem;
    PanelZemin: TPanel;
    PanelUst: TPanel;
    ComboPRJ_TURU: TcxDBImageComboBox;
    DateBASLAMATARIHI: TcxDBDateEdit;
    ComboPRJ_KONUSU: TcxDBComboBox;
    ComboPRJ_DURUM: TcxDBImageComboBox;
    DateBITISTARIHI: TcxDBDateEdit;
    cxLabel11: TcxLabel;
    cxLabel20: TcxLabel;
    cxLabel22: TcxLabel;
    cxLabel26: TcxLabel;
    LabelTURU: TcxLabel;
    cxLabel23: TcxLabel;
    CurrencySATISFIYATI: TcxDBCurrencyEdit;
    ComboSATISKUR: TcxDBComboBox;
    ComboIlgili: TcxButtonEdit;
    cxDBLabel8: TcxDBLabel;
    cxLabel1: TcxLabel;
    EditProjeKodu: TcxDBButtonEdit;
    lbProjeTipi: TcxLabel;
    comboPRJ_TIPI: TcxDBImageComboBox;
    cxLabel8: TcxLabel;
    LabelIlgili: TcxLabel;
    cxLabel10: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    LabelCari: TcxLabel;
    TabMaliyet: TFDQuery;
    DtsMaliyet: TDataSource;
    EditSORUMLU: TcxButtonEdit;
    ComboOLASILIK: TcxDBImageComboBox;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    DtsCariListe: TDataSource;
    TabCariListe: TFDQuery;
    frxEkstre: TfrxDBDataset;
    frxProjeler: TfrxDBDataset;
    cxDBLabel1: TcxDBLabel;
    cxLabel13: TcxLabel;
    CheckTamam: TcxDBCheckBox;
    LabelPROJEKODU: TcxDBTextEdit;
    LabelSonTeklif: TcxLabel;
    SonTeklifTutari: TcxCurrencyEdit;
    LabelTeklifTarihi: TcxLabel;
    cxLabel6: TcxLabel;
    cxGridPopupMenu1: TcxGridPopupMenu;
    cxLabel3: TcxLabel;
    ComboSEBEBI: TcxDBImageComboBox;
    ButtonEditRakip: TcxDBButtonEdit;
    cxLabel12: TcxLabel;
    PageControlAlt: TcxPageControl;
    TabSheet1: TcxTabSheet;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    TabSheetLojistik: TcxTabSheet;
    ToolBar2: TToolBar;
    ButtonYeni: TToolButton;
    GridLojistik: TcxGrid;
    GridLojistikView: TcxGridDBTableView;
    cxGridLevel2: TcxGridLevel;
    ButtonKaydet: TToolButton;
    ButtonIptal: TToolButton;
    TabLojistik: TFDQuery;
    DtsLojistik: TDataSource;
    TabLojistikID: TAutoIncField;
    TabLojistikAKTIVITEID: TIntegerField;
    TabLojistikTIPI: TSmallintField;
    TabLojistikKAYNAKULKE: TSmallintField;
    TabLojistikKAYNAKLOKASYON: TSmallintField;
    TabLojistikHEDEFLOKASYON: TSmallintField;
    TabLojistikTARIH: TDateTimeField;
    TabLojistikACIKLAMA: TStringField;
    TabLojistikEKLEYEN: TIntegerField;
    TabLojistikEKLEMETARIHI: TDateTimeField;
    TabLojistikDEGISTIREN: TIntegerField;
    TabLojistikDEGISTIRMETARIHI: TDateTimeField;
    GridLojistikViewTIPI: TcxGridDBColumn;
    GridLojistikViewKAYNAKULKE: TcxGridDBColumn;
    GridLojistikViewKAYNAKLOKASYON: TcxGridDBColumn;
    GridLojistikViewHEDEFLOKASYON: TcxGridDBColumn;
    GridLojistikViewTARIH: TcxGridDBColumn;
    GridLojistikViewACIKLAMA: TcxGridDBColumn;
    ButtonSil: TToolButton;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    labelFileName: TcxLabel;
    TabLojistikKAYNAKULKEAD: TStringField;
    TabLojistikHEDEFULKEAD: TStringField;
    TabLojistikKAYNAKLOKASYONAD: TStringField;
    TabLojistikHEDEFLOKASYONAD: TStringField;
    TabLojistikTIPIAD: TStringField;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    CheckZenginMetin: TcxCheckBox;
    GridLojistikViewYUKLEME_YERI: TcxGridDBColumn;
    GridLojistikViewYUKLEME_LIMANI: TcxGridDBColumn;
    GridLojistikViewTAHLIYE_LIMANI: TcxGridDBColumn;
    GridLojistikViewBOSALTMA_YERI: TcxGridDBColumn;
    TabLojistikYUKLEME_YERI: TWideStringField;
    TabLojistikYUKLEME_LIMANI: TWideStringField;
    TabLojistikTAHLIYE_LIMANI: TWideStringField;
    TabLojistikBOSALTMA_YERI: TWideStringField;
    TabSheetAsama: TcxTabSheet;
    ToolBar5: TToolBar;
    BtnAsamaEkle: TToolButton;
    BtnAsamaSil: TToolButton;
    BtnAsamaKaydet: TToolButton;
    BtnAsamaIptal: TToolButton;
    TabProjeAsama: TFDQuery;
    TabProjeAsamaID: TAutoIncField;
    TabProjeAsamaPROJEID: TIntegerField;
    TabProjeAsamaREHBERID: TIntegerField;
    TabProjeAsamaTUR: TIntegerField;
    TabProjeAsamaASAMA: TIntegerField;
    TabProjeAsamaONAY: TBooleanField;
    TabProjeAsamaACIKLAMA: TWideStringField;
    TabProjeAsamaBASTAR: TDateTimeField;
    TabProjeAsamaBITTAR: TDateTimeField;
    TabProjeAsamaDURUM: TBooleanField;
    TabProjeAsamaAKTIF: TBooleanField;
    TabProjeAsamaEKLEYEN: TIntegerField;
    TabProjeAsamaEKLEMETARIHI: TDateTimeField;
    TabProjeAsamaDEGISTIREN: TIntegerField;
    TabProjeAsamaDEGISTIRMETARIHI: TDateTimeField;
    TabProjeAsamaSUBEID: TSmallintField;
    TabProjeAsamaASAMASORUMLUSU: TStringField;
    TabProjeAsamaSURE: TStringField;
    DtsProjeAsama: TDataSource;
    GridAsama: TcxGrid;
    GridAsamaView: TcxGridDBTableView;
    GridAsamaViewASAMA: TcxGridDBColumn;
    GridAsamaViewASAMASORUMLUSU: TcxGridDBColumn;
    GridAsamaViewACIKLAMA: TcxGridDBColumn;
    GridAsamaViewBASTAR: TcxGridDBColumn;
    GridAsamaViewBITTAR: TcxGridDBColumn;
    GridAsamaViewSURE: TcxGridDBColumn;
    GridAsamaViewONAY: TcxGridDBColumn;
    GridAsamaLevel1: TcxGridLevel;
    PmSagClick: TPopupMenu;
    AsamalariEkle: TMenuItem;
    TabSheetIsListesi: TcxTabSheet;
    Panel2: TPanel;
    ToolBar4: TToolBar;
    GorevEkleTus: TToolButton;
    GorevSilTus: TToolButton;
    ToolButton8: TToolButton;
    GorevDuzenleTus: TToolButton;
    JvNavPanelHeader1: TJvNavPanelHeader;
    CheckTamamlanan: TcxCheckBox;
    ComboTamamlanan: TcxImageComboBox;
    DtsGorevler: TDataSource;
    TabGorevler: TFDQuery;
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
    function EkranAdiAl: string;
    procedure FormShow(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabFirsatlarNewRecord(DataSet: TDataSet);
    procedure TabFirsatlarBeforePost(DataSet: TDataSet);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure ProjeEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure ComboIlgiliPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelTURUClick(Sender: TObject);
    procedure cxLabel24Click(Sender: TObject);
    procedure cxLabel19Click(Sender: TObject);
    procedure TabFirsatlarAfterPost(DataSet: TDataSet);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure ProjeEkDetayEkrPage(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure TabFirsatlarAfterScroll(DataSet: TDataSet);
    procedure LabelAdClick(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure LabelSablonClick(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure lbProjeTipiClick(Sender: TObject);
    procedure TabFirsatlarBeforeEdit(DataSet: TDataSet);
    procedure ProjeTarihceEkrPage(Sender: TObject);
    procedure ProjebagTeklifEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure YeniTeklifGirClick(Sender: TObject);
    procedure GridBagTeklifViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridBagTeklifViewDblClick(Sender: TObject);
    procedure DuzenleTeklifClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ProjeEkDetayEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure ComboPRJ_TURUPropertiesEditValueChanged(Sender: TObject);
    procedure TabDokumanBeforeOpen(DataSet: TDataSet);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditProjeAdiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditTEMSILCIPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxDBButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelSonTeklifClick(Sender: TObject);
    procedure btnProjeClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure cxDBDateEdit1PropertiesCloseUp(Sender: TObject);
    procedure comboPRJ_TIPIPropertiesCloseUp(Sender: TObject);
    procedure CheckTamamPropertiesEditValueChanged(Sender: TObject);
    procedure TabLojistikNewRecord(DataSet: TDataSet);
    procedure GridLojistikViewKAYNAKULKEPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridLojistikViewHEDEFKULKEPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ButtonYeniClick(Sender: TObject);
    procedure ButtonKaydetClick(Sender: TObject);
    procedure ButtonIptalClick(Sender: TObject);
    procedure ButtonSilClick(Sender: TObject);
    procedure TabLojistikCalcFields(DataSet: TDataSet);
    procedure GridLojistikViewKAYNAKLOKASYONPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure GridLojistikViewHEDEFLOKASYONPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure DtsLojistikStateChange(Sender: TObject);
    procedure GridLojistikViewHEDEFULKEPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridLojistikViewTIPIPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure AsamalariEkleClick(Sender: TObject);
    procedure BtnAsamaEkleClick(Sender: TObject);
    procedure BtnAsamaSilClick(Sender: TObject);
    procedure BtnAsamaKaydetClick(Sender: TObject);
    procedure BtnAsamaIptalClick(Sender: TObject);
    procedure DtsProjeAsamaStateChange(Sender: TObject);
    procedure GridAsamaViewASAMASORUMLUSUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabProjeAsamaNewRecord(DataSet: TDataSet);
    procedure TabProjeAsamaBeforeEdit(DataSet: TDataSet);
    procedure TabProjeAsamaCalcFields(DataSet: TDataSet);
    procedure GorevEkleTusClick(Sender: TObject);
    procedure GorevSilTusClick(Sender: TObject);
    procedure GorevDuzenleTusClick(Sender: TObject);
    procedure CheckTamamlananClick(Sender: TObject);
    procedure CheckTamamlananPropertiesEditValueChanged(Sender: TObject);
    procedure TreeListGorevDblClick(Sender: TObject);
    procedure TreeListGorevClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    GBaslamaTarih,GBitisTarih : TDateTime;
    ProjeSorumlusu:integer;
    KodAgaciMasrafDlg:TKodAgaciDlg;
    function ProjeBoslukKontrolu : Boolean;
    procedure FirmaBilgileri;
    procedure KodOlustur;
    procedure LojistikUlkeSec(Ulke : String);
    procedure LojistikLokasyonSec(UlkeNo:Integer; Merkez:string);
    procedure IsListesiTabloAc;
  public
    { Public declarations }
    IslemOp,Sontus : Char;//P:Proje A:Aktivite //// E:Ekleme D:D?zenleme
    ProjeID, RehberId : Integer;
    IslemTarih : TDateTime;
    ///Dok?man
    Yeri:  SmallInt;
    Yer_ID : Integer;

  end;

var
  FirsatWizardDlg: TFirsatWizardDlg;
  EkleDetay :boolean;
  firsatkoduretme: integer;


implementation

Uses  UAnaForm, UBinarySave, PrjConst, FetaKurulusSiniflari,FetaClassExtensions,
 UCombo,UGenelAnaSekmeFrame ,IdGlobalProtocols,LocOnFly, UExceldenVeriAl,
 cxTLExportLink, UFastRap, URaporAraclari, UIsListesi;

{$R *.dfm}
  var
  DYetkisonuc:DokumanYetkiSonuc;
  OncekiDurum : smallint;
{  TabProjeAsama.FieldByName('PROJEID').AsInteger := TabFirsatlar.FieldByName('ID').AsInteger;
  TabProjeAsama.FieldByName('BASTAR').AsDatetime := Tablo.GENINI.BugunTrhSaat;
  TabProjeAsama.FieldByName('AKTIF').AsBoolean := True;
  TabProjeAsama.FieldByName('DURUM').AsBoolean := True;
  TabProjeAsama.FieldByName('SUBEID').AsInteger := SubeID;
  TabProjeAsama.FieldByName('EKLEYEN').AsString:= Kullanan;}
procedure TFirsatWizardDlg.AsamalariEkleClick(Sender: TObject);
begin
  if TabFirsatlar.State=dsEdit then
     TabFirsatlar.Post;

  Tablo.TablodanSorguAc(1,'Select DEGER,SIRA from GENINI Where BOLUM='+inttoStr(Ops_Firsat_Asama)+' order by SIRA');
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO [PROJEASAMA]([PROJEID],[REHBERID],[ASAMA],[BASTAR],[DURUM],[AKTIF],[EKLEYEN],[SUBEID]) Values('+
     ''+TabFirsatlar.FieldByName('ID').AsString+','''+Kullanan+''','+Tablo.Query1.FieldByName('DEGER').AsString+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',  '+
     '1,1,'''+Kullanan+''','+IntToStr(SubeId)+' )',[],[]);

     Tablo.Query1.Next;
  end;
  TabloYenile(TabProjeAsama,[TabFirsatlar.FieldByName('ID').AsInteger]);
end;

procedure TFirsatWizardDlg.BtnAsamaEkleClick(Sender: TObject);
begin
  if TabFirsatlar.State in [dsInsert, dsEdit] then
     TabFirsatlar.Post;
  TabProjeAsama.Append;
end;

procedure TFirsatWizardDlg.BtnAsamaIptalClick(Sender: TObject);
begin
  TabProjeAsama.Cancel;
end;

procedure TFirsatWizardDlg.BtnAsamaKaydetClick(Sender: TObject);
begin
  TabProjeAsama.Post;
end;

procedure TFirsatWizardDlg.BtnAsamaSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabProjeAsama.Delete;
end;

procedure TFirsatWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
   if TabFirsatlar.State in [dsEdit,dsInsert] then
      TabFirsatlar.Post;
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_PROJELER, TabFirsatlar.FieldByName('ID').AsInteger, TabFirsatlar.FieldByName('REHBERID').AsInteger,TabYorum, CheckZenginMetin.Checked);
end;

procedure TFirsatWizardDlg.btnProjeClick(Sender: TObject);
begin
   if TabFirsatlar.State in [dsEdit,dsInsert] then
      TabFirsatlar.Post;
   WizardKontrol.ActivePageIndex := tcxButton(Sender).Tag;//WizardKontrol.Pages.IndexOf(DokumanEkr);
end;

procedure TFirsatWizardDlg.ButtonIptalClick(Sender: TObject);
begin
   TabLojistik.Cancel;
end;

procedure TFirsatWizardDlg.ButtonKaydetClick(Sender: TObject);
begin
    TabLojistik.Post;
end;

procedure TFirsatWizardDlg.ButtonSilClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabLojistik.Delete;
end;

procedure TFirsatWizardDlg.ButtonYeniClick(Sender: TObject);
begin
   if TabFirsatlar.State in [dsInsert, dsEdit] then
      TabFirsatlar.Post;
   TabLojistik.Append;
   //LojistikUlkeSec('KAYNAKULKE');
   //LojistikUlkeSec('HEDEFULKE');
end;

procedure TFirsatWizardDlg.CheckTamamlananClick(Sender: TObject);
begin
   ComboTamamlanan.Visible := CheckTamamlanan.Checked;
   if ComboTamamlanan.Visible  then
      ComboTamamlanan.ItemIndex:=4;
   IsListesiTabloAc
end;

procedure TFirsatWizardDlg.CheckTamamlananPropertiesEditValueChanged( Sender: TObject);
begin
   ComboTamamlanan.Visible := CheckTamamlanan.Checked;
   if ComboTamamlanan.Visible  then
      ComboTamamlanan.ItemIndex:=4;
   IsListesiTabloAc
end;

procedure TFirsatWizardDlg.CheckTamamPropertiesEditValueChanged(
  Sender: TObject);
begin
//   if TabFirsatlar.State in [dsEdit, dsInsert] then begin
    if (CheckTamam.Checked)and(TabFirsatlar.FieldByName('BITISTARIHI').Value = null) then begin
        TabFirsatlar.Edit;
        TabFirsatlar.FieldByName('BITISTARIHI').AsDateTime := Trunc(Tablo.GENINI.BugunTrh);
    end;
//   end;
end;

procedure TFirsatWizardDlg.ComboBolumPropertiesEditValueChanged(Sender: TObject);
var i:Integer;
begin
  if (TabDetay.Active)  then begin
    if TabDetay.State=dsEdit then
      TabDetay.Post;
    i:=0;
    if TabDetay.RecordCount>0 then begin
      TabDetay.First;
      while not TabDetay.Eof do begin
        if TabDetay.FieldByName('BILGI').AsString <>'' then
          Inc(i);
        TabDetay.Next;
      end;
    end;
    if (i>0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrNo) then begin
      TabFirsatlar.Cancel
    end else begin
      TabFirsatlar.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_PROJELER,ProjeID]);
      ProjeEkDetayEkrPage(Self);
    end;
  end;
end;

procedure TFirsatWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
begin
  if ComboBolum.Properties.Items.Count=0 then
     ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(TabNo_PROJELER)).Items;
end;

procedure TFirsatWizardDlg.ComboIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabFirsatlar);
end;

procedure TFirsatWizardDlg.comboPRJ_TIPIPropertiesCloseUp(Sender: TObject);
begin
   KodOlustur
end;

procedure TFirsatWizardDlg.ComboPRJ_TURUPropertiesEditValueChanged(Sender: TObject);
begin
   if ComboPRJ_TURU.ItemIndex>=0 then begin
      comboPRJ_TIPI.Tag := StrToInt(IntToStr(Ops_Firsat_Turu)+ IntToStr(ComboPRJ_TURU.ActiveProperties.Items[ComboPRJ_TURU.ItemIndex].Value));
      Tablo.GENINI.ReadImageSection(comboPRJ_TIPI.Tag,comboPRJ_TIPI.Properties.Items,True);
      KodOlustur;
    end;
end;

procedure TFirsatWizardDlg.cxDBButtonEdit1PropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var ID : Integer;
    s:String;
begin
   if not (TabFirsatlar.state in[dsEdit,dsInsert]) then
      TabFirsatlar.Edit;

   ID:=Tablo.RehberAra_IDGetir(0);
   s:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
   if Trim(TabFirsatlar.FieldByName('RAKIP').AsString)<>'' then
      TabFirsatlar.FieldByName('RAKIP').AsString:=TabFirsatlar.FieldByName('RAKIP').AsString+' \ ';
   TabFirsatlar.FieldByName('RAKIP').AsString := TabFirsatlar.FieldByName('RAKIP').AsString + ' '+ copy(s,1,pos(' ',s));
end;

procedure TFirsatWizardDlg.cxDBDateEdit1PropertiesCloseUp(Sender: TObject);
begin
   KodOlustur;
end;

procedure TFirsatWizardDlg.cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties,Sender);
end;

procedure TFirsatWizardDlg.LabelSablonClick(Sender: TObject);
begin
  if  trim(ComboBolum.Text) ='' then
   begin
     ShowMessage(cnst_SablonAdiBosOlamaz);
//     Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),pchar(Uyari), MB_OK+ MB_ICONWARNING);
     Abort;
   end;

  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := TabNo_PROJELER;
  RehberAyarDlg.Bolum := ComboBolum.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  ProjeEkDetayEkrPage(Self);
end;

procedure TFirsatWizardDlg.LabelSonTeklifClick(Sender: TObject);
var s:string;
begin
   if LabelSonTeklif.tag=0 then begin
       s:='TEKLIF_MATRAHI';
       LabelSonTeklif.Caption := 'Min.Teklif';
       LabelSonTeklif.tag:=1;
   end else begin
       s:='TARIH desc';
       LabelSonTeklif.Caption := 'Son Teklif';
       LabelSonTeklif.tag:=0;
   end;
   Tablo.TablodanSorguAc(1,'select top 1 TARIH, TEKLIF_MATRAHI,KUR from TEKLIF T where PROJEID = '+IntToStr(ProjeID)+' order by '+s);
   SonTeklifTutari.Value := Tablo.Query1.Fields[1].AsCurrency;
   SonTeklifTutari.Properties.DisplayFormat := ',0.00 '+Tablo.Query1.Fields[2].AsString+';(,0.00 '+Tablo.Query1.Fields[2].AsString+')';
   if Tablo.Query1.Fields[0].AsDateTime > StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2000') then
      LabelTeklifTarihi.Caption := FormatDateTime('dd/mm/yyyy', Tablo.Query1.Fields[0].AsDateTime);
end;

procedure TFirsatWizardDlg.cxLabel19Click(Sender: TObject);
var ID : Integer;
begin
   {ID := Tablo.RehberSihirbazBaslat(0, -100, -100,StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
   if ID > 0 then begin
      TabFirsatlar.Edit;
      TabFirsatlar.FieldByName('PRJ_ASAMA_SORUMLUSU_ID').AsInteger := ID;
      ComboAsamaSorumlu.Text := Tablo.AciklamaGetir('REHBER','FIRMA', ID);
   end;}
end;

procedure TFirsatWizardDlg.cxLabel24Click(Sender: TObject);
var ID : Integer;
begin
   {ID := Tablo.RehberSihirbazBaslat(0, -100, -100,StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
   if ID > 0 then begin
      TabFirsatlar.Edit;
      TabFirsatlar.FieldByName('PRJ_SORUMLUSU_ID').AsInteger := ID;
      ComboPrjSorumlu.Text := Tablo.AciklamaGetir('REHBER','FIRMA', ID);
   end;}

end;

procedure TFirsatWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TFirsatWizardDlg.DkmanSil1Click(Sender: TObject);
begin
if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_projeler,TabFirsatlar.FieldByName('ID').AsInteger]);
  end;
end;

procedure TFirsatWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
                 TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabFirsatlar.FieldByName('REHBERID').AsInteger)

end;

procedure TFirsatWizardDlg.DtsLojistikStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsLojistik, ButtonYeni, ButtonSil, ButtonKaydet, ButtonIptal);
end;

procedure TFirsatWizardDlg.DtsProjeAsamaStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsProjeAsama,BtnAsamaEkle,BtnAsamaSil,BtnAsamaKaydet,BtnAsamaIptal);
end;

procedure TFirsatWizardDlg.EditProjeAdiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var st : Tstringlist;
begin
   if not (TabFirsatlar.state in[dsEdit,dsInsert]) then
     TabFirsatlar.Edit;
  if AButtonIndex = 0  then begin
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir('Proje Ad? Se?imi','select distinct AD=isnull(PROJEADI,'''') from PROJELER where isnull(PROJEADI,'''') like ''%<ara>%'' order by 1',st,[]) then begin
      TabFirsatlar.FieldByName('PROJEADI').Value := st[0];
    end;
    FreeAndNil(st);
  end else if AButtonIndex = 1 then begin
    TabFirsatlar.FieldByName('PROJEADI').Value := '';
  end;
end;

procedure TFirsatWizardDlg.KodOlustur;
var
 projekod, ad : string;
 GroupOtomatikKod : smallint;
 function KelimeGetir(s:string):string;
 begin
   if Pos(' ', s)>0 then
      result := Copy(ad, 1, Pos(' ', s)-1)
   else
      result := s;
 end;
begin
   if Firsatkoduretme=0 then exit;

   GroupOtomatikKod := Tablo.GENINI.ReadInteger(Ops_GroupOtomatikKod,0);
   ad := labelAd.Caption;
   if not (TabFirsatlar.state in[dsEdit,dsInsert]) then
      TabFirsatlar.Edit;

   projekod := KelimeGetir(ad);
   if GroupOtomatikKod=1 then begin
      if Pos(' ', ad)>0 then begin
         ad := trim(copy(ad, Pos(' ', ad), 1500));
         projekod := projekod +' '+ KelimeGetir(ad);
      end;
   end;

   projekod:= projekod+'-'+FormatDateTime('ddmmyyyy',DateBASLAMATARIHI.Date)+'-'+ComboPRJ_TURU.Text+'('+comboPRJ_TIPI.Text+')';

   TabFirsatlar.FieldByName('PROJEKODU').Value :=  projekod;
end;

procedure TFirsatWizardDlg.EditTEMSILCIPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
begin
   tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabFirsatlar, 'PRJ_SORUMLUSU_ID')
  {if AButtonIndex = 0 then
     tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabFirsatlar, 'PRJ_SORUMLUSU_ID')
  else if AButtonIndex = 1 then begin
     TabFirsatlar.Edit;
     TabFirsatlar.FieldByName('PRJ_SORUMLUSU_ID').AsInteger := 0;
     EditSORUMLU.text := '';
  end;}
end;

procedure TFirsatWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if  (Sontus='I') and ((IslemOp='E') or (IslemOp='K'))  then begin //e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
      if (TabFirsatlar.active)and(TabFirsatlar.Fields[0].AsString <> '')  then begin
        //varsa dokumanlar?n silinmeli
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_PROJELER, Yer_ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMAN where MODUL = &TabNo AND MODULID = &Modulid ',['&TabNo', '&Modulid'],[TabNo_PROJELER, TabFirsatlar.FieldByName('ID').AsInteger]);
        //varsa proje ba?lant?lar? silinmeli
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update AKTIVITELER set PROJEID=-1   where PROJEID ='+TabFirsatlar.FieldByName('ID').AsString,[],[]);
        //sonra kendi silinir
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PROJELER where ID=&Id ',['&Id'], [TabFirsatlar.FieldByName('ID').AsInteger]);
      end;
   end;
end;

procedure TFirsatWizardDlg.FormCreate(Sender: TObject);
begin

   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
   Tablo.GridTurkcelestir;
   Tablo.GridAyarRestore('ProjeTeklifGridi',GridBagTeklifView );
   Sontus:='I';
   RehberId := -1;
   LogID:=0;
   //DokumanTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\ProjeDokumanGridi',true,false,[gsoUseFilter],'ProjeDokumanGridi');
   Tablo.GridAyarRestore('ProjeTeklifGridi',GridBagTeklifView );


   Firsatkoduretme := Tablo.GENINI.ReadInteger(Ops_FirsatOpsiyon_ProjeKoduUretme, 1); //    ProjeOpsiyon', 'ProjeKoduUretme', 1);
   LabelPROJEKODU.Properties.ReadOnly := Firsatkoduretme<>0;


   if Tablo.GENINI.ReadBoolean(Ops_FirsatOpsiyon_IsListesiSekme, False)=False then
      TabSheetIsListesi.destroy;
   if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_LojistikSekme, False)=False then
      TabSheetLojistik.destroy;
   if Tablo.GENINI.ReadBoolean(Ops_FirsatOpsiyon_AsamaSekme, False)=False then
      TabSheetAsama.Destroy;

{   TabSheetLojistik.TabVisible := Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_LojistikSekme, False);
   TabSheetLojistik.Visible := TabSheetLojistik.TabVisible;
   TabSheetAsama.TabVisible :=  Tablo.GENINI.ReadBoolean(Ops_FirsatOpsiyon_AsamaSekme, False);
   TabSheetAsama.Visible := TabSheetAsama.TabVisible; }
end;

procedure TFirsatWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos :=Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bile?en Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name), TFirsatWizardDlg(Self),DtsFirsatlar);
    end;
  end
  else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bile?en D?zenle
//    ctrl := FindVCLWindow(Mouse.CursorPos);
//    if Assigned(ctrl) then begin
//      OutputDebugString(PChar(ctrl.Name));
//      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

//      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);

      Tablo.AlanlarDlgBaslat('D',1,0,ctrlPos.X,ctrlPos.Y,0,FindComponent(PanelUst.Name), TFirsatWizardDlg(Self),DtsFirsatlar);
      Tablo.AlanOlustur(TFirsatWizardDlg(Self), -1,DtsFirsatlar);
//    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('S')) then  begin  //Bile?en Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
     if ctrl.Name <> '' then begin
       Tablo.TablodanSorguAc(1,'Select CAPTION,ALANADI,TAG,TABLO from ALANLAR Where TAG='+IntToStr(ctrl.Tag)+'  ');
       if Application.MessageBox(PChar(Tablo.Query1.FieldByName('CAPTION').AsString+' alan?n? silmek istiyor musunuz ?'),'UYARI',MB_YESNO)=mrYes then  begin

           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from ALANLAR Where TAG ='+IntToStr(ctrl.Tag)+' ',[],[]);
         try
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Alter table '+Tablo.Query1.FieldByName('TABLO').AsString+' drop column '+Tablo.Query1.FieldByName('ALANADI').AsString+' ',[],[]);
         except
         end;
           ctrl.Visible := False;
           //Tablo.AlanOlustur(FindComponent(PanelAlan.Name),TFirsatWizardDlg(Self),-1,DtsFirsatlar);
           Tablo.AlanOlustur(TFirsatWizardDlg(Self),-1,DtsFirsatlar);
       end;
     end;
    end;
  end;

end;

procedure TFirsatWizardDlg.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 ');
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  lblMusteriAdres.Caption:= Adres+ Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+' '+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+' / '+Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  lblMusteriTel.Caption:= isTel+Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
  lblMusteriEposta.Caption:= EPosta+Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TFirsatWizardDlg.IsListesiTabloAc;
var AcKapa:String[1];
    GunSay : Smallint;
begin
        AcKapa:=IntToStr(Abs(StrToInt(BoolToStr(CheckTamamlanan.Checked))));
        if CheckTamamlanan.Checked then
           GunSay := ComboTamamlanan.EditValue
        else
           GunSay := 9999;
        TabloYenile(TabGorevler,[Kullanan, AcKapa,  GunSay, TabFirsatlar.Fields[0].AsInteger]);
end;

procedure TFirsatWizardDlg.FormShow(Sender: TObject);
var
  EskiProjeID,i:Integer;
  aktifFrame: TGenelAnaSekmeFrame;
  ra:string;
begin
  EkleDetay := False;
  FirmaBilgileri;

  //Tablo.ProjeInit(ComboPRJ_TURU.Properties,ComboPRJ_ASAMA.Properties,ComboPRJ_DURUM.Properties,ComboLISTEKUR.Properties,ComboSATISKUR.Properties);
  Tabloyenile(TabFirsatlar, [ProjeID]);
    //imgComboboxlar? sola yasla
   ComboPRJ_DURUM.RepositoryItem.Properties.Alignment.Horz:=taLeftJustify;
   ComboPRJ_TURU.RepositoryItem.Properties.Alignment.Horz:=taLeftJustify;
   //cbAplikasyon.RepositoryItem.Properties.Alignment.Horz:=taLeftJustify;
   //ComboPRJ_DURUM.RepositoryItem.Properties.Alignment.Horz:=taLeftJustify;
   comboPRJ_TIPI.Properties.Alignment.Horz:=taLeftJustify;
   //comboProjeSonuc.RepositoryItem.Properties.Alignment.Horz:=taLeftJustify;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  //lblDegistirenKullanici.Caption:= Tablo.repGenelPersonelListesi.Properties.GetDisplayText(TabFirsatlar.FieldByName('DEGISTIREN').AsInteger,True);
 // groupProjeSonAktivite.Visible:= IslemOp='D';

//  Tablo.AlanOlustur(PanelAlan,TFirsatWizardDlg(Self), -1,DtsFirsatlar);
  Tablo.AlanOlustur(TFirsatWizardDlg(Self), -1,DtsFirsatlar);

  //Admin de?il ise  RolId = -1 ise y?netici demektir..  Yetkili ya da sorumlu de?ilse ?ablonu g?remesin
   if (RolId<>'-1')and(TabFirsatlar.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
       LabelSablon.Visible := False;
       ComboBolum.Visible := False;
   end;

   if not SubeVarmi then begin
     LblSube.Visible:=False;
     ComboSube.Visible:=False;
   end else begin //?ube yetkileri ayarlan?r
      (ComboSube.Properties.Items as  TcxImageComboBoxItems).Clear;
      for I := 1 to tablo.RepSubelerOrtakTumSubeler.Properties.Items.Count - 1 do begin
        if tablo.YetkiVarmi(StrToInt('2198'+IntToStr(strtoint(vartostr(tablo.RepSubelerOrtakTumSubeler.Properties.Items[i].Value))*(-1))),YetkiTur_Gorme,False) then
          with (ComboSube.Properties.Items as  TcxImageComboBoxItems).add do begin
             Description := tablo.RepSubelerOrtakTumSubeler.Properties.Items[i].Description;
             Value := tablo.RepSubelerOrtakTumSubeler.Properties.Items[i].Value;
          end;
      end;
   end;

  case IslemOp of
  'E': begin //Ekleme
         Yer_ID := -1;
         TabFirsatlar.Append;
       end;
  'D', 'K': begin //De?i?tirme
         //TabFirsatlar.Locate('ID', ProjeID,[]);
         if TabFirsatlar.FieldByName('ILGILI').AsString<>'' then
            ComboIlgili.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabFirsatlar.FieldByName('ILGILI').AsString);
         Yer_ID := TabFirsatlar.Fields[0].AsInteger;
         //son teklif
         LabelSonTeklifClick(self);
       end;
  end;
 ///Dok?man
 // Yeri := 41;
   ProjeID := TabFirsatlar.Fields[0].AsInteger;
   Tabloyenile(TabYorum,[Tabno_Projeler, ProjeID]);
   EditSORUMLU.text := tablo.AciklamaGetir('REHBER', 'FIRMA',TabFirsatlar.FieldByName('PRJ_SORUMLUSU_ID').AsString);
   GBaslamaTarih:=TabFirsatlar.FieldByName('BASLAMATARIHI').AsDateTime;
   GBitisTarih:=TabFirsatlar.FieldByName('BITISTARIHI').AsDateTime;
   ProjeSorumlusu:=TabFirsatlar.FieldByName('PRJ_SORUMLUSU_ID').AsInteger;
   OncekiDurum := TabFirsatlar.FieldByName('DURUM').AsInteger;
   if TabFirsatlar.FieldByName('CARIID').AsString <> '' then
      LabelCari.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabFirsatlar.FieldByName('CARIID').AsInteger);

   if (TabSheetIsListesi<>nil)and(TabSheetIsListesi.TabVisible) then
      IsListesiTabloAc;
   if (TabSheetLojistik<>nil)and(TabSheetLojistik.TabVisible) then
      TabloYenile(TabLojistik,[TabFirsatlar.FieldByName('ID').AsInteger]);
   if (TabSheetAsama<>nil)and(TabSheetAsama.TabVisible) then
      TabloYenile(TabProjeAsama,[TabFirsatlar.FieldByName('ID').AsInteger]);

   PageControlAlt.ActivePageIndex := 0;
   PageControlAlt.SelectNextPage(True);
   PageControlAlt.ActivePageIndex := 0;
 end;

procedure TFirsatWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TFirsatWizardDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TFirsatWizardDlg.LojistikUlkeSec(Ulke : String);
var
   st: Tstringlist;
   Eski : smallint;
begin

   Eski := TabLojistik.FieldByName(Ulke).AsInteger;
   st := Tstringlist.Create;
   if tablo.ListedenBilgiGetir(UlkeListesi,
       'select ILNO, ILADI from ILILCE where ILNO>99 and ILADI like ''%<ara>%'' ORDER BY ILADI ', st, []) then begin
      TabLojistik.Edit;
      TabLojistik.FieldByName(Ulke).value := st.Strings[0];
   end;
   st.free;
  { if Eski <> TabLojistik.FieldByName(Ulke).Value then begin
      TabLojistik.FieldByName('KAYNAKLOKASYON').AsString := '';
      TabLojistik.FieldByName('HEDEFLOKASYON').AsString := '';
   end; }
end;

procedure TFirsatWizardDlg.LojistikLokasyonSec(UlkeNo:Integer; Merkez:string);
var
   st: Tstringlist;
begin
   st := Tstringlist.Create;
   if tablo.ListedenBilgiGetir(UlkeListesi,
       'select ID, MERKEZ from LOJISTIKMERKEZ where TIPI='+TabLojistik.FieldByName('TIPI').AsString+' and ULKENO='+IntToStr(UlkeNo)+' and MERKEZ like ''%<ara>%'' ORDER BY MERKEZ ', st, []) then begin
      TabLojistik.Edit;
      TabLojistik.FieldByName(Merkez).Value := st.Strings[0];
   end;
   st.free;
end;

procedure TFirsatWizardDlg.GridLojistikViewHEDEFKULKEPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  LojistikUlkeSec('HEDEFULKE');
  LojistikLokasyonSec(TabLojistik.FieldByName('HEDEFULKE').AsInteger, 'HEDEFLOKASYON');
end;

procedure TFirsatWizardDlg.GridLojistikViewHEDEFLOKASYONPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   LojistikLokasyonSec(TabLojistik.FieldByName('HEDEFULKE').AsInteger, 'HEDEFLOKASYON');
end;

procedure TFirsatWizardDlg.GridLojistikViewHEDEFULKEPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   LojistikUlkeSec('HEDEFULKE');
   LojistikLokasyonSec(TabLojistik.FieldByName('HEDEFULKE').AsInteger, 'HEDEFLOKASYON');
end;

procedure TFirsatWizardDlg.GridLojistikViewKAYNAKLOKASYONPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   LojistikLokasyonSec(TabLojistik.FieldByName('KAYNAKULKE').AsInteger, 'KAYNAKLOKASYON');
end;

procedure TFirsatWizardDlg.GridLojistikViewKAYNAKULKEPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   LojistikUlkeSec('KAYNAKULKE');
   LojistikLokasyonSec(TabLojistik.FieldByName('KAYNAKULKE').AsInteger, 'KAYNAKLOKASYON');
end;

procedure TFirsatWizardDlg.GridLojistikViewTIPIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
   st: Tstringlist;
   Eski : integer;
begin
   Eski := TabLojistik.FieldByName('TIPI').Value;
   st := Tstringlist.Create;
   if tablo.ListedenBilgiGetir(UlkeListesi,
       'select DEGER, ANAHTAR from GENINI where BOLUM=-2121 ', st, []) then begin
      TabLojistik.Edit;
      TabLojistik.FieldByName('TIPI').Value := st.Strings[0];
   end;
   st.free;

   if Eski <> TabLojistik.FieldByName('TIPI').Value then begin
      TabLojistik.FieldByName('KAYNAKLOKASYON').AsString := '';
      TabLojistik.FieldByName('HEDEFLOKASYON').AsString := '';
   end;
end;

procedure TFirsatWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabNo_GOREVLER);
end;

procedure TFirsatWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TFirsatWizardDlg.LabelAdClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(0,TabFirsatlar.FieldByName('REHBERID').AsInteger,-100,-100, False);
end;


procedure TFirsatWizardDlg.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
   Id := Tablo.RehberAra_IDGetir(-99, True);
   if Id>0 then begin
      RehberId := Id;
      if TabFirsatlar.State = dsBrowse then
         TabFirsatlar.Edit;
      TabFirsatlar.FieldByName('REHBERID').AsInteger := RehberId;
       ComboILGILI.Text := '';
      TabFirsatlar.FieldByName('ILGILI').AsInteger  := -1;
      FirmaBilgileri;
      KodOlustur;
   end;
end;

procedure TFirsatWizardDlg.LabelTURUClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TFirsatWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TFirsatWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_projeler, TabFirsatlar.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TFirsatWizardDlg.ProjebagTeklifEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   TabBagTeklif.SQL.Text := 'select T.ID,TARIH,TEKLIFNO,T.TEKLIF_MATRAHI,T.KDV_TUTARI,T.DURUM,TURU,T.REHBERID,R1.FIRMA, KONUSU, TEKLIF_TUTARI,KUR, '+
     ' OLASILIK,GECERLILIK_SURESI,HAZIRLAYAN,R2.FIRMA as HAZIRLAYANAD,MUS_ILGILI,RP.FIRMA as MUS_ILGILIAD, '+
     ' T.TESLIM_SEKLI,T.ODEME from TEKLIF T '+
     ' left outer join REHBER R1 on R1.ID=T.REHBERID '+
     ' inner join REHBER R2 on R2.ID=T.HAZIRLAYAN '+
     ' left outer join REHBER RP on RP.ID=T.MUS_ILGILI '+
     ' where PROJEID = '+TabFirsatlar.FieldByName('ID').AsString;
   if SubeVarmi then
      TabBagTeklif.SQL.Add(' and T.SUBEID in('+Tablo.YetkiliSubeleriGetir(29,YetkiTur_Gorme)+') ');
   TabloYenile(TabBagTeklif,[]);
end;

function TFirsatWizardDlg.ProjeBoslukKontrolu: Boolean;
begin
   ProjeBoslukKontrolu := True;
   if not BoslukKontrol(ComboPRJ_TURU.text, KontrolTuru) then Abort;
   if not BoslukKontrol(ComboPRJ_KONUSU.text, KontrolKonusu) then Abort;
   //if not BoslukKontrol(ComboPrjSorumlu.text, KontrolSorumlu) then Abort;
   //if not BoslukKontrol(ComboAsamaSorumlu.text, KontrolAsamaSorumlusu) then Abort;
   //if not BoslukKontrol(ComboPRJ_DURUM.text, KontrolDurum) then Abort;
   if not BoslukKontrol(ComboPRJ_DURUM.text, KontrolDurumu) then Abort;
   ProjeBoslukKontrolu := False;
end;

procedure TFirsatWizardDlg.ProjeEkDetayEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   if EkleDetay then
     Ekle(TabDetay,TabNo_PROJELER,ProjeID,'De?i?');
end;

procedure TFirsatWizardDlg.ProjeEkDetayEkrPage(Sender: TObject);
begin
    TabDetay.Close;
    TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    TabloYenile(TabDetay, [TabNo_PROJELER,ProjeID,ComboBolum.Text]);
    if TabDetay.Active then
    begin
      if TabDetay.FindField('ORJINAL') <> nil then
        TabDetay.FieldByName('ORJINAL').ReadOnly := True;
      if TabDetay.FindField('GIRIS') <> nil then
        TabDetay.FieldByName('GIRIS').ProviderFlags := [];
      if TabDetay.FindField('KAYNAK') <> nil then
        TabDetay.FieldByName('KAYNAK').ProviderFlags := [];
      if TabDetay.FindField('ZORUNLU') <> nil then
        TabDetay.FieldByName('ZORUNLU').ProviderFlags := [];
      if TabDetay.FindField('ORJINAL') <> nil then
        TabDetay.FieldByName('ORJINAL').ProviderFlags := [];
      // Boş BILGI değerlerini Null yap - tarih editöründe '' hatası önlenir
      TabDetay.DisableControls;
      try
        TabDetay.First;
        while not TabDetay.Eof do
        begin
          if Trim(TabDetay.FieldByName('BILGI').AsString) = '' then
          begin
            TabDetay.Edit;
            TabDetay.FieldByName('BILGI').Clear;
            TabDetay.Post;
          end;
          TabDetay.Next;
        end;
        TabDetay.First;
      finally
        TabDetay.EnableControls;
      end;
    end;
end;

procedure TFirsatWizardDlg.ProjeEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
   Stop := ProjeBoslukKontrolu;
   if (IslemOp='E')and(TabFirsatlar.State = dsInsert) then begin
      TabFirsatlar.Post;
      ProjeID := TabFirsatlar.Fields[0].AsInteger;
      RehberId := TabFirsatlar.FieldByName('REHBERID').AsInteger;
      Yer_ID := ProjeID;
   end;
end;

procedure TFirsatWizardDlg.ProjeTarihceEkrPage(Sender: TObject);
begin
   TabloYenile(TabProjeGecmis, [ProjeID]);
end;

function TFirsatWizardDlg.EkranAdiAl: string;
begin
   Result := 'ProjeWizard';
end;

procedure TFirsatWizardDlg.TabFirsatlarAfterPost(DataSet: TDataSet);
begin
   ProjeID := TabFirsatlar.Fields[0].AsInteger;
   if islemOp='D' then
      Tablo.LogIslemleri(TabNo_PROJELER,ProjeID, 4, TabFirsatlar);
end;

procedure TFirsatWizardDlg.TabFirsatlarAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabSonAktivite,[TabFirsatlar.FieldByName('ID').AsInteger]);
end;

procedure TFirsatWizardDlg.TabFirsatlarBeforeEdit(DataSet: TDataSet);
begin
      //Admin de?il ise  RolId = -1 ise y?netici demektir..
   if (RolId<>'-1')and(TabFirsatlar.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
       Application.MessageBox(PChar(AWSorumluHaricindeDegisYapilmaz), PChar(Uyari), MB_OK + MB_ICONERROR);
       Abort;
   end;
   if LogGun>0 then
      Tablo.OncekiLogBelirle(TabFirsatlar);
end;

procedure TFirsatWizardDlg.TabFirsatlarBeforePost(DataSet: TDataSet);
begin
{  if (TabFirsatlar.FieldByName('DURUM').AsBoolean=True) and (TabFirsatlar.FieldByName('SONUC').AsString='') then
   begin
     ShowMessage(PWSonucBilgisiGir);
     abort;
   end;}
  ProjeBoslukKontrolu;
  if (CheckTamam.checked)and(TabFirsatlar.FieldByName('BITISTARIHI').AsDateTime < TabFirsatlar.FieldByName('BASLAMATARIHI').AsDateTime) then
   begin
     ShowMessage(PWBitRarihKucukSecilemez);
     abort;
   end;
  if (TabFirsatlar.FieldByName('LISTEFIYATI').AsCurrency>0) and (TabFirsatlar.FieldByName('LISTEKUR').AsString='') then
   begin
     ShowMessage(PWListefiyatiKurBilgisiGir);
     abort;
   end;
  if (TabFirsatlar.FieldByName('SATISFIYATI').AsCurrency>0) and (TabFirsatlar.FieldByName('SATISKUR').AsString='') then
   begin
     ShowMessage(PWSatisFiyatiKurBilgisiGir);
     abort;
   end;
  if IslemOp = 'D' then
     Tablo.ProjeTarihceEkle(TabFirsatlar);
  EkleyenDegistiren(DtsFirsatlar);
end;

procedure TFirsatWizardDlg.TabFirsatlarNewRecord(DataSet: TDataSet);
begin
  //TabFirsatlar.FieldByName('FIRMAKOD').AsString := AraQuery1.FieldByname('KOD').AsString;
  TabFirsatlar.FieldByName('MODUL').AsInteger := 1;
  TabFirsatlar.FieldByName('REHBERID').AsInteger := RehberId;
  TabFirsatlar.FieldByName('BASLAMATARIHI').AsDateTime := Trunc(IslemTarih);

  ComboSATISKUR.ItemIndex  := 0;
  //ComboKAYIPKUR.ItemIndex := 0;
  TabFirsatlar.FieldByName('PRJ_SORUMLUSU_ID').AsString := Kullanan;
  //ComboPrjSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Kullanan);

//  TabFirsatlar.FieldByName('HABER_BEKLENIYOR').Asboolean := False;
//  TabFirsatlar.FieldByName('PLAN').Asboolean := False;
  TabFirsatlar.FieldByName('DURUM').AsInteger := 1;
  TabFirsatlar.FieldByName('ASAMA').AsInteger := 1;
  TabFirsatlar.FieldByName('EKLEYEN').AsString := Kullanan;

  if SubeVarmi then begin
     case Tablo.GENINI.ReadInteger(Ops_OpsiyonProje_GorunecekSubeler,0) of
       0 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtak;
       1 : ComboSube.RepositoryItem := Tablo.RepSubelerKendiSubesi;
       2 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakKendiSubesi;
       3 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakTumSubeler;
     end;
  end;
  case Tablo.GENINI.ReadInteger(Ops_OpsiyonProje_GorunecekSubeler,0) of
   0,2,3 : TabFirsatlar.FieldByName('SUBEID').AsInteger  := 0;
   1 : TabFirsatlar.FieldByName('SUBEID').AsInteger  := SubeID;
  end;
end;


procedure TFirsatWizardDlg.TabLojistikCalcFields(DataSet: TDataSet);
begin
  if TabLojistik.Active=False then
     exit;

   if TabLojistik.FieldByName('TIPI').AsString <> '' then begin
      Tablo.TablodanSorguAc(1,'select ANAHTAR from GENINI where BOLUM=-2121 and DEGER = '+TabLojistik.FieldByName('TIPI').AsString);
      TabLojistik.FieldByName('TIPIAD').AsString := Tablo.Query1.Fields[0].AsString;
   end;
   if TabLojistik.FieldByName('KAYNAKULKE').AsString <> '' then begin
      Tablo.TablodanSorguAc(1,'select ILADI from ILILCE where ILNO= '+TabLojistik.FieldByName('KAYNAKULKE').AsString);
      TabLojistik.FieldByName('KAYNAKULKEAD').AsString := Tablo.Query1.Fields[0].AsString;
   end;
   if TabLojistik.FieldByName('HEDEFULKE').AsString <> '' then begin
      Tablo.TablodanSorguAc(1,'select ILADI from ILILCE where ILNO= '+TabLojistik.FieldByName('HEDEFULKE').AsString);
      TabLojistik.FieldByName('HEDEFULKEAD').AsString := Tablo.Query1.Fields[0].AsString;
   end;
   if TabLojistik.FieldByName('KAYNAKLOKASYON').AsString <> '' then begin
      Tablo.TablodanSorguAc(1,'select MERKEZ from LOJISTIKMERKEZ where ID= '+TabLojistik.FieldByName('KAYNAKLOKASYON').AsString);
      TabLojistik.FieldByName('KAYNAKLOKASYONAD').AsString := Tablo.Query1.Fields[0].AsString;
   end;
   if TabLojistik.FieldByName('HEDEFLOKASYON').AsString <> '' then begin
      Tablo.TablodanSorguAc(1,'select MERKEZ from LOJISTIKMERKEZ where ID= '+TabLojistik.FieldByName('HEDEFLOKASYON').AsString);
      TabLojistik.FieldByName('HEDEFLOKASYONAD').AsString := Tablo.Query1.Fields[0].AsString;
   end;


end;

procedure TFirsatWizardDlg.TabLojistikNewRecord(DataSet: TDataSet);
begin
   TabLojistik.FieldByName('AKTIVITEID').AsInteger := TabFirsatlar.FieldByName('ID').AsInteger;
   TabLojistik.FieldByName('TIPI').AsInteger := 1;
end;

procedure TFirsatWizardDlg.TabProjeAsamaBeforeEdit(DataSet: TDataSet);
begin
//   TabProjeAsama.Edit;
//   TabProjeAsama.FieldByName('DEGISTIREN').AsString:= Kullanan;
//   TabProjeAsama.FieldByName('DEGISTIRMETARIHI').AsDateTime:= Tablo.GENINI.BugunTrhSaat;
end;

procedure TFirsatWizardDlg.TabProjeAsamaCalcFields(DataSet: TDataSet);
begin
   if TabProjeAsama.FieldByName('REHBERID').AsString<> '' then begin
       Tablo.TablodanSorguAc(1, 'select FIRMA from REHBER where ID='+TabProjeAsama.FieldByName('REHBERID').AsString);
       if Tablo.Query1.RecordCount>0 then
          TabProjeAsama.FieldByName('ASAMASORUMLUSU').AsString := Tablo.Query1.Fields[0].AsString
       else
          TabProjeAsama.FieldByName('ASAMASORUMLUSU').AsString := '';
   end;
{   Tablo.TablodanSorguAc(1, 'SELECT [dbo].[fn_TarihFarkiFormatli]('''+FormatDateTime('yyyy-mm-dd hh:nn',TabProjeAsama.FieldByName('BASTAR').AsDateTime)+''','''+
                             FormatDateTime('yyyy-mm-dd hh:nn',TabProjeAsama.FieldByName('BITTAR').AsDateTime)+''')');
   TabProjeAsama.FieldByName('SURE').AsString := Tablo.Query1.fields[0].asstring;   }
end;

procedure TFirsatWizardDlg.TabProjeAsamaNewRecord(DataSet: TDataSet);
begin
  TabProjeAsama.FieldByName('PROJEID').AsInteger := TabFirsatlar.FieldByName('ID').AsInteger;
  TabProjeAsama.FieldByName('BASTAR').AsDatetime := Tablo.GENINI.BugunTrhSaat;
  TabProjeAsama.FieldByName('AKTIF').AsBoolean := True;
  TabProjeAsama.FieldByName('DURUM').AsBoolean := True;
  TabProjeAsama.FieldByName('EKLEYEN').AsString:= Kullanan;
end;

procedure TFirsatWizardDlg.TreeListGorevClick(Sender: TObject);
var   TreeHitTest: TcxTreeListHitTest;
begin
   TreeHitTest := (Sender as TcxDBTreeList).HitTest;
   if not TreeHitTest.HitAtColumn  then // soldaki + alt seviye a?ma tu?una bast???nda a?ma/kapatma yapmas?n diye
        exit;

   if TcxDBTreeList(Sender).FocusedColumn.tag=1 then begin
      UpdateveMail(MasaUstu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, TcxDBTreeList(Sender).FocusedNode.HasChildren);
      PlayWavFromResource('Blink');
      IsListesiTabloAc
   end;
   Abort;//Bunu kesinlikle silme (listede tek sat?r kal?nca hata verdi?i i?in eklendi)end;
end;

procedure TFirsatWizardDlg.TreeListGorevDblClick(Sender: TObject);
begin
   //GorevDuzenleTusClick(Self);
   Menu_Duzenle(Sender, TabGorevler);
   IsListesiTabloAc
end;

procedure TFirsatWizardDlg.DuzenleTeklifClick(Sender: TObject);
begin
   Tablo.TeklifSihirbazBaslat('D',80,11,TabBagTeklif.Fields[0].AsInteger, TabBagTeklif.FieldByName('REHBERID').AsInteger,-1);
   ProjebagTeklifEnterPage(Self, ProjebagTeklif);
end;

procedure TFirsatWizardDlg.GorevDuzenleTusClick(Sender: TObject);
begin
   Menu_Duzenle(Sender, TabGorevler);
   IsListesiTabloAc
end;

procedure TFirsatWizardDlg.GorevEkleTusClick(Sender: TObject);
var
   GorevId : Integer;
   GorevDlg1:TGorevDlg;
begin
   TabFirsatlar.post;
   GorevId := Tablo.GorevOlustur('', Tablo.GENINI.ReadInteger(Ops_OpsiyonIs_VarsayilanKlasor, Masaustu), 0,
                                   TabFirsatlar.Fields[0].AsInteger, 0, TabFirsatlar.FieldByName('REHBERID').AsInteger, 0, 0, 0,
                                   0, 0, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat);

   Tablo.GorevSihirbazBaslat(GorevDlg1, 'E', GorevId, AtamaYapildi, YorumYapildi);
   if AtamaYapildi then
      Gorev_EPostaGonder(1, GorevId)
   else if YorumYapildi then
      Gorev_EPostaGonder(3, GorevId);
   IsListesiTabloAc
end;

procedure TFirsatWizardDlg.GorevSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) = ID_OK then begin
     Tablo.GorevSil(TabGorevler.Fields[0].AsInteger);
     IsListesiTabloAc
  end;
end;

procedure TFirsatWizardDlg.GridAsamaViewASAMASORUMLUSUPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  TabProjeAsama.Edit;
  TabProjeAsama.FieldByName('REHBERID').AsInteger := Tablo.RehberAra_IDGetir(335);
  //TabProjeAsama.Post;
end;

procedure TFirsatWizardDlg.GridBagTeklifViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridBagTeklif;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridBagTeklifView;
   AnaForm.pmGridStil.Tags.Values[GridBagTeklif.Name]:='ProjeTeklifGridi';
end;

procedure TFirsatWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   if TabFirsatlar.State in [dsEdit,dsInsert] then
      TabFirsatlar.Post;
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TFirsatWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TFirsatWizardDlg.GridBagTeklifViewDblClick(Sender: TObject);
begin
   if TabBagTeklif.RecordCount > 0 then
      DuzenleTeklifClick(Sender);
end;

procedure TFirsatWizardDlg.lbProjeTipiClick(Sender: TObject);
begin
  if (ComboPRJ_TURU.EditValue=null) or (ComboPRJ_TURU.EditValue=0) then begin
    ShowMessage(PWTurSec);
    abort;
  end else begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM like ''-2112%'' and len(BOLUM)>5 and convert(varchar(30),BOLUM) not in (select ''-2112''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2112)',[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM=0 and DEGER like ''-2112%'' and len(DEGER)>5 and convert(varchar(30),BOLUM) not in (select ''-2112''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2112)',[],[]);
    if not Veritabani.VeriVarMi(Tablo.FDCnn,'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DEGER='+IntToStr(comboPRJ_TIPI.Tag),[],[]) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) select 0,ANAHTAR,convert(varchar(10),BOLUM)+convert(varchar(10),DEGER),DIL,0 from GENINI where BOLUM='+IntToStr(Ops_Firsat_Turu)+' and DEGER='+VarToStr(ComboPRJ_TURU.EditValue),[],[]);
    end;
    Tablo.LabelClickCombobox(Sender);
  end;

end;

procedure TFirsatWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Sontus:='I'; //iptal butonu
   Close;
end;

procedure TFirsatWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
    GTakvimID,s:string;
    SonucListe : TStringList;
    TeklifDurum,TeklifSonuc : Smallint;
begin

   if TabFirsatlar.State in [dsInsert, dsEdit] then begin
      TabFirsatlar.post;
      ProjeID := TabFirsatlar.Fields[0].asInteger;
   end;
   if TabDetay.State in [dsInsert, dsEdit] then
      TabDetay.post;

   if (CheckTamam.Checked)and(ComboPRJ_DURUM.EditValue>0) then begin
       SonucListe := TStringList.Create;
       //TeklifDurum :=0; TeklifSonuc:=0;
       if not Tablo.HizliGirisListedenBilgiGetir('F?rsat Sonu?','select ANAHTAR,DEGER from GENINI where BOLUM=-2114 and DIL=-1 and DEGER<0 '+
                  ' order by 1 ',SonucListe,False,[True, False],[]) then abort;
       TabFirsatlar.Edit;
       TabFirsatlar.FieldByName('ASAMA').AsInteger := StrToIntDef(SonucListe[1],0);
       TabFirsatlar.post;
       SonucListe.Free;

//      ShowMessage('Kapan?? a?amas? se?in..');
//      Abort;
   end
   else if (CheckTamam.Checked=False)and(ComboPRJ_DURUM.EditValue<0) then begin
           if Application.MessageBox(PChar(KWKapandiOlarakIsaretlensinmi),PWideChar(PrjConst.Onay),MB_ICONQUESTION+MB_YESNO) = IDYES then begin
              TabFirsatlar.Edit;
              TabFirsatlar.FieldByName('DURUM').AsInteger := 2;
              TabFirsatlar.post;
           end
           //else
           //   Abort;
   end;


   if EkleDetay then
      Ekle(TabDetay,TabNo_PROJELER,ProjeID,'De?i?');

{   if (OncekiDurum=False)and(TabFirsatlar.FieldByName('DURUM').AsBoolean=True) then //Kapand?ysa opsiyona bak?p teklifleri de kapatal?m
       if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjeKapatma, True) then begin
           SonucListe := TStringList.Create;
           TeklifDurum :=0; TeklifSonuc:=0;
           if Tablo.HizliGirisListedenBilgiGetir('Tekif Sonu?','select ANAHTAR,DEGER from GENINI where BOLUM=-2902 and DIL=-1 and DEGER in (6,7) '+
                  ' order by 1 ',SonucListe,False,[True, False],[]) then
              TeklifDurum := StrToIntDef(SonucListe[1],0);
           //
           if TeklifDurum=6 then begin//reddedildi ise sebebini sor
               SonucListe.Clear;
               if Tablo.HizliGirisListedenBilgiGetir('Tekif Sonu?','select ANAHTAR, DEGER from GENINI where BOLUM = -2911 and DIL=-1 '+
                   ' order by 1 ',SonucListe,False,[True, False],[]) then
                  TeklifSonuc := StrToIntDef(SonucListe[1],0);
           end;
           SonucListe.free;
           if TeklifDurum <> 0 then begin
              if TeklifSonuc<>0 then
                 s:= ', SONUC='+IntToStr(TeklifSonuc)
              else
                 s:='';
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update TEKLIF set DURUM='+IntToStr(TeklifDurum)+s+' where PROJEID=&ID',['&ID'],[TabFirsatlar.Fields[0].asInteger]);
           end;
       end; }
   Sontus:='K'; //Kaydet butonu
   ModalResult := mrOk;

   Tablo.TablodanSorguAc(6,'SELECT * FROM PROJELER WHERE ID='+inttostr(ProjeID));
   Tablo.TablodanSorguAc(8,'SELECT count(REHBERID) as MailSayi FROM GOOGLETAKVIMHESAPLARI where KULLANICIID = '+Tablo.Query6.FieldByName('PRJ_SORUMLUSU_ID').AsString);

    if Tablo.InternetVarmi then begin       //internet ba?lantisi kontrol ediliyor.

     if (Tablo.query8.FieldByName('MailSayi').AsInteger > 0) then
      begin
       if IslemOp='E'  then
        Begin
         //Tablo.TablodanSorguAc(6,'SELECT * FROM PROJELER WHERE ID='+inttostr(ProjeID));
            GTakvimID:=tablo.GoogleTakvimKaydet(tablo.Query6.FieldByName('PROJEKODU').AsString+' '+tablo.Query6.FieldByName('PROJEADI').AsString,
                          '',
                          'Konusu         : '+tablo.Query6.FieldByName('KONUSU').AsString+#13#10+
                          'M??teri ilgili   : '+TABLO.AciklamaGetir('REHBER','FIRMA',tablo.Query6.FieldByName('ILGILI').AsInteger)+#13#10+
                          'Proje Tipi      : ' +comboPRJ_TIPI.EditText+#13#10+
                          'Notlar           : '+tablo.Query6.FieldByName('NOTLAR').AsString,
                          StrToDateTime(formatdatetime('dd/MM/yyyy 00:00:00',tablo.Query6.FieldByName('BASLAMATARIHI').AsDateTime)),
                          StrToDateTime(formatdatetime('dd/MM/yyyy 23:59',tablo.Query6.FieldByName('BITISTARIHI').AsDateTime)),
                          tablo.Query6.FieldByName('PRJ_SORUMLUSU_ID').AsInteger);
          if GTakvimID <>'' then
            begin
             Tablo.Query8.SQL.Text:='update PROJELER SET GOOGLEHESAPID ='+inttostr(GoogleHesapID)+', GOOGLEOLAYID = '''+GTakvimID + ''' where ID ='+inttostr(ProjeID);
             Tablo.Query8.ExecSQL;
            end
          else ShowMessage(AKCalendar_kayit_edilemedi);
        end;

        if IslemOp='D'  then  Begin
          //ba?lama biti? tarihinde degi?iklik varsa aktivite silinip tekrar ekleniyor
         if ( (datetostr(GBaslamaTarih) <> DateBASLAMATARIHI.Text)   or (DateToStr(GBitisTarih) <> DateBITISTARIHI.Text)or( ProjeSorumlusu <> tablo.Query6.FieldByName('PRJ_SORUMLUSU_ID').AsInteger))  then  begin
            if (Tablo.Query6.FieldByName('GOOGLEOLAYID').AsString <>'') then begin
               Tablo.GoogleTakvimSil(Tablo.Query6.FieldByName('GOOGLEHESAPID').AsInteger,
                                                    Tablo.Query6.FieldByName('GOOGLEOLAYID').AsString);
            end;

          GTakvimID:=tablo.GoogleTakvimKaydet(tablo.Query6.FieldByName('PROJEKODU').AsString+' '+tablo.Query6.FieldByName('PROJEADI').AsString,
                     '',
                     'Konusu         : '+tablo.Query6.FieldByName('KONUSU').AsString+#13#10+
                     'M??teri ilgili   : '+TABLO.AciklamaGetir('REHBER','FIRMA',tablo.Query6.FieldByName('ILGILI').AsInteger)+#13#10+
                     'Proje Tipi      : ' +comboPRJ_TIPI.EditText+#13#10+
                     'Notlar           : '+tablo.Query6.FieldByName('NOTLAR').AsString,
                     StrToDateTime(formatdatetime('dd/MM/yyyy 00:00:00',tablo.Query6.FieldByName('BASLAMATARIHI').AsDateTime)),
                     StrToDateTime(formatdatetime('dd/MM/yyyy 23:59',tablo.Query6.FieldByName('BITISTARIHI').AsDateTime)),
                     tablo.Query6.FieldByName('PRJ_SORUMLUSU_ID').AsInteger);

              if GTakvimID <>'' then begin
                  Tablo.Query8.SQL.Text:='update PROJELER SET GOOGLEHESAPID ='+inttostr(GoogleHesapID)+', GOOGLEOLAYID = '''+GTakvimID + ''' where ID ='+inttostr(ProjeID);
                  Tablo.Query8.ExecSQL;
               end
              else ShowMessage(AKCalendar_kayit_edilemedi);
         end
           else begin
              if  Tablo.Query6.FieldByName('GOOGLEOLAYID').AsString <>'' then begin
               tablo.GoogleTakvimDegistir(Tablo.Query6.FieldByName('GOOGLEHESAPID').AsInteger,
                                          Tablo.Query6.FieldByName('GOOGLEOLAYID').AsString,
                                          tablo.Query6.FieldByName('PROJEKODU').AsString+' '+tablo.Query6.FieldByName('PROJEADI').AsString,
                                          'Konusu         : '+tablo.Query6.FieldByName('KONUSU').AsString+#13#10+
                                          'M??teri ilgili   : '+TABLO.AciklamaGetir('REHBER','FIRMA',tablo.Query6.FieldByName('ILGILI').AsInteger)+#13#10+
                                          'Proje Tipi      : ' +comboPRJ_TIPI.EditText+#13#10+
                                          'Notlar           : '+tablo.Query6.FieldByName('NOTLAR').AsString);
             end;
           end;
       end;

      end;

       if (Tablo.Query6.FieldByName('GOOGLEOLAYID').AsString <>'') and (Tablo.query8.FieldByName('MailSayi').AsInteger = 0) then begin
               Tablo.GoogleTakvimSil(Tablo.Query6.FieldByName('GOOGLEHESAPID').AsInteger,
                                                    Tablo.Query6.FieldByName('GOOGLEOLAYID').AsString);
            end;
    end;

end;
procedure TFirsatWizardDlg.YeniTeklifGirClick(Sender: TObject);
var ID : Integer;
begin
    ID := Tablo.TeklifSihirbazBaslat('E',80,0,-1,RehberId,ProjeID) ;

    if ID > 0 then begin
       //Proje eklendi ba??n? da ekleyelim
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'update TEKLIF set PROJEID='+IntToStr(ProjeID)+' WHERE ID = '+inttostr(ID);
       Tablo.Query1.ExecSQL;
       ProjebagTeklifEnterPage(Self, ProjebagTeklif);
       //ekran? yenileyelim
    end;
end;

procedure TFirsatWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Projeler);
end;

procedure TFirsatWizardDlg.TabDokumanBeforeOpen(DataSet: TDataSet);
begin
{    if strtoint(ROLID) <> -1 then
    begin
      Tabdokuman.SQL.Add(' AND GOR=1  AND (REHID = '+Kullanan +' OR REHID=0)  ');
    end; }
end;



end.









                                             
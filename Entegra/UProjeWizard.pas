unit UProjeWizard;

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
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet;

type
  TProjeWizardDlg = class(TForm, IPopupDialog)
    DtsProjeler: TDataSource;
    TabProjeler: TFDQuery;
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
    PmKopyala: TPopupMenu;
    Kopyala1: TMenuItem;
    TabProjeAsama: TFDQuery;
    DtsProjeAsama: TDataSource;
    btnAsama: TcxButton;
    ProjeAsamaEkr: TJvWizardInteriorPage;
    ToolBar5: TToolBar;
    BtnAsamaEkle: TToolButton;
    BtnAsamaSil: TToolButton;
    BtnAsamaKaydet: TToolButton;
    BtnAsamaIptal: TToolButton;
    cxGridProjeAsama: TcxGrid;
    cxGridProjeAsamaDBTableView1: TcxGridDBTableView;
    cxGridProjeAsamaDBTableView1ASAMA: TcxGridDBColumn;
    cxGridProjeAsamaDBTableView1ASAMASORUMLUSU: TcxGridDBColumn;
    cxGridProjeAsamaDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridProjeAsamaDBTableView1ONAY: TcxGridDBColumn;
    cxGridProjeAsamaLevel1: TcxGridLevel;
    cxGridProjeAsamaDBTableView1BASTAR: TcxGridDBColumn;
    cxGridProjeAsamaDBTableView1BITTAR: TcxGridDBColumn;
    Panel2: TPanel;
    Panel3: TPanel;
    ComboPRJ_TURU: TcxDBImageComboBox;
    DateBASLAMATARIHI: TcxDBDateEdit;
    ComboPRJ_KONUSU: TcxDBComboBox;
    ComboPRJ_ASAMA: TcxDBImageComboBox;
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
    cxLabel9: TcxLabel;
    LabelIlgili: TcxLabel;
    cxLabel10: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    PmSagClick: TPopupMenu;
    AsamalariEkle: TMenuItem;
    LabelCari: TcxLabel;
    EditProjeAdi: TcxDBTextEdit;
    MaliyetTus: TcxButton;
    MaliyetEkr: TJvWizardInteriorPage;
    TabMaliyet: TFDQuery;
    DtsMaliyet: TDataSource;
    EditSORUMLU: TcxButtonEdit;
    TabProjeAsamaID: TAutoIncField;
    TabProjeAsamaPROJEID: TIntegerField;
    TabProjeAsamaREHBERID: TIntegerField;
    TabProjeAsamaTUR: TIntegerField;
    TabProjeAsamaASAMA: TIntegerField;
    TabProjeAsamaONAY: TBooleanField;
    TabProjeAsamaACIKLAMA: TWideStringField;
    TabProjeAsamaBASTAR: TSQLTimeStampField;
    TabProjeAsamaBITTAR: TSQLTimeStampField;
    TabProjeAsamaDURUM: TBooleanField;
    TabProjeAsamaAKTIF: TBooleanField;
    TabProjeAsamaEKLEYEN: TIntegerField;
    TabProjeAsamaEKLEMETARIHI: TSQLTimeStampField;
    TabProjeAsamaDEGISTIREN: TIntegerField;
    TabProjeAsamaDEGISTIRMETARIHI: TSQLTimeStampField;
    TabProjeAsamaSUBEID: TSmallintField;
    TabProjeAsamaASAMASORUMLUSU: TStringField;
    CariPageControl: TcxPageControl;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    cxPageControl1: TcxPageControl;
    TabSheetButce: TcxTabSheet;
    TabSheetMaliyet: TcxTabSheet;
    ToolBar6: TToolBar;
    MaliyetGrid: TcxGrid;
    MaliyetGridView: TcxGridDBTableView;
    MaliyetGridViewBelgeTipi: TcxGridDBColumn;
    MaliyetGridViewSatici: TcxGridDBColumn;
    MaliyetGridViewBelgeTarihi: TcxGridDBColumn;
    MaliyetGridViewBelgeNo: TcxGridDBColumn;
    MaliyetGridViewAciklama: TcxGridDBColumn;
    MaliyetGridViewTutar: TcxGridDBColumn;
    MaliyetGridViewKDV: TcxGridDBColumn;
    MaliyetGridViewToplam: TcxGridDBColumn;
    MaliyetGridViewKUR: TcxGridDBColumn;
    MaliyetGridViewPersonel: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    DtsProjeButce: TDataSource;
    TabProjeButce: TFDQuery;
    TreeProjeButce: TcxDBTreeList;
    TreeListID: TcxDBTreeListColumn;
    TreeListKOD: TcxDBTreeListColumn;
    TreeListKOD2: TcxDBTreeListColumn;
    TreeListAD: TcxDBTreeListColumn;
    ToolBar7: TToolBar;
    BtnButceEkle: TToolButton;
    BtnButceSil: TToolButton;
    BtnButceKaydet: TToolButton;
    BtnButceIptal: TToolButton;
    TreeMIKTAR: TcxDBTreeListColumn;
    TreeBIRIMI: TcxDBTreeListColumn;
    TreeTUTAR: TcxDBTreeListColumn;
    TreeBIRIMFIYAT: TcxDBTreeListColumn;
    TreeKUR: TcxDBTreeListColumn;
    TreeGERCEKTAH: TcxDBTreeListColumn;
    PMButce: TPopupMenu;
    ExceldenVeriAlMenu: TMenuItem;
    TreeGERCEKODE: TcxDBTreeListColumn;
    MaliyetGridViewKAYNAK: TcxGridDBColumn;
    TabSheetEkstre: TcxTabSheet;
    Panel5: TPanel;
    ToolBar11: TToolBar;
    JvNavPanelHeader1: TJvNavPanelHeader;
    cxLabel6: TcxLabel;
    CalendarEkstreBas: TcxDateEdit;
    CalendarEkstreBit: TcxDateEdit;
    cxLabel14: TcxLabel;
    cxRadioButton1: TcxRadioButton;
    cxRadioButton2: TcxRadioButton;
    cxRadioButton3: TcxRadioButton;
    DtsCariListe: TDataSource;
    TabCariListe: TFDQuery;
    frxEkstre: TfrxDBDataset;
    GridMasrafEkstre: TcxGrid;
    GridMasrafEkstreView: TcxGridDBTableView;
    GridMasrafEkstreViewTARIH: TcxGridDBColumn;
    GridMasrafEkstreViewAKSIYONTARIH: TcxGridDBColumn;
    GridMasrafEkstreViewNO: TcxGridDBColumn;
    GridMasrafEkstreViewTUR: TcxGridDBColumn;
    GridMasrafEkstreViewKOD: TcxGridDBColumn;
    GridMasrafEkstreViewAD: TcxGridDBColumn;
    GridMasrafEkstreViewACIKLAMA: TcxGridDBColumn;
    GridMasrafEkstreViewHESAPKODU: TcxGridDBColumn;
    GridMasrafEkstreViewHESAPADI: TcxGridDBColumn;
    GridMasrafEkstreViewBORC: TcxGridDBColumn;
    GridMasrafEkstreViewALACAK: TcxGridDBColumn;
    GridMasrafEkstreViewKUR: TcxGridDBColumn;
    GridMasrafEkstreViewBORCBAKIYE: TcxGridDBColumn;
    GridMasrafEkstreViewALACAKBAKIYE: TcxGridDBColumn;
    GridMasrafEkstreViewYERELKUR: TcxGridDBColumn;
    GridMasrafEkstreViewYERELTUTAR: TcxGridDBColumn;
    GridMasrafEkstreViewYERELBAKIYE: TcxGridDBColumn;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    cxGrid1DBTableView1VADE: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    cxGrid1DBTableView1HESAPADI: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    cxGridProjeAsamaDBTableView1SURE: TcxGridDBColumn;
    TreeFARK: TcxDBTreeListColumn;
    TabProjeButceROOTKOD: TWideStringField;
    TabProjeButceKOD: TWideStringField;
    TabProjeButceID: TAutoIncField;
    TabProjeButcePROJEID: TIntegerField;
    TabProjeButceMASRAFID: TIntegerField;
    TabProjeButceAD: TWideStringField;
    TabProjeButceMIKTAR: TFMTBCDField;
    TabProjeButceBIRIMI: TSmallintField;
    TabProjeButceBIRIMFIYAT: TFMTBCDField;
    TabProjeButceTUTAR: TFMTBCDField;
    TabProjeButceKUR: TWideStringField;
    TabProjeButceGERCEKTAH: TCurrencyField;
    TabProjeButceGERCEKODE: TCurrencyField;
    TabProjeButceFARK: TCurrencyField;
    TabProjeAsamaSURE: TStringField;
    MemoProjeButceEFlow: TMemo;
    MemoProjeButce: TMemo;
    N1: TMenuItem;
    ExceleGonderMenu: TMenuItem;
    YaziciYaz: TToolButton;
    frxProjeButce: TfrxDBDataset;
    frxProjeler: TfrxDBDataset;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YaziciyaYazdirMenu: TMenuItem;
    MenuItem1: TMenuItem;
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
    CheckTamam: TcxDBCheckBox;
    cxTabSheet1: TcxTabSheet;
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
    cxLabel13: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    LabelPROJEKODU: TcxDBTextEdit;
    cxGridPopupMenu1: TcxGridPopupMenu;
    function EkranAdiAl: string;
    procedure FormShow(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabProjelerNewRecord(DataSet: TDataSet);
    procedure TabProjelerBeforePost(DataSet: TDataSet);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure ProjeEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure ComboIlgiliPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelTURUClick(Sender: TObject);
    procedure TabProjelerAfterPost(DataSet: TDataSet);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure ProjeEkDetayEkrPage(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure LabelAdClick(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure LabelSablonClick(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure lbProjeTipiClick(Sender: TObject);
    procedure TabProjelerBeforeEdit(DataSet: TDataSet);
    procedure ProjeTarihceEkrPage(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DtsProjeAsamaStateChange(Sender: TObject);
    procedure BtnAsamaEkleClick(Sender: TObject);
    procedure BtnAsamaSilClick(Sender: TObject);
    procedure BtnAsamaKaydetClick(Sender: TObject);
    procedure BtnAsamaIptalClick(Sender: TObject);
    procedure TabProjeAsamaNewRecord(DataSet: TDataSet);
    procedure TabProjeAsamaAfterPost(DataSet: TDataSet);
    procedure cxGridProjeAsamaDBTableView1ASAMASORUMLUSUPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure ProjeEkDetayEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure ProjeAsamaEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure cxGridProjeAsamaDBTableView1BITTARPropertiesCloseUp(Sender: TObject);
    procedure ComboPRJ_TURUPropertiesEditValueChanged(Sender: TObject);
    procedure TabDokumanBeforeOpen(DataSet: TDataSet);
    procedure TabProjeAsamaBeforeEdit(DataSet: TDataSet);
    procedure TabProjeAsamaBeforePost(DataSet: TDataSet);
    procedure TabProjeAsamaBeforeDelete(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AsamalariEkleClick(Sender: TObject);
    procedure MaliyetEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure EditTEMSILCIPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxDBButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabProjeAsamaCalcFields(DataSet: TDataSet);
    procedure btnProjeClick(Sender: TObject);
    procedure MaliyetGridViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxGridProjeAsamaDBTableView1CanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure BtnButceEkleClick(Sender: TObject);
    procedure BtnButceSilClick(Sender: TObject);
    procedure DtsProjeButceStateChange(Sender: TObject);
    procedure BtnButceKaydetClick(Sender: TObject);
    procedure BtnButceIptalClick(Sender: TObject);
    procedure TabProjeButceBeforePost(DataSet: TDataSet);
    procedure ExceldenVeriAlMenuClick(Sender: TObject);
    procedure CalendarEkstreBasPropertiesChange(Sender: TObject);
    procedure TabProjeButceCalcFields(DataSet: TDataSet);
    procedure ExceleGonderMenuClick(Sender: TObject);
    procedure TreeProjeButceCanFocusNode(Sender: TcxCustomTreeList;
      ANode: TcxTreeListNode; var Allow: Boolean);
    procedure cxDBDateEdit1PropertiesCloseUp(Sender: TObject);
    procedure comboPRJ_TIPIPropertiesCloseUp(Sender: TObject);
    procedure TabProjelerAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    GBaslamaTarih,GBitisTarih : TDateTime;
    ProjeSorumlusu:integer;
    KodAgaciMasrafDlg:TKodAgaciDlg;
    function ProjeBoslukKontrolu : Boolean;
    procedure FirmaBilgileri;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure KodOlustur;
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
  ProjeWizardDlg: TProjeWizardDlg;
  EkleDetay :boolean;
  projekoduretme : integer;


implementation

Uses  UAnaForm, UBinarySave, PrjConst, FetaKurulusSiniflari,FetaClassExtensions,
 UCombo,UGenelAnaSekmeFrame ,IdGlobalProtocols,LocOnFly, UExceldenVeriAl,
 cxTLExportLink, UFastRap, URaporAraclari;

{$R *.dfm}
  var
  DYetkisonuc : DokumanYetkiSonuc;
  OncekiDurum : smallint;
  ProjeShowAsamasi : boolean;
{  TabProjeAsama.FieldByName('PROJEID').AsInteger := TabProjeler.FieldByName('ID').AsInteger;
  TabProjeAsama.FieldByName('BASTAR').AsDatetime := Tablo.GENINI.BugunTrhSaat;
  TabProjeAsama.FieldByName('AKTIF').AsBoolean := True;
  TabProjeAsama.FieldByName('DURUM').AsBoolean := True;
  TabProjeAsama.FieldByName('SUBEID').AsInteger := SubeID;
  TabProjeAsama.FieldByName('EKLEYEN').AsString:= Kullanan;}
procedure TProjeWizardDlg.AsamalariEkleClick(Sender: TObject);
begin
  if TabProjeler.State=dsEdit then
    TabProjeler.Post;

  Tablo.TablodanSorguAc(1,'Select DEGER,SIRA from GENINI Where BOLUM='+inttoStr(Ops_Proje_Asama)+' order by SIRA');
    Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO [PROJEASAMA]([PROJEID],[REHBERID],[ASAMA],[BASTAR],[DURUM],[AKTIF],[EKLEYEN],[SUBEID]) Values('+
    ''+TabProjeler.FieldByName('ID').AsString+','''+Kullanan+''','+Tablo.Query1.FieldByName('DEGER').AsString+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',  '+
    '1,1,'''+Kullanan+''','+IntToStr(SubeId)+' )',[],[]);

    Tablo.Query1.Next;
  end;
  TabloYenile(TabProjeAsama,[TabProjeler.FieldByName('ID').AsInteger]);

end;

procedure TProjeWizardDlg.BtnAsamaEkleClick(Sender: TObject);
begin
  if TabProjeler.State in [dsInsert, dsEdit] then
     TabProjeler.Post;
  TabProjeAsama.Append;
end;

procedure TProjeWizardDlg.BtnAsamaIptalClick(Sender: TObject);
begin
  TabProjeAsama.Cancel;
end;

procedure TProjeWizardDlg.BtnAsamaKaydetClick(Sender: TObject);
begin
  TabProjeAsama.Post;
end;

procedure TProjeWizardDlg.BtnAsamaSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabProjeAsama.Delete;
end;

procedure TProjeWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
   if TabProjeler.State in [dsEdit,dsInsert] then
      TabProjeler.Post;
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_PROJELER, TabProjeler.FieldByName('ID').AsInteger, TabProjeler.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TProjeWizardDlg.btnProjeClick(Sender: TObject);
begin
   if TabProjeler.State in [dsEdit,dsInsert] then
      TabProjeler.Post;
   WizardKontrol.ActivePageIndex := tcxButton(Sender).Tag;//WizardKontrol.Pages.IndexOf(DokumanEkr);
end;

procedure TProjeWizardDlg.CalendarEkstreBasPropertiesChange(Sender: TObject);
var i :integer;
begin
  if (TabProjeler.Active)and(TabProjeler.RecordCount>0)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
    if cxRadioButton1.Checked then i:=1
    else if cxRadioButton2.Checked then i:=2
    else i:=3;

    TabCariListe.SQL.Text := 'select * from  dbo.fn_Proje_Ekstre ('+TabProjeler.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''',';
    TabCariListe.SQL.Add(inttostr(i)+',0,'''') order by TARIH');
    TabloYenile(TabCariListe,[]);
  end;
end;

procedure TProjeWizardDlg.ComboBolumPropertiesEditValueChanged(Sender: TObject);
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
      TabProjeler.Cancel
    end else begin
      TabProjeler.Post;
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_PROJELER,ProjeID]);
      ProjeEkDetayEkrPage(Self);
    end;
  end;
end;

procedure TProjeWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
begin
  if ComboBolum.Properties.Items.Count=0 then
     ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(TabNo_PROJELER)).Items;
end;

procedure TProjeWizardDlg.ComboIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabProjeler);
end;

procedure TProjeWizardDlg.comboPRJ_TIPIPropertiesCloseUp(Sender: TObject);
begin
   KodOlustur;
end;

procedure TProjeWizardDlg.ComboPRJ_TURUPropertiesEditValueChanged(Sender: TObject);
begin
   if ComboPRJ_TURU.ItemIndex>=0 then begin
      comboPRJ_TIPI.Tag := StrToInt(IntToStr(Ops_Proje_Turu)+ IntToStr(ComboPRJ_TURU.ActiveProperties.Items[ComboPRJ_TURU.ItemIndex].Value));
      Tablo.GENINI.ReadImageSection(comboPRJ_TIPI.Tag,comboPRJ_TIPI.Properties.Items,True);
      KodOlustur;
    end;
end;

procedure TProjeWizardDlg.cxDBButtonEdit1PropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var ID : Integer;
    s:String;
begin
   if not (TabProjeler.state in[dsEdit,dsInsert]) then
      TabProjeler.Edit;

   ID:=Tablo.RehberAra_IDGetir(0);
   s:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
   if Trim(TabProjeler.FieldByName('RAKIP').AsString)<>'' then
      TabProjeler.FieldByName('RAKIP').AsString:=TabProjeler.FieldByName('RAKIP').AsString+' \ ';
   TabProjeler.FieldByName('RAKIP').AsString := TabProjeler.FieldByName('RAKIP').AsString + ' '+ copy(s,1,pos(' ',s));
end;

procedure TProjeWizardDlg.cxDBDateEdit1PropertiesCloseUp(Sender: TObject);
begin
   KodOlustur
end;

procedure TProjeWizardDlg.cxGridDBColumn4GetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties,Sender);
end;

procedure TProjeWizardDlg.cxGridProjeAsamaDBTableView1ASAMASORUMLUSUPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  TabProjeAsama.Edit;
  TabProjeAsama.FieldByName('REHBERID').AsInteger := Tablo.RehberAra_IDGetir(335);
  TabProjeAsama.Post;
end;

procedure TProjeWizardDlg.cxGridProjeAsamaDBTableView1BITTARPropertiesCloseUp(Sender: TObject);
var PrjAsamaID:integer;
begin
  PrjAsamaID:= TabProjeAsama.FieldByName('ID').AsInteger;
  if TabProjeAsama.State in [dsEdit,dsInsert] then
     TabProjeAsama.Post;
  Tablo.TablodanSorguAc(1,'Select top 1 * from PROJEASAMA Where PROJEID='+inttostr(ProjeID)+' and ID > '+IntToStr(PrjAsamaID)+' and isnull(BITTAR,0)=0');
  if Tablo.Query1.RecordCount > 0 then begin
    TabProjeler.Edit;
    TabProjeler.FieldByName('ASAMA').AsInteger:=Tablo.Query1.FieldByName('ASAMA').AsInteger;
    TabProjeler.FieldByName('PRJ_ASAMA_SORUMLUSU_ID').AsInteger:=Tablo.Query1.FieldByName('REHBERID').AsInteger;
    TabProjeler.Post;
  end;
end;

procedure TProjeWizardDlg.cxGridProjeAsamaDBTableView1CanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=cxGridProjeAsama;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridProjeAsamaDBTableView1;
   AnaForm.pmGridStil.Tags.Values[cxGridProjeAsama.Name] := 'cxGridProjeAsamaDBTableView1';
end;

procedure TProjeWizardDlg.LabelSablonClick(Sender: TObject);
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

procedure TProjeWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TProjeWizardDlg.DkmanSil1Click(Sender: TObject);
begin
if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_projeler,TabProjeler.FieldByName('ID').AsInteger]);
  end;
end;

procedure TProjeWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
                 TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabProjeler.FieldByName('REHBERID').AsInteger)

end;

procedure TProjeWizardDlg.DtsProjeAsamaStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsProjeAsama,BtnAsamaEkle,BtnAsamaSil,BtnAsamaKaydet,BtnAsamaIptal);
end;

procedure TProjeWizardDlg.DtsProjeButceStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsProjeButce,BtnButceEkle,BtnButceSil,BtnButceKaydet,BtnButceIptal);
end;

procedure TProjeWizardDlg.KodOlustur;
var
 projekod: string;
begin
   if projekoduretme=0 then exit;

   if not (TabProjeler.state in[dsEdit,dsInsert]) then
     TabProjeler.Edit;

   if Pos(' ',labelAd.Caption)>0 then
     projekod:= Copy(LabelAd.Caption , 1,Pos(' ',labelAd.Caption)-1)
   else
     projekod:= LabelAd.Caption;

   projekod:= projekod+'-'+FormatDateTime('ddmmyyyy',DateBASLAMATARIHI.Date)+'-'+ComboPRJ_TURU.Text+'('+comboPRJ_TIPI.Text+')';

   TabProjeler.FieldByName('PROJEKODU').Value :=  projekod;
end;

procedure TProjeWizardDlg.EditTEMSILCIPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
begin
   tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabProjeler, 'PRJ_SORUMLUSU_ID')
  {if AButtonIndex = 0 then
     tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabProjeler, 'PRJ_SORUMLUSU_ID')
  else if AButtonIndex = 1 then begin
     TabProjeler.Edit;
     TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsInteger := 0;
     EditSORUMLU.text := '';
  end;}
end;

procedure TProjeWizardDlg.ExceldenVeriAlMenuClick(Sender: TObject);
begin
   Excel2ProjeButce(TabProjeler.FieldByName('ID').AsInteger);
   TabloYenile(TabProjeButce,[TabProjeler.Fields[0].AsInteger]);
end;

procedure TProjeWizardDlg.ExceleGonderMenuClick(Sender: TObject);
var
  curstr: string;
begin
  if Tablo.SaveDialog1.Execute then begin
     curstr := FormatSettings.CurrencyString;
     FormatSettings.CurrencyString := ' '; // cxGridPopupMenu1.Grid.Name
     cxExportTLToExcel(Tablo.SaveDialog1.FileName, TreeProjeButce, True, True, True);
     MessageDlg(Excelverikaydedildi, mtInformation, [mbOk], 0);
     FormatSettings.CurrencyString := curstr;
  end;
end;

procedure TProjeWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if  (Sontus='I') and ((IslemOp='E') or (IslemOp='K'))  then begin //e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
      if (TabProjeler.active)and(TabProjeler.Fields[0].AsString <> '')  then begin
        //varsa dokumanlar?n silinmeli
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_PROJELER, Yer_ID]);
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from DOKUMAN where MODUL = &TabNo AND MODULID = &Modulid ',['&TabNo', '&Modulid'],[TabNo_PROJELER, TabProjeler.FieldByName('ID').AsInteger]);
        //varsa proje ba?lant?lar? silinmeli
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' update AKTIVITELER set PROJEID=-1   where PROJEID ='+TabProjeler.FieldByName('ID').AsString,[],[]);
        //sonra kendi silinir
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from PROJELER where ID=&Id ',['&Id'], [TabProjeler.FieldByName('ID').AsInteger]);
      end;
   end;
end;

procedure TProjeWizardDlg.FormCreate(Sender: TObject);
begin
  if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjeMaliyetEflowKullan, False) then
    TabProjeButce.SQL.Text := MemoProjeButceEFlow.Lines.Text
  else
    TabProjeButce.SQL.Text := MemoProjeButce.Lines.Text;

   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
   Tablo.GridTurkcelestir;
   Sontus:='I';
   RehberId := -1;
   LogID:=0;
   //DokumanTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\ProjeDokumanGridi',true,false,[gsoUseFilter],'ProjeDokumanGridi');
   Tablo.GridAyarRestore('ProjeMaliyetGridi',MaliyetGridView );
   Tablo.GridAyarRestore('cxGridProjeAsama',cxGridProjeAsamaDBTableView1 );

   //PanelAlan.Height := Tablo.GENINI.ReadInteger(Ops_ProjeOpsiyon_PanelAlan,140);
   projekoduretme := Tablo.GENINI.ReadInteger(Ops_ProjeOpsiyon_ProjeKoduUretme,1); //    ProjeOpsiyon', 'ProjeKoduUretme', 1);
   LabelPROJEKODU.Properties.ReadOnly := projekoduretme=1;
end;

procedure TProjeWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TProjeWizardDlg(Self),DtsProjeler);
    end;
  end
  else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bile?en D?zenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
//      Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(PanelAlan.Name),TProjeWizardDlg(Self),DtsProjeler);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('S')) then  begin  //Bile?en Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
     if ctrl.Name <> '' then begin
       Tablo.TablodanSorguAc(1,'Select CAPTION,ALANADI,TAG,TABLO from ALANLAR Where TAG='+IntToStr(ctrl.Tag)+'  ');
       if Application.MessageBox(PChar(Tablo.Query1.FieldByName('CAPTION').AsString+' alan?n? silmek istiyor musunuz ?'),'UYARI',MB_YESNO)=mrYes then  begin

           Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Delete from ALANLAR Where TAG ='+IntToStr(ctrl.Tag)+' ',[],[]);
         try
           Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Alter table '+Tablo.Query1.FieldByName('TABLO').AsString+' drop column '+Tablo.Query1.FieldByName('ALANADI').AsString+' ',[],[]);
         except
         end;
           ctrl.Visible := False;
           //Tablo.AlanOlustur(FindComponent(PanelAlan.Name),TProjeWizardDlg(Self),-1,DtsProjeler);
           Tablo.AlanOlustur(TProjeWizardDlg(Self),-1,DtsProjeler);
       end;
     end;
    end;
  end;

end;

procedure TProjeWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
  i : SmallInt;
begin
  TabloYenile(TabProjeler,[TabProjeler.Fields[0].AsInteger]);
  TabloYenile(TabProjeButce,[TabProjeler.Fields[0].AsInteger]);
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdiAl, frxProjeler) then
    AFastReport.EnabledDataSets.Add(frxProjeler)
  else begin
    frxProjeler.DataSet := tabProjeler;
    AFastReport.EnabledDataSets.Add(frxProjeler);
    AFastReport.EnabledDataSets.Add(frxProjeButce);
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
    Tablo.TabMusteri.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
  end;
end;

procedure TProjeWizardDlg.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 ');
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  lblMusteriAdres.Caption:= Adres+ Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+' '+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+' / '+Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  lblMusteriTel.Caption:= isTel+Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
  lblMusteriEposta.Caption:= EPosta+Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TProjeWizardDlg.FormShow(Sender: TObject);
var
  EskiProjeID,i:Integer;
  aktifFrame: TGenelAnaSekmeFrame;
  ra:string;
begin
  EkleDetay := False;
  FirmaBilgileri;

  ProjeShowAsamasi:=True;

  //Tablo.ProjeInit(ComboPRJ_TURU.Properties,ComboPRJ_ASAMA.Properties,ComboPRJ_DURUM.Properties,ComboLISTEKUR.Properties,ComboSATISKUR.Properties);
  Tabloyenile(TabProjeler, [ProjeID]);

    //imgComboboxlar? sola yasla
   ComboPRJ_ASAMA.RepositoryItem.Properties.Alignment.Horz:=taLeftJustify;
   ComboPRJ_TURU.RepositoryItem.Properties.Alignment.Horz:=taLeftJustify;
   comboPRJ_TIPI.Properties.Alignment.Horz:=taLeftJustify;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  //lblDegistirenKullanici.Caption:= Tablo.repGenelPersonelListesi.Properties.GetDisplayText(TabProjeler.FieldByName('DEGISTIREN').AsInteger,True);
 // groupProjeSonAktivite.Visible:= IslemOp='D';

//  Tablo.AlanOlustur(PanelAlan,TProjeWizardDlg(Self), -1,DtsProjeler);
  Tablo.AlanOlustur(TProjeWizardDlg(Self), -1,DtsProjeler);

  //Admin de?il ise  RolId = -1 ise y?netici demektir..  Yetkili ya da sorumlu de?ilse ?ablonu g?remesin
   if (RolId<>'-1')and(TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
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
         TabProjeler.Append;
       end;
  'D', 'K': begin //De?i?tirme
         if TabProjeler.FieldByName('ILGILI').AsString<>'' then
            ComboIlgili.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabProjeler.FieldByName('ILGILI').AsString);
         Yer_ID := TabProjeler.Fields[0].AsInteger;
         //son teklif
       end;


  end;
 ///Dok?man
 // Yeri := 41;
   ProjeID := TabProjeler.Fields[0].AsInteger;
   Tabloyenile(TabYorum, [Tabno_Projeler, ProjeID]);
   EditSORUMLU.text := tablo.AciklamaGetir('REHBER', 'FIRMA',TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsString);
   GBaslamaTarih := TabProjeler.FieldByName('BASLAMATARIHI').AsDateTime;
   GBitisTarih := TabProjeler.FieldByName('BITISTARIHI').AsDateTime;
   ProjeSorumlusu := TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsInteger;
   OncekiDurum := TabProjeler.FieldByName('DURUM').AsInteger;
   if TabProjeler.FieldByName('CARIID').AsString <> '' then
      LabelCari.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabProjeler.FieldByName('CARIID').AsInteger);


  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;
  ProjeShowAsamasi:=False;
end;

procedure TProjeWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TProjeWizardDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TProjeWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TProjeWizardDlg.LabelAdClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(0,TabProjeler.FieldByName('REHBERID').AsInteger,-100,-100, False);
end;


procedure TProjeWizardDlg.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
   Id := Tablo.RehberAra_IDGetir(-1);
   if Id>0 then begin
      RehberId := Id;
      if TabProjeler.State = dsBrowse then
         TabProjeler.Edit;
      TabProjeler.FieldByName('REHBERID').AsInteger := RehberId;
       ComboILGILI.Text := '';
      TabProjeler.FieldByName('ILGILI').AsInteger  := -1;
      FirmaBilgileri;
      KodOlustur;
   end;
end;

procedure TProjeWizardDlg.LabelTURUClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TProjeWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TProjeWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_projeler, tabProjeler.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TProjeWizardDlg.ProjeAsamaEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
if TabProjeAsama.State in [dsEdit,dsinsert] then
     TabProjeAsama.Post;
end;

function TProjeWizardDlg.ProjeBoslukKontrolu: Boolean;
begin
   ProjeBoslukKontrolu := True;
   if not BoslukKontrol(ComboPRJ_TURU.text, KontrolTuru) then Abort;
   if not BoslukKontrol(ComboPRJ_KONUSU.text, KontrolKonusu) then Abort;
   //if not BoslukKontrol(ComboPrjSorumlu.text, KontrolSorumlu) then Abort;
   //if not BoslukKontrol(ComboAsamaSorumlu.text, KontrolAsamaSorumlusu) then Abort;
   if not BoslukKontrol(ComboPRJ_ASAMA.text, KontrolAsamasi) then Abort;
   if not BoslukKontrol(LabelPROJEKODU.text, BGProje_kodu) then Abort;
   ProjeBoslukKontrolu := False;
end;

procedure TProjeWizardDlg.ProjeEkDetayEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   if EkleDetay then
      Ekle(TabDetay,TabNo_PROJELER,ProjeID,'De?i?');
end;

procedure TProjeWizardDlg.ProjeEkDetayEkrPage(Sender: TObject);
var Yeri : SmallInt;
begin
    TabDetay.Close;
    TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    TabDetay.Params[0].Value := TabNo_PROJELER;
    TabDetay.Params[1].Value := ProjeID;
    TabDetay.Params[2].Value := ComboBolum.Text;
    TabDetay.Open;

end;

procedure TProjeWizardDlg.ProjeEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
   Stop := ProjeBoslukKontrolu;
   if (IslemOp='E')and(TabProjeler.State = dsInsert) then begin
      TabProjeler.Post;
      ProjeID := TabProjeler.Fields[0].AsInteger;
      RehberId := TabProjeler.FieldByName('REHBERID').AsInteger;
      Yer_ID := ProjeID;
   end;
end;

procedure TProjeWizardDlg.ProjeTarihceEkrPage(Sender: TObject);
begin
  TabloYenile(TabProjeGecmis,  [ProjeID]);
end;

procedure TProjeWizardDlg.TabProjeAsamaAfterPost(DataSet: TDataSet);
begin
  //TabloYenile(TabProjeAsama,[TabProjeler.FieldByName('ID').AsInteger]);
end;

procedure TProjeWizardDlg.TabProjeAsamaBeforeDelete(DataSet: TDataSet);
begin
   if (RolId<>'-1')and(TabProjeAsama.FieldByName('EKLEYEN').AsString <> Kullanan)and(TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
       Application.MessageBox(PChar(AWSorumluHaricindeSilmeYapilmaz), PChar(Uyari), MB_OK + MB_ICONERROR);
       Abort;
   end;
end;

function TProjeWizardDlg.EkranAdiAl: string;
begin
  Result := 'ProjeWizard';
end;

procedure TProjeWizardDlg.TabProjeAsamaBeforeEdit(DataSet: TDataSet);
begin
      //Admin de?il ise  RolId = -1 ise y?netici demektir..
  if (ProjeShowAsamasi=False)and(RolId<>'-1')and(TabProjeAsama.FieldByName('EKLEYEN').AsString <> Kullanan)
         and(TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
      Application.MessageBox(PChar(AWSorumluHaricindeDegisYapilmaz), PChar(Uyari), MB_OK + MB_ICONERROR);
      Abort;
  end;
end;

procedure TProjeWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TProjeWizardDlg.TabProjeAsamaBeforePost(DataSet: TDataSet);
begin
   TabProjeAsama.FieldByName('DEGISTIREN').AsString:= Kullanan;
   TabProjeAsama.FieldByName('DEGISTIRMETARIHI').AsDateTime:= Tablo.GENINI.BugunTrhSaat;
end;

procedure TProjeWizardDlg.TabProjeAsamaCalcFields(DataSet: TDataSet);
begin
   if TabProjeAsama.FieldByName('REHBERID').AsString<> '' then begin
       Tablo.TablodanSorguAc(1, 'select FIRMA from REHBER where ID='+TabProjeAsama.FieldByName('REHBERID').AsString);
       if Tablo.Query1.RecordCount>0 then
          TabProjeAsama.FieldByName('ASAMASORUMLUSU').AsString := Tablo.Query1.Fields[0].AsString
       else
          TabProjeAsama.FieldByName('ASAMASORUMLUSU').AsString := '';
   end;
   Tablo.TablodanSorguAc(1, 'SELECT [dbo].[fn_TarihFarkiFormatli]('''+FormatDateTime('yyyy-mm-dd hh:nn',TabProjeAsama.FieldByName('BASTAR').AsDateTime)+''','''+
                             FormatDateTime('yyyy-mm-dd hh:nn',TabProjeAsama.FieldByName('BITTAR').AsDateTime)+''')');
   TabProjeAsama.FieldByName('SURE').AsString := Tablo.Query1.fields[0].asstring;
end;

procedure TProjeWizardDlg.TabProjeAsamaNewRecord(DataSet: TDataSet);
begin
  TabProjeAsama.FieldByName('PROJEID').AsInteger := TabProjeler.FieldByName('ID').AsInteger;
  TabProjeAsama.FieldByName('BASTAR').AsDatetime := Tablo.GENINI.BugunTrhSaat;
  TabProjeAsama.FieldByName('AKTIF').AsBoolean := True;
  TabProjeAsama.FieldByName('DURUM').AsBoolean := True;
  TabProjeAsama.FieldByName('EKLEYEN').AsString:= Kullanan;
end;

procedure TProjeWizardDlg.TabProjeButceBeforePost(DataSet: TDataSet);
begin
   TabProjeButce.FieldByName('TUTAR').AsFloat := TabProjeButce.FieldByName('MIKTAR').AsFloat *  TabProjeButce.FieldByName('BIRIMFIYAT').AsFloat
end;

procedure TProjeWizardDlg.TabProjeButceCalcFields(DataSet: TDataSet);
begin
   TabProjeButce.FieldByName('FARK').AsFloat := TabProjeButce.FieldByName('GERCEKTAH').AsFloat - TabProjeButce.FieldByName('GERCEKODE').AsFloat;
end;

procedure TProjeWizardDlg.TabProjelerAfterPost(DataSet: TDataSet);
begin
  ProjeID := TabProjeler.Fields[0].AsInteger;
  if islemOp='D' then
    Tablo.LogIslemleri(TabNo_PROJELER,ProjeID, 4, TabProjeler);
end;

procedure TProjeWizardDlg.TabProjelerAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabSonAktivite,[TabProjeler.FieldByName('ID').AsInteger]);
  TabloYenile(TabProjeAsama,[TabProjeler.FieldByName('ID').AsInteger]);
end;

procedure TProjeWizardDlg.TabProjelerBeforeEdit(DataSet: TDataSet);
begin
      //Admin de?il ise  RolId = -1 ise y?netici demektir..
   if (ProjeShowAsamasi=False)and(RolId<>'-1')and(TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
       Application.MessageBox(PChar(AWSorumluHaricindeDegisYapilmaz), PChar(Uyari), MB_OK + MB_ICONERROR);
       Abort;
   end;
   if LogGun>0 then
      Tablo.OncekiLogBelirle(TabProjeler);
end;

procedure TProjeWizardDlg.TabProjelerBeforePost(DataSet: TDataSet);
begin
  ProjeBoslukKontrolu;
  if TabProjeler.FieldByName('BITISTARIHI').AsDateTime < TabProjeler.FieldByName('BASLAMATARIHI').AsDateTime then
   begin
     ShowMessage(PWBitRarihKucukSecilemez);
     abort;
   end;

  if IslemOp = 'D' then
    Tablo.ProjeTarihceEkle(TabProjeler);
  EkleyenDegistiren(DtsProjeler);
end;

procedure TProjeWizardDlg.TabProjelerNewRecord(DataSet: TDataSet);
begin
  //TabProjeler.FieldByName('FIRMAKOD').AsString := AraQuery1.FieldByname('KOD').AsString;
  TabProjeler.FieldByName('MODUL').AsInteger := 11;
  TabProjeler.FieldByName('REHBERID').AsInteger := RehberId;
  TabProjeler.FieldByName('BASLAMATARIHI').AsDateTime := Trunc(IslemTarih);
  TabProjeler.FieldByName('BITISTARIHI').AsDateTime := Trunc(IslemTarih);
  ComboSATISKUR.ItemIndex := 0;
  TabProjeler.FieldByName('PRJ_SORUMLUSU_ID').AsString := Kullanan;
  //ComboPrjSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Kullanan);

//  TabProjeler.FieldByName('HABER_BEKLENIYOR').Asboolean := False;
//  TabProjeler.FieldByName('PLAN').Asboolean := False;
  TabProjeler.FieldByName('DURUM').AsInteger := 1;
  TabProjeler.FieldByName('ASAMA').AsInteger := 1;
  TabProjeler.FieldByName('EKLEYEN').AsString := Kullanan;

  if SubeVarmi then begin
     case Tablo.GENINI.ReadInteger(Ops_OpsiyonProje_GorunecekSubeler,0) of
       0 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtak;
       1 : ComboSube.RepositoryItem := Tablo.RepSubelerKendiSubesi;
       2 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakKendiSubesi;
       3 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakTumSubeler;
     end;
  end;
  case Tablo.GENINI.ReadInteger(Ops_OpsiyonProje_GorunecekSubeler,0) of
   0,2,3 : TabProjeler.FieldByName('SUBEID').AsInteger  := 0;
   1 : TabProjeler.FieldByName('SUBEID').AsInteger  := SubeID;
  end;
end;


procedure TProjeWizardDlg.TreeProjeButceCanFocusNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
begin
  TreeProjeButce.PopupMenu := AnaForm.PopupMenuTree;
end;

procedure TProjeWizardDlg.BtnButceEkleClick(Sender: TObject);
var
    MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
begin
    if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI,'',True) then begin
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into PROJEBUTCE (PROJEID,MASRAFID,KUR)values('+
       TabProjeler.FieldByName('ID').AsString+','+MASRAFID+','''+CariDoviz+''')',[],[]);
       //bakal?m bu kodun alt?nda eklenecek ba?ka sat?rlar varsa onlar? da ekleyelim..
       Tablo.TablodanSorguAc(0, 'select ID from MASRAFGELIR where KOD like '''+MASRAFKODU+'.%'' ');
       while not Tablo.Query0.Eof do begin
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into PROJEBUTCE (PROJEID,MASRAFID,KUR)values('+
             TabProjeler.FieldByName('ID').AsString+','+Tablo.Query0.Fields[0].AsString+','''+CariDoviz+''')',[],[]);
         Tablo.Query0.next;
       end;

       TabloYenile(TabProjeButce,[TabProjeler.Fields[0].AsInteger]);
    end;
end;

procedure TProjeWizardDlg.BtnButceIptalClick(Sender: TObject);
begin
   TabProjeButce.Cancel;
end;

procedure TProjeWizardDlg.BtnButceKaydetClick(Sender: TObject);
begin
   TabProjeButce.Post;
end;

procedure TProjeWizardDlg.BtnButceSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from PROJEBUTCE where ID='+TabProjeButce.FieldByName('ID').AsString,[],[]);
     TabloYenile(TabProjeButce,[TabProjeler.Fields[0].AsInteger]);
  end;
end;

procedure TProjeWizardDlg.MaliyetGridViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=MaliyetGrid;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=MaliyetGridView;
   AnaForm.pmGridStil.Tags.Values[MaliyetGrid.Name] := 'ProjeMaliyetGridi';
end;

procedure TProjeWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   if TabProjeler.State in [dsEdit,dsInsert] then
      TabProjeler.Post;
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TProjeWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   if TabProjeler.State in [dsEdit,dsInsert] then
      TabProjeler.Post;
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TProjeWizardDlg.lbProjeTipiClick(Sender: TObject);
begin
  if (ComboPRJ_TURU.EditValue=null) or (ComboPRJ_TURU.EditValue=0) then begin
    ShowMessage(PWTurSec);
    abort;
  end else begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from GENINI where BOLUM like ''-2132%'' and len(BOLUM)>5 and convert(varchar(30),BOLUM) not in (select ''-2132''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2132)',[],[]);
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from GENINI where BOLUM=0 and DEGER like ''-2132%'' and len(DEGER)>5 and convert(varchar(30),BOLUM) not in (select ''-2132''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2132)',[],[]);
    if not Veritabani.VeriVarMi(Tablo.FDCnn,'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DEGER='+IntToStr(comboPRJ_TIPI.Tag),[],[]) then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,
        'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) select 0,ANAHTAR,convert(varchar(10),BOLUM)+convert(varchar(10),DEGER),DIL,0 from GENINI where BOLUM='+IntToStr(Ops_Proje_Turu)+' and DEGER='+VarToStr(ComboPRJ_TURU.EditValue),[],[]);
    end;
    Tablo.LabelClickCombobox(Sender);
  end;

end;

procedure TProjeWizardDlg.MaliyetEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tablo.GridAyarRestore('TreeProjeButce',nil,TreeProjeButce );

   TabloYenile(TabProjeButce,[TabProjeler.Fields[0].AsInteger]);

   if CalendarEkstreBas.Text='' then begin
      CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2010');
      CalendarEkstreBit.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2050');
   end;

   if not TabMaliyet.Active then begin
      TabloYenile(TabMaliyet, [TabProjeler.Fields[0].AsInteger,TabProjeler.Fields[0].AsInteger,TabProjeler.Fields[0].AsInteger]);
      MaliyetGridView.ApplyBestFit(nil);
   end;
end;

procedure TProjeWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Sontus:='I'; //iptal butonu
   Close;
end;

procedure TProjeWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
    GTakvimID,s:string;
    SonucListe : TStringList;
    TeklifDurum,TeklifSonuc : Smallint;
begin

   if TabProjeler.State in [dsInsert, dsEdit] then begin
      TabProjeler.post;
      ProjeID := TabProjeler.Fields[0].asInteger;
   end;
   if TabDetay.State in [dsInsert, dsEdit] then
      TabDetay.post;

   if TabProjeAsama.State in [dsEdit,dsinsert] then
      TabProjeAsama.Post;

   if EkleDetay then
      Ekle(TabDetay,TabNo_PROJELER,ProjeID,'De?i?');

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
procedure TProjeWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Projeler);
end;

procedure TProjeWizardDlg.TabDokumanBeforeOpen(DataSet: TDataSet);
begin
{    if strtoint(ROLID) <> -1 then
    begin
      Tabdokuman.SQL.Add(' AND GOR=1  AND (REHID = '+Kullanan +' OR REHID=0)  ');
    end; }
end;



end.














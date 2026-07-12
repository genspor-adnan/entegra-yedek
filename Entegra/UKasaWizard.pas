unit UKasaWizard;

(* ?al??ma Prensipleri
Tahsilat veya ?deme :  Plan -> Belge - Tahsilat
Plan yapt?k, faturas? geldi bundan sonra Kasa tablosundaki : Plan?n durumu Fatura diye g?ncellenir
Plan yapt?k, Tahsilat veya ?demesi geldi bundan sonra 2 t?rl? durum olabilir: Kasa tablosundaki : 1. plan silinir 2.Plan?n durumu Tamamland? diye g?ncellenir
*)
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvWizard, StdCtrls, Buttons, FireDAC.Comp.Client,DateUtils,
  DB, Menus, Grids, DBGrids, ExtCtrls, ComCtrls, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxCheckBox,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, DBCtrls, Spin, cxDBEdit,
  cxContainer, cxTextEdit, cxMaskEdit, cxButtonEdit, Mask, cxCurrencyEdit,
  JvLinkLabel, JvExComCtrls, JvDBTreeView, cxImageComboBox, cxDropDownEdit,
  ToolWin, cxTreeView, cxMemo, cxLookAndFeelPainters, cxButtons, dxSkinsCore,
  dxSkinscxPCPainter, cxCalendar, cxLabel, cxDBLabel, cxImage, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, jpeg, cxSpinEdit, frxClass, frxDBSet,
  cxTimeEdit,cxFormats, cxPC, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdFinger, cxHyperLinkEdit, dxSkinLondonLiquidSky, cxTL, UTablo,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, cxTLData, cxDBTL, cxGroupBox,
  cxLookAndFeels, dxCore, cxDateUtils, cxNavigator,cxRadioGroup, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TKasaWizardDlg = class(TForm, IPopupDialog)
    WizardKontrol: TJvWizard;
    MenuEkr: TJvWizardWelcomePage;
    KasaSecimEkr: TJvWizardInteriorPage;
    KasaQuery: TFDQuery;
    dsKasaQuery: TDataSource;
    VirmanEkr: TJvWizardInteriorPage;
    pnl2: TPanel;
    VirmanNereyeQuery: TFDQuery;
    dsKurNereyeQuery: TDataSource;
    CekSenetKrediAraEkr: TJvWizardInteriorPage;
    dsCekSenet: TDataSource;
    CekSenetKrediQuery: TFDQuery;
    CekSenetAramaPanel: TPanel;
    LabelCariKodAra: TcxLabel;
    LabelCariAdAra: TcxLabel;
    edCarikod: TcxTextEdit;
    edCariAd: TcxTextEdit;
    CekSenetAraTus: TBitBtn;
    PlanlamaEkr: TJvWizardInteriorPage;
    PanelTaksit: TPanel;
    DtsOdemeTakvimi: TDataSource;
    TabOdemeTakvimi: TFDQuery;
    Panel3: TPanel;
    Yenilebtn: TSpeedButton;
    LabelKanal: TcxLabel;
    GridTaksit: TcxGrid;
    PlanTview: TcxGridDBTableView;
    ColumnSozId: TcxGridDBColumn;
    ColumnTarih: TcxGridDBColumn;
    ColumnTUTAR: TcxGridDBColumn;
    ColumnKur: TcxGridDBColumn;
    ColumnACIKLAMA: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    KasaGrid: TcxGrid;
    KasaGridTableView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    MemoCekSQL: TMemo;
    Label10: TcxLabel;
    TabTakvimFat: TFDQuery;
    DtsTakvimFat: TDataSource;
    ComboBoxOdemeYeri: TcxImageComboBox;
    FaturaPlanSecEkr: TJvWizardInteriorPage;
    GridTakvimPlan: TcxGrid;
    TakvimPlanView: TcxGridDBTableView;
    cxGridLevel5: TcxGridLevel;
    TakvimPlanViewID: TcxGridDBColumn;
    TakvimPlanViewTUR: TcxGridDBColumn;
    TakvimPlanViewTARIH: TcxGridDBColumn;
    TakvimPlanViewACIKLAMA: TcxGridDBColumn;
    TakvimPlanViewHESAPADI: TcxGridDBColumn;
    TakvimPlanViewTUTAR: TcxGridDBColumn;
    TakvimPlanViewKUR: TcxGridDBColumn;
    TakvimPlanViewDURUM: TcxGridDBColumn;
    TabDuzenliOdeme: TFDQuery;
    Label3: TcxLabel;
    KasaTarihi: TcxDateEdit;
    Label35: TcxLabel;
    PanelPlanOde: TPanel;
    GridTakvimFat: TcxGrid;
    TakvimFatView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    PanelPlanFat: TPanel;
    TabTakvimPlan: TFDQuery;
    DtsTakvimPlan: TDataSource;
    TahsilatEkr: TJvWizardInteriorPage;
    Label5: TcxLabel;
    ComboPlanAciklama: TcxComboBox;
    CheckBitisUyar: TcxCheckBox;
    SpinUYARIGUN: TcxSpinEdit;
    LabelUyariGun: TcxLabel;
    SQLPlan: TcxMemo;
    PlanTviewUYAR: TcxGridDBColumn;
    PlanTviewUYARIGUN: TcxGridDBColumn;
    cxLabel2: TcxLabel;
    RadioOnceSonra1: TRadioButton;
    RadioOnceSonra2: TRadioButton;
    RadioOnceSonra3: TRadioButton;
    SQLPesin: TMemo;
    Label32: TcxLabel;
    EditTutar: TcxCurrencyEdit;
    ComboKurPlan: TcxComboBox;
    DatePesinat: TcxDateEdit;
    EditPesinTutar: TcxCurrencyEdit;
    LabelPesin: TcxLabel;
    CheckTaksit: TCheckBox;
    TaksitPanel: TPanel;
    Label13: TcxLabel;
    TaksitSay: TcxSpinEdit;
    EditTaksitTutar: TcxCurrencyEdit;
    DateTaksit: TcxDateEdit;
    LabelPlanlananTarih: TcxLabel;
    Label54: TcxLabel;
    GridHedef: TcxGrid;
    GridHedefView: TcxGridDBTableView;
    cxGridLevel6: TcxGridLevel;
    PanelVirman: TPanel;
    Label26: TcxLabel;
    VirmanMiktar: TcxCurrencyEdit;
    ToolBar2: TToolBar;
    AylikTus: TToolButton;
    GridKaynak: TcxGrid;
    GridKaynakView: TcxGridDBTableView;
    cxGridLevel7: TcxGridLevel;
    dsVirmanNerdenQuery: TDataSource;
    VirmanNerdenQuery: TFDQuery;
    Label51: TcxLabel;
    ComboVirmanAciklama: TcxComboBox;
    DisindaTus: TcxButton;
    PlanSilTus: TcxButton;
    PanelSol: TPanel;
    PanelSag: TPanel;
    MenuMusTree: TcxTreeView;
    MenuVarTree: TcxTreeView;
    Panel2: TPanel;
    Panel4: TPanel;
    PanelOdemeKanali: TPanel;
    LabelBanka: TcxLabel;
    LabelPlanBankaHesapNoGon: TcxLabel;
    LabelPlanBankaHesapIdGon: TcxLabel;
    EditPlanBankaHesapGon: TcxButtonEdit;
    Label14: TcxLabel;
    LabelPlanBankaHesapNoAl: TcxLabel;
    LabelPlanBankaHesapIdAl: TcxLabel;
    EditPlanBankaHesapAlici: TcxButtonEdit;
    MemoSenetSQL: TMemo;
    Panel5: TPanel;
    Label15: TcxLabel;
    lbl29: TcxLabel;
    LabelFaizTutar: TcxLabel;
    EditTahsilatTutar: TcxCurrencyEdit;
    EditFaizTutar: TcxCurrencyEdit;
    PanelFisBilgi: TPanel;
    lbl27: TcxLabel;
    lbl28: TcxLabel;
    EditFisNo: TcxTextEdit;
    DateFisTarihi: TcxDateEdit;
    ComboBoxTahAciklama: TcxComboBox;
    LabelDovizTutar: TcxLabel;
    EditDovizTutar: TcxCurrencyEdit;
    ComboDovizTutar: TcxComboBox;
    ComboKurTah: TcxComboBox;
    DtsAvansTakvimi: TDataSource;
    GridAvansTaksit: TcxGrid;
    GridAvansTaksitView: TcxGridDBTableView;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel8: TcxGridLevel;
    PanelTaksitBilgisi: TPanel;
    Label59: TcxLabel;
    SpinAvansSay: TcxSpinEdit;
    Label60: TcxLabel;
    SQLAvanGeriOdeme: TMemo;
    Label61: TcxLabel;
    AraSay: TcxSpinEdit;
    Label62: TcxLabel;
    TabAvansTakvimi: TFDQuery;
    MemoKrediler: TMemo;
    TVCekSenetKrediAra: TcxGridDBTableView;
    GLCekSenetKrediAra: TcxGridLevel;
    GridCekSenetKrediAra: TcxGrid;
    VirmanKomisyon: TcxCurrencyEdit;
    LabelKomisyon: TcxLabel;
    RadioBankaKasa: TcxRadioGroup;
    ComboSube: TcxImageComboBox;
    LblSube: TcxLabel;
    ComboVirmanKur: TcxComboBox;
    VirmanTarihi: TcxDateEdit;
    LabelVirmanSube: TcxLabel;
    VirmanSube: TcxImageComboBox;
    EditVirmanlKur: TcxCurrencyEdit;
    PanelKarsilik: TPanel;
    LabelKarsiligi: TcxLabel;
    EditKarsiligi: TcxCurrencyEdit;
    ComboKarsiligiKur: TcxComboBox;
    PanelKaynak: TPanel;
    Label47: TcxLabel;
    Label50: TcxLabel;
    EditKaynakKod: TcxTextEdit;
    EditHedefKod: TcxTextEdit;
    cxLabel3: TcxLabel;
    EditKaynakAd: TcxTextEdit;
    cxLabel4: TcxLabel;
    EditHedefAd: TcxTextEdit;
    CbNakitVarlikTipi: TcxImageComboBox;
    LbVarlikTipi: TcxLabel;
    LabelRehberId: TcxLabel;
    LabelRehberAd: TcxLabel;
    cxLabel6: TcxLabel;
    EditIslemNo: TcxTextEdit;
    cxLabel7: TcxLabel;
    EditArbitrajKarsilik: TcxCurrencyEdit;
    EditKarsiligiKur: TcxCurrencyEdit;
    EditDovizKuru: TcxCurrencyEdit;
    CheckR: TcxCheckBox;
    ComboPlanSecim: TcxComboBox;
    LabelCekSenetKod: TcxLabel;
    ComboCekSenetKrediDurum: TcxImageComboBox;
    PanelHedef: TPanel;
    cxLabel1: TcxLabel;
    VirmanMiktarHedef: TcxCurrencyEdit;
    ComboVirmanKurHedef: TcxComboBox;
    EditVirmanlKurHedef: TcxCurrencyEdit;
    PanelKarsilikHedef: TPanel;
    cxLabel5: TcxLabel;
    EditKarsiligiHedef: TcxCurrencyEdit;
    ComboKarsiligiKurHedef: TcxComboBox;
    cxCurrencyEdit4: TcxCurrencyEdit;
    cxLabel8: TcxLabel;
    CekSenetKayitTarihi: TcxDateEdit;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VirmanEkrFinishButtonClick(Sender: TObject; var Stop: Boolean);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure dbgrd1DblClick(Sender: TObject);
    procedure KasaGridDblClick(Sender: TObject);
    procedure ListBoxMasrafDblClick(Sender: TObject);
    procedure GridNereyeDblClick(Sender: TObject);
    procedure CekSenetAraTusClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure EditFaturaKDVPropertiesChange(Sender: TObject);
    procedure EditPlanBankaHesapAdiPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CekSenetKrediAraEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure cxgrdceksenetkrediaramaDblClick(Sender: TObject);
    procedure VirmanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure PlanlamaEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FaturaPlanSecEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FaturaPlanSecEkrPage(Sender: TObject);
    procedure TakvimPlanViewDblClick(Sender: TObject);
    procedure CekSenetKrediAraEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure KasaSecimEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuVarTreeClick(Sender: TObject);
    procedure MenuVarTreeDblClick(Sender: TObject);
    procedure MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure MenuEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FormDestroy(Sender: TObject);
    procedure TahsilatEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure TahsilatEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure PlanlamaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure CheckBitisUyarClick(Sender: TObject);
    procedure CheckTaksitClick(Sender: TObject);
    procedure GridKaynakViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure KasaSecimEkrPage(Sender: TObject);
    procedure KasaSecimEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure DisindaTusClick(Sender: TObject);
    procedure GridMasrafViewDblClick(Sender: TObject);
    procedure FaturaPlanSecEkrNextButtonClick(Sender: TObject;
      var Stop: Boolean);
    procedure TakvimFatViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure TakvimPlanViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure PlanSilTusClick(Sender: TObject);
    procedure EditPlanBankaHesapAliciPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelDovizTutarClick(Sender: TObject);
    procedure ComboBoxTahAciklamaDblClick(Sender: TObject);
    procedure ComboBoxTahAciklamaPropertiesChange(Sender: TObject);
    procedure SpinAvansSayPropertiesChange(Sender: TObject);
    procedure EditTahsilatTutarPropertiesChange(Sender: TObject);
    procedure CekSenetKrediAraEkrPage(Sender: TObject);
    procedure ComboBoxOdemeYeriPropertiesCloseUp(Sender: TObject);
    procedure YenilebtnClick(Sender: TObject);
    procedure edCariAdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edCarikodKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboCekSenetKrediDurumPropertiesEditValueChanged(
      Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditTutarKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKaynakKodKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditHedefKodKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VirmanNeredenAc(Secim:Smallint);
    procedure VirmanNereyeAc(SoldakiSecimeGoreAc:Boolean; Secim:Smallint);
    procedure VirmanNereyeQueryAfterScroll(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure MenuMusTreeClick(Sender: TObject);
    procedure TVCekSenetKrediAraDblClick(Sender: TObject);
    procedure TahsilatEkrPage(Sender: TObject);
    procedure PlanlamaEkrPage(Sender: TObject);
    procedure VirmanMiktarKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKarsiligiKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboVirmanKurPropertiesCloseUp(Sender: TObject);
    procedure ComboKarsiligiKurPropertiesCloseUp(Sender: TObject);
    procedure PlanTviewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure EditKarsiligiKurKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RadioBankaKasaPropertiesChange(Sender: TObject);
    procedure ComboSecimPropertiesCloseUp(Sender: TObject);
    procedure LabelCekSenetKodClick(Sender: TObject);
    procedure ComboVirmanKurHedefPropertiesCloseUp(Sender: TObject);
    procedure VirmanMiktarHedefKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKarsiligiHedefKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboCekSenetKrediDurumPropertiesCloseUp(Sender: TObject);
  private
    { Private declarations }
    Valor : Boolean;
    BakiyeAnaparaTut, BakiyeFaizTut, SimdikiFaizTut : Currency;
    PlanTarihi : TDateTime;
    procedure KrediKartiKaydet(Turu: SmallInt);
    procedure KaydetmeIslemleri;
    procedure FaturaTutarHesapla;
    procedure InitDeger(Sayfa : TJvWizardInteriorPage);
    function Kontrol(Alan, Ad : String) : Boolean;
    function DovizIslem(Kur, KarsiligiKur:string) : Real;
    procedure VirmaHedefDoldur;
  public
    { Public declarations }
    SecIslem  : SmallInt; //1 Fat Gir, 2 Fat ??k, 4 Nakit Tah, 5 Havale Tah
    // 7 Nakit ?de, 8 Havale ?de, 21 Virman, 25 ?ek Tah, 26 ?ek ?de
    SecGrup, SecKur : String[30];
    OdemeTalimati : Boolean;
    MASRAFID : String;
    IslemOp : Char;
    KullanilanMenu, PanelGor: SmallInt;
    Id, RehberId, FaturaId, CekSenetId, Tur,Cagiran  : Integer;
    procedure IslemSecildi;
  end;
//Resourcestring
//  kullanilmisserino = 'Bu ?ek ?zerindeki Seri No daha ?nce kullan?lm??t?r.' ;

var
    KasaWizardDlg: TKasaWizardDlg;

implementation

{$R *.dfm}

uses  UMesaj, UKasa, UAnaForm, UReharadlg,UCombo, UBankaSecimi, Fetautil, UFastRap,
      PrjConst,UHizmetAra, UParaDegisiklik, FetaKurulusSiniflari,LocOnFly, URaporAraclari, UGenelAnaSekmeFrame, UVeriMotor;

const
    MasrafGelir=0;
var
    GeldigiEkranAdi, SecilenOdeme : string[25];
    Kapanabilir : Boolean;
    Id1,IdDonus,MasrafOlanId : Integer;

function TKasaWizardDlg.EkranAdiAl: string;
begin
  ///
end;

procedure TKasaWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  ///
end;

procedure TKasaWizardDlg.InitDeger(Sayfa : TJvWizardInteriorPage);
begin
    //svn deneme
   //E?er o sayfa kullan?lacaksa ilk de?er atamalar?n? buradan yap?yoruz

   if Sayfa = PlanlamaEkr then begin
      if SecIslem in [10,11,12,31,32,33,34,35,58,71,72] then
         LabelKanal.Caption := KWOdemeKanali
      else
         LabelKanal.Caption := KWTahsilatKanali;

      DatePesinat.Enabled := not(SecIslem in [25,35]); //KK veya POS ise tarih de?i?mez;
      DateTaksit.Enabled := DatePesinat.Enabled;


      ComboKurPlan.ItemIndex := (ComboKurPlan.RepositoryItem.Properties as TcxComboBoxProperties).Items.IndexOf(CariDoviz);
      //ssssComboBoxOdemeYeri.ItemIndex := 0;
      if Pos('0000', DateTimeToStr(DatePesinat.Date))>0 then
         DatePesinat.Date := Tablo.GENINI.BugunTrh;
   end
   else if Sayfa = TahsilatEkr then begin
       ComboKurTah.ItemIndex := ComboKurTah.Properties.Items.IndexOfName(CariDoviz);
       ComboDovizTutar.Properties.Items := ComboKurTah.Properties.Items;
       ComboDovizTutar.ItemIndex := 0;
   end
end;

procedure TKasaWizardDlg.IslemSecildi;
begin
  SecilenOdeme := '';
  if (RehberId<0)and(SecIslem in [25,35, 61,62,63, 71,72,161]) then begin
    RehberId := Tablo.RehberAra_IDGetir(-99);
    if RehberId < 1 then begin
      Close;
      exit;
    end;
  end;
  TabTakvimFat.active := False;
  TabTakvimPlan.active := False;
  //SabitGiderEkr.Enabled :=  SecIslem in [101,103];
  PlanlamaEkr.Enabled := SecIslem in [25,35, 61,62,63, 71,72,161];// 61:tahsilat plan?  /   71:?deme plan?  //161:?oklu senet
  TahsilatEkr.Enabled :=  (SecIslem in [21,22,31,32,58]); //or ( SecIslem in [40..49]);     // ,103
  KasaSecimEkr.Enabled :=  (SecIslem in [21,22,25,31,32,51,52,53,54]); //or ( SecIslem in [40..49]);    // ,103
  FaturaPlanSecEkr.Enabled := ( SecIslem in [11,12,15,16,21,22,23,24,25,31,32,33,34,35]); //101,103
  VirmanEkr.Enabled := SecIslem in [40..50,57,87,65,75];
  CekSenetKrediAraEkr.Enabled :=  SecIslem in [35,51,52,53,54,58];
  if PlanlamaEkr.Enabled then InitDeger(PlanlamaEkr);
  if TahsilatEkr.Enabled then InitDeger(TahsilatEkr);
  if CekSenetKrediAraEkr.Enabled then InitDeger(CekSenetKrediAraEkr);
end;

procedure TKasaWizardDlg.btn1Click(Sender: TObject);
begin
    SecIslem :=  TBitBtn(Sender).Tag; //?lk se?ilen i?lemi tutuyor
    IslemSecildi;
end;

procedure TKasaWizardDlg.cxgrdceksenetkrediaramaDblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.MenuMusTreeClick(Sender: TObject);
begin                  //11,12,15,16,21,22,23,24,25,31,32,33,34,35,71
  SecIslem := 0;
  KullanilanMenu := 1;
  MenuMusTree.ClearSelection(True);
  if not MenuMusTree.Selected.HasChildren then
    case  MenuMusTree.Selected.SelectedIndex of //?lk se?ilen i?lemi tutuyor
      10,11,12 : MenuEkr.Subtitle.Text := KWMusteriAlacaklandir;
      14,15,16 : MenuEkr.Subtitle.Text := KWMusteriBorclandir;
      21 : MenuEkr.Subtitle.Text := KWNakitGirisiVarsa;
      22 : MenuEkr.Subtitle.Text := KWHesaplarimizaGonderimYapilmissa;
      23 : MenuEkr.Subtitle.Text := KWCekveyaSenetAlinmissa;  //?ek
      24 : MenuEkr.Subtitle.Text := KWCekveyaSenetAlinmissa;  //Senet
      25 : MenuEkr.Subtitle.Text := KWKrediKartiileTahsilat;
      31 : MenuEkr.Subtitle.Text := KWNakitCikisiVarsa;
      32 : MenuEkr.Subtitle.Text := KWHesaplarinaOdemeYapilmissa;
      33 : MenuEkr.Subtitle.Text := KWCekveyaSenetVerilmisse;
      34 : MenuEkr.Subtitle.Text := KWCekveyaSenetVerilmisse;
      35 : MenuEkr.Subtitle.Text := KWKrediKartiileOdeme;
      61 : MenuEkr.Subtitle.Text := KWTahsilatPlani;
      62 : MenuEkr.Subtitle.Text := KWDuzenliTahsilat;
      63 : MenuEkr.Subtitle.Text := KWAvansTahsilati;
      71 : MenuEkr.Subtitle.Text := KWOdemePlani;
      72 : MenuEkr.Subtitle.Text := KWDuzenliOdeme;
      73 : MenuEkr.Subtitle.Text := KWPersonelMaasi;
      161: MenuEkr.Subtitle.Text := Coklu_Senet;
    else
      MenuEkr.Subtitle.Text := KWAksiyonSecin;
    end;
end;

procedure TKasaWizardDlg.MenuVarTreeDblClick(Sender: TObject);
var Stop: Boolean;
    agac : TcxTreeView;
begin
   if KullanilanMenu = 2 then
      agac := MenuVarTree
   else
      agac := MenuMusTree;
   if not agac.Selected.HasChildren then begin
      if (KullanilanMenu = 1)and(MenuMusTree.Selected.SelectedIndex in [10..39]) then begin //belgeleme ise
         SecIslem := MenuMusTree.Selected.SelectedIndex;
         KasaWizardDlg.ModalResult := mrOk
      end else if (KullanilanMenu = 2)and(MenuVarTree.Selected.SelectedIndex in [113,117,121,122,131,132,135]) then begin //belgeleme ise
         SecIslem := MenuVarTree.Selected.SelectedIndex;
         KasaWizardDlg.ModalResult := mrOk
      end else begin
         MenuEkrNextButtonClick(Self, Stop);
         WizardKontrol.SelectNextPage;
      end;
   end;
end;

procedure TKasaWizardDlg.MenuVarTreeClick(Sender: TObject);
begin
   SecIslem := 0;
   KullanilanMenu := 2;
   MenuVarTree.ClearSelection(True);
   if not MenuVarTree.Selected.HasChildren then
      case  MenuVarTree.Selected.SelectedIndex of //?lk se?ilen i?lemi tutuyor
        40 : MenuEkr.Subtitle.Text := KWKasadanKasayaTransfer;
        41 : MenuEkr.Subtitle.Text := KWKasadanBankayaTransfer;
        42 : MenuEkr.Subtitle.Text := KWBankadanKasayaTransfer;
        43 : MenuEkr.Subtitle.Text := KWBankadakiHesaplarArasiTransfer;
        44 : MenuEkr.Subtitle.Text := KWPOSBankaArasiTransfer;
        45 : MenuEkr.Subtitle.Text := KWKasadakiParaylaDovizAlirsa;
        46 : MenuEkr.Subtitle.Text := KWDovizKasasindakiBozdurulacaksa;
        47 : MenuEkr.Subtitle.Text := KWBankadakiParaylaDovizAlirsa;
        48 : MenuEkr.Subtitle.Text := KWDovizHesabindakiBozdurulacaksa;
        50 : MenuEkr.Subtitle.Text := KWBankadaArbitraj;
        51 : MenuEkr.Subtitle.Text := KWEldekiCekBankadanTahsilati;
        52 : MenuEkr.Subtitle.Text := KWEldekiSenetBankadanTahsilati;
        53 : MenuEkr.Subtitle.Text := KWCekBankadanOdenirse;
        54 : MenuEkr.Subtitle.Text := KWSenetBankadanOdenirse;
        57 : MenuEkr.Subtitle.Text := KWKrediOdemesiYapilir;
        58 : MenuEkr.Subtitle.Text := KWAlinmisKrediOdemesiYapilir;
        59 : MenuEkr.Subtitle.Text := KWKrediGirisi;
        87 : MenuEkr.Subtitle.Text := KWKrediOdemesiIade;
      else
            MenuEkr.Subtitle.Text := KWAksiyonSecin;
      end;
end;

procedure TKasaWizardDlg.dbgrd1DblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.DisindaTusClick(Sender: TObject);
begin
   SecilenOdeme := '';
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.edCariAdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CekSenetAraTusClick(Self);
end;

procedure TKasaWizardDlg.edCarikodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CekSenetAraTusClick(Self);
end;

procedure TKasaWizardDlg.EditFaturaKDVPropertiesChange(Sender: TObject);
begin
   //if not CheckFatDetay.Checked then
   //  EditFaturaTutar.Value :=  EditKDVSIZ.Value + EditFaturaKDV.Value
end;

procedure TKasaWizardDlg.EditHedefKodKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   VirmanNereyeAc(VirmanNerdenQuery.RecordCount>0, SecIslem);
end;

procedure TKasaWizardDlg.EditKarsiligiHedefKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if PanelKarsilikHedef.Visible then begin
      if (ComboVirmanKurHedef.EditValue=CariDoviz)and(EditKarsiligiHedef.Value>0) then
         EditVirmanlKurHedef.Value := VirmanMiktarHedef.Value / EditKarsiligiHedef.Value
      else if ComboVirmanKurHedef.EditValue<>CariDoviz then
         EditVirmanlKurHedef.Value := EditKarsiligiHedef.Value /  VirmanMiktarHedef.Value;
   end;
end;

procedure TKasaWizardDlg.EditKarsiligiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if PanelKarsilik.Visible then begin
      if (SecIslem = 50)and(EditArbitrajKarsilik.Value>0) then begin//arbitraj
         if EditKarsiligi.Value>0 then
            EditKarsiligiKur.Value := EditArbitrajKarsilik.Value /  EditKarsiligi.Value
      end else if (ComboVirmanKur.EditValue=CariDoviz)and(EditKarsiligi.Value>0) then
         EditVirmanlKur.Value := VirmanMiktar.Value / EditKarsiligi .Value
      else if ComboVirmanKur.EditValue<>CariDoviz then
         EditVirmanlKur.Value := EditKarsiligi.Value /  VirmanMiktar.Value;
   end;


{   case SecIslem of
     45,47: if EditKarsiligi.Value>0 then
            EditVirmanlKur.Value := VirmanMiktar.Value / EditKarsiligi.Value;
     46,48: if VirmanMiktar.Value>0 then
         EditVirmanlKur.Value :=EditKarsiligi .Value / VirmanMiktar.Value;
   end;}
end;

procedure TKasaWizardDlg.EditKarsiligiKurKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
   if (SecIslem = 50)and(EditArbitrajKarsilik.Value>0) then begin//arbitraj
      if EditKarsiligiKur.Value>0 then
         EditKarsiligi.Value := EditArbitrajKarsilik.Value / EditKarsiligiKur.Value
   end
end;

procedure TKasaWizardDlg.EditKaynakKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   VirmanNeredenAc(SecIslem);
  //VirmanEkrEnterPage(Self,VirmanEkr);
end;

procedure TKasaWizardDlg.EditPlanBankaHesapAdiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPNO, HESAPADI, KUR,KASAID,KASAKODU,KASAADI : string;
     i : SmallInt;
begin
   if SecIslem in [35,61,62,71,72,161] then begin
      HESAPID :='-1';
      i:=23;
   end
   else begin
      HESAPID := IntToStr(RehberId);
      i:=4;
   end;
   case ComboBoxOdemeYeri.ItemIndex of
     0 : ShowMessage(KWOnceOdemeKanaliSec);
     1 : if Tablo.KasaHesapEkrani(KASAID,KASAKODU,KASAADI,KUR) then begin
            EditPlanBankaHesapGon.Text :=  KASAADI;
            LabelPlanBankaHesapNoGon.Caption :=  KASAKODU;
            LabelPlanBankaHesapIdGon.Caption := KASAID ;
         end;
     2 : if Tablo.BankaHesapEkrani(i,HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
            EditPlanBankaHesapGon.Text :=  HESAPADI;
            LabelPlanBankaHesapNoGon.Caption :=  HESAPKODU;
            LabelPlanBankaHesapIdGon.Caption :=  HESAPID;
         end;
   end;
end;

procedure TKasaWizardDlg.EditPlanBankaHesapAliciPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPNO, HESAPADI, KUR,KASAID,KASAKODU,KASAADI : string;
     i:SmallInt;
begin
   if SecIslem in [35,71,72] then begin
      HESAPID := IntToStr(RehberId);
      i:=41;
   end
   else begin
      HESAPID :='-1';
      i:=23;
   end;
   if Tablo.BankaHesapEkrani(i,HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      EditPlanBankaHesapAlici.Text :=  HESAPADI;
      LabelPlanBankaHesapNoAl.Caption :=  HESAPKODU;
      LabelPlanBankaHesapIdAl.Caption :=  HESAPID;
   end;
end;

procedure TKasaWizardDlg.EditTahsilatTutarPropertiesChange(Sender: TObject);
begin
   if PanelTaksitBilgisi.Visible then
      SpinAvansSayPropertiesChange(Self);
end;

procedure TKasaWizardDlg.EditTutarKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  YenilebtnClick(Self);
end;

procedure TKasaWizardDlg.FaturaPlanSecEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var bas,bit : SmallInt;
begin
   SecilenOdeme := '';
   GeldigiEkranAdi := FromPage.Name;
   //?deme yap?lacaksa gelen faturalar ??ks?n
   if SecIslem in [31,32,33,34,35,71,72] then
       begin bas := 10; bit := 12 end
       else begin bas := 14; bit := 16 end;
   TabloYenile(TabTakvimFat, [RehberId, bas, bit]);
   PanelPlanFat.Visible := TabTakvimFat.RecordCount > 0;
   GridTakvimFat.Visible := PanelPlanFat.Visible;
   if GridTakvimFat.Visible then
      SecilenOdeme :=  'Fatura';

   if SecIslem in [31,32,33,34,35,71,72] then
       begin bas := 71; bit := 75 end
       else begin bas := 61; bit := 65 end;
   TabloYenile(TabTakvimPlan, [RehberId, bas, bit]);
   PanelPlanOde.Visible := TabTakvimPlan.RecordCount > 0;
   GridTakvimPlan.Visible := PanelPlanOde.Visible;
   if GridTakvimPlan.Visible then
      SecilenOdeme := 'Plan';
end;

procedure TKasaWizardDlg.FaturaPlanSecEkrNextButtonClick(Sender: TObject;  var Stop: Boolean);
begin
   if SecilenOdeme = 'Fatura' then begin //e?er ?deme plan? veya fat varsa onun ID'sini ?demenin FatId'sine kaydedelim
      PlanTarihi := TabTakvimFat.FieldByName('TARIH').AsDateTime;
      FaturaId := TabTakvimFat.FieldByName('FATURAID').AsInteger;
   end
   else if SecilenOdeme = 'Plan' then begin //e?er ?deme plan? veya fat varsa onun ID'sini ?demenin FatId'sine kaydedelim
      PlanTarihi := TabTakvimPlan.FieldByName('TARIH').AsDateTime;
      FaturaId := TabTakvimPlan.FieldByName('FATURAID').AsInteger;
   end
   else begin
      PlanTarihi := KasaTarihi.date;
      FaturaId := -1;
   end;
end;

procedure TKasaWizardDlg.FaturaPlanSecEkrPage(Sender: TObject);
begin
   if (TabTakvimFat.RecordCount < 1)and(TabTakvimPlan.RecordCount < 1) then begin//e?er daha ?nceden girilmi? fatura ya da ?deme plan? yoksa se?ilecek bi?ey de yok demektir
      if (GeldigiEkranAdi = 'MenuEkr')then
         WizardKontrol.SelectNextPage
      else
         WizardKontrol.SelectPriorPage;
   end;
end;

procedure TKasaWizardDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Kapanabilir
end;

procedure TKasaWizardDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
   FaturaId := -1;
   KullanilanMenu := 1;
   OdemeTalimati := False;
   SecIslem := 0;
   cxFormatController.UseDelphiDateTimeFormats := True;
   KasaWizardDlg.RehberId := -1;
   Kapanabilir := True;

   Tablo.GridTurkcelestir;

 end;

procedure TKasaWizardDlg.FormDestroy(Sender: TObject);
begin
   KasaWizardDlg := nil;
end;

procedure TKasaWizardDlg.FormShow(Sender: TObject);
var i:Integer;
//  ra: string;
//  aktifFrame: TGenelAnaSekmeFrame;
begin
  if islemop = 'D' then
     exit;

//  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
//  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
//  YaziciYaz.Caption := ra;

     ComboSube.EditValue := SubeId;
  if PanelGor = 1 then // 0:iki taraf? g?r; 1 sol taraf?; 2 sa? taraf? g?r
     KasaWizardDlg.PanelSag.Visible := False
  else if PanelGor = 2 then
     KasaWizardDlg.PanelSol.Visible := False;
  // PanelGor = 3 Kasadan ?a?r?lmas? 4 ise Bankadan ?a?r?lmas?

  for I := MenuMusTree.Items.Count - 1 downto 0 do
    case MenuMusTree.Items[i].SelectedIndex of
      0:if (not Tablo.YetkiVarmi(2401,YetkiTur_Gorme))or(PanelGor in [3,4])then //
          MenuMusTree.Items[i].Free;
      1:if (not Tablo.YetkiVarmi(2411,YetkiTur_Gorme))or(PanelGor in [3,4])then //
          MenuMusTree.Items[i].Free;
      10:if (not Tablo.YetkiVarmi(240121,YetkiTur_Gorme))or(PanelGor in [3,4]) then
          MenuMusTree.Items[i].Free;
      11:if (not Tablo.YetkiVarmi(240131,YetkiTur_Gorme))or(PanelGor in [3,4]) then
          MenuMusTree.Items[i].Free;
      12:if (not Tablo.YetkiVarmi(240141,YetkiTur_Gorme))or(PanelGor in [3,4]) then
          MenuMusTree.Items[i].Free;
      13:if (not Tablo.YetkiVarmi(240151,YetkiTur_Gorme))then  // or(PanelGor in [3,4])
          MenuMusTree.Items[i].Free;
      14:if (not Tablo.YetkiVarmi(241121,YetkiTur_Gorme))or(PanelGor in [3,4]) then
          MenuMusTree.Items[i].Free;
      15:if (not Tablo.YetkiVarmi(241131,YetkiTur_Gorme))or(PanelGor in [3,4]) then
          MenuMusTree.Items[i].Free;
      16:if (not Tablo.YetkiVarmi(241141,YetkiTur_Gorme))or(PanelGor in [3,4]) then
          MenuMusTree.Items[i].Free;
      17:if (not Tablo.YetkiVarmi(241151,YetkiTur_Gorme))then  // or(PanelGor in [3,4])
          MenuMusTree.Items[i].Free;
    end;
  for I := MenuVarTree.Items.Count - 1 downto 0 do
    case MenuVarTree.Items[i].SelectedIndex of
     -13: if PanelGor = 4 then MenuVarTree.Items[i].Free;//varl?ktaki tahakkuk b?l?m? sadece kasa i?in ge?erli, bankaysa silinsin
      40: if PanelGor = 4 then MenuVarTree.Items[i].Free;
      //41: if PanelGor = 3 then MenuVarTree.Items[i].Free;
      //42: if PanelGor = 3 then MenuVarTree.Items[i].Free;
      43: if PanelGor = 3 then MenuVarTree.Items[i].Free;
      44: if PanelGor = 3 then MenuVarTree.Items[i].Free;//POS
      45: if (PanelGor = 4)or(not DovizTakibi) then MenuVarTree.Items[i].Free;
      46: if (PanelGor = 4)or(not DovizTakibi) then MenuVarTree.Items[i].Free;
      47: if (PanelGor = 3)or(not DovizTakibi) then MenuVarTree.Items[i].Free;
      48: if (PanelGor = 3)or(not DovizTakibi) then MenuVarTree.Items[i].Free;
      49: if PanelGor in [3, 4] then MenuVarTree.Items[i].Free;
      50: if PanelGor = 3 then MenuVarTree.Items[i].Free;
      121: if PanelGor = 4 then MenuVarTree.Items[i].Free;
      122: if PanelGor = 3 then MenuVarTree.Items[i].Free;
      131: if PanelGor = 4 then MenuVarTree.Items[i].Free;
      132: if PanelGor = 3 then MenuVarTree.Items[i].Free;
      135: if PanelGor in [3, 4] then MenuVarTree.Items[i].Free;
    end;

end;

procedure TKasaWizardDlg.GridKaynakViewCellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   //kasa ??k?? ise ve TL ise TL olan s?f?rdan b?y?k rakamlar?, aksi halde kasa giri? ise kura g?re kasalar? listelesin
   //VirmanMiktar.value := EditTahsilatTutar.Value;
   if SecIslem<>49 then  //CariVirman de?ilse
      VirmanNereyeAc(True, SecIslem);
end;

procedure TKasaWizardDlg.GridMasrafViewDblClick(Sender: TObject);
begin
   WizardKontrol.ButtonFinish.ModalResult := mrOk;
   KaydetmeIslemleri;
end;

procedure TKasaWizardDlg.GridNereyeDblClick(Sender: TObject);
begin                           {
   if  JvWizard.bkFinish in VirmanEkr.VisibleButtons then
       JvWizard.bkFinish.Click
   else
       JvWizard.bkNext.Click;  }
    WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.KasaGridDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.KasaSecimEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   GeldigiEkranAdi := FromPage.Name;
   if SecIslem in [51,52,53,54] then begin //?eki?lemleri ise u ekranda bitsin
      KasaSecimEkr.VisibleButtons :=[bkfinish];
      KasaGridTableView.OnDblClick := WizardKontrolFinishButtonClick;
   end;
end;

procedure TKasaWizardDlg.KasaSecimEkrExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
   if KasaQuery.RecordCount<1 then
      raise Exception.Create(KWOnceHesabiTanimla);
end;

procedure TKasaWizardDlg.KasaSecimEkrPage(Sender: TObject);
var i : SmallInt;
begin
   //kasa ??k?? ise ve TL ise TL olan s?f?rdan b?y?k rakamlar?, aksi halde kasa giri? ise kura g?re kasalar? listelesin
   KasaQuery.Close;
   i := SecIslem;
   case i of
     21,31,41,45,46 : KasaQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, KUR FROM KASALAR WHERE KUR ='''+ComboKurTah.Text+''' order by 1 ';
     22,32,42,43,47,48,50,58 : KasaQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI ,SUBEADI, HESAPNO, KUR  '+
                    ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where KUR = '''+ComboKurTah.Text+''' and KREDIKARTI=0  Order By 1,3 ';
     23 : KasaQuery.SQL.Add(' and HESAPKODU like ''101%'' ');
     33 : KasaQuery.SQL.Add(' and HESAPKODU like ''103%'' ');
     25,44 :{KK ?deme} KasaQuery.SQL.Text := ' SELECT ID, KASAKODU=KODU, KASAADI=ADI, KUR FROM POS WHERE KUR ='''+ComboKurPlan.Text+''' order by 1 ';
     //?ek veya senet tahsilat? var. Se?ilen ?ekin kur bilgisine g?re banka veya kasa listesi al?n?r
     52,53,54{,103} : KasaQuery.SQL.Text := //' SELECT ID, KASAKODU, KASAADI, SUBEADI=NULL, HESAPNO=NULL, KUR FROM KASALAR WHERE DURUM=1 and KUR ='''+CekSenetKrediQuery.FieldByName('KUR').AsString+''''+
                                   //' union all '+
                                   ' Select BH.ID,HESAPKODU AS KASAKODU, HESAPADI AS KASAADI ,SUBEADI, HESAPNO  ,KUR '+
                                   ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where BH.DURUM=1 and BH.REHBERID=-1 and KUR = '''+CekSenetKrediQuery.FieldByName('KUR').AsString+''' and KREDIKARTI=0  Order By 1,3 ';
     51 : KasaQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, SUBEADI=NULL, HESAPNO=NULL, KUR FROM KASALAR WHERE DURUM=1 and KUR ='''+CekSenetKrediQuery.FieldByName('KUR').AsString+''' and KASATUR=100 '+
                                   ' union all '+
                                   ' Select BH.ID,HESAPKODU AS KASAKODU, HESAPADI AS KASAADI ,SUBEADI, HESAPNO  ,KUR '+
                                   ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where BH.DURUM=1 and BH.REHBERID=-1 and KUR = '''+CekSenetKrediQuery.FieldByName('KUR').AsString+''' and KREDIKARTI=0  Order By 1,3 ';


   end;
   KasaQuery.Open;
   if KasaQuery.RecordCount = 1 then begin //e?er tek kasa varsa se?meye gerek yok sonraki sayfaya atlas?n
      if GeldigiEkranAdi = 'TahsilatEkr' then
         WizardKontrol.SelectNextPage
      else
         WizardKontrol.SelectPriorPage;
   end else if KasaQuery.RecordCount > 1 then begin
     //cxGridLevel3.
     KasaGridTableView.ClearItems;
     KasaGridTableView.DataController.CreateAllItems;// CreateAllColumns;
     KasaGridTableView.ApplyBestFit(nil);
//     if (TabTakvimFat.active)and(TabTakvimFat.RecordCount>0) then  //e?er sabit gider ?demesi ise ve daha ?nce plan yap?lm??sa onun bilgilerini getirelim
//        KasaQuery.Locate('ID', AraQuery1.FieldByName('MASRAFID').AsInteger,[])
     if i in[51,53] then begin//?ek ?demesi yada tahsilat?.. banka bilgisi ?ekin i?inde var o bankaya locate olmam?z gerekiyor..
       Tablo.TablodanSorguAc(7,'select HESAPID from CEKLER where ID='+IntToStr(CekSenetId));
       if (Tablo.Query7.RecordCount=1)and(Tablo.Query7.Fields[0].asstring<>'') then
         KasaQuery.Locate('ID',Tablo.Query7.Fields[0].Value,[]);
     end;
   end else begin
     Showmessage(KWKasaVeyaBankaHesabiTanimla);
     close;
   end;
end;

procedure TKasaWizardDlg.MenuEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var i : Integer;

begin
   ComboSube.Visible := SubeVarmi;
   LblSube.Visible := SubeVarmi;

   MenuVarTree.FullExpand;// Items[0].Expanded := True;
   MenuVarTree.FullExpand;// Items[0].Expanded := True;
   if FromPage=nil then
      GeldigiEkranAdi := 'Giri?'
   else
      GeldigiEkranAdi := FromPage.Name;
   {AO 23/06/2025
    soldaki men?den kald?r?ld?
    61:Tahsilat Planla
    71:?deme Planla
    75:Virman Planla
    sa?daki men?den kald?r?ld?
    ?ek ??lemleri alt?nda
    51:?ekin Tahsilat?
    52:SenetinTahsilat?
    53:?ekin ?demesi
    54:Senetin ?demesi
   }
end;

procedure TKasaWizardDlg.MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if SecIslem>0 then exit;
  if (KullanilanMenu=1)and(MenuMusTree.Selected.SelectedIndex in [10..39]) then begin//belgeleme ise
    SecIslem :=  MenuMusTree.Selected.SelectedIndex;
    Stop := True;
    ModalResult := mrOk;
  end else if (KullanilanMenu=2)and(MenuVarTree.Selected.SelectedIndex in [113,117,121,122,131,132,135]) then begin//belgeleme ise
    SecIslem :=  MenuVarTree.Selected.SelectedIndex;
    Stop := True;
    ModalResult := mrOk;
  end else if (KullanilanMenu=1)and(not MenuMusTree.Selected.HasChildren) then begin
      SecIslem :=  MenuMusTree.Selected.SelectedIndex; //?lk se?ilen i?lemi tutuyor
      IslemSecildi;
    end else if (KullanilanMenu=2)and(not MenuVarTree.Selected.HasChildren) then begin
      SecIslem :=  MenuVarTree.Selected.SelectedIndex; //?lk se?ilen i?lemi tutuyor
      IslemSecildi;
    end else
      raise Exception.Create(KWAksiyonSecin);  //'Aksiyon Se?in!'
end;


procedure TKasaWizardDlg.FaturaTutarHesapla;
begin
end;

procedure TKasaWizardDlg.TahsilatEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure RotatifIslemler;
    var   TurList : TStringList;
       OdemeTuru : string;
       BasTarih : TDateTime;
    begin
       //?nce ne ?demesi soral?m.
       TurList := TStringList.Create;
       TurList.Add(KWAnaPara);
       TurList.Add(KWFaiz);
       TurList.Add(KWAnaparaveFaiz);
       if not MesajStrAl(KWLutfenSecin, KWOdemeTuru, 'C', TurList, OdemeTuru, '', 'E', nil, OdemeTuru) then exit;
       TurList.Free;
       //E?er faiz ?demesi ise ne kadar faiz ?demesi var hesaplayal?m
       //Val?r var m? soral?m
       if Application.MessageBox(PChar(KWValorVarmi), pchar(Onay), MB_YESNO) = IDYES then
          Valor := True
       else
          Valor := False;

       BakiyeAnaparaTut := CekSenetKrediQuery.FieldByName('BAKIYE').AsCurrency;
       BakiyeFaizTut := 0;//CekSenetKrediQuery.FieldByName('KALANFAIZ').AsCurrency;

       // son tarihi alal?m
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := ' select '+DbUst(1)+'TARIH, VALOR from  KREDIROTATIF where KREDIID=' +CekSenetKrediQuery.FieldByName('KREDIID').AsString +
                                ' and KREDIREFERANSNO='''+CekSenetKrediQuery.FieldByName('KREDIREFERANSNO').AsString+''' order by ID desc '+DbSinir(1);
       Tablo.Query1.Open;
       if Tablo.Query1.RecordCount>0 then
          SimdikiFaizTut := RotatifHesapla(CekSenetKrediQuery.FieldByName('KREDIID').AsInteger ,Tablo.Query1.FieldByName('VALOR').AsBoolean,Valor,BakiyeAnaparaTut,Tablo.Query1.Fields[0].AsDateTime,KasaTarihi.Date)
       else
          SimdikiFaizTut := 0.0;

      ComboBoxTahAciklama.text := Trim(CekSenetKrediQuery.FieldByName('KREDIREFERANSNO').AsString)+' Ref. ?deme';
      if Pos('Anapara',OdemeTuru)>0 then
         EditTahsilatTutar.Value := BakiyeAnaparaTut
      else
         EditTahsilatTutar.Text := '';

      if Pos('Faiz',OdemeTuru)>0 then begin
         EditFaizTutar.Visible := True;
         LabelFaizTutar.Visible := True;
         EditFaizTutar.Value := BakiyeFaizTut+SimdikiFaizTut + SimdikiFaizTut*BSMV;
      end else begin
         EditFaizTutar.Visible := False;
         LabelFaizTutar.Visible := False;
         EditFaizTutar.Text := ''
      end;
      //bu bilgileri al?yoruz ki, kalandan daha fazla ?deme yapamas?n. Kaydetme a?amas?nda kar??la?t?raca??z..
     // BakiyeAnaparaTut := EditTahsilatTutar.Value;
     // BakiyeFaizTut := EditFaizTutar.Value;
     end;
begin

   GeldigiEkranAdi := FromPage.Name;
   if SecIslem = 58 then begin//kredi ?demesi ise
      TahsilatEkr.VisibleButtons:=[bkback, bkfinish];
   end else
      TahsilatEkr.VisibleButtons:=[bkback, bknext];


   PanelFisBilgi.Visible := SecIslem in [21,31];

   case SecIslem of
      45, 47 : ComboKurTah.ItemIndex := 0;
      46, 48 : ComboKurTah.ItemIndex := 1;
   end;

   if SecIslem in [11,12,31,32,33,58] then begin
      TahsilatEkr.Title.Text := KWOdemeEkrani;
      TahsilatEkr.Subtitle.Text := KWOdemeBilgileriGir;
      Tablo.GENINI.ReadSection(Ops_GELIRAD,ComboBoxTahAciklama.Properties );  //   GELIRAD
      if (SecIslem = 58)and(CekSenetKrediQuery.RecordCount>0) then begin//Kredi geri ?demesi varsa kredi miktar?n? buraya alal?m
         if CekSenetKrediQuery.FieldByName('GENELKREDITIPI').AsInteger=2 then
            RotatifIslemler
         else
            EditTahsilatTutar.Value := CekSenetKrediQuery.FieldByName('BORC').AsCurrency;
         ComboBoxTahAciklama.Text := CekSenetKrediQuery.FieldByName('ADI').AsString+' '+CekSenetKrediQuery.FieldByName('ACIKLAMA').AsString;
      end;
   end else begin
      TahsilatEkr.Title.Text := KWTahsilatEkrani;
      TahsilatEkr.Subtitle.Text := KWTahsilatBilgileriGir;
      Tablo.GENINI.ReadSection(Ops_MASRAFAD,ComboBoxTahAciklama.Properties)  //          MASRAFAD
   end;

   if SecilenOdeme = 'Fatura' then begin //e?er sabit gider ?demesi ise ve daha ?nce plan yap?lm??sa onun bilgilerini getirelim
       ComboBoxTahAciklama.Text := TabTakvimFat.FieldByName('ACIKLAMA').AsString;
       EditTahsilatTutar.Value := TabTakvimFat.FieldByName('TUTAR').AsCurrency;
   end
   else if SecilenOdeme = 'Plan' then begin //e?er sabit gider ?demesi ise ve daha ?nce plan yap?lm??sa onun bilgilerini getirelim
       ComboBoxTahAciklama.Text := TabTakvimPlan.FieldByName('ACIKLAMA').AsString;
       EditTahsilatTutar.Value := TabTakvimPlan.FieldByName('TUTAR').AsCurrency;
   end;
end;

procedure TKasaWizardDlg.TahsilatEkrNextButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
   if SecIslem = 58 then begin
      if (Trim(EditTahsilatTutar.Text) = '')and(Trim(EditFaizTutar.Text) = '') then begin
         ShowMessage(KWAnaparaveFaizTutariGir);
         Stop := True;
      end
      else if (CekSenetKrediQuery.FieldByName('GENELKREDITIPI').AsInteger=2{rotatif})and(EditTahsilatTutar.Value-1.0 > (BakiyeAnaparaTut))or(EditFaizTutar.Value-1.0 > (BakiyeFaizTut+SimdikiFaizTut+(SimdikiFaizTut*BSMV))) then begin
          ShowMessage(KWBakiyedenFazlaOdenemez);
          Stop := True;
      end else begin
          EditFaizTutar.Visible := False;
          LabelFaizTutar.Visible := False;
      end;
   end
   else if Trim(EditTahsilatTutar.Text) = '' then begin
      ShowMessage(KWTutariGiriniz);
      Stop := True;
   end;

   case SecIslem of
      45, 47 : if ComboKurTah.ItemIndex <> 0 then begin
                  ShowMessage(KWDovizdenSonraCikisTLOlmali);
                  Stop := True;
               end;
      46, 48 : if ComboKurTah.ItemIndex = 0 then begin
                  ShowMessage(KWDovizdenSonraCikisTLOlamaz);
                  Stop := True;
               end;
   end;
end;

procedure TKasaWizardDlg.TahsilatEkrPage(Sender: TObject);
begin
   if (SecIslem = 58)and(CekSenetKrediQuery.RecordCount>0) then //Kredi geri ?demesi varsa kredi miktar?n? buraya alal?m
       ComboKurTah.Text := CekSenetKrediQuery.FieldByName('KUR').AsString
   else if SecilenOdeme = 'Fatura' then //e?er sabit gider ?demesi ise ve daha ?nce plan yap?lm??sa onun bilgilerini getirelim
       ComboKurTah.Text := TabTakvimFat.FieldByName('KUR').AsString
   else if SecilenOdeme = 'Plan' then //e?er sabit gider ?demesi ise ve daha ?nce plan yap?lm??sa onun bilgilerini getirelim
       ComboKurTah.Text := TabTakvimPlan.FieldByName('KUR').AsString
   else
       ComboKurTah.Text := CariDoviz;
end;

procedure TKasaWizardDlg.TakvimFatViewCellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  SecilenOdeme := 'Fatura';
end;

procedure TKasaWizardDlg.TakvimPlanViewCellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  SecilenOdeme := 'Plan';
end;

procedure TKasaWizardDlg.TakvimPlanViewDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.TVCekSenetKrediAraDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.SpinAvansSayPropertiesChange(Sender: TObject);
var
    Param : String;
    BasTarih : String[15];
begin
    if WizardKontrol.ActivePage <> TahsilatEkr
       then Exit;

    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'select isnull(MIN(TARIH), getdate()) from PLANMAAS where REHBERID='+IntToStr(RehberId)+' and SIRA = 10 and TARIH>GETDATE()';
    Tablo.Query1.Open; //diyelim ki 5 ve 10 geldi
    if Tablo.Query1.RecordCount < 1 then
       //?deme yap?lacak tarihi girin
       BasTarih := Formatdatetime ('yyyy-mm-dd', Tablo.GENINI.BugunTrh)
    else
      BasTarih := Formatdatetime ('yyyy-mm-dd',Tablo.Query1.Fields[0].AsDateTime);

    TabAvansTakvimi.Close;
    EditTaksitTutar.Value := (EditTutar.Value - EditPesinTutar.Value) / TaksitSay.Value;
    Param := ' SET @TAKSIT='+IntToStr(SpinAvansSay.Value)+
    ' SET @I=1 '+
    ' SET @BASLANGIC= '''+BasTarih+''''+
    ' SET @TUTAR= '+Float_ToStr(EditTahsilatTutar.Value)+
    ' SET @KUR= '''+ComboKurTah.Text+''''+
    ' SET @ACIKLAMA = '''+ComboBoxTahAciklama.Text+''' '+
    ' SET @ONCESONRA = 1';               //  -1 : onceki g?nlere gider, 1: sonraki g?nlere gider
    TabAvansTakvimi.SQL.Text := StringReplace(SQLAvanGeriOdeme.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    TabAvansTakvimi.SQL.Text := StringReplace(TabAvansTakvimi.SQL.text,'SQLKOMUT',Param, [rfReplaceAll]);
    TabAvansTakvimi.Open;
end;

procedure TKasaWizardDlg.PlanlamaEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
     GeldigiEkranAdi := FromPage.Name;

     if (Secislem in [61,71])or(ComboPlanSecim.ItemIndex < 0) then
        ComboPlanSecim.ItemIndex := 0
     else if Secislem = 161 then
        ComboPlanSecim.ItemIndex := 1;

     if ComboPlanSecim.ItemIndex = 1 then
             LabelCekSenetKodClick(self);

     CekSenetKayitTarihi.date := KasaTarihi.Date;

     if OdemeTalimati then
        ComboBoxOdemeYeri.EditValue := 2
     else begin
       Tablo.TablodanSorguAc(2,'select * from KASA where ID='+IntToStr(Id));
       if Tablo.Query2.FieldByName('HESAPTURU').Value = 'B' then
         ComboBoxOdemeYeri.EditValue := 2
       else if Tablo.Query2.FieldByName('HESAPTURU').Value = 'K' then
         ComboBoxOdemeYeri.EditValue := 1
       else
         ComboBoxOdemeYeri.EditValue := 0;
       ComboBoxOdemeYeri.PostEditValue;
     end;
     if SecIslem = 35 then begin //KK veya POS ise tarihi tan?mdan getirelim;
       // hesap kesim tarihi + son ?deme ne zaman
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select isnull(HESAP_KESIM_TARIHI,1)+ isnull(ODEME_GUN_SAYISI,1) as SOT from  KREDIKARTI where ID=' +CekSenetKrediQuery.FieldByName('ID').AsString;
       Tablo.Query1.Open; //diyelim ki 5 ve 10 geldi
       DatePesinat.Date := StrToDateDef(Tablo.Query1.Fields[0].AsString+FormatDateTime(FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh), StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
       //5 i ge?tiyse gelecek ay ge?mediyse bu ay
       if StrToInt(FormatDateTime('dd', Tablo.GENINI.BugunTrh)) > Tablo.Query1.Fields[0].AsInteger then
          DatePesinat.Date := SysUtils.IncMonth(DatePesinat.Date,1);
     end
     else if (SecIslem in [61,71])and(EditTutar.Value = 0)and(ComboPlanSecim.ItemIndex=0) then begin //tah/?deme planlama
          Tablo.TablodanSorguAc(1,' SELECT BORC-ALACAK from [dbo].[fn_CARIHESAPOZETI] ('+IntToStr(RehberId)+','''+CariDoviz+''',0)');
          EditTutar.Value := Tablo.Query1.Fields[0].AsCurrency;
          ComboKurPlan.Text := CariDoviz;
     end;
     if SecGrup='D?zenli ?deme' then begin
        //LabelOdemeTarihi.Caption := 'Son ?deme Tarihi';
        if SecilenOdeme = 'Fatura'   then begin //e?er sabit gider faturas? ise ve daha ?nce tahmini giri? yap?lm??sa onun bilgilerini getirelim
            DatePesinat.Date := TabTakvimFat.FieldByName('TARIH').AsDateTime;
            ComboBoxOdemeYeri.Text := TabDuzenliOdeme.FieldByName('ODEMEYERI').AsString;
            EditPlanBankaHesapGon.Text := TabTakvimFat.FieldByName('HESAPADI').AsString;
            LabelPlanBankaHesapNoGon.Caption := TabTakvimFat.FieldByName('HESAPKODU').AsString;
            LabelPlanBankaHesapIdGon.Caption := TabTakvimFat.FieldByName('HESAPID').AsString;
        end;
     end;
     if SecilenOdeme = 'Fatura' then begin //e?er sabit gider ?demesi ise ve daha ?nce plan yap?lm??sa onun bilgilerini getirelim
        ComboPlanAciklama.Text := TabTakvimFat.FieldByName('ACIKLAMA').AsString;
        EditTutar.Value := TabTakvimFat.FieldByName('TUTAR').AsCurrency;
        ComboKurPlan.Text := TabTakvimFat.FieldByName('KUR').AsString;
     end;
     ComboBoxOdemeYeriPropertiesCloseUp(self);
end;

procedure TKasaWizardDlg.PlanlamaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
     if EditTutar.Text = '' then begin
        ShowMessage(KWTutarKismiBosOlamaz);
        Stop := True;
     end;

     if not TabOdemeTakvimi.Active then
        Yenilebtn.Click;
end;

procedure TKasaWizardDlg.PlanlamaEkrPage(Sender: TObject);
begin
   if {(ID>0) and }(SecIslem in [61,71, 161]) then
       YenilebtnClick(Self);
end;

procedure TKasaWizardDlg.PlanSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := ' delete from KASA where ID = '+TabTakvimPlan.FieldByName('ID').AsString;
     Tablo.Query1.ExecSQL;
     if SecilenOdeme = '' then
        WizardKontrol.SelectNextPage;
  end;
end;

procedure TKasaWizardDlg.PlanTviewCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridTaksit;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := PlanTview;
//  AnaForm.pmGridStil.Tags.Values[GridTaksit.Name] := 'TahOdePlanlamaGridi';
end;

procedure TKasaWizardDlg.RadioBankaKasaPropertiesChange(Sender: TObject);
begin
   case SecIslem of
     57 : if RadioBankaKasa.ItemIndex=0 then  //KK ?deme
             VirmanNeredenAc(57) //banka
          else
             VirmanNeredenAc(570);//Kasa
     87 : if RadioBankaKasa.ItemIndex=0 then //KK ?deme iade
             VirmanNereyeAc(True, 87) //banka
          else
             VirmanNereyeAc(True, 870);//Kasa

   end;
end;

procedure TKasaWizardDlg.VirmanNeredenAc(Secim:Smallint);
begin
   VirmanNerdenQuery.Close;
   case Secim of
     44:begin   //POS Aktar?m?
        VirmanNerdenQuery.SQL.Text := ' SELECT '+DbUst(50)+'ID, KASAKODU=KODU, KASAADI=ADI,BAKIYE, KUR, BANKAHESAPID FROM POS WHERE DURUM=1 '+DbSinir(50);
        if EditKaynakKod.Text<>'' then
          VirmanNerdenQuery.SQL.Add(' and KOD like '''+EditKaynakKod.Text+'%'' ');
        if EditKaynakAd.Text<>'' then
          VirmanNerdenQuery.SQL.Add(' and FIRMA like'''+EditKaynakAd.Text+'%'' ');
        VirmanNerdenQuery.SQL.Add('order by 2,3 ');
     end;
     49:begin
        VirmanNerdenQuery.SQL.Text := ' SELECT '+DbUst(50)+'ID, KASAKODU=KOD, KASAADI=FIRMA FROM REHBER '+DbSinir(50); // , BAKIYE=0, KUR='''+CariDoviz+'''
        VirmanNerdenQuery.SQL.Add(' WHERE ID>0 and DURUM>0  and KOD not in (select  isnull(HESAPKODU,'''') from BANKAHESAPLAR)  ');
        if EditKaynakKod.Text<>'' then
          VirmanNerdenQuery.SQL.Add(' and KOD like ''%'+EditKaynakKod.Text+'%'' ');
        if EditKaynakAd.Text<>'' then
          VirmanNerdenQuery.SQL.Add(' and FIRMA like''%'+EditKaynakAd.Text+'%'' ');
        VirmanNerdenQuery.SQL.Add('order by 2,3 ');
     end;
     40,41,45,46,570 : begin
        VirmanNerdenQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI,BAKIYE, KUR FROM KASALAR where DURUM=1 ';
        if SecIslem in [40,41,45, 46]   then begin
           VirmanNerdenQuery.SQL.Add(' and KUR ='''+ComboVirmanKur.EditValue+'''');
           //ComboKarsiligiKur.EditValue:=CariDoviz;
        end;
//        else if SecIslem=45 then begin
//          VirmanNerdenQuery.SQL.Add(' and KUR ='''+CariDoviz+'''');
//          ComboVirmanKur.EditValue:=CariDoviz;
//        end else if SecIslem=46 then begin
//          VirmanNerdenQuery.SQL.Add(' and KUR <>'''+CariDoviz+'''');
  //        ComboKarsiligiKur.EditValue:=CariDoviz;
//        end; //else
          //VirmanNerdenQuery.SQL.Add(' DURUM=1 ');
        if EditKaynakKod.Text<>'' then
          VirmanNerdenQuery.SQL.Add(' and KASAKODU like '''+EditKaynakKod.Text+'%'' ');
        if EditKaynakAd.Text<>'' then
          VirmanNerdenQuery.SQL.Add(' and KASAADI like'''+EditKaynakAd.Text+'%'' ');
        if SubeVarmi then
           VirmanNerdenQuery.SQL.Add(' and SUBEID='+IntToStr(SubeId)+' order by 2,3 ');
     end;
     42,43,47,48,50,65,57,75 : begin
        VirmanNerdenQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI ,SUBEADI, HESAPNO, BAKIYE, KUR  '+
                ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where BH.REHBERID=-1 and BH.DURUM=1 '; //and ((isnull(KREDIKARTI,0)=1) or (isnull(KREDILIHESAP,0)=1))
{        if SecIslem=47 then begin
           VirmanNerdenQuery.SQL.Add(' and KUR = '''+CariDoviz+'''  ');
           ComboVirmanKur.EditValue:=CariDoviz;
        end else if SecIslem=48 then begin
         //  VirmanNerdenQuery.SQL.Add(' and KUR <> '''+CariDoviz+'''  ');
           ComboKarsiligiKur.EditValue:=CariDoviz;
        end;
}
        if SecIslem in [42,43, 47, 48,50,57]   then begin
           VirmanNerdenQuery.SQL.Add(' and KUR ='''+ComboVirmanKur.EditValue+'''');
           //ComboKarsiligiKur.EditValue:=CariDoviz;
        end;
        if EditKaynakKod.Text<>'' then
           VirmanNerdenQuery.SQL.Add(' and HESAPKODU like '''+EditKaynakKod.Text+'%'' ');
        if EditKaynakAd.Text<>'' then
           VirmanNerdenQuery.SQL.Add(' and HESAPADI like'''+EditKaynakAd.Text+'%'' ');
        if SubeVarmi then
           VirmanNerdenQuery.SQL.Add(' and SUBEID in (0,'+IntToStr(SubeId)+') order by 2,3 ');
     end;
     87:
       VirmanNerdenQuery.SQL.Text := 'SELECT ID,KODU AS KASAKODU,ADI AS KASAADI,KUR,NOSU, SUBEID FROM KREDIKARTI KK where KUR='''+ComboVirmanKur.EditValue+''' order by 2';
   end;
   TabloYenile( VirmanNerdenQuery, []);
   (* 05.05.2025 AO
   GridKaynakView.ClearItems;
   GridKaynakView.DataController.CreateAllItems;// CreateAllColumns;
   GridKaynakView.ApplyBestFit(nil); *) //
end;

procedure TKasaWizardDlg.VirmanNereyeAc(SoldakiSecimeGoreAc:Boolean; Secim:Smallint);
var Key: Word;
    Sube,s:String;
begin
   //if SecIslem in [45, 46, 47, 48, 49] then begin //Bu madde d???ndakilerde ?nce sol taraf sonra sa? taraf se?ilecek
       //kasa ??k?? ise ve TL ise TL olan s?f?rdan b?y?k rakamlar?, aksi halde kasa giri? ise kura g?re kasalar? listelesin
       //VirmanMiktar.value := EditTahsilatTutar.Value;
  if (Secim in [45,46,47,48,50] )and(ComboKarsiligiKur.EditValue=null) then
     exit;
  VirmanNereyeQuery.Close;
  VirmanNereyeQuery.SQL.Text:='';
  if SubeVarmi then
     Sube:=',SUBE=(select FIRMA from REHBER R where R.ID=K.SUBEID) '
  else
     Sube:='';

  case Secim of
     40,42,870:if SoldakiSecimeGoreAc then begin
       VirmanNereyeQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, KUR'+Sube+' FROM KASALAR K ';
       VirmanNereyeQuery.SQL.Add(' WHERE KUR ='''+VirmanNerdenQuery.FieldByName('KUR').AsString+''' ');
       if EditHedefKod.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and KASAKODU like '''+EditHedefKod.Text+'%'' ');
       if EditHedefAd.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and KASAADI like'''+EditHedefAd.Text+'%'' ');
       VirmanNereyeQuery.SQL.Add(' order by 2,3 ');
     end;
     45,46:begin
       VirmanNereyeQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, KUR'+Sube+' FROM KASALAR K ';
       VirmanNereyeQuery.SQL.Add(' WHERE KUR ='''+ComboKarsiligiKur.EditValue+''' ');
       if EditHedefKod.Text<>'' then
          VirmanNereyeQuery.SQL.Add(' and KASAKODU like '''+EditHedefKod.Text+'%'' ');
       if EditHedefAd.Text<>'' then
          VirmanNereyeQuery.SQL.Add(' and KASAADI like'''+EditHedefAd.Text+'%'' ');
       VirmanNereyeQuery.SQL.Add(' order by 2,3 ');
     end;
     47:begin
       VirmanNereyeQuery.SQL.Text := 'Select K.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI, SUBEADI, HESAPNO, KUR'+Sube;
       VirmanNereyeQuery.SQL.Add(' from BANKAHESAPLAR K inner join BANKASUBELER BS on K.BANKASUBELERID = BS.ID ');
       VirmanNereyeQuery.SQL.Add(' WHERE KUR ='''+ComboKarsiligiKur.EditValue+''' ');
//       VirmanNereyeQuery.SQL.Add(' WHERE KUR <>'''+CariDoviz+''' ');
       if EditHedefKod.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and HESAPKODU like '''+EditHedefKod.Text+'%'' ');
       if EditHedefAd.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and HESAPADI like'''+EditHedefAd.Text+'%'' ');
       VirmanNereyeQuery.SQL.Add(' order by 2,3 ');
     end;
     48,50:begin
       VirmanNereyeQuery.SQL.Text := 'Select K.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI'+Sube+', HESAPNO, KUR,K.SUBEID ';
       VirmanNereyeQuery.SQL.Add(' from BANKAHESAPLAR K inner join BANKASUBELER BS on K.BANKASUBELERID = BS.ID ');
       VirmanNereyeQuery.SQL.Add(' WHERE REHBERID=-1 and KUR ='''+ComboKarsiligiKur.EditValue+''' ');
       if EditHedefKod.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and HESAPKODU like '''+EditHedefKod.Text+'%'' ');
       if EditHedefAd.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and HESAPADI like'''+EditHedefAd.Text+'%'' ');
       VirmanNereyeQuery.SQL.Add(' order by 2,3 ');
     end;
     49: if IslemOp = 'E' then begin
             VirmanNereyeQuery.SQL.Text := ' SELECT '+DbUst(50)+'ID, KASAKODU=KOD, KASAADI=FIRMA FROM REHBER K '+DbSinir(50); //  , KUR='''+CariDoviz+''''+Sube+'
             VirmanNereyeQuery.SQL.Add(' WHERE ID>0 and DURUM>0 and KOD not in (select  isnull(HESAPKODU,'''') from BANKAHESAPLAR) ');
             if EditHedefKod.Text<>'' then
               VirmanNereyeQuery.SQL.Add(' and KOD like '''+EditHedefKod.Text+'%'' ');
             if EditHedefAd.Text<>'' then
               VirmanNereyeQuery.SQL.Add(' and FIRMA like'''+EditHedefAd.Text+'%'' ');
             VirmanNereyeQuery.SQL.Add('order by 2,3 ');
         end;
     41,43,65,75,87:if SoldakiSecimeGoreAc then begin
       VirmanNereyeQuery.SQL.Text := 'Select K.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI, SUBEADI, HESAPNO, KUR '+Sube;
       VirmanNereyeQuery.SQL.Add(' from BANKAHESAPLAR K inner join BANKASUBELER BS on K.BANKASUBELERID = BS.ID where K.REHBERID=-1 ');
       VirmanNereyeQuery.SQL.Add(' and K.DURUM=1 and KUR = '''+VirmanNerdenQuery.FieldByName('KUR').AsString+''' ');
       if EditHedefKod.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and HESAPKODU like '''+EditHedefKod.Text+'%'' ');
       if EditHedefAd.Text<>'' then
         VirmanNereyeQuery.SQL.Add(' and HESAPADI like'''+EditHedefAd.Text+'%'' ');
       VirmanNereyeQuery.SQL.Add(' order by 2,3 ');
     end;
     44:if VirmanNerdenQuery.FieldByName('BANKAHESAPID').AsString<>'' then begin
       VirmanNereyeQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI, SUBEADI, HESAPNO, KUR,BH.SUBEID ';
       VirmanNereyeQuery.SQL.Add(' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID  ');
       VirmanNereyeQuery.SQL.Add(' where BH.ID = '+VirmanNerdenQuery.FieldByName('BANKAHESAPID').AsString+' ');
     end;
     57:
       VirmanNereyeQuery.SQL.Text := 'SELECT ID,KODU AS KASAKODU,ADI AS KASAADI,KUR,NOSU, SUBEID FROM KREDIKARTI KK where KUR='''+ComboVirmanKur.EditValue+''' order by 2';
  end;
  if VirmanNereyeQuery.SQL.Text<>'' then begin
     TabloYenile(VirmanNereyeQuery, []);
   (*05.05.2025 AO  GridHedefView.ClearItems;
     GridHedefView.DataController.CreateAllItems;// CreateAllColumns;
     GridHedefView.ApplyBestFit(nil);     *)
     //ComboVirmanKur.EditValue:=VirmanNerdenQuery.FieldByName('KUR').AsString;
  {   if Secim in [46,48] then begin
        //EditVirmanlKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', Tablo.GENINI.BugunTrh), ComboVirmanKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
        Key:=0;
        VirmanMiktarKeyUp(Self, Key, [ssShift]);
     end; }
  end;
   {
   EditVirmanlKur.Visible := (Secim in [45..48])or(ComboVirmanKur.EditValue<>CariDoviz);//D?viz olursa kur de?erini almam?z gerekir
   if EditVirmanlKur.Visible then begin
      if ComboVirmanKur.EditValue<>CariDoviz then
         s:=ComboVirmanKur.EditValue
      else
         s:=ComboKarsiligiKur.EditValue;
      EditVirmanlKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', VirmanTarihi.Date), s, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
   end;
   }
end;


procedure TKasaWizardDlg.VirmanNereyeQueryAfterScroll(DataSet: TDataSet);
//var Key:Word;
begin
  if (VirmanNerdenQuery.Active)and(VirmanNereyeQuery.Active) then begin//(SecIslem<>49)and
     ComboVirmanAciklama.Text := VirmanNerdenQuery.FieldByName('KASAADI').AsString+' > '+VirmanNereyeQuery.FieldByName('KASAADI').AsString;
     {if SecIslem in [45,47] then begin
        ComboKarsiligiKur.EditValue:=VirmanNereyeQuery.FieldByName('KUR').AsString;
        EditVirmanlKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', Tablo.GENINI.BugunTrh), ComboKarsiligiKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
        Key:=0;
        VirmanMiktarKeyUp(Self, Key, [ssShift]);
     end;}
  end;
end;

procedure TKasaWizardDlg.VirmanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var Key: Word;
    Kilit : Boolean;
  procedure VirmanDuzenle;
      var NerdenQuery, NereyeQuery:TFDQuery;
      function POSMasrafIdBul_Islem(Id, GeriDonus:Integer) : Integer;
        begin
           Tablo.TablodanSorguAc(7,//'select * from kasa where ID = '+IntToStr(Id);
              ' select * from kasa where (ID = '+IntToStr(Id) +' and MASRAFID>0) or (TUR=44 and MASRAFID>0 '+
              ' and GERIDONUSID in ('+IntToStr(Id)+','+IntToStr(GeriDonus)+'))');
           if Tablo.Query7.FieldByName('MASRAFID').AsInteger > 0 then begin
              MasrafOlanId:=Tablo.Query7.FieldByName('ID').AsInteger;
              VirmanKomisyon.Value := Tablo.Query7.FieldByName('BORC').AsCurrency;
           end
           else
              Tablo.TablodanSorguAc(7,'select * from kasa where ID = '+IntToStr(Id));
           result:=Tablo.Query7.FieldByName('GERIDONUSID').AsInteger;
        end;
  begin

    if SecIslem = 44 then begin//pos aktar?m?
        Tablo.TablodanSorguAc(7, 'select * from kasa where ID = '+IntToStr(Id));
        ID := POSMasrafIdBul_Islem(Id, Tablo.Query7.FieldByName('GERIDONUSID').AsInteger);
//           if not POSMasrafIdBul_Islem(Tablo.Query7.FieldByName('GERIDONUSID').AsInteger) then
//           else if Tablo.Query7.FieldByName('HESAPID').AsString = 'B' then


     end;


     //birbirine ba?l? 2 sat?r var
     Tablo.TablodanSorguAc(8,'select * from kasa where ID='+IntToStr(Id));
     Tablo.TablodanSorguAc(9,'select * from kasa where ID='+IntToStr(Tablo.Query8.FieldByName('GERIDONUSID').AsInteger));
     Id1:=Id;
     IdDonus:=Tablo.Query8.FieldByName('GERIDONUSID').AsInteger;
     //De?i?kenleri atal?m
     CheckR.Checked := Tablo.Query8.FieldByName('R').AsBoolean=True;
     VirmanTarihi.Date := Tablo.Query8.FieldByName('ISLEMTARIHI').AsDateTime;
     ComboVirmanAciklama.Text := Tablo.Query8.FieldByName('ACIKLAMA').AsString;
     LabelRehberId.Caption:= Tablo.Query8.FieldByName('REHBERID').AsString;
     LabelRehberAd.Caption:= Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query8.FieldByName('REHBERID').AsInteger);
     EditIslemNo.Text := Tablo.Query8.FieldByName('BELGENO').AsString;

     VirmanSube.EditValue := Tablo.Query8.FieldByName('SUBEID').AsInteger;
//     if SecIslem in [46, 48]=False then begin //kasadan, bankadan d?viz sat?? de??lse.. ??nk? bor? taraf? d?viz
         if (SecIslem in [40,41,42, 45, 46, 47, 48, 50])or(Tablo.Query8.FieldByName('ALACAK').AsCurrency > 0) then begin
            NerdenQuery := Tablo.Query8;
            NereyeQuery := Tablo.Query9;
         end else begin
            NerdenQuery := Tablo.Query9;
            NereyeQuery := Tablo.Query8;
         end;
//     end;
     Kilit := False;
    if KilitKontrolEt(2,Secislem,VirmanTarihi.Date,2)then begin
       Kilit := True;
       VirmanEkr.Enabled := False;
       {GridKaynak.Enabled := False;
       GridHedef.Enabled := False;
       PanelVirman.Enabled := False;
       VirmanEkr.EnabledButtons:=bkcancel; }
    end;

     //VirmanMiktar.Value := NerdenQuery.FieldByName('ALACAK').AsCurrency;
     //ComboVirmanKur.Text :=NerdenQuery.FieldByName('KUR').AsString;

     if SecIslem = 49 then begin //cari virman
         VirmanNerdenQuery.Close;
         VirmanNerdenQuery.SQL.Text := ' SELECT '+DbUst(50)+'ID, KASAKODU=KOD, KASAADI=FIRMA FROM REHBER '+     //   , KUR='''+CariDoviz+'''
            ' WHERE ID='+NereyeQuery.FieldByName('HESAPID').AsString+' '+DbSinir(50);
         TabloYenile(VirmanNerdenQuery, []);

         VirmanNereyeQuery.close;
         VirmanNereyeQuery.SQL.Text := ' SELECT '+DbUst(50)+'ID, KASAKODU=KOD, KASAADI=FIRMA FROM REHBER '+    // , KUR='''+CariDoviz+'''
            ' WHERE ID='+NerdenQuery.FieldByName('HESAPID').AsString+' '+DbSinir(50);
         TabloYenile(VirmanNereyeQuery, []);
     end; {else begin
         VirmanNeredenAc(SecIslem);
         VirmanNerdenQuery.Locate('ID',NereyeQuery.FieldByName('HESAPID').AsInteger,[]);
         VirmanNereyeAc(True);
         VirmanNereyeQuery.Locate('ID', NerdenQuery.FieldByName('HESAPID').AsInteger,[]);
     end; }
     if SecIslem = 44 then begin  //POS Aktar?m?
        //AO 18-01-2022
        if VirmanMiktar.Value=0 then
           VirmanMiktar.Value := NereyeQuery.FieldByName('BORC').AsCurrency;
        //
        VirmanNerdenQuery.Locate('ID',NereyeQuery.FieldByName('HESAPID').AsInteger,[]);
        Tablo.TablodanSorguAc(1,'select KOMISYONMASRAFMERKEZI, MASRAFCIKIS from POS where ID='+VirmanNerdenQuery.FieldByName('ID').AsString);
        if Tablo.Query1.Fields[1].AsInteger = 2 then //?nce d??s?n sonra girsin
           VirmanMiktar.Value := NereyeQuery.FieldByName('BORC').AsCurrency + VirmanKomisyon.Value;
        //else
        //   VirmanMiktar.Value := VirmanMiktar.Value + VirmanKomisyon.Value;
     end
     else if SecIslem in [40,41,42,45, 46, 47, 48, 50] then
          VirmanMiktar.Value := NerdenQuery.FieldByName('BORC').AsCurrency
     else
       VirmanMiktar.Value := NerdenQuery.FieldByName('ALACAK').AsCurrency;    // NereyeQuery
     ComboVirmanKur.EditValue :=NerdenQuery.FieldByName('KUR').AsString;
     if ComboVirmanKur.EditValue<>CariDoviz then begin
        PanelKarsilik.Visible := True;
        EditVirmanlKur.Visible :=  True;
     end;
     case SecIslem of
      45,46,47,48,50 : begin//d?viz alma
                    EditKarsiligi.Value := NereyeQuery.FieldByName('ALACAK').AsCurrency;
                    ComboKarsiligiKur.Text :=NereyeQuery.FieldByName('KUR').AsString;
                 end;
      49 : begin//d?viz alma
           EditKarsiligi.Value := NerdenQuery.FieldByName('DOVIZ_TUTARI').AsCurrency;
           ComboKarsiligiKur.Text :=NerdenQuery.FieldByName('DOVIZ_KURU').AsString;

           VirmanMiktarHedef.Value := NereyeQuery.FieldByName('BORC').AsCurrency;
           ComboVirmanKurHedef.EditValue :=NereyeQuery.FieldByName('KUR').AsString;
           EditKarsiligiHedef.Value := NereyeQuery.FieldByName('DOVIZ_TUTARI').AsCurrency;
           ComboKarsiligiKurHedef.Text :=NereyeQuery.FieldByName('DOVIZ_KURU').AsString;
           PanelKarsilikHedef.visible := ComboVirmanKurHedef.EditValue<>CariDoviz;
           EditVirmanlKurHedef.visible := PanelKarsilikHedef.visible;
           Key:=0;
           EditKarsiligiHedefKeyUp(Self,Key,[ssShift]);//Kur de?erini hesaplar
          end;
      else begin
             EditKarsiligi.Value := NerdenQuery.FieldByName('DOVIZ_TUTARI').AsCurrency;
             ComboKarsiligiKur.Text :=NerdenQuery.FieldByName('DOVIZ_KURU').AsString;
          end;
     end;
     if (SecIslem in [40,41,42,50])and(ComboVirmanKur.Text<>CariDoviz) then begin
        EditVirmanlKur.Value := NerdenQuery.FieldByName('DOVIZ_TUTARI').AsCurrency /  NerdenQuery.FieldByName('BORC').AsCurrency;
        if SecIslem = 50 then begin// arbitraj ise
           EditArbitrajKarsilik.Value := NereyeQuery.FieldByName('DOVIZ_TUTARI').AsCurrency;
           EditKarsiligiKur.Value := NereyeQuery.FieldByName('DOVIZ_TUTARI').AsCurrency /  NereyeQuery.FieldByName('ALACAK').AsCurrency;
        end;
     end else begin
        Key:=0;
        EditKarsiligiKeyUp(Self,Key,[ssShift]);//Kur de?erini hesaplar
     end;

     if SecIslem <> 49 then begin
        VirmanNeredenAc(SecIslem);
        VirmanNereyeAc(True, SecIslem);
        if SecIslem in [40,41,42,45, 46, 47, 48, 50] then begin
           VirmanNerdenQuery.Locate('ID', NerdenQuery.FieldByName('HESAPID').AsInteger,[]);
           VirmanNereyeQuery.Locate('ID', NereyeQuery.FieldByName('HESAPID').AsInteger,[]);
        end
        else begin
           VirmanNerdenQuery.Locate('ID',NereyeQuery.FieldByName('HESAPID').AsInteger,[]);
           VirmanNereyeQuery.Locate('ID', NerdenQuery.FieldByName('HESAPID').AsInteger,[]);
        end;
     end;
  end;
begin
   VirmanTarihi.Date := KasaTarihi.Date;
   VirmanSube.EditValue:= ComboSube.EditValue;
   VirmanSube.Visible := SubeVarmi;
   LabelVirmanSube.Visible := SubeVarmi;
   if VirmanSube.EditValue = null then
      VirmanSube.EditValue := SubeId;

   ComboVirmanKur.Properties.Items := Tablo.cxEditRepository1ComboBoxItemKurlar.Properties.Items;//ComboKurTah.Properties.Items;
   ComboVirmanKur.ItemIndex := ComboVirmanKur.Properties.Items.IndexOf(SecKur);
   ComboKarsiligiKur.Properties.Items := Tablo.cxEditRepository1ComboBoxItemKurlar.Properties.Items;


   GeldigiEkranAdi := FromPage.Name;

   case SecIslem of
     40:begin
       RadioBankaKasa.Visible := False;
       LbVarlikTipi.Visible := True;
       CbNakitVarlikTipi.Visible := True;
     end;
     43,44:begin
       LabelKomisyon.Visible := True;
       VirmanKomisyon.Visible := True;
     end;
     45..48 : begin  {2025.06.18
       PanelKarsilik.Visible := True;
       ComboKarsiligiKur.Enabled := SecIslem in [45,47];
       ComboVirmanKur.Enabled := SecIslem in [46,48];}
       if SecIslem in [45,47] then begin
          ComboKarsiligiKur.Properties.Items.Delete(ComboVirmanKur.Properties.Items.IndexOf(CariDoviz));
          ComboKarsiligiKur.ItemIndex:=0;
       end else if SecIslem in [46,48] then begin
          ComboVirmanKur.Properties.Items.Delete(ComboVirmanKur.Properties.Items.IndexOf(CariDoviz));
          ComboVirmanKur.ItemIndex := 0;
          ComboKarsiligiKur.EditValue := CariDoviz;
      end;
     //30.05.24 EditVirmanlKurHedef.Value := DovizIslem(ComboVirmanKurHedef.EditValue, ComboKarsiligiKurHedef.EditValue);
      EditVirmanlKur.Value := DovizIslem(ComboVirmanKur.EditValue, ComboKarsiligiKur.EditValue);
     end;
     49: begin //cariler aras?
            PanelKaynak.Visible := True;
            PanelHedef.Visible := True;
            //ComboVirmanKurHedef.ItemIndex:=ComboVirmanKurHedef.Properties.Items.IndexOf(CariDoviz);
            //ComboKarsiligiKurHedef.ItemIndex := ComboVirmanKurHedef.ItemIndex;

            ComboVirmanKurHedef.Properties.Items := Tablo.cxEditRepository1ComboBoxItemKurlar.Properties.Items;//ComboKurTah.Properties.Items;
            ComboVirmanKurHedef.ItemIndex := ComboVirmanKurHedef.Properties.Items.IndexOf(CariDoviz);
            ComboKarsiligiKurHedef.Properties.Items := Tablo.cxEditRepository1ComboBoxItemKurlar.Properties.Items;
            EditVirmanlKurHedef.EditValue := 1;

         end;
     50: begin
           ComboKarsiligiKur.Enabled := True;
           EditKarsiligiKur.Visible := True;
           EditArbitrajKarsilik.Visible := True;
           ComboVirmanKur.Properties.Items.Delete(ComboVirmanKur.Properties.Items.IndexOf(CariDoviz));
           ComboKarsiligiKur.Properties.Items.Delete(ComboKarsiligiKur.Properties.Items.IndexOf(CariDoviz));
           if ComboVirmanKur.ItemIndex <0 then

           ComboVirmanKur.ItemIndex := 0;
           ComboKarsiligiKur.ItemIndex := 0;
         end;
   end;
   RadioBankaKasa.Visible := SecIslem in [57, 87];//KK ve KK iade

   //VirmanNeredenAc(SecIslem);
   //hem kurlar? getirelim hem de sol taraf? doldural?m
   if ComboVirmanKur.EditValue='' then
      ComboVirmanKur.EditValue:=CariDoviz;
   ComboVirmanKurPropertiesCloseUp(Self);
   (*
   if SecIslem=49 then begin
      VirmanNeredenAc(SecIslem);
      VirmanNereyeAc(True, SecIslem);
   end else begin
       if VirmanNerdenQuery.RecordCount>0 then begin
          GridKaynakView.ClearItems;
          GridKaynakView.DataController.CreateAllItems;// CreateAllColumns;
          GridKaynakView.ApplyBestFit(nil);
       end else begin
          Showmessage(KWKasaVeyaBankaHesabiTanimla);
          close;
       end;
   end;    *)
   //AA VirmanNereyeAc(False);

   if (SecIslem=49)and(islemop = 'E') then begin
      VirmanNeredenAc(SecIslem);
      VirmanNereyeAc(True, SecIslem);
   end;

   if (islemop = 'D')and((SecIslem in [40..50])or(SecIslem in [57, 87])) then begin//57 KK ?deme
      //iki bacakl? i?lemden b?y?k olan ?ift t?kland???nda sorun olmas?n diye k???k Id ye t?klanm?? gibi yap?yoruz..
      Tablo.TablodanSorguAc(1,'select GERIDONUSID from kasa where ID='+IntToStr(Id));
      if Id>Tablo.Query1.FieldByName('GERIDONUSID').AsInteger then //e?er 2.sat?r t?kland?ysa ilk sat?r gibi yapal?m
         Id := Tablo.Query1.FieldByName('GERIDONUSID').AsInteger;
      VirmanDuzenle;
   end;

   if PanelKarsilik.visible then begin
       ComboKarsiligiKur.Enabled :=  ComboKarsiligiKur.EditValue <> CariDoviz;  ///. SecIslem in [41,42,4345,47];
       ComboVirmanKur.Enabled :=   SecIslem in [40,41,42,43,46,48,49];
   end;

   if VirmanNerdenQuery.RecordCount>0 then begin
          GridKaynakView.ClearItems;
          GridKaynakView.DataController.CreateAllItems;// CreateAllColumns;
          GridKaynakView.ApplyBestFit(nil);
   end;
   if VirmanNereyeQuery.RecordCount>0 then begin
          GridHedefView.ClearItems;
          GridHedefView.DataController.CreateAllItems;// CreateAllColumns;
          GridHedefView.ApplyBestFit(nil);
   end;
end;

procedure TKasaWizardDlg.VirmanEkrFinishButtonClick(Sender: TObject;  var Stop: Boolean);
var
  kur,DCinsi, KomMsrAd: String;
  HesapTuru : Char;
  ALACAK, Tutar, DovizTutar, Alacak2,DovizTutar2 : Currency;
  DovizAlis : Boolean;
  ID, ID2, KomMsrID, BakaRehID, CekSenetID,KomMsrIslTuru, VirmanSubesi : Integer;
  cari : string[30];
begin
  if (islemop = 'D')and((SecIslem in [40..50])or(SecIslem in [57, 87]))and(Id1 > 0 ) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where ID in (&id1,&id2) ',['&id1','&id2'],[Id1, IdDonus]);
       if SecIslem = 44 then //pos aktar?m?
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where ID = &id1 ',['&id1'],[MasrafOlanId]);
  end;
  if (not VirmanNereyeQuery.Active)or(VirmanNereyeQuery.RecordCount<1) then begin
    ShowMessage(KWHedefHesapSecYoksaTanimla);
    Stop := True;
    exit;
  end;
  if VirmanMiktar.Text='' then begin
    ShowMessage(KWMiktariGirin);
    Stop := True;
    exit;
  end;

   if KilitKontrolEt(1,SecIslem,VirmanTarihi.Date,2) then begin
      Stop := True;
      exit;
   end;


  if SubeVarmi then
     VirmanSubesi := VirmanSube.EditValue
  else
     VirmanSubesi := -1;
  CekSenetID := 0;
  HesapTuru := ' ';

  if ComboVirmanKur.EditValue <> CariDoviz then
     DovizTutar := EditVirmanlKur.Value*VirmanMiktar.value
  else
     DovizTutar := VirmanMiktar.value;


  if SecIslem = 50 then begin
    HesapTuru := 'B';
    ALACAK := EditKarsiligi.Value;
    //ComboVirmanAciklama.Text := ComboVirmanAciklama.Text + ' ('+VirmanMiktar.Text+ComboVirmanKur.Text+' '+EditVirmanlKur.Text+' ? '+EditKarsiligi.Text+ComboKarsiligiKur.Text+')';
  end else if SecIslem in [45,46,47,48,50] then begin
    ALACAK := EditKarsiligi.Value;
    //ComboVirmanAciklama.Text := ComboVirmanAciklama.Text + ' ('+VirmanMiktar.Text+ComboVirmanKur.Text+' '+EditVirmanlKur.Text+' ? '+EditKarsiligi.Text+ComboKarsiligiKur.Text+')';
  end else if SecIslem in [65,75] then begin
    HesapTuru := 'B';
    ALACAK := VirmanMiktar.value;
  end else if SecIslem in [49] then begin
    HesapTuru := 'C';
    ALACAK := VirmanMiktar.value;
  end else
    ALACAK := VirmanMiktar.value;
  if SecIslem = 49 then begin
    ID := Tablo.KasaKaydet(SecIslem, VirmanTarihi.date,VirmanTarihi.date, VirmanNerdenQuery.FieldByName('ID').AsInteger, ComboVirmanAciklama.Text,
             VirmanNereyeQuery.FieldByName('ID').AsInteger, ComboVirmanKur.text{ VirmanNerdenQuery.FieldByName('KUR').AsString}, CariDoviz,0, 0.0,ALACAK,DovizTutar,-1, -1,-1,-1,-1, VirmanSubesi,HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked);

    if ComboVirmanKur.text = ComboVirmanKurHedef.text then begin //kaynak ve hedef para birimleri ayn? ise kaynak kullan?l?r
       Alacak2 := VirmanMiktar.value;
       DovizTutar2 := DovizTutar;
    end
    else begin
       Alacak2 := VirmanMiktarHedef.value;
       if ComboVirmanKurHedef.EditValue <> CariDoviz then
           DovizTutar2 := EditVirmanlKurHedef.Value*VirmanMiktarHedef.value
        else
           DovizTutar2 := VirmanMiktarHedef.value;
    end;
    ID2 := Tablo.KasaKaydet(SecIslem, VirmanTarihi.date, VirmanTarihi.date,VirmanNereyeQuery.FieldByName('ID').AsInteger, ComboVirmanAciklama.Text,
              VirmanNerdenQuery.FieldByName('ID').AsInteger,ComboVirmanKurHedef.text{VirmanNereyeQuery.FieldByName('KUR').AsString}, CariDoviz, 0,Alacak2,0, DovizTutar2,-1, -1,-1,-1, ID, VirmanSubesi,HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked);
  end else begin
    if SecIslem =57 then begin//Kredi kart? ?deme "B" ile banka ?demesi
       if RadioBankaKasa.ItemIndex=0 then
          HesapTuru := 'B'
       else
          HesapTuru := 'K'
    {end else if SecIslem=87 then begin//Kredi kart? ?deme iade "B" ile banka ?demesi
       if RadioBankaKasa.ItemIndex=0 then
          HesapTuru := 'B'
       else
          HesapTuru := 'K'}
    end else if SecIslem=44 then begin
        Tablo.TablodanSorguAc(1,'select KOMISYONMASRAFMERKEZI, MASRAFCIKIS from POS where ID='+VirmanNerdenQuery.FieldByName('ID').AsString);
        KomMsrID := Tablo.Query1.Fields[0].AsInteger;
        KomMsrIslTuru := Tablo.Query1.Fields[1].AsInteger;
        if KomMsrIslTuru = 2 then
           DovizTutar := DovizTutar - VirmanKomisyon.value;
        HesapTuru := 'P';
    end;
    if SecIslem=40 then begin
      if CbNakitVarlikTipi.EditValue=0 then //Nakit
        HesapTuru := 'K'
      else if CbNakitVarlikTipi.EditValue>0 then begin //Kupon ?e?itleri ?eksenetid ye yaz?l?r
        SecIslem := 81;
        HesapTuru := 'H';
        CekSenetID := CbNakitVarlikTipi.EditValue;
      end else if CbNakitVarlikTipi.EditValue = -1 then begin //hediye ?eki --insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)values(-1005,'Hediye ?eki Virman?',55,-1,55)
        SecIslem := 55;
        HesapTuru := 'H';
      end else if CbNakitVarlikTipi.EditValue = -2 then begin //iade ?eki --insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)values(-1005,'?ade ?eki Virman?',56,-1,56)
        SecIslem := 56;
        HesapTuru := 'H';
      end else begin
        ShowMessage(KTanimsiz_islem);
        ModalResult := mrCancel;
      end;
    end;
    if SecIslem = 87 then// //Kredi kart? ?deme iade veya iade "V" ile Visa ?demesi
       HesapTuru := 'V';

//    if SecIslem=44 then        //Altta posdan d??er //  +VirmanKomisyon.value
//      ID := Tablo.KasaKaydet(SecIslem, KasaTarihi.date,KasaTarihi.date, 0, ComboVirmanAciklama.Text,
//             VirmanNerdenQuery.FieldByName('ID').AsInteger,  VirmanNerdenQuery.FieldByName('KUR').AsString,'',0, VirmanMiktar.value,0.0,0,-1, -1,-1,-1,-1, SubeId,HesapTuru)
//    else
//    if (SecIslem=44)and(KomMsrIslTuru=2) then
//       Tutar := VirmanMiktar.value+VirmanKomisyon.value
//    else


    RehberId := StrToIntDef(LabelRehberId.Caption, 0);

    if (SecIslem=44)and(KomMsrIslTuru=2)  then
            ID := Tablo.KasaKaydet(SecIslem, VirmanTarihi.date,VirmanTarihi.date, RehberId, ComboVirmanAciklama.Text,
                VirmanNerdenQuery.FieldByName('ID').AsInteger,VirmanNerdenQuery.FieldByName('KUR').AsString, CariDoviz,0,
                VirmanMiktar.value - VirmanKomisyon.value,0,DovizTutar,-1, -1,-1,CekSenetID,-1, VirmanSubesi,HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked)
    else
        ID := Tablo.KasaKaydet(SecIslem, VirmanTarihi.date,VirmanTarihi.date, RehberId, ComboVirmanAciklama.Text,
              VirmanNerdenQuery.FieldByName('ID').AsInteger, VirmanNerdenQuery.FieldByName('KUR').AsString, CariDoviz,0,
              VirmanMiktar.value,0,DovizTutar,-1, -1,-1,CekSenetID,-1, VirmanSubesi,HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked);
//    else
//       ID := Tablo.KasaKaydet(SecIslem, KasaTarihi.date,KasaTarihi.date, 0, ComboVirmanAciklama.Text, VirmanNerdenQuery.FieldByName('ID').AsInteger,
//          VirmanNerdenQuery.FieldByName('KUR').AsString,'',0,0,VirmanMiktar.value,0,-1, -1,-1,CekSenetID,-1, SubeId,HesapTuru);
    if SecIslem=75 then
       SecIslem:=65
    else if SecIslem = 57 then// //Kredi kart? ?deme veya iade "V" ile Visa ?demesi
       HesapTuru := 'V'
    else if SecIslem = 87 then begin//Kredi kart? ?deme iade "B" ile banka ?demesi
       if RadioBankaKasa.ItemIndex=0 then
          HesapTuru := 'B'
       else
          HesapTuru := 'K'

    end else if SecIslem=44 then
       HesapTuru := 'B';
    if SecIslem=44 then begin
       if KomMsrIslTuru=1  then
          ID2 := Tablo.KasaKaydet(SecIslem, VirmanTarihi.date+0.001, VirmanTarihi.date+0.001, 0, ComboVirmanAciklama.Text,  //Bankaya giri?             //  +.value
             VirmanNereyeQuery.FieldByName('ID').AsInteger,VirmanNereyeQuery.FieldByName('KUR').AsString,CariDoviz,
             KomMsrID,VirmanKomisyon.value,0,VirmanKomisyon.value{DovizTutar},-1, -1,-1,-1, ID, VirmanSubesi, HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked)

    end else
      ID2 := Tablo.KasaKaydet(SecIslem, VirmanTarihi.date, VirmanTarihi.date, RehberId, ComboVirmanAciklama.Text,
             VirmanNereyeQuery.FieldByName('ID').AsInteger,VirmanNereyeQuery.FieldByName('KUR').AsString,
             CariDoviz,0,0,ALACAK,DovizTutar,-1, -1,-1,CekSenetID, ID, VirmanSubesi, HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked);
    if SecIslem=44 then begin
         if KomMsrIslTuru=1  then
            ID2:=Tablo.KasaKaydet(SecIslem, VirmanTarihi.date,VirmanTarihi.date, 0, ComboVirmanAciklama.Text,
                 VirmanNereyeQuery.FieldByName('ID').AsInteger,  VirmanNereyeQuery.FieldByName('KUR').AsString,
                 CariDoviz,0, 0,VirmanMiktar.value,DovizTutar,-1, -1,-1,-1,ID, VirmanSubesi,HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked)
         else
            ID2:=Tablo.KasaKaydet(SecIslem, VirmanTarihi.date,VirmanTarihi.date, 0, ComboVirmanAciklama.Text,
                 VirmanNereyeQuery.FieldByName('ID').AsInteger,  VirmanNereyeQuery.FieldByName('KUR').AsString,
                 CariDoviz, 0,0,VirmanMiktar.value - VirmanKomisyon.value,DovizTutar,-1, -1,-1,-1,ID, VirmanSubesi,HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked);

    end else if (SecIslem=43)and(VirmanKomisyon.EditValue>0.0) then begin  //Bankalar aras? havale
         if ComboVirmanKur.EditValue <> CariDoviz then
            DovizTutar := EditVirmanlKur.Value*VirmanKomisyon.value
         else if ComboKarsiligiKur.EditValue <> CariDoviz then
            DovizTutar := VirmanKomisyon.value
         else
            DovizTutar := VirmanKomisyon.value;
         KomMsrID := StrToInt(Tablo.GENINI.ReadString(Ops_OpsiyonBanka_MasrafMerkezi,'0'));  // MasrafMerkezi
         Tablo.KasaKaydet(32, VirmanTarihi.date, VirmanTarihi.date, 0, ComboVirmanAciklama.Text,  //Bankaya giri?             //  +.value
             VirmanNerdenQuery.FieldByName('ID').AsInteger, VirmanNerdenQuery.FieldByName('KUR').AsString,CariDoviz,KomMsrID,
             VirmanKomisyon.value,0,DovizTutar,-1, -1,-1,-1, ID, VirmanSubesi,'B',0,0,SiradakiMakbuzNumarasi(32),1,checkR.Checked)
    end;
  end;
  //2 bacakl? i?lemler i?in (d?viz alma bozdurma,para yat?rma vb) GERIDONUSID leerine ba? kurmak i?in birbilerinin ID leri kaydedilir
  if (SecIslem=44)and(KomMsrIslTuru=2) then begin
//     HesapTuru := 'M'; //MASRAF GEL?R
//     ID2 := Tablo.KasaKaydet(SecIslem, KasaTarihi.date, KasaTarihi.date, 0, ComboVirmanAciklama.Text,  //masraf giri? 653
//             KomMsrID,VirmanNereyeQuery.FieldByName('KUR').AsString,'',KomMsrID,0,VirmanKomisyon.value,0,-1, -1,-1,-1, ID, VirmanNereyeQuery.FieldByName('SUBEID').AsInteger,HesapTuru);
     HesapTuru := 'P'; //MASRAF GEL?R
     if VirmanKomisyon.value>0 then
        Tablo.KasaKaydet(SecIslem, VirmanTarihi.date, VirmanTarihi.date, 0, ComboVirmanAciklama.Text,  //masraf giri? 653
             VirmanNerdenQuery.FieldByName('ID').AsInteger,VirmanNereyeQuery.FieldByName('KUR').AsString,CariDoviz,
             KomMsrID,VirmanKomisyon.value,0,VirmanKomisyon.value{d?viztutar},-1, -1,-1,-1, ID, VirmanSubesi,HesapTuru,0,0,EditIslemNo.Text,1,checkR.Checked);
  end;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update KASA set GERIDONUSID = '+IntToStr(ID2)+' where ID = '+IntToStr(ID),[],[]);
  Tablo.SKIslemEkle(230200+SecIslem);
end;

procedure TKasaWizardDlg.VirmanMiktarHedefKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if PanelKarsilikHedef.Visible then begin
      if (ComboVirmanKurHedef.EditValue=CariDoviz)and(EditVirmanlKurHedef.Value>0) then
          EditKarsiligiHedef.Value := VirmanMiktarHedef.Value / EditVirmanlKurHedef.Value
      else if ComboVirmanKurHedef.EditValue<>CariDoviz then
               EditKarsiligiHedef.Value := VirmanMiktarHedef.Value * EditVirmanlKurHedef.Value;
   end;
end;

procedure TKasaWizardDlg.VirmaHedefDoldur;
begin   //cariler aras? transfer
  if (ComboVirmanKur.EditValue = ComboVirmanKurHedef.EditValue) then  //cariler aras? transfer  para birimleri e?itse
      VirmanMiktarHedef.Value := VirmanMiktar.Value
  else
      VirmanMiktarHedef.Value := EditKarsiligi.Value / EditVirmanlKurHedef.Value;
  EditKarsiligiHedef.Value := EditKarsiligi.Value
  //EditKarsiligiHedef.Value := VirmanMiktarHedef.Value * EditVirmanlKurHedef.Value;
end;


procedure TKasaWizardDlg.VirmanMiktarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if PanelKarsilik.Visible then begin
      if (ComboVirmanKur.EditValue=CariDoviz)and(EditVirmanlKur.Value>0) then
         EditKarsiligi.Value := VirmanMiktar.Value / EditVirmanlKur.Value
      else if ComboVirmanKur.EditValue<>CariDoviz then begin
            if SecIslem=50 then begin//arbitraj i?lemi ise
               EditArbitrajKarsilik.Value := VirmanMiktar.Value * EditVirmanlKur.Value;
               if (EditKarsiligiKur.Value<>null)and(EditKarsiligiKur.Value<>0) then
                   EditKarsiligi.Value := EditArbitrajKarsilik.Value / EditKarsiligiKur.Value;
            end else
               EditKarsiligi.Value := VirmanMiktar.Value * EditVirmanlKur.Value;
     end;
     if SecIslem=49 then
        VirmaHedefDoldur;
   end;
end;

procedure TKasaWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Kapanabilir := True;
   Close;
end;

function TKasaWizardDlg.Kontrol(Alan, Ad : String) : Boolean;
Begin
  if Alan='' then
  Begin
    Application.MessageBox(PChar(Ad+BosBirakilamaz),PChar(Uyari),MB_OK+MB_ICONERROR);
    Result := False;
  End
  else
    Result := True;
end;



procedure TKasaWizardDlg.KrediKartiKaydet(Turu: SmallInt);
var PlanTarihi : TDateTime;
    tkst, KasaId : Integer;

begin
   //PlanTarihi := StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900');
   //?nce kasaya toplam olarak kaydedelim
   KasaId := Tablo.KasaKaydet(Turu, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KasaTarihi.date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KasaTarihi.date)),RehberId,
                    ComboPlanAciklama.Text,CekSenetKrediQuery.FieldByName('ID').AsInteger, ComboKurPlan.Text,'', MasrafGelir,0, EditTutar.value,0,-1, FaturaId,-1,-1,-1, SubeId,' ');
   //Sonra kredi kart? planlama tablosuna kaydedlim
   tkst := 0;
   TabOdemeTakvimi.First;
   while not TabOdemeTakvimi.Eof do
   begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Insert Into PLANKREDIKARTI (KASAID, KKID, TARIH, TAKSITNO, TAKSITSAY, TUTAR, KUR, ACIKLAMA, ODENMIS, EKLEYEN,ANIMSAT,SUBEID) values(' +
                 ':KASAID,:KKID,:TARIH,:TAKSITNO,:TAKSITSAY,:TUTAR,:KUR,:ACIKLAMA,:ODENMIS,:EKLEYEN, 0,:SUBEID)';
      Tablo.Query1.ParamByName('KASAID').Value := KasaId;
      Tablo.Query1.ParamByName('KKID').Value := CekSenetKrediQuery.FieldByName('ID').AsInteger;
      Tablo.Query1.ParamByName('TARIH').Value := TabOdemeTakvimi.Fieldbyname('TARIH').Asdatetime;
      Inc(tkst);
      Tablo.Query1.ParamByName('TAKSITNO').Value := tkst;
      Tablo.Query1.ParamByName('TAKSITSAY').Value := TaksitSay.Value;
      Tablo.Query1.ParamByName('TUTAR').Value := TabOdemeTakvimi.Fieldbyname('TUTAR').AsCurrency;
      Tablo.Query1.ParamByName('KUR').Value :=  TabOdemeTakvimi.Fieldbyname('KUR').AsString;
      Tablo.Query1.ParamByName('ACIKLAMA').Value := TabOdemeTakvimi.Fieldbyname('ACIKLAMA').AsString;
      Tablo.Query1.ParamByName('ODENMIS').Value := False;
      Tablo.Query1.ParamByName('EKLEYEN').Value := Kullanan;
      Tablo.Query1.ParamByName('SUBEID').Value := SubeId;
      Tablo.Query1.ExecSQL;
      TabOdemeTakvimi.Next;
   end;
end;

procedure TKasaWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
   KaydetmeIslemleri;
end;

procedure TKasaWizardDlg.YenilebtnClick(Sender: TObject);
var
    uyar : string[10];
    OnceSonra,UyariGun : Smallint;
    Param : String;
begin
    if WizardKontrol.ActivePage <> PlanlamaEkr then
      Exit;
    if RadioOnceSonra1.Checked then
      OnceSonra := 0
    else if RadioOnceSonra2.Checked then
      OnceSonra := -1
    else if RadioOnceSonra3.Checked then
      OnceSonra := 1;
    if CheckBitisUyar.Checked then begin
       uyar := '1';
       UyariGun := SpinUYARIGUN.Value;
    end else begin
       uyar := '0';
       UyariGun := -1;
    end;
    TabOdemeTakvimi.Close;
    if not CheckTaksit.Checked then begin //pe?inse
       TabOdemeTakvimi.SQL.Text:= StringReplace(SQLPlan.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
       with TabOdemeTakvimi.ParamByName('PTAKSIT') do begin DataType := ftSmallint; AsSmallInt := 1; end;
       with TabOdemeTakvimi.ParamByName('PBASLANGIC') do begin DataType := ftDateTime; AsDateTime := DatePesinat.Date; end;
       with TabOdemeTakvimi.ParamByName('PTUTAR') do begin DataType := ftCurrency; AsCurrency := EditTutar.Value; end;
       with TabOdemeTakvimi.ParamByName('PKUR') do begin DataType := ftString; AsString := ComboKurPlan.Text; end;
       with TabOdemeTakvimi.ParamByName('PACIKLAMA') do begin DataType := ftString; AsString := ComboPlanAciklama.Text; end;
       with TabOdemeTakvimi.ParamByName('PUYAR') do begin DataType := ftBoolean; AsBoolean := uyar = '1'; end;
       with TabOdemeTakvimi.ParamByName('PUYARIGUN') do begin DataType := ftSmallint; AsSmallInt := UyariGun; end;
       with TabOdemeTakvimi.ParamByName('PONCESONRA') do begin DataType := ftSmallint; AsSmallInt := OnceSonra; end;
       TabOdemeTakvimi.Open;
    end else begin
     //pe?in + taksit
        EditTaksitTutar.Value := (EditTutar.Value - EditPesinTutar.Value) / TaksitSay.Value;
        Param:='  SET @TAKSIT='+IntToStr(TAKSITSay.Value)+
        ' SET @ARA='+IntToStr(AraSay.Value)+
        ' SET @TARIH_PESIN= '''+Formatdatetime('yyyy-mm-dd',  DatePesinat.Date)+''''+
        ' SET @TARIH_TAKSIT= '''+Formatdatetime('yyyy-mm-dd', DateTaksit.Date)+''''+
        ' SET @TUTAR= '+Float_ToStr(EditTutar.Value)+
        ' SET @TUTAR_PESIN= '+Float_ToStr(EditPesinTutar.Value)+
        ' SET @KUR= '''+ComboKurPlan.Text+''''+
        ' set @UYAR='+ Uyar+
        ' set @UYARIGUN='+ SpinUYARIGUN.Text+
        ' SET @ONCESONRA = '+ IntToStr(OnceSonra);               //  -1 : onceki g?nlere gider, 1: sonraki g?nlere gider
       TabOdemeTakvimi.SQL.Text:= StringReplace(SQLPesin.text,'SQLKOMUT',Param, [rfReplaceAll]);
    end;
   if CheckTaksit.Checked then
      TabOdemeTakvimi.Open;
end;

procedure TKasaWizardDlg.KaydetmeIslemleri;
var     j : SmallInt;
        s : string[10];
        Proje : string;
        ID1,ID2,ID3,ID4:integer;
        DovizTutar:Currency;
        KurDegeri:Real;
        TopluMakbuzno:string;

  procedure AvansKaydet(KasaId,RehberId,TaksitNo, TaksitSay:Integer; Tarih : TDateTime; TUTAR:Currency; Kur,Aciklama :string);
  begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Insert Into PLANAVANS (KASAID,REHBERID,ODENECEKTARIH,TAKSITNO,TAKSITSAY,TUTAR,KUR,ACIKLAMA,ODENMIS,EKLEYEN,SUBEID)values(' +
                                                ':KASAID,:REHBERID,:ODENECEKTARIH,:TAKSITNO,:TAKSITSAY,:TUTAR,:KUR,:ACIKLAMA,0,:EKLEYEN,:SUBEID)';
      Tablo.Query1.ParamByName('KASAID').Value := KasaId;
      Tablo.Query1.ParamByName('REHBERID').Value := RehberId;
      Tablo.Query1.ParamByName('ODENECEKTARIH').Value := Tarih;
      Tablo.Query1.ParamByName('TAKSITNO').Value := TaksitNo;
      Tablo.Query1.ParamByName('TAKSITSAY').Value := TaksitSay;
      Tablo.Query1.ParamByName('TUTAR').Value := TUTAR;
      Tablo.Query1.ParamByName('KUR').Value := Kur;
      Tablo.Query1.ParamByName('ACIKLAMA').Value := Aciklama;
      Tablo.Query1.ParamByName('EKLEYEN').Value := Kullanan;
      Tablo.Query1.ParamByName('SUBEID').Value := SubeId;
      Tablo.Query1.ExecSQL;
  end;

  procedure PlanKaydet;
        var
            PlanID,HId,MHId, Tur: Integer;
            BORC, ALACAK : Currency;
        procedure Insert(PTarih : TDateTime; TUTAR:Currency; ACIKLAMA,KUR :string;Uyarigun :integer; Uyar:Boolean);
        Var
          HesapTuru:string;
        begin
               //11: Giren m??teri faturas? ;;; 101 : Giren sabit gider faturas?
           if SecIslem in [11,12, 71] then begin //101
              Tur := 71; BORC :=0; ALACAK:= TUTAR;
           end else begin
              Tur := 61; BORC := TUTAR; ALACAK := 0;
           end;
           if LabelPlanBankaHesapIdGon.Caption='' then
              HId := 0 else HId := StrToInt(LabelPlanBankaHesapIdGon.Caption);
           if LabelPlanBankaHesapIdAl.Caption='' then
              MHId := 0 else MHId := StrToInt(LabelPlanBankaHesapIdAl.Caption);
           //if FaturaId > 0 then //Fatura varsa durum fatural? yoksa plan diye eklenir
           //   j := 1 else j := 0;
           if Length(ComboBoxOdemeYeri.Text)>0 then
              HesapTuru:=Copy(ComboBoxOdemeYeri.Text,0,1);
           PlanID:=Tablo.PlanKaydet(Tur, KasaTarihi.Date, PTarih, RehberId, ACIKLAMA, HId,MHId, KUR, BORC, ALACAK, 0, FaturaId, MasrafGelir, Uyarigun, Uyar,HesapTuru,0,0);
        end;
  begin
     //eskiyi silelim
     if ID > 0  then
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where ID=&id and TUR in (61, 71)',['&id'],[ID]);

     TabOdemeTakvimi.First;
     while not TabOdemeTakvimi.Eof do begin
         Insert(TabOdemeTakvimi.Fieldbyname('TARIH').Asdatetime, TabOdemeTakvimi.Fieldbyname('TUTAR').AsCurrency, ComboPlanAciklama.Text,TabOdemeTakvimi.Fieldbyname('KUR').AsString,TabOdemeTakvimi.Fieldbyname('UYARIGUN').AsInteger,TabOdemeTakvimi.Fieldbyname('UYAR').AsBoolean);
         Tablo.SablondanAktiviteOlustur(220102,PlanID,TabOdemeTakvimi.Fieldbyname('TARIH').Asdatetime,[ComboPlanAciklama.Text]);
         TabOdemeTakvimi.Next;
     end;
//     end;
//     Close;
  end;
  procedure PlanSenetKaydet;
        var
            SenetID,HId,MHId, Tur: Integer;
            BORC, ALACAK : Currency;
            Komut, Makbuz : string;
        procedure Insert(PTarih : TDateTime; TUTAR:Currency; MakbuzNo, ACIKLAMA,KUR :string;Uyarigun :integer; Uyar:Boolean);
        Var
          HesapTuru:string;
        begin
               //11: Giren m??teri faturas? ;;; 101 : Giren sabit gider faturas?
           if SecIslem in [11,12, 71] then begin //101
              Tur := 140;
           end else begin
              Tur := 130;
           end;

           //Serino i?in bu m??terideki en y?ksek no ya 1 ekleyelim
           Tablo.TablodanSorguAc(2,'SELECT  isnull(MAX(CAST(SERINO AS INT)), 0)+1  as SeriNo FROM CEKLER WHERE ISNUMERIC(SERINO) = 1 and REHBERID='+IntToStr(RehberId));
           // MakbuzNo:=SiradakiMakbuzNumarasi(Tur);
           Komut := 'insert into CEKLER(KOD, REHBERID, TUR, DURUM, TARIH, VADE, TUTAR, KUR, MAKBUZNO, SERINO, MASRAFID, CIROLU, DOVIZ_TUTARI, DOVIZ_KURU, ANIMSAT, EKLEYEN,DEGISTIREN, DEGISTIRMETARIHI,  SUBEID, MUHAKTAR, BASKASININ, EKSTREDEKULLAN, CEKSENET)';
           Komut := Komut + ' values('''+LabelCekSenetKod.Caption+''','+IntToStr(RehberId)+','+IntToStr(Tur)+',1,'''+FormatDateTime('yyyy-mm-dd hh:nn', CekSenetKayitTarihi.Date)+''','''+FormatDateTime('yyyy-mm-dd hh:nn', PTarih)+''','+
                      stringreplace(FloatToStr(TUTAR),',','.',[])+','''+KUR+''','''+MakbuzNo+''','''+Tablo.Query2.Fields[0].AsString+''',-1,0,'+stringreplace(FloatToStr(TUTAR),',','.',[])+','''+KUR+''',0,'+Kullanan+','+Kullanan+',GetDate(),'+IntToStr(SubeId)+',0,0,0,121)';
           SenetID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,Komut+' select scope_identity()',[],[],True);

           Komut := 'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM, REHBERID, BANKAHESAPLARID, EKLEYEN, SUBEID, TIP, DURUM, DOVIZ_TUTARI, DOVIZ_KURU, TUTAR, KUR, EKSTREDEKULLAN)';
           Komut := Komut + ' values('+IntToStr(SenetID)+','''+FormatDateTime('yyyy-mm-dd hh:nn', CekSenetKayitTarihi.Date)+''',130,'+IntToStr(RehberId)+',0,'+ Kullanan+','+IntToStr(SubeId)+',1,1,'+
                      stringreplace(FloatToStr(TUTAR),',','.',[])+','''+KUR+''','+stringreplace(FloatToStr(TUTAR),',','.',[])+','''+KUR+''',0)';
           SenetID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,Komut+' select scope_identity()',[],[],True);

        end;
  begin
     //eskiyi silelim
    // if ID > 0  then
    //    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where ID=&id and TUR in (61, 71)',['&id'],[ID]);

     //makbuzno i?in en y?ksek no ya 1 ekleyelim
     Tablo.TablodanSorguAc(1,'SELECT  isnull(MAX(CAST(MAKBUZNO AS INT)), 0)+1  as MaxMakbuzNo FROM CEKLER WHERE ISNUMERIC(MAKBUZNO) = 1 ');
     Makbuz := Tablo.Query1.Fields[0].AsString;

     TabOdemeTakvimi.First;
     while not TabOdemeTakvimi.Eof do begin
         Insert(TabOdemeTakvimi.Fieldbyname('TARIH').Asdatetime, TabOdemeTakvimi.Fieldbyname('TUTAR').AsCurrency,Makbuz, ComboPlanAciklama.Text,TabOdemeTakvimi.Fieldbyname('KUR').AsString,TabOdemeTakvimi.Fieldbyname('UYARIGUN').AsInteger,TabOdemeTakvimi.Fieldbyname('UYAR').AsBoolean);
        // Tablo.SablondanAktiviteOlustur(220102,SenetID,TabOdemeTakvimi.Fieldbyname('TARIH').Asdatetime,[ComboPlanAciklama.Text]);
         TabOdemeTakvimi.Next;
     end;
//     end;
//     Close;
  end;

   function KaydetCase(Turu:SmallInt):Boolean;
   var
        Acikla:string;
        KasaId : Integer;
        HesapTuru, HesapTur: Char;
        Anapara, Faiz,BorcTutar,AlacakTutar : Currency;
        function KrediKaydet(Tutar,DovizTutar:Currency; RehberId,MasrafId:Integer; AciklamaEk:String; yeri:Integer; yerid:Integer ):Integer;
        begin
           Result := Tablo.KasaKaydet(Turu, KasaTarihi.date, KasaTarihi.date,
                            RehberId, ComboBoxTahAciklama.Text+' '+AciklamaEk,
                            CekSenetKrediQuery.FieldByName('BANKATICARIHESAPID').AsInteger, ComboKurTah.Text, CariDoviz, MasrafId,//MasrafGelir,
                            Tutar, 0, Tutar*KurDegeri,  -1, CekSenetKrediQuery.FieldByName('DETAYID').AsInteger,
                            CekSenetKrediQuery.FieldByName('KREDIID').AsInteger,-1,ID, SubeId,' ',yeri,yerid,CekSenetKrediQuery.FieldByName('BELGENO').AsString);
        end;
   begin
      if KilitKontrolEt(2, Turu, KasaTarihi.date, 2) then
         Abort;


       Result := True;
       case Turu of
         21,22 : begin//M??teriden Tah giri?i
                   Tablo.KasaKaydet(Turu, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KasaTarihi.date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KasaTarihi.date)),RehberId,
                                    ComboBoxTahAciklama.Text,KasaQuery.FieldByName('ID').AsInteger, ComboKurTah.Text,ComboDovizTutar.Text,MasrafGelir,0,EditTahsilatTutar.value,EditDovizTutar.Value,-1, FaturaId,-1,-1,-1, SubeId,' ');
//                   Tablo.KasaUpdate('+',i, KasaQuery.FieldByName('ID').AsInteger, EditTahsilatTutar.value,0);
                 end;
         25,35:  begin//?ek giri?i ve ??k???
                   KrediKartiKaydet(Turu);
                 end;
         31,32:  begin//M??teriye ?deme ??k???  ,103
                   if Turu=31 then
                       HesapTur:='K'
                   else
                       HesapTur:='B';

                   KasaId := Tablo.KasaKaydet(Turu,StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KasaTarihi.date)),StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KasaTarihi.date)),
                         RehberId,
                         ComboBoxTahAciklama.Text,KasaQuery.FieldByName('ID').AsInteger,
                         ComboKurTah.Text,ComboDovizTutar.Text,MasrafGelir,   EditTahsilatTutar.value,0.0,EditDovizTutar.Value,-1, FaturaId,-1,-1,-1, SubeId,' ');
                   //E?er avans ?demesi ise planavans tablosuna kaydetmek laz?m
                   if GridAvansTaksit.Visible then begin
                       TabAvansTakvimi.First;
                       while not TabAvansTakvimi.Eof do
                        begin
                           //AvansKaydet(KasaId,RehberId,TaksitNo, TaksitSay:Integer; Tarih : TDateTime; TUTAR:Currency; Kur,Aciklama :string);
                           {AvansKaydet(KasaId,IntToStr(RehberId), TabAvansTakvimi.Fieldbyname('TAKSITNO').AsInteger,
                              TabAvansTakvimi.Fieldbyname('TAKSITSAY').AsInteger, TabAvansTakvimi.Fieldbyname('TARIH').AsDateTime,
                              TabAvansTakvimi.Fieldbyname('TUTAR').AsCurrency, TabAvansTakvimi.Fieldbyname('KUR').AsString,
                              TabAvansTakvimi.Fieldbyname('ACIKLAMA').AsString); }
                        //PlanKaydet(Tur : Integer; KTarih,PTarih : TDateTime; RehberId:Integer;Aciklama : string; HId:Integer;
                        //Kur :string; Giren, Cikan :Currency; Durum, FaturaId,MasrafId, Uyarigun :integer; Uyar:Boolean);
                          Tablo.PlanKaydet(63,StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KasaTarihi.date)),TabAvansTakvimi.Fieldbyname('TARIH').AsDateTime,
                               RehberId,TabAvansTakvimi.Fieldbyname('ACIKLAMA').AsString,-1,-1,TabAvansTakvimi.Fieldbyname('KUR').AsString,
                               TabAvansTakvimi.Fieldbyname('TUTAR').AsCurrency, 0.0,0,-1,MasrafGelir,-1,False,HesapTur,0,0);
                           TabAvansTakvimi.Next;
                        end;
                   end;
                 end;
    51,52,53,54 :begin //?ek senet tahsilat?
                   if not CekSenetKrediQuery.Locate('ID',CekSenetId,[])then
                    exit;
                   if KasaQuery.FieldByName('HESAPNO').AsString='' then
                      HesapTuru := 'K'
                   else
                      HesapTuru := 'B';
                   if Turu=51 then begin
                      Acikla:=Tablo.AciklamaGetir('CEKLER','SERINO',CekSenetKrediQuery.FieldByName('ID').AsInteger)+' Nolu ?ek Tahsilat?';
                      BorcTutar := 0;
                      AlacakTutar := CekSenetKrediQuery.FieldByName('TUTAR').AsCurrency;
                   end else if Turu=52 then begin
                      Acikla:=Tablo.AciklamaGetir('SENETLER','SERINO',CekSenetKrediQuery.FieldByName('ID').AsInteger)+' Nolu Senet Tahsilat?';
                      BorcTutar := 0;
                      AlacakTutar := CekSenetKrediQuery.FieldByName('TUTAR').AsCurrency;
                   end else if Turu=53 then begin
                      Acikla:=Tablo.AciklamaGetir('CEKLER','SERINO',CekSenetKrediQuery.FieldByName('ID').AsInteger)+' Nolu ?ek ?demesi';
                      BorcTutar := CekSenetKrediQuery.FieldByName('TUTAR').AsCurrency;
                      AlacakTutar := 0;
                   end else if Turu=54 then begin
                      Acikla:=Tablo.AciklamaGetir('SENETLER','SERINO',CekSenetKrediQuery.FieldByName('ID').AsInteger)+' Nolu Senet ?demesi';
                      BorcTutar := CekSenetKrediQuery.FieldByName('TUTAR').AsCurrency;
                      AlacakTutar := 0;
                   end;
                     if CekSenetKrediQuery.FieldByName('KUR').AsString <> CariDoviz then
                        DovizTutar := abs(BorcTutar-AlacakTutar)*DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', KasaTarihi.date), CekSenetKrediQuery.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'))
                      else DovizTutar := abs(BorcTutar-AlacakTutar);

                   Tablo.KasaKaydet(Turu, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn', KasaTarihi.date)),StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn', KasaTarihi.date)),0,Acikla,
                                    KasaQuery.FieldByName('ID').AsInteger,   CekSenetKrediQuery.FieldByName('KUR').AsString,CariDoviz, MasrafGelir,BorcTutar,AlacakTutar,DovizTutar,-1, -1,-1, CekSenetKrediQuery.FieldByName('ID').AsInteger,-1, SubeId,HesapTuru);
                   if Turu in [51,53] then begin  //?ek senet g?ncellemeleri..
                      if Tablo.GENINI.ReadBoolean(Ops_Cekler_CekOdemedeMMSil,False)  then   //    ?ekOdemedeMMSil
                        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKLER set DURUM=2,MASRAFID=-1 where ID=' +CekSenetKrediQuery.FieldByName('ID').AsString,[],[])
                      else
                        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKLER set DURUM=2 where ID=' +CekSenetKrediQuery.FieldByName('ID').AsString,[],[])
                   end else if Turu in [52,54] then begin
                      if Tablo.GENINI.ReadBoolean(Ops_Senetler_SenetOdemedeMMAktar,False) then    //    SenetOdemedeMMAktar
                        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SENETLER set DURUM=2,MASRAFID=-1 where ID=' +CekSenetKrediQuery.FieldByName('ID').AsString,[],[])
                      else
                        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SENETLER set DURUM=2 where ID=' +CekSenetKrediQuery.FieldByName('ID').AsString,[],[])
                   end;
                 end;
         61,71,88,161 : case ComboPlanSecim.ItemIndex of
                      0 : PlanKaydet; //   E?er ?nce SecIslem := 11 veya 15 ise ve vadeli ?deme oluyor
                      1 : PlanSenetKaydet;
                     end;
         58 :    begin//Kredi ?deme ??k???, kredinin al?nd??? hesap m??teri gibi olacak
                   if CekSenetKrediQuery.FieldByName('GENELKREDITIPI').AsInteger=2 then begin //Rotatif kredi tutar ??kan kalan update edilecek
                       Anapara := EditTahsilatTutar.value;
                       Faiz := EditFaizTutar.value;
                       //if CekSenetKrediQuery.FieldByName('KASAYA_DETAYLI').AsBoolean then begin //detyl? kay?tsa anapara ve faiz ayr? ayr?
                          //?NCE Kredihesab?na anaparay? atal?m
                       if Anapara > 0.01 then begin
                          ID:=Tablo.KasaKaydet(Turu, KasaTarihi.date, KasaTarihi.date,0,ComboBoxTahAciklama.Text,
                             CekSenetKrediQuery.FieldByName('KREDIID').AsInteger, ComboKurTah.Text,'', 0,//MasrafGelir,
                             0,Anapara,0, -1,CekSenetKrediQuery.FieldByName('KREDIID').AsInteger,
                             CekSenetKrediQuery.FieldByName('DETAYID').AsInteger,-1,-1, SubeId,'R',0,0,CekSenetKrediQuery.FieldByName('BELGENO').AsString);
                          //Bankadan anaparay? ??k
                          ID2:=KrediKaydet(Anapara,Anapara, 0,CekSenetKrediQuery.FieldByName('MASRAFID').AsInteger,'(Anapara)',
                            TabNo_PLANKREDI,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger);
                       end;
                       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set GERIDONUSID='+IntToStr(ID2)+' where ID='+IntToStr(ID),[],[]);
                       if Faiz > 0.01 then
                             KrediKaydet(Faiz,Faiz, 0,CekSenetKrediQuery.FieldByName('FAIZMASRAFID').AsInteger,'(Faiz)',
                            TabNo_PLANKREDI,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger);
                       //end else

                        // T?m ?demeler bittiyse kapand? olarak i?aretlernir
                      if //(BakiyeAnaparaTut-EditTahsilatTutar.value<1.0)and(BakiyeFaizTut+SimdikiFaizTut+SimdikiFaizTut*BSMV-EditFaizTutar.value < 1.0)and
                         (Application.MessageBox(PChar(KWKrediKapandiOlarakIsaretlensinmi), PChar(Onay), MB_YESNO) = IDYES) then begin
                          Tablo.Query1.Close;
                          Tablo.Query1.SQL.Text := 'update KREDIROTATIF set ODENMIS=1 where KREDIID=' +CekSenetKrediQuery.FieldByName('KREDIID').AsString +' and KREDIREFERANSNO=''' +Trim(CekSenetKrediQuery.FieldByName('KREDIREFERANSNO').AsString)+''' ';
                          Tablo.Query1.ExecSQL;
                      end;
                   end else begin //Di?er kredilerin t?m?
  //                     if CekSenetKrediQuery.FieldByName('KASAYA_DETAYLI').AsBoolean then begin //detyl? kay?tsa anapara ve faiz ayr? ayr?
                          //TabNo_PLANKREDI / CekSenetKrediQuery.FieldByName('DETAYID').AsString
                          if (ComboKurTah.Text <> CariDoviz)and(EditDovizTutar.Visible=False) then begin
                              showmessage(KWDovizKarsiGiriniz);
                              Result := False;
                          end;


                          Tablo.TablodanSorguAc(1, 'select ANAPARA,FAIZ+KKDF+BSMV from PLANKREDI where ID=' +CekSenetKrediQuery.FieldByName('DETAYID').AsString);
                          Anapara := Tablo.Query1.Fields[0].AsCurrency;
                          if ComboKurTah.Text = CariDoviz then
                             KurDegeri := 1
                          else
                             KurDegeri :=  EditDovizKuru.Value;// EditDovizTutar.Value / Anapara;
                          Faiz := Tablo.Query1.Fields[1].AsCurrency;
                          //?NCE Kredihesab?na anaparay? atal?m
                          ID:=Tablo.KasaKaydet(Turu, KasaTarihi.date, KasaTarihi.date,0,ComboBoxTahAciklama.Text+'(Anapara)',
                            CekSenetKrediQuery.FieldByName('KREDIID').AsInteger, ComboKurTah.Text, CariDoviz, 0,//MasrafGelir,
                            0, Anapara, Anapara*KurDegeri, -1,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger,
                            CekSenetKrediQuery.FieldByName('KREDIID').AsInteger,-1,-1, SubeId,'R',
                            TabNo_PLANKREDI,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger,
                            CekSenetKrediQuery.FieldByName('BELGENO').AsString);
                          //Bankadan anaparay? ??k
                          if Anapara > 0.01 then
                             ID2 := KrediKaydet(Anapara,DovizTutar, 0,0,'',TabNo_PLANKREDI,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger);

                          //Bankadan faizi ??k  gerid?n??id ler silme i?lemleri i?in eklenmeli
                          TopluMakbuzno := SiradakiMakbuzNumarasi(Tur);
                          if Faiz > 0.01 then begin
                             if ComboKurTah.Text = CariDoviz then
                                DovizTutar := Faiz
                             else
                                DovizTutar := Faiz * EditDovizKuru.Value;

                             ID3:=KrediKaydet(Faiz,DovizTutar, 0,CekSenetKrediQuery.FieldByName('FAIZMASRAFID').AsInteger,'(Faiz)',TabNo_PLANKREDI,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger);
                             ID4:=Tablo.KasaKaydet(Turu, KasaTarihi.date, KasaTarihi.date,0,ComboBoxTahAciklama.Text+'(Faiz)',
                                  CekSenetKrediQuery.FieldByName('KREDIID').AsInteger, ComboKurTah.Text,CariDoviz, 0, 0, Faiz, Faiz*KurDegeri, -1,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger,
                                  CekSenetKrediQuery.FieldByName('KREDIID').AsInteger,-1,-1, SubeId,'R',TabNo_PLANKREDI,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger,
                                  CekSenetKrediQuery.FieldByName('BELGENO').AsString);


                             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set BELGENO='''+TopluMakbuzno+''' , GERIDONUSID='+IntToStr(ID2)+' where ID='+IntToStr(ID),[],[]);
                             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set BELGENO='''+TopluMakbuzno+''' , GERIDONUSID='+IntToStr(ID3)+' where ID='+IntToStr(ID2),[],[]);
                             //e?er bu kredinin masraf projesi varsa onu update edelim;
                             Tablo.TablodanSorguAc(1, 'select PROJEID from KREDILER where ID='+CekSenetKrediQuery.FieldByName('KREDIID').AsString);
                             if Trim(Tablo.Query1.Fields[0].AsString)<>'' then
                                Proje := ', PROJEID='+Tablo.Query1.Fields[0].AsString
                             else
                                Proje :='';
                             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set BELGENO='''+TopluMakbuzno+''' , GERIDONUSID='+IntToStr(ID4)+Proje+' where ID='+IntToStr(ID3),[],[]);
                             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set BELGENO='''+TopluMakbuzno+''' , GERIDONUSID='+IntToStr(ID)+Proje+' where ID='+IntToStr(ID4),[],[]);
                          end else begin
                             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set BELGENO='''+TopluMakbuzno+''' , GERIDONUSID='+IntToStr(ID)+' where ID='+IntToStr(ID2),[],[]);
                             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set BELGENO='''+TopluMakbuzno+''' , GERIDONUSID='+IntToStr(ID2)+' where ID='+IntToStr(ID),[],[]);
                          end;

                             //                       end else
//                          KrediKaydet(EditTahsilatTutar.value,CekSenetKrediQuery.FieldByName('REHBERID').AsInteger, CekSenetKrediQuery.FieldByName('MASRAFID').AsInteger,'');
                      // ?dendi update edilecek
                       Tablo.Query1.Close;
                       Tablo.Query1.SQL.Text := 'update PLANKREDI set ODENMIS=1 where ID=' +CekSenetKrediQuery.FieldByName('DETAYID').AsString +' and KREDIID=' +CekSenetKrediQuery.FieldByName('KREDIID').AsString;
                       Tablo.Query1.ExecSQL;
                   end;
                   //son ?deme de yap?lm??sa sonland?rma i?lemleri yap?l?r..
                   Tablo.TablodanSorguAc(3,'select count(*) from PLANKREDI where ODENMIS=0 and KREDIID='+CekSenetKrediQuery.FieldByName('KREDIID').AsString);
                   if Tablo.Query3.Fields[0].AsInteger=0 then
                      Tablo.SablondanAktiviteOlustur(250202,CekSenetKrediQuery.FieldByName('KREDIID').AsInteger,Tablo.GENINI.BugunTrh,[ComboPlanAciklama.Text]);
                 end;
       end;
   end;

begin
   Kapanabilir := KaydetCase(SecIslem);
   if Kapanabilir=False then exit;

   if SecIslem in [21,22,23,24,25,31,32,33,34,35] then begin//fatura se?ilmi?se
      if FaturaId > - 1 then //fatura se?ilmi?se
         Tablo.FaturaDurumUpdate(FaturaId,0);
      if SecilenOdeme='Plan' then begin//?deme yap?ld? plan? silebiliriz
         Tablo.Query1.Close;
         //e?er plan miktar? kadar ?deme yap?lm??sa plan silinir aksi halde ?denen kadar eksiltilir
         if Abs(EditTahsilatTutar.Value - TabTakvimPlan.FieldByName('TUTAR').AsCurrency) < 0.1 then
            Tablo.Query1.SQL.Text := 'delete from KASA where ID=' +TabTakvimPlan.FieldByName('ID').AsString
         else begin
               if SecIslem in [31,32,33,34,35] then
                 s := 'ALACAK'
               else
                 s := 'BORC';
            Tablo.Query1.SQL.Text := 'update KASA set '+s+' = '+s+' - '+FExtToStr(EditTahsilatTutar.Value)+' where ID=' +TabTakvimPlan.FieldByName('ID').AsString;
         end;
         Tablo.Query1.ExecSQL;
      end;
   end;
   Tablo.SKIslemEkle(230200+SecIslem);
   if Kapanabilir then
      ModalResult := mrOK;
end;

procedure TKasaWizardDlg.CekSenetKrediAraEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var Sec : SmallInt;
begin
   if SecIslem in [61,71,72] then Exit;

   GeldigiEkranAdi := FromPage.Name;


   Sec := SecIslem;
   case Sec of
   25,35 : begin
             CekSenetKrediAraEkr.Title.Text := KWKrediKartiSec;
             CekSenetAramaPanel.Visible := False;
           end;
   51,52,53,54 : begin//?ek  aranacak
              CekSenetKrediAraEkr.Title.Text := KWCekSenetArama;
              ComboCekSenetKrediDurum.Properties.Items := tablo.imgComboboxInit(' select TUR, AD from ISLEMTURLERI where TUR between 130 and 139 order by 1 ').Items;
              ComboCekSenetKrediDurum.ItemIndex := 0;
           end;
  { 52,54 : begin// senet aranacak
              CekSenetKrediAraEkr.Title.Text := KWCekSenetArama;
              ComboCekSenetKrediDurum.Properties.Items := tablo.imgComboboxInit(' select TUR, AD from ISLEMTURLERI where TUR between 140 and 149 order by 1 ').Items;
              ComboCekSenetKrediDurum.ItemIndex := 1;
           end;  }
    58 : begin//kredi aranacak
              CekSenetKrediAraEkr.Title.Text := KWKrediSec;
              ComboCekSenetKrediDurum.Properties.Items := tablo.imgComboboxInit('select ID=0,ADI='''+KWTumu+''' union all '+
                ' select ID=2,ADI='''+KWOdenmemisler+''' union all select ID=1,ADI='''+KWOdenmisler+'''  ').Items;

            {  CekSenetAramaPanel.Visible := True;
              ComboCekSenetKrediDurum.Clear;
              ComboCekSenetKrediDurum.Properties.Items.Add(KWTumu);
              ComboCekSenetKrediDurum.Properties.Items.Add(KWOdenmemisler);
              ComboCekSenetKrediDurum.Properties.Items.Add(KWOdenmisler); }
              ComboCekSenetKrediDurum.ItemIndex := 1;
           end
   end;

   CekSenetAraTus.Click;
   {//CekSenetKrediTree.
   CekSenetKrediTree.Clear;
   CekSenetKrediTree.DataController.CreateAllItems;// CreateAllColumns;
   CekSenetKrediTree.ApplyBestFit;  }
end;

procedure TKasaWizardDlg.CekSenetKrediAraEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   if SecIslem in [61,71,72] then Exit;
   if (not CekSenetKrediQuery.Active) or (CekSenetKrediQuery.RecordCount<1) then
      raise Exception.Create (KWListedenSec);

   if SecIslem in [51..54] then begin
//       if CekSenetKrediQuery.FieldByName('DURUM').AsInteger = 2 then
//          raise Exception.Create (KWTahsilEdilmis);
       CekSenetId := CekSenetKrediQuery.FieldByName('ID').AsInteger;
   end;


   //CekMiktari := CekSenetAramaDlg.CekSenetQuery.FieldByName('TUTAR').AsFloat;
//   EditVirmanMiktar.Text := CekSenetKrediQuery.FieldByName('TUTAR').AsString;
//   ComboKurVir.ItemIndex := ComboKurVir.Items.IndexOf(CekSenetKrediQuery.FieldByName('KUR').AsString);
//   ComboKurVirChange(Self);

end;

procedure TKasaWizardDlg.CekSenetKrediAraEkrPage(Sender: TObject);
begin
  if SecIslem in [61,71,72] then Exit;
  if (CekSenetId > 0) and (GeldigiEkranAdi = 'MenuEkr') then
     WizardKontrol.ActivePage := KasaSecimEkr;
end;

procedure TKasaWizardDlg.CheckBitisUyarClick(Sender: TObject);
begin
   SpinUYARIGUN.Visible := CheckBitisUyar.Checked;
   LabelUyariGun.Visible := CheckBitisUyar.Checked;
   PlanTviewUYARIGUN.Visible := CheckBitisUyar.Checked;
end;

procedure TKasaWizardDlg.CheckTaksitClick(Sender: TObject);
begin
   TaksitPanel.Visible := CheckTaksit.Checked;
   if CheckTaksit.Checked then begin
      DatePesinat.Left := 225;
      GridTaksit.Visible := True;
    end else begin
      DatePesinat.Left := 101;
      GridTaksit.Visible := False;
    end;
   if SecIslem=35 then begin
      LabelPesin.Visible := False;
      EditPesinTutar.Visible := False;
      LabelPlanlananTarih.Visible :=  not CheckTaksit.Checked;
      DatePesinat.Visible :=  not CheckTaksit.Checked;
      DateTaksit.Date := DatePesinat.Date;
   end
   else begin
       LabelPesin.Visible := CheckTaksit.Checked;
       LabelPlanlananTarih.Visible := not CheckTaksit.Checked;
       EditPesinTutar.Visible := CheckTaksit.Checked;
       DateTaksit.Date := SysUtils.IncMonth(DatePesinat.Date,1);
   end;

   EditPesinTutar.Value := 0;

   YenilebtnClick(Self);
end;

procedure TKasaWizardDlg.ComboBoxOdemeYeriPropertiesCloseUp(Sender: TObject);
begin
   case ComboBoxOdemeYeri.ItemIndex of
     0: PanelOdemeKanali.Visible := False;//yok
     1: begin //kasa
       PanelOdemeKanali.Visible := True;
       Label14.Visible := False;
       EditPlanBankaHesapAlici.Visible := False;
       LabelPlanBankaHesapNoAl.Visible := False;
       LabelPlanBankaHesapIdAl.Visible := False;
     end;
     2: begin //Banka
       PanelOdemeKanali.Visible := True;
       Label14.Visible := True;
       EditPlanBankaHesapAlici.Visible := True;
       LabelPlanBankaHesapNoAl.Visible := True;
       LabelPlanBankaHesapIdAl.Visible := True;
     end;
   end;
   EditPlanBankaHesapGon.Text := '';
   EditPlanBankaHesapAlici.Text := '';
   LabelPlanBankaHesapNoGon.Caption := '-1';
   LabelPlanBankaHesapNoAl.Caption := '-1';
   LabelPlanBankaHesapIdGon.Caption := '-1';
   LabelPlanBankaHesapIdAl.Caption := '-1';
   if ComboBoxOdemeYeri.ItemIndex=2 then begin
     if SecIslem in [35,61,62,71,72] then begin
        EditPlanBankaHesapAlici.Tag := Tablo.VarsayilanBankaIDGetir(RehberId);
        EditPlanBankaHesapGon.Tag := Tablo.VarsayilanBankaIDGetir(-1);
     end else begin
        EditPlanBankaHesapAlici.Tag := Tablo.VarsayilanBankaIDGetir(-1);
        EditPlanBankaHesapGon.Tag := Tablo.VarsayilanBankaIDGetir(RehberId);
     end;
     if EditPlanBankaHesapAlici.Tag = -99 then
        EditPlanBankaHesapAliciPropertiesButtonClick(Self, 0)
     else begin//bilgileri getirelim..
        Tablo.Query2 := Tablo.HesapBilgisiGetirDetay(EditPlanBankaHesapAlici.Tag);
        EditPlanBankaHesapAlici.Text :=  Tablo.Query2.Fieldbyname('BANKAADI').AsString+' '+Tablo.Query2.Fieldbyname('SUBEADI').AsString;
        LabelPlanBankaHesapNoAl.Caption :=  Tablo.Query2.Fieldbyname('HESAPNO').AsString;
        LabelPlanBankaHesapIdAl.Caption :=  InttoStr(EditPlanBankaHesapAlici.Tag);
     end;
     if EditPlanBankaHesapGon.Tag = -99 then
        EditPlanBankaHesapAdiPropertiesButtonClick(Self, 0)
     else begin//bilgileri getirelim..
        Tablo.Query2 := Tablo.HesapBilgisiGetirDetay(EditPlanBankaHesapGon.Tag);
        EditPlanBankaHesapGon.Text :=  Tablo.Query2.Fieldbyname('BANKAADI').AsString+' '+Tablo.Query2.Fieldbyname('SUBEADI').AsString;
        LabelPlanBankaHesapNoGon.Caption :=  Tablo.Query2.Fieldbyname('HESAPNO').AsString;
        LabelPlanBankaHesapIdGon.Caption :=  InttoStr(EditPlanBankaHesapGon.Tag);
     end;
   end;

end;

procedure TKasaWizardDlg.ComboBoxTahAciklamaDblClick(Sender: TObject);
var s : Integer;
begin
   if SecIslem in [11,12,31,32,33,58] then
      s := Ops_GELIRAD // 'GELIRAD'
   else
      s :=Ops_MASRAFAD;// 'MASRAFAD';
   Tablo.GeniniBaslat(s);
   Tablo.GENINI.ReadSection(s,ComboBoxTahAciklama.Properties);
end;

procedure TKasaWizardDlg.ComboBoxTahAciklamaPropertiesChange(Sender: TObject);
begin
   PanelTaksitBilgisi.Visible := Pos('AVANS', UpperCase(ComboBoxTahAciklama.Text))>0;
   GridAvansTaksit.Visible := PanelTaksitBilgisi.Visible;
   if PanelTaksitBilgisi.Visible then
      SpinAvansSayPropertiesChange(Self);
end;

procedure TKasaWizardDlg.ComboCekSenetKrediDurumPropertiesCloseUp(
  Sender: TObject);
begin
  CekSenetAraTus.Click;
end;

procedure TKasaWizardDlg.ComboCekSenetKrediDurumPropertiesEditValueChanged(
  Sender: TObject);
begin
  CekSenetAraTusClick(Self);
end;

procedure TKasaWizardDlg.ComboKarsiligiKurPropertiesCloseUp(Sender: TObject);
var  s : string;
     Key : Word;
begin
   if SecIslem<>49 then begin  //CariVirman de?ilse
       if SecIslem=50 then begin //arbitraj ise alttaki kur de?eri de gelsin
          if ComboKarsiligiKur.EditValue<>null then
             EditKarsiligiKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', VirmanTarihi.Date), ComboKarsiligiKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
       end else
//30.05.24          EditVirmanlKurHedef.Value := DovizIslem(ComboVirmanKurHedef.EditValue, ComboKarsiligiKurHedef.EditValue);
          EditVirmanlKur.Value := DovizIslem(ComboVirmanKur.EditValue, ComboKarsiligiKur.EditValue);
       VirmanNereyeAc(True, SecIslem);
       Key:=0;
       VirmanMiktarKeyUp(Self, Key, [ssShift]);

   end;
end;

procedure TKasaWizardDlg.ComboSecimPropertiesCloseUp(Sender: TObject);
begin
    LabelCekSenetKod.Caption := Tablo.KodBulmaSihirbazi(121, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI','SENETLER', 'KOD');
end;

function TKasaWizardDlg.DovizIslem(Kur, KarsiligiKur:string) : Real;
var  s : string;
begin
      if Kur<>CariDoviz then
         s := Kur
      else if KarsiligiKur <> null then
         s := KarsiligiKur
      else
         s := '';
      if s <> '' then
         Result := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', VirmanTarihi.Date), s, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'))
      else
         Result:=-1;
end;

procedure TKasaWizardDlg.ComboVirmanKurHedefPropertiesCloseUp(Sender: TObject);
begin
   //d?viz se?ildiyyse kar??l??? g?r?ns?n
   PanelKarsilikHedef.Visible := (SecIslem in [45,46,47,48,49,50])or(ComboVirmanKurHedef.EditValue<>CariDoviz);
   if PanelKarsilikHedef.Visible then begin
      if ComboKarsiligiKurHedef.ItemIndex < 0 then
         ComboKarsiligiKurHedef.ItemIndex := ComboVirmanKur.ItemIndex;
      EditVirmanlKurHedef.Visible := True;
      if ComboVirmanKurHedef.EditValue= CariDoviz then
         EditVirmanlKurHedef.EditValue := 1
      else
         EditVirmanlKurHedef.EditValue := DovizIslem(ComboVirmanKurHedef.EditValue, ComboKarsiligiKurHedef.EditValue);
      EditKarsiligiHedef.Value := EditVirmanlKurHedef.Value * VirmanMiktarHedef.Value;
      if SecIslem <> 50 then //arbitraj de?ilse
         ComboKarsiligiKurHedef.editvalue := CariDoviz;
      if SecIslem = 49 then  //cariler aras? transfer
         VirmaHedefDoldur;
   end;
end;

procedure TKasaWizardDlg.ComboVirmanKurPropertiesCloseUp(Sender: TObject);
begin
   //d?viz se?ildiyyse kar??l??? g?r?ns?n
   PanelKarsilik.Visible := (SecIslem in [45,46,47,48,49,50])or(ComboVirmanKur.EditValue<>CariDoviz);
   if PanelKarsilik.Visible then begin
      if ComboKarsiligiKur.ItemIndex < 0 then
         //ComboKarsiligiKur.ItemIndex := ComboVirmanKur.ItemIndex;
         ComboKarsiligiKur.EditValue := CariDoviz;
      EditVirmanlKur.Visible := True;
      EditVirmanlKur.Value := DovizIslem(ComboVirmanKur.EditValue, ComboKarsiligiKur.EditValue);
      EditKarsiligi.Value := EditVirmanlKur.Value * VirmanMiktar.Value;
      if (SecIslem <> 50)and(ComboKarsiligiKur.ItemIndex < 0) then //arbitraj de?ilse ve bo?sa
         ComboKarsiligiKur.editvalue := CariDoviz;
      if SecIslem=49 then  //cariler aras? transfer
         VirmaHedefDoldur;

       ComboKarsiligiKur.Enabled :=  ComboKarsiligiKur.EditValue <> CariDoviz;  ///. SecIslem in [41,42,4345,47];
       ComboVirmanKur.Enabled :=  SecIslem in [40,41,42,43,46,48,49];

   end;

   if SecIslem <> 49 then begin
      VirmanNeredenAc(SecIslem);
      VirmanNereyeAc(True, SecIslem);
   end;
end;

procedure TKasaWizardDlg.CekSenetAraTusClick(Sender: TObject);
var
    Sec,turu,I,tipi: SmallInt;
begin
  Sec := SecIslem;
  if TVCekSenetKrediAra.ColumnCount=0 then begin
    if (not Sec in[35,58])and(edCarikod.Text='')and(edCariAd.Text='')and(ComboCekSenetKrediDurum.Text='') then Exit;
    CekSenetKrediQuery.Close;
    for I := 0 to TVCekSenetKrediAra.ColumnCount - 1 do
       TVCekSenetKrediAra.Columns[0].Destroy;
    TVCekSenetKrediAra.ClearItems;
  end;
  CekSenetKrediQuery.Close;
  case Sec  of
    35 : begin  //kk ?demesi
           CekSenetKrediQuery.SQL.Text := ' SELECT ID, KASAKODU=KODU, KASAADI=ADI, KUR FROM KREDIKARTI order by 1 ';
         end;
  51..54:begin //51-53?ek , 52-54senet
           {if CeksenetId>0 then begin//Banka sekmesinde ?ek listesinden tahsil denmi?se direk o ?ek bilgileri gelmeli
              if Sec in [51,53] then
                 CekSenetKrediQuery.SQL.Text := '  select C.ID,VADE,C.SERINO,C.DURUM,REHBERID,CARIKOD=R.KOD,CARIAD=R.FIRMA,TUTAR ,'+
                                                   '	KUR,NOTLAR FROM CEKLER C inner join REHBER R on C.REHBERID = R.ID where C.ID='+IntToStr(CeksenetId)
             else
                 CekSenetKrediQuery.SQL.Text := '  select C.ID,VADE,C.DURUM,REHBERID,CARIKOD=R.KOD,CARIAD=R.FIRMA,TUTAR ,'+
                                                   '	KUR,NOTLAR FROM SENETLER C inner join REHBER R on C.REHBERID = R.ID where C.ID='+IntToStr(CeksenetId);
           end else begin
                 if ComboCekSenetKrediDurum.Text=KWPortfoyde then
                   turu:=130   //durum:=1
                 else if ComboCekSenetKrediDurum.Text=KWTahsilEdildi then
                   turu:=136  //durum:=2
              //   else if ComboCekSenetKrediDurum.Text=KWCiroEdildi then
              //     durum:=3
                 else if ComboCekSenetKrediDurum.Text=KWCiroEdildi then
                   durum:=4
                 else if ComboCekSenetKrediDurum.Text=KWTahsileVerildi then
                   durum:=5
                 else if ComboCekSenetKrediDurum.Text=KWTeminataVerildi then
                   durum:=6
                 else if ComboCekSenetKrediDurum.Text=KWProtestoEdildi then
                   durum:=7
                 else if ComboCekSenetKrediDurum.Text=KWKarsiligiYok then
                   durum:=8
                 else if ComboCekSenetKrediDurum.Text=KWTahsilEdilemiyor then
                   durum:=9
                 else //t?m? i?in
                   durum:=0;
                  case Sec of
                    51:begin
                      // CekSenetKrediQuery.SQL.Text:=MemoCekSQL.Text;
                       tipi:=101;  //23;
                    end;
                    53:begin
                      // CekSenetKrediQuery.SQL.Text:=MemoCekSQL.Text;
                        tipi:=101;  //33;
                    end;
                    52:begin  //senet
                      // CekSenetKrediQuery.SQL.Text:=MemoCekSQL.Text;
                       tipi:=121;  //24;
                    end;
                    54:begin //senet
                       //CekSenetKrediQuery.SQL.Text:=MemoCekSQL.Text;
                       tipi:=121;  //34;
                    end;
                  end;      }
                  if Sec in [52, 54] then
                     tipi:=121
                  else
                     tipi:=101;
                  CekSenetKrediQuery.SQL.Text:=MemoCekSQL.Text;
                  TabloYenile(CekSenetKrediQuery, [tipi, edCariAd.Text, edCarikod.Text, ComboCekSenetKrediDurum.EditValue]);  //Turu;
          // end;
         end;
    58 : begin //kredi ?demesi
           { if ComboCekSenetKrediDurum.Text=KWOdenmemisler then
              durum:=2
            else if ComboCekSenetKrediDurum.Text=KWOdenmisler then
              durum:=1
            else
              durum:=0; }
            CekSenetKrediQuery.SQL.Text:=MemoKrediler.Text;
            if Id<1 then
               TabloYenile(CekSenetKrediQuery, [ComboCekSenetKrediDurum.EditValue, edCariAd.Text, edCarikod.Text, '%'])
            else
               TabloYenile(CekSenetKrediQuery, [ComboCekSenetKrediDurum.EditValue, edCariAd.Text, edCarikod.Text, Id]);

         end;
  else
    exit;
  end;
  if TVCekSenetKrediAra.ColumnCount=0 then begin
     TVCekSenetKrediAra.DataController.CreateAllItems;
     TVCekSenetKrediAra.ApplyBestFit;
    {if TVCekSenetKrediAra.Columns[0]<>nil then begin
       TVCekSenetKrediAra.Columns[0].Destroy;
    end; }
     if Sec=58 then begin
        TVCekSenetKrediAra.GetColumnByFieldName('ADI').GroupIndex:=0;
        //TVCekSenetKrediAra.DataController.Groups.FullExpand;
    end;
  end;
end;

procedure TKasaWizardDlg.LabelCekSenetKodClick(Sender: TObject);
begin
   ComboSecimPropertiesCloseUp(self);
end;

procedure TKasaWizardDlg.LabelDovizTutarClick(Sender: TObject);
begin
  Application.CreateForm(TParaDegisiklikDlg,Paradegisiklikdlg);
  Paradegisiklikdlg.KurTarihi := KasaTarihi.Date;
  Paradegisiklikdlg.GirenTutar := EditTahsilatTutar.Value;
  Paradegisiklikdlg.GirenKur := ComboKurTah.Text;
  Paradegisiklikdlg.CikanTutar := EditDovizTutar.Value;
  Paradegisiklikdlg.CikanKur := ComboDovizTutar.Text;

  Paradegisiklikdlg.ShowModal;
  if Paradegisiklikdlg.ModalResult = mrOk then begin
     EditDovizTutar.Value := Paradegisiklikdlg.CikanTutar;
     ComboDovizTutar.Text := Paradegisiklikdlg.CikanKur;
     EditDovizTutar.Visible := EditDovizTutar.Value > 0;
     ComboDovizTutar.Visible := EditDovizTutar.Value > 0;
     EditDovizKuru.Value := Paradegisiklikdlg.EditKulKur.Value;
  end;
  Paradegisiklikdlg.Destroy;
end;

procedure TKasaWizardDlg.ListBoxMasrafDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

end.










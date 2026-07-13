unit URehberWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxDBEdit, // cxMaskEdit,
  cxButtonEdit, cxTextEdit, cxMemo, cxContainer, cxLabel, ExtCtrls, cxImage,
  FireDAC.Comp.Client, JvWizard, JvExControls, Menus, cxLookAndFeelPainters, cxDropDownEdit,
  StdCtrls, cxButtons, cxCalendar, cxCheckBox, cxSpinEdit, cxGroupBox,
  cxRadioGroup, cxImageComboBox, cxExtEditRepositoryItems, Utablo,
  cxEditRepositoryItems, cxShellEditRepositoryItems, cxDBEditRepository,
  cxDBExtLookupComboBox, UReplikasyon, cxDBLabel, UGentegreFrameYonetimi,
  cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, cxLookAndFeels,
  cxNavigator, dxCore, cxDateUtils, cxGridCustomLayoutView, cxCurrencyEdit,
  UKullaniciDuzenle, GT_RehberAbout, URehberHareket, Vcl.DBCtrls, Usifre,
  cxPCdxBarPopupMenu, cxPC, dxBarBuiltInMenu, cxGridCustomPopupMenu,
  cxGridPopupMenu, OfficePopupMenu, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  JvComponentBase, JvDragDrop, cxMaskEdit, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, dxCoreGraphics, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TRehberWizardDlg = class(TForm)
    WizardKontrol: TJvWizard;
    TabCariIlet: TFDQuery;
    DtsKurIlet: TDataSource;
    PersonelIletisimEkr: TJvWizardInteriorPage;
    ToolBar2: TToolBar;
    YeniPerTus: TToolButton;
    SilPerTus: TToolButton;
    GridIlet: TcxGrid;
    GridIletView: TcxGridDBTableView;
    GridIletViewColumn1: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    SQLPerIlet: TcxMemo;
    GirisEkr: TJvWizardWelcomePage;
    TicariEkr: TJvWizardInteriorPage;
    IletisimEkr: TJvWizardInteriorPage;
    GridKurIlet: TcxGrid;
    GridKurIletView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    SQLKurIlet: TcxMemo;
    GridTicari: TcxGrid;
    GridTicariView: TcxGridDBTableView;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    SQLTicari: TcxMemo;
    TabPerIlet: TFDQuery;
    DtsPerIlet: TDataSource;
    TabTicari: TFDQuery;
    DtsTicari: TDataSource;
    GridKurIletViewColumn1: TcxGridDBColumn;
    GridTicariViewColumn1: TcxGridDBColumn;
    GridIletViewColumn3: TcxGridDBColumn;
    cxImageComboBox1: TcxImageComboBox;
    GridKurIletViewColumnsec: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    GridTicariViewColumn2: TcxGridDBColumn;
    GridIletViewColumn4: TcxGridDBColumn;
    TabRehber: TFDQuery;
    DtsRehber: TDataSource;
    cxGrid2: TcxGrid;
    GridPersonellerView: TcxGridDBTableView;
    PersonelVARSAYILAN: TcxGridDBColumn;
    PersonelAdi: TcxGridDBColumn;
    GridPersoneller: TcxGridLevel;
    TabIlgili: TFDQuery;
    DtsIlgili: TDataSource;
    DegisPerTus: TToolButton;
    ToolButton8: TToolButton;
    VarsayPerTus: TToolButton;
    GridIletViewColumnBilgi: TcxGridDBColumn;
    dtsSonAktivite: TDataSource;
    TabSonAktivite: TFDQuery;
    DokumanEkr: TJvWizardInteriorPage;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    JvDragDrop1: TJvDragDrop;
    Panel2: TPanel;
    btnCariKart: TcxButton;
    BtnDokuman: TcxButton;
    BtnKisiBilgiFormu: TcxButton;
    Btniletisim: TcxButton;
    btnTicariBilgiler: TcxButton;
    BtnCRM: TcxButton;
    CRMEkstreEkr: TJvWizardInteriorPage;
    ToolBar7: TToolBar;
    cxGridCRM: TcxGrid;
    cxGridCRMView: TcxGridDBTableView;
    cxGridLevel6: TcxGridLevel;
    DtsCRMEkstre: TDataSource;
    cxGridCRMViewMODUL: TcxGridDBColumn;
    cxGridCRMViewTARIH: TcxGridDBColumn;
    cxGridCRMViewAKSIYONTARIH: TcxGridDBColumn;
    cxGridCRMViewNO: TcxGridDBColumn;
    cxGridCRMViewTUR: TcxGridDBColumn;
    cxGridCRMViewACIKLAMA: TcxGridDBColumn;
    cxGridCRMViewDURUM: TcxGridDBColumn;
    cxGridCRMViewTUTAR: TcxGridDBColumn;
    cxGridCRMViewKUR: TcxGridDBColumn;
    cxLabel1: TcxLabel;
    ComboZamanAraligi: TcxComboBox;
    MemoCRM: TcxMemo;
    TabCRMEkstre: TFDQuery;
    PersonelNEREDE: TcxGridDBColumn;
    PopupIlgili: TPopupMenu;
    lgiliKurumdanAyrld1: TMenuItem;
    lgiliyiKopyala1: TMenuItem;
    N7: TMenuItem;
    Varsaylan1: TMenuItem;
    DurumuSfrla1: TMenuItem;
    N2: TMenuItem;
    cxGrid1: TcxGrid;
    GridAdresAdView: TcxGridDBTableView;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel7: TcxGridLevel;
    DtsRehberIlet: TDataSource;
    TabRehberIletisim: TFDQuery;
    YeniAdresTus: TToolButton;
    ToolButton2: TToolButton;
    PopupIletisim: TPopupMenu;
    MenuItem7: TMenuItem;
    AdresDegistir: TToolButton;
    lgiliyeletiimBilgisiKopyala1: TMenuItem;
    GridPersonellerViewGOREV: TcxGridDBColumn;
    Panel1: TPanel;
    EditKOD: TcxDBTextEdit;
    LabelKod: TcxLabel;
    KodAgaciTus: TcxButton;
    EditFIRMA: TcxDBTextEdit;
    LblUnvan: TcxLabel;
    ComboGRUP: TcxDBImageComboBox;
    LabelGrup: TcxLabel;
    LabelKategori: TcxLabel;
    EditKATEGORI: TcxButtonEdit;
    ComboSINIF: TcxDBImageComboBox;
    LabelSinif: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    ComboDURUM: TcxDBImageComboBox;
    Label34: TcxLabel;
    cxDBLabel2: TcxDBLabel;
    EditTEMSILCI: TcxButtonEdit;
    LabelSorumlu: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    LabelBolge: TcxLabel;
    ComboBolge: TcxDBImageComboBox;
    DBCheckBox1: TDBCheckBox;
    CheckPersonel: TcxCheckBox;
    ComboAltBolge: TcxDBImageComboBox;
    LabelAltBolge: TcxLabel;
    LabelSektor: TcxLabel;
    EditSektor: TcxButtonEdit;
    cxLabel2: TcxLabel;
    EditPERYOT: TcxDBSpinEdit;
    cxLabel5: TcxLabel;
    EditAltSektor: TcxButtonEdit;
    LabelAltSektor: TcxLabel;
    EditOzelKod: TcxDBTextEdit;
    Label3: TcxLabel;
    cxLabel4: TcxLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    CariPageControl: TcxPageControl;
    SheetNotlar: TcxTabSheet;
    CariGridNotlar: TcxGrid;
    CariGridNotlarView: TcxGridDBCardView;
    CariGridNotlarViewBILGI: TcxGridDBCardViewRow;
    CariGridNotlarViewYORUM: TcxGridDBCardViewRow;
    CariGridNotlarLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    YorumEkleTus: TToolButton;
    YorumSil: TToolButton;
    YorumDuzenle: TToolButton;
    SheetEkAlanlar: TcxTabSheet;
    PanelEkAlanlar: TPanel;
    cxLabel3: TcxLabel;
    TabNotlar: TFDQuery;
    DtsNotlar: TDataSource;
    LabelID: TcxLabel;
    TabPerIletisim: TFDQuery;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
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
    BtnDosyaGonder: TcxButton;
    LogoResim: TcxDBImage;
    EditTEMAS: TcxButtonEdit;
    LabelTemas: TcxLabel;
    cxDBCheckBox3: TcxDBCheckBox;
    cxLabel6: TcxLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    procedure FormShow(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure ComboKATEGORIPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KodAgaciTusClick(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit
      (Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure EditAdPropertiesChange(Sender: TObject);
    procedure GridKurIletViewStylesGetContentStyle
      (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    Function BosZorunluAlanSay(DTS: TDataSource; Alan: string): Integer;
    procedure WizardKontrolNextButtonClick(Sender: TObject);
    procedure TabPerIletNewRecord(DataSet: TDataSet);
    procedure TabCariIletNewRecord(DataSet: TDataSet);
    procedure TabTicariNewRecord(DataSet: TDataSet);
    procedure LogoResimClick(Sender: TObject);
    procedure GirisEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure TabRehberBeforePost(DataSet: TDataSet);
    procedure TabRehberNewRecord(DataSet: TDataSet);
    procedure DegisPerTusClick(Sender: TObject);
    procedure GridPersonellerViewSelectionChanged
      (Sender: TcxCustomGridTableView);
    procedure PersonelIletisimEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure TabIlgiliNewRecord(DataSet: TDataSet);
    procedure TabIlgiliBeforePost(DataSet: TDataSet);
    procedure VarsayPerTusClick(Sender: TObject);
    procedure TicariEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure IletisimEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure GridIletViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridKurIletViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridTicariViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure TabRehberBeforeEdit(DataSet: TDataSet);
    procedure TabRehberAfterPost(DataSet: TDataSet);
    procedure TabRehberAfterScroll(DataSet: TDataSet);
    procedure GridKurIletViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure BelgeKaydetTusClick(Sender: TObject);
    procedure BelgeIptalTusClick(Sender: TObject);
    procedure DtsImajStateChange(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure EditKODEditing(Sender: TObject; var CanEdit: Boolean);
    procedure ComboGRUPPropertiesChange(Sender: TObject);
    procedure btnCariKartClick(Sender: TObject);
    procedure ButtonDuzenle;
    procedure GirisEkrPage(Sender: TObject);
    procedure IletisimEkrPage(Sender: TObject);
    procedure TicariEkrPage(Sender: TObject);
    procedure PersonelIletisimEkrPage(Sender: TObject);
    procedure DokumanEkrPage(Sender: TObject);
    procedure CRMEkstreEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure ComboZamanAraligiPropertiesChange(Sender: TObject);
    procedure cxGridCRMViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxGridCRMViewDblClick(Sender: TObject);
    procedure CRMEkstreEkrPage(Sender: TObject);
    procedure TabCRMEkstreAfterScroll(DataSet: TDataSet);
    procedure lgiliKurumdanAyrld1Click(Sender: TObject);
    procedure lgiliyiKopyala1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Varsaylan1Click(Sender: TObject);
    procedure DurumuSfrla1Click(Sender: TObject);
    procedure EditMUSTEMSILCIPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabRehberIletisimNewRecord(DataSet: TDataSet);
    procedure DetayBeforeEdit(DataSet: TDataSet);   // cari detay: log oncesi snapshot
    procedure DetayAfterPost(DataSet: TDataSet);     // cari detay: edit/insert log (ust=cari)
    procedure GridAdresAdViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure YeniAdresTusClick(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure AdresDegistirClick(Sender: TObject);
    procedure LabelKategoriClick(Sender: TObject);
    procedure EditTEMSILCIKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lgiliyeletiimBilgisiKopyala1Click(Sender: TObject);
    procedure ComboSubeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboSubePropertiesCloseUp(Sender: TObject);
    procedure GridKurIletViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure GridKurIletViewEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridKurIletViewFocusedItemChanged(Sender: TcxCustomGridTableView;
      APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
    procedure GridKurIletViewInitEdit(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
    procedure TabTicariBeforePost(DataSet: TDataSet);
    procedure AdresSilTusClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ToolButton6Click(Sender: TObject);
    procedure YeniPerTusClick(Sender: TObject);
    procedure SilPerTusClick(Sender: TObject);
    procedure CheckPersonelClick(Sender: TObject);
    procedure LabelSektorClick(Sender: TObject);
    procedure LabelAltBolgeClick(Sender: TObject);
    procedure ComboBolgePropertiesEditValueChanged(Sender: TObject);
    procedure LabelAltSektorClick(Sender: TObject);
    procedure EditSektorPropertiesEditValueChanged(Sender: TObject);
    procedure YorumEkleTusClick(Sender: TObject);
    procedure YorumSilClick(Sender: TObject);
    procedure YorumDuzenleClick(Sender: TObject);
    procedure cxDBLabel2Click(Sender: TObject);
    procedure TabIlgiliBeforeOpen(DataSet: TDataSet);
    procedure TabIlgiliAfterPost(DataSet: TDataSet);
    procedure TabIlgiliAfterScroll(DataSet: TDataSet);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure LabelTemasClick(Sender: TObject);
    procedure LabelSorumluClick(Sender: TObject);

  private
    { Private declarations }
    FFrameBilgi: TIcerikFrameBilgi;
    KurIletZorunlu, TicariZorunlu, PerIletZorunlu : SmallInt;
    // bo? kalan zorunlu alanlar? sayfalara g?re sayal?m.. next ve finish tu?lar?n?n visible lar?n? ayarlayal?m..
    function BoslukKontrolu: Boolean;
    // Vergi No sorup izibiz NACE/mukellef bilgisini ceker, REHBER.ID olusturup
    // donen bilgileri ilgili alanlara (FIRMA + REHBERBILGI) yazar.
    procedure VeriAlNACE;

  public
    { Public declarations }
    Cagiran: SmallInt;
    // 0 Kurum i?in yeni, 1 kurum ileti?im, 2 Ticari , 3 Personel ?zl?k, 4 Personel ileti?imi?in ileti?im bilgileri
    RehberID, RehberIletID, RehberPerID: Integer;
    Ust : SmallInt; // 1 Kurum i?in, 2 Personel i?in ileti?im bilgileri
    UstId : Integer; // 1 Kurum i?in RehberId, 2 Personel i?in PersonelId
    PersIslemTipi : SmallInt; // 1 Yeni pers, 2 D?zenleme, 3 Silme;
    YeniKayit, IlkAcilis, Potansiyel : Boolean;
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    FKartSnap: TStringList;  // kart (REHBER) BeforeEdit snapshot'i - detay logu LogOnceki'yi ezmesin
    FKartSnapID: Integer;    // snapshot'in ait oldugu kart ID'si (bayat snapshot'i ayirt etmek icin)
    destructor Destroy; override;
  end;

var
  RehberWizardDlg: TRehberWizardDlg;
  DYetkisonuc: DokumanYetkiSonuc;

implementation

{$R *.dfm}

uses UVeriMotor, PrjConst, UGirisKutusuEx, UCombo, FetaKurulusSiniflari, UGENINIDuzenle,
  Fetautil,URehberAramaEkrani,UResim, UComboImgDuzenle, UCariFonksiyonlar, UBinarySave, UAnaForm,
  FetaClassExtensions, IdGlobalProtocols, UGenSifre,LocOnFly, UUnits, URehberTemsilci,
  System.JSON, UEBelgeKimlik, UIzibizRest, ULog;

var
  EkleKurIlet, EkleTicari, EklePerIlet : Boolean;
  KNo, GiristekiRehberId : String[15];
  FOturumID : string;   // geri-alinabilir oturum (Cagiran=0 mevcut cari duzenleme); '' = yok
  TabloNo, OncekiTemsilciId : Integer;

procedure TRehberWizardDlg.AdresDegistirClick(Sender: TObject);
var
  EtiAdi, Gorev: Variant;
begin
  EtiAdi := TabRehberIletisim.FieldByName('AD').AsString;
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
     TGirdiDenetimleri.Create.Edit(IletisimAdiniGirin, @EtiAdi)) = mrOK then begin
     //.ImageComboBox(AGS_Gorevler,@Gorev,Tablo.FDCnn,'select G.DEGER, G.ANAHTAR from GENINI G where G.BOLUM=-2205 order by 2',False, nil)) = mrOK then begin
     TabRehberIletisim.Edit;
     TabRehberIletisim.FieldByName('AD').AsString := Trim(EtiAdi);
     //TabRehberIletisim.FieldByName('GOREVID').AsString := Gorev;
     TabRehberIletisim.Post;
  end;
end;

procedure TRehberWizardDlg.AdresSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO)
    = IDYES then
  begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'delete from REHBERBILGI where YERI=1 and YER_ID=' +
      TabRehberIletisim.FieldByName('ID').AsString, [], []);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'delete from REHBERILETISIM where ID=' + TabRehberIletisim.FieldByName('ID')
      .AsString, [], []);
    TabloYenile(TabRehberIletisim, []);
  end;
end;

procedure TRehberWizardDlg.BelgeIptalTusClick(Sender: TObject);
begin
  TabImaj.Cancel;
end;

procedure TRehberWizardDlg.BelgeKaydetTusClick(Sender: TObject);
begin
  TabImaj.Post;
end;

function TRehberWizardDlg.BoslukKontrolu: Boolean;
begin
  BoslukKontrolu := true;
  if not Potansiyel then begin
      if not BoslukKontrol(ComboGRUP.text, KontrolGrup) then
        Abort;
      if not BoslukKontrol(EditKOD.text, KontrolKod) then
        Abort;
  end;
  if not BoslukKontrol(EditFIRMA.text, KontrolFirma) then
    Abort;
  if not BoslukKontrol(ComboDURUM.text, KontrolDurum) then
    Abort;

  if (Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_Zorunlu_BOLGE,False))and(not BoslukKontrol(ComboBolge.Text,KontrolBolge)) then
    Abort;
  if (Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_Zorunlu_ALTBOLGE,False))and(not BoslukKontrol(ComboAltBolge.Text,KontrolAltBolge)) then
    Abort;
  BoslukKontrolu := False;
end;

procedure TRehberWizardDlg.CheckPersonelClick(Sender: TObject);
var ID : Integer;
begin
  if IlkAcilis then exit;

  TabRehber.edit;
  if CheckPersonel.Checked then begin
    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then begin
      //?nce bakal?m bu personeledaha ?nce karta??lm?? m?
      Tablo.TablodanSorguAc(1,'select ID from REHBER where BAGID='+IntToStr(ID));
      if Tablo.Query1.RecordCount>0 then begin
         showmessage(CRPersonel_carikart_var);
         CheckPersonel.Checked := False;
         TabRehber.FieldByName('BAGID').AsInteger := 0
      end else begin
         TabRehber.FieldByName('STATU').AsBoolean := False;
         TabRehber.FieldByName('GRUP').AsInteger := 120;
         TabRehber.FieldByName('FIRMA').AsString := RehberAramaEkrani.AraQuery1.FieldByName('FIRMA').AsString;
         TabRehber.FieldByName('BAGID').AsInteger:= RehberAramaEkrani.AraQuery1.FieldByName('ID').AsInteger;;
      end;
    end else begin
       CheckPersonel.Checked := False;
       TabRehber.FieldByName('BAGID').AsInteger := 0
    end;
  end else
   TabRehber.FieldByName('BAGID').AsInteger := 0
end;

procedure TRehberWizardDlg.ComboBolgePropertiesEditValueChanged(Sender: TObject);
begin
   if ComboBolge.ItemIndex>=0 then begin
     Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_CariKart_Bolge)+ IntToStr(ComboBolge.ActiveProperties.Items[ComboBolge.ItemIndex].Value)),ComboAltBolge.Properties.Items,True);
     ComboAltBolge.Tag := StrToInt(IntToStr(Ops_CariKart_Bolge)+ IntToStr(ComboBolge.ActiveProperties.Items[ComboBolge.ItemIndex].Value));
   end;
end;

procedure TRehberWizardDlg.ComboGRUPPropertiesChange(Sender: TObject);
var uzunluk:smallint;
  function vknosor(Baslik:String): string;
  var VKNo: Variant;
  begin
      Result := '';
      VKNo := '';
      while Result = '' do
        if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Edit(Baslik, @VKNo)) = mrOK then begin
           VKNo := Trim(VKNo);
           if length(VKNo)<>uzunluk then
              ShowMessage(CRKarakter_sayisi+IntToStr(uzunluk))
           else
              Result := VKno
        end;
  end;
begin

   Potansiyel := ComboGRUP.EditValue = 1;
   CheckPersonel.visible := not Potansiyel;
   LabelKod.visible := not Potansiyel;
   EditKOD.visible := not Potansiyel;
   KodAgaciTus.visible := not Potansiyel;


  if KNo<>'' then begin
     Tablo.TablodanSorguAc(1,'SELECT ID=YER_ID, KOD,FIRMA FROM REHBERBILGI RB inner join REHBER R on RB.YER_ID=R.ID '+
             ' where [YERI]=2 and BILGI='''+KNo+''' and BILGI<>'''+copy('00000000000',1,uzunluk)+''' ');
     if Tablo.Query1.RecordCount>0 then begin
        ShowMessage(CRKimlik_no_kullanilmis+Tablo.Query1.Fields[1].asstring+' '+Tablo.Query1.Fields[2].asstring);
        Close;
     end;
  end;
end;

procedure TRehberWizardDlg.ComboKATEGORIPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
  st: Tstringlist;
  Bolum:String[20];
begin
  if AButtonIndex = 0 then
  begin
    st := Tstringlist.Create;
    if TcxButtonEdit(Sender).Name='EditAltSektor' then
       Bolum := IntToStr(TcxButtonEdit(Sender).Tag) + TabRehber.FieldByName('SEKTOR').AsString
    else
       Bolum := IntToStr(TcxButtonEdit(Sender).Tag);

    if tablo.ListedenBilgiGetir('Liste', 'select DEGER,ANAHTAR from GENINI  ' +
        ' where  BOLUM='+Bolum+' and DIL=' + IntToStr(Dil) + ' and ANAHTAR like''%<ara>%''', st, []) then
    begin
      TabRehber.Edit;
      TabRehber.FieldByName(TcxButtonEdit(Sender).Hint).AsString := st.Strings[0];
      TcxButtonEdit(Sender).text := st.Strings[1];
    end;
    st.free;
  end
  else if AButtonIndex = 1 then
  begin
    TabRehber.Edit;
    TabRehber.FieldByName(TcxButtonEdit(Sender).Hint).AsInteger := 0;
    TcxButtonEdit(Sender).text := '';
  end;

  if TcxButtonEdit(Sender).Name<>'EditAltSektor' then
     EditAltSektor.text := '';
end;

procedure TRehberWizardDlg.ComboSubeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   ComboSube.EditValue := 0;
end;

procedure TRehberWizardDlg.ComboSubePropertiesCloseUp(Sender: TObject);
begin
   ComboSube.EditValue := tablo.SubeGetir(tablo.GENINI.ReadInteger(Ops_OpsiyonCari_GorunecekSubeler, 0),
   ComboSube.EditValue);
end;

procedure TRehberWizardDlg.EditMUSTEMSILCIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin

  OncekiTemsilciId := TabRehber.FieldByName('TEMSILCI').AsInteger;
  if AButtonIndex = 0 then
     tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex,TabRehber, 'TEMSILCI')
  else if AButtonIndex = 1 then begin
     TabRehber.Edit;
     TabRehber.FieldByName('TEMSILCI').AsInteger := 0;
     EditTEMSILCI.text := '';
  end;
end;

procedure TRehberWizardDlg.EditSektorPropertiesEditValueChanged(Sender: TObject);
begin
  EditAltSektor.Enabled := EditSektor.Text<>'';
  LabelAltSektor.Enabled := EditAltSektor.Enabled;
end;

procedure TRehberWizardDlg.EditTEMSILCIKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
  if Key in [VK_DELETE, VK_BACK] then begin
     TcxButtonEdit(Sender).Tag := 0;
     TcxButtonEdit(Sender).text := '';
  end;
end;

procedure TRehberWizardDlg.ComboZamanAraligiPropertiesChange(Sender: TObject);
var
  Tarih: string;
begin
  if ComboZamanAraligi.text = RWBirAy then
    Tarih := ' Where TARIH > '+DbTarihEkle('month','-1',''''+FormatDateTime('yyyy-mm-dd 00:00:00', Now)+'''')
  else if ComboZamanAraligi.text = RWUcAy then
    Tarih := ' Where TARIH > '+DbTarihEkle('month','-3',''''+FormatDateTime('yyyy-mm-dd 00:00:00', Now)+'''')
  else if ComboZamanAraligi.text = RWAltiAy then
    Tarih := ' Where TARIH > '+DbTarihEkle('month','-6',''''+FormatDateTime('yyyy-mm-dd 00:00:00', Now)+'''')
  else if ComboZamanAraligi.text = RWBirYil then
    Tarih := ' Where TARIH > '+DbTarihEkle('year','-1',''''+FormatDateTime('yyyy-mm-dd 00:00:00', Now)+'''')
  else if ComboZamanAraligi.text = RWikiYil then
    Tarih := ' Where TARIH > '+DbTarihEkle('year','-2',''''+FormatDateTime('yyyy-mm-dd 00:00:00', Now)+'''')
  else if ComboZamanAraligi.text = RWTumKayitlar then
    Tarih := ' ';
  TabCRMEkstre.Close;
  TabCRMEkstre.SQL.text := 'select * from ##CRMEKSTRE99_' + IntToStr(SPID) + '_ ' + Tarih;
  TabloYenile(TabCRMEkstre,[]);
end;

procedure TRehberWizardDlg.cxDBLabel2Click(Sender: TObject);
var
  str:string;
begin
  if StrToInt(cxDBLabel2.Caption) > 0 then
  begin
    str := cxDBLabel2.Caption+'-'+Sifre(cxDBLabel2.Caption);
    InputQuery('Müşteri kodu','Müşteri kodu',str);
  end;
end;

procedure TRehberWizardDlg.cxGridCRMViewCanFocusRecord
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := cxGridCRM;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := cxGridCRMView;
  AnaForm.pmGridStil.Tags.Values[cxGridCRM.Name] := 'CRMGridi';
end;

procedure TRehberWizardDlg.cxGridCRMViewDblClick(Sender: TObject);
var
  srid: integer;
begin
  // if pos('Fatura', TabCRMEkstre.FieldByName('TUR').AsString)>0 then
  // Tablo.FaturaSihirbazBaslat('D',15{TabCRMEkstre.AsInteger['TUR']},-1, TabCRMEkstre.AsInteger['ID'], TabRehber.AsInteger['ID']);

  if cxGridCRMView.Controller.SelectedRecordCount > 0 then
  begin
    srid := cxGridCRMView.DataController.FocusedRecordIndex;
    case TabCRMEkstre.FieldByName('ISLEMTIPI').AsInteger of
      1:
        begin // Proje
          tablo.ProjeSihirbazBaslat('D', TabCRMEkstre.AsInteger['ID'],
            TabRehber.AsInteger['ID'], tablo.GENINI.BugunTrh);
        End;
     { 2:
        begin // Aktivite
          tablo.AktiviteGoster('D', FFrameBilgi,
            TabCRMEkstre.FieldByName('ISLEMTURU').AsInteger,
            TabCRMEkstre.AsInteger['ID'], -2, tablo.GENINI.BugunTrh);
        End;  }
      3:
        begin // Teklif
          tablo.TeklifSihirbazBaslat('D', 80, 0, TabCRMEkstre.AsInteger['ID'],
            TabRehber.AsInteger['ID'], -1);
        End;
      4:
        begin // Servis
          tablo.ServisSihirbazBaslat(ServisKapsami=1, 'D', 0, TabCRMEkstre.AsInteger['ID'],
            TabRehber.AsInteger['ID']);
        End;
      5:
        begin // Kasa
          AnaForm.GormeDialogCagir(TabCRMEkstre.AsInteger['ID'], TabCRMEkstre.FieldByName('ISLEMTURU').AsInteger,
            TabRehber.AsInteger['ID'], 0,TabCRMEkstre.FieldByName('TARIH').AsDateTime, TabCRMEkstre.FieldByName('NO').AsString);
        End;
      6:
        begin // Fatura
          if TabCRMEkstre.FieldByName('ISLEMTURU').AsInteger = 11 then
            tablo.FaturaSihirbazBaslat('D', 11, -1,
              TabCRMEkstre.AsInteger['ID'], TabRehber.AsInteger['ID'])
          else if TabCRMEkstre.FieldByName('ISLEMTURU').AsInteger = 15 then
            tablo.FaturaSihirbazBaslat('D', 15, -1,
              TabCRMEkstre.AsInteger['ID'], TabRehber.AsInteger['ID'])
        End;
      7:
        begin // ?ek
          tablo.MakbuzSihirbazBaslat('D', TabCRMEkstre.FieldByName('ISLEMTURU')
            .AsInteger, 0, 0, TabRehber.AsInteger['ID'],
            TabCRMEkstre.FieldByName('TARIH').AsDateTime,
            TabCRMEkstre.FieldByName('NO').AsString);
        End;
      8:
        begin // ?ek Ciro
          tablo.MakbuzSihirbazBaslat('D', TabCRMEkstre.FieldByName('ISLEMTURU')
            .AsInteger, 0, 0, TabRehber.AsInteger['ID'],
            TabCRMEkstre.FieldByName('TARIH').AsDateTime,
            TabCRMEkstre.FieldByName('NO').AsString);
        End;
      9:
        begin // Senet

        End;
      10:
        begin // Personel

        End;
    end;
    CRMEkstreEkrEnterPage(Self, CRMEkstreEkr);
    cxGridCRMView.DataController.FocusedRecordIndex := srid;

  end;

end;

procedure TRehberWizardDlg.cxGridDBColumn4GetPropertiesForEdit
  (Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
var
  Paramlar: TArrayOfString;
  Degerler: TArrayOfVariant;
begin
  SetLength(Paramlar, 2);
  SetLength(Degerler, 2);
  Paramlar[0] := ':PRehID';
  Paramlar[1] := ':PSubeID';
  Degerler[0] := RehberID;
  Degerler[1] := SubeID;
  tablo.RepositorydenPropertyAl(AProperties, Sender, Paramlar, Degerler);
end;

procedure TRehberWizardDlg.GridAdresAdViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
    if not TabRehberIletisim.Active then exit;

    if TabRehberIletisim.RecordCount > 0 then
    begin
      if EkleKurIlet then // daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
        Ekle(TabCariIlet, 1, RehberIletID, Degis, '', TabNo_REHBER, RehberID, 75);
      RehberIletID := TabRehberIletisim.Fields[0].AsInteger;

      TabCariIlet.Close;
      TabCariIlet.SQL.text := StringReplace(SQLKurIlet.text, ':SPID',
        IntToStr(SPID), [rfReplaceAll]);
      TabCariIlet.Params[0].Value := 1;
      TabCariIlet.Params[1].Value := RehberIletID; // RehberPerID;
      TabCariIlet.Params[2].Value := RehberIletID; // RehberPerI;
      TabCariIlet.Open;
      EkleKurIlet := False
    end
    else
      GridKurIlet.Visible := False;
end;

procedure TRehberWizardDlg.EditAdPropertiesChange(Sender: TObject);
begin
  GridIlet.Visible := (TabIlgili.Active) and (TabIlgili.RecordCount > 0);
end;

procedure TRehberWizardDlg.EditKODEditing(Sender: TObject;
  var CanEdit: Boolean);
begin
  if ComboGRUP.text = '' then
    raise Exception.Create(RWOnceGrupSeciniz);

end;

procedure TRehberWizardDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  Tablo.WizardTurkcelestir(WizardKontrol);
  Tablo.GridTurkcelestir;

  // LabelGrup.OnClick := Tablo.LabelClickCombobox;
  IlkAcilis:=True;
  CariPageControl.ActivePageIndex := 0;

  FKartSnap := TStringList.Create;

  // Cari detay iletisim dataset'lerini ust=cari log'una bagla (master-detail).
  TabRehberIletisim.BeforeEdit := DetayBeforeEdit;
  TabRehberIletisim.AfterPost  := DetayAfterPost;
  TabPerIletisim.BeforeEdit := DetayBeforeEdit;
  TabPerIletisim.AfterPost  := DetayAfterPost;
  TabCariIlet.BeforeEdit := DetayBeforeEdit;
  TabCariIlet.AfterPost  := DetayAfterPost;
  TabPerIlet.BeforeEdit := DetayBeforeEdit;
  TabPerIlet.AfterPost  := DetayAfterPost;
  TabTicari.BeforeEdit := DetayBeforeEdit;
  TabTicari.AfterPost  := DetayAfterPost;

  LabelGrup.OnClick := tablo.LabelClickCombobox;
  LabelSinif.OnClick := tablo.LabelClickCombobox;
  LabelBolge.OnClick := tablo.LabelClickCombobox;

  // Yetkilere g?re soldaki butonlar g?r?nmeyecek

   if not Tablo.YetkiVarmi(220110,YetkiTur_Gorme) then begin
      Btniletisim.Visible := False;
      IletisimEkr.Visible := False;
   end;
   if not Tablo.YetkiVarmi(220120,YetkiTur_Gorme) then begin
      BtnKisiBilgiFormu.Visible:=False;
      PersonelIletisimEkr.Visible:=False;
   end;
   if not Tablo.YetkiVarmi(220130,YetkiTur_Gorme) then begin
      btnTicariBilgiler.Visible:=False;
      TicariEkr.Visible:=False;
   end;
   if not Tablo.YetkiVarmi(220135,YetkiTur_Gorme) then begin
      BtnDokuman.Visible:=False;
      DokumanEkr.Visible:=False;
   end;

   if not tablo.YetkiVarmi(220185, YetkiTur_Gorme) then begin
      BtnCRM.Visible := False;
      CRMEkstreEkr.Visible := False;
   end;

  TabPerIlet.CachedUpdates := True;
  TabPerIlet.UpdateOptions.UpdateTableName := '';
  TabPerIlet.UpdateOptions.KeyFields := '';
  TabCariIlet.CachedUpdates := True;
  TabCariIlet.UpdateOptions.UpdateTableName := '';
  TabCariIlet.UpdateOptions.KeyFields := '';
  TabTicari.CachedUpdates := True;
  TabTicari.UpdateOptions.UpdateTableName := '';
  TabTicari.UpdateOptions.KeyFields := '';
end;

procedure TRehberWizardDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Key := 0;
end;

procedure TRehberWizardDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var
  Tur: integer;
  ctrlPos: TPoint;
  clientPos: TPoint;
  Strin: String;
  ctrl: TWinControl;
begin
  clientPos := Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt, ssCtrl]) and (Key = Ord('E')) then begin // Yeni Bile?en Ekle
      ctrl := FindVCLWindow(Mouse.CursorPos);
      if Assigned(ctrl) then
      begin
        OutputDebugString(PChar(ctrl.Name));
        ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
        tablo.AlanlarDlgBaslat('E', 1, -1, ctrlPos.X, ctrlPos.Y, -1,FindComponent(ctrl.Name), TRehberWizardDlg(Self), DtsRehber);
        tablo.AlanOlustur(TRehberWizardDlg(Self), -1, DtsRehber);
      end;
  end
  else if (Shift = [ssAlt, ssCtrl]) and (Key = Ord('D')) then begin
      tablo.AlanlarDlgBaslat('D', 1, 0, ctrlPos.X, ctrlPos.Y, 0,
                              FindComponent(PanelEkAlanlar.Name), TRehberWizardDlg(Self), DtsRehber);
      tablo.AlanOlustur(TRehberWizardDlg(Self), -1, DtsRehber);
  end;
end;

procedure TRehberWizardDlg.FormShow(Sender: TObject);
var
  s: string;
begin
  //cxGridCRMView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\CRMGridi', true,False, [gsoUseFilter], 'CRMGridi');
  Tablo.GridAyarRestore('CRMGridi',cxGridCRMView );

  KNo:='';

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  if PanelEkAlanlar <> nil then
//    tablo.AlanOlustur(FindComponent(PanelEkAlanlar.Name),TRehberWizardDlg(Self), -1, DtsRehber);
    tablo.AlanOlustur(TRehberWizardDlg(Self), -1, DtsRehber);

  if (not Potansiyel)and(tablo.GENINI.ReadInteger(Ops_OpsiyonCari_CariKodGirisi, 2) <> 2) then begin // CariOpsiyon  CariKodGirisi
     KodAgaciTus.Visible := False;
     EditKOD.Enabled := true;
  end;

  if not SubeVarmi then begin
     LblSube.Visible := False;
     ComboSube.Visible := False;
  end;

  if Cagiran = 0 then
  begin
    RehberPerID := -11;
    TabloYenile(TabRehber, [RehberID]);
    TabRehber.Edit;
    if TabRehber.FieldByName('SEKTOR').AsString <> '' then begin
        Tablo. TablodanSorguAc(1, 'Select '+DbUst(1)+'ANAHTAR from GENINI where DIL=' + IntToStr(Dil) +
          ' AND  BOLUM=' + IntToStr(Ops_CariKart_Sektor) + ' and DEGER=' + TabRehber.FieldByName('SEKTOR').AsString + ' '+DbSinir(1));
        EditSEKTOR.text := tablo.Query1.Fields[0].AsString;
        if TabRehber.FieldByName('ALTSEKTOR').AsString <> '' then begin
           Tablo. TablodanSorguAc(1, 'Select '+DbUst(1)+'ANAHTAR from GENINI where DIL=' + IntToStr(Dil) +
             ' AND  BOLUM=' + IntToStr(Ops_CariKart_Sektor)+TabRehber.FieldByName('SEKTOR').AsString + ' and DEGER=' + TabRehber.FieldByName('ALTSEKTOR').AsString + ' '+DbSinir(1));
           EditAltSEKTOR.text := tablo.Query1.Fields[0].AsString;
        end;
    end;
    if TabRehber.FieldByName('KATEGORI').AsString <> '' then begin
       Tablo. TablodanSorguAc(1, 'Select '+DbUst(1)+'ANAHTAR from GENINI where DIL=' + IntToStr(Dil) +
         ' AND  BOLUM=' + IntToStr(Ops_CariKart_Kategori) + ' and DEGER=' + TabRehber.FieldByName('KATEGORI').AsString + ' '+DbSinir(1));
       EditKATEGORI.text := tablo.Query1.Fields[0].AsString;
    end;

    if TabRehber.FieldByName('TEMAS').AsString<>'' then begin
        Tablo. TablodanSorguAc(1, 'Select '+DbUst(1)+'ANAHTAR from GENINI where DIL=' + IntToStr(Dil) +
          ' AND  BOLUM=' + IntToStr(Ops_CariKart_Temas) + ' and DEGER=' + TabRehber.FieldByName('TEMAS').AsString + ' '+DbSinir(1));
        EditTEMAS.text := tablo.Query1.Fields[0].AsString;
    end;
    EditTEMSILCI.text := tablo.AciklamaGetir('REHBER', 'FIRMA',TabRehber.FieldByName('TEMSILCI').AsString);

    if Potansiyel then begin
       ComboGRUP.EditValue := 1;
       TabloNo := TabNo_REHBER_POTANSIYEL;
       EditFIRMA.SetFocus;
    end
    else begin
       TabloNo := TabNo_REHBER;
       ComboGRUP.SetFocus;
    end;

    //ComboGRUP.enabled:= not Potansiyel;

    // Tablo.CariKartInit(ComboDURUM.Properties, ComboGRUP.Properties, ComboSINIF.Properties);
    //ResimGetir(RehberID, Tabno_Rehber, RehberID, LogoResim);

  end;
  OncekiTemsilciId := TabRehber.FieldByName('TEMSILCI').AsInteger;
  GiristekiRehberId:= TabRehber.Fields[0].AsString;

  // Geri-alinabilir oturum (yalniz Cagiran=0 + MEVCUT cari; GiristekiRehberId dolu = yuklendi).
  // Acilistaki hali SNAPSHOT'a al -> Cancel'da ilk hale don. IMAJ (blob) KAPSAM DISI.
  // REHBERBILGI 3 YERI: 1=iletisim (REHBERILETISIM uzerinden), 4=personel (REHBERPERSONEL),
  // 2-3=firma dogrudan (YER_ID=REHBER.ID). SIRA: ust once (REHBER<ILETISIM/PERSONEL<BILGI).
  FOturumID := '';
  if (Cagiran = 0) and (RehberID > 0) and (GiristekiRehberId <> '') and (GiristekiRehberId <> '0') then
    FOturumID := ULog.OturumBaslat('REHBER', RehberID,
      [ // --- Ana cari ---
        ULog.SnapTablo(1, 'REHBER',         'ID=' + IntToStr(RehberID)),
        ULog.SnapTablo(2, 'REHBERILETISIM', 'REHBERID=' + IntToStr(RehberID)),
        ULog.SnapTablo(2, 'REHBERPERSONEL', 'REHBERID=' + IntToStr(RehberID)),
        ULog.SnapTablo(3, 'REHBERBILGI',    'YERI=1 and YER_ID in (select ID from REHBERILETISIM where REHBERID=' + IntToStr(RehberID) + ')'),
        ULog.SnapTablo(3, 'REHBERBILGI',    'YERI=4 and YER_ID in (select ID from REHBERPERSONEL where REHBERID=' + IntToStr(RehberID) + ')'),
        ULog.SnapTablo(3, 'REHBERBILGI',    'YERI in (2,3) and YER_ID=' + IntToStr(RehberID)),
        // --- Ilgili kisiler (alt REHBER: GRUP=334, BAGID=ana) + kendi iletisim/bilgi ---
        //     (SIRA ana REHBER'den BUYUK -> once cocuk silinir, sonra ana; FK korunur.)
        ULog.SnapTablo(6, 'REHBERBILGI',    'YER_ID in (select ID from REHBERILETISIM where REHBERID in (select ID from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + '))'),
        ULog.SnapTablo(5, 'REHBERILETISIM', 'REHBERID in (select ID from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + ')'),
        ULog.SnapTablo(4, 'REHBER',         'GRUP=334 and BAGID=' + IntToStr(RehberID)),
        // --- Not (TUR 11-13) + Yorum (TUR=TabloNo) = GOREVYORUM, GOREVID=ana cari ---
        ULog.SnapTablo(7, 'GOREVYORUM',     'GOREVID=' + IntToStr(RehberID) + ' and (TUR between 11 and 13 or TUR=' + IntToStr(TabloNo) + ')') ]);

  EkleKurIlet := False;
  EkleTicari := False;
  EklePerIlet := False;
  IletisimEkr.Enabled :=(Cagiran in [0, 1]); //and (Tablo.YetkiVarmi(MODUL_Cari,YetkiTur_Gorme))  ;
  TicariEkr.Enabled := Cagiran in [0, 2];
  PersonelIletisimEkr.Enabled := (Cagiran in [0, 4, 34]); //and (Tablo.YetkiVarmi(MODUL_Cari,YetkiTur_Gorme))  ;
  DokumanEkr.Enabled :=(Cagiran in [0, RehAyarYeri_Dokuman]); // and (Tablo.YetkiVarmi(MODUL_Cari,YetkiTur_Gorme))  ;
  CRMEkstreEkr.Enabled := (Cagiran in [0, RehAyarYeri_CRM]); // and (Tablo.YetkiVarmi(MODUL_Cari,YetkiTur_Gorme)) ;
  panel2.Visible :=  Cagiran <> RehAyarYeri_CRM;

  case Cagiran of
  // 0 Kurum i?in yeni, 1 kurum ileti?im, 2 Personel ?zl?k, 3 Personel ileti?im, 4 Ticari i?in ileti?im bilgileri , 5  Personel Ucret ,8 CRM
    1:
      IletisimEkr.VisibleButtons := [bkFinish, bkCancel];
    2:
      TicariEkr.VisibleButtons := [bkFinish, bkCancel];
    4:
      begin
        PersonelIletisimEkr.VisibleButtons := [bkFinish, bkCancel];
        YeniPerTus.Visible := False;
        SilPerTus.Visible := False;
      end;
    8:
      CRMEkstreEkr.VisibleButtons := [bkFinish];
  end;

  Tabloyenile(TabNotlar,[RehberID]);

  CheckPersonel.Checked := (TabRehber.FieldByName('BAGID').AsString <> '')and(TabRehber.FieldByName('BAGID').AsString <> '0');
  EditTEMSILCI.enabled := ModulYetki_TekSubeTum.Cari <> 1;

  if (RehberID > 0) and (RehberID <> SonEklenenCari) then
      tablo.SKRehberEkle(RehberID);
  IlkAcilis:=False;

  if Cagiran > 0 then
    RehberWizardDlg.WizardKontrol.SelectNextPage;

end;

procedure TRehberWizardDlg.GridIletViewEditChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EklePerIlet := true;
end;

procedure TRehberWizardDlg.GridKurIletViewCellClick
  (Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry: TFDQuery;
  ctrls: TGirdiDenetimleri;
  SQL: Variant;
begin    //se?im i?in combo i?ini dolduran kodlar
  if ACellViewInfo.Item.Index = 0 then
  begin // t?klanan etiket mi
    Qry := (Sender as TcxGridDBTableView).DataController.DataSource.DataSet as
      TFDQuery;
    if Trim(Qry.FieldByName('KAYNAK').AsString) <> '' then
    begin
      if Pos('select', LowerCase(Qry.FieldByName('KAYNAK').AsString)) > 0 then
      begin
        SQL := Qry.FieldByName('KAYNAK').AsString;
        ctrls := TGirdiDenetimleri.Create.Memo(Qry.FieldByName('ETIKET').AsString, @SQL);
        if TGirisKutusuEx.BilgiAlEx(yenisorgugirin, ctrls) = mrOK then
        begin
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'update REHBERAYAR set KAYNAK=&Sql where ETIKET=&Etiket and GIRIS=&Giris  ',
            ['&Sql', '&Etiket', '&Giris'],
            [SQL, Qry.FieldByName('ETIKET').AsString, Qry.FieldByName('GIRIS').AsInteger]);
        end;
      end
      else if Qry.FieldByName('GIRIS').AsInteger in [4, 6, 8, 9] then
      begin // combo
        tablo.TablodanSorguAc(7, 'select DEGER from GENINI where DIL=' +
          IntToStr(Dil) + ' AND  BOLUM=0 and ANAHTAR=''' +
          Qry.FieldByName('KAYNAK').AsString + '''');
        tablo.GeniniBaslat(tablo.Query7.Fields[0].AsInteger);

      end;
      Qry.Close;
      Qry.Open;
    end;
  end;
  // ACellViewInfo.GridRecord.Index //sat?r index de?eri
  // ACellViewInfo.Item.Index //s?tun index de?eri
end;

procedure TRehberWizardDlg.GridKurIletViewEditChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleKurIlet := true;
end;

procedure TRehberWizardDlg.GridKurIletViewEditValueChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin //
  EkleKurIlet := true;
end;

procedure TRehberWizardDlg.GridKurIletViewFocusedItemChanged
  (Sender: TcxCustomGridTableView;
  APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
begin
  //
  EkleKurIlet := true;
end;

procedure TRehberWizardDlg.GridKurIletViewInitEdit
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem;
  AEdit: TcxCustomEdit);
begin
  EkleKurIlet := true;
end;

procedure TRehberWizardDlg.GridKurIletViewSelectionChanged
  (Sender: TcxCustomGridTableView);
begin //
  EkleKurIlet := true;
end;

procedure TRehberWizardDlg.GridKurIletViewStylesGetContentStyle
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
Var
  AColumn1: TcxCustomGridTableItem;
begin
  AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('ZORUNLU');
  if ARecord.Values[AColumn1.Index] = true then
    AStyle := tablo.cxZrnAln
  else
    Exit;
end;

procedure TRehberWizardDlg.GridPersonellerViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
    if not TabIlgili.Active then exit;

    if TabIlgili.RecordCount > 0 then begin
       if EklePerIlet then // daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
          Ekle(TabPerIlet, 1, RehberPerID, Degis);
       RehberPerID := TabPerIletisim.Fields[0].AsInteger;
       TabPerIlet.Close;
       TabPerIlet.SQL.text := StringReplace(SQLPerIlet.text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
       TabPerIlet.Params[0].Value := 1;
       TabPerIlet.Params[1].Value := RehberPerID; // RehberPerID;
       TabPerIlet.Params[2].Value := RehberPerID; // RehberPerID;
       TabPerIlet.Open;
       EklePerIlet := False
    end
    else
      GridIlet.Visible := False;     {
    if TabPerIletisim.RecordCount > 0 then
    begin
      if EkleKurIlet then // daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
         Ekle(TabCariIlet, 1, RehberIletID, Degis);
      RehberIletID := TabRehberIletisim.Fields[0].AsInteger;

      TabCariIlet.Close;
      TabCariIlet.SQL.text := StringReplace(SQLKurIlet.text, ':SPID',
        IntToStr(SPID), [rfReplaceAll]);
      TabCariIlet.Params[0].Value := 1;
      TabCariIlet.Params[1].Value := RehberIletID; // RehberPerID;
      TabCariIlet.Params[2].Value := RehberIletID; // RehberPerI;
      TabCariIlet.Open;
      EkleKurIlet := False
    end
    else
      GridKurIlet.Visible := False;  }
end;

procedure TRehberWizardDlg.GridTicariViewEditChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleTicari := true;
end;

procedure TRehberWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
 Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabloNo);
end;

procedure TRehberWizardDlg.IletisimEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  // ?leti?im Adres Bilgilerine Default 'Merkez' ekleniyor.
  tablo.TablodanSorguAc(1, 'Select ID from REHBERILETISIM Where REHBERID=' + IntToStr(RehberID) + ' ');
  if (Cagiran = 0) and (tablo.Query1.RecordCount = 0) then begin //
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
      + IntToStr(RehberID) + ',''Merkez'',1,1,' + IntToStr(SubeID) + ')', [], []);
  end;

  TabRehberIletisim.Close;
  TabRehberIletisim.SQL.text := 'select * from REHBERILETISIM where REHBERID=' + IntToStr(RehberID);
  if RehberIletID > 0 then
  // e?er bir ilgili ?zerinde ?ift t?k yap?p de?i?iklik olacaksa
     TabRehberIletisim.SQL.Add(' and ID=' + IntToStr(RehberIletID));
  TabRehberIletisim.SQL.Add(' order by VARSAYILAN  desc');
  TabRehberIletisim.Open;
  GridKurIlet.Visible := TabRehberIletisim.RecordCount > 0;
  if (RehberIletID = -1) and (Cagiran = 1) then // yeni tu?una bas?lm?? demektir
      YeniAdresTus.Click;
  if GridKurIlet.Visible then begin
     GridAdresAdView.DataController.FocusedRecordIndex := 0;
     GridAdresAdView.ViewData.Records[0].Selected := true;
  end;
end;

procedure TRehberWizardDlg.IletisimEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TRehberWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint;  Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TRehberWizardDlg.CRMEkstreEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  if not TabCRMEkstre.Active then
  begin
    if Cagiran = RehAyarYeri_CRM then
       TabloYenile( TabRehber, [RehberID]);

    //TabCRMEkstre.Close;
    TabCRMEkstre.SQL.text := StringReplace(MemoCRM.text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    //TabCRMEkstre.Params[0].Value := RehberID;
    //TabCRMEkstre.Open;
    TabloYenile(TabCRMEkstre, [RehberID]);
   // cxGridCRMView.ApplyBestFit(nil);
    // cxGridCRMView.ApplyBestFit(nil);
  end;
end;

procedure TRehberWizardDlg.CRMEkstreEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TRehberWizardDlg.KodAgaciTusClick(Sender: TObject);
var
  s: integer;
begin
  if ComboGRUP.text = '' then
     raise Exception.Create(RWOnceGrupSeciniz);
  TabRehber.Edit;
  EditKOD.text := tablo.KodBulmaSihirbazi(ComboGRUP.EditValue, 'HESAPPLANI',
                   'HESAPKODU', 'HESAPADI', 'REHBER', 'KOD',StrToInt(VarToStrDef(ComboGRUP.EditValue,'0')));

  // Yeni kayitta, opsiyonda "otomatik doldur" isaretliyse: kod secildikten
  // sonra Vergi No sorup mukellef bilgisini cek.
  if YeniKayit and (Trim(EditKOD.text) <> '') and
     Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_OtomatikDoldur, False) then
    try
      VeriAlNACE;
    except
      on E: Exception do
        ShowMessage('Mukellef bilgisi alinamadi: ' + E.Message);
    end;
end;

procedure TRehberWizardDlg.VeriAlNACE;
// "Veri al": Vergi No sorar, uygulamanin e-Belge (izibiz) ayarlariyla
// /v2/taxpayers cagirir; REHBER.ID yoksa once kaydedip ID uretir, ardindan
// donen bilgileri ilgili alanlara (FIRMA + REHBERBILGI) yazar.
var
  VKNo: Variant;
  LVergiNo, LUser, LSifre, LURL, LToken, LHata, LJSON: string;
  LTest: Boolean;
  LHttp, i, LIletID: Integer;
  LRoot: TJSONValue;
  LObj, LAkt: TJSONObject;
  LActs: TJSONArray;
  LUnvan, LVD, LAdres, LIl, LIlce, LNace, LParca, LMevcutFirma: string;

  function _Str(AO: TJSONObject; const AKeys: array of string): string;
  var k: Integer; v: TJSONValue;
  begin
    Result := '';
    if AO = nil then Exit;
    for k := 0 to High(AKeys) do begin
      v := AO.GetValue(AKeys[k]);
      if (v <> nil) and not (v is TJSONNull) then begin
        Result := Trim(v.Value);
        if Result <> '' then Exit;
      end;
    end;
  end;

  // REHBERBILGI'yi REHBERAYAR sablonundan yazar: SIRA/ETIKET sablondan gelir
  // (ETIKET metin). Eslesme VARSAYILAN=NO ve YERI uzerinden (REHBERAYAR.MODUL
  // bu kurulumda NULL oldugundan MODUL ile filtre yapilmaz).
  //   ANo   : REHBERVARSAYILAN.NO (RehVars_*)
  //   AYeri : 2=firma bilgi (YER_ID=REHBER.ID), 1=iletisim (YER_ID=REHBERILETISIM.ID)
  procedure _EkBilgiYazNO(ANo, AYeri, AYerID: Integer; const ABilgi: string);
  var LWhere: string;
  begin
    if (Trim(ABilgi) = '') or (AYerID <= 0) then Exit;
    LWhere := 'RV.NO=' + IntToStr(ANo) + ' and RA.YERI=' + IntToStr(AYeri);
    // Ayni hedefte bu sablonun etiketi varsa once temizle (mukerrer olmasin).
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'delete from REHBERBILGI where YERI=' + IntToStr(AYeri) +
      ' and YER_ID=' + IntToStr(AYerID) +
      ' and ETIKET in (select RA.ETIKET from REHBERAYAR RA ' +
      ' inner join REHBERVARSAYILAN RV on RA.VARSAYILAN=RV.NO where ' + LWhere + ')',
      [], []);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,SUBEID) ' +
      'select RA.YERI, ' + IntToStr(AYerID) + ', RA.SIRA, RA.ETIKET, &B, ' +
      IntToStr(StrToIntDef(Kullanan, 0)) + ', ' + IntToStr(SubeID) + ' ' +
      'from REHBERAYAR RA inner join REHBERVARSAYILAN RV on RA.VARSAYILAN=RV.NO ' +
      'where ' + LWhere,
      ['&B'], [ABilgi]);
  end;

begin
  if Potansiyel then Exit;

  // 1) Vergi / T.C. No sor
  VKNo := '';
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
       TGirdiDenetimleri.Create.Edit('Vergi No :', @VKNo)) <> mrOK then Exit;
  LVergiNo := StringReplace(Trim(VarToStr(VKNo)), ' ', '', [rfReplaceAll]);
  if not (Length(LVergiNo) in [10, 11]) then begin
    ShowMessage('Gecerli bir vergi / T.C. kimlik no giriniz.');
    Exit;
  end;

  // 1.5) Bu vergi/T.C. no ile zaten kayit var mi? Varsa onay iste.
  LMevcutFirma := VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'select '+DbUst(1)+'R.FIRMA from REHBERBILGI RB ' +
    'inner join REHBER R on R.ID=RB.YER_ID ' +
    'where RB.YERI=2 and RB.BILGI=&V and RB.ETIKET in ' +
    '(select RA.ETIKET from REHBERAYAR RA inner join REHBERVARSAYILAN RV ' +
    ' on RA.VARSAYILAN=RV.NO where RV.NO=22 and RA.YERI=2) '+DbSinir(1),
    ['&V'], [LVergiNo], True));
  if Trim(LMevcutFirma) <> '' then
    if Application.MessageBox(PChar('Bu vergi/T.C. no ile zaten kayit var:' +
         sLineBreak + LMevcutFirma + sLineBreak + sLineBreak +
         'Yine de yeni kayit olusturulsun mu?'),
         PChar('Uyari'), MB_YESNO or MB_ICONQUESTION) <> IDYES then
      Exit;

  // 2) Kimlik + token (uygulamanin e-Belge ayarlari)
  TEBelgeKimlik.Yukle(LUser, LSifre, LURL, LTest);
  if (Trim(LUser) = '') or (Trim(LSifre) = '') or (Trim(LURL) = '') then begin
    ShowMessage('e-Belge (izibiz) kullanici/sifre/URL ayarlari eksik.');
    Exit;
  end;
  LToken := TEBelgeKimlik.TokenAl;
  if LToken = '' then begin
    if not TIzibizRest.Login(LURL, LUser, LSifre,
         Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EBelgeVergiNo, ''), '',
         LToken, LHata) then begin
      ShowMessage('izibiz giris (token) basarisiz: ' + LHata);
      Exit;
    end;
    TEBelgeKimlik.TokenSet(LToken);
  end;

  // 3) NACE / mukellef sorgu
  Screen.Cursor := crHourGlass;
  try
    if not TIzibizRest.GetTaxpayer(LURL, LToken, LVergiNo, True,
         LJSON, LHttp, LHata) then begin
      ShowMessage('Mukellef sorgu basarisiz (HTTP ' + IntToStr(LHttp) + '): ' +
        LHata);
      Exit;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  // 4) Yaniti coz
  LRoot := TJSONObject.ParseJSONValue(LJSON);
  if not (LRoot is TJSONObject) then begin
    if LRoot <> nil then LRoot.Free;
    ShowMessage('Beklenmeyen yanit: ' + Copy(LJSON, 1, 400));
    Exit;
  end;
  try
    LObj := TJSONObject(LRoot);
    if LObj.GetValue('data') is TJSONObject then
      LObj := TJSONObject(LObj.GetValue('data'));

    // Unvan: sirket -> commercialName; sahis -> name + surname.
    LUnvan := _Str(LObj, ['commercialName', 'title']);
    if LUnvan = '' then
      LUnvan := Trim(_Str(LObj, ['name']) + ' ' + _Str(LObj, ['surname']));
    LVD := _Str(LObj, ['taxoffice', 'taxOffice', 'taxOfficeName']);

    // Adres: addresses[0] -> il=city, ilce=subCity, adres=district+streetName+buildingNumber
    LAdres := ''; LIl := ''; LIlce := '';
    if LObj.GetValue('addresses') is TJSONArray then begin
      LActs := TJSONArray(LObj.GetValue('addresses'));
      if (LActs.Count > 0) and (LActs.Items[0] is TJSONObject) then begin
        LAkt := TJSONObject(LActs.Items[0]);
        LIl   := _Str(LAkt, ['city']);
        LIlce := _Str(LAkt, ['subCity']);
        LAdres := Trim(_Str(LAkt, ['district']) + ' ' +
                       _Str(LAkt, ['streetName']) + ' ' +
                       _Str(LAkt, ['buildingNumber']));
      end;
    end;

    // Faaliyet adi -> nota yazilir. Birden fazla varsa EN KISA olani secilir
    // (uzun aciklamali NACE metni degil, kisa faaliyet adi).
    LNace := '';
    if LObj.GetValue('activities') is TJSONArray then begin
      LActs := TJSONArray(LObj.GetValue('activities'));
      for i := 0 to LActs.Count - 1 do
        if LActs.Items[i] is TJSONObject then begin
          LAkt := TJSONObject(LActs.Items[i]);
          LParca := _Str(LAkt, ['activityName', 'description']);
          if (LParca <> '') and ((LNace = '') or (Length(LParca) < Length(LNace))) then
            LNace := LParca;
        end;
    end;

    if Trim(LUnvan) = '' then Exit;   // mukellef bilgisi yok -> sessizce cik

    // 5) Unvani FIRMA'ya yaz (alan + kontrol -> BoslukKontrolu gecsin), kaydet.
    if not (TabRehber.State in [dsEdit, dsInsert]) then TabRehber.Edit;
    if Trim(LUnvan) <> '' then begin
      TabRehber.FieldByName('FIRMA').AsString := LUnvan;
      EditFIRMA.Text := LUnvan;   // TabRehberBeforePost.BoslukKontrolu bunu okur
    end;
    if TabRehber.State in [dsEdit, dsInsert] then TabRehber.Post;
    RehberID := TabRehber.FieldByName('ID').AsInteger;
    if RehberID <= 0 then begin
      ShowMessage('REHBER kaydedilemedi (ID olusmadi). Unvan: ' + LUnvan);
      Exit;
    end;

    // 6) Firma duzeyi bilgiler (MODUL=2 -> YERI=2, YER_ID=REHBER.ID)
    _EkBilgiYazNO(RehVars_Vergi_No,       2, RehberID, LVergiNo);
    _EkBilgiYazNO(RehVars_Vergi_Dairesi,  2, RehberID, LVD);
    _EkBilgiYazNO(RehVars_Fatura_Basligi, 2, RehberID, LUnvan);

    // 7) Adres: once REHBERILETISIM satiri ekle, ID'sini al; YERI=1 bilgileri
    //    (MODUL=1) bu iletisim ID'sine yazilir.
    if (LAdres <> '') or (LIl <> '') or (LIlce <> '') then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into REHBERILETISIM(REHBERID,AD,VARSAYILAN,AKTIF,SUBEID) ' +
        'values(&R,&AD,1,1,&S)', ['&R', '&AD', '&S'], [RehberID, 'Merkez', SubeID]);
      // scope_identity() ayri batch'te NULL doner; yeni rehberde tek iletisim
      // satiri oldugundan max(ID) guvenli.
      LIletID := StrToIntDef(VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'select isnull(max(ID),0) from REHBERILETISIM where REHBERID=' +
        IntToStr(RehberID), [], [], True)), 0);
      if LIletID > 0 then begin
        _EkBilgiYazNO(RehVars_Adres,      1, LIletID, LAdres);
        _EkBilgiYazNO(RehVars_Adres_il,   1, LIletID, LIl);
        _EkBilgiYazNO(RehVars_Adres_ilce, 1, LIletID, LIlce);
      end;
    end;

    // 8) Faaliyet adlarini NOT olarak ekle (GOREVYORUM, REHBER notu TUR=11).
    if Trim(LNace) <> '' then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into GOREVYORUM(GOREVID,TUR,YORUM,EKLEYEN,EKLEMETARIHI,TARIH,PERSONEL) ' +
        'values(&G,11,&Y,&EK,getdate(),getdate(),1)',
        ['&G', '&Y', '&EK'], [RehberID, LNace, StrToIntDef(Kullanan, 0)]);
    end;

    // 9) Ekrani tazele (ekrana bilgi/ozet gosterilmez)
    TabloYenile(TabRehber, [RehberID]);
    TabloYenile(TabNotlar, [RehberID]);
  finally
    LRoot.Free;
  end;
end;

procedure TRehberWizardDlg.LabelAltBolgeClick(Sender: TObject);
begin
  if (ComboBolge.EditValue=null) or (ComboBolge.EditValue=0) then begin
      Application.MessageBox(PChar(STMarka_sec),PChar(HataPrj),MB_OK+ MB_ICONERROR);
      abort;
  end else begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM like ''-2210%'' and len(BOLUM)>5 and cast(BOLUM as varchar(30)) not in (select ''-2210''+cast(DEGER as varchar(30)) from GENINI where BOLUM=-2210)',[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM=0  and DEGER like ''-2210%'' and len(DEGER)>5 and cast(BOLUM as varchar(30)) not in (select ''-2210''+cast(DEGER as varchar(30)) from GENINI where BOLUM=-2210)',[],[]);
    if not Veritabani.VeriVarMi(Tablo.FDCnn,'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DEGER='+IntToStr(ComboAltBolge.Tag),[],[]) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) select 0,ANAHTAR,cast(BOLUM as varchar(10))+cast(DEGER as varchar(10)),DIL,0 from GENINI where BOLUM='+IntToStr(Ops_CariKart_Bolge)+' and DEGER='+VarToStr(ComboBolge.EditValue),[],[]);
    end;
    Tablo.LabelClickCombobox(Sender);
  end;
end;

procedure TRehberWizardDlg.LabelAltSektorClick(Sender: TObject);
begin
    tablo.GeniniBaslat(StrToInt(IntToStr(Ops_CariKart_Sektor)+TabRehber.FieldByName('SEKTOR').AsString), EditSektor.Text);
    //tablo.GENINI.ReadImageSection(Ops_CariKart_Sektor, Tablo.RepCariSektor.Properties.Items, False);
end;

procedure TRehberWizardDlg.LabelKategoriClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_CariKart_Kategori);
    tablo.GENINI.ReadImageSection(Ops_CariKart_Kategori, tablo.RepCariKategori.Properties.Items, False);
end;

procedure TRehberWizardDlg.LabelSektorClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_CariKart_Sektor);
    tablo.GENINI.ReadImageSection(Ops_CariKart_Sektor, Tablo.RepCariSektor.Properties.Items, False);
end;

procedure TRehberWizardDlg.LabelSorumluClick(Sender: TObject);
begin
  Application.CreateForm(TRehberTemsilciDlg, RehberTemsilciDlg);
  RehberTemsilciDlg.RehberId := TabRehber.FieldByName('ID').AsInteger;
  RehberTemsilciDlg.TemsilciId := TabRehber.FieldByName('TEMSILCI').AsInteger;
  RehberTemsilciDlg.ShowModal;
  RehberTemsilciDlg.Destroy;
end;

procedure TRehberWizardDlg.LabelTemasClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_CariKart_Temas);
    tablo.GENINI.ReadImageSection(Ops_CariKart_Temas, tablo.RepCariTemas.Properties.Items, False);
end;

procedure TRehberWizardDlg.lgiliKurumdanAyrld1Click(Sender: TObject);
begin
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update REHBER set DURUM=0 where ID=&ID', ['&ID'], [TabIlgili.FieldByName('ID').AsInteger]);

//  TabIlgili.Close;
//  TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' +TabRehber.Fields[0].AsString +'order by STATU  desc';
  TabloYenile(TabIlgili,[TabRehber.Fields[0].AsInteger, 0]);

  GridPersonellerViewSelectionChanged(nil);

end;

procedure TRehberWizardDlg.lgiliyeletiimBilgisiKopyala1Click(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  if (TabRehberIletisim.Active) and (TabRehberIletisim.RecordCount > 0) then
    Bilgi := TabRehberIletisim.FieldByName('ID').Value;
  ctrls := TGirdiDenetimleri.Create.ImageComboBox(RDIlgiliIletisimSec, @Bilgi,
    Tablo.FDCnn, 'select ID,AD from REHBERILETISIM where REHBERID=' + IntToStr(RehberID), False, Nil);
  if TGirisKutusuEx.BilgiAlEx(RDIletisimAdresiSecimi, ctrls) = mrOK then
  begin
    if Tablo.UyariGoster(Uyari,'Bu kişideki eski bilgiler silinecektir. Yine de devam etmek istiyor musunuz?',2) = mrYes then begin
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'delete from REHBERBILGI where YERI=1 and YER_ID=(select '+DbUst(1)+'RI.ID from REHBERILETISIM RI where RI.REHBERID=&YerID '+DbSinir(1)+')', ['&YerID'],
        [TabIlgili.FieldByName('ID').AsInteger]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI) ' +
        'select 1, YER_ID=(select '+DbUst(1)+'ID from REHBERILETISIM where REHBERID = &RehPersID '+DbSinir(1)+'), SIRA, ETIKET, BILGI from REHBERBILGI RB ' +
        'where RB.YERI=1 AND RB.YER_ID=&RehIletID', ['&RehPersID', '&RehIletID'],
        [TabIlgili.FieldByName('ID').AsInteger, Bilgi]);
    end;
  end;
  GridPersonellerViewSelectionChanged(nil);
end;

procedure TRehberWizardDlg.lgiliyiKopyala1Click(Sender: TObject);
var // yeni isim al?n?p di?er bilgiler kopyalanacak..
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi := TabIlgili.FieldByName('ADSOYAD').AsString;
  ctrls := TGirdiDenetimleri.Create.Edit(RDYeniilgiliADSoyadGir, @Bilgi);
  if TGirisKutusuEx.BilgiAlEx(RDAdSoyad, ctrls) = mrOK then
  begin
    tablo.TablodanSorguAc(3,
      ('insert into REHBERPERSONEL(REHBERID,ADSOYAD,VARSAYILAN,NOTLAR,NEREDE,SUBEID)values('
      + TabRehber.FieldByName('ID').AsString + ',''' + Bilgi + ''',0,''' +
      TabIlgili.FieldByName('NOTLAR').AsString + ''',1,' + IntToStr(SubeID) +
      ') select scope_identity() '));
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,SUBEID) select 4,&Yer_ID,SIRA,ETIKET,BILGI,SUBEID from REHBERBILGI where YERI=4 and YER_ID=&YerID2',
      ['&Yer_ID', '&YerID2'], [tablo.Query3.Fields[0].AsInteger,
      TabIlgili.FieldByName('ID').AsInteger]);

//    TabIlgili.Close;
//    TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' +TabRehber.Fields[0].AsString;
//    TabIlgili.SQL.Add(' order by STATU  desc');
    TabloYenile(TabIlgili,[TabRehber.Fields[0].AsInteger, 0]);

    GridPersonellerViewSelectionChanged(nil);
  end;
end;

procedure TRehberWizardDlg.Varsaylan1Click(Sender: TObject);
begin
  if TabIlgili.FieldByName('NEREDE').AsInteger = 1 then
  begin

    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'Update REHBER Set STATU=0 Where DURUM>0 and GRUP=334 and BAGID=&RehID',['&RehID'], [TabRehber.FieldByName('ID').AsInteger]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'Update REHBERPERSONEL Set STATU=1 Where DURUM>0 and GRUP=334 and BAGID=&RehID and ID=&PersID',
      ['&RehID', '&PersID'], [TabRehber.FieldByName('ID').AsInteger,TabIlgili.FieldByName('ID').AsInteger]);
//    TabIlgili.Close;
//    TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' + TabRehber.Fields[0].AsString;
//    TabIlgili.SQL.Add(' order by STATU  desc');
    TabloYenile(TabIlgili,[TabRehber.Fields[0].AsInteger, 0]);

    GridPersonellerViewSelectionChanged(nil);
  end;
end;

procedure TRehberWizardDlg.LogoResimClick(Sender: TObject);
begin
   if TabRehber.State in [dsEdit, dsInsert] then
      TabRehber.Post;
   Tablo.ResimSihirbazBaslat(Tabno_Rehber,TabRehber.Fields[0].AsInteger);
   TabloYenile(TabRehber, [TabRehber.Fields[0].AsInteger]);
end;

procedure TRehberWizardDlg.MenuItem7Click(Sender: TObject);
begin
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'Update REHBERILETISIM Set VARSAYILAN=0 Where AKTIF=1 and REHBERID=&RehID',
    ['&RehID'], [TabRehber.FieldByName('ID').AsInteger]);
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'Update REHBERILETISIM Set VARSAYILAN=1 Where AKTIF=1 and REHBERID=&RehID and ID=&IletID',
    ['&RehID', '&IletID'], [TabRehber.FieldByName('ID').AsInteger,
    TabRehberIletisim.FieldByName('ID').AsInteger]);
  TabRehberIletisim.Close;
  TabRehberIletisim.SQL.text := 'select * from REHBERILETISIM where REHBERID=' +
    TabRehber.Fields[0].AsString;
  TabRehberIletisim.SQL.Add(' order by STATU  desc');
  TabRehberIletisim.Open;
  GridAdresAdViewSelectionChanged(nil);
end;

procedure TRehberWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TRehberWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TRehberWizardDlg.PersonelIletisimEkrEnterPage(Sender: TObject;const FromPage: TJvWizardCustomPage);
begin
  if not TabIlgili.Active then
  begin
//    TabIlgili.Close;
//    TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID);
    if RehberPerID > 0 then
      // e?er bir ilgili ?zerinde ?ift t?k yap?p de?i?iklik olacaksa
      //TabIlgili.SQL.Add(' and ID=' + IntToStr(RehberPerID));
       TabloYenile(TabIlgili,[RehberID, RehberPerID])
    else
//    TabIlgili.SQL.Add(' order by STATU  desc');
       TabloYenile(TabIlgili,[RehberID, 0]);
    GridIlet.Visible := TabIlgili.RecordCount > 0;
    if (RehberPerID = -1) and (Cagiran = 4) then
    // yeni tu?una bas?lm?? demektir
      YeniPerTus.Click;
    if GridIlet.Visible then
    begin
      GridPersonellerView.DataController.FocusedRecordIndex := 0;
      GridPersonellerView.ViewData.Records[0].Selected := true;
    end;
  end;
end;

procedure TRehberWizardDlg.PersonelIletisimEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TRehberWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TRehberWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabloNo, TabRehber.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TRehberWizardDlg.SilPerTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO)= IDYES then begin
      CariIlgiliSil(TabRehber.Fields[0].AsInteger, TabIlgili.Fields[0].AsInteger,TabIlgili.FieldByName('STATU').AsBoolean);
//      TabIlgili.Close;
//      TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + ' order by STATU  desc';
      TabloYenile(TabIlgili,[RehberID, 0]);
      GridPersonellerViewSelectionChanged(nil);
  end;
end;

procedure TRehberWizardDlg.YeniAdresTusClick(Sender: TObject);
var
  EtiAdi : Variant;
  IletID : integer;
begin
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Edit(IletisimAdiniGirin, @EtiAdi)) = mrOK then begin
    // if EklePerIlet then //daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
    // Ekle(TabPerIlet,4,RehberPerID,'De?i?');

     TabRehberIletisim.Append;
     TabRehberIletisim.FieldByName('AD').AsString := Trim(EtiAdi);
     TabRehberIletisim.FieldByName('VARSAYILAN').AsBoolean := TabRehberIletisim.RecordCount < 1;
     TabRehberIletisim.Post;
     IletID := TabRehberIletisim.FieldByName('ID').AsInteger;
     tablo.TablodanSorguAc(1, 'Select '+DbUst(1)+'* from REHBERILETISIM where REHBERID=' + IntToStr(RehberID) + ' '+DbSinir(1));

     if tablo.Query1.RecordCount < 1 then
        PersonelVarsayilanYap(RehberID, TabRehberIletisim.FieldByName('ID').AsInteger);

     TabRehberIletisim.Close;
     TabRehberIletisim.SQL.text := 'select * from REHBERILETISIM where REHBERID=' + IntToStr(RehberID);
     //TabRehberIletisim.SQL.Add(' and ID in (Select MAX(ID) from REHBERILETISIM where REHBERID=' + IntToStr(RehberID) + ' )');
     TabRehberIletisim.Open;
     TabRehberIletisim.Locate('ID',IletID,[]);
     GridKurIlet.Visible := true;
     GridAdresAdViewSelectionChanged(nil);
  end
  else
     WizardKontrolCancelButtonClick(Sender);
end;

procedure TRehberWizardDlg.YeniPerTusClick(Sender: TObject);
var
  EtiAdi, Gorev: Variant;
begin
//  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Edit(ilgiliAdiniGirin, @EtiAdi)) = mrOK then
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Edit(IletisimAdiniGirin, @EtiAdi)) = mrOK then
     //      .ImageComboBox(AGS_Gorevler,@Gorev,Tablo.FDCnn,'select G.DEGER, G.ANAHTAR from GENINI G where G.BOLUM=-2205 order by 2',False, nil)) = mrOK then
  begin
    // if EklePerIlet then //daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
    // Ekle(TabPerIlet,4,RehberPerID,'De?i?');


    //?nce Rehber tablosuna personel eklenir
    TabIlgili.Append;
    TabIlgili.FieldByName('FIRMA').AsString := Trim(EtiAdi);
    TabIlgili.FieldByName('STATU').AsBoolean := TabIlgili.RecordCount < 1;
    TabIlgili.Post;
    // Sonra Rehber ?leti?im tablosuna  'Merkez' ekleniyor.
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
      + TabIlgili.FieldByName('ID').AsString  + ',''Merkez'',1,1,' + IntToStr(SubeID) + ')', [], []);
    TabloYenile(TabPerIletisim, [TabIlgili.FieldByName('ID').AsInteger]);

    tablo.TablodanSorguAc(5, 'Select isnull(MAX(ID),0) from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID));
    if tablo.Query5.fields[0].AsInteger < 1 then
       PersonelVarsayilanYap(RehberID, TabIlgili.FieldByName('ID').AsInteger);

//    TabIlgili.Close;
//    TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' +IntToStr(RehberID);
//    TabIlgili.SQL.Add(' and ID in (Select MAX(ID) from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + ' )');
    TabloYenile(TabIlgili,[RehberID, tablo.Query5.fields[0].AsInteger]);

    GridIlet.Visible := true;
    GridPersonellerViewSelectionChanged(nil);
  end
  else
    WizardKontrolCancelButtonClick(Sender);

end;

procedure TRehberWizardDlg.YorumDuzenleClick(Sender: TObject);
begin
   if not YorumDuzenle.Visible then exit;
   YorumDuzenleIslemi(TabNotlar, TabRehber.Fields[0].AsInteger);
end;

procedure TRehberWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
end;

procedure TRehberWizardDlg.YorumEkleTusClick(Sender: TObject);
begin
   if TabRehber.State in [dsEdit, dsInsert] then begin
      TabRehber.Post;
      RehberID := TabRehber.Fields[0].AsInteger;
   end;

   YorumEkleIslemi(TabRehber,TabNotlar, TabRehber.Fields[0].AsInteger);
end;

procedure TRehberWizardDlg.YorumSilClick(Sender: TObject);
begin
   YorumSilIslemi(TabNotlar, TabNotlar.Fields[0].AsInteger);
end;

procedure TRehberWizardDlg.TabCRMEkstreAfterScroll(DataSet: TDataSet);
begin
  if TabCRMEkstre.FieldByName('ISLEMTIPI').AsInteger = 1 then
  begin // proje
    if not tablo.YetkiVarmi(2111, YetkiTur_Degistirme, False) then
    // proje de?i?tirme yetkisi
      cxGridCRMView.OnDblClick := Nil
    else
      cxGridCRMView.OnDblClick := cxGridCRMViewDblClick
  end
  else
    cxGridCRMView.OnDblClick := cxGridCRMViewDblClick;
end;

procedure TRehberWizardDlg.TabIlgiliAfterPost(DataSet: TDataSet);
begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update REHBER Set KOD=cast(ID as varchar(15)) Where ID=&ID',['&ID'],[TabIlgili.FieldByName('ID').AsInteger]);
end;

procedure TRehberWizardDlg.TabIlgiliAfterScroll(DataSet: TDataSet);
begin
   TabloYenile(TabPerIletisim, [TabIlgili.FieldByName('ID').AsInteger]);
end;

procedure TRehberWizardDlg.TabIlgiliBeforeOpen(DataSet: TDataSet);
begin
{  TabIlgili.SQL.Text := StringReplace(TabIlgili.SQL.Text,
                                      'select * from',
                                      'select *,'+
                                      'GOREV = (select top 1 BILGI from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RA.SIRA=RB.SIRA AND RA.VARSAYILAN=175  where RB.YERI=4 AND RB.YER_ID=REHBERPERSONEL.ID)'+
                                      ' from ',
                                      [rfIgnoreCase]); }
end;

procedure TRehberWizardDlg.TabIlgiliBeforePost(DataSet: TDataSet);
begin
  TabIlgili.FieldByName('DEGISTIREN').AsString := Kullanan;
  TabIlgili.FieldByName('DEGISTIRMETARIHI').AsDateTime := tablo.GENINI.BugunTrh;
end;

procedure TRehberWizardDlg.TabIlgiliNewRecord(DataSet: TDataSet);
begin
  TabIlgili.FieldByName('GRUP').AsInteger := 334;
  TabIlgili.FieldByName('BAGID').AsInteger := RehberID;
  TabIlgili.FieldByName('EKLEYEN').AsString := Kullanan;
  TabIlgili.FieldByName('DURUM').Asinteger := 1;
  TabIlgili.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TRehberWizardDlg.TabCariIletNewRecord(DataSet: TDataSet);
begin
  TabCariIlet.FieldByName('SIRA').AsInteger := 99;
  TabCariIlet.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TRehberWizardDlg.TabPerIletNewRecord(DataSet: TDataSet);
begin
  TabPerIlet.FieldByName('SIRA').AsInteger := 99;
  TabPerIlet.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TRehberWizardDlg.TabRehberAfterPost(DataSet: TDataSet);
begin
  if YeniEklenenKayit then
  begin
    if KNo<>'' then //Kimlik no varsa kaydedelim
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO REHBERBILGI([YERI],[YER_ID],[SIRA],[ETIKET],[BILGI],EKLEYEN, '+
       ' SUBEID) SELECT YERI=2,YER_ID='+TabRehber.Fields[0].AsString+',SIRA,ETIKET,BILGI='''+KNo+''', EKLEYEN='+Kullanan+
       ', SUBEID='+IntToStr(SubeId)+' FROM REHBERAYAR RA inner join REHBERVARSAYILAN RV on RA.VARSAYILAN=RV.NO and RV.NO=22 ',[], []);
    // NOT: kart (REHBER) EKLEME loglamasi buradan KALDIRILDI. AfterPost wizard
    // boyunca birden cok kez atesleniyor -> loglama Finish'te (WizardKontrolFinishButtonClick)
    // tek sefer yapiliyor.
  end;
  YeniEklenenKayit := False;
  //temsilci de?i?irse ge?mi?e ekleme yapal?m..
  if OncekiTemsilciId <> TabRehber.FieldByName('TEMSILCI').AsInteger  then begin
     if TabRehber.FieldByName('TEMSILCI').AsInteger > 0  then
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into REHBERTEMSILCI (REHBERID, TEMSILCIID, BASLAMA, BITIS, ACIKLAMA, EKLEYEN) '+
          ' Values ('+TabRehber.FieldByName('ID').AsString+','+TabRehber.FieldByName('TEMSILCI').AsString+','''+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)+''',''2099-01-01'','''','+Kullanan+') ',[],[]);

     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update REHBERTEMSILCI set BITIS   = '''+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)+
        ''', ACIKLAMA = '''', DEGISTIREN = '+Kullanan+', DEGISTIRMETARIHI=getdate() where REHBERID= '+ TabRehber.FieldByName('ID').AsString+'  and TEMSILCIID='+IntToStr(OncekiTemsilciId)+ ' and BITIS = ''2099-01-01''',[],[]);
  end;
  // NOT: kart (REHBER) EDIT loglamasi (LogIslemleri) buradan KALDIRILDI ->
  // Finish'te (WizardKontrolFinishButtonClick) tek sefer yapiliyor.
end;

// Cari detay dataset'leri (REHBERILETISIM vb.) icin ORTAK log. BeforeEdit'te snapshot,
// AfterPost'ta edit -> LogIslemleri, yeni satir -> LogKayitEkle. ust=(REHBER, cari ID).
procedure TRehberWizardDlg.DetayBeforeEdit(DataSet: TDataSet);
begin
  if LogGun > 0 then Tablo.OncekiLogBelirle(TFDQuery(DataSet));
end;

procedure TRehberWizardDlg.DetayAfterPost(DataSet: TDataSet);
var
  LTabNo: Integer;
begin
  if LogGun <= 0 then Exit;
  if (DataSet = TabRehberIletisim) or (DataSet = TabPerIletisim) then
    LTabNo := TabNo_REHBERILETISIM
  else if (DataSet = TabCariIlet) or (DataSet = TabPerIlet) or (DataSet = TabTicari) then
    LTabNo :=  TabNo_REHBERBILGI
  else
    Exit;
  // Detay ISLEMTIPI'si ANA KARTIN modunu izlesin: yeni cari -> ekle(1), mevcut cari -> degis(2).
  // Boylece kart + tum detaylar ayni ISLEMTIPI'de gruplanir -> UInfo'da TEK satir
  // (mevcut cariye iletisim/ticari eklenince ayri 'Ekleme' satiri cikmaz).
  if YeniKayit then LogUstModu := 1 else LogUstModu := 2;
  LogDetaySatirPost(DataSet, LTabNo, TabNo_REHBER, TabRehber.FieldByName('ID').AsInteger);
end;

procedure TRehberWizardDlg.TabRehberAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabSonAktivite, [TabRehber.FieldByName('ID').AsInteger]);
end;

procedure TRehberWizardDlg.TabRehberBeforeEdit(DataSet: TDataSet);
begin
  if LogGun > 0 then begin
    tablo.OncekiLogBelirle(TabRehber);
    FKartSnap.Assign(LogOnceki);   // detay logu LogOnceki'yi temizlese de kart diff'i icin sakla
    FKartSnapID := TabRehber.FieldByName('ID').AsInteger;
    // Kart snapshot'i FKartSnap'e alindi -> global LogOnceki'yi bosalt. Yoksa duzenleme
    // sirasinda EKLENEN yeni detay (iletisim/ticari) LogDetaySatirPost'ta LogOnceki dolu
    // gorunup kart snapshot'ina karsi pozisyonel diff'lenir (cop diff). Kart diff'i Finish'te
    // FKartSnap'ten geri yuklenir.
    LogOnceki.Clear;
  end;
end;

procedure TRehberWizardDlg.TabRehberBeforePost(DataSet: TDataSet);
begin
  BoslukKontrolu;
  TabRehber.FieldByName('DEGISTIREN').AsString := Kullanan;
  TabRehber.FieldByName('DEGISTIRMETARIHI').AsDateTime := tablo.GENINI.BugunTrh;

  if (Potansiyel)and(TabRehber.FieldByName('KOD').AsString='') then begin
      Tablo.TablodanSorguAc(1,'select isnull(max(ID),0) + 1 from REHBER ');
      TabRehber.FieldByName('KOD').AsString:= Tablo.Query1.Fields[0].AsString;
  end;
end;

procedure TRehberWizardDlg.TabRehberIletisimNewRecord(DataSet: TDataSet);
begin
  TabRehberIletisim.FieldByName('REHBERID').AsInteger := RehberID;
  TabRehberIletisim.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TRehberWizardDlg.TabRehberNewRecord(DataSet: TDataSet);
begin
  TabRehber.FieldByName('DURUM').AsInteger := 1;
  TabRehber.FieldByName('EKLEYEN').AsString := Kullanan;
  TabRehber.FieldByName('TEMSILCI').AsString := Kullanan;
  TabRehber.FieldByName('POSTA').AsBoolean := False;
  TabRehber.FieldByName('EPOSTA').AsBoolean := False;
  TabRehber.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  TabRehber.FieldByName('PERYOT').AsInteger := 0;
  if Potansiyel then
     TabRehber.FieldByName('GRUP').AsInteger := 1
  else
     TabRehber.FieldByName('GRUP').AsInteger := 0;
  TabRehber.FieldByName('KOD').AsString :='';
  
  TabRehber.FieldByName('SUBEID').AsInteger := SubeId;
  YeniEklenenKayit := true;
  YeniKayit := true;
end;

procedure TRehberWizardDlg.TabTicariBeforePost(DataSet: TDataSet);
var
  YetkiEk: string;
begin
  if TabTicari.FieldByName('VARSAYILAN').Value <> null then
    case TabTicari.FieldByName('VARSAYILAN').Value of
      95:
        begin // risk tutar? kullan?c? yetkisine g?re yaz?labilinir..
          YetkiEk := tablo.YetkiEkVarMi(22013001);
          if (YetkiEk <> '') and
            (StrToInt(YetkiEk) <
            StrToInt(vartostr(TabTicari.FieldByName('BILGI').Value))) then
          begin
            ShowMessage
              (CRRisk_limiti_asimi_islem_basarisiz);
            TabTicari.Cancel;
          end;
        end;
    end;
end;

procedure TRehberWizardDlg.TabTicariNewRecord(DataSet: TDataSet);
begin
  TabTicari.FieldByName('SIRA').AsInteger := 99;
  TabTicari.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TRehberWizardDlg.TicariEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  if not TabTicari.Active then
  begin
    TabTicari.Close;
    TabTicari.SQL.text := StringReplace(SQLTicari.text, ':SPID', IntToStr(SPID),
      [rfReplaceAll]);
    TabTicari.Params[0].Value := 2;
    TabTicari.Params[1].Value := RehberID;
    TabTicari.Params[2].Value := RehberID;
    TabTicari.Open;
  end;
end;

procedure TRehberWizardDlg.TicariEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TRehberWizardDlg.ToolButton6Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO)= IDYES then begin
      CariIlgiliSil(TabRehber.Fields[0].AsInteger, TabIlgili.Fields[0].AsInteger,TabIlgili.FieldByName('VARSAYILAN').AsBoolean);
      //TabIlgili.Close;
      //TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + ' order by STATU  desc';
      TabloYenile(TabIlgili,[RehberID, 0]);
      GridPersonellerViewSelectionChanged(nil);
  end;
end;

function TRehberWizardDlg.BosZorunluAlanSay(DTS: TDataSource;
  Alan: string): Integer;
var
  bm: TBookmark;
begin
  // bm:= ((Dts.DataSet) as TFDQuery).GetBookmark;
  bm := ((DTS.DataSet) as TFDQuery).Bookmark; // Pointer(Dts.DataSet.Bookmark);
  Result := 0;
  // if ((Dts.DataSet) as TFDQuery).State in [dsInsert,dsEdit] then
  // ((Dts.DataSet) as TFDQuery).Post;
  DTS.DataSet.DisableControls;
  ((DTS.DataSet) as TFDQuery).first;
  while not((DTS.DataSet) as TFDQuery).Eof do
  begin
    if ((DTS.DataSet) as TFDQuery).FieldByName('ZORUNLU').AsBoolean then
    begin
      if Length(Trim(((DTS.DataSet) as TFDQuery).FieldByName(Alan).AsString)) = 0
      then
        Inc(Result);
    end;
    ((DTS.DataSet) as TFDQuery).Next;
  end;
  ((DTS.DataSet) as TFDQuery).GotoBookmark(bm);
  DTS.DataSet.EnableControls;
end;

procedure TRehberWizardDlg.btnCariKartClick(Sender: TObject);
begin
  if TabRehber.State in [dsEdit, dsInsert] then
  begin
    TabRehber.Post;
    RehberID := TabRehber.Fields[0].AsInteger;
  end;
  WizardKontrol.ActivePageIndex := (Sender as TcxButton).Tag;
end;

procedure TRehberWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
   Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabloNo, TabRehber.FieldByName('ID').AsInteger, TabRehber.FieldByName('ID').AsInteger,TabYorum);
end;

procedure TRehberWizardDlg.ButtonDuzenle;
begin
  if Cagiran = 0 then begin
     btnCariKart.Enabled := btnCariKart.Tag <> WizardKontrol.ActivePageIndex;
     Btniletisim.Enabled := Btniletisim.Tag <> WizardKontrol.ActivePageIndex;
     btnTicariBilgiler.Enabled := btnTicariBilgiler.Tag <>WizardKontrol.ActivePageIndex;
     BtnKisiBilgiFormu.Enabled := BtnKisiBilgiFormu.Tag <>WizardKontrol.ActivePageIndex;
     BtnDokuman.Enabled := BtnDokuman.Tag <> WizardKontrol.ActivePageIndex;
     BtnCRM.Enabled := BtnCRM.Tag <> WizardKontrol.ActivePageIndex;
  end;
 { else
  begin
     btnCariKart.Enabled := False;
     Btniletisim.Enabled := False;
     btnTicariBilgiler.Enabled := False;
     BtnKisiBilgiFormu.Enabled := False;
     BtnDokuman.Enabled := False;
     BtnCRM.Enabled := False;
  end; }

end;

procedure TRehberWizardDlg.VarsayPerTusClick(Sender: TObject);
begin
  PersonelVarsayilanYap(RehberID, RehberPerID);
  // TabloYenile(TabIlgili,[RehberID]);
end;

procedure TRehberWizardDlg.DegisPerTusClick(Sender: TObject);
var
  EtiAdi: Variant;
begin
  EtiAdi := TabIlgili.FieldByName('FIRMA').AsString;
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
     TGirdiDenetimleri.Create.Edit(ilgiliAdiniGirin, @EtiAdi)) = mrOK then
  begin
    TabIlgili.Edit;
    TabIlgili.FieldByName('FIRMA').AsString := Trim(EtiAdi);
    TabIlgili.Post;
  end;

end;

procedure TRehberWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TRehberWizardDlg.DkmanSil1Click(Sender: TObject);
begin
    if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
        Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
        Tabloyenile(TabYorum,[TabloNo, TabRehber.FieldByName('ID').AsInteger]);
    end;
end;

procedure TRehberWizardDlg.DokumanEkrEnterPage(Sender: TObject;const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[TabloNo, TabRehber.FieldByName('ID').AsInteger]);
end;

procedure TRehberWizardDlg.DokumanEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TRehberWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
            TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabRehber.FieldByName('ID').AsInteger)
end;

procedure TRehberWizardDlg.DtsImajStateChange(Sender: TObject);
begin
  // BelgeEkleTus.Enabled:= DtsImaj.State = dsBrowse;
  // BelgeSilTus.Enabled:= BelgeEkleTus.Enabled;
  // BelgeGorTus.Enabled:= BelgeEkleTus.Enabled;
  // BelgeKaydetTus.Visible:= DtsImaj.State in [dsEdit, dsInsert];
  // BelgeIptalTus.Visible:= BelgeKaydetTus.Visible;
end;

procedure TRehberWizardDlg.DurumuSfrla1Click(Sender: TObject);
begin
  if TabIlgili.FieldByName('DURUM').AsInteger = 0 then
  begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBER set DURUM=1 where ID=&ID', ['&ID'],[TabIlgili.FieldByName('ID').AsInteger]);
//    TabIlgili.Close;
//    TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' +TabRehber.Fields[0].AsString;
//    TabIlgili.SQL.Add(' order by STATU  desc');
    TabloYenile(TabIlgili,[TabRehber.Fields[0].AsInteger, 0]);

    GridPersonellerViewSelectionChanged(nil);
  end;
end;

procedure TRehberWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  if (((Cagiran=0)and(TabRehber.Fields[0].AsString<>'')and(TabRehber.Fields[0].AsString<>GiristekiRehberId))
      or (FOturumID <> '')) then
    if Application.MessageBox(PChar('Yapılan değişiklikler kaybolacaktır. Devam edilsin mi?'),
         PChar('Onay'), MB_YESNO or MB_ICONWARNING) <> IDYES then begin ModalResult := mrNone; Exit; end;
  if (Cagiran=0)and(TabRehber.Fields[0].AsString<>'')and(TabRehber.Fields[0].AsString<>GiristekiRehberId) then begin//?ptal edildi ama kay?t olmu?. Onun i?in kayd? silece?iz
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERBILGI WHERE EXISTS (SELECT * FROM REHBERILETISIM RI WHERE RI.ID=REHBERBILGI.YER_ID AND RI.REHBERID='+TabRehber.Fields[0].AsString+' AND YERI=1 )',[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERILETISIM where REHBERID = '+TabRehber.Fields[0].AsString,[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERBILGI WHERE EXISTS (SELECT * FROM REHBERPERSONEL RP WHERE RP.ID=REHBERBILGI.YER_ID AND RP.REHBERID='+TabRehber.Fields[0].AsString+' AND YERI=4 )',[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERPERSONEL where REHBERID = '+TabRehber.Fields[0].AsString,[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERBILGI WHERE YERI in (2,3) and YER_ID ='+TabRehber.Fields[0].AsString,[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM IMAJ WHERE REHBERID='+TabRehber.Fields[0].AsString,[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBER WHERE ID='+TabRehber.Fields[0].AsString,[],[]);
  end
  else if FOturumID <> '' then
  begin
      // DUZENLEME iptali -> ilk hale don (snapshot geri yukle). Bekleyen edit'i iptal et.
      if TabRehber.State in [dsEdit, dsInsert] then TabRehber.Cancel;
      ULog.OturumGeriAl(FOturumID);
      FOturumID := '';
  end;
  Close;
end;

procedure TRehberWizardDlg.GirisEkrNextButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
  if TabRehber.State in [dsEdit, dsInsert] then
  begin
    TabRehber.Post;
    RehberID := TabRehber.Fields[0].AsInteger;
  end;
end;

procedure TRehberWizardDlg.GirisEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TRehberWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
  GenotipaEkle: Boolean;
  Durum, UpdateOldu: SmallInt;
begin
  GenotipaEkle := False;
  // Finish'te alt hareketler (Ekle -> ticari/iletisim/ilgili) ana kartin moduna gore
  // loglansin: yeni cari -> ekle(1), mevcut cari -> degis(2). Boylece kart + detaylar
  // tek ISLEMTIPI'de gruplanir -> UInfo'da TEK satir. (Detay Ekle icindeki ekle/degis/sil
  // buffer'lari LogYaz uzerinden yazildigindan LogUstModu override eder.)
  if YeniKayit then LogUstModu := 1 else LogUstModu := 2;
  //e?er daha ?nce kodu bo? olarak kaydedilmi? varsa kodunu Id yaps?n
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE REHBER SET KOD=cast(ID as varchar(20)) WHERE KOD=''''',[],[]);

  case Cagiran of
  // 0 Kurum i?in yeni, 1 kurum ileti?im,  2 Ticari, 3 Personel ?zl?k, 4 Personel ileti?im, i?in ileti?im bilgileri
    0:
      begin
        if TabRehber.FieldByName('DURUM').AsInteger > 1 then begin
           TabRehber.Edit;
           TabRehber.FieldByName('DURUM').AsInteger := 1;
        end;

        if TabRehber.State in [dsInsert] then begin
          BoslukKontrolu;
          TabRehber.Post;
          RehberID := TabRehber.Fields[0].AsInteger;
          GenotipaEkle := true;
        end else if TabRehber.State in [dsEdit] then begin
          BoslukKontrolu;
          // Gercek degisiklik yoksa Post etme -> DEGISTIREN/tarih ve gereksiz log olusmasin.
          // Yeni kayit her zaman Post edilmeli (YeniKayit / dsInsert dahil).
          if (TabRehber.State = dsInsert) or YeniKayit or TabRehber.Modified then
            TabRehber.Post
          else
            TabRehber.Cancel;
          RehberID := TabRehber.Fields[0].AsInteger;
        end
        else if TabRehber.State in [dsBrowse] then
        if EkleKurIlet then
           Ekle(TabCariIlet, 1, RehberIletID, Degis, '', TabNo_REHBER, RehberID, 75); // KurumIletisimEkle;
        if EkleTicari then
           Ekle(TabTicari, 2, RehberID, Degis, '', TabNo_REHBER, RehberID, 79); // TicariEkle;
        if EklePerIlet then
           Ekle(TabPerIlet, 1, RehberPerID, Degis, '', TabNo_REHBER, RehberID, 81, TabIlgili.FieldByName('FIRMA').AsString);
        tablo.TablodanSorguAc(1, 'Select ID from REHBERILETISIM Where REHBERID=' + IntToStr(RehberID) + ' ');
        if (tablo.Query1.RecordCount = 0) then begin
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
               'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
               + IntToStr(RehberID) + ',''Merkez'',1,1,' + IntToStr(SubeID) +')', [], []);
        end;
        TabloYenile(TabRehber,[TabRehber.Fields[0].AsInteger]);
        {if (Potansiyel)and(TabRehber.FieldByName('KOD').AsString='') then begin
           TabRehber.Edit;
           TabRehber.FieldByName('KOD').AsString:= TabRehber.FieldByName('ID').AsString;
           TabRehber.Post;
        end;  }
        if TabRehber.state in [dsEdit, dsInsert] then
           TabRehber.Post;
        //uyar? ya da yasak varsa durumu ona g?re de?i?tirir
        Tablo.CariDurumUpdate(RehberID);

        // KART (REHBER) loglama (TEK SEFER, Finish'te): yeni -> LogKayitEkle, edit -> LogIslemleri.
        // (AfterPost'tan tasindi; YeniKayit = bu oturumda yeni cari eklendi mi -> NewRecord'da set, resetlenmez.)
        if LogGun > 0 then begin
          if YeniKayit then
            FEkleLogland := LogKartEkle(TabRehber, TabNo_REHBER, True, FEkleLogland) or FEkleLogland
          else begin
            // Detay (iletisim) loglamasi LogOnceki'yi ezip/temizleyip kart diff'ini
            // kaybediyordu -> DOGRU karta ait snapshot'i geri yukle, sonra logla.
            if (FKartSnapID = RehberID) and (FKartSnap.Count > 0) then
              LogOnceki.Assign(FKartSnap);
            LogKartDegisti(TabRehber, TabNo_REHBER, RehberID);
          end;
        end;

      end;

    1:if EkleKurIlet then
        Ekle(TabCariIlet, 1, RehberIletID, Degis, '', TabNo_REHBER, RehberID, 75); // KurumIletisimEkle;
    2:if EkleTicari then
        Ekle(TabTicari, 2, RehberID, Degis, '', TabNo_REHBER, RehberID, 79); // TicariEkle;
    4:if EklePerIlet then
        Ekle(TabPerIlet, 1, RehberPerID, Degis, '', TabNo_REHBER, RehberID, 81, TabIlgili.FieldByName('FIRMA').AsString); // PersonelIletisimEkle;
  end;
  if RehberID <> SonEklenenCari then
    tablo.SKRehberEkle(RehberID);
  ModalResult := mrok;
end;

procedure TRehberWizardDlg.WizardKontrolNextButtonClick(Sender: TObject);
Var
  Sayfa: TJvWizardCustomPage;
begin
  // zorunlu alanlar? kontrol et!!
  Sayfa := WizardKontrol.ActivePage;
  // o sayfadaki zorunlu alanlar dolmu?sa next tu?u hata verir...
  if Sayfa = IletisimEkr then
  begin
    if BosZorunluAlanSay(DtsKurIlet, 'BILGI') > 0 Then
      raise Exception.Create(zorunlualanhata);
  end
  else if Sayfa = TicariEkr then
  begin
    if BosZorunluAlanSay(DtsTicari, 'BILGI') > 0 then
      raise Exception.Create(zorunlualanhata);
  end
  else if Sayfa = PersonelIletisimEkr then
  begin
    if BosZorunluAlanSay(DtsPerIlet, 'BILGI') > 0 then
      raise Exception.Create(zorunlualanhata);
  end
end;

destructor TRehberWizardDlg.Destroy;
begin
  // Geri-alinabilir oturum artigi: Finish/X ile kapandiysa snapshot kalmis olabilir (Cancel
  // ise OturumGeriAl icinde zaten temizlendi + FOturumID sifirlandi) -> kalani sil.
  if FOturumID <> '' then
  begin
    ULog.OturumBitir(FOturumID);
    FOturumID := '';
  end;
  // FALLBACK: yeni cari kaydedilip Finish'siz kapatildiysa EKLEME logu kacmasin (tek sefer).
  FEkleLogland := LogKartEkle(TabRehber, TabNo_REHBER, YeniKayit, FEkleLogland) or FEkleLogland;
  LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form kendi modunu set etmezse etkilenmesin)
  FKartSnap.Free;
  inherited;
end;

end.












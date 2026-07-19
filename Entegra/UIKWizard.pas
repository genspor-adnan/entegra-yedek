unit UIKWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxDBEdit, // cxMaskEdit,
  cxButtonEdit,  cxTextEdit, cxMemo, cxContainer, cxLabel, ExtCtrls, cxImage,
  FireDAC.Comp.Client, JvWizard, JvExControls, Menus, cxLookAndFeelPainters, cxDropDownEdit,
  StdCtrls, cxButtons, cxCalendar, cxCheckBox, cxSpinEdit, cxGroupBox,
  cxRadioGroup, cxImageComboBox, cxExtEditRepositoryItems, Utablo,
  cxEditRepositoryItems, cxShellEditRepositoryItems, cxDBEditRepository,
  cxDBExtLookupComboBox, UReplikasyon, cxDBLabel, dxSkinLondonLiquidSky,
  cxMaskEdit, cxCheckGroup, JvComponentBase, JvDragDrop, dxSkinBlack,
  dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dateutils,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinXmas2008Blue, UGentegreFrameYonetimi, cxCurrencyEdit,
  cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, cxLookAndFeels,
  cxNavigator, dxCore, cxDateUtils, cxGridCustomLayoutView, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  GT_RehberAbout, //URehberHareket,
  Vcl.DBCtrls, Usifre, dxBarBuiltInMenu, cxPC, cxGridCustomPopupMenu,
  cxGridPopupMenu, OfficePopupMenu, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxCoreGraphics, dxDateRanges,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TIKWizardDlg = class(TForm)
    WizardKontrol: TJvWizard;
    PersonelOzlukEkr: TJvWizardInteriorPage;
    TabKurIlet: TFDQuery;
    DtsKurIlet: TDataSource;
    DtsPers: TDataSource;
    Panel1: TPanel;
    PersonelIletisimEkr: TJvWizardInteriorPage;
    ToolBar2: TToolBar;
    YeniPerTus: TToolButton;
    SilPerTus: TToolButton;
    GridIlet: TcxGrid;
    GridIletView: TcxGridDBTableView;
    GridIletViewColumn1: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    SQLPerIlet_Eski: TcxMemo;
    GirisEkr: TJvWizardWelcomePage;
    GridTemel: TcxGrid;
    GridTemelView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    SQLTemel: TcxMemo;
    IletisimEkr: TJvWizardInteriorPage;
    GridKurIlet: TcxGrid;
    GridKurIletView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    SQLKurIlet: TcxMemo;
    TabPerOzluk: TFDQuery;
    DtsPerOzluk: TDataSource;
    TabPerIlet: TFDQuery;
    DtsPerIlet: TDataSource;
    GridKurIletViewColumn1: TcxGridDBColumn;
    GridIletViewColumn3: TcxGridDBColumn;
    GridTemelViewColumn1: TcxGridDBColumn;
    PersonelUcretEkr: TJvWizardInteriorPage;
    ToolBar5: TToolBar;
    GridUcret: TcxGrid;
    GridUcretView: TcxGridDBTableView;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    TabPerUcret: TFDQuery;
    DtsPerUcret: TDataSource;
    GridUcretViewColumn1: TcxGridDBColumn;
    SQLPerUcret: TcxMemo;
    GridUcretViewKur: TcxGridDBColumn;
    cxImageComboBox1: TcxImageComboBox;
    GridKurIletViewColumnsec: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    GridTemelViewColumn2: TcxGridDBColumn;
    GridIletViewColumn4: TcxGridDBColumn;
    GridUcretViewColumn2: TcxGridDBColumn;
    GridUcretViewColumn3: TcxGridDBColumn;
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
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    JvDragDrop1: TJvDragDrop;
    Panel2: TPanel;
    btnCariKart: TcxButton;
    BtnDokuman: TcxButton;
    BtnKisiBilgiFormu: TcxButton;
    BtnOzluk: TcxButton;
    Btniletisim: TcxButton;
    btnUcret: TcxButton;
    PersonelNEREDE: TcxGridDBColumn;
    cxGrid1: TcxGrid;
    GridAdresAdView: TcxGridDBTableView;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel7: TcxGridLevel;
    DtsRehberIlet: TDataSource;
    TabAdresAd: TFDQuery;
    YeniAdresTus: TToolButton;
    ToolButton2: TToolButton;
    PopupIletisim: TPopupMenu;
    MenuItem7: TMenuItem;
    AdresDegistir: TToolButton;
    TabDokuman: TFDQuery;
    DtsDokuman: TDataSource;
    Panel3: TPanel;
    Label6: TLabel;
    EditKOD: TcxDBTextEdit;
    Label1: TcxLabel;
    KodAgaciTus: TcxButton;
    EditFIRMA: TcxDBTextEdit;
    LblUnvan: TcxLabel;
    EditOzelKod: TcxDBTextEdit;
    Label3: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    Label34: TcxLabel;
    cxDBLabel2: TcxDBLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    cxLabel4: TcxLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    DBCheckBox1: TDBCheckBox;
    LabelDepartmani: TcxLabel;
    ComboCinsiyet: TcxImageComboBox;
    cxLabel2: TcxLabel;
    LabelGIRISTARIHI: TcxLabel;
    DateGIRISTARIHI: TcxDateEdit;
    LabelCIKISTARIHI: TcxLabel;
    DateCIKISTARIHI: TcxDateEdit;
    cxLabel6: TcxLabel;
    DateTARIH: TcxDBDateEdit;
    EditDYeri: TcxButtonEdit;
    LabelGorevi: TcxLabel;
    EditVKNO: TcxTextEdit;
    EditDepartman: TcxButtonEdit;
    EditGorevi: TcxButtonEdit;
    ListelerTus: TcxButton;
    ComboOgrenim: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    CariPageControl: TcxPageControl;
    SheetNotlar: TcxTabSheet;
    CariGridNotlar: TcxGrid;
    CariGridNotlarView: TcxGridDBCardView;
    CariGridNotlarViewBILGI: TcxGridDBCardViewRow;
    CariGridNotlarViewYORUM: TcxGridDBCardViewRow;
    CariGridNotlarLevel1: TcxGridLevel;
    ToolBar4: TToolBar;
    YorumEkleTus: TToolButton;
    YorumSil: TToolButton;
    YorumDuzenle: TToolButton;
    SheetEkAlanlar: TcxTabSheet;
    PanelEkAlanlar: TPanel;
    TabNotlar: TFDQuery;
    DtsNotlar: TDataSource;
    cxLabel3: TcxLabel;
    EditUyruk: TcxButtonEdit;
    TabPerIletisim: TFDQuery;
    DokumanEkr: TJvWizardInteriorPage;
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
    BtnDosyaGonder: TcxButton;
    LogoResim: TcxDBImage;
    cxLabel5: TcxLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBImageComboBox2: TcxDBImageComboBox;
    cxLabel7: TcxLabel;
    BtnGoogle: TToolButton;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    SQLPerIlet: TcxMemo;
    procedure FormShow(Sender: TObject);
    procedure YeniPerTusClick(Sender: TObject);
    procedure SilPerTusClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure MaasTarihPropertiesChange(Sender: TObject);
    procedure KodAgaciTusClick(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit
      (Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure EditAdPropertiesChange(Sender: TObject);
    procedure GridKurIletViewStylesGetContentStyle
      (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    Function BosZorunluAlanSay(DTS: TDataSource; Alan: string): Integer;
    procedure TabKurIletAfterPost(DataSet: TDataSet);
    procedure WizardKontrolNextButtonClick(Sender: TObject);
    procedure TabPerUcretNewRecord(DataSet: TDataSet);
    procedure TabPerIletNewRecord(DataSet: TDataSet);
    procedure TabKurIletNewRecord(DataSet: TDataSet);
    procedure TabPerOzlukNewRecord(DataSet: TDataSet);
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
    procedure PersonelOzlukEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure IletisimEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure PersonelUcretEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure GridIletViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridTemelViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridUcretViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridKurIletViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure TabRehberBeforeEdit(DataSet: TDataSet);
    procedure TabRehberAfterPost(DataSet: TDataSet);
    procedure DetayBeforeEdit(DataSet: TDataSet);   // IK detay iletisim: log oncesi snapshot
    procedure DetayAfterPost(DataSet: TDataSet);     // IK detay iletisim: edit/insert log (ust=personel)
    procedure TabRehberAfterScroll(DataSet: TDataSet);
    procedure GridKurIletViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure ComboGRUPPropertiesChange(Sender: TObject);
    procedure MaasTarihPropertiesEditValueChanged(Sender: TObject);
    procedure ButtonDuzenle;
    procedure GirisEkrPage(Sender: TObject);
    procedure IletisimEkrPage(Sender: TObject);
    procedure PersonelIletisimEkrPage(Sender: TObject);
    procedure DokumanEkrPage(Sender: TObject);
    procedure PersonelOzlukEkrPage(Sender: TObject);
    procedure PersonelUcretEkrPage(Sender: TObject);
    procedure GridUcretViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridTemelViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridIletViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure TabAdresAdNewRecord(DataSet: TDataSet);
    procedure GridAdresAdViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure YeniAdresTusClick(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure AdresDegistirClick(Sender: TObject);
    procedure EditTEMSILCIKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboSubeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboSubePropertiesCloseUp(Sender: TObject);
    procedure TabDokumanBeforeOpen(DataSet: TDataSet);
    procedure GridKurIletViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure GridKurIletViewEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridKurIletViewFocusedItemChanged(Sender: TcxCustomGridTableView;
      APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
    procedure GridKurIletViewInitEdit(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
    procedure AdresSilTusClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Label6DblClick(Sender: TObject);
    procedure btnCariKartClick(Sender: TObject);
    procedure ComboSINIFPropertiesCloseUp(Sender: TObject);
    procedure ComboCinsiyetPropertiesCloseUp(Sender: TObject);
    procedure ComboDURUMPropertiesEditValueChanged(Sender: TObject);
    procedure EditDYeriPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDepartmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListelerTusClick(Sender: TObject);
    procedure YorumSilClick(Sender: TObject);
    procedure YorumEkleTusClick(Sender: TObject);
    procedure YorumDuzenleClick(Sender: TObject);
    procedure EditUyrukPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabIlgiliAfterScroll(DataSet: TDataSet);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure cxLabel5Click(Sender: TObject);
    procedure LabelDepartmaniClick(Sender: TObject);
    procedure LabelGoreviClick(Sender: TObject);
    procedure cxLabel1Click(Sender: TObject);
    procedure BtnGoogleClick(Sender: TObject);

  private
    { Private declarations }
    FFrameBilgi: TIcerikFrameBilgi;
    KurIletZorunlu, PerIletZorunlu, PerOzlukZorunlu,
      PerUcretZorunlu: SmallInt;
    FEkAlanKuruldu: Boolean;   // ek-alan (REHBER_USER) kontrolleri kuruldu mu (yeni kartta ID gelince kurulur)
    FEkAlanKuruluyor: Boolean; // re-entry guard (Post/AlanOlustur sekme degisimini tekrar tetiklerse)
    // bo? kalan zorunlu alanlar? sayfalara g?re sayal?m.. next ve finish tu?lar?n?n visible lar?n? ayarlayal?m..
    function BoslukKontrolu: Boolean;
    procedure CariPageControlPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);

  public
    { Public declarations }
    Cagiran: SmallInt;
    // 0 Kurum i?in yeni, 1 kurum ileti?im,  3 Personel ?zl?k, 4 Personel ileti?imi?in ileti?im bilgileri
    RehberID, RehberIletID, RehberPerID: Integer;
    Ust: SmallInt; // 1 Kurum i?in, 2 Personel i?in ileti?im bilgileri
    UstId: Integer; // 1 Kurum i?in RehberId, 2 Personel i?in PersonelId
    PersIslemTipi: SmallInt; // 1 Yeni pers, 2 D?zenleme, 3 Silme;
    YeniKayit, Potansiyel:Boolean;
    FOturumID: string;   // geri-alinabilir oturum (Cagiran=0 personel duzenleme); '' = yok
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    FKartSnap: TStringList;  // kart (REHBER) BeforeEdit snapshot'i - detay logu LogOnceki'yi ezmesin
    FKartSnapID: Integer;    // snapshot'in ait oldugu kart ID'si
    destructor Destroy; override;
  end;

var
  IKWizardDlg: TIKWizardDlg;
  DYetkisonuc: DokumanYetkiSonuc;

implementation


{$R *.dfm}

uses
  UVeriMotor, PrjConst, UGirisKutusuEx, UCombo, FetaKurulusSiniflari, UGENINIDuzenle, UCokluSecim,
  Fetautil, UResim, UComboImgDuzenle, UCariFonksiyonlar, UBinarySave, UAnaForm,
  FetaClassExtensions, IdGlobalProtocols, UGenSifre,LocOnFly, UUnits, UGoogleSifre, ULog;

var
  EkleKurIlet,  EklePerOzluk, EklePerIlet, EklePerUcret, BireyselZorunlu: Boolean;
  KNo, GiristekiRehberId, OncekiGirisTarih, OncekiCikisTarih, OncekiTCNo : String[20];
  OncekiSinif, TabloNo:Smallint;

procedure TIKWizardDlg.AdresDegistirClick(Sender: TObject);
var
  EtiAdi: Variant;
begin
  EtiAdi := TabAdresAd.FieldByName('AD').AsString;
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
    TGirdiDenetimleri.Create.Edit(IletisimAdiniGirin, @EtiAdi)) = mrOK then
  begin
    TabAdresAd.Edit;
    TabAdresAd.FieldByName('AD').AsString := Trim(EtiAdi);
    TabAdresAd.Post;
  end;
end;

procedure TIKWizardDlg.AdresSilTusClick(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: adres silme -> yakala
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO)
    = IDYES then
  begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'delete from REHBERBILGI where YERI=1 and YER_ID=' +
      TabAdresAd.FieldByName('ID').AsString, [], []);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'delete from REHBERILETISIM where ID=' + TabAdresAd.FieldByName('ID')
      .AsString, [], []);
    TabloYenile(TabAdresAd, []);
  end;
end;

function TIKWizardDlg.BoslukKontrolu: Boolean;
begin
  BoslukKontrolu := true;
  if not Potansiyel then begin
      if not BoslukKontrol(EditKOD.text, KontrolKod) then
         Abort;
      if not BoslukKontrol(DateGIRISTARIHI.text, BGIse_giris_tarih) then
         Abort;
      if not BoslukKontrol(EditDepartman.text, AGS_Gorevler) then
         Abort;
  end;

  if not BoslukKontrol(EditFIRMA.text, KontrolFirma) then
    Abort;
  if not BoslukKontrol(ComboDURUM.text, KontrolDurum) then
    Abort;
  // if not BoslukKontrol(ComboKATEGORI.text, 'Kategori') then Abort;
  // if not BoslukKontrol(ComboSINIF.text, 'S?n?f') then Abort;
  BoslukKontrolu := False;
end;

procedure TIKWizardDlg.CariPageControlPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  // Yeni kart + ek-alan sekmesine gecis: personel (REHBER) kaydedilmemisse once kaydet (ID al),
  // sonra ek-alan (REHBER_USER) kontrollerini kur. Zorunlu alan bos ise Post Abort eder -> gecme.
  // Ortak mantik Tablo.EkAlanSekmeHazirla'da (re-entry/abort/kur).
  if NewPage = SheetEkAlanlar then
    Tablo.EkAlanSekmeHazirla(Self, TabRehber, DtsRehber, PanelEkAlanlar, 'REHBER_USER',
      RehberID, FEkAlanKuruldu, FEkAlanKuruluyor, AllowChange);
end;

procedure TIKWizardDlg.ComboCinsiyetPropertiesCloseUp(Sender: TObject);
begin
   TabRehber.Edit;
end;

procedure TIKWizardDlg.ComboDURUMPropertiesEditValueChanged(Sender: TObject);
begin
    DateCIKISTARIHI.Visible := (not Potansiyel)and(ComboDURUM.EditValue<>1);
    LabelCIKISTARIHI.Visible := (not Potansiyel)and(DateCIKISTARIHI.Visible)
end;

procedure TIKWizardDlg.ComboGRUPPropertiesChange(Sender: TObject);
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
              Tablo.UyariGoster(Uyari,IKMaksimum_sayi + IntToStr(uzunluk),1)
           else
              Result := VKno
        end;
  end;

begin
  if KNo<>'' then begin
     Tablo.TablodanSorguAc(1,'SELECT ID=YER_ID, KOD,FIRMA FROM REHBERBILGI RB inner join REHBER R on RB.YER_ID=R.ID '+
             ' where [YERI]=2 and BILGI='''+KNo+''' and BILGI<>'''+copy('00000000000',1,uzunluk)+''' ');
     if Tablo.Query1.RecordCount>0 then begin
        Tablo.UyariGoster(Uyari,CRKimlik_no_kullanilmis+Tablo.Query1.Fields[1].asstring+' '+Tablo.Query1.Fields[2].asstring,1);
        Close;
     end;
  end;
end;

procedure TIKWizardDlg.ComboSINIFPropertiesCloseUp(Sender: TObject);
begin
   //if ComboDepartman.EditValue <> null then
   //   ComboGorevi.Properties.items := Tablo.imgComboboxInit( 'SELECT ID,ROL FROM ROLLER WHERE DEPARTMAN = '+IntToStr(ComboDepartman.EditValue)+' ORDER BY 2 ').items;
end;

procedure TIKWizardDlg.ComboSubeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ComboSube.EditValue := 0;
end;

procedure TIKWizardDlg.ComboSubePropertiesCloseUp(Sender: TObject);
begin
  ComboSube.EditValue := tablo.SubeGetir
    (tablo.GENINI.ReadInteger(Ops_OpsiyonCari_GorunecekSubeler, 0),
    ComboSube.EditValue);
end;

procedure TIKWizardDlg.cxLabel1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_IK_Ogrenim);
   tablo.GENINI.ReadImageSection(Ops_IK_Ogrenim, Tablo.RepIKOgrenim.Properties.Items);
end;

procedure TIKWizardDlg.cxLabel5Click(Sender: TObject);
begin
   tablo.GeniniBaslat(Ops_IK_Statu);
   tablo.GENINI.ReadImageSection(Ops_IK_Statu, tablo.RepIKStatu.Properties.Items);
end;

procedure TIKWizardDlg.EditTEMSILCIKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_DELETE, VK_BACK] then begin
     TcxButtonEdit(Sender).Tag := 0;
     TcxButtonEdit(Sender).text := '';
  end;
end;

procedure TIKWizardDlg.EditUyrukPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
   Tablo.EditButtonStandart(EditUyruk, AButtonIndex, TabRehber,
         'select ILNO, ILADI from ILLER where ILNO > 100 and ILADI like ''%<ara>%''  ORDER BY 1 ')
end;

procedure TIKWizardDlg.GridAdresAdViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
  if TabAdresAd.Active then
    if TabAdresAd.RecordCount > 0 then
    begin
      if EkleKurIlet then // daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
      begin
        Ekle(TabKurIlet, 1, RehberIletID, Degis, '', TabloNo, RehberID, 75);
      end;
      RehberIletID := TabAdresAd.Fields[0].AsInteger;

      TabKurIlet.Close;
      TabKurIlet.SQL.text := StringReplace(SQLKurIlet.text, ':SPID',IntToStr(SPID), [rfReplaceAll]);
      //TabKurIlet.Params[0].Value := 1;
      //TabKurIlet.Params[1].Value := RehberIletID; // RehberPerID;
      //TabKurIlet.Params[2].Value := RehberIletID; // RehberPerI;
      //TabKurIlet.Open;
      Tabloyenile(TabKurIlet,[1,RehberIletID,RehberIletID]);
      EkleKurIlet := False
    end
    else
      GridKurIlet.Visible := False;
end;

procedure TIKWizardDlg.EditAdPropertiesChange(Sender: TObject);
begin
   GridIlet.Visible := (TabIlgili.Active) and (TabIlgili.RecordCount > 0);
end;

procedure TIKWizardDlg.EditDepartmanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  ID : Integer;
begin
   //tablo.EditDepartmanSec(TcxButtonEdit(Sender), AButtonIndex, TcxButtonEdit(Sender).Tag, TabRehber, 'SINIF');
  ID := Tablo.RolAra_IDGetir;
  if ID<>-99 then begin
     TabRehber.Edit;
     TabRehber.FieldByName('SINIF').AsInteger := ID;
     Tablo.TablodanSorguAc(1,'select SUBEID,DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
        ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+') '+
        ' from ROLLER ROL where ROL.ID='+IntToStr(ID));
     ComboSube.EditValue := Tablo.Query1.Fields[0].AsInteger;
     ComboSube.PostEditValue;
     TabRehber.FieldByName('SUBEID').AsInteger := Tablo.Query1.Fields[0].AsInteger;
     EditDepartman.text := Tablo.Query1.Fields[1].AsString;
     EditGorevi.text := Tablo.Query1.Fields[2].AsString;
  end;
end;

procedure TIKWizardDlg.EditDYeriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
begin
  if AButtonIndex = 0 then
  begin
    st := Tstringlist.Create;
    if tablo.ListedenBilgiGetir(KategoriListesi,
       'select * from ILILCE where  ILADI like ''%<ara>%'' or ILCEADI like ''%<ara>%'' ORDER BY 1,4 ', st, []) then begin
       TabRehber.Edit;
       TabRehber.FieldByName('BOLGE').AsString := st.Strings[1];
       if StrToInt(st.Strings[1])<500 then
          EditDYeri.text := st.Strings[2]
       else
          EditDYeri.text := st.Strings[3]+' / '+st.Strings[2];
    end;
    st.free;
  end
  else if AButtonIndex = 1 then
  begin
    TabRehber.Edit;
    TabRehber.FieldByName('BOLGE').AsInteger := 0;
    EditDYeri.text := '';
  end;
end;

procedure TIKWizardDlg.FormCreate(Sender: TObject);
  procedure HazirlaCacheDataSet(AQuery: TFDQuery);
  begin
    AQuery.CachedUpdates := True;
    AQuery.UpdateOptions.UpdateTableName := '';
    AQuery.UpdateOptions.KeyFields := '';
  end;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);

   FKartSnap := TStringList.Create;

   // IK personel iletisim (REHBERILETISIM) detayini ust=personel log'una bagla.
   TabPerIletisim.BeforeEdit := DetayBeforeEdit;
   TabPerIletisim.AfterPost  := DetayAfterPost;

   // LabelGrup.OnClick := Tablo.LabelClickCombobox;

   // Yetkilere g?re soldaki butonlar g?r?nmeyecek
   if not Tablo.YetkiVarmi(340103,YetkiTur_Gorme) then Btniletisim.Visible:=False;
   if not Tablo.YetkiVarmi(340106,YetkiTur_Gorme) then BtnKisiBilgiFormu.Visible:=False;
   if not Tablo.YetkiVarmi(340110,YetkiTur_Gorme) then BtnOzluk.Visible:=False;
   if not Tablo.YetkiVarmi(340115,YetkiTur_Gorme) then btnUcret.Visible:=False;
   if not Tablo.YetkiVarmi(340135,YetkiTur_Gorme) then BtnDokuman.Visible:=False;
   if (not Btniletisim.Visible)and(not BtnKisiBilgiFormu.Visible)and(not BtnOzluk.Visible)and(not btnUcret.Visible)and(not BtnDokuman.Visible) then
      GirisEkr.VisibleButtons := [bkFinish, bkCancel];


  Tablo.GridTurkcelestir;

  HazirlaCacheDataSet(TabPerIlet);
  HazirlaCacheDataSet(TabKurIlet);
  HazirlaCacheDataSet(TabPerOzluk);
  HazirlaCacheDataSet(TabPerUcret);
  cxGridDBColumn4.Options.Editing := True; // Bilgi kolonu art�k yaz�labilir
end;

procedure TIKWizardDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Key := 0;
end;

procedure TIKWizardDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var
  Tur: integer;
  ctrlPos: TPoint;
  clientPos: TPoint;
  Strin: String;
  ctrl: TWinControl;
begin
  clientPos := Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt, ssCtrl]) and (Key = Ord('E')) then
  begin // Yeni Bile?en Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then
    begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      tablo.AlanlarDlgBaslat('E', 1, -1, ctrlPos.X, ctrlPos.Y, -1,
        FindComponent(ctrl.Name), TIKWizardDlg(Self), Tablo.UserDataSourceHazirla(TIKWizardDlg(Self), DtsRehber, 'REHBER_USER'));
      tablo.AlanOlustur(TIKWizardDlg(Self), -1, Tablo.UserDataSourceHazirla(TIKWizardDlg(Self), DtsRehber, 'REHBER_USER'));
    end;
  end
  else if (Shift = [ssAlt, ssCtrl]) and (Key = Ord('D')) then
  begin // Bile?en D?zenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then
    begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := tablo.ComponentTurGetir(ctrl.ClassName);
      tablo.AlanlarDlgBaslat('D', 1, Tur, ctrlPos.X, ctrlPos.Y, ctrl.Tag,
        FindComponent(PanelEkAlanlar.Name), TIKWizardDlg(Self), Tablo.UserDataSourceHazirla(TIKWizardDlg(Self), DtsRehber, 'REHBER_USER'));
      tablo.AlanOlustur(TIKWizardDlg(Self), -1, Tablo.UserDataSourceHazirla(TIKWizardDlg(Self), DtsRehber, 'REHBER_USER'));
    end;
  end
  else if (Shift = [ssAlt, ssCtrl]) and (Key = Ord('S')) then
  begin // Bile?en Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then
    begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      if ctrl.Name <> '' then
      begin
        tablo.TablodanSorguAc(1,
          'Select CAPTION,ALANADI,TAG,TABLO from ALANLAR Where TAG=' +
          IntToStr(ctrl.Tag) + ' and TUR not in (11,19) ');
        if Application.MessageBox(PChar(tablo.Query1.FieldByName('CAPTION')
          .AsString + ' alan?n? silmek istiyor musunuz ?'), 'UYARI', MB_YESNO) = mrYes
        then
        begin
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'Delete from ALANLAR Where TAG =' + IntToStr(ctrl.Tag) +
            ' ', [], []);
          try
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
              'Alter table ' + tablo.Query1.FieldByName('TABLO').AsString +
              ' drop column ' + tablo.Query1.FieldByName('ALANADI').AsString +
              ' ', [], []);
          except
          end;
          ctrl.Visible := False;
          //tablo.AlanOlustur(FindComponent(PanelEkAlanlar.Name),TIKWizardDlg(Self), -1, DtsRehber);
          tablo.AlanOlustur(TIKWizardDlg(Self), -1, Tablo.UserDataSourceHazirla(TIKWizardDlg(Self), DtsRehber, 'REHBER_USER'));
        end;
      end;
    end;
  end;
end;

procedure TIKWizardDlg.FormShow(Sender: TObject);
var
  s: string;
begin
  GridUcretView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\PersonelUcretGridi', true, False, [gsoUseFilter], 'PersonelUcretGridi');
  Tablo.GridAyarRestore('PersonelUcretGridi',GridUcretView );
  GridTemelView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\PersonelOzlukGridi', true, False, [gsoUseFilter], 'PersonelOzlukGridi');
  Tablo.GridAyarRestore('PersonelOzlukGridi',GridTemelView );

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu  := nil;
   end;


  KNo :='';

  //if  then begin // CariOpsiyon  CariKodGirisi
  KodAgaciTus.Visible := (not Potansiyel)and(tablo.GENINI.ReadInteger(Ops_OpsiyonCari_PersKodGirisi, 2) = 2);
  EditKOD.Enabled := (not Potansiyel)and(not KodAgaciTus.Visible);


  if not SubeVarmi then begin
     LblSube.Visible := False;
     ComboSube.Visible := False;
  end;

  if Cagiran >= 0 then begin
      //RehberPerID := -1;
      Tabloyenile(TabRehber,[RehberID]);
      // LAZY: kart dsBrowse ACILIR (Edit KALDIRILDI). Ilk gercek degisiklikte AutoEdit ->
      // TabRehberBeforeEdit -> OturumYakala. Sadece bakma/gezme YAKALAMAZ, konfirmasyon sormaz.


      // Tablo.CariKartInit(ComboDURUM.Properties, ComboGRUP.Properties, ComboSINIF.Properties);
      //ResimGetir(RehberID, 11, RehberID, LogoResim);
  end;

  // Ek alan (REHBER_USER): MEVCUT kartta (ID>0) hemen kur. YENI kartta ID yok -> ek-alan sekmesine
  // gecince personel kaydedilip ID alinca kurulur (CariPageControlPageChanging).
  if CariPageControl <> nil then
     CariPageControl.OnPageChanging := CariPageControlPageChanging;
  if (PanelEkAlanlar <> nil) and (RehberID > 0) then
  begin
     tablo.AlanOlustur(TIKWizardDlg(Self), -1, Tablo.UserDataSourceHazirla(TIKWizardDlg(Self), DtsRehber, 'REHBER_USER'));
     FEkAlanKuruldu := True;
  end;
  // Ek alan olusturulunca SheetEkAlanlar aktiflesiyor -> varsayilan Notlar sekmesine dondur.
  if (CariPageControl <> nil) and (SheetNotlar <> nil) then
     CariPageControl.ActivePage := SheetNotlar;

  GiristekiRehberId:= TabRehber.Fields[0].AsString;

  if Potansiyel then
       TabloNo := TabNo_IK_POTANSIYEL
  else
       TabloNo := TabNo_IK;

  // Geri-alinabilir oturum (yalniz Cagiran=0 + MEVCUT personel; GiristekiRehberId dolu).
  // Acilistaki hali SNAPSHOT'a al -> Cancel'da ilk hale don. IMAJ(blob)+ucret/rol KAPSAM DISI.
  FOturumID := '';
  if (Cagiran = 0) and (RehberID > 0) and (GiristekiRehberId <> '') and (GiristekiRehberId <> '0') then
  begin
    if LogGun > 0 then
      ULog.LogUserAcilis('REHBER_USER', RehberID);
    FOturumID := ULog.OturumBaslatPlan('REHBER', RehberID,   // LAZY: plan bellekte, bakmada SNAPSHOT bos
      [ // --- Ana personel ---
        ULog.SnapTablo(1, 'REHBER',         'ID=' + IntToStr(RehberID)),
        ULog.SnapTablo(1, 'REHBER_USER','ID=' + IntToStr(RehberID)),
        ULog.SnapTablo(2, 'IMAJ',           'YERI=71 and YER_ID=' + IntToStr(RehberID)),   // 71=REHBER: profil resmi (LogoResim/RESIM cache); DOSYA icerigi pin ile korunur
        ULog.SnapTablo(2, 'REHBERILETISIM', 'REHBERID=' + IntToStr(RehberID)),
        ULog.SnapTablo(2, 'REHBERPERSONEL', 'REHBERID=' + IntToStr(RehberID)),
        ULog.SnapTablo(2, 'PERS_HAREKET',   'REHBERID=' + IntToStr(RehberID)),
        ULog.SnapTablo(3, 'REHBERBILGI',    'YERI=1 and YER_ID in (select ID from REHBERILETISIM where REHBERID=' + IntToStr(RehberID) + ')'),
        ULog.SnapTablo(3, 'REHBERBILGI',    'YERI=4 and YER_ID in (select ID from REHBERPERSONEL where REHBERID=' + IntToStr(RehberID) + ')'),
        ULog.SnapTablo(3, 'REHBERBILGI',    'YERI in (2,3) and YER_ID=' + IntToStr(RehberID)),
        // --- Ilgili kisiler (alt REHBER: GRUP=334, BAGID) + kendi iletisim/bilgi ---
        ULog.SnapTablo(6, 'REHBERBILGI',    'YER_ID in (select ID from REHBERILETISIM where REHBERID in (select ID from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + '))'),
        ULog.SnapTablo(5, 'REHBERILETISIM', 'REHBERID in (select ID from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + ')'),
        ULog.SnapTablo(4, 'REHBER',         'GRUP=334 and BAGID=' + IntToStr(RehberID)),
        // --- Not + Yorum (GOREVYORUM: not TUR 11-13, yorum TUR=TabloNo=TabNo_IK) ---
        ULog.SnapTablo(7, 'GOREVYORUM',     'GOREVID=' + IntToStr(RehberID) + ' and (TUR between 11 and 13 or TUR=' + IntToStr(TabloNo) + ')'),
        ULog.SnapTablo(8, 'DOKUMAN', 'MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'GOREVID=' + IntToStr(RehberID) + ' and (TUR between 11 and 13 or TUR=' + IntToStr(TabloNo) + ')' + ')'),
        ULog.SnapTablo(9, 'IMAJ',    'YERI=1 and YER_ID in (select ID from DOKUMAN where MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'GOREVID=' + IntToStr(RehberID) + ' and (TUR between 11 and 13 or TUR=' + IntToStr(TabloNo) + ')' + '))') ]);
  end;

  if (EditKOD.Visible)and(EditKOD.Enabled) then
     EditKOD.SetFocus;


  EkleKurIlet := False;
  EklePerOzluk := False;
  EklePerIlet := False;
  EklePerUcret := False;
  IletisimEkr.Enabled :=  (Cagiran in [0, 1]);
  PersonelOzlukEkr.Enabled := (Cagiran in [0, 3, 34]);
  PersonelIletisimEkr.Enabled := (Cagiran in [0, 4, 34]);
  PersonelUcretEkr.Enabled := (Cagiran in [0, 5]);
  DokumanEkr.Enabled := (Tablo.YetkiVarmi(MODUL_Dokuman,YetkiTur_Gorme)) and (Cagiran in [0, RehAyarYeri_Dokuman]);
  LabelDepartmani.Visible := not Potansiyel;
  EditDepartman.Visible := not Potansiyel;
  LabelGorevi.Visible := not Potansiyel;
  EditGorevi.Visible := not Potansiyel;
  btnUcret.Visible := not Potansiyel;
  DateGIRISTARIHI.Visible := not Potansiyel;
  LabelGIRISTARIHI.Visible := not Potansiyel;


  case Cagiran of
  // 0 Kurum i?in yeni, 1 kurum ileti?im, 2 Personel ?zl?k, 3 Personel ileti?im,  i?in ileti?im bilgileri , 5  Personel Ucret ,
    1:
      IletisimEkr.VisibleButtons := [bkFinish, bkCancel];
    3:
      PersonelOzlukEkr.VisibleButtons := [bkFinish, bkCancel];
    4:
      begin
        PersonelIletisimEkr.VisibleButtons := [bkFinish, bkCancel];
        YeniPerTus.Visible := False;
        SilPerTus.Visible := False;
      end;
    5:
      PersonelUcretEkr.VisibleButtons := [bkFinish, bkCancel];
  end;
  // sayfalardaki zorunlu alanlar?n say?lar?n? hesapl?yal?m..
  //KurIletZorunlu := ZorunluAlanSay(1);
  //PerOzlukZorunlu := ZorunluAlanSay(3);
  //PerIletZorunlu := ZorunluAlanSay(4);
  //PerUcretZorunlu := ZorunluAlanSay(5);

  //if TabRehber.FieldByName('SINIF').AsString <> '' then
  //   ComboGorevi.Properties.items := Tablo.imgComboboxInit( 'SELECT ID,ROL FROM ROLLER WHERE DEPARTMAN = '+TabRehber.FieldByName('SINIF').AsString+' ORDER BY 2 ').items;
  Tabloyenile(TabNotlar,[RehberID]);

  if TabRehber.FieldByName('SINIF').AsString <> '' then begin
     Tablo.TablodanSorguAc(1,'select SUBEID,DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
        ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+') '+
        ' from ROLLER ROL where ROL.ID='+TabRehber.FieldByName('SINIF').AsString);
     EditDepartman.text := Tablo.Query1.Fields[1].AsString;
     EditGorevi.text := Tablo.Query1.Fields[2].AsString;
  end;

  if TabRehber.FieldByName('ID').AsString <> '' then begin
      Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'BILGI from REHBERBILGI where YERI=3 AND YER_ID='+TabRehber.FieldByName('ID').AsString+' AND SIRA=22 '+DbSinir(1));
      if Tablo.Query1.recordcount>0 then
         EditVKNO.Text := Tablo.Query1.Fields[0].AsString;

      Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'TARIH from PERS_HAREKET where REHBERID='+TabRehber.FieldByName('ID').AsString+' and TUR=1 order by 1 desc '+DbSinir(1));
      if Tablo.Query1.recordcount>0 then
         DateGIRISTARIHI.Date :=Tablo.Query1.Fields[0].asdatetime;
      Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'TARIH from PERS_HAREKET where REHBERID='+TabRehber.FieldByName('ID').AsString+' and TUR=99 order by 1 desc '+DbSinir(1));
      if Tablo.Query1.recordcount>0 then
         DateCIKISTARIHI.Date :=Tablo.Query1.Fields[0].asdatetime;

      if TabRehber.FieldByName('BOLGE').AsString<>'' then begin
//         Tablo.TablodanSorguAc(1,'select case when ILCENO<500 then ILADI else ILCEADI end from ILILCE where ILCENO ='+ TabRehber.FieldByName('BOLGE').AsString);
         Tablo.TablodanSorguAc(1,'select ILCEADI, ILADI from ILILCE where ILCENO ='+ TabRehber.FieldByName('BOLGE').AsString);
         EditDYeri.Text := Tablo.Query1.Fields[0].AsString;
         if EditDYeri.Text <> '' then
            EditDYeri.Text := EditDYeri.Text+' / ';
         EditDYeri.Text := EditDYeri.Text+Tablo.Query1.Fields[1].AsString;
      end;
      if TabRehber.FieldByName('ALTBOLGE').AsString<>'' then begin
         Tablo.TablodanSorguAc(1,'select ILADI from ILLER where ILNO ='+ TabRehber.FieldByName('ALTBOLGE').AsString);
         EditUyruk.Text := Tablo.Query1.Fields[0].AsString;
      end;

  end;

  if TabRehber.FieldByName('STATU').Isnull=False then
     ComboCinsiyet.EditValue := Abs(StrToIntDef(BooltoStr(TabRehber.FieldByName('STATU').AsBoolean),1));

  if (RehberID > 0) and (RehberID <> SonEklenenCari) then
    tablo.SKRehberEkle(RehberID);

  if Cagiran > 0 then
    IKWizardDlg.WizardKontrol.SelectNextPage;
end;

procedure TIKWizardDlg.GridIletViewCanFocusRecord
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AAllow := True;
  AnaForm.cxGridPopupMenu1.Grid := GridIlet;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridIletView;
  AnaForm.pmGridStil.Tags.Values[GridIlet.Name] := 'PersonelIletisimGridi';
end;

procedure TIKWizardDlg.GridIletViewEditChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EklePerIlet := true;
end;

procedure TIKWizardDlg.cxGridDBColumn4GetPropertiesForEdit
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

procedure TIKWizardDlg.GridKurIletViewCellClick
  (Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry: TFDQuery;
  ctrls: TGirdiDenetimleri;
  SQL: Variant;
begin
  if ACellViewInfo.Item.Index = 0 then
  begin // t?klanan etiket mi
    Qry := (Sender as TcxGridDBTableView).DataController.DataSource.DataSet as
      TFDQuery;
    if Trim(Qry.FieldByName('KAYNAK').AsString) <> '' then
    begin
      if Pos('select', LowerCase(Qry.FieldByName('KAYNAK').AsString)) > 0 then
      begin
        SQL := Qry.FieldByName('KAYNAK').AsString;
        ctrls := TGirdiDenetimleri.Create.Memo(Qry.FieldByName('ETIKET')
          .AsString, @SQL);
        if TGirisKutusuEx.BilgiAlEx(yenisorgugirin, ctrls) = mrOK then
        begin
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'update REHBERAYAR set KAYNAK=&Sql where ETIKET=&Etiket and GIRIS=&Giris  ',
            ['&Sql', '&Etiket', '&Giris'],
            [SQL, Qry.FieldByName('ETIKET').AsString, Qry.FieldByName('GIRIS')
            .AsInteger]);
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
end;

procedure TIKWizardDlg.GridKurIletViewEditChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleKurIlet := true;
end;

procedure TIKWizardDlg.GridKurIletViewEditValueChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin //
  EkleKurIlet := true;
end;

procedure TIKWizardDlg.GridKurIletViewFocusedItemChanged
  (Sender: TcxCustomGridTableView;
  APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
begin
  //
  EkleKurIlet := true;
end;

procedure TIKWizardDlg.GridKurIletViewInitEdit
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem;
  AEdit: TcxCustomEdit);
begin
  EkleKurIlet := true;
end;

procedure TIKWizardDlg.GridKurIletViewSelectionChanged
  (Sender: TcxCustomGridTableView);
begin //
  EkleKurIlet := true;
end;

procedure TIKWizardDlg.GridKurIletViewStylesGetContentStyle
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

procedure TIKWizardDlg.GridPersonellerViewSelectionChanged
  (Sender: TcxCustomGridTableView);
begin
    if not TabIlgili.Active then exit;

    if TabIlgili.RecordCount > 0 then begin
       if EklePerIlet then // daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
          Ekle(TabPerIlet, 1, RehberPerID, Degis, '', TabloNo, RehberID, 81, TabIlgili.FieldByName('FIRMA').AsString);
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



{
  if TabIlgili.Active then begin
    if TabIlgili.RecordCount > 0 then begin
       if EklePerIlet then // daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
          Ekle(TabPerIlet, 1, RehberPerID, Degis, '', TabloNo, RehberID, 81, TabIlgili.FieldByName('FIRMA').AsString);
       RehberPerID := TabPerIletisim.Fields[0].AsInteger;
       TabPerIlet.Close;
       TabPerIlet.SQL.text := StringReplace(SQLPerIlet.text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
       TabloYenile(TabPerIlet,[1,RehberPerID, RehberPerID]);
       EklePerIlet := False
    end
    else
       GridIlet.Visible := False;
  end    }
end;

procedure TIKWizardDlg.GridTemelViewCanFocusRecord
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridTemel;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridTemelView;
  AnaForm.pmGridStil.Tags.Values[GridTemel.Name] := 'PersonelOzlukGridi';
end;

procedure TIKWizardDlg.GridTemelViewEditChanged(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EklePerOzluk := true;
end;

procedure TIKWizardDlg.GridUcretViewCanFocusRecord
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridUcret;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridUcretView;
  AnaForm.pmGridStil.Tags.Values[GridUcret.Name] := 'PersonelUcretGridi';
end;

procedure TIKWizardDlg.GridUcretViewEditChanged
  (Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EklePerUcret := true;
end;

procedure TIKWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabloNo);
end;

procedure TIKWizardDlg.IletisimEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  // ?leti?im Adres Bilgilerine Default 'Merkez' ekleniyor.
  tablo.TablodanSorguAc(1, 'Select ID from REHBERILETISIM Where REHBERID=' +
    IntToStr(RehberID) + ' ');
  if (Cagiran = 0) and (tablo.Query1.RecordCount = 0) then
  begin //
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
      + IntToStr(RehberID) + ',''Merkez'',1,1,' + IntToStr(SubeID) +
      ')', [], []);
  end;

  TabAdresAd.Close;
  TabAdresAd.SQL.text := 'select * from REHBERILETISIM where REHBERID=' +
    IntToStr(RehberID);
  if RehberIletID > 0 then
  // e?er bir ilgili ?zerinde ?ift t?k yap?p de?i?iklik olacaksa
    TabAdresAd.SQL.Add(' and ID=' + IntToStr(RehberIletID));
  TabAdresAd.SQL.Add(' order by VARSAYILAN  desc');
  TabAdresAd.Open;
  GridKurIlet.Visible := TabAdresAd.RecordCount > 0;
  if (RehberIletID = -1) and (Cagiran = 1) then // yeni tu?una bas?lm?? demektir
    YeniAdresTus.Click;
  if GridKurIlet.Visible then
  begin
    GridAdresAdView.DataController.FocusedRecordIndex := 0;
    GridAdresAdView.ViewData.Records[0].Selected := true;
  end;

end;

procedure TIKWizardDlg.IletisimEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TIKWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint;
  Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TIKWizardDlg.KodAgaciTusClick(Sender: TObject);
var
  s: integer;
begin
   TabRehber.Edit;
   EditKOD.text := tablo.KodBulmaSihirbazi(335, 'HESAPPLANI','HESAPKODU', 'HESAPADI', 'REHBER', 'KOD',335);
end;

procedure TIKWizardDlg.Label6DblClick(Sender: TObject);
var  str:string;
begin
  if StrToInt(cxDBLabel2.Caption) > 0 then begin
     str := cxDBLabel2.Caption+'-'+Sifre(cxDBLabel2.Caption);
     InputQuery('M??teri kodu','M??teri kodu',str);
  end;
end;

procedure TIKWizardDlg.LabelDepartmaniClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Bizim_Departman);
   tablo.GENINI.ReadImageSection(Ops_Bizim_Departman, tablo.RepBizimDepartman.Properties.Items);
end;

procedure TIKWizardDlg.LabelGoreviClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Bizim_Gorev);
   tablo.GENINI.ReadImageSection(Ops_Bizim_Gorev, tablo.RepBizimGorev.Properties.Items);
end;

procedure TIKWizardDlg.ListelerTusClick(Sender: TObject);
var
  Liste : TstringList;
  i : integer;
begin
    Application.CreateForm(TCokluSecimDlg, CokluSecimDlg);
    CokluSecimDlg.Caption := 'Bulunaca?? Listeler';
    CokluSecimDlg.ADOQuery1.SQL.Text := 'select LISTE=ANAHTAR, ID=DEGER from GENINI G where BOLUM = -2250 and DIL=-1 order by SIRA';
    TabloYenile(CokluSecimDlg.ADOQuery1, []);
    //CokluSecimDlg.ADOQuery1.DataController.CreateAllItems;
    CokluSecimDlg.cxGrid1DBTableView1.DataController.CreateAllItems;
    CokluSecimDlg.cxGrid1DBTableView1.ApplyBestFit(nil);

    Tablo.TablodanSorguAc(9, 'select TUR from GOREVKULLANICI where LISTGOREVID=-100 and REHBERID='+TabRehber.Fields[0].AsString+' order by TUR ');
    while not Tablo.Query9.Eof do begin
      if CokluSecimDlg.ADOQuery1.locate('ID', Tablo.Query9.Fields[0].AsInteger, []) then
         CokluSecimDlg.cxGrid1DBTableView1SEC.EditValue := True;
      Tablo.Query9.next;
    end;


    CokluSecimDlg.ShowModal;
    if CokluSecimDlg.ModalResult = mrOk then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GOREVKULLANICI where LISTGOREVID=-100 and REHBERID='+TabRehber.Fields[0].AsString,[],[]);
       CokluSecimDlg.ADOQuery1.First;
       while not CokluSecimDlg.ADOQuery1.Eof do begin
          if CokluSecimDlg.cxGrid1DBTableView1SEC.EditValue = True then
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                   ' values(-100,'+CokluSecimDlg.ADOQuery1.Fields[1].AsString+','+TabRehber.Fields[0].AsString+','+Kullanan+')', [],[]);
          CokluSecimDlg.ADOQuery1.Next;
       end;
    end;



    FreeAndNil(CokluSecimDlg);
  //Liste := TStringlist.Create;
  //Liste := Tablo.ListedenCokluSecim('','select LISTE=ANAHTAR, ID=DEGER from GENINI G where BOLUM = -2250 and DIL=-1 order by SIRA',[nil,nil,nil,nil,nil,nil,nil],
  //                                           ['Liste','Id']);
  {if Liste.Count>0 then begin
     for I := 0 to Liste.Count - 1 do begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
           ' values('+IntToStr(ListeId)+',2,'+copy(Liste[i],2,8)+','+Kullanan+')', [],[]);
     end;
     Tabloyenile(TabKullanici,[ListeId]);
  end; }
  //Liste.Free;
end;

procedure TIKWizardDlg.MaasTarihPropertiesChange(Sender: TObject);
var
  tar: TDateTime;
begin

  {
    if WizardKontrol.ActivePage = PersonelUcretEkr then begin
    tar := StrToDate(MaasGunu.Text+'/'+IntToStr(ComboAylar.ItemIndex+1)+'/'+IntToStr(CurrentYear));
    TabPerUcret.First;
    while not TabPerUcret.eof do begin
    TabPerUcret.Edit;
    TabPerUcret.FieldByName('TARIH').AsDateTime := tar;
    TabPerUcret.Post;
    TabPerUcret.Next;
    end;
    end;
    MaasTarih }
end;

procedure TIKWizardDlg.MaasTarihPropertiesEditValueChanged(Sender: TObject);
begin
  if WizardKontrol.ActivePage = PersonelUcretEkr then
     EklePerUcret := true;
end;

procedure TIKWizardDlg.MenuItem7Click(Sender: TObject);
begin
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'Update REHBERILETISIM Set VARSAYILAN=0 Where AKTIF=1 and REHBERID=&RehID',
    ['&RehID'], [TabRehber.FieldByName('ID').AsInteger]);
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'Update REHBERILETISIM Set VARSAYILAN=1 Where AKTIF=1 and REHBERID=&RehID and ID=&IletID',
    ['&RehID', '&IletID'], [TabRehber.FieldByName('ID').AsInteger,
    TabAdresAd.FieldByName('ID').AsInteger]);
  TabAdresAd.Close;
  TabAdresAd.SQL.text := 'select * from REHBERILETISIM where REHBERID=' +TabRehber.Fields[0].AsString;
  TabAdresAd.SQL.Add(' order by VARSAYILAN  desc');
  TabAdresAd.Open;
  GridAdresAdViewSelectionChanged(nil);
end;

procedure TIKWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 ULog.OturumYakala(FOturumID);   // LAZY: klasorden dosya ekleme -> yakala
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TIKWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: tarayicidan dosya ekleme -> yakala
    Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TIKWizardDlg.PersonelIletisimEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  if not TabIlgili.Active then begin
      TabIlgili.Close;
      TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID);
      if RehberPerID > 0 then // e?er bir ilgili ?zerinde ?ift t?k yap?p de?i?iklik olacaksa
         TabIlgili.SQL.Add(' and ID=' + IntToStr(RehberPerID));
      TabIlgili.SQL.Add(' order by STATU desc');
//      TabIlgili.Open;
      TabloYenile(TabIlgili,[]);
      if TabIlgili.RecordCount > 0 then
        TabloYenile(TabPerIlet,[1, TabIlgili.Fields[0].AsInteger])
      else
        TabloYenile(TabPerIlet,[1, 0]);
      GridIlet.Visible := TabIlgili.RecordCount > 0;
      if (RehberPerID = -1) and (Cagiran = 4) then
      // yeni tu?una bas?lm?? demektir
         YeniPerTus.Click;
      if GridIlet.Visible then begin
         GridPersonellerView.DataController.FocusedRecordIndex := 0;
         GridPersonellerView.ViewData.Records[0].Selected := true;
      end;
  end;
end;

procedure TIKWizardDlg.PersonelIletisimEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TIKWizardDlg.PersonelOzlukEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  if not TabPerOzluk.Active then
  begin
    TabPerOzluk.Close;
    TabPerOzluk.SQL.text := StringReplace(SQLTemel.text, ':SPID',
      IntToStr(SPID), [rfReplaceAll]);
    //TabPerOzluk.Params[0].Value := 3;
    //TabPerOzluk.Params[1].Value := RehberID;
    //TabPerOzluk.Params[2].Value := RehberID;
//    TabPerOzluk.Open;
    Tabloyenile(TabPerOzluk,[3,RehberID,RehberID]);
  end;
end;

procedure TIKWizardDlg.PersonelOzlukEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TIKWizardDlg.PersonelUcretEkrEnterPage(Sender: TObject;const FromPage: TJvWizardCustomPage);
begin
  if not TabPerUcret.Active then
  begin
    TabPerUcret.Close;
    TabPerUcret.SQL.text := StringReplace(SQLPerUcret.text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
//    TabPerUcret.ParamByName('RID1').Value := RehberID;
//    TabPerUcret.ParamByName('RID2').Value := RehberID;
//    TabPerUcret.Open;
    Tabloyenile(TabPerUcret,[RehberID,RehberID]);

    // Kur Kontrolu
    TabPerUcret.first;
    while not TabPerUcret.Eof do
    begin
      if Trim(TabPerUcret.FieldByName('KUR').AsString) = '' then
      begin
//        TabPerUcret.Edit;
//        TabPerUcret.FieldByName('KUR').AsString := CariDoviz;
//        TabPerUcret.Post;
      end;
      TabPerUcret.Next;
    end;
  end
end;

procedure TIKWizardDlg.PersonelUcretEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TIKWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum silme -> yakala
   Tablo.GridYorumuSil(TabloNo, tabrehber.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TIKWizardDlg.YeniAdresTusClick(Sender: TObject);
var
  EtiAdi: Variant;
begin
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
    TGirdiDenetimleri.Create.Edit(IletisimAdiniGirin, @EtiAdi)) = mrOK then
  begin
    // if EklePerIlet then //daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
    // Ekle(TabPerIlet,4,RehberPerID,'De?i?');

    TabAdresAd.Append;
    TabAdresAd.FieldByName('AD').AsString := Trim(EtiAdi);
    TabAdresAd.FieldByName('VARSAYILAN').AsBoolean :=
      TabAdresAd.RecordCount < 1;
    TabAdresAd.Post;
    tablo.TablodanSorguAc(1,
      'Select '+DbUst(1)+'* from REHBERILETISIM where REHBERID=' +
      IntToStr(RehberID)+' '+DbSinir(1));

    if tablo.Query1.RecordCount < 1 then
      PersonelVarsayilanYap(RehberID, TabAdresAd.FieldByName('ID').AsInteger);

    TabAdresAd.Close;
    TabAdresAd.SQL.text := 'select * from REHBERILETISIM where REHBERID=' +
      IntToStr(RehberID);
    TabAdresAd.SQL.Add
      (' and ID in (Select MAX(ID) from REHBERILETISIM where REHBERID=' +
      IntToStr(RehberID) + ' )');
    TabAdresAd.Open;

    GridKurIlet.Visible := true;
    GridAdresAdViewSelectionChanged(nil);
  end
  else
    WizardKontrolCancelButtonClick(Sender);
end;

procedure TIKWizardDlg.YeniPerTusClick(Sender: TObject);
var
  EtiAdi: Variant;
begin
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Edit(ilgiliAdiniGirin, @EtiAdi)) = mrOK then begin
    // if EklePerIlet then //daha ?nce giri? yap?ld?ysa ?nce onu kaydedelim
    // Ekle(TabPerIlet,4,RehberPerID,'De?i?');

    TabIlgili.Append;
    TabIlgili.FieldByName('FIRMA').AsString := Trim(EtiAdi);
    TabIlgili.FieldByName('STATU').AsBoolean := TabIlgili.RecordCount < 1;
    TabIlgili.Post;


{    tablo.TablodanSorguAc(1, 'Select * from REHBERPERSONEL where REHBERID='+IntToStr(RehberID));
    if tablo.Query1.RecordCount < 1 then
       PersonelVarsayilanYap(RehberID, TabIlgili.FieldByName('ID').AsInteger);

    TabIlgili.Close;
    TabIlgili.SQL.text := 'select * from REHBERPERSONEL where REHBERID=' +IntToStr(RehberID);
    TabIlgili.SQL.Add(' and ID in (Select MAX(ID) from REHBERPERSONEL where REHBERID='+IntToStr(RehberID) + ' )');
    //TabIlgili.Open;
    Tabloyenile(TabIlgili,[]);    }

    // Sonra Rehber ?leti?im tablosuna  'Merkez' ekleniyor.
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
      + TabIlgili.FieldByName('ID').AsString  + ',''Merkez'',1,1,' + IntToStr(SubeID) + ')', [], []);
    TabloYenile(TabPerIletisim, [TabIlgili.FieldByName('ID').AsInteger]);

    tablo.TablodanSorguAc(1, 'Select * from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID));
    if tablo.Query1.RecordCount < 1 then
      PersonelVarsayilanYap(RehberID, TabIlgili.FieldByName('ID').AsInteger);

    TabIlgili.Close;
    TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' +IntToStr(RehberID);
    TabIlgili.SQL.Add(' and ID in (Select MAX(ID) from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + ' )');
    TabloYenile(TabIlgili,[]);

    GridIlet.Visible := true;
    GridPersonellerViewSelectionChanged(nil);
  end
  else
    close;
end;

procedure TIKWizardDlg.YorumDuzenleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: not duzenleme -> yakala
   if not YorumDuzenle.Visible then exit;
   YorumDuzenleIslemi(TabNotlar, TabRehber.Fields[0].AsInteger);
end;

procedure TIKWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya duzenleme -> yakala
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
end;

procedure TIKWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
  DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString <> '';
  DokumanFormunuA1.Visible := DkmanGster1.Visible;
  DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TIKWizardDlg.YorumEkleTusClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: not/yorum ekleme -> yakala
   if TabRehber.State in [dsEdit, dsInsert] then begin
      TabRehber.Post;
      RehberID := TabRehber.Fields[0].AsInteger;
   end;

   YorumEkleIslemi(TabRehber,TabNotlar, TabRehber.Fields[0].AsInteger);
end;

procedure TIKWizardDlg.YorumSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: not/yorum silme -> yakala
   YorumSilIslemi(TabNotlar, TabNotlar.Fields[0].AsInteger);
end;

procedure TIKWizardDlg.SilPerTusClick(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: personel/ilgili silme -> yakala
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO)= IDYES then begin
      CariIlgiliSil(TabRehber.Fields[0].AsInteger, TabIlgili.Fields[0].AsInteger,TabIlgili.FieldByName('STATU').AsBoolean);
      TabIlgili.Close;
      TabIlgili.SQL.text := 'select * from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberID) + ' order by STATU desc';
  //    TabIlgili.Open;
      TabloYenile(TabIlgili,[]);
      GridPersonellerViewSelectionChanged(nil);
  end;
end;

procedure TIKWizardDlg.TabDokumanBeforeOpen(DataSet: TDataSet);
begin
  if Strtoint(ROLID) <> -1 then
     TabDokuman.SQL.Add(' AND GOR=1  AND (REHID = ' + Kullanan +' OR REHID=0)  ');
end;

procedure TIKWizardDlg.TabIlgiliAfterScroll(DataSet: TDataSet);
begin
   TabloYenile(TabPerIletisim, [TabIlgili.FieldByName('ID').AsInteger]);
end;

procedure TIKWizardDlg.TabIlgiliBeforePost(DataSet: TDataSet);
begin
  TabIlgili.FieldByName('DEGISTIREN').AsString := Kullanan;
  TabIlgili.FieldByName('DEGISTIRMETARIHI').AsDateTime := tablo.GENINI.BugunTrh;
end;

procedure TIKWizardDlg.TabIlgiliNewRecord(DataSet: TDataSet);
begin
  TabIlgili.FieldByName('GRUP').AsInteger := 334;
  TabIlgili.FieldByName('BAGID').AsInteger := RehberID;
  TabIlgili.FieldByName('EKLEYEN').AsString := Kullanan;
  TabIlgili.FieldByName('DURUM').Asinteger := 1;
  TabIlgili.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TIKWizardDlg.TabKurIletAfterPost(DataSet: TDataSet);
Var
  Sayfa: TJvWizardCustomPage;
begin
  // zorunlu alanlar? kontrol et!!
  { Sayfa := WizardKontrol.ActivePage;
    //o sayfadaki zorunlu alanlar dolmu?sa next tu?unu aktifle?tirebiliriz.
    if Sayfa = IletisimEkr then begin
    IletisimEkr.EnableButton(bkNext, BosZorunluAlanSay(DtsKurIlet,'BILGI')=0 );
    end else if Sayfa = TicariEkr then begin
    TicariEkr.EnableButton(bkNext, BosZorunluAlanSay(DtsTicari,'BILGI')=0 );
    end else if Sayfa = PersonelOzlukEkr then begin
    PersonelOzlukEkr.EnableButton(bkNext, BosZorunluAlanSay(DtsPerOzluk,'BILGI')=0 );
    end else if Sayfa = PersonelIletisimEkr then begin
    PersonelIletisimEkr.EnableButton(bkFinish, BosZorunluAlanSay(DtsPerIlet,'BILGI')=0 );
    end else if Sayfa = PersonelUcretEkr then begin
    PersonelUcretEkr.EnableButton(bkFinish, BosZorunluAlanSay(DtsPerUcret,'TUTAR')=0 );
    end; }
end;

procedure TIKWizardDlg.TabKurIletNewRecord(DataSet: TDataSet);
begin
  TabKurIlet.FieldByName('SIRA').AsInteger := 99;
  TabKurIlet.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TIKWizardDlg.TabPerIletNewRecord(DataSet: TDataSet);
begin
  TabPerIlet.FieldByName('SIRA').AsInteger := 99;
  TabPerIlet.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TIKWizardDlg.TabPerOzlukNewRecord(DataSet: TDataSet);
begin
  TabPerOzluk.FieldByName('SIRA').AsInteger := 99;
  TabPerOzluk.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TIKWizardDlg.TabPerUcretNewRecord(DataSet: TDataSet);
begin
  TabPerUcret.FieldByName('SIRA').AsInteger := 99;
  TabPerUcret.FieldByName('KUR').AsString :=
    (GridUcretViewKur.Properties as TcxComboBoxProperties).Items[0];
  TabPerUcret.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TIKWizardDlg.TabRehberAfterPost(DataSet: TDataSet);
begin
  if YeniEklenenKayit then begin
    if KNo<>'' then //Kimlik no varsa kaydedelim
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO REHBERBILGI([YERI],[YER_ID],[SIRA],[ETIKET],[BILGI],EKLEYEN, '+
       ' SUBEID) SELECT YERI=2,YER_ID='+TabRehber.Fields[0].AsString+',SIRA,ETIKET,BILGI='''+KNo+''', EKLEYEN='+Kullanan+
       ', SUBEID='+IntToStr(SubeId)+' FROM REHBERAYAR RA inner join REHBERVARSAYILAN RV on RA.VARSAYILAN=RV.NO and RV.NO=22 ',[], []);
  end
  else
  if TabRehber.FieldByName('SINIF').AsInteger<>OncekiSinif then
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update KULLANICI set ROLID=&snf '+
       ' where REHBERID='+TabRehber.Fields[0].AsString,['&snf'],[TabRehber.FieldByName('SINIF').AsInteger]);


  YeniEklenenKayit := False;
  // NOT: KART (master REHBER) loglamasi buradan KALDIRILDI. AfterPost sayfa
  // gecislerinde birden cok kez atesleniyor -> mukerrer log uretiyordu. Kart
  // loglamasi Finish'te (WizardKontrolFinishButtonClick) TEK SEFER yapilir.
  // Detay (DetayAfterPost) loglamasina dokunulmadi.
end;

// IK detay iletisim (REHBERILETISIM) icin ORTAK log. ust=(REHBER, personel ID).
procedure TIKWizardDlg.DetayBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: detay degisikligi -> yakala
  if LogGun > 0 then Tablo.OncekiLogBelirle(TFDQuery(DataSet));
end;

procedure TIKWizardDlg.DetayAfterPost(DataSet: TDataSet);
begin
  if LogGun <= 0 then Exit;
  if DataSet <> TabPerIletisim then Exit;
  // Detay ISLEMTIPI'si ANA KARTIN modunu izlesin: yeni personel -> ekle(1), mevcut -> degis(2)
  // -> kart+detaylar tek ISLEMTIPI'de gruplanir (UInfo'da tek satir).
  if YeniKayit then LogUstModu := 1 else LogUstModu := 2;
  // ust=IK (73/74)
  LogDetaySatirPost(DataSet, TabNo_REHBERILETISIM, TabloNo, TabRehber.FieldByName('ID').AsInteger);
end;

procedure TIKWizardDlg.TabRehberAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabSonAktivite, [TabRehber.FieldByName('ID').AsInteger]);
end;

procedure TIKWizardDlg.TabRehberBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: ilk gercek alan degisikliginde yakala
  OncekiTCNo := EditVKNO.Text;
  OncekiGirisTarih := DateGIRISTARIHI.Text;
  OncekiCikisTarih := DateCIKISTARIHI.Text;
  OncekiSinif := TabRehber.FieldByName('SINIF').AsInteger;
  if LogGun > 0 then begin
    tablo.OncekiLogBelirle(TabRehber);
    FKartSnap.Assign(LogOnceki);   // detay logu LogOnceki'yi temizlese de kart diff'i icin sakla
    FKartSnapID := TabRehber.FieldByName('ID').AsInteger;
    // Kart snapshot'i FKartSnap'e alindi -> global LogOnceki'yi bosalt. Yoksa duzenleme
    // sirasinda EKLENEN yeni detay (personel iletisim) LogDetaySatirPost'ta LogOnceki
    // dolu gorunup 'degisiklik' sanilir ve kart snapshot'ina karsi pozisyonel diff'lenir
    // (cop diff). Kart diff'i Finish'te FKartSnap'ten geri yuklenir.
    LogOnceki.Clear;
  end;
end;

procedure TIKWizardDlg.TabRehberBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: ana kart post -> yakala
  BoslukKontrolu;
  TabRehber.FieldByName('DEGISTIREN').AsString := Kullanan;
  TabRehber.FieldByName('DEGISTIRMETARIHI').AsDateTime := tablo.GENINI.BugunTrh;

  if ComboCinsiyet.EditValue=-1 then
     TabRehber.FieldByName('STATU').Value := null
  else
     TabRehber.FieldByName('STATU').AsBoolean := ComboCinsiyet.EditValue=1;
end;

procedure TIKWizardDlg.TabAdresAdNewRecord(DataSet: TDataSet);
begin
  TabAdresAd.FieldByName('REHBERID').AsInteger := RehberID;
  TabAdresAd.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TIKWizardDlg.TabRehberNewRecord(DataSet: TDataSet);
begin
  TabRehber.FieldByName('DURUM').AsInteger := 1;
  TabRehber.FieldByName('PERYOT').AsInteger := 0;
  TabRehber.FieldByName('STATU').Value := null;
  TabRehber.FieldByName('KOD').AsString := '';
  if Potansiyel then
     TabRehber.FieldByName('GRUP').AsInteger := 5
  else
     TabRehber.FieldByName('GRUP').AsInteger := 335;



  TabRehber.FieldByName('EKLEYEN').AsString := Kullanan;

  {if SubeVarmi then
  begin
    case tablo.GENINI.ReadInteger(Ops_OpsiyonCari_GorunecekSubeler, 0) of
      0:
        ComboSube.RepositoryItem := tablo.RepSubelerOrtak;
      1:
        ComboSube.RepositoryItem := tablo.RepSubelerKendiSubesi;
      2:
        ComboSube.RepositoryItem := tablo.RepSubelerOrtakKendiSubesi;
      3:
        ComboSube.RepositoryItem := tablo.RepSubelerOrtakTumSubeler;
    end;

    case tablo.GENINI.ReadInteger(Ops_OpsiyonCari_GorunecekSubeler, 0) of
      0, 2, 3:
        TabRehber.FieldByName('SUBEID').AsInteger := 0;
      1:
        TabRehber.FieldByName('SUBEID').AsInteger := SubeID;
    end
  end
  else
    TabRehber.FieldByName('SUBEID').AsInteger := -1;}
  TabRehber.FieldByName('SUBEID').AsInteger := SubeID;
  YeniEklenenKayit := true;
  YeniKayit := true;
end;

function TIKWizardDlg.BosZorunluAlanSay(DTS: TDataSource;
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

procedure TIKWizardDlg.btnCariKartClick(Sender: TObject);
begin
  if TabRehber.State in [dsEdit, dsInsert] then begin
    TabRehber.Post;
    RehberID := TabRehber.Fields[0].AsInteger;
  end;
  WizardKontrol.ActivePageIndex := (Sender as TcxButton).Tag;
end;

procedure TIKWizardDlg.BtnGoogleClick(Sender: TObject);
begin
   Application.CreateForm(TGoogleSifreDlg, GoogleSifreDlg);
   GoogleSifreDlg.RehberID := RehberID;
   GoogleSifreDlg.showmodal;
   GoogleSifreDlg.destroy;
end;

procedure TIKWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya mesaj/dosya ekleme -> yakala
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabloNo, TabRehber.FieldByName('ID').AsInteger,TabRehber.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TIKWizardDlg.ButtonDuzenle;
begin
  if Cagiran = 0 then begin
    btnCariKart.Enabled := btnCariKart.Tag <> WizardKontrol.ActivePageIndex;
    Btniletisim.Enabled := Btniletisim.Tag <> WizardKontrol.ActivePageIndex;
    BtnKisiBilgiFormu.Enabled := BtnKisiBilgiFormu.Tag <> WizardKontrol.ActivePageIndex;
    BtnDokuman.Enabled := BtnDokuman.Tag <> WizardKontrol.ActivePageIndex;
    BtnOzluk.Enabled := BtnOzluk.Tag <> WizardKontrol.ActivePageIndex;
    btnUcret.Enabled := btnUcret.Tag <> WizardKontrol.ActivePageIndex;
  end else begin
    btnCariKart.Enabled := False;
    Btniletisim.Enabled := False;
    BtnKisiBilgiFormu.Enabled := False;
    BtnDokuman.Enabled := False;
    BtnOzluk.Enabled := False;
    btnUcret.Enabled := False;
  end;

end;

procedure TIKWizardDlg.VarsayPerTusClick(Sender: TObject);
begin
  PersonelVarsayilanYap(RehberID, RehberPerID);
  // TabloYenile(TabIlgili,[RehberID]);
end;

procedure TIKWizardDlg.DegisPerTusClick(Sender: TObject);
var
  EtiAdi: Variant;
begin
//  EtiAdi := TabIlgili.FieldByName('ADSOYAD').AsString;
  EtiAdi := TabIlgili.FieldByName('FIRMA').AsString;
  if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi,
    TGirdiDenetimleri.Create.Edit(ilgiliAdiniGirin, @EtiAdi)) = mrOK then
  begin
    TabIlgili.Edit;
    TabIlgili.FieldByName('FIRMA').AsString := Trim(EtiAdi);
    TabIlgili.Post;
  end;

end;

procedure TIKWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TIKWizardDlg.DkmanSil1Click(Sender: TObject);
begin
    ULog.OturumYakala(FOturumID);   // LAZY: dokuman silme -> yakala
if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabloNo,TabRehber.FieldByName('ID').AsInteger]);
  end;
end;

procedure TIKWizardDlg.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[TabloNo, TabRehber.FieldByName('ID').AsInteger]);
end;

procedure TIKWizardDlg.DokumanEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TIKWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
            TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabRehber.FieldByName('ID').AsInteger)
end;

procedure TIKWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  // Iptal onayi (Gentegre Onay): Evet=Kaydet(finish), Hayir=Kaydetme(asagi/geri-al), Iptal=Geri Don.
  // LAZY: konfirmasyon SADECE gercek degisiklik varsa (yakalandi VEYA post-edilmemis buffer degisikligi).
  if (((Cagiran=0)and(TabRehber.Fields[0].AsString<>'')and(TabRehber.Fields[0].AsString<>GiristekiRehberId))
      or ULog.OturumYakalandiMi(FOturumID)
      or ((TabRehber.State in [dsEdit, dsInsert]) and TabRehber.Modified)) then
    case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
      IDYES:    begin ModalResult := mrNone; WizardKontrolFinishButtonClick(Self); Exit; end;  // Kaydet
      IDCANCEL: begin ModalResult := mrNone; Exit; end;                                         // Geri Don
      // IDNO: Kaydetme -> asagi devam (mevcut iptal/geri-al mantigi calisir)
    end;
  if (Ust = 2) and (DtsPers.DataSet.State in [dsEdit, dsInsert]) then
      DtsPers.DataSet.Cancel;

  if (Cagiran=0)and(TabRehber.Fields[0].AsInteger>0)and(TabRehber.Fields[0].AsString<>GiristekiRehberId) then begin//?ptal edildi ama kay?t olmu?. ID>0: -1/0 placeholder'da REHBERID=-1 mesru kayitlari SILME
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERBILGI WHERE EXISTS (SELECT * FROM REHBERILETISIM RI WHERE RI.ID=REHBERBILGI.YER_ID AND RI.REHBERID='+TabRehber.Fields[0].AsString+' AND YERI=1 )',[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERILETISIM where REHBERID = '+TabRehber.Fields[0].AsString,[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERBILGI WHERE EXISTS (SELECT * FROM REHBERPERSONEL RP WHERE RP.ID=REHBERBILGI.YER_ID AND RP.REHBERID='+TabRehber.Fields[0].AsString+' AND YERI=4 )',[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBER_USER WHERE ID in (SELECT ID FROM REHBER where GRUP=334 and BAGID = '+TabRehber.Fields[0].AsString+')',[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBER where GRUP=334 and BAGID = '+TabRehber.Fields[0].AsString,[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBERBILGI WHERE YERI in (2,3) and YER_ID ='+TabRehber.Fields[0].AsString,[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM IMAJ WHERE REHBERID='+TabRehber.Fields[0].AsString,[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBER_USER WHERE ID='+TabRehber.Fields[0].AsString,[],[]);
     // Personel'e bagli FATBASLIK (ucret/tahakkuk) + FATURA satirlari -> REHBER silinmeden once (FK).
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM FATURA WHERE FATBASID IN (SELECT ID FROM FATBASLIK WHERE REHBERID='+TabRehber.Fields[0].AsString+')',[],[]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM FATBASLIK WHERE REHBERID='+TabRehber.Fields[0].AsString,[],[]);
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM REHBER WHERE ID='+TabRehber.Fields[0].AsString,[],[]);
  end
  else if FOturumID <> '' then
  begin
      // DUZENLEME iptali -> ilk hale don (snapshot geri yukle). Bekleyen edit'i iptal et.
      if TabRehber.State in [dsEdit, dsInsert] then TabRehber.Cancel;
      var LDegisti := ULog.OturumYakalandiMi(FOturumID);   // geri-yukleme ONCE (OturumGeriAl temizler)
      ULog.OturumGeriAl(FOturumID);   // LAZY: yakalanmadiysa no-op (sadece plan temizlenir)
      if LDegisti then VarsayilanResimTazele(71, RehberID); // RESIM cache'i yalniz degisiklik olduysa tazele
      FOturumID := '';
  end;
  Close;
end;

procedure TIKWizardDlg.GirisEkrNextButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
  if TabRehber.State in [dsEdit, dsInsert] then
  begin
    TabRehber.Post;
    RehberID := TabRehber.Fields[0].AsInteger;
  end;
  if not BtnOzluk.Visible then
  begin
    PersonelOzlukEkr.Enabled := False;
    PersonelUcretEkr.Enabled := False;
  end
  else
  begin
    PersonelOzlukEkr.Enabled := true;
    PersonelUcretEkr.Enabled := true;
  end;
end;

procedure TIKWizardDlg.GirisEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TIKWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
  GenotipaEkle: Boolean;
  Durum, UpdateOldu: SmallInt;
  KartIslemi: SmallInt;   // 0=degisiklik yok, 1=yeni kart, 2=edit -> Finish'te TEK log
  procedure UcretEkle(Table1: TFDQuery);
  var
    Bilgi, orj: string;
    i, hangiay, sonHangiAy: SmallInt;
    tar, Tarih: TDateTime;
    procedure Yaz;
    begin
      Table1.first;
      while not Table1.Eof do
      begin
        Bilgi := Trim(Table1.FieldByName('TUTAR').AsString);
        if Table1.FieldByName('ORJINALTUTAR').DataType = ftCurrency then
          orj := FCurrToStr(Table1.FieldByName('ORJINALTUTAR').AsCurrency)
        else
          orj := Trim(Table1.FieldByName('ORJINALTUTAR').AsString);
        if (Bilgi <> orj) or
          ((Bilgi <> '') and (Trim(Table1.FieldByName('KUR').AsString) <>
          Trim(Table1.FieldByName('ORJINALKUR').AsString))) then
        begin
          tablo.Query1.Close;
          if (orj = '') and (Bilgi <> '') then
            tablo.Query1.SQL.text :=
              ' insert into PLANMAAS (YER,YERID,SIRA,ETIKET,TUTAR,KUR,EKLEYEN,SUBEID) values (0,'
              + IntToStr(RehberID) + ',' + Table1.FieldByName('SIRA').AsString + ','''
              + Table1.FieldByName('ETIKET').AsString + ''',' +
              FCurrToStr(Table1.FieldByName('TUTAR').AsCurrency) + ',''' +
              Table1.FieldByName('KUR').AsString + ''',''' + Kullanan + ''',' +
              IntToStr(SubeID) + ')'
          else if (orj <> '') and (Bilgi = '') then
            tablo.Query1.SQL.text := ' delete from PLANMAAS where YER=0 AND YERID=' +IntToStr(RehberID) +
            ' and SIRA=' + Table1.FieldByName('SIRA').AsString + ' and ETIKET=''' +Table1.FieldByName('ETIKET').AsString + ''''
          else if (orj <> '') and (Bilgi <> '') then
          begin
            tablo.Query5.Close;
            tablo.Query5.SQL.text :=
              'Select * from PLANMAAS  where YER=0 and YERID =:A0 and SIRA=:A2';
            tablo.Query5.Params[0].Value := RehberID;
            tablo.Query5.Params[1].Value := Table1.FieldByName('SIRA').AsString;
            tablo.Query5.Open;
            if tablo.Query5.RecordCount < 1 then
              tablo.Query1.SQL.text :=
                ' insert into PLANMAAS (YER,YERID,SIRA,ETIKET,TUTAR,KUR,EKLEYEN,SUBEID) values (0,'
                + IntToStr(RehberID) + ',' + Table1.FieldByName('SIRA').AsString +
                ',''' + Table1.FieldByName('ETIKET').AsString + ''',' +
                FCurrToStr(Table1.FieldByName('TUTAR').AsCurrency) + ',''' +
                Table1.FieldByName('KUR').AsString + ''',''' + Kullanan + ''','
                + IntToStr(SubeID) + ')'
            else
            begin
              tablo.Query1.SQL.text := ' update PLANMAAS set TUTAR=' +
                FCurrToStr(Table1.FieldByName('TUTAR').AsCurrency) + ',KUR=''' +
                Table1.FieldByName('KUR').AsString + ''', DEGISTIREN=''' +
                Kullanan + '''' + ' where YER=0 and YERID=' + IntToStr(RehberID) +
                ' and SIRA=' + Table1.FieldByName('SIRA').AsString +
                ' and ETIKET=''' + Table1.FieldByName('ETIKET').AsString + '''';
              UpdateOldu := 1;
            end;
          end;
          tablo.Query1.ExecSQL;
        end;
        Table1.Next;
      end;
    end;

  begin
    if Table1.State in [dsEdit, dsInsert] then
      Table1.Post;
    Table1.first;
    UpdateOldu := 0;
    // 0 ise ilk giri? de?eri,UpdateOldu=1 ise var olan kay?t de?i?ti,UpdateOldu=2 ise hi? olmayan yeni kay?t eklendi.
    tablo.TablodanSorguAc(5, 'Select * from PLANMAAS  where YER=0 and YERID ='+IntToStr(RehberID) );
    if tablo.Query5.RecordCount > 1 then
      UpdateOldu := 2;
    Yaz;
  
  end;

begin
  GenotipaEkle := False;
  KartIslemi := 0;
  // Finish'te alt hareketler (Ekle -> iletisim/ilgili) ana kartin moduna gore loglansin
  // -> kart+detaylar tek ISLEMTIPI (UInfo'da tek satir). LogYaz override eder.
  if YeniKayit then LogUstModu := 1 else LogUstModu := 2;

  case Cagiran of
  // 0 Kurum i?in yeni, 1 kurum ileti?im,  3 Personel ?zl?k, 4 Personel ileti?im, i?in ileti?im bilgileri
    0:
      begin
        if TabRehber.State in [dsInsert] then
        begin
          BoslukKontrolu;
          TabRehber.Post;
          RehberID := TabRehber.Fields[0].AsInteger;
          GenotipaEkle := true;
          KartIslemi := 1;   // yeni kart -> LogKayitEkle
        end
        else if TabRehber.State in [dsEdit] then
        begin
          BoslukKontrolu;
          // Gercek degisiklik yoksa Post etme: DEGISTIREN/DEGISTIRMETARIHI
          // guncellenmesin, gereksiz "degisiklik" logu uretilmesin.
          // NOT: Yeni kart cogu zaman dsEdit ile Finish'e gelir -> onu
          // kaybetmemek icin YeniKayit=true iken her zaman Post et.
          if YeniKayit or TabRehber.Modified then
          begin
            TabRehber.Post;
            KartIslemi := 2;   // edit -> LogIslemleri (OncekiLog snapshot ile)
          end
          else
            TabRehber.Cancel;   // degisiklik yok -> KartIslemi=0 kalir, log yazilmaz
          RehberID := TabRehber.Fields[0].AsInteger;
        end
        else if TabRehber.State in [dsBrowse] then
        if EkleKurIlet then
        begin
           Ekle(TabKurIlet, 1, RehberIletID, Degis, '', TabloNo, RehberID, 75); // KurumIletisimEkle;
        end;
        if EklePerOzluk then
           Ekle(TabPerOzluk, 3, RehberID, Degis, '', TabloNo, RehberID, 86);
        if EklePerIlet then
           Ekle(TabPerIlet, 1, RehberPerID, Degis, '', TabloNo, RehberID, 81, TabIlgili.FieldByName('FIRMA').AsString);
        if EklePerUcret then
           UcretEkle(TabPerUcret); // Personel ?cret Ekle;
        // ?leti?im Adres Bilgilerine Default 'Ana' ekleniyor.
        tablo.TablodanSorguAc(1, 'Select ID from REHBERILETISIM Where REHBERID='+ IntToStr(RehberID) + ' ');
        if (tablo.Query1.RecordCount = 0) then begin
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
            + IntToStr(RehberID) + ',''Merkez'',1,1,' + IntToStr(SubeID) +')', [], []);
        end;     //  OncekiCikisTarih
        if OncekiTCNo <> EditVKNO.Text then begin
           if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from REHBERBILGI where YERI=3 AND YER_ID='+TabRehber.FieldByName('ID').AsString+' AND SIRA=22',[],[]) then
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERBILGI set BILGI='''+EditVKNO.Text +''' where YERI=3 AND YER_ID='+TabRehber.FieldByName('ID').AsString+' AND SIRA=22',[],[])
           else
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [REHBERBILGI] (YERI,YER_ID,SIRA,ETIKET,BILGI)values(3,'+TabRehber.FieldByName('ID').AsString+',22,''T.C.Kmlik No'','''+EditVKNO.Text +''')',[],[]);
        end;
        if OncekiGirisTarih<>DateGIRISTARIHI.text then begin
           if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from PERS_HAREKET where REHBERID = '+TabRehber.FieldByName('ID').AsString+' and TUR = 1 ',[],[]) then
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PERS_HAREKET set TARIH='''+FormatDateTime('yyyy-mm-dd', DateGIRISTARIHI.Date)+''' where REHBERID = '+TabRehber.FieldByName('ID').AsString+' and TUR = 1',[],[])
           else
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [PERS_HAREKET] (REHBERID,TARIH,TUR,ACIKLAMA)values(&REHBERID,'''+FormatDateTime('yyyy-mm-dd', DateGIRISTARIHI.Date)+''' ,&TUR,&ACIKLAMA)'
                ,['&REHBERID','&TUR','&ACIKLAMA'], [TabRehber.FieldByName('ID').AsInteger,1, copy(ComboSube.text+'/'+EditDepartman.text+'/'+EditGorevi.text,1,100)]);
        end;
        if OncekiCikisTarih<>DateCIKISTARIHI.text then
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PERS_HAREKET set TARIH='''+FormatDateTime('yyyy-mm-dd', DateCIKISTARIHI.Date)+''' where REHBERID = '+TabRehber.FieldByName('ID').AsString+' and TUR = 99',[],[]);
        ///bu b?l?m en sonda olmal?. ??nk? ?ncekileri de?i?tiriyor..
        if (Potansiyel)and(TabRehber.FieldByName('KOD').AsString='') then begin
           TabRehber.Edit;
           TabRehber.FieldByName('KOD').AsString:= TabRehber.FieldByName('ID').AsString;
           TabRehber.Post;
        end;
        Tablo.UserDataSourceKaydet(TIKWizardDlg(Self), 'REHBER_USER');
        // _USER (ek alan) audit: UserDataSourceKaydet _USER'i post ettikten SONRA logla (kart grubuna baglanir).
        if LogGun > 0 then
          ULog.LogUserKaydet('REHBER_USER', TabNo_REHBER_USER, TabloNo, TabRehber.FieldByName('ID').AsInteger, KartIslemi = 1);
        // KART loglama (TEK SEFER, Finish'te): edit -> LogIslemleri, yeni -> LogKayitEkle.
        // AfterPost'tan buraya tasindi (sayfa gecislerinde mukerrer loglamayi onlemek icin).
        if LogGun > 0 then begin
          if KartIslemi = 2 then begin
            // Detay (iletisim) loglamasi LogOnceki'yi ezip/temizleyip kart diff'ini
            // kaybediyordu -> DOGRU karta ait snapshot'i geri yukle, sonra logla.
            if (FKartSnapID = TabRehber.FieldByName('ID').AsInteger) and (FKartSnap.Count > 0) then
              LogOnceki.Assign(FKartSnap);
            LogKartDegisti(TabRehber, TabloNo, TabRehber.FieldByName('ID').AsInteger)  // IK: 73/74
          end
          else if KartIslemi = 1 then
            FEkleLogland := LogKartEkle(TabRehber, TabloNo, True, FEkleLogland) or FEkleLogland;
        end;
      end;

    1:if EkleKurIlet then
      begin
        Ekle(TabKurIlet, 1, RehberIletID, Degis, '', TabloNo, RehberID, 75); // KurumIletisimEkle;
      end;
    3:if EklePerOzluk then
        Ekle(TabPerOzluk, 3, RehberID, Degis, '', TabloNo, RehberID, 86); // Personel ?zl?k Ekle;
    4:if EklePerIlet then
        Ekle(TabPerIlet, 1, RehberPerID, Degis, '', TabloNo, RehberID, 81, TabIlgili.FieldByName('FIRMA').AsString); // PersonelIletisimEkle;
    5:if EklePerUcret then
        UcretEkle(TabPerUcret); // Personel ?cret Ekle;
  end;

  //if RehberID <> SonEklenenCari then
  //   tablo.SKRehberEkle(RehberID);
  ModalResult := mrok;
end;

procedure TIKWizardDlg.WizardKontrolNextButtonClick(Sender: TObject);
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
  else if Sayfa = PersonelOzlukEkr then
  begin
    if BosZorunluAlanSay(DtsPerOzluk, 'BILGI') > 0 then
      raise Exception.Create(zorunlualanhata);
  end
  else if Sayfa = PersonelIletisimEkr then
  begin
    if BosZorunluAlanSay(DtsPerIlet, 'BILGI') > 0 then
      raise Exception.Create(zorunlualanhata);
  end
  else if Sayfa = PersonelUcretEkr then
  begin
    if BosZorunluAlanSay(DtsPerUcret, 'TUTAR') > 0 then
      raise Exception.Create(zorunlualanhata);
  end;
end;

destructor TIKWizardDlg.Destroy;
begin
  // Geri-alinabilir oturum artigi (Finish/X): kalan snapshot varsa sil (Cancel zaten temizler).
  if FOturumID <> '' then
  begin
    ULog.OturumBitir(FOturumID);
    FOturumID := '';
  end;
  // FALLBACK: yeni personel karti kaydedilip Finish'siz kapatildiysa EKLEME logu kacmasin (tek sefer).
  FEkleLogland := LogKartEkle(TabRehber, TabloNo, YeniKayit, FEkleLogland) or FEkleLogland;
  LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
  FKartSnap.Free;
  inherited;
end;

end.



















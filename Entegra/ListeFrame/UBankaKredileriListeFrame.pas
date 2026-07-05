unit UBankaKredileriListeFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 06/01/2010 08:46:37}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, cxStyles, dxSkinsCore, DateUtils,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, dxSkinsDefaultPainters,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, DB, FireDAC.Comp.Client, cxDBData,
  cxCurrencyEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, ToolWin, ExtCtrls,
  UBankaKredileriAramaFrame,UBankaKredileriListeTanimlariFrame,
  UFrameYoneticisi, cxImage, cxLookAndFeels, cxNavigator, dxSkinLiquidSky,
  cxCalendar, cxPCdxBarPopupMenu, dxCore, cxDateUtils, cxSplitter,
  cxDropDownEdit, cxImageComboBox, JvExControls, JvNavigationPane, cxPC,
  frxClass, frxDBSet, UTablo, cxCheckBox, dxBarBuiltInMenu, cxMemo,
  cxGridCustomPopupMenu, cxGridPopupMenu, cxGridCardView, cxGridDBCardView,
  cxGridCustomLayoutView, cxLabel, OfficePopupMenu, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses,
  FireDAC.Comp.DataSet;

type
  TBankaKredileriListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog)
    GridTakvim: TcxGrid;
    GridTakvimDBTableView1: TcxGridDBTableView;
    GridTakvimDBTableView1KREDIKODU1: TcxGridDBColumn;
    GridTakvimDBTableView1KREDITURU1: TcxGridDBColumn;
    GridTakvimDBTableView1KREDIACIKLAMA1: TcxGridDBColumn;
    GridTakvimDBTableView1ALINISTARIHI1: TcxGridDBColumn;
    GridTakvimLevel1: TcxGridLevel;
    DtsKrediler: TDataSource;
    KREDILER: TFDQuery;
    GridTakvimDBTableView1BANKAADI: TcxGridDBColumn;
    EKSTRE: TFDQuery;
    TabCariListe1: TFDQuery;
    DateTimeField1: TDateTimeField;
    StringField1: TStringField;
    StringField2: TStringField;
    StringField3: TStringField;
    StringField4: TStringField;
    StringField5: TStringField;
    StringField6: TStringField;
    BCDField1: TBCDField;
    BCDField2: TBCDField;
    TabCariListe1DURUM: TSmallintField;
    frxEkstre: TfrxDBDataset;
    DtsCariListe: TDataSource;
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
    PageControlSekme: TcxPageControl;
    TabSheetIlet: TcxTabSheet;
    TabSheetEkstre: TcxTabSheet;
    cxGrid1: TcxGrid;
    cxGridHareketler: TcxGridDBTableView;
    cxGridHareketlerTARIH: TcxGridDBColumn;
    cxGridHareketlerAKSIYONTARIH: TcxGridDBColumn;
    cxGridHareketlerNO: TcxGridDBColumn;
    cxGridHareketlerTUR: TcxGridDBColumn;
    cxGridHareketlerKOD: TcxGridDBColumn;
    cxGridHareketlerAD: TcxGridDBColumn;
    cxGridHareketlerACIKLAMA: TcxGridDBColumn;
    cxGridHareketlerHESAPKODU: TcxGridDBColumn;
    cxGridHareketlerHESAPADI: TcxGridDBColumn;
    cxGridHareketlerKUR: TcxGridDBColumn;
    cxGridHareketlerBORC: TcxGridDBColumn;
    cxGridHareketlerALACAK: TcxGridDBColumn;
    cxGridHareketlerBORCBAKIYE: TcxGridDBColumn;
    cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    cxGrid1DBTableView1VADE: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    cxGrid1DBTableView1HESAPADI: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    Panel1: TPanel;
    ToolBar11: TToolBar;
    JvNavPanelHeader2: TJvNavPanelHeader;
    Label2: TLabel;
    Label1: TLabel;
    CalendarEkstreBit: TcxDateEdit;
    CalendarEkstreBas: TcxDateEdit;
    cxSplitter1: TcxSplitter;
    frxKredi: TfrxDBDataset;
    AnaparaEkleTus: TToolButton;
    AnaparaOdemeTus: TToolButton;
    SilTus: TToolButton;
    GridTakvimDBTableView1ID: TcxGridDBColumn;
    GridTakvimDBTableView1SOZLESMENO: TcxGridDBColumn;
    GridTakvimDBTableView1KUR: TcxGridDBColumn;
    GridTakvimDBTableView1KAPANISTARIHI: TcxGridDBColumn;
    GridTakvimDBTableView1KREDITAKSIT: TcxGridDBColumn;
    GridTakvimDBTableView1ODENENTAKSIT: TcxGridDBColumn;
    GridTakvimDBTableView1TAKSITTUTARI: TcxGridDBColumn;
    GridTakvimDBTableView1DURUM: TcxGridDBColumn;
    GridTakvimDBTableView1SUBEADI: TcxGridDBColumn;
    KrediMenu: TPopupMenu;
    KrediInfoMenu: TMenuItem;
    YeniBanka1: TMenuItem;
    HesabDzenle1: TMenuItem;
    HesabSil1: TMenuItem;
    DevirFiiGir1: TMenuItem;
    Panel2: TPanel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    ToolButton1: TToolButton;
    YaziciYaz: TToolButton;
    JvNavPanelHeader1: TJvNavPanelHeader;
    CheckAktifPasif: TcxCheckBox;
    KrediSilTus: TToolButton;
    ToolButton3: TToolButton;
    GridTakvimDBTableView1TOPLAM_TUTAR: TcxGridDBColumn;
    GridTakvimDBTableView1TOPLAM_ANAPARA: TcxGridDBColumn;
    GridTakvimDBTableView1TOPLAM_GIDER: TcxGridDBColumn;
    GridTakvimDBTableView1ODENEN_TUTAR: TcxGridDBColumn;
    GridTakvimDBTableView1ODENEN_ANAPARA: TcxGridDBColumn;
    GridTakvimDBTableView1ODENEN_GIDER: TcxGridDBColumn;
    GridTakvimDBTableView1KALAN_TUTAR: TcxGridDBColumn;
    GridTakvimDBTableView1KALAN_ANAPARA: TcxGridDBColumn;
    GridTakvimDBTableView1KALAN_GIDER: TcxGridDBColumn;
    ToolButton2: TToolButton;
    TabYorumMedya: TcxTabSheet;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel7: TPanel;
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
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    EdKrediTrh: TcxDateEdit;
    arihSe1: TMenuItem;
    GridTakvimDBTableView1KALANTAKSIT: TcxGridDBColumn;
    GridTakvimDBTableView1KREDILIMITSURE: TcxGridDBColumn;
    GridTakvimDBTableView1KREDILIMIT: TcxGridDBColumn;
    GridTakvimDBTableView1KREDIKULLANIMSURE: TcxGridDBColumn;
    GridTakvimDBTableView1KREDIEKLIMITVAR: TcxGridDBColumn;
    GridTakvimDBTableView1REVIZYONTARIHI: TcxGridDBColumn;
    TabRotatif: TcxTabSheet;
    ROTATIFDURUM: TFDQuery;
    DtsROTATIFDURUM: TDataSource;
    DtsRotatif: TDataSource;
    KREDIROTATIF: TFDQuery;
    PanelDurum: TPanel;
    ToolBar5: TToolBar;
    KapatTus: TToolButton;
    ToolButton4: TToolButton;
    cxLabel16: TcxLabel;
    HesaplamaTarihi: TcxDateEdit;
    CheckValor: TcxCheckBox;
    cxGrid5: TcxGrid;
    cxGridDBTableView4: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    MemoRotatSQL: TMemo;
    Panel3: TPanel;
    ToolBar2: TToolBar;
    KrediEkleTus: TToolButton;
    OdemeSilTus: TToolButton;
    OdemeEkleTus: TToolButton;
    CheckKapanmis: TcxCheckBox;
    DurumRaporuTus: TToolButton;
    GridRotatif: TcxGrid;
    GridRotatifView1: TcxGridDBTableView;
    GridRotatifView1ID: TcxGridDBColumn;
    GridRotatifView1KREDIID: TcxGridDBColumn;
    GridRotatifView1TARIH: TcxGridDBColumn;
    GridRotatifView1KREDIREFERANSNO: TcxGridDBColumn;
    GridRotatifView1TUTAR: TcxGridDBColumn;
    GridRotatifView1ODENEN: TcxGridDBColumn;
    GridRotatifView1BAKIYE: TcxGridDBColumn;
    GridRotatifView1FAIZTUTARI: TcxGridDBColumn;
    GridRotatifView1BSMV: TcxGridDBColumn;
    GridRotatifView1TOPLAM: TcxGridDBColumn;
    GridRotatifView1ODENENFAIZ: TcxGridDBColumn;
    GridRotatifView1KALANFAIZ: TcxGridDBColumn;
    GridRotatifView1KUR: TcxGridDBColumn;
    GridRotatifView1ACIKLAMA: TcxGridDBColumn;
    GridRotatifView1VALOR: TcxGridDBColumn;
    GridRotatifView1ODENMIS: TcxGridDBColumn;
    GridRotatifView1EKLEYEN: TcxGridDBColumn;
    GridRotatifView1EKLEMETARIHI: TcxGridDBColumn;
    GridRotatifView1DEGISTIREN: TcxGridDBColumn;
    GridRotatifView1DEGISTIRMETARIHI: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    PopupRotatif: TPopupMenu;
    KrediyiEkleMenu: TMenuItem;
    ToolButton5: TToolButton;
    CheckMasrafGoster: TcxCheckBox;
    MasrafEkleTus: TToolButton;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    MasrafOdemeTus: TToolButton;
    ToolButton9: TToolButton;
    PopupRotatifMasrafEkleMenu: TPopupMenu;
    RotatifFaizrMasrafEkleMenu: TMenuItem;
    RotatifDigerTurMasrafEkleMenu: TMenuItem;
    PopupRotatifMasrafOdeMenu: TPopupMenu;
    DonemFaiziOdeMenu: TMenuItem;
    DigerMasrafOdeMenu: TMenuItem;
    DonemOranTus: TToolButton;
    TabSheetCekKocan: TcxTabSheet;
    TabCekKocan: TFDQuery;
    DtsCekKocan: TDataSource;
    ToolBar3: TToolBar;
    YeniKocanTus: TToolButton;
    KaydetKocanTus: TToolButton;
    IptalKocanTus: TToolButton;
    SilKocanTus: TToolButton;
    GridCekKocan: TcxGrid;
    GridCekKocanView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridCekKocanViewID: TcxGridDBColumn;
    GridCekKocanViewKREDIID: TcxGridDBColumn;
    GridCekKocanViewTARIH: TcxGridDBColumn;
    GridCekKocanViewBASSERINO: TcxGridDBColumn;
    GridCekKocanViewBITSERINO: TcxGridDBColumn;
    GridCekKocanViewKOCANNO: TcxGridDBColumn;
    GridCekKocanViewACIKLAMA: TcxGridDBColumn;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridTakvimDBTableView1DblClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure YenileTusClick;
    procedure GridTakvimDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure PageControlSekmeChange(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure TabSheetEkstreShow(Sender: TObject);
    procedure KREDILERAfterScroll(DataSet: TDataSet);
    procedure AnaparaEkleTusClick(Sender: TObject);
    procedure AnaparaOdemeTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure AcilisKaydiMenuClick(Sender: TObject);
    procedure cxCheckBox1PropertiesChange(Sender: TObject);
    procedure KrediSilTusClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure cxGridHareketlerCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure arihSe1Click(Sender: TObject);
    procedure Kasa_Islemleri(Tur, RehberId:Integer;HesapTur:char;Kur:String; Borc, Alacak : Currency;FaturaId:Integer=0; KrediId:Integer=0;Yer:Integer=0;YerId:Integer=0);
    procedure KrediEkleTusClick(Sender: TObject);
    procedure OdemeSilTusClick(Sender: TObject);
    procedure OdemeEkleTusClick(Sender: TObject);
    procedure KREDIROTATIFNewRecord(DataSet: TDataSet);
    procedure KREDIROTATIFBeforePost(DataSet: TDataSet);
    procedure KREDIROTATIFBeforeEdit(DataSet: TDataSet);
    procedure KREDIROTATIFAfterPost(DataSet: TDataSet);
    procedure KapatTusClick(Sender: TObject);
    procedure HesaplamaTarihiPropertiesCloseUp(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure CheckMasrafGosterClick(Sender: TObject);
    procedure RotatifFaizrMasrafEkleMenuClick(Sender: TObject);
    procedure RotatifDigerTurMasrafEkleMenuClick(Sender: TObject);
    procedure DonemFaiziOdeMenuClick(Sender: TObject);
    procedure DigerMasrafOdeMenuClick(Sender: TObject);
    procedure DonemOranTusClick(Sender: TObject);
    procedure YeniKocanTusClick(Sender: TObject);
    procedure SilKocanTusClick(Sender: TObject);
    procedure KaydetKocanTusClick(Sender: TObject);
    procedure IptalKocanTusClick(Sender: TObject);
    procedure DtsCekKocanStateChange(Sender: TObject);
    procedure TabCekKocanNewRecord(DataSet: TDataSet);
    procedure TabCekKocanBeforePost(DataSet: TDataSet);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
    procedure KrediInfoMenuClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TBankaKredileriAramaFrame;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    function EkranAdiAl: string;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    procedure KrediKapatEylemi(Sender: TObject);
    procedure KrediEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TBankaKredileriAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure EkstreGoster(Goster:Boolean);
    function RotatifBaslamaTarihGetir(var BasAy : smallint; var BasYil : smallint) : TDateTime;
    function RotatifDonemTarihGetir(BasAy, BasYil : smallint) : TDateTime;
    function RotatifDonemVar(YeniIslemTarihi:TDateTime):Boolean;
    procedure RotatifFaizMasrafEkle(Kapandi:Boolean=False);
  public
    { Public declarations }
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
  published
    property Arama : TBankaKredileriAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,UKrediler, FetaKurulusSiniflari, FetaClassExtensions, UKasalarListeFrame, PrjConst,UKrediHesapMakineDlg,
     URaporAraclari, UGenelAnaSekmeFrame, UFastRap, UGirisKutusuEx, FetaUtil,LocOnfly,
  UKrediEkle, UKasaWizard, URotatifDonemFaiz, ULog;


{$R *.dfm}

{ TBankaKredileriListeFrame }

function TBankaKredileriListeFrame.EkranAdiAl: string;
begin
   Result := 'KrediListeDlg'; //  'CariDlg'   'RehberAraDlg';
end;

procedure TBankaKredileriListeFrame.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TBankaKredileriListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   fb : TIcerikFrameBilgi;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);

   AFastReport.EnabledDataSets.Clear;
   if pos('EKSTRE', UpperCase(DokumAdi))>0  then begin//ekstre ise
      frxEkstre.DataSet := EKSTRE;
      DokumDegiskenListesi.Add(KontrolBaslangisTarihi+'$@$'+DateToStr(CalendarEkstreBas.Date));
      DokumDegiskenListesi.Add(KontrolBitisTarihi+'$@$'+DateToStr(CalendarEkstreBit.Date));
      AFastReport.EnabledDataSets.Add(frxEkstre);
   end
   else if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxEkstre) then begin
      AFastReport.EnabledDataSets.Clear;
      AFastReport.EnabledDataSets.Add(frxEkstre)
   end else begin
      AFastReport.EnabledDataSets.Clear;
      frxKredi.DataSet := KREDILER;
      AFastReport.EnabledDataSets.Add(frxKredi);
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TBankaKredileriListeFrame.AcilisKaydiMenuClick(Sender: TObject);
begin
  if Tablo.AcilisiFisiEkraniBaslat(6,TMenuItem(Sender).Tag,KREDILER.FieldByname('ID').AsString,KREDILER.FieldByname('KREDIKODU').AsString,KREDILER.FieldByname('ADI').AsString, KREDILER.FieldByname('KUR').AsString,0, Tablo.GENINI.BugunTrhSaat) then
    YenileTusClick;
end;

procedure TBankaKredileriListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    KREDILER.Prior
  else if Key = 40 then
    KREDILER.next
  else
  begin
      YenileTusClick;
      DegisTus.visible := KREDILER.RecordCount>0;
  end;
end;

procedure TBankaKredileriListeFrame.arihSe1Click(Sender: TObject);
begin
  EdKrediTrh.Visible := True;
end;

procedure TBankaKredileriListeFrame.YeniKocanTusClick(Sender: TObject);
begin
  TabCekKocan.Append;
end;

procedure TBankaKredileriListeFrame.YenileTusClick;
var
  P: TFDParam;
  LAfterScroll: TDataSetNotifyEvent;
begin
  if EdKrediTrh.EditValue = Null then begin
    EdKrediTrh.EditValue := EndOfTheDay(Tablo.GENINI.BugunTrh);
    EdKrediTrh.PostEditValue;
    EdKrediTrh.Properties.OnEditValueChanged := cxCheckBox1PropertiesChange;
  end;

  LAfterScroll := KREDILER.AfterScroll;
  KREDILER.AfterScroll := nil;
  try
    KREDILER.Close;
    KREDILER.Params.Clear;
    P := KREDILER.Params.Add;
    P.Name := 'PDrm';
    P.DataType := ftInteger;
    P.ParamType := ptInput;
    P.AsInteger := Ord(not CheckAktifPasif.Checked);
    P := KREDILER.Params.Add;
    P.Name := 'PTrh';
    P.DataType := ftDateTime;
    P.ParamType := ptInput;
    P.AsDateTime := EndOfTheDay(EdKrediTrh.Date);
    KREDILER.Open;
  finally
    KREDILER.AfterScroll := LAfterScroll;
  end;

  if Assigned(LAfterScroll) then
    LAfterScroll(KREDILER);
end;

procedure TBankaKredileriListeFrame.AnaparaOdemeTusClick(Sender: TObject);
var
  //TarihAl : Variant;
  Tarih, Valor, RefNo, Tutar, Aciklama : Variant;
  ctrls : TGirdiDenetimleri;
  ID,ID2: integer;
  KalanAnaPara : currency;
begin
   if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM KREDIROTATIFFAIZ where KREDIID='+KREDILER.FieldByName('ID').AsString,[],[]) then begin
      Showmessage('?nce faiz oranlar?n? girin!');
      exit;
   end;


  KalanAnaPara := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select	isnull(sum(BORC-ALACAK),0) from KASA KS where HESAPTURU=''R'' '+
     'and KS.TUR<>2 and KS.HESAPID='+KREDILER.FieldByName('ID').AsString,[],[], True);

  Tarih := Tablo.GENINI.BugunTrhSaat;
  Valor := Tarih;
  Tutar := KalanAnaPara;
  ctrls := TGirdiDenetimleri.Create.DateTimePicker(BGIslem_tarih_gir, @Tarih, dtkDate).DateTimePicker('Val?r', @Valor, dtkDate).Edit('Referans No', @RefNo).CurrencyEdit('?denen Tutar', @Tutar,2).Edit('A??klama', @Aciklama);
  if TGirisKutusuEx.BilgiAlEx(BGKredi_odemesi, ctrls) = mrOk then begin
     if StrToFloatDef(VarToStr(Tutar),0)-KalanAnaPara>1 then
        raise Exception.Create('Kalan Anaparadan daha fazla ?deme yap?lamaz!');
     //giri? veya ??k?? yaparken arada d?nem var m? bakal?m
     if EKSTRE.RecordCount >0 then
        while RotatifDonemVar(VarToDateTime(Valor)) do
              RotatifFaizMasrafEkle;

     ID:=Tablo.KasaKaydet(58, VarToDateTime(Valor), VarToDateTime(Tarih) ,0,Aciklama, KREDILER.FieldByName('ID').AsInteger,
              KREDILER.FieldByName('KUR').AsString,'',0,0,FStrToCurrDef(VarToStr(Tutar),0),0,-1,KREDILER.FieldByName('ID').AsInteger,0,
              -1,-1, SubeId,'R',0,0, VarToStr(RefNo));
              /// Rotatifin ID'sini fatura id'ye Kredinin Id sini de kredi Id ye atar?z

     ID2:=Tablo.KasaKaydet(58, VarToDateTime(Valor), VarToDateTime(Tarih) ,0, Aciklama, KREDILER.FieldByName('BANKATICARIHESAPID').AsInteger,
              KREDILER.FieldByName('KUR').AsString,'',0,FStrToCurrDef(VarToStr(Tutar),0),0,0,-1,KREDILER.FieldByName('ID').AsInteger,KREDILER.FieldByName('ID').AsInteger,
              -1,ID, SubeId,' ',0,0, VarToStr(RefNo));

              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set GERIDONUSID='+IntToStr(ID2)+' where ID='+IntToStr(ID),[],[]);

     if Abs(StrToFloatDef(VarToStr(Tutar),0)-KalanAnaPara) < 1  then
        RotatifFaizMasrafEkle(True);

  end;

//   Tarih := TarihAl;
//   Tablo.KasaSihirbazBaslat('E', KREDILER.FieldByName('ID').AsInteger, 58, 9,  -1, Tarih,Tarih,0, 0, KREDILER.FieldByName('KUR').AsString, '');
   YenileTusClick;
end;

procedure TBankaKredileriListeFrame.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s)
end;

procedure TBankaKredileriListeFrame.Baslatildi;
var ra : string;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   //GridTviewSUBEID.Visible := SubeVarmi;
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
   TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;
   YenileTusClick;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

   DegisTus.visible := KREDILER.Active;
   //SilTus.visible := DegisTus.visible;
   PageControlSekme.ActivePageIndex := 0;
   CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil-5));
   CalendarEkstreBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));

   //GridTakvimDBTableView1.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\BankaKredileriListeGridi',true,false,[gsoUseFilter],'BankaKredileriListeGridi');
   Tablo.GridAyarRestore('BankaKredileriListeGridi',GridTakvimDBTableView1 );
   Tablo.GridAyarRestore('BankaKredileriHareketlerGridi',cxGridHareketler );

//   cxGridHareketler.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasalarExtreGridi',true,false,[gsoUseFilter],'KasalarExtreGridi');

  // YenileTusClick;

  Tablo.GridTurkcelestir;
end;

procedure TBankaKredileriListeFrame.BtnMesajGonderClick(Sender: TObject);
begin
   Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger, KREDILER.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TBankaKredileriListeFrame.CalendarEkstreBasPropertiesEditValueChanged(
  Sender: TObject);
begin
   EkstreGoster(CheckMasrafGoster.checked);
end;

procedure TBankaKredileriListeFrame.CheckMasrafGosterClick(Sender: TObject);
begin
     EkstreGoster(CheckMasrafGoster.checked);
end;

procedure TBankaKredileriListeFrame.KrediInfoMenuClick(Sender: TObject);
begin
   if not KREDILER.IsEmpty then
      Tablo.InfoGoster('KREDILER', KREDILER.FieldByName('ID').AsInteger, TabNo_KREDILER);
end;

procedure TBankaKredileriListeFrame.cxCheckBox1PropertiesChange(Sender: TObject);
begin
 YenileTusClick;
end;

procedure TBankaKredileriListeFrame.cxGridHareketlerCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
    AnaForm.cxGridPopupMenu1.Grid:=cxGrid1;
    AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridHareketler;
    AnaForm.pmGridStil.Tags.Values[cxGrid1.Name] := 'BankaKredileriHareketlerGridi';
end;

procedure TBankaKredileriListeFrame.DegisTusClick(Sender: TObject);
begin
  KrediEkranAc(False);
  YenileTusClick;
end;

procedure TBankaKredileriListeFrame.DigerMasrafOdeMenuClick(Sender: TObject);
var ID : integer;
begin
   if EKSTRE.RecordCount = 0 then exit;
   ID := Tablo.NakitSihirbazBaslat('B','E', 32, 1, -1, 0, Tablo.GENINI.BugunTrhSaat, '-1');
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set YERI='+IntToStr(TabNo_KREDILER)+', YERID='+KREDILER.FieldByName('ID').AsString+' where ID='+IntToStr(ID),[],[]);
   EkstreGoster(CheckMasrafGoster.checked);
end;

procedure TBankaKredileriListeFrame.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TBankaKredileriListeFrame.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TBankaKredileriListeFrame.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
            TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, KREDILER.FieldByName('ID').AsInteger)
end;

procedure TBankaKredileriListeFrame.DonemFaiziOdeMenuClick(Sender: TObject);
var ID : Integer;
begin
   if EKSTRE.RecordCount = 0 then exit;
   Tablo.TablodanSorguAc(1,'select isnull(FAIZMASRAFID,0) from KREDILER where ID='+KREDILER.FieldByName('ID').AsString);
   ID := Tablo.NakitSihirbazBaslat('B','E', 32, 1, -1, 0, Tablo.GENINI.BugunTrhSaat, '-1',False,Tablo.Query1.Fields[0].AsInteger);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set YERI='+IntToStr(TabNo_KREDILER)+', YERID='+KREDILER.FieldByName('ID').AsString+' where ID='+IntToStr(ID),[],[]);
   EkstreGoster(CheckMasrafGoster.checked);
end;

procedure TBankaKredileriListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TBankaKredileriListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankaKredileriListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TBankaKredileriListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TBankaKredileriListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TBankaKredileriListeFrame.Gorunmez;
begin

end;

procedure TBankaKredileriListeFrame.GorunmezOlacak;
begin

end;

procedure TBankaKredileriListeFrame.Gorunur;
begin
  YenileTusClick;
end;

procedure TBankaKredileriListeFrame.GorunurOlacak;
begin

end;

procedure TBankaKredileriListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TBankaKredileriListeFrame.KapatTusClick(Sender: TObject);
begin
   PanelDurum.Visible := False;
end;

procedure TBankaKredileriListeFrame.KaydetKocanTusClick(Sender: TObject);
begin
  TabCekKocan.Post;
end;

procedure TBankaKredileriListeFrame.Kasa_Islemleri(Tur, RehberId:Integer;HesapTur:char;Kur:String; Borc, Alacak : Currency;FaturaId:Integer=0; KrediId:Integer=0;Yer:Integer=0;YerId:Integer=0);
var ID,ID2:integer;
begin
  //banka
  ID := Tablo.KasaKaydet(Tur, KREDIROTATIF.FieldByName('TARIH').AsDateTime, KREDIROTATIF.FieldByName('TARIH').AsDateTime,RehberId,
         KREDIROTATIF.FieldByName('ACIKLAMA').AsString, KREDILER.FieldByName('BANKATICARIHESAPID').AsInteger,Kur,Kur,0,
         Borc, Alacak,Abs(Borc-Alacak),0,FaturaId,KrediId,0,0,SubeId,'B', Yer,YerId, KREDIROTATIF.FieldByName('KREDIREFERANSNO').AsString);
  //kredi//
  ID2 := Tablo.KasaKaydet(Tur, KREDIROTATIF.FieldByName('TARIH').AsDateTime, KREDIROTATIF.FieldByName('TARIH').AsDateTime,0,
         KREDIROTATIF.FieldByName('ACIKLAMA').AsString, KREDILER.FieldByName('ID').AsInteger,Kur,Kur,0,
         Alacak,Borc,Abs(Borc-Alacak),0,FaturaId,KrediId,0,0,SubeId, HesapTur, Yer,YerId, KREDIROTATIF.FieldByName('KREDIREFERANSNO').AsString);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update KASA set GERIDONUSID = '+IntToStr(ID2)+' where ID = '+IntToStr(ID),[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update KASA set GERIDONUSID = '+IntToStr(ID)+' where ID = '+IntToStr(ID2),[],[]);
end;

procedure TBankaKredileriListeFrame.KrediEkleTusClick(Sender: TObject);
begin
   if KREDILER.State = dsInsert then
      KREDILER.Post;
   Application.CreateForm(TKrediEkleDlg, KrediEkleDlg);
   KrediEkleDlg.KrediID := KREDILER.FieldByName('ID').AsInteger;
   KrediEkleDlg.ShowModal;
   if KrediEkleDlg.ModalResult = mrOk then  begin
      KREDIROTATIF.Append;
      KREDIROTATIF.FieldByName('TARIH').AsDateTime := KrediEkleDlg.DateTimePickerOdemeBasl.Date;//FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY hh:nn',
      KREDIROTATIF.FieldByName('KREDIREFERANSNO').AsString := KrediEkleDlg.EditRef.Text;
      KREDIROTATIF.FieldByName('TUTAR').AsCurrency:= KrediEkleDlg.EditTutar.Value;
      KREDIROTATIF.FieldByName('ACIKLAMA').AsString := KrediEkleDlg.EditAcik.Text;
      KREDIROTATIF.Post;
      Kasa_Islemleri(59,0,'R',CariDoviz, 0, KREDIROTATIF.FieldByName('TUTAR').AsCurrency, 0, KREDILER.FieldByName('ID').AsInteger,
         TabNo_KREDIROTATIF, KREDIROTATIF.FieldByName('ID').AsInteger);
   end;
end;

procedure TBankaKredileriListeFrame.KrediEkranAc(Yeni: Boolean);
begin
  with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TKredilerDlg).Git do begin
   with TKredilerDlg(Ornek) do begin
     KapatEylemi := KrediKapatEylemi;
     KrediEkranInit(FetaKurulusSiniflari.IIf(Yeni, -1, FetaKurulusSiniflari.IIf(Self.KREDILER.RecordCount = 0, -1, Self.KREDILER.AsInteger['ID'])));
     if Yeni then
        KREDILER.Append;
   end;
 end;
end;

procedure TBankaKredileriListeFrame.KrediKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
  YenileTusClick;
end;

procedure TBankaKredileriListeFrame.KREDILERAfterScroll(DataSet: TDataSet);
begin
  TabSheetCekKocan.TabVisible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger=31; // ?ek
  TabSheetEkstre.TabVisible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger in [1, 2, 21];    //
  //TabRotatif.TabVisible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger=2;    //   Rotatif
  AnaparaEkleTus.Visible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger=2;    //   Rotatif
  AnaparaOdemeTus.Visible := AnaparaEkleTus.Visible;
  SilTus.Visible := AnaparaEkleTus.Visible;
  PageControlSekmeChange(Self);
end;

procedure TBankaKredileriListeFrame.KREDIROTATIFAfterPost(DataSet: TDataSet);
begin
   if YeniKayit then
      KrediyiEkleMenu.Click;
end;

procedure TBankaKredileriListeFrame.KREDIROTATIFBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit := False;
end;

procedure TBankaKredileriListeFrame.KREDIROTATIFBeforePost(DataSet: TDataSet);
var tut : Currency;
begin
   KREDIROTATIF.FieldByName('BAKIYE').AsCurrency := KREDIROTATIF.FieldByName('TUTAR').AsCurrency;
   //Yeni kredi al?nd? eski toplama eklenecek
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := ' select top 1 isnull(BAKIYE,0.0) from  KREDIROTATIF where KREDIID=' +KREDIROTATIF.FieldByName('KREDIID').AsString+
                            ' and KREDIREFERANSNO='''+KREDIROTATIF.FieldByName('KREDIREFERANSNO').AsString+'''  ';
   if KREDIROTATIF.FieldByName('ID').AsString<>'' then //eski kay?t ?st?nde d?zeltme yap?l?yorsa ID doludur yeniyse bo?tur
      Tablo.Query1.SQL.Add(' and ID<'+KREDIROTATIF.FieldByName('ID').AsString);
   Tablo.Query1.SQL.Add(' order by TARIH,ID desc');
   Tablo.Query1.Open;
   if Tablo.Query1.RecordCount>0 then
      tut := Tablo.Query1.Fields[0].AsCurrency
   else
      tut := 0.0;
   KREDIROTATIF.FieldByName('BAKIYE').AsCurrency := tut + KREDIROTATIF.FieldByName('TUTAR').AsCurrency-KREDIROTATIF.FieldByName('ODENEN').AsCurrency;
   KREDIROTATIF.FieldByName('DEGISTIREN').AsString := Kullanan;
   KREDIROTATIF.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
end;

procedure TBankaKredileriListeFrame.KREDIROTATIFNewRecord(DataSet: TDataSet);
begin
   YeniKayit := True;
   KREDIROTATIF.FieldByName('EKLEYEN').AsString := Kullanan;
   KREDIROTATIF.FieldByName('KREDIID').AsInteger := KREDILER.FieldByName('ID').AsInteger;
   KREDIROTATIF.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrh;
   //KREDIROTATIF.FieldByName('KUR').AsString := KREDILER.FieldByName('BANKAKREDIKUR').AsString;
   KREDIROTATIF.FieldByName('ODENMIS').AsBoolean:= False;
   KREDIROTATIF.FieldByName('VALOR').AsBoolean:= False;
   KREDIROTATIF.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TBankaKredileriListeFrame.EkstreGoster(Goster:Boolean);
begin

      MasrafEkleTus.Visible :=Goster;
      MasrafOdemeTus.Visible :=Goster;

      ToolButton6.Visible := Goster;
      DonemOranTus.Visible := Goster;


      if EKSTRE.Active then
        EKSTRE.Close;
      if (KREDILER.RecordCount>0)and(KREDILER.FieldByName('ID').AsString<>'') then begin
         EKSTRE.SQL.Text := 'select * from dbo.fn_Kredi_Ekstre ';
         EKSTRE.SQL.Add('('+KREDILER.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''','+iif(CheckMasrafGoster.Checked,'1','0')+')');
         EKSTRE.SQL.Add('order by KUR, ISLEMTARIHI');
         TabloYenile(EKSTRE,[]);
      end;
end;

procedure TBankaKredileriListeFrame.PageControlSekmeChange(Sender: TObject);
begin
  //fn_Kredi_Ekstre
  if (PageControlSekme.ActivePage=TabSheetEkstre)and(KREDILER.Active)and(KREDILER.RecordCount>0)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
      CheckMasrafGoster.Visible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger<>1;    //   Rotatif
      //CheckMasrafGoster.checked := False;
      if CheckMasrafGoster.visible then
         EkstreGoster(CheckMasrafGoster.checked)
      else
         EkstreGoster(False);
  end
  else if PageControlSekme.ActivePage=TabYorumMedya then
      Tabloyenile(TabYorum,[TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger])
  else if PageControlSekme.ActivePage=TabRotatif then begin
       TabloYenile(KREDIROTATIF,[KREDILER.FieldByName('ID').AsInteger, CheckKapanmis.Checked]);
       GridRotatifView1.ApplyBestFit(nil);
  end
  else if PageControlSekme.ActivePage=TabSheetCekKocan then begin
       TabloYenile(TabCekKocan,[KREDILER.FieldByName('ID').AsInteger]);
       GridCekKocanView.ApplyBestFit(nil);
  end;
end;

procedure TBankaKredileriListeFrame.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TBankaKredileriListeFrame.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TBankaKredileriListeFrame.RotatifDigerTurMasrafEkleMenuClick(Sender: TObject);
var ID : integer;
begin
   ID := Tablo.TahakkukSihirbaziBaslat('E',13,0,-1,0,Tablo.GENINI.BugunTrhSaat);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set YERI='+IntToStr(TabNo_KREDILER)+', YERID='+KREDILER.FieldByName('ID').AsString+' where ID='+IntToStr(ID),[],[]);
   EkstreGoster(CheckMasrafGoster.checked);
end;

procedure TBankaKredileriListeFrame.RotatifFaizrMasrafEkleMenuClick(Sender: TObject);
begin
   if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM KREDIROTATIFFAIZ where KREDIID='+KREDILER.FieldByName('ID').AsString,[],[]) then begin
      Showmessage('?nce faiz oranlar?n? girin!');
      exit;
   end;
   if EKSTRE.RecordCount >0 then
      RotatifFaizMasrafEkle;
end;

function TBankaKredileriListeFrame.RotatifBaslamaTarihGetir(var BasAy : smallint; var BasYil : smallint) : TDateTime;
begin
  Tablo.TablodanSorguAc(1,'select top 1 * from ('+
                       ' select  TUR=1,GUN=DATEPART(DD, min(PLANTARIHI)),AY=DATEPART(MM, min(PLANTARIHI)), YIL=DATEPART(YYYY, min(PLANTARIHI))  from  KASA where TUR = 59 and HESAPTURU=''R'' and HESAPID='+KREDILER.FieldByName('ID').AsString+
                       ' union all'+
                       ' select  TUR=2,GUN=DATEPART(DD, TARIH),AY=DATEPART(MM, TARIH), YIL=DATEPART(YYYY, TARIH)  from FATBASLIK where TUR=13 and YERI=47 and YERID='+KREDILER.FieldByName('ID').AsString+' and LOKASYON=131 )as cc order by 1 desc,4 desc,3 desc,2 desc  ');
  if Tablo.Query1.Fields[0].AsInteger = 1 then
     BasAy := Tablo.Query1.Fields[2].AsInteger - 1
  else
     BasAy := Tablo.Query1.Fields[2].AsInteger + 1;

  BasYil := Tablo.Query1.Fields[3].AsInteger;
  Result := StrToDateTime(Tablo.Query1.Fields[1].AsString+FormatSettings.DateSeparator+Tablo.Query1.Fields[2].AsString+FormatSettings.DateSeparator+Tablo.Query1.Fields[3].AsString);
end;

function TBankaKredileriListeFrame.RotatifDonemTarihGetir(BasAy, BasYil : smallint) : TDateTime;
begin
  Tablo.TablodanSorguAc(2,'SELECT GUN=SIRA,AY=DEGER FROM GENINI WHERE BOLUM=25009 and DEGER=(SELECT isnull(min(DEGER),(SELECT min(DEGER) FROM GENINI WHERE BOLUM=25009 )) FROM GENINI WHERE BOLUM=25009 and DEGER>'+IntToStr(BasAy)+')');
  Result := StrToDateTime(Tablo.Query2.Fields[0].AsString+FormatSettings.DateSeparator+Tablo.Query2.Fields[1].AsString+FormatSettings.DateSeparator+IntToStr(BasYil));
end;

function TBankaKredileriListeFrame.RotatifDonemVar(YeniIslemTarihi : TDateTime):Boolean;
var BasAy, BasYil : SmallInt;
    BasTarihi,DonemTarihi : TDateTime;
begin
    BasTarihi := RotatifBaslamaTarihGetir(BasAy, BasYil);
    DonemTarihi := RotatifDonemTarihGetir(BasAy, BasYil);
    if DonemTarihi < YeniIslemTarihi then
       Result := Application.MessageBox(PChar(faiz_donem_odemesi), PChar(Uyari),  MB_YESNO)=ID_YES
    else
       Result := False
end;

procedure TBankaKredileriListeFrame.RotatifFaizMasrafEkle(Kapandi:Boolean=False);
var SimdikiFaizTut : Currency;
    IslemTarih, ValorTarih,  FaizTutar, BSMVTutar, FaizAciklama, BSMVAciklama : Variant;
    BasTarihi, DonemTarihi : TDateTime;
    BasAy, BasYil : SmallInt;
    procedure Ekle(Aciklama:string; TUTAR:currency; LokTipi:Smallint);
    begin
      // LokTipi  131 ise faiz  132 ise BSMV
      Tablo.TablodanSorguAc(1,'select isnull(FAIZMASRAFID,0) from KREDILER where ID='+KREDILER.FieldByName('ID').AsString);
      //o g?ne kadar olan ana para bakiyeyi de matraha yazar?z
      Tablo.TablodanSorguAc(2,'select isnull(sum(BORC-ALACAK),0.0) from KASA where TUR in (58,59)and HESAPTURU=''R'' and HESAPID='+KREDILER.FieldByName('ID').AsString+
           ' and ISLEMTARIHI < '''+FormatDateTime('yyyy-mm-dd 00:00', DonemTarihi)+'''  ');

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO FATBASLIK(TARIH, TUR,TIPI,REHBERID, FATURATARIH,FATURA_MATRAHI, FATURA_TUTARI, KUR, DOVIZ_TUTARI,DOVIZ_CINSI, '+
        'MASRAFID, ACIKLAMA, EKLEYEN, DOVIZKUR, EKSTREDEKULLAN,RAPORDOVIZ,YERI,YERID,LOKASYON,GIRISKAYNAK)values('''+FormatDateTime('yyyy-mm-dd hh:nn', ValorTarih)+''',13,1,0,'+
        ''''+FormatDateTime('yyyy-mm-dd hh:nn', IslemTarih)+''','+Tablo.Query2.Fields[0].AsString+','+Float_ToStr(TUTAR)+','''+CariDoviz+''','+Float_ToStr(TUTAR)+','''+CariDoviz+''','+
      Tablo.Query1.Fields[0].AsString+','''+Aciklama+''','+Kullanan+',1.0,0,'''+CariDoviz+''','+IntToStr(TabNo_KREDILER)+','+KREDILER.FieldByName('ID').AsString+','+IntToStr(LokTipi)+',1)',[],[]);
   end;
   procedure OdemeYap(Tutar : currency);
   begin
       Tablo.TablodanSorguAc(1,'select isnull(FAIZMASRAFID,0) from KREDILER where ID='+KREDILER.FieldByName('ID').AsString);
       Tablo.KasaKaydet(32,IslemTarih,IslemTarih,0,'',KREDILER.FieldByName('BANKATICARIHESAPID').AsInteger,KREDILER.FieldByName('KUR').AsString,
             KREDILER.FieldByName('KUR').AsString, Tablo.Query1.Fields[0].AsInteger, Tutar,0,FStrToCurrDef(VarToStr(Tutar),0),0,
             -1, KREDILER.FieldByName('ID').AsInteger, -1, -1, SubeId, 'B', TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger);
   end;
begin
  BasTarihi := RotatifBaslamaTarihGetir(BasAy, BasYil);
  if Kapandi then begin
     DonemTarihi := Tablo.GENINI.BugunTrh;
     ValorTarih := DonemTarihi;
  end else begin
     DonemTarihi := RotatifDonemTarihGetir(BasAy, BasYil);
     ValorTarih := DonemTarihi+1;
  end;
 //?nce en son ne zaman ekleme yap?lm?? ona g?re bir sonraki d?nemi bulmal?y?<
  IslemTarih := DonemTarihi;
  //?nce faiz biti? tarihini alal?m
  if TGirisKutusuEx.BilgiAlEx(hesap1, TGirdiDenetimleri.Create.DateTimePicker('Biti? ??lem Tarihi', @IslemTarih, dtkDate).DateTimePicker('Val?r Tarihi', @ValorTarih, dtkDate)) = mrOk then begin
       // son i?lem tarihi alal?m
       Tablo.Query0.Close;//ba?lama ve biti? aras?ndaki t?m giren ve ??kan ?demeler i?in faiz hesaplan?r
       Tablo.Query0.SQL.Text := 'select VALOR = PLANTARIHI, ANAPARA=BORC-ALACAK '+
           ' from  KASA where TUR in (58,59)and HESAPTURU=''R'' and HESAPID='+KREDILER.FieldByName('ID').AsString+' and ISLEMTARIHI between '+
           ''''+FormatDateTime('yyyy-mm-dd 00:00', BasTarihi)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59', DonemTarihi)+''' '+
            ' union all '+//son d?nem tahakkuku da alal?m
           ' select VALOR, ANAPARA from( select top 1 VALOR = TARIH, ANAPARA=FATURA_MATRAHI from FATBASLIK where TUR=13 and YERI=47 and YERID='+KREDILER.FieldByName('ID').AsString+' and LOKASYON=131 order by 1 desc) as liste';
       Tablo.Query0.Open;
       SimdikiFaizTut := 0.0;
       while not Tablo.Query0.eof do begin
          SimdikiFaizTut := SimdikiFaizTut + FaizHesapla(False, Tablo.Query0.FieldByName('ANAPARA').AsCurrency, Tablo.Query0.FieldByName('VALOR').AsDateTime,VarToDateTime(ValorTarih)
          , 'KREDIROTATIFFAIZ', ' and KREDIID=' + KREDILER.FieldByName('ID').AsString);
          Tablo.Query0.next;
       end;
       FaizTutar := SimdikiFaizTut;
       BSMVTutar := SimdikiFaizTut*BSMV;
       if TGirisKutusuEx.BilgiAlEx(hesap1, TGirdiDenetimleri.Create.CurrencyEdit('Kredi Faizi Tutar?', @FaizTutar,2).Edit('Faiz A??klama', @FaizAciklama)
                         .CurrencyEdit('BSMV Tutar?', @BSMVTutar,2).Edit('BSMV A??klama', @BSMVAciklama)) = mrOk then
       Ekle(FaizAciklama,  FStrToCurrDef(VarToStr(FaizTutar),0),131);
       OdemeYap(FStrToCurrDef(VarToStr(FaizTutar),0));
       Ekle(BSMVAciklama,  FStrToCurrDef(VarToStr(BSMVTutar),0),132);
       OdemeYap(FStrToCurrDef(VarToStr(BSMVTutar),0));
       //Kasadan ?demeyi de ekleyelim
       EkstreGoster(CheckMasrafGoster.checked);
  end;
end;

procedure TBankaKredileriListeFrame.GridTakvimDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
    AnaForm.cxGridPopupMenu1.Grid:=GridTakvim;
    AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTakvimDBTableView1;
    AnaForm.pmGridStil.Tags.Values[GridTakvim.Name] := 'BankaKredileriListeGridi';
end;

procedure TBankaKredileriListeFrame.GridTakvimDBTableView1DblClick(Sender: TObject);
begin
  KrediEkranAc(False);
  YenileTusClick;
end;

procedure TBankaKredileriListeFrame.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
     Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TBankaKredileriListeFrame.HesaplamaTarihiPropertiesCloseUp(  Sender: TObject);
var Faiz : real;
begin
   ROTATIFDURUM.Close;
   ROTATIFDURUM.SQL.Text := StringReplace(MemoRotatSQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
   ROTATIFDURUM.SQL.Text := StringReplace(ROTATIFDURUM.SQL.Text, 'kosul3', ' KREDIID='+KREDILER.FieldByName('ID').AsString ,[RFrEPLACEaLL]) ;
    //   ROTATIFDURUM.SQL.Text := StringReplace(ROTATIFDURUM.SQL.Text, ':BASTAR', FormatDateTime('yyyy-mm-dd', FTakvimProjeler.dateProjeBaslangic.Date), [RFrEPLACEaLL]) ;
    //   ROTATIFDURUM.SQL.Text := StringReplace(ROTATIFDURUM.SQL.Text, ':BITTAR', FormatDateTime('yyyy-mm-dd', FTakvimProjeler.dateBitis.Date), [RFrEPLACEaLL]) ;
   ROTATIFDURUM.Open;

   ROTATIFDURUM.First;
   while not ROTATIFDURUM.Eof do begin
      ROTATIFDURUM.Edit;
      Faiz := RotatifHesapla(KREDILER.FieldByName('ID').AsInteger, ROTATIFDURUM.FieldByName('VALOR').AsBoolean,
                             CheckValor.Checked, ROTATIFDURUM.FieldByName('BAKIYE').AsCurrency,ROTATIFDURUM.FieldByName('TARIH').AsDateTime, HesaplamaTarihi.Date);
      ROTATIFDURUM.FieldByName('FAIZ').AsCurrency := ROTATIFDURUM.FieldByName('FAIZ').AsCurrency +Faiz+ (Faiz * BSMV);
      //ROTATIFDURUM.FieldByName('BSMV').AsCurrency := ROTATIFDURUM.FieldByName('FAIZ').AsCurrency * BSMV;
      ROTATIFDURUM.FieldByName('TOPLAM').AsCurrency := {OncekiBakiyeFaiz+}ROTATIFDURUM.FieldByName('BAKIYE').AsCurrency {+ ROTATIFDURUM.FieldByName('BSMV').AsCurrency} + ROTATIFDURUM.FieldByName('FAIZ').AsCurrency;
      ROTATIFDURUM.Post;
      ROTATIFDURUM.Next;
   end;
end;

procedure TBankaKredileriListeFrame.IptalKocanTusClick(Sender: TObject);
begin
  TabCekKocan.Cancel;
end;

procedure TBankaKredileriListeFrame.SetArama(const Value: TBankaKredileriAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;



procedure TBankaKredileriListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TBankaKredileriListeFrame.SilKocanTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabCekKocan.Delete;
end;

procedure TBankaKredileriListeFrame.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
   //e?er taksitli kredi ise taksitteki ?densi i?aretini kald?ral?m
     Tablo.KasaSilmeIslemleri(EKSTRE.FieldByName('CEKID').AsInteger,EKSTRE.FieldByName('TUR').AsInteger);
     EkstreGoster(CheckMasrafGoster.checked);
   end;
end;

procedure TBankaKredileriListeFrame.TabCekKocanBeforePost(DataSet: TDataSet);
begin
   //KO?AN ???NDEK? SER?NOLAR E?S?Z OLMALI
   Tablo.Query1.Close ;
   Tablo.Query1.SQL.Text:=' select * from cekkocan where '
     + TabCekKocan.FieldByName('BASSERINO').AsString +' BETWEEN BASSERINO AND BITSERINO OR '
     + TabCekKocan.FieldByName('BITSERINO').AsString +' BETWEEN BASSERINO AND BITSERINO ';
   Tablo.Query1.Open;
   if Tablo.Query1.RecordCount>0 then
      raise Exception.Create(serinohata);
end;

procedure TBankaKredileriListeFrame.TabCekKocanNewRecord(DataSet: TDataSet);
begin
   TabCekKocan.FieldByName('KREDIID').Value := KREDILER.FieldByName('ID').AsInteger;
   TabCekKocan.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrh;
   TabCekKocan.FieldByName('EKLEYEN').Value := Kullanan
end;

procedure TBankaKredileriListeFrame.TabSheetEkstreShow(Sender: TObject);
begin
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TBankaKredileriListeFrame.ToolButton2Click(Sender: TObject);
begin
   if KrediHesapMakineDlg = nil then
      Application.CreateForm(TKrediHesapMakineDlg, KrediHesapMakineDlg);
   KrediHesapMakineDlg.btnAktar.Visible := False;
   KrediHesapMakineDlg.showmodal;
end;

procedure TBankaKredileriListeFrame.ToolButton5Click(Sender: TObject);
begin
   Application.CreateForm(TRotatifDonemFaizDlg, RotatifDonemFaizDlg);
   RotatifDonemFaizDlg.KREDIID := KREDILER.FieldByName('ID').AsInteger;
   RotatifDonemFaizDlg.ShowModal;
   RotatifDonemFaizDlg.Destroy;
end;

procedure TBankaKredileriListeFrame.DonemOranTusClick(Sender: TObject);
begin
   Application.CreateForm(TRotatifDonemFaizDlg, RotatifDonemFaizDlg);
   RotatifDonemFaizDlg.KREDIID := KREDILER.FieldByName('ID').AsInteger;
   RotatifDonemFaizDlg.ShowModal;
   RotatifDonemFaizDlg.Destroy;
end;

procedure TBankaKredileriListeFrame.DtsCekKocanStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsCekKocan, YeniKocanTus,SilKocanTus,KaydetKocanTus,IptalKocanTus);
end;

procedure TBankaKredileriListeFrame.KrediSilTusClick(Sender: TObject);
begin
  if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KASA where  TUR=59 and KREDIID='+KREDILER.FieldByName('ID').AsString ,[],[]) or
     Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KASA where  TUR=55 and KREDIID='+KREDILER.FieldByName('ID').AsString ,[],[]) then
     Showmessage('Hareket görmüş, silinemez!')
  else begin
     if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
        if LogGun > 0 then begin  // silmeden ONCE logla (kayit dururken): detay + kart
           LogDetaylariSil('PLANKREDI','KREDIID',TabNo_KREDIPLAN,TabNo_KREDILER,KREDILER.FieldByName('ID').AsInteger);
           Tablo.OncekiLogBelirle(KREDILER);
           Tablo.LogIslemleri(TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger, 5, KREDILER);
        end;
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from PLANKREDI where KREDIID='+KREDILER.FieldByName('ID').AsString,[],[]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KREDILER where ID='+KREDILER.FieldByName('ID').AsString,[],[]);
        YenileTusClick;
     end;
  end;
end;

procedure TBankaKredileriListeFrame.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TBankaKredileriListeFrame.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TBankaKredileriListeFrame.OdemeEkleTusClick(Sender: TObject);
begin
  if KasaWizardDlg = nil then
    Application.CreateForm(TKasaWizardDlg, KasaWizardDlg);
  KasaWizardDlg.KasaTarihi.Date := Tablo.GENINI.BugunTrhSaat;
  KasaWizardDlg.WizardKontrol.SelectFirstPage;
  KasaWizardDlg.SecIslem := 58;
  KasaWizardDlg.IslemSecildi;
  KasaWizardDlg.ShowModal;
  KasaWizardDlg.destroy;
end;

procedure TBankaKredileriListeFrame.OdemeSilTusClick(Sender: TObject);
begin
   if (KREDIROTATIF.FieldByName('TUTAR').AsCurrency>0)and(Application.MessageBox(PChar(KKrediBilgisiSilinsinmi),PChar(Onay), MB_YESNO) = IDYES) then begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where KREDIID='+KREDILER.FieldByName('ID').AsString+' and YERI='+IntToStr(TabNo_KREDIROTATIF)+
                ' and YERID='+KREDIROTATIF.FieldByName('ID').AsString, [], []);
         KREDIROTATIF.Delete;
   end;
end;

procedure TBankaKredileriListeFrame.AnaparaEkleTusClick(Sender: TObject);
var
  Tarih, RefNo, Tutar, Aciklama : Variant;
  ctrls : TGirdiDenetimleri;
  ID,ID2: integer;
  KurDegeri : real;
  Tutar2 : currency;
begin
  Tarih := Tablo.GENINI.BugunTrhSaat;
  ctrls := TGirdiDenetimleri.Create.DateTimePicker('??lem Tarihi', @Tarih, dtkDate).Edit('Referans No', @RefNo).CurrencyEdit('Tutar', @Tutar,2).Edit('A??klama', @Aciklama);
  if TGirisKutusuEx.BilgiAlEx(BGKredi_giris, ctrls) = mrOk then begin

     //giri? veya ??k?? yaparken arada d?nem var m? bakal?m
     if EKSTRE.RecordCount >0 then
        while RotatifDonemVar(VarToDateTime(Tarih)) do
              RotatifFaizMasrafEkle;

      if KREDILER.FieldByName('KUR').AsString=CariDoviz then
          KurDegeri := 1
      else
          KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', VarToDateTime(Tarih)), KREDILER.FieldByName('KUR').AsString,
                                      Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));

      Tutar2 := FStrToCurrDef(VarToStr(Tutar),0);
      ID:=Tablo.KasaKaydet(59, VarToDateTime(Tarih), VarToDateTime(Tarih) ,0,
              KREDILER.FieldByName('ADI').AsString, KREDILER.FieldByName('ID').AsInteger,
              KREDILER.FieldByName('KUR').AsString, CariDoviz,0,Tutar2,0,Tutar2*KurDegeri,-1,
              /// Rotatifin ID'sini fatura id'ye Kredinin Id sini de kredi Id ye atar?z
              -1, KREDILER.FieldByName('ID').AsInteger,-1,-1,SubeId,'R',0,0,RefNo); // HesapTuru
      //if Tablo.UyariGoster('??leme Devam Ediliyor','Kredi kayd? ba?ar?yla eklendi.'+#13#10+' Tutar ilgili banka hesab?na da yat?r?ls?n m??',2)=MrYes then begin
        ID2:=Tablo.KasaKaydet(59, VarToDateTime(Tarih), VarToDateTime(Tarih),0,
                KREDILER.FieldByName('ADI').AsString, KREDILER.FieldByName('BANKATICARIHESAPID').AsInteger,
                KREDILER.FieldByName('KUR').AsString, CariDoviz,0,0,Tutar2,Tutar2*KurDegeri,-1,
                /// Rotatifin ID'sini fatura id'ye Kredinin Id sini de kredi Id ye atar?z
                -1, KREDILER.FieldByName('ID').AsInteger,-1,ID,SubeId,'B',0,0,RefNo); // HesapTuru
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set GERIDONUSID='+IntToStr(ID2)+' where ID='+IntToStr(ID),[],[]);
      //end;
  end;
  YenileTusClick;
end;

procedure TBankaKredileriListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankaKredileriListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TBankaKredileriListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankaKredileriListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TBankaKredileriListeFrame.YeniTusClick(Sender: TObject);
begin
  KrediEkranAc(True);
  YenileTusClick;
end;

procedure TBankaKredileriListeFrame.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Krediler);
end;

initialization
  RegisterClass(TBankaKredileriListeFrame);
end.





unit UKrediler;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, DB, FireDAC.Comp.Client, StdCtrls, DBCtrls, Mask, Buttons, Grids,
  DBGrids, cxSpinEdit, cxDBEdit, cxCurrencyEdit, cxControls, cxContainer,
  cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, ComCtrls, dxCore,
  cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData,
  cxButtonEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxDateUtils,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxCheckBox, frxDBSet,
  cxImageComboBox, ToolWin, cxLabel, UGentegreFrameYonetimi, cxLookAndFeelPainters,
  cxButtons, UBankaKredileriAramaFrame, dxSkinsCore, dxBarBuiltInMenu,Vcl.ImgList,
  UFrameYoneticisi, frxClass, cxPC, cxDBLabel, dxSkinLondonLiquidSky, cxNavigator,ComObj,
  dxSkinscxPCPainter,Utablo, cxLookAndFeels, cxPCdxBarPopupMenu, dxSkinLiquidSky,
  cxMemo, cxGridCustomPopupMenu, cxGridPopupMenu, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, OfficePopupMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  System.ImageList, cxImageList, dxCoreGraphics, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Generics.Collections;

type
  TKredilerDlg = class(TFrame,IIcerikBilgiFrame,IBilgiFrame,IPopupDialog )//IAracCubuguDestegi)
    Panel5: TPanel;
    DtsKrediler: TDataSource;
    KREDILER: TFDQuery;
    PopupMenu1: TPopupMenu;
    KrediyiEkleMenu: TMenuItem;
    Label25: TcxLabel;
    Label26: TcxLabel;
    Label31: TcxLabel;
    Label33: TcxLabel;
    Label36: TcxLabel;
    btnKrediNotlari: TSpeedButton;
    Label32: TcxLabel;
    Label34: TcxLabel;
    Label35: TcxLabel;
    Label4: TcxLabel;
    SpeedButton1: TSpeedButton;
    PLANKREDI: TFDQuery;
    DtsOdemeTakvimi: TDataSource;
    PopupMenu2: TPopupMenu;
    PlanSilMenu: TMenuItem;
    ToolBar2: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton4: TToolButton;
    btnKapat: TToolButton;
    Panel3: TPanel;
    Label2: TcxLabel;
    Label7: TcxLabel;
    EditADI: TcxDBTextEdit;
    ComboDURUM: TcxDBImageComboBox;
    PageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    TabSheetKrediOranlari: TcxTabSheet;
    TabSheetGeriOdemePlani: TcxTabSheet;
    ComboTEMINAT: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    EditKREDILIMITSURE: TcxDBDateEdit;
    PanelTarihler: TPanel;
    Label12: TcxLabel;
    Label17: TcxLabel;
    EditALINISTARIHI: TcxDBLabel;
    EditKAPANISTARIHI: TcxDBLabel;
    EditLimitSure: TcxDBSpinEdit;
    ComboKrediLimitTipi: TcxDBImageComboBox;
    CheckEkLimit: TcxDBCheckBox;
    EditKREDILIMIT: TcxDBCurrencyEdit;
    Label43: TcxLabel;
    Label15: TcxLabel;
    Label13: TcxLabel;
    Label11: TcxLabel;
    Label10: TcxLabel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel2: TBevel;
    Bevel1: TBevel;
    KrediHesapTus: TSpeedButton;
    Label18: TcxLabel;
    Label19: TcxLabel;
    Label20: TcxLabel;
    Label21: TcxLabel;
    Label28: TcxLabel;
    Label22: TcxLabel;
    Label23: TcxLabel;
    Label24: TcxLabel;
    Label27: TcxLabel;
    Label41: TcxLabel;
    EditTUTARI: TcxDBCurrencyEdit;
    EditMASRAFKOMISYON: TcxDBCurrencyEdit;
    EitFAIZORANI: TcxDBTextEdit;
    EditBSMV: TcxDBTextEdit;
    EditKKDF: TcxDBTextEdit;
    EditKREDITAKSIT: TcxDBSpinEdit;
    GridGeriOdeme: TcxGrid;
    PlanTview: TcxGridDBTableView;
    ColumnSozId: TcxGridDBColumn;
    ColumnTarih: TcxGridDBColumn;
    ColumnTAKSIT: TcxGridDBColumn;
    ColumnKDVSIZ: TcxGridDBColumn;
    ColumnANAPARA: TcxGridDBColumn;
    ColumnFAIZ: TcxGridDBColumn;
    ColumnKKDF: TcxGridDBColumn;
    ColumnBSMV: TcxGridDBColumn;
    ColumnBAKIYE: TcxGridDBColumn;
    ColumnKur: TcxGridDBColumn;
    ColumnACIKLAMA: TcxGridDBColumn;
    ColumnODENMIS: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    ComboKREDITURU: TcxDBImageComboBox;
    EditSOZLESMENO: TcxDBTextEdit;
    Label6: TcxLabel;
    Label38: TcxLabel;
    EdiBANKATICARIHESAPKODU: TcxButtonEdit;
    EditTicariHsId: TcxDBTextEdit;
    EditHesapAdiTicari: TcxTextEdit;
    Label5: TcxLabel;
    cxLabel5: TcxLabel;
    ComboMasraf: TcxButtonEdit;
    EditMasraf: TcxTextEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    KrediDetayCheck: TcxDBCheckBox;
    ComboKur: TcxDBComboBox;
    cxLabel6: TcxLabel;
    ComboFaizMasraf: TcxButtonEdit;
    EditFaizMasraf: TcxTextEdit;
    cxDBTextEdit2: TcxDBTextEdit;
    EditBanka: TcxTextEdit;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    EditHesap: TcxTextEdit;
    cxLabel9: TcxLabel;
    EditSube: TcxTextEdit;
    cxLabel15: TcxLabel;
    ComboGelir: TcxButtonEdit;
    EditGelir: TcxTextEdit;
    cxDBTextEdit3: TcxDBTextEdit;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem2: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem3: TMenuItem;
    EMail1: TMenuItem;
    MenuItem4: TMenuItem;
    YaziciYaz: TToolButton;
    frxKREDILER: TfrxDBDataset;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    EditTAKSIT: TcxDBCurrencyEdit;
    cxLabel10: TcxLabel;
    TextEditKREDITAKSIT: TcxDBLabel;
    Label16: TcxLabel;
    LabelKalanAdet: TcxLabel;
    cxLabel13: TcxLabel;
    EditOdenen: TcxCurrencyEdit;
    EditKalan2: TcxCurrencyEdit;
    EditOdenen2: TcxCurrencyEdit;
    cxLabel14: TcxLabel;
    EditKalan: TcxCurrencyEdit;
    cxLabel12: TcxLabel;
    cxLabel11: TcxLabel;
    N1: TMenuItem;
    IsaretlisatrlarOdendiolarakkabuletMenu: TMenuItem;
    ColumnID: TcxGridDBColumn;
    EditKREDIKODU: TcxDBButtonEdit;
    PlanTviewColumn1: TcxGridDBColumn;
    ImageListKredi: TcxImageList;
    DateALINISTARIHI: TcxDBDateEdit;
    Label14: TcxLabel;
    cxLabel3: TcxLabel;
    cxDBDateEdit1: TcxDBDateEdit;
    Label42: TcxLabel;
    DateKAPANISTARIHI: TcxDBDateEdit;
    ExceldenVeriAlMenu: TMenuItem;
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
    EditProje: TcxButtonEdit;
    LabelProjeKodu: TcxLabel;
    procedure DtsKredilerStateChange(Sender: TObject);
    procedure KREDILERNewRecord(DataSet: TDataSet);
    procedure DtsKredilerDataChange(Sender: TObject; Field: TField);
    procedure KREDIROTATIFAfterPost(DataSet: TDataSet);
    procedure KREDILERBeforePost(DataSet: TDataSet);
    procedure KREDIROTATIFBeforeEdit(DataSet: TDataSet);
    procedure KrediEkleTusClick(Sender: TObject);
    procedure OdemeEkleTusClick(Sender: TObject);
    procedure PlanSilMenuClick(Sender: TObject);
    procedure KREDILERAfterScroll(DataSet: TDataSet);
    procedure FrameResize(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure EdiBANKATICARIHESAPKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KrediHesapTusClick(Sender: TObject);
    procedure ComboMasrafPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KREDILERAfterPost(DataSet: TDataSet);
    procedure ComboFaizMasrafPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KREDILERBeforeDelete(DataSet: TDataSet);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure IsaretlisatrlarOdendiolarakkabuletMenuClick(Sender: TObject);
    procedure EditKREDIKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure PLANKREDIBeforePost(DataSet: TDataSet);
    procedure PLANKREDIAfterPost(DataSet: TDataSet);
    procedure cxDBImageComboBox1PropertiesCloseUp(Sender: TObject);
    procedure ExceldenVeriAlMenuClick(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
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
    procedure EditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KREDILERAfterOpen(DataSet: TDataSet);
    procedure KREDILERBeforeEdit(DataSet: TDataSet);
    procedure PlanTviewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    { IBilgiFrame �yeleri            }
    FDetSnap: TObjectDictionary<Integer, TStringList>;  // PLANKREDI (detay) orijinal satirlar (log diff icin)
    FYeniKredi: Boolean;                                // kart EKLEME mi (yeni) yoksa DUZENLEME mi
    FEkleLogland: Boolean;                              // ekleme logu tek sefer (kaydet VEYA kapanis fallback)
    FFrameBilgi : TIcerikFrameBilgi;
    FKapatEylemi: TNotifyEvent;
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
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    { Gezinme ve yazd�rma deste�i }
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
    {********************************}
    procedure KrediLeasingHesaplayiciIptalClick(Sender: TObject);
    function BoslukKontrolu: Boolean;
    procedure Kasaya_KRedi_Kaydet(ToplamFaiz : Currency);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    procedure KrediEkranInit(AKrediId: Integer);
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
  end;

var
  KredilerDlg: TKredilerDlg;

implementation

{$R *.dfm}
uses UAnaForm, UKasaWizard, UKrediEkle, FetaClassExtensions, UAramaYokFrame,PrjConst,LocOnFly,
     FetaKurulusSiniflari, UKrediHesapMakineDlg, UFastRap, URaporAraclari, UGenelAnaSekmeFrame, UBekletme, UExceldenVeriAl,
     ULog;

var YeniKayit : Boolean;

destructor TKredilerDlg.Destroy;
begin
  // FALLBACK: yeni kredi (FYeniKredi) DB'ye yazilmis (dsBrowse, ID>0) ama kaydette
  // loglanmadiysa (kaydedip/kaydetmeden X ile kapanis) ekleme logunu kapanista
  // TEK SEFER garanti et. FEkleLogland zaten True ise dokunma (mukerrer onleme).
  if (LogGun > 0) and FYeniKredi and (not FEkleLogland) and
     KREDILER.Active and (KREDILER.State = dsBrowse) and
     (KREDILER.FieldByName('ID').AsInteger > 0) then begin
    LogKayitEkle(KREDILER, TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger,
                 TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger);
    FEkleLogland := True;
  end;
  FreeAndNil(FDetSnap);
  inherited;
end;

procedure TKredilerDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TKredilerDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger]);
  end;
end;

procedure TKredilerDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
            TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, KREDILER.FieldByName('ID').AsInteger)
end;

procedure TKredilerDlg.DtsKredilerDataChange(Sender: TObject; Field: TField);
begin
  PageControl1.Pages[1].TabVisible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger in [1,11]; //taksit ve leasing
  PageControl1.Pages[2].TabVisible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger in [1,11];

  PanelTarihler.Visible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger in [1,11];
  if KREDILER.FieldByName('GENELKREDITIPI').AsInteger=2  then begin     //Rotatif

  end else begin
    Tabloyenile(PLANKREDI,[KREDILER.FieldByName('ID').AsInteger]);
    PlanTview.ApplyBestFit(nil);
    // Kredi yuklendikten sonra (kayit degisimi -> Field=nil) PLANKREDI orijinal snapshot'i.
    if (Field = nil) and (LogGun > 0) then
       LogSnapshotAl(PLANKREDI, FDetSnap);
  end;
  if KREDILER.FieldByName('GENELKREDITIPI').AsInteger=11  then begin       //   'Leasing'
    PlanTview.GetColumnByFieldName('TAKSIT').Caption := 'KDV li Kira';
    PlanTview.GetColumnByFieldName('KDVSIZ').Visible := True;
    PlanTview.GetColumnByFieldName('KKDF').Visible := False;
    PlanTview.GetColumnByFieldName('BSMV').Visible := False;
  end else begin
    PlanTview.GetColumnByFieldName('TAKSIT').Caption := 'Taksit';
    PlanTview.GetColumnByFieldName('KDVSIZ').Visible := False;
    PlanTview.GetColumnByFieldName('KKDF').Visible := True;
    PlanTview.GetColumnByFieldName('BSMV').Visible := True;
  end;
end;

procedure TKredilerDlg.DtsKredilerStateChange(Sender: TObject);
begin
    Tablo.NavTusGoruntule(DtsKrediler, EkleTus,SilTus,KaydetTus,IptalTus);
end;

function TKredilerDlg.EkranAdiAl: string;
begin
  Result := 'KredilerDlg';
end;

procedure TKredilerDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar2.Owner), DokumAdi, EkranAdi, frxKREDILER) then
      AFastReport.EnabledDataSets.Add(frxKREDILER)
   else begin
      frxKREDILER.DataSet := KREDILER;
      AFastReport.EnabledDataSets.Add(frxKREDILER);
   end;
end;

procedure TKredilerDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
   DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdi, DokumAdi);
end;

procedure TKredilerDlg.Baslatildi;
var ra : string;
begin
  Tablo.GridTurkcelestir;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y�kleniyor.
  Pagecontrol1.ActivePageIndex:=0;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

   Tablo.GENINI.ReadImageSection(Ops_OpsiyonBanka_KrediTeminat, ComboTEMINAT.Properties.Items, False);
   Tablo.GENINI.ReadImageSection(Ops_OpsiyonBanka_KrediLimitSureTipi, ComboKrediLimitTipi.Properties.Items, False);

   Tablo.GridAyarRestore('KrediGeriOdemeGridi', PlanTview);


   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,
       TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;
end;

procedure TKredilerDlg.btnKapatClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
    FKapatEylemi(Self);
end;

procedure TKredilerDlg.BtnMesajGonderClick(Sender: TObject);
begin
   Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger, KREDILER.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TKredilerDlg.ComboFaizMasrafPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
   if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      KREDILER.Edit;
      KREDILER.FieldByName('FAIZMASRAFID').AsString := MASRAFID;
      ComboFaizMasraf.Text := MASRAFKODU;
      EditFaizMasraf.text:= MASRAFMERKEZI;
   end
end;

procedure TKredilerDlg.ComboMasrafPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
   KREDILER.Edit;
   if AButtonIndex=1 then begin
      KREDILER.FieldByName('MASRAFID').AsString := '-1';
      ComboMasraf.Text := '';
      EditMasraf.text:= '';
   end
   else if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      KREDILER.FieldByName('MASRAFID').AsString := MASRAFID;
      ComboMasraf.Text := MASRAFKODU;
      EditMasraf.text:= MASRAFMERKEZI;
   end
end;

constructor TKredilerDlg.Create(AOwner: TComponent);
begin
  inherited;
  FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
  FEkleLogland := False;
  PageControl1.ActivePageIndex := 0;
end;

procedure TKredilerDlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
  KREDILER.Edit;
  if AButtonIndex=1 then begin
    KREDILER.FieldByName('GELIRID').AsString := '-1';
    ComboGelir.Text := MASRAFKODU;
    EditGelir.text:= MASRAFMERKEZI;
  end else if Tablo.MasrafMerkeziSecimEkrani(1, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
    KREDILER.FieldByName('GELIRID').AsString := MASRAFID;
    ComboGelir.Text := MASRAFKODU;
    EditGelir.text:= MASRAFMERKEZI;
  end
end;

procedure TKredilerDlg.cxDBImageComboBox1PropertiesCloseUp(Sender: TObject);
begin
   EditTAKSIT.Visible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger=1;
   //(pos ('Taksit',ComboKREDITURU.Text)>0)or(pos ('TAKS�T',ComboKREDITURU.Text)>0);
   Label16.Visible := EditTAKSIT.Visible;
end;

procedure TKredilerDlg.EdiBANKATICARIHESAPKODUPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var
  HESAPID,HESAPKODU, HESAPADI, HESAPNO,KUR: string;
  tempquery:TDataSet;
begin
  HESAPID :='-1';
  if Tablo.BankaHesapEkrani(33, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
    KREDILER.Edit;
    KREDILER.FieldByName('BANKATICARIHESAPID').AsString := HESAPID;
    KREDILER.FieldByName('KUR').AsString := KUR;
    tempquery:=Tablo.HesapBilgisiGetirDetay(KREDILER.FieldByName('BANKATICARIHESAPID').AsInteger);
    EdiBANKATICARIHESAPKODU.Text := tempquery.FieldByName('HESAPKODU').AsString;
    EditHesapAdiTicari.Text  := tempquery.FieldByName('HESAPADI').AsString;
    EditBanka.Text  := tempquery.FieldByName('BANKAADI').AsString;
    EditHesap.Text  := tempquery.FieldByName('HESAPNO').AsString;
    EditSube.Text  := tempquery.FieldByName('SUBEKODU').AsString;
    ComboKur.Text := KUR;
  end;
end;

procedure TKredilerDlg.EditKREDIKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  KREDILER.Edit;
  KREDILER.FieldByName('KREDIKODU').AsString := Tablo.KodBulmaSihirbazi(400, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI','KREDILER' ,'KREDIKODU',400);
end;

procedure TKredilerDlg.EditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(EditProje, KREDILER, AButtonIndex, ProjeSecimi, KREDILER.FieldByName('REHBERID').AsInteger);
end;

procedure TKredilerDlg.EkleTusClick(Sender: TObject);
begin
   KREDILER.Append;
end;

procedure TKredilerDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TKredilerDlg.ExceldenVeriAlMenuClick(Sender: TObject);
begin
   if KREDILER.state in [dsEdit, dsInsert] then
      KREDILER.post;

   Excel2KrediPlan(KREDILER.Fields[0].AsInteger, KREDILER.FieldByName('ALINISTARIHI').AsDateTime);
   Tabloyenile(PLANKREDI,[KREDILER.FieldByName('ID').AsInteger]);
   Listele;
   PlanTview.applyBestFit(nil);
end;

procedure TKredilerDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKredilerDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKredilerDlg.FrameResize(Sender: TObject);
begin
  btnKapat.Left := Width - btnKapat.Width - 5;
end;

function TKredilerDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKredilerDlg.GetKapatilabilir: Boolean;
begin

end;


procedure TKredilerDlg.Gorunmez;
begin

end;

procedure TKredilerDlg.GorunmezOlacak;
begin

end;

procedure TKredilerDlg.Gorunur;
begin
end;

procedure TKredilerDlg.GorunurOlacak;
begin

end;

procedure TKredilerDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TKredilerDlg.IptalTusClick(Sender: TObject);
begin
   KREDILER.Cancel;
end;

procedure TKredilerDlg.IsaretlisatrlarOdendiolarakkabuletMenuClick(Sender: TObject);
var
  i,Recordindex,ID:integer;
begin
{  if PlanTview.DataController.GetSelectedCount > 0 then begin
    for I := 0 to PlanTview.DataController.GetSelectedCount - 1 do begin
      Recordindex := PlanTview.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
      ID := PlanTview.DataController.Values[Recordindex,ColumnID.Index];
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update PLANKREDI set ODENMIS=1 where ID=&Id and KREDIID=&Kid  ',['&Id','&Kid'],[ID,KREDILER.Fields[0].AsInteger]);
    end;
    PLANKREDI.Close;
    PLANKREDI.Open;
  end; }
end;

procedure TKredilerDlg.KREDILERAfterOpen(DataSet: TDataSet);
begin
   EditProje.Text := Tablo.AciklamaGetir('PROJELER', 'PROJEKODU', KREDILER.FieldByName('PROJEID').Value);
   EditProje.Tag := StrToIntDef(KREDILER.FieldByName('PROJEID').AsString,0);
end;

procedure TKredilerDlg.KREDILERBeforeEdit(DataSet: TDataSet);
begin
   // Duzenleme oncesi orijinal kart degerlerini sakla (LogIslemleri diff icin).
   if LogGun > 0 then
      Tablo.OncekiLogBelirle(KREDILER);
end;

procedure TKredilerDlg.KREDILERAfterPost(DataSet: TDataSet);
begin
  //Kredi hat�rlatma aktivitesi olu�tural�m
//  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM AKTIVITELER WHERE YERI=250205 and YER_ID=&YERID',['&YERID'],[KREDILER.FieldByName('ID').AsString]);
//  Tablo.SablondanAktiviteOlustur(250205,KREDILER.FieldByName('ID').AsInteger,cxDBDateEdit1.Date,[EditADI.Text+' Kredisi.'])
end;

procedure TKredilerDlg.KREDILERAfterScroll(DataSet: TDataSet);
var
  tempquery:TDataSet;
begin
  tempquery:=Tablo.HesapBilgisiGetirDetay(KREDILER.FieldByName('BANKATICARIHESAPID').AsInteger);
  EdiBANKATICARIHESAPKODU.Text := tempquery.FieldByName('HESAPKODU').AsString;
  EditHesapAdiTicari.Text  := tempquery.FieldByName('HESAPADI').AsString;
  EditBanka.Text  := tempquery.FieldByName('BANKAADI').AsString;
  EditHesap.Text  := tempquery.FieldByName('HESAPNO').AsString;
  EditSube.Text  := tempquery.FieldByName('SUBEKODU').AsString;
  EditTAKSIT.Visible := KREDILER.FieldByName('GENELKREDITIPI').AsInteger=1;
  //(pos ('Taksit',ComboKREDITURU.Text)>0)or(pos ('TAKS�T',ComboKREDITURU.Text)>0);
  Label16.Visible := EditTAKSIT.Visible;
  EditTAKSIT.Properties.ReadOnly := (PLANKREDI.Active)and(PLANKREDI.RecordCount>0);

  if KREDILER.FieldByName('ID').AsString<>'' then begin
    Tablo.TablodanSorguAc(3,'select ODENENSAY=sum(case when ODENMIS=1 then 1 else 0 end), '
                                +'ODENMEYENSAY=sum(case when ODENMIS=1 then 0 else 1 end), '
                                +'ODENEN=sum(case when ODENMIS=1 then TAKSIT else 0 end), '
                                +'KALAN=sum(case when ODENMIS=1 then 0 else TAKSIT end) ,TAKSIT=MAX(TAKSIT), '
                                +'ODENENANA=sum(case when ODENMIS=1 then ANAPARA else 0 end), '
                                +'KALANANA=sum(case when ODENMIS=1 then 0 else ANAPARA end) '
                                +'from PLANKREDI where KREDIID='+KREDILER.FieldByName('ID').AsString);

    LabelKalanAdet.Caption:= '�denen('+Tablo.Query3.FieldByName('ODENENSAY').AsString+') / Kalan('+Tablo.Query3.FieldByName('ODENMEYENSAY').AsString+')' ;
    EditOdenen.Value:= Tablo.Query3.FieldByName('ODENEN').AsCurrency ;
    EditKalan.Value:= Tablo.Query3.FieldByName('KALAN').AsCurrency ;
    EditOdenen2.Value:= Tablo.Query3.FieldByName('ODENENANA').AsCurrency ;
    EditKalan2.Value:= Tablo.Query3.FieldByName('KALANANA').AsCurrency ;
  end;

  if KREDILER.FieldByName('GELIRID').AsString<>'' then begin
    ComboGelir.Text := Tablo.AciklamaGetir( 'MASRAFGELIR', 'KOD', KREDILER.FieldByName('GELIRID').AsInteger);
    EditGelir.Text:= Tablo.AciklamaGetir( 'MASRAFGELIR', 'AD', KREDILER.FieldByName('GELIRID').AsInteger);
  end;
  if KREDILER.FieldByName('MASRAFID').AsString<>'' then begin
    ComboMasraf.Text := Tablo.AciklamaGetir( 'MASRAFGELIR', 'KOD', KREDILER.FieldByName('MASRAFID').AsInteger);
    EditMasraf.Text:= Tablo.AciklamaGetir( 'MASRAFGELIR', 'AD', KREDILER.FieldByName('MASRAFID').AsInteger);
  end;
  if KREDILER.FieldByName('FAIZMASRAFID').AsString<>'' then begin
    ComboFaizMasraf.Text := Tablo.AciklamaGetir( 'MASRAFGELIR', 'KOD', KREDILER.FieldByName('FAIZMASRAFID').AsInteger);
    EditFaizMasraf.Text:= Tablo.AciklamaGetir( 'MASRAFGELIR', 'AD', KREDILER.FieldByName('FAIZMASRAFID').AsInteger);
  end;

  Tabloyenile(TabYorum,[TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger]);
end;

function TKredilerDlg.BoslukKontrolu: Boolean;
begin
   BoslukKontrolu := True;
   if not BoslukKontrol(EditKREDIKODU.text, KontrolKrediKodu) then Abort;
   if not BoslukKontrol(EditADI.text, KontrolKrediAdi) then Abort;
   if not BoslukKontrol(EditSOZLESMENO.text, KontrolSozlesmeNo) then Abort;
   if not BoslukKontrol(ComboDURUM.text, 'Durum') then Abort;
   if not BoslukKontrol(ComboKREDITURU.text, KontrolKrediTuru) then Abort;
   if not BoslukKontrol(EditTicariHsId.text, KontrolBankaKoduTicari) then Abort;
//   if not BoslukKontrol(ComboKrediLimitTipi.text, KontrolLimitTipi) then Abort;
//   if not BoslukKontrol(EditKREDILIMIT.text, KontrolLimit) then Abort;
//   if not BoslukKontrol(ComboTEMINAT.text,KontrolTeminati) then Abort;
//   if not BoslukKontrol(EditKREDILIMITSURE.text, KontrolLimitSuresi) then Abort;
//   if not BoslukKontrol(EditLimitSure.text, KontrolKullanimSuresi) then Abort;
   //if not BoslukKontrol(ComboGelir.text, KontrolGelir) then Abort;
   //if not BoslukKontrol(ComboMasraf.text, KontrolMasraf) then Abort;
   if not BoslukKontrol(ComboFaizMasraf.text, KontrolMasraf) then Abort;
   BoslukKontrolu := False;
end;

procedure TKredilerDlg.KREDILERBeforeDelete(DataSet: TDataSet);
begin
   //rehberden sil
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where TUR = 59 and KREDIID = &id ',['&id'],[KREDILER.FieldByName('ID').AsInteger]);
   //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBER where ID = &id ',['&id'],[KREDILER.FieldByName('REHBERID').AsInteger]);
end;

procedure TKredilerDlg.KREDILERBeforePost(DataSet: TDataSet);
begin
   BoslukKontrolu;
   EkleyenDegistiren(DtsKrediler);
end;

procedure TKredilerDlg.KREDILERNewRecord(DataSet: TDataSet);
begin
   FYeniKredi := True;   // yeni kredi -> kaydette EKLEME loglanacak
   FEkleLogland := False;   // yeni insert basladi -> ekleme logu (kaydet/fallback) yeniden garanti
   KREDILER.FieldByName('ALINISTARIHI').AsDateTime := Tablo.Genini.BugunTrhSaat;
   KREDILER.FieldByName('GENELKREDITIPI').AsInteger:= 0;
   KREDILER.FieldByName('EKLEYEN').AsString := Kullanan;
   KREDILER.FieldByName('DURUM').AsBoolean:= True;// ComboDURUM.Items[0];
   KREDILER.FieldByName('KASAYA_DETAYLI').AsBoolean:= False;
   KREDILER.FieldByName('MASRAFID').AsInteger:= -1;
   KREDILER.FieldByName('BSMV').AsInteger:= 5;
   KREDILER.FieldByName('SUBEID').AsInteger := SubeID;
   EditKREDIKODU.SetFocus;
   KREDILER.FieldByName('KREDIKODU').AsString:= Tablo.KodBulmaSihirbazi(400, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI','KREDILER' ,'KREDIKODU',400);
   ComboMasraf.text := '';
   EditMasraf.text := '';
   ComboGelir.text := '';
   EditGelir.text := '';
   ComboFaizMasraf.text := '';
   EditFaizMasraf.text := '';
end;

procedure TKredilerDlg.KREDIROTATIFAfterPost(DataSet: TDataSet);
begin
   if YeniKayit then
      KrediyiEkleMenu.Click;
end;
procedure TKredilerDlg.KREDIROTATIFBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit := False;
end;

procedure TKredilerDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TKredilerDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TKredilerDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TKredilerDlg.KaydetTusClick(Sender: TObject);
var
  Yeni: Boolean;
  KID: Integer;
begin
   Yeni := FYeniKredi or (KREDILER.State = dsInsert);
   // Gercek degisiklik yoksa (Modified=False) Post etme -> gereksiz DEGISTIREN/log olmasin.
   if (KREDILER.State = dsInsert) or KREDILER.Modified then
      KREDILER.Post
   else if KREDILER.State = dsEdit then
      KREDILER.Cancel;

   KID := KREDILER.FieldByName('ID').AsInteger;

   // KART loglama (TEK SEFER, kaydette): yeni -> LogKayitEkle, edit -> LogIslemleri.
   if LogGun > 0 then begin
      if Yeni then begin
         if not FEkleLogland then begin
            LogKayitEkle(KREDILER, TabNo_KREDILER, KID, TabNo_KREDILER, KID);
            FEkleLogland := True;
         end;
      end
      else
         Tablo.LogIslemleri(TabNo_KREDILER, KID, 4, KREDILER);
      // DETAY: PLANKREDI satir ekleme/degisiklik/silme diff (ust = kredi).
      LogDiffKaydet(PLANKREDI, FDetSnap, TabNo_KREDIPLAN, TabNo_KREDILER, KID);
      LogSnapshotAl(PLANKREDI, FDetSnap);   // snapshot'i tazele (mukerrer save engeli)
   end;

   FYeniKredi := False;
end;

procedure TKredilerDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKredilerDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKredilerDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKredilerDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKredilerDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_KREDILER);
end;

procedure TKredilerDlg.KrediEkleTusClick(Sender: TObject);
begin
   if KREDILER.State = dsInsert then
      KREDILER.Post;
   Application.CreateForm(TKrediEkleDlg, KrediEkleDlg);
   KrediEkleDlg.KrediID := KREDILER.FieldByName('ID').AsInteger;
   KrediEkleDlg.ShowModal;

end;

procedure TKredilerDlg.KrediEkranInit(AKrediId: Integer);
begin
  KREDILER.Close;
  if AKrediId <> -1 then begin
    if AKrediId = -2 then
      KREDILER.SQL.Text := 'SELECT TOP 1 * FROM KREDILER ORDER BY ID DESC'
    else begin
      KREDILER.SQL.Text := 'SELECT * FROM KREDILER WHERE ID = :ID';
      KREDILER.Params.ParamByName('ID').AsInteger := AKrediId;
    end;
  end else { Yani -1 -> Bo� Kredi Ekran� i�in bo� bir query }
    KREDILER.SQL.Text := 'SELECT TOP 0 * FROM KREDILER';
  KREDILER.Open;
end;

procedure TKredilerDlg.Kasaya_KRedi_Kaydet(ToplamFaiz : Currency);
var
  ID, ID2, ID3 : Integer;
  HesapTuru : Char;
  KurDegeri : real;
begin
   if KREDILER.FieldByName('KUR').AsString = CariDoviz then//TL ise
      KurDegeri := 1
    else
      KurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', KREDILER.FieldByName('ALINISTARIHI').AsDateTime), KREDILER.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
  HesapTuru := 'R';
  ID:=Tablo.KasaKaydet(59, DateALINISTARIHI.Date, DateALINISTARIHI.Date ,0,
        KREDILER.FieldByName('ADI').AsString+'', KREDILER.FieldByName('ID').AsInteger,
        KREDILER.FieldByName('KUR').AsString, CariDoviz ,KREDILER.FieldByName('GELIRID').AsInteger,KREDILER.FieldByName('TUTARI').AsCurrency,
        0, KREDILER.FieldByName('TUTARI').AsCurrency*KurDegeri,-1,
        /// Rotatifin ID'sini fatura id'ye Kredinin Id sini de kredi Id ye atar�z
        KREDILER.FieldByName('ID').AsInteger, KREDILER.FieldByName('ID').AsInteger,-1,-1,SubeId,HesapTuru); // HesapTuru

  ID2:=Tablo.KasaKaydet(59, DateALINISTARIHI.Date, DateALINISTARIHI.Date ,0,
        KREDILER.FieldByName('ADI').AsString+'(Faiz)', KREDILER.FieldByName('ID').AsInteger,
        KREDILER.FieldByName('KUR').AsString,'TL',KREDILER.FieldByName('GELIRID').AsInteger,ToplamFaiz,0,ToplamFaiz*KurDegeri,-1,
        /// Rotatifin ID'sini fatura id'ye Kredinin Id sini de kredi Id ye atar�z
        KREDILER.FieldByName('ID').AsInteger, KREDILER.FieldByName('ID').AsInteger,-1,ID,SubeId,HesapTuru); // HesapTuru
  HesapTuru := 'B';
  ID3:=Tablo.KasaKaydet(59, DateALINISTARIHI.Date, DateALINISTARIHI.Date ,0,
        KREDILER.FieldByName('ADI').AsString, KREDILER.FieldByName('BANKATICARIHESAPID').AsInteger,
        KREDILER.FieldByName('KUR').AsString, CariDoviz,KREDILER.FieldByName('GELIRID').AsInteger,0,KREDILER.FieldByName('TUTARI').AsCurrency,
        KREDILER.FieldByName('TUTARI').AsCurrency*KurDegeri,-1,
        /// Rotatifin ID'sini fatura id'ye Kredinin Id sini de kredi Id ye atar�z
        KREDILER.FieldByName('ID').AsInteger, KREDILER.FieldByName('ID').AsInteger,-1, ID2, SubeId,HesapTuru); // HesapTuru
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set GERIDONUSID='+IntToStr(ID3)+' where ID='+IntToStr(ID),[],[]);
end;

procedure TKredilerDlg.KrediHesapTusClick(Sender: TObject);
var KDVSIZ : string;
    ToplamFaiz, BSMV, KKDF : Currency;
begin
  ToplamFaiz := 0.0;
  if KREDILER.State in [dsInsert] then
    KREDILER.Post;
  if KrediHesapMakineDlg = nil then
    Application.CreateForm(TKrediHesapMakineDlg, KrediHesapMakineDlg);
  KrediHesapMakineDlg.btnAktar.Visible := True;
  KrediHesapMakineDlg.ComboKurFat.EditValue := ComboKur.EditValue;
  KrediHesapMakineDlg.ComboKurFat.Enabled := False;
  KrediHesapMakineDlg.ShowModal;
  if KrediHesapMakineDlg.ModalResult = mrOk then Begin

    if(PLANKREDI.RecordCount>0)and
      (MessageDlg(KGirilmisOdemeTakvimiVarSilinsinmi, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then Begin
      //�nce eski kredi takvimini sileriz
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PLANKREDI where KREDIID=&id ',['&id'],[KREDILER.Fields[0].AsInteger]);
      //Sonra da KASA ya bu krediden girmi� paray� sileriz
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where TUR=59 and KREDIID=&Kid ',['&Kid'],[KREDILER.Fields[0].AsInteger]);
    End;

    with KrediHesapMakineDlg do begin
        KREDILER.Edit;

        TabOdemeTakvimi.Last;
        KREDILER.FieldByName('KAPANISTARIHI').AsDateTime := TabOdemeTakvimi.FieldByName('TARIH').AsDateTime;
        KREDILER.FieldByName('KREDITAKSIT').AsInteger := TaksitSay.Value;
        KREDILER.FieldByName('TAKSITTUTARI').AsCurrency := TabOdemeTakvimi.FieldByName('TAKSIT').AsCurrency;
        EditTAKSIT.Properties.ReadOnly := True;
        KREDILER.FieldByName('TUTARI').AsCurrency := EditTutar.Value;
        KREDILER.FieldByName('FAIZORANI').AsFloat:= FaizOraniAy.Value;
        if cxPageControl1.ActivePageIndex = 0 then begin//kredi, Leasing de�il
          KREDILER.FieldByName('BSMV').AsFloat := EditBSMVOrani.Value;
          KREDILER.FieldByName('KKDF').AsFloat:= EditKKDFOrani.Value;
        end else begin
          KREDILER.FieldByName('BSMV').AsFloat := 0;
          KREDILER.FieldByName('KKDF').AsFloat:= 0;
        end;
        KREDILER.Post;
        TabOdemeTakvimi.First;
        while not TabOdemeTakvimi.Eof do begin
          if cxPageControl1.ActivePageIndex = 0 then begin//kredi, Leasing de�il
            KDVSIZ := '0';
            BSMV := TabOdemeTakvimi.FieldByName('BSMV').AsFloat;
            KKDF := TabOdemeTakvimi.FieldByName('KKDF').AsFloat;
          end else begin
            KDVSIZ := TabOdemeTakvimi.FieldByName('KDVSIZ').AsString;
            BSMV   := 0;
            KKDF   := 0;
          end;
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := ' INSERT INTO PLANKREDI (KREDIID, TARIH, TAKSIT,KDVSIZ,ANAPARA,FAIZ, KKDF, BSMV,BAKIYE, KUR, ACIKLAMA, ODENMIS, ANIMSAT,SUBEID ) '+
                            ' VALUES (:KREDIID, :TARIH, :TAKSIT,:KDVSIZ,:ANAPARA,:FAIZ, :KKDF, :BSMV,:BAKIYE, :KUR, :ACIKLAMA,0,0,'+IntToStr(SubeId)+' ) select scope_identity()';
          Tablo.Query1.Params[0].Value := KREDILER.FieldByName('ID').AsInteger;
          Tablo.Query1.Params[1].Value := TabOdemeTakvimi.FieldByName('TARIH').AsDateTime;//FormatDateTime('YYYY-MM-DD', FormatDateTime('MM/DD/YYYY', TabOdemeTakvimi.FieldByName('TARIH').AsDateTime);
          Tablo.Query1.Params[2].Value := TabOdemeTakvimi.FieldByName('TAKSIT').AsCurrency;
          Tablo.Query1.Params[3].Value := KDVSIZ;
          Tablo.Query1.Params[4].Value := TabOdemeTakvimi.FieldByName('ANAPARA').AsCurrency;
          Tablo.Query1.Params[5].Value := TabOdemeTakvimi.FieldByName('FAIZ').AsCurrency;
          Tablo.Query1.Params[6].Value := KKDF;
          Tablo.Query1.Params[7].Value := BSMV;
          Tablo.Query1.Params[8].Value := TabOdemeTakvimi.FieldByName('BAKIYE').AsCurrency;
          Tablo.Query1.Params[9].Value := TabOdemeTakvimi.FieldByName('KUR').AsString;
          Tablo.Query1.Params[10].Value := TabOdemeTakvimi.FieldByName('ACIKLAMA').AsString;
          Tablo.Query1.Open;
          Tablo.SablondanAktiviteOlustur(250201,Tablo.Query1.fields[0].AsInteger,TabOdemeTakvimi.FieldByName('TARIH').AsDateTime,[EditADI.Text+' Kredisi.']);
          ToplamFaiz := ToplamFaiz + TabOdemeTakvimi.FieldByName('FAIZ').AsCurrency+KKDF+BSMV;
          TabOdemeTakvimi.Next;
        end;
    end;
    DtsKredilerDataChange(Self, KREDILER.Fields[0] );
    if Application.MessageBox(PChar(KWKrediGirisiBankaya), PChar(Uyari),  MB_YESNO)=ID_YES then   // Sor
       Kasaya_KRedi_Kaydet(ToplamFaiz);
  end;
end;

procedure TKredilerDlg.KrediLeasingHesaplayiciIptalClick(Sender: TObject);
begin
  FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TFrame(Sender)).Kapat;
end;

procedure TKredilerDlg.PlanSilMenuClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(KOdemePlaniTumuyleSilinsinmi), PChar(Onay), MB_YESNO) <> IDYES then abort;

   Tablo.TablodanSorguAc(2,'select * from PLANKREDI where KREDIID='+KREDILER.FieldByName('ID').AsString);
   while not Tablo.Query2.Eof do begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM AKTIVITELER WHERE YERI=250201 and YER_ID=&YERID',['&YERID'],[Tablo.Query2.FieldByName('ID').AsString]);
     Tablo.Query2.Next;
   end;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'delete from PLANKREDI where KREDIID='+KREDILER.FieldByName('ID').AsString;
   Tablo.Query1.ExecSQL;
   Tabloyenile(PLANKREDI,[KREDILER.FieldByName('ID').AsInteger]);
   PlanTview.applyBestFit(nil);
end;

procedure TKredilerDlg.PlanTviewCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridGeriOdeme;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=PlanTview;
  AnaForm.pmGridStil.Tags.Values[GridGeriOdeme.Name]:='KrediGeriOdemeGridi';
end;

procedure TKredilerDlg.OdemeEkleTusClick(Sender: TObject);
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

procedure TKredilerDlg.PLANKREDIAfterPost(DataSet: TDataSet);
begin
  Tabloyenile(PLANKREDI,[KREDILER.FieldByName('ID').AsInteger]);
  PlanTview.applyBestFit(nil);
end;

procedure TKredilerDlg.PLANKREDIBeforePost(DataSet: TDataSet);
begin
   EkleyenDegistiren(DtsOdemeTakvimi);
   PLANKREDI.FieldByName('DEGISTI').AsBoolean:= True;
end;

procedure TKredilerDlg.PopupMenu2Popup(Sender: TObject);
begin
   PlanSilMenu.Enabled := PLANKREDI.RecordCount>0;
   ExceldenVeriAlMenu.Enabled := not PlanSilMenu.Enabled ;
end;

procedure TKredilerDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TKredilerDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_KREDILER, KREDILER.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TKredilerDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKredilerDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM AKTIVITELER WHERE YERI=250205 and YER_ID=&YERID',['&YERID'],[KREDILER.FieldByName('ID').AsString]);
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'select top 1 ISLEMTARIHI from KASA where TUR = 58 and KREDIID ='+KREDILER.FieldByName('ID').AsString;
    Tablo.Query1.Open;
    if Tablo.Query1.RecordCount > 0 then
       raise Exception.Create(KBuKredinin+Tablo.Query1.Fields[0].AsString+KTarihindeOdemesiVarSilinemez);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PLANKREDI  where KREDIID=&Id ',['&Id'], [KREDILER.FieldByName('ID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KREDIROTATIF  where KREDIID=&Id ',['&Id'], [KREDILER.FieldByName('ID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KREDIROTATIFFAIZ   where KREDIID=&Id ',['&Id'], [KREDILER.FieldByName('ID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KREDIROTATIFDONEM    where KREDIID=&Id ',['&Id'], [KREDILER.FieldByName('ID').AsInteger]);
    KREDILER.Delete;
    DtsKredilerStateChange(Self);
  end;
end;

initialization
  RegisterClass(TKredilerDlg);
end.


//   RiskHesapla(Tablo.TabRehber.Fieldbyname('KOD').AsString);











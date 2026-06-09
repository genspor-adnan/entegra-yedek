unit UUretimWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Utablo, cxGridTableView,
  Dialogs, JvWizard, JvExControls, cxGraphics, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridDBTableView, cxGrid, cxButtonEdit, cxDropDownEdit, cxImageComboBox, cxDBEdit, cxTextEdit, FireDAC.Comp.Client,
  cxCalendar, ComCtrls, ToolWin, cxContainer, cxLabel, Buttons, ExtCtrls, cxMaskEdit, UStokHizmetAra,
  frxClass, frxDBSet, Menus, cxMemo, cxCheckBox, cxDBLabel, dxSkinsCore, UIzleme, cxLookAndFeelPainters,
  dxSkinscxPCPainter, cxLookAndFeels, cxNavigator, cxCurrencyEdit, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  cxSpinEdit, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,  DateUtils,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxBarBuiltInMenu,
  cxPC, Vcl.StdCtrls, cxButtons, OfficePopupMenu, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, cxTimeEdit, JvNavigationPane,
  cxRichEdit, dxDateRanges, dxScrollbarAnnotations, dxCoreGraphics,
  frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;


type
  TUretimWizardDlg = class(TForm, IPopupDialog)
    WizardKontrol: TJvWizard;
    JvWizardInteriorPage1: TJvWizardInteriorPage;
    PanelUst: TPanel;
    btnKapat: TSpeedButton;
    ToolBar3: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton8: TToolButton;
    YaziciYaz: TToolButton;
    GridUretimDBTableView1: TcxGridDBTableView;
    GridUretimLevel1: TcxGridLevel;
    GridUretim: TcxGrid;
    ToolBar5: TToolBar;
    BilesenEkle: TToolButton;
    SatirSil: TToolButton;
    SatirKaydet: TToolButton;
    SatirIptal: TToolButton;
    TabUretim: TFDQuery;
    DtsUretim: TDataSource;
    TabUretimDetay: TFDQuery;
    DtsUretimDetay: TDataSource;
    UrunEkle: TToolButton;
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
    frxUretimDetay: TfrxDBDataset;
    frxUretim: TfrxDBDataset;
    GridUretimDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridUretimDBTableView1ADET: TcxGridDBColumn;
    GridUretimDBTableView1BIRIM: TcxGridDBColumn;
    GridUretimDBTableView1GRP: TcxGridDBColumn;
    GridUretimDBTableView1AD: TcxGridDBColumn;
    GridUretimDBTableView1KOD: TcxGridDBColumn;
    PopupRecete: TPopupMenu;
    ReetedenGetir1: TMenuItem;
    ReeteOlarakKaydet1: TMenuItem;
    ReceteTus: TToolButton;
    ToolButton2: TToolButton;
    Reeteler1: TMenuItem;
    cxLabel5: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    ReeteyeGreMiktarAyarla1: TMenuItem;
    GridUretimDBTableView1DOVIZ_BIRIMFIYAT: TcxGridDBColumn;
    GridUretimDBTableView1TUTAR: TcxGridDBColumn;
    GridUretimDBTableView1DOVIZ_TUTARI: TcxGridDBColumn;
    GridUretimDBTableView1DOVIZ_KURU: TcxGridDBColumn;
    GridUretimDBTableView1DOVIZKURDEGERI: TcxGridDBColumn;
    GridUretimDBTableView1KUR: TcxGridDBColumn;
    URETIM: TFDQuery;
    URETIMDETAY: TFDQuery;
    GridUretimDBTableView1STOKDURUM: TcxGridDBColumn;
    GridUretimDBTableView1BIRIMFIYAT: TcxGridDBColumn;
    HesaplaTus: TToolButton;
    GridUretimDBTableView1ORT_TPLM_MLYT: TcxGridDBColumn;
    GridUretimDBTableView1SON_TPLM_MLYT: TcxGridDBColumn;
    BtnDonustur: TToolButton;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    GridUretimDBTableView1FIRMA: TcxGridDBColumn;
    GridUretimDBTableView1SIRA: TcxGridDBColumn;
    PopupMenuDonustur: TPopupMenu;
    rnOlarak1: TMenuItem;
    SarfOlarak1: TMenuItem;
    GridUretimDBTableViewEKLEYEN: TcxGridDBColumn;
    GridUretimDBTableViewEKLEMETARIHI: TcxGridDBColumn;
    PopupGenel: TPopupMenu;
    IzlemBilgileriGorDegistirMenu: TMenuItem;
    PageControlUst: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    EkAlanlarEkr: TcxTabSheet;
    Label19: TcxLabel;
    LabelFatNo: TcxLabel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    EditFatTarih: TcxDBDateEdit;
    EditFatNo: TcxDBTextEdit;
    ComboCikisDepo: TcxDBImageComboBox;
    ComboGirisDepo: TcxDBImageComboBox;
    cxLabel2: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel4: TcxLabel;
    BEditIsMerkezi: TcxDBButtonEdit;
    BeditLokasyon: TcxDBButtonEdit;
    ComboUretici: TcxDBButtonEdit;
    EditTarih: TcxDBDateEdit;
    ComboSENARYO: TcxDBImageComboBox;
    cxLabel7: TcxLabel;
    cbUretimTuru: TcxDBImageComboBox;
    cxLabel8: TcxLabel;
    LabelUrunAd: TcxLabel;
    ToolButton1: TToolButton;
    DetayTus: TToolButton;
    UretimDetayPage: TJvWizardInteriorPage;
    LabelSablon: TcxLabel;
    ComboBolum: TcxDBComboBox;
    ToolBar1: TToolBar;
    DtsDetay: TDataSource;
    TabDetay: TFDQuery;
    DataSource1: TDataSource;
    ADOQuery1: TFDQuery;
    ToolBar2: TToolBar;
    GridProjeDetay: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    SQLDetay: TcxMemo;
    Panel2: TPanel;
    btnFis: TcxButton;
    btnDetay: TcxButton;
    btnAsama: TcxButton;
    DokumanEkr: TJvWizardInteriorPage;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel6: TPanel;
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
    cxLabel9: TcxLabel;
    EditOZELKOD: TcxDBTextEdit;
    cxLabel10: TcxLabel;
    EditOZELKOD2: TcxDBTextEdit;
    Query20: TFDQuery;
    PageControlAlt: TcxPageControl;
    TabSheetGenel: TcxTabSheet;
    TabIsVeZaman: TcxTabSheet;
    LabelProje: TcxLabel;
    cxLabel1: TcxLabel;
    memoACIKLAMA: TcxDBMemo;
    BeditProje: TcxButtonEdit;
    cxLabel3: TcxLabel;
    ComboOnaylayan: TcxDBButtonEdit;
    Panel9: TPanel;
    JvNavPanelHeader5: TJvNavPanelHeader;
    CheckTamamlananlar: TcxCheckBox;
    ToolBar4: TToolBar;
    IsZamanYeni: TToolButton;
    IsZamanSil: TToolButton;
    IsZamanDuzenle: TToolButton;
    GridIsZaman: TcxGrid;
    GridIsZamanView: TcxGridDBTableView;
    cxGridDBTARIH: TcxGridDBColumn;
    cxGridDBKONUSU: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBBASLAMA: TcxGridDBColumn;
    cxGridDBBITIS: TcxGridDBColumn;
    GridIsZamanViewMOLA: TcxGridDBColumn;
    GridIsZamanViewSURE: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    GridIsZamanViewDURUM: TcxGridDBColumn;
    GridIsZamanViewACIKLAMA: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TabIsZaman: TFDQuery;
    TabIsZamanID: TAutoIncField;
    TabIsZamanOPERASYONID: TIntegerField;
    TabIsZamanTARIH: TSQLTimeStampField;
    TabIsZamanPERSONEL: TIntegerField;
    TabIsZamanLOKASYON: TIntegerField;
    TabIsZamanKAYNAK: TIntegerField;
    TabIsZamanBASLAMA: TSQLTimeStampField;
    TabIsZamanBITIS: TSQLTimeStampField;
    TabIsZamanMOLA: TSQLTimeStampField;
    TabIsZamanSURE: TTimeField;
    TabIsZamanADET: TFloatField;
    TabIsZamanBIRIM: TIntegerField;
    TabIsZamanMIKTAR: TFloatField;
    TabIsZamanKONUSU: TWideStringField;
    TabIsZamanDURUM: TWordField;
    TabIsZamanEKLEYEN: TSmallintField;
    TabIsZamanEKLEMETARIHI: TSQLTimeStampField;
    TabIsZamanDEGISTIREN: TSmallintField;
    TabIsZamanDEGISTIRMETARIHI: TSQLTimeStampField;
    TabIsZamanLOKASYONADI: TWideStringField;
    TabIsZamanKAYNAKADI: TWideStringField;
    TabIsZamanSORUMLUADI: TWideStringField;
    TabIsZamanACIKLAMA: TWideStringField;
    DtsIsZaman: TDataSource;
    TabIsZamanYER: TSmallintField;
    GridUretimDBTableView1OZELKOD: TcxGridDBColumn;
    GridUretimDBTableView1OZELKOD2: TcxGridDBColumn;
    frxIsZaman: TfrxDBDataset;
    CheckOtomatikHesapla: TcxCheckBox;
    PopupMenuIsZaman: TPopupMenu;
    MenuKopyala: TMenuItem;
    LabelSevk: TcxLabel;
    lblMusteriAdres: TcxLabel;
    lblMusteriEposta: TcxLabel;
    lblMusteriTel: TcxLabel;
    GridUretimDBTableView1URUNNO: TcxGridDBColumn;
    cxLabel11: TcxLabel;
    EditDETAYBOLUMU: TcxDBTextEdit;
    PopupIsZamanPer: TPopupMenu;
    MenuTumKonular: TMenuItem;
    N5: TMenuItem;
    RecetedenKonularEkleMenu: TMenuItem;
    procedure DtsUretimStateChange(Sender: TObject);
    procedure DtsUretimDetayStateChange(Sender: TObject);
    procedure BilesenEkleClick(Sender: TObject);
    procedure TabUretimNewRecord(DataSet: TDataSet);
    procedure TabUretimAfterPost(DataSet: TDataSet);
    procedure TabUretimBeforeDelete(DataSet: TDataSet);
    procedure TabUretimBeforeEdit(DataSet: TDataSet);
    procedure TabUretimBeforePost(DataSet: TDataSet);
    procedure TabUretimDetayAfterDelete(DataSet: TDataSet);
    procedure TabUretimDetayAfterInsert(DataSet: TDataSet);
    procedure TabUretimDetayAfterPost(DataSet: TDataSet);
    procedure TabUretimDetayAfterScroll(DataSet: TDataSet);
    procedure TabUretimDetayBeforeDelete(DataSet: TDataSet);
    procedure TabUretimDetayBeforeEdit(DataSet: TDataSet);
    procedure TabUretimDetayBeforePost(DataSet: TDataSet);
    procedure TabUretimDetayNewRecord(DataSet: TDataSet);
    procedure SatirSilClick(Sender: TObject);
    procedure SatirKaydetClick(Sender: TObject);
    procedure SatirIptalClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UrunEkleClick(Sender: TObject);
    procedure TabUretimDetayAfterOpen(DataSet: TDataSet);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure Reeteler1Click(Sender: TObject);
    procedure ReeteOlarakKaydet1Click(Sender: TObject);
    procedure ReetedenGetir1Click(Sender: TObject);
    procedure BeditLokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabUretimAfterOpen(DataSet: TDataSet);
    procedure BEditIsMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ComboUreticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ComboOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ReeteyeGreMiktarAyarla1Click(Sender: TObject);
    procedure ReceteTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HesaplaTusClick(Sender: TObject);
    procedure BtnDonusturClick(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure FirmaBilgileri(RehberId:integer);
    procedure TabUretimDetayAfterCancel(DataSet: TDataSet);
    procedure DepoEnabledAyarla;
    procedure GridUretimDBTableView1CanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure cxLabel7Click(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BeditProjeDblClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure PopupGenelPopup(Sender: TObject);
    procedure IzlemBilgileriGorDegistirMenuClick(Sender: TObject);
    procedure TabUretimAfterScroll(DataSet: TDataSet);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure GridDetayViewInitEdit(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure LabelSablonClick(Sender: TObject);
    procedure UretimDetayPagePage(Sender: TObject);
    procedure UretimDetayPageExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageControlUstChange(Sender: TObject);
    procedure btnFisClick(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure IsZamanYeniClick(Sender: TObject);
    procedure IsZamanSilClick(Sender: TObject);
    procedure IsZamanDuzenleClick(Sender: TObject);
    procedure CheckTamamlananlarClick(Sender: TObject);
    procedure TabIsZamanAfterOpen(DataSet: TDataSet);
    procedure TabIsZamanCalcFields(DataSet: TDataSet);
    procedure PageControlAltChange(Sender: TObject);
    procedure MenuKopyalaClick(Sender: TObject);
    procedure LabelSevkClick(Sender: TObject);
    procedure MenuTumKonularClick(Sender: TObject);
    procedure RecetedenKonularEkleMenuClick(Sender: TObject);
  private
    BilesenAraDlg,UrunAraDlg:TStokHizmetAraDlg;
    UretimOncekiStokMiktar : Real;
    UretimOncekiBirim,Carpan : Integer;
    IzlemDlg3 : TIzlemeDlg;
    procedure IletisimEkleClick(Sender: TObject);
    function MiktarSor(Mik:Variant):Real;
    function BoslukKontrolu: Boolean;
    procedure URETIMADETChange(Sender: TField);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure StokIzlemBilgisi(TabloDetay:TFDQuery);
    { Private declarations }
  public
    UretimID,Cagiran,RehberId:Integer;
    IslemOp : Char;
    YeniMiktar:Real;
    function RecetedenEkle(ReceteID:integer;Miktar:extended;UrunudeEkle:Boolean):boolean;
    { Public declarations }
  end;

var
  UretimWizardDlg: TUretimWizardDlg;

implementation

uses
  UGenelAnaSekmeFrame, URaporAraclari, UUretimRecete, UGirisKutusuEx, Fetautil, FetaKurulusSiniflari,
  UKodAgaci, UAnaForm, LocOnFly,PrjConst, UFastRap, UBelgeDonusum, FetaClassExtensions,
  URehberAyar, UCariFonksiyonlar;

{$R *.dfm}

var
   Ciksin, IptalSecildi, EkleDetay : Boolean;

procedure TUretimWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi,Ekranadi:string;
begin
  TabloYenile(URETIM, [TabUretim.FieldByName('ID').AsInteger],TabUretim.FieldByName('ID').AsInteger,'ID');
  TabloYenile(URETIMDETAY, [TabUretim.FieldByName('ID').AsInteger],TabUretimDetay.FieldByName('ID').AsInteger,'ID');
  AFastReport.EnabledDataSets.Clear;
  DokumAdi := YaziciYaz.Caption;
  Ekranadi := EkranAdiAl;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar3.Owner), DokumAdi, Ekranadi, frxUretim) then begin

     AFastReport.EnabledDataSets.Add(frxUretim);
     AFastReport.EnabledDataSets.Add(frxIsZaman);
  end else begin
    frxUretim.Dataset := URETIM;
    AFastReport.EnabledDataSets.Add(frxUretim);
    AFastReport.EnabledDataSets.Add(frxUretimDetay);
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
    AFastReport.EnabledDataSets.Add(frxIsZaman);
  end;

end;

procedure TUretimWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabNo_URETIMFISI);
end;

procedure TUretimWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
  if TabUretim.State in [dsInsert,dsEdit] then
     TabUretim.Post;
  if TabUretimDetay.State in [dsInsert,dsEdit] then
     TabUretimDetay.Post;
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s); //EkranAdi
end;

procedure TUretimWizardDlg.BEditIsMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_UretimIsMerkezi);
   if LokID>0 then begin
      TabUretim.Edit;
      TabUretim.FieldByName('ISYERI').Value:=LokID;
      TabUretim.Post;
  end;
end;

procedure TUretimWizardDlg.BeditLokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
   LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Uretim);
   if LokID>0 then begin
      TabUretim.Edit;
      TabUretim.FieldByName('LOKASYON').Value:=LokID;
      TabUretim.Post;
   end;
end;

procedure TUretimWizardDlg.BeditProjeDblClick(Sender: TObject);
begin
  if BeditProje.Text <> '' then
    Tablo.ProjeSihirbazBaslat('D', TabUretim.FieldByName('PROJEID').AsInteger, TabUretim.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);

end;

procedure TUretimWizardDlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var PrjId : integer;
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje, TabUretim, AButtonIndex,ProjeSecimi, TabUretim.FieldByName('REHBERID').AsInteger);
  if StrToIntDef(VarToStrDef(TabUretim.FieldByname('PROJEID').Value,'0'),0)>0 then
     PrjId := TabUretim.FieldByName('PROJEID').AsInteger
  else
     PrjId := 0;

  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set PROJEID=&PrjID where FATBASID=&FatbasID',['&PrjID','&FatbasID'],[PrjId, TabUretim.FieldByname('ID').AsInteger]);
  TabloYenile(TabUretimDetay, [TabUretim.FieldByname('ID').AsInteger]);
end;

procedure TUretimWizardDlg.BilesenEkleClick(Sender: TObject);
begin
  if TabUretim.FieldByName('ID').AsInteger<1 then begin
     showmessage(DDUst_bilgi_kayit);
     exit;
  end;

  TabUretimDetay.AfterScroll := nil;
  if TabUretim.State in[dsEdit,dsInsert] then begin
    TabUretim.Post;
    TabloYenile(TabUretimDetay, [TabUretim.FieldByname('ID').AsInteger]);
  end;
  Carpan := -1;
  if BilesenAraDlg=nil then
     Application.CreateForm(TStokHizmetAraDlg,BilesenAraDlg);
  BilesenAraDlg.FatBasID:=TabUretim.FieldByName('ID').AsInteger;
  BilesenAraDlg.RehberID:=TabUretim.FieldByName('REHBERID').AsInteger;
  BilesenAraDlg.TabDetayGiris:=TabUretimDetay;
  BilesenAraDlg.TabGiris:=TabUretim;
  BilesenAraDlg.KalanAdetGetir:=True;
  BilesenAraDlg.stokhizmetaracagirantur := 6;
  BilesenAraDlg.GirisCikis:=FWCikis;//giriş-çıkış işlemi yapılmayacak..
  BilesenAraDlg.FiyatlariGetir:=False;
  BilesenAraDlg.cbFiyatAdi.EditValue := VarsAlisFiyatID;
  BilesenAraDlg.cbFiyatAdi.Visible:=False;
  BilesenAraDlg.SheetHizmet.TabVisible:=False;
  BilesenAraDlg.cbStokDepo.EditValue:=ComboCikisDepo.EditValue;
  BilesenAraDlg.ShowModal;
//  if TabUretim.FieldByname('SENARYO').AsInteger=1 then begin //bütünden parçaya
// Bu maliyet hesabı da kapandı AO 31/1/2018
//  Tablo.UretimSatirMaliyetUpdate(TabUretim.FieldByName('ID').AsInteger);
  TabloYenile(TabUretimDetay, [TabUretim.FieldByname('ID').AsInteger]);
  //end;
//  TabUretimDetay.AfterScroll := URETIMDetayAfterScroll;
  Carpan := 0;
end;

procedure TUretimWizardDlg.UrunEkleClick(Sender: TObject);
var ToplamAdet : String[30];
begin
  if TabUretim.FieldByName('ID').AsInteger<1 then begin
     showmessage(DDUst_bilgi_kayit);
     exit;
  end;

  TabUretimDetay.AfterScroll := nil;
  if TabUretim.State in[dsEdit,dsInsert] then begin
    TabUretim.Post;
    TabloYenile(TabUretimDetay, [TabUretim.FieldByname('ID').AsInteger]);
  end;
  Carpan := 1;
  if UrunAraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,UrunAraDlg);
  UrunAraDlg.FatBasID:=TabUretim.FieldByName('ID').AsInteger;
  UrunAraDlg.RehberID:=TabUretim.FieldByName('REHBERID').AsInteger;
  UrunAraDlg.TabDetayGiris:=TabUretimDetay;
  UrunAraDlg.TabGiris:=TabUretim;
  UrunAraDlg.KalanAdetGetir:=False;
  UrunAraDlg.stokhizmetaracagirantur := 6;
  UrunAraDlg.GirisCikis:=FWGiris;
  UrunAraDlg.FiyatlariGetir:=False;
  UrunAraDlg.cbFiyatAdi.EditValue := VarsAlisFiyatID;
  UrunAraDlg.cbFiyatAdi.Visible:=False;
  UrunAraDlg.SheetHizmet.TabVisible:=False;
  UrunAraDlg.cbStokDepo.EditValue:=ComboGirisDepo.EditValue;
  UrunAraDlg.ShowModal;
  Carpan := 0;
  //TabUretimDetay.AfterScroll := URETIMDetayAfterScroll;

  if TabUretim.FieldByname('SENARYO').AsInteger=2 then begin //bütünden parçaya
     //çıkanların toplam tutarını bulalım
     Tablo.TablodanSorguAc(1, 'select abs(sum(BIRIMFIYAT*ADET)) as BIRIMFIYAT, abs(sum(TUTAR*ADET)) as TUTAR from FATURA where FATBASID='+TabUretim.Fields[0].AsString+' and ADET<0.0');

     //şimdiye kadar girmişlerin toplam adedini bulalım
     Tablo.TablodanSorguAc(2, 'select isnull(sum(ADET),0.0) from FATURA where FATBASID='+TabUretim.Fields[0].AsString+' and ADET>0.0');
     ToplamAdet := Float_ToStr(Tablo.Query2.Fields[0].AsFloat);
     //toplam tutarları satırlara adetleri oranında dağıtalım
     Tablo.UretimSatirMaliyetUpdate(TabUretim.FieldByName('ID').AsInteger);
     TabloYenile(TabUretimDetay, [TabUretim.FieldByname('ID').AsInteger]);
  end;
end;

procedure TUretimWizardDlg.DtsUretimDetayStateChange(Sender: TObject);
begin
  BilesenEkle.Visible := (DtsUretimDetay.State = dsBrowse);//and(TabUretimDetay.RecordCount>0);
  UrunEkle.Visible := (DtsUretimDetay.State = dsBrowse);//and(TabUretimDetay.RecordCount>0);
  SatirSil.Visible := (DtsUretimDetay.State = dsBrowse)and(not TabUretimDetay.IsEmpty);
  SatirKaydet.Visible := DtsUretimDetay.State in [dsEdit,dsInsert];
  SatirIptal.Visible := DtsUretimDetay.State in [dsEdit,dsInsert];
end;


procedure TUretimWizardDlg.DtsUretimStateChange(Sender: TObject);
begin
  KaydetTus.Visible := DtsUretim.State in [dsEdit,dsInsert];
  IptalTus.Visible := DtsUretim.State in [dsEdit,dsInsert];
  YaziciYaz.Visible := DtsUretim.State = dsBrowse;
end;

procedure TUretimWizardDlg.TabIsZamanAfterOpen(DataSet: TDataSet);
begin
   IsZamanSil.Visible := not TabIsZaman.IsEmpty;
end;

procedure TUretimWizardDlg.TabIsZamanCalcFields(DataSet: TDataSet);
var saat, dakika : smallint;
    s, d :string[2];
begin
   //TabUretimOperasyonPersonel.FieldByName('SURE').AsDateTime := TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime - TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime
   //        -TabUretimOperasyonPersonel.FieldByName('MOLA').AsDateTime;

   Saat := HoursBetween(TabIsZaman.FieldByName('BITIS').AsDateTime-TabIsZaman.FieldByName('MOLA').AsDateTime,
                         TabIsZaman.FieldByName('BASLAMA').AsDateTime);
   if Saat>23 then
      ShowMessage('24 saat veya daha fazla süre geçersizdir!')
   else begin
         Dakika := MinutesBetween(TabIsZaman.FieldByName('BITIS').AsDateTime-TabIsZaman.FieldByName('MOLA').AsDateTime,
                             TabIsZaman.FieldByName('BASLAMA').AsDateTime);
         Dakika := Dakika-(Saat*60);
         s:=IntToStr(Saat);
         if saat<10 then
            s:='0'+s;
         d:=IntToStr(dakika);
         if dakika<10 then
            d:='0'+d;
         TabIsZaman.FieldByName('SURE').AsString := s+':'+d;
   end;
///   TabIsZaman.FieldByName('SURE').AsDateTime := TabIsZaman.FieldByName('BITIS').AsDateTime - TabIsZaman.FieldByName('BASLAMA').AsDateTime
///           -TabIsZaman.FieldByName('MOLA').AsDateTime;
end;

procedure TUretimWizardDlg.TabUretimAfterOpen(DataSet: TDataSet);
begin
  if TabUretim.FieldByName('LOKASYON').AsString <> '' then
     BeditLokasyon.Text:=Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',TabUretim.FieldByName('LOKASYON').Value);

  if TabUretim.FieldByName('REHBERID').AsInteger>0 then
    FirmaBilgileri(TabUretim.FieldByName('REHBERID').AsInteger);
end;

procedure TUretimWizardDlg.TabUretimAfterPost(DataSet: TDataSet);
begin
  UretimID:= TabUretim.FieldByName('ID').AsInteger;
  TabloYenile(TabUretim,[UretimID]);
end;

procedure TUretimWizardDlg.TabUretimAfterScroll(DataSet: TDataSet);
begin
   if TabUretim.FieldByName('AKTIVITEID').AsString='' then
      LabelUrunAd.Caption := '-'
   else
      LabelUrunAd.Caption := Tablo.AciklamaGetir('STOKLAR', 'STOKADI', TabUretim.FieldByName('AKTIVITEID').AsInteger);
end;

procedure TUretimWizardDlg.TabUretimBeforeDelete(DataSet: TDataSet);
begin
  if not TabUretim.IsEmpty then
    begin
       Application.MessageBox(PChar(FTWUretimleriSil),PChar(HataPrj), MB_OK+ MB_ICONERROR);
       abort;
    end;
end;

procedure TUretimWizardDlg.TabUretimBeforeEdit(DataSet: TDataSet);
begin
  if LogGun>0 then begin
    Tablo.OncekiLogBelirle(TabUretim);
  end;
end;

function TUretimWizardDlg.BoslukKontrolu: Boolean;
begin
  BoslukKontrolu := True;
  if not BoslukKontrol(EditFatTarih.Text, KontrolFaturaTarihi) then
    Abort;

  if not TarihKontrol(EditTarih.Date, 'Üretim Başlama' + KontrolTarihi) then
     Abort;
  if not TarihKontrol(EditFatTarih.Date, 'Üretim Bitiş' + KontrolTarihi) then
     Abort;
//  if not BoslukKontrol(EditFatNo.Text, 'Belge No') then Abort;

  BoslukKontrolu := False;
end;

procedure TUretimWizardDlg.BtnDonusturClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
begin
  if (sender as TMenuItem).Tag=415 then
    Carpan := 1
  else if (sender as TMenuItem).Tag=420 then
    Carpan := -1;

  if TabUretim.State in [dsEdit, dsInsert] then
     TabUretim.Post;
  if TabUretimDetay.State in [dsEdit, dsInsert] then
     TabUretimDetay.Post;

  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.RehID := TabUretim.FieldByName('REHBERID').AsInteger;
  BDDlg.HedefBaslikID := TabUretim.FieldByName('ID').AsInteger;
  BDDlg.TabKaynakBaslik := TabUretim;
  BDDlg.TabDetayGiris := TabUretimDetay;
  BDDlg.DonusumTuru := (sender as TMenuItem).Tag;
  BDDlg.GDepo := StrToIntDef(VarToStrDef(TabUretim.FieldByName('GIRISDEPO').Value,'0'),0);
  BDDlg.CDepo := StrToIntDef(VarToStrDef(TabUretim.FieldByName('CIKISDEPO').Value,'0'),0);
  BDDlg.HedefBaslikTur := 6;  //satış siparişi    TabUretim.FieldByName('TUR').AsInteger;
  BDDlg.ShowModal;
  //Cari firma adını girelim
  if LabelAd.Caption='Ad' then
     LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabUretim.FieldByName('REHBERID').AsInteger);

  FreeAndNil(BDDlg);
  //AO 02/01/2022
  if CheckOtomatikHesapla.checked then begin
     Tablo.UretimSatirMaliyetUpdate(TabUretim.FieldByName('ID').AsInteger);
     TabloYenile(TabUretimDetay,[TabUretim.FieldByName('ID').AsInteger]);
  end;
  TabUretim.Cancel;
end;

procedure TUretimWizardDlg.btnFisClick(Sender: TObject);
begin
   if TabUretim.State in [dsEdit,dsInsert] then
      TabUretim.Post;
   WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;
end;

procedure TUretimWizardDlg.BtnMesajGonderClick(Sender: TObject);
var ID : Integer;
begin
   ID := Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  TabNo_URETIMFISI, TabUretim.FieldByName('ID').AsInteger, 0,TabYorum);
   //eğer dosya eklendiyse konusuna stok kod ve adını yazalım
   TabYorum.Last;
   if (ID>0)and(TabYorum.FieldByName('DOKUMANID').AsString<>'') then
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DOKUMAN set KONU='''+TabUretim.FieldByName('KOD').AsString+' / '+TabUretim.FieldByName('STOKADI').AsString+''' where ID='+TabYorum.FieldByName('DOKUMANID').AsString,[],[]);
end;

procedure TUretimWizardDlg.CheckTamamlananlarClick(Sender: TObject);
var Durum : Smallint;
begin
   if CheckTamamlananlar.Checked then
      Durum := 9
   else
      Durum := 8;
   TabloYenile(TabIsZaman,[TabUretimDetay.FieldByName('ID').AsInteger, Durum]);
end;

procedure TUretimWizardDlg.ComboBolumPropertiesEditValueChanged( Sender: TObject);
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
      TabUretim.Cancel
    end else begin
      if TabUretim.state in [dsEdit, dsInsert] then
         TabUretim.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_URETIMFISI, TabUretim.FieldByName('ID').AsInteger]);
      UretimDetayPagePage(Self);
    end;
  end;
end;

procedure TUretimWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
begin
  if ComboBolum.Properties.Items.Count=0 then
     ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(TabNo_URETIMFISI)).Items;
end;

procedure TUretimWizardDlg.ComboOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then begin
    TabUretim.Edit;
    TabUretim.FieldByName('ONAYLAYAN').AsInteger:= ID;
    TabUretim.Post;
  end;
end;

procedure TUretimWizardDlg.ComboUreticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then begin
    TabUretim.Edit;
    TabUretim.FieldByName('SATICIKODU').AsInteger:= ID;
    TabUretim.Post;
  end;
end;

procedure TUretimWizardDlg.cxLabel7Click(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TUretimWizardDlg.PageControlAltChange(Sender: TObject);
begin
   if PageControlAlt.ActivePageIndex=1 then
      CheckTamamlananlarClick(Self);
end;

procedure TUretimWizardDlg.PageControlUstChange(Sender: TObject);
var i:integer;
begin
  if PageControlUst.ActivePage=EkAlanlarEkr then begin
    for I := 0 to EkAlanlarEkr.ControlCount-1 do begin
      (EkAlanlarEkr.Controls[i] as TcxControl).Refresh;
      if (EkAlanlarEkr.Controls[i] as TcxControl).ClassName='TcxDBTextEdit' then
        (EkAlanlarEkr.Controls[i] as TcxDBTextEdit).SetFocus;
    end;
  end
end;

procedure TUretimWizardDlg.TabUretimBeforePost(DataSet: TDataSet);
begin
  BoslukKontrolu;
  if TabUretim.FieldByName('GIRISDEPO').AsInteger<=0 then begin
    Application.MessageBox(PChar(FTWGirisDeposuBosOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
    ComboGirisDepo.SetFocus;
    Abort;
  end;
  if TabUretim.FieldByName('CIKISDEPO').AsInteger<=0 then begin
    Application.MessageBox(PChar(FTWCikisDeposuBosOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
    ComboCikisDepo.SetFocus;
    Abort;
  end;
  if TabUretim.FieldByName('FATURATARIH').AsDateTime < TabUretim.FieldByName('TARIH').AsDateTime then begin
    Application.MessageBox(PChar(FTWTarihKucukOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
    EditFatTarih.SetFocus;
    Abort;
  end;
  if KilitKontrolEt(1,6,TabUretim.FieldByName('TARIH').AsDateTime,1) then
     Abort;


  {if  (TabUretim.FieldByName('FATURATARIH').AsDateTime > Tablo.GENINI.BugunTrh + 720)or
      (TabUretim.FieldByName('TARIH').AsDateTime > Tablo.GENINI.BugunTrh + 720)or
      (TabUretim.FieldByName('FATURATARIH').AsDateTime < Tablo.GENINI.BugunTrh - 720)or
      (TabUretim.FieldByName('TARIH').AsDateTime < Tablo.GENINI.BugunTrh - 720) then begin
    Application.MessageBox(PChar(FTWTarihUzakOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
    EditFatTarih.SetFocus;
    Abort;
  end; }
end;

procedure TUretimWizardDlg.TabUretimDetayAfterCancel(DataSet: TDataSet);
begin
  YeniMiktar := 1;
end;

procedure TUretimWizardDlg.TabUretimDetayAfterDelete(DataSet: TDataSet);
begin
  TabUretim.Refresh;
  TabUretimDetay.Refresh;
  DepoEnabledAyarla;
end;

procedure TUretimWizardDlg.TabUretimDetayAfterInsert(DataSet: TDataSet);
begin
  UretimOncekiStokMiktar := 0.0;
end;

procedure TUretimWizardDlg.TabUretimDetayAfterOpen(DataSet: TDataSet);
begin
  TabUretimDetay.FieldByName('ADET').OnChange := URETIMADETChange;
  TabUretimDetay.FieldByName('BIRIM').OnChange := URETIMADETChange;
  GridUretimDBTableView1.ViewData.Expand(True);
  DepoEnabledAyarla;
end;

procedure TUretimWizardDlg.TabUretimDetayAfterPost(DataSet: TDataSet);
begin
  if (Carpan = 1) and (StrToIntDef(VarToStrDef(TabUretim.FieldByname('AKTIVITEID').Value,'0'),0)<=0) then begin
    TabUretim.Edit;
    TabUretim.FieldByname('AKTIVITEID').AsInteger := TabUretimDetay.FieldByName('URUNID').AsInteger;
    TabUretim.FieldByname('STOKISK').AsInteger := TabUretimDetay.FieldByName('ADET').AsInteger;
    TabUretim.Post;
  end;

  //burada eklenen tek bir ürün varsa ona maliyet eklemeliyiz.
  //şimdilik kaldırdım AO 31/1/2018 bunun yerine beforepost'ta maliyet tablosundan getiriyorum
  //Tablo.UretimSatirMaliyetUpdate(TabUretim.FieldByname('ID').AsInteger);

  if IzlemDlg3<>nil then begin   //kaydetmesi için destroy etmemiz lazım
     IzlemDlg3.SatirID := TabUretimDetay.FieldByName('ID').AsInteger;
     FreeAndNil(IzlemDlg3);
  end;
  TabloYenile(TabUretimDetay,[TabUretim.FieldByName('ID').AsInteger]);
  TabUretimDetay.FieldByName('DOVIZ_BIRIMFIYAT').OnChange := URETIMADETChange;
  TabUretimDetay.FieldByName('BIRIMFIYAT').OnChange := URETIMADETChange;
  TabloYenile(TabUretimDetay, [TabUretim.FieldByname('ID').AsInteger]);
  TabUretimDetayAfterScroll(DataSet);
  YeniMiktar := 1.0;
  DepoEnabledAyarla;
end;


procedure TUretimWizardDlg.DepoEnabledAyarla;
var
  locateID:integer;
begin
  locateID:=TabUretimDetay.FieldByName('ID').AsInteger;
  TabUretimDetay.AfterScroll := nil;
  ComboCikisDepo.Enabled := True;
  ComboGirisDepo.Enabled := True;
  TabUretimDetay.First;
  while not TabUretimDetay.eof do begin
    if TabUretimDetay.FieldByName('MIKTAR').AsFloat>0 then
      ComboGirisDepo.Enabled := False;
    if TabUretimDetay.FieldByName('MIKTAR').AsFloat<0 then
      ComboCikisDepo.Enabled := False;
    TabUretimDetay.Next;
  end;
  TabUretimDetay.Locate('ID',locateID,[]);
  TabUretimDetay.AfterScroll := TabUretimDetayAfterScroll;
end;

procedure TUretimWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TUretimWizardDlg.DkmanSil1Click(Sender: TObject);
begin
   if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
       Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
       Tabloyenile(TabYorum,[TabNo_URETIMFISI,TabUretim.FieldByName('ID').AsInteger]);
   end;
end;

procedure TUretimWizardDlg.DokumanEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[TabNo_URETIMFISI, TabUretim.FieldByName('ID').AsInteger]);
end;

procedure TUretimWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
                    TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, 0)
end;

procedure TUretimWizardDlg.TabUretimDetayAfterScroll(DataSet: TDataSet);
begin
  if (TabUretimDetay.active)and(not TabUretimDetay.IsEmpty)then begin
      if TabUretimDetay.FieldByName('MIKTAR').AsFloat>0 then
        Carpan := 1
      else
        Carpan := -1;

      PageControlAltChange(Self);
  end;
end;

procedure TUretimWizardDlg.TabUretimDetayBeforeDelete(DataSet: TDataSet);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where BASLIKID='+TabUretim.FieldByName('ID').AsString+' and SATIRID= '+TabUretimDetay.FieldByName('ID').AsString,[],[]);
end;

procedure TUretimWizardDlg.TabUretimDetayBeforeEdit(DataSet: TDataSet);
begin
  UretimOncekiStokMiktar := TabUretimDetay.FieldByName('MIKTAR').AsFloat;
  UretimOncekiBirim := TabUretimDetay.FieldByName('BIRIM').AsInteger;
end;


procedure TUretimWizardDlg.TabUretimDetayBeforePost(DataSet: TDataSet);
var
  PasifIzleme:boolean;
begin
  //if not BoslukKontrol(TabUretimDetay.FieldByname('ADET').AsString, 'Fatura adet') then
    //Abort;
  //if not BoslukKontrol(TabUretimDetay.FieldByname('BIRIMFIYAT').AsString, 'Birim Fiyat') then
    //Abort;
  //if not BoslukKontrol(TabUretimDetay.FieldByname('KDV').AsString, 'KDV') then
    //Abort;
//  if Carpan<>0  then begin
  Tablo.TablodanSorguAc(1, 'select top 1 BIRIMMALIYET from STOK_ORT_MALIYET where STOKID = '+TabUretimDetay.FieldByName('URUNID').AsString +' order by TARIH desc');

{  Tablo.TablodanSorguAc(9,'select ID,STOKID, '+
          ' MALIYETSON=(select top 1 SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI=-1),'+
          ' MALIYETORT=(select top 1 SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI=-2), '+
          ' SATIS=(select top 1 SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI='+IntToStr(VarsSatisFiyatID)+'), '+
          ' BIRIM=(select S.ANABIRIM from STOKLAR S where S.ID=UR.STOKID)'+
          ' from URETIMRECETE UR where  STOKID='+TabUretim.FieldByname('REHBERID').AsString;
  UrunID := Tablo.Query9.Fields[1].AsInteger;
 }

          //' MALIYETSON=
  Tablo.TablodanSorguAc(1,' select top 1 SF.FIYAT from STOKFIYAT SF where SF.FIYATADI=-1');
  if not Tablo.Query1.IsEmpty then
     TabUretimDetay.FieldByName('BIRIMFIYAT').AsString := Tablo.Query1.Fields[0].AsString
  else
     TabUretimDetay.FieldByName('BIRIMFIYAT').AsString:='0';
          //' MALIYETORT=(


  TabUretimDetay.FieldByname('ADET').AsFloat := Abs(TabUretimDetay.FieldByname('ADET').AsFloat) * TabUretimDetay.FieldByname('EKIPMANID').AsInteger;//Carpan;
  TabUretimDetay.FieldByname('MIKTAR').AsFloat := Tablo.StokMiktarHesapla(TabUretimDetay.FieldByname('URUNID').AsInteger,TabUretimDetay.FieldByname('ADET').AsFloat,TabUretimDetay.FieldByname('BIRIM').AsInteger);
  if TabUretimDetay.FieldByname('DOVIZKURDEGERI').AsCurrency>0 then
     TabUretimDetay.FieldByname('DOVIZ_BIRIMFIYAT').AsCurrency := TabUretimDetay.FieldByname('BIRIMFIYAT').AsCurrency/TabUretimDetay.FieldByname('DOVIZKURDEGERI').AsCurrency;
  if TabUretimDetay.FieldByName('ISKONTO').Value = null  then
     TabUretimDetay.FieldByName('ISKONTO').Value := 0;
  if TabUretimDetay.FieldByName('ISKONTO2').Value = null  then
     TabUretimDetay.FieldByName('ISKONTO2').Value := 0;
  if (TabUretimDetay.FieldByName('ADET').AsString<>'')and(TabUretimDetay.FieldByName('BIRIMFIYAT').AsString<>'') then begin
      TabUretimDetay.FieldByName('TUTAR').Value := Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabUretimDetay.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabUretimDetay.FieldByName('ISKONTO2').Value) / 100)*
                TabUretimDetay.FieldByName('ADET').Value*
                TabUretimDetay.FieldByName('BIRIMFIYAT').AsExtended);
      if DovizTakibi then
         TabUretimDetay.FieldByName('DOVIZ_TUTARI').Value :=Tablo.KusuratAyarla (OndalikDijitSayTut,
                ((100 - TabUretimDetay.FieldByName('ISKONTO').Value) / 100)*
                ((100 - TabUretimDetay.FieldByName('ISKONTO2').Value) / 100)*
                TabUretimDetay.FieldByName('ADET').Value*
                TabUretimDetay.FieldByName('DOVIZ_BIRIMFIYAT').AsExtended);
  end;
//  end else begin
//    TabUretimDetay.Cancel;
//    Abort;
//  end;

  if (TabUretimDetay.FieldByname('GRP').AsString = '1')and(TabUretimDetay.FieldByname('ADET').AsFloat<0) then begin
    ShowMessage(URSifirdanKucukUyarisi);
    Abort;
  end else if (TabUretimDetay.FieldByname('GRP').AsString = '0')and(TabUretimDetay.FieldByname('ADET').AsFloat>0) then begin
    ShowMessage(URSifirdanBuyukUyarisi);
    Abort;
  end;
  //tür stoksa stok kartına ait kontroller
  if UretimOncekiBirim <> TabUretimDetay.FieldByname('BIRIM').AsInteger then begin//stok birimi değişmişse geçerli mi kontrol ediliyor
    if not(tablo.StokBirimiGecerliMi(TabUretimDetay.FieldByname('URUNID').AsInteger,TabUretimDetay.FieldByname('BIRIM').AsInteger)) then begin
      Application.MessageBox(PChar(GecerliBirimTipiDegil),PChar(Uyari), MB_OK+ MB_ICONWARNING);
      abort
    end;
  end;

    //izlem bilgisi var mı bakalım serino vb.
  if (abs(UretimOncekiStokMiktar - TabUretimDetay.FieldByName('MIKTAR').AsFloat)>0.0001)
     and(TabUretimDetay.FieldByName('TUR').AsInteger=1)
     and(TabUretimDetay.FieldByName('IZLEME').AsInteger > 0) then begin
    //  if (TabUretimDetay.FieldByName('TUR').AsInteger=1) then
        //  PasifIzleme := veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from STOKIZLEME where DURUM=0 and BELGETUR = &BlgTur and BASLIKID = &BslkID and SATIRID = &StrID',
        //                ['&BlgTur','&BslkID','&StrID'],[TabUretim.FieldByName('TUR').AsInteger, TabUretim.FieldByName('ID').AsInteger, TabUretimDetay.FieldByName('ID').AsInteger]);
      //    if (TabUretimDetay.FieldByName('STOKDURUMDEGIS').AsBoolean=True)or(PasifIzleme=True) then begin
         StokIzlemBilgisi(TabUretimDetay);
  end;


  TabUretimDetay.FieldByname('REHBERID').AsInteger := TabUretim.FieldByname('REHBERID').AsInteger;
  EkleyenDegistiren(DtsUretimDetay);
end;

procedure TUretimWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TUretimWizardDlg.MenuKopyalaClick(Sender: TObject);
begin
  //
  Tablo.SQLSatiriKopyala('URETIMOPERASYONPERSONEL', TabIsZaman.Fields[0].AsInteger, ['EKLEYEN','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
                  [ Kullanan, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
  CheckTamamlananlarClick(self);
end;

procedure TUretimWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TUretimWizardDlg.MenuTumKonularClick(Sender: TObject);
var Bugun : TDateTime;
begin
  if TabUretimDetay.IsEmpty then
     Showmessage(UROnceUretimEkle)
  else if TabUretimDetay.FieldByName('ADET').AsFloat < 0 then
     Showmessage(URUrunlerIcinKalite)
  else begin
     Tablo.TablodanSorguAc(3,'select ACIKLAMA from LOKASYON where DURUM=1 and TUR=8 and REHBERID=-1 order by KOD ');
     Bugun := Tablo.GENINI.BugunTrh;
     while not Tablo.Query3.eof do begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into URETIMOPERASYONPERSONEL (OPERASYONID, TARIH, BASLAMA, BITIS, MOLA, DURUM,KONUSU, EKLEYEN,YER)values('+TabUretimDetay.FieldByName('ID').AsString+','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('yyyy-mm-dd hh:nn',Bugun)+''','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('1899-12-30 00:00', now)+''','+
         '0,'''+Tablo.Query3.Fields[0].AsString+''','+Kullanan+',2)', [], []);
         Tablo.Query3.next;
     end;
    CheckTamamlananlarClick(self);
  end;
end;

function TUretimWizardDlg.MiktarSor(Mik:variant) : Real;
begin
  if YeniMiktar <> 1.0 then begin
    Mik := YeniMiktar;
    YeniMiktar := 1.0;
  end;
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(KWMiktariGirin,@Mik,4)) <> mrOk then begin
     TabUretimDetay.Cancel;
     Abort;
  end;
  Result := Mik;
end;

procedure TUretimWizardDlg.PopupGenelPopup(Sender: TObject);
begin
   IzlemBilgileriGorDegistirMenu.visible := (TabUretimDetay.FieldByName('TUR').AsInteger=1)and(TabUretimDetay.FieldByName('IZLEME').AsInteger > 0);
end;

procedure TUretimWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TUretimWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_URETIMFISI, TabUretim.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TUretimWizardDlg.TabUretimDetayNewRecord(DataSet: TDataSet);
var Mik:Real;
begin
  Mik := 1;
  //parçadan bütüne ise veya bütünden parçaya ama ürün çıkışı ise miktar sorarız ama sarf ise 1 adet olacağı için sormayız
  if (TabUretim.FieldByname('SENARYO').AsInteger=1)or((TabUretim.FieldByname('SENARYO').AsInteger=2)and(Carpan=1)) then //parçadan bütüne üretim
     Mik := MiktarSor(Mik);
  if (Carpan=-1)and(Mik>0) then
    Mik:= -1*Mik
  else if (Carpan=1)and(Mik<0) then
    Mik:= -1*Mik;
  TabUretimDetay.FieldByname('ADET').AsFloat := Mik;
  TabUretimDetay.FieldByname('MIKTAR').AsFloat := Mik;
  TabUretimDetay.FieldByName('DOVIZ_KURU').AsString := CariDoviz;
  TabUretimDetay.FieldByName('KUR').AsString := CariDoviz;
  TabUretimDetay.FieldByname('DOVIZKURDEGERI').AsFloat := 1.0;
  TabUretimDetay.FieldByname('FATBASID').AsInteger := UretimID;
  TabUretimDetay.FieldByname('REHBERID').AsInteger := 0;
  TabUretimDetay.FieldByName('STOKDURUMDEGIS').AsBoolean := True;
  TabUretimDetay.FieldByname('EKLEYEN').AsString := Kullanan;
  TabUretimDetay.FieldByname('EKIPMANID').AsInteger := Carpan;//1 ise ürün  -1 ise sarf
  if StrToIntDef(VarToStrDef(TabUretim.FieldByname('PROJEID').Value,'0'),0)>0 then
    TabUretimDetay.FieldByname('PROJEID').AsInteger := TabUretim.FieldByname('PROJEID').AsInteger;
end;


procedure TUretimWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if dtsUretim.State = dsInsert then
    tabUretim.Cancel
  else begin
    if (IptalSecildi) and ((IslemOp = 'E') or (IslemOp = 'K')) and (TabUretim.active) and (TabUretim.Fields[0].AsString <> '') then// eğer yeni kayıtsa ve iptal edildiyse kaydedilmiş bilgiler silinmesi lazım
      //if Tablo.UyariGoster(Uretim1,cxKayıt,2)=MrYes then
        Tablo.FaturaSil(TabUretim, TabUretimDetay);
    if (TabUretim.active)and(TabUretim.Fields[0].AsString <> '')and (TabUretimDetay.active)and(TabUretimDetay.IsEmpty) then // eğer hiç satır yok ise silinmesi gerekiyor..
       Tablo.FaturaSil(TabUretim,TabUretimDetay);
    if UretimWizardDlg<> nil then
       FreeAndNil(UretimWizardDlg);
  end;
end;

procedure TUretimWizardDlg.FormCloseQuery(Sender: TObject;  var CanClose: Boolean);
begin
   Ciksin := True;
   if KaydetTus.Visible then
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : begin
                Ciksin := False;
                WizardKontrolFinishButtonClick(Self);
               end;
       IDCANCEL:Ciksin := False;
      end;

   if (dtsUretim.State<>dsInsert)and(TabUretimDetay.IsEmpty) then begin
     Ciksin := True;
     Tablo.FaturaSil(TabUretim, TabUretimDetay);
   end;
   CanClose := Ciksin;
end;

procedure TUretimWizardDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.WizardTurkcelestir(WizardKontrol);
  LogID := 0;
  Carpan := 0;
  Tablo.GridTurkcelestir;
  IptalSecildi := True;
  YeniMiktar := 1;
  PageControlAlt.ActivePageIndex:=0;
end;

procedure TUretimWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos := Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bileşen Ekle
      ctrl := FindVCLWindow(Mouse.CursorPos);
      if Assigned(ctrl) then begin
         OutputDebugString(PChar(ctrl.Name));
         ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
         Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name), TUretimWizardDlg(Self), DtsUretim);
         Tablo.AlanOlustur(TUretimWizardDlg(Self), -1,DtsUretim);
      end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin//Bileşen Düzenle
      Tablo.AlanlarDlgBaslat('D',1,0,ctrlPos.X,ctrlPos.Y,0,FindComponent(EkAlanlarEkr.Name), TUretimWizardDlg(Self), DtsUretim);
      Tablo.AlanOlustur(TUretimWizardDlg(Self), -1, DtsUretim);
  end;
end;

function TUretimWizardDlg.EkranAdiAl: string;
begin
  Result := 'UretimFisDlg';
end;

procedure TUretimWizardDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

 // DovizKurDegeri := ;
  // Tablo.FaturaInit(Tur,ComboDURUM.Properties, TcxImageComboBoxProperties(GridFaturaViewTUR.Properties), TcxImageComboBoxProperties(GridFaturaViewBIRIM1.Properties));
  TabloYenile(TabUretim, [UretimID]);
  TabloYenile(TabUretimDetay, [UretimID]);
  if (IslemOp='E') and (UretimID < 1) then begin
    TabUretim.Append;
    FirmaBilgileri(RehberId);
  end
  else begin
    if TabUretim.FieldByName('SATICIKODU').AsString <> '' then
      ComboUretici.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabUretim.FieldByName('SATICIKODU').AsString);
    LogBelge.Clear;
    if TabUretimDetay.active then begin
      TabUretimDetay.First;
      while not TabUretimDetay.Eof do begin
        if LogGun>0 then begin
          Tablo.BelgeLogBelirle(TabUretimDetay);
        end;
        TabUretimDetay.Next;
      end;
    end;
  end;
  if TabUretim.FieldByName('PROJEID').AsString <> '' then begin
    BeditProje.Text := Tablo.AciklamaGetir('PROJELER','PROJEKODU',TabUretim.FieldByName('PROJEID').AsInteger);
    BeditProje.Tag := TabUretim.FieldByName('PROJEID').AsInteger;
  end;

  Tablo.AlanOlustur(TUretimWizardDlg(Self), -1, DtsUretim);


  if (IslemOp='D')and(KilitKontrolEt(2, 6, TabUretim.FieldByName('TARIH').AsDateTime,2)) then begin
     //Kilit := True;
     TabUretim.Close;
     TabUretim.Open;
     TabUretimDetay.Close;
     TabUretimDetay.Open;
     ToolBar5.visible := False;
     ToolBar3.visible := False;
     TabSheetGenel.enabled := False;
     TabIsVeZaman.enabled := False;
     cxTabSheet1.enabled := False;
     EkAlanlarEkr.enabled := False;
  end;

end;


procedure TUretimWizardDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TUretimWizardDlg.GridDetayViewInitEdit(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
// BILGI nvarchar olduğu için Date editor açılırken geçersiz değer (örn. 'r') varsa
// EConvertError fırlatıyor. Burada değeri kontrollü atayarak hatayı engelliyoruz.
var
  Raw: string;
  D: TDateTime;
begin
  if (AItem = cxGridDBColumn4) and (AEdit is TcxDateEdit) then begin
    Raw := Trim(TabDetay.FieldByName('BILGI').AsString);
    if (Raw <> '') and TryStrToDate(Raw, D) then
      AEdit.EditValue := D
    else
      AEdit.EditValue := Null;   // boş tarih ile aç, kullanıcı seçerse Post string'e çevirir
  end;
end;

procedure TUretimWizardDlg.cxGridDBColumn4GetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
// BILGI hücresinin editor'unu satırın REHBERAYAR.GIRIS koduna göre dinamik seç.
// GIRIS kod-tipi haritası (REHBERAYAR.GIRIS varchar değerleri):
//   '2' → sayı  → SpinItem
//   '3' → tarih → DateItem
//   diğer → default text edit (DFM'deki TcxTextEditProperties)
var
  GirisKod: string;
begin
  if not TabDetay.Active then Exit;
  GirisKod := Trim(TabDetay.FieldByName('GIRIS').AsString);
  if GirisKod = '3' then
    AProperties := Tablo.cxEditRepository1DateItem1.Properties
  else if GirisKod = '2' then
    AProperties := Tablo.cxEditRepository1SpinItem1.Properties;
end;

procedure TUretimWizardDlg.GridUretimDBTableView1CanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridUretim;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridUretimDBTableView1;
  AnaForm.pmGridStil.Tags.Values[GridUretim.Name] := 'UretimSihirbazDetayGridi';
end;

procedure TUretimWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TUretimWizardDlg.HesaplaTusClick(Sender: TObject);
begin
  Tablo.UretimSatirMaliyetUpdate(TabUretim.FieldByName('ID').AsInteger);
  TabloYenile(TabUretimDetay,[TabUretim.FieldByName('ID').AsInteger]);
end;

procedure TUretimWizardDlg.IptalTusClick(Sender: TObject);
begin
  TabUretim.Cancel;
end;

procedure TUretimWizardDlg.IsZamanDuzenleClick(Sender: TObject);
begin
  Tablo.IsEmriPersonelZamanSihirbaz('D', 2, TabUretimDetay.FieldByName('ID').AsInteger, TabIsZaman.FieldByName('ID').AsInteger,0);
  CheckTamamlananlarClick(self);
end;

procedure TUretimWizardDlg.IsZamanSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabIsZaman.Delete;
end;

procedure TUretimWizardDlg.IsZamanYeniClick(Sender: TObject);
begin
  if TabUretimDetay.IsEmpty then
     Showmessage(UROnceOperasyonEkle)
  else begin
     Tablo.TablodanSorguAc(1,'select TOP 1 ID from URETIMRECETE where STOKID='+TabUretimDetay.FieldByName('URUNID').AsString);
     if Tablo.Query1.IsEmpty then
        Showmessage(STRecete_bulunamadi)
     else
        Tablo.TablodanSorguAc(3,'select UO.KONUSU, UO.KAYNAK, UO.SIRA, UO.SURE, UO.ID from [dbo].[URETIMRECETEOPR] UO where UO.URETIMRECETEID = '+
              IntToStr(Tablo.Query1.Fields[0].AsInteger)+' order by UO.SIRA');

     Tablo.IsEmriPersonelZamanSihirbaz('E', 2, TabUretimDetay.FieldByName('ID').AsInteger, 0, Tablo.Query3.FieldByName('ID').AsInteger);
     CheckTamamlananlarClick(self);
  end;
end;

procedure TUretimWizardDlg.IzlemBilgileriGorDegistirMenuClick(Sender: TObject);
begin
    StokIzlemBilgisi( TabUretimDetay);
    if IzlemDlg3<>nil then begin //kaydetmesi için destroy etmemiz lazım
       IzlemDlg3.SatirID := TabUretimDetay.FieldByName('ID').AsInteger;
       FreeAndNil(IzlemDlg3);
    end;
end;

procedure TUretimWizardDlg.UretimDetayPageExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   if EkleDetay then
      Ekle(TabDetay,TabNo_URETIMFISI, tabUretim.FieldByName('ID').AsInteger,'Değiş');
end;

procedure TUretimWizardDlg.UretimDetayPagePage(Sender: TObject);
var
  Yeri: SmallInt;
  Raw: string;
  D: TDateTime;
  EskiBefore: TDataSetNotifyEvent;
  EskiAfter:  TDataSetNotifyEvent;
begin
    TabDetay.Close;
    TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
    TabDetay.Params[0].Value := TabNo_URETIMFISI;
    TabDetay.Params[1].Value := tabUretim.FieldByName('ID').AsInteger;
    TabDetay.Params[2].Value := ComboBolum.Text;
    TabDetay.Open;

    // GIRIS='3' (tarih) satırlarında BILGI nvarchar olduğu için boş ya da geçersiz
    // değerler cxDateEdit'i bozar — bunları NULL'a çevir, cxGrid IsNull olduğunda
    // dönüşüm denemez.
    EskiBefore := TabDetay.BeforePost;
    EskiAfter  := TabDetay.AfterPost;
    TabDetay.BeforePost := nil;
    TabDetay.AfterPost  := nil;
    TabDetay.DisableControls;
    try
      TabDetay.First;
      while not TabDetay.Eof do begin
        if Trim(TabDetay.FieldByName('GIRIS').AsString) = '3' then begin
          Raw := Trim(TabDetay.FieldByName('BILGI').AsString);
          if (Raw = '') or not TryStrToDate(Raw, D) then begin
            TabDetay.Edit;
            TabDetay.FieldByName('BILGI').Clear;
            TabDetay.Post;
          end;
        end;
        TabDetay.Next;
      end;
      TabDetay.First;
    finally
      TabDetay.EnableControls;
      TabDetay.BeforePost := EskiBefore;
      TabDetay.AfterPost  := EskiAfter;
    end;
end;

procedure TUretimWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
//
end;

procedure TUretimWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if TabUretimDetay.State in [dsEdit,dsInsert] then
     TabUretimDetay.Post;
  if TabUretim.State in [dsEdit,dsInsert] then
     TabUretim.Post;

  IptalSecildi := False;
  Ciksin:=True;
  ModalResult := mrOk;
end;

procedure TUretimWizardDlg.KaydetTusClick(Sender: TObject);
begin
  TabUretim.Post;
end;

procedure TUretimWizardDlg.LabelKodClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := Tablo.RehberAra_IDGetir(-1);
  if Id > 0 then begin
    if TabUretim.State <> dsBrowse then
      TabUretim.Post;
    TabUretim.Edit;
    TabUretim.FieldByName('REHBERID').AsInteger := Id;
    Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' order by VARSAYILAN desc');
    TabUretim.FieldByName('REHBERILETID').AsInteger := tablo.Query1.Fields[0].AsInteger;
    Tablo.FaturaBaslik(TabUretim,Id);
    FirmaBilgileri(Id);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set REHBERID='+tabUretim.FieldByName('REHBERID').AsString+' where REHBERID<=0 and FATBASID='+tabUretim.FieldByName('ID').AsString,[],[]);
    TabUretim.Post;
  end;
end;

procedure TUretimWizardDlg.LabelSablonClick(Sender: TObject);
begin
  if  trim(ComboBolum.Text) ='' then
   begin
     ShowMessage(cnst_SablonAdiBosOlamaz);
//     Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),pchar(Uyari), MB_OK+ MB_ICONWARNING);
     Abort;
   end;

  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := TabNo_URETIMFISI;
  RehberAyarDlg.Bolum := ComboBolum.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  UretimDetayPagePage(Self);
end;

procedure TUretimWizardDlg.LabelSevkClick(Sender: TObject);
var
  SQLText:String;
  st:TStringList;
begin
  if Not (TabUretim.State in [dsEdit,dsInsert]) then
    TabUretim.Edit;

    try
      st:=TStringList.Create;
      SQLText:='select ID,AD,'+
        ' ADRES=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=2),'+
        ' ILCE=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=6),'+
        ' IL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=8),'+
        ' ID_VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=20),'+
        ' ID_VERGINO=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=22)'+
        ' FROM REHBERILETISIM Firma where REHBERID='+TabUretim.FieldByName('REHBERID').AsString;
      if Tablo.ListedenBilgiGetir('Adres Seçiniz.',SQLText,st,[],'FWizardAdresSecimi',IletisimEkleClick,Tablo.FDCnn,IletisimEkleClick) then begin
         //FATBASLIK.FieldByName('REHBERILETID').AsString:=st.Strings[0];
         //EditButtonSevkAdresi.Text := st.Strings[1];
          TabUretim.FieldByName('REHBERILETID').AsString := st.Strings[0];
          LabelSevk.Caption := 'Sevk : '+ st.Strings[1];
      end;
    finally
      st.free;
    end;

end;

procedure TUretimWizardDlg.IletisimEkleClick(Sender: TObject);
var
  Id : integer;
  Ad : string;
begin
  Tablo.IletisimEkle(TabUretim.FieldByName('REHBERID').AsInteger, Id, Ad);
  TabUretim.FieldByName('REHBERILETID').AsInteger := Id;
   LabelSevk.Caption := 'Sevk : '+ Ad;
end;

procedure TUretimWizardDlg.FirmaBilgileri(RehberId:integer);
var s : string;
begin
  if TabUretim.FieldByName('REHBERILETID').AsInteger > 0 Then
     s := ' ID='+TabUretim.FieldByName('REHBERILETID').AsString
  else
     s := ' VARSAYILAN = 1 ';
  Tablo.TablodanSorguAc(1,'Select top 1 ID, AD from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and '+s);
  LabelSevk.Caption := Tablo.Query1.FieldByName('AD').AsString;
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  lblMusteriAdres.Caption := Adres + Tablo.tabCariBilgileri.FieldByName('ADRES').AsString + ' ' + Tablo.tabCariBilgileri.FieldByName('ILCE').AsString + ' / ' + Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  lblMusteriTel.Caption := isTel + Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
  lblMusteriEposta.Caption := EPosta + Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TUretimWizardDlg.ReetedenGetir1Click(Sender: TObject);
begin
   ReceteTus.Click;
end;

procedure TUretimWizardDlg.StokIzlemBilgisi(TabloDetay:TFDQuery);
var
  DetID,GDepo,CDepo,Tur:integer;
  GerekMiktar, Miktar : real;
  Degisemez:Boolean;
  UretimNo:string;
begin
    if TabloDetay.FieldByName('ID').Value <> null then
      DetID := TabloDetay.FieldByName('ID').AsInteger
    else
      DetID := 0;

    GerekMiktar := Abs(TabloDetay.FieldByName('MIKTAR').AsFloat);

    if TabloDetay.FieldByName('MIKTAR').AsFloat<0 then begin
       Tur := KasaTur_Uretim_Sarf;
       UretimNo:='0';
    end
    else begin
       Tur := 6;//KasaTur_Uretim_Urun;
       UretimNo:= TabUretim.FieldByName('FATURANO').AsString;// Üretim no alınır
    end;

    Tablo.TablodanSorguAc(1,'select MIKTARSEC from STOKLAR where ID = '+TabloDetay.FieldByName('URUNID').AsString);
    if Tablo.Query1.Fields[0].AsString = '1' then begin //bütünden parçaya
       GerekMiktar := 1;
       Miktar := 0;
    end else begin
       GerekMiktar := Abs(TabloDetay.FieldByName('MIKTAR').AsFloat);
       Miktar := GerekMiktar;
    end;

    Degisemez := (UTSKullanimda)and(not TabloDetay.IsEmpty)and(Tablo.IzlemBildirimSayisi(TabUretim.FieldByName('TUR').AsInteger, 0,
                        TabloDetay.FieldByName('ID').AsInteger, TabUretim.FieldByName('FATURATARIH').AsDateTime)>0);
//   if Degisemez then
//       Tablo.UyariGoster(Uyari, BildirimYapilmisDegisemez);


    if not Anaform.StokIzleme(IzlemDlg3, TabloDetay.FieldByName('URUNID').AsInteger, TabloDetay.FieldByName('IZLEME').AsInteger,
       Tur, 1, TabUretim.FieldByName('ID').AsInteger,DetID, 0, TabUretim.FieldByName('GIRISDEPO').AsInteger, TabUretim.FieldByName('CIKISDEPO').AsInteger,
       GerekMiktar, Miktar, Degisemez, '',0,0,True,UretimNo) then begin
       FreeAndNil(IzlemDlg3);
       TabloDetay.Cancel;
       Abort;
    end;

    if TabUretim.FieldByname('SENARYO').AsInteger=2 then begin //bütünden parçaya üretim
       //Miktar := MiktarSor(Miktar);
       if (Carpan=-1)and(Miktar>0) then Miktar:= -1*Miktar
       else if (Carpan=1)and(Miktar<0) then Miktar:= -1*Miktar;
       if TabloDetay.state = dsBrowse then
          TabloDetay.Edit;
       TabloDetay.FieldByname('ADET').AsFloat := Miktar;
       TabloDetay.FieldByname('MIKTAR').AsFloat := Miktar;
    end;
end;

function TUretimWizardDlg.RecetedenEkle(ReceteID:integer;Miktar:extended;UrunudeEkle:Boolean):boolean;
var
  UrunID:integer;
  Yetersiz:boolean;
begin
  Tablo.TablodanSorguAc(9,'select ID,STOKID, '+
          ' MALIYETSON=(select top 1 SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI=-1),'+
          ' MALIYETORT=(select top 1 SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI=-2), '+
          ' SATIS=(select top 1 SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI='+IntToStr(VarsSatisFiyatID)+'), '+
          ' BIRIM=(select S.ANABIRIM from STOKLAR S where S.ID=UR.STOKID)'+
          ' from URETIMRECETE UR where  ID='+IntToStr(ReceteID));
  UrunID := Tablo.Query9.Fields[1].AsInteger;

  //19.02.2022 AO
  //Önce bu reçetedeki ürünler depoda var mı kontrol edelim

  Tablo.Query2.SQL.text :='select URD.URUNID, URD.ADET*'+Float_ToStr(Miktar)+', S.KOD'+
                       ' from URETIMRECETEDETAY URD inner join STOKLAR S on URD.URUNID=S.ID  where URETIMRECETEID='+IntToStr(ReceteID);
  //if not UrunudeEkle then
     Tablo.Query2.SQL.Add(' and URD.URUNID <> '+IntToStr(UrunID));
  Tablo.Query2.open;
  Yetersiz:=False;
  while not Tablo.Query2.eof do begin
    if not Tablo.StokVarmi( Tablo.Query2.Fields[0].AsInteger, TabUretim.FieldByName('CIKISDEPO').AsInteger, abs(Tablo.Query2.Fields[1].AsFloat), Tablo.Query2.Fields[2].AsString) then begin
       Yetersiz := True;
       //TabFATURA.Cancel;
    end;
    Tablo.Query2.next;
  end;
  if Yetersiz then begin
     result := False;
     exit;
  end;

  ////
  if dtsUretim.State in [dsEdit,dsInsert] then
    TabUretim.Post;
  TabUretim.Edit;
  TabUretim.FieldByName('AKTIVITEID').AsInteger:=Tablo.Query9.Fields[1].AsInteger;// STOKID=AKTIVITEID
  TabUretim.FieldByName('STOKISK').AsFloat:=Miktar;    //   MIKTAR=STOKISK
  TabUretim.FieldByName('FATURA_MATRAHI').AsFloat:=Tablo.Query9.Fields[2].AsFloat;
  TabUretim.FieldByName('FATURA_TUTARI').AsFloat:=Tablo.Query9.Fields[3].AsFloat;
  TabUretim.Post;
  TabUretim.Edit;
  TabUretim.FieldByName('KUR').AsString := CariDoviz;
  TabUretim.FieldByName('EKVERGI').AsFloat:=Tablo.Query9.Fields[4].AsFloat;  //  LISTE_FIYATI=EKVERGI
  if TabUretim.FieldByName('REHBERID').AsInteger<=0 then
     TabUretim.FieldByName('REHBERID').AsInteger := SubeId;
  TabUretim.FieldByName('DOVIZKUR').AsFloat := DovizKurDegeri;
  TabUretim.FieldByName('DOVIZ_CINSI').AsString := VarsDoviz;
  TabUretim.Post;
  TabUretim.Edit;
  TabUretim.FieldByName('KDV_TUTARI').AsFloat := Tablo.Query9.Fields[2].AsFloat/DovizKurDegeri;
  TabUretim.FieldByName('DOVIZ_TUTARI').AsFloat := Tablo.Query9.Fields[3].AsFloat/DovizKurDegeri;
  TabUretim.FieldByName('SAYFA').AsInteger := Tablo.Query9.Fields[5].AsInteger;//Birim    BIRIM=SAYFA
  TabUretim.FieldByName('YERI').AsInteger := TabNo_URETIMRECETE;//138
  TabUretim.FieldByName('YERID').AsInteger := Tablo.Query9.Fields[0].AsInteger;
  TabUretim.Post;

  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
  Tablo.Query2.SQL.Add(',DOVIZ_BIRIMFIYAT,DOVIZ_KURU,DOVIZ_TUTARI,DOVIZKURDEGERI,MASRAFID,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,IADEADET,VADE,EKIPMANID,SIRA)  ');
  Tablo.Query2.SQL.Add('select '+TabUretim.FieldByName('ID').AsString+',-1,URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+Float_ToStr(Miktar)+
//AO 02/01/2021       ',URD.BIRIM,MIKTAR=URD.MIKTAR*'+Float_ToStr(Miktar)+',MALIYETSON=ABS(MIKTAR*MALIYETSON*'+Float_ToStr(Miktar)+'),MALIYETORT=ABS(MIKTAR*MALIYETORT*'+Float_ToStr(Miktar)+'),'''+CariDoviz+''',0,0,S.KDV,'+
       ',URD.BIRIM,MIKTAR=URD.MIKTAR*'+Float_ToStr(Miktar)+',MALIYETSON=ABS(MIKTAR*MALIYETSON),MALIYETORT=ABS(MIKTAR*MALIYETORT),'''+CariDoviz+''',0,0,S.KDV,'+
       'ABS((MIKTAR*MALIYETSON*'+Float_ToStr(Miktar)+')/'+Float_ToStr(DovizKurDegeri)+'),'''+VarsDoviz+''',ABS((MIKTAR*MALIYETORT*'+Float_ToStr(Miktar)+')/'+Float_ToStr(DovizKurDegeri)+'),'+Float_ToStr(DovizKurDegeri));
  Tablo.Query2.SQL.Add(',URD.MASRAFID,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,URD.ADETHESAP,ANAURUN,EKIPMANID=case when URD.MIKTAR>0.0 then 1 else -1 end,URD.SIRA ');
  Tablo.Query2.SQL.Add(' from URETIMRECETEDETAY URD inner join STOKLAR S on URD.URUNID=S.ID where URETIMRECETEID='+IntToStr(ReceteID));
  if not UrunudeEkle then
    Tablo.Query2.SQL.Add(' and URD.URUNID <> '+IntToStr(UrunID));

  Tablo.Query2.SQL.Add(' order by URD.SIRA ');
  Tablo.Query2.ExecSQL;

  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'update FATURA set OZELKOD='''' where FATBASID='+TabUretim.FieldByName('ID').AsString ;
  Tablo.Query2.ExecSQL;

  TabUretim.Edit;
  TabUretim.FieldByName('YERI').AsInteger := TabNo_URETIMRECETE;
  TabUretim.FieldByName('YERID').AsInteger := ReceteID;
  TabUretim.Post;
  //Eğer ürettiğimiz ürünlerin izlemi (serino vb) varsa
  // Query20.SQL.Text := ' select * from FATURA F where FATBASID='+TabUretim.FieldByName('ID').AsString+' and IZLEME  between 1 and 6 ';    ,,,
  // 25.03.2022  AO  değişti
   Query20.SQL.Text := ' select * from FATURA F where FATBASID='+TabUretim.FieldByName('ID').AsString+' and IZLEME  between 1 and 6 '+
                       ' and F.ID not in (select SATIRID from STOKIZLEME where FATBASID='+TabUretim.FieldByName('ID').AsString+')';
  ///
  Query20.Open;
  while not Query20.eof do begin
    StokIzlemBilgisi(Query20);
    if IzlemDlg3<>nil then begin //kaydetmesi için destroy etmemiz lazım
       IzlemDlg3.SatirID := Query20.FieldByName('ID').AsInteger;
       FreeAndNil(IzlemDlg3);
    end;
    Query20.Next;
  end;
end;

procedure TUretimWizardDlg.RecetedenKonularEkleMenuClick(Sender: TObject);
begin
 //  KonularEkle(0); //tümünü
  if TabUretimDetay.IsEmpty then
     Showmessage(UROnceUretimEkle)
  else if TabUretimDetay.FieldByName('ADET').AsFloat < 0 then
     Showmessage(URUrunlerIcinKalite)
  else begin
     Tablo.TablodanSorguAc(1,'select TOP 1 ID from URETIMRECETE where STOKID='+TabUretimDetay.FieldByName('URUNID').AsString);
     if Tablo.Query1.IsEmpty then
        Showmessage(STRecete_bulunamadi)
     else begin
        Tablo.KonularEkleOrtak(TabUretimDetay, 0, 2, Tablo.Query1.Fields[0].AsInteger);
        CheckTamamlananlarClick(self);
     end;
  end;
end;

procedure TUretimWizardDlg.ReceteTusClick(Sender: TObject);
var
  ReceteID:Integer;
  Miktar : Variant;
begin
  Miktar := 1.0;
  if not TabUretimDetay.IsEmpty then
    raise Exception.Create(URIslemVarReceteAktarilmaz);

  if TabUretim.IsEmpty then
     TabUretim.Append;
  ReceteID := Tablo.ReceteSihirbazBaslat(0,'S');//Seçim modunda açılır..
  if ReceteID>0 then begin
    if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(BGUretim_miktari_gir, @Miktar, 6)) = mrOk then
       RecetedenEkle(ReceteID,Miktar,True);
  end;

  if CheckOtomatikHesapla.checked then
     Tablo.UretimSatirMaliyetUpdate(TabUretim.FieldByName('ID').AsInteger);
  TabloYenile(TabUretimDetay,[TabUretim.FieldByName('ID').AsInteger]);
end;

procedure TUretimWizardDlg.Reeteler1Click(Sender: TObject);
begin
  Application.CreateForm(TUretimReceteDlg,UretimReceteDlg);
  UretimReceteDlg.ShowModal;
  FreeAndNil(UretimReceteDlg);
end;

procedure TUretimWizardDlg.ReeteOlarakKaydet1Click(Sender: TObject);
var
  RecKod,RecAd: Variant;
  ReceteID: Integer;
begin
  TabUretimDetay.FetchAll;
  if TabUretimDetay.Recordcount<2 then
    showmessage(URYeterliKayitUyarisi)
  else begin
    RecKod := '';
    RecAd := '';
    if TGirisKutusuEx.BilgiAlEx(BGRecete_bilgileri, TGirdiDenetimleri.Create.Edit(BGRecete_kodu_gir, @RecKod).Edit(BGRecete_adi_gir, @RecAd)) = mrOk then begin
      if (RecKod<>'')and(RecAd<>'') then begin
        //başlık bilgisini kaydedelim..
        ReceteID := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into URETIMRECETE(KOD,AD)values(&KOD,&AD) select SCOPE_IDENTITY()'
                                                ,['&KOD','&AD'],[RecKod,RecAd],True);
        //detaylarda dönelim..
        TabUretimDetay.First;
        while not TabUretimDetay.eof do begin
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into URETIMRECETEDETAY(URETIMRECETEID,TUR,URUNID,ADET,BIRIM,MIKTAR,EKLEYEN)values(&URID,&TUR,&URUNID,&ADET,&BIRIM,&MIKTAR,&EKLEYEN)'
                                                ,['&URID','&TUR','&URUNID','&ADET','&BIRIM','&MIKTAR','&EKLEYEN']
                                                ,[ReceteID,TabUretimDetay.FieldByName('TUR').AsInteger,TabUretimDetay.FieldByName('URUNID').AsInteger,TabUretimDetay.FieldByName('ADET').AsFloat,TabUretimDetay.FieldByName('BIRIM').AsInteger,TabUretimDetay.FieldByName('MIKTAR').AsFloat,Kullanan]);
          TabUretimDetay.Next;
        end;
        Tablo.ReceteSihirbazBaslat(ReceteID);
      end else
        showmessage(URKodAdUyarisi);
    end;
  end;
end;

procedure TUretimWizardDlg.ReeteyeGreMiktarAyarla1Click(Sender: TObject);
var
  ReceteID:Integer;
  UretimPlanID,UretimPlanDetayID:Variant;
  Miktar : Variant;
begin
{  if TabUretim.State in [dsEdit,dsInsert] then
    TabUretim.Post;
  if TabUretim.FieldByName('YERI').AsString = '' then begin
    ShowMessage('Üretilen reçeteli bir ürün yok veya seçili ürünlerin reçete bağlantısı yok!');
  end else if TabUretim.FieldByName('YERI').AsInteger = TabNo_URETIMOPERASYON then begin
    //  -----------------------------------------------------  \\
      Tablo.TablodanSorguAc(9,'select * from URETIMOPERASYON where ID='+TabUretim.FieldByName('YERID').AsString);
      if Tablo.Query9.IsEmpty then begin
        ShowMessage('Bağlı Operasyon bulunamıyor. Lütfen fişi silerek tekrar oluşturun!');
        Abort;
      end;
      Tablo.TablodanSorguAc(8,'select * from URETIMEMRIDETAY where ID='+Tablo.Query9.FieldByName('URETIMEMRIDETAYID').AsString);
      if Tablo.Query9.IsEmpty then begin
        ShowMessage('Bağlı üretim emri bulunamıyor. Lütfen fişi silerek tekrar oluşturun!');
        Abort;
      end;

      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(BGUretim_miktari_gir, @Miktar, 0)) = mrOk then begin
        if Miktar<=0.0 then begin
          ShowMessage('Geçersiz Miktar Girişi!');
          Abort;
        end;


        if Tablo.Query9.FieldByName('URETIMPLANID').AsString <> '' then
          UretimPlanID := Tablo.Query9.FieldByName('URETIMPLANID').AsInteger
        else
          UretimPlanID := 0;
        if Tablo.Query9.FieldByName('URETIMPLANDETAYID').AsString <> '' then
          UretimPlanDetayID := Tablo.Query9.FieldByName('URETIMPLANDETAYID').AsInteger
        else
          UretimPlanDetayID := 0;
        //Reçeteden Kaynak eklenir
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'delete from FATURA where FATBASID='+TabUretim.FieldByName('ID').AsString ;
        Tablo.Query2.ExecSQL;
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
        Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
        Tablo.Query2.SQL.Add('select '+TabUretim.FieldByName('ID').AsString+',0,UE.TUR,UE.URUNID,UE.ACIKLAMA,UE.ADET,UE.BIRIM,UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
        Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
        Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
        Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID ');
        Tablo.Query2.SQL.Add(' where UE.URETIMEMRIID='+Tablo.Query9.FieldByName('URETIMEMRIID').AsString+' and KAYNAKRECETEID='+Tablo.Query9.FieldByName('RECETEID').AsString);
        Tablo.Query2.ExecSQL;
        //Reçeteden Hedefler eklenir.. - ile çarpılarak.. ustid nin kaynak olması da gerekiyor..
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
        Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
        Tablo.Query2.SQL.Add('select '+TabUretim.FieldByName('ID').AsString+',0,UE.TUR,UE.URUNID,UE.ACIKLAMA,-UE.ADET,UE.BIRIM,-UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
        Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
        Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
        Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID ');
        Tablo.Query2.SQL.Add(' where UE.URETIMEMRIID='+Tablo.Query9.FieldByName('URETIMEMRIID').AsString +' and UE.HEDEFRECETEID='+Tablo.Query9.FieldByName('RECETEID').AsString);
        Tablo.Query2.SQL.Add(' and UE.USTID='+Tablo.Query9.FieldByName('URETIMEMRIDETAYID').AsString);
        Tablo.Query2.ExecSQL;
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'update FATURA set ';
        Tablo.Query2.SQL.Add('MIKTAR=((MIKTAR/'+FormatFloat('#.######',Tablo.Query8.FieldByName('MIKTAR').AsFloat)+')*'+FormatFloat('#.######',Miktar)+'),');
        Tablo.Query2.SQL.Add('ADET=((ADET/'+FormatFloat('#.######',Tablo.Query8.FieldByName('MIKTAR').AsFloat)+')*'+FormatFloat('#.######',Miktar)+')');
        Tablo.Query2.SQL.Add(' where FATBASID='+TabUretim.FieldByName('ID').AsString);
        Tablo.Query2.ExecSQL;
      end;
    //  -----------------------------------------------------  \\
  end else if TabUretim.FieldByName('YERI').AsInteger = TabNo_URETIMRECETE then begin
    Miktar := 1.0;
    ReceteID := TabUretim.FieldByName('YERID').AsInteger;//Seçim modunda açılır..
    if ReceteID>0 then begin
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(BGUretim_miktari_gir, @Miktar, 0)) = mrOk then begin
        if Miktar<=0.0 then begin
          ShowMessage('Geçersiz Miktar Girişi!');
          Abort;
        end;
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'delete from FATURA where FATBASID='+TabUretim.FieldByName('ID').AsString ;
        Tablo.Query2.ExecSQL;
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
        Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,MASRAFID,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID)  ');
        Tablo.Query2.SQL.Add('select '+TabUretim.FieldByName('ID').AsString+',-1,URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+FormatFloat('#.######',Miktar)+',URD.BIRIM,URD.MIKTAR*'+FormatFloat('#.######',Miktar)+',0,0,'''+CariDoviz+''',0,0,S.KDV,0,'''+CariDoviz+''',0,1  ');
        Tablo.Query2.SQL.Add(',URD.MASRAFID,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID ');
        Tablo.Query2.SQL.Add(' from URETIMRECETEDETAY URD inner join STOKLAR S on URD.URUNID=S.ID where URETIMRECETEID='+IntToStr(ReceteID));
        Tablo.Query2.ExecSQL;
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'update FATURA set OZELKOD='''' where FATBASID='+TabUretim.FieldByName('ID').AsString ;
        Tablo.Query2.ExecSQL;
      end;
    end;
  end;

  TabloYenile(TabUretimDetay,[TabUretim.FieldByName('ID').AsInteger]);
     }
end;

procedure TUretimWizardDlg.SatirIptalClick(Sender: TObject);
begin
  TabUretimDetay.Cancel;
end;

procedure TUretimWizardDlg.SatirKaydetClick(Sender: TObject);
begin
  TabUretimDetay.Post;
end;

procedure TUretimWizardDlg.SatirSilClick(Sender: TObject);
var Silinebilir : boolean;
begin
           //Üretimde sarf satırı ise kontrole almıyoruz..
   Silinebilir := True;
   if TabUretimDetay.FieldByName('ADET').Value > 0 then begin
       if TabUretimDetay.FieldByName('IZLEME').AsInteger = 0 then begin //izlem yoksa
          if Tablo.KullanimSayisi(TabUretim.FieldByName('TUR').AsInteger, 0, TabUretimDetay.FieldByName('ID').AsInteger, TabUretimDetay.FieldByName('URUNID').AsInteger, TabUretim.FieldByName('FATURATARIH').AsDateTime)>0 then
             Silinebilir := False;
       end
       else begin
          //İts kullanımda ve bildirim yapılmışsa fatura silinemez
          if Tablo.IzlemBildirimSayisi(TabUretim.FieldByName('TUR').AsInteger, 0, TabUretimDetay.FieldByName('ID').AsInteger, TabUretim.FieldByName('FATURATARIH').AsDateTime)>0  then
             Silinebilir := False;
       end;

   end;
   if (Silinebilir) and (Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_YES) then begin
         if TabUretimDetay.FieldByName('ADET').AsFloat > 0 then
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' DELETE SL FROM FATURA F ' +
           		' INNER JOIN STOKIZLEME SI ON SI.BASLIKID = F.FATBASID AND SI.SATIRID = F.ID AND SI.BELGETUR = 6 '+
		          ' INNER JOIN STOKSERILOT SL ON SL.STOKID = SI.STOKID AND SL.ID = SI.SERILOTID '+
              ' WHERE F.ID = '+TabUretimDetay.FieldByName('ID').AsString+' AND F.ADET > 0 AND NOT EXISTS(SELECT SI1.* FROM STOKIZLEME SI1 WHERE SI1.STOKID = SI.STOKID AND SI1.SERILOTID = SL.ID AND SI1.ID <> SI.ID)',[],[]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where BASLIKID=&BID and SATIRID=&SID',['&BID','&SID'],[TabUretim.FieldByName('ID').AsString,TabUretimDetay.FieldByName('ID').AsString]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKLOKASYON where BASLIKID=&BID and SATIRID=&SID',['&BID','&SID'],[TabUretim.FieldByName('ID').AsString,TabUretimDetay.FieldByName('ID').AsString]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from FATURA where ID='+TabUretimDetay.Fields[0].AsString,[],[]);
         TabloYenile(TabUretimDetay, [TabUretim.FieldByname('ID').AsInteger]);
   end;
end;

procedure TUretimWizardDlg.URETIMADETChange(Sender: TField);
begin
  TabUretimDetay.FieldByName('BIRIMFIYAT').OnChange:=nil;
  TabUretimDetay.FieldByName('BIRIM').OnChange:=nil;
//  if (TabUretimDetay.FieldByName('ADET').AsString <> '') and (TabUretimDetay.FieldByName('BIRIMFIYAT').AsString <> '') then
//      TabUretimDetay.FieldByName('TUTAR').AsCurrency := (100 - TabUretimDetay.FieldByName('ISKONTO').AsFloat) * TabUretimDetay.FieldByName('ADET').AsFloat * TabUretimDetay.FieldByName('BIRIMFIYAT').AsFloat / 100;
  TabUretimDetay.FieldByName('MIKTAR').AsFloat := TabUretimDetay.FieldByName('ADET').AsFloat * Tablo.StokCarpan(TabUretimDetay.FieldByName('URUNID').AsInteger, TabUretimDetay.FieldByName('BIRIM').AsInteger);
end;

procedure TUretimWizardDlg.TabUretimNewRecord(DataSet: TDataSet);
var
   belgeno : TBelgeNo;
begin
  TabUretim.FieldByname('TARIH').Value := Tablo.GENINI.BugunTrhSaat;    //BASLAMA_TARIHI= TARIH
  belgeno:= SiradakiBelgeNumarasi(6,TabUretim.FieldByName('TARIH').AsDateTime);
  TabUretim.FieldByName('FATURANO').AsString := belgeno.belgeno; //UretimNoGetir;   URETIMNO=FATURANO
  TabUretim.FieldByName('KOCANNO').AsInteger := KocannoBul(6); //KOCAN numarası
  TabUretim.FieldByname('REHBERID').AsInteger := RehberId;
  Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' order by VARSAYILAN desc');
  TabUretim.FieldByName('REHBERILETID').AsInteger := tablo.Query1.Fields[0].AsInteger;
  TabUretim.FieldByname('FATURATARIH').Value := Tablo.GENINI.BugunTrhSaat;         // BITIS_TARIHI=FATURATARIH
  TabUretim.FieldByname('TUR').AsInteger := 6;
  TabUretim.FieldByname('TIPI').AsInteger := 1;
  TabUretim.FieldByname('DURUM').AsInteger := 0;
  TabUretim.FieldByname('REHBERID').AsInteger := 0;
  TabUretim.FieldByname('ACIKLAMA').AsString := '';
  TabUretim.FieldByname('EKLEYEN').AsString := Kullanan;
  TabUretim.FieldByname('GIRISDEPO').AsInteger := StrToIntDef(GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'), 1);
  TabUretim.FieldByname('CIKISDEPO').AsInteger := StrToIntDef(GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'), 1);
  TabUretim.FieldByname('SENARYO').AsInteger := Tablo.GENINI.ReadInteger(Ops_Uretim_Senaryo, 1);
  TabUretim.FieldByName('KUR').AsString := CariDoviz;
  TabUretim.FieldByName('RAPORDOVIZ').AsString := CariDoviz;
  TabUretim.FieldByName('DOVIZ_CINSI').AsString := CariDoviz;
  TabUretim.FieldByName('FATURADOVIZI').AsString := CariDoviz;
  TabUretim.FieldByName('DOVIZKUR').Ascurrency := 1.0;
end;


initialization
  RegisterClass(TCurrencyField);

end.










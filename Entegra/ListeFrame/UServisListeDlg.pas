unit UServisListeDlg;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 07/12/2010 10:47:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, Menus,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxGraphics,
  UServisAramaFrame, dxSkinsCore, cxStyles, cxCustomData, dxBarBuiltInMenu,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses, cxDBTL,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,
  cxSplitter, cxPC, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky,Utablo,
  cxCheckBox, cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu,
  JvTimer, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxTLData,
  dxSkinLiquidSky, cxHyperLinkEdit, dxSkinscxPCPainter, cxLabel, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, cxGridCustomPopupMenu,
  cxGridPopupMenu, OfficePopupMenu, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, frCoreClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

//TODO: liste için index oluşturulacak..
//TODO: emrenin bütün servislerinde yeni dışında aktif servisleri gözükmüyor.

type
  TServisListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )//IAracCubuguDestegi)
    DtsServisler: TDataSource;
    SERVIS: TFDQuery;
    cxSplitter1: TcxSplitter;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
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
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    GridServisViewKOD1: TcxGridDBColumn;
    GridServisViewACIKLAMA1: TcxGridDBColumn;
    GridServisViewADET1: TcxGridDBColumn;
    GridServisViewBIRIM1: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    GridKabul: TcxGrid;
    GridKabulView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    SQLMemo: TcxMemo;
    JvTimer1: TJvTimer;
    TabSheetGenel: TcxTabSheet;
    SQLGenelTekTus: TcxMemo;
    SQLGenelCokTus: TcxMemo;
    TabGenel: TFDQuery;
    DtsGenel: TDataSource;
    GenelTreeList: TcxDBTreeList;
    GenelTreeListROOTKOD: TcxDBTreeListColumn;
    GenelTreeListID: TcxDBTreeListColumn;
    GenelTreeListSERVISID: TcxDBTreeListColumn;
    GenelTreeListKOD: TcxDBTreeListColumn;
    GenelTreeListGRUP: TcxDBTreeListColumn;
    GenelTreeListAD: TcxDBTreeListColumn;
    GenelTreeListACIKLAMA: TcxDBTreeListColumn;
    GenelTreeListCOZUM: TcxDBTreeListColumn;
    TabSmsEPosta: TFDQuery;
    DtsSmsEPosta: TDataSource;
    cxTabSheet2: TcxTabSheet;
    cxTabSheet3: TcxTabSheet;
    GridHareketler: TcxGrid;
    GridHareketlerDBTableView1: TcxGridDBTableView;
    GridHareketlerDBTableView1DURUM: TcxGridDBColumn;
    GridHareketlerDBTableView1PERSONEL: TcxGridDBColumn;
    GridHareketlerDBTableView1BASLAMA: TcxGridDBColumn;
    GridHareketlerDBTableView1BITIS: TcxGridDBColumn;
    GridHareketlerDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridHareketlerDBTableView1UYARITURU: TcxGridDBColumn;
    GridHareketlerDBTableView1DISUYARITURU: TcxGridDBColumn;
    GridHareketlerLevel1: TcxGridLevel;
    TabHareketler: TFDQuery;
    DtsHareketler: TDataSource;
    TabServisBelge: TFDQuery;
    DtsServisBelge: TDataSource;
    frxServisBelge: TfrxDBDataset;
    cxGridBelgeler: TcxGrid;
    cxGridBelgelerDBTableView1: TcxGridDBTableView;
    cxGridBelgelerDBTableView1TUR: TcxGridDBColumn;
    cxGridBelgelerDBTableView1KAYNAK: TcxGridDBColumn;
    cxGridBelgelerDBTableView1HEDEF: TcxGridDBColumn;
    cxGridBelgelerDBTableView1TARIH: TcxGridDBColumn;
    cxGridBelgelerDBTableView1BELGENO: TcxGridDBColumn;
    cxGridBelgelerDBTableView1TUTAR: TcxGridDBColumn;
    cxGridBelgelerDBTableView1KUR: TcxGridDBColumn;
    cxGridBelgelerDBTableView1FIRMA: TcxGridDBColumn;
    cxGridBelgelerDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridBelgelerLevel1: TcxGridLevel;
    frxHareketler: TfrxDBDataset;
    frxGENEL: TfrxDBDataset;
    GridHareketlerDBTableView1SURE: TcxGridDBColumn;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    TabYorum: TFDQuery;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    PageControlServis: TcxPageControl;
    TabServis: TcxTabSheet;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton3: TToolButton;
    DegisTus: TToolButton;
    ToolButton1: TToolButton;
    YaziciYaz: TToolButton;
    GridServis: TcxGrid;
    GridServisView: TcxGridDBTableView;
    GridServisViewDURUM: TcxGridDBColumn;
    GridServisViewEKLEMETARIHI: TcxGridDBColumn;
    GridServisViewBASLAMATARIHI: TcxGridDBColumn;
    GridServisViewBITISTARIHI: TcxGridDBColumn;
    GridServisViewTOPLAM_SURE: TcxGridDBColumn;
    GridServisViewCALISMA_SURESI: TcxGridDBColumn;
    GridServisViewID: TcxGridDBColumn;
    GridServisViewServisNO: TcxGridDBColumn;
    GridServisViewTURU: TcxGridDBColumn;
    GridServisViewKATEGORIAD: TcxGridDBColumn;
    GridServisViewKONU: TcxGridDBColumn;
    GridServisViewURUNADI: TcxGridDBColumn;
    GridServisViewFIRMA: TcxGridDBColumn;
    GridServisViewSORUN_TIPI: TcxGridDBColumn;
    GridServisViewSORUN_ACIKLAMA: TcxGridDBColumn;
    GridServisViewSORUN_SONUCU: TcxGridDBColumn;
    GridServisViewSORUMLUAD: TcxGridDBColumn;
    GridServisViewFATURATARIH: TcxGridDBColumn;
    GridServisViewFATURANO: TcxGridDBColumn;
    GridServisViewFATURA_TUTARI: TcxGridDBColumn;
    GridServisViewNOTLAR: TcxGridDBColumn;
    GridServisViewSUBEID: TcxGridDBColumn;
    GridServisViewSERINO: TcxGridDBColumn;
    GridServisViewKABUL_EDENAD: TcxGridDBColumn;
    GridServisViewKABUL_SEKLI: TcxGridDBColumn;
    GridServisViewKABULNOTU: TcxGridDBColumn;
    GridServisViewKABUL_YAZISI_TURU: TcxGridDBColumn;
    GridServisViewTESLIM_ALANAD: TcxGridDBColumn;
    GridServisViewTESLIM_EDENAD: TcxGridDBColumn;
    GridServisViewTESLIM_TARIHI: TcxGridDBColumn;
    GridServisViewTESLIM_SEKLI: TcxGridDBColumn;
    GridServisViewTESLIMNOTU: TcxGridDBColumn;
    GridServisViewKAPSAM: TcxGridDBColumn;
    GridServisViewACIL: TcxGridDBColumn;
    GridServisViewDISSERVIS: TcxGridDBColumn;
    GridServisViewSERVISADRESI: TcxGridDBColumn;
    GridServisViewMUS_ILGILIAD: TcxGridDBColumn;
    GridServisViewLokasyon: TcxGridDBColumn;
    GridServisViewEKLEYEN: TcxGridDBColumn;
    GridServisLevel1: TcxGridLevel;
    Tabhareket: TcxTabSheet;
    ToolBar2: TToolBar;
    HareketServisEkleTus: TToolButton;
    HareketSilTus: TToolButton;
    ToolButton5: TToolButton;
    HareketDegisTus: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    GridHareket: TcxGrid;
    GridHareketView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    HareketEkleTus: TToolButton;
    HAREKET: TFDQuery;
    DtsHAREKET: TDataSource;
    GridHareketViewID: TcxGridDBColumn;
    GridHareketViewSHID: TcxGridDBColumn;
    GridHareketViewBASLAMA: TcxGridDBColumn;
    GridHareketViewBITIS: TcxGridDBColumn;
    GridHareketViewKOD: TcxGridDBColumn;
    GridHareketViewFIRMA: TcxGridDBColumn;
    GridHareketViewMUS_ILGILIAD: TcxGridDBColumn;
    GridHareketViewCALISMA_SURESI: TcxGridDBColumn;
    GridHareketViewEKIPMANAD: TcxGridDBColumn;
    GridHareketViewKONUSU: TcxGridDBColumn;
    GridHareketViewDURUM: TcxGridDBColumn;
    GridHareketViewPERSONEL: TcxGridDBColumn;
    GridHareketViewPROJEAD: TcxGridDBColumn;
    GridHareketViewHAREKETEKLEYENAD: TcxGridDBColumn;
    GridHareketViewEKLEMETARIHI: TcxGridDBColumn;
    cxSplitterHareket: TcxSplitter;
    PanelMedya: TPanel;
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
    GridHareketViewSERVISNO: TcxGridDBColumn;
    GridHareketViewBITISSEC: TcxGridDBColumn;
    ButtonServis: TToolButton;
    PopupMenuHareket: TPopupMenu;
    MenuItem1: TMenuItem;
    PopupMenuServis: TPopupMenu;
    ServisInfoMenu: TMenuItem;
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    procedure GridServisViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure SERVISAfterOpen(DataSet: TDataSet);
    procedure cxPageControl1Change(Sender: TObject);
    procedure GridServisViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridKabulViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure AraStokKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure JvTimer1Timer(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure HAREKETAfterOpen(DataSet: TDataSet);
    procedure PageControlServisChange(Sender: TObject);
    procedure HareketServisEkleTusClick(Sender: TObject);
    procedure HareketEkleTusClick(Sender: TObject);
    procedure HareketDegisTusClick(Sender: TObject);
    procedure GridHareketViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure HareketSilTusClick(Sender: TObject);
    procedure GridHareketViewFocusedRecordChanged(
      Sender: TcxCustomGridTableView; APrevFocusedRecord,
      AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure GridServisViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure TabHareketlerAfterScroll(DataSet: TDataSet);
    procedure ButtonServisClick(Sender: TObject);
    procedure PopupMenuHareketPopup(Sender: TObject);
    procedure ServisInfoMenuClick(Sender: TObject);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Servis_Liste)
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TServisAramaFrame;
    FIlkSonAranan : Boolean;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    procedure StokListeDlgKapatEylemi(Sender: TObject);
    procedure StokListeDlgEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TServisAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure HareketListele(Tablo1:TFDQuery; GridTablo1View:TcxGridTableView; ViewTabloAd:string);
    function EkranAdiAl : string;
    procedure TabloAc(ServisID:integer);
    procedure MenuItem1Click(Sender: TObject);
public
    { Public declarations }
    ServisAlanlarOlusturuldu,HareketAlanlarOlusturuldu : Boolean;
  published
    property Arama : TServisAramaFrame read FArama write SetArama;
  end;

implementation

uses ULog, UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UServisWizard, URaporAraclari, UGenelAnaSekmeFrame,
     UFastRap, PrjConst,LocOnFly, UServisHareketEkle, FetaUtil, UVeriMotor, System.JSON;

{$R *.dfm}
{ TServisListeDlg }

var
    OncekiSayfaIndex : SmallInt;

function ServisWildcardNormalize(const AValue: string; out ALike: Boolean): string;
begin
  Result := Trim(AValue);
  while Pos(' %', Result) > 0 do Result := StringReplace(Result, ' %', '%', [rfReplaceAll]);
  while Pos('% ', Result) > 0 do Result := StringReplace(Result, '% ', '%', [rfReplaceAll]);
  while Pos(' *', Result) > 0 do Result := StringReplace(Result, ' *', '*', [rfReplaceAll]);
  while Pos('* ', Result) > 0 do Result := StringReplace(Result, '* ', '*', [rfReplaceAll]);
  ALike := (Pos('%', Result) > 0) or (Pos('*', Result) > 0);
  Result := StringReplace(Result, '*', '%', [rfReplaceAll]);
end;


function TServisListeDlg.EkranAdiAl: string;
begin
  Result := 'ServisListeDlg';
{   case cxPageControl1.ActivePageIndex of
      0: Result := SERWServis_Kabul;
      1: Result := SERWServis_Plan;
      2: Result := SERWServisUygulama;
   end;   }
end;

procedure TServisListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  pc1 : TcxPageControl;
  DokumAdi: String;
begin
   AFastReport.EnabledDataSets.Clear;
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdiAl,frxServis) then
    AFastReport.EnabledDataSets.Add(frxServis)
  else begin

   AFastReport.EnabledDataSets.Add(frxServis);
   AFastReport.EnabledDataSets.Add(frxGENEL);
   AFastReport.EnabledDataSets.Add(frxHareketler);
   AFastReport.EnabledDataSets.Add(frxServisBelge);
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  end;

  // Kullanici ek alanlari (_USER) rapora: servis karti + hareket satirlari.
  if SERVIS.Active and (not SERVIS.IsEmpty) then begin
    Tablo.UserAlanYazdirmaEkle(AFastReport, 'SERVIS', SERVIS.FieldByName('ID').AsInteger);
    Tablo.UserAlanYazdirmaEkle(AFastReport, 'SERVISHAREKET', 0,
      'select ID from SERVISHAREKET where SERVISID=' + SERVIS.FieldByName('ID').AsString);
  end;

  DokumDegiskenListesi.Add('ServisID'+'$@$'+SERVIS.FieldByName('ID').AsString);
  if (ServisWizardDlg <> nil)and(ServisWizardDlg.ServisPageControl<>nil) then
    pc1 := ServisWizardDlg.ServisPageControl
  else
    pc1 := cxPageControl1;

end;

procedure TServisListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TServisListeDlg.Baslatildi;
var
  ra : string;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  PageControlServis.ActivePageIndex:=0;
  GridServisViewSUBEID.Visible := SubeVarmi;
  OncekiSayfaIndex := -1;
  cxPageControl1.ActivePageIndex := 1;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;

  //Tablo.ServisInit(TcxImageComboBoxProperties(GridServisViewTURU.Properties),TcxImageComboBoxProperties(GridServisViewDURUM.Properties),nil);

  ServisAlanlarOlusturuldu := False;
  HareketAlanlarOlusturuldu := False;
  FIlkSonAranan := False;
  // Tum/Son/Sik Aranan butonlarini SP listeleme handler'larina bagla (sunucu-tarafi SP)
  if Assigned(FArama) then begin
    FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
    FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
    FArama.LabelSikArananlar.OnClick := LabelSikArananlarClick;
  end;
  JvTimer1.Enabled := False;
//  Tablo.GridAyarRestore('ServislerlerGridi',GridServisView );
  Tablo.GridAyarRestore('ServislerKabulGridi',GridKabulView );
  Tablo.EkAlanlariGrideEkle(GridHareketlerDBTableView1,'ServisSonlandirDlg');
  //Tablo.GridAyarRestore('ServisHareketGridi',GridHareketView );
  //GridHareketlerDBTableView1.ApplyBestFit;
  Tablo.GridTurkcelestir;
  TabGenel.SQL.Text := SQLGenelTekTus.Text;

//  if Sektor = Sektor_OtomotivServis then
//     GridServisViewSERINO.Caption := 'Plaka No';
end;

procedure TServisListeDlg.BtnMesajGonderClick(Sender: TObject);
begin
  //Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,Tabno_Servis , SERVIS.FieldByName('ID').AsInteger, SERVIS.FieldByName('REHBERID').AsInteger,TabYorum);
//  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,Tabno_Servis , SERVIS.FieldByName('ID').AsInteger, SERVIS.FieldByName('REHBERID').AsInteger,TabYorum);
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger, SERVIS.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TServisListeDlg.ButtonServisClick(Sender: TObject);
begin
  if GridHareketView.Controller.SelectedRecordCount > 0 then begin
    if Tablo.ServisSihirbazBaslat(False, 'D',0,HAREKET.FieldByName('SERVISID').AsInteger, HAREKET.FieldByName('REHBERID').AsInteger) > 0 then
       YenileTusClick(Self);
  end;
end;

procedure TServisListeDlg.GridHareketViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridHareket;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridHareketView;
  AnaForm.pmGridStil.Tags.Values[GridHareket.Name]:='ServisHareketGridi';
end;

procedure TServisListeDlg.TabHareketlerAfterScroll(DataSet: TDataSet);
begin
    Tabloyenile(TabYorum,[TabNo_SERVISHAREKET,TabHareketler.FieldByName('ID').AsInteger]);
end;

procedure TServisListeDlg.TabloAc(ServisID:integer);
begin
    TabloYenile(TabSmsEPosta,[ServisID]);

    TabloYenile(TabGenel,[ServisID]);

    TabloYenile(TabHareketler,[ServisID]);
    if cxPageControl1.ActivePage = cxTabSheet3 then
       TabloYenile(TabServisBelge,[ServisID]);
end;

procedure TServisListeDlg.GridHareketViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
  TabloAc(HAREKET.FieldByName('SERVISID').AsInteger);
end;

procedure TServisListeDlg.GridKabulViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
    AnaForm.cxGridPopupMenu1.Grid:=GridKabul;
    AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridKabulView;
    AnaForm.pmGridStil.Tags.Values[GridKabul.Name]:='ServislerKabulGridi';
end;

procedure TServisListeDlg.GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TServisListeDlg.GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TServisListeDlg.cxPageControl1Change(Sender: TObject);
var ra : string;
begin
   if OncekiSayfaIndex<>cxPageControl1.ActivePageIndex then begin
      TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
           TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
      YaziciYaz.Caption := ra;
      OncekiSayfaIndex := cxPageControl1.ActivePageIndex;
   end;
   if SERVIS.active then begin
      if cxPageControl1.ActivePage=TabSheetGenel then
         TabloYenile( TabGenel, [SERVIS.Fields[0].asInteger]);
      if cxPageControl1.ActivePage = cxTabSheet3 then
         TabloYenile(TabServisBelge, [SERVIS.Fields[0].AsInteger]);
   end;

end;

procedure TServisListeDlg.YenileTusClick(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 3000;
  JvTimer1.Enabled := True;
end;

procedure TServisListeDlg.AraStokKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    JvTimer1Timer(Sender)
  else if Key = 38 then
    SERVIS.Prior
  else if Key = 40 then
    SERVIS.next
  else // if TEdit(Sender).Text <> '' then
    YenileTusClick(Sender);
end;

procedure TServisListeDlg.DegisTusClick(Sender: TObject);
var ID : Integer;
begin
  if GridServisView.Controller.SelectedRecordCount > 0 then begin
    ID := SERVIS.Fields[0].AsInteger;
    Tablo.AramaKaydet(MODUL_Servis, ID);   // Son/Sik Aranan takibi (kart acilinca upsert)
    if Tablo.ServisSihirbazBaslat(SERVIS.FieldByName('DEMIRBAS').AsBoolean, 'D',0, ID, SERVIS.FieldByName('REHBERID').AsInteger) > 0 then
       JvTimer1Timer(Self);
  end;
end;

procedure TServisListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TServisListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_Servis,SERVIS.FieldByName('ID').AsInteger]);
  end;
end;

procedure TServisListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, SERVIS.FieldByName('REHBERID').AsInteger)
end;

procedure TServisListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TServisListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TServisListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TServisListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TServisListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TServisListeDlg.Gorunmez;
begin

end;

procedure TServisListeDlg.GorunmezOlacak;
begin

end;

procedure TServisListeDlg.Gorunur;
begin

  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TServisListeDlg.GorunurOlacak;
begin

end;

procedure TServisListeDlg.GridServisViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridServis;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridServisView;
  AnaForm.pmGridStil.Tags.Values[GridServis.Name]:='ServislerGridi';
end;

procedure TServisListeDlg.GridServisViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
  TabloAc(SERVIS.FieldByName('ID').AsInteger);
end;

procedure TServisListeDlg.GridServisViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   cxPageControl1Change(Self);
end;

procedure TServisListeDlg.GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
   Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TServisListeDlg.GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TServisListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_Servis);
end;

procedure TServisListeDlg.HAREKETAfterOpen(DataSet: TDataSet);
begin
   HareketDegisTus.Visible   := SERVIS.RecordCount>0;
   HareketSilTus.Visible := DegisTus.Visible;
end;

procedure TServisListeDlg.HareketDegisTusClick(Sender: TObject);
begin
  // değişiklik olacağı zaman hareketin ID'sini gönderiyoruz
  if GridHareketView.Controller.SelectedRecordCount > 0 then begin
    if Tablo.ServisHareketBaslat('D',1,HAREKET.FieldByName('ID').AsInteger) > 0 then
       YenileTusClick(Self);
  end;
end;

procedure TServisListeDlg.HareketEkleTusClick(Sender: TObject);
begin
  //önce seçilmiş satırdan servis bilgisi (ID) alıp ona hareket eklemeliyiz
  if GridHareketView.Controller.SelectedRecordCount > 0 then begin
     if Tablo.ServisHareketBaslat('E',1, HAREKET.FieldByName('ID').AsInteger) > 0 then
        YenileTusClick(Self);
  end;
end;

procedure TServisListeDlg.HareketListele(Tablo1:TFDQuery; GridTablo1View:TcxGridTableView; ViewTabloAd:string);
var
  s : string;
  LocateID:integer;
begin
  JvTimer1.Enabled := False;
  if (Tablo1.Active)and(Tablo1.RecordCount>0) then
    LocateID := Tablo1.FieldByName('ID').AsInteger;
  Tablo1.Close;
  //AO 24.04.2020 birden fazla sorumlu kaldırıldı
  //  if not Tablo.GENINI.ReadBoolean(Ops_SERVISBirdenFazlaSorumluPers,False) then
  //  Tablo1.SQL.Text := StringReplace(SQLMemo.Text, 'SORUMLUAD=(SELECT [dbo].[fn_Tablo1Kisiler](S.DURUM, S.ID)),', 'SORUMLUAD=(SELECT R3.FIRMA from REHBER R3 where R3.ID=(select top 1 SH3.PERSONEL from Tablo1HAREKET SH3 where SH3.Tablo1ID=S.ID order by SH3.ID desc)),', [rfReplaceAll])
  //else
  //if Tablo1.Name='SERVIS' then
  //  Tablo1.SQL.Text := SQLMemo.Text;
  Tablo1.SQL.Text := 'select * from '+ViewTabloAd+' S  where 1=1 ';
  //if Tablo1.Name='SERVIS' then
  //   Tablo1.SQL.Add(' inner join vServisHareket H on S.ID=H.SERVISID ');
  //Tablo1.SQL.Add(' where 1=1 ');;
  if FArama.EditNo.Text <>'' then begin
     Tablo1.SQL.Text := Tablo1.SQL.Text + ' and ((S.SERVISNO Like '''+FArama.EditNo.Text+'%'')';
     if StrToIntDef(FArama.EditNo.Text, 0)<>0 then
        Tablo1.SQL.Text := Tablo1.SQL.Text +'or(S.ID = '+FArama.EditNo.Text+')';
     Tablo1.SQL.Text := Tablo1.SQL.Text + ')';
  end;
  if FArama.EditKategori.Tag>0 then
    Tablo1.SQL.Text := Tablo1.SQL.Text + ' and (select AD from KATEGORI K  where K.ID=S.EKIPMANID) = '''+FArama.EditKategori.Text+'''';
  if FArama.AraKonusu.Text <>'' then
    Tablo1.SQL.Text := Tablo1.SQL.Text + ' and S.KONUSU like ''%'+FArama.AraKonusu.Text+'%''';

  if FArama.editUrun.Text <>'' then
    Tablo1.SQL.Text := Tablo1.SQL.Text + ' and (select AD from EKIPMANLAR E  where E.ID=S.EKIPMANID) like ''%'+FArama.editUrun.Text+'%''';
  if FArama.AraMusteri.Text <>'' then
    Tablo1.SQL.Text := Tablo1.SQL.Text + ' and FIRMA like ''%'+FArama.AraMusteri.Text+'%'' ';

  if SubeVarmi then
   Tablo1.SQL.Text := Tablo1.SQL.Text + 'and S.SUBEID in('+Tablo.YetkiliSubeleriGetir(30,YetkiTur_Gorme)+') ';

(*  case ModulYetki_TekSubeTum.SERVIS of
    //1: Tablo1.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.SERVISID=S.ID and SH.PERSONEL='+Kullanan+') ');
    1: Tablo1.SQL.Add(' AND PERSONEL='+Kullanan);//sadece kendisinin
    5:;//kendi departmanını
   10: Tablo1.SQL.Add(' AND S.SUBEID='+IntToStr(SubeId));//şubesindekileri
   100;//herkesin
  end;   *)

  // NOT: Servis listesi (SERVIS) artik sunucu-tarafi SP ile geliyor (Liste_SP_Cagir/sp_Prog_Servis_Liste).
  //      HareketListele yalnizca SERVISHAREKET (vServisHareket) sekmesi icin kullaniliyor.
  begin //SERVISHAREKET sekmesinde arama
      case FArama.cbListe.EditValue of
        1 : //aktif servislerim
         Tablo1.SQL.Add(' AND PERSONEL='+Kullanan);
        2 : //tüm servislerim
            Tablo1.SQL.Add(' AND (PERSONEL='+Kullanan+' or HAREKETEKLEYEN='+Kullanan+') ');
        5 : begin//Departman servisleri
              Tablo1.SQL.Add(' AND S.PERSONEL in (select R.ID from REHBER R inner join ROLLER ROL on R.SINIF=ROL.ID ');
              Tablo1.SQL.Add(' where ROL.DEPARTMAN=(select ROL.DEPARTMAN from REHBER R inner join ROLLER ROL on R.SINIF=ROL.ID '+
                           ' where R.ID='+Kullanan+'))  ')//sadece kendi departmanım görür
            end;
        8 : //şube servisleri
              Tablo1.SQL.Add(' AND S.SUBEID='+IntToStr(SubeID));
      end;
      Tablo1.SQL.Add(' AND (isnull(S.BITISSEC,0)=0 ');
      //kapananları da göster
      //if FArama.EditNo.Text = '' then begin //eğer no araması yapılıyorsa geçmiş kayıtlara da bakılır
          if FArama.EditNo.Text<>'' then begin //servisno girilmişse en baştan beri kapalılar dahil arama yapar
             Tablo1.SQL.Add(' or BASLAMATARIHI > ''2000-01-01'' ');
          end
          else if FArama.CheckKapali.Checked then begin
              GridHareketViewBITISSEC.Visible := True;
              case FArama.ComboTamamlanan.EditValue of
                  1 : //bugün ise
                      Tablo1.SQL.Add(' or round(cast(BASLAMATARIHI as float),0,1)=round(cast(Getdate() as float),0,1) ');
                  9999 : //başlangıçtan beri
                      Tablo1.SQL.Add(' or BASLAMATARIHI > ''2000-01-01'' ');
                  19000 : //iki tarih arası
                      Tablo1.SQL.Add(' or BASLAMATARIHI between '''+FormatDateTime('yyyy-mm-dd', FArama.AraTarihBas.Date)+''' '+
                                                                                       ' and '''+FormatDateTime('yyyy-mm-dd', FArama.AraTarihBit.Date)+''' ');
                  else //son 1 hafta, 1 ay, 1 yıl vb. ise
                      Tablo1.SQL.Add(' or BASLAMATARIHI>='''+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh-FArama.ComboTamamlanan.EditValue)+''' ');;
              end;
              //Tablo1.SQL.Add(' ) ');
          end
          else begin
        //    Tablo1.SQL.Text := Tablo1.SQL.Text + ' ) ';
            GridHareketViewBITISSEC.Visible := False;
          end;
         //   Tablo1.SQL.Text := Tablo1.SQL.Text + ' and S.ACKAPA = 0 ';
     // end;
      Tablo1.SQL.Text := Tablo1.SQL.Text + ' ) ';



      if FArama.AraDurumu.Text <> '' then
         Tablo1.SQL.Add(' AND S.DURUM='+IntToStr(FArama.AraDurumu.EditValue));
      if (FArama.AraDurumu.Text <> '')and (FArama.EditSorumlu.Tag > 0) then
         Tablo1.SQL.Add(' AND S.DURUM='+vartostr(FArama.AraDurumu.EditValue)+' and S.PERSONEL='+IntToStr(FArama.EditSorumlu.Tag))
      else if (FArama.AraDurumu.Text = '')and (FArama.EditSorumlu.Tag > 0) then
         Tablo1.SQL.Add(' AND S.PERSONEL='+IntToStr(FArama.EditSorumlu.Tag))
      else if (FArama.AraDurumu.Text <> '')and (FArama.EditSorumlu.Tag = 0) then
         Tablo1.SQL.Add(' AND S.DURUM='+vartostr(FArama.AraDurumu.EditValue));


  end;
  //  TabloYenile(Tablo1,[],LocateID,'ID');
  TabloYenile(Tablo1,[]);
  if (not HareketAlanlarOlusturuldu) then begin
       //GridHareketView.DataController.CreateAllItems(True);
       Tablo.GridAyarRestore('ServisHareketGridi', GridHareketView);
       HareketAlanlarOlusturuldu := True;
  end;

  (*  if (Tablo1.Name='SERVIS')and(not ServisAlanlarOlusturuldu) then begin
    Tablo.GridAyarRestore('ServislerGridi', GridServisView);
    ServisAlanlarOlusturuldu := True;
  end
  else if (Tablo1.Name='HAREKET') then begin
    if not HareketAlanlarOlusturuldu then begin
       //GridHareketView.DataController.CreateAllItems(True);
       //Tablo.GridAyarRestore('ServisHareketGridi', GridHareketView);
       HareketAlanlarOlusturuldu := True;
    end
    //else
    //  GridHareketView.ViewData.Expand(True);
  end;   *)
  GridTablo1View.ViewData.Expand(True);

end;

procedure TServisListeDlg.HareketServisEkleTusClick(Sender: TObject);
begin
   if Tablo.ServisHareketBaslat('E',0,HAREKET.FieldByName('ID').AsInteger) > 0 then
      YenileTusClick(Self);
end;

procedure TServisListeDlg.HareketSilTusClick(Sender: TObject);
var  ID, ServisID: integer;
begin
  if (not TamYetkili)and(HAREKET.FieldByName('HAREKETEKLEYEN').AsString<>Kullanan) then begin
     showmessage(Yetkisiz_Islem);
     exit;
  end;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    ID := HAREKET.FieldByName('ID').AsInteger;
    if Veritabani.VeriVarmi(Tablo.FDCnn, ' select * from GOREVYORUM where TUR=183 and GOREVID=&Id ',['&Id'], [ID])then begin
       showmessage(RDYorumMedyaVarSilinemez);
       exit;
    end;
    ServisID := HAREKET.FieldByName('SERVISID').AsInteger;
    Tablo.TablodanSorguAc(1,  ' SELECT count(*) from VServisHareket where SERVISID  = '+ IntToStr(ServisID));
    // Hareket satiri + SERVISHAREKET_USER SILMEDEN ONCE logla (Geri Al).
    LogKartSil(HAREKET, TabNo_SERVISHAREKET, ID, TabNo_SERVIS, ServisID);
    LogKayitSil('SERVISHAREKET_USER', TabNo_SERVISHAREKET_USER, ID, TabNo_SERVIS, ServisID);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISHAREKET where ID  = &Id ',['&Id'], [ID]);
    if Tablo.Query1.Fields[0].AsInteger=1 then begin
       // Son hareket -> servis de siliniyor: kart + SERVIS_USER logla (ServisSil kalan detaylari loglar).
       LogKayitSil('SERVIS', TabNo_SERVIS, ServisID, TabNo_SERVIS, ServisID);
       LogDetaylariSil('SERVIS_USER', 'ID', TabNo_SERVIS_USER, TabNo_SERVIS, ServisID);
       Tablo.ServisSil(ServisID); //tek hareket olduğu zaman hem servis hem hareket silinir
    end;

    //if LogGun > 0 then
    //  Tablo.OncekiLogBelirle(SERVIS);
    //Tablo.ServisSil(ID);
    //Tablo.LogIslemleri(TabNo_SERVIS, ID, 5, SERVIS);
    YenileTusClick(Self);
  end;
end;

procedure TServisListeDlg.JvTimer1Timer(Sender: TObject);
var
  s : string;
  LocateID:integer;
begin
  JvTimer1.Enabled := False;   // ONEMLI: kacak timer'i durdur (yoksa her 700ms tekrar tetiklenir - surekli kum saati)
  if PageControlServis.ActivePage=Tabhareket then
     HareketListele(HAREKET, GridHareketView, 'vServisHareket')
  else if Tablo.IlkAcilisSonArananMi(FIlkSonAranan) then
     Liste_SP_Cagir(5)
  else
     Liste_SP_Cagir(4);   // Servis listesi -> sunucu-tarafi SP (sp_Prog_Servis_Liste)
(*  JvTimer1.Enabled := False;
  if (SERVIS.Active)and(SERVIS.RecordCount>0) then
    LocateID := SERVIS.FieldByName('ID').AsInteger;
  SERVIS.Close;
  if not Tablo.GENINI.ReadBoolean(Ops_ServisBirdenFazlaSorumluPers,False) then
    SERVIS.SQL.Text := StringReplace(SQLMemo.Text, 'SORUMLUAD=(SELECT [dbo].[fn_ServisKisiler](S.DURUM, S.ID)),', 'SORUMLUAD=(SELECT R3.FIRMA from REHBER R3 where R3.ID=(select '+DbUst(1)+'SH3.PERSONEL from SERVISHAREKET SH3 where SH3.SERVISID=S.ID order by SH3.ID desc '+DbSinir(1)+')),', [rfReplaceAll])
  else
    SERVIS.SQL.Text := SQLMemo.Text;
  SERVIS.SQL.Text := SERVIS.SQL.Text+' where 1=1 ';
  if FArama.EditNo.Text <>'' then
    SERVIS.SQL.Text := SERVIS.SQL.Text + ' and (S.SERVISNO Like '''+FArama.EditNo.Text+'%'')or(S.ID = '+FArama.EditNo.Text+') ';
  if FArama.EditKategori.Tag>0 then
    SERVIS.SQL.Text := SERVIS.SQL.Text + ' and (select AD from KATEGORI K  where K.ID=S.EKIPMANID) = '''+FArama.EditKategori.Text+'''';
  if FArama.AraKonusu.Text <>'' then
    SERVIS.SQL.Text := SERVIS.SQL.Text + ' and S.KONUSU like '''+FArama.AraKonusu.Text+'%''';
  if FArama.EditSerino.Text <>'' then
    SERVIS.SQL.Text := SERVIS.SQL.Text + ' and S.SERINO like '''+FArama.EditSerino.Text+'%''';
  if FArama.editUrun.Text <>'' then
    SERVIS.SQL.Text := SERVIS.SQL.Text + ' and (select AD from EKIPMANLAR E  where E.ID=S.EKIPMANID) like '''+FArama.editUrun.Text+'%''';
  if FArama.AraMusteri.Text <>'' then
    SERVIS.SQL.Text := SERVIS.SQL.Text + ' and R1.FIRMA like '''+FArama.AraMusteri.Text+'%'' ';

  if FArama.EditNo.Text = '' then begin //eğer no araması yapılıyorsa geçmiş kayıtlara da bakılır
      if FArama.CheckKapali.Checked then
          case FArama.ComboTamamlanan.EditValue of
              1 : //bugün ise
                  SERVIS.SQL.Add(' and ((isnull(S.ACKAPA,0)=0) or (round(cast(BASLAMATARIHI as float),0,1)=round(cast(Getdate() as float),0,1))) ');
              19000 : //iki tarih arası
                  SERVIS.SQL.Add(' and ((isnull(S.ACKAPA,0)=0) or (BASLAMATARIHI between '''+FormatDateTime('yyyy-mm-dd', FArama.AraTarihBas.Date)+''' '+
                                                                                   ' and '''+FormatDateTime('yyyy-mm-dd', FArama.AraTarihBit.Date)+''')) ');
              else //son 1 ay, 1 yıl vb. ise
                  SERVIS.SQL.Add(' and ((isnull(S.ACKAPA,0)=0) or (BASLAMATARIHI>='''+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh-FArama.ComboTamamlanan.EditValue)+''')) ');;
          end
      else
        SERVIS.SQL.Text := SERVIS.SQL.Text + ' and S.ACKAPA = 0 ';
  end;

  if SubeVarmi then
   SERVIS.SQL.Text := SERVIS.SQL.Text + 'and S.SUBEID in('+Tablo.YetkiliSubeleriGetir(30,YetkiTur_Gorme)+') ';

  case ModulYetki_TekSubeTum.Servis of
    1: SERVIS.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.SERVISID=S.ID and SH.PERSONEL='+Kullanan+') ');
   10: SERVIS.SQL.Add(' AND S.SUBEID='+IntToStr(SubeId));
  end;

  if FArama.cbListe.EditValue = 1 then //aktif servislerim
     SERVIS.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.BITIS is Null and SH.SERVISID=S.ID and SH.PERSONEL='+Kullanan+') ')
  else if FArama.cbListe.EditValue = 2 then //tüm servislerim
     SERVIS.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.SERVISID=S.ID and SH.PERSONEL='+Kullanan+') ')
  else if FArama.cbListe.EditValue = 5 then begin//Departman servisleri
     SERVIS.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.SERVISID=S.ID and SH.PERSONEL in ' +
                       ' (select R.ID from REHBER R inner join ROLLER ROL on R.SINIF=ROL.ID ');
     SERVIS.SQL.Add(' where ROL.DEPARTMAN=(select ROL.DEPARTMAN from REHBER R inner join ROLLER ROL on R.SINIF=ROL.ID '+
                       ' where R.ID='+Kullanan+'))')//sadece kendi departmanım görür
  end
  else if FArama.cbListe.EditValue = 8 then //şube servislerim
     SERVIS.SQL.Add(' AND S.SUBEID='+IntToStr(SubeID));

  if (FArama.AraDurumu.Text <> '')and (FArama.EditSorumlu.Tag > 0) then
     SERVIS.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.SERVISID=S.ID and SH.DURUM='+vartostr(FArama.AraDurumu.EditValue)+' and SH.PERSONEL='+IntToStr(FArama.EditSorumlu.Tag)+') ')
  else if (FArama.AraDurumu.Text = '')and (FArama.EditSorumlu.Tag > 0) then
     SERVIS.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.SERVISID=S.ID and SH.PERSONEL='+IntToStr(FArama.EditSorumlu.Tag)+') ')
  else if (FArama.AraDurumu.Text <> '')and (FArama.EditSorumlu.Tag = 0) then
     SERVIS.SQL.Add(' AND exists (select 1 from SERVISHAREKET SH where SH.SERVISID=S.ID and SH.DURUM='+vartostr(FArama.AraDurumu.EditValue)+') ');

  TabloYenile(SERVIS,[],LocateID,'ID');
  if not AlanlarOlusturuldu then begin
    //GridServisView.DataController.CreateAllItems(True);
    //GridStokView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\StokListeGridi',true,false,[gsoUseFilter],'StokListeGridi');
    Tablo.GridAyarRestore('ServislerlerGridi', GridServisView);
    AlanlarOlusturuldu := True;
  end;
  GridServisView.ViewData.Expand(True); *)
end;

procedure TServisListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TServisListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TServisListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TServisListeDlg.PageControlServisChange(Sender: TObject);
begin
   JvTimer1.Enabled := True;
end;

procedure TServisListeDlg.MenuItem1Click(Sender: TObject);
begin
  //önce seçilmiş satırdan servis bilgisi (ID) alıp ona hareket eklemeliyiz
  Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'ID from vServisHareket S  where SERVISID='+IntToStr(TmenuItem(Sender).Tag)+' and PERSONEL='+Kullanan+' order by TARIH desc '+DbSinir(1));
  if Tablo.ServisHareketBaslat('E',1, Tablo.Query1.Fields[0].AsInteger) > 0 then
     YenileTusClick(Self);
end;

procedure TServisListeDlg.ServisInfoMenuClick(Sender: TObject);
begin
  if not SERVIS.IsEmpty then
    Tablo.InfoGoster('SERVIS', SERVIS.FieldByName('ID').AsInteger, TabNo_SERVIS);
end;

procedure TServisListeDlg.PopupMenuHareketPopup(Sender: TObject);
begin
   Tablo.TablodanSorguAc(2,'select distinct '+DbUst(10)+'SERVISID,SERVISNO+'' ''+SUBSTRING (FIRMA,0,CHARINDEX('' '',FIRMA))+'' ''+KONUSU,TARIH  from vServisHareket S '+
                           ' where PERSONEL='+Kullanan+' order by TARIH desc '+DbSinir(10));
   PopupMenuHareket.Items.Clear;
   while not Tablo.Query2.eof do begin
      PopUpMenuIslemleri(PopupMenuHareket, MenuItem1Click, 'Ekle', Tablo.Query2.Fields[1].AsString,'', Tablo.Query2.Fields[0].AsInteger);
      Tablo.Query2.next;
   end;
end;

procedure TServisListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TServisListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_Servis, SERVIS.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TServisListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin
end;

procedure TServisListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
   TabloYenile(SERVIS,[]);
end;

procedure TServisListeDlg.SetArama(const Value: TServisAramaFrame);
var k : word;
begin
  FArama := Value;
  // Tum/Son/Sik Aranan butonlarini SP listeleme handler'larina bagla (init sirasindan bagimsiz garanti)
  FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
  FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
  FArama.LabelSikArananlar.OnClick := LabelSikArananlarClick;
  with FArama do begin
    YenileTus.Click;
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TServisListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TServisListeDlg.SilTusClick(Sender: TObject);
var  ServisID: integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    ServisID := SERVIS.FieldByName('ID').AsInteger;
    if (not TamYetkili)and(SERVIS.FieldByName('EKLEYEN').AsString<>Kullanan) then begin
       showmessage(Yetkisiz_Islem);
       exit;
    end;


    Tablo.TablodanSorguAc(1,  ' SELECT count(*) from SERVISHAREKET where SERVISID  = '+ IntToStr(ServisID));
    if Tablo.Query1.Fields[0].AsInteger>1 then begin
       showmessage(RDServisHarVerisiVarSilinemez);
       exit;
    end;
    // Kart SILME logu: SILMEDEN ONCE, kayit dururken.
    LogKartSil(SERVIS, TabNo_SERVIS, ServisID);
    // _USER (ek alan) satirini SILMEDEN ONCE logla (Geri Al icin); FK cascade kart ile siler.
    LogDetaylariSil('SERVIS_USER', 'ID', TabNo_SERVIS_USER, TabNo_SERVIS, ServisID);
    Tablo.ServisSil(ServisID);
    YenileTusClick(Self);
  end;
end;

procedure TServisListeDlg.SERVISAfterOpen(DataSet: TDataSet);
begin
   DegisTus.Visible   := SERVIS.RecordCount>0;
   SilTus.Visible := DegisTus.Visible;
end;

procedure TServisListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TServisListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TServisListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TServisListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TServisListeDlg.YeniTusClick(Sender: TObject);
var
  LServisID: Integer;
begin
   LServisID := Tablo.ServisSihirbazBaslat(ServisKapsami=1,'E',0,-1,-1);
   if LServisID > 0 then
      LabelSonArananlarClick(Self);
end;

procedure TServisListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Servis);
end;

procedure TServisListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(1);   // Tum kayitlar (TOP yok) -> sunucu-tarafi SP
end;

procedure TServisListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
   GridServisView.DataController.ClearSorting(False);
   Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA tarih desc)
   GridServisView.Controller.FocusedRecordIndex := 0;
end;

procedure TServisListeDlg.LabelSikArananlarClick(Sender: TObject);
begin
   GridServisView.DataController.ClearSorting(False);
   Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA SAY desc)
   GridServisView.Controller.FocusedRecordIndex := 0;
end;

procedure TServisListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// Servis listesini sunucu-tarafi SP ile getirir (2 PARAM JSON: sp_Prog_Servis_Liste_Json2).
//   @Baslik   = SELECT ek kolonlari (ham SQL parcasi, GUVENILIR; Servis'te bos).
//   @Kosullar = filtreler JSON (cast/parametreli DEGERLER; app TJSONObject ile guvenli escape).
//   AMod: 1=Tum (TOP yok), 3=Sik Aranan, 4=Filtre, 5=Son Aranan.
//   Bos metin filtreleri JSON'a EKLENMEZ (SP absent=NULL=filtre yok); bit/sayilar TJSONNumber.
//   Sonuc kumesi eski servis liste kolonlari ile uyumludur.
var
  TopN, LocateID, ServisNoId, cbListeVal: Integer;
  ServisNo, SeriNo, SubeYetki: string;
  j: TJSONObject;
  HizliArama, ServisNoLike, SeriNoLike: Boolean;
begin
  if (SERVIS.Active) and (SERVIS.RecordCount > 0) then
    LocateID := SERVIS.FieldByName('ID').AsInteger
  else
    LocateID := 0;

  if AMod in [3, 5] then begin
    GridServisView.DataController.ClearSorting(False);
    LocateID := 0;
  end;

  if AMod in [3, 5] then TopN := 200   // Son/Sik Aranan: sinirli (yeni islev)
  else TopN := 0;                      // Tum/Filtre: eski davranis (limitsiz)

  if SubeVarmi then SubeYetki := Tablo.YetkiliSubeleriGetir(30, YetkiTur_Gorme)
  else SubeYetki := '';

  ServisNo   := ServisWildcardNormalize(FArama.EditNo.Text, ServisNoLike);
  SeriNo     := ServisWildcardNormalize(FArama.EditSerino.Text, SeriNoLike);
  ServisNoId := StrToIntDef(FArama.EditNo.Text, 0);
  HizliArama := (AMod = 4) and ((ServisNo <> '') or (SeriNo <> ''));
  cbListeVal := StrToIntDef(VarToStr(FArama.cbListe.EditValue), 9);

  if HizliArama then
    TopN := 200;

  j := TJSONObject.Create;
  try
    j.AddPair('TopN',  TJSONNumber.Create(TopN));
    j.AddPair('Mod',   TJSONNumber.Create(AMod));
    j.AddPair('Pasif', TJSONNumber.Create(0));                             // rezerve (servis'te aktif/pasif yok)
    if AMod = 4 then begin
      if ServisNo <> '' then j.AddPair('ServisNo', ServisNo);
      if ServisNoLike then j.AddPair('ServisNoLike', TJSONNumber.Create(1));
      if ServisNoId <> 0 then j.AddPair('ServisNoId', TJSONNumber.Create(ServisNoId));
      if SeriNo <> '' then j.AddPair('SeriNo',  SeriNo);
      if SeriNoLike then j.AddPair('SeriNoLike', TJSONNumber.Create(1));
    end;
    if (not HizliArama) and (AMod = 4) then begin
      if (FArama.EditKategori.Tag > 0) and (Trim(FArama.EditKategori.Text) <> '') then
        j.AddPair('KategoriAd', FArama.EditKategori.Text);
      if Trim(FArama.AraKonusu.Text)    <> '' then j.AddPair('Konusu',  Trim(FArama.AraKonusu.Text));
      if Trim(FArama.editUrun.Text)     <> '' then j.AddPair('Urun',    Trim(FArama.editUrun.Text));
      if Trim(FArama.AraMusteri.Text)   <> '' then j.AddPair('Musteri', Trim(FArama.AraMusteri.Text));
      if SubeYetki <> '' then j.AddPair('SubeYetkiList', SubeYetki);
      j.AddPair('cbListe',    TJSONNumber.Create(cbListeVal));
      j.AddPair('Kullanan',   TJSONNumber.Create(StrToIntDef(Kullanan, 0)));
      j.AddPair('SubeID',     TJSONNumber.Create(SubeID));
      j.AddPair('Durum',      TJSONNumber.Create(StrToIntDef(VarToStr(FArama.AraDurumu.EditValue), 0)));
      j.AddPair('DurumVar',   TJSONNumber.Create(Ord(Trim(FArama.AraDurumu.Text) <> '')));
      j.AddPair('SorumluTag', TJSONNumber.Create(FArama.EditSorumlu.Tag));
      j.AddPair('Kapali',     TJSONNumber.Create(Ord(FArama.CheckKapali.Checked)));
      j.AddPair('Tamamlanan', TJSONNumber.Create(StrToIntDef(VarToStr(FArama.ComboTamamlanan.EditValue), 0)));
      j.AddPair('KapaliTarih', FormatDateTime('yyyy-mm-dd',
                                 Tablo.GENINI.BugunTrh - StrToIntDef(VarToStr(FArama.ComboTamamlanan.EditValue), 0)));
      j.AddPair('TarihBas',  FormatDateTime('yyyy-mm-dd', FArama.AraTarihBas.Date));
      j.AddPair('TarihBit',  FormatDateTime('yyyy-mm-dd', FArama.AraTarihBit.Date));
      j.AddPair('KulId',     TJSONNumber.Create(StrToIntDef(Kullanan, 0)));   // Son/Sik icin kullanici
      j.AddPair('Modul',     TJSONNumber.Create(MODUL_Servis));               // KULLANICI_ARAMA.MODUL
    end;
    if AMod in [3, 5] then begin
      j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));
      j.AddPair('Modul', TJSONNumber.Create(MODUL_Servis));
    end;

    // Generic helper: @Baslik='' (Servis ek-alan yok) + @Kosullar=j (JSON); helper j'yi Free eder + TabloYenile yapar.
    Tablo.ListeSPJson(SERVIS,  'sp_Prog_Servis_Liste_Json2', '', j, LocateID);
    j :=  nil;   // sahiplik helper'a gecti -> finally'de tekrar Free etme
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;

  if not ServisAlanlarOlusturuldu then begin                               // ilk yuklemede grid kolonlari
    GridServisView.DataController.CreateAllItems(True);
    Tablo.GridAyarRestore('ServislerGridi', GridServisView);
    ServisAlanlarOlusturuldu := True;
  end;
  if (AMod in [3, 5]) and (SERVIS.Active) and (not SERVIS.IsEmpty) then
    GridServisView.Controller.FocusedRecordIndex := 0;
end;

initialization
  RegisterClass(TServisListeDlg);
end.





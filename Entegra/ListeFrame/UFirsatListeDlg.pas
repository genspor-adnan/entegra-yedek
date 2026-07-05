unit UFirsatListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 04/12/2010 13:45:17}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, cxTLData,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, JvTimer, cxImage,
  UFirsatListeAramaFrame,dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridCustomTableView,DateUtils,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxTimeEdit, cxCheckBox, cxImageComboBox, cxMemo, cxDropDownEdit,
  cxCalendar, cxCurrencyEdit, dxSkinsCore, dxSkinLondonLiquidSky, frxClass, cxDBTL,
  frxDBSet, URaporAraclari, UGenelAnaSekmeFrame, Utablo, cxCalc, ImgList,
  PngImageList, cxSplitter, cxPC, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, cxLabel, JvExControls,
  JvNavigationPane, dxCore, cxDateUtils, OfficePopupMenu, dxSkinLiquidSky,
  cxSpinEdit, dxGDIPlusClasses, dxBarBuiltInMenu, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, cxGridCustomPopupMenu,
  cxGridPopupMenu, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, dxCustomTileControl,
  dxTileControl, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxScrollbarAnnotations, dxDateRanges,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet;

type
  TFirsatListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsProjeler: TDataSource;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    GorTus: TToolButton;
    SQLMemo: TcxMemo;
    FIRSATLAR: TFDQuery;
    YaziciYaz: TToolButton;
    ToolButton2: TToolButton;
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
    frxPROJELER: TfrxDBDataset;
    PopupMenu1: TPopupMenu;
    Kopyala1: TMenuItem;
    N4: TMenuItem;
    GrupA1: TMenuItem;
    GrupKapa1: TMenuItem;
    Panel1: TPanel;
    cxSplitter1: TcxSplitter;
    PageControlSekme: TcxPageControl;
    TabSheetTeklifler: TcxTabSheet;
    GridTeklif: TcxGrid;
    GridTeklifView: TcxGridDBTableView;
    GridTeklifViewTARIH: TcxGridDBColumn;
    GridTeklifViewTEKLIFNO: TcxGridDBColumn;
    GridTeklifViewKONU: TcxGridDBColumn;
    GridTeklifViewTURU: TcxGridDBColumn;
    GridTeklifViewDURUM: TcxGridDBColumn;
    GridTeklifViewHAZIRLAYAN: TcxGridDBColumn;
    GridTeklifViewDOVIZ_TUTARI: TcxGridDBColumn;
    GridTeklifViewKUR: TcxGridDBColumn;
    GridTeklifViewSUBEID: TcxGridDBColumn;
    GridTeklifLevel1: TcxGridLevel;
    TabTeklif: TFDQuery;
    DtsTeklifler: TDataSource;
    JvTimer1: TJvTimer;
    Panel9: TPanel;
    ToolBar2: TToolBar;
    IlgiliEkleTus: TToolButton;
    IlgiliSilTus: TToolButton;
    ToolButton6: TToolButton;
    IlgiliDuzenleTus: TToolButton;
    JvNavPanelHeader5: TJvNavPanelHeader;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    GridTeklifLevel2: TcxGridLevel;
    GridTeklifDBTableView1: TcxGridDBTableView;
    DtsTeklifDetay: TDataSource;
    TabTeklifDetay: TFDQuery;
    GridTeklifDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridTeklifDBTableView1ADET: TcxGridDBColumn;
    GridTeklifDBTableView1BIRIM: TcxGridDBColumn;
    GridTeklifDBTableView1BIRIMFIYAT: TcxGridDBColumn;
    GridTeklifDBTableView1ISKONTO: TcxGridDBColumn;
    GridTeklifDBTableView1KDV: TcxGridDBColumn;
    GridTeklifDBTableView1TUTAR: TcxGridDBColumn;
    GridTeklifDBTableView1KUR: TcxGridDBColumn;
    GridTeklifDBTableView1DOVIZ_TUTARI: TcxGridDBColumn;
    GridTeklifDBTableView1DOVIZ_KURU: TcxGridDBColumn;
    GridTeklifDBTableView1ISKONTO2: TcxGridDBColumn;
    GridTeklifDBTableView1DOVIZ_BIRIMFIYAT: TcxGridDBColumn;
    GridTeklifDBTableView1AD: TcxGridDBColumn;
    GridTeklifDBTableView1KOD: TcxGridDBColumn;
    GridTeklifViewFIRMA: TcxGridDBColumn;
    TabSheetGorevler: TcxTabSheet;
    TabGorevler: TFDQuery;
    DtsGorevler: TDataSource;
    GorevlerMenu: TOfficePopupMenu;
    DuzenleMenu: TMenuItem;
    TamamlandiIsaretleMenu: TMenuItem;
    Bayraklaretle1: TMenuItem;
    MenuItem3: TMenuItem;
    TarihBugunMenu: TMenuItem;
    arihYarn1: TMenuItem;
    TarihiKaldirMenu: TMenuItem;
    MenuItem5: TMenuItem;
    Atamayap1: TMenuItem;
    MenuItem6: TMenuItem;
    BuiiEPostaGnder1: TMenuItem;
    BuiYazdr1: TMenuItem;
    MenuItem9: TMenuItem;
    IsiKopyalaMenu: TMenuItem;
    IsiSilMenu: TMenuItem;
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
    DtsYorum: TDataSource;
    TabYorumMedya: TcxTabSheet;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    TabYorum: TFDQuery;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    Panel2: TPanel;
    ToolBar4: TToolBar;
    GorevEkleTus: TToolButton;
    GorevSilTus: TToolButton;
    ToolButton8: TToolButton;
    GorevDuzenleTus: TToolButton;
    JvNavPanelHeader1: TJvNavPanelHeader;
    CheckTamamlanan: TcxCheckBox;
    ComboTamamlanan: TcxImageComboBox;
    PageControlUst: TcxPageControl;
    TabSheetListe: TcxTabSheet;
    TabSheetGrup: TcxTabSheet;
    GridFirsat: TcxGrid;
    GridFirsatView: TcxGridDBTableView;
    GridFirsatViewBASTARIHI: TcxGridDBColumn;
    GridFirsatViewPROJEKODU: TcxGridDBColumn;
    GridFirsatViewFIRMA: TcxGridDBColumn;
    GridFirsatViewTURU: TcxGridDBColumn;
    GridFirsatViewKONU: TcxGridDBColumn;
    GridFirsatViewTIPI: TcxGridDBColumn;
    GridFirsatViewSATISFIYATI: TcxGridDBColumn;
    GridFirsatViewPROJEKUR: TcxGridDBColumn;
    GridFirsatViewDURUM: TcxGridDBColumn;
    GridFirsatViewBelgeVar: TcxGridDBColumn;
    GridFirsatViewILGILI1: TcxGridDBColumn;
    GridFirsatViewNOTLAR: TcxGridDBColumn;
    GridFirsatViewBITTARIHI: TcxGridDBColumn;
    GridFirsatViewSONUC: TcxGridDBColumn;
    GridFirsatViewSONUCACIKLAMA: TcxGridDBColumn;
    GridFirsatViewSONAKTKONUSU: TcxGridDBColumn;
    GridFirsatViewSONAKTTARIHI: TcxGridDBColumn;
    GridFirsatViewSONSATBELGETARIHI: TcxGridDBColumn;
    GridFirsatViewSONSATTUTARI: TcxGridDBColumn;
    GridFirsatViewDEGISTIRMETARIHI: TcxGridDBColumn;
    GridFirsatViewDEGISTIREN: TcxGridDBColumn;
    GridFirsatViewEKLEMETARIHI: TcxGridDBColumn;
    GridFirsatViewEKLEYEN: TcxGridDBColumn;
    GridFirsatViewSUBEID: TcxGridDBColumn;
    GridFirsatViewOLASILIK: TcxGridDBColumn;
    GridFirsatViewPRJ_SORUMLUSU_ID: TcxGridDBColumn;
    GridFirsatViewBASLAMAAY: TcxGridDBColumn;
    GridFirsatViewBASLAMAYIL: TcxGridDBColumn;
    GridFirsatViewBITISAY: TcxGridDBColumn;
    GridFirsatViewBITISYIL: TcxGridDBColumn;
    GridFirsatViewID: TcxGridDBColumn;
    GridFirsatViewSONTEKLIFDURUMU: TcxGridDBColumn;
    GridFirsatViewSONTEKLIFTARIHI: TcxGridDBColumn;
    GridFirsatViewSONTEKLIFTUTARI: TcxGridDBColumn;
    GridFirsatViewSONTEKLIFKUR: TcxGridDBColumn;
    GridFirsatViewSEBEBI: TcxGridDBColumn;
    GridFirsatViewRAKIP: TcxGridDBColumn;
    GridFirsatViewALANRAKIP: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    FTileControl: TdxTileControl;
    FTileControlActionBarItem1: TdxTileControlActionBarItem;
    FirsatInfoMenu: TMenuItem;
    N5: TMenuItem;
    ProjeOlusturMenu: TMenuItem;
    N6: TMenuItem;
    FirsatKapatMenu: TMenuItem;
    ServisOlusturMenu: TMenuItem;
    N7: TMenuItem;
    labelFileName: TcxLabel;
    CheckZenginMetin: TcxCheckBox;
    procedure YenileTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure GorTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure qryPROJELERrrAfterOpen(DataSet: TDataSet);
    procedure AraFirmaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboTuruKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AramaYap;
    procedure GridFirsatViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridFirsatViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure Kopyala1Click(Sender: TObject);
    procedure FIRSATLARBeforeOpen(DataSet: TDataSet);
    procedure GrupA1Click(Sender: TObject);
    procedure GridTeklifViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridTeklifViewDblClick(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure IlgiliEkleTusClick(Sender: TObject);
    procedure IlgiliSilTusClick(Sender: TObject);
    procedure IlgiliDuzenleTusClick(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure GridFirsatViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure TabTeklifAfterOpen(DataSet: TDataSet);
    procedure TamamlandiIsaretleMenuClick(Sender: TObject);
    procedure PageControlSekmeChange(Sender: TObject);
    procedure DuzenleMenuClick(Sender: TObject);
    procedure GorevGridDBTableView1ACKAPASECIMPropertiesEditValueChanged(
      Sender: TObject);
    procedure GorevGridDBTableView1DblClick(Sender: TObject);
    procedure Bayraklaretle1Click(Sender: TObject);
    procedure IsiSilMenuClick(Sender: TObject);
    procedure IsiKopyalaMenuClick(Sender: TObject);
    procedure GorevGridDBTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure TreeListGorevDblClick(Sender: TObject);
    procedure TreeListGorevClick(Sender: TObject);
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
    procedure GorevEkleTusClick(Sender: TObject);
    procedure GorevSilTusClick(Sender: TObject);
    procedure CheckTamamlananClick(Sender: TObject);
    procedure FTileControlItemClick(Sender: TdxTileControlItem);
    procedure FTileControlItemDragEnd(Sender: TdxCustomTileControl;
      AInfo: TdxTileControlDragItemInfo);
    procedure FTileControlItemDragBegin(Sender: TdxCustomTileControl;
      AInfo: TdxTileControlDragItemInfo; var AAllow: Boolean);
    procedure PageControlUstChange(Sender: TObject);
    procedure ProjeOlusturMenuClick(Sender: TObject);
    procedure FirsatKapatMenuClick(Sender: TObject);
    procedure ServisOlusturMenuClick(Sender: TObject);
    procedure FirsatInfoMenuClick(Sender: TObject);
  private
    { Private declarations }
    ProjeID, RehberId:integer;
    SecilenItem : TdxTileControlItem;
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TFirsatListeAramaFrame;
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
    procedure FirsatListeDlgKapatEylemi(Sender: TObject);
//    procedure ProjeListeDlgEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TFirsatListeAramaFrame);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure GrubaElemanEkle(ProjeId,Asama, RehberId:Integer; Firma,ProjeAdi,Konusu,Turu, BasTarih, BitTarih:String);
    procedure FirsatKapat;
  public
    { Public declarations }
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
  published
    property Arama      : TFirsatListeAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm, FetaKurulusSiniflari, FetaClassExtensions,  PrjConst, UFastRap, LocOnfly, UTeklifListeDlg, ULog,
     UIsListesi, UGorevDlg;

{$R *.dfm}

{ TFirsatListeDlg }

procedure TFirsatListeDlg.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TFirsatListeDlg.AraFirmaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
     GorTusClick(Self)
  else if Key = 38 then
    FIRSATLAR.Prior
  else if Key = 40 then
    FIRSATLAR.next
  else if TEdit(Sender).Text <> '' then
   AramaYap;
end;

procedure TFirsatListeDlg.AramaYap;
begin
   JvTimer1.Enabled := False;
   JvTimer1.Interval := 700;
   JvTimer1.Enabled := True;
end;

procedure TFirsatListeDlg.JvTimer1Timer(Sender: TObject);
var
  PID:integer;
begin
  JvTimer1.Enabled := False;
  ///  Gridde alan kontrolu
  if (FIRSATLAR.Active)and(FIRSATLAR.RecordCount>0) then
    PID := FIRSATLAR.FieldByName('ID').AsInteger;
  Tablo.GrideAlanEkle('PROJELER', 'FirsatWizardDlg', GridFirsatView);

  FIRSATLAR.Close;
  FIRSATLAR.SQL.Text:= SQLMemo.Text;
  if FArama.checkTarih.Checked then
   begin
     //FArama.dateProjeBaslangic.PostEditValue;
     //FArama.dateProjeBitis.PostEditValue;
     FIRSATLAR.SQL.Add(' AND P.BASLAMATARIHI >= '''+FormatDateTime('yyyy-mm-dd 00:00',FArama.dateProjeBaslangic.Date) +''' ');
     FIRSATLAR.SQL.Add(' AND P.BASLAMATARIHI <= '''+FormatDateTime('yyyy-mm-dd 23:59',FArama.dateProjeBitis.Date) +''' ');
   end;
  if StringReplace(FArama.AraFirma.Text,' ','',[rfReplaceAll])<>'' then
     FIRSATLAR.SQL.Add(' AND ISNULL(R1.FIRMA,'''') LIKE ''%'+FArama.AraFirma.Text+'%'' ');
  if StringReplace(FArama.AraProjeKodu.Text,' ','',[rfReplaceAll])<>'' then
     FIRSATLAR.SQL.Add(' AND ISNULL(P.PROJEKODU,'''') LIKE ''%'+FArama.AraProjeKodu.Text+'%'' ');
  if StringReplace(FArama.ComboSorumlu.Text,' ','',[rfReplaceAll])<>'' then
     FIRSATLAR.SQL.Add(' AND P.PRJ_SORUMLUSU_ID = '+IntToStr(FArama.ComboSorumlu.Tag)+' ');
  if StringReplace(FArama.ComboKonusu.Text,' ','',[rfReplaceAll])<>'' then
     FIRSATLAR.SQL.Add(' AND ISNULL(P.KONUSU,'''') LIKE ''%'+FArama.ComboKonusu.Text+'%'' ');

  if FArama.ComboTuru.EditValue>0 then
     FIRSATLAR.SQL.Add(' AND P.TURU ='+VarToStr(FArama.ComboTuru.EditValue)+' ');

  if FArama.comboAsama.EditValue>0 then
     FIRSATLAR.SQL.Add(' AND P.ASAMA='+VarToStr(FArama.comboAsama.EditValue)+'');

  if not(FArama.checkKapaliGoster.Checked) then
     FIRSATLAR.SQL.Add(' AND P.DURUM <> 2 ');

  case ModulYetki_TekSubeTum.Proje of
     1: FIRSATLAR.SQL.Add(' AND P.PRJ_SORUMLUSU_ID='+Kullanan);//sadece kendi projelerini g�r�r
    10: FIRSATLAR.SQL.Add(' AND P.SUBEID='+IntToStr(SubeId));//sadece kendi �ube projelerini g�r�r
  end;

  if SubeVarmi then
     FIRSATLAR.SQL.Text:=FIRSATLAR.SQL.Text+ ' and P.SUBEID in('+Tablo.YetkiliSubeleriGetir(21,YetkiTur_Gorme)+') ';

  FIRSATLAR.SQL.Add(' ORDER BY P.SATISKUR ');
  //ProjeID := PID;
  TabloYenile(FIRSATLAR,[],PID,'ID');
  //RehberId:= FIRSATLAR.FieldByName('REHBERID').AsInteger;
  GridFirsatView.ViewData.Expand(True);
end;

function TFirsatListeDlg.EkranAdiAl: string;
begin
  Result := 'FirsatListeDlg';
end;

procedure TFirsatListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxPROJELER) then begin
      AFastReport.EnabledDataSets.Clear;
      AFastReport.EnabledDataSets.Add(frxPROJELER)
   end else begin
      frxPROJELER.DataSet := FIRSATLAR;
      AFastReport.EnabledDataSets.Clear;
      AFastReport.EnabledDataSets.Add(frxPROJELER);
   end;


    DokumDegiskenListesi.Add('PROJELERID'+'$@$'+FIRSATLAR.FieldByName('ID').AsString);
end;

procedure TFirsatListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   if FIRSATLAR.Active then begin
       s := YaziciYaz.Caption;
       Delete(s, pos('&',s), 1);
       YazdirmayaHazirla(FastRaporDlg.frxReport1);
       FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
   end;
end;

procedure TFirsatListeDlg.Baslatildi;
var ra : string;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y�kleniyor.
  //GridFirsatView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\ProjelerGridi',true,false,[gsoUseFilter],'ProjelerGridi');
   Tablo.GridAyarRestore('FirsatGridi',GridFirsatView );
  //GridTeklifView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\ProjeTekliflerGridi',true,false,[gsoUseFilter],'ProjeTekliflerGridi');
  Tablo.GridAyarRestore('FirsatTekliflerGridi',GridTeklifView );
  //Tablo.GridAyarRestore('IsListesiGridi_Proje', GorevGridDBTableView1);

  Tablo.GridTurkcelestir;

  PageControlUst.ActivePageIndex := 0;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
   TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;

   ComboTamamlanan.ItemIndex := 0;


    if not Tablo.YetkiVarmi(2111,YetkiTur_Ekleme,False)then begin//proje ekleme yetkisi
      GridFirsat.PopupMenu := Nil;  //kopyalama
      YeniTus.Visible := False;
    end;
    if not Tablo.YetkiVarmi(2111,YetkiTur_Degistirme,False)then begin//proje de�i�tirme yetkisi
      GridFirsatView.OnDblClick := Nil;
      SilTus.Visible := False;
      GorTus.Visible := False;
    end;

//   Tablo.ProjeInit( nil , nil,  nil ,    TcxComboBoxProperties(GridFirsatViewSATISKUR.Properties), TcxComboBoxProperties(GridFirsatViewSATISKUR.Properties));

end;

procedure TFirsatListeDlg.Bayraklaretle1Click(Sender: TObject);
begin
//adn   Menu_Bayrak(Sender, GorevGridDBTableView1);
   PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,Tabno_projeler , FIRSATLAR.FieldByName('ID').AsInteger, FIRSATLAR.FieldByName('REHBERID').AsInteger, TabYorum, CheckZenginMetin.Checked);
end;

procedure TFirsatListeDlg.CheckTamamlananClick(Sender: TObject);
begin
   ComboTamamlanan.Visible := CheckTamamlanan.Checked;
   if ComboTamamlanan.Visible  then
      ComboTamamlanan.ItemIndex:=4;
   PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.ComboTuruKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   AramaYap;
end;

procedure TFirsatListeDlg.GridFirsatViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridFirsat;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFirsatView;
   AnaForm.pmGridStil.Tags.Values[GridFirsat.Name]:='FirsatGridi';
end;

procedure TFirsatListeDlg.GridFirsatViewSelectionChanged( Sender: TcxCustomGridTableView);
begin
   //ProjeID := FIRSATLAR.Fields[0].AsInteger;
   //RehberId:= FIRSATLAR.FieldByName('REHBERID').AsInteger;
   PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.GridFirsatViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TFirsatListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TFirsatListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_projeler, FIRSATLAR.Fields[0].AsInteger]);
  end;
end;

procedure TFirsatListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, FIRSATLAR.Fields[0].AsInteger)
end;

procedure TFirsatListeDlg.DuzenleMenuClick(Sender: TObject);
begin
   Menu_Duzenle(Sender, TabGorevler);
   PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.PageControlSekmeChange(Sender: TObject);
var AcKapa:String[1];
    GunSay : Smallint;
    ARecIndex:Integer;
begin
    if (not FIRSATLAR.Active) or (FIRSATLAR.recordcount<1) then exit;

    if PageControlSekme.ActivePage=TabSheetGorevler then begin
        AcKapa:=IntToStr(Abs(StrToInt(BoolToStr(CheckTamamlanan.Checked))));
        if CheckTamamlanan.Checked then
           GunSay := ComboTamamlanan.EditValue
        else
           GunSay := 9999;
        TabloYenile(TabGorevler,[Kullanan, AcKapa,  GunSay, FIRSATLAR.Fields[0].AsInteger]);
    end
    else if PageControlSekme.ActivePage=TabSheetTeklifler then begin
        TabloYenile(TabTeklif, [FIRSATLAR.Fields[0].AsInteger]);
    end else if PageControlSekme.ActivePage = TabYorumMedya then
        Tabloyenile(TabYorum,[Tabno_projeler, FIRSATLAR.Fields[0].AsInteger]);
end;

procedure TFirsatListeDlg.GrubaElemanEkle(ProjeId, Asama, RehberId:Integer; Firma, ProjeAdi, Konusu, Turu, BasTarih, BitTarih:String);
var AItem: TdxTileControlItem;
    I:Smallint;
    Item1 : TcxImageComboBoxItem;
begin
    AItem := FTileControl.Items.Add;
    with AItem do begin
      Item1 :=Tablo.repFirsatAsama.Properties.FindItemByValue(Asama);
      if Item1<>nil then
         GroupIndex := Item1.index;
      IsLarge := True;
      RowCount := 1;
      AItem.Name := 'A'+IntToStr(ProjeId);
      AItem.Tag := RehberId;
      AItem.Text1.Value := Firma;
      if ProjeAdi<>'' then AItem.Text1.Value := AItem.Text1.Value+ #13 + ProjeAdi;
      if Konusu<>'' then AItem.Text1.Value := AItem.Text1.Value+ #13 + Konusu;
      if Turu<>'' then AItem.Text1.Value := AItem.Text1.Value+ #13 + Tablo.Genini.AnahtarGetir(Ops_Proje_Turu, StrToIntDef(Turu,0), -1);

      AItem.Text1.WordWrap := True;
      AItem.Text3.Value := BasTarih;
      AItem.Text4.Value := BitTarih;

      OnClick := FTileControlItemClick;
    end;
end;

procedure TFirsatListeDlg.PageControlUstChange(Sender: TObject);
    procedure Grupla;
    var AGroup:tdxtilecontrolgroup;
        AItem: TdxTileControlItem;
        I:Smallint;
    begin
        while FTileControl.Items.Count>0 do
          FTileControl.DeleteItem(FTileControl.Items[0]);
        while FTileControl.Groups.Count>0 do
          FTileControl.Groups.Clear;
        for I := 0 to Tablo.repFirsatAsama.Properties.Items.Count-1 do begin
          AGroup := FTileControl.Groups.Add;
          AGroup.Caption.Text:=Tablo.repFirsatAsama.Properties.Items[i].Description;
          AGroup.Tag := Tablo.repFirsatAsama.Properties.Items[i].Value;
          //her bir �er�eve i�ine g�r�nmeyen bir madde ekleyelim ki bo�ald���nda grup kaybolmas�n
          AItem := FTileControl.Items.Add;
          AItem.Group := AGroup;
          AItem.Visible := False;
        end;


          //Tablo.TablodanSorguAc(1,'select ID,REHBERID,PROJEKODU,BASLAMATARIHI,BITISTARIHI from FIRSATLAR  where ASAMA='+IntToStr(Tablo.repFirsatAsama.Properties.Items[i].Value)+' and DURUM=1');
          FIRSATLAR.First;
          while not FIRSATLAR.Eof do begin
            GrubaElemanEkle(FIRSATLAR.Fields[0].AsInteger, FIRSATLAR.FieldByName('ASAMA').AsInteger, FIRSATLAR.FieldByName('REHBERID').AsInteger,
              FIRSATLAR.FieldByName('FIRMA').AsString,FIRSATLAR.FieldByName('PROJEADI').AsString, FIRSATLAR.FieldByName('KONUSU').AsString, FIRSATLAR.FieldByName('TURU').AsString,
              FIRSATLAR.FieldByName('BASLAMATARIHI').AsString, FIRSATLAR.FieldByName('BITISTARIHI').AsString);
            FIRSATLAR.next;
      end;
    end;
begin
    if (not FIRSATLAR.Active) or (FIRSATLAR.recordcount<1) then exit;

    if PageControlUst.ActivePage=TabSheetGrup then
       Grupla
    else
       FArama.YenileTus.Click;
end;

procedure TFirsatListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TFirsatListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_projeler, FIRSATLAR.Fields[0].AsInteger, TabYorum);
end;

procedure TFirsatListeDlg.ProjeOlusturMenuClick(Sender: TObject);
var FirsatId, PrjID : integer;
begin
   //proje olu�unca f�rsat kapanacaksa �u anki f�rsat ID sini lal�m
   if Application.MessageBox(PChar(SProjeFirsatKapansin), PChar(Uyari),  MB_YESNO)=ID_YES then begin  // Sor
      FirsatId:=FIRSATLAR.Fields[0].AsInteger;
   end else
      FirsatId:=0;

   ProjeID:= Tablo.SQLSatiriKopyala('PROJELER', FIRSATLAR.Fields[0].AsInteger,['MODUL','YERI','YERID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],
                                               [11,TabNo_FIRSAT, FIRSATLAR.Fields[0].AsInteger, Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);

   PrjID := Tablo.ProjeSihirbazBaslat('K',ProjeID, FIRSATLAR.FieldByName('REHBERID').AsInteger,Tablo.GENINI.BugunTrhSaat);


   if PrjID > 0 then begin
      //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update PROJELER set MODUL=11 where ID='+IntToStr(ID),[],[]);
      if FirsatId > 0 then
         FirsatKapat
      else
         TabloYenile(FIRSATLAR,[]);
   end;
end;

procedure TFirsatListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TFirsatListeDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFirsatListeDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFirsatListeDlg.FirsatKapat;
var
   SonucListe : TStringList;
begin
   if FIRSATLAR.FieldByName('DURUM').AsInteger=1  then begin
       SonucListe := TStringList.Create;
       if not Tablo.HizliGirisListedenBilgiGetir('Fırsat Sonuç','select ANAHTAR,DEGER from GENINI where BOLUM=-2113 and DIL=-1 and DEGER<0 '+
                  ' order by 1 ',SonucListe,False,[True, False],[]) then abort;
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PROJELER set DURUM=2, ASAMA='+ IntTostr(StrToIntDef(SonucListe[1],0))+' where ID='+FIRSATLAR.FieldByName('ID').AsString,[],[]);
       SonucListe.Free;
       TabloYenile(FIRSATLAR,[]);
   end
end;

procedure TFirsatListeDlg.FirsatKapatMenuClick(Sender: TObject);
begin
  FirsatKapat;
end;

procedure TFirsatListeDlg.FirsatInfoMenuClick(Sender: TObject);
begin
  if not FIRSATLAR.IsEmpty then
    Tablo.InfoGoster('PROJELER', FIRSATLAR.FieldByName('ID').AsInteger, 170);
end;

function TFirsatListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TFirsatListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TFirsatListeDlg.GorevEkleTusClick(Sender: TObject);
var
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin
     GorevId := Tablo.GorevOlustur('', Tablo.GENINI.ReadInteger(Ops_OpsiyonIs_VarsayilanKlasor, Masaustu), 0,
                                   FIRSATLAR.Fields[0].AsInteger, 0, FIRSATLAR.FieldByName('REHBERID').AsInteger, 0, 0, 0,
                                   0, 0, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat);

      Tablo.GorevSihirbazBaslat(GorevDlg1, 'E', GorevId, AtamaYapildi, YorumYapildi);
      if AtamaYapildi then
         Gorev_EPostaGonder(1, GorevId)
      else if YorumYapildi then
         Gorev_EPostaGonder(3, GorevId);
      PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.GorevGridDBTableView1ACKAPASECIMPropertiesEditValueChanged(Sender: TObject);
begin
   TamamlandiIsaretleMenuClick(Self);
end;

procedure TFirsatListeDlg.GorevGridDBTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if AcellViewinfo.Item.Tag = 1 then begin
//     TamamlandiIsaretleMenuClick(Self);
//     Menu_Tamam(GorevlerMenu, GorevGridDBTableView1, Scheduler, FArama.TabListe.Fields[0].AsInteger);
     UpdateveMail(Masaustu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, False);
     PlayWavFromResource('Blink');
     PageControlSekmeChange(Self);
  end;
  Abort;//Bunu kesinlikle silme (listede tek sat�r kal�nca hata verdi�i i�in eklendi)
end;

procedure TFirsatListeDlg.GorevGridDBTableView1DblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TFirsatListeDlg.GorevSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) = ID_OK then begin
     Tablo.GorevSil(TabGorevler.Fields[0].AsInteger);
     PageControlSekmeChange(Self);
  end;
end;

procedure TFirsatListeDlg.GorTusClick(Sender: TObject);
var
  PID:integer;
begin
   PID := FIRSATLAR.Fields[0].AsInteger;
   if PageControlUst.ActivePage=TabSheetGrup then begin
      Tablo.FirsatSihirbazBaslat('D',  PID, FIRSATLAR.FieldByName('REHBERID').AsInteger,Tablo.GENINI.BugunTrh);
      //tekrar g�sterelim, bunun i�in silip ekleyelim
      FTileControl.DeleteItem(SecilenItem);
      Tablo.TablodanSorguAc(2,'select P.ID, ASAMA,REHBERID,	FIRMA= CASE WHEN LEN(LTRIM(RTRIM(FIRMA)))-LEN(REPLACE(LTRIM(RTRIM(FIRMA)),'' '',''''))<2 THEN FIRMA ELSE SUBSTRING(FIRMA, 0, CHARINDEX('' '', FIRMA, CHARINDEX('' '', FIRMA, 0)+1)) END,'+
       ' PROJEADI,KONUSU,TURU,BASLAMATARIHI,BITISTARIHI from PROJELER P '+
       ' inner join REHBER R on P.REHBERID=R.ID where P.ID='+IntToStr(PID));
      GrubaElemanEkle(Tablo.Query2.Fields[0].AsInteger, Tablo.Query2.FieldByName('ASAMA').AsInteger, Tablo.Query2.FieldByName('REHBERID').AsInteger,
        Tablo.Query2.FieldByName('FIRMA').AsString, Tablo.Query2.FieldByName('PROJEADI').AsString, Tablo.Query2.FieldByName('KONUSU').AsString,
        Tablo.Query2.FieldByName('TURU').AsString, Tablo.Query2.FieldByName('BASLAMATARIHI').AsString, Tablo.Query2.FieldByName('BITISTARIHI').AsString);
   end else begin
       //ProjeID := FIRSATLAR.Fields[0].AsInteger;
       //RehberId:= FIRSATLAR.FieldByName('REHBERID').AsInteger;
       if Tablo.FirsatSihirbazBaslat('D',  PID, FIRSATLAR.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh) > 0 then
          FArama.YenileTus.Click;
   end;
   sleep(1000);
   FIRSATLAR.Locate('ID', PID, []);
   //GridFirsatView.DataController.SetFocus;
end;

procedure TFirsatListeDlg.Gorunmez;
begin

end;

procedure TFirsatListeDlg.GorunmezOlacak;
begin

end;

procedure TFirsatListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
  AramaYap;
end;

procedure TFirsatListeDlg.GorunurOlacak;
begin

end;

procedure TFirsatListeDlg.GridTeklifViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridTeklif;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTeklifView;
  AnaForm.pmGridStil.Tags.Values[GridTeklif.Name]:='FirsatTekliflerGridi';
end;

procedure TFirsatListeDlg.GridTeklifViewDblClick(Sender: TObject);
begin
  if Tablo.TeklifSihirbazBaslat('D',80,0,TabTeklif.FieldByName('ID').AsInteger, TabTeklif.FieldByName('REHBERID').AsInteger,-1)>0 then
     TabloYenile(TabTeklif, [FIRSATLAR.Fields[0].AsInteger]);
end;

procedure TFirsatListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_projeler);
end;

procedure TFirsatListeDlg.GrupA1Click(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0:GridFirsatView.DataController.Groups.FullCollapse;
    1:GridFirsatView.DataController.Groups.FullExpand;
  end;
end;

procedure TFirsatListeDlg.IlgiliDuzenleTusClick(Sender: TObject);
begin
   if Tablo.TeklifSihirbazBaslat('D', 80, 0, TabTeklif.Fields[0].AsInteger, FIRSATLAR.Fields[0].AsInteger,-1)>0 then
      TabloYenile(TabTeklif, [FIRSATLAR.Fields[0].AsInteger]);
end;

procedure TFirsatListeDlg.IlgiliEkleTusClick(Sender: TObject);
begin
   if Tablo.TeklifSihirbazBaslat('E',80,0,-1,FIRSATLAR.FieldByName('REHBERID').AsInteger, FIRSATLAR.Fields[0].AsInteger) > 0 then
      TabloYenile(TabTeklif, [FIRSATLAR.Fields[0].AsInteger]);
end;

procedure TFirsatListeDlg.IlgiliSilTusClick(Sender: TObject);
begin
   if TeklifSilmeIslemi(TabTeklif) then
      TabloYenile(TabTeklif, [FIRSATLAR.Fields[0].AsInteger]);
end;

procedure TFirsatListeDlg.IsiKopyalaMenuClick(Sender: TObject);
begin
  Tablo.GorevKopyala(TabGorevler.Fields[0].AsInteger, TabGorevler.FieldByName('KONUSU').AsString);
  PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.IsiSilMenuClick(Sender: TObject);
begin
   if Tablo.GorevSil(TabGorevler.Fields[0].AsInteger) then
      PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TFirsatListeDlg.Kopyala1Click(Sender: TObject);
begin
   ProjeID:= Tablo.SQLSatiriKopyala('PROJELER',FIRSATLAR.Fields[0].AsInteger,['EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);

  if Tablo.FirsatSihirbazBaslat('K', ProjeID, FIRSATLAR.FieldByName('REHBERID').AsInteger,Tablo.GENINI.BugunTrhSaat) > 0 then begin
     TabloYenile(FIRSATLAR,[]);
     //ProjeID := ProjeID;
     //RehberId:= FIRSATLAR.FieldByName('REHBERID').AsInteger;
  end;
end;

procedure TFirsatListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TFirsatListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TFirsatListeDlg.FIRSATLARBeforeOpen(DataSet: TDataSet);
begin
  FIRSATLAR.SQL.Text:=StringReplace(FIRSATLAR.SQL.Text,':PKullanan',Kullanan,[rfReplaceAll]);
end;

procedure TFirsatListeDlg.FirsatListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TFirsatListeDlg.ServisOlusturMenuClick(Sender: TObject);
var ServisId : Integer;
begin
   ServisId := Tablo.ServisOlustur(FIRSATLAR.FieldByName('REHBERID').AsInteger,FIRSATLAR.FieldByName('KONUSU').AsString,TabNo_FIRSAT, FIRSATLAR.Fields[0].AsInteger,FIRSATLAR.Fields[0].AsInteger,Windows_Donusum);   //Windows_Donusum
   if ServisId > 0 then
      Tablo.ServisSihirbazBaslat(False, 'D',0, ServisId, FIRSATLAR.FieldByName('REHBERID').AsInteger);
end;

procedure TFirsatListeDlg.SetArama(const Value: TFirsatListeAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    dateProjeBaslangic.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    dateProjeBitis.Date := Date+60;
    checkTarih.Checked:=False;
//    YenileTus.Click;     //tarih check i�aretlenince yenileme yap�ld��� i�in kapat�ld�

    { Arama olay atamas� }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tan�mlamay� AnaForm'daki AramaFrame OlayBaglamalari tag'�nda ger�ekle�tirebilirsiniz.  }
    { Detayl� bilgi i�in AnaForm'daki �rneklere bak�n�z. }
  end;
end;

procedure TFirsatListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFirsatListeDlg.SilTusClick(Sender: TObject);
var
    GoogleTakvimSonuc:boolean;
begin
   if (RolId<>'-1')and(FIRSATLAR.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
       Application.MessageBox(PChar(AWSorumluHaricindeSilmeYapilmaz), PChar(Uyari), MB_OK + MB_ICONERROR);
       Abort;
   end;

   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      //varsa dokumanlar�n silinmeli

     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from FATBASLIK where PROJEID =  &SId', ['&SId'],[FIRSATLAR.Fields[0].AsInteger]) then
        raise Exception.Create(PDFaturaVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from KASA where PROJEID =  &SId', ['&SId'],[FIRSATLAR.Fields[0].AsInteger]) then
        raise Exception.Create(RDPlanVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from CEKHAREKET where PROJEID =  &SId', ['&SId'],[FIRSATLAR.Fields[0].AsInteger]) then
        raise Exception.Create(RDCekVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from GOREVLER where PROJEID =  &SId', ['&SId'],[FIRSATLAR.Fields[0].AsInteger]) then
        raise Exception.Create(RDAktiviteVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from TEKLIF where PROJEID =  &SId', ['&SId'],[FIRSATLAR.Fields[0].AsInteger]) then
        raise Exception.Create(RDTeklifVerisiVarSilinemez);

        Tablo.TablodanSorguAc(5,'select * from PROJELER where ID='+FIRSATLAR.Fields[0].AsString);
       if (GCalendarAktif = true) and ( Tablo.Query5.FieldByName('GOOGLEOLAYID').AsString <> '') then
      begin
        GoogleTakvimSonuc:= Tablo.GoogleTakvimSil(Tablo.Query5.FieldByName('GOOGLEHESAPID').AsInteger,
                                                  Tablo.Query5.FieldByName('GOOGLEOLAYID').AsString);
        if GoogleTakvimSonuc= false then
           Showmessage(AKGoogle_takvim_silinemedi);
      end;


      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],
         [41, FIRSATLAR.Fields[0].AsInteger]);
      //varsa proje ba�lant�lar� silinmeli
      //kendisi silinir
      //FIRSATLAR.Delete;
      // Detay (REHBERBILGI firsat bilgileri, YERI=proje) SILMEDEN ONCE logla.
      LogDetaylariSil('REHBERBILGI', 'YER_ID', TabNo_PROJEDETAY, TabNo_FIRSAT, FIRSATLAR.Fields[0].AsInteger, 'YERI=' + IntToStr(TabNo_PROJELER));
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' DELETE FROM REHBERBILGI WHERE YERI = &RYer AND YER_ID = &YerId ', ['&RYer','&YerId'],[TabNo_PROJELER, FIRSATLAR.Fields[0].AsInteger]);
      // Detay satirlarini SILMEDEN ONCE logla (ust=firsat), sonra sil.
      LogDetaylariSil('PROJEASAMA', 'PROJEID', TabNo_PROJEASAMA, TabNo_FIRSAT, FIRSATLAR.Fields[0].AsInteger);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' DELETE FROM PROJEASAMA where PROJEID= &YerId ', ['&YerId'],[ FIRSATLAR.Fields[0].AsInteger]);

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PROJELER where Id=&id ',['&id'],[FIRSATLAR.Fields[0].AsInteger]);

    // Kart SILME logu (TabNo_FIRSAT: detay loglariyla tutarli; eskiden yanlislikla TabNo_PROJELER yaziliyordu)
    LogKartSil(FIRSATLAR, TabNo_FIRSAT, FIRSATLAR.Fields[0].AsInteger);

      FArama.YenileTus.Click;
        /// SQL2005 TE hataya neden oldu�u i�in delete olay�n� kendimiz yap�yoruz
       Abort;
   end;

end;

procedure TFirsatListeDlg.qryPROJELERrrAfterOpen(DataSet: TDataSet);
begin
   GorTus.Visible   := FIRSATLAR.RecordCount>0;
   SilTus.Visible :=  GorTus.Visible;
end;

procedure TFirsatListeDlg.TabTeklifAfterOpen(DataSet: TDataSet);
begin
  if FIRSATLAR.Active then
    TabloYenile(TabTeklifDetay, [FIRSATLAR.Fields[0].AsInteger]);
end;

procedure TFirsatListeDlg.TamamlandiIsaretleMenuClick(Sender: TObject);
begin
//Ad   Menu_Tamam(Sender, GorevGridDBTableView1);
   PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.ToolButton3Click(Sender: TObject);
var st : Tstringlist;
begin
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(ProjeSecimi,'select T.ID,[TARIH],[TEKLIFNO],TURU=(select ANAHTAR from GENINI where BOLUM=-2901 and DEGER=T.TURU),'+
          ' [KONUSU],DURUM=(select ANAHTAR from GENINI where BOLUM=-2902 and DEGER=T.DURUM),HAZIRLAYAN=R.FIRMA,[TEKLIF_MATRAHI],[KUR]'+
          ' from TEKLIF T inner join REHBER R on T.HAZIRLAYAN=R.ID'+
          ' where isnull(PROJEID,0)<=0 and ((TEKLIFNO like ''%<ara>%'' )or(KONUSU like ''%<ara>%'')) and REHBERID=' + FIRSATLAR.FieldByName('REHBERID').AsString+' order by TARIH desc', st, []) then
      begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIF set PROJEID=' + FIRSATLAR.Fields[0].AsString + ' Where ID=' +st.Strings[0]+ ' ', [], []);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFDETAY set PROJEID=' + FIRSATLAR.Fields[0].AsString + ' Where TEKLIFID=' + st.Strings[0]+ ' ', [], []);
          TabloYenile(TabTeklif, [FIRSATLAR.Fields[0].AsInteger]);
      end;
    finally
      st.free;
    end
end;

procedure TFirsatListeDlg.ToolButton4Click(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIF set PROJEID=0 Where ID=' +TabTeklif.Fields[0].AsString, [], []);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFDETAY set PROJEID=0 Where TEKLIFID=' + TabTeklif.Fields[0].AsString, [], []);
   TabloYenile(TabTeklif, [FIRSATLAR.Fields[0].AsInteger]);
end;

procedure TFirsatListeDlg.FTileControlItemClick(Sender: TdxTileControlItem);
begin
   SecilenItem := Sender;
   ProjeID:= StrToInt(copy(SecilenItem.Name,2,99));
   RehberId:= TdxTileControlItem(Sender).Tag;
   FIRSATLAR.locate('ID', FIRSATLAR.Fields[0].AsInteger, []);
   PageControlSekmeChange(Self);
end;

procedure TFirsatListeDlg.FTileControlItemDragBegin(Sender: TdxCustomTileControl;
  AInfo: TdxTileControlDragItemInfo; var AAllow: Boolean);
begin
   SecilenItem := AInfo.item;
   ProjeID := StrToInt(copy(AInfo.item.Name,2,99));
   RehberId:= AInfo.item.tag;
end;

procedure TFirsatListeDlg.FTileControlItemDragEnd(Sender: TdxCustomTileControl;AInfo: TdxTileControlDragItemInfo);
begin
   if AInfo.Group <> nil then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PROJELER set ASAMA='+IntToStr(AInfo.Group.Tag)+' where ID='+IntToStr(ProjeID),[],[]);
end;

procedure TFirsatListeDlg.TreeListGorevClick(Sender: TObject);
var   TreeHitTest: TcxTreeListHitTest;
begin
     TreeHitTest := (Sender as TcxDBTreeList).HitTest;
     if not TreeHitTest.HitAtColumn  then // soldaki + alt seviye a�ma tu�una bast���nda a�ma/kapatma yapmas�n diye
        exit;


   if TcxDBTreeList(Sender).FocusedColumn.tag=1 then begin
      UpdateveMail(MasaUstu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, TcxDBTreeList(Sender).FocusedNode.HasChildren);
      PlayWavFromResource('Blink');
      PageControlSekmeChange(Self);
  end;
  Abort;//Bunu kesinlikle silme (listede tek sat�r kal�nca hata verdi�i i�in eklendi)
end;

procedure TFirsatListeDlg.TreeListGorevDblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TFirsatListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFirsatListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFirsatListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFirsatListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TFirsatListeDlg.YeniTusClick(Sender: TObject);
begin
   if Tablo.FirsatSihirbazBaslat('E',-1,-99,Tablo.GENINI.BugunTrhSaat) > 0 then begin
      if PageControlUst.ActivePage=TabSheetGrup then
         PageControlUstChange(Self);
      FArama.YenileTus.Click;
   end;
end;

procedure TFirsatListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Projeler);
end;

procedure TFirsatListeDlg.YenileTusClick(Sender: TObject);
begin
  AramaYap;
end;

initialization
  RegisterClass(TFirsatListeDlg);
end.

{  TabTeklif.Close;
  TabTeklifTarihler.Close;
  if SubeVarmi then
    s := ' and SUBEID in('+Tablo.YetkiliSubeleriGetir(29,YetkiTur_Gorme)+') '
  else
    s:='';
  TabTeklifTarihler.SQL.Text := StringReplace(SQLMemoTeklif.Text,'--Subesi',s,[rfReplaceAll]);
  //TabTeklifTarihler.Params[0].Value:=RehberId;

  TabloYenile(TabTeklifTarihler, [ProjeID]);
}










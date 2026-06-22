unit UProjeListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 04/12/2010 13:45:17}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, cxTLData,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls, JvTimer, cxImage,
  UProjeListeAramaFrame,dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
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
  dxSkinVisualStudio2013Light, cxRichEdit, dxScrollbarAnnotations, dxDateRanges;

type
  TProjeListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsProjeler: TDataSource;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    GorTus: TToolButton;
    SQLMemo: TcxMemo;
    PROJELER: TFDQuery;
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
    JvTimer1: TJvTimer;
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
    labelFileName: TcxLabel;
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
    GridProjeler: TcxGrid;
    cxGridProjeler: TcxGridDBTableView;
    cxGridProjelerBASTARIHI: TcxGridDBColumn;
    cxGridProjelerPROJEKODU: TcxGridDBColumn;
    cxGridProjelerFIRMA: TcxGridDBColumn;
    cxGridProjelerTURU: TcxGridDBColumn;
    cxGridProjelerKONU: TcxGridDBColumn;
    cxGridProjelerTIPI: TcxGridDBColumn;
    cxGridProjelerSATISFIYATI: TcxGridDBColumn;
    cxGridProjelerPROJEKUR: TcxGridDBColumn;
    cxGridProjelerDURUM: TcxGridDBColumn;
    cxGridProjelerBelgeVar: TcxGridDBColumn;
    cxGridProjelerILGILI1: TcxGridDBColumn;
    cxGridProjelerASAMA: TcxGridDBColumn;
    cxGridProjelerNOTLAR: TcxGridDBColumn;
    cxGridProjelerBITTARIHI: TcxGridDBColumn;
    cxGridProjelerSONUC: TcxGridDBColumn;
    cxGridProjelerSONUCACIKLAMA: TcxGridDBColumn;
    cxGridProjelerSONAKTKONUSU: TcxGridDBColumn;
    cxGridProjelerSONAKTTARIHI: TcxGridDBColumn;
    cxGridProjelerDEGISTIRMETARIHI: TcxGridDBColumn;
    cxGridProjelerDEGISTIREN: TcxGridDBColumn;
    cxGridProjelerEKLEMETARIHI: TcxGridDBColumn;
    cxGridProjelerEKLEYEN: TcxGridDBColumn;
    cxGridProjelerSUBEID: TcxGridDBColumn;
    cxGridProjelerASAMASORUMLU: TcxGridDBColumn;
    cxGridProjelerPROJEADI: TcxGridDBColumn;
    cxGridProjelerPRJ_SORUMLUSU_ID: TcxGridDBColumn;
    cxGridProjelerBASLAMAAY: TcxGridDBColumn;
    cxGridProjelerBASLAMAYIL: TcxGridDBColumn;
    cxGridProjelerBITISAY: TcxGridDBColumn;
    cxGridProjelerBITISYIL: TcxGridDBColumn;
    cxGridProjelerID: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    FTileControl: TdxTileControl;
    FTileControlActionBarItem1: TdxTileControlActionBarItem;
    procedure YenileTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure GorTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure qryPROJELERrrAfterOpen(DataSet: TDataSet);
    procedure AraFirmaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboTuruKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AramaYap;
    procedure cxGridProjelerCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxGridProjelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure Kopyala1Click(Sender: TObject);
    procedure PROJELERBeforeOpen(DataSet: TDataSet);
    procedure GrupA1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure cxGridProjelerSelectionChanged(Sender: TcxCustomGridTableView);
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
    procedure PROJELERAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
    ProjeID, RehberId:integer;
    SecilenItem : TdxTileControlItem;
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TProjeListeAramaFrame;
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
    procedure ProjeListeDlgKapatEylemi(Sender: TObject);
//    procedure ProjeListeDlgEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TProjeListeAramaFrame);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure GrubaElemanEkle(ProjeId,Asama, RehberId:Integer; Firma,ProjeAdi,Konusu,Turu, BasTarih, BitTarih:String);
  public
    { Public declarations }
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
  published
    property Arama      : TProjeListeAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm, FetaKurulusSiniflari, FetaClassExtensions,  PrjConst, UFastRap, LocOnfly, UTeklifListeDlg, UIsListesi, UGorevDlg;

{$R *.dfm}

{ TProjeListeDlg }

procedure TProjeListeDlg.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TProjeListeDlg.AraFirmaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
     GorTusClick(Self)
  else if Key = 38 then
    PROJELER.Prior
  else if Key = 40 then
    PROJELER.next
  else if TEdit(Sender).Text <> '' then
   AramaYap;
end;

procedure TProjeListeDlg.AramaYap;
begin
   JvTimer1.Enabled := False;
   JvTimer1.Interval := 700;
   JvTimer1.Enabled := True;
end;

procedure TProjeListeDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  ///  Gridde alan kontrolu
  Tablo.GrideAlanEkle('PROJELER', 'ProjeWizardDlg', cxGridProjeler);

  PROJELER.Close;
  PROJELER.SQL.Text:= SQLMemo.Text;
  if FArama.checkTarih.Checked then
   begin
     PROJELER.SQL.Add(' AND P.BASLAMATARIHI >= '''+FormatDateTime('yyyy-mm-dd 00:00',FArama.dateProjeBaslangic.Date) +''' ');
     PROJELER.SQL.Add(' AND P.BASLAMATARIHI <= '''+FormatDateTime('yyyy-mm-dd 23:59',FArama.dateProjeBitis.Date) +''' ');
   end;
  if StringReplace(FArama.AraFirma.Text,' ','',[rfReplaceAll])<>'' then
     PROJELER.SQL.Add(' AND ISNULL(R1.FIRMA,'''') LIKE ''%'+FArama.AraFirma.Text+'%'' ');
  if StringReplace(FArama.AraProjeKodu.Text,' ','',[rfReplaceAll])<>'' then
     PROJELER.SQL.Add(' AND ISNULL(P.PROJEKODU,'''') LIKE ''%'+FArama.AraProjeKodu.Text+'%'' ');
  if StringReplace(FArama.AraProjeAdi.Text,' ','',[rfReplaceAll])<>'' then
     PROJELER.SQL.Add(' AND ISNULL(P.PROJEADI,'''') LIKE ''%'+FArama.AraProjeAdi.Text+'%'' ');
  if StringReplace(FArama.ComboSorumlu.Text,' ','',[rfReplaceAll])<>'' then
     PROJELER.SQL.Add(' AND P.PRJ_SORUMLUSU_ID = '+IntToStr(FArama.ComboSorumlu.Tag)+' ');
  if StringReplace(FArama.AraYetkili.Text,' ','',[rfReplaceAll])<>'' then
     PROJELER.SQL.Add(' AND ISNULL(RP.FIRMA,'''') LIKE ''%'+FArama.AraYetkili.Text+'%'' ');
  if StringReplace(FArama.ComboKonusu.Text,' ','',[rfReplaceAll])<>'' then
     PROJELER.SQL.Add(' AND ISNULL(P.KONUSU,'''') LIKE ''%'+FArama.ComboKonusu.Text+'%'' ');

  if FArama.ComboTuru.EditValue>0 then
     PROJELER.SQL.Add(' AND P.TURU ='+VarToStr(FArama.ComboTuru.EditValue)+' ');

  if FArama.comboAsama.EditValue>0 then
     PROJELER.SQL.Add(' AND P.ASAMA='+VarToStr(FArama.comboAsama.EditValue)+'');
  if FArama.comboSonuc.EditValue>0 then
     PROJELER.SQL.Add(' AND P.SONUC='+VarToStr(FArama.comboSonuc.EditValue)+'');

  if not(FArama.checkKapaliGoster.Checked) then
     PROJELER.SQL.Add(' AND P.DURUM <> 2 ');

  case ModulYetki_TekSubeTum.Proje of
     1: PROJELER.SQL.Add(' AND P.PRJ_SORUMLUSU_ID='+Kullanan);//sadece kendi projelerini g?r?r
    10: PROJELER.SQL.Add(' AND P.SUBEID='+IntToStr(SubeId));//sadece kendi ?ube projelerini g?r?r
  end;

  if SubeVarmi then
     PROJELER.SQL.Text:=PROJELER.SQL.Text+ ' and P.SUBEID in('+Tablo.YetkiliSubeleriGetir(21,YetkiTur_Gorme)+') ';

  PROJELER.SQL.Add(' ORDER BY SATISKUR ');
  TabloYenile(PROJELER,[Kullanan],ProjeID,'ID');
  ProjeID := ProjeID;
  RehberId:= PROJELER.FieldByName('REHBERID').AsInteger;
  cxGridProjeler.ViewData.Expand(True);
end;

function TProjeListeDlg.EkranAdiAl: string;
begin
  Result := 'ProjeListeDlg';
end;

procedure TProjeListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxPROJELER) then
      AFastReport.EnabledDataSets.Add(frxPROJELER)
   else begin
      frxPROJELER.DataSet := PROJELER;
      AFastReport.EnabledDataSets.Add(frxPROJELER);
   end;
end;

procedure TProjeListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   if PROJELER.Active then begin
       s := YaziciYaz.Caption;
       Delete(s, pos('&',s), 1);
       YazdirmayaHazirla(FastRaporDlg.frxReport1);
       FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
   end;
end;

procedure TProjeListeDlg.Baslatildi;
var ra : string;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  Tablo.GridAyarRestore('ProjelerGridi',cxGridProjeler );

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
      GridProjeler.PopupMenu := Nil;  //kopyalama
      YeniTus.Visible := False;
    end;
    if not Tablo.YetkiVarmi(2111,YetkiTur_Degistirme,False)then begin//proje de?i?tirme yetkisi
      cxGridProjeler.OnDblClick := Nil;
      SilTus.Visible := False;
      GorTus.Visible := False;
    end;

//   Tablo.ProjeInit( nil , nil,  nil ,    TcxComboBoxProperties(cxGridProjelerSATISKUR.Properties), TcxComboBoxProperties(cxGridProjelerSATISKUR.Properties));

end;

procedure TProjeListeDlg.Bayraklaretle1Click(Sender: TObject);
begin
//adn   Menu_Bayrak(Sender, GorevGridDBTableView1);
   PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,Tabno_projeler , ProjeId,RehberId, TabYorum);
end;

procedure TProjeListeDlg.CheckTamamlananClick(Sender: TObject);
begin
   ComboTamamlanan.Visible := CheckTamamlanan.Checked;
   PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.ComboTuruKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   AramaYap;
end;

procedure TProjeListeDlg.cxGridProjelerCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridProjeler;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridProjeler;
   AnaForm.pmGridStil.Tags.Values[GridProjeler.Name]:='ProjelerGridi';
end;

procedure TProjeListeDlg.cxGridProjelerSelectionChanged( Sender: TcxCustomGridTableView);
begin
   ProjeID := PROJELER.Fields[0].AsInteger;
   RehberId:= PROJELER.FieldByName('REHBERID').AsInteger;
   PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.cxGridProjelerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TProjeListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TProjeListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_projeler, ProjeId]);
  end;
end;

procedure TProjeListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, ProjeId)
end;

procedure TProjeListeDlg.DuzenleMenuClick(Sender: TObject);
begin
   Menu_Duzenle(Sender, TabGorevler);
   PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.PageControlSekmeChange(Sender: TObject);
var AcKapa:String[1];
    GunSay : Smallint;
    ARecIndex:Integer;
begin
    if (not PROJELER.Active) or (PROJELER.recordcount<1) then exit;

    if PageControlSekme.ActivePage=TabSheetGorevler then begin
        AcKapa:=IntToStr(Abs(StrToInt(BoolToStr(CheckTamamlanan.Checked))));
        if CheckTamamlanan.Checked then
           GunSay := ComboTamamlanan.EditValue
        else
           GunSay := 9999;
        TabloYenile(TabGorevler,[Kullanan, AcKapa,  GunSay, ProjeId]);
    end
    else if PageControlSekme.ActivePage = TabYorumMedya then
        Tabloyenile(TabYorum,[Tabno_projeler, ProjeId]);
end;

procedure TProjeListeDlg.GrubaElemanEkle(ProjeId, Asama, RehberId:Integer; Firma, ProjeAdi, Konusu, Turu, BasTarih, BitTarih:String);
var AItem: TdxTileControlItem;
    I:Smallint;
    Item1 : TcxImageComboBoxItem;
begin
    AItem := FTileControl.Items.Add;
    with AItem do begin
      Item1 :=Tablo.repProjeAsama.Properties.FindItemByValue(Asama);
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

procedure TProjeListeDlg.PageControlUstChange(Sender: TObject);
    procedure Grupla;
    var AGroup:tdxtilecontrolgroup;
        AItem: TdxTileControlItem;
        I:Smallint;
    begin
        while FTileControl.Items.Count>0 do
          FTileControl.DeleteItem(FTileControl.Items[0]);
        while FTileControl.Groups.Count>0 do
          FTileControl.Groups.Clear;
        for I := 0 to Tablo.repProjeAsama.Properties.Items.Count-1 do begin
          AGroup := FTileControl.Groups.Add;
          AGroup.Caption.Text:=Tablo.repProjeAsama.Properties.Items[i].Description;
          AGroup.Tag := Tablo.repProjeAsama.Properties.Items[i].Value;
          //her bir ?er?eve i?ine g?r?nmeyen bir madde ekleyelim ki bo?ald???nda grup kaybolmas?n
          AItem := FTileControl.Items.Add;
          AItem.Group := AGroup;
          AItem.Visible := False;
        end;


          //Tablo.TablodanSorguAc(1,'select ID,REHBERID,PROJEKODU,BASLAMATARIHI,BITISTARIHI from PROJELER  where ASAMA='+IntToStr(Tablo.repProjeAsama.Properties.Items[i].Value)+' and DURUM=1');
          PROJELER.First;
          while not PROJELER.Eof do begin
            GrubaElemanEkle(PROJELER.Fields[0].AsInteger, PROJELER.FieldByName('ASAMA').AsInteger, PROJELER.FieldByName('REHBERID').AsInteger,
              PROJELER.FieldByName('FIRMA').AsString,PROJELER.FieldByName('PROJEADI').AsString, PROJELER.FieldByName('KONUSU').AsString, PROJELER.FieldByName('TURU').AsString,
              PROJELER.FieldByName('BASLAMATARIHI').AsString, PROJELER.FieldByName('BITISTARIHI').AsString);
            PROJELER.next;
      end;
    end;
begin
    if (not PROJELER.Active) or (PROJELER.recordcount<1) then exit;

    if PageControlUst.ActivePage=TabSheetGrup then
       Grupla
    else
       FArama.YenileTus.Click;
end;

procedure TProjeListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TProjeListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_projeler, ProjeId, TabYorum);
end;

procedure TProjeListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TProjeListeDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TProjeListeDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TProjeListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TProjeListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TProjeListeDlg.GorevEkleTusClick(Sender: TObject);
var
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin
     GorevId := Tablo.GorevOlustur('', Tablo.GENINI.ReadInteger(Ops_OpsiyonIs_VarsayilanKlasor, Masaustu), 0, ProjeId, 0, RehberId, 0, 0, 0,
                                   0, 0, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat);

      Tablo.GorevSihirbazBaslat(GorevDlg1, 'E', GorevId, AtamaYapildi, YorumYapildi);
      if AtamaYapildi then
         Gorev_EPostaGonder(1, GorevId)
      else if YorumYapildi then
         Gorev_EPostaGonder(3, GorevId);
      PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.GorevGridDBTableView1ACKAPASECIMPropertiesEditValueChanged(Sender: TObject);
begin
   TamamlandiIsaretleMenuClick(Self);
end;

procedure TProjeListeDlg.GorevGridDBTableView1CellClick(
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
  Abort;//Bunu kesinlikle silme (listede tek sat?r kal?nca hata verdi?i i?in eklendi)
end;

procedure TProjeListeDlg.GorevGridDBTableView1DblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TProjeListeDlg.GorevSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) = ID_OK then begin
     Tablo.GorevSil(TabGorevler.Fields[0].AsInteger);
     PageControlSekmeChange(Self);
  end;
end;

procedure TProjeListeDlg.GorTusClick(Sender: TObject);
begin
   if PageControlUst.ActivePage=TabSheetGrup then begin
      Tablo.ProjeSihirbazBaslat('D',  ProjeID, RehberId ,Tablo.GENINI.BugunTrh);
      //tekrar g?sterelim, bunun i?in silip ekleyelim
      FTileControl.DeleteItem(SecilenItem);
      Tablo.TablodanSorguAc(2,'select P.ID, ASAMA,REHBERID,	FIRMA= CASE WHEN LEN(LTRIM(RTRIM(FIRMA)))-LEN(REPLACE(LTRIM(RTRIM(FIRMA)),'' '',''''))<2 THEN FIRMA ELSE SUBSTRING(FIRMA, 0, CHARINDEX('' '', FIRMA, CHARINDEX('' '', FIRMA, 0)+1)) END,'+
       ' PROJEADI,KONUSU,TURU,BASLAMATARIHI,BITISTARIHI from PROJELER P '+
       ' inner join REHBER R on P.REHBERID=R.ID where P.ID='+IntToStr(ProjeID));
      GrubaElemanEkle(Tablo.Query2.Fields[0].AsInteger, Tablo.Query2.FieldByName('ASAMA').AsInteger, Tablo.Query2.FieldByName('REHBERID').AsInteger,
        Tablo.Query2.FieldByName('FIRMA').AsString, Tablo.Query2.FieldByName('PROJEADI').AsString, Tablo.Query2.FieldByName('KONUSU').AsString,
        Tablo.Query2.FieldByName('TURU').AsString, Tablo.Query2.FieldByName('BASLAMATARIHI').AsString, Tablo.Query2.FieldByName('BITISTARIHI').AsString);
   end else begin
       ProjeID := PROJELER.Fields[0].AsInteger;
       RehberId:= PROJELER.FieldByName('REHBERID').AsInteger;
       if Tablo.ProjeSihirbazBaslat('D',  ProjeID, RehberId, Tablo.GENINI.BugunTrh) > 0 then
          FArama.YenileTus.Click;
       Sleep(1000);
       PROJELER.Locate('ID', ProjeID, []);
       cxGridProjeler.DataController.SetFocus;
       //cxGridProjeler.DataController.GetFocusedRowIndex
   end;
end;

procedure TProjeListeDlg.Gorunmez;
begin

end;

procedure TProjeListeDlg.GorunmezOlacak;
begin

end;

procedure TProjeListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
  AramaYap;
end;

procedure TProjeListeDlg.GorunurOlacak;
begin

end;

procedure TProjeListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_projeler);
end;

procedure TProjeListeDlg.GrupA1Click(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0:cxGridProjeler.DataController.Groups.FullCollapse;
    1:cxGridProjeler.DataController.Groups.FullExpand;
  end;
end;

procedure TProjeListeDlg.IsiKopyalaMenuClick(Sender: TObject);
begin
  Tablo.GorevKopyala(TabGorevler.Fields[0].AsInteger, TabGorevler.FieldByName('KONUSU').AsString);
  PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.IsiSilMenuClick(Sender: TObject);
begin
   if Tablo.GorevSil(TabGorevler.Fields[0].AsInteger) then
      PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TProjeListeDlg.Kopyala1Click(Sender: TObject);
var EskiProjeID : integer;
begin
   EskiProjeID := PROJELER.Fields[0].AsInteger;
   ProjeID:= Tablo.SQLSatiriKopyala('PROJELER',PROJELER.Fields[0].AsInteger,['EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
           'INSERT INTO PROJEASAMA(PROJEID,REHBERID,TUR,ASAMA,ONAY,ACIKLAMA,EKLEYEN,BASTAR,BITTAR,AKTIF,DURUM,SUBEID) '
          +'select &ProjeID,REHBERID,TUR,ASAMA,ONAY,ACIKLAMA,&Ekleyen,BASTAR,BITTAR,AKTIF,DURUM,SUBEID '
          +'from PROJEASAMA where PROJEID=&EskiProjID ',
          ['&ProjeID','&Ekleyen','&EskiProjID'],
          [ProjeID,Kullanan,EskiProjeID]);

  if Tablo.ProjeSihirbazBaslat('K',ProjeID,PROJELER.FieldByName('REHBERID').AsInteger,Tablo.GENINI.BugunTrhSaat) > 0 then begin
     TabloYenile(PROJELER,[Kullanan]);
     ProjeID := ProjeID;
     RehberId:= PROJELER.FieldByName('REHBERID').AsInteger;
  end;
end;

procedure TProjeListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TProjeListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TProjeListeDlg.PROJELERAfterOpen(DataSet: TDataSet);
begin
   ProjeId := PROJELER.Fields[0].AsInteger;
end;

procedure TProjeListeDlg.PROJELERBeforeOpen(DataSet: TDataSet);
begin
  // Param degeri TabloYenile ile veriliyor.
end;

procedure TProjeListeDlg.ProjeListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TProjeListeDlg.SetArama(const Value: TProjeListeAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    dateProjeBaslangic.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    dateProjeBitis.Date := Date+60;
    checkTarih.Checked:=False;
//    YenileTus.Click;     //tarih check i?aretlenince yenileme yap?ld??? i?in kapat?ld?

    { Arama olay atamas? }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tan?mlamay? AnaForm'daki AramaFrame OlayBaglamalari tag'?nda ger?ekle?tirebilirsiniz.  }
    { Detayl? bilgi i?in AnaForm'daki ?rneklere bak?n?z. }
  end;
end;

procedure TProjeListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TProjeListeDlg.SilTusClick(Sender: TObject);
begin
   if Tablo.ProjeSilmeIslemleri(Projeler, Projeler.Fields[0].AsInteger) then begin
      FArama.YenileTus.Click;
      /// SQL2005 TE hataya neden oldu?u i?in delete olay?n? kendimiz yap?yoruz
      Abort;
   end;
end;

procedure TProjeListeDlg.qryPROJELERrrAfterOpen(DataSet: TDataSet);
begin
   GorTus.Visible   := PROJELER.RecordCount>0;
   SilTus.Visible :=  GorTus.Visible;
end;

procedure TProjeListeDlg.TamamlandiIsaretleMenuClick(Sender: TObject);
begin
//Ad   Menu_Tamam(Sender, GorevGridDBTableView1);
   PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.FTileControlItemClick(Sender: TdxTileControlItem);
begin
   SecilenItem := Sender;
   ProjeID:= StrToInt(copy(SecilenItem.Name,2,99));
   RehberId:= TdxTileControlItem(Sender).Tag;
   PROJELER.locate('ID', ProjeID, []);
   PageControlSekmeChange(Self);
end;

procedure TProjeListeDlg.FTileControlItemDragBegin(Sender: TdxCustomTileControl;
  AInfo: TdxTileControlDragItemInfo; var AAllow: Boolean);
begin
   SecilenItem := AInfo.item;
   ProjeID := StrToInt(copy(AInfo.item.Name,2,99));
   RehberId:= AInfo.item.tag;
end;

procedure TProjeListeDlg.FTileControlItemDragEnd(Sender: TdxCustomTileControl;AInfo: TdxTileControlDragItemInfo);
begin
   if AInfo.Group <> nil then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PROJELER set ASAMA='+IntToStr(AInfo.Group.Tag)+' where ID='+IntToStr(ProjeID),[],[]);
end;

procedure TProjeListeDlg.TreeListGorevClick(Sender: TObject);
var   TreeHitTest: TcxTreeListHitTest;
begin
     TreeHitTest := (Sender as TcxDBTreeList).HitTest;
     if not TreeHitTest.HitAtColumn  then // soldaki + alt seviye a?ma tu?una bast???nda a?ma/kapatma yapmas?n diye
        exit;


   if TcxDBTreeList(Sender).FocusedColumn.tag=1 then begin
      UpdateveMail(MasaUstu, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.Fields[0].AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, TcxDBTreeList(Sender).FocusedNode.HasChildren);
      PlayWavFromResource('Blink');
      PageControlSekmeChange(Self);
  end;
  Abort;//Bunu kesinlikle silme (listede tek sat?r kal?nca hata verdi?i i?in eklendi)
end;

procedure TProjeListeDlg.TreeListGorevDblClick(Sender: TObject);
begin
   DuzenleMenuClick(Self);
end;

procedure TProjeListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TProjeListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TProjeListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TProjeListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TProjeListeDlg.YeniTusClick(Sender: TObject);
begin
   if Tablo.ProjeSihirbazBaslat('E',-1,-99,Tablo.GENINI.BugunTrhSaat) > 0 then begin
      if PageControlUst.ActivePage=TabSheetGrup then
         PageControlUstChange(Self);
      FArama.YenileTus.Click;
   end;
end;

procedure TProjeListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Projeler);
end;

procedure TProjeListeDlg.YenileTusClick(Sender: TObject);
begin
  AramaYap;
end;

initialization
  RegisterClass(TProjeListeDlg);
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











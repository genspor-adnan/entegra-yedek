unit UGorevListeDlg;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 04/12/2010 11:54:17}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Utablo,
  System.JSON, Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxInplaceContainer,
  UGorevListeAramaFrame, dxSkinsCore,  dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridCustomTableView, cxDBTL,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxProgressBar, cxTLData, cxLabel,
  dxSkinLondonLiquidSky, cxLookAndFeels, cxNavigator, cxTL, cxTLdxBarBuiltInMenu,
  JvExControls, JvNavigationPane, cxCheckBox, OfficePopupMenu, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, dxCore, cxDateUtils, cxDropDownEdit,
  cxDBEdit, dxGDIPlusClasses, cxImage, JvTimer, cxCurrencyEdit, cxScheduler,
  cxSchedulerStorage, cxSchedulerCustomControls, cxSchedulerCustomResourceView,
  cxSchedulerDayView, cxSchedulerDateNavigator, cxSchedulerHolidays, frxClass,
  cxSchedulerTimeGridView, cxSchedulerUtils, cxSchedulerWeekView,
  cxSchedulerYearView, cxSchedulerGanttView, cxSchedulerTreeListBrowser, System.Generics.Collections,
  dxSkinscxSchedulerPainter, cxSchedulerDBStorage, Vcl.Samples.Spin, cxSplitter,
  cxCheckListBox, cxDBCheckListBox, cxSpinEdit, cxTimeEdit, cxPCdxBarPopupMenu,
  cxDBLabel, cxPC, dxBarBuiltInMenu, cxSchedulerRibbonStyleEventEditor,
  cxSchedulerRecurrence, dxSkinLiquidSky, cxGridCustomPopupMenu, cxGridPopupMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxCustomTileControl, dxTileControl,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, cxSchedulerAgendaView,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;//, cxSchedulerAgendaView;//, cxSchedulerRibbonStyleEventEditor,  cxSchedulerRecurrence;

type
  TGorevListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsGorevler: TDataSource;
    TabGorevler: TFDQuery;
    GorevlerMenu: TOfficePopupMenu;
    GorevInfoMenu: TMenuItem;
    DuzenleMenu: TMenuItem;
    TamamlandiIsaretleMenu: TMenuItem;
    Bayraklaretle1: TMenuItem;
    N1: TMenuItem;
    TarihBugunMenu: TMenuItem;
    arihYarn1: TMenuItem;
    TarihiKaldirMenu: TMenuItem;
    N2: TMenuItem;
    Atamayap1: TMenuItem;
    N3: TMenuItem;
    MteriSe1: TMenuItem;
    N4: TMenuItem;
    BuiIsiTasiMenu: TMenuItem;
    N5: TMenuItem;
    BuiiEPostaGnder1: TMenuItem;
    N6: TMenuItem;
    ButenYeniBirListeOlutur1: TMenuItem;
    IsiKopyalaMenu: TMenuItem;
    IsiSilMenu: TMenuItem;
    JvTimer1: TJvTimer;
    cxSplitterTakvim: TcxSplitter;
    PanelListe: TPanel;
    SQLKullan: TMemo;
    PanelYeniIs: TJvNavPanelHeader;
    PanelTakvim: TPanel;
    Scheduler: TcxScheduler;
    pnlControls: TPanel;
    Memo1: TMemo;
    GridPersonel: TcxGrid;
    GridPersonelView: TcxGridDBTableView;
    GridPersonelViewFIRMA: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    MemoServisSQL: TMemo;
    ToolBar1: TToolBar;
    ToolButton8: TToolButton;
    ToolButton2: TToolButton;
    HaftaTus: TToolButton;
    AylikTus: TToolButton;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    CheckSorumluGrupla: TcxCheckBox;
    edTakvimSayisi: TSpinEdit;
    MemoPlanSQL: TMemo;
    MemoGorevSQL: TMemo;
    SchedulerDBStorage: TcxSchedulerDBStorage;
    SchedulerDataSource: TDataSource;
    AraQuery1: TFDQuery;
    Query1: TFDQuery;
    DtsPersonel: TDataSource;
    TabPersonel: TFDQuery;
    tabTakvimKaynaklari: TFDQuery;
    dtsTakvimKaynaklari: TDataSource;
    GridPersonelViewSEC: TcxGridDBColumn;
    GridPersonelViewID: TcxGridDBColumn;
    BuTariheIsEkleMenu: TMenuItem;
    SQLGorevMemo: TMemo;
    UstIsiAcMenu: TMenuItem;
    AltIsiAcMenu: TMenuItem;
    N7: TMenuItem;
    cxSplitter2: TcxSplitter;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    MemoNOTLAR: TcxDBMemo;
    cxDBLabel1: TcxDBLabel;
    TabIcerik: TFDQuery;
    DtsIcerik: TDataSource;
    PanelYorum: TPanel;
    MasaUstuMenu: TMenuItem;
    N8: TMenuItem;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel10: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    cxGridDBCardViewYORUM: TcxGridDBCardViewRow;
    cxGridLevel1: TcxGridLevel;
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
    PageControlUst: TcxPageControl;
    TabSheetListe: TcxTabSheet;
    TabSheetGrup: TcxTabSheet;
    FTileControl: TdxTileControl;
    FTileControlActionBarItem1: TdxTileControlActionBarItem;
    FTileControlItem1: TdxTileControlItem;
    FTileControlItem2: TdxTileControlItem;
    FTileControlActionBarItem2: TdxTileControlActionBarItem;
    FTileControlItem3: TdxTileControlItem;
    FTileControlItem4: TdxTileControlItem;
    PanelPersonelSec: TPanel;
    ToolBar3: TToolBar;
    PersonelHepsiSec: TToolButton;
    PersonelHepsiBirak: TToolButton;
    Panel5: TPanel;
    ToolBar6: TToolBar;
    GorevEkleTus: TToolButton;
    GorevSilTus: TToolButton;
    ToolButton15: TToolButton;
    GorevDuzenleTus: TToolButton;
    JvNavPanelHeader1: TJvNavPanelHeader;
    YenileTus: TToolButton;
    CheckTamamlanan: TcxCheckBox;
    ComboTamamlanan: TcxImageComboBox;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    GridGorev: TcxGrid;
    GridGorevView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    GridGorevViewGOREV_ID: TcxGridDBColumn;
    GridGorevViewREH_ID: TcxGridDBColumn;
    GridGorevViewEKLEYEN: TcxGridDBColumn;
    GridGorevViewACKAPA: TcxGridDBColumn;
    GridGorevViewBAYRAK: TcxGridDBColumn;
    GridGorevViewLISTEID: TcxGridDBColumn;
    GridGorevViewTUR: TcxGridDBColumn;
    GridGorevViewCARIAD: TcxGridDBColumn;
    GridGorevViewEKLEMETARIHI: TcxGridDBColumn;
    GridGorevViewBITISTARIHI: TcxGridDBColumn;
    GridGorevViewPROJEKODU: TcxGridDBColumn;
    GridGorevViewEKLEYENAD: TcxGridDBColumn;
    GridGorevViewKONUSU: TcxGridDBColumn;
    GridGorevViewATANAN: TcxGridDBColumn;
    GridGorevViewDURUM: TcxGridDBColumn;
    GridGorevViewBASLAMATARIHI: TcxGridDBColumn;
    GridGorevViewNOTLAR_BIT: TcxGridDBColumn;
    GridGorevViewYORUM_BIT: TcxGridDBColumn;
    CheckZenginMetin: TcxCheckBox;
    procedure AramaYap;
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Gorev_Liste)
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
    procedure GorevInfoMenuClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure TreeListelerClick(Sender: TObject);
    procedure Bayraklaretle1Click(Sender: TObject);
    procedure DuzenleMenuClick(Sender: TObject);
    procedure TamamlandiIsaretleMenuClick(Sender: TObject);
    procedure Atamayap1Click(Sender: TObject);
    procedure MteriSe1Click(Sender: TObject);
    procedure TarihBugunMenuClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure IsiSilMenuClick(Sender: TObject);
    procedure IsiKopyalaMenuClick(Sender: TObject);
    procedure ButenYeniBirListeOlutur1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure AylikTusClick(Sender: TObject);
    procedure SchedulerDblClick(Sender: TObject);
    procedure GridPersonelViewSECPropertiesEditValueChanged(Sender: TObject);
    procedure SchedulerDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SchedulerDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure GorevGridDBTableView1DragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure GorevGridDBTableView1DragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure GorevlerMenuPopup(Sender: TObject);
    procedure BuiiEPostaGnder1Click(Sender: TObject);
    procedure Listele;
    procedure EkleDuzenleTusClick(Sender: TObject);
    procedure GorevGridDBTableView1CanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure UstIsiAcMenuClick(Sender: TObject);
    procedure AltIsiAcMenuClick(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure TreeListGorevDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeListGorevMoveTo(Sender: TcxCustomTreeList;
      AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode;
      Nodes: TList; var IsCopy, Done: Boolean);
    procedure TreeListGorevClick(Sender: TObject);
    procedure TreeListGorevDblClick(Sender: TObject);
    procedure TreeListGorevDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure PageControlUstChange(Sender: TObject);
    procedure FTileControlItemClick(Sender: TdxTileControlItem);
    procedure TabGorevlerAfterOpen(DataSet: TDataSet);
    procedure FTileControlItemDragBegin(Sender: TdxCustomTileControl;
      AInfo: TdxTileControlDragItemInfo; var AAllow: Boolean);
    procedure FTileControlItemDragEnd(Sender: TdxCustomTileControl;
      AInfo: TdxTileControlDragItemInfo);
    procedure PersonelHepsiSecClick(Sender: TObject);
    procedure PersonelHepsiBirakClick(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    procedure GorevEkleTusClick(Sender: TObject);
    procedure CheckTamamlananClick(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure GridGorevViewStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridGorevViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure GridGorevViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure GridGorevViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    SecilenItem : TdxTileControlItem;
    FArama      : TGorevListeAramaFrame;
    SecilmisPersonelSay:Integer;
    AKeys: Variant;
    SecilmisPersonelList: TStringList;
    // SAYFALI liste (merkezi TSayfaliListe, Utablo)
    FSayfali: TSayfaliListe;
    FSonMod: SmallInt;   // son Liste_SP_Cagir modu (sayfa buyutme ayni modla)
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
    procedure GorevListeDlgKapatEylemi(Sender: TObject);
    procedure SetArama(const Value: TGorevListeAramaFrame);
    procedure GorevArama;
    procedure TakvimdeGoster;
    procedure KaynaklariYukle;
    function GetDragSourceGridView (const aSource: TcxDragControlObject): TcxCustomGridView;
    function GetRealDragSourceGridView (const aSource: TcxDragControlObject): TcxCustomGridView;
    procedure GrubaElemanEkle(GorevId, Durum :Integer; Konusu, Firma, Turu, BitTarih:String);
    procedure PersonelSecim(Sec:Boolean);
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
  public
    { Public declarations }
     ADragnode: TcxTreeListNode;
     procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
     procedure InitIslemler(Sender:TObject);
  published
    property Arama : TGorevListeAramaFrame read FArama write SetArama;
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, PrjConst,LocOnFly, UGenNotificationUtils,
   UGorevDlg, FetaUtil, UIslistesi, UAnaForm, UAksiyonlarGorevFrame, UVeriMotor;

{$R *.dfm}
{ TGorevListeDlg }

//const
//  Masaustu = -27; Bugun=-24;  Onaylar =-21;  BanaAtananlar=-18;  Atadiklarim=-15; Atanmamislar=-12;  Bayrakli = -9; Servis=-6; Proje=-3;
var
 KaynakKomut : string;
 MenuGorevId : Integer;
 AlanlarOlusturuldu : Boolean;

function PgGorevEskiListeSQL(AKlasorID, AKullanici: Integer; const AAcKapa: string;
  AGunSay: Integer): string;
var
  LWhere: string;
begin
  LWhere := ' where 1=1 ';
  if AAcKapa = '0' then
    LWhere := LWhere + ' and coalesce(g.ackapa,0)=0 '
  else if AGunSay < 9999 then
    LWhere := LWhere + ' and (coalesce(g.ackapa,0)=0 or coalesce(g.bitistarihi,g.degistirmetarihi,g.eklemetarihi) >= current_date - interval ''' + IntToStr(AGunSay) + ' day'') ';

  case AKlasorID of
    Masaustu:
      LWhere := LWhere + ' and g.listeid=' + IntToStr(Masaustu) + ' and g.ekleyen=' + IntToStr(AKullanici);
    BanaAtananlar:
      LWhere := LWhere + ' and exists (select 1 from gorevkullanici gk where gk.listgorevid=g.id and gk.rehberid=' + IntToStr(AKullanici) + ')';
    Atanmamislar:
      LWhere := LWhere + ' and not exists (select 1 from gorevkullanici gk where gk.listgorevid=g.id)';
    Atadiklarim:
      LWhere := LWhere + ' and g.ekleyen=' + IntToStr(AKullanici);
    Bayrakli:
      LWhere := LWhere + ' and coalesce(g.bayrak,0)<>0';
    ToplantiKlasor, DemirbasKlasor, Servis:
      LWhere := LWhere + ' and g.listeid=' + IntToStr(AKlasorID);
  else
    if AKlasorID > 0 then
      LWhere := LWhere + ' and g.listeid=' + IntToStr(AKlasorID);
  end;

  Result :=
    'select distinct ' +
    'g.id, g.ackapa, g.listeid, g.id as gorev_id, g.konusu, ' +
    '(select anahtar from genini where bolum=-21044 and dil=-1 and deger=g.turu limit 1)::varchar as turu, ' +
    'g.ekleyen, g.rehberid, g.rehberid as reh_id, ' +
    '(select r.firma from rehber r where r.id=g.rehberid limit 1)::varchar as cariad, ' +
    '(select r.firma from rehber r where r.id=g.mus_ilgili limit 1)::varchar as mus_ilgili, ' +
    '(select case when count(*)=0 then '''' else string_agg(k.kod, '' - '' order by gk.id) || '' -'' end from gorevkullanici gk inner join kullanici k on k.rehberid=gk.rehberid where gk.listgorevid=g.id)::varchar as atanan1, ' +
    'g.baslamatarihi, g.bitistarihi, ' +
    '(case when coalesce(g.tekrarid,0)>0 then 1 else 0 end)::smallint as tekrar_bit, ' +
    '(case when coalesce(g.animsat,0)>0 then 1 else 0 end)::smallint as animsat_bit, ' +
    'g.bayrak, g.durum, g.eklemetarihi, ' +
    '(select p.projekodu from projeler p where p.id=g.projeid limit 1)::varchar as projekodu, ' +
    '(select r.firma from rehber r where r.id=g.ekleyen limit 1)::varchar as ekleyenad, ' +
    '(case when exists(select 1 from gorevyorum gy where gy.gorevid=g.id and gy.tur=1) then 1 else 0 end)::smallint as notlar_bit, ' +   // MSSQL: GOREVYORUM TUR=1 (not)
    '(case when exists(select 1 from gorevyorum gy where gy.gorevid=g.id and gy.tur=33) then 1 else 0 end)::smallint as yorum_bit, ' +  // MSSQL: GOREVYORUM TUR=33 (yorum)
    'g.bagidust, g.bagidalt ' +
    'from gorevler g left join gorevliste gl on gl.id=g.listeid ' +
    LWhere +
    ' order by g.ackapa, g.baslamatarihi, g.ekleyen desc';
end;

procedure TGorevListeDlg.InitIslemler(Sender:TObject);
var
  k : word;
  Item, SubItem : TMenuItem;
  i:integer;
  gf : TAksiyonlarGorevFrame;
begin
{  if cxSplitter1<>nil then begin
    if TJvNavPanelButton( Sender ).Tag = 0 then
       //PanelTakvim.visible := false
       //  PanelTakvim.Width := 800
       cxSplitter1.Left := 40
    else
       cxSplitter1.Left := 1000
  end;

  }

//       cxSplitter1.OpenSplitter
     //  PanelTakvim.Width := 20;

     //PanelListe.visible := false;
     //PanelTakvim.visible := false;


//  gf := TAksiyonlarGorevFrame(FFrameBilgi.AnaFrameBilgi.GorevFrameOrnek);
//  gf.FMenuTur := gf.MenuTur;

end;

procedure TGorevListeDlg.YazdirmayaHazirla(AFastReport : TfrxReport);
begin

end;

function TGorevListeDlg.EkranAdiAl : string;
begin

end;
procedure TGorevListeDlg.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TGorevListeDlg.TamamlandiIsaretleMenuClick(Sender: TObject);
begin
   PlayWavFromResource('Blink');
   Menu_Tamam(Sender, GridGorevView, Scheduler, FArama.TabListe.Fields[0].AsInteger);
   Listele;
end;

procedure TGorevListeDlg.TarihBugunMenuClick(Sender: TObject);
var I, ID, LISTEID:Integer;
begin
   {0101
   if TreeListGorev.SelectionCount> 0 then begin
      for I := 0 to TreeListGorev.SelectionCount-1 do begin
          ID :=TreeListGorev.Selections[I].Values[TreeListEkipmancxDBTreeListID.ItemIndex];
          LISTEID :=TreeListGorev.Selections[I].Values[TreeListGorevcxDBTreeListLISTEID.ItemIndex];
          if LISTEID = Servis then begin
               if TOfficePopupMenu(Sender).Tag = -1 then
                  ServisUpdate(ID, 'BASLAMATARIHI = null, BITISTARIHI= null')
               else
                  ServisUpdate(ID, 'BASLAMATARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrh + TOfficePopupMenu(Sender).Tag)+''''+
                     ',BITISTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrh + TOfficePopupMenu(Sender).Tag)+'''');
           end else begin
               if TOfficePopupMenu(Sender).Tag = -1 then
                  GorevUpdate(ID, 'BASLAMATARIHI = null, BITISTARIHI= null')
               else
                  GorevUpdate(ID, 'BASLAMATARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrh + TOfficePopupMenu(Sender).Tag)+''''+
                     ',BITISTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrh + TOfficePopupMenu(Sender).Tag)+'''');
           end;
      end;
   end;  }
   Listele;
end;

procedure TGorevListeDlg.Atamayap1Click(Sender: TObject);
var
  Kullanicilar:TstringList;
  i:integer;
begin
    Kullanicilar := TStringlist.Create;
    Kullanicilar := Tablo.ListedenCokluSecim('',SQLKullan.text,[nil,nil,nil,nil,nil,nil,nil],
                                               ['Id','Ad','Görev','Departman','Şube','Kategori','Tür']);
    if Kullanicilar.Count>0 then begin
       if TabGorevler.FieldByName('LISTEID').AsInteger=Servis then
          ServisUpdate(MenuGorevId, 'SORUMLU='+copy(Kullanicilar[i],2,8))
       else begin // Görev
         for I := 0 to Kullanicilar.Count - 1 do
           if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT '+DbUst(1)+'* FROM GOREVKULLANICI where LISTGOREVID='+IntToStr(MenuGorevId)+' and TUR=11 and REHBERID='+copy(Kullanicilar[i],2,8)+' '+DbSinir(1),[],[]) then begin
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                   ' values('+IntToStr(MenuGorevId)+',11,'+copy(Kullanicilar[i],2,8)+','+Kullanan+')', [],[]);
             if (AktifMail>0)and(TabGorevler.Fieldbyname('EKLEYEN').Asstring <> copy(Kullanicilar[i],2,8)) then
                TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA',copy(Kullanicilar[i],2,8))+','+ Tablo.MailAdresiBul(1,StrToInt(copy(Kullanicilar[i],2,8))), epostaalicilar);
             if (AktifMail>0)and(epostaalicilar.Count > 0) then
                Gorev_EPostaGonder(1,TabGorevler.FieldByName('ID').AsInteger);
         end;
         Listele;
       end;
    end;
    Kullanicilar.Free;
end;

procedure TGorevListeDlg.AylikTusClick(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0: begin
         Scheduler.GoToDate(Scheduler.SelStart, vmDay);
         Scheduler.ViewDay.Active := True;
       end;
    1: Scheduler.SelectWorkDays(Date);
    2: Scheduler.ViewWeek.Active := True;
    3: Scheduler.GoToDate(Scheduler.SelectedDays[0], vmMonth);
    4: Scheduler.ViewTimeGrid.Active := True;
    5: Scheduler.ViewYear.Active := True;
    6: Scheduler.ViewGantt.Active:= True;
    7: Scheduler.GoToDate(Scheduler.SelStart, vmWorkWeek);
    8: Scheduler.ViewYear.Active:=True;
  end;
end;

procedure TGorevListeDlg.MenuItem1Click(Sender: TObject);
var I, ID:Integer;
begin
   {0101
   if TreeListGorev.SelectionCount> 0 then begin
      for I := 0 to TreeListGorev.SelectionCount-1 do begin
          ID :=TreeListGorev.Selections[I].Values[TreeListEkipmancxDBTreeListID.ItemIndex];
          GorevUpdate(ID, 'LISTEID='+IntToStr( TMenuItem(Sender).Tag ));//  TabGorevler.Fields[0].AsInteger
      end;
      Listele;
   end;}
end;

procedure TGorevListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TGorevListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TGorevListeDlg.Baslatildi;
  procedure TakvimAyar;
  begin
    edTakvimSayisi.Value:=3;
    Scheduler.OptionsView.GroupingKind:= gkNone;
    KaynakKomut:=  '                                     '+
           '   DECLARE @TARIH SMALLDATETIME,     '+
           '       @SAHIPREHBERID INT,           '+
           '       @YETKIALANI INT               '+
           '   SET @SAHIPREHBERID = '+Kullanan+'     '+
//           '   SET @YETKIALANI = 1                   '+
           '   SELECT Reh.ID REHBERID, Reh.FIRMA PERSONEL                   '+
           '         FROM KULLANICI Kul                 '+
           '                   Inner Join REHBER Reh on Reh.ID = Kul.REHBERID ';
//    if PersonelYetkiKontrol then
//            KaynakKomut:= KaynakKomut+ ' Inner Join YETKIALANI Alan ON Alan.REHBERID = Kul.REHBERID ';


//    if PersonelYetkiKontrol then
//            KaynakKomut:= KaynakKomut+ '    AND Alan.SAHIPREHBERID = @SAHIPREHBERID    '+
//                         '     AND Alan.ALANTURU = @YETKIALANI           ';

            KaynakKomut:= KaynakKomut+ ' ORDER BY PERSONEL	' ;
  end;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
//0101  Tablo.GridAyarRestore('TreeListGorev',nil,TreeListGorev);

  // Tum/Son/Sik Aranan label'larini list frame handler'larina bagla (SP listeleme)
  if Assigned(FArama) then begin
    FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
    FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
    FArama.LabelSikArananlar.OnClick := LabelSikArananlarClick;
  end;

  // SAYFALI liste: merkezi yardimci; sayfa boyu GENEL OPSIYON (Liste sayfa uzunlugu).
  if FSayfali = nil then
    FSayfali := TSayfaliListe.Baglan(Self, TabGorevler, GridGorevView, nil,
      procedure
      begin
        Liste_SP_Cagir(FSonMod);
      end);

  PanelTakvim.Visible := Tablo.YetkiVarmi(2132,YetkiTur_Gorme);
  cxSplitterTakvim.Visible := PanelTakvim.Visible;

  AlanlarOlusturuldu := False;
  PageControlUst.ActivePageIndex := 0;
  EPostaAlicilar := TList<TEpostaAlici>.Create;
  EPostaAlicilarCC := TList<TEpostaAlici>.Create;
  //PanelListe.Width := 600;
  AktifMail:=Tablo.GENINI.ReadInteger(Ops_OpsiyonAktivite_BilgilendirmeMail,-1);
//s  ComboIsTuru.EditValue := -1;
   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  if PanelTakvim.Visible then begin
     TakvimAyar;
     TabloYenile(TabPersonel, []);
  end;
  // Tablo.TablodanSorguAc(5,'SELECT GL.ID, GL.ADI FROM GOREVLISTE GL '+
  //  'inner join GOREVKULLANICI GK on GL.ID=GK.LISTGOREVID AND GK.TUR<=2 WHERE GL.DURUM=1 AND GK.REHBERID='+Kullanan+' order by ID ');
   FArama.TabListe.First;
   while not FArama.TabListe.eof do begin
     if FArama.TabListe.Fields[0].AsInteger>0 then
        PopUpSubMenuIslemleri(BuiIsiTasiMenu, MenuItem1Click, 'Ekle', FArama.TabListe.FieldByName('ADI').AsString,'', FArama.TabListe.Fields[0].AsInteger);
     FArama.TabListe.next;
   end;
   HaftaTus.Click;
   FArama.TabListe.Locate('ID', MasaUstu, []);
   ComboTamamlanan.ItemIndex := 0;

//0101  Tablo.GridAyarRestore('TreeListGorev',nil,TreeListGorev );
  VarsayDurumYeni := Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_Yeni,1);//
  VarsayDurumSonOnay := Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_SonOnay,-1);//
  VarsayDurumSonRed := Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_SonRed,-1);//
  VarsayDurumSon :=    Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_Son,-1);//
  //VarsayDurumServisSonOnay := Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_Varsayilan_Durum_SonOnay,-1);//
   Listele;
end;

procedure TGorevListeDlg.Bayraklaretle1Click(Sender: TObject);
begin
//0101   Menu_Bayrak(Sender, TreeListGorev, Scheduler);
   Listele;
end;

procedure TGorevListeDlg.BtnMesajGonderClick(Sender: TObject);
var TabNo:Integer;
begin
   if TabGorevler.FieldByName('LISTEID').AsInteger=Servis then
      TabNo := Tabno_Servis
   else
      TabNo := Tabno_Gorevler;
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  Tabno, TabGorevler.FieldByName('ID').AsInteger, AktifRehberId, TabYorum, CheckZenginMetin.Checked);

  if Gorev_EPostaGonder(3,TabGorevler.FieldByName('ID').AsInteger, False) = True then
     ShowMessage(EPostaGonderildi);
end;

procedure TGorevListeDlg.BuiiEPostaGnder1Click(Sender: TObject);
begin
  if Gorev_EPostaGonder(1,TabGorevler.FieldByName('ID').AsInteger, False) = True then
     ShowMessage(EPostaGonderildi);
end;

procedure TGorevListeDlg.ButenYeniBirListeOlutur1Click(Sender: TObject);
var ListeId : Integer;
begin
   ListeId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVLISTE]([USTID],[ADI],RESIM,[DURUM],[EKLEYEN])'+
         ' values(0,''Yeni Liste'',0,1,'+Kullanan+') select SCOPE_IDENTITY() ',[],[], True);

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
         ' values('+IntToStr(ListeId)+',1,'+Kullanan+','+Kullanan+')', [], []);

   GorevUpdate(MenuGorevId, 'LISTEID='+IntToStr(ListeId));
   TabloYenile(FArama.TabListe,[StrToInt(Kullanan)]);
   FArama.TabListe.Locate('ID', ListeId, []);
end;

procedure TGorevListeDlg.CheckTamamlananClick(Sender: TObject);
begin
   ComboTamamlanan.Visible := not ComboTamamlanan.Visible;
   if FArama.PageListeler.ActivePageIndex = 2 then //arama ise
      GorevArama
   else
      Listele;
end;

procedure TGorevListeDlg.cxPageControl1Change(Sender: TObject);
var TabNo:integer;
begin
   TabloYenile(TabIcerik, [AktifGorevId]);

   //servis mi görev mi ona göre yorum açalım
   if TabGorevler.FieldByName('LISTEID').AsInteger = Servis then
      TabNo := Tabno_Servis
   else
      TabNo := Tabno_Gorevler;
   TabloYenile(TabYorum, [Tabno, AktifGorevId]);

   MemoNOTLAR.visible := TabIcerik.FieldByName('NOTLAR').AsString<>'';
end;

procedure TGorevListeDlg.EkleDuzenleTusClick(Sender: TObject);
var Key: Word;
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin
//s   if Trim(YeniGorevEdit.Text)<>'' then begin
      Key := 13;

      if FArama.PageListeler.ActivePageIndex=1 then
//s         GorevId := YeniGorevEkle(TabGorevler, Tablo.GENINI.ReadInteger(Ops_OpsiyonIs_VarsayilanKlasor, Masaustu), FArama.TabListe.Fields[0].asInteger, YeniGorevEdit, Key, DateEdit1, TimeEdit1, CheckBAYRAK,
//s                    FArama.TabListe.FieldByName('REHBERID').asInteger,-1,ComboIsTuru.EditValue)//proje
//s      else
//s         GorevId := YeniGorevEkle(TabGorevler, FArama.TabListe.Fields[0].asInteger,0, YeniGorevEdit, Key, DateEdit1, TimeEdit1, CheckBAYRAK,0,0,ComboIsTuru.EditValue);
//s      ComboIsTuru.EditValue := -1;
      if FArama.TabListe.Fields[0].asInteger = Servis then
         Tablo.ServisSihirbazBaslat(False, 'D', 0, GorevId, AktifRehberId)
      else
         Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', GorevId, AtamaYapildi, YorumYapildi);
      if AtamaYapildi then
         Gorev_EPostaGonder(1, GorevId)
      else if YorumYapildi then
         Gorev_EPostaGonder(3, GorevId);
      Listele;
//s   end;
end;

procedure TGorevListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TGorevListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_GOREVLER,TabGorevler.FieldByName('ID').AsInteger]);
  end;
end;

procedure TGorevListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
            TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabGorevler.FieldByName('ID').AsInteger)
end;

procedure TGorevListeDlg.DuzenleMenuClick(Sender: TObject);
VAR
  GorevDlg1: TGorevDlg;
  ID:integer;
begin
  ID := TabGorevler.FieldByName('ID').AsInteger;
  Tablo.AramaKaydet(MODUL_Gorev, ID);   // Son/Sik Aranan takibi (kart acilinca upsert)
  if PageControlUst.ActivePage=TabSheetGrup then begin
    //Tablo.ServisSihirbazBaslat(False, 'D',0, AktifGorevId, AktifRehberId);
    Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', AktifGorevId,AtamaYapildi, YorumYapildi);
    //tekrar gösterelim, bunun için silip ekleyelim
    FTileControl.DeleteItem(SecilenItem);
    Tablo.TablodanSorguAc(2,'select G.ID, G.DURUM, KONUSU, FIRMA, TURU=(select ANAHTAR from GENINI where BOLUM = '+IntToStr(Ops_Gorev_Turu)+' and DEGER=G.TURU), G.BITISTARIHI from GOREVLER G '+
     ' inner join REHBER R on G.REHBERID=R.ID where G.ID='+IntToStr(AktifGorevId));
    GrubaElemanEkle(Tablo.Query2.Fields[0].AsInteger, Tablo.Query2.FieldByName('DURUM').AsInteger,
            Tablo.Query2.FieldByName('KONUSU').AsString, Tablo.Query2.FieldByName('FIRMA').AsString,
            Tablo.Query2.FieldByName('TURU').AsString,Tablo.Query2.FieldByName('BITISTARIHI').AsString);
  end else begin
    Menu_Duzenle(Sender, TabGorevler, Scheduler);
    if FArama.PageListeler.ActivePageIndex = 2 then //arama ise
       GorevArama
    else
       Listele;
  end;
  TabGorevler.Locate('ID', ID, []);
//  if YorumYapildi then
//     Gorev_EPostaGonder(3, ID, False);
end;

procedure TGorevListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TGorevListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TGorevListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TGorevListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TGorevListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TGorevListeDlg.Gorunmez;
begin

end;

procedure TGorevListeDlg.GorunmezOlacak;
begin

end;

procedure TGorevListeDlg.Gorunur;
begin
  
end;

procedure TGorevListeDlg.GorunurOlacak;
begin

end;

procedure TGorevListeDlg.KaynaklariYukle;
var
 i,say : Integer;
 APCheckStates:^TcxCheckStates;
begin
     i:=0;
     say:=0;

     if SecilmisPersonelSay=0 then
      begin

         tabTakvimKaynaklari.Close;
         tabTakvimKaynaklari.SQL.Text:= KaynakKomut;
         tabTakvimKaynaklari.Open;
         tabTakvimKaynaklari.First;

        while SchedulerDBStorage.Resources.Items.Count>0 do
         SchedulerDBStorage.Resources.Items.Delete(0);

        while not tabTakvimKaynaklari.Eof do
         begin
            SchedulerDBStorage.Resources.Items.Add;
            SchedulerDBStorage.Resources.Items[tabTakvimKaynaklari.RecNo-1].Name:= tabTakvimKaynaklari.FieldByName('PERSONEL').AsString;
            SchedulerDBStorage.Resources.Items[tabTakvimKaynaklari.RecNo-1].ResourceID:=tabTakvimKaynaklari.FieldByName('REHBERID').AsInteger;
            tabTakvimKaynaklari.Next;
         end;
      end
     else
      begin
        // eğer seçili sorumlu varsa takvim kaynakları seçilenlerden dolsun
        while SchedulerDBStorage.Resources.Items.Count>0 do
         SchedulerDBStorage.Resources.Items.Delete(0);

         New(APCheckStates);
         try
          //with FArama.editSorumlu do
          //  begin
          //   CalculateCheckStates(Value, Properties.Items,Properties.EditValueFormat , APCheckStates^);
             for i := 0 to GridPersonelView.DataController.RecordCount - 1 do begin
                if GridPersonelView.DataController.GetValue(i, 0) = True then begin
         //     for i := 0 to Properties.Items.Count - 1 do
         //       if APCheckStates^[I] = cbsChecked then begin
                   SchedulerDBStorage.Resources.Items.Add;
//                   SchedulerDBStorage.Resources.Items[say].Name:=  Properties.Items[i].Description ;
//                   SchedulerDBStorage.Resources.Items[say].ResourceID:= StrToInt(Properties.Items[i].ShortDescription);
                   SchedulerDBStorage.Resources.Items[say].Name:=  GridPersonelView.DataController.GetValue(i,GridPersonelViewFIRMA.Index);// GridPersonelView.Controller.SelectedRecords[i].Values[GridPersonelViewFIRMA.Index];
                   SchedulerDBStorage.Resources.Items[say].ResourceID:= GridPersonelView.DataController.GetValue(i,GridPersonelViewID.Index); // GridPersonelView.Controller.SelectedRecords[i].Values[GridPersonelViewID.Index];
                   say:=say+1;
                 end;

            end;
         finally
          Dispose(APCheckStates);
         end;
      end;
end;

procedure TGorevListeDlg.GridGorevViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridGorev;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridGorevView;
  AnaForm.pmGridStil.Tags.Values[GridGorev.Name] := 'IsListesiGridi';
end;

procedure TGorevListeDlg.GridGorevViewStylesGetContentStyle(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  // Durum-renk kurallari tarihsel olarak 'GorevGridView' (ana sayfa gorev grid'i) adiyla
  // tanimli (UOpsDlg > Stiller). Liste grid'i (GridGorevView) AYNI kurallari kullansin
  // diye Sender.Name yerine o adla denetlenir -> tek kural seti iki ekranda da isler.
  Tablo.GridStilYonetim.StilDenetle('GorevGridView', AStyle, Sender, ARecord);
end;

procedure TGorevListeDlg.GridGorevViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   DuzenleMenuClick(Self);
end;

procedure TGorevListeDlg.GridGorevViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   TabGorevlerAfterOpen(TabGorevler);
   cxPageControl1Change(Self);
end;

procedure TGorevListeDlg.GridPersonelViewSECPropertiesEditValueChanged(Sender: TObject);
begin
   if VarToStr(GridPersonelViewSEC.EditValue)='True' then
      SecilmisPersonelList.Add(GridPersonelViewID.EditValue)
      //Inc(SecilmisPersonelSay)
   else
      SecilmisPersonelList.Delete(SecilmisPersonelList.indexof(GridPersonelViewID.EditValue));
      //Dec(SecilmisPersonelSay);
//   KaynaklariYukle;
   Listele;
end;

procedure TGorevListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabNo_GOREVLER);
end;

procedure TGorevListeDlg.IsiKopyalaMenuClick(Sender: TObject);
begin
  Tablo.GorevKopyala(MenuGorevId, TabGorevler.FieldByName('KONUSU').AsString);
  Listele;
end;

procedure TGorevListeDlg.IsiSilMenuClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) = ID_OK then begin
     if TabGorevler.FieldByName('LISTEID').AsInteger=Servis then
        Tablo.ServisSil(MenuGorevId)
     else
        Tablo.GorevSil(TabGorevler.FieldByName('ID').AsInteger);
     Listele;
  end;
end;


procedure TGorevListeDlg.AltIsiAcMenuClick(Sender: TObject);
var GorevDlg1 : TGorevDlg;
begin
   Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',TabGorevler.FieldByName('BAGIDALT').AsInteger,AtamaYapildi, YorumYapildi);
end;

procedure TGorevListeDlg.AramaYap;
Begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
End;

procedure TGorevListeDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  GorevArama;
end;

procedure TGorevListeDlg.GorevInfoMenuClick(Sender: TObject);
begin
  if not TabGorevler.IsEmpty then
    Tablo.InfoGoster('GOREVLER', TabGorevler.FieldByName('ID').AsInteger, 33);
end;

procedure TGorevListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TGorevListeDlg.MteriSe1Click(Sender: TObject);
var ID: Integer;
begin
    ID := Tablo.RehberAra_IDGetir(-99);
    if ID > 0 then begin
        if TabGorevler.FieldByName('LISTEID').AsInteger=Servis then
           ServisUpdate(MenuGorevId,' REHBERID='+IntToStr(ID)+',MUS_ILGILI= 0')
       else
           GorevUpdate(MenuGorevId, ' REHBERID='+IntToStr(ID)+',MUS_ILGILI= 0,MUS_ILGILI2= 0');
       Listele;
    end;
end;

procedure TGorevListeDlg.FTileControlItemClick(Sender: TdxTileControlItem);
begin
   SecilenItem := Sender;
   AktifGorevId  := StrToInt(copy(TdxTileControlItem(Sender).Name,2,99));
   AktifRehberId := TdxTileControlItem(Sender).Tag;
   TabGorevler.locate('ID', AktifGorevId, []);
   cxPageControl1Change(Self);
end;

procedure TGorevListeDlg.FTileControlItemDragBegin(Sender: TdxCustomTileControl; AInfo: TdxTileControlDragItemInfo; var AAllow: Boolean);
begin
   SecilenItem := AInfo.item;
   AktifGorevId := StrToInt(copy(AInfo.item.Name,2,99));
   AktifRehberId:= AInfo.item.tag;
end;

procedure TGorevListeDlg.FTileControlItemDragEnd(Sender: TdxCustomTileControl; AInfo: TdxTileControlDragItemInfo);
begin
   if AInfo.Group <> nil then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update GOREVLER set DURUM='+IntToStr(AInfo.Group.Tag)+' where ID='+IntToStr(AktifGorevId),[],[]);
end;

procedure TGorevListeDlg.GrubaElemanEkle(GorevId, Durum :Integer; Konusu, Firma, Turu, BitTarih:String);
var AItem: TdxTileControlItem;
    //I:Smallint;
    Item1 : TcxImageComboBoxItem;
    s:String;
begin
    AItem := FTileControl.Items.Add;
    with AItem do begin
      Item1 := Tablo.RepGorevDurum.Properties.FindItemByValue(Durum);
      //i := Tablo.RepGorevDurum.Properties.FindItemByValue(Durum).Index;
      if Item1<>nil then
         //i:=Item1.Index;
         //if i>=0 then
         GroupIndex := Item1.Index;
      IsLarge := True;
      RowCount := 1;
      AItem.Name := 'A'+IntToStr(GorevId);
      AItem.Tag := AktifRehberId;

      if Firma<>'' then begin
          if length(Trim(Firma))-length(StringReplace(Trim(Firma),' ','',[rfReplaceAll]))<2 then
             s := Firma
          else
             s := copy(Firma, 1, pos(' ',Firma, pos(' ', Firma,1)+1)-1);
         s:=s+#13+Konusu;
     end
     else
        s:=Konusu;

      AItem.Text1.Value := s;
      AItem.Text1.WordWrap := True;
      AItem.Text3.Value := Turu;
      AItem.Text4.Value := BitTarih;
      OnClick := FTileControlItemClick;
    end;
end;

procedure TGorevListeDlg.PageControlUstChange(Sender: TObject);
    procedure Grupla;
    var AGroup:tdxtilecontrolgroup;
        AItem: TdxTileControlItem;
        I:Smallint;
    begin
        while FTileControl.Items.Count>0 do
          FTileControl.DeleteItem(FTileControl.Items[0]);
        while FTileControl.Groups.Count>0 do
          FTileControl.Groups.Clear;
        //önce çerçeveler
        for I := 0 to Tablo.RepGorevDurum.Properties.Items.Count-1 do begin
          AGroup := FTileControl.Groups.Add;
          AGroup.Caption.Text:=Tablo.RepGorevDurum.Properties.Items[i].Description;
          //AGroup.Index :=1;
          AGroup.Tag := Tablo.RepGorevDurum.Properties.Items[i].Value;
          //her bir çerçeve içine görünmeyen bir madde ekleyelim ki boşaldığında grup kaybolmasın
          AItem := FTileControl.Items.Add;
          AItem.Group := AGroup;
          AItem.Visible := False;
        end;
        //içini doldur
        TabGorevler.First;
        while not TabGorevler.Eof do begin
           GrubaElemanEkle(TabGorevler.FieldByName('ID').AsInteger, TabGorevler.FieldByName('DURUM').AsInteger,
              TabGorevler.FieldByName('KONUSU').AsString, TabGorevler.FieldByName('CARIAD').AsString,
              TabGorevler.FieldByName('TURU').AsString,TabGorevler.FieldByName('BITISTARIHI').AsString);
           TabGorevler.next;
        end;
    end;

    procedure ListeYenile;
    var LisId:Integer;
    begin
       if not FArama.TabListe.active then
          exit;
       LisId:=FArama.TabListe.Fields[0].AsInteger;
       TabloYenile(FArama.TabListe,[StrToInt(Kullanan)]);
       FArama.TabListe.Locate('ID',LisId,[]);
       Listele;
    end;
begin
    if (not TabGorevler.Active) or (TabGorevler.recordcount<1) then exit;

    if PageControlUst.ActivePage=TabSheetGrup then
       Grupla
    else
       ListeYenile;
end;

procedure TGorevListeDlg.PersonelSecim(Sec:Boolean);
var i : integer;
begin
   GridPersonelView.DataController.DataSet.DisableControls;
   SecilmisPersonelList.Clear;
   GridPersonelView.Controller.SelectAll;
    if GridPersonelView.DataController.Controller.SelectedRecordCount > 0 then
       for I := 0 to GridPersonelView.DataController.Controller.SelectedRecordCount-1 do begin
          GridPersonelView.DataController.Controller.SelectedRecords[I].Values[GridPersonelViewSEC.Index] := Sec;
          if Sec then
             SecilmisPersonelList.Add(GridPersonelView.DataController.Controller.SelectedRecords[I].Values[GridPersonelViewID.Index]);
       end;
   GridPersonelView.Controller.ClearSelection;
   GridPersonelView.DataController.DataSet.EnableControls;
   Listele;
end;

procedure TGorevListeDlg.PersonelHepsiSecClick(Sender: TObject);
begin
   PersonelSecim(True);
end;

procedure TGorevListeDlg.PersonelHepsiBirakClick(Sender: TObject);
begin
   PersonelSecim(False);
end;

procedure TGorevListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TGorevListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_GOREVLER,TabGorevler.FieldByName('ID').AsInteger, TabYorum);
end;

{
procedure TGorevListeDlg.GorevListeDlgEkranAc(Yeni: Boolean);
begin
  with FFrameBilgi.IcerikGit(TGorevListeDlg).Git do begin
   with TGorevListeDlg(Ornek) do begin
     KapatEylemi := GorevListeDlgKapatEylemi;
     GorevListeDlgEkranInit(IIf(Yeni, -1, IIf(Self.TabGorevler.RecordCount = 0, -1, Self.TabGorevler.AsInteger['ID'])));
     if Yeni then
       TabGorevler.Append;
   end;
 end;
end; }

procedure TGorevListeDlg.GorevGridDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;  var AAllow: Boolean);
begin
{//adn  AnaForm.cxGridPopupMenu1.Grid := GorevGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:= TreeListGorev;
  if FArama.TabListe.Fields[0].asInteger=TumListe then
     AnaForm.pmGridStil.Tags.Values[GorevGrid.Name]:='IsListesiGridi_Tum'
   else
     AnaForm.pmGridStil.Tags.Values[GorevGrid.Name]:='IsListesiGridi_Diger';   }
end;

procedure TGorevListeDlg.GorevListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TGorevListeDlg.SchedulerDblClick(Sender: TObject);
var GOREV_ID: String[15];
    selectedEvent : TcxSchedulerControlEvent;
begin
   if Scheduler.CurrentView.HitTest.Event <> nil then
      DuzenleMenuClick( Scheduler )
   {begin
     if Scheduler.SelectedEventCount = 0 then Exit;
     selectedEvent := Scheduler.SelectedEvents[0];
     GOREV_ID := selectedEvent.GetCustomFieldValueByName('GOREV_ID');
     if Tablo.GorevSihirbazBaslat('D','',0, StrToIntDef(GOREV_ID,-1),0,0, 0,AtamaYapildi, YorumYapildi) > 0 then begin
        if AtamaYapildi then
           Gorev_EPostaGonder(1, StrToIntDef(GOREV_ID,-1));
        TakvimdeGoster;
     end
   end }
   else
     BuTariheIsEkleMenu.Click;
end;

function TGorevListeDlg.GetRealDragSourceGridView(const aSource: TcxDragControlObject): TcxCustomGridView;
begin
  result := nil;
  if (TcxDragControlObject (aSource).Control is TcxGridSite) then begin
    result := TcxGridSite (TcxDragControlObject (aSource).Control).GridView;
  end;
end;

function TGorevListeDlg.GetDragSourceGridView(
  const aSource: TcxDragControlObject): TcxCustomGridView;
begin
  result := GetRealDragSourceGridView (aSource);
  if result.IsDetail then
    result := result.PatternGridView;
end;

procedure TGorevListeDlg.SchedulerDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  selectedEvent : TcxSchedulerControlEvent;
  aGridView, aRealGridView: TcxCustomGridView;
  newRecord,DragID, DropID, Ekleyen: integer;
  Trh : TDateTime;
  //ANode: TcxTreeListNode;
begin
  if TcxDragControlObject(Source).Control = Scheduler then begin
     selectedEvent := Scheduler.SelectedEvents[0];
     Ekleyen := selectedEvent.GetCustomFieldValueByName('EKLEYEN');
     if Ekleyen <> StrToInt(Kullanan) then
        Abort;

     DragID := selectedEvent.GetCustomFieldValueByName('GOREV_ID');
     trh := Scheduler.CurrentView.HitTest.Time;
     if selectedEvent.GetCustomFieldValueByName('LISTEID')=Servis then
        ServisUpdate(DragID, 'BASLAMATARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+''''+
         ',BITISTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+'''')
     else
        GorevUpdate(DragID, 'BASLAMATARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+''''+
         ',BITISTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+'''');
  end
  else begin
      if aGridView = GridPersonelView then begin
         aRealGridView := GetRealDragSourceGridView (TcxDragControlObject (Source));
         aGridView := GetDragSourceGridView (TcxDragControlObject (Source));
         DragID:= aRealGridView.DataController.Values[aRealGridView.DataController.FocusedRecordIndex, GridPersonelViewID.Index];
         if Scheduler.CurrentView.HitTest.HitAtEvent then begin
            DropID := Scheduler.CurrentView.HitTest.Event.GetCustomFieldValueByName('GOREV_ID');//Görev
            if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT '+DbUst(1)+'* FROM GOREVKULLANICI where LISTGOREVID='+IntToStr(DropID)+' and TUR=11 and REHBERID='+IntToStr(DragID)+' '+DbSinir(1),[],[]) then begin
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                   ' values('+IntToStr(DropID)+',11,'+IntToStr(DragID)+','+Kullanan+')', [],[]);
               if (AktifMail>0) then begin
                   TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA', DragID)+','+ Tablo.MailAdresiBul(1, DragID), epostaalicilar);
                   Gorev_EPostaGonder(1,DropID);
               end;
            end;
         end;

      end
      else begin
//adn         DragID:= aRealGridView.DataController.Values[aRealGridView.DataController.FocusedRecordIndex, GorevGridDBTableView1ID.Index];


        if ADragnode <> nil then
           dragId := ADragnode.Values[0]
        else
           Abort;


         trh := Scheduler.CurrentView.HitTest.Time;
         {if FArama.CheckTemas.Checked then begin//temas zamanı gelenler
            Tablo.GorevOlustur('Ziyaret', MasaUstu,0,0, 0,AktifRehberId, 0,0,0,0,0, trh,trh);
            TakvimdeGoster;
         end else}
         if Scheduler.CurrentView.HitTest.HitAtTime then begin
            if TabGorevler.FieldByName('LISTEID').AsInteger = Servis then
               ServisUpdate(TabGorevler.FieldByName('ID').AsInteger, 'BASLAMATARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+''''+
                 ',BITISTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+'''')
            else
               GorevUpdate(TabGorevler.FieldByName('ID').AsInteger, 'BASLAMATARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+''''+
                 ',BITISTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+'''');
          end;
      end;
  end;
  Listele;


//  Trh := Scheduler.SelStart;

  //akttarih:= Scheduler.SelFinish;


{  with tvTarget.DataController do begin
    newRecord := AppendRecord;
    values [newRecord, tvTargetSourceView.Index] := aGridView.Name;
    if aGridView = dbtvCustomers then
       values [newRecord, tvTargetID.Index] :=
       aRealGridView.DataController.Values[aRealGridView.DataController.FocusedRecordIndex, dbtvCustomersCustNo.Index]
    else
       values [newRecord, tvTargetID.Index] :=
       aRealGridView.DataController.Values[aRealGridView.DataController.FocusedRecordIndex, dbtvOrdersOrderNo.Index];
  end;}
end;

procedure TGorevListeDlg.SchedulerDragOver(Sender, Source: TObject; X,  Y: Integer; State: TDragState; var Accept: Boolean);
var
  aGridView: TcxCustomGridView;
begin
  if TcxDragControlObject(Source).Control = Scheduler then
     Accept := True
  else begin
//adn     aGridView := GetDragSourceGridView (TcxDragControlObject (Source));
//adn     Accept := (aGridView = TreeListGorev)or(aGridView = GridPersonelView);
     Accept := True
  end;
end;

procedure TGorevListeDlg.SetArama( const Value: TGorevListeAramaFrame);
begin
  FArama := Value;
  with FArama do begin
    //DateEdit1.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    //cxDateEdit2.Date := Date+60;
    YenileTus.Click;

    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TGorevListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TGorevListeDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],
         [61, TabGorevler.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from AKTIVITELER where Id=&id ',['&id'],[TabGorevler.FieldByName('ID').AsInteger]);
      YenileTus.Click;
      Abort;
   end;
end;

procedure TGorevListeDlg.TreeListGorevClick(Sender: TObject);
var   TreeHitTest: TcxTreeListHitTest;
      //FN : TcxTreeListNode;
      ID : Integer;
begin
     TreeHitTest := (Sender as TcxDBTreeList).HitTest;
     if not TreeHitTest.HitAtColumn  then // soldaki + alt seviye açma tuşuna bastığında açma/kapatma yapmasın diye
        exit;

    //FN := TreeListGorev.FocusedNode;
    ID := TabGorevler.FieldByName('ID').AsInteger;

   if TcxDBTreeList(Sender).FocusedColumn.tag=1 then begin
      UpdateveMail(FArama.TabListe.Fields[0].AsInteger, TabGorevler.FieldByName('LISTEID').AsInteger, TabGorevler.FieldByName('ID').AsInteger,
                  TabGorevler.FieldByName('EKLEYEN').AsInteger, TabGorevler.FieldByName('ACKAPA').AsBoolean, TcxDBTreeList(Sender).FocusedNode.HasChildren);
      PlayWavFromResource('Blink');
      if CheckTamamlanan.Checked then
         Listele;
         //TreeListGorev.FindNodeByKeyValue(FN.;
         //TreeListGorev.Focus();
      //0101 else
      //0101    TreeListGorev.FocusedNode.Free; //   yeniden listelemek yerine o node kaldırılır

      TabGorevler.Locate('ID', ID, []);
  end;
  Abort;//Bunu kesinlikle silme (listede tek satır kalınca hata verdiği için eklendi)
end;

procedure TGorevListeDlg.TreeListGorevDblClick(Sender: TObject);
var
  TreeHitTest: TcxTreeListHitTest;
begin
  TreeHitTest := (Sender as TcxDBTreeList).HitTest;
  if not TreeHitTest.HitAtColumn  then // soldaki + alt seviye açma tuşuna bastığında açma/kapatma yapmasın diye
    exit;

  DuzenleMenuClick(Self);
end;

procedure TGorevListeDlg.TreeListGorevDragDrop(Sender, Source: TObject; X,  Y: Integer);
var
  aGridView, aRealGridView: TcxCustomGridView;
  DragID, DropID, ListeTuru : integer;

  //AHitTest: TcxCustomGridHitTest;
  //AValue: Variant;
  ARowIndex, ARecIndex: Integer;
  TreeHitTest: TcxTreeListHitTest;
//    if (TcxDragControlObject (aSource).Control is TcxGridSite) then begin
//    result := TcxGridSite (TcxDragControlObject (aSource).Control).GridView;

begin
  //if TcxDragControlObject(Source).Control  is TcxGridSite then begin
//  if (sender is TcxGridsite) and (source is TcxDragControlObject) then begin
  if not(source.classparent = TcxCustomDBTreeList)  then begin

      //Personel sürüklenip de buraya bırakılırsa
      aRealGridView := GetRealDragSourceGridView (TcxDragControlObject (Source));
      aGridView := GetDragSourceGridView (TcxDragControlObject (Source));

      if aGridView = GridPersonelView then begin
          DragID:= aRealGridView.DataController.Values[aRealGridView.DataController.FocusedRecordIndex, GridPersonelViewID.Index];

          //AHitTest := (Sender as TcxGridSite).GridView.ViewInfo.GetHitTest(X,Y);
          //if AHitTest.HitTestCode = htCell then begin
          TreeHitTest := (Sender as TcxDBTreeList).HitTest;
          if TreeHitTest.HitAtNode then begin
             ADragnode := TcxTreeList(Sender).GetNodeAt(X,Y);
             if ADragnode <> nil then begin
                DropID := ADragnode.Values[0];
             //with TcxGridRecordCellHitTest(AHitTest) do
             //     ARecIndex := TcxGridRecordCellHitTest(AHitTest).GridRecord.RecordIndex;
      //adn         DropID := TreeListGorev.DataController.Values[ARecIndex, GorevGridDBTableView1ID.Index];
             //if TreeListGorev.DataController.Values[ARecIndex, GorevGridDBTableView1LISTEID.Index]=Servis then
//0101             if ADragnode.Values[TreeListGorev.GetColumnByFieldName('LISTEID').ItemIndex] =Servis then
//0101                ListeTuru := 12 //servis için tür
//0101             else
                ListeTuru := 11; //görev için tür
               if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT '+DbUst(1)+'* FROM GOREVKULLANICI where LISTGOREVID='+IntToStr(DropID)+' and TUR='+IntToStr(ListeTuru)+' and REHBERID='+IntToStr(DragID)+' '+DbSinir(1),[],[]) then begin
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                      ' values('+IntToStr(DropID)+','+IntToStr(ListeTuru)+','+IntToStr(DragID)+','+Kullanan+')', [],[]);
                  if (AktifMail>0) then begin
                      TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA', DragID)+','+ Tablo.MailAdresiBul(1, DragID), epostaalicilar);
                      Gorev_EPostaGonder(1,TabGorevler.FieldByName('ID').AsInteger);
                  end;
                  Listele;
               end;
             end;
          end;
      end;
  end;
end;

procedure TGorevListeDlg.TreeListGorevDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var   TreeHitTest: TcxTreeListHitTest;

begin
  if State = dsDragLeave then begin //
     TreeHitTest := (Sender as TcxDBTreeList).HitTest;
     if not TreeHitTest.HitAtNode then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update GOREVLER set BAGIDUST = 0 where ID='+TabGorevler.FieldByName('ID').AsString,[],[]);
        Listele;
        //TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
     end;
  end
  else begin
      ADragnode := TcxTreeList(Sender).GetNodeAt(X,Y);
      if ADragnode <> nil then begin
         Caption := ADragnode.Values[0];
         Accept := True;
      end;
  end;
end;

procedure TGorevListeDlg.TreeListGorevMoveTo(Sender: TcxCustomTreeList;
  AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode;
  Nodes: TList; var IsCopy, Done: Boolean);
var
  dropId, dragId: Integer;
begin
  Sender.BeginUpdate;
  try
   if Nodes.Count = 1 then begin  //Projeler kapalı ve liste diğer listenin altına gelecekse
      dropId := TcxDBTreeListNode( AttachNode ).KeyValue;
      dragId := TcxDBTreeListNode( Nodes[0] ).Values[0];
      if (DragId>0)and(dropId>0) then begin
         //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PROJELER set ASAMA='+IntToStr(abs(dropId))+' where ID='+IntToStr(dragId),[],[]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update GOREVLER set BAGIDUST = '+IntToStr(abs(dropId))+' where ID='+IntToStr(abs(dragId)),[],[]);
         Listele;
         //TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
      end;
    end;
  finally
    Sender.EndUpdate;
  end;
  Done := True;
end;

procedure  TGorevListeDlg.TreeListelerClick(Sender: TObject);
begin
   PanelYeniIs.Visible := (FArama.TabListe.Fields[0].asInteger <> Onayla)and(FArama.TabListe.Fields[0].asInteger <> BanaAtananlar);
//s   DateEdit1.Visible := (PanelYeniIs.Visible)and(FArama.TabListe.Fields[0].asInteger <> Bugun);
   FArama.EditAraProje.Text := '';
   Listele;
{//adn   if FArama.TabListe.Fields[0].asInteger=TumListe then
      Tablo.GridAyarRestore('IsListesiGridi_Tum', TreeListGorev)
   else
      Tablo.GridAyarRestore('IsListesiGridi_Diger', TreeListGorev);  }
end;

procedure TGorevListeDlg.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TGorevListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TGorevListeDlg.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TGorevListeDlg.UstIsiAcMenuClick(Sender: TObject);
var GorevDlg1 : TGorevDlg;
begin
   Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',TabGorevler.FieldByName('BAGIDUST').AsInteger,AtamaYapildi, YorumYapildi);
end;

procedure TGorevListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TGorevListeDlg.GorevArama;
begin
  // Filtre/arama listeleme -> sunucu-tarafi SP (sp_Prog_Gorev_Liste).
  //   Eski SQLGorevMemo + string-concat sorgu kurma Liste_SP_Cagir'a tasindi.
  Liste_SP_Cagir(4);
end;

procedure TGorevListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(1);   // Tum (TOP yok)
end;

procedure TGorevListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA.DEGISTIRMETARIHI)
end;

procedure TGorevListeDlg.LabelSikArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA.SAY)
end;

procedure TGorevListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// JSON (2 PARAM): sp_Prog_Gorev_Liste_Json2 @Baslik + @Kosullar.
//   @Baslik   = SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR; Gorev'de bos -> @SelectList bos).
//   @Kosullar = filtreler JSON (cast/parametreli DEGERLER; app TJSONObject ile guvenli escape).
//   Tipli ~15 param yerine tek JSON; guvenlik siniri net (baslik=ham SQL / kosullar=deger).
//   Bos/opsiyonel filtre JSON'a EKLENMEZ (SP absent=NULL=filtre yok); bool'lar 0/1 sayi (TRY_CAST AS BIT).
//   AMod: 1=Tum (TOP yok), 3=Sik Aranan, 4=Filtre, 5=Son Aranan.
//   NOT: Ana liste TVF yolu (Listele) DEGISMEZ; bu yalnizca arama/filtre listelemesidir.
var
  Ara: string;
  TopN, FirmaID, OlusturanID, AtananID, GorevID, LocateID: Integer;
  j: TJSONObject;
begin
  if not FArama.TabListe.Active then
     Exit;

  // Konu/Notlar arama metni: liste sekmesinde EditAraIsler, arama sekmesinde ComboKonusu
  if FArama.PageListeler.ActivePageIndex = 0 then
     Ara := Trim(FArama.EditAraIsler.Text)
  else
     Ara := Trim(FArama.ComboKonusu.Text);

  // SAYFALI (TSayfaliListe): Mod=1 (Tum) ve Mod=4 (filtre/normal) sayfalanir;
  // Son/Sik Aranan eski TOP davranisinda (kucuk listeler).
  FSonMod := AMod;
  if AMod in [1, 4] then
     TopN := FSayfali.TopN
  else begin
     FSayfali.TopN(False);   // tetikleri pasiflestir
     TopN := 200;            // Son/Sik: kayit sayisi ile sinirla
  end;

  // Metin dolu degilse ID gonderilmez (SP >0 kontrolu ile filtreyi atlar)
  if FArama.AraFirma.Text <> '' then FirmaID := FArama.AraFirma.Tag else FirmaID := 0;
  if FArama.EditOlusturan.Text <> '' then OlusturanID := FArama.EditOlusturan.Tag else OlusturanID := 0;
  if FArama.EditAtanan.Text <> '' then AtananID := FArama.EditAtanan.Tag else AtananID := 0;
  GorevID := StrToIntDef(Trim(FArama.EditID.Text), 0);

  if (TabGorevler.Active) and (TabGorevler.RecordCount > 0) then
     LocateID := TabGorevler.FieldByName('ID').AsInteger
  else
     LocateID := 0;

  j := TJSONObject.Create;
  try
    j.AddPair('TopN', TJSONNumber.Create(TopN));
    j.AddPair('Mod',  TJSONNumber.Create(AMod));
    j.AddPair('Pasif', TJSONNumber.Create(Ord(CheckTamamlanan.Checked)));  // 0=sadece acik (ACKAPA=0)
    if Ara <> '' then j.AddPair('Ara', Ara);
    j.AddPair('Tarih', TJSONNumber.Create(Ord(FArama.checkTarih.Checked)));
    j.AddPair('BasTarih', FormatDateTime('yyyy-mm-dd', FArama.dateAktBaslangic.Date));
    j.AddPair('BitTarih', FormatDateTime('yyyy-mm-dd', FArama.dateAktBitis.Date));
    if FirmaID > 0     then j.AddPair('FirmaID',     TJSONNumber.Create(FirmaID));
    if OlusturanID > 0 then j.AddPair('OlusturanID', TJSONNumber.Create(OlusturanID));
    if AtananID > 0    then j.AddPair('AtananID',    TJSONNumber.Create(AtananID));
    if GorevID > 0     then j.AddPair('GorevID',     TJSONNumber.Create(GorevID));
    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));   // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_Gorev));               // KULLANICI_ARAMA.MODUL
    if not (AMod in [3, 5]) then                                        // Son/Sik'te SP override eder
       j.AddPair('OrderBy', '3,2,G.EKLEYEN desc');                     // orijinal GorevArama sirasi

    // Generic helper: @Baslik='' (Gorev ek-alan yok) + @Kosullar=j (JSON); helper j'yi Free eder + TabloYenile yapar.
    Tablo.ListeSPJson(TabGorevler, 'sp_Prog_Gorev_Liste_Json2', '', j, LocateID);
    j := nil;   // sahiplik helper'a gecti -> finally'de tekrar Free etme
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;

  if not AlanlarOlusturuldu then begin                                 // ilk yuklemede grid kolonlari
     GridGorevView.DataController.CreateAllItems(True);
     Tablo.GridAyarRestore('IsListesiGridi', GridGorevView);
     AlanlarOlusturuldu := True;
  end;
  FSayfali.YuklemeSonrasi;   // ekran dolana kadar zincirleme sayfa (yalniz sayfali dalda etkin)
end;

procedure TGorevListeDlg.GorevEkleTusClick(Sender: TObject);
var
    GorevId, KlasorId : Integer;
    GorevDlg1:TGorevDlg;

    Trh : TDateTime;
begin
   if FArama.TabListe.FieldByName('ID').AsInteger > 0 then
      KlasorId := FArama.TabListe.FieldByName('ID').AsInteger
   else
      KlasorId := Masaustu;


   if TComponent(Sender).ClassName = 'TToolButton' then begin
     // + butonuna basıldıysaa
     GorevId := Tablo.GorevOlustur('', KlasorId,0, 0, 0, 0, 0, 0, 0, 0, 0, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat);
     Tablo.GorevSihirbazBaslat(GorevDlg1, 'E', GorevId, AtamaYapildi, YorumYapildi);
   end else begin
    //takvimde
    Trh := Scheduler.SelStart;
    akttarih:= Scheduler.SelFinish;
    //if Tablo.GorevOlustur('', Masaustu, -1, 0,0,0,0,0,0,0,0, Trh, akttarih) > 0 then
    //    TakvimdeGoster;
    GorevId := Tablo.GorevOlustur('', KlasorId,0, 0, 0, 0, 0, 0, 0, 0, 0, Trh, akttarih);
    Tablo.GorevSihirbazBaslat(GorevDlg1, 'E', GorevId, AtamaYapildi, YorumYapildi);
    TakvimdeGoster
   end;

     if AtamaYapildi then
         Gorev_EPostaGonder(1, GorevId)
     else if YorumYapildi then
         Gorev_EPostaGonder(3, GorevId);
     PageControlUstChange(Self);
end;

procedure TGorevListeDlg.TabGorevlerAfterOpen(DataSet: TDataSet);
begin
   AktifGorevId  := TabGorevler.FieldByName('ID').AsInteger;
   AktifRehberId := AktifRehberId;
end;

procedure TGorevListeDlg.TakvimdeGoster;
var s, tarih : String;
    Sorgu :string;
    i:smallint;
begin
  if SecilmisPersonelList=nil then
      SecilmisPersonelList := TStringList.Create;

   AraQuery1.Close;

   if AktifVeriMotor = vmPG then
   begin
      if SecilmisPersonelList.Count > 0 then begin
        s := '';
        for i := 0 to SecilmisPersonelList.Count-1 do begin
          if i > 0 then s := s + ',';
          s := s + SecilmisPersonelList.Strings[i];
        end;
      end else
        s := '';

      AraQuery1.SQL.Clear;
      AraQuery1.SQL.Add('select row_number() over(order by X."Start", X."GOREV_ID", X."Dosya")::integer as "ID", X.* from (');
      AraQuery1.SQL.Add('select distinct ');
      AraQuery1.SQL.Add('0::smallint as "Type", G.BASLAMATARIHI::timestamp as "Start", G.BITISTARIHI::timestamp as "Finish", ');
      AraQuery1.SQL.Add('3::smallint as "Options", ');
      AraQuery1.SQL.Add('(coalesce(G.KONUSU,'''') || '' / '' || coalesce((select K.KOD from KULLANICI K where K.REHBERID=G.EKLEYEN limit 1),'''') || '' > '' || ');
      AraQuery1.SQL.Add('coalesce((select string_agg(coalesce(KL.KOD,''''), '' - '' order by GK2.ID) ');
      AraQuery1.SQL.Add('from GOREVKULLANICI GK2 inner join KULLANICI KL on KL.REHBERID=GK2.REHBERID ');
      AraQuery1.SQL.Add('where GK2.LISTGOREVID=G.ID and GK2.TUR=11),'''') || '' / '' || ');
      AraQuery1.SQL.Add('coalesce(substring(Musteri.FIRMA from 1 for greatest(position('' '' in Musteri.FIRMA || '' '') - 1, 0)),''''))::varchar(1000) as "Caption", ');
      AraQuery1.SQL.Add('''''::varchar(10) as "Location", ''''::varchar(10) as "Message", 0::smallint as "State", ');
      AraQuery1.SQL.Add('(case when coalesce(G.ACKAPA,0)=1 then 13882323 else 55295 end)::bigint as "LabelColor", ');
      AraQuery1.SQL.Add('coalesce(GK1.REHBERID, G.EKLEYEN)::integer as "ResourceID", ');
      AraQuery1.SQL.Add('''GOREVLER''::varchar(20) as "Dosya", G.ID::integer as "GOREV_ID", ');
      AraQuery1.SQL.Add('G.REHBERID::integer as "REHBERID", G.EKLEYEN::integer as "EKLEYEN", ');
      AraQuery1.SQL.Add('coalesce(G.ACKAPA,0)::smallint as "ACKAPA", coalesce(G.BAYRAK,0)::smallint as "BAYRAK", G.LISTEID::integer as "LISTEID", 0::varchar(200) as "TUR" ');
      AraQuery1.SQL.Add('from GOREVLER G ');
      AraQuery1.SQL.Add('left join GOREVLISTE GL on G.LISTEID=GL.ID ');
      AraQuery1.SQL.Add('left join GOREVKULLANICI GK1 on G.ID=GK1.LISTGOREVID and GK1.TUR in (0,1,2,11) ');
      AraQuery1.SQL.Add('left join REHBER Musteri on Musteri.ID=G.REHBERID ');
      AraQuery1.SQL.Add('where not exists (select 1 from GOREVLER G1 where G1.ID=G.ID ');
      AraQuery1.SQL.Add('and G1.LISTEID=-27 and G1.EKLEYEN<>'+Kullanan+') ');

      if not CheckTamamlanan.Checked then
        AraQuery1.SQL.Add(' and coalesce(G.ACKAPA,0)=0 ')
      else
        AraQuery1.SQL.Add(' and G.BASLAMATARIHI>='''+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh-ComboTamamlanan.EditValue)+'''::timestamp ');
      if s <> '' then
        AraQuery1.SQL.Add(' and (GK1.REHBERID in('+s+') or (G.EKLEYEN in('+s+') '+
          'and not exists(select 1 from GOREVKULLANICI GK where G.ID=GK.LISTGOREVID '+
          'and GK.TUR in (0,1,2,11)))) ');

      AraQuery1.SQL.Add(
        ' union all '+
        'select distinct '+
        '0::smallint as "Type", G.BASLAMATARIHI::timestamp as "Start", G.BITISTARIHI::timestamp as "Finish", '+
        '3::smallint as "Options", '+
        '(coalesce(G.KONUSU,'''') || '' / '' || coalesce((select string_agg(coalesce(KL.KOD,''''), '' - '' order by GK2.ID) from GOREVKULLANICI GK2 inner join KULLANICI KL on KL.REHBERID=GK2.REHBERID where GK2.LISTGOREVID=G.ID and GK2.TUR=12),'''') || '' / '' || coalesce(Musteri.FIRMA,''''))::varchar(1000) as "Caption", '+
        '''''::varchar(10) as "Location", ''''::varchar(10) as "Message", 0::smallint as "State", '+
        '(case when coalesce(G.ACKAPA,0)=1 then 13882323 else 16436871 end)::bigint as "LabelColor", '+
        'coalesce(GK1.REHBERID, G.EKLEYEN)::integer as "ResourceID", '+
        '''SERVIS''::varchar(20) as "Dosya", G.ID::integer as "GOREV_ID", G.REHBERID::integer as "REHBERID", G.EKLEYEN::integer as "EKLEYEN", '+
        'coalesce(G.ACKAPA,0)::smallint as "ACKAPA", coalesce(G.ACIL,0)::smallint as "BAYRAK", -6::integer as "LISTEID", G.TURU::varchar(200) as "TUR" '+
        'from SERVIS G '+
        'left join GOREVKULLANICI GK1 on G.ID=GK1.LISTGOREVID and GK1.TUR=12 '+
        'left join REHBER Musteri on Musteri.ID=G.REHBERID '+
        'where 1=1 ');

      if not CheckTamamlanan.Checked then
        AraQuery1.SQL.Add(' and coalesce(G.ACKAPA,0)=0 ');
      if s <> '' then
        AraQuery1.SQL.Add(' and GK1.REHBERID in('+s+') ');
      AraQuery1.SQL.Add(') X order by X."Start"');
      TabloYenile(AraQuery1, []);
      Exit;
   end;

   AraQuery1.SQL.Text:= MemoPlanSQL.Text+' '+MemoGorevSQL.Text ;
   AraQuery1.SQL.Add(' and not exists (select * from GOREVLER G1 WHERE G1.ID=G.ID AND  G1.LISTEID=-27 AND G1.EKLEYEN<>'+Kullanan+')	');
   if not CheckTamamlanan.Checked then
      AraQuery1.SQL.Add(' and ACKAPA=0 ')
   else
      AraQuery1.SQL.Add(' and BASLAMATARIHI>='''+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh-ComboTamamlanan.EditValue)+''' ');
   if SecilmisPersonelList.Count > 0 then begin
      s:='';
      for i := 0 to SecilmisPersonelList.Count-1 do begin
          if i>0 then s:=s+',';
          s:=s+SecilmisPersonelList.Strings[i];
      end;
      AraQuery1.SQL.Add(' and GK1.REHBERID in('+s+')or'+
      '(G.EKLEYEN in('+s+') and 0=(select count(*) from GOREVKULLANICI GK where G.ID=GK.LISTGOREVID AND GK.TUR in (0,1,2,11) ) )');
   end;


   AraQuery1.SQL.Add(' UNION ALL '+MemoServisSQL.Text);
   if not CheckTamamlanan.Checked then
      AraQuery1.SQL.Add(' and ACKAPA=0');
   if SecilmisPersonelList.Count > 0 then
      AraQuery1.SQL.Add(' and GK1.REHBERID in('+s+')');
(*  if FArama.checkTarih.Checked then
   begin
    AraQuery1.SQL.Add(' and G.BASLAMATARIHI>=''' + formatdatetime('yyyy-mm-dd', FArama.dateAktBaslangic.Date) + ' 00:00'' ');
    AraQuery1.SQL.Add(' and G.BASLAMATARIHI<=''' + formatdatetime('yyyy-mm-dd', FArama.dateAktBitis.Date) + ' 23:59'' ');
   end;
  if FArama.ComboKonusu.Text <> '' then
    AraQuery1.SQL.Add(' and G.KONU like ''%' + FArama.ComboKonusu.Text + '%'' ');
  if FArama.AraFirma.Text <> '' then
    AraQuery1.SQL.Add(' and Musteri.FIRMA like ''%' + FArama.AraFirma.Text + '%'' ');
  if FArama.EditSorumlu.Text <> '' then
    AraQuery1.SQL.Add(' and Pers.ID IN (' + FArama.EditSorumlu.Text + ') ');
  if FArama.ComboTuru.Text <> '' then
    AraQuery1.SQL.Add(' and G.TURU = ' + VarToStr(FArama.ComboTuru.EditValue) + ' ');
  if FArama.ComboTipi.Text <> '' then
    AraQuery1.SQL.Add(' and G.TIPI = ' + VarToStr(FArama.ComboTipi.EditValue) + ' ');
  //if FArama.ComboKonum.Text <> '' then
    //AraQuery1.SQL.Add(' and G.KONUM = ' + FArama.ComboKonum.EditValue + ' ');
  if FArama.AraYetkili.Text <> '' then
    AraQuery1.SQL.Add(' and ( MusteriIlgi1.ID = ' + VarToStr(FArama.AraYetkili.EditValue) + ' or MusteriIlgi2.ID =' + VarToStr(FArama.AraYetkili.EditValue) + ' ) ');
  if FArama.EditAtayan.Text <> '' then
    AraQuery1.SQL.Add(' and AtayanPers.FIRMA like ''%' + FArama.EditAtayan.Text + '%'' ');
  if FArama.EditBilgi.Text <> '' then
    AraQuery1.SQL.Add(' and BilgiPers.FIRMA like ''%' + FArama.EditBilgi.Text + '%'' ');
  if FArama.EditTakipci.Text <> '' then
    AraQuery1.SQL.Add(' and TakipciPers.FIRMA like ''%' + FArama.EditTakipci.Text + '%'' ');

  if not(FArama.checkTamamlanmisGoster.Checked) then
  begin
    AraQuery1.SQL.Add(' and G.DURUM<>9 '); // onaylanmış
    AraQuery1.SQL.Add(' AND 1  = CASE WHEN G.TURU <> 1 AND G.DURUM = 8 THEN 0 ELSE 1 END '); // görev dışındaki aktivitelerin durumu tamamlandı olanların görünmemesi için
  end;

  if trim(FArama.editAraNot.Text)<>'' then
    AraQuery1.SQL.Add(' AND G.NOTLAR LIKE ''%'+trim(FArama.editAraNot.Text)+'%'' ');



  AraQuery1.ParamByName('PPERSONEL').Value := Kullanan;
  AraQuery1.ParamByName('PALANTURU').Value := 1; // Yetki alan türü 1 aktiviteler ekranını belirtir.
  AraQuery1.ParamByName('PYETKIKONTROL').Value := PersonelYetkiKontrol;   *)
  AraQuery1.SQL.Add(' ORDER BY 2   select * from #GOREV_SPID_ '); // sıralamayı ekle cxgrid gruplaması için
  TabloYenile(AraQuery1, []);

end;

procedure TGorevListeDlg.Listele;
var AcKapa, TYetki:String[1];
    ARecIndex, GunSay: Integer;
begin
{  if FArama.CheckTemas.Checked then begin//temas zamanı gelenler
      TabGorevler.SQL.Text :=' exec sp_Prg_IsListesi_Ziyaret '+Kullanan;
      TabloYenile(TabGorevler,[]);
//adn      TreeListGorev.ViewData.Expand(True);
      exit;
   end; }

   if not FArama.TabListe.active then
      exit;
  if  (FArama.PageListeler.ActivePageIndex=1)and(FArama.TabListe.Fields[0].AsInteger < 0) then
      exit;
{//adn  TreeListGorev.OptionsView.GroupByBox := FArama.TabListe.Fields[0].AsInteger = TumListe;
  //TreeListGorev.OptionsView.Header := TreeListGorev.OptionsView.GroupByBox ;
  GorevGridDBTableView1ID.visible := TreeListGorev.OptionsView.GroupByBox ;
  GorevGridDBTableView1EKLEYENAD.visible := TreeListGorev.OptionsView.GroupByBox ;
  GorevGridDBTableView1DURUM.visible := TreeListGorev.OptionsView.GroupByBox ;
  GorevGridDBTableView1TURU.visible := TreeListGorev.OptionsView.GroupByBox ;
  GorevGridDBTableView1PROJEKODU.visible := TreeListGorev.OptionsView.GroupByBox ;
}
  TabGorevler.Close;
  AcKapa:=IntToStr(Abs(StrToInt(BoolToStr(CheckTamamlanan.Checked))));
  TYetki:=IntToStr(Abs(StrToInt(BoolToStr(TamYetkili))));
  if CheckTamamlanan.Checked then
     GunSay := ComboTamamlanan.EditValue
  else
     GunSay := 9999;
  case FArama.TabListe.Fields[0].AsInteger of
       TumListe: begin
                  Tablo.TablodanSorguAc(1,' select R.GOREVID, R.DEPARTMAN  FROM KULLANICI K inner join ROLLER R on K.ROLID=R.ID where K.REHBERID='+Kullanan,true);
                  TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiTumListe] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+','+TYetki+
                    ','+Tablo.Query1.Fields[0].AsString+','+Tablo.Query1.Fields[1].AsString+','+IntToStr(SubeId)+')';
                 end;
       Bugun : // TabGorevler.SQL.Text :=' exec sp_Prg_IsListesiBuhafta '+Kullanan+','+AcKapa+','+IntToStr(GunSay)+',0';
                  TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiBuHafta] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+',0'+')';
       Onayla : // TabGorevler.SQL.Text :=' exec sp_Prg_IsListesiOnayla '+Kullanan+','+IntToStr(VarsayDurumSonOnay)+','+ IntToStr(VarsayDurumServisSonOnay);
                   TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiOnayla] ('+Kullanan+','+IntToStr(VarsayDurumSonOnay)+','+ IntToStr(0)+')';//+ IntToStr(VarsayDurumServisSonOnay)+')';
       BanaAtananlar: // TabGorevler.SQL.Text :=' exec sp_Prg_IsListesiBanaAtananlar '+Kullanan+','+AcKapa+','+IntToStr(GunSay);
                         TabGorevler.SQL.Text :='  SELECT * FROM [dbo].[fn_prg_IsListesiBanaAtananlar] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
       Atanmamislar: //TabGorevler.SQL.Text :=' exec sp_Prg_IsListesiAtanmamislar '+Kullanan+','+AcKapa+','+IntToStr(GunSay);
                     TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiAtanmamislar]('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
       Atadiklarim: //TabGorevler.SQL.Text :=' exec sp_Prg_IsListesiAtadiklarim '+Kullanan+','+AcKapa+','+IntToStr(GunSay);
                     TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiAtadiklarim]( '+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
       Bayrakli : //TabGorevler.SQL.Text :=' exec sp_Prg_IsListesiBayrakli '+Kullanan+','+AcKapa+','+IntToStr(GunSay);
                    TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiBayrakli] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
       Masaustu :  //TabGorevler.SQL.Text :=' exec sp_Prg_IsListesiMasaUstu '+Kullanan+','+AcKapa+','+IntToStr(GunSay);
                    TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiMasaUstu] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
                     //TabGorevler.SQL.Add(' and LISTEID = '+IntToStr(MasaUstu)+' and G.EKLEYEN='+Kullanan);
       ToplantiKlasor :  TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiToplanti] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
       DemirbasKlasor :  TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiDemirbas] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
       Servis : TabGorevler.SQL.Text :=' SELECT * FROM [dbo].[fn_prg_IsListesiServis] ('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+')';
       1..99999 : begin
        if FArama.PageListeler.ActivePageIndex=1 then
           TabGorevler.SQL.Text :='SELECT * FROM [dbo].[fn_prg_IsListesiProjeler] '//' exec sp_Prg_IsListesi_Projeler '
        else
         //  TabGorevler.SQL.Text :=' exec sp_Prg_IsListesi_Listeler ';
           TabGorevler.SQL.Text :='SELECT * FROM [dbo].[fn_Prg_IsListesiListeler]';// (1,0,1,1)
//        TabGorevler.SQL.Add(Kullanan+','+AcKapa+','+IntToStr(GunSay)+','+FArama.TabListe.Fields[0].asstring);
        TabGorevler.SQL.Add('('+Kullanan+','+AcKapa+','+IntToStr(GunSay)+','+FArama.TabListe.Fields[0].asstring+')');
       end;
  end;

  if AktifVeriMotor = vmPG then
    case FArama.TabListe.Fields[0].AsInteger of
      Masaustu, BanaAtananlar, Atanmamislar, Atadiklarim, Bayrakli,
      ToplantiKlasor, DemirbasKlasor, Servis:
        TabGorevler.SQL.Text := PgGorevEskiListeSQL(FArama.TabListe.Fields[0].AsInteger,
           StrToIntDef(Kullanan, 0), AcKapa, GunSay);
      1..99999:
        TabGorevler.SQL.Text := PgGorevEskiListeSQL(FArama.TabListe.Fields[0].AsInteger,
          StrToIntDef(Kullanan, 0), AcKapa, GunSay);
    end;

  TabloYenile(TabGorevler,[]);

   if not AlanlarOlusturuldu then begin
    GridGorevView.DataController.CreateAllItems(True);
    //GridStokView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\StokListeGridi',true,false,[gsoUseFilter],'StokListeGridi');
    Tablo.GridAyarRestore('IsListesiGridi', GridGorevView);
    AlanlarOlusturuldu := True;
  end;

//adn  TreeListGorev.ViewData.Expand(True);
{  if CheckTamamlanan.Checked then
     for ARecIndex := 0 to TreeListGorev.DataController.RecordCount-1 do
         TreeListGorev.DataController.Values[ARecIndex, GorevGridDBTableView1ACKAPASECIM.Index] :=
         TreeListGorev.DataController.Values[ARecIndex, GorevGridDBTableView1ACKAPA.Index];
  }
  TakvimdeGoster;
end;

procedure TGorevListeDlg.YenileTusClick(Sender: TObject);
begin
  PageControlUstChange(Self);
end;

procedure TGorevListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Gorevler);
end;

procedure TGorevListeDlg.GorevGridDBTableView1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  aGridView, aRealGridView: TcxCustomGridView;
  DragID, DropID, ListeTuru : integer;

  AHitTest: TcxCustomGridHitTest;
  AValue: Variant;
  ARowIndex, ARecIndex: Integer;
begin
  aRealGridView := GetRealDragSourceGridView (TcxDragControlObject (Source));
  aGridView := GetDragSourceGridView (TcxDragControlObject (Source));

  if aGridView = GridPersonelView then begin
      DragID:= aRealGridView.DataController.Values[aRealGridView.DataController.FocusedRecordIndex, GridPersonelViewID.Index];

      AHitTest := (Sender as TcxGridSite).GridView.ViewInfo.GetHitTest(X,Y);
      if AHitTest.HitTestCode = htCell then begin
         with TcxGridRecordCellHitTest(AHitTest) do
              ARecIndex := TcxGridRecordCellHitTest(AHitTest).GridRecord.RecordIndex;
{//adn         DropID := TreeListGorev.DataController.Values[ARecIndex, GorevGridDBTableView1ID.Index];
         if TreeListGorev.DataController.Values[ARecIndex, GorevGridDBTableView1LISTEID.Index]=Servis then
            ListeTuru := 12 //servis için tür
         else
            ListeTuru := 11; }//görev için tür
         if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT '+DbUst(1)+'* FROM GOREVKULLANICI where LISTGOREVID='+IntToStr(DropID)+' and TUR='+IntToStr(ListeTuru)+' and REHBERID='+IntToStr(DragID)+' '+DbSinir(1),[],[]) then begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                ' values('+IntToStr(DropID)+','+IntToStr(ListeTuru)+','+IntToStr(DragID)+','+Kullanan+')', [],[]);
            if (AktifMail>0) then begin
                TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA', DragID)+','+ Tablo.MailAdresiBul(1, DragID), epostaalicilar);
                Gorev_EPostaGonder(1,TabGorevler.FieldByName('ID').AsInteger);
            end;
            Listele;
         end;
      end;
  end;
end;

procedure TGorevListeDlg.GorevGridDBTableView1DragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  aGridView: TcxCustomGridView;
begin
  aGridView := GetDragSourceGridView (TcxDragControlObject (Source));
  Accept := aGridView = GridPersonelView;
end;

procedure TGorevListeDlg.GorevlerMenuPopup(Sender: TObject);
var
    selectedEvent : TcxSchedulerControlEvent;
begin
//   if TPopupMenu(TMenuItem(Sender).GetParentComponent).PopupComponent.ClassName = 'TcxScheduler' then begin
  BuTariheIsEkleMenu.Visible := True;
  if TPopupMenu(Sender).PopupComponent.ClassName = 'TcxScheduler' then begin
      if Scheduler.SelectedEventCount = 0 then Exit;
      selectedEvent := Scheduler.SelectedEvents[0];
      MenuGorevId := StrToInt(selectedEvent.GetCustomFieldValueByName('GOREV_ID'))
  end
  else {if FArama.CheckTemas.Checked then //temas listesi açıksa menü görünmesin
     Abort
  else }begin
     MenuGorevId := TabGorevler.FieldByName('ID').AsInteger;
     BuTariheIsEkleMenu.Visible := False;
  end;
 // UstIsiAcMenu.Enabled := TabGorevler.FieldByName('BAGIDUST').AsInteger>0;
  //AltIsiAcMenu.Enabled := TabGorevler.FieldByName('BAGIDALT').AsInteger>0;
  IsiKopyalaMenu.Enabled:= TabGorevler.FieldByName('LISTEID').AsInteger<>Servis;
  BuiIsiTasiMenu.Enabled:= IsiKopyalaMenu.Enabled;
  IsiSilMenu.Enabled:= TabGorevler.FieldByName('EKLEYEN').AsString=Kullanan;
end;

initialization
  RegisterClass(TGorevListeDlg);
end.







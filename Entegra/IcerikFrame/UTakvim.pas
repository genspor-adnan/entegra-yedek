unit UTakvim;

// Plan     ->    Faturası Geldi   ->   Ödeme yap
// Kredi    ->   Ödeme yap
// Fatura   ->   Ödeme yap
// Çek / Senet   ->   Ödeme yap

//Planlananlar
// I  - Planlanan tablosundan müşteri tahsil (61) ve ödeme (71) satırları
// II - Planlanan tablosundan düzenli tahsil (62) ve düzenli ödeme (72) satırları
// III- Planmaas tablosundan personel ödeme (73) satırları
// IV - PlanKredi tablosundan kredi ödeme (58) satırları
// V  - CekSenet tablosundan müşteri tahsil (23,24) ve ödeme (33,34) satırları
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxStyles, cxGraphics, cxEdit, cxScheduler, cxSchedulerStorage,
  cxSchedulerCustomControls, cxSchedulerCustomResourceView, cxSchedulerDayView,
  cxSchedulerDateNavigator, cxSchedulerTimeGridView, cxSchedulerUtils,cxLookAndFeelPainters,
  cxSchedulerWeekView, cxSchedulerYearView, cxSchedulerDBStorage, cxControls,
  DB, FireDAC.Comp.Client, StdCtrls, cxContainer, cxCheckBox, ExtCtrls, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, Buttons, Grids, DBGrids, Utablo,
  dxSkinsCore, cxSchedulerHolidays,DateUtils, ShellApi, UGentegreFrameYonetimi,
  cxSchedulerGanttView, UTakvimAksiyonFrame, UFrameYoneticisi, ComCtrls, ToolWin,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxDBData,
  cxCurrencyEdit, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGridLevel, cxClasses, cxGridCustomView, cxGrid, dxSkinLondonLiquidSky,
  dxSkinsDefaultPainters, frxClass, frxDBSet, dxSkinscxSchedulerPainter, cxPC,
  cxGridDBChartView, dxSkinLiquidSky, cxGridChartView, dxBarBuiltInMenu,
  cxLookAndFeels, cxPCdxBarPopupMenu, cxNavigator, cxSchedulerTreeListBrowser,
  cxCustomPivotGrid, cxDBPivotGrid, cxImageComboBox, JvExComCtrls,
  JvDateTimePicker, cxSchedulerRibbonStyleEventEditor, cxSchedulerRecurrence,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxSchedulerAgendaView, dxDateRanges,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses,
  FireDAC.Comp.DataSet;

type
  TTakvimDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    SchedulerDBStorage: TcxSchedulerDBStorage;
    SchedulerDataSource: TDataSource;
    TabTakvim: TFDQuery;
    PopupMenu1: TPopupMenu;
    OdemeMenu: TMenuItem;
    N1: TMenuItem;
    GunlukMenu: TMenuItem;
    N2: TMenuItem;
    AksiyonMenu: TMenuItem;
    BilgileriDegisMenu: TMenuItem;
    Butariheplanekle1: TMenuItem;
    SilMenu: TMenuItem;
    TahsilatPlanMenu: TMenuItem;
    OdemePlanMenu: TMenuItem;
    N3: TMenuItem;
    Butarihefaturaekle1: TMenuItem;
    GelenFaturaMenu: TMenuItem;
    GidenFaturaMenu: TMenuItem;
    N4: TMenuItem;
    BuguneaksiyonekleMenu: TMenuItem;
    ToolBar1: TToolBar;
    AylikTus: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    NakitOdemeMenu: TMenuItem;
    HavaleEFTOdemeMenu: TMenuItem;
    CekOdemeMenu: TMenuItem;
    SenetOdemeMenu: TMenuItem;
    DtsToplam: TDataSource;
    TabToplam: TFDQuery;
    KrediKart1: TMenuItem;
    TahsilMenu: TMenuItem;
    Nakit1: TMenuItem;
    HavaleEFT1: TMenuItem;
    POS1: TMenuItem;
    ek1: TMenuItem;
    Senet1: TMenuItem;
    GenelMenu: TMenuItem;
    Gizle1: TMenuItem;
    ToolButton1: TToolButton;
    YaziciYaz: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    frxTAKVIM: TfrxDBDataset;
    TAKVIM: TFDQuery;
    PageControl: TcxPageControl;
    TabSheetTakvim: TcxTabSheet;
    TabSheetGrafik: TcxTabSheet;
    Scheduler: TcxScheduler;
    pnlControls: TPanel;
    Memo1: TMemo;
    GridToplam: TcxGrid;
    ToplamView: TcxGridDBTableView;
    ToplamViewYON: TcxGridDBColumn;
    ToplamViewTUR: TcxGridDBColumn;
    ToplamViewTUTAR: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    GridGrafikLevel1: TcxGridLevel;
    GridGrafik: TcxGrid;
    GridGrafikDBChartView: TcxGridDBChartView;
    GridGrafikDBChartViewGUN: TcxGridDBChartSeries;
    GridGrafikDBChartViewAYADI: TcxGridDBChartSeries;
    TabGrafik: TFDQuery;
    DsTabGrafik: TDataSource;
    GridGrafikDBChartViewBAKIYE: TcxGridDBChartSeries;
    SqlGrafikTahsilatPlan: TMemo;
    SqlGrafikOdemePlan: TMemo;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    SqlMemoGrafik: TMemo;
    SqlGrafikPOS: TMemo;
    SqlGrafikMaas: TMemo;
    SqlGrafikKK: TMemo;
    SqlGrafikKredi: TMemo;
    SqlGrafikGider: TMemo;
    SqlGrafikGelir: TMemo;
    SqlGrafikSenetMusteri: TMemo;
    SqlGrafikSenetKendi: TMemo;
    SqlGrafikCekKendi: TMemo;
    SqlGrafikCekMusteri: TMemo;
    MemoPlanButce: TMemo;
    MemoPlanKredi: TMemo;
    MemoPlanMaas: TMemo;
    MemoTakvimCekKendi: TMemo;
    MemoTakvimCekMusteri: TMemo;
    MemoTakvimPlanKK: TMemo;
    MemoTakvimOdemePlan: TMemo;
    MemoTakvimTahsilatPlan: TMemo;
    MemoOdeme: TMemo;
    MemoFatura: TMemo;
    MemoTakvimSenetMusteri: TMemo;
    MemoTakvimSenetKendi: TMemo;
    MemoTakvimGider: TMemo;
    MemoTakvimGelir: TMemo;
    MemoTakvimPOS: TMemo;
    MemoBaslangic: TMemo;
    TabSheetPivot: TcxTabSheet;
    TabPivot: TFDQuery;
    DtsPivot: TDataSource;
    Panel1: TPanel;
    LabelBittar: TJvDateTimePicker;
    cxImageComboBox1: TcxImageComboBox;
    Memo2: TMemo;
    TabPivotGRUP: TWideStringField;
    TabPivotTUR: TWideStringField;
    TabPivotTARIH: TSQLTimeStampField;
    TabPivotTUTAR: TFloatField;
    Label1: TLabel;
    pivot: TcxDBPivotGrid;
    pivotGRUP: TcxDBPivotGridField;
    pivotTUR: TcxDBPivotGridField;
    pivotTARIH: TcxDBPivotGridField;
    pivotTUTAR: TcxDBPivotGridField;
    pmPivot: TPopupMenu;
    ExcelPivot1: TMenuItem;
    FGrid: TcxGrid;
    FGridTableView: TcxGridDBTableView;
    FGridDBTableView1: TcxGridDBTableView;
    FGridDBTableView1DURUM: TcxGridDBColumn;
    FGridDBTableView1VADE: TcxGridDBColumn;
    FGridDBTableView1SERINO: TcxGridDBColumn;
    FGridDBTableView1HESAPADI: TcxGridDBColumn;
    FGridDBTableView1Column1: TcxGridDBColumn;
    FGridLevel1: TcxGridLevel;
    FGridTableViewGRUP: TcxGridDBColumn;
    FGridTableViewTUR: TcxGridDBColumn;
    FGridTableViewTARIH: TcxGridDBColumn;
    FGridTableViewTUTAR: TcxGridDBColumn;
    TabSheetListe: TcxTabSheet;
    Panel2: TPanel;
    DateTimeListeBitis: TJvDateTimePicker;
    DtsListe: TDataSource;
    LISTE: TFDQuery;
    GridListe: TcxGrid;
    GridListeView: TcxGridDBTableView;
    GridListeLevel1: TcxGridLevel;
    GridListeViewPLANTARIHI: TcxGridDBColumn;
    GridListeViewKOD: TcxGridDBColumn;
    GridListeViewFIRMA: TcxGridDBColumn;
    GridListeViewISTEL: TcxGridDBColumn;
    GridListeViewBORC: TcxGridDBColumn;
    GridListeViewTAHSILAT: TcxGridDBColumn;
    GridListeViewKUR: TcxGridDBColumn;
    GridListeViewACIKLAMA: TcxGridDBColumn;
    PopupMenuListe: TPopupMenu;
    MenuListeDuzenle: TMenuItem;
    N5: TMenuItem;
    MenuListeSil: TMenuItem;
    CheckTahsilat: TcxCheckBox;
    CheckOdeme: TcxCheckBox;
    GridListeViewODEME: TcxGridDBColumn;
    GridListeViewTIPI: TcxGridDBColumn;
    SQLListe: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    procedure YenileTusClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure GunlukMenuClick(Sender: TObject);
    procedure AksiyonMenuClick(Sender: TObject);
    procedure BilgileriDegisMenuClick(Sender: TObject);
    procedure SchedulerDblClick(Sender: TObject);
    procedure OdemePlanMenuClick(Sender: TObject);
    procedure BuguneaksiyonekleMenuClick(Sender: TObject);
    procedure AylikTusClick(Sender: TObject);
    procedure NakitOdemeMenuClick(Sender: TObject);
    procedure SchedulerDateNavigatorSelectionChanged(Sender: TObject;
      const AStart, AFinish: TDateTime);
    procedure SilMenuClick(Sender: TObject);
    procedure Gizle1Click(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ExcelPivot1Click(Sender: TObject);
    procedure LabelBittarChange(Sender: TObject);
    procedure DateTimeListeBitisChange(Sender: TObject);
    procedure MenuListeSilClick(Sender: TObject);
    procedure MenuListeDuzenleClick(Sender: TObject);
    procedure GridListeViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    { IBilgiFrame üyeleri            }
    FFrameBilgi : TIcerikFrameBilgi;
    FTakvimAksiyonlar : TTakvimAksiyonFrame;
    //FGridTableView        : TcxGridDBTableView;
    //FGrid                 : TcxGrid;
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
    {********************************}
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl : string;
    procedure TabloAc(var Tablo1 : TFDQuery; BasTarih, BitTarih : TDateTime);
    procedure SetTakvimAksiyonlar(const Value: TTakvimAksiyonFrame);
    function DetayliBilgiGetir(Tur, Id : Integer; var RehberID: Integer; var Tutar:Currency) : Boolean;
    procedure GrafikOlustur;
    procedure ZamanSecildi;
    procedure TakvimSil(Tur,ID:Integer);
  public
    { Public declarations }
    //property GridTableView: TcxGridDBTableView read FGridTableView write FGridTableView;
    //property Grid : TcxGrid read FGrid write FGrid;
    procedure TusBasildi(Tus : TToolButton);
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  published
    property TakvimAksiyonlar : TTakvimAksiyonFrame read FTakvimAksiyonlar write SetTakvimAksiyonlar;

  end;

var
  TakvimDlg: TTakvimDlg;
  AylikHaftalikGunluk : Integer;

implementation

uses UVeriMotor, UGunlukTakvim, UAnaForm, UKasaWizard, Umesaj, PrjConst,FetaKurulusSiniflari,
  UAramaYokFrame, UNakitDlg, UFastRap, URaporAraclari, UGenelAnaSekmeFrame, GenoTIP.Ortak.GridPivotUtils,LocOnFly;
{$R *.dfm}



procedure TTakvimDlg.AksiyonMenuClick(Sender: TObject);
begin
//   AnaForm.KasaTus.Click;
end;

procedure TTakvimDlg.BuguneaksiyonekleMenuClick(Sender: TObject);
var Trh, Tarih : TDateTime;
    Sonuc : Integer;
begin
   Trh := Scheduler.SelStart;
   Tarih :=  StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Trh)+
                  FormatDateTime(' hh:nn:ss', Tablo.GENINI.BugunTrhSaat));
   Sonuc := Tablo.KasaSihirbazBaslat('E', -1,-1, 0, -1,Tarih,Tablo.GENINI.BugunTrhSaat,0,0,'','');
   if Sonuc in [9,19] then
      Tablo.SiparisSihirbazBaslat('E', Sonuc,0, -1, -1)
   else if Sonuc in [10..16] then begin
      if Sonuc=11 then
        Sonuc := 0 //0:belge girişi  1:belge çıkışı
      else
        Sonuc := 1;
      Tablo.FaturaSihirbazBaslat('E', Sonuc,-1, -1,0)
   end else if Sonuc in [20..39] then
     Tablo.MakbuzSihirbazBaslat('E', Sonuc,0, -1, -1, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Trh)+
                    FormatDateTime(' hh:nn:ss', Tablo.GENINI.BugunTrhSaat)), '');
   FTakvimAksiyonlar.YenileTus.Click;
end;

constructor TTakvimDlg.Create(AOwner: TComponent);
begin
  inherited;
  Scheduler.SelectDays([Date - 1, Date, Date + 13], True);
  Height := 550;
  Width := 700;
  //SQL komutunda SPID değernini değiştirelim
end;

procedure TTakvimDlg.PageControlChange(Sender: TObject);
var s, ra : string;
begin
   //yazdırma ayarları her sekmeye göre yapılır
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra, TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;


   if PageControl.ActivePage=TabSheetTakvim then begin
    TakvimAksiyonlar.DateTakvimBasTar.Visible:=True;
    TakvimAksiyonlar.DateTakvimBitTar.Visible:=True;
    TakvimAksiyonlar.DateGrafikBasTar.Visible:=False;
    TakvimAksiyonlar.DateGrafikBitTar.Visible:=False;
    ZamanSecildi;
//    YenileTusClick(Sender);
  end else if PageControl.ActivePage=TabSheetPivot then begin
    if LabelBittar.Tag=0 then begin
       LabelBittar.Date:=Tablo.GENINI.BugunTrh+30;
       LabelBittar.Tag:=1;
    end;
    //AylikTusClick(self);
    ZamanSecildi;
  end else if PageControl.ActivePage=TabSheetGrafik then begin
    TakvimAksiyonlar.DateGrafikBasTar.Visible:=True;
    TakvimAksiyonlar.DateGrafikBitTar.Visible:=True;
    TakvimAksiyonlar.DateTakvimBasTar.Visible:=False;
    TakvimAksiyonlar.DateTakvimBitTar.Visible:=False;
    GrafikOlustur;
  end else if PageControl.ActivePage=TabSheetListe then begin
    s:=' and ';
    if (CheckTahsilat.Checked)and(CheckOdeme.Checked) then s:=s+' (TUR=61 or TUR=71) '
    else if CheckTahsilat.Checked then s:=s+' (TUR=61) '
    else if CheckOdeme.Checked then s:=s+' (TUR=71) '
    else s:=s+' TUR=9999 ';  // hiç işaretlenmediyse
    LISTE.SQL.Text := SQLListe.Text + ' PLANTARIHI <= '''+FormatDateTime('yyyy-MM-dd 23:59', DateTimeListeBitis.Date)+''' '+s+' order by 2 ';
    TabloYenile(LISTE, []);
  end;
end;

procedure TTakvimDlg.GrafikOlustur;
var
  OlusanSQL: string;
begin
 OlusanSQL:='';
         if FTakvimAksiyonlar.GiderFiltreCheck.States[0]=cbsChecked then begin  //Odeme Planı
           OlusanSQL:= ' Union All '+SqlGrafikOdemePlan.Lines.Text;
         end;
         if FTakvimAksiyonlar.GelirFiltreCheck.States[0]=cbsChecked then begin  //Tahsilat Planı
           OlusanSQL:= OlusanSQL +' Union All '+SqlGrafikTahsilatPlan.Lines.Text;
         end;
         if FTakvimAksiyonlar.GiderFiltreCheck.States[1]=cbsChecked then begin  //KK
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikKK.Lines.Text;
         end;
         if FTakvimAksiyonlar.GelirFiltreCheck.States[1]=cbsChecked then begin  //POS
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikPOS.Lines.Text;
         end;
         if FTakvimAksiyonlar.GiderFiltreCheck.States[2]=cbsChecked then begin  //Çek
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikCekKendi.Lines.Text;
         end;
         if FTakvimAksiyonlar.GelirFiltreCheck.States[2]=cbsChecked then begin  //Çek
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikCekMusteri.Lines.Text;
         end;
         if FTakvimAksiyonlar.GiderFiltreCheck.States[3]=cbsChecked then begin  //Senet
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikSenetKendi.Lines.Text;
         end;
         if FTakvimAksiyonlar.GelirFiltreCheck.States[3]=cbsChecked then begin  //Senet
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikSenetMusteri.Lines.Text;
         end;
         if FTakvimAksiyonlar.GiderFiltreCheck.States[5]=cbsChecked then begin  //Kredi
            OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikKredi.Lines.Text;
         end;
         if FTakvimAksiyonlar.GelirFiltreCheck.States[4]=cbsChecked then begin  //Gelir
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikGelir.Lines.Text;
         end;
         if FTakvimAksiyonlar.GiderFiltreCheck.States[4]=cbsChecked then begin  //Gider
            OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikGider.Lines.Text;
         end;
         if FTakvimAksiyonlar.GiderFiltreCheck.States[6]=cbsChecked then begin  //Maaş
           OlusanSQL:= OlusanSQL + ' Union All '+ SqlGrafikMaas.Lines.Text;
         end;
  TabGrafik.Close;
  TabGrafik.SQL.Text:=StringReplace(SqlMemoGrafik.Lines.Text,'_SQLMEMO_',OlusanSQL,[rfReplaceAll]);
    case AylikHaftalikGunluk  of
       0:begin
         TabGrafik.SQL.Add('select * from GRAFIKPLAN_SPID ORDER by TARIH');
       end;
       2:begin
         TabGrafik.SQL.Add('Select * from GRAFIKPLAN_SPID Where datename(dw,TARIH)=''Sunday'' order by TARIH  ');//Pazar günlerini listelele
       end;
       -1,3:begin
         TabGrafik.SQL.Add('select GUN,AY,BAKIYE,TARIH,'+DbConv('DATEADD(dd,-(DAY(DATEADD(mm,1,TARIH))),DATEADD(mm,1,TARIH))','VARCHAR(10)',112)+'  from GRAFIKPLAN_SPID'+
         ' Where TARIH='+DbConv('DATEADD(dd,-(DAY(DATEADD(mm,1,TARIH))),DATEADD(mm,1,TARIH))','VARCHAR(10)',112)+' and TARIH >='''+FormatDateTime('yyyy-mm-dd 00:00',TakvimAksiyonlar.DateGrafikBasTar.Date)+'''  and TARIH <= '''+FormatDateTime('yyyy-mm-dd 00:00',TakvimAksiyonlar.DateGrafikBitTar.Date)+''' '+
         ' Order by TARIH');
       end;
    end;
  TabGrafik.Params[0].Value:=FTakvimAksiyonlar.DateGrafikBasTar.Date;
  TabGrafik.Params[1].Value:=FTakvimAksiyonlar.DateGrafikBitTar.Date;
  TabloYenile( TabGrafik, []);
end;


procedure TTakvimDlg.DateTimeListeBitisChange(Sender: TObject);
begin
   if PageControl.ActivePage=TabSheetListe then
      PageControlChange(Self);
end;

destructor TTakvimDlg.Destroy;
begin

  inherited;
end;

procedure TTakvimDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TTakvimDlg.ExcelPivot1Click(Sender: TObject);
begin
  Tablo.SaveDialog1.FileName := 'Nakit Akış Pivot-'+FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)+'.xlsx';
  if Tablo.SaveDialog1.Execute then begin
    if ExportToExcelPivot(Tablo.SaveDialog1.FileName,FGrid,FGridTableView,pivot) then
      ShellExecute(0,'open',PWideChar(Tablo.SaveDialog1.FileName),nil,nil,SW_SHOW);
  end;
end;

procedure TTakvimDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTakvimDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTakvimDlg.DetayliBilgiGetir(Tur, Id : Integer; var RehberID: Integer; var Tutar:Currency) : Boolean;
begin
   Tablo.Query1.Close;
   case TUR of
     61 : Tablo.Query1.SQL.Text := 'select REHBERID,BORC  from KASA ';
     71 : Tablo.Query1.SQL.Text := 'select REHBERID,ALACAK  from KASA ';
     11, 15 : Tablo.Query1.SQL.Text := 'select REHBERID,FATURA_TUTARI  from FATBASLIK ';
   end;
   Tablo.Query1.SQL.Add(' where ID = ' + IntToStr(Id));
   Tablo.Query1.open;
   RehberID := Tablo.Query1.Fields[0].AsInteger;
   Tutar := Tablo.Query1.Fields[1].AsCurrency;

end;

function TTakvimDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTakvimDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TTakvimDlg.Gizle1Click(Sender: TObject);
var
   selectedEvent : TcxSchedulerControlEvent;
begin
  selectedEvent := Scheduler.SelectedEvents[0];
  Tablo.Query1.close;
  Tablo.Query1.SQL.Text:=' Update BUTCE SET GOR=0 where ID='+inttostr(selectedEvent.GetCustomFieldValueByName('ID2'));
  Tablo.Query1.ExecSQL;
  YenileTusClick(Self);
end;

procedure TTakvimDlg.Gorunmez;
begin

end;

procedure TTakvimDlg.GorunmezOlacak;
begin

end;

procedure TTakvimDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TTakvimDlg.GorunurOlacak;
begin

end;

procedure TTakvimDlg.GunlukMenuClick(Sender: TObject);
var Trh : TDateTime;
begin
  Trh := Scheduler.SelStart;

  if GunlukTakvimDlg = nil then
     Application.CreateForm(TGunlukTakvimDlg, GunlukTakvimDlg);
  GunlukTakvimDlg.Tarih := Trh;// .RealFirstDate;// Date;
  GunlukTakvimDlg.InitIslemler;
  GunlukTakvimDlg.ShowModal;
end;

procedure TTakvimDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTakvimDlg.LabelBittarChange(Sender: TObject);
begin
   ZamanSecildi;
end;

procedure TTakvimDlg.MenuListeDuzenleClick(Sender: TObject);
begin
   AnaForm.GormeDialogCagir(LISTE.Fields[0].AsInteger, LISTE.FieldByName('TUR').AsInteger, LISTE.FieldByName('REHBERID').AsInteger, 0,LISTE.FieldByName('PLANTARIHI').AsDateTime, '0');
   TabloYenile(LISTE, [FormatDateTime('yyyy-MM-dd 23:59', DateTimeListeBitis.Date)]);
end;

procedure TTakvimDlg.MenuListeSilClick(Sender: TObject);
begin
   if Application.MessageBox(PCHAR(TAksiyonsil), PCHAR(Onay), MB_YESNO) = IDYES then begin
      TakvimSil(LISTE.FieldByName('TUR').AsInteger,LISTE.Fields[0].AsInteger);
      //TabloYenile(LISTE, [FormatDateTime('yyyy-MM-dd 23:59', DateTimeListeBitis.Date)]);
      PageControlChange(Self);
   end;
end;

procedure TTakvimDlg.NakitOdemeMenuClick(Sender: TObject);
var
   PlanID, PlanTur, ID,Tur, RehberID: Integer;
   Kur : String[5];
   Tutar:Currency;
   selectedEvent : TcxSchedulerControlEvent;
   HesapTuru : Char;
   Tarih :TDateTime;
   procedure KrediTahsilEt;
   begin
      Tarih := Tablo.GENINI.BugunTrhSaat;
      Tablo.KasaSihirbazBaslat('E', ID, TUR, 9,  RehberId, Tarih,Tarih,0, Tutar, Kur, '')
     (* Application.CreateForm(TKasaWizardDlg, KasaWizardDlg);
      KasaWizardDlg.SecIslem := 58;
      KasaWizardDlg.Cagiran := 8;
      KasaWizardDlg.ID:= ID;
      KasaWizardDlg.RehberId := RehberId;
      KasaWizardDlg.IslemOp := 'E';
      KasaWizardDlg.KasaTarihi.Date := Tablo.GENINI.BugunTrhSaat;

      {if Tur in [61,71,72] then begin
         KasaWizardDlg.DatePesinat.Date := PlanTarihi;
         KasaWizardDlg.ComboPlanAciklama.Text := Aciklama;
         if Tutar > 0 then begin
            KasaWizardDlg.EditTutar.Value := Tutar;
            KasaWizardDlg.ComboKurPlan.Text := Kur;
         end;
      end;}
      KasaWizardDlg.MenuEkr.Enabled := False;
      KasaWizardDlg.IslemSecildi;

      KasaWizardDlg.ShowModal;
      if KasaWizardDlg.ModalResult = mrOk then
        Result := KasaWizardDlg.SecIslem
      else
        Result := -99;
      KasaWizardDlg.destroy;*)

   end;
begin
// Plan   (Tur = 61 veya 71)   ->   Ödeme yap   //Burdaki ID PLANLANAN tablosundaki ID karşılığı
// Kredi  (Tur = 58)   ->   Ödeme yap   //Burdaki ID PLANKREDI tablosundaki ID karşılığı
// Fatura (Tur = 11 veya 15)  ->   Ödeme yap   //Burdaki ID FATBASLIK tablosundaki ID karşılığı
// Çek / Senet (Tur = Çek:23 veya 33 Sen:24 veya 34)  ->   Ödeme yap //Burdaki ID CEKSENET tablosundaki ID karşılığı
//           ID := Scheduler.CurrentView.HitTest.Event.Source.GetCustomFieldValueByName('ID2');
   if Scheduler.SelectedEventCount = 0 then Exit;
   selectedEvent := Scheduler.SelectedEvents[0];
   PlanID := selectedEvent.GetCustomFieldValueByName('ID2');
   PlanTur := StrToInt(selectedEvent.GetCustomFieldValueByName('TUR'));
   RehberId:= selectedEvent.GetCustomFieldValueByName('REHBERID');
   Tutar:= selectedEvent.GetCustomFieldValueByName('TUTAR');
   Kur:= selectedEvent.GetCustomFieldValueByName('KUR');

   //şimdi sihirbazı çağırabiliriz
   Tur := TMenuItem(Sender).Tag;
   case Tur of
       21,31 : HesapTuru := 'K';
       23,33 : HesapTuru := 'V';
       else    HesapTuru := 'B';
   end;
   case Tur of
     10,11,12,14,15,16 : ID := Tablo.FaturaSihirbazBaslat('E', Tur,-1, -1,0);
     9,19 : ID := Tablo.SiparisSihirbazBaslat('E', Tur,0, -1, -1);
     13,17 : Tablo.TahakkukSihirbaziBaslat('E',Tur,0,-1,-1,Tablo.GENINI.BugunTrhSaat);
     21..39 : begin//ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,0, -1, RehberId, Tablo.GENINI.BugunTrhSaat, '-1');
       Application.CreateForm(TNakitDlg, NakitDlg);
       NakitDlg.ID := -1;
       NakitDlg.Tur := Tur;
       NakitDlg.HesapTuru := HesapTuru;
       NakitDlg.IslemOp := 'E';
       NakitDlg.RehberId := RehberId;
       NakitDlg.MakbuzTarih := Tablo.GENINI.BugunTrhSaat;
       NakitDlg.LabelTarih.Visible := True; //menüden kısayol olduğu için tarih girilebilir
       NakitDlg.EditTarih.Visible := True;
       NakitDlg.MakbuzNo := SiradakiMakbuzNumarasi(Tur);
       NakitDlg.Tutar := Tutar;
       NakitDlg.Kur := Kur;
       NakitDlg.showmodal;
       if NakitDlg.ModalResult = mrOk  then  begin
          Tablo.KasaSilmeIslemleri(PlanID, PlanTur);
          FTakvimAksiyonlar.YenileTus.Click;
       end;
       NakitDlg.Destroy;
     end;
     51..54,58 : begin Tarih:= Tablo.GENINI.BugunTrhSaat;
                   Tablo.KasaSihirbazBaslat('E', PlanID, TUR, 9,  RehberId, Tarih,Tarih,0, Tutar, Kur, '');//KrediTahsilEt;
                 end;
   end;
   FTakvimAksiyonlar.YenileTus.Click;
end;

procedure TTakvimDlg.OdemePlanMenuClick(Sender: TObject);
var Trh,Tarih : TDateTime;
    ID : Integer;
begin
    ID := 0;
    Trh := Scheduler.SelStart;
    Tarih := Tablo.GENINI.BugunTrhSaat;
    ID := Tablo.KasaSihirbazBaslat('E', -1, TMenuItem(Sender).Tag, 0, -1, Tarih,Trh,0,0,'','');
    if ID > 0 then
       FTakvimAksiyonlar.YenileTus.Click;
end;

procedure TTakvimDlg.PopupMenu1Popup(Sender: TObject);
var Dosya,s :String[20];
    Aciklama : string;
    Tur : SmallInt;
    Enable : Boolean;
    procedure TagaBilgiYaz(i:SmallInt);
    begin
       NakitOdemeMenu.Tag := i;
       HavaleEFTOdemeMenu.Tag := i+1;
       CekOdemeMenu.Tag := i+2;
       SenetOdemeMenu.Tag := i+3;
    end;
begin
// Plan     ->    Faturası Geldi   ->   Ödeme yap
// Kredi    ->   Ödeme yap
// Fatura   ->   Ödeme yap
// Çek / Senet   ->   Ödeme yap
   Enable := Scheduler.CurrentView.HitTest.Event <> nil;
   BilgileriDegisMenu.Enabled := Enable;
   TahsilMenu.Enabled := Enable;
   SilMenu.Enabled := Enable;
   if Scheduler.CurrentView.HitTest.HitAtEvent then begin

       Dosya := Scheduler.CurrentView.HitTest.Event.Source.GetCustomFieldValueByName('Dosya');
       Tur := StrToInt(Scheduler.CurrentView.HitTest.Event.Source.GetCustomFieldValueByName('Tur'));
       Aciklama := Scheduler.CurrentView.HitTest.Event.Caption; //Scheduler.CurrentView.HitTest.Event.Source.Get  CustomFieldValueByName('caption');

       //Çek senet ödemesi tekrar çek senetle yapılmayacağı için kapatırız
       TahsilMenu.Visible := Tur = 61;
       OdemeMenu.Visible := Tur = 71;
       case Tur of
         23 : begin
                GenelMenu.Visible := True;
                GenelMenu.Caption := 'Çek Tahsilatını Yap';
                GenelMenu.Tag := 51;
              end;
         24 : begin
                GenelMenu.Visible := True;
                GenelMenu.Caption := 'Senet Tahsilatını Yap';
                GenelMenu.Tag := 52;
              end;
         33 : begin
                GenelMenu.Visible := True;
                GenelMenu.Caption := 'Çek Ödemesini Yap';
                GenelMenu.Tag := 53;
              end;
         34 : begin
                GenelMenu.Visible := True;
                GenelMenu.Caption := 'Senet Ödemesini Yap';
                GenelMenu.Tag := 54;
              end;
         111: begin
                GenelMenu.Visible := True;
                GenelMenu.Caption := 'Kredi Ödemesini Yap';
                GenelMenu.Tag := 58;
              end
         else
              GenelMenu.Visible := False;
       end;
//       NakitOdemeMenu.Visible := Dosya <> 'PLANKREDI' ;
//       CekOdemeMenu.Visible := not((Dosya = 'CEKLER') or (Dosya = 'PLANKREDI'));
//       SenetOdemeMenu.Visible := not((Dosya = 'SENETLER') or (Dosya = 'PLANKREDI'));
       //Sadece planlarda ve ahmin olduğu zaman fatura menüsü görülecek
       Gizle1.Visible := Dosya = 'Bütçe';
       if Dosya = 'KASA' then begin //eğer plansa
          s := 'Plan';
       end else if Dosya = 'FATBASLIK' then begin
          s := 'Fatura';
          if Tur=11 then begin
             TahsilMenu.Caption := 'Fatura ödemesini yap';
             TagaBilgiYaz(31);
          end else begin
             TahsilMenu.Caption := 'Fatura tahsilatını yap' ;
             TagaBilgiYaz(21);
          end;
       end else
       BilgileriDegisMenu.Caption :=s+' bilgilerini gör / değiştir';
   end;
end;

procedure TTakvimDlg.SchedulerDateNavigatorSelectionChanged(Sender: TObject;
  const AStart, AFinish: TDateTime);
begin
   if TabTakvim.Active then begin
     TabToplam.Close;
     TabToplam.SQL.Text := StringReplace(TabToplam.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
//     TabToplam.Params[0].value := FormatDateTime('yyyy-mm-dd 00:00', AStart);
//     TabToplam.Params[1].value := FormatDateTime('yyyy-mm-dd 00:00', AFinish);
//     TabToplam.Open;
     TabloYenile(TabToplam,[FormatDateTime('yyyy-mm-dd 00:00', AStart), FormatDateTime('yyyy-mm-dd 00:00', AFinish)]);
   end;
end;

procedure TTakvimDlg.SchedulerDblClick(Sender: TObject);
begin
   if Scheduler.CurrentView.HitTest.Event <> nil then
      BilgileriDegisMenu.Click
   else
      GunlukMenu.Click;
end;

procedure TTakvimDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTakvimDlg.SetTakvimAksiyonlar(const Value: TTakvimAksiyonFrame);
begin
  FTakvimAksiyonlar := Value;
  with FTakvimAksiyonlar do begin
    DateTakvimBasTar.Date := StartOfTheYear(Tablo.GENINI.BugunTrh-180);
    DateTakvimBitTar.Date := EndOfTheYear(Tablo.GENINI.BugunTrh+180);
    DateGrafikBasTar.Date := Tablo.GENINI.BugunTrh;;
    DateGrafikBitTar.Date := Tablo.GENINI.BugunTrh+365;

    YenileTusClick(Self);
    SchedulerDateNavigatorSelectionChanged(self,Scheduler.DateNavigator.FirstDate,Scheduler.DateNavigator.LastDate);

  end;
  AylikTus.Click;//   clSpeedButton1.Click;
end;

type hh = class(TcxCustomSchedulerStorage)

end;

procedure TTakvimDlg.TusBasildi(Tus : TToolButton);
var i : SmallInt;
begin
   for i := 0 to ComponentCount - 1 do
       if Components[i] is TToolButton then begin
          if TToolButton(Components[i]) = Tus then
             TToolButton(Components[i]).Down := True
          else
             TToolButton(Components[i]).Down := False;
       end;
end;

procedure TTakvimDlg.AylikTusClick(Sender: TObject);
begin
   AylikHaftalikGunluk := TMenuItem(Sender).Tag;
   TusBasildi(TToolButton(Sender));
   ZamanSecildi;
end;

procedure TTakvimDlg.ZamanSecildi;
begin
//  if not Scheduler.ViewWeek.Active then
//    AnchorDate := Scheduler.SelectedDays[0];
//  Scheduler.SelectDays([AnchorDate], TMenuItem(Sender).Tag in [0, 1]);
if PageControl.ActivePage=TabSheetTakvim then begin
  case AylikHaftalikGunluk of
    0: Scheduler.ViewDay.Active := True;
    1: Scheduler.SelectWorkDays(Date);
    2: Scheduler.ViewWeek.Active := True;
    3: Scheduler.GoToDate(Scheduler.SelectedDays[0], vmMonth);
    4: Scheduler.ViewTimeGrid.Active := True;
    5: Scheduler.ViewYear.Active := True;
  end;
end else if PageControl.ActivePage=TabSheetPivot then begin
    TabPivot.Close;
    case AylikHaftalikGunluk  of
      0: TabPivot.SQL.Text := 'select * from [dbo].[fn_NakitAkisiPivot](:PSonTarih)'; //günlük
      2: TabPivot.SQL.Text := 'select * from [dbo].[fn_NakitAkisiPivot_Haftalik](:PSonTarih)'; //hafta
      3: TabPivot.SQL.Text := 'select * from [dbo].[fn_NakitAkisiPivot_Aylik](:PSonTarih)'; //ay
    end;
    TabloYenile(TabPivot,[LabelBittar.Date]);
end else begin
  if TabGrafik.Active then begin
    TabGrafik.Close;
    case AylikHaftalikGunluk  of
       0:TabGrafik.SQL.Text:='select * from GRAFIKPLAN_SPID ORDER by TARIH';
       2:TabGrafik.SQL.Text:='Select * from GRAFIKPLAN_SPID Where datename(dw,TARIH)=''Sunday'' order by TARIH  ';//Pazar günlerini listelele
       3:TabGrafik.SQL.Text:='select GUN,AY,BAKIYE,TARIH,'+DbConv('DATEADD(dd,-(DAY(DATEADD(mm,1,TARIH))),DATEADD(mm,1,TARIH))','VARCHAR(10)',112)+'  from GRAFIKPLAN_SPID'+
         ' Where TARIH='+DbConv('DATEADD(dd,-(DAY(DATEADD(mm,1,TARIH))),DATEADD(mm,1,TARIH))','VARCHAR(10)',112)+' and TARIH >='''+FormatDateTime('yyyy-mm-dd 00:00',TakvimAksiyonlar.DateGrafikBasTar.Date)+'''  and TARIH <= '''+FormatDateTime('yyyy-mm-dd 00:00',TakvimAksiyonlar.DateGrafikBitTar.Date)+''' '+
         ' Order by TARIH';
    end;
    TabloYenile(TabGrafik,[]);
   GridGrafikDBChartView.DiagramColumn.AxisValue.GridLines := true; // grid çizgileri
   GridGrafikDBChartView.DiagramColumn.AxisValue.TickMarkLabels := true; // Altta ayları gösterir
   GridGrafikDBChartView.DiagramColumn.Values.CaptionPosition := cdvcpOutsideEnd; // üstte değerlerinin görünmesini sağlar
  end;
end;

end;
function TTakvimDlg.EkranAdiAl: string;
begin
  Result := 'TakvimDlg'+IntToStr(PageControl.ActivePage.Tag);
end;

procedure TTakvimDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxTAKVIM) then
      AFastReport.EnabledDataSets.Add(frxTAKVIM)
   else begin
      case PageControl.ActivePage.Tag of
        1 : begin //takvin nakit akışı
              TabloAc(TAKVIM, Scheduler.DateNavigator.SelectionList.Items[0] , Scheduler.DateNavigator.SelectionList.Items[Scheduler.DateNavigator.SelectionList.Count-1]);
              frxTAKVIM.DataSet := TAKVIM;
              frxTAKVIM.UserName := 'TAKVIM';
            end;
        4 : begin //takvin nakit akışı
              frxTAKVIM.DataSet := LISTE;
              frxTAKVIM.UserName := 'LISTE';
            end;
      end;
      AFastReport.EnabledDataSets.Add(frxTAKVIM);
   end;
end;

procedure TTakvimDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   if TabTakvim.Active then begin
       s := YaziciYaz.Caption;
       Delete(s, pos('&',s), 1);
       YazdirmayaHazirla(FastRaporDlg.frxReport1);
       FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
   end;
end;

procedure TTakvimDlg.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

   Tablo.GridTurkcelestir;

   Tablo.GridAyarRestore('TakvimListeGridi', GridListeView);

   PageControl.ActivePageIndex:=0;
   PageControlChange(Self);
   AylikHaftalikGunluk:=3;

  if PageControl.ActivePage=TabSheetTakvim then begin
    TakvimAksiyonlar.DateTakvimBasTar.Visible:=True;
    TakvimAksiyonlar.DateTakvimBitTar.Visible:=True;
    TakvimAksiyonlar.DateGrafikBasTar.Visible:=False;
    TakvimAksiyonlar.DateGrafikBitTar.Visible:=False;
  end else if PageControl.ActivePage=TabSheetGrafik then begin
    TakvimAksiyonlar.DateGrafikBasTar.Visible:=True;
    TakvimAksiyonlar.DateGrafikBitTar.Visible:=True;
    TakvimAksiyonlar.DateTakvimBasTar.Visible:=False;
    TakvimAksiyonlar.DateTakvimBitTar.Visible:=False;
  end;
  DateTimeListeBitis.Date := Tablo.GENINI.BugunTrh+7;
end;

procedure TTakvimDlg.TakvimSil(Tur,ID:Integer);
var   Trh : TDateTime;
begin
      if Tur in [21..39] then begin
        Tablo.Query1.Close;
        if Tur in [23,33] then
           Tablo.Query1.SQL.Text := 'select TARIH from CEKLER where ID='+IntToStr(ID)
        else if Tur in [24,34] then
           Tablo.Query1.SQL.Text := 'select TARIH from SENETLER where ID='+IntToStr(ID)
        else
           Tablo.Query1.SQL.Text := 'select ISLEMTARIHI from KASA where ID='+IntToStr(ID);
        Tablo.Query1.Open;
        Trh := Tablo.Query1.Fields[0].AsDateTime;
      end
      else
        Trh := Scheduler.SelStart;

     case Tur of
       10,11,12,13,14,15,16,17,21,22,23,24,25,31,32,33,34,35:begin
           if Tur in [11,15] then begin
           if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+IntToStr(ID)+' ',[],[]) then begin
             if  Application.MessageBox(PCHAR(TFaturaPlanliSilinsinmi),PChar(Uyari),MB_YESNO)=mrNo then begin
               Abort;
             end;
           end;
         end;
       end;
     end;
     Tablo.KasaSilmeIslemleri(ID, Tur);
end;

procedure TTakvimDlg.SilMenuClick(Sender: TObject);
var
   ID, Tur : Integer;
   selectedEvent : TcxSchedulerControlEvent;
begin
   if Scheduler.SelectedEventCount = 0 then Exit;
   if Application.MessageBox(PCHAR(TAksiyonsil), PCHAR(Onay), MB_YESNO) = IDYES then begin
      selectedEvent := Scheduler.SelectedEvents[0];
      ID := selectedEvent.GetCustomFieldValueByName('ID2');
      Tur := StrToInt(selectedEvent.GetCustomFieldValueByName('TUR'));
      TakvimSil(Tur,ID);

      FTakvimAksiyonlar.YenileTus.Click;
   end;
end;

procedure TTakvimDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTakvimDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTakvimDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTakvimDlg.BilgileriDegisMenuClick(Sender: TObject);
var ID, BELGENO : String[15];
    Tur : SmallInt;
    s : string;
    RehberId : Integer;
var Trh : TDateTime;
    selectedEvent : TcxSchedulerControlEvent;
begin
   if Scheduler.SelectedEventCount = 0 then Exit;
   selectedEvent := Scheduler.SelectedEvents[0];
   ID := selectedEvent.GetCustomFieldValueByName('ID2');
   Tur := selectedEvent.GetCustomFieldValueByName('TUR');
   RehberId:= selectedEvent.GetCustomFieldValueByName('REHBERID');

   if Tur in [21..39,130..149] then begin
      Tablo.Query1.Close;
      if Tur in [23,33,130..149] then
         Tablo.Query1.SQL.Text := 'select TARIH, MAKBUZNO from CEKLER where ID='+ID
      else if Tur in [24,34] then
         Tablo.Query1.SQL.Text := 'select TARIH, MAKBUZNO from SENETLER where ID='+ID
      else
         Tablo.Query1.SQL.Text := 'select ISLEMTARIHI, BELGENO from KASA where ID='+ID;
      Tablo.Query1.Open;
      Trh := Tablo.Query1.Fields[0].AsDateTime;
      BELGENO := Tablo.Query1.Fields[1].AsString;
   end
   else
      Trh := Scheduler.SelStart;

   AnaForm.GormeDialogCagir(StrToInt(ID), Tur, RehberId, 0,Trh, BELGENO);
   FTakvimAksiyonlar.YenileTus.Click;
end;

procedure TTakvimDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TTakvimDlg.TabloAc(var Tablo1 : TFDQuery; BasTarih, BitTarih : TDateTime);
var s, tarih,Tbas,Tbit : String;
  I,J: Integer;
  procedure             Ekle(Komut : String);
  begin
     if I>J then begin
        J:=I;
        Tablo1.SQL.Add(' Union All ');
     end;
     Tablo1.SQL.Text := Tablo1.SQL.Text + Komut;
     inc(I);
  end;
begin
   FTakvimAksiyonlar.GiderFiltreCheck.Visible := FTakvimAksiyonlar.CheckGroupSecim.ItemIndex = 0;
   Tablo1.Close;
   Tablo1.SQL.Text := MemoBaslangic.Text;
   I:=0;
   J:=0;
   case FTakvimAksiyonlar.CheckGroupSecim.itemindex of
     0:begin//Tablo1.SQL.Text:= Tablo1.SQL.Text+MemoPlan.Lines.Text);
         if FTakvimAksiyonlar.GiderFiltreCheck.States[0]=cbsChecked then   //Odeme Plan Kasa
            Ekle(MemoTakvimOdemePlan.Lines.Text);
         if FTakvimAksiyonlar.GelirFiltreCheck.States[0]=cbsChecked then //Tahsilat Plan Kasa
            Ekle(MemoTakvimTahsilatPlan.Lines.Text);
         if FTakvimAksiyonlar.GiderFiltreCheck.States[1]=cbsChecked then //KK
            Ekle(MemoTakvimPlanKK.Lines.Text);
         if FTakvimAksiyonlar.GiderFiltreCheck.States[2]=cbsChecked then //Çekimiz
            Ekle(MemoTakvimCekKendi.Lines.Text);
         if FTakvimAksiyonlar.GelirFiltreCheck.States[2]=cbsChecked then //Müşteri Çek
            Ekle(MemoTakvimCekMusteri.Lines.Text);
         if FTakvimAksiyonlar.GiderFiltreCheck.States[3]=cbsChecked then //Senetimiz
            Ekle(MemoTakvimSenetKendi.Lines.Text);
         if FTakvimAksiyonlar.GelirFiltreCheck.States[3]=cbsChecked then //Müşteri Senet
            Ekle(MemoTakvimSenetMusteri.Lines.Text);
         if FTakvimAksiyonlar.GiderFiltreCheck.States[6]=cbsChecked then //Maaş
            Ekle(MemoPlanMaas.Lines.Text);
         if FTakvimAksiyonlar.GiderFiltreCheck.States[5]=cbsChecked then //Kredi
            Ekle(MemoPlanKredi.Lines.Text);
         if FTakvimAksiyonlar.GiderFiltreCheck.States[4]=cbsChecked then //Gider Bütçe
            Ekle(MemoTakvimGider.Lines.Text);
         if FTakvimAksiyonlar.GelirFiltreCheck.States[4]=cbsChecked then //Gelir Bütçe
            Ekle(MemoTakvimGelir.Lines.Text);
         if FTakvimAksiyonlar.GelirFiltreCheck.States[1]=cbsChecked then //POS
            Ekle(MemoTakvimPOS.Lines.Text);
       end;
     1: Tablo1.SQL.Text:= Tablo1.SQL.Text+MemoFatura.Lines.Text;
     2: Tablo1.SQL.Text:= Tablo1.SQL.Text+MemoOdeme.Lines.Text;
   end;
   if Tablo1.Name = 'TAKVIM' then
      Tablo1.SQL.add(' ORDER BY YON DESC, 2 ASC')
   else
      Tablo1.SQL.add(' ORDER BY 2 ');
   Tbas:=FormatDateTime('yyyy-MM-dd', BasTarih);
   Tbit:=FormatDateTime('yyyy-MM-dd', BitTarih);
   Tablo1.SQL.add(' select * from ##TAKVIM_SPID_');
   Tablo1.SQL.Text := StringReplace(Tablo1.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
   Tablo1.SQL.Text := StringReplace(Tablo1.SQL.Text, '2020-01-01', Tbit, [RFrEPLACEaLL]) ;
   Tablo1.SQL.Text := StringReplace(Tablo1.SQL.Text, '2010-01-01', Tbas, [RFrEPLACEaLL]) ;
   Tablo1.Open;
   TabToplam.Close;
   TabToplam.SQL.Text := StringReplace(TabToplam.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
//   TabToplam.Params[0].value := FormatDateTime('yyyy-MM-dd 00:00', BasTarih);
//   TabToplam.Params[1].value := FormatDateTime('yyyy-MM-dd 00:00', BitTarih);
//   TabToplam.Open;
   TabloYenile(TabToplam,[FormatDateTime('yyyy-MM-dd 00:00', BasTarih),FormatDateTime('yyyy-MM-dd 00:00', BitTarih)]);
end;

procedure TTakvimDlg.ToolButton2Click(Sender: TObject);
var Trh : TDateTime;
begin
 // Trh := Scheduler.SelStart;

  if GunlukTakvimDlg = nil then
     Application.CreateForm(TGunlukTakvimDlg, GunlukTakvimDlg);
  GunlukTakvimDlg.Tarih :=Tablo.GENINI.BugunTrh;// Trh;// .RealFirstDate;// Date;
  GunlukTakvimDlg.InitIslemler;
  GunlukTakvimDlg.Caption:='Varlıklar';
  GunlukTakvimDlg.Width:=373;
  GunlukTakvimDlg.AutoSize:=True;
  GunlukTakvimDlg.ShowModal;
end;

procedure TTakvimDlg.YenileTusClick(Sender: TObject);
begin
   if PageControl.ActivePage=TabSheetTakvim then
     TabloAc(TabTakvim, FTakvimAksiyonlar.DateTakvimBasTar.Date, FTakvimAksiyonlar.DateTakvimBitTar.Date)
   else begin
     if TakvimAksiyonlar.CheckGroupSecim.ItemIndex = 0 then
      GrafikOlustur;
   end;
end;

procedure TTakvimDlg.GridListeViewCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridListe;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridListeView;
  //AnaForm.pmGridStil.Tags.Values[GridListe.Name] := 'TakvimListeGridi';
end;

initialization
  Classes.RegisterClass(TTakvimDlg);

end.






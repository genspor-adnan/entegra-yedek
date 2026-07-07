unit UKasalarListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 02/03/2010 16:36:27}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls,Utablo,
  UKasalarAramaFrame, cxStyles, dxSkinsCore,  dxSkinscxPCPainter, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit, cxCalendar,
  cxCheckBox, cxMemo, cxPC, cxSplitter, frxClass, frxDBSet,
  dxSkinLondonLiquidSky,DateUtils, dxSkinBlack, dxSkinBlue, dxSkinCoffee,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin,
  dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, dxSkinCaramel,
  dxSkinDarkRoom, dxSkinOffice2007Blue, dxSkinSummer2008, cxLookAndFeels,
  cxNavigator, cxPCdxBarPopupMenu, dxCore, cxDateUtils, JvExControls,
  JvNavigationPane, cxDBEdit, cxLabel, dxBarBuiltInMenu, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxDateRanges,
  dxScrollbarAnnotations, frCoreClasses;

type
  TKasalarListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog)
    DtsKasalar: TDataSource;
    KASALAR: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    ToolButton3: TToolButton;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridTviewID: TcxGridDBColumn;
    GridTviewKASAKODU: TcxGridDBColumn;
    GridTviewKASAADI: TcxGridDBColumn;
    GridTviewKUR: TcxGridDBColumn;
    GridTviewDURUM: TcxGridDBColumn;
    GridTviewGIREN: TcxGridDBColumn;
    GridTviewCIKAN: TcxGridDBColumn;
    GridTviewKALAN: TcxGridDBColumn;
    cxSplitter1: TcxSplitter;
    PageControlSekme: TcxPageControl;
    TabSheetEkstre: TcxTabSheet;
    GridKasaEkstre: TcxGrid;
    GridKasaEkstreView: TcxGridDBTableView;
    GridKasaEkstreViewTARIH: TcxGridDBColumn;
    GridKasaEkstreViewAKSIYONTARIH: TcxGridDBColumn;
    GridKasaEkstreViewNO: TcxGridDBColumn;
    GridKasaEkstreViewTUR: TcxGridDBColumn;
    GridKasaEkstreViewKOD: TcxGridDBColumn;
    GridKasaEkstreViewAD: TcxGridDBColumn;
    GridKasaEkstreViewACIKLAMA: TcxGridDBColumn;
    GridKasaEkstreViewHESAPKODU: TcxGridDBColumn;
    GridKasaEkstreViewHESAPADI: TcxGridDBColumn;
    GridKasaEkstreViewKUR: TcxGridDBColumn;
    GridKasaEkstreViewBORC: TcxGridDBColumn;
    GridKasaEkstreViewALACAK: TcxGridDBColumn;
    GridKasaEkstreViewBORCBAKIYE: TcxGridDBColumn;
    GridKasaEkstreViewALACAKBAKIYE: TcxGridDBColumn;
    GridKasaEkstreDBTableView1: TcxGridDBTableView;
    GridKasaEkstreDBTableView1DURUM: TcxGridDBColumn;
    GridKasaEkstreDBTableView1VADE: TcxGridDBColumn;
    GridKasaEkstreDBTableView1SERINO: TcxGridDBColumn;
    GridKasaEkstreDBTableView1HESAPADI: TcxGridDBColumn;
    GridKasaEkstreDBTableView1Column1: TcxGridDBColumn;
    GridKasaEkstreLevel1: TcxGridLevel;
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
    EKSTRE: TFDQuery;
    DtsCariListe: TDataSource;
    frxEkstre: TfrxDBDataset;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    KasaListeMenu: TPopupMenu;
    AcilisKaydiMenu: TMenuItem;
    DevirFiiGir1: TMenuItem;
    MenuItem2: TMenuItem;
    N4: TMenuItem;
    AksiyonlarMenu: TPopupMenu;
    ExceleAktar1: TMenuItem;
    MenuItem3: TMenuItem;
    Ekle1: TMenuItem;
    Sil1: TMenuItem;
    AksiyonBilgisiniGorMenu: TMenuItem;
    frxKasa: TfrxDBDataset;
    GridTviewSUBEID: TcxGridDBColumn;
    SqlMemo: TMemo;
    N5: TMenuItem;
    AksMenu: TMenuItem;
    AksiyonTus: TToolButton;
    Panel1: TPanel;
    ToolBar11: TToolBar;
    YaziciYaz: TToolButton;
    JvNavPanelHeader2: TJvNavPanelHeader;
    CalendarEkstreBit: TcxDateEdit;
    Label2: TLabel;
    CalendarEkstreBas: TcxDateEdit;
    Label1: TLabel;
    CbNakitVarlikTipi: TcxImageComboBox;
    Label3: TLabel;
    N6: TMenuItem;
    KopyalaMenu: TMenuItem;
    GridKasaEkstreViewYERELKUR: TcxGridDBColumn;
    GridKasaEkstreViewYERELTUTAR: TcxGridDBColumn;
    GridKasaEkstreViewYERELBAKIYE: TcxGridDBColumn;
    cxTabSheet1: TcxTabSheet;
    cxLabel1: TcxLabel;
    cxDBCurrencyEdit1: TcxDBCurrencyEdit;
    cxDBCurrencyEdit2: TcxDBCurrencyEdit;
    cxLabel4: TcxLabel;
    cxDBCurrencyEdit3: TcxDBCurrencyEdit;
    cxLabel6: TcxLabel;
    cxDBCurrencyEdit4: TcxDBCurrencyEdit;
    cxLabel8: TcxLabel;
    TOPLAMLAR: TFDQuery;
    DtsTOPLAMLAR: TDataSource;
    PopupMenuBakiye: TPopupMenu;
    MenuItem1: TMenuItem;
    KurFarkGeliri1: TMenuItem;
    KurFarkGideri1: TMenuItem;
    N8: TMenuItem;
//    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure KasaYenileTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure GridTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure PageControlSekmeChange(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure KASALARAfterOpen(DataSet: TDataSet);
    procedure AcilisKaydiMenuClick(Sender: TObject);
    procedure KasaInfoMenuClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridKasaEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridKasaEkstreViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure TabSheetEkstreShow(Sender: TObject);
    procedure KASALARBeforeDelete(DataSet: TDataSet);
    procedure YenileTusClick;
    procedure AksiyonTusClick(Sender: TObject);
    procedure Ekle1Click(Sender: TObject);
    procedure AksiyonBilgisiniGorMenuClick(Sender: TObject);
    procedure KopyalaMenuClick(Sender: TObject);
    procedure AksiyonlarMenuPopup(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure KurFarkGeliri1Click(Sender: TObject);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TKasalarAramaFrame;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    function EkranAdiAl: string;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    procedure SetArama(const Value: TKasalarAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

  public
    { Public declarations }
  published
    property Arama      : TKasalarAramaFrame read FArama write SetArama;
  end;

implementation

uses ULog, UAnaForm,FetaKurulusSiniflari, FetaClassExtensions,  UKasaTanimWizard,
  UKasaWizard, PrjConst, UFastRap, URaporAraclari, UGenelAnaSekmeFrame,LocOnFly;

{$R *.dfm}

{ TKasalarListeFrame }

procedure TKasalarListeFrame.AcilisKaydiMenuClick(Sender: TObject);
begin
    if Tablo.AcilisiFisiEkraniBaslat(2,TMenuItem(Sender).Tag, KASALAR.FieldByname('ID').AsString,KASALAR.FieldByname('KASAKODU').AsString,KASALAR.FieldByname('KASAADI').AsString,KASALAR.FieldByName('KUR').AsString, 0,Tablo.GENINI.BugunTrhSaat) then
       PageControlSekmeChange(Self);
end;

procedure TKasalarListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
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
      frxKASA.DataSet := KASALAR;
      AFastReport.EnabledDataSets.Add(frxKASA);
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TKasalarListeFrame.Ekle1Click(Sender: TObject);
var Sonuc ,RehberId: Integer;
begin
{  RehberId := Tablo.RehberAra_IDGetir(-99);
  if RehberId = 0 then
    Exit;
  Sonuc := Tablo.KasaSihirbazBaslat('E', -1,-1, 0, RehberId, Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat,1,0,'','');
  case Sonuc of
    9,19:  Tablo.SiparisSihirbazBaslat('E', Sonuc,-1, -1, RehberId);
    10,11,12,14,15,16 : Tablo.FaturaSihirbazBaslat('E', Sonuc,-1, -1, RehberId);
    13,17 : Tablo.TahakkukSihirbaziBaslat('E', Sonuc,0, -1, RehberId, Tablo.GENINI.BugunTrhSaat);
    20..39: Tablo.MakbuzSihirbazBaslat('E', Sonuc,0, -1, RehberId, Tablo.GENINI.BugunTrhSaat, '');
  end;
  if (PageControlSekme.ActivePage = TabSheetEkstre)  then
      PageControlSekmeChange(Self);
  YenileTusClick; }
  AksiyonTusClick(Self);
end;

function TKasalarListeFrame.EkranAdiAl: string;
begin
   Result := 'KasaListeDlg'; //  'CariDlg'   'RehberAraDlg';
end;

procedure TKasalarListeFrame.AksiyonBilgisiniGorMenuClick(Sender: TObject);
var
  srid, Sonuc:integer;
begin
//   if EKSTRE.FieldByName('TUR').AsInteger in [1,2] then
//      Tablo.AcilisiFisiEkraniBaslat(2, EKSTRE.FieldByName('TUR').AsInteger, KASALAR.FieldByname('ID').AsString,KASALAR.FieldByname('KASAKODU').AsString,KASALAR.FieldByname('KASAADI').AsString,KASALAR.FieldByName('KUR').AsString, EKSTRE.FieldByName('CEKID').AsInteger);
   srid:=GridKasaEkstreView.DataController.FocusedRecordIndex;

   if EKSTRE.FieldByName('TUR').AsInteger in [1,2] then
      Tablo.AcilisiFisiEkraniBaslat(2,EKSTRE.FieldByName('TUR').AsInteger, KASALAR.FieldByname('ID').AsString,KASALAR.FieldByname('KASAKODU').AsString,KASALAR.FieldByname('KASAADI').AsString,
            KASALAR.FieldByname('KUR').AsString,EKSTRE.FieldByname('CEKID').AsInteger,EKSTRE.FieldByName('TARIH').AsDateTime)
   else
      Sonuc := AnaForm.GormeDialogCagir(EKSTRE.FieldByName('CEKID').AsInteger, EKSTRE.FieldByName('TUR').AsInteger,
           EKSTRE.FieldByName('HESAPID').AsInteger, 3, EKSTRE.FieldByName('TARIH').AsDateTime, EKSTRE.FieldByName('NO').AsString);
   CalendarEkstreBasPropertiesEditValueChanged(Self);
   if Sonuc = -99 then //iptal ise tekrar konumlans�n
      GridKasaEkstreView.DataController.FocusedRecordIndex:=srid;
end;

procedure TKasalarListeFrame.AksiyonlarMenuPopup(Sender: TObject);
begin
  KopyalaMenu.Visible := EKSTRE.FieldByName('TUR').AsInteger in [21,31];
end;

procedure TKasalarListeFrame.AksiyonTusClick(Sender: TObject);
var Tur : smallint;
    HesapTuru : Char;
    Tarih:TDateTime;
begin
  Tarih:=Tablo.GENINI.BugunTrhSaat;
  Tur:= Tablo.KasaSihirbazBaslat('E', -1, -1, 0, -1, Tarih, Tarih, 3, 0, 'TL','', 0, 0);
  case Tur of
    21,31: Tablo.NakitSihirbazBaslat('K','E', Tur,3, -1, -1, Tarih, '-1');
    113,117 : Tablo.TahakkukSihirbaziBaslat('E', Tur-100,3, KASALAR.Fields[0].AsInteger, KASALAR.Fields[0].AsInteger, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', Tarih)));
    121,131,122,132 : begin
       // masrafta cari seçilmez yani rehberid sıfırdır
       if Tur in [121,131] then HesapTuru := 'K'
       else HesapTuru := 'B';
       Dec(Tur,100);
       Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,3, -1, 0, Tarih, '-1',False,0, KASALAR.Fields[0].AsInteger);
    end;
  end;
  TabloYenile( KASALAR,[]);
  PageControlSekmeChange(Self);
end;

procedure TKasalarListeFrame.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s)
end;

procedure TKasalarListeFrame.Baslatildi;
var ra : string;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  GridTviewSUBEID.Visible := SubeVarmi;
  PageControlSekme.ActivePageIndex:=0;
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
  TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;

  DegisTus.visible := KASALAR.Active;
  SilTus.visible := DegisTus.visible;

  CalendarEkstreBas.Date := Tablo.GENINI.BugunTrh;
  CalendarEkstreBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));

 // GridTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasalarListeGridi',true,false,[gsoUseFilter],'KasalarListeGridi');
  Tablo.GridAyarRestore('KasalarListeGridi',GridTview );

  //GridKasaEkstreView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasalarExtreGridi',true,false,[gsoUseFilter],'KasalarExtreGridi');
  Tablo.GridAyarRestore('KasalarExtreGridi',GridKasaEkstreView );



  Tablo.GridTurkcelestir;
  GridKasaEkstreViewYERELTUTAR.Visible := DovizTakibi;
  GridKasaEkstreViewYERELKUR.Visible := DovizTakibi;
  GridKasaEkstreViewYERELBAKIYE.Visible := DovizTakibi;
end;


procedure TKasalarListeFrame.CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
begin
  if (PageControlSekme.ActivePage = TabSheetEkstre)and(KASALAR.Active)and(KASALAR.RecordCount>0)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
    case CbNakitVarlikTipi.EditValue of
    -1 : EKSTRE.SQL.Text := 'select * from dbo.fn_Kasa_Hediye_Ekstre ' ;//hediye
    -2 : EKSTRE.SQL.Text := 'select * from dbo.fn_Kasa_Iade_Ekstre ';//iade
     0 :if SQLVersion2008 then
             EKSTRE.SQL.Text := ' select * from dbo.fn_Kasa_Nakit_Ekstre '//nakit
          else begin
             EKSTRE.SQL.Text := ' EXEC Sp_Prg_KasaNakitEkstre '+KASALAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''' ';
             TabloYenile(EKSTRE,[]);
             exit;
           end;
    else begin//Kuponlar
          if SQLVersion2008 then
             EKSTRE.SQL.Text := 'select * from dbo.fn_Kasa_Kupon_Ekstre '+
               '('+KASALAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''','+IntToStr(CbNakitVarlikTipi.EditValue)+')'
          else
             EKSTRE.SQL.Text := ' EXEC Sp_Prg_KasaKuponEkstre '+KASALAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''','+IntToStr(CbNakitVarlikTipi.EditValue);
          TabloYenile(EKSTRE,[]);
          exit;
         end;
    end;
    EKSTRE.SQL.Add('('+KASALAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''')');
    EKSTRE.SQL.Add('order by KUR,TARIH');
    TabloYenile(EKSTRE,[]);
  end;
end;

procedure TKasalarListeFrame.GridKasaEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridKasaEkstre;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridKasaEkstreView;
  AnaForm.pmGridStil.Tags.Values[GridKasaEkstre.Name]:='KasalarExtreGridi';
end;

procedure TKasalarListeFrame.GridKasaEkstreViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKasalarListeFrame.TabSheetEkstreShow(Sender: TObject);
begin
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TKasalarListeFrame.DegisTusClick(Sender: TObject);
var
srid:integer;
begin
  if GridTview.Controller.SelectedRecordCount > 0 then
  begin
    srid:=GridTview.DataController.FocusedRecordIndex;
     if Tablo.KasaTanimSihirbazBaslat('D', 0, KASALAR.Fields[0].AsInteger) > 0 then begin
        YenileTusClick;
     end;
    GridTview.DataController.FocusedRecordIndex:=srid;
    GridTview.ViewData.Records[srid].Selected := false;
  end;
end;
procedure TKasalarListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TKasalarListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasalarListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKasalarListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKasalarListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TKasalarListeFrame.Gorunmez;
begin

end;

procedure TKasalarListeFrame.GorunmezOlacak;
begin

end;

procedure TKasalarListeFrame.Gorunur;
begin
  TabloYenile(KASALAR,[]);
end;

procedure TKasalarListeFrame.GorunurOlacak;
begin

end;

procedure TKasalarListeFrame.KasaYenileTusClick(Sender: TObject);
begin
   YenileTusClick;
//   TabloYenile(KASALAR,[]);
   KASALAR.first;
   while not KASALAR.eof do begin
      TabloYenile(TOPLAMLAR,[KASALAR.Fields[0].AsInteger,KASALAR.Fields[0].AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASALAR set BAKIYE = &Bak where ID=&ID ',['&Bak','&ID'],[StringReplace(TOPLAMLAR.FieldByName('BAKIYE').AsString,',','.',[]),KASALAR.FieldByName('ID').AsInteger]);
      KASALAR.next;
   end;
   //TabloYenile(KASALAR,[]);
   YenileTusClick;
end;


procedure TKasalarListeFrame.GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
  AnaForm.pmGridStil.Tags.Values[cxGrid.Name]:='KasalarListeGridi';
end;

procedure TKasalarListeFrame.GridTviewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   PageControlSekmeChange(Self);
end;

procedure TKasalarListeFrame.GridTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKasalarListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TKasalarListeFrame.PageControlSekmeChange(Sender: TObject);
begin
   if PageControlSekme.ActivePage = TabSheetEkstre then
      CalendarEkstreBasPropertiesEditValueChanged(Self)
   else
      TabloYenile(TOPLAMLAR,[KASALAR.Fields[0].AsInteger,KASALAR.Fields[0].AsInteger]);
end;

procedure TKasalarListeFrame.SetArama(const Value: TKasalarAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
    YenileTusClick;
    DegisTus.visible := KASALAR.RecordCount > 0;
  end;
end;

procedure TKasalarListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKasalarListeFrame.Sil1Click(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Tablo.KasaSilmeIslemleri(EKSTRE.FieldByName('CEKID').AsInteger, EKSTRE.FieldByName('TUR').AsInteger, EKSTRE.FieldByName('AKSIYONTARIH').AsDateTime);
      PageControlSekmeChange(Self);
      TabloYenile( KASALAR,[]);
   end;
end;

procedure TKasalarListeFrame.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
     //Önce açılış kaydı harici girilmiş bilgi var mı
     Tablo.Query4.Close;
     Tablo.Query4.SQL.Text := 'Select top 1 ISLEMTARIHI From KASA Where HESAPTURU=''K'' AND HESAPID = '+ KASALAR.Fields[0].AsString+' AND TUR<>1';
     Tablo.Query4.Open;

     if Tablo.Query4.RecordCount> 0 then
       raise Exception.Create(FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', Tablo.Query4.fields[0].AsDateTime)+' tarihinde girilmiş kasa bilgisi var, silinemez...')
     else begin//yoksa açılış kaydını silelim
       Tablo.Query4.Close;
       Tablo.Query4.SQL.Text := 'delete From KASA Where HESAPTURU=''K'' AND HESAPID = '+ KASALAR.Fields[0].AsString+' AND TUR=1';
       Tablo.Query4.ExecSQL;
       KASALAR.Delete;
     end;
  end;
end;

procedure TKasalarListeFrame.KASALARAfterOpen(DataSet: TDataSet);
begin
   DegisTus.Visible   := KASALAR.RecordCount>0;
   SilTus.Visible := DegisTus.Visible;
end;

procedure TKasalarListeFrame.KASALARBeforeDelete(DataSet: TDataSet);
begin
  LogKartSil(KASALAR, TabNo_KASATANIM, KASALAR.FieldByName('ID').AsInteger);   // kasa TANIMI (KASALAR)
end;

procedure TKasalarListeFrame.KasaInfoMenuClick(Sender: TObject);
begin
  if not KASALAR.IsEmpty then
    Tablo.InfoGoster('KASALAR', KASALAR.FieldByName('ID').AsInteger, TabNo_KASATANIM);
end;

procedure TKasalarListeFrame.KopyalaMenuClick(Sender: TObject);
Var IDsi : integer;
begin
   IDsi := Tablo.SQLSatiriKopyala('KASA', EKSTRE.FieldByName('CEKID').AsInteger,[ 'ISLEMTARIHI', 'BELGENO','EKLEYEN', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
            [ Tablo.GENINI.BugunTrhSaat,  '0' ,Kullanan, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);

   case EKSTRE.FieldByName('TUR').AsInteger of
     21, 31 : IDsi := Tablo.NakitSihirbazBaslat('K','K', EKSTRE.FieldByName('TUR').AsInteger,3,
              IDsi,EKSTRE.FieldByName('HESAPID').AsInteger, Tablo.GENINI.BugunTrhSaat,'0',False, -1, EKSTRE.FieldByName('REHBERID').AsInteger );
   end;
   CalendarEkstreBasPropertiesEditValueChanged(Self);
   YenileTusClick;
end;

procedure TKasalarListeFrame.KurFarkGeliri1Click(Sender: TObject);
begin
   Tablo.NakitSihirbazBaslat('K','E', TMenuItem(Sender).Tag,4, -1, 0, Tablo.GENINI.BugunTrhSaat, '-1',False,0, KASALAR.Fields[0].AsInteger);
   CalendarEkstreBasPropertiesEditValueChanged(Self);
end;

procedure TKasalarListeFrame.Label1Click(Sender: TObject);
begin
   CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
end;

procedure TKasalarListeFrame.MenuItem1Click(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASALAR set BAKIYE = &Bak where ID=&ID ',['&Bak','&ID'],[StringReplace(TOPLAMLAR.FieldByName('BAKIYE').AsString,',','.',[]),KASALAR.FieldByName('ID').AsInteger]);
   YenileTusClick;
end;

procedure TKasalarListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKasalarListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKasalarListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKasalarListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKasalarListeFrame.YeniTusClick(Sender: TObject);
begin
   if Tablo.KasaTanimSihirbazBaslat('E', 0, -1) > 0 then
      YenileTusClick;
end;

procedure TKasalarListeFrame.YenileTusClick;
begin
   KASALAR.Close;
   KASALAR.SQL.Text:=SqlMemo.Text;
   if SubeVarmi then begin
      if FArama.ComboSube.EditValue >= 0 then
         KASALAR.SQL.Add(' and SUBEID in('+Tablo.YetkiliSubeleriGetir(23,YetkiTur_Gorme)+') ')
      else
         KASALAR.SQL.add(' and SUBEID ='+IntToStr(FArama.ComboSube.EditValue)+' ');
   end;
   KASALAR.SQL.Add(' order by KASAKODU');
   TabloYenile(KASALAR,[]);
end;

initialization
  RegisterClass(TKasalarListeFrame);
end.




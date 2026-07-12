unit UBankalarListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 21/02/2010 23:05:30}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls,
  UBankalarAramaFrame, cxStyles, dxSkinsCore,  dxSkinscxPCPainter, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxImageComboBox, cxCurrencyEdit, cxSplitter, cxDropDownEdit,
  cxCalendar, cxCheckBox, cxPC, frxClass, frxDBSet, dxSkinLondonLiquidSky, Utablo, dxSkinLiquidSky,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxCore, cxDateUtils,
  JvExControls, JvNavigationPane, cxDBEdit, cxLabel, dxBarBuiltInMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, cxGridExportLink;

type
  TBankalarListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsBankalar: TDataSource;
    BANKALAR: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridTviewBANKAADI: TcxGridDBColumn;
    GridTviewSUBEADI: TcxGridDBColumn;
    GridTviewHESAPKODU: TcxGridDBColumn;
    GridTviewHESAPADI: TcxGridDBColumn;
    GridTviewHESAPNO: TcxGridDBColumn;
    GridTviewKUR: TcxGridDBColumn;
    GridTviewTIPI: TcxGridDBColumn;
    GridTviewDURUM: TcxGridDBColumn;
    SilTus: TToolButton;
    ToolButton2: TToolButton;
    PageControlSekme: TcxPageControl;
    TabSheetEkstre: TcxTabSheet;
    GridBankaEkstre: TcxGrid;
    GridBankaEkstreView: TcxGridDBTableView;
    GridBankaEkstreViewTARIH: TcxGridDBColumn;
    GridBankaEkstreViewAKSIYONTARIH: TcxGridDBColumn;
    GridBankaEkstreViewNO: TcxGridDBColumn;
    GridBankaEkstreViewTUR: TcxGridDBColumn;
    GridBankaEkstreViewKOD: TcxGridDBColumn;
    GridBankaEkstreViewAD: TcxGridDBColumn;
    GridBankaEkstreViewACIKLAMA: TcxGridDBColumn;
    GridBankaEkstreViewHESAPKODU: TcxGridDBColumn;
    GridBankaEkstreViewHESAPADI: TcxGridDBColumn;
    GridBankaEkstreViewKUR: TcxGridDBColumn;
    GridBankaEkstreViewBORC: TcxGridDBColumn;
    GridBankaEkstreViewALACAK: TcxGridDBColumn;
    GridBankaEkstreViewBORCBAKIYE: TcxGridDBColumn;
    GridBankaEkstreViewALACAKBAKIYE: TcxGridDBColumn;
    GridBankaEkstreDBTableView1: TcxGridDBTableView;
    GridBankaEkstreDBTableView1DURUM: TcxGridDBColumn;
    GridBankaEkstreDBTableView1VADE: TcxGridDBColumn;
    GridBankaEkstreDBTableView1SERINO: TcxGridDBColumn;
    GridBankaEkstreDBTableView1HESAPADI: TcxGridDBColumn;
    GridBankaEkstreDBTableView1Column1: TcxGridDBColumn;
    GridBankaEkstreLevel1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
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
    EKSTRE: TFDQuery;
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
    BankaListeMenu1: TPopupMenu;
    AcilisKaydiMenu: TMenuItem;
    DevirFiiGir1: TMenuItem;
    AksiyonlarMenu: TPopupMenu;
    ExceleAktar1: TMenuItem;
    MenuItem3: TMenuItem;
    Ekle1: TMenuItem;
    Sil1: TMenuItem;
    AksiyonBilgisiniGorMenu: TMenuItem;
    frxBANKA: TfrxDBDataset;
    GridTviewSUBEID: TcxGridDBColumn;
    SqlMemo: TMemo;
    HesaplararasTransferYap1: TMenuItem;
    ToolButton1: TToolButton;
    AksiyonTus: TToolButton;
    GridTviewSUBEKODU: TcxGridDBColumn;
    GridTviewIBAN: TcxGridDBColumn;
    Panel1: TPanel;
    ToolBar11: TToolBar;
    YaziciYaz: TToolButton;
    JvNavPanelHeader2: TJvNavPanelHeader;
    Label1: TLabel;
    Label2: TLabel;
    CalendarEkstreBas: TcxDateEdit;
    CalendarEkstreBit: TcxDateEdit;
    N8: TMenuItem;
    N5: TMenuItem;
    YeniBanka1: TMenuItem;
    HesabDzenle1: TMenuItem;
    HesabSil1: TMenuItem;
    N6: TMenuItem;
    KopyalaMenu: TMenuItem;
    GridBankaEkstreViewYERELKUR: TcxGridDBColumn;
    GridBankaEkstreViewYERELTUTAR: TcxGridDBColumn;
    GridBankaEkstreViewYERELBAKIYE: TcxGridDBColumn;
    TOPLAMLAR: TFDQuery;
    DtsTOPLAMLAR: TDataSource;
    cxTabSheet1: TcxTabSheet;
    cxLabel1: TcxLabel;
    cxDBCurrencyEdit1: TcxDBCurrencyEdit;
    cxDBCurrencyEdit2: TcxDBCurrencyEdit;
    cxLabel4: TcxLabel;
    cxDBCurrencyEdit3: TcxDBCurrencyEdit;
    cxLabel6: TcxLabel;
    cxDBCurrencyEdit4: TcxDBCurrencyEdit;
    cxLabel8: TcxLabel;
    N7: TMenuItem;
    KurFarkGeliri1: TMenuItem;
    KurFarkGideri1: TMenuItem;
    GridBankaEkstreViewID: TcxGridDBColumn;
    GridTviewID: TcxGridDBColumn;
    ExceldenAlTus2: TToolButton;
    ExceldenAlTus: TToolButton;
    ToolButton3: TToolButton;
    BankaHizliGirisTus: TToolButton;
    HesapBakiyesiniGuncelleMenu: TMenuItem;
    N10: TMenuItem;
    BankaInfoMenu: TMenuItem;
    procedure BankaInfoMenuClick(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SilTusClick(Sender: TObject);
    procedure PageControlSekmeChange(Sender: TObject);
    procedure GridTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure BANKALARAfterOpen(DataSet: TDataSet);
    procedure AcilisKaydiMenuClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridBankaEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure TabSheetEkstreShow(Sender: TObject);
    procedure YenileClick;
    procedure AksiyonTusClick(Sender: TObject);
    procedure BankaHizliGirisTusClick(Sender: TObject);
    procedure Ekle1Click(Sender: TObject);
    procedure AksiyonBilgisiniGorMenuClick(Sender: TObject);
    procedure KopyalaMenuClick(Sender: TObject);
    procedure AksiyonlarMenuPopup(Sender: TObject);
    procedure KurFarkGeliri1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure GridBankaEkstreViewStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridTviewStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure ExceldenAlTusClick(Sender: TObject);
    procedure HesapBakiyesiniGuncelleMenuClick(Sender: TObject);
    procedure ExceleAktar1Click(Sender: TObject);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TBankalarAramaFrame;
    function EkranAdiAl: string;
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
    procedure SetArama(const Value: TBankalarAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

  public
    { Public declarations }
  published
    property Arama      : TBankalarAramaFrame read FArama write SetArama;
  end;

implementation

uses ULog, UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, PrjConst, UFastRap, URaporAraclari,
      UGenelAnaSekmeFrame, UKasalarListeFrame, LocOnFly, UBankaHareketleri,
      UBankaHesapGiris, UVeriMotor;

{$R *.dfm}

{ TBankalarListeFrame }

procedure TBankalarListeFrame.BankaInfoMenuClick(Sender: TObject);
begin
   if not BANKALAR.IsEmpty then
      Tablo.InfoGoster('BANKAHESAPLAR', BANKALAR.FieldByName('ID').AsInteger, TabNo_BANKAHESAPLAR);
end;

procedure TBankalarListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   fb : TIcerikFrameBilgi;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);

   AFastReport.EnabledDataSets.Clear;
   if pos('EKSTRE', UpperCase(DokumAdi))>0  then begin//ekstre ise
      {if not TabCariListe.Active then begin
         fb := FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TKasalarListeFrame(nil));
         TKasalarListeFrame(fb).EkstreListele(1, REHBER.Fields[0].AsInteger, False, CalendarEkstreBas.Date,CalendarEkstreBit.Date,TabCariListe);
      end; }
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
      frxBANKA.DataSet := BANKALAR;
      AFastReport.EnabledDataSets.Add(frxBANKA);
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TBankalarListeFrame.Ekle1Click(Sender: TObject);
var Sonuc ,RehberId: Integer;
begin
  {RehberId := Tablo.RehberAra_IDGetir(-99);
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
  YenileClick; }
  AksiyonTusClick(Self);
end;

function TBankalarListeFrame.EkranAdiAl: string;
begin
   Result := 'BankaListeDlg'; //  'CariDlg'   'RehberAraDlg';
end;

procedure TBankalarListeFrame.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s)
end;

procedure TBankalarListeFrame.Baslatildi;
var ra : string;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   PageControlSekme.ActivePageIndex := 0;
   GridTviewSUBEID.Visible := SubeVarmi;
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
   TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;

   DegisTus.visible := BANKALAR.Active;
   SilTus.visible := DegisTus.visible;
   CalendarEkstreBas.Date := Tablo.GENINI.BugunTrh;
   CalendarEkstreBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));

  //GridTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\BankalarGridi',true,False,[gsoUseFilter],'BankalarGridi');
  Tablo.GridAyarRestore('BankalarGridi',GridTview );

  //cxGridHareketler.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\BankalarHaraketGridi',true,False,[gsoUseFilter],'BankalarHaraketGridi');
  Tablo.GridAyarRestore('BankalarHaraketGridi',GridBankaEkstreView );

  Tablo.GridTurkcelestir;
  GridBankaEkstreViewYERELTUTAR.Visible := DovizTakibi;
  GridBankaEkstreViewYERELKUR.Visible := DovizTakibi;
  GridBankaEkstreViewYERELBAKIYE.Visible := DovizTakibi;
end;

procedure TBankalarListeFrame.CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
begin
  if (PageControlSekme.ActivePage = TabSheetEkstre)and(BANKALAR.Active)and(BANKALAR.RecordCount>0)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
      if SQLVersion2008 then begin
         EKSTRE.SQL.Text := 'select * from dbo.fn_Banka_Ekstre ';
         EKSTRE.SQL.Add('('+BANKALAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''')');
         EKSTRE.SQL.Add('order by KUR,TARIH');
      end else
         EKSTRE.SQL.Text := ' EXEC Sp_Prg_BankaEkstre  '+BANKALAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''' ';
    TabloYenile(EKSTRE,[]);
  end;
end;

procedure TBankalarListeFrame.GridBankaEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridBankaEkstre;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridBankaEkstreView;
  AnaForm.pmGridStil.Tags.Values[GridBankaEkstre.Name]:='BankalarHaraketGridi';
end;

procedure TBankalarListeFrame.GridBankaEkstreViewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TBankalarListeFrame.TabSheetEkstreShow(Sender: TObject);
begin
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TBankalarListeFrame.AksiyonBilgisiniGorMenuClick(Sender: TObject);
var
  srid, Sonuc:integer;
begin
//   if EKSTRE.FieldByName('TUR').AsInteger in [1,2] then
//      Tablo.AcilisiFisiEkraniBaslat(3,EKSTRE.FieldByName('TUR').AsInteger,BANKALAR.FieldByname('ID').AsString,BANKALAR.FieldByname('HESAPNO').AsString,
//                                       BANKALAR.FieldByname('HESAPADI').AsString, BANKALAR.FieldByname('KUR').AsString, EKSTRE.FieldByName('CEKID').AsInteger);
   Sonuc := 0;
   srid:=GridBankaEkstreView.DataController.FocusedRecordIndex;

   if EKSTRE.FieldByName('TUR').AsInteger in [1,2] then
      Tablo.AcilisiFisiEkraniBaslat(3,EKSTRE.FieldByName('TUR').AsInteger, BANKALAR.FieldByname('ID').AsString,BANKALAR.FieldByname('HESAPKODU').AsString,
                      BANKALAR.FieldByname('HESAPADI').AsString,'',EKSTRE.FieldByName('CEKID').AsInteger,EKSTRE.FieldByName('TARIH').AsDateTime)
   else
      Sonuc := AnaForm.GormeDialogCagir(EKSTRE.FieldByName('CEKID').AsInteger, EKSTRE.FieldByName('TUR').AsInteger,
           EKSTRE.FieldByName('HESAPID').AsInteger, 4,EKSTRE.FieldByName('TARIH').AsDateTime, EKSTRE.FieldByName('NO').AsString);
   CalendarEkstreBasPropertiesEditValueChanged(Self);
   if Sonuc = -99 then //iptal ise tekrar konumlans�n
      GridBankaEkstreView.DataController.FocusedRecordIndex:=srid;
end;

procedure TBankalarListeFrame.AksiyonlarMenuPopup(Sender: TObject);
begin
  KopyalaMenu.Visible := EKSTRE.FieldByName('TUR').AsInteger in [22,32];
end;

procedure TBankalarListeFrame.AksiyonTusClick(Sender: TObject);
var Tur : smallint;
    HesapTuru : Char;
    Tarih : TDateTime;
begin
   Tarih := Tablo.GENINI.BugunTrhSaat;
   Tur := Tablo.KasaSihirbazBaslat('E', -1, -2, 0, -1, Tarih, Tarih, 4, 0, BANKALAR.FieldByName('KUR').AsString,'', 0, 0);
   case Tur of
    21,31: begin
            inc(Tur);
            Tablo.NakitSihirbazBaslat('B','E', Tur,4, -1, -1, Tarih, '-1',False,0, BANKALAR.Fields[0].AsInteger);
           end;
    121,131,122,132 : begin
       // masrafta cari seçilmez yani rehberid sıfırdır
       if Tur in [121,131] then HesapTuru := 'K'
       else HesapTuru := 'B';
       Dec(Tur,100);
       Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,4, -1, 0, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', Tarih)), '-1',False,0, BANKALAR.Fields[0].AsInteger);
   end;
  end;
  YenileClick;
end;

procedure TBankalarListeFrame.DegisTusClick(Sender: TObject);
var     Key: Word;
srid:integer;
begin
  if GridTview.Controller.SelectedRecordCount > 0 then
  begin
    srid:=GridTview.DataController.FocusedRecordIndex;
  if Tablo.YetkiVarmi(2501,YetkiTur_Degistirme) then begin
     Tablo.BankaTanimSihirbazBaslat('D', 0, BANKALAR.Fields[0].AsInteger,-1);
     AraKodKeyUp(Self, Key, []);
   end else
     raise Exception.Create(Yetkisiz_Islem);

    GridTview.DataController.FocusedRecordIndex:=srid;
//    GridTview.ViewData.Records[srid].Selected := false;
  end;
end;
procedure TBankalarListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TBankalarListeFrame.ExceldenAlTusClick(Sender: TObject);
begin
   Application.CreateForm(TBankaHareketlerDlg, BankaHareketlerDlg);
   BankaHareketlerDlg.ShowModal;
   BankaHareketlerDlg.Destroy;
end;

procedure TBankalarListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankalarListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TBankalarListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TBankalarListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TBankalarListeFrame.Gorunmez;
begin

end;

procedure TBankalarListeFrame.GorunmezOlacak;
begin

end;

procedure TBankalarListeFrame.Gorunur;
begin
end;

procedure TBankalarListeFrame.GorunurOlacak;
begin

end;

procedure TBankalarListeFrame.GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
  AnaForm.pmGridStil.Tags.Values[cxGrid.Name]:='BankalarGridi';
end;

procedure TBankalarListeFrame.GridTviewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   PageControlSekmeChange(Self);
end;

procedure TBankalarListeFrame.GridTviewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TBankalarListeFrame.HesapBakiyesiniGuncelleMenuClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update  BANKAHESAPLAR set BAKIYE=(select SUM(K1.ALACAK-K1.BORC)'+
    ' from KASA K1 where K1.HESAPID='+BANKALAR.FieldByName('ID').AsString+' AND K1.ISLEMTARIHI >= '+DbTarihEkle('yy', DbTarihFark('yy','0','GETDATE()'), '0')+
    ' and K1.HESAPTURU=''B'') where ID='+BANKALAR.FieldByName('ID').AsString, [],[]);
    YenileClick;
end;

procedure TBankalarListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TBankalarListeFrame.KopyalaMenuClick(Sender: TObject);
Var IDsi : integer;
begin
   IDsi := Tablo.SQLSatiriKopyala('KASA', EKSTRE.FieldByName('CEKID').AsInteger,[ 'ISLEMTARIHI', 'BELGENO','MUHAKTAR','EKLEYEN', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
            [ Tablo.GENINI.BugunTrhSaat,  '', '0', Kullanan, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);

   case EKSTRE.FieldByName('TUR').AsInteger of
     22, 32 : IDsi := Tablo.NakitSihirbazBaslat('B','K', EKSTRE.FieldByName('TUR').AsInteger,4,
              IDsi,EKSTRE.FieldByName('HESAPID').AsInteger, Tablo.GENINI.BugunTrhSaat,'0',False, -1, EKSTRE.FieldByName('REHBERID').AsInteger );
   end;
   CalendarEkstreBasPropertiesEditValueChanged(Self);
   YenileClick;
end;

procedure TBankalarListeFrame.KurFarkGeliri1Click(Sender: TObject);
begin
   Tablo.NakitSihirbazBaslat('B','E', TMenuItem(Sender).Tag,4, -1, 0, Tablo.GENINI.BugunTrhSaat, '-1',False,0, BANKALAR.Fields[0].AsInteger);
   CalendarEkstreBasPropertiesEditValueChanged(Self);
end;

procedure TBankalarListeFrame.Label1Click(Sender: TObject);
begin
   CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
end;

procedure TBankalarListeFrame.PageControlSekmeChange(Sender: TObject);
begin
   if PageControlSekme.ActivePage = TabSheetEkstre then
      CalendarEkstreBasPropertiesEditValueChanged(Self)
   else
      TabloYenile(TOPLAMLAR,[BANKALAR.Fields[0].AsInteger,BANKALAR.Fields[0].AsInteger]);
end;

procedure TBankalarListeFrame.AcilisKaydiMenuClick(Sender: TObject);
begin
  if Tablo.AcilisiFisiEkraniBaslat(3,TMenuItem(Sender).Tag,BANKALAR.FieldByname('ID').AsString,BANKALAR.FieldByname('HESAPNO').AsString,
           BANKALAR.FieldByname('HESAPADI').AsString, BANKALAR.FieldByname('KUR').AsString, 0, Tablo.GENINI.BugunTrhSaat) then
     PageControlSekmeChange(Self);
end;

procedure TBankalarListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = 38 then
    BANKALAR.Prior
  else if Key = 40 then
    BANKALAR.next
  else
  begin
//      BANKALAR.Close;
//      BANKALAR.Params[0].Value := FArama.AraKod.Text+'%';
//      BANKALAR.Params[1].Value := '%'+FArama.AraKod.Text+'%';
//      BANKALAR.Params[2].Value := SubeId ;
////      BANKALAR.SQL.Text :=  'select * from BANKAHESAPLAR where BH.HESAPNO like '''+FArama.AraKod.Text+'%'' or B.BANKAADI like ''%'+FArama.AraKod.Text+'%'' and REHBERID=-1 ';
//      BANKALAR.Open;
      YenileClick;
      DegisTus.visible := BANKALAR.RecordCount > 0;
  end;
end;

procedure TBankalarListeFrame.SetArama(const Value: TBankalarAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;

procedure TBankalarListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TBankalarListeFrame.Sil1Click(Sender: TObject);
begin
   if Application.MessageBox(PChar(BAksiyon_silinsinmi),PChar(Onay), MB_YESNO) = IDYES then begin
      Tablo.KasaSilmeIslemleri(EKSTRE.FieldByName('CEKID').AsInteger, EKSTRE.FieldByName('TUR').AsInteger, EKSTRE.FieldByName('TARIH').AsDateTime);
      PageControlSekmeChange(Self);
      YenileClick;
   end;
end;

procedure TBankalarListeFrame.SilTusClick(Sender: TObject);
begin
   if Tablo.YetkiVarmi(2501,YetkiTur_Degistirme) then begin
      if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
        //Önce açılış kaydı harici girilmiş bilgi var mı
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'Select '+DbUst(1)+'ISLEMTARIHI From KASA Where HESAPTURU=''B'' AND HESAPID = '+ BANKALAR.FieldByName('ID').AsString+' AND TUR<>1 '+DbSinir(1);
        Tablo.Query4.Open;
        if Tablo.Query4.RecordCount> 0 then
          raise Exception.Create(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.Query4.fields[0].AsDateTime)+' tarihinde girilmiş kasa bilgisi var, silinemez...')
        else begin//yoksa açılış kaydını silelim
          Tablo.Query4.SQL.Text := ' = '+ BANKALAR.FieldByName('ID').AsString+' AND TUR in (1,2)';
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete From KASA Where HESAPID=&id and HESAPTURU=''B'' AND TUR in (1,2) ',['&id'], [BANKALAR.Fields[0].AsInteger]);
               //kendisini sil
          // Kart SILME logu: SILMEDEN ONCE, kayit dururken.
          LogKartSil(BANKALAR, TabNo_BANKAHESAPLAR, BANKALAR.FieldByName('ID').AsInteger);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBER  where KOD=&Kod ',['&Kod'],[BANKALAR.FieldByName('HESAPKODU').AsString]);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from BANKAHESAPLAR  where ID=&id ',['&id'],[BANKALAR.Fields[0].AsInteger]);

          YenileClick;
        end;
      end;
   end else
      raise Exception.Create(Yetkisiz_Islem);
end;

procedure TBankalarListeFrame.YenileClick;
var ID:integer;
begin
      if (BANKALAR.Active)and(BANKALAR.RecordCount>0) then
          ID := BANKALAR.Fields[0].AsInteger
      else
          ID := 0;
      BANKALAR.Close;
      BANKALAR.SQL.Text := SqlMemo.Text;
      BANKALAR.SQL.Add(' Where REHBERID=-1 ');
      if not FArama.CheckPasifler.Checked  then
         BANKALAR.SQL.Add(' and BH.DURUM=1 ');
      if FArama.AraKod.Text <> '' then
         BANKALAR.SQL.Add(' and (BH.HESAPNO like ''%'+FArama.AraKod.Text+'%'' or BH.HESAPADI like ''%'+FArama.AraKod.Text+'%'') ');
      if SubeVarmi then begin
         if FArama.ComboSube.EditValue = 0 then
            BANKALAR.SQL.Add(' and BH.SUBEID in('+Tablo.YetkiliSubeleriGetir(25,YetkiTur_Gorme)+') ')
         else
            BANKALAR.SQL.add(' and BH.SUBEID ='+IntToStr(FArama.ComboSube.EditValue)+' ');
      end;
      BANKALAR.SQL.Add(' ORDER BY 5,1 ');
      TabloYenile(BANKALAR,[]);
      BANKALAR.Locate('ID', ID, []);
end;

procedure TBankalarListeFrame.BANKALARAfterOpen(DataSet: TDataSet);
begin
   DegisTus.Visible   := BANKALAR.RecordCount>0;
   SilTus.Visible := DegisTus.Visible;
end;

procedure TBankalarListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankalarListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TBankalarListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankalarListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TBankalarListeFrame.YenileTusClick(Sender: TObject);
begin
   TabloYenile(BANKALAR,[]);
   BANKALAR.first;
   while not BANKALAR.eof do begin
      TabloYenile(TOPLAMLAR,[BANKALAR.Fields[0].AsInteger,BANKALAR.Fields[0].AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update BANKAHESAPLAR set BAKIYE = &Bak where ID=&ID ',['&Bak','&ID'],[StringReplace(TOPLAMLAR.FieldByName('BAKIYE').AsString,',','.',[]),BANKALAR.FieldByName('ID').AsInteger]);
      BANKALAR.next;
   end;
   TabloYenile(BANKALAR,[]);
end;


procedure TBankalarListeFrame.YeniTusClick(Sender: TObject);
var ID:Integer;
    Key: Word;
begin
   if Tablo.YetkiVarmi(2501,YetkiTur_Ekleme) then begin
     ID := Tablo.BankaTanimSihirbazBaslat('E', 0, -1,-1);
     Key := 0;
     if ID > 0 then
        AraKodKeyUp(Self, Key, []);
   end else
     raise Exception.Create(Yetkisiz_Islem);
end;

procedure TBankalarListeFrame.BankaHizliGirisTusClick(Sender: TObject);
begin
   if not Assigned(bankaHesapGirisdlg) then
      bankaHesapGirisdlg := TbankaHesapGirisdlg.Create(Application);
   bankaHesapGirisdlg.Show;
end;

procedure TBankalarListeFrame.ExceleAktar1Click(Sender: TObject);
var
  Sd: TSaveDialog;
begin
  Sd := TSaveDialog.Create(Self);
  try
    Sd.Title    := 'Banka Ekstresini Excel''e Aktar';
    Sd.Filter   := 'Excel|*.xls';
    Sd.DefaultExt := 'xls';
    Sd.FileName := 'BankaEkstre';
    Sd.Options  := Sd.Options + [ofOverwritePrompt];
    if Sd.Execute then begin
      ExportGridToExcel(Sd.FileName, GridBankaEkstre, True, True, True, 'xls');
      ShowMessage('Veriler Excel''e aktarıldı.');
    end;
  finally
    Sd.Free;
  end;
end;

initialization
  RegisterClass(TBankalarListeFrame);
end.






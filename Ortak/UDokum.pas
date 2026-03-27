unit UDokum;
{Y:Yönetici Dökümleri (Panodaki)
B:Banka
C:Cari
Ç:Çek
E:Servis
F:Fatura
K:Kasa
P:ÝK
D:Demirbaþ
R:CRM
S:Stok
T:Teklif
O:Doküman
U:Uretim
}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  FireDAC.Comp.Client, StdCtrls, Outline, DBCtrls, Grids, DBGrids, Mask, Buttons,
  ExtCtrls, Menus, comctrls, ComObj, OleServer, WideStrings,
  ToolWin, Db, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
   cxGrid, UQuantGrid, cxGridCustomPopupMenu,
  cxGridPopupMenu, cxContainer, cxTextEdit, cxMaskEdit,cxSplitter,
  cxDropDownEdit, cxCalendar, cxSpinEdit, dxSkinsCore,  dxSkinLondonLiquidSky,
  dxSkinsDefaultPainters ,
  {$IFNDEF AGENT}
  UGentegreFrameYonetimi,
  UDokumlerAksiyonFrame,
  {$ENDIF}

  UFrameYoneticisi, frxClass, frxDBSet, JvExExtCtrls, JvExtComponent, JvPanel,
  Contnrs, cxDBEdit, cxLabel, cxDBLabel, cxButtons, cxButtonEdit, cxPC, cxTimeEdit, cxCurrencyEdit,
  dxSkinscxPCPainter, Utablo, AppEvnts, ShellAPI, JvComponentBase, JvDragDrop, cxGridExportLink,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, cxNavigator,
  JvExControls, JvNavigationPane, cxCheckBox, dxBarBuiltInMenu,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations, frCoreClasses, cxGridDBTableView;

type

  TDokumDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)  //; IAracCubuguDestegi
    pmDokumSartlari: TPopupMenu;
    DtsDokumler: TDataSource;
    OpenDialog1: TOpenDialog;
    N3: TMenuItem;
    DosyayaYazdr1: TMenuItem;
    DosyaAyarlar1: TMenuItem;
    Moduller: TMenuItem;
    C: TMenuItem;
    K: TMenuItem;
    B: TMenuItem;
    F: TMenuItem;
    S: TMenuItem;
    BuRapor1: TMenuItem;
    HerkesteGrnsn1: TMenuItem;
    KimsedeGrnmesin1: TMenuItem;
    Panel1: TPanel;
    RaporKaydet1: TMenuItem;
    RaporEkle2: TMenuItem;
    N6: TMenuItem;
    PopupMenu2: TPopupMenu;
    Text1: TMenuItem;
    HTML1: TMenuItem;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    XML1: TMenuItem;
    Excel1: TMenuItem;
    GridPopupMenu: TcxGridPopupMenu;
    TabDokum: TFDQuery;
    TabKosul: TFDQuery;
    qryListe: TFDQuery;
    dsListe: TDataSource;
    SaveDialog1: TSaveDialog;
    TabKomut: TFDQuery;
    Table1: TFDTable;
    GBox1: TJvPanel;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    HTML2: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    N1: TMenuItem;
    CariKartAcMenu: TMenuItem;
    StokKartAcMenu: TMenuItem;
    frxSQLKomut: TfrxDBDataset;
    OrjinalExcel1: TMenuItem;
    N2: TMenuItem;
    BuDkmzelBlmeKopyala1: TMenuItem;
    Panel2: TPanel;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton2: TToolButton;
    DokumTus: TToolButton;
    ToolButton1: TToolButton;
    cxTabControl1: TcxTabControl;
    YaziciYaz: TToolButton;
    ToolButton5: TToolButton;
    PanelBaslik: TJvNavPanelHeader;
    PanelBilgi: TPanel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    Label8: TcxLabel;
    LabelKullanan: TcxLabel;
    EditRAPORADI: TcxDBLabel;
    EditGRUBU: TcxDBLabel;
    cxDBTextEdit3: TcxDBLabel;
    cxDBTextEdit1: TcxDBLabel;
    cxDBTextEdit2: TcxDBLabel;
    cxDBTextEdit4: TcxDBLabel;
    EditRAPORKODU: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    cxLabel1: TcxLabel;
    EditRAPORNO: TcxDBLabel;
    LabelOzel: TcxLabel;
    DBGrid1: TcxGrid;
    DBTable: TcxGridDBTableView;
    DBTableColumn1: TcxGridDBColumn;
    DBGrid1Level1: TcxGridLevel;
    Splitter1: TcxSplitter;
    cxDBCheckBox1: TcxDBCheckBox;
    cxDBCheckBox2: TcxDBCheckBox;
    R: TMenuItem;
    U: TMenuItem;
    D: TMenuItem;
    E: TMenuItem;
    O: TMenuItem;
    T: TMenuItem;
    P: TMenuItem;
    PDFAyri: TMenuItem;
    procedure TableAdListesiOlustur;
    procedure DosyayaYazdr1Click(Sender: TObject);
    procedure DosyaAyarlar1Click(Sender: TObject);
    procedure CClick(Sender: TObject);
    procedure ModullerClick(Sender: TObject);
    procedure HerkesteGrnsn1Click(Sender: TObject);
    procedure KimsedeGrnmesin1Click(Sender: TObject);
    procedure RaporKaydet1Click(Sender: TObject);
    procedure DokumTusClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure Text1Click(Sender: TObject);
    procedure HTML1Click(Sender: TObject);
    procedure DBTableMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure XML1Click(Sender: TObject);
    procedure Excel1Click(Sender: TObject);
    function FieldTypeBul(FieldType: TFieldType): string;
    procedure TabDokumNewRecord(DataSet: TDataSet);
    procedure TabDokumAfterPost(DataSet: TDataSet);
    procedure TabKosulNewRecord(DataSet: TDataSet);
    procedure TabKosulBeforeEdit(DataSet: TDataSet);
    procedure TabKosulAfterPost(DataSet: TDataSet);
    procedure TabDokumBeforeEdit(DataSet: TDataSet);
    procedure TabDokumBeforePost(DataSet: TDataSet);
    procedure TabKosulBeforePost(DataSet: TDataSet);
    procedure TabDokumAfterScroll(DataSet: TDataSet);
    procedure Panel4Paint(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure CariKartAcMenuClick(Sender: TObject);
    procedure OrjinalExcel1Click(Sender: TObject);
    procedure BuDkmzelBlmeKopyala1Click(Sender: TObject);
    procedure Label6DblClick(Sender: TObject);
    procedure Label2DblClick(Sender: TObject);
    procedure cxDBCheckBox1Click(Sender: TObject);
    procedure DBTableCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    OrderDesc: Boolean;
     {LastOrderField, OrderField,}Siralama, SiraYonu: string;
    {***********************************}
    FFrameBilgi : TIcerikFrameBilgi;
    FAksiyon : TDokumlerAksiyonFrame;
//    ComboList : TComponentList;
    GroupByList, TableBagList,  TableAdlari: TStringList;
    komut : TStringList;
    St, EskiRapor, OncekiLabKodu: string;
    EnBuyukKartNo: smallint;
    Label55: TLabel;
    Tut: TComponent;
    str, FatTar, FatNo: string;
    DosyanoVar: Boolean;

    function komutsatiri(TabAd, FIELD, EQUAL, VALUE: string): Boolean;

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
    { -------------------------------------------- }
    procedure ComBoxDropDown(Sender: TObject);

    procedure KosullariKaydet;
    procedure TopluFaturaEkle(Kime, Baslik: string);
    procedure DokumIslemi;



    { Gezinme ve yazdýrma desteði }
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
  public
    { Public declarations }
    ScrollBox2: TScrollBox;
    Standart : smallint;
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    procedure ComBoxInitPopup(Sender: TObject);
    procedure ButonClick(Sender: TObject);
    class procedure SartlarOlustur(var AOncekiOrnek : TScrollBox;
      AParent : TWinControl;AKosulHostPanel: TPanel;ATabKosul: TDataSet;
      AButtonClick,AComboInitPopup: TNotifyEvent);
    procedure GenelDokumler_EkranYazici(Sender: TObject);
    procedure ExceleYazdir(Table1: TFDQuery; Grid1: TDBGrid);
    procedure DokumuKaydet(DokumAdi: string);
    procedure DokumuAl(DokumAdi: string);
    procedure InsertMenuItem;
    procedure CreateGridFields(const tvCaption, tvFieldName, tvProperties: string; tvMerging, tvalign: boolean; tvWidth: integer);
    procedure DokumTabloAc(Modul:String; Standart1, Durum:smallint);
    procedure EkranDegisveKonumlan(ID:Integer);
  end;

var
  FMenuItem: TMenuItem;
  EditNe: TcxTextEdit;
  //SubeId,RolID: integer;
implementation

uses FetaUtil, {$IFNDEF AGENT} UAnaForm, {$ENDIF} UListe, UGrid, UMesaj, UFastRap,
     UMultiDataSetEvent, UDokumAramaFrame, FetaKurulusSiniflari, UDokumSart, UVersiyonGuncelle,
     FetaClassExtensions, URaporAraclari, JvJVCLUtils, UGenelAnaSekmeFrame, UDokumGirisFrame, PrjConst, uKosulDetayAra,LocOnFly;

{$R *.DFM}

var
  Kontrol : array[1..12] of String[20];
  OncekiSQL, OncekiGrubu, OncekiRaporAdi : string;
  YeniKayit:Boolean;

procedure TDokumDlg.InsertMenuItem;
var
  I: Integer;
  AMenu: TComponent;
  ABuiltInMenus: TcxGridDefaultPopupMenu;
begin
  AMenu := nil;
  ABuiltInMenus := GridPopupMenu.BuiltInPopupMenus;
  for I := 0 to ABuiltInMenus.Count - 1 do
    if ([gvhtFooter, gvhtFooterCell, gvhtGroupFooter, gvhtGroupFooterCell] *
      ABuiltInMenus[I].HitTypes) <> [] then
    begin
      AMenu := ABuiltInMenus[I].PopupMenu;
    end;
  AMenu := ABuiltInMenus[0].PopupMenu;
  if Assigned(AMenu) and AMenu.InheritsFrom(TPopupMenu) then
  begin
    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := 'Panoya Kopyala';
      Hint := 'Panoya Kopyala';
 //     OnClick := miCopyToClipboardClick;
    end;
    TPopupMenu(AMenu).Items.Add(FMenuItem);
    //
    FMenuItem := TMenuItem.Create(Self);
    FMenuItem.Caption := '-';
    TPopupMenu(AMenu).Items.Add(FMenuItem);

    FMenuItem := TMenuItem.Create(Self);
    with FMenuItem do
    begin
      Caption := 'Gönder';
      Hint := 'Gönder';
 //     OnClick := miCopyToClipboardClick;
    end;
    TPopupMenu(AMenu).Items.Add(FMenuItem);
  end;
end;

procedure TDokumDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDokumDlg.komutsatiri(TabAd, FIELD, EQUAL, VALUE: string): Boolean;
var FieldTipi: TFieldType;
  NeTarih: string[25];
  kom : string;
begin
  kom := '(';
  if (EQUAL = 'Baþlayan') or (EQUAL = 'Ýçinde geçen') then
    kom := kom + TabAd + '.' + FIELD + ' LIKE '
  else if EQUAL = 'Gün/Ay' then
    kom := kom + '(DAY(' + TabAd + '.' + FIELD + ') =' + copy(VALUE, 1, Pos('/', VALUE) - 1) +
      ') AND (MONTH(' + TabAd + '.' + FIELD + ') =' + copy(VALUE, Pos('/', VALUE) + 1, Length(VALUE)) + ')'
  else
    kom := kom + TabAd + '.' + FIELD + EQUAL;
  with Veritabani.SorguBaslat(Tablo.FDCnn,'Select TOP 0 '+Field+' FROM ' + TabAd,[],[]) do
  try
    FieldTipi := FieldByName(FIELD).DataType;
  finally
    Free;
  end;
  if (FieldTipi = FtString) or (FieldTipi = FtMemo) or (FieldTipi = FtDate) then kom := kom + '''';
  if EQUAL = 'Ýçinde geçen' then kom := kom + '%';
  if (FieldTipi = FtDate) or (FieldTipi = FtDateTime) then
  begin
{      Yils :='';
      GunS  := Copy(VALUE, 1, Pos('/',VALUE)-1);
      Delete(VALUE, 1, Pos('/',VALUE));
      if Pos('/',VALUE)>0 then begin
         AyS := Copy(VALUE, 1, Pos('/',VALUE)-1);
         Delete(VALUE, 1, Pos('/',VALUE));
         YilS := VALUE;
      end
      else AyS := VALUE;
      VALUE := AyS + '/' + GunS + '/' + YilS;}

    VALUE := FormatDateTime('mm/dd/yyyy', StrToDate(VALUE)); // VALUE := GAY2AGY(VALUE);
    if (FieldTipi = FtDateTime) then
      if EQUAL = '>' then
        VALUE := '''' + VALUE + ' 23:59:00'''
      else if EQUAL = '>=' then
        VALUE := '''' + VALUE + ' 00:00:00'''
      else if EQUAL = '<' then
        VALUE := '''' + VALUE + ' 00:00:00'''
      else if EQUAL = '<=' then
        VALUE := '''' + VALUE + ' 23:59:00'''
      else if EQUAL = '=' then
      begin
        NeTarih := copy(kom, pos('(', kom) + 1, pos('=', kom) - 2);
        kom := '((' + NeTarih + '>=''' + VALUE + ' 00:00:00'')and(' + NeTarih + '<=''' + VALUE + ' 23:59:00'')';
        VALUE := '';
      end
      else if EQUAL = 'Gün/Ay' then
        VALUE := ''
  end;
  kom := kom + VALUE;
  if (EQUAL = 'Baþlayan') or (EQUAL = 'Ýçinde geçen') then kom := kom + '%';
  if (FieldTipi = FtString) or (FieldTipi = FtMemo) or (FieldTipi = FtDate) then kom := kom + '''';
  kom := kom + ')';
  komut.Add(kom);
  komutsatiri := TRUE;
end;

procedure TDokumDlg.TabDokumAfterPost(DataSet: TDataSet);
var ID : Integer;
begin
{  if TabDokum.Tags.AsBoolean['YeniKayit'] then begin
     TabloYenile(TabKosul, [TabDokum.Fields[0].AsInteger]);
     SartlarOlustur;
  end;}
  ID :=  TabDokum.Fields[0].AsInteger;
  if (YeniKayit)or(OncekiRaporAdi <> TabDokum.FieldByName('RAPORADI').AsString)
     or(OncekiGrubu <> TabDokum.FieldByName('GRUBU').AsString) then begin
      DokumSartDlg.Close;
       with FFrameBilgi.AramaFrameYoneticisi.
         FrameBul(TDokumAramaFrame).Ornek as TDokumAramaFrame do begin
         DokumleriYerlestir(TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi);
         TabDokum.Locate('ID',ID,[]);
       end;
     end;
end;

procedure TDokumDlg.TabDokumAfterScroll(DataSet: TDataSet);
var i:smallint;
begin
 // Tablo.TablodanSorguAc(1, ' select FIRMA from REHBER where KOD='''+ TabDokum.FieldByName('SONKULLANAN').AsString+''' ');
  PanelBaslik.Caption := TabDokum.FieldByName('RAPORADI').AsString;
  Splitter1.OpenSplitter;
  LabelKullanan.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDokum.FieldByName('SONKULLANAN').AsString);
  TabloYenile(TabKosul, [TabDokum.Fields[0].AsInteger]);
  if TabKosul.RecordCount>7 then
     i:=7
  else
     i:=TabKosul.RecordCount;
  GBox1.Height := 30+(i*25);
  SartlarOlustur(ScrollBox2,GBox1,Panel1,TabKosul,ButonClick,ComBoxInitPopup);
  qryListe.Close;
end;

procedure TDokumDlg.TabDokumBeforeEdit(DataSet: TDataSet);
begin
  YeniKayit := False;
  OncekiGrubu := TabDokum.FieldByName('GRUBU').AsString;
  OncekiRaporAdi := TabDokum.FieldByName('RAPORADI').AsString;
  OncekiSQL := TabDokum.FieldByName('SQL').AsString;
end;

procedure TDokumDlg.TabDokumBeforePost(DataSet: TDataSet);
  function VersiyonGetir(Ver:string) : string;
  var i : SmallInt;
  begin
     if Ver = '' then
        Result := '1.1'
     else begin
        i := StrToIntDef(Copy(Ver,1,pos('.', Ver)-1),1);
        Inc(i);
        Result := IntToStr(i)+'.'+Copy(Ver,pos('.', Ver)+1,10);
     end;
  end;
begin
  if TabDokum.AsString['RAPORADI'] = '' then
    raise Exception.Create('Rapor Adý Dolu Olmalý!');
  TabDokum.FieldByName('SQL').AsString := trim(TabDokum.FieldByName('SQL').AsString);
  TabDokum.FieldByName('DEGISTIREN').AsString := Kullanan;
  TabDokum.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;

  if OncekiSQL <> TabDokum.FieldByName('SQL').AsString then
     TabDokum.FieldByName('VERSIYON').AsString := VersiyonGetir(TabDokum.FieldByName('VERSIYON').AsString);
end;

procedure TDokumDlg.TabDokumNewRecord(DataSet: TDataSet);
begin
  TabDokum.FieldByName('EKLEYEN').AsString := Kullanan;
  TabDokum.FieldByName('EKLEMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  TabDokum.FieldByName('STANDART').AsBoolean := False;
  TabDokum.FieldByName('MOBIL').AsBoolean := False;
  TabDokum.FieldByName('MODUL').AsString := TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi;//TRaporAraclari.Modul;
  TabDokum.FieldByName('PRGVERSIYON').AsInteger := 2000;
  TabDokum.FieldByName('SEKTOR').AsString := '(0)';
  TabDokum.FieldByName('DURUM').AsInteger:=9;
  YeniKayit := True;
  OncekiSQL := '';
end;


procedure TDokumDlg.TabKosulAfterPost(DataSet: TDataSet);
begin
  if YeniKayit then begin
     TabKosul.Close;
     TabKosul.Open;
  end;
end;

procedure TDokumDlg.TabKosulBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit := False;
end;

procedure TDokumDlg.TabKosulBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(TabKosul.AsString['KOD_ADI'], 'Kod Adý') then Abort;
   if not BoslukKontrol(TabKosul.AsString['ACIKLAMA'], 'Açýklama') then Abort;
   if not BoslukKontrol(TabKosul.AsString['ICERIKTURU'], 'Ýçerik Türü') then Abort;
end;

procedure TDokumDlg.TabKosulNewRecord(DataSet: TDataSet);
begin
  YeniKayit := True;
  TabKosul.Fields[1].AsInteger := TabDokum.Fields[0].AsInteger;
end;

procedure TDokumDlg.TableAdListesiOlustur;
var index1, TabAd, sat: string[100];
  i, j, k, IndexAlanSay: Integer;
  FList, IndexList: TStringList;
  bulundu: boolean;
  procedure ListedeYoksaEkle(TabloAd: string);
  begin
    bulundu := false;
    k := 0;
    while (not bulundu) and (k <= TableAdlari.Count - 1) do
      if TabloAd = TableAdlari.Strings[k] then
        bulundu := true
      else
        inc(k);
    if not bulundu then
      TableAdlari.Add(TabloAd);
  end;

  function IndexAlanAl(TabloAd: string; IndexAlanSira: integer): string;
  begin
    Table1.Close;
////////      Table1.DatabaseName := 'GENOTIP';
    Table1.TableName := TabloAd;
    Table1.open;
    Table1.IndexDefs.Update;
//      index1 := Table1.IndexDefs.Items[0].Fields;
    index1 := Table1.Fields[0].FieldName;
    IndexAlanAl := index1;
    IndexAlanSay := 0;
    while pos(';', index1) > 0 do
    begin //Ýndex Alan Sayýsýný belirle 'kod;sýrano'
      inc(IndexAlanSay);
      if IndexAlanSira = IndexAlanSay then
        IndexAlanAl := copy(index1, 1, pos(';', index1) - 1);
      delete(index1, 1, pos(';', index1));
    end; //while
  end;
begin
  FList := TStringList.Create;
  IndexList := TStringList.Create;
  TableAdlari.Clear;
  TableBagList.Clear;
  FList.Assign(TabDokum.FieldByName('FIELDLIST'));
   {Field'lerden Table Adlarý belirlenir}
  TabKosul.First;
  while not TabKosul.eof do
  begin
    ListedeYoksaEkle(TabKosul.FieldByName('TABLO').AsString);
    TabKosul.next;
  end; {while}

  for i := 0 to FList.Count - 1 do
  begin
    sat := FList.Strings[i];
    Sat := Trim(sat);
    while (sat <> '') and (Pos('.', sat) > 0) do
    begin
      TabAd := Copy(sat, 1, Pos('.', sat) - 1);
      Delete(sat, 1, Pos('.', sat));
      if RevPos(' ', TabAd) > 0 then Delete(TabAd, 1, RevPos(' ', TabAd));
      if RevPos('(', TabAd) > 0 then Delete(TabAd, 1, RevPos('(', TabAd));
      if RevPos('*', TabAd) > 0 then Delete(TabAd, 1, RevPos('*', TabAd));
      if RevPos('-', TabAd) > 0 then Delete(TabAd, 1, RevPos('-', TabAd));
      if RevPos('+', TabAd) > 0 then Delete(TabAd, 1, RevPos('+', TabAd));
//          if simge <> '.' then Delete(TabAd,1,Rev_Pos(simge, TabAd));
      Trim(TabAd);
      ListedeYoksaEkle(TabAd);
    end;
  end; {for}


  if TableAdlari.Count = 0 then {boþsa}
    TableAdlari.Add('STOK');

  if TableAdlari.Count > 1 then {Tablolar arasýndaki baðý kur}
    for k := 1 to TableAdlari.Count - 1 do
    begin
      TableBagList.Add('(' + TableAdlari.Strings[0] + '.' + IndexAlanAl(TableAdlari.Strings[0], 1) + '=' +
        TableAdlari.Strings[k] + '.' + IndexAlanAl(TableAdlari.Strings[k], 1) + ')');
      if k < TableAdlari.Count - 1 then TableBagList.Add(' AND ');
//    TableBagList.Add('And(Siparis.SiparisNo = '+TabAd+'.SiparisNo)');
    end;

//   if DataDosyaYolu <> '' then
//      for i := 0 to TableAdlari.Count-1 do
//          TableAdlari.Strings[i] := DataDosyaYolu+TableAdlari.Strings[i];

  for i := 0 to TableAdlari.Count - 2 do
    TableAdlari.Strings[i] := TableAdlari.Strings[i] + ',';

  FList.Destroy;

end;

procedure TDokumDlg.KosullariKaydet;
var
  i : Integer;
  s : string;
begin
  i := 1;
  TabKosul.First;
  while not TabKosul.eof do begin
    Tut := ScrollBox2.FindChildControl(Kontrol[TabKosul.FieldByName('ICERIKTURU').AsInteger] + TabKosul.FieldByName('ID').AsString);
    if Tut <> nil then begin
       TabKosul.edit;
       case TabKosul.FieldByName('ICERIKTURU').AsInteger of
         1,3 : s := TcxTextEdit(Tut).Text;
         2 : s := TcxSpinEdit(Tut).Text;
         4 : s := TcxCurrencyEdit(Tut).Text;
         5 : s := FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', TcxDateEdit(Tut).Date);
         6 : s := FormatDateTime('hh:nn', TcxTimeEdit(Tut).Time);
         7 : s := TcxComBoBox(Tut).Text;
         8 : s := TcxTextEdit(Tut).Text;
       end;
       TabKosul.FieldByName('DEGER').AsString := s;//TComBoBox(Tut).Text;
       TabKosul.post;
    end;
    TabKosul.Next;
    inc(i, 5);
  end;

  Tablo.FDCnn.ExecSQL('UPDATE DOKUMLER SET SAYAC= ISNULL(SAYAC,0) + 1 , SONTARIH= GETDATE(), SONKULLANAN='''+Kullanan+''' WHERE RAPORADI ='''+TabDokum.Fieldbyname('RAPORADI').AsString +'''');
end;

procedure TDokumDlg.Label2DblClick(Sender: TObject);
begin
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar
end;

procedure TDokumDlg.Label6DblClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from DOKUMLER  where MODUL>''-'' and  STANDART=0 AND DOKUMLER.RAPORADI in ('+
                 ' select D2.RAPORADI from DOKUMLER D2 where   D2.STANDART=1)',[],[]);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from [AYARLARYENI] where DOKUMID not in (select ID from DOKUMLER) ',[],[]);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from [KOSULLAR] where DOKUMID not in (select ID from DOKUMLER) ',[],[]);
end;

{procedure TDokumDlg.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
const   BufferLength : DWORD = 511;
var
  DroppedFilename     : String;
  FileIndex           : DWORD;
  NumDroppedFiles     : DWORD;
  pDroppedFilename    : array [0..511] of Char;
  procedure DokumEkleme(FileName : String);
  var i : SmallInt;
      Ad : String;
  begin
      i := Pos('#',  FileName);
      if i > 0 then
         Ad := Copy(FileName, 1, i-2)
      else begin
         i := Pos('.FR',  UpperCase(FileName));
         if i > 0 then
            Ad := Copy(FileName, 1, i-1);
      end;
      FastRaporDlg.XMLOku('DokumDlg', Ad, FileName);//(EkranAdi1, RaporAdi1, DosyaAdi : String)
  end;
begin
   if Msg.message = WM_DROPFILES then begin
      FileIndex := $FFFFFFFF;
      NumDroppedFiles := DragQueryFile(Msg.WParam, FileIndex,
      pDroppedFilename, BufferLength);
      DroppedFilename := '';
      FileIndex:=NumDroppedFiles - 1;
      for FileIndex := 0 to (NumDroppedFiles - 1) do begin
          DragQueryFile(Msg.WParam, FileIndex, pDroppedFilename, BufferLength);
          DroppedFilename := StrPas(pDroppedFilename);
          if FileExists(DroppedFilename) then
             DokumEkleme(DroppedFilename);
      end;
      DragFinish(Msg.WParam);
      Handled := True;
      TabDokumAfterDelete(TabDokum);
   end;
end;}

procedure TDokumDlg.BaskiOnizlemeMenuClick(Sender: TObject);
begin
   // Analist Deðiþkenleri Klasörünü ekle

   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   qryListe.DisableControls;
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'DokumDlg', TabDokum.FieldByName('RAPORADI').AsString);
   qryListe.EnableControls;
end;

procedure TDokumDlg.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  if not Tablo.Yetkivarmi(110103,YetkiTur_Gorme) then begin//Excel Aktarýmý
     Excel1.Visible := False;
     Excel2.Visible := False;
     CSV1.Visible := False;
  end;
end;

procedure TDokumDlg.BuDkmzelBlmeKopyala1Click(Sender: TObject);
var DID, AID:Integer;
begin
   DID := Tablo.SatirKopyala('DOKUMLER', TabDokum.FieldByName('ID').AsInteger);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE DOKUMLER SET STANDART=0,SAYAC=0,RAPORNO=0,EKLEYEN='+Kullanan+',EKLEMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''',DEGISTIREN='+Kullanan+',DEGISTIRMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''' WHERE ID = &ID', ['&ID'],[IntToStr(DID)]);

   Tablo.TablodanSorguAc(3,'select ID from AYARLARYENI WHERE DOKUMID = '+TabDokum.Fields[0].AsString);
   if Tablo.Query3.RecordCount>0 then begin
      AID := Tablo.SatirKopyala('AYARLARYENI',Tablo.Query3.Fields[0].AsInteger);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE AYARLARYENI SET DOKUMID='+IntToStr(DID)+', EKLEYEN='+Kullanan+',EKLEMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''',DEGISTIREN='+Kullanan+',DEGISTIRMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''' WHERE ID = &ID', ['&ID'],[IntToStr(AID)]);
   end;

   Tablo.TablodanSorguAc(3,'select ID from KOSULLAR WHERE DOKUMID = '+TabDokum.Fields[0].AsString);
   while not Tablo.Query3.eof do begin
     AID := Tablo.SatirKopyala('KOSULLAR', Tablo.Query3.Fields[0].AsInteger);
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE KOSULLAR SET DOKUMID='+IntToStr(DID)+', EKLEYEN='+Kullanan+',EKLEMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''',DEGISTIREN='+Kullanan+',DEGISTIRMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''' WHERE ID = &ID', ['&ID'],[IntToStr(AID)]);
     Tablo.Query3.next;
   end;
   Showmessage(DDokum_gormek_icin_yetki);
end;

procedure TDokumDlg.ButonClick(Sender: TObject);
var
  Yedekad, ad: string;
  btn: TSpeedButton;
  i: integer;
  j: integer;
begin
  btn := TSpeedButton(Sender);
  Yedekad:= Copy(btn.Name,8,Length(btn.Name)-8);
  i:= StrToInt(Copy(Yedekad,1,Pos('_',Yedekad)-1));

//  i := strtoint(copy(btn.Name, 8, pos('_', btn.Name) - 4));
//  j := strtoint(copy(btn.Name, pos('_', btn.Name) + 1, length(btn.name)));
  EditNe := ScrollBox2.FindChildControl('Edit_' + inttostr(i)) as TcxTextEdit;
  TabKosul.First;
  TabKosul.Locate('ID', i, [loPartialKey, loCaseInsensitive]);
  Application.CreateForm(TKosulDetayAra, KosulDetayAra);
  KosulDetayAra.TabKosulInstance := TabKosul;
  KosulDetayAra.showmodal;
  KosulDetayAra.destroy;
end;

class procedure TDokumDlg.SartlarOlustur;
  procedure LabelCreate(Ad, Baslik: string; LeftArtis, TopArtis: Integer);
  begin
    with TcxLabel.Create(AParent.Owner) do
    begin
      Name := Ad;
      Parent := AOncekiOrnek;
      Caption := Baslik;
      Left := 16 + LeftArtis;
      Top := 10 + TopArtis;
      Height := 13;
      Style.Font.Size := 8;
      AutoSize := True;
    end;
  end;
  procedure EditCreate(Ad, Baslik: string; LeftArtis, TopArtis: Integer);
  begin
    with TcxTextEdit.Create(AParent.Owner) do
    begin
      Name := Ad;
      Parent := AOncekiOrnek;
      Text := Baslik;
      Left := 16 + LeftArtis;
      Top := 10 + TopArtis;
      Width := 225;
      Height := 10;
      Style.Font.Size := 8;
//      ComboList.Add(TComponent(CurrentInstance));
    end;
  end;
  procedure ComboCreate(Ad, Baslik, ComboIcerik: string; LeftArtis, TopArtis: Integer);
  begin
    with TcxComboBox.Create(AParent.Owner) do
    begin
      Name := Ad;
      Parent := AOncekiOrnek;
      Properties.ImmediatePost:=True;
      Text := Baslik;
      Left := 16 + LeftArtis;
      Top := 10 + TopArtis;
      Width := 225;
      Height := 10;
      Style.Font.Size := 8;

      //Properties.OnCloseUp := ComBoxDropDown;
      Properties.OnInitPopup := AComboInitPopup;
//      ComboList.Add(TComponent(CurrentInstance));
    end;
  end;
  procedure DateCreate(Ad, Baslik, ComboIcerik: string; LeftArtis, TopArtis: Integer);
  var
    d: TcxDateEdit;
  begin
    d := TcxDateEdit.Create(AParent.Owner);
    with d do
    begin
      Name := Ad;
      Properties.DisplayFormat := FormatSettings.ShortDateFormat;
      Properties.EditFormat := FormatSettings.ShortDateFormat;
      Properties.ImmediatePost := True;
      Parent := AOncekiOrnek;
      Text := Baslik;
      Left := 19 + LeftArtis;
      Top := 10 + TopArtis;
      Width := 121;
      Height := 21;
//      delete(ad, 1, 3);
      if (ComboIcerik = 'bu gün') or (ComboIcerik = 'BU GÜN') or (ComboIcerik = 'bugün') or (ComboIcerik = 'BUGÜN')  then
         d.Date := Tablo.GENINI.BugunTrh
      else
         d.Date := StrToDateDef(Baslik, Tablo.GENINI.BugunTrh);

    end;
  end;
  procedure TimeCreate(Ad, Baslik, ComboIcerik: string; LeftArtis, TopArtis: Integer);
  var
    d: TcxTimeEdit;
  begin
    d := TcxTimeEdit.Create(AParent.Owner);
    with d do
    begin
      Name := Ad;
      Parent := AOncekiOrnek;
      Properties.ImmediatePost := True;
      Text := Baslik;
      Left := 19 + LeftArtis;
      Top := 10 + TopArtis;
      Width := 121;
      Height := 21;
      delete(ad, 1, 3);

      if ( UpperCase(ComboIcerik) = 'SAAT') or (ComboIcerik = 'ÞÝMDÝ') or (ComboIcerik = 'Þimdi') or (ComboIcerik = 'þimdi')  then
         d.Time := Tablo.GENINI.BugunTrhSaat
       else
         d.Time := StrToDateDef(Baslik, Tablo.GENINI.BugunTrhSaat);

    end;
  end;
  procedure MoneyCreate(Ad, Baslik: string; LeftArtis, TopArtis: Integer);
  var
    d: TcxCurrencyEdit;
  begin
    d := TcxCurrencyEdit.Create(AParent.Owner);
    with d do
    begin
      Name := Ad;
      Parent := AOncekiOrnek;
      Text := Baslik;
      Left := 16 + LeftArtis;
      Top := 10 + TopArtis;
      Width := 121;
      Height := 21;
      Style.Font.Size := 8;
    end;
  end;
  procedure SpinCreate(Ad, Baslik: string; LeftArtis, TopArtis: Integer);
  var
    d: TcxSpinEdit;
  begin
    d := TcxSpinEdit.Create(AParent.Owner);
    with d do
    begin
      Name := Ad;
      Parent := AOncekiOrnek;
      Text := Baslik;
      Left := 16 + LeftArtis;
      Top := 10 + TopArtis;
      Width := 121;
      Height := 21;
      Style.Font.Size := 8;
    end;
  end;
  procedure ButonCreate(Ad, Baslik: string; LeftArtis, TopArtis: Integer);
  var
    d: TcxButton;
  begin
    d := TcxButton.Create(AParent.Owner);
    with d do
    begin
      Name := Ad;
      Parent := AOncekiOrnek;
      Caption := Baslik;
      Left := 16 + LeftArtis;
      Top := 10 + TopArtis;
      Width := 24;
      Height := 21;
      Font.Size := 8;
      delete(ad, 1, 3);
      Caption := '...';
      OnClick := AButtonClick;
//      d.DateTime := TarihBul;
    end;
  end;
var
  i : Integer;
  DownList: TStringList;
begin
//  if EskiRapor = TabDokum.FieldByName('RAPORADI').AsString then exit;
//  EskiRapor := TabDokum.FieldByName('RAPORADI').AsString;


  if AOncekiOrnek <> nil then
  begin
    AOncekiOrnek.Free;
    AOncekiOrnek := nil;
  end;
//  ComboList.Clear;
  AOncekiOrnek := TScrollBox.Create(AParent.Owner);

  with AOncekiOrnek do
  begin
    Name := 'ScrollBox2';
    Parent := AParent;
    Align := alClient;
    BorderStyle := bsNone;
  end;


  i := 1;
  DownList := TStringList.Create;
  ATabKosul.First;
  AOncekiOrnek.CizimiKilitle(True);
  try
    while not ATabKosul.eof do
    begin
      LabelCreate('Lab' + IntToStr(i + 4), ATabKosul.FieldByName('ACIKLAMA').AsString, 0, i * 5);
      LabelCreate('Lab' + IntToStr(i + 5), ATabKosul.FieldByName('ESITLIK').AsString, 100, i * 5);
      case ATabKosul.FieldByName('ICERIKTURU').AsInteger of
        1,3 : EditCreate('Edit_' + ATabKosul.FieldByName('ID').AsString, ATabKosul.FieldByName('DEGER').AsString, 220, i * 5);
        2 : SpinCreate('Spin_' + ATabKosul.FieldByName('ID').AsString, ATabKosul.FieldByName('DEGER').AsString, 220, i * 5);  //tamsayý
        4 : MoneyCreate('Money_' + ATabKosul.FieldByName('ID').AsString, ATabKosul.FieldByName('DEGER').AsString, 220, i * 5);
        5 : DateCreate('Date_' + ATabKosul.FieldByName('ID').AsString, ATabKosul.FieldByName('DEGER').AsString,ATabKosul.FieldByName('COMBOICERIK').AsString, 220, i * 5);
        6 : TimeCreate('Time_' + ATabKosul.FieldByName('ID').AsString, ATabKosul.FieldByName('DEGER').AsString,ATabKosul.FieldByName('COMBOICERIK').AsString, 220, i * 5);
        7 : ComboCreate('Combo_' + ATabKosul.FieldByName('ID').AsString, ATabKosul.FieldByName('DEGER').AsString, ATabKosul.FieldByName('COMBOICERIK').AsString, 220, i * 5);
        8 : begin
              EditCreate('Edit_' + ATabKosul.FieldByName('ID').AsString, ATabKosul.FieldByName('DEGER').AsString, 220, i * 5);
              DownList.Add(ATabKosul.FieldByName('COMBOICERIK').AsString);
  //            if copy(ATabKosul.FieldByName('COMBOICERIK').AsString, 1, 1) = '{' then
              ButonCreate('Button_' + ATabKosul.fieldbyname('ID').AsString + '_' + inttostr(i), ATabKosul.FieldByName('DEGER').AsString, 444, i * 5);
            end;
      end;
      Inc(i, 5);
      ATabKosul.Next;
    end; {while}
  finally
    DownList.Free;
  end;
  AOncekiOrnek.CizimiKilitle(False);
  AKosulHostPanel.Height := AOncekiOrnek.CurrentHeight + 20;
end;
procedure TDokumDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
  AValue.Etiketler.AsBoolean['DökümEkraný'] := True;
end;


{
   LabelBaglac.Caption :=TabKosul.FieldByName('BAGLAC').AsString;
   LabelTablo.Caption :=TabKosul.FieldByName('TABLO').AsString;
   LabelAlan.Caption :=TabKosul.FieldByName('ALAN').AsString;
   LabelEsitlik.Caption :=TabKosul.FieldByName('ESITLIK').AsString;
   ComboDeger.Text :=TabKosul.FieldByName('DEGER').AsString;
}
procedure TDokumDlg.ComBoxInitPopup(Sender: TObject);
begin
   //TRaporAraclari.Ini.ReadSection('Dokum_'+TabKosul.FieldByName('KOD_ADI').AsString+TabKosul.FieldByName('ID').AsString, TcxComboBox(Sender).Properties.Items);
end;

procedure TDokumDlg.CariKartAcMenuClick(Sender: TObject);
begin
   case TMenuItem(Sender).Tag of
      1 : Tablo.RehberSihirbazBaslat(0,qryListe.FieldByName('REHBERID').AsInteger,-100,-100, False);
      2 : Tablo.StokSihirbazBaslat('D', 0, qryListe.FieldByName('STOKID').AsInteger,-1,0);
   end;
end;

procedure TDokumDlg.ComBoxDropDown(Sender: TObject);
var
  SQLSt: string;
  i : Integer;
  j : Integer;
begin
  i := StrToInt(Copy(TComboBox(Sender).Name, 7, length(TComboBox(Sender).Name)));
  j := 1;
  TabKosul.First;
  while j < i do
  begin
    TabKosul.Next;
    inc(j, 5);
  end;
  if TabKosul.FieldByName('COMBOICERIK').AsString <> '' then
  begin
//    if Copy(TabKosul.FieldByName('COMBOICERIK').AsString, 1, 1) = '{' then
//      SQLSt := Copy(TabKosul.FieldByName('COMBOICERIK').AsString, pos('}', TabKosul.FieldByName('COMBOICERIK').AsString) + 1, length(TabKosul.FieldByName('COMBOICERIK').AsString))
//    else
    SQLSt := TabKosul.FieldByName('COMBOICERIK').AsString;
    try
      TComboBox(Sender).Items.FillFromSQL(Tablo.FDCnn,SQLSt,[],[]);
    except
    end;
    exit;
  end;

  TRaporAraclari.Ini.ReadSection(TabKosul.FieldByName('ALAN').AsString, TComboBox(Sender).Items);
end;


procedure TDokumDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   if not qryListe.Active then
      DokumTus.Click;

   TabKosul.First;
   while not TabKosul.Eof do begin
       DokumDegiskenListesi.Add(TabKosul.FieldByName('ACIKLAMA').AsString+'$@$'+TabKosul.FieldByName('DEGER').AsString);
       TabKosul.Next;
   end;

   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxSQLKomut);
end;

procedure TDokumDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TDokumDlg.YeniTusClick(Sender: TObject);
begin
    Application.CreateForm(TDokumSartDlg, DokumSartDlg);
    DokumSartDlg.DtsKosul.DataSet := TabKosul;
    DokumSartDlg.DtsDokumler.DataSet := TabDokum;
    TabDokum.Append;
    DokumSartDlg.ShowModal;
    DokumSartDlg.Destroy;

    with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TDokumDlg).Git.Ornek as TDokumDlg do begin
//       DtsDokumler.DataSet := TabDokum;
//       TabDokum.Locate('ID',,[]);
    end;
    SartlarOlustur(ScrollBox2,GBox1,Panel1,TabKosul,ButonClick,ComBoxInitPopup);
end;

function TDokumDlg.EkranAdiAl : string;
begin
  Result := 'DokumDlg';//Self.ClassName;
end;

procedure TDokumDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumDlg.GenelDokumler_EkranYazici(Sender: TObject);
var AyarTablo, Baslik: string;
begin                       {
  if not qryListe.Active then
    raise Exception.Create('Önce sonuçlarý listeleyiniz');

  //RaporTabloSec(RapTablo.Kosullar, DtsDokumler, 'RAPORADI');

  Baslik := AnaForm.EkranYaz.Caption;
  Delete(Baslik, Pos('&', Baslik), 1);
  if (TabDokum.FieldByName('DOKUMTIPI').AsString = 'E') or (Baslik = 'Etiket') then
    AyarTablo := 'Etiket_'
  else
    AyarTablo := TabDokum.FieldByName('RAPORADI').AsString;

  GlobalQuery := qryListe;
  if TToolButton(Sender).Name = 'EkranYaz' then
    RapSyf.DokumYap(0, AyarTablo)
  else
    RapSyf.DokumYap(1, AyarTablo);
  RapTablo.Kosullar.Close; }

end;

function TDokumDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumDlg.Gorunmez;
begin

end;

procedure TDokumDlg.GorunmezOlacak;
begin

end;

procedure TDokumDlg.Gorunur;
begin
  FFrameBilgi.IcerikFrameYoneticisi.AramaFrameYoneticisi.FrameBul(TDokumAramaFrame).Git;
  if (Dokum_Degis_Yetki)or(Standart=0) then
     YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar
  else
     YaziciYaz.PopupMenu := nil;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
  Kontrol[1] := 'Edit_';
  Kontrol[2] := 'Spin_';
  Kontrol[3] := 'Edit_';
  Kontrol[4] := 'Money_';
  Kontrol[5] := 'Date_';
  Kontrol[6] := 'Time_';
  Kontrol[7] := 'Combo_';
  Kontrol[8] := 'Edit_';
end;

procedure TDokumDlg.GorunurOlacak;
begin

end;


{procedure TDokumDlg.RaporEkle1Click(Sender: TObject);
var Yol, Secilen : String;
   procedure DeleteQuery(TabloAdi, Deger : String);
   begin
     Tablo.Query2.SQL.Text := 'Delete From '+TabloAdi+' Where RAPORADI  = '''+Deger+'''';
     Tablo.Query2.ExecSQL;
   end;

begin
   GetDir(0, str);
   OpenDialog1.InitialDir := str;
   if OpenDialog1.Execute then begin
      if RevPos('\',(OpenDialog1.FileName))>0 then
         Yol := copy(OpenDialog1.FileName,1,RevPos('\', (OpenDialog1.FileName)));

      qryListe.Close;
      qryListe.DatabaseName := Yol;
      qryListe.SQL.Text := 'Select distinct RAPORADI from  DOKUMLER';// ''' + Yol+'Dokumler' +'''');
      qryListe.Open;

      qryListe.first;
      Application.CreateForm(TListeDlg, ListeDlg);
      while not qryListe.eof do begin
        ListeDlg.ListAmac.Items.Add(qryListe.FieldByName('RAPORADI').AsString);
        qryListe.Next;
      end;
      ListeDlg.ShowModal;
      If ListeDlg.ModalResult = idOK then
         Secilen := ListeDlg.ListAmac.Items[ListeDlg.ListAmac.ItemIndex]
      else
         Secilen := '';
      ListeDlg.Destroy;
      if Secilen = '' then begin
         qryListe.Close;
         qryListe.DatabaseName := 'GENOTIP';
         exit;
      end;

      RapTablo.Kosullar.Open;
      RapTablo.Ayarlar.Open;
      TabDokum2.SQL.Text := 'Select * From DOKUMLER Where RAPORADI = '''+Secilen+'''';
      TabDokum2.Open;
      if TabDokum2.RecordCount >0 then
         if MessageDlg('Dökümlerde ayný adla rapor bulundu. Üzerine kaydedilsin mi?',
                   mtConfirmation, [mbYes,mbNo], 0) <> mrYES then exit
         else begin
            DeleteQuery('Dokumler', Secilen);
            DeleteQuery('Ayarlar',  Secilen);
            DeleteQuery('Kosullar', Secilen);
         end;
      SQLRaporEkle(TabDokum2, 'DOKUMLER', Secilen);
      SQLRaporEkle(RapTablo.Kosullar, 'KOSULLAR', Secilen);
      SQLRaporEkle(RapTablo.Ayarlar, 'AYARLAR', Secilen);
      qryListe.Close;
      qryListe.DatabaseName := 'GENOTIP';
      TabDokum.Close;
      TabDokum.Open;
//      TabDokum.FindKey([Secilen]);
//      SartlarOlustur;
      MenuIslemleri(AnaForm.GenelDokumler, GenelRaporSecClick, 'Ekle', Secilen, '',-1);
      ShowMessage(Secilen+' Raporu Eklendi..');
   end;
end; }

procedure TDokumDlg.DosyayaYazdr1Click(Sender: TObject);
var
  F: Textfile;
  DisNo, Ekle: integer;
  fmt, st, ss: string;
  i : Integer;
  j : Integer;
begin
  SaveDialog1.Title := 'Kaydedilecek Dosya Adý';
  if SaveDialog1.Execute then
  begin
    AssignFile(F, SaveDialog1.FileName);
    if FileExists(SaveDialog1.FileName) then
      if MessageDlg(OpenDialog1.FileName + ' adlý dosya zaten var. Üzerine yazýlsýn mý?',
        mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        exit;
    try
      Rewrite(F);
    except
      on EInOutError do
        MessageDlg('Dosya oluþturmada hata var!!!', mtError, [mbOk], 0);
    end;

    qryListe.first;
    while not qryListe.eof do
    begin
      str := '';
      for i := 0 to qryListe.FieldCount - 1 do
      begin
        fmt := TRaporAraclari.Ini.ReadString(TabDokum.FieldByName('RAPORADI').AsString, qryListe.Fields[i].FieldName, '%-,');
        fmt := copy(fmt, 1, pos(',', fmt) - 1);
        st := '';

        if Fmt[Length(Fmt)] = 't' then
          St := FormatDateTime('ddmmyyyy', qryListe.Fields[i].AsDateTime)
        else if Fmt[Length(Fmt)] = 'd' then
          st := Format(fmt, [qryListe.Fields[i].AsInteger])
        else if Fmt[Length(Fmt)] = 'c' then
        begin
          st := qryListe.Fields[i].AsString;
          while pos('.', st) > 0 do
            delete(st, pos('.', st), 1);
          while pos(' ', st) > 0 do
            delete(st, pos(' ', st), 1);
        end
        else if Fmt[Length(Fmt)] = 'þ' then
        begin
          ss := copy(qryListe.Fields[i].AsString, 1, 7);
          DisNo := StrToInt(copy(qryListe.Fields[i].AsString, 9, 1));
          if (ss = 'SAÐ ÜST') or (ss = 'Sað Üst') then
            Ekle := 0
          else if (ss = 'SOL ÜST') or (ss = 'Sol Üst') then
            Ekle := 8
          else if (ss = 'SAÐ ALT') or (ss = 'Sað Alt') then
            Ekle := 16
          else if (ss = 'SOL ALT') or (ss = 'Sol Alt') then
            Ekle := 24;
          st := '';
          for j := 0 to Ekle + disno do
            st := st + ' ';
          st := st + copy(qryListe.Fields[i].AsString, 11, 1);
          for j := Ekle + disno to 32 do
            st := st + ' '
        end
        else if Fmt[Length(Fmt)] = 'ö' then
        begin
          st := qryListe.Fields[i].AsString;
          if st = '0' then
            st := '<'
          else
            St := St + '-';

          if qryListe.Fields[i + 1].AsString = '0' then
            st := st + '>'
          else
            st := st + qryListe.Fields[i + 1].AsString;

          if st = '-' then
            st := qryListe.Fields[i + 2].AsString;
          Ekle := length(St);
          for j := Ekle to 10 do
            st := st + ' ';
          St := Copy(St, 1, 10);
        end
        else if Fmt[Length(Fmt)] = 'ç' then
        begin
          if (qryListe.Fields[i].AsString = '0') or
            (qryListe.Fields[i].AsString = ' ') then
            st := Format('%-10s', [qryListe.Fields[i + 1].AsString])
          else
            st := Format('%-10s', [qryListe.Fields[i].AsString]);
          St := Copy(St, 1, 10);
        end
        else if Fmt[Length(Fmt)] = 's' then
          st := Format(fmt, [qryListe.Fields[i].AsString]);
        str := str + st;
//          end else
//             s := s + qryListe.Fields[i].AsString;
      end;
      Writeln(F, str);
      qryListe.next;
    end;
    CloseFile(F);
    ShowMessage(DosyayaYazmaBitti);
  end;
end;

procedure TDokumDlg.DosyaAyarlar1Click(Sender: TObject);
begin
  GridIniDuzenle(TabDokum.FieldByName('RAPORADI').AsString, TRaporAraclari.Ini, 4, '', 1);
end;


procedure TDokumDlg.ExceleYazdir(Table1: TFDQuery; Grid1: TDBGrid);
var v, wb, sheet: variant;
    i : Integer;
    kol : Integer;
    j : Integer;
begin
  str := '';
  MesajStrAl('', 'Excel Dosya Adýný Dizinli Giriniz :', 'E', nil, str, '', 'E', nil, str);
  if str = '' then exit;

  v := CreateOleObject('Excel.Application');
  wb := v.WorkBooks.Add();
//   v.visible := True;
//   v.WorkBooks.Open(s+'.xls',0,False);
  sheet := v.WorkBooks[1].WorkSheets[1];

//   for j := 0 to Table1.Fields.Count -1 do
//      Sheet.Cells[1, j+1] := Table1.Fields[j].FieldName;
  kol := 0;
  for i := 0 to Grid1.Columns.Count - 1 do
    if Grid1.Columns[i].Visible then
    begin
      inc(kol);
      Sheet.Cells[1, kol] := Grid1.Columns[i].FieldName;
    end;

  Table1.first; i := 1;
  while not Table1.eof do
  begin
    inc(i); kol := 0;
    for j := 0 to Grid1.Columns.Count - 1 do
      if Grid1.Columns[j].Visible then
      begin
        inc(kol);
        Sheet.Cells[i, kol] := Table1.FieldByName(Grid1.Columns[j].FieldName).AsString;
      end;
    Table1.next;
  end;
//   V.DisplayAlerts := False;
  wb.SaveAs(str);
  v.Quit;
  Showmessage(MTExceleAktarildi);
end;

procedure TDokumDlg.ModullerClick(Sender: TObject);
begin
  St := TabDokum.FieldByName('MODUL').AsString;
  R.Checked := Pos('R', St) > 0;
  C.Checked := Pos('C', St) > 0;
  K.Checked := Pos('K', St) > 0;
  B.Checked := Pos('B', St) > 0;
  F.Checked := Pos('F', St) > 0;
  S.Checked := Pos('S', St) > 0;
  U.Checked := Pos('U', St) > 0;
  T.Checked := Pos('T', St) > 0;
  P.Checked := Pos('P', St) > 0;
  E.Checked := Pos('E', St) > 0;
  O.Checked := Pos('O', St) > 0;
end;

procedure TDokumDlg.OrjinalExcel1Click(Sender: TObject);
var
  book,excel,sheet:variant;
  i,a:integer;
  isimAciklama :String;
begin
  i := 2;
  try
    excel := createoleobject('excel.application');
    book  := excel.workbooks.add;
    excel.visible := true;
    sheet := book.worksheets[1];
  except
     raise exception.Create('Excel Açýlamadý..');
  end;
  try

    for a := 0 to qryListe.FieldCount - 1 do begin
        sheet.cells[1,a+1]:=qryListe.Fields[a].FieldName;
    end;

    qryListe.First;
    while not qryListe.Eof do begin
       for a := 0 to qryListe.FieldCount-1 do begin
         sheet.cells[i,a+1]:= qryListe.FieldByName(qryListe.Fields[a].FieldName).AsString;
       end;
      inc(i);
      qryListe.Next;
    end;

  finally
      Application.Messagebox(PChar(DExele_kaydedildi),Pchar(Uyari),MB_OK);
  end;

end;

procedure TDokumDlg.Panel4Paint(Sender: TObject);
begin
  GradientFillRect(TJvPanel(Sender).Canvas,TJvPanel(Sender).ClientRect,clWhite,$00D6D6D6,fdTopToBottom,255);
end;

procedure TDokumDlg.PopupMenu2Popup(Sender: TObject);
begin
   CariKartAcMenu.Visible := qryListe.Fields.FindField('REHBERID') <> nil;
   StokKartAcMenu.Visible := qryListe.Fields.FindField('STOKID') <> nil;
end;

procedure TDokumDlg.CClick(Sender: TObject);
begin
  if TMenuItem(Sender).Name = TRaporAraclari.Modul then Exit;
  TMenuItem(Sender).Checked := not TMenuItem(Sender).Checked;
  St := TabDokum.FieldByName('MODUL').AsString;
  if TMenuItem(Sender).Checked then
    St := St + TMenuItem(Sender).Name
  else
    Delete(St, Pos(TMenuItem(Sender).Name, St), 1);
  TabDokum.Edit;
  TabDokum.FieldByName('MODUL').AsString := St;
  TabDokum.Post;
end;


procedure TDokumDlg.HerkesteGrnsn1Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(DRapor_gorulecek_onayi),PChar(Onay), mb_YESNO) <> IDYES then exit;
 { Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Delete from KULHAR '+
    'Where EKRAN = &ekran',['&ekran'],[
    TabDokum.AsString['RAPORADI']]); }
end;

procedure TDokumDlg.KimsedeGrnmesin1Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(DRapor_gorulmeyecek_onayi),PChar(Onay), mb_YESNO) <> IDYES then exit;
  {Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Delete from KULHAR '+
    'Where EKRAN = &ekran',['&ekran'],[TabDokum.AsString['RAPORADI']]);  }
  with Veritabani.SorguBaslat(Tablo.FDCnn,'Select KULLANICI From KULLANICI',[],[]) do
  try
    Open;
    while not Eof do begin
      if KullanAdi <> AsString[0] then
      begin
       { Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,
          'Insert Into KULHAR (KULLANICIADI, EKRAN, GORME, EKLEME, DEGISTIRME, SILME, BILGI)Values(&kadi,&dadi,' +
          '''0'',''0'',''0'',''0'','''')',['&kadi','&dadi'],[
            AsString[0],TabDokum.AsString['RAPORADI']]);   }
      end;
      Next;
    end;
  finally
    Free;
  end;

end;

procedure TDokumDlg.DokumuKaydet(DokumAdi: string);
var
  F: Textfile;
begin
  SaveDialog1.Title := 'Kaydetme';
  SaveDialog1.DefaultExt := 'sql';

  if Screen.ActiveForm.Name = 'DokumDlg' then
    DokumAdi := TabDokum.Fields[0].AsString;

  SaveDialog1.FileName := DokumAdi + '.sql';

  if Screen.ActiveForm.Name <> 'DokumDlg' then
    DokumAdi := DokumAdi + '_';

  if SaveDialog1.Execute then
  begin
    with Veritabani.SorguBaslat(Tablo.FDCnn, StringReplace(TabKomut.SQL.Text, 'Ýþlem Sayý', DokumAdi, [rfReplaceAll]),[],[]) do
    try
      Open;
      AssignFile(F, SaveDialog1.FileName);
      try
        Rewrite(F);
        while not Eof do begin
          writeln(F, Fields[0].AsString);
          Next;
        end;
        CloseFile(F);
      except
        on EInOutError do
          MessageDlg('File I/O error.', mtError, [mbOk], 0);
      end;
    finally
      Free;
    end;
  end;
end;

procedure TDokumDlg.RaporKaydet1Click(Sender: TObject);
begin
  DokumuKaydet(TabDokum.FieldByName('RAPORADI').AsString);
end;

procedure TDokumDlg.DokumuAl(DokumAdi: string);
var str: string;
  Memo1: TMemo;

begin
  GetDir(0, str);
  OpenDialog1.InitialDir := str;
  OpenDialog1.Title := 'Rapor Alma/Ekleme';
  if OpenDialog1.Execute then begin

//    Memo1.Lines.LoadFromFile(OpenDialog1.FileName);
      //Tablo.qryListe.SQL.Text := Memo1.Lines.Text;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.LoadFromFile(OpenDialog1.FileName);
//      Tablo.qryListe.SQL.Text := StringReplace(Tablo.qryListe.SQL.Text, #0,' ' ,[rfReplaceAll]);
  //  Memo1.Free;
    Tablo.Query1.ExecSQL;
  end;
end;

procedure TDokumDlg.TopluFaturaEkle(Kime, Baslik: string);
var Tutar: string;
  i: smallint;
  Eklenebilir: Boolean;
  ss: array[0..200] of char;
  Lotno: string;
  function LotNoAl: string;
  var MesajOkunan: string;
  begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'Select Max(cast(LOTNO as Integer)) from FATBASLIK where isnumeric(LOTNO)=1';
    Tablo.Query1.Open;
    MesajOkunan := IntToStr(Tablo.Query1.Fields[0].AsInteger + 1);

    if not MesajStrAl('', 'Lot No Giriniz :', 'E', nil, MesajOkunan, '', 'E', nil, MesajOkunan) then
      exit;
    if MesajOkunan = '' then
      LotNoAl := '0'
    else
      LotNoAl := MesajOkunan;
  end;
begin
  Lotno := LotNoAl;
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := 'Select DOSYANO, GELISNO, isnull(SUM(TUTAR),0) AS TUTAR from( ';
  for i := 0 to Komut.Count - 1 do
    if (Komut.Strings[i] <> '') and (pos('ORDER', uppercase(Komut.Strings[i])) = 0) then
      Tablo.Query5.SQL.Add(Komut.Strings[i]);
  Tablo.Query5.SQL.Add(')AS PARA ');
  Tablo.Query5.SQL.Add('GROUP BY DOSYANO, GELISNO');
  Tablo.Query5.SQL.Add('ORDER BY DOSYANO, GELISNO');
  Tablo.Query5.Open;

  while not Tablo.Query5.eof do begin
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'Select Isnull(Max(KARTNO),0)+1 from FATBASLIK ' +
      ' where DOSYANO = ''' + Tablo.Query5.FieldByName('DOSYANO').AsString + '''' +
      '   and GELISNO = ' + Tablo.Query5.FieldByName('GELISNO').AsString;
    Tablo.Query3.Open;

    Eklenebilir := True;

    if Tablo.Query3.Fields[0].AsInteger > 1 then begin //daha önce fatura kesilmiþ mi bakalýmmmm
      Tablo.Query4.Close;
      Tablo.Query4.SQL.Text := 'Select FATBASLIK.DOSYANO,KARTNO, AD,SOYAD,FATURATARIH, FATURA_TUTARI from FATBASLIK,KIMLIK ' +
        ' where FATBASLIK.DOSYANO=KIMLIK.DOSYANO and FATBASLIK.DOSYANO = ''' + Tablo.Query5.FieldByName('DOSYANO').AsString + '''' +
        ' and GELISNO = ' + Tablo.Query5.FieldByName('GELISNO').AsString +
        ' and KIME=''' + Kime + ''' ORDER BY KARTNO DESC';
      Tablo.Query4.Open;

      if Tablo.Query4.RecordCount > 0 then
        StrPCopy(ss, 'Hasta:' + Tablo.Query4.FieldByName('AD').AsString + ' ' +
          Tablo.Query4.FieldByName('SOYAD').AsString + #13#10' Fat Tarih:' +
          copy(Tablo.Query4.FieldByName('FATURATARIH').AsString, 1, 10) + #13#10 +
          ' Fat.Tutarý:' + Format('%-10m', [Tablo.Query4.FieldByName('FATURA_TUTARI').AsCurrency]) +
          #13#10 + ' Eklenecek Tutar:' + Format('%-10m', [Tablo.Query5.FieldByName('TUTAR').AsCurrency]));

      if Application.MessageBox(ss, PChar(DEklenmis_fat_tekrar_eklensinmi),  mb_YESNO) <> IDYES then Eklenebilir := False;
    end;

    if Eklenebilir then begin
         ///Hastaya fatura baþlýðý

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Insert Into FATBASLIK (DOSYANO, GELISNO, KARTNO,BELGE,KIME,FATURATARIH,FATURANO,BASLIK,' +
        ' KDVDURUM,LOTNO,KATKIYUZDE,FATURA_TUTARI,KULLANICI,SUBEID) values(''' + Tablo.Query5.FieldByName('DOSYANO').AsString +
        ''',' + Tablo.Query5.FieldByName('GELISNO').AsString + ',' + Tablo.Query3.Fields[0].AsString + ',''FATURA'',''' +
        'Sanal'',''' + FormatDateTime('yyyy-mm-dd 00:00:00', StrToDateTime(FatTar)) + ''',''' + FatNo + ''',''' + Kime +
        ''',''Hariç'',' + Lotno + ',100,' + Tablo.Query5.FieldByName('TUTAR').AsString + ',''' + Kullanan + ''','+IntToStr(SubeId)+')';
      Tablo.Query1.ExecSQL;

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'update GELISLER set FATURATARIH=''' + FormatDateTime('yyyy-mm-dd 00:00:00',
        StrToDateTime(FatTar)) + ''', FATURANO=''' + FatNo + ''' where DOSYANO=''' +
        Tablo.Query5.FieldByName('DOSYANO').AsString + ''' and GELISNO=' + Tablo.Query5.FieldByName('GELISNO').AsString;
      Tablo.Query1.ExecSQL;
    end;
    Tablo.Query5.next;
  end;
  showmessage(OSIslemTamamlandi);
end;


procedure TDokumDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Return then
    DokumTus.Click;
end;

procedure TDokumDlg.EkranDegisveKonumlan(ID:Integer);
begin
      with FFrameBilgi.AramaFrameYoneticisi.FrameBul(TDokumAramaFrame).Ornek as TDokumAramaFrame do begin
        DokumleriYerlestir(TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi);
        TabDokum.Locate('ID',ID,[]);
      end;
end;

procedure TDokumDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      if Veritabani.VeriVarMi(Tablo.FDCnn,'select ID from KOSULLAR where DOKUMID = $PID', ['PID'], [TabDokum.Fields[0].AsInteger]) then
         raise exception.Create('Önce Koþullarý Silmelisiniz...');
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'DELETE FROM AYARLARYENI WHERE DOKUMID = &ID', ['&ID'],[TabDokum.Fields[0].AsInteger]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'DELETE FROM DOKUMLER WHERE ID = &ID', ['&ID'],[TabDokum.Fields[0].AsInteger]);
      EkranDegisveKonumlan(0);
  end;
end;

procedure TDokumDlg.DokumIslemi;
var Kosullar: array[1..10] of string[50];
  Yeri: integer;
  s: string;
  i : Integer;
  j : Integer;
begin
  Komut.Clear;
//  Komut.Clear;
  KosullariKaydet;
//  TabDokum.Refresh;
//  DokumSartDlg.TabDokum.FindKey([TabDokum.FieldByName('RAPORADI').AsString]);
  if TabDokum.FieldByName('SQL').AsString <> '' then begin
    Komut.Assign(TabDokum.FieldByName('SQL'));
    komut.Text := StringReplace(komut.Text,'%KullanýcýKodu%',Kullanan,[rfReplaceAll]);
    komut.Text := StringReplace(komut.Text,'%KullanýcýAdý%',KullanAdi,[rfReplaceAll]);

    i := 0; //Koþullarý Diziye Al
    TabKosul.First;
    while not TabKosul.eof do
    begin
      inc(i);
      if TabKosul.FieldByName('ICERIKTURU').AsInteger = 5 then //date
         s := FormatDateTime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy', StrToDateDef(TabKosul.FieldByName('DEGER').AsString, Tablo.GENINI.BugunTrh))//date
      else
         s := TabKosul.FieldByName('DEGER').AsString;
      Komut.Text := StringReplace(komut.Text, '$'+TabKosul.FieldByName('KOD_ADI').AsString+'$', s, [rfReplaceAll]);
      TabKosul.next;
    end;

    qryListe.Close;
    qryListe.SQL.Text := Komut.Text;
    qryListe.open;



  end else
    ShowMessage(SQLBulunamadi);
end;

constructor TDokumDlg.Create(AOwner: TComponent);
begin
  inherited;
//  ComboList := TComponentList.Create(False);
  TableAdlari := TStringList.Create;
  GroupByList := TStringlist.Create;
  Komut := TStringList.Create;
  TableBagList := TStringlist.Create;
  EskiRapor := '';
//  DragAcceptFiles(Handle, True);
end;

procedure TDokumDlg.CreateGridFields(const tvCaption, tvFieldName, tvProperties: string; tvMerging, tvalign: boolean; tvWidth: integer);
begin
  with DBTable.CreateColumn do
  begin
    Caption := tvCaption;
    DataBinding.FieldName := tvFieldName;
    DataBinding.ValueType := tvProperties;
    HeaderAlignmentHorz := taCenter;
    HeaderAlignmentVert :=  cxClasses.vaCenter;
    Name := 'tv' + tvFieldName;
    Options.CellMerging := tvMerging;

    if tvProperties = 'DateTime' then
    begin
      PropertiesClass := TcxDateEditProperties;
      TcxDateEditProperties(Properties).ShowTime := true;
      if tvalign = true then
        TcxTextEditProperties(Properties).Alignment.Horz := taCenter;
    end;
    if tvProperties = 'Float' then
    begin
      PropertiesClass := TcxSpinEditProperties;
      TcxSpinEditProperties(Properties).ValueType:=vtFloat;
    end;
    //width := tvWidth;
  end;
end;

procedure TDokumDlg.cxDBCheckBox1Click(Sender: TObject);
begin
   TabDokum.Edit;
   TabDokum.Post;
end;

function TDokumDlg.FieldTypeBul(FieldType: TFieldType): string;
begin
  case FieldType of
    ftUnknown: Result := '';
    ftString: Result := 'String';
    ftSmallInt: Result := 'Float';
    ftInteger: Result := 'Float';
    ftWord: Result := 'Float';
    ftBoolean: Result := 'Boolean';
    ftFloat: Result := 'Float';
    ftCurrency: Result := 'Float';
    ftBCD: Result := 'Float';
    ftDate: Result := 'DateTime';
    ftTime: Result := 'DateTime';
    ftDateTime: Result := 'DateTime';
    ftBytes: Result := 'Float';
    ftVarBytes: Result := 'Float';
    ftBlob: Result := '';
    ftMemo: Result := '';
    ftGraphic: Result := '';
    ftAutoInc: Result := '';
    ftFmtMemo: Result := '';
    ftParadoxOle: Result := '';
    ftDBaseOle: Result := '';
    ftTypedBinary: Result := '';
  end;
end;


procedure TDokumDlg.DokumTabloAc(Modul: String; Standart1, Durum:smallint);
begin
  Standart := Standart1;
  YeniTus.Visible := (Dokum_Degis_Yetki)or(Standart=0);
  SilTus.Visible := (Dokum_Degis_Yetki)or(Standart=0);
  BuDkmzelBlmeKopyala1.Visible := (Standart=1)and(RolID='-1');
  LabelOzel.Visible := Standart<>1;
  TabloYenile(TabDokum, ['%' + Modul + '%', RolID, Standart, Durum]);
  TabDokum.First;
end;

procedure TDokumDlg.DokumTusClick(Sender: TObject);
var Tplm : tcxDataSummaryItem;
       i : Integer;
         AItem: TcxGridDBcolumn;
begin
  Splitter1.CloseSplitter;
  Siralama := '0';
  DokumIslemi;
  dosyanovar := false;
  while DBTable.ColumnCount > 0 do
    DBTable.Columns[0].Destroy;
  DBTable.DataController.CreateAllItems;
  DBTable.DataController.Summary.FooterSummaryItems.Add(DBTable.Columns[0],spFooter,skCount);
  DBTable.ApplyBestFit(nil);
  Tablo.GridAyarRestore('Dokum-'+TabDokum.Fields[0].AsString, DBTable );
  // 23.09.2025  Grid'deki tüm sütunlarda döngü yap
  for i := 0 to DBTable.ColumnCount - 1 do
  begin
    AItem := DBTable.columns[i];

    // Eðer sütun bir veritabaný alanýna baðlýysa ve veri tipi kontrol edilebilir durumdaysa
    if Assigned(AItem.DataBinding.Field) then begin
      // Veri tipini kontrol et
      case AItem.DataBinding.Field.DataType of
        ftFloat, ftCurrency, ftBCD, ftFMTBcd:
        begin
          // Sütunun özelliklerini para birimi düzenleme özelliklerine dönüþtür
          AItem.PropertiesClassName := 'TcxCurrencyEditProperties';

          // Gerekirse biçimlendirme ayarlarýný yap
          // TcxCurrencyEditProperties(AItem.Properties).DisplayFormat := 'c'; // Windows ayarlarýný kullanýr

          // Ýsteðe baðlý olarak, farklý bir format belirleyebilirsiniz
          TcxCurrencyEditProperties(AItem.Properties).DisplayFormat := '#,##0.00';
        end;
      end;
    end;
  end;




  (* 26.05.24
  for I := 0 to DBTable.ColumnCount - 1 do begin
         if DBTable.Columns[i].DataBinding.ValueType = 'Currency' then
           DBTable.Columns[i].RepositoryItem := Tablo.RepCurrencyGenel
         else if DBTable.Columns[i].DataBinding.ValueType = 'Float' then
           DBTable.Columns[i].RepositoryItem := Tablo.RepCurrencyGenel;

  end;   *)
  // 26.05.25 AO alt toplamlar
{AO 06.06.2025 bazý raporlarda  hata verdiði için çýkardým
  for I := 0 to qryListe.fieldcount-1 do
     if qryListe.fields[I].datatype in [ftfloat,ftCurrency, ftBCD, ftFMTBcd] then begin
        //showmessage(qryListe.fields[I].FieldName);
          try
            DBTable.Columns[I].RepositoryItem := Tablo.RepCurrencyGenel;

            Tplm := DBTable.DataController.Summary.FooterSummaryItems.Add(DBTable.Columns[I],spFooter,skSum);
            Tplm.format := ',0.00;(,0.00)';
          except
            on ExDMCreate001:exception  do
            begin

            end;
          end;

     end;    }

end;

procedure TDokumDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumDlg.KapatTusClick(Sender: TObject);
begin
  GridExport(DBGrid1, 'XLS', TabDokum.Fields[0].AsString);
end;

procedure TDokumDlg.Text1Click(Sender: TObject);
begin
  GridExport(DBGrid1, 'TXT', TabDokum.Fields[0].AsString);
end;

procedure TDokumDlg.HTML1Click(Sender: TObject);
begin
  GridExport(DBGrid1, 'HTM', TabDokum.Fields[0].AsString);
end;

procedure TDokumDlg.DBTableCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
    AnaForm.cxGridPopupMenu1.Grid:=DBGrid1;
    AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=DBTable;
    AnaForm.pmGridStil.Tags.Values[DBGrid1.Name]:='Dokum-'+TabDokum.Fields[0].AsString;
end;

procedure TDokumDlg.DBTableMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//  QuantGrid.dxDBGridMouseUp(SENDER,BUTTON,SHIFT,X, Y,QuantGrid.pmHeader);
end;

destructor TDokumDlg.Destroy;
begin
//  ComboList.Free;
  ScrollBox2 := nil;
  TableAdlari.Free;
  GroupByList.Free;
  Komut.Free;
  TableBagList.Free;
  inherited;
end;

procedure TDokumDlg.XML1Click(Sender: TObject);
begin
  GridExport(DBGrid1, 'XML', TabDokum.Fields[0].AsString);
end;

procedure TDokumDlg.Excel1Click(Sender: TObject);
begin
   GridExport(DBGrid1, 'XLS', TabDokum.Fields[0].AsString);
end;

initialization
  RegisterClass(TDokumDlg);

finalization
end.










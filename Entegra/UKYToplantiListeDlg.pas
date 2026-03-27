unit UKYToplantiListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls, 
  UServisAramaFrame, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,
  cxSplitter, cxPC, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky,Utablo,
  cxCheckBox, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData,
  cxLookAndFeels, cxNavigator, dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxDateRanges,
  dxScrollbarAnnotations;

type
  TKYToplantiListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton1: TToolButton;
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
    SilTus: TToolButton;
    TabToplanti: TFDQuery;
    DtsToplanti: TDataSource;
    frxToplanti: TfrxDBDataset;
    DBToplanti: TcxGridDBTableView;
    GridToplantiLevel1: TcxGridLevel;
    GridToplanti: TcxGrid;
    ADI: TcxGridDBColumn;
    BASLAMATARIHI: TcxGridDBColumn;
    TOPLANTIYERI: TcxGridDBColumn;
    EKLEYEN: TcxGridDBColumn;
    DURUM: TcxGridDBColumn;
    DBToplantiID: TcxGridDBColumn;
    DBToplantiPROJE: TcxGridDBColumn;
    DBToplantiKURUM: TcxGridDBColumn;
    DBToplantiSUBEID: TcxGridDBColumn;
    DBToplantiTOPLANTINO: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    Kopyala1: TMenuItem;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure DegisTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DBToplantiCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure TabToplantiAfterOpen(DataSet: TDataSet);
    procedure DBToplantiCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure Kopyala1Click(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TServisAramaFrame;
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
    procedure StokListeDlgKapatEylemi(Sender: TObject);
    procedure StokListeDlgEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TServisAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

    function EkranAdiAl : string;
  public
    { Public declarations }
  published
    property Arama : TServisAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UServisWizard, URaporAraclari, UGenelAnaSekmeFrame,
  UFastRap, PrjConst, UKaliteToplanti;

{$R *.dfm}
{ TEkipmanListeDlg }

var SQLMemo:string;
    OncekiSayfaIndex : SmallInt;


function TKYToplantiListeDlg.EkranAdiAl: string;
begin
   Result := SERWServisEkipman;
end;

procedure TKYToplantiListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxToplanti);
end;

procedure TKYToplantiListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKYToplantiListeDlg.Baslatildi;
begin
  TabloYenile(TabToplanti,[]);
  DBToplanti.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KaliteToplantiGridi',true,false,[gsoUseFilter],'KaliteToplantiGridi');
end;

procedure TKYToplantiListeDlg.cxDBTreeList1DblClick(Sender: TObject);
begin
  DegisTusClick(Self);
end;

procedure TKYToplantiListeDlg.DBToplantiCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridToplanti;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=DBToplanti;
   AnaForm.pmGridStil.Tags.Values[GridToplanti.Name] := 'KaliteToplantiGridi';
end;

procedure TKYToplantiListeDlg.DBToplantiCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
DegisTus.Click;
end;

procedure TKYToplantiListeDlg.DegisTusClick(Sender: TObject);
var
  LocateToplantiID:Integer;
begin
  LocateToplantiID := Tablo.ToplantiSihirbazBaslat('D',TabToplanti.FieldByName('ID').AsInteger);
  TabloYenile(TabToplanti,[]);
  //locate olacak...
end;

procedure TKYToplantiListeDlg.GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYToplantiListeDlg.GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYToplantiListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TKYToplantiListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKYToplantiListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKYToplantiListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKYToplantiListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TKYToplantiListeDlg.Gorunmez;
begin

end;

procedure TKYToplantiListeDlg.GorunmezOlacak;
begin

end;

procedure TKYToplantiListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TKYToplantiListeDlg.GorunurOlacak;
begin

end;

procedure TKYToplantiListeDlg.GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYToplantiListeDlg.GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYToplantiListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TKYToplantiListeDlg.Kopyala1Click(Sender: TObject);
var yeniID:integer;
begin
  yeniID:=Tablo.SQLSatiriKopyala('KALITETOPLANTI', TabToplanti.FieldByName('ID').AsInteger,['TOPLANTINO','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],['YeniKod',Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);

  Tablo.ToplantiSihirbazBaslat('K',yeniID);
  TabloYenile(TabToplanti,[]);
end;

procedure TKYToplantiListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TKYToplantiListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin

end;

procedure TKYToplantiListeDlg.SetArama(const Value: TServisAramaFrame);
var k : word;
  YeniEkipmanID : Integer;
begin
  FArama := Value;
  with FArama do begin
    AraTarihBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    AraTarihBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));
    TabloYenile(TabToplanti,[]);
    { Arama olay atamasý }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanýmlamayý AnaForm'daki AramaFrame OlayBaglamalari tag'ýnda gerçekleþtirebilirsiniz.  }
    { Detaylý bilgi için AnaForm'daki örneklere bakýnýz. }
  end;
end;

procedure TKYToplantiListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;



procedure TKYToplantiListeDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Tablo.ToplantiSil(TabToplanti.FieldByName('ID').AsInteger);
      TabloYenile(TabToplanti,[]);
   end;
end;

procedure TKYToplantiListeDlg.TabToplantiAfterOpen(DataSet: TDataSet);
begin
  DegisTus.Visible   := TabToplanti.RecordCount>0;
   SilTus.Visible := DegisTus.Visible;
   //DBToplanti.ApplyBestFit(nil);
end;

procedure TKYToplantiListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYToplantiListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKYToplantiListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYToplantiListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKYToplantiListeDlg.YeniTusClick(Sender: TObject);
var
  ToplantiID : Integer;
begin
  ToplantiID := Tablo.ToplantiSihirbazBaslat('E',0);
  TabloYenile(TabToplanti,[]);

end;

initialization
  RegisterClass(TKYToplantiListeDlg);
end.


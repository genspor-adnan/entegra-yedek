unit UKYEgitimListeDlg;
  		
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
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations;

type
  TKYEgitimListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
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
    TabEgitim: TFDQuery;
    DtsEgitim: TDataSource;
    frxEgitim: TfrxDBDataset;
    GridEgitim: TcxGrid;
    GridEgitimView: TcxGridDBTableView;
    GridEgitimLevel3: TcxGridLevel;
    GridEgitimViewEGITIMTURU: TcxGridDBColumn;
    GridEgitimViewEGITIMSORUMLU: TcxGridDBColumn;
    GridEgitimViewDURUM: TcxGridDBColumn;
    GridEgitimViewREHBERID: TcxGridDBColumn;
    GridEgitimViewEGITIMKONUSU: TcxGridDBColumn;
    GridEgitimViewEGITIMBITISTARIHI: TcxGridDBColumn;
    GridEgitimViewEGITIMBASLAMATARIHI: TcxGridDBColumn;
    GridEgitimViewID: TcxGridDBColumn;
    GridEgitimViewEGITIMNO: TcxGridDBColumn;
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
    procedure TabEgitimAfterOpen(DataSet: TDataSet);
    procedure GridEgitimViewCanFocusRecord(Sender: TcxCustomGridTableView;
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
  UFastRap, PrjConst;

{$R *.dfm}
{ TEkipmanListeDlg }

var SQLMemo:string;
    OncekiSayfaIndex : SmallInt;


function TKYEgitimListeDlg.EkranAdiAl: string;
begin
   Result := SERWServisEkipman;
end;

procedure TKYEgitimListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxEgitim);
end;

procedure TKYEgitimListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKYEgitimListeDlg.Baslatildi;
begin
  TabloYenile(TabEgitim,[]);
   Tablo.GridAyarRestore('EgitimGridi', GridEgitimview );
end;

procedure TKYEgitimListeDlg.cxDBTreeList1DblClick(Sender: TObject);
begin
  DegisTusClick(Self);
end;

procedure TKYEgitimListeDlg.DegisTusClick(Sender: TObject);
var
  LocateEkipmanID:Integer;
begin
  LocateEkipmanID := Tablo.EgitimSihirbazBaslat('D',0,TabEgitim.FieldByName('ID').AsInteger,0);
  TabloYenile(TabEgitim,[]);
  //locate olacak...
end;

procedure TKYEgitimListeDlg.GridEgitimViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridEgitim;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridEgitimview;
  AnaForm.pmGridStil.Tags.Values[GridEgitim.Name]:='EgitimGridi';
end;

procedure TKYEgitimListeDlg.GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYEgitimListeDlg.GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYEgitimListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TKYEgitimListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKYEgitimListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKYEgitimListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKYEgitimListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TKYEgitimListeDlg.Gorunmez;
begin

end;

procedure TKYEgitimListeDlg.GorunmezOlacak;
begin

end;

procedure TKYEgitimListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TKYEgitimListeDlg.GorunurOlacak;
begin

end;

procedure TKYEgitimListeDlg.GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYEgitimListeDlg.GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYEgitimListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TKYEgitimListeDlg.Kopyala1Click(Sender: TObject);
var yeniID:integer;
begin
  yeniID:=Tablo.SQLSatiriKopyala('KALITEEGITIM', TabEgitim.FieldByName('ID').AsInteger,['EGITIMNO','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],['YeniKod',Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
  Tablo.EgitimSihirbazBaslat('K',0,yeniID,0);
  TabloYenile(TabEgitim,[]);
end;

procedure TKYEgitimListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TKYEgitimListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin

end;

procedure TKYEgitimListeDlg.SetArama(const Value: TServisAramaFrame);
var k : word;
  YeniEkipmanID : Integer;
begin
  FArama := Value;
  with FArama do begin
    AraTarihBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    AraTarihBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));
    TabloYenile(TabEgitim,[]);
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TKYEgitimListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKYEgitimListeDlg.SilTusClick(Sender: TObject);
var
i,ID:integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      begin
        for i := GridEgitimView.Controller.SelectedRecordCount - 1 downto 0 do
        begin
         ID := GridEgitimView.Controller.SelectedRecords[i].Values[GridEgitimViewID.Index];
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KALITEEGITIM where ID=&DokID', ['&DokID'], [ID]);
        end;
      end;
  TabloYenile(TabEgitim,[]);
end;

procedure TKYEgitimListeDlg.TabEgitimAfterOpen(DataSet: TDataSet);
begin
  SilTus.Visible := TabEgitim.RecordCount > 0;
  DegisTus.Enabled := SilTus.Enabled;
end;

procedure TKYEgitimListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYEgitimListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKYEgitimListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYEgitimListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKYEgitimListeDlg.YeniTusClick(Sender: TObject);
var
  YeniEkipmanID : Integer;
begin
  YeniEkipmanID := Tablo.EgitimSihirbazBaslat('E',0,0,0);
  TabloYenile(TabEgitim,[]);
end;

initialization
  RegisterClass(TKYEgitimListeDlg);
end.




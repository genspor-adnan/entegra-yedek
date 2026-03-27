unit UKYSapmaOlayListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, Menus,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxGraphics,
  UServisAramaFrame, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,
  cxSplitter, cxPC, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky,Utablo,
  cxCheckBox, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData,
  cxEditRepositoryItems, cxLookAndFeels, dxSkinLiquidSky, cxNavigator,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations;

type
  TKYSapmaOlayListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
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
    TabSapmaOlay: TFDQuery;
    DtsSapmaOlay: TDataSource;
    frxSapmaOlay: TfrxDBDataset;
    GridSapmaOlay: TcxGrid;
    GridSapmaOlayView: TcxGridDBTableView;
    GridSapmaOlayLevel3: TcxGridLevel;
    GridSapmaOlayViewSORUMLU: TcxGridDBColumn;
    GridSapmaOlayViewPROJEKODU: TcxGridDBColumn;
    GridSapmaOlayViewID: TcxGridDBColumn;
    GridSapmaOlayViewTARIH: TcxGridDBColumn;
    GridSapmaOlayViewREFERANSNO: TcxGridDBColumn;
    GridSapmaOlayViewDURUM: TcxGridDBColumn;
    GridSapmaOlayViewKATEGORI: TcxGridDBColumn;
    GridSapmaOlayViewTIPI: TcxGridDBColumn;
    GridSapmaOlayViewDEPARTMAN: TcxGridDBColumn;
    GridSapmaOlayViewSUBEID: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    Kopyala1: TMenuItem;
    GridSapmaOlayViewSORUMLU_ONAYLAYACAK: TcxGridDBColumn;
    GridSapmaOlayViewKONUSU: TcxGridDBColumn;
    GridSapmaOlayViewKAYITTARIHI: TcxGridDBColumn;
    GridSapmaOlayViewSORUMLU_ONAYLAYAN_TARIHI: TcxGridDBColumn;
    GridSapmaOlayViewURUNADI: TcxGridDBColumn;
    GridSapmaOlayViewSERINO: TcxGridDBColumn;
    GridSapmaOlayViewDOF: TcxGridDBColumn;
    GridSapmaOlayViewYORUM: TcxGridDBColumn;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure DegisTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure TabSapmaOlayAfterOpen(DataSet: TDataSet);
    procedure GridSapmaOlayViewCanFocusRecord(Sender: TcxCustomGridTableView;
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
    function KYSapmaOlaySihirbaz(IslemOp:char;Cagiran,ID:Integer):integer;

  public
    { Public declarations }
  published
    property Arama : TServisAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, URaporAraclari, UGenelAnaSekmeFrame,//UKYDuzelticiVeOnleyiciFaalWizard,
  UFastRap, PrjConst,LoconFly, UKYSapmaOlayWizard;

{$R *.dfm}
{ TEkipmanListeDlg }

var SQLMemo:string;
    OncekiSayfaIndex : SmallInt;
    DOF_ID : Integer;


function TKYSapmaOlayListeDlg .EkranAdiAl: string;
begin
   Result := SERWServisEkipman;
end;

procedure TKYSapmaOlayListeDlg .YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxSapmaOlay);
end;

procedure TKYSapmaOlayListeDlg .BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKYSapmaOlayListeDlg .Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TabloYenile(TabSapmaOlay,[]);
  //GridSapmaOlayView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KaliteToplantiGridi',true,false,[gsoUseFilter],'KaliteDOFGridi');
  Tablo.GridAyarRestore('KaliteDOFGridi',GridSapmaOlayView );
  Tablo.GridTurkcelestir;

end;

procedure TKYSapmaOlayListeDlg .DegisTusClick(Sender: TObject);
begin
   KYSapmaOlaySihirbaz('D', 0, TabSapmaOlay.FieldByName('ID').AsInteger);
end;

procedure TKYSapmaOlayListeDlg .GridSapmaOlayViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridSapmaOlay;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridSapmaOlayView;
   AnaForm.pmGridStil.Tags.Values[GridSapmaOlay.Name] := 'KaliteDOFGridi';
end;

procedure TKYSapmaOlayListeDlg .GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYSapmaOlayListeDlg .GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYSapmaOlayListeDlg .EkranYazdir(Sender: TObject);
begin

end;

procedure TKYSapmaOlayListeDlg .FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKYSapmaOlayListeDlg .FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKYSapmaOlayListeDlg .GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKYSapmaOlayListeDlg .GetKapatilabilir: Boolean;
begin

end;

procedure TKYSapmaOlayListeDlg .Gorunmez;
begin

end;

procedure TKYSapmaOlayListeDlg .GorunmezOlacak;
begin

end;

procedure TKYSapmaOlayListeDlg .Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TKYSapmaOlayListeDlg .GorunurOlacak;
begin

end;

procedure TKYSapmaOlayListeDlg .GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYSapmaOlayListeDlg .GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYSapmaOlayListeDlg .Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TKYSapmaOlayListeDlg.Kopyala1Click(Sender: TObject);
var yeniID:integer;
begin
   yeniID:=Tablo.SQLSatiriKopyala('KY_SAPMAOLAY', TabSapmaOlay.FieldByName('ID').AsInteger,['REFERANSNO','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],['YeniKod',Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
   KYSapmaOlaySihirbaz('K', 0, yeniID);
end;

procedure TKYSapmaOlayListeDlg .StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TKYSapmaOlayListeDlg .StokListeDlgKapatEylemi(Sender: TObject);
begin

end;

procedure TKYSapmaOlayListeDlg .SetArama(const Value: TServisAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
//    AraTarihBas.Date := StrToDateTime('01'+dateseparator+'01'+dateseparator+IntToStr(CariYil));
//    AraTarihBit.Date := StrToDateTime('31'+dateseparator+'12'+dateseparator+IntToStr(CariYil));
//    DateBitisBas.Date := AraTarihBas.Date;
//    DateBitisBit.Date := AraTarihBit.Date ;
//    DateTeslimBas.Date := AraTarihBas.Date;
//    DateTeslimBit.Date := AraTarihBit.Date ;
//    TabloYenile(TabSapmaOlay,[]);
    { Arama olay atamasý }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanýmlamayý AnaForm'daki AramaFrame OlayBaglamalari tag'ýnda gerçekleþtirebilirsiniz.  }
    { Detaylý bilgi için AnaForm'daki örneklere bakýnýz. }
  end;
end;

procedure TKYSapmaOlayListeDlg .SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKYSapmaOlayListeDlg .SilTusClick(Sender: TObject);
var
i,ID:integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     for i := GridSapmaOlayView.Controller.SelectedRecordCount - 1 downto 0 do begin
          ID := GridSapmaOlayView.Controller.SelectedRecords[i].Values[GridSapmaOlayViewID.Index];
          Tablo.SapmaOlaySil(ID);
     end;
  end;
  TabloYenile(TabSapmaOlay,[]);
end;

procedure TKYSapmaOlayListeDlg .TabSapmaOlayAfterOpen(DataSet: TDataSet);
begin
  SilTus.Enabled := TabSapmaOlay.RecordCount > 0;
  DegisTus.Enabled := SilTus.Enabled;
end;

procedure TKYSapmaOlayListeDlg .TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYSapmaOlayListeDlg .TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKYSapmaOlayListeDlg .TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYSapmaOlayListeDlg .YaziciYazdir(Sender: TObject);
begin

end;

function TKYSapmaOlayListeDlg.KYSapmaOlaySihirbaz(IslemOp:char;Cagiran,ID:Integer):integer;
begin
  Application.CreateForm(TKYSapmaOlayWizardDlg, KYSapmaOlayWizardDlg);
  KYSapmaOlayWizardDlg.Cagiran := Cagiran;
  KYSapmaOlayWizardDlg.DOF_ID := ID;
  KYSapmaOlayWizardDlg.IslemOp := IslemOp;
  KYSapmaOlayWizardDlg.ShowModal;

  if KYSapmaOlayWizardDlg.ModalResult = mrOk then
    DOF_ID := KYSapmaOlayWizardDlg.DOF_ID
  else
    DOF_ID := -99;
  KYSapmaOlayWizardDlg.Free;
  TabloYenile(TabSapmaOlay,[]);
end;


procedure TKYSapmaOlayListeDlg.YeniTusClick(Sender: TObject);
begin
   KYSapmaOlaySihirbaz('E', 0, -1);
end;

initialization
   RegisterClass(TKYSapmaOlayListeDlg );
end.


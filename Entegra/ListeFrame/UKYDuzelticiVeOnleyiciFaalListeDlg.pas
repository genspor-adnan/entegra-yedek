unit UKYDuzelticiVeOnleyiciFaalListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, 
  UServisAramaFrame, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,
  cxSplitter, cxPC, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky,Utablo,
  cxCheckBox, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData,
  cxEditRepositoryItems, cxLookAndFeels, dxSkinLiquidSky, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations;

type
  TKYDuzelticiVeOnleyiciFaalListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
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
    TabDOF: TFDQuery;
    DtsDOF: TDataSource;
    frxDOF: TfrxDBDataset;
    GridDOF: TcxGrid;
    GridDOFView: TcxGridDBTableView;
    GridDOFLevel3: TcxGridLevel;
    GridDOFViewID: TcxGridDBColumn;
    GridDOFViewTARIH: TcxGridDBColumn;
    GridDOFViewTIPI: TcxGridDBColumn;
    GridDOFViewHATAKAYNAGI: TcxGridDBColumn;
    GridDOFViewREHBERID: TcxGridDBColumn;
    GridDOFViewBIRIM: TcxGridDBColumn;
    GridDOFViewDOF_ACAN: TcxGridDBColumn;
    GridDOFViewDOF_SORUMLUSU: TcxGridDBColumn;
    GridDOFViewDURUM: TcxGridDBColumn;
    GridDOFViewDOFNO: TcxGridDBColumn;
    GridDOFViewACIL: TcxGridDBColumn;
    GridDOFViewONEMLI: TcxGridDBColumn;
    GridDOFViewKONU: TcxGridDBColumn;
    GridDOFViewKATEGORI: TcxGridDBColumn;
    GridDOFViewPROJE: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    Kopyala1: TMenuItem;
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
    procedure TabDOFAfterOpen(DataSet: TDataSet);
    procedure GridDOFViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure SilTusClick(Sender: TObject);
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

  function DOFSihirbazBaslat(IslemOp:char; Cagiran, DofID: Integer; Yer: Integer=0 ;YerId:Integer=0): Integer;
  procedure DOFSil(DofID: Integer);


implementation



uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, URaporAraclari, UGenelAnaSekmeFrame,UKYDuzelticiVeOnleyiciFaalWizard,
  UFastRap, PrjConst,LoconFly;

{$R *.dfm}
{ TEkipmanListeDlg }

var SQLMemo:string;
    OncekiSayfaIndex : SmallInt;
    DOF_ID : Integer;


function TKYDuzelticiVeOnleyiciFaalListeDlg.EkranAdiAl: string;
begin
   Result := SERWServisEkipman;
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxDOF);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TabloYenile(TabDOF,[]);
  //GridDOFView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KaliteToplantiGridi',true,false,[gsoUseFilter],'KaliteDOFGridi');
  Tablo.GridAyarRestore('KaliteDOFGridi',GridDOFView );
  Tablo.GridTurkcelestir;

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.GridDOFViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridDOF;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridDOFView;
   AnaForm.pmGridStil.Tags.Values[GridDOF.Name] := 'KaliteDOFGridi';
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKYDuzelticiVeOnleyiciFaalListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKYDuzelticiVeOnleyiciFaalListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.Gorunmez;
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.GorunmezOlacak;
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
  TabloYenile(TabDOF,[]);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.GorunurOlacak;
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.Kopyala1Click(Sender: TObject);
var yeniID:integer;
begin
  yeniID:=Tablo.SQLSatiriKopyala('KALITEDOF',TabDOF.FieldByName('ID').AsInteger,['DOFNO','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],['YeniKod',Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);

  if DOFSihirbazBaslat('K', 0, yeniID) > -99 then
     TabloYenile(TabDOF,[]);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.SetArama(const Value: TServisAramaFrame);
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
//    TabloYenile(TabDOF,[]);
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure DOFSil(DofID: Integer);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KALITEDOF where ID=&DokID', ['&DokID'], [ DofID ]);
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.SilTusClick(Sender: TObject);
begin
   DofSil(TabDOF.FieldByName('ID').AsInteger);
   TabloYenile(TabDOF,[]);
end;



procedure TKYDuzelticiVeOnleyiciFaalListeDlg.TabDOFAfterOpen(DataSet: TDataSet);
begin
  SilTus.Enabled := TabDOF.RecordCount > 0;
  DegisTus.Enabled := SilTus.Enabled;
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

function DOFSihirbazBaslat(IslemOp:char; Cagiran, DofID: Integer; Yer: Integer=0 ;YerId:Integer=0): Integer;
begin
   Application.CreateForm(TKYDuzelticiVeOnleyiciFaalWizardDlg, KYDuzelticiVeOnleyiciFaalWizardDlg);
   KYDuzelticiVeOnleyiciFaalWizardDlg.Cagiran := Cagiran;
   KYDuzelticiVeOnleyiciFaalWizardDlg.DOF_ID := DofID;
   KYDuzelticiVeOnleyiciFaalWizardDlg.IslemOp := IslemOp;
   KYDuzelticiVeOnleyiciFaalWizardDlg.Yer := Yer;
   KYDuzelticiVeOnleyiciFaalWizardDlg.YerId:= YerId;
   KYDuzelticiVeOnleyiciFaalWizardDlg.ShowModal;

   if KYDuzelticiVeOnleyiciFaalWizardDlg.ModalResult = mrOk then
      DOF_ID := KYDuzelticiVeOnleyiciFaalWizardDlg.DOF_ID
   else
      DOF_ID := -99;
   KYDuzelticiVeOnleyiciFaalWizardDlg.Free;
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.YeniTusClick(Sender: TObject);
begin
  if DOFSihirbazBaslat('E', 0,-1) > -99 then
     TabloYenile(TabDOF,[]);
end;

procedure TKYDuzelticiVeOnleyiciFaalListeDlg.DegisTusClick(Sender: TObject);
begin
  if DOFSihirbazBaslat('D', 0, TabDOF.FieldByName('ID').AsInteger) > -99 then
     TabloYenile(TabDOF,[]);
end;

initialization
  RegisterClass(TKYDuzelticiVeOnleyiciFaalListeDlg);
end.




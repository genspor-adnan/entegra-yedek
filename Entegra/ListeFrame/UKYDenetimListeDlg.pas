unit UKYDenetimListeDlg;
  		
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
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  frCoreClasses, FireDAC.Comp.DataSet;

type
  TKYDenetimListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
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
    TabDenetim: TFDQuery;
    DtsDenetim: TDataSource;
    frxDOF: TfrxDBDataset;
    GridDOF: TcxGrid;
    GridDOFView: TcxGridDBTableView;
    GridDOFLevel3: TcxGridLevel;
    GridDOFViewKURUM: TcxGridDBColumn;
    GridDOFViewSORUMLU: TcxGridDBColumn;
    GridDOFViewDENETCI: TcxGridDBColumn;
    GridDOFViewPROJEKODU: TcxGridDBColumn;
    GridDOFViewID: TcxGridDBColumn;
    GridDOFViewTARIH: TcxGridDBColumn;
    GridDOFViewDENETIMNO: TcxGridDBColumn;
    GridDOFViewDURUM: TcxGridDBColumn;
    GridDOFViewKATEGORI: TcxGridDBColumn;
    GridDOFViewTIPI: TcxGridDBColumn;
    GridDOFViewADI: TcxGridDBColumn;
    GridDOFViewDEPARTMAN: TcxGridDBColumn;
    GridDOFViewBASLAMATARIHI: TcxGridDBColumn;
    GridDOFViewBITISTARIHI: TcxGridDBColumn;
    GridDOFViewSUBEID: TcxGridDBColumn;
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
    procedure SilTusClick(Sender: TObject);
    procedure TabDenetimAfterOpen(DataSet: TDataSet);
    procedure GridDOFViewCanFocusRecord(Sender: TcxCustomGridTableView;
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
    function DenetimSihirbaz(IslemOp:char;Cagiran,ID:Integer):integer;

  public
    { Public declarations }
  published
    property Arama : TServisAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, URaporAraclari, UGenelAnaSekmeFrame,UKYDuzelticiVeOnleyiciFaalWizard,
  UFastRap, PrjConst,LoconFly, UKYDenetimWizard;

{$R *.dfm}
{ TEkipmanListeDlg }

var SQLMemo:string;
    OncekiSayfaIndex : SmallInt;
    DOF_ID : Integer;


function TKYDenetimListeDlg .EkranAdiAl: string;
begin
   Result := SERWServisEkipman;
end;

procedure TKYDenetimListeDlg .YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxDOF);
end;

procedure TKYDenetimListeDlg .BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKYDenetimListeDlg .Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TabloYenile(TabDenetim,[]);
  //GridDOFView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KaliteToplantiGridi',true,false,[gsoUseFilter],'KaliteDOFGridi');
  Tablo.GridAyarRestore('KaliteDOFGridi',GridDOFView );
  Tablo.GridTurkcelestir;

end;

procedure TKYDenetimListeDlg .DegisTusClick(Sender: TObject);
begin
   DenetimSihirbaz('D', 0, TabDenetim.FieldByName('ID').AsInteger);
end;

procedure TKYDenetimListeDlg .GridDOFViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridDOF;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridDOFView;
   AnaForm.pmGridStil.Tags.Values[GridDOF.Name] := 'KaliteDOFGridi';
end;

procedure TKYDenetimListeDlg .GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDenetimListeDlg .GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDenetimListeDlg .EkranYazdir(Sender: TObject);
begin

end;

procedure TKYDenetimListeDlg .FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKYDenetimListeDlg .FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKYDenetimListeDlg .GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKYDenetimListeDlg .GetKapatilabilir: Boolean;
begin

end;

procedure TKYDenetimListeDlg .Gorunmez;
begin

end;

procedure TKYDenetimListeDlg .GorunmezOlacak;
begin

end;

procedure TKYDenetimListeDlg .Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TKYDenetimListeDlg .GorunurOlacak;
begin

end;

procedure TKYDenetimListeDlg .GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDenetimListeDlg .GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYDenetimListeDlg .Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TKYDenetimListeDlg.Kopyala1Click(Sender: TObject);
var yeniID:integer;
begin
   yeniID:=Tablo.SQLSatiriKopyala('KALITEDENETIM', TabDenetim.FieldByName('ID').AsInteger,['DENETIMNO','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],['YeniKod',Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
   DenetimSihirbaz('K', 0, yeniID);
end;

procedure TKYDenetimListeDlg .StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TKYDenetimListeDlg .StokListeDlgKapatEylemi(Sender: TObject);
begin

end;

procedure TKYDenetimListeDlg .SetArama(const Value: TServisAramaFrame);
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
//    TabloYenile(TabDenetim,[]);
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TKYDenetimListeDlg .SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKYDenetimListeDlg .SilTusClick(Sender: TObject);
var
i,ID:integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      begin
        for i := GridDOFView.Controller.SelectedRecordCount - 1 downto 0 do
        begin
           ID := GridDOFView.Controller.SelectedRecords[i].Values[GridDOFViewID.Index];
           Tablo.DenetimSil(ID);
        end;
      end;
  TabloYenile(TabDenetim,[]);
end;

procedure TKYDenetimListeDlg .TabDenetimAfterOpen(DataSet: TDataSet);
begin
  SilTus.Enabled := TabDenetim.RecordCount > 0;
  DegisTus.Enabled := SilTus.Enabled;
end;

procedure TKYDenetimListeDlg .TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYDenetimListeDlg .TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKYDenetimListeDlg .TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYDenetimListeDlg .YaziciYazdir(Sender: TObject);
begin

end;

function TKYDenetimListeDlg.DenetimSihirbaz(IslemOp:char;Cagiran,ID:Integer):integer;
begin
  Application.CreateForm(TKYDenetimWizardDlg, KYDenetimWizardDlg);
  KYDenetimWizardDlg.Cagiran := Cagiran;
  KYDenetimWizardDlg.DOF_ID := ID;
  KYDenetimWizardDlg.IslemOp := IslemOp;
  KYDenetimWizardDlg.ShowModal;

  if KYDenetimWizardDlg.ModalResult = mrOk then
    DOF_ID := KYDenetimWizardDlg.DOF_ID
  else
    DOF_ID := -99;
  KYDenetimWizardDlg.Free;
  TabloYenile(TabDenetim,[]);

end;


procedure TKYDenetimListeDlg .YeniTusClick(Sender: TObject);
begin
  DenetimSihirbaz('E', 0,-1);
end;

initialization
  RegisterClass(TKYDenetimListeDlg );
end.


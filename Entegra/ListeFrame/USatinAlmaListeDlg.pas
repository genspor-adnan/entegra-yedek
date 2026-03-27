unit USatinAlmaListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 01/07/2010 22:55:06}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB,  FireDAC.Comp.Client, ToolWin, ExtCtrls, dxSkinsCore,
  dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxDBData, cxImageComboBox, cxCurrencyEdit, cxGridLevel, USatinAlmaAramaFrame,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,UTeklifGorevFrame,
  cxGridCustomView, cxGrid, dxSkinLondonLiquidSky, cxImage, Utablo, cxSplitter,
  cxDropDownEdit, cxCalendar, cxPC, frxClass, frxDBSet, dxSkinLiquidSky,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxCore, cxDateUtils,
  JvExControls, JvNavigationPane, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxDateRanges, dxScrollbarAnnotations;

type
  TSatinAlmaListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsTabSatinAlma: TDataSource;
    TabSatinAlma: TFDQuery;
    BeniDegistir: TPanel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    ToolButton1: TToolButton;
    SilTus: TToolButton;
    cxSplitter1: TcxSplitter;
    PmPopupMenu: TPopupMenu;
    AcilisKaydiMenu: TMenuItem;
    DevirFiiGir1: TMenuItem;
    SqlMemo: TMemo;
    GridTviewTALEPTARIHI: TcxGridDBColumn;
    GridTviewTALEPNO: TcxGridDBColumn;
    GridTviewDURUM: TcxGridDBColumn;
    GridTviewTALEPEDEN: TcxGridDBColumn;
    GridTviewTALEPEDENBOLUM: TcxGridDBColumn;
    GridTviewSUBEID: TcxGridDBColumn;
    GridTviewASAMA: TcxGridDBColumn;
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SilTusClick(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TSatinAlmaAramaFrame;
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
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
    procedure SetArama(const Value: TSatinAlmaAramaFrame);

  public
    { Public declarations }
  published
    property Arama : TSatinAlmaAramaFrame read FArama write SetArama;
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, PrjConst, UFastRap,
URaporAraclari, UGenelAnaSekmeFrame, UAnaForm,LocOnFly;

{$R *.dfm}

{ TSatinAlmaAramaFrame }

procedure TSatinAlmaListeDlg.Baslatildi;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.GridTurkcelestir;
   GridTviewSUBEID.Visible := SubeVarmi;
   YenileTusClick(Self);
   DegisTus.visible := TabSatinAlma.Active;
   SilTus.visible := DegisTus.visible;
end;

function TSatinAlmaListeDlg.EkranAdiAl: string;
begin
   Result := 'SatinAlmaListeDlg';
end;

procedure TSatinAlmaListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin

end;

procedure TSatinAlmaListeDlg.DegisTusClick(Sender: TObject);
var
srid:integer;
begin
  if GridTview.Controller.SelectedRecordCount > 0 then
  begin
  srid:=GridTview.DataController.FocusedRecordIndex;
  if Tablo.SatinALmaSihirbazBaslat('D',TabSatinAlma.FieldByName('ASAMA').AsInteger,0,TabSatinAlma.Fields[0].AsInteger)>0 then
    YenileTusClick(Self);

   TabSatinAlma.Locate('ID',srid,[]);
   GridTview.DataController.SetFocus;
  //GridTview.DataController.FocusedRecordIndex:=srid;
//  GridTview.ViewData.Records[srid].Selected := false;
  end;
end;
procedure TSatinAlmaListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TSatinAlmaListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TSatinAlmaListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TSatinAlmaListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TSatinAlmaListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TSatinAlmaListeDlg.Gorunmez;
begin

end;

procedure TSatinAlmaListeDlg.GorunmezOlacak;
begin

end;

procedure TSatinAlmaListeDlg.Gorunur;
begin
  
end;

procedure TSatinAlmaListeDlg.GorunurOlacak;
begin

end;

procedure TSatinAlmaListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;


procedure TSatinAlmaListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TSatinAlmaListeDlg.SetArama( const Value: TSatinAlmaAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin

    AraTarihBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    AraTarihBit.Date := Tablo.GENINI.BugunTrh+1;
    YenileTus.Click;
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TSatinAlmaListeDlg.SilTusClick(Sender: TObject);
begin
 if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
  if LogGun > 0 then begin
    Tablo.OncekiLogBelirle(TabSatinAlma);
  end;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SATINALMADETAY where SATINALMAID=&id ',['&id'],[TabSatinAlma.Fields[0].AsInteger]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SATINALMA where ID=&id ',['&id'],[TabSatinAlma.Fields[0].AsInteger]);
  Tablo.LogIslemleri(TabNo_SATINALMA,TabSatinAlma.FieldByName('ID').AsInteger,5,TabSatinAlma);
  YenileTusClick(Self);
    /// SQL2005 TE hataya neden olduğu için delete olayını kendimiz yapıyoruz
  Abort;
 end;
end;

procedure TSatinAlmaListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSatinAlmaListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;
procedure TSatinAlmaListeDlg.AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 38 then
    TabSatinAlma.Prior
  else if Key = 40 then
    TabSatinAlma.next
  else begin
    YenileTusClick(Self);
  end;
end;
procedure TSatinAlmaListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSatinAlmaListeDlg.YaziciYazdir(Sender: TObject);
begin

end;
procedure TSatinAlmaListeDlg.YenileTusClick(Sender: TObject);
begin
  TabSatinAlma.Close;
  TabSatinAlma.SQL.Text := SqlMemo.Text;
  TabSatinAlma.SQL.Add(' Where 1=1 ');
  if SubeVarmi then
    TabSatinAlma.SQL.Add(' and SA.SUBEID in('+Tablo.YetkiliSubeleriGetir(29,YetkiTur_Gorme)+') ');
  TabSatinAlma.Open;
end;
procedure TSatinAlmaListeDlg.YeniTusClick(Sender: TObject);
begin
  if Tablo.SatinALmaSihirbazBaslat('E',1,0,-1)>0 then
    YenileTusClick(Self);
end;

initialization
  RegisterClass(TSatinAlmaListeDlg);
end.




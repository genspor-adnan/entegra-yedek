unit UDBSListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 18/02/2010 17:26:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls, 
  UDBSAramaFrame, cxStyles, dxSkinsCore,
  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxImageComboBox, dxSkinLondonLiquidSky, cxImage, cxLookAndFeels, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, dxDateRanges, dxScrollbarAnnotations;

type
  TDBSListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsDBS: TDataSource;
    TabDBS: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridTviewDURUM: TcxGridDBColumn;
    GridTviewSOZLESME_TARIHI: TcxGridDBColumn;
    GridTviewKREDIHESAPKODU: TcxGridDBColumn;
    GridTviewKREDIHESAPADI: TcxGridDBColumn;
    GridTviewBORCLUKOD: TcxGridDBColumn;
    GridTviewBORCLUUNVAN: TcxGridDBColumn;
    GridTviewALACAKLIKOD: TcxGridDBColumn;
    GridTviewALACAKLIFIRMA: TcxGridDBColumn;
    GridTviewTICARIHESAPKODU: TcxGridDBColumn;
    GridTviewTICARIHESAPADI: TcxGridDBColumn;
    GridTviewLOGO: TcxGridDBColumn;
    GridTviewBANKAADI: TcxGridDBColumn;
    GridTviewSUBEID: TcxGridDBColumn;
    SilTus: TToolButton;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YeniTusClick(Sender: TObject);
    procedure YenileTusClick;
    procedure DegisTusClick(Sender: TObject);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure SilTusClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TDBSAramaFrame;
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
    procedure DBSKapatEylemi(Sender: TObject);
    procedure DBSEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TDBSAramaFrame);

  public
    { Public declarations }
  published
    property Arama      : TDBSAramaFrame read FArama write SetArama;
  end;

implementation

uses
UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UDBS,UTablo,PrjConst,LocOnFly;

{$R *.dfm}
{ TDBSListeFrame }

var
 SQLMemo :string;

procedure TDBSListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    TabDBS.Prior
  else if Key = 40 then
    TabDBS.next
  else
  begin
      YenileTusClick;
      DegisTus.visible := TabDBS.RecordCount > 0;
  end;
end;
procedure TDBSListeFrame.YenileTusClick;
begin
  TabDBS.Close;
  if SQLMemo = '' then
    SQLMemo := TabDBS.SQL.Text;

  TabDBS.SQL.Text := SQLMemo;
  TabDBS.SQL.Text := TabDBS.SQL.Text;
  TabDBS.SQL.Add( ' Where 1=1 ' );
  if SubeVarmi then
    TabDBS.SQL.Add( ' and D.SUBEID in('+Tablo.YetkiliSubeleriGetir(28,YetkiTur_Gorme)+') ');
  TabDBS.Open;
end;
procedure TDBSListeFrame.Baslatildi;
begin
  YenileTusClick;
  //GridTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\DogrudanBorclanmaListeGridi',true,false,[gsoUseFilter],'DogrudanBorclanmaListeGridi');
  Tablo.GridAyarRestore('DogrudanBorclanmaListeGridi',GridTview );

  DegisTus.visible := TabDBS.Active;

  Tablo.GridTurkcelestir;

end;

procedure TDBSListeFrame.DegisTusClick(Sender: TObject);
begin
   DBSEkranAc(False);
end;

procedure TDBSListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDBSListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDBSListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDBSListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDBSListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDBSListeFrame.Gorunmez;
begin

end;

procedure TDBSListeFrame.GorunmezOlacak;
begin

end;

procedure TDBSListeFrame.Gorunur;
begin
  
end;

procedure TDBSListeFrame.GorunurOlacak;
begin

end;

procedure TDBSListeFrame.GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
AnaForm.pmGridStil.Tags.Values[cxGrid.Name] := 'DogrudanBorclanmaListeGridi';
end;

procedure TDBSListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDBSListeFrame.DBSEkranAc(Yeni: Boolean);
begin
  with FFrameBilgi.IcerikGit(TDBSDlg).Git do begin
   with TDBSDlg(Ornek) do begin
     KapatEylemi := DBSKapatEylemi;
     DBSEkranInit(IIf(Yeni, -1, IIf(Self.TabDBS.RecordCount = 0, -1, Self.TabDBS.AsInteger['ID'])));
     if Yeni then
       TabDBS.Append;
   end;
 end;
end;

procedure TDBSListeFrame.DBSKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
  YenileTusClick
end;

procedure TDBSListeFrame.SetArama(
  const Value: TDBSAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;

procedure TDBSListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDBSListeFrame.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(BDSVeriSilinsinmi),PChar(Onay), MB_YESNO) = IDYES then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from DBS Where ID ='+TabDBS.FieldByName('ID').AsString+' ',[],[]);
      YenileTusClick;
   end;
end;

procedure TDBSListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDBSListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDBSListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDBSListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TDBSListeFrame.YeniTusClick(Sender: TObject);
begin
  DBSEkranAc(True);
end;

initialization
  RegisterClass(TDBSListeFrame);
end.




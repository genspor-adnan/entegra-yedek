unit UTeminatMektuplariListeFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, UTeminatMektubuAramaFrame, DB, FireDAC.Comp.Client,
  ToolWin, ExtCtrls, cxStyles, dxSkinsCore,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxDBData, cxImageComboBox, cxCurrencyEdit, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid,  UFrameYoneticisi, cxImage, cxLookAndFeels,
  cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxDateRanges, dxScrollbarAnnotations;

type
  TTeminatMektuplariListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsTeminatMektubu: TDataSource;
    GridTakvim: TcxGrid;
    TakvimView: TcxGridDBTableView;
    TakvimViewDURUM: TcxGridDBColumn;
    TakvimViewBANKAADI: TcxGridDBColumn;
    TakvimViewTARIH: TcxGridDBColumn;
    akvimViewSURESI: TcxGridDBColumn;
    TakvimViewMUHATAPADI: TcxGridDBColumn;
    TakvimViewTUTARI: TcxGridDBColumn;
    TakvimViewKUR: TcxGridDBColumn;
    TakvimViewEKLEYEN: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    akvimViewLOGO: TcxGridDBColumn;
    TabTeminatMektubu: TFDQuery;
    akvimViewSUBEID: TcxGridDBColumn;
    SilTus: TToolButton;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure TakvimViewDblClick(Sender: TObject);
    procedure YenileTusClick;
    procedure TakvimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure SilTusClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TTeminatMektubuAramaFrame;
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
    procedure TeminatMektubuKapatEylemi(Sender: TObject);
    procedure TeminatMektubuEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TTeminatMektubuAramaFrame);

  public
    { Public declarations }
  published
    property Arama      : TTeminatMektubuAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UTeminatMektubu,UTablo,PrjConst,LocOnFly;

{$R *.dfm}

{ TTeminatMektuplariListeFrame }

var
SQLMemo :String;

procedure TTeminatMektuplariListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    TabTeminatMektubu.Prior
  else if Key = 40 then
    TabTeminatMektubu.next
  else
  begin
      YenileTusClick;
      DegisTus.visible := TabTeminatMektubu.RecordCount > 0;
  end;
end;
procedure TTeminatMektuplariListeFrame.YenileTusClick;
begin
  TabTeminatMektubu.Close;
  if SQLMemo = '' then
    SQLMemo := TabTeminatMektubu.SQL.Text;
  TabTeminatMektubu.SQL.Text := SQLMemo;
  TabTeminatMektubu.SQL.Text := TabTeminatMektubu.SQL.Text;
  TabTeminatMektubu.SQL.Add( ' Where 1=1 ' );
  if SubeVarmi then
      TabTeminatMektubu.SQL.add(' and T.SUBEID in('+Tablo.YetkiliSubeleriGetir(25,YetkiTur_Gorme)+') ');
  TabTeminatMektubu.Open;
end;

procedure TTeminatMektuplariListeFrame.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  YenileTusClick;
 // TakvimView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\TeminatMektubuListeGridi',true,false,[gsoUseFilter],'TeminatMektubuListeGridi');
  Tablo.GridAyarRestore('TeminatMektubuListeGridi',TakvimView );


  Tablo.GridTurkcelestir;

  DegisTus.visible := TabTeminatMektubu.Active;
end;

procedure TTeminatMektuplariListeFrame.DegisTusClick(Sender: TObject);
begin
  TeminatMektubuEkranAc(False);
end;

procedure TTeminatMektuplariListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTeminatMektuplariListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeminatMektuplariListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTeminatMektuplariListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTeminatMektuplariListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTeminatMektuplariListeFrame.Gorunmez;
begin

end;

procedure TTeminatMektuplariListeFrame.GorunmezOlacak;
begin

end;

procedure TTeminatMektuplariListeFrame.Gorunur;
begin

end;

procedure TTeminatMektuplariListeFrame.GorunurOlacak;
begin

end;

procedure TTeminatMektuplariListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTeminatMektuplariListeFrame.TakvimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=GridTakvim;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=TakvimView;
AnaForm.pmGridStil.Tags.Values[GridTakvim.Name] := 'TeminatMektubuListeGridi';
end;

procedure TTeminatMektuplariListeFrame.TakvimViewDblClick(Sender: TObject);
begin
  //
  TeminatMektubuEkranAc(False);
end;



procedure TTeminatMektuplariListeFrame.TeminatMektubuEkranAc(Yeni: Boolean);
begin
  with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TTeminatMektubuDlg).Git do begin
   with TTeminatMektubuDlg(Ornek) do begin
     KapatEylemi := TeminatMektubuKapatEylemi;
     TeminatMektubuEkranInit(IIf(Yeni, -1, IIf(Self.TabTeminatMektubu.RecordCount = 0, -1, Self.TabTeminatMektubu.AsInteger['ID'])));
     if Yeni then
       TabTeminatMektubu.Append;
   end;
 end;
end;

procedure TTeminatMektuplariListeFrame.TeminatMektubuKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
  YenileTusClick;
end;

procedure TTeminatMektuplariListeFrame.SetArama(
  const Value: TTeminatMektubuAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;



procedure TTeminatMektuplariListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTeminatMektuplariListeFrame.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu),PChar(Onay), MB_YESNO) = IDYES then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from TEMINATMEKTUBU Where ID ='+TabTeminatMektubu.FieldByName('ID').AsString+' ',[],[]);
      YenileTusClick;
   end;
end;

procedure TTeminatMektuplariListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeminatMektuplariListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTeminatMektuplariListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeminatMektuplariListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TTeminatMektuplariListeFrame.YeniTusClick(Sender: TObject);
begin
  TeminatMektubuEkranAc(True);
end;

initialization
  RegisterClass(TTeminatMektuplariListeFrame);
end.




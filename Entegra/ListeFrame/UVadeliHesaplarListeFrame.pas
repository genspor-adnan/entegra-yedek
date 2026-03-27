unit UVadeliHesaplarListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 06/01/2010 13:19:58}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, 
  UVadeliHesapAramaFrame, cxStyles, dxSkinsCore,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxDBData, cxImageComboBox, cxCurrencyEdit, cxCheckBox,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid,   dxSkinsDefaultPainters,
   UFrameYoneticisi, cxImage, cxLookAndFeels, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TVadeliHesaplarListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsVadeliHesap: TDataSource;
    TabVadeliHesap: TFDQuery;
    GridTakvim: TcxGrid;
    TakvimView: TcxGridDBTableView;
    cxGridLevel4: TcxGridLevel;
    TakvimViewKOD: TcxGridDBColumn;
    TakvimViewADI: TcxGridDBColumn;
    TakvimViewVADESIZHESAPKODU: TcxGridDBColumn;
    TakvimViewVADESIZHESAPNO: TcxGridDBColumn;
    TakvimViewVADESIZHESAPADI: TcxGridDBColumn;
    TakvimViewVADELIHESAPKODU: TcxGridDBColumn;
    TakvimViewVADELIHESAPNO: TcxGridDBColumn;
    TakvimViewVADELIHESAPADI: TcxGridDBColumn;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    akvimViewLOGO: TcxGridDBColumn;
    akvimViewBANKAADI: TcxGridDBColumn;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure TakvimViewDblClick(Sender: TObject);
    procedure TakvimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TVadeliHesapAramaFrame;
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
    procedure VadeliHesapKapatEylemi(Sender: TObject);
    procedure VadeliHesapEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TVadeliHesapAramaFrame);
  public
    { Public declarations }
  published
    property Arama      : TVadeliHesapAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UVadeliHesap,utablo,LocOnFly,PrjConst;

{$R *.dfm}

{ TVadeliHesaplarListeFrame }

procedure TVadeliHesaplarListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    TabVadeliHesap.Prior
  else if Key = 40 then
    TabVadeliHesap.next
  else
  begin
      TabVadeliHesap.Close;
      TabVadeliHesap.Params[0].Value := '%'+FArama.AraKod.Text+'%';
      TabVadeliHesap.Params[1].Value := '%'+FArama.AraKod.Text+'%';
      TabVadeliHesap.Open;
      DegisTus.visible := TabVadeliHesap.RecordCount>0;
  end;
end;

procedure TVadeliHesaplarListeFrame.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
 // TakvimView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\VadeliHesaplarListeGridi',true,false,[gsoUseFilter],'');
  Tablo.GridAyarRestore('VadeliHesaplarListeGridi',TakvimView );

  Tablo.GridTurkcelestir;

  DegisTus.visible := TabVadeliHesap.Active;
end;

procedure TVadeliHesaplarListeFrame.DegisTusClick(Sender: TObject);
begin
  VadeliHesapEkranAc(False);
end;

procedure TVadeliHesaplarListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TVadeliHesaplarListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TVadeliHesaplarListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TVadeliHesaplarListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TVadeliHesaplarListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TVadeliHesaplarListeFrame.Gorunmez;
begin

end;

procedure TVadeliHesaplarListeFrame.GorunmezOlacak;
begin

end;

procedure TVadeliHesaplarListeFrame.Gorunur;
begin
end;

procedure TVadeliHesaplarListeFrame.GorunurOlacak;
begin

end;

procedure TVadeliHesaplarListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TVadeliHesaplarListeFrame.VadeliHesapEkranAc(Yeni: Boolean);
begin
  with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TVadeliHesapDlg).Git do begin
   with TVadeliHesapDlg(Ornek) do begin
     KapatEylemi := VadeliHesapKapatEylemi;
     VadeliHesapEkranInit(IIf(Yeni, -1, IIf(Self.TabVadeliHesap.RecordCount = 0, -1, Self.TabVadeliHesap.AsInteger['ID'])));
     if Yeni then
       TabVadeliHesap.Append;
   end;
 end;
end;

procedure TVadeliHesaplarListeFrame.VadeliHesapKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
  TabVadeliHesap.Close;
  TabVadeliHesap.Open;   
end;

procedure TVadeliHesaplarListeFrame.SetArama(
  const Value: TVadeliHesapAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;



procedure TVadeliHesaplarListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TVadeliHesaplarListeFrame.TakvimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=GridTakvim;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=TakvimView;
AnaForm.pmGridStil.Tags.Values[GridTakvim.Name] := 'VadeliHesaplarListeGridi';
end;

procedure TVadeliHesaplarListeFrame.TakvimViewDblClick(Sender: TObject);
begin
  VadeliHesapEkranAc(False);
end;



procedure TVadeliHesaplarListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TVadeliHesaplarListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TVadeliHesaplarListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TVadeliHesaplarListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TVadeliHesaplarListeFrame.YeniTusClick(Sender: TObject);
begin
  VadeliHesapEkranAc(True);
end;

initialization
  RegisterClass(TVadeliHesaplarListeFrame);
end.




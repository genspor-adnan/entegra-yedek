unit USorumlulukMerkezleriDlg;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 04/12/2010 11:54:17}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls, Forms,
  UUretimAramaFrame, dxSkinsCore,  dxSkinscxPCPainter, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridCustomTableView, cxGraphics,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxProgressBar,
  dxSkinLondonLiquidSky, cxPC, cxLookAndFeels, dxSkinsDefaultPainters, cxNavigator;

type
  TSorumlulukMerkezListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsTabSRMMerkezListe: TDataSource;
    TabSRMMerkezListe: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    DuzenleTus: TToolButton;
    GridSRMMerkez: TcxGrid;
    GridSRMMerkezDBTableView1: TcxGridDBTableView;
    GridSRMMerkezLevel1: TcxGridLevel;
    GridSRMMerkezDBTVMERKEZADI: TcxGridDBColumn;
    GridSRMMerkezDBTVMERKEZKODU: TcxGridDBColumn;
    procedure SilTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure DuzenleTusClick(Sender: TObject);
    procedure TabSRMMerkezListeNewRecord(DataSet: TDataSet);
    procedure GridSRMMerkezDBTableView1DblClick(Sender: TObject);
  private
    { Private declarations }    
    FFrameBilgi : TIcerikFrameBilgi;
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
    procedure SetArama(const Value: TUretimAramaFrame);
  public
    { Public declarations }
    GELIRMI :Boolean;
  published
    procedure AramaYap(Sender: TObject);
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions,Utablo, PrjConst, UUretimRecete,UGirisKutusuEx;

{$R *.dfm}

{ TSorumlulukMerkezListeDlg }

procedure TSorumlulukMerkezListeDlg.Baslatildi;
begin

end;

procedure TSorumlulukMerkezListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TSorumlulukMerkezListeDlg.AramaYap(Sender: TObject);
begin
  TabloYenile(TabSRMMerkezListe,[GELIRMI]);
end;

procedure TSorumlulukMerkezListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TSorumlulukMerkezListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TSorumlulukMerkezListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TSorumlulukMerkezListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TSorumlulukMerkezListeDlg.DuzenleTusClick(Sender: TObject);
var
  YeniMerkezKod,YeniMerkezAd : Variant;
begin
   YeniMerkezKod := TabSRMMerkezListe.FieldByName('MERKEZKODU').AsString;
   YeniMerkezAd  :=  TabSRMMerkezListe.FieldByName('MERKEZADI').AsString;

      if TGirisKutusuEx.BilgiAlEx('Yeni bilgi girişi.', TGirdiDenetimleri.Create.Edit('Merkez kodu giriniz', @YeniMerkezKod).Edit('Merkez Adı giriniz',@YeniMerkezAd)) <> mrOk then
        Abort;

      if TabSRMMerkezListe.State <> dsEdit then
      TabSRMMerkezListe.Edit;

      TabSRMMerkezListe.FieldByName('MERKEZKODU').AsString:=YeniMerkezKod;
      TabSRMMerkezListe.FieldByName('MERKEZADI').AsString:=YeniMerkezAd;
      TabSRMMerkezListe.Post;
  AramaYap(nil);
end;

procedure TSorumlulukMerkezListeDlg.Gorunmez;
begin

end;

procedure TSorumlulukMerkezListeDlg.GorunmezOlacak;
begin

end;

procedure TSorumlulukMerkezListeDlg.Gorunur;
begin
  
end;

procedure TSorumlulukMerkezListeDlg.GorunurOlacak;
begin

end;

procedure TSorumlulukMerkezListeDlg.GridSRMMerkezDBTableView1DblClick(Sender: TObject);
begin
   DuzenleTusClick(Self);
end;

procedure TSorumlulukMerkezListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TSorumlulukMerkezListeDlg.SetArama( const Value: TUretimAramaFrame);
begin

end;

procedure TSorumlulukMerkezListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TSorumlulukMerkezListeDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabSRMMerkezListe.Delete;
     AramaYap(nil);
   end;
end;

procedure TSorumlulukMerkezListeDlg.TabSRMMerkezListeNewRecord(DataSet: TDataSet);
begin
  TabSRMMerkezListe.FieldByName('GELIRMI').AsBoolean := GELIRMI;
  TabSRMMerkezListe.FieldByName('EKLEYEN').AsString := Kullanan;
  TabSRMMerkezListe.FieldByName('EKLEMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  TabSRMMerkezListe.FieldByName('SUBEID').AsInteger := SubeId;
end;

procedure TSorumlulukMerkezListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSorumlulukMerkezListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TSorumlulukMerkezListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TSorumlulukMerkezListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TSorumlulukMerkezListeDlg.YeniTusClick(Sender: TObject);
var
  YeniMerkezKod,YeniMerkezAd : Variant;
begin
      if TGirisKutusuEx.BilgiAlEx('Yeni bilgi girişi.', TGirdiDenetimleri.Create.Edit('Merkez kodu giriniz', @YeniMerkezKod).Edit('Merkez Adı giriniz',@YeniMerkezAd)) <> mrOk then
        Abort;

      TabSRMMerkezListe.Append;
      TabSRMMerkezListe.FieldByName('MERKEZKODU').AsString:=YeniMerkezKod;
      TabSRMMerkezListe.FieldByName('MERKEZADI').AsString:=YeniMerkezAd;
      TabSRMMerkezListe.Post;

      AramaYap(nil);
end;

initialization
  RegisterClass(TSorumlulukMerkezListeDlg);
end.

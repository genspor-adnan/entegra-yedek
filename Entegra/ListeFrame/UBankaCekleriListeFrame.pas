unit UBankaCekleriListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 06/01/2010 13:51:10}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls,
  UBankaCekleriAramaFrame, cxStyles, dxSkinsCore,UBankaKredileriListeTanimlariFrame,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  UFrameYoneticisi, cxImage, cxImageComboBox, cxLookAndFeels, cxNavigator,
  dxSkinLiquidSky;

type
  TBankaCekleriListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsCekler: TDataSource;
    TabCekKredi: TFDQuery;
    cxGrid2: TcxGrid;
    CekTview: TcxGridDBTableView;
    CekTviewKREDIKODU: TcxGridDBColumn;
    CekTviewKREDIACIKLAMA: TcxGridDBColumn;
    CekTviewKREDITEMINAT: TcxGridDBColumn;
    CekTviewKREDILIMIT: TcxGridDBColumn;
    CekTviewCEKMIN: TcxGridDBColumn;
    CekTviewLOGO: TcxGridDBColumn;
    CekTviewDURUM: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    ToolButton1: TToolButton;
    SilTus: TToolButton;
    CekTviewBANKAADI: TcxGridDBColumn;
    CekTviewSUBEID: TcxGridDBColumn;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure TabCekKrediBeforeOpen(DataSet: TDataSet);
    procedure YenileTusClick;
    procedure CekTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TBankaCekleriAramaFrame;
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
    procedure BankaCekiKapatEylemi(Sender: TObject);
    procedure SetArama(const Value: TBankaCekleriAramaFrame);
    function BankaCekiWizardBaslat(CekKrediId:Integer; IslemOp:char) : Integer;

  public
    { Public declarations }
  published
    property Arama      : TBankaCekleriAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UBankaCekiWizard, PrjConst, Utablo,LocOnFly;

{$R *.dfm}

{ TBankaCekleriListeFrame }
  var
  SqlMemo :string;

procedure TBankaCekleriListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 38 then
    TabCekKredi.Prior
  else if Key = 40 then
    TabCekKredi.next
  else
  begin
    YenileTusClick;
  end;
end;

Procedure TBankaCekleriListeFrame.YenileTusClick;
begin
  TabCekKredi.Close;
  if SQLMemo = '' then
    SQLMemo := TabCekKredi.SQL.Text;
  TabCekKredi.SQL.Text := SQLMemo;
  TabCekKredi.SQL.Text := TabCekKredi.SQL.Text;
  TabCekKredi.SQL.Add( ' Where 1=1 ' );
  if SubeVarmi then
    TabCekKredi.SQL.Add( ' and CK.SUBEID in('+Tablo.YetkiliSubeleriGetir(25,YetkiTur_Gorme)+') ');

  TabCekKredi.Open;
end;
procedure TBankaCekleriListeFrame.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  CekTviewSUBEID.Visible := SubeVarmi;
  YenileTusClick;
  //CekTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\BankaCekleriListeGridi',true,false,[gsoUseFilter],'BankaCekleriListeGridi');
  Tablo.GridAyarRestore('BankaCekleriListeGridi',CekTview );

  Tablo.GridTurkcelestir;
  end;

procedure TBankaCekleriListeFrame.CekTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=cxGrid2;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=CekTview;
AnaForm.pmGridStil.Tags.Values[cxGrid2.Name] := 'BankaCekleriListeGridi';
end;

procedure TBankaCekleriListeFrame.DegisTusClick(Sender: TObject);
var Key : Word;
srid:integer;
begin
  if CekTview.Controller.SelectedRecordCount > 0 then
  begin
  srid:=CekTview.DataController.FocusedRecordIndex;
  if tablo.YetkiVarmi(25510101,YetkiTur_Degistirme) then begin
     if BankaCekiWizardBaslat( TabCekKredi.fields[0].AsInteger,'D') > 0 then
        AraKodKeyUp(Self, Key, [])
  end else
    raise Exception.Create(Yetkisiz_Islem);

    CekTview.DataController.FocusedRecordIndex:=srid;
  //  CekTview.ViewData.Records[srid].Selected := false;
  end;
end;
procedure TBankaCekleriListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TBankaCekleriListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankaCekleriListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TBankaCekleriListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TBankaCekleriListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TBankaCekleriListeFrame.Gorunmez;
begin

end;

procedure TBankaCekleriListeFrame.GorunmezOlacak;
begin

end;

procedure TBankaCekleriListeFrame.Gorunur;
begin

end;

procedure TBankaCekleriListeFrame.GorunurOlacak;
begin

end;

procedure TBankaCekleriListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

function TBankaCekleriListeFrame.BankaCekiWizardBaslat(CekKrediId:Integer; IslemOp:char) : Integer;
begin
   Application.CreateForm(TBankaCekleriWizardDlg, BankaCekleriWizardDlg);
   BankaCekleriWizardDlg.CekKrediId :=CekKrediId;
   BankaCekleriWizardDlg.IslemOp := IslemOp;
   BankaCekleriWizardDlg.ShowModal;
   Result := BankaCekleriWizardDlg.CekKrediId;
   BankaCekleriWizardDlg.Destroy;
end;

procedure TBankaCekleriListeFrame.BankaCekiKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
  TabCekKredi.Close;
  TabCekKredi.Open;
end;

procedure TBankaCekleriListeFrame.SetArama(const Value: TBankaCekleriAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;

procedure TBankaCekleriListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TBankaCekleriListeFrame.SilTusClick(Sender: TObject);
var k : word;
begin
  if tablo.YetkiVarmi(25510101,YetkiTur_Degistirme) then begin
     if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
        if Veritabani.VeriVarMi(Tablo.FDCnn, ' select * from CEKKOCAN where KREDIID=&id ',['&id'],[TabCekKredi.fields[0].AsInteger]) then
           ShowMessage(BCek_kocani_tanimli_silin)
        else
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from CEKKREDI where ID=&Id ',['&Id'], [TabCekKredi.fields[0].AsInteger]);
     end;
     Self.AraKodKeyUp(Self, k, []);
  end else
     raise Exception.Create(Yetkisiz_Islem);
end;

procedure TBankaCekleriListeFrame.TabCekKrediBeforeOpen(DataSet: TDataSet);
begin
  if not Tablo.YetkiVarmi(25510101,YetkiTur_Gorme) then
    Abort;
end;

procedure TBankaCekleriListeFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TBankaCekleriListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TBankaCekleriListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankaCekleriListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TBankaCekleriListeFrame.YeniTusClick(Sender: TObject);
var Key: Word;
begin
  if tablo.YetkiVarmi(25510101,YetkiTur_Ekleme) then begin
     if BankaCekiWizardBaslat(-1, 'E') > 0 then
        AraKodKeyUp(Self, Key, []);
  end else
     raise Exception.Create(Yetkisiz_Islem);

end;

initialization
  RegisterClass(TBankaCekleriListeFrame);
end.




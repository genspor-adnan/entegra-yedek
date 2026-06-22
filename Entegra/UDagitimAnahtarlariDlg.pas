unit UDagitimAnahtarlariDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, DB, FireDAC.Comp.Client, ToolWin,
  DBCtrls, Mask, dxSkinsCore, cxDBEdit, dxSkinLondonLiquidSky, cxDBLabel,
  cxLabel, cxSpinEdit, cxGraphics, cxDropDownEdit, cxImageComboBox, cxCalendar,
  ExtCtrls, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxDBData, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxCurrencyEdit, cxLookAndFeels, cxNavigator, dxSkinLiquidSky,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, UTablo,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDagitimAnahtarlariDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    ToolButton5: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    TabDagitim: TFDQuery;
    DtsTabDagitim: TDataSource;
    DtsTabDagitimDetay: TDataSource;
    TabDagitimDetay: TFDQuery;
    Panel3: TPanel;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label23: TcxLabel;
    DBEdit1: TcxDBLabel;
    EditKOD: TcxDBTextEdit;
    EditAD: TcxDBTextEdit;
    DateBaslamaTarihi: TcxDBDateEdit;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    Panel2: TPanel;
    GridDagitim: TcxGrid;
    GridDagitimDBTableView1: TcxGridDBTableView;
    GridDagitimDBTVMASRAFADI: TcxGridDBColumn;
    GridDagitimDBTVMERKEZADI: TcxGridDBColumn;
    GridDagitimDBTVPUAN: TcxGridDBColumn;
    GridDagitimLevel1: TcxGridLevel;
    ToolBar5: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1DBTableView1Column2: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure KapatTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsTabDagitimStateChange(Sender: TObject);
    procedure TabDagitimNewRecord(DataSet: TDataSet);
    procedure TabDagitimBeforePost(DataSet: TDataSet);
    procedure SatirEkleClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure GridDagitimDBTVMASRAFKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabDagitimDetayNewRecord(DataSet: TDataSet);
    procedure GridDagitimDBTVMERKEZADIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure DtsTabDagitimDetayStateChange(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure TabDagitimAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FKapatEylemi: TNotifyEvent;
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
    
    { Gezinme ve yazdirma destegi }
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
    function EkranAdiAl : string;
  public
    { Public declarations }
    GELIRMI : Boolean;

    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}
uses FetaClassExtensions, PrjConst;

{ TKrediKarti }

destructor TDagitimAnahtarlariDlg.Destroy;
begin

  inherited;
end;


procedure TDagitimAnahtarlariDlg.Baslatildi;
begin

end;

constructor TDagitimAnahtarlariDlg.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TDagitimAnahtarlariDlg.DtsTabDagitimDetayStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsTabDagitimDetay,SatirEkle,SatirSil,ToolButton1,ToolButton2)
end;

procedure TDagitimAnahtarlariDlg.DtsTabDagitimStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsTabDagitim, EkleTus,SilTus,KaydetTus,IptalTus)
end;

procedure TDagitimAnahtarlariDlg.EkleTusClick(Sender: TObject);
begin
   TabDagitim.Append;
end;

function TDagitimAnahtarlariDlg.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TDagitimAnahtarlariDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TDagitimAnahtarlariDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDagitimAnahtarlariDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDagitimAnahtarlariDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDagitimAnahtarlariDlg.GetKapatilabilir: Boolean;
begin

end;

function TDagitimAnahtarlariDlg.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TDagitimAnahtarlariDlg.Gorunmez;
begin

end;

procedure TDagitimAnahtarlariDlg.GorunmezOlacak;
begin

end;

procedure TDagitimAnahtarlariDlg.Gorunur;
begin

end;

procedure TDagitimAnahtarlariDlg.GorunurOlacak;
begin

end;

procedure TDagitimAnahtarlariDlg.GridDagitimDBTVMASRAFKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
   MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
   GelirGider:SmallInt;
begin
  if GELIRMI then
     GelirGider :=1
  else  GelirGider:=0;

  if TabDagitimDetay.State = dsBrowse then
     TabDagitimDetay.Edit;
  if AButtonIndex=0 then begin
    if Tablo.MasrafMerkeziSecimEkrani(GelirGider, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      TabDagitimDetay.FieldByName('MASRAFID').AsInteger := StrToIntDef(MASRAFID,0);
      TabDagitimDetay.Post;
      TabloYenile(TabDagitimDetay,[TabDagitim.FieldByName('ID').AsInteger,GELIRMI]);
    end;
  end else if AButtonIndex=1 then begin
    TabDagitimDetay.FieldByName('MASRAFID').AsInteger := 0;
    TabDagitimDetay.Post;
    TabloYenile(TabDagitimDetay,[TabDagitim.FieldByName('ID').AsInteger,GELIRMI]);
  end;
end;

procedure TDagitimAnahtarlariDlg.GridDagitimDBTVMERKEZADIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
   st: TStringList;
   GelirGider:SmallInt;
begin
  if GELIRMI then
     GelirGider :=1
  else  GelirGider :=0;

  if TabDagitimDetay.State = dsBrowse then
     TabDagitimDetay.Edit;
  if AButtonIndex=0 then begin
    st := TStringList.Create;
    if Tablo.ListedenBilgiGetir('Sorumluluk Merkezi Seçimi','select ID,Kod=MERKEZKODU,Ad=MERKEZADI from SRMMERKEZI Where GELIRMI='+intToStr(GelirGider)+' ',st,[],'SRM Seçimi') then begin
      TabDagitimDetay.FieldByName('MERKEZID').AsInteger := StrToIntDef(st[0],0);
      TabDagitimDetay.Post;
      TabloYenile(TabDagitimDetay,[TabDagitim.FieldByName('ID').AsInteger,GELIRMI]);
    end;
    FreeAndNil(st);
  end else if AButtonIndex=1 then begin
    TabDagitimDetay.FieldByName('MERKEZID').AsInteger := 0;
    TabDagitimDetay.Post;
    TabloYenile(TabDagitimDetay,[TabDagitim.FieldByName('ID').AsInteger,GELIRMI]);
  end;

end;

procedure TDagitimAnahtarlariDlg.IptalTusClick(Sender: TObject);
begin
   TabDagitim.Cancel;
end;

procedure TDagitimAnahtarlariDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDagitimAnahtarlariDlg.KapatTusClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
    FKapatEylemi(Self);
end;

procedure TDagitimAnahtarlariDlg.KaydetTusClick(Sender: TObject);
begin
   TabDagitim.Post;
end;

procedure TDagitimAnahtarlariDlg.SatirEkleClick(Sender: TObject);
begin
   if TabDagitim.State in [dsedit, dsinsert] then
      TabDagitim.post;
  TabDagitimDetay.Append;
end;

procedure TDagitimAnahtarlariDlg.SatirSilClick(Sender: TObject);
begin
  TabDagitimDetay.Delete;
end;

procedure TDagitimAnahtarlariDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDagitimAnahtarlariDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabDagitim.Delete;
end;

procedure TDagitimAnahtarlariDlg.TabDagitimAfterScroll(DataSet: TDataSet);
begin
   if TabDagitim.RecordCount>0 then
      TabloYenile(TabDagitimDetay,[TabDagitim.FieldByName('ID').AsInteger,GELIRMI]);
end;

procedure TDagitimAnahtarlariDlg.TabDagitimBeforePost(DataSet: TDataSet);
begin
  if not BoslukKontrol(EditKOD.Text,'Kodu') then Abort;
  if not BoslukKontrol(EditAD.Text,'Adı') then Abort;
  if not BoslukKontrol(DateBaslamaTarihi.Text,'Baslama Tarihi') then Abort;
end;

procedure TDagitimAnahtarlariDlg.TabDagitimDetayNewRecord(DataSet: TDataSet);
begin
  TabDagitimDetay.FieldByName('GELIRMI').AsBoolean := GELIRMI;
  TabDagitimDetay.FieldByName('DAGITIMID').AsInteger := TabDagitim.FieldByName('ID').AsInteger;
end;

procedure TDagitimAnahtarlariDlg.TabDagitimNewRecord(DataSet: TDataSet);
begin
   TabDagitim.FieldByName('GELIRMI').AsBoolean := GELIRMI;
   TabDagitim.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TDagitimAnahtarlariDlg.ToolButton1Click(Sender: TObject);
begin
  TabDagitimDetay.Post;
end;

procedure TDagitimAnahtarlariDlg.ToolButton2Click(Sender: TObject);
begin
  TabDagitimDetay.Cancel;
end;

procedure TDagitimAnahtarlariDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;
procedure TDagitimAnahtarlariDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDagitimAnahtarlariDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TDagitimAnahtarlariDlg.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TDagitimAnahtarlariDlg.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDagitimAnahtarlariDlg);
end.


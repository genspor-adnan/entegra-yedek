unit UStokDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:46:38}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, cxGraphics,
  dxSkinscxPCPainter, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  DB, cxDBData, cxCheckBox, cxDropDownEdit, cxImageComboBox, cxTimeEdit,
  frxClass, frxDBSet, FireDAC.Comp.Client, ImgList, cxGroupBox, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxPC, cxRadioGroup, cxDBEdit, cxMemo, cxImage,
  cxDBLabel, ToolWin, cxLabel, ExtCtrls, cxGridCustomPopupMenu, cxGridPopupMenu,
  XPMenu, DBCtrls, Mask, cxProgressBar, Buttons, Grids, DBGrids, UGenDBNavigator;

type
  TStokDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton4: TToolButton;
    btnKapat: TToolButton;
    Label19: TLabel;
    Panel1: TPanel;
    PanelDetayPage: TPanel;
    PageControl1: TPageControl;
    tshFiyatlar: TTabSheet;
    tshStokDurum: TTabSheet;
    Panel4: TPanel;
    Label18: TLabel;
    lbGiren: TLabel;
    lbCikan: TLabel;
    lbKalan: TLabel;
    Panel8: TPanel;
    DurumExceleAktarBtn: TSpeedButton;
    cxProgressBar1: TcxProgressBar;
    cbSKTsizGrupla: TCheckBox;
    cbSifirKalanGoster: TCheckBox;
    tshGiris: TTabSheet;
    cxgrdStokGirisKart: TcxGrid;
    cxgrdStokGirisKartDBTableView1: TcxGridDBTableView;
    cxgrdStokGirisKartDBTableView1YIL: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1DBColumn3: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1DBGIRNO: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1ALINANFRMA: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1BELGETARH: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1DBBELGENO: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1ADET: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1BRM: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1BRMFYAT: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1SKONTO1: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1SKONTO2: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1TUTAR: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1SONKULLANMATARH: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1DBColumn1: TcxGridDBColumn;
    cxgrdStokGirisKartDBTableView1DBColumn2: TcxGridDBColumn;
    cxgrdStokGirisKartLevel1: TcxGridLevel;
    Panel6: TPanel;
    LabelGirisUyari: TLabel;
    GirisExceleAktarBtn: TSpeedButton;
    CheckGirisUyari: TCheckBox;
    tshCikis: TTabSheet;
    cxGridStokCikislar: TcxGrid;
    cxGridStokCikislari: TcxGridDBTableView;
    cxGridStokCikislariYIL: TcxGridDBColumn;
    CikisTuru: TcxGridDBColumn;
    CikisTarih: TcxGridDBColumn;
    CikisNo: TcxGridDBColumn;
    CikisYeri: TcxGridDBColumn;
    CikisHedef: TcxGridDBColumn;
    CikisAdet: TcxGridDBColumn;
    CikisBirim: TcxGridDBColumn;
    CikisMiktar: TcxGridDBColumn;
    CikisPersonel: TcxGridDBColumn;
    CikisSkt: TcxGridDBColumn;
    cxGridStokCikislarLevel1: TcxGridLevel;
    Panel7: TPanel;
    LabelCikisUyari: TLabel;
    CikisExceleAktarBtn: TSpeedButton;
    CheckCikisUyari: TCheckBox;
    tshTeknikSartname: TTabSheet;
    DBMemo1: TDBMemo;
    tshStokPanel: TTabSheet;
    Panel10: TPanel;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    GridStokPanel: TDBGrid;
    tsKritikSeviye: TTabSheet;
    Panel9: TPanel;
    GenNgKritikSeviye: TGenDBNavigator;
    cxGridKritikSeviye: TcxGrid;
    TableViewKritikSeviye: TcxGridDBTableView;
    TableViewKritikSeviyeDEPOADI: TcxGridDBColumn;
    TableViewKritikSeviyeKRITIKSEVIYE: TcxGridDBColumn;
    cxGridKritikSeviyeWiew: TcxGridLevel;
    PanelKartBilgi: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    DBText1: TcxDBTextEdit;
    DBEdit1: TcxDBTextEdit;
    DBEdit2: TcxDBTextEdit;
    ComboGRUBU: TcxDBImageComboBox;
    ComboOZELLIK: TcxDBImageComboBox;
    ComboANABIRIM: TcxDBImageComboBox;
    ComboBIRIM2: TcxDBImageComboBox;
    EditBirim2Miktar: TcxDBTextEdit;
    EditBarkod: TcxDBTextEdit;
    cxButton1: TcxButton;
    Panel12: TPanel;
    Label11: TLabel;
    Label13: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label12: TLabel;
    Label17: TLabel;
    Label16: TLabel;
    Label20: TLabel;
    DBEdit10: TcxDBTextEdit;
    EditKDV: TcxDBTextEdit;
    SKTCheckBox: TcxDBCheckBox;
    ReuseCheckBox: TcxDBCheckBox;
    EditOZELKOD: TcxDBTextEdit;
    EditMUHKODU: TcxDBTextEdit;
    dbchbSeri: TcxDBCheckBox;
    CheckPasifKartlar: TCheckBox;
    PopupMenu1: TPopupMenu;
    BukartnGiriklarnGncelle1: TMenuItem;
    N1: TMenuItem;
    TmkartlarnGiriklarnGncelle1: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu2: TPopupMenu;
    YeniFiyatOlutur1: TMenuItem;
    N8: TMenuItem;
    FiyatKopyala: TMenuItem;
    MenuItem2: TMenuItem;
    FiyatAdiniDegistir: TMenuItem;
    N3: TMenuItem;
    FiyatSil: TMenuItem;
    N5: TMenuItem;
    YuzdeArtma: TMenuItem;
    YuzdeAzaltma: TMenuItem;
    N2: TMenuItem;
    YeniFiyatBilgileriniAl: TMenuItem;
    PopupMenu3: TPopupMenu;
    MenuItem1: TMenuItem;
    N4: TMenuItem;
    AnaBirimDeitir1: TMenuItem;
    N2BirimDeitir1: TMenuItem;
    N6: TMenuItem;
    KartKopyala1: TMenuItem;
    XPMenu1: TXPMenu;
    cxGridPopupMenu1: TcxGridPopupMenu;
    cxGridPopupMenu2: TcxGridPopupMenu;
    GridFiyat: TcxGrid;
    GridFiyatView: TcxGridDBTableView;
    GridFiyatLevel1: TcxGridLevel;
    ToolBar3: TToolBar;
    BankaEkleTus: TToolButton;
    BankaSilTus: TToolButton;
    BankaKaydetTus: TToolButton;
    BankaIptalTus: TToolButton;
    GridStokDurum: TcxGrid;
    GridStokDurumView: TcxGridDBTableView;
    GridStokDurumLevel1: TcxGridLevel;
    TabStok: TFDQuery;
    DtsStok: TDataSource;
    Label7: TLabel;
    ComboDURUM: TcxDBImageComboBox;
    procedure btnKapatClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
  private
    { Private declarations }
    FKapatEylemi: TNotifyEvent;
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
    
    { Gezinme ve yazdirma destegi }
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
    function EkranAdiAl : string;
  public
    { Public declarations }
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
    procedure StokEkranInit(AStokId: Integer);
  end;

implementation

uses Utablo, FetaClassExtensions;

{$R *.dfm}

{ TStokDlg }

procedure TStokDlg.Baslatildi;
begin

end;

procedure TStokDlg.StokEkranInit(AStokId: Integer);
begin
  TabStok.Close;
//  if ARehberId <> -1 then begin
//    if ARehberId = -2 then
//      TabRehber.InitSql('SELECT TOP 1 *  FROM REHBER ORDER BY ID DESC',[],[])
//    else
  TabStok.SQL.Text := 'SELECT *   FROM STOKLAR WHERE ID = :ID';
  TabStok.Params.ParamByName('ID').AsInteger := AStokId;
//  end else { Yani -1 -> Boþ Çek senet ekraný için boþ bir query }
//    TabRehber.InitSql('SELECT TOP 0  * FROM REHBER ',[],[]);
  TabStok.Open;
end;

procedure TStokDlg.btnKapatClick(Sender: TObject);
begin
  if TabStok.State in [dsEdit, dsInsert] then
     TabStok.post;

  if Assigned(FKapatEylemi) then
     FKapatEylemi(Self);
end;

procedure TStokDlg.EkleTusClick(Sender: TObject);
var ID : Integer;
begin
   ID := Tablo.StokSihirbazBaslat('E',0,-1);
   if ID<>-99 then
      StokEkranInit(ID);
end;

function TStokDlg.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TStokDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TStokDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TStokDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TStokDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TStokDlg.GetKapatilabilir: Boolean;
begin

end;

function TStokDlg.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TStokDlg.Gorunmez;
begin

end;

procedure TStokDlg.GorunmezOlacak;
begin

end;

procedure TStokDlg.Gorunur;
begin
   Tablo.StokInit(ComboDURUM.Properties, ComboGRUBU.Properties, ComboOZELLIK.Properties, ComboANABIRIM.Properties, ComboBIRIM2.Properties);
end;

procedure TStokDlg.GorunurOlacak;
begin

end;

procedure TStokDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TStokDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TStokDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TStokDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TStokDlg.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TStokDlg.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TStokDlg);
end.







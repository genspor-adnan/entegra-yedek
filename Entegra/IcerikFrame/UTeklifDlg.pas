unit UTeklifDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:10}
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
  DB, cxDBData, cxDropDownEdit, frxClass, frxDBSet, FireDAC.Comp.Client, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, Grids, cxLabel, cxDBLabel, ToolWin, jpeg, cxImage,
  cxImageComboBox, cxDBEdit, cxMemo, Buttons, ExtCtrls;

type
  TTeklifDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    Panel3: TPanel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label19: TLabel;
    FTarihTus: TSpeedButton;
    LabelFatNo: TLabel;
    Label22: TLabel;
    Label21: TLabel;
    Label20: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    btnKapat: TSpeedButton;
    Label11: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    DBTextKNO: TcxDBTextEdit;
    MemoFatAdres: TcxDBMemo;
    EditVD: TcxDBTextEdit;
    EditVNo: TcxDBTextEdit;
    EditFatTarih: TcxDBTextEdit;
    EditFatNo: TcxDBTextEdit;
    DBEdit3: TcxDBTextEdit;
    ComboKDV: TcxDBComboBox;
    DBEdit9: TcxDBTextEdit;
    DBComboBox1: TcxDBComboBox;
    ComboDURUM: TcxDBImageComboBox;
    cxImage1: TcxImage;
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    ToolButton5: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton2: TToolButton;
    ResimTus: TToolButton;
    ToolButton4: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton1: TToolButton;
    KapatTus: TToolButton;
    LabelKOD: TcxDBLabel;
    LabelFIRMA: TcxDBLabel;
    EditILCE: TcxDBTextEdit;
    EditIL: TcxDBTextEdit;
    cxDBImageComboBox2: TcxDBImageComboBox;
    Panel4: TPanel;
    Label27: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label8: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    DBEdit1: TcxDBTextEdit;
    ComboAMBARNO: TcxDBComboBox;
    DBEdit4: TcxDBTextEdit;
    DBEdit5: TcxDBTextEdit;
    GridFaturaToplam: TStringGrid;
    DBComboBox2: TcxDBComboBox;
    DBEdit8: TcxDBTextEdit;
    DBEdit10: TcxDBTextEdit;
    DBEdit11: TcxDBTextEdit;
    ComboFatKur: TcxDBComboBox;
    DOVIZ_TUTARI: TcxDBTextEdit;
    ComboDovizKur: TcxDBComboBox;
    GridFat: TcxGrid;
    GridFatDBTableView1: TcxGridDBTableView;
    GridFatDBTableView1KOD1: TcxGridDBColumn;
    GridFatDBTableView1ACIKLAMA1: TcxGridDBColumn;
    GridFatDBTableView1ADET1: TcxGridDBColumn;
    GridFatDBTableView1BIRIM1: TcxGridDBColumn;
    GridFatDBTableView1BIRIMFIYAT1: TcxGridDBColumn;
    GridFatDBTableView1ISKONTO1: TcxGridDBColumn;
    GridFatDBTableView1KDV1: TcxGridDBColumn;
    GridFatDBTableView1TUTAR1: TcxGridDBColumn;
    GridFatDBTableView1MASRAFKOD: TcxGridDBColumn;
    GridFatDBTableView1MASRAFAD: TcxGridDBColumn;
    GridFatLevel1: TcxGridLevel;
    PopupMenuFatura: TPopupMenu;
    BoSatrEkle1: TMenuItem;
    N16: TMenuItem;
    FaturaKoanAyarlar1: TMenuItem;
    BuKullancdaFaturaKoannDeitir1: TMenuItem;
    N21: TMenuItem;
    FaturaIptalIsaretle: TMenuItem;
    MenuItem48: TMenuItem;
    FatHepsiniSil: TMenuItem;
    FaturayiptalEt1: TMenuItem;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    TabTeklifDetay: TFDQuery;
    DtsFatura: TDataSource;
    TabTeklif: TFDQuery;
    DtsFatBaslik: TDataSource;
    frxFATURA: TfrxDBDataset;
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
    TabRehber: TFDQuery;
    DtsRehber: TDataSource;
    frxFATBASLIK: TfrxDBDataset;
    procedure KapatTusClick(Sender: TObject);
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
  end;

implementation

{$R *.dfm}

{ TTeklifDlg }

procedure TTeklifDlg.Baslatildi;
begin

end;

function TTeklifDlg.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TTeklifDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TTeklifDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeklifDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTeklifDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTeklifDlg.GetKapatilabilir: Boolean;
begin

end;

function TTeklifDlg.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TTeklifDlg.Gorunmez;
begin

end;

procedure TTeklifDlg.GorunmezOlacak;
begin

end;

procedure TTeklifDlg.Gorunur;
begin

end;

procedure TTeklifDlg.GorunurOlacak;
begin

end;

procedure TTeklifDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTeklifDlg.KapatTusClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
    FKapatEylemi(Self);
end;

procedure TTeklifDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTeklifDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeklifDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTeklifDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TTeklifDlg.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TTeklifDlg.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TTeklifDlg);
end.


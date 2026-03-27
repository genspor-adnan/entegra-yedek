unit UKasa;
//tcxintl not found cxintl1
interface

uses StdCtrls, Grids,  DBGrids, ComCtrls, Controls, Classes,
  ExtCtrls, Forms, Db, SysUtils, DBCtrls, Menus, Dialogs,
  ToolWin, FireDAC.Comp.Client, graphics, windows, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxButtonEdit, cxDropDownEdit,
  cxGridCustomPopupMenu, cxGridPopupMenu, Variants, cxCalendar,
  cxPropertiesStore, cxCheckBox, cxContainer, cxTextEdit, cxMaskEdit,
  cxDBEdit, Buttons, cxCurrencyEdit, cxImageComboBox, UGentegreFrameYonetimi,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, dxSkinscxPCPainter,UFrameYoneticisi, cxMemo,
  cxLookAndFeelPainters, cxButtons, UGunlukAksiyonAramaFrame, cxLookAndFeels,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, dxBarBuiltInMenu;

type
  TKasaDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsKasa :TDataSource;
    TabKasa: TFDQuery;
    PopupMenu1 :TPopupMenu;
    Toplam: TFDQuery;
    DtsToplam :TDataSource;
    Splitter1 :TSplitter;
    PanelToplam :TPanel;
    ToplamHESAPKODU :TStringField;
    ToplamHESAPADI :TStringField;
    ToplamKUR :TStringField;
    ToplamDEVIR :TBCDField;
    //ToplamGIREN :TBCDField;
    ToplamCIKAN :TBCDField;
    StatusBar1 :TStatusBar;
    cxPropertiesStore1 :TcxPropertiesStore;
    Label7 :TLabel;
    Label8 :TLabel;
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    cxGrid1: TcxGrid;
    KasaGrid: TcxGridDBTableView;
    KasaGridTUR: TcxGridDBColumn;
    KasaGridDURUM: TcxGridDBColumn;
    KasaGridBELGENO: TcxGridDBColumn;
    KasaGridKAYITTARIH: TcxGridDBColumn;
    KasaGridCARIKOD: TcxGridDBColumn;
    KasaGridCARIAD: TcxGridDBColumn;
    KasaGridACIKLAMA: TcxGridDBColumn;
    KasaGridHESAPKODU: TcxGridDBColumn;
    KasaGridHESAPADI: TcxGridDBColumn;
    KasaGridGIREN: TcxGridDBColumn;
    KasaGridCIKAN: TcxGridDBColumn;
    KasaGridKASA: TcxGridDBColumn;
    KasaGridONAY: TcxGridDBColumn;
    KasaGridKULLANICI: TcxGridDBColumn;
    KasaGridMASRAFKOD: TcxGridDBColumn;
    KasaGridMASRAFAD: TcxGridDBColumn;
    KasaGridKUR: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    GridToplam: TcxGrid;
    GridToplamLevel1: TcxGridLevel;
    GridToplamDBTableView1: TcxGridDBTableView;
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
    SQLKasa: TcxMemo;
    SQLFatura: TcxMemo;
    SQLCekSenet: TcxMemo;
    SQLStokGiris: TcxMemo;
    EkleMenu: TMenuItem;
    SilMenu: TMenuItem;
    GorMenu: TMenuItem;
    ToolButton1: TToolButton;
    GorTus: TToolButton;
    KasaGridAKSIYONTARIH: TcxGridDBColumn;
    N2: TMenuItem;
    Ekstre1: TMenuItem;
    SQLPersonel: TcxMemo;
    GridToplamDBTableView1HESAPKODU: TcxGridDBColumn;
    GridToplamDBTableView1HESAPADI: TcxGridDBColumn;
    GridToplamDBTableView1DEVIR: TcxGridDBColumn;
    GridToplamDBTableView1GIREN: TcxGridDBColumn;
    GridToplamDBTableView1CIKAN: TcxGridDBColumn;
    GridToplamDBTableView1KUR: TcxGridDBColumn;
    GridToplamDBTableView1KALAN: TcxGridDBColumn;
    Varlklar1: TMenuItem;
    VarliklarTus: TToolButton;
    ToolButton3: TToolButton;
    cxGridPopupMenu1: TcxGridPopupMenu;
    ToplamKALAN: TBCDField;
    procedure FormCreate(Sender :TObject);
    procedure DtsKasaStateChange(Sender :TObject);
    procedure Calendar1Change(Sender :TObject);
    procedure FormActivate(Sender :TObject);
    procedure KasaGridMouseUp(Sender :TObject; Button :TMouseButton;
      Shift :TShiftState; X, Y :Integer);
    procedure CheckFatClick(Sender :TObject);
    procedure CheckKasaClick(Sender :TObject);
    procedure KasaGridCARIKODPropertiesButtonClick(Sender :TObject;
      AButtonIndex :Integer);
    procedure KasaGridCARIADPropertiesButtonClick(Sender :TObject;
      AButtonIndex :Integer);
    procedure KasaGridMASRAFKODPropertiesButtonClick(Sender :TObject;
      AButtonIndex :Integer);
    procedure KasaGridStylesGetContentStyle(Sender :TcxCustomGridTableView;
      ARecord :TcxCustomGridRecord; AItem :TcxCustomGridTableItem;
      out AStyle :TcxStyle);
    procedure btnBelgePropertiesButtonClick(Sender :TObject;
      AButtonIndex :Integer);
    procedure ChStokClick(Sender :TObject);
    procedure Button1Click(Sender :TObject);
    procedure Button2Click(Sender :TObject);
    procedure GridToplamDblClick(Sender: TObject);
    procedure TabKasaAfterOpen(DataSet: TDataSet);
    procedure EkleTusClick(Sender: TObject);
    procedure CheckBankaClick(Sender: TObject);
    procedure CheckPlanClick(Sender: TObject);
    procedure CheckCekSenetClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure GorTusClick(Sender: TObject);
    procedure Ekstre1Click(Sender: TObject);
    procedure BtnToplamClick(Sender: TObject);
    procedure ToplamAfterOpen(DataSet: TDataSet);
    procedure VarliklarTusClick(Sender: TObject);
  private
    { private declarations }
    SonKaydedilenSiraNo :Integer;
    { IBilgiFrame üyeleri            }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama : TGunlukAksiyonAramaFrame;
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
    {********************************}
    procedure KasaSilmeIslemleri;
    procedure CariAdRehberKaydaErisildi(Sender: TObject);
    procedure KasaMasrafRehberKaydaErisildi(Sender: TObject);
    procedure SetArama(const Value: TGunlukAksiyonAramaFrame);
    procedure EkstreKapatEylemi(Sender: TObject);
  public
    { public declarations }
    ParaSource :TDataSource;
    procedure SayfaDokumu(Sender :TObject);
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  published
    property Arama : TGunlukAksiyonAramaFrame read FArama write SetArama;
  end;

var
  Miktar, KasaEkAlanlar,KasaEkAlanlar2 :string;
  
implementation

uses UTablo, UAnaForm, UMesaj, UCombo,
  URehAraDlg, UGrid, UQuantGrid, FetaUtil, UListe, UListeCheck,
  UVadesiGelmisler, UCekSenetArama, Math, DateUtils, UBelgeDosya, UCekListe,UCxUtils,
  UKasaWizard, FetaKurulusSiniflari, FetaClassExtensions,
  FetaClassExtensionsConsts, UTakvimOnay, UTakvimGelenFatura,UTakvimBankaParaTransfer,
  UTakvimGidenFatura, UTakvimGelenCek, UTakvimGidenCek,UCari,UTakvimKrediKarti,UTakvimAcilisKaydi ;

{$R *.DFM}
var
  YeniEklenenKayit, Sor, CheckCariKod, CheckAciklama, CheckHesapKod, CheckMiktar, CheckMasrafKod :boolean;
  CheckMasrafAd, checkVadeSor, CheckTahakkukMasrafAd :Boolean;

  GelenMasrafSor, vbBasIndex, vbAyracIndex, vbBitIndex, vbMaxKasaNo, vbKasaSirano, vbGeriDonusId :integer;
  vbTahTarih, vbSirano, vade, SeriNo :string;

procedure TKasaDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TKasaDlg.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TKasaDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKasaDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKasaDlg.FormCreate(Sender :TObject);
var
  i, ATuru:smallint;
  AlanAdi, s : String[40];
//  List2 : TStringList;
  x : TcxGridDBColumn;
begin
  KasaGrid.RestoreFromRegistry('SOFTWARE\ENTEGRA\Gridler\KasaGrid', true, false, [gsoUseFilter], 'KasaGrid');
  cxUtils.SetcxGridPopupMenu(cxGrid1, nil, true);

  Sor := True;
  FArama.ChStok.Checked := True;
  FArama.ChStok.Visible := super;

  FArama.Calendar1.Date := GenotipIni.BugunTrh;

  FArama.CheckFat.Checked := RehberIni.ReadBool('KasaEkran', 'Tahakkuk', True);
  FArama.CheckKasa.Checked := RehberIni.ReadBool('KasaEkran', 'Kasa', True);
  FArama.CheckBanka.Checked := RehberIni.ReadBool('KasaEkran', 'Banka', True);
  FArama.CheckCekSenet.Checked := RehberIni.ReadBool('KasaEkran', 'ÇekveSenet', True);
  FArama.CheckPlan.Checked := RehberIni.ReadBool('KasaEkran', 'Plan', True);
  FArama.CheckTop.Checked := RehberIni.ReadBool('KasaEkran', 'Toplamlar', True);
  FArama.ChStok.Checked := RehberIni.ReadBool('KasaEkran', 'StoktanGirisler', True);


  //PanelToplam.Visible := FArama.CheckTop.Checked;
  Calendar1Change(Self);

  CheckCariKod := RehberIni.ReadBool('HizliGiris', 'CheckCariKod', False);
  CheckAciklama := RehberIni.ReadBool('HizliGiris', 'CheckAciklama', False);
  CheckHesapKod := RehberIni.ReadBool('HizliGiris', 'CheckHesapKod', False);
  CheckMiktar := RehberIni.ReadBool('HizliGiris', 'CheckMiktar', False);
  CheckMasrafKod := RehberIni.ReadBool('HizliGiris', 'CheckMasrafKod', False);
  CheckMasrafAd := RehberIni.ReadBool('HizliGiris', 'CheckMasrafAd', False);
  CheckTahakkukMasrafAd := RehberIni.ReadBool('HizliGiris', 'CheckTahakkukMasrafAd', False);
  checkVadeSor := RehberIni.ReadBool('HizliGiris', 'VadeSor', False);
  GelenMasrafSor := RehberIni.ReadInteger('HizliGiris', 'GelenMasrafSor', 1);
end;

procedure TKasaDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKasaDlg.KasaMasrafRehberKaydaErisildi(Sender: TObject);
begin
  if TRehberAraDlg(Sender).AraQuery1.RecordCount > 0 then
  begin
    with Veritabani.SorguBaslat(Tablo.FDCnn,'SELECT KOD,FIRMA FROM REHBER ID = $1',
      ['$1'],[TRehberAraDlg(Sender).AraQuery1.AsInteger[0]]) do
    try
      TabKasa.Edit;
      KasaGridMASRAFKOD.DataBinding.Field.AsString := AsString[0];
      KasaGridMASRAFKOD.DataBinding.Field.AsString := AsString[1];
    finally
      Free;
    end;
  end;
end;

procedure TKasaDlg.CariAdRehberKaydaErisildi(Sender: TObject);
begin
  if TRehberAraDlg(Sender).AraQuery1.RecordCount > 0 then
  begin
    with Veritabani.SorguBaslat(Tablo.FDCnn,'SELECT KOD,FIRMA FROM REHBER ID = $1',
      ['$1'],[TRehberAraDlg(Sender).AraQuery1.AsInteger[0]]) do
    try
      TabKasa.Edit;
      KasaGridCARIKOD.DataBinding.Field.AsString := AsString[0];
      KasaGridCARIAD.DataBinding.Field.AsString := AsString[1];
    finally
      Free;
    end;
  end;
end;



destructor TKasaDlg.Destroy;
begin
  KasaGrid.StoreToRegistry('KasaGrid', true, [gsoUseFilter], 'KasaGrid');
  inherited;
end;

procedure TKasaDlg.DtsKasaStateChange(Sender :TObject);
begin
  Tablo.YetkiTuslariBelirle('Gent-Kasa', '', 'AE', DtsKasa, AnaForm.ToolBarNavigator);
end;

procedure TKasaDlg.KasaSilmeIslemleri;
Var CekSenetId, s:String;
    Tur, HId : Integer;
    Giren, Cikan : Currency;
begin
  if (TabKasa.FieldByName('ONAY').AsString <> '') and (not Super) then
    raise Exception.Create('Kesinleþmiþ kayýt..');
  vbKasaSirano := TabKasa.FieldByName('ID').AsInteger;

  /// SQL2005 TE hataya neden olduðu için delete olayýný kendimiz yapýyoruz

  Hid := TabKasa.FieldByName('HESAPID').AsInteger;
  Tur := TabKasa.FieldByName('TUR').AsInteger;
  Giren := TabKasa.FieldByName('GIREN').AsCurrency;
  Cikan := TabKasa.FieldByName('CIKAN').AsCurrency;

  if Tur=111 then begin //eðer kredi ödemesi ise ödendi iþaretini kaldýralým
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'update PLANKREDI set ODENMIS = 0 where ID=' +TabKasa.FieldByName('KREDIID').AsString  + ' and  KREDIID='+TabKasa.FieldByName('FATURAID').AsString;
     Tablo.Query1.ExecSQL;
  end;

  if Tur in [23,24,33,34] then begin
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'delete from CEKSENETLER where ID='+TabKasa.FieldByName('ID').AsString;
     Tablo.Query1.ExecSQL;
  end else if Tur in [11,15] then begin
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'delete from FATURA where FATBASID='+TabKasa.FieldByName('ID').AsString;
     Tablo.Query1.ExecSQL;
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'delete from FATBASLIK where ID='+TabKasa.FieldByName('ID').AsString;
     Tablo.Query1.ExecSQL;
  end else if Tur in [25,35] then begin
     s := IIf(TabKasa.FieldByName('TUR').AsInteger = 25, 'POS', 'KREDIKARTI');
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'delete from '+s+' where ID='+TabKasa.FieldByName('ID').AsString;
     Tablo.Query1.ExecSQL;
  end;


  if Tur in [21,22,25,31,32,35,61,71] then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'DELETE FROM KASA WHERE ID = ' + inttostr(vbKasasirano) + '';
      Tablo.Query1.ExecSQL;
  end;

  Calendar1Change(Self);


  /// SQL2005 TE hataya neden olduðu için delete olayýný kendimiz yapýyoruz
  Abort;

  //   Tablo.LogIslemleri('Cari', 'Silme', TabKasa, True);
end;

procedure TKasaDlg.TabKasaAfterOpen(DataSet: TDataSet);
begin
//  TCurrencyField(TabKasa.FieldByName('GIREN')).DisplayFormat := '###,###,###,##0.00';
//  TCurrencyField(TabKasa.FieldByName('CIKAN')).DisplayFormat := '###,###,###,##0.00';
end;

procedure TKasaDlg.VarliklarTusClick(Sender: TObject);
begin
  if VarliklarTus.Tag = 0 then begin
    PanelToplam.Visible := True;
    Toplam.Params[0].Value := FormatDateTime('YYYY-MM-DD 00:00', FArama.Calendar1.Date);
    Toplam.Params[1].Value := FormatDateTime('YYYY-MM-DD 23:59', FArama.Calendar1.Date);
    Toplam.Open;
    PanelToplam.Height := 24 + Toplam.RecordCount * 20;
    if PanelToplam.Height > 240 then PanelToplam.Height := 200;
    VarliklarTus.Tag := 1;
  end
  else  begin
    Toplam.Close;
    PanelToplam.Visible := False;
    PanelToplam.Height := 1;
    Calendar1Change(Self);
    VarliklarTus.Tag := 0
  end;
end;

procedure TKasaDlg.ToplamAfterOpen(DataSet: TDataSet);
begin
//  TCurrencyField(Toplam.FieldByName('DEVIR')).DisplayFormat := '###,###,###,##0.00';
//  TCurrencyField(Toplam.FieldByName('GIREN')).DisplayFormat := '###,###,###,##0.00';
//  TCurrencyField(Toplam.FieldByName('CIKAN')).DisplayFormat := '###,###,###,##0.00';
//  TCurrencyField(Toplam.FieldByName('KALAN')).DisplayFormat := '###,###,###,##0.00';
end;

procedure TKasaDlg.Calendar1Change(Sender :TObject);
begin
//  if not Tablo.TabRehber.Active then exit;

  if FArama.Calendar1.Date<StrToDate('01'+DateSeparator+'01'+DateSeparator+'2000') then exit;

  TabKasa.Close;
  TabKasa.SQL.Text := SQLKasa.Text+
    ' Where ' +
    ' K.ISLEMTARIHI >= ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 00:00:00'' and' +
    ' K.ISLEMTARIHI < ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 23:59:59'' ';

//  if not CheckTah.Checked then
//     TabKasa.SQL.Add(' and not(TUR between 11 and 19) ');
  if not FArama.CheckKasa.Checked then
     TabKasa.SQL.Add(' and not(K.TUR between 21 and 39) ');
  if not FArama.CheckPlan.Checked then
     TabKasa.SQL.Add(' and not(K.TUR between 61 and 69) ');


  //if FArama.CheckFat.Checked then
  begin
    TabKasa.SQL.add(SQLPersonel.Text+
    ' Where TARIH >= ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 00:00:00'' and' +
    ' TARIH < ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 23:59:59'' '+
    '      group by P.ID,REHBERID,TARIH,R.KOD,R.FIRMA,P.EKLEYEN, P.KUR, P.DURUM ' );
  end;

  if FArama.CheckFat.Checked then  begin
    TabKasa.SQL.add(SQLFatura.Text+
    ' Where ' +
    ' TARIH >= ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 00:00:00'' and' +
    ' TARIH < ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 23:59:59'' ');
  end;
  if FArama.CheckKasa.Checked then
  begin
    TabKasa.SQL.add(SQLCekSenet.Text+
    ' Where ' +
    ' C.TARIH >= ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 00:00:00'' and' +
    ' C.TARIH < ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 23:59:59'' ');
  end;
  if FArama.ChStok.Checked then
  begin
    TabKasa.SQL.add(SQLStokGiris.Text+
    ' Where ' +
    ' TARIH >= ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 00:00:00'' and' +
    ' TARIH < ''' + FormatDateTime('mm/dd/yyyy', FArama.Calendar1.Date) + ' 23:59:59'' ');
    TabKasa.SQL.Add(' ORDER BY 2 ');
  end;

  TabKasa.Open;
  KasaGrid.ApplyBestFit(nil);

end;

procedure TKasaDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasaDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasaDlg.FormActivate(Sender :TObject);
begin
  Calendar1Change(Self);

end;

procedure TKasaDlg.CheckBankaClick(Sender: TObject);
begin
  RehberIni.WriteBool('KasaEkran', 'Banka', FArama.CheckBanka.Checked);
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckCekSenetClick(Sender: TObject);
begin
  RehberIni.WriteBool('KasaEkran', 'ÇekveSenet', FArama.CheckCekSenet.Checked);
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckFatClick(Sender :TObject);
begin
  RehberIni.WriteBool('KasaEkran', 'Tahakkuk', FArama.CheckFat.Checked);
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckKasaClick(Sender :TObject);
begin
  RehberIni.WriteBool('KasaEkran', 'Kasa', FArama.CheckKasa.Checked);
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckPlanClick(Sender: TObject);
begin
  RehberIni.WriteBool('KasaEkran', 'Plan', FArama.CheckPlan.Checked);
  Calendar1Change(Self);
end;


procedure TKasaDlg.KasaGridMouseUp(Sender :TObject; Button :TMouseButton; Shift :TShiftState; X, Y :Integer);
begin
  if Assigned(QuantKasa) then
    QuantKasa.dxDBGridMouseUp(Sender, Button, Shift, X, Y, PopupMenu1);
end;

procedure TKasaDlg.EkleTusClick(Sender: TObject);
begin
  if KasaWizardDlg = nil then
     Application.CreateForm(TKasaWizardDlg, KasaWizardDlg);
  KasaWizardDlg.KasaTarihi.date := FArama.Calendar1.Date;
  KasaWizardDlg.LabelIslemTarih2.visible := False;
  KasaWizardDlg.DateIslemTarih2.visible := False;
//  KasaWizardDlg.LabelIslemTarih3.visible := False;
//  KasaWizardDlg.DateIslemTarih3.visible := False;
  KasaWizardDlg.WizardKontrol.SelectFirstPage;
  KasaWizardDlg.ShowModal;
  KasaWizardDlg.destroy;
  Calendar1Change(Self);
end;

procedure TKasaDlg.EkranYazdir(Sender: TObject);
begin

end;
procedure TKasaDlg.EkstreKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TKasaDlg.Ekstre1Click(Sender: TObject);
begin
  with TCariDlg(FFrameBilgi.IcerikGit(TCariDlg).Ornek) do begin
      KapatEylemi := EkstreKapatEylemi;
      KapatGorunsun := True;
      DokumTuru := 1;
      Arama.LabelCariHesapKodu.Caption := TabKasa.AsString['CARIKOD'];
      Arama.LabelCariUnvan.Caption := TabKasa.AsString['CARIAD'];
      Arama.LabelCariId.Caption := TabKasa.AsString['REHBERID'];
      InitIslemler;
  end;
end;

procedure TKasaDlg.SayfaDokumu(Sender :TObject);
var
  Siralama, SiraYonu, s :string[40];
begin
(*  s := TToolButton(Sender).Caption;
  Delete(s, pos('&', s), 1);
  if pos('Toplam', s) > 0 then
  begin
    RapTablo.KasaToplam.Close;
    RapTablo.KasaToplam.SQL.Text := Toplam.SQL.Text;
    RapTablo.KasaToplam.Open;
  end
  else
  begin
    {if KasaGrid.SortedColumn <> nil then begin
       if  KasaGrid.SortedColumn.Sorted = csUp   then begin
           Siralama := KasaGrid.SortedColumn.FieldName;     //TabFatTakipADSOYAD
           SiraYonu := ' ASC'
       end  else if   KasaGrid.SortedColumn.Sorted = csDown   then begin
           Siralama := KasaGrid.SortedColumn.FieldName;
           SiraYonu := ' desc';
       end;

    end;
    }
    RapTablo.Kasa.Close;
if pos('order',TabKasa.SQL.Text)>0 then
  Begin
    if Siralama = '' then
      RapTablo.Kasa.SQL.Text := copy(TabKasa.SQL.Text, 1, pos('Order By', TabKasa.SQL.Text) + 8) + ' 1'
    else
      RapTablo.Kasa.SQL.Text := copy(TabKasa.SQL.Text, 1, pos('Order By', TabKasa.SQL.Text) + 8) + ' ' + Siralama + ' ' + SiraYonu;
  End
  Else
    RapTablo.Kasa.SQL.Text := TabKasa.SQL.Text;
    RapTablo.Kasa.Open;
  end; *)
end;

procedure TKasaDlg.SetArama(const Value: TGunlukAksiyonAramaFrame);
begin
  FArama := Value;

end;

procedure TKasaDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKasaDlg.SilTusClick(Sender: TObject);
begin
   if TabKasa.FieldByName('TUR').AsInteger  in [1,2] then
      raise Exception.Create('Açýlýþ fiþi veya devir kaydý silinemez!!');
   if Application.MessageBox('Bu aksiyon silinsin mi?', 'O N A Y', MB_YESNO) = IDYES then
      KasaSilmeIslemleri;
end;
{
procedure TKasaDlg.KasaGridCustomDraw(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; ANode: TdxTreeListNode; AColumn: TdxDBTreeListColumn;
  const AText: String; AFont: TFont; var AColor: TColor; ASelected,
  AFocused: Boolean; var ADone: Boolean);
begin
If ANode.Count = 0 Then
Begin
        If Not ASelected Then
        Begin
              If ANode.Values[kasagrid.ColumnByFieldName('SIRANO').Index] = 0 Then
              Begin
                AColor := $00B0ECBF;
              End ;
        End ;
end;

end;
 }

procedure TKasaDlg.KasaGridCARIKODPropertiesButtonClick(Sender :TObject;
  AButtonIndex :Integer);
begin
  TRehberAraDlg(FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TRehberAraDlg).Git.Ornek).KayitErisimTamamlandi :=
    CariAdRehberKaydaErisildi;
end;

procedure TKasaDlg.KasaGridCARIADPropertiesButtonClick(Sender :TObject;
  AButtonIndex :Integer);
begin
  TRehberAraDlg(FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TRehberAraDlg).Git.Ornek).KayitErisimTamamlandi :=
    CariAdRehberKaydaErisildi;
end;

procedure TKasaDlg.KasaGridMASRAFKODPropertiesButtonClick(Sender :TObject;
  AButtonIndex :Integer);
begin
  TRehberAraDlg(FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TRehberAraDlg).Git.Ornek).KayitErisimTamamlandi :=
    KasaMasrafRehberKaydaErisildi;
end;

procedure TKasaDlg.KasaGridStylesGetContentStyle(
  Sender :TcxCustomGridTableView; ARecord :TcxCustomGridRecord;
  AItem :TcxCustomGridTableItem; out AStyle :TcxStyle);
var
  AColumn :TcxCustomGridTableItem;
begin
  AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('ID');
  if AColumn <> nil then
    if VarToStr(ARecord.Values[AColumn.Index]) = '0' then
    begin
      AStyle := tablo.cxstSecili;
    end
end;

procedure TKasaDlg.Baslatildi;
begin
  FormCreate(nil);
end;

procedure TKasaDlg.btnBelgePropertiesButtonClick(Sender :TObject;
  AButtonIndex :Integer);
var
  aciklama :string;
begin
  if TabKasa.FieldByName('ID').AsInteger = 0 then
  begin
    anahtarno := strtoint(copy(TabKasa.FieldByName('ACIKLAMA').AsString, 8, (pos(')', TabKasa.FieldByName('ACIKLAMA').AsString)) - 8));
    Application.CreateForm(TBelgeDosyaDlg, BelgeDosyaDlg);
    moduladi := 'Stok';
    TabloYenile(BelgeDosyaDlg.TabBelgeDosya, ['Stok', anahtarno]);
    BelgeDosyaDlg.ShowModal;
    BelgeDosyaDlg.Destroy;
  end
  else
  begin
    anahtarno := TabKasa.Fieldbyname('ID').AsInteger;
    Application.CreateForm(TBelgeDosyaDlg, BelgeDosyaDlg);
    moduladi := 'Gentegre';
    TabloYenile(BelgeDosyaDlg.TabBelgeDosya, ['Gentegre', anahtarno]);
    BelgeDosyaDlg.ShowModal;
    BelgeDosyaDlg.Destroy;
  end;
end;

procedure TKasaDlg.ChStokClick(Sender :TObject);
begin
  RehberIni.WriteBool('KasaEkran', 'StoktanGirisler', FArama.ChStok.Checked);
  Calendar1Change(Self);
end;

constructor TKasaDlg.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TKasaDlg.BtnToplamClick(Sender: TObject);
begin
  Toplam.Close;
  Toplam.Params[0].Value := FormatDateTime('YYYY-MM-DD 00:00', FArama.Calendar1.Date);
  Toplam.Params[1].Value := FormatDateTime('YYYY-MM-DD 23:59', FArama.Calendar1.Date);
  Toplam.Open;
  PanelToplam.Height := 24 + Toplam.RecordCount * 20;
  if PanelToplam.Height > 240 then PanelToplam.Height := 200;
end;

procedure TKasaDlg.Button1Click(Sender :TObject);
begin
  cxUtils.cxGridSaveToRegistry(cxGrid1);
end;

procedure TKasaDlg.Button2Click(Sender :TObject);
begin
  cxUtils.cxGridLoadFromRegistry(cxGrid1);
end;

function TKasaDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKasaDlg.GetKapatilabilir: Boolean;
begin

end;


procedure TKasaDlg.GorTusClick(Sender: TObject);
begin
   case TabKasa.FieldByName('TUR').AsInteger of
      11,12 : begin
                 Application.CreateForm(TTakvimGelenFaturaDlg, TakvimGelenFaturaDlg);
                 TakvimGelenFaturaDlg.ID := TabKasa.FieldByName('ID').AsInteger;
                 TakvimGelenFaturaDlg.showmodal;
                 TakvimGelenFaturaDlg.Destroy;
              end;
      15,16 : begin
                 Application.CreateForm(TTakvimGidenFaturaDlg, TakvimGidenFaturaDlg);
                 TakvimGidenFaturaDlg.ID := TabKasa.FieldByName('ID').AsInteger;
                 TakvimGidenFaturaDlg.showmodal;
                 TakvimGidenFaturaDlg.Destroy;
              end;
      23 :    begin
                 Application.CreateForm(TTakvimGelenCekDlg, TakvimGelenCekDlg);
                 TakvimGelenCekDlg.ID := TabKasa.FieldByName('ID').AsInteger;
                 TakvimGelenCekDlg.showmodal;
                 TakvimGelenCekDlg.Destroy;
              end;
      35:     Begin
                 Application.CreateForm(TTakvimKrediKartiDlg, TakvimKrediKartiDlg);
                 TakvimKrediKartiDlg.KasaID := TabKasa.FieldByName('ID').AsInteger;
                 TakvimKrediKartiDlg.KKID := TabKasa.FieldByName('HESAPID').AsInteger;
                 TakvimKrediKartiDlg.showmodal;
                 TakvimKrediKartiDlg.Destroy;
              End;
      33 :    begin
                 Application.CreateForm(TTakvimGidenCekDlg, TakvimGidenCekDlg);
                 TakvimGidenCekDlg.ID := TabKasa.FieldByName('ID').AsInteger;
                 TakvimGidenCekDlg.showmodal;
                 TakvimGidenCekDlg.Destroy;
              end;
      21,22,31,32,61,71:
              begin
                Application.CreateForm(TTakvimBankaParaTransferDlg, TakvimBankaParaTransferDlg);
                TakvimBankaParaTransferDlg.ID := TabKasa.FieldByName('ID').AsInteger;
                TakvimBankaParaTransferDlg.IsTuru := TabKasa.FieldByName('TUR').AsInteger;
                TakvimBankaParaTransferDlg.showmodal;
                TakvimBankaParaTransferDlg.Destroy;
              end;
   else
              begin
                 Application.CreateForm(TTakvimOnayDlg, TakvimOnayDlg);
                 TakvimOnayDlg.Sirano := TabKasa.FieldByName('ID').AsInteger;
                 TakvimOnayDlg.Tur := TabKasa.FieldByName('TUR').AsInteger;
                 TakvimOnayDlg.InitIslemler;
                 TakvimOnayDlg.ToolBarAlt.visible := False;
                 TakvimOnayDlg.ShowModal;
                 TakvimOnayDlg.Destroy;
              end
   end;
   Calendar1Change(Self);
end;

procedure TKasaDlg.Gorunmez;
begin

end;

procedure TKasaDlg.GorunmezOlacak;
begin

end;

procedure TKasaDlg.Gorunur;
begin
  FormActivate(nil);
end;

procedure TKasaDlg.GorunurOlacak;
begin

end;

procedure TKasaDlg.GridToplamDblClick(Sender: TObject);
begin


   if (pos('101', Toplam.FieldByName('HESAPKODU').AsString) > 0) or (pos('103', Toplam.FieldByName('HESAPKODU').AsString) > 0) then
  begin
     if CekListeDlg = nil then
        Application.CreateForm(TCekListeDlg,CekListeDlg);

      CekListeDlg.ShowModal;
  end;
end;

initialization
  Classes.RegisterClass(TKasaDlg);

end.

{
Emre: stoktaki iade çýkýþ bölümü var firmalara iade faturalarýnýn kesildiði bölüm, bu faturalarý da gentegre de görmek istiyor malatya


Emre Baytar is online.
Emre: giriþ faturalarý firma carisine yansýyor ama iadeler yapýlmamýþ þimdi denedik de
bunu da eklermisiniz
ahmet le konusursunuz nasýl olacaðýný sanýrm
}






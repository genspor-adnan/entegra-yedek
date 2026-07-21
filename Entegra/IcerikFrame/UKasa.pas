unit  UKasa;
//tcxintl not found cxintl1
interface

uses StdCtrls,  Grids, DBGrids, ComCtrls, Controls, Classes,
  ExtCtrls, Forms, Db, SysUtils, DBCtrls, Menus, Dialogs,
  ToolWin, FireDAC.Comp.Client, graphics, windows, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxButtonEdit, cxDropDownEdit,
  cxGridCustomPopupMenu, cxGridPopupMenu, Variants, cxCalendar,
  cxPropertiesStore, cxCheckBox, cxContainer, cxTextEdit, cxMaskEdit,
  cxDBEdit, Buttons, cxCurrencyEdit, cxImageComboBox, UGentegreFrameYonetimi,
  dxSkinscxPCPainter,UFrameYoneticisi, cxMemo,
  cxLookAndFeelPainters, cxButtons, UGunlukAksiyonAramaFrame, dxSkinsCore,
  dxSkinLondonLiquidSky, frxclass,Utablo, frxDBSet, dxSkinLiquidSky,
  cxLookAndFeels, cxNavigator, cxSplitter, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations, dxBarBuiltInMenu, frCoreClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TKasaDlg = class(TFrame, IPopupDialog, IIcerikBilgiFrame, IBilgiFrame)// IAracCubuguDestegi
    DtsKasa :TDataSource;
    KASA: TFDQuery;
    PopupMenu1 :TPopupMenu;
    DtsToplam :TDataSource;
    Splitter1 :TSplitter;
    PanelToplam :TPanel;
    StatusBar1 :TStatusBar;
    cxPropertiesStore1 :TcxPropertiesStore;
    Label7 :TLabel;
    Label8 :TLabel;
    ToolBar1: TToolBar;
    SilTus: TToolButton;
    cxGrid1: TcxGrid;
    KasaGrid: TcxGridDBTableView;
    KasaGridTUR: TcxGridDBColumn;
    KasaGridDURUM: TcxGridDBColumn;
    KasaGridBELGENO: TcxGridDBColumn;
    KasaGridCARIKOD: TcxGridDBColumn;
    KasaGridCARIAD: TcxGridDBColumn;
    KasaGridACIKLAMA: TcxGridDBColumn;
    KasaGridHESAPKODU: TcxGridDBColumn;
    KasaGridHESAPADI: TcxGridDBColumn;
    KasaGridBORC: TcxGridDBColumn;
    KasaGridALACAK: TcxGridDBColumn;
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
    SQLCek: TcxMemo;
    EkleMenu: TMenuItem;
    SilMenu: TMenuItem;
    GorMenu: TMenuItem;
    TahsilMenu2: TMenuItem;
    OdemeMenu2: TMenuItem;
    ToolButton1: TToolButton;
    GorTus: TToolButton;
    KasaGridAKSIYONTARIH: TcxGridDBColumn;
    N2: TMenuItem;
    EkstreMenu: TMenuItem;
    SQLPersonel: TcxMemo;
    GridToplamDBTableView1HESAPKODU: TcxGridDBColumn;
    GridToplamDBTableView1HESAPADI: TcxGridDBColumn;
    GridToplamDBTableView1DEVIR: TcxGridDBColumn;
    GridToplamDBTableView1GIREN: TcxGridDBColumn;
    GridToplamDBTableView1CIKAN: TcxGridDBColumn;
    GridToplamDBTableView1KUR: TcxGridDBColumn;
    Varlklar1: TMenuItem;
    VarliklarTus: TToolButton;
    ToolButton3: TToolButton;
    cxGridPopupMenu1: TcxGridPopupMenu;
    GridToplamDBTableView1KALAN: TcxGridDBColumn;
    TabToplam: TFDQuery;
    SQLSenet: TcxMemo;
    YeniTus: TToolButton;
    PopupMenuYeni: TPopupMenu;
    MenuItem4: TMenuItem;
    GelenBelge1: TMenuItem;
    Satbelgesi1: TMenuItem;
    Fatura1: TMenuItem;
    Fi1: TMenuItem;
    rsaliye1: TMenuItem;
    Fatura2: TMenuItem;
    Fi2: TMenuItem;
    rsaliye2: TMenuItem;
    ahsilat1: TMenuItem;
    mnOdeme: TMenuItem;
    N1: TMenuItem;
    GelirPlan1: TMenuItem;
    demePlan1: TMenuItem;
    Nakit1: TMenuItem;
    HavaleEFT1: TMenuItem;
    ek1: TMenuItem;
    CekOde2: TMenuItem;
    Senet1: TMenuItem;
    Nakit2: TMenuItem;
    HavaleEFT2: TMenuItem;
    KrediKart1: TMenuItem;
    CekOde: TMenuItem;
    Senet2: TMenuItem;
    N3: TMenuItem;
    AlacakTahakkuku: TMenuItem;
    N4: TMenuItem;
    BorTahakkuku1: TMenuItem;
    N5: TMenuItem;
    Senet3: TMenuItem;
    CekTahsilMenu: TMenuItem;
    POS1: TMenuItem;
    HavaleEFT3: TMenuItem;
    Nakit3: TMenuItem;
    adeeki1: TMenuItem;
    IadeCekiOdemeMenu2: TMenuItem;
    Iadeceki2: TMenuItem;
    Hediyeceki1: TMenuItem;
    Kupon1: TMenuItem;
    HediyeCeki2: TMenuItem;
    Kupon2: TMenuItem;
    N6: TMenuItem;
    Kopyala1: TMenuItem;
    KasaGridSUBEID: TcxGridDBColumn;
    YaziciYaz: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    frxKASA: TfrxDBDataset;
    ToolButton2: TToolButton;
    CbGroupAcKapa: TcxCheckBox;
    Masrafdeme1: TMenuItem;
    N7: TMenuItem;
    MasrafNakitMenu: TMenuItem;
    MasrafHavaleEFTMenu: TMenuItem;
    MasrafKrediKartiMenu: TMenuItem;
    KasaGridOZELKOD: TcxGridDBColumn;
    GelirTahsilat1: TMenuItem;
    Nakit4: TMenuItem;
    HavaleEFT4: TMenuItem;
    cxSplitter1: TcxSplitter;
    procedure FormCreate(Sender :TObject);
    procedure Calendar1Change(Sender :TObject);
    procedure FormActivate(Sender :TObject);
    procedure KasaGridMouseUp(Sender :TObject; Button :TMouseButton;
      Shift :TShiftState; X, Y :Integer);
    procedure KasaGridCARIKODPropertiesButtonClick(Sender :TObject;
      AButtonIndex :Integer);
    procedure KasaGridCARIADPropertiesButtonClick(Sender :TObject;
      AButtonIndex :Integer);
    procedure KasaGridMASRAFKODPropertiesButtonClick(Sender :TObject;
      AButtonIndex :Integer);
    procedure KasaGridStylesGetContentStyle(Sender :TcxCustomGridTableView;
      ARecord :TcxCustomGridRecord; AItem :TcxCustomGridTableItem;
      var AStyle :TcxStyle);
    procedure CheckFatClick(Sender :TObject);
    procedure CheckKasaClick(Sender :TObject);
    procedure CheckBankaClick(Sender: TObject);
    procedure CheckPlanClick(Sender: TObject);
    procedure CheckCekSenetClick(Sender: TObject);
    procedure Button1Click(Sender :TObject);
    procedure Button2Click(Sender :TObject);
    procedure GridToplamDblClick(Sender: TObject);
    procedure KASAAfterOpen(DataSet: TDataSet);
    procedure SilTusClick(Sender: TObject);
    procedure GorTusClick(Sender: TObject);
    procedure BtnToplamClick(Sender: TObject);
    procedure VarliklarTusClick(Sender: TObject);
    procedure TabToplamAfterOpen(DataSet: TDataSet);
    procedure YeniTusClick(Sender: TObject);
    procedure Fatura1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure NakitOdemeMenu2Click(Sender: TObject);
    procedure KasaGridCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridToplamDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridToplamDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure Kopyala1Click(Sender: TObject);
    procedure CbGroupAcKapaClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure KasaGridBAKIYEGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
    procedure KasaGridBAKIYEGetDataText(Sender: TcxCustomGridTableItem; ARecordIndex: Integer; var AText: string);
    procedure MasrafNakitMenuClick(Sender: TObject);
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
    procedure CariAdRehberKaydaErisildi(Sender: TObject);
    procedure KasaMasrafRehberKaydaErisildi(Sender: TObject);
    procedure SetArama(const Value: TGunlukAksiyonAramaFrame);
    procedure EkstreKapatEylemi(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl : string;
  public
    { public declarations }
    ParaSource :TDataSource;
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  published
    property Arama : TGunlukAksiyonAramaFrame read FArama write SetArama;
  end;

var
  Miktar, KasaEkAlanlar,KasaEkAlanlar2 :string;
  
implementation

uses
  UAnaForm, UMesaj, UCombo,UFastRap,URaporAraclari,UGenelAnaSekmeFrame,
  URehAraDlg, UGrid, UQuantGrid, FetaUtil, UListe, UListeCheck,
  UVadesiGelmisler, UCekSenetArama, Math, DateUtils, UCxUtils,    //UCekListe
  UKasaWizard, FetaKurulusSiniflari, FetaClassExtensions,PrjConst,
  FetaClassExtensionsConsts,UMakbuzWizard, UNakitDlg,LocOnFly, System.JSON;

{$R *.DFM}
var
  YeniEklenenKayit, Sor, CheckCariKod, CheckAciklama, CheckHesapKod, CheckMiktar, CheckMasrafKod :boolean;
  CheckMasrafAd, checkVadeSor, CheckTahakkukMasrafAd :Boolean;

  GelenMasrafSor, vbBasIndex, vbAyracIndex, vbBitIndex, vbMaxKasaNo, vbKasaSirano, vbGeriDonusId, KasaEkleGun :integer;
  vbTahTarih, vbSirano, vade, SeriNo:string;
  KasaBasZamani, KasaBitZamani :string[20];

procedure TKasaDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxKASA) then begin
      AFastReport.EnabledDataSets.Clear;
      AFastReport.EnabledDataSets.Add(frxKASA);
   end else begin
      frxKASA.Dataset := KASA;
      AFastReport.EnabledDataSets.Clear;
      AFastReport.EnabledDataSets.Add(frxKASA);
   end;
end;

function TKasaDlg.EkranAdiAl: string;
begin
   //Result := 'MakbuzWizardDlg';
    Result := 'KasaDlg';
end;

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
  ra:string;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  PopupMenuYaz.Images := aktifFrame.ImageList1;

  //KasaGrid.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasaGrid', true, false, [gsoUseFilter], 'KasaGrid');
  Tablo.GridAyarRestore('KasaGrid', KasaGrid);

  cxUtils.SetcxGridPopupMenu(cxGrid1, nil, true);

  Sor := True;
  KasaBasZamani :=  Tablo.inidenAnahtarGetir(IntToStr(Ops_KasaBasZamani),'0');
  if KasaBasZamani='' then KasaBasZamani := '00:00:00';
  KasaBitZamani :=  Tablo.inidenAnahtarGetir(IntToStr(Ops_KasaBitZamani),'0');
  if KasaBitZamani='' then KasaBitZamani := '23:59';
  KasaEkleGun :=  StrToIntDef(Tablo.inidenAnahtarGetir(IntToStr(Ops_KasaEkleGun),'0'),0);
  FArama.Calendar1.Date := Tablo.GENINI.BugunTrh;
  FArama.Calendar2.Date := FArama.Calendar1.Date;
end;

procedure TKasaDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKasaDlg.YeniTusClick(Sender: TObject);
var Sonuc,KasaId : Integer;
    HesapTuru : char;
    SonucListe : TStringList;
    Tarih:TDateTime;
begin
//   Tarih:= StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', FArama.Calendar1.Date)+
//                  FormatDateTime(' hh:nn:ss', Tablo.GENINI.BugunTrhSaat));
   Tarih:= Tablo.GENINI.BugunTrhSaat;
   Sonuc := Tablo.KasaSihirbazBaslat('E', -1,-1, 0, -1, Tarih,Tablo.GENINI.BugunTrhSaat,0,0,'','');
  case Sonuc of
    9,19: Tablo.SiparisSihirbazBaslat('E', Sonuc,-1, -1, -99);
    10,11,12,14,15,16 : Tablo.FaturaSihirbazBaslat('E', Sonuc,-1,-1,0);
    13,17 : Tablo.TahakkukSihirbaziBaslat('E', Sonuc, 1, -1, -1, Tarih);
    20..39: Tablo.MakbuzSihirbazBaslat('E', Sonuc,1, -1, -1, Tarih, '');
    113,117 : begin //Önce kasa eçimi yapıp sonratahakkuk ekranını çağıralım
       SonucListe := TStringList.Create;
       if Tablo.ListedenBilgiGetir('Kasa Seçimi','select ID, KASAKODU, KASAADI, KUR FROM KASALAR where DURUM=1 and (KASAKODU like ''%<ara>%'' or KASAADI like ''%<ara>%'')',SonucListe,[nil, nil, nil])then
          KasaId := StrToIntDef(SonucListe[0],0)
       else
          KasaId := 0;
       SonucListe.Free;
       if KasaId>0 then
          Tablo.TahakkukSihirbaziBaslat('E', Sonuc-100, 3, KasaId, -1*KasaId, Tarih);
     end;
    121,131,122,132,135 : begin
       // masrafta cari seçilmez yani rehberid sıfırdır
       if Sonuc in [121,131] then HesapTuru := 'K'
       else if Sonuc in [135] then HesapTuru := 'V'
       else HesapTuru := 'B';
       Dec(Sonuc,100);
       Tablo.NakitSihirbazBaslat(HesapTuru,'E', Sonuc,1, -1, 0, Tarih, '-1');
    end;
  end;
  Calendar1Change(Self);
end;

procedure TKasaDlg.KasaMasrafRehberKaydaErisildi(Sender: TObject);
begin
  if TRehberAraDlg(Sender).REHBER.RecordCount > 0 then
  begin
    with Veritabani.SorguBaslat(Tablo.FDCnn,'SELECT KOD,FIRMA FROM REHBER ID = $1',['$1'],[TRehberAraDlg(Sender).REHBER.AsInteger[0]]) do
    try
      KASA.Edit;
      KasaGridMASRAFKOD.DataBinding.Field.AsString := AsString[0];
      KasaGridMASRAFKOD.DataBinding.Field.AsString := AsString[1];
    finally
      Free;
    end;
  end;
end;

procedure TKasaDlg.Kopyala1Click(Sender: TObject);
var FaturaIDsi : integer;
begin
  FaturaIDsi := Tablo.BelgeKopyala(KASA.FieldByName('ID').AsInteger, KASA.FieldByName('TUR').AsInteger,
                 KASA.FieldByName('REHBERID').AsInteger, KASA.FieldByName('AKSIYONTARIH').AsDateTime);

  case KASA.FieldByName('TUR').AsInteger of
    13,17:begin
      Tablo.TahakkukSihirbaziBaslat('K',KASA.FieldByName('TUR').AsInteger,1, FaturaIDsi,KASA.FieldByName('REHBERID').AsInteger,-1);
    end;
    10,14,11,15,12,16:begin
      Tablo.FaturaSihirbazBaslat('K', KASA.FieldByName('TUR').AsInteger, 0, FaturaIDsi, KASA.FieldByName('REHBERID').AsInteger, 1,False,-1);
    end;
    9,19:begin
      Tablo.SiparisSihirbazBaslat('K', KASA.FieldByName('TUR').AsInteger, 0, FaturaIDsi, KASA.FieldByName('REHBERID').AsInteger, -1);
    end;
  end;
  Calendar1Change(Self);

  {if KASA.FieldByName('TUR').AsInteger = 11 then
    Tablo.FaturaSihirbazBaslat('K', 11 ,0,FaturaIDsi, KASA.FieldByName('REHBERID').AsInteger, 1,False,-1)
  else if KASA.FieldByName('TUR').AsInteger = 15 then
    Tablo.FaturaSihirbazBaslat('K', 15 ,0,FaturaIDsi, KASA.FieldByName('REHBERID').AsInteger,1,False, -1)
  else begin
    ShowMessage(KAlisSatis_belgesi_kopyala);
    Abort;
  end;
    Calendar1Change(Self);}

end;

procedure TKasaDlg.MasrafNakitMenuClick(Sender: TObject);
var HesapTuru : char;
begin
   // masrafta cari seçilmez yani rehberid sıfırdır
   case TMenuItem(Sender).Tag of
     21,31 : HesapTuru := 'K';
     22,32 : HesapTuru := 'B';
     25,35 : HesapTuru := 'V';
   end;

   Tablo.NakitSihirbazBaslat(HesapTuru,'E', TMenuItem(Sender).Tag,1, -1, 0, Tablo.GENINI.BugunTrhSaat, '-1');
   Calendar1Change(Self);
end;

procedure TKasaDlg.NakitOdemeMenu2Click(Sender: TObject);
var Tur, Tipi : SmallInt;
    HesapTuru : Char;
    Tutar : Currency;
    MasrafID : Integer;
begin
   Tablo.TablodanSorguAc(1,'Select isnull(ID,-1) from MASRAFGELIR where KOD='''+KASA.FieldByName('MASRAFKOD').AsString+'''');
   MasrafID := StrToIntDef(Tablo.Query1.Fields[0].AsString,-1);
   Tur := TMenuItem(Sender).Tag;
   case Tur of
       21,31 : HesapTuru := 'K';
       22,32 : HesapTuru := 'B';
       25 : HesapTuru := 'P';
       35 : HesapTuru := 'V';
       26,28,29,36,38,39 :  HesapTuru := 'H';
       else    HesapTuru := '-';
   end;
   if Tur in [21..29] then
      Tutar := KASA.FieldByName('BORC').AsCurrency
   else
      Tutar := KASA.FieldByName('ALACAK').AsCurrency;
   case Tur of
     10,11,12,14,15,16 :Tablo.FaturaSihirbazBaslat('E', Tur,-1, -1,0);
     9,19: Tablo.SiparisSihirbazBaslat('E', Tur,-1, -1, -99);
     13,17: Tablo.TahakkukSihirbaziBaslat('E',Tur,0,1,-99, Tablo.GENINI.BugunTrhSaat);
     21,22,25,26,28,29,31,32,35,36,38,39 : begin//ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,0, -1, RehberId, Tablo.GENINI.BugunTrhSaat, '-1');
       Application.CreateForm(TNakitDlg, NakitDlg);
       NakitDlg.ID := -1;
       NakitDlg.Tur := Tur;
       NakitDlg.HesapTuru := HesapTuru;
       NakitDlg.IslemOp := 'E';
       NakitDlg.RehberId := KASA.FieldByName('REHBERID').AsInteger;

       NakitDlg.LabelTarih.Visible := True; // menüden kısayol olduğu için tarih girilebilir
       NakitDlg.EditTarih.Visible := True;



       if Tur=39 then
        begin
         NakitDlg.MakbuzTarih := KASA.FieldByName('KAYITTARIH').AsDateTime;
         NakitDlg.MakbuzNo:= SiradakiBelgeNumarasi(Tur,NakitDlg.MakbuzTarih).BelgeNo;
        end
       else
        begin
          NakitDlg.MakbuzNo := SiradakiMakbuzNumarasi(Tur);
          NakitDlg.MakbuzTarih := Tablo.GENINI.BugunTrhSaat;
        end;

       if KASA.FieldByName('FATURAID').AsInteger>0 then begin
          NakitDlg.KasaFatBasId:= KASA.FieldByName('FATURAID').AsInteger;
          NakitDlg.Aciklama := KASA.FieldByName('BELGENO').AsString + ' nolu satış tahsilatı';
       end
       else
          NakitDlg.Aciklama := KASA.FieldByName('ACIKLAMA').AsString;
       NakitDlg.Tutar := Tutar;
       NakitDlg.Kur := KASA.FieldByName('KUR').AsString;
       if KASA.FieldByName('YERI').AsInteger>0 then
         begin
             NakitDlg.KasaYer:= KASA.FieldByName('YERI').AsInteger;
             NakitDlg.KasaYer_id:= KASA.FieldByName('YERID').AsString;
         end;

       NakitDlg.showmodal;

       if NakitDlg.ModalResult = mrOk  then
          Calendar1Change(Self);
       NakitDlg.Destroy;
     end;
     Sbt_Cek_Gelen,Sbt_Cek_Giden,Sbt_Senet_Gelen,Sbt_Senet_Giden : begin
                  if Tur in [Sbt_Cek_Gelen, Sbt_Senet_Gelen]  then Tipi:=130
                  else Tipi:=140;
                  if Tablo.CekSihirbazBaslat('E',Tipi,Tur,0,-1,KASA.FieldByName('REHBERID').AsInteger,MasrafID, Tablo.GENINI.BugunTrhSaat,'',False,Tutar,KASA.FieldByName('ACIKLAMA').AsString) > 0 then
                     Calendar1Change(Self);
               end;
   end;
end;

procedure TKasaDlg.PopupMenu1Popup(Sender: TObject);
begin
   SilMenu.Visible := KASA.RecordCount > 0;
   GorMenu.Visible := SilMenu.Visible;
   EkstreMenu.Visible := SilMenu.Visible;
   TahsilMenu2.Visible := (SilMenu.Visible)and((KASA.FieldByName('TUR').AsInteger in [15..19])or(KASA.FieldByName('TUR').AsInteger = 61));
   OdemeMenu2.Visible := (SilMenu.Visible)and((KASA.FieldByName('TUR').AsInteger in [8,10..14])or(KASA.FieldByName('TUR').AsInteger = 11));
end;

procedure TKasaDlg.CariAdRehberKaydaErisildi(Sender: TObject);
begin
  if TRehberAraDlg(Sender).REHBER.RecordCount > 0 then
  begin
    with Veritabani.SorguBaslat(Tablo.FDCnn,'SELECT KOD,FIRMA FROM REHBER ID = $1',
      ['$1'],[TRehberAraDlg(Sender).REHBER.AsInteger[0]]) do
    try
      KASA.Edit;
      KasaGridCARIKOD.DataBinding.Field.AsString := AsString[0];
      KasaGridCARIAD.DataBinding.Field.AsString := AsString[1];
    finally
      Free;
    end;
  end;
end;



destructor TKasaDlg.Destroy;
begin
  inherited;
end;

procedure TKasaDlg.KASAAfterOpen(DataSet: TDataSet);
begin
  SilTus.Visible := KASA.RecordCount>0;
  GorTus.Visible := SilTus.Visible;
  TCurrencyField(KASA.FieldByName('BORC')).DisplayFormat := '###,###,###,##0.00';
  TCurrencyField(KASA.FieldByName('ALACAK')).DisplayFormat := '###,###,###,##0.00';
end;

procedure TKasaDlg.TabToplamAfterOpen(DataSet: TDataSet);
begin
 // TCurrencyField(Toplam.FieldByName('DEVIR')).DisplayFormat := '###,###,###,##0.00';
 // TCurrencyField(Toplam.FieldByName('BORC')).DisplayFormat := '###,###,###,##0.00';
 // TCurrencyField(Toplam.FieldByName('ALACAK')).DisplayFormat := '###,###,###,##0.00';
  //TCurrencyField(Toplam.FieldByName('KALAN')).DisplayFormat := '###,###,###,##0.00';
end;

procedure TKasaDlg.VarliklarTusClick(Sender: TObject);
begin
  if PanelToplam.Visible then begin
     TabToplam.Close;
     PanelToplam.Visible := False;
     PanelToplam.Height := 1;
     Calendar1Change(Self);
  end else  begin
     PanelToplam.Visible := True;
     TabToplam.Params[0].Value := FormatDateTime('YYYY-MM-DD 00:00', FArama.Calendar1.Date);
     TabToplam.Params[1].Value := FormatDateTime('YYYY-MM-DD 23:59', FArama.Calendar1.Date);
     TabToplam.Open;
     PanelToplam.Height := 24 + TabToplam.RecordCount * 20;
     if PanelToplam.Height > 240 then
        PanelToplam.Height := 200;
     VarliklarTus.Tag := 1;
  end;
end;

procedure TKasaDlg.Calendar1Change(Sender :TObject);
var
  j : TJSONObject;
  subeId : Integer;
begin
//  if not Tablo.TabRehber.Active then exit;
  FArama.CheckTop.Checked := False;
  PanelToplam.Visible := False;

  if FArama.Calendar1.Date<StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2000') then exit;
  if FArama.Calendar2.Date<StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2000') then exit;

  // Cok-kaynakli KASA sorgusu artik sunucu-tarafi SP'de kuruluyor (sp_Prog_Kasa_Hareket_Json2).
  // Eski dinamik SQL ile BIREBIR ayni UNION ALL sonucu; filtreler JSON ile gecirilir.
  j := TJSONObject.Create;
  j.AddPair('Cal1', FormatDateTime('yyyy-mm-dd', FArama.Calendar1.Date));
  j.AddPair('Cal2', FormatDateTime('yyyy-mm-dd', FArama.Calendar2.Date));
  j.AddPair('BasZaman', string(KasaBasZamani));
  j.AddPair('BitZaman', string(KasaBitZamani));
  j.AddPair('EkleGun', TJSONNumber.Create(KasaEkleGun));
  j.AddPair('CheckKasa', TJSONNumber.Create(Ord(FArama.CheckKasa.Checked)));
  j.AddPair('CheckPlan', TJSONNumber.Create(Ord(FArama.CheckPlan.Checked)));
  j.AddPair('CheckFat', TJSONNumber.Create(Ord(FArama.CheckFat.Checked)));
  j.AddPair('CheckCekSenet', TJSONNumber.Create(Ord(FArama.CheckCekSenet.Checked)));
  if SubeVarmi then begin
    if FArama.ComboSube.EditValue = 0 then begin
      // ComboSube=0 -> yetkili sube listeleri (kasa+fatura: modul 24, cek+senet: modul 25)
      j.AddPair('SubeKasaList', Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme));
      j.AddPair('SubeCekList', Tablo.YetkiliSubeleriGetir(25,YetkiTur_Gorme));
    end else begin
      subeId := FArama.ComboSube.EditValue;
      j.AddPair('SubeId', TJSONNumber.Create(subeId));
    end;
  end;

  Tablo.ListeSPJson(KASA, 'sp_Prog_Kasa_Hareket_Json2', '', j, 0); // j sahipligi devralinir

  if GenRegIni.RegReadString('GrupAcKapa', 'KasaDlg' , '0', 'C')='1' then begin
    CbGroupAcKapa.Checked:=True;
    KasaGrid.DataController.Groups.FullExpand;
  end else begin
    CbGroupAcKapa.Checked:=False;
    KasaGrid.DataController.Groups.FullCollapse;
  end;

  frxKASA.DataSet:=KASA;


end;

procedure TKasaDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasaDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasaDlg.Fatura1Click(Sender: TObject);
var Tur, ID ,RehID, Tipi: Integer;
    HesapTuru : Char;
    DateSaat:TDateTime;
begin
   Tur := TMenuItem(Sender).Tag;
   case Tur of
     21,31 : HesapTuru := 'K';
     22,32 : HesapTuru := 'B';
     25 : HesapTuru :='P';
     35 : HesapTuru :='V';
     39 : HesapTuru :='H';
   else
     HesapTuru := '-';
   end;
   case Tur of
     9,19: ID := Tablo.SiparisSihirbazBaslat('E', Tur,-1, -1, -1);
     10,11,12,14,15,16 : ID := Tablo.FaturaSihirbazBaslat('E', Tur,-1, -1,0);
     Sbt_Cek_Gelen,Sbt_Cek_Giden,Sbt_Senet_Gelen,Sbt_Senet_Giden : begin
     {        if pos('Cek', TMenuItem(Sender).Name)=1 then Tipi:=1
             else Tipi:=2;
             ID := Tablo.CekSihirbazBaslat('E', Tur, Tipi,0, -1, -99,-99, Tablo.GENINI.BugunTrhSaat, '');
           end;
     140 :begin}
             if Tur in [Sbt_Cek_Gelen, Sbt_Senet_Gelen]  then Tipi:=130
                  else Tipi:=140;
           {  Tablo.TablodanSorguAc(1,'Select * from CEKLER Where CEKSENET='+IntToStr(Sbt_Cek_Gelen)+' and DURUM=1 and isnull(CIROLU,0) <> 1 ');
             if Tablo.Query1.RecordCount > 0 then begin
                DateSaat:=StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', Tablo.GENINI.BugunTrhSaat));
                RehId := Tablo.RehberAra_IDGetir(-99);
                if RehId < 0 then Exit;
                   Tablo.CiroEdileceklerBaslat('K', Tur, Tipi,0,-1, RehId,-1,DateSaat,'');
             end else  }
                ID := Tablo.CekSihirbazBaslat('E', Tipi, Tur, 0, -1, -99,-99, Tablo.GENINI.BugunTrhSaat, '');
           end;

     13,17: Tablo.TahakkukSihirbaziBaslat('E',Tur,0,-1,-1,Tablo.GENINI.BugunTrhSaat);
     21,22,25,31,32,35,39 : ID := Tablo.NakitSihirbazBaslat(HesapTuru,'E', Tur,1, -1, -1, Tablo.GENINI.BugunTrhSaat, '-1');
     61,65,71,72,75 : begin DateSaat := Tablo.GENINI.BugunTrhSaat;
                            ID := Tablo.KasaSihirbazBaslat('E', -1,Tur, 0, -99, DateSaat,Tablo.GENINI.BugunTrhSaat,0,0,'','');
                      end;
   end;
   if ID > 0 then
      Calendar1Change(Self);
end;
procedure TKasaDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TKasaDlg.FormActivate(Sender :TObject);
begin
  Calendar1Change(Self);

end;

procedure TKasaDlg.CheckBankaClick(Sender: TObject);
begin
  Tablo.GENINI.WriteBoolean(Ops_KasaEkran_Banka,FArama.CheckBanka.Checked);       // KasaEkran', 'Banka'
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckCekSenetClick(Sender: TObject);
begin
  Tablo.GENINI.WriteBoolean(Ops_KasaEkran_CekveSenet,FArama.CheckCekSenet.Checked);       // KasaEkran', 'ÇekveSenet'
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckFatClick(Sender :TObject);
begin
  Tablo.GENINI.WriteBoolean(Ops_KasaEkran_Tahakkuk,FArama.CheckFat.Checked);       // KasaEkran', 'Tahakkuk'
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckKasaClick(Sender :TObject);
begin
  Tablo.GENINI.WriteBoolean(Ops_KasaEkran_Kasa,FArama.CheckKasa.Checked);       // KasaEkran', 'Kasa'
  Calendar1Change(Self);
end;

procedure TKasaDlg.CheckPlanClick(Sender: TObject);
begin
  Tablo.GENINI.WriteBoolean(Ops_KasaEkran_Plan,FArama.CheckPlan.Checked);       // KasaEkran', 'Plan'
  Calendar1Change(Self);
end;

procedure TKasaDlg.KasaGridMouseUp(Sender :TObject; Button :TMouseButton; Shift :TShiftState; X, Y :Integer);
begin
  if Assigned(QuantKasa) then
    QuantKasa.dxDBGridMouseUp(Sender, Button, Shift, X, Y, PopupMenu1);
end;

procedure TKasaDlg.EkstreKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
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
    case KASA.FieldByName('TUR').AsInteger of
       10,11,12,13,14,15,16,17,21,22,24,25,31,32,34,35,110,125,130,140:begin
         if KASA.FieldByName('TUR').AsInteger in [11,15] then begin
           if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+KASA.FieldByName('ID').AsString+' ',[],[]) then begin
             if  Application.MessageBox(PChar(KPlanli_fatura_silinsinmi),PChar(Uyari),MB_YESNO)=mrNo then begin
               Abort;
             end;
           end;
         end;

       end;
    end;
   // kasa eksiği veya fazlası fişi ise bu ekrandan müdahale edilmesin
  if (KASA.FieldByName('TUR').AsInteger= 27) or (KASA.FieldByName('TUR').AsInteger= 37) then
    begin
      Application.MessageBox(PChar(KBu_ekrandan_silinemez_Hizli_Satistan),PChar(Uyari),MB_OK+MB_ICONWARNING);
      Abort;
    end;
   if Application.MessageBox(PChar(KAksiyon_silinsinmi),PChar(Onay), MB_YESNO) = IDYES then begin
      Tablo.KasaSilmeIslemleri(KASA.FieldByName('ID').AsInteger, KASA.FieldByName('TUR').AsInteger);
      Calendar1Change(Self);
      /// SQL2005 TE hataya neden olduğu için delete olayını kendimiz yapıyoruz
      Abort;
   end;
end;
procedure TKasaDlg.KasaGridCARIKODPropertiesButtonClick(Sender :TObject;
  AButtonIndex :Integer);
begin
  TRehberAraDlg(FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TRehberAraDlg).Git.Ornek).KayitErisimTamamlandi :=
    CariAdRehberKaydaErisildi;
end;

procedure TKasaDlg.KasaGridBAKIYEGetDataText(Sender: TcxCustomGridTableItem; ARecordIndex: Integer; var AText: string);
begin
  //Sender.GridView.DataController.SetValue(ARecordIndex,KasaGridBAKIYE.Index,Sender.GridView.DataController.GetValue(ARecordIndex,KasaGridBORC.Index) - Sender.GridView.DataController.GetValue(ARecordIndex,KasaGridALACAK.Index));

end;

procedure TKasaDlg.KasaGridBAKIYEGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
begin

  //Sender.GridView.DataController.SetValue(ARecord.RecordIndex,ARecord.Index,Sender.GridView.DataController.GetValue(ARecord.RecordIndex,KasaGridBORC.Index) - Sender.GridView.DataController.GetValue(ARecord.RecordIndex,KasaGridALACAK.Index));
 // AText := FormatFloat('########0,00',);

end;

procedure TKasaDlg.KasaGridCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=cxGrid1;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=KasaGrid;
AnaForm.pmGridStil.Tags.Values[cxGrid1.Name]:= 'KasalarGridi';
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
  AItem :TcxCustomGridTableItem; var AStyle :TcxStyle);
var
  AColumn :TcxCustomGridTableItem;
begin
Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
  AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('ID');
  if AColumn <> nil then
    if VarToStr(ARecord.Values[AColumn.Index]) = '0' then
    begin
      AStyle := tablo.cxstSecili;
    end

end;

procedure TKasaDlg.CbGroupAcKapaClick(Sender: TObject);
var
Deger:integer;
begin
  if CbGroupAcKapa.Checked then begin
    Deger:=1;
    KasaGrid.DataController.Groups.FullExpand;
  end else begin
    Deger:=0;
    KasaGrid.DataController.Groups.FullCollapse;
  end;
  GenRegIni.RegWriteString('GrupAcKapa','KasaDlg',IntToStr(Deger),'C');

end;

procedure TKasaDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKasaDlg.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  FormCreate(nil);
  KasaGridSUBEID.Visible := SubeVarmi;
  //KasaGrid.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasalarGridi',true,false,[gsoUseFilter],'KasalarGridi');
  Tablo.GridAyarRestore('KasalarGridi', KasaGrid);

  //GridToplamDBTableView1.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasalarToplamGridi',true,false,[gsoUseFilter],'KasalarToplamGridi');
  Tablo.GridAyarRestore('KasalarToplamGridi',GridToplamDBTableView1 );

  Tablo.GridTurkcelestir;

  GelenBelge1.Visible := Tablo.YetkiVarmi(2401,YetkiTur_Gorme);
  Satbelgesi1.Visible := Tablo.YetkiVarmi(2411,YetkiTur_Gorme);
  if GelenBelge1.Visible then begin //2401 detayları
     Fatura1.Visible := Tablo.YetkiVarmi(240131,YetkiTur_Gorme);
     Fi1.Visible := Tablo.YetkiVarmi(240141,YetkiTur_Gorme);
     rsaliye1.Visible := Tablo.YetkiVarmi(240121,YetkiTur_Gorme);
     AlacakTahakkuku.Visible := Tablo.YetkiVarmi(240151,YetkiTur_Gorme);
  end;
  if Satbelgesi1.Visible then begin //2411 detayları
     Fatura2.Visible := Tablo.YetkiVarmi(241131,YetkiTur_Gorme);
     Fi2.Visible := Tablo.YetkiVarmi(241141,YetkiTur_Gorme);
     rsaliye2.Visible := Tablo.YetkiVarmi(241121,YetkiTur_Gorme);
     BorTahakkuku1.Visible := Tablo.YetkiVarmi(241151,YetkiTur_Gorme);
  end;
end;

constructor TKasaDlg.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TKasaDlg.BtnToplamClick(Sender: TObject);
begin
  TabToplam.Close;
  TabToplam.Params[0].Value := FormatDateTime('YYYY-MM-DD 00:00', FArama.Calendar1.Date);
  TabToplam.Params[1].Value := FormatDateTime('YYYY-MM-DD 23:59', FArama.Calendar1.Date+KasaEkleGun);
  TabToplam.Open;
  PanelToplam.Height := 24 + TabToplam.RecordCount * 20;
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
var
  srid:integer;
begin
  if KasaGrid.Controller.SelectedRecordCount > 0 then
  begin

   // kasa eksiği veya fazlası fişi ise bu ekrandan müdahale edilmesin
  if (KASA.FieldByName('TUR').AsInteger= 27) or (KASA.FieldByName('TUR').AsInteger= 37) then
    begin
      Application.MessageBox(PChar(KBu_ekrandan_silinemez_Hizli_Satistan),PChar(Uyari),MB_OK+MB_ICONWARNING);
      Abort;
    end;


   srid:=KasaGrid.DataController.FocusedRecordIndex;
    AnaForm.GormeDialogCagir(KASA.FieldByName('ID').AsInteger, KASA.FieldByName('TUR').AsInteger,
           KASA.FieldByName('REHBERID').AsInteger, 1,KASA.FieldByName('KAYITTARIH').AsDateTime, KASA.FieldByName('BELGENO').AsString);
   Calendar1Change(Self);

   KasaGrid.DataController.FocusedRecordIndex:=srid;
//   KasaGrid.ViewData.Records[srid].Selected := false;

  end;
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
 // ReherIni.ReadImageSection('Kasa Türleri', TcxImageComboBoxProperties(KasaGridTUR.Properties));
end;

procedure TKasaDlg.GorunurOlacak;
begin

end;

procedure TKasaDlg.GridToplamDblClick(Sender: TObject);
begin
{   if (pos('101', TabToplam.FieldByName('HESAPKODU').AsString) > 0) or (pos('103', TabToplam.FieldByName('HESAPKODU').AsString) > 0) then begin
       if CekListeDlg = nil then
          Application.CreateForm(TCekListeDlg,CekListeDlg);
      CekListeDlg.ShowModal;
   end;}
end;

procedure TKasaDlg.GridToplamDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridToplam;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridToplamDBTableView1;
  AnaForm.pmGridStil.Tags.Values[GridToplam.Name]:='KasalarToplamGridi';
end;

procedure TKasaDlg.GridToplamDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

initialization
  Classes.RegisterClass(TKasaDlg);

end.

{
Emre: stoktaki iade çıkış bölümü var firmalara iade faturalarının kesildiği bölüm, bu faturaları da gentegre de görmek istiyor malatya


Emre Baytar is online.
Emre: giriş faturaları firma carisine yansıyor ama iadeler yapılmamış şimdi denedik de  }






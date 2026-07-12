unit UBankaHesapGiris;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Menus, Data.DB, Math,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxClasses, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  cxDBData, cxContainer, cxLabel, cxTextEdit, cxMaskEdit, cxCalendar, cxDropDownEdit,
  cxButtonEdit, cxImageComboBox, cxCheckBox, cxCurrencyEdit, cxButtons,
  cxGridLevel, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxDateUtils,
  dxCore, dxCoreGraphics, dxSkinsCore, dxSkinscxPCPainter, dxSkinLondonLiquidSky,
  dxmdaset,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, dxDateRanges,
  dxScrollbarAnnotations, System.Generics.Collections;

type
  TBankaTipi = (btGenerik, btGaranti, btZiraat, btIsBank, btAkbank, btYapikredi,
                btHalkbank, btVakifbank, btQNB, btING);

  TBankaHareketSatiri = record
    Tarih: TDateTime;
    Aciklama: string;
    Etiket: string;
    Tutar: Currency;
    Bakiye: Currency;
    DekontNo: string;
  end;
  TBankaHareketListesi = TList<TBankaHareketSatiri>;

  // Banka-bazlı parse konfigürasyonu (kolon sıraları, header anahtarları)
  TBankaKonfig = record
    Tipi: TBankaTipi;
    Adi: string;
    BankaKodu: string;          // DB lookup için: 'GARANTI','ZIRAAT',...
    // CSV/XLS kolon indeksleri (1-tabanlı; -1 = yok)
    KolTarih, KolAciklama, KolEtiket, KolTutar, KolBakiye, KolDekontNo: Integer;
    HeaderAnahtar: string;       // Header satırını bulan ipucu (ör. 'Tarih')
    BankaTespitAnahtar: string;  // Dosyada bu metin geçiyorsa banka tespiti yapılır
  end;

  // BANKA_KURAL tablosundan yüklenmiş tek bir kural
  TBankaKural = record
    KuralTipi: Char;       // 'E' Etiket, 'A' Açıklama, 'I' İsim çıkarma
    Pattern: string;
    PatternTipi: Char;     // 'L' LIKE, 'R' Regex
    TurNeg: Integer;       // Tutar negatifse hangi tür (-1 = yok)
    TurPoz: Integer;       // Tutar pozitifse hangi tür (-1 = yok)
    RegexGroup: Integer;
    Confidence: Integer;
  end;
  TBankaKuralListesi = TList<TBankaKural>;

type
  TbankaHesapGirisdlg = class(TForm)
    // Üst düğme şeridi
    PanelUst: TPanel;
    btnHesapSec: TcxButton;
    btnMT940Al: TcxButton;
    lblBanka: TcxLabel;
    lblSube: TcxLabel;
    lblHesap: TcxLabel;
    lblHesapDoviz: TcxLabel;
    // Üst giriş paneli (yeni satır oluşturma)
    PanelGiris: TPanel;
    lbl_Tarih: TcxLabel;
    cxDateEdit1: TcxDateEdit;
    lbl_Tur: TcxLabel;
    cbTur: TcxImageComboBox;
    lbl_Secim: TcxLabel;
    beSecim: TcxButtonEdit;
    lbl_Tutar: TcxLabel;
    ceTutar: TcxCurrencyEdit;
    lbl_Masraf: TcxLabel;
    ceKomisyon: TcxCurrencyEdit;
    lbl_Aciklama: TcxLabel;
    teAciklama: TcxTextEdit;
    lbl_MasrafKalemi: TcxLabel;
    beMasrafKalemi: TcxButtonEdit;
    lbl_BelgeNo: TcxLabel;
    teBelgeNo: TcxTextEdit;
    chkKarsiligi: TcxCheckBox;
    chkEkstrede: TcxCheckBox;
    // Karşılığı sağ alt paneli (chkKarsiligi tıklanınca görünür)
    PanelKarsiligiSag: TPanel;
    lbl_DovizTipi: TcxLabel;
    cbDovizTipi: TcxImageComboBox;
    lbl_Kur: TcxLabel;
    ceKur: TcxCurrencyEdit;
    lbl_DovizTutar: TcxLabel;
    ceDovizTutar: TcxCurrencyEdit;
    // Grid (eklenmiş satırlar)
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    dxMemData1: TdxMemData;
    DataSource1: TDataSource;
    dxMemData1TARIH: TDateTimeField;
    dxMemData1TURID: TSmallintField;
    dxMemData1TUR: TStringField;
    dxMemData1SECIMID: TIntegerField;
    dxMemData1SECIM: TStringField;
    dxMemData1TUTAR: TCurrencyField;
    dxMemData1PBIRIMI: TStringField;
    dxMemData1KOMISYON: TCurrencyField;
    dxMemData1ACIKLAMA: TStringField;
    dxMemData1BELGENO: TStringField;
    dxMemData1IBAN: TStringField;
    dxMemData1HAMAD: TStringField;
    dxMemData1ICERIALINDI: TBooleanField;
    dxMemData1KARSILIGI: TBooleanField;
    dxMemData1DOVIZ_TUTARI: TCurrencyField;
    dxMemData1DOVIZ_TIPI: TStringField;
    dxMemData1KUR: TCurrencyField;
    dxMemData1EKSTREDE_KULLAN: TBooleanField;
    dxMemData1MASRAFID: TIntegerField;
    dxMemData1MASRAFKALEMI: TStringField;
    cxGrid1DBTableView1TARIH: TcxGridDBColumn;
    cxGrid1DBTableView1TURID: TcxGridDBColumn;
    cxGrid1DBTableView1TUR: TcxGridDBColumn;
    cxGrid1DBTableView1SECIMID: TcxGridDBColumn;
    cxGrid1DBTableView1SECIM: TcxGridDBColumn;
    cxGrid1DBTableView1TUTAR: TcxGridDBColumn;
    cxGrid1DBTableView1PBIRIMI: TcxGridDBColumn;
    cxGrid1DBTableView1KOMISYON: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGrid1DBTableView1BELGENO: TcxGridDBColumn;
    cxGrid1DBTableView1KARSILIGI: TcxGridDBColumn;
    cxGrid1DBTableView1DOVIZ_TUTARI: TcxGridDBColumn;
    cxGrid1DBTableView1DOVIZ_TIPI: TcxGridDBColumn;
    cxGrid1DBTableView1KUR: TcxGridDBColumn;
    cxGrid1DBTableView1EKSTREDE_KULLAN: TcxGridDBColumn;
    cxGrid1DBTableView1MASRAFID: TcxGridDBColumn;
    cxGrid1DBTableView1MASRAFKALEMI: TcxGridDBColumn;
    // Alt düğme şeridi
    PanelAlt: TPanel;
    btnF5Kaydet: TcxButton;
    btnF8Devam: TcxButton;
    // Grid sağ tık menüsü
    PopupMenu1: TPopupMenu;
    miSatirSil: TMenuItem;
    miBenzerlerineUygula: TMenuItem;
    // Excel/CSV içeri alma
    Od1: TOpenDialog;
    cxStyleRepository1: TcxStyleRepository;
    StyleYesil: TcxStyle;
    StyleSari: TcxStyle;
    StyleKirmizi: TcxStyle;
    dxMemData1CONFIDENCE: TIntegerField;
    cxGrid1DBTableView1CONFIDENCE: TcxGridDBColumn;
    dxMemData1ONAY: TBooleanField;
    cxGrid1DBTableView1ONAY: TcxGridDBColumn;
    dxMemData1KREDIDETAYID: TIntegerField;
    ButtonExcelAl: TcxButton;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure btnHesapSecClick(Sender: TObject);
    procedure cbTurPropertiesChange(Sender: TObject);
    procedure beSecimPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure beMasrafKalemiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure chkKarsiligiClick(Sender: TObject);
    procedure cbDovizTipiPropertiesChange(Sender: TObject);
    procedure ceTutarPropertiesChange(Sender: TObject);
    procedure ceKurPropertiesChange(Sender: TObject);
    procedure btnF5KaydetClick(Sender: TObject);
    procedure btnF8DevamClick(Sender: TObject);
    procedure miSatirSilClick(Sender: TObject);
    procedure cxGrid1DBTableView1FocusedRecordChanged(
      Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure cxGrid1DBTableView1CellClick(
      Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure cxGrid1DBTableView1StylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure cxGrid1DBTableView1SECIMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxGrid1DBTableView1TURIDPropertiesChange(Sender: TObject);
    procedure cxGrid1DBTableView1Editing(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; var AAllow: Boolean);
    procedure miBenzerlerineUygulaClick(Sender: TObject);
    procedure btnMT940AlClick(Sender: TObject);
    procedure ButtonExcelAlClick(Sender: TObject);
  private
    FHESAPID: Integer;
    FBankaAdi, FSubeAdi, FHESAPKODU, FHESAPNO, FBankaDovizi, FHesapAdi: string;
    FSECIMID: Integer;
    FMasrafKalemiID: Integer; // Gelen/Giden Havale için MASRAFID seçimi (KASA.MASRAFID)
    FKrediDetayID: Integer;   // Üst panel kredi seçimi → PLANKREDI.ID (UKasaWizard DETAYID)
    FKrediBelgeNo: string;    // Üst panel kredi seçimi → KASA.BELGENO
    FOtoHesapla: Boolean;     // recursive change-event guard
    FDuzenlemeKipinde: Boolean;
    FSatirEkleniyor: Boolean; // SatirEkle çalışırken grid focus event'ini blokla
    // Banka kural önbelleği — anahtar formatı "BANKA_KODU:KURAL_TIPI" (ör. "GARANTI:E")
    FKuralCache: TObjectDictionary<string, TBankaKuralListesi>;
    FYuklenenBankalar: TStringList;   // İki kere yüklenip duplicate Add'ı engelle
    FMT940Dosyalar: TStringList;      // MT940: aynı dosya (tam yol) ikinci kez yüklenmesin
    FKayitIDleri: TList<Integer>;     // bu oturumda KASA'ya yazılan satırlar → FormClose'da EKLEME logu
    FBankaTipi: TBankaTipi;           // Aktif içeri al akışında kullanılan banka tipi
    function KayitIzle(AId: Integer): Integer;
    procedure IbanCariyeYaz(ARehId: Integer);
    function TurAdiGetir(ATur: Integer): string;
    procedure SatiriUstePanele;
    procedure HesapBilgiGoster;
    procedure TurListesiniDoldur;
    procedure TurDegistiUygula;
    procedure SecimEkraniAc;
    procedure MasrafKalemiEkraniAc;
    function BankaHesapSecModal(const DovizKodu: string; HaricID: Integer;
                                out hId: Integer;
                                out BankaAdi, SubeAdi, HesapNo, HesapKodu, Doviz, HesapAdi: string): Boolean;
    function BankaDovizHesapSecModal(const HaricDoviz: string; HaricID: Integer;
                                     out hId: Integer;
                                     out BankaAdi, SubeAdi, HesapNo, HesapKodu, Doviz, HesapAdi: string): Boolean;
    function BankaArbitrajHesapSecModal(const HaricDoviz: string; HaricID: Integer;
                                        out hId: Integer;
                                        out BankaAdi, SubeAdi, HesapNo, HesapKodu, Doviz, HesapAdi: string): Boolean;
    function PosSecModal(out PosID: Integer;
                         out PosAdi, BankaHesapAdi: string): Boolean;
    procedure DovizKuruYukle;
    procedure HesaplaDovizTutar;
    procedure DovizTipiniDoldur;
    procedure BelgeNoOtomatikDoldur;
    procedure AciklamaOtomatikDoldur(Tur: Integer);
    procedure KarsiligiPaneliGoster(Goster: Boolean);
    procedure MasrafPaneliGoster(Goster: Boolean);
    procedure MasrafKalemiPaneliGoster(Goster: Boolean; const Baslik: string = '');
    procedure TemizleUstPanel;
    procedure SatirEkle;
    function DogrulaGiris(out Mesaj: string): Boolean;
    function KasaSatirYaz(Tur, HId, RehId, MasId: Integer; const Tarih: TDateTime;
                          const Aciklama, Kur, DovizKod: string;
                          Borc, Alacak, Doviz: Currency; EkstredeKullan: Boolean;
                          HesapTuru: Char = 'B'; GeriDonusId: Integer = -1;
                          const BelgeNo: string = ''; YerId: Integer = 0;
                          KrediId: Integer = -1): Integer;
    procedure HareketleriIceriAl(const DosyaYolu: string);
    function OkuCsv(const Dosya: string; const Konf: TBankaKonfig;
                    Satirlar: TBankaHareketListesi): Boolean;
    function OkuXls(const Dosya: string; const Konf: TBankaKonfig;
                    Satirlar: TBankaHareketListesi): Boolean;
    procedure SatirAnalizEt(const Satir: TBankaHareketSatiri;
                            BankaTipi: TBankaTipi;
                            out Tur: Integer; out RehberID: Integer;
                            out RehberAd, OnerilenAciklama: string;
                            out Confidence: Integer);
    function RehberAraExact(const Isim: string): Integer;
    function RehberAraLike(const Isim: string): Integer;
    function KartNoIleAra(const Aciklama: string): Integer;
    function KrediSecimEkraniAc(out KrediID, DetayID: Integer; out KrediAdi: string;
                                out TaksitTutar: Currency;
                                out BelgeNo, Aciklama: string): Boolean;
    procedure KrediSecimQueryAfterOpen(DataSet: TDataSet);
    function AciklamadanIsimCikar(const Aciklama: string;
                                  BankaTipi: TBankaTipi): string;
    function EtiketTuruEslestir(const Etiket: string; Negatif: Boolean;
                                BankaTipi: TBankaTipi;
                                out Tur: Integer; out Confidence: Integer): Boolean;
    function StrToTarihCSV(const S: string): TDateTime;
    function StrToTutarCSV(const S: string): Currency;
    function DekontNoSaatCikar(const DekontNo: string;
                               BankaTipi: TBankaTipi): TDateTime;
    function BankaKonfigGetir(Tipi: TBankaTipi): TBankaKonfig;
    function BankaTipiTespit(const Dosya: string): TBankaTipi;
    function BankaTipiSor(const Onerilen: TBankaTipi): TBankaTipi;
    function BankaKoduGetir(Tipi: TBankaTipi): string;
    procedure KurallariYukle(const BankaKodu: string);
    function KurallariGetir(const BankaKodu: string; KuralTipi: Char): TBankaKuralListesi;
    function LikePatternEslesir(const Metin, Pattern: string): Boolean;
    function RegexIleIsimCikar(const Aciklama, Pattern: string;
                               Grup: Integer; out Isim: string): Boolean;
    function FingerprintHesapla(BankaTipi: TBankaTipi; Tur: Integer;
                                const Aciklama: string): string;
    procedure EslemeKaydet(const BankaKodu, Fingerprint: string;
                           Tur, RehberID: Integer; KesinMi: Boolean = True);
    function EslemeBul(const BankaKodu, Fingerprint: string;
                       out Tur, RehberID: Integer; out KesinMi: Boolean): Boolean;
    procedure SatirTuruDegistir(YeniTurID: Integer);
  public
  end;

const
  // Tür ID'leri (Banka Hızlı Giriş.xlsx -> "Ekran Tasarımı" R8-R14)
  TURID_GELENHAVALE = 22;
  TURID_GIDENHAVALE = 32;
  TURID_PARAYATIRMA = 41;
  TURID_PARACEKME   = 42;
  TURID_HESAPLARARASI = 43;
  TURID_POSAKTARIM = 44;
  TURID_BANKADANDOVIZAL = 47;
  TURID_BANKADANDOVIZSAT = 48;
  TURID_BANKAARBITRAJ = 50;
  TURID_KKODEME     = 57;
  TURID_KREDIODEME  = 58;
  TURID_KKODEMEIADE = 87;
  // Masraf Ödeme: UI'de ayrı bir item olarak görünebilsin diye benzersiz Value (132).
  // KASA'ya yazılırken TURID_GIDENHAVALE (32) ile normalize edilir; MASRAFID dolu olur,
  // REHBERID = 0. Ayrım MASRAFID/REHBERID üzerinden, TUR aynı (32).
  TURID_MASRAFODEME = 132;
  // Gelir Tahsilatı: Masraf Ödeme'nin Gelen Havale versiyonu. KASA TUR=22, MASRAFID=gelir kalemi.
  TURID_GELIRTAHSILATI = 122;

var
  bankaHesapGirisdlg: TbankaHesapGirisdlg;

implementation

{$R *.dfm}

uses ULog, PrjConst, Utablo, FetaKurulusSiniflari, fetautil, LocOnfly, System.DateUtils,
  System.IOUtils, System.StrUtils, Winapi.ActiveX, System.Win.ComObj,
  System.RegularExpressions, System.Masks, UMT940Reader, UTabloGiris, UVeriMotor;

{ ---------- Yardımcı kurulum ---------- }

procedure TbankaHesapGirisdlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);   // Dil yükleme (UBelgegiris ile aynı pattern)
  Tablo.GridTurkcelestir;

  // Banka kural önbelleği — owned objects (auto free)
  FKuralCache := TObjectDictionary<string, TBankaKuralListesi>.Create([doOwnsValues]);
  FYuklenenBankalar := TStringList.Create;
  FYuklenenBankalar.Sorted := True;
  FYuklenenBankalar.Duplicates := dupIgnore;
  FMT940Dosyalar := TStringList.Create;
  FMT940Dosyalar.Sorted := True;
  FMT940Dosyalar.Duplicates := dupIgnore;
  FMT940Dosyalar.CaseSensitive := False;
  FKayitIDleri := TList<Integer>.Create;

  TurListesiniDoldur;

  // Döviz tipi combo — hesabın dövizine göre dinamik dolar
  DovizTipiniDoldur;

  FHESAPID  := 0;
  FSECIMID  := 0;
  FOtoHesapla := False;
  FDuzenlemeKipinde := False;
  KarsiligiPaneliGoster(False);
  MasrafPaneliGoster(False);   // ilk açılışta görünmesin (Tür default'u Gelen Havale)

  // Tarih sınırı — 2020 öncesi ve bugünden sonrası kabul edilmez
  cxDateEdit1.Properties.MinDate := EncodeDate(2020, 1, 1);
  cxDateEdit1.Properties.MaxDate := Date + 1 - (1 / 86400);   // bugün 23:59:59
end;

procedure TbankaHesapGirisdlg.FormShow(Sender: TObject);
begin
  cxDateEdit1.Date := Tablo.GENINI.BugunTrhSaat;     // tarih + saat otomatik (R7)
  cbTur.ItemIndex := 0;                              // ilk satır: Gelen Havale
  cbDovizTipi.ItemIndex := 0;                        // $
  dxMemData1.Open;
  TemizleUstPanel;

  // Form görünür hale geldikten sonra Hesap Seç modalını otomatik aç.
  // Kullanıcı modali iptal eder / kapatır → form da kapanır.
  TThread.ForceQueue(nil,
    procedure
    begin
      if (bankaHesapGirisdlg <> nil) and (FHESAPID = 0) then begin
        btnHesapSec.Click;
        if FHESAPID = 0 then
          Close;
      end;
    end);
end;

procedure TbankaHesapGirisdlg.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FYuklenenBankalar);
  FreeAndNil(FMT940Dosyalar);
  FreeAndNil(FKayitIDleri);
  FreeAndNil(FKuralCache);
  bankaHesapGirisdlg := nil;
end;

// KASA'ya yazılan satırın ID'sini biriktirir → FormClose'da EKLEME logu TEK SEFER yazılır.
function TbankaHesapGirisdlg.KayitIzle(AId: Integer): Integer;
begin
  Result := AId;
  if (AId > 0) and Assigned(FKayitIDleri) then
    FKayitIDleri.Add(AId);
end;

// TUR ID'sinin ekrandaki adini cbTur listesinden cozer (tek merkez).
function TbankaHesapGirisdlg.TurAdiGetir(ATur: Integer): string;
var i: Integer;
begin
  Result := '';
  for i := 0 to cbTur.Properties.Items.Count - 1 do
    if cbTur.Properties.Items[i].Value = ATur then
      Exit(cbTur.Properties.Items[i].Description);
end;

// MT940'tan gelen satirdaki karsi taraf IBAN'ini, secilen carinin IBAN'i BOSSA cariye yazar
// (onayli). Boylece bir sonraki MT940 yuklemesinde ayni cari IBAN ile otomatik eslesir.
// Dolu IBAN'in ustune ASLA yazilmaz. Degisiklik ISLEMLOG'a cari DEGISTIRME olarak islenir.
procedure TbankaHesapGirisdlg.IbanCariyeYaz(ARehId: Integer);
var
  LIban, LEski: string;
begin
  if ARehId <= 0 then Exit;
  if not FDuzenlemeKipinde then Exit;                 // yalniz grid satiri duzenlenirken
  if dxMemData1.RecordCount = 0 then Exit;
  LIban := Trim(dxMemData1IBAN.AsString);
  if LIban = '' then Exit;                            // elle giriste / IBAN'siz bankada bos
  LEski := Trim(Tablo.AciklamaGetir('REHBER', 'IBAN', ARehId));
  if LEski <> '' then Exit;                           // dolu IBAN'a dokunma
  if Application.MessageBox(PChar('Seçilen cariye bu IBAN kaydedilsin mi?' + sLineBreak + LIban),
                            PChar(Onay), MB_ICONQUESTION + MB_YESNO) <> IDYES then Exit;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'UPDATE REHBER SET IBAN = &I WHERE ID = &ID', ['&I', '&ID'], [LIban, ARehId]);
  // Cari kartina ISLEMLOG degistirme kaydi
  LogYaz(liDegistir, TabNo_REHBER, ARehId,
         TLogKurucu.Yeni.Alan('IBAN', LEski, LIban), 'Cari Kart');
end;

procedure TbankaHesapGirisdlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Bu oturumda kaydedilen banka hareketlerinin EKLEME loglari (TEK SEFER, kapanista).
  // Kayit guncel halinden loglanir (GERIDONUSID/BELGENO update'leri de yansimis olur).
  if (LogGun > 0) and (FKayitIDleri.Count > 0) then
  try
    var LQ: TFDQuery := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      for var LID in FKayitIDleri do begin
        LQ.Close;
        LQ.SQL.Text := 'SELECT * FROM KASA WHERE ID = ' + IntToStr(LID);
        LQ.Open;
        if not LQ.IsEmpty then begin
          // Bölüm: banka satırları yönüne göre 'Banka Ödeme' / 'Banka Tahsilat'
          var LTab: Integer := TabNo_KASA;
          if LQ.FieldByName('HESAPTURU').AsString = 'B' then
            if LQ.FieldByName('BORC').AsCurrency > 0 then
              LTab := TabNo_BANKAODEME
            else
              LTab := TabNo_BANKATAHSILAT;
          LogKayitEkle(LQ, LTab, LID, LTab, LID);
        end;
      end;
    finally
      LQ.Free;
    end;
    FKayitIDleri.Clear;
  except
    // loglama is akisini ASLA bozmaz
  end;
  Action := caFree;
end;

procedure TbankaHesapGirisdlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (dxMemData1.RecordCount < 1) or
              (Application.MessageBox(PChar(DKaydedilmedi_cikis_olacakmi), PChar(Onay), MB_YESNO) = IDYES);
end;

procedure TbankaHesapGirisdlg.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_F5: btnF5Kaydet.Click;
    VK_F8: btnF8Devam.Click;
  end;
end;

{ ---------- Üst banka hesabı bilgisi ---------- }

procedure TbankaHesapGirisdlg.HesapBilgiGoster;
begin
  lblBanka.Caption      := 'Banka: '  + FBankaAdi;
  lblSube.Caption       := 'Şube: '   + FSubeAdi;
  lblHesap.Caption      := 'Hesap: '  + FHESAPNO + '   (ID: ' + IntToStr(FHESAPID) + ')';
  lblHesapDoviz.Caption := 'P.Birimi: '  + FBankaDovizi;
end;

procedure TbankaHesapGirisdlg.TurListesiniDoldur;
begin
  cbTur.Properties.Items.Clear;
  with cbTur.Properties.Items do begin
    with Add do begin Description := 'Gelen Havale';            Value := TURID_GELENHAVALE; end;
    with Add do begin Description := 'Giden Havale';            Value := TURID_GIDENHAVALE; end;
    with Add do begin Description := 'Para Yatırma';            Value := TURID_PARAYATIRMA; end;
    with Add do begin Description := 'Para Çekme';              Value := TURID_PARACEKME; end;
    with Add do begin Description := 'Hesaplar arası transfer'; Value := TURID_HESAPLARARASI; end;
    with Add do begin Description := 'POS Aktarım';             Value := TURID_POSAKTARIM; end;
    if FBankaDovizi = CariDoviz then
      with Add do begin Description := 'Bankadan Döviz Al';     Value := TURID_BANKADANDOVIZAL; end
    else if FBankaDovizi <> '' then begin
      with Add do begin Description := 'Bankadan Döviz Sat';    Value := TURID_BANKADANDOVIZSAT; end;
      with Add do begin Description := 'Banka Arbitraj';        Value := TURID_BANKAARBITRAJ; end;
    end;
    with Add do begin Description := 'Masraf Ödeme';            Value := TURID_MASRAFODEME; end;
    with Add do begin Description := 'Gelir Tahsilatı';         Value := TURID_GELIRTAHSILATI; end;
    with Add do begin Description := 'KK Ödeme';                Value := TURID_KKODEME; end;
    with Add do begin Description := 'KK Ödeme İadesi';         Value := TURID_KKODEMEIADE; end;
    with Add do begin Description := 'Kredi Ödeme';             Value := TURID_KREDIODEME; end;
  end;

  TcxImageComboBoxProperties(cxGrid1DBTableView1TURID.Properties)
    .Items.Assign(cbTur.Properties.Items);
  if cbTur.Properties.Items.Count > 0 then
    cbTur.ItemIndex := 0;
end;

function TbankaHesapGirisdlg.BankaHesapSecModal(const DovizKodu: string; HaricID: Integer;
  out hId: Integer; out BankaAdi, SubeAdi, HesapNo, HesapKodu, Doviz, HesapAdi: string): Boolean;
// Aktif banka hesaplarını modal listeden seçtirir.
// DovizKodu boş ise döviz filtresi uygulanmaz (tüm dövizler listelenir).
// HaricID > 0 ise bu ID'li hesap dışlanır (hesaplar-arası transferde kendisini gizlemek için).
// Kolon sırası: 0=BH.ID, 1=BANKAADI, 2=SUBEADI, 3=HESAPNO, 4=HESAPKODU, 5=KUR, 6=HESAPADI
var
  SQL: string;
  Sonuc: TStringList;
begin
  Result := False;
  SQL :=
    'Select BH.ID, BL.BANKAADI, BS.SUBEADI, BH.HESAPNO, BH.HESAPKODU, BH.KUR, BH.HESAPADI ' +
    'from BANKAHESAPLAR BH ' +
    'inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID ' +
    'inner join BANKALAR     BL on BS.BANKAKODU = BL.BANKAKODU ' +
    'where BH.REHBERID = -1 and BH.DURUM = 1';
  if DovizKodu <> '' then
    SQL := SQL + ' and BH.KUR = ''' + DovizKodu + '''';
  if HaricID > 0 then
    SQL := SQL + ' and BH.ID NOT IN (' + IntToStr(HaricID) + ')';

  Sonuc := TStringList.Create;
  try
    if Tablo.ListedenBilgiGetir('Banka Hesap Seçimi', SQL, Sonuc, []) then begin
      hId       := StrToIntDef(Trim(Sonuc.Strings[0]), 0);
      BankaAdi  := Sonuc.Strings[1];
      SubeAdi   := Sonuc.Strings[2];
      HesapNo   := Sonuc.Strings[3];
      HesapKodu := Sonuc.Strings[4];
      Doviz     := Sonuc.Strings[5];
      HesapAdi  := Sonuc.Strings[6];
      Result := True;
    end;
  finally
    Sonuc.Free;
  end;
end;

function TbankaHesapGirisdlg.BankaDovizHesapSecModal(const HaricDoviz: string;
  HaricID: Integer; out hId: Integer; out BankaAdi, SubeAdi, HesapNo,
  HesapKodu, Doviz, HesapAdi: string): Boolean;
var
  SQL: string;
  Sonuc: TStringList;
begin
  Result := False;
  SQL :=
    'Select BH.ID, BL.BANKAADI, BS.SUBEADI, BH.HESAPNO, BH.HESAPKODU, BH.KUR, BH.HESAPADI ' +
    'from BANKAHESAPLAR BH ' +
    'inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID ' +
    'inner join BANKALAR BL on BS.BANKAKODU = BL.BANKAKODU ' +
    'where BH.REHBERID = -1 and BH.DURUM = 1 ' +
    'and BH.KUR <> ''' + StringReplace(HaricDoviz, '''', '''''', [rfReplaceAll]) + '''';
  if HaricID > 0 then
    SQL := SQL + ' and BH.ID <> ' + IntToStr(HaricID);
  SQL := SQL + ' order by BH.KUR, BL.BANKAADI, BS.SUBEADI, BH.HESAPADI';

  Sonuc := TStringList.Create;
  try
    if Tablo.ListedenBilgiGetir('Döviz Alınacak Banka Hesabı', SQL, Sonuc, []) then begin
      hId       := StrToIntDef(Trim(Sonuc.Strings[0]), 0);
      BankaAdi  := Sonuc.Strings[1];
      SubeAdi   := Sonuc.Strings[2];
      HesapNo   := Sonuc.Strings[3];
      HesapKodu := Sonuc.Strings[4];
      Doviz     := Sonuc.Strings[5];
      HesapAdi  := Sonuc.Strings[6];
      Result := True;
    end;
  finally
    Sonuc.Free;
  end;
end;

function TbankaHesapGirisdlg.BankaArbitrajHesapSecModal(const HaricDoviz: string;
  HaricID: Integer; out hId: Integer; out BankaAdi, SubeAdi, HesapNo,
  HesapKodu, Doviz, HesapAdi: string): Boolean;
var
  SQL: string;
  Sonuc: TStringList;
begin
  Result := False;
  SQL :=
    'Select BH.ID, BL.BANKAADI, BS.SUBEADI, BH.HESAPNO, BH.HESAPKODU, BH.KUR, BH.HESAPADI ' +
    'from BANKAHESAPLAR BH ' +
    'inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID ' +
    'inner join BANKALAR BL on BS.BANKAKODU = BL.BANKAKODU ' +
    'where BH.REHBERID = -1 and BH.DURUM = 1 ' +
    'and BH.KUR <> ''' + StringReplace(CariDoviz, '''', '''''', [rfReplaceAll]) + ''' ' +
    'and BH.KUR <> ''' + StringReplace(HaricDoviz, '''', '''''', [rfReplaceAll]) + '''';
  if HaricID > 0 then
    SQL := SQL + ' and BH.ID <> ' + IntToStr(HaricID);
  SQL := SQL + ' order by BH.KUR, BL.BANKAADI, BS.SUBEADI, BH.HESAPADI';

  Sonuc := TStringList.Create;
  try
    if Tablo.ListedenBilgiGetir('Arbitraj Hedef Banka Hesabı', SQL, Sonuc, []) then begin
      hId       := StrToIntDef(Trim(Sonuc.Strings[0]), 0);
      BankaAdi  := Sonuc.Strings[1];
      SubeAdi   := Sonuc.Strings[2];
      HesapNo   := Sonuc.Strings[3];
      HesapKodu := Sonuc.Strings[4];
      Doviz     := Sonuc.Strings[5];
      HesapAdi  := Sonuc.Strings[6];
      Result := True;
    end;
  finally
    Sonuc.Free;
  end;
end;

function TbankaHesapGirisdlg.PosSecModal(out PosID: Integer;
  out PosAdi, BankaHesapAdi: string): Boolean;
var
  SQL: string;
  Sonuc: TStringList;
begin
  Result := False;
  SQL :=
    'SELECT P.ID, P.KODU, P.ADI, P.KUR, BH.HESAPADI ' +
    'FROM POS P ' +
    'INNER JOIN BANKAHESAPLAR BH ON BH.ID=P.BANKAHESAPID ' +
    'WHERE P.DURUM=1 AND BH.DURUM=1 AND P.KUR=BH.KUR ' +
    'ORDER BY P.KODU, P.ADI';

  Sonuc := TStringList.Create;
  try
    if Tablo.ListedenBilgiGetir('POS Seçimi', SQL, Sonuc, []) then begin
      PosID := StrToIntDef(Trim(Sonuc.Strings[0]), 0);
      PosAdi := Sonuc.Strings[2];
      BankaHesapAdi := Sonuc.Strings[4];
      Result := PosID > 0;
    end;
  finally
    Sonuc.Free;
  end;
end;

procedure TbankaHesapGirisdlg.btnHesapSecClick(Sender: TObject);
begin
  // İlk hesap seçimi — döviz filtresi yok, tüm aktif firma hesapları gelsin.
  if BankaHesapSecModal('', 0, FHESAPID, FBankaAdi, FSubeAdi, FHESAPNO, FHESAPKODU, FBankaDovizi, FHesapAdi) then begin
    HesapBilgiGoster;
    TurListesiniDoldur;
    DovizTipiniDoldur;   // hesabın dövizine göre döviz tipi seçeneklerini yeniden kur
  end;
end;

{ ---------- Üst panel temizleme / yardımcılar ---------- }

procedure TbankaHesapGirisdlg.TemizleUstPanel;
begin
  cxDateEdit1.Date := Tablo.GENINI.BugunTrhSaat;
  cbTur.ItemIndex := 0;
  beSecim.Clear;
  FSECIMID := 0;
  ceTutar.Value := 0;
  ceKomisyon.Value := 0;
  teAciklama.Clear;
  teBelgeNo.Clear;
  beMasrafKalemi.Clear;
  FMasrafKalemiID := 0;
  // teBelgeNo: Tür Gelen/Giden Havale ise sıradaki makbuz no ile yeniden doldur
  BelgeNoOtomatikDoldur;
  chkKarsiligi.Checked := False;
  chkEkstrede.Checked := False;
  ceDovizTutar.Value := 0;
  cbDovizTipi.ItemIndex := 0;
  // Kur defaultta dolu kalır — DovizTipi değişince yeniden okunur
  KarsiligiPaneliGoster(False);
end;

procedure TbankaHesapGirisdlg.KarsiligiPaneliGoster(Goster: Boolean);
begin
  PanelKarsiligiSag.Visible := Goster;
  if Goster and (ceKur.Value = 0) then
    DovizKuruYukle;
end;

procedure TbankaHesapGirisdlg.chkKarsiligiClick(Sender: TObject);
begin
  KarsiligiPaneliGoster(chkKarsiligi.Checked);
end;

{ ---------- Tür / Seçim modal akışı ---------- }

procedure TbankaHesapGirisdlg.cbTurPropertiesChange(Sender: TObject);
begin
  TurDegistiUygula;
end;

procedure TbankaHesapGirisdlg.TurDegistiUygula;
var
  Tur: Integer;
begin
  // Tür değişince önceki seçimi ve açıklamayı sıfırla
  beSecim.Clear;
  FSECIMID := 0;
  teAciklama.Clear;
  // Masraf (Banka Komisyonu) alanı: Giden Havale, Hesaplar Arası, Masraf Ödeme,
  // Gelir Tahsilatı türlerinde görünür
  MasrafPaneliGoster((cbTur.ItemIndex >= 0) and
                     ((cbTur.EditValue = TURID_GIDENHAVALE) or
                       (cbTur.EditValue = TURID_HESAPLARARASI) or
                      (cbTur.EditValue = TURID_POSAKTARIM) or
                      (cbTur.EditValue = TURID_MASRAFODEME) or
                      (cbTur.EditValue = TURID_GELIRTAHSILATI)));

  // Masraf/Gelir Kalemi seçim alanı: Gelen Havale → 'Gelir Kalemi', Giden Havale → 'Masraf Kalemi'
  if cbTur.ItemIndex >= 0 then begin
    Tur := cbTur.EditValue;
    if Tur = TURID_GELENHAVALE then
      MasrafKalemiPaneliGoster(True, 'Gelir Kalemi')
    else if Tur = TURID_GIDENHAVALE then
      MasrafKalemiPaneliGoster(True, 'Masraf Kalemi')
    else
      MasrafKalemiPaneliGoster(False);
  end else
    MasrafKalemiPaneliGoster(False);

  if (cbTur.ItemIndex >= 0) and
     ((cbTur.EditValue = TURID_BANKADANDOVIZAL) or
      (cbTur.EditValue = TURID_BANKADANDOVIZSAT) or
      (cbTur.EditValue = TURID_BANKAARBITRAJ)) then begin
    chkKarsiligi.Checked := True;
    KarsiligiPaneliGoster(True);
    cbDovizTipi.Enabled := False;
  end else begin
    chkKarsiligi.Checked := False;
    KarsiligiPaneliGoster(False);
    cbDovizTipi.Enabled := True;
  end;

  BelgeNoOtomatikDoldur;
end;

procedure TbankaHesapGirisdlg.AciklamaOtomatikDoldur(Tur: Integer);
// SecimEkraniAc sırasında bir seçim yapıldığında teAciklama'yı türün yönüne göre yeniden üretir.
// Seçim her değiştiğinde overwrite eder. Gelen/Giden Havale için boş bırakır (kullanıcı yazsın).
begin
  if FSECIMID = 0 then Exit;
  if FHesapAdi = '' then Exit;
  case Tur of
    TURID_GELIRTAHSILATI,
    TURID_PARAYATIRMA,
    TURID_KKODEMEIADE:                 // para banka hesabına giriyor
      teAciklama.Text := beSecim.Text + ' > ' + FHesapAdi;
    TURID_MASRAFODEME,
    TURID_PARACEKME,
    TURID_KKODEME:                     // para banka hesabından çıkıyor
      teAciklama.Text := FHesapAdi + ' > ' + beSecim.Text;
    // TURID_GELENHAVALE, TURID_GIDENHAVALE: açıklama boş kalır — kullanıcı manuel girer
    // Virman ve döviz al/sat türleri kendi seçim dalında set edilir.
  end;
end;

procedure TbankaHesapGirisdlg.BelgeNoOtomatikDoldur;
// Belge No: Gelen/Giden Havale ve Gelir Tahsilatı için otomatik sıradaki makbuz
// numarası; diğer türler için doluysa temizlenir (kullanıcı manuel yazabilir).
var
  Tur: Integer;
begin
  if cbTur.ItemIndex < 0 then Exit;
  Tur := cbTur.EditValue;
  if (Tur = TURID_GELENHAVALE) or (Tur = TURID_GIDENHAVALE) then
    teBelgeNo.Text := SiradakiMakbuzNumarasi(Tur)
  else if Tur = TURID_GELIRTAHSILATI then
    teBelgeNo.Text := SiradakiMakbuzNumarasi(TURID_GELENHAVALE)   // KASA TUR=22 ile aynı seri
  else if Tur = TURID_MASRAFODEME then
    teBelgeNo.Text := SiradakiMakbuzNumarasi(TURID_GIDENHAVALE)   // KASA TUR=32 ile aynı seri
  else if teBelgeNo.Text <> '' then
    teBelgeNo.Clear;
end;

procedure TbankaHesapGirisdlg.MasrafPaneliGoster(Goster: Boolean);
begin
  lbl_Masraf.Visible := Goster;
  ceKomisyon.Visible   := Goster;
  ceKomisyon.Enabled   := Goster;
  if not Goster then
    ceKomisyon.Value := 0;
end;

procedure TbankaHesapGirisdlg.MasrafKalemiPaneliGoster(Goster: Boolean; const Baslik: string = '');
// Gelen Havale → 'Gelir Kalemi', Giden Havale → 'Masraf Kalemi'.
// Görünür olduğunda teAciklama daralır (240), gizliyken eski genişliğine (400) döner.
begin
  lbl_MasrafKalemi.Visible := Goster;
  beMasrafKalemi.Visible   := Goster;
  if Goster then begin
    teAciklama.Width := 240;
    if Baslik <> '' then
      lbl_MasrafKalemi.Caption := Baslik;
  end else begin
    teAciklama.Width := 400;
    beMasrafKalemi.Clear;
    FMasrafKalemiID := 0;
  end;
end;

procedure TbankaHesapGirisdlg.MasrafKalemiEkraniAc;
var
  Tur: Integer;
  GelirGider: SmallInt;
  s1, s2, s3: string;
begin
  if cbTur.ItemIndex < 0 then Exit;
  Tur := cbTur.EditValue;
  // Gelen Havale → gelir kalemi (1), Giden Havale → masraf kalemi (0)
  if Tur = TURID_GELENHAVALE then
    GelirGider := 1
  else if Tur = TURID_GIDENHAVALE then
    GelirGider := 0
  else
    Exit;

  if Tablo.MasrafMerkeziSecimEkrani(GelirGider, s1, s2, s3) then begin
    FMasrafKalemiID    := StrToIntDef(s1, 0);
    beMasrafKalemi.Text := s3;     // Masraf/Gelir kalemi adı
  end;
end;

procedure TbankaHesapGirisdlg.beMasrafKalemiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  MasrafKalemiEkraniAc;
end;

procedure TbankaHesapGirisdlg.beSecimPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  SecimEkraniAc;
end;

procedure TbankaHesapGirisdlg.SecimEkraniAc;
var
  TurId: Integer;
  s1, s2, s3, s4, s5, s6: string;
  iTmp, i: Integer;
  Sonuc: TStringList;
begin
  if cbTur.ItemIndex < 0 then Exit;
  TurId := cbTur.EditValue;

  case TurId of
    TURID_GELENHAVALE, TURID_GIDENHAVALE:
      begin
        // Cari (müşteri) seçimi — UBelgegiris'teki gibi
        iTmp := Tablo.RehberAra_IDGetir(-1);
        if iTmp > 0 then begin
          FSECIMID := iTmp;
          beSecim.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', iTmp);
          // MT940 satirinda IBAN varsa ve secilen carinin IBAN'i bossa cariye kaydet
          IbanCariyeYaz(iTmp);
          // Öğrenen eşleme: bu MT940 ünvanı için seçilen cariyi hatırla
          if FDuzenlemeKipinde and (dxMemData1.RecordCount > 0) and
             (Trim(dxMemData1HAMAD.AsString) <> '') then
            EslemeKaydet('MT940', 'MTAD:' + AnsiUpperCase(Trim(dxMemData1HAMAD.AsString)),
                         dxMemData1TURID.AsInteger, iTmp, True);
        end;
      end;

    TURID_MASRAFODEME:
      begin
        if Tablo.MasrafMerkeziSecimEkrani(0, s1, s2, s3) then begin
          FSECIMID := StrToIntDef(s1, 0);
          beSecim.Text := s3;                    // Masraf merkezi adı
        end;
      end;

    TURID_GELIRTAHSILATI:
      begin
        // Gelir kalemi seçimi (MasrafMerkeziSecimEkrani Gelirmi=1)
        if Tablo.MasrafMerkeziSecimEkrani(1, s1, s2, s3) then begin
          FSECIMID := StrToIntDef(s1, 0);
          beSecim.Text := s3;
        end;
      end;

    TURID_KKODEME, TURID_KKODEMEIADE:
      begin
        // KrediKartiEkrani(var KKID, KODU, ADI, Kur: string)
        s1 := ''; s2 := ''; s3 := ''; s4 := FBankaDovizi;
        if Tablo.KrediKartiEkrani(s1, s2, s3, s4) then begin
          FSECIMID := StrToIntDef(s1, 0);
          beSecim.Text := s3;
        end;
      end;

    TURID_KREDIODEME:
      begin
        // UKasaWizard CekSenetKrediAraEkr grid'i — ödenmemiş krediler listesi (ADI'ya göre gruplu)
        var KrediID, DetayID: Integer;
        var KrediAd, KrediBelgeNo: string;
        var TaksitTutar: Currency;
        var KrediAciklama: string;
        if KrediSecimEkraniAc(KrediID, DetayID, KrediAd, TaksitTutar, KrediBelgeNo, KrediAciklama) then begin
          FSECIMID := KrediID;
          FKrediDetayID := DetayID;       // F5 Kaydet'te kullanılacak
          FKrediBelgeNo := KrediBelgeNo;
          beSecim.Text := KrediAd;
          if TaksitTutar > 0 then ceTutar.Value := TaksitTutar;
          // Açıklama: önce kredi adı, sonra "-" ile seçilen açıklama
          if Trim(KrediAciklama) <> '' then
            teAciklama.Text := KrediAd + ' - ' + KrediAciklama
          else
            teAciklama.Text := KrediAd;
          // BelgeNo'yu da kredi'nin BELGENO'su olarak doldur
          if Trim(KrediBelgeNo) <> '' then teBelgeNo.Text := KrediBelgeNo;
        end;
      end;

    TURID_POSAKTARIM:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz (Hesap Seç).',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if PosSecModal(iTmp, s1, s2) then begin
          FSECIMID := iTmp;
          beSecim.Text := s1;
          teAciklama.Text := s1 + ' > ' + s2;
        end;
      end;

    TURID_PARAYATIRMA, TURID_PARACEKME:
      begin
        // Kasa listesi — sadece banka hesabının dövizine uyanlar
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz (Hesap Seç).',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        Sonuc := TStringList.Create;
        try
          if Tablo.ListedenBilgiGetir('Kasa Seçimi',
            'SELECT ID, KASAKODU, KASAADI FROM KASALAR ' +
            'WHERE DURUM = 1 AND KASATUR = 100 AND KUR = ''' + FBankaDovizi + ''' ' +
            'ORDER BY KASAADI',
            Sonuc, []) then begin
            FSECIMID := StrToIntDef(Sonuc.Strings[0], 0);
            beSecim.Text := Sonuc.Strings[2];   // KASAADI
          end;
        finally
          Sonuc.Free;
        end;
      end;

    TURID_HESAPLARARASI:
      begin
        // Karşı banka hesabı — ana hesabın dövizine uyanlar, kendisi hariç.
        // Açıklama bu blok içinde set edilir (hedef HESAPADI'sı kullanılır), centralized helper skip eder.
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz (Hesap Seç).',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaHesapSecModal(FBankaDovizi, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          FSECIMID := iTmp;
          beSecim.Text := s1 + ' / ' + s2 + ' - ' + s3;   // BankaAdi / Şube - HesapNo
          // Seçim değiştiğinde açıklama yeniden üretilir (HESAPADI'lar zaten formatlı)
          teAciklama.Text := FHesapAdi + ' > ' + s6;
        end;
      end;

    TURID_BANKADANDOVIZAL:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz (Hesap Seç).',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaDovizHesapSecModal(FBankaDovizi, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          FSECIMID := iTmp;
          beSecim.Text := s1 + ' / ' + s2 + ' - ' + s3;
          teAciklama.Text := FHesapAdi + ' > ' + s6;

          i := 0;
          while (i < cbDovizTipi.Properties.Items.Count) and
                (VarToStr(cbDovizTipi.Properties.Items[i].Value) <> s5) do
            Inc(i);
          if i = cbDovizTipi.Properties.Items.Count then
            with cbDovizTipi.Properties.Items.Add do begin
              Description := s5;
              Value := s5;
            end;
          cbDovizTipi.ItemIndex := i;
          chkKarsiligi.Checked := True;
          KarsiligiPaneliGoster(True);
          DovizKuruYukle;
        end;
      end;

    TURID_BANKADANDOVIZSAT:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz (Hesap Seç).',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaHesapSecModal(CariDoviz, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          FSECIMID := iTmp;
          beSecim.Text := s1 + ' / ' + s2 + ' - ' + s3;
          teAciklama.Text := FHesapAdi + ' > ' + s6;

          i := 0;
          while (i < cbDovizTipi.Properties.Items.Count) and
                (VarToStr(cbDovizTipi.Properties.Items[i].Value) <> s5) do
            Inc(i);
          if i = cbDovizTipi.Properties.Items.Count then
            with cbDovizTipi.Properties.Items.Add do begin
              Description := s5;
              Value := s5;
            end;
          cbDovizTipi.ItemIndex := i;
          chkKarsiligi.Checked := True;
          KarsiligiPaneliGoster(True);
          DovizKuruYukle;
        end;
      end;

    TURID_BANKAARBITRAJ:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz (Hesap Seç).',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaArbitrajHesapSecModal(FBankaDovizi, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          FSECIMID := iTmp;
          beSecim.Text := s1 + ' / ' + s2 + ' - ' + s3;
          teAciklama.Text := FHesapAdi + ' > ' + s6;

          i := 0;
          while (i < cbDovizTipi.Properties.Items.Count) and
                (VarToStr(cbDovizTipi.Properties.Items[i].Value) <> s5) do
            Inc(i);
          if i = cbDovizTipi.Properties.Items.Count then
            with cbDovizTipi.Properties.Items.Add do begin
              Description := s5;
              Value := s5;
            end;
          cbDovizTipi.ItemIndex := i;
          chkKarsiligi.Checked := True;
          KarsiligiPaneliGoster(True);
          DovizKuruYukle;
        end;
      end;
  end;

  // Virman türleri dışındaki türler için açıklamayı yön kuralına göre otomatik doldur.
  if not (TurId in [TURID_HESAPLARARASI, TURID_POSAKTARIM, TURID_BANKADANDOVIZAL,
                    TURID_BANKADANDOVIZSAT, TURID_BANKAARBITRAJ]) then
    AciklamaOtomatikDoldur(TurId);
end;

{ ---------- Döviz hesabı (Karşılığı paneli) ---------- }

procedure TbankaHesapGirisdlg.cbDovizTipiPropertiesChange(Sender: TObject);
begin
  if FOtoHesapla then Exit;   // grid satırı yüklenirken kaydedilen kuru ezme
  DovizKuruYukle;
end;

procedure TbankaHesapGirisdlg.DovizKuruYukle;
var
  DovizKod: string;
  KaynakKur, HedefKur, KurDeger: Currency;
begin
  if cbDovizTipi.ItemIndex < 0 then Exit;
  DovizKod := VarToStr(cbDovizTipi.EditValue);

  if FBankaDovizi = CariDoviz then
    KaynakKur := 1
  else
    KaynakKur := DovizKuruBul(FormatDateTime('yyyy-mm-dd', cxDateEdit1.Date), FBankaDovizi,
                              Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));
  if DovizKod = CariDoviz then
    HedefKur := 1
  else
    HedefKur := DovizKuruBul(FormatDateTime('yyyy-mm-dd', cxDateEdit1.Date), DovizKod,
                             Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));

  if FBankaDovizi = CariDoviz then
    KurDeger := HedefKur
  else if HedefKur <> 0 then
    KurDeger := KaynakKur / HedefKur
  else
    KurDeger := 0;

  FOtoHesapla := True;
  try
    ceKur.Value := KurDeger;
    HesaplaDovizTutar;
  finally
    FOtoHesapla := False;
  end;
end;

procedure TbankaHesapGirisdlg.ceTutarPropertiesChange(Sender: TObject);
begin
  if FOtoHesapla then Exit;
  HesaplaDovizTutar;
end;

procedure TbankaHesapGirisdlg.ceKurPropertiesChange(Sender: TObject);
begin
  if FOtoHesapla then Exit;
  HesaplaDovizTutar;
end;

procedure TbankaHesapGirisdlg.HesaplaDovizTutar;
// Kural:
//   FBankaDovizi = CariDoviz (örn. TL hesap, TL sistem) → DovizTutar = Tutar / Kur
//   FBankaDovizi ≠ CariDoviz (yabancı para hesap)        → DovizTutar = Tutar * Kur
begin
  FOtoHesapla := True;
  try
    if FBankaDovizi = CariDoviz then begin
      if ceKur.Value <> 0 then
        ceDovizTutar.Value := ceTutar.Value / ceKur.Value
      else
        ceDovizTutar.Value := 0;
    end else
      ceDovizTutar.Value := ceTutar.Value * ceKur.Value;
  finally
    FOtoHesapla := False;
  end;
end;

procedure TbankaHesapGirisdlg.DovizTipiniDoldur;
// Hesabın dövizi CariDoviz'den farklıysa (yabancı para hesap) listeye CariDoviz (TL)
// eklenir ve default seçilir. Aynıysa sadece yabancı dövizler ($/€/£), default $.
var
  TLEklenmeli: Boolean;
begin
  TLEklenmeli := (FBankaDovizi <> '') and (FBankaDovizi <> CariDoviz);
  FOtoHesapla := True;
  try
    cbDovizTipi.Properties.Items.Clear;
    with cbDovizTipi.Properties.Items do begin
      if TLEklenmeli then
        with Add do begin Description := CariDoviz; Value := CariDoviz; end;
      with Add do begin Description := '$'; Value := '$'; end;
      with Add do begin Description := '€'; Value := '€'; end;
      with Add do begin Description := '£'; Value := '£'; end;
    end;
    cbDovizTipi.ItemIndex := 0;     // ya CariDoviz ya $ — her ikisi de ilk eleman
  finally
    FOtoHesapla := False;
  end;
end;

{ ---------- F8: üst paneli grid'e satır olarak ekle ---------- }

procedure TbankaHesapGirisdlg.btnF8DevamClick(Sender: TObject);
begin
  SatirEkle;
end;

function TbankaHesapGirisdlg.DogrulaGiris(out Mesaj: string): Boolean;
begin
  Result := False;
  if FHESAPID = 0 then begin
    Mesaj := 'Önce banka hesabı seçiniz (Hesap Seç).';
    Exit;
  end;
  if cbTur.ItemIndex < 0 then begin
    Mesaj := 'Tür seçiniz.';
    Exit;
  end;
  if (cbTur.EditValue <> TURID_HESAPLARARASI) and (FSECIMID = 0) then begin
    // Hesaplar arası transferde de seçim olmalı aslında — yine de ayrı mesaj
    Mesaj := 'Seçim alanını doldurunuz.';
    Exit;
  end;
  if FSECIMID = 0 then begin
    Mesaj := 'Seçim alanını doldurunuz.';
    Exit;
  end;
  if ceTutar.Value <= 0 then begin
    Mesaj := 'Tutar giriniz.';
    Exit;
  end;
  if (Integer(cbTur.EditValue) = TURID_POSAKTARIM) and
     ((ceKomisyon.Value < 0) or (ceKomisyon.Value >= ceTutar.Value)) then begin
    Mesaj := 'POS komisyonu sıfırdan küçük olamaz ve aktarım tutarından küçük olmalıdır.';
    Exit;
  end;
  if (Integer(cbTur.EditValue) = TURID_BANKAARBITRAJ) and
     ((FBankaDovizi = CariDoviz) or
      (VarToStr(cbDovizTipi.EditValue) = CariDoviz)) then begin
    Mesaj := 'Banka arbitraj işleminde kaynak ve hedef hesaplar TL dışında olmalıdır.';
    Exit;
  end;
  if (Integer(cbTur.EditValue) in [TURID_BANKADANDOVIZAL, TURID_BANKADANDOVIZSAT,
                                   TURID_BANKAARBITRAJ]) and
     (not chkKarsiligi.Checked or (ceDovizTutar.Value <= 0) or
      (VarToStr(cbDovizTipi.EditValue) = FBankaDovizi)) then begin
    Mesaj := 'Döviz alınacak farklı para birimli hesabı ve karşılık tutarını seçiniz.';
    Exit;
  end;
  Result := True;
end;

procedure TbankaHesapGirisdlg.SatirEkle;
var
  Mesaj: string;
begin
  if not DogrulaGiris(Mesaj) then begin
    Application.MessageBox(PChar(Mesaj), PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
    Exit;
  end;

  FSatirEkleniyor := True;
  try
  if FDuzenlemeKipinde and (dxMemData1.RecordCount > 0) then
    dxMemData1.Edit            // mevcut satırı güncelle
  else
    dxMemData1.Append;          // yeni satır ekle
  dxMemData1TARIH.AsDateTime     := cxDateEdit1.Date;
  dxMemData1TURID.AsInteger      := cbTur.EditValue;
  dxMemData1TUR.AsString         := cbTur.Text;
  dxMemData1SECIMID.AsInteger    := FSECIMID;
  dxMemData1SECIM.AsString       := beSecim.Text;
  dxMemData1TUTAR.AsCurrency     := ceTutar.Value;
  dxMemData1PBIRIMI.AsString     := FBankaDovizi;
  dxMemData1KOMISYON.AsCurrency  := ceKomisyon.Value;
  dxMemData1ACIKLAMA.AsString    := teAciklama.Text;
  dxMemData1BELGENO.AsString     := teBelgeNo.Text;
  dxMemData1KARSILIGI.AsBoolean  := chkKarsiligi.Checked;
  if chkKarsiligi.Checked then begin
    dxMemData1DOVIZ_TUTARI.AsCurrency := ceDovizTutar.Value;
    dxMemData1DOVIZ_TIPI.AsString     := VarToStr(cbDovizTipi.EditValue);
    dxMemData1KUR.AsCurrency          := ceKur.Value;
  end else begin
    dxMemData1DOVIZ_TUTARI.AsCurrency := 0;
    dxMemData1DOVIZ_TIPI.AsString     := '';
    dxMemData1KUR.AsCurrency          := 0;
  end;
  dxMemData1EKSTREDE_KULLAN.AsBoolean := chkEkstrede.Checked;
  // Gelen/Giden Havale türü için seçilen Masraf/Gelir Kalemi (KASA.MASRAFID)
  dxMemData1MASRAFID.AsInteger      := FMasrafKalemiID;
  dxMemData1MASRAFKALEMI.AsString   := beMasrafKalemi.Text;
  // Kredi Ödeme türü için seçilen taksitin PLANKREDI ID'si
  dxMemData1KREDIDETAYID.AsInteger  := FKrediDetayID;
  dxMemData1.Post;
  finally
    FSatirEkleniyor := False;
  end;

  FDuzenlemeKipinde := False;   // F8 sonrası edit modundan çık
  TemizleUstPanel;
  // Sonraki giriş için pratik: Tarih ve sabit alanları koru, fokus Tür'e
  cxDateEdit1.Date := Tablo.GENINI.BugunTrhSaat;
  cbTur.SetFocus;
end;

procedure TbankaHesapGirisdlg.miSatirSilClick(Sender: TObject);
begin
  if dxMemData1.RecordCount > 0 then begin
    dxMemData1.Delete;
    FDuzenlemeKipinde := False;
    TemizleUstPanel;
  end;
end;

procedure TbankaHesapGirisdlg.cxGrid1DBTableView1FocusedRecordChanged(
  Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if AFocusedRecord = nil then begin
    FDuzenlemeKipinde := False;
    Exit;
  end;
  SatiriUstePanele;
end;

procedure TbankaHesapGirisdlg.cxGrid1DBTableView1CellClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
// Tek satır olduğunda OnFocusedRecordChanged ateşlenmez — cell click ile de yükle.
begin
  if AButton = mbLeft then
    SatiriUstePanele;
end;

procedure TbankaHesapGirisdlg.SatiriUstePanele;
// Grid'in mevcut focuslu kaydını üst giriş paneline kopyalar.
// SatirEkle sonradan F8 ile çağrılınca, FDuzenlemeKipinde true ise Append yerine Edit yapar.
var
  i: Integer;
begin
  if FSatirEkleniyor then Exit;              // SatirEkle Append/Edit ortasında çağrılma
  if dxMemData1.State in [dsInsert, dsEdit] then Exit;
  if dxMemData1.RecordCount = 0 then begin
    FDuzenlemeKipinde := False;
    Exit;
  end;

  FOtoHesapla := True;     // yükleme sırasında auto-calc / DovizKuruYukle blokla
  try
    cxDateEdit1.Date := dxMemData1TARIH.AsDateTime;

    // Tür combo'sundan TURID'e uyan satırı seç
    for i := 0 to cbTur.Properties.Items.Count - 1 do
      if Integer(cbTur.Properties.Items[i].Value) = dxMemData1TURID.AsInteger then begin
        cbTur.ItemIndex := i;
        Break;
      end;
    // cbTur değişimi beSecim'i temizledi — saklanan değerleri tekrar set et
    FSECIMID     := dxMemData1SECIMID.AsInteger;
    beSecim.Text := dxMemData1SECIM.AsString;

    ceTutar.Value       := dxMemData1TUTAR.AsCurrency;
    ceKomisyon.Value      := dxMemData1KOMISYON.AsCurrency;
    teAciklama.Text     := dxMemData1ACIKLAMA.AsString;
    teBelgeNo.Text      := dxMemData1BELGENO.AsString;
    chkEkstrede.Checked := dxMemData1EKSTREDE_KULLAN.AsBoolean;

    // Masraf/Gelir Kalemi — saklı ID + adı
    FMasrafKalemiID := dxMemData1MASRAFID.AsInteger;
    if FMasrafKalemiID > 0 then
      beMasrafKalemi.Text := dxMemData1MASRAFKALEMI.AsString
    else
      beMasrafKalemi.Clear;

    if dxMemData1KARSILIGI.AsBoolean then begin
      // ceKur'u önce set et — KarsiligiPaneliGoster yalnız ceKur=0 iken DovizKuruYukle çağırır
      ceKur.Value        := dxMemData1KUR.AsCurrency;
      ceDovizTutar.Value := dxMemData1DOVIZ_TUTARI.AsCurrency;
      for i := 0 to cbDovizTipi.Properties.Items.Count - 1 do
        if VarToStr(cbDovizTipi.Properties.Items[i].Value) = dxMemData1DOVIZ_TIPI.AsString then begin
          cbDovizTipi.ItemIndex := i;
          Break;
        end;
      chkKarsiligi.Checked := True;
    end else begin
      chkKarsiligi.Checked := False;
      ceKur.Value          := 0;
      ceDovizTutar.Value   := 0;
    end;
  finally
    FOtoHesapla := False;
  end;

  FDuzenlemeKipinde := True;
end;

{ ---------- F5: Kaydet ---------- }

function TbankaHesapGirisdlg.KasaSatirYaz(Tur, HId, RehId, MasId: Integer;
  const Tarih: TDateTime; const Aciklama, Kur, DovizKod: string;
  Borc, Alacak, Doviz: Currency; EkstredeKullan: Boolean;
  HesapTuru: Char = 'B'; GeriDonusId: Integer = -1;
  const BelgeNo: string = ''; YerId: Integer = 0;
  KrediId: Integer = -1): Integer;
// Tek KASA satırı yaz — UNakitDlg.tamamButtonClick'teki (satır 1084) çağrı düzeniyle uyumlu.
// FaturaId/KrediId/CekSenetId/SubeId varsayılanları -1. HesapTuru ve GeriDonusId çağıran tarafından
// özelleştirilebilir (KK Ödeme'de 'V' / karşı satır ID için). YerId komisyon/masraf satırının
// ana satıra bağlanması için kullanılır.
// Result = KASA.ID
var
  TarihSaniye: TDateTime;
begin
  // KASA'ya saniye hassasiyetinde yaz — millisaniyeleri at
  TarihSaniye := RecodeMillisecond(Tarih, 0);
  Result := KayitIzle(Tablo.KasaKaydet(
    Tur,
    TarihSaniye,                      // PlanTarihi
    TarihSaniye,                      // IslemTarihi
    RehId,
    Aciklama,
    HId,                              // HesapID
    Kur,                              // hesap dövizi (KUR sütunu)
    DovizKod,                         // DOVIZ_KURU sütunu
    MasId,
    Borc, Alacak, Doviz,
    0, -1, KrediId, 0, GeriDonusId, -1,    // Durum, FaturaId, KrediId, CekSenetId, GeriDonusId, SubeId1
    HesapTuru,                        // 'B' banka, 'V' kredi kartı
    0, YerId, BelgeNo,                // Yer, YerId, BelgeNo
    Windows_HizliGiris,               // GirisKaynak — Utablo'da global = 5
    False,                            // R
    EkstredeKullan));
end;

procedure TbankaHesapGirisdlg.btnF5KaydetClick(Sender: TObject);
var
  Tur, RehId, MasId, BankaMasrafMerkeziId, IdBanka, IdKK: Integer;
  YeniBelgeNo, OzelKodDeger, IdListe: string;
  SatirBasiIdx, k: Integer;
  MukerrerVar: Boolean;
  Borc, Alacak, DovizTutar, MasrafTutar: Currency;
  DovizKod: string;
  Tarih: TDateTime;
  Aciklama, HesapKuru: string;
  EkKullan: Boolean;
  HedefHesapAdi: string;
begin
  if FHESAPID = 0 then begin
    Application.MessageBox('Önce banka hesabı seçiniz.', PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
    Exit;
  end;
  if dxMemData1.RecordCount = 0 then begin
    Application.MessageBox(PChar(DGiris_yapin), PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
    Exit;
  end;

  // Banka masraf merkezi opsiyon defaultu (UNakitDlg satır 365 ile aynı kaynak)
  BankaMasrafMerkeziId := StrToIntDef(Tablo.GENINI.ReadString(Ops_OpsiyonBanka_MasrafMerkezi, '0'), 0);

  FSatirEkleniyor := True;   // Delete/Next sırasında grid focus eventleri paneli bozmasın
  try
  dxMemData1.First;
  while not dxMemData1.Eof do begin
    // Excel'den içeri alındıysa (ONAY kolonu görünürse), sadece işaretli satırları kaydet
    if cxGrid1DBTableView1ONAY.Visible and not dxMemData1ONAY.AsBoolean then begin
      dxMemData1.Next;
      Continue;
    end;

    Tur         := dxMemData1TURID.AsInteger;
    Tarih       := dxMemData1TARIH.AsDateTime;
    // İçeri alınan (MT940/Excel) satırlarda kaynak belge no -> KASA.OZELKOD ('NONREF' = boş).
    // Manuel satırlarda BELGENO zaten bizim makbuz serimizden -> OZELKOD'a taşınmaz.
    if dxMemData1ICERIALINDI.AsBoolean then begin
      OzelKodDeger := Copy(Trim(dxMemData1BELGENO.AsString), 1, 20);
      if SameText(OzelKodDeger, 'NONREF') then OzelKodDeger := '';
    end else
      OzelKodDeger := '';
    Aciklama    := dxMemData1ACIKLAMA.AsString;
    HesapKuru   := dxMemData1PBIRIMI.AsString;
    EkKullan    := dxMemData1EKSTREDE_KULLAN.AsBoolean;
    MasrafTutar := dxMemData1KOMISYON.AsCurrency;

    // Yön: borç/alacak — banka hesabı açısından
    //   Para çıkıyor (Giden Havale, Masraf Ödeme)            → BORC
    //   Para giriyor (Gelen Havale, Gelir Tahsilatı)         → ALACAK
    // (Para Yat/Çek, KK Ödeme, Hesaplar Arası kendi blokunda ele alınıyor)
    case Tur of
      TURID_GIDENHAVALE,
      TURID_PARAYATIRMA,
      TURID_MASRAFODEME,
      TURID_KREDIODEME:
        begin Borc := dxMemData1TUTAR.AsCurrency; Alacak := 0; end;
      TURID_GELENHAVALE,
      TURID_GELIRTAHSILATI,
      TURID_PARACEKME,
      TURID_KKODEME,
      TURID_HESAPLARARASI:
        begin Borc := 0; Alacak := dxMemData1TUTAR.AsCurrency; end;
    else
      begin Borc := 0; Alacak := 0; end;
    end;

    // Cari ve masraf ID — Tür'e göre SECIMID hangi alana yazılacak
    RehId := 0; MasId := 0;
    case Tur of
      TURID_GELENHAVALE,
      TURID_GIDENHAVALE:
        begin
          RehId := dxMemData1SECIMID.AsInteger;
          // Gelen/Giden Havale'de seçilen Gelir/Masraf Kalemi de KASA.MASRAFID olarak yazılır
          MasId := dxMemData1MASRAFID.AsInteger;
        end;
      TURID_MASRAFODEME,
      TURID_GELIRTAHSILATI: MasId := dxMemData1SECIMID.AsInteger;
    end;

    // Karşılığı: işaretliyse döviz tutarı/tipi farklı, değilse hesabın kendi dövizi
    if dxMemData1KARSILIGI.AsBoolean then begin
      DovizTutar := dxMemData1DOVIZ_TUTARI.AsCurrency;
      DovizKod   := dxMemData1DOVIZ_TIPI.AsString;
    end else begin
      DovizTutar := dxMemData1TUTAR.AsCurrency;
      DovizKod   := HesapKuru;
    end;

    // MÜKERRER kontrol:
    //  - kaynak belge no (OZELKOD) doluysa: OZELKOD + tarih + tutar (kesin anahtar)
    //  - yoksa: aynı gün + tür + tutar (+cari). Borc=Alacak=0 türlerde atlanır.
    MukerrerVar := False;
    if OzelKodDeger <> '' then
      MukerrerVar := Veritabani.VeriVarMi(Tablo.FDCnn,
        'SELECT '+DbUst(1)+'ID FROM KASA WHERE HESAPID = ' + IntToStr(FHESAPID) +
        ' AND HESAPTURU = ''B'' AND OZELKOD = ' + QuotedStr(OzelKodDeger) +
        ' AND CAST(ISLEMTARIHI AS date) = ''' + FormatDateTime('yyyy-mm-dd', Tarih) + '''' +
        ' AND BORC = ' + StringReplace(CurrToStr(Borc), ',', '.', [rfReplaceAll]) +
        ' AND ALACAK = ' + StringReplace(CurrToStr(Alacak), ',', '.', [rfReplaceAll])+' '+DbSinir(1), [], [])
    else if Borc + Alacak > 0 then
      MukerrerVar := Veritabani.VeriVarMi(Tablo.FDCnn,
        'SELECT '+DbUst(1)+'ID FROM KASA WHERE HESAPID = ' + IntToStr(FHESAPID) +
        ' AND HESAPTURU = ''B'' AND TUR = ' + IntToStr(Tur) +
        ' AND CAST(ISLEMTARIHI AS date) = ''' + FormatDateTime('yyyy-mm-dd', Tarih) + '''' +
        ' AND BORC = ' + StringReplace(CurrToStr(Borc), ',', '.', [rfReplaceAll]) +
        ' AND ALACAK = ' + StringReplace(CurrToStr(Alacak), ',', '.', [rfReplaceAll]) +
        IfThen(RehId > 0, ' AND REHBERID = ' + IntToStr(RehId), '')+' '+DbSinir(1), [], []);
    if MukerrerVar then
      if Application.MessageBox(PChar('Bu hareket zaten kayıtlı görünüyor:' + sLineBreak +
           FormatDateTime('dd.mm.yyyy', Tarih) + '   ' + dxMemData1SECIM.AsString + '   ' +
           CurrToStr(dxMemData1TUTAR.AsCurrency) + sLineBreak +
           'Yine de kaydedilsin mi? (MÜKERRER kayıt riski!)'),
           PChar(Onay), MB_ICONWARNING + MB_YESNO) <> IDYES then begin
        dxMemData1.Next;
        Continue;
      end;

    // BELGENO: içeri alınan satırlarda bizim makbuz serimizden ÜRET (kaynak belge no
    // OZELKOD'a gitti); manuel satırlarda kutudaki no (zaten seri) korunur.
    if dxMemData1ICERIALINDI.AsBoolean then
      YeniBelgeNo := SiradakiMakbuzNumarasi(Tur)
    else
      YeniBelgeNo := dxMemData1BELGENO.AsString;
    SatirBasiIdx := FKayitIDleri.Count;

    if Tur in [TURID_KKODEME, TURID_KKODEMEIADE] then begin
      // KK Ödeme / İade: banka ve kredi kartı arasında karşılıklı bağlı 2 KASA satırı.
      if Tur = TURID_KKODEME then begin
        if Aciklama = '' then
          Aciklama := FHesapAdi + ' > ' + dxMemData1SECIM.AsString;

        // Ödeme: banka çıkışı, kredi kartı girişi.
        IdBanka := KasaSatirYaz(Tur, FHESAPID, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                dxMemData1TUTAR.AsCurrency, 0, DovizTutar,
                                EkKullan, 'B', -1, YeniBelgeNo);
        IdKK := KasaSatirYaz(Tur, dxMemData1SECIMID.AsInteger, 0, 0, Tarih, Aciklama,
                             HesapKuru, DovizKod,
                             0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                             EkKullan, 'V', IdBanka, YeniBelgeNo);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'UPDATE KASA SET GERIDONUSID = ' + IntToStr(IdKK) + ' WHERE ID = ' + IntToStr(IdBanka),
          [], []);
      end else begin
        if Aciklama = '' then
          Aciklama := dxMemData1SECIM.AsString + ' > ' + FHesapAdi;

        // İade: kredi kartı çıkışı, banka girişi.
        IdKK := KayitIzle(Tablo.KasaKaydet(
          Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
          0, Aciklama, dxMemData1SECIMID.AsInteger, HesapKuru, DovizKod, 0,
          dxMemData1TUTAR.AsCurrency, 0, DovizTutar,
          -1, -1, -1, 0, -1, -1, 'V',
          0, 0, YeniBelgeNo, 1, False, EkKullan));
        IdBanka := KayitIzle(Tablo.KasaKaydet(
          Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
          0, Aciklama, FHESAPID, HesapKuru, DovizKod, 0,
          0, dxMemData1TUTAR.AsCurrency, DovizTutar,
          -1, -1, -1, 0, IdKK, -1, 'B',
          0, 0, YeniBelgeNo, 1, False, EkKullan));
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'UPDATE KASA SET GERIDONUSID = ' + IntToStr(IdBanka) + ' WHERE ID = ' + IntToStr(IdKK),
          [], []);
      end;
    end else if Tur = TURID_POSAKTARIM then begin
      // POS Aktarım: POS çıkışı, bağlı banka girişi ve varsa komisyon satırı.
      var QPos: TFDQuery := TFDQuery.Create(nil);
      var PosAdi: string := '';
      var PosKuru: string := '';
      var PosBankaHesapAdi: string := '';
      var PosBankaKuru: string := '';
      var PosBankaHesapID: Integer := 0;
      var KomisyonMasrafID: Integer := 0;
      var MasrafCikis: Integer := 1;
      var IdPos: Integer := 0;
      var AktarimTutari: Currency := dxMemData1TUTAR.AsCurrency;
      var BankayaGiren: Currency := AktarimTutari;
      var PosAnaBorc: Currency := AktarimTutari;
      var PosAnaDoviz: Currency := DovizTutar;

      try
        QPos.Connection := Tablo.FDCnn;
        QPos.SQL.Text :=
          'SELECT P.ADI, P.KUR AS POSKUR, P.BANKAHESAPID, BH.HESAPADI, BH.KUR AS BANKAKUR, ' +
          'P.KOMISYONMASRAFMERKEZI, P.MASRAFCIKIS ' +
          'FROM POS P INNER JOIN BANKAHESAPLAR BH ON BH.ID=P.BANKAHESAPID ' +
          'WHERE P.ID=:POSID AND P.DURUM=1 AND BH.DURUM=1 ' +
          'AND P.KUR=BH.KUR';
        QPos.ParamByName('POSID').AsInteger := dxMemData1SECIMID.AsInteger;
        QPos.Open;
        if QPos.IsEmpty then
          raise Exception.Create('Seçilen POS veya POS''a bağlı banka hesabı aktif değil.');

        PosAdi := QPos.FieldByName('ADI').AsString;
        PosKuru := QPos.FieldByName('POSKUR').AsString;
        PosBankaHesapID := QPos.FieldByName('BANKAHESAPID').AsInteger;
        PosBankaHesapAdi := QPos.FieldByName('HESAPADI').AsString;
        PosBankaKuru := QPos.FieldByName('BANKAKUR').AsString;
        KomisyonMasrafID := QPos.FieldByName('KOMISYONMASRAFMERKEZI').AsInteger;
        MasrafCikis := QPos.FieldByName('MASRAFCIKIS').AsInteger;
      finally
        QPos.Free;
      end;

      if Aciklama = '' then
        Aciklama := PosAdi + ' > ' + PosBankaHesapAdi;

      // MASRAFCIKIS=2 ise komisyon POS'tan ayrıca düşer ve bankaya net tutar girer.
      if MasrafCikis = 2 then begin
        BankayaGiren := AktarimTutari - MasrafTutar;
        PosAnaBorc := BankayaGiren;
        if AktarimTutari <> 0 then
          PosAnaDoviz := DovizTutar * BankayaGiren / AktarimTutari;
      end;

      IdPos := KayitIzle(Tablo.KasaKaydet(
        Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
        0, Aciklama, dxMemData1SECIMID.AsInteger, PosKuru, CariDoviz, 0,
        PosAnaBorc, 0, PosAnaDoviz,
        -1, -1, -1, 0, -1, -1, 'P',
        0, 0, YeniBelgeNo, 1, False, EkKullan));

      // MASRAFCIKIS=1: komisyon bağlı banka hesabından gider.
      if (MasrafTutar > 0) and (MasrafCikis <> 2) then
        KayitIzle(Tablo.KasaKaydet(
          Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
          0, Aciklama, PosBankaHesapID, PosBankaKuru, CariDoviz, KomisyonMasrafID,
          MasrafTutar, 0, MasrafTutar,
          -1, -1, -1, -1, IdPos, -1, 'B',
          0, 0, YeniBelgeNo, 1, False, EkKullan));

      IdBanka := KayitIzle(Tablo.KasaKaydet(
        Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
        0, Aciklama, PosBankaHesapID, PosBankaKuru, CariDoviz, 0,
        0, BankayaGiren, PosAnaDoviz,
        -1, -1, -1, -1, IdPos, -1, 'B',
        0, 0, YeniBelgeNo, 1, False, EkKullan));

      // MASRAFCIKIS=2: komisyon POS hesabından ayrıca düşer.
      if (MasrafTutar > 0) and (MasrafCikis = 2) then
        KayitIzle(Tablo.KasaKaydet(
          Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
          0, Aciklama, dxMemData1SECIMID.AsInteger, PosKuru, CariDoviz, KomisyonMasrafID,
          MasrafTutar, 0, MasrafTutar,
          -1, -1, -1, -1, IdPos, -1, 'P',
          0, 0, YeniBelgeNo, 1, False, EkKullan));

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'UPDATE KASA SET GERIDONUSID = ' + IntToStr(IdBanka) + ' WHERE ID = ' + IntToStr(IdPos),
        [], []);
    end else if (Tur = TURID_PARAYATIRMA) or (Tur = TURID_PARACEKME) then begin
      // Para Yatırma / Çekme — kasa <-> banka arasında karşılıklı bağlı 2 satır
      // (DB örneği TUR=41 Para Yatırma: ID 729693 kasa BORC + 729694 banka ALACAK)

      // ACIKLAMA otomatik (legacy format) — yön Tür'e göre değişir
      if Aciklama = '' then begin
        if Tur = TURID_PARAYATIRMA then
          Aciklama := dxMemData1SECIM.AsString + ' > ' + FHesapAdi
        else
          Aciklama := FHesapAdi + ' > ' + dxMemData1SECIM.AsString;
      end;

      if Tur = TURID_PARAYATIRMA then begin
        // Para Yatırma — para kasadan bankaya. Kasa BORC, Banka ALACAK
        IdBanka := KasaSatirYaz(Tur, dxMemData1SECIMID.AsInteger, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                dxMemData1TUTAR.AsCurrency, 0, DovizTutar,
                                EkKullan, 'K', -1, YeniBelgeNo);
        IdKK    := KasaSatirYaz(Tur, FHESAPID, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                                EkKullan, 'B', IdBanka, YeniBelgeNo);
      end else begin
        // Para Çekme — para bankadan kasaya. Banka BORC, Kasa ALACAK
        IdBanka := KasaSatirYaz(Tur, FHESAPID, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                dxMemData1TUTAR.AsCurrency, 0, DovizTutar,
                                EkKullan, 'B', -1, YeniBelgeNo);
        IdKK    := KasaSatirYaz(Tur, dxMemData1SECIMID.AsInteger, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                                EkKullan, 'K', IdBanka, YeniBelgeNo);
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'UPDATE KASA SET GERIDONUSID = ' + IntToStr(IdKK) + ' WHERE ID = ' + IntToStr(IdBanka),
        [], []);
    end else if Tur in [TURID_BANKADANDOVIZAL, TURID_BANKADANDOVIZSAT,
                        TURID_BANKAARBITRAJ] then begin
      // Döviz Al/Sat ve Arbitraj: üstteki kaynak hesaptan çıkış, seçilen hesaba giriş.
      var HedefDoviz: string := dxMemData1DOVIZ_TIPI.AsString;
      var KaynakKurDegeri: Currency;
      var YerelDovizTutar: Currency;

      if HesapKuru = CariDoviz then
        KaynakKurDegeri := 1
      else
        KaynakKurDegeri := DovizKuruBul(FormatDateTime('yyyy-mm-dd', Tarih), HesapKuru,
          Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));
      YerelDovizTutar := dxMemData1TUTAR.AsCurrency * KaynakKurDegeri;

      HedefHesapAdi := '';
      Tablo.TablodanSorguAc(1,
        'SELECT HESAPADI FROM BANKAHESAPLAR WHERE ID = ' + IntToStr(dxMemData1SECIMID.AsInteger));
      if not Tablo.Query1.IsEmpty then
        HedefHesapAdi := Tablo.Query1.FieldByName('HESAPADI').AsString;
      if Aciklama = '' then
        Aciklama := FHesapAdi + ' > ' + HedefHesapAdi;

      IdBanka := KayitIzle(Tablo.KasaKaydet(
        Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
        0, Aciklama, FHESAPID, HesapKuru, CariDoviz, 0,
        dxMemData1TUTAR.AsCurrency, 0, YerelDovizTutar,
        -1, -1, -1, 0, -1, -1, 'B',
        0, 0, YeniBelgeNo, 1, False, EkKullan));
      IdKK := KayitIzle(Tablo.KasaKaydet(
        Tur, RecodeMillisecond(Tarih, 0), RecodeMillisecond(Tarih, 0),
        0, Aciklama, dxMemData1SECIMID.AsInteger, HedefDoviz, CariDoviz, 0,
        0, dxMemData1DOVIZ_TUTARI.AsCurrency, YerelDovizTutar,
        -1, -1, -1, 0, IdBanka, -1, 'B',
        0, 0, YeniBelgeNo, 1, False, EkKullan));
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'UPDATE KASA SET GERIDONUSID = ' + IntToStr(IdKK) + ' WHERE ID = ' + IntToStr(IdBanka),
        [], []);
    end else if Tur = TURID_HESAPLARARASI then begin
      // Hesaplar Arası Transfer — kaynak banka -> hedef banka, karşılıklı bağlı 2 satır
      // DB örneği: ID 729715 (kaynak BORC) + 729716 (hedef ALACAK), ikisi HESAPTURU='B'.

      // Hedef hesabın HESAPADI'si (ACIKLAMA otomatik format için)
      HedefHesapAdi := '';
      Tablo.TablodanSorguAc(1,
        'SELECT HESAPADI FROM BANKAHESAPLAR WHERE ID = ' + IntToStr(dxMemData1SECIMID.AsInteger));
      if Tablo.Query1.RecordCount > 0 then
        HedefHesapAdi := Tablo.Query1.FieldByName('HESAPADI').AsString;

      // ACIKLAMA otomatik (legacy format) — kullanıcı yazmadıysa
      if Aciklama = '' then
        Aciklama := FHesapAdi + ' > ' + HedefHesapAdi;

      // Kaynak satırı (HESAPTURU='B', BORC=Tutar) — para kaynak hesaptan çıkıyor
      IdBanka := KasaSatirYaz(Tur, FHESAPID, 0, 0, Tarih, Aciklama,
                              HesapKuru, DovizKod,
                              dxMemData1TUTAR.AsCurrency, 0, DovizTutar,
                              EkKullan, 'B', -1, YeniBelgeNo);
      // Hedef satırı (HESAPTURU='B', ALACAK=Tutar, GERIDONUSID=kaynak) — para hedef hesaba giriyor
      IdKK    := KasaSatirYaz(Tur, dxMemData1SECIMID.AsInteger, 0, 0, Tarih, Aciklama,
                              HesapKuru, DovizKod,
                              0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                              EkKullan, 'B', IdBanka, YeniBelgeNo);
      // Kaynak satırının GERIDONUSID'i hedef satırın ID'sine güncellensin (karşılıklı bağ)
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'UPDATE KASA SET GERIDONUSID = ' + IntToStr(IdKK) + ' WHERE ID = ' + IntToStr(IdBanka),
        [], []);

      // Banka masrafı varsa kaynak hesaba ayrı BORC satırı (BELGENO Giden Havale serisinden,
      // GERIDONUSID + YERID transferin kaynak satırının ID'sine bağlı)
      if MasrafTutar > 0 then
        KasaSatirYaz(32, FHESAPID, 0, BankaMasrafMerkeziId, Tarih,
                     'Banka Masrafı - ' + Aciklama,
                     HesapKuru, HesapKuru,
                     MasrafTutar, 0, MasrafTutar,
                     EkKullan, 'B', IdBanka, SiradakiMakbuzNumarasi(TURID_GIDENHAVALE),
                     IdBanka);
    end else begin
      // 1) Ana KASA satırı
      //    Masraf Ödeme     → KASA TUR=32 (Giden Havale ile aynı), MASRAFID dolu
      //    Gelir Tahsilatı  → KASA TUR=22 (Gelen Havale ile aynı), MASRAFID dolu, BELGENO auto
      //    Gelen/Giden Havale → BELGENO otomatik üretilir
      IdBanka := 0;
      if Tur = TURID_MASRAFODEME then
        IdBanka := KasaSatirYaz(TURID_GIDENHAVALE, FHESAPID, RehId, MasId, Tarih, Aciklama,
                                HesapKuru, DovizKod, Borc, Alacak, DovizTutar, EkKullan,
                                'B', -1, dxMemData1BELGENO.AsString)
      else if Tur = TURID_GELIRTAHSILATI then
        IdBanka := KasaSatirYaz(TURID_GELENHAVALE, FHESAPID, RehId, MasId, Tarih, Aciklama,
                                HesapKuru, DovizKod, Borc, Alacak, DovizTutar, EkKullan,
                                'B', -1, dxMemData1BELGENO.AsString)
      else if (Tur = TURID_GELENHAVALE) or (Tur = TURID_GIDENHAVALE) then begin
        IdBanka := KasaSatirYaz(Tur, FHESAPID, RehId, MasId, Tarih, Aciklama,
                                HesapKuru, DovizKod, Borc, Alacak, DovizTutar, EkKullan,
                                'B', -1, dxMemData1BELGENO.AsString);
        // Gelen/Giden Havale için: DURUM=0, KASA=0, FATURAID=-1, CEKSENETID=-1 enforce
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'UPDATE KASA SET DURUM=0, KASA=0, FATURAID=-1, CEKSENETID=-1 WHERE ID=' + IntToStr(IdBanka),
          [], []);
      end
      else if Tur = TURID_KREDIODEME then begin
        // Kredi Ödeme (UKasaWizard 58 deseni): anapara ve faiz için dört KASA satırı.
        // GERIDONUSID halkası: kredi anapara -> banka anapara -> banka faiz
        // -> kredi faiz -> kredi anapara.
        var KrediID: Integer := dxMemData1SECIMID.AsInteger;
        var DetayID: Integer := dxMemData1KREDIDETAYID.AsInteger;
        var KrediBelgeNo: string := dxMemData1BELGENO.AsString;
        var TarihSn: TDateTime := RecodeMillisecond(Tarih, 0);
        var Anapara: Currency := 0;
        var Faiz: Currency := 0;
        var AnaparaDoviz: Currency := 0;
        var FaizDoviz: Currency := 0;
        var ToplamTaksit: Currency := 0;
        var FaizMasrafID: Integer := 0;
        var KrediProjeID: Integer := 0;
        var IdFaizBanka: Integer := 0;
        var IdFaizKredi: Integer := 0;
        var TopluMakbuzNo: string := SiradakiMakbuzNumarasi(TURID_KREDIODEME);
        var QKredi: TFDQuery := TFDQuery.Create(nil);

        try
          if (KrediID <= 0) or (DetayID <= 0) then
            raise Exception.Create('Kredi ödeme kaydı için kredi ve taksit seçilmelidir.');

          QKredi.Connection := Tablo.FDCnn;
          QKredi.SQL.Text :=
            'SELECT P.ANAPARA, FAIZTUTARI=ISNULL(P.FAIZ,0)+ISNULL(P.KKDF,0)+ISNULL(P.BSMV,0), ' +
            'K.FAIZMASRAFID, K.PROJEID ' +
            'FROM PLANKREDI P INNER JOIN KREDILER K ON K.ID=P.KREDIID ' +
            'WHERE P.ID=:DETAYID AND P.KREDIID=:KREDIID';
          QKredi.ParamByName('DETAYID').AsInteger := DetayID;
          QKredi.ParamByName('KREDIID').AsInteger := KrediID;
          QKredi.Open;
          if QKredi.IsEmpty then
            raise Exception.Create('Seçilen kredi taksiti bulunamadı.');

          Anapara := QKredi.FieldByName('ANAPARA').AsCurrency;
          Faiz := QKredi.FieldByName('FAIZTUTARI').AsCurrency;
          FaizMasrafID := QKredi.FieldByName('FAIZMASRAFID').AsInteger;
          KrediProjeID := QKredi.FieldByName('PROJEID').AsInteger;
          ToplamTaksit := Anapara + Faiz;

          if ToplamTaksit > 0.01 then begin
            AnaparaDoviz := DovizTutar * Anapara / ToplamTaksit;
            FaizDoviz := DovizTutar * Faiz / ToplamTaksit;
          end;

          // 1) Kredi hesabına anapara
          IdKK := KayitIzle(Tablo.KasaKaydet(
            TURID_KREDIODEME, TarihSn, TarihSn, 0, Aciklama + '(Anapara)',
            KrediID, HesapKuru, DovizKod, 0,
            0, Anapara, AnaparaDoviz,
            -1, DetayID, KrediID, -1, -1, -1, 'R',
            TabNo_PLANKREDI, DetayID, KrediBelgeNo,
            Windows_HizliGiris, False, EkKullan));

          // 2) Bankadan anapara çıkışı
          IdBanka := KayitIzle(Tablo.KasaKaydet(
            TURID_KREDIODEME, TarihSn, TarihSn, 0, Aciklama,
            FHESAPID, HesapKuru, DovizKod, 0,
            Anapara, 0, AnaparaDoviz,
            -1, DetayID, KrediID, -1, -1, -1, 'B',
            TabNo_PLANKREDI, DetayID, KrediBelgeNo,
            Windows_HizliGiris, False, EkKullan));

          if Faiz > 0.01 then begin
            // 3) Bankadan faiz/masraf çıkışı
            IdFaizBanka := KayitIzle(Tablo.KasaKaydet(
              TURID_KREDIODEME, TarihSn, TarihSn, 0, Aciklama + ' (Faiz)',
              FHESAPID, HesapKuru, DovizKod, FaizMasrafID,
              Faiz, 0, FaizDoviz,
              -1, DetayID, KrediID, -1, -1, -1, 'B',
              TabNo_PLANKREDI, DetayID, KrediBelgeNo,
              Windows_HizliGiris, False, EkKullan));

            // 4) Kredi hesabına faiz
            IdFaizKredi := KayitIzle(Tablo.KasaKaydet(
              TURID_KREDIODEME, TarihSn, TarihSn, 0, Aciklama + '(Faiz)',
              KrediID, HesapKuru, DovizKod, 0,
              0, Faiz, FaizDoviz,
              -1, DetayID, KrediID, -1, -1, -1, 'R',
              TabNo_PLANKREDI, DetayID, KrediBelgeNo,
              Windows_HizliGiris, False, EkKullan));

            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
              'UPDATE KASA SET BELGENO=''' + TopluMakbuzNo + ''', GERIDONUSID=' + IntToStr(IdBanka) +
              ' WHERE ID=' + IntToStr(IdKK) + '; ' +
              'UPDATE KASA SET BELGENO=''' + TopluMakbuzNo + ''', GERIDONUSID=' + IntToStr(IdFaizBanka) +
              ' WHERE ID=' + IntToStr(IdBanka) + '; ' +
              'UPDATE KASA SET BELGENO=''' + TopluMakbuzNo + ''', GERIDONUSID=' + IntToStr(IdFaizKredi) +
              IfThen(KrediProjeID > 0, ', PROJEID=' + IntToStr(KrediProjeID), '') +
              ' WHERE ID=' + IntToStr(IdFaizBanka) + '; ' +
              'UPDATE KASA SET BELGENO=''' + TopluMakbuzNo + ''', GERIDONUSID=' + IntToStr(IdKK) +
              IfThen(KrediProjeID > 0, ', PROJEID=' + IntToStr(KrediProjeID), '') +
              ' WHERE ID=' + IntToStr(IdFaizKredi),
              [], []);
          end else
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
              'UPDATE KASA SET BELGENO=''' + TopluMakbuzNo + ''', GERIDONUSID=' + IntToStr(IdBanka) +
              ' WHERE ID=' + IntToStr(IdKK) + '; ' +
              'UPDATE KASA SET BELGENO=''' + TopluMakbuzNo + ''', GERIDONUSID=' + IntToStr(IdKK) +
              ' WHERE ID=' + IntToStr(IdBanka),
              [], []);
        finally
          QKredi.Free;
        end;

        // Taksiti ödendi olarak işaretle
        if DetayID > 0 then
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
            'UPDATE PLANKREDI SET ODENMIS=1 WHERE ID = ' + IntToStr(DetayID) +
            ' AND KREDIID = ' + IntToStr(KrediID),
            [], []);
      end
      else
        IdBanka := KasaSatirYaz(Tur, FHESAPID, RehId, MasId, Tarih, Aciklama,
                                HesapKuru, DovizKod, Borc, Alacak, DovizTutar, EkKullan,
                                'B', -1, YeniBelgeNo);

      // 2) Banka masrafı varsa ayrı satır (UNakitDlg satır 1144-1149 deseni)
      //    Masraf banka hesabından çıkıyor → BORC, BELGENO Giden Havale serisinden,
      //    YERID = ana satırın ID'si (Giden Havale / Masraf Ödeme / Gelir Tahsilatı vs.)
      if MasrafTutar > 0 then
        KasaSatirYaz(32, FHESAPID, 0, BankaMasrafMerkeziId, Tarih,
                     'Banka Masrafı - ' + Aciklama,
                     HesapKuru, HesapKuru,
                     MasrafTutar, 0, MasrafTutar,
                     EkKullan, 'B', -1, SiradakiMakbuzNumarasi(TURID_GIDENHAVALE),
                     IdBanka);
    end;

    // Kaynak belge no'yu bu satırda yazılan KASA kayıtlarının OZELKOD'una işle
    if (OzelKodDeger <> '') and (FKayitIDleri.Count > SatirBasiIdx) then begin
      IdListe := '';
      for k := SatirBasiIdx to FKayitIDleri.Count - 1 do begin
        if IdListe <> '' then IdListe := IdListe + ',';
        IdListe := IdListe + IntToStr(FKayitIDleri[k]);
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'UPDATE KASA SET OZELKOD = ' + QuotedStr(OzelKodDeger) +
        ' WHERE ID IN (' + IdListe + ')', [], []);
    end;

    // Kaydedilen satır grid'den HEMEN düşer → ikinci F5'te tekrar kaydedilemez.
    dxMemData1.Delete;
  end;
  finally
    FSatirEkleniyor := False;
  end;

  Application.MessageBox(PChar(DKayit_yapildi), PChar(Kaydet), MB_ICONINFORMATION + MB_OK);
  if dxMemData1.RecordCount = 0 then
    cxGrid1DBTableView1ONAY.Visible := False;
  FDuzenlemeKipinde := False;
end;

{ ---------- Excel/CSV İçeri Al (PanelUst çift tık) ---------- }

procedure TbankaHesapGirisdlg.HareketleriIceriAl(const DosyaYolu: string);
var
  Liste: TBankaHareketListesi;
  Satir: TBankaHareketSatiri;
  Tur, RehId, Confidence: Integer;
  RehAd, OnerilenAciklama, Uzanti: string;
  Basarili: Boolean;
  Tipi: TBankaTipi;
  Konf: TBankaKonfig;
begin
  Liste := TBankaHareketListesi.Create;
  try
    // Banka tipini dosyadan tespit et, belirsizse kullanıcıya sor
    Tipi := BankaTipiTespit(DosyaYolu);
    Tipi := BankaTipiSor(Tipi);
    if Tipi = btGenerik then begin
      // Kullanıcı seçmedi/iptal etti
      Exit;
    end;
    FBankaTipi := Tipi;     // Manuel seçimler için sonradan kullanılır
    Konf := BankaKonfigGetir(Tipi);

    Uzanti := LowerCase(ExtractFileExt(DosyaYolu));
    if Uzanti = '.csv' then
      Basarili := OkuCsv(DosyaYolu, Konf, Liste)
    else if (Uzanti = '.xls') or (Uzanti = '.xlsx') then
      Basarili := OkuXls(DosyaYolu, Konf, Liste)
    else begin
      Application.MessageBox('Desteklenmeyen dosya formatı. .csv veya .xls seçin.',
                             PChar(Hata), MB_ICONWARNING + MB_OK);
      Exit;
    end;

    if not Basarili then begin
      Application.MessageBox('Dosya okunamadı veya tanınmayan format.',
                             PChar(Hata), MB_ICONWARNING + MB_OK);
      Exit;
    end;

    if Liste.Count = 0 then begin
      Application.MessageBox('Dosyada banka hareketi bulunamadı.',
                             PChar(Hata), MB_ICONINFORMATION + MB_OK);
      Exit;
    end;

    // Analiz et ve grid'e ekle
    FSatirEkleniyor := True;
    try
      for Satir in Liste do begin
        SatirAnalizEt(Satir, Tipi, Tur, RehId, RehAd, OnerilenAciklama, Confidence);

        dxMemData1.Append;
        dxMemData1TARIH.AsDateTime    := Satir.Tarih;
        dxMemData1TURID.AsInteger     := Tur;
        // Tür açıklaması cbTur'dan al
        dxMemData1TUR.AsString        := '';
        // (Tur değerine göre cbTur item description bulup yaz)
        var i: Integer;
        for i := 0 to cbTur.Properties.Items.Count - 1 do
          if Integer(cbTur.Properties.Items[i].Value) = Tur then begin
            dxMemData1TUR.AsString := cbTur.Properties.Items[i].Description;
            Break;
          end;
        dxMemData1SECIMID.AsInteger   := RehId;
        dxMemData1SECIM.AsString      := RehAd;
        dxMemData1TUTAR.AsCurrency    := Abs(Satir.Tutar);
        dxMemData1PBIRIMI.AsString    := FBankaDovizi;
        dxMemData1KOMISYON.AsCurrency := 0;
        dxMemData1ACIKLAMA.AsString   := OnerilenAciklama;
        dxMemData1BELGENO.AsString    := Satir.DekontNo;
        dxMemData1ICERIALINDI.AsBoolean := True;
        dxMemData1KARSILIGI.AsBoolean := False;
        dxMemData1DOVIZ_TUTARI.AsCurrency := 0;
        dxMemData1DOVIZ_TIPI.AsString     := '';
        dxMemData1KUR.AsCurrency          := 0;
        dxMemData1EKSTREDE_KULLAN.AsBoolean := True;
        dxMemData1MASRAFID.AsInteger      := 0;
        dxMemData1MASRAFKALEMI.AsString   := '';
        dxMemData1CONFIDENCE.AsInteger    := Confidence;
        dxMemData1ONAY.AsBoolean          := False;
        dxMemData1.Post;
      end;
    finally
      FSatirEkleniyor := False;
    end;

    // Dosya yüklendi → Onay kolonunu görünür yap
    cxGrid1DBTableView1ONAY.Visible := True;

    Application.MessageBox(PChar(IntToStr(Liste.Count) + ' satır içeri alındı.' + sLineBreak +
                                 'Yeşil = yüksek güven, Sarı = kontrol gerekir, Pembe = manuel düzeltin.'),
                           'İçeri Al', MB_ICONINFORMATION + MB_OK);
  finally
    Liste.Free;
  end;
end;

{ ---------- Banka konfigürasyonu ---------- }

function TbankaHesapGirisdlg.BankaKoduGetir(Tipi: TBankaTipi): string;
// TBankaTipi enum → DB içindeki BANKA_KODU string'i
begin
  case Tipi of
    btGaranti:    Result := 'GARANTI';
    btZiraat:     Result := 'ZIRAAT';
    btIsBank:     Result := 'ISBANK';
    btAkbank:     Result := 'AKBANK';
    btYapikredi:  Result := 'YAPIKREDI';
    btHalkbank:   Result := 'HALKBANK';
    btVakifbank:  Result := 'VAKIFBANK';
    btQNB:        Result := 'QNB';
    btING:        Result := 'ING';
  else
    Result := 'GENERIK';
  end;
end;

function TbankaHesapGirisdlg.BankaKonfigGetir(Tipi: TBankaTipi): TBankaKonfig;
// Banka-bazlı kolon haritalama. Yeni banka eklerken sadece bu listeye yeni case ekleyin.
begin
  Result.Tipi := Tipi;
  Result.BankaKodu := BankaKoduGetir(Tipi);
  case Tipi of
    btGaranti:
      begin
        Result.Adi := 'Garanti BBVA';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'GARANTI';   // "T. GARANTİ BANKASI A.Ş."
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := 3;
        Result.KolTutar := 4; Result.KolBakiye := 5; Result.KolDekontNo := 6;
      end;
    btZiraat:
      begin
        Result.Adi := 'Ziraat Bankası';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'ZIRAAT';
        // Ziraat formatı için TODO — başlangıç tahmini, gerçek dosya görülünce ayarlanmalı
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
    btIsBank:
      begin
        Result.Adi := 'İş Bankası';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'IŞ BANKASI';
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
    btAkbank:
      begin
        Result.Adi := 'Akbank';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'AKBANK';
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
    btYapikredi:
      begin
        Result.Adi := 'Yapı Kredi';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'YAPI KREDI';
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
    btHalkbank:
      begin
        Result.Adi := 'Halkbank';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'HALKBANK';
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
    btVakifbank:
      begin
        Result.Adi := 'Vakıfbank';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'VAKIFBANK';
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
    btQNB:
      begin
        Result.Adi := 'QNB Finansbank';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'QNB';
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
    btING:
      begin
        Result.Adi := 'ING';
        Result.HeaderAnahtar := 'Tarih';
        Result.BankaTespitAnahtar := 'ING';
        Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
        Result.KolTutar := 3; Result.KolBakiye := 4; Result.KolDekontNo := 5;
      end;
  else
    begin
      Result.Adi := 'Generik';
      Result.HeaderAnahtar := 'Tarih';
      Result.BankaTespitAnahtar := '';
      Result.KolTarih := 1; Result.KolAciklama := 2; Result.KolEtiket := -1;
      Result.KolTutar := 3; Result.KolBakiye := -1; Result.KolDekontNo := -1;
    end;
  end;
end;

function TbankaHesapGirisdlg.BankaTipiTespit(const Dosya: string): TBankaTipi;
// Dosyanın ilk birkaç KB'ını okuyup banka isminden tipi tahmin et.
const
  Tipler: array[0..8] of TBankaTipi = (
    btGaranti, btZiraat, btIsBank, btAkbank, btYapikredi,
    btHalkbank, btVakifbank, btQNB, btING);
var
  Strm: TFileStream;
  Buf: TBytes;
  Okunan: Integer;
  Icerik: string;
  i: Integer;
  Konf: TBankaKonfig;
begin
  Result := btGenerik;
  try
    Strm := TFileStream.Create(Dosya, fmOpenRead or fmShareDenyNone);
    try
      SetLength(Buf, Min(Strm.Size, 8192));
      Okunan := Strm.Read(Buf, Length(Buf));
      SetLength(Buf, Okunan);
    finally
      Strm.Free;
    end;
    // Binary .xls içinde de string'ler text olarak bulunabiliyor; düşük ASCII'ye yakın taranır.
    Icerik := UpperCase(TEncoding.ANSI.GetString(Buf));
    for i := 0 to High(Tipler) do begin
      Konf := BankaKonfigGetir(Tipler[i]);
      if (Konf.BankaTespitAnahtar <> '') and (Pos(Konf.BankaTespitAnahtar, Icerik) > 0) then begin
        Result := Tipler[i];
        Exit;
      end;
    end;
  except
    Result := btGenerik;
  end;
end;

function TbankaHesapGirisdlg.BankaTipiSor(const Onerilen: TBankaTipi): TBankaTipi;
// Tespit edilen tipi onaylat veya kullanıcıdan seçim al.
const
  Adlar: array[TBankaTipi] of string = (
    'Generik', 'Garanti BBVA', 'Ziraat Bankası', 'İş Bankası', 'Akbank',
    'Yapı Kredi', 'Halkbank', 'Vakıfbank', 'QNB Finansbank', 'ING');
var
  Liste: TStringList;
  T: TBankaTipi;
  Sec: Integer;
begin
  Result := Onerilen;
  Liste := TStringList.Create;
  try
    for T := Low(TBankaTipi) to High(TBankaTipi) do
      Liste.AddObject(Adlar[T], TObject(Ord(T)));
    Sec := Ord(Onerilen);
    if Onerilen = btGenerik then begin
      // Tespit edilemediyse, varsayılan Garanti
      Sec := Ord(btGaranti);
    end;
    // Basit InputCombo yerine MessageBox onayla — istenirse genişletilebilir
    if Onerilen <> btGenerik then begin
      if Application.MessageBox(
          PChar('Banka tespit edildi: ' + Adlar[Onerilen] + sLineBreak +
                'Devam etmek için Evet, başka banka seçmek için Hayır.'),
          'Banka Onayı', MB_ICONQUESTION + MB_YESNO) = IDYES then
        Exit;
    end;
    // Manuel seçim — basit dialog. Yoksa Garanti ile devam.
    // (UI bileşeni hazır değil — geliştirme için varsayılan Garanti.)
    Result := btGaranti;
  finally
    Liste.Free;
  end;
end;

{ ---------- CSV okuyucu ---------- }

function TbankaHesapGirisdlg.DekontNoSaatCikar(const DekontNo: string;
  BankaTipi: TBankaTipi): TDateTime;
// Banka bazlı dekont no → saat parse.
var
  TimePart: string;
  H, M, S: Integer;
begin
  Result := 0;
  case BankaTipi of
    btGaranti:
      begin
        // "YYYY-MM-DD-HH.MM.SS.uuuuuu" örn. "2026-06-07-14.31.21.080034"
        if Length(DekontNo) < 19 then Exit;
        if DekontNo[11] <> '-' then Exit;
        TimePart := Copy(DekontNo, 12, 8);
        if (Length(TimePart) < 8) or (TimePart[3] <> '.') or (TimePart[6] <> '.') then Exit;
        H := StrToIntDef(Copy(TimePart, 1, 2), -1);
        M := StrToIntDef(Copy(TimePart, 4, 2), -1);
        S := StrToIntDef(Copy(TimePart, 7, 2), -1);
        if (H < 0) or (H > 23) or (M < 0) or (M > 59) or (S < 0) or (S > 59) then Exit;
        Result := EncodeTime(H, M, S, 0);
      end;
    // TODO: Diğer bankaların dekont formatları görüldükçe eklenecek
    // btZiraat: ...
    // btIsBank: ...
  end;
end;

function TbankaHesapGirisdlg.StrToTarihCSV(const S: string): TDateTime;
var
  Eski: Char;
  TmpStr: string;
begin
  // DD/MM/YYYY veya DD.MM.YYYY destekle
  TmpStr := Trim(S);
  TmpStr := StringReplace(TmpStr, '.', '/', [rfReplaceAll]);
  Eski := FormatSettings.DateSeparator;
  try
    FormatSettings.DateSeparator := '/';
    if not TryStrToDate(TmpStr, Result, FormatSettings) then
      Result := 0;
  finally
    FormatSettings.DateSeparator := Eski;
  end;
end;

function TbankaHesapGirisdlg.StrToTutarCSV(const S: string): Currency;
var
  TmpStr: string;
  P, V: Integer;
begin
  // Hem nokta hem virgül desimal olabilir. Son ayırıcı desimal kabul edilir.
  TmpStr := Trim(S);
  TmpStr := StringReplace(TmpStr, ' ', '', [rfReplaceAll]);
  TmpStr := StringReplace(TmpStr, 'TL', '', [rfReplaceAll, rfIgnoreCase]);
  // Son nokta veya virgülü desimal kabul et, diğerlerini sil
  P := LastDelimiter('.,', TmpStr);
  if P > 0 then begin
    V := P;
    // V konumundaki karakter desimal noktası olacak
    // Önceki tüm . ve , kaldırılacak
    TmpStr := StringReplace(Copy(TmpStr, 1, V - 1), '.', '', [rfReplaceAll]);
    TmpStr := StringReplace(TmpStr, ',', '', [rfReplaceAll]);
    TmpStr := TmpStr + FormatSettings.DecimalSeparator + Copy(S, V + 1, MaxInt);
    // Aslında baştaki Copy(S, V+1) — orijinal S'den almalıydık, düzelt:
    // Yeni baştan: V indexi orijinal TmpStr (whitespace temizlendikten sonra)
  end;
  // Basit yaklaşım: tüm noktayı ve binlik virgülünü sil, son ayırıcıyı . yap.
  TmpStr := Trim(S);
  TmpStr := StringReplace(TmpStr, ' ', '', [rfReplaceAll]);
  TmpStr := StringReplace(TmpStr, 'TL', '', [rfReplaceAll, rfIgnoreCase]);
  P := LastDelimiter('.,', TmpStr);
  if P > 0 then begin
    var Sol: string := Copy(TmpStr, 1, P - 1);
    var Sag: string := Copy(TmpStr, P + 1, MaxInt);
    Sol := StringReplace(Sol, '.', '', [rfReplaceAll]);
    Sol := StringReplace(Sol, ',', '', [rfReplaceAll]);
    TmpStr := Sol + FormatSettings.DecimalSeparator + Sag;
  end;
  if not TryStrToCurr(TmpStr, Result, FormatSettings) then
    Result := 0;
end;

function HucreAl(const Parcalar: TArray<string>; Idx: Integer): string;
// 1-tabanlı kolon erişimi; geçersizse boş
begin
  if (Idx <= 0) or (Idx > Length(Parcalar)) then Result := ''
  else Result := Trim(Parcalar[Idx - 1]);
end;

function TbankaHesapGirisdlg.OkuCsv(const Dosya: string; const Konf: TBankaKonfig;
  Satirlar: TBankaHareketListesi): Boolean;
var
  Lines: TStringList;
  i, HeaderIdx: Integer;
  Ayr: Char;
  Satir: string;
  Parcalar: TArray<string>;
  Sat: TBankaHareketSatiri;
  SaatPart: TDateTime;
begin
  Result := False;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(Dosya, TEncoding.UTF8);
    if Lines.Count = 0 then Exit;

    // Ayırıcı tespiti — ; , Tab
    Ayr := ';';
    for i := 0 to Lines.Count - 1 do
      if Trim(Lines[i]) <> '' then begin
        if (Pos(';', Lines[i]) = 0) and (Pos(',', Lines[i]) > 0) then Ayr := ','
        else if (Pos(';', Lines[i]) = 0) and (Pos(#9, Lines[i]) > 0) then Ayr := #9;
        Break;
      end;

    // Header satırı — konfigdeki HeaderAnahtar (örn. "Tarih") geçen ilk satır
    HeaderIdx := -1;
    for i := 0 to Lines.Count - 1 do
      if Pos(Konf.HeaderAnahtar, Lines[i]) > 0 then begin
        HeaderIdx := i;
        Break;
      end;
    if HeaderIdx < 0 then Exit;

    for i := HeaderIdx + 1 to Lines.Count - 1 do begin
      Satir := Trim(Lines[i]);
      if Satir = '' then Continue;
      Parcalar := Satir.Split([Ayr]);
      if Length(Parcalar) < 3 then Continue;

      Sat.Tarih    := StrToTarihCSV(HucreAl(Parcalar, Konf.KolTarih));
      if Sat.Tarih = 0 then Continue;
      Sat.Aciklama := HucreAl(Parcalar, Konf.KolAciklama);
      Sat.Etiket   := HucreAl(Parcalar, Konf.KolEtiket);
      Sat.Tutar    := StrToTutarCSV(HucreAl(Parcalar, Konf.KolTutar));
      Sat.Bakiye   := StrToTutarCSV(HucreAl(Parcalar, Konf.KolBakiye));
      Sat.DekontNo := HucreAl(Parcalar, Konf.KolDekontNo);

      if Sat.DekontNo <> '' then begin
        SaatPart := DekontNoSaatCikar(Sat.DekontNo, Konf.Tipi);
        if SaatPart > 0 then Sat.Tarih := Trunc(Sat.Tarih) + SaatPart;
      end;

      Satirlar.Add(Sat);
    end;
    Result := True;
  finally
    Lines.Free;
  end;
end;

{ ---------- XLS okuyucu (OLE Excel COM Automation) ---------- }

function HucreOlarakOku(Sheet: OleVariant; R, C: Integer): string;
var CV: OleVariant;
begin
  Result := '';
  if C <= 0 then Exit;
  CV := Sheet.Cells[R, C].Value;
  if VarIsNull(CV) or VarIsEmpty(CV) then Exit;
  Result := Trim(VarToStr(CV));
end;

function HucreSayiOku(Sheet: OleVariant; R, C: Integer): Currency;
var CV: OleVariant;
begin
  Result := 0;
  if C <= 0 then Exit;
  CV := Sheet.Cells[R, C].Value;
  if VarIsNull(CV) or VarIsEmpty(CV) then Exit;
  if VarIsNumeric(CV) then Result := Currency(Double(CV))
  else if VarIsStr(CV) then Result := 0;  // StrToTutarCSV çağrısı aşağıda yapılacak
end;

function TbankaHesapGirisdlg.OkuXls(const Dosya: string; const Konf: TBankaKonfig;
  Satirlar: TBankaHareketListesi): Boolean;
var
  Excel, Wb, Sheet: OleVariant;
  RowCount, ColCount, r, HeaderRow: Integer;
  CV: OleVariant;
  Sat: TBankaHareketSatiri;
  SaatPart: TDateTime;
begin
  Result := False;
  CoInitialize(nil);
  try
    try
      Excel := CreateOleObject('Excel.Application');
    except
      on E: Exception do begin
        Application.MessageBox(PChar('Excel yüklü değil veya açılamıyor.'#13 +
                                     'Lütfen dosyayı .csv olarak kaydedip tekrar deneyin.'#13#13 +
                                     'Detay: ' + E.Message),
                               PChar(Hata), MB_ICONWARNING + MB_OK);
        Exit;
      end;
    end;

    try
      Excel.Visible := False;
      Excel.DisplayAlerts := False;
      Wb := Excel.Workbooks.Open(Dosya, 0, True);   // ReadOnly
      Sheet := Wb.Sheets[1];
      RowCount := Sheet.UsedRange.Rows.Count;
      ColCount := Sheet.UsedRange.Columns.Count;
      if (RowCount < 2) or (ColCount < 2) then Exit;

      // Header satırı: KolTarih kolonunda HeaderAnahtar yazan satır
      HeaderRow := -1;
      for r := 1 to Min(RowCount, 30) do begin
        CV := Sheet.Cells[r, Konf.KolTarih].Value;
        if VarIsStr(CV) and (Pos(Konf.HeaderAnahtar, string(CV)) > 0) then begin
          HeaderRow := r;
          Break;
        end;
      end;
      if HeaderRow < 0 then Exit;

      for r := HeaderRow + 1 to RowCount do begin
        // Tarih hücresi - DateTime veya string olabilir
        Sat.Tarih := 0;
        CV := Sheet.Cells[r, Konf.KolTarih].Value;
        if VarIsNull(CV) or VarIsEmpty(CV) then Continue;
        if VarType(CV) = varDate then
          Sat.Tarih := TDateTime(CV)
        else if VarIsStr(CV) then
          Sat.Tarih := StrToTarihCSV(string(CV))
        else if VarIsNumeric(CV) then
          Sat.Tarih := Double(CV);
        if Sat.Tarih = 0 then Continue;

        Sat.Aciklama := HucreOlarakOku(Sheet, r, Konf.KolAciklama);
        Sat.Etiket   := HucreOlarakOku(Sheet, r, Konf.KolEtiket);

        // Tutar
        if Konf.KolTutar > 0 then begin
          CV := Sheet.Cells[r, Konf.KolTutar].Value;
          if VarIsNumeric(CV) then Sat.Tutar := Currency(Double(CV))
          else if VarIsStr(CV) then Sat.Tutar := StrToTutarCSV(string(CV))
          else Sat.Tutar := 0;
        end else Sat.Tutar := 0;

        // Bakiye
        if Konf.KolBakiye > 0 then begin
          CV := Sheet.Cells[r, Konf.KolBakiye].Value;
          if VarIsNumeric(CV) then Sat.Bakiye := Currency(Double(CV))
          else if VarIsStr(CV) then Sat.Bakiye := StrToTutarCSV(string(CV))
          else Sat.Bakiye := 0;
        end else Sat.Bakiye := 0;

        Sat.DekontNo := HucreOlarakOku(Sheet, r, Konf.KolDekontNo);

        if Sat.DekontNo <> '' then begin
          SaatPart := DekontNoSaatCikar(Sat.DekontNo, Konf.Tipi);
          if SaatPart > 0 then Sat.Tarih := Trunc(Sat.Tarih) + SaatPart;
        end;

        Satirlar.Add(Sat);
      end;

      Result := True;
    finally
      try Wb.Close(False); except end;
      try Excel.Quit; except end;
      Wb := Unassigned;
      Excel := Unassigned;
    end;
  finally
    CoUninitialize;
  end;
end;

{ ---------- Rule-based sınıflandırıcı ---------- }

{ ---------- Kural önbelleği ---------- }

procedure TbankaHesapGirisdlg.KurallariYukle(const BankaKodu: string);
// Belirtilen bankanın tüm kurallarını DB'den çekip cache'e koy.
// Anahtar: "BANKA_KODU:KURAL_TIPI" (örn. "GARANTI:E")
var
  Q: TFDQuery;
  Listeler: array['A'..'Z'] of TBankaKuralListesi;
  Tip: Char;
  K: TBankaKural;
begin
  if FYuklenenBankalar.IndexOf(BankaKodu) >= 0 then Exit;   // Zaten yüklendi
  FYuklenenBankalar.Add(BankaKodu);

  for Tip := 'A' to 'Z' do Listeler[Tip] := nil;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Tablo.FDCnn;
    Q.SQL.Text :=
      'SELECT KURAL_TIPI, PATTERN, PATTERN_TIPI, TUR_NEG, TUR_POZ, ' +
      '       REGEX_GROUP, CONFIDENCE ' +
      'FROM BANKA_KURAL ' +
      'WHERE BANKA_KODU = :BK AND AKTIF = 1 ' +
      'ORDER BY KURAL_TIPI, CONFIDENCE DESC';
    Q.ParamByName('BK').AsString := BankaKodu;
    Q.Open;
    while not Q.Eof do begin
      Tip := UpCase(Q.FieldByName('KURAL_TIPI').AsString[1]);
      if (Tip in ['E','A','I']) then begin
        if Listeler[Tip] = nil then begin
          Listeler[Tip] := TBankaKuralListesi.Create;
          FKuralCache.Add(BankaKodu + ':' + Tip, Listeler[Tip]);
        end;
        K.KuralTipi := Tip;
        K.Pattern := Q.FieldByName('PATTERN').AsString;
        K.PatternTipi := UpCase(Q.FieldByName('PATTERN_TIPI').AsString[1]);
        if Q.FieldByName('TUR_NEG').IsNull then K.TurNeg := -1
        else K.TurNeg := Q.FieldByName('TUR_NEG').AsInteger;
        if Q.FieldByName('TUR_POZ').IsNull then K.TurPoz := -1
        else K.TurPoz := Q.FieldByName('TUR_POZ').AsInteger;
        if Q.FieldByName('REGEX_GROUP').IsNull then K.RegexGroup := 1
        else K.RegexGroup := Q.FieldByName('REGEX_GROUP').AsInteger;
        K.Confidence := Q.FieldByName('CONFIDENCE').AsInteger;
        Listeler[Tip].Add(K);
      end;
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function TbankaHesapGirisdlg.KurallariGetir(const BankaKodu: string;
  KuralTipi: Char): TBankaKuralListesi;
var
  Anahtar: string;
begin
  KurallariYukle(BankaKodu);
  Anahtar := BankaKodu + ':' + KuralTipi;
  if FKuralCache.ContainsKey(Anahtar) then
    Result := FKuralCache[Anahtar]
  else
    Result := nil;
end;

function TbankaHesapGirisdlg.LikePatternEslesir(const Metin, Pattern: string): Boolean;
// SQL LIKE benzeri eşleştirme — Pos tabanlı (MatchesMask Unicode/Türkçe
// karakterlerle güvenilmez sonuç verebiliyor).
// '%' wildcard. '_' (tek karakter) bu kullanım için ihmal edilebilir.
var
  M, P, Cekirdek: string;
  BasWild, SonWild: Boolean;
  Parcalar: TArray<string>;
  Token: string;
  Bas, Bul: Integer;
begin
  Result := False;
  if Pattern = '' then Exit;
  M := UpperCase(Metin);
  P := UpperCase(Pattern);

  BasWild := P[1] = '%';
  SonWild := P[Length(P)] = '%';

  Cekirdek := P;
  if BasWild then Delete(Cekirdek, 1, 1);
  if SonWild and (Cekirdek <> '') then SetLength(Cekirdek, Length(Cekirdek) - 1);

  if Cekirdek = '' then begin
    Result := True;   // '%' ya da '%%' → her şey eşleşir
    Exit;
  end;

  // Kompleks pattern (içinde hala % varsa) → token bazlı sıralı arama
  if Pos('%', Cekirdek) > 0 then begin
    Parcalar := Cekirdek.Split(['%']);
    Bas := 1;
    for Token in Parcalar do begin
      if Token = '' then Continue;
      Bul := PosEx(Token, M, Bas);
      if Bul = 0 then Exit;
      Bas := Bul + Length(Token);
    end;
    Result := True;
    Exit;
  end;

  // Basit %X%, X%, %X, X durumları
  if BasWild and SonWild then Result := Pos(Cekirdek, M) > 0
  else if BasWild then Result := EndsText(Cekirdek, M)
  else if SonWild then Result := StartsText(Cekirdek, M)
  else Result := M = Cekirdek;
end;

function TbankaHesapGirisdlg.RegexIleIsimCikar(const Aciklama, Pattern: string;
  Grup: Integer; out Isim: string): Boolean;
var
  Eslesme: TMatch;
begin
  Result := False; Isim := '';
  try
    Eslesme := TRegEx.Match(Aciklama, Pattern, [roIgnoreCase]);
    if Eslesme.Success and (Eslesme.Groups.Count > Grup) then begin
      Isim := Trim(Eslesme.Groups[Grup].Value);
      Result := Isim <> '';
    end;
  except
    // Geçersiz regex pattern → sessizce başarısız
    Result := False;
  end;
end;

{ ---------- Kural-driven sınıflandırma ---------- }

function TbankaHesapGirisdlg.AciklamadanIsimCikar(const Aciklama: string;
  BankaTipi: TBankaTipi): string;
// DB'deki 'I' tipi (İsim çıkarma) regex kurallarını sırayla dene.
// Bulunamazsa GENERIK kurallarına düş. Hâlâ yoksa ilk "-" öncesi fallback.
var
  BankaKodu: string;
  Liste: TBankaKuralListesi;
  K: TBankaKural;
  Isim: string;
  P: Integer;
begin
  Result := '';
  if Trim(Aciklama) = '' then Exit;

  // Ortak ön filtreler: ATM/POS/MASRAF/KOMISYON başlayan açıklamalarda isim yok
  if Pos('ATM', UpperCase(Aciklama)) = 1 then Exit;
  if Pos('POS', UpperCase(Aciklama)) = 1 then Exit;
  if (Pos('KOMISYON', UpperCase(Aciklama)) > 0) or
     (Pos('KOMİSYON', UpperCase(Aciklama)) > 0) or
     (Pos('MASRAF', UpperCase(Aciklama)) > 0) then Exit;

  BankaKodu := BankaKoduGetir(BankaTipi);
  Liste := KurallariGetir(BankaKodu, 'I');
  if Liste <> nil then begin
    for K in Liste do begin
      if K.PatternTipi = 'R' then begin
        if RegexIleIsimCikar(Aciklama, K.Pattern, K.RegexGroup, Isim) then begin
          Result := Isim;
          Exit;
        end;
      end else if K.PatternTipi = 'L' then begin
        if LikePatternEslesir(Aciklama, K.Pattern) then begin
          // LIKE pattern'i isim çıkarmıyor, sadece flag; bu durum nadir
          Result := Aciklama; Exit;
        end;
      end;
    end;
  end;

  // GENERIK kurallar üzerinde dene
  if BankaKodu <> 'GENERIK' then begin
    Liste := KurallariGetir('GENERIK', 'I');
    if Liste <> nil then
      for K in Liste do
        if (K.PatternTipi = 'R') and
           RegexIleIsimCikar(Aciklama, K.Pattern, K.RegexGroup, Isim) then begin
          Result := Isim;
          Exit;
        end;
  end;

  // Son çare: ilk "-" öncesi
  P := Pos('-', Aciklama);
  if P > 0 then Result := Trim(Copy(Aciklama, 1, P - 1))
  else Result := Aciklama;
end;

function TbankaHesapGirisdlg.EtiketTuruEslestir(const Etiket: string;
  Negatif: Boolean; BankaTipi: TBankaTipi;
  out Tur: Integer; out Confidence: Integer): Boolean;
// DB'deki 'E' tipi (Etiket→Tür) kurallarını sırayla LIKE eşleştir.
// Eşleşen ilk kuralda confidence + tur yönü sonuçlanır. Bulunamazsa GENERIK'e düş.
var
  BankaKodu: string;
  Liste: TBankaKuralListesi;
  K: TBankaKural;
  SecilenTur: Integer;
begin
  Result := False; Tur := 0; Confidence := 0;
  if Trim(Etiket) = '' then Exit;

  BankaKodu := BankaKoduGetir(BankaTipi);
  Liste := KurallariGetir(BankaKodu, 'E');
  if Liste <> nil then begin
    for K in Liste do begin
      if (K.PatternTipi = 'L') and LikePatternEslesir(Etiket, K.Pattern) then begin
        if Negatif then SecilenTur := K.TurNeg
        else SecilenTur := K.TurPoz;
        if SecilenTur > 0 then begin
          Tur := SecilenTur;
          Confidence := K.Confidence div 2;  // Etiket bazlı yarı confidence (sonra +cari +20)
          Result := True;
          Exit;
        end;
      end;
    end;
  end;

  // GENERIK fallback
  if BankaKodu <> 'GENERIK' then begin
    Liste := KurallariGetir('GENERIK', 'E');
    if Liste <> nil then
      for K in Liste do
        if (K.PatternTipi = 'L') and LikePatternEslesir(Etiket, K.Pattern) then begin
          if Negatif then SecilenTur := K.TurNeg
          else SecilenTur := K.TurPoz;
          if SecilenTur > 0 then begin
            Tur := SecilenTur;
            Confidence := K.Confidence div 2;
            Result := True;
            Exit;
          end;
        end;
  end;
end;

function TbankaHesapGirisdlg.RehberAraExact(const Isim: string): Integer;
begin
  Result := 0;
  if Trim(Isim) = '' then Exit;
  Tablo.TablodanSorguAc(1,
    'SELECT '+DbUst(1)+'ID FROM REHBER WHERE UPPER(FIRMA) = ''' +
    StringReplace(UpperCase(Isim), '''', '''''', [rfReplaceAll]) + ''''+' '+DbSinir(1));
  if not Tablo.Query1.IsEmpty then
    Result := Tablo.Query1.Fields[0].AsInteger;
end;

function TbankaHesapGirisdlg.KrediSecimEkraniAc(out KrediID, DetayID: Integer;
  out KrediAdi: string; out TaksitTutar: Currency;
  out BelgeNo, Aciklama: string): Boolean;
// UKasaWizard'daki MemoKrediler.Text SQL'inin aynısı — sadece ödenmemiş krediler.
// Manuel TabloGirisDlg açıyoruz ki: ADI'ya göre grupla + footer'da satır sayımı göster.
// Kolon indeksleri (SELECT sırasına göre):
//   0=KREDIKODU, 1=BELGENO, 2=ADI, 3=ISLEMTARIHI, 4=BORC, 5=ODENEN,
//   6=BAKIYE, 7=KUR, 8=ACIKLAMA, 9=GENELKREDITIPI,
//   10=MASRAF, 11=FAIZMASRAF, 12=KREDIID, ...
const
  SQL_KREDI_LISTE =
    'declare @KrediDurum smallint, @KrediKodu varchar(20), @KrediAdi varchar(50), @KrediId varchar(10); ' +
    'set @KrediDurum = 2; set @KrediAdi = ''<ara>''; set @KrediKodu = ''''; set @KrediId = ''%''; ' +
    'SELECT K.KREDIKODU, KS.BELGENO, K.ADI, KS.ISLEMTARIHI, KS.BORC, ' +
    '  ODENEN=(select isnull(SUM(ALACAK),0.0) from KASA KS2 ' +
    '          where K.ID=KS2.HESAPID AND KS2.HESAPTURU=''R'' AND KS2.TUR=58 and KS2.BELGENO=KS.BELGENO), ' +
    '  BAKIYE=KS.BORC-(select isnull(SUM(ALACAK),0.0) from KASA KS2 ' +
    '          where K.ID=KS2.HESAPID AND KS2.HESAPTURU=''R'' AND KS2.TUR=58 and KS2.BELGENO=KS.BELGENO), ' +
    '  K.KUR, ACIKLAMA, GENELKREDITIPI, ' +
    '  MASRAF=(select AD from MASRAFGELIR where ID=K.MASRAFID), ' +
    '  FAIZMASRAF=(select AD from MASRAFGELIR where ID=K.FAIZMASRAFID), ' +
    '  K.ID as KREDIID, KS.ID AS DETAYID, BANKATICARIHESAPID, KASAYA_DETAYLI, K.MASRAFID, ' +
    '  K.FAIZMASRAFID, K.REHBERID, KREDIREFERANSNO=KS.ACIKLAMA ' +
    'FROM KREDILER K INNER JOIN KASA KS ON K.ID=KS.HESAPID AND KS.HESAPTURU=''R'' AND KS.TUR=59 ' +
    'where K.GENELKREDITIPI = 2 ' +
    '  AND K.KREDIKODU like ''%''+@KrediKodu+''%'' ' +
    '  AND K.ADI like ''%''+@KrediAdi+''%'' ' +
    '  AND K.ID like @KrediId ' +
    'union all ' +
    'SELECT K.KREDIKODU, BELGENO=K.SOZLESMENO, K.ADI, TARIH, KO.TAKSIT, ODENEN=0, BAKIYE, ' +
    '  K.KUR, ACIKLAMA, GENELKREDITIPI, ' +
    '  MASRAF=(select AD from MASRAFGELIR where ID=K.MASRAFID), ' +
    '  FAIZMASRAF=(select AD from MASRAFGELIR where ID=K.FAIZMASRAFID), ' +
    '  K.ID as KREDIID, KO.ID AS DETAYID, BANKATICARIHESAPID, KASAYA_DETAYLI, K.MASRAFID, ' +
    '  K.FAIZMASRAFID, K.REHBERID, KREDIREFERANSNO=null ' +
    'FROM KREDILER K INNER JOIN PLANKREDI KO ON K.ID=KO.KREDIID ' +
    'where KO.TAKSIT>0 ' +
    '  AND 1= case when @KrediDurum=0 then 1 when @KrediDurum=1 and ODENMIS=1 then 1 ' +
    '              when @KrediDurum=2 and ODENMIS=0 then 1 else 2 end ' +
    '  AND K.KREDIKODU like ''%''+@KrediKodu+''%'' ' +
    '  AND K.ADI like ''%''+@KrediAdi+''%'' ' +
    '  AND K.ID like @KrediId';
var
  SummaryItem: TcxGridDBTableSummaryItem;
  Key: Word;
  i: Integer;
begin
  Result := False; KrediID := 0; DetayID := 0; KrediAdi := '';
  TaksitTutar := 0; BelgeNo := ''; Aciklama := '';

  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  try
    TabloGirisDlg.Caption := 'Ödenmemiş Krediler';
    TabloGirisDlg.Komut := SQL_KREDI_LISTE;
    TabloGirisDlg.EkranYazdirAdi := 'Krediler';
    TabloGirisDlg.Query1.AfterOpen := KrediSecimQueryAfterOpen;
    Key := 0;
    TabloGirisDlg.Edit1KeyUp(Self, Key, [ssShift]);   // sorgu açılır, kolonlar oluşur

    // Footer'da satır sayımı
    TabloGirisDlg.GridGirisTV.OptionsView.Footer := True;
    TabloGirisDlg.GridGirisTV.DataController.Summary.FooterSummaryItems.Clear;
    SummaryItem := TabloGirisDlg.GridGirisTV.DataController.Summary.FooterSummaryItems.Add as TcxGridDBTableSummaryItem;
    SummaryItem.Kind := skCount;
    SummaryItem.Format := 'Toplam: 0 kredi';
    if TabloGirisDlg.GridGirisTV.ColumnCount > 0 then
      SummaryItem.Column := TabloGirisDlg.GridGirisTV.Columns[0];

    TabloGirisDlg.ShowModal;
    if TabloGirisDlg.ModalResult = mrOk then begin
      // Kolon 12 = KREDIID, 13 = DETAYID, 4 = aylık taksit, 8 = ACIKLAMA, 2 = ADI, 1 = BELGENO
      with TabloGirisDlg.Query1 do begin
        if Fields[12] <> nil then KrediID := Fields[12].AsInteger;
        if Fields[13] <> nil then DetayID := Fields[13].AsInteger;
        if Fields[2] <> nil then KrediAdi := Fields[2].AsString;
        if Fields[4] <> nil then TaksitTutar := Fields[4].AsCurrency;
        if Fields[1] <> nil then BelgeNo := Fields[1].AsString;
        if Fields[8] <> nil then Aciklama := Fields[8].AsString;
      end;
      Result := KrediID > 0;
    end;
  finally
    TabloGirisDlg.Free;
  end;
end;

procedure TbankaHesapGirisdlg.KrediSecimQueryAfterOpen(DataSet: TDataSet);
var
  ColAdi: TcxGridDBColumn;
  i: Integer;
begin
  // Önce standart dinamik kolon oluşturma işlemini çalıştır.
  TabloGirisDlg.Query1AfterOpen(DataSet);

  // Sorgu zamanlayıcıyla açıldığı için gruplamayı kolonlar oluştuktan sonra uygula.
  for i := 0 to TabloGirisDlg.GridGirisTV.ColumnCount - 1 do
    TabloGirisDlg.GridGirisTV.Columns[i].GroupIndex := -1;

  ColAdi := TabloGirisDlg.GridGirisTV.GetColumnByFieldName('ADI') as TcxGridDBColumn;
  if ColAdi <> nil then begin
    ColAdi.GroupIndex := 0;
    TabloGirisDlg.GridGirisTV.OptionsView.GroupByBox := False;
    TabloGirisDlg.GridGirisTV.DataController.Groups.FullCollapse;
  end;
end;

function TbankaHesapGirisdlg.KartNoIleAra(const Aciklama: string): Integer;
// Açıklamada geçen 4 haneli sayı gruplarını tara, KREDIKARTI.NOSU'da LIKE ile eşleştir.
// "K.Kartı Ödeme 5407 **** **** 7015" → "5407" ve "7015" 4'erli gruplar; NOSU bir tanesini içeren kart döner.
var
  i, j: Integer;
  Token: string;
  Q: TFDQuery;
begin
  Result := 0;
  if Trim(Aciklama) = '' then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Tablo.FDCnn;
    Q.SQL.Text := 'SELECT '+DbUst(1)+'ID FROM KREDIKARTI WHERE NOSU LIKE :P '+DbSinir(1);
    i := 1;
    while i <= Length(Aciklama) do begin
      if (Aciklama[i] >= '0') and (Aciklama[i] <= '9') then begin
        j := i;
        while (j <= Length(Aciklama)) and (Aciklama[j] >= '0') and (Aciklama[j] <= '9') do
          Inc(j);
        if (j - i) = 4 then begin
          Token := Copy(Aciklama, i, 4);
          // Yıl olabilecek değerleri (1900-2099) atla — false positive yaratmasın
          if (Token < '1900') or (Token > '2099') then begin
            Q.Close;
            Q.ParamByName('P').AsString := '%' + Token + '%';
            Q.Open;
            if not Q.IsEmpty then begin
              Result := Q.Fields[0].AsInteger;
              Exit;
            end;
          end;
        end;
        i := j;
      end else
        Inc(i);
    end;
  finally
    Q.Free;
  end;
end;

function TbankaHesapGirisdlg.RehberAraLike(const Isim: string): Integer;
var
  Tokens: TArray<string>;
  Tk: string;
  Kosul: string;
begin
  Result := 0;
  if Trim(Isim) = '' then Exit;
  // Tokenize — uzun olan ilk 2 kelimeyi LIKE ile arayalım
  Tokens := Isim.Split([' ']);
  Kosul := '';
  for Tk in Tokens do
    if Length(Tk) >= 3 then begin
      if Kosul <> '' then Kosul := Kosul + ' AND ';
      Kosul := Kosul + 'UPPER(FIRMA) LIKE ''%' +
        StringReplace(UpperCase(Tk), '''', '''''', [rfReplaceAll]) + '%''';
    end;
  if Kosul = '' then Exit;
  Tablo.TablodanSorguAc(1, 'SELECT '+DbUst(1)+'ID FROM REHBER WHERE ' + Kosul+' '+DbSinir(1));
  if not Tablo.Query1.IsEmpty then
    Result := Tablo.Query1.Fields[0].AsInteger;
end;

function TbankaHesapGirisdlg_AciklamaKuraliUygula(
  Self_: TbankaHesapGirisdlg;
  const Aciklama: string; Negatif: Boolean; Liste: TBankaKuralListesi;
  out Tur: Integer; out Confidence: Integer): Boolean;
// Liste içindeki 'A' (Açıklama) kurallarını LIKE ile dener.
var
  K: TBankaKural;
  SecilenTur: Integer;
begin
  Result := False; Tur := 0; Confidence := 0;
  if Liste = nil then Exit;
  for K in Liste do begin
    if K.PatternTipi <> 'L' then Continue;
    if Self_.LikePatternEslesir(Aciklama, K.Pattern) then begin
      if Negatif then SecilenTur := K.TurNeg
      else SecilenTur := K.TurPoz;
      if SecilenTur > 0 then begin
        Tur := SecilenTur;
        Confidence := K.Confidence div 2;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure TbankaHesapGirisdlg.SatirAnalizEt(const Satir: TBankaHareketSatiri;
  BankaTipi: TBankaTipi;
  out Tur: Integer; out RehberID: Integer;
  out RehberAd, OnerilenAciklama: string;
  out Confidence: Integer);
var
  Isim, BankaKodu: string;
  Negatif: Boolean;
  EtiketTaninir, AciklamaTaninir: Boolean;
  EtiketConfidence, AciklamaConfidence: Integer;
  AciklamaTur: Integer;
  AciklamaKurallari: TBankaKuralListesi;
  Fingerprint: string;
  EslemeRehID: Integer;
  EslemeKesin: Boolean;
begin
  Tur := 0; RehberID := 0; RehberAd := ''; OnerilenAciklama := Satir.Aciklama;
  Confidence := 0;
  Negatif := Satir.Tutar < 0;
  BankaKodu := BankaKoduGetir(BankaTipi);

  // 0) Önce öğrenilmiş eşleme (BANKA_CARI_ESLEME) — fingerprint açıklama-bazlı
  Fingerprint := FingerprintHesapla(BankaTipi, 0, Satir.Aciklama);
  if EslemeBul(BankaKodu, Fingerprint, AciklamaTur, EslemeRehID, EslemeKesin) then begin
    if AciklamaTur > 0 then begin
      Tur := AciklamaTur;
      if EslemeKesin then Confidence := 95 else Confidence := 75;
    end;
    if EslemeRehID > 0 then begin
      RehberID := EslemeRehID;
      case Tur of
        TURID_GELENHAVALE, TURID_GIDENHAVALE:
          RehberAd := Tablo.AciklamaGetir('REHBER', 'FIRMA', EslemeRehID);
        TURID_MASRAFODEME, TURID_GELIRTAHSILATI:
          RehberAd := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', EslemeRehID);
        TURID_PARAYATIRMA, TURID_PARACEKME:
          RehberAd := Tablo.AciklamaGetir('KASALAR', 'KASAADI', EslemeRehID);
        TURID_KKODEME, TURID_KKODEMEIADE:
          RehberAd := Tablo.AciklamaGetir('KREDIKARTI', 'ADI', EslemeRehID);
        TURID_KREDIODEME:
          RehberAd := Tablo.AciklamaGetir('KREDILER', 'ADI', EslemeRehID);
        TURID_HESAPLARARASI, TURID_POSAKTARIM, TURID_BANKADANDOVIZAL, TURID_BANKADANDOVIZSAT,
        TURID_BANKAARBITRAJ:
          RehberAd := Tablo.AciklamaGetir('BANKAHESAPLAR', 'HESAPADI', EslemeRehID);
      end;
    end;
    // Hem TUR hem REHBER öğrenildiyse direkt yeşil, devam etme
    if (AciklamaTur > 0) and (EslemeRehID > 0) then begin
      OnerilenAciklama := Satir.Aciklama;
      Exit;
    end;
  end;

  // 1) DB'deki Etiket kuralları (KURAL_TIPI='E')
  EtiketTaninir := EtiketTuruEslestir(Satir.Etiket, Negatif, BankaTipi, Tur, EtiketConfidence);
  if EtiketTaninir then
    Inc(Confidence, EtiketConfidence);

  // 2) Etiket yoksa/tanınmazsa DB'deki Açıklama kurallarını dene (KURAL_TIPI='A')
  if not EtiketTaninir then begin
    AciklamaKurallari := KurallariGetir(BankaKodu, 'A');
    AciklamaTaninir := TbankaHesapGirisdlg_AciklamaKuraliUygula(Self,
                         Satir.Aciklama, Negatif, AciklamaKurallari,
                         AciklamaTur, AciklamaConfidence);
    if not AciklamaTaninir and (BankaKodu <> 'GENERIK') then begin
      // GENERIK fallback
      AciklamaKurallari := KurallariGetir('GENERIK', 'A');
      AciklamaTaninir := TbankaHesapGirisdlg_AciklamaKuraliUygula(Self,
                           Satir.Aciklama, Negatif, AciklamaKurallari,
                           AciklamaTur, AciklamaConfidence);
    end;
    if AciklamaTaninir then begin
      Tur := AciklamaTur;
      Inc(Confidence, AciklamaConfidence);
    end else begin
      // Hiçbir kural eşleşmedi → sadece tutar yönü
      if Negatif then Tur := TURID_GIDENHAVALE else Tur := TURID_GELENHAVALE;
      Inc(Confidence, 15);
    end;
  end;

  // 3) KK Ödeme — açıklamadan 4 haneli kart no parça ile KREDIKARTI tablosundan bul
  if (Tur in [TURID_KKODEME, TURID_KKODEMEIADE]) and (RehberID = 0) then begin
    RehberID := KartNoIleAra(Satir.Aciklama);
    if RehberID > 0 then begin
      RehberAd := Tablo.AciklamaGetir('KREDIKARTI', 'ADI', RehberID);
      Inc(Confidence, 35);
    end;
  end;

  // 4) Cari arama — rule-based (öğrenilmiş eşleme yukarıda zaten denendi)
  if (Tur = TURID_GELENHAVALE) or (Tur = TURID_GIDENHAVALE) then begin
    Isim := AciklamadanIsimCikar(Satir.Aciklama, BankaTipi);
    if Isim <> '' then begin
      Inc(Confidence, 15);
      RehberID := RehberAraExact(Isim);
      if RehberID > 0 then begin
        RehberAd := Isim;
        Inc(Confidence, 35);
      end else begin
        RehberID := RehberAraLike(Isim);
        if RehberID > 0 then begin
          RehberAd := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberID);
          Inc(Confidence, 20);
        end else
          RehberAd := Isim;   // Cari bulunmadı — kullanıcı seçecek
      end;
    end;
  end else if EtiketTaninir then
    Inc(Confidence, 20);   // Para Çekme/Yatırma için cari aranmaz

  if OnerilenAciklama = '' then OnerilenAciklama := Satir.Aciklama;
  if Confidence > 100 then Confidence := 100;
  if Confidence < 0 then Confidence := 0;
end;

{ ---------- Grid satır renklendirme ---------- }

procedure TbankaHesapGirisdlg.cxGrid1DBTableView1SECIMPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
// Grid satırının Seçim hücresindeki ellipsis butonuna basılınca,
// satırın TURID'ine göre uygun seçim ekranını aç ve SECIMID + SECIM alanlarını güncelle.
var
  Tur, YeniID: Integer;
  YeniAd, s1, s2, s3, s4, s5, s6: string;
  iTmp: Integer;
  Sonuc: TStringList;
  Secildi: Boolean;
  // Kredi seçiminde otomatik atanan ek bilgiler
  KrediTutar: Currency;
  KrediYeniAciklama: string;
  KrediDetayIDLocal: Integer;
  KrediBelgeNoLocal: string;
  HedefDovizLocal: string;
  DovizKurLocal, DovizTutarLocal: Currency;
begin
  if dxMemData1.RecordCount = 0 then Exit;
  if dxMemData1.State in [dsInsert, dsEdit] then dxMemData1.Cancel;

  Tur := dxMemData1TURID.AsInteger;
  YeniID := 0; YeniAd := ''; Secildi := False;
  KrediTutar := 0; KrediYeniAciklama := '';
  KrediDetayIDLocal := 0; KrediBelgeNoLocal := '';
  HedefDovizLocal := ''; DovizKurLocal := 0; DovizTutarLocal := 0;

  case Tur of
    TURID_GELENHAVALE, TURID_GIDENHAVALE:
      begin
        iTmp := Tablo.RehberAra_IDGetir(-1);
        if iTmp > 0 then begin
          YeniID := iTmp;
          YeniAd := Tablo.AciklamaGetir('REHBER', 'FIRMA', iTmp);
          Secildi := True;
        end;
      end;
    TURID_BANKADANDOVIZSAT:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz.',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaHesapSecModal(CariDoviz, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          YeniID := iTmp;
          YeniAd := s1 + ' / ' + s2 + ' - ' + s3;
          HedefDovizLocal := s5;
          var KaynakKurLocal: Currency := 1;
          if FBankaDovizi <> CariDoviz then
            KaynakKurLocal := DovizKuruBul(FormatDateTime('yyyy-mm-dd', dxMemData1TARIH.AsDateTime),
              FBankaDovizi, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));
          DovizKurLocal := KaynakKurLocal;
          DovizTutarLocal := dxMemData1TUTAR.AsCurrency * DovizKurLocal;
          Secildi := True;
        end;
      end;
    TURID_MASRAFODEME:
      if Tablo.MasrafMerkeziSecimEkrani(0, s1, s2, s3) then begin
        YeniID := StrToIntDef(s1, 0); YeniAd := s3; Secildi := True;
      end;
    TURID_GELIRTAHSILATI:
      if Tablo.MasrafMerkeziSecimEkrani(1, s1, s2, s3) then begin
        YeniID := StrToIntDef(s1, 0); YeniAd := s3; Secildi := True;
      end;
    TURID_KKODEME, TURID_KKODEMEIADE:
      begin
        s1 := ''; s2 := ''; s3 := ''; s4 := FBankaDovizi;
        if Tablo.KrediKartiEkrani(s1, s2, s3, s4) then begin
          YeniID := StrToIntDef(s1, 0); YeniAd := s3; Secildi := True;
        end;
      end;
    TURID_KREDIODEME:
      begin
        // UKasaWizard CekSenetKrediAraEkr grid'i — ödenmemiş krediler listesi (ADI'ya göre gruplu)
        var KrediAd, SecAciklama, KrediBelgeNo: string;
        var DetayID: Integer;
        if KrediSecimEkraniAc(YeniID, DetayID, KrediAd, KrediTutar, KrediBelgeNo, SecAciklama) then begin
          YeniAd := KrediAd;
          Secildi := True;
          // Detay ID ve Belge No'yu prosedür-seviyesi tutuculara al (Edit/Post bloğunda yazılacak)
          KrediDetayIDLocal := DetayID;
          KrediBelgeNoLocal := KrediBelgeNo;
          // Açıklama formatı: önce kredi adı, sonra "-" ile seçilen açıklama
          if Trim(SecAciklama) <> '' then
            KrediYeniAciklama := KrediAd + ' - ' + SecAciklama
          else
            KrediYeniAciklama := KrediAd;
        end;
      end;
    TURID_PARAYATIRMA, TURID_PARACEKME:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz.',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        Sonuc := TStringList.Create;
        try
          if Tablo.ListedenBilgiGetir('Kasa Seçimi',
            'SELECT ID, KASAKODU, KASAADI FROM KASALAR ' +
            'WHERE DURUM = 1 AND KASATUR = 100 AND KUR = ''' + FBankaDovizi + ''' ' +
            'ORDER BY KASAADI', Sonuc, []) then begin
            YeniID := StrToIntDef(Sonuc.Strings[0], 0);
            YeniAd := Sonuc.Strings[2];
            Secildi := True;
          end;
        finally
          Sonuc.Free;
        end;
      end;
    TURID_HESAPLARARASI:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz.',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaHesapSecModal(FBankaDovizi, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          YeniID := iTmp;
          YeniAd := s1 + ' / ' + s2 + ' - ' + s3;
          Secildi := True;
        end;
      end;
    TURID_POSAKTARIM:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz.',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if PosSecModal(iTmp, s1, s2) then begin
          YeniID := iTmp;
          YeniAd := s1;
          s6 := s2;
          Secildi := True;
        end;
      end;
    TURID_BANKADANDOVIZAL:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz.',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaDovizHesapSecModal(FBankaDovizi, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          YeniID := iTmp;
          YeniAd := s1 + ' / ' + s2 + ' - ' + s3;
          HedefDovizLocal := s5;
          var KaynakKurLocal: Currency := 1;
          var HedefKurLocal: Currency := 1;
          if FBankaDovizi <> CariDoviz then
            KaynakKurLocal := DovizKuruBul(FormatDateTime('yyyy-mm-dd', dxMemData1TARIH.AsDateTime),
              FBankaDovizi, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));
          if HedefDovizLocal <> CariDoviz then
            HedefKurLocal := DovizKuruBul(FormatDateTime('yyyy-mm-dd', dxMemData1TARIH.AsDateTime),
              HedefDovizLocal, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));
          if FBankaDovizi = CariDoviz then begin
            DovizKurLocal := HedefKurLocal;
            if DovizKurLocal <> 0 then
              DovizTutarLocal := dxMemData1TUTAR.AsCurrency / DovizKurLocal;
          end else if HedefKurLocal <> 0 then begin
            DovizKurLocal := KaynakKurLocal / HedefKurLocal;
            DovizTutarLocal := dxMemData1TUTAR.AsCurrency * DovizKurLocal;
          end;
          Secildi := True;
        end;
      end;
    TURID_BANKAARBITRAJ:
      begin
        if FHESAPID = 0 then begin
          Application.MessageBox('Önce banka hesabı seçiniz.',
                                 PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
          Exit;
        end;
        if BankaArbitrajHesapSecModal(FBankaDovizi, FHESAPID, iTmp, s1, s2, s3, s4, s5, s6) then begin
          YeniID := iTmp;
          YeniAd := s1 + ' / ' + s2 + ' - ' + s3;
          HedefDovizLocal := s5;
          var KaynakKurLocal: Currency := DovizKuruBul(
            FormatDateTime('yyyy-mm-dd', dxMemData1TARIH.AsDateTime),
            FBankaDovizi, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));
          var HedefKurLocal: Currency := DovizKuruBul(
            FormatDateTime('yyyy-mm-dd', dxMemData1TARIH.AsDateTime),
            HedefDovizLocal, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));
          if HedefKurLocal <> 0 then begin
            DovizKurLocal := KaynakKurLocal / HedefKurLocal;
            DovizTutarLocal := dxMemData1TUTAR.AsCurrency * DovizKurLocal;
          end;
          Secildi := True;
        end;
      end;
  else
    Application.MessageBox('Bu tür için seçim mevcut değil.', PChar(Hata),
                           MB_ICONINFORMATION + MB_OK);
    Exit;
  end;

  if not Secildi then Exit;

  // Grid satırına yaz
  FSatirEkleniyor := True;
  try
    dxMemData1.Edit;
    dxMemData1SECIMID.AsInteger := YeniID;
    dxMemData1SECIM.AsString    := YeniAd;
    // Kredi Ödeme: tutar, açıklama, DETAYID, BELGENO seçilen krediden gelir
    if Tur = TURID_KREDIODEME then begin
      if KrediTutar > 0 then dxMemData1TUTAR.AsCurrency := KrediTutar;
      if Trim(KrediYeniAciklama) <> '' then dxMemData1ACIKLAMA.AsString := KrediYeniAciklama;
      dxMemData1KREDIDETAYID.AsInteger := KrediDetayIDLocal;
      if Trim(KrediBelgeNoLocal) <> '' then dxMemData1BELGENO.AsString := KrediBelgeNoLocal;
    end else if Tur = TURID_KKODEME then begin
      dxMemData1ACIKLAMA.AsString := FHesapAdi + ' > ' + YeniAd;
    end else if Tur = TURID_KKODEMEIADE then begin
      dxMemData1ACIKLAMA.AsString := YeniAd + ' > ' + FHesapAdi;
    end else if Tur = TURID_POSAKTARIM then begin
      dxMemData1ACIKLAMA.AsString := YeniAd + ' > ' + s6;
    end else if Tur in [TURID_BANKADANDOVIZAL, TURID_BANKADANDOVIZSAT,
                        TURID_BANKAARBITRAJ] then begin
      dxMemData1KARSILIGI.AsBoolean := True;
      dxMemData1DOVIZ_TIPI.AsString := HedefDovizLocal;
      dxMemData1KUR.AsCurrency := DovizKurLocal;
      dxMemData1DOVIZ_TUTARI.AsCurrency := DovizTutarLocal;
      dxMemData1ACIKLAMA.AsString := FHesapAdi + ' > ' + s6;
    end;
    // Bu satır artık manuel seçimle güncellendi → confidence 95 (yeşil)
    dxMemData1CONFIDENCE.AsInteger := 95;
    dxMemData1.Post;
  finally
    FSatirEkleniyor := False;
  end;

  // Öğrenme — sonraki içeri alımda otomatik eşleşmek üzere DB'ye kaydet (TUR + REHBERID)
  EslemeKaydet(BankaKoduGetir(FBankaTipi),
               FingerprintHesapla(FBankaTipi, Tur, dxMemData1ACIKLAMA.AsString),
               Tur, YeniID, True);
end;

procedure TbankaHesapGirisdlg.SatirTuruDegistir(YeniTurID: Integer);
// TURID değişince ilgili field'ları (TUR string, SECIM, CONFIDENCE) güncelle.
// TURID'i de explicit yazıyoruz — grid'in editor commit timing'i nedeniyle
// bazen yansımıyor.
var
  i: Integer;
  YeniAd: string;
begin
  YeniAd := '';
  for i := 0 to cbTur.Properties.Items.Count - 1 do
    if Integer(cbTur.Properties.Items[i].Value) = YeniTurID then begin
      YeniAd := cbTur.Properties.Items[i].Description;
      Break;
    end;

  FSatirEkleniyor := True;
  try
    if not (dxMemData1.State in [dsInsert, dsEdit]) then dxMemData1.Edit;
    dxMemData1TURID.AsInteger   := YeniTurID;   // <-- Garantili commit
    dxMemData1TUR.AsString      := YeniAd;
    // SECIM eski tür için seçilmişse temizle (yeni tür için farklı dialog gerekiyor)
    dxMemData1SECIMID.AsInteger := 0;
    dxMemData1SECIM.AsString    := '';
    dxMemData1CONFIDENCE.AsInteger := 70;   // tür manuel set: orta-yüksek (henüz seçim yok)
    dxMemData1.Post;
  finally
    FSatirEkleniyor := False;
  end;
end;

procedure TbankaHesapGirisdlg.cxGrid1DBTableView1TURIDPropertiesChange(Sender: TObject);
// Grid'de TURID kolonu ImageCombo değişince çağrılır.
var
  YeniTur: Integer;
begin
  if FSatirEkleniyor then Exit;
  if dxMemData1.RecordCount = 0 then Exit;
  if not (Sender is TcxImageComboBox) then Exit;
  YeniTur := TcxImageComboBox(Sender).EditValue;
  if YeniTur <= 0 then Exit;

  SatirTuruDegistir(YeniTur);

  // Öğrenme — TUR'u DB'ye yaz (REHBERID henüz seçilmedi → 0 olarak gönderilir, kolon korunur)
  EslemeKaydet(BankaKoduGetir(FBankaTipi),
               FingerprintHesapla(FBankaTipi, YeniTur, dxMemData1ACIKLAMA.AsString),
               YeniTur, 0, True);
end;

{ ---------- Fingerprint + öğrenen eşleme cache (BANKA_CARI_ESLEME) ---------- }

function TbankaHesapGirisdlg.FingerprintHesapla(BankaTipi: TBankaTipi;
  Tur: Integer; const Aciklama: string): string;
// Açıklama-tabanlı stabil eşleştirme anahtarı. Tür bilgisi anahtara DAHIL DEĞIL —
// kullanıcı Tür'ü değiştirdiğinde aynı fingerprint kullanılır.
// Algoritma:
//   1) AciklamadanIsimCikar ile bir başlık yakala (regex veya fallback)
//   2) Bu başlığı ilk rakam/yıldız karakterinden önce kes (kart no, ATM kod vs. eleme)
//   3) Sondaki '-', boşluk gibi gürültüleri trim et
//   Örnekler:
//     "K.Kartı Ödeme 5407 **** **** 7015"           → "ACK:K.KARTI ÖDEME"
//     "ATM PARA YATIRMA-5170********5108-ATM Kodu"  → "ACK:ATM PARA YATIRMA"
//     "EMİNE ODABAŞI--HVL-CEP ŞUBE"                  → "ACK:EMİNE ODABAŞI" (regex'le)
//     "Semra Kaya-FAST-CEP ŞUBE-548000279"           → "ACK:SEMRA KAYA"   (regex'le)
//     "PARA ÇEKME"                                   → "ACK:PARA ÇEKME"
//     "KESİNTİ VE EKLERİ-"                           → "ACK:KESİNTİ VE EKLERİ"
var
  Anahtar, Tmp: string;
  i: Integer;
begin
  Result := '';
  Tmp := Trim(Aciklama);
  if Tmp = '' then Exit;

  // 1) Önce isim çıkarmayı dene; başarısız olursa açıklamanın kendisini kullan
  Anahtar := AciklamadanIsimCikar(Tmp, BankaTipi);
  if Anahtar = '' then Anahtar := Tmp;

  // 2) İlk rakam veya '*' karakterinden önceki kısmı al — kart no, ATM kodu vs. eleme
  for i := 1 to Length(Anahtar) do
    if (Anahtar[i] = '*') or
       ((Anahtar[i] >= '0') and (Anahtar[i] <= '9')) then begin
      SetLength(Anahtar, i - 1);
      Break;
    end;

  // 3) Sondaki gürültüyü (- _ . , ' ') trim et
  while (Length(Anahtar) > 0) and CharInSet(Anahtar[Length(Anahtar)],
        ['-', '_', '.', ',', ' ']) do
    SetLength(Anahtar, Length(Anahtar) - 1);
  Anahtar := Trim(Anahtar);

  // 4) Boş düşerse veya çok kısa kaldıysa açıklamanın ilk 80 karakterine düş
  if Length(Anahtar) < 3 then Anahtar := Copy(Tmp, 1, 80);

  Result := 'ACK:' + UpperCase(Anahtar);
  if Length(Result) > 200 then Result := Copy(Result, 1, 200);
end;

procedure TbankaHesapGirisdlg.EslemeKaydet(const BankaKodu, Fingerprint: string;
  Tur, RehberID: Integer; KesinMi: Boolean = True);
// Aynı BANKA_KODU + FINGERPRINT varsa TUR + REHBERID güncelle.
// Yoksa yeni satır ekle. Tur=0 veya RehberID=0 ise ilgili kolon güncellenmez.
var
  Q: TFDQuery;
  VarId: Integer;
begin
  if Trim(Fingerprint) = '' then Exit;
  if (Tur <= 0) and (RehberID <= 0) then Exit;   // Saklanacak bir şey yok

  VarId := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Tablo.FDCnn;
    Q.SQL.Text := 'SELECT '+DbUst(1)+'ID FROM BANKA_CARI_ESLEME ' +
                  'WHERE BANKA_KODU = :BK AND FINGERPRINT = :FP '+DbSinir(1);
    Q.ParamByName('BK').AsString := BankaKodu;
    Q.ParamByName('FP').AsString := Fingerprint;
    Q.Open;
    if not Q.IsEmpty then VarId := Q.Fields[0].AsInteger;
    Q.Close;

    if VarId > 0 then begin
      // UPDATE — sadece dolu geçenleri güncelle (Tur 0 / RehberID 0 ise o kolon korunur)
      var SQLText: string := 'UPDATE BANKA_CARI_ESLEME SET ';
      if Tur > 0 then SQLText := SQLText + 'TUR = :T, ';
      if RehberID > 0 then SQLText := SQLText + 'REHBERID = :R, ';
      SQLText := SQLText + 'KESIN_MI = :K, KULLANIM = KULLANIM + 1, ' +
                 'SON_KULLANIM = GETDATE() WHERE ID = :I';
      Q.SQL.Text := SQLText;
      Q.ParamByName('K').AsBoolean := KesinMi;
      Q.ParamByName('I').AsInteger := VarId;
      if Tur > 0 then Q.ParamByName('T').AsInteger := Tur;
      if RehberID > 0 then Q.ParamByName('R').AsInteger := RehberID;
    end else begin
      // INSERT — REHBERID NOT NULL (kolon kısıtı): yoksa 0 yaz
      Q.SQL.Text := 'INSERT INTO BANKA_CARI_ESLEME ' +
                    '(BANKA_KODU, FINGERPRINT, TUR, REHBERID, KESIN_MI) ' +
                    'VALUES (:BK, :FP, :T, :R, :K)';
      Q.ParamByName('BK').AsString := BankaKodu;
      Q.ParamByName('FP').AsString := Fingerprint;
      if Tur > 0 then Q.ParamByName('T').AsInteger := Tur
      else begin
        // NULL yazarken tip belirtilmeli; tipsiz Clear FireDAC -335 'data type
        // is unknown' hatasi verir (Tur=0 ile ilk cagri MT940 dosya izinde cikti).
        Q.ParamByName('T').DataType := ftInteger;
        Q.ParamByName('T').Clear;
      end;
      Q.ParamByName('R').AsInteger := Max(RehberID, 0);
      Q.ParamByName('K').AsBoolean := KesinMi;
    end;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TbankaHesapGirisdlg.EslemeBul(const BankaKodu, Fingerprint: string;
  out Tur, RehberID: Integer; out KesinMi: Boolean): Boolean;
var
  Q: TFDQuery;
begin
  Result := False; Tur := 0; RehberID := 0; KesinMi := False;
  if Trim(Fingerprint) = '' then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Tablo.FDCnn;
    Q.SQL.Text := 'SELECT '+DbUst(1)+'TUR, REHBERID, KESIN_MI FROM BANKA_CARI_ESLEME ' +
                  'WHERE BANKA_KODU = :BK AND FINGERPRINT = :FP ' +
                  'ORDER BY KESIN_MI DESC, KULLANIM DESC '+DbSinir(1);
    Q.ParamByName('BK').AsString := BankaKodu;
    Q.ParamByName('FP').AsString := Fingerprint;
    Q.Open;
    if not Q.IsEmpty then begin
      if not Q.FieldByName('TUR').IsNull then Tur := Q.FieldByName('TUR').AsInteger;
      RehberID := Q.FieldByName('REHBERID').AsInteger;
      KesinMi := Q.FieldByName('KESIN_MI').AsBoolean;
      Result := (Tur > 0) or (RehberID > 0);
    end;
  finally
    Q.Free;
  end;
end;

procedure TbankaHesapGirisdlg.miBenzerlerineUygulaClick(Sender: TObject);
// Aktif satırın TUR + SECIM değerlerini al; aynı fingerprint'li tüm satırlara
// uygula (TUR ya da SECIM ya da ikisi birden). DB'ye de yaz — öğrenir.
var
  KaynakTur, KaynakSecimID, GuncellenenAdet: Integer;
  KaynakSecimAd, KaynakFP, SatirFP: string;
  BankaKodu: string;
  Bookmark: TArray<Byte>;
begin
  if dxMemData1.RecordCount = 0 then Exit;

  KaynakTur     := dxMemData1TURID.AsInteger;
  KaynakSecimID := dxMemData1SECIMID.AsInteger;
  KaynakSecimAd := dxMemData1SECIM.AsString;
  KaynakFP := FingerprintHesapla(FBankaTipi, KaynakTur, dxMemData1ACIKLAMA.AsString);

  if (KaynakTur <= 0) and (KaynakSecimID <= 0) then begin
    Application.MessageBox('Önce bu satıra Tür ya da Seçim atayın.',
                           PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
    Exit;
  end;
  if KaynakFP = '' then Exit;

  BankaKodu := BankaKoduGetir(FBankaTipi);
  GuncellenenAdet := 0;
  Bookmark := dxMemData1.Bookmark;

  FSatirEkleniyor := True;
  dxMemData1.DisableControls;
  try
    dxMemData1.First;
    while not dxMemData1.Eof do begin
      SatirFP := FingerprintHesapla(FBankaTipi,
                                    dxMemData1TURID.AsInteger,
                                    dxMemData1ACIKLAMA.AsString);
      if SatirFP = KaynakFP then begin
        if (dxMemData1TURID.AsInteger <> KaynakTur) or
           (dxMemData1SECIMID.AsInteger <> KaynakSecimID) or
           (dxMemData1CONFIDENCE.AsInteger < 95) then begin
          dxMemData1.Edit;
          if KaynakTur > 0 then begin
            dxMemData1TURID.AsInteger := KaynakTur;
            // TUR string'ini de güncelle
            for var i: Integer := 0 to cbTur.Properties.Items.Count - 1 do
              if Integer(cbTur.Properties.Items[i].Value) = KaynakTur then begin
                dxMemData1TUR.AsString := cbTur.Properties.Items[i].Description;
                Break;
              end;
          end;
          if KaynakSecimID > 0 then begin
            dxMemData1SECIMID.AsInteger := KaynakSecimID;
            dxMemData1SECIM.AsString    := KaynakSecimAd;
          end;
          dxMemData1CONFIDENCE.AsInteger := 95;
          dxMemData1.Post;
          Inc(GuncellenenAdet);
        end;
      end;
      dxMemData1.Next;
    end;
    if Length(Bookmark) > 0 then
      try dxMemData1.Bookmark := Bookmark; except end;
  finally
    dxMemData1.EnableControls;
    FSatirEkleniyor := False;
  end;

  // Öğrenme — TUR + REHBERID birlikte DB'ye yaz (boş geçen kolon korunur)
  EslemeKaydet(BankaKodu, KaynakFP, KaynakTur, KaynakSecimID, True);

  Application.MessageBox(PChar(IntToStr(GuncellenenAdet) + ' satır güncellendi.'#13 +
                               'Eşleşme DB''ye kaydedildi — sonraki içeri alımda otomatik gelir.'),
                         'Benzerlerine Uygula', MB_ICONINFORMATION + MB_OK);
end;

procedure TbankaHesapGirisdlg.cxGrid1DBTableView1Editing(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem;
  var AAllow: Boolean);
// ONAY kolonu sadece yeşil satırlarda (CONFIDENCE >= 90) işaretlenebilsin.
begin
  if (AItem = cxGrid1DBTableView1ONAY) and
     (dxMemData1CONFIDENCE.AsInteger < 90) then
    AAllow := False;
end;

procedure TbankaHesapGirisdlg.cxGrid1DBTableView1StylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  Conf: Integer;
  V: Variant;
begin
  AStyle := nil;
  if ARecord = nil then Exit;
  V := ARecord.Values[cxGrid1DBTableView1CONFIDENCE.Index];
  if VarIsNull(V) or VarIsEmpty(V) then Exit;
  Conf := V;
  if Conf >= 90 then AStyle := StyleYesil
  else if Conf >= 60 then AStyle := StyleSari
  else AStyle := StyleKirmizi;
end;

{ ============================================================ }
{        MT940 İçeri Al — Excel/CSV akışından bağımsız         }
{ ============================================================ }

procedure TbankaHesapGirisdlg.btnMT940AlClick(Sender: TObject);
// MT940 dosyalarını (ÇOKLU seçim) oku → karşı taraf IBAN ile REHBER lookup → grid'i doldur.
// Mevcut rule motoru/öğrenen cache devreye girmez — IBAN zaten kesin tanımlayıcı.
// Aynı dosya (tam yol) bu ekranda daha önce yüklendiyse tekrar YÜKLENMEZ (mükerrer engeli).
var
  Od: TOpenDialog;
  Parser: TMT940Parser;
  Sonuc: TMT940Dosyasi;
  H: TMT940Hareketi;
  Q: TFDQuery;
  RehID, Tur, Confidence, i, d: Integer;
  RehAd, Dosya, Sorunlular, Ozet: string;
  ToplamHareket, OkunanDosya, AtlananDosya: Integer;
begin
  if FHESAPID = 0 then begin
    Application.MessageBox('Önce banka hesabı seçiniz.',
                           PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
    Exit;
  end;

  Od := TOpenDialog.Create(nil);
  try
    Od.DefaultExt := 'txt';
    Od.Filter := 'MT940 (*.txt;*.sta;*.940)|*.txt;*.sta;*.940';
    Od.Options := [ofPathMustExist, ofFileMustExist, ofAllowMultiSelect];
    if not Od.Execute then Exit;

    ToplamHareket := 0; OkunanDosya := 0; AtlananDosya := 0; Sorunlular := '';

    Parser := TMT940Parser.Create;
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Tablo.FDCnn;

      for d := 0 to Od.Files.Count - 1 do begin
        Dosya := Od.Files[d];

        // Aynı dosya daha önce listeye yüklendiyse ATLA (oturum içi, sessiz)
        if FMT940Dosyalar.IndexOf(Dosya) >= 0 then begin
          Inc(AtlananDosya);
          Continue;
        end;

        // KALICI kontrol: bu dosya adı bu programda daha önce yüklenmiş mi?
        // (BANKA_CARI_ESLEME / 'MT940DOSYA' izi; form kapansa da hatırlanır.)
        var KTur, KReh: Integer;
        var KKesin: Boolean;
        if EslemeBul('MT940DOSYA', UpperCase(ExtractFileName(Dosya)), KTur, KReh, KKesin) then
          if Application.MessageBox(PChar(ExtractFileName(Dosya) +
               ' daha önce yüklenmiş görünüyor.' + sLineBreak +
               'Yine de yüklensin mi? (MÜKERRER kayıt riski!)'),
               PChar(Onay), MB_ICONWARNING + MB_YESNO) <> IDYES then begin
            Inc(AtlananDosya);
            Continue;
          end;

        if not Parser.Parse(Dosya, Sonuc) then begin
          FreeAndNil(Sonuc.Hareketler);   // Parse basta olusturur; hata yolunda da birak(ilmali)
          Sorunlular := Sorunlular + '  ' + ExtractFileName(Dosya) + ' (okunamadı/format hatalı)' + sLineBreak;
          Continue;
        end;
        try
          if Sonuc.Hareketler.Count = 0 then begin
            Sorunlular := Sorunlular + '  ' + ExtractFileName(Dosya) + ' (hareket bulunamadı)' + sLineBreak;
            Continue;
          end;

          FSatirEkleniyor := True;
          try
            for i := 0 to Sonuc.Hareketler.Count - 1 do begin
              H := Sonuc.Hareketler[i];
              RehID := 0; RehAd := ''; Confidence := 50;

              // Tür — borç/alacak yönüne göre temel sınıflandırma
              if H.BorcMu then Tur := TURID_GIDENHAVALE
                         else Tur := TURID_GELENHAVALE;
              // Açıklamadan tür ipucu: 'K.Kartı Ödeme ...' → KK Ödeme
              if H.BorcMu and (Pos('K.KART', AnsiUpperCase(H.Aciklama)) > 0) and
                 (Pos('DEME', AnsiUpperCase(H.Aciklama)) > 0) then
                Tur := TURID_KKODEME;

              // IBAN ile REHBER lookup — eşsiz, yüksek güven
              if H.KarsiTarafIBAN <> '' then begin
                Q.Close;
                Q.SQL.Text := 'SELECT '+DbUst(1)+'ID, KOD, FIRMA FROM REHBER WHERE IBAN = :I '+DbSinir(1);
                Q.ParamByName('I').AsString := H.KarsiTarafIBAN;
                Q.Open;
                if not Q.IsEmpty then begin
                  RehID := Q.FieldByName('ID').AsInteger;
                  // Cari KOD + AD birlikte gosterilsin
                  RehAd := Trim(Q.FieldByName('KOD').AsString);
                  if RehAd <> '' then RehAd := RehAd + ' - ';
                  RehAd := RehAd + Q.FieldByName('FIRMA').AsString;
                  Confidence := 95;
                end;
              end;

              // IBAN'la bulunmadıysa karşı taraf adıyla dene
              if (RehID = 0) and (H.KarsiTarafAd <> '') then begin
                Q.Close;
                Q.SQL.Text := 'SELECT '+DbUst(1)+'ID, KOD, FIRMA FROM REHBER ' +
                              'WHERE UPPER(FIRMA) = UPPER(:N) '+DbSinir(1);
                Q.ParamByName('N').AsString := H.KarsiTarafAd;
                Q.Open;
                if not Q.IsEmpty then begin
                  RehID := Q.FieldByName('ID').AsInteger;
                  RehAd := Trim(Q.FieldByName('KOD').AsString);
                  if RehAd <> '' then RehAd := RehAd + ' - ';
                  RehAd := RehAd + Q.FieldByName('FIRMA').AsString;
                  Confidence := 75;
                end else begin
                  RehAd := H.KarsiTarafAd;
                  Confidence := 60;
                end;
              end;

              // Önek eşleşmesi: :86: ünvanı 43 kolonda KESİK gelir; FIRMA bu kesik
              // adla BAŞLIYORSA ve TEK aday varsa eşleştir (2+ aday = belirsiz).
              if (RehID = 0) and (Length(Trim(H.KarsiTarafAd)) >= 8) then begin
                Q.Close;
                Q.SQL.Text := 'SELECT '+DbUst(2)+'ID, KOD, FIRMA FROM REHBER ' +
                              'WHERE UPPER(FIRMA) LIKE UPPER(:N) + ''%'' '+DbSinir(2);
                Q.ParamByName('N').AsString := Trim(H.KarsiTarafAd);
                Q.Open;
                if Q.RecordCount = 1 then begin
                  RehID := Q.FieldByName('ID').AsInteger;
                  RehAd := Trim(Q.FieldByName('KOD').AsString);
                  if RehAd <> '' then RehAd := RehAd + ' - ';
                  RehAd := RehAd + Q.FieldByName('FIRMA').AsString;
                  Confidence := 80;
                end;
              end;

              // Öğrenen eşleme: bu ünvan için daha önce kullanıcı cari seçtiyse onu kullan
              if (RehID = 0) and (Trim(H.KarsiTarafAd) <> '') then begin
                var ETur, ERehID: Integer;
                var EKesin: Boolean;
                if EslemeBul('MT940', 'MTAD:' + AnsiUpperCase(Trim(H.KarsiTarafAd)),
                             ETur, ERehID, EKesin) and (ERehID > 0) then begin
                  RehID := ERehID;
                  RehAd := Trim(Tablo.AciklamaGetir('REHBER', 'KOD', ERehID));
                  if RehAd <> '' then RehAd := RehAd + ' - ';
                  RehAd := RehAd + Tablo.AciklamaGetir('REHBER', 'FIRMA', ERehID);
                  if ETur > 0 then Tur := ETur;
                  Confidence := 90;
                end;
              end;

              // Fatura tutari eslesmesi: hala eslesmediyse hareket tutarina BIREBIR esit
              // kesilmis fatura ara (gelen havale -> satis, giden havale -> alis; son 120 gun).
              // TEK cari aday sarti: tutar tesadufu riskine karsi 2+ aday alinmaz.
              if RehID = 0 then begin
                Q.Close;
                // NOT: parametre yerine literal — FireDAC currency/date parametre tip
                // cikarimi '-335 data type is unknown' hatasi verebiliyor.
                Q.SQL.Text := 'SELECT DISTINCT '+DbUst(2)+'F.REHBERID FROM FATBASLIK F ' +
                              'WHERE F.FATURA_TUTARI = ' +
                                StringReplace(CurrToStr(H.Tutar), ',', '.', [rfReplaceAll]) +
                              ' AND F.REHBERID > 0 ' +
                              'AND F.TARIH BETWEEN ''' +
                                FormatDateTime('yyyy-mm-dd', H.Tarih - 120) + ''' AND ''' +
                                FormatDateTime('yyyy-mm-dd', H.Tarih + 2) + ' 23:59'' ' +
                              IfThen(H.BorcMu, 'AND F.TUR IN (9,11,13)',
                                               'AND F.TUR IN (15,17,19)')+' '+DbSinir(2);
                Q.Open;
                if (Q.RecordCount = 1) and (Q.Fields[0].AsInteger > 0) then begin
                  RehID := Q.Fields[0].AsInteger;
                  RehAd := Trim(Tablo.AciklamaGetir('REHBER', 'KOD', RehID));
                  if RehAd <> '' then RehAd := RehAd + ' - ';
                  RehAd := RehAd + Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID);
                  Confidence := 70;
                end;
              end;

              // Grid'e ekle
              dxMemData1.Append;
              dxMemData1TARIH.AsDateTime    := H.Tarih;
              dxMemData1TURID.AsInteger     := Tur;
              dxMemData1TUR.AsString        := TurAdiGetir(Tur);
              dxMemData1SECIMID.AsInteger   := RehID;
              dxMemData1SECIM.AsString      := RehAd;
              dxMemData1TUTAR.AsCurrency    := H.Tutar;
              dxMemData1PBIRIMI.AsString    := H.Doviz;
              dxMemData1KOMISYON.AsCurrency := 0;
              dxMemData1ACIKLAMA.AsString   := Trim(H.Aciklama);
              dxMemData1BELGENO.AsString    := H.Referans;
              dxMemData1ICERIALINDI.AsBoolean := True;
              dxMemData1IBAN.AsString       := H.KarsiTarafIBAN;
              dxMemData1HAMAD.AsString      := H.KarsiTarafAd;
              dxMemData1KARSILIGI.AsBoolean := False;
              dxMemData1DOVIZ_TUTARI.AsCurrency := 0;
              dxMemData1DOVIZ_TIPI.AsString     := '';
              dxMemData1KUR.AsCurrency          := 0;
              dxMemData1EKSTREDE_KULLAN.AsBoolean := True;
              dxMemData1MASRAFID.AsInteger      := 0;
              dxMemData1MASRAFKALEMI.AsString   := '';
              dxMemData1CONFIDENCE.AsInteger    := Confidence;
              dxMemData1ONAY.AsBoolean          := False;
              dxMemData1.Post;
            end;
          finally
            FSatirEkleniyor := False;
          end;

          Inc(ToplamHareket, Sonuc.Hareketler.Count);
          Inc(OkunanDosya);
          FMT940Dosyalar.Add(Dosya);   // başarıyla yüklendi → bir daha yüklenmesin
          // Kalıcı iz: dosya adı kaydedilsin (sonraki günlerde tekrar seçilirse uyarı çıkar)
          EslemeKaydet('MT940DOSYA', UpperCase(ExtractFileName(Dosya)), 0, FHESAPID, True);
        finally
          Sonuc.Hareketler.Free;
        end;
      end;
    finally
      Q.Free;
      Parser.Free;
    end;

    // Onay kolonu görünür yap (yeşil = tıklanabilir)
    if ToplamHareket > 0 then
      cxGrid1DBTableView1ONAY.Visible := True;

    Ozet := IntToStr(OkunanDosya) + ' dosyadan ' + IntToStr(ToplamHareket) +
            ' MT940 hareketi içeri alındı.';
    if ToplamHareket > 0 then
      Ozet := Ozet + sLineBreak + 'IBAN ile eşleşenler yeşil, diğerleri sarı/pembe.';
    if AtlananDosya > 0 then
      Ozet := Ozet + sLineBreak + IntToStr(AtlananDosya) + ' dosya daha önce yüklendiği için atlandı.';
    if Sorunlular <> '' then
      Ozet := Ozet + sLineBreak + 'Sorunlu dosyalar:' + sLineBreak + Sorunlular;
    Application.MessageBox(PChar(Ozet), 'MT940 İçeri Al', MB_ICONINFORMATION + MB_OK);
  finally
    Od.Free;
  end;
end;

procedure TbankaHesapGirisdlg.ButtonExcelAlClick(Sender: TObject);
begin
  if FHESAPID = 0 then begin
    Application.MessageBox('Önce banka hesabı seçiniz.',
                           PChar(DBos_alan), MB_ICONINFORMATION + MB_OK);
    Exit;
  end;
  if not Od1.Execute then Exit;
  HareketleriIceriAl(Od1.FileName);
end;

end.

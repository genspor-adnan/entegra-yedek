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
  dxScrollbarAnnotations;

type
  TbankaHesapGirisdlg = class(TForm)
    // Üst düğme şeridi
    PanelUst: TPanel;
    btnHesapSec: TcxButton;
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
  private
    FHESAPID: Integer;
    FBankaAdi, FSubeAdi, FHESAPKODU, FHESAPNO, FBankaDovizi, FHesapAdi: string;
    FSECIMID: Integer;
    FMasrafKalemiID: Integer; // Gelen/Giden Havale için MASRAFID seçimi (KASA.MASRAFID)
    FOtoHesapla: Boolean;     // recursive change-event guard
    FDuzenlemeKipinde: Boolean;
    FSatirEkleniyor: Boolean; // SatirEkle çalışırken grid focus event'ini blokla
    procedure SatiriUstePanele;
    procedure HesapBilgiGoster;
    procedure TurDegistiUygula;
    procedure SecimEkraniAc;
    procedure MasrafKalemiEkraniAc;
    function BankaHesapSecModal(const DovizKodu: string; HaricID: Integer;
                                out hId: Integer;
                                out BankaAdi, SubeAdi, HesapNo, HesapKodu, Doviz, HesapAdi: string): Boolean;
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
                          const BelgeNo: string = ''; YerId: Integer = 0): Integer;
  public
  end;

const
  // Tür ID'leri (Banka Hızlı Giriş.xlsx -> "Ekran Tasarımı" R8-R14)
  TURID_GELENHAVALE = 22;
  TURID_GIDENHAVALE = 32;
  TURID_PARAYATIRMA = 41;
  TURID_PARACEKME   = 42;
  TURID_HESAPLARARASI = 43;
  TURID_KKODEME     = 57;
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

uses PrjConst, Utablo, FetaKurulusSiniflari, fetautil, LocOnfly, System.DateUtils;

{ ---------- Yardımcı kurulum ---------- }

procedure TbankaHesapGirisdlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);   // Dil yükleme (UBelgegiris ile aynı pattern)
  Tablo.GridTurkcelestir;

  // Tür imagecombo doldur — Tag = TURID
  cbTur.Properties.Items.Clear;
  with cbTur.Properties.Items do begin
    with Add do begin Description := 'Gelen Havale';            Value := TURID_GELENHAVALE; end;
    with Add do begin Description := 'Giden Havale';            Value := TURID_GIDENHAVALE; end;
    with Add do begin Description := 'Para Yatırma';            Value := TURID_PARAYATIRMA; end;
    with Add do begin Description := 'Para Çekme';              Value := TURID_PARACEKME;   end;
    with Add do begin Description := 'Hesaplar arası transfer'; Value := TURID_HESAPLARARASI; end;
    with Add do begin Description := 'Masraf Ödeme';            Value := TURID_MASRAFODEME; end;
    with Add do begin Description := 'Gelir Tahsilatı';         Value := TURID_GELIRTAHSILATI; end;
    with Add do begin Description := 'KK Ödeme';                Value := TURID_KKODEME;     end;
  end;

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
  bankaHesapGirisdlg := nil;
end;

procedure TbankaHesapGirisdlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
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

procedure TbankaHesapGirisdlg.btnHesapSecClick(Sender: TObject);
begin
  // İlk hesap seçimi — döviz filtresi yok, tüm aktif firma hesapları gelsin.
  if BankaHesapSecModal('', 0, FHESAPID, FBankaAdi, FSubeAdi, FHESAPNO, FHESAPKODU, FBankaDovizi, FHesapAdi) then begin
    HesapBilgiGoster;
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
    TURID_PARAYATIRMA:                 // para banka hesabına giriyor
      teAciklama.Text := beSecim.Text + ' > ' + FHesapAdi;
    TURID_MASRAFODEME,
    TURID_PARACEKME,
    TURID_KKODEME:                     // para banka hesabından çıkıyor
      teAciklama.Text := FHesapAdi + ' > ' + beSecim.Text;
    // TURID_GELENHAVALE, TURID_GIDENHAVALE: açıklama boş kalır — kullanıcı manuel girer
    // TURID_HESAPLARARASI: kendi dalı içinde set ediyor (hedef HESAPADI ile)
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
  iTmp: Integer;
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

    TURID_KKODEME:
      begin
        // KrediKartiEkrani(var KKID, KODU, ADI, Kur: string)
        s1 := ''; s2 := ''; s3 := ''; s4 := '';
        if Tablo.KrediKartiEkrani(s1, s2, s3, s4) then begin
          FSECIMID := StrToIntDef(s1, 0);
          beSecim.Text := s3;
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
  end;

  // Hesaplar Arası dışındaki türler için açıklamayı yön kuralına göre otomatik doldur.
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
  KurDeger: Currency;
begin
  if cbDovizTipi.ItemIndex < 0 then Exit;
  DovizKod := VarToStr(cbDovizTipi.EditValue);

  // Eğer combo'da CariDoviz (TL) seçildiyse, gerçek kur lookup'ı hesabın dövizine
  // göre yapılır (örn. $ hesap → $ kuru). CariDoviz'in kendisi 1'dir, anlamlı değil.
  if (DovizKod = CariDoviz) and (FBankaDovizi <> '') and (FBankaDovizi <> CariDoviz) then
    DovizKod := FBankaDovizi;

  // Günün kuru — Utablo.DovizKuruBul kullan.
  KurDeger := DovizKuruBul(FormatDateTime('yyyy-mm-dd', Now), DovizKod,
                           Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz, ''));

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
  const BelgeNo: string = ''; YerId: Integer = 0): Integer;
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
  Result := Tablo.KasaKaydet(
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
    0, -1, -1, 0, GeriDonusId, -1,    // Durum, FaturaId, KrediId, CekSenetId, GeriDonusId, SubeId1
    HesapTuru,                        // 'B' banka, 'V' kredi kartı
    0, YerId, BelgeNo,                // Yer, YerId, BelgeNo
    Windows_HizliGiris,               // GirisKaynak — Utablo'da global = 5
    False,                            // R
    EkstredeKullan);
end;

procedure TbankaHesapGirisdlg.btnF5KaydetClick(Sender: TObject);
var
  Tur, RehId, MasId, BankaMasrafMerkeziId, IdBanka, IdKK: Integer;
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

  dxMemData1.First;
  while not dxMemData1.Eof do begin
    Tur         := dxMemData1TURID.AsInteger;
    Tarih       := dxMemData1TARIH.AsDateTime;
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
      TURID_MASRAFODEME:
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

    if Tur = TURID_KKODEME then begin
      // KK Ödeme — karşılıklı bağlı 2 KASA satırı (DB örneği: ID 729683/729684)

      // ACIKLAMA otomatik üret (legacy format), kullanıcı yazmadıysa.
      // Örnek: "GARANTİ BANKASI_DES_6265332_TL > **** **** **** 8060 ORHAN AKAR Ş.KART"
      if Aciklama = '' then
        Aciklama := FHesapAdi + ' > ' + dxMemData1SECIM.AsString;

      // Banka tarafı (HESAPTURU='B', BORC=Tutar)
      IdBanka := KasaSatirYaz(TURID_KKODEME, FHESAPID, 0, 0, Tarih, Aciklama,
                              HesapKuru, DovizKod,
                              dxMemData1TUTAR.AsCurrency, 0, DovizTutar,
                              EkKullan, 'B', -1);
      // KK tarafı (HESAPTURU='V', ALACAK=Tutar, GERIDONUSID=banka satırı)
      IdKK := KasaSatirYaz(TURID_KKODEME, dxMemData1SECIMID.AsInteger, 0, 0, Tarih, Aciklama,
                           HesapKuru, DovizKod,
                           0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                           EkKullan, 'V', IdBanka);
      // Banka satırının GERIDONUSID'ini KK satırının ID'sine güncelle (karşılıklı bağ)
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'UPDATE KASA SET GERIDONUSID = ' + IntToStr(IdKK) + ' WHERE ID = ' + IntToStr(IdBanka),
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
                                EkKullan, 'K', -1);
        IdKK    := KasaSatirYaz(Tur, FHESAPID, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                                EkKullan, 'B', IdBanka);
      end else begin
        // Para Çekme — para bankadan kasaya. Banka BORC, Kasa ALACAK
        IdBanka := KasaSatirYaz(Tur, FHESAPID, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                dxMemData1TUTAR.AsCurrency, 0, DovizTutar,
                                EkKullan, 'B', -1);
        IdKK    := KasaSatirYaz(Tur, dxMemData1SECIMID.AsInteger, 0, 0, Tarih, Aciklama,
                                HesapKuru, DovizKod,
                                0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                                EkKullan, 'K', IdBanka);
      end;
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
                              EkKullan, 'B', -1);
      // Hedef satırı (HESAPTURU='B', ALACAK=Tutar, GERIDONUSID=kaynak) — para hedef hesaba giriyor
      IdKK    := KasaSatirYaz(Tur, dxMemData1SECIMID.AsInteger, 0, 0, Tarih, Aciklama,
                              HesapKuru, DovizKod,
                              0, dxMemData1TUTAR.AsCurrency, DovizTutar,
                              EkKullan, 'B', IdBanka);
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
      else
        IdBanka := KasaSatirYaz(Tur, FHESAPID, RehId, MasId, Tarih, Aciklama,
                                HesapKuru, DovizKod, Borc, Alacak, DovizTutar, EkKullan);

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

    dxMemData1.Next;
  end;

  Application.MessageBox(PChar(DKayit_yapildi), PChar(Kaydet), MB_ICONINFORMATION + MB_OK);
  dxMemData1.Close;
  dxMemData1.Open;
  FDuzenlemeKipinde := False;
end;

end.

unit UInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.ComCtrls, dxCore, cxDateUtils,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxMaskEdit, cxDropDownEdit, cxCalendar,  DateUtils,
  cxTextEdit, System.JSON, System.StrUtils, Vcl.ExtCtrls, Winapi.CommCtrl, Winapi.UxTheme,
  dxBarBuiltInMenu, cxPC, dxCoreGraphics, cxImageComboBox, cxButtonEdit,
  cxCheckBox, cxLabel, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, Data.DB, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TInfoDlg = class(TForm)
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    PanelUst: TPanel;
    DateTarihBas: TcxDateEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    CheckSilme: TcxCheckBox;
    CheckDegistirme: TcxCheckBox;
    CheckEkleme: TcxCheckBox;
    EditKayitNo: TcxButtonEdit;
    cxLabel7: TcxLabel;
    txtTablo: TcxComboBox;
    Kullanici: TcxButtonEdit;
    txtAlan: TcxButtonEdit;
    cxLabel4: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel6: TcxLabel;
    DateTarihBit: TcxDateEdit;
    LvGecmis: TListView;
    LvDetay: TListView;
    GridLOG: TcxGrid;
    GridLOGView: TcxGridDBTableView;
    GridLOGViewSATIRID: TcxGridDBColumn;
    GridLOGViewTARIH: TcxGridDBColumn;
    GridLOGViewPCADI: TcxGridDBColumn;
    GridLOGViewFIRMA: TcxGridDBColumn;
    GridLOGViewTABLO: TcxGridDBColumn;
    GridLOGViewISLEM: TcxGridDBColumn;
    GridLOGViewKOD: TcxGridDBColumn;
    GridLOGViewAD: TcxGridDBColumn;
    GridLOGViewISLEMTIPI: TcxGridDBColumn;   // gizli - satir renklendirme icin
    GridLOGLevel1: TcxGridLevel;
    Panel2: TPanel;
    cxButton1: TcxButton;
    BtnGeriAl: TcxButton;
    TabLog: TFDQuery;
    DsTabLog: TDataSource;
    cxLabel8: TcxLabel;
    EditIcerik: TcxButtonEdit;
    CheckIcerik: TcxCheckBox;
    procedure FormShow(Sender: TObject);
    procedure LvGecmisSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure LvGecmisCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure cxPageControl1Change(Sender: TObject);
    procedure GridLOGViewCustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure GridLOGViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure BtnGeriAlClick(Sender: TObject);
  private
    FJsonlar: TStringList;     // LvGecmis ile paralel: her kaydin BILGI json'u
    FTabloIDler: TStringList;  // FJsonlar ile paralel: her satirin TABLOID'i (deger cozumu icin)
    FKullaniciAdlari: TStringList;  // FJsonlar ile paralel: islemi yapan kullanici adi
    FTiklamaAcik: Boolean;     // button-edit OnClick re-entrancy guard'i
    FCozumler: TStringList;    // LOGCOZUM satirlari: 'ALAN|TABLOID' -> 'KAYNAKTABLO|IDKOLON|ADKOLON|FILTRE'
    FCozumCache: TStringList;  // 'TABLOID|ALAN|DEGER' -> ad (tekrarli sorguyu onler)
    procedure CozumleriYukle;  // LOGCOZUM'u bellege al (bir kez)
    function  DegerCoz(ATabloID: Integer; const AAlan, ADeger: string;
      AKardesler: TStrings = nil): string;  // ID -> ad ({ALAN} placeholder = kardes alan degeri)
    procedure ButtonEditTiklama(Sender: TObject);   // edit'e tiklayinca picker'i ac
    procedure SutunlariHazirla;
    procedure LogGecmisiYukle;
    procedure DetayGoster(const ABilgiJSON: string; ATip: Integer; ATabloID: Integer = 0; const AKullaniciAd: string = '');
    procedure TabLogYukle;             // Genel grid: LOG (ISLEMLOG) listesi (filtreli)
    procedure GenelSatirDetayGoster;   // Genel'de secili satirin BILGI'sini LvDetay'a
    procedure FiltreOlaylariBagla;     // filtre kontrollerinin olaylarini bagla
    procedure FiltreUygula(Sender: TObject);
    procedure BolumleriYukle;          // Bolum combo: TABLOLAR modulleri + bos
    procedure KullaniciButonClick(Sender: TObject; AButtonIndex: Integer);  // personel listesi
    procedure BilgiAlButonClick(Sender: TObject; AButtonIndex: Integer);    // Bilgisayar/KayitNo: giris + temizle
    procedure GeriAlButonGuncelle;   // "Geri Al" butonu gorunurlugu (secili satir SILME mi)
  public
    TabloAd: String;
    ID: Integer;
    TabloNo: Integer;          // ISLEMLOG.TABLOID filtresi (LOG.TABLOID / TabNo_*)
    GenelModu: Boolean;        // True: 2 sekme (MenuYeniLog browse); False: sadece Detay (kayit bazli)
  end;

var
  InfoDlg: TInfoDlg;

implementation

   uses UTablo, UGirisKutusuEx, ULog;
{$R *.dfm}

function IslemAd(ATip: Integer): string;
begin
  case ATip of
    0: Result := 'Silme';
    1: Result := 'Ekleme';
    2: Result := 'De'#$011F'i'#$015F'tirme';   // Değiştirme
  else
    Result := '?';
  end;
end;

function JsonDeger(V: TJSONValue): string;
begin
  if V = nil then
    Result := ''
  else if V is TJSONString then
    Result := TJSONString(V).Value
  else
    Result := V.ToString;
end;

procedure TInfoDlg.SutunlariHazirla;
var
  LW, LAlan, LDeger, LT, LO: Integer;
begin
  // --- Sol grid: gecmis (Tarih | Olay | Tipi) ---
  if LvGecmis.Columns.Count = 0 then
  begin
    with LvGecmis.Columns.Add do Caption := 'Tarih';
    with LvGecmis.Columns.Add do Caption := 'B'#$00F6'l'#$00FC'm';   // Bölüm: Başlık / Detay
    with LvGecmis.Columns.Add do Caption := 'Tipi';    // Ekleme/Değiştirme/Silme
  end;
  LW := LvGecmis.ClientWidth - 24;
  if LW < 160 then LW := 160;
  LT := LW * 6 div 12;   // Tarih genis
  LO := LW * 3 div 12;
  LvGecmis.Columns[0].Width := LT;
  LvGecmis.Columns[1].Width := LO;
  LvGecmis.Columns[2].Width := LW - LT - LO;

  // --- Sag grid: detay (Alan | Önceki | Sonraki) ---
  if LvDetay.Columns.Count = 0 then
  begin
    with LvDetay.Columns.Add do Caption := 'Alan';
    with LvDetay.Columns.Add do Caption := #$00D6'nceki';   // Önceki
    with LvDetay.Columns.Add do Caption := 'Sonraki';
  end;
  LW := LvDetay.ClientWidth - 24;
  if LW < 180 then LW := 180;
  LAlan  := LW * 2 div 12;
  LDeger := LW * 5 div 12;
  LvDetay.Columns[0].Width := LAlan;
  LvDetay.Columns[1].Width := LDeger;
  LvDetay.Columns[2].Width := LW - LAlan - LDeger;
end;

// Grid basliginin (header) OS temasini kaldirir -> klasik GRI baslik zemini.
procedure HeaderGriYap(ALV: TListView);
var
  H: HWND;
begin
  if (ALV = nil) or (not ALV.HandleAllocated) then Exit;
  H := HWND(SendMessage(ALV.Handle, LVM_GETHEADER, 0, 0));
  if H <> 0 then
    SetWindowTheme(H, '', '');
end;

procedure TInfoDlg.FormShow(Sender: TObject);
begin
   SutunlariHazirla;
   HeaderGriYap(LvGecmis);   // baslik zemini gri (ikisi de)
   HeaderGriYap(LvDetay);

   if GenelModu then
   begin
     // MenuYeniLog: 2 sekme, Genel (grupli log listesi) aktif.
     cxTabSheet1.TabVisible := True;
     cxPageControl1.ActivePage := cxTabSheet1;
     // Bolum combo + tarih varsayilani (BUGUN). Olaylardan ONCE atanir ki
     // ilk deger atamalari erken sorgu tetiklemesin.
     BolumleriYukle;
     DateTarihBas.Date := Date;
     DateTarihBit.Date := Date;
     FiltreOlaylariBagla;
     TabLogYukle;
   end
   else
   begin
     // Kayit bazli cagri (InfoGoster): yalnizca Detay sekmesi, o kaydin gecmisi.
     cxTabSheet1.TabVisible := False;
     cxPageControl1.ActivePage := cxTabSheet2;
     // NOT: ust ekleyen/degistiren paneli kaldirildi; islemi yapan kisi zaten
     // Detay grid'in en altinda (Ekleyen/Degistiren/Silen) gosteriliyor.

     LogGecmisiYukle;
   end;
end;

// Genel sekmesi: ISLEMLOG (LOG<yyyy> birlesimi) listesini TabLog'a yukler.
// FIRMA=kullanici (REHBER), ANAHTAR=modul/gorunum (TABLOLAR), ISLEM=islem adi.
// ISLEMTIPI + BILGI_JSON detay sekmesi icin ekstra tasinir (grid'de gosterilmez).
procedure TInfoDlg.TabLogYukle;
var
  LW, LTip: string;

  function Esc(const S: string): string;   // ' -> '' (SQL literal guvenli)
  begin
    Result := StringReplace(Trim(S), '''', '''''', [rfReplaceAll]);
  end;

  // Metin kolonu icin "iceren" (LIKE %v%) kosul. Bos ise ''.
  function MetinKosul(const ACol, ADeger: string): string;
  var v: string;
  begin
    Result := '';
    v := Esc(ADeger);
    if v <> '' then
      Result := ' AND ' + ACol + ' LIKE ''%' + v + '%''';
  end;

  function Tipler: string;   // islem checkbox'lari; hicbiri secili degilse '' (=tumu)
  begin
    Result := '';
    if CheckEkleme.Checked     then Result := Result + '1,';
    if CheckDegistirme.Checked then Result := Result + '2,';
    if CheckSilme.Checked      then Result := Result + '0,';
    if Result <> '' then SetLength(Result, Length(Result) - 1);
  end;

begin
  TabLog.Close;

  // --- WHERE: filtre kontrollerinden. Bos alan -> o filtre yok (tum kayitlar). ---
  LW := ' WHERE 1=1';
  // Tarih filtresi SADECE genel arama (Ad/Icerik) ve Kayit No bosken uygulanir.
  // Onlar girilince tarih araligina bakma -> aramanin/kaydin TUM gecmisi gelsin.
  if (Trim(EditKayitNo.Text) = '') and (Trim(EditIcerik.Text) = '') then
  begin
    if not VarIsNull(DateTarihBas.EditValue) then
      LW := LW + ' AND L.TARIH >= ''' + FormatDateTime('yyyymmdd', DateTarihBas.Date) + ' 00:00:00''';
    if not VarIsNull(DateTarihBit.EditValue) then
      LW := LW + ' AND L.TARIH <= ''' + FormatDateTime('yyyymmdd', DateTarihBit.Date) + ' 23:59:59''';
  end;
  // Kullanici (REHBER firma) - arama turu ile
  LW := LW + MetinKosul('ISNULL(R.FIRMA, CAST(L.KULLANICIID AS varchar(20)))', Kullanici.Text);
  // Bolum: TABLOLAR modul listesinden secim (tam eslesme). Bos = tumu.
  if Trim(txtTablo.Text) <> '' then
    LW := LW + ' AND T.MODUL = ''' + Esc(txtTablo.Text) + '''';
  // Kayit No (USTKAYITID) - arama turu ile
  LW := LW + MetinKosul('CAST(L.USTKAYITID AS varchar(20))', EditKayitNo.Text);
  // Bilgisayar (ISTASYON) - arama turu ile (txtAlan kutusu bu amacla kullaniliyor)
  LW := LW + MetinKosul('L.ISTASYON', txtAlan.Text);
  // Ad/Icerik (cift yonlu): once LOGREFERANS'ta ad/kod (HIZLI, indeksli, silinmis
  // kayit dahil), sonra log JSON (BILGI) icerigi (yavas). Ikisinden biri eslesirse gelir.
  if Trim(EditIcerik.Text) <> '' then
  begin
    var LAra: string := Esc(EditIcerik.Text);
    if CheckIcerik.Checked then
      // "Icerikten Ara" secili: log JSON (BILGI) icinde detayli arama (yavas)
      LW := LW + ' AND CAST(DECOMPRESS(L.BILGI) AS nvarchar(max)) LIKE ''%' + LAra + '%'''
    else
      // Varsayilan: bagli cari/IK (REHBERID) veya stok (STOKID) KOD/AD icinde (hizli)
      LW := LW + ' AND EXISTS(SELECT 1 FROM LOGREFERANS r WHERE' +
        ' ((r.KAYITID=L.REHBERID AND r.TABLOID IN (71,73,74)) OR (r.KAYITID=L.STOKID AND r.TABLOID=88))' +
        ' AND (r.AD LIKE ''%' + LAra + '%'' OR r.KOD LIKE ''%' + LAra + '%''))';
  end;
  // Islem tipi (Ekleme=1 / Degistirme=2 / Silme=0). Hicbiri secili degilse tumu.
  LTip := Tipler;
  if LTip <> '' then LW := LW + ' AND L.ISLEMTIPI IN (' + LTip + ')';

  // Master (USTKAYITID) + islem tipi + GUN bazinda GRUPLU.
  TabLog.SQL.Text :=
    'SELECT TARIH = MAX(L.TARIH), GUN = CAST(L.TARIH AS date),' +
    ' KAYITNO = L.USTKAYITID, USTTABLOID = L.USTTABLOID, L.ISLEMTIPI,' +
    ' ISLEM = CASE L.ISLEMTIPI WHEN 0 THEN N''Silme'' WHEN 1 THEN N''Ekleme''' +
    '         WHEN 2 THEN N''De' + #$011F + 'i' + #$015F + 'tirme'' ELSE ''?'' END,' +
    ' FIRMA = MAX(ISNULL(R.FIRMA, CAST(L.KULLANICIID AS varchar(20)))),' +
    ' PCADI = MAX(L.ISTASYON),' +
    ' ANAHTAR = MAX(COALESCE(T.MODUL, T.TABLOADI, CAST(L.USTTABLOID AS varchar(20)))),' +
    // Kod/Ad: once kaydin KENDI referansi (kart: KAYITID=USTKAYITID, TABLOID=USTTABLOID),
    // yoksa bagli cari/IK (REHBERID) veya stok (STOKID) - LOGREFERANS''tan (guncel).
    // Cek/Senet (315/316/318/319): kart kendi muhasebe kodu yerine borclu/alacakli CARI
    // (REHBERID) kod/adi gelsin -> LRk atlanir, LRc (cari) oncelikli. Diger kartlar kendi ad/kod''u
    // (NULLIF: bos ise bagli cari/stok''a gec).
    // Uretim Fisi (144) de cek/senet gibi: kart kendi kodu yerine once CARI (REHBERID);
    // cari yoksa uretilen stok (detay FATURA'da ADET>0 olan URUNID) kod/adi (LRuf).
    // COLLATE DATABASE_DEFAULT: LOGREFERANS (GENDEPO) ile STOKLAR (ana DB) farkli collation ->
    // COALESCE/MAX 'collation conflict' verir; hepsini ayni collation'a getir.
    ' KOD = MAX(COALESCE(CASE WHEN L.USTTABLOID IN (315,316,318,319,144) THEN NULL ELSE NULLIF(LRk.KOD,'''') COLLATE DATABASE_DEFAULT END, NULLIF(LRc.KOD,'''') COLLATE DATABASE_DEFAULT, NULLIF(LRs.KOD,'''') COLLATE DATABASE_DEFAULT, NULLIF(LRuf.KOD,'''') COLLATE DATABASE_DEFAULT)),' +
    ' AD  = MAX(COALESCE(CASE WHEN L.USTTABLOID IN (315,316,318,319,144) THEN NULL ELSE NULLIF(LRk.AD,'''') COLLATE DATABASE_DEFAULT  END, NULLIF(LRc.AD,'''') COLLATE DATABASE_DEFAULT,  NULLIF(LRs.AD,'''') COLLATE DATABASE_DEFAULT,  NULLIF(LRuf.AD,'''') COLLATE DATABASE_DEFAULT)),' +
    ' ADET = COUNT(*)' +
    ' FROM ISLEMLOG L' +
    ' LEFT JOIN REHBER R ON R.ID = L.KULLANICIID' +
    ' LEFT JOIN TABLOLAR T ON T.TABLOID = L.USTTABLOID' +
    ' OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS WHERE KAYITID=L.USTKAYITID AND TABLOID=L.USTTABLOID ORDER BY ID DESC) LRk' +
    ' OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS WHERE KAYITID=L.REHBERID AND TABLOID IN (71,73,74) ORDER BY ID DESC) LRc' +
    ' OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS WHERE KAYITID=L.STOKID   AND TABLOID=88          ORDER BY ID DESC) LRs' +
    // Uretim Fisi (144): uretilen stok = detay (FATURA) ADET>0 olan URUNID -> STOKLAR kod/ad
    ' OUTER APPLY (SELECT TOP 1 KOD=s.KOD, AD=s.STOKADI FROM FATURA f JOIN STOKLAR s ON s.ID=f.URUNID' +
    '   WHERE L.USTTABLOID=144 AND f.FATBASID=L.USTKAYITID AND f.ADET>0 ORDER BY f.ID) LRuf' +
    LW +
    ' GROUP BY CAST(L.TARIH AS date), L.USTKAYITID, L.USTTABLOID, L.ISLEMTIPI' +
    ' ORDER BY MAX(L.TARIH) DESC';
  try
    TabLog.Open;
  except
    // ISLEMLOG view yok / erisim yok -> sessiz gec (grid bos)
  end;
  GeriAlButonGuncelle;   // secili satir degisti -> "Geri Al" gorunurlugu
end;

// Filtre kontrollerinin olaylarini TabLogYukle'ye baglar (kod ile, bir kez).
procedure TInfoDlg.FiltreOlaylariBagla;
begin
  DateTarihBas.Properties.OnEditValueChanged := FiltreUygula;
  DateTarihBit.Properties.OnEditValueChanged := FiltreUygula;
  DateTarihBas.Properties.ImmediatePost := True;   // deger degisince ANINDA tetikle
  DateTarihBit.Properties.ImmediatePost := True;
  CheckEkleme.Properties.OnEditValueChanged := FiltreUygula;
  CheckDegistirme.Properties.OnEditValueChanged := FiltreUygula;
  CheckSilme.Properties.OnEditValueChanged := FiltreUygula;
  txtTablo.Properties.OnEditValueChanged := FiltreUygula;   // Bolum combo: secimde
  // Metin button-edit'ler: yazdikca otomatik suz (OnChange).
  Kullanici.Properties.OnChange := FiltreUygula;
  txtAlan.Properties.OnChange := FiltreUygula;
  EditKayitNo.Properties.OnChange := FiltreUygula;
  // Kullanici butonu -> personel listesi
  Kullanici.Properties.OnButtonClick := KullaniciButonClick;
  // Bilgisayar / Kayit No butonlari: giris (BilgiAl) + temizle ('-')
  txtAlan.Properties.OnButtonClick := BilgiAlButonClick;
  EditKayitNo.Properties.OnButtonClick := BilgiAlButonClick;
  EditIcerik.Properties.OnButtonClick := BilgiAlButonClick;  // BilgiAl giris + '-' temizle
  EditIcerik.Properties.OnChange := FiltreUygula;             // secim/temizlemede suz
  CheckIcerik.Properties.OnEditValueChanged := FiltreUygula;  // Icerikten Ara: mod degisince suz
  // Button-edit'lerin herhangi bir yerine tiklayinca giris ekrani (picker) acilsin.
  Kullanici.OnClick   := ButtonEditTiklama;
  txtAlan.OnClick     := ButtonEditTiklama;
  EditKayitNo.OnClick := ButtonEditTiklama;
  EditIcerik.OnClick  := ButtonEditTiklama;
end;

procedure TInfoDlg.FiltreUygula(Sender: TObject);
begin
  if GenelModu then TabLogYukle;
end;

// Button-edit'in herhangi bir yerine tiklayinca ilgili giris ekranini (picker) acar.
procedure TInfoDlg.ButtonEditTiklama(Sender: TObject);
begin
  if FTiklamaAcik then Exit;   // modal sonrasi tekrar tetiklenmesin
  FTiklamaAcik := True;
  try
    if Sender = Kullanici then KullaniciButonClick(Sender, 0)   // personel listesi
    else BilgiAlButonClick(Sender, 0);                          // BilgiAl giris
  finally
    FTiklamaAcik := False;
  end;
end;

// Bolum combo'sunu TABLOLAR'daki modul listesiyle (Fatura/Fiş/İrsaliye/Sipariş...)
// doldurur; ilk oge BOS (= tum bolumler).
procedure TInfoDlg.BolumleriYukle;
begin
  txtTablo.Properties.Items.Clear;
  txtTablo.Properties.Items.Add('');   // bos = tumu
  try
    Tablo.TablodanSorguAc(1,
      'select distinct MODUL from TABLOLAR where MODUL is not null and MODUL<>'''' order by MODUL');
    while not Tablo.Query1.Eof do
    begin
      txtTablo.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
      Tablo.Query1.Next;
    end;
  except
  end;
  txtTablo.ItemIndex := 0;   // bos secili
end;

// Kullanici filtresi butonu: personel listesini (KULLANICI+REHBER) combo diyalogunda
// gosterir; secilen isim Kullanici kutusuna yazilir (OnChange -> suzer).
procedure TInfoDlg.KullaniciButonClick(Sender: TObject; AButtonIndex: Integer);
var
  LListe: TStringList;
  LSecim: Variant;
begin
  if AButtonIndex = 1 then   // '-' temizle
  begin
    TcxButtonEdit(Sender).Text := '';   // OnChange -> suzer
    Exit;
  end;
  LListe := TStringList.Create;
  try
    try
      Tablo.TablodanSorguAc(1,
        'select distinct R.FIRMA from KULLANICI K inner join REHBER R on R.ID=K.REHBERID ' +
        'where R.FIRMA is not null and R.FIRMA<>'''' order by R.FIRMA');
      while not Tablo.Query1.Eof do
      begin
        LListe.Add(Tablo.Query1.Fields[0].AsString);
        Tablo.Query1.Next;
      end;
    except
    end;
    if LListe.Count = 0 then Exit;
    LSecim := Kullanici.Text;
    if TGirisKutusuEx.BilgiAlEx('Personel se' + #$00E7 + 'in',
         TGirdiDenetimleri.Create.ComboBox('Kullan' + #$0131 + 'c' + #$0131,
           @LSecim, LListe, csDropDownList, False, nil, 320)) = mrOk then
      Kullanici.Text := VarToStr(LSecim);   // OnChange -> suzer
  finally
    LListe.Free;
  end;
end;

// Bilgisayar / Kayit No butonlari: buton0 = BilgiAl ile deger gir, buton1 ('-') = temizle.
procedure TInfoDlg.BilgiAlButonClick(Sender: TObject; AButtonIndex: Integer);
var
  LEdit: TcxButtonEdit;
  LDeg: Variant;
  LBaslik: string;
begin
  LEdit := TcxButtonEdit(Sender);
  if AButtonIndex = 1 then          // '-' temizle
  begin
    LEdit.Text := '';               // OnChange -> suzer
    Exit;
  end;
  if LEdit = EditKayitNo then LBaslik := 'Kay' + #$0131 + 't No'
  else if LEdit = EditIcerik then LBaslik := 'Ad/' + #$0130 + #$00E7 + 'erik'
  else LBaslik := 'Bilgisayar';
  LDeg := LEdit.Text;
  if TGirisKutusuEx.BilgiAlEx(LBaslik,
       TGirdiDenetimleri.Create.Edit(LBaslik, @LDeg)) = mrOk then
    LEdit.Text := VarToStr(LDeg);   // OnChange -> suzer
end;

// Genel'de secili GRUBUN (USTKAYITID + ISLEMTIPI + GUN) tum log satirlarini Detay
// sekmesine yukler: LvGecmis'e liste (o gunku tum degisiklikler), LvDetay'a secili
// satirin alan detayi. Ornek: 11-12-13'teki 3 degisiklik burada ayri ayri gorulur.
procedure TInfoDlg.GenelSatirDetayGoster;
var
  LSat, LGorunum: string;
  LTip, LTabloID, LUstT: Integer;
begin
  if not Assigned(FJsonlar) then FJsonlar := TStringList.Create;
  if not Assigned(FTabloIDler) then FTabloIDler := TStringList.Create;
  if not Assigned(FKullaniciAdlari) then FKullaniciAdlari := TStringList.Create;
  FJsonlar.Clear;
  FTabloIDler.Clear;
  FKullaniciAdlari.Clear;
  LvGecmis.Items.Clear;
  LvDetay.Items.Clear;
  if (not TabLog.Active) or TabLog.IsEmpty then Exit;

  LUstT := TabLog.FieldByName('USTTABLOID').AsInteger;
  try
    Tablo.TablodanSorguAc(1,
      'select i.TARIH, i.ISLEMTIPI, i.TABLOID, t.GORUNUM, ' +
      'KULLANICIAD = ISNULL((select FIRMA from REHBER where ID=i.KULLANICIID), CAST(i.KULLANICIID as varchar(20))), ' +
      'cast(DECOMPRESS(i.BILGI) as nvarchar(max)) as BILGI_JSON ' +
      'from ISLEMLOG i left join TABLOLAR t on t.TABLOID = i.TABLOID ' +
      'where i.USTTABLOID=' + IntToStr(LUstT) +
      ' and i.USTKAYITID=' + TabLog.FieldByName('KAYITNO').AsString +
      ' and cast(i.TARIH as date)=' +
        QuotedStr(FormatDateTime('yyyy-mm-dd', TabLog.FieldByName('GUN').AsDateTime)) +
      ' and i.ISLEMTIPI=' + TabLog.FieldByName('ISLEMTIPI').AsString +
      ' order by i.TARIH desc, case when i.TABLOID=i.USTTABLOID then 0 else 1 end, i.ID');
  except
    Exit;
  end;

  while not Tablo.Query1.Eof do
  begin
    LTip := Tablo.Query1.FieldByName('ISLEMTIPI').AsInteger;
    LTabloID := Tablo.Query1.FieldByName('TABLOID').AsInteger;
    LGorunum := Tablo.Query1.FieldByName('GORUNUM').AsString;
    LSat := LGorunum;
    if (LSat = '') and (LTabloID <> LUstT) then
      LSat := '[' + IntToStr(LTabloID) + ']';
    with LvGecmis.Items.Add do
    begin
      Caption := FormatDateTime('dd.mm.yyyy hh:nn',
                   Tablo.Query1.FieldByName('TARIH').AsDateTime);
      SubItems.Add(LSat);
      SubItems.Add(IslemAd(LTip));
      Data := TObject(NativeInt(LTip));
    end;
    FJsonlar.Add(Tablo.Query1.FieldByName('BILGI_JSON').AsString);
    FTabloIDler.Add(IntToStr(LTabloID));
    FKullaniciAdlari.Add(Tablo.Query1.FieldByName('KULLANICIAD').AsString);
    Tablo.Query1.Next;
  end;

  if LvGecmis.Items.Count > 0 then
    LvGecmis.Items[0].Selected := True;   // OnSelectItem -> LvDetay dolar
end;

// Detay sekmesine gecince Genel'de duran satirin icerigini goster.
procedure TInfoDlg.cxPageControl1Change(Sender: TObject);
begin
  // Sadece browse (2 sekme) modunda Genel->Detay drill-down. Kayit modunda
  // Detay zaten kaydin gecmisiyle dolu; dokunma.
  if GenelModu and (cxPageControl1.ActivePage = cxTabSheet2) then
    GenelSatirDetayGoster;
  GeriAlButonGuncelle;   // "Geri Al" yalnizca Liste sekmesinde + SILME satirinda
end;

// ISLEMLOG (yillik LOG<yyyy> birlesim view'i) uzerinden bu kaydin islem gecmisini
// solda tarih listesine yukler. Her satirin BILGI json'u FJsonlar'da, islem tipi
// LvGecmis satirinin Data'sinda (islem tipi) tutulur.
procedure TInfoDlg.LogGecmisiYukle;
var
  LSQL, LSat, LGorunum: string;
  LTip, LTabloID, LUstT: Integer;
  LUstK: Int64;
  // Bir JSON nesnesinin dis suslu parantezlerini soyar: {"a":1} -> "a":1
  function _IcJson(const S: string): string;
  var T: string;
  begin
    T := Trim(S);
    if (Length(T) >= 2) and (T[1] = '{') and (T[Length(T)] = '}') then
      Result := Trim(Copy(T, 2, Length(T) - 2))
    else
      Result := '';
  end;
  // Bir grubu (ayni an+tablo+tip) tek LvGecmis satiri yapar; parcalari tek JSON'da birlestirir.
  procedure _EmitGrup(ATarih: TDateTime; const ASat: string; ATip, ATabloID: Integer; const AKullanici: string; AParts: TStringList);
  var k: Integer; LMerged: string;
  begin
    LMerged := '';
    for k := 0 to AParts.Count - 1 do
    begin
      if k > 0 then LMerged := LMerged + ',';
      LMerged := LMerged + AParts[k];
    end;
    if LMerged <> '' then LMerged := '{' + LMerged + '}';
    with LvGecmis.Items.Add do
    begin
      Caption := FormatDateTime('dd.mm.yyyy hh:nn', ATarih);
      SubItems.Add(ASat);
      SubItems.Add(IslemAd(ATip));
      Data := TObject(NativeInt(ATip));
    end;
    FJsonlar.Add(LMerged);
    FTabloIDler.Add(IntToStr(ATabloID));
    FKullaniciAdlari.Add(AKullanici);
  end;
begin
  if not Assigned(FJsonlar) then FJsonlar := TStringList.Create;
  if not Assigned(FTabloIDler) then FTabloIDler := TStringList.Create;
  if not Assigned(FKullaniciAdlari) then FKullaniciAdlari := TStringList.Create;
  FJsonlar.Clear;
  FTabloIDler.Clear;
  FKullaniciAdlari.Clear;
  LvGecmis.Items.Clear;
  LvDetay.Items.Clear;
  if ID <= 0 then Exit;

  // ISLEMLOG (synonym -> GENDEPO view) kullanilabilir mi? Henuz hic log yazilmamis
  // / view olusmamis olabilir. sys.synonyms + OBJECT_ID sorgusu HIC hata vermez;
  // yoksa sessiz cikariz -> exception olmaz (IDE debugger'inda da patlamaz).
  try
    Tablo.TablodanSorguAc(1,
      'select ISVAR=case when exists(select 1 from sys.synonyms s ' +
      'where s.name=''ISLEMLOG'' and OBJECT_ID(s.base_object_name) is not null) ' +
      'then 1 else 0 end');
    if Tablo.Query1.Fields[0].AsInteger = 0 then Exit;
  except
    Exit;
  end;

  // 1) Acilan kaydin ait oldugu MASTER (ust) anahtarini bul. Kayit master ise
  //    ust=kendisi; detay (ör. FATURA satiri) ise ust=FATBASLIK. Boylece nereden
  //    acilirsa acilsin ayni butun (master+detay) gorulur.
  LUstT := TabloNo;   // varsayilan: kendisi master
  LUstK := ID;
  try
    Tablo.TablodanSorguAc(1,
      'select top 1 USTTABLOID, USTKAYITID from ISLEMLOG ' +
      'where TABLOID=' + IntToStr(TabloNo) + ' and KAYITID=' + IntToStr(ID) +
      ' order by ID desc');
    if not Tablo.Query1.Eof then
    begin
      if not Tablo.Query1.FieldByName('USTTABLOID').IsNull then
        LUstT := Tablo.Query1.FieldByName('USTTABLOID').AsInteger;
      if not Tablo.Query1.FieldByName('USTKAYITID').IsNull then
        LUstK := Tablo.Query1.FieldByName('USTKAYITID').AsLargeInt;
    end;
  except
    Exit;   // ISLEMLOG view yoksa / erisim yoksa sessiz gec
  end;

  // 2) Ust altindaki TUM loglar. Master (TABLOID=USTTABLOID) USTTE, detaylar altta;
  //    her grup icinde en yeni ustte. TABLOLAR ile TABLOID->GORUNUM (Başlık/Detay).
  LSQL := 'select i.TARIH, i.ISLEMTIPI, i.TABLOID, i.KAYITID, t.GORUNUM, ' +
          'KULLANICIAD = ISNULL((select FIRMA from REHBER where ID=i.KULLANICIID), CAST(i.KULLANICIID as varchar(20))), ' +
          'cast(DECOMPRESS(i.BILGI) as nvarchar(max)) as BILGI_JSON ' +
          'from ISLEMLOG i left join TABLOLAR t on t.TABLOID = i.TABLOID ' +
          'where i.USTKAYITID=' + IntToStr(LUstK);
  if LUstT > 0 then
    LSQL := LSQL + ' and i.USTTABLOID=' + IntToStr(LUstT);
  // Tarihe gore AZALAN (en yeni ustte); ayni tarihte master (Başlık) detaydan once.
  // Saniye+tablo+KAYITID+tip bazli sirala ki ayni gruptakiler bitisik gelsin.
  LSQL := LSQL + ' order by convert(char(19), i.TARIH, 120) desc, ' +
          'case when i.TABLOID=i.USTTABLOID then 0 else 1 end, i.TABLOID, i.KAYITID, i.ISLEMTIPI, i.ID desc';

  try
    Tablo.TablodanSorguAc(1, LSQL);
  except
    Exit;
  end;

  // Ayni (saniye + tablo + islem tipi) satirlari TEK gruba topla; JSON parcalarini birlestir.
  // Boylece solda tek satir, sagda (LvDetay) o gruptaki tum alan degisiklikleri alt alta gelir.
  var LCurKey: string := #1;
  var LParts: TStringList := TStringList.Create;
  var LGTarih: TDateTime := 0;
  var LGSat: string := '';
  var LGTip: Integer := 0;
  var LGTabloID: Integer := 0;
  var LGKullanici: string := '';
  try
    while not Tablo.Query1.Eof do
    begin
      LTip := Tablo.Query1.FieldByName('ISLEMTIPI').AsInteger;
      LTabloID := Tablo.Query1.FieldByName('TABLOID').AsInteger;
      LGorunum := Tablo.Query1.FieldByName('GORUNUM').AsString;
      // Olay = TABLOLAR gorunum adi (Başlık/Detay/İletişim...); yoksa tablo kodu.
      LSat := LGorunum;
      if (LSat = '') and (LTabloID <> LUstT) then
        LSat := '[' + IntToStr(LTabloID) + ']';
      var LTarih: TDateTime := Tablo.Query1.FieldByName('TARIH').AsDateTime;
      var LKayitID: Int64 := Tablo.Query1.FieldByName('KAYITID').AsLargeInt;
      var LKey: string := FormatDateTime('yyyymmddhhnnss', LTarih) + '|' +
                          IntToStr(LTabloID) + '|' + IntToStr(LKayitID) + '|' + IntToStr(LTip);
      if LKey <> LCurKey then
      begin
        if LCurKey <> #1 then _EmitGrup(LGTarih, LGSat, LGTip, LGTabloID, LGKullanici, LParts);
        LParts.Clear;
        LCurKey := LKey;
        LGTarih := LTarih; LGSat := LSat; LGTip := LTip; LGTabloID := LTabloID;
        LGKullanici := Tablo.Query1.FieldByName('KULLANICIAD').AsString;
      end;
      var LIc: string := _IcJson(Tablo.Query1.FieldByName('BILGI_JSON').AsString);
      if LIc <> '' then LParts.Add(LIc);
      Tablo.Query1.Next;
    end;
    if LCurKey <> #1 then _EmitGrup(LGTarih, LGSat, LGTip, LGTabloID, LGKullanici, LParts);  // son grup
  finally
    LParts.Free;
  end;

  if LvGecmis.Items.Count > 0 then
    LvGecmis.Items[0].Selected := True;   // OnSelectItem -> detay dolar
end;

// LOGCOZUM haritasini bellege alir (bir kez). Anahtar: 'ALAN|TABLOID' (TABLOID bos=genel).
procedure TInfoDlg.CozumleriYukle;
begin
  if Assigned(FCozumler) then Exit;   // bir kez
  FCozumler := TStringList.Create;
  FCozumCache := TStringList.Create;
  try
    Tablo.TablodanSorguAc(1,
      'select ALAN, TABLOID, KAYNAKTABLO, IDKOLON, ADKOLON, ISNULL(FILTRE,'''') FILTRE ' +
      'from LOGCOZUM where AKTIF=1');
    while not Tablo.Query1.Eof do
    begin
      FCozumler.Add(
        UpperCase(Tablo.Query1.FieldByName('ALAN').AsString) + '|' +
        Tablo.Query1.FieldByName('TABLOID').AsString + '=' +
        Tablo.Query1.FieldByName('KAYNAKTABLO').AsString + '|' +
        Tablo.Query1.FieldByName('IDKOLON').AsString + '|' +
        Tablo.Query1.FieldByName('ADKOLON').AsString + '|' +
        Tablo.Query1.FieldByName('FILTRE').AsString);
      Tablo.Query1.Next;
    end;
  except
    // LOGCOZUM yoksa sessiz: cozum yapilmaz, degerler ID kalir
  end;
end;

// Bir alan degerini (ID) LOGCOZUM'a gore ad'a cevirir. Eslesme/sonuc yoksa ADeger doner.
function TInfoDlg.DegerCoz(ATabloID: Integer; const AAlan, ADeger: string;
  AKardesler: TStrings = nil): string;
var
  LTanim, LKaynak, LIdKol, LAdKol, LFiltre, LCacheKey: string;
  LParts: TArray<string>;
  i: Integer;
  LQ: TFDQuery;
var
  LDummy: Int64;
begin
  Result := ADeger;
  if (Trim(ADeger) = '') or (not Assigned(FCozumler)) then Exit;
  // Tum lookup IDKOLON'lari sayisal (ID/DEGER/TUR/TIP...). Deger sayisal degilse
  // (ör. bir alan firma ADI tutuyorsa) cozme -> 'convert to int' hatasi olmaz.
  if not TryStrToInt64(Trim(ADeger), LDummy) then Exit;
  // Tanim bul: once tabloya ozel (ALAN|TABLOID), yoksa genel (ALAN|).
  LTanim := FCozumler.Values[UpperCase(AAlan) + '|' + IntToStr(ATabloID)];
  if LTanim = '' then LTanim := FCozumler.Values[UpperCase(AAlan) + '|'];
  if LTanim = '' then Exit;   // bu alan cozumlenmez
  // LTanim = KAYNAKTABLO|IDKOLON|ADKOLON|FILTRE
  LParts := LTanim.Split(['|']);
  if Length(LParts) < 3 then Exit;
  LKaynak := LParts[0]; LIdKol := LParts[1]; LAdKol := LParts[2];
  if Length(LParts) >= 4 then LFiltre := LParts[3] else LFiltre := '';
  // FILTRE'de {ALAN} placeholder'lari -> ayni kayittaki kardes alan degerleri.
  // (ör. ALTSEKTOR: 'BOLUM=-2204{SEKTOR}' -> SEKTOR=52 ise 'BOLUM=-220452')
  if (Pos('{', LFiltre) > 0) then
  begin
    if Assigned(AKardesler) then
      for i := 0 to AKardesler.Count - 1 do
        LFiltre := StringReplace(LFiltre, '{' + AKardesler.Names[i] + '}',
                     AKardesler.ValueFromIndex[i], [rfReplaceAll, rfIgnoreCase]);
    if Pos('{', LFiltre) > 0 then Exit;   // cozulemeyen placeholder -> ID kalir
  end;
  // Cache (cozulmus filtre dahil: parent'a gore ad degisebilir)
  LCacheKey := IntToStr(ATabloID) + '|' + UpperCase(AAlan) + '|' + ADeger + '|' + LFiltre;
  i := FCozumCache.IndexOfName(LCacheKey);
  if i >= 0 then Exit(FCozumCache.ValueFromIndex[i]);
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text := 'select top 1 ' + LAdKol + ' from ' + LKaynak +
        ' where ' + LIdKol + ' = :PDEGER' +
        IfThen(Trim(LFiltre) <> '', ' and (' + LFiltre + ')', '');
      LQ.ParamByName('PDEGER').AsString := ADeger;
      LQ.Open;
      if (not LQ.IsEmpty) and (Trim(LQ.Fields[0].AsString) <> '') then
        Result := Trim(LQ.Fields[0].AsString);
    finally
      LQ.Free;
    end;
  except
    // cozum sorgusu patlarsa ID kalir
  end;
  FCozumCache.Add(LCacheKey + '=' + Result);   // cache'le (ayni deger tekrar sorgulanmaz)
end;

// Secili kaydin BILGI json'unu 3 sutunlu grid'e doker: Alan | Onceki | Sonraki.
//   Degisiklik: {"ALAN":{"e":..,"y":..}}  Tek deger: ekle->Sonraki, sil->Onceki.
//   ATabloID: bu kaydin log tablosu -> LOGCOZUM ile deger (ID) -> ad cevrimi icin.
procedure TInfoDlg.DetayGoster(const ABilgiJSON: string; ATip: Integer; ATabloID: Integer = 0; const AKullaniciAd: string = '');
var
  LParsed: TJSONValue;
  LObj: TJSONObject;
  LPair: TJSONPair;
  LVal: TJSONValue;
  LItem: TListItem;
  LOnc, LSon, LAlan: string;
  LGorulen: TStringList;   // ayni alan adini (ör. İlgili) tek kez goster
  LKardes: TStringList;    // ALAN=deger (tum alanlar) -> {ALAN} placeholder cozumu icin
begin
  CozumleriYukle;
  LvDetay.Items.BeginUpdate;
  LGorulen := TStringList.Create;
  LGorulen.Sorted := True;
  LKardes := TStringList.Create;
  try
    LvDetay.Items.Clear;
    // Sutun basliklari islem tipine gore: degisme -> Onceki|Sonraki; ekleme/silme -> Bilgisi|(bos)
    if LvDetay.Columns.Count >= 3 then
      if ATip = 2 then
      begin
        LvDetay.Columns[1].Caption := #$00D6'nceki';
        LvDetay.Columns[2].Caption := 'Sonraki';
      end
      else
      begin
        LvDetay.Columns[1].Caption := 'Bilgisi';
        LvDetay.Columns[2].Caption := '';
      end;
    if Trim(ABilgiJSON) = '' then Exit;
    LParsed := TJSONObject.ParseJSONValue(ABilgiJSON);
    if not (LParsed is TJSONObject) then
    begin
      if LParsed <> nil then LParsed.Free;
      Exit;
    end;
    try
      LObj := TJSONObject(LParsed);
      // Once TUM alanlarin guncel degerini topla (ALAN=deger): {ALAN} placeholder icin.
      // Degisiklikte yeni (y), tek degerde deger. Placeholder cozumu (ör. ALTSEKTOR<-SEKTOR).
      for LPair in LObj do
      begin
        LVal := LPair.JsonValue;
        if LVal is TJSONObject then
          LKardes.Values[LPair.JsonString.Value] := JsonDeger(TJSONObject(LVal).GetValue('y'))
        else
          LKardes.Values[LPair.JsonString.Value] := JsonDeger(LVal);
      end;
      for LPair in LObj do
      begin
        if LGorulen.IndexOf(LPair.JsonString.Value) >= 0 then Continue;  // tekrar eden alan gosterme
        LGorulen.Add(LPair.JsonString.Value);
        LAlan := LPair.JsonString.Value;
        LVal := LPair.JsonValue;
        if LVal is TJSONObject then
        begin
          LOnc := JsonDeger(TJSONObject(LVal).GetValue('e'));
          LSon := JsonDeger(TJSONObject(LVal).GetValue('y'));
        end
        else
        begin
          // Ekleme ve silme (tek deger): her zaman Onceki kolonda goster.
          LOnc := JsonDeger(LVal);
          LSon := '';
        end;
        // LOGCOZUM: alan degerlerini (ID) anlasilir ada cevir (eslesme yoksa ID kalir).
        LOnc := DegerCoz(ATabloID, LAlan, LOnc, LKardes);
        if LSon <> '' then LSon := DegerCoz(ATabloID, LAlan, LSon, LKardes);
        LItem := LvDetay.Items.Add;
        LItem.Caption := LAlan;      // Alan
        LItem.SubItems.Add(LOnc);    // Onceki
        LItem.SubItems.Add(LSon);    // Sonraki
      end;
      // EN ALTTA: islemi yapan kisi (LOG.KULLANICIID -> ad). Tarih zaten solda listede.
      if AKullaniciAd <> '' then
      begin
        LItem := LvDetay.Items.Add;
        case ATip of
          1: LItem.Caption := 'Ekleyen';
          0: LItem.Caption := 'Silen';
        else LItem.Caption := 'Değiştiren';
        end;
        LItem.SubItems.Add(AKullaniciAd);
        LItem.SubItems.Add('');
      end;
    finally
      LParsed.Free;
    end;
  finally
    LvDetay.Items.EndUpdate;
    LGorulen.Free;
    LKardes.Free;
  end;
end;

procedure TInfoDlg.LvGecmisSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if not Selected then Exit;
  if (Item = nil) or (Item.Index < 0) or (Item.Index >= FJsonlar.Count) then
  begin
    LvDetay.Items.Clear;
    Exit;
  end;
  var LTabloID: Integer := 0;
  if Assigned(FTabloIDler) and (Item.Index < FTabloIDler.Count) then
    LTabloID := StrToIntDef(FTabloIDler[Item.Index], 0);
  var LKulAd: string := '';
  if Assigned(FKullaniciAdlari) and (Item.Index < FKullaniciAdlari.Count) then
    LKulAd := FKullaniciAdlari[Item.Index];
  DetayGoster(FJsonlar[Item.Index], Integer(NativeInt(Item.Data)), LTabloID, LKulAd);
end;

// Satir rengi islem tipine gore: Ekleme yesil, Silme kirmizi, Degistirme mavi.
procedure TInfoDlg.LvGecmisCustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  case Integer(NativeInt(Item.Data)) of
    0: Sender.Canvas.Font.Color := clRed;     // Silme
    1: Sender.Canvas.Font.Color := clGreen;   // Ekleme
    2: Sender.Canvas.Font.Color := clBlue;    // Değiştirme
  else
    Sender.Canvas.Font.Color := clWindowText;
  end;
  DefaultDraw := True;
end;

// Genel grid (GridLOG) satir renklendirme: Ekleme yesil, Degistirme mavi, Silme kirmizi.
procedure TInfoDlg.GridLOGViewCustomDrawCell(Sender: TcxCustomGridTableView;
  ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  LTip: Integer;
begin
  LTip := StrToIntDef(VarToStr(AViewInfo.GridRecord.Values[GridLOGViewISLEMTIPI.Index]), -1);
  case LTip of
    0: ACanvas.Font.Color := clRed;     // Silme
    1: ACanvas.Font.Color := clGreen;   // Ekleme
    2: ACanvas.Font.Color := clBlue;    // Değiştirme
  end;
  // Secili satir: koyu zemin renkli yaziyi bogar -> ACIK zemin ver (yazi okunur kalsin).
  if AViewInfo.GridRecord.Selected then
    ACanvas.Brush.Color := $00D9F2FF;   // acik krem
end;

procedure TInfoDlg.FormDestroy(Sender: TObject);
begin
  FKullaniciAdlari.Free;
  FJsonlar.Free;
  FTabloIDler.Free;
  FCozumler.Free;
  FCozumCache.Free;
end;

// "Geri Al" butonu yalnizca Liste (Genel) sekmesinde ve secili satir SILME (0) ise gorunur.
procedure TInfoDlg.GeriAlButonGuncelle;
begin
  BtnGeriAl.Visible := GenelModu
    and (cxPageControl1.ActivePage = cxTabSheet1)
    and TabLog.Active and (not TabLog.IsEmpty)
    and (TabLog.FieldByName('ISLEMTIPI').AsInteger = 0);
end;

procedure TInfoDlg.GridLOGViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  GeriAlButonGuncelle;   // secili satir SILME ise butonu goster
end;

// Secili SILME grubunu (kart + tum detaylari) log JSON'larindan AYNI ID ile geri ekler.
procedure TInfoDlg.BtnGeriAlClick(Sender: TObject);
var
  LUstTab: Integer;
  LUstKayit: Int64;
  LGun: TDateTime;
  LAd, LSonuc: string;
begin
  if (not TabLog.Active) or TabLog.IsEmpty
     or (TabLog.FieldByName('ISLEMTIPI').AsInteger <> 0) then Exit;
  LUstTab   := TabLog.FieldByName('USTTABLOID').AsInteger;
  LUstKayit := TabLog.FieldByName('KAYITNO').AsLargeInt;
  LGun      := TabLog.FieldByName('GUN').AsDateTime;
  LAd       := TabLog.FieldByName('AD').AsString;
  if Application.MessageBox(
       PChar('Bu silme i'#$015F'lemi geri al'#$0131'ns'#$0131'n m'#$0131'? Kay'#$0131't ayn'#$0131' ID ile geri eklenecek.'#13#10 + LAd),
       PChar('Geri Al'), MB_YESNO or MB_ICONQUESTION) <> IDYES then Exit;
  LSonuc := LogGeriAl(LUstTab, LUstKayit, LGun);
  if LSonuc = '' then
  begin
    ShowMessage('Kay'#$0131't geri al'#$0131'nd'#$0131'.');
    TabLogYukle;   // listeyi tazele (silme kaydi hala loglarda kalir)
  end
  else
    ShowMessage(LSonuc);
end;

end.

unit ULog;

// ============================================================
// Islem/audit loglama. Tek tablo: GENDEPO.dbo.ISLEMLOG (ana DB'de synonym).
//
// Model: OTONOM. Log kendi (kalici, cache'li) baglantisinda yazilir; is
// transaction'ina karismaz, kilit tutmaz. Tum govde try/except -> loglama
// hicbir kosulda uygulamayi kirmaz/yavaslamaz. Cagriyi islem BASARILI olduktan
// sonra yap.
//
// Kullanim (ATabloID = LOG.TABLOID, yani TabNo_* sabitleri):
//   LogYaz(liEkle, TabNo_REHBER, RehberID,
//     TLogKurucu.Yeni.Deger('KOD','320.01').Deger('UNVAN','ABC Ltd'), 'Cari Kart');
//
//   LogYaz(liDegistir, TabNo_FATBASLIK_Giden, FaturaID,
//     TLogKurucu.Yeni.Alan('TUTAR', EskiTutar, YeniTutar)
//                    .Alan('ACIKLAMA', EskiAck, YeniAck), 'Fatura');
//
//   LogYaz(liSil, TabNo_STOK, StokID, TLogKurucu.Yeni.Deger('KOD', StokKod));
// ============================================================

interface

uses
  System.JSON, System.Classes, Data.DB, System.Generics.Collections;

type
  // 0=silme 1=ekleme 2=degistirme (ISLEMLOG.ISLEMTIPI ile birebir)
  TLogIslem = (liSil = 0, liEkle = 1, liDegistir = 2);

  // BILGI (json) kurucu. Fluent; TLogKurucu.Yeni ... .JSON.
  // liDegistir icin Alan(eski,yeni) -> "AD":{"e":..,"y":..} (esitse atlanir).
  // liEkle/liSil icin Deger(ad,deger) -> "AD":deger.
  TLogKurucu = class
  private
    FObj: TJSONObject;
  public
    constructor Create;
    destructor Destroy; override;
    class function Yeni: TLogKurucu; static;
    // Degisiklik (eski -> yeni). Ayni ise eklenmez.
    function Alan(const AAd, AEski, AYeni: string): TLogKurucu; overload;
    function Alan(const AAd: string; AEski, AYeni: Int64): TLogKurucu; overload;
    function Alan(const AAd: string; AEski, AYeni: Currency): TLogKurucu; overload;
    function Alan(const AAd: string; AEski, AYeni: Double): TLogKurucu; overload;
    // Tek deger (ekleme/silme ozeti).
    function Deger(const AAd, ADeger: string): TLogKurucu; overload;
    function Deger(const AAd: string; ADeger: Int64): TLogKurucu; overload;
    function Deger(const AAd: string; ADeger: Currency): TLogKurucu; overload;
    function BosMu: Boolean;
    function JSON: string;
  end;

// JSON'u string olarak veren temel cagri. ATabloID = LOG.TABLOID (TabNo_*).
// AUstTabloID/AUstKayitID: master (ör. FATBASLIK). Verilmezse ust=kendisidir;
// detay satirlarda (ör. FATURA) master gecirilir -> master+detay birlikte gorulur.
procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  const ABilgiJSON: string; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0); overload;

// TLogKurucu alan pratik cagri. AKurucu'nun SAHIPLIGINI ALIR ve serbest birakir
// (fluent kullanim icin). Kurucu bos ise BILGI NULL yazilir.
procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  AKurucu: TLogKurucu; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0); overload;

// ---- Master/detay snapshot + diff loglama (wizard'lar icin ortak) ----
// Bir dataset'in tum satirlarini (ID -> alan degerleri, alan index sirali) ASnap'e
// alir. Duzenleme oncesi (browse) cagrilir; imlec bookmark ile korunur.
procedure LogSnapshotAl(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>);

// ASnap (yukleme) ile ADataSet (mevcut) farkini loglar:
//   degisen alan -> liDegistir, snapshot'ta olmayan satir -> liEkle,
//   mevcutta olmayan snapshot satiri -> liSil.
// ADetayTabNo = satirin TABLOID'i; AUstTabNo/AUstID = master (ust) anahtari.
// ASnap bos ise tum satirlar EKLEME sayilir (yeni belge). Kaydetmeyi ASLA bozmaz.
procedure LogDiffKaydet(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64);

// Bir kaydin (ADataSet mevcut satiri) tum dolu fkData alanlarini EKLEME loglar.
procedure LogKayitEkle(ADataSet: TDataSet; ATabNo: Integer; AID: Int64;
  AUstTabNo: Integer = 0; AUstID: Int64 = 0);

// Bir kart silinirken detay tablosundaki (AUstKolon=AUstID [AND AEkKosul]) TUM
// satirlari SILME loglar. SILMEDEN ONCE cagrilmali (veri hala DB'de). Her satir ->
// liSil (ust=kart). AEkKosul: cok-amacli detay tablolari icin ek WHERE
// (ör. REHBERBILGI 'YERI=70', IMAJ 'YERI=1', GOREVKULLANICI 'TUR=11').
procedure LogDetaylariSil(const ADetayTablo, AUstKolon: string;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64; const AEkKosul: string = '');

// Kart (master) ad/kod referansini GENDEPO.LOGREFERANS'a UPSERT eder (hizli arama).
// Silinen kayit da kalir (ASilindi=True -> SILINDI=1). AD/KOD dataset alanlarindan
// (FIRMA/STOKADI/ADI/KOD...) cikarilir. Loglama gibi is akisini ASLA kirmaz.
procedure LogReferansGuncelle(ADataSet: TDataSet; ATabloID: Integer; AKayitID: Int64;
  ASilindi: Boolean);

// Kaydin varlik anahtarlarini alanlarindan cikarir: cari <- REHBERID/CARIID,
// stok <- STOKID/URUNID. Bulunamazsa 0. (LogYaz'a REHBERID/STOKID gecmek icin.)
procedure LogVarlikIDleri(ADataSet: TDataSet; out ARehberID, AStokID: Int64);

// Bir SILME grubunu (kart + tum detaylari) log JSON'larindan AYNI ID ile geri
// INSERT eder (silinen kaydin dirilmesi / "Geri Al"). AUstTabloID/AUstKayitID = kart
// (master) anahtari, AGun = silme islemi tarihi (gun bazli). Kart once, sonra detaylar
// eklenir (FK). Kart ID'si su an baska bir kayitta kullaniliyorsa hicbir sey eklenmez.
// Sonuc: '' = tam basari; aksi halde hata (kart) veya uyari (atlanan detay) mesaji.
function LogGeriAl(AUstTabloID: Integer; AUstKayitID: Int64; AGun: TDateTime): string;

implementation

uses
  System.SysUtils, System.SyncObjs, System.DateUtils, FireDAC.Comp.Client, Winapi.Windows,
  Utablo, PrjConst, uUtility_my;

var
  GLogCnn: TFDConnection = nil;   // otonom log baglantisi (GENDEPO'ya baglanir, cache)
  GLock: TCriticalSection = nil;  // log yazimlarini seri yapar
  GIP: string = #1;               // #1 = henuz hesaplanmadi
  GIstasyon: string = #1;
  GYillar: TStringList = nil;     // bu oturumda garantilenen LOG<yyyy> tablolari

{ ---- yardimcilar ---- }

function YerelIP: string;
begin
  if GIP = #1 then
    try
      GIP := GetIPAddress;
    except
      GIP := '';
    end;
  Result := GIP;
end;

function Istasyon: string;
begin
  if GIstasyon = #1 then
    try
      GIstasyon := GetEnvironmentVariable('COMPUTERNAME');
    except
      GIstasyon := '';
    end;
  Result := GIstasyon;
end;

function DepoDBAdi: string;
begin
  try
    Result := Trim(Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_DepoDBAdi, 'GENDEPO'));
  except
    Result := '';
  end;
  if Result = '' then Result := 'GENDEPO';
end;

function LogBaglantisi: TFDConnection;
begin
  if GLogCnn = nil then
  begin
    // Otonom baglanti dogrudan DEPO DB'ye (GENDEPO) baglanir; yillik tablolar
    // LOG<yyyy> ve birlesim view'i ISLEMLOG orada. Params ana baglantidan
    // klonlanip Database override edilir.
    GLogCnn := TFDConnection.Create(nil);
    GLogCnn.LoginPrompt := False;
    GLogCnn.Params.Assign(Tablo.FDCnn.Params);
    GLogCnn.Params.Database := DepoDBAdi;
    GLogCnn.Params.Values['MARS_Connection'] := 'Yes';
    GLogCnn.Connected := True;
  end
  else if not GLogCnn.Connected then
    GLogCnn.Connected := True;
  Result := GLogCnn;
end;

// GENDEPO'da tum LOG<yyyy> tablolarini birlestiren ISLEMLOG view'ini (yeniden) kurar.
procedure IslemLogViewKur(ACnn: TFDConnection);
var
  LQ: TFDQuery;
  LUnion, LT: string;
  LTablolar: TStringList;
  i: Integer;
begin
  LQ := TFDQuery.Create(nil);
  LTablolar := TStringList.Create;
  try
    LQ.Connection := ACnn;
    LQ.SQL.Text := 'SELECT name FROM sys.tables ' +
      'WHERE name LIKE ''LOG[0-9][0-9][0-9][0-9]'' ORDER BY name';
    LQ.Open;
    while not LQ.Eof do begin LTablolar.Add(LQ.Fields[0].AsString); LQ.Next; end;
    LQ.Close;
    if LTablolar.Count = 0 then Exit;
    LUnion := '';
    for i := 0 to LTablolar.Count - 1 do
    begin
      LT := LTablolar[i];
      // Eski LOG tablolarina REHBERID/STOKID kolonu + indeks (yoksa) ekle.
      LQ.SQL.Text := 'IF COL_LENGTH(''dbo.' + LT + ''',''REHBERID'') IS NULL' +
        ' ALTER TABLE dbo.' + LT + ' ADD REHBERID bigint NULL;';
      LQ.ExecSQL;
      LQ.SQL.Text := 'IF COL_LENGTH(''dbo.' + LT + ''',''STOKID'') IS NULL' +
        ' ALTER TABLE dbo.' + LT + ' ADD STOKID bigint NULL;';
      LQ.ExecSQL;
      LQ.SQL.Text := 'IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=''IX_' + LT +
        '_REHBER'' AND object_id=OBJECT_ID(''dbo.' + LT + ''')) CREATE INDEX IX_' + LT +
        '_REHBER ON dbo.' + LT + '(REHBERID);';
      LQ.ExecSQL;
      LQ.SQL.Text := 'IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=''IX_' + LT +
        '_STOK'' AND object_id=OBJECT_ID(''dbo.' + LT + ''')) CREATE INDEX IX_' + LT +
        '_STOK ON dbo.' + LT + '(STOKID);';
      LQ.ExecSQL;
      if LUnion <> '' then LUnion := LUnion + ' UNION ALL ';
      LUnion := LUnion +
        'SELECT ID,TARIH,IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,' +
        'USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI ' +
        'FROM dbo.' + LT;
    end;
    LQ.SQL.Text := 'CREATE OR ALTER VIEW dbo.ISLEMLOG AS ' + LUnion;
    LQ.ExecSQL;
  finally
    LTablolar.Free;
    LQ.Free;
  end;
end;

// LOG<yyyy> tablosunu (yoksa) olusturur + ISLEMLOG view'ini gunceller.
// Oturumda yil basina bir kez calisir (GYillar cache). Tablo adini doner.
function  LogYilTablosu(ACnn: TFDConnection; AYil: Integer): string;
var
  LQ: TFDQuery;
  LT: string;
begin
  LT := 'LOG' + IntToStr(AYil);
  Result := LT;
  if GYillar.IndexOf(LT) >= 0 then Exit;
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := ACnn;
    LQ.SQL.Text :=
      'IF OBJECT_ID(''dbo.' + LT + ''',''U'') IS NULL BEGIN ' +
      'CREATE TABLE dbo.' + LT + '(' +
      ' ID bigint IDENTITY(1,1) NOT NULL,' +
      ' TARIH datetime2(3) NOT NULL CONSTRAINT DF_' + LT + '_TARIH DEFAULT(SYSDATETIME()),' +
      ' IP varchar(45) NULL, ISTASYON varchar(64) NULL, KULLANICIID int NULL,' +
      ' SUBEID smallint NULL, ISLEMTIPI tinyint NOT NULL,' +
      ' USTTABLOID int NULL, USTKAYITID bigint NULL,' +
      ' TABLOID int NULL, KAYITID bigint NULL,' +
      ' REHBERID bigint NULL, STOKID bigint NULL,' +   // varlik baglantisi (cari/stok)
      ' BILGI varbinary(max) NULL,' +
      ' CONSTRAINT PK_' + LT + ' PRIMARY KEY CLUSTERED (ID));' +
      ' CREATE INDEX IX_' + LT + '_UST ON dbo.' + LT + '(USTTABLOID,USTKAYITID);' +
      ' CREATE INDEX IX_' + LT + '_KAYIT ON dbo.' + LT + '(TABLOID,KAYITID);' +
      ' CREATE INDEX IX_' + LT + '_REHBER ON dbo.' + LT + '(REHBERID);' +
      ' CREATE INDEX IX_' + LT + '_STOK ON dbo.' + LT + '(STOKID);' +
      ' CREATE INDEX IX_' + LT + '_TARIH ON dbo.' + LT + '(TARIH); END';
    LQ.ExecSQL;
  finally
    LQ.Free;
  end;
  IslemLogViewKur(ACnn);   // yeni yil tablosu view'e dahil edilsin
  GYillar.Add(LT);         // view kurulumu BASARILIYSA cache'le (yoksa tekrar denenir)
end;

{ TLogKurucu }

constructor TLogKurucu.Create;
begin
  inherited Create;
  FObj := TJSONObject.Create;
end;

destructor TLogKurucu.Destroy;
begin
  FObj.Free;
  inherited;
end;

class function TLogKurucu.Yeni: TLogKurucu;
begin
  Result := TLogKurucu.Create;
end;

function TLogKurucu.Alan(const AAd, AEski, AYeni: string): TLogKurucu;
begin
  Result := Self;
  if AEski = AYeni then Exit;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', AEski)
    .AddPair('y', AYeni));
end;

function TLogKurucu.Alan(const AAd: string; AEski, AYeni: Int64): TLogKurucu;
begin
  Result := Self;
  if AEski = AYeni then Exit;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', TJSONNumber.Create(AEski))
    .AddPair('y', TJSONNumber.Create(AYeni)));
end;

function TLogKurucu.Alan(const AAd: string; AEski, AYeni: Currency): TLogKurucu;
var
  LE, LY: Double;  // Currency -> Double deger donusumu (TJSONNumber ambiguity'sini onler)
begin
  Result := Self;
  if AEski = AYeni then Exit;
  LE := AEski; LY := AYeni;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', TJSONNumber.Create(LE))
    .AddPair('y', TJSONNumber.Create(LY)));
end;

function TLogKurucu.Alan(const AAd: string; AEski, AYeni: Double): TLogKurucu;
begin
  Result := Self;
  if AEski = AYeni then Exit;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', TJSONNumber.Create(AEski))
    .AddPair('y', TJSONNumber.Create(AYeni)));
end;

function TLogKurucu.Deger(const AAd, ADeger: string): TLogKurucu;
begin
  Result := Self;
  FObj.AddPair(AAd, ADeger);
end;

function TLogKurucu.Deger(const AAd: string; ADeger: Int64): TLogKurucu;
begin
  Result := Self;
  FObj.AddPair(AAd, TJSONNumber.Create(ADeger));
end;

function TLogKurucu.Deger(const AAd: string; ADeger: Currency): TLogKurucu;
var
  LD: Double;  // Currency -> Double deger donusumu
begin
  Result := Self;
  LD := ADeger;
  FObj.AddPair(AAd, TJSONNumber.Create(LD));
end;

function TLogKurucu.BosMu: Boolean;
begin
  Result := FObj.Count = 0;
end;

function TLogKurucu.JSON: string;
begin
  Result := FObj.ToString;
end;

{ LogYaz }

procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  const ABilgiJSON: string; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0);
var
  LQ: TFDQuery;
  LCnn: TFDConnection;
  LBilgiVar: Boolean;
  LTablo: string;
  LUstT: Integer;
  LUstK: Int64;
begin
  // Loglama hicbir kosulda uygulamayi kirmaz/yavaslamaz.
  try
    // Ust (master) verilmediyse kendisidir (baslik kendi kaydi). Detay satirda
    // cagiran USTTABLOID/USTKAYITID = master (ör. FATBASLIK) gecirir; boylece
    // master+detay loglari birlikte sorgulanabilir.
    LUstT := AUstTabloID; if LUstT = 0 then LUstT := ATabloID;
    LUstK := AUstKayitID; if LUstK = 0 then LUstK := AKayitID;
    // Varlik anahtari verilmediyse KART tipinden turet: cari/IK (71/73/74) ve stok(88)
    // kartinin KENDISI -> KAYITID; altindaki DETAY -> USTKAYITID. Boylece bir cari/IK
    // personelinin (REHBER) veya stokun TUM loglari REHBERID/STOKID ile bulunur.
    if AREHBERID <= 0 then
    begin
      if (ATabloID = TabNo_REHBER) or (ATabloID = TabNo_IK) or (ATabloID = TabNo_IK_POTANSIYEL) then
        AREHBERID := AKayitID
      else if (LUstT = TabNo_REHBER) or (LUstT = TabNo_IK) or (LUstT = TabNo_IK_POTANSIYEL) then
        AREHBERID := LUstK;
    end;
    if ASTOKID <= 0 then
    begin
      if ATabloID = TabNo_STOKLAR then ASTOKID := AKayitID
      else if LUstT = TabNo_STOKLAR then ASTOKID := LUstK;
    end;
    GLock.Enter;
    try
      LCnn := LogBaglantisi;
      LTablo := LogYilTablosu(LCnn, YearOf(Now));   // yila gore LOG<yyyy>
      LBilgiVar := Trim(ABilgiJSON) <> '';
      LQ := TFDQuery.Create(nil);
      try
        LQ.Connection := LCnn;
        // MODUL log tablolarinda TUTULMAZ; TABLOID -> TABLOLAR.MODUL ile alinir.
        // AModul param'i geriye uyumluluk icin durur (yazilmaz).
        if LBilgiVar then
          LQ.SQL.Text :=
            'INSERT INTO dbo.' + LTablo + '(IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI) ' +
            'VALUES(:IP,:IST,:KUL,:SUB,:IT,:UTID,:UKYT,:TID,:KYT, NULLIF(:REH,0), NULLIF(:STK,0), COMPRESS(CAST(:BILGI AS nvarchar(max))))'
        else
          LQ.SQL.Text :=
            'INSERT INTO dbo.' + LTablo + '(IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID) ' +
            'VALUES(:IP,:IST,:KUL,:SUB,:IT,:UTID,:UKYT,:TID,:KYT, NULLIF(:REH,0), NULLIF(:STK,0))';
        LQ.ParamByName('IP').AsString  := Copy(YerelIP, 1, 45);
        LQ.ParamByName('IST').AsString := Copy(Istasyon, 1, 64);
        LQ.ParamByName('KUL').AsInteger := StrToIntDef(Trim(Kullanan), 0);
        LQ.ParamByName('SUB').AsInteger := StrToIntDef(Trim(SubeIDYazi), 0);
        LQ.ParamByName('IT').AsInteger := Ord(AIslemTipi);
        LQ.ParamByName('UTID').AsInteger := LUstT;
        LQ.ParamByName('UKYT').AsLargeInt := LUstK;
        LQ.ParamByName('TID').AsInteger := ATabloID;
        LQ.ParamByName('KYT').AsLargeInt := AKayitID;
        LQ.ParamByName('REH').AsLargeInt := AREHBERID;
        LQ.ParamByName('STK').AsLargeInt := ASTOKID;
        if LBilgiVar then
        begin
          LQ.ParamByName('BILGI').DataType := ftWideMemo;
          LQ.ParamByName('BILGI').AsWideMemo := ABilgiJSON;
        end;
        LQ.ExecSQL;
      finally
        LQ.Free;
      end;
    finally
      GLock.Leave;
    end;
  except
    // yut: loglama hatasi is akisini etkilemesin
  end;
end;

// Kaydin cari/stok anahtarlarini alanlarindan cikarir (REHBERID/CARIID, STOKID/URUNID).
procedure LogVarlikIDleri(ADataSet: TDataSet; out ARehberID, AStokID: Int64);
  function AlanID(const AAlanlar: array of string): Int64;
  var i: Integer; F: TField;
  begin
    Result := 0;
    if ADataSet = nil then Exit;
    for i := 0 to High(AAlanlar) do
    begin
      F := ADataSet.FindField(AAlanlar[i]);
      if (F <> nil) and (not F.IsNull) and (F.AsLargeInt > 0) then
        Exit(F.AsLargeInt);
    end;
  end;
begin
  ARehberID := AlanID(['REHBERID', 'CARIID']);
  AStokID   := AlanID(['STOKID', 'URUNID']);
end;

// AD/KOD'u oncelikli alan listelerinden cikarir; GENDEPO.LOGREFERANS'a upsert eder.
procedure LogReferansGuncelle(ADataSet: TDataSet; ATabloID: Integer; AKayitID: Int64;
  ASilindi: Boolean);

  function IlkDolu(const AAlanlar: array of string): string;
  var i: Integer; F: TField;
  begin
    Result := '';
    if ADataSet = nil then Exit;
    for i := 0 to High(AAlanlar) do
    begin
      F := ADataSet.FindField(AAlanlar[i]);
      if (F <> nil) and (Trim(F.AsString) <> '') then
        Exit(Trim(F.AsString));
    end;
  end;

var
  LQ: TFDQuery;
  LCnn: TFDConnection;
  LAd, LKod: string;
begin
  try
    // ADI/KODU -> POS, Kredi Karti; HESAPADI/HESAPKODU -> Banka; KREDIKODU -> Krediler;
    // BORCLU/SERINO -> Cek/Senet. (IlkDolu var olmayan alani atlar -> fazla aday zararsiz.)
    LAd  := Copy(IlkDolu(['FIRMA','STOKADI','ADI','ADSOYAD','KONUSU','PROJEADI',
                          'ACIKLAMA','TANIM','UNVAN','ISIM','HESAPADI','BANKAADI',
                          'BORCLU']), 1, 200);
    LKod := Copy(IlkDolu(['KOD','STOKKOD','KODU','CARIKOD','HESAPKODU','HESAPNO',
                          'KREDIKODU','SERINO']), 1, 60);
    if (LAd = '') and (LKod = '') then Exit;   // referanslanacak ad/kod yok
    GLock.Enter;
    try
      LCnn := LogBaglantisi;
      LQ := TFDQuery.Create(nil);
      try
        LQ.Connection := LCnn;
        // Son satirin AD/KOD/SILINDI'sini al. DEGISMISSE YENI SATIR ekle -> eski isim
        // korunur (isim gecmisi); eski isimle de arama yapilabilir.
        LQ.SQL.Text := 'SELECT TOP 1 AD, KOD, SILINDI FROM dbo.LOGREFERANS' +
                       ' WHERE TABLOID=:TID AND KAYITID=:KYT ORDER BY ID DESC';
        LQ.ParamByName('TID').AsInteger  := ATabloID;
        LQ.ParamByName('KYT').AsLargeInt := AKayitID;
        LQ.Open;
        var LAyni: Boolean := (not LQ.IsEmpty)
                          and (LQ.FieldByName('AD').AsString = LAd)
                          and (LQ.FieldByName('KOD').AsString = LKod)
                          and (LQ.FieldByName('SILINDI').AsBoolean = ASilindi);
        LQ.Close;
        if LAyni then Exit;   // ad/kod/silindi degismemis -> yeni satir gerekmez
        LQ.SQL.Text :=
          'INSERT INTO dbo.LOGREFERANS(TABLOID,KAYITID,AD,KOD,SILINDI,SONISLEM)' +
          ' VALUES(:TID,:KYT,:AD,:KOD,:SIL,getdate())';
        LQ.ParamByName('TID').AsInteger  := ATabloID;
        LQ.ParamByName('KYT').AsLargeInt := AKayitID;
        LQ.ParamByName('AD').AsString    := LAd;
        LQ.ParamByName('KOD').AsString   := LKod;
        LQ.ParamByName('SIL').AsInteger  := Ord(ASilindi);
        LQ.ExecSQL;
      finally
        LQ.Free;
      end;
    finally
      GLock.Leave;
    end;
  except
    // yut
  end;
end;

procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  AKurucu: TLogKurucu; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0);
var
  LJSON: string;
begin
  try
    if AKurucu = nil then
      LJSON := ''
    else if AKurucu.BosMu then
      LJSON := ''
    else
      LJSON := AKurucu.JSON;
    LogYaz(AIslemTipi, ATabloID, AKayitID, LJSON, AModul, AUstTabloID, AUstKayitID,
           AREHBERID, ASTOKID);
  finally
    AKurucu.Free;  // sahipligi aldik
  end;
end;

procedure LogSnapshotAl(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>);
var
  LBM: TBookmark;
  LSL: TStringList;
  i: Integer;
begin
  if ASnap = nil then Exit;
  ASnap.Clear;
  if (ADataSet = nil) or (not ADataSet.Active) then Exit;
  ADataSet.DisableControls;
  try
    LBM := ADataSet.Bookmark;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        LSL := TStringList.Create;
        for i := 0 to ADataSet.FieldCount - 1 do
          LSL.Add(ADataSet.Fields[i].AsString);
        ASnap.AddOrSetValue(ADataSet.FieldByName('ID').AsInteger, LSL);
        ADataSet.Next;
      end;
    finally
      if ADataSet.BookmarkValid(LBM) then ADataSet.Bookmark := LBM;
    end;
  finally
    ADataSet.EnableControls;
  end;
end;

procedure LogDiffKaydet(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64);
var
  i, LID: Integer;
  LSnap: TStringList;
  LK: TLogKurucu;
  LGorulen: TList<Integer>;
  LPair: TPair<Integer, TStringList>;
  LBM: TBookmark;
  LReh, LStk: Int64;

  // Mevcut satirin tum dolu fkData alanlarini deger olarak iceren kurucu (ekle/sil).
  function DoluAlanlar(ASL: TStringList): TLogKurucu;
  var j: Integer;
  begin
    Result := TLogKurucu.Yeni;
    for j := 0 to ADataSet.FieldCount - 1 do
      if (ADataSet.Fields[j].FieldKind = fkData) and
         (ADataSet.Fields[j].DataType <> ftBlob) and
         (ADataSet.Fields[j].DataType <> ftMemo) then
      begin
        if ASL <> nil then      // snapshot degeri (silinen satir)
        begin
          if (j < ASL.Count) and (Trim(ASL[j]) <> '') then
            Result.Deger(ADataSet.Fields[j].FieldName, ASL[j]);
        end
        else if Trim(ADataSet.Fields[j].AsString) <> '' then   // mevcut satir (ekleme)
          Result.Deger(ADataSet.Fields[j].FieldName, ADataSet.Fields[j].AsString);
      end;
  end;

begin
  if (ASnap = nil) or (ADataSet = nil) or (not ADataSet.Active) then Exit;
  try
    LGorulen := TList<Integer>.Create;
    try
      ADataSet.DisableControls;
      try
        LBM := ADataSet.Bookmark;
        try
          ADataSet.First;
          while not ADataSet.Eof do
          begin
            LID := ADataSet.FieldByName('ID').AsInteger;
            LGorulen.Add(LID);
            LogVarlikIDleri(ADataSet, LReh, LStk);   // satirin cari/stok anahtarlari
            if ASnap.TryGetValue(LID, LSnap) then
            begin
              // Mevcut satir snapshot'ta var -> degisen alanlar
              LK := TLogKurucu.Yeni;
              for i := 0 to ADataSet.FieldCount - 1 do
                if (ADataSet.Fields[i].FieldKind = fkData) and
                   (ADataSet.Fields[i].DataType <> ftBlob) and
                   (ADataSet.Fields[i].DataType <> ftMemo) and
                   (i < LSnap.Count) and
                   (ADataSet.Fields[i].AsString <> LSnap[i]) then
                  LK.Alan(ADataSet.Fields[i].FieldName, LSnap[i],
                          ADataSet.Fields[i].AsString);
              if not LK.BosMu then
                LogYaz(liDegistir, ADetayTabNo, LID, LK, '', AUstTabNo, AUstID, LReh, LStk)
              else
                LK.Free;
            end
            else
              // snapshot'ta yok -> yeni satir -> EKLEME
              LogYaz(liEkle, ADetayTabNo, LID, DoluAlanlar(nil), '', AUstTabNo, AUstID, LReh, LStk);
            ADataSet.Next;
          end;
        finally
          if ADataSet.BookmarkValid(LBM) then ADataSet.Bookmark := LBM;
        end;
      finally
        ADataSet.EnableControls;
      end;

      // Snapshot'ta olup mevcutta olmayan -> SILME
      for LPair in ASnap do
        if LGorulen.IndexOf(LPair.Key) < 0 then
          LogYaz(liSil, ADetayTabNo, LPair.Key, DoluAlanlar(LPair.Value),
                 '', AUstTabNo, AUstID);
    finally
      LGorulen.Free;
    end;
  except
    // loglama kaydetmeyi bozmaz
  end;
end;

procedure LogKayitEkle(ADataSet: TDataSet; ATabNo: Integer; AID: Int64;
  AUstTabNo: Integer = 0; AUstID: Int64 = 0);
var
  LK: TLogKurucu;
  i: Integer;
  LReh, LStk: Int64;
begin
  if (ADataSet = nil) or (not ADataSet.Active) then Exit;
  try
    LK := TLogKurucu.Yeni;
    for i := 0 to ADataSet.FieldCount - 1 do
      if (ADataSet.Fields[i].FieldKind = fkData) and
         (ADataSet.Fields[i].DataType <> ftBlob) and
         (ADataSet.Fields[i].DataType <> ftMemo) and
         (Trim(ADataSet.Fields[i].AsString) <> '') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'DEGISTIREN') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'DEGISTIRMETARIHI') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'EKLEYEN') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'EKLEMETARIHI') then
        LK.Deger(ADataSet.Fields[i].FieldName, ADataSet.Fields[i].AsString);
    LogVarlikIDleri(ADataSet, LReh, LStk);   // cari/stok anahtarlari
    LogYaz(liEkle, ATabNo, AID, LK, '', AUstTabNo, AUstID, LReh, LStk);
    // Master (kart) ise LOGREFERANS'a upsert (hizli ad/kod arama).
    if (AUstTabNo = 0) or ((AUstTabNo = ATabNo) and (AUstID = AID)) then
      LogReferansGuncelle(ADataSet, ATabNo, AID, False);
  except
  end;
end;

procedure LogDetaylariSil(const ADetayTablo, AUstKolon: string;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64; const AEkKosul: string = '');
var
  LQ: TFDQuery;
  LK: TLogKurucu;
  i: Integer;
  LReh, LStk: Int64;
begin
  if (LogGun <= 0) or (Trim(ADetayTablo) = '') then Exit;
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text := 'select * from ' + ADetayTablo + ' where ' + AUstKolon + ' = ' + IntToStr(AUstID);
      if Trim(AEkKosul) <> '' then
        LQ.SQL.Text := LQ.SQL.Text + ' and (' + AEkKosul + ')';
      LQ.Open;
      while not LQ.Eof do
      begin
        LK := TLogKurucu.Yeni;
        for i := 0 to LQ.FieldCount - 1 do
          if (LQ.Fields[i].FieldKind = fkData) and
             (LQ.Fields[i].DataType <> ftBlob) and (LQ.Fields[i].DataType <> ftMemo) and
             (Trim(LQ.Fields[i].AsString) <> '') then
            LK.Deger(LQ.Fields[i].FieldName, LQ.Fields[i].AsString);
        LogVarlikIDleri(LQ, LReh, LStk);
        LogYaz(liSil, ADetayTabNo, LQ.FieldByName('ID').AsLargeInt, LK, '',
               AUstTabNo, AUstID, LReh, LStk);   // LK sahipligi LogYaz'a gecer
        LQ.Next;
      end;
    finally
      LQ.Free;
    end;
  except
    // loglama silme islemini ASLA bozmaz
  end;
end;

{ ---- Geri Al (silinen kaydi dirilt) ---- }

type
  TGeriKayit = record
    TabloID: Integer;
    KayitID: Int64;
    JSON: string;
  end;

// ANA DB'de TABLOID -> fiziksel tablo adi (TABLOLAR). Bulunamazsa ''.
function GeriTabloAdiGetir(ATabloID: Integer): string;
var LQ: TFDQuery;
begin
  Result := '';
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text := 'SELECT TABLOADI FROM TABLOLAR WHERE TABLOID=:t';
    LQ.ParamByName('t').AsInteger := ATabloID;
    LQ.Open;
    if not LQ.IsEmpty then Result := Trim(LQ.Fields[0].AsString);
  finally
    LQ.Free;
  end;
end;

// ANA DB: <ATablo>'da ID=AID kaydi var mi? (cakisma / mukerrer kontrolu)
function GeriKayitVarMi(const ATablo: string; AID: Int64): Boolean;
var LQ: TFDQuery;
begin
  Result := False;
  if Trim(ATablo) = '' then Exit;
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text := 'SELECT 1 FROM ' + ATablo + ' WHERE ID=:id';
    LQ.ParamByName('id').AsLargeInt := AID;
    LQ.Open;
    Result := not LQ.IsEmpty;
  finally
    LQ.Free;
  end;
end;

// Tablonun IDENTITY kolonu var mi? (IDENTITY_INSERT sadece varsa acilir)
function GeriIdentityVarMi(const ATablo: string): Boolean;
var LQ: TFDQuery;
begin
  Result := False;
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text := 'SELECT OBJECTPROPERTY(OBJECT_ID(:t), ''TableHasIdentity'')';
    LQ.ParamByName('t').AsString := ATablo;
    LQ.Open;
    if (not LQ.IsEmpty) and (not LQ.Fields[0].IsNull) then
      Result := LQ.Fields[0].AsInteger = 1;
  finally
    LQ.Free;
  end;
end;

// JSON degerini duz string'e cevirir (silme JSON'unda degerler string tutulur ama
// sayi/bool da gelebilir). Nesne/dizi beklenmez (duz key-value).
function GeriJsonDeger(V: TJSONValue): string;
begin
  if V = nil then
    Result := ''
  else if V is TJSONString then
    Result := TJSONString(V).Value
  else if (V is TJSONNumber) or (V is TJSONBool) then
    Result := V.Value
  else
    Result := V.ToString;
end;

// Tek bir kaydi (JSON alanlari) ATabloAdi'na AYNI ID ile ekler. Format-guvenli
// (TField.AsString -> kultur-aware). Sonuc: '' = basari, aksi halde hata mesaji.
function GeriKayitEkle(const ATabloAdi, AJSON: string): string;
var
  LQ: TFDQuery;
  LParsed: TJSONValue;
  LObj: TJSONObject;
  LPair: TJSONPair;
  F: TField;
  LDeger: string;
  LIdentity, LIdentityAcik: Boolean;
begin
  Result := '';
  LIdentityAcik := False;
  LParsed := nil;
  LQ := TFDQuery.Create(nil);
  try
    try
      LParsed := TJSONObject.ParseJSONValue(AJSON);
      if not (LParsed is TJSONObject) then
        Exit('JSON cozumlenemedi.');
      LObj := TJSONObject(LParsed);

      // Bos sablon dataset (INSERT icin): SELECT * ... WHERE 1=0
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text := 'SELECT * FROM ' + ATabloAdi + ' WHERE 1=0';
      LQ.Open;
      // FireDAC ID'yi acikca yazsin: auto-inc alan atlamasini kapat + ID guncellemeye dahil.
      LQ.UpdateOptions.AutoIncFields := '';
      F := LQ.FindField('ID');
      if F <> nil then
        F.ProviderFlags := F.ProviderFlags + [pfInUpdate];

      LIdentity := GeriIdentityVarMi(ATabloAdi);
      if LIdentity then
      begin
        Tablo.FDCnn.ExecSQL('SET IDENTITY_INSERT ' + ATabloAdi + ' ON');
        LIdentityAcik := True;
      end;

      LQ.Append;
      for LPair in LObj do
      begin
        F := LQ.FindField(LPair.JsonString.Value);   // computed/olmayan kolon -> nil, atla
        if F = nil then Continue;
        LDeger := GeriJsonDeger(LPair.JsonValue);
        if Trim(LDeger) = '' then
          F.Clear
        else
          F.AsString := LDeger;   // kultur-aware: Turkce ondalik/tarih dogru yorumlanir
      end;
      LQ.Post;   // FireDAC parametreli INSERT -> format guvenli
    except
      on E: Exception do
      begin
        try if LQ.State in [dsInsert, dsEdit] then LQ.Cancel; except end;
        Result := E.Message;
      end;
    end;
  finally
    // IDENTITY_INSERT'i ayni connection'da MUTLAKA geri kapat (hata olsa bile)
    if LIdentityAcik then
      try Tablo.FDCnn.ExecSQL('SET IDENTITY_INSERT ' + ATabloAdi + ' OFF'); except end;
    LQ.Free;
    if LParsed <> nil then LParsed.Free;
  end;
end;

function LogGeriAl(AUstTabloID: Integer; AUstKayitID: Int64; AGun: TDateTime): string;
var
  LCnn: TFDConnection;
  LLogQ: TFDQuery;
  LList: TList<TGeriKayit>;
  LRec: TGeriKayit;
  i: Integer;
  LTabloAdi, LKartTabloAdi, LUyari, LHata: string;
  LKart: Boolean;
begin
  Result := '';
  LList := TList<TGeriKayit>.Create;
  try
    // a. GENDEPO (otonom log baglantisi) - silme grubunu oku, KART ONCE (FK icin).
    //    Tum satirlar once listeye alinir (ayni conn'da baska sorgu acmamak icin).
    try
      GLock.Enter;
      try
        LCnn := LogBaglantisi;
        LLogQ := TFDQuery.Create(nil);
        try
          LLogQ.Connection := LCnn;
          LLogQ.SQL.Text :=
            'SELECT TABLOID, KAYITID, CAST(DECOMPRESS(BILGI) AS nvarchar(max)) J ' +
            'FROM ISLEMLOG WHERE USTKAYITID=:u AND USTTABLOID=:ut AND ISLEMTIPI=0 ' +
            'AND CAST(TARIH AS date)=:g ' +
            'ORDER BY CASE WHEN TABLOID=:ut2 THEN 0 ELSE 1 END, ID';
          LLogQ.ParamByName('u').AsLargeInt := AUstKayitID;
          LLogQ.ParamByName('ut').AsInteger := AUstTabloID;
          LLogQ.ParamByName('ut2').AsInteger := AUstTabloID;
          LLogQ.ParamByName('g').AsString := FormatDateTime('yyyy-mm-dd', AGun);
          LLogQ.Open;
          while not LLogQ.Eof do
          begin
            LRec.TabloID := LLogQ.FieldByName('TABLOID').AsInteger;
            LRec.KayitID := LLogQ.FieldByName('KAYITID').AsLargeInt;
            LRec.JSON    := LLogQ.FieldByName('J').AsString;
            LList.Add(LRec);
            LLogQ.Next;
          end;
        finally
          LLogQ.Free;
        end;
      finally
        GLock.Leave;
      end;
    except
      on E: Exception do
        Exit('Log kayitlari okunamadi: ' + E.Message);
    end;

    if LList.Count = 0 then
      Exit('Bu silme islemine ait geri alinacak kayit bulunamadi.');

    // b. KART cakisma kontrolu (ANA DB): kart ID'si su an kullaniliyorsa hicbir sey ekleme.
    LKartTabloAdi := GeriTabloAdiGetir(AUstTabloID);
    if LKartTabloAdi = '' then
      Exit('Kart tablosu (TABLOID=' + IntToStr(AUstTabloID) + ') bulunamadi; geri alinamaz.');
    if GeriKayitVarMi(LKartTabloAdi, AUstKayitID) then
      Exit('Bu ID (' + IntToStr(AUstKayitID) + ') su an baska bir kayitta kullaniliyor; geri alinamaz.');

    // c. Sirayla INSERT (kart once, sonra detaylar).
    LUyari := '';
    for i := 0 to LList.Count - 1 do
    begin
      LRec := LList[i];
      LKart := (LRec.TabloID = AUstTabloID) and (LRec.KayitID = AUstKayitID);

      LTabloAdi := GeriTabloAdiGetir(LRec.TabloID);
      if LTabloAdi = '' then
      begin
        if LKart then Exit('Kart tablosu bulunamadi; geri alinamaz.');
        LUyari := LUyari + 'TABLOID=' + IntToStr(LRec.TabloID) + ' tablo adi bulunamadi, atlandi.'#13#10;
        Continue;
      end;

      // Zaten varsa atla (detaylarda parcali cakisma; kart b'de kontrol edildi).
      if GeriKayitVarMi(LTabloAdi, LRec.KayitID) then
      begin
        if not LKart then
          LUyari := LUyari + LTabloAdi + ' ID=' + IntToStr(LRec.KayitID) + ' zaten mevcut, atlandi.'#13#10;
        Continue;
      end;

      LHata := GeriKayitEkle(LTabloAdi, LRec.JSON);
      if LHata <> '' then
      begin
        if LKart then
          Exit('Kart geri eklenemedi: ' + LHata)   // kart basarisiz -> tum islem iptal
        else
          LUyari := LUyari + LTabloAdi + ' ID=' + IntToStr(LRec.KayitID) + ': ' + LHata + #13#10;
      end;
    end;

    Result := LUyari;   // '' = tam basari; aksi halde atlanan detay uyarilari
  finally
    LList.Free;
  end;
end;

initialization
  GLock := TCriticalSection.Create;
  GYillar := TStringList.Create;

finalization
  if GLogCnn <> nil then
  begin
    try GLogCnn.Free; except end;
    GLogCnn := nil;
  end;
  GYillar.Free;
  GLock.Free;

end.

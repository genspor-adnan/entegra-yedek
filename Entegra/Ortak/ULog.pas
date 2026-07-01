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
  System.JSON;

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
procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  const ABilgiJSON: string; const AModul: string = ''); overload;

// TLogKurucu alan pratik cagri. AKurucu'nun SAHIPLIGINI ALIR ve serbest birakir
// (fluent kullanim icin). Kurucu bos ise BILGI NULL yazilir.
procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  AKurucu: TLogKurucu; const AModul: string = ''); overload;

implementation

uses
  System.SysUtils, System.SyncObjs, System.Classes, System.DateUtils, Data.DB,
  FireDAC.Comp.Client, Winapi.Windows,
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
  LUnion: string;
begin
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := ACnn;
    LQ.SQL.Text := 'SELECT name FROM sys.tables ' +
      'WHERE name LIKE ''LOG[0-9][0-9][0-9][0-9]'' ORDER BY name';
    LQ.Open;
    LUnion := '';
    while not LQ.Eof do
    begin
      if LUnion <> '' then LUnion := LUnion + ' UNION ALL ';
      LUnion := LUnion +
        'SELECT ID,TARIH,IP,ISTASYON,KULLANICIID,SUBEID,MODUL,ISLEMTIPI,TABLOID,KAYITID,BILGI ' +
        'FROM dbo.' + LQ.Fields[0].AsString;
      LQ.Next;
    end;
    LQ.Close;
    if LUnion = '' then Exit;
    LQ.SQL.Text := 'CREATE OR ALTER VIEW dbo.ISLEMLOG AS ' + LUnion;
    LQ.ExecSQL;
  finally
    LQ.Free;
  end;
end;

// LOG<yyyy> tablosunu (yoksa) olusturur + ISLEMLOG view'ini gunceller.
// Oturumda yil basina bir kez calisir (GYillar cache). Tablo adini doner.
function LogYilTablosu(ACnn: TFDConnection; AYil: Integer): string;
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
      ' SUBEID smallint NULL, MODUL varchar(64) NULL, ISLEMTIPI tinyint NOT NULL,' +
      ' TABLOID int NULL, KAYITID bigint NULL, BILGI varbinary(max) NULL,' +
      ' CONSTRAINT PK_' + LT + ' PRIMARY KEY CLUSTERED (ID));' +
      ' CREATE INDEX IX_' + LT + '_KAYIT ON dbo.' + LT + '(TABLOID,KAYITID);' +
      ' CREATE INDEX IX_' + LT + '_TARIH ON dbo.' + LT + '(TARIH); END';
    LQ.ExecSQL;
  finally
    LQ.Free;
  end;
  GYillar.Add(LT);
  IslemLogViewKur(ACnn);   // yeni yil tablosu view'e dahil edilsin
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
  const ABilgiJSON: string; const AModul: string = '');
var
  LQ: TFDQuery;
  LCnn: TFDConnection;
  LBilgiVar: Boolean;
  LTablo: string;
begin
  // Loglama hicbir kosulda uygulamayi kirmaz/yavaslamaz.
  try
    GLock.Enter;
    try
      LCnn := LogBaglantisi;
      LTablo := LogYilTablosu(LCnn, YearOf(Now));   // yila gore LOG<yyyy>
      LBilgiVar := Trim(ABilgiJSON) <> '';
      LQ := TFDQuery.Create(nil);
      try
        LQ.Connection := LCnn;
        if LBilgiVar then
          LQ.SQL.Text :=
            'INSERT INTO dbo.' + LTablo + '(IP,ISTASYON,KULLANICIID,SUBEID,MODUL,ISLEMTIPI,TABLOID,KAYITID,BILGI) ' +
            'VALUES(:IP,:IST,:KUL,:SUB,:MDL,:IT,:TID,:KYT, COMPRESS(CAST(:BILGI AS nvarchar(max))))'
        else
          LQ.SQL.Text :=
            'INSERT INTO dbo.' + LTablo + '(IP,ISTASYON,KULLANICIID,SUBEID,MODUL,ISLEMTIPI,TABLOID,KAYITID) ' +
            'VALUES(:IP,:IST,:KUL,:SUB,:MDL,:IT,:TID,:KYT)';
        LQ.ParamByName('IP').AsString  := Copy(YerelIP, 1, 45);
        LQ.ParamByName('IST').AsString := Copy(Istasyon, 1, 64);
        LQ.ParamByName('KUL').AsInteger := StrToIntDef(Trim(Kullanan), 0);
        LQ.ParamByName('SUB').AsInteger := StrToIntDef(Trim(SubeIDYazi), 0);
        LQ.ParamByName('MDL').AsString := Copy(AModul, 1, 64);
        LQ.ParamByName('IT').AsInteger := Ord(AIslemTipi);
        LQ.ParamByName('TID').AsInteger := ATabloID;
        LQ.ParamByName('KYT').AsLargeInt := AKayitID;
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

procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  AKurucu: TLogKurucu; const AModul: string = '');
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
    LogYaz(AIslemTipi, ATabloID, AKayitID, LJSON, AModul);
  finally
    AKurucu.Free;  // sahipligi aldik
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

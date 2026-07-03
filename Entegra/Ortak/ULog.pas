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
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0); overload;

// TLogKurucu alan pratik cagri. AKurucu'nun SAHIPLIGINI ALIR ve serbest birakir
// (fluent kullanim icin). Kurucu bos ise BILGI NULL yazilir.
procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  AKurucu: TLogKurucu; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0); overload;

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
        'SELECT ID,TARIH,IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,' +
        'USTTABLOID,USTKAYITID,TABLOID,KAYITID,BILGI ' +
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
      ' TABLOID int NULL, KAYITID bigint NULL, BILGI varbinary(max) NULL,' +
      ' CONSTRAINT PK_' + LT + ' PRIMARY KEY CLUSTERED (ID));' +
      ' CREATE INDEX IX_' + LT + '_UST ON dbo.' + LT + '(USTTABLOID,USTKAYITID);' +
      ' CREATE INDEX IX_' + LT + '_KAYIT ON dbo.' + LT + '(TABLOID,KAYITID);' +
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
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0);
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
            'INSERT INTO dbo.' + LTablo + '(IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID,BILGI) ' +
            'VALUES(:IP,:IST,:KUL,:SUB,:IT,:UTID,:UKYT,:TID,:KYT, COMPRESS(CAST(:BILGI AS nvarchar(max))))'
        else
          LQ.SQL.Text :=
            'INSERT INTO dbo.' + LTablo + '(IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID) ' +
            'VALUES(:IP,:IST,:KUL,:SUB,:IT,:UTID,:UKYT,:TID,:KYT)';
        LQ.ParamByName('IP').AsString  := Copy(YerelIP, 1, 45);
        LQ.ParamByName('IST').AsString := Copy(Istasyon, 1, 64);
        LQ.ParamByName('KUL').AsInteger := StrToIntDef(Trim(Kullanan), 0);
        LQ.ParamByName('SUB').AsInteger := StrToIntDef(Trim(SubeIDYazi), 0);
        LQ.ParamByName('IT').AsInteger := Ord(AIslemTipi);
        LQ.ParamByName('UTID').AsInteger := LUstT;
        LQ.ParamByName('UKYT').AsLargeInt := LUstK;
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
  AKurucu: TLogKurucu; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0);
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
    LogYaz(AIslemTipi, ATabloID, AKayitID, LJSON, AModul, AUstTabloID, AUstKayitID);
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
                LogYaz(liDegistir, ADetayTabNo, LID, LK, '', AUstTabNo, AUstID)
              else
                LK.Free;
            end
            else
              // snapshot'ta yok -> yeni satir -> EKLEME
              LogYaz(liEkle, ADetayTabNo, LID, DoluAlanlar(nil), '', AUstTabNo, AUstID);
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
begin
  if (ADataSet = nil) or (not ADataSet.Active) then Exit;
  try
    LK := TLogKurucu.Yeni;
    for i := 0 to ADataSet.FieldCount - 1 do
      if (ADataSet.Fields[i].FieldKind = fkData) and
         (ADataSet.Fields[i].DataType <> ftBlob) and
         (ADataSet.Fields[i].DataType <> ftMemo) and
         (Trim(ADataSet.Fields[i].AsString) <> '') then
        LK.Deger(ADataSet.Fields[i].FieldName, ADataSet.Fields[i].AsString);
    LogYaz(liEkle, ATabNo, AID, LK, '', AUstTabNo, AUstID);
  except
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

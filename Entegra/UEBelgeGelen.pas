unit UEBelgeGelen;

// Izibiz inbox'tan gelen e-belgeleri ceker ve EBELGE'ye kaydeder.
// FATBASLIK kaydi olusturulmaz; bu islem sonraki iceri alma akisina aittir.

interface

uses
  FireDAC.Comp.Client;

type
  /// AMevcut: simdiye kadar islenen, ATotal: toplam, ABilgi: gosterilecek metin
  TIlerlemeOlay = reference to procedure(const AMevcut, ATotal: Integer;
    const ABilgi: string);

  TEBelgeGelen = class
  public
    class function Cek(AConnection: TFDConnection;
      out AYeniSayi, AAtlananSayi: Integer;
      out AHata: string;
      AIlerleme: TIlerlemeOlay = nil; AEArsiv: Boolean = False): Boolean; static;
    /// EBELGE.YON=2 olup FATBASLIK linki olmayan kayitlar icin
    /// sp_Grnt_AlisFaturaIslem @TIP=1 cagirarak FATBASLIK olusturur.
    /// FATBASLIK.GNTPID = EBELGE.ID linkajini kurar, EFATURADURUM=-1 (Yeni Gelen).
    class function OlusturFatbaslikler(AConnection: TFDConnection;
      out AYeniSayi: Integer; out AHata: string;
      AIlerleme: TIlerlemeOlay = nil; AEArsiv: Boolean = False): Boolean; static;
  end;

/// EBELGE.UBL_XML sikistirma aktif mi? Opsiyon `Ops_FaturaOpsiyon_UBL_ZIP`
/// (varsayilan AÇIK). Aktifse UBL_XML_ZIP kolonunu oturumda bir kez garantiler +
/// dogrular; kolon yoksa/acilamiyorsa (yetki vs) False doner -> duz UBL_XML yazilir.
/// Boylece "default zip" olsa bile kolon eksikse e-belge bozulmaz.
function EBelgeUBLSikistir(AConnection: TFDConnection): Boolean;

/// Gelen belgenin saklanan UBL'inden tutarlari (matrah/KDV/dahil) yeniden
/// hesaplayip FATBASLIK'a yazar. "Kullanim disi"na alinirken sifirlanan
/// tutarlarin, tekrar sisteme/gelen kutusuna alinirken geri doldurulmasi icin.
/// EBELGE <-> FATBASLIK bagi: FATBASLIK.GNTPID = EBELGE.ID. UBL yoksa/tutar
/// cikarilamazsa False doner (FATBASLIK degismez).
function EBelgeGelenTutarlariUBLdenDoldur(AConnection: TFDConnection;
  AFatBaslikID: Integer): Boolean;

implementation

uses
  System.SysUtils, System.StrUtils, System.JSON, System.NetEncoding,
  System.IOUtils, Data.DB, System.Classes, System.Zip,
  Utablo, PrjConst, FetaKurulusSiniflari, UEBelgeKimlik, UIzibizRest;

var
  GUblZipKontrolEdildi: Boolean = False;   // oturumda kolon kontrolu yapildi mi
  GUblZipKullanilabilir: Boolean = False;  // UBL_XML_ZIP kolonu mevcut/kullanilabilir mi

function EBelgeUBLSikistir(AConnection: TFDConnection): Boolean;
var
  LQ: TFDQuery;
begin
  // Opsiyon varsayilan AÇIK (default zip).
  if not Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_UBL_ZIP, True) then
    Exit(False);
  // Kolonu oturumda bir kez garantile + dogrula. Yoksa/acilamiyorsa duz yaz.
  if not GUblZipKontrolEdildi then begin
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := AConnection;
      try
        LQ.SQL.Text :=
          'IF COL_LENGTH(''dbo.EBELGE'',''UBL_XML_ZIP'') IS NULL ' +
          'ALTER TABLE dbo.EBELGE ADD UBL_XML_ZIP varbinary(max) NULL';
        LQ.ExecSQL;
      except
        // yetki yoksa sessiz gec; asagidaki dogrulama sonucu belirler
      end;
      LQ.Close;
      LQ.SQL.Text := 'SELECT COL_LENGTH(''dbo.EBELGE'',''UBL_XML_ZIP'')';
      LQ.Open;
      GUblZipKullanilabilir := not LQ.Fields[0].IsNull;
    finally
      LQ.Free;
    end;
    GUblZipKontrolEdildi := True;
  end;
  Result := GUblZipKullanilabilir;
end;

function _JSONStr(AObj: TJSONObject; const AKey: string): string;
var
  LV: TJSONValue;
begin
  Result := '';
  if AObj = nil then Exit;
  LV := AObj.GetValue(AKey);
  if LV <> nil then Result := LV.Value;
end;

function _JSONChildStr(AObj: TJSONObject; const AKey, AChildKey: string): string;
var
  LV: TJSONValue;
begin
  Result := '';
  if AObj = nil then Exit;
  LV := AObj.GetValue(AKey);
  if LV is TJSONObject then
    Result := _JSONStr(TJSONObject(LV), AChildKey);
end;

// JSON null degerleri bazi surumlerde 'null' metni olarak gelir; bos kabul et.
function _NullBosalt(const S: string): string;
begin
  Result := Trim(S);
  if SameText(Result, 'null') then
    Result := '';
end;

procedure _IDAdd(var AArr: TArray<string>; const AID: string);
var
  LID: string;
  i, LLen: Integer;
begin
  LID := Trim(AID);
  if LID = '' then Exit;
  for i := 0 to High(AArr) do
    if SameText(AArr[i], LID) then Exit;
  LLen := Length(AArr);
  SetLength(AArr, LLen + 1);
  AArr[LLen] := LID;
end;

function _DownloadIDleri(AItem: TJSONObject; const AUUID: string): TArray<string>;
begin
  SetLength(Result, 0);
  // Izibiz /v2/einvoices/inbox/download/ubl endpoint'i InboxList icindeki
  // numerik document id alanini bekliyor. envelopeId veya UUID gonderilirse
  // 10013 NOT_VALID_REQUEST donuyor.
  _IDAdd(Result, _JSONStr(AItem, 'id'));
end;

function _ArrayBul(AObj: TJSONObject; out AArr: TJSONArray): Boolean;
var
  LV: TJSONValue;
  LData: TJSONObject;
begin
  AArr := nil;
  Result := False;
  if AObj = nil then Exit;
  LV := AObj.GetValue('data');
  if LV is TJSONArray then begin
    AArr := TJSONArray(LV);
    Exit(True);
  end;
  if LV is TJSONObject then begin
    LData := TJSONObject(LV);
    if LData.GetValue('contents') is TJSONArray then begin
      AArr := TJSONArray(LData.GetValue('contents'));
      Exit(True);
    end;
    if LData.GetValue('content') is TJSONArray then begin
      AArr := TJSONArray(LData.GetValue('content'));
      Exit(True);
    end;
    if LData.GetValue('items') is TJSONArray then begin
      AArr := TJSONArray(LData.GetValue('items'));
      Exit(True);
    end;
  end;
  if AObj.GetValue('contents') is TJSONArray then begin
    AArr := TJSONArray(AObj.GetValue('contents'));
    Exit(True);
  end;
  if AObj.GetValue('content') is TJSONArray then begin
    AArr := TJSONArray(AObj.GetValue('content'));
    Exit(True);
  end;
  if AObj.GetValue('items') is TJSONArray then begin
    AArr := TJSONArray(AObj.GetValue('items'));
    Exit(True);
  end;
end;

function _UBLContentCikar(const ADownJSON: string): string;
var
  LJSON, LV: TJSONValue;
  LObj: TJSONObject;
  LArr: TJSONArray;
  LB64: string;
  LBytes: TBytes;

  function _IcerikOku(AObj: TJSONObject): string;
  begin
    Result := '';
    if AObj = nil then Exit;
    Result := _JSONStr(AObj, 'content');
    if Result = '' then Result := _JSONStr(AObj, 'xml');
    if Result = '' then Result := _JSONStr(AObj, 'ubl');
    if Result = '' then Result := _JSONStr(AObj, 'fileContent');
    if Result = '' then Result := _JSONStr(AObj, 'documentContent');
    if Result = '' then Result := _JSONStr(AObj, 'binaryData');
  end;

  function _ZipXmlCikar(const ABytes: TBytes): string;
  var
    LZipStream: TBytesStream;
    LZip: TZipFile;
    LFileBytes: TBytes;
    i: Integer;
    LFileName, LExt: string;
  begin
    Result := '';
    if Length(ABytes) < 4 then Exit;
    if not ((ABytes[0] = $50) and (ABytes[1] = $4B)) then Exit;

    LZipStream := TBytesStream.Create(ABytes);
    LZip := TZipFile.Create;
    try
      LZip.Open(LZipStream, zmRead);
      for i := 0 to LZip.FileCount - 1 do begin
        LFileName := LZip.FileName[i];
        LExt := LowerCase(ExtractFileExt(LFileName));
        if (LExt = '.xml') or (i = 0) then begin
          LZip.Read(i, LFileBytes);
          Result := TEncoding.UTF8.GetString(LFileBytes);
          if (Pos('<', Trim(Result)) = 1) or (LExt = '.xml') then
            Exit;
        end;
      end;
    finally
      LZip.Free;
      LZipStream.Free;
    end;
  end;

  function _Coz(const S: string): string;
  begin
    Result := '';
    if Trim(S) = '' then Exit;
    try
      LBytes := TNetEncoding.Base64.DecodeStringToBytes(S);
      Result := _ZipXmlCikar(LBytes);
      if Result = '' then
        Result := TEncoding.UTF8.GetString(LBytes);
    except
      Result := S;
    end;
  end;

begin
  Result := '';
  if Trim(ADownJSON) = '' then Exit;
  if Pos('<', Trim(ADownJSON)) = 1 then Exit(ADownJSON);
  LJSON := TJSONObject.ParseJSONValue(ADownJSON);
  if LJSON = nil then Exit;
  try
    if LJSON is TJSONObject then begin
      LObj := TJSONObject(LJSON);
      LB64 := _IcerikOku(LObj);
      if LB64 <> '' then Exit(_Coz(LB64));

      LV := LObj.GetValue('data');
      if LV is TJSONObject then begin
        LB64 := _IcerikOku(TJSONObject(LV));
        if LB64 <> '' then Exit(_Coz(LB64));
      end;

      if _ArrayBul(LObj, LArr) then begin
        if (LArr.Count > 0) and (LArr.Items[0] is TJSONObject) then begin
          LB64 := _IcerikOku(TJSONObject(LArr.Items[0]));
          if LB64 <> '' then Exit(_Coz(LB64));
        end;
      end;
    end else if LJSON is TJSONArray then begin
      LArr := TJSONArray(LJSON);
      if (LArr.Count > 0) and (LArr.Items[0] is TJSONObject) then begin
        LB64 := _IcerikOku(TJSONObject(LArr.Items[0]));
        if LB64 <> '' then Exit(_Coz(LB64));
      end;
    end;
  finally
    LJSON.Free;
  end;
end;

function _EBelgeKayitBul(AConnection: TFDConnection; const AUUID: string;
  ABelgeTuru: Integer; out AEBelgeID: Int64; out AUblVar: Boolean): Boolean;
var
  LQry: TFDQuery;
begin
  Result := False;
  AEBelgeID := 0;
  AUblVar := False;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'select top 1 ID, UBLVAR=case when (UBL_XML_ZIP IS NOT NULL ' +
      'OR len(isnull(UBL_XML, N''''))>0) then 1 else 0 end ' +
      'from EBELGE where YON=2 and UUID=:UUID and BELGETURU=:BELGETURU order by ID desc';
    LQry.ParamByName('UUID').AsString := AUUID;
    LQry.ParamByName('BELGETURU').AsInteger := ABelgeTuru;
    LQry.Open;
    Result := not LQry.Eof;
    if Result then begin
      AEBelgeID := LQry.FieldByName('ID').AsLargeInt;
      AUblVar := LQry.FieldByName('UBLVAR').AsInteger = 1;
    end;
  finally
    LQry.Free;
  end;
end;

function _EBelgeKaydet(AConnection: TFDConnection; AEBelgeID: Int64;
  const AUUID, ABelgeNo, AGonderici, AAlici, AAPIJSON, AUBLXML: string;
  ABelgeTuru, ADurum, AKullanan: Integer): Int64;
var
  LQry: TFDQuery;
begin
  Result := AEBelgeID;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    // UBL sikistirma opsiyonu (EBELGE.UBL_XML_ZIP = COMPRESS). Acikken UBL_XML=NULL.
    // BOS UBL sikistirilmaz: COMPRESS('') non-null olurdu, var-mi kontrolu "UBL var"
    // sanip gercek UBL'in tekrar indirilmesini engellerdi.
    var LUxUpd, LUxIns: string;
    if (Trim(AUBLXML) <> '') and EBelgeUBLSikistir(AConnection) then begin
      LUxUpd := 'UBL_XML=NULL, UBL_XML_ZIP=COMPRESS(cast(:UX as nvarchar(max))), ';
      LUxIns := 'NULL, COMPRESS(cast(:UX as nvarchar(max)))';
    end else begin
      LUxUpd := 'UBL_XML=cast(:UX as nvarchar(max)), UBL_XML_ZIP=NULL, ';
      LUxIns := 'cast(:UX as nvarchar(max)), NULL';
    end;
    if AEBelgeID > 0 then begin
      LQry.SQL.Text :=
        'update EBELGE set BELGENO=:BNO, GONDERICIALIAS=:GA, ALICIALIAS=:AA, ' +
        'DURUM=:DURUM, API_JSON=cast(:AJ as nvarchar(max)), ' +
        LUxUpd + 'DEGISTIREN=:KUL, DEGISTIRMETARIHI=getdate() ' +
        'where ID=:ID';
      LQry.ParamByName('ID').AsLargeInt := AEBelgeID;
    end else begin
      LQry.SQL.Text :=
        'insert into EBELGE(FATBASLIKID, REHBERID, BELGETURU, YON, UUID, BELGENO, ' +
        'GONDERICIALIAS, ALICIALIAS, DURUM, API_JSON, UBL_XML, UBL_XML_ZIP, EKLEYEN, EKLEMETARIHI) values(' +
        '0, 0, :BELGETURU, 2, :UUID, :BNO, :GA, :AA, :DURUM, cast(:AJ as nvarchar(max)), ' +
        LUxIns + ', :KUL, getdate()); ' +
        'select cast(scope_identity() as bigint) as ID';
      LQry.ParamByName('UUID').AsString := AUUID;
      LQry.ParamByName('BELGETURU').AsInteger := ABelgeTuru;
    end;

    LQry.ParamByName('BNO').AsString := ABelgeNo;
    LQry.ParamByName('GA').AsString := AGonderici;
    LQry.ParamByName('AA').AsString := AAlici;
    LQry.ParamByName('DURUM').AsInteger := ADurum;
    LQry.ParamByName('AJ').DataType := ftWideMemo;
    LQry.ParamByName('AJ').AsWideMemo := AAPIJSON;
    LQry.ParamByName('UX').DataType := ftWideMemo;
    LQry.ParamByName('UX').AsWideMemo := AUBLXML;
    LQry.ParamByName('KUL').AsInteger := AKullanan;

    if AEBelgeID > 0 then
      LQry.ExecSQL
    else begin
      LQry.Open;
      Result := LQry.Fields[0].AsLargeInt;
    end;
  finally
    LQry.Free;
  end;
end;

procedure _HareketYaz(AConnection: TFDConnection; AEBelgeID: Int64;
  const AMesaj, AHataKodu, AHataMesaji: string; AHttpKodu, AKullanan: Integer);
var
  LQry: TFDQuery;
begin
  if AEBelgeID <= 0 then Exit;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'insert into EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,HTTPKODU,' +
      'SERVISKODU,HATAKODU,HATAMESAJI,EKLEYEN,EKLEMETARIHI) values(' +
      ':EID,2,2,:MT,:MSG,:HK,:SERVIS,:HKOD,:HMSG,:KUL,getdate())';
    LQry.ParamByName('EID').AsLargeInt := AEBelgeID;
    LQry.ParamByName('MT').AsInteger := 9;
    LQry.ParamByName('MSG').DataType := ftWideMemo;
    LQry.ParamByName('MSG').AsWideMemo := AMesaj;
    LQry.ParamByName('HK').DataType := ftInteger;
    if AHttpKodu > 0 then
      LQry.ParamByName('HK').AsInteger := AHttpKodu
    else
      LQry.ParamByName('HK').Clear;
    LQry.ParamByName('SERVIS').AsString := 'IZIBIZ';
    LQry.ParamByName('HKOD').AsString := AHataKodu;
    LQry.ParamByName('HMSG').DataType := ftWideMemo;
    LQry.ParamByName('HMSG').AsWideMemo := AHataMesaji;
    LQry.ParamByName('KUL').AsInteger := AKullanan;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function _EBelgeMevcutStatusKod(AConn: TFDConnection; AEBelgeID: Int64): Integer;
// Mevcut EBELGE.API_JSON icindeki statusCode'u oku. Yoksa 0 doner.
var
  LQ: TFDQuery; LJSON: TJSONValue; LStr: string;
begin
  Result := 0;
  if AEBelgeID <= 0 then Exit;
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConn;
    LQ.SQL.Text := 'select cast(API_JSON as nvarchar(max)) AJ from EBELGE where ID=' + IntToStr(AEBelgeID);
    LQ.Open;
    if not LQ.Eof then begin
      LStr := LQ.Fields[0].AsString;
      if Trim(LStr) <> '' then begin
        LJSON := TJSONObject.ParseJSONValue(LStr);
        if LJSON is TJSONObject then
          Result := StrToIntDef(_JSONStr(TJSONObject(LJSON), 'statusCode'), 0);
        if LJSON <> nil then LJSON.Free;
      end;
    end;
    LQ.Close;
  finally LQ.Free; end;
end;

procedure _IzibizDurumMesajYaz(AConn: TFDConnection; AEBelgeID: Int64;
  AItem: TJSONObject; AKullanan: Integer);
// Izibiz item icindeki status/aciklama bilgilerini EBELGEMESAJ tablosuna yazar.
// MESAJTIPI: 9 Hata (red), 2 Yanit (kabul/zaman dolma), 1 Bilgi (diger).
var
  LStatus, LStatusDesc, LMesaj, LHataKod: string;
  LStatusKod, LMesajTipi: Integer;
  LQ: TFDQuery;
begin
  if AEBelgeID <= 0 then Exit;
  LStatusKod := StrToIntDef(_JSONStr(AItem, 'statusCode'), 0);
  LStatus := _JSONStr(AItem, 'status');
  LStatusDesc := _JSONStr(AItem, 'statusDescription');
  if LStatusDesc = '' then LStatusDesc := _JSONStr(AItem, 'description');
  if LStatusDesc = '' then LStatusDesc := _JSONStr(AItem, 'rejectionReason');
  if LStatusDesc = '' then LStatusDesc := _JSONStr(AItem, 'responseDescription');
  if LStatusDesc = '' then LStatusDesc := _JSONStr(AItem, 'message');

  LMesaj := 'Izibiz durumu: ';
  if LStatus <> '' then LMesaj := LMesaj + LStatus
  else LMesaj := LMesaj + IntToStr(LStatusKod);
  if (LStatusKod > 0) and (LStatus <> '') then
    LMesaj := LMesaj + ' (kod: ' + IntToStr(LStatusKod) + ')';
  if LStatusDesc <> '' then LMesaj := LMesaj + sLineBreak + LStatusDesc;

  if LStatusKod > 0 then LHataKod := IntToStr(LStatusKod) else LHataKod := '';

  case LStatusKod of
    107, 126: LMesajTipi := 9;     // Rejected -> Hata
    108, 109: LMesajTipi := 2;     // Accepted / TimeExpired -> Yanit
  else
    LMesajTipi := 1;                // New / Received / Waiting -> Bilgi
  end;

  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConn;
    LQ.SQL.Text :=
      'insert into EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,' +
      'SERVISKODU,HATAKODU,HATAMESAJI,EKLEYEN,EKLEMETARIHI) values(' +
      ':EID,2,2,:MT,:MSG,:SERVIS,:HKOD,:HMSG,:KUL,getdate())';
    LQ.ParamByName('EID').AsLargeInt := AEBelgeID;
    LQ.ParamByName('MT').AsInteger := LMesajTipi;
    LQ.ParamByName('MSG').DataType := ftWideMemo;
    LQ.ParamByName('MSG').AsWideMemo := LMesaj;
    LQ.ParamByName('SERVIS').AsString := 'IZIBIZ';
    LQ.ParamByName('HKOD').AsString := LHataKod;
    LQ.ParamByName('HMSG').DataType := ftWideMemo;
    LQ.ParamByName('HMSG').AsWideMemo := LStatusDesc;
    LQ.ParamByName('KUL').AsInteger := AKullanan;
    LQ.ExecSQL;
  finally LQ.Free; end;
end;

function _IzibizStatusEsle(AStatusCode: Integer;
  out ADurum, ASonuc: Integer): Boolean;
// Izibiz inbox statusCode -> FATBASLIK.EFATURADURUM/EFATURASONUC eslemesi (alis).
// Gelen tarafinda EFATURADURUM her zaman -1 (gelen kutusu); detay EFATURASONUC ile.
// Bilinmeyen kodlar icin Result=False (mevcut state korunur).
//   100 New                 -> -1 / 0
//   106 WaitingForResponse  -> -1 / 6 (Yanit bekliyor)
//   107/126 Rejected        -> -1 / 3 (Hata/Red)
//   108 Accepted            -> -1 / 2 (Kabul)
//   109 ResponseTimeExpired -> -1 / 12 (Kanunen kabul)
//   113 Received            -> -1 / 0
begin
  Result := True;
  ADurum := -1;
  case AStatusCode of
    100, 113: ASonuc := 0;
    106:      ASonuc := 6;
    107, 126: ASonuc := 3;
    108:      ASonuc := 2;
    109:      ASonuc := 12;
  else
    ASonuc := 0;
    Result := False;
  end;
end;

function _StatusNormalize(const AStatus: string): string;
begin
  Result := Trim(AStatus);
  Result := StringReplace(Result, 'ı', 'I', [rfReplaceAll]);
  Result := StringReplace(Result, 'İ', 'I', [rfReplaceAll]);
  Result := StringReplace(Result, 'ğ', 'G', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ğ', 'G', [rfReplaceAll]);
  Result := StringReplace(Result, 'ü', 'U', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ü', 'U', [rfReplaceAll]);
  Result := StringReplace(Result, 'ş', 'S', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ş', 'S', [rfReplaceAll]);
  Result := StringReplace(Result, 'ö', 'O', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ö', 'O', [rfReplaceAll]);
  Result := StringReplace(Result, 'ç', 'C', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ç', 'C', [rfReplaceAll]);
  Result := UpperCase(Result);
  Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  Result := StringReplace(Result, '_', '', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '', [rfReplaceAll]);
end;

function _IzibizStatusMetinEsle(const AStatus: string;
  out ADurum, ASonuc: Integer): Boolean;
var
  S: string;
begin
  Result := True;
  S := _StatusNormalize(AStatus);

  if (S = '') then
    Result := False
  else if (S = 'YANITGEREKMIYOR') or (S = 'YANITGEREKMEZ') or
          (S = 'RESPONSEISNOTREQUIRED') or (S = 'NORESPONSEREQUIRED') then begin
    ADurum := -1; ASonuc := 11;
  end else if (S = 'KANUNENKABUL') or (S = 'DEEMEDACCEPTED') or
              (S = 'ACCEPTEDBYLAW') then begin
    ADurum := -1; ASonuc := 12;
  end else if (S = 'YANITBEKLIYOR') or (S = 'CEVAPBEKLIYOR') or
              (S = 'WAITINGFORRESPONSE') or (S = 'WAITING') then begin
    ADurum := -1; ASonuc := 6;
  end else if (S = 'INPROCESSING') or (S = 'PROCESSING') then begin
    ADurum := -1; ASonuc := 1;
  end else if (S = 'REJECTED') or (S = 'RED') or (S = 'UNDELIVERED') or
              (S = 'REDDEDILDI') then begin
    ADurum := -1; ASonuc := 3;
  end else if (S = 'ACCEPTED') or (S = 'KABUL') or (S = 'KABULEDILDI') then begin
    ADurum := -1; ASonuc := 2;
  end else if (S = 'RESPONSETIMEEXPIRED') or (S = 'TIMEEXPIRED') or
              (S = 'CEVAPZAMANIGECTI') or (S = 'CEVAPSURESIGECTI') then begin
    ADurum := -1; ASonuc := 12;
  end else if (S = 'RECEIVED') or (S = 'ALINDI') then begin
    ADurum := -1; ASonuc := 11;
  end else
    Result := False;
end;

function _IzibizItemStatusEsle(AItem: TJSONObject;
  out ADurum, ASonuc: Integer): Boolean;
var
  LStatusKod: Integer;
  LDocStatus, LProfile: string;
begin
  Result := False;
  ADurum := -1;
  ASonuc := 0;
  if AItem = nil then Exit;

  Result := _IzibizStatusMetinEsle(_JSONStr(AItem, 'responseStatus'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'responseStatusDescription'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'responseStatusDisplay'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'answerStatus'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'replyStatus'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'statusDesc'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'statusDisplay'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'statusDescription'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONChildStr(AItem, 'documentStatus', 'label'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONChildStr(AItem, 'documentStatus', 'value'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'documentStatus'), ADurum, ASonuc) or
            _IzibizStatusMetinEsle(_JSONStr(AItem, 'status'), ADurum, ASonuc);
  if Result then Exit;

  LDocStatus := _StatusNormalize(_JSONChildStr(AItem, 'documentStatus', 'value'));
  if LDocStatus = '' then
    LDocStatus := _StatusNormalize(_JSONStr(AItem, 'documentStatus'));
  LProfile := _StatusNormalize(_JSONStr(AItem, 'profile'));
  if (LDocStatus = 'NEW') or (LDocStatus = 'DELIVERED') or (LDocStatus = 'RECEIVED') then begin
    ADurum := -1;
    if (LProfile = 'TEMELFATURA') or (LProfile = 'EARSIVFATURA') then
      ASonuc := 11
    else
      ASonuc := 6;
    Exit(True);
  end;

  LStatusKod := StrToIntDef(_JSONStr(AItem, 'statusCode'), 0);
  if (LStatusKod > 0) and _IzibizStatusEsle(LStatusKod, ADurum, ASonuc) then
    Exit(True);
end;

class function TEBelgeGelen.Cek(AConnection: TFDConnection;
  out AYeniSayi, AAtlananSayi: Integer;
  out AHata: string;
  AIlerleme: TIlerlemeOlay; AEArsiv: Boolean): Boolean;
var
  LKullanici, LSifre, LBaseURL: string;
  LTestMi: Boolean;
  LToken, LIdentifier, LName: string;
  LYanitJSON, LDownJSON, LXMLContent, LBelgeNo, LGonderici, LAlici, LDownHata,
    LEArsivGelenURL: string;
  LDownloadHatalari, LUyari: string;
  LHttpKodu, LDownHttp, i, j, LKullanan, LIndirilemeyen, LGuncellenen: Integer;
  LJSON: TJSONValue;
  LObj, LItem: TJSONObject;
  LArr: TJSONArray;
  LUUID, LDownloadID: string;
  LDownloadIDs, LSingleID: TArray<string>;
  LKayitVar, LUblVar, LDownloadOK, LIndirmeCagrisiOK, LIVDMain: Boolean;
  LEBelgeID: Int64;
  LPage, LSayfaBoyu, LSayfaSayisi, LMaxSayfa: Integer;
  LBaslangic: TDate;
  LBelgeTuru: Integer;
begin
  Result := False;
  AYeniSayi := 0;
  AAtlananSayi := 0;
  LIndirilemeyen := 0;
  LGuncellenen := 0;
  AHata := '';
  if AEArsiv then
    LBelgeTuru := 150
  else
    LBelgeTuru := 151;

  TEBelgeKimlik.Yukle(LKullanici, LSifre, LBaseURL, LTestMi);
  if AEArsiv then begin
    LEArsivGelenURL := Trim(Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EArsivGelenURL, ''));
    if LEArsivGelenURL <> '' then
      LBaseURL := LEArsivGelenURL;
  end;
  LIVDMain := ContainsText(LBaseURL, '/IVD/main') or
              ContainsText(LBaseURL, '/GIB/main');
  if (Trim(LKullanici) = '') or (Trim(LSifre) = '') or (Trim(LBaseURL) = '') then begin
    AHata := 'Opsiyon ekranindan kullanici/sifre/URL girilmemis.';
    Exit;
  end;

  LIdentifier := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LName := KURUMADI;

  if not TIzibizRest.Login(LBaseURL, LKullanici, LSifre, LIdentifier, LName,
                           LToken, AHata) then
    Exit;

  LKullanan := StrToIntDef(Kullanan, 0);
  LPage := 0;       // Izibiz pagination 0-based (page=0 ilk sayfa)
  LSayfaBoyu := 100;
  LMaxSayfa := 100; // Sonsuz dongu emniyeti: 100 sayfa x 100 kayit = 10000 fatura tavan

  // Baslangic tarihi sabit alt sinirla belirlenir (bu tarihten oncesi cekilmez):
  //   Test modu  -> 01.05.2026 (test ortami)
  //   Uretim     -> 01.01.2026 (canli)
  if LTestMi then
    LBaslangic := EncodeDate(2026, 5, 1)
  else
    LBaslangic := EncodeDate(2026, 1, 1);

  repeat
    // Status filtresi yok: Delivered/New/WaitingForResponse vb. tum kayitlar gelir.
    if AEArsiv then begin
      if not TIzibizRest.EArchiveInboxList(LBaseURL, LToken, '',
                                           LBaslangic, Date,
                                           LPage, LSayfaBoyu,
                                           LYanitJSON, LHttpKodu, AHata) then
        Exit;
    end else begin
      if not TIzibizRest.InboxList(LBaseURL, LToken, '',
                                   LBaslangic, Date,
                                   LPage, LSayfaBoyu,
                                   LYanitJSON, LHttpKodu, AHata) then
        Exit;
    end;

    try
      TFile.WriteAllText(TPath.Combine(TPath.GetTempPath,
                         'izibiz_inbox_p' + IntToStr(LPage) + '.json'),
                         LYanitJSON, TEncoding.UTF8);
    except end;

    LJSON := TJSONObject.ParseJSONValue(LYanitJSON);
    if not (LJSON is TJSONObject) then begin
      if LJSON <> nil then LJSON.Free;
      AHata := 'InboxList (page=' + IntToStr(LPage) +
               '): yanit JSON object degil. Ham: ' + Copy(LYanitJSON, 1, 500);
      Exit;
    end;
    LObj := TJSONObject(LJSON);

    try
      if not _ArrayBul(LObj, LArr) then begin
        AHata := 'InboxList (page=' + IntToStr(LPage) +
                 '): data/content array bulunamadi. Ham: ' + Copy(LYanitJSON, 1, 500);
        Exit;
      end;

      LSayfaSayisi := LArr.Count;

      for i := 0 to LArr.Count - 1 do begin
        if Assigned(AIlerleme) then
          AIlerleme(i + 1, LArr.Count,
                    'Izibiz inbox sayfa ' + IntToStr(LPage) + ' indiriliyor');
      if not (LArr.Items[i] is TJSONObject) then Continue;
      LItem := TJSONObject(LArr.Items[i]);

      LUUID := _JSONStr(LItem, 'uuid');
      if LUUID = '' then LUUID := _JSONStr(LItem, 'documentUUID');
      if LUUID = '' then LUUID := _JSONStr(LItem, 'envelopeUUID');
      if LUUID = '' then begin
        var LEnv: TJSONValue := LItem.GetValue('envelope');
        if LEnv is TJSONObject then
          LUUID := _JSONStr(TJSONObject(LEnv), 'identifier');
      end;
      if LUUID = '' then LUUID := _JSONStr(LItem, 'id');
      if LUUID = '' then Continue;

      if AEArsiv and SameText(_NullBosalt(_JSONStr(LItem, 'direction')), 'OUT') then begin
        Inc(AAtlananSayi);
        Continue;
      end;

      LKayitVar := _EBelgeKayitBul(AConnection, LUUID, LBelgeTuru, LEBelgeID, LUblVar);

      // Mevcut kayit varsa, Izibiz statusCode'a gore baglandiysa FATBASLIK'i da
      // guncelle (sync). Bu sayede sonradan degisen GIB durumu yansir.
      if LKayitVar then begin
        var LDurum, LSonuc, LEskiStatus, LYeniStatus: Integer;
        LEskiStatus := _EBelgeMevcutStatusKod(AConnection, LEBelgeID);
        LYeniStatus := StrToIntDef(_JSONStr(LItem, 'statusCode'), 0);
        if _IzibizItemStatusEsle(LItem, LDurum, LSonuc) then begin
          if AEArsiv then
            LDurum := -11;
          Veritabani.BasitKomutÇalıştır(AConnection,
            'UPDATE FATBASLIK SET EFATURADURUM=&D, EFATURASONUC=&S ' +
            'WHERE ID IN (SELECT FATBASLIKID FROM EBELGE WHERE ID=&EID AND FATBASLIKID > 0)',
            ['&D', '&S', '&EID'], [LDurum, LSonuc, LEBelgeID]);
        end;
        // API_JSON'u da tazele - sonraki sync'ler icin son state korunsun
        Veritabani.BasitKomutÇalıştır(AConnection,
          'UPDATE EBELGE SET API_JSON=cast(&AJ as nvarchar(max)) WHERE ID=&EID',
          ['&AJ', '&EID'], [LItem.ToJSON, LEBelgeID]);
        // Status degistiyse mesaj kaydet (kullanici Mesajlar dialogunda gorsun).
        if (LYeniStatus > 0) and (LYeniStatus <> LEskiStatus) then
          _IzibizDurumMesajYaz(AConnection, LEBelgeID, LItem, LKullanan);
      end;

      if LKayitVar and LUblVar then begin
        Inc(AAtlananSayi);
        Continue;
      end;

      LBelgeNo := _JSONStr(LItem, 'documentNo');
      LGonderici := _JSONStr(LItem, 'supplierAlias');
      if LGonderici = '' then LGonderici := _JSONStr(LItem, 'supplierSSN');
      LAlici := _JSONStr(LItem, 'customerAlias');
      if LAlici = '' then LAlici := _JSONStr(LItem, 'customerSSN');

      LXMLContent := '';
      LDownloadOK := False;
      LDownloadHatalari := '';
      if AEArsiv and LIVDMain then
        LDownloadOK := True
      else begin
      LDownloadIDs := _DownloadIDleri(LItem, LUUID);
      for j := 0 to High(LDownloadIDs) do begin
        LDownloadID := LDownloadIDs[j];
        SetLength(LSingleID, 1);
        LSingleID[0] := LDownloadID;
        LDownJSON := '';
        LDownHata := '';
        LDownHttp := 0;
        if AEArsiv then
          LIndirmeCagrisiOK := TIzibizRest.EArchiveInboxDownloadUBL(LBaseURL, LToken, LSingleID,
            LDownJSON, LDownHttp, LDownHata)
        else
          LIndirmeCagrisiOK := TIzibizRest.InboxDownloadUBL(LBaseURL, LToken, LSingleID,
            LDownJSON, LDownHttp, LDownHata);
        if LIndirmeCagrisiOK then begin
          LXMLContent := _UBLContentCikar(LDownJSON);
          if Trim(LXMLContent) <> '' then begin
            LDownloadOK := True;
            Break;
          end;
          if LDownloadHatalari <> '' then LDownloadHatalari := LDownloadHatalari + sLineBreak;
          LDownloadHatalari := LDownloadHatalari + 'ID=' + LDownloadID +
            ' HTTP=' + IntToStr(LDownHttp) + ' yanitindan XML cikarilamadi. Yanit: ' +
            Copy(LDownJSON, 1, 500);
        end else begin
          if LDownloadHatalari <> '' then LDownloadHatalari := LDownloadHatalari + sLineBreak;
          LDownloadHatalari := LDownloadHatalari + 'ID=' + LDownloadID + ': ' + LDownHata;
        end;
      end;
      end;

      if not LDownloadOK then begin
        LEBelgeID := _EBelgeKaydet(AConnection, LEBelgeID, LUUID, LBelgeNo,
          LGonderici, LAlici, LItem.ToJSON, '', LBelgeTuru, 9, LKullanan);
        _HareketYaz(AConnection, LEBelgeID,
          'Izibiz XML icerigi indirilemedi. Metadata EBELGE kaydina alindi.',
          'UBL_DOWNLOAD', LDownloadHatalari, LDownHttp, LKullanan);
        Inc(LIndirilemeyen);
        Continue;
      end;

      LEBelgeID := _EBelgeKaydet(AConnection, LEBelgeID, LUUID, LBelgeNo,
        LGonderici, LAlici, LItem.ToJSON, LXMLContent, LBelgeTuru, 1, LKullanan);
      if LKayitVar then
        Inc(LGuncellenen)
      else begin
        Inc(AYeniSayi);
        // Yeni EBELGE - Izibiz durum mesajini ilk kez yaz.
        _IzibizDurumMesajYaz(AConnection, LEBelgeID, LItem, LKullanan);
      end;
    end;
    finally
      LObj.Free;
    end;

    Inc(LPage);
  until (LSayfaSayisi < LSayfaBoyu) or (LPage > LMaxSayfa);

  if LGuncellenen > 0 then
    LUyari := 'XML sonradan tamamlanan: ' + IntToStr(LGuncellenen);
  if LIndirilemeyen > 0 then begin
    if LUyari <> '' then LUyari := LUyari + sLineBreak;
    LUyari := LUyari + 'XML indirilemeyen ve DURUM=9 olarak kaydedilen: ' +
      IntToStr(LIndirilemeyen);
  end;
  AHata := LUyari;
  Result := True;
end;

// ---- EBELGE -> FATBASLIK donusumu (sp_Grnt_AlisFaturaIslem) ----

function _ParseTRSayi(const AStr: string): Currency;
// "15.772,56" -> 15772.56
var
  S: string;
  FS: TFormatSettings;
begin
  S := Trim(AStr);
  if S = '' then Exit(0);
  S := StringReplace(S, '.', '', [rfReplaceAll]);
  S := StringReplace(S, ',', '.', [rfReplaceAll]);
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  FS.ThousandSeparator := #0;
  try
    Result := StrToCurr(S, FS);
  except
    Result := 0;
  end;
end;

function _ParseUBLSayi(const AStr: string): Currency;
// UBL standart formati: '1306.09' (nokta ondalik, binlik ayrac yok)
var
  S: string;
  FS: TFormatSettings;
begin
  S := Trim(AStr);
  if S = '' then Exit(0);
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  FS.ThousandSeparator := #0;
  try
    Result := StrToCurr(S, FS);
  except
    Result := 0;
  end;
end;

function _SQLEscape(const AStr: string): string;
begin
  Result := StringReplace(AStr, '''', '''''', [rfReplaceAll]);
end;

function _JSONEscape(const AStr: string): string;
// JSON string value icin kacis: \, ", control chars
begin
  Result := AStr;
  Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #9, '\t', [rfReplaceAll]);
end;

function _XMLTagDeger(const AXML, AStartTag, AEndTag: string;
  AStartPos: Integer = 1): string;
// AStartTag ile AEndTag arasindaki ilk metin
var P1, P2: Integer;
begin
  Result := '';
  P1 := PosEx(AStartTag, AXML, AStartPos);
  if P1 = 0 then Exit;
  P1 := P1 + Length(AStartTag);
  P2 := PosEx(AEndTag, AXML, P1);
  if P2 = 0 then Exit;
  Result := Trim(Copy(AXML, P1, P2 - P1));
end;

procedure _SupplierBilgiCikar(const AUBLXML: string;
  out AAdres, AILCE, AIL, AVD, ABaslik, AVNO: string);
// UBL'den AccountingSupplierParty bloku icindeki bilgileri
var
  LBlok, LPartyName: string;
  LStartPos, LEndPos: Integer;
const
  CStart = '<cac:AccountingSupplierParty>';
  CEnd = '</cac:AccountingSupplierParty>';
begin
  AAdres := '';
  AILCE := '';
  AIL := '';
  AVD := '';
  ABaslik := '';
  AVNO := '';
  if Trim(AUBLXML) = '' then Exit;

  LStartPos := Pos(CStart, AUBLXML);
  if LStartPos = 0 then Exit;
  LEndPos := PosEx(CEnd, AUBLXML, LStartPos);
  if LEndPos = 0 then Exit;
  LBlok := Copy(AUBLXML, LStartPos, LEndPos - LStartPos);

  AAdres := _XMLTagDeger(LBlok, '<cbc:StreetName>', '</cbc:StreetName>');
  AILCE := _XMLTagDeger(LBlok, '<cbc:CitySubdivisionName>', '</cbc:CitySubdivisionName>');
  AIL := _XMLTagDeger(LBlok, '<cbc:CityName>', '</cbc:CityName>');

  // Vergi dairesi: PartyTaxScheme > TaxScheme > Name
  AVD := _XMLTagDeger(LBlok, '<cac:PartyTaxScheme>', '</cac:PartyTaxScheme>');
  if AVD <> '' then
    AVD := _XMLTagDeger(AVD, '<cbc:Name>', '</cbc:Name>');

  // BASLIK: Once PartyLegalEntity/RegistrationName (resmi unvan), sonra PartyName/Name
  ABaslik := _XMLTagDeger(LBlok, '<cbc:RegistrationName>', '</cbc:RegistrationName>');
  if ABaslik = '' then begin
    LPartyName := _XMLTagDeger(LBlok, '<cac:PartyName>', '</cac:PartyName>');
    if LPartyName <> '' then
      ABaslik := _XMLTagDeger(LPartyName, '<cbc:Name>', '</cbc:Name>');
  end;

  // VNO: PartyIdentification > ID (schemeID=VKN/TCKN)
  AVNO := _XMLTagDeger(LBlok, 'schemeID="VKN">', '</cbc:ID>');
  if AVNO = '' then
    AVNO := _XMLTagDeger(LBlok, 'schemeID="TCKN">', '</cbc:ID>');
end;

function _XMLDegerInline(const AXML, ATagBas: string; const AEndTag: string): string;
// Attribute'li veya plain tag'in icerigini doner.
// Ornek: <cbc:LineExtensionAmount currencyID="TRY">100.00</cbc:LineExtensionAmount>
// ATagBas: '<cbc:LineExtensionAmount', AEndTag: '</cbc:LineExtensionAmount>'
var P, P2: Integer;
begin
  Result := '';
  P := Pos(ATagBas, AXML);
  if P = 0 then Exit;
  P := PosEx('>', AXML, P);
  if P = 0 then Exit;
  Inc(P);
  P2 := PosEx(AEndTag, AXML, P);
  if P2 = 0 then Exit;
  Result := Trim(Copy(AXML, P, P2 - P));
end;

function _AttrDeger(const AXML, ATag, AAttr: string): string;
// <cbc:InvoicedQuantity unitCode="C62">... -> "C62"
var P, P2: Integer;
  LBlokBitis: Integer;
begin
  Result := '';
  P := Pos(ATag, AXML);
  if P = 0 then Exit;
  LBlokBitis := PosEx('>', AXML, P);
  if LBlokBitis = 0 then Exit;
  P := Pos(AAttr + '="', AXML);
  if (P = 0) or (P > LBlokBitis) then Exit;
  Inc(P, Length(AAttr) + 2);
  P2 := PosEx('"', AXML, P);
  if P2 = 0 then Exit;
  Result := Copy(AXML, P, P2 - P);
end;

procedure _UBLDetaylariEkle(AConn: TFDConnection; AFatBaslikID, ARehberID,
  AKullanan: Integer; const AUBL: string);
// UBL'deki tum <cac:InvoiceLine> bloklarini parse edip
// sp_Grnt_AlisFaturaHareketIslem @TIP=1 ile FATURA'ya satir ekler.
// URUNKOD bos gonderilir -> SP otomatik URUNID=0 ("Tanimsiz Urun") yazar.
// ACIKLAMA = UBL'deki Item/Name.
var
  LIdx, LBlokSon: Integer;
  LBlok, LItem, LTax, LPrice, LJSON: string;
  LAciklama, LAdet, LBirim, LTutar, LBirimFiyat, LKDV, LKur: string;
  LSP: TFDQuery;
begin
  if Trim(AUBL) = '' then Exit;
  LIdx := 1;
  LSP := TFDQuery.Create(nil);
  try
    LSP.Connection := AConn;
    while True do begin
      LIdx := PosEx('<cac:InvoiceLine>', AUBL, LIdx);
      if LIdx = 0 then Break;
      LBlokSon := PosEx('</cac:InvoiceLine>', AUBL, LIdx);
      if LBlokSon = 0 then Break;
      LBlok := Copy(AUBL, LIdx, LBlokSon - LIdx);
      LIdx := LBlokSon + Length('</cac:InvoiceLine>');

      LAdet := _XMLDegerInline(LBlok, '<cbc:InvoicedQuantity', '</cbc:InvoicedQuantity>');
      LBirim := _AttrDeger(LBlok, '<cbc:InvoicedQuantity', 'unitCode');
      if LBirim = '' then LBirim := 'C62';

      LTutar := _XMLDegerInline(LBlok, '<cbc:LineExtensionAmount', '</cbc:LineExtensionAmount>');

      LTax := _XMLDegerInline(LBlok, '<cac:TaxSubtotal', '</cac:TaxSubtotal>');
      LKDV := _XMLDegerInline(LTax, '<cbc:Percent', '</cbc:Percent>');
      if LKDV = '' then LKDV := '0';

      LPrice := _XMLDegerInline(LBlok, '<cac:Price', '</cac:Price>');
      LBirimFiyat := _XMLDegerInline(LPrice, '<cbc:PriceAmount', '</cbc:PriceAmount>');

      LItem := _XMLDegerInline(LBlok, '<cac:Item', '</cac:Item>');
      LAciklama := _XMLDegerInline(LItem, '<cbc:Name', '</cbc:Name>');

      // Urun tanimlayicisi (oncelik sirasiyla); FATURA.IZLEMEKODU'na yazilir.
      // Eslestirme sirasinda STOK_ESLESTIRME.GELEN_KOD ile karsilastirilir.
      var LUrunNo: string;
      LUrunNo := _XMLDegerInline(_XMLDegerInline(LItem,
                  '<cac:SellersItemIdentification', '</cac:SellersItemIdentification>'),
                  '<cbc:ID', '</cbc:ID>');
      if LUrunNo = '' then
        LUrunNo := _XMLDegerInline(_XMLDegerInline(LItem,
                    '<cac:BuyersItemIdentification', '</cac:BuyersItemIdentification>'),
                    '<cbc:ID', '</cbc:ID>');
      if LUrunNo = '' then
        LUrunNo := _XMLDegerInline(_XMLDegerInline(LItem,
                    '<cac:StandardItemIdentification', '</cac:StandardItemIdentification>'),
                    '<cbc:ID', '</cbc:ID>');
      if LUrunNo = '' then
        LUrunNo := _XMLDegerInline(_XMLDegerInline(LItem,
                    '<cac:ManufacturersItemIdentification', '</cac:ManufacturersItemIdentification>'),
                    '<cbc:ID', '</cbc:ID>');
      if Length(LUrunNo) > 40 then LUrunNo := Copy(LUrunNo, 1, 40);

      LKur := _AttrDeger(LBlok, '<cbc:LineExtensionAmount', 'currencyID');
      if LKur = '' then LKur := 'TRY';
      if SameText(LKur, 'TRY') then LKur := 'TL';

      // Sayisal degerler bos olamaz; SP'ye gonderirken default 0.
      if LAdet = ''      then LAdet := '0';
      if LTutar = ''     then LTutar := '0';
      if LBirimFiyat = '' then LBirimFiyat := '0';

      LJSON := '{' +
        '"FATBASID":' + IntToStr(AFatBaslikID) + ',' +
        '"REHBERID":' + IntToStr(ARehberID) + ',' +
        '"URUNKOD":"",' +
        '"URUNNO":"' + _JSONEscape(LUrunNo) + '",' +
        '"ACIKLAMA":"' + _JSONEscape(LAciklama) + '",' +
        '"ADET":' + LAdet + ',' +
        '"BIRIM":"' + _JSONEscape(LBirim) + '",' +
        '"BIRIMFIYAT":' + LBirimFiyat + ',' +
        '"TUTAR":' + LTutar + ',' +
        '"KDV":' + LKDV + ',' +
        '"ISKONTO":0,' +
        '"KUR":"' + LKur + '",' +
        '"DOVIZ_TUTARI":' + LTutar + ',' +
        '"DOVIZ_BIRIMFIYAT":' + LBirimFiyat + ',' +
        '"DOVIZ_KURU":"' + LKur + '",' +
        '"EKLEYEN":' + IntToStr(AKullanan) +
      '}';

      try
        LSP.SQL.Text :=
          'DECLARE @sid INT, @smsg VARCHAR(5000); ' +
          'EXEC sp_Grnt_AlisFaturaHareketIslem @jsonData=:j, @TIP=1, ' +
          ' @SONUC_ID=@sid OUTPUT, @SONUC_MESAJ=@smsg OUTPUT; ' +
          'SELECT @sid AS SID, @smsg AS SMSG';
        LSP.ParamByName('j').AsString := LJSON;
        LSP.Open;
        LSP.Close;
      except
        // Satir hatasi tum FATBASLIK'i bozmasin; sessizce gec.
      end;
    end;
  finally
    LSP.Free;
  end;
end;

type
  TGelenSatir = record
    EBelgeID: Int64;
    BelgeNo: string;
    APIJSON: string;
    UBLXML: string;
  end;

function EBelgeGelenTutarlariUBLdenDoldur(AConnection: TFDConnection;
  AFatBaslikID: Integer): Boolean;
var
  LSel: TFDQuery;
  LFmt: TFormatSettings;
  LUbl, LLMT, LTaxBlok, LMatStr, LDahilStr, LKDVStr: string;
  LMatrah, LDahil, LKDV: Currency;
begin
  Result := False;
  if AFatBaslikID <= 0 then Exit;
  LFmt := TFormatSettings.Create;
  LFmt.DecimalSeparator := '.';
  LFmt.ThousandSeparator := #0;

  LSel := TFDQuery.Create(nil);
  try
    LSel.Connection := AConnection;
    LSel.SQL.Text :=
      'SELECT TOP 1 COALESCE(CAST(DECOMPRESS(E.UBL_XML_ZIP) AS NVARCHAR(MAX)),' +
      '                     CAST(E.UBL_XML AS NVARCHAR(MAX))) AS UBLXML ' +
      'FROM EBELGE E JOIN FATBASLIK FB ON FB.GNTPID = E.ID ' +
      'WHERE FB.ID=:F AND E.YON=2 ORDER BY E.ID DESC';
    LSel.ParamByName('F').AsInteger := AFatBaslikID;
    LSel.Open;
    if LSel.Eof then Exit;
    LUbl := LSel.FieldByName('UBLXML').AsString;
  finally
    LSel.Free;
  end;
  if Trim(LUbl) = '' then Exit;

  // Ayni parse mantigi OlusturFatbaslikler icinde de var (ilk olusturmada).
  LLMT := _XMLTagDeger(LUbl,
    '<cac:LegalMonetaryTotal>', '</cac:LegalMonetaryTotal>');
  if LLMT <> '' then begin
    // Matrah: TaxExclusiveAmount (varsa) yoksa LineExtensionAmount
    LMatStr := _XMLDegerInline(LLMT,
      '<cbc:TaxExclusiveAmount', '</cbc:TaxExclusiveAmount>');
    if LMatStr = '' then
      LMatStr := _XMLDegerInline(LLMT,
        '<cbc:LineExtensionAmount', '</cbc:LineExtensionAmount>');
    // Genel toplam: PayableAmount (varsa) yoksa TaxInclusiveAmount
    LDahilStr := _XMLDegerInline(LLMT,
      '<cbc:PayableAmount', '</cbc:PayableAmount>');
    if LDahilStr = '' then
      LDahilStr := _XMLDegerInline(LLMT,
        '<cbc:TaxInclusiveAmount', '</cbc:TaxInclusiveAmount>');
  end;
  // KDV toplam: root cac:TaxTotal -> ilk cbc:TaxAmount
  LTaxBlok := _XMLTagDeger(LUbl, '<cac:TaxTotal>', '</cac:TaxTotal>');
  if LTaxBlok <> '' then
    LKDVStr := _XMLDegerInline(LTaxBlok,
      '<cbc:TaxAmount', '</cbc:TaxAmount>');

  LMatrah := _ParseUBLSayi(LMatStr);
  LDahil := _ParseUBLSayi(LDahilStr);
  LKDV := _ParseUBLSayi(LKDVStr);
  if (LKDV = 0) and (LDahil > LMatrah) then
    LKDV := LDahil - LMatrah;
  if (LDahil = 0) and (LMatrah > 0) then
    LDahil := LMatrah + LKDV;

  if (LMatrah > 0) or (LDahil > 0) then begin
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE FATBASLIK SET FATURA_MATRAHI=' + CurrToStr(LMatrah, LFmt) +
      ', FATURA_TUTARI=' + CurrToStr(LDahil, LFmt) +
      ', KDV_TUTARI=' + CurrToStr(LKDV, LFmt) +
      ', DOVIZ_TUTARI=' + CurrToStr(LDahil, LFmt) +
      ' WHERE ID=&FID',
      ['&FID'], [AFatBaslikID]);
    Result := True;
  end;
end;

class function TEBelgeGelen.OlusturFatbaslikler(AConnection: TFDConnection;
  out AYeniSayi: Integer; out AHata: string;
  AIlerleme: TIlerlemeOlay; AEArsiv: Boolean): Boolean;
var
  LSel, LSP: TFDQuery;
  LEBelgeID: Int64;
  LAPIJSON, LBelgeNo, LSpJSON, LIssueDate, LSupplier, LSupSSN, LCur: string;
  LAmount: Currency;
  LJV: TJSONValue;
  LObj: TJSONObject;
  LSonucID, LYeniFatbasID, LToplam, LIslenen, i: Integer;
  LSonucMesaj: string;
  LSatirlar: TArray<TGelenSatir>;
  LSatir: TGelenSatir;
  LFmt: TFormatSettings;
  LBelgeTuru, LGelenDurum: Integer;
begin
  Result := False;
  AYeniSayi := 0;
  AHata := '';
  LIslenen := 0;
  LFmt := TFormatSettings.Create;
  LFmt.DecimalSeparator := '.';
  LFmt.ThousandSeparator := #0;
  if AEArsiv then begin
    LBelgeTuru := 150;
    LGelenDurum := -11;
  end else begin
    LBelgeTuru := 151;
    LGelenDurum := -1;
  end;

  LSel := TFDQuery.Create(nil);
  LSP := TFDQuery.Create(nil);
  try
    LSel.Connection := AConnection;
    LSP.Connection := AConnection;

    // Toplam (ilerleme icin)
    LToplam := 0;
    LSP.SQL.Text :=
      'SELECT COUNT(*) FROM EBELGE E WHERE E.YON=2 ' +
      '  AND E.BELGETURU=:BELGETURU ' +
      '  AND NOT EXISTS (SELECT 1 FROM FATBASLIK FB WHERE FB.GNTPID = E.ID)';
    LSP.ParamByName('BELGETURU').AsInteger := LBelgeTuru;
    LSP.Open;
    if not LSP.Eof then LToplam := LSP.Fields[0].AsInteger;
    LSP.Close;

    // FATBASLIK linki olmayan gelen e-belgeler.
    // Acik cursor + UPDATE EBELGE ayni baglantida lock cakismasi yapip timeout veriyor.
    // Cozum: tum satirlari array'e cek, cursor'i kapat, sonra islet.
    LSel.SQL.Text :=
      'SELECT E.ID, E.BELGENO, cast(E.API_JSON as nvarchar(max)) as APIJ, ' +
      '       COALESCE(CAST(DECOMPRESS(E.UBL_XML_ZIP) AS NVARCHAR(MAX)),' +
      '               CAST(E.UBL_XML AS NVARCHAR(MAX))) as UBLXML ' +
      'FROM EBELGE E ' +
      'WHERE E.YON=2 ' +
      '  AND E.BELGETURU=:BELGETURU ' +
      '  AND NOT EXISTS (SELECT 1 FROM FATBASLIK FB WHERE FB.GNTPID = E.ID)';
    LSel.ParamByName('BELGETURU').AsInteger := LBelgeTuru;
    LSel.Open;
    SetLength(LSatirlar, 0);
    while not LSel.Eof do begin
      LSatir.EBelgeID := LSel.FieldByName('ID').AsLargeInt;
      LSatir.BelgeNo := LSel.FieldByName('BELGENO').AsString;
      LSatir.APIJSON := LSel.FieldByName('APIJ').AsString;
      LSatir.UBLXML := LSel.FieldByName('UBLXML').AsString;
      LSatirlar := LSatirlar + [LSatir];
      LSel.Next;
    end;
    LSel.Close;

    LToplam := Length(LSatirlar);

    for i := 0 to High(LSatirlar) do begin
      Inc(LIslenen);
      if Assigned(AIlerleme) then
        AIlerleme(LIslenen, LToplam, 'FATBASLIK olusturuluyor');
      LEBelgeID := LSatirlar[i].EBelgeID;
      LBelgeNo := LSatirlar[i].BelgeNo;
      LAPIJSON := LSatirlar[i].APIJSON;

      // Default'lar
      LIssueDate := FormatDateTime('yyyy-mm-dd', Now);
      LSupplier := '';
      LSupSSN := '';
      LCur := 'TRY';
      LAmount := 0;

      // API_JSON'dan tarih/tutar/durum bilgilerini al
      var LDurumJSON, LSonucJSON: Integer;
      var LStatusEslesmis: Boolean := False;
      LJV := TJSONObject.ParseJSONValue(LAPIJSON);
      if LJV is TJSONObject then begin
        try
          LObj := TJSONObject(LJV);
          LIssueDate := _JSONStr(LObj, 'issueDate');
          if LIssueDate = '' then LIssueDate := FormatDateTime('yyyy-mm-dd', Now);
          LSupplier := _JSONStr(LObj, 'supplierName');
          LSupSSN := _JSONStr(LObj, 'supplierSSN');
          LCur := _JSONStr(LObj, 'currency');
          if SameText(LCur, 'TRY') or (LCur = '') then LCur := 'TL';
          LAmount := _ParseTRSayi(_JSONStr(LObj, 'amount'));
          LStatusEslesmis := _IzibizItemStatusEsle(LObj, LDurumJSON, LSonucJSON);
        finally
          LJV.Free;
        end;
      end;

      // UBL XML'den supplier bilgileri
      var LAdres, LILCE, LIL, LVD, LUBLBaslik, LUBLVNO: string;
      _SupplierBilgiCikar(LSatirlar[i].UBLXML, LAdres, LILCE, LIL, LVD,
                          LUBLBaslik, LUBLVNO);
      // BASLIK oncelik: UBL'den gelen firma unvani (PartyLegalEntity/PartyName) en dogru.
      // supplierName bazen alias (URN/handle gibi "Uyumsoft#yanikibo") donuyor;
      // UBL'de gercek bir unvan varsa onu kullan.
      if Trim(LUBLBaslik) <> '' then
        LSupplier := LUBLBaslik
      else if Trim(LSupplier) = '' then
        LSupplier := LUBLBaslik;
      if Trim(LSupSSN) = '' then LSupSSN := LUBLVNO;

      // e-Arsivde UBL gelmez ve API_JSON'daki supplierName/supplierSSN bos/null
      // olabilir; taraf bilgisi accountingSupplier/accountingCustomer nesnesinden
      // tamamlanir (cikan/OUT belgede karsi taraf musteri, gelen/IN'de saticidir).
      if (Trim(LSupplier) = '') or (Trim(LSupSSN) = '') then begin
        var LJV2: TJSONValue := TJSONObject.ParseJSONValue(LAPIJSON);
        if LJV2 is TJSONObject then
        try
          var LObj2: TJSONObject := TJSONObject(LJV2);
          var LParti: string := 'accountingSupplier';
          if SameText(_NullBosalt(_JSONStr(LObj2, 'direction')), 'OUT') then
            LParti := 'accountingCustomer';
          if Trim(LSupplier) = '' then begin
            LSupplier := _NullBosalt(_JSONChildStr(LObj2, LParti, 'name'));
            if Trim(LSupplier) = '' then
              LSupplier := _NullBosalt(_JSONChildStr(LObj2, LParti, 'person'));
          end;
          if Trim(LSupSSN) = '' then
            LSupSSN := _NullBosalt(_JSONChildStr(LObj2, LParti, 'identifier'));
        finally
          LJV2.Free;
        end;
      end;

      // VKN'ye gore REHBER lookup (REHBERBILGI uzerinden, aktif olanlar)
      var LRehberIDPar: string := '';
      if Trim(LSupSSN) <> '' then begin
        LSP.SQL.Text :=
          'SELECT TOP 1 R.ID FROM REHBER R ' +
          'INNER JOIN REHBERBILGI RB ON RB.YER_ID = R.ID ' +
          ' AND RB.YERI = 2 AND RB.ETIKET = N''Vergi No'' ' +
          'WHERE R.DURUM = 1 ' +
          '  AND REPLACE(RB.BILGI, '' '', '''') = :VKN ORDER BY R.ID';
        LSP.ParamByName('VKN').AsString := StringReplace(LSupSSN, ' ', '', [rfReplaceAll]);
        LSP.Open;
        if not LSP.Eof then
          LRehberIDPar := ',"REHBERID":' + LSP.Fields[0].AsString;
        LSP.Close;
      end;

      // SP JSON'unu insa et
      LSpJSON :=
        '{' +
        '"FATBASLIKID":' + IntToStr(LEBelgeID) + ',' +
        '"FATURATARIHI":"' + LIssueDate + '",' +
        '"FATURANO":"' + _JSONEscape(LBelgeNo) + '",' +
        '"FATURA_MATRAHI":' + CurrToStr(LAmount, LFmt) + ',' +
        '"FATURA_TUTARI":' + CurrToStr(LAmount, LFmt) + ',' +
        '"KDV_TUTARI":0,' +
        '"KUR":"' + LCur + '",' +
        '"DOVIZ_CINSI":"' + LCur + '",' +
        '"DOVIZKUR":1,' +
        '"DOVIZ_TUTARI":' + CurrToStr(LAmount, LFmt) + ',' +
        '"DEPO":"Merkez",' +
        // Gelen faturadan: BASLIK = supplier name, VNO = supplier VKN
        '"BASLIK":"' + _JSONEscape(LSupplier) + '",' +
        '"VNO":"' + _JSONEscape(LSupSSN) + '",' +
        '"VD":"' + _JSONEscape(LVD) + '",' +
        '"ADRES":"' + _JSONEscape(LAdres) + '",' +
        '"ILCE":"' + _JSONEscape(LILCE) + '",' +
        '"IL":"' + _JSONEscape(LIL) + '",' +
        '"ACIKLAMA":"Izibiz inbox: ' + _JSONEscape(LSupplier) + ' VKN:' + _JSONEscape(LSupSSN) + '"' +
        LRehberIDPar +
        '}';

      // SP'yi cagir
      LSonucID := -99;
      LSonucMesaj := '';
      try
        LSP.SQL.Text :=
          'DECLARE @sid INT, @smsg VARCHAR(5000); ' +
          'EXEC sp_Grnt_AlisFaturaIslem @jsonData=:j, @TIP=1, ' +
          '  @SONUC_ID=@sid OUTPUT, @SONUC_MESAJ=@smsg OUTPUT; ' +
          'SELECT @sid AS SID, @smsg AS SMSG';
        LSP.ParamByName('j').AsString := LSpJSON;
        LSP.Open;
        if not LSP.Eof then begin
          LSonucID := LSP.FieldByName('SID').AsInteger;
          LSonucMesaj := LSP.FieldByName('SMSG').AsString;
        end;
        LSP.Close;
      except
        on E: Exception do begin
          AHata := 'SP cagrisi hata (EBELGE.ID=' + IntToStr(LEBelgeID) + '): ' +
                   E.Message;
          Exit;
        end;
      end;

      if LSonucID = 1 then begin
        // SP yeni FATBASLIK olusturdu - GNTP_FATBASID = EBELGE.ID ile bulunur
        LYeniFatbasID := 0;
        LSP.SQL.Text :=
          'SELECT TOP 1 ID FROM FATBASLIK ' +
          'WHERE GNTP_FATBASID = :EID AND TUR = 11 ORDER BY ID DESC';
        LSP.ParamByName('EID').AsLargeInt := LEBelgeID;
        LSP.Open;
        if not LSP.Eof then
          LYeniFatbasID := LSP.Fields[0].AsInteger;
        LSP.Close;

        if LYeniFatbasID > 0 then begin
          // SP zaten SUBEID=-1, GIRISDEPO=1 default'lariyla insert etti.
          // GNTPID linkaji + EFATURADURUM/EFATURASONUC = Izibiz statusCode esleme.
          var LDurumIlk, LSonucIlk: Integer;
          if LStatusEslesmis then begin
            LDurumIlk := LDurumJSON;
            LSonucIlk := LSonucJSON;
          end else begin
            LDurumIlk := LGelenDurum; LSonucIlk := 0;
          end;
          if AEArsiv then
            LDurumIlk := -11;
          Veritabani.BasitKomutÇalıştır(AConnection,
            'UPDATE FATBASLIK SET GNTPID=&EID, EFATURADURUM=&D, EFATURASONUC=&S WHERE ID=&FID',
            ['&EID', '&D', '&S', '&FID'],
            [LEBelgeID, LDurumIlk, LSonucIlk, LYeniFatbasID]);
          // EBELGE -> FATBASLIK back-link
          Veritabani.BasitKomutÇalıştır(AConnection,
            'UPDATE EBELGE SET FATBASLIKID=&FID WHERE ID=&EID',
            ['&FID', '&EID'], [LYeniFatbasID, LEBelgeID]);

          // UBL detay satirlarini FATURA tablosuna ekle.
          // REHBERID FATBASLIK'tan yeniden okunur (SP icinde default 0 =
          // "Tanimsiz Cari").
          var LRehberIDDetay: Integer := 0;
          LSP.SQL.Text := 'SELECT TOP 1 ISNULL(REHBERID,0) FROM FATBASLIK WHERE ID=:F';
          LSP.ParamByName('F').AsInteger := LYeniFatbasID;
          LSP.Open;
          if not LSP.Eof then LRehberIDDetay := LSP.Fields[0].AsInteger;
          LSP.Close;
          _UBLDetaylariEkle(AConnection, LYeniFatbasID, LRehberIDDetay,
                            StrToIntDef(Kullanan, 0), LSatirlar[i].UBLXML);

          // UBL'den gercek toplam degerleri parse edip FATBASLIK'i son kelime
          // olarak UPDATE et (SP_PRG_FaturaDipToplami yanlis sonuc verebiliyor;
          // UBL kaynakli degerler her zaman dogru).
          var LUbl: string := LSatirlar[i].UBLXML;
          if Trim(LUbl) <> '' then begin
            var LLMT, LTaxBlok, LMatStr, LDahilStr, LKDVStr: string;
            var LMatrah, LDahil, LKDV: Currency;
            LLMT := _XMLTagDeger(LUbl,
              '<cac:LegalMonetaryTotal>', '</cac:LegalMonetaryTotal>');
            if LLMT <> '' then begin
              // Matrah: TaxExclusiveAmount (varsa) yoksa LineExtensionAmount
              LMatStr := _XMLDegerInline(LLMT,
                '<cbc:TaxExclusiveAmount', '</cbc:TaxExclusiveAmount>');
              if LMatStr = '' then
                LMatStr := _XMLDegerInline(LLMT,
                  '<cbc:LineExtensionAmount', '</cbc:LineExtensionAmount>');
              // Genel toplam: PayableAmount (varsa) yoksa TaxInclusiveAmount
              LDahilStr := _XMLDegerInline(LLMT,
                '<cbc:PayableAmount', '</cbc:PayableAmount>');
              if LDahilStr = '' then
                LDahilStr := _XMLDegerInline(LLMT,
                  '<cbc:TaxInclusiveAmount', '</cbc:TaxInclusiveAmount>');
            end;
            // KDV toplam: root cac:TaxTotal -> ilk cbc:TaxAmount
            LTaxBlok := _XMLTagDeger(LUbl, '<cac:TaxTotal>', '</cac:TaxTotal>');
            if LTaxBlok <> '' then
              LKDVStr := _XMLDegerInline(LTaxBlok,
                '<cbc:TaxAmount', '</cbc:TaxAmount>');

            LMatrah := _ParseUBLSayi(LMatStr);
            LDahil := _ParseUBLSayi(LDahilStr);
            LKDV := _ParseUBLSayi(LKDVStr);
            // KDV verilmemis ama matrah/dahil farkliysa farktan hesapla
            if (LKDV = 0) and (LDahil > LMatrah) then
              LKDV := LDahil - LMatrah;
            // Dahil bos ise matrah+KDV
            if (LDahil = 0) and (LMatrah > 0) then
              LDahil := LMatrah + LKDV;

            if (LMatrah > 0) or (LDahil > 0) then begin
              // Currency degerlerini LFmt (nokta ondalik) ile elle stringe
              // cevirip SQL'e koy. BasitKomutCalistir variant->string'i
              // Turkce locale ile yapip kurus ayracini bozabiliyor.
              var LMatS := CurrToStr(LMatrah, LFmt);
              var LDahilS := CurrToStr(LDahil, LFmt);
              var LKDVS := CurrToStr(LKDV, LFmt);
              Veritabani.BasitKomutÇalıştır(AConnection,
                'UPDATE FATBASLIK SET FATURA_MATRAHI=' + LMatS +
                ', FATURA_TUTARI=' + LDahilS +
                ', KDV_TUTARI=' + LKDVS +
                ', DOVIZ_TUTARI=' + LDahilS +
                ' WHERE ID=&FID',
                ['&FID'], [LYeniFatbasID]);
            end;

            // Para birimi TRY ise TL olarak normalize et.
            Veritabani.BasitKomutÇalıştır(AConnection,
              'UPDATE FATBASLIK SET DOVIZ_CINSI=N''TL'', KUR=N''TL'' ' +
              'WHERE ID=&FID AND (DOVIZ_CINSI=N''TRY'' OR KUR=N''TRY'')',
              ['&FID'], [LYeniFatbasID]);
          end;

          Inc(AYeniSayi);
        end;
      end;
    end;

    Result := True;
  finally
    LSel.Free;
    LSP.Free;
  end;
end;

end.















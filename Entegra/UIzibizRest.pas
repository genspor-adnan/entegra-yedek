unit UIzibizRest;

// Izibiz REST API istemcisi — Login + SendInvoice.
// Postman koleksiyonundan elde edilen yapi:
//   Base: https://apidev.izibiz.com.tr  (test icin; uretim/uat farkli olabilir)
//   Login : POST /v1/auth/login  body: {"username","password"}  -> {"accessToken"}
//   Send  : POST /v1/einvoices   header: Authorization: Bearer <accessToken>
//
// Login path/exact format varsa opsiyon ekraninda URL'i full path olarak verip
// SendInvoice icin ayri path tanimlayabiliyoruz. Su anda standart pathler kullanildi.

interface

uses
  System.SysUtils, System.Classes, System.JSON;

type
  TIzibizGonderimSonuc = record
    BasariliMI: Boolean;
    HttpKodu: Integer;
    UUID: string;
    Mesaj: string;
    YanitJSON: string;
  end;

  TIzibizRest = class
  public
    /// Basic Auth (user/pass) + body{identifier,name} ile /v1/auth/api-token cagrisi.
    /// Basari: AAccessToken doner.
    class function Login(const ABaseURL, AKullanici, ASifre,
      AIdentifier, AName: string;
      out AAccessToken: string; out AHata: string): Boolean; static;

    /// SendInvoice — Bearer token header'i + JSON body POST'lanir.
    /// AYol genelde '/v1/einvoices'.
    class function SendInvoice(const ABaseURL, AAccessToken, AYol, ABody: string;
      out ASonuc: TIzibizGonderimSonuc): Boolean; static;

    /// Inbox listesi — GET /v1/einvoices/inbox
    /// Postman ornegi (delivered + tarih araligi ile):
    ///   ?dateType=DELIVERY&status=Delivered&startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
    ///   &page=1&pageSize=100&sort=desc&sortProperty=documentNo
    /// Headers: Authorization: Bearer, Client-Type: REST
    ///   AStatus: 'Delivered' (indirilebilir), 'New' (yeni gelen ama henuz teslim alinmamis)
    ///   AStartDate/AEndDate: 0 ise query'ye eklenmez
    class function InboxList(const ABaseURL, AAccessToken, AStatus: string;
      AStartDate, AEndDate: TDate;
      APage, APageSize: Integer; out AYanitJSON: string;
      out AHttpKodu: Integer; out AHata: string): Boolean; static;

    /// Inbox XML indir - POST /v2/einvoices/inbox/download/xml
    /// AUUIDs: indirilecek Izibiz inbox id listesi
    class function InboxDownloadUBL(const ABaseURL, AAccessToken: string;
      const AUUIDs: array of string; out AYanitJSON: string;
      out AHttpKodu: Integer; out AHata: string): Boolean; static;

    /// Gelen ticari e-fatura uygulama yaniti.
    /// AKabul=True -> kabul, False -> red.
    class function InboxResponse(const ABaseURL, AAccessToken, AID,
      AUUID, AAciklama: string; AKabul: Boolean;
      out ASonuc: TIzibizGonderimSonuc): Boolean; static;
  end;

implementation

uses
  System.Net.HttpClient, System.Net.URLClient, System.Net.HttpClientComponent,
  System.NetEncoding;

class function TIzibizRest.Login(const ABaseURL, AKullanici, ASifre,
  AIdentifier, AName: string; out AAccessToken: string; out AHata: string): Boolean;
// /v1/auth/token endpoint'i 401 dondurdu (digerleri 403=Spring generic).
// Bu OAuth2-style token endpoint olmali. 3 varyant dene:
//   1) Form-encoded body (grant_type=password&username=&password=)
//   2) Form-encoded + Basic Auth
//   3) JSON body { username, password }
var
  LClient: THTTPClient;
  LStream: TMemoryStream;
  LYanit: IHTTPResponse;
  LYanitStr, LURL, LBasic: string;
  LBody: string;
  LBytes: TBytes;
  LJSON: TJSONValue;
  LToken, LData: TJSONValue;
  LDenenen: string;
  i: Integer;

  function _UrlEncode(const S: string): string;
  begin
    Result := TNetEncoding.URL.Encode(S);
  end;

  function _TokenAra(AObj: TJSONObject): TJSONValue;
  begin
    Result := AObj.GetValue('accessToken');
    if Result = nil then Result := AObj.GetValue('access_token');
    if Result = nil then Result := AObj.GetValue('token');
    if Result = nil then Result := AObj.GetValue('ACCESS_TOKEN');
  end;

  function _YanitParseEt(const AYanitStr: string): string;
  var
    JV, TV, DV: TJSONValue;
  begin
    Result := '';
    JV := TJSONObject.ParseJSONValue(AYanitStr);
    if (JV = nil) or not (JV is TJSONObject) then begin
      if JV <> nil then JV.Free;
      Exit;
    end;
    try
      TV := _TokenAra(TJSONObject(JV));
      if TV = nil then begin
        DV := TJSONObject(JV).GetValue('data');
        if (DV <> nil) and (DV is TJSONObject) then
          TV := _TokenAra(TJSONObject(DV));
      end;
      if TV <> nil then Result := TV.Value;
    finally
      JV.Free;
    end;
  end;

begin
  Result := False;
  AAccessToken := '';
  AHata := '';
  LDenenen := '';
  LURL := ABaseURL.TrimRight(['/']) + '/v1/auth/token';
  LBasic := TNetEncoding.Base64.Encode(AKullanici + ':' + ASifre);
  LBasic := StringReplace(LBasic, sLineBreak, '', [rfReplaceAll]);

  for i := 1 to 4 do begin
    LClient := THTTPClient.Create;
    LStream := TMemoryStream.Create;
    try
      try
        case i of
          1: begin
            // Form-encoded body, no Basic Auth
            LBody := 'grant_type=password&username=' + _UrlEncode(AKullanici) +
                     '&password=' + _UrlEncode(ASifre);
            LClient.ContentType := 'application/x-www-form-urlencoded';
          end;
          2: begin
            // Form-encoded body + Basic Auth
            LBody := 'grant_type=password&username=' + _UrlEncode(AKullanici) +
                     '&password=' + _UrlEncode(ASifre);
            LClient.ContentType := 'application/x-www-form-urlencoded';
            LClient.CustomHeaders['Authorization'] := 'Basic ' + LBasic;
          end;
          3: begin
            // JSON body, no Basic Auth (zaten denedik ama tekrar)
            LBody := Format('{"username":"%s","password":"%s"}', [AKullanici, ASifre]);
            LClient.ContentType := 'application/json; charset=UTF-8';
          end;
          4: begin
            // JSON body + Basic Auth
            LBody := Format('{"username":"%s","password":"%s"}', [AKullanici, ASifre]);
            LClient.ContentType := 'application/json; charset=UTF-8';
            LClient.CustomHeaders['Authorization'] := 'Basic ' + LBasic;
          end;
        end;
        LBytes := TEncoding.UTF8.GetBytes(LBody);
        LStream.WriteBuffer(LBytes, Length(LBytes));
        LStream.Position := 0;

        LClient.Accept := 'application/json';
        LClient.ConnectionTimeout := 30000;
        LClient.ResponseTimeout := 60000;

        LYanit := LClient.Post(LURL, LStream);
        LYanitStr := LYanit.ContentAsString(TEncoding.UTF8);
        LDenenen := LDenenen + sLineBreak +
                    Format('Variant %d -> HTTP %d : %s',
                           [i, LYanit.StatusCode, Copy(LYanitStr, 1, 150)]);

        if (LYanit.StatusCode >= 200) and (LYanit.StatusCode < 300) then begin
          AAccessToken := _YanitParseEt(LYanitStr);
          if Trim(AAccessToken) <> '' then begin
            Result := True;
            Exit;
          end;
        end;
      except
        on E: Exception do
          LDenenen := LDenenen + sLineBreak +
                      Format('Variant %d istisna: %s', [i, E.Message]);
      end;
    finally
      LStream.Free;
      LClient.Free;
    end;
  end;

  AHata := '/v1/auth/token denemeleri basarisiz:' + LDenenen;
end;

class function TIzibizRest.SendInvoice(const ABaseURL, AAccessToken, AYol,
  ABody: string; out ASonuc: TIzibizGonderimSonuc): Boolean;
var
  LClient: THTTPClient;
  LStream: TMemoryStream;
  LBytes: TBytes;
  LYanit: IHTTPResponse;
  LJSON: TJSONValue;
  LURL: string;
  LObj: TJSONObject;
  LVal: TJSONValue;
begin
  Result := False;
  ASonuc := Default(TIzibizGonderimSonuc);
  LClient := THTTPClient.Create;
  LStream := TMemoryStream.Create;
  try
    try
      LBytes := TEncoding.UTF8.GetBytes(ABody);
      LStream.WriteBuffer(LBytes, Length(LBytes));
      LStream.Position := 0;

      LURL := ABaseURL.TrimRight(['/']) + AYol;
      LClient.ContentType := 'application/json; charset=UTF-8';
      LClient.Accept := 'application/json';
      LClient.CustomHeaders['Authorization'] := 'Bearer ' + AAccessToken;
      LClient.ConnectionTimeout := 30000;
      LClient.ResponseTimeout := 120000;

      LYanit := LClient.Post(LURL, LStream);
      ASonuc.HttpKodu := LYanit.StatusCode;
      ASonuc.YanitJSON := LYanit.ContentAsString(TEncoding.UTF8);

      if (LYanit.StatusCode >= 200) and (LYanit.StatusCode < 300) then begin
        ASonuc.BasariliMI := True;
        LJSON := TJSONObject.ParseJSONValue(ASonuc.YanitJSON);
        if (LJSON <> nil) and (LJSON is TJSONObject) then try
          LObj := TJSONObject(LJSON);
          LVal := LObj.GetValue('uuid');
          if LVal = nil then LVal := LObj.GetValue('UUID');
          if LVal = nil then LVal := LObj.GetValue('documentUUID');
          if LVal = nil then LVal := LObj.GetValue('id');
          if LVal <> nil then ASonuc.UUID := LVal.Value;
          LVal := LObj.GetValue('message');
          if LVal = nil then LVal := LObj.GetValue('description');
          if LVal <> nil then ASonuc.Mesaj := LVal.Value
          else ASonuc.Mesaj := 'Gonderim basarili';
        finally LJSON.Free; end;
        Result := True;
      end else
        ASonuc.Mesaj := Format('HTTP %d: %s', [LYanit.StatusCode, ASonuc.YanitJSON]);
    except
      on E: Exception do begin
        ASonuc.Mesaj := 'SendInvoice istisnasi: ' + E.Message;
        ASonuc.BasariliMI := False;
      end;
    end;
  finally
    LStream.Free;
    LClient.Free;
  end;
end;

class function TIzibizRest.InboxList(const ABaseURL, AAccessToken, AStatus: string;
  AStartDate, AEndDate: TDate;
  APage, APageSize: Integer; out AYanitJSON: string;
  out AHttpKodu: Integer; out AHata: string): Boolean;
var
  LClient: THTTPClient;
  LYanit: IHTTPResponse;
  LURL: string;
begin
  Result := False;
  AYanitJSON := '';
  AHttpKodu := 0;
  AHata := '';
  LClient := THTTPClient.Create;
  try
    try
      // dateType=DOCUMENT -> belge (issue) tarihine gore filtre.
      // Gecerli degerler: DOCUMENT, DELIVERY (Izibiz enum).
      LURL := ABaseURL.TrimRight(['/']) + '/v1/einvoices/inbox' +
        '?dateType=DOCUMENT';
      if Trim(AStatus) <> '' then
        LURL := LURL + '&status=' + AStatus;
      if AStartDate > 0 then
        LURL := LURL + '&startDate=' + FormatDateTime('yyyy-mm-dd', AStartDate);
      if AEndDate > 0 then
        LURL := LURL + '&endDate=' + FormatDateTime('yyyy-mm-dd', AEndDate);
      LURL := LURL +
        '&page=' + IntToStr(APage) +
        '&pageSize=' + IntToStr(APageSize) +
        '&sort=desc' +
        '&sortProperty=documentNo';
      LClient.Accept := 'application/json';
      LClient.CustomHeaders['Authorization'] := 'Bearer ' + AAccessToken;
      LClient.CustomHeaders['Client-Type'] := 'REST';
      LClient.ConnectionTimeout := 30000;
      LClient.ResponseTimeout := 120000;

      LYanit := LClient.Get(LURL);
      AHttpKodu := LYanit.StatusCode;
      AYanitJSON := LYanit.ContentAsString(TEncoding.UTF8);
      if (LYanit.StatusCode >= 200) and (LYanit.StatusCode < 300) then
        Result := True
      else
        AHata := Format('HTTP %d: %s', [LYanit.StatusCode, AYanitJSON]);
    except
      on E: Exception do
        AHata := 'InboxList istisnasi: ' + E.Message;
    end;
  finally
    LClient.Free;
  end;
end;

class function TIzibizRest.InboxDownloadUBL(const ABaseURL, AAccessToken: string;
  const AUUIDs: array of string; out AYanitJSON: string;
  out AHttpKodu: Integer; out AHata: string): Boolean;
const
  LPostPaths: array[0..3] of string = (
    '/v1/einvoices/inbox/download/ubl',
    '/v2/einvoices/inbox/download',
    '/v2/einvoices/inbox/download/ubl',
    '/v2/einvoices/inbox/download/xml'
  );
  LGetPathFormats: array[0..5] of string = (
    '/v1/einvoices/inbox/%s/xml',
    '/v1/einvoices/inbox/%s/ubl',
    '/v2/einvoices/inbox/%s/xml',
    '/v2/einvoices/inbox/%s/ubl',
    '/v1/einvoices/%s/xml',
    '/v2/einvoices/%s/xml'
  );
var
  LClient: THTTPClient;
  LStream: TMemoryStream;
  LBytes: TBytes;
  LYanit: IHTTPResponse;
  LURL, LBody, LDenemeler: string;
  i, p: Integer;
  LArr: TJSONArray;
  LObj: TJSONObject;
begin
  Result := False;
  AYanitJSON := '';
  AHttpKodu := 0;
  AHata := '';
  if Length(AUUIDs) = 0 then begin
    AHata := 'InboxDownloadUBL: id listesi bos.';
    Exit;
  end;

  LArr := TJSONArray.Create;
  try
    for i := 0 to High(AUUIDs) do begin
      LObj := TJSONObject.Create;
      LObj.AddPair('id', AUUIDs[i]);
      LObj.AddPair('contentType', 'XML');
      LObj.AddPair('exportType', 'SINGLE');
      LArr.AddElement(LObj);
    end;
    LBody := LArr.ToJSON;
  finally
    LArr.Free;
  end;

  LClient := THTTPClient.Create;
  LStream := TMemoryStream.Create;
  try
    try
      LClient.ContentType := 'application/json; charset=UTF-8';
      LClient.Accept := 'application/json';
      LClient.CustomHeaders['Authorization'] := 'Bearer ' + AAccessToken;
      LClient.CustomHeaders['Client-Type'] := 'REST';
      LClient.ConnectionTimeout := 30000;
      LClient.ResponseTimeout := 120000;

      for p := Low(LPostPaths) to High(LPostPaths) do begin
        LBytes := TEncoding.UTF8.GetBytes(LBody);
        LStream.Size := 0;
        LStream.WriteBuffer(LBytes, Length(LBytes));
        LStream.Position := 0;

        LURL := ABaseURL.TrimRight(['/']) + LPostPaths[p];
        LYanit := LClient.Post(LURL, LStream);
        AHttpKodu := LYanit.StatusCode;
        AYanitJSON := LYanit.ContentAsString(TEncoding.UTF8);
        if (LYanit.StatusCode >= 200) and (LYanit.StatusCode < 300) then begin
          Result := True;
          Exit;
        end;

        if LDenemeler <> '' then LDenemeler := LDenemeler + sLineBreak;
        LDenemeler := LDenemeler + 'POST ' + LPostPaths[p] + ' -> ' +
          Format('HTTP %d: %s', [LYanit.StatusCode, AYanitJSON]);
      end;

      for p := Low(LGetPathFormats) to High(LGetPathFormats) do begin
        for i := 0 to High(AUUIDs) do begin
          LURL := ABaseURL.TrimRight(['/']) + Format(LGetPathFormats[p], [AUUIDs[i]]);
          LYanit := LClient.Get(LURL);
          AHttpKodu := LYanit.StatusCode;
          AYanitJSON := LYanit.ContentAsString(TEncoding.UTF8);
          if (LYanit.StatusCode >= 200) and (LYanit.StatusCode < 300) then begin
            Result := True;
            Exit;
          end;

          if LDenemeler <> '' then LDenemeler := LDenemeler + sLineBreak;
          LDenemeler := LDenemeler + 'GET ' + Format(LGetPathFormats[p], [AUUIDs[i]]) + ' -> ' +
            Format('HTTP %d: %s', [LYanit.StatusCode, AYanitJSON]);
        end;
      end;
      AHata := LDenemeler;
    except
      on E: Exception do
        AHata := 'InboxDownloadUBL istisnasi: ' + E.Message;
    end;
  finally
    LStream.Free;
    LClient.Free;
  end;
end;

class function TIzibizRest.InboxResponse(const ABaseURL, AAccessToken, AID,
  AUUID, AAciklama: string; AKabul: Boolean;
  out ASonuc: TIzibizGonderimSonuc): Boolean;
const
  LAcceptPaths: array[0..7] of string = (
    '/v2/einvoices/inbox/accept',
    '/v1/einvoices/inbox/accept',
    '/v2/einvoices/inbox/approve',
    '/v1/einvoices/inbox/approve',
    '/v2/einvoices/inbox/response',
    '/v1/einvoices/inbox/response',
    '/v2/einvoices/inbox/application-response',
    '/v1/einvoices/inbox/application-response'
  );
  LRejectPaths: array[0..7] of string = (
    '/v2/einvoices/inbox/reject',
    '/v1/einvoices/inbox/reject',
    '/v2/einvoices/inbox/decline',
    '/v1/einvoices/inbox/decline',
    '/v2/einvoices/inbox/response',
    '/v1/einvoices/inbox/response',
    '/v2/einvoices/inbox/application-response',
    '/v1/einvoices/inbox/application-response'
  );
var
  LClient: THTTPClient;
  LStream: TMemoryStream;
  LBytes: TBytes;
  LYanit: IHTTPResponse;
  LURL, LBody, LDenemeler, LAction, LStatus: string;
  p, b: Integer;

  function _JSONEscape(const S: string): string;
  begin
    Result := S;
    Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
    Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
    Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
    Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  end;

  function _BodyOlustur(AIndex: Integer): string;
  var
    LIDParca, LUUIDParca, LAciklama: string;
  begin
    LIDParca := '"id":"' + _JSONEscape(AID) + '"';
    LUUIDParca := '';
    if Trim(AUUID) <> '' then
      LUUIDParca := ',"uuid":"' + _JSONEscape(AUUID) + '"';
    LAciklama := _JSONEscape(AAciklama);

    case AIndex of
      0:
        Result := '[{' + LIDParca + LUUIDParca + ',"response":"' + LStatus +
          '","description":"' + LAciklama + '"}]';
      1:
        Result := '{' + LIDParca + LUUIDParca + ',"response":"' + LStatus +
          '","description":"' + LAciklama + '"}';
      2:
        Result := '{"documents":[{' + LIDParca + LUUIDParca + '}],"responseType":"' +
          LAction + '","description":"' + LAciklama + '"}';
    else
      Result := '{"items":[{' + LIDParca + LUUIDParca + '}],"status":"' +
        LStatus + '","note":"' + LAciklama + '"}';
    end;
  end;

  function _Path(AIndex: Integer): string;
  begin
    if AKabul then
      Result := LAcceptPaths[AIndex]
    else
      Result := LRejectPaths[AIndex];
  end;

begin
  Result := False;
  ASonuc := Default(TIzibizGonderimSonuc);
  if Trim(AID) = '' then begin
    ASonuc.Mesaj := 'InboxResponse: Izibiz belge id bilgisi bos.';
    Exit;
  end;

  if AKabul then begin
    LAction := 'ACCEPT';
    LStatus := 'ACCEPTED';
  end else begin
    LAction := 'REJECT';
    LStatus := 'REJECTED';
  end;

  LClient := THTTPClient.Create;
  LStream := TMemoryStream.Create;
  try
    try
      LClient.ContentType := 'application/json; charset=UTF-8';
      LClient.Accept := 'application/json';
      LClient.CustomHeaders['Authorization'] := 'Bearer ' + AAccessToken;
      LClient.CustomHeaders['Client-Type'] := 'REST';
      LClient.ConnectionTimeout := 30000;
      LClient.ResponseTimeout := 120000;

      for p := Low(LAcceptPaths) to High(LAcceptPaths) do begin
        for b := 0 to 3 do begin
          LBody := _BodyOlustur(b);
          LBytes := TEncoding.UTF8.GetBytes(LBody);
          LStream.Size := 0;
          LStream.WriteBuffer(LBytes, Length(LBytes));
          LStream.Position := 0;

          LURL := ABaseURL.TrimRight(['/']) + _Path(p);
          LYanit := LClient.Post(LURL, LStream);
          ASonuc.HttpKodu := LYanit.StatusCode;
          ASonuc.YanitJSON := LYanit.ContentAsString(TEncoding.UTF8);
          if (LYanit.StatusCode >= 200) and (LYanit.StatusCode < 300) then begin
            ASonuc.BasariliMI := True;
            if AKabul then
              ASonuc.Mesaj := 'Kabul yaniti gonderildi.'
            else
              ASonuc.Mesaj := 'Red yaniti gonderildi.';
            ASonuc.UUID := AUUID;
            Result := True;
            Exit;
          end;

          if LDenemeler <> '' then LDenemeler := LDenemeler + sLineBreak;
          LDenemeler := LDenemeler + 'POST ' + _Path(p) +
            Format(' body%d -> HTTP %d: %s',
              [b, LYanit.StatusCode, Copy(ASONuc.YanitJSON, 1, 500)]);
        end;
      end;
      ASonuc.Mesaj := LDenemeler;
    except
      on E: Exception do
        ASonuc.Mesaj := 'InboxResponse istisnasi: ' + E.Message;
    end;
  finally
    LStream.Free;
    LClient.Free;
  end;
end;

end.


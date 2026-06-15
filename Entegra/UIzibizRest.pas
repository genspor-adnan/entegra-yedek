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

end.

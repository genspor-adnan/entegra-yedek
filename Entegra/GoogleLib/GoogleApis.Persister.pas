unit GoogleApis.Persister;

interface

uses
  System.Classes, System.SysUtils, System.DateUtils,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdIOHandler, IdURI,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdGlobal,
  Lib.JsonSerializer,
  Lib.JWT,
  Lib.Bson,
  Lib.OpenSSL,
  GoogleApis;

const
  GOOGLE_API_TOKEN_URL = 'https://oauth2.googleapis.com/token';
  HTTP_CONNECT_TIMEOUT = 5000; //5sn
  HTTP_READ_TIMEOUT = 5000; //5 sn

type
  TGoogleServiceAccountCredential = class(TCredential)
  private
    FAccessToken: String;
    FLastToken: TDateTime;
    FTokenExpiresInSec: Int64;
  private
    FOAuthScope: String;
    FServiceAccount: String;
    FPrivateKey: String;
    FP12FileName: string;
    FP12CertData: TBytes;

    function ClaimSet(const AScope: String; const ADateTime: TDateTime): String;
    procedure SetOAuthScope(const AValue: String);
    procedure SetPrivateKey(const AValue: String);
    procedure SetP12FileName(const AValue: string);
    procedure SetP12CertData(const AValue: TBytes);
    procedure SetServiceAccount(const AValue: String);
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetAccessToken: string; override;
    procedure Abort; override;
  public
    property AccessToken: string read GetAccessToken;
    property OAuthScope: string read FOAuthScope write SetOAuthScope;
    property ServiceAccount: string read FServiceAccount write SetServiceAccount;
    property PrivateKey: string read FPrivateKey write SetPrivateKey;
    property P12CertData: TBytes read FP12CertData write SetP12CertData;
    property P12FileName: string read FP12FileName write SetP12FileName;
  end;

  TGoogleApisHttpClient = class(THttpClient)
  strict private
    FHttp: TIdCustomHTTP;

    function GetRequestUri(const AUri: string; AParameters: THttpRequestParameterList): string;
    procedure CheckResponse(const AJsonResponse: string);
  strict protected
    function GetStatusCode: Integer; override;
  public
    constructor Create(AInitializer: TServiceInitializer);
    destructor Destroy; override;

    function Get(const AUri: string; AParameters: THttpRequestParameterList): string; override;
    function Post(const AUri: string; AParameters: THttpRequestParameterList; const AJsonRequest: string): string; override;
    function Put(const AUri: string; AParameters: THttpRequestParameterList; const AJsonRequest: string): string; override;
    function Patch(const AUri: string; AParameters: THttpRequestParameterList; AJsonRequest: string): string; override;
    function Delete(const AUri: string): string; override;
    procedure Abort; override;
  end;

  TGoogleApisJsonSerializer = class(TJsonSerializer)
  strict private
    FSerializer: Lib.JsonSerializer.TJsonSerializer;
  public
    constructor Create;
    destructor Destroy; override;

    function JsonToException(const AJson: string): EGoogleApisException; override;
    function ExceptionToJson(E: EGoogleApisException): string; override;

    function JsonToObject(AType: TClass; const AJson: string): TObject; override;
    function ObjectToJson(AObject: TObject): string; override;
  end;

  TGoogleApisServiceInitializer = class(TServiceInitializer)
  strict private
    FHttpClient: THttpClient;
    FJsonSerializer: TJsonSerializer;
  strict protected
    function GetHttpClient: THttpClient; override;
    function GetJsonSerializer: TJsonSerializer; override;
  public
    constructor Create(ACredential: TCredential; const ApplicationName: string);
    destructor Destroy; override;
  end;

implementation

uses
  {$IF CompilerVersion >= 28.0}
  System.NetEncoding,
  {$ELSE}
  Web.HTTPApp,
  {$ENDIF}
  System.SysConst;

{$IF CompilerVersion < 28.0}
type
  TIdCustomHTTPAccess= class(TIdCustomHTTP);
{$ENDIF}

{ TGoogleServiceAccountCredential }

procedure TGoogleServiceAccountCredential.Abort;
begin
 ; //Nothing to do
end;

function TGoogleServiceAccountCredential.ClaimSet(const AScope: String;
  const ADateTime: TDateTime): String;
var
  Doc: TBsonDocument;
begin
  Doc := TBsonDocument.Create;
  Doc['iss'] := FServiceAccount;
  Doc['scope'] := AScope;
  Doc['aud'] := GOOGLE_API_TOKEN_URL;
  Doc['exp'] := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(IncSecond(ADateTime, 3600))); { expires in one hour }
  Doc['iat'] := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(ADateTime));
  Result := Doc.ToJson;
end;

constructor TGoogleServiceAccountCredential.Create;
begin
  FLastToken := -1;
  FTokenExpiresInSec := 0;
end;

destructor TGoogleServiceAccountCredential.Destroy;
begin
  inherited;
end;

function TGoogleServiceAccountCredential.GetAccessToken: string;
var
  Http: TIdHTTP;
  SSL_Handler: TIdSSLIOHandlerSocketOpenSSL;
  Response: string;
  ContextStr: string;
  PostData: TStringStream;
  Doc: TBsonDocument;
  JWT: String;
begin
  if (FLastToken = -1) or (Now >= IncSecond(FLastToken, FTokenExpiresInSec - 5)) then { padding of 5 seconds }
  begin
    { new token }
    FLastToken := Now;
    FAccessToken := '';
    if JavaWebToken(BytesOf(FPrivateKey), JWT_RS256,  ClaimSet(FOAuthScope, FLastToken), JWT) then
    begin
      Http := TIdHTTP.Create;
      try
        SSL_Handler:= TIdSSLIOHandlerSocketOpenSSL.Create(Http);
        Http.IOHandler := SSL_Handler;
        Http.ReadTimeout := HTTP_READ_TIMEOUT;
        Http.ConnectTimeout := HTTP_CONNECT_TIMEOUT;
        Http.Request.ContentType := 'application/x-www-form-urlencoded';

        {$IF CompilerVersion >= 28.0}
        ContextStr :=
          'grant_type=' + TNetEncoding.URL.Encode('urn:ietf:params:oauth:grant-type:jwt-bearer') + '&' +
          'assertion=' + TNetEncoding.URL.Encode(JWT);
        {$ELSE}
        ContextStr :=
          'grant_type=' + string(HTTPEncode(Ansistring('urn:ietf:params:oauth:grant-type:jwt-bearer'))) + '&' +
          'assertion=' + string(HTTPEncode(AnsiString(JWT)));
        {$ENDIF}

        PostData := TStringStream.Create(ContextStr);
        try
          Response := Http.Post(GOOGLE_API_TOKEN_URL,PostData);
        finally
          PostData.Free;
        end;
        if Http.Response.ResponseCode = 200 then
        begin
          Doc := TBsonDocument.Parse(Response);
          FTokenExpiresInSec := Doc['expires_in'];
          FAccessToken := Doc['access_token'];
        end;
      finally
        Http.Free;
      end;
    end;
  end;
  Result := FAccessToken;
end;


procedure TGoogleServiceAccountCredential.SetOAuthScope(
  const AValue: String);
begin
  FOAuthScope := AValue;
  FLastToken := -1; { create new access token on next request }
end;


procedure TGoogleServiceAccountCredential.SetP12CertData(const AValue: TBytes);
var
  pk: TBytes;
begin
  if TSSLHelper.ExtractPEMPrivateKey_FromPKCS12(AValue, pk) then
    SetPrivateKey(StringOf(pk))
  else
    raise Exception.Create('Private key cannot extract from p12/pfx data');

  FP12CertData := AValue;
end;

procedure TGoogleServiceAccountCredential.SetP12FileName(
  const AValue: string);
var
  fs: TFileStream;
  p12: TBytes;
begin
  if FileExists(AValue) then begin
    FP12FileName := AValue;

    fs:= TFileStream.Create(FP12FileName,fmOpenRead);
    try
      SetLength(p12, fs.Size);
      fs.ReadBuffer(Pointer(p12)^, Length(p12));
    finally
      fs.Free;
    end;

    SetP12CertData(p12);
  end else
    raise EFileNotFoundException.Create(SFileNotFound);
end;

procedure TGoogleServiceAccountCredential.SetPrivateKey(
  const AValue: String);
begin
  FPrivateKey := AValue;
  FLastToken := -1; { create new access token on next request }
end;


procedure TGoogleServiceAccountCredential.SetServiceAccount(
  const AValue: String);
begin
  FServiceAccount := AValue;
  FLastToken := -1; { create new access token on next request }
end;

{ TGoogleApisHttpClient }

procedure TGoogleApisHttpClient.Abort;
begin
  FHttp.Disconnect;
end;

procedure TGoogleApisHttpClient.CheckResponse(const AJsonResponse: string);
begin
  if (FHttp.ResponseCode >= 300) then
  begin
    if (FHttp.Response.ContentType.ToLower().IndexOf('json') > -1) then
    begin
      raise Initializer.JsonSerializer.JsonToException(AJsonResponse);
    end;
  end;
end;

constructor TGoogleApisHttpClient.Create(AInitializer: TServiceInitializer);
var
  SSL_Handler: TIdSSLIOHandlerSocketOpenSSL;
begin
  inherited Create(AInitializer);

  FHttp := TIdCustomHTTP.Create(nil);
  FHttp.Request.UserAgent := Initializer.ApplicationName;
  SSL_Handler:= TIdSSLIOHandlerSocketOpenSSL.Create(FHttp);
  FHttp.IOHandler := SSL_Handler;
  FHttp.ReadTimeout := HTTP_READ_TIMEOUT;
  FHttp.ConnectTimeout := HTTP_CONNECT_TIMEOUT;

  {When hoNoProtocolErrorException is enabled and an HTTP error occurs, if hoWantProtocolErrorContent is
   enabled then the error content will be returned to the caller (either in a String return value or
   in an AResponseContent output stream, depending on which version of Get()/Post() is being called),
   otherwise the content will be discarded.}
  //FHttp.HTTPOptions := FHttp.HTTPOptions + [hoNoProtocolErrorException,hoWantProtocolErrorContent];
end;

function TGoogleApisHttpClient.Delete(const AUri: string): string;
var
  resp: TStringStream;
begin
  resp := TStringStream.Create('', TEncoding.UTF8, False);
  try
    FHttp.Request.CustomHeaders.Values['Authorization']:= 'Bearer ' + Initializer.Credential.GetAccessToken();
    {$IF CompilerVersion >= 28.0}
    FHttp.Delete(AUri, resp);
    {$ELSE}
    TIdCustomHTTPAccess(FHttp).DoRequest(Id_HTTPMethodDelete, AUri, nil, resp, []);
    {$ENDIF}
    CheckResponse(resp.DataString);
    Result := resp.DataString;
  finally
    resp.Free();
  end;
end;

destructor TGoogleApisHttpClient.Destroy;
begin
  FHttp.Free();
  inherited Destroy();
end;

function TGoogleApisHttpClient.Get(const AUri: string; AParameters: THttpRequestParameterList): string;
var
  resp: TStringStream;
begin
  resp := TStringStream.Create('', TEncoding.UTF8, False);
  try
    FHttp.Request.CustomHeaders.Values['Authorization']:= 'Bearer ' + Initializer.Credential.GetAccessToken();
    FHttp.Get(GetRequestUri(AUri, AParameters), resp);
    CheckResponse(resp.DataString);
    Result := resp.DataString;
  finally
    resp.Free();
  end;
end;

function TGoogleApisHttpClient.GetRequestUri(const AUri: string; AParameters: THttpRequestParameterList): string;
begin
  with TIdURI.Create(AUri) do
  try
    Params := ParamsEncode(AParameters.GetRawRequestUri);
    Result := URI;
  finally
    Free;
  end;
end;

function TGoogleApisHttpClient.GetStatusCode: Integer;
begin
  Result := FHttp.ResponseCode;
end;

function TGoogleApisHttpClient.Patch(const AUri: string; AParameters: THttpRequestParameterList; AJsonRequest: string): string;
var
  req,resp: TStringStream;
begin
  req := TStringStream.Create(AJsonRequest, TEncoding.UTF8);
  resp := TStringStream.Create('', TEncoding.UTF8, False);
  try
    FHttp.Request.CustomHeaders.Values['Authorization']:= 'Bearer ' + Initializer.Credential.GetAccessToken();
    {$IF CompilerVersion >= 28.0}
    FHttp.Patch(GetRequestUri(AUri, AParameters), req, resp);
    {$ELSE}
    TIdCustomHTTPAccess(FHttp).DoRequest(Id_HTTPMethodDelete, AUri, req, resp, []);
    {$ENDIF}
    CheckResponse(resp.DataString);
    Result := resp.DataString;
  finally
    resp.Free();
    req.Free();
  end;
end;

function TGoogleApisHttpClient.Post(const AUri: string; AParameters: THttpRequestParameterList; const AJsonRequest: string): string;
var
  req,resp: TStringStream;
begin
  req := TStringStream.Create(AJsonRequest, TEncoding.UTF8);
  resp := TStringStream.Create('', TEncoding.UTF8, false);
  try
    FHttp.Request.CustomHeaders.Values['Authorization']:= 'Bearer ' + Initializer.Credential.GetAccessToken();
    FHttp.Post(GetRequestUri(AUri, AParameters), req, resp);
    CheckResponse(resp.DataString);
    Result := resp.DataString;
  finally
    resp.Free();
    req.Free();
  end;
end;

function TGoogleApisHttpClient.Put(const AUri: string; AParameters: THttpRequestParameterList; const AJsonRequest: string): string;
var
  req,resp: TStringStream;
begin
  req := TStringStream.Create(AJsonRequest, TEncoding.UTF8);
  resp := TStringStream.Create('', TEncoding.UTF8, False);
  try
    FHttp.Request.CustomHeaders.Values['Authorization']:= 'Bearer ' + Initializer.Credential.GetAccessToken();
    FHttp.Put(GetRequestUri(AUri, AParameters), req, resp);
    CheckResponse(resp.DataString);
    Result := resp.DataString;
  finally
    resp.Free();
    req.Free();
  end;
end;

{ TGoogleApisServiceInitializer }

constructor TGoogleApisServiceInitializer.Create(ACredential: TCredential; const ApplicationName: string);
begin
  inherited Create(ACredential, ApplicationName);

  FHttpClient := nil;
  FJsonSerializer := nil;
end;

destructor TGoogleApisServiceInitializer.Destroy;
begin
  FHttpClient.Free();
  FJsonSerializer.Free();

  inherited Destroy();
end;

function TGoogleApisServiceInitializer.GetHttpClient: THttpClient;
begin
  if (FHttpClient = nil) then
  begin
    FHttpClient := TGoogleApisHttpClient.Create(Self);
  end;
  Result := FHttpClient;
end;

function TGoogleApisServiceInitializer.GetJsonSerializer: TJsonSerializer;
begin
  if (FJsonSerializer = nil) then
  begin
    FJsonSerializer := TGoogleApisJsonSerializer.Create();
  end;
  Result := FJsonSerializer;
end;

{ TGoogleApisJsonSerializer }

constructor TGoogleApisJsonSerializer.Create;
begin
  inherited Create();
  FSerializer := Lib.JsonSerializer.TJsonSerializer.Create();
end;

destructor TGoogleApisJsonSerializer.Destroy;
begin
  FSerializer.Free();
  inherited Destroy();
end;

function TGoogleApisJsonSerializer.ExceptionToJson(E: EGoogleApisException): string;
begin
  Result := FSerializer.ObjectToJson(E);
end;

function TGoogleApisJsonSerializer.JsonToException(const AJson: string): EGoogleApisException;
begin
  Result := EGoogleApisException.Create();
  try
    Result := FSerializer.JsonToObject(Result, AJson) as EGoogleApisException;
  except
    Result.Free();
    raise;
  end;
end;

function TGoogleApisJsonSerializer.JsonToObject(AType: TClass; const AJson: string): TObject;
begin
  Result := FSerializer.JsonToObject(AType, AJson);
end;

function TGoogleApisJsonSerializer.ObjectToJson(AObject: TObject): string;
begin
  Result := FSerializer.ObjectToJson(AObject);
end;

end.



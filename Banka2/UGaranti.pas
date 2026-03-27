unit UGaranti;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, 
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxButtons,
  IdCustomHTTPServer, IdHTTPServer, IdContext,
  System.JSON, IdCoderMIME, System.Net.URLClient, System.Net.HttpClient, 
  System.Net.HttpClientComponent, IniFiles, dxSkinsCore, dxSkinBasic,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinOffice2019Black,
  dxSkinOffice2019Colorful, dxSkinOffice2019DarkGray, dxSkinOffice2019White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxSkinWXI,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus,
  Winapi.ShellAPI, System.IOUtils, Vcl.ExtCtrls;

type
  EGarantiAPIError = class(Exception);

type
  TForm1 = class(TForm)
    memoSonuc: TMemo;
    Panel1: TPanel;
    btnBaglan: TcxButton;
    procedure btnBaglanClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FHttpClient: TNetHTTPClient;
    FHTTPServer: TIdHTTPServer;
    FConfig: TIniFile;
    
    function GetAccessToken: string;
    function ReadConfig: Boolean;
    function CreateTransactionRequest: string;
    procedure InitializeHttpClient;
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function LoadFileToString(const FileName: string): string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FHTTPServer);
  FreeAndNil(FHttpClient);
  FreeAndNil(FConfig);
end;

procedure TForm1.InitializeHttpClient;
begin
  if FHttpClient = nil then
    FHttpClient := TNetHTTPClient.Create(nil);
  
  FHttpClient.ConnectionTimeout := 30000;
  FHttpClient.ResponseTimeout := 30000;
end;

function TForm1.GetAccessToken: string;
var
  Params: TStringStream;
  Response: TStringStream;
  JSONResponse: TJSONObject;
  RawResponse: string;
  ClientID, ClientSecret: string;
begin
  InitializeHttpClient;
  
  ClientID := FConfig.ReadString('GarantiAPI', 'ClientID', '');
  ClientSecret := FConfig.ReadString('GarantiAPI', 'ClientSecret', '');
  
  Params := TStringStream.Create(
    Format('grant_type=client_credentials&client_id=%s&client_secret=%s', 
    [ClientID, ClientSecret]), TEncoding.UTF8);
  Response := TStringStream.Create;
  try
    FHttpClient.ContentType := 'application/x-www-form-urlencoded';
    FHttpClient.Post(FConfig.ReadString('GarantiAPI', 'TokenEndpoint', ''), 
      Params, Response);

    RawResponse := Response.DataString;
    memoSonuc.Lines.Add('Response received:' + sLineBreak + RawResponse);

    JSONResponse := TJSONObject.ParseJSONValue(RawResponse) as TJSONObject;
    if not Assigned(JSONResponse) then
      raise EGarantiAPIError.Create('Response could not be parsed!');

    if JSONResponse.GetValue('access_token') = nil then
      raise EGarantiAPIError.Create('Access token not found. Error: ' + 
        JSONResponse.ToJSON);

    Result := JSONResponse.GetValue<string>('access_token');
    memoSonuc.Lines.Add('Access Token: ' + Result);  // Token'ı memo'ya ekle
    JSONResponse.Free;
  finally
    Params.Free;
    Response.Free;
  end;
end;

procedure TForm1.btnBaglanClick(Sender: TObject);
begin
  try
    if not ReadConfig then
      raise EGarantiAPIError.Create('Configuration file not found or invalid');

    // Start callback server
    FHTTPServer := TIdHTTPServer.Create(nil);
    try
      FHTTPServer.DefaultPort := FConfig.ReadInteger('GarantiAPI', 'Port', 8080);
      FHTTPServer.OnCommandGet := IdHTTPServer1CommandGet;
      FHTTPServer.Active := True;
      memoSonuc.Lines.Add(Format('Callback server started: %s', 
        [FConfig.ReadString('GarantiAPI', 'CallbackURL', '')]));

      // Get configuration values
      var ClientID := FConfig.ReadString('GarantiAPI', 'ClientID', '');
      var ClientSecret := FConfig.ReadString('GarantiAPI', 'ClientSecret', '');
      var RedirectURI := FConfig.ReadString('GarantiAPI', 'RedirectURI', '');
      
      // Log configuration
      memoSonuc.Lines.Add('Client ID: ' + ClientID);
      memoSonuc.Lines.Add('Client Secret: ' + StringOfChar('*', Length(ClientSecret)));
      memoSonuc.Lines.Add('Redirect URI: ' + RedirectURI);

      // Open browser with authorization URL
      var AuthURL := Format('https://apis.garantibbva.com.tr/auth/oauth/v2/authorize?response_type=token&client_id=%s&redirect_uri=%s&scope=account_read',
        [ClientID, RedirectURI]);
      
      // Log the authorization URL
      memoSonuc.Lines.Add('Authorization URL: ' + AuthURL);
      
      // Open browser
      var BrowserResult := ShellExecute(0, 'open', PChar(AuthURL), nil, nil, SW_SHOWNORMAL);
      if BrowserResult <= 32 then
      begin
        memoSonuc.Lines.Add('Error opening browser with authorization URL. Error code: ' + IntToStr(BrowserResult));
        memoSonuc.Lines.Add('Please try to open this URL manually in your browser:');
        memoSonuc.Lines.Add(AuthURL);
      end
      else
        memoSonuc.Lines.Add('Browser opened successfully');
    except
      on E: Exception do
        memoSonuc.Lines.Add('Error starting callback server: ' + E.Message);
    end;
  except
    on E: Exception do
      memoSonuc.Lines.Add('Unexpected Error: ' + E.Message);
  end;
end;

function TForm1.LoadFileToString(const FileName: string): string;
var
  FileStream: TFileStream;
  StreamReader: TStreamReader;
begin
  Result := '';
  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      StreamReader := TStreamReader.Create(FileStream, TEncoding.UTF8);
      try
        Result := StreamReader.ReadToEnd;
      finally
        StreamReader.Free;
      end;
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
      raise EGarantiAPIError.Create('Error reading file: ' + E.Message);
  end;
end;

procedure TForm1.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Token: string;
begin
  try
    memoSonuc.Lines.Add('Incoming request received');
    memoSonuc.Lines.Add('Request Method: ' + ARequestInfo.Command);
    memoSonuc.Lines.Add('Request Raw HTTP Command: ' + ARequestInfo.RawHTTPCommand);
    memoSonuc.Lines.Add('Request Document: ' + ARequestInfo.Document);
    
    // Get token from callback URL parameters
    if ARequestInfo.Params.Values['access_token'] <> '' then
    begin
      Token := ARequestInfo.Params.Values['access_token'];
      memoSonuc.Lines.Add('Access Token received: ' + Token);
      
      // Store token for later use
      FHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + Token;
      
      // Send success response
      AResponseInfo.ContentText := LoadFileToString('callback.html');
      AResponseInfo.ContentType := 'text/html';
      Exit;
    end
    else if ARequestInfo.Params.Values['code'] <> '' then
    begin
      // Exchange authorization code for access token
      Token := GetAccessToken;
      memoSonuc.Lines.Add('Access Token received: ' + Token);
      
      // Store token for later use
      FHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + Token;
      
      // Send success response
      AResponseInfo.ContentText := LoadFileToString('callback.html');
      AResponseInfo.ContentType := 'text/html';
      Exit;
    end;
    memoSonuc.Lines.Add('Request Headers: ' + ARequestInfo.RawHeaders.Text);
    memoSonuc.Lines.Add('Request Parameters: ' + ARequestInfo.Params.ToString);
    
    if ARequestInfo.Document = '/callback' then
    begin
      // Get token from URL parameters
      Token := ARequestInfo.Params.Values['access_token'];
      if Token <> '' then
      begin
        memoSonuc.Lines.Add('Access Token Received: ' + Token);
        memoSonuc.Lines.Add('Full URL with parameters: ' + ARequestInfo.RawHTTPCommand);
        memoSonuc.Lines.Add('All parameters: ' + ARequestInfo.Params.ToString);
        
        // Get transactions using the access token
        try
          InitializeHttpClient;
          
          // Create request body
          var RequestBody := TStringStream.Create(CreateTransactionRequest, TEncoding.UTF8);
          var Response := TStringStream.Create;
          
          try
            // Set headers
            FHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + Token;
            FHttpClient.ContentType := 'application/json';
            
            // Send POST request
            FHttpClient.Post(FConfig.ReadString('GarantiAPI', 'APIEndpoint', ''), 
              RequestBody, Response);
            
            var RawResponse := Response.DataString;
            memoSonuc.Lines.Add('Transactions received:' + sLineBreak + RawResponse);
          finally
            RequestBody.Free;
            Response.Free;
          end;
        except
          on E: Exception do
            memoSonuc.Lines.Add('Error getting transactions: ' + E.Message);
        end;
      end
      else
      begin
        memoSonuc.Lines.Add('No token received in callback');
        memoSonuc.Lines.Add('Received parameters: ' + ARequestInfo.Params.ToString);
        memoSonuc.Lines.Add('Raw HTTP Command: ' + ARequestInfo.RawHTTPCommand);
      end;
    end
    else
      memoSonuc.Lines.Add('Not a callback request');
  except
    on E: Exception do
      memoSonuc.Lines.Add('Error processing request: ' + E.Message);
  end;
  
  // Send callback page to browser
  AResponseInfo.ContentType := 'text/html';
  AResponseInfo.ContentText := LoadFileToString('callback.html');
end;

function TForm1.ReadConfig: Boolean;
var
  ConfigPath: string;
begin
  ConfigPath := ExtractFilePath(Application.ExeName) + 'config.ini';
  FConfig := TIniFile.Create(ConfigPath);
  try
    Result := FileExists(ConfigPath) and 
      (FConfig.ReadString('GarantiAPI', 'ClientID', '') <> '') and
      (FConfig.ReadString('GarantiAPI', 'ClientSecret', '') <> '');
  except
    Result := False;
  end;
end;


function TForm1.CreateTransactionRequest: string;
var
  RequestObj: TJSONObject;
begin
  RequestObj := TJSONObject.Create;
  try
    RequestObj.AddPair('consentId', FConfig.ReadString('TransactionRequest', 'ConsentID', ''));
    RequestObj.AddPair('unitNum', FConfig.ReadString('TransactionRequest', 'UnitNum', ''));
    RequestObj.AddPair('accountNum', FConfig.ReadString('TransactionRequest', 'AccountNum', ''));
    RequestObj.AddPair('IBAN', FConfig.ReadString('TransactionRequest', 'IBAN', ''));
    RequestObj.AddPair('startDate', FConfig.ReadString('TransactionRequest', 'StartDate', ''));
    RequestObj.AddPair('endDate', FConfig.ReadString('TransactionRequest', 'EndDate', ''));
    RequestObj.AddPair('transactionId', FConfig.ReadString('TransactionRequest', 'TransactionID', ''));
    RequestObj.AddPair('pageIndex', FConfig.ReadString('TransactionRequest', 'PageIndex', ''));
    RequestObj.AddPair('pageSize', FConfig.ReadString('TransactionRequest', 'PageSize', ''));
    
    Result := RequestObj.ToJSON;
  finally
    RequestObj.Free;
  end;
end;

end.

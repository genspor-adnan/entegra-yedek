unit UGaranti;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.JSON, System.DateUtils,
  Winapi.WinHTTP, Winapi.WinInet, System.NetEncoding;

type
  TGarantiDlg = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function GetAccessToken: string;
    function GetTransactions(const AccessToken: string): string;
    function SendHTTPRequest(const URL, Method, Headers, Data: string): string;
  public
    { Public declarations }
  end;

var
  GarantiDlg: TGarantiDlg;

implementation

{$R *.dfm}

function TGarantiDlg.SendHTTPRequest(const URL, Method, Headers, Data: string): string;
var
  hSession, hConnect, hRequest: HINTERNET;
  dwSize, dwDownloaded: DWORD;
  pBuffer: Pointer;
  pszOutBuffer: string;
  dwBytesAvailable: DWORD;
  pdwBytesAvailable: PDWORD;
  dwBytesRead: DWORD;
  pdwBytesRead: PDWORD;
  strResponse: string;
  URLComponents: TURLComponents;
  HostName, Path: string;
  Port: INTERNET_PORT;
  HeaderLines: TStringList;
  i: Integer;
  HeaderName, HeaderValue: string;
  ColonPos: Integer;
  pData: Pointer;
  dwDataLength: DWORD;
  dwLastError: DWORD;
  dwTimeout: DWORD;
begin
  Result := '';
  
  // URL'yi parçala
  FillChar(URLComponents, SizeOf(URLComponents), 0);
  URLComponents.dwStructSize := SizeOf(URLComponents);
  URLComponents.dwHostNameLength := 1;
  URLComponents.dwUrlPathLength := 1;
  URLComponents.dwSchemeLength := 1;
  
  if not InternetCrackUrl(PChar(URL), Length(URL), 0, URLComponents) then
  begin
    dwLastError := GetLastError;
    ShowMessage('URL ayrıştırılamadı: ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
    Exit;
  end;
  
  SetLength(HostName, URLComponents.dwHostNameLength);
  SetLength(Path, URLComponents.dwUrlPathLength);
  Move(URLComponents.lpszHostName^, HostName[1], URLComponents.dwHostNameLength);
  Move(URLComponents.lpszUrlPath^, Path[1], URLComponents.dwUrlPathLength);
  Port := URLComponents.nPort;
  
  // WinHTTP oturumu başlat
  hSession := WinHttpOpen('Garanti API Client',
                         WINHTTP_ACCESS_TYPE_NO_PROXY,
                         WINHTTP_NO_PROXY_NAME,
                         WINHTTP_NO_PROXY_BYPASS,
                         0);
  if hSession = nil then
  begin
    dwLastError := GetLastError;
    ShowMessage('WinHTTP oturumu başlatılamadı: ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
    Exit;
  end;
  
  try
    // Timeout ayarları
    dwTimeout := 30000; // 30 saniye
    if not WinHttpSetTimeouts(hSession, dwTimeout, dwTimeout, dwTimeout, dwTimeout) then
    begin
      dwLastError := GetLastError;
      ShowMessage('Timeout ayarları yapılamadı: ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
      Exit;
    end;
    
    // Bağlantıyı aç
    hConnect := WinHttpConnect(hSession,
                             PChar(HostName),
                             Port,
                             0);
    if hConnect = nil then
    begin
      dwLastError := GetLastError;
      ShowMessage('Bağlantı açılamadı: ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
      Exit;
    end;
    
    try
      // İsteği aç (SSL olmadan)
      hRequest := WinHttpOpenRequest(hConnect,
                                   PChar(Method),
                                   PChar(Path),
                                   nil,
                                   WINHTTP_NO_REFERER,
                                   WINHTTP_DEFAULT_ACCEPT_TYPES,
                                   0);
      if hRequest = nil then
      begin
        dwLastError := GetLastError;
        ShowMessage('İstek açılamadı: ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
        Exit;
      end;
      
      try
        // Header'ları ayarla
        HeaderLines := TStringList.Create;
        try
          HeaderLines.Text := Headers;
          for i := 0 to HeaderLines.Count - 1 do
          begin
            if HeaderLines[i] = '' then
              Continue;
              
            ColonPos := Pos(':', HeaderLines[i]);
            if ColonPos > 0 then
            begin
              HeaderName := Trim(Copy(HeaderLines[i], 1, ColonPos - 1));
              HeaderValue := Trim(Copy(HeaderLines[i], ColonPos + 1, Length(HeaderLines[i])));
              
              if not WinHttpAddRequestHeaders(hRequest,
                                            PChar(HeaderName + ': ' + HeaderValue),
                                            Length(HeaderName + ': ' + HeaderValue),
                                            WINHTTP_ADDREQ_FLAG_ADD) then
              begin
                dwLastError := GetLastError;
                ShowMessage('Header eklenemedi: ' + HeaderLines[i] + ' - ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
                Exit;
              end;
            end;
          end;
        finally
          HeaderLines.Free;
        end;
        
        // İsteği gönder
        if Data <> '' then
        begin
          pData := Pointer(Data);
          dwDataLength := Length(Data);
        end
        else
        begin
          pData := nil;
          dwDataLength := 0;
        end;
        
        if not WinHttpSendRequest(hRequest,
                                WINHTTP_NO_ADDITIONAL_HEADERS,
                                0,
                                pData,
                                dwDataLength,
                                dwDataLength,
                                0) then
        begin
          dwLastError := GetLastError;
          ShowMessage('İstek gönderilemedi: ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
          Exit;
        end;
        
        // Yanıtı al
        if not WinHttpReceiveResponse(hRequest, nil) then
        begin
          dwLastError := GetLastError;
          ShowMessage('Yanıt alınamadı: ' + SysErrorMessage(dwLastError) + ' (' + IntToStr(dwLastError) + ')');
          Exit;
        end;
        
        // Yanıtı oku
        strResponse := '';
        repeat
          dwBytesAvailable := 0;
          pdwBytesAvailable := @dwBytesAvailable;
          if not WinHttpQueryDataAvailable(hRequest, pdwBytesAvailable) then
            Break;
            
          if dwBytesAvailable = 0 then
            Break;
            
          GetMem(pBuffer, dwBytesAvailable);
          try
            dwBytesRead := 0;
            pdwBytesRead := @dwBytesRead;
            if not WinHttpReadData(hRequest, pBuffer, dwBytesAvailable, pdwBytesRead) then
              Break;
              
            pszOutBuffer := '';
            SetString(pszOutBuffer, PChar(pBuffer), dwBytesRead);
            strResponse := strResponse + pszOutBuffer;
          finally
            FreeMem(pBuffer);
          end;
        until False;
        
        Result := strResponse;
      finally
        WinHttpCloseHandle(hRequest);
      end;
    finally
      WinHttpCloseHandle(hConnect);
    end;
  finally
    WinHttpCloseHandle(hSession);
  end;
end;

function TGarantiDlg.GetAccessToken: string;
var
  URL: string;
  Headers: string;
  Data: string;
  Response: string;
  JSONResponse: TJSONObject;
  ClientID: string;
  ClientSecret: string;
  AuthHeader: string;
  Credentials: string;
begin
  Result := '';
  
  // HTTP kullan (SSL olmadan)
  URL := 'http://apis.garantibbva.com.tr/auth/oauth/v2/token';
  
  ClientID := 'l77959f4cd59f54a63b496c71dbe0b33a0';
       //     '177959f4cd59f54a63b496c71dbe0b33a0';
  ClientSecret := '736abff6058a4e019a844893b38f650d';
  //ClientSecret := '5327d258-eb31-529e-bcfb-095e945de2f9';
  
  // Base64 encode the credentials
  Credentials := ClientID + ':' + ClientSecret;
  AuthHeader := 'Basic ' + TNetEncoding.Base64.Encode(Credentials);
  
  // Headers
  Headers := 'Authorization: ' + AuthHeader + #13#10 +
             'Content-Type: application/x-www-form-urlencoded' + #13#10 +
             'Accept: application/json';
  
  // Request body
  Data := 'grant_type=client_credentials' +
          '&redirect_uri=oob';
  
  Memo1.Lines.Add('Token isteği gönderiliyor...');
  Memo1.Lines.Add('URL: ' + URL);
  Memo1.Lines.Add('Auth Header: ' + AuthHeader);
  Memo1.Lines.Add('Data: ' + Data);
  
  Response := SendHTTPRequest(URL, 'POST', Headers, Data);
  
  Memo1.Lines.Add('Response: ' + Response);
  
  if Response <> '' then
  begin
    JSONResponse := TJSONObject.ParseJSONValue(Response) as TJSONObject;
    try
      if Assigned(JSONResponse) then
        Result := JSONResponse.GetValue('access_token').Value;
    finally
      JSONResponse.Free;
    end;
  end;
end;

function TGarantiDlg.GetTransactions(const AccessToken: string): string;
var
  URL: string;
  Headers: string;
  Data: string;
  JSONRequest: TJSONObject;
begin
  Result := '';
  
  // HTTP kullan (SSL olmadan)
  URL := 'http://apis.garantibbva.com.tr/balancesandmovements/accountinformation/transaction/v1/gettransactions';
  
  JSONRequest := TJSONObject.Create;
  try
    JSONRequest.AddPair('consentId', 'YOUR_CONSENT_ID');
    JSONRequest.AddPair('unitNum', TJSONNumber.Create(295));
    JSONRequest.AddPair('accountNum', TJSONNumber.Create(6291296));
    JSONRequest.AddPair('IBAN', 'TR620006200029500006291296');
    JSONRequest.AddPair('startDate', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', IncDay(Now, -7)));
    JSONRequest.AddPair('endtDate', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', Now));
    JSONRequest.AddPair('pageIndex', TJSONNumber.Create(1));
    JSONRequest.AddPair('pageSize', TJSONNumber.Create(100));
    
    Data := JSONRequest.ToString;
  finally
    JSONRequest.Free;
  end;
  
  // Headers
  Headers := 'Authorization: Bearer ' + AccessToken + #13#10 +
             'Content-Type: application/json' + #13#10 +
             'Accept: application/json' + #13#10 +
             'GUID: ' + TGUID.NewGuid.ToString;
  
  Result := SendHTTPRequest(URL, 'POST', Headers, Data);
end;

procedure TGarantiDlg.Button1Click(Sender: TObject);
var
  AccessToken: string;
begin
  Memo1.Clear;
  AccessToken := GetAccessToken;
  if AccessToken <> '' then
    Memo1.Lines.Text := GetTransactions(AccessToken)
  else
    ShowMessage('Access token alınamadı!');
end;




end.

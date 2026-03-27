unit PosInfo;

interface

uses
  System.SysUtils, IdHTTP, IdSSLOpenSSL, System.JSON;

procedure FetchPOSInfo(const AuthToken: string);

implementation

procedure FetchPOSInfo(const AuthToken: string);
var
  HttpClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  ResponseBody: TStringStream;
  JsonResponse: TJSONObject;
begin
  HttpClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  ResponseBody := TStringStream.Create;
  try
    HttpClient.IOHandler := SSLHandler;

    // Set the authorization header
    HttpClient.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + AuthToken);

    // Send request to fetch POS information
    HttpClient.Get('https://polynom-api.finekra.com/api/posinfo', ResponseBody);
    
    // Process the response
    JsonResponse := TJSONObject.ParseJSONValue(ResponseBody.DataString) as TJSONObject;
    try
      // Handle the response data
      // ... (process POS data here)
    finally
      JsonResponse.Free;
    end;
  finally
    HttpClient.Free;
    SSLHandler.Free;
    ResponseBody.Free;
  end;
end;

end.

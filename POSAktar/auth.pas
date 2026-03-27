unit Auth;

interface

uses
  System.SysUtils, IdHTTP, IdSSLOpenSSL, System.JSON;

function Authenticate: string;

implementation

function Authenticate: string;
var
  HttpClient: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  RequestBody, ResponseBody: TStringStream;
  JsonResponse: TJSONObject;
begin
  HttpClient := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  RequestBody := TStringStream.Create;
  ResponseBody := TStringStream.Create;
  try
    HttpClient.IOHandler := SSLHandler;

    // Prepare JSON request for authentication
    RequestBody.WriteString('{"email": "finekra-api@bilimplant.com", "password": "JwfFVR5Vvj+7A6tk", "tenantCode": "7330884158", "screenOption": 0}');

    // Send request to authenticate
    HttpClient.Post('https://polynom-api.finekra.com/api/Auth/DealerLogin', RequestBody, ResponseBody);
    
    // Parse the response to get the authentication token
    JsonResponse := TJSONObject.ParseJSONValue(ResponseBody.DataString) as TJSONObject;
    try
      Result := JsonResponse.GetValue<string>('token'); // Assuming 'token' is the key for the auth token
    finally
      JsonResponse.Free;
    end;
  finally
    HttpClient.Free;
    SSLHandler.Free;
    RequestBody.Free;
    ResponseBody.Free;
  end;
end;

end.

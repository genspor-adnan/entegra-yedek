unit UGaranti;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxSkinsCore, dxSkinBasic, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinOffice2019Black,
  dxSkinOffice2019Colorful, dxSkinOffice2019DarkGray, dxSkinOffice2019White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxSkinWXI,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, Vcl.StdCtrls,
  cxButtons,   IdCustomHTTPServer, IdHTTPServer, IdContext;

type
  TForm1 = class(TForm)
    btnBaglan: TcxButton;
    memoSonuc: TMemo;
    procedure btnBaglanClick(Sender: TObject);
  private
    { Private declarations }
    function GetAccessToken(ClientID, ClientSecret: string): string;
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



//procedure TForm1.cxButton1Click(Sender: TObject);
uses
  System.JSON, IdCoderMIME,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

var
   IdHTTPServer1 : TIdHTTPServer;

procedure TForm1.btnBaglanClick(Sender: TObject);
var
  ClientID, ClientSecret, Token: string;
begin
//  ClientID := edtClientID.Text.Trim;
//  ClientSecret := edtClientSecret.Text.Trim;
  IdHTTPServer1 := TIdHTTPServer.Create();
  IdHTTPServer1.DefaultPort := 8080; // Callback URL'de bu portu yazmalýsýn
  IdHTTPServer1.OnCommandGet := IdHTTPServer1CommandGet;
  IdHTTPServer1.Active := True;
  memoSonuc.Lines.Add('Callback sunucusu baþlatýldý: http://localhost:8080/callback');


  ClientID := 'l77959f4cd59f54a63b496c71dbe0b33a0';

  ClientSecret := '736abff6058a4e019a844893b38f650d';
 // ClientSecret := '5327d258-eb31-529e-bcfb-095e945de2f9';
 //   ClientSecret := 'c166cae2f7c14457b9c35ccc23be06f7';


  try
    Token := GetAccessToken(ClientID, ClientSecret);
    memoSonuc.Lines.Add( 'Access Token Alýndý:' + sLineBreak + Token);
  except
    on E: Exception do
      memoSonuc.Lines.Add('Hata: ' + E.Message);
  end;
end;

function TForm1.GetAccessToken(ClientID, ClientSecret: string): string;
var
  HttpClient: TNetHTTPClient;
  Params: TStringStream;
  Response: TStringStream;
  JSONResponse: TJSONObject;
  Base64Auth: string;
  RawResponse: string;
begin
  HttpClient := TNetHTTPClient.Create(nil);
  Params := TStringStream.Create('grant_type=client_credentials', TEncoding.UTF8);
  Response := TStringStream.Create;
  try
    Base64Auth := TIdEncoderMIME.EncodeString(ClientID + ':' + ClientSecret);
    HttpClient.CustomHeaders['Authorization'] := 'Basic ' + Base64Auth;
    HttpClient.ContentType := 'application/x-www-form-urlencoded';

    // HTTP POST ile token al
    HttpClient.Post('https://apis.garantibbva.com.tr/auth/oauth/v2/token', Params, Response);

    RawResponse := Response.DataString;
    memoSonuc.Lines.Add('Dönen yanýt:' + sLineBreak + RawResponse);

    JSONResponse := TJSONObject.ParseJSONValue(RawResponse) as TJSONObject;
    if not Assigned(JSONResponse) then
      raise Exception.Create('Yanýt ayrýþtýrýlamadý!');

    if JSONResponse.GetValue('access_token') = nil then
      raise Exception.Create('Access Token bulunamadý. Hata: ' + JSONResponse.ToJSON);

    Result := JSONResponse.GetValue<string>('access_token');
    JSONResponse.Free;
  finally
    HttpClient.Free;
    Params.Free;
    Response.Free;
  end;
end;


procedure TForm1.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  JSONObj: TJSONObject;
  BodyStr: string;
  SS: TStringStream;
begin
  if (ARequestInfo.PostStream <> nil) and (ARequestInfo.PostStream.Size > 0) then
  begin
    ARequestInfo.PostStream.Position := 0;
    SS := TStringStream.Create('', TEncoding.UTF8);
    try
      SS.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
      BodyStr := SS.DataString;

      JSONObj := TJSONObject.ParseJSONValue(BodyStr) as TJSONObject;
      if Assigned(JSONObj) then
      begin
        // access_token örnek: cb215ada-b7d3-4dd5-911a-7171f2f754bf
        memoSonuc.Lines.Add('Access Token: ' + JSONObj.GetValue<string>('access_token'));
        JSONObj.Free;
      end
      else
        memoSonuc.Lines.Add('Geçersiz JSON geldi!');
    finally
      SS.Free;
    end;
  end;
end;


end.

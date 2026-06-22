unit GenGoogleCalenderService;

interface

uses
  System.Classes, System.SysUtils, System.DateUtils,
  GoogleApis,
  GoogleApis.Persister,
  GoogleApis.Calendar,
  GoogleApis.Calendar.Persister;

type

  TGoogleCalenderLoginInfo = class
  strict private
    FServiceAccount : string;
    FP12PrimaryKeyData : TBytes;
  public
    constructor Create; overload;
    constructor Create(const AServiceAccount: string;
      const AP12PrimaryKeyData: TBytes); overload;
  public
    property ServiceAccount: string read FServiceAccount write FServiceAccount;
    property P12PrimaryKeyData: TBytes read FP12PrimaryKeyData write FP12PrimaryKeyData;
  end;

  TGoogleCalendarEvent = record
    TakvimId,
    BolumId,
    OlayId,
    aciklama,
    Konum,
    Hasta,
    Tel,
    Baslik: string;
    Tarih: TDatetime;
    sure :Integer;
  public
    class function New(TakvimId, BolumId, OlayId, aciklama, Konum, Hasta, Tel, Baslik : string;
      Tarih: TDatetime; sure :Integer): TGoogleCalendarEvent; static;
  end;

  function GetService(GoogleCalenderLoginInfo : TGoogleCalenderLoginInfo = nil): TCalendarService;
  function InsertOrUpdateGoogleEvent(const AEvent: TGoogleCalendarEvent;
    AService: TCalendarService = nil): string;
  procedure DeleteGooleEvent(const CalendarId, GoogleEventId: string;
    AService: TCalendarService = nil);

implementation

var
  CalendarService: TCalendarService;
  SharedCalendarService: TCalendarService;

const
  GenPrimaryKey =
      '-----BEGIN RSA PRIVATE KEY-----' +
      'MIIEpAIBAAKCAQEAtvckoG0fkG4sVPri8OSx8sazlcKBxow3vjfioFixYBvF3PYz' +
      'ZJ9Xfg26fWjjK+mHi+Mfuok1Q3KJnIt9cJTlykoSd4I2QqOpoPV0I9zmzcLgZvKb' +
      'WvNl0M5W2KXgu8OFT8hRMrttUSmQQaMqYn+qKmSGBVdopgUaRX0VNJO1vAhfh9LL' +
      'aGPM1xkAhofsahI1CesbWDv758tAAkxHkjIU1LCxpMOpSk1MQXNDRa76EMox842Y' +
      'bUJz4FywP414W7ffUsXP1jgge1Zo020fRIM40Jju0m6T5lNxcrQm0qU7eWRLjXY+' +
      'ITB93Gjqo+HQ/liPdn5dC/LqqyH04aQyuKwK2wIDAQABAoIBAAQQ0duJ1ieRnt2l' +
      'yn5wfexrKGWGT7yO+Rk1nLSFTd9sjVZDVzkE4W3CusxPPF0TSUAa1XlacVYYgXlm' +
      '6Lr88ZWmGi/fghg9Td2CZZKY5vgSUIXvRPPil88RQc/cyZ0J5zh3j7FthbYyJo3d' +
      'm0H4Jh+Qkw2Fy2mFBpWnytObpyGQpaylyiQLNGCf620Sp7ifrRmXIAJ3VQh0viGL' +
      '9upBsx5iNhDb/fF/TtNSKPu6+OT6ahge5lHIgy+HLQs7kPsR0fBtO9kVFMN6j5Tw' +
      'vLv563dWt+fFcX8GfYQCuhqLzVLNUHFYJjiMgIx4Ge1a0TQQZ6TX71pi8H0GNzgf' +
      'DexQ8yECgYEA37Yu/SuLb5Elqig251fXCZ2sAfTU+VbnK2fFj4ew5Kt4LjQYkDtH' +
      '5A1Pq1uSEYT19S85ykxM110VWjEX2FEDG7L1jyI6AZqtVgs55AOr3cmpmTV5hP3i' +
      'vbwGW2CaS79GOdYrVBc9dXtO69u6/nBD56Zy/w6wQt5y579AYN9JvI0CgYEA0V9y' +
      'Cn6K1flq3RcYTcjUv3TOlayJjWTSQ2uWfFDRzvMdccEdU5dEF76zyyDbrRyjBI5j' +
      'jHQi4A/fK3G2YqzNoTUwQ+t8eJDWL5cxsWtER38PRW+Ocj1qVSkIdCO2XYBR9uha' +
      '1qkjrnneL14dqiGfEJQibaU7++nLdX4aR2KyLwcCgYB5KawDdJ0dfOiAYy1xWNLf' +
      'o2Tw3lCnBtlHWfnXRe+ZugDqTU7sdx71tfvrXDodgPzRoZVUKsUHc6PH6IT4pM/h' +
      'Jaj3r9ro2YR98LCW/SINilZv41WAoR04E+kBfq2yztLTKlrnPXsM8Q8KkUSS3+z3' +
      'PuBTofn3DZIAUEYm8Wh3VQKBgQDQuWwBFkHmKq3kFr/923ZsH1BLWiQOtzH+UGVH' +
      'LXLb8vWpj7Fiwev6F/05RVp6a5AAXMrVHHogEPKUZtpB6K9eRJ4HN91wfENqUjoR' +
      '+zOoavyYZiwFq0A0AaIR1gBZmjEcCmt0kE2oBIoBgrvj/XyLlIH1+MGh02MnkD02' +
      'aSflRQKBgQDev0zO1qahOoBfW1ZnM0VZfHbK8+jwgp/4WFhCJFmKAQjgi1sJRE01' +
      'n1yK1EbqJti+pVf48SFNMWbaA2tfo98VSlWufdBF78j5wb9DaUoJNxjqYuFblkmr' +
      'tiL7y6cM6VkdXjnCz5TR+hWELYkKBKQ+P2fbJDfUTPUk6IgUAC5caw==' +
      '-----END RSA PRIVATE KEY-----';

function GetService(GoogleCalenderLoginInfo : TGoogleCalenderLoginInfo = nil): TCalendarService;
var
  Initializer: TServiceInitializer;
  Credential: TGoogleServiceAccountCredential;

  function CreateService: TCalendarService;
  begin
    Initializer := TGoogleApisServiceInitializer.Create(Credential, 'GenoTIP');
    Result:= TCalendarService.Create(Initializer);
  end;

begin
  Credential := TGoogleServiceAccountCredential.Create();
  Credential.OAuthScope :=  'https://www.googleapis.com/auth/calendar';
  if Assigned(GoogleCalenderLoginInfo) then
  begin
    {Özel hesap }
    FreeAndNil(CalendarService); //Daha önce kullanıdıysa temizle
    Credential.ServiceAccount := GoogleCalenderLoginInfo.ServiceAccount;
    Credential.P12CertData := GoogleCalenderLoginInfo.P12PrimaryKeyData;
    GoogleCalenderLoginInfo.Free;
    CalendarService := CreateService;
    Result := CalendarService;
  end else
  begin
    {Ortak hesap }
    if SharedCalendarService = nil then
    begin
      Credential.ServiceAccount := 'gen-yazilim-api-test@calendertest-377005.iam.gserviceaccount.com';
      Credential.P12CertData := BytesOf(GenPrimaryKey);
      SharedCalendarService := CreateService;
    end;
    Result := SharedCalendarService;
  end;

end;

function InsertOrUpdateGoogleEvent(const AEvent: TGoogleCalendarEvent;
    AService: TCalendarService): string;
var
  service: TCalendarService;
  insReq: TEventsInsertRequest;
  updReq: TEventsUpdateRequest;
  event: TEvent;
begin
  Result := '';

  event := TEvent.Create;
  event.Summary := AEvent.Hasta;
  event.Location := AEvent.Konum;
//  event.Description := Format('Açıklama: %1:s%0:s%0:sHasta Telefonu: %2:s%0:sBolum Id: %3:s',
//    [sLineBreak, AEvent.aciklama, AEvent.Tel, AEvent.BolumId]);
  event.Description := Aevent.aciklama;

  event.Start := TEventDateTime.Create;
  event.Start.DateTime := AEvent.Tarih;

  event.End_:= TEventDateTime.Create;
  event.End_.DateTime := IncMinute(AEvent.Tarih, AEvent.sure);

  if Assigned(AService) then
    service:= AService else GetService();

  if AEvent.OlayId = EmptyStr then
  begin
    insReq := service.Events.Insert(AEvent.TakvimId, event);
    try
      event:= insReq.Execute;
      try
        Result := event.Id;
      finally
        event.Free;
      end;
    finally
      insReq.Free;
    end;
  end else
  begin
    event.Id := AEvent.OlayId;
    updReq := service.Events.Update(AEvent.TakvimId, event);
    try
      event:= updReq.Execute;
      event.Free;
    finally
      updReq.Free;
    end;
  end;
end;

procedure DeleteGooleEvent(const CalendarId, GoogleEventId: string;
  AService: TCalendarService = nil);
var
  service: TCalendarService;
  req: TEventsDeleteRequest;
begin
  if Assigned(AService) then
    service:= AService else GetService();

  req := service.Events.Delete(CalendarId, GoogleEventId);
  try
     req.Execute();
  finally
    req.Free;
  end;
end;

{ TGoogleCalenderLoginInfo }

constructor TGoogleCalenderLoginInfo.Create(const AServiceAccount: string;
  const AP12PrimaryKeyData: TBytes);
begin
  Create();
  FServiceAccount := AServiceAccount;
  P12PrimaryKeyData := AP12PrimaryKeyData;
end;

constructor TGoogleCalenderLoginInfo.Create;
begin
  inherited Create();
end;

{ TGoogleCalendarEvent }

class function TGoogleCalendarEvent.New(TakvimId, BolumId, OlayId, aciklama, Konum, Hasta, Tel,
  Baslik: string; Tarih: TDatetime; sure: Integer): TGoogleCalendarEvent;
begin
  Result.TakvimId := TakvimId;
  Result.BolumId := BolumId;
  Result.OlayId := OlayId;
  Result.aciklama := aciklama;
  Result.Konum := Konum;
  Result.Hasta := Hasta;
  Result.Tel := Tel;
  Result.Baslik := Baslik;
  Result.Tarih := Tarih;
  Result.sure := sure;
end;

initialization

finalization
  CalendarService.Free;
  SharedCalendarService.Free;

end.

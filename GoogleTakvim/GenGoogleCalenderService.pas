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

  function GetService(GoogleCalenderLoginInfo : TGoogleCalenderLoginInfo): TCalendarService;
  function InsertOrUpdateGoogleEvent(const AEvent: TGoogleCalendarEvent;
    AService: TCalendarService): string;
  procedure DeleteGooleEvent(const CalendarId, GoogleEventId: string;
    AService: TCalendarService);

implementation

var
  CalendarService: TCalendarService;

function GetService(GoogleCalenderLoginInfo : TGoogleCalenderLoginInfo): TCalendarService;
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
  FreeAndNil(CalendarService); //Daha önce kullanýdýysa temizle
  Credential.ServiceAccount := GoogleCalenderLoginInfo.ServiceAccount;
  Credential.P12CertData := GoogleCalenderLoginInfo.P12PrimaryKeyData;
  GoogleCalenderLoginInfo.Free;
  CalendarService := CreateService;
  Result := CalendarService;

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
  event.Location := AEvent.Konum +'('+AEvent.BolumId+')';
  event.Description := Format('%1:s%0:s%0:s %2:s%0:s',
    [sLineBreak, AEvent.aciklama, AEvent.Tel]);

  event.Start := TEventDateTime.Create;
  event.Start.DateTime := AEvent.Tarih;

  event.End_:= TEventDateTime.Create;
  event.End_.DateTime := IncMinute(AEvent.Tarih, AEvent.sure);


  service:= AService;

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
  AService: TCalendarService);
var
  service: TCalendarService;
  req: TEventsDeleteRequest;
begin
  service:= AService;

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

end.

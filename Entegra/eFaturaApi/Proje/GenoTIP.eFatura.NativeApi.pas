unit GenoTIP.eFatura.NativeApi;

interface
uses
  SysUtils, Dialogs, Windows, ActiveX;

const
  INVOICE_NEW = $0001;
  INVOICE_SENT_OR_RECEVIED = $0002;
  INVOICE_ACCEPTED = $0010;
  INVOICE_REJECTED = $0020;
  INVOICE_CANCELED = $0400;

  function InitializeApi(AUserId, ABranchId: Integer): Boolean;
  function OpenInvoice(AInvoiceId: String;var AOpenedInvoiceId: Integer): Boolean;
  function CloseInvoice(AOpenedInvoiceId: Integer): Boolean;
  function GetInvoiceStatus(AOpenedInvoiceId: Integer;var AStatus: Integer): Boolean;
  function ShowInvoicePreview(AOpenedInvoiceId: Integer): Boolean;
  function SendInvoice(AOpenedInvoiceId: Integer): Boolean;

  function TestInvoiceStatus(AOpenedInvoiceId, AFlag: Integer): Boolean;

implementation

const
  NativeDll                               = 'GenoTIP.eFatura.Native.dll';
  RESULT_SUCCESS                          = 0;
  RESULT_NOT_INITIALIZED                  = $80000001;
  RESULT_NOT_LOGGED_IN                    = $80000002;
  RESULT_INITIALIZE_DB_FAILED             = $80000003;
  RESULT_USER_NOT_FOUND                   = $80000004;
  RESULT_BRANCH_NOT_FOUND                 = $80000005;
  RESULT_INVOICE_NOT_FOUND                = $80000006;
  RESULT_MAPPING_CANCELED                 = $80000007;
  RESULT_EINVOICE_COULD_NOT_BE_GENERATED  = $80000008;
  RESULT_EXCEPTION                        = $80000009;


type
  TCreateSession                = function : HINST;cdecl;
  TDestroySession               = procedure (AInst: HINST);cdecl;
  TLogin                        = function (AInst: HINST;AUserId,ABranchId: Integer): Integer;cdecl;
  TShowInvoicePreview           = function (AInst: HINST;AOpenedInvoiceId: Integer): Integer;cdecl;
  TSendInvoice                  = function (AInst: HINST;AOpenedInvoiceId: Integer): Integer;cdecl;
  TOpenInvoice                  = function (AInst: HINST;AInvoiceId: PWideChar;var AOpenedInvoiceId: Integer): Integer;cdecl;
  TGetInvoiceStatus             = function (AInst: HINST;AOpenedInvoiceId: Integer;var AStatus: Integer): Integer;cdecl;
  TCloseInvoice                 = function (AInst: HINST;AOpenedInvoiceId: Integer): Integer;cdecl;
  TGetLastError                 = function (AInst: HINST): PWideChar;cdecl;

var
  NativeDllHandle               : HMODULE = 0;
  SessionInstance               : HINST = 0;
  _CreateSession                : TCreateSession = nil;
  _DestroySession               : TDestroySession = nil;
  _Login                        : TLogin = nil;
  _ShowInvoicePreview           : TShowInvoicePreview = nil;
  _SendInvoice                  : TSendInvoice = nil;
  _GetLastError                 : TGetLastError = nil;
  _OpenInvoice                  : TOpenInvoice = nil;
  _CloseInvoice                 : TCloseInvoice = nil;
  _GetInvoiceStatus             : TGetInvoiceStatus = nil;

procedure GetProcedureAddress(var P: Pointer; const ProcName: string);
begin
  if not Assigned(P) then
  begin
    P := GetProcAddress(NativeDllHandle, PChar(ProcName));
    if not Assigned(P) then
      raise Exception.CreateFmt('Procedure bulunamadı %s', [ProcName]);
  end;
end;

function CreateSession: HINST;
begin
  GetProcedureAddress(Pointer(@_CreateSession),'CreateSession');
  Result := _CreateSession;
end;

procedure DestroySession(AInst: HINST);
begin
  GetProcedureAddress(Pointer(@_DestroySession),'DestroySession');
end;

function ApiLogin(AInst: HINST;AUserId,ABranchId: Integer): Integer;
begin
  GetProcedureAddress(Pointer(@_Login),'Login');
  Result := _Login(AInst,AUserId,ABranchId);
end;

function ApiShowInvoicePreview(AInst: HINST;AOpenedInvoiceId: Integer): Integer;
begin
  GetProcedureAddress(Pointer(@_ShowInvoicePreview),'ShowInvoicePreview');
  Result := _ShowInvoicePreview(AInst,AOpenedInvoiceId);
end;

function ApiSendInvoice(AInst: HINST;AOpenedInvoiceId: Integer): Integer;
begin
  GetProcedureAddress(Pointer(@_SendInvoice),'SendInvoice');
  Result := _SendInvoice(AInst,AOpenedInvoiceId);
end;

function ApiOpenInvoice(AInst: HINST;AInvoiceId: string;var AOpenedInvoiceId: Integer): Integer;
begin
  GetProcedureAddress(Pointer(@_OpenInvoice),'OpenInvoice');
  Result := _OpenInvoice(AInst,PWideChar(AInvoiceId),AOpenedInvoiceId);
end;

function ApiCloseInvoice(AInst: HINST;AOpenedInvoiceId: Integer): Integer;
begin
  GetProcedureAddress(Pointer(@_CloseInvoice),'CloseInvoice');
  Result := _CloseInvoice(AInst, AOpenedInvoiceId);
end;

function ApiGetInvoiceStatus(AInst: HINST;AOpenedInvoiceId: Integer;var AStatus: Integer): Integer;
begin
  GetProcedureAddress(Pointer(@_GetInvoiceStatus),'GetInvoiceStatus');
  Result := _GetInvoiceStatus(AInst, AOpenedInvoiceId, AStatus);
end;

function ApiGetLastError(AInst: HINST): PWideChar;
begin
  GetProcedureAddress(Pointer(@_GetLastError),'GetLastError');
  Result := _GetLastError(AInst);
end;

function NativeApiCheck(AResult: Integer): Boolean;
var
  err : PWideChar;
begin
  Result := True;
  if AResult <> RESULT_SUCCESS then begin
    Result := False;
    err := ApiGetLastError(SessionInstance);
    try
      raise Exception.Create(WideCharToString(err));
    finally
      if AResult = RESULT_EXCEPTION then
        CoTaskMemFree(err);
    end;
  end;
end;

procedure FinalizeApi;
begin
  if SessionInstance = 0 then Exit;
  DestroySession(SessionInstance);
  SessionInstance := 0;
end;

function InitializeApi;
begin
  if SessionInstance <> 0 then
    Exit(True);
  if NativeDllHandle = 0 then begin
    NativeDllHandle := SafeLoadLibrary(NativeDll);
    if NativeDllHandle = 0 then
      raise Exception.Create('Dll yüklenemedi!');
  end;
  Result := False;
  try
    SessionInstance := CreateSession;
    if NativeApiCheck(ApiLogin(SessionInstance,AUserId,ABranchId)) then begin
      Exit(True);
    end;
  finally
    if not Result then begin
      FinalizeApi;
    end;
  end;
end;

function ShowInvoicePreview(AOpenedInvoiceId: Integer): Boolean;
begin
  if SessionInstance = 0 then
    raise Exception.Create('Api başlatılmamış!');
  Result := NativeApiCheck(
    ApiShowInvoicePreview(SessionInstance,AOpenedInvoiceId));
end;

function SendInvoice(AOpenedInvoiceId: Integer): Boolean;
begin
  if SessionInstance = 0 then
    raise Exception.Create('Api başlatılmamış!');
  Result := NativeApiCheck(
    ApiSendInvoice(SessionInstance,AOpenedInvoiceId));
end;

function OpenInvoice(AInvoiceId: String;var AOpenedInvoiceId: Integer): Boolean;
begin
  if SessionInstance = 0 then
    raise Exception.Create('Api başlatılmamış!');
  Result := NativeApiCheck(
    ApiOpenInvoice(SessionInstance,AInvoiceId,AOpenedInvoiceId));
end;

function CloseInvoice(AOpenedInvoiceId: Integer): Boolean;
begin
  if SessionInstance = 0 then
    raise Exception.Create('Api başlatılmamış!');
  Result := NativeApiCheck(
    ApiCloseInvoice(SessionInstance,AOpenedInvoiceId));
end;

function GetInvoiceStatus(AOpenedInvoiceId: Integer;var AStatus: Integer): Boolean;
begin
  if SessionInstance = 0 then
    raise Exception.Create('Api başlatılmamış!');
  Result := NativeApiCheck(
    ApiGetInvoiceStatus(SessionInstance,AOpenedInvoiceId,AStatus));
end;

function TestInvoiceStatus(AOpenedInvoiceId, AFlag: Integer): Boolean;
var
  st : Integer;
begin
  GetInvoiceStatus(AOpenedInvoiceId,st);
  Result := ( st AND AFlag ) = AFlag;
end;



initialization

finalization
  FinalizeApi;
end.


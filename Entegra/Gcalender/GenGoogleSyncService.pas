// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc?wsdl
//  >Import : http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc?wsdl>0
//  >Import : http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc?xsd=xsd0
//  >Import : http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc?xsd=xsd2
//  >Import : http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc?xsd=xsd1
// Encoding : utf-8
// Version  : 1.0
// (08/09/2020 11:50:30 - - $Rev: 52705 $)
// ************************************************************************ //

unit GenGoogleSyncService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_NLBL = $0004;
  IS_REF  = $0080;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:double          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]

  CalendarLogin2       = class;                 { "http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"[GblCplx] }
  CalendarEvent2       = class;                 { "http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"[GblCplx] }
  CalendarEvent        = class;                 { "http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"[GblElm] }
  CalendarLogin        = class;                 { "http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"[GblElm] }



  // ************************************************************************ //
  // XML       : CalendarLogin, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary
  // ************************************************************************ //
  CalendarLogin2 = class(TRemotable)
  private
    FCalendarID: string;
    FCalendarID_Specified: boolean;
    FP12SecurityFile: TByteDynArray;
    FP12SecurityFile_Specified: boolean;
    FServiceAccountMailAddress: string;
    FServiceAccountMailAddress_Specified: boolean;
    procedure SetCalendarID(Index: Integer; const Astring: string);
    function  CalendarID_Specified(Index: Integer): boolean;
    procedure SetP12SecurityFile(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  P12SecurityFile_Specified(Index: Integer): boolean;
    procedure SetServiceAccountMailAddress(Index: Integer; const Astring: string);
    function  ServiceAccountMailAddress_Specified(Index: Integer): boolean;
  published
    property CalendarID:                string         Index (IS_OPTN or IS_NLBL) read FCalendarID write SetCalendarID stored CalendarID_Specified;
    property P12SecurityFile:           TByteDynArray  Index (IS_OPTN or IS_NLBL) read FP12SecurityFile write SetP12SecurityFile stored P12SecurityFile_Specified;
    property ServiceAccountMailAddress: string         Index (IS_OPTN or IS_NLBL) read FServiceAccountMailAddress write SetServiceAccountMailAddress stored ServiceAccountMailAddress_Specified;
  end;



  // ************************************************************************ //
  // XML       : CalendarEvent, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary
  // ************************************************************************ //
  CalendarEvent2 = class(TRemotable)
  private
    FDescription: string;
    FDescription_Specified: boolean;
    FId: string;
    FId_Specified: boolean;
    FLocation: string;
    FLocation_Specified: boolean;
    FPatientName: string;
    FPatientName_Specified: boolean;
    FPatientPhone: string;
    FPatientPhone_Specified: boolean;
    FPeriod: Double;
    FPeriod_Specified: boolean;
    FSectionId: string;
    FSectionId_Specified: boolean;
    FStartDate: TXSDateTime;
    FStartDate_Specified: boolean;
    FSummary: string;
    FSummary_Specified: boolean;
    procedure SetDescription(Index: Integer; const Astring: string);
    function  Description_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Astring: string);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetLocation(Index: Integer; const Astring: string);
    function  Location_Specified(Index: Integer): boolean;
    procedure SetPatientName(Index: Integer; const Astring: string);
    function  PatientName_Specified(Index: Integer): boolean;
    procedure SetPatientPhone(Index: Integer; const Astring: string);
    function  PatientPhone_Specified(Index: Integer): boolean;
    procedure SetPeriod(Index: Integer; const ADouble: Double);
    function  Period_Specified(Index: Integer): boolean;
    procedure SetSectionId(Index: Integer; const Astring: string);
    function  SectionId_Specified(Index: Integer): boolean;
    procedure SetStartDate(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  StartDate_Specified(Index: Integer): boolean;
    procedure SetSummary(Index: Integer; const Astring: string);
    function  Summary_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Description:  string       Index (IS_OPTN or IS_NLBL) read FDescription write SetDescription stored Description_Specified;
    property Id:           string       Index (IS_OPTN or IS_NLBL) read FId write SetId stored Id_Specified;
    property Location:     string       Index (IS_OPTN or IS_NLBL) read FLocation write SetLocation stored Location_Specified;
    property PatientName:  string       Index (IS_OPTN or IS_NLBL) read FPatientName write SetPatientName stored PatientName_Specified;
    property PatientPhone: string       Index (IS_OPTN or IS_NLBL) read FPatientPhone write SetPatientPhone stored PatientPhone_Specified;
    property Period:       Double       Index (IS_OPTN) read FPeriod write SetPeriod stored Period_Specified;
    property SectionId:    string       Index (IS_OPTN or IS_NLBL) read FSectionId write SetSectionId stored SectionId_Specified;
    property StartDate:    TXSDateTime  Index (IS_OPTN) read FStartDate write SetStartDate stored StartDate_Specified;
    property Summary:      string       Index (IS_OPTN or IS_NLBL) read FSummary write SetSummary stored Summary_Specified;
  end;



  // ************************************************************************ //
  // XML       : CalendarEvent, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary
  // ************************************************************************ //
  CalendarEvent = class(CalendarEvent2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : CalendarLogin, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary
  // ************************************************************************ //
  CalendarLogin = class(CalendarLogin2)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/IGenGoogleSyncService/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : BasicHttpBinding_IGenGoogleSyncService
  // service   : GenGoogleSyncService
  // port      : BasicHttpBinding_IGenGoogleSyncService
  // URL       : http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc
  // ************************************************************************ //
  IGenGoogleSyncService = interface(IInvokable)
  ['{D28BC93C-87E2-5DCD-00D6-0B007872362F}']
    function  InsertCalendarEvent(const _CalendarLogin: CalendarLogin2; const _CalendarEvent: CalendarEvent2): string; stdcall;
    function  DeleteCalendarEvent(const _CalendarLogin: CalendarLogin2; const _EventId: string): Boolean; stdcall;
    function  UpdateCalendarEvent(const _CalendarLogin: CalendarLogin2; const _CalendarEvent: CalendarEvent2): Boolean; stdcall;
    function  GetCalendarEvent(const _CalendarLogin: CalendarLogin2; const _EventId: string): CalendarEvent2; stdcall;
  end;

function GetIGenGoogleSyncService(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IGenGoogleSyncService;


implementation

uses SysUtils;

function GetIGenGoogleSyncService(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IGenGoogleSyncService;
const
  defWSDL = 'http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc?wsdl';
  defURL  = 'http://genlisans.genyazilim.com/GenGoogleSync/GenGoogleSync.svc';
  defSvc  = 'GenGoogleSyncService';
  defPrt  = 'BasicHttpBinding_IGenGoogleSyncService';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IGenGoogleSyncService);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


procedure CalendarLogin2.SetCalendarID(Index: Integer; const Astring: string);
begin
  FCalendarID := Astring;
  FCalendarID_Specified := True;
end;

function CalendarLogin2.CalendarID_Specified(Index: Integer): boolean;
begin
  Result := FCalendarID_Specified;
end;

procedure CalendarLogin2.SetP12SecurityFile(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  FP12SecurityFile := ATByteDynArray;
  FP12SecurityFile_Specified := True;
end;

function CalendarLogin2.P12SecurityFile_Specified(Index: Integer): boolean;
begin
  Result := FP12SecurityFile_Specified;
end;

procedure CalendarLogin2.SetServiceAccountMailAddress(Index: Integer; const Astring: string);
begin
  FServiceAccountMailAddress := Astring;
  FServiceAccountMailAddress_Specified := True;
end;

function CalendarLogin2.ServiceAccountMailAddress_Specified(Index: Integer): boolean;
begin
  Result := FServiceAccountMailAddress_Specified;
end;

destructor CalendarEvent2.Destroy;
begin
  SysUtils.FreeAndNil(FStartDate);
  inherited Destroy;
end;

procedure CalendarEvent2.SetDescription(Index: Integer; const Astring: string);
begin
  FDescription := Astring;
  FDescription_Specified := True;
end;

function CalendarEvent2.Description_Specified(Index: Integer): boolean;
begin
  Result := FDescription_Specified;
end;

procedure CalendarEvent2.SetId(Index: Integer; const Astring: string);
begin
  FId := Astring;
  FId_Specified := True;
end;

function CalendarEvent2.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure CalendarEvent2.SetLocation(Index: Integer; const Astring: string);
begin
  FLocation := Astring;
  FLocation_Specified := True;
end;

function CalendarEvent2.Location_Specified(Index: Integer): boolean;
begin
  Result := FLocation_Specified;
end;

procedure CalendarEvent2.SetPatientName(Index: Integer; const Astring: string);
begin
  FPatientName := Astring;
  FPatientName_Specified := True;
end;

function CalendarEvent2.PatientName_Specified(Index: Integer): boolean;
begin
  Result := FPatientName_Specified;
end;

procedure CalendarEvent2.SetPatientPhone(Index: Integer; const Astring: string);
begin
  FPatientPhone := Astring;
  FPatientPhone_Specified := True;
end;

function CalendarEvent2.PatientPhone_Specified(Index: Integer): boolean;
begin
  Result := FPatientPhone_Specified;
end;

procedure CalendarEvent2.SetPeriod(Index: Integer; const ADouble: Double);
begin
  FPeriod := ADouble;
  FPeriod_Specified := True;
end;

function CalendarEvent2.Period_Specified(Index: Integer): boolean;
begin
  Result := FPeriod_Specified;
end;

procedure CalendarEvent2.SetSectionId(Index: Integer; const Astring: string);
begin
  FSectionId := Astring;
  FSectionId_Specified := True;
end;

function CalendarEvent2.SectionId_Specified(Index: Integer): boolean;
begin
  Result := FSectionId_Specified;
end;

procedure CalendarEvent2.SetStartDate(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  FStartDate := ATXSDateTime;
  FStartDate_Specified := True;
end;

function CalendarEvent2.StartDate_Specified(Index: Integer): boolean;
begin
  Result := FStartDate_Specified;
end;

procedure CalendarEvent2.SetSummary(Index: Integer; const Astring: string);
begin
  FSummary := Astring;
  FSummary_Specified := True;
end;

function CalendarEvent2.Summary_Specified(Index: Integer): boolean;
begin
  Result := FSummary_Specified;
end;

initialization
  { IGenGoogleSyncService }
  InvRegistry.RegisterInterface(TypeInfo(IGenGoogleSyncService), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IGenGoogleSyncService), 'http://tempuri.org/IGenGoogleSyncService/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IGenGoogleSyncService), ioDocument);
  { IGenGoogleSyncService.InsertCalendarEvent }
  InvRegistry.RegisterMethodInfo(TypeInfo(IGenGoogleSyncService), 'InsertCalendarEvent', '',
                                 '[ReturnName="InsertCalendarEventResult"]', IS_OPTN or IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'InsertCalendarEvent', '_CalendarLogin', '',
                                '[Namespace="http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"]', IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'InsertCalendarEvent', '_CalendarEvent', '',
                                '[Namespace="http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"]', IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'InsertCalendarEvent', 'InsertCalendarEventResult', '',
                                '', IS_NLBL);
  { IGenGoogleSyncService.DeleteCalendarEvent }
  InvRegistry.RegisterMethodInfo(TypeInfo(IGenGoogleSyncService), 'DeleteCalendarEvent', '',
                                 '[ReturnName="DeleteCalendarEventResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'DeleteCalendarEvent', '_CalendarLogin', '',
                                '[Namespace="http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"]', IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'DeleteCalendarEvent', '_EventId', '',
                                '', IS_NLBL);
  { IGenGoogleSyncService.UpdateCalendarEvent }
  InvRegistry.RegisterMethodInfo(TypeInfo(IGenGoogleSyncService), 'UpdateCalendarEvent', '',
                                 '[ReturnName="UpdateCalendarEventResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'UpdateCalendarEvent', '_CalendarLogin', '',
                                '[Namespace="http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"]', IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'UpdateCalendarEvent', '_CalendarEvent', '',
                                '[Namespace="http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"]', IS_NLBL);
  { IGenGoogleSyncService.GetCalendarEvent }
  InvRegistry.RegisterMethodInfo(TypeInfo(IGenGoogleSyncService), 'GetCalendarEvent', '',
                                 '[ReturnName="GetCalendarEventResult"]', IS_OPTN or IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'GetCalendarEvent', '_CalendarLogin', '',
                                '[Namespace="http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"]', IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'GetCalendarEvent', '_EventId', '',
                                '', IS_NLBL);
  InvRegistry.RegisterParamInfo(TypeInfo(IGenGoogleSyncService), 'GetCalendarEvent', 'GetCalendarEventResult', '',
                                '[Namespace="http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary"]', IS_NLBL);
  RemClassRegistry.RegisterXSClass(CalendarLogin2, 'http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary', 'CalendarLogin2', 'CalendarLogin');
  RemClassRegistry.RegisterXSClass(CalendarEvent2, 'http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary', 'CalendarEvent2', 'CalendarEvent');
  RemClassRegistry.RegisterXSClass(CalendarEvent, 'http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary', 'CalendarEvent');
  RemClassRegistry.RegisterXSClass(CalendarLogin, 'http://schemas.datacontract.org/2004/07/GenGoogleSyncServiceLibrary', 'CalendarLogin');

end.
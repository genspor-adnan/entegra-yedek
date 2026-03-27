// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ReferenceServices/Stakeholder?wsdl
//  >Import : http://its.saglik.gov.tr/ReferenceServices/Stakeholder?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ReferenceServices/Stakeholder?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (21/03/2012 15:09:06 - - $Rev: 25127 $)
// ************************************************************************ //

unit ItsServisStakeholder;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_UNQL = $0008;
  IS_ATTR = $0010;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]

  stakeholderRequest   = class;                 { "http://services.reference.its/"[Lit][GblCplx] }
  stakeholderResponse  = class;                 { "http://services.reference.its/"[Lit][GblCplx] }
  company              = class;                 { "http://services.reference.its/"[GblCplx] }
  referanceErrorType   = class;                 { "http://services.reference.its/"[GblCplx] }
  referenceError       = class;                 { "http://services.reference.its/"[Flt][GblElm] }
  request              = class;                 { "http://services.reference.its/"[Lit][GblElm] }
  response             = class;                 { "http://services.reference.its/"[Lit][GblElm] }



  // ************************************************************************ //
  // XML       : stakeholderRequest, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  stakeholderRequest = class(TRemotable)
  private
    FstakeholderType: string;
    FgetAll: Boolean;
    FcityPlate: string;
    FcityPlate_Specified: boolean;
    procedure SetcityPlate(Index: Integer; const Astring: string);
    function  cityPlate_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
  published
    property stakeholderType: string   Index (IS_UNQL) read FstakeholderType write FstakeholderType;
    property getAll:          Boolean  Index (IS_UNQL) read FgetAll write FgetAll;
    property cityPlate:       string   Index (IS_OPTN or IS_UNQL) read FcityPlate write SetcityPlate stored cityPlate_Specified;
  end;

  companies  = array of company;                { "http://services.reference.its/"[Cplx] }


  // ************************************************************************ //
  // XML       : stakeholderResponse, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  stakeholderResponse = class(TRemotable)
  private
    Fcompanies: companies;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property companies: companies  Index (IS_UNQL) read Fcompanies write Fcompanies;
  end;



  // ************************************************************************ //
  // XML       : company, global, <complexType>
  // Namespace : http://services.reference.its/
  // ************************************************************************ //
  company = class(TRemotable)
  private
    FisActive: Boolean;
    Fgln: string;
    FcompanyName: string;
    Fauthorized: string;
    Femail: string;
    Fphone: string;
    Fcity: string;
    Ftown: string;
    Faddress: string;
  published
    property isActive:    Boolean  Index (IS_ATTR) read FisActive write FisActive;
    property gln:         string   Index (IS_UNQL) read Fgln write Fgln;
    property companyName: string   Index (IS_UNQL) read FcompanyName write FcompanyName;
    property authorized:  string   Index (IS_UNQL) read Fauthorized write Fauthorized;
    property email:       string   Index (IS_UNQL) read Femail write Femail;
    property phone:       string   Index (IS_UNQL) read Fphone write Fphone;
    property city:        string   Index (IS_UNQL) read Fcity write Fcity;
    property town:        string   Index (IS_UNQL) read Ftown write Ftown;
    property address:     string   Index (IS_UNQL) read Faddress write Faddress;
  end;



  // ************************************************************************ //
  // XML       : referanceErrorType, global, <complexType>
  // Namespace : http://services.reference.its/
  // ************************************************************************ //
  referanceErrorType = class(TRemotable)
  private
    FfaultCode: string;
    FfaultMessage: string;
  published
    property faultCode:    string  Index (IS_UNQL) read FfaultCode write FfaultCode;
    property faultMessage: string  Index (IS_UNQL) read FfaultMessage write FfaultMessage;
  end;



  // ************************************************************************ //
  // XML       : referenceError, global, <element>
  // Namespace : http://services.reference.its/
  // Info      : Fault
  // Base Types: referanceErrorType
  // ************************************************************************ //
  referenceError = class(ERemotableException)
  private
    FfaultCode: string;
    FfaultMessage: string;
  published
    property faultCode:    string  Index (IS_UNQL) read FfaultCode write FfaultCode;
    property faultMessage: string  Index (IS_UNQL) read FfaultMessage write FfaultMessage;
  end;



  // ************************************************************************ //
  // XML       : request, global, <element>
  // Namespace : http://services.reference.its/
  // Info      : Wrapper
  // ************************************************************************ //
  request = class(stakeholderRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : response, global, <element>
  // Namespace : http://services.reference.its/
  // Info      : Wrapper
  // ************************************************************************ //
  response = class(stakeholderResponse)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://services.reference.its/
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : StakeholderPortBinding
  // service   : Stakeholder
  // port      : StakeholderPort
  // URL       : http://its.saglik.gov.tr:80/ReferenceServices/Stakeholder
  // ************************************************************************ //
  Stakeholder = interface(IInvokable)
  ['{BF16270D-4F4F-C644-3742-99EBF2BC5007}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  Stakeholder(const body: request): response; stdcall;
  end;

function GetStakeholder(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): Stakeholder;


implementation
  uses SysUtils;

function GetStakeholder(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): Stakeholder;
const
  defWSDL = 'http://its.saglik.gov.tr/ReferenceServices/Stakeholder?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ReferenceServices/Stakeholder';
  defSvc  = 'Stakeholder';
  defPrt  = 'StakeholderPort';
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
    Result := (RIO as Stakeholder);
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


constructor stakeholderRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

procedure stakeholderRequest.SetcityPlate(Index: Integer; const Astring: string);
begin
  FcityPlate := Astring;
  FcityPlate_Specified := True;
end;

function stakeholderRequest.cityPlate_Specified(Index: Integer): boolean;
begin
  Result := FcityPlate_Specified;
end;

constructor stakeholderResponse.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor stakeholderResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(Fcompanies)-1 do
    SysUtils.FreeAndNil(Fcompanies[I]);
  System.SetLength(Fcompanies, 0);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(Stakeholder), 'http://services.reference.its/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(Stakeholder), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(Stakeholder), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(Stakeholder), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(Stakeholder), 'Stakeholder', 'body1', 'body');
  RemClassRegistry.RegisterXSClass(stakeholderRequest, 'http://services.reference.its/', 'stakeholderRequest');
  RemClassRegistry.RegisterSerializeOptions(stakeholderRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(companies), 'http://services.reference.its/', 'companies');
  RemClassRegistry.RegisterXSClass(stakeholderResponse, 'http://services.reference.its/', 'stakeholderResponse');
  RemClassRegistry.RegisterSerializeOptions(stakeholderResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(company, 'http://services.reference.its/', 'company');
  RemClassRegistry.RegisterXSClass(referanceErrorType, 'http://services.reference.its/', 'referanceErrorType');
  RemClassRegistry.RegisterXSClass(referenceError, 'http://services.reference.its/', 'referenceError');
  RemClassRegistry.RegisterXSClass(request, 'http://services.reference.its/', 'request');
  RemClassRegistry.RegisterXSClass(response, 'http://services.reference.its/', 'response');

end.
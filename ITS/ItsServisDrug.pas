// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ReferenceServices/Drug?wsdl
//  >Import : http://its.saglik.gov.tr/ReferenceServices/Drug?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ReferenceServices/Drug?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (22/03/2012 13:25:00 - - $Rev: 25127 $)
// ************************************************************************ //

unit ItsServisDrug;

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
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]

  drugRequest          = class;                 { "http://services.reference.its/"[Lit][GblCplx] }
  drugResponse         = class;                 { "http://services.reference.its/"[Lit][GblCplx] }
  drug2                 = class;                 { "http://services.reference.its/"[GblCplx] }
  referanceErrorType   = class;                 { "http://services.reference.its/"[GblCplx] }
  referenceError       = class;                 { "http://services.reference.its/"[Flt][GblElm] }
  request              = class;                 { "http://services.reference.its/"[Lit][GblElm] }
  response             = class;                 { "http://services.reference.its/"[Lit][GblElm] }



  // ************************************************************************ //
  // XML       : drugRequest, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  drugRequest = class(TRemotable)
  private
    FgetAll: Boolean;
  public
    constructor Create; override;
  published
    property getAll: Boolean  Index (IS_UNQL) read FgetAll write FgetAll;
  end;

  drugs      = array of drug2;                   { "http://services.reference.its/"[Cplx] }


  // ************************************************************************ //
  // XML       : drugResponse, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  drugResponse = class(TRemotable)
  private
    Fdrugs: drugs;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property drugs: drugs  Index (IS_UNQL) read Fdrugs write Fdrugs;
  end;



  // ************************************************************************ //
  // XML       : drug, global, <complexType>
  // Namespace : http://services.reference.its/
  // ************************************************************************ //
  drug2 = class(TRemotable)
  private
    FisActive: Boolean;
    Fgtin: string;
    FdrugName: string;
    FmanufacturerGLN: string;
    FmanufacturerName: string;
    FisImported: Boolean;
  published
    property isActive:         Boolean  Index (IS_ATTR) read FisActive write FisActive;
    property gtin:             string   Index (IS_UNQL) read Fgtin write Fgtin;
    property drugName:         string   Index (IS_UNQL) read FdrugName write FdrugName;
    property manufacturerGLN:  string   Index (IS_UNQL) read FmanufacturerGLN write FmanufacturerGLN;
    property manufacturerName: string   Index (IS_UNQL) read FmanufacturerName write FmanufacturerName;
    property isImported:       Boolean  Index (IS_UNQL) read FisImported write FisImported;
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
  request = class(drugRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : response, global, <element>
  // Namespace : http://services.reference.its/
  // Info      : Wrapper
  // ************************************************************************ //
  response = class(drugResponse)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://services.reference.its/
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DrugPortBinding
  // service   : Drug
  // port      : DrugPort
  // URL       : http://its.saglik.gov.tr:80/ReferenceServices/Drug
  // ************************************************************************ //
  Drug = interface(IInvokable)
  ['{2F0177A1-4484-044E-16D3-623E48B28E02}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  Drug(const body: request): response; stdcall;
  end;

function GetDrug(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): Drug;


implementation
  uses SysUtils;

function GetDrug(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): Drug;
const
  defWSDL = 'http://its.saglik.gov.tr/ReferenceServices/Drug?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ReferenceServices/Drug';
  defSvc  = 'Drug';
  defPrt  = 'DrugPort';
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
    Result := (RIO as Drug);
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


constructor drugRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

constructor drugResponse.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor drugResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(Fdrugs)-1 do
    SysUtils.FreeAndNil(Fdrugs[I]);
  System.SetLength(Fdrugs, 0);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(Drug), 'http://services.reference.its/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(Drug), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(Drug), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(Drug), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(Drug), 'Drug', 'body1', 'body');
  RemClassRegistry.RegisterXSClass(drugRequest, 'http://services.reference.its/', 'drugRequest');
  RemClassRegistry.RegisterSerializeOptions(drugRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(drugs), 'http://services.reference.its/', 'drugs');
  RemClassRegistry.RegisterXSClass(drugResponse, 'http://services.reference.its/', 'drugResponse');
  RemClassRegistry.RegisterSerializeOptions(drugResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(drug2, 'http://services.reference.its/', 'drug');
  RemClassRegistry.RegisterXSClass(referanceErrorType, 'http://services.reference.its/', 'referanceErrorType');
  RemClassRegistry.RegisterXSClass(referenceError, 'http://services.reference.its/', 'referenceError');
  RemClassRegistry.RegisterXSClass(request, 'http://services.reference.its/', 'request');
  RemClassRegistry.RegisterXSClass(response, 'http://services.reference.its/', 'response');

end.
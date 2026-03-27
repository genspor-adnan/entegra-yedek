// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ReferenceServices/ErrorCode?wsdl
//  >Import : http://its.saglik.gov.tr/ReferenceServices/ErrorCode?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ReferenceServices/ErrorCode?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (22/03/2012 17:19:03 - - $Rev: 25127 $)
// ************************************************************************ //

unit ItsServisError;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_UNQL = $0008;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]

  errorCodeRequest     = class;                 { "http://services.reference.its/"[Lit][GblCplx] }
  errorCodeResponse    = class;                 { "http://services.reference.its/"[Lit][GblCplx] }
  errorCode2            = class;                 { "http://services.reference.its/"[GblCplx] }
  referanceErrorType   = class;                 { "http://services.reference.its/"[GblCplx] }
  referenceError       = class;                 { "http://services.reference.its/"[Flt][GblElm] }
  request              = class;                 { "http://services.reference.its/"[Lit][GblElm] }
  response             = class;                 { "http://services.reference.its/"[Lit][GblElm] }



  // ************************************************************************ //
  // XML       : errorCodeRequest, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  errorCodeRequest = class(TRemotable)
  private
  public
    constructor Create; override;
  published
  end;

  errorCodes = array of errorCode2;              { "http://services.reference.its/"[Cplx] }


  // ************************************************************************ //
  // XML       : errorCodeResponse, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  errorCodeResponse = class(TRemotable)
  private
    FerrorCodes: errorCodes;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property errorCodes: errorCodes  Index (IS_UNQL) read FerrorCodes write FerrorCodes;
  end;



  // ************************************************************************ //
  // XML       : errorCode, global, <complexType>
  // Namespace : http://services.reference.its/
  // ************************************************************************ //
  errorCode2 = class(TRemotable)
  private
    Ftype_: string;
    Fcode: string;
    Fmessage_: string;
    Fdescription: string;
  published
    property type_:       string  Index (IS_UNQL) read Ftype_ write Ftype_;
    property code:        string  Index (IS_UNQL) read Fcode write Fcode;
    property message_:    string  Index (IS_UNQL) read Fmessage_ write Fmessage_;
    property description: string  Index (IS_UNQL) read Fdescription write Fdescription;
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
  request = class(errorCodeRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : response, global, <element>
  // Namespace : http://services.reference.its/
  // Info      : Wrapper
  // ************************************************************************ //
  response = class(errorCodeResponse)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://services.reference.its/
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : ErrorCodePortBinding
  // service   : ErrorCode
  // port      : ErrorCodePort
  // URL       : http://its.saglik.gov.tr:80/ReferenceServices/ErrorCode
  // ************************************************************************ //
  ErrorCode = interface(IInvokable)
  ['{F6A5E6AB-795B-A1E2-BAAE-B425B2ADC426}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  getErrorCodes(const body: request): response; stdcall;
  end;

function GetErrorCode(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): ErrorCode;


implementation
  uses SysUtils;

function GetErrorCode(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): ErrorCode;
const
  defWSDL = 'http://its.saglik.gov.tr/ReferenceServices/ErrorCode?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ReferenceServices/ErrorCode';
  defSvc  = 'ErrorCode';
  defPrt  = 'ErrorCodePort';
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
    Result := (RIO as ErrorCode);
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


constructor errorCodeRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

constructor errorCodeResponse.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor errorCodeResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FerrorCodes)-1 do
    SysUtils.FreeAndNil(FerrorCodes[I]);
  System.SetLength(FerrorCodes, 0);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(ErrorCode), 'http://services.reference.its/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(ErrorCode), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(ErrorCode), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(ErrorCode), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(ErrorCode), 'getErrorCodes', 'body1', 'body');
  RemClassRegistry.RegisterXSClass(errorCodeRequest, 'http://services.reference.its/', 'errorCodeRequest');
  RemClassRegistry.RegisterSerializeOptions(errorCodeRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(errorCodes), 'http://services.reference.its/', 'errorCodes');
  RemClassRegistry.RegisterXSClass(errorCodeResponse, 'http://services.reference.its/', 'errorCodeResponse');
  RemClassRegistry.RegisterSerializeOptions(errorCodeResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(errorCode2, 'http://services.reference.its/', 'errorCode');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(errorCode2), 'type_', 'type');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(errorCode2), 'message_', 'message');
  RemClassRegistry.RegisterXSClass(referanceErrorType, 'http://services.reference.its/', 'referanceErrorType');
  RemClassRegistry.RegisterXSClass(referenceError, 'http://services.reference.its/', 'referenceError');
  RemClassRegistry.RegisterXSClass(request, 'http://services.reference.its/', 'request');
  RemClassRegistry.RegisterXSClass(response, 'http://services.reference.its/', 'response');

end.
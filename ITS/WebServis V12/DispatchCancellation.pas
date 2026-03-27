// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ITSServices/DispatchCancellation?wsdl
//  >Import : http://its.saglik.gov.tr/ITSServices/DispatchCancellation?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ITSServices/DispatchCancellation?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/12/2012 14:20:45 - - $Rev: 25127 $)
// ************************************************************************ //

unit DispatchCancellation;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_UNBD = $0002;
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
  // !:date            - "http://www.w3.org/2001/XMLSchema"[Gbl]

  ItsPlainRequest      = class;                 { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Lit][GblCplx] }
  PRODUCT              = class;                 { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Cplx] }
  ItsResponse          = class;                 { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Lit][GblCplx] }
  PRODUCT2             = class;                 { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Cplx] }
  itsErrorType         = class;                 { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[GblCplx] }
  DispatchCancellationRequest = class;          { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Lit][GblElm] }
  DispatchCancellationResponse = class;         { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Lit][GblElm] }
  itsError             = class;                 { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Flt][GblElm] }

  PRODUCTS   = array of PRODUCT;                { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsPlainRequest, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ItsPlainRequest = class(TRemotable)
  private
    FPRODUCTS: PRODUCTS;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property PRODUCTS: PRODUCTS  Index (IS_UNQL) read FPRODUCTS write FPRODUCTS;
  end;



  // ************************************************************************ //
  // XML       : PRODUCT, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // ************************************************************************ //
  PRODUCT = class(TRemotable)
  private
    FGTIN: string;
    FBN: string;
    FSN: string;
    FXD: TXSDate;
  public
    destructor Destroy; override;
  published
    property GTIN: string   Index (IS_UNQL) read FGTIN write FGTIN;
    property BN:   string   Index (IS_UNQL) read FBN write FBN;
    property SN:   string   Index (IS_UNQL) read FSN write FSN;
    property XD:   TXSDate  Index (IS_UNQL) read FXD write FXD;
  end;

  PRODUCTS2  = array of PRODUCT2;               { "http://its.iegm.gov.tr/p2/cancellation/dispatch"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsResponse, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ItsResponse = class(TRemotable)
  private
    FNOTIFICATIONID: string;
    FPRODUCTS: PRODUCTS2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property NOTIFICATIONID: string     Index (IS_UNQL) read FNOTIFICATIONID write FNOTIFICATIONID;
    property PRODUCTS:       PRODUCTS2  Index (IS_UNQL) read FPRODUCTS write FPRODUCTS;
  end;



  // ************************************************************************ //
  // XML       : PRODUCT, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // ************************************************************************ //
  PRODUCT2 = class(TRemotable)
  private
    FGTIN: string;
    FSN: string;
    FUC: string;
  published
    property GTIN: string  Index (IS_UNQL) read FGTIN write FGTIN;
    property SN:   string  Index (IS_UNQL) read FSN write FSN;
    property UC:   string  Index (IS_UNQL) read FUC write FUC;
  end;



  // ************************************************************************ //
  // XML       : itsErrorType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // ************************************************************************ //
  itsErrorType = class(TRemotable)
  private
    FfaultCode: string;
    FfaultMessage: string;
  published
    property faultCode:    string  Index (IS_UNQL) read FfaultCode write FfaultCode;
    property faultMessage: string  Index (IS_UNQL) read FfaultMessage write FfaultMessage;
  end;



  // ************************************************************************ //
  // XML       : DispatchCancellationRequest, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // Info      : Wrapper
  // ************************************************************************ //
  DispatchCancellationRequest = class(ItsPlainRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DispatchCancellationResponse, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // Info      : Wrapper
  // ************************************************************************ //
  DispatchCancellationResponse = class(ItsResponse)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : itsError, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // Info      : Fault
  // Base Types: itsErrorType
  // ************************************************************************ //
  itsError = class(ERemotableException)
  private
    FfaultCode: string;
    FfaultMessage: string;
  published
    property faultCode:    string  Index (IS_UNQL) read FfaultCode write FfaultCode;
    property faultMessage: string  Index (IS_UNQL) read FfaultMessage write FfaultMessage;
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/p2/cancellation/dispatch
  // soapAction: http://its.iegm.gov.tr/p2/cancellation/dispatch/ItsRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DispatchCancellationPortBinding
  // service   : DispatchCancellation
  // port      : DispatchCancellationPort
  // URL       : http://its.saglik.gov.tr:80/ITSServices/DispatchCancellation
  // ************************************************************************ //
  DispatchCancellationReceiver = interface(IInvokable)
  ['{710BE031-9EE9-BEA2-E5EE-E3F7CFDF9756}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  sendDispatchCancellation(const body: DispatchCancellationRequest): DispatchCancellationResponse; stdcall;
  end;

function GetDispatchCancellationReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DispatchCancellationReceiver;


implementation
  uses SysUtils;

function GetDispatchCancellationReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DispatchCancellationReceiver;
const
  defWSDL = 'http://its.saglik.gov.tr/ITSServices/DispatchCancellation?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ITSServices/DispatchCancellation';
  defSvc  = 'DispatchCancellation';
  defPrt  = 'DispatchCancellationPort';
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
    Result := (RIO as DispatchCancellationReceiver);
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


constructor ItsPlainRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor ItsPlainRequest.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FPRODUCTS)-1 do
    SysUtils.FreeAndNil(FPRODUCTS[I]);
  System.SetLength(FPRODUCTS, 0);
  inherited Destroy;
end;

destructor PRODUCT.Destroy;
begin
  SysUtils.FreeAndNil(FXD);
  inherited Destroy;
end;

constructor ItsResponse.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor ItsResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FPRODUCTS)-1 do
    SysUtils.FreeAndNil(FPRODUCTS[I]);
  System.SetLength(FPRODUCTS, 0);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(DispatchCancellationReceiver), 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DispatchCancellationReceiver), 'http://its.iegm.gov.tr/p2/cancellation/dispatch/ItsRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(DispatchCancellationReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(DispatchCancellationReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(DispatchCancellationReceiver), 'sendDispatchCancellation', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS), 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsPlainRequest, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'ItsPlainRequest');
  RemClassRegistry.RegisterSerializeOptions(ItsPlainRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'PRODUCT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS2), 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'PRODUCTS2', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsResponse, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'ItsResponse');
  RemClassRegistry.RegisterSerializeOptions(ItsResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT2, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'PRODUCT2', 'PRODUCT');
  RemClassRegistry.RegisterXSClass(itsErrorType, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'itsErrorType');
  RemClassRegistry.RegisterXSClass(DispatchCancellationRequest, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'DispatchCancellationRequest');
  RemClassRegistry.RegisterXSClass(DispatchCancellationResponse, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'DispatchCancellationResponse');
  RemClassRegistry.RegisterXSClass(itsError, 'http://its.iegm.gov.tr/p2/cancellation/dispatch', 'itsError');

end.
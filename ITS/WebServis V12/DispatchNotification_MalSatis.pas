// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr:80/ITSServices/DispatchNotification?wsdl
//  >Import : http://its.saglik.gov.tr:80/ITSServices/DispatchNotification?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ITSServices/DispatchNotification?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/12/2012 14:15:58 - - $Rev: 25127 $)
// ************************************************************************ //

unit DispatchNotification_MalSatis;

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

  ItsRequest           = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[Lit][GblCplx] }
  PRODUCT              = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[Cplx] }
  ItsResponse          = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[Lit][GblCplx] }
  PRODUCT2             = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[Cplx] }
  itsErrorType         = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[GblCplx] }
  DispatchRequest      = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[Lit][GblElm] }
  DispatchResponse     = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[Lit][GblElm] }
  itsError             = class;                 { "http://its.iegm.gov.tr/p2/notification/dispatch"[Flt][GblElm] }

  PRODUCTS   = array of PRODUCT;                { "http://its.iegm.gov.tr/p2/notification/dispatch"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsRequest, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ItsRequest = class(TRemotable)
  private
    FTOGLN: string;
    FPRODUCTS: PRODUCTS;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property TOGLN:    string    Index (IS_UNQL) read FTOGLN write FTOGLN;
    property PRODUCTS: PRODUCTS  Index (IS_UNQL) read FPRODUCTS write FPRODUCTS;
  end;



  // ************************************************************************ //
  // XML       : PRODUCT, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
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

  PRODUCTS2  = array of PRODUCT2;               { "http://its.iegm.gov.tr/p2/notification/dispatch"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsResponse, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
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
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
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
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
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
  // XML       : DispatchRequest, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
  // Info      : Wrapper
  // ************************************************************************ //
  DispatchRequest = class(ItsRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DispatchResponse, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
  // Info      : Wrapper
  // ************************************************************************ //
  DispatchResponse = class(ItsResponse)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : itsError, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
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
  // Namespace : http://its.iegm.gov.tr/p2/notification/dispatch
  // soapAction: http://its.iegm.gov.tr/p2/notification/dispatch/ItsRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DispatchNotificationPortBinding
  // service   : DispatchNotification
  // port      : DispatchNotificationPort
  // URL       : http://its.saglik.gov.tr:80/ITSServices/DispatchNotification
  // ************************************************************************ //
  DispatchNotificationReceiver = interface(IInvokable)
  ['{6D031C75-078E-201F-B298-3DD2053C7B1F}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  sendDispatchNotification(const body: DispatchRequest): DispatchResponse; stdcall;
  end;

function GetDispatchNotificationReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DispatchNotificationReceiver;


implementation
  uses SysUtils;

function GetDispatchNotificationReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DispatchNotificationReceiver;
const
  defWSDL = 'http://its.saglik.gov.tr:80/ITSServices/DispatchNotification?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ITSServices/DispatchNotification';
  defSvc  = 'DispatchNotification';
  defPrt  = 'DispatchNotificationPort';
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
    Result := (RIO as DispatchNotificationReceiver);
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


constructor ItsRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor ItsRequest.Destroy;
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
  InvRegistry.RegisterInterface(TypeInfo(DispatchNotificationReceiver), 'http://its.iegm.gov.tr/p2/notification/dispatch', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DispatchNotificationReceiver), 'http://its.iegm.gov.tr/p2/notification/dispatch/ItsRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(DispatchNotificationReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(DispatchNotificationReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(DispatchNotificationReceiver), 'sendDispatchNotification', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS), 'http://its.iegm.gov.tr/p2/notification/dispatch', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsRequest, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'ItsRequest');
  RemClassRegistry.RegisterSerializeOptions(ItsRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'PRODUCT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS2), 'http://its.iegm.gov.tr/p2/notification/dispatch', 'PRODUCTS2', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsResponse, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'ItsResponse');
  RemClassRegistry.RegisterSerializeOptions(ItsResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT2, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'PRODUCT2', 'PRODUCT');
  RemClassRegistry.RegisterXSClass(itsErrorType, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'itsErrorType');
  RemClassRegistry.RegisterXSClass(DispatchRequest, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'DispatchRequest');
  RemClassRegistry.RegisterXSClass(DispatchResponse, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'DispatchResponse');
  RemClassRegistry.RegisterXSClass(itsError, 'http://its.iegm.gov.tr/p2/notification/dispatch', 'itsError');

end.
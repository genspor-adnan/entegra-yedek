// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ITSServices/ReturnNotification?wsdl
//  >Import : http://its.saglik.gov.tr/ITSServices/ReturnNotification?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ITSServices/ReturnNotification?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/12/2012 14:19:19 - - $Rev: 25127 $)
// ************************************************************************ //

unit ReturnNotification_MalIade;

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

  ItsRequest           = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[Lit][GblCplx] }
  PRODUCT              = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[Cplx] }
  ItsResponse          = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[Lit][GblCplx] }
  PRODUCT2             = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[Cplx] }
  itsErrorType         = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[GblCplx] }
  ReturnRequest        = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[Lit][GblElm] }
  ReturnResponse       = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[Lit][GblElm] }
  itsError             = class;                 { "http://its.iegm.gov.tr/p2/notification/return"[Flt][GblElm] }

  PRODUCTS   = array of PRODUCT;                { "http://its.iegm.gov.tr/p2/notification/return"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsRequest, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
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
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
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

  PRODUCTS2  = array of PRODUCT2;               { "http://its.iegm.gov.tr/p2/notification/return"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsResponse, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
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
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
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
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
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
  // XML       : ReturnRequest, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
  // Info      : Wrapper
  // ************************************************************************ //
  ReturnRequest = class(ItsRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ReturnResponse, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
  // Info      : Wrapper
  // ************************************************************************ //
  ReturnResponse = class(ItsResponse)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : itsError, global, <element>
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
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
  // Namespace : http://its.iegm.gov.tr/p2/notification/return
  // soapAction: http://its.iegm.gov.tr/p2/notification/return/ItsRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : ReturnNotificationPortBinding
  // service   : ReturnNotification
  // port      : ReturnNotificationPort
  // URL       : http://its.saglik.gov.tr:80/ITSServices/ReturnNotification
  // ************************************************************************ //
  ReturnNotificationReceiver = interface(IInvokable)
  ['{F09BA756-49FB-20DF-3BD9-9F8CC397CAF9}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  sendReturnNotification(const body: ReturnRequest): ReturnResponse; stdcall;
  end;

function GetReturnNotificationReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): ReturnNotificationReceiver;


implementation
  uses SysUtils;

function GetReturnNotificationReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): ReturnNotificationReceiver;
const
  defWSDL = 'http://its.saglik.gov.tr/ITSServices/ReturnNotification?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ITSServices/ReturnNotification';
  defSvc  = 'ReturnNotification';
  defPrt  = 'ReturnNotificationPort';
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
    Result := (RIO as ReturnNotificationReceiver);
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
  InvRegistry.RegisterInterface(TypeInfo(ReturnNotificationReceiver), 'http://its.iegm.gov.tr/p2/notification/return', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(ReturnNotificationReceiver), 'http://its.iegm.gov.tr/p2/notification/return/ItsRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(ReturnNotificationReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(ReturnNotificationReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(ReturnNotificationReceiver), 'sendReturnNotification', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS), 'http://its.iegm.gov.tr/p2/notification/return', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsRequest, 'http://its.iegm.gov.tr/p2/notification/return', 'ItsRequest');
  RemClassRegistry.RegisterSerializeOptions(ItsRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT, 'http://its.iegm.gov.tr/p2/notification/return', 'PRODUCT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS2), 'http://its.iegm.gov.tr/p2/notification/return', 'PRODUCTS2', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsResponse, 'http://its.iegm.gov.tr/p2/notification/return', 'ItsResponse');
  RemClassRegistry.RegisterSerializeOptions(ItsResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT2, 'http://its.iegm.gov.tr/p2/notification/return', 'PRODUCT2', 'PRODUCT');
  RemClassRegistry.RegisterXSClass(itsErrorType, 'http://its.iegm.gov.tr/p2/notification/return', 'itsErrorType');
  RemClassRegistry.RegisterXSClass(ReturnRequest, 'http://its.iegm.gov.tr/p2/notification/return', 'ReturnRequest');
  RemClassRegistry.RegisterXSClass(ReturnResponse, 'http://its.iegm.gov.tr/p2/notification/return', 'ReturnResponse');
  RemClassRegistry.RegisterXSClass(itsError, 'http://its.iegm.gov.tr/p2/notification/return', 'itsError');

end.
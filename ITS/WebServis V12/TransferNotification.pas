// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ITSServices/TransferNotification?wsdl
//  >Import : http://its.saglik.gov.tr/ITSServices/TransferNotification?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ITSServices/TransferNotification?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/12/2012 14:21:19 - - $Rev: 25127 $)
// ************************************************************************ //

unit TransferNotification;

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

  ItsRequest           = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Lit][GblCplx] }
  PRODUCT              = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Cplx] }
  ItsResponse          = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Lit][GblCplx] }
  PRODUCT2             = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Cplx] }
  itsErrorType         = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[GblCplx] }
  TransferRequest      = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Lit][GblElm] }
  TransferResponse     = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Lit][GblElm] }
  itsError             = class;                 { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Flt][GblElm] }

  PRODUCTS   = array of PRODUCT;                { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsRequest, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
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
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
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

  PRODUCTS2  = array of PRODUCT2;               { "http://its.iegm.gov.tr/notification/BR/v1/Transfer/General"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsResponse, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
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
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
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
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
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
  // XML       : TransferRequest, global, <element>
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
  // Info      : Wrapper
  // ************************************************************************ //
  TransferRequest = class(ItsRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : TransferResponse, global, <element>
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
  // Info      : Wrapper
  // ************************************************************************ //
  TransferResponse = class(ItsResponse)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : itsError, global, <element>
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
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
  // Namespace : http://its.iegm.gov.tr/notification/BR/v1/Transfer/General
  // soapAction: http://its.iegm.gov.tr/notification/NotificationReceiver/v1/Transfer/ItsRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : TransferNotificationReceiverBindingPortBinding
  // service   : TransferNotification
  // port      : TransferNotificationReceiverBindingPort
  // URL       : http://its.saglik.gov.tr:80/ITSServices/TransferNotification
  // ************************************************************************ //
  TransferNotificationReceiver = interface(IInvokable)
  ['{5F4F50D0-E7C4-9A43-C790-7B93A39AC985}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  sendTransferNotification(const body: TransferRequest): TransferResponse; stdcall;
  end;

function GetTransferNotificationReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): TransferNotificationReceiver;


implementation
  uses SysUtils;

function GetTransferNotificationReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): TransferNotificationReceiver;
const
  defWSDL = 'http://its.saglik.gov.tr/ITSServices/TransferNotification?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ITSServices/TransferNotification';
  defSvc  = 'TransferNotification';
  defPrt  = 'TransferNotificationReceiverBindingPort';
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
    Result := (RIO as TransferNotificationReceiver);
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
  InvRegistry.RegisterInterface(TypeInfo(TransferNotificationReceiver), 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(TransferNotificationReceiver), 'http://its.iegm.gov.tr/notification/NotificationReceiver/v1/Transfer/ItsRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(TransferNotificationReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(TransferNotificationReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(TransferNotificationReceiver), 'sendTransferNotification', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS), 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsRequest, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'ItsRequest');
  RemClassRegistry.RegisterSerializeOptions(ItsRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'PRODUCT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS2), 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'PRODUCTS2', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsResponse, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'ItsResponse');
  RemClassRegistry.RegisterSerializeOptions(ItsResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT2, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'PRODUCT2', 'PRODUCT');
  RemClassRegistry.RegisterXSClass(itsErrorType, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'itsErrorType');
  RemClassRegistry.RegisterXSClass(TransferRequest, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'TransferRequest');
  RemClassRegistry.RegisterXSClass(TransferResponse, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'TransferResponse');
  RemClassRegistry.RegisterXSClass(itsError, 'http://its.iegm.gov.tr/notification/BR/v1/Transfer/General', 'itsError');

end.
// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ITSServices/ReceiptNotification?wsdl
//  >Import : http://its.saglik.gov.tr/ITSServices/ReceiptNotification?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ITSServices/ReceiptNotification?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/12/2012 14:18:31 - - $Rev: 25127 $)
// ************************************************************************ //

unit ReceiptNotification_MalAlim;

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

  ItsPlainRequest      = class;                 { "http://its.iegm.gov.tr/notification/receipt"[Lit][GblCplx] }
  PRODUCT              = class;                 { "http://its.iegm.gov.tr/notification/receipt"[Cplx] }
  ItsResponse          = class;                 { "http://its.iegm.gov.tr/notification/receipt"[Lit][GblCplx] }
  PRODUCT2             = class;                 { "http://its.iegm.gov.tr/notification/receipt"[Cplx] }
  itsErrorType         = class;                 { "http://its.iegm.gov.tr/notification/receipt"[GblCplx] }
  ReceiptRequest       = class;                 { "http://its.iegm.gov.tr/notification/receipt"[Lit][GblElm] }
  ReceiptResponse      = class;                 { "http://its.iegm.gov.tr/notification/receipt"[Lit][GblElm] }
  itsError             = class;                 { "http://its.iegm.gov.tr/notification/receipt"[Flt][GblElm] }

  PRODUCTS   = array of PRODUCT;                { "http://its.iegm.gov.tr/notification/receipt"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsPlainRequest, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/notification/receipt
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
  // Namespace : http://its.iegm.gov.tr/notification/receipt
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

  PRODUCTS2  = array of PRODUCT2;               { "http://its.iegm.gov.tr/notification/receipt"[Cplx] }


  // ************************************************************************ //
  // XML       : ItsResponse, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/notification/receipt
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
  // Namespace : http://its.iegm.gov.tr/notification/receipt
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
  // Namespace : http://its.iegm.gov.tr/notification/receipt
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
  // XML       : ReceiptRequest, global, <element>
  // Namespace : http://its.iegm.gov.tr/notification/receipt
  // Info      : Wrapper
  // ************************************************************************ //
  ReceiptRequest = class(ItsPlainRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ReceiptResponse, global, <element>
  // Namespace : http://its.iegm.gov.tr/notification/receipt
  // Info      : Wrapper
  // ************************************************************************ //
  ReceiptResponse = class(ItsResponse)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : itsError, global, <element>
  // Namespace : http://its.iegm.gov.tr/notification/receipt
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
  // Namespace : http://its.iegm.gov.tr/notification/receipt
  // soapAction: http://its.iegm.gov.tr/notification/receipt/ItsRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : ReceiptNotificationPortBinding
  // service   : ReceiptNotification
  // port      : ReceiptNotificationPort
  // URL       : http://its.saglik.gov.tr:80/ITSServices/ReceiptNotification
  // ************************************************************************ //
  ReceiptNotificationReceiver = interface(IInvokable)
  ['{035B89B6-9F60-83F3-DA58-FDC4CCC0DDA0}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  sendReceiptNotification(const body: ReceiptRequest): ReceiptResponse; stdcall;
  end;

function GetReceiptNotificationReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): ReceiptNotificationReceiver;


implementation
  uses SysUtils;

function GetReceiptNotificationReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): ReceiptNotificationReceiver;
const
  defWSDL = 'http://its.saglik.gov.tr/ITSServices/ReceiptNotification?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ITSServices/ReceiptNotification';
  defSvc  = 'ReceiptNotification';
  defPrt  = 'ReceiptNotificationPort';
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
    Result := (RIO as ReceiptNotificationReceiver);
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
  InvRegistry.RegisterInterface(TypeInfo(ReceiptNotificationReceiver), 'http://its.iegm.gov.tr/notification/receipt', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(ReceiptNotificationReceiver), 'http://its.iegm.gov.tr/notification/receipt/ItsRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(ReceiptNotificationReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(ReceiptNotificationReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(ReceiptNotificationReceiver), 'sendReceiptNotification', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS), 'http://its.iegm.gov.tr/notification/receipt', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsPlainRequest, 'http://its.iegm.gov.tr/notification/receipt', 'ItsPlainRequest');
  RemClassRegistry.RegisterSerializeOptions(ItsPlainRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT, 'http://its.iegm.gov.tr/notification/receipt', 'PRODUCT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PRODUCTS2), 'http://its.iegm.gov.tr/notification/receipt', 'PRODUCTS2', 'PRODUCTS');
  RemClassRegistry.RegisterXSClass(ItsResponse, 'http://its.iegm.gov.tr/notification/receipt', 'ItsResponse');
  RemClassRegistry.RegisterSerializeOptions(ItsResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PRODUCT2, 'http://its.iegm.gov.tr/notification/receipt', 'PRODUCT2', 'PRODUCT');
  RemClassRegistry.RegisterXSClass(itsErrorType, 'http://its.iegm.gov.tr/notification/receipt', 'itsErrorType');
  RemClassRegistry.RegisterXSClass(ReceiptRequest, 'http://its.iegm.gov.tr/notification/receipt', 'ReceiptRequest');
  RemClassRegistry.RegisterXSClass(ReceiptResponse, 'http://its.iegm.gov.tr/notification/receipt', 'ReceiptResponse');
  RemClassRegistry.RegisterXSClass(itsError, 'http://its.iegm.gov.tr/notification/receipt', 'itsError');

end.
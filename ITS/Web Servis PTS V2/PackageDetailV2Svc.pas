// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/ReferenceServices/PackageDetail?wsdl
//  >Import : http://its.saglik.gov.tr/ReferenceServices/PackageDetail?wsdl>0
//  >Import : http://its.saglik.gov.tr:80/ReferenceServices/PackageDetail?xsd=1
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (25/01/2013 14:04:32 - - $Rev: 25127 $)
// ************************************************************************ //

unit PackageDetailV2Svc;

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
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:date            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:long            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]

  packageDetailRequest = class;                 { "http://services.reference.its/"[Lit][GblCplx] }
  packageDetailResponse = class;                { "http://services.reference.its/"[Lit][GblCplx] }
  transferDetail       = class;                 { "http://services.reference.its/"[GblCplx] }
  referanceErrorType   = class;                 { "http://services.reference.its/"[GblCplx] }
  referenceError       = class;                 { "http://services.reference.its/"[Flt][GblElm] }
  request              = class;                 { "http://services.reference.its/"[Lit][GblElm] }
  response             = class;                 { "http://services.reference.its/"[Lit][GblElm] }



  // ************************************************************************ //
  // XML       : packageDetailRequest, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  packageDetailRequest = class(TRemotable)
  private
    Fsender: string;
    Freceiver: string;
    FbringNotReceivedTransferInfo: Boolean;
    FstartDate: TXSDate;
    FendDate: TXSDate;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property sender:                       string   Index (IS_UNQL) read Fsender write Fsender;
    property receiver:                     string   Index (IS_UNQL) read Freceiver write Freceiver;
    property bringNotReceivedTransferInfo: Boolean  Index (IS_UNQL) read FbringNotReceivedTransferInfo write FbringNotReceivedTransferInfo;
    property startDate:                    TXSDate  Index (IS_UNQL) read FstartDate write FstartDate;
    property endDate:                      TXSDate  Index (IS_UNQL) read FendDate write FendDate;
  end;

  transferDetails = array of transferDetail;    { "http://services.reference.its/"[Cplx] }


  // ************************************************************************ //
  // XML       : packageDetailResponse, global, <complexType>
  // Namespace : http://services.reference.its/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  packageDetailResponse = class(TRemotable)
  private
    FtransferDetails: transferDetails;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property transferDetails: transferDetails  Index (IS_UNQL) read FtransferDetails write FtransferDetails;
  end;



  // ************************************************************************ //
  // XML       : transferDetail, global, <complexType>
  // Namespace : http://services.reference.its/
  // ************************************************************************ //
  transferDetail = class(TRemotable)
  private
    FsenderGln: string;
    FreceiverGln: string;
    FtransferId: Int64;
    FsendDate: TXSDateTime;
    FfirstTransferDate: TXSDateTime;
    FlastTransferDate: TXSDateTime;
    Fmd5Checksum: string;
  public
    destructor Destroy; override;
  published
    property senderGln:         string       Index (IS_UNQL) read FsenderGln write FsenderGln;
    property receiverGln:       string       Index (IS_UNQL) read FreceiverGln write FreceiverGln;
    property transferId:        Int64        Index (IS_UNQL) read FtransferId write FtransferId;
    property sendDate:          TXSDateTime  Index (IS_UNQL) read FsendDate write FsendDate;
    property firstTransferDate: TXSDateTime  Index (IS_UNQL) read FfirstTransferDate write FfirstTransferDate;
    property lastTransferDate:  TXSDateTime  Index (IS_UNQL) read FlastTransferDate write FlastTransferDate;
    property md5Checksum:       string       Index (IS_UNQL) read Fmd5Checksum write Fmd5Checksum;
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
  request = class(packageDetailRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : response, global, <element>
  // Namespace : http://services.reference.its/
  // Info      : Wrapper
  // ************************************************************************ //
  response = class(packageDetailResponse)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://services.reference.its/
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : PackageDetailPortBinding
  // service   : PackageDetail
  // port      : PackageDetailPort
  // URL       : http://its.saglik.gov.tr:80/ReferenceServices/PackageDetail
  // ************************************************************************ //
  PackageDetail = interface(IInvokable)
  ['{3D100067-D12D-CF8E-9643-8B54FB7EB723}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  receivePackageDetails(const body: request): response; stdcall;
  end;

function GetPackageDetail(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): PackageDetail;


implementation
  uses SysUtils;

function GetPackageDetail(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): PackageDetail;
const
  defWSDL = 'http://its.saglik.gov.tr/ReferenceServices/PackageDetail?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/ReferenceServices/PackageDetail';
  defSvc  = 'PackageDetail';
  defPrt  = 'PackageDetailPort';
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
    Result := (RIO as PackageDetail);
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


constructor packageDetailRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor packageDetailRequest.Destroy;
begin
  SysUtils.FreeAndNil(FstartDate);
  SysUtils.FreeAndNil(FendDate);
  inherited Destroy;
end;

constructor packageDetailResponse.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor packageDetailResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FtransferDetails)-1 do
    SysUtils.FreeAndNil(FtransferDetails[I]);
  System.SetLength(FtransferDetails, 0);
  inherited Destroy;
end;

destructor transferDetail.Destroy;
begin
  SysUtils.FreeAndNil(FsendDate);
  SysUtils.FreeAndNil(FfirstTransferDate);
  SysUtils.FreeAndNil(FlastTransferDate);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(PackageDetail), 'http://services.reference.its/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(PackageDetail), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(PackageDetail), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(PackageDetail), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(PackageDetail), 'receivePackageDetails', 'body1', 'body');
  RemClassRegistry.RegisterXSClass(packageDetailRequest, 'http://services.reference.its/', 'packageDetailRequest');
  RemClassRegistry.RegisterSerializeOptions(packageDetailRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(transferDetails), 'http://services.reference.its/', 'transferDetails');
  RemClassRegistry.RegisterXSClass(packageDetailResponse, 'http://services.reference.its/', 'packageDetailResponse');
  RemClassRegistry.RegisterSerializeOptions(packageDetailResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(transferDetail, 'http://services.reference.its/', 'transferDetail');
  RemClassRegistry.RegisterXSClass(referanceErrorType, 'http://services.reference.its/', 'referanceErrorType');
  RemClassRegistry.RegisterXSClass(referenceError, 'http://services.reference.its/', 'referenceError');
  RemClassRegistry.RegisterXSClass(request, 'http://services.reference.its/', 'request');
  RemClassRegistry.RegisterXSClass(response, 'http://services.reference.its/', 'response');

end.
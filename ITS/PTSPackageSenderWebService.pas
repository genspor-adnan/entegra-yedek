// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://pts.saglik.gov.tr/PTS/PackageSenderWebService?wsdl
//  >Import : http://pts.saglik.gov.tr/PTS/PackageSenderWebService?wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (26/12/2011 12:34:19 - - $Rev: 25127 $)
// ************************************************************************ //

unit PTSPackageSenderWebService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
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
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:long            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:TSOAPAttachment - "http://www.borland.com/namespaces/Types"[Lit][]

  sendFileParametersType = class;               { "http://its.iegm.gov.tr/pts/sendpackage"[GblCplx] }
  sendFileStreamParametersType = class;         { "http://its.iegm.gov.tr/pts/sendpackage"[Lit][GblCplx] }
  sendFileResponseType = class;                 { "http://its.iegm.gov.tr/pts/sendpackage"[Lit][GblCplx] }
  packageTransferErrorType = class;             { "http://its.iegm.gov.tr/pts/sendpackage"[GblCplx] }
  sendFileParameters   = class;                 { "http://its.iegm.gov.tr/pts/sendpackage"[GblElm] }
  sendFileStreamParameters = class;             { "http://its.iegm.gov.tr/pts/sendpackage"[Lit][GblElm] }
  sendFileResponse     = class;                 { "http://its.iegm.gov.tr/pts/sendpackage"[Lit][GblElm] }
  packageTransferError = class;                 { "http://its.iegm.gov.tr/pts/sendpackage"[Flt][GblElm] }

  sourceGLN       =  type string;      { "http://its.iegm.gov.tr/pts/sendpackage"[Smpl] }
  destinationGLN  =  type string;      { "http://its.iegm.gov.tr/pts/sendpackage"[Smpl] }


  // ************************************************************************ //
  // XML       : sendFileParametersType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // ************************************************************************ //
  sendFileParametersType = class(TRemotable)
  private
    FsourceGLN: sourceGLN;
    FdestinationGLN: destinationGLN;
  published
    property sourceGLN:      sourceGLN       Index (IS_UNQL) read FsourceGLN write FsourceGLN;
    property destinationGLN: destinationGLN  Index (IS_UNQL) read FdestinationGLN write FdestinationGLN;
  end;



  // ************************************************************************ //
  // XML       : sendFileStreamParametersType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  sendFileStreamParametersType = class(TRemotable)
  private
    FsendFileParameters: sendFileParametersType;
    FfileStreamElement: TByteDynArray;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property sendFileParameters: sendFileParametersType  Index (IS_UNQL) read FsendFileParameters write FsendFileParameters;
    property fileStreamElement:  TByteDynArray           Index (IS_UNQL) read FfileStreamElement write FfileStreamElement;
  end;



  // ************************************************************************ //
  // XML       : sendFileResponseType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  sendFileResponseType = class(TRemotable)
  private
    FtransferId: Int64;
  public
    constructor Create; override;
  published
    property transferId: Int64  Index (IS_UNQL) read FtransferId write FtransferId;
  end;

  faultCode       =  type string;      { "http://its.iegm.gov.tr/pts/sendpackage"[Smpl] }


  // ************************************************************************ //
  // XML       : packageTransferErrorType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // ************************************************************************ //
  packageTransferErrorType = class(TRemotable)
  private
    FfaultCode: faultCode;
    FfaultMessage: string;
  published
    property faultCode:    faultCode  Index (IS_UNQL) read FfaultCode write FfaultCode;
    property faultMessage: string     Index (IS_UNQL) read FfaultMessage write FfaultMessage;
  end;



  // ************************************************************************ //
  // XML       : sendFileParameters, global, <element>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // ************************************************************************ //
  sendFileParameters = class(sendFileParametersType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : sendFileStreamParameters, global, <element>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // Info      : Wrapper
  // ************************************************************************ //
  sendFileStreamParameters = class(sendFileStreamParametersType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : sendFileResponse, global, <element>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // Info      : Wrapper
  // ************************************************************************ //
  sendFileResponse = class(sendFileResponseType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : packageTransferError, global, <element>
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // Info      : Fault
  // Base Types: packageTransferErrorType
  // ************************************************************************ //
  packageTransferError = class(ERemotableException)
  private
    FfaultCode: faultCode;
    FfaultMessage: string;
  published
    property faultCode:    faultCode  Index (IS_UNQL) read FfaultCode write FfaultCode;
    property faultMessage: string     Index (IS_UNQL) read FfaultMessage write FfaultMessage;
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/pts/sendpackage
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : PackageSenderWSPortBinding
  // service   : PackageSenderWebService
  // port      : PackageSenderWSPort
  // URL       : http://pts.saglik.gov.tr:80/PTS/PackageSenderWebService
  // ************************************************************************ //
  PackageSenderWS = interface(IInvokable)
  ['{662963E9-6CFE-448C-EB18-3703D14BE5DB}']
    function  sendFile(const filePart: TSOAPAttachment; const inputPart: sendFileParameters): sendFileResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  sendFileStream(const inputPart: sendFileStreamParameters): sendFileResponse; stdcall;
  end;

function GetPackageSenderWS(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): PackageSenderWS;


implementation
  uses SysUtils;

function GetPackageSenderWS(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): PackageSenderWS;
const
  defWSDL = 'http://pts.saglik.gov.tr/PTS/PackageSenderWebService?wsdl';
  defURL  = 'http://pts.saglik.gov.tr:80/PTS/PackageSenderWebService';
  defSvc  = 'PackageSenderWebService';
  defPrt  = 'PackageSenderWSPort';
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
    Result := (RIO as PackageSenderWS);
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


constructor sendFileStreamParametersType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor sendFileStreamParametersType.Destroy;
begin
  SysUtils.FreeAndNil(FsendFileParameters);
  inherited Destroy;
end;

constructor sendFileResponseType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(PackageSenderWS), 'http://its.iegm.gov.tr/pts/sendpackage', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(PackageSenderWS), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(PackageSenderWS), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(PackageSenderWS), ioLiteral);
  RemClassRegistry.RegisterXSInfo(TypeInfo(sourceGLN), 'http://its.iegm.gov.tr/pts/sendpackage', 'sourceGLN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(destinationGLN), 'http://its.iegm.gov.tr/pts/sendpackage', 'destinationGLN');
  RemClassRegistry.RegisterXSClass(sendFileParametersType, 'http://its.iegm.gov.tr/pts/sendpackage', 'sendFileParametersType');
  RemClassRegistry.RegisterXSClass(sendFileStreamParametersType, 'http://its.iegm.gov.tr/pts/sendpackage', 'sendFileStreamParametersType');
  RemClassRegistry.RegisterSerializeOptions(sendFileStreamParametersType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(sendFileResponseType, 'http://its.iegm.gov.tr/pts/sendpackage', 'sendFileResponseType');
  RemClassRegistry.RegisterSerializeOptions(sendFileResponseType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(faultCode), 'http://its.iegm.gov.tr/pts/sendpackage', 'faultCode');
  RemClassRegistry.RegisterXSClass(packageTransferErrorType, 'http://its.iegm.gov.tr/pts/sendpackage', 'packageTransferErrorType');
  RemClassRegistry.RegisterXSClass(sendFileParameters, 'http://its.iegm.gov.tr/pts/sendpackage', 'sendFileParameters');
  RemClassRegistry.RegisterXSClass(sendFileStreamParameters, 'http://its.iegm.gov.tr/pts/sendpackage', 'sendFileStreamParameters');
  RemClassRegistry.RegisterXSClass(sendFileResponse, 'http://its.iegm.gov.tr/pts/sendpackage', 'sendFileResponse');
  RemClassRegistry.RegisterXSClass(packageTransferError, 'http://its.iegm.gov.tr/pts/sendpackage', 'packageTransferError');

end.
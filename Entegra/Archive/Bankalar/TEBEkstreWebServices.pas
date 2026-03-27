// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://ext.teb.com.tr/tebws/TEBWebServices?WSDL
//  >Import : https://ext.teb.com.tr/tebws/TEBWebServices?WSDL>0
// Encoding : UTF-8
// Version  : 1.0
// (11/07/2011 09:54:42 - - $Rev: 24171 $)
// ************************************************************************ //

unit TEBEkstreWebServices;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_NLBL = $0004;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]

  TEBWebServiceResult  = class;                 { "http://prjwebservice/"[GblCplx] }



  // ************************************************************************ //
  // XML       : TEBWebServiceResult, global, <complexType>
  // Namespace : http://prjwebservice/
  // ************************************************************************ //
  TEBWebServiceResult = class(TRemotable)
  private
    FerrorMsg: string;
    FsessionId: string;
    FoutputDataXML: string;
    FerrorCode: string;
  published
    property errorMsg:      string  Index (IS_NLBL) read FerrorMsg write FerrorMsg;
    property sessionId:     string  Index (IS_NLBL) read FsessionId write FsessionId;
    property outputDataXML: string  Index (IS_NLBL) read FoutputDataXML write FoutputDataXML;
    property errorCode:     string  Index (IS_NLBL) read FerrorCode write FerrorCode;
  end;


  // ************************************************************************ //
  // Namespace : http://prjwebservice/
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : TEBWebServicesSoapHttp
  // service   : TEBWebServices
  // port      : TEBWebServicesSoapHttpPort
  // URL       : https://ext.teb.com.tr/tebws/TEBWebServices
  // ************************************************************************ //
  TEBWebServices = interface(IInvokable)
  ['{F8C3F4D9-B296-9E90-A33A-62603DCA23A4}']
    function  TEBWebSrv(const UserName: string; const Password: string; const ServiceID: string; const Environment: string; const InputDataXML: string): TEBWebServiceResult; stdcall;
  end;

function GetTEBWebServices(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): TEBWebServices;


implementation
  uses SysUtils;

function GetTEBWebServices(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): TEBWebServices;
const
  defWSDL = 'https://ext.teb.com.tr/tebws/TEBWebServices?WSDL';
  defURL  = 'https://ext.teb.com.tr/tebws/TEBWebServices';
  defSvc  = 'TEBWebServices';
  defPrt  = 'TEBWebServicesSoapHttpPort';
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
    Result := (RIO as TEBWebServices);
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


initialization
  InvRegistry.RegisterInterface(TypeInfo(TEBWebServices), 'http://prjwebservice/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(TEBWebServices), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(TEBWebServices), ioDocument);
  RemClassRegistry.RegisterXSClass(TEBWebServiceResult, 'http://prjwebservice/', 'TEBWebServiceResult');

end.

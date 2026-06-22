// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://78.187.231.166:1111/es/EntegraActivityAutomationWebService.asmx?WSDL
//  >Import : http://78.187.231.166:1111/es/EntegraActivityAutomationWebService.asmx?WSDL>0
// Encoding : utf-8
// Version  : 1.0
// (25/01/2011 11:29:58 - - $Rev: 24171 $)
// ************************************************************************ //

unit EntegraActivityAutomationWebService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_REF  = $0080;


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


  {$SCOPEDENUMS ON}
  { "http://tempuri.org/"[GblSmpl] }
  EntegraAutomationSendMailExceptions = (None, InvalidOperation, SmtpException, InvalidRecipients, ArgumentNull, Unknown);

  {$SCOPEDENUMS OFF}

  ArrayOfString = array of string;              { "http://tempuri.org/"[GblCplx] }
  ArrayOfBase64Binary = array of TByteDynArray;   { "http://tempuri.org/"[GblCplx] }

  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/SendMail
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : EntegraActivityAutomationWebServiceSoap12
  // service   : EntegraActivityAutomationWebService
  // port      : EntegraActivityAutomationWebServiceSoap12
  // URL       : http://78.187.231.166:1111/es/EntegraActivityAutomationWebService.asmx
  // ************************************************************************ //
  EntegraActivityAutomationWebServiceSoap = interface(IInvokable)
  ['{FD24D375-0AC7-5F66-C1EE-D117C8113B8E}']
    function  SendMail(const ToEmailAddresses: ArrayOfString; const CCEmailAddresses: ArrayOfString; const BCCEmailAddresses: ArrayOfString; const subject: string; const content: string; const attnames: ArrayOfString; 
                       const atts: ArrayOfBase64Binary): EntegraAutomationSendMailExceptions; stdcall;
  end;

function GetEntegraActivityAutomationWebServiceSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): EntegraActivityAutomationWebServiceSoap;


implementation
  uses SysUtils;

function GetEntegraActivityAutomationWebServiceSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): EntegraActivityAutomationWebServiceSoap;
const
  defWSDL = 'http://78.187.231.166:1111/es/EntegraActivityAutomationWebService.asmx?WSDL';
  defURL  = 'http://78.187.231.166:1111/es/EntegraActivityAutomationWebService.asmx';
  defSvc  = 'EntegraActivityAutomationWebService';
  defPrt  = 'EntegraActivityAutomationWebServiceSoap12';
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
    Result := (RIO as EntegraActivityAutomationWebServiceSoap);
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
  InvRegistry.RegisterInterface(TypeInfo(EntegraActivityAutomationWebServiceSoap), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(EntegraActivityAutomationWebServiceSoap), 'http://tempuri.org/SendMail');
  InvRegistry.RegisterInvokeOptions(TypeInfo(EntegraActivityAutomationWebServiceSoap), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(EntegraActivityAutomationWebServiceSoap), ioSOAP12);
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfString), 'http://tempuri.org/', 'ArrayOfString');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfBase64Binary), 'http://tempuri.org/', 'ArrayOfBase64Binary');
  RemClassRegistry.RegisterXSInfo(TypeInfo(EntegraAutomationSendMailExceptions), 'http://tempuri.org/', 'EntegraAutomationSendMailExceptions');

end.
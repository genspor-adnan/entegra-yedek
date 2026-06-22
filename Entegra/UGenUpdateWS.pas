// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://94.55.138.182/WSGenupdate/Service1.svc?wsdl
//  >Import : http://94.55.138.182/WSGenupdate/Service1.svc?wsdl>0
//  >Import : http://94.55.138.182/WSGenUpdate/Service1.svc?xsd=xsd0
//  >Import : http://94.55.138.182/WSGenUpdate/Service1.svc?xsd=xsd1
//  >Import : http://94.55.138.182/WSGenUpdate/Service1.svc?xsd=xsd2
// Encoding : utf-8
// Version  : 1.0
// (12/11/2011 11:57:55 - - $Rev: 24171 $)
// ************************************************************************ //

unit UGenUpdateWS;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns ;

const
  IS_OPTN = $0001;
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
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:schema          - "http://www.w3.org/2001/XMLSchema"[GblElm]

  gonderResult         = class;                 { "http://tempuri.org/"[Cplx] }



  // ************************************************************************ //
  // XML       : gonderResult, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  gonderResult = class(TRemotable)
  private
    Fschema: TXMLData;
  public
    destructor Destroy; override;
  published
    property schema: TXMLData  Index (IS_REF) read Fschema write Fschema;
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/SCServis/gonder
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_SCServis
  // service   : Service1
  // port      : BasicHttpBinding_SCServis
  // URL       : http://94.55.138.182/WSGenUpdate/Service1.svc
  // ************************************************************************ //
  SCServis = interface(IInvokable)
  ['{D556B2F9-A89C-A4B6-1F0C-6371B3AC74C9}']
    function  gonder(const prgid: Integer; const versno: Integer): gonderResult; stdcall;
  end;

function GetSCServis(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SCServis;


implementation
  uses SysUtils;

function GetSCServis(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SCServis;
const
  defWSDL = 'http://94.55.138.182/WSGenupdate/Service1.svc?wsdl';
  defURL  = 'http://94.55.138.182/WSGenUpdate/Service1.svc';
  defSvc  = 'Service1';
  defPrt  = 'BasicHttpBinding_SCServis';
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
    Result := (RIO as SCServis);
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


destructor gonderResult.Destroy;
begin
  SysUtils.FreeAndNil(Fschema);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(SCServis), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SCServis), 'http://tempuri.org/SCServis/gonder');
  InvRegistry.RegisterInvokeOptions(TypeInfo(SCServis), ioDocument);
  RemClassRegistry.RegisterXSClass(gonderResult, 'http://tempuri.org/', 'gonderResult');

end.
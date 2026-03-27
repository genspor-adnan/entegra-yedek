// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://genlisans.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc?wsdl
//  >Import : http://genlisans.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc?wsdl>0
//  >Import : http://genlisans.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc?xsd=xsd0
//  >Import : http://genlisans.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc?xsd=xsd2
//  >Import : http://genlisans.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc?xsd=xsd1
// Encoding : utf-8
// Version  : 1.0
// (24/11/2011 13:15:58 - - $Rev: 24171 $)
// ************************************************************************ //

unit GenUpdateWCF;

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
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]

  GenUpdateWCF_komutListe = class;              { "http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF"[GblCplx] }
  GenUpdateWCF_komutListe2 = class;             { "http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF"[GblElm] }

  ArrayOfGenUpdateWCF_komutListe = array of GenUpdateWCF_komutListe;   { "http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF"[GblCplx] }


  // ************************************************************************ //
  // XML       : GenUpdateWCF.komutListe, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF
  // ************************************************************************ //
  GenUpdateWCF_komutListe = class(TRemotable)
  private
    FACIKLAMA: string;
    FACIKLAMA_Specified: boolean;
    FKOMUT: string;
    FKOMUT_Specified: boolean;
    FVERSIYONNO: Integer;
    FVERSIYONNO_Specified: boolean;
    procedure SetACIKLAMA(Index: Integer; const Astring: string);
    function  ACIKLAMA_Specified(Index: Integer): boolean;
    procedure SetKOMUT(Index: Integer; const Astring: string);
    function  KOMUT_Specified(Index: Integer): boolean;
    procedure SetVERSIYONNO(Index: Integer; const AInteger: Integer);
    function  VERSIYONNO_Specified(Index: Integer): boolean;
  published
    property ACIKLAMA:   string   Index (IS_OPTN or IS_NLBL) read FACIKLAMA write SetACIKLAMA stored ACIKLAMA_Specified;
    property KOMUT:      string   Index (IS_OPTN or IS_NLBL) read FKOMUT write SetKOMUT stored KOMUT_Specified;
    property VERSIYONNO: Integer  Index (IS_OPTN) read FVERSIYONNO write SetVERSIYONNO stored VERSIYONNO_Specified;
  end;



  // ************************************************************************ //
  // XML       : GenUpdateWCF.komutListe, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF
  // ************************************************************************ //
  GenUpdateWCF_komutListe2 = class(GenUpdateWCF_komutListe)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/IGenUpdateWCF/guncelleme
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_IGenUpdateWCF
  // service   : GenUpdateWCF
  // port      : BasicHttpBinding_IGenUpdateWCF
  // URL       : http://genlisans.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc
  // ************************************************************************ //
  IGenUpdateWCF = interface(IInvokable)
  ['{348035B8-705F-0FBE-EEF0-B5D00F374FDD}']
    function  guncelleme(const programid: Integer; const baslangýc_verno: Integer; const bitis_verno: Integer): ArrayOfGenUpdateWCF_komutListe; stdcall;
  end;

function GetIGenUpdateWCF(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IGenUpdateWCF;


implementation
  uses SysUtils;

function GetIGenUpdateWCF(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IGenUpdateWCF;
const
  defWSDL = 'http://genupdate.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc?wsdl';
  defURL  = 'http://genupdate.genyazilim.com/GenUpdateWS/GenUpdateWCF.svc';
  defSvc  = 'GenUpdateWCF';
  defPrt  = 'BasicHttpBinding_IGenUpdateWCF';
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
    Result := (RIO as IGenUpdateWCF);
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


procedure GenUpdateWCF_komutListe.SetACIKLAMA(Index: Integer; const Astring: string);
begin
  FACIKLAMA := Astring;
  FACIKLAMA_Specified := True;
end;

function GenUpdateWCF_komutListe.ACIKLAMA_Specified(Index: Integer): boolean;
begin
  Result := FACIKLAMA_Specified;
end;

procedure GenUpdateWCF_komutListe.SetKOMUT(Index: Integer; const Astring: string);
begin
  FKOMUT := Astring;
  FKOMUT_Specified := True;
end;

function GenUpdateWCF_komutListe.KOMUT_Specified(Index: Integer): boolean;
begin
  Result := FKOMUT_Specified;
end;

procedure GenUpdateWCF_komutListe.SetVERSIYONNO(Index: Integer; const AInteger: Integer);
begin
  FVERSIYONNO := AInteger;
  FVERSIYONNO_Specified := True;
end;

function GenUpdateWCF_komutListe.VERSIYONNO_Specified(Index: Integer): boolean;
begin
  Result := FVERSIYONNO_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IGenUpdateWCF), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IGenUpdateWCF), 'http://tempuri.org/IGenUpdateWCF/guncelleme');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IGenUpdateWCF), ioDocument);
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfGenUpdateWCF_komutListe), 'http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF', 'ArrayOfGenUpdateWCF_komutListe', 'ArrayOfGenUpdateWCF.komutListe');
  RemClassRegistry.RegisterXSClass(GenUpdateWCF_komutListe, 'http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF', 'GenUpdateWCF_komutListe', 'GenUpdateWCF.komutListe');
  RemClassRegistry.RegisterXSClass(GenUpdateWCF_komutListe2, 'http://schemas.datacontract.org/2004/07/WS_GenUpdate_WCF', 'GenUpdateWCF_komutListe2', 'GenUpdateWCF.komutListe');

end.

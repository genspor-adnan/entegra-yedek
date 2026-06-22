// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc?wsdl
//  >Import : http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc?wsdl>0
//  >Import : http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc?xsd=xsd0
//  >Import : http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc?xsd=xsd2
//  >Import : http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc?xsd=xsd1
// Encoding : utf-8
// Version  : 1.0
// (14/12/2011 17:09:07 - - $Rev: 24171 $)
// ************************************************************************ //

unit GenUpdateWS;

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

  GenUpdateWS_komutListe = class;               { "http://schemas.datacontract.org/2004/07/GenUpdate.DataServices"[GblCplx] }
  GenUpdateWS_komutListe2 = class;              { "http://schemas.datacontract.org/2004/07/GenUpdate.DataServices"[GblElm] }

  ArrayOfGenUpdateWS_komutListe = array of GenUpdateWS_komutListe;   { "http://schemas.datacontract.org/2004/07/GenUpdate.DataServices"[GblCplx] }


  // ************************************************************************ //
  // XML       : GenUpdateWS.komutListe, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/GenUpdate.DataServices
  // ************************************************************************ //
  GenUpdateWS_komutListe = class(TRemotable)
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
  // XML       : GenUpdateWS.komutListe, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/GenUpdate.DataServices
  // ************************************************************************ //
  GenUpdateWS_komutListe2 = class(GenUpdateWS_komutListe)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/IGenUpdateWS/guncelleme
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_IGenUpdateWS
  // service   : GenUpdateWS
  // port      : BasicHttpBinding_IGenUpdateWS
  // URL       : http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc
  // ************************************************************************ //
  IGenUpdateWS = interface(IInvokable)
  ['{05BC0325-4650-A8B3-0606-180A81C34C74}']
    function  guncelleme(const programid: Integer; const baslangıc_verno: Integer; const bitis_verno: Integer): ArrayOfGenUpdateWS_komutListe; stdcall;
  end;

function GetIGenUpdateWS(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IGenUpdateWS;


implementation
  uses SysUtils;

function GetIGenUpdateWS(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IGenUpdateWS;
const
  defWSDL = 'http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc?wsdl';
  defURL  = 'http://genlisans.genyazilim.com/GenUpdate/DataServices/GenUpdateWS.svc';
  defSvc  = 'GenUpdateWS';
  defPrt  = 'BasicHttpBinding_IGenUpdateWS';
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
    Result := (RIO as IGenUpdateWS);
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


procedure GenUpdateWS_komutListe.SetACIKLAMA(Index: Integer; const Astring: string);
begin
  FACIKLAMA := Astring;
  FACIKLAMA_Specified := True;
end;

function GenUpdateWS_komutListe.ACIKLAMA_Specified(Index: Integer): boolean;
begin
  Result := FACIKLAMA_Specified;
end;

procedure GenUpdateWS_komutListe.SetKOMUT(Index: Integer; const Astring: string);
begin
  FKOMUT := Astring;
  FKOMUT_Specified := True;
end;

function GenUpdateWS_komutListe.KOMUT_Specified(Index: Integer): boolean;
begin
  Result := FKOMUT_Specified;
end;

procedure GenUpdateWS_komutListe.SetVERSIYONNO(Index: Integer; const AInteger: Integer);
begin
  FVERSIYONNO := AInteger;
  FVERSIYONNO_Specified := True;
end;

function GenUpdateWS_komutListe.VERSIYONNO_Specified(Index: Integer): boolean;
begin
  Result := FVERSIYONNO_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IGenUpdateWS), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IGenUpdateWS), 'http://tempuri.org/IGenUpdateWS/guncelleme');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IGenUpdateWS), ioDocument);
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfGenUpdateWS_komutListe), 'http://schemas.datacontract.org/2004/07/GenUpdate.DataServices', 'ArrayOfGenUpdateWS_komutListe', 'ArrayOfGenUpdateWS.komutListe');
  RemClassRegistry.RegisterXSClass(GenUpdateWS_komutListe, 'http://schemas.datacontract.org/2004/07/GenUpdate.DataServices', 'GenUpdateWS_komutListe', 'GenUpdateWS.komutListe');
  RemClassRegistry.RegisterXSClass(GenUpdateWS_komutListe2, 'http://schemas.datacontract.org/2004/07/GenUpdate.DataServices', 'GenUpdateWS_komutListe2', 'GenUpdateWS.komutListe');

end.
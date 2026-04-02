// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://88.247.188.21/genlisans/lisansWS.asmx?WSDL
// Encoding : utf-8
// Version  : 1.0
// (22/11/2007 16:14:21 - 1.33.2.5)
// ************************************************************************ //

unit lisansWS;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"
  // !:int             - "http://www.w3.org/2001/XMLSchema"

  Mesaj                = class;                 { "http://tempuri.org/" }
  KurumlarResult       = class;                 { "http://tempuri.org/" }
  MAClerResult         = class;                 { "http://tempuri.org/" }



  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  Mesaj = class(TRemotable)
  private
    FID: WideString;
    FKurumKOD: WideString;
    FTARIH: WideString;
    FISTEKNO: WideString;
    FTESISKODU: WideString;
    FKULLANICI: WideString;
    FMESAJTIPI: WideString;
    FKONU: WideString;
    FMESAJ: WideString;
    FMETIN: WideString;
    FONCELIK: WideString;
    FSUBE: WideString;
    FSORUMLU: WideString;
    FMAIL: WideString;
  published
    property ID: WideString read FID write FID;
    property KurumKOD: WideString read FKurumKOD write FKurumKOD;
    property TARIH: WideString read FTARIH write FTARIH;
    property ISTEKNO: WideString read FISTEKNO write FISTEKNO;
    property TESISKODU: WideString read FTESISKODU write FTESISKODU;
    property KULLANICI: WideString read FKULLANICI write FKULLANICI;
    property MESAJTIPI: WideString read FMESAJTIPI write FMESAJTIPI;
    property KONU: WideString read FKONU write FKONU;
    property MESAJ: WideString read FMESAJ write FMESAJ;
    property METIN: WideString read FMETIN write FMETIN;
    property ONCELIK: WideString read FONCELIK write FONCELIK;
    property SUBE: WideString read FSUBE write FSUBE;
    property SORUMLU: WideString read FSORUMLU write FSORUMLU;
    property MAIL: WideString read FMAIL write FMAIL;
  end;



  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  KurumlarResult = class(TRemotable)
  private
    Fschema: WideString;
  published
    property schema: WideString read Fschema write Fschema;
  end;



  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  MAClerResult = class(TRemotable)
  private
    Fschema: WideString;
  published
    property schema: WideString read Fschema write Fschema;
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // binding   : LisansServiceSoap
  // service   : LisansService
  // port      : LisansServiceSoap
  // URL       : http://88.247.188.21/genlisans/lisansWS.asmx
  // ************************************************************************ //
  LisansServiceSoap = interface(IInvokable)
  ['{13DE10DB-FD29-64CC-4B48-498A19B65E39}']
    function  LisansNumarasi(const KurumKod1: Integer; const KurumKod2: Integer; const MAC: WideString): WideString; stdcall;
    function  Kurumlar(const KurumAdi: WideString): KurumlarResult; stdcall;
    function  AcikLisans(const KurumKod1: Integer; const KurumKod2: Integer; const MAC: WideString): WideString; stdcall;
    function  KurumAdi(const KurumKod1: Integer; const KurumKod2: Integer; const MAC: WideString): WideString; stdcall;
    function  MACler: MAClerResult; stdcall;
    function  MesajKaydet(const TARIH: WideString; const ISTEKNO: WideString; const TESISNO: WideString; const KULLANICIADI: WideString; const MESAJTIPI: WideString; const KONU: WideString; const MESAJ: WideString; const ONCELIK: WideString; const SUBE: WideString; const SORUMLU: WideString
                          ): Mesaj; stdcall;
  end;

function GetLisansServiceSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): LisansServiceSoap;


implementation

function GetLisansServiceSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): LisansServiceSoap;
const
  defWSDL = 'http://88.247.188.21/genlisans/lisansWS.asmx?WSDL';
  defURL  = 'http://88.247.188.21/genlisans/lisansWS.asmx';
  defSvc  = 'LisansService';
  defPrt  = 'LisansServiceSoap';
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
    Result := (RIO as LisansServiceSoap);
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
  InvRegistry.RegisterInterface(TypeInfo(LisansServiceSoap), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(LisansServiceSoap), 'http://tempuri.org/%operationName%');
  RemClassRegistry.RegisterXSClass(Mesaj, 'http://tempuri.org/', 'Mesaj');
  RemClassRegistry.RegisterXSClass(KurumlarResult, 'http://tempuri.org/', 'KurumlarResult');
  RemClassRegistry.RegisterXSClass(MAClerResult, 'http://tempuri.org/', 'MAClerResult');
end. 
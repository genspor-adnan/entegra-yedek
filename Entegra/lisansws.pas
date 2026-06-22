// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://'+GenYazilimIPAdress+'/entegralisans/LisansWs.asmx?wsdl
//  >Import : http://'+GenYazilimIPAdress+'/entegralisans/LisansWs.asmx?wsdl>0
// Encoding : utf-8
// Version  : 1.0
// (04/03/2011 15:15:11 - - $Rev: 24171 $)
// ************************************************************************ //

unit LisansWs;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
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
  // !:schema          - "http://www.w3.org/2001/XMLSchema"[GblElm]

  Mesaj                = class;                 { "http://tempuri.org/"[GblCplx] }
  KurumlarResult       = class;                 { "http://tempuri.org/"[Cplx] }
  MAClerResult         = class;                 { "http://tempuri.org/"[Cplx] }
  DataSet              = class;                 { "http://tempuri.org/"[GblElm] }
  Mesaj2               = class;                 { "http://tempuri.org/"[GblElm] }



  // ************************************************************************ //
  // XML       : Mesaj, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  Mesaj = class(TRemotable)
  private
    FID: string;
    FID_Specified: boolean;
    FKurumKOD: string;
    FKurumKOD_Specified: boolean;
    FTARIH: string;
    FTARIH_Specified: boolean;
    FISTEKNO: string;
    FISTEKNO_Specified: boolean;
    FTESISKODU: string;
    FTESISKODU_Specified: boolean;
    FKULLANICI: string;
    FKULLANICI_Specified: boolean;
    FMESAJTIPI: string;
    FMESAJTIPI_Specified: boolean;
    FKONU: string;
    FKONU_Specified: boolean;
    FMESAJ: string;
    FMESAJ_Specified: boolean;
    FMETIN: string;
    FMETIN_Specified: boolean;
    FONCELIK: string;
    FONCELIK_Specified: boolean;
    FSUBE: string;
    FSUBE_Specified: boolean;
    FSORUMLU: string;
    FSORUMLU_Specified: boolean;
    FMAIL: string;
    FMAIL_Specified: boolean;
    procedure SetID(Index: Integer; const Astring: string);
    function  ID_Specified(Index: Integer): boolean;
    procedure SetKurumKOD(Index: Integer; const Astring: string);
    function  KurumKOD_Specified(Index: Integer): boolean;
    procedure SetTARIH(Index: Integer; const Astring: string);
    function  TARIH_Specified(Index: Integer): boolean;
    procedure SetISTEKNO(Index: Integer; const Astring: string);
    function  ISTEKNO_Specified(Index: Integer): boolean;
    procedure SetTESISKODU(Index: Integer; const Astring: string);
    function  TESISKODU_Specified(Index: Integer): boolean;
    procedure SetKULLANICI(Index: Integer; const Astring: string);
    function  KULLANICI_Specified(Index: Integer): boolean;
    procedure SetMESAJTIPI(Index: Integer; const Astring: string);
    function  MESAJTIPI_Specified(Index: Integer): boolean;
    procedure SetKONU(Index: Integer; const Astring: string);
    function  KONU_Specified(Index: Integer): boolean;
    procedure SetMESAJ(Index: Integer; const Astring: string);
    function  MESAJ_Specified(Index: Integer): boolean;
    procedure SetMETIN(Index: Integer; const Astring: string);
    function  METIN_Specified(Index: Integer): boolean;
    procedure SetONCELIK(Index: Integer; const Astring: string);
    function  ONCELIK_Specified(Index: Integer): boolean;
    procedure SetSUBE(Index: Integer; const Astring: string);
    function  SUBE_Specified(Index: Integer): boolean;
    procedure SetSORUMLU(Index: Integer; const Astring: string);
    function  SORUMLU_Specified(Index: Integer): boolean;
    procedure SetMAIL(Index: Integer; const Astring: string);
    function  MAIL_Specified(Index: Integer): boolean;
  published
    property ID:        string  Index (IS_OPTN) read FID write SetID stored ID_Specified;
    property KurumKOD:  string  Index (IS_OPTN) read FKurumKOD write SetKurumKOD stored KurumKOD_Specified;
    property TARIH:     string  Index (IS_OPTN) read FTARIH write SetTARIH stored TARIH_Specified;
    property ISTEKNO:   string  Index (IS_OPTN) read FISTEKNO write SetISTEKNO stored ISTEKNO_Specified;
    property TESISKODU: string  Index (IS_OPTN) read FTESISKODU write SetTESISKODU stored TESISKODU_Specified;
    property KULLANICI: string  Index (IS_OPTN) read FKULLANICI write SetKULLANICI stored KULLANICI_Specified;
    property MESAJTIPI: string  Index (IS_OPTN) read FMESAJTIPI write SetMESAJTIPI stored MESAJTIPI_Specified;
    property KONU:      string  Index (IS_OPTN) read FKONU write SetKONU stored KONU_Specified;
    property MESAJ:     string  Index (IS_OPTN) read FMESAJ write SetMESAJ stored MESAJ_Specified;
    property METIN:     string  Index (IS_OPTN) read FMETIN write SetMETIN stored METIN_Specified;
    property ONCELIK:   string  Index (IS_OPTN) read FONCELIK write SetONCELIK stored ONCELIK_Specified;
    property SUBE:      string  Index (IS_OPTN) read FSUBE write SetSUBE stored SUBE_Specified;
    property SORUMLU:   string  Index (IS_OPTN) read FSORUMLU write SetSORUMLU stored SORUMLU_Specified;
    property MAIL:      string  Index (IS_OPTN) read FMAIL write SetMAIL stored MAIL_Specified;
  end;



  // ************************************************************************ //
  // XML       : KurumlarResult, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  KurumlarResult = class(TRemotable)
  private
    Fschema: TXMLData;
  public
    destructor Destroy; override;
  published
    property schema: TXMLData  Index (IS_REF) read Fschema write Fschema;
  end;



  // ************************************************************************ //
  // XML       : MAClerResult, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  MAClerResult = class(TRemotable)
  private
    Fschema: TXMLData;
  public
    destructor Destroy; override;
  published
    property schema: TXMLData  Index (IS_REF) read Fschema write Fschema;
  end;

  string_         =  type string;      { "http://tempuri.org/"[GblElm] }


  // ************************************************************************ //
  // XML       : DataSet, global, <element>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  DataSet = class(TRemotable)
  private
    Fschema: TXMLData;
  public
    destructor Destroy; override;
  published
    property schema: TXMLData  Index (IS_REF) read Fschema write Fschema;
  end;



  // ************************************************************************ //
  // XML       : Mesaj, global, <element>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  Mesaj2 = class(Mesaj)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : LisansServiceSoap12
  // service   : LisansService
  // port      : LisansServiceSoap12
  // URL       : http://genlisans.genyazilim.com/entegralisans/LisansWs.asmx
  // ************************************************************************ //
  LisansServiceSoap = interface(IInvokable)
  ['{147600BC-5FF6-E8ED-8332-16C1A32FE132}']
    function  MACGuncelle(const KurumKod: string; const MAC: string): string; stdcall;
    function  LisansNumarasi(const KurumKod1: Integer; const KurumKod2: Integer; const MAC: string): string; stdcall;
    function  Kurumlar(const KurumAdi: string): KurumlarResult; stdcall;
    function  AcikLisans(const KurumKod1: Integer; const KurumKod2: Integer; const MAC: string): string; stdcall;
    function  KurumAdi(const KurumKod1: Integer; const KurumKod2: Integer; const MAC: string): string; stdcall;
    function  MACler: MAClerResult; stdcall;
    function  MesajKaydet(const TARIH: string; const ISTEKNO: string; const TESISNO: string; const KULLANICIADI: string; const MESAJTIPI: string; const KONU: string; 
                          const MESAJ: string; const ONCELIK: string; const SUBE: string; const SORUMLU: string): Mesaj; stdcall;
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // binding   : LisansServiceHttpGet
  // service   : LisansService
  // port      : LisansServiceHttpGet
  // ************************************************************************ //
  LisansServiceHttpGet = interface(IInvokable)
  ['{BA1FE452-EF68-8BC9-9AA0-3D405A7BC654}']
    function  MACGuncelle(const KurumKod: string; const MAC: string): string_; stdcall;
    function  LisansNumarasi(const KurumKod1: string; const KurumKod2: string; const MAC: string): string_; stdcall;
    function  Kurumlar(const KurumAdi: string): DataSet; stdcall;
    function  AcikLisans(const KurumKod1: string; const KurumKod2: string; const MAC: string): string_; stdcall;
    function  KurumAdi(const KurumKod1: string; const KurumKod2: string; const MAC: string): string_; stdcall;
    function  MACler: DataSet; stdcall;
    function  MesajKaydet(const TARIH: string; const ISTEKNO: string; const TESISNO: string; const KULLANICIADI: string; const MESAJTIPI: string; const KONU: string; 
                          const MESAJ: string; const ONCELIK: string; const SUBE: string; const SORUMLU: string): Mesaj2; stdcall;
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // binding   : LisansServiceHttpPost
  // service   : LisansService
  // port      : LisansServiceHttpPost
  // ************************************************************************ //
  LisansServiceHttpPost = interface(IInvokable)
  ['{6C80D9A9-A21E-DC38-054B-AB1EBFFFE284}']
    function  MACGuncelle(const KurumKod: string; const MAC: string): string_; stdcall;
    function  LisansNumarasi(const KurumKod1: string; const KurumKod2: string; const MAC: string): string_; stdcall;
    function  Kurumlar(const KurumAdi: string): DataSet; stdcall;
    function  AcikLisans(const KurumKod1: string; const KurumKod2: string; const MAC: string): string_; stdcall;
    function  KurumAdi(const KurumKod1: string; const KurumKod2: string; const MAC: string): string_; stdcall;
    function  MACler: DataSet; stdcall;
    function  MesajKaydet(const TARIH: string; const ISTEKNO: string; const TESISNO: string; const KULLANICIADI: string; const MESAJTIPI: string; const KONU: string; 
                          const MESAJ: string; const ONCELIK: string; const SUBE: string; const SORUMLU: string): Mesaj2; stdcall;
  end;

function GetLisansServiceSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): LisansServiceSoap;
function GetLisansServiceHttpGet(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): LisansServiceHttpGet;
function GetLisansServiceHttpPost(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): LisansServiceHttpPost;


implementation
  uses SysUtils;

function GetLisansServiceSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): LisansServiceSoap;
const
  defWSDL = 'http://94.55.135.150/entegralisans/LisansWs.asmx?wsdl';
  defURL  = 'http://94.55.135.150/entegralisans/LisansWs.asmx';
  defSvc  = 'LisansService';
  defPrt  = 'LisansServiceSoap12';
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


function GetLisansServiceHttpGet(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): LisansServiceHttpGet;
const
  defWSDL = 'http://94.55.135.150/entegralisans/LisansWs.asmx?wsdl';
  defURL  = '';
  defSvc  = 'LisansService';
  defPrt  = 'LisansServiceHttpGet';
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
    Result := (RIO as LisansServiceHttpGet);
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


function GetLisansServiceHttpPost(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): LisansServiceHttpPost;
const
  defWSDL = 'http://94.55.135.150/entegralisans/LisansWs.asmx?wsdl';
  defURL  = '';
  defSvc  = 'LisansService';
  defPrt  = 'LisansServiceHttpPost';
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
    Result := (RIO as LisansServiceHttpPost);
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


procedure Mesaj.SetID(Index: Integer; const Astring: string);
begin
  FID := Astring;
  FID_Specified := True;
end;

function Mesaj.ID_Specified(Index: Integer): boolean;
begin
  Result := FID_Specified;
end;

procedure Mesaj.SetKurumKOD(Index: Integer; const Astring: string);
begin
  FKurumKOD := Astring;
  FKurumKOD_Specified := True;
end;

function Mesaj.KurumKOD_Specified(Index: Integer): boolean;
begin
  Result := FKurumKOD_Specified;
end;

procedure Mesaj.SetTARIH(Index: Integer; const Astring: string);
begin
  FTARIH := Astring;
  FTARIH_Specified := True;
end;

function Mesaj.TARIH_Specified(Index: Integer): boolean;
begin
  Result := FTARIH_Specified;
end;

procedure Mesaj.SetISTEKNO(Index: Integer; const Astring: string);
begin
  FISTEKNO := Astring;
  FISTEKNO_Specified := True;
end;

function Mesaj.ISTEKNO_Specified(Index: Integer): boolean;
begin
  Result := FISTEKNO_Specified;
end;

procedure Mesaj.SetTESISKODU(Index: Integer; const Astring: string);
begin
  FTESISKODU := Astring;
  FTESISKODU_Specified := True;
end;

function Mesaj.TESISKODU_Specified(Index: Integer): boolean;
begin
  Result := FTESISKODU_Specified;
end;

procedure Mesaj.SetKULLANICI(Index: Integer; const Astring: string);
begin
  FKULLANICI := Astring;
  FKULLANICI_Specified := True;
end;

function Mesaj.KULLANICI_Specified(Index: Integer): boolean;
begin
  Result := FKULLANICI_Specified;
end;

procedure Mesaj.SetMESAJTIPI(Index: Integer; const Astring: string);
begin
  FMESAJTIPI := Astring;
  FMESAJTIPI_Specified := True;
end;

function Mesaj.MESAJTIPI_Specified(Index: Integer): boolean;
begin
  Result := FMESAJTIPI_Specified;
end;

procedure Mesaj.SetKONU(Index: Integer; const Astring: string);
begin
  FKONU := Astring;
  FKONU_Specified := True;
end;

function Mesaj.KONU_Specified(Index: Integer): boolean;
begin
  Result := FKONU_Specified;
end;

procedure Mesaj.SetMESAJ(Index: Integer; const Astring: string);
begin
  FMESAJ := Astring;
  FMESAJ_Specified := True;
end;

function Mesaj.MESAJ_Specified(Index: Integer): boolean;
begin
  Result := FMESAJ_Specified;
end;

procedure Mesaj.SetMETIN(Index: Integer; const Astring: string);
begin
  FMETIN := Astring;
  FMETIN_Specified := True;
end;

function Mesaj.METIN_Specified(Index: Integer): boolean;
begin
  Result := FMETIN_Specified;
end;

procedure Mesaj.SetONCELIK(Index: Integer; const Astring: string);
begin
  FONCELIK := Astring;
  FONCELIK_Specified := True;
end;

function Mesaj.ONCELIK_Specified(Index: Integer): boolean;
begin
  Result := FONCELIK_Specified;
end;

procedure Mesaj.SetSUBE(Index: Integer; const Astring: string);
begin
  FSUBE := Astring;
  FSUBE_Specified := True;
end;

function Mesaj.SUBE_Specified(Index: Integer): boolean;
begin
  Result := FSUBE_Specified;
end;

procedure Mesaj.SetSORUMLU(Index: Integer; const Astring: string);
begin
  FSORUMLU := Astring;
  FSORUMLU_Specified := True;
end;

function Mesaj.SORUMLU_Specified(Index: Integer): boolean;
begin
  Result := FSORUMLU_Specified;
end;

procedure Mesaj.SetMAIL(Index: Integer; const Astring: string);
begin
  FMAIL := Astring;
  FMAIL_Specified := True;
end;

function Mesaj.MAIL_Specified(Index: Integer): boolean;
begin
  Result := FMAIL_Specified;
end;

destructor KurumlarResult.Destroy;
begin
  SysUtils.FreeAndNil(Fschema);
  inherited Destroy;
end;

destructor MAClerResult.Destroy;
begin
  SysUtils.FreeAndNil(Fschema);
  inherited Destroy;
end;

destructor DataSet.Destroy;
begin
  SysUtils.FreeAndNil(Fschema);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(LisansServiceSoap), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(LisansServiceSoap), 'http://tempuri.org/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(LisansServiceSoap), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(LisansServiceSoap), ioSOAP12);
  InvRegistry.RegisterInterface(TypeInfo(LisansServiceHttpGet), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(LisansServiceHttpGet), '');
  InvRegistry.RegisterInterface(TypeInfo(LisansServiceHttpPost), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(LisansServiceHttpPost), '');
  RemClassRegistry.RegisterXSClass(Mesaj, 'http://tempuri.org/', 'Mesaj');
  RemClassRegistry.RegisterXSClass(KurumlarResult, 'http://tempuri.org/', 'KurumlarResult');
  RemClassRegistry.RegisterXSClass(MAClerResult, 'http://tempuri.org/', 'MAClerResult');
  RemClassRegistry.RegisterXSInfo(TypeInfo(string_), 'http://tempuri.org/', 'string_', 'string');
  RemClassRegistry.RegisterXSClass(DataSet, 'http://tempuri.org/', 'DataSet');
  RemClassRegistry.RegisterXSClass(Mesaj2, 'http://tempuri.org/', 'Mesaj2', 'Mesaj');

end.

// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://192.168.0.111/Destek/Destek.asmx?WSDL
//  >Import : http://192.168.0.111/Destek/Destek.asmx?WSDL>0
// Encoding : utf-8
// Version  : 1.0
// (12.2.2014 09:13:26 - - $Rev: 52705 $)
// ************************************************************************ //

unit WS_Destek;

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
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:short           - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]

  GENINI               = class;                 { "http://tempuri.org/"[GblCplx] }
  REH2                 = class;                 { "http://tempuri.org/"[GblCplx] }
  REH                  = class;                 { "http://tempuri.org/"[GblElm] }



  // ************************************************************************ //
  // XML       : GENINI, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  GENINI = class(TRemotable)
  private
    FBolum: string;
    FBolum_Specified: boolean;
    FAnahtar: string;
    FAnahtar_Specified: boolean;
    FDeger: string;
    FDeger_Specified: boolean;
    FDil: string;
    FDil_Specified: boolean;
    FSira: string;
    FSira_Specified: boolean;
    procedure SetBolum(Index: Integer; const Astring: string);
    function  Bolum_Specified(Index: Integer): boolean;
    procedure SetAnahtar(Index: Integer; const Astring: string);
    function  Anahtar_Specified(Index: Integer): boolean;
    procedure SetDeger(Index: Integer; const Astring: string);
    function  Deger_Specified(Index: Integer): boolean;
    procedure SetDil(Index: Integer; const Astring: string);
    function  Dil_Specified(Index: Integer): boolean;
    procedure SetSira(Index: Integer; const Astring: string);
    function  Sira_Specified(Index: Integer): boolean;
  published
    property Bolum:   string  Index (IS_OPTN) read FBolum write SetBolum stored Bolum_Specified;
    property Anahtar: string  Index (IS_OPTN) read FAnahtar write SetAnahtar stored Anahtar_Specified;
    property Deger:   string  Index (IS_OPTN) read FDeger write SetDeger stored Deger_Specified;
    property Dil:     string  Index (IS_OPTN) read FDil write SetDil stored Dil_Specified;
    property Sira:    string  Index (IS_OPTN) read FSira write SetSira stored Sira_Specified;
  end;



  // ************************************************************************ //
  // XML       : REH, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  REH2 = class(TRemotable)
  private
    FID: Integer;
    FFirma: string;
    FFirma_Specified: boolean;
    procedure SetFirma(Index: Integer; const Astring: string);
    function  Firma_Specified(Index: Integer): boolean;
  published
    property ID:    Integer  read FID write FID;
    property Firma: string   Index (IS_OPTN) read FFirma write SetFirma stored Firma_Specified;
  end;



  // ************************************************************************ //
  // XML       : REH, global, <element>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  REH = class(REH2)
  private
  published
  end;

  string_         =  type string;      { "http://tempuri.org/"[GblElm] }
  ArrayOfGENINI2 = array of GENINI;             { "http://tempuri.org/"[GblCplx] }
  ArrayOfGENINI   =  type ArrayOfGENINI2;      { "http://tempuri.org/"[GblElm] }

  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : DestekSoap
  // service   : Destek
  // port      : DestekSoap
  // URL       : http://192.168.0.111/Destek/Destek.asmx
  // ************************************************************************ //
  DestekSoap = interface(IInvokable)
  ['{E4A65E60-5EFE-69AD-EF80-F160C7F74291}']
    function  TalimatEkle(const firmaID: Integer; const sorumluID: Integer; const turu: SmallInt; const aciklama: string; const baslamaTarihi: string; const bitisTarihi: string; 
                          const konu: string; const tip: SmallInt): string; stdcall;
    function  FirmaKontrol(const musteriKodu: string): REH2; stdcall;
    function  Genini(const bolumid: Integer): ArrayOfGENINI2; stdcall;
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // style     : ????
  // use       : ????
  // binding   : DestekHttpGet
  // service   : Destek
  // port      : DestekHttpGet
  // ************************************************************************ //
  DestekHttpGet = interface(IInvokable)
  ['{1A94FC91-702F-B35B-355D-567EFCDFE820}']
    function  TalimatEkle(const firmaID: string; const sorumluID: string; const turu: string; const aciklama: string; const baslamaTarihi: string; const bitisTarihi: string; 
                          const konu: string; const tip: string): string_; stdcall;
    function  FirmaKontrol(const musteriKodu: string): REH; stdcall;
    function  Genini(const bolumid: string): ArrayOfGENINI; stdcall;
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // style     : ????
  // use       : ????
  // binding   : DestekHttpPost
  // service   : Destek
  // port      : DestekHttpPost
  // ************************************************************************ //
  DestekHttpPost = interface(IInvokable)
  ['{805C09D3-FBAB-6CA7-06A1-476BEFB77F29}']
    function  TalimatEkle(const firmaID: string; const sorumluID: string; const turu: string; const aciklama: string; const baslamaTarihi: string; const bitisTarihi: string; 
                          const konu: string; const tip: string): string_; stdcall;
    function  FirmaKontrol(const musteriKodu: string): REH; stdcall;
    function  Genini(const bolumid: string): ArrayOfGENINI; stdcall;
  end;

function GetDestekSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DestekSoap;
function GetDestekHttpGet(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DestekHttpGet;
function GetDestekHttpPost(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DestekHttpPost;


implementation
  uses SysUtils;

function GetDestekSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DestekSoap;
const
  defWSDL = 'http://192.168.0.111/Destek/Destek.asmx?WSDL';
  defURL  = 'http://192.168.0.111/Destek/Destek.asmx';
  defSvc  = 'Destek';
  defPrt  = 'DestekSoap';
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
    Result := (RIO as DestekSoap);
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


function GetDestekHttpGet(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DestekHttpGet;
const
  defWSDL = 'http://192.168.0.111/Destek/Destek.asmx?WSDL';
  defURL  = '';
  defSvc  = 'Destek';
  defPrt  = 'DestekHttpGet';
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
    Result := (RIO as DestekHttpGet);
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


function GetDestekHttpPost(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DestekHttpPost;
const
  defWSDL = 'http://192.168.0.111/Destek/Destek.asmx?WSDL';
  defURL  = '';
  defSvc  = 'Destek';
  defPrt  = 'DestekHttpPost';
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
    Result := (RIO as DestekHttpPost);
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


procedure GENINI.SetBolum(Index: Integer; const Astring: string);
begin
  FBolum := Astring;
  FBolum_Specified := True;
end;

function GENINI.Bolum_Specified(Index: Integer): boolean;
begin
  Result := FBolum_Specified;
end;

procedure GENINI.SetAnahtar(Index: Integer; const Astring: string);
begin
  FAnahtar := Astring;
  FAnahtar_Specified := True;
end;

function GENINI.Anahtar_Specified(Index: Integer): boolean;
begin
  Result := FAnahtar_Specified;
end;

procedure GENINI.SetDeger(Index: Integer; const Astring: string);
begin
  FDeger := Astring;
  FDeger_Specified := True;
end;

function GENINI.Deger_Specified(Index: Integer): boolean;
begin
  Result := FDeger_Specified;
end;

procedure GENINI.SetDil(Index: Integer; const Astring: string);
begin
  FDil := Astring;
  FDil_Specified := True;
end;

function GENINI.Dil_Specified(Index: Integer): boolean;
begin
  Result := FDil_Specified;
end;

procedure GENINI.SetSira(Index: Integer; const Astring: string);
begin
  FSira := Astring;
  FSira_Specified := True;
end;

function GENINI.Sira_Specified(Index: Integer): boolean;
begin
  Result := FSira_Specified;
end;

procedure REH2.SetFirma(Index: Integer; const Astring: string);
begin
  FFirma := Astring;
  FFirma_Specified := True;
end;

function REH2.Firma_Specified(Index: Integer): boolean;
begin
  Result := FFirma_Specified;
end;

initialization
  { DestekSoap }
  InvRegistry.RegisterInterface(TypeInfo(DestekSoap), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DestekSoap), 'http://tempuri.org/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(DestekSoap), ioDocument);
  { DestekSoap.TalimatEkle }
  InvRegistry.RegisterMethodInfo(TypeInfo(DestekSoap), 'TalimatEkle', '',
                                 '[ReturnName="TalimatEkleResult"]', IS_OPTN);
  { DestekSoap.FirmaKontrol }
  InvRegistry.RegisterMethodInfo(TypeInfo(DestekSoap), 'FirmaKontrol', '',
                                 '[ReturnName="FirmaKontrolResult"]', IS_OPTN);
  { DestekSoap.Genini }
  InvRegistry.RegisterMethodInfo(TypeInfo(DestekSoap), 'Genini', '',
                                 '[ReturnName="GeniniResult"]', IS_OPTN);
  InvRegistry.RegisterParamInfo(TypeInfo(DestekSoap), 'Genini', 'GeniniResult', '',
                                '[ArrayItemName="GENINI"]');
  { DestekHttpGet }
  InvRegistry.RegisterInterface(TypeInfo(DestekHttpGet), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DestekHttpGet), '');
  { DestekHttpPost }
  InvRegistry.RegisterInterface(TypeInfo(DestekHttpPost), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DestekHttpPost), '');
  RemClassRegistry.RegisterXSClass(GENINI, 'http://tempuri.org/', 'GENINI');
  RemClassRegistry.RegisterXSClass(REH2, 'http://tempuri.org/', 'REH2', 'REH');
  RemClassRegistry.RegisterXSClass(REH, 'http://tempuri.org/', 'REH');
  RemClassRegistry.RegisterXSInfo(TypeInfo(string_), 'http://tempuri.org/', 'string_', 'string');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfGENINI2), 'http://tempuri.org/', 'ArrayOfGENINI2', 'ArrayOfGENINI');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfGENINI), 'http://tempuri.org/', 'ArrayOfGENINI');

end.
// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoUrunDogrulama.wsdl
//  >Import : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoUrunDogrulama.wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (14/10/2011 15:12:42 - - $Rev: 25127 $)
// ************************************************************************ //

unit DepoUrunDogrulamaServis;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_UNBD = $0002;
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
  // !:date            - "http://www.w3.org/2001/XMLSchema"[Gbl]

  DepoDogrulamaBildirimCevapType = class;       { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Lit][GblCplx] }
  URUNDURUM            = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Cplx] }
  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[GblCplx] }
  DepoDogrulamaBildirimType = class;            { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Lit][GblCplx] }
  URUN                 = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Cplx] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Flt][GblElm] }
  DepoDogrulamaBildirimCevap = class;           { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Lit][GblElm] }
  DepoDogrulamaBildirim = class;                { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Lit][GblElm] }

  URUNLER    = array of URUNDURUM;              { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : DepoDogrulamaBildirimCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DepoDogrulamaBildirimCevapType = class(TRemotable)
  private
    FBILDIRIMID: string;
    FURUNLER: URUNLER;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property BILDIRIMID: string   Index (IS_UNQL) read FBILDIRIMID write FBILDIRIMID;
    property URUNLER:    URUNLER  Index (IS_UNQL) read FURUNLER write FURUNLER;
  end;

  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }
  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // ************************************************************************ //
  URUNDURUM = class(TRemotable)
  private
    FGTIN: GTIN;
    FSN: SN;
    FUC: UC;
  published
    property GTIN: GTIN  Index (IS_UNQL) read FGTIN write FGTIN;
    property SN:   SN    Index (IS_UNQL) read FSN write FSN;
    property UC:   UC    Index (IS_UNQL) read FUC write FUC;
  end;

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }
  FR              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }
  URUNLER2   = array of URUN;                   { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : DepoDogrulamaBildirimType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DepoDogrulamaBildirimType = class(TRemotable)
  private
    FDT: DT;
    FFR: FR;
    FURUNLER: URUNLER2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property DT:      DT        Index (IS_UNQL) read FDT write FDT;
    property FR:      FR        Index (IS_UNQL) read FFR write FFR;
    property URUNLER: URUNLER2  Index (IS_UNQL) read FURUNLER write FURUNLER;
  end;

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }
  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUN, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // ************************************************************************ //
  URUN = class(TRemotable)
  private
    FGTIN: GTIN2;
    FBN: BN;
    FSN: SN2;
    FXD: TXSDate;
  public
    destructor Destroy; override;
  published
    property GTIN: GTIN2    Index (IS_UNQL) read FGTIN write FGTIN;
    property BN:   BN       Index (IS_UNQL) read FBN write FBN;
    property SN:   SN2      Index (IS_UNQL) read FSN write FSN;
    property XD:   TXSDate  Index (IS_UNQL) read FXD write FXD;
  end;



  // ************************************************************************ //
  // XML       : BildirimHata, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // Info      : Fault
  // Base Types: BildirimHataType
  // ************************************************************************ //
  BildirimHata = class(ERemotableException)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;



  // ************************************************************************ //
  // XML       : DepoDogrulamaBildirimCevap, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  DepoDogrulamaBildirimCevap = class(DepoDogrulamaBildirimCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DepoDogrulamaBildirim, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  DepoDogrulamaBildirim = class(DepoDogrulamaBildirimType)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo
  // soapAction: http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/DepoDogrulamaBildirimRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DepoDogrulamaReceiverBinding
  // service   : DepoDogrulamaReceiverService
  // port      : DepoDogrulamaBildirimReceiverBindingPort
  // URL       : http://itstest:8080/DepoDogrulama/DepoDogrulamaReceiverService
  // ************************************************************************ //
  DepoDogrulamaBildirimReceiver = interface(IInvokable)
  ['{01F4B368-0997-50B5-2AEE-4BA1D636EDC6}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  DepoDogrulamaBildir(const body: DepoDogrulamaBildirim): DepoDogrulamaBildirimCevap; stdcall;
  end;

function GetDepoDogrulamaBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DepoDogrulamaBildirimReceiver;


implementation
  uses SysUtils;

function GetDepoDogrulamaBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DepoDogrulamaBildirimReceiver;
const
  defWSDL = 'http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoUrunDogrulama.wsdl';
  defURL  = 'http://212.174.130.240/DepoDogrulama/DepoDogrulamaReceiverService';
  defSvc  = 'DepoDogrulamaReceiverService';
  defPrt  = 'DepoDogrulamaBildirimReceiverBindingPort';
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
    Result := (RIO as DepoDogrulamaBildirimReceiver);
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


constructor DepoDogrulamaBildirimCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DepoDogrulamaBildirimCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

constructor DepoDogrulamaBildirimType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DepoDogrulamaBildirimType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

destructor URUN.Destroy;
begin
  SysUtils.FreeAndNil(FXD);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(DepoDogrulamaBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DepoDogrulamaBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/DepoDogrulamaBildirimRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(DepoDogrulamaBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(DepoDogrulamaBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(DepoDogrulamaBildirimReceiver), 'DepoDogrulamaBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DepoDogrulamaBildirimCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'DepoDogrulamaBildirimCevapType');
  RemClassRegistry.RegisterSerializeOptions(DepoDogrulamaBildirimCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'UC');
  RemClassRegistry.RegisterXSClass(URUNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'URUNDURUM');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FR), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'FR');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DepoDogrulamaBildirimType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'DepoDogrulamaBildirimType');
  RemClassRegistry.RegisterSerializeOptions(DepoDogrulamaBildirimType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'SN2', 'SN');
  RemClassRegistry.RegisterXSClass(URUN, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'URUN');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'BildirimHata');
  RemClassRegistry.RegisterXSClass(DepoDogrulamaBildirimCevap, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'DepoDogrulamaBildirimCevap');
  RemClassRegistry.RegisterXSClass(DepoDogrulamaBildirim, 'http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo', 'DepoDogrulamaBildirim');

end.

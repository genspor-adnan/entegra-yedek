// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/UrunDogrulama/UrunDogrulamaReceiverService?wsdl
//  >Import : http://its.saglik.gov.tr/UrunDogrulama/UrunDogrulamaReceiverService?wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (31/03/2012 11:54:26 - - $Rev: 25127 $)
// ************************************************************************ //

unit ItsServisUrunDogrulamaReceiverService;

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

  UrunDogrulamaBildirimCevapType = class;       { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Lit][GblCplx] }
  URUNDURUM            = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Cplx] }
  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[GblCplx] }
  UrunDogrulamaBildirimType = class;            { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Lit][GblCplx] }
  URUN                 = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Cplx] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Flt][GblElm] }
  UrunDogrulamaBildirimCevap = class;           { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Lit][GblElm] }
  UrunDogrulamaBildirim = class;                { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Lit][GblElm] }

  URUNLER    = array of URUNDURUM;              { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Cplx] }


  // ************************************************************************ //
  // XML       : UrunDogrulamaBildirimCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  UrunDogrulamaBildirimCevapType = class(TRemotable)
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

  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }
  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }


  // ************************************************************************ //
  // XML       : URUNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
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

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }
  FR              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }
  URUNLER2   = array of URUN;                   { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Cplx] }


  // ************************************************************************ //
  // XML       : UrunDogrulamaBildirimType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  UrunDogrulamaBildirimType = class(TRemotable)
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

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }
  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel"[Smpl] }


  // ************************************************************************ //
  // XML       : URUN, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
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
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
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
  // XML       : UrunDogrulamaBildirimCevap, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
  // Info      : Wrapper
  // ************************************************************************ //
  UrunDogrulamaBildirimCevap = class(UrunDogrulamaBildirimCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : UrunDogrulamaBildirim, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
  // Info      : Wrapper
  // ************************************************************************ //
  UrunDogrulamaBildirim = class(UrunDogrulamaBildirimType)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel
  // soapAction: http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/UrunDogrulamaBildirimRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : UrunDogrulamaReceiverBinding
  // service   : UrunDogrulamaReceiverService
  // port      : UrunDogrulamaBildirimReceiverBindingPort
  // URL       : http://its.saglik.gov.tr:80/UrunDogrulama/UrunDogrulamaReceiverService
  // ************************************************************************ //
  UrunDogrulamaBildirimReceiver = interface(IInvokable)
  ['{7B86F084-F31B-E231-67DA-CB5A9628C394}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  UrunDogrulamaBildir(const body: UrunDogrulamaBildirim): UrunDogrulamaBildirimCevap; stdcall;
  end;

function GetUrunDogrulamaBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): UrunDogrulamaBildirimReceiver;


implementation
  uses SysUtils;

function GetUrunDogrulamaBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): UrunDogrulamaBildirimReceiver;
const
  defWSDL = 'http://its.saglik.gov.tr/UrunDogrulama/UrunDogrulamaReceiverService?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/UrunDogrulama/UrunDogrulamaReceiverService';
  defSvc  = 'UrunDogrulamaReceiverService';
  defPrt  = 'UrunDogrulamaBildirimReceiverBindingPort';
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
    Result := (RIO as UrunDogrulamaBildirimReceiver);
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


constructor UrunDogrulamaBildirimCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor UrunDogrulamaBildirimCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

constructor UrunDogrulamaBildirimType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor UrunDogrulamaBildirimType.Destroy;
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
  InvRegistry.RegisterInterface(TypeInfo(UrunDogrulamaBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(UrunDogrulamaBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/UrunDogrulamaBildirimRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(UrunDogrulamaBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(UrunDogrulamaBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(UrunDogrulamaBildirimReceiver), 'UrunDogrulamaBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'URUNLER');
  RemClassRegistry.RegisterXSClass(UrunDogrulamaBildirimCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'UrunDogrulamaBildirimCevapType');
  RemClassRegistry.RegisterSerializeOptions(UrunDogrulamaBildirimCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'UC');
  RemClassRegistry.RegisterXSClass(URUNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'URUNDURUM');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FR), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'FR');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(UrunDogrulamaBildirimType, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'UrunDogrulamaBildirimType');
  RemClassRegistry.RegisterSerializeOptions(UrunDogrulamaBildirimType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'SN2', 'SN');
  RemClassRegistry.RegisterXSClass(URUN, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'URUN');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'BildirimHata');
  RemClassRegistry.RegisterXSClass(UrunDogrulamaBildirimCevap, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'UrunDogrulamaBildirimCevap');
  RemClassRegistry.RegisterXSClass(UrunDogrulamaBildirim, 'http://its.iegm.gov.tr/bildirim/BR/v1/UrunDogrulama/Genel', 'UrunDogrulamaBildirim');

end.
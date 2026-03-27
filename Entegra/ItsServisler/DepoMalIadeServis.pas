// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoMalIadeReceiver.wsdl
//  >Import : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoMalIadeReceiver.wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/10/2011 13:44:23 - - $Rev: 25127 $)
// ************************************************************************ //

unit DepoMalIadeServis;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_UNBD = $0002;
  IS_NLBL = $0004;
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

  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[GblCplx] }
  BELGE                = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Cplx] }
  DepoMalIadeType      = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Lit][GblCplx] }
  URUN                 = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Cplx] }
  DepoMalIadeCevapType = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Lit][GblCplx] }
  URUNDURUM            = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Cplx] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Flt][GblElm] }
  DepoMalIadeCevap     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Lit][GblElm] }
  DepoMalIade          = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Lit][GblElm] }

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }
  FR              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }
  TO_             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }
  DN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : BELGE, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // ************************************************************************ //
  BELGE = class(TRemotable)
  private
    FDD: TXSDate;
    FDN: DN;
  public
    destructor Destroy; override;
  published
    property DD: TXSDate  Index (IS_UNQL) read FDD write FDD;
    property DN: DN       Index (IS_NLBL or IS_UNQL) read FDN write FDN;
  end;

  URUNLER    = array of URUN;                   { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : DepoMalIadeType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalIadeType = class(TRemotable)
  private
    FDT: DT;
    FFR: FR;
    FTO_: TO_;
    FBELGE: BELGE;
    FURUNLER: URUNLER;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property DT:      DT       Index (IS_UNQL) read FDT write FDT;
    property FR:      FR       Index (IS_UNQL) read FFR write FFR;
    property TO_:     TO_      Index (IS_UNQL) read FTO_ write FTO_;
    property BELGE:   BELGE    Index (IS_NLBL or IS_UNQL) read FBELGE write FBELGE;
    property URUNLER: URUNLER  Index (IS_UNQL) read FURUNLER write FURUNLER;
  end;

  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }
  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUN, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // ************************************************************************ //
  URUN = class(TRemotable)
  private
    FGTIN: GTIN;
    FBN: BN;
    FSN: SN;
    FXD: TXSDate;
  public
    destructor Destroy; override;
  published
    property GTIN: GTIN     Index (IS_UNQL) read FGTIN write FGTIN;
    property BN:   BN       Index (IS_UNQL) read FBN write FBN;
    property SN:   SN       Index (IS_UNQL) read FSN write FSN;
    property XD:   TXSDate  Index (IS_UNQL) read FXD write FXD;
  end;

  URUNLER2   = array of URUNDURUM;              { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : DepoMalIadeCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalIadeCevapType = class(TRemotable)
  private
    FBILDIRIMID: string;
    FURUNLER: URUNLER2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property BILDIRIMID: string    Index (IS_UNQL) read FBILDIRIMID write FBILDIRIMID;
    property URUNLER:    URUNLER2  Index (IS_UNQL) read FURUNLER write FURUNLER;
  end;

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }
  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // ************************************************************************ //
  URUNDURUM = class(TRemotable)
  private
    FGTIN: GTIN2;
    FSN: SN2;
    FUC: UC;
  published
    property GTIN: GTIN2  Index (IS_UNQL) read FGTIN write FGTIN;
    property SN:   SN2    Index (IS_UNQL) read FSN write FSN;
    property UC:   UC     Index (IS_UNQL) read FUC write FUC;
  end;



  // ************************************************************************ //
  // XML       : BildirimHata, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
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
  // XML       : DepoMalIadeCevap, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalIadeCevap = class(DepoMalIadeCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DepoMalIade, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalIade = class(DepoMalIadeType)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo
  // soapAction: http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/Iade/DepoIade/MalIadeBildirRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DepoMalIadeBildirimReceiverBinding
  // service   : DepoMalIadeReceiverService
  // port      : DepoMalIadeBildirimReceiverBindingPort
  // URL       : http://itstest:8080/DepoMalIade/DepoMalIadeReceiverService
  // ************************************************************************ //
  DepoMalIadeBildirimReceiver = interface(IInvokable)
  ['{6D24B098-623B-19E9-1395-24E2EB9BD3E2}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  DepoMalIadeBildir(const body: DepoMalIade): DepoMalIadeCevap; stdcall;
  end;

function GetDepoMalIadeBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DepoMalIadeBildirimReceiver;


implementation
  uses SysUtils;

function GetDepoMalIadeBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DepoMalIadeBildirimReceiver;
const
  defWSDL = 'http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoMalIadeReceiver.wsdl';
  defURL  = 'http://212.174.130.240/DepoMalIade/DepoMalIadeReceiverService';
  defSvc  = 'DepoMalIadeReceiverService';
  defPrt  = 'DepoMalIadeBildirimReceiverBindingPort';
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
    Result := (RIO as DepoMalIadeBildirimReceiver);
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


destructor BELGE.Destroy;
begin
  SysUtils.FreeAndNil(FDD);
  inherited Destroy;
end;

constructor DepoMalIadeType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DepoMalIadeType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  SysUtils.FreeAndNil(FBELGE);
  inherited Destroy;
end;

destructor URUN.Destroy;
begin
  SysUtils.FreeAndNil(FXD);
  inherited Destroy;
end;

constructor DepoMalIadeCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DepoMalIadeCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(DepoMalIadeBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DepoMalIadeBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/Iade/DepoIade/MalIadeBildirRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(DepoMalIadeBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(DepoMalIadeBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(DepoMalIadeBildirimReceiver), 'DepoMalIadeBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FR), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'FR');
  RemClassRegistry.RegisterXSInfo(TypeInfo(TO_), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'TO_', 'TO');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'DN');
  RemClassRegistry.RegisterXSClass(BELGE, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'BELGE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DepoMalIadeType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'DepoMalIadeType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(DepoMalIadeType), 'TO_', 'TO');
  RemClassRegistry.RegisterSerializeOptions(DepoMalIadeType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'SN');
  RemClassRegistry.RegisterXSClass(URUN, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'URUN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DepoMalIadeCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'DepoMalIadeCevapType');
  RemClassRegistry.RegisterSerializeOptions(DepoMalIadeCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'SN2', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'UC');
  RemClassRegistry.RegisterXSClass(URUNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'URUNDURUM');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'BildirimHata');
  RemClassRegistry.RegisterXSClass(DepoMalIadeCevap, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'DepoMalIadeCevap');
  RemClassRegistry.RegisterXSClass(DepoMalIade, 'http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo', 'DepoMalIade');

end.

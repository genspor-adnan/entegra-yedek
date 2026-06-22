// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoSatisReceiver.wsdl
//  >Import : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoSatisReceiver.wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/10/2011 13:46:04 - - $Rev: 25127 $)
// ************************************************************************ //

unit DepoSatisServis;

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

  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[GblCplx] }
  BELGE                = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Cplx] }
  SatisBildirimType    = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Lit][GblCplx] }
  URUN                 = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Cplx] }
  SatisBildirimCevapType = class;               { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Lit][GblCplx] }
  URUNDURUM            = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Cplx] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Flt][GblElm] }
  SatisBildirimCevap   = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Lit][GblElm] }
  SatisBildirim        = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Lit][GblElm] }

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }
  FR              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }
  TO_             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }
  DN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }


  // ************************************************************************ //
  // XML       : BELGE, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
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

  URUNLER    = array of URUN;                   { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Cplx] }


  // ************************************************************************ //
  // XML       : SatisBildirimType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SatisBildirimType = class(TRemotable)
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

  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }
  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }


  // ************************************************************************ //
  // XML       : URUN, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
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

  URUNLER2   = array of URUNDURUM;              { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Cplx] }


  // ************************************************************************ //
  // XML       : SatisBildirimCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SatisBildirimCevapType = class(TRemotable)
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

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }
  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis"[Smpl] }


  // ************************************************************************ //
  // XML       : URUNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
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
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
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
  // XML       : SatisBildirimCevap, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
  // Info      : Wrapper
  // ************************************************************************ //
  SatisBildirimCevap = class(SatisBildirimCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : SatisBildirim, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
  // Info      : Wrapper
  // ************************************************************************ //
  SatisBildirim = class(SatisBildirimType)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis
  // soapAction: http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/Satis/DepoSatis/SatisBildirRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : SatisBildirimReceiverBinding
  // service   : DepoSatisReceiverService
  // port      : SatisBildirimReceiverBindingPort
  // URL       : http://itstest:8080/DepoSatis/DepoSatisReceiverService
  // ************************************************************************ //
  SatisBildirimReceiver = interface(IInvokable)
  ['{3EC96DFF-D98A-1A8D-D562-F38785317F76}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  SatisBildir(const body: SatisBildirim): SatisBildirimCevap; stdcall;
  end;

function GetSatisBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SatisBildirimReceiver;


implementation
  uses SysUtils;

function GetSatisBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SatisBildirimReceiver;
const
  defWSDL = 'http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoSatisReceiver.wsdl';
  defURL  = 'http://212.174.130.240/DepoSatis/DepoSatisReceiverService';
  defSvc  = 'DepoSatisReceiverService';
  defPrt  = 'SatisBildirimReceiverBindingPort';
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
    Result := (RIO as SatisBildirimReceiver);
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

constructor SatisBildirimType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SatisBildirimType.Destroy;
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

constructor SatisBildirimCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SatisBildirimCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(SatisBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SatisBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/Satis/DepoSatis/SatisBildirRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(SatisBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(SatisBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(SatisBildirimReceiver), 'SatisBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FR), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'FR');
  RemClassRegistry.RegisterXSInfo(TypeInfo(TO_), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'TO_', 'TO');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'DN');
  RemClassRegistry.RegisterXSClass(BELGE, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'BELGE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'URUNLER');
  RemClassRegistry.RegisterXSClass(SatisBildirimType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'SatisBildirimType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(SatisBildirimType), 'TO_', 'TO');
  RemClassRegistry.RegisterSerializeOptions(SatisBildirimType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'SN');
  RemClassRegistry.RegisterXSClass(URUN, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'URUN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(SatisBildirimCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'SatisBildirimCevapType');
  RemClassRegistry.RegisterSerializeOptions(SatisBildirimCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'SN2', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'UC');
  RemClassRegistry.RegisterXSClass(URUNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'URUNDURUM');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'BildirimHata');
  RemClassRegistry.RegisterXSClass(SatisBildirimCevap, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'SatisBildirimCevap');
  RemClassRegistry.RegisterXSClass(SatisBildirim, 'http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis', 'SatisBildirim');

end.

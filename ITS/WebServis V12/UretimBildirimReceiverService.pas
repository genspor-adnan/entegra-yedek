// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://its.saglik.gov.tr/UretimBildirim/UretimBildirimReceiverService?wsdl
//  >Import : http://its.saglik.gov.tr/UretimBildirim/UretimBildirimReceiverService?wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/12/2012 14:24:22 - - $Rev: 25127 $)
// ************************************************************************ //

unit UretimBildirimReceiverService;

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

  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[GblCplx] }
  BELGE                = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Cplx] }
  UretimBildirimType   = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Lit][GblCplx] }
  UretimBildirimCevapType = class;              { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Lit][GblCplx] }
  SNDURUM              = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Cplx] }
  Uretim               = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Lit][GblElm] }
  UretimResponse       = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Lit][GblElm] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Flt][GblElm] }

  {$SCOPEDENUMS ON}
  { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  PT = (PP, BP, FP);

  {$SCOPEDENUMS OFF}

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  MI              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  DN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }


  // ************************************************************************ //
  // XML       : BELGE, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // ************************************************************************ //
  BELGE = class(TRemotable)
  private
    FDD: TXSDate;
    FDN: DN;
  public
    destructor Destroy; override;
  published
    property DD: TXSDate  Index (IS_UNQL) read FDD write FDD;
    property DN: DN       Index (IS_UNQL) read FDN write FDN;
  end;

  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  URUNLER    = array of SN;                     { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Cplx] }


  // ************************************************************************ //
  // XML       : UretimBildirimType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  UretimBildirimType = class(TRemotable)
  private
    FDT: DT;
    FMI: MI;
    FPT: PT;
    FMD: TXSDate;
    FGTIN: GTIN;
    FXD: TXSDate;
    FBN: BN;
    FBELGE: BELGE;
    FURUNLER: URUNLER;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property DT:      DT       Index (IS_UNQL) read FDT write FDT;
    property MI:      MI       Index (IS_UNQL) read FMI write FMI;
    property PT:      PT       Index (IS_UNQL) read FPT write FPT;
    property MD:      TXSDate  Index (IS_UNQL) read FMD write FMD;
    property GTIN:    GTIN     Index (IS_UNQL) read FGTIN write FGTIN;
    property XD:      TXSDate  Index (IS_UNQL) read FXD write FXD;
    property BN:      BN       Index (IS_UNQL) read FBN write FBN;
    property BELGE:   BELGE    Index (IS_NLBL or IS_UNQL) read FBELGE write FBELGE;
    property URUNLER: URUNLER  Index (IS_UNQL) read FURUNLER write FURUNLER;
  end;

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  BN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  URUNLER2   = array of SNDURUM;                { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Cplx] }


  // ************************************************************************ //
  // XML       : UretimBildirimCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  UretimBildirimCevapType = class(TRemotable)
  private
    FBILDIRIMID: string;
    FMD: TXSDate;
    FGTIN: GTIN2;
    FXD: TXSDate;
    FBN: BN2;
    FURUNLER: URUNLER2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property BILDIRIMID: string    Index (IS_UNQL) read FBILDIRIMID write FBILDIRIMID;
    property MD:         TXSDate   Index (IS_UNQL) read FMD write FMD;
    property GTIN:       GTIN2     Index (IS_UNQL) read FGTIN write FGTIN;
    property XD:         TXSDate   Index (IS_UNQL) read FXD write FXD;
    property BN:         BN2       Index (IS_UNQL) read FBN write FBN;
    property URUNLER:    URUNLER2  Index (IS_UNQL) read FURUNLER write FURUNLER;
  end;

  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Uretim"[Smpl] }


  // ************************************************************************ //
  // XML       : SNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // ************************************************************************ //
  SNDURUM = class(TRemotable)
  private
    FSN: SN2;
    FUC: UC;
  published
    property SN: SN2  Index (IS_UNQL) read FSN write FSN;
    property UC: UC   Index (IS_UNQL) read FUC write FUC;
  end;



  // ************************************************************************ //
  // XML       : Uretim, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // Info      : Wrapper
  // ************************************************************************ //
  Uretim = class(UretimBildirimType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : UretimResponse, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // Info      : Wrapper
  // ************************************************************************ //
  UretimResponse = class(UretimBildirimCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : BildirimHata, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
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
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Uretim
  // soapAction: http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/UretimBildirim/UretimBildirRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : UretimBildirimReceiverBinding
  // service   : UretimBildirimReceiverService
  // port      : UretimBildirimReceiver
  // URL       : http://its.saglik.gov.tr:80/UretimBildirim/UretimBildirimReceiverService
  // ************************************************************************ //
  UretimBildirimReceiver = interface(IInvokable)
  ['{DC6F00B5-A67C-3A54-1F03-71EC95E99A1D}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  UretimBildir(const body: Uretim): UretimResponse; stdcall;
  end;

function GetUretimBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): UretimBildirimReceiver;


implementation
  uses SysUtils;

function GetUretimBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): UretimBildirimReceiver;
const
  defWSDL = 'http://its.saglik.gov.tr/UretimBildirim/UretimBildirimReceiverService?wsdl';
  defURL  = 'http://its.saglik.gov.tr:80/UretimBildirim/UretimBildirimReceiverService';
  defSvc  = 'UretimBildirimReceiverService';
  defPrt  = 'UretimBildirimReceiver';
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
    Result := (RIO as UretimBildirimReceiver);
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

constructor UretimBildirimType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor UretimBildirimType.Destroy;
begin
  SysUtils.FreeAndNil(FMD);
  SysUtils.FreeAndNil(FXD);
  SysUtils.FreeAndNil(FBELGE);
  inherited Destroy;
end;

constructor UretimBildirimCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor UretimBildirimCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  SysUtils.FreeAndNil(FMD);
  SysUtils.FreeAndNil(FXD);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(UretimBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(UretimBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/UretimBildirim/UretimBildirRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(UretimBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(UretimBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(UretimBildirimReceiver), 'UretimBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(MI), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'MI');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PT), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'PT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'DN');
  RemClassRegistry.RegisterXSClass(BELGE, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'BELGE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'URUNLER');
  RemClassRegistry.RegisterXSClass(UretimBildirimType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'UretimBildirimType');
  RemClassRegistry.RegisterSerializeOptions(UretimBildirimType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'BN2', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(UretimBildirimCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'UretimBildirimCevapType');
  RemClassRegistry.RegisterSerializeOptions(UretimBildirimCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'SN2', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'UC');
  RemClassRegistry.RegisterXSClass(SNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'SNDURUM');
  RemClassRegistry.RegisterXSClass(Uretim, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'Uretim');
  RemClassRegistry.RegisterXSClass(UretimResponse, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'UretimResponse');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/Uretim', 'BildirimHata');

end.
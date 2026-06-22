// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoMalAlımReceiver.wsdl
//  >Import : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoMalAlımReceiver.wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (10/10/2011 11:50:47 - - $Rev: 25127 $)
// ************************************************************************ //

unit DepoMalAlmServis;

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

  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[GblCplx] }
  BELGE                = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Cplx] }
  DepoMalAlimType      = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Lit][GblCplx] }
  URUN                 = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Cplx] }
  DepoMalAlimCevapType = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Lit][GblCplx] }
  URUNDURUM            = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Cplx] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Flt][GblElm] }
  DepoMalAlimCevap     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Lit][GblElm] }
  DepoMalAlim          = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Lit][GblElm] }

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }
  FR              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }
  TO_             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }
  DN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : BELGE, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
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

  URUNLER    = array of URUN;                   { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : DepoMalAlimType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalAlimType = class(TRemotable)
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

  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }
  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUN, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
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

  URUNLER2   = array of URUNDURUM;              { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : DepoMalAlimCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalAlimCevapType = class(TRemotable)
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

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }
  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
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
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
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
  // XML       : DepoMalAlimCevap, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalAlimCevap = class(DepoMalAlimCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DepoMalAlim, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  DepoMalAlim = class(DepoMalAlimType)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo
  // soapAction: http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/Alim/Depo/AlimBildirRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DepoMalAlimBildirimReceiverBinding
  // service   : DepoMalAlimReceiverService
  // port      : DepoMalAlimBildirimReceiverBindingPort
  // URL       : http://itstest:8080/DepoMalAlim/DepoMalAlimReceiverService
  // ************************************************************************ //
  DepoMalAlimBildirimReceiver = interface(IInvokable)
  ['{680827EB-EB7A-333A-9D7C-2744F4DECD7F}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  DepoMalAlimBildir(const body: DepoMalAlim): DepoMalAlimCevap; stdcall;
  end;

function GetDepoMalAlimBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DepoMalAlimBildirimReceiver;


implementation
  uses SysUtils;

function GetDepoMalAlimBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DepoMalAlimBildirimReceiver;
const
  defWSDL = 'http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoMalAlımReceiver.wsdl';
  defURL  = 'http://212.174.130.240/DepoMalAlim/DepoMalAlimReceiverService';
  defSvc  = 'DepoMalAlimReceiverService';
  defPrt  = 'DepoMalAlimBildirimReceiverBindingPort';
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
    Result := (RIO as DepoMalAlimBildirimReceiver);
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

constructor DepoMalAlimType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DepoMalAlimType.Destroy;
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

constructor DepoMalAlimCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DepoMalAlimCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(DepoMalAlimBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DepoMalAlimBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/Alim/Depo/AlimBildirRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(DepoMalAlimBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(DepoMalAlimBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(DepoMalAlimBildirimReceiver), 'DepoMalAlimBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FR), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'FR');
  RemClassRegistry.RegisterXSInfo(TypeInfo(TO_), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'TO_', 'TO');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'DN');
  RemClassRegistry.RegisterXSClass(BELGE, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'BELGE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DepoMalAlimType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'DepoMalAlimType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(DepoMalAlimType), 'TO_', 'TO');
  RemClassRegistry.RegisterSerializeOptions(DepoMalAlimType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'SN');
  RemClassRegistry.RegisterXSClass(URUN, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'URUN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DepoMalAlimCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'DepoMalAlimCevapType');
  RemClassRegistry.RegisterSerializeOptions(DepoMalAlimCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'SN2', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'UC');
  RemClassRegistry.RegisterXSClass(URUNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'URUNDURUM');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'BildirimHata');
  RemClassRegistry.RegisterXSClass(DepoMalAlimCevap, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'DepoMalAlimCevap');
  RemClassRegistry.RegisterXSClass(DepoMalAlim, 'http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo', 'DepoMalAlim');

end.

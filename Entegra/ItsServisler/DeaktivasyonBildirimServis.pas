// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.iegm.gov.tr/Folders/file/its/wsdl/DeaktivasyonBildirimReceiver.wsdl
//  >Import : http://www.iegm.gov.tr/Folders/file/its/wsdl/DeaktivasyonBildirimReceiver.wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (15/10/2011 10:55:02 - - $Rev: 25127 $)
// ************************************************************************ //

unit DeaktivasyonBildirimServis;

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

  DeaktivasyonBildirimCevapType = class;        { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Lit][GblCplx] }
  URUNDURUM            = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Cplx] }
  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[GblCplx] }
  BELGE                = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Cplx] }
  DeaktivasyonBildirimType = class;             { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Lit][GblCplx] }
  URUN                 = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Cplx] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Flt][GblElm] }
  DeaktivasyonBildirimCevap = class;            { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Lit][GblElm] }
  DeaktivasyonBildirim = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Lit][GblElm] }

  URUNLER    = array of URUNDURUM;              { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Cplx] }


  // ************************************************************************ //
  // XML       : DeaktivasyonBildirimCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DeaktivasyonBildirimCevapType = class(TRemotable)
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

  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }
  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }


  // ************************************************************************ //
  // XML       : URUNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
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

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }
  FR              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }
  DS              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }
  DN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }


  // ************************************************************************ //
  // XML       : BELGE, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
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

  URUNLER2   = array of URUN;                   { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Cplx] }


  // ************************************************************************ //
  // XML       : DeaktivasyonBildirimType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  DeaktivasyonBildirimType = class(TRemotable)
  private
    FDT: DT;
    FFR: FR;
    FDS: DS;
    FISACIKLAMA: string;
    FBELGE: BELGE;
    FURUNLER: URUNLER2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property DT:         DT        Index (IS_UNQL) read FDT write FDT;
    property FR:         FR        Index (IS_UNQL) read FFR write FFR;
    property DS:         DS        Index (IS_UNQL) read FDS write FDS;
    property ISACIKLAMA: string    Index (IS_UNQL) read FISACIKLAMA write FISACIKLAMA;
    property BELGE:      BELGE     Index (IS_NLBL or IS_UNQL) read FBELGE write FBELGE;
    property URUNLER:    URUNLER2  Index (IS_UNQL) read FURUNLER write FURUNLER;
  end;

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }
  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon"[Smpl] }


  // ************************************************************************ //
  // XML       : URUN, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
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
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
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
  // XML       : DeaktivasyonBildirimCevap, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
  // Info      : Wrapper
  // ************************************************************************ //
  DeaktivasyonBildirimCevap = class(DeaktivasyonBildirimCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DeaktivasyonBildirim, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
  // Info      : Wrapper
  // ************************************************************************ //
  DeaktivasyonBildirim = class(DeaktivasyonBildirimType)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon
  // soapAction: http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/DeaktivasyonBildirRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DeaktivasyonBildirimReceiverBinding
  // service   : DeaktivasyonBildirimReceiverService
  // port      : DeaktivasyonBildirimReceiverBindingPort
  // URL       : http://itstest:8080/DeaktivasyonBildirim/DeaktivasyonBildirimReceiverService
  // ************************************************************************ //
  DeaktivasyonBildirimReceiver = interface(IInvokable)
  ['{ABD7C6B5-F7E3-D378-85C0-D5CE2C2FA29F}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  DeaktivasyonBildir(const body: DeaktivasyonBildirim): DeaktivasyonBildirimCevap; stdcall;
  end;

function GetDeaktivasyonBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): DeaktivasyonBildirimReceiver;


implementation
  uses SysUtils;

function GetDeaktivasyonBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): DeaktivasyonBildirimReceiver;
const
  defWSDL = 'http://www.iegm.gov.tr/Folders/file/its/wsdl/DeaktivasyonBildirimReceiver.wsdl';
  defURL  = 'http://212.174.130.240/DeaktivasyonBildirim/DeaktivasyonBildirimReceiverService';
  defSvc  = 'DeaktivasyonBildirimReceiverService';
  defPrt  = 'DeaktivasyonBildirimReceiverBindingPort';
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
    Result := (RIO as DeaktivasyonBildirimReceiver);
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


constructor DeaktivasyonBildirimCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DeaktivasyonBildirimCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

destructor BELGE.Destroy;
begin
  SysUtils.FreeAndNil(FDD);
  inherited Destroy;
end;

constructor DeaktivasyonBildirimType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor DeaktivasyonBildirimType.Destroy;
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

initialization
  InvRegistry.RegisterInterface(TypeInfo(DeaktivasyonBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(DeaktivasyonBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/DeaktivasyonBildirRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(DeaktivasyonBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(DeaktivasyonBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(DeaktivasyonBildirimReceiver), 'DeaktivasyonBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DeaktivasyonBildirimCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'DeaktivasyonBildirimCevapType');
  RemClassRegistry.RegisterSerializeOptions(DeaktivasyonBildirimCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'UC');
  RemClassRegistry.RegisterXSClass(URUNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'URUNDURUM');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FR), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'FR');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DS), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'DS');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'DN');
  RemClassRegistry.RegisterXSClass(BELGE, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'BELGE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(DeaktivasyonBildirimType, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'DeaktivasyonBildirimType');
  RemClassRegistry.RegisterSerializeOptions(DeaktivasyonBildirimType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'SN2', 'SN');
  RemClassRegistry.RegisterXSClass(URUN, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'URUN');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'BildirimHata');
  RemClassRegistry.RegisterXSClass(DeaktivasyonBildirimCevap, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'DeaktivasyonBildirimCevap');
  RemClassRegistry.RegisterXSClass(DeaktivasyonBildirim, 'http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon', 'DeaktivasyonBildirim');

end.

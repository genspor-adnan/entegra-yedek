// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoSatisIptalReceiver.wsdl
//  >Import : http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoSatisIptalReceiver.wsdl>0
// Encoding : UTF-8
// Codegen  : [wfForceSOAP11+]
// Version  : 1.0
// (12/10/2011 13:48:49 - - $Rev: 25127 $)
// ************************************************************************ //

unit DepoSatisIptalServis;

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

  BildirimHataType     = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[GblCplx] }
  BELGE                = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Cplx] }
  SatisIptalBildirimType = class;               { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Lit][GblCplx] }
  URUN                 = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Cplx] }
  SatisIptalBildirimCevapType = class;          { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Lit][GblCplx] }
  URUNDURUM            = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Cplx] }
  BildirimHata         = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Flt][GblElm] }
  SatisIptalBildirimCevap = class;              { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Lit][GblElm] }
  SatisIptalBildirim   = class;                 { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Lit][GblElm] }

  FC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : BildirimHataType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
  // ************************************************************************ //
  BildirimHataType = class(TRemotable)
  private
    FFC: FC;
    FFM: string;
  published
    property FC: FC      Index (IS_UNQL) read FFC write FFC;
    property FM: string  Index (IS_UNQL) read FFM write FFM;
  end;

  DT              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  FR              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  TO_             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  DN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : BELGE, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
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

  URUNLER    = array of URUN;                   { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : SatisIptalBildirimType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SatisIptalBildirimType = class(TRemotable)
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

  GTIN            =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  BN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  SN              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUN, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
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

  URUNLER2   = array of URUNDURUM;              { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Cplx] }


  // ************************************************************************ //
  // XML       : SatisIptalBildirimCevapType, global, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SatisIptalBildirimCevapType = class(TRemotable)
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

  GTIN2           =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  BN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  SN2             =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }
  UC              =  type string;      { "http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo"[Smpl] }


  // ************************************************************************ //
  // XML       : URUNDURUM, <complexType>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
  // ************************************************************************ //
  URUNDURUM = class(TRemotable)
  private
    FGTIN: GTIN2;
    FXD: TXSDate;
    FBN: BN2;
    FSN: SN2;
    FUC: UC;
  public
    destructor Destroy; override;
  published
    property GTIN: GTIN2    Index (IS_UNQL) read FGTIN write FGTIN;
    property XD:   TXSDate  Index (IS_UNQL) read FXD write FXD;
    property BN:   BN2      Index (IS_UNQL) read FBN write FBN;
    property SN:   SN2      Index (IS_UNQL) read FSN write FSN;
    property UC:   UC       Index (IS_UNQL) read FUC write FUC;
  end;



  // ************************************************************************ //
  // XML       : BildirimHata, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
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
  // XML       : SatisIptalBildirimCevap, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  SatisIptalBildirimCevap = class(SatisIptalBildirimCevapType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : SatisIptalBildirim, global, <element>
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
  // Info      : Wrapper
  // ************************************************************************ //
  SatisIptalBildirim = class(SatisIptalBildirimType)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo
  // soapAction: http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/SatisIptal/Depo/SatisIptalBildirRequest
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : SatisIptalBildirimReceiverBinding
  // service   : DepoSatisIptalReceiverService
  // port      : SatisIptalBildirimReceiverBindingPort
  // URL       : http://itstest:8080/DepoSatisIptal/DepoSatisIptalReceiverService
  // ************************************************************************ //
  SatisIptalBildirimReceiver = interface(IInvokable)
  ['{90443DD6-5408-DBB1-FA64-A718B2C8BDA0}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  SatisIptalBildir(const body: SatisIptalBildirim): SatisIptalBildirimCevap; stdcall;
  end;

function GetSatisIptalBildirimReceiver(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SatisIptalBildirimReceiver;


implementation
  uses SysUtils;

function GetSatisIptalBildirimReceiver(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SatisIptalBildirimReceiver;
const
  defWSDL = 'http://www.iegm.gov.tr/Folders/file/its/wsdl/DepoSatisIptalReceiver.wsdl';
  defURL  = 'http://212.174.130.240/DepoSatisIptal/DepoSatisIptalReceiverService';
  defSvc  = 'DepoSatisIptalReceiverService';
  defPrt  = 'SatisIptalBildirimReceiverBindingPort';
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
    Result := (RIO as SatisIptalBildirimReceiver);
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

constructor SatisIptalBildirimType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SatisIptalBildirimType.Destroy;
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

constructor SatisIptalBildirimCevapType.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SatisIptalBildirimCevapType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FURUNLER)-1 do
    SysUtils.FreeAndNil(FURUNLER[I]);
  System.SetLength(FURUNLER, 0);
  inherited Destroy;
end;

destructor URUNDURUM.Destroy;
begin
  SysUtils.FreeAndNil(FXD);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(SatisIptalBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SatisIptalBildirimReceiver), 'http://its.iegm.gov.tr/bildirim/BildirimReceiver/v1/SatisIptal/Depo/SatisIptalBildirRequest');
  InvRegistry.RegisterInvokeOptions(TypeInfo(SatisIptalBildirimReceiver), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(SatisIptalBildirimReceiver), ioLiteral);
  InvRegistry.RegisterExternalParamName(TypeInfo(SatisIptalBildirimReceiver), 'SatisIptalBildir', 'body1', 'body');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FC), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'FC');
  RemClassRegistry.RegisterXSClass(BildirimHataType, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'BildirimHataType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DT), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'DT');
  RemClassRegistry.RegisterXSInfo(TypeInfo(FR), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'FR');
  RemClassRegistry.RegisterXSInfo(TypeInfo(TO_), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'TO_', 'TO');
  RemClassRegistry.RegisterXSInfo(TypeInfo(DN), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'DN');
  RemClassRegistry.RegisterXSClass(BELGE, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'BELGE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'URUNLER');
  RemClassRegistry.RegisterXSClass(SatisIptalBildirimType, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'SatisIptalBildirimType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(SatisIptalBildirimType), 'TO_', 'TO');
  RemClassRegistry.RegisterSerializeOptions(SatisIptalBildirimType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'SN');
  RemClassRegistry.RegisterXSClass(URUN, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'URUN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(URUNLER2), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'URUNLER2', 'URUNLER');
  RemClassRegistry.RegisterXSClass(SatisIptalBildirimCevapType, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'SatisIptalBildirimCevapType');
  RemClassRegistry.RegisterSerializeOptions(SatisIptalBildirimCevapType, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GTIN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'GTIN2', 'GTIN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'BN2', 'BN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SN2), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'SN2', 'SN');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UC), 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'UC');
  RemClassRegistry.RegisterXSClass(URUNDURUM, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'URUNDURUM');
  RemClassRegistry.RegisterXSClass(BildirimHata, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'BildirimHata');
  RemClassRegistry.RegisterXSClass(SatisIptalBildirimCevap, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'SatisIptalBildirimCevap');
  RemClassRegistry.RegisterXSClass(SatisIptalBildirim, 'http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo', 'SatisIptalBildirim');

end.

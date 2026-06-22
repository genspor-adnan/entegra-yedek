// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://94.55.151.106/MSS_Service/MSS_Sender.asmx?wsdl
//  >Import : http://94.55.151.106/MSS_Service/MSS_Sender.asmx?wsdl>0
// Encoding : utf-8
// Version  : 1.0
// (12/05/2011 15:37:16 - - $Rev: 24171 $)
// ************************************************************************ //

unit MSS_Sender;

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
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]

  Result               = class;                 { "http://mss_sender.ega.com.tr/"[GblCplx] }
  HashResult           = class;                 { "http://mss_sender.ega.com.tr/"[GblCplx] }
  MonetaryLimit        = class;                 { "http://mss_sender.ega.com.tr/"[GblCplx] }
  SignatureResult      = class;                 { "http://mss_sender.ega.com.tr/"[GblCplx] }
  SignatureByteResult  = class;                 { "http://mss_sender.ega.com.tr/"[GblCplx] }



  // ************************************************************************ //
  // XML       : Result, global, <complexType>
  // Namespace : http://mss_sender.ega.com.tr/
  // ************************************************************************ //
  Result = class(TRemotable)
  private
    FIsSuccessful: Boolean;
    FResultCode: Integer;
    FMessage_: string;
    FMessage__Specified: boolean;
    procedure SetMessage_(Index: Integer; const Astring: string);
    function  Message__Specified(Index: Integer): boolean;
  published
    property IsSuccessful: Boolean  read FIsSuccessful write FIsSuccessful;
    property ResultCode:   Integer  read FResultCode write FResultCode;
    property Message_:     string   Index (IS_OPTN) read FMessage_ write SetMessage_ stored Message__Specified;
  end;



  // ************************************************************************ //
  // XML       : HashResult, global, <complexType>
  // Namespace : http://mss_sender.ega.com.tr/
  // ************************************************************************ //
  HashResult = class(Result)
  private
    FParmakIzi: string;
    FParmakIzi_Specified: boolean;
    FApTransId: string;
    FApTransId_Specified: boolean;
    procedure SetParmakIzi(Index: Integer; const Astring: string);
    function  ParmakIzi_Specified(Index: Integer): boolean;
    procedure SetApTransId(Index: Integer; const Astring: string);
    function  ApTransId_Specified(Index: Integer): boolean;
  published
    property ParmakIzi: string  Index (IS_OPTN) read FParmakIzi write SetParmakIzi stored ParmakIzi_Specified;
    property ApTransId: string  Index (IS_OPTN) read FApTransId write SetApTransId stored ApTransId_Specified;
  end;



  // ************************************************************************ //
  // XML       : MonetaryLimit, global, <complexType>
  // Namespace : http://mss_sender.ega.com.tr/
  // ************************************************************************ //
  MonetaryLimit = class(TRemotable)
  private
    FAmount: Integer;
    FExponent: Integer;
    FType_: Integer;
  published
    property Amount:   Integer  read FAmount write FAmount;
    property Exponent: Integer  read FExponent write FExponent;
    property Type_:    Integer  read FType_ write FType_;
  end;



  // ************************************************************************ //
  // XML       : SignatureResult, global, <complexType>
  // Namespace : http://mss_sender.ega.com.tr/
  // ************************************************************************ //
  SignatureResult = class(Result)
  private
    FSignerName: string;
    FSignerName_Specified: boolean;
    FTcKimlikNo: string;
    FTcKimlikNo_Specified: boolean;
    FGsmOperator: Integer;
    FEmail: string;
    FEmail_Specified: boolean;
    FPlaceOfBirth: string;
    FPlaceOfBirth_Specified: boolean;
    FSignedData: string;
    FSignedData_Specified: boolean;
    FTransId: string;
    FTransId_Specified: boolean;
    FMonetaryLimit: MonetaryLimit;
    FMonetaryLimit_Specified: boolean;
    FSignatureDate: TXSDateTime;
    procedure SetSignerName(Index: Integer; const Astring: string);
    function  SignerName_Specified(Index: Integer): boolean;
    procedure SetTcKimlikNo(Index: Integer; const Astring: string);
    function  TcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetEmail(Index: Integer; const Astring: string);
    function  Email_Specified(Index: Integer): boolean;
    procedure SetPlaceOfBirth(Index: Integer; const Astring: string);
    function  PlaceOfBirth_Specified(Index: Integer): boolean;
    procedure SetSignedData(Index: Integer; const Astring: string);
    function  SignedData_Specified(Index: Integer): boolean;
    procedure SetTransId(Index: Integer; const Astring: string);
    function  TransId_Specified(Index: Integer): boolean;
    procedure SetMonetaryLimit(Index: Integer; const AMonetaryLimit: MonetaryLimit);
    function  MonetaryLimit_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property SignerName:    string         Index (IS_OPTN) read FSignerName write SetSignerName stored SignerName_Specified;
    property TcKimlikNo:    string         Index (IS_OPTN) read FTcKimlikNo write SetTcKimlikNo stored TcKimlikNo_Specified;
    property GsmOperator:   Integer        read FGsmOperator write FGsmOperator;
    property Email:         string         Index (IS_OPTN) read FEmail write SetEmail stored Email_Specified;
    property PlaceOfBirth:  string         Index (IS_OPTN) read FPlaceOfBirth write SetPlaceOfBirth stored PlaceOfBirth_Specified;
    property SignedData:    string         Index (IS_OPTN) read FSignedData write SetSignedData stored SignedData_Specified;
    property TransId:       string         Index (IS_OPTN) read FTransId write SetTransId stored TransId_Specified;
    property MonetaryLimit: MonetaryLimit  Index (IS_OPTN) read FMonetaryLimit write SetMonetaryLimit stored MonetaryLimit_Specified;
    property SignatureDate: TXSDateTime    read FSignatureDate write FSignatureDate;
  end;



  // ************************************************************************ //
  // XML       : SignatureByteResult, global, <complexType>
  // Namespace : http://mss_sender.ega.com.tr/
  // ************************************************************************ //
  SignatureByteResult = class(Result)
  private
    FSignerName: string;
    FSignerName_Specified: boolean;
    FTcKimlikNo: string;
    FTcKimlikNo_Specified: boolean;
    FGsmOperator: Integer;
    FEmail: string;
    FEmail_Specified: boolean;
    FPlaceOfBirth: string;
    FPlaceOfBirth_Specified: boolean;
    FSignedData: TByteDynArray;
    FSignedData_Specified: boolean;
    FTransId: string;
    FTransId_Specified: boolean;
    FMonetaryLimit: MonetaryLimit;
    FMonetaryLimit_Specified: boolean;
    FSignatureDate: TXSDateTime;
    procedure SetSignerName(Index: Integer; const Astring: string);
    function  SignerName_Specified(Index: Integer): boolean;
    procedure SetTcKimlikNo(Index: Integer; const Astring: string);
    function  TcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetEmail(Index: Integer; const Astring: string);
    function  Email_Specified(Index: Integer): boolean;
    procedure SetPlaceOfBirth(Index: Integer; const Astring: string);
    function  PlaceOfBirth_Specified(Index: Integer): boolean;
    procedure SetSignedData(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  SignedData_Specified(Index: Integer): boolean;
    procedure SetTransId(Index: Integer; const Astring: string);
    function  TransId_Specified(Index: Integer): boolean;
    procedure SetMonetaryLimit(Index: Integer; const AMonetaryLimit: MonetaryLimit);
    function  MonetaryLimit_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property SignerName:    string         Index (IS_OPTN) read FSignerName write SetSignerName stored SignerName_Specified;
    property TcKimlikNo:    string         Index (IS_OPTN) read FTcKimlikNo write SetTcKimlikNo stored TcKimlikNo_Specified;
    property GsmOperator:   Integer        read FGsmOperator write FGsmOperator;
    property Email:         string         Index (IS_OPTN) read FEmail write SetEmail stored Email_Specified;
    property PlaceOfBirth:  string         Index (IS_OPTN) read FPlaceOfBirth write SetPlaceOfBirth stored PlaceOfBirth_Specified;
    property SignedData:    TByteDynArray  Index (IS_OPTN) read FSignedData write SetSignedData stored SignedData_Specified;
    property TransId:       string         Index (IS_OPTN) read FTransId write SetTransId stored TransId_Specified;
    property MonetaryLimit: MonetaryLimit  Index (IS_OPTN) read FMonetaryLimit write SetMonetaryLimit stored MonetaryLimit_Specified;
    property SignatureDate: TXSDateTime    read FSignatureDate write FSignatureDate;
  end;


  // ************************************************************************ //
  // Namespace : http://mss_sender.ega.com.tr/
  // soapAction: http://mss_sender.ega.com.tr/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : MSS_SenderSoap12
  // service   : MSS_Sender
  // port      : MSS_SenderSoap12
  // URL       : http://94.55.151.106/MSS_Service/MSS_Sender.asmx
  // ************************************************************************ //
  MSS_SenderSoap = interface(IInvokable)
  ['{64702915-31CC-A783-88BE-C1BAD0173FE6}']
    function  GetHash(const data: TByteDynArray; const telNo: string): HashResult; stdcall;
    function  GetSignature(const dataToBeDisplayed: string; const apTransId: string): SignatureResult; stdcall;
    function  GetSignatureByte(const dataToBeDisplayed: string; const apTransId: string): SignatureByteResult; stdcall;
    function  GetFingerPrint(const hash: TByteDynArray; const telNo: string): HashResult; stdcall;
    function  GetSignatureByHash(const dataToBeDisplayed: string; const apTransId: string): SignatureResult; stdcall;
    function  GetHashForSignedData(const signedData: TByteDynArray; const telNo: string): HashResult; stdcall;
    function  AddSignature(const dataToBeDisplayed: string; const apTransId: string): SignatureResult; stdcall;
    function  AddSignatureByte(const dataToBeDisplayed: string; const apTransId: string): SignatureByteResult; stdcall;
    function  GetHashForGsmOperator(const data: TByteDynArray; const telNo: string; const gsmOperator: Integer): HashResult; stdcall;
    function  GetFingerPrintForGsmOperator(const hash: TByteDynArray; const telNo: string; const gsmOperator: Integer): HashResult; stdcall;
    function  GetHashForSignedDataForGsmOperator(const signedData: TByteDynArray; const telNo: string; const gsmOperator: Integer): HashResult; stdcall;
  end;

function GetMSS_SenderSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): MSS_SenderSoap;


implementation
  uses SysUtils;

function GetMSS_SenderSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): MSS_SenderSoap;
const
  defWSDL = 'http://94.55.151.106/MSS_Service/MSS_Sender.asmx?wsdl';
  defURL  = 'http://94.55.151.106/MSS_Service/MSS_Sender.asmx';
  defSvc  = 'MSS_Sender';
  defPrt  = 'MSS_SenderSoap12';
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
    Result := (RIO as MSS_SenderSoap);
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


procedure Result.SetMessage_(Index: Integer; const Astring: string);
begin
  FMessage_ := Astring;
  FMessage__Specified := True;
end;

function Result.Message__Specified(Index: Integer): boolean;
begin
  Result := FMessage__Specified;
end;

procedure HashResult.SetParmakIzi(Index: Integer; const Astring: string);
begin
  FParmakIzi := Astring;
  FParmakIzi_Specified := True;
end;

function HashResult.ParmakIzi_Specified(Index: Integer): boolean;
begin
  Result := FParmakIzi_Specified;
end;

procedure HashResult.SetApTransId(Index: Integer; const Astring: string);
begin
  FApTransId := Astring;
  FApTransId_Specified := True;
end;

function HashResult.ApTransId_Specified(Index: Integer): boolean;
begin
  Result := FApTransId_Specified;
end;

destructor SignatureResult.Destroy;
begin
  SysUtils.FreeAndNil(FMonetaryLimit);
  SysUtils.FreeAndNil(FSignatureDate);
  inherited Destroy;
end;

procedure SignatureResult.SetSignerName(Index: Integer; const Astring: string);
begin
  FSignerName := Astring;
  FSignerName_Specified := True;
end;

function SignatureResult.SignerName_Specified(Index: Integer): boolean;
begin
  Result := FSignerName_Specified;
end;

procedure SignatureResult.SetTcKimlikNo(Index: Integer; const Astring: string);
begin
  FTcKimlikNo := Astring;
  FTcKimlikNo_Specified := True;
end;

function SignatureResult.TcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FTcKimlikNo_Specified;
end;

procedure SignatureResult.SetEmail(Index: Integer; const Astring: string);
begin
  FEmail := Astring;
  FEmail_Specified := True;
end;

function SignatureResult.Email_Specified(Index: Integer): boolean;
begin
  Result := FEmail_Specified;
end;

procedure SignatureResult.SetPlaceOfBirth(Index: Integer; const Astring: string);
begin
  FPlaceOfBirth := Astring;
  FPlaceOfBirth_Specified := True;
end;

function SignatureResult.PlaceOfBirth_Specified(Index: Integer): boolean;
begin
  Result := FPlaceOfBirth_Specified;
end;

procedure SignatureResult.SetSignedData(Index: Integer; const Astring: string);
begin
  FSignedData := Astring;
  FSignedData_Specified := True;
end;

function SignatureResult.SignedData_Specified(Index: Integer): boolean;
begin
  Result := FSignedData_Specified;
end;

procedure SignatureResult.SetTransId(Index: Integer; const Astring: string);
begin
  FTransId := Astring;
  FTransId_Specified := True;
end;

function SignatureResult.TransId_Specified(Index: Integer): boolean;
begin
  Result := FTransId_Specified;
end;

procedure SignatureResult.SetMonetaryLimit(Index: Integer; const AMonetaryLimit: MonetaryLimit);
begin
  FMonetaryLimit := AMonetaryLimit;
  FMonetaryLimit_Specified := True;
end;

function SignatureResult.MonetaryLimit_Specified(Index: Integer): boolean;
begin
  Result := FMonetaryLimit_Specified;
end;

destructor SignatureByteResult.Destroy;
begin
  SysUtils.FreeAndNil(FMonetaryLimit);
  SysUtils.FreeAndNil(FSignatureDate);
  inherited Destroy;
end;

procedure SignatureByteResult.SetSignerName(Index: Integer; const Astring: string);
begin
  FSignerName := Astring;
  FSignerName_Specified := True;
end;

function SignatureByteResult.SignerName_Specified(Index: Integer): boolean;
begin
  Result := FSignerName_Specified;
end;

procedure SignatureByteResult.SetTcKimlikNo(Index: Integer; const Astring: string);
begin
  FTcKimlikNo := Astring;
  FTcKimlikNo_Specified := True;
end;

function SignatureByteResult.TcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FTcKimlikNo_Specified;
end;

procedure SignatureByteResult.SetEmail(Index: Integer; const Astring: string);
begin
  FEmail := Astring;
  FEmail_Specified := True;
end;

function SignatureByteResult.Email_Specified(Index: Integer): boolean;
begin
  Result := FEmail_Specified;
end;

procedure SignatureByteResult.SetPlaceOfBirth(Index: Integer; const Astring: string);
begin
  FPlaceOfBirth := Astring;
  FPlaceOfBirth_Specified := True;
end;

function SignatureByteResult.PlaceOfBirth_Specified(Index: Integer): boolean;
begin
  Result := FPlaceOfBirth_Specified;
end;

procedure SignatureByteResult.SetSignedData(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  FSignedData := ATByteDynArray;
  FSignedData_Specified := True;
end;

function SignatureByteResult.SignedData_Specified(Index: Integer): boolean;
begin
  Result := FSignedData_Specified;
end;

procedure SignatureByteResult.SetTransId(Index: Integer; const Astring: string);
begin
  FTransId := Astring;
  FTransId_Specified := True;
end;

function SignatureByteResult.TransId_Specified(Index: Integer): boolean;
begin
  Result := FTransId_Specified;
end;

procedure SignatureByteResult.SetMonetaryLimit(Index: Integer; const AMonetaryLimit: MonetaryLimit);
begin
  FMonetaryLimit := AMonetaryLimit;
  FMonetaryLimit_Specified := True;
end;

function SignatureByteResult.MonetaryLimit_Specified(Index: Integer): boolean;
begin
  Result := FMonetaryLimit_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(MSS_SenderSoap), 'http://mss_sender.ega.com.tr/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(MSS_SenderSoap), 'http://mss_sender.ega.com.tr/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(MSS_SenderSoap), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(MSS_SenderSoap), ioSOAP12);
  RemClassRegistry.RegisterXSClass(Result, 'http://mss_sender.ega.com.tr/', 'Result');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Result), 'Message_', 'Message');
  RemClassRegistry.RegisterXSClass(HashResult, 'http://mss_sender.ega.com.tr/', 'HashResult');
  RemClassRegistry.RegisterXSClass(MonetaryLimit, 'http://mss_sender.ega.com.tr/', 'MonetaryLimit');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(MonetaryLimit), 'Type_', 'Type');
  RemClassRegistry.RegisterXSClass(SignatureResult, 'http://mss_sender.ega.com.tr/', 'SignatureResult');
  RemClassRegistry.RegisterXSClass(SignatureByteResult, 'http://mss_sender.ega.com.tr/', 'SignatureByteResult');

end.

// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc?wsdl
//  >Import : http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc?wsdl>0
//  >Import : http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc?xsd=xsd0
//  >Import : http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc?xsd=xsd2
//  >Import : http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc?xsd=xsd3
//  >Import : http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc?xsd=xsd1
// Encoding : utf-8
// Version  : 1.0
// (16/12/2011 15:19:00 - - $Rev: 24171 $)
// ************************************************************************ //

unit RaporiumWS;

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
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]

  BaseModelOfReportSvcBSSoMiEA = class;         { "http://schemas.datacontract.org/2004/07/Raporium.Web"[GblCplx] }
  BaseModelOfReportFileBSSoMiEA = class;        { "http://schemas.datacontract.org/2004/07/Raporium.Web"[GblCplx] }
  BaseModelOfReportSvcBSSoMiEA2 = class;        { "http://schemas.datacontract.org/2004/07/Raporium.Web"[GblElm] }
  BaseModelOfReportFileBSSoMiEA2 = class;       { "http://schemas.datacontract.org/2004/07/Raporium.Web"[GblElm] }
  ReportSvc            = class;                 { "http://schemas.datacontract.org/2004/07/Raporium.Web.Domain"[GblCplx] }
  ReportFile           = class;                 { "http://schemas.datacontract.org/2004/07/Raporium.Web.Domain"[GblCplx] }
  ReportSvc2           = class;                 { "http://schemas.datacontract.org/2004/07/Raporium.Web.Domain"[GblElm] }
  ReportFile2          = class;                 { "http://schemas.datacontract.org/2004/07/Raporium.Web.Domain"[GblElm] }



  // ************************************************************************ //
  // XML       : BaseModelOfReportSvcBSSoMiEA, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web
  // ************************************************************************ //
  BaseModelOfReportSvcBSSoMiEA = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : BaseModelOfReportFileBSSoMiEA, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web
  // ************************************************************************ //
  BaseModelOfReportFileBSSoMiEA = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : BaseModelOfReportSvcBSSoMiEA, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web
  // ************************************************************************ //
  BaseModelOfReportSvcBSSoMiEA2 = class(BaseModelOfReportSvcBSSoMiEA)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : BaseModelOfReportFileBSSoMiEA, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web
  // ************************************************************************ //
  BaseModelOfReportFileBSSoMiEA2 = class(BaseModelOfReportFileBSSoMiEA)
  private
  published
  end;

  ArrayOfReportSvc = array of ReportSvc;        { "http://schemas.datacontract.org/2004/07/Raporium.Web.Domain"[GblCplx] }


  // ************************************************************************ //
  // XML       : ReportSvc, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web.Domain
  // ************************************************************************ //
  ReportSvc = class(BaseModelOfReportSvcBSSoMiEA)
  private
    FACIKLAMA: string;
    FACIKLAMA_Specified: boolean;
    FADSOYAD: string;
    FADSOYAD_Specified: boolean;
    FDEGISTIRMETARIHI: TXSDateTime;
    FDEGISTIRMETARIHI_Specified: boolean;
    FDURUM: string;
    FDURUM_Specified: boolean;
    FEKRANVERSIYON: Integer;
    FEKRANVERSIYON_Specified: boolean;
    FID: Integer;
    FID_Specified: boolean;
    FRAPORADI: string;
    FRAPORADI_Specified: boolean;
    FRAPORTIPI: string;
    FRAPORTIPI_Specified: boolean;
    FSQLVERSIYON: Integer;
    FSQLVERSIYON_Specified: boolean;
    procedure SetACIKLAMA(Index: Integer; const Astring: string);
    function  ACIKLAMA_Specified(Index: Integer): boolean;
    procedure SetADSOYAD(Index: Integer; const Astring: string);
    function  ADSOYAD_Specified(Index: Integer): boolean;
    procedure SetDEGISTIRMETARIHI(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  DEGISTIRMETARIHI_Specified(Index: Integer): boolean;
    procedure SetDURUM(Index: Integer; const Astring: string);
    function  DURUM_Specified(Index: Integer): boolean;
    procedure SetEKRANVERSIYON(Index: Integer; const AInteger: Integer);
    function  EKRANVERSIYON_Specified(Index: Integer): boolean;
    procedure SetID(Index: Integer; const AInteger: Integer);
    function  ID_Specified(Index: Integer): boolean;
    procedure SetRAPORADI(Index: Integer; const Astring: string);
    function  RAPORADI_Specified(Index: Integer): boolean;
    procedure SetRAPORTIPI(Index: Integer; const Astring: string);
    function  RAPORTIPI_Specified(Index: Integer): boolean;
    procedure SetSQLVERSIYON(Index: Integer; const AInteger: Integer);
    function  SQLVERSIYON_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property ACIKLAMA:         string       Index (IS_OPTN or IS_NLBL) read FACIKLAMA write SetACIKLAMA stored ACIKLAMA_Specified;
    property ADSOYAD:          string       Index (IS_OPTN or IS_NLBL) read FADSOYAD write SetADSOYAD stored ADSOYAD_Specified;
    property DEGISTIRMETARIHI: TXSDateTime  Index (IS_OPTN) read FDEGISTIRMETARIHI write SetDEGISTIRMETARIHI stored DEGISTIRMETARIHI_Specified;
    property DURUM:            string       Index (IS_OPTN or IS_NLBL) read FDURUM write SetDURUM stored DURUM_Specified;
    property EKRANVERSIYON:    Integer      Index (IS_OPTN) read FEKRANVERSIYON write SetEKRANVERSIYON stored EKRANVERSIYON_Specified;
    property ID:               Integer      Index (IS_OPTN) read FID write SetID stored ID_Specified;
    property RAPORADI:         string       Index (IS_OPTN or IS_NLBL) read FRAPORADI write SetRAPORADI stored RAPORADI_Specified;
    property RAPORTIPI:        string       Index (IS_OPTN or IS_NLBL) read FRAPORTIPI write SetRAPORTIPI stored RAPORTIPI_Specified;
    property SQLVERSIYON:      Integer      Index (IS_OPTN) read FSQLVERSIYON write SetSQLVERSIYON stored SQLVERSIYON_Specified;
  end;

  ArrayOfReportFile = array of ReportFile;      { "http://schemas.datacontract.org/2004/07/Raporium.Web.Domain"[GblCplx] }


  // ************************************************************************ //
  // XML       : ReportFile, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web.Domain
  // ************************************************************************ //
  ReportFile = class(BaseModelOfReportFileBSSoMiEA)
  private
    FDOSYAADI: string;
    FDOSYAADI_Specified: boolean;
    FDOSYAICERIK: TByteDynArray;
    FDOSYAICERIK_Specified: boolean;
    FDOSYATURU: Integer;
    FDOSYATURU_Specified: boolean;
    FEKLEMETARIHI: TXSDateTime;
    FEKLEMETARIHI_Specified: boolean;
    FEKLEYEN: Integer;
    FEKLEYEN_Specified: boolean;
    FID: Integer;
    FID_Specified: boolean;
    FRAPORID: Integer;
    FRAPORID_Specified: boolean;
    procedure SetDOSYAADI(Index: Integer; const Astring: string);
    function  DOSYAADI_Specified(Index: Integer): boolean;
    procedure SetDOSYAICERIK(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  DOSYAICERIK_Specified(Index: Integer): boolean;
    procedure SetDOSYATURU(Index: Integer; const AInteger: Integer);
    function  DOSYATURU_Specified(Index: Integer): boolean;
    procedure SetEKLEMETARIHI(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  EKLEMETARIHI_Specified(Index: Integer): boolean;
    procedure SetEKLEYEN(Index: Integer; const AInteger: Integer);
    function  EKLEYEN_Specified(Index: Integer): boolean;
    procedure SetID(Index: Integer; const AInteger: Integer);
    function  ID_Specified(Index: Integer): boolean;
    procedure SetRAPORID(Index: Integer; const AInteger: Integer);
    function  RAPORID_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property DOSYAADI:     string         Index (IS_OPTN or IS_NLBL) read FDOSYAADI write SetDOSYAADI stored DOSYAADI_Specified;
    property DOSYAICERIK:  TByteDynArray  Index (IS_OPTN or IS_NLBL) read FDOSYAICERIK write SetDOSYAICERIK stored DOSYAICERIK_Specified;
    property DOSYATURU:    Integer        Index (IS_OPTN) read FDOSYATURU write SetDOSYATURU stored DOSYATURU_Specified;
    property EKLEMETARIHI: TXSDateTime    Index (IS_OPTN) read FEKLEMETARIHI write SetEKLEMETARIHI stored EKLEMETARIHI_Specified;
    property EKLEYEN:      Integer        Index (IS_OPTN) read FEKLEYEN write SetEKLEYEN stored EKLEYEN_Specified;
    property ID:           Integer        Index (IS_OPTN) read FID write SetID stored ID_Specified;
    property RAPORID:      Integer        Index (IS_OPTN) read FRAPORID write SetRAPORID stored RAPORID_Specified;
  end;



  // ************************************************************************ //
  // XML       : ReportSvc, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web.Domain
  // ************************************************************************ //
  ReportSvc2 = class(ReportSvc)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ReportFile, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/Raporium.Web.Domain
  // ************************************************************************ //
  ReportFile2 = class(ReportFile)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/IRaporiumWS/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_IRaporiumWS
  // service   : RaporiumWS
  // port      : BasicHttpBinding_IRaporiumWS
  // URL       : http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc
  // ************************************************************************ //
  IRaporiumWS = interface(IInvokable)
  ['{8AEE3B62-4963-AD3A-9AD8-C5E3A515C1EE}']
    function  TarihSorgu(const tarih: TXSDateTime): ArrayOfReportSvc; stdcall;
    function  Dosyalar(const raporid: Integer): ArrayOfReportFile; stdcall;
  end;

function GetIRaporiumWS(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IRaporiumWS;


implementation
  uses SysUtils;

function GetIRaporiumWS(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IRaporiumWS;
const
  defWSDL = 'http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc?wsdl';
  defURL  = 'http://genlisans.genyazilim.com/Raporium/DataServices/RaporiumWS.svc';
  defSvc  = 'RaporiumWS';
  defPrt  = 'BasicHttpBinding_IRaporiumWS';
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
    Result := (RIO as IRaporiumWS);
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


destructor ReportSvc.Destroy;
begin
  SysUtils.FreeAndNil(FDEGISTIRMETARIHI);
  inherited Destroy;
end;

procedure ReportSvc.SetACIKLAMA(Index: Integer; const Astring: string);
begin
  FACIKLAMA := Astring;
  FACIKLAMA_Specified := True;
end;

function ReportSvc.ACIKLAMA_Specified(Index: Integer): boolean;
begin
  Result := FACIKLAMA_Specified;
end;

procedure ReportSvc.SetADSOYAD(Index: Integer; const Astring: string);
begin
  FADSOYAD := Astring;
  FADSOYAD_Specified := True;
end;

function ReportSvc.ADSOYAD_Specified(Index: Integer): boolean;
begin
  Result := FADSOYAD_Specified;
end;

procedure ReportSvc.SetDEGISTIRMETARIHI(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  FDEGISTIRMETARIHI := ATXSDateTime;
  FDEGISTIRMETARIHI_Specified := True;
end;

function ReportSvc.DEGISTIRMETARIHI_Specified(Index: Integer): boolean;
begin
  Result := FDEGISTIRMETARIHI_Specified;
end;

procedure ReportSvc.SetDURUM(Index: Integer; const Astring: string);
begin
  FDURUM := Astring;
  FDURUM_Specified := True;
end;

function ReportSvc.DURUM_Specified(Index: Integer): boolean;
begin
  Result := FDURUM_Specified;
end;

procedure ReportSvc.SetEKRANVERSIYON(Index: Integer; const AInteger: Integer);
begin
  FEKRANVERSIYON := AInteger;
  FEKRANVERSIYON_Specified := True;
end;

function ReportSvc.EKRANVERSIYON_Specified(Index: Integer): boolean;
begin
  Result := FEKRANVERSIYON_Specified;
end;

procedure ReportSvc.SetID(Index: Integer; const AInteger: Integer);
begin
  FID := AInteger;
  FID_Specified := True;
end;

function ReportSvc.ID_Specified(Index: Integer): boolean;
begin
  Result := FID_Specified;
end;

procedure ReportSvc.SetRAPORADI(Index: Integer; const Astring: string);
begin
  FRAPORADI := Astring;
  FRAPORADI_Specified := True;
end;

function ReportSvc.RAPORADI_Specified(Index: Integer): boolean;
begin
  Result := FRAPORADI_Specified;
end;

procedure ReportSvc.SetRAPORTIPI(Index: Integer; const Astring: string);
begin
  FRAPORTIPI := Astring;
  FRAPORTIPI_Specified := True;
end;

function ReportSvc.RAPORTIPI_Specified(Index: Integer): boolean;
begin
  Result := FRAPORTIPI_Specified;
end;

procedure ReportSvc.SetSQLVERSIYON(Index: Integer; const AInteger: Integer);
begin
  FSQLVERSIYON := AInteger;
  FSQLVERSIYON_Specified := True;
end;

function ReportSvc.SQLVERSIYON_Specified(Index: Integer): boolean;
begin
  Result := FSQLVERSIYON_Specified;
end;

destructor ReportFile.Destroy;
begin
  SysUtils.FreeAndNil(FEKLEMETARIHI);
  inherited Destroy;
end;

procedure ReportFile.SetDOSYAADI(Index: Integer; const Astring: string);
begin
  FDOSYAADI := Astring;
  FDOSYAADI_Specified := True;
end;

function ReportFile.DOSYAADI_Specified(Index: Integer): boolean;
begin
  Result := FDOSYAADI_Specified;
end;

procedure ReportFile.SetDOSYAICERIK(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  FDOSYAICERIK := ATByteDynArray;
  FDOSYAICERIK_Specified := True;
end;

function ReportFile.DOSYAICERIK_Specified(Index: Integer): boolean;
begin
  Result := FDOSYAICERIK_Specified;
end;

procedure ReportFile.SetDOSYATURU(Index: Integer; const AInteger: Integer);
begin
  FDOSYATURU := AInteger;
  FDOSYATURU_Specified := True;
end;

function ReportFile.DOSYATURU_Specified(Index: Integer): boolean;
begin
  Result := FDOSYATURU_Specified;
end;

procedure ReportFile.SetEKLEMETARIHI(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  FEKLEMETARIHI := ATXSDateTime;
  FEKLEMETARIHI_Specified := True;
end;

function ReportFile.EKLEMETARIHI_Specified(Index: Integer): boolean;
begin
  Result := FEKLEMETARIHI_Specified;
end;

procedure ReportFile.SetEKLEYEN(Index: Integer; const AInteger: Integer);
begin
  FEKLEYEN := AInteger;
  FEKLEYEN_Specified := True;
end;

function ReportFile.EKLEYEN_Specified(Index: Integer): boolean;
begin
  Result := FEKLEYEN_Specified;
end;

procedure ReportFile.SetID(Index: Integer; const AInteger: Integer);
begin
  FID := AInteger;
  FID_Specified := True;
end;

function ReportFile.ID_Specified(Index: Integer): boolean;
begin
  Result := FID_Specified;
end;

procedure ReportFile.SetRAPORID(Index: Integer; const AInteger: Integer);
begin
  FRAPORID := AInteger;
  FRAPORID_Specified := True;
end;

function ReportFile.RAPORID_Specified(Index: Integer): boolean;
begin
  Result := FRAPORID_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IRaporiumWS), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IRaporiumWS), 'http://tempuri.org/IRaporiumWS/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IRaporiumWS), ioDocument);
  RemClassRegistry.RegisterXSClass(BaseModelOfReportSvcBSSoMiEA, 'http://schemas.datacontract.org/2004/07/Raporium.Web', 'BaseModelOfReportSvcBSSoMiEA');
  RemClassRegistry.RegisterXSClass(BaseModelOfReportFileBSSoMiEA, 'http://schemas.datacontract.org/2004/07/Raporium.Web', 'BaseModelOfReportFileBSSoMiEA');
  RemClassRegistry.RegisterXSClass(BaseModelOfReportSvcBSSoMiEA2, 'http://schemas.datacontract.org/2004/07/Raporium.Web', 'BaseModelOfReportSvcBSSoMiEA2', 'BaseModelOfReportSvcBSSoMiEA');
  RemClassRegistry.RegisterXSClass(BaseModelOfReportFileBSSoMiEA2, 'http://schemas.datacontract.org/2004/07/Raporium.Web', 'BaseModelOfReportFileBSSoMiEA2', 'BaseModelOfReportFileBSSoMiEA');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfReportSvc), 'http://schemas.datacontract.org/2004/07/Raporium.Web.Domain', 'ArrayOfReportSvc');
  RemClassRegistry.RegisterXSClass(ReportSvc, 'http://schemas.datacontract.org/2004/07/Raporium.Web.Domain', 'ReportSvc');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfReportFile), 'http://schemas.datacontract.org/2004/07/Raporium.Web.Domain', 'ArrayOfReportFile');
  RemClassRegistry.RegisterXSClass(ReportFile, 'http://schemas.datacontract.org/2004/07/Raporium.Web.Domain', 'ReportFile');
  RemClassRegistry.RegisterXSClass(ReportSvc2, 'http://schemas.datacontract.org/2004/07/Raporium.Web.Domain', 'ReportSvc2', 'ReportSvc');
  RemClassRegistry.RegisterXSClass(ReportFile2, 'http://schemas.datacontract.org/2004/07/Raporium.Web.Domain', 'ReportFile2', 'ReportFile');

end.
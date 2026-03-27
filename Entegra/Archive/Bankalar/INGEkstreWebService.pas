// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://cm-online.ingbank.com.tr/ekstre.asmx?WSDL
//  >Import : https://cm-online.ingbank.com.tr/ekstre.asmx?WSDL>0
// Encoding : utf-8
// Version  : 1.0
// (31/05/2011 13:56:24 - - $Rev: 24171 $)
// ************************************************************************ //

unit INGEkstreWebService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
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

  HareketlerBakiyeHesapHareketlerDetay = class;   { "http://cm-online.ingbank.com.tr/"[GblCplx] }
  HareketlerBakiye     = class;                 { "http://cm-online.ingbank.com.tr/"[GblCplx] }
  Hareketler           = class;                 { "http://cm-online.ingbank.com.tr/"[GblElm] }
  HareketlerBakiyeHesap = class;                { "http://cm-online.ingbank.com.tr/"[GblCplx] }



  // ************************************************************************ //
  // XML       : HareketlerBakiyeHesapHareketlerDetay, global, <complexType>
  // Namespace : http://cm-online.ingbank.com.tr/
  // ************************************************************************ //
  HareketlerBakiyeHesapHareketlerDetay = class(TRemotable)
  private
    FTarih: string;
    FTarih_Specified: boolean;
    FIslemSaati: string;
    FIslemSaati_Specified: boolean;
    FIslemSube: string;
    FIslemSube_Specified: boolean;
    FFisNo: string;
    FFisNo_Specified: boolean;
    FValor: string;
    FValor_Specified: boolean;
    FTutar: string;
    FTutar_Specified: boolean;
    FBakiye: string;
    FBakiye_Specified: boolean;
    FAciklama1: string;
    FAciklama1_Specified: boolean;
    FAciklama2: string;
    FAciklama2_Specified: boolean;
    FProgramKod: string;
    FProgramKod_Specified: boolean;
    FRefNo: string;
    FRefNo_Specified: boolean;
    procedure SetTarih(Index: Integer; const Astring: string);
    function  Tarih_Specified(Index: Integer): boolean;
    procedure SetIslemSaati(Index: Integer; const Astring: string);
    function  IslemSaati_Specified(Index: Integer): boolean;
    procedure SetIslemSube(Index: Integer; const Astring: string);
    function  IslemSube_Specified(Index: Integer): boolean;
    procedure SetFisNo(Index: Integer; const Astring: string);
    function  FisNo_Specified(Index: Integer): boolean;
    procedure SetValor(Index: Integer; const Astring: string);
    function  Valor_Specified(Index: Integer): boolean;
    procedure SetTutar(Index: Integer; const Astring: string);
    function  Tutar_Specified(Index: Integer): boolean;
    procedure SetBakiye(Index: Integer; const Astring: string);
    function  Bakiye_Specified(Index: Integer): boolean;
    procedure SetAciklama1(Index: Integer; const Astring: string);
    function  Aciklama1_Specified(Index: Integer): boolean;
    procedure SetAciklama2(Index: Integer; const Astring: string);
    function  Aciklama2_Specified(Index: Integer): boolean;
    procedure SetProgramKod(Index: Integer; const Astring: string);
    function  ProgramKod_Specified(Index: Integer): boolean;
    procedure SetRefNo(Index: Integer; const Astring: string);
    function  RefNo_Specified(Index: Integer): boolean;
  published
    property Tarih:      string  Index (IS_OPTN) read FTarih write SetTarih stored Tarih_Specified;
    property IslemSaati: string  Index (IS_OPTN) read FIslemSaati write SetIslemSaati stored IslemSaati_Specified;
    property IslemSube:  string  Index (IS_OPTN) read FIslemSube write SetIslemSube stored IslemSube_Specified;
    property FisNo:      string  Index (IS_OPTN) read FFisNo write SetFisNo stored FisNo_Specified;
    property Valor:      string  Index (IS_OPTN) read FValor write SetValor stored Valor_Specified;
    property Tutar:      string  Index (IS_OPTN) read FTutar write SetTutar stored Tutar_Specified;
    property Bakiye:     string  Index (IS_OPTN) read FBakiye write SetBakiye stored Bakiye_Specified;
    property Aciklama1:  string  Index (IS_OPTN) read FAciklama1 write SetAciklama1 stored Aciklama1_Specified;
    property Aciklama2:  string  Index (IS_OPTN) read FAciklama2 write SetAciklama2 stored Aciklama2_Specified;
    property ProgramKod: string  Index (IS_OPTN) read FProgramKod write SetProgramKod stored ProgramKod_Specified;
    property RefNo:      string  Index (IS_OPTN) read FRefNo write SetRefNo stored RefNo_Specified;
  end;

  Array_Of_HareketlerBakiyeHesap = array of HareketlerBakiyeHesap;   { "http://cm-online.ingbank.com.tr/"[GblUbnd] }


  // ************************************************************************ //
  // XML       : HareketlerBakiye, global, <complexType>
  // Namespace : http://cm-online.ingbank.com.tr/
  // ************************************************************************ //
  HareketlerBakiye = class(TRemotable)
  private
    FhataKodu: string;
    FhataKodu_Specified: boolean;
    FhataAciklama: string;
    FhataAciklama_Specified: boolean;
    FHesap: Array_Of_HareketlerBakiyeHesap;
    FHesap_Specified: boolean;
    procedure SethataKodu(Index: Integer; const Astring: string);
    function  hataKodu_Specified(Index: Integer): boolean;
    procedure SethataAciklama(Index: Integer; const Astring: string);
    function  hataAciklama_Specified(Index: Integer): boolean;
    procedure SetHesap(Index: Integer; const AArray_Of_HareketlerBakiyeHesap: Array_Of_HareketlerBakiyeHesap);
    function  Hesap_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property hataKodu:     string                          Index (IS_OPTN) read FhataKodu write SethataKodu stored hataKodu_Specified;
    property hataAciklama: string                          Index (IS_OPTN) read FhataAciklama write SethataAciklama stored hataAciklama_Specified;
    property Hesap:        Array_Of_HareketlerBakiyeHesap  Index (IS_OPTN or IS_UNBD) read FHesap write SetHesap stored Hesap_Specified;
  end;



  // ************************************************************************ //
  // XML       : Hareketler, global, <element>
  // Namespace : http://cm-online.ingbank.com.tr/
  // ************************************************************************ //
  Hareketler = class(HareketlerBakiye)
  private
  published
  end;

  Array_Of_HareketlerBakiyeHesapHareketlerDetay = array of HareketlerBakiyeHesapHareketlerDetay;   { "http://cm-online.ingbank.com.tr/"[GblUbnd] }


  // ************************************************************************ //
  // XML       : HareketlerBakiyeHesap, global, <complexType>
  // Namespace : http://cm-online.ingbank.com.tr/
  // ************************************************************************ //
  HareketlerBakiyeHesap = class(TRemotable)
  private
    FHesapNo: string;
    FHesapNo_Specified: boolean;
    FHesapAdi: string;
    FHesapAdi_Specified: boolean;
    FParaKod: string;
    FParaKod_Specified: boolean;
    FMusteriNo: string;
    FMusteriNo_Specified: boolean;
    FSubeKodu: string;
    FSubeKodu_Specified: boolean;
    FSubeAdi: string;
    FSubeAdi_Specified: boolean;
    FHesapAcilisTarihi: string;
    FHesapAcilisTarihi_Specified: boolean;
    FSonHareketTarihi: string;
    FSonHareketTarihi_Specified: boolean;
    FBakiye: string;
    FBakiye_Specified: boolean;
    FHareket: Array_Of_HareketlerBakiyeHesapHareketlerDetay;
    FHareket_Specified: boolean;
    procedure SetHesapNo(Index: Integer; const Astring: string);
    function  HesapNo_Specified(Index: Integer): boolean;
    procedure SetHesapAdi(Index: Integer; const Astring: string);
    function  HesapAdi_Specified(Index: Integer): boolean;
    procedure SetParaKod(Index: Integer; const Astring: string);
    function  ParaKod_Specified(Index: Integer): boolean;
    procedure SetMusteriNo(Index: Integer; const Astring: string);
    function  MusteriNo_Specified(Index: Integer): boolean;
    procedure SetSubeKodu(Index: Integer; const Astring: string);
    function  SubeKodu_Specified(Index: Integer): boolean;
    procedure SetSubeAdi(Index: Integer; const Astring: string);
    function  SubeAdi_Specified(Index: Integer): boolean;
    procedure SetHesapAcilisTarihi(Index: Integer; const Astring: string);
    function  HesapAcilisTarihi_Specified(Index: Integer): boolean;
    procedure SetSonHareketTarihi(Index: Integer; const Astring: string);
    function  SonHareketTarihi_Specified(Index: Integer): boolean;
    procedure SetBakiye(Index: Integer; const Astring: string);
    function  Bakiye_Specified(Index: Integer): boolean;
    procedure SetHareket(Index: Integer; const AArray_Of_HareketlerBakiyeHesapHareketlerDetay: Array_Of_HareketlerBakiyeHesapHareketlerDetay);
    function  Hareket_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property HesapNo:           string                                         Index (IS_OPTN) read FHesapNo write SetHesapNo stored HesapNo_Specified;
    property HesapAdi:          string                                         Index (IS_OPTN) read FHesapAdi write SetHesapAdi stored HesapAdi_Specified;
    property ParaKod:           string                                         Index (IS_OPTN) read FParaKod write SetParaKod stored ParaKod_Specified;
    property MusteriNo:         string                                         Index (IS_OPTN) read FMusteriNo write SetMusteriNo stored MusteriNo_Specified;
    property SubeKodu:          string                                         Index (IS_OPTN) read FSubeKodu write SetSubeKodu stored SubeKodu_Specified;
    property SubeAdi:           string                                         Index (IS_OPTN) read FSubeAdi write SetSubeAdi stored SubeAdi_Specified;
    property HesapAcilisTarihi: string                                         Index (IS_OPTN) read FHesapAcilisTarihi write SetHesapAcilisTarihi stored HesapAcilisTarihi_Specified;
    property SonHareketTarihi:  string                                         Index (IS_OPTN) read FSonHareketTarihi write SetSonHareketTarihi stored SonHareketTarihi_Specified;
    property Bakiye:            string                                         Index (IS_OPTN) read FBakiye write SetBakiye stored Bakiye_Specified;
    property Hareket:           Array_Of_HareketlerBakiyeHesapHareketlerDetay  Index (IS_OPTN or IS_UNBD) read FHareket write SetHareket stored Hareket_Specified;
  end;


  // ************************************************************************ //
  // Namespace : http://cm-online.ingbank.com.tr/
  // soapAction: http://cm-online.ingbank.com.tr/Sorgula
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : EkstreSoap12
  // service   : Ekstre
  // port      : EkstreSoap12
  // URL       : https://cm-online.ingbank.com.tr/ekstre.asmx
  // ************************************************************************ //
  EkstreSoap = interface(IInvokable)
  ['{835AD8AB-30F3-8DA1-C0E9-22D6BE9B0679}']
    function  Sorgula(const KullaniciKod: string; const Sifre: string; const HesapNo: string; const BaslangicTarihi: string; const BitisTarihi: string; const Refno: string
                      ): HareketlerBakiye; stdcall;
  end;


  // ************************************************************************ //
  // Namespace : http://cm-online.ingbank.com.tr/
  // binding   : EkstreHttpGet
  // service   : Ekstre
  // port      : EkstreHttpGet
  // ************************************************************************ //
  EkstreHttpGet = interface(IInvokable)
  ['{B35EC5AB-1861-F549-1CDE-862A564C6157}']
    function  Sorgula(const KullaniciKod: string; const Sifre: string; const HesapNo: string; const BaslangicTarihi: string; const BitisTarihi: string; const Refno: string
                      ): Hareketler; stdcall;
  end;


  // ************************************************************************ //
  // Namespace : http://cm-online.ingbank.com.tr/
  // binding   : EkstreHttpPost
  // service   : Ekstre
  // port      : EkstreHttpPost
  // ************************************************************************ //
  EkstreHttpPost = interface(IInvokable)
  ['{0D107075-FDD4-EBDA-C2E0-7C4AABC7F9CA}']
    function  Sorgula(const KullaniciKod: string; const Sifre: string; const HesapNo: string; const BaslangicTarihi: string; const BitisTarihi: string; const Refno: string
                      ): Hareketler; stdcall;
  end;

function GetEkstreSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): EkstreSoap;
function GetEkstreHttpGet(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): EkstreHttpGet;
function GetEkstreHttpPost(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): EkstreHttpPost;


implementation
  uses SysUtils;

function GetEkstreSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): EkstreSoap;
const
  defWSDL = 'https://cm-online.ingbank.com.tr/ekstre.asmx?WSDL';
  defURL  = 'https://cm-online.ingbank.com.tr/ekstre.asmx';
  defSvc  = 'Ekstre';
  defPrt  = 'EkstreSoap12';
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
    Result := (RIO as EkstreSoap);
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


function GetEkstreHttpGet(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): EkstreHttpGet;
const
  defWSDL = 'https://cm-online.ingbank.com.tr/ekstre.asmx?WSDL';
  defURL  = '';
  defSvc  = 'Ekstre';
  defPrt  = 'EkstreHttpGet';
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
    Result := (RIO as EkstreHttpGet);
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


function GetEkstreHttpPost(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): EkstreHttpPost;
const
  defWSDL = 'https://cm-online.ingbank.com.tr/ekstre.asmx?WSDL';
  defURL  = '';
  defSvc  = 'Ekstre';
  defPrt  = 'EkstreHttpPost';
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
    Result := (RIO as EkstreHttpPost);
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


procedure HareketlerBakiyeHesapHareketlerDetay.SetTarih(Index: Integer; const Astring: string);
begin
  FTarih := Astring;
  FTarih_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.Tarih_Specified(Index: Integer): boolean;
begin
  Result := FTarih_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetIslemSaati(Index: Integer; const Astring: string);
begin
  FIslemSaati := Astring;
  FIslemSaati_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.IslemSaati_Specified(Index: Integer): boolean;
begin
  Result := FIslemSaati_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetIslemSube(Index: Integer; const Astring: string);
begin
  FIslemSube := Astring;
  FIslemSube_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.IslemSube_Specified(Index: Integer): boolean;
begin
  Result := FIslemSube_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetFisNo(Index: Integer; const Astring: string);
begin
  FFisNo := Astring;
  FFisNo_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.FisNo_Specified(Index: Integer): boolean;
begin
  Result := FFisNo_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetValor(Index: Integer; const Astring: string);
begin
  FValor := Astring;
  FValor_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.Valor_Specified(Index: Integer): boolean;
begin
  Result := FValor_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetTutar(Index: Integer; const Astring: string);
begin
  FTutar := Astring;
  FTutar_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.Tutar_Specified(Index: Integer): boolean;
begin
  Result := FTutar_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetBakiye(Index: Integer; const Astring: string);
begin
  FBakiye := Astring;
  FBakiye_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.Bakiye_Specified(Index: Integer): boolean;
begin
  Result := FBakiye_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetAciklama1(Index: Integer; const Astring: string);
begin
  FAciklama1 := Astring;
  FAciklama1_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.Aciklama1_Specified(Index: Integer): boolean;
begin
  Result := FAciklama1_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetAciklama2(Index: Integer; const Astring: string);
begin
  FAciklama2 := Astring;
  FAciklama2_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.Aciklama2_Specified(Index: Integer): boolean;
begin
  Result := FAciklama2_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetProgramKod(Index: Integer; const Astring: string);
begin
  FProgramKod := Astring;
  FProgramKod_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.ProgramKod_Specified(Index: Integer): boolean;
begin
  Result := FProgramKod_Specified;
end;

procedure HareketlerBakiyeHesapHareketlerDetay.SetRefNo(Index: Integer; const Astring: string);
begin
  FRefNo := Astring;
  FRefNo_Specified := True;
end;

function HareketlerBakiyeHesapHareketlerDetay.RefNo_Specified(Index: Integer): boolean;
begin
  Result := FRefNo_Specified;
end;

destructor HareketlerBakiye.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FHesap)-1 do
    SysUtils.FreeAndNil(FHesap[I]);
  System.SetLength(FHesap, 0);
  inherited Destroy;
end;

procedure HareketlerBakiye.SethataKodu(Index: Integer; const Astring: string);
begin
  FhataKodu := Astring;
  FhataKodu_Specified := True;
end;

function HareketlerBakiye.hataKodu_Specified(Index: Integer): boolean;
begin
  Result := FhataKodu_Specified;
end;

procedure HareketlerBakiye.SethataAciklama(Index: Integer; const Astring: string);
begin
  FhataAciklama := Astring;
  FhataAciklama_Specified := True;
end;

function HareketlerBakiye.hataAciklama_Specified(Index: Integer): boolean;
begin
  Result := FhataAciklama_Specified;
end;

procedure HareketlerBakiye.SetHesap(Index: Integer; const AArray_Of_HareketlerBakiyeHesap: Array_Of_HareketlerBakiyeHesap);
begin
  FHesap := AArray_Of_HareketlerBakiyeHesap;
  FHesap_Specified := True;
end;

function HareketlerBakiye.Hesap_Specified(Index: Integer): boolean;
begin
  Result := FHesap_Specified;
end;

destructor HareketlerBakiyeHesap.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FHareket)-1 do
    SysUtils.FreeAndNil(FHareket[I]);
  System.SetLength(FHareket, 0);
  inherited Destroy;
end;

procedure HareketlerBakiyeHesap.SetHesapNo(Index: Integer; const Astring: string);
begin
  FHesapNo := Astring;
  FHesapNo_Specified := True;
end;

function HareketlerBakiyeHesap.HesapNo_Specified(Index: Integer): boolean;
begin
  Result := FHesapNo_Specified;
end;

procedure HareketlerBakiyeHesap.SetHesapAdi(Index: Integer; const Astring: string);
begin
  FHesapAdi := Astring;
  FHesapAdi_Specified := True;
end;

function HareketlerBakiyeHesap.HesapAdi_Specified(Index: Integer): boolean;
begin
  Result := FHesapAdi_Specified;
end;

procedure HareketlerBakiyeHesap.SetParaKod(Index: Integer; const Astring: string);
begin
  FParaKod := Astring;
  FParaKod_Specified := True;
end;

function HareketlerBakiyeHesap.ParaKod_Specified(Index: Integer): boolean;
begin
  Result := FParaKod_Specified;
end;

procedure HareketlerBakiyeHesap.SetMusteriNo(Index: Integer; const Astring: string);
begin
  FMusteriNo := Astring;
  FMusteriNo_Specified := True;
end;

function HareketlerBakiyeHesap.MusteriNo_Specified(Index: Integer): boolean;
begin
  Result := FMusteriNo_Specified;
end;

procedure HareketlerBakiyeHesap.SetSubeKodu(Index: Integer; const Astring: string);
begin
  FSubeKodu := Astring;
  FSubeKodu_Specified := True;
end;

function HareketlerBakiyeHesap.SubeKodu_Specified(Index: Integer): boolean;
begin
  Result := FSubeKodu_Specified;
end;

procedure HareketlerBakiyeHesap.SetSubeAdi(Index: Integer; const Astring: string);
begin
  FSubeAdi := Astring;
  FSubeAdi_Specified := True;
end;

function HareketlerBakiyeHesap.SubeAdi_Specified(Index: Integer): boolean;
begin
  Result := FSubeAdi_Specified;
end;

procedure HareketlerBakiyeHesap.SetHesapAcilisTarihi(Index: Integer; const Astring: string);
begin
  FHesapAcilisTarihi := Astring;
  FHesapAcilisTarihi_Specified := True;
end;

function HareketlerBakiyeHesap.HesapAcilisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FHesapAcilisTarihi_Specified;
end;

procedure HareketlerBakiyeHesap.SetSonHareketTarihi(Index: Integer; const Astring: string);
begin
  FSonHareketTarihi := Astring;
  FSonHareketTarihi_Specified := True;
end;

function HareketlerBakiyeHesap.SonHareketTarihi_Specified(Index: Integer): boolean;
begin
  Result := FSonHareketTarihi_Specified;
end;

procedure HareketlerBakiyeHesap.SetBakiye(Index: Integer; const Astring: string);
begin
  FBakiye := Astring;
  FBakiye_Specified := True;
end;

function HareketlerBakiyeHesap.Bakiye_Specified(Index: Integer): boolean;
begin
  Result := FBakiye_Specified;
end;

procedure HareketlerBakiyeHesap.SetHareket(Index: Integer; const AArray_Of_HareketlerBakiyeHesapHareketlerDetay: Array_Of_HareketlerBakiyeHesapHareketlerDetay);
begin
  FHareket := AArray_Of_HareketlerBakiyeHesapHareketlerDetay;
  FHareket_Specified := True;
end;

function HareketlerBakiyeHesap.Hareket_Specified(Index: Integer): boolean;
begin
  Result := FHareket_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(EkstreSoap), 'http://cm-online.ingbank.com.tr/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(EkstreSoap), 'http://cm-online.ingbank.com.tr/Sorgula');
  InvRegistry.RegisterInvokeOptions(TypeInfo(EkstreSoap), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(EkstreSoap), ioSOAP12);
  InvRegistry.RegisterInterface(TypeInfo(EkstreHttpGet), 'http://cm-online.ingbank.com.tr/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(EkstreHttpGet), '');
  InvRegistry.RegisterInterface(TypeInfo(EkstreHttpPost), 'http://cm-online.ingbank.com.tr/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(EkstreHttpPost), '');
  RemClassRegistry.RegisterXSClass(HareketlerBakiyeHesapHareketlerDetay, 'http://cm-online.ingbank.com.tr/', 'HareketlerBakiyeHesapHareketlerDetay');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_HareketlerBakiyeHesap), 'http://cm-online.ingbank.com.tr/', 'Array_Of_HareketlerBakiyeHesap');
  RemClassRegistry.RegisterXSClass(HareketlerBakiye, 'http://cm-online.ingbank.com.tr/', 'HareketlerBakiye');
  RemClassRegistry.RegisterXSClass(Hareketler, 'http://cm-online.ingbank.com.tr/', 'Hareketler');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_HareketlerBakiyeHesapHareketlerDetay), 'http://cm-online.ingbank.com.tr/', 'Array_Of_HareketlerBakiyeHesapHareketlerDetay');
  RemClassRegistry.RegisterXSClass(HareketlerBakiyeHesap, 'http://cm-online.ingbank.com.tr/', 'HareketlerBakiyeHesap');

end.

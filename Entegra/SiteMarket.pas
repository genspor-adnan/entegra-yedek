// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://genlisans.genyazilim.com:8090/Market/SiteMarket.asmx?wsdl
//  >Import : http://genlisans.genyazilim.com:8090/Market/SiteMarket.asmx?wsdl>0
// Encoding : utf-8
// Version  : 1.0
// (14/05/2014 16:53:07 - - $Rev: 52705 $)
// ************************************************************************ //

unit SiteMarket;

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
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]

  Modul                = class;                 { "Gentegre"[GblCplx] }
  Moduller2            = class;                 { "Gentegre"[GblCplx] }
  Moduller             = class;                 { "Gentegre"[GblElm] }

  ArrayOfModul = array of Modul;                { "Gentegre"[GblCplx] }


  // ************************************************************************ //
  // XML       : Modul, global, <complexType>
  // Namespace : Gentegre
  // ************************************************************************ //
  Modul = class(TRemotable)
  private
    FStokId: Integer;
    FStokKodu: string;
    FStokKodu_Specified: boolean;
    FOzelKod: string;
    FOzelKod_Specified: boolean;
    FStokAdi: string;
    FStokAdi_Specified: boolean;
    FModulDurumu: Boolean;
    procedure SetStokKodu(Index: Integer; const Astring: string);
    function  StokKodu_Specified(Index: Integer): boolean;
    procedure SetOzelKod(Index: Integer; const Astring: string);
    function  OzelKod_Specified(Index: Integer): boolean;
    procedure SetStokAdi(Index: Integer; const Astring: string);
    function  StokAdi_Specified(Index: Integer): boolean;
  published
    property StokId:      Integer  read FStokId write FStokId;
    property StokKodu:    string   Index (IS_OPTN) read FStokKodu write SetStokKodu stored StokKodu_Specified;
    property OzelKod:     string   Index (IS_OPTN) read FOzelKod write SetOzelKod stored OzelKod_Specified;
    property StokAdi:     string   Index (IS_OPTN) read FStokAdi write SetStokAdi stored StokAdi_Specified;
    property ModulDurumu: Boolean  read FModulDurumu write FModulDurumu;
  end;



  // ************************************************************************ //
  // XML       : Moduller, global, <complexType>
  // Namespace : Gentegre
  // ************************************************************************ //
  Moduller2 = class(TRemotable)
  private
    FLisansSayisi: Integer;
    FGuncelleme: Boolean;
    FLisansKontrolGun: Integer;
    FServerId: string;
    FServerId_Specified: boolean;
    FHata: string;
    FHata_Specified: boolean;
    FSkt: TXSDateTime;
    FTarih: TXSDateTime;
    FModulListesi: ArrayOfModul;
    FModulListesi_Specified: boolean;
    procedure SetServerId(Index: Integer; const Astring: string);
    function  ServerId_Specified(Index: Integer): boolean;
    procedure SetHata(Index: Integer; const Astring: string);
    function  Hata_Specified(Index: Integer): boolean;
    procedure SetModulListesi(Index: Integer; const AArrayOfModul: ArrayOfModul);
    function  ModulListesi_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property LisansSayisi:     Integer       read FLisansSayisi write FLisansSayisi;
    property Guncelleme:       Boolean       read FGuncelleme write FGuncelleme;
    property LisansKontrolGun: Integer       read FLisansKontrolGun write FLisansKontrolGun;
    property ServerId:         string        Index (IS_OPTN) read FServerId write SetServerId stored ServerId_Specified;
    property Hata:             string        Index (IS_OPTN) read FHata write SetHata stored Hata_Specified;
    property Skt:              TXSDateTime   read FSkt write FSkt;
    property Tarih:            TXSDateTime   read FTarih write FTarih;
    property ModulListesi:     ArrayOfModul  Index (IS_OPTN) read FModulListesi write SetModulListesi stored ModulListesi_Specified;
  end;



  // ************************************************************************ //
  // XML       : Moduller, global, <element>
  // Namespace : Gentegre
  // ************************************************************************ //
  Moduller = class(Moduller2)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : Gentegre
  // soapAction: Gentegre/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : SiteMarketSoap
  // service   : SiteMarket
  // port      : SiteMarketSoap
  // URL       : http://genlisans.genyazilim.com/Market/SiteMarket.asmx
  // ************************************************************************ //
  SiteMarketSoap = interface(IInvokable)
  ['{C3D0A8FB-A332-3DD7-6B6F-F7DBACF064D3}']
    procedure CityList; stdcall;
    procedure UserControl(const username: string; const password: string); stdcall;
    procedure SiparisEkleme(const tarih: string; const tur: Integer; const tipi: Integer; const rehberid: Integer; const siparistarihi: string; const baslik: string;
                            const adres: string; const il: string; const vd: string; const kdvdurum: string; const siparismatrahi: string;
                            const kdvtutari: string; const siparistutari: string; const kur: string; const dovizcinsi: string; const DURUM: Integer;
                            const eklemetarihi: string); stdcall;
    procedure SiparisDetayEkleme(const siparisid: string; const rehberid: string; const tur: string; const urunid: string; const adet: string; const birim: string;
                                 const miktar: string; const birimfiyat: string; const tutar: string; const kur: string; const kdv: string;
                                 const dovizKuru: string; const eklemetarihi: string); stdcall;
    procedure CompanyAdd(const firmaAdi: string; const sifre: string; const vergiDairesi: string; const vergiNo: string; const postaKodu: string; const adres: string;
                         const yetkiliAdi: string; const telNo: string; const fax: string; const il: string; const ilce: string;
                         const eposta: string; const webAdresi: string; const bayi: string); stdcall;
    procedure StockSelect(const rehberid: string); stdcall;
    function  StockSelect1(const musteriKodu: string; const sid: string): Moduller2; stdcall;
    procedure StokInformationSelect(const urunId: Integer); stdcall;
  end;


  // ************************************************************************ //
  // Namespace : Gentegre
  // style     : ????
  // use       : ????
  // binding   : SiteMarketHttpGet
  // service   : SiteMarket
  // port      : SiteMarketHttpGet
  // ************************************************************************ //
  SiteMarketHttpGet = interface(IInvokable)
  ['{CE708235-DA35-F353-13D2-2A4219D9CFBD}']
    procedure CityList; stdcall;
    procedure UserControl(const username: string; const password: string); stdcall;
    procedure SiparisEkleme(const tarih: string; const tur: string; const tipi: string; const rehberid: string; const siparistarihi: string; const baslik: string;
                            const adres: string; const il: string; const vd: string; const kdvdurum: string; const siparismatrahi: string;
                            const kdvtutari: string; const siparistutari: string; const kur: string; const dovizcinsi: string; const DURUM: string;
                            const eklemetarihi: string); stdcall;
    procedure SiparisDetayEkleme(const siparisid: string; const rehberid: string; const tur: string; const urunid: string; const adet: string; const birim: string;
                                 const miktar: string; const birimfiyat: string; const tutar: string; const kur: string; const kdv: string;
                                 const dovizKuru: string; const eklemetarihi: string); stdcall;
    procedure CompanyAdd(const firmaAdi: string; const sifre: string; const vergiDairesi: string; const vergiNo: string; const postaKodu: string; const adres: string;
                         const yetkiliAdi: string; const telNo: string; const fax: string; const il: string; const ilce: string;
                         const eposta: string; const webAdresi: string; const bayi: string); stdcall;
    procedure StockSelect(const rehberid: string); stdcall;
    function  StockSelect1(const musteriKodu: string; const sid: string): Moduller; stdcall;
    procedure StokInformationSelect(const urunId: string); stdcall;
  end;


  // ************************************************************************ //
  // Namespace : Gentegre
  // style     : ????
  // use       : ????
  // binding   : SiteMarketHttpPost
  // service   : SiteMarket
  // port      : SiteMarketHttpPost
  // ************************************************************************ //
  SiteMarketHttpPost = interface(IInvokable)
  ['{FC97A882-2F39-48D8-24E3-A55AFBCC3386}']
    procedure CityList; stdcall;
    procedure UserControl(const username: string; const password: string); stdcall;
    procedure SiparisEkleme(const tarih: string; const tur: string; const tipi: string; const rehberid: string; const siparistarihi: string; const baslik: string;
                            const adres: string; const il: string; const vd: string; const kdvdurum: string; const siparismatrahi: string;
                            const kdvtutari: string; const siparistutari: string; const kur: string; const dovizcinsi: string; const DURUM: string;
                            const eklemetarihi: string); stdcall;
    procedure SiparisDetayEkleme(const siparisid: string; const rehberid: string; const tur: string; const urunid: string; const adet: string; const birim: string;
                                 const miktar: string; const birimfiyat: string; const tutar: string; const kur: string; const kdv: string;
                                 const dovizKuru: string; const eklemetarihi: string); stdcall;
    procedure CompanyAdd(const firmaAdi: string; const sifre: string; const vergiDairesi: string; const vergiNo: string; const postaKodu: string; const adres: string;
                         const yetkiliAdi: string; const telNo: string; const fax: string; const il: string; const ilce: string;
                         const eposta: string; const webAdresi: string; const bayi: string); stdcall;
    procedure StockSelect(const rehberid: string); stdcall;
    function  StockSelect1(const musteriKodu: string; const sid: string): Moduller; stdcall;
    procedure StokInformationSelect(const urunId: string); stdcall;
  end;

function GetSiteMarketSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SiteMarketSoap;
function GetSiteMarketHttpGet(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SiteMarketHttpGet;
function GetSiteMarketHttpPost(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SiteMarketHttpPost;


implementation
  uses SysUtils;

function GetSiteMarketSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SiteMarketSoap;
const
  defWSDL = 'http://genlisans.genyazilim.com:8090/Market/SiteMarket.asmx?wsdl';
  defURL  = 'http://genlisans.genyazilim.com/Market/SiteMarket.asmx';
  defSvc  = 'SiteMarket';
  defPrt  = 'SiteMarketSoap';
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
    Result := (RIO as SiteMarketSoap);
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


function GetSiteMarketHttpGet(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SiteMarketHttpGet;
const
  defWSDL = 'http://genlisans.genyazilim.com:8090/Market/SiteMarket.asmx?wsdl';
  defURL  = '';
  defSvc  = 'SiteMarket';
  defPrt  = 'SiteMarketHttpGet';
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
    Result := (RIO as SiteMarketHttpGet);
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


function GetSiteMarketHttpPost(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SiteMarketHttpPost;
const
  defWSDL = 'http://genlisans.genyazilim.com:8090/Market/SiteMarket.asmx?wsdl';
  defURL  = '';
  defSvc  = 'SiteMarket';
  defPrt  = 'SiteMarketHttpPost';
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
    Result := (RIO as SiteMarketHttpPost);
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


procedure Modul.SetStokKodu(Index: Integer; const Astring: string);
begin
  FStokKodu := Astring;
  FStokKodu_Specified := True;
end;

function Modul.StokKodu_Specified(Index: Integer): boolean;
begin
  Result := FStokKodu_Specified;
end;

procedure Modul.SetOzelKod(Index: Integer; const Astring: string);
begin
  FOzelKod := Astring;
  FOzelKod_Specified := True;
end;

function Modul.OzelKod_Specified(Index: Integer): boolean;
begin
  Result := FOzelKod_Specified;
end;

procedure Modul.SetStokAdi(Index: Integer; const Astring: string);
begin
  FStokAdi := Astring;
  FStokAdi_Specified := True;
end;

function Modul.StokAdi_Specified(Index: Integer): boolean;
begin
  Result := FStokAdi_Specified;
end;

destructor Moduller2.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FModulListesi)-1 do
    SysUtils.FreeAndNil(FModulListesi[I]);
  System.SetLength(FModulListesi, 0);
  SysUtils.FreeAndNil(FSkt);
  SysUtils.FreeAndNil(FTarih);
  inherited Destroy;
end;

procedure Moduller2.SetServerId(Index: Integer; const Astring: string);
begin
  FServerId := Astring;
  FServerId_Specified := True;
end;

function Moduller2.ServerId_Specified(Index: Integer): boolean;
begin
  Result := FServerId_Specified;
end;

procedure Moduller2.SetHata(Index: Integer; const Astring: string);
begin
  FHata := Astring;
  FHata_Specified := True;
end;

function Moduller2.Hata_Specified(Index: Integer): boolean;
begin
  Result := FHata_Specified;
end;

procedure Moduller2.SetModulListesi(Index: Integer; const AArrayOfModul: ArrayOfModul);
begin
  FModulListesi := AArrayOfModul;
  FModulListesi_Specified := True;
end;

function Moduller2.ModulListesi_Specified(Index: Integer): boolean;
begin
  Result := FModulListesi_Specified;
end;

initialization
  { SiteMarketSoap }
  InvRegistry.RegisterInterface(TypeInfo(SiteMarketSoap), 'Gentegre', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SiteMarketSoap), 'Gentegre/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(SiteMarketSoap), ioDocument);
  { SiteMarketSoap.StockSelect1 }
  InvRegistry.RegisterMethodInfo(TypeInfo(SiteMarketSoap), 'StockSelect1', '',
                                 '[ReturnName="StockSelect1Result"]', IS_OPTN);
  { SiteMarketHttpGet }
  InvRegistry.RegisterInterface(TypeInfo(SiteMarketHttpGet), 'Gentegre', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SiteMarketHttpGet), '');
  { SiteMarketHttpPost }
  InvRegistry.RegisterInterface(TypeInfo(SiteMarketHttpPost), 'Gentegre', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SiteMarketHttpPost), '');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfModul), 'Gentegre', 'ArrayOfModul');
  RemClassRegistry.RegisterXSClass(Modul, 'Gentegre', 'Modul');
  RemClassRegistry.RegisterXSClass(Moduller2, 'Gentegre', 'Moduller2', 'Moduller');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Moduller2), 'ModulListesi', '[ArrayItemName="Modul"]');
  RemClassRegistry.RegisterXSClass(Moduller, 'Gentegre', 'Moduller');

end.

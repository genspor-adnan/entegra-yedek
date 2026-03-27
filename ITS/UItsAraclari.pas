// ************************************************************************ //
// İş       : İts Araçları
// Başlangıc Tarihi :İsmail ACET 07-10-2011
// Değiştime  : 26-11-2011 Üretici için üretim bildirimi ve diğer servisleri yapıldı
// Üretimresponse için yeni class oluşturuldu .
// Encoding : UTF-8
// Codegen  : SOAP
// Version  : 1.1
// Değiştirme :13-01-2011  Paket Alma Servisi Eklendi
// Version  : 1.2
// Değiştirme : 24-01-2011 PaketDatay Alma Servisi /başlandı
// Versiyon   : 1.2
// Değiştirme : 12.12.2012 Web Serviswleirnde Değişikliğe gidindi.(1.2 ver)
// ************************************************************************ //


unit UItsAraclari;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ECXMLParser, Generics.Collections,KAZip,EncdDecd,StrUtils,UTablo;



type
  TUrun = class
  private
    FBN: string;
    FGTIN: string;
    FSN: string;
    FXD: TDateTime;
  published
  public
    class function Yeni(AGTIN,ABN,ASN: string;AXD : TDAteTime): TUrun;
    property GTIN : string read FGTIN write FGTIN;
    property BN : string read FBN write FBN;
    property SN : string read FSN write FSN;
    property XD : TDateTime read FXD write FXD;
  end;

  TTransferDetay = class
    private
    FHedefGLN: string;
    FTransferTarih: TDateTime;
    FTransferID: integer;
    FKaynakGLN: string;
    published
    public
      property HedefGLN : string read FHedefGLN  write FHedefGLN;
      property KaynakGLN: string read FKaynakGLN write FKaynakGLN;
      property TransferID : integer read  FTransferID write FTransferID;
      property TransferTarih : TDateTime read  FTransferTarih write FTransferTarih;

  end;



  TUrunDurum = class
  private
    FUC: string;
    FGTIN: string;
    FSN: string;
  published
  public
    constructor Create(ANode: TXMLItem);virtual;
    property GTIN : string read FGTIN;
    property SN : string read FSN;
    property UC : string read FUC;
  end;



    TUrunDurumUretim = class
  private
    FUC: string;
    FSN: string;
  published
  public
    constructor Create(ANode: TXMLItem);virtual;
    property SN : string read FSN;
    property UC : string read FUC;
  end;


  TPTSUrun = class;
  TPTSXml = class;

  TTasiyici  = class
    private
    FIcTasiyicilar: TList<TTasiyici>;
    FTip: string;
    FEtiket: string;
    FUrunListesi: TList<TPTSUrun>;
    FPtsXml: TPTSXml;
    protected
    published
    public
    constructor Create ; virtual;
    destructor Destroy ; virtual;
    procedure XmlOlustur(AKok: TXMLItem);
    class function XmldenGetir(APtsXml: TPtsXml;AKok: TXmlItem): TTasiyici;
    procedure VeriTabaniKaydet(PaketID : Integer;TasiyiciID:Integer);
    property Etiket : string read FEtiket write FEtiket;
    property Tip : string read FTip  write FTip;
    property UrunListesi   : TList<TPTSUrun> read FUrunListesi;
    property IcTasiyicilar :TList<TTasiyici> read FIcTasiyicilar;
    property PtsXml : TPTSXml read FPtsXml write FPtsXml;
  end;

  TPTSUrun = class
    private
    FGTIN: string;
    FSiraNo: TStringList;
    FUretimTarihi: string;
    FPoSayisi: string;
    FLotNumarasi: string;
    FSonKullanimTarihi: string;
    protected
    published
    public
    constructor Create ; virtual;
    destructor Destroy ; virtual;
    procedure XmlOlustur(AKok: TXMLItem);
    class function XmldenGetir(AKok: TXMLItem): TPTSUrun;
    property GTIN : string read FGTIN write FGTIN;
    property LotNumarasi :string read FLotNumarasi write FLotNumarasi;
    property UretimTarihi : string read FUretimTarihi write FUretimTarihi;
    property SonKullanimTarihi : string read FSonKullanimTarihi write FSonKullanimTarihi;
    property PoSayisi : string read FPoSayisi write FPoSayisi ;
    property SiraNo : TStringList read FSiraNo write FSiraNo;

  end;

  TSSCC = class
  public
    class function Olustur(ATasimaTipi,AFirmaNumarasi,ABenzersizNumara: string) : string;
    constructor Create;
  end;


  TPTSXml = class
  private
    FBelgeNumarasi: string;
    FTransferTipi: string;
    FHedefGLN: string;
    FTransferNot: String;
    FVersiyon: string;
    FBelgeTarihi: TDate;
    FSevkNereye: string;
    FKaynakGLN: string;
    FTasiyici: TList<TTasiyici>;
    FUrunListesi: TList<TPTSUrun>;
  published
  protected
  FXml   : TECXMLParser;
  FGovde : TXMLItem;
  procedure BaslikOlustur;virtual;
  procedure GovdeOlustur;virtual;
  public
  Constructor Create; virtual;
  Destructor Destroy; override;
  procedure ZipKaydet;
  function XmltoString:string;
  class function XmldenGetir(AItem: TXmlItem): TPtsXml;
  procedure VeriTabaniKaydet(TransferID : string);
  property  KaynakGLN : string read FKaynakGLN write FKaynakGLN;
  property  HedefGLN  : string read FHedefGLN write FHedefGLN;
  property  TransferTipi : string read  FTransferTipi write FTransferTipi;
  property  SevkNereye : string read FSevkNereye write FSevkNereye ;
  property  BelgeNumarasi : string read FBelgeNumarasi write FBelgeNumarasi;
  property  BelgeTarihi : TDate read FBelgeTarihi write FBelgeTarihi;
  property  TransferNot : String read FTransferNot write FTransferNot;
  property  Versiyon :string read FVersiyon write FVersiyon ;
  property  Tasiyici : TList<TTasiyici> read FTasiyici write FTasiyici ;
  property  UrunListesi   : TList<TPTSUrun> read FUrunListesi write FUrunListesi;
  end;


  TSoapIstek = class
  private
    function GetIcerik: TStream;
    function GetIcerikString: AnsiString;
  protected
    FXml: TECXMLParser;
    FGovde : TXMLItem;
    procedure Baslat;virtual;
    procedure GovdeHazirla;virtual;
    procedure BaslikHazirla;
    function GetServisUrl : string;virtual;
  public
    constructor Create;virtual;
    destructor Destroy;override;
    property Icerik : TStream read GetIcerik;
    property IcerikString : AnsiString read GetIcerikString;
    property ServisUrl : string read GetServisUrl;
  end;

  TPTSSoapIstek = class
    private
    FBaslikNS: string;
      function GetIcerik: TStream;
       function GetIcerikString: AnsiString;
    protected
      FXml : TECXMLParser;
      FGovde : TXMLItem;
      procedure Baslat;virtual;
      procedure GovdeHazirla;virtual;
      procedure BaslikHazirla;
      function GetServisUrl  : string;virtual;
    public
      constructor Create;virtual;
      destructor Destroy;override;
      property Icerik : TStream read GetIcerik;
      property IcerikString : AnsiString read GetIcerikString;
      property Servis :string read GetServisUrl;
      property BaslikNS : string read FBaslikNS write FBaslikNS;
  end;





  TPTSAlimIstek = class(TPTSSoapIstek)
  private
    FKaynak: string;
    FTRANSFERID: string;
  protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
  published
  public
    constructor Create; override;
    destructor Destroy; override;
    property Kaynak : string read FKaynak write FKaynak;
    property TRANSFERID : string read FTRANSFERID write FTRANSFERID;
  end;



  TPTSGonderimIstek = class (TPTSSoapIstek)
  private
    FHedefGLN: string;
    FKaynekGLN: string;
    FOlusanXml: TPTSXml;
  protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
  published
  public
    constructor Create;override;
    destructor Destroy;override;
    property KaynakGLN      : string read FKaynekGLN write FKaynekGLN;
    property HedefGLN       : string read FHedefGLN write FHedefGLN;
    property OlusanXml      : TPTSXml read FOlusanXml write FOlusanXml;
  end;

  TPTSDetayIstek = class (TPTSSoapIstek)
   private
    FBitisTarih: TDateTime;
    FHedefGLN: string;
    FBaslangicTarih: TDateTime;
    FKaynakGLN: string;
    FTransferBilgisi: string;
   protected
    procedure Baslat      ;override;
    procedure GovdeHazirla;override;
    function  GetServisUrl : string; override;
   published
   public
    constructor Create;override;
    destructor Destroy ;override;
    property KaynakGLN : string read FKaynakGLN write FKaynakGLN;
    property HedefGLN  : string read FHedefGLN  write FHedefGLN;
    property TransferBilgisi : string read FTransferBilgisi write FTransferBilgisi;
    property BaslangicTarih  : TDateTime read FBaslangicTarih write FBaslangicTarih;
    property BitisTarih  : TDateTime read FBitisTarih write FBitisTarih;
  end;

  TUretimBildirIstek = class (TSoapIstek)
  private
    FDT: string;
    FMI: string;
    FBN: string;
    FGTIN: string;
    FMD: TDateTime;
    FPT: string;
    FXD: TDateTime;
    FUrunler: TObjectList<TUrun>;
    FBelgeDN: String;
    FBelgeDD: TDateTime;
    procedure SetDT(const Value: string);
    procedure SetBN(const Value: string);
    procedure SetGTIN(const Value: string);
    procedure SetMD(const Value: TDateTime);
    procedure SetMI(const Value: string);
    procedure SetPT(const Value: string);
    procedure SetXD(const Value: TDateTime);
    procedure SetBelgeDD(const Value: TDateTime);
    procedure SetBelgeDN(const Value: String);
    procedure SetUrunler(const Value: TObjectList<TUrun>);
  protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl:string; override;
  published
  public
  constructor Create; override;
  destructor Destroy; override;
  property DT : string read FDT write SetDT;  //Bildirim Tipi    M : Üretim Bildirim   I : Ithalat Bildirimi
  property MI : string read FMI write SetMI;
 {Üretici/Đthalatçı: Ürünlerin sisteme girisini yapacak firmalardır. Bu alan için belirteç
  olarak <MI> kullanılır. Üretici veya ithalatçılar GLN kodu ile sistemde yer alacaklardır.
  Sisteme ancak ruhsat veya izinleri kendilerine ait olan ilaçlar için veri gönderebileceklerdir.}
  property PT :string read FPT write SetPT;      // Ürün Cinsi PP : İlaç , BP : Ara Ürün , FP : Besleme Ürün
  {Ürün Tipi: Bu alan için belirteç olarak <PT> kullanılır. 2 karakter uzunlukta
  alfanümerik tipte bir alan tutar. Belirteç, ilaç için <PP>, ara ürün için <BP>, beslenme
  ürünleri için <FP> kullanılır.}
  property MD : TDateTime read FMD write SetMD;  // Ürün Üretim Tarihi
  {Üretim Tarihi: Bildirime esas olan üretimin tarihidir. Bu alan için belirteç olarak
  <MD> kullanılır. 12 byte uzunlukta “date” tipinde bir alan tutar.}
  property GTIN :string read FGTIN write SetGTIN;  //
  {Ürün barkodu(GTIN): Bu alan için belirteç olarak <GTIN> kullanılır. 14 karakter
   uzunlukta nümerik tipte bir alan tutar.}
  property XD   : TDateTime read FXD write SetXD;  //Son Kulanma Tarihi
  property BN :string read FBN write SetBN;        //Parti Numarası
  {Ürün Parti Numarası: Bu alan için belirteç olarak <BN> kullanılır. 20 karakter
  uzunlukta alfanümerik tipte bir alan tutar. Sadece Büyük harfler ve nümerik karakterler
  kullanılabilir. Türkçe karakter kullanılmaz.}
  property BelgeDD : TDateTime read FBelgeDD write SetBelgeDD;
  property BelgeDN : String read FBelgeDN write SetBelgeDN;
  property Urunler :TObjectList<TUrun> read FUrunler write SetUrunler; //10,000 Optimum performans için geçilmemesi gerekir.
  end;


 { TDepoAlimIstek = class(TSoapIstek)
  private
    FFR: string;
    FTO: string;
    FUrunler: TObjectList<TUrun>;
    FBelgeDN: string;
    FBelgeDD: TDateTime;
  protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
  published
  public
    constructor Create; override;
    destructor Destroy; override;
    property FR : string read FFR write FFR;
    property _TO : string read FTO write FTO;
    property BelgeDD : TDateTime read FBelgeDD write FBelgeDD;
    property BelgeDN : string read FBelgeDN write FBelgeDN;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;
         }


  TDepoDogrulamaIstek = class (TSoapIstek)
    private
    FFR: string;
    FUrunler: TObjectList<TUrun>;
    protected
     procedure Baslat; override;
     procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
    published
    public
    constructor Create; override;
    destructor Destroy; override;
    property FR : string read FFR write FFR;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;
  {TDepoAlimIadeIstek = class (TSoapIstek)
   private
    FUrunler: TObjectList<TUrun>;
    FFR: string;
    FBelgeDN: string;
    FBelgeDD: TDateTime;
    FTO: string;
   protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
   published
   public
    constructor Create; override;
    destructor Destroy; override;
    property FR : string read FFR write FFR;
    property _TO : string read FTO write FTO;
    property BelgeDD : TDateTime read FBelgeDD write FBelgeDD;
    property BelgeDN : string read FBelgeDN write FBelgeDN;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;   }

  { TUretimSatisIstek = class (TSoapIstek)
     private
    FUrunler: TObjectList<TUrun>;
    FFR: string;
    FBelgeDD: TDateTime;
    FTO: string;
    FBelgeDN: string;
     protected
     procedure Baslat; override;
     procedure GovdeHazirla; override;
     function GetServisUrl: string; override;
     published
     public
     constructor Create; override;
     destructor Destroy; override;
     property FR :string read FFR write FFR;
     property _TO :string read FTO write FTO;
     property BelgeDD :TDateTime read FBelgeDD write FBelgeDD;
     property BelgeDN :string read FBelgeDN write FBelgeDN;
     property Urunler :TObjectList<TUrun> read FUrunler write FUrunler;
   end;


  TDepoSatisIstek = class (TSoapIstek)
   private
    FUrunler: TObjectList<TUrun>;
    FFR: string;
    FBelgeDN: string;
    FBelgeDD: TDateTime;
    FTO: string;
   protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
   published
   public
    constructor Create; override;
    destructor Destroy; override;
    property FR : string read FFR write FFR;
    property _TO : string read FTO write FTO;
    property BelgeDD : TDateTime read FBelgeDD write FBelgeDD;
    property BelgeDN : string read FBelgeDN write FBelgeDN;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;     }

  //yeni servisler
  TSatisIstek = class (TSoapIstek)
    private
      FUrunler: TObjectList<TUrun>;
      FTOGLN: string;
    protected
      procedure Baslat;override;
      procedure GovdeHazirla; override;
      function GetServisUrl: string; override;
    Published
    Public
      constructor Create; override;
      destructor Destroy; override;
      property TOGLN : string read FTOGLN write FTOGLN;
      property Urunler :TObjectList<TUrun> read FUrunler write FUrunler;
  end;

  TSatisIptalIstek = class (TSoapIstek)
    private
    FUrunler: TObjectList<TUrun>;
    protected
      procedure Baslat; override;
      procedure GovdeHazirla;override;
      function GetServisUrl:string;override;
    published
    public
      constructor Create;override;
      destructor Destroy;override;
      property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;

    TAlimIstek = class(TSoapIstek)
  private
    FUrunler: TObjectList<TUrun>;
    protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
  published
  public
    constructor Create; override;
    destructor Destroy; override;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;

  end;

  //****************************************

 { TDepoSatisIptalIstek = class (TSoapIstek)
   private
    FUrunler: TObjectList<TUrun>;
    FFR: string;
    FBelgeDN: string;
    FBelgeDD: TDateTime;
    FTO: string;
   protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
   published
   public
    constructor Create; override;
    destructor Destroy; override;
    property FR : string read FFR write FFR;
    property _TO : string read FTO write FTO;
    property BelgeDD : TDateTime read FBelgeDD write FBelgeDD;
    property BelgeDN : string read FBelgeDN write FBelgeDN;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;
  TUretimSatisIptalIstek = class(TSoapIstek)
    private
    FFR: string;
    FUrunler: TObjectList<TUrun>;
    FBelgeDD: TDateTime;
    FTO: string;
    FBelgeDN: string;
    protected
    procedure Baslat ;override;
    procedure GovdeHazirla;override;
    function GetServisUrl :string ;override;
    published
    public
    constructor Create;override;
    destructor Destroy; override;
    property FR :string read FFR write FFR;
    property _TO : string read FTO write FTO;
    property BelgeDD : TDateTime read FBelgeDD write FBelgeDD;
    property BelgeDN : string read FBelgeDN write FBelgeDN;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;
              }


  TDeAktivasyonIstek = class(TSoapIstek)
  private
    FFR: string;
    FUrunler: TObjectList<TUrun>;
    FBelgeDN: string;
    FBelgeDD: TDateTime;
    FDS: string;
    FISACIKLAMA: string;
  protected
    procedure Baslat; override;
    procedure GovdeHazirla; override;
    function GetServisUrl: string; override;
  published
  public
    constructor Create; override;
    destructor Destroy; override;
    property FR : string read FFR write FFR;
    property DS : string read FDS write FDS;
    property ISACIKLAMA : string read FISACIKLAMA write FISACIKLAMA;

    property BelgeDD : TDateTime read FBelgeDD write FBelgeDD;
    property BelgeDN : string read FBelgeDN write FBelgeDN;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;

  TSoapYanit = class
  private
    FFaultString: string;
    FFaultCode: string;
    FEFaultString: string;
    FEFaultCode: string;
    FHataServisAdi: string;
    function GetServisAdi: string;
  protected
    FGovde : TXmlItem;
    FXml : TECXMLParser;
  public
    procedure YanitiIsle;virtual;
    constructor Create(Stream: TStringStream);virtual;
    destructor Destroy;override;
    property ServisAdi : string read GetServisAdi;
    property HataServisAdi : string read FHataServisAdi;
    property FaultCode : string read FFaultCode;
    property FaultString : string read FFaultString;
    property EFaultCode : string read FEFaultCode;
    property EFaultString : string read FEFaultString;
  end;

  TGenelYanit = class(TSoapYanit)
  private
    FUrunDurumlar: TObjectList<TUrunDurum>;
    FBildirimId: string;
    FYanitHatali: Boolean;
  protected
  published
  public
    constructor Create(Stream: TStringStream); override;
    destructor Destroy; override;
    procedure YanitiIsle; override;
    property BildirimId : string read FBildirimId;
    property UrunDurumlar : TObjectList<TUrunDurum> read FUrunDurumlar;
    property YanitHatali : Boolean read FYanitHatali;
  end;

  TGeneLYanitV12 = class (TSoapYanit)
    private
    FUrunDurumlar: TObjectList<TUrunDurum>;
    FBildirimId: string;
    FYanitHatali: Boolean;
  protected
  published
  public
    constructor Create(Stream: TStringStream); override;
    destructor Destroy; override;
    procedure YanitiIsle; override;
    property BildirimId : string read FBildirimId;
    property UrunDurumlar : TObjectList<TUrunDurum> read FUrunDurumlar;
    property YanitHatali : Boolean read FYanitHatali;
  end;



  TGenelYanitPTS = class(TSoapYanit)
  private
     FBildirimId: string;
    FYanitHatali: Boolean;
    FTransferID: string;
  protected
  published
  public
    constructor Create(Stream: TStringStream); override;
    destructor Destroy; override;
    procedure YanitiIsle; override;
    property BildirimId : string read FBildirimId;
    property TransferID :string read FTransferID;
    property YanitHatali : Boolean read FYanitHatali;
  end;


   TGenelDetayYanitPTS = class(TSoapYanit)
  private
    FTransferDetay: TObjectList<TTransferDetay>;
    FYanitHatali: Boolean;
  protected
  published
  public
    constructor Create(Stream: TStringStream); override;
    destructor Destroy; override;
    procedure YanitiIsle; override;
    property TransferDetay : TObjectList<TTransferDetay> read FTransferDetay write FTransferDetay;
    property YanitHatali : Boolean read FYanitHatali;
  end;



  TGenelAlimYanitPTS = class(TSoapYanit)
  private
    FGelenString: String;
    FYanitHatali: Boolean;
  protected
  published
  public
    constructor Create(Stream: TStringStream); override;
    destructor Destroy; override;
    procedure YanitiIsle; override;
    property GelenString : string read FGelenString;
    property YanitHatali : Boolean read FYanitHatali;

  end;

  TUretimBildirimYanit = class (TSoapYanit)
    private
    FUrunDurumlar: TObjectList<TUrunDurumUretim>;
    FBn: string;
    FBildirimId: string;
    FGtin: string;
    FYanitHatali: Boolean;
    FXd: TDateTime;
    FMd: TDateTime;
    protected
    published
    public
    constructor Create(Stream : TStringStream); override;
    destructor Destroy; override;
    procedure YanitiIsle; override;
    property BildirimId : string read FBildirimId;
    property Md        : TDateTime read FMd;
    property Gtin       : string read FGtin;
    property Xd         : TDateTime read FXd;
    property Bn         : string  read FBn;
    property UrunDurumlar : TObjectList<TUrunDurumUretim> read FUrunDurumlar;
    property YanitHatali :Boolean read FYanitHatali;
  end;

var
 // ServisUrlOnEki : string = 'http://212.174.130.240/';
  ServisUrlOnEki : string = 'http://its.saglik.gov.tr/';


implementation

uses FetaKurulusSiniflari,FetaClassExtensions,ADODB,db;

function PtsDateToDate(ADate : string): TDateTime;
begin
  if ADate= '' then
  Result := now
  else
  begin
    if Pos('.',ADate) = 3  then
      begin
      Result := EncodeDate(StrToInt(Copy(ADate,7,4)),StrToInt(Copy(ADate,4,2)),StrToInt(Copy(ADate,1,2)))
      end else
      begin
      Result := EncodeDate(StrToInt(Copy(ADate,1,4)),StrToInt(Copy(ADate,6,2)),StrToInt(Copy(ADate,9,2)));
      end;
    end;
  end;

procedure TSoapIstek.Baslat;
begin

end;

procedure TSoapIstek.BaslikHazirla;
begin
  if (Assigned(FXml)) then
    FreeAndNil(FXml);
  FXml := TECXMLParser.Create(nil);
  FXml.Root.Name := 'soapenv:Envelope';
  FXml.Root.Params.Add('xmlns:soapenv=http://schemas.xmlsoap.org/soap/envelope/');
  with FXml.Root.New do begin
    Name := 'soapenv:Header';
  end;
  FGovde := FXml.Root.New;
  with FGovde do begin
    Name := 'soapenv:Body';
  end;
end;

constructor TSoapIstek.Create;
begin

end;

destructor TSoapIstek.Destroy;
begin
  if (Assigned(FXml)) then
    FXml.Free;
  inherited;
end;

function TSoapIstek.GetIcerik: TStream;
begin
  BaslikHazirla;
  Baslat;
  GovdeHazirla;
  Result := TMemoryStream.Create;
  FXml.SaveToStream(Result);
  Result.Position:=0;
end;

function TSoapIstek.GetIcerikString: AnsiString;
var
  ss : TStringStream;
begin
  BaslikHazirla;
  Baslat;
  GovdeHazirla;
  ss := TStringStream.Create;
  try
    FXml.SaveToStream(ss);
    Result := ss.DataString;
  finally
    ss.Free;
  end;
  FXml.SaveToFile('c:\Gentegre\GidenXml\Gönderilen'+FormatDateTime('yyyyMMddhhnnss',Now)+'.xml');
end;

function TSoapIstek.GetServisUrl: string;
begin
  Result := '';
end;

procedure TSoapIstek.GovdeHazirla;
begin

end;

{ TDepoAlimIstek }
{
procedure TDepoAlimIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:depo=http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo');
end;

constructor TDepoAlimIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;

end;

destructor TDepoAlimIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TDepoAlimIstek.GetServisUrl: string;
begin
  Result := ServisUrlOnEki + 'DepoMalAlim/DepoMalAlimReceiverService';
end;

procedure TDepoAlimIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'depo:DepoMalAlim';
    with New do begin
      Name := 'DT';
      Text := 'A';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'TO';
      Text := FTO;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;
end;

{ TUrun }

class function TUrun.Yeni(AGTIN, ABN, ASN: string; AXD: TDAteTime): TUrun;
begin
  Result := TUrun.Create;
  Result.GTIN := AGTIN;
  Result.BN := ABN;
  Result.SN := ASN;
  Result.XD := AXD;
end;

{ TSoapYanit }

constructor TSoapYanit.Create(Stream: TStringStream);
var
  I: Integer;
  str : string;
begin
  FXml := TECXMLParser.Create(nil);
  //FXML.DefaultLargeTokenizer:=True;
  //Stream.Position:=0;
  //str:=StringReplace(Stream.ReadString(Stream.Size),#13#10,'',[rfReplaceAll]);
  //Stream.Clear;
  //stream.Position:=0;
  //Stream.WriteString(str);
  //A FXml.DefaultLargeTokenizer := True;
  FXml.LoadFromStream(Stream);
  for I := 0 to FXml.Root.SubItemCount - 1 do begin
    if ( Pos('BODY',UpperCase(FXml.Root.SubItems[i].Name)) > 0) then begin
      FGovde := FXml.Root.SubItems[i].SubItems[0];
      YanitiIsle;
      Exit;
    end;
  end;
 Stream.Position:=0;
end;

destructor TSoapYanit.Destroy;
begin

  inherited;
end;


function TSoapYanit.GetServisAdi: string;
var
  i : Integer;
begin
  Result := '';
  if Assigned(FGovde) then begin
    i := Dize.TerstenAra(':',FGovde.Name);
    Result := Copy(FGovde.Name, i + 1, (Length(FGovde.Name) - i) + 1);
  end;
end;


procedure TSoapYanit.YanitiIsle;
begin

end;

{ TGenelYanit }

constructor TGenelYanit.Create(Stream: TStringStream);
begin
  FUrunDurumlar := TObjectList<TUrunDurum>.Create;
  inherited;
end;

destructor TGenelYanit.Destroy;
begin
  FUrunDurumlar.Free;
  inherited;
end;

procedure TGenelYanit.YanitiIsle;
var
  urunler : TXMLItem;
  I: Integer;
begin
  inherited;
  if Pos('FAULT',UpperCase(FGovde.Name)) > 0 then begin
    FYanitHatali := True;
    FFaultCode := FGovde.NamedItem['faultcode'].Text;
    FFaultString := Utf8ToAnsi( FGovde.NamedItem['faultstring'].Text);
    if FGovde.IndexOfName('detail') > -1 then begin
    FEFaultCode := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FC'].Text;
    FEFaultString := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FM'].Text;
    FHataServisAdi := FGovde.NamedItem['detail'].SubItems[0].Params.ValueFromIndex[0];
    i := Dize.TerstenAra('/', FHataServisAdi);
    FHataServisAdi := Copy(FHataServisAdi, i + 1, (Length(FHataServisAdi) - i) + 1);
    end;
  end else begin
    FYanitHatali := False;
    FBildirimId := FGovde.NamedItem['BILDIRIMID'].Text;
    urunler := FGovde.NamedItem['URUNLER'];
    for I := 0 to urunler.SubItemCount - 1 do
      FUrunDurumlar.Add(TUrunDurum.Create(urunler[i]));
  end;
end;

{ TUrunDurum }

constructor TUrunDurum.Create(ANode: TXMLItem);
begin
  FGTIN := ANode.NamedItem['GTIN'].Text;
  FSN := ANode.NamedItem['SN'].Text;
  FUC := ANode.NamedItem['UC'].Text;
end;



{ TDepoDogrulamaIstek }

procedure TDepoDogrulamaIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:depo=http://its.iegm.gov.tr/bildirim/BR/v1/Dogrulama/Depo');
end;

constructor TDepoDogrulamaIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TDepoDogrulamaIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TDepoDogrulamaIstek.GetServisUrl: string;
begin
  Result := ServisUrlOnEki + 'DepoDogrulama/DepoDogrulamaReceiverService';
end;

procedure TDepoDogrulamaIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'depo:DepoDogrulamaBildirim';
    with New do begin
      Name := 'DT';
      Text := 'V';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;

end;

{ TDepoAlimIadeIstek }
{
procedure TDepoAlimIadeIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:depo=http://its.iegm.gov.tr/bildirim/BR/v1/Iade/Depo');
end;

constructor TDepoAlimIadeIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;

end;

destructor TDepoAlimIadeIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TDepoAlimIadeIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki + 'DepoMalIade/DepoMalIadeReceiverService';
end;

procedure TDepoAlimIadeIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'depo:DepoMalIade';
    with New do begin
      Name := 'DT';
      Text := 'F';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'TO';
      Text := FTO;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;

end;

{ TDepoSatısIstek }
 {
procedure TDepoSatisIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:dep=http://its.iegm.gov.tr/bildirim/BR/v1/Satis/DepoSatis');
end;

constructor TDepoSatisIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TDepoSatisIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TDepoSatisIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki + 'DepoSatis/DepoSatisReceiverService';
end;

procedure TDepoSatisIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'dep:SatisBildirim';
    with New do begin
      Name := 'DT';
      Text := 'S';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'TO';
      Text := FTO;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;

end;

{ TDepoSatisIptalIstek }
 {
procedure TDepoSatisIptalIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:depo=http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Depo');
end;

constructor TDepoSatisIptalIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TDepoSatisIptalIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TDepoSatisIptalIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki + 'DepoSatisIptal/DepoSatisIptalReceiverService';
end;

procedure TDepoSatisIptalIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'depo:SatisIptalBildirim';
    with New do begin
      Name := 'DT';
      Text := 'C';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'TO';
      Text := FTO;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;

end;

{ TDeAktivasyonIstek }

procedure TDeAktivasyonIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:deak=http://its.iegm.gov.tr/bildirim/BR/v1/Deaktivasyon');
end;

constructor TDeAktivasyonIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TDeAktivasyonIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TDeAktivasyonIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki + 'DeaktivasyonBildirim/DeaktivasyonBildirimReceiverService';
end;

procedure TDeAktivasyonIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'deak:DeaktivasyonBildirim';
    with New do begin
      Name := 'DT';
      Text := 'D';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'DS';
      Text := FDS;
    end;
    with New do begin
      Name := 'ISACIKLAMA';
      Text := FISACIKLAMA;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;

end;

{ TPTSIstek }

procedure TPTSSoapIstek.Baslat;
begin

end;

procedure TPTSSoapIstek.BaslikHazirla;
begin
  if (Assigned(FXml)) then
    FreeAndNil(FXml);
   FXml := TECXMLParser.Create(nil);

   FXml.Root.Name := 'soapenv:Envelope';
   FXml.Root.Params.Add('xmlns:soapenv=http://schemas.xmlsoap.org/soap/envelope/');
   FXml.Root.Params.Add(FBaslikNS);
 //  FXml.Root.Params.Add('xmlns:xsd=http://www.w3.org/2001/XMLSchema');
 //  FXml.Root.Params.Add('xmlns:xsi=http://www.w3.org/2001/XMLSchema-instance');

   with FXml.Root.New do begin
   Name := 'soapenv:Header';
   end;
 FGovde := FXml.Root.New;
  with FGovde  do begin
    Name := 'soapenv:Body';
 //  Params.AddNameValue('xmlns:NS1','http://its.iegm.gov.tr/pts/sendpackage');
  end;
end;

constructor TPTSSoapIstek.Create;
begin
  inherited;
end;

destructor TPTSsoapIstek.Destroy;
begin
  if (Assigned(FXml)) then
   FXml.Free;
  inherited;
end;

function TPTSSoapIstek.GetIcerik: TStream;
begin
  BaslikHazirla;
  Baslat;
  GovdeHazirla;
  Result := TMemoryStream.Create;
  FXml.SaveToStream(Result);
  Result.Position:=0;
end;

function TPTSSoapIstek.GetIcerikString: AnsiString;
var
  ss : TStringStream;
begin
  BaslikHazirla;
  Baslat;
  GovdeHazirla;
  ss := TStringStream.Create;
  try
    FXml.SaveToStream(ss);
    Result := AnsiReplaceStr(ss.DataString,'<br/>','');
  finally
    ss.Free;
  end;
  FXml.SaveToFile('Gönderilen'+FormatDateTime('yyyyMMddhhnnss',Now)+'.xml');

end;

function TPTSSoapIstek.GetServisUrl: string;
begin
Result := '';
end;

procedure TPTSSoapIstek.GovdeHazirla;
begin

end;

{ TPTSAlimIstek }

procedure TPTSAlimIstek.Baslat;
begin
  inherited;

end;

constructor TPTSAlimIstek.Create;
begin
  inherited;
  FBaslikNS := 'xmlns:rec=http://its.iegm.gov.tr/pts/receivepackage';
  end;

destructor TPTSAlimIstek.Destroy;
begin
  inherited;
end;

function TPTSAlimIstek.GetServisUrl: string;
begin
Result := 'http://pts.saglik.gov.tr/PTS/PackageReceiverWebService';

end;

procedure TPTSAlimIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;

  with FGovde.New do begin
    Name := 'rec:receiveFileStreamParameters';
    with New do begin
      Name := 'sourceGLN';
      Text := FKaynak;
    end;
    with New do begin
      Name := 'transferId';
      Text := FTRANSFERID;
    end;
  end;
end;



{ TUretimBildirIstek }

procedure TUretimBildirIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:uret=http://its.iegm.gov.tr/bildirim/BR/v1/Uretim');
end;

constructor TUretimBildirIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TUretimBildirIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TUretimBildirIstek.GetServisUrl: string;
begin
  inherited;
  Result := ServisUrlOnEki + 'UretimBildirim/UretimBildirimReceiverService';
end;

procedure TUretimBildirIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'uret:Uretim';
    with New do begin
      Name := 'DT';
      Text := FDT;
    end;
    with New do begin
      Name := 'MI';
      Text := FMI;
    end;

    with New do begin
      Name := 'PT';
      Text := FPT;
    end;
    with New do begin
      Name := 'MD';
      Text := FormatDateTime('yyyy-MM-dd',FMD);
    end;
    with New do begin
      Name := 'GTIN';
      Text := FGTIN;
    end;
    with New do begin
      Name := 'XD';
      Text := FormatDateTime('yyyy-MM-dd',FXD);
    end;
    with New do begin
      Name := 'BN';
      Text := FBN;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
           with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
      end;
    end;
  end;

end;

procedure TUretimBildirIstek.SetBelgeDD(const Value: TDateTime);
begin
  FBelgeDD := Value;
end;

procedure TUretimBildirIstek.SetBelgeDN(const Value: String);
begin
  FBelgeDN := Value;
end;

procedure TUretimBildirIstek.SetBN(const Value: string);
begin
  FBN := Value;
end;

procedure TUretimBildirIstek.SetDT(const Value: string);
begin
  FDT := Value;
end;

procedure TUretimBildirIstek.SetGTIN(const Value: string);
begin
  FGTIN := Value;
end;

procedure TUretimBildirIstek.SetMD(const Value: TDateTime);
begin
  FMD := Value;
end;

procedure TUretimBildirIstek.SetMI(const Value: string);
begin
  FMI := Value;
end;

procedure TUretimBildirIstek.SetPT(const Value: string);
begin
  FPT := Value;
end;

procedure TUretimBildirIstek.SetUrunler(const Value: TObjectList<TUrun>);
begin
  FUrunler := Value;
end;

procedure TUretimBildirIstek.SetXD(const Value: TDateTime);
begin
  FXD := Value;
end;

{ TUretimBildirimYanit }

constructor TUretimBildirimYanit.Create(Stream: TStringStream);
begin
  FUrunDurumlar := TObjectList<TUrunDurumUretim>.Create;
  inherited;

end;

destructor TUretimBildirimYanit.Destroy;
begin
  FUrunDurumlar.Free;
  inherited;
end;

procedure TUretimBildirimYanit.YanitiIsle;
var
i:integer;
urunler : TXMLItem;
begin
  if Pos('FAULT',UpperCase(FGovde.Name)) > 0 then begin
    FYanitHatali := True;
    FFaultCode := FGovde.NamedItem['faultcode'].Text;
    FFaultString := Utf8ToAnsi( FGovde.NamedItem['faultstring'].Text);
    if FGovde.IndexOfName('detail') > -1 then begin
    FEFaultCode := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FC'].Text;
    FEFaultString := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FM'].Text;
    FHataServisAdi := FGovde.NamedItem['detail'].SubItems[0].Params.ValueFromIndex[0];
    i := Dize.TerstenAra('/', FHataServisAdi);
    FHataServisAdi := Copy(FHataServisAdi, i + 1, (Length(FHataServisAdi) - i) + 1);
    end;
  end else begin
    FYanitHatali := False;
    FBildirimId := FGovde.NamedItem['BILDIRIMID'].Text;
    FMd   := PtsDateToDate(FGovde.NamedItem['MD'].Text);
    FGtin := FGovde.NamedItem['GTIN'].Text;
    FXd   := PtsDateToDate(FGovde.NamedItem['XD'].Text);
    FBn   := FGovde.NamedItem['BN'].Text;
    urunler := FGovde.NamedItem['URUNLER'];
    for I := 0 to urunler.SubItemCount - 1 do
      FUrunDurumlar.Add(TUrunDurumUretim.Create(urunler[I]));
  end;
end;

{ TUrunlerSatisIstek }
 {
procedure TUretimSatisIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:dep=http://its.iegm.gov.tr/bildirim/BR/v1/Satis/UreticiSatis');
end;

constructor TUretimSatisIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TUretimSatisIstek.Destroy;
begin
   FUrunler.Free;
  inherited;
end;

function TUretimSatisIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki + 'UreticiSatis/UreticiSatisReceiverService';
end;

procedure TUretimSatisIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'dep:SatisBildirim';
    with New do begin
      Name := 'DT';
      Text := 'S';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'TO';
      Text := FTO;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
        end;
      end;
    end;
  end;
end;




{ TUretimSatisIptalIstek }
{
procedure TUretimSatisIptalIstek.Baslat;
begin
  inherited;
  FXml.Root.Params.Add('xmlns:uret=http://its.iegm.gov.tr/bildirim/BR/v1/SatisIptal/Uretici');

end;

constructor TUretimSatisIptalIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TUretimSatisIptalIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TUretimSatisIptalIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki + 'UreticiSatisIptal/UreticiSatisIptalReceiverService';
end;

procedure TUretimSatisIptalIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'uret:SatisIptalBildirim';
    with New do begin
      Name := 'DT';
      Text := 'C';
    end;
    with New do begin
      Name := 'FR';
      Text := FFR;
    end;
    with New do begin
      Name := 'TO';
      Text := FTO;
    end;
    with New do begin
      Name := 'BELGE';
      with New do begin
        Name := 'DD';
        Text := FormatDateTime('yyyy-MM-dd',FBelgeDD);
      end;
      with New do begin
        Name := 'DN';
        Text := FBelgeDN;
      end;
    end;
    with New do begin
      Name := 'URUNLER';
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'URUN';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
         end;
      end;
    end;
  end;


end;

{ TSSCC }

constructor TSSCC.Create;
begin

end;


class function TSSCC.Olustur(ATasimaTipi, AFirmaNumarasi, ABenzersizNumara: string): string;
var
I : Integer;
SSCC : string;
begin

//gln numarası 86800529-00019
 //Kontrol Basamağı : Modulo-10 yöntemine göre checksum hesaplanır .  (1)
 //Uzatma Basamağı : Taşima birimi firmanın kensi iç yapısında vereceği numaradır
 // (Taşıma Birimlerine göre)                 (1)
 //GS1 Firma Numarası : GS1 Organizyonun verdiği taşıma Firma numarası  il 7 veya 9 karakter alınacak  (7)
 //Taşıma Birimi seri numarası : Benzersiz taşıma birimi numarası (9)
   SSCC := ATasimaTipi+AFirmaNumarasi;
   for I := 1 to 16-Length(AFirmaNumarasi)-Length(ABenzersizNumara) do
   begin
    SSCC := SSCC+'0';
   end;
    SSCC := SSCC + ABenzersizNumara;
  Result := SSCC;
end;

{ TUrunListesi }

constructor TPTSUrun.Create;
begin
FSiraNo := TStringList.Create;

end;

destructor TPTSUrun.Destroy;
begin
FSiraNo.Free;
end;


class function TPTSUrun.XmldenGetir(AKok: TXMLItem): TPTSUrun;
var
  i : Integer;
  oge : TXMLItem;
begin
  Result := TPTSUrun.Create;
  Result.GTIN := AKok.Params.Values['GTIN'];
  Result.LotNumarasi := AKok.Params.Values['lotNumber'];
  Result.UretimTarihi := AKok.Params.Values['productionDate'];
  Result.SonKullanimTarihi := AKok.Params.Values['expirationDate'];
  for I := 0 to AKok.SubItemCount - 1 do begin
    oge := AKok.SubItems[i];
    Result.SiraNo.Add(oge.Text);
  end;

end;

procedure TPTSUrun.XmlOlustur(AKok: TXMLItem);
var
  I: Integer;
begin
  with AKok.New do begin
    Name := 'productList';
    Params.AddNameValue('GTIN',FGTIN);
    Params.AddNameValue('lotNumber',FLotNumarasi);
    if FUretimTarihi <> '' then
      Params.AddNameValue('productionDate', FormatDateTime('yyyy-MM-dd',StrToDateTime(FUretimTarihi)));
    Params.AddNameValue('expirationDate',FormatDateTime('yyyy-MM-dd',StrToDateTime(FSonKullanimTarihi)));
    if FPoSayisi <> '' then
      Params.AddNameValue('PONumber',FPoSayisi);
    for I := 0 to FSiraNo.Count - 1 do begin
      with New do begin
        Name := 'serialNumber';
        Text := FSiraNo[i];
      end;
    end;
  end;
end;

{ TTasiyici }

constructor TTasiyici.Create;
begin
  FUrunListesi := Tlist<TPTSUrun>.Create;
  FIcTasiyicilar := TList<TTasiyici>.Create;
end;

destructor TTasiyici.Destroy;
begin
FUrunListesi.Free;
FIcTasiyicilar.Free;
end;

procedure TTasiyici.VeriTabaniKaydet(PaketID:Integer;TasiyiciID:Integer);
var
I ,j: Integer;
cmd : TADOCommand;
begin
      with Veritabani.SorguBaslat(Tablo.cnn,'INSERT INTO ITS_PTS_GELEN_TASIMA_BIRIMI (ETIKET,TIP,ITS_PTS_PAKET_ID,USTID) '
                        +'VALUES ($ETIKETP,$TIPP,$ITS_PTS_PAKET_ID,$USTID) '
                        +'SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY] ',
                        ['$ETIKETP','$TIPP','$ITS_PTS_PAKET_ID','$USTID'],
                        [Etiket,Tip,PaketID,TasiyiciID])   do
      try
      open;
        while not Eof do begin
           TasiyiciID := FieldByName('SCOPE_IDENTITY').AsInteger;
           Next;
        end;
      finally
        Free;
      end;


     cmd := Veritabani.KomutBaslat(Tablo.cnn,'INSERT INTO ITS_PTS_GELEN_URUN (GTIN,LOTNUMARASI,URETIMTARIHI,  ' +
            'SONKULLANIMTARIHI,POSAYISI,SIRANO,PTS_GELEN_PAKET_ID,PTS_GELEN_TASIMA_BIRIMI_ID) VALUES ('
            +':GTIN,:LOTNUMARASI,:URETIMTARIHI,:SONKULLANIMTARIHI,:POSAYISI,:SIRANO,'
            +' '+IntToStr(PaketID)+','+IntToStr(TasiyiciID)+' ) ',[],[]);
     cmd.Parameters[0].DataType := ftString;
     cmd.Parameters[0].Size := 50;
     cmd.Parameters[1].DataType := ftString;
     cmd.Parameters[1].Size := 50;
     cmd.Parameters[2].DataType := ftDateTime;
     cmd.Parameters[3].DataType := ftDateTime;
     cmd.Parameters[4].DataType := ftString;
     cmd.Parameters[4].Size := 50;
     cmd.Parameters[5].DataType := ftString;
     cmd.Parameters[5].Size := 50;
     cmd.Prepared := True;

  for I := 0 to UrunListesi.Count - 1 do begin
    for j := 0 to UrunListesi[I].SiraNo.Count - 1 do begin
     cmd.Parameters[0].Value := UrunListesi[I].GTIN;
     cmd.Parameters[1].Value := UrunListesi[I].LotNumarasi;
     if UrunListesi[I].UretimTarihi<>'' then
     cmd.Parameters[2].Value := UrunListesi[I].UretimTarihi;
     cmd.Parameters[3].Value := UrunListesi[I].SonKullanimTarihi;
     cmd.Parameters[4].Value := UrunListesi[I].PoSayisi;
     cmd.Parameters[5].value := UrunListesi[I].SiraNo[j];
     cmd.Execute;
    {Veritabani.BasitKomutÇalıştır(Tablo.cnn,'INSERT INTO ITS_PTS_GELEN_URUN (GTIN,LOTNUMARASI,URETIMTARIHI,'
                        +'SONKULLANIMTARIHI,POSAYISI,SIRANO,PTS_GELEN_PAKET_ID,PTS_GELEN_TASIMA_BIRIMI_ID) VALUES ('
                        +'$GTIN,$LOTNUMARASI,$URETIMTARIHI,$SONKULLANIMTARIHI,$POSAYISI,$SIRANO,'
                        +'$PTS_GELEN_PAKET_ID,$PTS_GELEN_TASIMA_BIRIMI_ID ) ',
                        ['$GTIN','$LOTNUMARASI','$URETIMTARIHI','$SONKULLANIMTARIHI','$POSAYISI',
                        '$SIRANO','$PTS_GELEN_PAKET_ID','$PTS_GELEN_TASIMA_BIRIMI_ID'],
                        [UrunListesi[I].GTIN,UrunListesi[I].LotNumarasi,UrunListesi[I].UretimTarihi,
                        UrunListesi[I].SonKullanimTarihi,UrunListesi[I].PoSayisi,UrunListesi[I].SiraNo[j],PaketID,TasiyiciID]
                        );  }


    end;

  end;

  for I := 0 to IcTasiyicilar.Count - 1 do
  begin
    IcTasiyicilar[I].VeriTabaniKaydet(PaketID,TasiyiciID);
  end;


end;

class function TTasiyici.XmldenGetir(APtsXml: TPtsXml;AKok: TXmlItem): TTasiyici;
var
  i : Integer;
  oge : TXMLItem;
begin
  Result := TTasiyici.Create;
  Result.FPtsXml := APtsXml;
  Result.Etiket := AKok.Params.Values['carrierLabel'];
  Result.Tip := AKok.Params.Values['containerType'];
  for I := 0 to AKok.SubItemCount - 1 do begin
    oge := AKok.SubItems[i];
    if oge.Name = 'carrier' then begin
      Result.IcTasiyicilar.Add(TTasiyici.XmldenGetir(APtsXml, oge));
    end else if oge.Name = 'productList' then begin
      Result.UrunListesi.Add(TPTSUrun.XmldenGetir(oge));
    end;
  end;
end;



procedure TTasiyici.XmlOlustur(AKok: TXMLItem);
var
  kok : TXMLItem;
  I: Integer;
begin
  kok := AKok.New;
  with kok do begin
    Name := 'carrier';
    Params.AddNameValue('carrierLabel','00'+FEtiket);
    Params.AddNameValue('containerType',FTip);
  end;
  for I := 0 to FUrunListesi.Count - 1 do begin
    FUrunListesi[i].XmlOlustur(kok);
  end;
  for I := 0 to FIcTasiyicilar.Count - 1 do begin
    FIcTasiyicilar[i].XmlOlustur(kok);
  end;
end;

{ TPTSXmlOlustur }

procedure TPTSXml.BaslikOlustur;
begin

end;

constructor TPTSXml.Create;
begin
  inherited;
  FUrunListesi := Tlist<TPTSUrun>.Create;
  FTasiyici := TList<TTasiyici>.Create;
  FXml := TECXMLParser.Create(nil);
end;

destructor TPTSXml.Destroy;
begin
  FXml.Free;
  FUrunListesi.Free;
  FTasiyici.Free;
  inherited;
end;

procedure TPTSXml.GovdeOlustur;
var
  I: Integer;
begin
 FXml.Root.Name := 'transfer';
 with FXml.Root do
 begin
    with New do begin
      Name := 'sourceGLN';
      Text := FKaynakGLN;
    end;
    with New do begin
      Name := 'destinationGLN';
      Text := FHedefGLN;
    end;
    with New do begin
      Name := 'actionType';
      Text := FTransferTipi;
    end;
    with New do begin
      Name := 'shipTo';
      Text := FSevkNereye;
    end;
    with New do begin
      Name := 'documentNumber';
      Text := FBelgeNumarasi;
    end;
    with New do begin
      Name := 'documentDate';
      Text := FormatDateTime('yyyy-MM-dd',FBelgeTarihi);
    end;
    with New do begin
      Name := 'note';
      Text := FTransferNot;
    end;
    with New do begin
      Name := 'version';
      Text := FVersiyon;
    end;
 end;
 for I := 0 to FTasiyici.Count - 1 do
  FTasiyici[i].XmlOlustur(FXml.Root);

end;

procedure TPTSXml.VeriTabaniKaydet(TransferID:string);
var
  I: Integer;
  PaketID : Integer;
begin
      with Veritabani.SorguBaslat(Tablo.cnn,'INSERT INTO ITS_PTS_GELEN_PAKET (KAYNAKGLN,HEDEFGLN,TRANSFERTIPI,SEVKNEREYE, '
                        +'BELGENUMARASI,BELGETARIHI,TRANSFERNOT,VERSIYON,TRANSFERID) VALUES ('
                        +'$KAYNAKGLNP,$HEDEFGLNP,$TRANSFERTIPIP,$SEVKNEREYEP,'
                        +'$BELGENUMARASIP,$BELGETARIHIP,$TRANSFERNOTP,$VERSIYONP,$TRANSFERIDP) '
                        +'SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY] ',
                        ['$KAYNAKGLNP','$HEDEFGLNP','$TRANSFERTIPIP','$SEVKNEREYEP',
                        '$BELGENUMARASIP','$BELGETARIHIP','$TRANSFERNOTP','$VERSIYONP','$TRANSFERIDP'],
                        [KaynakGLN,HedefGLN,TransferTipi,SevkNereye,
                        BelgeNumarasi,BelgeTarihi,TransferNot,Versiyon,TransferID]) do
      try
      open;
        while not Eof do begin
           PaketID := FieldByName('SCOPE_IDENTITY').AsInteger;
           Veritabani.BasitKomutÇalıştır(Tablo.cnn,'UPDATE ITS_BILDIRILMIS_PAKETLER SET DURUM=1 WHERE TRANSFERID='''+TransferID+''' ',[],[]);
           next;
        end;
      finally
        Free;
      end;
    for I := 0 to FTasiyici.Count - 1 do
      FTasiyici[i].VeriTabaniKaydet(PaketID,-1);

end;

procedure TPTSXml.ZipKaydet;
var
kzip : TKAZip;
XmlFile,Zipfile : TFileStream;
StrStream : TFileStream;
yol,XmlAdi : string;
begin
  GovdeOlustur;
  yol := 'c:\Gentegre\ITS\';
  XmlAdi:= FKaynakGLN + '_' + FHedefGLN + '_' + FBelgeNumarasi + '_' + FormatDateTime('yyyyMMdd',FBelgeTarihi) + '.xml';
  FXml.SaveToFile(yol + XmlAdi);
  Xmlfile := TFileStream.Create(yol + XmlAdi,fmOpenRead);
  Zipfile := TFileStream.Create(yol + 'GonderilecekXml.zip',fmCreate);
  kzip := TKAZip.Create(nil);
  Zipfile.Position:=0;
  kzip.CreateZip(Zipfile);
  Zipfile.Free;
  kzip.Open(yol + 'GonderilecekXml.zip');
  Zipfile.Position:=0;
  kzip.Entries.AddStream(Xmladi,XmlFile);
  kzip.Close;
  kzip.Free;
  XmlFile.Free;
end;

class function TPTSXml.XmldenGetir(AItem: TXmlItem): TPtsXml;
var
  tas : TTasiyici;
begin
  Result := TPTSXml.Create;
  Result.KaynakGLN := AItem.NamedItem['sourceGLN'].Text;
  Result.HedefGLN := AItem.NamedItem['destinationGLN'].Text;
  Result.TransferTipi := AItem.NamedItem['actionType'].Text;
  Result.SevkNereye := AItem.NamedItem['shipTo'].Text;
  Result.BelgeNumarasi := AItem.NamedItem['documentNumber'].Text;
  Result.BelgeTarihi := PtsDateToDate(AItem.NamedItem['documentDate'].Text);
  Result.TransferNot := AItem.NamedItem['note'].Text;
  Result.Versiyon := AItem.NamedItem['version'].Text;
  tas := TTasiyici.XmldenGetir(Result,AItem.NamedItem['carrier']);
  Result.Tasiyici.Add(tas);
end;

function TPTSXml.XmltoString:string;
var
  Zipfile :TStream;
  ss : TStringStream;
begin
  ss := TStringStream.Create;
  ZipFile:=TFileStream.Create('C:\Gentegre\ITS\GonderilecekXml.zip', fmOpenRead);
  try
    Zipfile.Position:=0;
    EncodeStream(zipfile,ss);
    Result := ss.DataString;
  finally
   Zipfile.Free;
  end;
end;

{ TPTSGonderimIstek }

procedure TPTSGonderimIstek.Baslat;
begin
  inherited;

 // FXml.Root.Params.Add('xmlns:http://its.iegm.gov.tr/pts/sendpackage');
end;

constructor TPTSGonderimIstek.Create;
begin
  inherited;
    FBaslikNS := 'xmlns:sen=http://its.iegm.gov.tr/pts/sendpackage';
end;

destructor TPTSGonderimIstek.Destroy;
begin
  inherited;
end;

function TPTSGonderimIstek.GetServisUrl: string;
begin
Result := 'http://pts.saglik.gov.tr/PTS/PackageSenderWebService';
end;

procedure TPTSGonderimIstek.GovdeHazirla;
begin
inherited;
  FBaslikNS := 'xmlns:sen=http://its.iegm.gov.tr/pts/sendpackage';
  with FGovde.New do begin
    Name := 'sen:sendFileStreamParameters';
    //Params.AddNameValue('xmlns','http://its.iegm.gov.tr/pts/sendpackage');
    with New do begin
    Name :='sendFileParameters';
    //Params.AddNameValue('xmlns','');
    //Params.AddNameValue('xsi:type','NS1:sendFileParameters');
    with New do begin
      Name := 'sourceGLN';
      Text := FKaynekGLN;
    end;
    with New do begin
      Name := 'destinationGLN';
      Text := FHedefGLN;
    end
    end;
    with New do begin
    Name :='fileStreamElement';
    //Params.AddNameValue('xmlns','');
    Text :=FOlusanXml.XmltoString;
    end;
    end;
end;

{ TGenelYanitPTS }

constructor TGenelYanitPTS.Create(Stream: TStringStream);
begin
  inherited;

end;

destructor TGenelYanitPTS.Destroy;
begin

  inherited;
end;

procedure TGenelYanitPTS.YanitiIsle;
var
i:Integer;
begin
  inherited;
  if Pos('FAULT',UpperCase(FGovde.Name)) > 0 then begin
    FYanitHatali := True;
    FFaultCode := FGovde.NamedItem['faultcode'].Text;
    FFaultString := Utf8ToAnsi( FGovde.NamedItem['faultstring'].Text);
    if FGovde.IndexOfName('detail') > -1 then begin
    FEFaultCode := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FC'].Text;
    FEFaultString := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FM'].Text;
    FHataServisAdi := FGovde.NamedItem['detail'].SubItems[0].Params.ValueFromIndex[0];
    i := Dize.TerstenAra('/', FHataServisAdi);
    FHataServisAdi := Copy(FHataServisAdi, i + 1, (Length(FHataServisAdi) - i) + 1);
    end;
  end else begin
    FYanitHatali := False;
    FTransferID := FGovde.NamedItem['transferId'].Text;
  end;

end;

{ TGenelAlimYanitPTS }

constructor TGenelAlimYanitPTS.Create(Stream: TStringStream);
begin

  inherited;


end;

destructor TGenelAlimYanitPTS.Destroy;
begin

  inherited;
end;

procedure TGenelAlimYanitPTS.YanitiIsle;
var
i:Integer;
begin
  inherited;
  if Pos('FAULT',UpperCase(FGovde.Name)) > 0 then begin
    FYanitHatali := True;
    FFaultCode := FGovde.NamedItem['faultcode'].Text;
    FFaultString := Utf8ToAnsi( FGovde.NamedItem['faultstring'].Text);
    if FGovde.IndexOfName('detail') > -1 then begin
    FEFaultCode := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FC'].Text;
    FEFaultString := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FM'].Text;
    FHataServisAdi := FGovde.NamedItem['detail'].SubItems[0].Params.ValueFromIndex[0];
    i := Dize.TerstenAra('/', FHataServisAdi);
    FHataServisAdi := Copy(FHataServisAdi, i + 1, (Length(FHataServisAdi) - i) + 1);
    end;
  end else begin
    FYanitHatali := False;
    FGelenString:=FGovde.Text;
  end;

end;

{ TPTSDetayIstek }

procedure TPTSDetayIstek.Baslat;
begin
  inherited;

end;

constructor TPTSDetayIstek.Create;
begin
  inherited;
FBaslikNS := 'xmlns:rec=http://its.iegm.gov.tr/pts/helper/receiveTrasnferDetails';
end;

destructor TPTSDetayIstek.Destroy;
begin

  inherited;
end;

function TPTSDetayIstek.GetServisUrl: string;
begin
Result := 'http://pts.saglik.gov.tr/PTS/PackageTransferHelperService';
end;

procedure TPTSDetayIstek.GovdeHazirla;
begin
  inherited;

   with FGovde.New do begin
    Name :='rec:receiveTransferDetailsParameters';
    with New do begin
      Name := 'sourceGLN';
      Text := FKaynakGLN;
    end;
    with New do begin
      Name := 'destinationGLN';
      Text := FHedefGLN;
    end;
    with New do begin
      Name := 'bringNotReceivedTransferInfo';
      Text := FTransferBilgisi;
    end;
    with New do begin
      Name := 'startDate';
      Text := FormatDateTime('yyyy-MM-dd',FBaslangicTarih);
    end;
    with New do begin
      Name := 'endDate';
      Text := FormatDateTime('yyyy-MM-dd',FBitisTarih);
    end;
   end;
end;

{ TGenelDetayYanitPTS }

constructor TGenelDetayYanitPTS.Create(Stream: TStringStream);
begin
  FTransferDetay := TObjectList<TTransferDetay>.Create;
  inherited;

end;

destructor TGenelDetayYanitPTS.Destroy;
begin

  inherited;
end;

procedure TGenelDetayYanitPTS.YanitiIsle;
var
i:Integer;
SS: TStringStream;
TranferDetay :txmlitem;
TransferDetayType : TTransferDetay;
begin
  inherited;
  if Pos('FAULT',UpperCase(FGovde.Name)) > 0 then begin
    FYanitHatali := True;
    FFaultCode := FGovde.NamedItem['faultcode'].Text;
    FFaultString := Utf8ToAnsi( FGovde.NamedItem['faultstring'].Text);
    if FGovde.IndexOfName('detail') > -1 then begin
    FEFaultCode := FGovde.NamedItem['detail'].SubItems[0].NamedItem['faultCode'].Text;
    FEFaultString := FGovde.NamedItem['detail'].SubItems[0].NamedItem['faultMessage'].Text;
    FHataServisAdi := FGovde.NamedItem['detail'].SubItems[0].Params.ValueFromIndex[0];
    i := Dize.TerstenAra('/', FHataServisAdi);
    FHataServisAdi := Copy(FHataServisAdi, i + 1, (Length(FHataServisAdi) - i) + 1);
    end;
  end else begin
  //
    TranferDetay := FGovde.NamedItem['transferDetails'];
    for I := 0 to TranferDetay.SubItemCount - 1 do
    begin
      TransferDetayType := TTransferDetay.Create;
      TransferDetayType.HedefGLN := TranferDetay.SubItems[I].NamedItem['sourceGLN'].Text;
      TransferDetayType.KaynakGLN := TranferDetay.SubItems[I].NamedItem['destinationGLN'].Text;
      TransferDetayType.TransferID := StrToInt(TranferDetay.SubItems[I].NamedItem['transferId'].Text);
      TransferDetayType.TransferTarih := PtsDateToDate(TranferDetay.SubItems[I].NamedItem['transferDate'].Text);
      FTransferDetay.Add(TransferDetayType);
    end;
  end;
end;

{ TUrunDurumUretim }

constructor TUrunDurumUretim.Create(ANode: TXMLItem);
begin
  FSN := ANode.NamedItem['SN'].Text;
  FUC := ANode.NamedItem['UC'].Text;
end;





{ TSatisIstek }

procedure TSatisIstek.Baslat;
begin
  inherited;
end;

constructor TSatisIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;

end;

destructor TSatisIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TSatisIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki +'ITSServices/DispatchNotification ';
end;

procedure TSatisIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'DispatchRequest';
    params.Add('xmlns=http://its.iegm.gov.tr/p2/notification/dispatch');
    with New do begin
      Name := 'TOGLN';
      Text := FTOGLN;
      Params.Add('xmlns=');
    end;
    with New do begin
      Name := 'PRODUCTS';
      Params.Add('xmlns=');
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'PRODUCT';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;

end;

{ TSatisIptalIstek }

procedure TSatisIptalIstek.Baslat;
begin
  inherited;

end;

constructor TSatisIptalIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TSatisIptalIstek.Destroy;
begin

  inherited;
end;

function TSatisIptalIstek.GetServisUrl: string;
begin
Result := ServisUrlOnEki +'ITSServices/DispatchCancellation';
end;

procedure TSatisIptalIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'DispatchCancellationRequest';
    params.Add('xmlns=http://its.iegm.gov.tr/p2/cancellation/dispatch');
    with New do begin
      Name := 'PRODUCTS';
      Params.Add('xmlns=');
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'PRODUCT';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;
end;

{ TGeneLYanitV12 }

constructor TGeneLYanitV12.Create(Stream: TStringStream);
begin
  FUrunDurumlar := TObjectList<TUrunDurum>.Create;
  inherited;
end;

destructor TGeneLYanitV12.Destroy;
begin
  FUrunDurumlar.Free;
  inherited;
end;

procedure TGeneLYanitV12.YanitiIsle;
var
  urunler : TXMLItem;
  I: Integer;
begin
  inherited;
  if Pos('FAULT',UpperCase(FGovde.Name)) > 0 then begin
    FYanitHatali := True;
    FFaultCode := FGovde.NamedItem['faultcode'].Text;
    FFaultString := Utf8ToAnsi( FGovde.NamedItem['faultstring'].Text);
    if FGovde.IndexOfName('detail') > -1 then begin
    FEFaultCode := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FC'].Text;
    FEFaultString := FGovde.NamedItem['detail'].SubItems[0].NamedItem['FM'].Text;
    FHataServisAdi := FGovde.NamedItem['detail'].SubItems[0].Params.ValueFromIndex[0];
    i := Dize.TerstenAra('/', FHataServisAdi);
    FHataServisAdi := Copy(FHataServisAdi, i + 1, (Length(FHataServisAdi) - i) + 1);
    end;
  end else begin
    FYanitHatali := False;
    FBildirimId := FGovde.NamedItem['NOTIFICATIONID'].Text;
    urunler := FGovde.NamedItem['PRODUCTS'];
    for I := 0 to urunler.SubItemCount - 1 do
      FUrunDurumlar.Add(TUrunDurum.Create(urunler[i]));
  end;
end;

{ TAlimIstek }

procedure TAlimIstek.Baslat;
begin
  inherited;
end;

constructor TAlimIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TAlimIstek.Destroy;
begin

  inherited;
end;

function TAlimIstek.GetServisUrl: string;
begin
  Result := ServisUrlOnEki + 'ITSServices/ReceiptNotification';
end;

procedure TAlimIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'ReceiptRequest';
    params.Add('xmlns=http://its.iegm.gov.tr/notification/receipt');
    with New do begin
      Name := 'PRODUCTS';
      Params.add('xmlns=');
      for I := 0 to FUrunler.Count - 1 do begin
        urun := FUrunler[i];
        with New do begin
          Name := 'PRODUCT';
          with New do begin
            Name := 'GTIN';
            Text := urun.GTIN;
          end;
          with New do begin
            Name := 'BN';
            Text := urun.BN;
          end;
          with New do begin
            Name := 'SN';
            Text := urun.SN;
          end;
          with New do begin
            Name := 'XD';
            Text := FormatDateTime('yyyy-MM-dd', urun.XD);
          end;
        end;
      end;
    end;
  end;
end;




end.

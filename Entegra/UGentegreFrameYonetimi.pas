unit UGentegreFrameYonetimi;

interface

uses ECXMLParser, Classes, Controls, Forms, Contnrs, cxPC, Dialogs,
  FetaKurulusSiniflari,JvPanel, JvPageList, JvNavigationPane,
  Graphics, JvTransparentButton, SysUtils,Windows,Messages,
  FetaClassExtensions, UMultiCastEvent, UFrameYoneticisi,DBCtrls, ComCtrls,
  cxButtons, frxClass;

type

  TBeforeFrameLoadEvent = procedure(AFrameInfo: TXMLItem;Var CanLoad: Boolean) of object;

  TAnaFrameYoneticisi = class;

  //TAracCubuguFrameYoneticisi = class;

  TAramaFrameYoneticisi = class;

  TIcerikFrameYoneticisi = class;

  TAnaFrameBilgi = class;

  TIcerikFrameBilgi = class;

  TAramaFrameBilgi = class;

  //TAracCubuguFrameBilgi = class;

  TFrameOlayBaglamaBilgisi = class;

  IAnaBilgiFrame = interface(IBilgiFrame)
    ['{AC7CACD6-EDE8-485F-9A26-EA31B3FAE18F}']
    function GetFrameBilgi : TAnaFrameBilgi;
    procedure SetFrameBilgi(AValue: TAnaFrameBilgi);
    procedure IcerikFrameAktifOlacak(Sender: TIcerikFrameBilgi);
    {$REGION 'Özellikler'}
    property FrameBilgi : TAnaFrameBilgi read GetFrameBilgi write SetFrameBilgi;
    {$ENDREGION}
  end;
  
  IIcerikBilgiFrame = interface(IBilgiFrame)
    ['{3653296C-DC42-4404-9F18-AEBD9C87E504}']
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue: TIcerikFrameBilgi);
    {$REGION 'Özellikler'}
    property FrameBilgi : TIcerikFrameBilgi read GetFrameBilgi write SetFrameBilgi;
    {$ENDREGION}
  end;

  IAramaBilgiFrame = interface(IBilgiFrame)
    ['{B4793DA9-6D3B-4ED7-92E7-E9207C451155}']
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue: TAramaFrameBilgi);
    {$REGION 'Özellikler'}
    property FrameBilgi : TAramaFrameBilgi read GetFrameBilgi write SetFrameBilgi;
    {$ENDREGION}
  end;

  IAracCubuguDestegi = interface(IInterface)
    ['{73657F6A-D7E1-462E-931D-EECC05FAAD28}']
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
    procedure GezinmeBagla(ADBNavigator : TDBNavigator);
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
  end;

//  IAracCubuguBilgiFrame = interface(IBilgiFrame)
//    ['{0C088E8E-CEC3-4E39-BA87-6FD60A370457}']
//    function GetFrameBilgi : TAracCubuguFrameBilgi;
//    procedure SetFrameBilgi(AValue: TAracCubuguFrameBilgi);
//    {$REGION 'Özellikler'}
//    property FrameBilgi : TAracCubuguFrameBilgi read GetFrameBilgi write SetFrameBilgi;
//    {$ENDREGION}
//  end;

  TAnaFrameYoneticisi = class(TFrameYoneticisi)
  private
    FOnBeforeFrameLoad: TBeforeFrameLoadEvent;
  protected
    function GetAktifFrame: TAnaFrameBilgi; reintroduce;
    function AnaSekmeBul: TAnaFrameBilgi; reintroduce;
  public
    constructor Create(ASayfaDenetimi : TcxPageControl;AFrameYapilandirmaDosyasi : string);override;
    destructor Destroy;override;
    procedure FrameleriYukle;override;
    function FrameBul(AFrameBasligi : string): TAnaFrameBilgi;reintroduce;overload;
    function FrameBul(AFrameTipi : TFrameClass): TAnaFrameBilgi;reintroduce;overload;
    function FrameBul(AFrameOrnek : TFrame): TAnaFrameBilgi;reintroduce;overload;
    function FrameBulYumurtlanan(AFrameOrnek : TFrame): TAnaFrameBilgi;reintroduce;
    {$REGION 'Özellikler'}
    property AktifFrame : TAnaFrameBilgi read GetAktifFrame;
    property OnBeforeFrameLoad : TBeforeFrameLoadEvent read FOnBeforeFrameLoad write FOnBeforeFrameLoad;
    {$ENDREGION}
  end;

  TAnaFrameBilgi = class(TFrameBilgi)
  private
    //FAracCubuguFrameYoneticisi : TAracCubuguFrameYoneticisi;
    FAramaFrameYoneticisi : TAramaFrameYoneticisi;
    FIcerikFrameYoneticisi : TIcerikFrameYoneticisi;

    FAramaSayfaDenetimi : TcxPageControl;
    FIcerikSayfaDenetimi : TcxPageControl;
    //FAracCubuguSayfaDenetimi : TcxPageControl;
    FGorevFrameOrnek: TFrame;

    FIAnaBilgiFrame: IAnaBilgiFrame;

    { XML verileri }
    FAramaSayfaDenetimAdi : string;
    FIcerikSayfaDenetimAdi : string;
    FGorevlerPanelAdi : string;
    FFrameYonetilebilir : Boolean;
    FGorevFrameTipi: string;
    FGirisSayfasiTipi: string;
    FGorevPanelBoyu: string;
    FGorevFrameFrameBilgiProperty: string;
    FNavigatorAdi: string;
    FEkranYazAdi: string;
    FYaziciYazAdi: string;
    FYaziciYaz: TcxButton;
    FNavigator: TDBNavigator;
    FEkranYaz: TcxButton;
    FGezinmePaneliAdi: string;
    FGezinmePaneli: TWinControl;
    procedure SetAktifArama(const Value: TAramaFrameBilgi);
    procedure SetAktifIcerik(const Value: TIcerikFrameBilgi);
    function GetAktifArama: TAramaFrameBilgi;
    function GetAktifIcerik: TIcerikFrameBilgi;
    function GetAktifIcerikYazdirmaDestekli: Boolean;
  protected
    function GetFrameYoneticisi : TAnaFrameYoneticisi;reintroduce;
    procedure IcerikFrameHenuzBaslatildi(Sender: TObject);
    procedure IcerikFrameAktifOlacak(Sender: TObject);
  public
    constructor Create(AAnaFrameYoneticisi : TAnaFrameYoneticisi;ASayfaDenetimi: TcxPageControl);reintroduce;
    destructor Destroy;override;
    function Baslat: TAnaFrameBilgi; reintroduce;
    function Git: TAnaFrameBilgi; reintroduce;

    procedure Yukle(ABilgi: TXMLItem); override;
    function IcerikGit(AFrameClass : TFrameClass) : TIcerikFrameBilgi;overload;
    function IcerikGit(ABaslik: string) : TIcerikFrameBilgi;overload;
    function GitAdaGore: TAnaFrameBilgi; reintroduce;
    property AnaFrameIntf : IAnaBilgiFrame read FIAnaBilgiFrame;
    //property AracCubuguFrameYoneticisi : TAracCubuguFrameYoneticisi read FAracCubuguFrameYoneticisi;
    property IcerikFrameYoneticisi : TIcerikFrameYoneticisi read FIcerikFrameYoneticisi;
    property AramaFrameYoneticisi : TAramaFrameYoneticisi read FAramaFrameYoneticisi;
    property AramaSayfaDenetimi : TcxPageControl read FAramaSayfaDenetimi;
    property IcerikSayfaDenetimi : TcxPageControl read FIcerikSayfaDenetimi;
    property AnaFrameYoneticisi : TAnaFrameYoneticisi read GetFrameYoneticisi;
    property GorevFrameTipi : string read FGorevFrameTipi;
    property GorevFrameOrnek : TFrame read FGorevFrameOrnek;
    property GirisSayfasiTipi : string read FGirisSayfasiTipi;
    property GorevPanelBoyu : string read FGorevPanelBoyu;
    property GorevFrameFrameBilgiProperty : string read FGorevFrameFrameBilgiProperty;
    property NavigatorAdi : string read FNavigatorAdi;
    property EkranYazAdi : string read FEkranYazAdi;
    property YaziciYazAdi : string read FYaziciYazAdi;
    property GezinmePaneliAdi : string read FGezinmePaneliAdi;
    property Navigator : TDBNavigator  read FNavigator;
    property EkranYaz : TcxButton  read FEkranYaz;
    property YaziciYaz : TcxButton read FYaziciYaz;
    property GezinmePaneli : TWinControl read FGezinmePaneli;
    property AktifIcerik : TIcerikFrameBilgi read GetAktifIcerik write SetAktifIcerik;
    property AktifArama  : TAramaFrameBilgi read GetAktifArama write SetAktifArama;
    property AktifIcerikYazdirmaDestekli : Boolean read GetAktifIcerikYazdirmaDestekli;
    property FrameYonetilebilir : Boolean read FFrameYonetilebilir;

  end;

  TIcerikFrameYoneticisi = class(TFrameYoneticisi)
  private
    FAnaFrameBilgi : TAnaFrameBilgi;
    function GetAnaFrameYoneticisi: TAnaFrameYoneticisi;
    function GetAramaFrameYoneticisi: TAramaFrameYoneticisi;
  protected
    function GetAktifFrame: TIcerikFrameBilgi; reintroduce;
    function AnaSekmeBul: TIcerikFrameBilgi; reintroduce;
  public
    constructor Create(AAnaFrameBilgi : TAnaFrameBilgi;
      ASayfaDenetimi : TcxPageControl;
      AIcerikSekmeleri : TXMLItem);reintroduce;
    destructor Destroy;override;
    procedure FrameleriYukle(ABilgiler: TXMLItem);reintroduce;
    function FrameBul(AFrameBasligi : string): TIcerikFrameBilgi;reintroduce;overload;
    function FrameBul(AFrameTipi : TFrameClass): TIcerikFrameBilgi;reintroduce;overload;
    function FrameBul(AFrameOrnek : TFrame): TIcerikFrameBilgi;reintroduce;overload;
    function FrameBulYumurtlanan(AFrameOrnek : TFrame): TIcerikFrameBilgi;reintroduce;
    {$REGION 'Özellikler'}
    property AktifFrame : TIcerikFrameBilgi read GetAktifFrame;
    property AnaFrameYoneticisi : TAnaFrameYoneticisi read GetAnaFrameYoneticisi;
    property AnaFrameBilgi : TAnaFrameBilgi read FAnaFrameBilgi;
    property AramaFrameYoneticisi : TAramaFrameYoneticisi read GetAramaFrameYoneticisi;
    {$ENDREGION}
  end;

  TIcerikFrameBilgi = class(TFrameBilgi)
  private
    FAramaFrameTipi : string;
    //FAracCubuguFrameTipi : string;
    //FAracCubuguPropertyAdi: string;
    FAramaPropertyAdi: string;
    FIIIcerikFrameBilgi: IIcerikBilgiFrame;
    FAracCubuguDestegi: IAracCubuguDestegi;
    FAnaFrameBilgi: TAnaFrameBilgi;
    FAktifRaporAdi: string;
    function GetAramaFrameYoneticisi: TAramaFrameYoneticisi;
    function GetYazdirmaDestegi: Boolean;
  protected
    function GetFrameYoneticisi : TIcerikFrameYoneticisi;reintroduce;
    procedure FrameOrnekBaslatildi; override;
  public
    constructor Create(AIcerikFrameYoneticisi : TIcerikFrameYoneticisi;ASayfaDenetimi: TcxPageControl);reintroduce;
    destructor Destroy;override;
    function Baslat: TIcerikFrameBilgi; reintroduce;
    function Git: TIcerikFrameBilgi; reintroduce;
    function GitAdaGore: TIcerikFrameBilgi; reintroduce;
    function IcerikGit(AFrameClass: TFrameClass): TIcerikFrameBilgi;
    procedure Yukle(ABilgi: TXMLItem); override;
    property IcerikFrameYoneticisi : TIcerikFrameYoneticisi read GetFrameYoneticisi;
    property AramaFrameTipi : string read FAramaFrameTipi;
    //property AracCubuguFrameTipi : string read FAracCubuguFrameTipi;
    //property AracCubuguPropertyAdi : string read FAracCubuguPropertyAdi;
    property AramaPropertyAdi: string read FAramaPropertyAdi;
    property IIIcerikFrameBilgi : IIcerikBilgiFrame read FIIIcerikFrameBilgi;
    property AracCubuguDestegi : IAracCubuguDestegi read FAracCubuguDestegi;
    property AnaFrameBilgi : TAnaFrameBilgi read FAnaFrameBilgi;
    property AramaFrameYoneticisi : TAramaFrameYoneticisi read GetAramaFrameYoneticisi;
    property AktifRaporAdi : string read FAktifRaporAdi write FAktifRaporAdi;
    property YazdirmaDestegi : Boolean read GetYazdirmaDestegi;
  end;

  TAramaFrameYoneticisi = class(TFrameYoneticisi)
  private
    FAnaFrameBilgi: TAnaFrameBilgi;
    function GetAnaFrameYoneticisi: TAnaFrameYoneticisi;
    function GetIcerikFrameYoneticisi: TIcerikFrameYoneticisi;

  protected
    function GetAktifFrame: TAramaFrameBilgi; reintroduce;
    function AnaSekmeBul: TAramaFrameBilgi; reintroduce;
  public
    constructor Create(AAnaFrameBilgi : TAnaFrameBilgi;
      ASayfaDenetimi : TcxPageControl;
      AAramaSekmeleri : TXMLItem);reintroduce;
    destructor Destroy;override;
    procedure FrameleriYukle(ABilgiler: TXMLItem);reintroduce;
    function FrameBul(AFrameBasligi : string): TAramaFrameBilgi;reintroduce;overload;
    function FrameBul(AFrameTipi : TFrameClass): TAramaFrameBilgi;reintroduce;overload;
    function FrameBul(AFrameOrnek : TFrame): TAramaFrameBilgi;reintroduce;overload;
    function FrameBulYumurtlanan(AFrameOrnek : TFrame): TAramaFrameBilgi;reintroduce;
    {$REGION 'Özellikler'}
    property AktifFrame : TAramaFrameBilgi read GetAktifFrame;
    property AnaFrameYoneticisi : TAnaFrameYoneticisi read GetAnaFrameYoneticisi;
    property AnaFrameBilgi : TAnaFrameBilgi read FAnaFrameBilgi;
    property IcerikFrameYoneticisi : TIcerikFrameYoneticisi read GetIcerikFrameYoneticisi;
    {$ENDREGION}
  end;

  TAramaFrameBilgi = class(TFrameBilgi)
  private
    FBagListesi : TObjectList;
    FIIAramaFrameBilgi: IAramaBilgiFrame;
    FAnaFrameBilgi: TAnaFrameBilgi;
    function GetIcerikFrameYoneticisi: TIcerikFrameYoneticisi;
  protected
    function GetFrameYoneticisi : TAramaFrameYoneticisi;reintroduce;
  public
    constructor Create(AAramaFrameYoneticisi : TAramaFrameYoneticisi;ASayfaDenetimi: TcxPageControl);reintroduce;
    destructor Destroy;override;
    function Baslat: TAramaFrameBilgi; reintroduce;
    function Git: TAramaFrameBilgi; reintroduce;

    procedure Yukle(ABilgi: TXMLItem); override;
    function BaglariKur(AIcerikFrameOrnek : TFrame): TAramaFrameBilgi;
    function GitAdaGore: TAramaFrameBilgi; reintroduce;
    property AramaFrameYoneticisi : TAramaFrameYoneticisi read GetFrameYoneticisi;
    property IIAramaFrameBilgi : IAramaBilgiFrame read FIIAramaFrameBilgi;
    property AnaFrameBilgi : TAnaFrameBilgi read FAnaFrameBilgi;
    property IcerikFrameYoneticisi : TIcerikFrameYoneticisi read GetIcerikFrameYoneticisi;
  end;

  TTemelBaglayici = class(TObject)
  public
    procedure Bagla(AHedefOrnek : TFrame;AKaynakOrnek: TFrame);virtual;abstract;
  end;

  TFrameOlayBaglamaBilgisi = class(TTemelBaglayici)
  private
    FHedefBilesen: string;
    FHedefOlay: string;
    FKaynakMethod: string;
  public
    procedure Bagla(AHedefOrnek : TFrame;AKaynakOrnek: TFrame);override;
    class function Yukle(ABilgi: TXMLItem): TFrameOlayBaglamaBilgisi;
  end;

  TFramePropertyBaglamaBilgisi = class(TTemelBaglayici)
  private
    FHedefBilesen: string;
    FHedefProperty: string;
    FKaynakBilesen: string;
  public
    procedure Bagla(AHedefOrnek : TFrame;AKaynakOrnek: TFrame);override;
    class function Yukle(ABilgi: TXMLItem): TFramePropertyBaglamaBilgisi;
  end;


implementation
uses
  TypInfo;//,LocOnFly;

var
  GeciciOwner: TComponent;

function FrameIcinAdDegistirici(const Name: string): Boolean;
begin
  Result := GeciciOwner.FindComponent(Name) = nil;
end;

{ TAnaFrameYoneticisi }

function TAnaFrameYoneticisi.AnaSekmeBul: TAnaFrameBilgi;
begin
  Result := TAnaFrameBilgi(inherited AnaSekmeBul);
end;

constructor TAnaFrameYoneticisi.Create(ASayfaDenetimi: TcxPageControl;
  AFrameYapilandirmaDosyasi: string);
begin
  inherited Create(ASayfaDenetimi,AFrameYapilandirmaDosyasi);


end;

destructor TAnaFrameYoneticisi.Destroy;
var
  I: Integer;
  frm : TAnaFrameBilgi;
  kapatilabilir : Boolean;
begin
  for I := 0 to FrameSayisi - 1 do begin
    frm := TAnaFrameBilgi(Frame[i]);
    kapatilabilir := True;
    if Assigned(frm.BilgiFrameIntf) then
      frm.BilgiFrameIntf.Kapatiliyor(kapatilabilir);
  end;
  inherited;
end;

function TAnaFrameYoneticisi.FrameBul(AFrameBasligi: string): TAnaFrameBilgi;
begin
  Result := TAnaFrameBilgi(inherited FrameBul(AFrameBasligi));
end;

function TAnaFrameYoneticisi.FrameBul(AFrameTipi: TFrameClass): TAnaFrameBilgi;
begin
  Result := TAnaFrameBilgi(inherited FrameBul(AFrameTipi));
end;

function TAnaFrameYoneticisi.FrameBul(AFrameOrnek: TFrame): TAnaFrameBilgi;
begin
  Result := TAnaFrameBilgi(inherited FrameBul(AFrameOrnek));
end;

function TAnaFrameYoneticisi.FrameBulYumurtlanan(
  AFrameOrnek: TFrame): TAnaFrameBilgi;
begin
  Result := TAnaFrameBilgi(inherited FrameBulYumurtlanan(AFrameOrnek));
end;

procedure TAnaFrameYoneticisi.FrameleriYukle;
var
  xml: TECXMLParser;
  I: Integer;
  sekmeBilgi : TXMLItem;
  sekmeler   : TXMLItem;
  fb         : TFrameBilgi;
  strStream  : TStringStream;
  canLoad    : Boolean;
begin
  xml := TECXMLParser.Create(nil);
//  xml.DefaultLargeTokenizer := True;
  strStream := TStringStream.Create(FFrameYapilandirmaDosyasi);

  try
    xml.LoadFromStream(strStream,TEncoding.ANSI);
    sekmeler := xml.Root.NamedItem['AnaSekmeler'];
    for I := 0 to sekmeler.Count - 1 do begin
      sekmeBilgi := sekmeler[i];
      canLoad := True;
      if Assigned(OnBeforeFrameLoad) then
        OnBeforeFrameLoad(sekmeBilgi,canLoad);
      if canLoad then begin
        fb := TAnaFrameBilgi.Create(Self,FSayfaDenetimi);
        fb.Yukle(sekmeBilgi);
        FKayitliFrameListesi.Add(fb);
      end;

    end; 
  finally
    xml.Free;
    strStream.Free;
  end;
end;

function TAnaFrameYoneticisi.GetAktifFrame: TAnaFrameBilgi;
begin
  Result := TAnaFrameBilgi(inherited GetAktifFrame);
end;

{ TAnaFrameBilgi }

function TAnaFrameBilgi.Baslat: TAnaFrameBilgi;
begin
  Result := TAnaFrameBilgi(inherited Baslat);
  if not Supports(FOrnek,IAnaBilgiFrame,FIAnaBilgiFrame) then
    FIAnaBilgiFrame := nil
  else
    FIAnaBilgiFrame.FrameBilgi := Self;
end;

constructor TAnaFrameBilgi.Create(AAnaFrameYoneticisi: TAnaFrameYoneticisi;
  ASayfaDenetimi: TcxPageControl);
begin
  inherited Create(AAnaFrameYoneticisi,ASayfaDenetimi);
  FIcerikFrameYoneticisi := nil;
  //FAracCubuguFrameYoneticisi := nil;
  FAramaFrameYoneticisi := nil;
end;

destructor TAnaFrameBilgi.Destroy;
begin
  FIAnaBilgiFrame := nil;
  if Assigned(FAramaFrameYoneticisi) then
    FAramaFrameYoneticisi.Free;
  if Assigned(FIcerikFrameYoneticisi) then
    FIcerikFrameYoneticisi.Free;
  inherited;
end;

function TAnaFrameBilgi.GetAktifArama: TAramaFrameBilgi;
begin
  Result := FAramaFrameYoneticisi.AktifFrame;
end;

function TAnaFrameBilgi.GetAktifIcerik: TIcerikFrameBilgi;
begin
  Result := FIcerikFrameYoneticisi.AktifFrame;
end;

function TAnaFrameBilgi.GetAktifIcerikYazdirmaDestekli: Boolean;
begin
  Result := Assigned(AktifIcerik) and AktifIcerik.YazdirmaDestegi;
end;

function TAnaFrameBilgi.GetFrameYoneticisi: TAnaFrameYoneticisi;
begin
  Result := TAnaFrameYoneticisi(inherited GetFrameYoneticisi);
end;

function TAnaFrameBilgi.Git: TAnaFrameBilgi;
begin
  Result := Self;
  if FYumurtlandi then
    FSayfaDenetimi.ActivePage := FSekmeSayfasi
  else begin
    if not FBaslatildi then
      Baslat;
    FFrameYoneticisi.TipeGoreAktifEt(FOrnekClass);
  end;
end;

function TAnaFrameBilgi.GitAdaGore: TAnaFrameBilgi;
begin
  Result := Self;
  if FYumurtlandi then
    FSayfaDenetimi.ActivePage := FSekmeSayfasi
  else begin
    if not FBaslatildi then
      Baslat;
    FFrameYoneticisi.AdaGoreAktifEt(FBaslik);
  end;
end;

procedure TAnaFrameBilgi.IcerikFrameAktifOlacak(Sender: TObject);
var
  ifb : TIcerikFrameBilgi;
  afb : TAramaFrameBilgi;
  ekranAdi : string;
  hicGorunmesin : Boolean;
begin
  ifb := Sender as TIcerikFrameBilgi;
  if ifb.AramaFrameTipi <> '' then begin
    afb := FAramaFrameYoneticisi.FrameBul(TFrameClass(GetClass(ifb.AramaFrameTipi)));
    if afb.Baslatildi then afb.Git;
  end;
  { Gezinme paneli yönetimi }
  if Assigned(FGezinmePaneli) then begin
    if Assigned(ifb.AracCubuguDestegi) then begin
      hicGorunmesin := True;
      if Assigned(FNavigator) then begin
        if ifb.AracCubuguDestegi.GezinmeAktifMi then begin
          ifb.AracCubuguDestegi.GezinmeBagla(FNavigator);
          FNavigator.Tag := 0;
          hicGorunmesin := False;
        end else begin
          FNavigator.Visible := False;
          FNavigator.Tag := 100; // pencere açılırsa bile görünmesin
        end;
      end;
      if Assigned(FEkranYaz) then begin
        if ifb.AracCubuguDestegi.YazdirmaAktifMi then begin
          FEkranYaz.Tag := 0;
          hicGorunmesin := False;
          FEkranYaz.Caption := ekranAdi;
          if Assigned(FYaziciYaz) then begin
            FYaziciYaz.Caption := ekranAdi;
            FYaziciYaz.Tag := 0;
          end;
        end else begin
          if Assigned(FYaziciYaz) then
            FEkranYaz.Tag := 100;
            FYaziciYaz.Tag := 100;
        end;
      end;
      FGezinmePaneli.Visible := not hicGorunmesin;
      { burada yazdırma ile ilgili kısımlar gerçekleşecek }
    end else FGezinmePaneli.Visible := False;
  end;
  FIAnaBilgiFrame.IcerikFrameAktifOlacak(ifb); 
end;

procedure TAnaFrameBilgi.IcerikFrameHenuzBaslatildi(Sender: TObject);
var
  ifb : TIcerikFrameBilgi;
  afb : TAramaFrameBilgi;
begin
  ifb := Sender as TIcerikFrameBilgi;
  if ifb.AramaFrameTipi <> '' then begin
    afb := FAramaFrameYoneticisi.FrameBul(TFrameClass(GetClass(ifb.AramaFrameTipi)));
    if not afb.Baslatildi then begin
      afb.Git.BaglariKur(ifb.Ornek);
      if ifb.AramaPropertyAdi <> '' then begin
        SetObjectProp(ifb.Ornek,ifb.AramaPropertyAdi,afb.Ornek);
      end;
    end;
  end;
end;

function TAnaFrameBilgi.IcerikGit(ABaslik: string): TIcerikFrameBilgi;
begin
  if ABaslik <> '' then
     Result := IcerikFrameYoneticisi.FrameBul(ABaslik).Git;
end;

function TAnaFrameBilgi.IcerikGit(AFrameClass: TFrameClass): TIcerikFrameBilgi;
begin
 Result := IcerikFrameYoneticisi.FrameBul(AFrameClass).Git;
end;

procedure TAnaFrameBilgi.SetAktifArama(const Value: TAramaFrameBilgi);
begin
  Value.Git;
end;

procedure TAnaFrameBilgi.SetAktifIcerik(const Value: TIcerikFrameBilgi);
begin
  Value.Git;
end;

procedure TAnaFrameBilgi.Yukle(ABilgi: TXMLItem);
var
  ctrl : TComponent;
  oldProc : TIsUniqueGlobalComponentName;
begin
  inherited;
  FAramaSayfaDenetimAdi := ABilgi.Params.Values['AramaSayfaDenetimi'];
  FIcerikSayfaDenetimAdi := ABilgi.Params.Values['IcerikSayfaDenetimi'];
  FGorevlerPanelAdi := ABilgi.Params.Values['GorevlerPaneli'];
  FGorevFrameTipi := ABilgi.Params.Values['GorevFrameTipi'];
  FGirisSayfasiTipi := ABilgi.Params.Values['GirisSayfasiTipi'];
  FGorevPanelBoyu := ABilgi.Params.Values['GorevPanelBoyu'];
  FGorevFrameFrameBilgiProperty := ABilgi.Params.Values['GorevFrameFrameBilgiProperty'];
  FYaziciYazAdi := ABilgi.Params.Values['YaziciYazAdi'];
  FEkranYazAdi := ABilgi.Params.Values['EkranYazAdi'];
  FNavigatorAdi := ABilgi.Params.Values['NavigatorAdi'];
  FGezinmePaneliAdi := ABilgi.Params.Values['GezinmePaneliAdi'];
  FFrameYonetilebilir := ABilgi.Params.Values['FrameYonetilebilir'] <> 'hayir';
  if FFrameYonetilebilir then begin
    { İçerik,Arama ve Araç çubuğu yöneticileri için ana sekmenin başlatılmış olması gerekiyor }
    { Baslatilmamışsa başlat }
    if not Baslatildi then
      Baslat;
    { Arama Frame Yöneticisini Başlatma }
    ctrl := FOrnek.FindComponent(FAramaSayfaDenetimAdi);
    if not Assigned(ctrl) then
      raise Exception.Create('Denetim bulunamadı -> ' + FAramaSayfaDenetimAdi);
    FAramaSayfaDenetimi := TcxPageControl(ctrl);
    FAramaFrameYoneticisi := TAramaFrameYoneticisi.
      Create(Self,FAramaSayfaDenetimi,ABilgi.NamedItem['AramaSekmeleri']);
    { İçerik Frame Yöneticisini Başlatma }
    ctrl := FOrnek.FindComponent(FIcerikSayfaDenetimAdi);
    if not Assigned(ctrl) then
      raise Exception.Create('Denetim bulunamadı -> ' + FIcerikSayfaDenetimAdi);
    FIcerikSayfaDenetimi := TcxPageControl(ctrl);
    FIcerikFrameYoneticisi := TIcerikFrameYoneticisi.
      Create(Self,FIcerikSayfaDenetimi,ABilgi.NamedItem['IcerikSekmeleri']);
    FIcerikFrameYoneticisi.OnFrameHenuzBaslatildi.Add(IcerikFrameHenuzBaslatildi);
    FIcerikFrameYoneticisi.OnFrameAktifOlacak.Add(IcerikFrameAktifOlacak);    
    { Gezinme ve Yazdırma }
    if FEkranYazAdi <> '' then
      FEkranYaz := TcxButton(FOrnek.FindComponent(FEkranYazAdi));
    if FYaziciYazAdi <> '' then
      FYaziciYaz := TcxButton(FOrnek.FindComponent(FYaziciYazAdi));
    if FNavigatorAdi <> '' then
      FNavigator := TDBNavigator(FOrnek.FindComponent(FNavigatorAdi));
    if FGezinmePaneliAdi <> '' then
      FGezinmePaneli := TWinControl(FOrnek.FindComponent(FGezinmePaneliAdi));
    { Görev Frame'i yükleme }
    if (FGorevlerPanelAdi <> '') and (FGorevFrameTipi <> '') then begin
      ctrl := FOrnek.FindComponent(FGorevlerPanelAdi);
      if not Assigned(ctrl) then
        raise Exception.Create('Görev paneli denetimi bulunamadı -> ' + FGorevlerPanelAdi);
      if FGorevPanelBoyu <> '' then begin
        TWinControl(ctrl).Height := StrToIntDef(FGorevPanelBoyu, 145);
      end;
      FGorevFrameOrnek := TFrame(GetClass(FGorevFrameTipi).NewInstance);
      { Ad ile ilgili istisnayı engellemek için }
      GeciciOwner := FSekmeSayfasi.Owner;
      IsUniqueGlobalComponentNameProc := @FrameIcinAdDegistirici;
      FGorevFrameOrnek.Create(FOrnek);
      IsUniqueGlobalComponentNameProc := nil;
      FGorevFrameOrnek.Parent := TWinControl(ctrl);
      {* FrameBilgi property set etme }
      SetObjectProp(FGorevFrameOrnek,IIf(FGorevFrameFrameBilgiProperty = '','FrameBilgi',FGorevFrameFrameBilgiProperty),Self);
      GeciciOwner := nil;
    end;
    if FGirisSayfasiTipi <> '' then
      FIcerikFrameYoneticisi.FrameBul(TFrameClass(GetClass(FGirisSayfasiTipi))).Git;
  end
    else
  Baslat;
end;

{ TIcerikFrameBilgi }

function TIcerikFrameBilgi.Baslat: TIcerikFrameBilgi;
begin
  Result := TIcerikFrameBilgi(inherited Baslat);
end;

constructor TIcerikFrameBilgi.Create(
  AIcerikFrameYoneticisi: TIcerikFrameYoneticisi;
  ASayfaDenetimi: TcxPageControl);
begin
  inherited Create(AIcerikFrameYoneticisi,ASayfaDenetimi);
  FAnaFrameBilgi := AIcerikFrameYoneticisi.AnaFrameBilgi;
end;

destructor TIcerikFrameBilgi.Destroy;
begin
  FIIIcerikFrameBilgi := nil;
  FAracCubuguDestegi := nil;
  inherited;
end;

procedure TIcerikFrameBilgi.FrameOrnekBaslatildi;
begin
  inherited;
  if not Supports(FOrnek, IAracCubuguDestegi,FAracCubuguDestegi) then
    FAracCubuguDestegi := nil;
  if not Supports(FOrnek,IIcerikBilgiFrame,FIIIcerikFrameBilgi) then
    FIIIcerikFrameBilgi := nil
  else
    FIIIcerikFrameBilgi.FrameBilgi := Self; 
end;

function TIcerikFrameBilgi.GetAramaFrameYoneticisi: TAramaFrameYoneticisi;
begin
  Result := FAnaFrameBilgi.AramaFrameYoneticisi;
end;

function TIcerikFrameBilgi.GetFrameYoneticisi: TIcerikFrameYoneticisi;
begin
  Result := TIcerikFrameYoneticisi(inherited GetFrameYoneticisi);
end;

function TIcerikFrameBilgi.GetYazdirmaDestegi: Boolean;
begin
  Result := Assigned(FAracCubuguDestegi) and FAracCubuguDestegi.YazdirmaAktifMi;
end;

function TIcerikFrameBilgi.Git: TIcerikFrameBilgi;
begin  
  Result := Self;
  if FYumurtlandi then
    FSayfaDenetimi.ActivePage := FSekmeSayfasi
  else begin
    if not FBaslatildi then
      Baslat;
    FFrameYoneticisi.AdaGoreAktifEt(FBaslik);
    LogEvent('%s - İçerik Frame Git:%s; Class:%s',[FAnaFrameBilgi.FBaslik, FBaslik,FOrnekClass.ClassName]);
  end;
end;

function TIcerikFrameBilgi.GitAdaGore: TIcerikFrameBilgi;
begin
  Result := Self.Git;
end;

function TIcerikFrameBilgi.IcerikGit(
  AFrameClass: TFrameClass): TIcerikFrameBilgi;
begin
  Result := IcerikFrameYoneticisi.FrameBul(AFrameClass).Git; 
end;


procedure TIcerikFrameBilgi.Yukle(ABilgi: TXMLItem);
begin
  inherited;
  FAramaFrameTipi := ABilgi.Params.Values['AramaTipi'];
  //FAracCubuguFrameTipi := ABilgi.Params.Values['AracCubuguTipi'];
  FAramaPropertyAdi := ABilgi.Params.Values['AramaPropertyAdi'];
  //FAracCubuguPropertyAdi := ABilgi.Params.Values['AracCubuguPropertyAdi'];
end;

{ TIcerikFrameYoneticisi }

function TIcerikFrameYoneticisi.AnaSekmeBul: TIcerikFrameBilgi;
begin
  Result := TIcerikFrameBilgi(inherited AnaSekmeBul);
end;

constructor TIcerikFrameYoneticisi.Create(AAnaFrameBilgi: TAnaFrameBilgi;
  ASayfaDenetimi: TcxPageControl; AIcerikSekmeleri: TXMLItem);
begin
  inherited Create(ASayfaDenetimi,'');
  FAnaFrameBilgi := AAnaFrameBilgi;
  FrameleriYukle(AIcerikSekmeleri);
end;

destructor TIcerikFrameYoneticisi.Destroy;
var
  I: Integer;
  frm : TIcerikFrameBilgi;
  kapatilabilir : Boolean;
begin
  for I := 0 to FrameSayisi - 1 do begin
    frm := TIcerikFrameBilgi(Frame[i]);
    kapatilabilir := True;
    if Assigned(frm.BilgiFrameIntf) then
      frm.BilgiFrameIntf.Kapatiliyor(kapatilabilir);
  end;
  inherited;
end;

function TIcerikFrameYoneticisi.FrameBul(
  AFrameTipi: TFrameClass): TIcerikFrameBilgi;
begin
  Result := TIcerikFrameBilgi(inherited FrameBul(AFrameTipi));
end;

function TIcerikFrameYoneticisi.FrameBul(
  AFrameBasligi: string): TIcerikFrameBilgi;
begin
  Result := TIcerikFrameBilgi(inherited FrameBul(AFrameBasligi));
end;

function TIcerikFrameYoneticisi.FrameBul(
  AFrameOrnek: TFrame): TIcerikFrameBilgi;
begin
  Result := TIcerikFrameBilgi(inherited FrameBul(AFrameOrnek));
end;

function TIcerikFrameYoneticisi.FrameBulYumurtlanan(
  AFrameOrnek: TFrame): TIcerikFrameBilgi;
begin
  Result := TIcerikFrameBilgi(inherited FrameBulYumurtlanan(AFrameOrnek));
end;

procedure TIcerikFrameYoneticisi.FrameleriYukle(ABilgiler: TXMLItem);
var
  I: Integer;
  sekmeBilgi : TXMLItem;
  fb         : TIcerikFrameBilgi;
begin
  for I := 0 to ABilgiler.Count - 1 do begin
    sekmeBilgi := ABilgiler[i];
    fb := TIcerikFrameBilgi.Create(Self, FSayfaDenetimi);
       fb.Yukle(sekmeBilgi);
    FKayitliFrameListesi.Add(fb);
  end;
end;

function TIcerikFrameYoneticisi.GetAktifFrame: TIcerikFrameBilgi;
begin
  Result := TIcerikFrameBilgi(inherited GetAktifFrame);
end;

function TIcerikFrameYoneticisi.GetAnaFrameYoneticisi: TAnaFrameYoneticisi;
begin
  Result := FAnaFrameBilgi.AnaFrameYoneticisi;
end;

function TIcerikFrameYoneticisi.GetAramaFrameYoneticisi: TAramaFrameYoneticisi;
begin
  Result := FAnaFrameBilgi.AramaFrameYoneticisi;
end;

{ TAramaFrameYoneticisi }

function TAramaFrameYoneticisi.AnaSekmeBul: TAramaFrameBilgi;
begin
  Result := TAramaFrameBilgi(inherited AnaSekmeBul);
end;

constructor TAramaFrameYoneticisi.Create(AAnaFrameBilgi: TAnaFrameBilgi;
  ASayfaDenetimi: TcxPageControl; AAramaSekmeleri: TXMLItem);
begin
  inherited Create(ASayfaDenetimi,'');
  FAnaFrameBilgi := AAnaFrameBilgi;
  FrameleriYukle(AAramaSekmeleri);
end;

destructor TAramaFrameYoneticisi.Destroy;
begin

  inherited;
end;

function TAramaFrameYoneticisi.FrameBul(
  AFrameBasligi: string): TAramaFrameBilgi;
begin
  Result := TAramaFrameBilgi(inherited FrameBul(AFrameBasligi));
end;

function TAramaFrameYoneticisi.FrameBul(
  AFrameTipi: TFrameClass): TAramaFrameBilgi;
begin
  Result := TAramaFrameBilgi(inherited FrameBul(AFrameTipi));
end;

function TAramaFrameYoneticisi.FrameBul(AFrameOrnek: TFrame): TAramaFrameBilgi;
begin
  Result := TAramaFrameBilgi(inherited FrameBul(AFrameOrnek));
end;

function TAramaFrameYoneticisi.FrameBulYumurtlanan(
  AFrameOrnek: TFrame): TAramaFrameBilgi;
begin
  Result := TAramaFrameBilgi(inherited FrameBulYumurtlanan(AFrameOrnek));
end;

procedure TAramaFrameYoneticisi.FrameleriYukle(ABilgiler: TXMLItem);
var
  I: Integer;
  sekmeBilgi : TXMLItem;
  fb         : TAramaFrameBilgi;
begin
  for I := 0 to ABilgiler.Count - 1 do begin
    sekmeBilgi := ABilgiler[i];
    fb := TAramaFrameBilgi.Create(Self, FSayfaDenetimi);
    fb.Yukle(sekmeBilgi);
    FKayitliFrameListesi.Add(fb);
  end;
end;

function TAramaFrameYoneticisi.GetAktifFrame: TAramaFrameBilgi;
begin
  Result := TAramaFrameBilgi(inherited GetAktifFrame);
end;

function TAramaFrameYoneticisi.GetAnaFrameYoneticisi: TAnaFrameYoneticisi;
begin
  Result := FAnaFrameBilgi.AnaFrameYoneticisi;
end;

function TAramaFrameYoneticisi.GetIcerikFrameYoneticisi: TIcerikFrameYoneticisi;
begin
  Result := FAnaFrameBilgi.IcerikFrameYoneticisi;
end;

{ TAramaFrameBilgi }

function TAramaFrameBilgi.Baslat: TAramaFrameBilgi;
begin
  Result := TAramaFrameBilgi(inherited Baslat);
  if not Supports(FOrnek,IAramaBilgiFrame,FIIAramaFrameBilgi) then
    FIIAramaFrameBilgi := nil
  else
    FIIAramaFrameBilgi.FrameBilgi := Self;
end;

constructor TAramaFrameBilgi.Create(
  AAramaFrameYoneticisi: TAramaFrameYoneticisi; ASayfaDenetimi: TcxPageControl);
begin
  inherited Create(AAramaFrameYoneticisi,ASayfaDenetimi);
  FBagListesi := TObjectList.Create;
  FAnaFrameBilgi := AAramaFrameYoneticisi.AnaFrameBilgi;
end;

destructor TAramaFrameBilgi.Destroy;
begin
  FIIAramaFrameBilgi := nil;
  FBagListesi.Free;
  inherited;
end;

function TAramaFrameBilgi.GetFrameYoneticisi: TAramaFrameYoneticisi;
begin
  Result := TAramaFrameYoneticisi(inherited GetFrameYoneticisi);
end;

function TAramaFrameBilgi.GetIcerikFrameYoneticisi: TIcerikFrameYoneticisi;
begin
  Result := FAnaFrameBilgi.IcerikFrameYoneticisi;
end;

function TAramaFrameBilgi.Git: TAramaFrameBilgi;
begin
  Result := Self;
  if FYumurtlandi then
    FSayfaDenetimi.ActivePage := FSekmeSayfasi
  else begin
    if not FBaslatildi then
      Baslat;
    FFrameYoneticisi.TipeGoreAktifEt(FOrnekClass);
  end;
end;

function TAramaFrameBilgi.GitAdaGore: TAramaFrameBilgi;
begin
  Result := Self;
  if FYumurtlandi then
    FSayfaDenetimi.ActivePage := FSekmeSayfasi
  else begin
    if not FBaslatildi then
      Baslat;
    FFrameYoneticisi.AdaGoreAktifEt(FBaslik);
  end;
end;

function TAramaFrameBilgi.BaglariKur(
  AIcerikFrameOrnek: TFrame): TAramaFrameBilgi;
var
  i : Integer;
  bag : TTemelBaglayici;
begin
  for I := 0 to FBagListesi.Count - 1 do begin
    TTemelBaglayici( FBagListesi[i] ).Bagla(FOrnek,AIcerikFrameOrnek);
  end;
end;

procedure TAramaFrameBilgi.Yukle(ABilgi: TXMLItem);
var
  bag : TXMLItem;
  baglar : TXMLItem;
  i   : Integer;
begin
  inherited;
  baglar := ABilgi.NamedItem['OlayBaglamalar'];
  if baglar.Count > 0 then begin
    for I := 0 to baglar.Count - 1 do begin
      bag := baglar[i];
      FBagListesi.Add(TFrameOlayBaglamaBilgisi.Yukle(bag));
    end;
  end;
  baglar := ABilgi.NamedItem['PropertyBaglamalari'];
  if baglar.Count > 0 then begin
    for I := 0 to baglar.Count - 1 do begin
      bag := baglar[i];
      FBagListesi.Add(TFramePropertyBaglamaBilgisi.Yukle(bag));
    end;
  end;
end;

//{ TAracCubuguFrameBilgi }
//
//function TAracCubuguFrameBilgi.Baslat: TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited Baslat);
//end;
//
//constructor TAracCubuguFrameBilgi.Create(
//  AAracCubuguFrameYoneticisi: TAracCubuguFrameYoneticisi;
//  ASayfaDenetimi: TcxPageControl);
//begin
//  inherited Create(AAracCubuguFrameYoneticisi,ASayfaDenetimi);
//
//end;
//
//destructor TAracCubuguFrameBilgi.Destroy;
//begin
//
//  inherited;
//end;
//
//function TAracCubuguFrameBilgi.GetFrameYoneticisi: TAracCubuguFrameYoneticisi;
//begin
//  Result := TAracCubuguFrameYoneticisi(FFrameYoneticisi);
//end;
//
//function TAracCubuguFrameBilgi.Git: TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited Git);
//end;
//
//procedure TAracCubuguFrameBilgi.Yukle(ABilgi: TXMLItem);
//begin
//  inherited;
//end;

//{ TAracCubuguFrameYoneticisi }
//
//function TAracCubuguFrameYoneticisi.AnaSekmeBul: TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited AnaSekmeBul);
//end;
//
//constructor TAracCubuguFrameYoneticisi.Create(AAnaFrameBilgi: TAnaFrameBilgi;
//  ASayfaDenetimi: TcxPageControl; AAracCubuguSekmeleri: TXMLItem);
//begin
//  inherited Create(ASayfaDenetimi,'');
//  FAnaFrameBilgi := AAnaFrameBilgi;
//  FrameleriYukle(AAracCubuguSekmeleri);
//end;
//
//destructor TAracCubuguFrameYoneticisi.Destroy;
//begin
//
//  inherited;
//end;
//
//function TAracCubuguFrameYoneticisi.FrameBul(
//  AFrameBasligi: string): TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited FrameBul(AFrameBasligi));
//end;
//
//function TAracCubuguFrameYoneticisi.FrameBul(
//  AFrameOrnek: TFrame): TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited FrameBul(AFrameOrnek));
//end;
//
//function TAracCubuguFrameYoneticisi.FrameBul(
//  AFrameTipi: TFrameClass): TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited FrameBul(AFrameTipi));
//end;
//
//function TAracCubuguFrameYoneticisi.FrameBulYumurtlanan(
//  AFrameOrnek: TFrame): TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited FrameBulYumurtlanan(AFrameOrnek));
//end;
//
//procedure TAracCubuguFrameYoneticisi.FrameleriYukle(ABilgiler: TXMLItem);
//var
//  I: Integer;
//  sekmeBilgi : TXMLItem;
//  fb         : TAracCubuguFrameBilgi;
//begin
//  for I := 0 to ABilgiler.Count - 1 do begin
//    sekmeBilgi := ABilgiler[i];
//    fb := TAracCubuguFrameBilgi.Create(Self, FSayfaDenetimi);
//    fb.Yukle(sekmeBilgi);
//    FKayitliFrameListesi.Add(fb);
//  end;
//end;
//
//function TAracCubuguFrameYoneticisi.GetAktifFrame: TAracCubuguFrameBilgi;
//begin
//  Result := TAracCubuguFrameBilgi(inherited GetAktifFrame);
//end;
//
//function TAracCubuguFrameYoneticisi.GetAnaFrameYoneticisi: TAnaFrameYoneticisi;
//begin
//  Result := FAnaFrameBilgi.AnaFrameYoneticisi;
//end;
//
//function TAracCubuguFrameYoneticisi.GetIcerikFrameYoneticisi: TIcerikFrameYoneticisi;
//begin
//  Result := FAnaFrameBilgi.IcerikFrameYoneticisi;
//end;

{ TFrameOlayBaglamaBilgisi }

procedure TFrameOlayBaglamaBilgisi.Bagla(AHedefOrnek, AKaynakOrnek: TFrame);

  procedure YontemAta(AOrnek : TComponent;ABilesenAdi: string;AOlay: string;AAtanacak : TMethod);
  var
    p : TComponent;
    c : string;
  begin
    if Pos('.',ABilesenAdi) > 0 then begin
      c := Dize.SinirlandirilmisMetinEx(ABilesenAdi,'.');
      p := TComponent(GetObjectProp(AOrnek, c));
      if not Assigned(p) then
        raise Exception.Create('Bileşen nil -> ' + c);
      YontemAta(p,ABilesenAdi,AOlay,AAtanacak);
    end else begin
      if ABilesenAdi <> '' then begin
        p := TComponent(GetObjectProp(AOrnek, ABilesenAdi));
        if not Assigned(p) then
          raise Exception.Create('Bileşen nil -> ' + ABilesenAdi);
        SetMethodProp(p,AOlay,AAtanacak);
      end else
        if AOrnek <> nil then
           SetMethodProp(AOrnek,AOlay,AAtanacak);
    end;
  end;  
var
  ba   : string;
  hcba : string;
  mt   : TMethod;
  hc   : TComponent;
begin
  mt.Code := AKaynakOrnek.MethodAddress(FKaynakMethod);
  if not Assigned(mt.Code) then
    raise Exception.Create('Kaynak örnekte bu yöntem bulunamıyor -> ' + FKaynakMethod);
  mt.Data := AKaynakOrnek;
  ba := FHedefBilesen;
  hcba := Dize.SinirlandirilmisMetinEx(ba,'.');
  hc := AHedefOrnek.FindComponent(hcba);
  YontemAta(hc,ba,FHedefOlay,mt);
end;

class function TFrameOlayBaglamaBilgisi.Yukle(ABilgi: TXMLItem): TFrameOlayBaglamaBilgisi;
begin
  Result := TFrameOlayBaglamaBilgisi.Create;
  Result.FHedefBilesen := ABilgi.Params.Values['hedefBilesen'];
  Result.FHedefOlay := ABilgi.Params.Values['hedefOlay'];
  Result.FKaynakMethod := ABilgi.Params.Values['kaynakMethod'];
end;

{ TFramePropertyBaglamaBilgisi }

procedure TFramePropertyBaglamaBilgisi.Bagla(AHedefOrnek, AKaynakOrnek: TFrame);

  procedure ObjectPropertyAta(AOrnek : TComponent;ABilesenAdi: string;
    AHedefProperty: string;AKaynakBilesen : TComponent);
  var
    p : TComponent;
    c : string;
  begin
    if Pos('.',ABilesenAdi) > 0 then begin
      c := Dize.SinirlandirilmisMetinEx(ABilesenAdi,'.');
      p := TComponent(GetObjectProp(AOrnek, c));
      if not Assigned(p) then
        raise Exception.Create('Bileşen bulunamadı -> ' + c);
      ObjectPropertyAta(p,ABilesenAdi,AHedefProperty,AKaynakBilesen);
    end else begin
      if ABilesenAdi <> '' then begin
        p := TComponent(GetObjectProp(AOrnek, ABilesenAdi));
        if not Assigned(p) then
          raise Exception.Create('Bileşen nil -> ' + ABilesenAdi);
        SetObjectProp(p,AHedefProperty,AKaynakBilesen);
      end else
      SetObjectProp(AOrnek,AHedefProperty,AKaynakBilesen);
    end;
  end;
  
var
  ba : string;
  hcba : string;
  hc : TComponent;
  kc : TComponent;
begin
  ba := FHedefBilesen;
  hcba := Dize.SinirlandirilmisMetinEx(ba,'.');
  hc := AHedefOrnek.FindComponent(hcba);
  kc := AKaynakOrnek.FindComponent(FKaynakBilesen);
  ObjectPropertyAta(hc,ba,FHedefProperty,kc);
end;

class function TFramePropertyBaglamaBilgisi.Yukle(
  ABilgi: TXMLItem): TFramePropertyBaglamaBilgisi;
begin
  Result := TFramePropertyBaglamaBilgisi.Create;
  Result.FHedefBilesen := ABilgi.Params.Values['hedefBilesen'];
  Result.FHedefProperty := ABilgi.Params.Values['hedefProperty'];
  Result.FKaynakBilesen := ABilgi.Params.Values['kaynakBilesen'];
end;

end.

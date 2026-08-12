unit UFrameYoneticisi;

interface
uses ECXMLParser, Classes, Controls, Forms, Contnrs, cxPC, Dialogs,
  FetaKurulusSiniflari,JvPanel, JvPageList, JvNavigationPane,
  Graphics, JvTransparentButton, SysUtils,Windows,Messages,
  FetaClassExtensions, UMultiCastEvent;

type

  TFrameYoneticisi = class;

  TFrameBilgi = class;

  IBilgiFrame = interface(IInterface)
    ['{A464FC23-BA58-4A00-B0BA-89A35E95C3E8}']
    function GetKapatilabilir : Boolean;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    procedure Baslatildi;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    property Kapatilabilir : Boolean read GetKapatilabilir;
  end;

  TFrameYoneticisi = class
  private
    FOnMesaj: TMulticastNotifyVariant;
    FOnFrameDegisti: TMultiCastNotify;
    FOnFrameBaslikDegisti: TMultiCastNotify;
    FOnFrameAktifOlacak: TMultiCastNotify;
    FOnFrameHenuzBaslatildi: TMultiCastNotify;
    function GetFrameSayisi: Integer;
    function GetFrame(index: Integer): TFrameBilgi;
  protected
    FFramelerYuklendi: Boolean;
    FSayfaDenetimi : TcxPageControl;
    FFrameYapilandirmaDosyasi : String;
    FKayitliFrameListesi : TObjectList;
    FYumurtlananFrameListesi : TObjectList;
    FAyricaBaslatilacaklar : TStringList;
    function GetAktifFrame: TFrameBilgi;virtual;
    function AnaSekmeBul : TFrameBilgi;virtual;
    procedure FrameAktifOldu(AFrameBilgi: TFrameBilgi);
    procedure FrameAktifOlacak(AFrameBilgi: TFrameBilgi);
    procedure FrameBaslikDegisti(AFrameBilgi : TFrameBilgi);
    procedure FrameHenuzBaslatildi(AFrameBilgi: TFrameBilgi);
  public
    constructor Create(ASayfaDenetimi: TcxPageControl;
      AFrameYapilandirmaDosyasi : String);virtual;
    destructor Destroy;override;
    procedure FrameleriYukle;virtual;
    function FrameBul(AFrameBasligi : string): TFrameBilgi;overload;virtual;
    function FrameBul(AFrameTipi : TFrameClass): TFrameBilgi;overload;virtual;
    function FrameBul(AFrameOrnek : TFrame): TFrameBilgi;overload;virtual;
    function FrameBulYumurtlanan(AFrameOrnek : TFrame): TFrameBilgi;virtual;
    procedure AdaGoreAktifEt(AAdi : string);
    procedure TipeGoreAktifEt(AFrameTipi : TFrameClass);
    function KapatilabilirlerKapanabilirMi : Boolean;
    procedure KapatilabilirleriKapat;
    property FramelerYuklendi : Boolean read FFramelerYuklendi;
    procedure AnaSekmeyeGit;
    function Yumurtla(AFrameTipi: TFrameClass): TFrameBilgi;
    procedure MesajYayinla(AMesaj: string);
    property OnMesaj : TMulticastNotifyVariant read FOnMesaj;
    property OnFrameDegisti : TMultiCastNotify read FOnFrameDegisti;
    property OnFrameAktifOlacak : TMultiCastNotify read FOnFrameAktifOlacak;
    property OnFrameBaslikDegisti : TMultiCastNotify read FOnFrameBaslikDegisti;
    property OnFrameHenuzBaslatildi: TMultiCastNotify read FOnFrameHenuzBaslatildi;
    property AktifFrame : TFrameBilgi read GetAktifFrame;
    property Frame[index: Integer] : TFrameBilgi read GetFrame;
    property FrameSayisi : Integer read GetFrameSayisi;
  end;


  TFrameBilgi = class
  private
    procedure OnFrameShow(Sender: TObject);
    procedure OnFrameHide(Sender: TObject);
    procedure SetBaslik(const Value: String);
    procedure SetSekmeMetinRengi(const Value: TColor);
    procedure SetSekmeRengi(const Value: TColor);
    function GetAktifFrameMi: Boolean;
    procedure SetImageIndex(const Value: Integer);
  protected
    FOrnek : TFrame;
    FOrnekClass : TFrameClass;
    FSekmeSayfasi : TcxTabSheet;
    FSayfaDenetimi : TcxPageControl;
    FFrameYoneticisi : TFrameYoneticisi;
    FIBilgi : IBilgiFrame;
    FBaslatildi : Boolean;
    FBaslik: String;
    FGecikmeli: Boolean;
    FEtiket: Integer;
    FEtiketler : TStringList;
    FKapatilabilir: Boolean;
    FAnaSekme: Boolean;
    FYumurtlandi: Boolean;
    FSekmeMetinRengi: TColor;
    FSekmeRengi: TColor;
    FAyricaGoster: string;
    FOnFrameBaslatildi: TMultiCastNotify;
    FImageIndex: Integer;
    function Yumurtla: TFrameBilgi;
    function GetFrameYoneticisi : TFrameYoneticisi;virtual;
    procedure FrameOrnekBaslatildi;virtual;
  public
    constructor Create(AFrameYoneticisi : TFrameYoneticisi;ASayfaDenetimi: TcxPageControl);virtual;
    destructor Destroy;override;
    function Baslat : TFrameBilgi;virtual;
    procedure Kapat;
    procedure Yukle(ABilgi: TXMLItem);virtual;
    function Git : TFrameBilgi;virtual;
    function GitAdaGore : TFrameBilgi;virtual;
    property BilgiFrameIntf: IBilgiFrame read FIBilgi;
    property Ornek : TFrame read FOrnek;
    property Baslatildi : Boolean read FBaslatildi;
    property Baslik : String read FBaslik write SetBaslik;
    property Gecikmeli : Boolean read FGecikmeli;
    property Etiket : Integer read FEtiket write FEtiket;
    property Etiketler : TStringList read FEtiketler;
    property Kapatilabilir : Boolean read FKapatilabilir;
    property AnaSekme : Boolean read FAnaSekme write FAnaSekme;
    property Yumurtlandi : Boolean read FYumurtlandi;
    property SekmeSayfasi : TcxTabSheet read FSekmeSayfasi;
    property SekmeRengi : TColor read FSekmeRengi write SetSekmeRengi;
    property SekmeMetinRengi : TColor read FSekmeMetinRengi write SetSekmeMetinRengi;
    property AyricaGoster : string read FAyricaGoster write FAyricaGoster;
    property AktifFrameMi : Boolean read GetAktifFrameMi;
    property OnFrameBaslatildi : TMultiCastNotify read FOnFrameBaslatildi;
    property ImageIndex : Integer read FImageIndex write SetImageIndex;
  end;

var
  // Uygulama temasi gibi frame yaratildiktan sonra calisacak merkezi kanca.
  // UFrameYoneticisi uygulama katmanina baglanmaz; atamayi ana form yapar.
  FrameSkinUygulayici: TNotifyEvent;

implementation
uses
  TypInfo;//,LocOnFly;
type
  TNavPnl = class(TJvNavPanelPage);

procedure TFrameYoneticisi.AdaGoreAktifEt(AAdi: string);
var
  fb: Pointer;
begin
  for fb in FKayitliFrameListesi do
  begin
    if TFrameBilgi(fb).Baslatildi and (TFrameBilgi(fb).Baslik = AAdi) then begin
      FSayfaDenetimi.ActivePage := TFrameBilgi(fb).FSekmeSayfasi;
      Exit;
    end;
  end;
end;

function TFrameYoneticisi.AnaSekmeBul: TFrameBilgi;
var
  fb: Pointer;
begin
  Result := nil;
  for fb in FKayitliFrameListesi do begin
    with TFrameBilgi(fb) do begin
      if FBaslatildi and AnaSekme then begin
        Result := fb;
        Exit;
      end;
    end;
  end;
end;

procedure TFrameYoneticisi.AnaSekmeyeGit;
var
  AnaSekme : TFrameBilgi;
begin
  AnaSekme := AnaSekmeBul;
  if Assigned(AnaSekme) then
    AnaSekme.Git
  else
    MessageDlg('Sekme yapılandırma dosyası hatalar içeriyor!. '+
      'Sekmeler arasında hiç Ana sekme bulunmuyor!',mtError,[mbOK],0);
end;


constructor TFrameYoneticisi.Create(ASayfaDenetimi: TcxPageControl;
  AFrameYapilandirmaDosyasi : String);
begin
  FKayitliFrameListesi := TObjectList.Create;
  FYumurtlananFrameListesi := TObjectList.Create;
  FFrameYapilandirmaDosyasi := AFrameYapilandirmaDosyasi;
  FSayfaDenetimi := ASayfaDenetimi;
  FFramelerYuklendi := False;
  FAyricaBaslatilacaklar := TStringList.Create;
  FOnMesaj := TMulticastNotifyVariant.Create;
  FOnFrameDegisti := TMultiCastNotify.Create(Self);
  FOnFrameBaslikDegisti := TMultiCastNotify.Create(Self);
  FOnFrameAktifOlacak := TMultiCastNotify.Create(Self);
  FOnFrameHenuzBaslatildi := TMultiCastNotify.Create(Self);


end;

function TFrameYoneticisi.FrameBulYumurtlanan(AFrameOrnek: TFrame): TFrameBilgi;
var
  fb: Pointer;
begin
  Result := nil;
  for fb in FYumurtlananFrameListesi do
  begin
    if TFrameBilgi(fb).FOrnek = AFrameOrnek then begin
      Result := fb;
      Exit;
    end;
  end;
end;

procedure TFrameYoneticisi.FrameHenuzBaslatildi(AFrameBilgi: TFrameBilgi);
begin

end;

destructor TFrameYoneticisi.Destroy;
begin
  FOnMesaj.Free;
  FOnFrameDegisti.Free;
  FOnFrameBaslikDegisti.Free;
  FOnFrameHenuzBaslatildi.Free;
  FYumurtlananFrameListesi.Free;
  FKayitliFrameListesi.Free;
  FAyricaBaslatilacaklar.Free;
  inherited;
end;

function TFrameYoneticisi.FrameBul(AFrameBasligi: string): TFrameBilgi;
var
  fb: Pointer;
begin
  Result := nil;
  for fb in FKayitliFrameListesi do
  begin
    if TFrameBilgi(fb).Baslik = AFrameBasligi then begin
      Result := fb;
      Exit;
    end;
  end;
end;

function TFrameYoneticisi.FrameBul(AFrameTipi: TFrameClass): TFrameBilgi;
var
  fb: Pointer;
begin
  Result := nil;
  for fb in FKayitliFrameListesi do
  begin
    if TFrameBilgi(fb).FOrnekClass = AFrameTipi then begin
      Result := fb;
      Exit;
    end;
  end;
end;

procedure TFrameYoneticisi.FrameAktifOlacak(AFrameBilgi: TFrameBilgi);
begin
  FOnFrameAktifOlacak.DoEvent(AFrameBilgi);
end;

procedure TFrameYoneticisi.FrameAktifOldu(AFrameBilgi: TFrameBilgi);
begin
  FOnFrameDegisti.DoEvent(AFrameBilgi);
end;

procedure TFrameYoneticisi.FrameBaslikDegisti(AFrameBilgi: TFrameBilgi);
begin
  FOnFrameBaslikDegisti.DoEvent(AFrameBilgi);
end;

function TFrameYoneticisi.FrameBul(AFrameOrnek: TFrame): TFrameBilgi;
var
  fb: Pointer;
begin
  Result := nil;
  for fb in FKayitliFrameListesi do
  begin
    if TFrameBilgi(fb).FOrnek = AFrameOrnek then begin
      Result := fb;
      Exit;
    end;
  end;
end;

procedure TFrameYoneticisi.FrameleriYukle;
var
  xml: TECXMLParser;
  I: Integer;
  sekmeBilgi : TXMLItem;
  sekmeler   : TXMLItem;
  fb         : TFrameBilgi;
  strStream  : TStringStream;

begin
  xml := TECXMLParser.Create(nil);
  //xml.DefaultLargeTokenizer := True;
  strStream := TStringStream.Create(FFrameYapilandirmaDosyasi); 
  try
    xml.LoadFromStream(strStream);
    sekmeler := xml.Root.NamedItem['Sekmeler'];
    for I := 0 to sekmeler.Count - 1 do begin
      sekmeBilgi := sekmeler[i];
      fb := TFrameBilgi.Create(Self, FSayfaDenetimi);
      fb.Yukle(sekmeBilgi);
      FKayitliFrameListesi.Add(fb);
    end; 
  finally
    xml.Free;
    strStream.Free;
  end;
  FFramelerYuklendi := True;
  for I := 0 to FAyricaBaslatilacaklar.Count - 1 do begin
    fb := FrameBul(TFrameClass(GetClass(FAyricaBaslatilacaklar[i])));
    if Assigned(fb) and not fb.Baslatildi then begin
      if fb.AnaSekme then fb.FAnaSekme := False;
      fb.Baslat;
    end;
  end;
end;

function TFrameYoneticisi.GetAktifFrame: TFrameBilgi;
begin
  Result := nil;
  if (FSayfaDenetimi.PageCount > 0) and Assigned(FSayfaDenetimi.ActivePage) and
    TFrameBilgi(FSayfaDenetimi.ActivePage.Tag).Baslatildi then
    Result := TFrameBilgi(FSayfaDenetimi.ActivePage.Tag);
end;

function TFrameYoneticisi.GetFrame(index: Integer): TFrameBilgi;
begin
  Result := TFrameBilgi(FKayitliFrameListesi[index]);
end;

function TFrameYoneticisi.GetFrameSayisi: Integer;
begin
  Result := FKayitliFrameListesi.Count;
end;

procedure TFrameYoneticisi.KapatilabilirleriKapat;
var
  fb: Pointer;
  i  : Integer;
begin
  if KapatilabilirlerKapanabilirMi then begin

    for fb in FKayitliFrameListesi do
    begin
      with TFrameBilgi(fb) do begin
        if Kapatilabilir and FBaslatildi then
          if BilgiFrameIntf.Kapatilabilir then Kapat;
      end;
    end;
    for i := FYumurtlananFrameListesi.Count - 1 downto 0 do begin
      TFrameBilgi(FYumurtlananFrameListesi[i]).Kapat;
    end;
  end;
  AnaSekmeyeGit;
end;

function TFrameYoneticisi.KapatilabilirlerKapanabilirMi: Boolean;
var
  fb: Pointer;
begin
  Result := True;
  for fb in FKayitliFrameListesi do
  begin
    with TFrameBilgi(fb) do begin
      if Kapatilabilir and FBaslatildi then
        if not BilgiFrameIntf.Kapatilabilir then begin
          Result := False;
          Exit;
        end;
    end;
  end;
end;

procedure TFrameYoneticisi.MesajYayinla(AMesaj: string);
begin
  FOnMesaj.DoEvent(AMesaj);
end;

procedure TFrameYoneticisi.TipeGoreAktifEt(AFrameTipi: TFrameClass);
var
  fb: Pointer;
begin
  for fb in FKayitliFrameListesi do
  begin
    if TFrameBilgi(fb).Baslatildi and (TFrameBilgi(fb).FOrnekClass = AFrameTipi) then begin
      FSayfaDenetimi.ActivePage := TFrameBilgi(fb).FSekmeSayfasi;
      Exit;
    end;
  end;
end;

function TFrameYoneticisi.Yumurtla(AFrameTipi: TFrameClass): TFrameBilgi;
var
  fb: TFrameBilgi;
begin
  Result := nil;
  fb := FrameBul(AFrameTipi);
  if Assigned(fb) then begin
    Result := fb.Yumurtla;
    FYumurtlananFrameListesi.Add(Result);
  end;
end;

var
  GeciciOwner: TComponent;

function YumurtlananFrameIcinAdDegistirici(const Name: string): Boolean;
begin
  Result := GeciciOwner.FindComponent(Name) = nil;
end;

{ TFrameBilgi }

function TFrameBilgi.Baslat : TFrameBilgi;
var
  fb : TFrameBilgi;
begin
  Result := Self;
  if FBaslatildi then Exit;
  FOrnek := TFrame(FOrnekClass.NewInstance);
  if not Supports(FOrnek,IBilgiFrame,FIBilgi) then
    FIBilgi := nil;
  FrameOrnekBaslatildi;
  { Tab Sekmesini Başlatma }

  FSekmeSayfasi := TcxTabSheet.Create(FSayfaDenetimi.Owner);
  //FSekmeSayfasi.Tag := Integer(Self); //my.15.05.2025 --> NativeInt
  FSekmeSayfasi.Tag := NativeInt(Self);
  FSekmeSayfasi.OnShow := OnFrameShow;
  FSekmeSayfasi.OnHide := OnFrameHide;
  FSekmeSayfasi.ImageIndex := FImageIndex;
  { OnFrameShow için örneği bu olay tetkiklenmeden önce başlatmamız gerekiyor  }
  { Aksi takdirde OnAramaFrameAktifOldu,OnAramaFrameOrnekAtandi olayları ilk   }
  { başlatma sırasında başarısız oluyor                                        }
  { Frame birden fazla yumurtlanınca Name istisnasına neden oluyordu. }
  GeciciOwner := FSayfaDenetimi.Owner;
  IsUniqueGlobalComponentNameProc := @YumurtlananFrameIcinAdDegistirici;
  FOrnek.Create(FSekmeSayfasi.Owner);
  if Assigned(FrameSkinUygulayici) then
    FrameSkinUygulayici(FOrnek);
  IsUniqueGlobalComponentNameProc := nil;
  { Eğer bu ilk sekme ise OnFrameShow olayı tetkiklenecektir }
  FSekmeSayfasi.PageControl := FSayfaDenetimi;
  FSekmeSayfasi.Parent := FSayfaDenetimi;
  FSekmeSayfasi.Caption := FBaslik;

  GeciciOwner := nil;
  FOrnek.Parent := FSekmeSayfasi;
  FBaslatildi := True;
  FFrameYoneticisi.FOnFrameHenuzBaslatildi.DoEvent(Self);
  if Assigned(FIBilgi) then
    FIBilgi.Baslatildi;
  if FAyricaGoster <> '' then begin
    if not FFrameYoneticisi.FramelerYuklendi then
      FFrameYoneticisi.FAyricaBaslatilacaklar.Add(FAyricaGoster)
    else begin
      fb := FFrameYoneticisi.FrameBul(TFrameClass(GetClass(FAyricaGoster)));
      if Assigned(fb) and not fb.Baslatildi then begin
        if fb.AnaSekme then fb.FAnaSekme := False;
        fb.Baslat;
      end;
    end;
  end;
  FOnFrameBaslatildi.DoEvent;
end;

constructor TFrameBilgi.Create(AFrameYoneticisi : TFrameYoneticisi;ASayfaDenetimi: TcxPageControl);
begin
  FFrameYoneticisi := AFrameYoneticisi;
  FSayfaDenetimi := ASayfaDenetimi;
  FBaslatildi := False;
  FEtiketler := TStringList.Create;
  FSekmeRengi := clBtnFace;
  FSekmeMetinRengi := clBlack;
  FOnFrameBaslatildi := TMultiCastNotify.Create(Self);  
end;

destructor TFrameBilgi.Destroy;
begin        
  FIBilgi := nil;
  FEtiketler.Free;
  FOnFrameBaslatildi.Free;
  inherited;
end;

procedure TFrameBilgi.FrameOrnekBaslatildi;
begin

end;

function TFrameBilgi.GetAktifFrameMi: Boolean;
begin
  Result := FFrameYoneticisi.AktifFrame = Self;
end;

function TFrameBilgi.GetFrameYoneticisi: TFrameYoneticisi;
begin
  Result := FFrameYoneticisi;
end;

function TFrameBilgi.Git : TFrameBilgi;
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

function TFrameBilgi.GitAdaGore: TFrameBilgi;
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

procedure TFrameBilgi.Kapat;
begin
  FBaslatildi := False;
  FIBilgi := nil;
  FOrnek.Free;
  FOrnek := nil;
  FSekmeSayfasi.Free;
  FSekmeSayfasi := nil;
  if FYumurtlandi then
    FFrameYoneticisi.FYumurtlananFrameListesi.Remove(Self);
end;

procedure TFrameBilgi.OnFrameHide(Sender: TObject);
begin
  if Assigned(FIBilgi) then
    FIBilgi.Gorunmez;
end;

procedure TFrameBilgi.OnFrameShow(Sender: TObject);
begin
  if FGecikmeli and not FBaslatildi then
    Baslat;
  FFrameYoneticisi.FrameAktifOlacak(Self);
  if Assigned(FIBilgi) then
    FIBilgi.Gorunur;
  FFrameYoneticisi.FrameAktifOldu(Self);
end;


procedure TFrameBilgi.SetBaslik(const Value: String);
begin
  FBaslik := Value;
  if Assigned(FSekmeSayfasi) then
    FSekmeSayfasi.Caption := Value;
  FFrameYoneticisi.FrameBaslikDegisti(Self);
end;

procedure TFrameBilgi.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  FSekmeSayfasi.ImageIndex := Value;
end;

procedure TFrameBilgi.SetSekmeMetinRengi(const Value: TColor);
begin
  FSekmeMetinRengi := Value;
  if Assigned(FSekmeSayfasi) then
    FSekmeSayfasi.Repaint;
end;

procedure TFrameBilgi.SetSekmeRengi(const Value: TColor);
begin
  FSekmeRengi := Value;
  if Assigned(FSekmeSayfasi) then
    FSekmeSayfasi.Repaint;
end;

procedure TFrameBilgi.Yukle(ABilgi: TXMLItem);
var
  fc         : TFrameClass;
begin
  fc := TFrameClass(GetClass(ABilgi.Params.Values['Tip']));
    if Assigned(fc) then begin
    FOrnekClass := fc;
    FBaslik := ABilgi.Params.Values['Adi'];
    FAyricaGoster := ABilgi.Params.Values['AyricaGoster'];
    FGecikmeli := ABilgi.Params.Values['Gecikmeli'] = 'evet';
    FKapatilabilir := ABilgi.Params.Values['Kapatilabilir'] = 'evet';
    FAnaSekme := ABilgi.Params.Values['AnaSekme'] = 'evet';
    FImageIndex := StrToIntDef(ABilgi.Params.Values['Image'],-1);
    if (ABilgi.Params.Values['HerZamanGorunur'] = 'evet') then begin
      if not FGecikmeli then begin
        Baslat;
      end;
    end;
  end;
  end;

function TFrameBilgi.Yumurtla: TFrameBilgi;
begin
  Result := TFrameBilgi.Create(FFrameYoneticisi,FSayfaDenetimi);
  Result.FYumurtlandi := True;
  Result.FAnaSekme := FAnaSekme;
  Result.FBaslatildi := False;
  Result.FBaslik := FBaslik;
  Result.FEtiket := FEtiket;
  Result.FEtiketler.Assign(FEtiketler);
  Result.FGecikmeli := FGecikmeli;
  Result.FIBilgi := nil;
  Result.FOrnek := nil;
  Result.FKapatilabilir := True;
  Result.FOrnekClass := FOrnekClass;
  Result.FSekmeSayfasi := nil;
end;

end.

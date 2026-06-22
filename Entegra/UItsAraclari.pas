unit UItsAraclari;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ECXMLParser, Generics.Collections;


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
      function GetIcerik: TStream;
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
      property Servis :string read GetServisUrl;
  end;

  TPTSAlimIstek = class(TPTSSoapIstek)
  private
    FFR: string;
    FTRANSFERID: string;
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
    property TRANSFERID : string read FTRANSFERID write FTRANSFERID;
    property Urunler : TObjectList<TUrun> read FUrunler write FUrunler;
  end;

  TDepoAlimIstek = class(TSoapIstek)
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
  TDepoAlimIadeIstek = class (TSoapIstek)
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
  end;
  TDepoSatisIptalIstek = class (TSoapIstek)
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
    constructor Create(Stream: TStream);virtual;
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
    constructor Create(Stream: TStream); override;
    destructor Destroy; override;
    procedure YanitiIsle; override;
    property BildirimId : string read FBildirimId;
    property UrunDurumlar : TObjectList<TUrunDurum> read FUrunDurumlar;
    property YanitHatali : Boolean read FYanitHatali;
  end;

var
  ServisUrlOnEki : string = 'http://212.174.130.240/';

implementation

uses FetaKurulusSiniflari;

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
end;

function TSoapIstek.GetServisUrl: string;
begin
  Result := '';
end;

procedure TSoapIstek.GovdeHazirla;
begin

end;

{ TDepoAlimIstek }

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

constructor TSoapYanit.Create(Stream: TStream);
var
  I: Integer;
begin
  FXml := TECXMLParser.Create(nil);
  FXml.LoadFromStream(Stream);
  for I := 0 to FXml.Root.SubItemCount - 1 do begin
    if ( Pos('BODY',UpperCase(FXml.Root.SubItems[i].Name)) > 0) then begin
      FGovde := FXml.Root.SubItems[i].SubItems[0];
      YanitiIsle;
      Exit;
    end;
  end;

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

constructor TGenelYanit.Create(Stream: TStream);
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
  FXml.Root.Params.Add('xmlns:xsd=http://www.w3.org/2001/XMLSchema');
  FXml.Root.Params.Add('xmlns:xsi=http://www.w3.org/2001/XMLSchema-instance');
  FGovde := FXml.Root.New;
  with FGovde do begin
    Name := 'soapenv:Body';
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
  FXml.Root.Params.Add('xmlns:Gonder=http://its.iegm.gov.tr/pts/receivepackage');
end;

constructor TPTSAlimIstek.Create;
begin
  inherited;
  FUrunler := TObjectList<TUrun>.Create;
end;

destructor TPTSAlimIstek.Destroy;
begin
  FUrunler.Free;
  inherited;
end;

function TPTSAlimIstek.GetServisUrl: string;
begin
Result := 'http://pts.saglik.gov.tr:80/PTS/PackageReceiverWebService';
end;

procedure TPTSAlimIstek.GovdeHazirla;
var
  I: Integer;
  urun : TUrun;
begin
  inherited;
  with FGovde.New do begin
    Name := 'Gonder:receiveFileParameters';
    with New do begin
      Name := 'sourceGLN';
      Text := FFR;
    end;
    with New do begin
      Name := 'transferId';
      Text := FTRANSFERID;
    end;
  end;
end;



end.

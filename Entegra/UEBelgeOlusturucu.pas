unit UEBelgeOlusturucu;

interface

uses
  FireDAC.Comp.Client;

type
  TEBelgeOlusturucu = class
  public
    class function Olustur(AConnection: TFDConnection; AFatBaslikID: Integer;
      const AAliciAlias: string; ABelgeTuruOverride: Integer = 0): Int64; static;
    class procedure Onizle(AConnection: TFDConnection;
      AFatBaslikID: Integer); static;
    class procedure HTMLKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure PDFKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure XMLKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class function Gonder(AConnection: TFDConnection;
      AFatBaslikID: Integer; const AKullanici, ASifre, ABaseURL: string;
      ATestModu: Boolean; out AYanitMesaj: string): Boolean; static;

    /// Gelen e-belge (EBELGE.YON=2) icin onizleme/dosya isleri.
    /// UBL XML'i EBELGE.UBL_XML kolonundan okur; XSLT ile HTML olusturur.
    class procedure OnizleGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer); static;
    class procedure XMLKaydetGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure HTMLKaydetGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure PDFKaydetGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
  end;

implementation

uses
  Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Classes,
  System.JSON, System.NetEncoding, System.IOUtils, System.Variants, Data.DB,
  System.StrUtils, ComObj, Utablo, PrjConst, FetaKurulusSiniflari,
  UEBelgeAliasServis, UIzibizRest;

type
  TEBelgeBaslik = record
    ID: Integer;
    Tur: Integer;
    RehberID: Integer;
    EBelgeID: Int64;
    EBelgeDurum: Integer;
    Tarih: TDateTime;
    VergiNo: string;
    VergiDairesi: string;
    Baslik: string;
    CariKod: string;
    FaturaNo: string;
    Aciklama: string;
    Aciklama2: string;
    Adres: string;
    Ilce: string;
    Il: string;
    ParaBirimi: string;
    AliciAlias: string;
    GondericiAlias: string;
    UUID: string;
    Matrah: Currency;
    KDV: Currency;
    Toplam: Currency;
    EFaturaDurum: Integer;     // FATBASLIK.EFATURADURUM (1/11/51 vs 2/12/52)
    EArsivMi: Boolean;         // EFATURADURUM in [11,12] olunca True
    EBelgeBelgeTuru: Integer;  // EBELGE.BELGETURU ? RAlias kodu (140/141/150/151)
  end;

  TEBelgeSatir = record
    SatirNo: Integer;
    UrunKodu: string;
    AliciUrunKodu: string;
    UrunAdi: string;
    Barkod: string;
    SutKodu: string;
    LotNo: string;
    SeriNo: string;
    Aciklama: string;
    BirimKodu: string;
    Miktar: Double;
    BirimFiyat: Currency;
    Tutar: Currency;
    KDVOrani: Double;
    Notu: string;
  end;

  TEBelgeSatirlar = array of TEBelgeSatir;

  TEBelgeTaraf = record
    VergiNo: string;
    VergiDairesi: string;
    Unvan: string;
    Adres: string;
    Ilce: string;
    Il: string;
    Ulke: string;
    PostaKodu: string;
    Telefon: string;
    Faks: string;
    EPosta: string;
    Web: string;
  end;
  TSevkBilgisi = record
    TasiyanTipi: string;
    TasiyiciID: Integer;
    TasiyiciUnvan: string;
    TasiyiciVknTckn: string;
    Plaka: string;
    SoforID: Integer;
    SoforAdi: string;
    SoforSoyadi: string;
    SoforTckn: string;
    DorsePlaka: string;
  end;

function AlanStr(ADataSet: TDataSet; const AAlan: string): string;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsString
  else
    Result := '';
end;

function AlanInt(ADataSet: TDataSet; const AAlan: string): Integer;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsInteger
  else
    Result := 0;
end;

function AlanInt64(ADataSet: TDataSet; const AAlan: string): Int64;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsLargeInt
  else
    Result := 0;
end;

function AlanFloat(ADataSet: TDataSet; const AAlan: string): Double;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsFloat
  else
    Result := 0;
end;

function AlanCurrency(ADataSet: TDataSet; const AAlan: string): Currency;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsCurrency
  else
    Result := 0;
end;

function AlanTarih(ADataSet: TDataSet; const AAlan: string): TDateTime;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsDateTime
  else
    Result := 0;
end;

function XMLEscape(const ADeger: string): string;
begin
  Result := StringReplace(ADeger, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
end;

function HTMLEscape(const ADeger: string): string;
begin
  Result := XMLEscape(ADeger);
  Result := StringReplace(Result, sLineBreak, '<br>', [rfReplaceAll]);
end;

function Ondalik(const ADeger: Extended; const AFormat: string): string;
begin
  Result := StringReplace(FormatFloat(AFormat, ADeger), ',', '.',
    [rfReplaceAll]);
end;

function ParaBirimiNormallestir(const ADeger: string): string;
begin
  Result := UpperCase(Trim(ADeger));
  if (Result = '') or (Result = 'TL') or (Result = 'YTL') then
    Result := 'TRY';
end;

function KimlikSemasi(const AVergiNo: string): string;
begin
  if Length(Trim(AVergiNo)) = 11 then
    Result := 'TCKN'
  else
    Result := 'VKN';
end;

function YeniUUID: string;
begin
  Result := TGUID.NewGuid.ToString;
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
end;

function GondericiAliasGetir(ABelgeTuru: Integer): string;
begin
  Result := '';
  Tablo.TablodanSorguAc(1,
    'select top 1 ALIAS from REHBERALIAS where REHBERID=-1 and BELGETURU=' +
    IntToStr(ABelgeTuru) + ' and AKTIF=1 order by VARSAYILAN desc, ID');
  if not Tablo.Query1.Eof then
    Result := Tablo.Query1.Fields[0].AsString;
end;
function JSONNesneStr(AObj: TJSONObject; const AAd: string): string;
var
  LVal: TJSONValue;
begin
  Result := '';
  if not Assigned(AObj) then
    Exit;
  LVal := AObj.GetValue(AAd);
  if Assigned(LVal) then
    Result := LVal.Value;
end;
function SevkBilgisiGetir(AFatBaslikID: Integer): TSevkBilgisi;
var
  LJSON: string;
  LVal: TJSONValue;
  LObj: TJSONObject;
begin
  Result := Default(TSevkBilgisi);
  Tablo.TablodanSorguAc(1,
    'select SEVKBILGISI from FATBASLIK_USER where ID=' + IntToStr(AFatBaslikID));
  if Tablo.Query1.Eof then
    Exit;
  LJSON := Trim(AlanStr(Tablo.Query1, 'SEVKBILGISI'));
  Tablo.Query1.Close;
  if LJSON = '' then
    Exit;
  LVal := TJSONObject.ParseJSONValue(LJSON);
  if not (LVal is TJSONObject) then begin
    LVal.Free;
    Exit;
  end;
  LObj := TJSONObject(LVal);
  try
    Result.TasiyanTipi := JSONNesneStr(LObj, 'tasiyanTipi');
    Result.TasiyiciID := StrToIntDef(JSONNesneStr(LObj, 'tasiyiciId'), 0);
    Result.TasiyiciUnvan := Trim(JSONNesneStr(LObj, 'tasiyiciUnvan'));
    if Result.TasiyiciUnvan = '' then
      Result.TasiyiciUnvan := Trim(JSONNesneStr(LObj, 'tasiyici'));
    Result.TasiyiciVknTckn := StringReplace(
      Trim(JSONNesneStr(LObj, 'tasiyiciVknTckn')), ' ', '', [rfReplaceAll]);
    Result.Plaka := Trim(JSONNesneStr(LObj, 'plaka'));
    Result.SoforID := StrToIntDef(JSONNesneStr(LObj, 'soforId'), 0);
    Result.SoforAdi := Trim(JSONNesneStr(LObj, 'soforAdi'));
    if Result.SoforAdi = '' then
      Result.SoforAdi := Trim(JSONNesneStr(LObj, 'sofor'));
    Result.SoforSoyadi := Trim(JSONNesneStr(LObj, 'soforSoyadi'));
    Result.SoforTckn := StringReplace(
      Trim(JSONNesneStr(LObj, 'soforTckn')), ' ', '', [rfReplaceAll]);
    Result.DorsePlaka := Trim(JSONNesneStr(LObj, 'dorsePlaka'));
  finally
    LObj.Free;
  end;
end;
function SevkTasiyiciTaraf(const ASevk: TSevkBilgisi;
  const AGonderici: TEBelgeTaraf): TEBelgeTaraf;
begin
  if SameText(Trim(ASevk.TasiyanTipi), 'kendimiz') then begin
    Result := AGonderici;
    Exit;
  end;
  Result := Default(TEBelgeTaraf);
  Result.Unvan := ASevk.TasiyiciUnvan;
  Result.VergiNo := ASevk.TasiyiciVknTckn;
  Result.Ulke := 'Turkiye';
end;
function SevkBilgisiDogrula(const ASevk: TSevkBilgisi): string;
begin
  Result := '';
  if Trim(ASevk.Plaka) = '' then
    Exit('Sevk bilgisi eksik: plaka girilmelidir.');
  if Trim(ASevk.SoforAdi) = '' then
    Exit('Sevk bilgisi eksik: sofor adi girilmelidir.');

  if Trim(ASevk.SoforTckn) = '' then
    Exit('Sevk bilgisi eksik: sofor TCKN girilmelidir.');
  if not SameText(Trim(ASevk.TasiyanTipi), 'kendimiz') then begin
    if Trim(ASevk.TasiyiciUnvan) = '' then
      Exit('Sevk bilgisi eksik: tasiyici unvani girilmelidir.');
    if Trim(ASevk.TasiyiciVknTckn) = '' then
      Exit('Sevk bilgisi eksik: tasiyici VKN/TCKN girilmelidir.');
  end;
end;

procedure VerileriOku(AFatBaslikID: Integer; out ABaslik: TEBelgeBaslik;
  out ASatirlar: TEBelgeSatirlar);
var
  LSatir: TEBelgeSatir;
  LMiktar: Double;
begin
  ABaslik := Default(TEBelgeBaslik);
  SetLength(ASatirlar, 0);

  Tablo.TablodanSorguAc(1, 'exec dbo.sp_Prog_EBelge_GidenFatura @ID=' +
    IntToStr(AFatBaslikID));
  if Tablo.Query1.Eof then
    raise Exception.Create('Giden e-belge baslik bilgisi bulunamadi.');

  ABaslik.ID := AlanInt(Tablo.Query1, 'ID');
  ABaslik.Tur := AlanInt(Tablo.Query1, 'TUR');
  ABaslik.RehberID := AlanInt(Tablo.Query1, 'REHBERID');
  ABaslik.EBelgeID := AlanInt64(Tablo.Query1, 'EBELGEID');
  ABaslik.EBelgeDurum := AlanInt(Tablo.Query1, 'EBDURUM');
  ABaslik.EFaturaDurum := AlanInt(Tablo.Query1, 'EFATURADURUM');
  ABaslik.EArsivMi := ABaslik.EFaturaDurum in [11, 12];
  ABaslik.Tarih := AlanTarih(Tablo.Query1, 'FATURATARIH');
  ABaslik.VergiNo := AlanStr(Tablo.Query1, 'VNO');
  ABaslik.VergiDairesi := AlanStr(Tablo.Query1, 'VD');
  ABaslik.Baslik := AlanStr(Tablo.Query1, 'BASLIK');
  ABaslik.CariKod := AlanStr(Tablo.Query1, 'CARIKOD');
  ABaslik.FaturaNo := AlanStr(Tablo.Query1, 'FATURANO');
  ABaslik.Aciklama := AlanStr(Tablo.Query1, 'ACIKLAMA');
  ABaslik.Aciklama2 := AlanStr(Tablo.Query1, 'ACIKLAMA2');
  ABaslik.Adres := AlanStr(Tablo.Query1, 'ADRES');
  ABaslik.Ilce := AlanStr(Tablo.Query1, 'ILCE');
  ABaslik.Il := AlanStr(Tablo.Query1, 'IL');
  ABaslik.ParaBirimi := ParaBirimiNormallestir(
    AlanStr(Tablo.Query1, 'FATURADOVIZI'));
  ABaslik.AliciAlias := AlanStr(Tablo.Query1, 'ALICIALIAS');
  ABaslik.GondericiAlias := AlanStr(Tablo.Query1, 'GONDERICIALIAS');
  ABaslik.UUID := AlanStr(Tablo.Query1, 'EBUUID');
  ABaslik.Matrah := AlanCurrency(Tablo.Query1, 'FATURA_MATRAHI');
  ABaslik.KDV := AlanCurrency(Tablo.Query1, 'KDV_TUTARI');
  ABaslik.Toplam := AlanCurrency(Tablo.Query1, 'FATURA_TUTARI');

  Tablo.TablodanSorguAc(1,
    'exec dbo.sp_Prog_EBelge_GidenFaturaDetay @invoiceId=' +
    IntToStr(AFatBaslikID));
  while not Tablo.Query1.Eof do begin
    LSatir := Default(TEBelgeSatir);
    LSatir.SatirNo := AlanInt(Tablo.Query1, 'LineNumber');
    LSatir.UrunKodu := AlanStr(Tablo.Query1, 'ProductCode');
    LSatir.AliciUrunKodu := AlanStr(Tablo.Query1, 'BuyersItemCode');
    LSatir.UrunAdi := AlanStr(Tablo.Query1, 'ProductName');
    LSatir.Barkod := AlanStr(Tablo.Query1, 'BARKOD');
    LSatir.SutKodu := AlanStr(Tablo.Query1, 'ManufacturersItemCode');
    LSatir.LotNo := AlanStr(Tablo.Query1, 'LOTNO');
    LSatir.SeriNo := AlanStr(Tablo.Query1, 'SERINO');
    LSatir.Aciklama := AlanStr(Tablo.Query1, 'ACIKLAMA');
    LSatir.BirimKodu := AlanStr(Tablo.Query1, 'UnitCodeConverted');
    LMiktar := AlanFloat(Tablo.Query1, 'MIKTAR');
    if LMiktar = 0 then
      LMiktar := AlanFloat(Tablo.Query1, 'ADET');
    if LMiktar = 0 then
      LMiktar := 1;
    LSatir.Miktar := LMiktar;
    LSatir.BirimFiyat := AlanCurrency(Tablo.Query1, 'BIRIMFIYAT');
    LSatir.Tutar := AlanCurrency(Tablo.Query1, 'TUTAR');
    LSatir.KDVOrani := AlanFloat(Tablo.Query1, 'KDV');
    LSatir.Notu := AlanStr(Tablo.Query1, 'Note');
    SetLength(ASatirlar, Length(ASatirlar) + 1);
    ASatirlar[High(ASatirlar)] := LSatir;
    Tablo.Query1.Next;
  end;
end;

function PartyXML(const ARol: string; const ATaraf: TEBelgeTaraf): string;
var
  LXML: TStringBuilder;
begin
  LXML := TStringBuilder.Create;
  try
    LXML.AppendLine('<cac:' + ARol + '>');
    LXML.AppendLine('<cac:Party>');
    if Trim(ATaraf.Web) <> '' then
      LXML.AppendLine('<cbc:WebsiteURI>' + XMLEscape(ATaraf.Web) +
        '</cbc:WebsiteURI>');
    if Trim(ATaraf.VergiNo) <> '' then
      LXML.AppendLine('<cac:PartyIdentification><cbc:ID schemeID="' +
        KimlikSemasi(ATaraf.VergiNo) + '">' + XMLEscape(ATaraf.VergiNo) +
        '</cbc:ID></cac:PartyIdentification>');
    LXML.AppendLine('<cac:PartyName><cbc:Name>' + XMLEscape(ATaraf.Unvan) +
      '</cbc:Name></cac:PartyName>');
    LXML.AppendLine('<cac:PostalAddress>');
    if Trim(ATaraf.Adres) <> '' then
      LXML.AppendLine('<cbc:StreetName>' + XMLEscape(ATaraf.Adres) +
        '</cbc:StreetName>');
    if Trim(ATaraf.Ilce) <> '' then
      LXML.AppendLine('<cbc:CitySubdivisionName>' + XMLEscape(ATaraf.Ilce) +
        '</cbc:CitySubdivisionName>');
    if Trim(ATaraf.Il) <> '' then
      LXML.AppendLine('<cbc:CityName>' + XMLEscape(ATaraf.Il) +
        '</cbc:CityName>');
    if Trim(ATaraf.PostaKodu) <> '' then
      LXML.AppendLine('<cbc:PostalZone>' + XMLEscape(ATaraf.PostaKodu) +
        '</cbc:PostalZone>');
    if Trim(ATaraf.Ulke) = '' then
      LXML.AppendLine('<cac:Country><cbc:Name>Turkiye</cbc:Name></cac:Country>')
    else
      LXML.AppendLine('<cac:Country><cbc:Name>' + XMLEscape(ATaraf.Ulke) +
        '</cbc:Name></cac:Country>');
    LXML.AppendLine('</cac:PostalAddress>');
    if Trim(ATaraf.VergiDairesi) <> '' then
      LXML.AppendLine('<cac:PartyTaxScheme><cac:TaxScheme><cbc:Name>' +
        XMLEscape(ATaraf.VergiDairesi) +
        '</cbc:Name></cac:TaxScheme></cac:PartyTaxScheme>');
    LXML.AppendLine('<cac:PartyLegalEntity><cbc:RegistrationName>' +
      XMLEscape(ATaraf.Unvan) +
      '</cbc:RegistrationName></cac:PartyLegalEntity>');
    if (Trim(ATaraf.Telefon) <> '') or (Trim(ATaraf.Faks) <> '') or
      (Trim(ATaraf.EPosta) <> '') then begin
      LXML.AppendLine('<cac:Contact>');
      if Trim(ATaraf.Telefon) <> '' then
        LXML.AppendLine('<cbc:Telephone>' + XMLEscape(ATaraf.Telefon) +
          '</cbc:Telephone>');
      if Trim(ATaraf.Faks) <> '' then
        LXML.AppendLine('<cbc:Telefax>' + XMLEscape(ATaraf.Faks) +
          '</cbc:Telefax>');
      if Trim(ATaraf.EPosta) <> '' then
        LXML.AppendLine('<cbc:ElectronicMail>' + XMLEscape(ATaraf.EPosta) +
          '</cbc:ElectronicMail>');
      LXML.AppendLine('</cac:Contact>');
    end;
    LXML.AppendLine('</cac:Party>');
    LXML.AppendLine('</cac:' + ARol + '>');
    Result := LXML.ToString;
  finally
    LXML.Free;
  end;
end;

function BizimTarafGetir(const AVergiNo, AUnvan: string): TEBelgeTaraf;
begin
  Result := Default(TEBelgeTaraf);
  Result.VergiNo := AVergiNo;
  Result.Unvan := AUnvan;

  if not Tablo.TabBizim.Active then
    Tablo.TabBizim.Open;
  if Tablo.TabBizim.IsEmpty then
    Exit;

  Result.VergiNo := AlanStr(Tablo.TabBizim, 'VERGINO');
  Result.VergiDairesi := AlanStr(Tablo.TabBizim, 'VERGIDAI');
  Result.Unvan := AlanStr(Tablo.TabBizim, 'FATURABASLIK');
  if Trim(Result.Unvan) = '' then
    Result.Unvan := AlanStr(Tablo.TabBizim, 'FIRMA');
  Result.Adres := AlanStr(Tablo.TabBizim, 'ADRES');
  Result.Ilce := AlanStr(Tablo.TabBizim, 'ILCE');
  Result.Il := AlanStr(Tablo.TabBizim, 'IL');
  Result.Ulke := AlanStr(Tablo.TabBizim, 'ULKE');
  Result.PostaKodu := AlanStr(Tablo.TabBizim, 'PK');
  Result.Telefon := AlanStr(Tablo.TabBizim, 'ISTEL');
  Result.Faks := AlanStr(Tablo.TabBizim, 'FAX');
  Result.EPosta := AlanStr(Tablo.TabBizim, 'EMAIL');
  Result.Web := AlanStr(Tablo.TabBizim, 'WEB');

  if Trim(Result.VergiNo) = '' then
    Result.VergiNo := AVergiNo;
  Result.VergiNo := StringReplace(Result.VergiNo, ' ', '', [rfReplaceAll]);
  if Trim(Result.Unvan) = '' then
    Result.Unvan := AUnvan;
end;

function UBLXMLUret(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar; const AGondericiVergiNo,
  AGondericiUnvan: string): string;
var
  LXML: TStringBuilder;
  I: Integer;
  LSatirVergi: Currency;
  LSatirTuru, LMiktarTuru, LRoot, LProfil: string;
  LGonderici, LAlici, LTasiyici: TEBelgeTaraf;
  LSevk: TSevkBilgisi;
begin
  if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
    LRoot := 'DespatchAdvice';
    LProfil := 'TEMELIRSALIYE';
    LSatirTuru := 'DespatchLine';
    LMiktarTuru := 'DeliveredQuantity';
  end else if ABaslik.EArsivMi then begin
    LRoot := 'Invoice';
    LProfil := 'EARSIVFATURA';
    LSatirTuru := 'InvoiceLine';
    LMiktarTuru := 'InvoicedQuantity';
  end else begin
    LRoot := 'Invoice';
    LProfil := 'TEMELFATURA';
    LSatirTuru := 'InvoiceLine';
    LMiktarTuru := 'InvoicedQuantity';
  end;

  LGonderici := BizimTarafGetir(AGondericiVergiNo, AGondericiUnvan);
  LSevk := Default(TSevkBilgisi);
  LTasiyici := Default(TEBelgeTaraf);
  if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
    LSevk := SevkBilgisiGetir(ABaslik.ID);
    LTasiyici := SevkTasiyiciTaraf(LSevk, LGonderici);
  end;
  LAlici := Default(TEBelgeTaraf);
  LAlici.VergiNo := ABaslik.VergiNo;
  LAlici.VergiDairesi := ABaslik.VergiDairesi;
  LAlici.Unvan := ABaslik.Baslik;
  LAlici.Adres := ABaslik.Adres;
  LAlici.Ilce := ABaslik.Ilce;
  LAlici.Il := ABaslik.Il;
  LAlici.Ulke := 'Turkiye';

  LXML := TStringBuilder.Create;
  try
    LXML.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
    LXML.AppendLine('<' + LRoot +
      ' xmlns="urn:oasis:names:specification:ubl:schema:xsd:' + LRoot +
      '-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' +
      ' xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">');
    LXML.AppendLine('<cbc:UBLVersionID>2.1</cbc:UBLVersionID>');
    LXML.AppendLine('<cbc:CustomizationID>TR1.2</cbc:CustomizationID>');
    LXML.AppendLine('<cbc:ProfileID>' + LProfil + '</cbc:ProfileID>');
    LXML.AppendLine('<cbc:ID>' + XMLEscape(ABaslik.FaturaNo) + '</cbc:ID>');
    LXML.AppendLine('<cbc:CopyIndicator>false</cbc:CopyIndicator>');
    LXML.AppendLine('<cbc:UUID>' + XMLEscape(ABaslik.UUID) + '</cbc:UUID>');
    LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
      ABaslik.Tarih) + '</cbc:IssueDate>');
    LXML.AppendLine('<cbc:IssueTime>' + FormatDateTime('hh:nn:ss',
      ABaslik.Tarih) + '</cbc:IssueTime>');
    if ABaslik.Tur = EBelgeTuruEIrsaliye then
      LXML.AppendLine('<cbc:DespatchAdviceTypeCode>SEVK</cbc:DespatchAdviceTypeCode>')
    else
      LXML.AppendLine('<cbc:InvoiceTypeCode>SATIS</cbc:InvoiceTypeCode>');
    if Trim(ABaslik.Aciklama) <> '' then
      LXML.AppendLine('<cbc:Note>' + XMLEscape(ABaslik.Aciklama) +
        '</cbc:Note>');
    if Trim(ABaslik.Aciklama2) <> '' then
      LXML.AppendLine('<cbc:Note>' + XMLEscape(ABaslik.Aciklama2) +
        '</cbc:Note>');
    LXML.AppendLine('<cbc:DocumentCurrencyCode>' +
      XMLEscape(ABaslik.ParaBirimi) + '</cbc:DocumentCurrencyCode>');
    LXML.AppendLine('<cbc:LineCountNumeric>' + IntToStr(Length(ASatirlar)) +
      '</cbc:LineCountNumeric>');

    if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
      LXML.Append(PartyXML('DespatchSupplierParty', LGonderici));
      LXML.Append(PartyXML('DeliveryCustomerParty', LAlici));
      LXML.AppendLine('<cac:Shipment>');
      LXML.AppendLine('<cbc:ID>1</cbc:ID>');
      LXML.AppendLine('<cac:GoodsItem><cbc:ValueAmount currencyID="' +
        XMLEscape(ABaslik.ParaBirimi) + '">' + Ondalik(ABaslik.Matrah, '0.00##') +
        '</cbc:ValueAmount></cac:GoodsItem>');
      LXML.AppendLine('<cac:ShipmentStage>');
      if Trim(LSevk.Plaka) <> '' then begin
        LXML.AppendLine('<cac:TransportMeans>');
        LXML.AppendLine('<cac:RoadTransport>');
        LXML.AppendLine('<cbc:LicensePlateID>' + XMLEscape(LSevk.Plaka) +
          '</cbc:LicensePlateID>');
        LXML.AppendLine('</cac:RoadTransport>');
        LXML.AppendLine('</cac:TransportMeans>');
      end;
      if (Trim(LSevk.SoforAdi) <> '') or (Trim(LSevk.SoforSoyadi) <> '') or
         (Trim(LSevk.SoforTckn) <> '') then begin
        LXML.AppendLine('<cac:DriverPerson>');
        if Trim(LSevk.SoforAdi) <> '' then
          LXML.AppendLine('<cbc:FirstName>' + XMLEscape(Trim(LSevk.SoforAdi + ' ' + LSevk.SoforSoyadi)) +
            '</cbc:FirstName>');
        if Trim(LSevk.SoforTckn) <> '' then
          LXML.AppendLine('<cbc:NationalityID>' + XMLEscape(LSevk.SoforTckn) +
            '</cbc:NationalityID>');
        LXML.AppendLine('</cac:DriverPerson>');
      end;
      if (Trim(LTasiyici.Unvan) <> '') or (Trim(LTasiyici.VergiNo) <> '') then begin
        // CarrierParty dogrudan Party elemanÄ±dÄ±r - cac:Party sarmalayÄ±cÄ± olmadan
        LXML.AppendLine('<cac:CarrierParty>');
        if Trim(LTasiyici.VergiNo) <> '' then
          LXML.AppendLine('<cac:PartyIdentification><cbc:ID schemeID="' +
            KimlikSemasi(LTasiyici.VergiNo) + '">' + XMLEscape(LTasiyici.VergiNo) +
            '</cbc:ID></cac:PartyIdentification>');
        LXML.AppendLine('<cac:PartyName><cbc:Name>' + XMLEscape(LTasiyici.Unvan) +
          '</cbc:Name></cac:PartyName>');
        LXML.AppendLine('</cac:CarrierParty>');
      end;
      LXML.AppendLine('</cac:ShipmentStage>');
      LXML.AppendLine('<cac:Delivery>');
      LXML.AppendLine('<cac:DeliveryAddress>');
      if Trim(ABaslik.Adres) <> '' then
        LXML.AppendLine('<cbc:StreetName>' + XMLEscape(ABaslik.Adres) +
          '</cbc:StreetName>');
      if Trim(ABaslik.Ilce) <> '' then
        LXML.AppendLine('<cbc:CitySubdivisionName>' + XMLEscape(ABaslik.Ilce) +
          '</cbc:CitySubdivisionName>');
      if Trim(ABaslik.Il) <> '' then
        LXML.AppendLine('<cbc:CityName>' + XMLEscape(ABaslik.Il) +
          '</cbc:CityName>');
      LXML.AppendLine('<cbc:PostalZone>34000</cbc:PostalZone>');
      LXML.AppendLine('<cac:Country><cbc:Name>Turkiye</cbc:Name></cac:Country>');
      LXML.AppendLine('</cac:DeliveryAddress>');
      LXML.AppendLine('<cac:Despatch>');
      LXML.AppendLine('<cbc:ActualDespatchDate>' + FormatDateTime('yyyy-mm-dd',
        ABaslik.Tarih) + '</cbc:ActualDespatchDate>');
      LXML.AppendLine('<cbc:ActualDespatchTime>' + FormatDateTime('hh:nn:ss',
        ABaslik.Tarih) + '</cbc:ActualDespatchTime>');
      LXML.AppendLine('</cac:Despatch>');
      LXML.AppendLine('</cac:Delivery>');
      LXML.AppendLine('</cac:Shipment>');
    end else begin
      LXML.Append(PartyXML('AccountingSupplierParty', LGonderici));
      LXML.Append(PartyXML('AccountingCustomerParty', LAlici));
      LXML.AppendLine('<cac:TaxTotal><cbc:TaxAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(ABaslik.KDV, '0.00##') +
        '</cbc:TaxAmount></cac:TaxTotal>');
      LXML.AppendLine('<cac:LegalMonetaryTotal>');
      LXML.AppendLine('<cbc:LineExtensionAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(ABaslik.Matrah, '0.00##') +
        '</cbc:LineExtensionAmount>');
      LXML.AppendLine('<cbc:TaxExclusiveAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(ABaslik.Matrah, '0.00##') +
        '</cbc:TaxExclusiveAmount>');
      LXML.AppendLine('<cbc:TaxInclusiveAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(ABaslik.Toplam, '0.00##') +
        '</cbc:TaxInclusiveAmount>');
      LXML.AppendLine('<cbc:PayableAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(ABaslik.Toplam, '0.00##') +
        '</cbc:PayableAmount>');
      LXML.AppendLine('</cac:LegalMonetaryTotal>');
    end;

    for I := 0 to High(ASatirlar) do begin
      LXML.AppendLine('<cac:' + LSatirTuru + '>');
      LXML.AppendLine('<cbc:ID>' + IntToStr(ASatirlar[I].SatirNo) +
        '</cbc:ID>');
      LXML.AppendLine('<cbc:' + LMiktarTuru + ' unitCode="' +
        XMLEscape(ASatirlar[I].BirimKodu) + '">' +
        Ondalik(ASatirlar[I].Miktar, '0.######') + '</cbc:' +
        LMiktarTuru + '>');
      if ABaslik.Tur <> EBelgeTuruEIrsaliye then begin
        LXML.AppendLine('<cbc:LineExtensionAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(ASatirlar[I].Tutar,
          '0.00##') + '</cbc:LineExtensionAmount>');
        LSatirVergi := ASatirlar[I].Tutar * ASatirlar[I].KDVOrani / 100;
        LXML.AppendLine('<cac:TaxTotal><cbc:TaxAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LSatirVergi, '0.00##') +
          '</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(ASatirlar[I].Tutar,
          '0.00##') + '</cbc:TaxableAmount><cbc:TaxAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LSatirVergi, '0.00##') +
          '</cbc:TaxAmount><cbc:Percent>' +
          Ondalik(ASatirlar[I].KDVOrani, '0.##') +
          '</cbc:Percent><cac:TaxCategory><cac:TaxScheme><cbc:Name>KDV</cbc:Name>' +
          '<cbc:TaxTypeCode>0015</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory>' +
          '</cac:TaxSubtotal></cac:TaxTotal>');
      end;
      if Trim(ASatirlar[I].Notu) <> '' then
        LXML.AppendLine('<cbc:Note>' + XMLEscape(ASatirlar[I].Notu) +
          '</cbc:Note>');
      LXML.AppendLine('<cac:Item><cbc:Description>' +
        XMLEscape(ASatirlar[I].Aciklama) + '</cbc:Description><cbc:Name>' +
        XMLEscape(ASatirlar[I].UrunAdi) +
        '</cbc:Name><cac:SellersItemIdentification><cbc:ID>' +
        XMLEscape(ASatirlar[I].UrunKodu) +
        '</cbc:ID></cac:SellersItemIdentification>');
      if Trim(ASatirlar[I].AliciUrunKodu) <> '' then
        LXML.AppendLine('<cac:BuyersItemIdentification><cbc:ID>' +
          XMLEscape(ASatirlar[I].AliciUrunKodu) +
          '</cbc:ID></cac:BuyersItemIdentification>');
      if Trim(ASatirlar[I].Barkod) <> '' then
        LXML.AppendLine('<cac:StandardItemIdentification><cbc:ID schemeID="GTIN">' +
          XMLEscape(ASatirlar[I].Barkod) +
          '</cbc:ID></cac:StandardItemIdentification>');
      if Trim(ASatirlar[I].SutKodu) <> '' then
        LXML.AppendLine('<cac:ManufacturersItemIdentification><cbc:ID>' +
          XMLEscape(ASatirlar[I].SutKodu) +
          '</cbc:ID></cac:ManufacturersItemIdentification>');
      if Trim(ASatirlar[I].LotNo) <> '' then
        LXML.AppendLine('<cac:AdditionalItemProperty><cbc:Name>LOTNO</cbc:Name><cbc:Value>' +
          XMLEscape(ASatirlar[I].LotNo) +
          '</cbc:Value></cac:AdditionalItemProperty>');
      if Trim(ASatirlar[I].SeriNo) <> '' then
        LXML.AppendLine('<cac:AdditionalItemProperty><cbc:Name>SERINO</cbc:Name><cbc:Value>' +
          XMLEscape(ASatirlar[I].SeriNo) +
          '</cbc:Value></cac:AdditionalItemProperty>');
      LXML.AppendLine('</cac:Item>');
      if ABaslik.Tur <> EBelgeTuruEIrsaliye then
        LXML.AppendLine('<cac:Price><cbc:PriceAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(ASatirlar[I].BirimFiyat,
          '0.00######') + '</cbc:PriceAmount></cac:Price>');
      LXML.AppendLine('</cac:' + LSatirTuru + '>');
    end;
    LXML.AppendLine('</' + LRoot + '>');
    Result := LXML.ToString;
  finally
    LXML.Free;
  end;
end;

function APIJSONUret(const ABaslik: TEBelgeBaslik; const AUBLXML: string): string;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  try
    LJSON.AddPair('provider', 'IZIBIZ');
    LJSON.AddPair('direction', 'OUTBOUND');
    if ABaslik.Tur = EBelgeTuruEIrsaliye then
      LJSON.AddPair('documentType', 'DESPATCHADVICE')
    else
      LJSON.AddPair('documentType', 'INVOICE');
    LJSON.AddPair('sourceId', IntToStr(ABaslik.ID));
    LJSON.AddPair('documentNo', ABaslik.FaturaNo);
    LJSON.AddPair('uuid', ABaslik.UUID);
    LJSON.AddPair('senderAlias', ABaslik.GondericiAlias);
    LJSON.AddPair('receiverAlias', ABaslik.AliciAlias);
    LJSON.AddPair('contentType', 'application/xml');
    LJSON.AddPair('contentEncoding', 'base64');
    LJSON.AddPair('content', TNetEncoding.Base64.EncodeBytesToString(
      TEncoding.UTF8.GetBytes(AUBLXML)));
    Result := LJSON.ToJSON;
  finally
    LJSON.Free;
  end;
end;

function HTMLUret(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar): string;
var
  LHTML: TStringBuilder;
  I: Integer;
  LBelgeTuru: string;
begin
  if ABaslik.Tur = EBelgeTuruEIrsaliye then
    LBelgeTuru := 'e-Irsaliye'
  else
    LBelgeTuru := 'e-Fatura';

  LHTML := TStringBuilder.Create;
  try
    LHTML.AppendLine('<!doctype html><html><head><meta charset="utf-8">');
    LHTML.AppendLine('<title>' + LBelgeTuru + ' ' +
      HTMLEscape(ABaslik.FaturaNo) + '</title>');
    LHTML.AppendLine('<style>body{font-family:Segoe UI,Arial;margin:32px;color:#222}' +
      'h1{margin-bottom:4px}.muted{color:#666}.box{border:1px solid #ddd;padding:16px;margin:18px 0}' +
      'table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:8px}' +
      'th{background:#f3f5f7;text-align:left}.num{text-align:right}</style></head><body>');
    LHTML.AppendLine('<h1>' + LBelgeTuru + '</h1><div class="muted">EBELGE ID: ' +
      IntToStr(ABaslik.EBelgeID) + ' | UUID: ' + HTMLEscape(ABaslik.UUID) +
      '</div>');
    LHTML.AppendLine('<div class="box"><b>Belge No:</b> ' +
      HTMLEscape(ABaslik.FaturaNo) + '<br><b>Tarih:</b> ' +
      FormatDateTime('dd.mm.yyyy hh:nn', ABaslik.Tarih) +
      '<br><b>Alici:</b> ' + HTMLEscape(ABaslik.Baslik) +
      '<br><b>VKN/TCKN:</b> ' + HTMLEscape(ABaslik.VergiNo) +
      '<br><b>Alias:</b> ' + HTMLEscape(ABaslik.AliciAlias) +
      '<br><b>Adres:</b> ' + HTMLEscape(ABaslik.Adres + ' ' +
      ABaslik.Ilce + ' ' + ABaslik.Il) + '</div>');
    LHTML.AppendLine('<table><thead><tr><th>No</th><th>Kod</th><th>Barkod</th><th>SUT</th><th>Lot</th><th>Seri</th><th>Urun/Hizmet</th>' +
      '<th class="num">Miktar</th><th class="num">Birim Fiyat</th>' +
      '<th class="num">KDV %</th><th class="num">Tutar</th></tr></thead><tbody>');
    for I := 0 to High(ASatirlar) do
      LHTML.AppendLine('<tr><td>' + IntToStr(ASatirlar[I].SatirNo) +
        '</td><td>' + HTMLEscape(ASatirlar[I].UrunKodu) + '</td><td>' +
        HTMLEscape(ASatirlar[I].Barkod) + '</td><td>' +
        HTMLEscape(ASatirlar[I].SutKodu) + '</td><td>' +
        HTMLEscape(ASatirlar[I].LotNo) + '</td><td>' +
        HTMLEscape(ASatirlar[I].SeriNo) + '</td><td>' +
        HTMLEscape(ASatirlar[I].UrunAdi) + '</td><td class="num">' +
        FormatFloat('#,##0.######', ASatirlar[I].Miktar) + ' ' +
        HTMLEscape(ASatirlar[I].BirimKodu) + '</td><td class="num">' +
        FormatFloat('#,##0.00####', ASatirlar[I].BirimFiyat) +
        '</td><td class="num">' + FormatFloat('#,##0.##',
        ASatirlar[I].KDVOrani) + '</td><td class="num">' +
        FormatFloat('#,##0.00', ASatirlar[I].Tutar) + '</td></tr>');
    LHTML.AppendLine('</tbody></table>');
    LHTML.AppendLine('<div class="box" style="text-align:right"><b>Matrah:</b> ' +
      FormatFloat('#,##0.00', ABaslik.Matrah) + ' ' + ABaslik.ParaBirimi +
      '<br><b>KDV:</b> ' + FormatFloat('#,##0.00', ABaslik.KDV) + ' ' +
      ABaslik.ParaBirimi + '<br><b>Toplam:</b> ' +
      FormatFloat('#,##0.00', ABaslik.Toplam) + ' ' +
      ABaslik.ParaBirimi + '</div>');
    if Trim(ABaslik.Aciklama) <> '' then
      LHTML.AppendLine('<div class="box"><b>Aciklama:</b><br>' +
        HTMLEscape(ABaslik.Aciklama) + '</div>');
    LHTML.AppendLine('</body></html>');
    Result := LHTML.ToString;
  finally
    LHTML.Free;
  end;
end;

function BelgeXSLTGetir(ARehberID, ABelgeTuru: Integer;
  AEArsivMi, AGelenMi: Boolean; out AXSLT: string): Boolean;
// AGelenMi=True ise gelen XSLT opsiyonlari, False ise giden opsiyonlari kullanilir.
// REHBERBILGI per-cari override sadece giden tarafi icin uygulanir (cari'nin
// kendi sabloni alici tarafa onerme istegidir).
var
  LXSLTID, LSira: Integer;
  LXSLTAdi: string;
begin
  Result := False;
  AXSLT := '';
  LXSLTAdi := '';
  if ABelgeTuru = EBelgeTuruEIrsaliye then
    LSira := 151
  else if AEArsivMi then
    LSira := 150
  else
    LSira := 140;

  // REHBERBILGI per-cari sablon override sadece GIDEN icin gecerli.
  if (not AGelenMi) and (ARehberID > 0) then begin
    Tablo.TablodanSorguAc(1,
      'select top 1 BILGI from REHBERBILGI where YERI=2 and SIRA=' +
      IntToStr(LSira) + ' and YER_ID=' + IntToStr(ARehberID));
    if not Tablo.Query1.Eof then
      LXSLTAdi := Trim(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Close;
    if LXSLTAdi <> '' then begin
      Tablo.TablodanSorguAc(1,
        'select top 1 SQL from DOKUMLER where GRUBU=''XSLT'' and RAPORADI=' +
        QuotedStr(LXSLTAdi) + ' order by ID desc');
      if not Tablo.Query1.Eof then
        AXSLT := Tablo.Query1.Fields[0].AsString;
      Tablo.Query1.Close;
    end;
  end;

  if Trim(AXSLT) = '' then begin
    // Gelen XSLT opsiyonlari Utablo cache'ine alinmiyor; GENINI'den dogrudan
    // okunur (giden tarafi mevcut Varsayilan* globallerini kullanmaya devam eder).
    if AGelenMi then begin
      if ABelgeTuru = EBelgeTuruEIrsaliye then
        LXSLTID := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EIrsaliyeGelenXSLT, 0)
      else if AEArsivMi then
        LXSLTID := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EArsivFaturaGelenXSLT, 0)
      else
        LXSLTID := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EFaturaGelenXSLT, 0);
    end else begin
      if ABelgeTuru = EBelgeTuruEIrsaliye then
        LXSLTID := VarsayilanEIrsaliyeXSLT
      else if AEArsivMi then
        LXSLTID := VarsayilanEArsivFaturaXSLT
      else
        LXSLTID := VarsayilanEFaturaXSLT;
    end;
    if LXSLTID > 0 then begin
      Tablo.TablodanSorguAc(1,
        'select SQL from DOKUMLER where ID=' + IntToStr(LXSLTID) +
        ' and GRUBU=''XSLT''' );
      if not Tablo.Query1.Eof then
        AXSLT := Tablo.Query1.Fields[0].AsString;
      Tablo.Query1.Close;
    end;
  end;

  Result := Trim(AXSLT) <> '';
end;

function XSLTOnizlemeUret(ARehberID, ABelgeTuru: Integer;
  AEArsivMi, AGelenMi: Boolean; const AUBLXML: string): string;
var
  LXSLT: string;
  LXMLBelgesi, LXSLTBelgesi: OleVariant;
begin
  Result := '';
  if Trim(AUBLXML) = '' then
    Exit;
  if not BelgeXSLTGetir(ARehberID, ABelgeTuru, AEArsivMi, AGelenMi, LXSLT) then
    Exit;

  try
    LXMLBelgesi := CreateOleObject('Msxml2.DOMDocument.6.0');
    LXMLBelgesi.async := False;
    LXMLBelgesi.validateOnParse := False;
    LXMLBelgesi.resolveExternals := False;
    if not LXMLBelgesi.loadXML(AUBLXML) then
      Exit;

    LXSLTBelgesi := CreateOleObject('Msxml2.DOMDocument.6.0');
    LXSLTBelgesi.async := False;
    LXSLTBelgesi.validateOnParse := False;
    LXSLTBelgesi.resolveExternals := False;
    if not LXSLTBelgesi.loadXML(LXSLT) then
      Exit;

    Result := LXMLBelgesi.transformNode(LXSLTBelgesi);
  except
    Result := '';
  end;
end;

procedure EBelgeGuncelle(AConnection: TFDConnection;
  const ABaslik: TEBelgeBaslik; const AAPIJSON, AUBLXML: string;
  AKullanan: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConnection;
    LQuery.ResourceOptions.MacroCreate := False;
    LQuery.SQL.Text :=
      'update EBELGE set REHBERID=:REHBERID, UUID=:UUID, BELGENO=:BELGENO, ' +
      'GONDERICIALIAS=:GONDERICIALIAS, ALICIALIAS=:ALICIALIAS, DURUM=1, ' +
      'API_JSON=cast(:API_JSON as nvarchar(max)), ' +
      'UBL_XML=cast(:UBL_XML as nvarchar(max)), DEGISTIREN=:DEGISTIREN, ' +
      'DEGISTIRMETARIHI=getdate() where ID=:ID';
    LQuery.ParamByName('REHBERID').AsInteger := ABaslik.RehberID;
    LQuery.ParamByName('UUID').AsString := ABaslik.UUID;
    LQuery.ParamByName('BELGENO').AsString := ABaslik.FaturaNo;
    LQuery.ParamByName('GONDERICIALIAS').AsString := ABaslik.GondericiAlias;
    LQuery.ParamByName('ALICIALIAS').AsString := ABaslik.AliciAlias;
    LQuery.ParamByName('API_JSON').DataType := ftWideMemo;
    LQuery.ParamByName('API_JSON').Size := Length(AAPIJSON);
    LQuery.ParamByName('API_JSON').AsWideMemo := AAPIJSON;
    LQuery.ParamByName('UBL_XML').DataType := ftWideMemo;
    LQuery.ParamByName('UBL_XML').Size := Length(AUBLXML);
    LQuery.ParamByName('UBL_XML').AsWideMemo := AUBLXML;
    LQuery.ParamByName('DEGISTIREN').AsInteger := AKullanan;
    LQuery.ParamByName('ID').AsLargeInt := ABaslik.EBelgeID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function EBelgeEkle(AConnection: TFDConnection;
  const ABaslik: TEBelgeBaslik; const AAPIJSON, AUBLXML: string;
  AKullanan: Integer): Int64;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConnection;
    LQuery.ResourceOptions.MacroCreate := False;
    LQuery.SQL.Text :=
      'insert into EBELGE(FATBASLIKID,REHBERID,BELGETURU,YON,UUID,BELGENO,' +
      'GONDERICIALIAS,ALICIALIAS,DURUM,API_JSON,UBL_XML,EKLEYEN) values(' +
      ':FATBASLIKID,:REHBERID,:BELGETURU,1,:UUID,:BELGENO,:GONDERICIALIAS,' +
      ':ALICIALIAS,1,cast(:API_JSON as nvarchar(max)),' +
      'cast(:UBL_XML as nvarchar(max)),:EKLEYEN); ' +
      'select cast(scope_identity() as bigint) as ID';
    LQuery.ParamByName('FATBASLIKID').AsInteger := ABaslik.ID;
    LQuery.ParamByName('REHBERID').AsInteger := ABaslik.RehberID;
    LQuery.ParamByName('BELGETURU').AsInteger := ABaslik.EBelgeBelgeTuru;
    LQuery.ParamByName('UUID').AsString := ABaslik.UUID;
    LQuery.ParamByName('BELGENO').AsString := ABaslik.FaturaNo;
    LQuery.ParamByName('GONDERICIALIAS').AsString := ABaslik.GondericiAlias;
    LQuery.ParamByName('ALICIALIAS').AsString := ABaslik.AliciAlias;
    LQuery.ParamByName('API_JSON').DataType := ftWideMemo;
    LQuery.ParamByName('API_JSON').Size := Length(AAPIJSON);
    LQuery.ParamByName('API_JSON').AsWideMemo := AAPIJSON;
    LQuery.ParamByName('UBL_XML').DataType := ftWideMemo;
    LQuery.ParamByName('UBL_XML').Size := Length(AUBLXML);
    LQuery.ParamByName('UBL_XML').AsWideMemo := AUBLXML;
    LQuery.ParamByName('EKLEYEN').AsInteger := AKullanan;
    LQuery.Open;
    Result := LQuery.FieldByName('ID').AsLargeInt;
  finally
    LQuery.Free;
  end;
end;

class function TEBelgeOlusturucu.Olustur(AConnection: TFDConnection;
  AFatBaslikID: Integer; const AAliciAlias: string;
  ABelgeTuruOverride: Integer = 0): Int64;
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LUBLXML, LAPIJSON, LGondericiVergiNo, LGondericiUnvan: string;
  LKullanan: Integer;
  LOwnTransaction: Boolean;
  LSevk: TSevkBilgisi;
  LSevkHata: string;
begin
  VerileriOku(AFatBaslikID, LBaslik, LSatirlar);
  if Trim(LBaslik.FaturaNo) = '' then
    raise Exception.Create('Belge numarasi bulunamadi.');
  if Length(LSatirlar) = 0 then
    raise Exception.Create('Belge detayi bulunamadi.');

  // ABelgeTuruOverride = RAlias kodu (140/141/150/151).
  // FATBASLIK.TUR (14/15) degismez ? uygulamadaki belge tipi kodu olarak kalir.
  // EBELGE.BELGETURU bu RAlias kodu olarak saklanir.
  if ABelgeTuruOverride > 0 then begin
    LBaslik.EBelgeBelgeTuru := ABelgeTuruOverride;
    LBaslik.EArsivMi := ABelgeTuruOverride = RAlias_EArsiv;
  end;
  if LBaslik.EBelgeBelgeTuru = 0 then begin
    // Olusturucu cagrildi ama override gelmedi ? FATBASLIK.TUR'a gore varsayilan
    if LBaslik.Tur = EBelgeTuruEIrsaliye then
      LBaslik.EBelgeBelgeTuru := RAlias_EIrsaliyeKendi
    else
      LBaslik.EBelgeBelgeTuru := RAlias_EFatura;
  end;
  if Trim(AAliciAlias) <> '' then
    LBaslik.AliciAlias := AAliciAlias;
  if Trim(LBaslik.GondericiAlias) = '' then
    LBaslik.GondericiAlias := GondericiAliasGetir(LBaslik.Tur);
  if Trim(LBaslik.UUID) = '' then
    LBaslik.UUID := YeniUUID;

  LGondericiVergiNo := Tablo.GENINI.ReadString(
    Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LGondericiUnvan := KURUMADI;
  LUBLXML := UBLXMLUret(LBaslik, LSatirlar, LGondericiVergiNo,
    LGondericiUnvan);
  LAPIJSON := APIJSONUret(LBaslik, LUBLXML);
  LKullanan := StrToIntDef(Kullanan, 0);

  LOwnTransaction := not AConnection.InTransaction;
  if LOwnTransaction then
    AConnection.StartTransaction;
  try
    if LBaslik.EBelgeID > 0 then begin
      EBelgeGuncelle(AConnection, LBaslik, LAPIJSON, LUBLXML, LKullanan);
      Result := LBaslik.EBelgeID;
    end else
      Result := EBelgeEkle(AConnection, LBaslik, LAPIJSON, LUBLXML,
        LKullanan);
    if Result = 0 then
      raise Exception.Create('EBELGE kayit ID bilgisi alinamadi.');

    Veritabani.BasitKomutÇalıştır(AConnection,
      'insert into EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,' +
      'EKLEYEN) values(~P1~,1,1,1,~P2~,~P3~)',
      ['~P1~', '~P2~', '~P3~'],
      [Result, 'UBL/XML ve Izibiz kuyruk JSON bilgisi olusturuldu.',
       LKullanan]);

    if LOwnTransaction then
      AConnection.Commit;
  except
    if LOwnTransaction and AConnection.InTransaction then
      AConnection.Rollback;
    raise;
  end;
end;

class procedure TEBelgeOlusturucu.Onizle(AConnection: TFDConnection;
  AFatBaslikID: Integer);
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LDosya, LHTML, LUBLXML, LGondericiVergiNo, LGondericiUnvan: string;
  LSonuc: HINST;
begin
  VerileriOku(AFatBaslikID, LBaslik, LSatirlar);
  if LBaslik.EBelgeID = 0 then
    raise Exception.Create('Onizleme icin once e-belgeyi olusturun.');
  if Trim(LBaslik.UUID) = '' then
    raise Exception.Create('Olusturulmus e-belgenin UUID bilgisi bulunamadi.');

  LGondericiVergiNo := Tablo.GENINI.ReadString(
    Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LGondericiUnvan := KURUMADI;
  LUBLXML := UBLXMLUret(LBaslik, LSatirlar, LGondericiVergiNo,
    LGondericiUnvan);

  // Giden onizleme/yazdir: AGelenMi=False
  LHTML := XSLTOnizlemeUret(LBaslik.RehberID, LBaslik.Tur,
                            LBaslik.EArsivMi, False, LUBLXML);
  if Trim(LHTML) = '' then
    LHTML := HTMLUret(LBaslik, LSatirlar);
  LDosya := TPath.Combine(TPath.GetTempPath,
    'Gentegre_EBelge_' + IntToStr(AFatBaslikID) + '.html');
  TFile.WriteAllText(LDosya, LHTML, TEncoding.UTF8);
  LSonuc := ShellExecute(0, 'open', PChar(LDosya), nil, nil, SW_SHOWNORMAL);
  if LSonuc <= 32 then
    raise Exception.Create('E-belge onizleme dosyasi acilamadi.');
end;


class procedure TEBelgeOlusturucu.XMLKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LUBLXML, LGondericiVergiNo, LGondericiUnvan: string;
begin
  VerileriOku(AFatBaslikID, LBaslik, LSatirlar);
  if LBaslik.EBelgeID = 0 then
    raise Exception.Create('XML icin once e-belgeyi olusturun.');

  LGondericiVergiNo := Tablo.GENINI.ReadString(
    Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LGondericiUnvan := KURUMADI;
  LUBLXML := UBLXMLUret(LBaslik, LSatirlar, LGondericiVergiNo,
    LGondericiUnvan);

  TFile.WriteAllText(ADosya, LUBLXML, TEncoding.UTF8);
end;

class procedure TEBelgeOlusturucu.HTMLKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
// ?nizle ile ayn? HTML ?retimi � ama belirtilen dosyaya kaydeder, a?maz.
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LHTML, LUBLXML, LGondericiVergiNo, LGondericiUnvan: string;
begin
  VerileriOku(AFatBaslikID, LBaslik, LSatirlar);
  if LBaslik.EBelgeID = 0 then
    raise Exception.Create('HTML icin once e-belgeyi olusturun.');

  LGondericiVergiNo := Tablo.GENINI.ReadString(
    Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LGondericiUnvan := KURUMADI;
  LUBLXML := UBLXMLUret(LBaslik, LSatirlar, LGondericiVergiNo,
    LGondericiUnvan);

  // Giden onizleme/yazdir: AGelenMi=False
  LHTML := XSLTOnizlemeUret(LBaslik.RehberID, LBaslik.Tur,
                            LBaslik.EArsivMi, False, LUBLXML);
  if Trim(LHTML) = '' then
    LHTML := HTMLUret(LBaslik, LSatirlar);

  TFile.WriteAllText(ADosya, LHTML, TEncoding.UTF8);
end;

class procedure TEBelgeOlusturucu.PDFKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
// HTML ?retilip ge?ici dosyaya yaz?l?r � headless Edge ile PDF'e d?n??t?r?l?r.
// Edge Windows 10+'da varsay?lan olarak y?kl?; bulunamazsa Chrome denenir.
var
  LTempHTML, LEdge, LKomut: string;
  LStartInfo: TStartupInfo;
  LProcInfo: TProcessInformation;
begin
  LTempHTML := TPath.Combine(TPath.GetTempPath,
    'Gentegre_EBelge_PDF_' + IntToStr(AFatBaslikID) + '.html');
  HTMLKaydet(AConnection, AFatBaslikID, LTempHTML);

  // Edge yolu
  LEdge := 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe';
  if not FileExists(LEdge) then
    LEdge := 'C:\Program Files\Microsoft\Edge\Application\msedge.exe';
  if not FileExists(LEdge) then begin
    // Chrome'a d??
    LEdge := 'C:\Program Files\Google\Chrome\Application\chrome.exe';
    if not FileExists(LEdge) then
      LEdge := 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe';
  end;
  if not FileExists(LEdge) then begin
    try TFile.Delete(LTempHTML); except end;
    raise Exception.Create(
      'PDF olusturmak icin Microsoft Edge veya Google Chrome kurulu olmalidir.');
  end;

  // Headless mode ile HTML�PDF
  LKomut := '"' + LEdge + '" --headless --disable-gpu --no-margins ' +
            '--print-to-pdf="' + ADosya + '" "' + LTempHTML + '"';

  FillChar(LStartInfo, SizeOf(LStartInfo), 0);
  LStartInfo.cb := SizeOf(LStartInfo);
  LStartInfo.dwFlags := STARTF_USESHOWWINDOW;
  LStartInfo.wShowWindow := SW_HIDE;
  if not CreateProcess(nil, PChar(LKomut), nil, nil, False, 0, nil, nil,
                       LStartInfo, LProcInfo) then begin
    try TFile.Delete(LTempHTML); except end;
    raise Exception.Create('PDF olusturma islemi baslatilamadi.');
  end;
  try
    WaitForSingleObject(LProcInfo.hProcess, 60000);   // max 60 sn
  finally
    CloseHandle(LProcInfo.hThread);
    CloseHandle(LProcInfo.hProcess);
  end;

  try TFile.Delete(LTempHTML); except end;

  if not FileExists(ADosya) then
    raise Exception.Create('PDF dosyasi olusturulamadi.');
end;

// ---- Izibiz JSON body uretici (sadelestirilmis) ----
function _IzibizJSONOlustur(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar;
  const AGondericiTaraf: TEBelgeTaraf): string;
var
  LRoot, LContent, LSupplier, LSupplierAdr, LCustomer, LTax, LTaxSub, LTaxScheme,
    LMonetary, LLine, LLineTax, LLineTaxSub, LLineTaxScheme: TJSONObject;
  LNotes, LLines, LTaxSubArr, LLineTaxSubArr, LAddRefs: TJSONArray;
  LAddRefSend: TJSONObject;
  i, LBosluk: Integer;
  LToplamMatrah, LToplamKDV: Currency;
  LSatir: TEBelgeSatir;
  LIsArsiv, LIsIrsaliye: Boolean;
  LAd, LSoyad, LProfil, LCustSeli, LTrimmed, LDocTypeCode: string;
  LSevk: TSevkBilgisi;
  LTasiyici: TEBelgeTaraf;
begin
  LIsIrsaliye := ABaslik.Tur = EBelgeTuruEIrsaliye;
  LIsArsiv := ABaslik.EArsivMi;
  if LIsIrsaliye then begin
    LProfil := 'TEMELIRSALIYE';
    LDocTypeCode := 'SEVK';
  end else begin
    LDocTypeCode := 'SATIS';
    if LIsArsiv then LProfil := 'EARSIVFATURA' else LProfil := 'TEMELFATURA';
  end;

  LSevk := Default(TSevkBilgisi);
  LTasiyici := Default(TEBelgeTaraf);
  if LIsIrsaliye then begin
    LSevk := SevkBilgisiGetir(ABaslik.ID);
    LTasiyici := SevkTasiyiciTaraf(LSevk, AGondericiTaraf);
  end;
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair('documentAction', 'SEND');
    // Postman ornegine gore string "true"/"false" gonderiliyor (bool degil)
    LRoot.AddPair('assignNumber',
                  IfThen(Trim(ABaslik.FaturaNo) = '', 'true', 'false'));
    LRoot.AddPair('seriePrefix', Copy(ABaslik.FaturaNo, 1, 3));
    if LIsIrsaliye then
      LRoot.AddPair('compressed', 'false')   // irsaliye base64 olarak parse edilmesin
    else
      LRoot.AddPair('xsltName', 'DEFAULT');

    LContent := TJSONObject.Create;
    LContent.AddPair('profile', LProfil);
    LContent.AddPair('documentTypeCode', LDocTypeCode);
    if Trim(ABaslik.FaturaNo) <> '' then
      LContent.AddPair('documentNo', ABaslik.FaturaNo);
    if Trim(ABaslik.UUID) <> '' then
      LContent.AddPair('uuid', ABaslik.UUID)
    else
      LContent.AddPair('uuid', YeniUUID);
    LContent.AddPair('issueDate', FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
    LContent.AddPair('issueTime', FormatDateTime('hh:nn:ss', ABaslik.Tarih));
    LNotes := TJSONArray.Create;
    LContent.AddPair('notes', LNotes);
    LContent.AddPair('currencyCode', IfThen(Trim(ABaslik.ParaBirimi) = '', 'TRY', ABaslik.ParaBirimi));

    // Supplier (gonderici = bizim firma)
    LSupplier := TJSONObject.Create;
    LSupplier.AddPair('name', AGondericiTaraf.Unvan);
    LSupplier.AddPair('identifier', AGondericiTaraf.VergiNo);
    LSupplier.AddPair('schemeId', KimlikSemasi(AGondericiTaraf.VergiNo));
    if Trim(AGondericiTaraf.VergiDairesi) <> '' then
      LSupplier.AddPair('taxOffice', AGondericiTaraf.VergiDairesi);
    LSupplierAdr := TJSONObject.Create;
    LSupplierAdr.AddPair('country', 'TR');
    if Trim(AGondericiTaraf.Il) <> '' then
      LSupplierAdr.AddPair('city', AGondericiTaraf.Il);
    if Trim(AGondericiTaraf.Ilce) <> '' then
      LSupplierAdr.AddPair('subCity', AGondericiTaraf.Ilce);
    if Trim(AGondericiTaraf.Adres) <> '' then
      LSupplierAdr.AddPair('streetName', AGondericiTaraf.Adres);
    if Trim(AGondericiTaraf.PostaKodu) <> '' then
      LSupplierAdr.AddPair('postalCode', AGondericiTaraf.PostaKodu);
    LSupplier.AddPair('address', LSupplierAdr);
    LContent.AddPair('supplierParty', LSupplier);

    // EArsiv'e ozel: additionalReferences ? gonderim tipi ELEKTRONIK
    if LIsArsiv then begin
      LAddRefs := TJSONArray.Create;
      LAddRefSend := TJSONObject.Create;
      LAddRefSend.AddPair('documentTypeCode', 'SendingType');
      LAddRefSend.AddPair('documentType', 'ELEKTRONIK');
      LAddRefSend.AddPair('id', '1');
      LAddRefSend.AddPair('issueDate',
                          FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
      LAddRefs.AddElement(LAddRefSend);
      LContent.AddPair('additionalReferences', LAddRefs);
    end;

    // EIrsaliye'ye ozel: additionalReferences ? XSLT inline base64
    if LIsIrsaliye then begin
      var LXSLT: string := '';
      if BelgeXSLTGetir(ABaslik.RehberID, ABaslik.Tur, ABaslik.EArsivMi, False, LXSLT) then begin
        var LAddXslt: TJSONObject := TJSONObject.Create;
        LAddXslt.AddPair('documentType', 'XSLT');
        LAddXslt.AddPair('id', YeniUUID);
        LAddXslt.AddPair('issueDate',
                         FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
        var LAttach: TJSONObject := TJSONObject.Create;
        LAttach.AddPair('characterSetCode', 'UTF-8');
        LAttach.AddPair('encodingCode', 'Base64');
        LAttach.AddPair('filename', ABaslik.FaturaNo + '.xslt');
        LAttach.AddPair('mimeCode', 'application/xml');
        LAttach.AddPair('content', TNetEncoding.Base64.EncodeBytesToString(
          TEncoding.UTF8.GetBytes(LXSLT)));
        LAddXslt.AddPair('attachment', LAttach);
        LAddRefs := TJSONArray.Create;
        LAddRefs.AddElement(LAddXslt);
        LContent.AddPair('additionalReferences', LAddRefs);
      end;
    end;

    // Customer (alici)
    LCustomer := TJSONObject.Create;
    LCustSeli := KimlikSemasi(ABaslik.VergiNo);
    // EIrsaliye'de de schemeId aciktan yazilir (yoksa Izibiz uzunluktan tahmin eder)
    LCustomer.AddPair('schemeId', LCustSeli);
    LCustomer.AddPair('identifier', ABaslik.VergiNo);
    if SameText(LCustSeli, 'TCKN') and (LIsArsiv or LIsIrsaliye) then begin
      // Baslik'tan ad/soyad ayir: ilk kelime AD, gerisi SOYAD
      LTrimmed := Trim(ABaslik.Baslik);
      LBosluk := Pos(' ', LTrimmed);
      if LBosluk > 0 then begin
        LAd := Trim(Copy(LTrimmed, 1, LBosluk - 1));
        LSoyad := Trim(Copy(LTrimmed, LBosluk + 1, MaxInt));
      end else begin
        LAd := LTrimmed;
        LSoyad := LTrimmed;
      end;
      LCustomer.AddPair('firstName', LAd);
      LCustomer.AddPair('lastName', LSoyad);
    end else begin
      LCustomer.AddPair('name', ABaslik.Baslik);
      // EIrsaliye taxOffice'i de gonderebilir
      if Trim(ABaslik.VergiDairesi) <> '' then
        LCustomer.AddPair('taxOffice', ABaslik.VergiDairesi);
    end;
    // Address ? Postman ornegine gore VARSAYILAN olarak gonderilir (Izibiz NPE atmasin)
    var LCustomerAdr: TJSONObject := TJSONObject.Create;
    LCustomerAdr.AddPair('country', 'TR');
    if Trim(ABaslik.Il) <> '' then
      LCustomerAdr.AddPair('city', ABaslik.Il);
    if Trim(ABaslik.Ilce) <> '' then
      LCustomerAdr.AddPair('subCity', ABaslik.Ilce);
    if Trim(ABaslik.Adres) <> '' then
      LCustomerAdr.AddPair('streetName', ABaslik.Adres);
    // EArsiv: aliciAlias mail adresidir, Izibiz buradan iletim yapar
    if LIsArsiv and (Trim(ABaslik.AliciAlias) <> '') then
      LCustomerAdr.AddPair('email', Trim(ABaslik.AliciAlias));
    LCustomer.AddPair('address', LCustomerAdr);
    LContent.AddPair('customerParty', LCustomer);

    // Tax / Monetary ? sadece fatura/arsiv icin (irsaliyede yok)
    if not LIsIrsaliye then begin
      LToplamMatrah := ABaslik.Matrah;
      LToplamKDV := ABaslik.KDV;
      var LRootPercent: Double := 0;
      if LToplamMatrah > 0.001 then
        LRootPercent := Round(LToplamKDV / LToplamMatrah * 100);
      LTax := TJSONObject.Create;
      LTax.AddPair('taxAmount', TJSONNumber.Create(LToplamKDV));
      LTaxSubArr := TJSONArray.Create;
      LTaxSub := TJSONObject.Create;
      LTaxSub.AddPair('calculationSequenceNumeric', TJSONNumber.Create(1));
      LTaxSub.AddPair('taxableAmount', TJSONNumber.Create(LToplamMatrah));
      LTaxSub.AddPair('percent', TJSONNumber.Create(LRootPercent));
      LTaxSub.AddPair('taxAmount', TJSONNumber.Create(LToplamKDV));
      LTaxScheme := TJSONObject.Create;
      LTaxScheme.AddPair('name', 'KDV');
      if LRootPercent < 0.001 then
        LTaxScheme.AddPair('typeCode', '9015')
      else
        LTaxScheme.AddPair('typeCode', '0015');
      LTaxSub.AddPair('taxScheme', LTaxScheme);
      LTaxSubArr.AddElement(LTaxSub);
      LTax.AddPair('taxSubTotal', LTaxSubArr);
      LContent.AddPair('taxTotal', LTax);

      LMonetary := TJSONObject.Create;
      LMonetary.AddPair('lineExtensionAmount', TJSONNumber.Create(LToplamMatrah));
      LMonetary.AddPair('taxExclusiveAmount', TJSONNumber.Create(LToplamMatrah));
      LMonetary.AddPair('taxInclusiveAmount', TJSONNumber.Create(ABaslik.Toplam));
      LMonetary.AddPair('payableAmount', TJSONNumber.Create(ABaslik.Toplam));
      LContent.AddPair('legalMonetaryTotal', LMonetary);
    end else begin
      // E-Irsaliye: shipment blogu
      var LShipment: TJSONObject := TJSONObject.Create;
      LShipment.AddPair('id', TJSONNumber.Create(1));

      var LGoods: TJSONArray := TJSONArray.Create;
      var LGood: TJSONObject := TJSONObject.Create;
      LGood.AddPair('currencyId', IfThen(Trim(ABaslik.ParaBirimi) = '', 'TRY', ABaslik.ParaBirimi));
      LGood.AddPair('valueAmount', TJSONNumber.Create(ABaslik.Matrah));
      LGoods.AddElement(LGood);
      LShipment.AddPair('goodsItems', LGoods);

      var LStages: TJSONArray := TJSONArray.Create;
      var LStage: TJSONObject := TJSONObject.Create;
      if Trim(LSevk.Plaka) <> '' then
        LStage.AddPair('licensePlateID', LSevk.Plaka);
      if Trim(LSevk.DorsePlaka) <> '' then
        LStage.AddPair('trailerPlateID', LSevk.DorsePlaka);
      if (Trim(LSevk.SoforAdi) <> '') or (Trim(LSevk.SoforSoyadi) <> '') or
         (Trim(LSevk.SoforTckn) <> '') then begin
        var LDriver: TJSONObject := TJSONObject.Create;
        if Trim(LSevk.SoforAdi) <> '' then
          LDriver.AddPair('firstName', Trim(LSevk.SoforAdi + ' ' + LSevk.SoforSoyadi));
        if Trim(LSevk.SoforTckn) <> '' then begin
          LDriver.AddPair('identifier', LSevk.SoforTckn);
          LDriver.AddPair('identifierSchemeID', 'TCKN');
        end;
        LDriver.AddPair('title', 'Surucu');
        LDriver.AddPair('nationalityID', 'TR');
        LStage.AddPair('driverPerson', LDriver);
      end;
      if (Trim(LTasiyici.Unvan) <> '') or (Trim(LTasiyici.VergiNo) <> '') then begin
        var LCarrier: TJSONObject := TJSONObject.Create;
        if Trim(LTasiyici.Unvan) <> '' then
          LCarrier.AddPair('name', LTasiyici.Unvan);
        if Trim(LTasiyici.VergiNo) <> '' then begin
          LCarrier.AddPair('identifier', LTasiyici.VergiNo);
          LCarrier.AddPair('schemeId', KimlikSemasi(LTasiyici.VergiNo));
        end;
        LStage.AddPair('carrierParty', LCarrier);
      end;
      LStages.AddElement(LStage);
      LShipment.AddPair('shipmentStages', LStages);

      var LDelivery: TJSONObject := TJSONObject.Create;
      var LDelAdr: TJSONObject := TJSONObject.Create;
      LDelAdr.AddPair('country', 'TR');
      if Trim(ABaslik.Il) <> '' then LDelAdr.AddPair('city', ABaslik.Il);
      if Trim(ABaslik.Ilce) <> '' then LDelAdr.AddPair('subCity', ABaslik.Ilce);
      if Trim(ABaslik.Adres) <> '' then LDelAdr.AddPair('streetName', ABaslik.Adres);
      LDelAdr.AddPair('postalZone', '34000');
      LDelivery.AddPair('deliveryAddress', LDelAdr);

      var LDespatch: TJSONObject := TJSONObject.Create;
      LDespatch.AddPair('actualDespatchDate', FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
      LDespatch.AddPair('actualDespatchTime', FormatDateTime('hh:nn:ss', ABaslik.Tarih));
      LDelivery.AddPair('despatch', LDespatch);

      LShipment.AddPair('delivery', LDelivery);
      LContent.AddPair('shipment', LShipment);
    end;

    // Lines
    LLines := TJSONArray.Create;
    for i := 0 to Length(ASatirlar) - 1 do begin
      LSatir := ASatirlar[i];
      LLine := TJSONObject.Create;
      LLine.AddPair('id', TJSONNumber.Create(LSatir.SatirNo));
      LLine.AddPair('quantity', TJSONNumber.Create(LSatir.Miktar));
      LLine.AddPair('unitCode', IfThen(LSatir.BirimKodu = '', 'C62', LSatir.BirimKodu));
      LLine.AddPair('lineExtensionAmount', TJSONNumber.Create(LSatir.Tutar));
      LLine.AddPair('itemName', LSatir.UrunAdi);
      LLine.AddPair('itemPrice', TJSONNumber.Create(LSatir.BirimFiyat));
      if LIsIrsaliye then begin
        LLine.AddPair('currencyId',
          IfThen(Trim(ABaslik.ParaBirimi) = '', 'TRY', ABaslik.ParaBirimi));
        LLines.AddElement(LLine);
        Continue;
      end;
      // line tax ? sadece fatura/arsiv
      LLineTax := TJSONObject.Create;
      LLineTax.AddPair('taxAmount', TJSONNumber.Create(LSatir.Tutar * LSatir.KDVOrani / 100));
      LLineTaxSubArr := TJSONArray.Create;
      LLineTaxSub := TJSONObject.Create;
      LLineTaxSub.AddPair('taxableAmount', TJSONNumber.Create(LSatir.Tutar));
      LLineTaxSub.AddPair('taxAmount', TJSONNumber.Create(LSatir.Tutar * LSatir.KDVOrani / 100));
      LLineTaxSub.AddPair('calculationSequenceNumeric', TJSONNumber.Create(1));
      LLineTaxSub.AddPair('percent', TJSONNumber.Create(LSatir.KDVOrani));
      LLineTaxScheme := TJSONObject.Create;
      LLineTaxScheme.AddPair('name', 'KDV');
      if LSatir.KDVOrani < 0.001 then
        LLineTaxScheme.AddPair('typeCode', '9015')
      else
        LLineTaxScheme.AddPair('typeCode', '0015');
      LLineTaxSub.AddPair('taxScheme', LLineTaxScheme);
      LLineTaxSubArr.AddElement(LLineTaxSub);
      LLineTax.AddPair('taxSubTotal', LLineTaxSubArr);
      LLine.AddPair('taxTotal', LLineTax);
      LLines.AddElement(LLine);
    end;
    LContent.AddPair('lines', LLines);

    LRoot.AddPair('content', LContent);
    Result := LRoot.ToJSON;
  finally
    LRoot.Free;
  end;
end;

class function TEBelgeOlusturucu.Gonder(AConnection: TFDConnection;
  AFatBaslikID: Integer; const AKullanici, ASifre, ABaseURL: string;
  ATestModu: Boolean; out AYanitMesaj: string): Boolean;
// Izibiz REST entegrasyonu: Login -> SendInvoice -> DB update.
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LEBelgeID: Int64;
  LKullanan: Integer;
  LOwnTransaction: Boolean;
  LSessionID, LHata, LBody, LYol, LGondericiVKN, LGondericiUnvan: string;
  LSonuc: TIzibizGonderimSonuc;
begin
  Result := False;
  AYanitMesaj := '';
  VerileriOku(AFatBaslikID, LBaslik, LSatirlar);
  if LBaslik.EBelgeID = 0 then
    raise Exception.Create('Gonderim icin once e-belgeyi olusturun.');

  LEBelgeID := LBaslik.EBelgeID;
  LKullanan := StrToIntDef(Kullanan, 0);
  LGondericiVKN := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LGondericiUnvan := KURUMADI;

  // 1) Login � Basic Auth + identifier(VKN) + name(firma)
  if not TIzibizRest.Login(ABaseURL, AKullanici, ASifre,
                           LGondericiVKN, LGondericiUnvan,
                           LSessionID, LHata) then begin
    AYanitMesaj := 'Login basarisiz: ' + LHata;
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
      'VALUES(&EID,1,2,9,&MSG,&KUL,GETDATE())',
      ['&EID', '&MSG', '&KUL'], [LEBelgeID, AYanitMesaj, LKullanan]);
    Exit;
  end;

  // 2) JSON body olustur � gonderici tarafini Tablo.TabBizim'den cek
  //    Test modunda gonderici VKN, Izibiz test hesabinin VKN'sine override edilir
  //    (Izibiz oturum acan hesabin VKN'si ile belge VKN'sinin uyusmasini bekliyor)
  var LGondericiTaraf: TEBelgeTaraf := BizimTarafGetir(LGondericiVKN, LGondericiUnvan);
  if ATestModu then
    LGondericiTaraf.VergiNo := LGondericiVKN;   // Ops_FaturaOpsiyon_EBelgeVergiNo (Izibiz test VKN)
  LBody := _IzibizJSONOlustur(LBaslik, LSatirlar, LGondericiTaraf);

  // 3) SendInvoice ? belge turune gore endpoint
  //   /v1/einvoices, /v1/earchives, /v2/edespatches/send (irsaliye v2 ve /send suffixli)
  if LBaslik.Tur = EBelgeTuruEIrsaliye then
    LYol := '/v2/edespatches/send'
  else if LBaslik.EArsivMi then
    LYol := '/v1/earchives'
  else
    LYol := '/v1/einvoices';

  // Login log
  Veritabani.BasitKomutÇalıştır(AConnection,
    'INSERT INTO EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
    'VALUES(&EID,1,2,1,&MSG,&KUL,GETDATE())',
    ['&EID', '&MSG', '&KUL'],
    [LEBelgeID,
     IfThen(ATestModu, 'TEST', 'URETIM') + ' modunda gonderim: ' + ABaseURL + LYol,
     LKullanan]);

  // Gonderilen JSON body'sini de log'la (debug � sorun cikan field'i tespit icin)
  Veritabani.BasitKomutÇalıştır(AConnection,
    'INSERT INTO EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
    'VALUES(&EID,1,2,3,&MSG,&KUL,GETDATE())',
    ['&EID', '&MSG', '&KUL'],
    [LEBelgeID, 'REQUEST BODY: ' + Copy(LBody, 1, 3500), LKullanan]);

  if not TIzibizRest.SendInvoice(ABaseURL, LSessionID, LYol, LBody, LSonuc) then begin
    AYanitMesaj := 'SendInvoice basarisiz: ' + LSonuc.Mesaj;
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,HTTPKODU,EKLEYEN,EKLEMETARIHI) ' +
      'VALUES(&EID,1,2,9,&MSG,&HK,&KUL,GETDATE())',
      ['&EID', '&MSG', '&HK', '&KUL'],
      [LEBelgeID, AYanitMesaj, LSonuc.HttpKodu, LKullanan]);
    // Gonderim teknik olarak basarisiz -> gridde Hata/Red olarak gorunsun.
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE FATBASLIK SET EFATURASONUC=3 WHERE ID=&ID', ['&ID'], [AFatBaslikID]);
    Exit;
  end;

  // 4) Basarili � DB guncelle
  LOwnTransaction := not AConnection.InTransaction;
  if LOwnTransaction then AConnection.StartTransaction;
  try
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO EBELGEMESAJ(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,HTTPKODU,SERVISKODU,EKLEYEN,EKLEMETARIHI) ' +
      'VALUES(&EID,1,2,2,&MSG,&HK,&SRV,&KUL,GETDATE())',
      ['&EID', '&MSG', '&HK', '&SRV', '&KUL'],
      [LEBelgeID, 'Gonderim basarili. UUID: ' + LSonuc.UUID,
       LSonuc.HttpKodu, IfThen(ATestModu, 'TEST', 'URETIM'), LKullanan]);

    if Trim(LSonuc.UUID) <> '' then
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE EBELGE SET UUID=&U, DURUM=2, DEGISTIREN=&KUL, DEGISTIRMETARIHI=GETDATE() WHERE ID=&EID',
        ['&U', '&KUL', '&EID'], [LSonuc.UUID, LKullanan, LEBelgeID])
    else
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE EBELGE SET DURUM=2, DEGISTIREN=&KUL, DEGISTIRMETARIHI=GETDATE() WHERE ID=&EID',
        ['&KUL', '&EID'], [LKullanan, LEBelgeID]);

    // Gonderim sonrasi durum: 1->2 (eFatura), 11->12 (eArsiv), 51->52 (eIrsaliye)
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE FATBASLIK SET EFATURADURUM = CASE EFATURADURUM ' +
      ' WHEN 1 THEN 2 WHEN 11 THEN 12 WHEN 51 THEN 52 ELSE EFATURADURUM END, ' +
      'EFATURASONUC=9 WHERE ID=&ID',
      ['&ID'], [AFatBaslikID]);

    if LOwnTransaction then AConnection.Commit;
    AYanitMesaj := LSonuc.Mesaj;
    if Trim(LSonuc.UUID) <> '' then AYanitMesaj := AYanitMesaj + ' UUID=' + LSonuc.UUID;
    Result := True;
  except
    on E: Exception do begin
      if LOwnTransaction and AConnection.InTransaction then AConnection.Rollback;
      AYanitMesaj := 'DB guncelleme hatasi: ' + E.Message;
    end;
  end;
end;

// ---- GELEN E-BELGE (YON=2) icin uretim ----

function _GelenUBLOku(AConnection: TFDConnection; AFatBaslikID: Integer;
  out ARehberID: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := '';
  ARehberID := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'SELECT TOP 1 cast(E.UBL_XML as nvarchar(max)) as UBLX, ' +
      '  isnull(FB.REHBERID, 0) as RID ' +
      'FROM EBELGE E ' +
      ' INNER JOIN FATBASLIK FB ON FB.ID = E.FATBASLIKID ' +
      'WHERE E.YON = 2 AND E.FATBASLIKID = :FID ' +
      'ORDER BY E.ID DESC';
    LQry.ParamByName('FID').AsInteger := AFatBaslikID;
    LQry.Open;
    if not LQry.Eof then begin
      Result := LQry.FieldByName('UBLX').AsString;
      ARehberID := LQry.FieldByName('RID').AsInteger;
    end;
    LQry.Close;
  finally
    LQry.Free;
  end;
end;

class procedure TEBelgeOlusturucu.OnizleGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer);
var
  LUBL, LHTML, LDosya: string;
  LRehberID: Integer;
  LSonuc: HINST;
begin
  LUBL := _GelenUBLOku(AConnection, AFatBaslikID, LRehberID);
  if Trim(LUBL) = '' then
    raise Exception.Create('Gelen e-belgenin UBL XML bilgisi bulunamadi.');

  // Gelen daima e-Fatura kabul (TUR=15, EArsivMi=False)
  // Gelen onizleme: AGelenMi=True -> gelen XSLT opsiyonu kullanilir
  LHTML := XSLTOnizlemeUret(LRehberID, EBelgeTuruEFatura, False, True, LUBL);
  if Trim(LHTML) = '' then
    raise Exception.Create('XSLT donusumu bos sonuc verdi (XSLT tanimli mi?).');

  LDosya := TPath.Combine(TPath.GetTempPath,
    'Gentegre_GelenEBelge_' + IntToStr(AFatBaslikID) + '.html');
  TFile.WriteAllText(LDosya, LHTML, TEncoding.UTF8);
  LSonuc := ShellExecute(0, 'open', PChar(LDosya), nil, nil, SW_SHOWNORMAL);
  if LSonuc <= 32 then
    raise Exception.Create('Gelen e-belge onizleme dosyasi acilamadi.');
end;

class procedure TEBelgeOlusturucu.XMLKaydetGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LUBL: string;
  LRehberID: Integer;
begin
  LUBL := _GelenUBLOku(AConnection, AFatBaslikID, LRehberID);
  if Trim(LUBL) = '' then
    raise Exception.Create('Gelen e-belgenin UBL XML bilgisi bulunamadi.');
  TFile.WriteAllText(ADosya, LUBL, TEncoding.UTF8);
end;

class procedure TEBelgeOlusturucu.HTMLKaydetGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LUBL, LHTML: string;
  LRehberID: Integer;
begin
  LUBL := _GelenUBLOku(AConnection, AFatBaslikID, LRehberID);
  if Trim(LUBL) = '' then
    raise Exception.Create('Gelen e-belgenin UBL XML bilgisi bulunamadi.');
  // Gelen onizleme: AGelenMi=True -> gelen XSLT opsiyonu kullanilir
  LHTML := XSLTOnizlemeUret(LRehberID, EBelgeTuruEFatura, False, True, LUBL);
  if Trim(LHTML) = '' then
    raise Exception.Create('XSLT donusumu bos sonuc verdi.');
  TFile.WriteAllText(ADosya, LHTML, TEncoding.UTF8);
end;

procedure _HTMLDosyaPDFeCevir(const ATempHTML, ADosya: string);
var
  LEdge, LKomut: string;
  LStartInfo: TStartupInfo;
  LProcInfo: TProcessInformation;
begin
  LEdge := 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe';
  if not FileExists(LEdge) then
    LEdge := 'C:\Program Files\Microsoft\Edge\Application\msedge.exe';
  if not FileExists(LEdge) then begin
    LEdge := 'C:\Program Files\Google\Chrome\Application\chrome.exe';
    if not FileExists(LEdge) then
      LEdge := 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe';
  end;
  if not FileExists(LEdge) then begin
    try TFile.Delete(ATempHTML); except end;
    raise Exception.Create(
      'PDF olusturmak icin Microsoft Edge veya Google Chrome kurulu olmalidir.');
  end;

  LKomut := '"' + LEdge + '" --headless --disable-gpu --no-margins ' +
            '--print-to-pdf="' + ADosya + '" "' + ATempHTML + '"';
  FillChar(LStartInfo, SizeOf(LStartInfo), 0);
  LStartInfo.cb := SizeOf(LStartInfo);
  LStartInfo.dwFlags := STARTF_USESHOWWINDOW;
  LStartInfo.wShowWindow := SW_HIDE;
  if not CreateProcess(nil, PChar(LKomut), nil, nil, False, 0, nil, nil,
                       LStartInfo, LProcInfo) then begin
    try TFile.Delete(ATempHTML); except end;
    raise Exception.Create('PDF olusturma islemi baslatilamadi.');
  end;
  try
    WaitForSingleObject(LProcInfo.hProcess, 60000);
  finally
    CloseHandle(LProcInfo.hThread);
    CloseHandle(LProcInfo.hProcess);
  end;
  try TFile.Delete(ATempHTML); except end;
  if not FileExists(ADosya) then
    raise Exception.Create('PDF dosyasi olusturulamadi.');
end;

class procedure TEBelgeOlusturucu.PDFKaydetGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LTempHTML: string;
begin
  LTempHTML := TPath.Combine(TPath.GetTempPath,
    'Gentegre_GelenEBelge_PDF_' + IntToStr(AFatBaslikID) + '.html');
  HTMLKaydetGelen(AConnection, AFatBaslikID, LTempHTML);
  _HTMLDosyaPDFeCevir(LTempHTML, ADosya);
end;

end.








unit UEBelgeAliasServis;

interface

uses
  FireDAC.Comp.Client;

const
  // FATBASLIK.TUR / EBELGE.BELGETURU � app-genel belge tipi kodlari
  EBelgeTuruEIrsaliye = 14;
  EBelgeTuruEFatura   = 15;
  EBelgeTuruEArsiv    = 16;

  // REHBERALIAS.BELGETURU � alias depolama kodlamasi (bu tabloya ozel)
  RAlias_EIrsaliyeGIB   = 140;   // Izibiz'den dogrulanmis e-Irsaliye alias
  RAlias_EIrsaliyeKendi = 141;   // Kendi sistemde tutulan e-Irsaliye
  RAlias_EArsiv         = 150;   // Mukellef degil, mail bazli
  RAlias_EFatura        = 151;   // Izibiz'den dogrulanmis e-Fatura alias

type
  TEBelgeAliasKaydi = record
    BelgeTuru: Byte;
    Alias: string;
    Baslik: string;   // Izibiz 'title' (unvan) - coklu alias seciminde gosterim icin
    // GIB alias aktivasyon/kayit zamani (Izibiz JSON'inda registerTime/creationTime...).
    // Coklu alias seciminde hangisinin GUNCEL oldugunu ayirt etmek icin gosterilir;
    // servis alani vermezse 0 kalir ve ekranda tarih yazilmaz.
    AktivasyonTarihi: TDateTime;
    // Kayittaki TUM tarih gorunumlu alanlar (ad + deger). Dogru alani secmek icin gerekli:
    // yanitta mukellef-seviyesi (tum aliaslarda AYNI) tarihler de var; alias'a ozel olan,
    // aliaslar arasinda DEGISEN alandir -> AktivasyonlariBelirle bunu secer.
    TarihAdlari: TArray<string>;
    TarihDegerleri: TArray<TDateTime>;
  end;

  TEBelgeAliasKayitlari = array of TEBelgeAliasKaydi;

  IEBelgeAliasSaglayici = interface
    ['{3905D6A3-0B7D-496B-BD6C-F887BDF94B79}']
    function AliaslariGetir(const AVergiNo: string): TEBelgeAliasKayitlari;
  end;

  TAliasYonetimSonuc = record
    Basari: Boolean;
    BelgeTuru: SmallInt;      // 150 (Arsiv) veya 151 (Fatura)
    Alias: string;            // 151 ise Izibiz alias, 150 ise mail adres(ler)i
    Mesaj: string;
  end;

  TEBelgeAliasServis = class
  public
    class function SaglayiciOlustur: IEBelgeAliasSaglayici; static;
    class function VarsayilanAliasGetir(AConnection: TFDConnection;
      ARehberID, ABelgeTuru: Integer): string; static;
    class procedure ServistenGuncelle(AConnection: TFDConnection;
      ARehberID: Integer; const AVergiNo: string); static;
    class function AliasGetirVeyaGuncelle(AConnection: TFDConnection;
      ARehberID, ABelgeTuru: Integer; const AVergiNo: string): string; static;
    /// e-Fatura/e-Arsiv olusturma akisinda kullanilan alias yonetimi.
    /// 4 branch karar mantigi:
    ///   (A) 151/141 + 30gun dolmadi  -> mevcut alias kullan
    ///   (B) 151/141 + 30gun dolmus   -> Izibiz'e sor, gerekirse yenile
    ///   (C) 150/140                  -> Izibiz'e her defasinda sor, mukellef olduysa 151 ekle
    ///   (D) Hic kayit yok            -> Once Izibiz, alias gelirse 151, gelmezse 150 (mail diyalogu)
    /// AFatBaslikTur: 15 (e-Fatura/e-Arsiv) veya 14 (e-Irsaliye)
    class function AliasIslemiYap(AConnection: TFDConnection;
      ARehberID, AFatBaslikTur: Integer; const AVergiNo, ACariAdi,
      ARehberMail: string): TAliasYonetimSonuc; static;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.DateUtils, System.UITypes, System.Variants,
  FireDAC.Stan.Param, Vcl.Dialogs, Vcl.StdCtrls,
  Utablo, FetaKurulusSiniflari, UEBelgeKimlik, UMailOnayDlg, PrjConst,
  UGirisKutusuEx, UVeriMotor;

type
  TIzibizAliasSaglayici = class(TInterfacedObject, IEBelgeAliasSaglayici)
  private
    FHTTPClient: THTTPClient;
    FApiBaseURL: string;
    FKullaniciAdi: string;
    FSifre: string;
    function TokenAl: string;
  public
    constructor Create(const AServisURL, AKullaniciAdi, ASifre: string);
    destructor Destroy; override;
    function AliaslariGetir(const AVergiNo: string): TEBelgeAliasKayitlari;
  end;

function IzibizAPIAdresineCevir(const AServisURL: string): string;
var
  LAlt: string;
  LKonum: Integer;
begin
  Result := Trim(AServisURL);
  while Result.EndsWith('/') do
    Delete(Result, Length(Result), 1);

  LAlt := LowerCase(Result);
  if (Pos('portaltest.izibiz.com.tr', LAlt) > 0) or
    (Pos('apitest.izibiz.com.tr', LAlt) > 0) or
    (Pos('efaturatest.izibiz.com.tr', LAlt) > 0) then
    Exit('https://apitest.izibiz.com.tr');

  if (Pos('portal.izibiz.com.tr', LAlt) > 0) or
    (Pos('api.izibiz.com.tr', LAlt) > 0) or
    (Pos('efatura.izibiz.com.tr', LAlt) > 0) then
    Exit('https://api.izibiz.com.tr');

  LKonum := Pos('/v1/', LAlt);
  if LKonum > 0 then
    SetLength(Result, LKonum - 1);
end;

function JSONMetni(AObject: TJSONObject; const AAlan: string): string;
var
  LDeger: TJSONValue;
begin
  Result := '';
  if not Assigned(AObject) then
    Exit;

  LDeger := AObject.GetValue(AAlan);
  if Assigned(LDeger) and not (LDeger is TJSONNull) then
    Result := LDeger.Value;
end;

// Metni ISO 8601 / 'yyyy-mm-dd hh:nn:ss' tarihe cevirir; olmazsa 0 doner.
function MetinTarih(const AMetin: string): TDateTime;
var
  S: string;
begin
  Result := 0;
  S := Trim(AMetin);
  if Length(S) < 10 then Exit;
  if (S[5] <> '-') or (S[8] <> '-') then Exit;
  S := StringReplace(S, 'T', ' ', [rfReplaceAll]);
  if Pos('.', S) > 0 then S := Copy(S, 1, Pos('.', S) - 1);   // milisaniye eki
  if Pos('+', S) > 0 then S := Copy(S, 1, Pos('+', S) - 1);   // saat dilimi eki
  S := Trim(StringReplace(S, 'Z', '', [rfReplaceAll]));
  if not TryEncodeDateTime(StrToIntDef(Copy(S, 1, 4), 0), StrToIntDef(Copy(S, 6, 2), 0),
                           StrToIntDef(Copy(S, 9, 2), 0), StrToIntDef(Copy(S, 12, 2), 0),
                           StrToIntDef(Copy(S, 15, 2), 0), StrToIntDef(Copy(S, 18, 2), 0),
                           0, Result) then
    Result := 0;
end;

// Kayittaki TUM tarih gorunumlu alanlari (ad + deger) toplar. Hangisinin "alias aktivasyonu"
// oldugu yanitin alan adlarina gore degistigi icin secim AktivasyonlariBelirle'ye birakilir.
procedure JSONTarihleriTopla(AObject: TJSONObject; var AAdlar: TArray<string>;
  var ADegerler: TArray<TDateTime>);
var
  LPair, LAlt: TJSONPair;
  LTarih: TDateTime;
begin
  SetLength(AAdlar, 0);
  SetLength(ADegerler, 0);
  if not Assigned(AObject) then Exit;
  for LPair in AObject do
  begin
    if (not Assigned(LPair.JsonValue)) or (LPair.JsonValue is TJSONNull) then Continue;
    // Bir seviye ic ice nesne (or. {"alias":{...,"registerTime":"..."}}) de taransin;
    // ad 'ust.alt' olarak tutulur (yalniz karsilastirma icin kullanilir).
    if LPair.JsonValue is TJSONObject then
    begin
      for LAlt in TJSONObject(LPair.JsonValue) do
      begin
        if (not Assigned(LAlt.JsonValue)) or (LAlt.JsonValue is TJSONNull) then Continue;
        LTarih := MetinTarih(LAlt.JsonValue.Value);
        if LTarih > 0 then
        begin
          AAdlar := AAdlar + [LPair.JsonString.Value + '.' + LAlt.JsonString.Value];
          ADegerler := ADegerler + [LTarih];
        end;
      end;
      Continue;
    end;
    LTarih := MetinTarih(LPair.JsonValue.Value);
    if LTarih > 0 then
    begin
      AAdlar := AAdlar + [LPair.JsonString.Value];
      ADegerler := ADegerler + [LTarih];
    end;
  end;
end;

// Coklu alias listesinde gosterilecek AKTIVASYON tarihini secer.
// SORUN: Izibiz yaniti hem alias'a OZEL hem de mukellef-seviyesi (tum aliaslarda AYNI)
//   tarihler iceriyor; sabit alan adi denemek yanlis alani secip her aliasta ayni tarihi
//   gosteriyordu (or. 03.01.2020).
// COZUM: birden fazla alias varsa, aliaslar arasinda DEGISEN (>=2 farkli degerli) alanlar
//   arasindan bilinen-ad onceligine gore sec; hicbiri degismiyorsa yine bilinen-ad
//   onceligine dus (tek alias durumunda da bu gecerli).
procedure AktivasyonlariBelirle(var AKayitlar: TEBelgeAliasKayitlari);
const
  COncelik: array[0..7] of string = ('aliasCreationTime', 'registerTime', 'registrationTime',
    'activationTime', 'creationTime', 'createDate', 'createTime', 'firstCreationTime');
var
  i, j, k: Integer;
  LAdaylar: TArray<string>;
  LDegisen: TArray<string>;
  LSecilen: string;
  LIlk: TDateTime;
  LFarkli: Boolean;

  function AdVar(const AAd: string; const ADizi: TArray<string>): Boolean;
  var n: Integer;
  begin
    Result := False;
    for n := 0 to High(ADizi) do
      if SameText(ADizi[n], AAd) then Exit(True);
  end;

  function KayittaDeger(const AKayit: TEBelgeAliasKaydi; const AAd: string;
    out ADeger: TDateTime): Boolean;
  var n: Integer;
  begin
    Result := False;
    ADeger := 0;
    for n := 0 to High(AKayit.TarihAdlari) do
      if SameText(AKayit.TarihAdlari[n], AAd) then
      begin
        ADeger := AKayit.TarihDegerleri[n];
        Exit(True);
      end;
  end;

  // Alan TUM kayitlarda var mi?
  function HerKayittaVar(const AAd: string): Boolean;
  var n: Integer; d: TDateTime;
  begin
    Result := True;
    for n := 0 to High(AKayitlar) do
      if not KayittaDeger(AKayitlar[n], AAd, d) then Exit(False);
  end;

var
  LDeger: TDateTime;
begin
  if Length(AKayitlar) = 0 then Exit;

  // 1) Tum kayitlarda ORTAK olan tarih alanlarinin adlarini topla
  SetLength(LAdaylar, 0);
  for i := 0 to High(AKayitlar[0].TarihAdlari) do
    if HerKayittaVar(AKayitlar[0].TarihAdlari[i]) then
      LAdaylar := LAdaylar + [AKayitlar[0].TarihAdlari[i]];

  // 2) Birden fazla alias varsa: degerleri DEGISEN alanlari ayikla (alias'a ozel olanlar)
  SetLength(LDegisen, 0);
  if Length(AKayitlar) > 1 then
    for i := 0 to High(LAdaylar) do
    begin
      KayittaDeger(AKayitlar[0], LAdaylar[i], LIlk);
      LFarkli := False;
      for j := 1 to High(AKayitlar) do
      begin
        KayittaDeger(AKayitlar[j], LAdaylar[i], LDeger);
        if LDeger <> LIlk then begin LFarkli := True; Break; end;
      end;
      if LFarkli then
        LDegisen := LDegisen + [LAdaylar[i]];
    end;

  // 3) Secim: once DEGISEN alanlar icinde bilinen-ad onceligi, sonra ilk degisen alan,
  //    hicbiri yoksa tum adaylar icinde bilinen-ad onceligi.
  LSecilen := '';
  for k := Low(COncelik) to High(COncelik) do
    if AdVar(COncelik[k], LDegisen) then begin LSecilen := COncelik[k]; Break; end;
  if (LSecilen = '') and (Length(LDegisen) > 0) then
    LSecilen := LDegisen[0];
  if LSecilen = '' then
    for k := Low(COncelik) to High(COncelik) do
      if AdVar(COncelik[k], LAdaylar) then begin LSecilen := COncelik[k]; Break; end;

  // 4) Uygula (secilemezse tarih gosterilmez)
  for i := 0 to High(AKayitlar) do
    if (LSecilen <> '') and KayittaDeger(AKayitlar[i], LSecilen, LDeger) then
      AKayitlar[i].AktivasyonTarihi := LDeger
    else
      AKayitlar[i].AktivasyonTarihi := 0;
end;

function IzibizHataMesaji(ARoot: TJSONObject): string;
var
  LHata: TJSONValue;
begin
  Result := '';
  if not Assigned(ARoot) then
    Exit;

  LHata := ARoot.GetValue('error');
  if LHata is TJSONObject then
    Result := JSONMetni(TJSONObject(LHata), 'message');
end;

function EntegratorAdiNormallestir(const ADeger: string): string;
begin
  Result := UpperCase(Trim(ADeger));
  Result := StringReplace(Result, WideChar($0130), 'I', [rfReplaceAll]);
  Result := StringReplace(Result, WideChar($0131), 'I', [rfReplaceAll]);
end;

constructor TIzibizAliasSaglayici.Create(const AServisURL, AKullaniciAdi,
  ASifre: string);
begin
  inherited Create;
  FApiBaseURL := IzibizAPIAdresineCevir(AServisURL);
  FKullaniciAdi := AKullaniciAdi;
  FSifre := ASifre;
  FHTTPClient := THTTPClient.Create;
end;

destructor TIzibizAliasSaglayici.Destroy;
begin
  FHTTPClient.Free;
  inherited Destroy;
end;

function TIzibizAliasSaglayici.TokenAl: string;
var
  LBody: TJSONObject;
  LIstek: TStringStream;
  LCevap: IHTTPResponse;
  LJSON: TJSONValue;
  LRoot, LData: TJSONObject;
  LHeaders: TNetHeaders;
  LHata: string;
begin
  // Cache'de gecerli token var mi?
  Result := TEBelgeKimlik.TokenAl;
  if Result <> '' then Exit;

  Result := '';
  LBody := TJSONObject.Create;
  try
    LBody.AddPair('username', FKullaniciAdi);
    LBody.AddPair('password', FSifre);
    LIstek := TStringStream.Create(LBody.ToJSON, TEncoding.UTF8);
    try
      LHeaders := [
        TNameValuePair.Create('Content-Type', 'application/json'),
        TNameValuePair.Create('Accept', 'application/json')
      ];
      LCevap := FHTTPClient.Post(FApiBaseURL + '/v1/auth/token', LIstek, nil,
        LHeaders);
    finally
      LIstek.Free;
    end;
  finally
    LBody.Free;
  end;

  LJSON := TJSONObject.ParseJSONValue(LCevap.ContentAsString(TEncoding.UTF8));
  try
    if not (LJSON is TJSONObject) then
      raise Exception.CreateFmt('Izibiz token servisi gecersiz yanit verdi. HTTP %d.',
        [LCevap.StatusCode]);

    LRoot := TJSONObject(LJSON);
    LHata := IzibizHataMesaji(LRoot);
    if (LCevap.StatusCode < 200) or (LCevap.StatusCode >= 300) then
      raise Exception.CreateFmt('Izibiz token servisi hatasi (HTTP %d): %s',
        [LCevap.StatusCode, LHata]);

    if not (LRoot.GetValue('data') is TJSONObject) then
      raise Exception.Create('Izibiz token yanitinda data alani bulunamadi.');
    LData := TJSONObject(LRoot.GetValue('data'));
    Result := JSONMetni(LData, 'accessToken');
    if Result = '' then
      raise Exception.Create('Izibiz token yanitinda accessToken bulunamadi.');
    // Token'i 25 dakika cache'le
    TEBelgeKimlik.TokenSet(Result, 25);
  finally
    LJSON.Free;
  end;
end;

function TIzibizAliasSaglayici.AliaslariGetir(
  const AVergiNo: string): TEBelgeAliasKayitlari;
var
  LToken: string;
  LCevap: IHTTPResponse;
  LJSON: TJSONValue;
  LRoot, LKayit: TJSONObject;
  LData: TJSONArray;
  LHeaders: TNetHeaders;
  I, LKayitSayisi: Integer;
  LAlias, LBelgeTuru, LHata: string;
begin
  SetLength(Result, 0);
  LToken := TokenAl;
  LHeaders := [
    TNameValuePair.Create('Authorization', 'Bearer ' + LToken),
    TNameValuePair.Create('Accept', 'application/json')
  ];
  LCevap := FHTTPClient.Get(FApiBaseURL + '/v1/resources/gib-users?identifier=' +
    AVergiNo, nil, LHeaders);

  LJSON := TJSONObject.ParseJSONValue(LCevap.ContentAsString(TEncoding.UTF8));
  try
    if not (LJSON is TJSONObject) then
      raise Exception.CreateFmt('Izibiz alias servisi gecersiz yanit verdi. HTTP %d.',
        [LCevap.StatusCode]);

    LRoot := TJSONObject(LJSON);
    LHata := IzibizHataMesaji(LRoot);
    if (LCevap.StatusCode < 200) or (LCevap.StatusCode >= 300) then
      raise Exception.CreateFmt('Izibiz alias servisi hatasi (HTTP %d): %s',
        [LCevap.StatusCode, LHata]);

    if not (LRoot.GetValue('data') is TJSONArray) then
      raise Exception.Create('Izibiz alias yanitinda data listesi bulunamadi.');
    LData := TJSONArray(LRoot.GetValue('data'));
    LKayitSayisi := 0;
    SetLength(Result, LData.Count);
    for I := 0 to LData.Count - 1 do begin
      if not (LData.Items[I] is TJSONObject) then
        Continue;
      LKayit := TJSONObject(LData.Items[I]);
      if SameText(JSONMetni(LKayit, 'active'), 'false') then
        Continue;

      LAlias := Trim(JSONMetni(LKayit, 'alias'));
      if LAlias = '' then
        Continue;

      Result[LKayitSayisi].Alias := LAlias;
      Result[LKayitSayisi].Baslik := Trim(JSONMetni(LKayit, 'title'));
      JSONTarihleriTopla(LKayit, Result[LKayitSayisi].TarihAdlari,
                                 Result[LKayitSayisi].TarihDegerleri);
      LBelgeTuru := UpperCase(JSONMetni(LKayit, 'documentType'));
      if (LBelgeTuru = 'DESPATCHADVICE') or
        (Pos('IRSALIYE', UpperCase(LAlias)) > 0) then
        Result[LKayitSayisi].BelgeTuru := EBelgeTuruEIrsaliye
      else
        Result[LKayitSayisi].BelgeTuru := EBelgeTuruEFatura;
      Inc(LKayitSayisi);
    end;
    SetLength(Result, LKayitSayisi);
    // Aktivasyon tarihi ancak TUM kayitlar elde olunca secilebilir (degisen alan analizi).
    AktivasyonlariBelirle(Result);
  finally
    LJSON.Free;
  end;
end;

class function TEBelgeAliasServis.SaglayiciOlustur: IEBelgeAliasSaglayici;
// Kimlik bilgileri ortak TEBelgeKimlik cache'inden alinir � bu sayede
// gonderim akisi ile ayn? kullan?c?/?ifre/URL paylasilir, ayri ayri okunmaz.
var
  LEntegrator: string;
  LOrtam, LUser, LSifre, LURL: string;
  LTestModu: Boolean;
begin
  LEntegrator := EntegratorAdiNormallestir(Entegrator);
  if not ((LEntegrator = '') or (Pos('IZIBIZ', LEntegrator) > 0) or
    (Pos('IZIBIS', LEntegrator) > 0)) then
    raise Exception.CreateFmt('Alias sorgusu icin desteklenmeyen entegrator: %s',
      [Entegrator]);

  TEBelgeKimlik.Yukle(LUser, LSifre, LURL, LTestModu);

  if Trim(LURL) = '' then begin
    if LTestModu then LOrtam := 'test' else LOrtam := 'uretim';
    raise Exception.CreateFmt('E-Fatura %s servis adresi tanimli degil.', [LOrtam]);
  end;
  if Trim(LUser) = '' then
    raise Exception.Create('Izibiz kullanici adi tanimli degil.');

  Result := TIzibizAliasSaglayici.Create(LURL, LUser, LSifre);
end;

class function TEBelgeAliasServis.VarsayilanAliasGetir(
  AConnection: TFDConnection; ARehberID, ABelgeTuru: Integer): string;
begin
  Result := '';
  Tablo.TablodanSorguAc(1,
    'select '+DbUst(1)+'ALIAS from REHBERALIAS ' +
    'where REHBERID=' + IntToStr(ARehberID) +
    ' and BELGETURU=' + IntToStr(ABelgeTuru) + ' and AKTIF=1 ' +
    'order by VARSAYILAN desc, SONKONTROLTARIHI desc, ID '+DbSinir(1));
  if Tablo.Query1.RecordCount > 0 then
    Result := Tablo.Query1.Fields[0].AsString;
end;

class procedure TEBelgeAliasServis.ServistenGuncelle(AConnection: TFDConnection;
  ARehberID: Integer; const AVergiNo: string);
var
  LAliaslar: TEBelgeAliasKayitlari;
  LSaglayici: IEBelgeAliasSaglayici;
  LOwnTransaction: Boolean;
  LVergiNo: string;
  LAliasID, LBelgeTuru, I: Integer;
begin
  LVergiNo := StringReplace(Trim(AVergiNo), ' ', '', [rfReplaceAll]);
  if not (Length(LVergiNo) in [10, 11]) then
    raise Exception.Create('Gecerli vergi veya T.C. kimlik numarasi bulunamadi.');

  LSaglayici := SaglayiciOlustur;
  LAliaslar := LSaglayici.AliaslariGetir(LVergiNo);
  if Length(LAliaslar) = 0 then
    Exit;

  LOwnTransaction := not AConnection.InTransaction;
  if LOwnTransaction then
    AConnection.StartTransaction;
  try
    Veritabani.BasitKomutÇalıştır(AConnection,
        'update REHBERALIAS set AKTIF=0, VARSAYILAN=0, ' +
        'PASIFTARIHI=sysdatetime(), SONKONTROLTARIHI=sysdatetime() ' +
        'where REHBERID=&REHBERID',
        ['&REHBERID'], [ARehberID]);

    for I := 0 to Length(LAliaslar) - 1 do begin
      Tablo.TablodanSorguAc(1,
        'select '+DbUst(1)+'ID from REHBERALIAS where REHBERID=' +
        IntToStr(ARehberID) + ' and BELGETURU=' +
        IntToStr(LAliaslar[I].BelgeTuru) + ' and ALIAS=' +
        QuotedStr(LAliaslar[I].Alias) + ' '+DbSinir(1));
      if Tablo.Query1.RecordCount > 0 then begin
        LAliasID := Tablo.Query1.Fields[0].AsInteger;
        Veritabani.BasitKomutÇalıştır(AConnection,
          'update REHBERALIAS set AKTIF=1, VARSAYILAN=0, PASIFTARIHI=null, ' +
          'SONKONTROLTARIHI=sysdatetime() where ID=&ID',
          ['&ID'], [LAliasID]);
      end else
        Veritabani.BasitKomutÇalıştır(AConnection,
          'insert into REHBERALIAS(REHBERID,BELGETURU,ALIAS,VARSAYILAN,AKTIF) ' +
          'values(&REHBERID,&BELGETURU,&ALIAS,0,1)',
          ['&REHBERID', '&BELGETURU', '&ALIAS'],
          [ARehberID, LAliaslar[I].BelgeTuru, LAliaslar[I].Alias]);
    end;

    for LBelgeTuru := EBelgeTuruEIrsaliye to EBelgeTuruEFatura do begin
      Tablo.TablodanSorguAc(1,
        'select '+DbUst(1)+'ID from REHBERALIAS where REHBERID=' +
        IntToStr(ARehberID) + ' and BELGETURU=' + IntToStr(LBelgeTuru) +
        ' and AKTIF=1 order by ID '+DbSinir(1));
      if Tablo.Query1.RecordCount > 0 then
        Veritabani.BasitKomutÇalıştır(AConnection,
          'update REHBERALIAS set VARSAYILAN=1 where ID=&ID',
          ['&ID'], [Tablo.Query1.Fields[0].AsInteger]);
    end;

    if LOwnTransaction then
      AConnection.Commit;
  except
    if LOwnTransaction and AConnection.InTransaction then
      AConnection.Rollback;
    raise;
  end;
end;

class function TEBelgeAliasServis.AliasGetirVeyaGuncelle(
  AConnection: TFDConnection; ARehberID, ABelgeTuru: Integer;
  const AVergiNo: string): string;
begin
  Result := VarsayilanAliasGetir(AConnection, ARehberID, ABelgeTuru);
  if Result <> '' then
    Exit;

  ServistenGuncelle(AConnection, ARehberID, AVergiNo);
  Result := VarsayilanAliasGetir(AConnection, ARehberID, ABelgeTuru);
end;

// REHBERALIAS triplet (RehberID, BelgeTuru, Alias) varsa reactivate, yoksa
// LEskiID'yi pasif yap ve yeni satir ekle.
procedure RAliasUpsert(AConnection: TFDConnection; ARehberID: Integer;
  ABelgeTuru: Integer; const AAlias: string; AEskiID: Integer);
var
  LExistingID: Integer;
begin
  LExistingID := 0;
  Tablo.TablodanSorguAc(1,
    'SELECT '+DbUst(1)+'ID FROM REHBERALIAS WHERE REHBERID=' + IntToStr(ARehberID) +
    ' AND BELGETURU=' + IntToStr(ABelgeTuru) +
    ' AND ALIAS=' + QuotedStr(AAlias) + ' '+DbSinir(1));
  if not Tablo.Query1.IsEmpty then
    LExistingID := Tablo.Query1.Fields[0].AsInteger;
  Tablo.Query1.Close;

  if LExistingID > 0 then begin
    // Reactivate, varsayilan yap; diger ayni (rehber,belgeturu) varsayilanlarini sifirla
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE REHBERALIAS SET VARSAYILAN=0 WHERE REHBERID=&R AND BELGETURU=&B AND ID<>&I',
      ['&R', '&B', '&I'], [ARehberID, ABelgeTuru, LExistingID]);
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE REHBERALIAS SET AKTIF=1, VARSAYILAN=1, PASIFTARIHI=NULL, ' +
      'SONKONTROLTARIHI=GETDATE() WHERE ID=&ID',
      ['&ID'], [LExistingID]);
  end else begin
    if AEskiID > 0 then
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE REHBERALIAS SET AKTIF=0, VARSAYILAN=0, PASIFTARIHI=GETDATE() WHERE ID=&ID',
        ['&ID'], [AEskiID]);
    // Ayrica ayni (rehber,belgeturu)'deki diger varsayilanlari sifirla (UX_VARSAYILAN icin)
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE REHBERALIAS SET VARSAYILAN=0 WHERE REHBERID=&R AND BELGETURU=&B',
      ['&R', '&B'], [ARehberID, ABelgeTuru]);
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO REHBERALIAS(REHBERID,BELGETURU,ALIAS,VARSAYILAN,AKTIF,ILKKAYITTARIHI,SONKONTROLTARIHI) ' +
      'VALUES(&RID, &BT, &AL, 1, 1, GETDATE(), GETDATE())',
      ['&RID', '&BT', '&AL'], [ARehberID, ABelgeTuru, AAlias]);
  end;
end;

// Birden fazla alias bulundugunda kullanicidan secim ister (combo, index bazli).
// Iptal -> False. Secilirse ASecilen'e alias yazilir.
// ATarihler: her alias'in GIB aktivasyon/kayit zamani (0 = servis vermedi -> yazilmaz).
function AliasSec(const AAliaslar, ABasliklar: array of string;
  const ATarihler: array of TDateTime; out ASecilen: string): Boolean;
var
  LListe: TStringList;
  LSecim: Variant;
  i: Integer;
  LSatir: string;
begin
  Result := False;
  ASecilen := '';
  LListe := TStringList.Create;
  try
    for i := 0 to High(AAliaslar) do begin
      LSatir := AAliaslar[i];
      if (i <= High(ABasliklar)) and (Trim(ABasliklar[i]) <> '') then
        LSatir := AAliaslar[i] + '  -  ' + ABasliklar[i];
      // Ayni vergi numarasinda birden cok alias oldugunda karar veren bilgi genelde
      // aktivasyon tarihidir (en yenisi genelde gecerli olan) -> satirin BASINDA.
      if (i <= High(ATarihler)) and (ATarihler[i] > 0) then
        LSatir := '(' + FormatDateTime('dd.mm.yyyy', ATarihler[i]) + ')  ' + LSatir;
      LListe.Add(LSatir);
    end;
    // Ilk ogeyi on-secili yap (init TEXT ile eslesir); donus ItemIndex olur.
    if LListe.Count > 0 then LSecim := LListe[0] else LSecim := '';
    if TGirisKutusuEx.BilgiAlEx(
         'Birden fazla alias bulundu - l' + #$00FC + 'tfen se' + #$00E7 + 'in',
         TGirdiDenetimleri.Create.ComboBox('Alias', @LSecim, LListe,
           csDropDownList, True, nil, 620)) <> mrOk then   // 620px genis combo
      Exit;
    i := LSecim;
    if (i >= 0) and (i <= High(AAliaslar)) then begin
      ASecilen := AAliaslar[i];
      Result := True;
    end;
  finally
    LListe.Free;
  end;
end;

{ ---------- AliasIslemiYap � 4-branch akis ---------- }

class function TEBelgeAliasServis.AliasIslemiYap(AConnection: TFDConnection;
  ARehberID, AFatBaslikTur: Integer; const AVergiNo, ACariAdi,
  ARehberMail: string): TAliasYonetimSonuc;
var
  Q: TFDQuery;
  LMevcutID: Integer;
  LMevcutBelgeTuru: SmallInt;
  LMevcutAlias: string;
  LMevcutSonKontrol: TDateTime;
  LVar: Boolean;
  LIzibizSorgu: Boolean;
  LSaglayici: IEBelgeAliasSaglayici;
  LKayitlar: TEBelgeAliasKayitlari;
  LIzibizAlias: string;
  LYeniMail: string;
  i: Integer;
  LIrsaliyeMi: Boolean;
  LKodMukellef, LKodGenel: Integer;
  LIzibizFiltreTur: Byte;
begin
  Result := Default(TAliasYonetimSonuc);
  LIrsaliyeMi := AFatBaslikTur = EBelgeTuruEIrsaliye;
  if LIrsaliyeMi then begin
    LKodMukellef    := RAlias_EIrsaliyeKendi;  // 141
    LKodGenel       := RAlias_EIrsaliyeGIB;    // 140
    LIzibizFiltreTur := EBelgeTuruEIrsaliye;   // 14
  end else begin
    LKodMukellef    := RAlias_EFatura;         // 151
    LKodGenel       := RAlias_EArsiv;          // 150
    LIzibizFiltreTur := EBelgeTuruEFatura;     // 15
  end;

  // 1) Mevcut aktif kayit ara (varsa)
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT '+DbUst(1)+'ID, BELGETURU, ALIAS, SONKONTROLTARIHI ' +
      'FROM REHBERALIAS ' +
      'WHERE REHBERID = :REHBERID AND AKTIF = 1 ' +
      '  AND BELGETURU IN (:T1, :T2) ' +
      'ORDER BY VARSAYILAN DESC, ID DESC '+DbSinir(1);
    Q.ParamByName('REHBERID').AsInteger := ARehberID;
    Q.ParamByName('T1').AsInteger := LKodMukellef;
    Q.ParamByName('T2').AsInteger := LKodGenel;
    Q.Open;
    LVar := not Q.IsEmpty;
    if LVar then begin
      LMevcutID := Q.FieldByName('ID').AsInteger;
      LMevcutBelgeTuru := Q.FieldByName('BELGETURU').AsInteger;
      LMevcutAlias := Q.FieldByName('ALIAS').AsString;
      LMevcutSonKontrol := Q.FieldByName('SONKONTROLTARIHI').AsDateTime;
    end;
  finally
    Q.Free;
  end;

  // 2) Izibiz'e sorgu yapmaya gerek var mi?
  //    TEST modunda cache atlanir (her seferinde dialog gosterilir)
  var LKullaniciDmy: string; var LSifreDmy: string; var LURLDmy: string;
  var LTestModu: Boolean;
  TEBelgeKimlik.Yukle(LKullaniciDmy, LSifreDmy, LURLDmy, LTestModu);

  LIzibizSorgu := True;
  if LVar and (not LTestModu) then begin
    if LMevcutBelgeTuru = LKodMukellef then begin
      // 30 gun kontrolu (151/141 cache)
      if DaysBetween(Now, LMevcutSonKontrol) <= 30 then
        LIzibizSorgu := False;  // Branch (A)
    end;
    // 140/150 (LKodGenel) her zaman tekrar sorgulanir
  end;

  if not LIzibizSorgu then begin
    // Branch (A) � mevcut alias direkt kullanilir
    Result.Basari := True;
    Result.BelgeTuru := LMevcutBelgeTuru;
    Result.Alias := LMevcutAlias;
    Result.Mesaj := 'Mevcut alias kullaniliyor (son kontrol: ' +
                    FormatDateTime('dd.mm.yyyy', LMevcutSonKontrol) + ')';
    Exit;
  end;

  // 3) Izibiz'e sor � TEST modunda atla, dogrudan EFatura placeholder ile devam
  LIzibizAlias := '';
  if LTestModu then begin
    var LMsg: string;
    if LIrsaliyeMi then
      LMsg := 'TEST MODU - e-İrsaliye seçimi' + sLineBreak + sLineBreak +
              'Cari: ' + ACariAdi + sLineBreak +
              'VKN/TCKN: ' + AVergiNo + sLineBreak + sLineBreak +
              'Firma e-İrsaliye mükellefi mi?' + sLineBreak +
              '  EVET = Firmaya direkt (141)' + sLineBreak +
              '  HAYIR = GİB üzerinden (140)' + sLineBreak +
              '  İPTAL = Vazgeç'
    else
      LMsg := 'TEST MODU - Belge türü seçimi' + sLineBreak + sLineBreak +
              'Cari: ' + ACariAdi + sLineBreak +
              'VKN/TCKN: ' + AVergiNo + sLineBreak + sLineBreak +
              'Bu belge ne olarak kesilecek?' + sLineBreak +
              '  EVET = e-Fatura (mükellef varsay)' + sLineBreak +
              '  HAYIR = e-Arşiv Fatura' + sLineBreak +
              '  İPTAL = Vazgeç';
    case MessageDlg(LMsg, mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:    LIzibizAlias := 'urn:mail:defaultpk@izibiz.com.tr';
      mrNo:     LIzibizAlias := '';  // genel branch'ine d�sun (150/140)
    else
      Result.Basari := False;
      Result.Mesaj := 'Kullanici iptal etti';
      Exit;
    end;
  end else
  try
    LSaglayici := SaglayiciOlustur;
    LKayitlar := LSaglayici.AliaslariGetir(AVergiNo);

    // Belge turune uyan TUM aliaslari topla (14->EIrsaliye, 15->EFatura).
    var LAdaylar: TArray<string> := [];
    var LBasliklar: TArray<string> := [];
    var LTarihler: TArray<TDateTime> := [];
    for i := 0 to Length(LKayitlar) - 1 do
      if LKayitlar[i].BelgeTuru = LIzibizFiltreTur then begin
        LAdaylar := LAdaylar + [LKayitlar[i].Alias];
        LBasliklar := LBasliklar + [LKayitlar[i].Baslik];
        LTarihler := LTarihler + [LKayitlar[i].AktivasyonTarihi];
      end;

    // Adaylari aktivasyon tarihine gore YENIDEN ESKIYE sirala: combo'da ilk sira
    // on-secili geldigi icin en guncel alias varsayilan secim olur (tarihsizler sona).
    for i := 0 to High(LAdaylar) - 1 do
      for var k := 0 to High(LAdaylar) - 1 - i do
        if LTarihler[k] < LTarihler[k + 1] then begin
          var LT: TDateTime := LTarihler[k]; LTarihler[k] := LTarihler[k + 1]; LTarihler[k + 1] := LT;
          var LS: string := LAdaylar[k];    LAdaylar[k]  := LAdaylar[k + 1];  LAdaylar[k + 1]  := LS;
          LS := LBasliklar[k];              LBasliklar[k] := LBasliklar[k + 1]; LBasliklar[k + 1] := LS;
        end;

    if Length(LAdaylar) = 1 then
      LIzibizAlias := LAdaylar[0]
    else if Length(LAdaylar) > 1 then begin
      // Adaylardan biri REHBERALIAS'ta zaten AKTIF ise sormadan onu kullan
      // (varsayilan/en yeni oncelikli). Yoksa musteriye sor.
      var LHazirAlias: string := '';
      var Q2: TFDQuery := TFDQuery.Create(nil);
      try
        Q2.Connection := AConnection;
        Q2.SQL.Text :=
          'SELECT ALIAS FROM REHBERALIAS WHERE REHBERID=:R AND AKTIF=1 ' +
          'AND BELGETURU IN (:T1,:T2) ' +
          'ORDER BY VARSAYILAN DESC, SONKONTROLTARIHI DESC, ID DESC';
        Q2.ParamByName('R').AsInteger := ARehberID;
        Q2.ParamByName('T1').AsInteger := LKodMukellef;
        Q2.ParamByName('T2').AsInteger := LKodGenel;
        Q2.Open;
        while (not Q2.Eof) and (LHazirAlias = '') do begin
          for i := 0 to High(LAdaylar) do
            if SameText(Trim(Q2.FieldByName('ALIAS').AsString), LAdaylar[i]) then begin
              LHazirAlias := LAdaylar[i];
              Break;
            end;
          Q2.Next;
        end;
      finally
        Q2.Free;
      end;

      if LHazirAlias <> '' then
        LIzibizAlias := LHazirAlias        // REHBERALIAS'taki aktif alias -> sormadan
      else if not AliasSec(LAdaylar, LBasliklar, LTarihler, LIzibizAlias) then begin
        Result.Basari := False;
        Result.Mesaj := 'Alias secimi iptal edildi';
        Exit;
      end;
    end;
    // 0 ise LIzibizAlias='' kalir -> asagida e-Arsiv/mail (150) ya da 140 branch'i
  except
    on E: Exception do begin
      // Izibiz sorgusu hata � mevcut varsa onu kullan, yoksa hata don
      if LVar then begin
        Result.Basari := True;
        Result.BelgeTuru := LMevcutBelgeTuru;
        Result.Alias := LMevcutAlias;
        Result.Mesaj := 'Izibiz sorgusu basarisiz � mevcut alias kullaniliyor: ' + E.Message;
        Exit;
      end;
      Result.Basari := False;
      Result.Mesaj := 'Izibiz alias sorgusu hatasi: ' + E.Message;
      Exit;
    end;
  end;

  // 4) Sonuc degerlendirme
  if LIzibizAlias <> '' then begin
    // Mukellef � LKodMukellef (151/141) ekle/reactivate
    if LVar and (LMevcutBelgeTuru = LKodMukellef) and
       SameText(LMevcutAlias, LIzibizAlias) then begin
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE REHBERALIAS SET SONKONTROLTARIHI = GETDATE() WHERE ID = &ID',
        ['&ID'], [LMevcutID]);
      Result.Mesaj := 'Alias degismedi � tarih guncellendi';
    end else begin
      var LEskiID: Integer := 0;
      if LVar then LEskiID := LMevcutID;
      RAliasUpsert(AConnection, ARehberID, LKodMukellef, LIzibizAlias, LEskiID);
      if LVar and (LMevcutBelgeTuru = LKodGenel) then
        Result.Mesaj := 'Cari mukellef oldu � alias eklendi/reactivate'
      else
        Result.Mesaj := 'Mukellef alias eklendi/reactivate';
    end;
    Result.Basari := True;
    Result.BelgeTuru := LKodMukellef;
    Result.Alias := LIzibizAlias;
  end else if LIrsaliyeMi then begin
    // EIrsaliye + alias yok � 140
    //   URETIM: opsiyondaki GIB Portal aliasi (irsaliyepk@gib.gov.tr)
    //   TEST:   Izibiz test URN (gercek GIB'e gitmesin)
    var LGIBAlias: string;
    if LTestModu then
      LGIBAlias := 'urn:mail:defaultpk@izibiz.com.tr'
    else
      LGIBAlias := Trim(Tablo.GENINI.ReadString(
        Ops_FaturaOpsiyon_EIrsaliyeGIBAlias, 'irsaliyepk@gib.gov.tr'));
    var LEski: Integer := 0;
    if LVar then LEski := LMevcutID;
    RAliasUpsert(AConnection, ARehberID, LKodGenel, LGIBAlias, LEski);
    Result.Basari := True;
    Result.BelgeTuru := LKodGenel;
    Result.Alias := LGIBAlias;
    Result.Mesaj := 'e-Irsaliye 140 (GIB Portal)';
  end else begin
    // EFatura akisinda mukellef DEGIL � e-Arsiv flow (mail)
    var LMevcutMail: string := '';
    if LVar and (LMevcutBelgeTuru = LKodGenel) then
      LMevcutMail := LMevcutAlias
    else
      LMevcutMail := ARehberMail;
    if MailOnayAl(ACariAdi, LMevcutMail, LYeniMail) then begin
      var LEskiID2: Integer := 0;
      if LVar then LEskiID2 := LMevcutID;
      RAliasUpsert(AConnection, ARehberID, LKodGenel, LYeniMail, LEskiID2);
      Result.Basari := True;
      Result.BelgeTuru := LKodGenel;
      Result.Alias := LYeniMail;
      Result.Mesaj := 'e-Arsiv mail kaydi (upsert)';
    end else begin
      Result.Basari := False;
      Result.Mesaj := 'Mail diyalogu iptal edildi';
    end;
  end;
end;

end.

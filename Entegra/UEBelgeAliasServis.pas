unit UEBelgeAliasServis;

interface

uses
  FireDAC.Comp.Client;

const
  // FATBASLIK.TUR / EBELGE.BELGETURU ï¿½ app-genel belge tipi kodlari
  EBelgeTuruEIrsaliye = 14;
  EBelgeTuruEFatura   = 15;
  EBelgeTuruEArsiv    = 16;

  // REHBERALIAS.BELGETURU ï¿½ alias depolama kodlamasi (bu tabloya ozel)
  RAlias_EIrsaliyeGIB   = 140;   // Izibiz'den dogrulanmis e-Irsaliye alias
  RAlias_EIrsaliyeKendi = 141;   // Kendi sistemde tutulan e-Irsaliye
  RAlias_EArsiv         = 150;   // Mukellef degil, mail bazli
  RAlias_EFatura        = 151;   // Izibiz'den dogrulanmis e-Fatura alias

type
  TEBelgeAliasKaydi = record
    BelgeTuru: Byte;
    Alias: string;
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
  System.Net.URLClient, System.DateUtils, System.UITypes,
  FireDAC.Stan.Param, Vcl.Dialogs,
  Utablo, FetaKurulusSiniflari, UEBelgeKimlik, UMailOnayDlg, PrjConst;

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
      LBelgeTuru := UpperCase(JSONMetni(LKayit, 'documentType'));
      if (LBelgeTuru = 'DESPATCHADVICE') or
        (Pos('IRSALIYE', UpperCase(LAlias)) > 0) then
        Result[LKayitSayisi].BelgeTuru := EBelgeTuruEIrsaliye
      else
        Result[LKayitSayisi].BelgeTuru := EBelgeTuruEFatura;
      Inc(LKayitSayisi);
    end;
    SetLength(Result, LKayitSayisi);
  finally
    LJSON.Free;
  end;
end;

class function TEBelgeAliasServis.SaglayiciOlustur: IEBelgeAliasSaglayici;
// Kimlik bilgileri ortak TEBelgeKimlik cache'inden alinir ï¿½ bu sayede
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
    'select top 1 ALIAS from REHBERALIAS ' +
    'where REHBERID=' + IntToStr(ARehberID) +
    ' and BELGETURU=' + IntToStr(ABelgeTuru) + ' and AKTIF=1 ' +
    'order by VARSAYILAN desc, SONKONTROLTARIHI desc, ID');
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
    Veritabani.BasitKomutÇalýþtýr(AConnection,
        'update REHBERALIAS set AKTIF=0, VARSAYILAN=0, ' +
        'PASIFTARIHI=sysdatetime(), SONKONTROLTARIHI=sysdatetime() ' +
        'where REHBERID=&REHBERID',
        ['&REHBERID'], [ARehberID]);

    for I := 0 to Length(LAliaslar) - 1 do begin
      Tablo.TablodanSorguAc(1,
        'select top 1 ID from REHBERALIAS where REHBERID=' +
        IntToStr(ARehberID) + ' and BELGETURU=' +
        IntToStr(LAliaslar[I].BelgeTuru) + ' and ALIAS=' +
        QuotedStr(LAliaslar[I].Alias));
      if Tablo.Query1.RecordCount > 0 then begin
        LAliasID := Tablo.Query1.Fields[0].AsInteger;
        Veritabani.BasitKomutÇalýþtýr(AConnection,
          'update REHBERALIAS set AKTIF=1, VARSAYILAN=0, PASIFTARIHI=null, ' +
          'SONKONTROLTARIHI=sysdatetime() where ID=&ID',
          ['&ID'], [LAliasID]);
      end else
        Veritabani.BasitKomutÇalýþtýr(AConnection,
          'insert into REHBERALIAS(REHBERID,BELGETURU,ALIAS,VARSAYILAN,AKTIF) ' +
          'values(&REHBERID,&BELGETURU,&ALIAS,0,1)',
          ['&REHBERID', '&BELGETURU', '&ALIAS'],
          [ARehberID, LAliaslar[I].BelgeTuru, LAliaslar[I].Alias]);
    end;

    for LBelgeTuru := EBelgeTuruEIrsaliye to EBelgeTuruEFatura do begin
      Tablo.TablodanSorguAc(1,
        'select top 1 ID from REHBERALIAS where REHBERID=' +
        IntToStr(ARehberID) + ' and BELGETURU=' + IntToStr(LBelgeTuru) +
        ' and AKTIF=1 order by ID');
      if Tablo.Query1.RecordCount > 0 then
        Veritabani.BasitKomutÇalýþtýr(AConnection,
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
    'SELECT TOP 1 ID FROM REHBERALIAS WHERE REHBERID=' + IntToStr(ARehberID) +
    ' AND BELGETURU=' + IntToStr(ABelgeTuru) +
    ' AND ALIAS=' + QuotedStr(AAlias));
  if not Tablo.Query1.IsEmpty then
    LExistingID := Tablo.Query1.Fields[0].AsInteger;
  Tablo.Query1.Close;

  if LExistingID > 0 then begin
    // Reactivate, varsayilan yap; diger ayni (rehber,belgeturu) varsayilanlarini sifirla
    Veritabani.BasitKomutÇalýþtýr(AConnection,
      'UPDATE REHBERALIAS SET VARSAYILAN=0 WHERE REHBERID=&R AND BELGETURU=&B AND ID<>&I',
      ['&R', '&B', '&I'], [ARehberID, ABelgeTuru, LExistingID]);
    Veritabani.BasitKomutÇalýþtýr(AConnection,
      'UPDATE REHBERALIAS SET AKTIF=1, VARSAYILAN=1, PASIFTARIHI=NULL, ' +
      'SONKONTROLTARIHI=GETDATE() WHERE ID=&ID',
      ['&ID'], [LExistingID]);
  end else begin
    if AEskiID > 0 then
      Veritabani.BasitKomutÇalýþtýr(AConnection,
        'UPDATE REHBERALIAS SET AKTIF=0, VARSAYILAN=0, PASIFTARIHI=GETDATE() WHERE ID=&ID',
        ['&ID'], [AEskiID]);
    // Ayrica ayni (rehber,belgeturu)'deki diger varsayilanlari sifirla (UX_VARSAYILAN icin)
    Veritabani.BasitKomutÇalýþtýr(AConnection,
      'UPDATE REHBERALIAS SET VARSAYILAN=0 WHERE REHBERID=&R AND BELGETURU=&B',
      ['&R', '&B'], [ARehberID, ABelgeTuru]);
    Veritabani.BasitKomutÇalýþtýr(AConnection,
      'INSERT INTO REHBERALIAS(REHBERID,BELGETURU,ALIAS,VARSAYILAN,AKTIF,ILKKAYITTARIHI,SONKONTROLTARIHI) ' +
      'VALUES(&RID, &BT, &AL, 1, 1, GETDATE(), GETDATE())',
      ['&RID', '&BT', '&AL'], [ARehberID, ABelgeTuru, AAlias]);
  end;
end;

{ ---------- AliasIslemiYap ï¿½ 4-branch akis ---------- }

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
      'SELECT TOP 1 ID, BELGETURU, ALIAS, SONKONTROLTARIHI ' +
      'FROM REHBERALIAS ' +
      'WHERE REHBERID = :REHBERID AND AKTIF = 1 ' +
      '  AND BELGETURU IN (:T1, :T2) ' +
      'ORDER BY VARSAYILAN DESC, ID DESC';
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
    // Branch (A) ï¿½ mevcut alias direkt kullanilir
    Result.Basari := True;
    Result.BelgeTuru := LMevcutBelgeTuru;
    Result.Alias := LMevcutAlias;
    Result.Mesaj := 'Mevcut alias kullaniliyor (son kontrol: ' +
                    FormatDateTime('dd.mm.yyyy', LMevcutSonKontrol) + ')';
    Exit;
  end;

  // 3) Izibiz'e sor ï¿½ TEST modunda atla, dogrudan EFatura placeholder ile devam
  LIzibizAlias := '';
  if LTestModu then begin
    var LMsg: string;
    if LIrsaliyeMi then
      LMsg := 'TEST MODU - e-ï¿½rsaliye seï¿½imi' + sLineBreak + sLineBreak +
              'Cari: ' + ACariAdi + sLineBreak +
              'VKN/TCKN: ' + AVergiNo + sLineBreak + sLineBreak +
              'Firma e-ï¿½rsaliye mï¿½kellefi mi?' + sLineBreak +
              '  EVET = Firmaya direkt (141)' + sLineBreak +
              '  HAYIR = Gï¿½B ï¿½zerinden (140)' + sLineBreak +
              '  ï¿½PTAL = vazgeï¿½'
    else
      LMsg := 'TEST MODU - Belge tï¿½rï¿½ seï¿½imi' + sLineBreak + sLineBreak +
              'Cari: ' + ACariAdi + sLineBreak +
              'VKN/TCKN: ' + AVergiNo + sLineBreak + sLineBreak +
              'Bu belge ne olarak kesilecek?' + sLineBreak +
              '  EVET = e-Fatura (mï¿½kellef varsay)' + sLineBreak +
              '  HAYIR = e-Arï¿½iv Fatura' + sLineBreak +
              '  ï¿½PTAL = vazgeï¿½';
    case MessageDlg(LMsg, mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:    LIzibizAlias := 'urn:mail:defaultpk@izibiz.com.tr';
      mrNo:     LIzibizAlias := '';  // genel branch'ine dï¿½sun (150/140)
    else
      Result.Basari := False;
      Result.Mesaj := 'Kullanici iptal etti';
      Exit;
    end;
  end else
  try
    LSaglayici := SaglayiciOlustur;
    LKayitlar := LSaglayici.AliaslariGetir(AVergiNo);

    // Belge tï¿½rï¿½ne gï¿½re alias seï¿½imi (14 iï¿½in EIrsaliye, 15 iï¿½in EFatura)
    for i := 0 to Length(LKayitlar) - 1 do
      if LKayitlar[i].BelgeTuru = LIzibizFiltreTur then begin
        LIzibizAlias := LKayitlar[i].Alias;
        Break;
      end;
  except
    on E: Exception do begin
      // Izibiz sorgusu hata ï¿½ mevcut varsa onu kullan, yoksa hata don
      if LVar then begin
        Result.Basari := True;
        Result.BelgeTuru := LMevcutBelgeTuru;
        Result.Alias := LMevcutAlias;
        Result.Mesaj := 'Izibiz sorgusu basarisiz ï¿½ mevcut alias kullaniliyor: ' + E.Message;
        Exit;
      end;
      Result.Basari := False;
      Result.Mesaj := 'Izibiz alias sorgusu hatasi: ' + E.Message;
      Exit;
    end;
  end;

  // 4) Sonuc degerlendirme
  if LIzibizAlias <> '' then begin
    // Mukellef ï¿½ LKodMukellef (151/141) ekle/reactivate
    if LVar and (LMevcutBelgeTuru = LKodMukellef) and
       SameText(LMevcutAlias, LIzibizAlias) then begin
      Veritabani.BasitKomutÇalýþtýr(AConnection,
        'UPDATE REHBERALIAS SET SONKONTROLTARIHI = GETDATE() WHERE ID = &ID',
        ['&ID'], [LMevcutID]);
      Result.Mesaj := 'Alias degismedi ï¿½ tarih guncellendi';
    end else begin
      var LEskiID: Integer := 0;
      if LVar then LEskiID := LMevcutID;
      RAliasUpsert(AConnection, ARehberID, LKodMukellef, LIzibizAlias, LEskiID);
      if LVar and (LMevcutBelgeTuru = LKodGenel) then
        Result.Mesaj := 'Cari mukellef oldu ï¿½ alias eklendi/reactivate'
      else
        Result.Mesaj := 'Mukellef alias eklendi/reactivate';
    end;
    Result.Basari := True;
    Result.BelgeTuru := LKodMukellef;
    Result.Alias := LIzibizAlias;
  end else if LIrsaliyeMi then begin
    // EIrsaliye + alias yok ï¿½ 140
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
    // EFatura akisinda mukellef DEGIL ï¿½ e-Arsiv flow (mail)
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

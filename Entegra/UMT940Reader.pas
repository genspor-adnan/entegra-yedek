unit UMT940Reader;

// MT940 SWIFT formatı parser'ı — Excel/CSV reader'dan tamamen bağımsız.
// MT940 satır tipleri:
//   :20: dosya referansı
//   :25: hesap kimliği
//   :28C: ekstre numarası
//   :60F/:60M: açılış bakiyesi
//   :61: işlem satırı (her bir hareket)
//   :86: önceki :61:'in detayı (çok satırlı)
//   :62F/:62M: kapanış bakiyesi
//
// Format kaynağı: SWIFT MT940 ISO 15022 dokümantasyonu.
// Türk bankalarının :86: alt yapısı (?20=karşı taraf adı, ?32=IBAN vb.)
// banka bazlı farklılaşır — burada heuristik parser kullanılır.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.DateUtils, System.RegularExpressions;

type
  TMT940Hareketi = record
    Tarih: TDateTime;          // Value date
    GirisTarih: TDateTime;     // Entry date
    Tutar: Currency;           // Pozitif değer
    BorcMu: Boolean;           // True = para çıkışı, False = giriş
    Doviz: string;             // TL, USD, EUR vs.
    IslemKodu: string;         // NTRF, NMSC, ATM, vs.
    Referans: string;          // :61:'deki referans
    BankaReferansi: string;    // :86:'da geçen banka ref
    Aciklama: string;          // :86: ham içerik
    KarsiTarafAd: string;      // :86: deki karşı taraf adı (heuristik)
    KarsiTarafIBAN: string;    // :86: deki IBAN (regex)
    KarsiTarafBanka: string;
  end;
  TMT940HareketListesi = TList<TMT940Hareketi>;

  TMT940Dosyasi = record
    DosyaReferansi: string;    // :20:
    HesapKimligi: string;      // :25:
    EkstreNo: string;          // :28C:
    BaslangicBakiye: Currency; // :60F:
    BaslangicBorcMu: Boolean;
    BaslangicTarih: TDateTime;
    Doviz: string;
    KapanisBakiye: Currency;
    KapanisBorcMu: Boolean;
    KapanisTarih: TDateTime;
    Hareketler: TMT940HareketListesi;
  end;

  TMT940Parser = class
  private
    FSatirlar: TStringList;
    FIndex: Integer;
    function MevcutSatir: string;
    procedure SonrakiSatir;
    function SatirinTipi(const S: string): string;  // ':20:', ':61:' vs.
    function IBANCikar(const S: string): string;    // TR + 24 rakam regex
    procedure ParseAcilisBakiye(const S: string; out Tutar: Currency;
                                out BorcMu: Boolean; out Tarih: TDateTime;
                                out Doviz: string);
    procedure Parse61(const S: string; var Hareket: TMT940Hareketi);
    procedure Parse86(const Detay: string; var Hareket: TMT940Hareketi);
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const DosyaYolu: string; out Sonuc: TMT940Dosyasi): Boolean;
  end;

implementation

{ TMT940Parser }

constructor TMT940Parser.Create;
begin
  inherited;
  FSatirlar := TStringList.Create;
end;

destructor TMT940Parser.Destroy;
begin
  FSatirlar.Free;
  inherited;
end;

function TMT940Parser.MevcutSatir: string;
begin
  if FIndex < FSatirlar.Count then Result := FSatirlar[FIndex]
  else Result := '';
end;

procedure TMT940Parser.SonrakiSatir;
begin
  Inc(FIndex);
end;

function TMT940Parser.SatirinTipi(const S: string): string;
// ':20:..' veya ':61:..' formatından tip stringi döner. Tip yoksa ''.
var
  P: Integer;
begin
  Result := '';
  if (S = '') or (S[1] <> ':') then Exit;
  P := Pos(':', S, 2);
  if P > 0 then Result := Copy(S, 1, P);
end;

function TMT940Parser.IBANCikar(const S: string): string;
// TR + 24 rakam (boşluklu olabilir): TR12 3456 7890 1234 5678 9012 34
var
  Eslesme: TMatch;
  Tmp: string;
begin
  Result := '';
  Eslesme := TRegEx.Match(UpperCase(S), 'TR\s*(\d[\s\d]{24,32})');
  if Eslesme.Success then begin
    Tmp := StringReplace(Eslesme.Value, ' ', '', [rfReplaceAll]);
    if Length(Tmp) = 26 then Result := Tmp;
  end;
end;

procedure TMT940Parser.ParseAcilisBakiye(const S: string; out Tutar: Currency;
  out BorcMu: Boolean; out Tarih: TDateTime; out Doviz: string);
// Format: :60F:CYYMMDDCCCnnnnnn,nn (C=Credit/D=Debit, CCC=para birimi)
// Örn: :60F:C260601TRY17907,11
var
  Govde, TutarStr: string;
  Yil, Ay, Gun: Integer;
  Eski: Char;
begin
  Tutar := 0; BorcMu := False; Tarih := 0; Doviz := '';
  // ':60F:' veya ':60M:' önekini at
  Govde := S;
  if Pos(':', Govde) = 1 then begin
    var P: Integer := Pos(':', Govde, 2);
    if P > 0 then Govde := Copy(Govde, P + 1, MaxInt);
  end;
  if Length(Govde) < 11 then Exit;

  BorcMu := UpCase(Govde[1]) = 'D';
  if not TryStrToInt('20' + Copy(Govde, 2, 2), Yil) then Exit;
  if not TryStrToInt(Copy(Govde, 4, 2), Ay) then Exit;
  if not TryStrToInt(Copy(Govde, 6, 2), Gun) then Exit;
  try
    Tarih := EncodeDate(Yil, Ay, Gun);
  except
    Tarih := 0;
  end;
  Doviz := Copy(Govde, 8, 3);
  TutarStr := StringReplace(Copy(Govde, 11, MaxInt), ',',
                            FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Eski := FormatSettings.DecimalSeparator;
  try
    FormatSettings.DecimalSeparator := FormatSettings.DecimalSeparator;
    if not TryStrToCurr(TutarStr, Tutar) then Tutar := 0;
  finally
    FormatSettings.DecimalSeparator := Eski;
  end;
end;

procedure TMT940Parser.Parse61(const S: string; var Hareket: TMT940Hareketi);
// :61:YYMMDD[MMDD][D|C|RD|RC|EC|ED][1-char funds]nnnnn,nn[N<3-char-type>]NONREF//ref...
// Örn: :61:2606070607DR5300,00NTRFNONREF//12345
var
  Govde, IslemTipi, RefStr: string;
  Yil, Ay, Gun, GAy, GGun, i, j: Integer;
  TutarStr: string;
  BorcCharLen: Integer;
begin
  Govde := S;
  if Pos(':', Govde) = 1 then begin
    var P: Integer := Pos(':', Govde, 2);
    if P > 0 then Govde := Copy(Govde, P + 1, MaxInt);
  end;
  // İlk 6: value date YYMMDD
  if Length(Govde) < 7 then Exit;
  if TryStrToInt('20' + Copy(Govde, 1, 2), Yil) and
     TryStrToInt(Copy(Govde, 3, 2), Ay) and
     TryStrToInt(Copy(Govde, 5, 2), Gun) then
    try Hareket.Tarih := EncodeDate(Yil, Ay, Gun); except Hareket.Tarih := 0; end;
  i := 7;
  // Opsiyonel giriş tarihi MMDD (4 rakam)
  if (i + 3 <= Length(Govde)) and (Govde[i] in ['0'..'9']) and
     (Govde[i+1] in ['0'..'9']) and (Govde[i+2] in ['0'..'9']) and
     (Govde[i+3] in ['0'..'9']) then begin
    if TryStrToInt(Copy(Govde, i, 2), GAy) and
       TryStrToInt(Copy(Govde, i+2, 2), GGun) then
      try Hareket.GirisTarih := EncodeDate(Yil, GAy, GGun); except end;
    Inc(i, 4);
  end;
  // Borç/Alacak göstergesi: D, C, RD, RC, EC, ED
  if i > Length(Govde) then Exit;
  BorcCharLen := 1;
  if (i + 1 <= Length(Govde)) and CharInSet(Govde[i], ['R','E']) and
     CharInSet(Govde[i+1], ['D','C']) then begin
    BorcCharLen := 2;
    Hareket.BorcMu := UpCase(Govde[i+1]) = 'D';
  end else
    Hareket.BorcMu := UpCase(Govde[i]) = 'D';
  Inc(i, BorcCharLen);
  // Opsiyonel funds code (1 letter)
  if (i <= Length(Govde)) and CharInSet(Govde[i], ['A'..'Z']) then
    Inc(i);
  // Tutar — sonraki harfe kadar oku
  j := i;
  while (j <= Length(Govde)) and CharInSet(Govde[j], ['0'..'9', ',', '.']) do
    Inc(j);
  TutarStr := StringReplace(Copy(Govde, i, j - i), ',',
                            FormatSettings.DecimalSeparator, [rfReplaceAll]);
  if not TryStrToCurr(TutarStr, Hareket.Tutar) then Hareket.Tutar := 0;
  i := j;
  // İşlem tipi — 'N' + 3 chars (NTRF, NMSC, NCHK, NDIV, vs.)
  if (i + 3 <= Length(Govde)) and (UpCase(Govde[i]) = 'N') then begin
    IslemTipi := Copy(Govde, i, 4);
    Hareket.IslemKodu := IslemTipi;
    Inc(i, 4);
  end;
  // Referans: '//' sonrası
  RefStr := Copy(Govde, i, MaxInt);
  var P: Integer := Pos('//', RefStr);
  if P > 0 then begin
    Hareket.Referans := Copy(RefStr, P + 2, MaxInt);
    // Multiline ek bilgi varsa devam edebilir
  end else
    Hareket.Referans := RefStr;
end;

procedure TMT940Parser.Parse86(const Detay: string; var Hareket: TMT940Hareketi);
// :86: çok satırlı serbest metin. IBAN regex'le, isim heuristik olarak çıkar.
// Bazı bankalar ?20=isim ?32=IBAN gibi tag yapısı kullanır.
var
  Tmp, Ad, Bnk: string;
  P, i: Integer;
begin
  Tmp := Detay;
  Hareket.Aciklama := Tmp;

  // IBAN
  Hareket.KarsiTarafIBAN := IBANCikar(Tmp);

  // ?20=<isim>?  ?32=<IBAN>?  ?108=<açıklama>?
  // SWIFT structured field formatları
  P := Pos('?20', Tmp);
  if P > 0 then begin
    Ad := Copy(Tmp, P + 3, MaxInt);
    i := Pos('?', Ad);
    if i > 0 then Ad := Copy(Ad, 1, i - 1);
    Hareket.KarsiTarafAd := Trim(Ad);
  end;
  P := Pos('?33', Tmp);
  if P > 0 then begin
    Bnk := Copy(Tmp, P + 3, MaxInt);
    i := Pos('?', Bnk);
    if i > 0 then Bnk := Copy(Bnk, 1, i - 1);
    Hareket.KarsiTarafBanka := Trim(Bnk);
  end;

  // Fallback — yapısal tag yoksa ilk satırı isim olarak al
  if Hareket.KarsiTarafAd = '' then begin
    var Satirlar := Tmp.Split([#13#10, #10, '/']);
    for var L in Satirlar do begin
      var Ltr: string := Trim(L);
      if (Ltr <> '') and (IBANCikar(Ltr) = '') and (Length(Ltr) >= 3) then begin
        Hareket.KarsiTarafAd := Ltr;
        Break;
      end;
    end;
  end;
end;

function TMT940Parser.Parse(const DosyaYolu: string;
  out Sonuc: TMT940Dosyasi): Boolean;
var
  Tip, Detay86: string;
  Hareket: TMT940Hareketi;
  HareketAktif: Boolean;
begin
  Result := False;
  Sonuc.Hareketler := TMT940HareketListesi.Create;
  try
    FSatirlar.LoadFromFile(DosyaYolu, TEncoding.ANSI);   // Çoğu banka cp1254
  except
    try FSatirlar.LoadFromFile(DosyaYolu, TEncoding.UTF8); except Exit; end;
  end;

  FIndex := 0;
  HareketAktif := False;
  Detay86 := '';
  Hareket := Default(TMT940Hareketi);

  while FIndex < FSatirlar.Count do begin
    var S: string := FSatirlar[FIndex];
    Tip := SatirinTipi(S);

    if Tip = '' then begin
      // Önceki :86:'ya ek satır mı? — başlangıç ':' yok demek
      if HareketAktif and (Trim(S) <> '') then
        Detay86 := Detay86 + sLineBreak + S;
      SonrakiSatir;
      Continue;
    end;

    // Yeni etiket başladığında, varsa biriken :86:'yı bitir
    if HareketAktif and (Tip <> ':86:') then begin
      Parse86(Detay86, Hareket);
      Sonuc.Hareketler.Add(Hareket);
      HareketAktif := False;
      Detay86 := '';
      Hareket := Default(TMT940Hareketi);
    end;

    if Tip = ':20:' then
      Sonuc.DosyaReferansi := Trim(Copy(S, 5, MaxInt))
    else if Tip = ':25:' then
      Sonuc.HesapKimligi := Trim(Copy(S, 5, MaxInt))
    else if Tip = ':28C:' then
      Sonuc.EkstreNo := Trim(Copy(S, 6, MaxInt))
    else if (Tip = ':60F:') or (Tip = ':60M:') then
      ParseAcilisBakiye(S, Sonuc.BaslangicBakiye, Sonuc.BaslangicBorcMu,
                        Sonuc.BaslangicTarih, Sonuc.Doviz)
    else if (Tip = ':62F:') or (Tip = ':62M:') then
      ParseAcilisBakiye(S, Sonuc.KapanisBakiye, Sonuc.KapanisBorcMu,
                        Sonuc.KapanisTarih, Sonuc.Doviz)
    else if Tip = ':61:' then begin
      Hareket := Default(TMT940Hareketi);
      Parse61(S, Hareket);
      HareketAktif := True;
      Detay86 := '';
    end
    else if Tip = ':86:' then begin
      if HareketAktif then
        Detay86 := Copy(S, 5, MaxInt);
    end;

    SonrakiSatir;
  end;

  // Son hareketi kaydet
  if HareketAktif then begin
    Parse86(Detay86, Hareket);
    Sonuc.Hareketler.Add(Hareket);
  end;

  Result := True;
end;

end.

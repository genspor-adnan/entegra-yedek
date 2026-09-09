unit UGS1Barkod;

{ ---------------------------------------------------------------------------
  GS1 barkod cozumleyici (AI = Uygulama Tanimlayici tabanli).

  Ekran ve veritabani bagimliligi YOKTUR; izleme ekrani, stok/hizmet arama ve
  stok arama frame'i ayni cozumleyiciyi kullanabilsin diye ayri birim yapildi.

  Desteklenen bicimler
  --------------------
  1) Bitisik GS1 (karekod / GS1-128):
         0106958698034224172803311034190003910 04
         01 + GTIN(14) , 17 + SKT(6) , 10 + Lot(degisken)
  2) Iki asamali "line" okuyucular: once yalniz urun, sonra lot + SKT
         1. okutma: 0106958698034224              -> btGS1UrunNo
         2. okutma: 17280331103419000391004       -> btGS1LotSkt
  3) Insan okunur parantezli bicim (bazi tedarikcilerin etiketi):
         (01) 8681489739128 (10) G-PBL3210233233 (17) 2029.03.20
  4) AI icermeyen duz urun numarasi (EAN-13 / UPC)      -> btDuzUrunNo

  Degisken uzunluklu alanlar (10, 21, ...) normalde FNC1/GS (#29) ile biter.
  El terminalleri bu karakteri sik sik yutar; ayirici yoksa cozumleyici olasi
  butun boluntuleri dener ve EN COK ALAN ureten boluntuyu secer. Ornegin
  "...10PBL481223041917280715 11230715" verisinde lotu 17'nin baslangicina
  kadar uzatmak 3 alan uretirken, sonuna kadar uzatmak 2 alan uretir; dogru
  olan uc alanlisidir.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.DateUtils, System.StrUtils, System.Math;

const
  GS1_AYIRICI = #29;   // FNC1 / GS - degisken uzunluklu alanin sonu

type
  TGS1Alan = record
    AI: string;
    Deger: string;
  end;

  TBarkodTuru = (
    btBilinmiyor,   //< cozulemedi
    btGS1Tam,       //< urun + izleme bilgisi tek okutmada (karekod)
    btGS1UrunNo,    //< yalniz urun no (iki asamalinin 1. okutmasi)
    btGS1LotSkt,    //< urun no yok, lot/SKT/seri var (2. okutma)
    btDuzUrunNo     //< AI yok, duz numara (EAN-13 / UPC / dahili urun no)
  );

  TGS1Bilgi = record
    Ham: string;
    Tur: TBarkodTuru;
    Gtin: string;          //< AI 01/02, 14 hane
    UrunNo: string;        //< GTIN'in bastaki sifirlari atilmis hali
    Lot: string;           //< AI 10
    SeriNo: string;        //< AI 21
    Skt: TDateTime;        //< AI 17
    SktVar: Boolean;
    Uretim: TDateTime;     //< AI 11
    UretimVar: Boolean;
    Miktar: Double;        //< AI 30 (adet)
    MiktarVar: Boolean;
    Alanlar: TArray<TGS1Alan>;
    function AlanVar(const AAI: string): Boolean;
    function Alan(const AAI: string): string;
    function UrunVar: Boolean;      //< urun numarasi tasiyor mu
    function IzlemeVar: Boolean;    //< lot / seri / SKT tasiyor mu
  end;

/// Barkodu cozer. Basarisizsa Sonuc False ve Bilgi.Tur = btBilinmiyor.
function GS1Coz(const ABarkod: string; out ABilgi: TGS1Bilgi): Boolean;

/// GTIN-8/12/13/14 kontrol hanesi dogrulamasi.
function GtinGecerli(const AGtin: string): Boolean;

/// Bastaki sifirlari atar: '08681489789024' -> '8681489789024'
function UrunNoNormalize(const ADeger: string): string;

/// YYAAGG / YYYYAAGG / gg.aa.yyyy / yyyy.aa.gg cozer. Gun 00 ise ayin sonu.
function GS1TarihCoz(const ADeger: string; out ATarih: TDateTime): Boolean;

implementation

type
  TAITanim = record
    AI: string;
    Uzunluk: Integer;   //< sabit uzunluk; 0 ise degisken
    EnFazla: Integer;   //< degiskende ust sinir
  end;

const
  // Saglik/tibbi malzeme etiketlerinde gecen AI'lar. Liste uzatilabilir;
  // tanimsiz bir AI ile karsilasilirsa cozumleme basarisiz olur ve arayuz
  // eski (BARKODAYARLAR) yoluna duser.
  AITablosu: array[0..30] of TAITanim = (
    (AI: '00';  Uzunluk: 18; EnFazla: 18),   // SSCC
    (AI: '01';  Uzunluk: 14; EnFazla: 14),   // GTIN
    (AI: '02';  Uzunluk: 14; EnFazla: 14),   // ic paket GTIN
    (AI: '10';  Uzunluk: 0;  EnFazla: 20),   // parti / lot
    (AI: '11';  Uzunluk: 6;  EnFazla: 6),    // uretim tarihi
    (AI: '12';  Uzunluk: 6;  EnFazla: 6),    // vade
    (AI: '13';  Uzunluk: 6;  EnFazla: 6),    // paketleme
    (AI: '15';  Uzunluk: 6;  EnFazla: 6),    // tavsiye edilen son kullanim
    (AI: '16';  Uzunluk: 6;  EnFazla: 6),    // satis son tarihi
    (AI: '17';  Uzunluk: 6;  EnFazla: 6),    // son kullanma tarihi
    (AI: '20';  Uzunluk: 2;  EnFazla: 2),    // varyant
    (AI: '21';  Uzunluk: 0;  EnFazla: 20),   // seri no
    (AI: '22';  Uzunluk: 0;  EnFazla: 20),   // eski saglik verisi
    (AI: '30';  Uzunluk: 0;  EnFazla: 8),    // adet
    (AI: '37';  Uzunluk: 0;  EnFazla: 8),    // lojistik adet
    (AI: '240'; Uzunluk: 0;  EnFazla: 30),   // ek urun tanimi
    (AI: '241'; Uzunluk: 0;  EnFazla: 30),   // musteri parca no
    (AI: '250'; Uzunluk: 0;  EnFazla: 30),   // ikincil seri
    (AI: '251'; Uzunluk: 0;  EnFazla: 30),   // kaynak referansi
    (AI: '400'; Uzunluk: 0;  EnFazla: 30),   // siparis no
    (AI: '401'; Uzunluk: 0;  EnFazla: 30),   // sevkiyat no
    (AI: '90';  Uzunluk: 0;  EnFazla: 30),   // taraflar arasi dahili
    (AI: '91';  Uzunluk: 0;  EnFazla: 30),   // 91..99: firma ici dahili alanlar
    (AI: '92';  Uzunluk: 0;  EnFazla: 30),
    (AI: '93';  Uzunluk: 0;  EnFazla: 30),
    (AI: '94';  Uzunluk: 0;  EnFazla: 30),
    (AI: '95';  Uzunluk: 0;  EnFazla: 30),
    (AI: '96';  Uzunluk: 0;  EnFazla: 30),
    (AI: '97';  Uzunluk: 0;  EnFazla: 30),
    (AI: '98';  Uzunluk: 0;  EnFazla: 30),
    (AI: '99';  Uzunluk: 0;  EnFazla: 30)
  );

{ ---------------------------------------------------------------- yardimcilar }

function SadeceRakam(const S: string): Boolean;
var
  I: Integer;
begin
  Result := S <> '';
  for I := Low(S) to High(S) do
    if not CharInSet(S[I], ['0'..'9']) then
      Exit(False);
end;

function UrunNoNormalize(const ADeger: string): string;
var
  I: Integer;
begin
  Result := Trim(ADeger);
  I := 1;
  while (I < Length(Result)) and (Result[I] = '0') do
    Inc(I);
  Result := Copy(Result, I, MaxInt);
end;

function GtinGecerli(const AGtin: string): Boolean;
var
  Kod: string;
  I, Toplam, Agirlik, Hane: Integer;
begin
  Kod := Trim(AGtin);
  if not SadeceRakam(Kod) then
    Exit(False);
  if not (Length(Kod) in [8, 12, 13, 14]) then
    Exit(False);

  // Sagdan sola: kontrol hanesinin solundaki ilk hane 3, sonra 1 ...
  Toplam := 0;
  Agirlik := 3;
  for I := Length(Kod) - 1 downto 1 do
  begin
    Toplam := Toplam + StrToInt(Kod[I]) * Agirlik;
    if Agirlik = 3 then Agirlik := 1 else Agirlik := 3;
  end;
  Hane := (10 - (Toplam mod 10)) mod 10;
  Result := Hane = StrToInt(Kod[Length(Kod)]);
end;

function GS1TarihCoz(const ADeger: string; out ATarih: TDateTime): Boolean;
var
  S: string;
  Yil, Ay, Gun: Integer;
begin
  Result := False;
  ATarih := 0;
  S := Trim(ADeger);
  if S = '' then
    Exit;

  S := StringReplace(S, '/', '.', [rfReplaceAll]);
  S := StringReplace(S, '-', '.', [rfReplaceAll]);

  if (Length(S) = 6) and SadeceRakam(S) then
  begin
    // YYAAGG. Yuzyil GS1 kurali: bugune gore +50 / -49 penceresi.
    Yil := (YearOf(Date) div 100) * 100 + StrToInt(Copy(S, 1, 2));
    if Yil - YearOf(Date) > 50 then
      Dec(Yil, 100)
    else if YearOf(Date) - Yil > 49 then
      Inc(Yil, 100);
    Ay  := StrToInt(Copy(S, 3, 2));
    Gun := StrToInt(Copy(S, 5, 2));
  end
  else if (Length(S) = 8) and SadeceRakam(S) then
  begin
    Yil := StrToInt(Copy(S, 1, 4));
    Ay  := StrToInt(Copy(S, 5, 2));
    Gun := StrToInt(Copy(S, 7, 2));
  end
  else if (Length(S) = 10) and (S[3] = '.') then      // gg.aa.yyyy
  begin
    Gun := StrToIntDef(Copy(S, 1, 2), 0);
    Ay  := StrToIntDef(Copy(S, 4, 2), 0);
    Yil := StrToIntDef(Copy(S, 7, 4), 0);
  end
  else if (Length(S) = 10) and (S[5] = '.') then      // yyyy.aa.gg
  begin
    Yil := StrToIntDef(Copy(S, 1, 4), 0);
    Ay  := StrToIntDef(Copy(S, 6, 2), 0);
    Gun := StrToIntDef(Copy(S, 9, 2), 0);
  end
  else
    Exit;

  if (Ay < 1) or (Ay > 12) or (Yil < 1900) then
    Exit;

  // GS1'de gun 00 "ayin son gunu" demektir.
  if Gun = 0 then
    Gun := DaysInAMonth(Yil, Ay);
  if (Gun < 1) or (Gun > DaysInAMonth(Yil, Ay)) then
    Exit;

  Result := TryEncodeDate(Yil, Ay, Gun, ATarih);
end;

{ ------------------------------------------------------------- AI cozumleme }

function OlcuAIMi(const S: string): Boolean;
var
  Uc: string;
begin
  // 310n..316n agirlik, 320n..336n hacim/olcu, 340n..357n, 360n..369n
  Result := False;
  if Length(S) <> 4 then
    Exit;
  if not SadeceRakam(S) then
    Exit;
  Uc := Copy(S, 1, 3);
  Result := ((Uc >= '310') and (Uc <= '316')) or
            ((Uc >= '320') and (Uc <= '336')) or
            ((Uc >= '340') and (Uc <= '357')) or
            ((Uc >= '360') and (Uc <= '369'));
end;

function AIBul(const S: string; ABas: Integer; out AAI: string;
  out AUzunluk: Integer; out ADegisken: Boolean; out AEnFazla: Integer): Boolean;
var
  I, Boy: Integer;
  Aday: string;
begin
  Result := False;
  if ABas > Length(S) then
    Exit;

  Aday := Copy(S, ABas, 4);
  if OlcuAIMi(Aday) then
  begin
    AAI := Aday; AUzunluk := 6; ADegisken := False; AEnFazla := 6;
    Exit(True);
  end;

  // Once 3 haneli AI'lar, sonra 2 haneliler denenir.
  for Boy := 3 downto 2 do
  begin
    Aday := Copy(S, ABas, Boy);
    if Length(Aday) < Boy then
      Continue;
    for I := Low(AITablosu) to High(AITablosu) do
      if AITablosu[I].AI = Aday then
      begin
        AAI       := Aday;
        AUzunluk  := AITablosu[I].Uzunluk;
        ADegisken := AITablosu[I].Uzunluk = 0;
        AEnFazla  := AITablosu[I].EnFazla;
        Exit(True);
      end;
  end;
end;

/// Bir GS1 dizisinde ayni AI iki kez gecmez. Ayirici yutulmus barkodlarda
/// lotun icindeki rakamlar AI sanilip lot parcalanabiliyor
/// ("(10)341 (90)0039 (10)04"); tekrar eden AI o coumu eler.
/// Ayirici yutulmusken degisken alanin nerede bittigi belirsizdir. Yalnizca
/// KENDINI DOGRULAYAN bir AI'nin basladigi yerde bolmeye izin veririz: tarih
/// alanlari gecerli bir tarih, GTIN alanlari gecerli kontrol hanesi tasimak
/// zorundadir. Boylece lotun icindeki rakamlar "(30)419" gibi uydurma
/// alanlara bolunemez; bolunme ancak "(17)280715" gibi kanitli bir yerde olur.
function GucluAI(const AAI, ADeger: string): Boolean;
var
  Tarih: TDateTime;
begin
  // Yalnizca SKT ve GTIN: bunlar lottan hemen sonra gelen tipik alanlar ve
  // ikisi de kendini dogrular. Digerlerini (11 uretim, 12 vade ...) bolme
  // noktasi saymayiz; onlar zaten sabit uzunluklu bir alandan sonra gelirse
  // belirsizlik olmadan zincirlenir.
  if AAI = '17' then
    Result := GS1TarihCoz(ADeger, Tarih)
  else if (AAI = '01') or (AAI = '02') then
    Result := GtinGecerli(ADeger)
  else
    Result := False;
end;

/// Ayirici yutulmus barkodda degisken alani bitiren ikinci kural.
/// MicroPort/NUMEN gibi ureticiler lottan sonra firma ici bir alan basiyor:
///   etikette "(17) 280331 (10) 34220004 (91) 001", okuyucudan
///   "17280331103422000491001" -- FNC1 gelmiyor, lot 8 hane olmasina ragmen
///   "3422000491001" olarak yapisik okunuyordu.
/// AI 91..99 kendini dogrulamadigi icin GucluAI bunu kabul edemez; bolmeyi
/// yalnizca su dar kalibin hepsi tutunca aciyoruz:
///   - dahili alan dizinin SONU (arkasindan baska alan gelmiyor),
///   - AI 91..99 (90 haric: kisa rakam dizilerinde cok daha sik yanlis eslesir),
///   - dahili alanin degeri 2..4 hane, salt rakam,
///   - kapanan degisken alan (lot/seri) en az 6 hane ve salt rakam.
/// Boylece "262900" gibi kisa sayisal lotlar ve "PBL4812230419" gibi
/// alfanumerik lotlar bolunmez; kalip yalnizca gercek ureticide tutar.
function DahiliSonAI(const AKuyruk: TArray<TGS1Alan>; const AKapanan: string): Boolean;
var
  Tail: string;
begin
  Result := False;
  if Length(AKuyruk) <> 1 then
    Exit;
  if (Length(AKuyruk[0].AI) <> 2) or (AKuyruk[0].AI[1] <> '9') or
     (AKuyruk[0].AI[2] < '1') then
    Exit;
  Tail := AKuyruk[0].Deger;
  if (Length(Tail) < 2) or (Length(Tail) > 4) or not SadeceRakam(Tail) then
    Exit;
  if (Length(AKapanan) < 6) or not SadeceRakam(AKapanan) then
    Exit;
  Result := True;
end;

function AIVarMi(const AAlanlar: TArray<TGS1Alan>; const AAI: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(AAlanlar) do
    if AAlanlar[I].AI = AAI then
      Exit(True);
end;

function AlanEkle(const AAI, ADeger: string;
  const AKuyruk: TArray<TGS1Alan>): TArray<TGS1Alan>;
var
  I: Integer;
begin
  SetLength(Result, Length(AKuyruk) + 1);
  Result[0].AI := AAI;
  Result[0].Deger := ADeger;
  for I := 0 to High(AKuyruk) do
    Result[I + 1] := AKuyruk[I];
end;

/// ABas'tan sonunu cozer. Ayirici yoksa en cok alan ureten boluntuyu secer.
function EnIyiCoz(const S: string; ABas: Integer;
  out AAlanlar: TArray<TGS1Alan>): Boolean;
var
  AI, Deger, EnIyiDeger: string;
  Uzunluk, EnFazla, VeriBas, GSYeri, Boy, UstSinir: Integer;
  Degisken, Bulundu: Boolean;
  Kuyruk, EnIyiKuyruk: TArray<TGS1Alan>;
begin
  SetLength(AAlanlar, 0);
  if ABas > Length(S) then
    Exit(True);                       // veri bitti: gecerli cozum

  if not AIBul(S, ABas, AI, Uzunluk, Degisken, EnFazla) then
    Exit(False);

  VeriBas := ABas + Length(AI);

  if not Degisken then
  begin
    if Length(S) - VeriBas + 1 < Uzunluk then
      Exit(False);
    Deger := Copy(S, VeriBas, Uzunluk);
    if not EnIyiCoz(S, VeriBas + Uzunluk, Kuyruk) then
      Exit(False);
    if AIVarMi(Kuyruk, AI) then
      Exit(False);
    AAlanlar := AlanEkle(AI, Deger, Kuyruk);
    Exit(True);
  end;

  // Degisken uzunluklu alan: once ayiriciya bak.
  GSYeri := Pos(GS1_AYIRICI, S, VeriBas);
  if GSYeri > 0 then
  begin
    Deger := Copy(S, VeriBas, GSYeri - VeriBas);
    if (Deger = '') or (Length(Deger) > EnFazla) then
      Exit(False);
    if not EnIyiCoz(S, GSYeri + 1, Kuyruk) then
      Exit(False);
    if AIVarMi(Kuyruk, AI) then
      Exit(False);
    AAlanlar := AlanEkle(AI, Deger, Kuyruk);
    Exit(True);
  end;

  // Ayirici yok: butun boluntuleri dene, en cok alan ureteni sec.
  Bulundu := False;
  UstSinir := Min(EnFazla, Length(S) - VeriBas + 1);
  for Boy := UstSinir downto 1 do
  begin
    Deger := Copy(S, VeriBas, Boy);
    if not EnIyiCoz(S, VeriBas + Boy, Kuyruk) then
      Continue;
    if AIVarMi(Kuyruk, AI) then
      Continue;
    // Veri sonuna kadar giden aday her zaman gecerli (GS1 varsayilani);
    // erken bolunme ancak kanitli bir AI ile kabul edilir.
    if (Length(Kuyruk) > 0) and
       not GucluAI(Kuyruk[0].AI, Kuyruk[0].Deger) and
       not DahiliSonAI(Kuyruk, Deger) then
      Continue;
    // Esitlikte ilk aday kazanir; dongu en uzundan basladigi icin bu, GS1'in
    // "degisken alan veri sonuna kadar surer" varsayilanini korur.
    if (not Bulundu) or (Length(Kuyruk) > Length(EnIyiKuyruk)) then
    begin
      EnIyiKuyruk := Kuyruk;
      EnIyiDeger  := Deger;
      Bulundu     := True;
    end;
  end;

  if not Bulundu then
    Exit(False);
  AAlanlar := AlanEkle(AI, EnIyiDeger, EnIyiKuyruk);
  Result := True;
end;

/// "(01) 8681489739128 (10) G-PBL... (17) 2029.03.20" bicimi.
function ParantezliCoz(const S: string; out AAlanlar: TArray<TGS1Alan>): Boolean;
var
  I, Kapanis: Integer;
  AI, Deger: string;
begin
  SetLength(AAlanlar, 0);
  I := 1;
  while I <= Length(S) do
  begin
    if S[I] <> '(' then
    begin
      Inc(I);
      Continue;
    end;
    Kapanis := PosEx(')', S, I + 1);
    if Kapanis = 0 then
      Break;
    AI := Trim(Copy(S, I + 1, Kapanis - I - 1));

    I := Kapanis + 1;
    Deger := '';
    while (I <= Length(S)) and (S[I] <> '(') do
    begin
      Deger := Deger + S[I];
      Inc(I);
    end;
    Deger := Trim(Deger);
    if (AI <> '') and (Deger <> '') then
      AAlanlar := AlanEkle(AI, Deger, AAlanlar);
  end;
  Result := Length(AAlanlar) > 0;
end;

{ ------------------------------------------------------------- TGS1Bilgi }

function TGS1Bilgi.Alan(const AAI: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Alanlar) do
    if Alanlar[I].AI = AAI then
      Exit(Alanlar[I].Deger);
end;

function TGS1Bilgi.AlanVar(const AAI: string): Boolean;
begin
  Result := Alan(AAI) <> '';
end;

function TGS1Bilgi.UrunVar: Boolean;
begin
  Result := UrunNo <> '';
end;

function TGS1Bilgi.IzlemeVar: Boolean;
begin
  Result := (Lot <> '') or (SeriNo <> '') or SktVar;
end;

{ ------------------------------------------------------------------ GS1Coz }

function GS1Coz(const ABarkod: string; out ABilgi: TGS1Bilgi): Boolean;
var
  S, Ondalik: string;
  Alanlar: TArray<TGS1Alan>;
  I: Integer;
begin
  ABilgi := Default(TGS1Bilgi);
  ABilgi.Ham := ABarkod;
  ABilgi.Tur := btBilinmiyor;

  S := Trim(ABarkod);
  if S = '' then
    Exit(False);

  // Bazi okuyucular basa sembol tanimlayici koyar: ]d2 , ]C1 , ]e0
  if (Length(S) > 3) and (S[1] = ']') then
    S := Copy(S, 4, MaxInt);

  if Pos('(', S) > 0 then
  begin
    if not ParantezliCoz(S, Alanlar) then
      Exit(False);
  end
  else
  begin
    S := StringReplace(S, ' ', '', [rfReplaceAll]);   // etikette bosluk olabilir
    if not EnIyiCoz(S, 1, Alanlar) then
    begin
      // AI yok: duz urun numarasi olabilir (EAN-13 / UPC / dahili no)
      if SadeceRakam(S) and (Length(S) >= 6) and (Length(S) <= 14) then
      begin
        ABilgi.UrunNo := UrunNoNormalize(S);
        ABilgi.Gtin   := S;
        ABilgi.Tur    := btDuzUrunNo;
        Exit(True);
      end;
      Exit(False);
    end;
  end;

  ABilgi.Alanlar := Alanlar;
  for I := 0 to High(Alanlar) do
  begin
    if (Alanlar[I].AI = '01') or (Alanlar[I].AI = '02') then
    begin
      ABilgi.Gtin   := Alanlar[I].Deger;
      ABilgi.UrunNo := UrunNoNormalize(Alanlar[I].Deger);
    end
    else if Alanlar[I].AI = '10' then
      ABilgi.Lot := Alanlar[I].Deger
    else if Alanlar[I].AI = '21' then
      ABilgi.SeriNo := Alanlar[I].Deger
    else if Alanlar[I].AI = '17' then
      ABilgi.SktVar := GS1TarihCoz(Alanlar[I].Deger, ABilgi.Skt)
    else if Alanlar[I].AI = '11' then
      ABilgi.UretimVar := GS1TarihCoz(Alanlar[I].Deger, ABilgi.Uretim)
    else if Alanlar[I].AI = '30' then
    begin
      ABilgi.MiktarVar := TryStrToFloat(Alanlar[I].Deger, ABilgi.Miktar);
      if not ABilgi.MiktarVar then
        ABilgi.Miktar := 0;
    end
    else if OlcuAIMi(Alanlar[I].AI) then
    begin
      // 310n: son hane ondalik basamak sayisi (3103 = kg, 3 basamak)
      Ondalik := Copy(Alanlar[I].AI, 4, 1);
      ABilgi.MiktarVar := TryStrToFloat(Alanlar[I].Deger, ABilgi.Miktar);
      if ABilgi.MiktarVar then
        ABilgi.Miktar := ABilgi.Miktar / IntPower(10, StrToIntDef(Ondalik, 0));
    end;
  end;

  // GTIN kontrol hanesi tutmuyorsa urun numarasina guvenmeyelim.
  if (ABilgi.Gtin <> '') and not GtinGecerli(ABilgi.Gtin) then
  begin
    ABilgi.Gtin := '';
    ABilgi.UrunNo := '';
  end;

  if ABilgi.UrunVar and ABilgi.IzlemeVar then
    ABilgi.Tur := btGS1Tam
  else if ABilgi.UrunVar then
    ABilgi.Tur := btGS1UrunNo
  else if ABilgi.IzlemeVar then
    ABilgi.Tur := btGS1LotSkt
  else
    ABilgi.Tur := btBilinmiyor;

  Result := ABilgi.Tur <> btBilinmiyor;
end;

end.

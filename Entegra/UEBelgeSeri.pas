unit UEBelgeSeri;

// ============================================================================
//  E-BELGE SERI KURALLARI - TEK KAYNAK
//
//  Seri kurallari GENINI'de tek metin alaninda tutulur:
//
//      BOLUM   : -24130 e-Fatura | -24131 e-Arsiv | -24133 e-Irsaliye
//      DIL     : -1
//      ANAHTAR : 'SERI,SENARYO,KULLANICIID[,AKTIF]'     <- alanlar SOLDAN sayilir
//      SIRA    : ayni oncelikteki kurallar arasinda siralama
//      DEGER   : kural numarasi (benzersizlik icin)
//
//  4. alan (AKTIF) sonradan eklendi; 4. alani olmayan ESKI kayitlar AKTIF sayilir.
//
//  NEDEN BU UNIT VAR
//    Bu bicim once UOpsiyonFatura'da (yazma + ekranda listeleme), sonra
//    UEBelgeOlusturucu'da (belge keserken seri secimi) AYRI AYRI ayristiriliyordu;
//    ustelik SQL icinde, motora ozel fonksiyonlarla:
//      - MSSQL parsename() SAGDAN sayar  -> 4 alanli kayitlarda KULLANICIID yerine
//        AKTIF okunuyordu; ekran bu kaymis degeri geri kaydedince veri bozuluyordu.
//      - PG split_part indisleri virgul sayisindan hesaplaniyordu -> ayni kayma.
//    Sonuc: hicbir seri kullaniciya uymuyor ve "gecerli ilk seri tanimi yok"
//    hatasi aliniyordu (onarim: GenDepoUpdate170/171).
//
//    Bu yuzden ayristirma/yazma artik SQL'de DEGIL burada, tek yerde ve iki
//    veri motorunda birebir ayni sekilde yapilir. SQL yalnizca ham satiri getirir.
// ============================================================================

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client;

const
  SeriKarakterSayisi = 3;          // belge serisi tam 3 karakter olmalidir

type
  TSeriKurali = record
    Bolum       : Integer;
    Seri        : string;
    Senaryo     : Integer;         // 0 = tum senaryolar
    KullaniciID : Integer;         // 0 = tum kullanicilar (REHBER.ID)
    Aktif       : Boolean;
    Sira        : Integer;
    Deger       : Integer;
    /// GENINI.ANAHTAR karsiligi
    function Anahtar: string;
    /// Kural verilen senaryo/kullanici icin kullanilabilir mi?
    function Uyar(ASenaryo, AKullaniciID: Integer): Boolean;
    /// 1 = tam eslesme ... 4 = genel kural (kucuk deger once gelir)
    function Oncelik(ASenaryo, AKullaniciID: Integer): Integer;
    /// Kural neden elendi? (tani metni; uyuyorsa bos doner)
    function ElenmeNedeni(ASenaryo, AKullaniciID: Integer): string;
  end;

  TSeriKurallari = TArray<TSeriKurali>;

/// ANAHTAR metnini alanlarina ayirir. Alanlar SOLDAN sayilir; 4. alan yoksa Aktif = True.
function SeriAnahtarCoz(const AAnahtar: string): TSeriKurali;
/// Kurali ANAHTAR metnine cevirir (her zaman 4 alanli yazar).
function SeriAnahtarYaz(const AKural: TSeriKurali): string;
/// Belge turune gore hangi kural setine bakilacagini soyler (GENINI.BOLUM).
function SeriKuralBolumu(ATur, ABelgeTuru: Integer): Integer;
/// Verilen BOLUM'lerdeki tum kurallari okur (aktif/pasif ayrimi yapmaz).
function SeriKurallariOku(AConnection: TFDConnection;
  const ABolumler: array of Integer): TSeriKurallari;
/// Kullanilabilir serileri oncelik sirasiyla dondurur (pasifler haric, tekrarsiz).
function UygunSeriler(AConnection: TFDConnection;
  ATur, ABelgeTuru, ASenaryo, AKullaniciID: Integer): TArray<string>;
/// Son UygunSeriler cagrisinin tanisi (hata mesajlarinda gosterilir).
function SeriTanisi: string;

implementation

uses
  UEBelgeAliasServis, PrjConst;

var
  FSonTani: string = '';

{ TSeriKurali }

function TSeriKurali.Anahtar: string;
begin
  Result := Trim(Seri) + ',' + IntToStr(Senaryo) + ',' + IntToStr(KullaniciID) + ',' +
            IntToStr(Ord(Aktif));
end;

function TSeriKurali.Uyar(ASenaryo, AKullaniciID: Integer): Boolean;
begin
  Result := (Trim(Seri) <> '') and Aktif and
            ((Senaryo = 0) or (Senaryo = ASenaryo)) and
            ((KullaniciID = 0) or (KullaniciID = AKullaniciID));
end;

function TSeriKurali.Oncelik(ASenaryo, AKullaniciID: Integer): Integer;
begin
  if (Senaryo = ASenaryo) and (KullaniciID = AKullaniciID) then
    Result := 1                                    // senaryo + kullanici tam eslesme
  else if (Senaryo = 0) and (KullaniciID = AKullaniciID) then
    Result := 2                                    // tum senaryolar + kullanici
  else if (Senaryo = ASenaryo) and (KullaniciID = 0) then
    Result := 3                                    // senaryo + tum kullanicilar
  else
    Result := 4;                                   // genel kural
end;

function TSeriKurali.ElenmeNedeni(ASenaryo, AKullaniciID: Integer): string;
begin
  if Trim(Seri) = '' then
    Result := 'seri bos'
  else if not Aktif then
    Result := 'pasif'
  else if (Senaryo <> 0) and (Senaryo <> ASenaryo) then
    Result := Format('senaryo %d <> %d', [Senaryo, ASenaryo])
  else if (KullaniciID <> 0) and (KullaniciID <> AKullaniciID) then
    Result := Format('kullanici %d <> %d', [KullaniciID, AKullaniciID])
  else
    Result := '';
end;

{ ---------------------------------------------------------------- }

function SeriAnahtarCoz(const AAnahtar: string): TSeriKurali;
var
  LParcalar: TStringList;
begin
  Result := Default(TSeriKurali);
  Result.Aktif := True;                    // 4. alan yoksa (eski kayit) aktif sayilir
  LParcalar := TStringList.Create;
  try
    LParcalar.StrictDelimiter := True;
    LParcalar.Delimiter := ',';
    LParcalar.DelimitedText := AAnahtar;
    if LParcalar.Count > 0 then Result.Seri        := Trim(LParcalar[0]);
    if LParcalar.Count > 1 then Result.Senaryo     := StrToIntDef(Trim(LParcalar[1]), 0);
    if LParcalar.Count > 2 then Result.KullaniciID := StrToIntDef(Trim(LParcalar[2]), 0);
    if LParcalar.Count > 3 then Result.Aktif       := Trim(LParcalar[3]) <> '0';
  finally
    LParcalar.Free;
  end;
end;

function SeriAnahtarYaz(const AKural: TSeriKurali): string;
begin
  Result := AKural.Anahtar;
end;

function SeriKuralBolumu(ATur, ABelgeTuru: Integer): Integer;
begin
  if ATur = EBelgeTuruEIrsaliye then
    Result := Ops_FaturaOpsiyon_EIrsaliyeSeriKurallari
  else if ABelgeTuru = RAlias_EArsiv then
    Result := Ops_FaturaOpsiyon_EArsivSeriKurallari
  else
    Result := Ops_FaturaOpsiyon_EFaturaSeriKurallari;
end;

function SeriKurallariOku(AConnection: TFDConnection;
  const ABolumler: array of Integer): TSeriKurallari;
var
  LQ: TFDQuery;
  LBolumListe: string;
  i: Integer;
  LKural: TSeriKurali;
begin
  Result := nil;
  if Length(ABolumler) = 0 then
    Exit;

  LBolumListe := '';
  for i := Low(ABolumler) to High(ABolumler) do begin
    if LBolumListe <> '' then
      LBolumListe := LBolumListe + ',';
    LBolumListe := LBolumListe + IntToStr(ABolumler[i]);
  end;

  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConnection;
    // Ham satir; ayristirma Pascal'da. Iki motorda da ayni SQL.
    LQ.SQL.Text :=
      'select BOLUM, ANAHTAR, DEGER, SIRA from GENINI' +
      ' where BOLUM in (' + LBolumListe + ') and DIL=-1' +
      ' order by BOLUM, coalesce(SIRA,0), ANAHTAR';
    LQ.Open;
    while not LQ.Eof do begin
      LKural := SeriAnahtarCoz(LQ.FieldByName('ANAHTAR').AsString);
      LKural.Bolum := LQ.FieldByName('BOLUM').AsInteger;
      LKural.Sira  := LQ.FieldByName('SIRA').AsInteger;
      LKural.Deger := LQ.FieldByName('DEGER').AsInteger;
      Result := Result + [LKural];
      LQ.Next;
    end;
  finally
    LQ.Free;
  end;
end;

function UygunSeriler(AConnection: TFDConnection;
  ATur, ABelgeTuru, ASenaryo, AKullaniciID: Integer): TArray<string>;
var
  LBolum, LOncelik, i: Integer;
  LKurallar: TSeriKurallari;
  LListe: TStringList;
  LNeden: string;
begin
  Result := nil;
  LBolum := SeriKuralBolumu(ATur, ABelgeTuru);
  LKurallar := SeriKurallariOku(AConnection, [LBolum]);

  // Tani: seri bulunamazsa hata mesajinda gosterilir.
  FSonTani := Format('BOLUM=%d  Senaryo=%d  KullaniciID=%d', [LBolum, ASenaryo, AKullaniciID]);
  if Length(LKurallar) = 0 then
    FSonTani := FSonTani + sLineBreak + 'Bu BOLUM icin GENINI''de hic kayit yok.';
  for i := Low(LKurallar) to High(LKurallar) do begin
    LNeden := LKurallar[i].ElenmeNedeni(ASenaryo, AKullaniciID);
    FSonTani := FSonTani + sLineBreak + '[' + LKurallar[i].Anahtar + '] ';
    if LNeden = '' then
      FSonTani := FSonTani + 'UYGUN (' + LKurallar[i].Seri + ')'
    else
      FSonTani := FSonTani + 'ELENDI: ' + LNeden;
  end;

  LListe := TStringList.Create;
  try
    LListe.Duplicates := dupIgnore;
    // SeriKurallariOku zaten SIRA'ya gore sirali getirir; oncelik gruplarini
    // sirayla gezerek grup ici SIRA duzenini koruyoruz.
    for LOncelik := 1 to 4 do
      for i := Low(LKurallar) to High(LKurallar) do
        if LKurallar[i].Uyar(ASenaryo, AKullaniciID) and
           (LKurallar[i].Oncelik(ASenaryo, AKullaniciID) = LOncelik) and
           (LListe.IndexOf(LKurallar[i].Seri) < 0) then
          LListe.Add(LKurallar[i].Seri);

    for i := 0 to LListe.Count - 1 do
      Result := Result + [LListe[i]];
  finally
    LListe.Free;
  end;
end;

function SeriTanisi: string;
begin
  Result := FSonTani;
end;

end.

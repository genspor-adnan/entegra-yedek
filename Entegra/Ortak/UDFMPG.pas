unit UDFMPG;

// ============================================================
// UDFMPG — DFM SQL bilesenlerinin PG karsiliklari (yalniz CETREFIL olanlar).
// ------------------------------------------------------------
// Merkezi PgSqlCevir basit diyalekt farklarini (isnull/top/getdate/alias=/[bracket]/@var-inline/
//   string+) otomatik cevirir; cogu DFM SQL o yoldan gecer. Ancak MSSQL UPDATE...FROM (self-alias),
//   ##global-temp CREATE TABLE, cok-statement gibi YAPISAL desenler regex-cevrilemez/kirilgan.
// Bu birim onlarin ELLE-YAZILMIS + PG'ye-KARSI-TEST-EDILMIS PG karsiliklarini SABIT olarak tutar.
// Kullanim: cagiran taraf `if AktifVeriMotor = vmPG then <PG sabiti> else <DFM memo>`.
//   :TabloAdi ve @var'lar KORUNUR (cagiran KomutDeclare ekler, PgSqlCevir @var'i inline eder,
//   [bracket]/COLLATE temizler). DIKKAT: PgSelectAliasCevir yalniz SELECT/INSERT'i isler, UPDATE'i
//   ATLAR -> bu sabitlerdeki select-listesi alias'lari `expr AS ad` yazilmali (`ad=expr` DEGIL).
// ============================================================

interface

uses System.Classes, FireDAC.Comp.Client;

// ============================================================
// IKI AYRI MEKANIZMA — KARISTIRMA:
//  (1) RESOLVER / REGISTRY (DFMPGSqlGetir + RegKur.Ekle): DFM'e dusen TFDQuery component'lerinin
//      SQL override'i. Override PG_MARK ile doner -> PgSqlCevir CALISMAZ. Dolayisiyla parametreler
//      FireDAC-native `:param` OLMALI; `@param` YASAK (cevrilmez, PG'de "parametre" hatasi verir).
//  (2) CETREFIL SABITLER (SQL_PG_Izleme* + UIzleme.MemoSec): DFM MEMO/batch UPDATE'ler. Cagiran
//      basa KomutDeclare (declare/set @var) ekler ve ExecC->PgSqlCevir->PgDeclareCevir @var'i INLINE
//      eder. Bunlar PG_MARK ALMAZ (MemoSec ham dondurur). Bu yolda `@StokID` vb. DOGRU, gereklidir.
//  ==> Kural: registry override'inda :param; MemoSec sabitinde @var. Sabitleri registry'ye EKLEME.
// ============================================================

// (1) DFM component SQL cozucusu (FormAdi.ComponentAdi anahtarli). vmPG'de: once override registry,
//   yoksa PgSqlCevir(ADefaultSql). vmMSSQL'de: ADefaultSql AYNEN (dokunmaz). Zaten-cevrili (PG_MARK)
//   metni aynen dondurur. UVeriMotor.DFMPGCozucuHook bu fonksiyona baglanir (initialization).
//   Override eklemek: RegKur icinde Ekle('FormClassName-T''siz.ComponentAdi', <PG-native, :param'li SQL>).
function DFMPGSqlGetir(AOwner: TComponent; AQuery: TFDQuery; const ADefaultSql: string): string;

const
  // (2) MemoSec/@var-inline yolu icin — REGISTRY'YE EKLENMEZ. @StokID/@BaslikID/@SatirID cagiranin
  //   KomutDeclare'iyle inline edilir (FireDAC :param DEGIL). PG_MARK almaz.
  // UIzleme.SQLCikanUpdate PG: MSSQL 'UPDATE Tmp SET .. FROM :TabloAdi Tmp INNER JOIN (subq) x ON c'
  //   -> PG 'UPDATE :TabloAdi tmp SET .. FROM (subq) x WHERE c'. Secili cikis izlemlerini isaretler.
  SQL_PG_IzlemeCikanUpdate =
    'update :TabloAdi tmp set KALAN=X.DURUM, SEC=1, UPDID=X.ID'#13#10 +
    'from ('#13#10 +
    '  select * from ('#13#10 +
    '    SELECT SI1.STOKID, SUM(SI1.ADET) AS DURUM, SERINO, LOTNO, SKT, URT, SI1.ID'#13#10 +
    '    from STOKIZLEME SI1'#13#10 +
    '    INNER JOIN STOKSERILOT SSL ON SI1.SERILOTID = SSL.ID'#13#10 +
    '    where SI1.STOKID=@StokID and SI1.BASLIKID=@BaslikID and SI1.SATIRID=@SatirID'#13#10 +
    '    group by SI1.STOKID, SERINO, LOTNO, SKT, URT, SI1.ID'#13#10 +
    '  ) as List where DURUM >= 0.0'#13#10 +
    ') as x'#13#10 +
    'WHERE (X.SERINO = TMP.SERINO OR (X.SERINO IS NULL AND TMP.SERINO IS NULL))'#13#10 +
    '  AND (X.LOTNO  = TMP.LOTNO  OR (X.LOTNO  IS NULL AND TMP.LOTNO  IS NULL))'#13#10 +
    '  AND (X.SKT    = TMP.SKT    OR (X.SKT    IS NULL AND TMP.SKT    IS NULL))';

  // UIzleme.SQLDonusCikanHedefUpdate PG: donusum hedef belgesinde kaynak izlemleri isaretler.
  SQL_PG_IzlemeDonusCikanHedefUpdate =
    'update :TabloAdi tmp set DURUM=tmp.DURUM+X.ADET, KALAN=X.ADET, SEC=1, UPDID=X.IZLEM1'#13#10 +
    'from ('#13#10 +
    '  SELECT SI1.STOKID, SI1.ADET AS ADET, SERINO, LOTNO, SKT, URT, SI1.ID AS IZLEM1'#13#10 +
    '  from STOKIZLEME SI1'#13#10 +
    '  INNER JOIN STOKSERILOT SSL ON SI1.SERILOTID=SSL.ID'#13#10 +
    '  where SI1.SATIRID=@SatirID'#13#10 +
    ') as x'#13#10 +
    'WHERE (X.SERINO = TMP.SERINO OR (X.SERINO IS NULL AND TMP.SERINO IS NULL))'#13#10 +
    '  AND (X.LOTNO  = TMP.LOTNO  OR (X.LOTNO  IS NULL AND TMP.LOTNO  IS NULL))'#13#10 +
    '  AND (X.SKT    = TMP.SKT    OR (X.SKT    IS NULL AND TMP.SKT    IS NULL))';

implementation

uses SysUtils, System.Generics.Collections, UVeriMotor;

var
  FReg: TDictionary<string,string> = nil;   // anahtar(lower) -> PG-native SQL

// Form/frame class adindan anahtar oneki: 'TUSiparisWizard' -> 'USiparisWizard' (bas 'T' atilir).
function FormAdiNorm(AOwner: TComponent): string;
begin
  Result := '';
  if AOwner = nil then Exit;
  Result := AOwner.ClassName;
  if (Length(Result) > 1) and (Result[1] = 'T') then Delete(Result, 1, 1);
end;

procedure RegKur;
  procedure Ekle(const AKey, ASql: string);
  var j: Integer;
  begin
    // Registry override PG_MARK ile doner -> PgSqlCevir CALISMAZ. Param FireDAC-native :param
    //   olmali; @param cevrilmeden kalir -> fail-fast (runtime FireDAC hatasindan iyi).
    for j := 1 to Length(ASql) - 1 do
      if (ASql[j] = '@') and CharInSet(ASql[j + 1], ['A'..'Z', 'a'..'z', '_']) then
        raise Exception.CreateFmt(
          'UDFMPG override "%s": @param yasak, :param kullan '+
          '(PG_MARK''li override PgSqlCevir''den gecmez, @->: cevrilmez).', [AKey]);
    FReg.AddOrSetValue(LowerCase(AKey), ASql);
  end;
begin
  FReg := TDictionary<string,string>.Create;
  // --- (1) DFM component SQL override'lari (registry) ---
  //   YALNIZ otomatik ceviricinin (PgSqlCevir) bozdugu/karmasik DFM sorgulari buraya alinir.
  //   Cogu DFM SQL PgSqlCevir'den gecer; burasi bos kalmasi NORMAL. Ornek (sirasi gelince):
  //   Ekle('USiparisWizard.TabSiparisDetay', 'select ... from ... where x=:StokID');
  //   Kural: PG-native yaz (limit/||/AS), FireDAC :param KULLAN (@param YASAK), deploy oncesi
  //   PG'ye karsi test et. (SQL_PG_Izleme* sabitleri BURAYA GIRMEZ -> bkz. ust blok, @var'li.)
end;

function DFMPGSqlGetir(AOwner: TComponent; AQuery: TFDQuery; const ADefaultSql: string): string;
var anahtar, ovr: string;
begin
  Result := ADefaultSql;
  if AktifVeriMotor <> vmPG then Exit;             // MSSQL: dokunma (davranis-korur)
  if Copy(ADefaultSql, 1, Length(PG_MARK)) = PG_MARK then Exit;  // zaten cevrilmis (idempotent)
  if FReg = nil then RegKur;
  if AQuery <> nil then
  begin
    anahtar := LowerCase(FormAdiNorm(AOwner) + '.' + AQuery.Name);
    if FReg.TryGetValue(anahtar, ovr) and (Trim(ovr) <> '') then
    begin
      // Override PG-native sabit -> isaretle ki TabloYenile/scan bir daha PgSqlCevir'e sokmasin.
      if Copy(ovr, 1, Length(PG_MARK)) = PG_MARK then Result := ovr else Result := PG_MARK + ovr;
      Exit;
    end;
  end;
  Result := PgSqlCevir(ADefaultSql);               // override yok -> merkezi cevirici (kendi isaretler)
end;

initialization
  DFMPGCozucuHook := DFMPGSqlGetir;   // UVeriMotor kancasina bagla (circular-dep'siz)
finalization
  FreeAndNil(FReg);
end.

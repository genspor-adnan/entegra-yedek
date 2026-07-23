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

const
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

end.

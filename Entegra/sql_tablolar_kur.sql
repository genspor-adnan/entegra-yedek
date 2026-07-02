-- ============================================================
-- TABLOLAR: genel tablo kaydi (registry).
--   TABLOID  -> TabNo_* sabiti (Utablo.pas) ile ayni sayi
--   TABLOADI -> fiziksel tablo adi (FATBASLIK, FATURA...)
--   GORUNUM  -> arayuzde gosterilecek ad (Başlık, Detay...)
--   MODUL    -> modul adi (Fatura, Cari, Stok...)
-- Ana DB'de. Idempotent; veri korunur. MERGE/SELECT EXEC icinde (rename/ALTER
-- ayni batch'te once calissin diye).
-- ============================================================
IF OBJECT_ID('dbo.TABLOLAR','U') IS NULL
CREATE TABLE dbo.TABLOLAR(
  TABLOID  int           NOT NULL CONSTRAINT PK_TABLOLAR PRIMARY KEY,
  TABLOADI varchar(64)   NULL,
  GORUNUM  nvarchar(128) NULL,
  MODUL    nvarchar(64)  NULL
);

-- Eski DBTABLOADI -> TABLOADI (varsa)
IF COL_LENGTH('dbo.TABLOLAR','DBTABLOADI') IS NOT NULL
   AND COL_LENGTH('dbo.TABLOLAR','TABLOADI') IS NULL
   EXEC sp_rename 'dbo.TABLOLAR.DBTABLOADI', 'TABLOADI', 'COLUMN';

-- MODUL kolonu yoksa ekle
IF COL_LENGTH('dbo.TABLOLAR','MODUL') IS NULL
   ALTER TABLE dbo.TABLOLAR ADD MODUL nvarchar(64) NULL;

EXEC('
MERGE dbo.TABLOLAR AS h
USING (VALUES
  (28,  ''FATBASLIK'', N''Başlık'', N''Fatura''),
  (29,  ''FATBASLIK'', N''Başlık'', N''Fatura''),
  (30,  ''FATBASLIK'', N''Başlık'', N''Fatura''),
  (120, ''FATURA'',    N''Detay'',  N''Fatura''),
  (130, ''FATURA'',    N''Detay'',  N''Fatura''),
  (131, ''FATURA'',    N''Detay'',  N''Fatura''),
  (132, ''FATURA'',    N''Detay'',  N''Fatura''),
  (133, ''FATURA'',    N''Detay'',  N''Fatura''),
  (330, ''FATURA'',    N''Detay'',  N''Fatura'')
) AS k(TABLOID, TABLOADI, GORUNUM, MODUL)
ON h.TABLOID = k.TABLOID
WHEN MATCHED THEN UPDATE SET TABLOADI=k.TABLOADI, GORUNUM=k.GORUNUM, MODUL=k.MODUL
WHEN NOT MATCHED THEN INSERT(TABLOID, TABLOADI, GORUNUM, MODUL)
  VALUES(k.TABLOID, k.TABLOADI, k.GORUNUM, k.MODUL);');

EXEC('SELECT TABLOID, TABLOADI, GORUNUM, MODUL FROM dbo.TABLOLAR ORDER BY TABLOID');

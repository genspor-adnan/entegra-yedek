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
  (330, ''FATURA'',    N''Detay'',  N''Fatura''),
  (91,  ''SIPARIS'',      N''Başlık'', N''Sipariş''),
  (92,  ''SIPARIS'',      N''Başlık'', N''Sipariş''),
  (93,  ''SIPARISDETAY'', N''Detay'',  N''Sipariş''),
  (105, ''FATBASLIK'',    N''Başlık'', N''İrsaliye''),
  (106, ''FATBASLIK'',    N''Kart'', N''Giriş Fişi''),
  (107, ''FATBASLIK'',    N''Kart'', N''Çıkış Fişi''),
  (71,  ''REHBER'',        N''Kart'',      N''Cari''),
  (75,  ''REHBERBILGI'',   N''İletişim'',  N''Cari''),
  (76,  ''REHBERBILGI'',   N''Detay'',     N''Cari''),
  (79,  ''REHBERBILGI'',   N''Ticari'',    N''Cari''),
  (81,  ''REHBERBILGI'',   N''İlgili'',    N''Cari''),
  (88,  ''STOKLAR'',       N''Kart'',   N''Stok''),
  (340, ''STOKBARKOD'',    N''Barkod'', N''Stok''),
  (346, ''STOKFIYAT'',     N''Fiyat'',  N''Stok''),
  (370, ''STOKDETAY'',     N''Detay'',  N''Stok''),
  (33,  ''GOREVLER'',      N''Kart'',  N''Görev''),
  (70,  ''PROJELER'',      N''Kart'',   N''Proje''),
  (371, ''PROJEASAMA'',    N''Aşama'',  N''Proje''),
  (372, ''REHBERBILGI'',   N''Detay'',  N''Proje''),
  (170, ''PROJELER'',      N''Kart'',   N''Satış Fırsatı''),
  (464, ''SIPARIS'',       N''Kart'',   N''Stok Talep''),
  (18,  ''DEMIRBAS'',      N''Kart'',      N''Demirbaş''),
  (373, ''AMORTISMAN'',    N''Amortisman'',N''Demirbaş''),
  (182, ''DEMIRBAS_TUTANAK_DETAY'', N''Tutanak'', N''Demirbaş''),
  (83,  ''SERVIS'',        N''Kart'',      N''Servis''),
  (183, ''SERVISHAREKET'', N''Hareket'',   N''Servis''),
  (430, ''SERVISDETAYPERSONEL'', N''Personel'', N''Servis''),
  (210, ''GOREVYORUM'',    N''Yorum'',     N''Görev''),
  (142, ''URETIMOPERASYON'',N''Operasyon'',N''Üretim''),
  (321, ''DOKUMAN'',       N''Kart'',      N''Doküman''),
  (374, ''DOKUMANREVIZE'', N''Revizyon'',  N''Doküman''),
  (43,  ''KASA'',          N''Kart'',  N''Nakit''),
  (-1,  ''OTURUM'',        N''Oturum'',  N''Oturum''),
  (97,  ''TEKLIF'',        N''Başlık'',  N''Teklif''),
  (98,  ''TEKLIFDETAY'',   N''Detay'',   N''Teklif''),
  (134, ''FATBASLIK'',     N''Kart'',    N''Stok Transfer''),
  (138, ''URETIMRECETE'',  N''Kart'',   N''Reçete''),
  (139, ''URETIMRECETEDETAY'',N''Detay'',N''Reçete''),
  (140, ''URETIMEMRI'',    N''Kart'',   N''Üretim Emri''),
  (141, ''URETIMEMRIDETAY'',N''Detay'', N''Üretim Emri''),
  (144, ''URETIMFISI'',    N''Kart'',   N''Üretim Fişi''),
  (145, ''URETIMFISDETAY'',N''Detay'',  N''Üretim Fişi''),
  (73,  ''REHBER'',        N''Kart'',   N''İK''),
  (74,  ''REHBER'',        N''Kart'',   N''İK Potansiyel''),
  (86,  ''REHBERBILGI'',   N''Özlük'',  N''İK'')
) AS k(TABLOID, TABLOADI, GORUNUM, MODUL)
ON h.TABLOID = k.TABLOID
WHEN MATCHED THEN UPDATE SET TABLOADI=k.TABLOADI, GORUNUM=k.GORUNUM, MODUL=k.MODUL
WHEN NOT MATCHED THEN INSERT(TABLOID, TABLOADI, GORUNUM, MODUL)
  VALUES(k.TABLOID, k.TABLOADI, k.GORUNUM, k.MODUL);');

EXEC('SELECT TABLOID, TABLOADI, GORUNUM, MODUL FROM dbo.TABLOLAR ORDER BY TABLOID');

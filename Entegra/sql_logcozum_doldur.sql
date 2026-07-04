-- ============================================================
-- LOGCOZUM baslangic eslemeleri (idempotent). Yeni eslemeler buraya eklenir.
--   Cozum: SELECT <ADKOLON> FROM <KAYNAKTABLO> WHERE <IDKOLON>=<deger> [AND <FILTRE>]
--   TABLOID NULL = tum log tablolari (genel alan).
-- ============================================================
SET NOCOUNT ON;

MERGE dbo.LOGCOZUM AS h
USING (VALUES
  -- Kullanici alanlari (REHBER.ID -> FIRMA). Genel (tum tablolar) + cari temsilci.
  (NULL, N'EKLEYEN',    N'REHBER', N'ID',    N'FIRMA',   NULL),
  (NULL, N'DEGISTIREN', N'REHBER', N'ID',    N'FIRMA',   NULL),
  (71,   N'TEMSILCI',   N'REHBER', N'ID',    N'FIRMA',   NULL),
  -- Cari lookup (GENINI: BOLUM grup, DEGER=id, ANAHTAR=metin; DIL=-1 dil-bagimsiz)
  (71,   N'SEKTOR',     N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2204'),
  (71,   N'BOLGE',      N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2210'),
  (71,   N'KATEGORI',   N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2208'),
  (71,   N'SINIF',      N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2203'),
  (71,   N'DURUM',      N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2201'),
  (71,   N'TEMAS',      N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2207'),
  -- Parent-bagli: BOLUM = base & parent. {ALAN} = ayni kayittaki parent alan degeri.
  (71,   N'ALTSEKTOR',  N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=CAST(''-2204''+''{SEKTOR}'' AS int)'),
  (71,   N'ALTBOLGE',   N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=CAST(''-2210''+''{BOLGE}'' AS int)'),

  -- ===== Genel (tum tablolar): cari/kisi/proje anahtarlari =====
  (NULL, N'REHBERID',   N'REHBER',   N'ID', N'FIRMA',    NULL),   -- ilgili cari (fatura/gorev...)
  (NULL, N'CARIID',     N'REHBER',   N'ID', N'FIRMA',    NULL),
  (NULL, N'PROJEID',    N'PROJELER', N'ID', N'PROJEADI', NULL),
  (NULL, N'SUBEID',     N'REHBER',   N'ID', N'FIRMA',    NULL),   -- sube = negatif REHBER.ID

  -- ===== STOK (88): GENINI (BOLUM), DIL=-1 dil-bagimsiz =====
  (88,   N'MARKA',          N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2701'),
  (88,   N'ANABIRIM',       N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2702'),
  (88,   N'BIRIM2',         N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2702'),
  (88,   N'TIPI',           N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2703'),
  (88,   N'GRUBU',          N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2704'),
  (88,   N'OZELLIK',        N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2705'),
  (88,   N'IZLEME',         N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2706'),
  (88,   N'RAFOMRU_BIRIM',  N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2707'),
  (88,   N'DURUM',          N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2708'),
  (88,   N'UZUNLUK_BIRIMI', N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2710'),
  (88,   N'ALAN_BIRIMI',    N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2711'),
  (88,   N'HACIM_BIRIMI',   N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2712'),
  (88,   N'AGIRLIK_BIRIMI', N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2713'),
  (88,   N'ICERIK',         N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2718'),
  (88,   N'KULLANIM',       N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2726'),
  (88,   N'MEDIKALSINIF',   N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2757'),
  (88,   N'URETICIID',      N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2791'),
  (88,   N'MODEL',          N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=CAST(''-2701''+''{MARKA}'' AS int)'),
  -- STOK: baska tablodan
  (88,   N'KATEGORI',       N'KATEGORI',          N'ID',   N'AD',    NULL),
  (88,   N'MASRAFID',       N'MASRAFGELIR',       N'ID',   N'AD',    NULL),
  (88,   N'GELIRID',        N'MASRAFGELIR',       N'ID',   N'AD',    NULL),
  (88,   N'URETICI',        N'REHBER',            N'ID',   N'FIRMA', NULL),
  (88,   N'MENSEIULKE',     N'ILLER',             N'ILNO', N'ILADI', NULL),
  (88,   N'BOYUTGRUBU',     N'STOKBOYUTGRUPLARI', N'ID',   N'ADI',   NULL),

  -- ===== PROJE (70): GENINI + kisi =====
  (70,   N'TURU',            N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2132'),
  (70,   N'ASAMA',           N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=-2133'),
  (70,   N'TIPI',            N'GENINI', N'DEGER', N'ANAHTAR', N'BOLUM=CAST(''-2132''+''{TURU}'' AS int)'),
  (70,   N'PRJ_SORUMLUSU_ID',N'REHBER', N'ID',    N'FIRMA',   NULL),
  (70,   N'ILGILI',          N'REHBER', N'ID',    N'FIRMA',   NULL),

  -- ===== GOREV (33): GENINI + kisi/ekipman =====
  (33,   N'DURUM',      N'GENINI',     N'DEGER', N'ANAHTAR', N'BOLUM=-21042'),
  (33,   N'TURU',       N'GENINI',     N'DEGER', N'ANAHTAR', N'BOLUM=-21044'),
  (33,   N'MUS_ILGILI', N'REHBER',     N'ID',    N'FIRMA',   NULL),
  (33,   N'MUS_ILGILI2',N'REHBER',     N'ID',    N'FIRMA',   NULL),
  (33,   N'EKIPMANID',  N'EKIPMANLAR', N'ID',    N'AD',      NULL),
  (33,   N'LISTEID',    N'GOREVLISTE', N'ID',    N'ADI',     NULL)
) AS k(TABLOID, ALAN, KAYNAKTABLO, IDKOLON, ADKOLON, FILTRE)
ON ISNULL(h.TABLOID,-1)=ISNULL(k.TABLOID,-1) AND h.ALAN=k.ALAN COLLATE Turkish_CI_AS
WHEN MATCHED THEN UPDATE SET KAYNAKTABLO=k.KAYNAKTABLO, IDKOLON=k.IDKOLON, ADKOLON=k.ADKOLON, FILTRE=k.FILTRE, AKTIF=1
WHEN NOT MATCHED THEN INSERT(TABLOID,ALAN,KAYNAKTABLO,IDKOLON,ADKOLON,FILTRE)
  VALUES(k.TABLOID,k.ALAN,k.KAYNAKTABLO,k.IDKOLON,k.ADKOLON,k.FILTRE);

SELECT ID, TABLOID, ALAN, KAYNAKTABLO, IDKOLON, ADKOLON, FILTRE FROM dbo.LOGCOZUM ORDER BY ISNULL(TABLOID,0), ALAN;

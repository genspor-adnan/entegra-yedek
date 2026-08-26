-- ============================================================
-- Update_SQL_174.sql   (MSSQL)
-- STOK IZLEME: excel aktariminin urettigi MUKERRER "Yok" sozluk kayitlarini temizle
--
-- SORUN
--   Excel'den stok aktariminda (UExceldenVeriAl.IniEkle) sozluk kodu soyle bulunuyordu:
--       Result := Iniden_Deger_Getir(BOLUM, ANAHTAR);   -- BULUNAMAZSA da '0' doner
--       if Result = '0' then  ... insert (max(DEGER)+1) ...
--   Yani "deger 0" ile "kayit yok" ayni sayiliyordu. Stok Izleme sozlugunde (GENINI
--   BOLUM = -2706) 'Yok' anahtarinin DEGERI 0'dir. Excel'in IZLEME sutununda 'Yok'
--   yazan her aktarim bu yuzden sozluge YENI bir 'Yok' satiri ekliyor (7, 8, 9, ...)
--   ve stok kartina o sahte kodu yaziyordu -> "Izleme: Yok" yazan exceli aktarinca
--   kartta degisik rakamlar. (Or. bir kurulumda 'Yok' 5 kez: 0, 7, 8, 9, 10.)
--
-- COZUM
--   Uygulama tarafi duzeltildi (varlik artik ANAHTAR uzerinden kontrol ediliyor).
--   Bu betik GECMIS veriyi onarir: sahte 'Yok' kodlarini kullanan stoklar asil koda
--   (DEGER = 0) cekilir, sahte sozluk satirlari silinir.
--
-- GUVENLIK / KAPSAM
--   - YALNIZ BOLUM = -2706 (Stok Izleme) ve YALNIZ ayni ANAHTAR'in DEGER=0 kaydi VARSA.
--     Kaydin gercekten mukerrer oldugu boylece kanitlanir; tek basina duran kodlara
--     (Seri No, Lot No...) DOKUNULMAZ.
--   - Degisen stok satirlarinin eski degeri YEDEK tabloya yazilir.
--   - Diger sozlukler (marka, model, tip...) icin yalnizca RAPOR basilir; otomatik
--     silme yapilmaz (bir BOLUM'un hangi tabloda kullanildigi burada bilinemez).
--   - Idempotent: ikinci calistirmada eslesen satir kalmaz.
-- ============================================================

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

IF OBJECT_ID('dbo.GENINI', 'U') IS NULL OR OBJECT_ID('dbo.STOKLAR', 'U') IS NULL
BEGIN
    PRINT 'Update_SQL_174: GENINI/STOKLAR yok, atlandi.';
    RETURN;
END;

-- 1) Yedek tablolar
IF OBJECT_ID('dbo.YEDEK_STOK_IZLEME_174', 'U') IS NULL
    CREATE TABLE dbo.YEDEK_STOK_IZLEME_174
    (
        STOKID       INT      NOT NULL PRIMARY KEY,
        ESKI_IZLEME  INT      NULL,
        YENI_IZLEME  INT      NULL,
        TARIH        DATETIME NOT NULL DEFAULT (GETDATE())
    );

IF OBJECT_ID('dbo.YEDEK_GENINI_174', 'U') IS NULL
    CREATE TABLE dbo.YEDEK_GENINI_174
    (
        BOLUM   INT             NOT NULL,
        ANAHTAR NVARCHAR(250)   NULL,
        DEGER   INT             NOT NULL,
        DIL     INT             NULL,
        TARIH   DATETIME        NOT NULL DEFAULT (GETDATE())
    );

-- 2) Sahte kodlar: ayni ANAHTAR'in DEGER=0 kaydi VARSA, DEGER<>0 olanlar mukerrerdir
IF OBJECT_ID('tempdb..#Sahte') IS NOT NULL DROP TABLE #Sahte;
SELECT G.DEGER AS SAHTE, G.ANAHTAR
  INTO #Sahte
  FROM dbo.GENINI G
 WHERE G.BOLUM = -2706 AND G.DIL = -1 AND G.DEGER <> 0
   AND EXISTS (SELECT 1 FROM dbo.GENINI G0
                WHERE G0.BOLUM = -2706 AND G0.DIL = -1 AND G0.DEGER = 0
                  AND G0.ANAHTAR = G.ANAHTAR);

IF NOT EXISTS (SELECT 1 FROM #Sahte)
BEGIN
    PRINT 'Update_SQL_174: mukerrer Izleme kaydi yok, onarim gerekmedi.';
END
ELSE
BEGIN
    -- 3) Etkilenen stoklarin yedegi + duzeltmesi (sahte kod -> 0)
    INSERT INTO dbo.YEDEK_STOK_IZLEME_174 (STOKID, ESKI_IZLEME, YENI_IZLEME)
    SELECT S.ID, S.IZLEME, 0
      FROM dbo.STOKLAR S
      JOIN #Sahte X ON X.SAHTE = S.IZLEME
     WHERE NOT EXISTS (SELECT 1 FROM dbo.YEDEK_STOK_IZLEME_174 Y WHERE Y.STOKID = S.ID);

    UPDATE S
       SET S.IZLEME = 0
      FROM dbo.STOKLAR S
      JOIN #Sahte X ON X.SAHTE = S.IZLEME;

    PRINT 'Update_SQL_174: duzeltilen stok sayisi = ' + CAST(@@ROWCOUNT AS varchar(10));

    -- 4) Sahte sozluk satirlarini yedekle + sil
    INSERT INTO dbo.YEDEK_GENINI_174 (BOLUM, ANAHTAR, DEGER, DIL)
    SELECT G.BOLUM, G.ANAHTAR, G.DEGER, G.DIL
      FROM dbo.GENINI G
      JOIN #Sahte X ON X.SAHTE = G.DEGER AND X.ANAHTAR = G.ANAHTAR
     WHERE G.BOLUM = -2706 AND G.DIL = -1;

    DELETE G
      FROM dbo.GENINI G
      JOIN #Sahte X ON X.SAHTE = G.DEGER AND X.ANAHTAR = G.ANAHTAR
     WHERE G.BOLUM = -2706 AND G.DIL = -1;

    PRINT 'Update_SQL_174: silinen mukerrer sozluk satiri = ' + CAST(@@ROWCOUNT AS varchar(10));
END;

DROP TABLE #Sahte;

-- 5) BILGI: diger sozluklerde ayni desende mukerrer var mi? (silinmez, yalnizca rapor)
SELECT BOLUM, ANAHTAR, MUKERRER_ADET = COUNT(*)
  FROM dbo.GENINI G
 WHERE G.DIL = -1
   AND EXISTS (SELECT 1 FROM dbo.GENINI G0
                WHERE G0.BOLUM = G.BOLUM AND G0.DIL = -1 AND G0.DEGER = 0
                  AND G0.ANAHTAR = G.ANAHTAR)
 GROUP BY BOLUM, ANAHTAR
HAVING COUNT(*) > 1
 ORDER BY BOLUM;

-- 6) Sonuc: Izleme sozlugu
SELECT ANAHTAR, DEGER FROM dbo.GENINI WHERE BOLUM = -2706 AND DIL = -1 ORDER BY DEGER;

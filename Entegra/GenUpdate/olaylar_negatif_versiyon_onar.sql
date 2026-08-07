/* ============================================================================
   olaylar_negatif_versiyon_onar.sql  —  MUSTERI ANA veritabaninda calistirilir

   SORUN: OLAYLAR tablosundaki guncelleme kayitlarinda komut numarasi (BILGINO)
     NEGATIF gorunuyor: -32679, -32680, -32706 ...
     Sebep 16-bit TASMA (smallint sarmasi): komut numaralari 32767'yi asinca
     (32830, 32857 ...) deger  <gercek> - 65536  olarak yazilmis.
        32857 - 65536 = -32679      -32679 + 65536 = 32857
     Boylece Guncellemeler ekraninda hangi komutun calistigi/patladigi okunamiyor.

   NE YAPAR: yalnizca GUNCELLEME olay kayitlarinda (KAYNAK = 10, KATEGORI = 101)
     negatif BILGINO degerlerine 65536 ekler. Baska modullerin kayitlarina
     DOKUNMAZ (orada negatif deger mesru olabilir).

   DOGRULAMA: Ayni sunucuda GenUpdate dagitim tablosu (dbo.GUNCELLEMELER) varsa,
     duzeltilen numara ile kaydin ACIKLAMA metni KARSILASTIRILIR ve uyusmayanlar
     raporlanir. Musteri veritabaninda bu tablo bulunmaz; o durumda yalnizca
     tasma matematigi kullanilir (deterministik: +65536).

   KULLANIM:
     - Once oldugu gibi calistirin  -> yalnizca RAPOR.
     - Uygulamak icin @Uygula = 1 yapip tekrar calistirin.
     - Idempotent: duzeltilmis kayitlar pozitif oldugu icin tekrar etkilenmez.

   NOT: Tasmanin KAYNAGI 06.08.2026'da giderildi (OLAYLAR.BILGINO int + guncelleme
     dongusunde Integer kullanimi). Bu betik GECMIS kayitlari okunur yapar.
============================================================================ */
SET NOCOUNT ON;

------------------------------------------------------------------------------
DECLARE @Uygula BIT = 0;      -- 0 = yalniz rapor   |   1 = DUZELTMEYI UYGULA
------------------------------------------------------------------------------

/* ---- 1) Aday kayitlar ----------------------------------------------------- */
IF OBJECT_ID('tempdb..#N') IS NOT NULL DROP TABLE #N;
SELECT o.ID,
       ESKI  = o.BILGINO,
       YENI  = o.BILGINO + 65536,
       ACIKLAMA = LEFT(ISNULL(o.BILGI, ''), 80)
INTO #N
FROM dbo.OLAYLAR o
WHERE o.BILGINO < 0
  AND o.KAYNAK = 10 AND o.KATEGORI = 101;   -- yalniz guncelleme kayitlari

IF NOT EXISTS (SELECT 1 FROM #N)
BEGIN
    PRINT 'Duzeltilecek negatif guncelleme kaydi yok.';
    RETURN;
END

/* ---- 2) GUNCELLEMELER ile capraz dogrulama (tablo varsa) ------------------- */
DECLARE @dogrulama NVARCHAR(200) = N'(dbo.GUNCELLEMELER yok - yalniz tasma matematigi)';
IF OBJECT_ID('dbo.GUNCELLEMELER') IS NOT NULL
BEGIN
    SELECT n.ID, n.ESKI, n.YENI, n.ACIKLAMA,
           EKSLESME = CASE
               WHEN g.VERSIYONNO IS NULL THEN 'komut numarasi TABLODA YOK'
               WHEN LEFT(REPLACE(REPLACE(ISNULL(g.ACIKLAMA,''),CHAR(13),' '),CHAR(10),' '), 80)
                    = n.ACIKLAMA THEN 'aciklama UYUSUYOR'
               ELSE 'aciklama FARKLI - kontrol edin' END
    FROM #N n
    LEFT JOIN dbo.GUNCELLEMELER g ON g.VERSIYONNO = n.YENI;
    SET @dogrulama = N'(dbo.GUNCELLEMELER ile karsilastirildi - yukaridaki EKSLESME sutunu)';
END

/* ---- 3) Rapor ------------------------------------------------------------- */
SELECT ID, ESKI_BILGINO = ESKI, YENI_BILGINO = YENI, ACIKLAMA FROM #N ORDER BY YENI;
SELECT ADET = COUNT(*), EN_KUCUK = MIN(YENI), EN_BUYUK = MAX(YENI), DOGRULAMA = @dogrulama FROM #N;

IF @Uygula = 0
BEGIN
    PRINT '';
    PRINT '*** RAPOR MODU - hicbir degisiklik yapilmadi. ***';
    PRINT 'Uygulamak icin @Uygula = 1 yapip tekrar calistirin.';
    RETURN;
END

/* ---- 4) Uygulama ---------------------------------------------------------- */
BEGIN TRY
    BEGIN TRAN;

    UPDATE o SET o.BILGINO = n.YENI
    FROM dbo.OLAYLAR o
    JOIN #N n ON n.ID = o.ID;

    DECLARE @adet INT = @@ROWCOUNT;
    COMMIT;
    PRINT 'Duzeltilen kayit: ' + CAST(@adet AS varchar(10));
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT 'HATA: ' + ERROR_MESSAGE();
    PRINT 'NOT: BILGINO hala smallint ise once olaylar_bilgino_int.sql calistirin.';
    RETURN;
END CATCH

/* ---- 5) Son durum --------------------------------------------------------- */
SELECT KALAN_NEGATIF = COUNT(*)
FROM dbo.OLAYLAR WHERE BILGINO < 0 AND KAYNAK = 10 AND KATEGORI = 101;

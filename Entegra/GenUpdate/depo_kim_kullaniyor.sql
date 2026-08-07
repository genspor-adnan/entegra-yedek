/* ============================================================================
   depo_kim_kullaniyor.sql   —   MASTER veritabaninda calistirilir (SALT OKUMA)

   Ortak 'GENDEPO' deposunu HANGI kurulumlarin kullandigini/kullanabilecegini
   listeler. Hicbir sey DEGISTIRMEZ.

   Neden gerekli: depo_adlandirma_onar.sql, ortak 'GENDEPO'yu birden fazla
   kurulum kullaniyorsa ADINI DEGISTIRMEZ (degistirse digerleri - ozellikle eski
   surum exe kullananlar - acilmaz). Bu betik "kim engelliyor" sorusunu yanitlar.

   KULLANIM SIRASI:
     1) Bu betigi calistirin, ortak depoya dusen kurulumlari gorun.
     2) 'SESSIZ' / 'acikca kullaniyor' olanlara KENDI depolarini kurdurun
        (yeni exe ilk acilista kurar; ya da GenDepoKur1..9).
     3) Ortak depoda tek kurulum kalinca depo_adlandirma_onar.sql rename'i yapar.
============================================================================ */
USE master;
GO
SET NOCOUNT ON;

DECLARE @DepoOpsiyon INT = -24120;

IF OBJECT_ID('tempdb..#K') IS NOT NULL DROP TABLE #K;
CREATE TABLE #K (
    ANA_DB      SYSNAME,
    KENDI_DEPOSU_VAR CHAR(3),
    GENINI_ADI  NVARCHAR(200) NULL,
    SYN_DEPO    SYSNAME       NULL,
    VERI_SATIR  BIGINT        NULL,
    DURUM       NVARCHAR(120) NULL
);

DECLARE @db SYSNAME, @sql NVARCHAR(MAX);
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT name FROM sys.databases
     WHERE database_id > 4 AND state = 0 AND name NOT LIKE '%[_]GENDEPO' AND name <> 'GENDEPO'
     ORDER BY name;
OPEN c; FETCH NEXT FROM c INTO @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECT_ID(QUOTENAME(@db) + '.dbo.GENINI') IS NOT NULL
    BEGIN
        SET @sql = N'
        INSERT #K (ANA_DB, KENDI_DEPOSU_VAR, GENINI_ADI, SYN_DEPO, VERI_SATIR)
        SELECT @db,
               CASE WHEN DB_ID(@db + N''_GENDEPO'') IS NULL THEN ''YOK'' ELSE ''VAR'' END,
               (SELECT TOP 1 LTRIM(RTRIM(ANAHTAR)) FROM ' + QUOTENAME(@db) + N'.dbo.GENINI
                 WHERE BOLUM = @b AND DIL = 0),
               (SELECT TOP 1 PARSENAME(base_object_name, 3) FROM ' + QUOTENAME(@db) + N'.sys.synonyms
                 WHERE PARSENAME(base_object_name, 3) IS NOT NULL
                 GROUP BY PARSENAME(base_object_name, 3) ORDER BY COUNT(*) DESC),
               (SELECT ISNULL(SUM(p.rows), 0) FROM ' + QUOTENAME(@db) + N'.sys.partitions p
                  JOIN ' + QUOTENAME(@db) + N'.sys.objects o ON o.object_id = p.object_id
                 WHERE o.name IN (''FATBASLIK'', ''REHBER'', ''STOKLAR'') AND p.index_id IN (0, 1))';
        BEGIN TRY
            EXEC sp_executesql @sql, N'@db SYSNAME, @b INT', @db = @db, @b = @DepoOpsiyon;
        END TRY
        BEGIN CATCH
            INSERT #K (ANA_DB, KENDI_DEPOSU_VAR, DURUM) VALUES (@db, '?', N'TARANAMADI: ' + ERROR_MESSAGE());
        END CATCH
    END
    FETCH NEXT FROM c INTO @db;
END
CLOSE c; DEALLOCATE c;

UPDATE #K
SET DURUM = CASE
      WHEN DURUM IS NOT NULL THEN DURUM
      WHEN SYN_DEPO = 'GENDEPO' OR GENINI_ADI = 'GENDEPO'
        THEN N'ORTAK DEPOYU ACIKCA KULLANIYOR'
      WHEN ISNULL(VERI_SATIR, -1) = 0
        THEN N'BOS KURULUM (veri yok) - yok hukmunde, aday SAYILMAZ'
      WHEN KENDI_DEPOSU_VAR = 'YOK' AND ISNULL(GENINI_ADI, N'') = N''
        THEN N'SESSIZ KULLANICI (opsiyon bos + kendi deposu yok -> varsayilan GENDEPO)'
      WHEN KENDI_DEPOSU_VAR = 'VAR'
        THEN N'kendi deposunu kullaniyor'
      ELSE N'baska depo: ' + ISNULL(GENINI_ADI, ISNULL(SYN_DEPO, N'(bilinmiyor)')) END;

/* ---- 1) Ortak depoya dusen kurulumlar (RENAME'i ENGELLEYENLER) ------------- */
SELECT ORTAK_DEPOYA_DUSEN = ANA_DB, KENDI_DEPOSU_VAR, GENINI_ADI, SYN_DEPO, VERI_SATIR, DURUM
FROM #K
WHERE DURUM LIKE N'ORTAK DEPOYU%' OR DURUM LIKE N'SESSIZ%' OR DURUM LIKE N'TARANAMADI%'
ORDER BY ANA_DB;

/* ---- 2) Tum kurulumlar ---------------------------------------------------- */
SELECT ANA_DB, KENDI_DEPOSU_VAR, GENINI_ADI, SYN_DEPO, VERI_SATIR, DURUM FROM #K ORDER BY ANA_DB;

/* ---- 3) Ozet -------------------------------------------------------------- */
DECLARE @adet INT = (SELECT COUNT(*) FROM #K
                      WHERE DURUM LIKE N'ORTAK DEPOYU%' OR DURUM LIKE N'SESSIZ%' OR DURUM LIKE N'TARANAMADI%');
PRINT '';
IF DB_ID('GENDEPO') IS NULL
    PRINT 'Sunucuda ortak ''GENDEPO'' veritabani YOK.';
ELSE IF @adet = 0
    PRINT 'Ortak GENDEPO''ya dusen kurulum YOK (artik silinebilir/yeniden adlandirilabilir).';
ELSE IF @adet = 1
    PRINT 'Ortak GENDEPO''yu TEK kurulum kullaniyor -> depo_adlandirma_onar.sql rename yapabilir.';
ELSE
BEGIN
    PRINT 'Ortak GENDEPO''ya ' + CAST(@adet AS varchar(5)) + ' kurulum dusuyor -> RENAME YAPILAMAZ.';
    PRINT 'Once bu kurulumlara kendi depolarini kurdurun (yeni exe ilk acilista kurar).';
END

/* ============================================================================
   depo_adlandirma_onar.sql   —   MASTER veritabaninda calistirilir (SSMS)

   NE ICIN: depo_adlandirma_duzelt.sql'in YANLIS BAGLADIGI kurulumlari onarir.
   Her ana veritabanini KENDI deposuna baglar ve opsiyonu uygulamanin OKUDUGU
   bicimde yazar.

   ONCEKI BETIGIN KUSURU (bu betik onu duzeltir):
     Uygulama depo adini soyle okur (UGENINIDuzenle.ReadString):
         select ANAHTAR from GENINI where BOLUM = -24120 and DIL = 0
         ... if RecordCount = 1 then <deger> else <varsayilan 'GENDEPO'>
     yani  (a) satir DIL = 0 olmali,  (b) TAM BIR satir olmali.
     Onceki betik opsiyonu DIL = -1 ile yaziyor ve okurken DIL'i hic
     filtrelemiyordu -> uygulama kaydi GOREMEYIP 'GENDEPO' varsayimina
     dusuyordu (ya da mukerrer satirda yine varsayilana dusuyordu).

   DEPO TESPIT SIRASI (kanit gucune gore):
     1) <ANA_DB>_GENDEPO zaten varsa            -> odur (kural adi)
     2) Ana DB'deki SYNONYM'lerin gosterdigi DB -> en guclu kanit (kullanimda)
     3) GENINI'de yazan ad (DIL farketmeksizin)
     4) Ortak 'GENDEPO'
   Bulunan depo kural adinda degilse yeniden adlandirilir; BASKA bir ana DB de
   ayni depoyu gosteriyorsa PAYLASIMLI kabul edilir ve DOKUNULMAZ (rapor edilir).

   KULLANIM:
     - Once oldugu gibi calistirin -> yalnizca RAPOR.
     - Uygulamak icin @Uygula = 1 yapip tekrar calistirin.
     - Yeniden adlandirma SINGLE_USER ister: once Gentegre oturumlarini kapatin.
     - Idempotent: tekrar calistirmak zararsizdir.
============================================================================ */
/* BAGLAM DEGISTIRILMEZ: betik hangi veritabaninda calistirilirsa orada kalir
   (eskiden 'USE master' yapiyordu ve kullanici master'da kaliyordu; T-SQL'de baglami
   otomatik geri almanin yolu yok - USE degisken kabul etmez, EXEC('USE X') cagiranin
   baglamini degistirmez).
   master GEREKMEZ: sys.databases her veritabanindan okunur, ALTER DATABASE ... MODIFY NAME
   icin de yalnizca YENIDEN ADLANDIRILAN veritabanina BAGLI OLMAMAK yeterlidir.

   TEK KOSUL: bir DEPO (..._GENDEPO) veritabaninda calistirmayin - kendi baglantiniz
   SINGLE_USER almayi engeller. */
IF DB_NAME() LIKE '%[_]GENDEPO' OR DB_NAME() = 'GENDEPO'
BEGIN
    PRINT '*** DURDURULDU: su an bir DEPO veritabanindasiniz (' + DB_NAME() + ').';
    PRINT '    Yeniden adlandirma icin o veritabanina BAGLI OLMAMALISINIZ.';
    PRINT '    Ana veritabanina (or. GENTEGRE) ya da master''a gecip tekrar calistirin.';
    RETURN;
END
SET NOCOUNT ON;

------------------------------------------------------------------------------
DECLARE @Uygula BIT = 0;      -- 0 = yalniz rapor   |   1 = ONARIMI UYGULA
------------------------------------------------------------------------------

-- Ortak depo adayligindan HARIC tutulacak veritabanlari (virgullu liste).
--   Bos/terk edilmis kurulumlar sayilmasin diye. Ornek: N'Bilim_Ankara,TEST_DB'
DECLARE @HaricDBler NVARCHAR(MAX) = N'';
------------------------------------------------------------------------------

DECLARE @DepoOpsiyon INT = -24120;   -- Ops_FaturaOpsiyon_DepoDBAdi

IF OBJECT_ID('tempdb..#D') IS NOT NULL DROP TABLE #D;
CREATE TABLE #D (
    ANA_DB       SYSNAME,
    BEKLENEN     SYSNAME,
    GENINI_ADI   NVARCHAR(200) NULL,   -- GENINI'de yazan (herhangi bir DIL)
    GENINI_DIL0  NVARCHAR(200) NULL,   -- DIL = 0 satirindaki (uygulamanin gordugu)
    GENINI_SATIR INT           NULL,   -- DIL = 0 satir sayisi (1 olmali)
    SYN_DEPO     SYSNAME       NULL,   -- synonym'lerin gosterdigi depo
    GERCEK_DEPO  SYSNAME       NULL,   -- tespit edilen
    PAYLASIMLI   CHAR(3)       NULL,
    ORTAK_ADAY   CHAR(3)       NULL,   -- ortak 'GENDEPO'ya dusen (SESSIZ kullanici) mi
    TARANDI      CHAR(3)       NULL,   -- tarama basarili mi (hayirsa GUVENLI TARAFTA KAL)
    VERI_SATIR   BIGINT        NULL,   -- ana tablolardaki satir sayisi (0 = BOS kurulum)
    ISLEM        NVARCHAR(200) NULL
);

/* ---- 1) Tarama ------------------------------------------------------------ */
DECLARE @db SYSNAME, @sql NVARCHAR(MAX);

DECLARE cDb CURSOR LOCAL FAST_FORWARD FOR
    SELECT name FROM sys.databases
     WHERE database_id > 4 AND state = 0 AND name NOT LIKE '%[_]GENDEPO' AND name <> 'GENDEPO'
     ORDER BY name;
OPEN cDb; FETCH NEXT FROM cDb INTO @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECT_ID(QUOTENAME(@db) + '.dbo.GENINI') IS NOT NULL
    BEGIN
        SET @sql = N'
        INSERT #D (ANA_DB, BEKLENEN, GENINI_ADI, GENINI_DIL0, GENINI_SATIR, SYN_DEPO, VERI_SATIR)
        SELECT @db, @db + N''_GENDEPO'',
               (SELECT TOP 1 LTRIM(RTRIM(ANAHTAR)) FROM ' + QUOTENAME(@db) + N'.dbo.GENINI
                 WHERE BOLUM = @b AND LTRIM(RTRIM(ISNULL(ANAHTAR,N''''))) <> N'''' ORDER BY DIL),
               (SELECT TOP 1 LTRIM(RTRIM(ANAHTAR)) FROM ' + QUOTENAME(@db) + N'.dbo.GENINI
                 WHERE BOLUM = @b AND DIL = 0),
               (SELECT COUNT(*) FROM ' + QUOTENAME(@db) + N'.dbo.GENINI WHERE BOLUM = @b AND DIL = 0),
               (SELECT TOP 1 PARSENAME(base_object_name, 3) FROM ' + QUOTENAME(@db) + N'.sys.synonyms
                 WHERE PARSENAME(base_object_name, 3) IS NOT NULL
                 GROUP BY PARSENAME(base_object_name, 3) ORDER BY COUNT(*) DESC),
               -- Kurulum GERCEKTEN kullaniliyor mu? BOS veritabani (hic veri girilmemis)
               --   ortak depo adayi SAYILMAZ -> tek gercek kullanicinin rename''ini engellemesin.
               (SELECT ISNULL(SUM(p.rows), 0) FROM ' + QUOTENAME(@db) + N'.sys.partitions p
                  JOIN ' + QUOTENAME(@db) + N'.sys.objects o ON o.object_id = p.object_id
                 WHERE o.name IN (''FATBASLIK'', ''REHBER'', ''STOKLAR'') AND p.index_id IN (0, 1))';
        BEGIN TRY
            EXEC sp_executesql @sql, N'@db SYSNAME, @b INT', @db = @db, @b = @DepoOpsiyon;
            UPDATE #D SET TARANDI = 'VAR' WHERE ANA_DB = @db AND TARANDI IS NULL;
        END TRY
        BEGIN CATCH
            -- Taranamayan DB'yi YOK SAYMA: ortak depoyu kullaniyor OLABILIR. Kayit
            --   olarak birak, rename kararlarinda "bilinmiyor" kabul edilip engel olsun.
            PRINT 'TARAMA HATASI (' + @db + '): ' + ERROR_MESSAGE();
            DELETE #D WHERE ANA_DB = @db AND TARANDI IS NULL;
            INSERT #D (ANA_DB, BEKLENEN, TARANDI) VALUES (@db, @db + N'_GENDEPO', 'YOK');
        END CATCH
    END
    FETCH NEXT FROM cDb INTO @db;
END
CLOSE cDb; DEALLOCATE cDb;

/* ---- 2) Gercek depoyu tespit et ------------------------------------------- */
UPDATE #D
SET GERCEK_DEPO =
      CASE WHEN DB_ID(BEKLENEN)   IS NOT NULL THEN BEKLENEN            -- 1) kural adi
           WHEN DB_ID(SYN_DEPO)   IS NOT NULL THEN SYN_DEPO            -- 2) synonym kaniti
           WHEN DB_ID(GENINI_ADI) IS NOT NULL THEN GENINI_ADI          -- 3) opsiyondaki ad
           ELSE NULL END;
/* DIKKAT: ortak 'GENDEPO'yu "sahibi belli olmayan" bir kuruluma ATAMIYORUZ.
   Eskiden 4. bir dal vardi: depo bulunamazsa 'GENDEPO' kabul ediliyordu. Bunun
   sonucu: BOS ya da SESSIZ bir veritabani ortak depoyu KENDI ADINA rename ediyor,
   depoyu GERCEKTEN kullanan kurulum (GENINI'sinde 'GENDEPO' yazan) aciKta kaliyordu.
   (Yasanmis: Bilim_Ankara ortak depoyu aldi, MAYA acilamadi.)
   Artik ortak depo yalnizca ACIK KANIT ile sahiplenilir: GENINI'de 'GENDEPO'
   yaziyorsa (3. dal) veya synonym'ler onu gosteriyorsa (2. dal). Kaniti olmayan
   kurulum icin GERCEK_DEPO = NULL -> "DEPO YOK, kendi deposu kurulmali" denir. */

/* ORTAK 'GENDEPO' SESSIZ KULLANICILARI ---------------------------------------
   KRITIK: bir veritabani hicbir yerde 'GENDEPO' YAZMADAN da o depoyu kullaniyor
   olabilir. Eski surum uygulama depo adini GENINI'de BULAMAZSA varsayilan
   'GENDEPO'ya duser. Boyle bir kurulumda:
       GENINI(-24120) kaydi yok/bos   +   kendi <DB>_GENDEPO'su yok
   demek ki ortak 'GENDEPO'ya bakiyor -> ortak depo BASKASINA verilirse (rename)
   o musteri ACILMAZ. (Yasanmis: DENTSEMBOL rename edildi, MAYA acilmadi.)
   Bu yuzden ortak depoyu kullanabilecek TUM adaylari sayariz.                  */
UPDATE #D
SET ORTAK_ADAY =
      CASE WHEN DB_ID('GENDEPO') IS NULL THEN 'yok'
           -- Elle haric tutulan kurulum
           WHEN @HaricDBler <> N''
                AND N',' + REPLACE(@HaricDBler, N' ', N'') + N',' LIKE N'%,' + ANA_DB + N',%' THEN 'yok'
           -- BOS kurulum (FATBASLIK/REHBER/STOKLAR tamamen bos) = yok hukmunde
           WHEN ISNULL(VERI_SATIR, -1) = 0 THEN 'yok'
           WHEN TARANDI = 'YOK' THEN 'VAR'
           -- FIILEN BAGLI DEGIL: hic synonym'i yok -> ortak depoya erisimi de yok.
           --   Depo ozelligini hic kullanmamis kurulumdur. Yeni exe ilk acilista KENDI
           --   deposunu kurar (32859), yani ilerde de ortak depoya dusmez. Bu yuzden
           --   depoyu GERCEKTEN kullanan kurulumun rename'ini ENGELLEMEZ.
           --   (Yasanmis: Bilim_Ankara ve Yildiz synonym'siz oldugu halde MAYA'yi bloke ediyordu.)
           WHEN SYN_DEPO IS NULL AND ISNULL(GENINI_ADI, N'') <> 'GENDEPO' THEN 'yok'
           WHEN GENINI_ADI = 'GENDEPO' OR SYN_DEPO = 'GENDEPO' THEN 'VAR'  -- acikca kullaniyor
           WHEN DB_ID(BEKLENEN) IS NULL
                AND ISNULL(GENINI_ADI, N'') = N'' THEN 'VAR'     -- SESSIZ: varsayilana duser
           ELSE 'yok' END;

/* Paylasim: ayni depoyu birden fazla ana DB gosteriyor mu?
   'GENDEPO' icin sayim ORTAK_ADAY uzerinden yapilir (sessiz kullanicilar dahil). */
UPDATE d SET PAYLASIMLI =
      CASE WHEN d.GERCEK_DEPO = 'GENDEPO'
             THEN CASE WHEN (SELECT COUNT(*) FROM #D o WHERE o.ORTAK_ADAY = 'VAR') > 1 THEN 'VAR' ELSE 'yok' END
           WHEN x.adet > 1 THEN 'VAR' ELSE 'yok' END
FROM #D d
OUTER APPLY (SELECT COUNT(*) adet FROM #D o
              WHERE o.GERCEK_DEPO = d.GERCEK_DEPO AND o.GERCEK_DEPO IS NOT NULL) x;

UPDATE #D
SET ISLEM =
      CASE WHEN GERCEK_DEPO IS NULL
             THEN N'DEPO YOK -> GenDepoKur1..9 ile kurulmali'
           WHEN GERCEK_DEPO <> BEKLENEN AND PAYLASIMLI = 'VAR'
             THEN N'ORTAK DEPO - BASKA KURULUM DA KULLANIYOR, ad DEGISTIRILMEZ'
           WHEN GERCEK_DEPO <> BEKLENEN
             THEN N'Yeniden adlandir + opsiyon(DIL=0) + synonym'
           WHEN ISNULL(GENINI_DIL0, N'') <> BEKLENEN OR ISNULL(GENINI_SATIR, 0) <> 1
             THEN N'Ad DOGRU ama opsiyon(DIL=0) hatali -> opsiyon + synonym'
           ELSE N'UYGUN' END;

/* ---- 3) Rapor ------------------------------------------------------------- */
SELECT ANA_DB, BEKLENEN, GERCEK_DEPO, GENINI_DIL0, SYN_DEPO, ORTAK_ADAY, PAYLASIMLI, TARANDI, ISLEM
FROM #D ORDER BY CASE WHEN ISLEM = N'UYGUN' THEN 1 ELSE 0 END, ANA_DB;

/* Ortak 'GENDEPO' rename'ini ENGELLEYEN adaylar: kullanici neyi cozmesi
   gerektigini gormeli. Cozum yolu: bu kurulumlara ONCE kendi depolarini kurmak
   (yeni exe ilk acilista 32859 ile kurar; ya da GenDepoKur1..9). Ortak depoya
   dusen baska kurulum kalmayinca rename serbest kalir. */
IF EXISTS (SELECT 1 FROM #D WHERE ORTAK_ADAY = 'VAR')
   AND (SELECT COUNT(*) FROM #D WHERE ORTAK_ADAY = 'VAR') > 1
BEGIN
    PRINT '';
    PRINT '!!! ORTAK ''GENDEPO'' RENAME EDILEMEZ - su kurulumlar ona dusuyor:';
    DECLARE @ad SYSNAME, @nk NVARCHAR(300);
    DECLARE cA CURSOR LOCAL FAST_FORWARD FOR
        SELECT ANA_DB, CASE WHEN TARANDI = 'YOK' THEN N'taranamadi (bilinmiyor)'
                            WHEN GENINI_ADI = 'GENDEPO' OR SYN_DEPO = 'GENDEPO' THEN N'acikca kullaniyor'
                            ELSE N'SESSIZ: opsiyon bos + kendi deposu yok -> varsayilana duser' END
          FROM #D WHERE ORTAK_ADAY = 'VAR' ORDER BY ANA_DB;
    OPEN cA; FETCH NEXT FROM cA INTO @ad, @nk;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '    - ' + @ad + '  (' + @nk + ')';
        FETCH NEXT FROM cA INTO @ad, @nk;
    END
    CLOSE cA; DEALLOCATE cA;
    PRINT '  COZUM: once bu kurulumlara KENDI depolarini kurun (yeni exe ilk acilista';
    PRINT '         kurar; ya da GenDepoKur1..9). Ortak depoya dusen baska kurulum';
    PRINT '         kalmayinca bu betik rename''i yapabilir.';
    PRINT '';
END

IF @Uygula = 0
BEGIN
    PRINT '';
    PRINT '*** RAPOR MODU - hicbir degisiklik yapilmadi. ***';
    PRINT 'Uygulamak icin @Uygula = 1 yapip tekrar calistirin (Gentegre oturumlari KAPALI olsun).';
    RETURN;
END

/* ---- 4) Onarim ------------------------------------------------------------ */
DECLARE @beklenen SYSNAME, @gercek SYSNAME, @islem NVARCHAR(200);

DECLARE cIs CURSOR LOCAL FAST_FORWARD FOR
    SELECT ANA_DB, BEKLENEN, GERCEK_DEPO, ISLEM FROM #D
     WHERE ISLEM NOT IN (N'UYGUN', N'DEPO YOK -> GenDepoKur1..9 ile kurulmali',
                         N'ORTAK DEPO - BASKA KURULUM DA KULLANIYOR, ad DEGISTIRILMEZ');
OPEN cIs; FETCH NEXT FROM cIs INTO @db, @beklenen, @gercek, @islem;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '--- ' + @db + ' : ' + ISNULL(@gercek, '(yok)') + ' -> ' + @beklenen;
    BEGIN TRY
        /* 4a) Yeniden adlandirma (yalniz gerekiyorsa)
               SON KONTROL: ortak 'GENDEPO' birden fazla kurulumun adayiysa ASLA rename etme.
               (Rename edilirse digerleri - ozellikle ESKI surum exe kullananlar - acilmaz.) */
        IF @gercek = 'GENDEPO'
           AND (SELECT COUNT(*) FROM #D WHERE ORTAK_ADAY = 'VAR') > 1
        BEGIN
            PRINT '    ATLANDI: ortak GENDEPO''yu birden fazla kurulum kullaniyor olabilir.';
            FETCH NEXT FROM cIs INTO @db, @beklenen, @gercek, @islem;
            CONTINUE;
        END

        IF @gercek <> @beklenen
        BEGIN
            SET @sql = N'ALTER DATABASE ' + QUOTENAME(@gercek) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
            EXEC sp_executesql @sql;
            SET @sql = N'ALTER DATABASE ' + QUOTENAME(@gercek) + N' MODIFY NAME = ' + QUOTENAME(@beklenen) + N';';
            EXEC sp_executesql @sql;
            SET @sql = N'ALTER DATABASE ' + QUOTENAME(@beklenen) + N' SET MULTI_USER;';
            EXEC sp_executesql @sql;
            PRINT '    veritabani yeniden adlandirildi';
        END

        /* 4b) GENINI opsiyonu: uygulamanin OKUDUGU bicim -> DIL = 0, TEK satir.
               Once bu bolumun TUM satirlari silinir, sonra tek dogru satir yazilir. */
        SET @sql = N'
            DELETE FROM ' + QUOTENAME(@db) + N'.dbo.GENINI WHERE BOLUM = @b;
            INSERT ' + QUOTENAME(@db) + N'.dbo.GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA)
            VALUES (@b, @y, 0, 0, 0);';
        EXEC sp_executesql @sql, N'@b INT, @y NVARCHAR(200)', @b = @DepoOpsiyon, @y = @beklenen;
        PRINT '    opsiyon yazildi (DIL=0, tek satir): ' + @beklenen;

        /* 4c) Synonym'ler: hedefi @beklenen olmayan TUM depo synonym'leri yeniden kurulur */
        SET @sql = N'EXEC ' + QUOTENAME(@db) + N'.sys.sp_executesql N''
            DECLARE @s SYSNAME, @t SYSNAME, @c NVARCHAR(MAX), @n INT = 0;
            DECLARE cS CURSOR LOCAL FAST_FORWARD FOR
                SELECT name, PARSENAME(base_object_name, 1) FROM sys.synonyms
                 WHERE PARSENAME(base_object_name, 3) IS NOT NULL
                   AND PARSENAME(base_object_name, 3) <> @y;
            OPEN cS; FETCH NEXT FROM cS INTO @s, @t;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @c = N''''DROP SYNONYM dbo.'''' + QUOTENAME(@s) +
                         N''''; CREATE SYNONYM dbo.'''' + QUOTENAME(@s) +
                         N'''' FOR '''' + QUOTENAME(@y) + N''''.dbo.'''' + QUOTENAME(@t) + N'''';'''';
                EXEC sp_executesql @c;
                SET @n = @n + 1;
                FETCH NEXT FROM cS INTO @s, @t;
            END
            CLOSE cS; DEALLOCATE cS;
            IF @n > 0 PRINT ''''    '''' + CAST(@n AS varchar(10)) + '''' synonym yeni depoya cevrildi'''';
        '', N''@y SYSNAME'', @y = @yy;';
        EXEC sp_executesql @sql, N'@yy SYSNAME', @yy = @beklenen;
    END TRY
    BEGIN CATCH
        PRINT '    HATA: ' + ERROR_MESSAGE();
    END CATCH

    FETCH NEXT FROM cIs INTO @db, @beklenen, @gercek, @islem;
END
CLOSE cIs; DEALLOCATE cIs;

/* ---- 5) Son durum --------------------------------------------------------- */
PRINT '';
PRINT '--- ONARIM SONRASI ---';
DECLARE @son TABLE (ANA_DB SYSNAME, OPSIYON NVARCHAR(200), SATIR INT, DEPO_VAR CHAR(3));
DECLARE cSon CURSOR LOCAL FAST_FORWARD FOR SELECT ANA_DB FROM #D;
OPEN cSon; FETCH NEXT FROM cSon INTO @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'SELECT @db,
        (SELECT TOP 1 ANAHTAR FROM ' + QUOTENAME(@db) + N'.dbo.GENINI WHERE BOLUM = @b AND DIL = 0),
        (SELECT COUNT(*) FROM ' + QUOTENAME(@db) + N'.dbo.GENINI WHERE BOLUM = @b AND DIL = 0),
        CASE WHEN DB_ID(@db + N''_GENDEPO'') IS NULL THEN ''YOK'' ELSE ''VAR'' END';
    INSERT @son EXEC sp_executesql @sql, N'@db SYSNAME, @b INT', @db = @db, @b = @DepoOpsiyon;
    FETCH NEXT FROM cSon INTO @db;
END
CLOSE cSon; DEALLOCATE cSon;

SELECT ANA_DB, OPSIYON, DIL0_SATIR = SATIR, DEPO_VAR,
       DURUM = CASE WHEN OPSIYON = ANA_DB + N'_GENDEPO' AND SATIR = 1 AND DEPO_VAR = 'VAR'
                    THEN 'TAMAM' ELSE 'KONTROL EDIN' END
FROM @son ORDER BY ANA_DB;


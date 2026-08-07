/* ############################################################################
   !!! BU BETIK ARTIK KULLANILMAMALIDIR - YERINE  depo_adlandirma_onar.sql  !!!

   KUSUR (06.08.2026 tespit): GENINI depo opsiyonunu uygulamanin OKUMADIGI
   bicimde yaziyordu. Uygulama (UGENINIDuzenle.ReadString) opsiyonu
       select ANAHTAR from GENINI where BOLUM = -24120 and DIL = 0
       ... if RecordCount = 1 then <deger> else <varsayilan 'GENDEPO'>
   seklinde okur; yani satir DIL = 0 olmali ve TAM BIR tane olmalidir.
   Bu betik ise  INSERT ... DIL = -1  yaziyor ve okurken DIL'i hic
   filtrelemiyordu -> uygulama depo adini goremeyip 'GENDEPO' varsayimina
   dusuyor, depo YANLIS baglaniyordu.

   Asagidaki gövde bu kusur giderilmis haliyle birakilmistir (yanlislikla
   calistirilirsa zarar vermesin diye), ancak ONARIM ICIN
       GenUpdate/depo_adlandirma_onar.sql
   kullanin: o betik her ana veritabanini KENDI deposuna baglar, paylasimli
   depoyu korur ve opsiyonu DIL = 0 / tek satir olarak yazar.
############################################################################ */

/* ============================================================================
   depo_adlandirma_duzelt.sql   —   MASTER veritabaninda calistirilir (SSMS)

   DEPO ADLANDIRMA KURALI (05.08.2026): depo veritabani adi  <ANA_DB>_GENDEPO
     olmak zorunda (GENTEGRE -> GENTEGRE_GENDEPO, SDI -> SDI_GENDEPO ...).
     Ayni sunucuda birden fazla Gentegre veritabani bulunabildigi icin ortak
     'GENDEPO' adi yanlis depoya (ISLEMLOG / EBELGE / DOSYA) yazma riski
     tasiyordu. Uygulama acilista denetler (ULog.DepoKuralDenetle) ve kurala
     uymayan kurulumda HATA verir.

   NE YAPAR (kurala uymayan her Gentegre veritabani icin):
     1) Depo veritabanini yeniden adlandirir  (ALTER DATABASE ... MODIFY NAME)
     2) Ana DB'deki GENINI depo opsiyonunu (BOLUM = -24120) yeni ada gunceller
     3) Ana DB'deki depo synonym'lerini yeni depoya cevirir

   KULLANIM:
     - Once oldugu gibi calistirin  -> yalnizca RAPOR verir, hicbir sey degismez.
     - Uygulamak icin asagidaki @Uygula degerini 1 yapip tekrar calistirin.

   UYARI:
     * Yeniden adlandirma SINGLE_USER ister -> ilgili veritabanina bagli
       uygulama OLMAMALI (ROLLBACK IMMEDIATE acik baglantilari duserur).
       Once Gentegre'yi kapatin.
     * Veri kaybi YOK; islem geri alinabilir (ad geri degistirilebilir).
     * Hedef depo hic yoksa yeniden adlandirma yapilamaz; o kurulumda depo
       GenDepoKur1..9 ile KURULMALI (script bunu ayrica raporlar).
============================================================================ */

USE master;
GO
SET NOCOUNT ON;

------------------------------------------------------------------------------
DECLARE @Uygula BIT = 0;      -- 0 = yalniz rapor   |   1 = DEGISIKLIGI UYGULA
------------------------------------------------------------------------------

DECLARE @DepoOpsiyon INT = -24120;    -- Ops_FaturaOpsiyon_DepoDBAdi

IF OBJECT_ID('tempdb..#Durum') IS NOT NULL DROP TABLE #Durum;
CREATE TABLE #Durum (
    ANA_DB        SYSNAME,
    TANIMLI_DEPO  NVARCHAR(200),
    OLMASI_GEREK  SYSNAME,
    KAYNAK_VAR    CHAR(3),      -- yeniden adlandirilacak (eski) depo duruyor mu
    HEDEF_VAR     CHAR(3),      -- dogru adli depo zaten var mi
    SONUC         NVARCHAR(200)
);

/* ---- 1) Tarama: Gentegre ana veritabanlarini ve depo adlarini topla -------- */
DECLARE @db SYSNAME, @sql NVARCHAR(MAX), @mevcut NVARCHAR(200), @beklenen SYSNAME, @genini BIT;

DECLARE cDb CURSOR LOCAL FAST_FORWARD FOR
    SELECT name FROM sys.databases
     WHERE database_id > 4 AND state = 0 AND name NOT LIKE '%[_]GENDEPO'
     ORDER BY name;

OPEN cDb;
FETCH NEXT FROM cDb INTO @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Gentegre ana veritabani mi? (GENINI tablosu var mi)
    SET @genini = 0;
    SET @sql = N'SELECT @o = CASE WHEN OBJECT_ID(''' + QUOTENAME(@db) + N'.dbo.GENINI'') IS NULL THEN 0 ELSE 1 END';
    EXEC sp_executesql @sql, N'@o BIT OUTPUT', @o = @genini OUTPUT;

    IF @genini = 1
    BEGIN
        SET @mevcut = N'';
        SET @sql = N'SELECT @o = ISNULL((SELECT TOP 1 ANAHTAR FROM ' + QUOTENAME(@db) + N'.dbo.GENINI
                                          WHERE BOLUM = @b ORDER BY CASE WHEN DIL = 0 THEN 0 ELSE 1 END), N'''')';
        EXEC sp_executesql @sql, N'@b INT, @o NVARCHAR(200) OUTPUT', @b = @DepoOpsiyon, @o = @mevcut OUTPUT;

        SET @beklenen = @db + N'_GENDEPO';

        INSERT #Durum (ANA_DB, TANIMLI_DEPO, OLMASI_GEREK, KAYNAK_VAR, HEDEF_VAR, SONUC)
        SELECT @db,
               CASE WHEN @mevcut = N'' THEN N'(bos -> GENDEPO)' ELSE @mevcut END,
               @beklenen,
               CASE WHEN DB_ID(CASE WHEN @mevcut = N'' THEN N'GENDEPO' ELSE @mevcut END) IS NULL THEN 'YOK' ELSE 'VAR' END,
               CASE WHEN DB_ID(@beklenen) IS NULL THEN 'YOK' ELSE 'VAR' END,
               CASE WHEN @mevcut = @beklenen AND DB_ID(@beklenen) IS NOT NULL THEN N'UYGUN'
                    WHEN DB_ID(@beklenen) IS NOT NULL THEN N'Ad dogru degil (hedef depo zaten var) -> opsiyon+synonym'
                    WHEN DB_ID(CASE WHEN @mevcut = N'' THEN N'GENDEPO' ELSE @mevcut END) IS NOT NULL
                         THEN N'Yeniden adlandirilacak'
                    ELSE N'DEPO YOK -> GenDepoKur1..9 ile kurulmali' END;
    END

    FETCH NEXT FROM cDb INTO @db;
END
CLOSE cDb; DEALLOCATE cDb;

/* ---- 2) Rapor ------------------------------------------------------------- */
SELECT * FROM #Durum ORDER BY CASE WHEN SONUC = N'UYGUN' THEN 1 ELSE 0 END, ANA_DB;

IF @Uygula = 0
BEGIN
    PRINT '';
    PRINT '*** RAPOR MODU - hicbir degisiklik yapilmadi. ***';
    PRINT 'Uygulamak icin script basindaki  @Uygula = 0  satirini  @Uygula = 1  yapin.';
    PRINT 'ONCE ilgili veritabanlarina bagli Gentegre oturumlarini KAPATIN.';
    RETURN;
END

/* ---- 3) Uygulama ---------------------------------------------------------- */
DECLARE @eski SYSNAME, @yeni SYSNAME, @kaynakVar CHAR(3), @hedefVar CHAR(3);

DECLARE cIs CURSOR LOCAL FAST_FORWARD FOR
    SELECT ANA_DB,
           CASE WHEN TANIMLI_DEPO = N'(bos -> GENDEPO)' THEN N'GENDEPO' ELSE TANIMLI_DEPO END,
           OLMASI_GEREK, KAYNAK_VAR, HEDEF_VAR
      FROM #Durum
     WHERE SONUC <> N'UYGUN';

OPEN cIs;
FETCH NEXT FROM cIs INTO @db, @eski, @yeni, @kaynakVar, @hedefVar;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '--- ' + @db + ' : ' + @eski + ' -> ' + @yeni;

    BEGIN TRY
        /* 3a) Yeniden adlandirma (hedef yoksa ve kaynak varsa) */
        IF @hedefVar = 'YOK' AND @kaynakVar = 'VAR'
        BEGIN
            SET @sql = N'ALTER DATABASE ' + QUOTENAME(@eski) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
            EXEC sp_executesql @sql;
            SET @sql = N'ALTER DATABASE ' + QUOTENAME(@eski) + N' MODIFY NAME = ' + QUOTENAME(@yeni) + N';';
            EXEC sp_executesql @sql;
            SET @sql = N'ALTER DATABASE ' + QUOTENAME(@yeni) + N' SET MULTI_USER;';
            EXEC sp_executesql @sql;
            PRINT '    veritabani yeniden adlandirildi';
        END
        ELSE IF @hedefVar = 'VAR'
            PRINT '    hedef ad zaten var -> yalniz opsiyon + synonym';
        ELSE
        BEGIN
            PRINT '    UYARI: kaynak depo (' + @eski + ') bulunamadi -> once GenDepoKur1..9 calistirin';
            FETCH NEXT FROM cIs INTO @db, @eski, @yeni, @kaynakVar, @hedefVar;
            CONTINUE;
        END

        /* 3b) GENINI depo opsiyonu (upsert) */
        SET @sql = N'
            DELETE FROM ' + QUOTENAME(@db) + N'.dbo.GENINI WHERE BOLUM = @b;
            INSERT ' + QUOTENAME(@db) + N'.dbo.GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA)
            VALUES (@b, @y, 0, 0, 0);';
        EXEC sp_executesql @sql, N'@b INT, @y NVARCHAR(200)', @b = @DepoOpsiyon, @y = @yeni;
        PRINT '    opsiyon guncellendi';

        /* 3c) Depo synonym'lerini yeni depoya cevir
               (ana DB icinde calismali -> hedef DB'nin sp_executesql'i kullanilir) */
        SET @sql = N'
            DECLARE @s SYSNAME, @t SYSNAME, @c NVARCHAR(MAX);
            DECLARE cS CURSOR LOCAL FAST_FORWARD FOR
                SELECT name, PARSENAME(base_object_name, 1)
                  FROM sys.synonyms
                 WHERE PARSENAME(base_object_name, 3) IS NOT NULL
                   AND PARSENAME(base_object_name, 3) <> @y;
            OPEN cS; FETCH NEXT FROM cS INTO @s, @t;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @c = N''DROP SYNONYM dbo.'' + QUOTENAME(@s) +
                         N''; CREATE SYNONYM dbo.'' + QUOTENAME(@s) +
                         N'' FOR '' + QUOTENAME(@y) + N''.dbo.'' + QUOTENAME(@t) + N'';'';
                EXEC sp_executesql @c;
                FETCH NEXT FROM cS INTO @s, @t;
            END
            CLOSE cS; DEALLOCATE cS;';
        SET @sql = QUOTENAME(@yeni) + N'..sp_executesql';   -- yer tutucu (asagida gercek cagri)

        -- Synonym'ler ANA DB'de duruyor -> ana DB baglaminda calistir
        SET @sql = N'EXEC ' + QUOTENAME(@db) + N'.sys.sp_executesql N''
            DECLARE @s SYSNAME, @t SYSNAME, @c NVARCHAR(MAX);
            DECLARE cS CURSOR LOCAL FAST_FORWARD FOR
                SELECT name, PARSENAME(base_object_name, 1)
                  FROM sys.synonyms
                 WHERE PARSENAME(base_object_name, 3) IS NOT NULL
                   AND PARSENAME(base_object_name, 3) <> @y;
            OPEN cS; FETCH NEXT FROM cS INTO @s, @t;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @c = N''''DROP SYNONYM dbo.'''' + QUOTENAME(@s) +
                         N''''; CREATE SYNONYM dbo.'''' + QUOTENAME(@s) +
                         N'''' FOR '''' + QUOTENAME(@y) + N''''.dbo.'''' + QUOTENAME(@t) + N'''';'''';
                EXEC sp_executesql @c;
                FETCH NEXT FROM cS INTO @s, @t;
            END
            CLOSE cS; DEALLOCATE cS;'', N''@y SYSNAME'', @y = ' + QUOTENAME(@yeni, '''') + N';';
        EXEC sp_executesql @sql;
        PRINT '    synonym''ler cevrildi';
    END TRY
    BEGIN CATCH
        PRINT '    HATA: ' + ERROR_MESSAGE();
    END CATCH

    FETCH NEXT FROM cIs INTO @db, @eski, @yeni, @kaynakVar, @hedefVar;
END
CLOSE cIs; DEALLOCATE cIs;

PRINT '';
PRINT 'Bitti. Dogrulama icin scripti @Uygula = 0 ile tekrar calistirin.';
GO

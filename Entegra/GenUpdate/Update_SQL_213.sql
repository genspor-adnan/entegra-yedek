/*
  Update_SQL_213 - Eski fatura/irsaliye/siparislere carinin varsayilan iletisimi.

  Giris belgelerinde (alis faturasi/irsaliyesi/fisi) ve verilen sipariste
  REHBERILETID hic atanmiyordu (0/NULL). Program artik yeni kayitta varsayilan
  iletisimi yaziyor; bu script eski kayitlari tamamlar.

  Kapsam (yalniz REHBERILETID BOS olanlar - dolu olana dokunulmaz):
    FATBASLIK TUR 8,10,11,12,14,15,16  (gider pusulasi, alis/satis irsaliye, fatura, fis)
    SIPARIS   TUR 9,19                 (verilen/alinan siparis)
  Deger: carinin VARSAYILAN=1 iletisimi, yoksa ilk iletisimi. Carinin iletisimi
  yoksa satir bos kalir (yeni iletisim ACILMAZ).

  Yedek: degisen her satirin ID'si ve eski degeri ZZ_YEDEK_ILETISIM_213'e yazilir.
  Geri almak icin:
    UPDATE F SET REHBERILETID = Y.ESKI FROM FATBASLIK F
      JOIN ZZ_YEDEK_ILETISIM_213 Y ON Y.TABLO='FATBASLIK' AND Y.ID=F.ID;
    (SIPARIS icin ayni, TABLO='SIPARIS')

  Tetikleyiciler: REHBERILETID bakiyeyi/aktarimi etkilemez; TG_FatBaslik_CariBakiye
  (satir satir cursor) ve trg_Siparis_Aktarim (tek-satir varsayimli) bu guncelleme
  icin ISLEM ICINDE kapatilir, sonunda acilir. Hata olursa islem geri alinir
  (DISABLE TRIGGER da geri alinir). Tekrar calistirilirsa yalniz hala bos olanlara bakar.
*/
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;   -- FATBASLIK'ta filtreli index var; UPDATE bunu ister
SET ANSI_NULLS ON;

IF OBJECT_ID('dbo.ZZ_YEDEK_ILETISIM_213') IS NULL
    CREATE TABLE dbo.ZZ_YEDEK_ILETISIM_213 (
        TABLO  NVARCHAR(20) NOT NULL,
        ID     INT          NOT NULL,
        ESKI   INT          NULL,
        YENI   INT          NOT NULL,
        TARIH  DATETIME     NOT NULL DEFAULT GETDATE());

DECLARE @Hedef TABLE (TABLO NVARCHAR(20), ID INT, ESKI INT NULL, YENI INT,
                      PRIMARY KEY (TABLO, ID));

INSERT @Hedef (TABLO, ID, ESKI, YENI)
SELECT N'FATBASLIK', F.ID, F.REHBERILETID, V.ID
FROM dbo.FATBASLIK F
CROSS APPLY (SELECT TOP 1 RI.ID FROM dbo.REHBERILETISIM RI
             WHERE RI.REHBERID = F.REHBERID
             ORDER BY CASE WHEN RI.VARSAYILAN = 1 THEN 0 ELSE 1 END, RI.ID) V
WHERE F.TUR IN (8, 10, 11, 12, 14, 15, 16)
  AND F.REHBERID > 0
  AND ISNULL(F.REHBERILETID, 0) = 0;

INSERT @Hedef (TABLO, ID, ESKI, YENI)
SELECT N'SIPARIS', S.ID, S.REHBERILETID, V.ID
FROM dbo.SIPARIS S
CROSS APPLY (SELECT TOP 1 RI.ID FROM dbo.REHBERILETISIM RI
             WHERE RI.REHBERID = S.REHBERID
             ORDER BY CASE WHEN RI.VARSAYILAN = 1 THEN 0 ELSE 1 END, RI.ID) V
WHERE S.TUR IN (9, 19)
  AND S.REHBERID > 0
  AND ISNULL(S.REHBERILETID, 0) = 0;

DECLARE @NF INT = (SELECT COUNT(*) FROM @Hedef WHERE TABLO = N'FATBASLIK'),
        @NS INT = (SELECT COUNT(*) FROM @Hedef WHERE TABLO = N'SIPARIS');
PRINT N'Update213: guncellenecek FATBASLIK=' + CAST(@NF AS NVARCHAR(10)) +
      N', SIPARIS=' + CAST(@NS AS NVARCHAR(10));

IF @NF + @NS > 0
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        INSERT dbo.ZZ_YEDEK_ILETISIM_213 (TABLO, ID, ESKI, YENI)
        SELECT TABLO, ID, ESKI, YENI FROM @Hedef;

        IF @NF > 0
        BEGIN
            IF OBJECT_ID('dbo.TG_FatBaslik_CariBakiye', 'TR') IS NOT NULL
                DISABLE TRIGGER dbo.TG_FatBaslik_CariBakiye ON dbo.FATBASLIK;
            UPDATE F SET F.REHBERILETID = H.YENI
            FROM dbo.FATBASLIK F
            INNER JOIN @Hedef H ON H.TABLO = N'FATBASLIK' AND H.ID = F.ID
            WHERE ISNULL(F.REHBERILETID, 0) = 0;
            IF OBJECT_ID('dbo.TG_FatBaslik_CariBakiye', 'TR') IS NOT NULL
                ENABLE TRIGGER dbo.TG_FatBaslik_CariBakiye ON dbo.FATBASLIK;
        END

        IF @NS > 0
        BEGIN
            IF OBJECT_ID('dbo.trg_Siparis_Aktarim', 'TR') IS NOT NULL
                DISABLE TRIGGER dbo.trg_Siparis_Aktarim ON dbo.SIPARIS;
            UPDATE S SET S.REHBERILETID = H.YENI
            FROM dbo.SIPARIS S
            INNER JOIN @Hedef H ON H.TABLO = N'SIPARIS' AND H.ID = S.ID
            WHERE ISNULL(S.REHBERILETID, 0) = 0;
            IF OBJECT_ID('dbo.trg_Siparis_Aktarim', 'TR') IS NOT NULL
                ENABLE TRIGGER dbo.trg_Siparis_Aktarim ON dbo.SIPARIS;
        END

        COMMIT;
        PRINT N'Update213: tamamlandi.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END

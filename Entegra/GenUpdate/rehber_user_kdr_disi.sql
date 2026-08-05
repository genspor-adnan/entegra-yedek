/* ============================================================================
   rehber_user_kdr_disi.sql  —  MUSTERI ANA veritabaninda calistirilir
   KDR raporlarindan ONCE calistirilmalidir.

   AMAC: KDR raporlarinin bagimli oldugu REHBER_USER tablosunu ve KDR_Disi
         kolonunu GARANTIYE ALIR (yoksa olusturur).

   NEDEN: KDR_SONUC / KDR_BORCLULAR / KDR_ALACAKLILAR raporlari
            LEFT JOIN REHBER_USER RU ON RU.ID = R.ID
            WHERE ISNULL(RU.KDR_Disi,'False') = 'False'
          seklinde REHBER_USER tablosunu kullanir ("bu cariyi karar destek
          raporlarina dahil etme" isareti). Bu tablo KULLANICI EK ALAN tablosudur
          ve her kurulumda BULUNMAZ (musteri ek alan tanimlamadiysa hic olusmaz).
          Tablo ya da kolon yoksa raporlar
             "Invalid object name 'REHBER_USER'"  /  "Invalid column name 'KDR_Disi'"
          hatasi verir ve Ana Giris > KDR paneli acilmaz.

   NE YAPAR (idempotent):
     1) REHBER_USER yoksa olusturur (standart _USER deseni: ID + audit kolonlari).
     2) KDR_Disi kolonu yoksa ekler (nvarchar(60), NULL = rapora DAHIL).
     Mevcut tabloya/kolona DOKUNMAZ, veri SILMEZ.

   NOT: Deger 'True' olan cariler raporlarin DISINDA kalir; NULL/'False' dahil edilir.
============================================================================ */
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

/* ---- 1) Tablo ------------------------------------------------------------- */
IF OBJECT_ID('dbo.REHBER_USER', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.REHBER_USER
    (
        ID               int NOT NULL,
        EKLEYEN          int NULL,
        EKLEMETARIHI     datetime NULL,
        DEGISTIREN       int NULL,
        DEGISTIRMETARIHI datetime NULL,
        CONSTRAINT PK_REHBER_USER PRIMARY KEY CLUSTERED (ID)
    );
    PRINT 'REHBER_USER olusturuldu.';
END
ELSE
    PRINT 'REHBER_USER zaten var.';

/* ---- 2) KDR_Disi kolonu --------------------------------------------------- */
IF COL_LENGTH('dbo.REHBER_USER', 'KDR_Disi') IS NULL
BEGIN
    ALTER TABLE dbo.REHBER_USER ADD KDR_Disi nvarchar(60) NULL;
    PRINT 'KDR_Disi kolonu eklendi.';
END
ELSE
    PRINT 'KDR_Disi kolonu zaten var.';

/* ---- 3) Durum ------------------------------------------------------------- */
SELECT VERITABANI   = DB_NAME(),
       REHBER_USER  = CASE WHEN OBJECT_ID('dbo.REHBER_USER','U') IS NULL THEN 'YOK' ELSE 'VAR' END,
       KDR_DISI     = CASE WHEN COL_LENGTH('dbo.REHBER_USER','KDR_Disi') IS NULL THEN 'YOK' ELSE 'VAR' END,
       KAYIT        = (SELECT COUNT(*) FROM dbo.REHBER_USER),
       RAPOR_DISI   = (SELECT COUNT(*) FROM dbo.REHBER_USER WHERE ISNULL(KDR_Disi,'False') <> 'False');

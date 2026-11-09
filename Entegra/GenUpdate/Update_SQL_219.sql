/*
  Update_SQL_219 - Fatura ek alanlari: doktor / hasta (medikal) + SGK ilave fatura tipi listesi.

  Alanlar FATBASLIK_USER kolonudur, ALANLAR mekanizmasiyla fatura wizard'inda
  (PanelEkAlanlar) gorunur; fatura listesinde "Ek Alanlar Listelensin"
  isaretlenince kolon olarak gelir (UFaturalar.EkAlanlariGetir; liste SP'si
  FATBASLIK_USER'i yalniz bu durumda join'ler).

  1) Medikal kolonlar (DOKTOR, HASTA, KIMLIK_*, KURUM*, PROTOKOLNO ...) yalniz
     YOKSA eklenir. Kolon adlari mevcut medikal musterilerle ayni: konsinye
     trigger'i (trg_FATBASLIK_DOKTOR) ve e-Irsaliye sorgusu (FBU.HASTA, KURUM,
     ISLEMNO, OPERASYONTARIHI) bu adlarla okur. Var olan kolonun tipine dokunulmaz.
  2) ALANLAR satiri (alan + etiketi) yalniz o ALANADI icin FaturaWizardDlg'de
     satir YOKSA eklenir; musterinin kendi tanimi/yerlesimi korunur.
     DOKTOR ve KURUM rehberden secilir (button edit, TUR=7).
  3) SGK: e-Fatura kodu SGK_* kolonlarini okur (Update_SQL_178). Ayri
     MUKELLEF_KODU / ILAVE_FATURA_TIPI kolonu ACILMAZ. Yalniz SGK_ILAVE_TIPI
     178'in varsayilan tanimindaysa (serbest metin) GIB deger listesinden
     secilen combobox'a cevrilir.

  4) REHBER_FATEKALAN: carinin kullandigi ek alanlar (REHBERID, ALANADI, SIRA).
     Fatura wizard'i > Ek Alanlar > sag tus "Bu Cari Icin Alanlari Sec" ile
     doldurulur. Satiri olmayan caride tum alanlar gorunur (bugunku davranis).

  Tekrar calistirilabilir. Tek batch (GO yok).
*/
SET NOCOUNT ON;

IF OBJECT_ID('dbo.FATBASLIK_USER','U') IS NULL
BEGIN
  CREATE TABLE dbo.FATBASLIK_USER(
    ID int NOT NULL,
    SEVKBILGISI nvarchar(max) NULL,
    EKLEYEN int NULL,
    EKLEMETARIHI datetime NULL CONSTRAINT DF_FATBASLIK_USER_EKLEMETARIHI DEFAULT(getdate()),
    DEGISTIREN int NULL,
    DEGISTIRMETARIHI datetime NULL,
    CONSTRAINT PK_FATBASLIK_USER PRIMARY KEY CLUSTERED(ID),
    CONSTRAINT FK_FATBASLIK_USER_FATBASLIK FOREIGN KEY(ID) REFERENCES dbo.FATBASLIK(ID));
END

-- 1) kolonlar
IF COL_LENGTH('dbo.FATBASLIK_USER','DOKTOR') IS NULL          ALTER TABLE dbo.FATBASLIK_USER ADD [DOKTOR] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','HASTA') IS NULL           ALTER TABLE dbo.FATBASLIK_USER ADD [HASTA] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','KIMLIK_TUR') IS NULL      ALTER TABLE dbo.FATBASLIK_USER ADD [KIMLIK_TUR] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','KIMLIK_NO') IS NULL       ALTER TABLE dbo.FATBASLIK_USER ADD [KIMLIK_NO] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','KURUM') IS NULL           ALTER TABLE dbo.FATBASLIK_USER ADD [KURUM] [nvarchar](120) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','KURUM_KOD') IS NULL       ALTER TABLE dbo.FATBASLIK_USER ADD [KURUM_KOD] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','OPERASYONTARIHI') IS NULL ALTER TABLE dbo.FATBASLIK_USER ADD [OPERASYONTARIHI] [datetime] NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','PROTOKOLNO') IS NULL      ALTER TABLE dbo.FATBASLIK_USER ADD [PROTOKOLNO] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','HISNO') IS NULL           ALTER TABLE dbo.FATBASLIK_USER ADD [HISNO] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','DOSYANO') IS NULL         ALTER TABLE dbo.FATBASLIK_USER ADD [DOSYANO] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','ISLEMNO') IS NULL         ALTER TABLE dbo.FATBASLIK_USER ADD [ISLEMNO] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','IHALETALEPNO') IS NULL    ALTER TABLE dbo.FATBASLIK_USER ADD [IHALETALEPNO] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','SIPARISNO') IS NULL       ALTER TABLE dbo.FATBASLIK_USER ADD [SIPARISNO] [nvarchar](100) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER','SIPARISTARIHI') IS NULL   ALTER TABLE dbo.FATBASLIK_USER ADD [SIPARISTARIHI] [datetime] NULL;

-- 2) wizard alanlari: iki kolon, etiket solda (PanelEkAlanlar 1096x149; SGK alanlari LEFT<600)
DECLARE @Ekran varchar(50) = 'FaturaWizardDlg';
DECLARE @Tablo nvarchar(60) = N'FATBASLIK_USER';
DECLARE @Konum varchar(20) = 'PanelEkAlanlar';

DECLARE @Alan TABLE(SIRA int, ALANADI varchar(20), CAPTION varchar(50), TUR tinyint, SQL varchar(200));
INSERT INTO @Alan VALUES
 ( 1, 'DOKTOR',          N'Doktor',          7, 'SELECT ID,FIRMA FROM REHBER R INNER JOIN GENINI G ON G.BOLUM = -2203 AND G.ANAHTAR = ''Doktor'' AND R.SINIF = G.DEGER WHERE FIRMA like ''%<ara>%'''),
 ( 2, 'HASTA',           N'Hasta',           1, NULL),
 ( 3, 'KIMLIK_TUR',      N'Kimlik Türü',     1, NULL),
 ( 4, 'KIMLIK_NO',       N'Kimlik No',       1, NULL),
 ( 5, 'KURUM',           N'Kurum',           7, 'select ID,FIRMA FROM REHBER WHERE GRUP IN (120) and FIRMA like ''%<ara>%'''),
 ( 6, 'KURUM_KOD',       N'Kurum Kodu',      1, NULL),
 ( 7, 'OPERASYONTARIHI', N'Operasyon Tarihi',3, NULL),
 ( 8, 'PROTOKOLNO',      N'Protokol No',     1, NULL),
 ( 9, 'HISNO',           N'HIS No',          1, NULL),
 (10, 'DOSYANO',         N'Dosya No',        1, NULL),
 (11, 'ISLEMNO',         N'İşlem No',        1, NULL),
 (12, 'IHALETALEPNO',    N'İhale Talep No',  1, NULL),
 (13, 'SIPARISNO',       N'Sipariş No',      1, NULL),
 (14, 'SIPARISTARIHI',   N'Sipariş Tarihi',  3, NULL);

-- yalniz tanimi olmayan alanlar (etiketi de onunla birlikte eklenir)
DECLARE @Yeni TABLE(SIRA int, ALANADI varchar(20), CAPTION varchar(50), TUR tinyint, SQL varchar(200), SOL int, UST int);
INSERT INTO @Yeni
SELECT A.SIRA, A.ALANADI, A.CAPTION, A.TUR, A.SQL,
       CASE WHEN A.SIRA <= 7 THEN 600 ELSE 845 END,
       2 + 21 * ((A.SIRA - 1) % 7)
  FROM @Alan A
 WHERE NOT EXISTS (SELECT 1 FROM dbo.ALANLAR L WHERE L.EKRANADI = @Ekran AND L.ALANADI = A.ALANADI);

INSERT INTO dbo.ALANLAR
  (EKRANADI,TUR,TABLO,ALANADI,CAPTION,SQL,KONUM,TAG,[LEFT],[TOP],BOLD,ITALIK,ALTCIZGI,FONT,FONTCOLOR,FONTSIZE,ARKARENK,HEIGHT,WIDTH,EKLEYEN,EKLEMETARIHI,SUBEID)
SELECT @Ekran, 11, @Tablo, 'LBL_' + Y.ALANADI, Y.CAPTION, NULL, @Konum, 25, Y.SOL, Y.UST + 2,
       0,0,0,'Tahoma','clWindowText',8,'16777215',18,85,1,GETDATE(),1
  FROM @Yeni Y
 WHERE NOT EXISTS (SELECT 1 FROM dbo.ALANLAR L WHERE L.EKRANADI = @Ekran AND L.ALANADI = 'LBL_' + Y.ALANADI)
 ORDER BY Y.SIRA;

INSERT INTO dbo.ALANLAR
  (EKRANADI,TUR,TABLO,ALANADI,CAPTION,SQL,KONUM,TAG,[LEFT],[TOP],BOLD,ITALIK,ALTCIZGI,FONT,FONTCOLOR,FONTSIZE,ARKARENK,HEIGHT,WIDTH,EKLEYEN,EKLEMETARIHI,SUBEID)
SELECT @Ekran, Y.TUR, @Tablo, Y.ALANADI, Y.CAPTION, Y.SQL, @Konum, 25, Y.SOL + 85, Y.UST,
       0,0,0,'Tahoma','clWindowText',8,'16777215',21,150,1,GETDATE(),1
  FROM @Yeni Y
 ORDER BY Y.SIRA;

PRINT N'Eklenen fatura ek alani: ' + CAST(@@ROWCOUNT AS nvarchar(10));

-- 4) cari bazli alan secimi
IF OBJECT_ID('dbo.REHBER_FATEKALAN','U') IS NULL
  CREATE TABLE dbo.REHBER_FATEKALAN(
    REHBERID int NOT NULL,
    ALANADI varchar(20) NOT NULL,
    SIRA int NOT NULL CONSTRAINT DF_REHBER_FATEKALAN_SIRA DEFAULT(0),
    EKLEYEN int NULL,
    EKLEMETARIHI datetime NULL CONSTRAINT DF_REHBER_FATEKALAN_EKLEMETARIHI DEFAULT(getdate()),
    CONSTRAINT PK_REHBER_FATEKALAN PRIMARY KEY CLUSTERED(REHBERID, ALANADI));

-- 3) SGK ilave fatura tipi: 178'in serbest metin tanimi -> GIB deger listesi
UPDATE dbo.ALANLAR
   SET TUR = 4,
       SQL = 'select V from (values(''SAGLIK_ECZ''),(''SAGLIK_HAS''),(''SAGLIK_OPT''),(''SAGLIK_MED''),(''ABONELIK''),(''MAL_HIZMET''),(''DIGER'')) T(V)'
 WHERE EKRANADI = @Ekran AND ALANADI = 'SGK_ILAVE_TIPI'
   AND TUR = 1 AND ISNULL(SQL, '') = '';

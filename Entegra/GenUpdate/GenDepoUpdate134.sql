-- ============================================================
-- GenDepoUpdate134.sql
-- SILME ALTYAPISI - URETIM EMRI (140) ve URETIM RECETESI (138)
--
--   Eskiden bu iki silme app icinde elle yazilmis DELETE dizileriydi
--   (Utablo.UretimEmriSilmeIslemleri, UUretimRecete.ReceteSilBtnClick):
--   transaction YOK, operasyon altindaki cocuk tablolar (personel/olcum/
--   maliyet/fason/yorum) HIC silinmiyordu -> yetim satir kaliyordu.
--   Artik plan sunucuda; silme tek transaction, log Geri Al'a hazir.
--
-- ENGELLER
--   140: operasyonlardan URETIM FISI uretilmisse (FATBASLIK TUR=6 YERI=142)
--        silinmez. Detay/operasyon satiri VARLIGI engel DEGILDIR - wizard
--        "iptal -> yeni karti sil" yolu bu satirlarla birlikte siler.
--        (Liste ekranindaki daha siki UI kontrolu yerinde duruyor.)
--   138: recete fisi (FATBASLIK TUR=6 YERI=138), receteyi kullanan uretim
--        emri, ya da ANAURUN=0 detay satiri varsa silinmez (mevcut kural).
--
-- NOT: fn_Prog_Silme_Engel_Ek / fn_Prog_Silme_Detay_Ek TAM olarak yeniden
--   yazilir (133'teki 88/520 planlari korunur + 140/138 eklenir).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Eksik TABLOLAR kayitlari (UInfo'da ad gorunsun; Geri Al tablo cozumu icin)
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 146)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (146, 'URETIMOPERASYONPERSONEL', N'Detay', N'Üretim');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 522)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (522, 'URETIMOPERASYONMALIYET', N'Detay', N'Üretim');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 523)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (523, 'URETIMOPERASYONFASON', N'Detay', N'Üretim');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 524)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (524, 'URETIMOLCUM', N'Detay', N'Üretim');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 525)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (525, 'URETIMOLCUMDETAY', N'Detay', N'Üretim');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 526)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (526, 'URETIMOPERASONPERSONEL_USER', N'Detay', N'Üretim');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 155)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (155, 'URETIMRECETEOPR', N'Detay', N'Üretim');
GO

CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Engel_Ek()
RETURNS @T TABLE
(
    Modul  INT,
    Sira   INT,
    Tablo  sysname,
    Kosul  NVARCHAR(1000),
    Mesaj  NVARCHAR(200)
)
AS
BEGIN
    ------------------------------------------------------------------ STOK (88)
    INSERT @T VALUES
    (88, 10, 'STOKSAYIMKALEMLERI', N'SELECT 1 FROM STOKSAYIMKALEMLERI WHERE STOKID={ID}', N'Bu stok sayımda kullanılmış, silinemez.'),
    (88, 20, 'FATURA',             N'SELECT 1 FROM FATURA WHERE TUR=1 AND URUNID={ID}',   N'Bu stok faturada kullanılmış, silinemez.'),
    (88, 30, 'SIPARISDETAY',       N'SELECT 1 FROM SIPARISDETAY WHERE TUR=1 AND URUNID={ID}', N'Bu stok siparişte kullanılmış, silinemez.'),
    (88, 40, 'TEKLIFDETAY',        N'SELECT 1 FROM TEKLIFDETAY WHERE TUR=1 AND URUNID={ID}',  N'Bu stok teklifte kullanılmış, silinemez.'),
    (88, 50, 'STOKIZLEME',         N'SELECT 1 FROM STOKIZLEME WHERE STOKID={ID}',         N'Bu stokun lot/seri hareketi var, silinemez.'),
    (88, 60, 'URETIMRECETE',       N'SELECT 1 FROM URETIMRECETE WHERE STOKID={ID}',       N'Bu stok üretim reçetesinde kullanılmış, silinemez.'),
    (88, 70, 'STOKDURUM',          N'SELECT 1 FROM STOKDURUM WHERE STOKID={ID} AND ISNULL(KALAN,0)<>0', N'Bu stokun depo bakiyesi var, silinemez.');

    ------------------------------------------------------------------ STOK SAYIMI (520)
    INSERT @T VALUES
    (520, 10, 'STOKSAYIMKALEMLERI', N'SELECT 1 FROM STOKSAYIMKALEMLERI WHERE SAYIMID={ID}', N'Bu sayımın kalemleri var, önce kalemleri silin.');

    ------------------------------------------------------------------ URETIM EMRI (140)
    --   Tek gercek engel: operasyondan URETIM FISI uretilmis olmasi.
    INSERT @T VALUES
    (140, 10, 'FATBASLIK', N'SELECT 1 FROM FATBASLIK WHERE TUR=6 AND YERI=142 AND YERID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})',
                           N'Bu üretim emrinden üretim fişi oluşturulmuş, silinemez.');

    ------------------------------------------------------------------ URETIM RECETESI (138)
    INSERT @T VALUES
    (138, 10, 'FATBASLIK',         N'SELECT 1 FROM FATBASLIK WHERE TUR=6 AND YERI=138 AND YERID={ID}', N'Bu reçeteden üretim fişi oluşturulmuş, silinemez.'),
    (138, 20, 'URETIMEMRI',        N'SELECT 1 FROM URETIMEMRI WHERE RECETEID={ID}',                    N'Bu reçete üretim emrinde kullanılmış, silinemez.'),
    (138, 30, 'URETIMRECETEDETAY', N'SELECT 1 FROM URETIMRECETEDETAY WHERE URETIMRECETEID={ID} AND ISNULL(ANAURUN,0)=0', N'Önce Reçete detayını silin!');

    RETURN;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Detay_Ek()
RETURNS @T TABLE
(
    Modul   INT,
    Sira    INT,
    Tablo   sysname,
    Kosul   NVARCHAR(1000),
    TabloId INT
)
AS
BEGIN
    ------------------------------------------------------------------ STOK (88)
    --   Utablo.StokSilmeIslemleri sirasi
    INSERT @T VALUES
    (88, 10, 'IMAJ',                 N'YERI BETWEEN 71 AND 72 AND YER_ID={ID}', 42),
    (88, 20, 'IMAJ',                 N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID}))', 42),
    (88, 30, 'DOKUMAN',              N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID})', 321),
    (88, 40, 'GOREVYORUM',           N'TUR=88 AND GOREVID={ID}', 210),
    (88, 50, 'STOKFIYAT',            N'STOKID={ID}', 346),
    (88, 60, 'ISORTAGI',             N'STOKID={ID}', 88),
    (88, 70, 'STOKESDEGER',          N'STOKID={ID}', 344),
    (88, 80, 'STOKBARKOD',           N'STOKID={ID}', 340),
    (88, 90, 'STOKBOYUTKOMBINASYON', N'STOKID={ID}', 342),
    (88,100, 'STOKSEVIYE',           N'STOKID={ID}', 88),
    (88,110, 'STOKMUHASEBE',         N'STOKID={ID}', 88),
    (88,120, 'STOKCEVRIM',           N'STOKID={ID}', 88),
    (88,130, 'EKIPMANLAR',           N'URUNID={ID}', 88),
    (88,140, 'PAKETDETAY',           N'PAKETID={ID}', 88),
    (88,150, 'PAKETDETAY',           N'URUNID={ID} AND STOK=1', 88),
    (88,160, 'REHBERBILGI',          N'YERI=88 AND YER_ID={ID}', 76),
    (88,170, 'STOKLAR_USER',         N'ID={ID}', 508),
    (88,900, 'STOKLAR',              N'ID={ID}', 88);

    ------------------------------------------------------------------ STOK SAYIMI (520)
    INSERT @T VALUES
    (520, 10, 'STOKIZLEME',   N'BELGETUR=99 AND BASLIKID={ID}', 367),
    (520, 20, 'STOKLOKASYON', N'DURUM=0 AND BELGETUR=99 AND BASLIKID={ID}', 520),
    (520, 30, 'FATURA',       N'FATBASID IN (SELECT ID FROM FATBASLIK WHERE TUR=7 AND ANAKAYITID={ID})', 132),
    (520, 40, 'FATBASLIK',    N'TUR=7 AND ANAKAYITID={ID}', 29),
    (520,900, 'STOKSAYIM',    N'ID={ID}', 520);

    ------------------------------------------------------------------ URETIM EMRI (140)
    --   Operasyon agacinin TAMAMI (personel/olcum/maliyet/fason/yorum-medya)
    --   emirle birlikte gider. Sira: torunlar -> cocuklar -> operasyon -> emir.
    INSERT @T VALUES
    (140, 10, 'IMAJ',                    N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})))', 42),
    (140, 20, 'DOKUMAN',                 N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 321),
    (140, 30, 'GOREVYORUM',              N'TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})', 210),
    (140, 40, 'URETIMOLCUMDETAY',        N'URETIMOLCUMID IN (SELECT ID FROM URETIMOLCUM WHERE OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})))', 525),
    (140, 50, 'URETIMOLCUM',             N'OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 524),
    -- Personelin ek-alan (_USER) satirlari: biri CASCADE, digeri (eski, adi hatali
    --   yazilmis tablo) NO ACTION -> elle silinmezse FK ihlali verir.
    (140, 52, 'URETIMOPERASONPERSONEL_USER', N'ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 526),
    (140, 55, 'URETIMOPERASYONPERSONEL_USER', N'ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 511),
    (140, 60, 'URETIMOPERASYONPERSONEL', N'OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})', 146),
    (140, 70, 'URETIMOPERASYONMALIYET',  N'URETIMEMRIID={ID}', 522),
    (140, 80, 'URETIMOPERASYONFASON',    N'URETIMEMRIID={ID}', 523),
    (140, 90, 'URETIMOPERASYON',         N'URETIMEMRIID={ID}', 142),
    (140,100, 'URETIMEMRIDETAY',         N'URETIMEMRIID={ID}', 141),
    (140,110, 'URETIMEMRI_USER',         N'ID={ID}', 510),
    (140,900, 'URETIMEMRI',              N'ID={ID}', 140);

    ------------------------------------------------------------------ URETIM RECETESI (138)
    INSERT @T VALUES
    (138, 10, 'URETIMRECETEOPR',   N'URETIMRECETEID={ID}', 155),
    (138, 20, 'URETIMRECETEDETAY', N'URETIMRECETEID={ID}', 139),
    (138,900, 'URETIMRECETE',      N'ID={ID}', 138);

    RETURN;
END
GO

-- ---- SARMALAYICILAR ------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_UretimEmri_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 140, @Kosullar; END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_UretimRecete_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 138, @Kosullar; END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT SELECT  ON dbo.fn_Prog_Silme_Engel_Ek       TO gentegre_api;
    GRANT SELECT  ON dbo.fn_Prog_Silme_Detay_Ek       TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_UretimEmri_Sil_Json   TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_UretimRecete_Sil_Json TO gentegre_api;
END
GO

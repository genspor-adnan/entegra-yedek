-- ============================================================
-- GenDepoUpdate127.sql
-- KART SILME ALTYAPISI (sunucu tarafi) - 1. ASAMA: MOTOR + METADATA
--
-- AMAC: sp_Api_Belge_Sil_Json'un yaptigini (on-kontrol -> loglama -> sirali
--   silme, TEK transaction) diger kart modullerine de getirmek. Delphi tarafinda
--   ayni is her modulde ELLE yaziliydi: kontroller/log/silme sirasi modulden
--   module kayiyordu, transaction yoktu (yarim silme riski).
--
-- YAKLASIM: 12 modul icin 12 uzun SP YAZILMAZ. Kural METADATA'ya alinir, tek
--   motor calistirir - donusum rota matrisi (fn_Prog_BelgeDonusum_Rota) ile ayni
--   felsefe. Yeni modul = iki TVF'ye satir eklemek.
--
--   fn_Prog_Silme_Engel(@Modul)  : "silinemez" kurallari
--       SIRA, TABLO, KOSUL ({ID} yer tutucusu), MESAJ
--       Kosul TRUE donerse silme REDDEDILIR (mesaj kullaniciya gider).
--   fn_Prog_Silme_Detay(@Modul)  : kartla birlikte gidecek COCUK satirlar
--       SIRA (silme sirasi; kucukten buyuge SILINIR), TABLO, KOSUL, TABLOID (log)
--       Kart satirinin KENDISI de plandadir (en son sira).
--
--   sp_Prog_Kayit_Silinebilir_Mi @Modul, @KayitId
--       -> SILINEBILIR(0/1), NEDEN, MESAJ
--   sp_Api_Kayit_Sil_Json  (jenerik motor)
--       {"Modul":71,"KayitId":123,"Oturum":{...}}
--       1) on-kontrol  2) ISLEMLOG (silmeden ONCE - Geri Al buna bagli)
--       3) plan sirasiyla DELETE   -- hepsi TEK transaction
--   sp_Api_<Modul>_Sil_Json : ince sarmalayicilar (Delphi/mobil ayni adi cagirir)
--
-- MODUL = ISLEMLOG TABLOID (PrjConst TabNo_*): 71 Cari, 73 IK, 83 Servis,
--   97 Teklif, 91 Siparis, 18 Demirbas, 321 Dokuman, 70 Proje, 33 Gorev,
--   170 Firsat, 69 POS, 46 KrediKarti
--
-- BU DOSYADA TAM TANIMLI: Cari(71), IK(73), Servis(83), Teklif(97)
--   Digerleri (Siparis/Demirbas/Dokuman/Proje/Gorev/Firsat/POS/KrediKarti)
--   sarmalayici olarak VAR ama plani henuz bos -> motor "plan tanimli degil"
--   diye THROW eder; YANLIS SILME YAPMAZ. Planlari 2. asamada eklenecek.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- 1) ENGEL KURALLARI
--    KOSUL: {ID} yer tutucusu calisirken kayit ID'si ile degistirilir.
--    Kosul EXISTS(...) icinde calistirilir -> satir donerse ENGEL.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Engel()
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
    ------------------------------------------------------------------
    -- CARI (71)  - Utablo.CariSil ile ayni kurallar
    ------------------------------------------------------------------
    INSERT @T VALUES
    (71, 10, 'KULLANICI',   N'SELECT 1 FROM KULLANICI K INNER JOIN ROLLER R ON R.ID=K.ROLID WHERE K.REHBERID={ID} AND ISNULL(R.TY,0)=1', N'Yönetici kullanıcı silinemez.'),
    (71, 20, 'KASA',        N'SELECT 1 FROM KASA WHERE REHBERID={ID}',            N'Bu cariye ait kasa/plan verisi var, silinemez.'),
    (71, 30, 'FATBASLIK',   N'SELECT 1 FROM FATBASLIK WHERE REHBERID={ID}',       N'Bu cariye ait fatura verisi var, silinemez.'),
    (71, 40, 'CEKLER',      N'SELECT 1 FROM CEKLER WHERE REHBERID={ID}',          N'Bu cariye ait çek verisi var, silinemez.'),
    (71, 50, 'SENETLER',    N'SELECT 1 FROM SENETLER WHERE REHBERID={ID}',        N'Bu cariye ait senet verisi var, silinemez.'),
    (71, 60, 'PERS_HAREKET',N'SELECT 1 FROM PERS_HAREKET WHERE REHBERID={ID}',    N'Bu karta ait personel bilgisi var, silinemez.'),
    (71, 70, 'BANKAHESAPLAR', N'SELECT 1 FROM BANKAHESAPLAR WHERE REHBERID={ID}', N'Bu cariye ait banka hesabı var, silinemez.'),
    (71, 80, 'PROJELER',    N'SELECT 1 FROM PROJELER WHERE REHBERID={ID}',        N'Bu cariye ait proje var, silinemez.'),
    (71, 90, 'AKTIVITELER', N'SELECT 1 FROM AKTIVITELER WHERE MUSTERIID={ID}',    N'Bu cariye ait aktivite var, silinemez.'),
    (71,100, 'TEKLIF',      N'SELECT 1 FROM TEKLIF WHERE REHBERID={ID}',          N'Bu cariye ait teklif var, silinemez.'),
    (71,110, 'SIPARIS',     N'SELECT 1 FROM SIPARIS WHERE REHBERID={ID}',         N'Bu cariye ait sipariş var, silinemez.'),
    (71,120, 'SERVIS',      N'SELECT 1 FROM SERVIS WHERE REHBERID={ID}',          N'Bu cariye ait servis kaydı var, silinemez.'),
    (71,130, 'SOZLESMELER', N'SELECT 1 FROM SOZLESMELER WHERE REHBERID={ID}',     N'Bu cariye ait sözleşme var, silinemez.'),
    (71,140, 'SATINALMA',   N'SELECT 1 FROM SATINALMA WHERE REHBERID={ID}',       N'Bu cariye ait satınalma kaydı var, silinemez.'),
    (71,150, 'URETIMEMRI',  N'SELECT 1 FROM URETIMEMRI WHERE REHBERID={ID}',      N'Bu cariye ait üretim emri var, silinemez.'),
    (71,160, 'ISEMRI',      N'SELECT 1 FROM ISEMRI WHERE REHBERID={ID}',          N'Bu cariye ait iş emri var, silinemez.'),
    -- Bagli kisi (GRUP=334) BELGEDE kullanildiysa engel; yalniz kart detayiysa degil.
    (71,170, 'REHBER',      N'SELECT 1 FROM REHBER K WHERE K.GRUP=334 AND K.BAGID={ID} AND ('
                            + N' EXISTS(SELECT 1 FROM SIPARIS s WHERE s.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIF t WHERE t.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM SERVIS v WHERE v.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM GOREVLER g WHERE g.MUS_ILGILI=K.ID OR g.MUS_ILGILI2=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM EKIPMANREHBER e WHERE e.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM DOKUMAN d WHERE d.ILGILIID=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIFFINANSAL f WHERE f.ILGILIID=K.ID))',
                            N'Bu karta bağlı ilgili kişi belgelerde kullanılmış, silinemez.');

    ------------------------------------------------------------------
    -- IK / PERSONEL (73) - UIKListeDlg.SilTusClick ile ayni kurallar
    ------------------------------------------------------------------
    INSERT @T VALUES
    (73, 10, 'KULLANICI',   N'SELECT 1 FROM KULLANICI K INNER JOIN ROLLER R ON R.ID=K.ROLID WHERE K.REHBERID={ID} AND ISNULL(R.TY,0)=1', N'Yönetici kullanıcı silinemez.'),
    (73, 20, 'KASA',        N'SELECT 1 FROM KASA WHERE REHBERID={ID}',            N'Bu personele ait kasa hareketi var, silinemez.'),
    (73, 30, 'FATBASLIK',   N'SELECT 1 FROM FATBASLIK WHERE REHBERID={ID}',       N'Bu personele ait belge var, silinemez.'),
    -- PERS_HAREKET TUR=1 (ise giris) kartin kendi kaydi -> engel DEGIL, kartla gider.
    (73, 40, 'PERS_HAREKET',N'SELECT 1 FROM PERS_HAREKET WHERE REHBERID={ID} AND ISNULL(TUR,0)<>1', N'Bu personele ait hareket kaydı var, silinemez.'),
    (73, 50, 'BANKAHESAPLAR', N'SELECT 1 FROM BANKAHESAPLAR WHERE REHBERID={ID}', N'Bu personele ait banka hesabı var, silinemez.'),
    (73, 60, 'SERVIS',      N'SELECT 1 FROM SERVIS WHERE REHBERID={ID}',          N'Bu personele ait servis kaydı var, silinemez.'),
    (73, 70, 'REHBER',      N'SELECT 1 FROM REHBER K WHERE K.GRUP=334 AND K.BAGID={ID} AND ('
                            + N' EXISTS(SELECT 1 FROM SIPARIS s WHERE s.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIF t WHERE t.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM SERVIS v WHERE v.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM GOREVLER g WHERE g.MUS_ILGILI=K.ID OR g.MUS_ILGILI2=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM EKIPMANREHBER e WHERE e.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM DOKUMAN d WHERE d.ILGILIID=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIFFINANSAL f WHERE f.ILGILIID=K.ID))',
                            N'Bu karta bağlı ilgili kişi belgelerde kullanılmış, silinemez.');

    ------------------------------------------------------------------
    -- SERVIS (83) : servisten belge uretilmisse (FATBASLIK.SERVISID) engel
    ------------------------------------------------------------------
    INSERT @T VALUES
    (83, 10, 'FATBASLIK',   N'SELECT 1 FROM FATBASLIK WHERE SERVISID={ID}',       N'Bu servisten belge oluşturulmuş, silinemez.');

    ------------------------------------------------------------------
    -- TEKLIF (97) : siparise donusmusse engel (zincir kopmasin)
    --   Rota matrisi: 412/413 teklif -> alis/satis siparisi (hedef SIPARISDETAY)
    ------------------------------------------------------------------
    INSERT @T VALUES
    (97, 10, 'SIPARISDETAY', N'SELECT 1 FROM SIPARISDETAY SD INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R'
                             + N'   ON R.DonusumTuru=SD.YERI AND R.KaynakDetayTablo=''TEKLIFDETAY'''
                             + N' WHERE SD.YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID={ID})',
                             N'Bu teklif siparişe dönüştürülmüş, silinemez.');

    RETURN;
END
GO

-- ============================================================
-- 2) SILME PLANI (cocuk satirlar + kart)
--    SIRA kucukten buyuge SILINIR (once en alt cocuk, en son kart).
--    TABLOID = ISLEMLOG'a yazilacak TABLOID (UInfo'da gorunum/Geri Al icin).
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Detay()
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
    ------------------------------------------------------------------
    -- CARI (71) - Utablo.CariSil sirasi
    ------------------------------------------------------------------
    INSERT @T VALUES
    (71, 10, 'REHBERBILGI',      N'YERI=1 AND YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID={ID})', 76),
    (71, 20, 'REHBERILETISIM',   N'REHBERID={ID}', 75),
    (71, 30, 'REHBERBILGIRESIM', N'REHBERBILGIID IN (SELECT ID FROM REHBERBILGI WHERE YERI IN (1,2,3) AND YER_ID={ID})', 516),
    (71, 40, 'REHBERBILGI',      N'YERI IN (2,3) AND YER_ID={ID}', 76),
    (71, 50, 'IMAJ',             N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID={ID}))', 42),
    (71, 60, 'DOKUMAN',          N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID={ID})', 321),
    (71, 70, 'GOREVYORUM',       N'TUR=71 AND GOREVID={ID}', 210),
    (71, 80, 'IMAJ',             N'YERI=71 AND YER_ID={ID}', 42),
    (71, 90, 'REHBERALIAS',      N'REHBERID={ID}', 513),
    (71,100, 'REHBERTEMSILCI',   N'REHBERID={ID}', 514),
    (71,110, 'REHBERPERSONEL',   N'REHBERID={ID}', 515),
    (71,120, 'KULLANICI',        N'REHBERID={ID}', 52),
    -- Bagli kisi (GRUP=334) ve detaylari
    (71,130, 'REHBERBILGI',      N'YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID}))', 76),
    (71,140, 'REHBERILETISIM',   N'REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID})', 75),
    (71,150, 'REHBER',           N'GRUP=334 AND BAGID={ID}', 71),
    -- Ek alan satiri (_USER) ve karta ait GENINI opsiyonlari (Utablo.CariSil sonu)
    (71,160, 'REHBER_USER',      N'ID={ID}', 504),
    (71,170, 'GENINI',           N'BOLUM IN (SELECT CAST(''-100'' + CAST(v.n AS varchar(2)) + CAST({ID} AS varchar(20)) AS bigint) FROM (VALUES(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69)) v(n))', 71),
    (71,900, 'REHBER',           N'ID={ID}', 71);

    ------------------------------------------------------------------
    -- IK (73) - UIKListeDlg sirasi (GOREVYORUM.TUR=73!)
    ------------------------------------------------------------------
    INSERT @T VALUES
    (73, 10, 'REHBERBILGI',      N'YERI=1 AND YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID={ID})', 76),
    (73, 20, 'REHBERILETISIM',   N'REHBERID={ID}', 75),
    (73, 30, 'REHBERBILGIRESIM', N'REHBERBILGIID IN (SELECT ID FROM REHBERBILGI WHERE YERI IN (1,2,3) AND YER_ID={ID})', 516),
    (73, 40, 'REHBERBILGI',      N'YERI=3 AND YER_ID={ID}', 86),
    (73, 50, 'REHBERBILGI',      N'YERI=2 AND YER_ID={ID}', 76),
    (73, 60, 'IMAJ',             N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID={ID}))', 42),
    (73, 70, 'DOKUMAN',          N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID={ID})', 321),
    (73, 80, 'GOREVYORUM',       N'TUR=73 AND GOREVID={ID}', 210),
    (73, 90, 'IMAJ',             N'YERI=71 AND YER_ID={ID}', 42),
    (73,100, 'PERS_HAREKET',     N'REHBERID={ID} AND TUR=1', 78),
    (73,110, 'KULLANICI',        N'REHBERID={ID}', 52),
    (73,120, 'REHBERALIAS',      N'REHBERID={ID}', 513),
    (73,130, 'REHBERTEMSILCI',   N'REHBERID={ID}', 514),
    (73,140, 'REHBERPERSONEL',   N'REHBERID={ID}', 515),
    (73,150, 'REHBERBILGI',      N'YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID}))', 76),
    (73,160, 'REHBERILETISIM',   N'REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID})', 75),
    (73,170, 'REHBER',           N'GRUP=334 AND BAGID={ID}', 71),
    (73,180, 'REHBER_USER',      N'ID={ID}', 504),
    (73,190, 'GENINI',           N'BOLUM IN (SELECT CAST(''-100'' + CAST(v.n AS varchar(2)) + CAST({ID} AS varchar(20)) AS bigint) FROM (VALUES(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69)) v(n))', 73),
    (73,900, 'REHBER',           N'ID={ID}', 73);

    ------------------------------------------------------------------
    -- SERVIS (83) - Utablo.ServisSil sirasi
    ------------------------------------------------------------------
    INSERT @T VALUES
    (83, 10, 'IMAJ',                N'YERI=83 AND YER_ID={ID}', 42),
    (83, 20, 'SERVISDETAY',         N'SERVISID={ID}', 183),
    (83, 30, 'SERVISBILGI',         N'SERVISID={ID}', 183),
    (83, 40, 'SERVISDETAYPERSONEL', N'SERVISID={ID}', 430),
    (83, 50, 'SERVISASAMA',         N'SERVISID={ID}', 183),
    (83, 60, 'GOREVKULLANICI',      N'TUR=12 AND LISTGOREVID={ID}', 183),
    (83, 70, 'SERVISHAREKET_USER',  N'ID IN (SELECT ID FROM SERVISHAREKET WHERE SERVISID={ID})', 183),
    (83, 80, 'SERVISHAREKET',       N'SERVISID={ID}', 183),
    (83, 90, 'IMAJ',                N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID={ID}))', 42),
    (83,100, 'DOKUMAN',             N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID={ID})', 321),
    (83,110, 'GOREVYORUM',          N'TUR=83 AND GOREVID={ID}', 210),
    (83,120, 'SERVIS_USER',         N'ID={ID}', 83),
    (83,900, 'SERVIS',              N'ID={ID}', 83);

    ------------------------------------------------------------------
    -- TEKLIF (97) - Utablo.TeklifSil + yorum/medya uc katmani
    ------------------------------------------------------------------
    INSERT @T VALUES
    (97, 10, 'IMAJ',        N'YERI=80 AND YER_ID={ID}', 42),
    (97, 20, 'IMAJ',        N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=97 AND GOREVID={ID}))', 42),
    (97, 30, 'DOKUMAN',     N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=97 AND GOREVID={ID})', 321),
    (97, 40, 'GOREVYORUM',  N'TUR=97 AND GOREVID={ID}', 210),
    (97, 50, 'TEKLIFDETAY', N'TEKLIFID={ID}', 98),
    (97, 60, 'TEKLIF_USER',  N'ID={ID}', 97),
    (97,900, 'TEKLIF',      N'ID={ID}', 97);

    RETURN;
END
GO

-- ============================================================
-- 3) ON-KONTROL
--    Doner: SILINEBILIR(0/1), NEDEN (engelleyen tablo), MESAJ
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Kayit_Silinebilir_Mi
    @Modul   INT,
    @KayitId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    IF @KayitId IS NULL OR @KayitId <= 0
        THROW 51001, N'KayitId zorunlu.', 1;

    DECLARE @Sira INT, @Tablo sysname, @Kosul NVARCHAR(1000), @Mesaj NVARCHAR(200);
    DECLARE @Var BIT, @SQL NVARCHAR(MAX);
    DECLARE @Neden sysname = NULL, @NedenMesaj NVARCHAR(200) = NULL;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul, Mesaj
        FROM dbo.fn_Prog_Silme_Engel()
        WHERE Modul = @Modul
        ORDER BY Sira;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @Mesaj;
    WHILE @@FETCH_STATUS = 0 AND @Neden IS NULL
    BEGIN
        -- Tablo yoksa (surum farki) kurali ATLA - silme akisi kirilmasin.
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @Var = 0;
            SET @SQL = N'SELECT @v = 1 WHERE EXISTS (' +
                       REPLACE(@Kosul, N'{ID}', CAST(@KayitId AS NVARCHAR(20))) + N')';
            EXEC sp_executesql @SQL, N'@v BIT OUTPUT', @v = @Var OUTPUT;
            IF ISNULL(@Var, 0) = 1
            BEGIN
                SET @Neden = @Tablo;
                SET @NedenMesaj = @Mesaj;
            END
        END
        FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @Mesaj;
    END
    CLOSE cur; DEALLOCATE cur;

    SELECT SILINEBILIR = CASE WHEN @Neden IS NULL THEN 1 ELSE 0 END,
           NEDEN       = @Neden,
           MESAJ       = ISNULL(@NedenMesaj, N'');
END
GO

-- ============================================================
-- 4) JENERIK SILME MOTORU
--   GIRDI : {"Modul":71,"KayitId":123,"Oturum":{"KulId":5,"SubeId":-1,"Ip":"","Istasyon":""}}
--   CIKTI : {"Sonuc":1,"Modul":..,"KayitId":..,"SilinenSatir":n,"Loglanan":n}
--   HATA  : 51001 KayitId eksik, 51002 kayit yok, 51003 plan tanimsiz,
--           51200 silinemez (mesaj on-kontrolden)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Kayit_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Modul   INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.Modul')   AS INT);
    DECLARE @KayitId BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);
    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip      VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist     VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @Modul IS NULL OR @KayitId IS NULL OR @KayitId <= 0
        THROW 51001, N'Modul ve KayitId zorunlu.', 1;

    -- Plan var mi? (yeni modul eklenmeden motor calismasin)
    DECLARE @KartTablo sysname =
        (SELECT TOP 1 Tablo FROM dbo.fn_Prog_Silme_Detay() WHERE Modul = @Modul AND Sira = 900);
    IF @KartTablo IS NULL
        THROW 51003, N'Bu modul icin silme plani tanimli degil.', 1;

    -- Kayit var mi?
    DECLARE @SQL NVARCHAR(MAX), @Var BIT = 0;
    SET @SQL = N'SELECT @v=1 WHERE EXISTS (SELECT 1 FROM ' + QUOTENAME(@KartTablo) + N' WHERE ID=@id)';
    EXEC sp_executesql @SQL, N'@id BIGINT, @v BIT OUTPUT', @id = @KayitId, @v = @Var OUTPUT;
    IF ISNULL(@Var, 0) = 0
        THROW 51002, N'Kayit bulunamadi.', 1;

    -- ---- 1) On-kontrol ----
    DECLARE @K TABLE (SILINEBILIR INT, NEDEN sysname NULL, MESAJ NVARCHAR(200));
    INSERT @K EXEC dbo.sp_Prog_Kayit_Silinebilir_Mi @Modul = @Modul, @KayitId = @KayitId;

    DECLARE @Mesaj NVARCHAR(200) = (SELECT TOP 1 MESAJ FROM @K WHERE ISNULL(SILINEBILIR,1) = 0);
    IF @Mesaj IS NOT NULL
        THROW 51200, @Mesaj, 1;

    DECLARE @Loglanan INT = 0, @Silinen INT = 0, @n INT;

    BEGIN TRAN;

    -- ---- 2) LOGLAMA (SILMEDEN ONCE - Geri Al buna bagli) ----
    --   Kart ONCE loglanir (UInfo'da kart satiri ustte), sonra cocuklar.
    EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = @KartTablo, @Kosul = N'ID=@pB', @KosulPar = @KayitId,
         @TabNo = @Modul, @UstTabNo = @Modul, @UstId = @KayitId,
         @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
         @IslemTipi = 0, @Yazilan = @n OUTPUT;
    SET @Loglanan = @Loglanan + ISNULL(@n, 0);

    DECLARE @Sira INT, @Tablo sysname, @Kosul NVARCHAR(1000), @TabloId INT;
    DECLARE @KosulP NVARCHAR(1000);   -- EXEC parametresi IFADE alamaz -> onceden hesapla
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul, TabloId
        FROM dbo.fn_Prog_Silme_Detay()
        WHERE Modul = @Modul AND Sira < 900
        ORDER BY Sira;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @TabloId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @n = 0;
            SET @KosulP = REPLACE(@Kosul, N'{ID}', N'@pB');   -- ID parametreyle baglanir
            EXEC dbo.sp_Api_Log_Yaz_Ic
                 @Tablo = @Tablo,
                 @Kosul = @KosulP,
                 @KosulPar = @KayitId,
                 @TabNo = @TabloId, @UstTabNo = @Modul, @UstId = @KayitId,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan = @Loglanan + ISNULL(@n, 0);
        END
        FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @TabloId;
    END
    CLOSE cur; DEALLOCATE cur;

    -- ---- 3) SILME (plan sirasi: once cocuk, en son kart) ----
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul
        FROM dbo.fn_Prog_Silme_Detay()
        WHERE Modul = @Modul
        ORDER BY Sira;
    OPEN cur2;
    FETCH NEXT FROM cur2 INTO @Sira, @Tablo, @Kosul;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @SQL = N'DELETE FROM ' + QUOTENAME(@Tablo) + N' WHERE ' +
                       REPLACE(@Kosul, N'{ID}', N'@pB');
            EXEC sp_executesql @SQL, N'@pB BIGINT', @pB = @KayitId;
            SET @Silinen = @Silinen + @@ROWCOUNT;
        END
        FETCH NEXT FROM cur2 INTO @Sira, @Tablo, @Kosul;
    END
    CLOSE cur2; DEALLOCATE cur2;

    COMMIT;

    SELECT Sonuc = 1, Modul = @Modul, KayitId = @KayitId,
           SilinenSatir = @Silinen, Loglanan = @Loglanan
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ============================================================
-- 5) MODUL SARMALAYICILARI
--    Hepsi ayni motoru cagirir; JSON'a Modul degerini ekler.
--    GIRDI: {"KayitId":123,"Oturum":{...}}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Modul_Sil_Ic
    @Modul INT, @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @J NVARCHAR(MAX) =
        JSON_MODIFY(ISNULL(@Kosullar, N'{}'), '$.Modul', @Modul);
    EXEC dbo.sp_Api_Kayit_Sil_Json @Kosullar = @J;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Cari_Sil_Json      @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  71, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_IK_Sil_Json        @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  73, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Servis_Sil_Json    @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  83, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Teklif_Sil_Json    @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  97, @Kosullar; END
GO
-- Asagidakilerin PLANI HENUZ YOK (2. asama): motor 51003 ile reddeder, yanlis silmez.
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Siparis_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  91, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Demirbas_Sil_Json  @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  18, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Dokuman_Sil_Json   @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 321, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Proje_Sil_Json     @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  70, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Gorev_Sil_Json     @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  33, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Firsat_Sil_Json    @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 170, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_POS_Sil_Json       @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  69, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_KrediKarti_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  46, @Kosullar; END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_Kayit_Silinebilir_Mi   TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Kayit_Sil_Json          TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Modul_Sil_Ic            TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Cari_Sil_Json           TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_IK_Sil_Json             TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Servis_Sil_Json         TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Teklif_Sil_Json         TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Belge_Siparis_Sil_Json  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Demirbas_Sil_Json       TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Dokuman_Sil_Json        TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Proje_Sil_Json          TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Gorev_Sil_Json          TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Firsat_Sil_Json         TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_POS_Sil_Json            TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_KrediKarti_Sil_Json     TO gentegre_api;
END
GO

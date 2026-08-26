-- ======================================================================
-- KONSOLIDE UPDATE 00 - ROL + SEMA + VERI (once bunu calistir)
-- ======================================================================
-- Kaynak: GenDepoUpdate66..169 (Agustos 7+). Tek seferlik yapisal degisiklikler.
-- Musteri ANA veritabaninda calistirin.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- gentegre_api rolu (yoksa) -- GRANT'ler buna baglidir
IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO


-- ---- [DDL] kaynak: GenDepoUpdate66 ----
-- ============================================================
--   GenDepoUpdate66 — Belge listelerinde "SON ARANAN" modu
--   MUSTERI ANA veritabaninda calistirilir.
--
--   NE ISE YARAR:
--     Kullanici bir belgeyi ACTIGINDA ya da KAYDETTIGINDE (yeni kestiginde)
--     KULLANICI_ARAMA'ya yazilir (uygulama tarafi: Tablo.BelgeAramaKaydet).
--     Gorev panelindeki liste butonuna basildiginda liste bu kayitlarla sinirlanir
--     ve en son dokunulan belge en ustte gelir.
--     Ornek akis: cari ekranindayken fatura kes -> Faturalar listesine gec ->
--     "Faturalar" butonuna bas -> az once kestigin belge listede.
--
--   BELGE TURU BAZLI AYRI LISTE:
--     KULLANICI_ARAMA.MODUL = belge turunun MODUL.MODULID'si (MODUL.KASATUR eslesmesi).
--     Boylece alis faturasi (TUR 11 -> 240131) ile satis faturasi (TUR 15 -> 241131),
--     giris fisi (3 -> 2712) ile cikis fisi (4 -> 2713) KARISMAZ.
--
--   BU BETIK: iki liste SP'sine @Kosullar JSON'i uzerinden 3 yeni filtre ekler:
--     "SonAranan": 1     -> liste KULLANICI_ARAMA ile sinirlanir
--     "Modul": <MODULID> -> hangi belge turunun listesi
--     "Kul": <KULID>     -> hangi kullanici
--   Modul/Kul eksikse SonAranan otomatik 0'a duser (normal liste) - geriye donuk uyumlu.
--
--   NOT: SP govdeleri ayri dosyalardadir; bu betik onlari YENIDEN KURMAZ, yalnizca
--        hangi dosyalarin dagitilmasi gerektigini belgeler. Dagitim sirasi:
--          1) GenUpdate\sp_Prog_AlisSatis_IrsFatFisKons_Json2.sql
--          2) GenUpdate\sp_Prog_AlisSatis_Siparis_Json2.sql
--        (musteri_guncelleme.ps1 ikisini de calistirir.)
--
--   Uygulama tarafi da yenilenmelidir (Gentegre.exe): kayit kancalari ve
--   gorev paneli butonu yeni surumde.
-- ============================================================
SET NOCOUNT ON;

/* ---- 0) DOGRU VERITABANI MI? ---------------------------------------------
   Bu betik MUSTERI ANA veritabaninda calisir (depo/GENDEPO'da DEGIL).
   Ana DB'nin ayirt edici tablosu: FATBASLIK. Yoksa hicbir sey yapmadan cikar;
   aksi halde depo DB'sinde bos KULLANICI_ARAMA olusturup kafa karistirir. */
IF OBJECT_ID('dbo.FATBASLIK', 'U') IS NULL
BEGIN
    PRINT '*** ATLANDI: burasi Gentegre ANA veritabani degil (FATBASLIK yok).';
    PRINT '    Betigi musterinin ANA veritabaninda calistirin (depo/GENDEPO''da degil).';
    RETURN;
END

/* ---- On kosul: KULLANICI_ARAMA + benzersiz index ---------------------------
   Tablo eski kurulumlarda olmayabilir; Son/Sik Aranan bu tabloya yazar.
   UX index'i AramaKaydet'in upsert deseni icin gereklidir (mukerrer satir olmasin). */
IF OBJECT_ID('dbo.KULLANICI_ARAMA', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.KULLANICI_ARAMA
    (
        ID               int IDENTITY(1,1) NOT NULL CONSTRAINT PK_KULLANICI_ARAMA PRIMARY KEY,
        KULID            int NOT NULL,
        MODUL            int NOT NULL,
        KAYITID          int NOT NULL,
        SAY              int NOT NULL CONSTRAINT DF_KULLANICI_ARAMA_SAY DEFAULT(1),
        DEGISTIRMETARIHI smalldatetime NULL
    );
    PRINT 'KULLANICI_ARAMA olusturuldu.';
END
ELSE
    PRINT 'KULLANICI_ARAMA zaten var.';

IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE name = 'UX_KULLANICI_ARAMA' AND object_id = OBJECT_ID('dbo.KULLANICI_ARAMA'))
BEGIN
    -- Ayni kullanici + modul + kayit icin TEK satir (upsert bunun uzerine calisir).
    ;WITH d AS (SELECT ID, RN = ROW_NUMBER() OVER (PARTITION BY KULID, MODUL, KAYITID ORDER BY ID DESC)
                FROM dbo.KULLANICI_ARAMA)
    DELETE FROM d WHERE RN > 1;   -- varsa mukerrerleri temizle (index kurulabilsin)

    CREATE UNIQUE INDEX UX_KULLANICI_ARAMA
        ON dbo.KULLANICI_ARAMA (KULID, MODUL, KAYITID);
    PRINT 'UX_KULLANICI_ARAMA olusturuldu.';
END
ELSE
    PRINT 'UX_KULLANICI_ARAMA zaten var.';

/* ---- Son Aranan sorgusu icin yardimci index -------------------------------
   Liste SP'si: WHERE KAYITID = F.ID AND MODUL = @Modul AND KULID = @Kul
                ORDER BY MAX(DEGISTIRMETARIHI) DESC */
IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE name = 'IX_KULLANICI_ARAMA_SONARANAN' AND object_id = OBJECT_ID('dbo.KULLANICI_ARAMA'))
BEGIN
    CREATE INDEX IX_KULLANICI_ARAMA_SONARANAN
        ON dbo.KULLANICI_ARAMA (KULID, MODUL, DEGISTIRMETARIHI DESC) INCLUDE (KAYITID);
    PRINT 'IX_KULLANICI_ARAMA_SONARANAN olusturuldu.';
END
ELSE
    PRINT 'IX_KULLANICI_ARAMA_SONARANAN zaten var.';

/* ---- Durum ---------------------------------------------------------------- */
-- MODUL tablosu bilgi amaclidir; her kurulumda bulunmayabilir -> ERISILEMEZSE ATLA.
--   (Uygulama TUR -> MODULID haritasini KODDA tutar, bu tabloya BAGIMLI DEGILDIR.)
IF OBJECT_ID('dbo.MODUL', 'U') IS NOT NULL
    SELECT VERITABANI = DB_NAME(),
           KAYIT      = (SELECT COUNT(*) FROM dbo.KULLANICI_ARAMA),
           BELGE_TURU_MODUL_ESLESMESI = (SELECT COUNT(*) FROM dbo.MODUL WHERE KASATUR IS NOT NULL);
ELSE
    SELECT VERITABANI = DB_NAME(),
           KAYIT      = (SELECT COUNT(*) FROM dbo.KULLANICI_ARAMA),
           BELGE_TURU_MODUL_ESLESMESI = N'MODUL tablosu yok (sorun degil - harita kodda)';
GO

-- ---- [DDL] kaynak: GenDepoUpdate87 ----
-- ============================================================
-- URETIMEMRI: Trg_UretimEmri_LOTNO_SKT_Guncelle -- CANLI BOZUKLUK, TASINDI
--
-- BULGU: bu trigger I.URT / I.SKT kolonlarina bakiyor ama URETIMEMRI tablosunda
--   BU KOLONLAR YOK; URT ve SKT URETIMEMRI_USER tablosuna tasinmis. Sonuc:
--   URETIMEMRI'ye yapilan HER INSERT/UPDATE "Invalid column name 'SKT'" ile
--   basarisiz oluyordu (dogrulandi; tablodaki son kayit 05.07.2026).
--   Yani uretim emri olusturma tamamen kirikti - donusum planindan bagimsiz,
--   canli bir hata.
--
-- COZUM: kural verinin bulundugu tabloya tasindi. Eski trigger DUSURULUR,
--   ayni kural URETIMEMRI_USER uzerinde set-bazli olarak kurulur.
--   Dogru tetikleme zamani da budur: URT zaten URETIMEMRI_USER'a yazilir,
--   URETIMEMRI'ye degil - eski yerinde URT hic dolmamis olurdu.
--
-- KURAL (eskisiyle ayni): URT doluysa ve stok kategorisi 7 ise SKT = URT + 5 yil,
--   degilse SKT = NULL.
-- ============================================================
DROP TRIGGER IF EXISTS [dbo].[Trg_UretimEmri_LOTNO_SKT_Guncelle];
GO

-- ---- [DDL] kaynak: GenDepoUpdate89 ----
-- ============================================================
-- 1) BELGEDONUSUMISLEM
--    ANA veritabaninda (GENDEPO'da DEGIL - synonym bagimliligi log ekraninda
--    sorun cikarmisti). ISTEKID benzersiz: ayni istek iki kez gelirse ikinci
--    kez belge uretilmez.
--
--    ROLLBACK NOTU: SQL Server'da autonomous transaction yok. 'BASLADI' satiri
--    ana transaction'dan ONCE (kendi kucuk transaction'inda) yazilir; sonuc
--    ya da hata COMMIT/ROLLBACK'ten SONRA guncellenir. Boylece islem izi her
--    kosulda kalir.
-- ============================================================
IF OBJECT_ID('dbo.BELGEDONUSUMISLEM', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BELGEDONUSUMISLEM (
        ID              INT IDENTITY(1,1) NOT NULL,
        ISTEKID         UNIQUEIDENTIFIER  NOT NULL,
        DONUSUMTURU     INT               NOT NULL,
        KULLANICIID     INT               NOT NULL,
        SUBEID          INT               NOT NULL,
        DURUM           NVARCHAR(12)      NOT NULL,   -- BASLADI | TAMAMLANDI | HATA
        HEDEFBASLIKID   INT               NULL,
        HEDEFTUR        INT               NULL,
        BASLAMATARIHI   DATETIME          NOT NULL CONSTRAINT DF_BELGEDONUSUMISLEM_BAS DEFAULT (GETDATE()),
        BITISTARIHI     DATETIME          NULL,
        SONUCJSON       NVARCHAR(MAX)     NULL,
        HATAKODU        INT               NULL,
        CONSTRAINT PK_BELGEDONUSUMISLEM PRIMARY KEY CLUSTERED (ID)
    );
    CREATE UNIQUE INDEX UX_BELGEDONUSUMISLEM_ISTEKID
        ON dbo.BELGEDONUSUMISLEM (ISTEKID);
    -- Terk edilmis 'BASLADI' kayitlarini bulmak icin
    CREATE INDEX IX_BELGEDONUSUMISLEM_DURUM
        ON dbo.BELGEDONUSUMISLEM (DURUM, BASLAMATARIHI) INCLUDE (ISTEKID);
END
GO

-- ---- [DDL] kaynak: GenDepoUpdate95 ----
-- ============================================================
-- Onarim kayit tablosu - ANA veritabaninda
-- ============================================================
IF OBJECT_ID('dbo.IZLEMEBAKIYEONARIM', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.IZLEMEBAKIYEONARIM (
        ID           INT IDENTITY(1,1) NOT NULL,
        PARTIID      INT               NOT NULL,   -- ayni calistirmanin satirlari
        TARIH        DATETIME          NOT NULL CONSTRAINT DF_IZLEMEBAKIYEONARIM_TRH DEFAULT (GETDATE()),
        KULLANICIID  INT               NULL,
        STOKID       INT               NOT NULL,
        DEPOID       INT               NOT NULL,
        SERILOTID    INT               NOT NULL,
        ESKIKALAN    FLOAT             NULL,       -- NULL = satir yoktu, eklendi
        YENIKALAN    FLOAT             NOT NULL,
        FARK         FLOAT             NOT NULL,
        GERIALINDI   BIT               NOT NULL CONSTRAINT DF_IZLEMEBAKIYEONARIM_GA DEFAULT (0),
        CONSTRAINT PK_IZLEMEBAKIYEONARIM PRIMARY KEY CLUSTERED (ID)
    );
    CREATE INDEX IX_IZLEMEBAKIYEONARIM_PARTI ON dbo.IZLEMEBAKIYEONARIM (PARTIID);
END
GO

-- ---- [DDL] kaynak: GenDepoUpdate122 ----
IF OBJECT_ID(N'dbo.sp_Prog_Servis_Liste', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Prog_Servis_Liste;
GO

-- ---- [DDL] kaynak: GenDepoUpdate125 ----
-- ============================================================
-- GenDepoUpdate125.sql
-- SNAPSHOT (geri-alinabilir oturum) tablosuna iki kolon:
--   SILSIRA smallint  : SILME sirasi. Bos ise SIRA kullanilir.
--   TAMSIL  bit       : 1 = geri yuklemede filtredeki TUM satirlar silinip
--                       snapshot'takiler yeniden EKLENIR (satir-eslemeli
--                       UPDATE yapilmaz).
--
-- NEDEN (izleme ornegi, 10.08.2026):
--   Stok izlemede iade/geri-yukleme TETIKLE yapiliyor:
--     TG_StokIzlemeDurumSil  -> STOKIZLEME'den SILINCE calisir ve stogu
--                               STOKIZLEMEDEPO satirlarindan okuyup iade eder.
--     STOKIZLEMEDEPO'nun DELETE tetigi YOK (yalniz INSERT/UPDATE var).
--   Yani depo satirlari, izlem satirindan ONCE silinirse stok iadesi KAYBOLUR.
--   Snapshot motoru ise silmeyi SIRA DESC (cocuk once) yapiyordu -> iptalden
--   sonra STOKDURUMIZLEME eksik kaliyordu (lot 43653: 17 -> 7).
--   Cozum: bu cift icin SILME sirasi ile GERI-EKLEME sirasi AYRI olmali:
--     STOKIZLEME     : Sira=3, SilSira=4  (once silinir, sonra eklenir)
--     STOKIZLEMEDEPO : Sira=4, SilSira=3  (sonra silinir, en son eklenir)
--   Ayrica ikisi de TAMSIL=1: satirlar UPDATE ile degil, sil+ekle ile geri
--   gelir; boylece tetikler dogru sirayla calisip stok tam iade edilir.
--
-- Kolonlar OPSIYONEL: eski oturumlarda NULL kalir, motor eski davranisi surdurur.
-- ============================================================
SET NOCOUNT ON;

-- Depo adi calisirken cozulur (GenDepoUpdate2 ile ayni kural: GENINI BOLUM=-24120).
DECLARE @depo sysname = NULLIF((SELECT ANAHTAR FROM dbo.GENINI WHERE BOLUM = -24120 AND DIL = 0), '');
IF @depo IS NULL OR @depo = '' SET @depo = 'GENDEPO';
DECLARE @sql nvarchar(max);

IF DB_ID(@depo) IS NULL
BEGIN
    PRINT 'Depo veritabani yok: ' + @depo;
    RETURN;
END;

IF OBJECT_ID(QUOTENAME(@depo) + '.dbo.SNAPSHOT') IS NULL
BEGIN
    PRINT 'SNAPSHOT tablosu yok (GenDepoUpdate2 uygulanmamis).';
    RETURN;
END;

SET @sql = N'USE ' + QUOTENAME(@depo) + N';
IF COL_LENGTH(''dbo.SNAPSHOT'', ''SILSIRA'') IS NULL
    ALTER TABLE dbo.SNAPSHOT ADD SILSIRA smallint NULL;
IF COL_LENGTH(''dbo.SNAPSHOT'', ''TAMSIL'') IS NULL
    ALTER TABLE dbo.SNAPSHOT ADD TAMSIL bit NULL;';
EXEC(@sql);

PRINT 'SNAPSHOT.SILSIRA / SNAPSHOT.TAMSIL hazir.';
GO

-- ---- [DATA] kaynak: GenDepoUpdate130 ----
-- ---- 1) SECENEK LISTELERI ----------------------------------------------
--   DIL alanina dokunulmaz; mevcut satirlar guncellenir, eksik olan eklenir.
DECLARE @Listeler TABLE (BOLUM INT);
INSERT @Listeler VALUES (-24020), (-24021), (-2405);   -- alis sip. / satis sip. / belge

-- 0 = Taslak (siparis listelerinde "Yapilmadi" yaziyordu)
UPDATE G SET ANAHTAR = N'Taslak'
FROM GENINI G INNER JOIN @Listeler L ON L.BOLUM = G.BOLUM
WHERE G.DEGER = 0 AND G.ANAHTAR <> N'Taslak';

-- 2 = Onay (yoksa ekle; her dil satiri icin)
INSERT INTO GENINI (BOLUM, DIL, DEGER, ANAHTAR)
SELECT DISTINCT G.BOLUM, G.DIL, 2, N'Onay'
FROM GENINI G INNER JOIN @Listeler L ON L.BOLUM = G.BOLUM
WHERE NOT EXISTS (SELECT 1 FROM GENINI G2
                  WHERE G2.BOLUM = G.BOLUM AND G2.DIL = G.DIL AND G2.DEGER = 2);
GO

-- ---- [DATA] kaynak: GenDepoUpdate133 ----
-- STOKSAYIM icin TABLOLAR kaydi (UInfo'da "Stok Sayimi" olarak gorunsun)
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 520)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    VALUES (520, 'STOKSAYIM', N'Kart', N'Stok Sayımı');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 521)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    VALUES (521, 'STOKSAYIMKALEMLERI', N'Detay', N'Stok Sayımı');
GO

-- ---- [DATA] kaynak: GenDepoUpdate134 ----
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

-- ---- [DDL] kaynak: GenDepoUpdate135 ----
-- ---- SAYAC TABLOSU -------------------------------------------------------
IF OBJECT_ID('dbo.SAYAC') IS NULL
BEGIN
    CREATE TABLE dbo.SAYAC
    (
        ANAHTAR     NVARCHAR(200) NOT NULL,   -- 'FATBASLIK.FATURANO|T14|S-1|K1401'
        TABLOADI    sysname       NULL,
        ALANADI     sysname       NULL,
        KAPSAM      NVARCHAR(80)  NULL,       -- tur/sube/kocan/yil ayrimi
        SONNO       BIGINT        NOT NULL CONSTRAINT DF_SAYAC_SONNO DEFAULT (0),
        GUNCELLEME  DATETIME      NULL,
        CONSTRAINT PK_SAYAC PRIMARY KEY CLUSTERED (ANAHTAR)
    );
END
GO

-- ---- [DATA] kaynak: GenDepoUpdate135 ----
-- GENINI opsiyon satiri (yoksa ekle) - varsayilan KAPALI.
--   Bool opsiyon deseni: ANAHTAR NULL, DEGER 0/1, DIL 0 (bkz -24119 UBL_ZIP).
--   -24130 DOLU (e-Fatura seri kurallari) -> serbest slot -24121 kullanildi.
IF NOT EXISTS (SELECT 1 FROM dbo.GENINI WHERE BOLUM = -24121)
    INSERT INTO dbo.GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA)
    VALUES (-24121, NULL, 0, 0, NULL);
GO

-- ---- [DDL] kaynak: GenDepoUpdate145 ----
-- ---- KANAL (sohbet) ------------------------------------------------------
IF OBJECT_ID('dbo.MESAJKANAL') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJKANAL
    (
        ID              INT IDENTITY(1,1) NOT NULL,
        TUR             TINYINT       NOT NULL CONSTRAINT DF_MESAJKANAL_TUR DEFAULT (1),  -- 1 birebir, 2 grup
        ADI             NVARCHAR(100) NULL,          -- grup adi (birebirde NULL)
        OLUSTURAN       INT           NOT NULL,      -- REHBER.ID
        OLUSTURMATARIHI DATETIME      NOT NULL CONSTRAINT DF_MESAJKANAL_TRH DEFAULT (GETDATE()),
        DURUM           TINYINT       NOT NULL CONSTRAINT DF_MESAJKANAL_DRM DEFAULT (1),  -- 1 aktif, 0 kapali
        SONMESAJID      BIGINT        NULL,          -- denormalize: liste ekrani hizli sıralasin
        SONMESAJTARIH   DATETIME      NULL,
        SUBEID          SMALLINT      NULL,
        CONSTRAINT PK_MESAJKANAL PRIMARY KEY CLUSTERED (ID)
    );
    CREATE INDEX IX_MESAJKANAL_SON ON dbo.MESAJKANAL (SONMESAJTARIH DESC) INCLUDE (TUR, ADI, DURUM);
END
GO

-- ---- [DDL] kaynak: GenDepoUpdate145 ----
-- ---- KANAL UYELERI (+ okundu imleci) -------------------------------------
IF OBJECT_ID('dbo.MESAJKANALUYE') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJKANALUYE
    (
        ID            INT IDENTITY(1,1) NOT NULL,
        KANALID       INT      NOT NULL,
        REHBERID      INT      NOT NULL,     -- kullanici
        ROL           TINYINT  NOT NULL CONSTRAINT DF_MESAJUYE_ROL DEFAULT (0),   -- 1 = grup yoneticisi
        KATILMATARIHI DATETIME NOT NULL CONSTRAINT DF_MESAJUYE_KTL DEFAULT (GETDATE()),
        AYRILMATARIHI DATETIME NULL,         -- NULL = halen uye
        SONOKUMAID    BIGINT   NOT NULL CONSTRAINT DF_MESAJUYE_OKU DEFAULT (0),   -- okundu imleci (MESAJ.ID)
        BILDIRIM      BIT      NOT NULL CONSTRAINT DF_MESAJUYE_BLD DEFAULT (1),   -- 0 = sessize alindi
        BASLANGICID   BIGINT   NOT NULL CONSTRAINT DF_MESAJUYE_BSL DEFAULT (0),   -- uyeden ONCEKI mesajlari gormesin
        CONSTRAINT PK_MESAJKANALUYE PRIMARY KEY CLUSTERED (ID),
        CONSTRAINT UQ_MESAJKANALUYE UNIQUE (KANALID, REHBERID),
        CONSTRAINT FK_MESAJKANALUYE_KANAL FOREIGN KEY (KANALID) REFERENCES dbo.MESAJKANAL (ID)
    );
    -- "benim sohbetlerim" sorgusunun cekirdegi
    CREATE INDEX IX_MESAJKANALUYE_KUL ON dbo.MESAJKANALUYE (REHBERID, AYRILMATARIHI)
        INCLUDE (KANALID, SONOKUMAID, BILDIRIM, BASLANGICID);
END
GO

-- ---- [DDL] kaynak: GenDepoUpdate145 ----
-- ---- MESAJLAR ------------------------------------------------------------
IF OBJECT_ID('dbo.MESAJ') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJ
    (
        ID          BIGINT IDENTITY(1,1) NOT NULL,
        KANALID     INT           NOT NULL,
        GONDERENID  INT           NOT NULL,   -- REHBER.ID
        TARIH       DATETIME2(0)  NOT NULL CONSTRAINT DF_MESAJ_TRH DEFAULT (SYSDATETIME()),
        METIN       NVARCHAR(MAX) NULL,
        YANITID     BIGINT        NULL,       -- alintilanan mesaj (MESAJ.ID)
        DOSYAID     INT           NULL,       -- GENDEPO.DOSYA referansi
        DOSYAADI    NVARCHAR(200) NULL,
        DOSYABOYUT  BIGINT        NULL,
        SILINDI     BIT           NOT NULL CONSTRAINT DF_MESAJ_SIL DEFAULT (0),
        SILEN       INT           NULL,
        SILMETARIHI DATETIME      NULL,
        CONSTRAINT PK_MESAJ PRIMARY KEY CLUSTERED (ID),
        CONSTRAINT FK_MESAJ_KANAL FOREIGN KEY (KANALID) REFERENCES dbo.MESAJKANAL (ID)
    );
    -- Gecmis okuma + "yeni var mi" yoklamasi: (KANALID, ID) tek indeks yeter.
    CREATE INDEX IX_MESAJ_KANAL ON dbo.MESAJ (KANALID, ID) INCLUDE (GONDERENID, TARIH, SILINDI);
END
GO

-- ---- [DATA] kaynak: GenDepoUpdate145 ----
-- ---- LOG/UInfo icin tablo adlari ----------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 530)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (530, 'MESAJKANAL', N'Kart', N'Mesajlaşma');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 531)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (531, 'MESAJKANALUYE', N'Detay', N'Mesajlaşma');
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 532)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (532, 'MESAJ', N'Detay', N'Mesajlaşma');
GO

-- ---- [DDL] kaynak: GenDepoUpdate154 ----
IF COL_LENGTH('dbo.MESAJKANAL', 'DOSYAID') IS NULL
    ALTER TABLE dbo.MESAJKANAL ADD DOSYAID INT NULL;
GO

-- ---- [DDL] kaynak: GenDepoUpdate160 ----
IF OBJECT_ID('dbo.MESAJGIZLI') IS NULL
BEGIN
    CREATE TABLE dbo.MESAJGIZLI
    (
        MESAJID  BIGINT   NOT NULL,
        REHBERID INT      NOT NULL,      -- mesaji KENDINDEN silen kullanici
        TARIH    DATETIME NOT NULL CONSTRAINT DF_MESAJGIZLI_TRH DEFAULT (GETDATE()),
        CONSTRAINT PK_MESAJGIZLI PRIMARY KEY CLUSTERED (MESAJID, REHBERID),
        CONSTRAINT FK_MESAJGIZLI_MESAJ FOREIGN KEY (MESAJID) REFERENCES dbo.MESAJ (ID)
    );
    -- "bu kullanicidan gizlenenler" sorgusu (gecmis suzmesi) icin
    CREATE INDEX IX_MESAJGIZLI_KUL ON dbo.MESAJGIZLI (REHBERID, MESAJID);
END
GO

-- ---- [DATA] kaynak: GenDepoUpdate160 ----
IF NOT EXISTS (SELECT 1 FROM dbo.TABLOLAR WHERE TABLOID = 533)
    INSERT INTO dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    VALUES (533, 'MESAJGIZLI', N'Detay', N'Mesajlaşma');
GO

-- ---- [DDL] kaynak: GenDepoUpdate162 ----
IF COL_LENGTH('dbo.MESAJKANALUYE', 'FAVORI') IS NULL
    ALTER TABLE dbo.MESAJKANALUYE
        ADD FAVORI BIT NOT NULL CONSTRAINT DF_MESAJKANALUYE_FAV DEFAULT (0);
GO

-- ---- [DDL] kaynak: GenDepoUpdate166 ----
-- Once bagimli FK'lar (varsa), sonra tablolar
IF OBJECT_ID('dbo.MESAJLOGKULLANICI') IS NOT NULL
BEGIN
    DECLARE @Sql NVARCHAR(MAX) = N'';
    SELECT @Sql = @Sql + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.'
                       + QUOTENAME(OBJECT_NAME(parent_object_id))
                       + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' + CHAR(13)
      FROM sys.foreign_keys
     WHERE referenced_object_id IN (OBJECT_ID('dbo.MESAJLOG'), OBJECT_ID('dbo.MESAJLOGKULLANICI'),
                                    OBJECT_ID('dbo.MESAJLAR'));
    IF LEN(@Sql) > 0 EXEC sp_executesql @Sql;
END
GO

-- ---- [DDL] kaynak: GenDepoUpdate166 ----
IF OBJECT_ID('dbo.MESAJLOGKULLANICI') IS NOT NULL DROP TABLE dbo.MESAJLOGKULLANICI;
IF OBJECT_ID('dbo.MESAJLOG')          IS NOT NULL DROP TABLE dbo.MESAJLOG;
IF OBJECT_ID('dbo.MESAJLAR')          IS NOT NULL DROP TABLE dbo.MESAJLAR;
GO

-- ---- [DATA] kaynak: GenDepoUpdate166 ----
-- TABLOLAR kaydi (UInfo/log adlandirmasi) varsa temizle
DELETE FROM dbo.TABLOLAR
 WHERE TABLOADI IN (N'MESAJLOG', N'MESAJLOGKULLANICI', N'MESAJLAR');
GO

-- ---- [DDL] kaynak: GenDepoUpdate169 ----
-- ============================================================
-- GenDepoUpdate169.sql
-- Kullanici bazli DevExpress skin tercihi
--
-- NULL / bos: mevcut uygulama gorunumu korunur.
-- Diger    : DevExpress SkinName (orn. Office2016Dark).
-- ============================================================
IF COL_LENGTH('dbo.KULLANICI', 'SKINADI') IS NULL
BEGIN
    ALTER TABLE dbo.KULLANICI ADD SKINADI NVARCHAR(50) NULL;
END
GO

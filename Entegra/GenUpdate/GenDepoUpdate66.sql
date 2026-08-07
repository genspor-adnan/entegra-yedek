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

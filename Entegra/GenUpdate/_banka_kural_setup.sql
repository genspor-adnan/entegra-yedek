-- =============================================================
-- BANKA HIZLI GİRİŞ — Banka-izole kural motoru altyapısı
-- =============================================================
-- Her bankanın kuralları (etiket→tür, açıklama→tür, isim çıkarma)
-- kendi BANKA_KODU altında izole tutulur. Yeni banka eklemek için
-- BANKA_KURAL tablosuna INSERT yeterlidir — kod değişikliği gerekmez.
-- =============================================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- 1) BANKA_KURAL — Banka-bazlı sınıflandırma kuralları
-- ============================================================
IF OBJECT_ID('dbo.BANKA_KURAL','U') IS NULL
BEGIN
    CREATE TABLE [dbo].[BANKA_KURAL] (
        [ID]              INT IDENTITY(1,1) PRIMARY KEY,
        [BANKA_KODU]      VARCHAR(20)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
                          -- 'GARANTI','ZIRAAT','ISBANK','AKBANK','YAPIKREDI',
                          -- 'HALKBANK','VAKIFBANK','QNB','ING','GENERIK'
        [KURAL_TIPI]      CHAR(1)      NOT NULL,
                          -- 'E'=Etiket→Tür, 'A'=Açıklama→Tür, 'I'=İsim çıkarma
        [PATTERN]         VARCHAR(200) COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
                          -- LIKE deseni veya regex
        [PATTERN_TIPI]    CHAR(1)      NOT NULL DEFAULT 'L',
                          -- 'L'=SQL LIKE, 'R'=Regex (uygulamada işlenecek)
        [TUR_NEG]         INT NULL,   -- Tutar < 0 ise hangi TURID
        [TUR_POZ]         INT NULL,   -- Tutar > 0 ise hangi TURID
        [REGEX_GROUP]     INT NULL,   -- İsim çıkarmada yakalanacak group no
        [CONFIDENCE]      INT NOT NULL DEFAULT 80,
        [KAYNAK]          VARCHAR(20)  COLLATE SQL_Latin1_General_CP1254_CI_AS
                          NOT NULL DEFAULT 'manuel',
                          -- 'manuel','sistem','llm_ogrenildi'
        [KULLANIM_SAYISI] INT NOT NULL DEFAULT 0,
        [SON_KULLANIM]    DATETIME NULL,
        [AKTIF]           BIT NOT NULL DEFAULT 1,
        [OLUSTURMA]       DATETIME NOT NULL DEFAULT GETDATE(),
        [KULLANICIID]     INT NULL,
        [ACIKLAMA]        VARCHAR(200) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL
    );
    CREATE INDEX IX_BKURAL_BANKA_TIP ON BANKA_KURAL (BANKA_KODU, KURAL_TIPI, AKTIF);
END
GO

-- ============================================================
-- 2) BANKA_CARI_ESLEME — Açıklama fingerprint → REHBERID önbelleği
-- ============================================================
IF OBJECT_ID('dbo.BANKA_CARI_ESLEME','U') IS NULL
BEGIN
    CREATE TABLE [dbo].[BANKA_CARI_ESLEME] (
        [ID]            INT IDENTITY(1,1) PRIMARY KEY,
        [BANKA_KODU]    VARCHAR(20)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
        [FINGERPRINT]   VARCHAR(200) COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
                        -- Açıklamadan çıkarılan stabil anahtar
                        -- (örn. "EMİNE ODABAŞI" veya "FETA BILGISAYAR LTD STI")
        [TUR]           INT NULL,    -- Öğrenilen Tür (KASA TUR kodu) — kullanıcı manuel set edebilir
        [REHBERID]      INT NOT NULL,
        [KESIN_MI]      BIT NOT NULL DEFAULT 0,
                        -- 1 = kullanıcı manuel onayladı; öncelik en yüksek
        [KULLANIM]      INT NOT NULL DEFAULT 1,
        [SON_KULLANIM]  DATETIME NOT NULL DEFAULT GETDATE(),
        [OLUSTURMA]     DATETIME NOT NULL DEFAULT GETDATE(),
        [KULLANICIID]   INT NULL
    );
    CREATE INDEX IX_BCESLEME_BANKA_FP ON BANKA_CARI_ESLEME (BANKA_KODU, FINGERPRINT);
END
GO

-- ============================================================
-- 3) BANKA_LLM_LOG — LLM çağrıları ve öğrenme audit log'u
-- ============================================================
IF OBJECT_ID('dbo.BANKA_LLM_LOG','U') IS NULL
BEGIN
    CREATE TABLE [dbo].[BANKA_LLM_LOG] (
        [ID]                INT IDENTITY(1,1) PRIMARY KEY,
        [BANKA_KODU]        VARCHAR(20)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
        [TARIH]             DATETIME NOT NULL DEFAULT GETDATE(),
        [GIRDI_ETIKET]      VARCHAR(200) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
        [GIRDI_ACIKLAMA]    VARCHAR(500) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
        [GIRDI_TUTAR]       DECIMAL(18,2) NULL,
        [LLM_CEVAP_JSON]    NVARCHAR(MAX) NULL,
        [ONERILEN_PATTERN]  VARCHAR(200) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
        [KULLANICI_ONAYI]   BIT NULL,    -- NULL=karar verilmedi, 1=kabul, 0=red
        [KURAL_ID]          INT NULL,    -- Kural oluşturulduysa BANKA_KURAL.ID
        [TOKENS_GIRDI]      INT NULL,    -- Maliyet takibi
        [TOKENS_CIKTI]      INT NULL
    );
    CREATE INDEX IX_BLLMLOG_BANKA ON BANKA_LLM_LOG (BANKA_KODU, TARIH);
END
GO

-- =============================================================
-- SEED — Garanti BBVA için mevcut hardcoded pattern'ler
-- =============================================================

-- Etiket → Tür kuralları (KURAL_TIPI='E')
IF NOT EXISTS (SELECT 1 FROM BANKA_KURAL WHERE BANKA_KODU='GARANTI' AND KURAL_TIPI='E')
BEGIN
    INSERT INTO BANKA_KURAL (BANKA_KODU, KURAL_TIPI, PATTERN, PATTERN_TIPI, TUR_NEG, TUR_POZ, CONFIDENCE, KAYNAK, ACIKLAMA)
    VALUES
      -- Para Transferi → Giden/Gelen Havale
      ('GARANTI','E','PARA TRANSFERI','L', 32, 22, 95, 'sistem', 'Etiket "Para Transferi" → tutara göre 32/22'),
      ('GARANTI','E','PARA TRANSFERİ','L', 32, 22, 95, 'sistem', 'Türkçe karakterli'),
      -- Para Çekme/Yatırma
      ('GARANTI','E','%PARA ÇEKME%','L', 42, NULL, 95, 'sistem', 'Etiket "Para Çekme" → para çekme (42)'),
      ('GARANTI','E','%PARA CEKME%','L', 42, NULL, 95, 'sistem', 'ASCII'),
      ('GARANTI','E','%PARA YATIRMA%','L', NULL, 41, 95, 'sistem', 'Etiket "Para Yatırma" → para yatırma (41)'),
      -- Maaş — pozitifse alınan maaş (Gelir Tahsilatı 122), negatifse maaş ödemesi (Masraf Ödeme 132)
      ('GARANTI','E','MAAŞ','L', 132, 122, 90, 'sistem', 'Etiket "Maaş" → tutar yönüne göre 132/122'),
      ('GARANTI','E','MAAS','L', 132, 122, 90, 'sistem', 'ASCII'),
      -- Kart Ödemesi — banka hesabından kredi kartı borcu ödenmesi
      ('GARANTI','E','%KART ÖDEMES%','L', 57, NULL, 90, 'sistem', 'Etiket "Kart Ödemesi" → KK Ödeme (57)'),
      ('GARANTI','E','%KART ODEMES%','L', 57, NULL, 90, 'sistem', 'ASCII'),
      -- Diğer — banka kesintisi vb. → Masraf Ödeme
      ('GARANTI','E','DİĞER','L', 132, 122, 70, 'sistem', 'Etiket "Diğer" → tutar yönüne göre 132/122 (kesinti vs.)'),
      ('GARANTI','E','DIGER','L', 132, 122, 70, 'sistem', 'ASCII'),
      -- Komisyon / masraf
      ('GARANTI','E','%KOMISYON%','L', 132, NULL, 90, 'sistem', 'Etiketde komisyon → masraf ödeme'),
      ('GARANTI','E','%KOMİSYON%','L', 132, NULL, 90, 'sistem', 'Türkçe'),
      ('GARANTI','E','%MASRAF%','L', 132, NULL, 90, 'sistem', 'Etiketde masraf → masraf ödeme');
END
GO

-- Açıklama → Tür kuralları (KURAL_TIPI='A') — Etiket tanınmadığında kullanılır
IF NOT EXISTS (SELECT 1 FROM BANKA_KURAL WHERE BANKA_KODU='GARANTI' AND KURAL_TIPI='A')
BEGIN
    INSERT INTO BANKA_KURAL (BANKA_KODU, KURAL_TIPI, PATTERN, PATTERN_TIPI, TUR_NEG, TUR_POZ, CONFIDENCE, KAYNAK, ACIKLAMA)
    VALUES
      -- ATM
      ('GARANTI','A','%ATM PARA YATIRMA%','L', NULL, 41, 92, 'sistem', 'ATM para yatırma → para yatırma (41), ATM PARA% genel kuralından önce'),
      ('GARANTI','A','ATM PARA%','L', 42, NULL, 90, 'sistem', 'ATM ile başlayan → para çekme (yatırma kuralı yukarıda yakalanmadıysa)'),
      ('GARANTI','A','PARA ÇEKME','L', 42, NULL, 90, 'sistem', 'Açıklama tam "PARA ÇEKME" (banka şubesi)'),
      -- Havale/EFT/FAST
      ('GARANTI','A','%HVL-CEP%','L', 32, 22, 85, 'sistem', 'CEP ŞUBE havale'),
      ('GARANTI','A','%-EFT-%','L', 32, 22, 80, 'sistem', 'EFT geçen açıklama'),
      ('GARANTI','A','%-FAST-%','L', 32, 22, 80, 'sistem', 'FAST geçen açıklama'),
      ('GARANTI','A','%-FAST%','L', 32, 22, 78, 'sistem', 'FAST sonunda olabilir'),
      ('GARANTI','A','%EFTEMRİ%','L', 32, 22, 80, 'sistem', 'CEP-EFTEMRİ deseni'),
      -- Kredi kartı ödemeleri
      ('GARANTI','A','%KREDI KART%','L', 57, NULL, 88, 'sistem', 'Kredi kartı ödemesi'),
      ('GARANTI','A','%KREDİ KART%','L', 57, NULL, 88, 'sistem', 'Türkçe'),
      ('GARANTI','A','%K.KARTI ÖDEME%','L', 57, NULL, 88, 'sistem', 'K.Kartı Ödeme'),
      ('GARANTI','A','%K.KARTI ODEME%','L', 57, NULL, 88, 'sistem', 'ASCII'),
      ('GARANTI','A','%KKBO%','L', 57, NULL, 80, 'sistem', 'KKBO kodu (Kredi Kartı Borç Ödeme)'),
      -- Maaş / Emekli
      ('GARANTI','A','%EMEKLI%','L', NULL, 122, 85, 'sistem', 'Emekli maaşı → gelir tahsilatı'),
      ('GARANTI','A','%EMEKLİ%','L', NULL, 122, 85, 'sistem', 'Türkçe'),
      ('GARANTI','A','%SSKEMEKL%','L', NULL, 122, 85, 'sistem', 'SSK emekli'),
      ('GARANTI','A','%BAYRAM%','L', NULL, 122, 80, 'sistem', 'Bayram ikramiyesi'),
      ('GARANTI','A','%İKRAMIYE%','L', NULL, 122, 80, 'sistem', 'İkramiye'),
      ('GARANTI','A','%MAAŞ%','L', 132, 122, 75, 'sistem', 'Maaş geçen'),
      ('GARANTI','A','%MAAS%','L', 132, 122, 75, 'sistem', 'ASCII'),
      -- Masraf / Kesinti
      ('GARANTI','A','%KOMISYON%','L', 132, NULL, 85, 'sistem', 'Komisyon'),
      ('GARANTI','A','%KOMİSYON%','L', 132, NULL, 85, 'sistem', 'Türkçe'),
      ('GARANTI','A','%MASRAF%','L', 132, NULL, 85, 'sistem', 'Masraf'),
      ('GARANTI','A','%KESINTI%','L', 132, NULL, 80, 'sistem', 'Banka kesintisi'),
      ('GARANTI','A','%KESİNTİ%','L', 132, NULL, 80, 'sistem', 'Türkçe');
END
GO

-- İsim çıkarma kuralları (KURAL_TIPI='I') — regex tabanlı
IF NOT EXISTS (SELECT 1 FROM BANKA_KURAL WHERE BANKA_KODU='GARANTI' AND KURAL_TIPI='I')
BEGIN
    INSERT INTO BANKA_KURAL (BANKA_KODU, KURAL_TIPI, PATTERN, PATTERN_TIPI, REGEX_GROUP, CONFIDENCE, KAYNAK, ACIKLAMA)
    VALUES
      -- Gelen havale: "FIRMA -<adim> na-HVL..." (yeni para girişi)
      ('GARANTI','I','^(.+?) -.+ na-HVL','R', 1, 92, 'sistem', 'Gelen havale "FIRMA -<adim> na-HVL"'),
      -- Gelen havale (alternatif): "FIRMA -<adim>-HVL..." (na yok)
      ('GARANTI','I','^(.+?) -.+-HVL','R', 1, 88, 'sistem', 'Gelen havale "FIRMA -<adim>-HVL"'),
      -- Giden havale: "ISIM--HVL-CEP ŞUBE"
      ('GARANTI','I','^(.+?)--HVL','R', 1, 92, 'sistem', 'Giden havale "ISIM--HVL"'),
      -- FAST: "ISIM-FAST-..."
      ('GARANTI','I','^(.+?)-FAST','R', 1, 90, 'sistem', 'FAST transferi'),
      -- EFT: "FIRMA-EFT-..."
      ('GARANTI','I','^(.+?)-EFT','R', 1, 90, 'sistem', 'EFT transferi');
END
GO

-- =============================================================
-- SEED — Generik fallback kuralları (BANKA_KODU='GENERIK')
-- Banka tipi belirlenemediğinde devreye girer.
-- =============================================================
IF NOT EXISTS (SELECT 1 FROM BANKA_KURAL WHERE BANKA_KODU='GENERIK' AND KURAL_TIPI='A')
BEGIN
    INSERT INTO BANKA_KURAL (BANKA_KODU, KURAL_TIPI, PATTERN, PATTERN_TIPI, TUR_NEG, TUR_POZ, CONFIDENCE, KAYNAK, ACIKLAMA)
    VALUES
      ('GENERIK','A','%HAVALE%','L', 32, 22, 60, 'sistem', 'Havale geçen → tutara göre'),
      ('GENERIK','A','%EFT%','L', 32, 22, 60, 'sistem', 'EFT geçen → tutara göre'),
      ('GENERIK','A','%TRANSFER%','L', 32, 22, 55, 'sistem', 'Transfer geçen → tutara göre'),
      ('GENERIK','A','%ATM%','L', 42, NULL, 70, 'sistem', 'ATM geçen → para çekme'),
      ('GENERIK','A','%KOMISYON%','L', 132, NULL, 70, 'sistem', 'Komisyon geçen → masraf'),
      ('GENERIK','A','%MASRAF%','L', 132, NULL, 70, 'sistem', 'Masraf geçen → masraf');
END
GO

PRINT 'Banka kural altyapısı kuruldu.';
DECLARE @GarantiAdet INT, @GenerikAdet INT;
SELECT @GarantiAdet = COUNT(*) FROM BANKA_KURAL WHERE BANKA_KODU = 'GARANTI';
SELECT @GenerikAdet = COUNT(*) FROM BANKA_KURAL WHERE BANKA_KODU = 'GENERIK';
PRINT 'Garanti seed: ' + CAST(@GarantiAdet AS VARCHAR(10)) + ' kural';
PRINT 'Generik seed: ' + CAST(@GenerikAdet AS VARCHAR(10)) + ' kural';
GO

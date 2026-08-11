-- ============================================================
-- GenDepoUpdate130.sql
-- DONUSUMDE KAYNAK BELGE DURUMU - tek model
--
--   0 Taslak      : yeni olusan belge (Windows ya da mobil)
--   2 Onay        : mobilden gelen belge merkezden ONAYLANDI
--   1 Kismi       : satirlarin bir kismi donustu
--   9 Tamamlandi  : tamami donustu
--   6 Iptal       : donusum iptal edildi -> BELGE DONUSMEZ ve donusum
--                   kaynak listelerinde GORUNMEZ (belge icindeki donustur
--                   butonu ile yapilan donusumlerde de kapsam disidir)
--
-- NE DEGISTI
--   1) GENINI secenek listeleri: siparis (-24020/-24021) "Yapilmadi" -> "Taslak";
--      her uc listeye (belge -2405 dahil) "Onay" (2) eklendi.
--   2) sp_Api_Belge_Durum_Yaz_Ic
--        - ONAY (2) da yeniden hesaplanabilir duruma alindi: onaylanmis belge
--          donusmeye basladiginda Kismi/Tamamlandi'ya gecer (once "durum
--          korumali" deyip hic dokunmuyordu).
--        - IPTAL (6) korunur - hicbir kosulda otomatik degismez.
--        - Donusum kodlari artik ROTA MATRISINDEN okunur; SP icindeki elle
--          yazilmis kod listeleri (409/410/415/420/429/473 ...) kaldirildi.
--          Yeni rota eklendiginde durum hesabi kendiliginden kapsar.
--   3) fn_Prog_Donusum_KaynakDonusebilirMi : tek yerden "bu belge donusturulebilir
--      mi" cevabi (IPTAL ise 0). Donusum SP'leri ve kaynak listeleri bunu kullanir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

-- ---- 2) DURUM HESABI ----------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Durum_Yaz_Ic
    @BelgeId     INT,
    @Kaynak      NVARCHAR(10) = N'siparis',
    @Yaz         BIT = 1,
    @Tur         INT OUTPUT,
    @Durum       INT OUTPUT,
    @OncekiDurum INT OUTPUT,
    @Satir       INT OUTPUT,
    @Tamamlanan  INT OUTPUT,
    @Kismi       INT OUTPUT,
    @Acik        INT OUTPUT,
    @Neden       NVARCHAR(60) OUTPUT,
    @Yazildi     BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Neden = N''; SET @Yazildi = 0;
    SET @Satir = 0; SET @Tamamlanan = 0; SET @Kismi = 0; SET @Acik = 0;

    IF @Kaynak = N'siparis'
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM SIPARIS   WHERE ID = @BelgeId;
    ELSE
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL THROW 51002, N'Kayit bulunamadi.', 1;
    SET @Durum = @OncekiDurum;

    -- Yeniden hesaplanabilir durumlar: Taslak(0) / Kismi(1) / Onay(2) / Tamamlandi(9)
    --   IPTAL(6) ve diger ozel durumlar KORUNUR (otomatik degismez).
    IF @OncekiDurum NOT IN (0, 1, 2, 9)
        SET @Neden = N'durum korumali (' + CAST(@OncekiDurum AS nvarchar(10)) + N')';

    -- Bu belge turunden CIKAN donusum kodlari: ROTA MATRISINDEN (elle liste YOK)
    DECLARE @Yeri TABLE (K INT PRIMARY KEY);
    IF @Neden = N''
    BEGIN
        INSERT @Yeri (K)
        SELECT DISTINCT R.DonusumTuru
        FROM dbo.fn_Prog_BelgeDonusum_Rota() R
        WHERE R.KaynakTur = @Tur
          AND R.KaynakDetayTablo = CASE WHEN @Kaynak = N'siparis' THEN 'SIPARISDETAY' ELSE 'FATURA' END
          AND R.KalanHedefTablo = 'FATURA';

        IF NOT EXISTS (SELECT 1 FROM @Yeri)
            SET @Neden = CASE WHEN @Kaynak = N'siparis' THEN N'siparis turu kapsam disi'
                              ELSE N'belge turu kapsam disi' END;
    END

    IF @Neden = N''
    BEGIN
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6), Cikan DECIMAL(18,6));
        IF @Kaynak = N'siparis'
            INSERT @S SELECT SD.ID, ISNULL(SD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = SD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM SIPARISDETAY SD WHERE SD.SIPARISID = @BelgeId AND ISNULL(SD.ADET,0) > 0;
        ELSE
            INSERT @S SELECT FD.ID, ISNULL(FD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = FD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM FATURA FD WHERE FD.FATBASID = @BelgeId AND ISNULL(FD.ADET,0) > 0;

        SELECT @Satir      = COUNT(*),
               @Tamamlanan = ISNULL(SUM(CASE WHEN Adet - Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Acik       = ISNULL(SUM(CASE WHEN Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Kismi      = ISNULL(SUM(CASE WHEN Cikan > 0 AND Adet - Cikan > 0 THEN 1 ELSE 0 END), 0)
        FROM @S;

        IF @Satir = 0                SET @Neden = N'adetli satir yok';
        ELSE IF @Satir = @Tamamlanan SET @Durum = 9;                       -- Tamamlandi
        -- Hic donusum yoksa: ONAY(2) korunur, digerlerinde TASLAK(0)
        ELSE IF @Acik = @Satir       SET @Durum = CASE WHEN @OncekiDurum = 2 THEN 2 ELSE 0 END;
        ELSE                         SET @Durum = 1;                       -- Kismi
    END

    IF @Yaz = 1 AND @Neden = N'' AND @Durum <> @OncekiDurum
    BEGIN
        IF @Kaynak = N'siparis' UPDATE SIPARIS   SET DURUM = @Durum WHERE ID = @BelgeId;
        ELSE                    UPDATE FATBASLIK SET DURUM = @Durum WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END
END
GO

-- ---- 3) DONUSTURULEBILIR MI ---------------------------------------------
--   Tek kural kaynagi: IPTAL(6) belge donusmez. Kaynak listeleri ve donusum
--   SP'leri bunu cagirir; ileride yeni kural eklenirse TEK yerde eklenir.
CREATE OR ALTER FUNCTION dbo.fn_Prog_Donusum_KaynakDonusebilirMi
(
    @BelgeTablo varchar(20),   -- 'SIPARIS' | 'FATBASLIK'
    @BelgeId    INT
)
RETURNS bit
AS
BEGIN
    DECLARE @D INT;
    IF @BelgeTablo = 'SIPARIS'
        SELECT @D = ISNULL(DURUM, 0) FROM SIPARIS   WHERE ID = @BelgeId;
    ELSE
        SELECT @D = ISNULL(DURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;

    IF @D IS NULL   RETURN 0;    -- kayit yok
    IF @D = 6       RETURN 0;    -- IPTAL
    RETURN 1;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.fn_Prog_Donusum_KaynakDonusebilirMi TO gentegre_api;
GO

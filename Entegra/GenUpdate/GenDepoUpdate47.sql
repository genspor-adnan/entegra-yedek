-- ============================================================
-- GenDepoUpdate47 (musteri uygulama)
--   Dokuman liste standart-sistem SP'si (ListeSPJson @Baslik+@Kosullar):
--     sp_Prog_Dokuman_Liste_Json2  (Mod=1 klasor-agac / 2 arama / 3 tum; 2-kol union)
--   Uygulama build'i de gerekir (UDokumanListeFrame YenileKlasorClick/JvTimer1Timer/
--     LabelTumKayitlarClick -> ListeSPJson). NOT: DOKUMAN SAP-modu kaldirildi (SP-only).
--   Tek CREATE OR ALTER -> tek batch (GO gerekmez). MSSQL-only (PG icin ayri fonksiyon).
-- ============================================================
-- ============================================================
-- sp_Prog_Dokuman_Liste_Json2 — Dokuman liste (2 param: @Baslik + @Kosullar JSON)
--   UDokumanListeFrame inline SQL'inin (SQLMemo + SQLMemo2 union-all + Pascal filtreleri)
--   standart-sistem karsiligi. Rapor listesi (son-aranan yok).
--   Iki kol tek WITH Dizin (ozyinelemeli klasor-yol) CTE'sini paylasir:
--     arm1 DTIP=1  = DOKUMAN D  (+ IMAJ/Firma/Lokasyon/Sorumlu/DY join)
--     arm2 DTIP=0  = DOKUMANKISAYOL DK -> DOKUMAN D (DY join YOK)
--   Tum MSSQL dialect (WITH ozyineleme/top1/REVERSE/CHARINDEX/DATETIME) SP govdesinde
--   izole -> app engine-agnostic; PG icin ayri fonksiyon (frame vmPG'de Exit eder).
--
--   @Kosullar alanlari (frame 3 cagri yerine gore doldurur):
--     Mod       : 1=klasor-agac  2=arama-formu  3=tum-kayitlar (varsayilan 3)
--     KlasorId  : Mod=1 secili klasor ID
--     TabNo     : Mod=1 arm2 DOKUMANKISAYOL.YER (TabNo_DOKUMAN)
--     TamYetki  : bit; Mod=1'de kisitsiz, Mod=2'de gizlilik gate'i kapatir
--     GD        : gizlilik derecesi ust siniri (TamYetki=0 iken)
--     Kullanan  : Mod=1 non-yetki DY.REHBERID esitleme
--     Mod=2 arama: AraDokuman/AraKonu/AraAnahtar/AraKurum/AraSorumlu/AraLokasyon
--                  Bolum/Modul/Kategori (0/yok=tumu), Pasif(bit=checkPasif),
--                  TarihVar(bit)/TarihBas/TarihBit
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Dokuman_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod') AS INT), 3);
    DECLARE @KlasorId   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KlasorId') AS INT);
    DECLARE @TabNo      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TabNo') AS INT);
    DECLARE @TamYetki   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TamYetki') AS BIT), 0);
    DECLARE @GD         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.GD') AS INT), 1);
    DECLARE @Kullanan   INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kullanan') AS INT), 0);
    DECLARE @AraDokuman NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraDokuman'), N'');
    DECLARE @AraKonu    NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraKonu'), N'');
    DECLARE @AraAnahtar NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraAnahtar'), N'');
    DECLARE @AraKurum   NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraKurum'), N'');
    DECLARE @AraSorumlu NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraSorumlu'), N'');
    DECLARE @AraLokasyon NVARCHAR(200)= NULLIF(JSON_VALUE(@Kosullar,'$.AraLokasyon'), N'');
    DECLARE @Bolum      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Bolum') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @Kategori   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Kategori') AS INT);
    DECLARE @Pasif      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @TarihVar   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihVar') AS BIT), 0);
    DECLARE @TarihBas   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);

    -- Bolum/Modul/Kategori: 0 => filtre yok (orijinal 'EditValue > 0' kosulu)
    IF @Bolum    = 0 SET @Bolum    = NULL;
    IF @Modul    = 0 SET @Modul    = NULL;
    IF @Kategori = 0 SET @Kategori = NULL;

    ;WITH Dizin AS
    (
        SELECT ID, USTID, AD = CAST(AD AS NVARCHAR(260))
        FROM DOKUMANKLASOR
        WHERE USTID = 0
        UNION ALL
        SELECT A.ID, A.USTID, AD = CAST(V.AD + N'\' + A.AD AS NVARCHAR(260))
        FROM DOKUMANKLASOR A
        INNER JOIN Dizin V ON V.ID = A.USTID
    )
    -- ---------- arm1: DTIP=1  (DOKUMAN D) ----------
    SELECT DISTINCT
        D.*, DTIP = 1, KISAYOLID = 0,
        Firma.FIRMA AS KURUM, Lokasyon.ACIKLAMA AS LOKASYONAD, Sorumlu.FIRMA AS SORUMLUAD,
        EXT = N'.' + I.BELGETURU, I.SURUM, I.BOYUT,
        KLASORAD      = (SELECT AD    FROM Dizin  WHERE ID = D.KLASOR),
        ONAYLAYACAKAD = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAYLAYACAK),
        ONAYLAYANAD   = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAY),
        EKLEYENAD     = (SELECT FIRMA FROM REHBER WHERE ID = D.EKLEYEN),
        DEGISTIRENAD  = (SELECT FIRMA FROM REHBER WHERE ID = D.DEGISTIREN)
    FROM DOKUMAN D
        INNER JOIN IMAJ I ON I.ID = (SELECT TOP 1 ID FROM IMAJ WHERE YERI = 1 AND YER_ID = D.ID ORDER BY ID DESC)
        LEFT OUTER JOIN REHBER   Firma    ON Firma.ID    = D.REHBERID
        LEFT OUTER JOIN LOKASYON Lokasyon ON Lokasyon.ID = D.LOKASYON
        LEFT OUTER JOIN REHBER   Sorumlu  ON Sorumlu.ID  = I.REHBERID
        LEFT OUTER JOIN DOKUMANYETKI DY   ON DY.YERI = 321 AND DY.YERID = D.ID
    WHERE
        (   -- Mod=1 klasor-agac
            @Mod = 1
            AND D.KLASOR = @KlasorId
            AND ( @TamYetki = 1
                  OR ( D.GIZLILIKDERECESI <= @GD AND DY.GOR = 1
                       AND (DY.REHBERID = 0 OR DY.REHBERID = @Kullanan) ) )
        )
        OR
        (   -- Mod=2 arama-formu
            @Mod = 2
            AND (@AraDokuman  IS NULL OR D.AD             LIKE N'%' + @AraDokuman  + N'%')
            AND (@AraKonu     IS NULL OR D.KONU           LIKE N'%' + @AraKonu     + N'%')
            AND (@AraAnahtar  IS NULL OR D.ANAHTAR        LIKE N'%' + @AraAnahtar  + N'%')
            AND (@AraKurum    IS NULL OR Firma.FIRMA      LIKE N'%' + @AraKurum    + N'%')
            AND (@AraSorumlu  IS NULL OR Sorumlu.FIRMA    LIKE N'%' + @AraSorumlu  + N'%')
            AND (@AraLokasyon IS NULL OR Lokasyon.ACIKLAMA LIKE N'%' + @AraLokasyon + N'%')
            AND (@Bolum       IS NULL OR D.BOLUM    = @Bolum)
            AND (@Modul       IS NULL OR D.MODUL    = @Modul)
            AND (@Kategori    IS NULL OR D.KATEGORI = @Kategori)
            AND (@Pasif       = 1     OR D.DURUM    = 1)
            AND (@TamYetki    = 1     OR D.GIZLILIKDERECESI <= @GD)
            AND (@TarihVar    = 0     OR (D.TARIH >= @TarihBas AND D.TARIH <= @TarihBit))
        )
        OR @Mod = 3   -- Mod=3 tum-kayitlar

    UNION ALL

    -- ---------- arm2: DTIP=0  (DOKUMANKISAYOL DK) ----------
    SELECT DISTINCT
        D.*, DTIP = 0, KISAYOLID = DK.ID,
        Firma.FIRMA AS KURUM, Lokasyon.ACIKLAMA AS LOKASYONAD, Sorumlu.FIRMA AS SORUMLUAD,
        EXT = CASE WHEN D.AD LIKE N'%.%'
                   THEN N'.' + REVERSE(SUBSTRING(REVERSE(ISNULL(D.AD, N'.')), 1,
                                CHARINDEX(N'.', REVERSE(ISNULL(D.AD, N'.')), 1) - 1))
                   ELSE N'' END,
        I.SURUM, I.BOYUT,
        KLASORAD      = (SELECT AD    FROM Dizin  WHERE ID = D.KLASOR),
        ONAYLAYACAKAD = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAYLAYACAK),
        ONAYLAYANAD   = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAY),
        EKLEYENAD     = (SELECT FIRMA FROM REHBER WHERE ID = D.EKLEYEN),
        DEGISTIRENAD  = (SELECT FIRMA FROM REHBER WHERE ID = D.DEGISTIREN)
    FROM DOKUMANKISAYOL DK
        INNER JOIN DOKUMAN D ON DK.DOKUMANID = D.ID
        INNER JOIN IMAJ I ON I.ID = (SELECT TOP 1 ID FROM IMAJ WHERE YERI = 1 AND YER_ID = D.ID ORDER BY ID DESC)
        LEFT OUTER JOIN REHBER   Firma    ON Firma.ID    = D.REHBERID
        LEFT OUTER JOIN LOKASYON Lokasyon ON Lokasyon.ID = D.LOKASYON
        LEFT OUTER JOIN REHBER   Sorumlu  ON Sorumlu.ID  = I.REHBERID
    WHERE
        (   -- Mod=1 klasor-agac (arm2: kisayol yeri/yer_id)
            @Mod = 1
            AND DK.YER = @TabNo AND DK.YER_ID = @KlasorId
        )
        OR
        (   -- Mod=2 arama-formu (arm1 ile ayni filtre)
            @Mod = 2
            AND (@AraDokuman  IS NULL OR D.AD             LIKE N'%' + @AraDokuman  + N'%')
            AND (@AraKonu     IS NULL OR D.KONU           LIKE N'%' + @AraKonu     + N'%')
            AND (@AraAnahtar  IS NULL OR D.ANAHTAR        LIKE N'%' + @AraAnahtar  + N'%')
            AND (@AraKurum    IS NULL OR Firma.FIRMA      LIKE N'%' + @AraKurum    + N'%')
            AND (@AraSorumlu  IS NULL OR Sorumlu.FIRMA    LIKE N'%' + @AraSorumlu  + N'%')
            AND (@AraLokasyon IS NULL OR Lokasyon.ACIKLAMA LIKE N'%' + @AraLokasyon + N'%')
            AND (@Bolum       IS NULL OR D.BOLUM    = @Bolum)
            AND (@Modul       IS NULL OR D.MODUL    = @Modul)
            AND (@Kategori    IS NULL OR D.KATEGORI = @Kategori)
            AND (@Pasif       = 1     OR D.DURUM    = 1)
            AND (@TamYetki    = 1     OR D.GIZLILIKDERECESI <= @GD)
            AND (@TarihVar    = 0     OR (D.TARIH >= @TarihBas AND D.TARIH <= @TarihBit))
        )
        OR @Mod = 3;   -- Mod=3 tum-kayitlar
END;

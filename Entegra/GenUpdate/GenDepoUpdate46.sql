-- ============================================================
-- GenDepoUpdate46 (musteri uygulama)
--   PDKS liste standart-sistem SP'si (ListeSPJson @Baslik+@Kosullar):
--     sp_Prog_PDKS_Liste_Json2  (personel giris/cikis rapor listesi; son-aranan yok)
--   Uygulama build'i de gerekir (UPDKSListeFrame.YenileClick -> ListeSPJson).
--   Tek CREATE OR ALTER -> tek batch (GO gerekmez). MSSQL-only (PG icin ayri fonksiyon).
-- ============================================================
-- ============================================================
-- sp_Prog_PDKS_Liste_Json2 — PDKS (personel giris/cikis) liste (2 param: @Baslik + @Kosullar JSON)
--   UPDKSListeFrame inline SQL'inin (SQLMemo + Pascal filtreleri) standart-sistem karsiligi.
--   Rapor listesi (son-aranan yok). Tum MSSQL dialect (DATEADD/DATEDIFF/CONVERT 108/
--   DATEPART/CAST time/dbo.fn_*) SP govdesinde izole -> app engine-agnostic; PG icin ayri fonksiyon.
--   Filtreler statik-parametreli ((@p IS NULL OR ...)) -> plan cache reuse.
--   @Kosullar: RehberID(0/yok=tumu), TarihBas, TarihBit, GirisTur(0/1erken/2gec),
--              CikisTur(0/1/2), CikisNull(bit), SubeID, Durum.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_PDKS_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RehberID INT      = TRY_CAST(JSON_VALUE(@Kosullar,'$.RehberID') AS INT);
    DECLARE @TarihBas DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    DECLARE @GirisTur INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.GirisTur') AS INT), 0);
    DECLARE @CikisTur INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CikisTur') AS INT), 0);
    DECLARE @CikisNull BIT     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CikisNull') AS BIT), 0);
    DECLARE @SubeID   INT      = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeID') AS INT);
    DECLARE @Durum    INT      = TRY_CAST(JSON_VALUE(@Kosullar,'$.Durum') AS INT);

    SELECT
        PP.ID, R.FIRMA, R.ID AS REHBERID,
        TARIH = DATEADD(dd, 0, DATEDIFF(dd, 0, PP.GIRIS)),
        PV.GUNADI,
        GIRIS = CONVERT(varchar, PP.GIRIS, 108),
        CIKIS = CONVERT(varchar, PP.CIKIS, 108),
        MOLA  = CONVERT(varchar, PP.MOLA, 108),
        PP.SUBEID, PP.DURUM, PP.ACIKLAMA,
        VARGIRISCIKIS = (CONVERT(varchar, PV.GIRIS, 108) + N' / ' + CONVERT(varchar, PV.CIKIS, 108)),
        GIRFARK = CASE WHEN PP.DURUM <> 1 THEN N''
                       ELSE ISNULL(dbo.fn_GIRFARK(CONVERT(varchar, PV.GIRIS, 108), PP.GIRIS), '00:00') END,
        CALSURE = ISNULL(dbo.fn_SaatOlarak(DATEDIFF(mi, PP.GIRIS, DATEADD(second, -DATEDIFF(second, 0, CAST(PP.MOLA AS time(0))), PP.CIKIS))), '00:00'),
        CALFARK = CASE WHEN charindex('*', dbo.fn_SaatOlarak(DATEDIFF(mi, PP.GIRIS, PP.CIKIS))) = 0
                       THEN dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi, PV.GIRIS, PV.CIKIS)), dbo.fn_SaatOlarak(DATEDIFF(mi, PP.GIRIS, PP.CIKIS)))
                       ELSE '00:00' END,
        CIKFARK = CASE WHEN PP.DURUM <> 1 THEN N''
                       ELSE ISNULL(dbo.fn_CIKFARK(CONVERT(varchar, PV.GIRIS, 108), dbo.fn_SaatOlarak(DATEDIFF(mi, PV.GIRIS, PV.CIKIS)), PP.GIRIS, PP.CIKIS), '00:00') END
    FROM PERS_PDKS PP
    LEFT OUTER JOIN REHBER R ON R.ID = PP.REHBERID
    LEFT OUTER JOIN PERS_VARDIYATANIM PV ON
        PV.REHBERID = CASE WHEN EXISTS (SELECT TOP 1 ISNULL(REHBERID, -1) FROM dbo.PERS_VARDIYATANIM WHERE REHBERID = PP.REHBERID)
                           THEN PP.REHBERID ELSE -1 END
        AND PV.GUN = DATEPART(WEEKDAY, PP.GIRIS)
    WHERE AY = 0
      -- kisi: secilirse o kisi, yoksa REHBERID<>0
      AND (ISNULL(@RehberID, 0) = 0 OR PP.REHBERID = @RehberID)
      AND (ISNULL(@RehberID, 0) <> 0 OR PP.REHBERID <> 0)
      -- tarih araligi
      AND (@TarihBas IS NULL OR PP.GIRIS >= @TarihBas)
      AND (@TarihBit IS NULL OR PP.GIRIS <= @TarihBit)
      -- giris erken(1)/gec(2)
      AND (@GirisTur = 0
           OR (@GirisTur = 1 AND CAST(PV.GIRIS AS Time) > CAST(PP.GIRIS AS Time) AND CAST(PP.GIRIS AS Time) <> '00:00')
           OR (@GirisTur = 2 AND CAST(PV.GIRIS AS Time) < CAST(PP.GIRIS AS Time)))
      -- cikis erken(1)/gec(2)
      AND (@CikisTur = 0
           OR (@CikisTur = 1 AND CAST(PV.CIKIS AS Time) > CAST(PP.CIKIS AS Time))
           OR (@CikisTur = 2 AND CAST(PV.CIKIS AS Time) < CAST(PP.CIKIS AS Time)))
      -- sadece cikisi olanlar
      AND (@CikisNull = 0 OR PP.CIKIS <> '')
      -- sube / durum
      AND (@SubeID IS NULL OR R.SUBEID = @SubeID)
      AND (@Durum  IS NULL OR PP.DURUM = @Durum)
    ORDER BY R.FIRMA, PP.GIRIS, PP.CIKIS;
END;

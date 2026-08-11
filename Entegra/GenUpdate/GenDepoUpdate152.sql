-- ============================================================
-- GenDepoUpdate152.sql
-- MESAJLASMA: avatar fotograflarini TOPLU getir
--
-- Tek tek okumak (sp_Prog_Mesaj_Avatar @RehberId) sol listeyi kaydirirken
--   satir basina ayri gidis-donus demekti. Bu SP virgullu ID listesi alir,
--   fotograflari TEK sorguda dondurur. Istemci sonucu onbellekler.
--
-- STRING_SPLIT yerine XML ayristirma: eski SQL Server surumlerinde de calisir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Avatar_Toplu
    @Idler NVARCHAR(MAX)          -- '1064,1098,3228'
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL(@Idler, N'') = N'' RETURN;

    DECLARE @X XML = CAST(N'<i>' + REPLACE(@Idler, N',', N'</i><i>') + N'</i>' AS XML);

    ;WITH Idler AS
    (
        SELECT ID = T.c.value(N'.', N'INT')
        FROM @X.nodes(N'/i') T(c)
    )
    SELECT R.ID, R.RESIM
    FROM dbo.REHBER R
        INNER JOIN Idler I ON I.ID = R.ID
    WHERE R.RESIM IS NOT NULL;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Avatar_Toplu TO gentegre_api;
GO

-- Update_SQL_199: Belge donusumunde seri/lot aktarimi SESSIZCE eksik kalmasin.
--
-- Musteri (Expert): siparis -> irsaliye'de tek lotlu urunde secim ekrani acilmiyor (tek aday
-- otomatik secilir - dogru) ama lot irsaliye satirina yazilmiyor, belge eksik olusuyor.
-- Guncel SP zincirinde (Dogrula tek-aday secimi -> Kaydet -> IzlemeAktar -> sp_Prog_Izleme_Aktar_Json)
-- yerel testte lot STOKIZLEME'ye yaziliyor; musteride yazilmiyorsa aktarim adimi sessiz basarisiz.
-- Bu betik sp_Prog_BelgeDonusum_Uygula_Json2'ye IzlemeAktar sonrasi KONTROL ekler: secimi olan
-- her kaynak satirin hedef satirinda STOKIZLEME kaydi yoksa THROW -> islem geri sarilir, kullanici
-- "Seri/lot secimi hedef satira yazilamadi: <urun>" mesajini gorur (eksik belge yerine).
-- Canli tanim yerinde yamalanir, idempotent, veri degismez.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @Sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_BelgeDonusum_Uygula_Json2'));
IF @Sql IS NULL THROW 51200, N'sp_Prog_BelgeDonusum_Uygula_Json2 bulunamadi.', 1;
IF CHARINDEX(N'Update199', @Sql) > 0
    PRINT N'Update199: sp_Prog_BelgeDonusum_Uygula_Json2 zaten yamali - atlandi.';
ELSE IF (LEN(@Sql) - LEN(REPLACE(@Sql, N'@Aktarilan = @Akt OUTPUT;', N''))) / LEN(N'@Aktarilan = @Akt OUTPUT;') <> 1
    THROW 51200, N'Update199: IzlemeAktar cagrisi tam bir kez bulunamadi, SP elle kontrol edilmeli.', 1;
ELSE
BEGIN
    SET @Sql = REPLACE(@Sql, N'@Aktarilan = @Akt OUTPUT;', N'@Aktarilan = @Akt OUTPUT;

        -- Update199: izlemeli satirlarin seri/lot''u hedef satira gercekten yazildi mi? Yazilmadiysa
        --   belge EKSIK olusmasin - islem geri sarilir, sebep acikca soylenir (Expert: "tek lot
        --   secim ekrani acilmadi, irsaliye satirina lot da yazilmadi" - sessiz eksik belge yerine hata).
        IF EXISTS (SELECT 1
                   FROM #DonusumIzlemeSecim I
                        INNER JOIN #DonusumSatirEsleme E ON E.KaynakSatirId = I.SatirId
                   WHERE NOT EXISTS (SELECT 1 FROM dbo.STOKIZLEME SI
                                     WHERE SI.BASLIKID = @HedefOut AND SI.SATIRID = E.HedefSatirId))
        BEGIN
            DECLARE @EksikSatir NVARCHAR(400) =
                STUFF((SELECT DISTINCT N'', '' + ISNULL(ST.STOKADI, CAST(S.UrunId AS nvarchar(12)))
                       FROM #DonusumIzlemeSecim I
                            INNER JOIN #DonusumSatirEsleme E ON E.KaynakSatirId = I.SatirId
                            INNER JOIN #DonusumKaynakSatir S ON S.SatirId = I.SatirId
                            LEFT JOIN dbo.STOKLAR ST ON ST.ID = S.UrunId
                       WHERE NOT EXISTS (SELECT 1 FROM dbo.STOKIZLEME SI
                                         WHERE SI.BASLIKID = @HedefOut AND SI.SATIRID = E.HedefSatirId)
                       FOR XML PATH(''''), TYPE).value(''.'', ''nvarchar(max)''), 1, 2, N'''');
            DECLARE @EksikMsg NVARCHAR(600) = N''Seri/lot secimi hedef satira yazilamadi: '' + ISNULL(@EksikSatir, N''?'')
                + N''. Belge olusturulmadi; izleme aktarim SP''''leri (sp_Prog_Izleme_Aktar_Json) guncel mi kontrol edin.'';
            THROW 51200, @EksikMsg, 1;
        END');
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2', N'ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2', N'ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2', N'ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2');
    IF CHARINDEX(N'ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2', @Sql) = 0
        THROW 51200, N'Update199: SP basligi cozulemedi.', 1;
    EXEC sp_executesql @Sql;
    PRINT N'Update199: sp_Prog_BelgeDonusum_Uygula_Json2 izleme aktarim kontrolu eklendi.';
END
GO

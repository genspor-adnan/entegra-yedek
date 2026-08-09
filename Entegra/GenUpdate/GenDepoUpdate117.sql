-- ============================================================
-- GenDepoUpdate117.sql
-- sp_Prog_Siparis_Silinebilir_Mi : donusum kontrolu ROTA MATRISINDEN
--
-- HATA (08.08.2026): tekliften uretilen alis siparisi konsinyeye cevrildikten
--   SONRA silinebiliyordu - zincir kopuyor, hedef belge kaynaksiz kaliyordu.
--
-- NEDEN: kural donusum kodlarini ELLE sayiyordu
--     TUR = 9  -> 406, 407
--     TUR = 19 -> 409, 410, 415, 420
--   Rota matrisinde SIPARISDETAY kaynakli 12 rota var; listede 6'si yok:
--     478 (alis fisi), 414 (transfer), 429 (giden konsinye), 473 (satis fisi),
--     435 (stok talebi -> transfer), 428 (satinalma talebi -> siparis)
--   Yani konsinye, fis, transfer ve talep->siparis donusumleri silmeyi
--   ENGELLEMIYORDU.
--
-- COZUM: kodlar fn_Prog_BelgeDonusum_Rota'dan okunuyor - donusumun zaten tek
--   kaynagi. Yeni rota eklendiginde bu kural KENDILIGINDEN kapsar; elle
--   guncellenecek ikinci bir liste kalmadi.
--
-- 428 AYRI ELE ALINDI: o rotanin hedefi FATURA degil SIPARISDETAY
--   (satinalma talebi -> alis siparisi). Hedef tablo rotadan okunup iki dal
--   ayri yaziliyor.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Siparis_Silinebilir_Mi
  @SiparisID int = 0,
  @SatirID   int = 0
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH Satirlar AS (
    SELECT SD.ID AS SATIRID, S.TUR AS TUR
    FROM SIPARISDETAY SD
    INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
    WHERE (@SatirID > 0 AND SD.ID = @SatirID)
       OR (@SatirID = 0 AND SD.SIPARISID = @SiparisID)
  )
  SELECT TOP 1 SILINEBILIR, NEDEN, BELGEAD, BELGETARIH, BELGENO
  FROM (
    -- DONUSUM (hedef FATURA): siparis satiri belgeye donusturulmus
    SELECT 0 AS SILINEBILIR, 'DONUSUM' AS NEDEN,
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FB.TUR) AS varchar(100)) AS BELGEAD,
      CAST(FB.FATURATARIH AS datetime) AS BELGETARIH,
      CAST(FB.FATURANO AS varchar(50)) AS BELGENO, 1 AS SIRA
    FROM Satirlar S
    INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
            ON R.KaynakDetayTablo = 'SIPARISDETAY'
           AND R.KalanHedefTablo  = 'FATURA'
           AND R.KaynakTur        = S.TUR
    INNER JOIN FATURA F     ON F.YERID = S.SATIRID AND F.YERI = R.DonusumTuru
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID

    UNION ALL
    -- DONUSUM (hedef SIPARISDETAY): 428 satinalma talebi -> alis siparisi
    SELECT 0, 'DONUSUM',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = S2.TUR) AS varchar(100)),
      CAST(S2.SIPARISTARIH AS datetime),
      CAST(S2.SIPARISNO AS varchar(50)), 1
    FROM Satirlar S
    INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
            ON R.KaynakDetayTablo = 'SIPARISDETAY'
           AND R.KalanHedefTablo  = 'SIPARISDETAY'
           AND R.KaynakTur        = S.TUR
    INNER JOIN SIPARISDETAY SD2 ON SD2.YERID = S.SATIRID AND SD2.YERI = R.DonusumTuru
    INNER JOIN SIPARIS S2       ON S2.ID = SD2.SIPARISID

    UNION ALL
    -- ENGEL YOK -> silinebilir
    SELECT 1, '',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 99
  ) X
  ORDER BY SIRA;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Siparis_Silinebilir_Mi TO gentegre_api;
GO

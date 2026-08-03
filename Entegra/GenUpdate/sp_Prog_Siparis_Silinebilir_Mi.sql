-- ============================================================================
-- sp_Prog_Siparis_Silinebilir_Mi  (MSSQL)  -- fatura SP'sinin siparis karsiligi.
--   Siparis/satinalma SILME on-kontrolu. Iki mod:
--     @SatirID > 0  -> tek SIPARISDETAY satiri
--     @SatirID = 0  -> @SiparisID altindaki TUM detay satirlari (biri engelliyse toptan RED)
--   Hep TEK satir doner: SILINEBILIR(0/1), NEDEN, BELGEAD, BELGETARIH, BELGENO.
--   Gerekli kontrol: DONUSUM - siparis satiri asagi-akista fatura/irsaliye/uretime donusturulmus mu
--   (FATURA.YERID = SIPARISDETAY.ID + kaynak YERI kodu). Kodlar fn_prg_servis_belgeler ile ayni:
--     TUR=9  (gelen/verilen siparis) -> FATURA.YERI in (406,407)
--     TUR=19 (giden siparis)         -> FATURA.YERI in (409,410,415,420)
--   NOT: satinalma(101)/stoktalep(105) zincir donusumleri gerekince eklenir.
-- ============================================================================
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
    -- DONUSUM: siparis satiri fatura/irsaliye/uretime donusturulmus
    SELECT 0 AS SILINEBILIR, 'DONUSUM' AS NEDEN,
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FB.TUR) AS varchar(100)) AS BELGEAD,
      CAST(FB.FATURATARIH AS datetime) AS BELGETARIH,
      CAST(FB.FATURANO AS varchar(50)) AS BELGENO, 1 AS SIRA
    FROM Satirlar S
    INNER JOIN FATURA F   ON F.YERID = S.SATIRID
      AND ((S.TUR = 9  AND F.YERI IN (406,407))
        OR (S.TUR = 19 AND F.YERI IN (409,410,415,420)))
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID

    UNION ALL
    -- ENGEL YOK -> silinebilir
    SELECT 1, '',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 99
  ) X
  ORDER BY SIRA;
END

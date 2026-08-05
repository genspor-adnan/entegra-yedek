-- ============================================================
--   GenDepoUpdate65 — StokHizmetAra PAKET detayi: sp_Prog_StokHizmetAra_Paket
--   MUSTERI ANA veritabaninda calistirilir (GENDEPO'da DEGIL).
--   Tek CREATE OR ALTER -> tek batch (GO gerekmez).
--
--   NEDEN SP:
--     UStokHizmetAra.TabPaket'in DFM SQL'i
--        declare @PaketID int ... set @PaketID = :P1 ... select ...
--     seklindeydi. PARAMETRELI DECLARE BATCH'i ODBC surucusu PREPARE EDEMEZ
--     (SQLDescribeParam basarisiz) ->
--        "COUNT field incorrect or syntax error"
--     hatasi ile paket urun secimi hic calismiyordu. Dialekt (declare/set/convert)
--     SP govdesine tasindi; uygulama tek satir 'exec ... @PaketID=:P1,...' cagirir
--     ve engine-agnostic olur. PG karsiligi: public.fn_prog_stokhizmetara_paket
--     (pg/schema/70_fn_prog_stokhizmetara_paket.sql).
--
--   SONUC KUMESI (12 kolon, sirasi ONEMLI - union all iki dal):
--     ID, KOD, AD, FIYAT, KUR, KDV, KDVDURUM, IZLEME, KALAN, BIRIM, STOK, ADET
--     STOK=1 -> stok kalemi (STOKLAR/STOKFIYAT), STOK=0 -> hizmet (MASRAFGELIR/FIYATLAR)
--
--   DAVRANIS eski SQL ile BIREBIR:
--     - Hizmet dalinda BIRIM = GENINI(BOLUM=-2702, ANAHTAR='Adet') degeri.
--       Eskiden 'select @AdetID=... from GENINI' (birden fazla satirda SONUNCU)
--       kullaniliyordu; burada MAX ile tek deger alinir (pratikte tek satir).
--     - FIYAT/KALAN bulunamazsa -1 / 0.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokHizmetAra_Paket
    @PaketID  INT,
    @FiyatAdi INT,
    @DepoID   INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AdetID INT;
    SELECT @AdetID = MAX(CONVERT(INT, DEGER))
      FROM GENINI
     WHERE BOLUM = -2702 AND ANAHTAR = 'Adet';

    -- 1) Paketin STOK kalemleri
    SELECT
        ID       = ISNULL(S.ID, 0),
        S.KOD,
        AD       = S.STOKADI,
        FIYAT    = ISNULL(SF.FIYAT, -1),
        SF.KUR,
        S.KDV,
        SF.KDVDURUM,
        S.IZLEME,
        KALAN    = ISNULL((SELECT SUM(SD.KALAN) FROM STOKDURUM SD
                            WHERE SD.STOKID = S.ID AND SD.DEPOID = @DepoID), 0),
        SF.BIRIM,
        PD.STOK,
        PD.ADET
    FROM PAKETDETAY PD
         LEFT OUTER JOIN STOKLAR S    ON PD.URUNID = S.ID
         LEFT OUTER JOIN STOKFIYAT SF ON SF.STOKID = S.ID AND SF.BIRIM = PD.BIRIM
    WHERE PD.PAKETID = @PaketID
      AND PD.STOK = 1
      AND SF.FIYATADI = @FiyatAdi

    UNION ALL

    -- 2) Paketin HIZMET kalemleri (stok takibi yok: KALAN sinirsiz kabul)
    SELECT
        ID       = ISNULL(M.ID, 0),
        M.KOD,
        AD       = M.AD,
        FIYAT    = ISNULL(F.FIYAT, -1),
        F.KUR,
        ISNULL(M.KDV, 0),
        F.KDVDURUM,
        IZLEME   = 0,
        KALAN    = 999999,
        BIRIM    = @AdetID,
        PD.STOK,
        PD.ADET
    FROM PAKETDETAY PD
         LEFT OUTER JOIN MASRAFGELIR M ON PD.URUNID = M.ID
         LEFT OUTER JOIN FIYATLAR F    ON F.FIYATADI = @FiyatAdi AND F.HIZMETID = M.ID
    WHERE PD.PAKETID = @PaketID
      AND PD.STOK = 0
      AND F.FIYATADI = @FiyatAdi;
END

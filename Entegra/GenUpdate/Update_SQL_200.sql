-- Update_SQL_200: Kocan Ayarlari'nda "Alis Irsaliyesi" (TUR=10) turu listede cikmiyor.
--
-- Opsiyon > Kocan Ayarlari'ndaki Tur listesi 'ISLEMTURLERI INNER JOIN KOCANAYARLARI' ile dolar:
-- bir tur icin hic KOCANAYARLARI satiri yoksa o tur listeye gelmez, dolayisiyla eklenemez de
-- (tavuk-yumurta). Bazi musterilerde TUR=10 icin satir yok -> Alis Irsaliyesi gorunmuyor.
-- Bu betik TUR=10 icin merkez (SUBEID=-1) kocan satiri acar: kocan no = o turun max+1 (yoksa 1001),
-- baslangic no '000001', baslangic 2016-01-01, kullanimda. Satir varsa dokunmaz (idempotent).
-- Ekledigi kaydi raporlar; musteri ekranindan seri/baslangic no'yu duzenleyebilir.

SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.ISLEMTURLERI WHERE TUR = 10)
    PRINT N'Update200: ISLEMTURLERI''de TUR=10 (Alis Irsaliyesi) tanimi YOK - once islem turu tanimlanmali.';
ELSE IF EXISTS (SELECT 1 FROM dbo.KOCANAYARLARI WHERE TUR = 10)
    PRINT N'Update200: TUR=10 icin kocan satiri zaten var - atlandi.';
ELSE
BEGIN
    DECLARE @KocanNo INT = ISNULL((SELECT MAX(KOCANNO) FROM dbo.KOCANAYARLARI WHERE TUR = 10), 1000) + 1;
    INSERT INTO dbo.KOCANAYARLARI (KOCANNO, TUR, BASLANGICTARIHI, SERINO, BASLANGICNO, SIFIRLA, SUBEID, KOCANKULLAN, EKLEMETARIHI)
    VALUES (@KocanNo, 10, '2016-01-01', NULL, '000001', 0, -1, 1, GETDATE());
    PRINT N'Update200: TUR=10 (Alis Irsaliyesi) icin kocan ' + CAST(@KocanNo AS nvarchar(10)) + N' eklendi (SUBEID=-1, baslangic 000001).';
END
GO

/*
  Update_SQL_220 - Bir lotun tek SKT/URT'si olur (215 geri alinir)

  Kullanici (04.11.2026): ayni lot no farkli SKT/URT ile ayri tanim olarak
  acilmasin; bir lot numarasinin tek tanimi (tek SKT/URT'si) vardir.

  Update_SQL_215 seri no'suz lotta kart aramasini dbo.fn_SeriLot_TarihUyar
  ile lot no + tarihe baglamisti (tarih farkliysa yeni STOKSERILOT tanimi
  aciliyordu). Bu fonksiyonu kullanan nesneler:
    sp_Prog_Izleme_Yaz_Json, sp_Prog_BelgeDonusum_Uygula_Json2,
    sp_Prog_BelgeDonusum_IzlemeAktar, sp_Prog_Irs_Fat_Satir_Ekleme,
    sp_Grnt_AlisFaturaHareketIslem, sp_Api_Belge_SeriLot_Yaz_Ic
  Fonksiyon her zaman 1 donunce hepsi yeniden yalniz lot no ile arar: var
  olan lot no'ya gelen satir o tanima baglanir, yeni tanim acilmaz.
  215'in "metni degisen lot" duzeltmesi (sp_Prog_Izleme_Yaz_Json) aynen kalir.
  Nesneler yeniden yazilmaz, yalniz fonksiyon degisir.

  215 doneminde ayni lot no ile acilmis birden fazla tanim VERI olarak
  birlestirilmez (hangi tarihin dogru oldugu bilinemez; hareketler bagli).
  Sayisi ve listesi raporlanir; stok listesinden lot duzenle ile tarih
  duzeltilebilir. Program (UIzleme) bu durumda listeden secim ister.

  Tekrar calistirilabilir. Veri degistirmez.
*/
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE OR ALTER FUNCTION dbo.fn_SeriLot_TarihUyar
(
    @StokId  INT,
    @SeriNo  NVARCHAR(100),
    @KartSkt DATETIME,
    @KartUrt DATETIME,
    @Skt     DATETIME,
    @Urt     DATETIME
)
RETURNS BIT
AS
BEGIN
    -- 220: bir lotun tek SKT/URT'si olur; kart kimligi seri no / lot no'dur,
    --   tarih ayirt etmez. Imza 215'i kullanan nesneler icin korunur.
    RETURN 1;
END
GO
SET NOCOUNT ON;

DECLARE @Ikiz TABLE (STOKID INT, LOTNO NVARCHAR(100), ADET INT);
INSERT INTO @Ikiz
SELECT STOKID, LOTNO, COUNT(*)
  FROM dbo.STOKSERILOT
 WHERE ISNULL(SERINO, N'') = N'' AND ISNULL(LOTNO, N'') <> N''
 GROUP BY STOKID, LOTNO
HAVING COUNT(*) > 1;

DECLARE @Sayi INT = (SELECT COUNT(*) FROM @Ikiz);
PRINT N'Birden fazla tanimi olan lot no: ' + CAST(@Sayi AS NVARCHAR(10));

SELECT I.STOKID, S.KOD, S.STOKADI, I.LOTNO, SSL.ID AS SERILOTID, SSL.SKT, SSL.URT,
       ISNULL((SELECT SUM(D.KALAN) FROM dbo.STOKDURUMIZLEME D WHERE D.SERILOTID = SSL.ID), 0) AS BAKIYE
  FROM @Ikiz I
       INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = I.STOKID AND SSL.LOTNO = I.LOTNO AND ISNULL(SSL.SERINO, N'') = N''
       LEFT JOIN dbo.STOKLAR S ON S.ID = I.STOKID
 ORDER BY I.STOKID, I.LOTNO, SSL.ID;

-- ============================================================
-- GenDepoUpdate43  (musteri uygulama)
--
--  1) TABLOLAR: 367 STOKIZLEME, 375 STOKIZLEMEDEPO
--     Fatura satiri / tum fatura silinince STOKIZLEME + STOKIZLEMEDEPO loglanir
--     ve Geri Al ile geri yuklenir. LogGeriAl, TABLOID -> fiziksel tablo adini
--     TABLOLAR'dan cozer; bu iki kayit olmadan geri-al calismaz.
--     (Geri-al sirasi: STOKIZLEME once, STOKIZLEMEDEPO sonra -> STOKIZLEMEDEPO
--      insert trigger'i TG_StokIzlemeDurumEkle STOKDURUMIZLEME'yi yeniden kurar.)
--
--  2) sp_Prog_Kontrol_Adet_Izlemsiz / sp_Prog_Kontrol_Adet_Izlemli
--     Transfer + fatura/fis cikista tarih-bazli "o tarihte kaynak depoda yeterli
--     stok var mi" kontrolu. Model: guncel bakiye (STOKDURUM / STOKDURUMIZLEME =
--     otorite) EKSI TARIH'ten sonraki hareketler. Ileri tarihli cikis OLSA BILE
--     yalnizca o tarihe kadarki bakiye dikkate alinir.
--
--  Idempotent. Ana (musteri) DB'de calisir. Uygulama build'i de gerekir
--  (Utablo.StokCikisYeterliMi + wizard cagrilari + STOKIZLEME/DEPO loglama).
-- ============================================================
set nocount on;

-- 1) TABLOLAR kayitlari (yoksa ekle) --------------------------------------
if not exists (select 1 from dbo.TABLOLAR where TABLOID = 367)
    insert into dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    values (367, 'STOKIZLEME', N'Stok İzleme', N'Stok');

if not exists (select 1 from dbo.TABLOLAR where TABLOID = 375)
    insert into dbo.TABLOLAR (TABLOID, TABLOADI, GORUNUM, MODUL)
    values (375, 'STOKIZLEMEDEPO', N'İzleme Depo', N'Stok');

-- 2) sp_Prog_Kontrol_Adet_Izlemsiz ---------------------------------------
-- Izlemsiz (seri-lot takipsiz) urun: TARIH'te DEPO'da yeterli ADET var mi?
--   asof(T) = STOKDURUM.KALAN - SUM(giris - cikis ; FATURATARIH > T)
--   @SATIRID>0 (duzenleme): o satirin guncel etkisi geri eklenir.
exec (N'
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Kontrol_Adet_Izlemsiz
    @URUNID  int,
    @DEPOID  int,
    @TARIH   datetime,
    @ADET    float,
    @SATIRID int = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KALANNOW float =
        ISNULL((SELECT KALAN FROM dbo.STOKDURUM WHERE STOKID = @URUNID AND DEPOID = @DEPOID), 0);

    DECLARE @SONRA float = 0;
    SELECT @SONRA =
         ISNULL(SUM(CASE WHEN FB.GIRISDEPO = @DEPOID THEN F.ADET ELSE 0 END), 0)
       - ISNULL(SUM(CASE WHEN FB.CIKISDEPO = @DEPOID THEN F.ADET ELSE 0 END), 0)
    FROM dbo.FATURA F
    INNER JOIN dbo.FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE F.URUNID = @URUNID
      AND FB.FATURATARIH > @TARIH
      AND (@SATIRID <= 0 OR F.ID <> @SATIRID);

    DECLARE @SATIRETKI float = 0;
    IF @SATIRID > 0
        SELECT @SATIRETKI =
             ISNULL(SUM(CASE WHEN FB.GIRISDEPO = @DEPOID THEN F.ADET ELSE 0 END), 0)
           - ISNULL(SUM(CASE WHEN FB.CIKISDEPO = @DEPOID THEN F.ADET ELSE 0 END), 0)
        FROM dbo.FATURA F
        INNER JOIN dbo.FATBASLIK FB ON FB.ID = F.FATBASID
        WHERE F.ID = @SATIRID;

    DECLARE @ASOF float = @KALANNOW - @SONRA - @SATIRETKI;

    SELECT YETERLI = CASE WHEN @ASOF >= @ADET THEN 1 ELSE 0 END,
           KALAN   = @ASOF,
           ISTENEN = @ADET;
END;
');

-- 3) sp_Prog_Kontrol_Adet_Izlemli ----------------------------------------
-- Izlemli (seri-lot takipli) urun: TARIH'te DEPO'da yeterli lot/ADET var mi?
--   asof(T) = STOKDURUMIZLEME.KALAN - SUM(STOKIZLEMEDEPO.ADET ; FATURATARIH > T)
--   STOKIZLEMEDEPO.ADET isaretli (giris +, cikis -). @SERILOTID>0 -> tek lot;
--   0 -> urun+depo tum lotlar toplami. @SATIRID>0 -> satirin etkisi geri eklenir.
--   (Not: STOKIZLEMEDEPO gecmisi silinen hareketlerde eksilebildigi icin gecmisi
--    toplamak yerine guncele demirleyip GELECEGI geri sararız.)
exec (N'
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Kontrol_Adet_Izlemli
    @URUNID    int,
    @DEPOID    int,
    @TARIH     datetime,
    @ADET      float,
    @SATIRID   int = 0,
    @SERILOTID int = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KALANNOW float =
        ISNULL((SELECT SUM(KALAN) FROM dbo.STOKDURUMIZLEME
                WHERE STOKID = @URUNID AND DEPOID = @DEPOID
                  AND (@SERILOTID <= 0 OR SERILOTID = @SERILOTID)), 0);

    DECLARE @SONRA float = 0;
    SELECT @SONRA = ISNULL(SUM(SD.ADET), 0)
    FROM dbo.STOKIZLEME SI
    INNER JOIN dbo.STOKIZLEMEDEPO SD ON SD.IZLEMID = SI.ID
    INNER JOIN dbo.FATBASLIK FB ON FB.ID = SI.BASLIKID
    WHERE SI.STOKID = @URUNID
      AND SD.DEPOID = @DEPOID
      AND FB.FATURATARIH > @TARIH
      AND (@SERILOTID <= 0 OR SI.SERILOTID = @SERILOTID)
      AND (@SATIRID   <= 0 OR SI.SATIRID   <> @SATIRID);

    DECLARE @SATIRETKI float = 0;
    IF @SATIRID > 0
        SELECT @SATIRETKI = ISNULL(SUM(SD.ADET), 0)
        FROM dbo.STOKIZLEME SI
        INNER JOIN dbo.STOKIZLEMEDEPO SD ON SD.IZLEMID = SI.ID
        WHERE SI.STOKID = @URUNID
          AND SD.DEPOID = @DEPOID
          AND SI.SATIRID = @SATIRID
          AND (@SERILOTID <= 0 OR SI.SERILOTID = @SERILOTID);

    DECLARE @ASOF float = @KALANNOW - @SONRA - @SATIRETKI;

    SELECT YETERLI = CASE WHEN @ASOF >= @ADET THEN 1 ELSE 0 END,
           KALAN   = @ASOF,
           ISTENEN = @ADET;
END;
');

-- ============================================================
-- GenDepoUpdate87.sql
-- BELGE DONUSUM SP PLANI - ON KOSUL 1 SONUCU: tek-satir varsayan trigger'lar
--   set-bazliya cevrildi.
--
-- NEDEN (bkz. BelgeDonusum_Trigger_Envanteri.txt):
--   Plan hedef detay satirlarinin SET BAZLI eklenmesini ongoruyor. Asagidaki iki
--   trigger 'inserted' icinden SKALER atama yapip TEK satiri guncelliyordu; cok
--   satirli bir INSERT'te geri kalan satirlar sessizce islenmeden kaliyordu.
--   Bugun sorun cikmamasinin tek sebebi Delphi'nin satirlari TEK TEK eklemesi.
--   Bu yalniz donusum icin degil, cok satirli insert yapan HER ekran icin
--   mevcut (gizli) bir veri hatasidir.
--
-- DAVRANIS: tek satirli INSERT'te sonuc AYNI. Cok satirli INSERT'te artik TUM
--   satirlar isleniyor (onceden yalnizca rastgele biri).
--
-- KAPSAM DISI - trg_Siparis_Aktarim (SIPARIS):
--   O da skaler atama yapiyor ama gorevi bambaska: baska bir veritabaninda
--   (AlpAlk) REHBER/STOKLAR/SIPARIS/SIPARISDETAY kayitlari uretiyor, 135 satir,
--   dogasi geregi belge-basina. Set-bazliya cevirmek ayri bir is.
--   KURAL: SIPARIS BASLIGI HER ZAMAN TEK SATIR eklenmeli (428 rotasinda toplu
--   baslik uretimi yapilmayacak). Bu kisit rota matrisine yazildi.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- FATURA: masraf/gelir satirinda MASRAFID bos ise URUNID ile doldur.
--   Eski hali: SELECT @FATBASID=I.FATBASID, ... FROM inserted I  -> tek satir.
-- ============================================================
CREATE OR ALTER TRIGGER [dbo].[Trg_Fatura_MasrafID_Guncelle]
ON [dbo].[FATURA]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Set bazli: eklenen TUM satirlar islenir. Kosul eskisiyle ayni
    --   (MASRAFID bos VE TUR = 0, yani masraf/gelir satiri).
    UPDATE F
       SET MASRAFID = F.URUNID
      FROM FATURA F
           INNER JOIN inserted I ON I.ID = F.ID
     WHERE ISNULL(I.MASRAFID, 0) = 0
       AND ISNULL(I.TUR, 0) = 0;
END
GO

-- ============================================================
-- URETIMEMRI: Trg_UretimEmri_LOTNO_SKT_Guncelle -- CANLI BOZUKLUK, TASINDI
--
-- BULGU: bu trigger I.URT / I.SKT kolonlarina bakiyor ama URETIMEMRI tablosunda
--   BU KOLONLAR YOK; URT ve SKT URETIMEMRI_USER tablosuna tasinmis. Sonuc:
--   URETIMEMRI'ye yapilan HER INSERT/UPDATE "Invalid column name 'SKT'" ile
--   basarisiz oluyordu (dogrulandi; tablodaki son kayit 05.07.2026).
--   Yani uretim emri olusturma tamamen kirikti - donusum planindan bagimsiz,
--   canli bir hata.
--
-- COZUM: kural verinin bulundugu tabloya tasindi. Eski trigger DUSURULUR,
--   ayni kural URETIMEMRI_USER uzerinde set-bazli olarak kurulur.
--   Dogru tetikleme zamani da budur: URT zaten URETIMEMRI_USER'a yazilir,
--   URETIMEMRI'ye degil - eski yerinde URT hic dolmamis olurdu.
--
-- KURAL (eskisiyle ayni): URT doluysa ve stok kategorisi 7 ise SKT = URT + 5 yil,
--   degilse SKT = NULL.
-- ============================================================
DROP TRIGGER IF EXISTS [dbo].[Trg_UretimEmri_LOTNO_SKT_Guncelle];
GO

CREATE OR ALTER TRIGGER [dbo].[Trg_UretimEmriUser_SKT_Guncelle]
ON [dbo].[URETIMEMRI_USER]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Sonsuz dongu olmasin: SKT'nin kendisi degistiyse tekrar hesaplama.
    --   (recursive triggers KAPALI ama UPDATE(SKT) kontrolu yine de acik yazilmis
    --    bir guvenlik; URT degismediyse is yok.)
    IF UPDATE(SKT) AND NOT UPDATE(URT) RETURN;

    UPDATE UU
       SET SKT = CASE WHEN S.KATEGORI = 7 THEN DATEADD(YEAR, 5, I.URT) ELSE NULL END
      FROM URETIMEMRI_USER UU
           INNER JOIN inserted   I ON I.ID = UU.ID
           INNER JOIN URETIMEMRI U ON U.ID = I.ID
           INNER JOIN STOKLAR    S ON S.ID = U.STOKID
     WHERE I.URT IS NOT NULL;
END
GO

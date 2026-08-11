-- ============================================================
-- GenDepoUpdate126.sql
-- sp_Prog_Fatura_Silinebilir_Mi : IZLEME kuralina DEPO ESLESMESI
--
-- HATA (10.08.2026): depo1 -> depo2 transferi silinemiyordu; engel olarak AYNI GUN
--   depo1'den yapilmis bir satis faturasi gosteriliyordu ("lot seri no'lu urun
--   cikisi yapilmis"). Oysa o fatura transferin koydugu stogu (depo2) kullanmiyor;
--   iki hareket birbirinden bagimsiz.
--
-- NEDEN: kural yalnizca LOT esitligine ve gun bazli tarihe bakiyordu:
--     STOKIZLEME SI1.SERILOTID IN (bu satirin lotlari) AND tarih >= ...
--   Depo bilgisi hic devrede degildi.
--
-- COZUM: asagi-akis cikisi, BU BELGENIN STOK KOYDUGU depodan yapilmis olmali:
--     bu satir  : STOKIZLEMEDEPO.ADET > 0  -> giren depo
--     asagi-akis: STOKIZLEMEDEPO.ADET < 0  -> cikan depo
--     ikisi ayni DEPOID olmali.
--   Gun bazli tarih kurali ve diger kontroller (EBELGE/KULLANIM/UTS/DONUSUM) AYNEN durur.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Fatura_Silinebilir_Mi
  @FatBasID        int = 0,
  @SatirID         int = 0,
  @KilitKaldirildi bit = 0
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH Satirlar AS (
    SELECT F.ID AS SATIRID, F.FATBASID, F.URUNID, F.IZLEME, F.ADET,
           FB.TUR, FB.FATURATARIH, FB.EFATURADURUM
    FROM FATURA F
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE (@SatirID > 0 AND F.ID = @SatirID)
       OR (@SatirID = 0 AND F.FATBASID = @FatBasID)
  )
  SELECT TOP 1 SILINEBILIR, NEDEN, BELGEAD, BELGETARIH, BELGENO
  FROM (
    -- 0) EBELGE: islem goren e-fatura/e-arsiv (EFATURADURUM 2/52) silinemez (override haric)
    SELECT 0 AS SILINEBILIR, 'EBELGE' AS NEDEN,
      CAST(NULL AS varchar(100)) AS BELGEAD, CAST(NULL AS datetime) AS BELGETARIH,
      CAST(NULL AS varchar(50)) AS BELGENO, 0 AS SIRA
    FROM Satirlar S
    WHERE @KilitKaldirildi = 0 AND S.EFATURADURUM IN (2,52)

    UNION ALL
    -- 1) KULLANIM: izlemesiz giris satiri; urun asagi-akista cikis/tuketim yapilmis
    SELECT 0, 'KULLANIM',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FB2.TUR) AS varchar(100)),
      CAST(FB2.FATURATARIH AS datetime), CAST(FB2.FATURANO AS varchar(50)), 1
    FROM Satirlar S
    INNER JOIN FATURA F2   ON F2.URUNID = S.URUNID
    INNER JOIN FATBASLIK FB2 ON FB2.ID = F2.FATBASID
    WHERE S.IZLEME = 0
      AND S.TUR IN (3,6,101,102,10,11,12,20,99)
      AND NOT (S.TUR = 6 AND S.ADET < 0)
      AND (FB2.TUR IN (4,14,15,16,20,119) OR (FB2.TUR = 6 AND F2.ADET < 0))
      -- GUN bazinda AYNI GUN DAHIL (>=): FATURATARIH'in saati KAYIT ANI'dir, fiziksel
      -- akisi yansitmaz (mal sabah cikar, alis faturasi aksam islenir -> cikis saati
      -- giristen KUCUK kalir ve saatli '>' kacirirdi). Kendi belgesi haric.
      AND CAST(FB2.FATURATARIH AS date) >= CAST(S.FATURATARIH AS date)
      AND FB2.ID <> S.FATBASID

    UNION ALL
    -- 2) IZLEME: izlemeli satir; seri/lot asagi-akista cikmis
    SELECT 0, 'IZLEME',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = SI1.BELGETUR) AS varchar(100)),
      CAST(FBz.FATURATARIH AS datetime), CAST(FBz.FATURANO AS varchar(50)), 2
    FROM Satirlar S
    -- BU satirin izlem kayitlari ve STOGU NEREYE KOYDUGU (ADET>0 = giren depo)
    INNER JOIN STOKIZLEME SIb      ON SIb.SATIRID = S.SATIRID
    INNER JOIN STOKIZLEMEDEPO SDb  ON SDb.IZLEMID = SIb.ID AND SDb.ADET > 0
    -- AYNI LOT'u kullanan asagi-akis izlem kaydi ve STOGU NEREDEN ALDIGI (ADET<0)
    INNER JOIN STOKIZLEME SI1      ON SI1.SERILOTID = SIb.SERILOTID
    INNER JOIN STOKIZLEMEDEPO SDz  ON SDz.IZLEMID = SI1.ID AND SDz.ADET < 0
    INNER JOIN FATURA Fz    ON Fz.ID = SI1.SATIRID
    INNER JOIN FATBASLIK FBz ON FBz.ID = SI1.BASLIKID
    WHERE S.IZLEME <> 0
      -- DEPO ESLESMESI: cikis, BU BELGENIN STOK KOYDUGU depodan yapilmis olmali.
      --   Yoksa (ornek: transfer depo1 -> depo2 iken ayni gun depo1'den satis) alakasiz
      --   bir belge silmeyi engelliyordu.
      AND SDz.DEPOID = SDb.DEPOID
      AND S.TUR IN (3,6,101,102,10,11,12,20,99)
      AND NOT (S.TUR = 6 AND S.ADET < 0)
      AND SI1.BELGETUR IN (4,14,15,16,20,101,119)
      -- KULLANIM ile ayni: gun bazinda, ayni gun dahil, kendi belgesi haric.
      AND CAST(FBz.FATURATARIH AS date) >= CAST(S.FATURATARIH AS date)
      AND FBz.ID <> S.FATBASID

    UNION ALL
    -- 3) UTS BILDIRIM: izlemeli satirin STOKIZLEME kaydinda YER/YERID dolu (bildirilmis)
    SELECT 0, 'UTSBILDIRIM',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 3
    FROM Satirlar S
    INNER JOIN STOKIZLEME SI ON SI.STOKID = S.URUNID AND SI.SATIRID = S.SATIRID
    WHERE S.IZLEME <> 0
      AND ISNULL(SI.YER,0) > 0 AND ISNULL(SI.YERID,0) > 0

    UNION ALL
    -- 4) DONUSUM: bu belge satiri baska belgeye donusturulmus (YERI/YERID linki)
    --    Kodlar ROTA MATRISINDEN okunur - donusumun zaten tek kaynagi.
    --    Eskiden elle sayiliyordu (408/411/469/462/468 + TUR IN (10,14,109,119))
    --    ve rota matrisindeki FATURA kaynakli 10 rotanin ALTISI kapsam disiydi:
    --      425/426 uretim fisi -> irsaliye/fatura  (TUR=6 listede bile yoktu)
    --      427 alis irsaliyesi -> alis fisi
    --      424 satis irsaliyesi -> satis fisi
    --      461 gelen konsinye -> alis faturasi
    --      472 giden konsinye -> satis fisi
    --    Ayrica 469 diye bir rota YOK (olu kod). Sonuc: bu donusumler
    --    yapildiktan sonra kaynak belge silinebiliyor, zincir kopuyordu.
    SELECT 0, 'DONUSUM',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FBD.TUR) AS varchar(100)),
      CAST(FBD.FATURATARIH AS datetime),
      CAST(FBD.FATURANO AS varchar(50)), 4
    FROM Satirlar S
    INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
            ON R.KaynakDetayTablo = 'FATURA'
           AND R.KalanHedefTablo  = 'FATURA'
           AND R.KaynakTur        = S.TUR
    INNER JOIN FATURA FD     ON FD.YERID = S.SATIRID AND FD.YERI = R.DonusumTuru
    INNER JOIN FATBASLIK FBD ON FBD.ID = FD.FATBASID

    UNION ALL
    -- 99) ENGEL YOK -> silinebilir
    SELECT 1, '',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 99
  ) X
  ORDER BY SIRA;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Fatura_Silinebilir_Mi TO gentegre_api;
GO

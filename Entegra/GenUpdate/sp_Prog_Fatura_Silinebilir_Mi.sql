-- ============================================================================
-- sp_Prog_Fatura_Silinebilir_Mi  (MSSQL)
--   Fatura/irsaliye/fis/konsinye/uretim SILME on-kontrolu (server-side). Iki mod:
--     @SatirID > 0  -> tek FATURA satiri
--     @SatirID = 0  -> @FatBasID altindaki TUM satirlar (biri engelliyse toptan RED)
--   Hep TEK satir doner: en oncelikli engel (yoksa SILINEBILIR=1).
--   Kolonlar: SILINEBILIR(0/1), NEDEN, BELGEAD, BELGETARIH, BELGENO.
--   Kontroller: EBELGE(oncelik) / KULLANIM / IZLEME / UTSBILDIRIM / DONUSUM / IADE.
--   @KilitKaldirildi=1 -> e-belge (islem goren) engelini ATLA (wizard admin override).
--   Satirin kaynak belgesi (iade -> iade edilen satis) engel sayilmaz; kaynagin da
--   kaynagi (satis faturasi <- satis irsaliyesi) dahil, donusum zinciri boyunca
--   (Update_SQL_210).
--   NOT: KILIT (MODUL/devir) app-side KilitKontrolEt'te (helper cagirir) - burada YOK.
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Fatura_Silinebilir_Mi
  @FatBasID        int = 0,
  @SatirID         int = 0,
  @KilitKaldirildi bit = 0
AS
BEGIN
  SET NOCOUNT ON;

  -- Donusum zinciri ATALARI (Update_SQL_210): satirin izleme kaydindan DONUSID
  --   ile geriye (iade <- satis faturasi <- satis irsaliyesi). Bunlar satirin
  --   KAYNAGIDIR, asagi-akis cikisi degil; IZLEME kontrolunde haric tutulur.
  --   Eskiden yalniz dogrudan kaynak haric tutuluyordu: irsaliyeden donusmus
  --   faturanin iadesi, ayni gun kesilen irsaliye yuzunden silinemiyordu.
  DECLARE @Ata TABLE (KOKSATIRID int NOT NULL, IZLEMID int NOT NULL,
                      PRIMARY KEY (KOKSATIRID, IZLEMID));
  ;WITH Zincir AS (
    SELECT SI.SATIRID AS KOKSATIRID, SI.DONUSID AS IZLEMID, 1 AS DERINLIK
    FROM STOKIZLEME SI
    INNER JOIN FATURA F ON F.ID = SI.SATIRID
    WHERE ((@SatirID > 0 AND F.ID = @SatirID) OR (@SatirID = 0 AND F.FATBASID = @FatBasID))
      AND ISNULL(SI.DONUSID, 0) > 0
    UNION ALL
    SELECT Z.KOKSATIRID, P.DONUSID, Z.DERINLIK + 1
    FROM Zincir Z
    INNER JOIN STOKIZLEME P ON P.ID = Z.IZLEMID
    WHERE ISNULL(P.DONUSID, 0) > 0 AND Z.DERINLIK < 20
  )
  INSERT @Ata (KOKSATIRID, IZLEMID)
  SELECT DISTINCT KOKSATIRID, IZLEMID FROM Zincir
  OPTION (MAXRECURSION 25);

  ;WITH Satirlar AS (
    SELECT F.ID AS SATIRID, F.FATBASID, F.URUNID, F.IZLEME, F.ADET,
           FB.TUR, FB.FATURATARIH, FB.EFATURADURUM,
           -- Satirin KAYNAK belgesi (iade: YERID=iade edilen satis satiri, ANAKAYITID=satis
           -- basligi). Kaynak belge asagi-akis cikis DEGILDIR -> KULLANIM/IZLEME'de haric.
           ISNULL(F.YERID, 0) AS KAYNAKSATIRID, ISNULL(FB.ANAKAYITID, 0) AS KAYNAKBASID,
           -- Kaynagin kaynagi: kaynak satir irsaliyeden donusmusse (408/411) o
           -- irsaliye satiri da kaynaktir (Update_SQL_210; izlemesiz KULLANIM icin).
           ISNULL(FK.YERID, 0) AS KAYNAK2SATIRID
    FROM FATURA F
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    LEFT JOIN FATURA FK ON FK.ID = F.YERID AND F.YERI IN (416, 417)
                       AND FK.YERI IN (408, 411)
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
      AND F2.ID <> S.KAYNAKSATIRID AND FB2.ID <> S.KAYNAKBASID
      AND F2.ID <> S.KAYNAK2SATIRID

    UNION ALL
    -- 2) IZLEME: izlemeli satir; seri/lot asagi-akista cikmis
    SELECT 0, 'IZLEME',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = SI1.BELGETUR) AS varchar(100)),
      CAST(FBz.FATURATARIH AS datetime), CAST(FBz.FATURANO AS varchar(50)), 2
    FROM Satirlar S
    INNER JOIN STOKIZLEME SI1 ON SI1.SERILOTID IN
         (SELECT SERILOTID FROM STOKIZLEME SI2 WHERE SI2.SATIRID = S.SATIRID)
    INNER JOIN FATURA Fz    ON Fz.ID = SI1.SATIRID
    INNER JOIN FATBASLIK FBz ON FBz.ID = SI1.BASLIKID
    WHERE S.IZLEME <> 0
      AND S.TUR IN (3,6,101,102,10,11,12,20,99)
      AND NOT (S.TUR = 6 AND S.ADET < 0)
      AND SI1.BELGETUR IN (4,14,15,16,20,101,119)
      -- KULLANIM ile ayni: gun bazinda, ayni gun dahil, kendi belgesi haric.
      AND CAST(FBz.FATURATARIH AS date) >= CAST(S.FATURATARIH AS date)
      AND FBz.ID <> S.FATBASID
      AND Fz.ID <> S.KAYNAKSATIRID AND FBz.ID <> S.KAYNAKBASID
      AND NOT EXISTS (SELECT 1 FROM @Ata A
                      WHERE A.KOKSATIRID = S.SATIRID AND A.IZLEMID = SI1.ID)

    UNION ALL
    -- 3) UTS BILDIRIM: izlemeli satirin STOKIZLEME kaydinda YER/YERID dolu (bildirilmis)
    SELECT 0, 'UTSBILDIRIM',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 3
    FROM Satirlar S
    INNER JOIN STOKIZLEME SI ON SI.STOKID = S.URUNID AND SI.SATIRID = S.SATIRID
    WHERE S.IZLEME <> 0
      AND ISNULL(SI.YER,0) > 0 AND ISNULL(SI.YERID,0) > 0

    UNION ALL
    -- 4) DONUSUM: irsaliye/konsinye baska belgeye donusturulmus (YERID linki)
    SELECT 0, 'DONUSUM',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 4
    FROM Satirlar S
    INNER JOIN FATURA FD ON FD.YERID = S.SATIRID
      AND ((S.TUR = 10  AND FD.YERI = 408)
        OR (S.TUR = 14  AND FD.YERI = 411)
        OR (S.TUR = 109 AND FD.YERI = 469)
        OR (S.TUR = 119 AND FD.YERI IN (462,468)))
    WHERE S.TUR IN (10,14,109,119)

    UNION ALL
    -- 5) IADE: bu belgeden/satirdan iade (416 alis-iade, 417 satis-iade) veya fiyat farki
    --    (418/419) belgesi uretilmis. Kaynak silinirse iade sahipsiz kalir -> once iade silinmeli.
    --    Satir modu: yalniz o satira bagli (YERID) iade satirlari; belge modu: ANAKAYITID de.
    SELECT 0, 'IADE',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FBi.TUR) AS varchar(100)),
      CAST(FBi.FATURATARIH AS datetime), CAST(FBi.FATURANO AS varchar(50)), 5
    FROM Satirlar S
    INNER JOIN FATURA Fi    ON Fi.YERID = S.SATIRID AND Fi.YERI IN (416,417,418,419)
    INNER JOIN FATBASLIK FBi ON FBi.ID = Fi.FATBASID
    WHERE FBi.ID <> S.FATBASID

    UNION ALL
    SELECT 0, 'IADE',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FBa.TUR) AS varchar(100)),
      CAST(FBa.FATURATARIH AS datetime), CAST(FBa.FATURANO AS varchar(50)), 5
    FROM FATBASLIK FBa
    WHERE @SatirID = 0 AND @FatBasID > 0
      AND FBa.ANAKAYITID = @FatBasID AND FBa.ID <> @FatBasID

    UNION ALL
    -- 99) ENGEL YOK -> silinebilir
    SELECT 1, '',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 99
  ) X
  ORDER BY SIRA;
END

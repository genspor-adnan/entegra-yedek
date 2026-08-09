-- ============================================================
-- GenDepoUpdate121.sql
-- sp_Prog_Cari_Liste_Json2 : Detay + Son/Sik Arananlar birlikte patliyordu
--
-- HATA (09.08.2026): Cari listede "Detay" isaretliyken "Son Arananlar"a
--   basilinca
--     The multi-part identifier "KA.DEGISTIRMETARIHI" could not be bound.
--
-- NEDEN: Detay (CRM) sarmalamasi sorguyu 'select * from ( ... ) as cc' icine
--   aliyor. Dis kapsamda KULLANICI_ARAMA takma adi (KA) YOK; KA kolonlari
--   select listesinde de yok (liste kolonlarini uygulama gonderiyor).
--   ORDER BY ise sarmalamadan sonra ekleniyor ve hala KA.* diyordu.
--
-- COZUM: sarmalanmis halde siralama iliskili alt sorguyla yapiliyor
--   (cc.ID uzerinden KULLANICI_ARAMA'ya bakarak). Sonuc kumesinin bicimi
--   DEGISMEZ - select listesine kolon eklenmedi.
--
-- Ayrica LATENT bir hata kapatildi: @KulId/@Modul NULL ise KA join'i hic
--   eklenmiyor ama ORDER BY KA.* yine yaziliyordu. O durumda artik
--   ORDER BY 1 kullaniliyor.
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Cari_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR = Paramst)
    @Kosullar NVARCHAR(MAX)             -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL (typed default korunur). ----
    DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @Variant       SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Variant')      AS SMALLINT), 0);
    DECLARE @TopN          INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')         AS INT), 200);
    DECLARE @Mod           SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')          AS SMALLINT), 4);
    DECLARE @IlgiliArama   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IlgiliArama')  AS BIT), 0);
    DECLARE @KulId         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId')        AS INT);
    DECLARE @Modul         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul')        AS INT), 22);
    DECLARE @CRM           BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CRM')          AS BIT), 0);
    DECLARE @AraFirma      NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.AraFirma');
    DECLARE @AraYetkili    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.AraYetkili');
    DECLARE @AraKod        NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.AraKod');
    DECLARE @AraOzelKod    NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.AraOzelKod');
    DECLARE @Arailler      NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Arailler');
    DECLARE @TemsilciAd    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.TemsilciAd');
    DECLARE @TemsilciID    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TemsilciID')   AS INT);
    DECLARE @GrupID        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GrupID')       AS INT);
    DECLARE @BolgeID       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.BolgeID')      AS INT);
    DECLARE @KategoriID    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KategoriID')   AS INT);
    DECLARE @SinifID       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SinifID')      AS INT);
    DECLARE @Pasifler      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasifler')     AS BIT), 0);
    DECLARE @AksiyonFrame  BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AksiyonFrame') AS BIT), 0);
    DECLARE @Potansiyel    BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Potansiyel')   AS BIT), 0);
    DECLARE @SubeList      NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeList');
    DECLARE @TekSubeTum    INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TekSubeTum')   AS INT), 0);
    DECLARE @SubeId        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeId')       AS INT);
    DECLARE @EkipmanFiltre BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.EkipmanFiltre') AS BIT), 0);
    DECLARE @AnalizWhere   SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AnalizWhere')  AS SMALLINT), 0);
    DECLARE @OrderCol      SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.OrderCol')     AS SMALLINT), 0);

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL   NVARCHAR(MAX);
    DECLARE @Top   NVARCHAR(30) = CASE WHEN @TopN > 0
                                       THEN N'top (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                       ELSE N'' END;
    DECLARE @BASTARIH DATETIME =
            CONVERT(VARCHAR(4), YEAR(GETDATE())) + '-01-01 00:00:00';

    -- --------- FROM iskeleti (iki base memo) -----------------
    IF @Variant = 1
    BEGIN
        -- SQLMemoBA: BORC/ALACAK/TAKIPTE/IRSALIYE toplama alt-sorgusu (app'teki DFM memosu ile birebir)
        SET @SQL = N'
    SELECT ' + @Top + @SelectList + N'
    FROM(
        select REHBERID,
               TOPLAM_BORC   = SUM(isnull(BORC,0)),
               TOPLAM_ALACAK = SUM(isnull(ALACAK,0)),
               TAKIPTE       = ABS(SUM(ISNULL(TAKIPTE,0))),
               IRSALIYE      = ABS(SUM(ISNULL(IRSALIYE,0))),
               KUR           = isnull(KUR,''TL'')
        from (
            SELECT REHBERID,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) AS BORC,
                   0 AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM FATBASLIK F
            WHERE isnull(F.DURUM,0)<>6 and (F.TUR in (15,16,17)) AND FATURATARIH >= @pBasTarih
            GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end
            UNION ALL
            SELECT FB.REHBERID, 0 AS BORC, 0 AS ALACAK,
                   CASE WHEN FB.EKSTREDEKULLAN = 1 THEN FB.DOVIZ_CINSI ELSE FB.KUR END AS KUR,
                   0 AS TAKIPTE,
                   CAST(SUM(CASE WHEN FB.EKSTREDEKULLAN = 1 THEN CASE WHEN F.DOVIZ_KURU <> ''TL'' THEN F.DOVIZ_BIRIMFIYAT * (1 - ISKONTO / 100.0) * (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * (1 + ISNULL(F.KDV, 10) / 100.0) ELSE ((F.ISKONTOLUBRMFIYAT * (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * (1 + ISNULL(F.KDV, 10) / 100.0)))/FB.DOVIZKUR END ELSE F.ISKONTOLUBRMFIYAT * (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * (1 + ISNULL(F.KDV, 10) / 100.0) END) AS DECIMAL(18,2)) AS IRSALIYE
            FROM FATBASLIK FB
                 INNER JOIN FATURA F ON F.FATBASID = FB.ID
                 LEFT JOIN (SELECT YERID, SUM(ADET) AS FATURA_ADET FROM FATURA WHERE YERI IN (411,424) GROUP BY YERID ) F1 ON F1.YERID = F.ID
            WHERE ISNULL(FB.DURUM, 0) <> 6 AND FB.TUR = 14
            GROUP BY FB.REHBERID, FB.EKSTREDEKULLAN,FB.DOVIZ_CINSI,FB.KUR
            UNION ALL
            SELECT REHBERID, 0 AS BORC,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) AS FATURA_ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM FATBASLIK F
            WHERE isnull(F.DURUM,0)<>6 and (F.TUR in (8,11,12,13)) AND FATURATARIH >= @pBasTarih
            GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end
            UNION ALL
            SELECT REHBERID,
                   SUM(case when ISNULL(K.BORC,0)>0 and EKSTREDEKULLAN=1 then K.DOVIZ_TUTARI else K.BORC end) AS BORC,
                   SUM(case when ISNULL(K.ALACAK,0)>0 and EKSTREDEKULLAN=1 then K.DOVIZ_TUTARI else K.ALACAK end) AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM KASA K
            WHERE TUR not between 60 and 79 AND ISLEMTARIHI >= @pBasTarih
            GROUP BY K.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end
            UNION ALL
            SELECT CH.REHBERID,
                   BORC   = sum(Case when CH.ISLEM in(140,131,132,133,134,137) then (case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TUTAR,0)end) else 0 end),
                   ALACAK = sum(Case when CH.ISLEM in(130,141) then (case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TUTAR,0)end) else 0 end),
                   KUR    = case when CH.EKSTREDEKULLAN=1 then CH.KUR else isnull(C.KUR,''TL'')end,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID
            WHERE CH.ISLEM in(130,131,132,134,137,140,141) and CH.TARIH >= @pBasTarih
            GROUP BY CH.REHBERID,CH.ISLEM,CH.EKSTREDEKULLAN,case when CH.EKSTREDEKULLAN=1 then CH.KUR else isnull(C.KUR,''TL'')end
            UNION ALL
            SELECT C.REHBERID, BORC = 0, ALACAK = 0,
                   KUR = case when C.EKSTREDEKULLAN=1 then C.DOVIZ_KURU else isnull(C.KUR,''TL'') end,
                   TAKIPTE = SUM(Case when C.TUR in(131,132,133,134,137) then (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end)-sum(Case when C.TUR in(130) then (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end),
                   IRSALIYE = 0
            FROM CEKLER C
            WHERE C.CEKSENET IN (101,121) AND C.TUR IN (130,131,132,133,134,135,138)
                  AND EXISTS(SELECT * FROM CEKHAREKET CH WHERE CH.CEKSENETLERID = C.ID)
            GROUP BY C.REHBERID,C.EKSTREDEKULLAN,C.DOVIZ_KURU,isnull(C.KUR,''TL'')
            UNION ALL
            SELECT REHBERID, 0 AS BORC,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TUTARI ELSE TUTAR END) AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM SENETLER S
            WHERE TUR = 24 AND TARIH >= @pBasTarih
            GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR END
            UNION ALL
            SELECT REHBERID,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TUTARI ELSE TUTAR END) AS BORC,
                   0 AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM SENETLER S
            WHERE TUR = 34 AND TARIH >= @pBasTarih
            GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end
        ) as asd
        group by REHBERID,KUR
    ) AS DSA
        INNER JOIN REHBER R ON DSA.REHBERID=R.ID
         left outer join REHBER P on R.ID = P.BAGID and
             1 = CASE WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 1 THEN 1
                      WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 0 AND isnull(P.STATU,1) = 1 THEN 1
                      ELSE 0 END ';
    END
    ELSE
    BEGIN
        -- SQLMemo: normal. P join = ilgili (yetkili) arama; @IlgiliArama app'te Param.
        SET @SQL = N'
    SELECT ' + @Top + @SelectList + N'
    FROM REHBER R
         left outer join REHBER P on R.ID = P.BAGID and
             1 = CASE WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 1 THEN 1
                      WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 0 AND isnull(P.STATU,1) = 1 THEN 1
                      ELSE 0 END ';
    END;

    -- --------- ortak trailing join'ler (SorguyaTabloEkle) ----
    SET @SQL = @SQL + N'
        LEFT OUTER JOIN REHBER R2 WITH (NOLOCK) ON R2.ID = R.TEMSILCI
        OUTER APPLY ( SELECT top 1 RB.BILGI FROM REHBERBILGI RB WITH (NOLOCK)
                      INNER JOIN REHBERAYAR RA WITH (NOLOCK) ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10
                      WHERE RB.YER_ID = R.ID ) X1 ';

    -- @Mod=3/5: Son/Sik -> KULLANICI_ARAMA inner join (MODUL bazli, 1:1 unique KULID,MODUL,KAYITID)
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
        SET @SQL = @SQL + N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = R.ID AND KA.KULID = '
                 + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' ';

    -- --------- ortak WHERE cekirdegi (SorguyaTabloEkle) ------
    SET @SQL = @SQL + N' where R.GRUP<>334 and R.GRUP<>335 and R.ID > 1 ';

    -- --------- @Mod bazli WHERE alt-kumeleri -----------------
    IF @Mod = 4
    BEGIN
        -- JvTimer1Timer: tum arama kutulari
        IF @AraFirma IS NOT NULL AND @AraFirma <> N''
            SET @SQL = @SQL + N' and ( R.FIRMA LIKE N''%'' + @pFirma + N''%'' OR X1.BILGI LIKE N''%'' + @pFirma + N''%'' ) ';
        IF @AraYetkili IS NOT NULL AND @AraYetkili <> N''
            SET @SQL = @SQL + N' and P.FIRMA LIKE N''%'' + @pYetkili + N''%'' ';
        IF @AraKod IS NOT NULL AND @AraKod <> N''
            SET @SQL = @SQL + N' and R.KOD LIKE N''%'' + @pKod + N''%'' ';

        IF @AksiyonFrame = 1 AND @Potansiyel = 0
            SET @SQL = @SQL + N' and R.GRUP = 1 ';
        ELSE
        BEGIN
            IF @GrupID IS NOT NULL AND @GrupID > 0
                SET @SQL = @SQL + N' and R.GRUP = ' + CAST(@GrupID AS NVARCHAR(20)) + N' ';
            ELSE
                SET @SQL = @SQL + N' and R.GRUP<>334 and R.GRUP<>335 ';
            IF @Potansiyel = 0
                SET @SQL = @SQL + N' and R.GRUP > 1 ';
        END;

        IF @BolgeID IS NOT NULL AND @BolgeID > 0
            SET @SQL = @SQL + N' and R.BOLGE = ' + CAST(@BolgeID AS NVARCHAR(20)) + N' ';
        IF @Arailler IS NOT NULL AND @Arailler <> N''
            SET @SQL = @SQL + N' and X1.BILGI = @pIller ';   -- eski kodda X.BILGI (X join yoktu=latent bug); X1'e maplendi
        IF @TemsilciAd IS NOT NULL AND @TemsilciAd <> N''
        BEGIN
            IF @TemsilciID IS NOT NULL AND @TemsilciID > 0
                SET @SQL = @SQL + N' and R.TEMSILCI = ' + CAST(@TemsilciID AS NVARCHAR(20)) + N' ';
            ELSE
                SET @SQL = @SQL + N' and R2.FIRMA like @pTemsilci + N''%'' ';
        END;
        IF @Pasifler = 0
            SET @SQL = @SQL + N' and R.DURUM > 0 ';
        IF @SubeList IS NOT NULL AND @SubeList <> N''
            SET @SQL = @SQL + N' and R.SUBEID in(' + @SubeList + N') ';
        IF @KategoriID IS NOT NULL AND @KategoriID > 0
            SET @SQL = @SQL + N' and R.KATEGORI = ' + CAST(@KategoriID AS NVARCHAR(20)) + N' ';
        IF @SinifID IS NOT NULL AND @SinifID > 0
            SET @SQL = @SQL + N' and R.SINIF = ' + CAST(@SinifID AS NVARCHAR(20)) + N' ';
        IF @AraOzelKod IS NOT NULL AND @AraOzelKod <> N''
            SET @SQL = @SQL + N' and R.OZELKOD like @pOzelKod + N''%'' ';
        IF @TekSubeTum = 1
            SET @SQL = @SQL + N' AND R.TEMSILCI = ' + CAST(ISNULL(@KulId,0) AS NVARCHAR(20)) + N' ';
        ELSE IF @TekSubeTum = 10
            SET @SQL = @SQL + N' AND R.SUBEID = ' + CAST(ISNULL(@SubeId,0) AS NVARCHAR(20)) + N' ';
        IF @EkipmanFiltre = 1
            SET @SQL = @SQL + N' and R.ID in (select distinct REHBERID from EKIPMANREHBER) ';

        -- BA analiz where (ComboCariAnaliz 1..4)
        IF @AnalizWhere IN (1,3)
            SET @SQL = @SQL + N' and isnull(R.ID,'''')<>'''' and ((ISNULL(TOPLAM_BORC,0.0) - ISNULL(TOPLAM_ALACAK,0.0)) > 1.0 OR TAKIPTE > 1.0 OR IRSALIYE > 1.0) ';
        ELSE IF @AnalizWhere IN (2,4)
            SET @SQL = @SQL + N' and isnull(R.ID,'''')<>'''' and (ISNULL(TOPLAM_ALACAK,0.0) - ISNULL(TOPLAM_BORC,0.0)) > 1.0 ';
    END
    ELSE IF @Mod = 1
    BEGIN
        -- LabelTumKayitlarClick: TOP yok, sinirli filtre
        IF @Pasifler = 0
            SET @SQL = @SQL + N' and R.DURUM > 0 ';
        IF @SubeList IS NOT NULL AND @SubeList <> N''
            SET @SQL = @SQL + N' and R.SUBEID in(' + @SubeList + N') ';
        IF @AksiyonFrame = 1
            SET @SQL = @SQL + N' and R.GRUP = 1 ';
        ELSE
            SET @SQL = @SQL + N' and R.GRUP > 1 ';
        SET @SQL = @SQL + N' and R.GRUP <> 334 ';
    END
    ELSE IF @Mod IN (3, 5)
    BEGIN
        -- LabelSonArananlarClick / LabelSikArananlarClick: DURUM filtresi YOK (eski davranis)
        IF @SubeList IS NOT NULL AND @SubeList <> N''
            SET @SQL = @SQL + N' and R.SUBEID in(' + @SubeList + N') ';
        IF @AksiyonFrame = 1
            SET @SQL = @SQL + N' and R.GRUP = 1 ';
        ELSE
            SET @SQL = @SQL + N' and R.GRUP > 1 ';
        SET @SQL = @SQL + N' and R.GRUP <> 334 ';
    END;

    -- --------- CRM sarmalama (CheckDetay) --------------------
    IF @CRM = 1
        SET @SQL = N' select * from ( ' + @SQL + N' ) as cc ';

    -- --------- ORDER BY --------------------------------------
    -- CRM sarmalamasi (yukarida) sorguyu 'select * from (...) as cc' icine
    --   aliyor; dis kapsamda KA takma adi YOK ve KA kolonlari select
    --   listesinde de yok. Sarmalanmis halde KA.* ile siralamak
    --   "The multi-part identifier KA.DEGISTIRMETARIHI could not be bound"
    --   veriyordu (Cari liste + Detay + Son Arananlar, 09.08.2026).
    --   Sarmalanmissa siralama iliskili alt sorguyla yapilir (cc.ID uzerinden);
    --   sonuc kumesinin BICIMI DEGISMEZ.
    DECLARE @OrdSon NVARCHAR(MAX) = N'KA.DEGISTIRMETARIHI';
    DECLARE @OrdSik NVARCHAR(MAX) = N'KA.SAY';
    IF @CRM = 1 AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        DECLARE @KaFiltre NVARCHAR(200) =
            N' where KA2.KAYITID = cc.ID and KA2.KULID = ' + CAST(@KulId AS NVARCHAR(20)) +
            N' and KA2.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @OrdSon = N'(select KA2.DEGISTIRMETARIHI from KULLANICI_ARAMA KA2' + @KaFiltre;
        SET @OrdSik = N'(select KA2.SAY from KULLANICI_ARAMA KA2' + @KaFiltre;
    END;

    -- @KulId/@Modul yoksa KA join'i de eklenmemistir; KA ile siralamak patlar.
    IF @Mod = 5 AND (@KulId IS NULL OR @Modul IS NULL)
        SET @SQL = @SQL + N' ORDER BY 1 ';
    ELSE IF @Mod = 3 AND (@KulId IS NULL OR @Modul IS NULL)
        SET @SQL = @SQL + N' ORDER BY 1 ';
    ELSE IF @Mod = 5
        SET @SQL = @SQL + N' ORDER BY ' + @OrdSon + N' DESC ';
    ELSE IF @Mod = 3
        SET @SQL = @SQL + N' ORDER BY ' + @OrdSik + N' DESC ';
    ELSE IF @Mod = 1
        SET @SQL = @SQL + N' ORDER BY 1 ';
    ELSE IF @Mod = 4
    BEGIN
        IF @Variant = 1
            SET @SQL = @SQL + N' ORDER BY KUR ';
        ELSE IF @OrderCol = 1
            SET @SQL = @SQL + N' ORDER BY KOD ';
        ELSE
            SET @SQL = @SQL + N' ORDER BY FIRMA ';
    END;

    EXEC sp_executesql @SQL,
         N'@pFirma NVARCHAR(200), @pYetkili NVARCHAR(200), @pKod NVARCHAR(100), @pOzelKod NVARCHAR(100), @pIller NVARCHAR(200), @pTemsilci NVARCHAR(200), @pBasTarih DATETIME',
         @pFirma = @AraFirma, @pYetkili = @AraYetkili, @pKod = @AraKod, @pOzelKod = @AraOzelKod,
         @pIller = @Arailler, @pTemsilci = @TemsilciAd, @pBasTarih = @BASTARIH;
END;

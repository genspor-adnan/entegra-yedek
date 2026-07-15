-- ============================================================
-- sp_Prog_Cari_Liste — Cari/Rehber liste ekrani sunucu-tarafi listeleme (UReharadlg / TRehberAraDlg)
--   sp_Prog_Stok_Liste deseninin Cari/Rehber karsiligi. THE en kritik/en cok kullanilan ekran.
--   PARITE MUTLAK: SELECT listesi app'te SubSelectGetir ile birebir uretilip @SelectList olarak
--   gecilir (byte-parity garanti). SP yalniz FROM/JOIN/WHERE/ORDER iskeletini sahiplenir.
--
--   Iki base memo (app'teki SQLMemo / SQLMemoBA) @Variant ile karsilanir:
--     @Variant=0 -> normal (SQLMemo): FROM REHBER R + P (ilgili arama) + R2 + X1 (outer apply)
--     @Variant=1 -> BA/analiz (SQLMemoBA): buyuk BORC/ALACAK/TAKIPTE/IRSALIYE toplama + REHBER join
--
--   @Mod (Son/Sik/Tum/Filtre) — Stok pilotu ile ayni + Cari'ye ozel WHERE alt-kumeleri:
--     1 = Tum Kayitlar (TOP yok, ORDER BY 1)                 -> LabelTumKayitlarClick
--     3 = Sik Aranan (INNER JOIN KULLANICI_ARAMA, KA.SAY desc)
--     4 = Filtre / normal listeleme (JvTimer1Timer)          -> tum arama kutulari
--     5 = Son Aranan (INNER JOIN KULLANICI_ARAMA, KA.DEGISTIRMETARIHI desc)
--
--   KULLANICI_REHBER -> KULLANICI_ARAMA (generic, MODUL bazli): MODUL = MODUL_Cari = 22.
--     Son/Sik: INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID=R.ID AND KA.KULID=@KulId AND KA.MODUL=@Modul.
--     Normal/Tum: KULLANICI_ARAMA hic join edilmez (eski kodda K OUTER APPLY vardi ama SELECT'te/
--     siralamada kullanilmadigi icin sonuc kumesine etkisiz -> parite icin cikarildi).
--
--   Metin filtreleri sp_executesql parametreleri (plan reuse + enjeksiyon guvenli). Sayisal/liste
--   filtreleri int cast/virgullu-int-liste (guvenli). PK = REHBER.ID (alias R).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Cari_Liste
    @SelectList    NVARCHAR(MAX),               -- Paramst (app SubSelectGetir ile birebir)
    @Variant       SMALLINT      = 0,           -- 0=normal(SQLMemo) 1=BA/analiz(SQLMemoBA)
    @TopN          INT           = 200,         -- 0 = TOP yok
    @Mod           SMALLINT      = 4,           -- 1=Tum 3=Sik 4=Filtre 5=Son
    @IlgiliArama   BIT           = 0,           -- @ILGILIARAMA: AraYetkili doluysa 1
    @KulId         INT           = NULL,        -- @Mod=3/5 kullanici (KULLANICI_ARAMA.KULID)
    @Modul         INT           = 22,          -- KULLANICI_ARAMA.MODUL = MODUL_Cari
    @CRM           BIT           = 0,           -- CheckDetay: select * from (...) cc sarmalama
    -- kullanici filtreleri (typed):
    @AraFirma      NVARCHAR(200) = NULL,
    @AraYetkili    NVARCHAR(200) = NULL,
    @AraKod        NVARCHAR(100) = NULL,
    @AraOzelKod    NVARCHAR(100) = NULL,
    @Arailler      NVARCHAR(200) = NULL,
    @TemsilciAd    NVARCHAR(200) = NULL,
    @TemsilciID    INT           = NULL,
    @GrupID        INT           = NULL,
    @BolgeID       INT           = NULL,
    @KategoriID    INT           = NULL,
    @SinifID       INT           = NULL,
    @Pasifler      BIT           = 0,           -- 1=pasifler de
    @AksiyonFrame  BIT           = 0,           -- AktifSekme='TAksiyonlarGorevFrame'
    @Potansiyel    BIT           = 0,           -- CheckPotansiyel
    @SubeList      NVARCHAR(MAX) = NULL,        -- yetkili sube listesi (virgullu int) veya NULL
    @TekSubeTum    INT           = 0,           -- ModulYetki_TekSubeTum.Cari (1 veya 10)
    @SubeId        INT           = NULL,
    @EkipmanFiltre BIT           = 0,           -- ComboCariAnaliz=6 -> EKIPMANREHBER
    @AnalizWhere   SMALLINT      = 0,           -- BA analiz borc/alacak where (1,2,3,4)
    @OrderCol      SMALLINT      = 0            -- @Mod=4 normal: 0=FIRMA 1=KOD
AS
BEGIN
    SET NOCOUNT ON;

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
    IF @Mod = 5
        SET @SQL = @SQL + N' ORDER BY KA.DEGISTIRMETARIHI DESC ';
    ELSE IF @Mod = 3
        SET @SQL = @SQL + N' ORDER BY KA.SAY DESC ';
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

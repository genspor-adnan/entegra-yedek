-- ============================================================
-- sp_Prog_Banka_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Banka'da BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   sp_Prog_Banka_Liste (tipli) ile BIREBIR ayni govde; sadece parametre alimi JSON.
--   @Kosullar ornek: '{"Mod":4,"Pasif":0,"Trh":"2026-07-14T23:59:59","Kod":"","KulId":1,"Modul":25}'
--   Amac: JSON vs tipli-param paritesi (Teklif pilotu deseninin Banka karsiligi).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Banka_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                       -- sablon uyumu (Banka'da ek alan yok)
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);  -- 0 = TOP yok
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Pasif      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @Trh        DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.Trh') AS DATETIME);
    DECLARE @Kod        NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.Kod');
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @PDURUM INT      = CASE WHEN @Pasif = 1 THEN 0 ELSE 1 END;   -- Ord(not CheckAktifPasif)
    DECLARE @PTARIH DATETIME = ISNULL(@Trh, GETDATE());

    -- Son/Sik: kullanicinin actigi krediler (KULLANICI_ARAMA) — suzgec + siralama anahtari
    DECLARE @KaCol NVARCHAR(MAX) = N'';   -- her SELECT'e eklenecek KA_SIRA kolonu
    DECLARE @Filt  NVARCHAR(MAX) = N'';   -- her WHERE'e eklenecek ek kosullar
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        SET @KaCol = N', KA_SIRA = (SELECT '
            + CASE WHEN @Mod = 5 THEN N'MAX(KA.DEGISTIRMETARIHI)' ELSE N'MAX(KA.SAY)' END
            + N' FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = KR.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = KR.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';
    END

    -- Metin filtresi (parametreli - enjeksiyon guvenli)
    IF @Kod IS NOT NULL AND @Kod <> N''
        SET @Filt = @Filt + N' AND (KR.KREDIKODU LIKE N''%'' + @pKod + N''%'' OR KR.ADI LIKE N''%'' + @pKod + N''%'' OR KR.SOZLESMENO LIKE N''%'' + @pKod + N''%'') ';

    DECLARE @SQL NVARCHAR(MAX) = N'
    ----------------------------------------------------------------- taksitli (1,11)
    select
        KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KR.DURUM,
        KREDITAKSIT=count(P.ID),
        ODENENTAKSIT=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then 1 else 0 end),
        KALANTAKSIT=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then 0 else 1 end),
        TOPLAM_TUTAR=isnull(sum(P.TAKSIT),0),
        TOPLAM_ANAPARA=isnull(sum(P.ANAPARA),0),
        TOPLAM_GIDER=isnull(sum(P.FAIZ+P.KKDF+P.BSMV),0),
        ODENEN_TUTAR=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then P.TAKSIT else 0.0 end),
        ODENEN_ANAPARA=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then P.ANAPARA else 0.0 end),
        ODENEN_GIDER=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then P.FAIZ+P.KKDF+P.BSMV else 0.0 end),
        KALAN_TUTAR=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then 0.0 else P.TAKSIT end),
        KALAN_ANAPARA=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then 0.0 else P.ANAPARA end),
        KALAN_GIDER=sum(case when P.ODENMIS=1 and P.TARIH<=@PTARIH then 0.0 else P.FAIZ+P.KKDF+P.BSMV end),
        B.BANKAADI,BS.SUBEADI,LOGO=null,BANKATICARIHESAPID, HESAPKUR = BH.KUR,
        KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KREDILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI/*KA*/
    from KREDILER KR
        left join PLANKREDI P on P.KREDIID=KR.ID
        inner join BANKAHESAPLAR BH ON  BH.ID = KR.BANKATICARIHESAPID
        inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID
        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU
    where
        KR.DURUM>=@PDURUM and GENELKREDITIPI in (1,11)
        and ALINISTARIHI<=@PTARIH+1 /*FLT*/
    GROUP BY
        KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KREDITAKSIT,
        TAKSITTUTARI,KR.DURUM,KR.SUBEID,B.BANKAADI,BS.SUBEADI,BANKATICARIHESAPID,BH.KUR,
        KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KREDILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI
    -----
    union all
    ----------------------------------------------------------------- rotatif (2)
    select
        KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KR.DURUM,
        KREDITAKSIT= 0,
        ODENENTAKSIT = 0,
        KALANTAKSIT = 0,
        TOPLAM_TUTAR=isnull(sum(BORC),0)+([dbo].[fn_RotatifFaizHesapla]  (KR.ID, ''2000.01.01 00:00'', @PTARIH-1, 0)),
        TOPLAM_ANAPARA=isnull(sum(BORC),0),
        TOPLAM_GIDER=[dbo].[fn_RotatifFaizHesapla]  (KR.ID, ''2000.01.01 00:00'', @PTARIH-1, 0),
        ODENEN_TUTAR=isnull(sum(ALACAK),0)+(SELECT isnull(sum(BORC),0.0) FROM KASA K where K.TUR=32 and K.YERI=47 AND K.YERID=KR.ID),
        ODENEN_ANAPARA=isnull(sum(ALACAK),0),
        ODENEN_GIDER=(SELECT isnull(sum(BORC),0.0) FROM KASA K where K.TUR=32 and K.YERI=47 AND K.YERID=KR.ID),
        KALAN_TUTAR=isnull(sum(BORC-ALACAK),0)+[dbo].[fn_RotatifFaizHesapla]  (KR.ID, ''2000.01.01 00:00'', @PTARIH-1, 0)
                    - (SELECT isnull(sum(BORC),0.0) FROM KASA K where K.TUR=32 and K.YERI=47 AND K.YERID=KR.ID),
        KALAN_ANAPARA=isnull(sum(BORC-ALACAK),0),
        KALAN_GIDER=[dbo].[fn_RotatifFaizHesapla]  (KR.ID, ''2000.01.01 00:00'', @PTARIH-1, 0)
                    - (SELECT isnull(sum(BORC),0.0) FROM KASA K where K.TUR=32 and K.YERI=47 AND K.YERID=KR.ID),
        B.BANKAADI,BS.SUBEADI,LOGO=null,BANKATICARIHESAPID, HESAPKUR = BH.KUR,
        KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KREDILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI/*KA*/
    from KREDILER KR
        left outer join KASA KS on HESAPTURU=''R'' and KS.HESAPID=KR.ID and KS.HESAPID=KR.ID and KS.TUR<>2 and KS.ISLEMTARIHI<=@PTARIH+1
        inner join BANKAHESAPLAR BH ON  BH.ID = KR.BANKATICARIHESAPID
        inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID
        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU
    where
        KR.DURUM>=@PDURUM
        and GENELKREDITIPI = 2 /*FLT*/
    GROUP BY
        KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KREDITAKSIT,
        TAKSITTUTARI,KR.DURUM,KR.SUBEID,B.BANKAADI,BS.SUBEADI,BANKATICARIHESAPID,BH.KUR,
        KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KREDILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI
    -----
    union all
    ----------------------------------------------------------------- cek kocan (31)
    select
        KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KR.DURUM,
        KREDITAKSIT= 0,
        ODENENTAKSIT = 0,
        KALANTAKSIT = 0,
        TOPLAM_TUTAR=0,
        TOPLAM_ANAPARA=0,
        TOPLAM_GIDER=0,
        ODENEN_TUTAR=0,
        ODENEN_ANAPARA=0,
        ODENEN_GIDER=0,
        KALAN_TUTAR=0,
        KALAN_ANAPARA=0,
        KALAN_GIDER=0,
        B.BANKAADI,BS.SUBEADI,LOGO=null,BANKATICARIHESAPID, HESAPKUR = BH.KUR,
        KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KREDILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI/*KA*/
    from KREDILER KR
        left outer join KASA KS on HESAPTURU=''R'' and KS.HESAPID=KR.ID and KS.HESAPID=KR.ID and KS.TUR<>2 and KS.ISLEMTARIHI<=@PTARIH+1
        inner join BANKAHESAPLAR BH ON  BH.ID = KR.BANKATICARIHESAPID
        inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID
        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU
    where
        KR.DURUM>=@PDURUM
        and GENELKREDITIPI = 31 /*FLT*/
    GROUP BY
        KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KREDITAKSIT,
        TAKSITTUTARI,KR.DURUM,KR.SUBEID,B.BANKAADI,BS.SUBEADI,BANKATICARIHESAPID,BH.KUR,
        KR.KREDITEMINAT,KR.KREDILIMITSURETIPI,KR.KREDILIMITSURE,KR.KREDILIMIT,KR.KREDIKULLANIMSURE,KR.KREDIEKLIMITVAR,KR.REVIZYONTARIHI';

    -- Son/Sik suzgeci + KA_SIRA kolonu enjeksiyonu (3 parca)
    SET @SQL = REPLACE(@SQL, N'/*KA*/',  @KaCol);
    SET @SQL = REPLACE(@SQL, N'/*FLT*/', @Filt);

    -- SAYFALI liste (TSayfaliListe): @TopN>0 -> TOP (n). 0 = TOP yok (eski davranis).
    --   Govde UNION ALL (taksitli + taksitsiz) oldugu icin TOP her dala AYRI uygulanmamali
    --   (2xN satir doner) -> tum sorgu turetilmis tabloya sarilir. ORDER BY DISARIYA eklenir
    --   (asagidaki blok) -> siralama TOP'tan ONCE degerlendirilir, sayfalar tutarli olur.
    IF @TopN > 0
        SET @SQL = N'SELECT TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') * FROM (' + @SQL + N') AS SAYFA';

    -- Siralama
    IF @Mod IN (3, 5)
        SET @SQL = @SQL + N' ORDER BY KA_SIRA DESC';
    ELSE IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@PDURUM INT, @PTARIH DATETIME, @pKod NVARCHAR(100)',
         @PDURUM = @PDURUM, @PTARIH = @PTARIH, @pKod = @Kod;
END;

-- ============================================================
-- GenDepoUpdate24 : sp_Prog_Kasa_Hareket_Json2  (2-param JSON, guncel)
--   Liste ekrani sunucu-tarafi listeleme SP'si. ANA DB baglantisindan.
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: GenDepoUpdate4 (KULLANICI_ARAMA).
-- ============================================================

-- ============================================================
-- sp_Prog_Kasa_Hareket_Json2 — Kasa (gunluk hareket) ekrani, tek JSON parametre (MSSQL-ONLY)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Kasa'da KULLANILMAZ);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   UKasa.Calendar1Change (eski dinamik SQL) ile BIREBIR ayni cok-kaynakli UNION ALL sonuc kumesi.
--   FINANSAL EKRAN: satir kumesi + tutarlar (BORC/ALACAK) birebir korunur.
--   Kaynaklar (kosullu UNION ALL):
--     - KASA (taban, HER ZAMAN) : ISLEMTARIHI araligi + sube + not(TUR 21..39)/not(TUR 61..79)
--     - FATBASLIK (CheckFat)    : FATURATARIH araligi + sube (liste 24)
--     - CEKLER/CEKHAREKET (CheckCekSenet) : CH.TARIH araligi + sube (liste 25)
--     - SENETLER (CheckCekSenet): C.TARIH araligi + sube (liste 25)
--   @Kosullar ornek:
--     {"Cal1":"2024-12-31","Cal2":"2024-12-31","BasZaman":"00:00:00","BitZaman":"23:59",
--      "EkleGun":0,"CheckKasa":0,"CheckPlan":0,"CheckFat":1,"CheckCekSenet":1,
--      "SubeKasaList":"-1","SubeCekList":"-1","SubeId":0}
--   NOT: eski akista taban sorgular DFM memo'larinda (SQLKasa/SQLFatura/SQLCek/SQLSenet);
--        burada govdede AYNEN gomulu. Tarih sinirlari parametreli (enjeksiyon guvenli);
--        sube listeleri digit-guard'li ham IN.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Kasa_Hareket_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (Kasa'da kullanilmaz; sablon uyumu)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @Cal1     DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.Cal1') AS DATE);
    DECLARE @Cal2     DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.Cal2') AS DATE);
    DECLARE @BasZaman NVARCHAR(20)  = ISNULL(JSON_VALUE(@Kosullar,'$.BasZaman'), N'00:00:00');
    DECLARE @BitZaman NVARCHAR(20)  = ISNULL(JSON_VALUE(@Kosullar,'$.BitZaman'), N'23:59');
    DECLARE @EkleGun  INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.EkleGun') AS INT), 0);
    DECLARE @CheckKasa      BIT     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CheckKasa')      AS BIT), 0);
    DECLARE @CheckPlan      BIT     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CheckPlan')      AS BIT), 0);
    DECLARE @CheckFat       BIT     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CheckFat')       AS BIT), 0);
    DECLARE @CheckCekSenet  BIT     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CheckCekSenet')  AS BIT), 0);
    DECLARE @SubeKasaList NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeKasaList');  -- liste 24 (kasa+fatura); yalniz rakam/virgul/bosluk/eksi
    DECLARE @SubeCekList  NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeCekList');   -- liste 25 (cek+senet); yalniz rakam/virgul/bosluk/eksi
    DECLARE @SubeId       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeId') AS INT), 0);

    -- ---- Tarih sinirlari (datetime; eski FormatDateTime + KasaBas/BitZamani + KasaEkleGun ile ESDEGER) ----
    --   alt sinir = Cal1 + BasZaman ; ust sinir = (Cal2 + EkleGun gun) + BitZaman ; karsilastirma [>= alt, < ust)
    DECLARE @BasDT DATETIME = TRY_CAST(CONVERT(VARCHAR(10), @Cal1, 120) + ' ' + @BasZaman AS DATETIME);
    DECLARE @BitDT DATETIME = TRY_CAST(CONVERT(VARCHAR(10), DATEADD(DAY, @EkleGun, @Cal2), 120) + ' ' + @BitZaman AS DATETIME);

    -- ---- Sube suzgeci uretici (SubeId>0 -> =@pSubeId; degilse liste doluysa IN(...)). Kolon: alias.SUBEID ----
    --   digit-guard: yalniz rakam/virgul/bosluk/eksi (SUBEID negatif olabilir, orn -1) -> guvenli enjeksiyon.
    DECLARE @SubeKasaFilt NVARCHAR(MAX) = N'';   -- KASA (K.SUBEID)
    DECLARE @SubeFatFilt  NVARCHAR(MAX) = N'';   -- FATBASLIK (F.SUBEID)
    DECLARE @SubeCekFilt  NVARCHAR(MAX) = N'';   -- CEK/SENET (C.SUBEID)

    IF @SubeId > 0
    BEGIN
        SET @SubeKasaFilt = N' and K.SUBEID = @pSubeId ';
        SET @SubeFatFilt  = N' and F.SUBEID = @pSubeId ';
        SET @SubeCekFilt  = N' and C.SUBEID = @pSubeId ';
    END
    ELSE
    BEGIN
        IF @SubeKasaList IS NOT NULL AND @SubeKasaList <> N'' AND @SubeKasaList NOT LIKE N'%[^0-9, -]%'
        BEGIN
            SET @SubeKasaFilt = N' and K.SUBEID in (' + @SubeKasaList + N') ';
            SET @SubeFatFilt  = N' and F.SUBEID in (' + @SubeKasaList + N') ';
        END
        IF @SubeCekList IS NOT NULL AND @SubeCekList <> N'' AND @SubeCekList NOT LIKE N'%[^0-9, -]%'
            SET @SubeCekFilt = N' and C.SUBEID in (' + @SubeCekList + N') ';
    END

    -- ================= GOVDE: eski Calendar1Change akisiyla BIREBIR (UNION ALL) =================
    DECLARE @SQL NVARCHAR(MAX);

    -- ---- Taban: KASA (DFM SQLKasa) ----
    SET @SQL = N'Select K.ID, ISLEMTARIHI AS KAYITTARIH, PLANTARIHI AS AKSIYONTARIH, K.TUR,BELGENO=cast(BELGENO as nvarchar(20)), REHBERID,
CARIKOD=R.KOD,
CARIAD=R.FIRMA, K.ACIKLAMA, HESAPID,
     HESAPKODU=case HESAPTURU
         when ''B'' then (select HESAPKODU from BANKAHESAPLAR BH where BH.ID=K.HESAPID)
         when ''K'' then (select KASAKODU from KASALAR K2 where K2.ID=K.HESAPID)
         when ''H'' then (select KASAKODU from KASALAR K2 where K2.ID=K.HESAPID)+isnull('' (''+ (select ADI from PARA_KUPON PK where PK.ID=K.CEKSENETID)+'')'','''')
         when ''P'' then (select HESAPKODU = KODU from POS P where P.ID=K.HESAPID)
         when ''V'' then (select HESAPKODU = KODU from KREDIKARTI KK where KK.ID=K.HESAPID)
         when ''R'' then (select HESAPKODU = KREDIKODU from KREDILER KR where KR.ID=K.HESAPID)
         when ''M'' then (select HESAPKODU = KOD  from MASRAFGELIR M where M.ID=K.HESAPID)
     end,
     HESAPADI=case HESAPTURU
         when ''B'' then (select HESAPADI from BANKAHESAPLAR BH where BH.ID=K.HESAPID)
         when ''K'' then (select HESAPADI = KASAADI from KASALAR K2 where K2.ID=K.HESAPID)
         when ''H'' then (select HESAPADI = KASAADI from KASALAR K2 where K2.ID=K.HESAPID)+isnull('' (''+ (select ADI from PARA_KUPON PK where PK.ID=K.CEKSENETID)+'')'','''')
         when ''P'' then (select HESAPADI = ADI from POS P where P.ID=K.HESAPID)
         when ''V'' then (select HESAPADI = ADI from KREDIKARTI KK where KK.ID=K.HESAPID)
         when ''R'' then (select HESAPADI = ADI from KREDILER KR where KR.ID=K.HESAPID)
         when ''M'' then (select HESAPADI = AD from MASRAFGELIR M where M.ID=K.HESAPID)

     end,
     BORC = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51,52,53,54,58,59) and isnull(HESAPTURU,'''')<>'''' then ALACAK
else
BORC
end,
     ALACAK = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51,52,53,54,58,59) and  isnull(HESAPTURU,'''')<>'''' then BORC else
ALACAK
end,
 DOVIZ_TUTARI, KASA, ONAY, K.EKLEYEN,
       MASRAFKOD=MG.KOD, MASRAFAD=MG.AD,
       K.KUR, GERIDONUSID, DURUM=null, FATURAID,
CEKSENETID,KREDIID ,
K.YERI, K.YERID,OZELKOD='''',K.SUBEID
FROM KASA K (NOLOCK)
     left outer join REHBER R on R.ID=K.REHBERID
     left outer join MASRAFGELIR MG on MG.ID=K.MASRAFID';

    SET @SQL = @SQL + N'
 Where  K.ISLEMTARIHI >= @pBasDT and K.ISLEMTARIHI < @pBitDT ' + @SubeKasaFilt;

    IF @CheckKasa = 0
        SET @SQL = @SQL + N' and not(K.TUR between 21 and 39) ';
    IF @CheckPlan = 0
        SET @SQL = @SQL + N' and not(K.TUR between 61 and 79) ';

    -- ---- FATBASLIK (DFM SQLFatura) — CheckFat ----
    IF @CheckFat = 1
    BEGIN
        SET @SQL = @SQL + N'
UNION ALL

SELECT
	SIRANO= F.ID,FATURATARIH as KAYITTARIH, FATURATARIH as AKSIYONTARIH,   F.TUR,
FATURANO as BELGENO, REHBERID,CARIKOD=R.KOD,CARIAD=R.FIRMA, F.ACIKLAMA,
	HESAPID  = case when YERI=3 then abs(REHBERID) else null end,
	HESAPKODU= case when YERI=3 then (select KASAKODU from KASALAR where ID=abs(F.REHBERID)) else null end,
	HESAPADI = case when YERI=3 then (select KASAADI  from KASALAR where ID=abs(F.REHBERID)) else null end,
	BORC=case when F.TUR in (15,16,17,110) then FATURA_TUTARI else 0.0 end,
	ALACAK=case when F.TUR in (8, 11,12,13) then FATURA_TUTARI else 0.0 end,
	DOVIZ_TUTARI,KASA=0,ONAY=NULL,
	F.EKLEYEN ,	MASRAFKOD = MG.KOD,	MASRAFAD=MG.AD,
	F.KUR,GERIDONUSID=NULL, DURUM=null,
	FATURAID=F.ID, CEKSENETID=NULL,KREDIID=null
,YERI=CASE WHEN KASATAKIPID IS NOT NULL THEN 401 ELSE NULL END ,
YERID= F.KASATAKIPID,F.OZELKOD,F.SUBEID
FROM
	FATBASLIK F (NOLOCK)
	left outer join REHBER R on R.ID = F.REHBERID
	left outer join MASRAFGELIR MG on MG.ID=F.MASRAFID';

        SET @SQL = @SQL + N'
 Where F.TUR not in (2,6,10,14,20) and isnull(F.DURUM,0)<>6 and  FATURATARIH >= @pBasDT and FATURATARIH < @pBitDT ' + @SubeFatFilt;
    END

    -- ---- CEKLER/CEKHAREKET (DFM SQLCek) + SENETLER (DFM SQLSenet) — CheckCekSenet ----
    IF @CheckCekSenet = 1
    BEGIN
        SET @SQL = @SQL + N'
--cek
union all
SELECT
	CH.ID,CH.TARIH as KAYITTARIH,AKSIYONTARIH=C.VADE,
	TUR=case when CH.ISLEM between 130 and 139 and CEKSENET=101 then 23
	when CH.ISLEM between 140 and 149 and CEKSENET=103 then 33
	when CH.ISLEM between 130 and 139 and CEKSENET=121 then 24
	when CH.ISLEM between 140 and 149 and CEKSENET=321 then 34
	else 0 end,
	BELGENO=cast(CH.BELGENO as nvarchar(20)),CH.REHBERID,CARIKOD=R.KOD,CARIAD= R.FIRMA,
	ACIKLAMA=G.ANAHTAR+'' ''+isnull(CH.ACIKLAMA,''''),
	HESAPID=null,HESAPKODU=C.KOD,HESAPADI=(select HESAPADI from HESAPPLANI where HESAPKODU=C.KOD),
	BORC = case when CH.ISLEM in(131,132,133,134,135,136,137,138,140) then  C.TUTAR else 0    end,
	ALACAK = case when CH.ISLEM in(130,141) then C.TUTAR else 0  end,
	DOVIZ_TUTARI=0,KASA=0,ONAY=NULL,
	C.EKLEYEN ,MASRAFKOD = M.KOD,	MASRAFAD=M.AD,
	C.KUR,GERIDONUSID=NULL, DURUM=null,FATURAID,
	CEKSENETID=C.ID,KREDIID=null ,YERI=NULL, YERID=NULL,C.OZELKOD,C.SUBEID
FROM
	CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID
	inner join GENINI G on G.BOLUM=-1005 and G.DIL=-1 and G.DEGER=CH.ISLEM
	left outer join REHBER R on R.ID=CH.REHBERID
	left outer JOIN BANKAHESAPLAR BH ON BH.ID = CH.BANKAHESAPLARID
	left outer join MASRAFGELIR M on M.ID=C.MASRAFID
';

        SET @SQL = @SQL + N'
 Where CH.ISLEM in(130,131,132,133,134,135,137,138,140,141) and  CH.TARIH >= @pBasDT and CH.TARIH < @pBitDT ' + @SubeCekFilt;

        SET @SQL = @SQL + N'
---senet
UNION ALL
SELECT
	 C.ID,C.TARIH as KAYITTARIH,C.VADE as AKSIYONTARIH,   C.TUR,
	MAKBUZNO as BELGENO,REHBERID, CARIKOD=R.KOD, CARIAD=R.FIRMA,
	C.ACIKLAMA,
	HESAPID=null,HESAPKODU=C.KOD,HESAPADI=null,
	BORC = case when C.TUR=34 then  C.TUTAR else 0    end,
	ALACAK = case when C.TUR=24 then  C.TUTAR else 0    end,
	DOVIZ_TUTARI=0,KASA=0,ONAY=NULL,
	C.EKLEYEN, MASRAFKOD = MG.KOD,	MASRAFAD=MG.AD,
	C.KUR,GERIDONUSID=NULL, DURUM=null,FATURAID,
	CEKSENETID=NULL,KREDIID=null
,YERI=NULL, YERID=NULL,C.OZELKOD,C.SUBEID
FROM
	SENETLER C
	inner join REHBER R on R.ID=C.REHBERID
	left outer join MASRAFGELIR MG on MG.ID=C.MASRAFID';

        SET @SQL = @SQL + N'
 Where  C.TARIH >= @pBasDT and C.TARIH < @pBitDT ' + @SubeCekFilt;
    END

    EXEC sp_executesql @SQL,
         N'@pBasDT DATETIME, @pBitDT DATETIME, @pSubeId INT',
         @pBasDT = @BasDT, @pBitDT = @BitDT, @pSubeId = @SubeId;
END;

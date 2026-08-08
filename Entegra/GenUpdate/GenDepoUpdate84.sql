-- ============================================================
-- GenDepoUpdate84.sql
-- sp_Prog_StokTalep_Liste_Json2 : bellek grant'i duzeltmesi (istenen 283,4 MB)
--
-- GenDepoUpdate83 (Dokuman listesi) ile AYNI SINIF hata. Plan cache taramasinda
--   bu sorgu 283,4 MB "istenen" bellekle listenin BASINDA cikti; gereken minimum
--   yalnizca 7,5 MB. SQL Express'te sorgu-bellek semaforu 10 MB civarina dustugunde
--   bu istek karsilanamaz ve Stok Talep listesi acilirken program KILITLENIR
--   (RESOURCE_SEMAPHORE, timeout yok, hata da vermez).
--
-- KOK NEDEN: "LEFT OUTER JOIN SIPARISDETAY SD" KOSULSUZ duruyordu. Talep basina
--   detay satiri kadar satir uretiyor, bunu da "SELECT DISTINCT TOP (200)" topluyordu.
--   DISTINCT tum kolonlar (genis satir) uzerinde hash/sort demek. SD'ye gercekte
--   yalnizca iki yerde ihtiyac vardi:
--     1) opsiyonel AraKod/AraStok filtresi (STOKLAR join'i zaten kosulluydu),
--     2) KAYNAK kolonunun 'Uretimden' kosulu.
--   Ikisi de EXISTS ile satir cogaltmadan ifade edilebiliyor.
--
-- YAN FAYDA - GIZLI KAYIT COGALTMA HATASI: DISTINCT satirlari birlestirirken
--   KAYNAK degeri detay satirina gore degistigi icin ayni talep hem KAYNAK=''
--   hem KAYNAK='Uretimden' ile IKI KEZ listelenebiliyordu. EXISTS'e gecince
--   talep basina tek satir kalir.
--
-- COZUM: SD join'i tamamen kaldirildi, AraKod/AraStok ve KAYNAK EXISTS'e cevrildi,
--   DISTINCT kaldirildi.
--
-- NOT (duzeltilmedi, bilgi): SELECT listesinde "PROJEKOD=(...)" korele alt sorgusu
--   UC KEZ birebir tekrar ediyor. Kolon sayisi/sirasi degisirse istemci tarafi
--   etkilenebilecegi icin dokunulmadi.
-- ============================================================
-- ============================================================
-- sp_Prog_StokTalep_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR); @Kosullar = filtreler (JSON).
--   @Kosullar = '{"Mod":4,"TarihBas":"2026-01-01",...}' -> JSON_VALUE ile yerel degiskenlere.
--   Amac: sp_Prog_StokTalep_Liste (tipli-param) ile PARITE (ayni sonuc kumesi).
--   Govde tipli-param SP ile BIREBIR aynidir; sadece parametre alimi JSON'a cevrildi.
--   @Mod: 1=Tum (TOP yok), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.DEGISTIRMETARIHI)
--   PK: SIPARIS.ID (S.ID). Belge turu S.TUR=105 (Stok Talep).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokTalep_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR); StokTalep'te genelde ''
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 200);
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Pasif      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);   -- StokTalep'te no-op (imza uyumu)
    DECLARE @TarihBas   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    -- Yeni filtreler (Sube filtreleri kaldirildi: S.SUBE/S.GIRISSUBE kolonlari SIPARIS'te yok, bozuktu)
    DECLARE @TalepEden    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TalepEden') AS INT);   -- S.SATICIKODU (REHBER/personel)
    DECLARE @CikisDepo    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.CikisDepo') AS INT);   -- S.CIKISDEPO
    DECLARE @GirisDepo    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GirisDepo') AS INT);   -- S.GIRISDEPO
    DECLARE @TalepNo      NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.TalepNo');                       -- S.SIPARISNO LIKE
    DECLARE @OzelKod      NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.OzelKod');                       -- S.OZELKOD LIKE
    DECLARE @UretimEmirNo NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.UretimEmirNo');                  -- URETIMEMRI.EMIRNO LIKE (EXISTS)
    DECLARE @Kod          NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.Kod');                            -- AraKod -> STOKLAR.KOD veya URUNNO LIKE (detay uzerinden EXISTS)
    DECLARE @Stok         NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Stok');                           -- AraStok -> STOKLAR.STOKADI LIKE (detay uzerinden EXISTS)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    -- DISTINCT + ORDER BY kurali: KA sort kolonu SELECT listesinde olmali (yoksa hata)
    DECLARE @KaCol NVARCHAR(60) = CASE WHEN @Mod = 3 THEN N', KA.SAY'
                                       WHEN @Mod = 5 THEN N', KA.DEGISTIRMETARIHI'
                                       ELSE N'' END;

    SET @SQL = N'
    SELECT ' + @Top + N' S.ID,S.DURUM,
    TALEPTARIH=S.SIPARISTARIH, TALEPNO=S.SIPARISNO,
    S.DETAYBOLUMU,
    TALEPEDENAD=(SELECT FIRMA FROM REHBER R WHERE S.SATICIKODU = R.ID),
    TALEPEDENBIRIM=(select DEPARTMAN=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 ) from ROLLER ROL where ROL.ID=S.BOLUM),
    BIRIMONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLAYACAK = R.ID),
    BIRIMONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLAYAN = R.ID),
    TALEPONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYACAK = R.ID),
    TALEPONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYAN = R.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    S.ACIKLAMA,S.OZELKOD,
    GIRISDEPOSU=(select DEPOADI from DEPOLAR D where D.ID=S.GIRISDEPO),
    S.TIPI,S.REHBERID,S.TUR,S.SUBEID,
    S.ONAYLAYACAK,S.ONAYLAYAN,
    KAYNAK= case when (S.TUR=105) and exists (
                    select 1 from SIPARISDETAY SD2
                     where SD2.SIPARISID = S.ID
                       and exists (select 1 from SIPARISDETAY X
                                    inner join URETIMEMRIDETAY UED on UED.ID = SD2.YERID
                                    where X.YERI = 467 and X.YERID = UED.ID))
                 then ''Üretimden'' else '''' end,
    HEDEF=  case when (S.TUR=105)and(435 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then ''Transfer'' end'
    + @SelectList + @KaCol + N'
    from SIPARIS S (NOLOCK) inner join REHBER R on R.ID = S.REHBERID '
    -- SIPARISDETAY/STOKLAR ARTIK JOIN DEGIL: bkz. asagidaki AraKod/AraStok EXISTS'leri.
    --   Onceki halde "LEFT OUTER JOIN SIPARISDETAY SD" KOSULSUZ duruyordu; talep basina
    --   detay satiri kadar satir uretiyor, bunu da DISTINCT topluyordu. Genis satirlarda
    --   (TOP 200 x tum kolonlar) bu, 283 MB bellek grant'i demekti -> SQL Express'te
    --   RESOURCE_SEMAPHORE'da sonsuz bekleme.
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 (unique KULID,MODUL,KAYITID)
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = S.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' where S.TUR=105 ';

    -- Tarih araligi (Filtre modunda; Tum/Son/Sik'te app NULL gonderir) - parametreli
    IF @TarihBas IS NOT NULL
        SET @SQL = @SQL + N' and SIPARISTARIH >= @pTarihBas ';
    IF @TarihBit IS NOT NULL
        SET @SQL = @SQL + N' and SIPARISTARIH <= @pTarihBit ';

    -- Talep Eden / Cikis Depo / Giris Depo (secili degilse app 0/NULL gonderir) - guvenli int cast
    IF @TalepEden IS NOT NULL AND @TalepEden > 0
        SET @SQL = @SQL + N' and S.SATICIKODU = ' + CAST(@TalepEden AS NVARCHAR(20)) + N' ';
    IF @CikisDepo IS NOT NULL AND @CikisDepo > 0
        SET @SQL = @SQL + N' and S.CIKISDEPO = ' + CAST(@CikisDepo AS NVARCHAR(20)) + N' ';
    IF @GirisDepo IS NOT NULL AND @GirisDepo > 0
        SET @SQL = @SQL + N' and S.GIRISDEPO = ' + CAST(@GirisDepo AS NVARCHAR(20)) + N' ';

    -- Talep No / Ozel Kod / Uretim Emir No (LIKE) - parametreli (SQL injection guvenli)
    IF @TalepNo IS NOT NULL AND @TalepNo <> N''
        SET @SQL = @SQL + N' and S.SIPARISNO LIKE @pTalepNo ';
    IF @OzelKod IS NOT NULL AND @OzelKod <> N''
        SET @SQL = @SQL + N' and S.OZELKOD LIKE @pOzelKod ';
    -- Uretim Emir No: StokTalep'te SIPARIS.DETAYBOLUMU alaninda DOGRUDAN tutuluyor
    IF @UretimEmirNo IS NOT NULL AND @UretimEmirNo <> N''
        SET @SQL = @SQL + N' and S.DETAYBOLUMU LIKE @pUretimEmirNo ';
    -- AraKod / AraStok: detay satirlarinda urun arama. JOIN yerine EXISTS - satir
    --   cogaltmaz, dolayisiyla DISTINCT'e de gerek kalmaz.
    IF @Kod IS NOT NULL AND @Kod <> N''
        SET @SQL = @SQL + N' and exists (select 1 from SIPARISDETAY SDK
                                          inner join STOKLAR STK on STK.ID = SDK.URUNID
                                          where SDK.SIPARISID = S.ID
                                            and (STK.KOD LIKE @pKod OR STK.URUNNO LIKE @pKod)) ';
    IF @Stok IS NOT NULL AND @Stok <> N''
        SET @SQL = @SQL + N' and exists (select 1 from SIPARISDETAY SDS
                                          inner join STOKLAR STK on STK.ID = SDS.URUNID
                                          where SDS.SIPARISID = S.ID
                                            and STK.STOKADI LIKE @pStok) ';

    -- Son/Sik siralamasi (KULLANICI_ARAMA); aksi halde orijinal: SIPARISTARIH desc
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    ELSE IF @OrderBy IS NULL OR @OrderBy = N'' SET @OrderBy = N'SIPARISTARIH desc';

    SET @SQL = @SQL + N' order by ' + @OrderBy;

    -- LIKE degerleri: '%' + deger + '%' (parametreli gonderilir)
    DECLARE @pTalepNoV      NVARCHAR(200) = N'%' + ISNULL(@TalepNo, N'')      + N'%';
    DECLARE @pOzelKodV      NVARCHAR(200) = N'%' + ISNULL(@OzelKod, N'')      + N'%';
    DECLARE @pUretimEmirNoV NVARCHAR(200) = N'%' + ISNULL(@UretimEmirNo, N'') + N'%';
    DECLARE @pKodV          NVARCHAR(200) = N'%' + ISNULL(@Kod, N'')          + N'%';
    DECLARE @pStokV         NVARCHAR(200) = N'%' + ISNULL(@Stok, N'')         + N'%';

    EXEC sp_executesql @SQL,
         N'@pTarihBas DATETIME, @pTarihBit DATETIME, @pTalepNo NVARCHAR(200), @pOzelKod NVARCHAR(200), @pUretimEmirNo NVARCHAR(200), @pKod NVARCHAR(200), @pStok NVARCHAR(200)',
         @pTarihBas = @TarihBas, @pTarihBit = @TarihBit,
         @pTalepNo = @pTalepNoV, @pOzelKod = @pOzelKodV, @pUretimEmirNo = @pUretimEmirNoV, @pKod = @pKodV, @pStok = @pStokV;
END;

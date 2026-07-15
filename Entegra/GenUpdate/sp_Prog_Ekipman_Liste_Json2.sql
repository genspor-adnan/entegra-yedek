-- ============================================================
-- sp_Prog_Ekipman_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Ekipman'da BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER + guvenilir SubeYetkiList).
--   Ekipman liste ekrani (UEkipmanListeDlg / TreeList) sunucu-tarafi listeleme. Govde eski
--   TabEkipmanlar.SQL (DFM'deki ozyinelemeli CTE agac sorgusu) ile BIREBIR; sadece Son/Sik
--   siralama+suzgeci ve opsiyonel sube-yetki suzgeci parametreyle eklenir. Parametre alimi JSON.
--   Govde DINAMIK DEGIL (agac sorgusu tirnak-yogun; BIREBIR korumak icin duz T-SQL + degisken guard).
--   @Kosullar ornek: '{"Mod":4,"SubeYetkiList":"1,2,5","KulId":1,"Modul":3011}'
--   Son/Sik: KULLANICI_ARAMA (MODUL_Ekipman=3011), PK = EKIPMANLAR.ID (outer alias E2.ID).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Ekipman_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR; Ekipman'da BOS)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                        -- sablon uyumu (Ekipman'da ek alan yok)
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);   -- sablon uyumu (agac sorgusunda uygulanmaz)
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @SubeList   NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');                      -- tam-sayi listesi (GUVENILIR; yalniz SubeVarmi)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');                            -- sablon uyumu (agac sirasi sabit: order by 2,AD)

    -- ================= GOVDE = eski TabEkipmanlar.SQL (DFM) ile BIREBIR =================
    --   Fark yalniz: (1) KA_SIRA hesap kolonu (Son/Sik siralamasi; Mod 4'te NULL -> etkisiz),
    --                (2) opsiyonel sube-yetki + Son/Sik EXISTS suzgeci (degisken-guard'li),
    --                (3) ORDER BY KA_SIRA DESC ONEKI (Mod 4'te tum satirlar NULL -> orijinal
    --                    'order by 2,AD' ile AYNI sira).
    WITH PagesList (EkipmanID,TreeID) AS
    (	SELECT -- Anchor member definition
    		E.ID,
    		TreeID=convert(nvarchar(254),E.ID)
    	FROM EKIPMANLAR E
    	UNION ALL
    	SELECT -- Recursive member definition
    		ED.EKIPMANID,
    		TreeID =  convert(nvarchar(254),TreeID+N'.'+convert(nvarchar(200),ED.EKIPMANID))
    	From EKIPMANDETAY as ED INNER JOIN PagesList as p ON ED.USTEKIPMANID = p.EkipmanID
    )-- Statement that executes the CTE
    SELECT
    ALTID=TreeID,
    USTID=case when CHARINDEX('.',TreeID,1)=0 then '' else
    REVERSE(SUBSTRING(REVERSE(TreeID),CHARINDEX('.',REVERSE(TreeID),1)+1,LEN(TreeID)-(CHARINDEX('.',REVERSE(TreeID),1)-1)))
    end ,E2.*,
    STOKLU=convert(bit, case when isnull(URUNID,'')<>'' then 1 else 0 end),
    MARKAAD = (case when E2.SAHIP=0 then (select top 1 ANAHTAR from GENINI where BOLUM=-2727 and DEGER=E2.MARKA and DIL=-1)
    			else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and DEGER=E2.MARKA and DIL=-1) end) ,
    MODELAD = (case when E2.SAHIP=0 then (select top 1 ANAHTAR from GENINI where BOLUM=convert(int,'-2727'+convert(varchar(10),E2.MARKA)) and DEGER=E2.MODEL and DIL=-1)
    			else (select top 1 ANAHTAR from GENINI where BOLUM=convert(int,'-2701'+convert(varchar(10),E2.MARKA)) and DEGER=E2.MODEL and DIL=-1) end),
    KA_SIRA = CASE WHEN @Mod IN (3,5) THEN
                (SELECT CASE WHEN @Mod = 5 THEN CAST(MAX(KA.DEGISTIRMETARIHI) AS FLOAT)
                             ELSE CAST(MAX(KA.SAY) AS FLOAT) END
                 FROM KULLANICI_ARAMA KA
                 WHERE KA.KAYITID = E2.ID AND KA.KULID = @KulId AND KA.MODUL = @Modul)
              END
    FROM PagesList p
    inner join EKIPMANLAR E2 on E2.ID = p.EkipmanID
    WHERE 1=1
      -- Sube-yetki suzgeci (app-uretimi tam-sayi listesi; yalniz SubeVarmi ise gonderilir).
      -- LIKE-tabanli uyelik testi (STRING_SPLIT/dinamik SQL'siz, tum surumlerde calisir).
      AND (@SubeList IS NULL OR @SubeList = N''
           OR (N',' + @SubeList + N',') LIKE (N'%,' + CAST(E2.SUBEID AS nvarchar(20)) + N',%'))
      -- Son/Sik: yalniz kullanicinin actigi ekipmanlar (KULLANICI_ARAMA), PK=E2.ID.
      AND (@Mod NOT IN (3,5)
           OR EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = E2.ID AND KA.KULID = @KulId AND KA.MODUL = @Modul))
    -- Mod 4: KA_SIRA tum satirlarda NULL -> onek etkisiz -> orijinal 'order by 2,AD' (=USTID,AD).
    -- Mod 3/5: KA_SIRA DESC (Sik=SAY / Son=tarih), esitlik bozan sabit anahtar USTID,AD.
    ORDER BY KA_SIRA DESC, USTID, AD;
END;

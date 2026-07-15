-- ============================================================
-- GenDepoUpdate29 : Liste SP'lerine SENARYO kolonu (fatura + siparis)
--   ANA DB. Mevcut sp_Prog_AlisSatis_IrsFatFisKons + _Siparis tanimini alip
--   SELECT'e SENARYO ekler (fatura=F.SENARYO; siparis=NULL, SIPARIS'te yok).
--   Dinamik ALTER (sp_executesql), TEK BATCH (GO yok). Idempotent (zaten varsa atlar).
--   BAGIMLILIK: bu SP'ler onceden kurulmus olmali. -I (QI ON) + -f 65001 ile calistir.
-- ============================================================
/* ============================================================================
   Fatura/Sipariş liste SP'lerine SENARYO kolonu ekler.
   ----------------------------------------------------------------------------
   sp_Prog_AlisSatis_IrsFatFisKons (fatura) ve sp_Prog_AlisSatis_Siparis (siparis)
   base SELECT'inde F.TIPI var ama F.SENARYO YOK -> grid "Senaryo" kolonu bos kaliyor.
   Bu patch, SP tanimini alip SELECT'e F.SENARYO ekler (F.TIPI'nin hemen yanina)
   ve ALTER ile geri yazar. SP'ler dosyada olmadigi icin (yalniz DB'de) dinamik
   REPLACE ile yapilir; boylece Turkce icerik editorden gecmeden korunur.

   IDEMPOTENT: zaten eklenmisse dokunmaz. QUOTED_IDENTIFIER ON korunur.
   Calistirma:  sqlcmd -S .. -d <DB> -C -I -f 65001 -i sp_senaryo_ekle.sql
   ============================================================================ */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

DECLARE @def nvarchar(max);

/* ---- Fatura listesi ---- */
SET @def = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_AlisSatis_IrsFatFisKons'));
IF @def IS NOT NULL AND @def NOT LIKE '%F.TIPI,F.SENARYO%'
BEGIN
  SET @def = STUFF(@def, CHARINDEX('CREATE', @def), 6, 'ALTER');            -- CREATE PROCEDURE -> ALTER PROCEDURE
  SET @def = REPLACE(@def, 'F.TIPI,F.REHBERID', 'F.TIPI,F.SENARYO,F.REHBERID');
  EXEC sys.sp_executesql @def;
  PRINT 'sp_Prog_AlisSatis_IrsFatFisKons: F.SENARYO eklendi';
END
ELSE
  PRINT 'sp_Prog_AlisSatis_IrsFatFisKons: zaten SENARYO var / SP yok - atlandi';

/* ---- Siparis listesi ----
   DIKKAT: Siparis SP'si SIPARIS tablosunu sorgular ve SIPARIS'te SENARYO kolonu
   YOKTUR (senaryo e-Fatura kavrami). Grid kolonunun hata vermemesi + fatura ile
   ayni alan setine sahip olmasi icin SENARYO=NULL (sabit) doldurulur. */
SET @def = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_AlisSatis_Siparis'));
IF @def IS NOT NULL AND @def NOT LIKE '%SENARYO=CAST(NULL%'
BEGIN
  SET @def = STUFF(@def, CHARINDEX('CREATE', @def), 6, 'ALTER');
  -- Onceki hatali F.SENARYO eklemesini geri al (varsa), sonra dogru NULL sabitini koy
  SET @def = REPLACE(@def, 'F.TIPI,F.SENARYO,F.REHBERID', 'F.TIPI,F.REHBERID');
  SET @def = REPLACE(@def, 'F.TIPI,F.REHBERID', 'F.TIPI,SENARYO=CAST(NULL AS smallint),F.REHBERID');
  EXEC sys.sp_executesql @def;
  PRINT 'sp_Prog_AlisSatis_Siparis: SENARYO=NULL eklendi (SIPARIS''te senaryo yok)';
END
ELSE
  PRINT 'sp_Prog_AlisSatis_Siparis: zaten SENARYO=NULL var / SP yok - atlandi';

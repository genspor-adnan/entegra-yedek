-- ============================================================
-- e-Belge UBL SIKISTIRMA (UBL_ZIP) opsiyonunu ACIK yap.
-- Opsiyon sabiti: Ops_FaturaOpsiyon_UBL_ZIP = -24119  (GENINI.BOLUM)
--
-- NOT: Uygulama bu opsiyonu VARSAYILAN ACIK okur (satir yoksa da zip yapar).
--      Bu script yalnizca acikligi GENINI'ye kalici/net yazmak icindir.
--
-- ReadBoolean sarti: BOLUM=-24119, DIL=0 icin TAM 1 satir olmali.
--   DEGER='1' -> ACIK, DEGER='0' -> KAPALI, (satir yok / mukerrer) -> varsayilan (ACIK).
-- Bu yuzden once temizleyip tek satir yaziyoruz (WriteBoolean ile birebir ayni).
-- ============================================================

DELETE FROM GENINI WHERE BOLUM = -24119 AND DIL = 0;
INSERT INTO GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA)
VALUES (-24119, NULL, 1, 0, NULL);

-- Sikistirmanin calismasi icin EBELGE.UBL_XML_ZIP kolonu gerekir.
-- Uygulama da ilk yazimda otomatik ekliyor; burada garanti olarak ekliyoruz.
IF COL_LENGTH('dbo.EBELGE','UBL_XML_ZIP') IS NULL
    ALTER TABLE dbo.EBELGE ADD UBL_XML_ZIP varbinary(max) NULL;

-- Kontrol:
SELECT OPSIYON_DEGER = DEGER,
       DURUM = CASE WHEN DEGER = '1' THEN 'ACIK (zip)' ELSE 'KAPALI' END
FROM GENINI WHERE BOLUM = -24119 AND DIL = 0;

SELECT UBL_XML_ZIP_KOLON =
       CASE WHEN COL_LENGTH('dbo.EBELGE','UBL_XML_ZIP') IS NULL
            THEN 'YOK' ELSE 'VAR' END;

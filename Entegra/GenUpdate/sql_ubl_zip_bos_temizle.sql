-- Bos UBL sikistirilmis (COMPRESS('')) gelen kayitlari temizle.
-- Bunlar var-mi kontrolunde "UBL var" gorunup gercek UBL'in tekrar indirilmesini
-- engelliyordu ve onizlemede "UBL bulunamadi" veriyordu.
-- Iki kolonu da NULL yap -> sonraki Cek'te UBL yeniden indirilir.
-- Once kac tane oldugunu goster:
SELECT BOS_ZIP_KAYIT = COUNT(*)
FROM EBELGE
WHERE UBL_XML_ZIP IS NOT NULL
  AND LEN(CAST(DECOMPRESS(UBL_XML_ZIP) AS NVARCHAR(MAX))) = 0;

UPDATE EBELGE
   SET UBL_XML_ZIP = NULL, UBL_XML = NULL
 WHERE UBL_XML_ZIP IS NOT NULL
   AND LEN(CAST(DECOMPRESS(UBL_XML_ZIP) AS NVARCHAR(MAX))) = 0;

SELECT TEMIZLENEN = @@ROWCOUNT;

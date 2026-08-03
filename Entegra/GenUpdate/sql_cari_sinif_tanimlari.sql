/*
  Cari karti "Sinif" listesinin baslik kaydi.
  Ops_CariKart_Sinif = -2203

  Sinif degerleri zaten GENINI.BOLUM = -2203 altinda tanimlidir.
*/
SET NOCOUNT ON;

IF NOT EXISTS (
  SELECT 1
  FROM GENINI
  WHERE BOLUM = 0
    AND DEGER = -2203
    AND DIL = -1
)
BEGIN
  INSERT INTO GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA)
  VALUES (0, N'Sınıf', -2203, -1, 0);
END;

SELECT BOLUM, ANAHTAR, DEGER, DIL, SIRA
FROM GENINI
WHERE BOLUM = 0
  AND DEGER = -2203
  AND DIL = -1;

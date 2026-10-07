-- Update_SQL_202: İhraç kayıtlı fatura KDV muafiyet nedenleri.
-- TIPI=9 faturada PLANID ile saklanir; e-Belge XML/JSON'da TaxExemptionReason olur.
-- Veri degistirmez, sadece eksik GENINI seceneklerini ekler; idempotenttir.

SET NOCOUNT ON;

DECLARE @Muafiyet TABLE (Kod INT NOT NULL, Aciklama NVARCHAR(250) NOT NULL);
INSERT INTO @Muafiyet (Kod, Aciklama) VALUES
  (701, N'701 - 3065 s. KDV Kanununun 11/1-c md. Kapsamındaki İhraç Kayıtlı Satış'),
  (702, N'702 - DİİB ve Geçici Kabul Rejimi Kapsamındaki Satışlar'),
  (703, N'703 - 4760 s. ÖTV Kanununun 8/2 Md. Kapsamındaki İhraç Kayıtlı Satış'),
  (704, N'704 - 3065 sayılı KDV Kanununun (11/1-c) maddesi ve 4760 s. Ötv Kanununun 8/2. Md. Kapsamındaki İhraç Kayıtlı Satış');

INSERT INTO dbo.GENINI (BOLUM, DIL, DEGER, ANAHTAR, SIRA)
SELECT -2334, -1, M.Kod, M.Aciklama, M.Kod
FROM @Muafiyet M
WHERE NOT EXISTS
(
  SELECT 1 FROM dbo.GENINI G
  WHERE G.BOLUM = -2334 AND G.DIL = -1 AND G.DEGER = M.Kod
);

PRINT N'Update202: İhraç kayıtlı fatura muafiyet nedenleri kontrol edildi.';

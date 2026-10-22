-- Update_SQL_211: KASA.REHBERILETID - tahsilat/odeme (nakit) ekraninda musteri iletisim adi.
--   Tahakkuk (FATBASLIK.REHBERILETID zaten var) ile ayni: secilen REHBERILETISIM.ID tutulur.
--   Yeni kolon NULL; mevcut kayitlar degismez. Tekrar calistirilirsa atlanir.
IF COL_LENGTH('dbo.KASA', 'REHBERILETID') IS NULL
BEGIN
    ALTER TABLE dbo.KASA ADD REHBERILETID INT NULL;
    PRINT N'Update211: KASA.REHBERILETID eklendi.';
END
ELSE
    PRINT N'Update211: KASA.REHBERILETID zaten var - atlandi.';

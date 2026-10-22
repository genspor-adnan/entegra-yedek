-- Update_SQL_214: REHBERALIAS.EPOSTA - e-Arsiv faturasi bu adrese e-posta ile gonderilsin mi.
--   Cari listesi > Alias gridinde "E-Posta" kutusu (varsayilan isaretli).
--   Hazirlamada "e-posta gonderilsin mi?" sorusuna Hayir denirse 0 yazilir;
--   o zaman izibiz'e mail istenmez ve belge KAGIT gonderim seklinde gider.
--   Mevcut satirlar 1 (eskisi gibi e-posta gider). Tekrar calistirilirsa atlanir.
SET QUOTED_IDENTIFIER ON;   -- REHBERALIAS'ta filtreli index (UX_VARSAYILAN) var
SET ANSI_NULLS ON;
IF COL_LENGTH('dbo.REHBERALIAS', 'EPOSTA') IS NULL
BEGIN
    ALTER TABLE dbo.REHBERALIAS ADD EPOSTA BIT NOT NULL
        CONSTRAINT DF_REHBERALIAS_EPOSTA DEFAULT ((1));
    PRINT N'Update214: REHBERALIAS.EPOSTA eklendi.';
END
ELSE
    PRINT N'Update214: REHBERALIAS.EPOSTA zaten var - atlandi.';

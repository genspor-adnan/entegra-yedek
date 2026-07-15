-- ============================================================
-- sp_liste_perf_indexler.sql
--   SP-liste ekranlari (sp_Prog_*_Liste) icin performans index'leri.
--   Sorgu SONUCUNU DEGISTIRMEZ (parite korunur), yalniz hizlandirir.
--   HER MUSTERI DB'sinde bir kez calistir (exe/SP deploy ile birlikte).
-- ============================================================

-- IK personel/aday listesi: NOTLAR alt-sorgusu
--   (select top 1 GY.YORUM from GOREVYORUM GY where R.ID=GY.GOREVID and GY.TUR=11 order by GY.TARIH desc)
--   GOREVYORUM'da GOREVID/TUR index'i yoktu -> her satir icin tam tarama (348 satirda ~31.668 okuma).
--   Bu index seek'e cevirir (~500ms -> ~170ms). YORUM nvarchar(max) oldugu icin INCLUDE edilmez (key lookup).
--   Ayrica Gorev/Cari NOTLAR aramalarina da fayda saglar.
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_GOREVYORUM_Gorevid_Tur'
                 AND object_id = OBJECT_ID('dbo.GOREVYORUM'))
    CREATE NONCLUSTERED INDEX IX_GOREVYORUM_Gorevid_Tur
        ON dbo.GOREVYORUM (GOREVID, TUR, TARIH DESC);
GO

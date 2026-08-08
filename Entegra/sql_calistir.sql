SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @sip INT = (SELECT TOP 1 S.ID FROM SIPARIS S
   WHERE S.TUR=19 AND S.DURUM IN (0,1)
     AND EXISTS(SELECT 1 FROM SIPARISDETAY SD CROSS APPLY dbo.fn_Api_Donusum_Kalan(2,409,SD.ID,0) K
                WHERE SD.SIPARISID=S.ID AND K.Kalan>0.0001)
   ORDER BY S.ID DESC);
SELECT 'Kaynak siparis' AS x, ID, TUR, DURUM, SIPARISNO FROM SIPARIS WHERE ID=@sip;
SELECT 'Kalan satirlari' AS x, SD.ID, SD.URUNID, SD.ADET, K.Donusen, K.Kalan
FROM SIPARISDETAY SD CROSS APPLY dbo.fn_Api_Donusum_Kalan(2,409,SD.ID,0) K WHERE SD.SIPARISID=@sip;

BEGIN TRAN;
-- SP'yi dogrulamak icin bozuk tetikleyiciyi SADECE bu transaction icinde devre disi birak
DISABLE TRIGGER trg_Siparis_Aktarim ON SIPARIS;
DECLARE @j NVARCHAR(MAX) = N'{"SiparisId":' + CAST(@sip AS varchar(20)) +
   N',"HedefTur":14,"Tarih":"2026-08-08","Oturum":{"KulId":2,"SubeId":-1}}';
EXEC dbo.sp_Api_Donusum_SiparistenBelge_Json @j;

DECLARE @hed INT = (SELECT TOP 1 ID FROM FATBASLIK ORDER BY ID DESC);
SELECT 'Hedef belge' AS x, ID, TUR, FATURANO, REHBERID, FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI, ACIKLAMA FROM FATBASLIK WHERE ID=@hed;
SELECT 'Hedef satirlar' AS x, ID, URUNID, ADET, BIRIMFIYAT, TUTAR, KDV, YERI, YERID FROM FATURA WHERE FATBASID=@hed;
SELECT 'Kaynak kalan (tran ici)' AS x, SD.ID, K.Kalan FROM SIPARISDETAY SD CROSS APPLY dbo.fn_Api_Donusum_Kalan(2,409,SD.ID,0) K WHERE SD.SIPARISID=@sip;
SELECT 'Siparis durumu (tran ici)' AS x, DURUM FROM SIPARIS WHERE ID=@sip;
ROLLBACK;
SELECT 'Tetikleyici geri acildi mi' AS x, is_disabled FROM sys.triggers WHERE name='trg_Siparis_Aktarim';
SELECT 'Rollback sonrasi hedef belge' AS x, COUNT(*) AS Adet FROM FATBASLIK WHERE ID=@hed;

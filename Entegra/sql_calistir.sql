SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @id INT = (SELECT TOP 1 ID FROM FATBASLIK WHERE ACIKLAMA IS NOT NULL AND ACIKLAMA <> '' ORDER BY ID DESC);
BEGIN TRAN;
INSERT INTO ALANLAR (EKRANADI, TUR, TABLO, ALANADI, CAPTION, [LEFT], [TOP], WIDTH, HEIGHT)
VALUES ('TESTAPI', 1, 'FATBASLIK', 'ACIKLAMA', 'Aciklama', 10, 10, 200, 20),
       ('TESTAPI', 1, 'FATBASLIK', 'FATURATARIH', 'Fatura Tarihi', 10, 40, 120, 20),
       ('TESTAPI', 1, 'FATBASLIK', 'DOVIZKUR', 'Kur', 10, 70, 100, 20);
DECLARE @j NVARCHAR(400) = N'{"Ekran":"TESTAPI","Tablo":"FATBASLIK","KayitId":' + CAST(@id AS varchar(20)) + N'}';
EXEC dbo.sp_Api_Belge_EkAlan_Json @j;
ROLLBACK;

DECLARE @sid INT = (SELECT TOP 1 ID FROM FATURA ORDER BY ID DESC);
DECLARE @bid INT = (SELECT FATBASID FROM FATURA WHERE ID=@sid);
BEGIN TRAN;
DECLARE @lj NVARCHAR(MAX) = N'{"Tablo":"FATURA","TabNo":110,"KayitId":' + CAST(@sid AS varchar(20)) +
  N',"UstTabNo":14,"UstId":' + CAST(@bid AS varchar(20)) + N',"Oturum":{"KulId":9,"Istasyon":"XMLTEST"}}';
EXEC dbo.sp_Api_Log_KayitSil_Json @lj;
DECLARE @depo sysname = dbo.fn_Api_DepoDBAdi();
DECLARE @s NVARCHAR(MAX) = N'SELECT TOP 1 ''LOG JSON'' AS x, CAST(DECOMPRESS(BILGI) AS nvarchar(max)) AS J FROM [' + @depo + N'].dbo.ISLEMLOG ORDER BY ID DESC;';
EXEC sp_executesql @s;
ROLLBACK;
SELECT 'FATURA loglanabilir kolon' AS x, COUNT(*) AS Adet FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id
 WHERE c.object_id=OBJECT_ID('FATURA') AND c.generated_always_type=0 AND c.is_hidden=0
   AND t.name NOT IN ('varbinary','binary','image','text','ntext','xml','geography','geometry','hierarchyid','sql_variant','timestamp');

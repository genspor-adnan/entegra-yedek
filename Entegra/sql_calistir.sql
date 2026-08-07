SET NOCOUNT ON;
DECLARE @depo sysname = dbo.fn_Api_DepoDBAdi();
DECLARE @lt sysname = N'LOG' + CAST(YEAR(GETDATE()) AS varchar(4));
DECLARE @s NVARCHAR(MAX) = N'DELETE FROM [' + @depo + N'].dbo.' + @lt + N' WHERE ID IN (607,608);
SELECT ''silinen'' AS x, @@ROWCOUNT AS Adet;
SELECT ''kalan test logu'' AS x, COUNT(*) AS Adet FROM [' + @depo + N'].dbo.' + @lt + N'
 WHERE ISTASYON = ''TESTPC'' OR (KULLANICIID = 7 AND TABLOID = 110);';
EXEC sp_executesql @s;

SET NOCOUNT ON;
SELECT i.name AS pk_name FROM BILIM.sys.indexes i WHERE i.object_id=OBJECT_ID('BILIM.dbo.BANKALAR') AND i.is_primary_key=1;

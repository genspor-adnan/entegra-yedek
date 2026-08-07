SET NOCOUNT ON;
SELECT c.name, t.name AS tip, c.max_length, c.is_nullable, c.is_identity
FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id
WHERE c.object_id=OBJECT_ID('KULLANICI_ARAMA') ORDER BY c.column_id;

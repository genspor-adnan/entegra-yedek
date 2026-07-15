-- KASA.BELGENO 15 -> 30 genisletme (uzun belge numaralari icin; idempotent).
-- Excel/MT940 banka girislerinde '2021-12-07-08.30.12' gibi belge nolar 15'e sigmiyordu.
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
           WHERE TABLE_NAME='KASA' AND COLUMN_NAME='BELGENO'
             AND CHARACTER_MAXIMUM_LENGTH < 30)
   ALTER TABLE dbo.KASA ALTER COLUMN BELGENO nvarchar(30) NULL;

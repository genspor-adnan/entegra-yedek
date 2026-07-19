-- ============================================================
-- GenDepoUpdate41: _USER (kart ek kullanici alanlari) tablolarini TABLOLAR
-- registry'sine ekler. Bu kayit olmadan UInfo "Geri Al" _USER satirini geri
-- INSERT edemez (GeriTabloAdiGetir tablo adini TABLOLAR'dan cozer).
--   TABLOID 500-511 blogu -> _USER tablolari (Utablo.pas TabNo_*_USER ile ayni sayi).
-- Ana DB'de calisir. Idempotent (MERGE); yalniz FIZIKSEL olarak var olan _USER
-- tablolari icin kayit yazar (GenDepoUpdate35/39 ile olusmus olmali).
-- ============================================================
set nocount on;

IF OBJECT_ID('dbo.TABLOLAR','U') IS NULL
BEGIN
  RAISERROR('TABLOLAR yok; once sql_tablolar_kur.sql calistirin.', 16, 1);
  RETURN;
END;

declare @Kaynak table(TABLOID int primary key, TABLOADI varchar(64), GORUNUM nvarchar(128), MODUL nvarchar(64));
insert into @Kaynak values
  (500, 'DEMIRBAS_USER',                N'Ek Alan', N'Demirbaş'),
  (501, 'DOKUMAN_USER',                 N'Ek Alan', N'Doküman'),
  (502, 'FATBASLIK_USER',               N'Ek Alan', N'Fatura'),
  (503, 'FATURA_USER',                  N'Ek Alan', N'Fatura'),
  (504, 'REHBER_USER',                  N'Ek Alan', N'Cari'),
  (505, 'SERVIS_USER',                  N'Ek Alan', N'Servis'),
  (506, 'SERVISHAREKET_USER',           N'Ek Alan', N'Servis'),
  (507, 'SIPARIS_USER',                 N'Ek Alan', N'Sipariş'),
  (508, 'STOKLAR_USER',                 N'Ek Alan', N'Stok'),
  (509, 'TEKLIF_USER',                  N'Ek Alan', N'Teklif'),
  (510, 'URETIMEMRI_USER',              N'Ek Alan', N'Üretim Emri'),
  (511, 'URETIMOPERASYONPERSONEL_USER', N'Ek Alan', N'Üretim'),
  (512, 'DEMIRBAS_TUTANAK',             N'Tutanak', N'Demirbaş');

-- Fiziksel tablosu olmayanlari ele (henuz kurulmamis _USER tablosu registry'ye girmesin)
delete K from @Kaynak K where object_id('dbo.' + K.TABLOADI, 'U') is null;

MERGE dbo.TABLOLAR AS h
USING @Kaynak AS k
ON h.TABLOID = k.TABLOID
WHEN MATCHED THEN UPDATE SET TABLOADI=k.TABLOADI, GORUNUM=k.GORUNUM, MODUL=k.MODUL
WHEN NOT MATCHED THEN INSERT(TABLOID, TABLOADI, GORUNUM, MODUL)
  VALUES(k.TABLOID, k.TABLOADI, k.GORUNUM, k.MODUL);

select TABLOID, TABLOADI, GORUNUM, MODUL from dbo.TABLOLAR where TABLOID between 500 and 511 order by TABLOID;

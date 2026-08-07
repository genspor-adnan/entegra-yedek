/* ============================================================================
   olaylar_bilgino_int.sql   —   MUSTERI ANA veritabaninda calistirilir

   SORUN (guncelleme KILITLENMESI):
     GUNCELLEMELER zinciri her komuttan sonra OLAYLAR tablosuna log yazar:
        Tablo.OlaylarIslemleri(1,10,101,-1,1, <VERSIYONNO>, ...)   -> BILGINO = VERSIYONNO
     Eski kurulumlarda OLAYLAR.BILGINO **smallint** (max 32767). Komut numaralari
     bu siniri asinca (32859, 32860, ...) log INSERT'i
        "Arithmetic overflow error for data type smallint, value = 32859."
     verir; exception VersiyonGuncelle'yi KOPARIR, GENINI'deki versiyon numarasi
     ILERLEMEZ ve musteri her acilista AYNI komutta takilir kalir.

   TAVUK-YUMURTA: bunu duzelten guncelleme komutu (32864 "OLAYLAR tablosu BILGINO
     int yapildi") zincirin ILERISINDEDIR -> ona hic ulasilamaz.

   BELIRTI: yeni exe kuruldu, depo (<DB>_GENDEPO) olustu ama ICI BOS/eksik
     (yalniz LOG<yyyy> var), synonym yok, GENINI'deki VersiyonNo eski degerde duruyor.

   COZUM: Bu betik kolonu int'e cevirir. Sonraki acilista zincir kaldigi yerden
     devam eder ve depo tablolari (EBELGE, LOGREFERANS, LOGCOZUM, TABLOLAR ...) kurulur.

   NOT: 06.08.2026 sonrasi surumlerde uygulama bunu acilista KENDI onarir
     (UVersiyonGuncelle.OlaylarTablosuHazirla) ve log hatasi artik zinciri kirmaz.
     Bu betik, eski exe ile kilitli kalmis kurulumlar icindir.

   Idempotent: tekrar calistirmak zararsizdir.
============================================================================ */
SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM sys.columns c
            JOIN sys.types t ON t.user_type_id = c.user_type_id
           WHERE c.object_id = OBJECT_ID('dbo.OLAYLAR')
             AND c.name = 'BILGINO' AND t.name = 'smallint')
BEGIN
    ALTER TABLE dbo.OLAYLAR ALTER COLUMN BILGINO int;
    PRINT 'OLAYLAR.BILGINO -> int yapildi.';
END
ELSE
    PRINT 'OLAYLAR.BILGINO zaten uygun (smallint degil).';

/* ---- Durum ---------------------------------------------------------------- */
SELECT VERITABANI = DB_NAME(),
       BILGINO_TIPI = (SELECT t.name FROM sys.columns c
                        JOIN sys.types t ON t.user_type_id = c.user_type_id
                       WHERE c.object_id = OBJECT_ID('dbo.OLAYLAR') AND c.name = 'BILGINO'),
       VERSIYON_NO  = (SELECT TOP 1 DEGER FROM dbo.GENINI WHERE BOLUM = -10022),
       DEPO_ADI     = (SELECT TOP 1 ANAHTAR FROM dbo.GENINI WHERE BOLUM = -24120 AND DIL = 0);

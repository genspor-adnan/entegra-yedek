/* ============================================================================
   vergino_temizle.sql   —   MUSTERI ANA veritabaninda calistirilir

   AMAC: VKN/TCKN alanlarindaki AYRAC karakterlerini (bosluk, tire, nokta, slash)
     temizler. Yalniz rakam kalir.

   NEDEN: Karta "12 23 545 871" gibi girilen numara
     - e-Belge ALIAS sorgusunda bulunamaz (entegratore bosluklu gider),
     - e-Fatura XML/JSON'ina gecersiz olarak yazilir -> GIB REDDEDER,
     - VKN/TCKN sema secimi uzunluga baktigi icin YANLIS tip secilir
       (Length("12 23 545 871") = 13; ne 10 ne 11).

   KAPSAM:
     1) FATBASLIK.VNO   - fatura basligindaki cari VKN/TCKN
     2) REHBERBILGI.BILGI - cari kartindaki VKN/TCKN
        (etiket ADI musteriye gore degisebilir; dogru satir REHBERAYAR uzerinden
         VARSAYILAN = 22 kodu ile bulunur - sabit 'Vergi No' metnine guvenilmez)

   GUVENLIK KURALI - SADECE "AYRAC TEMIZLENINCE GECERLI OLAN" kayitlar duzeltilir:
     temizlenmis hali 10 veya 11 HANE ve tamami rakam olmali.
     Boylece icine vergi dairesi adi / 'XXX' / '.' gibi seyler yazilmis kayitlara
     DOKUNULMAZ; onlar raporda listelenir ve elle degerlendirilir.

   KULLANIM:
     - Once oldugu gibi calistirin -> yalnizca RAPOR, hicbir sey degismez.
     - Uygulamak icin @Uygula = 1 yapip tekrar calistirin.
     - Idempotent: temiz kayitlar zaten kalibin disinda kalir.

   NOT: 07.08.2026 sonrasi surumlerde uygulama VKN'yi KAYIT ANINDA normalize eder
     (Fetautil.VergiNoTemizle); bu betik GECMIS veriyi duzeltir.
============================================================================ */
SET NOCOUNT ON;
-- Filtreli index / computed column iceren tablolarda (FATBASLIK) UPDATE icin ZORUNLU.
--   sqlcmd bunlari varsayilan OFF baslatir -> "UPDATE failed ... QUOTED_IDENTIFIER".
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

------------------------------------------------------------------------------
DECLARE @Uygula BIT = 0;      -- 0 = yalniz rapor   |   1 = TEMIZLIGI UYGULA
------------------------------------------------------------------------------

/* Ayraclardan arindirilmis hali (fonksiyon olusturmadan, ic ice REPLACE) */
;WITH T AS (
    SELECT KAYNAK = 'FATBASLIK.VNO',
           ID     = CAST(ID AS bigint),
           ESKI   = VNO,
           YENI   = REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(VNO)),
                    ' ', ''), '-', ''), '.', ''), '/', '')
    FROM FATBASLIK
    WHERE VNO IS NOT NULL AND VNO <> '' AND VNO LIKE '%[^0-9]%'
    UNION ALL
    SELECT 'REHBERBILGI.BILGI',
           CAST(rb.ID AS bigint),
           rb.BILGI,
           REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(rb.BILGI)),
           ' ', ''), '-', ''), '.', ''), '/', '')
    FROM REHBERBILGI rb
    WHERE EXISTS (SELECT 1 FROM REHBERAYAR ra
                   WHERE ra.ETIKET = rb.ETIKET AND ra.VARSAYILAN = 22)
      AND rb.BILGI IS NOT NULL AND rb.BILGI <> '' AND rb.BILGI LIKE '%[^0-9]%'
)
SELECT * INTO #T FROM T;

/* Duzeltilebilir mi? (temizlenince tamami rakam VE 10/11 hane) */
ALTER TABLE #T ADD DURUM nvarchar(60);
UPDATE #T
SET DURUM = CASE
      WHEN YENI LIKE '%[^0-9]%'      THEN N'RAKAM DISI ICERIK (elle bakilmali)'
      WHEN LEN(YENI) IN (10, 11)     THEN N'DUZELTILEBILIR'
      WHEN YENI = ''                 THEN N'BOSALIYOR (elle bakilmali)'
      ELSE N'HANE SAYISI TUTMUYOR (elle bakilmali)'
    END;

/* ---- 1) Ozet -------------------------------------------------------------- */
SELECT KAYNAK, DURUM, ADET = COUNT(*) FROM #T GROUP BY KAYNAK, DURUM ORDER BY KAYNAK, DURUM;

/* ---- 2) Duzeltilecekler (ornek) ------------------------------------------- */
SELECT TOP 20 KAYNAK, ID, ESKI = '[' + ESKI + ']', YENI
FROM #T WHERE DURUM = N'DUZELTILEBILIR' ORDER BY KAYNAK, ID;

/* ---- 3) DOKUNULMAYACAKLAR (elle degerlendirin) ---------------------------- */
SELECT TOP 20 KAYNAK, ID, ICERIK = '[' + ESKI + ']', DURUM
FROM #T WHERE DURUM <> N'DUZELTILEBILIR' ORDER BY KAYNAK, ID;

IF @Uygula = 0
BEGIN
    PRINT '';
    PRINT '*** RAPOR MODU - hicbir degisiklik yapilmadi. ***';
    PRINT 'Uygulamak icin @Uygula = 1 yapip tekrar calistirin.';
    RETURN;
END

/* ---- 4) Uygulama ---------------------------------------------------------- */
BEGIN TRY
    BEGIN TRAN;

    UPDATE f SET f.VNO = t.YENI
    FROM FATBASLIK f
    JOIN #T t ON t.ID = f.ID AND t.KAYNAK = 'FATBASLIK.VNO' AND t.DURUM = N'DUZELTILEBILIR';
    DECLARE @fb INT = @@ROWCOUNT;

    UPDATE r SET r.BILGI = t.YENI
    FROM REHBERBILGI r
    JOIN #T t ON t.ID = r.ID AND t.KAYNAK = 'REHBERBILGI.BILGI' AND t.DURUM = N'DUZELTILEBILIR';
    DECLARE @rb INT = @@ROWCOUNT;

    COMMIT;
    PRINT 'FATBASLIK.VNO       duzeltilen: ' + CAST(@fb AS varchar(10));
    PRINT 'REHBERBILGI (VKN)   duzeltilen: ' + CAST(@rb AS varchar(10));
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT 'HATA: ' + ERROR_MESSAGE();
    RETURN;
END CATCH

/* ---- 5) Kalan durum ------------------------------------------------------- */
SELECT KALAN_FATBASLIK = (SELECT COUNT(*) FROM FATBASLIK
                           WHERE VNO IS NOT NULL AND VNO <> '' AND VNO LIKE '%[^0-9]%'),
       KALAN_REHBERBILGI = (SELECT COUNT(*) FROM REHBERBILGI rb
                             WHERE EXISTS (SELECT 1 FROM REHBERAYAR ra
                                            WHERE ra.ETIKET = rb.ETIKET AND ra.VARSAYILAN = 22)
                               AND rb.BILGI IS NOT NULL AND rb.BILGI <> ''
                               AND rb.BILGI LIKE '%[^0-9]%');
PRINT 'NOT: Kalanlar "elle bakilmali" olarak isaretlenen kayitlardir (rapor bolum 3).';

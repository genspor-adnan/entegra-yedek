-- ============================================================
-- sp_Prog_Log_Liste_Json2 — Info/Log ekrani (UInfo) Genel listesi (MSSQL-ONLY)
--   IKI PARAM (aile deseni):
--     @Baslik   = SELECT ek kolonlari. Bu listede KULLANILMAZ (kolon seti sabit,
--                 grid DFM'de ada gore bagli) — imza uyumu icin kabul edilir.
--     @Kosullar = filtreler (JSON). Degerler PARAMETRELI/cast'li — eski kod
--                 filtreleri string olarak SQL'e gomuyordu (Esc ile), artik gomulmez.
--   Kolon seti UInfo.TabLogYukle ile BIREBIR:
--     TARIH GUN KAYITNO USTTABLOID ISLEMTIPI ISLEM FIRMA PCADI ANAHTAR KOD AD ADET
--   PG karsiligi: pg/schema/45_fn_prog_log_liste_json2.sql
--
--   NOT: ISLEMLOG / LOGREFERANS ana DB'de SYNONYM'dir (-> depo DB, vars. GENDEPO).
--        Synonym yoksa bu SP de calismaz; onarim: GenDepoUpdate61.sql.
--
--   JSON anahtarlari (absent -> NULL -> o filtre YOK):
--     TarihBas, TarihBit  (date; YALNIZ KayitNo ve Ara bosken uygulanir)
--     Kullanici, Modul, KayitNo, Istasyon, Ara   (metin)
--     IcerikAra (bit: 1 -> log JSON icerigi icinde ara, 0 -> LOGREFERANS KOD/AD)
--     Ekleme, Degistirme, Silme (bit; UCU DE 0 -> tum islem tipleri)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Log_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- kullanilmiyor (imza uyumu)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent/bos key -> NULL. ----
    DECLARE @TarihBas   DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATE);
    DECLARE @TarihBit   DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATE);
    DECLARE @Kullanici  NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.Kullanici'), N'');
    DECLARE @Modul      NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.Modul'),     N'');
    DECLARE @KayitNo    NVARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar,'$.KayitNo'),   N'');
    DECLARE @Istasyon   NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Istasyon'),  N'');
    DECLARE @Ara        NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.Ara'),       N'');
    DECLARE @IcerikAra  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IcerikAra')  AS BIT), 0);
    DECLARE @Ekleme     BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Ekleme')     AS BIT), 0);
    DECLARE @Degistirme BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Degistirme') AS BIT), 0);
    DECLARE @Silme      BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Silme')      AS BIT), 0);

    -- Tarih araligi YALNIZ genel arama (Ara) ve Kayit No bosken uygulanir:
    -- onlar girilince aramanin/kaydin TUM gecmisi gelsin (eski davranis birebir).
    DECLARE @TarihUygula BIT = CASE WHEN @KayitNo IS NULL AND @Ara IS NULL THEN 1 ELSE 0 END;
    DECLARE @Bas DATETIME2(0) = CASE WHEN @TarihUygula = 1 THEN CAST(@TarihBas AS DATETIME2(0)) END;
    -- Bitis: gun sonu -> ertesi gunun basi (< karsilastirmasi, saat bilgisi kaybolmaz)
    DECLARE @Bit DATETIME2(0) = CASE WHEN @TarihUygula = 1 AND @TarihBit IS NOT NULL
                                     THEN CAST(DATEADD(DAY, 1, @TarihBit) AS DATETIME2(0)) END;
    -- Hicbir islem tipi secili degilse -> TUMU
    DECLARE @TipHepsi BIT = CASE WHEN @Ekleme = 0 AND @Degistirme = 0 AND @Silme = 0 THEN 1 ELSE 0 END;
    -- LIKE deseni: %deger% (ozel karakter kacisi: [ -> [[])
    DECLARE @KullaniciL NVARCHAR(210) = N'%' + REPLACE(@Kullanici, N'[', N'[[]') + N'%';
    DECLARE @KayitNoL   NVARCHAR(60)  = N'%' + REPLACE(@KayitNo,   N'[', N'[[]') + N'%';
    DECLARE @IstasyonL  NVARCHAR(110) = N'%' + REPLACE(@Istasyon,  N'[', N'[[]') + N'%';
    DECLARE @AraL       NVARCHAR(210) = N'%' + REPLACE(@Ara,       N'[', N'[[]') + N'%';

    -- Master (USTKAYITID) + islem tipi + GUN bazinda GRUPLU.
    SELECT
        TARIH = MAX(L.TARIH),
        GUN   = CAST(L.TARIH AS date),
        KAYITNO = L.USTKAYITID,
        USTTABLOID = L.USTTABLOID,
        L.ISLEMTIPI,
        ISLEM = CASE L.ISLEMTIPI WHEN 0 THEN N'Silme' WHEN 1 THEN N'Ekleme'
                     WHEN 2 THEN N'De' + NCHAR(287) + N'i' + NCHAR(351) + N'tirme' ELSE N'?' END,
        FIRMA = MAX(ISNULL(R.FIRMA, CAST(L.KULLANICIID AS varchar(20)))),
        PCADI = MAX(L.ISTASYON),
        ANAHTAR = MAX(CASE WHEN L.USTTABLOID IN (108,109) THEN N'Tahakkuk'
                           ELSE COALESCE(T.MODUL, T.TABLOADI, CAST(L.USTTABLOID AS varchar(20))) END),
        -- Kod/Ad: once kaydin KENDI referansi (kart: KAYITID=USTKAYITID, TABLOID=USTTABLOID),
        -- yoksa bagli cari/IK (REHBERID) veya stok (STOKID) - LOGREFERANS'tan (guncel).
        -- Cek/Senet (315/316/318/319): kart kendi muhasebe kodu yerine borclu/alacakli CARI
        -- (REHBERID) kod/adi gelsin -> LRk atlanir, LRc (cari) oncelikli.
        -- Uretim Fisi (144), Konsinye (209/219), Banka Odeme/Tahsilat (482/483) de ayni:
        -- once CARI (REHBERID); cari yoksa uretilen stok (LRuf).
        -- COLLATE DATABASE_DEFAULT: LOGREFERANS (depo) ile STOKLAR (ana DB) collation farki.
        -- KOD/AD YALNIZ kart satirindan (TABLOID=USTTABLOID); detay satirlari MAX'e karismasin.
        KOD = MAX(CASE WHEN L.USTTABLOID = 485 THEN N'Opsiyon'
                       WHEN L.TABLOID = L.USTTABLOID THEN
                         COALESCE(CASE WHEN L.USTTABLOID IN (315,316,318,319,144,209,219,482,483) THEN NULL
                                       ELSE NULLIF(LRk.KOD, N'') COLLATE DATABASE_DEFAULT END,
                                  NULLIF(LRc.KOD, N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RL.KOD,  N'') COLLATE DATABASE_DEFAULT,
                                  CASE WHEN L.USTTABLOID IN (144,482,483)
                                       THEN NULLIF(LRk.KOD, N'') COLLATE DATABASE_DEFAULT END,
                                  NULLIF(LRs.KOD,  N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RS.KOD,   N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(LRuf.KOD, N'') COLLATE DATABASE_DEFAULT)
                       WHEN L.USTTABLOID IN (144,209,219) THEN
                         COALESCE(NULLIF(LRcb.KOD, N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RL.KOD,   N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(LRuf.KOD, N'') COLLATE DATABASE_DEFAULT)
                       ELSE
                         COALESCE(CASE WHEN L.USTTABLOID NOT IN (315,316,318,319,144,209,219,482,483)
                                       THEN NULLIF(LRk.KOD, N'') COLLATE DATABASE_DEFAULT END,
                                  NULLIF(RL.KOD, N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RS.KOD, N'') COLLATE DATABASE_DEFAULT)
                  END),
        AD = MAX(CASE WHEN L.USTTABLOID = 485 THEN NULLIF(AYS.SEKSIYON, N'') COLLATE DATABASE_DEFAULT
                      WHEN L.TABLOID = L.USTTABLOID THEN
                        COALESCE(CASE WHEN L.USTTABLOID IN (315,316,318,319,144,209,219,482,483) THEN NULL
                                      ELSE NULLIF(LRk.AD, N'') COLLATE DATABASE_DEFAULT END,
                                 NULLIF(LRc.AD, N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RL.AD,  N'') COLLATE DATABASE_DEFAULT,
                                 CASE WHEN L.USTTABLOID IN (144,482,483)
                                      THEN NULLIF(LRk.AD, N'') COLLATE DATABASE_DEFAULT END,
                                 NULLIF(LRs.AD,  N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RS.AD,   N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(LRuf.AD, N'') COLLATE DATABASE_DEFAULT)
                      WHEN L.USTTABLOID IN (144,209,219) THEN
                        COALESCE(NULLIF(LRcb.AD, N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RL.AD,   N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(LRuf.AD, N'') COLLATE DATABASE_DEFAULT)
                      ELSE
                        COALESCE(CASE WHEN L.USTTABLOID NOT IN (315,316,318,319,144,209,219,482,483)
                                      THEN NULLIF(LRk.AD, N'') COLLATE DATABASE_DEFAULT END,
                                 NULLIF(RL.AD, N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RS.AD, N'') COLLATE DATABASE_DEFAULT)
                 END),
        ADET = COUNT(*)
    FROM ISLEMLOG L
        LEFT JOIN REHBER   R ON R.ID = L.KULLANICIID
        LEFT JOIN TABLOLAR T ON T.TABLOID = L.USTTABLOID
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = L.USTKAYITID AND TABLOID = L.USTTABLOID ORDER BY ID DESC) LRk
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = L.REHBERID AND TABLOID IN (71,73,74) ORDER BY ID DESC) LRc
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = L.STOKID AND TABLOID = 88 ORDER BY ID DESC) LRs
        -- CANLI fallback: LOGREFERANS (cache) bu cariyi/stogu henuz icermiyorsa
        -- ad/kod dogrudan REHBER/STOKLAR'dan gelsin.
        OUTER APPLY (SELECT TOP 1 AD = FIRMA,   KOD FROM REHBER
                     WHERE ID = L.REHBERID AND L.REHBERID > 0) RL
        OUTER APPLY (SELECT TOP 1 AD = STOKADI, KOD FROM STOKLAR
                     WHERE ID = L.STOKID AND L.STOKID > 0) RS
        -- Opsiyon/ayar (485): KAYITID=BOLUM. SEKSIYON = opsiyon bolumu -> AD; KOD sabit 'Opsiyon'.
        OUTER APPLY (SELECT TOP 1 SEKSIYON, AD FROM AYARADI
                     WHERE BOLUM = L.KAYITID AND L.USTTABLOID = 485) AYS
        -- Belge (FATBASLIK) tabanli gruplar (144/209/219): grupta KART satiri yoksa
        -- KOD/AD yine belge CARIsinden gelsin -> canli FATBASLIK.REHBERID -> LOGREFERANS.
        OUTER APPLY (SELECT TOP 1 REHBERID FROM FATBASLIK
                     WHERE ID = L.USTKAYITID AND L.USTTABLOID IN (144,209,219)) FB
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = FB.REHBERID AND TABLOID IN (71,73,74) ORDER BY ID DESC) LRcb
        -- Uretim Fisi (144): uretilen stok = detay (FATURA) ADET>0 olan URUNID
        OUTER APPLY (SELECT TOP 1 KOD = s.KOD, AD = s.STOKADI
                     FROM FATURA f JOIN STOKLAR s ON s.ID = f.URUNID
                     WHERE L.USTTABLOID = 144 AND f.FATBASID = L.USTKAYITID AND f.ADET > 0
                     ORDER BY f.ID) LRuf
    WHERE (@Bas IS NULL OR L.TARIH >= @Bas)
      AND (@Bit IS NULL OR L.TARIH <  @Bit)
      AND (@Kullanici IS NULL OR ISNULL(R.FIRMA, CAST(L.KULLANICIID AS varchar(20))) LIKE @KullaniciL)
      AND (@Modul     IS NULL OR T.MODUL = @Modul)
      AND (@KayitNo   IS NULL OR CAST(L.USTKAYITID AS varchar(20)) LIKE @KayitNoL)
      AND (@Istasyon  IS NULL OR L.ISTASYON LIKE @IstasyonL)
      AND (@Ara IS NULL
           OR (@IcerikAra = 1
               -- "Icerikten Ara": log JSON (BILGI) icinde detayli arama (yavas)
               AND CAST(DECOMPRESS(L.BILGI) AS nvarchar(max)) LIKE @AraL)
           OR (@IcerikAra = 0
               -- Varsayilan: LOGREFERANS KOD/AD (hizli, indeksli, silinmis kayit dahil).
               -- Uc kaynak: kartin kendi kaydi / bagli cari-IK / bagli stok.
               AND EXISTS (SELECT 1 FROM LOGREFERANS r
                           WHERE ((r.KAYITID = L.USTKAYITID AND r.TABLOID = L.USTTABLOID)
                               OR (r.KAYITID = L.REHBERID   AND r.TABLOID IN (71,73,74))
                               OR (r.KAYITID = L.STOKID     AND r.TABLOID = 88))
                             AND (r.AD LIKE @AraL OR r.KOD LIKE @AraL))))
      AND (@TipHepsi = 1
           OR (@Ekleme = 1 AND L.ISLEMTIPI = 1)
           OR (@Degistirme = 1 AND L.ISLEMTIPI = 2)
           OR (@Silme = 1 AND L.ISLEMTIPI = 0))
    GROUP BY CAST(L.TARIH AS date), L.USTKAYITID, L.USTTABLOID, L.ISLEMTIPI
    ORDER BY MAX(L.TARIH) DESC;
END

/* ============================================================================
   İHRACAT e-Fatura DETAY ŞABLONU + GİB KOD LİSTELERİ KURULUM SCRIPTİ
   ----------------------------------------------------------------------------
   Ne yapar:
     1) GİB UBL-TR kod listelerini (Teslim Şartı/INCOTERMS, Taşıma Şekli,
        Paket/Kap Cinsi) GENINI'ye yazar (registry BOLUM=0 + liste öğeleri).
     2) Fatura detay şablonu 'İhracat'ı (YERI=132, giden fatura) 3 combo +
        FOB alanı ile yeniden kurar; combo KAYNAK'ları GENINI listelerine bağlar.

   Mekanizma: REHBERAYAR.KAYNAK = liste adı  ->  GENINI(BOLUM=0,ANAHTAR=ad).DEGER
              = liste BOLUM'u  ->  o BOLUM'daki öğeler combo'ya yüklenir.
              Combo Description=ANAHTAR (görünen), Value=DEGER (REHBERBILGI'ye
              saklanan). Harfli kodlar (FOB, CT) DEGER'e sığmadığından kod,
              ANAHTAR'ın " - " öncesi ön ekinden okunur (emisyon tarafı).

   İDEMPOTENT: tekrar çalıştırılabilir; kayıtlı liste BOLUM'u varsa yeniden
   kullanır. Ana uygulama DB'sinde (BILIM/müşteri DB) çalışır — GENDEPO'da DEĞİL.
   sqlcmd ile UTF-8 çalıştır:  sqlcmd -S .. -d <DB> -C -f 65001 -i ihracat_sablon_kur.sql
   ============================================================================ */
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRAN;

/* ---- 1) Liste BOLUM numaralarını belirle (kayıtlıysa yeniden kullan) ---- */
DECLARE @TeslimB int, @TasimaB int, @KapB int;
SELECT @TeslimB = DEGER FROM GENINI WHERE BOLUM=0 AND ANAHTAR=N'İhracat_Teslim_Şartı';
SELECT @TasimaB = DEGER FROM GENINI WHERE BOLUM=0 AND ANAHTAR=N'İhracat_Taşıma_Şekli';
SELECT @KapB    = DEGER FROM GENINI WHERE BOLUM=0 AND ANAHTAR=N'İhracat_Paket_Kap';
SET @TeslimB = ISNULL(@TeslimB, -11020);   -- rezerve sistem-liste bandı
SET @TasimaB = ISNULL(@TasimaB, -11021);
SET @KapB    = ISNULL(@KapB,    -11022);

/* ---- 2) Registry (BOLUM=0) — eski/yeni adları temizle, yeniden yaz ---- */
DELETE FROM GENINI WHERE BOLUM=0 AND ANAHTAR IN
  (N'İhracat_Teslim_Şartı', N'İhracat_Taşıma_Şekli', N'İhracat_Paket_Kap',
   N'İhracat_Teslim', N'İhracat_Kap_Ambalaj');   -- son iki: eski kısmi adlar
INSERT INTO GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) VALUES
  (0, N'İhracat_Teslim_Şartı', @TeslimB, -1, 1),
  (0, N'İhracat_Taşıma_Şekli', @TasimaB, -1, 1),
  (0, N'İhracat_Paket_Kap',    @KapB,    -1, 1);

/* ---- 3) Liste öğeleri — hedef BOLUM'ları temizle, yeniden doldur ---- */
DELETE FROM GENINI WHERE BOLUM IN (@TeslimB, @TasimaB, @KapB);

/* 3a) TESLİM ŞARTI / INCOTERMS  (kod harfli -> DEGER sıra; kod ANAHTAR ön ekinde) */
INSERT INTO GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) VALUES
  (@TeslimB, N'EXW - İşyerinde Teslim',                       1, -1, 1),
  (@TeslimB, N'FCA - Taşıyıcıya Masrafsız',                   2, -1, 2),
  (@TeslimB, N'FAS - Gemi Doğrultusunda Masrafsız',           3, -1, 3),
  (@TeslimB, N'FOB - Gemide Masrafsız',                       4, -1, 4),
  (@TeslimB, N'CFR - Masraflar ve Navlun',                    5, -1, 5),
  (@TeslimB, N'CIF - Masraflar, Sigorta ve Navlun',           6, -1, 6),
  (@TeslimB, N'CPT - Taşıma Ödenmiş Olarak',                  7, -1, 7),
  (@TeslimB, N'CIP - Taşıma ve Sigorta Ödenmiş Olarak',       8, -1, 8),
  (@TeslimB, N'DAF - Sınırda Teslim',                         9, -1, 9),
  (@TeslimB, N'DAP - Belirlenen Yerde Teslim',               10, -1, 10),
  (@TeslimB, N'DAT - Terminalde Teslim',                     11, -1, 11),
  (@TeslimB, N'DES - Gemide Teslim',                         12, -1, 12),
  (@TeslimB, N'DEQ - Rıhtımda Teslim',                       13, -1, 13),
  (@TeslimB, N'DDU - Gümrük Resmi Ödenmemiş Teslim',         14, -1, 14),
  (@TeslimB, N'DDP - Gümrük Vergileri Ödenmiş Olarak',       15, -1, 15);

/* 3b) TAŞIMA GÖNDERİM ŞEKLİ  (kod sayısal -> DEGER = kod) */
INSERT INTO GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) VALUES
  (@TasimaB, N'1 - Denizyolu',              1, -1, 1),
  (@TasimaB, N'2 - Demiryolu',              2, -1, 2),
  (@TasimaB, N'3 - Karayolu',               3, -1, 3),
  (@TasimaB, N'4 - Havayolu',               4, -1, 4),
  (@TasimaB, N'5 - Posta',                  5, -1, 5),
  (@TasimaB, N'6 - Çok araçlı',             6, -1, 6),
  (@TasimaB, N'7 - Sabit taşıma tesisleri', 7, -1, 7),
  (@TasimaB, N'8 - İç su taşımacılığı',     8, -1, 8);

/* 3c) PAKET / KAP CİNSİ  (kod harfli -> DEGER sıra; kod ANAHTAR ön ekinde) */
INSERT INTO GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) VALUES
  (@KapB, N'BA - Varil',         1, -1, 1),
  (@KapB, N'BE - Bohça',         2, -1, 2),
  (@KapB, N'BG - Torba',         3, -1, 3),
  (@KapB, N'BH - Demet',         4, -1, 4),
  (@KapB, N'BI - Çöp kutusu',    5, -1, 5),
  (@KapB, N'BJ - Kova',          6, -1, 6),
  (@KapB, N'BK - Sepet',         7, -1, 7),
  (@KapB, N'BX - Kutu',          8, -1, 8),
  (@KapB, N'CB - Bira kasası',   9, -1, 9),
  (@KapB, N'CH - Sandık',       10, -1, 10),
  (@KapB, N'CI - Teneke kutu',  11, -1, 11),
  (@KapB, N'CK - Fıçı',         12, -1, 12),
  (@KapB, N'CN - Konteyner',    13, -1, 13),
  (@KapB, N'CR - Kasa',         14, -1, 14),
  (@KapB, N'DK - Karton kasa',  15, -1, 15),
  (@KapB, N'DR - Bidon',        16, -1, 16),
  (@KapB, N'EC - Plastik torba',17, -1, 17),
  (@KapB, N'FC - Meyve kasası', 18, -1, 18),
  (@KapB, N'JR - Kavanoz',      19, -1, 19),
  (@KapB, N'LV - Liftvan',      20, -1, 20),
  (@KapB, N'NE - Ambalajsız',   21, -1, 21),
  (@KapB, N'SA - Çuval',        22, -1, 22),
  (@KapB, N'SU - Bavul',        23, -1, 23),
  (@KapB, N'TN - Teneke',       24, -1, 24),
  (@KapB, N'VG - Dökme gaz',    25, -1, 25),
  (@KapB, N'VL - Dökme sıvı',   26, -1, 26),
  (@KapB, N'VO - Dökme katı',   27, -1, 27);

/* ---- 4) REHBERAYAR: 'İhracat' detay şablonu (YERI=132) yeniden kur ---- */
/* Eski partial şablon adlarını da temizle (İhracat) ; SIRA'lar korunur ki
   varsa REHBERBILGI değerleri (YERI,SIRA) hizada kalsın. */
DELETE FROM REHBERAYAR WHERE YERI=132 AND BOLUM=N'İhracat';
INSERT INTO REHBERAYAR(YERI,SIRA,ETIKET,GIRIS,KAYNAK,VARSAYILAN,ZORUNLU,BOLUM,SUBEID) VALUES
  (132,  5, N'Teslim Şartı - INCOTERMS', 4,  N'İhracat_Teslim_Şartı', NULL, 1, N'İhracat', -1),
  (132, 10, N'Taşıma Şekli',             4,  N'İhracat_Taşıma_Şekli', NULL, 1, N'İhracat', -1),
  (132, 15, N'Kap / Ambalaj Cinsi',      4,  N'İhracat_Paket_Kap',    NULL, 1, N'İhracat', -1),
  (132, 20, N'FOB Değeri',              13,  NULL,                    NULL, 1, N'İhracat', -1),
  (132, 25, N'Kap Adedi',               13,  NULL,                    NULL, 0, N'İhracat', -1);

/* ---- 5) GENINI EFatura_Senaryo listesi (grid "Senaryo" kolonu + wizard combosu) ---- */
/* RepSenaryo runtime'da GENINI.ReadImageSection(EFatura_Senaryo=-11009) ile buradan
   dolar; deger yoksa combo bos kalir. Idempotent: eksik olani ekler, mevcuda dokunmaz.
   Not: RepSenaryo sabitinde 4 vardi (Temel/Ticari/İhracat/Kamu); veride 8=İlaç da
   oldugu icin o da eklendi (yoksa o satirlar bos gorunur). */
IF NOT EXISTS (SELECT 1 FROM GENINI WHERE BOLUM=0 AND ANAHTAR=N'EFatura_Senaryo')
  INSERT INTO GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) VALUES (0, N'EFatura_Senaryo', -11009, -1, 1);

;WITH S(ANAHTAR, DEGER, SIRA) AS (
  SELECT N'Temel',                1, 1 UNION ALL
  SELECT N'Ticari',               2, 2 UNION ALL
  SELECT N'İhracat',              3, 3 UNION ALL
  SELECT N'Kamu',                 7, 4 UNION ALL
  SELECT N'İlaç ve Tıbbi Cihaz',  8, 5
)
INSERT INTO GENINI(BOLUM, ANAHTAR, DEGER, DIL, SIRA)
SELECT -11009, S.ANAHTAR, S.DEGER, -1, S.SIRA
FROM S
WHERE NOT EXISTS (SELECT 1 FROM GENINI G WHERE G.BOLUM=-11009 AND G.DEGER=S.DEGER);

COMMIT;

/* ---- Doğrulama ---- */
SELECT N'Registry' AS Tur, ANAHTAR, DEGER FROM GENINI WHERE BOLUM=0
  AND ANAHTAR IN (N'İhracat_Teslim_Şartı',N'İhracat_Taşıma_Şekli',N'İhracat_Paket_Kap');
SELECT N'Teslim' AS Liste, COUNT(*) Adet FROM GENINI WHERE BOLUM=@TeslimB
UNION ALL SELECT N'Taşıma', COUNT(*) FROM GENINI WHERE BOLUM=@TasimaB
UNION ALL SELECT N'Kap',    COUNT(*) FROM GENINI WHERE BOLUM=@KapB;
SELECT SIRA, ETIKET, GIRIS, KAYNAK FROM REHBERAYAR WHERE YERI=132 AND BOLUM=N'İhracat' ORDER BY SIRA;

-- ============================================================
-- Update_PG_170.sql   #pg   (PostgreSQL)
-- E-BELGE SERI KURALLARI: kaymis KULLANICIID alanini onar (PostgreSQL)
--
-- Update_SQL_170.sql'in PG karsiligi; ayni gerekce ve ayni guvenlik kurallari.
--   ANAHTAR = 'SERI,SENARYO,KULLANICIID[,AKTIF]'  (alanlar SOLDAN)
--   BOLUM   = -24130 e-Fatura | -24131 e-Arsiv | -24133 e-Irsaliye,  DIL = -1
--   PG tarafinda okuma split_part indislerini virgul sayisindan hesapliyordu;
--   4 alanli kayitlarda KULLANICIID yerine AKTIF okunuyor, opsiyon ekranindan
--   kaydedilince bozuk deger kaliciyor ve hicbir seri kullaniciya uymuyordu.
--
-- MUSTERIDE CALISTIRMA NOTLARI
--   * Idempotent: tekrar calistirilabilir, ikinci calismada is yapmaz.
--   * Once YEDEK alinir (GENINI_SERI_YEDEK, her calisma damgali - ustune yazmaz).
--   * SADECE ISPATLANABILIR SEKILDE BOZUK satirlar onarilir:
--       4 alanli + son alan 0/1 + 3. alan > 0 + o ID'de TANIMLI KULLANICI YOK.
--     Gercek bir kullaniciya bagli kurallara DOKUNULMAZ.
--   * v_sadece_rapor = true yapilirsa hicbir yazma islemi yapilmaz.
--   * KULLANICI tablosu yoksa otomatik onarim atlanir.
--   * #pg etiketi bu baslikta bulunmalidir; aksi halde komut MSSQL'e karsi
--     calistirilmaya calisilir (bkz. UVersiyonGuncelle.pas).
-- ============================================================

DO $$
DECLARE
    v_sadece_rapor  boolean := false;      -- true = kuru calisma
    v_calisma       timestamp := now();
    v_kullanici_var boolean;
    v_sayi          integer;
    r               record;
BEGIN
    IF to_regclass('public.GENINI') IS NULL THEN
        RAISE NOTICE 'Update_PG_170: GENINI tablosu yok, atlandi.';
        RETURN;
    END IF;

    v_kullanici_var := to_regclass('public.KULLANICI') IS NOT NULL;

    -- 1) Ilgili kayitlari alanlarina ayir (alanlar SOLDAN)
    CREATE TEMP TABLE tmp_kural ON COMMIT DROP AS
    SELECT BOLUM, DEGER, DIL, SIRA, ANAHTAR,
           char_length(ANAHTAR) - char_length(replace(ANAHTAR, ',', '')) + 1 AS adet,
           split_part(ANAHTAR, ',', 1) AS seri,
           split_part(ANAHTAR, ',', 2) AS senaryo,
           split_part(ANAHTAR, ',', 3) AS kullaniciid,
           split_part(ANAHTAR, ',', 4) AS aktif
    FROM GENINI
    WHERE BOLUM IN (-24130, -24131, -24133)
      AND DIL = -1
      AND ANAHTAR IS NOT NULL;

    -- 2) Onarilacak satirlar (ispatlanabilir sekilde bozuk)
    CREATE TEMP TABLE tmp_bozuk ON COMMIT DROP AS
    SELECT k.*
    FROM tmp_kural k
    WHERE k.adet >= 4
      AND k.aktif IN ('0', '1')
      AND k.kullaniciid ~ '^[0-9]+$'
      AND k.kullaniciid::int > 0
      AND v_kullanici_var
      AND NOT EXISTS (SELECT 1 FROM KULLANICI u
                      WHERE u.REHBERID = k.kullaniciid::int);

    -- 3) Rapor
    FOR r IN SELECT * FROM tmp_bozuk ORDER BY BOLUM, SIRA LOOP
        RAISE NOTICE 'ONARILACAK  bolum=% sira=% anahtar=%', r.BOLUM, r.SIRA, r.ANAHTAR;
    END LOOP;

    FOR r IN
        SELECT k.* FROM tmp_kural k
        WHERE k.adet >= 4
          AND k.kullaniciid ~ '^[0-9]+$'
          AND k.kullaniciid::int > 0
          AND NOT EXISTS (SELECT 1 FROM tmp_bozuk b
                          WHERE b.BOLUM = k.BOLUM AND b.ANAHTAR = k.ANAHTAR AND b.DEGER = k.DEGER)
        ORDER BY k.BOLUM, k.SIRA
    LOOP
        RAISE NOTICE 'GOZDEN GECIR (dokunulmadi)  bolum=% sira=% anahtar=%', r.BOLUM, r.SIRA, r.ANAHTAR;
    END LOOP;

    SELECT count(*) INTO v_sayi FROM tmp_bozuk;
    IF v_sayi = 0 THEN
        RAISE NOTICE 'Update_PG_170: onarilacak kayit yok.';
        RETURN;
    END IF;

    IF v_sadece_rapor THEN
        RAISE NOTICE 'Update_PG_170: v_sadece_rapor = true, yazma yapilmadi.';
        RETURN;
    END IF;

    -- 4) Yedek + onarim  (DO blogu tek transaction icinde calisir)
    CREATE TABLE IF NOT EXISTS GENINI_SERI_YEDEK (
        YEDEKTARIH timestamp,
        KAYNAK     varchar(40),
        BOLUM      integer,
        DEGER      integer,
        DIL        integer,
        SIRA       integer,
        ANAHTAR    varchar(255)
    );

    INSERT INTO GENINI_SERI_YEDEK (YEDEKTARIH, KAYNAK, BOLUM, DEGER, DIL, SIRA, ANAHTAR)
    SELECT v_calisma, 'Update_PG_170', BOLUM, DEGER, DIL, SIRA, ANAHTAR
    FROM tmp_bozuk;

    UPDATE GENINI g
    SET ANAHTAR = b.seri || ',' || b.senaryo || ',0,' || b.aktif
    FROM tmp_bozuk b
    WHERE b.BOLUM = g.BOLUM
      AND b.DEGER = g.DEGER
      AND b.DIL   = g.DIL
      AND b.ANAHTAR = g.ANAHTAR;

    RAISE NOTICE 'Update_PG_170: % kayit onarildi. Yedek -> GENINI_SERI_YEDEK', v_sayi;
END $$;

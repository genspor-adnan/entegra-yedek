-- ============================================================
-- Update_PG_174.sql   #pg   (PostgreSQL)
-- STOK IZLEME: excel aktariminin urettigi MUKERRER "Yok" sozluk kayitlarini temizle
--
-- Update_SQL_174.sql'in PG karsiligi; ayni gerekce ve ayni guvenlik kurallari:
--   UExceldenVeriAl.IniEkle "deger 0" ile "kayit yok"u ayni saydigi icin, DEGERI 0 olan
--   'Yok' anahtari (genini bolum -2706) her aktarimda yeniden ekleniyor ve stok kartina
--   sahte kod (max+1) yaziliyordu. Uygulama duzeltildi; bu betik gecmis veriyi onarir.
--   Yalniz ayni anahtarin deger=0 kaydi VARSA mukerrer kabul edilir; yedek alinir.
-- Idempotent.
-- ============================================================

CREATE TABLE IF NOT EXISTS yedek_stok_izleme_174
(
    stokid      integer PRIMARY KEY,
    eski_izleme integer,
    yeni_izleme integer,
    tarih       timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS yedek_genini_174
(
    bolum   integer NOT NULL,
    anahtar varchar(250),
    deger   integer NOT NULL,
    dil     integer,
    tarih   timestamp NOT NULL DEFAULT now()
);

DO $$
DECLARE
    v_stok int := 0;
    v_soz  int := 0;
BEGIN
    IF to_regclass('public.genini') IS NULL OR to_regclass('public.stoklar') IS NULL THEN
        RAISE NOTICE 'Update_PG_174: genini/stoklar yok, atlandi.';
        RETURN;
    END IF;

    CREATE TEMP TABLE sahte ON COMMIT DROP AS
        SELECT g.deger AS sahte, g.anahtar
          FROM genini g
         WHERE g.bolum = -2706 AND g.dil = -1 AND g.deger <> 0
           AND EXISTS (SELECT 1 FROM genini g0
                        WHERE g0.bolum = -2706 AND g0.dil = -1 AND g0.deger = 0
                          AND g0.anahtar = g.anahtar);

    IF NOT EXISTS (SELECT 1 FROM sahte) THEN
        RAISE NOTICE 'Update_PG_174: mukerrer Izleme kaydi yok, onarim gerekmedi.';
        RETURN;
    END IF;

    INSERT INTO yedek_stok_izleme_174 (stokid, eski_izleme, yeni_izleme)
    SELECT s.id, s.izleme, 0
      FROM stoklar s
      JOIN sahte x ON x.sahte = s.izleme
     WHERE NOT EXISTS (SELECT 1 FROM yedek_stok_izleme_174 y WHERE y.stokid = s.id);

    UPDATE stoklar s SET izleme = 0
      FROM sahte x
     WHERE x.sahte = s.izleme;
    GET DIAGNOSTICS v_stok = ROW_COUNT;

    INSERT INTO yedek_genini_174 (bolum, anahtar, deger, dil)
    SELECT g.bolum, g.anahtar, g.deger, g.dil
      FROM genini g
      JOIN sahte x ON x.sahte = g.deger AND x.anahtar = g.anahtar
     WHERE g.bolum = -2706 AND g.dil = -1;

    DELETE FROM genini g
     USING sahte x
     WHERE x.sahte = g.deger AND x.anahtar = g.anahtar
       AND g.bolum = -2706 AND g.dil = -1;
    GET DIAGNOSTICS v_soz = ROW_COUNT;

    RAISE NOTICE 'Update_PG_174: duzeltilen stok = %, silinen sozluk satiri = %', v_stok, v_soz;
END $$;

-- Sonuc: Izleme sozlugu
SELECT anahtar, deger FROM genini WHERE bolum = -2706 AND dil = -1 ORDER BY deger;

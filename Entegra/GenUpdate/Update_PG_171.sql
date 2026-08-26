-- ============================================================
-- Update_PG_171.sql   #pg   (PostgreSQL)
-- ALIS IRSALIYESI (TUR=10): KOCANNO=0 kalmis belgeleri kendi kocanina bagla
--
-- Update_SQL_171.sql'in PG karsiligi; ayni gerekce ve ayni guvenlik kurallari:
--   - yalnizca TUR=10, KOCANNO 0/NULL ve FATURANO SAYISAL satirlar
--   - yalnizca ilgili subede TEK kocan tanimliysa
--   - yalnizca kocanin BASLANGICTARIHI'nden sonraki belgeler
--   - eski degerler yedek tabloya yazilir, betik idempotenttir
-- MSSQL ISNUMERIC() yerine PG'de regex kullanilir (sadece rakam).
-- ============================================================

-- 1) Yedek tablo
CREATE TABLE IF NOT EXISTS yedek_fatbaslik_kocanno_171
(
    id            integer PRIMARY KEY,
    tur           integer,
    subeid        integer,
    faturano      varchar(50),
    eski_kocanno  integer,
    yeni_kocanno  integer,
    tarih         timestamp NOT NULL DEFAULT now()
);

-- 2) Onarilacak satirlarin yedegi
WITH tekkocan AS (
    SELECT subeid, tur,
           min(kocanno)         AS kocanno,
           min(baslangictarihi) AS baslangictarihi
      FROM kocanayarlari
     WHERE tur = 10
     GROUP BY subeid, tur
    HAVING count(*) = 1
),
hedef AS (
    SELECT fb.id, fb.tur, fb.subeid, fb.faturano,
           coalesce(fb.kocanno, 0) AS eski_kocanno,
           tk.kocanno              AS yeni_kocanno
      FROM fatbaslik fb
      JOIN tekkocan  tk ON tk.subeid = fb.subeid AND tk.tur = fb.tur
     WHERE fb.tur = 10
       AND coalesce(fb.kocanno, 0) = 0
       AND fb.faturano ~ '^[0-9]+$'
       AND fb.faturatarih >= coalesce(tk.baslangictarihi, timestamp '1900-01-01')
)
INSERT INTO yedek_fatbaslik_kocanno_171 (id, tur, subeid, faturano, eski_kocanno, yeni_kocanno)
SELECT h.id, h.tur, h.subeid, h.faturano, h.eski_kocanno, h.yeni_kocanno
  FROM hedef h
 WHERE NOT EXISTS (SELECT 1 FROM yedek_fatbaslik_kocanno_171 y WHERE y.id = h.id);

-- 3) Guncelleme
UPDATE fatbaslik fb
   SET kocanno = y.yeni_kocanno
  FROM yedek_fatbaslik_kocanno_171 y
 WHERE y.id = fb.id
   AND coalesce(fb.kocanno, 0) = 0;

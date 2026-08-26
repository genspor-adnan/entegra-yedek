-- Seri kurallari onarimi
-- ANAHTAR = SERI,SENARYO,KULLANICIID,AKTIF
-- Eski hatali okuma (MSSQL parsename SAGDAN sayiyordu) AKTIF bayragini KULLANICIID
-- alanina kaydirmisti. Bu script YALNIZCA 3. alani (KULLANICIID) 0 = "tum kullanicilar"
-- yapar; SERI, SENARYO ve AKTIF oldugu gibi korunur.

-- 1) ONCE
select 'ONCE' as DURUM, BOLUM, DEGER, SIRA, ANAHTAR
from GENINI
where BOLUM in (-24130, -24131, -24133) and DIL = -1
order by BOLUM, SIRA, ANAHTAR;

-- 2) ONARIM (yalnizca 4 alanli kayitlar)
update GENINI
set ANAHTAR =
      left(ANAHTAR, charindex(',', ANAHTAR) - 1) + ',' +
      left(substring(ANAHTAR, charindex(',', ANAHTAR) + 1, 200),
           charindex(',', substring(ANAHTAR, charindex(',', ANAHTAR) + 1, 200) + ',') - 1) +
      ',0,' + right(rtrim(ANAHTAR), 1)
where BOLUM in (-24130, -24131, -24133)
  and DIL = -1
  and len(ANAHTAR) - len(replace(ANAHTAR, ',', '')) >= 3
  and charindex(',', ANAHTAR) > 1;

-- 3) SONRA
select 'SONRA' as DURUM, BOLUM, DEGER, SIRA, ANAHTAR,
       SERI  = left(ANAHTAR, charindex(',', ANAHTAR) - 1),
       AKTIF = right(rtrim(ANAHTAR), 1)
from GENINI
where BOLUM in (-24130, -24131, -24133) and DIL = -1
order by BOLUM, SIRA, ANAHTAR;

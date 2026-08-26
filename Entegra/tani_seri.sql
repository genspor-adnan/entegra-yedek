-- Seri kurallari tanisi: GENINI'deki ham ANAHTAR ve nasil ayristirildigi
select
  BOLUM,
  DEGER,
  SIRA,
  ANAHTAR,
  PARCA        = len(ANAHTAR) - len(replace(ANAHTAR, ',', '')) + 1,
  SERI         = left(ANAHTAR, charindex(',', ANAHTAR + ',') - 1),
  SENARYO      = try_convert(int, parsename(replace(ANAHTAR, ',', '.'),
                   case when len(ANAHTAR) - len(replace(ANAHTAR, ',', '')) >= 3 then 3 else 2 end)),
  KULLANICIID  = try_convert(int, parsename(replace(ANAHTAR, ',', '.'),
                   case when len(ANAHTAR) - len(replace(ANAHTAR, ',', '')) >= 3 then 2 else 1 end)),
  AKTIF        = case when len(ANAHTAR) - len(replace(ANAHTAR, ',', '')) >= 3
                      then parsename(replace(ANAHTAR, ',', '.'), 1) else '1' end,
  PASIF_FILTRE = case when ANAHTAR like '%,%,%,0' then 'ELENIR' else 'gecer' end
from GENINI
where BOLUM in (-24130, -24131, -24133) and DIL = -1
order by BOLUM, SIRA, ANAHTAR;

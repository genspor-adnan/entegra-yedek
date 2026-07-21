CREATE OR REPLACE VIEW public.uv_tahsilat_genel AS
select
	r.firma										as sube,
	date_trunc('day', k.islemtarihi)			as tarih,
	case
		when k.hesapturu = 'B' then (select bh.hesapadi from bankahesaplar bh where bh.id = k.hesapid)
		when k.hesapturu = 'H' and coalesce(k.ceksenetid, 0) <> 0 then (select pk.adi from para_kupon pk where k.ceksenetid = pk.id)
		when k.hesapturu = 'H' and coalesce(k.ceksenetid, 0) =  0 then 'Hediye Çeki'
		when k.hesapturu = 'K' then 'Nakit'
		when k.hesapturu = 'P' then (select p.adi from pos p where p.id = k.hesapid)
		when k.hesapturu = 'V' then (select kk.adi from kredikarti kk where kk.id = k.hesapid)
	end											as hesapadi,
	k.hesapturu,
	k.hesapid,
	k.ceksenetid,
	abs(k.borc - k.alacak)						as tutar
from kasa k
	left join rehber r on k.subeid = r.id and r.id < 0
where
	k.tur in (21, 25);

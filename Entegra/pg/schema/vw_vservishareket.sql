CREATE OR REPLACE VIEW public.vservishareket AS
select
	sh.id, sh.servisid, s.tarih, s.servisno, s.turu,
	sh.baslasec, sh.baslama as baslamatarihi, sh.bitissec, sh.bitis as bitistarihi,
	s.rehberid, r1.kod, r1.firma, s.kabul_sekli, s.disservis, s.acil, s.onemli,
	s.mus_ilgili, (select firma from rehber r where r.id = s.mus_ilgili) as mus_ilgiliad,
	vsh.calisma_suresi,
	s.ekipmanid, (select ad from ekipmanlar e where e.id = s.ekipmanid) as ekipmanad,
	s.konusu,
	sh.durum, (select anahtar from genini g where g.bolum = -3007 and deger = sh.durum and dil = -1) as durumad,
	sh.aciklama,
	s.projeid, (select projekodu||' '||projeadi from projeler p where p.id = s.projeid) as projead,
	sh.personel, (select firma from rehber r where r.id = sh.personel) as personelad,
	s.ackapa, s.subeid, s.ekleyen as servisekleyen,
	sh.ekleyen as hareketekleyen, (select firma from rehber r where r.id = sh.ekleyen) as hareketekleyenad,
	sh.eklemetarihi
from servishareket sh
inner join servis s on sh.servisid = s.id
left outer join rehber r1 on r1.id = s.rehberid
left outer join v_servis_hareket_ozet vsh on vsh.servisid = s.id;

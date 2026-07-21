CREATE OR REPLACE VIEW public.vservislistesi AS
select distinct
	s.*, sh.baslama, sh.bitis, sh.toplam_sure, sh.calisma_suresi,
	sl.ad as sorun_tipi, sb.aciklama as sorun_aciklama, sb.cozum as sorun_sonucu,
	(select firma from rehber r7 where r7.id = s.ekleyen) as kabul_edenad,
	case when s.demirbas=1 then (select stokadi from demirbas_urun du inner join demirbas d on d.kategoriid=du.id where d.id=s.ekipmanid) else (select ad from kategori k where k.id=s.ekipmanid) end as kategoriad,
	case when s.demirbas=1 then (select demirbasadi from demirbas d where d.id=s.ekipmanid) else (select ad from ekipmanlar e where e.id=s.ekipmanid) end as ekipmanad,
	r1.firma,
	(select fn_serviskisiler(s.durum, s.id)) as sorumluad,
	rp.firma as mus_ilgiliad,
	(select aciklama from lokasyon l where l.id=s.lokasyonid) as lokasyon,
	(select r5.firma from rehber r5 where r5.grup=334 and r5.id = s.disonay) as onaylayanad,
	(select r5.firma from rehber r5 where r5.grup=334 and r5.id = s.teslim_alan) as teslim_alanad,
	(select anahtar from genini g where bolum=-3005 and g.deger=s.onaysekli) as onaysekliad,
	fb.faturatarih, fb.faturano, fb.fatura_tutari,
	ri.ad as servis_adresi
from servis s
left outer join v_servis_hareket_ozet sh on sh.servisid=s.id
left outer join rehber r1 on r1.id=s.rehberid
left outer join rehber rp on rp.id=s.mus_ilgili and rp.grup=334
left outer join fatbaslik fb on fb.servisid=s.id and fb.tur in (15,16)
left outer join (select *, row_number() over (partition by sb2.servisid order by sb2.id) as sirano from servisbilgi sb2 where sb2.servistur=210) sb on sb.sirano=1 and sb.servisid=s.id
left outer join servisliste sl on sl.id=sb.servislisteid
left outer join rehberiletisim ri on ri.rehberid=s.rehberid and ri.id=s.servisadresi;

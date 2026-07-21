CREATE OR REPLACE VIEW public.uv_ciro_genel AS
SELECT
	r.firma                                                                                       AS sube,
	fb.tarih                                                                                       AS tarih,
	fb.tur,
	firma.firma                                                                                    AS firma,
	k.ad                                                                                           AS kategori,
	fb.kdvdurum,
	f.urunid                                                                                       AS urunid,
	s.kod                                                                                          AS urunkodu,
	s.stokadi                                                                                      AS urunadi,
	CASE WHEN fb.kdvdurum = 'Dahil' THEN f.birimfiyat ELSE f.birimfiyat * (1 + (f.kdv / 100.0)) END AS birimfiyat,
	f.adet,
	CASE WHEN fb.kdvdurum = 'Dahil' THEN f.tutar ELSE f.tutar * (1 + (f.kdv / 100.0)) END          AS tutar,
	satici.firma                                                                                   AS satici
FROM fatbaslik fb
	LEFT JOIN rehber r ON fb.subeid = r.id AND r.id < 0
	LEFT JOIN rehber firma ON fb.rehberid = firma.id
	INNER JOIN fatura f ON fb.id = f.fatbasid
	LEFT JOIN rehber satici ON f.ekleyen = satici.id
	INNER JOIN stoklar s ON f.urunid = s.id
	LEFT JOIN kategori k ON s.kategori = k.id
WHERE fb.tur IN (17, 15, 16);

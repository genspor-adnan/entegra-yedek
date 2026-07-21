CREATE OR REPLACE VIEW public.uv_cari_borclu_listesi AS
SELECT
	r.id, r.kod, r.firma, r2.firma AS temsilciad, kur, (toplam_borc - toplam_alacak) AS bakiye
FROM (
	SELECT
		rehberid,
		SUM(COALESCE(borc,0)) AS toplam_borc,
		SUM(COALESCE(alacak,0)) AS toplam_alacak,
		SUM(COALESCE(takipte,0)) AS takipte,
		COALESCE(kur,'TL') AS kur
	FROM (
		SELECT
			rehberid,
			SUM(CASE WHEN ekstredekullan=1 THEN doviz_tutari ELSE f.fatura_tutari END) AS borc,
			0 AS alacak,
			CASE WHEN ekstredekullan=1 THEN doviz_cinsi ELSE kur END AS kur,
			0 AS takipte
		FROM fatbaslik f
		WHERE COALESCE(f.durum,0) <> 6 AND (f.tur IN (15,16,17))
			AND faturatarih >= date_trunc('year', now())
		GROUP BY f.rehberid, CASE WHEN ekstredekullan=1 THEN doviz_cinsi ELSE kur END
		UNION ALL
		SELECT
			rehberid,
			0 AS borc,
			SUM(CASE WHEN ekstredekullan=1 THEN doviz_tutari ELSE f.fatura_tutari END) AS alacak, -- alinan fatura BORCA YAZ
			CASE WHEN ekstredekullan=1 THEN doviz_cinsi ELSE kur END AS kur,
			0 AS takipte
		FROM fatbaslik f
		WHERE COALESCE(f.durum,0) <> 6 AND (f.tur IN (8,11,12,13))
			AND faturatarih >= date_trunc('year', now())
		GROUP BY f.rehberid, CASE WHEN ekstredekullan=1 THEN doviz_cinsi ELSE kur END
		UNION ALL
		SELECT
			rehberid,
			SUM(CASE WHEN COALESCE(k.borc,0)>0 AND ekstredekullan=1 THEN k.doviz_tutari ELSE k.borc END) AS borc,
			SUM(CASE WHEN COALESCE(k.alacak,0)>0 AND ekstredekullan=1 THEN k.doviz_tutari ELSE k.alacak END) AS alacak,
			CASE WHEN ekstredekullan=1 THEN doviz_kuru ELSE kur END AS kur,
			0 AS takipte
		FROM kasa k
		WHERE tur NOT BETWEEN 60 AND 79
			AND islemtarihi >= date_trunc('year', now())
		GROUP BY k.rehberid, CASE WHEN ekstredekullan=1 THEN doviz_kuru ELSE kur END
		UNION ALL
		SELECT
			ch.rehberid,
			SUM(CASE WHEN ch.islem IN (140,131,132,133,134,137) THEN (CASE WHEN ch.ekstredekullan=1 THEN ch.tutar ELSE COALESCE(c.tutar,0) END) ELSE 0 END) AS borc,
			SUM(CASE WHEN ch.islem IN (130,141) THEN (CASE WHEN ch.ekstredekullan=1 THEN ch.tutar ELSE COALESCE(c.tutar,0) END) ELSE 0 END) AS alacak,
			CASE WHEN ch.ekstredekullan=1 THEN ch.kur ELSE COALESCE(c.kur,'TL') END AS kur,
			0 AS takipte
		FROM cekler c INNER JOIN cekhareket ch ON c.id=ch.ceksenetlerid
		WHERE ch.islem IN (130,131,132,134,137,140,141)
			AND ch.tarih >= date_trunc('year', now())
		GROUP BY ch.rehberid, ch.islem, ch.ekstredekullan, CASE WHEN ch.ekstredekullan=1 THEN ch.kur ELSE COALESCE(c.kur,'TL') END
		UNION ALL
		SELECT
			c.rehberid,
			0 AS borc,
			0 AS alacak,
			CASE WHEN c.ekstredekullan=1 THEN c.doviz_kuru ELSE COALESCE(c.kur,'TL') END AS kur,
			SUM(CASE WHEN c.tur IN (131,132,133,134,137) THEN (CASE WHEN c.ekstredekullan=1 THEN c.doviz_tutari ELSE COALESCE(c.tutar,0) END) ELSE 0 END)
				- SUM(CASE WHEN c.tur IN (130) THEN (CASE WHEN c.ekstredekullan=1 THEN c.doviz_tutari ELSE COALESCE(c.tutar,0) END) ELSE 0 END) AS takipte
		FROM cekler c
		WHERE c.ceksenet IN (101,121)
			AND c.tur IN (130,131,132,133,134,135,138)
			AND EXISTS (SELECT * FROM cekhareket ch WHERE ch.ceksenetlerid = c.id)
		GROUP BY c.rehberid, c.ekstredekullan, c.doviz_kuru, COALESCE(c.kur,'TL')
		UNION ALL
		SELECT
			rehberid,
			0 AS borc,
			SUM(CASE WHEN ekstredekullan=1 THEN s.doviz_tutari ELSE tutar END) AS alacak,
			CASE WHEN ekstredekullan=1 THEN s.doviz_kuru ELSE kur END AS kur,
			0 AS takipte
		FROM senetler s
		WHERE tur = 24
			AND tarih >= date_trunc('year', now())
		GROUP BY s.rehberid, CASE WHEN ekstredekullan=1 THEN s.doviz_kuru ELSE kur END
		UNION ALL
		SELECT
			rehberid,
			SUM(CASE WHEN ekstredekullan=1 THEN s.doviz_tutari ELSE tutar END) AS borc,
			0 AS alacak,
			CASE WHEN ekstredekullan=1 THEN s.doviz_kuru ELSE kur END AS kur,
			0 AS takipte
		FROM senetler s
		WHERE tur = 34
			AND tarih >= date_trunc('year', now())
		GROUP BY s.rehberid, CASE WHEN ekstredekullan=1 THEN s.doviz_kuru ELSE kur END
	) AS asd
	GROUP BY rehberid, kur
) AS dsa
	INNER JOIN rehber r ON dsa.rehberid = r.id
	LEFT JOIN rehber r2 ON r2.id = r.temsilci
WHERE r.grup <> 334
	AND r.grup <> 335
	AND r.id > 1
	AND r.grup <> 334
	AND r.grup <> 335
	AND r.grup > 1
	AND r.durum > 0
	AND COALESCE(r.id, 0) <> 0
	AND (COALESCE(toplam_borc, 0.0) - COALESCE(toplam_alacak, 0.0)) > 1.0;

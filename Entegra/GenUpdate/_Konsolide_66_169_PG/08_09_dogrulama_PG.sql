\set ON_ERROR_STOP on
-- ---- veri ----
INSERT INTO cari (kod, ad, bakiye, acilis, degistirme, rehberid, aktif)
VALUES ('CR001','GRANIT BILGISAYAR LTD.', 172320.5, '2026-01-15', '2026-08-16 10:20:30', 1301, true),
       ('CR002','KIMPA KIMYA SAN.',       -134900,  '2026-02-01', '2026-08-16 11:00:00', 1512, false);
INSERT INTO stoklar (id, kategori, kod, ad) VALUES (5,7,'ELD-01','Eldiven'), (6,3,'MSK-01','Maske');
INSERT INTO uretimemri (id, stokid) VALUES (100,5), (101,6);

\echo '--- 1) fn_api_depodbadi'
SELECT public.fn_api_depodbadi() AS sema;

\echo '--- 2) fn_api_log_yiltablosu (var olan yil)'
SELECT public.fn_api_log_yiltablosu(2026) AS tablo;
\echo '--- 2b) olmayan yil -> tablo olusturulmali'
SELECT public.fn_api_log_yiltablosu(2027) AS tablo;
SELECT to_regclass('depo.log2027') IS NOT NULL AS log2027_olustu;

\echo '--- 3) trigger: KATEGORI=7 -> SKT = URT + 5 yil'
INSERT INTO uretimemri_user (id, urt) VALUES (100, '2026-03-10');
INSERT INTO uretimemri_user (id, urt) VALUES (101, '2026-03-10');
SELECT id, urt::date AS urt, skt::date AS skt FROM uretimemri_user ORDER BY id;

\echo '--- 4) fn_api_log_kayitsil_json (tek kayit)'
SELECT * FROM public.fn_api_log_kayitsil_json(
  '{"Tablo":"cari","TabNo":71,"KayitId":1,"Oturum":{"KulId":9,"SubeId":1,"Ip":"10.0.0.5","Istasyon":"PC-01"}}');

\echo '--- 4b) yazilan log satiri'
SELECT tabloid, kayitid, rehberid, islemtipi, kullaniciid, ip, istasyon FROM depo.log2026;
\echo '--- 4c) BILGI json (blob haric, NULL/bos atilmis, tarih 120 stili, ondalik 6 hane)'
SELECT jsonb_pretty(bilgi) FROM depo.log2026;

\echo '--- 5) fn_api_log_detaysil_json (kosul ile coklu satir)'
SELECT * FROM public.fn_api_log_detaysil_json(
  '{"Tablo":"cari","TabNo":71,"Kosul":"t.bakiye < 0","Oturum":{"KulId":9,"SubeId":1}}');

\echo '--- 6) fn_api_log_kaynak_isaretle (kopya=3)'
UPDATE depo.log2026 SET islemtipi = 1 WHERE kayitid = 1;
SELECT public.fn_api_log_kaynak_isaretle(71, 1::bigint, 3::smallint, 999::bigint, NULL);
SELECT altislemtipi, bilgi->>'_KopyaKaynak' AS kopyakaynak, bilgi->>'_KaynakTablo' AS kaynaktablo
FROM depo.log2026 WHERE kayitid = 1;

\echo '--- 7) hata yolu: zorunlu alan eksik'
DO $$ BEGIN
  PERFORM * FROM public.fn_api_log_kayitsil_json('{"TabNo":71}');
  RAISE NOTICE 'HATA BEKLENIYORDU';
EXCEPTION WHEN SQLSTATE 'GN001' THEN RAISE NOTICE 'beklenen hata alindi: %', SQLERRM;
END $$;

\echo '--- 8) olmayan tablo'
DO $$ BEGIN
  PERFORM public.fn_api_log_yaz_ic(p_tablo => 'yok_boyle_tablo', p_tabno => 1, p_kayitid => 1);
  RAISE NOTICE 'HATA BEKLENIYORDU';
EXCEPTION WHEN SQLSTATE 'GN002' THEN RAISE NOTICE 'beklenen hata alindi: %', SQLERRM;
END $$;

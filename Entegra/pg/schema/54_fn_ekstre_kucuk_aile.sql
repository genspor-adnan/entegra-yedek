-- ============================================================================
-- Kucuk TVF portlari: fn_prim_detay_liste, fn_butcepivot_aylik, fn_masrafgelir_ekstre_odeme
-- NOT: birebir; differential veriyle dogrulanmali.
-- ============================================================================

-- ---------------------------------------------------------------- fn_prim_detay_liste
DROP FUNCTION IF EXISTS fn_prim_detay_liste(integer, timestamp, timestamp);
CREATE OR REPLACE FUNCTION fn_prim_detay_liste(p_rehid integer, p_bastar timestamp, p_bittar timestamp)
RETURNS TABLE("ID" integer,"TARIH" timestamp,"BELGENO" varchar(25),"KOD" varchar(25),"AD" varchar(150),"MATRAH" double precision,"PIRIM" double precision)
LANGUAGE sql AS $$
  SELECT P.ID::int, S.SIPARISTARIH::timestamp, S.SIPARISNO::varchar(25), MG.KOD::varchar(25), MG.AD::varchar(150),
         P.MATRAH::double precision, P.PIRIM::double precision
  FROM PERS_PIRIM_LISTE P
    INNER JOIN SIPARISDETAY SD ON P.YER_ID=SD.ID
    INNER JOIN SIPARIS S ON S.ID=SD.SIPARISID
    INNER JOIN MASRAFGELIR MG ON SD.URUNID=MG.ID AND SD.TUR=0
  WHERE P.REHBERID=p_rehid AND P.TARIH BETWEEN p_bastar AND p_bittar
  ORDER BY P.TARIH;
$$;

-- ---------------------------------------------------------------- fn_butcepivot_aylik
DROP FUNCTION IF EXISTS fn_butcepivot_aylik(integer, integer);
CREATE OR REPLACE FUNCTION fn_butcepivot_aylik(p_bittar integer, p_gelirmi integer)
RETURNS TABLE("GRUP" varchar(50),"TUR" varchar(50),"YIL" double precision,"TARIH" double precision,"TARIHYAZI" varchar(20),"PLANLANAN" numeric,"GERCEKLESEN" numeric)
LANGUAGE sql AS $$
  SELECT GRUP, TUR, YIL, TARIH,
    (CASE TARIH::int WHEN 1 THEN '01/Ocak' WHEN 2 THEN '02/Şubat' WHEN 3 THEN '03/Mart' WHEN 4 THEN '04/Nisan'
                     WHEN 5 THEN '05/Mayıs' WHEN 6 THEN '06/Haziran' WHEN 7 THEN '07/Temmuz' WHEN 8 THEN '08/Ağustos'
                     WHEN 9 THEN '09/Eylül' WHEN 10 THEN '10/Ekim' WHEN 11 THEN '11/Kasım' WHEN 12 THEN '12/Aralık' END)::varchar(20) AS TARIHYAZI,
    SUM(PLANLANAN)::numeric AS PLANLANAN, SUM(GERCEKLESEN)::numeric AS GERCEKLESEN
  FROM (
    SELECT (CASE WHEN p_gelirmi=0 THEN 'Gider' ELSE 'Gelir' END)::varchar(50) AS GRUP,
           (coalesce(M.KOD,'')||' '||coalesce(rtrim(M.AD),''))::varchar(50) AS TUR,
           B.YIL::double precision AS YIL, B.AY::double precision AS TARIH, B.PLANLANAN AS PLANLANAN, B.GERCEKLESEN AS GERCEKLESEN
    FROM BUTCE B INNER JOIN MASRAFGELIR M ON M.ID=B.MASRAFID
    WHERE B.GOR=1 AND B.YIL=extract(year from now()) AND M.GELIRMI=p_gelirmi
  ) X
  WHERE YIL=p_bittar
  GROUP BY GRUP, TUR, YIL, TARIH;
$$;

-- ---------------------------------------------------------------- fn_masrafgelir_ekstre_odeme
-- Hesap-ekstre deseni: cursor->window (TUR 60-79 haric), yerel* kolonlari YOK. Tek KASA kaynagi (MASRAFID).
DROP FUNCTION IF EXISTS fn_masrafgelir_ekstre_odeme(integer, timestamp, timestamp);
CREATE OR REPLACE FUNCTION fn_masrafgelir_ekstre_odeme(p_masrafid integer, p_bastar timestamp, p_bittar timestamp)
RETURNS TABLE("SIRANO" integer,"CEKID" integer,"TARIH" timestamp,"AKSIYONTARIH" timestamp,"NO" varchar(20),
  "TUR" smallint,"BASLIK" varchar(150),"TURAD" varchar(50),"REHBERID" integer,"KOD" varchar(20),"AD" varchar(100),
  "ACIKLAMA" varchar(500),"HESAPID" integer,"HESAPKODU" varchar(100),"HESAPADI" varchar(150),"DURUM" smallint,
  "BORC" numeric,"ALACAK" numeric,"KUR" varchar(6),"MASRAFID" integer,"MASRAFKOD" varchar(50),"MASRAFAD" varchar(100),
  "BORCBAKIYE" numeric,"ALACAKBAKIYE" numeric,"SUBEID" integer,"VADETARIHI" timestamp)
LANGUAGE sql AS $$
WITH mov AS (
  SELECT K.ID AS CEKID, K.ISLEMTARIHI AS TARIH, K.PLANTARIHI AS AKSIYONTARIH, K.BELGENO::varchar(20) AS no, K.TUR::smallint AS TUR,
    ''::varchar(150) AS BASLIK,
    (CASE WHEN K.TUR::text LIKE '26__' THEN (SELECT ANAHTAR||' tahsilatı ' FROM GENINI WHERE BOLUM=-2329 AND 2600+DEGER=K.TUR LIMIT 1)
          WHEN K.TUR::text LIKE '36__' THEN (SELECT ANAHTAR||' ödemesi ' FROM GENINI WHERE BOLUM=-2329 AND 3600+DEGER=K.TUR LIMIT 1)
          ELSE (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-1005 AND DEGER=K.TUR LIMIT 1) END)::varchar(50) AS TURAD,
    K.REHBERID,
    (CASE WHEN K.REHBERID=0 THEN M.KOD ELSE R.KOD END)::varchar(20) AS KOD,
    (CASE WHEN K.REHBERID=0 THEN M.AD ELSE R.FIRMA END)::varchar(100) AS AD,
    K.ACIKLAMA::varchar(500) AS ACIKLAMA, K.HESAPID,
    (CASE K.HESAPTURU WHEN 'B' THEN (SELECT HESAPKODU FROM BANKAHESAPLAR BH WHERE BH.ID=K.HESAPID)
       WHEN 'H' THEN (SELECT KASAKODU FROM KASALAR K2 WHERE K2.ID=K.HESAPID)||coalesce(' ('||(SELECT ADI FROM PARA_KUPON PK WHERE PK.ID=K.CEKSENETID)||')','')
       WHEN 'K' THEN (SELECT KASAKODU FROM KASALAR K2 WHERE K2.ID=K.HESAPID)
       WHEN 'P' THEN (SELECT KODU FROM POS P WHERE P.ID=K.HESAPID)
       WHEN 'V' THEN (SELECT KODU FROM KREDIKARTI KK WHERE KK.ID=K.HESAPID) END)::varchar(100) AS HESAPKODU,
    (CASE K.HESAPTURU WHEN 'B' THEN (SELECT HESAPADI FROM BANKAHESAPLAR BH WHERE BH.ID=K.HESAPID)
       WHEN 'H' THEN (SELECT KASAADI FROM KASALAR K2 WHERE K2.ID=K.HESAPID)||coalesce(' ('||(SELECT ADI FROM PARA_KUPON PK WHERE PK.ID=K.CEKSENETID)||')','')
       WHEN 'K' THEN (SELECT KASAADI FROM KASALAR K2 WHERE K2.ID=K.HESAPID)
       WHEN 'P' THEN (SELECT ADI FROM POS P WHERE P.ID=K.HESAPID)
       WHEN 'V' THEN (SELECT ADI FROM KREDIKARTI KK WHERE KK.ID=K.HESAPID) END)::varchar(150) AS HESAPADI,
    K.DURUM::smallint AS DURUM,
    (CASE WHEN K.BORC>0 AND K.DOVIZ_TUTARI>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)::numeric AS BORC,
    (CASE WHEN K.ALACAK>0 AND K.DOVIZ_TUTARI>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END)::numeric AS ALACAK,
    (CASE WHEN K.DOVIZ_TUTARI>0 THEN K.DOVIZ_KURU ELSE K.KUR END)::varchar(6) AS KUR,
    K.MASRAFID, M.KOD::varchar(50) AS MASRAFKOD, M.AD::varchar(100) AS MASRAFAD, K.SUBEID, K.ISLEMTARIHI AS VADETARIHI
  FROM KASA K
    LEFT JOIN REHBER R ON K.REHBERID=R.ID
    LEFT JOIN KASALAR KS ON KS.ID=K.HESAPID
    LEFT JOIN MASRAFGELIR M ON M.ID=K.MASRAFID
  WHERE K.MASRAFID=p_masrafid
    AND extract(year from K.ISLEMTARIHI)>=extract(year from p_bastar) AND extract(year from K.ISLEMTARIHI)<=extract(year from p_bittar)
    AND K.TUR IN (1,21,22,25,31,32,35,44,51,52,53,54,58)
),
seq AS (SELECT *, row_number() OVER (ORDER BY KUR, TARIH) AS SIRANO FROM mov),
bal AS (SELECT *,
  greatest(SUM(CASE WHEN TUR BETWEEN 60 AND 79 THEN 0 ELSE BORC-ALACAK END) OVER (PARTITION BY KUR ORDER BY SIRANO),0) AS BORCBAKIYE,
  greatest(SUM(CASE WHEN TUR BETWEEN 60 AND 79 THEN 0 ELSE ALACAK-BORC END) OVER (PARTITION BY KUR ORDER BY SIRANO),0) AS ALACAKBAKIYE
  FROM seq)
SELECT row_number() OVER (ORDER BY q.KUR, q.TARIH, q.devirsira, q.CEKID)::int AS SIRANO,
  q.CEKID, q.TARIH, q.AKSIYONTARIH, q.no, q.TUR, q.BASLIK, q.TURAD, q.REHBERID, q.KOD, q.AD, q.ACIKLAMA,
  q.HESAPID, q.HESAPKODU, q.HESAPADI, q.DURUM, q.BORC, q.ALACAK, q.KUR, q.MASRAFID, q.MASRAFKOD, q.MASRAFAD,
  q.BORCBAKIYE, q.ALACAKBAKIYE, q.SUBEID, q.VADETARIHI
FROM (
  SELECT 0 AS devirsira, 0 AS CEKID, p_bastar AS TARIH, p_bastar AS AKSIYONTARIH, NULL::varchar(20) AS no, 2::smallint AS TUR,
    ''::varchar(150) AS BASLIK, 'Devir'::varchar(50) AS TURAD, 0 AS REHBERID, ''::varchar(20) AS KOD, ''::varchar(100) AS AD,
    'Devir'::varchar(500) AS ACIKLAMA, NULL::int AS HESAPID, NULL::varchar(100) AS HESAPKODU, NULL::varchar(150) AS HESAPADI, 1::smallint AS DURUM,
    SUM(BORC)::numeric AS BORC, SUM(ALACAK)::numeric AS ALACAK, KUR, 0 AS MASRAFID, ''::varchar(50) AS MASRAFKOD, ''::varchar(100) AS MASRAFAD,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END)::numeric AS BORCBAKIYE,
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END)::numeric AS ALACAKBAKIYE,
    SUBEID, p_bastar AS VADETARIHI
  FROM bal WHERE TUR IN (11,12,13,15,16,17,21,22,25,31,32,35,44,51,52,53,54,58) AND TARIH < p_bastar GROUP BY KUR, SUBEID
  UNION ALL
  SELECT 1 AS devirsira, CEKID, TARIH, AKSIYONTARIH, no, TUR, BASLIK, TURAD, REHBERID, KOD, AD, ACIKLAMA, HESAPID, HESAPKODU,
    HESAPADI, DURUM, BORC, ALACAK, KUR, MASRAFID, MASRAFKOD, MASRAFAD, BORCBAKIYE, ALACAKBAKIYE, SUBEID, VADETARIHI
  FROM bal WHERE TARIH >= p_bastar
) q
ORDER BY q.KUR, q.TARIH, q.devirsira, q.CEKID;
$$;

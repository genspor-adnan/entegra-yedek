-- Sp_Prg_KasaNakitEkstre PG portu (kasa NAKIT ekstresi).
--   App 'EXEC Sp_Prg_KasaNakitEkstre @KasaId,@BasTar,@BitTar' cagirir; PgExecCevir ->
--   'SELECT * FROM fn_prg_kasanakitekstre($1,$2,$3)'. Tarih literalleri 'unknown' gelir,
--   parametre tipi timestamp oldugundan PG coerce eder.
--   MSSQL orijinali #tmp + IDENTITY SIRANO + 2-katman GROUP BY (borc/alacak swap) + 3 UNION.
--   SIRANO = pencere running-bakiye sirasi -> row_number(order by KUR,TARIH, AraDevir-once, CEKID).
--   Yerel para birimi kodu: GENINI BOLUM=-10135 ANAHTAR. Kasa tur adi: GENINI BOLUM=-1005.
CREATE OR REPLACE FUNCTION public.fn_prg_kasanakitekstre(
  p_kasaid integer, p_bastar timestamp, p_bittar timestamp)
RETURNS TABLE(
  cekid int, tarih timestamp, aksiyontarih timestamp, "NO" varchar, tur smallint,
  baslik varchar, turad varchar, rehberid int, kod varchar, ad varchar, aciklama varchar,
  hesapid int, hesapkodu varchar, hesapadi varchar, durum smallint,
  borc numeric, alacak numeric, yereltutar numeric, kur varchar, yerelkur numeric,
  masrafid int, masrafkod varchar, masrafad varchar, subeid int, vadetarihi timestamp,
  borcbakiye numeric, alacakbakiye numeric, yerelbakiye numeric)
AS $$
WITH yp AS (SELECT ANAHTAR AS c FROM GENINI WHERE BOLUM=-10135 LIMIT 1),
raw AS (
  -- Branch1: Ara Devir (acilis bakiyesi, @BasTar oncesi ayni yil)
  SELECT
    0 AS cekid, p_bastar AS tarih, p_bastar AS aksiyontarih, NULL::varchar AS "NO", 2::smallint AS tur,
    ''::varchar AS baslik, 'Ara Devir'::varchar AS turad, 0 AS rehberid,
    ''::varchar AS kod, ''::varchar AS ad, 'Ara Devir'::varchar AS aciklama,
    NULL::int AS hesapid, NULL::varchar AS hesapkodu, NULL::varchar AS hesapadi, 1::smallint AS durum,
    K.BORC::numeric AS borc, K.ALACAK::numeric AS alacak,
    K.KUR::varchar AS kur, 0::numeric AS yerelkur, 0 AS masrafid, ''::varchar AS masrafkod, ''::varchar AS masrafad,
    (SELECT SUM(A) FROM (
       SELECT CASE
         WHEN K1.DOVIZ_KURU=(SELECT c FROM yp) AND K1.BORC>0 THEN -1*K1.DOVIZ_TUTARI
         WHEN K1.DOVIZ_KURU=(SELECT c FROM yp) AND K1.ALACAK>0 THEN K1.DOVIZ_TUTARI
         WHEN K1.TUR=88 THEN K1.DOVIZ_TUTARI
         WHEN K1.TUR=98 THEN -1*K1.DOVIZ_TUTARI
         ELSE K1.ALACAK-K1.BORC END AS A
       FROM KASA K1
       WHERE K1.HESAPID=p_kasaid AND K1.ISLEMTARIHI<=p_bastar
         AND ((K1.HESAPTURU='K') OR (K1.HESAPTURU='B' AND K1.KASA IN (195,196)))
    ) S)::numeric AS yereltutar,
    K.SUBEID AS subeid, K.ISLEMTARIHI AS vadetarihi
  FROM KASA K
  LEFT JOIN GENINI KasaTurleri ON K.TUR=KasaTurleri.DEGER AND KasaTurleri.DIL=-1 AND KasaTurleri.BOLUM=-1005
  WHERE K.ISLEMTARIHI<=p_bastar AND EXTRACT(YEAR FROM K.ISLEMTARIHI)=EXTRACT(YEAR FROM p_bastar)
    AND K.HESAPID=p_kasaid
    AND ((K.HESAPTURU='K') OR (K.HESAPTURU='B' AND K.KASA IN (195,196)))
    AND NOT EXISTS (SELECT 1 FROM KASA K1 WHERE K1.ID=K.ID AND K1.TUR NOT IN (2)
                    AND K.ISLEMTARIHI=K1.ISLEMTARIHI AND K1.ISLEMTARIHI>=p_bastar)

  UNION ALL
  -- Branch2: KASA hareketleri (@BasTar..@BitTar)
  SELECT K.ID AS cekid, K.ISLEMTARIHI AS tarih, K.ISLEMTARIHI AS aksiyontarih, K.BELGENO::varchar AS "NO", K.TUR AS tur,
    ''::varchar AS baslik, KasaTurleri.ANAHTAR::varchar AS turad, K.HESAPID AS rehberid,
    (CASE K.HESAPTURU
       WHEN 'B' THEN (SELECT HESAPKODU FROM BANKAHESAPLAR BH WHERE BH.ID=K.HESAPID)
       WHEN 'H' THEN (SELECT CAST(ID AS varchar) FROM PARA_KUPON PK WHERE PK.ID=K.HESAPID)
       WHEN 'K' THEN (SELECT KASAKODU FROM KASALAR K2 WHERE K2.ID=K.HESAPID)
       WHEN 'P' THEN (SELECT KODU FROM POS P WHERE P.ID=K.HESAPID)
       WHEN 'R' THEN (SELECT KREDIKODU FROM KREDILER KR WHERE KR.ID=K.HESAPID)
       WHEN 'V' THEN (SELECT KODU FROM KREDIKARTI KK WHERE KK.ID=K.HESAPID) END)::varchar AS kod,
    (CASE K.HESAPTURU
       WHEN 'B' THEN (SELECT HESAPADI FROM BANKAHESAPLAR BH WHERE BH.ID=K.HESAPID)
       WHEN 'H' THEN (SELECT ADI FROM PARA_KUPON PK WHERE PK.ID=K.HESAPID)
       WHEN 'K' THEN (SELECT KASAADI FROM KASALAR K2 WHERE K2.ID=K.HESAPID)
       WHEN 'P' THEN (SELECT ADI FROM POS P WHERE P.ID=K.HESAPID)
       WHEN 'R' THEN (SELECT ADI FROM KREDILER KR WHERE KR.ID=K.HESAPID)
       WHEN 'V' THEN (SELECT ADI FROM KREDIKARTI KK WHERE KK.ID=K.HESAPID) END)::varchar AS ad,
    K.ACIKLAMA::varchar AS aciklama, K.REHBERID AS hesapid,
    (CASE WHEN K.REHBERID=0 THEN M.KOD ELSE R.KOD END)::varchar AS hesapkodu,
    (CASE WHEN K.REHBERID=0 THEN M.AD ELSE R.FIRMA END)::varchar AS hesapadi,
    K.DURUM AS durum,
    K.ALACAK::numeric AS borc, K.BORC::numeric AS alacak,
    K.KUR::varchar AS kur,
    ABS((CASE WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.BORC>0 THEN -1*K.DOVIZ_TUTARI
              WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.ALACAK>0 THEN K.DOVIZ_TUTARI
              ELSE K.ALACAK-K.BORC END)/
         CASE WHEN (K.ALACAK-K.BORC)=0 THEN 1 ELSE (K.ALACAK-K.BORC) END)::numeric AS yerelkur,
    K.MASRAFID AS masrafid, M.KOD::varchar AS masrafkod, M.AD::varchar AS masrafad,
    (CASE WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.BORC>0 THEN -1*K.DOVIZ_TUTARI
          WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.ALACAK>0 THEN K.DOVIZ_TUTARI
          WHEN K.TUR=88 THEN K.DOVIZ_TUTARI
          WHEN K.TUR=98 THEN -1*K.DOVIZ_TUTARI
          ELSE K.ALACAK-K.BORC END)::numeric AS yereltutar,
    K.SUBEID AS subeid, K.ISLEMTARIHI AS vadetarihi
  FROM KASA K
  LEFT JOIN REHBER R ON R.ID=K.REHBERID
  LEFT JOIN GENINI KasaTurleri ON K.TUR=KasaTurleri.DEGER AND KasaTurleri.DIL=-1 AND KasaTurleri.BOLUM=-1005
  LEFT JOIN MASRAFGELIR M ON M.ID=K.MASRAFID
  WHERE K.ISLEMTARIHI BETWEEN p_bastar AND p_bittar
    AND K.HESAPID=p_kasaid
    AND ((K.HESAPTURU='K') OR (K.HESAPTURU='B' AND K.KASA IN (195,196)))

  UNION ALL
  -- Branch3: FATBASLIK gelir/masraf faturalari (REHBERID=0, TUR 13/17)
  SELECT F.ID AS cekid, F.FATURATARIH AS tarih, F.FATURATARIH AS aksiyontarih, F.FATURANO::varchar AS "NO", F.TUR AS tur,
    F.BASLIK::varchar AS baslik,
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-1005 AND DEGER=F.TUR LIMIT 1)::varchar AS turad,
    F.REHBERID AS rehberid, R.KOD::varchar AS kod, R.FIRMA::varchar AS ad, F.ACIKLAMA::varchar AS aciklama,
    NULL::int AS hesapid, NULL::varchar AS hesapkodu, NULL::varchar AS hesapadi, F.DURUM AS durum,
    (CASE WHEN F.TUR IN (13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)::numeric AS borc,
    (CASE WHEN F.TUR IN (17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)::numeric AS alacak,
    (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END)::varchar AS kur,
    ABS((CASE WHEN F.DOVIZ_CINSI=(SELECT c FROM yp) AND F.TUR IN (17) THEN F.DOVIZ_TUTARI
              WHEN F.DOVIZ_CINSI=(SELECT c FROM yp) AND F.TUR IN (13) THEN -1*F.DOVIZ_TUTARI
              WHEN F.DOVIZ_CINSI<>(SELECT c FROM yp) AND F.TUR IN (17) THEN F.FATURA_TUTARI
              WHEN F.DOVIZ_CINSI<>(SELECT c FROM yp) AND F.TUR IN (13) THEN -1*F.FATURA_TUTARI END)/
         CASE WHEN ((CASE WHEN F.TUR IN (13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)-
                    (CASE WHEN F.TUR IN (17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END))=0 THEN 1
              ELSE ((CASE WHEN F.TUR IN (13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)-
                    (CASE WHEN F.TUR IN (17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)) END)::numeric AS yerelkur,
    F.MASRAFID AS masrafid, M.KOD::varchar AS masrafkod, M.AD::varchar AS masrafad,
    (CASE WHEN F.DOVIZ_CINSI=(SELECT c FROM yp) AND F.TUR IN (17) THEN F.DOVIZ_TUTARI
          WHEN F.DOVIZ_CINSI=(SELECT c FROM yp) AND F.TUR IN (13) THEN -1*F.DOVIZ_TUTARI
          WHEN F.DOVIZ_CINSI<>(SELECT c FROM yp) AND F.TUR IN (17) THEN F.FATURA_TUTARI
          WHEN F.DOVIZ_CINSI<>(SELECT c FROM yp) AND F.TUR IN (13) THEN -1*F.FATURA_TUTARI END)::numeric AS yereltutar,
    F.SUBEID AS subeid, (F.FATURATARIH + make_interval(days => coalesce(F.VADE,0)::int)) AS vadetarihi
  FROM FATBASLIK F
  LEFT JOIN REHBER R ON F.REHBERID=R.ID AND coalesce(F.DURUM,0)<>6
  LEFT JOIN MASRAFGELIR M ON M.ID=F.MASRAFID
  WHERE F.REHBERID=0 AND F.FATURATARIH BETWEEN p_bastar AND p_bittar AND F.KASA=p_kasaid AND F.TUR IN (13,17)
),
y AS (
  SELECT cekid,tarih,aksiyontarih,"NO",tur,baslik,turad,rehberid,kod,ad,aciklama,hesapid,hesapkodu,hesapadi,durum,
    SUM(borc) AS borc, SUM(alacak) AS alacak, kur,yerelkur,masrafid,masrafkod,masrafad,yereltutar,subeid,vadetarihi
  FROM raw
  GROUP BY cekid,tarih,aksiyontarih,"NO",tur,baslik,turad,rehberid,kod,ad,aciklama,hesapid,hesapkodu,hesapadi,durum,
    kur,yerelkur,masrafid,masrafkod,masrafad,yereltutar,subeid,vadetarihi
),
ins AS (
  SELECT cekid,tarih,aksiyontarih,"NO",tur,baslik,turad,rehberid,kod,ad,aciklama,hesapid,hesapkodu,hesapadi,durum,
    SUM(alacak) AS borc, SUM(borc) AS alacak, kur,yerelkur,masrafid,masrafkod,masrafad,yereltutar,subeid,vadetarihi
  FROM y
  GROUP BY cekid,tarih,aksiyontarih,"NO",tur,baslik,turad,rehberid,kod,ad,aciklama,hesapid,hesapkodu,hesapadi,durum,
    kur,yerelkur,masrafid,masrafkod,masrafad,yereltutar,subeid,vadetarihi
),
tmp AS (
  SELECT row_number() OVER (ORDER BY kur, tarih,
           CASE WHEN tur=2 AND aciklama='Ara Devir' THEN 0 ELSE 1 END, cekid) AS sirano, ins.*
  FROM ins
)
SELECT
  A.cekid, A.tarih, A.aksiyontarih, A."NO", A.tur, A.baslik, A.turad, A.rehberid, A.kod, A.ad, A.aciklama,
  A.hesapid, A.hesapkodu, A.hesapadi, A.durum,
  (CASE WHEN A.tur=2 AND A.aciklama='Ara Devir' THEN 0 ELSE A.borc END)::numeric AS borc,
  (CASE WHEN A.tur=2 AND A.aciklama='Ara Devir' THEN 0 ELSE A.alacak END)::numeric AS alacak,
  A.yereltutar, A.kur, A.yerelkur, A.masrafid, A.masrafkod, A.masrafad, A.subeid, A.vadetarihi,
  (CASE WHEN SUM(A.borc-A.alacak) OVER (ORDER BY A.kur,A.sirano)>0 THEN SUM(A.borc-A.alacak) OVER (ORDER BY A.kur,A.sirano) ELSE 0 END)::numeric AS borcbakiye,
  (CASE WHEN SUM(A.alacak-A.borc) OVER (ORDER BY A.kur,A.sirano)>0 THEN SUM(A.alacak-A.borc) OVER (ORDER BY A.kur,A.sirano) ELSE 0 END)::numeric AS alacakbakiye,
  (SUM(A.yereltutar) OVER (ORDER BY A.kur,A.sirano))::numeric AS yerelbakiye
FROM tmp A
WHERE NOT EXISTS (
  SELECT 1 FROM tmp B
  WHERE B.tarih=(SELECT C.tarih FROM tmp C WHERE B.tarih=C.tarih AND C.tur=2 AND C.cekid=0 LIMIT 1)
    AND B.cekid=A.cekid AND B.tur=2 AND A.cekid<>0)
ORDER BY A.kur, A.sirano;
$$ LANGUAGE sql;

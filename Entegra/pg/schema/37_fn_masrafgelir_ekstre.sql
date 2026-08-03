-- fn_MasrafGelir_Ekstre PG portu (masraf/gelir kalemi ekstresi).
--   MSSQL orijinali: @TOPLAM tablo-degiskeni + IDENTITY SIRANO + 4 UNION (FATBASLIK gider/gelir,
--   FATURA satir, serbest-meslek-makbuzu EKVERGI, KASA hareket) + ic-ice CURSOR ile KUR bazli
--   running bakiye + Devir satiri (BasTar oncesi toplam) + BasTar-oncesi satir silme.
--   PG: cursor -> pencere fonksiyonu (SUM OVER PARTITION BY kur ORDER BY sirano); SIRANO =
--   row_number(KUR,TARIH) (MSSQL insert 'order by KUR,2'); tablo-degisken -> CTE.
--   App 'SELECT * FROM dbo.fn_MasrafGelir_Ekstre(id,bas,bit) order by KUR,TARIH' cagirir.
--   NOT: buyuk/cetrefil -> gercek veride MSSQL ile differential dogrulama gerek (EKSPERT su an bos).
CREATE OR REPLACE FUNCTION public.fn_masrafgelir_ekstre(
  p_masrafid integer, p_bastar timestamp, p_bittar timestamp)
RETURNS TABLE(
  cekid int, tarih timestamp, aksiyontarih timestamp, "NO" varchar, tur smallint,
  baslik varchar, turad varchar, rehberid int, kod varchar, ad varchar, aciklama varchar,
  hesapid int, hesapkodu varchar, hesapadi varchar, durum smallint,
  borc numeric, alacak numeric, kur varchar, yerelkur numeric,
  masrafid int, masrafkod varchar, masrafad varchar,
  borcbakiye numeric, alacakbakiye numeric, yereltutar numeric, yerelbakiye numeric,
  subeid int, vadetarihi timestamp)
AS $$
WITH yp AS (SELECT ANAHTAR AS c FROM GENINI WHERE BOLUM=-10135 LIMIT 1),
ynew AS (SELECT ID AS id FROM MASRAFGELIR WHERE KOD=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-24045) LIMIT 1),
raw AS (
  -- Branch1: FATBASLIK dogrudan gider/gelir faturasi (TUR 13,17)
  SELECT FB.ID AS cekid, FB.FATURATARIH AS tarih, FB.FATURATARIH AS aksiyontarih, FB.FATURANO::varchar AS "NO", FB.TUR AS tur,
    FB.BASLIK::varchar AS baslik, KasaTurleri.ANAHTAR::varchar AS turad, FB.REHBERID AS rehberid,
    MG.KOD::varchar AS kod, MG.AD::varchar AS ad, FB.ACIKLAMA::varchar AS aciklama, FB.REHBERID AS hesapid,
    (CASE WHEN FB.REHBERID=0 AND FB.TIPI=1 AND coalesce(FB.KASA,0)<>0 THEN K.KASAKODU ELSE R.KOD END)::varchar AS hesapkodu,
    (CASE WHEN FB.REHBERID=0 AND FB.TIPI=1 AND coalesce(FB.KASA,0)<>0 THEN K.KASAADI ELSE R.FIRMA END)::varchar AS hesapadi,
    FB.DURUM AS durum,
    (CASE WHEN FB.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END)::numeric AS borc,
    (CASE WHEN FB.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END)::numeric AS alacak,
    (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_CINSI ELSE FB.KUR END)::varchar AS kur,
    ABS((CASE WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.TUR IN (15,16,17) THEN FB.DOVIZ_TUTARI
              WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.TUR IN (8,11,12,13) THEN -1*FB.DOVIZ_TUTARI
              WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.TUR IN (15,16,17) THEN FB.FATURA_TUTARI
              WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.TUR IN (8,11,12,13) THEN -1*FB.FATURA_TUTARI END)/
         CASE WHEN ((CASE WHEN FB.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END)-
                    (CASE WHEN FB.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END))=0 THEN 1
              ELSE ((CASE WHEN FB.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END)-
                    (CASE WHEN FB.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END)) END)::numeric AS yerelkur,
    FB.MASRAFID AS masrafid, MG.KOD::varchar AS masrafkod, MG.AD::varchar AS masrafad,
    (CASE WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.TUR IN (15,16,17) THEN FB.DOVIZ_TUTARI
          WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.TUR IN (8,11,12,13) THEN -1*FB.DOVIZ_TUTARI
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.TUR IN (15,16,17) THEN FB.FATURA_TUTARI
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.TUR IN (8,11,12,13) THEN -1*FB.FATURA_TUTARI END)::numeric AS yereltutar,
    FB.SUBEID AS subeid, (FB.FATURATARIH + make_interval(days=>coalesce(FB.VADE,0)::int)) AS vadetarihi
  FROM FATBASLIK FB
    INNER JOIN MASRAFGELIR MG ON FB.MASRAFID=MG.ID AND coalesce(FB.DURUM,0)<>6
    LEFT JOIN REHBER R ON R.ID=FB.REHBERID
    LEFT JOIN GENINI KasaTurleri ON FB.TUR=KasaTurleri.DEGER AND KasaTurleri.BOLUM=-1005 AND KasaTurleri.DIL=-1
    LEFT JOIN KASALAR K ON FB.KASA=K.ID
  WHERE coalesce(FB.FATURA_TUTARI,0)>0 AND MG.ID=p_masrafid
    AND extract(year from FB.FATURATARIH)>=extract(year from p_bastar)
    AND extract(year from FB.FATURATARIH)<=extract(year from p_bittar) AND FB.FATURATARIH<=p_bittar
    AND FB.TUR IN (13,17)

  UNION ALL
  -- Branch2: FATURA satir bazli (F.TUR=0 = masraf/gelir kalemi), TUR 11,12,15,16
  SELECT FB.ID AS cekid, FB.FATURATARIH AS tarih, FB.FATURATARIH AS aksiyontarih, FB.FATURANO::varchar AS "NO", FB.TUR AS tur,
    FB.BASLIK::varchar AS baslik, KasaTurleri.ANAHTAR::varchar AS turad, FB.REHBERID AS rehberid,
    (CASE WHEN F.TUR=0 THEN (SELECT KOD FROM MASRAFGELIR MG2 WHERE MG2.ID=F.URUNID)
          WHEN F.TUR=1 THEN (SELECT KOD FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END)::varchar AS kod,
    (CASE WHEN F.TUR=0 THEN (SELECT AD FROM MASRAFGELIR MG2 WHERE MG2.ID=F.URUNID)
          WHEN F.TUR=1 THEN (SELECT S.STOKADI FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END)::varchar AS ad,
    ((CASE WHEN F.TUR=0 THEN (SELECT AD FROM MASRAFGELIR MG2 WHERE MG2.ID=F.URUNID)
           WHEN F.TUR=1 THEN (SELECT S.STOKADI FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END) || ' ' || coalesce(FB.ACIKLAMA,''))::varchar AS aciklama,
    FB.REHBERID AS hesapid, R.KOD::varchar AS hesapkodu, R.FIRMA::varchar AS hesapadi, FB.DURUM AS durum,
    (CASE WHEN FB.TUR IN (8,11,12) THEN 0.0 ELSE
       (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN ((F.DOVIZ_TUTARI)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
             WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN (((coalesce(F.DOVIZ_TUTARI,0)/(1+(F.KDV/100.0))))/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
             WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN F.DOVIZ_TUTARI
             WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN (coalesce(F.DOVIZ_TUTARI,0)/(1+(F.KDV/100.0)))
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN ((F.TUTAR)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN (((coalesce(F.TUTAR,0)/(1+(F.KDV/100.0))))/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN F.TUTAR
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN (coalesce(F.TUTAR,0)/(1+(F.KDV/100.0))) END) END)::numeric AS borc,
    (CASE WHEN FB.TUR IN (15,16) THEN 0.0 ELSE
       (CASE WHEN FB.EKSTREDEKULLAN=1 AND FB.KDVDURUM='Hariç' THEN F.DOVIZ_TUTARI
             WHEN FB.EKSTREDEKULLAN=1 AND FB.KDVDURUM='Dahil' THEN (coalesce(F.DOVIZ_TUTARI,0)/(1+(F.KDV/100.0)))
             WHEN FB.EKSTREDEKULLAN=0 AND FB.KDVDURUM='Hariç' THEN F.TUTAR
             WHEN FB.EKSTREDEKULLAN=0 AND FB.KDVDURUM='Dahil' THEN (coalesce(F.TUTAR,0)/(1+(F.KDV/100.0))) END) END)::numeric AS alacak,
    (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_CINSI ELSE FB.KUR END)::varchar AS kur,
    ABS(ROUND((CASE WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.TUR IN (15,16) AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
                    WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.TUR IN (15,16) AND MG.KOD LIKE '600.%' THEN ((F.DOVIZ_TUTARI)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                    WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.TUR IN (8,11,12) THEN -1*nullif(F.DOVIZ_TUTARI,0)
                    WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.TUR IN (15,16) AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0)
                    WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.TUR IN (15,16) AND MG.KOD LIKE '600.%' THEN ((F.TUTAR)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                    WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.TUR IN (8,11,12) THEN -1*nullif(F.TUTAR,0) END)::numeric,4)/
        ROUND((CASE WHEN ((CASE WHEN FB.TUR IN (8,11,12) THEN 0.0 ELSE
                       (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' THEN ((F.DOVIZ_TUTARI)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                             WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
                             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' THEN ((F.TUTAR)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0) END) END)-
                     (CASE WHEN FB.TUR IN (15,16) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END))=0 THEN 1
                    ELSE ((CASE WHEN FB.TUR IN (8,11,12) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' THEN ((F.DOVIZ_TUTARI)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                          WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
                          WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' THEN ((F.TUTAR)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                          WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0) END) END)-
                         (CASE WHEN FB.TUR IN (15,16) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' THEN ((F.DOVIZ_TUTARI)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                          WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
                          WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' THEN ((F.TUTAR)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
                          WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0) END) END)) END)::numeric,4))::numeric AS yerelkur,
    MG.ID AS masrafid, MG.KOD::varchar AS masrafkod, MG.AD::varchar AS masrafad,
    (CASE WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN F.DOVIZ_TUTARI
          WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN (coalesce(F.DOVIZ_TUTARI,0)/(1+(F.KDV/100.0)))
          WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN ((F.DOVIZ_TUTARI)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
          WHEN FB.RAPORDOVIZ=(SELECT c FROM yp) AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN (((coalesce(F.DOVIZ_TUTARI,0)/(1+(F.KDV/100.0))))/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN F.TUTAR
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN (coalesce(F.TUTAR,0)/(1+(F.KDV/100.0)))
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN ((F.TUTAR)/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN (((coalesce(F.TUTAR,0)/(1+(F.KDV/100.0))))/(1-(F.ISKONTO/100.0)))/(1-(F.ISKONTO2/100.0))
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.KDVDURUM='Hariç' AND FB.TIPI=4 THEN F.TUTAR+(-1*coalesce(FB.EKVERGI,0))
          WHEN FB.RAPORDOVIZ<>(SELECT c FROM yp) AND FB.KDVDURUM='Dahil' AND FB.TIPI=4 THEN (coalesce(F.TUTAR,0)/(1+(F.KDV/100.0)))+(-1*coalesce(FB.EKVERGI,0)) END)::numeric AS yereltutar,
    F.SUBEID AS subeid, (FB.FATURATARIH + make_interval(days=>coalesce(FB.VADE,0)::int)) AS vadetarihi
  FROM FATURA F
    INNER JOIN MASRAFGELIR MG ON F.TUR=0 AND F.URUNID=MG.ID
    INNER JOIN FATBASLIK FB ON FB.ID=F.FATBASID AND coalesce(FB.DURUM,0)<>6
    LEFT JOIN REHBER R ON R.ID=FB.REHBERID
    LEFT JOIN GENINI KasaTurleri ON FB.TUR=KasaTurleri.DEGER AND KasaTurleri.BOLUM=-1005 AND KasaTurleri.DIL=-1
  WHERE F.TUR=0 AND F.URUNID=p_masrafid
    AND extract(year from FB.FATURATARIH)>=extract(year from p_bastar)
    AND extract(year from FB.FATURATARIH)<=extract(year from p_bittar) AND FB.FATURATARIH<=p_bittar
    AND FB.TUR IN (11,12,15,16)

  UNION ALL
  -- Branch3: Serbest Meslek Makbuzu (EKVERGI, TUR=11 TIPI=4, YENIMASRAFID)
  SELECT FB.ID AS cekid, FB.FATURATARIH AS tarih, FB.FATURATARIH AS aksiyontarih, FB.FATURANO::varchar AS "NO", FB.TUR AS tur,
    FB.BASLIK::varchar AS baslik, KasaTurleri.ANAHTAR::varchar AS turad, FB.REHBERID AS rehberid,
    (CASE WHEN F.TUR=0 THEN (SELECT KOD FROM MASRAFGELIR MG2 WHERE MG2.ID=(SELECT id FROM ynew))
          WHEN F.TUR=1 THEN (SELECT KOD FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END)::varchar AS kod,
    (CASE WHEN F.TUR=0 THEN (SELECT AD FROM MASRAFGELIR MG2 WHERE MG2.ID=(SELECT id FROM ynew))
          WHEN F.TUR=1 THEN (SELECT S.STOKADI FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END)::varchar AS ad,
    ((CASE WHEN F.TUR=0 THEN (SELECT AD FROM MASRAFGELIR MG2 WHERE MG2.ID=(SELECT id FROM ynew))
           WHEN F.TUR=1 THEN (SELECT S.STOKADI FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END) || ' ' || coalesce(FB.ACIKLAMA,''))::varchar AS aciklama,
    FB.REHBERID AS hesapid, R.KOD::varchar AS hesapkodu, R.FIRMA::varchar AS hesapadi, FB.DURUM AS durum,
    0::numeric AS borc, (-1*FB.EKVERGI)::numeric AS alacak, FB.KUR::varchar AS kur, 1::numeric AS yerelkur,
    MG.ID AS masrafid, MG.KOD::varchar AS masrafkod, MG.AD::varchar AS masrafad,
    (FB.EKVERGI*-1)::numeric AS yereltutar,
    F.SUBEID AS subeid, (FB.FATURATARIH + make_interval(days=>coalesce(FB.VADE,0)::int)) AS vadetarihi
  FROM FATURA F
    INNER JOIN MASRAFGELIR MG ON F.TUR=0 AND MG.ID=(SELECT id FROM ynew)
    INNER JOIN FATBASLIK FB ON FB.ID=F.FATBASID AND coalesce(FB.DURUM,0)<>6
    LEFT JOIN REHBER R ON R.ID=FB.REHBERID
    LEFT JOIN GENINI KasaTurleri ON FB.TUR=KasaTurleri.DEGER AND KasaTurleri.BOLUM=-1005 AND KasaTurleri.DIL=-1
  WHERE F.TUR=0
    AND extract(year from FB.FATURATARIH)>=extract(year from p_bastar)
    AND extract(year from FB.FATURATARIH)<=extract(year from p_bittar) AND FB.FATURATARIH<=p_bittar
    AND FB.TUR IN (11) AND FB.TIPI=4 AND F.URUNID=(SELECT id FROM ynew)

  UNION ALL
  -- Branch4: KASA hareketleri (REHBERID=0 veya HESAPTURU='-'), belirli TUR'ler
  SELECT K.ID AS cekid, K.ISLEMTARIHI AS tarih, K.PLANTARIHI AS aksiyontarih, K.BELGENO::varchar AS "NO", K.TUR AS tur,
    ''::varchar AS baslik,
    (CASE WHEN K.TUR::text LIKE '26__' THEN (SELECT ANAHTAR||' tahsilatı ' FROM GENINI WHERE BOLUM=-2329 AND 2600+DEGER=K.TUR LIMIT 1)
          WHEN K.TUR::text LIKE '36__' THEN (SELECT ANAHTAR||' ödemesi ' FROM GENINI WHERE BOLUM=-2329 AND 3600+DEGER=K.TUR LIMIT 1)
          ELSE (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-1005 AND DEGER=K.TUR LIMIT 1) END)::varchar AS turad,
    K.REHBERID AS rehberid,
    (CASE WHEN K.REHBERID=0 THEN M.KOD ELSE R.KOD END)::varchar AS kod,
    (CASE WHEN K.REHBERID=0 THEN M.AD ELSE R.FIRMA END)::varchar AS ad,
    K.ACIKLAMA::varchar AS aciklama, K.HESAPID AS hesapid,
    (CASE K.HESAPTURU
       WHEN 'B' THEN (SELECT HESAPKODU FROM BANKAHESAPLAR BH WHERE BH.ID=K.HESAPID)
       WHEN 'H' THEN (SELECT KASAKODU FROM KASALAR K2 WHERE K2.ID=K.HESAPID) || coalesce(' ('||(SELECT ADI FROM PARA_KUPON PK WHERE PK.ID=K.CEKSENETID)||')','')
       WHEN 'K' THEN (SELECT KASAKODU FROM KASALAR K2 WHERE K2.ID=K.HESAPID)
       WHEN 'P' THEN (SELECT KODU FROM POS P WHERE P.ID=K.HESAPID)
       WHEN 'V' THEN (SELECT KODU FROM KREDIKARTI KK WHERE KK.ID=K.HESAPID)
       WHEN '-' THEN (SELECT RR.KOD FROM REHBER RR WHERE RR.ID=K.REHBERID) END)::varchar AS hesapkodu,
    (CASE K.HESAPTURU
       WHEN 'B' THEN (SELECT HESAPADI FROM BANKAHESAPLAR BH WHERE BH.ID=K.HESAPID)
       WHEN 'H' THEN (SELECT KASAADI FROM KASALAR K2 WHERE K2.ID=K.HESAPID) || coalesce(' ('||(SELECT ADI FROM PARA_KUPON PK WHERE PK.ID=K.CEKSENETID)||')','')
       WHEN 'K' THEN (SELECT KASAADI FROM KASALAR K2 WHERE K2.ID=K.HESAPID)
       WHEN 'P' THEN (SELECT ADI FROM POS P WHERE P.ID=K.HESAPID)
       WHEN 'V' THEN (SELECT ADI FROM KREDIKARTI KK WHERE KK.ID=K.HESAPID)
       WHEN '-' THEN (SELECT RR.FIRMA FROM REHBER RR WHERE RR.ID=K.REHBERID) END)::varchar AS hesapadi,
    K.DURUM AS durum,
    (CASE WHEN K.TUR=88 THEN K.DOVIZ_TUTARI WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)::numeric AS borc,
    (CASE WHEN K.TUR=98 THEN K.DOVIZ_TUTARI WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END)::numeric AS alacak,
    (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END)::varchar AS kur,
    ABS((CASE WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.BORC>0 THEN K.DOVIZ_TUTARI WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.ALACAK>0 THEN -1*K.DOVIZ_TUTARI ELSE K.BORC-K.ALACAK END)/
        CASE WHEN ((CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)-(CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END))=0 THEN 1
             ELSE ((CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)-(CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END)) END)::numeric AS yerelkur,
    K.MASRAFID AS masrafid, M.KOD::varchar AS masrafkod, M.AD::varchar AS masrafad,
    (CASE WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.BORC>0 THEN K.DOVIZ_TUTARI
          WHEN K.DOVIZ_KURU=(SELECT c FROM yp) AND K.ALACAK>0 THEN -1*K.DOVIZ_TUTARI
          ELSE K.BORC-K.ALACAK END)::numeric AS yereltutar,
    K.SUBEID AS subeid, K.ISLEMTARIHI AS vadetarihi
  FROM KASA K
    LEFT JOIN REHBER R ON K.REHBERID=R.ID
    LEFT JOIN MASRAFGELIR M ON M.ID=K.MASRAFID
  WHERE (CASE WHEN K.REHBERID=0 THEN 1 WHEN (K.REHBERID>0) AND (K.HESAPTURU='-') THEN 1 ELSE 0 END)=1
    AND K.MASRAFID=p_masrafid
    AND extract(year from K.ISLEMTARIHI)>=extract(year from p_bastar)
    AND extract(year from K.ISLEMTARIHI)<=extract(year from p_bittar) AND K.ISLEMTARIHI<=p_bittar
    AND K.TUR IN (1,21,22,23,33,35,44,58,88,98)
),
tmp AS (
  SELECT row_number() OVER (ORDER BY kur, tarih, cekid) AS sirano, raw.*
  FROM raw
),
-- Running bakiye: KUR bazli, SIRANO sirali. TUR 60-79 satirlar bakiyeye KATILMAZ (cursor mantigi).
bak AS (
  SELECT tmp.*,
    SUM(CASE WHEN tur BETWEEN 60 AND 79 THEN 0 ELSE borc-alacak END) OVER (PARTITION BY kur ORDER BY sirano) AS run_bb,
    SUM(CASE WHEN tur BETWEEN 60 AND 79 THEN 0 ELSE alacak-borc END) OVER (PARTITION BY kur ORDER BY sirano) AS run_ab,
    SUM(CASE WHEN tur BETWEEN 60 AND 79 THEN 0 ELSE yereltutar END)   OVER (PARTITION BY kur ORDER BY sirano) AS run_yb
  FROM tmp
),
-- Devir satiri: BasTar oncesi (belirli TUR'ler) KUR+SUBEID bazli toplam. TARIH=@BasTar.
devir AS (
  SELECT 0 AS cekid, p_bastar AS tarih, p_bastar AS aksiyontarih, NULL::varchar AS "NO", 2::smallint AS tur,
    ''::varchar AS baslik, 'Devir'::varchar AS turad, 0 AS rehberid, ''::varchar AS kod, ''::varchar AS ad,
    'Devir'::varchar AS aciklama, NULL::int AS hesapid, NULL::varchar AS hesapkodu, NULL::varchar AS hesapadi, 1::smallint AS durum,
    SUM(borc)::numeric AS borc, SUM(alacak)::numeric AS alacak, kur, NULL::numeric AS yerelkur,
    0 AS masrafid, ''::varchar AS masrafkod, ''::varchar AS masrafad,
    (CASE WHEN SUM(borc-alacak)>0 THEN SUM(borc-alacak) ELSE 0 END)::numeric AS borcbakiye,
    (CASE WHEN SUM(alacak-borc)>0 THEN SUM(alacak-borc) ELSE 0 END)::numeric AS alacakbakiye,
    SUM(yereltutar)::numeric AS yereltutar,
    (CASE WHEN SUM(yereltutar)>0 THEN SUM(yereltutar) ELSE 0 END)::numeric AS yerelbakiye,
    subeid, p_bastar AS vadetarihi
  FROM tmp
  WHERE tur IN (11,12,13,15,16,17,31,32,35,44,58,88,98) AND tarih < p_bastar
  GROUP BY kur, subeid
)
-- BasTar >= satirlar (running bakiye ile) + devir satiri. BasTar oncesi ham satirlar atlanir.
SELECT cekid,tarih,aksiyontarih,"NO",tur,baslik,turad,rehberid,kod,ad,aciklama,hesapid,hesapkodu,hesapadi,durum,
  borc,alacak,kur,yerelkur,masrafid,masrafkod,masrafad,
  (CASE WHEN run_bb>0 THEN run_bb ELSE 0 END)::numeric AS borcbakiye,
  (CASE WHEN run_ab>0 THEN run_ab ELSE 0 END)::numeric AS alacakbakiye,
  yereltutar, run_yb::numeric AS yerelbakiye,
  subeid, vadetarihi
FROM bak
WHERE tarih >= p_bastar
UNION ALL
SELECT cekid,tarih,aksiyontarih,"NO",tur,baslik,turad,rehberid,kod,ad,aciklama,hesapid,hesapkodu,hesapadi,durum,
  borc,alacak,kur,yerelkur,masrafid,masrafkod,masrafad,borcbakiye,alacakbakiye,yereltutar,yerelbakiye,subeid,vadetarihi
FROM devir;
$$ LANGUAGE sql;

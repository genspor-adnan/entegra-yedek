-- ============================================================================
-- fn_masrafgelir_tam_ekstre (PG portu, TVF-per-engine)
-- MSSQL: fn_MasrafGelir_Tam_Ekstre(@MasrafID int,@BasTar datetime,@BitTar datetime)
-- 5 kaynak union: KASA + FATBASLIK + FATURA(satir, MASRAFGELIR/FATBASLIK) + CEK(CEKHAREKET) + SENET.
-- MasrafID filtresi: KASA/FATBASLIK/CEK/SENET = MASRAFID kolonu; FATURA = F.URUNID (F.TUR=0).
-- Running bakiye CURSOR (TUR 60-79 haric, 61/71 dahil) -> window greatest(SUM(...) OVER(PARTITION BY KUR ORDER BY ...),0).
--   Bakiye tum satirlar (pre+post) uzerinden; sonra Devir(pre-BasTar aggregate, KUR+SUBEID) eklenir, pre satirlar cikarilir.
-- @YERELKUR = GENINI BOLUM=-10135 (yk CTE CROSS JOIN). Guardsiz bolme -> nullif(...,0).
-- Coz.kolon: NOTLAR->REHBER; FATURA arm'da EKSTREDEKULLAN/FATURA_TUTARI/DOVIZ_CINSI->FATBASLIK, ISKONTO/ISKONTO2/KDV/TUTAR/ADET/BIRIMFIYAT->FATURA.
-- NOT: differential dogrula.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_masrafgelir_tam_ekstre(integer, timestamp, timestamp);
CREATE OR REPLACE FUNCTION fn_masrafgelir_tam_ekstre(p_masrafid integer, p_bastar timestamp, p_bittar timestamp)
RETURNS TABLE(
  "SIRANO" integer,"CEKID" integer,"TARIH" timestamp,"AKSIYONTARIH" timestamp,"NO" varchar(20),"TUR" smallint,
  "BASLIK" varchar(250),"TURAD" varchar(50),"REHBERID" integer,"KOD" varchar(20),"AD" varchar(100),
  "ACIKLAMA" varchar(500),"HESAPID" integer,"HESAPKODU" varchar(100),"HESAPADI" varchar(250),"DURUM" smallint,
  "BORC" numeric,"ALACAK" numeric,"KUR" varchar(6),"YERELKUR" numeric,"MASRAFID" integer,"MASRAFKOD" varchar(50),
  "MASRAFAD" varchar(200),"BORCBAKIYE" numeric,"ALACAKBAKIYE" numeric,"YERELTUTAR" numeric,"YERELBAKIYE" numeric,
  "SUBEID" integer,"VADETARIHI" timestamp,"ADET" double precision,"BIRIM" varchar(30),"BIRIMFIYAT" numeric)
LANGUAGE sql AS $$
WITH yk AS (SELECT ANAHTAR AS d FROM GENINI WHERE BOLUM=-10135 LIMIT 1),
har AS (
  -- ==================== KASA ====================
  SELECT
    K.ID::int AS cekid, K.ISLEMTARIHI AS tarih, K.PLANTARIHI AS aksiyontarih, K.BELGENO::varchar(20) AS no, K.TUR::smallint AS tur,
    ''::varchar(250) AS baslik,
    (CASE WHEN K.TUR::text LIKE '26__' THEN (SELECT ANAHTAR||' tahsilatı ' FROM GENINI WHERE BOLUM=-2329 AND 2600+DEGER=K.TUR LIMIT 1)
          WHEN K.TUR::text LIKE '36__' THEN (SELECT ANAHTAR||' ödemesi ' FROM GENINI WHERE BOLUM=-2329 AND 3600+DEGER=K.TUR LIMIT 1)
          ELSE (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-1005 AND DEGER=K.TUR LIMIT 1) END)::varchar(50) AS turad,
    K.REHBERID::int AS rehberid,
    (CASE WHEN K.REHBERID=0 THEN M.KOD ELSE R.KOD END)::varchar(20) AS kod,
    (CASE WHEN K.REHBERID=0 THEN M.AD ELSE R.FIRMA END)::varchar(100) AS ad,
    K.ACIKLAMA::varchar(500) AS aciklama, K.HESAPID::int AS hesapid,
    (CASE K.HESAPTURU WHEN 'B' THEN Banka.HESAPKODU WHEN 'H' THEN KS.KASAKODU||coalesce(' ('||PK.ADI||')','') WHEN 'K' THEN KS.KASAKODU
       WHEN 'P' THEN POS.KODU WHEN 'V' THEN KK.KODU END)::varchar(100) AS hesapkodu,
    (CASE K.HESAPTURU WHEN 'B' THEN Banka.HESAPADI WHEN 'H' THEN KS.KASAADI||coalesce(' ('||PK.ADI||')','') WHEN 'K' THEN KS.KASAADI
       WHEN 'P' THEN POS.ADI WHEN 'V' THEN KK.ADI END)::varchar(250) AS hesapadi,
    K.DURUM::smallint AS durum,
    (CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)::numeric AS borc,
    (CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END)::numeric AS alacak,
    (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END)::varchar(6) AS kur,
    ABS((CASE WHEN K.DOVIZ_KURU=YK.d AND K.BORC>0 THEN K.DOVIZ_TUTARI WHEN K.DOVIZ_KURU=YK.d AND K.ALACAK>0 THEN -1*K.DOVIZ_TUTARI ELSE K.BORC-K.ALACAK END)
        / (CASE WHEN ((CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)-(CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END))=0 THEN 1
                ELSE ((CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)-(CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END)) END))::numeric AS yerelkur,
    K.MASRAFID::int AS masrafid, M.KOD::varchar(50) AS masrafkod, M.AD::varchar(200) AS masrafad,
    (CASE WHEN K.DOVIZ_KURU=YK.d AND K.BORC>0 THEN K.DOVIZ_TUTARI WHEN K.DOVIZ_KURU=YK.d AND K.ALACAK>0 THEN -1*K.DOVIZ_TUTARI
          WHEN K.TUR=88 THEN K.DOVIZ_TUTARI WHEN K.TUR=98 THEN -1*K.DOVIZ_TUTARI ELSE K.BORC-K.ALACAK END)::numeric AS yereltutar,
    K.SUBEID::int AS subeid, K.ISLEMTARIHI AS vadetarihi, 1.0::double precision AS adet, ''::varchar(30) AS birim, 0.0::numeric AS birimfiyat
  FROM KASA K
    LEFT JOIN REHBER R ON K.REHBERID=R.ID
    LEFT JOIN KASALAR KS ON KS.ID=K.HESAPID
    LEFT JOIN MASRAFGELIR M ON M.ID=K.MASRAFID
    LEFT JOIN BANKAHESAPLAR Banka ON Banka.ID=K.HESAPID
    LEFT JOIN POS ON POS.ID=K.HESAPID
    LEFT JOIN KREDIKARTI KK ON KK.ID=K.HESAPID
    LEFT JOIN PARA_KUPON PK ON PK.ID=K.CEKSENETID
    CROSS JOIN yk YK
  WHERE K.MASRAFID=p_masrafid
    AND extract(year from K.ISLEMTARIHI)>=extract(year from p_bastar) AND extract(year from K.ISLEMTARIHI)<=extract(year from p_bittar)
    AND K.ISLEMTARIHI<=p_bittar AND ((K.TUR IN (49,61,71)) OR (K.TUR NOT BETWEEN 40 AND 79))

  UNION ALL
  -- ==================== FATBASLIK ====================
  SELECT
    F.ID::int, F.FATURATARIH, F.FATURATARIH, F.FATURANO::varchar(20), F.TUR::smallint, F.BASLIK::varchar(250),
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-1005 AND DEGER=F.TUR LIMIT 1)::varchar(50),
    F.REHBERID::int, R.KOD::varchar(20), R.FIRMA::varchar(100), F.ACIKLAMA::varchar(500), NULL::int, NULL::varchar(100), NULL::varchar(250), F.DURUM::smallint,
    (CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 WHEN F.TIPI=5 THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)::numeric,
    (CASE WHEN F.TUR IN (15,16,17) THEN 0.0 WHEN F.TIPI=5 THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)::numeric,
    (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END)::varchar(6),
    (CASE WHEN F.TIPI=5 THEN F.DOVIZKUR ELSE
      ABS((CASE WHEN F.RAPORDOVIZ=YK.d AND F.TUR IN (15,16,17) THEN F.DOVIZ_TUTARI WHEN F.RAPORDOVIZ=YK.d AND F.TUR IN (8,11,12,13) THEN -1*F.DOVIZ_TUTARI
                WHEN F.RAPORDOVIZ<>YK.d AND F.TUR IN (15,16,17) THEN F.FATURA_TUTARI WHEN F.RAPORDOVIZ<>YK.d AND F.TUR IN (8,11,12,13) THEN -1*F.FATURA_TUTARI END)
          / (CASE WHEN ((CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)
                       -(CASE WHEN F.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END))=0 THEN 1
                  ELSE ((CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)
                       -(CASE WHEN F.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)) END)) END)::numeric,
    F.MASRAFID::int, M.KOD::varchar(50), M.AD::varchar(200),
    (CASE WHEN F.RAPORDOVIZ=YK.d AND F.TUR IN (15,16,17) THEN F.DOVIZ_TUTARI WHEN F.RAPORDOVIZ=YK.d AND F.TUR IN (8,11,12,13) THEN -1*F.DOVIZ_TUTARI
          WHEN F.RAPORDOVIZ<>YK.d AND F.TUR IN (15,16,17) THEN F.FATURA_TUTARI WHEN F.RAPORDOVIZ<>YK.d AND F.TUR IN (8,11,12,13) THEN -1*F.FATURA_TUTARI END)::numeric,
    F.SUBEID::int, (F.FATURATARIH + (coalesce(F.VADE,0)*interval '1 day'))::timestamp, 1.0::double precision, ''::varchar(30), 0.0::numeric
  FROM FATBASLIK F
    INNER JOIN REHBER R ON F.REHBERID=R.ID AND F.TUR IN (8,11,12,13,15,16,17) AND coalesce(F.DURUM,0)<>6
    LEFT JOIN MASRAFGELIR M ON M.ID=F.MASRAFID
    CROSS JOIN yk YK
  WHERE F.MASRAFID=p_masrafid
    AND extract(year from F.FATURATARIH)>=extract(year from p_bastar) AND extract(year from F.FATURATARIH)<=extract(year from p_bittar)
    AND F.FATURATARIH<=p_bittar

  UNION ALL
  -- ==================== FATURA (satir bazli, masraf) ====================
  SELECT
    FB.ID::int, FB.FATURATARIH, FB.FATURATARIH, FB.FATURANO::varchar(20), FB.TUR::smallint, FB.BASLIK::varchar(250),
    KasaTurleri.ANAHTAR::varchar(50), FB.REHBERID::int,
    (CASE WHEN F.TUR=0 THEN (SELECT KOD FROM MASRAFGELIR MG2 WHERE MG2.ID=F.URUNID) WHEN F.TUR=1 THEN (SELECT KOD FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END)::varchar(20),
    (CASE WHEN F.TUR=0 THEN (SELECT AD FROM MASRAFGELIR MG2 WHERE MG2.ID=F.URUNID) WHEN F.TUR=1 THEN (SELECT S.STOKADI FROM STOKLAR S WHERE S.ID=F.URUNID) ELSE '' END)::varchar(100),
    (MG.AD||' '||FB.ACIKLAMA)::varchar(500), FB.REHBERID::int, R.KOD::varchar(100), R.FIRMA::varchar(250), FB.DURUM::smallint,
    -- BORC
    (CASE WHEN FB.TUR IN (8,11,12) THEN 0.0 ELSE
       (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN (F.DOVIZ_TUTARI/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
             WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN ((coalesce(F.DOVIZ_TUTARI,0)/nullif(1+(F.KDV/100.0),0))/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
             WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN F.DOVIZ_TUTARI
             WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN coalesce(F.DOVIZ_TUTARI,0)/nullif(1+(F.KDV/100.0),0)
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN (F.TUTAR/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN ((coalesce(F.TUTAR,0)/nullif(1+(F.KDV/100.0),0))/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Hariç' THEN F.TUTAR
             WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' AND FB.KDVDURUM='Dahil' THEN coalesce(F.TUTAR,0)/nullif(1+(F.KDV/100.0),0) END)
     END)::numeric,
    -- ALACAK
    (CASE WHEN FB.TUR IN (15,16) THEN 0.0 ELSE
       (CASE WHEN FB.EKSTREDEKULLAN=1 AND FB.KDVDURUM='Hariç' THEN F.DOVIZ_TUTARI
             WHEN FB.EKSTREDEKULLAN=1 AND FB.KDVDURUM='Dahil' THEN coalesce(F.DOVIZ_TUTARI,0)/nullif(1+(F.KDV/100.0),0)
             WHEN FB.EKSTREDEKULLAN=0 AND FB.KDVDURUM='Hariç' THEN F.TUTAR
             WHEN FB.EKSTREDEKULLAN=0 AND FB.KDVDURUM='Dahil' THEN coalesce(F.TUTAR,0)/nullif(1+(F.KDV/100.0),0) END)
     END)::numeric,
    (CASE WHEN FB.EKSTREDEKULLAN=1 THEN FB.DOVIZ_CINSI ELSE FB.KUR END)::varchar(6),
    -- YERELKUR = ABS( ROUND(num,4) / nullif(ROUND(den,4),0) )
    ABS(
      ROUND((CASE
          WHEN FB.RAPORDOVIZ=YK.d AND FB.TUR IN (15,16) AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
          WHEN FB.RAPORDOVIZ=YK.d AND FB.TUR IN (15,16) AND MG.KOD LIKE '600.%' THEN (F.DOVIZ_TUTARI/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
          WHEN FB.RAPORDOVIZ=YK.d AND FB.TUR IN (8,11,12) THEN -1*nullif(F.DOVIZ_TUTARI,0)
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.TUR IN (15,16) AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0)
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.TUR IN (15,16) AND MG.KOD LIKE '600.%' THEN (F.TUTAR/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.TUR IN (8,11,12) THEN -1*nullif(F.TUTAR,0) END)::numeric,4)
      / nullif(ROUND((CASE WHEN
          ((CASE WHEN FB.TUR IN (8,11,12) THEN 0.0 ELSE
              (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' THEN (F.DOVIZ_TUTARI/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
                    WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
                    WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' THEN (F.TUTAR/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
                    WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0) END) END)
           -(CASE WHEN FB.TUR IN (15,16) THEN 0.0 ELSE (CASE WHEN FB.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE FB.FATURA_TUTARI END) END))=0 THEN 1
        ELSE
          ((CASE WHEN FB.TUR IN (8,11,12) THEN 0.0 ELSE
              (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' THEN (F.DOVIZ_TUTARI/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
                    WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
                    WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' THEN (F.TUTAR/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
                    WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0) END) END)
           -(CASE WHEN FB.TUR IN (15,16) THEN 0.0 ELSE
              (CASE WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD LIKE '600.%' THEN (F.DOVIZ_TUTARI/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
                    WHEN FB.EKSTREDEKULLAN=1 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.DOVIZ_TUTARI,0)
                    WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD LIKE '600.%' THEN (F.TUTAR/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
                    WHEN FB.EKSTREDEKULLAN=0 AND MG.KOD NOT LIKE '600.%' THEN nullif(F.TUTAR,0) END) END))
        END)::numeric,4),0)
    )::numeric,
    MG.ID::int, MG.KOD::varchar(50), MG.AD::varchar(200),
    -- YERELTUTAR
    (CASE WHEN FB.RAPORDOVIZ=YK.d AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN F.DOVIZ_TUTARI
          WHEN FB.RAPORDOVIZ=YK.d AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN coalesce(F.DOVIZ_TUTARI,0)/nullif(1+(F.KDV/100.0),0)
          WHEN FB.RAPORDOVIZ=YK.d AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN (F.DOVIZ_TUTARI/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
          WHEN FB.RAPORDOVIZ=YK.d AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN ((coalesce(F.DOVIZ_TUTARI,0)/nullif(1+(F.KDV/100.0),0))/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN F.TUTAR
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD NOT LIKE '600.%' THEN coalesce(F.TUTAR,0)/nullif(1+(F.KDV/100.0),0)
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.KDVDURUM='Hariç' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN (F.TUTAR/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.KDVDURUM='Dahil' AND FB.TIPI<>4 AND MG.KOD LIKE '600.%' THEN ((coalesce(F.TUTAR,0)/nullif(1+(F.KDV/100.0),0))/nullif(1-(F.ISKONTO/100.0),0))/nullif(1-(F.ISKONTO2/100.0),0)
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.KDVDURUM='Hariç' AND FB.TIPI=4 THEN F.TUTAR+(-1*coalesce(FB.EKVERGI,0))
          WHEN FB.RAPORDOVIZ<>YK.d AND FB.KDVDURUM='Dahil' AND FB.TIPI=4 THEN (coalesce(F.TUTAR,0)/nullif(1+(F.KDV/100.0),0))+(-1*coalesce(FB.EKVERGI,0)) END)::numeric,
    F.SUBEID::int, (FB.FATURATARIH + (coalesce(FB.VADE,0)*interval '1 day'))::timestamp, F.ADET::double precision, ''::varchar(30), F.BIRIMFIYAT::numeric
  FROM FATURA F
    INNER JOIN MASRAFGELIR MG ON F.TUR=0 AND F.URUNID=MG.ID
    INNER JOIN FATBASLIK FB ON FB.ID=F.FATBASID AND coalesce(FB.DURUM,0)<>6
    LEFT JOIN REHBER R ON R.ID=FB.REHBERID
    LEFT JOIN GENINI KasaTurleri ON FB.TUR=KasaTurleri.DEGER AND KasaTurleri.BOLUM=-1005 AND KasaTurleri.DIL=-1
    CROSS JOIN yk YK
  WHERE F.TUR=0 AND F.URUNID=p_masrafid
    AND extract(year from FB.FATURATARIH)>=extract(year from p_bastar) AND extract(year from FB.FATURATARIH)<=extract(year from p_bittar)
    AND FB.FATURATARIH<=p_bittar AND FB.TUR IN (11,12,15,16)

  UNION ALL
  -- ==================== CEK (CEKHAREKET) ====================
  SELECT
    C.ID::int, CH.TARIH, C.VADE, C.MAKBUZNO::varchar(20), (CASE WHEN CH.ISLEM IN (130,141) THEN 23 ELSE 33 END)::smallint, ''::varchar(250),
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-1005 AND DEGER=(CASE WHEN CH.ISLEM IN (130,141) THEN 23 ELSE 33 END) AND DIL=-1 LIMIT 1)::varchar(50),
    CH.REHBERID::int, R.KOD::varchar(20), R.FIRMA::varchar(100),
    ('Serino:'||C.SERINO::varchar||' '||rtrim(coalesce(CH.ACIKLAMA,'')))::varchar(500),
    CH.BANKAHESAPLARID::int, BH.HESAPKODU::varchar(100), BH.HESAPADI::varchar(250), C.DURUM::smallint,
    (CASE WHEN CH.ISLEM IN (140,131,132,133,134,137) THEN CH.TUTAR ELSE 0.0 END)::numeric,
    (CASE WHEN CH.ISLEM IN (130,141) THEN CH.TUTAR ELSE 0.0 END)::numeric,
    CH.KUR::varchar(6),
    (CH.DOVIZ_TUTARI/nullif(CH.TUTAR,0))::numeric,
    C.MASRAFID::int, M.KOD::varchar(50), M.AD::varchar(200),
    (CASE WHEN CH.ISLEM IN (140,131,132,133,134,137) THEN CH.DOVIZ_TUTARI ELSE -1*CH.DOVIZ_TUTARI END)::numeric,
    C.SUBEID::int, C.VADE, 1.0::double precision, ''::varchar(30), 0.0::numeric
  FROM CEKLER C INNER JOIN CEKHAREKET CH ON C.ID=CH.CEKSENETLERID
    LEFT JOIN REHBER R ON CH.REHBERID=R.ID
    LEFT JOIN BANKAHESAPLAR BH ON CH.BANKAHESAPLARID=BH.ID
    LEFT JOIN MASRAFGELIR M ON M.ID=C.MASRAFID
    CROSS JOIN yk YK
  WHERE CH.ISLEM IN (130,131,132,134,137,140,141) AND C.MASRAFID=p_masrafid
    AND extract(year from CH.TARIH)>=extract(year from p_bastar) AND extract(year from CH.TARIH)<=extract(year from p_bittar)
    AND CH.TARIH<=p_bittar

  UNION ALL
  -- ==================== SENET ====================
  SELECT
    C.ID::int, C.TARIH, C.VADE, C.MAKBUZNO::varchar(20), C.TUR::smallint, ''::varchar(250),
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-1005 AND DEGER=C.TUR LIMIT 1)::varchar(50),
    C.REHBERID::int, R.KOD::varchar(20), R.FIRMA::varchar(100), rtrim(R.NOTLAR)::varchar(500), NULL::int, NULL::varchar(100), NULL::varchar(250), C.DURUM::smallint,
    (CASE WHEN C.TUR=34 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0 END)::numeric,
    (CASE WHEN C.TUR=24 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0 END)::numeric,
    (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_KURU ELSE coalesce(C.KUR,'TL') END)::varchar(6),
    ABS((CASE WHEN C.DOVIZ_KURU=YK.d AND C.TUR=34 THEN C.DOVIZ_TUTARI WHEN C.DOVIZ_KURU=YK.d AND C.TUR=24 THEN -1*C.DOVIZ_TUTARI
              WHEN C.DOVIZ_KURU<>YK.d AND C.TUR=34 THEN C.TUTAR WHEN C.DOVIZ_KURU<>YK.d AND C.TUR=24 THEN -1*C.TUTAR END)
        / nullif(((CASE WHEN C.TUR=34 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0 END)
                 -(CASE WHEN C.TUR=24 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0 END)),0))::numeric,
    C.MASRAFID::int, M.KOD::varchar(50), M.AD::varchar(200),
    (CASE WHEN C.DOVIZ_KURU=YK.d AND C.TUR=34 THEN C.DOVIZ_TUTARI WHEN C.DOVIZ_KURU=YK.d AND C.TUR=24 THEN -1*C.DOVIZ_TUTARI
          WHEN C.DOVIZ_KURU<>YK.d AND C.TUR=34 THEN C.TUTAR WHEN C.DOVIZ_KURU<>YK.d AND C.TUR=24 THEN -1*C.TUTAR END)::numeric,
    C.SUBEID::int, C.VADE, 1.0::double precision, ''::varchar(30), 0.0::numeric
  FROM SENETLER C
    INNER JOIN REHBER R ON C.REHBERID=R.ID
    LEFT JOIN MASRAFGELIR M ON M.ID=C.MASRAFID
    CROSS JOIN yk YK
  WHERE C.MASRAFID=p_masrafid
    AND extract(year from C.TARIH)>=extract(year from p_bastar) AND extract(year from C.TARIH)<=extract(year from p_bittar)
    AND C.TARIH<=p_bittar
),
seq AS (
  SELECT h.*,
    greatest(SUM(CASE WHEN tur IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) THEN 0 ELSE borc-alacak END) OVER w, 0)::numeric AS borcbakiye,
    greatest(SUM(CASE WHEN tur IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) THEN 0 ELSE alacak-borc END) OVER w, 0)::numeric AS alacakbakiye,
    (SUM(CASE WHEN tur IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) THEN 0 ELSE yereltutar END) OVER w)::numeric AS yerelbakiye
  FROM har h
  WINDOW w AS (PARTITION BY kur ORDER BY tarih, cekid)
),
outrows AS (
  -- Devir (pre-BasTar aggregate, KUR + SUBEID)
  SELECT 0 AS devirsira, 0::int AS cekid, p_bastar AS tarih, p_bastar AS aksiyontarih, NULL::varchar(20) AS no, 2::smallint AS tur,
    ''::varchar(250) AS baslik, 'Devir'::varchar(50) AS turad, 0::int AS rehberid, ''::varchar(20) AS kod, ''::varchar(100) AS ad,
    'Devir'::varchar(500) AS aciklama, NULL::int AS hesapid, NULL::varchar(100) AS hesapkodu, NULL::varchar(250) AS hesapadi, 1::smallint AS durum,
    SUM(borc)::numeric AS borc, SUM(alacak)::numeric AS alacak, kur, NULL::numeric AS yerelkur, 0::int AS masrafid, ''::varchar(50) AS masrafkod, ''::varchar(200) AS masrafad,
    greatest(SUM(borc-alacak),0)::numeric AS borcbakiye, greatest(SUM(alacak-borc),0)::numeric AS alacakbakiye,
    SUM(yereltutar)::numeric AS yereltutar, greatest(SUM(yereltutar),0)::numeric AS yerelbakiye,
    subeid, p_bastar AS vadetarihi, NULL::double precision AS adet, NULL::varchar(30) AS birim, NULL::numeric AS birimfiyat
  FROM har
  WHERE tarih < p_bastar AND ((tur IN (40,42,49,61,71)) OR (tur NOT BETWEEN 40 AND 79))
  GROUP BY kur, subeid
  UNION ALL
  -- Hareketler (>= BasTar)
  SELECT 1 AS devirsira, cekid, tarih, aksiyontarih, no, tur, baslik, turad, rehberid, kod, ad, aciklama, hesapid, hesapkodu, hesapadi, durum,
    borc, alacak, kur, yerelkur, masrafid, masrafkod, masrafad, borcbakiye, alacakbakiye, yereltutar, yerelbakiye, subeid, vadetarihi, adet, birim, birimfiyat
  FROM seq WHERE tarih >= p_bastar
),
final AS (SELECT *, row_number() OVER (ORDER BY devirsira, kur, tarih, cekid)::int AS sirano FROM outrows)
SELECT sirano, cekid, tarih, aksiyontarih, no, tur, baslik, turad, rehberid, kod, ad, aciklama, hesapid, hesapkodu, hesapadi, durum,
  borc, alacak, kur, yerelkur, masrafid, masrafkod, masrafad, borcbakiye, alacakbakiye, yereltutar, yerelbakiye, subeid, vadetarihi, adet, birim, birimfiyat
FROM final
ORDER BY kur, sirano;
$$;

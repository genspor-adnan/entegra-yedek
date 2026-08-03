-- ============================================================================
-- fn_stokhareket_ortmaliyet2012 (PG portu, TVF-per-engine)
-- MSSQL: fn_StokHareket_OrtMaliyet2012 (@BasTar,@BitTar,@DepoId,@UrunID)
-- Yapi: har(3-parca hareket union, yil-basi..BitTar) -> tmp2(Devir: pre-orijinal SUM(MIKTAR)
--   per URUNID,DEPO + hareketler orijinal..BitTar) -> final(FATBASLIK/STOKLAR INNER join,
--   STOK_ORT_MALIYET left join; KALAN=SUM(MIKTAR) OVER(ORDER BY SIRANO); WHERE OLAY<>'Çıkış').
--   Devir FATBASID=0 -> INNER JOIN FATBASLIK onu duser (MSSQL ile ayni).
-- NOT: birebir port; differential veriyle dogrulanmali.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_stokhareket_ortmaliyet2012(timestamp, timestamp, integer, integer);
CREATE OR REPLACE FUNCTION fn_stokhareket_ortmaliyet2012(p_bastar timestamp, p_bittar timestamp, p_depoid integer, p_urunid integer)
RETURNS TABLE(
  "KOD" varchar(150),"FIRMA" varchar(750),"OLAY" varchar(50),"URUNID" integer,"FATBASID" integer,"FATURAID" integer,
  "TUR" integer,"TURAD" varchar(50),"FATURATARIH" timestamp,"FATURASERI" varchar(50),"FATURANO" varchar(20),
  "REHBERID" integer,"BIRIM" integer,"BIRIMFIYAT" numeric,"TUTAR" numeric,"KUR" varchar(5),"EKMALIYET" numeric,
  "DEPO" integer,"GIREN" double precision,"CIKAN" double precision,"ADET" double precision,"MIKTAR" double precision,
  "KALAN" double precision,"MALIYET" numeric)
LANGUAGE sql AS $$
WITH prm AS (
  SELECT date_trunc('year', p_bastar)::timestamp AS yilbasi,
         p_bastar AS yedekbastar,
         ((p_bastar::date - 1)::timestamp + interval '23:59:59') AS arabastar,
         p_bittar AS bittar),
har AS (
  -- part1: genel hareketler (FB.TUR NOT IN 10,14,20,109)
  SELECT
    (CASE WHEN FB.REHBERID>0 THEN R.KOD ELSE '' END)::varchar(150) AS KOD,
    (CASE WHEN FB.REHBERID>0 AND FB.TUR<>20 THEN R.FIRMA
          WHEN FB.TUR=20 AND coalesce(FB.CIKISDEPO,0)<>0 THEN D2.DEPOADI
          WHEN FB.TUR=7 THEN 'Sayım Fişi' ELSE '' END)::varchar(750) AS FIRMA,
    (CASE WHEN coalesce(FB.TUR,0)=6 THEN 'Üretim'
          WHEN coalesce(FB.GIRISDEPO,0)=0 THEN (CASE WHEN coalesce(FB.TIPI,0)=2 THEN 'Çıkış(iade)' ELSE 'Çıkış' END)
          WHEN coalesce(FB.CIKISDEPO,0)=0 THEN (CASE WHEN coalesce(FB.TIPI,0)=2 THEN 'Giriş(iade)' ELSE 'Giriş' END)
          WHEN F.MIKTAR>0 THEN (CASE WHEN coalesce(FB.TIPI,0)=2 THEN 'Giriş(iade)' ELSE 'Giriş' END)
          WHEN F.MIKTAR<0 THEN (CASE WHEN coalesce(FB.TIPI,0)=2 THEN 'Çıkış(iade)' ELSE 'Çıkış' END) END)::varchar(50) AS OLAY,
    F.URUNID, FB.ID AS FATBASID, F.ID AS FATURAID, FB.TUR, IT.AD::varchar(50) AS TURAD,
    FB.FATURATARIH, FB.FATURASERI::varchar(50) AS FATURASERI, FB.FATURANO::varchar(20) AS FATURANO, FB.REHBERID,
    F.BIRIM, F.BIRIMFIYAT::numeric AS BIRIMFIYAT, F.TUTAR::numeric AS TUTAR, F.KUR::varchar(5) AS KUR, F.EKMALIYET::numeric AS EKMALIYET,
    (CASE WHEN coalesce(FB.GIRISDEPO,0)=0 THEN FB.CIKISDEPO WHEN coalesce(FB.CIKISDEPO,0)=0 THEN FB.GIRISDEPO
          WHEN F.MIKTAR>0 THEN FB.GIRISDEPO WHEN F.MIKTAR<0 THEN FB.CIKISDEPO END) AS DEPO,
    (CASE WHEN coalesce(FB.GIRISDEPO,0)=0 THEN 0.0 WHEN coalesce(FB.CIKISDEPO,0)=0 THEN F.MIKTAR
          WHEN F.MIKTAR>0 THEN F.MIKTAR WHEN F.MIKTAR<0 THEN 0.0 END)::double precision AS GIREN,
    (CASE WHEN coalesce(FB.GIRISDEPO,0)=0 THEN F.MIKTAR WHEN coalesce(FB.CIKISDEPO,0)=0 THEN 0.0
          WHEN F.MIKTAR>0 THEN 0.0 WHEN F.MIKTAR<0 THEN -F.MIKTAR END)::double precision AS CIKAN,
    F.ADET::double precision AS ADET,
    (CASE WHEN coalesce(FB.GIRISDEPO,0)=0 THEN -F.MIKTAR WHEN coalesce(FB.CIKISDEPO,0)=0 THEN F.MIKTAR
          WHEN F.MIKTAR>0 THEN F.MIKTAR WHEN F.MIKTAR<0 THEN F.MIKTAR END)::double precision AS MIKTAR
  FROM FATBASLIK FB
    INNER JOIN FATURA F ON F.FATBASID=FB.ID
    LEFT JOIN REHBER R ON FB.REHBERID=R.ID
    LEFT JOIN depolar D1 ON FB.GIRISDEPO=D1.ID
    LEFT JOIN depolar D2 ON FB.CIKISDEPO=D2.ID
    INNER JOIN ISLEMTURLERI IT ON IT.TUR=FB.TUR AND IT.TIP IN (0,1)
  WHERE FB.FATURATARIH BETWEEN (SELECT yilbasi FROM prm) AND (SELECT bittar FROM prm)
    AND F.URUNID=p_urunid AND coalesce(FB.DURUM,1)<>6 AND F.TUR=1 AND FB.TUR NOT IN (10,14,20,109)
    AND (p_depoid=0 OR p_depoid=(CASE WHEN coalesce(FB.GIRISDEPO,0)=0 THEN FB.CIKISDEPO WHEN coalesce(FB.CIKISDEPO,0)=0 THEN FB.GIRISDEPO
                                      WHEN F.MIKTAR>0 THEN FB.GIRISDEPO WHEN F.MIKTAR<0 THEN FB.CIKISDEPO END))

  UNION ALL
  -- part2: TUR 20 cikis / 109+TIPI=2 (cikis)
  SELECT
    (CASE WHEN FB.REHBERID>0 THEN R.KOD ELSE '' END)::varchar(150),
    (CASE WHEN FB.TUR IN (20) THEN D2.DEPOADI WHEN FB.TUR IN (109,119) THEN R.FIRMA ELSE '' END)::varchar(750),
    (CASE WHEN coalesce(FB.TIPI,0)=2 THEN 'Çıkış(iade)' ELSE 'Çıkış' END)::varchar(50),
    F.URUNID, FB.ID, F.ID, FB.TUR,
    (CASE WHEN FB.TUR=109 AND FB.TIPI=2 THEN 'İade Konsinye' ELSE IT.AD END)::varchar(50),
    FB.FATURATARIH, FB.FATURASERI::varchar(50), FB.FATURANO::varchar(20), FB.REHBERID,
    F.BIRIM, F.BIRIMFIYAT::numeric, F.TUTAR::numeric, F.KUR::varchar(5), F.EKMALIYET::numeric,
    FB.CIKISDEPO, 0::double precision, F.MIKTAR::double precision, F.ADET::double precision, (-F.MIKTAR)::double precision
  FROM FATBASLIK FB
    INNER JOIN FATURA F ON F.FATBASID=FB.ID
    LEFT JOIN REHBER R ON FB.REHBERID=R.ID
    LEFT JOIN depolar D1 ON FB.GIRISDEPO=D1.ID
    LEFT JOIN depolar D2 ON FB.CIKISDEPO=D2.ID
    INNER JOIN ISLEMTURLERI IT ON IT.TUR=FB.TUR AND IT.TIP IN (0,1)
  WHERE FB.FATURATARIH BETWEEN (SELECT yilbasi FROM prm) AND (SELECT bittar FROM prm)
    AND F.URUNID=p_urunid AND coalesce(FB.DURUM,1)<>6 AND F.TUR=1
    AND (FB.TUR IN (20) OR (FB.TUR IN (109) AND FB.TIPI=2))
    AND (p_depoid=0 OR p_depoid=FB.CIKISDEPO)

  UNION ALL
  -- part3: TUR 20 giris
  SELECT
    (CASE WHEN FB.REHBERID>0 THEN R.KOD ELSE '' END)::varchar(150),
    (CASE WHEN FB.TUR IN (20) THEN D1.DEPOADI WHEN FB.TUR IN (109,119) THEN R.FIRMA ELSE '' END)::varchar(750),
    (CASE WHEN coalesce(FB.TIPI,0)=2 THEN 'Giriş(iade)' ELSE 'Giriş' END)::varchar(50),
    F.URUNID, FB.ID, F.ID, FB.TUR, IT.AD::varchar(50),
    FB.FATURATARIH, FB.FATURASERI::varchar(50), FB.FATURANO::varchar(20), FB.REHBERID,
    F.BIRIM, F.BIRIMFIYAT::numeric, F.TUTAR::numeric, F.KUR::varchar(5), F.EKMALIYET::numeric,
    FB.GIRISDEPO, F.MIKTAR::double precision, 0::double precision, F.ADET::double precision, F.MIKTAR::double precision
  FROM FATBASLIK FB
    INNER JOIN FATURA F ON F.FATBASID=FB.ID
    LEFT JOIN REHBER R ON FB.REHBERID=R.ID
    LEFT JOIN depolar D1 ON FB.GIRISDEPO=D1.ID
    LEFT JOIN depolar D2 ON FB.CIKISDEPO=D2.ID
    INNER JOIN ISLEMTURLERI IT ON IT.TUR=FB.TUR AND IT.TIP IN (0,1)
  WHERE FB.FATURATARIH BETWEEN (SELECT yilbasi FROM prm) AND (SELECT bittar FROM prm)
    AND F.URUNID=p_urunid AND coalesce(FB.DURUM,1)<>6 AND F.TUR=1 AND FB.TUR IN (20)
    AND (p_depoid=0 OR p_depoid=FB.GIRISDEPO)
),
tmp2 AS (
  -- Devir (pre-orijinal, per URUNID,DEPO) + hareketler (orijinal..BitTar)
  SELECT row_number() OVER (ORDER BY (CASE WHEN q.FATBASID=0 THEN 0 ELSE 1 END), q.DEPO, q.FATURATARIH)::int AS SIRANO, q.*
  FROM (
    SELECT ''::varchar(150) AS KOD, ''::varchar(750) AS FIRMA, 'Devreden'::varchar(50) AS OLAY, URUNID,
      0 AS FATBASID, 0 AS FATURAID, 0 AS TUR, 'Devir'::varchar(50) AS TURAD, (SELECT yedekbastar FROM prm) AS FATURATARIH,
      ''::varchar(50) AS FATURASERI, NULL::varchar(20) AS FATURANO, NULL::int AS REHBERID, NULL::int AS BIRIM,
      NULL::numeric AS BIRIMFIYAT, NULL::numeric AS TUTAR, NULL::varchar(5) AS KUR, 0::numeric AS EKMALIYET, DEPO,
      NULL::double precision AS GIREN, NULL::double precision AS CIKAN, NULL::double precision AS ADET, SUM(MIKTAR)::double precision AS MIKTAR
    FROM har WHERE FATURATARIH BETWEEN (SELECT yilbasi FROM prm) AND (SELECT arabastar FROM prm)
    GROUP BY URUNID, DEPO
    UNION ALL
    SELECT KOD, FIRMA, OLAY, URUNID, FATBASID, FATURAID, TUR, TURAD, FATURATARIH, FATURASERI, FATURANO, REHBERID, BIRIM,
      BIRIMFIYAT, TUTAR, KUR, EKMALIYET, DEPO, GIREN, CIKAN, ADET, MIKTAR
    FROM har WHERE FATURATARIH BETWEEN (SELECT yedekbastar FROM prm) AND (SELECT bittar FROM prm)
  ) q
),
joined AS (
  SELECT T.*, FB.TUR AS FB_TUR, FB.CIKISDEPO AS FB_CIKISDEPO, FB.FATURATARIH AS FB_FATURATARIH,
         S.ID AS S_ID, SM.BIRIMMALIYET AS SM_BIRIMMALIYET
  FROM tmp2 T
    INNER JOIN FATBASLIK FB ON FB.ID=T.FATBASID
    INNER JOIN STOKLAR S ON S.ID=T.URUNID
    LEFT JOIN STOK_ORT_MALIYET SM ON T.DEPO=SM.DEPOID AND T.FATBASID=SM.FATBASID AND T.FATURAID=SM.FATURAID
  WHERE T.OLAY<>'Çıkış'
)
SELECT KOD, FIRMA, OLAY, URUNID, FATBASID, FATURAID, TUR, TURAD, FATURATARIH, FATURASERI, FATURANO, REHBERID, BIRIM,
  (CASE WHEN FB_TUR IN (20,119)
        THEN (SELECT SO.BIRIMMALIYET FROM STOK_ORT_MALIYET SO WHERE SO.STOKID=S_ID AND SO.DEPOID=FB_CIKISDEPO AND SO.TARIH<=FB_FATURATARIH ORDER BY SO.TARIH DESC LIMIT 1)
        ELSE BIRIMFIYAT END)::numeric AS BIRIMFIYAT,
  (CASE WHEN FB_TUR=6 THEN ADET*BIRIMFIYAT
        WHEN FB_TUR IN (20,119) THEN (SELECT SO.BIRIMMALIYET FROM STOK_ORT_MALIYET SO WHERE SO.STOKID=S_ID AND SO.DEPOID=FB_CIKISDEPO AND SO.TARIH<=FB_FATURATARIH ORDER BY SO.TARIH DESC LIMIT 1)*ADET
        ELSE TUTAR END)::numeric AS TUTAR,
  KUR, EKMALIYET, DEPO, GIREN, CIKAN, ADET, MIKTAR,
  (SUM(MIKTAR) OVER (ORDER BY SIRANO))::double precision AS KALAN,
  SM_BIRIMMALIYET::numeric AS MALIYET
FROM joined
ORDER BY SIRANO;
$$;

-- ============================================================================
-- fn_prg_islistesitumliste (7-param TVF portu) — MSSQL: fn_prg_IsListesiTumListe
--   (@Kullanici,@AcKapa,@BaslaGun,@TamYetki,@Gorev,@Departman,@Sube)
-- UGorevListeDlg TumListe: takvim+gorev kolonlu is-listesi, yetki-filtreli, tekrar-dedup.
-- (Ayri 3-param sp-portu da var; bu 7-param overload app'in gercek cagrisi.)
-- fn_GorevVerilenKisiler(11/12,id) -> inline string_agg. NOT: birebir; differential dogrula.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prg_islistesitumliste(integer,integer,integer,integer,integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesitumliste(p_kullanici integer, p_ackapa integer, p_baslagun integer,
  p_tamyetki integer, p_gorev integer, p_departman integer, p_sube integer)
RETURNS TABLE(
  "type" smallint,"start" timestamp,"finish" timestamp,"options" smallint,"caption" varchar(1000),
  "location" varchar(10),"message" varchar(10),"state" smallint,"labelColor" bigint,"DOSYA" varchar(20),
  "GOREV_ID" integer,"ID" integer,"LISTEID" integer,"LISTEADI" varchar(150),"KONUSU" varchar(150),"DURUM" smallint,
  "TURU" varchar(50),"REHBERID" integer,"CARIAD" varchar(350),"MUS_ILGILI" varchar(70),"ATANAN1" varchar(350),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRARID" integer,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"NOTLAR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,
  "BAYRAK" smallint,"ACKAPA" smallint,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(150),"EKLEYENAD" varchar(150))
LANGUAGE sql AS $$
WITH raw AS (
  -- GOREVLER
  SELECT 0::smallint AS "type", date_trunc('second',G.BASLAMATARIHI)::timestamp AS "start",
    date_trunc('second',G.BITISTARIHI)::timestamp AS "finish", 3::smallint AS "options",
    (G.KONUSU||' / '||coalesce((SELECT KOD FROM KULLANICI K WHERE K.REHBERID=G.EKLEYEN LIMIT 1),'')||' > '||
     coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK2.ID) FROM GOREVKULLANICI GK2 INNER JOIN KULLANICI KL ON GK2.REHBERID=KL.REHBERID WHERE GK2.LISTGOREVID=G.ID),'')||' / '||
     coalesce(array_to_string((string_to_array(R.FIRMA,' '))[1:2],' '),''))::varchar(1000) AS "caption",
    ''::varchar(10) AS "location", ''::varchar(10) AS "message", 0::smallint AS "state",
    (CASE WHEN G.ACKAPA=1 THEN 13882323 ELSE 55295 END)::bigint AS "labelColor", 'GOREVLER'::varchar(20) AS "DOSYA",
    G.ID::int AS "GOREV_ID", G.ID::int AS "ID",
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE G.LISTEID END)::int AS "LISTEID",
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE (SELECT GL2.ADI FROM GOREVLISTE GL2 WHERE GL2.ID=G.LISTEID LIMIT 1) END)::varchar(150) AS "LISTEADI",
    G.KONUSU::varchar(150) AS "KONUSU", G.DURUM::smallint AS "DURUM",
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-21044 AND DIL=-1 AND DEGER=G.TURU LIMIT 1)::varchar(50) AS "TURU",
    G.REHBERID::int AS "REHBERID", (SELECT FIRMA FROM REHBER R2 WHERE R2.ID=G.REHBERID LIMIT 1)::varchar(350) AS "CARIAD",
    (SELECT FIRMA FROM REHBER R2 WHERE R2.ID=G.MUS_ILGILI LIMIT 1)::varchar(70) AS "MUS_ILGILI",
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK2.ID) FROM GOREVKULLANICI GK2 INNER JOIN KULLANICI KL ON GK2.REHBERID=KL.REHBERID WHERE GK2.LISTGOREVID=G.ID),'')::varchar(350) AS "ATANAN1",
    G.BASLAMATARIHI::timestamp AS "BASLAMATARIHI", G.BITISTARIHI::timestamp AS "BITISTARIHI", G.TEKRARID::int AS "TEKRARID",
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint AS "TEKRAR_BIT",
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint AS "ANIMSAT_BIT",
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint AS "ZINCIR_BIT",
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=1) THEN 1 ELSE 0 END)::smallint AS "NOTLAR_BIT",
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=33) THEN 1 ELSE 0 END)::smallint AS "YORUM_BIT",
    G.BAGIDUST::int AS "BAGIDUST", G.BAGIDALT::int AS "BAGIDALT", G.BAYRAK::smallint AS "BAYRAK", G.ACKAPA::smallint AS "ACKAPA",
    G.EKLEYEN::int AS "EKLEYEN", G.EKLEMETARIHI::timestamp AS "EKLEMETARIHI",
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(150) AS "PROJEKODU",
    (SELECT FIRMA FROM REHBER R2 WHERE R2.ID=G.EKLEYEN LIMIT 1)::varchar(150) AS "EKLEYENAD"
  FROM GOREVLER G
    LEFT JOIN GOREVLISTE GL ON GL.ID=G.LISTEID AND GL.DURUM=1
    LEFT JOIN GOREVKULLANICI GK ON G.ID=GK.LISTGOREVID AND GK.TUR<=5
    LEFT JOIN REHBER R ON R.ID=G.REHBERID
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR p_ackapa=G.ACKAPA)
    AND ((p_tamyetki=1) OR (G.EKLEYEN=p_kullanici) OR (GL.HERKESEACIK=1) OR (GL.EKLEYEN=p_kullanici) OR
         (1=(CASE WHEN GK.TUR=1 AND GK.REHBERID=p_kullanici THEN 1
                  WHEN GK.TUR=2 AND GK.REHBERID=p_gorev THEN 1
                  WHEN GK.TUR=3 AND GK.REHBERID=p_departman THEN 1
                  WHEN GK.TUR=4 AND GK.REHBERID=p_sube THEN 1 END)))

  UNION ALL
  -- SERVIS
  SELECT 0::smallint, date_trunc('second',G.BASLAMATARIHI)::timestamp, date_trunc('second',G.BITISTARIHI)::timestamp, 3::smallint,
    (G.KONUSU||' / '||coalesce((SELECT KOD FROM KULLANICI K WHERE K.REHBERID=G.EKLEYEN LIMIT 1),'')||' > '||
     coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK2.ID) FROM GOREVKULLANICI GK2 INNER JOIN KULLANICI KL ON GK2.REHBERID=KL.REHBERID WHERE GK2.LISTGOREVID=G.ID),'')||' / '||
     coalesce(array_to_string((string_to_array(R.FIRMA,' '))[1:2],' '),''))::varchar(1000),
    ''::varchar(10), ''::varchar(10), 0::smallint,
    (CASE WHEN G.ACKAPA=1 THEN 13882323 ELSE 55295 END)::bigint, 'GOREVLER'::varchar(20),
    G.ID::int, G.ID::int, GL.ID::int, GL.ADI::varchar(150), G.KONUSU::varchar(150), G.DURUM::smallint,
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-3006 AND DIL=-1 AND DEGER=G.TURU LIMIT 1)::varchar(50),
    G.REHBERID::int, (SELECT FIRMA FROM REHBER R2 WHERE R2.ID=G.REHBERID LIMIT 1)::varchar(350),
    (SELECT FIRMA FROM REHBER R2 WHERE R2.ID=G.MUS_ILGILI LIMIT 1)::varchar(70),
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK2.ID) FROM GOREVKULLANICI GK2 INNER JOIN KULLANICI KL ON GK2.REHBERID=KL.REHBERID WHERE GK2.LISTGOREVID=G.ID),'')::varchar(350),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp, 0::int, 0::smallint, 0::smallint, 0::smallint,
    (CASE WHEN coalesce(G.NOTLAR,'')<>'' THEN 1 ELSE 0 END)::smallint, 0::smallint, 0::int, 0::int,
    G.ACIL::smallint, G.ACKAPA::smallint, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp, NULL::varchar(150),
    (SELECT FIRMA FROM REHBER R2 WHERE R2.ID=G.EKLEYEN LIMIT 1)::varchar(150)
  FROM SERVIS G
    INNER JOIN GOREVLISTE GL ON GL.ID=-6 AND G.KABUL_EDEN=p_kullanici
    LEFT JOIN REHBER R ON R.ID=G.REHBERID
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR p_ackapa=G.ACKAPA)
),
ids AS (
  SELECT DISTINCT (CASE WHEN coalesce("TEKRARID",0)=0 THEN "ID" ELSE MIN("ID") OVER (PARTITION BY "TEKRARID") END) AS "ID"
  FROM raw
)
SELECT A."type",A."start",A."finish",A."options",A."caption",A."location",A."message",A."state",A."labelColor",A."DOSYA",
  A."GOREV_ID",A."ID",A."LISTEID",A."LISTEADI",A."KONUSU",A."DURUM",A."TURU",A."REHBERID",A."CARIAD",A."MUS_ILGILI",A."ATANAN1",
  A."BASLAMATARIHI",A."BITISTARIHI",A."TEKRARID",A."TEKRAR_BIT",A."ANIMSAT_BIT",A."ZINCIR_BIT",A."NOTLAR_BIT",A."YORUM_BIT",
  A."BAGIDUST",A."BAGIDALT",A."BAYRAK",A."ACKAPA",A."EKLEYEN",A."EKLEMETARIHI",A."PROJEKODU",A."EKLEYENAD"
FROM raw A INNER JOIN ids B ON A."ID"=B."ID"
ORDER BY A."LISTEID", A."ACKAPA", A."ID" DESC;
$$;

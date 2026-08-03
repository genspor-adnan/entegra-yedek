-- ============================================================================
-- fn_prg_islistesibanaatananlar  (PG portu, TVF-per-engine)
-- MSSQL: dbo.sp_Prg_IsListesiBanaAtananlar (@Kullanici,@AcKapa,@BaslaGun)
-- Bana atanan gorev+servis is-listesi (GOREVKULLANICI TUR=11/12, REHBERID=kullanici).
-- fn_GorevVerilenKisiler(@LISTID,@GOREVID): @LISTID kullanilmiyor -> inline string_agg.
-- NOT: bu SP'de NOTLAR_BIT YOK, TURU ham int, YORUM_BIT=GOREVYORUM TUR=2, LISTEID PROJE fallback.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prg_islistesibanaatananlar(integer, integer, integer);

CREATE OR REPLACE FUNCTION fn_prg_islistesibanaatananlar(p_kullanici integer, p_ackapa integer, p_baslagun integer)
RETURNS TABLE(
  "ID"            integer,
  "LISTEID"       integer,
  "LISTEADI"      varchar(255),
  "KONUSU"        varchar(1000),
  "DURUM"         smallint,
  "TURU"          integer,
  "REHBERID"      integer,
  "CARIAD"        varchar(255),
  "MUS_ILGILI"    integer,
  "ATANAN1"       varchar(1000),
  "BASLAMATARIHI" timestamp,
  "BITISTARIHI"   timestamp,
  "TEKRAR_BIT"    smallint,
  "ANIMSAT_BIT"   smallint,
  "ZINCIR_BIT"    smallint,
  "YORUM_BIT"     smallint,
  "BAGIDUST"      integer,
  "BAGIDALT"      integer,
  "BAYRAK"        integer,
  "ACKAPA"        integer,
  "EKLEYEN"       integer,
  "EKLEMETARIHI"  timestamp,
  "PROJEKODU"     varchar(255),
  "EKLEYENAD"     varchar(255)
)
LANGUAGE sql
AS $func$
  -- ---- GOREVLER (bana atanan, TUR=11) --------------------------------------
  SELECT
    G.ID::integer,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE G.LISTEID END)::integer AS LISTEID,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID)
          ELSE (SELECT GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LISTEID LIMIT 1) END)::varchar(255) AS LISTEADI,
    G.KONUSU::varchar(1000),
    G.DURUM::smallint,
    G.TURU::integer,
    G.REHBERID::integer,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255) AS CARIAD,
    G.MUS_ILGILI::integer,
    coalesce((SELECT string_agg(KL.KOD, ' - ' ORDER BY GK.ID)
              FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID
              WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000) AS ATANAN1,
    G.BASLAMATARIHI::timestamp,
    G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint AS TEKRAR_BIT,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint AS ANIMSAT_BIT,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint AS ZINCIR_BIT,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint AS YORUM_BIT,
    G.BAGIDUST::integer,
    G.BAGIDALT::integer,
    G.BAYRAK::integer,
    G.ACKAPA::integer,
    G.EKLEYEN::integer,
    G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255) AS PROJEKODU,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255) AS EKLEYENAD
  FROM GOREVLER G
    INNER JOIN GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREVID AND GK1.TUR=11 AND GK1.REHBERID=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI, now()) >
          (CASE WHEN G.ACKAPA=1 THEN now() - (p_baslagun * interval '1 day')
                ELSE now() - (9999 * interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)

  UNION ALL

  -- ---- SERVIS (bana atanan, TUR=12, GOREVLISTE ID=-6) ----------------------
  SELECT
    G.ID::integer,
    GL.ID::integer AS LISTEID,
    GL.ADI::varchar(255) AS LISTEADI,
    G.KONUSU::varchar(1000),
    G.DURUM::smallint,
    NULL::integer AS TURU,
    G.REHBERID::integer,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255) AS CARIAD,
    G.MUS_ILGILI::integer,
    coalesce((SELECT string_agg(KL.KOD, ' - ' ORDER BY GK.ID)
              FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID
              WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000) AS ATANAN1,
    G.BASLAMATARIHI::timestamp,
    G.BITISTARIHI::timestamp,
    0::smallint AS TEKRAR_BIT,
    0::smallint AS ANIMSAT_BIT,
    0::smallint AS ZINCIR_BIT,
    0::smallint AS YORUM_BIT,
    0::integer AS BAGIDUST,
    0::integer AS BAGIDALT,
    G.ACIL::integer AS BAYRAK,
    G.ACKAPA::integer,
    G.EKLEYEN::integer,
    G.EKLEMETARIHI::timestamp,
    NULL::varchar(255) AS PROJEKODU,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255) AS EKLEYENAD
  FROM SERVIS G
    INNER JOIN GOREVLISTE GL ON GL.ID=-6
    INNER JOIN GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREVID AND GK1.TUR=12 AND GK1.REHBERID=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI, now()) >
          (CASE WHEN G.ACKAPA=1 THEN now() - (p_baslagun * interval '1 day')
                ELSE now() - (9999 * interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)

  ORDER BY 2, 20, 1 DESC;   -- LISTEID, ACKAPA, ID desc
$func$;

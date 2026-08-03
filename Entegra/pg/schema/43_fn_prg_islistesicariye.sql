-- ============================================================================
-- fn_prg_islistesicariye  (PG portu, TVF-per-engine)
-- MSSQL orijinali: dbo.sp_Prg_IsListesiCariye (@RehberId,@AcKapa,@BaslaGun)
-- Cari kartinin gorev+servis is-listesi. Cagri: UReharadlg TabGorevler
--   EXEC sp -> PgSqlCevir -> select * from fn_prg_islistesicariye(:RehberId,:AcKapa,:GunSay)
-- Bolum 1: GOREVLER (cariye ait), Bolum 2: SERVIS (GOREVLISTE ID=-6)
-- fn_GorevVerilenKisiler(@LISTID,@GOREVID): @LISTID kullanilmiyor -> inline string_agg
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prg_islistesicariye(integer, integer, integer);

CREATE OR REPLACE FUNCTION fn_prg_islistesicariye(p_rehberid integer, p_ackapa integer, p_baslagun integer)
RETURNS TABLE(
  "ID"            integer,
  "LISTEID"       integer,
  "LISTEADI"      varchar(255),
  "KONUSU"        varchar(1000),
  "DURUM"         smallint,
  "TURU"          varchar(255),
  "REHBERID"      integer,
  "CARIAD"        varchar(255),
  "MUS_ILGILI"    integer,
  "ATANAN1"       varchar(1000),
  "BASLAMATARIHI" timestamp,
  "BITISTARIHI"   timestamp,
  "TEKRAR_BIT"    smallint,
  "ANIMSAT_BIT"   smallint,
  "ZINCIR_BIT"    smallint,
  "NOTLAR_BIT"    smallint,
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
  -- ---- Bolum 1: GOREVLER ----------------------------------------------------
  SELECT
    G.ID::integer,
    G.LISTEID::integer,
    (SELECT GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LISTEID LIMIT 1)::varchar(255) AS LISTEADI,
    G.KONUSU::varchar(1000),
    G.DURUM::smallint,
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-21044 AND DIL=-1 AND DEGER=G.TURU LIMIT 1)::varchar(255) AS TURU,
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
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=1) THEN 1 ELSE 0 END)::smallint AS NOTLAR_BIT,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=33) THEN 1 ELSE 0 END)::smallint AS YORUM_BIT,
    G.BAGIDUST::integer,
    G.BAGIDALT::integer,
    G.BAYRAK::integer,
    G.ACKAPA::integer,
    G.EKLEYEN::integer,
    G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255) AS PROJEKODU,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255) AS EKLEYENAD
  FROM GOREVLER G
  WHERE coalesce(G.BASLAMATARIHI, now()) >
          (CASE WHEN G.ACKAPA=1 THEN now() - (p_baslagun * interval '1 day')
                ELSE now() - (9999 * interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND G.REHBERID=p_rehberid

  UNION ALL

  -- ---- Bolum 2: SERVIS (GOREVLISTE ID=-6) ----------------------------------
  SELECT
    G.ID::integer,
    GL.ID::integer AS LISTEID,
    GL.ADI::varchar(255) AS LISTEADI,
    G.KONUSU::varchar(1000),
    G.DURUM::smallint,
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-3006 AND DIL=-1 AND DEGER=G.TURU LIMIT 1)::varchar(255) AS TURU,
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
    (CASE WHEN coalesce(G.NOTLAR,'')<>'' THEN 1 ELSE 0 END)::smallint AS NOTLAR_BIT,
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
       INNER JOIN GOREVLISTE GL ON GL.ID=-6 AND G.REHBERID=p_rehberid
  WHERE coalesce(G.BASLAMATARIHI, now()) >
          (CASE WHEN G.ACKAPA=1 THEN now() - (p_baslagun * interval '1 day')
                ELSE now() - (9999 * interval '1 day') END)
    AND p_ackapa IN (0,1)

  ORDER BY 2, 21, 1 DESC;   -- LISTEID, ACKAPA, ID desc  (MSSQL: order by 2,G.ACKAPA,1 desc)
$func$;

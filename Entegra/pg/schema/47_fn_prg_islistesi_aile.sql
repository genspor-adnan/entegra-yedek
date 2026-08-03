-- ============================================================================
-- IsListesi görev-liste ailesi (PG portu, TVF-per-engine)
-- MSSQL: sp_Prg_IsListesi{MasaUstu,Atadiklarim,Atanmamislar,Bayrakli,BuHafta,
--        TumListe,Onayla,_Demirbas,_Listeler,_Projeler,_Ziyaret}
-- Ortak: GOREVLER(+SERVIS) is-listesi. ATANAN1 = fn_GorevVerilenKisiler inline
--        (1.param kullanilmaz -> string_agg). bit->::smallint. Getdate()-N -> now()-N gun.
-- NOT: birebir port; differential veriyle dogrulanmali. (Hatirlatma ayri: helper fn gerektirir.)
-- ============================================================================

-- ==== ortak filtre notlari =================================================
--  ackapa(std): (p_ackapa=1 OR (case G.ACKAPA 0->0,1->1 end)=p_ackapa)
--  ackapa(servis): p_ackapa IN (0,1)
--  tarih: coalesce(G.BASLAMATARIHI,now()) > (G.ACKAPA=1 ? now()-baslagun : now()-9999) gun

-- ------------------------------------------------------------ MASAUSTU (tek parca, STD)
DROP FUNCTION IF EXISTS fn_prg_islistesimasaustu(integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesimasaustu(p_kullanici integer, p_ackapa integer, p_baslagun integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int, G.LISTEID::int,
    (SELECT GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LISTEID LIMIT 1)::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint, G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G
  WHERE G.LISTEID=-27 AND G.EKLEYEN=p_kullanici
    AND G.EKLEMETARIHI > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
  ORDER BY 2, 20, 1 DESC;
$$;

-- ------------------------------------------------------------ ATADIKLARIM (2 parca, STD)
DROP FUNCTION IF EXISTS fn_prg_islistesiatadiklarim(integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesiatadiklarim(p_kullanici integer, p_ackapa integer, p_baslagun integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE G.LISTEID END)::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE (SELECT GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LISTEID LIMIT 1) END)::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint, G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND G.EKLEYEN=p_kullanici
    AND EXISTS (SELECT 1 FROM GOREVKULLANICI GK WHERE G.ID=GK.LISTGOREVID AND GK.EKLEYEN=G.EKLEYEN)
  UNION ALL
  SELECT G.ID::int, GL.ID::int, GL.ADI::varchar(255), G.KONUSU::varchar(1000), G.DURUM::smallint, NULL::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp, 0::smallint,0::smallint,0::smallint,0::smallint,
    0::int,0::int, G.ACIL::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp, NULL::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM SERVIS G INNER JOIN GOREVLISTE GL ON GL.ID=-6 AND G.KABUL_EDEN=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
  ORDER BY 2, 20, 1 DESC;
$$;

-- ------------------------------------------------------------ ATANMAMISLAR (2 parca, STD)
DROP FUNCTION IF EXISTS fn_prg_islistesiatanmamislar(integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesiatanmamislar(p_kullanici integer, p_ackapa integer, p_baslagun integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE G.LISTEID END)::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE (SELECT GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LISTEID LIMIT 1) END)::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint, G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G
    LEFT JOIN GOREVKULLANICI GK2 ON G.ID=GK2.LISTGOREVID AND GK2.TUR<=2 AND GK2.REHBERID=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND NOT EXISTS (SELECT 1 FROM GOREVKULLANICI GK WHERE GK.TUR=11 AND G.ID=GK.LISTGOREVID)
    AND ((G.EKLEYEN=p_kullanici) OR (GK2.TUR<=2 AND GK2.REHBERID=p_kullanici))
  UNION ALL
  SELECT G.ID::int, GL.ID::int, GL.ADI::varchar(255), G.KONUSU::varchar(1000), G.DURUM::smallint, NULL::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp, 0::smallint,0::smallint,0::smallint,0::smallint,
    0::int,0::int, G.ACIL::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp, NULL::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM SERVIS G INNER JOIN GOREVLISTE GL ON GL.ID=-6 AND G.KABUL_EDEN=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa IN (0,1))
    AND coalesce(G.SORUMLU,0)=0
  ORDER BY 2, 20, 1 DESC;
$$;

-- ------------------------------------------------------------ BAYRAKLI (2 parca, STD)
DROP FUNCTION IF EXISTS fn_prg_islistesibayrakli(integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesibayrakli(p_kullanici integer, p_ackapa integer, p_baslagun integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE GL.ID END)::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE GL.ADI END)::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint, G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G
    LEFT JOIN GOREVLISTE GL ON G.LISTEID=GL.ID
    LEFT JOIN GOREVKULLANICI GK1 ON G.LISTEID=GK1.LISTGOREVID AND GK1.TUR=11 AND GK1.REHBERID=p_kullanici
    LEFT JOIN GOREVKULLANICI GK2 ON GL.ID=GK2.LISTGOREVID AND GK2.TUR<=2 AND GK2.REHBERID=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND coalesce(G.BAYRAK,0)=1
    AND ((G.EKLEYEN=p_kullanici) OR (GK2.TUR<=2 AND GK2.REHBERID=p_kullanici))
  UNION ALL
  SELECT G.ID::int, GL.ID::int, GL.ADI::varchar(255), G.KONUSU::varchar(1000), G.DURUM::smallint, NULL::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp, 0::smallint,0::smallint,0::smallint,0::smallint,
    0::int,0::int, G.ACIL::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp, NULL::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM SERVIS G INNER JOIN GOREVLISTE GL ON GL.ID=-6 AND G.KABUL_EDEN=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa IN (0,1))
    AND coalesce(G.ACIL,0)=1
  ORDER BY 2, 20, 1 DESC;
$$;

-- ------------------------------------------------------------ TUMLISTE (2 parca, STD)
DROP FUNCTION IF EXISTS fn_prg_islistesitumliste(integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesitumliste(p_kullanici integer, p_ackapa integer, p_baslagun integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE G.LISTEID END)::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE (SELECT GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LISTEID LIMIT 1) END)::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint, G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G
    LEFT JOIN GOREVKULLANICI GK2 ON G.ID=GK2.LISTGOREVID AND GK2.TUR<=2 AND GK2.REHBERID=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND ((G.EKLEYEN=p_kullanici) OR (GK2.TUR<=2 AND GK2.REHBERID=p_kullanici))
  UNION ALL
  SELECT G.ID::int, GL.ID::int, GL.ADI::varchar(255), G.KONUSU::varchar(1000), G.DURUM::smallint, NULL::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp, 0::smallint,0::smallint,0::smallint,0::smallint,
    0::int,0::int, G.ACIL::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp, NULL::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM SERVIS G INNER JOIN GOREVLISTE GL ON GL.ID=-6 AND G.KABUL_EDEN=p_kullanici
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa IN (0,1))
  ORDER BY 2, 20, 1 DESC;
$$;

-- ------------------------------------------------------------ BUHAFTA (2 parca, STD, +@Gun)
DROP FUNCTION IF EXISTS fn_prg_islistesibuhafta(integer,integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesibuhafta(p_kullanici integer, p_ackapa integer, p_baslagun integer, p_gun integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE GL.ID END)::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE GL.ADI END)::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint, G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G
    LEFT JOIN GOREVLISTE GL ON G.LISTEID=GL.ID
    LEFT JOIN GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREVID AND GK1.TUR=11 AND GK1.REHBERID=p_kullanici
    LEFT JOIN GOREVKULLANICI GK2 ON G.ID=GK2.LISTGOREVID AND GK2.TUR<=2 AND GK2.REHBERID=p_kullanici
  WHERE G.BASLAMATARIHI IS NOT NULL
    AND G.BASLAMATARIHI::date <= (current_date + p_gun)
    AND G.BASLAMATARIHI > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND ((G.EKLEYEN=p_kullanici) OR (GK1.TUR=11 AND GK1.REHBERID=p_kullanici))
  UNION ALL
  SELECT G.ID::int, GL.ID::int, GL.ADI::varchar(255), G.KONUSU::varchar(1000), G.DURUM::smallint, NULL::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp, 0::smallint,0::smallint,0::smallint,0::smallint,
    0::int,0::int, G.ACIL::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp, NULL::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM SERVIS G
    INNER JOIN GOREVLISTE GL ON GL.ID=-6
    INNER JOIN GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREVID AND GK1.TUR=12 AND GK1.REHBERID=p_kullanici
  WHERE G.BASLAMATARIHI IS NOT NULL
    AND G.BASLAMATARIHI::date <= (current_date + p_gun)
    AND G.BASLAMATARIHI > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
  ORDER BY 2, 20, 1 DESC;
$$;

-- ------------------------------------------------------------ _PROJELER (tek parca, +NOTLAR, TURU varchar, +@ListeId)
DROP FUNCTION IF EXISTS fn_prg_islistesi_projeler(integer,integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesi_projeler(p_kullanici integer, p_ackapa integer, p_baslagun integer, p_listeid integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" varchar(255),"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"NOTLAR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int, G.LISTEID::int, P.PROJEKODU::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint,
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-21044 AND DIL=-1 AND DEGER=G.TURU LIMIT 1)::varchar(255),
    G.REHBERID::int, (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=1) THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P2.PROJEKODU FROM PROJELER P2 WHERE P2.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G INNER JOIN PROJELER P ON P.ID=G.PROJEID
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND G.PROJEID=p_listeid
  ORDER BY 2, 21, 1 DESC;
$$;

-- ------------------------------------------------------------ _DEMIRBAS (tek parca, +NOTLAR, TURU varchar, +@DemirbasId)
DROP FUNCTION IF EXISTS fn_prg_islistesi_demirbas(integer,integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesi_demirbas(p_kullanici integer, p_ackapa integer, p_baslagun integer, p_demirbasid integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),"DURUM" smallint,
  "TURU" varchar(255),"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"NOTLAR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int, G.LISTEID::int, P.PROJEKODU::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint,
    (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-21045 AND DIL=-1 AND DEGER=G.TURU LIMIT 1)::varchar(255),
    G.REHBERID::int, (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=1) THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P2.PROJEKODU FROM PROJELER P2 WHERE P2.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G LEFT JOIN PROJELER P ON P.ID=G.PROJEID
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND G.YER=18 AND G.YER_ID=p_demirbasid
  ORDER BY 2, 21, 1 DESC;
$$;

-- ------------------------------------------------------------ _LISTELER (tek parca, DURUM YOK, +@ListeId)
DROP FUNCTION IF EXISTS fn_prg_islistesi_listeler(integer,integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesi_listeler(p_kullanici integer, p_ackapa integer, p_baslagun integer, p_listeid integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(1000),
  "TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int, G.LISTEID::int, GL.ADI::varchar(255),
    G.KONUSU::varchar(1000), G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G INNER JOIN GOREVLISTE GL ON G.LISTEID=GL.ID
  WHERE coalesce(G.BASLAMATARIHI,now()) > (CASE WHEN G.ACKAPA=1 THEN now()-(p_baslagun*interval '1 day') ELSE now()-(9999*interval '1 day') END)
    AND (p_ackapa=1 OR (CASE WHEN G.ACKAPA=0 THEN 0 WHEN G.ACKAPA=1 THEN 1 END)=p_ackapa)
    AND G.LISTEID=p_listeid
  ORDER BY 2, 19, 1 DESC;
$$;

-- ------------------------------------------------------------ ONAYLA (2 parca, poz3 ACKAPA_ONAY, param: Kullanici,IsDurum,ServisDurum)
DROP FUNCTION IF EXISTS fn_prg_islistesionayla(integer,integer,integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesionayla(p_kullanici integer, p_isdurum integer, p_servisdurum integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"ACKAPA_ONAY" smallint,"LISTEADI" varchar(255),"KONUSU" varchar(1000),
  "DURUM" smallint,"TURU" integer,"REHBERID" integer,"CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),
  "BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,"TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,
  "ZINCIR_BIT" smallint,"YORUM_BIT" smallint,"BAGIDUST" integer,"BAGIDALT" integer,"BAYRAK" integer,
  "ACKAPA" integer,"EKLEYEN" integer,"EKLEMETARIHI" timestamp,"PROJEKODU" varchar(255),"EKLEYENAD" varchar(255))
LANGUAGE sql AS $$
  SELECT G.ID::int,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.ID FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE G.LISTEID END)::int,
    0::smallint AS ACKAPA_ONAY,
    (CASE WHEN G.LISTEID=0 THEN (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID) ELSE (SELECT GL.ADI FROM GOREVLISTE GL WHERE GL.ID=G.LISTEID LIMIT 1) END)::varchar(255),
    G.KONUSU::varchar(1000), G.DURUM::smallint, G.TURU::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp,
    (CASE WHEN coalesce(G.TEKRARID,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.ANIMSAT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN coalesce(G.BAGIDUST,0)>0 OR coalesce(G.BAGIDALT,0)>0 THEN 1 ELSE 0 END)::smallint,
    (CASE WHEN EXISTS(SELECT 1 FROM GOREVYORUM WHERE GOREVID=G.ID AND TUR=2) THEN 1 ELSE 0 END)::smallint,
    G.BAGIDUST::int, G.BAGIDALT::int, G.BAYRAK::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp,
    (SELECT P.PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID LIMIT 1)::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM GOREVLER G
  WHERE G.EKLEYEN=p_kullanici AND G.DURUM=p_isdurum
  UNION ALL
  SELECT G.ID::int, GL.ID::int, 0::smallint, GL.ADI::varchar(255), G.KONUSU::varchar(1000), G.DURUM::smallint, NULL::int, G.REHBERID::int,
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.REHBERID LIMIT 1)::varchar(255), G.MUS_ILGILI::int,
    coalesce((SELECT string_agg(KL.KOD,' - ' ORDER BY GK.ID) FROM GOREVKULLANICI GK INNER JOIN KULLANICI KL ON GK.REHBERID=KL.REHBERID WHERE GK.LISTGOREVID=G.ID),'')::varchar(1000),
    G.BASLAMATARIHI::timestamp, G.BITISTARIHI::timestamp, 0::smallint,0::smallint,0::smallint,0::smallint,
    0::int,0::int, G.ACIL::int, G.ACKAPA::int, G.EKLEYEN::int, G.EKLEMETARIHI::timestamp, NULL::varchar(255),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN LIMIT 1)::varchar(255)
  FROM SERVIS G INNER JOIN GOREVLISTE GL ON GL.ID=-6 AND G.KABUL_EDEN=p_kullanici
  WHERE G.DURUM=p_servisdurum
  ORDER BY 2, 3, 1 DESC;
$$;

-- ------------------------------------------------------------ _ZIYARET (temas zamani gecenler, tek param)
DROP FUNCTION IF EXISTS fn_prg_islistesi_ziyaret(integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesi_ziyaret(p_kullanici integer)
RETURNS TABLE("ID" integer,"LISTEID" integer,"LISTEADI" varchar(255),"KONUSU" varchar(500),"REHBERID" integer,
  "CARIAD" varchar(255),"MUS_ILGILI" integer,"ATANAN1" varchar(1000),"BASLAMATARIHI" timestamp,"BITISTARIHI" timestamp,
  "TEKRAR_BIT" smallint,"ANIMSAT_BIT" smallint,"BAYRAK" integer,"ACKAPA" integer,"PERYOT" integer,"EKLEYEN" integer)
LANGUAGE sql AS $$
  SELECT coalesce(MAXGOREV.ID,-1)::int AS ID, 0::int AS LISTEID, 'Temas Zamanı Geçenler'::varchar(255) AS LISTEADI,
    ('Peryot : '||R.PERYOT::varchar||' ay / Geçen Gün : '||
       ((current_date - (coalesce(MAX(MAXGOREV.BASLAMATARIHI), R.EKLEMETARIHI) + (R.PERYOT*30)*interval '1 day')::date))::varchar)::varchar(500) AS KONUSU,
    R.ID::int AS REHBERID, R.FIRMA::varchar(255) AS CARIAD, MAXGOREV.MUS_ILGILI::int,
    NULL::varchar(1000) AS ATANAN1,
    (coalesce(MAX(MAXGOREV.BASLAMATARIHI), R.EKLEMETARIHI) + (R.PERYOT*30)*interval '1 day')::timestamp AS BASLAMATARIHI,
    NULL::timestamp AS BITISTARIHI, 0::smallint, 0::smallint, 0::int AS BAYRAK, 0::int AS ACKAPA,
    R.PERYOT::int, MAXGOREV.EKLEYEN::int
  FROM REHBER R
    LEFT JOIN (
      SELECT ID, REHBERID, MUS_ILGILI, BASLAMATARIHI, BITISTARIHI, EKLEYEN
      FROM (
        SELECT ID, REHBERID, MUS_ILGILI, BASLAMATARIHI,
               MAX(BASLAMATARIHI) OVER (PARTITION BY REHBERID) AS MAXTARIH,
               CASE WHEN MAX(BASLAMATARIHI) OVER (PARTITION BY REHBERID)=BASLAMATARIHI THEN 1 ELSE 0 END AS MAXTARIHMI,
               BITISTARIHI, EKLEYEN
        FROM GOREVLER
        GROUP BY ID, REHBERID, MUS_ILGILI, BASLAMATARIHI, BITISTARIHI, EKLEYEN
      ) X WHERE MAXTARIHMI=1
    ) MAXGOREV ON R.ID=MAXGOREV.REHBERID
  WHERE R.PERYOT > 0
    AND now() - coalesce(MAXGOREV.BASLAMATARIHI, R.EKLEMETARIHI) > ((R.PERYOT*30)*interval '1 day')
    AND R.TEMSILCI=p_kullanici
  GROUP BY coalesce(MAXGOREV.ID,-1), R.ID, R.FIRMA, MAXGOREV.MUS_ILGILI, R.EKLEMETARIHI, R.PERYOT, MAXGOREV.EKLEYEN
  ORDER BY 1;
$$;

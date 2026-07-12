-- ============================================================
-- fn_modullistesi() — MSSQL dbo.fn_ModulListesi TVF'inin PG portu
-- ------------------------------------------------------------
-- Modul listesi (MODUL) + dinamik dallar (DOKUMLER rapor, REHBER sube, "Ortak",
--   GENINI ekstre, DEPOLAR depo). MSSQL'de her satir bir LISANS-HASH kapisindan
--   gecer (M.L = HashBytes('SHA1', @Sid+MODULID); @Sid sunucu-schemadate hash'i).
-- PG PILOT: sys.sysservers/HashBytes/fn_varbintohexstr yok -> hash kapisi UYGULANMAZ
--   (tum moduller doner). Lisans zorlamasi PG'ye tasindiginda burada yeniden ele alinacak.
-- MSSQL->PG: convert->CAST/::, LEN(int)->length(int::text), '+' concat->CONCAT,
--   int LIKE->int::text LIKE, alias=expr->expr AS alias.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_modullistesi();
CREATE FUNCTION public.fn_modullistesi()
RETURNS TABLE(modulid bigint, rootkod bigint, tur int, moduladi text, aciklama text)
LANGUAGE sql STABLE AS $$
  -- 1) MODUL taban (ROOTKOD = son 2 hane atilmis ust-modul; 2-haneli -> 0)
  select M.MODULID::bigint,
    (case length(M.MODULID::text)
       when 2  then 0
       when 4  then substring(M.MODULID::text,1,2)::bigint
       when 6  then substring(M.MODULID::text,1,4)::bigint
       when 8  then substring(M.MODULID::text,1,6)::bigint
       when 10 then substring(M.MODULID::text,1,8)::bigint
       when 12 then substring(M.MODULID::text,1,10)::bigint
       when 14 then substring(M.MODULID::text,1,12)::bigint
     end)::bigint,
    M.TUR::int, M.MODULADI::text, M.ACIKLAMA::text
  from MODUL M

  union all
  -- 2) DOKUMLER (rapor modulleri, MODULID '__99')
  select CAST(CONCAT(M.MODULID::varchar, D.ID::varchar) AS bigint),
    M.MODULID::bigint, 1, D.RAPORADI::text, D.ACIKLAMA::text
  from MODUL M inner join DOKUMLER D on M.DOKUMTUR=D.MODUL
  where length(M.MODULID::text)=4 and M.MODULID::text like '__99'

  union all
  -- 3) REHBER subeler (R.ID<0, MODULID '__98')
  select CAST(CONCAT(M.MODULID::varchar, (-R.ID)::varchar) AS bigint),
    M.MODULID::bigint, 1, R.FIRMA::text, NULL::text
  from MODUL M inner join REHBER R on R.ID<0 and R.DURUM>0
  where length(M.MODULID::text)=4 and M.MODULID::text like '__98'

  union all
  -- 4) "Ortak" (MODULID '__98')
  select CAST(CONCAT(M.MODULID::varchar, '0') AS bigint),
    M.MODULID::bigint, 1, 'Ortak'::text, NULL::text
  from MODUL M
  where length(M.MODULID::text)=4 and M.MODULID::text like '__98'

  union all
  -- 5) GENINI ekstreleri (MODULID=220150)
  select CAST(CONCAT('220150', G.DEGER::varchar) AS bigint),
    M.MODULID::bigint, 1, CONCAT(G.ANAHTAR, ' Ekstresi')::text, NULL::text
  from MODUL M inner join GENINI G on G.BOLUM=-2200 and M.MODULID=220150 and G.DIL=-1

  union all
  -- 6) DEPOLAR (MODULID='2470')
  select CAST(CONCAT(M.MODULID::varchar, D.ID::varchar) AS bigint),
    M.MODULID::bigint, 1, D.DEPOADI::text, NULL::text
  from MODUL M inner join DEPOLAR D on D.DURUM>0
  where length(M.MODULID::text)=4 and M.MODULID='2470'

  order by 1;
$$;

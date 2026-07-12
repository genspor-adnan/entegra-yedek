-- ============================================================
-- 04_proc_portlari.sql — MSSQL saklı yordamlarının (exec sp_X) PG fonksiyon portları
-- ------------------------------------------------------------
-- MSSQL 'exec sp_X a,b' -> PG 'select * from sp_x(a,b)' (kod tarafi UVeriMotor.DbExec seam).
-- Her sp ayri portlanir; buraya eklenir. getdate()-N -> now()-N*interval, isnull->coalesce,
-- bit=1 -> smallint (native). Ihtiyac olunca cogaltilacak.
-- ============================================================

-- Kullanicinin acik gorev+servis sayisi (dashboard 'Gorevler (N)' butonu).
DROP FUNCTION IF EXISTS public.sp_prg_sayi_banaislistesi(int, int, int);
CREATE FUNCTION public.sp_prg_sayi_banaislistesi(p_kullanici int, p_ackapa int, p_baslagun int)
RETURNS TABLE(gorevsay bigint)
LANGUAGE sql STABLE AS $$
  select sum(SAY)::bigint from (
    select count(G.ID) AS SAY
    from GOREVLER G
      inner join GOREVKULLANICI GK1 on G.ID=GK1.LISTGOREVID and GK1.TUR=11 and GK1.REHBERID=p_kullanici
    where coalesce(G.BASLAMATARIHI, now()::timestamp) >
            (case when G.ACKAPA=1 then now()::timestamp - p_baslagun*interval '1 day'
                  else now()::timestamp - 9999*interval '1 day' end)
      and 1 = (case when p_ackapa=1 then 1
                    when p_ackapa=(case when G.ACKAPA=0 then 0 when G.ACKAPA=1 then 1 end) then 1
                    else 0 end)
    union all
    select count(G.ID)
    from SERVIS G
      inner join GOREVLISTE GL on GL.ID=-6 and G.SORUMLU=p_kullanici
    where coalesce(G.BASLAMATARIHI, now()::timestamp) >
            (case when G.ACKAPA=1 then now()::timestamp - p_baslagun*interval '1 day'
                  else now()::timestamp - 9999*interval '1 day' end)
      and 1 = (case when p_ackapa=0 then 1 when p_ackapa=1 then 1 else 0 end)
  ) Toplam;
$$;

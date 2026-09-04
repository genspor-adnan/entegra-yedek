-- ============================================================================
--  383 - PLANA EKLENEN KISI, PLANIN ROLUNDE ADAY OLMALI
--
--  Kullanici: "prim rolüne göre personeldeki prim rolü eşleşmesi ile alanlara
--  eklenebilir".
--
--  382'de yalniz "dis hekim ancak Gönderen planina" kurali vardi. Dogru kural
--  DAHA GENELI: kisi, planin rolunde ADAY DEGILSE o plana eklenmemeli -
--  `belge_satir_rol`'de o rolde hic gorunmeyecegi icin hakedis HIC dogmaz ve
--  eksik prim ancak ay sonunda fark edilir. Dis hekim kurali bunun OZEL HALI:
--  aday gorunumunde dis hekimin tek rolu zaten Gönderen (1).
--
--  ADAYLIK KAYNAGI `v_prim_rol_aday`:
--      ic personel  -> taraf_prim_rol'de ISARETLI roller (calisma sekli Primli)
--      dis hekim    -> yalnizca Gönderen (isaret aranmaz, dis hekim olmasi yeter)
--
--  Kural ARAYUZDE DE var (arama yalnizca aday listesini tarar); buradaki tetik
--  garantidir - istek dogrudan API'ye gelebilir, gocler arayuzden gecmez.
-- ============================================================================

create or replace function public.tg_prim_plani_taraf_dogrula()
returns trigger
language plpgsql
as $function$
declare
    v_rol   smallint;
    v_unvan varchar(200);
    v_rol_ad text;
begin
    select p.rol into v_rol from public.prim_plani p where p.id = new.plan_id;
    select coalesce(t.unvan, '') into v_unvan from public.taraf t where t.id = new.taraf_id;

    if not exists (select 1 from public.v_prim_rol_aday a
                    where a.id = new.taraf_id and a.rol = coalesce(v_rol, 0)) then
        select coalesce(kd.ad, 'rol ' || coalesce(v_rol, 0)::text) into v_rol_ad
          from public.kod_liste kl
          join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = v_rol
         where kl.kod = 'prim.rol';

        raise exception
            '% kisisi "%" rolunde prim adayi degil; personel kartindaki Prim '
            'Rolleri sekmesinden bu rolu isaretleyin (dis hekimlerde yalnizca '
            '"Gönderen" rolu vardir).', v_unvan, coalesce(v_rol_ad, '?')
            using errcode = 'check_violation';
    end if;
    return new;
end $function$;

comment on function public.tg_prim_plani_taraf_dogrula() is
  'Plana eklenen kisi PLANIN ROLUNDE aday olmali (383, v_prim_rol_aday): '
  'aday olmayan kisiye yazilan satirdan hakedis hic dogmaz. "Dis hekim yalniz '
  'Gönderen planina" (382) bunun ozel halidir.';

do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi
      from public.prim_plani_taraf t
      join public.prim_plani p on p.id = t.plan_id
     where not exists (select 1 from public.v_prim_rol_aday a
                        where a.id = t.taraf_id and a.rol = p.rol);
    if v_sayi > 0 then
        raise notice 'UYARI: % satir yeni kurali ihlal ediyor (kisi plan rolunde aday degil)', v_sayi;
    else
        raise notice 'Mevcut veri kurala uygun.';
    end if;
end $$;

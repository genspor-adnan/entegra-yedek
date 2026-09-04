-- ============================================================================
--  384 - PLANA EKLENEN KISI AKTIF DE OLMALI
--
--  Kullanici: "tabii ki personel ve dış dr'lar aktifse şartı da var".
--
--  383 yalnizca ROL ADAYLIGINI ariyordu; isten ayrilmis (durum <> 1) bir
--  personel hala o rolde aday gorunur. Plana pasif kisi eklemek, hicbir zaman
--  is yapmayacak birine oran yazmaktir.
--
--  ONEMLI SINIR: kural YALNIZ EKLEME/DEGISTIRME aninda calisir (tetik
--  `insert or update of plan_id, taraf_id`). Bugun ekli olan biri YARIN pasife
--  alinirsa PLANDAKI SATIRI DURUR ve gecmis hakedisleri bozulmaz - kisiyi
--  isten cikarmak, gecmis primini silmek demek degildir.
-- ============================================================================

create or replace function public.tg_prim_plani_taraf_dogrula()
returns trigger
language plpgsql
as $function$
declare
    v_rol    smallint;
    v_unvan  varchar(200);
    v_durum  smallint;
    v_rol_ad text;
begin
    select p.rol into v_rol from public.prim_plani p where p.id = new.plan_id;
    select coalesce(t.unvan, ''), coalesce(t.durum, 1)
      into v_unvan, v_durum
      from public.taraf t where t.id = new.taraf_id;

    if coalesce(v_durum, 1) <> 1 then
        raise exception '% PASIF; plana yalnizca aktif personel/dis hekim eklenebilir.',
            v_unvan using errcode = 'check_violation';
    end if;

    if not exists (select 1 from public.v_prim_rol_aday a
                    where a.id = new.taraf_id
                      and a.rol = coalesce(v_rol, 0)
                      and coalesce(a.durum, 1) = 1) then
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
  'Plana eklenen kisi AKTIF (384) ve PLANIN ROLUNDE aday (383) olmali. '
  'Yalniz ekleme/degistirme aninda: sonradan pasife alinan kisinin PLANDAKI '
  'satiri ve gecmis hakedisleri korunur.';

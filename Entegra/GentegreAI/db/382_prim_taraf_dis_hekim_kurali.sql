-- ============================================================================
--  382 - DIS HEKIM YALNIZ "GÖNDEREN" PLANINA EKLENEBILIR
--
--  Kullanici: "prim rolü gönderense ancak o zaman dış doktorlar eklenebilir".
--
--  KURALIN GEREKCESI: dis hekim kurumda CALISMAZ - tetkiki yapmaz, raporlamaz,
--  ameliyata girmez. Kurumla iliskisi tek bir eylemdir: HASTA GONDERIR. Bu
--  yuzden "Yapan %10" ya da "Raporlayan %12" planina dis hekim eklemek, hicbir
--  zaman gerceklesmeyecek bir satir yazmak demektir: `belge_satir_rol`'de o
--  kisi o rolde hic gorunmez, hakedis hic dogmaz ve eksik prim ancak ay sonunda
--  fark edilir.
--
--  KURAL VERITABANINDA: arayuz zaten dis hekimleri aramadan cikariyor ama
--  istek dogrudan API'ye de gelebilir (ve gocler/betikler arayuzden gecmez).
--  Ayni kural iki yerde: biri kullaniciyi yonlendirir, oteki garanti eder.
-- ============================================================================

create or replace function public.tg_prim_plani_taraf_dogrula()
returns trigger
language plpgsql
as $function$
declare
    v_rol      smallint;
    v_dis      smallint;
    v_unvan    varchar(200);
begin
    select p.rol into v_rol from public.prim_plani p where p.id = new.plan_id;
    select coalesce(pp.dis_hekim, 0), coalesce(t.unvan, '')
      into v_dis, v_unvan
      from public.taraf t
      left join public.taraf_personel pp on pp.id = t.id
     where t.id = new.taraf_id;

    -- 1 = Gönderen (kod listesi prim.rol).
    if v_dis = 1 and coalesce(v_rol, 0) <> 1 then
        raise exception
            '% bir DIS HEKIM; dis hekim yalnizca "Gönderen" rollu prim planina eklenebilir.',
            v_unvan
            using errcode = 'check_violation';
    end if;
    return new;
end $function$;

drop trigger if exists tr_prim_plani_taraf_dogrula on public.prim_plani_taraf;
create trigger tr_prim_plani_taraf_dogrula
    before insert or update of plan_id, taraf_id on public.prim_plani_taraf
    for each row execute function public.tg_prim_plani_taraf_dogrula();

comment on function public.tg_prim_plani_taraf_dogrula() is
  'Dis hekim yalniz "Gönderen" (rol 1) planina eklenebilir (382): kurumda '
  'calismadigi icin baska rolde hic gorunmez, o satirdan hakedis hic dogmaz.';

-- MEVCUT VERI KONTROLU: kural bugun ihlal ediliyor mu?
do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi
      from public.prim_plani_taraf t
      join public.prim_plani p on p.id = t.plan_id
      join public.taraf_personel pp on pp.id = t.taraf_id
     where coalesce(pp.dis_hekim, 0) = 1 and coalesce(p.rol, 0) <> 1;
    if v_sayi > 0 then
        raise notice 'UYARI: % adet satir yeni kurali ihlal ediyor (dis hekim, rol <> Gönderen)', v_sayi;
    else
        raise notice 'Mevcut veri kurala uygun.';
    end if;
end $$;

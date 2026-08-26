-- ============================================================================
--  Gentegre AI — "Merkez deposunu KULLAN" (paylasim degil, DEVIR)
--  174_merkez_depo_kullan.sql
--
--  Kullanici: "'Merkez deposunu da kullan' -> 'Merkez deposunu kullan';
--  isaretli ise depo (gridi) gorunmez olur."
--
--  ANLAM DEGISTI: 173'te bayrak "kendi depolarina EK OLARAK merkezinkiler"
--  demekti. Artik "kendi deposu YOK, merkezin depolarini kullanir" demek -
--  magaza/servis subesi gibi deposu olmayan birimler icin dogru model.
--  Ekranda da boyle: bayrak isaretliyken subenin kendi depo listesi hic
--  gosterilmez, cunku o subeye ait depo kaydi tutulmaz.
--
--  ESKI VERI: bayragi 1 olan sube yok (173 varsayilani 0), dolayisiyla anlam
--  degisikliginin gecmise etkisi yok - yine de asagida sayilip loglaniyor.
-- ============================================================================
\set ON_ERROR_STOP on

comment on column public.sube.merkez_depo_kullan is
  '1 ise sube KENDI depolarini degil MERKEZIN depolarini kullanir (174).';

create or replace function public.fn_sube_depo_subeleri(p_sube_id integer)
returns integer[] language sql stable as $$
    select case
             when s.merkez_depo_kullan = 1
                  and public.fn_sube_merkez_id(s.id) is distinct from s.id
             -- Kendi depolari DEGIL, merkezinkiler (174).
             then array[public.fn_sube_merkez_id(s.id)]
             else array[s.id]
           end
      from public.sube s
     where s.id = p_sube_id
    union all
    -- Sube bulunamazsa (sube_id 0 / eski kayit) filtre kimseyi elemesin diye
    --   verilen degeri aynen dondur.
    select array[p_sube_id]
     where not exists (select 1 from public.sube where id = p_sube_id)
    limit 1
$$;

comment on function public.fn_sube_depo_subeleri(integer) is
  'Subenin depo secimlerinde gorecegi sube kumesi: kendisi ya da (bayrak acikken) merkez - 174.';

do $$
declare v_var integer;
begin
    select count(*) into v_var from public.sube where merkez_depo_kullan = 1;
    if v_var > 0 then
        raise notice '174 UYARI: % subede bayrak acik - artik KENDI depolari degil merkezinkiler gecerli.', v_var;
    end if;
    raise notice '174 tamam: merkez deposu kullanimi devir anlaminda.';
end $$;

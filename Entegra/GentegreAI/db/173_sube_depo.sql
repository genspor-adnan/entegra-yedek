-- ============================================================================
--  Gentegre AI — SUBE DEPOLARI + MERKEZ DEPOSU KULLANIMI
--  173_sube_depo.sql
--
--  Kullanici: "sube modalde Depolar diye sekme ac, depolari buraya tasi; yalniz
--  sube merkez depoyu da kullanabilir (check), yoksa kendi depolarini kullanir."
--
--  DURUM: `depo.sube_id` zaten vardi ve liste ekrani subeye gore suzuyordu, ama
--  MERKEZ DEPOSUNU paylasan sube anlatilamiyordu. Gercek hayatta yaygin:
--  magaza kendi deposundan satar ama stok merkez depodan da cikabilir.
--
--  BAYRAK SUBEDE (depoda degil): "bu sube merkezin depolarini da gorsun" karari
--  subenin ozelligidir. Depoya koysaydik "hangi subeler bu depoyu gorur"
--  listesi olurdu - cok subeli kurulumda her yeni subede tum depolar tek tek
--  isaretlenmek zorunda kalirdi.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.sube
    add column if not exists merkez_depo_kullan smallint not null default 0;

comment on column public.sube.merkez_depo_kullan is
  '1 ise sube kendi depolarina EK OLARAK merkezin depolarini da kullanir (173).';

-- Depo secimlerinde gorunecek SUBE kumesi: kendisi + (bayrak acikken) merkez.
--   Tek yerden cozulur; liste, belge kalemi ve stok hareketi ayni kumeyi kullanir.
create or replace function public.fn_sube_depo_subeleri(p_sube_id integer)
returns integer[] language sql stable as $$
    select case
             when s.merkez_depo_kullan = 1
                  and public.fn_sube_merkez_id(s.id) is distinct from s.id
             then array[s.id, public.fn_sube_merkez_id(s.id)]
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
  'Subenin depo secimlerinde gorecegi sube kumesi: kendisi + merkez (bayrak acikken) - 173.';

do $$
declare r record;
begin
    for r in select s.id, s.ad, s.merkez_depo_kullan,
                    public.fn_sube_depo_subeleri(s.id) as kume,
                    (select count(*) from public.depo d
                      where d.sube_id = any(public.fn_sube_depo_subeleri(s.id))) as depo_adet
               from public.sube s order by s.id loop
        raise notice '173: sube % (%) merkez_depo=% -> sube kumesi %, % depo',
            r.id, r.ad, r.merkez_depo_kullan, r.kume, r.depo_adet;
    end loop;
    raise notice '173 tamam: sube.merkez_depo_kullan + fn_sube_depo_subeleri.';
end $$;

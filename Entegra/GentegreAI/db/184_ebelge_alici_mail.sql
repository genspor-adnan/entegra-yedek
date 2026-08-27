\set ON_ERROR_STOP on
-- e-Arsiv gonderiminde alici e-postasi: alias alani (Delphi ile ayni ikili
--   anlam - e-Faturada GIB posta kutusu, e-Arsivde e-posta adresi).
create or replace function public.fn_ebelge_alici_bilgi(p_belge_id integer)
returns table (belge_turu smallint, alias text, onerilen_mail text, taraf_unvan text)
language sql stable as $$
    select e.belge_turu,
           coalesce(nullif(btrim(e.alici_alias), ''), '')::text,
           -- Oncelik: carinin e-Belge icin ayrilmis adresi, sonra genel e-postasi.
           coalesce(nullif(btrim(t.alias_eposta), ''),
                    nullif(btrim(t.eposta), ''), '')::text,
           coalesce(bl.taraf_unvan, '')::text
      from public.belge bl
      join public.e_belge e on e.belge_id = bl.id
      left join public.taraf t on t.id = bl.taraf_id
     where bl.id = p_belge_id
     order by e.id desc limit 1
$$;

comment on function public.fn_ebelge_alici_bilgi(integer) is
  'e-Arsiv gonderiminde sorulacak alici e-postasi ve mevcut alias (184).';

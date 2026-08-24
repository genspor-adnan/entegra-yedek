-- ============================================================================
--  Gentegre AI — TELEFONDA ARAMA (rakam bazli)
--  123_telefon_arama.sql
--
--  Telefonlar "+90 532 418 77 20" bicimiyle saklaniyor; kullanici ise numarayi
--  akilda kaldigi gibi yaziyor: "5324187720", "0532 418 77 20", "532-418".
--  Arama duz metin karsilastirmasiyla calistigi icin bunlarin cogu KAYIT
--  BULMUYORDU (yalniz birebir parca eslesirse geliyordu).
--
--  fn_telefon_rakam iki tarafi da AYNI kanona indirger:
--    - rakam disi her sey atilir,
--    - basta "90" ulke kodu varsa atilir,
--    - kalan 11 hane ve "0" ile basliyorsa o "0" da atilir.
--  Sonuc: "+90 532 418 77 20", "05324187720" ve "5324187720" -> "5324187720".
--
--  Indeks: en cok aranan telefon kolonlarinda (taraf.telefon / cep_tel) ifade
--  indeksi acilir - aksi halde her arama tabloyu tarardi.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_telefon_rakam(metin text)
returns text
language sql
immutable
parallel safe
as $$
    select case
             when r is null or r = '' then ''
             when length(r) = 11 and left(r, 1) = '0' then right(r, 10)
             when left(r, 2) = '90' and length(r) >= 12 then
                  case when length(right(r, length(r) - 2)) = 11
                            and left(right(r, length(r) - 2), 1) = '0'
                       then right(r, 10)
                       else right(r, length(r) - 2)
                  end
             else r
           end
      from (select regexp_replace(coalesce(metin, ''), '[^0-9]', '', 'g') as r) x
$$;

comment on function public.fn_telefon_rakam(text) is
  'Telefonu rakam kanonuna indirger (123): ulke kodu ve yerel 0 onegi atilir. Arama bunun uzerinden yapilir.';

create index if not exists ix_taraf_telefon_rakam
    on public.taraf (public.fn_telefon_rakam(telefon)) where telefon <> '';
create index if not exists ix_taraf_cep_rakam
    on public.taraf (public.fn_telefon_rakam(cep_tel)) where cep_tel <> '';

do $$
declare v_ornek text;
begin
    select public.fn_telefon_rakam('+90 532 418 77 20') into v_ornek;
    raise notice '123 tamam: "+90 532 418 77 20" -> % (05324187720 -> %, 5324187720 -> %)',
                 v_ornek, public.fn_telefon_rakam('05324187720'),
                 public.fn_telefon_rakam('5324187720');
end $$;

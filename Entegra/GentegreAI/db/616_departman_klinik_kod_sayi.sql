-- =====================================================================
--  616_departman_klinik_kod_sayi.sql
--  SKRS KLİNİK KODU SAYI ALANI OLSUN.
--
--  611 alanı varchar açtı. Kart tarafında kod alanları tam sayı olarak
--  çözülüyor (DegerCevirici "kod" -> long); varchar bir kolona lookup
--  bağlayınca yazma tip uyuşmazlığıyla düşerdi. Kodun kendisi zaten
--  sayısal (SKRS KLİNİKLER 101..197023).
-- =====================================================================

alter table public.departman
  alter column skrs_klinik_kod drop default;
alter table public.departman
  alter column skrs_klinik_kod drop not null;
alter table public.departman
  alter column skrs_klinik_kod type integer
  using nullif(regexp_replace(coalesce(skrs_klinik_kod, ''), '\D', '', 'g'), '')::integer;

comment on column public.departman.skrs_klinik_kod is
  '611/616: SKRS KLINIKLER kodu (USS 101 KLINIK_KODU), v_skrs_klinik_lookup. '
  '`kod` BRANS kodudur, bu ayri alandir. NULL = karsiligi secilmemis.';

do $$
begin
    raise notice '616 tamam: % departmanda SKRS klinik kodu',
        (select count(*) from public.departman where skrs_klinik_kod is not null);
end $$;

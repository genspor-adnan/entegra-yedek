-- ============================================================================
--  Gentegre AI — KASA ISLEMINDE SAAT
--  146_kasa_islem_saat.sql
--
--  Kullanici: tahsilatta tarihin yaninda SAAT de olsun. `islem_tarihi` `date`
--  idi - gun icinde hangi tahsilatin once alindigi kaybediliyordu (kasa
--  sayiminda ve ekstre siralamasinda onemli).
--
--  `timestamp`e cevrilir; mevcut kayitlarin saati 00:00 olur (bilinmiyor,
--  uydurulmaz). PLAN TARIHI `date` KALIR: vade bir GUNDUR, saati yoktur.
--
--  Cevrim veri kaybetmez - date -> timestamp genisleme yonundedir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.kasa_islem
    alter column islem_tarihi type timestamp using islem_tarihi::timestamp;

comment on column public.kasa_islem.islem_tarihi is
  'Islemin tarihi ve SAATI (146). Ileri tarih/saat kabul edilmez.';

do $$
declare v_tip text;
begin
    select data_type into v_tip from information_schema.columns
     where table_name = 'kasa_islem' and column_name = 'islem_tarihi';
    raise notice '146 tamam: kasa_islem.islem_tarihi = %', v_tip;
end $$;

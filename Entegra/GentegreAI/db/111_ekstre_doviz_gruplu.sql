-- ============================================================================
--  Gentegre AI — EKSTRELER PARA BIRIMI BAZINDA
--  111_ekstre_doviz_gruplu.sql
--
--  IKI AYRI SORUN:
--
--  1) YURUYEN BAKIYE PARA BIRIMLERINI TOPLUYORDU. v_cari_ekstre'de doviz
--     bakiyesi PARTITION BY taraf_id idi: ayni carinin 1.000 USD faturasi ile
--     10.000 TL faturasi ayni sutunda toplanip "11.000" gibi HICBIR ANLAMI
--     OLMAYAN bir bakiye uretiyordu. Bakiye artik (taraf, para birimi) basina
--     yurur - USD bakiyesi USD, TL bakiyesi TL olarak okunur.
--
--  2) EKSTRE PARA BIRIMINE GORE GRUPLANIR (kullanici karari): once yerel para
--     (TL) hareketleri ve toplami, sonra USD ve toplami, sonra EUR... en sonda
--     yerel para cinsinden GENEL toplam. Bunun icin siralamayi belirleyen
--     doviz_sira kolonu eklenir: yerel para 0, digerleri 1 (kendi icinde kod
--     sirasiyla).
--
--  Yerel para birimi AYARDAN gelir (genel.yerel_para); "TL" sabit degildir.
--
--  Satirin yerel karsiligi HAREKETIN KENDI KURUYLA yazilir (yerel_borc /
--  yerel_alacak alanlari, kayit aninda hesaplanmis). Ekstre gununun guncel
--  kuruyla YENIDEN degerlemek muhasebe kaydiyla tutmaz ve ayni ekstre her gun
--  baska rakam verirdi; kur farki ayri bir hareket olarak dogar.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- yerel para ---
create or replace function public.fn_yerel_para()
returns varchar(6)
language sql
stable
as $$
    select coalesce(nullif((select deger from public.referans
                             where anahtar = 'genel.yerel_para'), ''), 'TL')::varchar(6)
$$;

comment on function public.fn_yerel_para() is
  'Yerel para birimi (ayar genel.yerel_para, yoksa TL). Ekstre gruplama sirasi bunu kullanir.';

-- ------------------------------------------------------------ cari ekstre ---
create or replace view public.v_cari_ekstre as
select id,
       taraf_id,
       taraf_unvan,
       islem_tarihi,
       plan_tarihi,
       tur,
       tur_adi,
       tur_grup,
       islem_no,
       belge_no,
       belge_id,
       kasa_islem_id,
       aciklama,
       doviz_cinsi,
       borc,
       alacak,
       doviz_kuru,
       yerel_borc,
       yerel_alacak,
       bakiye_dahil,
       proje_id,
       sube_id,
       -- Yerel bakiye de para birimi basina yurur: TL grubunun bakiyesi yalniz
       --   TL hareketlerden, USD grubunun yerel bakiyesi yalniz USD hareketlerin
       --   TL karsiliklarindan olusur. Genel toplam grid'in alt satirinda.
       sum(case when bakiye_dahil = 1 then yerel_borc - yerel_alacak else 0::numeric end)
           over (partition by taraf_id, doviz_cinsi
                 order by islem_tarihi, id
                 rows between unbounded preceding and current row) as yerel_bakiye,
       sum(case when bakiye_dahil = 1 then borc - alacak else 0::numeric end)
           over (partition by taraf_id, doviz_cinsi
                 order by islem_tarihi, id
                 rows between unbounded preceding and current row) as bakiye,
       -- Gruplama sirasi: yerel para once, digerleri kod sirasiyla arkasindan.
       -- (Kolon SONA eklenir: create or replace view mevcut kolon sirasini
       --  degistirmeye izin vermez, aradan eklemek view'i drop ettirirdi.)
       case when doviz_cinsi = public.fn_yerel_para() then 0 else 1 end as doviz_sira
  from v_mali_hareket_ek e
 where hesap_turu::text = 'C'::text and cari_ekstre = 1 and (islem_durum = any (array[1, 2]));

comment on view public.v_cari_ekstre is
  'Cari ekstresi (111). Bakiye (taraf, para birimi) basina yurur; doviz_sira gruplama sirasidir.';

-- ----------------------------------------------------------- hesap ekstre ---
-- Hesap TEK para biriminde calisir (hesap.doviz_cinsi), yine de ayni kural:
--   bakiye para birimi basina. Devir/duzeltme farkli birimde girilmis olsa bile
--   iki birim toplanmaz.
create or replace view public.v_hesap_ekstre as
select id,
       hesap_id,
       hesap_adi,
       hesap_dovizi,
       islem_tarihi,
       tur,
       tur_adi,
       islem_no,
       belge_no,
       kasa_islem_id,
       belge_id,
       taraf_id,
       taraf_unvan,
       aciklama,
       doviz_cinsi,
       doviz_kuru,
       borc as giris,
       alacak as cikis,
       yerel_borc,
       yerel_alacak,
       proje_id,
       sube_id,
       sum(borc - alacak)
           over (partition by hesap_id, doviz_cinsi
                 order by islem_tarihi, id
                 rows between unbounded preceding and current row) as bakiye,
       sum(yerel_borc - yerel_alacak)
           over (partition by hesap_id, doviz_cinsi
                 order by islem_tarihi, id
                 rows between unbounded preceding and current row) as yerel_bakiye,
       case when doviz_cinsi = public.fn_yerel_para() then 0 else 1 end as doviz_sira
  from v_mali_hareket_ek e
 where hesap_id is not null and hesap_ekstre = 1 and islem_durum = 2;

comment on view public.v_hesap_ekstre is
  'Hesap ekstresi (111). Bakiye (hesap, para birimi) basina yurur; doviz_sira gruplama sirasidir.';

do $$
declare v_para varchar(6); v_cari integer; v_hesap integer;
begin
    select public.fn_yerel_para() into v_para;
    select count(*) into v_cari  from public.v_cari_ekstre;
    select count(*) into v_hesap from public.v_hesap_ekstre;
    raise notice '111 tamam: yerel para %, cari ekstre % satir, hesap ekstre % satir',
                 v_para, v_cari, v_hesap;
end $$;

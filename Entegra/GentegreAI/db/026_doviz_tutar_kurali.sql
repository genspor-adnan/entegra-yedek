-- ============================================================================
--  Gentegre AI — tutarin yerel + doviz karsiligi HER ZAMAN dolu
--  026_doviz_tutar_kurali.sql
--
--  KARAR (19.08.2026): fatura satirinda ve tahsilat/odeme (mali_hareket)
--    satirinda tutar HEM YEREL PARA BIRIMINDE HEM DOVIZ KARSILIGIYLA tutulur.
--    TL islemde de alanlar bos birakilmaz: doviz_cinsi = 'TL', doviz_kuru = 1,
--    doviz_tutari = yerel tutar. Boylece:
--      * doviz raporu "kur neydi" diye geriye donuk hesap yapmaz (kur o anki kurdur),
--      * TL/doviz ayrimi icin sorgu dallanmaz,
--      * kur sonradan degisse bile gecmis belge/hareket DEGISMEZ.
--
--  Olculdu (goc sonrasi): belge_satir 6.251 satirin 4.499'unda doviz_cinsi ve
--    doviz_kuru bostu; mali_hareket'te 798 satirin TAMAMINDA kur 0 idi.
--    MSSQL kaynaginda TL islemlerde bu alanlar bos birakilmis.
--
--  mali_hareket'te ayri doviz_borc / doviz_alacak YOKTUR (eski KASA ile ayni):
--    hangi taraf doluysa (borc ya da alacak) doviz_tutari o tarafin karsiligidir.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------------- belge ----
update public.belge
   set belge_dovizi = coalesce(nullif(btrim(belge_dovizi), ''), 'TL'),
       doviz_kuru   = case when coalesce(doviz_kuru, 0) = 0 then 1 else doviz_kuru end,
       kur          = coalesce(nullif(btrim(kur), ''), 'TL'),
       rapor_dovizi = coalesce(nullif(btrim(rapor_dovizi), ''), 'TL')
 where coalesce(nullif(btrim(belge_dovizi), ''), '') = ''
    or coalesce(doviz_kuru, 0) = 0
    or coalesce(nullif(btrim(kur), ''), '') = ''
    or coalesce(nullif(btrim(rapor_dovizi), ''), '') = '';

update public.belge
   set doviz_tutari = round(genel_toplam / nullif(doviz_kuru, 0), 4)
 where coalesce(doviz_tutari, 0) = 0
   and genel_toplam <> 0
   and coalesce(doviz_kuru, 0) <> 0;

-- ---------------------------------------------------------- belge_satir ----
-- Satirin dovizi belirtilmemisse belgenin dovizi gecerlidir.
update public.belge_satir s
   set doviz_cinsi = coalesce(nullif(btrim(s.doviz_cinsi), ''),
                              nullif(btrim(b.belge_dovizi), ''), 'TL'),
       doviz_kuru  = case when coalesce(s.doviz_kuru, 0) = 0
                          then coalesce(nullif(b.doviz_kuru, 0), 1)
                          else s.doviz_kuru end
  from public.belge b
 where b.id = s.belge_id
   and (coalesce(nullif(btrim(s.doviz_cinsi), ''), '') = '' or coalesce(s.doviz_kuru, 0) = 0);

update public.belge_satir
   set doviz_birim_fiyat = round(birim_fiyat / nullif(doviz_kuru, 0), 6)
 where coalesce(doviz_birim_fiyat, 0) = 0
   and birim_fiyat <> 0
   and coalesce(doviz_kuru, 0) <> 0;

update public.belge_satir
   set doviz_tutari = round(tutar / nullif(doviz_kuru, 0), 4)
 where coalesce(doviz_tutari, 0) = 0
   and tutar <> 0
   and coalesce(doviz_kuru, 0) <> 0;

-- --------------------------------------------------------- mali_hareket ----
update public.mali_hareket
   set doviz_cinsi = coalesce(nullif(btrim(doviz_cinsi), ''), 'TL'),
       kur         = coalesce(nullif(btrim(kur), ''), 'TL'),
       doviz_kuru  = case when coalesce(doviz_kuru, 0) = 0 then 1 else doviz_kuru end
 where coalesce(nullif(btrim(doviz_cinsi), ''), '') = ''
    or coalesce(nullif(btrim(kur), ''), '') = ''
    or coalesce(doviz_kuru, 0) = 0;

-- Hangi taraf doluysa (borc / alacak) doviz karsiligi ODUR.
update public.mali_hareket
   set doviz_tutari = round((case when borc <> 0 then borc else alacak end)
                            / nullif(doviz_kuru, 0), 4)
 where coalesce(doviz_tutari, 0) = 0
   and (borc <> 0 or alacak <> 0)
   and coalesce(doviz_kuru, 0) <> 0;

-- ------------------------------------------------------------ varsayilan ----
-- Yeni kayitlarda alanlar bos gelmesin: TL varsayilani kolon duzeyinde.
alter table public.belge        alter column belge_dovizi set default 'TL';
alter table public.belge        alter column doviz_kuru   set default 1;
alter table public.belge_satir  alter column doviz_cinsi  set default 'TL';
alter table public.belge_satir  alter column doviz_kuru   set default 1;
alter table public.mali_hareket alter column doviz_cinsi  set default 'TL';
alter table public.mali_hareket alter column doviz_kuru   set default 1;

-- ---------------------------------------------------------------- kisit ----
-- Kur SIFIR olamaz: sifir kur "doviz karsiligi hesaplanamaz" demektir ve
--   0'a bolme ile raporu sessizce bozar.
alter table public.belge        drop constraint if exists ck_belge_kur;
alter table public.belge        add  constraint ck_belge_kur        check (doviz_kuru > 0);
alter table public.belge_satir  drop constraint if exists ck_belge_satir_kur;
alter table public.belge_satir  add  constraint ck_belge_satir_kur  check (doviz_kuru > 0);
alter table public.mali_hareket drop constraint if exists ck_mali_hareket_kur;
alter table public.mali_hareket add  constraint ck_mali_hareket_kur check (doviz_kuru > 0);

comment on column public.belge_satir.doviz_tutari  is 'Satir tutarinin DOVIZ karsiligi. TL islemde de dolu (doviz_cinsi = TL, kur = 1). Kur belge anindaki kurdur - sonradan degismez.';
comment on column public.belge_satir.doviz_kuru    is 'Satirin kuru. SIFIR OLAMAZ (check). TL islemde 1.';
comment on column public.mali_hareket.doviz_tutari is 'Hareketin DOVIZ karsiligi. Hangi taraf doluysa (borc/alacak) onun karsiligidir; ayri doviz_borc/doviz_alacak tutulmaz (eski KASA ile ayni).';
comment on column public.mali_hareket.doviz_kuru   is 'Hareketin kuru. SIFIR OLAMAZ (check). TL islemde 1.';

-- ------------------------------------------------------------- dogrulama ----
do $$
declare
    v_s integer; v_m integer; v_b integer;
begin
    select count(*) into v_s from public.belge_satir
     where doviz_cinsi = '' or doviz_kuru = 0 or (doviz_tutari = 0 and tutar <> 0);
    select count(*) into v_m from public.mali_hareket
     where doviz_cinsi = '' or doviz_kuru = 0 or (doviz_tutari = 0 and (borc <> 0 or alacak <> 0));
    select count(*) into v_b from public.belge
     where belge_dovizi = '' or doviz_kuru = 0;
    raise notice '026 tamam: eksik kalan -> belge_satir %, mali_hareket %, belge %', v_s, v_m, v_b;
end $$;

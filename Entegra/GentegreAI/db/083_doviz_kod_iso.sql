-- ============================================================================
--  Gentegre AI — Para birimi kodlarini ISO'ya normalize et + kur getirici
--  083_doviz_kod_iso.sql
--
--  SORUN: ayni para birimi uc farkli kodla yaziliydi:
--     hesap.doviz_cinsi      -> '$', '€', 'TRY'
--     doviz_kur.doviz_cinsi  -> '$', '€'
--     mali_hareket.doviz_cinsi -> 'USD', 'EUR' (080 gocunde ISO'ya cevrilmisti)
--  Kasa motoru bacak dovizi ile hesap dovizini KARSILASTIRIR; farkli kodlama
--  "hesabin para birimi bacaktan farkli" hatasi uretirdi ve kur tablosundan
--  hicbir kur bulunamazdi.
--
--  KARAR: her yerde ISO-4217 (USD/EUR/GBP/CHF/...), yerel para 'TL'.
--     'TRY' de 'TL'ye cevrilir (uygulama genelinde yerel kod 'TL').
--
--  Ayrica: legacy KUR alaninda para birimi yerine SAYI yazilmis 3 acilis-devri
--     satiri ('7591') TL'ye alinir - yerel ve doviz tutari zaten esitti.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------ ISO cevirici ----
create or replace function public.fn_doviz_iso(p_kod text)
returns varchar(6)
language sql
immutable
as $$
    select case upper(btrim(coalesce(p_kod, '')))
               when '$'   then 'USD'
               when 'USD' then 'USD'
               when '€'   then 'EUR'
               when 'EUR' then 'EUR'
               when '£'   then 'GBP'
               when '₺'   then 'TL'
               when 'TRY' then 'TL'
               when 'TRL' then 'TL'
               when ''    then 'TL'
               else upper(btrim(p_kod))
           end::varchar(6);
$$;

comment on function public.fn_doviz_iso(text) is
  'Para birimi kodunu ISO-4217''ye normalize eder. Yerel para her zaman ''TL'' (TRY degil).';

do $$
declare v_h integer; v_k integer; v_m integer;
begin
    -- kur tablosu: unique (doviz_cinsi, tarih) var; sembol satirlari ISO karsiligiyla
    --   cakisirsa (bugun cakismiyor) once cakisani sil.
    delete from public.doviz_kur k
     where public.fn_doviz_iso(k.doviz_cinsi) <> k.doviz_cinsi
       and exists (select 1 from public.doviz_kur i
                    where i.doviz_cinsi = public.fn_doviz_iso(k.doviz_cinsi)
                      and i.tarih = k.tarih);

    update public.doviz_kur set doviz_cinsi = public.fn_doviz_iso(doviz_cinsi)
     where doviz_cinsi <> public.fn_doviz_iso(doviz_cinsi);
    get diagnostics v_k = row_count;

    update public.hesap set doviz_cinsi = public.fn_doviz_iso(doviz_cinsi)
     where doviz_cinsi <> public.fn_doviz_iso(doviz_cinsi);
    get diagnostics v_h = row_count;

    -- '7591' gibi para birimi olmayan degerler: acilis devri satirlari, TL
    update public.mali_hareket set doviz_cinsi = 'TL', doviz_kuru = 1
     where doviz_cinsi !~ '^[A-Z]{2,6}$' or doviz_cinsi ~ '^[0-9]+$';
    get diagnostics v_m = row_count;

    update public.mali_hareket set doviz_cinsi = public.fn_doviz_iso(doviz_cinsi)
     where doviz_cinsi <> public.fn_doviz_iso(doviz_cinsi);

    update public.kasa_islem set doviz_cinsi = public.fn_doviz_iso(doviz_cinsi)
     where doviz_cinsi <> public.fn_doviz_iso(doviz_cinsi);
    update public.kasa_islem set karsi_doviz_cinsi = public.fn_doviz_iso(karsi_doviz_cinsi)
     where karsi_doviz_cinsi <> '' and karsi_doviz_cinsi <> public.fn_doviz_iso(karsi_doviz_cinsi);
    update public.cek_senet set doviz_cinsi = public.fn_doviz_iso(doviz_cinsi)
     where doviz_cinsi <> public.fn_doviz_iso(doviz_cinsi);
    update public.belge set belge_dovizi = public.fn_doviz_iso(belge_dovizi)
     where belge_dovizi <> public.fn_doviz_iso(belge_dovizi);
    update public.belge_satir set doviz_cinsi = public.fn_doviz_iso(doviz_cinsi)
     where doviz_cinsi <> public.fn_doviz_iso(doviz_cinsi);
    update public.muhasebe_fis_satir set doviz_cinsi = public.fn_doviz_iso(doviz_cinsi)
     where doviz_cinsi <> public.fn_doviz_iso(doviz_cinsi);

    raise notice '083: kur % satir, hesap % satir, bozuk kod % satir duzeltildi', v_k, v_h, v_m;
end $$;

-- --------------------------------------------------------- kur getirici ----
-- p_yon: 1 satis (giris/tahsilat - musteriden doviz aliriz), 2 alis (cikis/odeme),
--        3 efektif satis, 4 efektif alis, 0 = ortalama.
-- O gunun kuru yoksa ONCEKI en yakin gun kullanilir (hafta sonu/tatil).
create or replace function public.fn_doviz_kur_getir(p_cins text, p_tarih date, p_yon smallint default 1)
returns numeric(19,6)
language plpgsql
stable
as $$
declare
    v_cins varchar(6) := public.fn_doviz_iso(p_cins);
    k      record;
begin
    if v_cins = 'TL' then return 1; end if;

    select alis, satis, efektif_alis, efektif_satis into k
      from public.doviz_kur
     where doviz_cinsi = v_cins and tarih <= coalesce(p_tarih, current_date)
     order by tarih desc limit 1;

    if not found then return null; end if;

    return case p_yon
               when 1 then nullif(k.satis, 0)
               when 2 then nullif(k.alis, 0)
               when 3 then coalesce(nullif(k.efektif_satis, 0), nullif(k.satis, 0))
               when 4 then coalesce(nullif(k.efektif_alis, 0), nullif(k.alis, 0))
               else nullif((k.alis + k.satis) / 2, 0)
           end;
end $$;

comment on function public.fn_doviz_kur_getir(text, date, smallint) is
  'Tarihe ait kur; o gun yoksa onceki en yakin gun. p_yon 1 satis / 2 alis / 3-4 efektif / 0 ortalama.';

do $$
declare v_usd numeric; v_bad integer;
begin
    select public.fn_doviz_kur_getir('USD', current_date, 1::smallint) into v_usd;
    select count(*) into v_bad from public.hesap h
     where h.doviz_cinsi <> public.fn_doviz_iso(h.doviz_cinsi);
    raise notice '083 tamam: USD satis kuru %, normalize edilmemis hesap %', v_usd, v_bad;
end $$;

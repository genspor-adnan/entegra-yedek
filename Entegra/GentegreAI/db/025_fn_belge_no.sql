-- ============================================================================
--  Gentegre AI — belge numarasi uretimi (F1-06)
--  025_fn_belge_no.sql
--
--  KURALLAR (plan F1-06, sozlesme §4):
--    1. Numara TRANSACTION ICINDE uretilir; sayac satiri "for update" ile
--       kilitlenir - iki kullanici ayni anda belge kesince CAKISMAZ.
--    2. BOSLUKSUZ akar (e-Belge zorunlulugu): numara ancak kesinlestirmede alinir.
--    3. TASLAK numara TUKETMEZ - taslakta bu fonksiyon hic cagrilmaz.
--    4. Kapsam SUBE bazlidir (019): "belge.belge_no|T<tur>|S<seri>|SUBE<id>".
--       Iki sube ayni anda belge kesince numaralar birbirine karismaz, her sube
--       kendi serisini boslukdsuz akitir.
--
--  DIKKAT: Numara alan transaction ROLLBACK olursa o numara BOSLUGA DUSER.
--    Bu yuzden numara, kaydin en SON adiminda alinir (tum dogrulamalar gectikten
--    sonra); sequence kullanilmaz - sequence rollback'te geri gitmez, boslukluk
--    olusur ve e-Belge kontrolu bunu reddeder.
-- ============================================================================
\set ON_ERROR_STOP on

-- Sayac anahtari: kapsam parcalarindan tek bicimde uretilir.
create or replace function public.fn_belge_no_anahtar(p_tur int, p_seri text, p_sube_id int)
returns text
language sql immutable as $$
    select 'belge.belge_no|T' || p_tur::text ||
           '|S' || coalesce(nullif(btrim(p_seri), ''), '-') ||
           '|SUBE' || coalesce(p_sube_id, 0)::text
$$;

comment on function public.fn_belge_no_anahtar(int, text, int) is
  'Belge numarasi sayac anahtari. Kapsam: belge turu + seri + SUBE (019 karari).';

-- Siradaki numarayi uretir. Cagiran TRANSACTION ICINDE olmalidir.
create or replace function public.fn_belge_no_uret(p_tur int, p_seri text, p_sube_id int,
                                                   p_hane int default 9)
returns text
language plpgsql as $$
declare
    v_anahtar text := public.fn_belge_no_anahtar(p_tur, p_seri, p_sube_id);
    v_no      bigint;
begin
    -- Sayac satiri yoksa acilir; varsa KILITLENIR (for update) - ayni anda ikinci
    --   transaction bu satiri bekler, boylece ayni numara iki kez verilmez.
    insert into public.belge_no_sayac (anahtar, tablo_adi, alan_adi, kapsam, son_no)
    values (v_anahtar, 'belge', 'belge_no',
            'T' || p_tur::text || '|S' || coalesce(nullif(btrim(p_seri), ''), '-') ||
            '|SUBE' || coalesce(p_sube_id, 0)::text, 0)
    on conflict (anahtar) do nothing;

    select son_no into v_no
      from public.belge_no_sayac
     where anahtar = v_anahtar
       for update;

    v_no := coalesce(v_no, 0) + 1;

    update public.belge_no_sayac
       set son_no = v_no, guncelleme = now()::timestamp
     where anahtar = v_anahtar;

    return lpad(v_no::text, p_hane, '0');
end $$;

comment on function public.fn_belge_no_uret(int, text, int, int) is
  'Siradaki belge numarasi (sifir dolgulu). TRANSACTION ICINDE cagrilir, satir kilidi altinda BOSLUKSUZ artar. Taslakta CAGRILMAZ.';

-- ------------------------------------------------- mevcut numaralarla hizala ----
-- Goc sonrasi sayac 0'da kalirsa yeni belge "000000001" alir ve mevcut numarayla
--   cakisir. Her (tur, seri, sube) icin en buyuk SAYISAL numara sayaca yazilir.
--   Alfanumerik numaralar (alis faturasi tedarikcinin numarasi - harf icerebilir)
--   ATLANIR: onlar bizim serimiz degildir.
do $$
declare
    v_satir integer := 0;
begin
    with mevcut as (
        select b.tur, b.belge_seri, b.sube_id,
               max(b.belge_no::bigint) as son_no
          from public.belge b
         where b.belge_no ~ '^[0-9]+$'
           and length(b.belge_no) <= 18
         group by b.tur, b.belge_seri, b.sube_id
    )
    insert into public.belge_no_sayac (anahtar, tablo_adi, alan_adi, kapsam, son_no)
    select public.fn_belge_no_anahtar(m.tur, m.belge_seri, m.sube_id),
           'belge', 'belge_no',
           'T' || m.tur::text || '|S' || coalesce(nullif(btrim(m.belge_seri), ''), '-') ||
           '|SUBE' || coalesce(m.sube_id, 0)::text,
           m.son_no
      from mevcut m
    on conflict (anahtar) do update
       set son_no = greatest(belge_no_sayac.son_no, excluded.son_no),
           guncelleme = now()::timestamp;

    get diagnostics v_satir = row_count;
    raise notice '025 tamam: % sayac satiri mevcut belge numaralariyla hizalandi.', v_satir;
end $$;

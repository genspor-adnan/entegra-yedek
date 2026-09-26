-- =====================================================================
--  916_kimlik_kurali_default_serbest.sql
--  KİMLİK NO DOĞRULAMASI VARSAYILAN KAPALI (kullanıcı: "default doğrulama
--  olmasın"). Önceden 'otomatik' + Türkiye şubesi → 'tc' (T.C. algoritması)
--  ile geliyordu; artık 'otomatik' → 'serbest' (biçim kontrolü yok).
--
--  Doğrulama İSTEYEN kurum, Kurum Profili → "Kimlik no biçimi" alanından
--  "T.C. Kimlik No"yu (ya da özel desen) açıkça seçer.
-- =====================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_kimlik_kurali(p_sube integer default 0)
returns table(bicim character varying, desen character varying, aciklama character varying)
language sql stable as $function$
    with p as (select * from public.fn_kurum_profil(p_sube))
    -- 'otomatik' / boş / null → SERBEST (doğrulama yok). Yalnız açıkça 'tc' /
    --   'desen' / 'serbest' seçilmişse o uygulanır.
    select case when coalesce(nullif(p.kimlik_bicimi, ''), 'otomatik') = 'otomatik'
                then 'serbest'
                else p.kimlik_bicimi end::varchar as bicim,
           p.kimlik_deseni::varchar as desen,
           p.kimlik_aciklama::varchar as aciklama
      from p;
$function$;

do $$ begin raise notice '916 tamam: fn_kimlik_kurali otomatik -> serbest (doğrulama varsayılan kapalı)'; end $$;

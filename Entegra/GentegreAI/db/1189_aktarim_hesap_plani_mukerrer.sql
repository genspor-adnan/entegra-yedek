-- =============================================================================
--  1189  AKTARIM: DELPHI HESAP PLANINDA MÜKERRER KOD
--
--  ZONE geçişi (25.10.2026): Delphi HESAPPLANI'nda aynı kod birden çok satırda ("770" × 3, aynı ad);
--  fn_aktar_ek_hesap_plani (1148) "ux_hesap_plani_kod" ile düşüyor, hesap planı hiç taşınmıyordu.
--  Kod tekil: en küçük ID'li satır alınır, atlanan sayısı 'mukerrer_kod_atlanan' ile döner. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_aktar_ek_hesap_plani()
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare v_e int := 0; v_g int := 0; v_ust int := 0; v_grup int := 0; v_web int := 0; v_n int := 0; v_muk int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);
    -- web'de aynı kod varsa web satırı kalır (TDHP adı korunur)
    select count(*) into v_web from stg.hesapplani s
     where exists (select 1 from public.hesap_plani h where h.kod = btrim(s.hesapkodu)
                     and h.aktarim_kaynak is distinct from 1);

    create temp table if not exists _hp on commit drop as select h.* from public.hesap_plani h with no data;
    truncate _hp;
    -- 1189: Delphi'de AYNI KOD birden çok satırda olabilir (ZONE: 770 üç kez) - kod tekil; en küçük ID'li alınır.
    select count(*) - count(distinct btrim(s.hesapkodu)) into v_muk from stg.hesapplani s
     where coalesce(btrim(s.hesapkodu), '') <> '';
    insert into _hp (aktarim_id, kod, ad, sinif, doviz_cinsi, calisir_mi, durum)
    select distinct on (btrim(s.hesapkodu)) s.id, btrim(s.hesapkodu), left(coalesce(nullif(btrim(s.hesapadi), ''), btrim(s.hesapkodu)), 150),
           case when left(btrim(s.hesapkodu), 1) ~ '^[0-9]$' then left(btrim(s.hesapkodu), 1)::int else 0 end,
           public.fn_aktarim_doviz(s.kur),
           -- Delphi planında alt hesabı olan grup hesaptır (çalışmaz)
           case when exists (select 1 from stg.hesapplani c where btrim(c.hesapkodu) like btrim(s.hesapkodu) || '.%')
                then 0 else 1 end,
           case when coalesce(s.durum, 1) = 0 then 0 else 1 end
      from stg.hesapplani s
     where coalesce(btrim(s.hesapkodu), '') <> ''
       and not exists (select 1 from public.hesap_plani h where h.kod = btrim(s.hesapkodu)
                         and h.aktarim_kaynak is distinct from 1)
     order by btrim(s.hesapkodu), s.id;
    select eklenen, guncellenen into v_e, v_g from public.fn_aktarim_esitle('hesap_plani', 'HESAPPLANI', '_hp',
        array['kod', 'ad', 'sinif', 'doviz_cinsi', 'calisir_mi', 'durum']);

    -- üst hesap ve seviye: koddaki en uzun önek. Zincir (üstü de bu çalıştırmada
    --   eklenen hesap) için değişiklik kalmayana kadar tekrarlanır.
    for i in 1..10 loop
        update public.hesap_plani h set ust_id = u.id, seviye = coalesce(u.seviye, 0) + 1
          from (select h2.id hid,
                       (select p.id from public.hesap_plani p
                         where p.id <> h2.id
                           and (h2.kod like p.kod || '.%' or (h2.kod !~ '\.' and length(h2.kod) = 3 and p.kod in (left(h2.kod, 2), left(h2.kod, 1))))
                         order by length(p.kod) desc limit 1) uid
                  from public.hesap_plani h2 where h2.aktarim_kaynak = 1 and h2.aktarim_tablo = 'HESAPPLANI') x
          join public.hesap_plani u on u.id = x.uid
         where h.id = x.hid and (h.ust_id is distinct from u.id or h.seviye is distinct from coalesce(u.seviye, 0) + 1);
        get diagnostics v_n = row_count;
        v_ust := v_ust + v_n;
        exit when v_n = 0;
    end loop;

    -- Delphi alt hesabı eklenen WEB hesabı grup olur (çalışmaz)
    update public.hesap_plani h set calisir_mi = 0
     where h.calisir_mi <> 0 and h.aktarim_kaynak is distinct from 1
       and exists (select 1 from public.hesap_plani c where c.ust_id = h.id);
    get diagnostics v_grup = row_count;

    return jsonb_build_object('eklenen', v_e, 'guncellenen', v_g, 'web_kodu_korunan', v_web,
                              'ust_baglanan', v_ust, 'gruba_donen', v_grup, 'mukerrer_kod_atlanan', v_muk);
end $function$;

-- ============================================================================
--  389 - fn_prim_kademe_uygula DUZELTMESI
--
--  388'de iki hata vardi:
--
--  1) `count(*)` BIGINT doner, `fn_prim_kademe_orani` INTEGER bekliyor -
--     "function does not exist" ile patliyordu. Acik cast.
--
--  2) IC DONGU DIS DONGUNUN degiskenini eziyordu: ikisi de `r` kullaniyordu,
--     yani ic dongu basladigi anda `r.oran_tipi` ve `r.plan_satir_id`
--     KAYBOLUYORDU. Sessiz ve sinsi: dis dongunun okumasi gereken degerler
--     ic dongunun satirindan geliyordu. Ayri degisken adlari (`p` / `h`).
-- ============================================================================

create or replace function public.fn_prim_kademe_uygula(
    p_taraf_id integer, p_bas date, p_bit date)
returns integer
language plpgsql
as $function$
declare
    p        record;   -- plan satiri + donemdeki adet
    h        record;   -- o plan satirina ait hakedis satirlari
    v_oran   numeric(19,4);
    v_yeni   numeric(19,4);
    v_sayac  integer := 0;
begin
    for p in
        select hs.plan_satir_id,
               count(*)::integer as adet,
               min(ps.oran_tipi) as oran_tipi
          from public.hakedis_satir hs
          join public.prim_plani_satir ps on ps.id = hs.plan_satir_id
         where hs.taraf_id = p_taraf_id
           and hs.hakedis_id is null
           and hs.durum in (1, 2)
           and hs.tarih between p_bas and p_bit
           and exists (select 1 from public.prim_plani_kademe k
                        where k.satir_id = ps.id)
         group by hs.plan_satir_id
    loop
        v_oran := public.fn_prim_kademe_orani(p.plan_satir_id, p.adet);
        if v_oran is null then continue; end if;

        for h in
            select hs.id, hs.taban, hs.pay_yuzde
              from public.hakedis_satir hs
             where hs.taraf_id = p_taraf_id
               and hs.hakedis_id is null
               and hs.durum in (1, 2)
               and hs.tarih between p_bas and p_bit
               and hs.plan_satir_id = p.plan_satir_id
        loop
            -- SABIT TUTARLI satirda (oran_tipi 2) kademe TUTARI verir;
            --   yuzdede oran yerine gecer ve taban uzerinden hesaplanir.
            v_yeni := case when p.oran_tipi = 2
                           then v_oran
                           else round(h.taban * v_oran / 100.0, 2) end;
            v_yeni := round(v_yeni * coalesce(h.pay_yuzde, 100) / 100.0, 2);

            update public.hakedis_satir
               set deger = v_oran, tutar = v_yeni
             where id = h.id and tutar is distinct from v_yeni;
            if found then v_sayac := v_sayac + 1; end if;
        end loop;
    end loop;
    return v_sayac;
end $function$;

-- ============================================================================
--  390 - KADEME, PLAN SATIRININ ALT/UST SINIRINI EZIYORDU
--
--  Sinirlar iki ayri yolda uygulaniyordu, ama biri eksikti:
--
--    uretim   (fn_prim_uret_belge, 339) : pay yuzdesi -> alt sinir -> ust sinir
--    kapanis  (fn_prim_kademe_uygula)   : pay yuzdesi -> (HICBIRI)
--
--  Donem kapanisinda tutar `taban * kademe_orani` ile YENIDEN yaziliyor, o
--  yazimda sinirlar okunmuyordu. Sonuc iki yonde de kacak:
--
--    ust_sinir 50, kademe %7, taban 1000 -> satir 70,00 olur (sinir asilir)
--    alt_sinir 100, kademe %7, taban 1000 -> satir 70,00 olur (altina dusulur)
--
--  Kademe eklenene kadar (388) tutari sonradan degistiren baska yol yoktu,
--  bu yuzden sorun gorunmuyordu.
--
--  Sira URETIM YOLUNDAKI ile ayni: once pay yuzdesi, sonra alt, sonra ust.
--  Ters sirada (once sinir, sonra pay) yarim paya dusen kisi ust siniri
--  hicbir zaman goremezdi.
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
               min(ps.oran_tipi) as oran_tipi,
               min(ps.alt_sinir) as alt_sinir,
               min(ps.ust_sinir) as ust_sinir
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

            -- 390: uretim yolundaki (339) ile ayni sira ve ayni kosullar.
            if p.alt_sinir is not null and v_yeni < p.alt_sinir then
                v_yeni := p.alt_sinir;
            end if;
            if p.ust_sinir is not null and v_yeni > p.ust_sinir then
                v_yeni := p.ust_sinir;
            end if;

            update public.hakedis_satir
               set deger = v_oran, tutar = v_yeni
             where id = h.id and tutar is distinct from v_yeni;
            if found then v_sayac := v_sayac + 1; end if;
        end loop;
    end loop;
    return v_sayac;
end $function$;

comment on function public.fn_prim_kademe_uygula(integer, date, date) is
  'Donem kapanmadan once kademeli plan satirlarini ADET bazinda yeniden '
  'degerler (388). Kalem aninda yazilan oran ONIZLEMEDIR; kesin oran budur. '
  'Plan satirinin alt/ust siniri uretim yolundaki sirayla uygulanir (390).';

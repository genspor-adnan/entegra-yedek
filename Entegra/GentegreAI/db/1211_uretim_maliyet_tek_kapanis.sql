\set ON_ERROR_STOP on
-- ============================================================================
--  1211 — K57: üretim maliyet kapanışı emir başına TEK
--
--  Kod inceleme 30.10.2026 K57: UretimUclari maliyet kapanışı "var mı" diye
--  sayıp ekliyor (oku-sonra-yaz); iki eş zamanlı kapanış iki maliyet satırı
--  yazabiliyor, benzersiz kısıt yoktu. Dev DB'de çift kayıt yok (sayıldı);
--  müşteri DB'sinde varsa en yenisi kalır, eskileri yedeğe alınır.
-- ============================================================================
begin;

create table if not exists public._yedek_uretim_maliyet_1211 (like public.uretim_maliyet including all);
insert into public._yedek_uretim_maliyet_1211
select m.* from public.uretim_maliyet m
 where m.id <> (select max(id) from public.uretim_maliyet x where x.emir_id = m.emir_id);
delete from public.uretim_maliyet m
 where m.id <> (select max(id) from public.uretim_maliyet x where x.emir_id = m.emir_id);

create unique index if not exists ux_uretim_maliyet_emir on public.uretim_maliyet (emir_id);

do $$
begin
    if (select count(*) from public._yedek_uretim_maliyet_1211) = 0 then
        drop table public._yedek_uretim_maliyet_1211;
    else
        raise notice '1211: % çift maliyet satırı _yedek_uretim_maliyet_1211''e alındı',
                     (select count(*) from public._yedek_uretim_maliyet_1211);
    end if;
end $$;

commit;

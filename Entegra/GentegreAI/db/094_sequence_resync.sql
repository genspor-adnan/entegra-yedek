-- 094 - Sequence resync (tekrar tekrar calistirilabilir)
--
-- MSSQL'den veri kopyalanirken id'ler ACIK deger olarak yazilir; PG sequence'i
-- bu sirada ilerlemez. Sonra uygulamanin ilk INSERT'i var olan id'ye carpar:
--   duplicate key value violates unique constraint "<tablo>_pkey"
-- (gercek vaka: depo_id_seq 1'de kalmisti, tablo max 13; "Ekle" patliyordu.)
--
-- Bu script sequence'i olan TUM public tablolari tarar ve geride kalanlari
-- max(id)'ye ceker. Veriyi degistirmez, ileride olan sequence'e dokunmaz.
-- HER seed / goc sonrasi calistirilmali.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    r record;
    v_max bigint;
    v_last bigint;
    v_duzeltilen int := 0;
    v_tum int := 0;
begin
    for r in
        select c.oid::regclass::text as tablo, a.attname as kolon,
               pg_get_serial_sequence(c.oid::regclass::text, a.attname) as seq
          from pg_class c
          join pg_namespace n on n.oid = c.relnamespace
          join pg_attribute a on a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
         where n.nspname = 'public'
           and c.relkind = 'r'
           and pg_get_serial_sequence(c.oid::regclass::text, a.attname) is not null
         order by 1
    loop
        v_tum := v_tum + 1;
        execute format('select coalesce(max(%I), 0) from %s', r.kolon, r.tablo) into v_max;
        select coalesce(last_value, 0) into v_last
          from pg_sequences
         where schemaname = 'public' and sequencename = split_part(r.seq, '.', 2);

        if v_max > coalesce(v_last, 0) then
            perform setval(r.seq, v_max);
            v_duzeltilen := v_duzeltilen + 1;
            raise notice 'resync % (%): % -> %', r.tablo, r.kolon, v_last, v_max;
        end if;
    end loop;

    raise notice '094 tamam: % sequence tarandi, % duzeltildi', v_tum, v_duzeltilen;
end $$;

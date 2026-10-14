-- ============================================================================
--  1097  KALAN ZAMAN DAMGALARI timestamptz  (667'nin devamı)
--
--  Kullanıcı (14.10.2026): saat dilimi sorunu "düzelt", "şube zaman dilimini baz al".
--
--  667 bütün `timestamp` kolonlarını timestamptz yapmıştı (AN saklanır, okuyan
--  kendi / şubesinin saat diliminde görür). Ondan sonra eklenen modüller (çağrı
--  merkezi, sterilizasyon, İSG, form, teleradyoloji, döküm, portal daveti, lab
--  akılcı istem, personel hareketi...) yine `timestamp` + `now()` kullandı: 114
--  kolon. Bunlara UTC duvar saati yazılıyor, web saatsiz değeri yerel sanıyor -
--  ekranda 3 saat geri (gerçek 11:32, kayıt 08:32).
--
--  DÖNÜŞÜM KURALI (envanter 14.10.2026, her kolonun yazanı tek tek tarandı):
--   * 112 kolon now()/now()::timestamp ya da UTC'ye çevrilmiş kart değeri -> değer,
--     YAZILDIĞI OTURUMUN saat diliminde duvar saatidir. Veritabanının saat dilimi
--     kurulumdan kuruluma farklı (gentegre_ai UTC - 667; 129 ile kurulanlar
--     Europe/Istanbul): göç oturumu veritabanının kendi saat dilimiyle açılır,
--     dönüşüm `AT TIME ZONE current_setting('TimeZone')` - hangisiyse o.
--   * cagri.geri_arama ve telerad_gelen.onay_zamani YEREL duvar saati (tarayıcıdan
--     gelen tarih / HL7 göndericisinin saati): satırın ŞUBESİNİN saat dilimiyle.
--  Sonra veritabanının saat dilimi her kurulumda UTC (667'nin kuralı, ama adı
--  sabit yazmadan). Saklanan an UTC; "bugün" ve gösterim isteğin şubesinin saat
--  diliminde (API, VeriKaynagi).
--
--  GÖRÜNÜMLER: 667 gibi - hepsi yedeklenir, düşürülür, dönüşümden sonra aynı
--  tanımla geri kurulur (sıra bilinmediği için tekrar denenir).
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create temporary table _kaynak_tz on commit drop as select current_setting('TimeZone') as tz;

-- Şubenin saat dilimi - TEK KAYNAK (666: sube.zaman_dilimi, IANA adı). Şube yoksa /
-- boşsa kurumun varsayılan şubesininki, o da yoksa Europe/Istanbul.
create or replace function public.fn_sube_zaman_dilimi(p_sube_id integer)
returns text language sql stable as $f$
    select coalesce(
        (select nullif(s.zaman_dilimi, '') from public.sube s where s.id = p_sube_id),
        (select nullif(s.zaman_dilimi, '') from public.sube s where s.aktif = 1 order by s.id limit 1),
        'Europe/Istanbul')
$f$;
comment on function public.fn_sube_zaman_dilimi(integer) is
    '1097: subenin IANA saat dilimi (sube.zaman_dilimi); yoksa ilk aktif subeninki, o da yoksa Europe/Istanbul.';

-- ---------------------------------------------------- 1) görünümleri yedekle/düşür
create table if not exists public._yedek_view_1097 (
    sira       serial primary key,
    ad         text not null,
    tanim      text not null,
    kaydedildi timestamptz not null default now()
);
truncate table public._yedek_view_1097;

insert into public._yedek_view_1097 (ad, tanim)
select c.oid::regclass::text, pg_get_viewdef(c.oid, true)
  from pg_class c join pg_namespace n on n.oid = c.relnamespace and n.nspname = 'public'
 where c.relkind = 'v'
 order by 1;

do $$
declare r record;
begin
    for r in select ad from public._yedek_view_1097 order by sira desc loop
        execute format('drop view if exists %s cascade', r.ad);
    end loop;
end $$;

-- ------------------------------------------------------------ 2) kolonlar
do $$
declare
    r record;
    v_tz text := (select tz from _kaynak_tz);
    v_using text;
    v_n integer := 0;
begin
    for r in
        select c.table_name, c.column_name, c.column_default
          from information_schema.columns c
          join pg_class pc on pc.relname = c.table_name
          join pg_namespace pn on pn.oid = pc.relnamespace and pn.nspname = 'public'
         where c.table_schema = 'public'
           and c.data_type = 'timestamp without time zone'
           and pc.relkind in ('r', 'p')
           and c.is_generated = 'NEVER'
           and not exists (
                 select 1 from pg_partitioned_table pt
                   join pg_attribute a on a.attrelid = pt.partrelid
                                      and a.attnum = any (string_to_array(pt.partattrs::text, ' ')::smallint[])
                  where pt.partrelid = pc.oid and a.attname = c.column_name)
           and not exists (select 1 from pg_inherits i where i.inhrelid = pc.oid)
         order by c.table_name, c.column_name
    loop
        if r.column_default is not null then
            execute format('alter table public.%I alter column %I drop default', r.table_name, r.column_name);
        end if;

        -- Yerel duvar saati tutan iki kolon: satırın şubesinin saat dilimi.
        if (r.table_name, r.column_name) in (('cagri', 'geri_arama'), ('telerad_gelen', 'onay_zamani')) then
            v_using := format('%I at time zone public.fn_sube_zaman_dilimi(sube_id)', r.column_name);
        else
            v_using := format('%I at time zone %L', r.column_name, v_tz);
        end if;
        execute format('alter table public.%I alter column %I type timestamptz using %s',
                       r.table_name, r.column_name, v_using);
        v_n := v_n + 1;

        if r.column_default is not null then
            if r.column_default ilike '%now()%' then
                execute format('alter table public.%I alter column %I set default now()', r.table_name, r.column_name);
            else
                execute format('alter table public.%I alter column %I set default %s',
                               r.table_name, r.column_name, r.column_default);
            end if;
        end if;
    end loop;
    raise notice '1097: % kolon timestamptz oldu (kaynak saat dilimi %)', v_n, v_tz;
end $$;

-- ------------------------------------------------------- 3) görünümleri geri kur
do $$
declare r record; v_kalan integer; v_onceki integer := -1; v_hata text := '';
begin
    create temporary table _kalan_view_1097 on commit drop as
        select ad, tanim from public._yedek_view_1097 order by sira;
    loop
        v_kalan := 0;
        for r in select ad, tanim from _kalan_view_1097 loop
            begin
                execute format('create or replace view %s as %s', r.ad, r.tanim);
                delete from _kalan_view_1097 where ad = r.ad;
            exception when others then
                v_kalan := v_kalan + 1;
                v_hata := r.ad || ': ' || sqlerrm;
            end;
        end loop;
        exit when v_kalan = 0;
        if v_kalan = v_onceki then
            raise exception '1097: % gorunum kurulamadi. Son hata -> %', v_kalan, v_hata;
        end if;
        v_onceki := v_kalan;
    end loop;
end $$;

-- ------------------------------------------- 4) veritabanı saat dilimi: UTC
-- Saklanan an UTC; oturumun saat dilimini API isteğin şubesine göre verir.
do $$ begin execute format('alter database %I set timezone to %L', current_database(), 'UTC'); end $$;

do $$
declare v_kalan integer;
begin
    select count(*) into v_kalan from information_schema.columns c
      join pg_class pc on pc.relname = c.table_name
      join pg_namespace pn on pn.oid = pc.relnamespace and pn.nspname = 'public'
     where c.table_schema = 'public' and c.data_type = 'timestamp without time zone' and pc.relkind in ('r', 'p');
    if v_kalan > 0 then raise warning '1097: % kolon hala timestamp (bolum anahtari olabilir)', v_kalan; end if;
end $$;

commit;

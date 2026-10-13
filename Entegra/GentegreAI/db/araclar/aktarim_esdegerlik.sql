-- =============================================================================
--  aktarim_esdegerlik.sql - Delphi aktarım fonksiyonları ↔ göç eşdeğerliği
--  (dokuman/18 §11.4 adım 3)
--
--  YALNIZ BİR KOPYA veritabanında çalıştırılır (dev'in pg_dump kopyası) -
--  aktarılan kayıtları günceller. Akış:
--    1) göçle gelmiş kayıtları işaretle (fn_aktarim_kaynak_isaretle - id + kod)
--    2) işaretli kayıtların ÖNCEKİ halinin fotoğrafı (esd_* tabloları)
--    3) stg'deki BÜTÜN Delphi verisini fn_aktar_* ile aynı kayıtların üzerine aktar
--    4) önce / sonra farkı kolon kolon -> esd_fark
--  Beklenen farklar (göçten bilerek ayrılan kurallar, 1081 başlığı):
--    ekleme/degistirme/d_tarih (saat dilimi), temsilci/ekleyen/degistiren (boş).
--  Çalıştırma: psql -d gentegre_ai_aktarim -f aktarim_esdegerlik.sql
-- =============================================================================
\set ON_ERROR_STOP on
\pset pager off

select tablo, toplam, eslesen, isaretlenen from public.fn_aktarim_kaynak_isaretle(true)
 where tablo in ('taraf', 'taraf_adres', 'depo');

drop table if exists esd_taraf, esd_adres, esd_depo, esd_fark;
create table esd_taraf as select * from public.taraf       where aktarim_kaynak = 1;
create table esd_adres as select * from public.taraf_adres where aktarim_kaynak = 1;
create table esd_depo  as select * from public.depo        where aktarim_kaynak = 1;

-- ----------------------------------------------------------- 3) aktar ---
\echo '--- depo'
select public.fn_aktar_depo(jsonb_build_object('U', jsonb_build_object(
    'DEPOLAR', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.depolar d))));

\echo '--- cari (500er cari, her paket kendi adres + bilgi satırlarıyla)'
do $$
declare
    v_bas int := -2147483648; v_son int; v_sonuc jsonb; v_top jsonb := '{}';
    k text;
begin
    loop
        select max(id) into v_son from (select id from stg.rehber where id > v_bas order by id limit 500) x;
        exit when v_son is null;
        v_sonuc := public.fn_aktar_cari(jsonb_build_object('U', jsonb_build_object(
            -- takma ad 'rh': stg.rehber'de 'r' adinda bir KOLON var, to_jsonb(r) onu cevirirdi
            'REHBER',         (select coalesce(jsonb_agg(to_jsonb(rh)), '[]') from stg.rehber rh
                                where rh.id > v_bas and rh.id <= v_son),
            'REHBERILETISIM', (select coalesce(jsonb_agg(to_jsonb(i)), '[]') from stg.rehberiletisim i
                                where i.rehberid > v_bas and i.rehberid <= v_son),
            'REHBERBILGI',    (select coalesce(jsonb_agg(to_jsonb(b)), '[]') from stg.rehberbilgi b
                                where (b.yeri = 2 and b.yer_id > v_bas and b.yer_id <= v_son)
                                   or (b.yeri = 1 and b.yer_id in (select i.id from stg.rehberiletisim i
                                        where i.rehberid > v_bas and i.rehberid <= v_son))))));
        for k in select jsonb_object_keys(v_sonuc) loop
            v_top := jsonb_set(v_top, array[k], to_jsonb(coalesce((v_top->>k)::int, 0) + (v_sonuc->>k)::int));
        end loop;
        v_bas := v_son;
    end loop;
    raise notice 'cari toplam: %', v_top;
end $$;

-- ---------------------------------------------------------- 4) fark ---
create table esd_fark (tablo text, kolon text, fark int, ornek text);

do $$
declare
    r record; v_fark int; v_ornek text;
begin
    for r in
        select 'taraf' as tablo, 'esd_taraf' as once, c.column_name as kolon
          from information_schema.columns c
         where c.table_schema = 'public' and c.table_name = 'taraf'
           and c.column_name not in ('id', 'resim', 'aktarim_kaynak', 'aktarim_tablo', 'aktarim_id')
        union all
        select 'taraf_adres', 'esd_adres', c.column_name
          from information_schema.columns c
         where c.table_schema = 'public' and c.table_name = 'taraf_adres'
           and c.column_name not in ('id', 'aktarim_kaynak', 'aktarim_tablo', 'aktarim_id')
        union all
        select 'depo', 'esd_depo', c.column_name
          from information_schema.columns c
         where c.table_schema = 'public' and c.table_name = 'depo'
           and c.column_name not in ('id', 'aktarim_kaynak', 'aktarim_tablo', 'aktarim_id')
    loop
        execute format(
            'select count(*), min(format(''id %%s: %%s -> %%s'', o.id, left(o.%1$I::text, 40), left(s.%1$I::text, 40))) '
            '  from %2$I o join public.%3$I s on s.id = o.id '
            ' where o.%1$I is distinct from s.%1$I', r.kolon, r.once, r.tablo)
        into v_fark, v_ornek;
        if v_fark > 0 then
            insert into esd_fark values (r.tablo, r.kolon, v_fark, v_ornek);
        end if;
    end loop;
end $$;

\echo '--- yeni eklenen (işaretli göç kaydıyla eşleşmeyen Delphi satırı -> yeni web kaydı)'
select 'taraf' as tablo, count(*) as yeni from public.taraf t
 where t.aktarim_kaynak = 1 and not exists (select 1 from esd_taraf e where e.id = t.id)
union all
select 'taraf_adres', count(*) from public.taraf_adres a
 where a.aktarim_kaynak = 1 and not exists (select 1 from esd_adres e where e.id = a.id)
union all
select 'depo', count(*) from public.depo d
 where d.aktarim_kaynak = 1 and not exists (select 1 from esd_depo e where e.id = d.id);

\echo '--- kolon farkları (önce = göç + sonraki migrationlar + dev düzenlemeleri, sonra = fn_aktar)'
select tablo, kolon, fark, ornek from esd_fark order by tablo, fark desc;

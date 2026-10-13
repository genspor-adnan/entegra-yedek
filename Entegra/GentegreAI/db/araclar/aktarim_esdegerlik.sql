-- =============================================================================
--  aktarim_esdegerlik.sql - Delphi aktarım fonksiyonları ↔ göç eşdeğerliği
--  (dokuman/18 §11.4 adım 3)
--
--  YALNIZ BİR KOPYA veritabanında çalıştırılır (dev'in pg_dump kopyası) -
--  aktarılan kayıtları günceller. Akış:
--    1) göçle gelmiş kayıtları işaretle (fn_aktarim_kaynak_isaretle - id + ikinci alan)
--    2) işaretli kayıtların ÖNCEKİ halinin fotoğrafı (esd.<tablo>)
--    3) stg'deki BÜTÜN Delphi verisini fn_aktar_* ile aynı kayıtların üzerine aktar
--    4) önce / sonra farkı kolon kolon -> esd.fark; yeni eklenenler -> esd.yeni
--  Yeni dilim eklenince: 3)'e çağrısı, aşağıdaki tablo listesine adı eklenir.
--  Çalıştırma: psql -d gentegre_ai_aktarim -f aktarim_esdegerlik.sql
-- =============================================================================
\set ON_ERROR_STOP on
\pset pager off

select tablo, kaynak, toplam, eslesen, isaretlenen from public.fn_aktarim_kaynak_isaretle(true)
 where coalesce(eslesen, 0) > 0 or isaretlenen > 0;

drop schema if exists esd cascade;
create schema esd;
create table esd.tablolar (ad text primary key);
insert into esd.tablolar values
    ('depo'), ('taraf'), ('taraf_adres'),
    ('doviz_kur'), ('masraf_merkezi'), ('proje'), ('hizmet'), ('masraf'), ('hizmet_fiyat'), ('masraf_fiyat'),
    ('stok'), ('stok_barkod'), ('stok_fiyat'), ('stok_seri_lot'), ('hesap'), ('kredi');

do $$
declare t text;
begin
    for t in select ad from esd.tablolar loop
        execute format('create table esd.%I as select * from public.%I where aktarim_kaynak = 1', t, t);
    end loop;
end $$;

-- ----------------------------------------------------------- 3) aktar ---
\echo '--- depo, döviz, masraf merkezi, proje'
select public.fn_aktar_depo(jsonb_build_object('U', jsonb_build_object(
    'DEPOLAR', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.depolar d))));
select public.fn_aktar_doviz(jsonb_build_object('U', jsonb_build_object(
    'DOVIZ', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.doviz d))));
select public.fn_aktar_masraf_merkezi(jsonb_build_object('U', jsonb_build_object(
    'SRMMERKEZI', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.srmmerkezi d))));

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
    raise notice 'cari: %', v_top;
end $$;

\echo '--- proje, kalem, stok, hesap (cariden sonra: referanslar cariye bağlı)'
select public.fn_aktar_proje(jsonb_build_object('U', jsonb_build_object(
    'PROJELER', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.projeler d))));
select public.fn_aktar_kalem(jsonb_build_object('U', jsonb_build_object(
    'MASRAFGELIR', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.masrafgelir d),
    'FIYATLAR',    (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.fiyatlar d))));

do $$
declare
    v_bas int := -2147483648; v_son int; v_sonuc jsonb; v_top jsonb := '{}'; k text;
begin
    loop
        select max(id) into v_son from (select id from stg.stoklar where id > v_bas order by id limit 500) x;
        exit when v_son is null;
        v_sonuc := public.fn_aktar_stok(jsonb_build_object('U', jsonb_build_object(
            'STOKLAR',     (select coalesce(jsonb_agg(to_jsonb(s)), '[]') from stg.stoklar s     where s.id > v_bas and s.id <= v_son),
            'STOKBARKOD',  (select coalesce(jsonb_agg(to_jsonb(s)), '[]') from stg.stokbarkod s  where s.stokid > v_bas and s.stokid <= v_son),
            'STOKFIYAT',   (select coalesce(jsonb_agg(to_jsonb(s)), '[]') from stg.stokfiyat s   where s.stokid > v_bas and s.stokid <= v_son),
            'STOKSERILOT', (select coalesce(jsonb_agg(to_jsonb(s)), '[]') from stg.stokserilot s where s.stokid > v_bas and s.stokid <= v_son))));
        for k in select jsonb_object_keys(v_sonuc) loop
            v_top := jsonb_set(v_top, array[k], to_jsonb(coalesce((v_top->>k)::int, 0) + (v_sonuc->>k)::int));
        end loop;
        v_bas := v_son;
    end loop;
    raise notice 'stok: %', v_top;
end $$;

select public.fn_aktar_hesap(jsonb_build_object('U', jsonb_build_object(
    'BANKAHESAPLAR', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.bankahesaplar d),
    'KASALAR',       (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.kasalar d),
    'POS',           (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.pos d),
    'KREDIKARTI',    (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.kredikarti d),
    'KREDILER',      (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from stg.krediler d))));

-- ---------------------------------------------------------- 4) fark ---
create table esd.fark (tablo text, kolon text, fark int, ornek text);
create table esd.yeni (tablo text, yeni int);

do $$
declare
    t text; c text; v_fark int; v_ornek text; v_yeni int;
begin
    for t in select ad from esd.tablolar loop
        execute format('select count(*) from public.%I x where x.aktarim_kaynak = 1 '
                       'and not exists (select 1 from esd.%I e where e.id = x.id)', t, t) into v_yeni;
        insert into esd.yeni values (t, v_yeni);
        for c in select column_name from information_schema.columns
                  where table_schema = 'public' and table_name = t
                    and column_name not in ('id', 'resim', 'aktarim_kaynak', 'aktarim_tablo', 'aktarim_id',
                                            'degistirme_tarihi')
        loop
            execute format(
                'select count(*), min(format(''id %%s: %%s -> %%s'', o.id, left(o.%1$I::text, 40), left(s.%1$I::text, 40))) '
                '  from esd.%2$I o join public.%2$I s on s.id = o.id '
                ' where o.%1$I is distinct from s.%1$I', c, t)
            into v_fark, v_ornek;
            if v_fark > 0 then insert into esd.fark values (t, c, v_fark, v_ornek); end if;
        end loop;
    end loop;
end $$;

\echo '--- işaretli (göç) / yeni eklenen'
select y.tablo, (select count(*) from information_schema.tables where false) as _,
       y.yeni
  from esd.yeni y order by 1;
\echo '--- kolon farkları (önce = göç + sonraki migrationlar + dev düzenlemeleri, sonra = fn_aktar)'
select tablo, kolon, fark, ornek from esd.fark order by tablo, fark desc;

-- ============================================================================
--  UYGULAMA ROLÜ (kod inceleme raporu 28.10.2026 B07)
--
--  API veritabanına süper kullanıcı (postgres) ile değil, KURULUMA ÖZEL ve
--  yalnız kendi DB'sinde veri yetkisi olan bir rolle bağlanır. API'deki bir açık
--  ya da sızan bağlantı bilgisi; rol / DB / tablo oluşturmaya, başka kurulumun
--  veritabanına ya da sunucu dosyalarına (COPY ... PROGRAM) uzanamaz.
--
--  Göçler (goc_uygula.sh) ve yedek (pg_dump) postgres ile çalışmaya DEVAM EDER -
--  şema değişikliği yönetim işidir, uygulamanın değil.
--
--  Her yayında (sunucu-guncelle.sh) ve kalite kapısında (yayinla.ps1, yerel test
--  DB'si) ÇALIŞTIRILIR; tekrar çalışması güvenlidir. Her seferinde kısıtları
--  yeniden yazar - elle verilmiş fazla yetki / üyelik bir sonraki yayında söner.
--
--  Değişkenler (psql):
--     db      kurulum veritabanı (büyük harfli olabilir: BILIM, FETA...)
--     rol     uygulama rolü (sunucu-guncelle.sh: <db küçük harf>_uyg)
--     parola  rolün parolası - KOMUT SATIRINDA DEĞİL, stdin'in ilk satırında
--             \set ile gelir (ps çıktısında görünmesin)
--
--  Çalışma anındaki DDL taraması (28.10.2026): API kodu DDL çalıştırmıyor;
--  DB fonksiyonlarının DDL'i yalnız GEÇİCİ tablolarda (fn_aktar_*,
--  fn_belge_diptoplam... "_x" geçici tabloları - TEMP hakkı) ve setval
--  (sequence UPDATE hakkı). Bu ikisi aşağıda verilir.
-- ============================================================================
\set ON_ERROR_STOP on
\set QUIET on

-- --------------------------------------------------------------- rol ----
select format('create role %I login', :'rol')
 where not exists (select 1 from pg_roles where rolname = :'rol') \gexec

-- Kısıtlar HER çalışmada yeniden yazılır (elle açılmış yetki kalıcı olmasın).
alter role :"rol" with login nosuperuser nocreatedb nocreaterole noreplication nobypassrls
    inherit connection limit 200 password :'parola';

-- Hiçbir role üye değil (pg_read_server_files, pg_write_all_data... dahil).
select format('revoke %I from %I', g.rolname, :'rol')
  from pg_auth_members m
  join pg_roles g on g.oid = m.roleid
  join pg_roles u on u.oid = m.member
 where u.rolname = :'rol' \gexec

-- ----------------------------------------------------------- veritabani ----
-- PUBLIC'in CONNECT hakkı bu DB'den alınır: başka kurulumun uygulama rolü bu
--   DB'ye bağlanamaz (her kurulum yayınlandıkça kendi DB'sini kapatır).
--   Süper kullanıcı (göç, yedek) etkilenmez.
revoke connect on database :"db" from public;
grant connect, temporary on database :"db" to :"rol";

-- ----------------------------------------------------------- şemalar ----
-- public + stg (Delphi aktarım ara tabloları). CREATE hakkı YOK: uygulama
--   kalıcı nesne oluşturamaz.
select format('revoke create on schema %I from public, %I', n.nspname, :'rol'),
       format('grant usage on schema %I to %I', n.nspname, :'rol'),
       format('grant select, insert, update, delete on all tables in schema %I to %I', n.nspname, :'rol'),
       format('grant usage, select, update on all sequences in schema %I to %I', n.nspname, :'rol'),
       format('grant execute on all routines in schema %I to %I', n.nspname, :'rol'),
       -- Göçlerin (postgres) bundan SONRA oluşturacağı nesneler de aynı yetkiyle doğar.
       format('alter default privileges for role postgres in schema %I grant select, insert, update, delete on tables to %I', n.nspname, :'rol'),
       format('alter default privileges for role postgres in schema %I grant usage, select, update on sequences to %I', n.nspname, :'rol'),
       format('alter default privileges for role postgres in schema %I grant execute on routines to %I', n.nspname, :'rol')
  from pg_namespace n
 where n.nspname in ('public', 'stg') \gexec

-- Göç defteri uygulamanın değil: yalnız okunur.
select format('revoke insert, update, delete, truncate on public.goc_gecmisi from %I', :'rol')
 where to_regclass('public.goc_gecmisi') is not null \gexec

-- ------------------------------------------------------------- doğrulama ----
-- Rol yanlış kurulduysa yayın burada DURUR (API eski haliyle kalır).
select set_config('gentegre.uyg_rol', :'rol', false) \gset
do $$
declare
    v_rol text := current_setting('gentegre.uyg_rol');
    r record;
begin
    select rolsuper, rolcreatedb, rolcreaterole, rolreplication, rolbypassrls into r
      from pg_roles where rolname = v_rol;
    if r.rolsuper or r.rolcreatedb or r.rolcreaterole or r.rolreplication or r.rolbypassrls then
        raise exception 'uygulama rolu % fazla yetkili', v_rol;
    end if;
    if exists (select 1 from pg_auth_members m join pg_roles u on u.oid = m.member where u.rolname = v_rol) then
        raise exception 'uygulama rolu % bir role uye', v_rol;
    end if;
    if exists (select 1 from pg_class c join pg_roles o on o.oid = c.relowner where o.rolname = v_rol)
       or exists (select 1 from pg_proc p join pg_roles o on o.oid = p.proowner where o.rolname = v_rol) then
        -- Sahip olunan nesne GRANT'lardan bağımsız tam yetki verir (DROP/ALTER).
        raise exception 'uygulama rolu % nesne sahibi - nesneyi postgres''e devredin', v_rol;
    end if;
end $$;

-- Bilgi: CONNECT hakkı hâlâ PUBLIC'te olan kurulum DB'leri (o kurulum ilk kez
--   yeni sürümle yayınlanınca kapanır). Dışarıdan bağlanan başka bir
--   süper-olmayan rol varsa burada görünür - erişimi elle verilmeli.
\set QUIET off
\pset tuples_only on
select 'UYARI: PUBLIC CONNECT acik ' || count(*) || ' DB: '
       || array_to_string((array_agg(d.datname order by d.datname))[1:10], ', ')
       || case when count(*) > 10 then ', ...' else '' end as bilgi
  from pg_database d
 where not d.datistemplate and d.datname <> 'postgres'
   and has_database_privilege('public', d.oid, 'CONNECT')
having count(*) > 0;
select 'bilgi: diger super-olmayan giris rolleri: ' || string_agg(rolname, ', ' order by rolname) as bilgi
  from pg_roles
 where rolcanlogin and not rolsuper and rolname <> :'rol' and rolname !~ '_uyg$'
having count(*) > 0;

-- ============================================================================
--  Gentegre AI — ZAMAN DAMGALARI timestamptz'YE GEÇİYOR
--  667_timestamptz.sql
--
--  Kullanıcı: "timestamptz ye geç"  (666'nın devamı: şubeye göre saat)
--
--  SORUN — bugün ekranlarda saat YANLIŞ görünüyor:
--    veritabanı UTC çalışıyor (TimeZone = Etc/UTC) ve her yerde
--    `now()::timestamp` yazılıyor. Yani kayıtlara UTC duvar saati düşüyor,
--    istemci ise onu YEREL saat sanıp olduğu gibi gösteriyor. Türkiye'de
--    23:27'de yapılan giriş ekranda "20:27" yazıyor.
--
--    Aynı kolonlar, şubesi başka ülkede olan kurumda çözümsüz: "14:00" kaydı
--    kimin 14:00'ı? Zaman diliminsiz bir damga, ANI değil METNİ saklar.
--
--  ÇÖZÜM — `timestamp without time zone` → `timestamptz`:
--    timestamptz bir AN saklar; okuyan taraf kendi (ya da şubesinin) saat
--    diliminde görür. Şube bazlı saat (666) ancak bununla anlam kazanır.
--
--  DÖNÜŞÜM KURALI: mevcut değerler UTC duvar saatidir (DB Etc/UTC'de
--  `now()::timestamp` üretti), bu yüzden `AT TIME ZONE 'UTC'` ile
--  yorumlanır. "Europe/Istanbul" deseydik bütün geçmiş 3 saat kayardı.
--
--  KAPSAM: public şemasındaki TÜM `timestamp` kolonları (725 kolon / 333
--  tablo). Seçmeli dönüştürmek, aynı tabloda biri diline biri anına bakan
--  iki kolon bırakır - karşılaştırma yapan her sorgu sessizce yanlış olurdu.
--
--  GÖRÜNÜMLER: kolon tipini değiştirmek, o kolonu kullanan VIEW'ları
--  engeller. Bağımlı görünümler otomatik olarak yedeklenir, düşürülür ve
--  dönüşüm sonrası AYNI tanımla geri kurulur.
--
--  FONKSİYONLAR: gövdesinde `now()::timestamp` geçen fonksiyonlar dokunulmadan
--  çalışmaya devam eder - timestamp → timestamptz örtük dönüşümü OTURUM saat
--  dilimini kullanır ve veritabanının saat dilimi UTC'dir. Bunu kazaya
--  bırakmamak için aşağıda veritabanı düzeyinde AÇIKÇA sabitleniyor.
-- ============================================================================
\set ON_ERROR_STOP on

-- TEK ISLEM: 725 kolonun yarisi donusmus bir sema, donusmemis semadan
--   beterdir. PostgreSQL'de ALTER TABLE ... TYPE islemseldir.
begin;

-- ---------------------------------------------------------------------------
--  0) VERİTABANI SAAT DİLİMİ AÇIKÇA UTC
--     Sunucu saati değişse de (konteyner, işletim sistemi) davranış sabit
--     kalsın: saklanan an UTC, gösterim istemcinin işi.
-- ---------------------------------------------------------------------------
alter database gentegre_ai set timezone to 'UTC';

-- ---------------------------------------------------------------------------
--  1) BAĞIMLI GÖRÜNÜMLERİ YEDEKLE + DÜŞÜR
--     Yedek tablo KALIR: bir görünüm geri kurulamazsa tanımı elde dursun
--     (silinmiş bir view'ı hatırlamanın başka yolu yok).
-- ---------------------------------------------------------------------------
create table if not exists public._yedek_view_667 (
    sira        serial primary key,
    ad          text not null,
    tanim       text not null,
    kaydedildi  timestamptz not null default now()
);

truncate table public._yedek_view_667;

do $$
declare r record; n integer := 0;
begin
    -- Bagimli view'lar: ts kolonu OKUYAN her view. Bagimlilik sirasi onemli -
    --   view uzerine view olabilir; oid sirasi yerine BAGIMLILIK sirasiyla
    --   dusurmek icin once en cok bagimli olani almak yerine CASCADE kullanip
    --   tanimlari onceden saklamak daha guvenli.
    for r in
        select distinct c.oid::regclass::text as ad, pg_get_viewdef(c.oid, true) as tanim
          from pg_class c
          join pg_namespace n2 on n2.oid = c.relnamespace and n2.nspname = 'public'
         where c.relkind = 'v'
         order by 1
    loop
        insert into public._yedek_view_667 (ad, tanim) values (r.ad, r.tanim);
        n := n + 1;
    end loop;
    raise notice '667: % gorunum tanimi yedeklendi', n;
end $$;

-- Tum view'lari dusur (tanimlari yedekte). CASCADE: view uzerine view varsa
--   zincir birlikte gider; hepsi asagida geri kurulur.
do $$
declare r record;
begin
    -- ADLAR ONCEDEN METIN: CASCADE ile dusen bir view'in oid'si sonraki
    --   adimda regclass'a cevrilemiyor ve "drop view 155077" gibi gecersiz
    --   bir ad uretiyordu. Yedek tablodaki adlar zaten metin.
    for r in select ad from public._yedek_view_667 order by sira desc loop
        execute format('drop view if exists %s cascade', r.ad);
    end loop;
end $$;

-- ---------------------------------------------------------------------------
--  2) KOLONLARI DÖNÜŞTÜR
--     Önce varsayılan düşürülür: `now()::timestamp` varsayılanı tip
--     değişirken yeniden yorumlanır ve hataya/yanlış değere yol açar.
-- ---------------------------------------------------------------------------
do $$
declare
    r record;
    v_kolon integer := 0;
    v_varsayilan integer := 0;
begin
    for r in
        select c.table_name, c.column_name, c.column_default
          from information_schema.columns c
          join pg_class pc on pc.relname = c.table_name
          join pg_namespace pn on pn.oid = pc.relnamespace and pn.nspname = 'public'
         where c.table_schema = 'public'
           and c.data_type = 'timestamp without time zone'
           and pc.relkind in ('r', 'p')          -- yalniz gercek tablolar
           and c.is_generated = 'NEVER'
           -- BOLUM ANAHTARI DISARIDA: PostgreSQL bolumlenmis tablonun anahtar
           --   kolonunun tipini degistirmeye izin vermez ("cannot alter column
           --   ... part of the partition key"). islem_log.tarih boyle; o tablo
           --   yeniden kurulmayi gerektiriyor - AYRI adim (668), cunku musteri
           --   veritabaninda milyonlarca satir olabilir ve kopyalama suresi
           --   bu betigin yanina sigmaz.
           and not exists (
                 select 1
                   from pg_partitioned_table pt
                   join pg_attribute a on a.attrelid = pt.partrelid
                                      and a.attnum = any (string_to_array(pt.partattrs::text, ' ')::smallint[])
                  where pt.partrelid = pc.oid and a.attname = c.column_name)
           -- Bolum COCUKLARI da atlanir: cocuk kolonun tipi ebeveynden gelir,
           --   dogrudan degistirilemez (ebeveynle birlikte donusur).
           and not exists (select 1 from pg_inherits i where i.inhrelid = pc.oid)
         order by c.table_name, c.column_name
    loop
        if r.column_default is not null then
            execute format('alter table public.%I alter column %I drop default',
                           r.table_name, r.column_name);
        end if;

        -- SAKLANAN DEGER UTC DUVAR SAATIDIR: 'UTC' ile yorumlanir.
        execute format(
            'alter table public.%I alter column %I type timestamptz using %I at time zone ''UTC''',
            r.table_name, r.column_name, r.column_name);
        v_kolon := v_kolon + 1;

        -- now() tabanli varsayilanlar timestamptz olarak geri konur.
        if r.column_default is not null then
            if r.column_default ilike '%now()%' then
                execute format('alter table public.%I alter column %I set default now()',
                               r.table_name, r.column_name);
                v_varsayilan := v_varsayilan + 1;
            else
                -- now() disi varsayilan (sabit tarih vb.): oldugu gibi geri kon.
                execute format('alter table public.%I alter column %I set default %s',
                               r.table_name, r.column_name, r.column_default);
            end if;
        end if;
    end loop;

    raise notice '667: % kolon timestamptz oldu (% tanesinde now() varsayilani)',
        v_kolon, v_varsayilan;
end $$;

-- ---------------------------------------------------------------------------
--  3) GÖRÜNÜMLERİ GERİ KUR
--     Sıra bilinmiyor: view üzerine view olabilir. Kurulamayan satırlar tekrar
--     denenir; ilerleme durduğunda kalanlar hata olarak bildirilir.
-- ---------------------------------------------------------------------------
do $$
declare
    r record;
    v_kalan integer;
    v_onceki integer := -1;
    v_tur integer := 0;
    v_hata text := '';
begin
    create temporary table _kalan_view_667 on commit drop as
        select ad, tanim from public._yedek_view_667 order by sira;

    loop
        v_kalan := 0;
        for r in select ad, tanim from _kalan_view_667 loop
            begin
                execute format('create or replace view %s as %s', r.ad, r.tanim);
                delete from _kalan_view_667 where ad = r.ad;
            exception when others then
                v_kalan := v_kalan + 1;
                v_hata := r.ad || ': ' || SQLERRM;
            end;
        end loop;

        v_tur := v_tur + 1;
        exit when v_kalan = 0;
        if v_kalan = v_onceki then
            raise exception '667: % gorunum kurulamadi. Son hata -> %', v_kalan, v_hata;
        end if;
        v_onceki := v_kalan;
    end loop;

    raise notice '667: gorunumler % turda geri kuruldu', v_tur;
end $$;

-- ---------------------------------------------------------------------------
--  DOĞRULAMA
-- ---------------------------------------------------------------------------
do $$
declare v_kalan integer; v_tz integer; v_view integer;
begin
    select count(*) into v_kalan from information_schema.columns c
      join pg_class pc on pc.relname = c.table_name
      join pg_namespace pn on pn.oid = pc.relnamespace and pn.nspname = 'public'
     where c.table_schema = 'public' and c.data_type = 'timestamp without time zone'
       and pc.relkind in ('r', 'p');
    select count(*) into v_tz from information_schema.columns
     where table_schema = 'public' and data_type = 'timestamp with time zone';
    select count(*) into v_view from pg_views where schemaname = 'public';

    raise notice '667 tamam: timestamptz kolon %, kalan timestamp %, gorunum %',
        v_tz, v_kalan, v_view;
    if v_kalan > 0 then
        raise warning '667: % kolon hala timestamp - bakiniz yukaridaki notlar', v_kalan;
    end if;
end $$;

commit;

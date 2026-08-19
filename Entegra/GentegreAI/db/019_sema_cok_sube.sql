-- ============================================================================
--  Gentegre AI — cok subeli calisma
--  019_sema_cok_sube.sql
--
--  KARAR (19.08.2026): musteriler COK SUBELI olacak - hem ERP hem hastane
--  kullaniminda. Oncelik ERP; HBYS sistem ayaga kalktiktan sonra.
--  Cok subelilik sonradan eklenirse belge numaralama ve yetki filtresi bastan
--  yazilmak zorunda kalirdi; bu yuzden simdi kuruluyor.
--
--  MODEL
--    ANA VERI (taraf, stok, hizmet, masraf, kod listeleri) SUBELER ARASI ORTAK.
--      sube_id bu tablolarda "kaydi acan sube" izidir; yetki filtresi ana veride
--      UYGULANMAZ - yoksa ayni cari iki subede iki kez acilir.
--    HAREKET (belge, belge_satir, mali_hareket, stok hareketleri) SUBEYE AITTIR.
--      Liste/rapor yetkisi bu tablolarda sube_id uzerinden filtrelenir.
--    DEPO subeye baglidir; stok mevcudu depo bazlidir, dolayisiyla sube bazli
--      stok "hangi depolar o subenin" sorusuyla cevaplanir.
--    BELGE NUMARASI sube bazli uretilir: belge_no_sayac.kapsam icinde sube kodu
--      yer alir (or. 'belge.belge_no|T15|S1|SUBE1'), boylece iki sube ayni anda
--      belge kesince numara CAKISMAZ ve her subenin serisi BOSLUKSUZ akar.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- sube.tur ----
-- Hastane kullaniminda ayni firmanin poliklinigi/hastanesi ayri sube olur.
alter table public.sube add column if not exists tur smallint not null default 0;
comment on column public.sube.tur is
  '0 merkez, 1 sube, 2 saglik tesisi (HBYS), 9 diger. Belge numarasi ve yetki bu ayrimdan bagimsizdir; yalniz raporlama/gorunum icin.';

alter table public.sube add column if not exists ust_sube_id integer;
alter table public.sube drop constraint if exists fk_sube_ust;
alter table public.sube add constraint fk_sube_ust foreign key (ust_sube_id) references public.sube (id);
comment on column public.sube.ust_sube_id is 'Sube hiyerarsisi (bolge muduru altindaki subeler gibi). Bos = ust duzey.';

-- --------------------------------------------- sube_id -> FK ve NOT NULL ----
-- 018 gocu tum sube_id degerlerini gecerli subeye cekti; artik zorlanabilir.
-- taraf uzerindeki gorunumler kolon tipi degistirilirken engel olur; once dusurulur
drop view if exists public.cari, public.musteri, public.tedarikci,
                    public.personel, public.hasta cascade;

do $$
declare
    v_tablo text;
    v_vars  integer;
begin
    select id into v_vars from public.sube where varsayilan = 1 limit 1;

    for v_tablo in
        select c.relname
          from pg_class c
          join pg_namespace n on n.oid = c.relnamespace
         where n.nspname = 'public' and c.relkind = 'r'
           and c.relname not in ('sube')
           and c.relispartition = false
           and exists (select 1 from information_schema.columns k
                        where k.table_schema = 'public' and k.table_name = c.relname
                          and k.column_name = 'sube_id')
    loop
        -- kalan bos/gecersiz degerler varsayilan subeye
        execute format('update public.%I set sube_id = $1
                         where sube_id is null
                            or not exists (select 1 from public.sube s where s.id = sube_id)', v_tablo)
            using v_vars;
        -- tip smallint ise integer'a cek (sube.id integer)
        execute format('alter table public.%I alter column sube_id type integer', v_tablo);
        execute format('alter table public.%I alter column sube_id set not null', v_tablo);
        execute format('alter table public.%I drop constraint if exists fk_%s_sube', v_tablo, v_tablo);
        execute format('alter table public.%I add constraint fk_%s_sube
                        foreign key (sube_id) references public.sube (id)', v_tablo, v_tablo);
    end loop;
end $$;

-- Hareket tablolarinda sube bazli listeleme icin indeks
create index if not exists ix_belge_sube        on public.belge (sube_id, belge_tarihi desc);
create index if not exists ix_mali_hareket_sube on public.mali_hareket (sube_id, islem_tarihi desc);
create index if not exists ix_depo_sube         on public.depo (sube_id);

-- gorunumler geri kurulur (017 ile ayni tanim)
create or replace view public.cari      as select * from public.taraf where musteri = 1 or tedarikci = 1;
create or replace view public.musteri   as select * from public.taraf where musteri = 1;
create or replace view public.tedarikci as select * from public.taraf where tedarikci = 1;
create or replace view public.personel  as select * from public.taraf where personel = 1;
create or replace view public.hasta     as select * from public.taraf where hasta = 1;

-- ------------------------------------------------ kullanici-sube yetkisi ----
-- Kimlik tablosu Faz 0/F0-05'te gelecek; yetki baglantisi simdiden tanimlaniyor
-- ki liste sozlesmesindeki "sube filtresi sunucuda eklenir" kurali karsiliksiz
-- kalmasin. taraf.personel = 1 olan kayit uygulamanin kullanicisidir.
create table if not exists public.kullanici_sube (
    taraf_id          integer  not null references public.taraf (id) on delete cascade,
    sube_id           integer  not null references public.sube (id),
    varsayilan        smallint not null default 0,
    yazma             smallint not null default 1,   -- 0 ise yalniz okuma
    ekleyen           integer  not null default 0,
    ekleme_tarihi     timestamp not null default now()::timestamp,
    degistiren        integer  not null default 0,
    degistirme_tarihi timestamp,
    constraint pk_kullanici_sube primary key (taraf_id, sube_id)
);

create unique index if not exists ux_kullanici_sube_varsayilan
    on public.kullanici_sube (taraf_id) where varsayilan = 1;

comment on table public.kullanici_sube is
  'Kullanicinin (personel rollu taraf) calisabilecegi subeler. Liste/kart yetkisi bu tablodan turetilir; istekte sube bilgisi TASINMAZ.';

-- Mevcut personelin tamami varsayilan subeye baglanir (tek sube kurulumu)
insert into public.kullanici_sube (taraf_id, sube_id, varsayilan)
select t.id, (select id from public.sube where varsayilan = 1 limit 1), 1
  from public.taraf t
 where t.personel = 1
   and not exists (select 1 from public.kullanici_sube k where k.taraf_id = t.id);

-- ---------------------------------------------- belge numarasi: sube kapsami ----
-- Sayac anahtari sube kodunu icerir; boylece her sube kendi serisini BOSLUKSUZ
--   akitir ve iki sube ayni anda belge kesince numara cakismaz.
comment on table public.belge_no_sayac is
  'Belge numarasi sayaci. Anahtar sube kodunu ICERIR: "belge.belge_no|T<tur>|S<seri>|SUBE<id>". Numara transaction icinde, satir kilidi (for update) altinda, BOSLUKSUZ uretilir; taslak numara tuketmez.';

-- ============================================================================
--  Gentegre AI — KASA ATAMASI (varsayılan kasa / personel kasası)
--  196_kasa_atama.sql
--
--  Kullanıcı: "kasa hesaplarına bir kolon ekle; bu kolona default ya da
--  personel atayabileyim, ya da boş olsun. Nakit tahsilatta kullanıcının
--  kendi adına atanmış kasası varsa o gelsin, yoksa varsayılan kasa."
--
--  TEK KOLON, ÜÇ DURUM:
--      atama = 0  boş      - sıradan kasa, kimseye bağlı değil
--      atama = 1  Varsayılan - kullanıcının kendi kasası yoksa bu gelir
--      atama = 2  Personel  - `sorumlu_id` alanındaki kişinin kasası
--  Personel için AYRI kolon açılmadı: `hesap.sorumlu_id` zaten vardı ve tam
--  bu anlamı taşıyor; ikinci bir kişi alanı iki kaynak demekti.
--
--  ŞUBE BAZLI VARSAYILAN: her şubede bir varsayılan kasa olur (kısmi tekil
--  index). Farklı şubelerde çalışanlar birbirinin kasasına yazamamalı.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.hesap
    add column if not exists atama smallint not null default 0;

comment on column public.hesap.atama is
  '0 bos · 1 varsayilan kasa · 2 personel kasasi (kisi sorumlu_id''de) - 196.';

-- Bir şubede TEK varsayılan kasa; ikincisini eklemek sessizce eskisini
--   gölgede bırakırdı.
create unique index if not exists ux_hesap_varsayilan
    on public.hesap (tur, sube_id)
    where atama = 1 and durum = 1;

-- Aynı personele aynı şubede iki kasa atanmasın: hangisinin geleceği belirsiz olurdu.
create unique index if not exists ux_hesap_personel_kasa
    on public.hesap (tur, sube_id, sorumlu_id)
    where atama = 2 and durum = 1;

create index if not exists ix_hesap_atama
    on public.hesap (sube_id, tur, atama) where atama > 0;

-- Kod listesi (kart alanı).
insert into public.kod_liste (kod, ad)
select 'hesap.atama', 'Kasa Ataması'
 where not exists (select 1 from public.kod_liste where kod = 'hesap.atama');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.sira, 1
  from (values (0, '—', 10), (1, 'Varsayılan', 20), (2, 'Personel', 30)) as v(deger, ad, sira)
  join public.kod_liste l on l.kod = 'hesap.atama'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ---------------------------------------------------------------------------
--  KULLANICININ KASASI: nakit tahsilatta hangi kasa açılacak?
--    1) kullanıcıya ATANMIŞ kasa (atama = 2, sorumlu_id = kullanıcı)
--    2) yoksa şubenin VARSAYILAN kasası (atama = 1)
--    3) yoksa null - kart kasa alanını boş açar, kullanıcı seçer
--
--  Kullanıcı `taraf_kullanici` üzerinden bir TARAF kaydıdır; sorumlu_id de
--  taraf'a bakar - eşleşme doğrudan id üzerinden.
-- ---------------------------------------------------------------------------
create or replace function public.fn_kullanici_kasa(p_kullanici_id integer,
                                                    p_sube_id integer,
                                                    p_tur varchar default 'K')
returns table (hesap_id integer, ad varchar, doviz_cinsi varchar, kendi_kasasi boolean)
language sql stable as $$
    with aday as (
        select h.id, h.ad, h.doviz_cinsi,
               (h.atama = 2) as kendi,
               -- Kendi kasası önce; sonra varsayılan.
               case when h.atama = 2 then 1 else 2 end as oncelik
          from public.hesap h
         where h.tur = p_tur and h.durum = 1
           and (p_sube_id is null or h.sube_id = p_sube_id)
           and ((h.atama = 2 and h.sorumlu_id = p_kullanici_id) or h.atama = 1))
    select id, ad, doviz_cinsi, kendi from aday order by oncelik, id limit 1
$$;

comment on function public.fn_kullanici_kasa(integer, integer, varchar) is
  'Kullanicinin nakit islemde acilacak kasasi (196): once kendi atanmis kasasi, yoksa subenin varsayilan kasasi.';

-- Liste kolonu için okunur karşılık: "Varsayılan" · personel adı · boş.
create or replace function public.fn_hesap_atama_adi(p_atama smallint, p_sorumlu integer)
returns varchar language sql stable as $$
    select case coalesce(p_atama, 0)
             when 1 then 'Varsayılan'
             when 2 then coalesce((select t.unvan from public.taraf t where t.id = p_sorumlu), 'Personel')
             else '' end::varchar
$$;

do $$
declare v_kasa integer;
begin
    select count(*) into v_kasa from public.hesap where tur = 'K' and durum = 1;
    raise notice '196 tamam: hesap.atama (0 bos / 1 varsayilan / 2 personel) + fn_kullanici_kasa; % aktif kasa.', v_kasa;
end $$;

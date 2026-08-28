-- ============================================================================
--  Gentegre AI — BAZ ALINACAK ŞUBE (depo + ÜTS + e-Belge)
--  227_baz_sube.sql
--
--  "Merkezin verisini kullan" bayrağı yerine BAZ ALINACAK ŞUBE seçimi
--  (kullanıcı): 4 şubeli yerde 2 şube bir ortak veriyi, diğer 2 şube başka
--  ortak veriyi kullanabilmeli. Combo: "Kendisi" (id 0, ilk sırada) + şubeler.
--  e-Belge'de mevcut ust_sube_id zaten şube seçiyor - yalnız etiket değişti.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------ ortak lookup ----
-- id 0 = "Kendisi": kolonlar 0 varsayılanıyla NOT NULL tutulur (FK yok -
-- 0 gerçek şube değil). Seçenek sorgusu id=0'ı başa alır (KartDeposu.Okuma).
create or replace view public.v_sube_baz_lookup as
select 0 as id, 'Kendisi' as ad, 1 as aktif
union all
select id, ad, aktif from public.sube where aktif = 1;

comment on view public.v_sube_baz_lookup is
  'Baz alınacak şube combosu (227): 0 = Kendisi + aktif şubeler.';

-- ------------------------------------------------------------- depolar ----
alter table public.sube
    add column if not exists depo_baz_sube_id integer not null default 0;

comment on column public.sube.depo_baz_sube_id is
  'Depoları baz alınacak şube (227): 0 = kendisi. Dolu ise şube kendi deposu '
  'tutmaz, o şubenin depolarını kullanır (merkez_depo_kullan''ın genel hali).';

-- Geçiş: "merkezin depolarını kullan" işaretli şubeler merkezini baz alır.
update public.sube s
   set depo_baz_sube_id = public.fn_sube_merkez_id(s.id)
 where s.merkez_depo_kullan = 1
   and s.depo_baz_sube_id = 0
   and public.fn_sube_merkez_id(s.id) is distinct from s.id;

-- Depo seçimlerinde görünecek şube kümesi artık baz şubeden çözülür.
create or replace function public.fn_sube_depo_subeleri(p_sube_id integer)
returns integer[] language sql stable as $$
    select case
             when s.depo_baz_sube_id > 0 and s.depo_baz_sube_id <> s.id
             then array[s.id, s.depo_baz_sube_id]
             else array[s.id]
           end
      from public.sube s
     where s.id = p_sube_id
    union all
    select array[p_sube_id]
     where not exists (select 1 from public.sube where id = p_sube_id)
    limit 1
$$;

comment on function public.fn_sube_depo_subeleri(integer) is
  'Şubenin depo seçimlerinde göreceği şube kümesi: kendisi + baz şube (227).';

-- ----------------------------------------------------------------- ÜTS ----
alter table public.uts_hesap
    add column if not exists baz_sube_id integer not null default 0;

comment on column public.uts_hesap.baz_sube_id is
  'ÜTS hesabını baz alınacak şube (227): 0 = kendisi. Dolu ise bildirimler '
  'o şubenin hesabıyla (token/kurum no) gider.';

create or replace function public.fn_uts_hesap(p_sube_id integer default null)
returns table (kurum_no varchar, token text, test_mi boolean, url varchar)
language sql stable as $$
    with istenen as (
        select coalesce(p_sube_id,
                 (select id from public.sube
                   where varsayilan = 1 and aktif = 1 order by id limit 1)) as id
    ),
    -- Hedef şube: kaydındaki baz yönlendirmesi (0 = kendisi); kaydı hiç
    -- yoksa varsayılan şubeye düşülür.
    hedef as (
        select coalesce(
                 (select case when x.baz_sube_id > 0 and x.baz_sube_id <> x.sube_id
                              then x.baz_sube_id else x.sube_id end
                    from public.uts_hesap x join istenen i on i.id = x.sube_id),
                 (select id from public.sube
                   where varsayilan = 1 and aktif = 1 order by id limit 1)) as id
    ),
    -- "ÜTS Hesabı Aktif" / "Test Ortamı" karşılıklı dışlanan seçimdir:
    -- ikisinden biri işaretliyse hesap kullanılabilir.
    h as (
        select x.* from public.uts_hesap x
          join hedef t on t.id = x.sube_id
         where (x.aktif = 1 or x.test_ortami = 1)
         limit 1
    )
    select case when h.test_ortami = 1 then h.test_kurum_no else h.kurum_no end::varchar,
           case when h.test_ortami = 1 then h.test_token    else h.token    end,
           h.test_ortami = 1,
           coalesce(
             nullif(btrim((select r.deger from public.referans r
                            where r.anahtar = case when h.test_ortami = 1
                                                   then 'uts.test_url'
                                                   else 'uts.uretim_url' end)), ''),
             case when h.test_ortami = 1
                  then 'https://utstest.saglik.gov.tr'
                  else 'https://utsuygulama.saglik.gov.tr' end)::varchar
      from h
$$;

comment on function public.fn_uts_hesap(integer) is
  'Şubenin ÜTS hesabı (227): kayıttaki baz şube yönlendirmesi izlenir '
  '(0 = kendisi); kayıt yoksa varsayılan şubeye düşer.';

do $$ begin
    raise notice '227 tamam: baz şube (depo + ÜTS) + v_sube_baz_lookup.';
end $$;

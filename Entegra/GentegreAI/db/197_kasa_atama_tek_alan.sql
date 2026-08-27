-- ============================================================================
--  Gentegre AI — KASA ATAMASI TEK ALANDA
--  197_kasa_atama_tek_alan.sql
--
--  Kullanıcı: "hem atama hem sorumluya gerek yok, sadece atama yeter. Ana kasa
--  (default) zaten default olmak zorunda; diğerleri ya boş kalır ya personel
--  atanır."
--
--  196'da atama bir DURUM kodu (0/1/2) idi ve kişi ayrı alanda (sorumlu_id)
--  duruyordu - kullanıcı iki alan doldurmak zorundaydı. Artık TEK ALAN:
--
--      atama =  0 (ya da NULL)  boş        - sıradan kasa
--      atama = -1               Ana Kasa   - varsayılan; kullanıcının kendi
--                                            kasası yoksa bu açılır
--      atama >  0               personel   - değerin kendisi taraf kimliğidir
--
--  Negatif değer "özel durum" işareti: personel kimlikleri her zaman pozitif
--  olduğu için çakışma yok, ikinci bir bayrak kolonuna gerek kalmıyor.
--  `hesap.sorumlu_id` kolonu DURUYOR (eski kayıtlar ve raporlar için) ama kasa
--  atamasında artık kullanılmıyor - kart alanından da kaldırıldı.
-- ============================================================================
\set ON_ERROR_STOP on

-- Eski kısıtlar yeni anlamla uyumsuz: önce düşür.
drop index if exists public.ux_hesap_varsayilan;
drop index if exists public.ux_hesap_personel_kasa;
drop index if exists public.ix_hesap_atama;

-- smallint -> integer: personel kimliği taşıyacak.
alter table public.hesap
    alter column atama type integer using atama::integer;

-- 196 kodlarını yeni anlama taşı: 1 (varsayılan) -> -1, 2 (personel) -> kişi.
update public.hesap set atama = -1 where atama = 1;
update public.hesap
   set atama = case when coalesce(sorumlu_id, 0) > 0 then sorumlu_id else 0 end
 where atama = 2;

comment on column public.hesap.atama is
  'Kasa atamasi (197): 0 bos · -1 Ana Kasa (varsayilan) · >0 personel taraf kimligi.';

-- Bir şubede TEK ana kasa.
create unique index if not exists ux_hesap_ana_kasa
    on public.hesap (tur, sube_id) where atama = -1 and durum = 1;

-- Aynı personele aynı şubede tek kasa.
create unique index if not exists ux_hesap_personel_kasa
    on public.hesap (tur, sube_id, atama) where atama > 0 and durum = 1;

create index if not exists ix_hesap_atama
    on public.hesap (sube_id, tur, atama) where atama <> 0;

-- ---------------------------------------------------------------------------
--  TEK ALANIN SEÇİM LİSTESİ: "Ana Kasa" + personeller.
--  Kart tek lookup kullanır; iki ayrı alan (durum + kişi) yerine tek seçim.
-- ---------------------------------------------------------------------------
-- Ad "★" ile baslar: kart combo'su secenekleri ADA gore siraliyor; duz metin
--   olsaydi "Ana Kasa" personel adlarinin arasina karisirdi. Yildiz sirlamada
--   harflerden once gelir, secenek daima EN USTTE durur.
create or replace view public.v_hesap_atama_lookup as
    select -1 as id, '★ Ana Kasa (varsayılan)'::text as ad, 1 as aktif
    union all
    select t.id, t.unvan::text, t.durum
      from public.taraf t
     where t.personel = 1 and t.durum = 1;

comment on view public.v_hesap_atama_lookup is
  'Kasa atama secenekleri (197): Ana Kasa (-1) + aktif personeller.';

-- ---------------------------------------------------------------------------
--  Seçim kuralı aynı, tek alana göre yeniden yazıldı.
-- ---------------------------------------------------------------------------
create or replace function public.fn_kullanici_kasa(p_kullanici_id integer,
                                                    p_sube_id integer,
                                                    p_tur varchar default 'K')
returns table (hesap_id integer, ad varchar, doviz_cinsi varchar, kendi_kasasi boolean)
language sql stable as $$
    with aday as (
        select h.id, h.ad, h.doviz_cinsi,
               (h.atama = p_kullanici_id) as kendi,
               -- Kendi kasası önce, sonra ana kasa.
               case when h.atama = p_kullanici_id then 1 else 2 end as oncelik
          from public.hesap h
         where h.tur = p_tur and h.durum = 1
           and (p_sube_id is null or h.sube_id = p_sube_id)
           and (h.atama = p_kullanici_id or h.atama = -1))
    select id, ad, doviz_cinsi, kendi from aday order by oncelik, id limit 1
$$;

comment on function public.fn_kullanici_kasa(integer, integer, varchar) is
  'Kullanicinin nakit islemde acilacak kasasi (197): once kendi atanmis kasasi, yoksa subenin ana kasasi.';

-- Liste kolonu: "Ana Kasa" · personel adı · boş.
drop function if exists public.fn_hesap_atama_adi(smallint, integer);

create or replace function public.fn_hesap_atama_adi(p_atama integer)
returns varchar language sql stable as $$
    select case
             when coalesce(p_atama, 0) = 0 then ''
             when p_atama = -1 then 'Ana Kasa'
             else coalesce((select t.unvan from public.taraf t where t.id = p_atama), 'Personel')
           end::varchar
$$;

do $$
declare v_ana integer; v_per integer;
begin
    select count(*) into v_ana from public.hesap where atama = -1;
    select count(*) into v_per from public.hesap where atama > 0;
    raise notice '197 tamam: kasa atamasi TEK alan (-1 ana kasa / >0 personel); % ana kasa, % personel kasasi.',
                 v_ana, v_per;
end $$;

-- =====================================================================
--  933_muayene_sablon_doktor_oncelik.sql
--  DOKTORUN ŞABLONU ÖNCE (kullanıcı: "muayene sırasında doktor adına şablon
--  varsa onu kullansın yoksa genel branş şablonu kullanılsın").
--
--  931'deki fn_muayene_sablon_kapsami bölüm ortak + doktorun şablonlarını
--  BİRLİKTE döndürüyordu: doktor kendi sık tanı / reçete / panel / makro
--  listesini kursa da bölümünkiler araya karışıyordu. Artık:
--
--    · muayenenin doktorunun o bölümde aktif şablonu VARSA yalnız onlar,
--    · YOKSA bölüm ortak (doktoru boş) şablonlar,
--    · muayeneye uygulanmış şablon her durumda (kisisel = 2).
--
--  KURALLAR İSTİSNA (p_kural = true): bölüm ortak şablonların kuralları
--  doktorun şablonu olsa da uygulanır. Kural başhekimin / bölümün kararıdır;
--  doktor kendi kopyasından kuralı silerek zorunluluğu atlatamamalı.
--
--  İmza değişti (ikinci parametre varsayılanlı): tek parametreli çağrılar
--  aynen çalışır. Eski tek parametreli sürüm düşürülür (aşırı yükleme
--  belirsizliği olmasın).
-- =====================================================================
\set ON_ERROR_STOP on

drop function if exists public.fn_muayene_sablon_kapsami(integer);

create or replace function public.fn_muayene_sablon_kapsami(p_muayene integer, p_kural boolean default false)
returns table (sablon_id integer, kisisel smallint)
language sql stable as $$
  with m as (
    select id, bolum_id, personel_id, sablon_id from public.muayene where id = p_muayene
  ), aday as (
    select s.id, case when s.hekim_id is not null then 1 else 0 end::smallint kisisel
      from m
      join public.muayene_sablon s
        on s.durum = 1 and s.bolum_id = m.bolum_id
       and (s.hekim_id is null or s.hekim_id = m.personel_id)
  ), secilen as (
    select a.id, a.kisisel from aday a
     where a.kisisel = 1
        or not exists (select 1 from aday d where d.kisisel = 1)   -- doktorunki yoksa bölüm ortak
        or p_kural                                                 -- kural: bölüm ortak da
  )
  select id, kisisel from secilen
  union
  select m.sablon_id, 2::smallint
    from m
   where m.sablon_id is not null
     and not exists (select 1 from secilen x where x.id = m.sablon_id)
$$;

do $$ begin raise notice '933 tamam: şablon kapsamı - doktorunki varsa o, yoksa bölüm ortak'; end $$;

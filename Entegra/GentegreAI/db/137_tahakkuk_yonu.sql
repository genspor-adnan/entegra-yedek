-- ============================================================================
--  Gentegre AI — ALACAK TAHAKKUKUNUN CARI YONU
--  137_tahakkuk_yonu.sql
--
--  Alacak Tahakkuku (13) SATIS tarafindadir: musteri borclanir. Sunucudaki yon
--  listesi (BelgeTuru.CikisTurleri) 13'u icermedigi icin belge alis gibi
--  davraniyor, cari hesaba ALACAK yaziyordu - bakiye ters cikiyordu.
--  (17 Borc Tahakkuku alis tarafinda oldugu icin dogruydu.)
--
--  Kod duzeltildi; bu goc, yanlis yonle yazilmis MEVCUT satirlari cevirir.
--  Iade tahakkuku (belge.tipi = 2) yon zaten TERSTIR - disarida birakilir.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.mali_hareket_tahakkuk_yedek_137 (
    id           integer primary key,
    borc         numeric(19,4),
    alacak       numeric(19,4),
    yerel_borc   numeric(19,4),
    yerel_alacak numeric(19,4),
    tarih        timestamp not null default now()::timestamp
);

begin;

insert into public.mali_hareket_tahakkuk_yedek_137
    (id, borc, alacak, yerel_borc, yerel_alacak)
select m.id, m.borc, m.alacak, m.yerel_borc, m.yerel_alacak
  from public.mali_hareket m
  join public.belge b on b.id = m.belge_id
 where m.tur = 13
   and coalesce(b.tipi, 0) <> 2      -- iade tahakkukunda yon zaten ters
   and m.alacak > 0                  -- yalniz TERS yazilmis satirlar
on conflict (id) do nothing;

update public.mali_hareket m
   set borc         = m.alacak,
       alacak       = m.borc,
       yerel_borc   = m.yerel_alacak,
       yerel_alacak = m.yerel_borc
  from public.belge b
 where b.id = m.belge_id
   and m.tur = 13
   and coalesce(b.tipi, 0) <> 2
   and m.alacak > 0;

commit;

do $$
declare v_cevrilen integer; v_ters integer;
begin
    select count(*) into v_cevrilen from public.mali_hareket_tahakkuk_yedek_137;
    select count(*) into v_ters from public.mali_hareket m
      join public.belge b on b.id = m.belge_id
     where m.tur = 13 and coalesce(b.tipi, 0) <> 2 and m.alacak > 0;
    raise notice '137 tamam: % satirin yonu cevrildi, kalan ters satir %', v_cevrilen, v_ters;
end $$;

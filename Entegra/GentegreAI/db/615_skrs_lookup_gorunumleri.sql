-- =====================================================================
--  615_skrs_lookup_gorunumleri.sql
--  BÜYÜK SKRS LİSTELERİ İÇİN LOOKUP GÖRÜNÜMLERİ.
--
--  Küçük listeler karta `KodListesi` ile bağlanır: sunucu listeyi olduğu
--  gibi gönderir, istemci açılır kutuda gösterir. Meslek (5461), ülke
--  (236) ve klinik (240) bunun için fazla büyük - onlar arama kutusuyla
--  çalışan `KodTablosu` lookup'ına bağlanır; kurum seçimi (v_kurum_lookup)
--  ile aynı mekanizma.
--
--  Görünümler lookup sözleşmesini izler: (id, ad, aktif). `id` SKRS
--  kodunun kendisidir - kartta seçilen değer doğrudan e-Nabız'a giden
--  koddur, arada çeviri yok.
--
--  Meslek alanları da metin olmaktan çıkıp kod alanına dönüyor; ikisi de
--  boştu (hiçbir kayıtta meslek girilmemiş), dönüşüm veri kaybetmiyor.
-- =====================================================================

create or replace view public.v_skrs_meslek_lookup as
select d.deger as id,
       d.skrs_kod || ' - ' || d.ad as ad,
       d.aktif
  from public.kod_deger d
  join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'taraf.meslek' and d.dil = 0;

create or replace view public.v_skrs_ulke_lookup as
select d.deger as id, d.ad, d.aktif
  from public.kod_deger d
  join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'hasta.uyruk' and d.dil = 0;

create or replace view public.v_skrs_klinik_lookup as
select d.deger as id,
       d.skrs_kod || ' - ' || d.ad as ad,
       d.aktif
  from public.kod_deger d
  join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'klinik.kod' and d.dil = 0;

comment on view public.v_skrs_meslek_lookup is
  '615: SKRS MESLEKLER lookup (id = SKRS kodu).';
comment on view public.v_skrs_ulke_lookup is
  '615: SKRS ULKE KODLARI lookup (id = MERNIS kodu).';
comment on view public.v_skrs_klinik_lookup is
  '615: SKRS KLINIKLER lookup (id = SKRS klinik kodu).';

-- --------------------------------------------------------------------
--  Meslek: metin -> SKRS kodu
-- --------------------------------------------------------------------
-- Alan NOT NULL + varsayilan '' idi; sayiya donusunce "girilmemis" artik
-- NULL ile anlatilir - mesleksiz hasta bos metin degil, BILINMEYEN.
alter table public.taraf_hasta
  alter column meslek drop default;
alter table public.taraf_hasta
  alter column meslek drop not null;
alter table public.taraf_hasta
  alter column meslek type integer
  using nullif(regexp_replace(coalesce(meslek, ''), '\D', '', 'g'), '')::integer;

alter table public.taraf_personel
  alter column meslek_kodu drop default;
alter table public.taraf_personel
  alter column meslek_kodu drop not null;
alter table public.taraf_personel
  alter column meslek_kodu type integer
  using nullif(regexp_replace(coalesce(meslek_kodu, ''), '\D', '', 'g'), '')::integer;

comment on column public.taraf_hasta.meslek is
  '615: SKRS MESLEKLER kodu (v_skrs_meslek_lookup). Onceden serbest metindi.';
comment on column public.taraf_personel.meslek_kodu is
  '615: SKRS MESLEKLER kodu (v_skrs_meslek_lookup).';

do $$
begin
    raise notice '615 tamam: lookup gorunumleri kuruldu (% meslek, % ulke, % klinik)',
        (select count(*) from public.v_skrs_meslek_lookup),
        (select count(*) from public.v_skrs_ulke_lookup),
        (select count(*) from public.v_skrs_klinik_lookup);
end $$;

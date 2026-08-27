-- ============================================================================
--  Gentegre AI — MUKELLEF SORGUSUNUN TAZELIGI
--  185_mukellef_sorgu_tazelik.sql
--
--  Kullanici: "mukellef sorgusu yapmadan burayi kontrol et; opsiyona gore 30
--  gunu gecti ve e-Fatura ise tekrar sorgu yap; e-posta ise mutlaka her
--  seferinde sorgulama yap."
--
--  KURAL:
--    * Cari e-FATURA MUKELLEFI olarak biliniyorsa ve son sorgu TAZE ise
--      (varsayilan 30 gun) entegratore SORULMAZ - her belgede ag turu atmak
--      hem yavas hem gereksiz; GIB kaydi gunluk degismez.
--    * Sure gectiyse yeniden sorulur: mukellefiyet birakilmis olabilir, o
--      durumda belge e-Arsiv'e donmeli.
--    * Cari MUKELLEF DEGILSE (e-Arsiv) sorgu HER SEFERINDE yapilir: yeni
--      mukellefiyet her an baslayabilir ve e-Arsiv kesilen bir aliciya artik
--      e-Fatura gitmesi gerekiyor olabilir.
--
--  Sure OPSIYONDA (Ayarlar > Satis Belgeleri): musteriye gore degisebilsin.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf
    add column if not exists efatura_sorgu_tarihi timestamp null;

comment on column public.taraf.efatura_sorgu_tarihi is
  'e-Fatura mukellefiyetinin entegratore en son ne zaman soruldugu (185).';

insert into public.referans (anahtar, deger, tip, aciklama)
select 'efatura.mukellef_sorgu_gun', '30', 'sayi',
       'e-Fatura mükellefi olarak bilinen cari kaç gün sonra yeniden sorgulanır (185).'
 where not exists (select 1 from public.referans
                    where anahtar = 'efatura.mukellef_sorgu_gun');

-- Sorgu gerekli mi: TEK karar yeri - uc ve arayuz ayni cevabi alsin.
create or replace function public.fn_mukellef_sorgu_gerekli(p_taraf_id integer)
returns boolean
language sql stable as $$
    select case
             -- Cari yoksa ya da VKN'si yoksa sorulacak bir sey yok.
             when t.id is null or coalesce(btrim(t.vkno), '') = '' then false
             -- MUKELLEF DEGIL: her seferinde sor (yeni mukellefiyet baslamis olabilir).
             when coalesce(t.efatura, 0) <> 1 then true
             -- MUKELLEF ama hic sorulmamis.
             when t.efatura_sorgu_tarihi is null then true
             -- MUKELLEF ve sorgu ESKIMIS.
             else t.efatura_sorgu_tarihi
                  < now()::timestamp - make_interval(days =>
                      greatest(coalesce((select nullif(btrim(r.deger), '')::int
                                           from public.referans r
                                          where r.anahtar = 'efatura.mukellef_sorgu_gun'), 30), 1))
           end
      from public.taraf t where t.id = p_taraf_id
$$;

comment on function public.fn_mukellef_sorgu_gerekli(integer) is
  'Carinin e-Fatura mukellefiyeti yeniden sorulmali mi (185): mukellef degilse her zaman, mukellefse sorgu eskiyince.';

do $$
declare v_gun integer;
begin
    select coalesce(nullif(btrim(deger), '')::int, 30) into v_gun
      from public.referans where anahtar = 'efatura.mukellef_sorgu_gun';
    raise notice '185 tamam: mukellef sorgusu tazeligi (% gun); mukellef olmayan cari her seferinde sorulur.', v_gun;
end $$;

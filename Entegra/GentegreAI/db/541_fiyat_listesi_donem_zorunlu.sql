-- =====================================================================
--  541 - FIYAT LISTESINDE DONEM ZORUNLU, AD+DONEM TEKIL
--  (kullanici: "başlama-bitiş alanları zorunlu olsun" ·
--              "isim ve başlama bitiş tarihleri aynı ise kaydet izni
--               verilmez")
--
--  BUGUNE KADAR: `baslangic`/`bitis` bos birakilabiliyordu ve ad TEK
--  BASINA tekildi (ux_fiyat_listesi_ad). Ikisi birlikte su sonucu
--  veriyordu: yeni yilin listesini acmak icin adin icine yil yazmak
--  ZORUNLUYDU ("SUT 2026", "SUT 2027") - cunku ayni ad ikinci kez
--  kullanilamiyordu. Donem bilgisi adin icinde metin olarak yasiyordu,
--  kolonlar ise bostu; `fn_belge_varsayilan_liste` / `fn_cari_fiyat_listesi`
--  "bugun gecerli liste" secimini bos tarihlerle yapiyor, yani her liste
--  her tarihte gecerli sayiliyordu.
--
--  BUNDAN SONRA: donem ZORUNLU, tekillik (ad + baslangic + bitis)
--  uclusunde. Ayni ad farkli donemde serbest - "SUT" listesi 2026 ve
--  2027 icin ayri ayri acilabilir, ad degismez, tarih ayirir.
-- =====================================================================

-- ------------------------------------------------ 1) mevcut satirlar ----
-- Donem bos olan listelere ADINDAKI yildan donem yazilir (bugunku uc
--   liste "SUT 2026" / "TTB/HUV 2026" / "Özel (Ücretli) 2026" - yil zaten
--   adin icinde). Yil bulunamazsa icinde bulunulan yil.
create table if not exists public._yedek_fiyat_listesi_donem_541 as
select id, ad, baslangic, bitis from public.fiyat_listesi
 where baslangic is null or bitis is null;

update public.fiyat_listesi l
   set baslangic = coalesce(l.baslangic,
                            make_date(coalesce(
                              (substring(l.ad from '(?:19|20)[0-9]{2}'))::int,
                              extract(year from current_date)::int), 1, 1)),
       bitis     = coalesce(l.bitis,
                            make_date(coalesce(
                              (substring(l.ad from '(?:19|20)[0-9]{2}'))::int,
                              extract(year from current_date)::int), 12, 31))
 where l.baslangic is null or l.bitis is null;

-- ---------------------------------------------------- 2) zorunluluk ----
alter table public.fiyat_listesi alter column baslangic set not null;
alter table public.fiyat_listesi alter column bitis     set not null;

comment on column public.fiyat_listesi.baslangic is
  'Listenin gecerlilik baslangici. ZORUNLU (541) - "bugun gecerli liste"
   secimi (fn_belge_varsayilan_liste, fn_cari_fiyat_listesi) bu tarihi okur.';
comment on column public.fiyat_listesi.bitis is
  'Listenin gecerlilik bitisi. ZORUNLU (541).';

-- ------------------------------------------------------ 3) tekillik ----
-- Ad TEK BASINA degil, DONEMLE BIRLIKTE tekil (541). Ayni adin ikinci
--   donemi artik mesru: "SUT" 2026 ve "SUT" 2027 yan yana durur.
drop index if exists public.ux_fiyat_listesi_ad;
create unique index if not exists ux_fiyat_listesi_ad_donem
    on public.fiyat_listesi (lower(ad), baslangic, bitis);

do $$
declare v_bos int;
begin
    select count(*) into v_bos
      from public.fiyat_listesi where baslangic is null or bitis is null;
    raise notice '541: donemi bos liste kaldi = %', v_bos;
end $$;

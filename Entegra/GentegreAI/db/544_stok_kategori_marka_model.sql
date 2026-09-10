-- =====================================================================
--  544 - STOK KARTI: KATEGORI AGACI (yalniz stok) · MARKA · MODEL
--  (kullanici: "stok kartı kategori de sadece stok kategorileri combo
--   ağacı şeklinde gelsin" · "marka da id'ler geliyor anlaşılmıyor..
--   model de combo olmalı ve markaya bağımlı olmalı, yani markanın
--   modelleri")
--
--  UC AYRI DERT, TEK KOK: stok kartinin siniflandirma kutusu.
--
--  1) KATEGORI. Kart `public.kategori` tablosunun TAMAMINI duz bir combo
--     olarak gosteriyordu: hizmet agaci (tur 2, SUT basliklari) da stok
--     kartinda cikiyor, hiyerarsi hic gorunmuyordu. Hizmet kartinda ayni
--     hata aynadan: stok dallari orada listeleniyor. Iki gorunum ayirir.
--
--  2) MARKA. `stok.marka` kod listesinin 171 satirindan 164'unun ADI bir
--     SAYI ("505", "244", "0"): gocte kod alani ad diye yazilmis. Combo
--     "id'ler geliyor" gibi gorunuyordu - cunku oyle. Hicbir stok satiri
--     bunlara BAGLI DEGIL; bagli olmayan sayi-adli satirlar pasife alinir
--     (silinmez - baska kurulumda anlamli olabilir).
--
--  3) MODEL. Kolon zaten `smallint` (bir KOD), kartta ise metin kutusuydu:
--     yazilan metin kolona hic girmiyordu. Model markadan bagimsiz da
--     olamaz - "X markasinin modelleri". Bunun icin kod listelerine UST
--     BAGI eklenir: kod_liste.ust_liste_id (bu liste sununun altindadir) +
--     kod_deger.ust_deger (bu deger ust listenin su degerine baglidir).
--     Ayni desen ilerde il/ilce icin de kullanilabilir.
-- =====================================================================

-- ---------------------------------------------- 1) kategori gorunumleri ----
-- KodTablosu sozlesmesi: id · ad · aktif · ust_id (agac icin GERCEK ust).
--   `v_kategori_lookup` (250) ust_id yerine TUR dondurur - o gorunum
--   kategori kartinin "ust" combosunu ayni tur icinde suzmek icin yazilmis;
--   agac cizimi icin kullanilamaz. Ikisi ayri istir, ayri gorunum.
create or replace view public.v_stok_kategori_lookup as
select k.id, k.ad, k.aktif, k.ust_id
  from public.kategori k
 where k.tur = 1;

comment on view public.v_stok_kategori_lookup is
  'Stok kategorileri (tur 1) - kart agac combosu (544).';

create or replace view public.v_hizmet_kategori_lookup as
select k.id, k.ad, k.aktif, k.ust_id
  from public.kategori k
 where k.tur = 2;

comment on view public.v_hizmet_kategori_lookup is
  'Hizmet kategorileri (tur 2) - kart agac combosu (544).';

-- --------------------------------------------------- 2) marka temizligi ----
do $$
declare v_sayi int;
begin
    create table if not exists public._yedek_kod_deger_marka_544 as
    select d.* from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id
     where l.kod = 'stok.marka';

    -- YALNIZ PROVABLE OLARAK ISE YARAMAYAN SATIR: adi bastan sona rakam VE
    --   hicbir stok satiri o markayi kullanmiyor. Adi gercek olan marka ya
    --   da kullanimda olan bir deger ELLENMEZ.
    update public.kod_deger d
       set aktif = 0
      from public.kod_liste l
     where l.id = d.liste_id
       and l.kod = 'stok.marka'
       and d.aktif = 1
       and d.ad ~ '^[0-9]+$'
       and not exists (select 1 from public.stok s where s.marka = d.deger);
    get diagnostics v_sayi = row_count;
    raise notice '544: adi sayi olan ve kullanilmayan marka pasife alindi = %', v_sayi;
end $$;

-- --------------------------------------------------- 3) bagli kod listesi ----
alter table public.kod_liste
    add column if not exists ust_liste_id integer references public.kod_liste(id);
comment on column public.kod_liste.ust_liste_id is
  'Bu liste bir UST listeye baglidir (544): degerleri ust listenin secili degerine gore suzulur. Ör. stok.model -> stok.marka.';

alter table public.kod_deger
    add column if not exists ust_deger integer not null default 0;
comment on column public.kod_deger.ust_deger is
  'Ust listedeki deger (544). 0 = bagsiz; ust listesi olmayan listelerde her zaman 0.';

-- stok.model listesi: stok.marka'nin altinda.
insert into public.kod_liste (kod, ad)
select 'stok.model', 'Stok Model'
 where not exists (select 1 from public.kod_liste where kod = 'stok.model');

update public.kod_liste l
   set ust_liste_id = (select u.id from public.kod_liste u where u.kod = 'stok.marka')
 where l.kod = 'stok.model' and l.ust_liste_id is null;

-- MODEL COMBOSU icin AYRI GORUNUM YOK: kart alani `KodListesi: stok.model` +
--   `BagliAlan: marka`; secenekler kod listesinden, ust haritasi
--   `kod_deger.ust_deger`den gelir (KartDeposu.KodListesiUstAsync). Boylece
--   ayni alan hem markaya gore SUZULUR hem de etiketi tiklanip liste
--   duzenlenebilir - kod tablosu gorunumunde ikincisi mumkun olmuyordu.

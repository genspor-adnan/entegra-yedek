-- ============================================================================
--  Gentegre AI — BELGEDE LOT / SERI IZLEMI (giris belgeleri)
--  114_belge_izlem.sql
--
--  Tablolar ZATEN VAR (011 + goc): stok_seri_lot (lot/seri kimligi) ve
--  stok_izleme (hangi belge satiri hangi lottan ne kadar hareket ettirdi).
--  36.509 lot ve 454.406 izlem satiri gocmus durumda. Eksik olan, YENI girilen
--  belgelerin bu tablolari doldurmasiydi: kalem penceresinde tek satirlik bir
--  "Seri / Lot" metin kutusu vardi, bir kalemde birden fazla lot girilemiyordu.
--
--  Bu goc, o yazma yolunun ihtiyaci olan uc seyi hazirlar:
--
--  1) LOT KIMLIGI BENZERSIZ. Yeni girisde lot "varsa bul, yoksa ac" mantigiyla
--     eslenecek; bunun icin (stok, lot no, seri no) benzersiz olmali. Gocte 4
--     cift mukerrer kalmis (36.509 satir / 36.505 benzersiz kimlik) - ayni lotun
--     iki kaydi. Hareketler kucuk id'ye tasinir, fazlalik silinir; silinenler
--     yedek tabloda kalir.
--
--  2) DURUM. Kullanici karari: izlem satirinda Durum kolonu var ve GIRISTE 0.
--     Simdilik tanimli tek deger 0 (Girişte); karantina/bloke gibi durumlar
--     kod listesine eklenecegi zaman burada tanimlanir - uydurma durum kodu
--     yazmiyoruz.
--
--  3) OKUMA GORUNUMU. Belge acilinca kalemin lotlari geri gelmeli.
--     v_belge_satir_izlem satir + lot bilgisini birlestirir.
--
--  TARIH BOSLUGU: gocmus lotlarda "tarih yok" 1899-12-31 ya da 1990-01-01
--  sentinel'i olarak duruyor (kaynak sistemin bos tarihi). Gorunum bunlari NULL
--  gosterir - ekranda 31.12.1899 yazmasi kullaniciya yanlis bilgi verir.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------- 1) mukerrer lot temizligi --
create table if not exists public.stok_seri_lot_tekil_yedek_114 (
    id                  integer primary key,
    stok_id             integer,
    lot_no              varchar(30),
    lot_no_ex           varchar(30),
    seri_no             varchar(30),
    uretim_tarihi       timestamp,
    son_kullanma_tarihi timestamp,
    tasindigi_id        integer,      -- hareketlerin aktarildigi kayit
    yedek_tarihi        timestamp not null default now()::timestamp
);

comment on table public.stok_seri_lot_tekil_yedek_114 is
  'Mukerrer lot temizliginde (114) silinen kayitlar. Geri alma icin saklanir.';

do $$
declare v_tasinan integer; v_silinen integer;
begin
    create temporary table gecici_lot_esle on commit drop as
    select l.id as eski_id, k.tutulan_id
      from public.stok_seri_lot l
      join (select stok_id, lot_no, seri_no, min(id) as tutulan_id
              from public.stok_seri_lot
             group by 1, 2, 3
            having count(*) > 1) k
        on k.stok_id = l.stok_id and k.lot_no = l.lot_no and k.seri_no = l.seri_no
     where l.id <> k.tutulan_id;

    insert into public.stok_seri_lot_tekil_yedek_114
        (id, stok_id, lot_no, lot_no_ex, seri_no, uretim_tarihi, son_kullanma_tarihi, tasindigi_id)
    select l.id, l.stok_id, l.lot_no, l.lot_no_ex, l.seri_no,
           l.uretim_tarihi, l.son_kullanma_tarihi, e.tutulan_id
      from public.stok_seri_lot l
      join gecici_lot_esle e on e.eski_id = l.id
     on conflict (id) do nothing;

    update public.stok_izleme i
       set seri_lot_id = e.tutulan_id
      from gecici_lot_esle e
     where i.seri_lot_id = e.eski_id;
    get diagnostics v_tasinan = row_count;

    delete from public.stok_seri_lot l using gecici_lot_esle e where l.id = e.eski_id;
    get diagnostics v_silinen = row_count;

    raise notice '114: % izlem satiri tasindi, % mukerrer lot silindi', v_tasinan, v_silinen;
end $$;

-- Lot kimligi: ayni stokta ayni lot+seri iki kez acilamaz ("varsa bul" bunu kullanir).
create unique index if not exists ux_stok_seri_lot_kimlik
    on public.stok_seri_lot (stok_id, lot_no, seri_no);

-- ------------------------------------------------------------------ 2) durum --
alter table public.stok_izleme
    add column if not exists durum smallint not null default 0;

comment on column public.stok_izleme.durum is
  'Izlem satirinin durumu (114). Giriste 0. Diger degerler kod listesinde tanimlanacak.';

insert into public.kod_liste (kod, ad) values ('stok_izleme.durum', 'İzlem Durumu')
on conflict (kod) do nothing;

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select kl.id, 0, 'Girişte', 10, 1
  from public.kod_liste kl
 where kl.kod = 'stok_izleme.durum'
   and not exists (select 1 from public.kod_deger k where k.liste_id = kl.id and k.deger = 0);

-- Belge satirindan lotlarina gidis (kart acilinca kalemin lotlari okunur).
create index if not exists ix_stok_izleme_belge_satir
    on public.stok_izleme (belge_satir_id) where belge_satir_id is not null;

-- ------------------------------------------------------------- 3) okuma gorunumu --
-- Gocmus kayitlarda bos tarih 1899-12-31 / 1990-01-01 sentinel'i; ekranda tarih
--   gibi gosterilmemeli - NULL'a cevrilir.
create or replace view public.v_belge_satir_izlem as
select i.id,
       i.belge_id,
       i.belge_satir_id,
       i.stok_id,
       i.seri_lot_id,
       l.lot_no,
       l.seri_no,
       case when l.uretim_tarihi in (timestamp '1899-12-31 00:00', timestamp '1990-01-01 00:00')
            then null else l.uretim_tarihi end as uretim_tarihi,
       case when l.son_kullanma_tarihi in (timestamp '1899-12-31 00:00', timestamp '1990-01-01 00:00')
            then null else l.son_kullanma_tarihi end as son_kullanma_tarihi,
       i.izlem_tur,
       i.belge_tur,
       i.durum,
       i.adet,
       i.kalan
  from public.stok_izleme i
  join public.stok_seri_lot l on l.id = i.seri_lot_id;

comment on view public.v_belge_satir_izlem is
  'Belge satirinin lot/seri dagilimi (114). Bos tarih sentinel''leri NULL gosterilir.';

do $$
declare v_lot integer; v_izlem integer;
begin
    select count(*) into v_lot from public.stok_seri_lot;
    select count(*) into v_izlem from public.stok_izleme;
    raise notice '114 tamam: % lot kimligi, % izlem satiri', v_lot, v_izlem;
end $$;

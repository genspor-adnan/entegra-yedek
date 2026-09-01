-- 315: Cihaz tanımı ekranı — randevu ayarları ve kapatma/bakım takvimi.
--
-- Kullanıcı: "cihaz tanımı ekranını yap". Tablo 283'te açılmıştı (kod, ad,
-- modalite, AE Title, oda) ama randevu için gereken hiçbir alan yoktu; cihaz
-- takvimi bu alanlar olmadan çizilemez.
--
-- ALAN ADLARI RANDEVU BÖLÜM AYARIYLA AYNI (randevu_bolum_ayar): randevu motoru
-- ortak - slot üretimi, mola ve çalışma günü mantığı iki yerde farklı isimle
-- durursa ikisi zamanla ayrışır.

alter table public.radyoloji_cihaz
  -- Randevusuz ("walk-in") cihazda istem doğrudan çalışma listesine düşer.
  add column if not exists randevu_verilir  smallint     not null default 1,
  add column if not exists baslangic_saat   varchar(5)   not null default '',
  add column if not exists bitis_saat       varchar(5)   not null default '',
  add column if not exists ogle_baslangic   varchar(5)   not null default '',
  add column if not exists ogle_bitis       varchar(5)   not null default '',
  -- Takvim ızgarasının adımı; randevu SÜRESİ tetkikin protokolünden gelir (314).
  add column if not exists slot_dk          smallint     not null default 15,
  add column if not exists varsayilan_sure  smallint     not null default 15,
  -- Aynı slotta kaç hasta (USG'de iki prob, mamografide tek).
  add column if not exists eszaman          smallint     not null default 1,
  -- Acil istemler için günde ayrılan slot sayısı - normal randevuya kapalıdır.
  add column if not exists acil_slot        smallint     not null default 0,
  -- '1,2,3,4,5' = Pzt-Cum (randevu_bolum_ayar ile aynı biçim).
  add column if not exists calisma_gunleri  varchar(20)  not null default '1,2,3,4,5',
  add column if not exists sorumlu_id       integer references public.taraf(id);

comment on column public.radyoloji_cihaz.randevu_verilir is
  'Cihaza randevu verilir mi (315); 0 = walk-in, istem doğrudan çalışma listesine düşer.';
comment on column public.radyoloji_cihaz.slot_dk is
  'Takvim ızgarasının adımı (315). Randevu süresi çekim protokolünden gelir (314).';
comment on column public.radyoloji_cihaz.acil_slot is
  'Acil istemler için günde ayrılan slot sayısı (315).';

-- ------------------------------------------------------ kapatma / bakım --
-- Bakım, arıza, tatil: takvimde "kapalı" görünür ve randevu verilemez.
-- Cihaz kartının ALTINDAKİ grid bu tabloyu yazar.
create table if not exists public.radyoloji_cihaz_kapatma (
  id            integer generated always as identity primary key,
  cihaz_id      integer not null references public.radyoloji_cihaz(id) on delete cascade,
  baslangic     timestamp not null,
  bitis         timestamp not null,
  -- 1 bakım · 2 arıza · 3 tatil · 9 diğer (kod listesi rad.kapatma).
  neden_tur     smallint not null default 1,
  aciklama      varchar(200) not null default '',
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamp not null default (now())::timestamp,
  degistiren    integer not null default 0,
  degistirme_tarihi timestamp,
  constraint ck_radyoloji_cihaz_kapatma_aralik check (bitis > baslangic)
);

comment on table public.radyoloji_cihaz_kapatma is
  'Cihazın randevuya kapalı olduğu aralıklar (315): bakım, arıza, tatil.';

create index if not exists ix_rad_cihaz_kapatma
    on public.radyoloji_cihaz_kapatma (cihaz_id, baslangic);

-- --------------------------------------------------------- kod listesi --
insert into public.kod_liste (kod, ad)
select 'rad.kapatma', 'Cihaz Kapatma Nedeni'
 where not exists (select 1 from public.kod_liste where kod = 'rad.kapatma');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.deger, 1
  from public.kod_liste l
 cross join (values (1, 'Bakım'), (2, 'Arıza'), (3, 'Tatil'), (9, 'Diğer')) as v(deger, ad)
 where l.kod = 'rad.kapatma'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ------------------------------------------------- mevcut cihaz tohumu --
-- 283'te açılan tek cihaz kaydı randevu ayarsız kalmasın (mesai boşsa takvim
-- çizilemez); yalnız BOŞ olanlar doldurulur, kullanıcının girdiği ezilmez.
update public.radyoloji_cihaz
   set baslangic_saat = case when baslangic_saat = '' then '08:00' else baslangic_saat end,
       bitis_saat     = case when bitis_saat = ''     then '18:00' else bitis_saat end,
       ogle_baslangic = case when ogle_baslangic = '' then '12:30' else ogle_baslangic end,
       ogle_bitis     = case when ogle_bitis = ''     then '13:30' else ogle_bitis end;

-- 283 tohumundaki cihaz ŞUBESİZ (sube_id = 0) kalmıştı: liste şube süzmesi
-- yaptığı için ekranda hiç görünmüyordu. Şubesiz cihazlar ilk şubeye alınır.
update public.radyoloji_cihaz
   set sube_id = (select min(id) from public.sube)
 where coalesce(sube_id, 0) = 0
   and exists (select 1 from public.sube);

-- 296: BAŞVURU UZANTISI (belge_basvuru) — bölüm ve hekim.
--
-- Kullanıcı: başvuru kartında "Satış Temsilcisi" yerine BAŞVURULAN BÖLÜM,
-- "Depo" yerine DOKTOR seçimi olsun; doktor listesi seçilen bölüme göre
-- süzülsün. İkisi de randevu tarafında var (randevu.bolum, randevu.hekim_id)
-- ama belgede yoktu: başvuru listesindeki Poliklinik/Doktor kolonları
-- randevudan okunuyordu, yani RANDEVUSUZ açılan başvuruda boş kalıyordu ve
-- kayıt kabul görevlisi bölüm/hekim giremiyordu.
--
-- NEDEN AYRI TABLO (kullanıcı kararı): alanlar yalnız BAŞVURUDA (tür 19)
-- anlamlı. Ana belge tablosu 80 kolona yaklaştı ve her yeni modül birkaç kolon
-- daha ekliyor; başvuruya özgü alanlar 1:1 uzantıda durur — sevkiyat
-- (belge_sevkiyat) ve hasta (taraf_hasta) uzantılarındaki desenin aynısı.
-- Satır YALNIZ bilgi girilince açılır.

create table if not exists public.belge_basvuru (
    id                integer primary key
                      references public.belge(id) on delete cascade,
    bolum_id          integer references public.departman(id),
    hekim_id          integer references public.taraf(id),
    -- ÖDEYEN KURUM (289) da buraya taşındı: yalnız başvuruda anlamlı, ana
    --   tabloda duruyordu.
    odeyen_kurum_id   integer references public.taraf(id),
    ekleyen           integer not null default 0,
    ekleme_tarihi     timestamp not null default now()::timestamp,
    degistiren        integer not null default 0,
    degistirme_tarihi timestamp
);

alter table public.belge_basvuru
  add column if not exists odeyen_kurum_id integer references public.taraf(id);

comment on table  public.belge_basvuru is
  'Başvuruya (tür 19) özgü başlık alanları (296) - belge ile 1:1.';
comment on column public.belge_basvuru.bolum_id is
  'Başvurulan bölüm - departman.id (randevu_verilebilir olanlar).';
comment on column public.belge_basvuru.hekim_id is
  'Başvuruyu karşılayan hekim - taraf.id (randevu verilebilen personel).';

-- Liste ekranı bölüme/hekime göre süzer ve gruplar.
create index if not exists ix_belge_basvuru_bolum on public.belge_basvuru (bolum_id)
    where bolum_id is not null;
create index if not exists ix_belge_basvuru_hekim on public.belge_basvuru (hekim_id)
    where hekim_id is not null;

-- Ana tabloya kolon ekleme denemesi geri alınır (aynı numaranın ilk hâli).
alter table public.belge drop constraint if exists fk_belge_bolum;
alter table public.belge drop constraint if exists fk_belge_hekim;
drop index if exists public.ix_belge_bolum;
drop index if exists public.ix_belge_hekim;
alter table public.belge drop column if exists bolum_id;
alter table public.belge drop column if exists hekim_id;

create index if not exists ix_belge_basvuru_kurum on public.belge_basvuru (odeyen_kurum_id)
    where odeyen_kurum_id is not null;

-- ---------------------------------------------------------- geçmiş veri ----
-- 1) Randevudan dönüşen başvurularda bölüm/hekim ZATEN VAR (randevu.belge_id
--    bağı); uzantıya taşınır ki liste ve kart tek yerden okusun.
insert into public.belge_basvuru (id, bolum_id, hekim_id)
select b.id, r.bolum, r.hekim_id
  from public.belge b
  join public.randevu r on r.belge_id = b.id
 where b.tur = 19
   and (r.bolum is not null or r.hekim_id is not null)
   and not exists (select 1 from public.belge_basvuru bb where bb.id = b.id);

-- 2) Ödeyen kurum ana tablodan uzantıya. Satırı olmayan belgeye açılır, olana
--    yazılır; sonra ana tablodaki kolon düşürülür (kaynak tek olsun).
insert into public.belge_basvuru (id, odeyen_kurum_id)
select b.id, b.odeyen_kurum_id
  from public.belge b
 where b.odeyen_kurum_id is not null
   and not exists (select 1 from public.belge_basvuru bb where bb.id = b.id)
on conflict (id) do nothing;

update public.belge_basvuru bb
   set odeyen_kurum_id = b.odeyen_kurum_id
  from public.belge b
 where b.id = bb.id
   and b.odeyen_kurum_id is not null
   and bb.odeyen_kurum_id is null;

-- Görünüm ana tablodaki kolona bağlıydı; uzantıdan okusun (yoksa DROP COLUMN
--   "other objects depend on it" ile düşer).
create or replace view public.v_radyoloji_worklist as
 SELECT i.id,
    i.sube_id,
    i.accession_no,
    i.durum,
    i.oncelik,
    i.modalite,
    coalesce(md.ad, ''::character varying) AS modalite_adi,
    coalesce(dd.ad, ''::character varying) AS durum_adi,
    i.cekim_tarihi,
    i.hasta_id,
    coalesce(h.unvan, ''::character varying) AS hasta_adi,
    coalesce(hz.kod, ''::character varying) AS tetkik_kodu,
    coalesce(hz.ad, ''::character varying) AS tetkik_adi,
    coalesce(ih.unvan, nullif(i.dis_hekim_ad::text, ''::text)::character varying) AS isteyen,
    coalesce(ik.unvan, ''::character varying) AS isteyen_kurum,
    i.belge_id,
    b.belge_no,
    coalesce(ok.unvan, ''::character varying) AS odeyen_kurum,
    r.id AS rapor_id,
    coalesce(r.durum::integer, 0) AS rapor_durum,
    coalesce(ry.unvan, ''::character varying) AS raporlayan,
    round(extract(epoch from now()::timestamp without time zone
                  - coalesce(i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN taraf ih ON ih.id = i.istek_hekim_id
     LEFT JOIN taraf ik ON ik.id = i.istek_kurum_id
     LEFT JOIN belge b ON b.id = i.belge_id
     LEFT JOIN belge_basvuru bb ON bb.id = b.id
     LEFT JOIN taraf ok ON ok.id = bb.odeyen_kurum_id
     LEFT JOIN radyoloji_rapor r ON r.istem_id = i.id AND r.ust_rapor_id IS NULL
     LEFT JOIN taraf ry ON ry.id = coalesce(r.onaylayan_id, r.yazan_id)
     LEFT JOIN kod_deger md ON md.deger = i.modalite AND md.liste_id =
         (SELECT kod_liste.id FROM kod_liste WHERE kod_liste.kod::text = 'rad.modalite'::text)
     LEFT JOIN kod_deger dd ON dd.deger = i.durum AND dd.liste_id =
         (SELECT kod_liste.id FROM kod_liste WHERE kod_liste.kod::text = 'rad.istem_durum'::text);

alter table public.belge drop column if exists odeyen_kurum_id;

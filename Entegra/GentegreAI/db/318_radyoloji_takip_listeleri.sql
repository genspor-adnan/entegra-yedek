-- 318: Radyoloji takip listeleri — kritik bulgu, konsültasyon, sonuç teslim.
--
-- Üçünün de VERİSİ giriliyor (rapor ekranından) ama hiçbiri toplu görülemiyor:
-- "açık kritik bulgu var mı", "hangi konsültasyon cevap bekliyor", "kimin
-- raporu alınmadı" sorularının cevabı bugün istem istem bakmakla veriliyor.
--
-- Bu göç, o üç listeyi besleyecek eksik alanları ve görünümleri ekler.
-- Yeni tablo YOK - mevcut radyoloji_kritik_bulgu / _konsultasyon / _teslim
-- tabloları kullanılır.

-- ------------------------------------------------------- kritik bulgu ----
-- Kritik bulgu iki adımdır: (1) radyolog "bu tetkikte kritik bulgu var" der
-- (radyoloji_istem.kritik = 1), (2) hekime HABER VERİR (bu tabloya satır).
-- Aradaki boşluk listenin asıl konusudur: işaretlenmiş ama bildirilmemiş.
-- Üçüncü adım teyittir - karşı tarafın aldığını doğrulaması hukuki izdir.
alter table public.radyoloji_kritik_bulgu
  add column if not exists teyit_alindi   smallint not null default 0,
  add column if not exists kapatan_id     integer references public.taraf(id),
  add column if not exists kapatma_zamani timestamp;

comment on column public.radyoloji_kritik_bulgu.teyit_alindi is
  'Bildirilen hekim bulguyu aldığını teyit etti mi (318).';
comment on column public.radyoloji_kritik_bulgu.kapatma_zamani is
  'Takip kapatıldığı an - kapatılmayan kayıt listede açık durur (318).';

create index if not exists ix_rad_kritik_acik
    on public.radyoloji_kritik_bulgu (istem_id)
 where kapatma_zamani is null;

-- ------------------------------------------------------- konsültasyon ----
alter table public.radyoloji_konsultasyon
  add column if not exists tip  smallint not null default 1,
  add column if not exists acil smallint not null default 0;

comment on column public.radyoloji_konsultasyon.tip is
  'Görüş / ikinci okuma / klinik korelasyon (318, kod listesi rad.konsultasyon_tip).';

-- ---------------------------------------------------------- teslim -------
-- Tek "tur" kolonu bir teslimde birden çok kalem verilmesini anlatamıyordu:
-- hastaya aynı anda rapor + film + CD verilir. Kalemler ayrı bayrak oldu;
-- eski satırlar mevcut tur değerinden doldurulur.
alter table public.radyoloji_teslim
  add column if not exists rapor_verildi   smallint not null default 0,
  add column if not exists film_verildi    smallint not null default 0,
  add column if not exists cd_verildi      smallint not null default 0,
  add column if not exists dijital_verildi smallint not null default 0;

update public.radyoloji_teslim
   set rapor_verildi   = case when tur = 2 then 1 else rapor_verildi end,
       film_verildi    = case when tur = 4 then 1 else film_verildi end,
       cd_verildi      = case when tur = 3 then 1 else cd_verildi end,
       dijital_verildi = case when tur in (1, 5) then 1 else dijital_verildi end
 where rapor_verildi + film_verildi + cd_verildi + dijital_verildi = 0;

-- --------------------------------------------------------- kod listeleri --
insert into public.kod_liste (kod, ad)
select v.kod, v.ad
  from (values ('rad.kritik_yol',      'Kritik Bulgu Bildirim Yolu'),
               ('rad.konsultasyon_tip','Konsültasyon Tipi'),
               ('rad.konsultasyon_durum','Konsültasyon Durumu')) v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad)
select kl.id, v.deger, v.ad
  from (values ('rad.kritik_yol', 1, 'Telefon'),
               ('rad.kritik_yol', 2, 'Yüz yüze'),
               ('rad.kritik_yol', 3, 'Mesaj / sistem'),
               ('rad.konsultasyon_tip', 1, 'Görüş'),
               ('rad.konsultasyon_tip', 2, 'İkinci okuma'),
               ('rad.konsultasyon_tip', 3, 'Klinik korelasyon'),
               ('rad.konsultasyon_durum', 1, 'Bekliyor'),
               ('rad.konsultasyon_durum', 2, 'Cevaplandı'),
               ('rad.konsultasyon_durum', 0, 'İptal')) v(liste, deger, ad)
  join public.kod_liste kl on kl.kod = v.liste
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = kl.id and d.deger = v.deger);

-- ================================================ kritik bulgu takibi ====
-- Satır = KRİTİK İŞARETLİ İSTEM (bildirim satırı değil): bildirilmemiş olan
-- da listede görünmeli - listenin var oluş sebebi zaten o.
create or replace view public.v_radyoloji_kritik_takip as
select i.id                                   as istem_id,
       i.sube_id,
       i.accession_no,
       i.modalite,
       i.hasta_id,
       coalesce(h.unvan, '')                  as hasta,
       coalesce(hz.ad, '')                    as tetkik,
       r.onay_tarihi,
       i.cekim_tarihi,
       kb.id                                  as bildirim_id,
       coalesce(kb.bulgu, '')                 as bulgu,
       coalesce(kb.bildirilen_ad, '')         as bildirilen_ad,
       kb.bildiren_id,
       coalesce(bd.unvan, '')                 as bildiren,
       kb.yol,
       kb.bildirim_zamani,
       coalesce(kb.teyit_alindi, 0)           as teyit_alindi,
       kb.kapatma_zamani,
       -- DURUM: 1 bildirilmedi, 2 bildirildi (teyit yok), 3 teyitli, 4 kapatıldı.
       case when kb.id is null                     then 1
            when kb.kapatma_zamani is not null     then 4
            when coalesce(kb.teyit_alindi, 0) = 1  then 3
            else 2 end                        as takip_durum,
       -- SÜRE: bulgunun doğduğu an (rapor / çekim / istem) ile bildirim ya da
       --   şimdi arasındaki dakika - listenin sıralama ve kırmızı ölçüsü.
       (extract(epoch from
          (coalesce(kb.bildirim_zamani, now()::timestamp)
           - coalesce(r.onay_tarihi, r.yazma_tarihi, i.cekim_tarihi, i.ekleme_tarihi))) / 60)::int
                                              as gecen_dk
  from public.radyoloji_istem i
  left join public.taraf h  on h.id = i.hasta_id
  left join public.hizmet hz on hz.id = i.hizmet_id
  -- Bulgunun dogdugu an rapordan gelir: istemde rapor zamani kolonu yok.
  left join lateral (
       select x.* from public.radyoloji_rapor x
        where x.istem_id = i.id order by x.id desc limit 1) r on true
  -- Bir isteme birden çok bildirim yazılabilir (farklı hekimlere): takipte
  --   SON bildirim geçerlidir.
  left join lateral (
       select k.* from public.radyoloji_kritik_bulgu k
        where k.istem_id = i.id order by k.id desc limit 1) kb on true
  left join public.taraf bd on bd.id = kb.bildiren_id
 where coalesce(i.kritik, 0) = 1 and coalesce(i.durum, 1) > 0;

comment on view public.v_radyoloji_kritik_takip is
  'Kritik bulgu takip listesi (318): işaretli istem + son bildirim + geçen süre.';

-- ================================================= teslim takibi =========
-- Satır = TESLİME HAZIR İSTEM: raporu onaylı (durum >= 5) olan istemler.
-- Teslim satırı yoksa "hazır", varsa teslim bilgisi görünür.
create or replace view public.v_radyoloji_teslim_takip as
select i.id                                   as istem_id,
       i.sube_id,
       i.accession_no,
       i.modalite,
       i.hasta_id,
       coalesce(h.unvan, '')                  as hasta,
       coalesce(h.telefon, '')                as telefon,
       coalesce(hz.ad, '')                    as tetkik,
       r.onay_tarihi,
       coalesce(ry.unvan, '')                 as radyolog,
       i.durum                                as istem_durum,
       coalesce(i.cd_istendi, 0)              as cd_istendi,
       t.id                                   as teslim_id,
       t.teslim_zamani,
       coalesce(t.alan_ad, '')                as alan_ad,
       coalesce(t.alan_yakinlik, '')          as alan_yakinlik,
       coalesce(te.unvan, '')                 as teslim_eden,
       coalesce(t.rapor_verildi, 0)           as rapor_verildi,
       coalesce(t.film_verildi, 0)            as film_verildi,
       coalesce(t.cd_verildi, 0)              as cd_verildi,
       coalesce(t.dijital_verildi, 0)         as dijital_verildi,
       case when t.id is null then 1 else 2 end as takip_durum,   -- 1 hazır, 2 teslim
       (extract(epoch from
          (coalesce(t.teslim_zamani, now()::timestamp)
           - coalesce(r.onay_tarihi, i.cekim_tarihi, i.ekleme_tarihi))) / 60)::int as bekleme_dk
  from public.radyoloji_istem i
  left join public.taraf h  on h.id = i.hasta_id
  left join public.hizmet hz on hz.id = i.hizmet_id
  left join lateral (
       select x.* from public.radyoloji_rapor x
        where x.istem_id = i.id order by x.id desc limit 1) r on true
  left join public.taraf ry on ry.id = coalesce(r.onaylayan_id, r.yazan_id)
  left join lateral (
       select x.* from public.radyoloji_teslim x
        where x.istem_id = i.id order by x.id desc limit 1) t on true
  left join public.taraf te on te.id = t.teslim_eden_id
 where coalesce(i.durum, 1) >= 5;

comment on view public.v_radyoloji_teslim_takip is
  'Sonuç teslim listesi (318): onaylı raporu olan istemler + son teslim kaydı.';

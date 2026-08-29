-- 252: PERSONELDE "randevu verilebilir" (kullanıcı: "personele de Randevu
-- Verilebilir ekle; randevu verilen bölümle randevu verilen personel buluşmuş
-- olur").
--
-- Bölüm tarafındaki karşılığı departman.randevu_verilebilir (251). İkisi
-- birleşince "hekim" tanımı çıkar: randevu verilen bir bölümde çalışan,
-- randevu verilebilir personel. Ayrı bir hekim tablosu açmaya gerek kalmıyor -
-- aynı kişi hem personel hem hekim.

alter table public.taraf add column if not exists randevu_verilebilir smallint not null default 0;
comment on column public.taraf.randevu_verilebilir is
  'Bu personele randevu verilebilir mi (252) - hekim/uygulayıcı.';

create index if not exists ix_taraf_randevu_verilebilir
  on public.taraf (randevu_verilebilir) where randevu_verilebilir = 1;

-- Halihazırda randevu verilmiş kişiler zaten hekimdir; bayrak onlar için açılır.
update public.taraf t
   set randevu_verilebilir = 1
 where t.randevu_verilebilir = 0
   and exists (select 1 from public.randevu r where r.hekim_id = t.id);

-- ------------------------------------------------------------------ lookup --
-- Randevu kartındaki "Hekim" listesi: randevu verilen bölümde çalışan,
--   randevu verilebilir personel. Bölüm ataması yapılmamış personel de
--   listelenir (bölüm zorunlu değil) - yoksa yeni açılan hekim, departmanı
--   seçilene kadar hiçbir randevuya atanamazdı.
create or replace view public.v_hekim_lookup as
select t.id, t.unvan as ad, case when coalesce(t.durum, 1) = 1 then 1 else 0 end as aktif
  from public.taraf t
 where t.personel = 1 and t.randevu_verilebilir = 1;

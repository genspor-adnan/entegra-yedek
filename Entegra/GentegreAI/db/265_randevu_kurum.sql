-- 265: RANDEVUYA ÖDEYEN KURUM (kullanıcı: "randevuya hastanın kurumu da
-- eklenmeli").
--
-- Hastanın aktif poliçesi (taraf_hasta_kurum, 248) randevu verilirken KOPYALANIR:
-- poliçe sonradan değişse bile o randevunun hangi kuruma yazıldığı sabit kalır.
-- Başvuruya dönüşünce belge.odeyen_kurum_id'ye (249) buradan geçer.

alter table public.randevu add column if not exists kurum_id integer
  references public.taraf(id);
comment on column public.randevu.kurum_id is
  'Randevuyu ödeyecek anlaşmalı kurum (265). Boşsa hasta kendi öder.';

create index if not exists ix_randevu_kurum on public.randevu (kurum_id)
  where kurum_id is not null;

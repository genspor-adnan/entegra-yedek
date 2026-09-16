-- 708: SEANS İŞLEM SATIRINA UYGULAMA AYRINTISI (mockup dis_seans_kaydi.html,
-- kullanıcı: "seans kartını mockup gibi yapılan işlemler listesiyle güncelle").
--
-- Bir seansta birden çok işlem yapılır; uygulama notu, komplikasyon ve
-- "bu satırın sonraki seans planı" işleme aittir, seansa değil - 26 kanalın
-- çalışma boyu 24 kompozitin notuna karışmasın. Seans genelinde kalanlar:
-- hastaya talimat, sonraki seans önerisi, anestezi (dis_seans).
alter table public.dis_seans_islem add column if not exists uygulama_notu varchar(1000) not null default '';
alter table public.dis_seans_islem add column if not exists komplikasyon  varchar(300)  not null default '';
alter table public.dis_seans_islem add column if not exists sonraki_plan  varchar(300)  not null default '';
alter table public.dis_seans_islem add column if not exists calisma_boyu  varchar(120)  not null default '';
comment on column public.dis_seans_islem.calisma_boyu is 'Endodonti çalışma boyu metni: "MB 20,5 · DB 20 · P 21,5" (708); json alanı ileride cihazdan dolar.';

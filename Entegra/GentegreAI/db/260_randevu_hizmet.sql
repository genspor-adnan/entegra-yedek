-- 260: RANDEVUYA HİZMET (kullanıcı: takvimde hekim sütununda saat seçilince
-- bölüm ve hekim kendiliğinden dolsun, "ben hasta ve hizmet adını seçeyim").
--
-- Hizmet = randevunun konusu (Poliklinik Muayenesi, Kontrol, Tetkik...).
-- Başvuruya dönüştürülürken kalem satırı buradan geleceği için serbest metin
-- değil, hizmet kartına referans.

alter table public.randevu add column if not exists hizmet_id integer
  references public.hizmet(id);
comment on column public.randevu.hizmet_id is 'Randevunun konusu - hizmet kartı (260).';

create index if not exists ix_randevu_hizmet on public.randevu (hizmet_id)
  where hizmet_id is not null;

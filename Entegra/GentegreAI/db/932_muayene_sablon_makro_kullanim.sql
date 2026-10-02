-- =====================================================================
--  932_muayene_sablon_makro_kullanim.sql
--  ŞABLON MAKROSU KULLANIM SAYISI (kullanıcı: "makro çipine tıklayınca makro
--  kullanım sayısı artsın").
--
--  Kurum makrosunda (metin_makro, 411) `kullanim` vardı ama hiçbir yol
--  artırmıyordu; şablon makrosunda (931) kolon yoktu. Muayenede makro
--  alana yazıldığında (ipucu çipi ya da kısayol + boşluk) sunucu ucu
--  (`POST /api/muayene-sablon/makro-kullanim`) ilgili satırı artırır.
--  "Kopyala (bana)" sayacı kopyalamaz: kopya sıfırdan başlar.
-- =====================================================================
\set ON_ERROR_STOP on

alter table public.muayene_sablon_makro
  add column if not exists kullanim integer not null default 0;

do $$ begin raise notice '932 tamam: muayene_sablon_makro.kullanim'; end $$;

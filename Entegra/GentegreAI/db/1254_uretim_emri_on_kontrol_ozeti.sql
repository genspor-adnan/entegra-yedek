-- =============================================================================
--  1254  ÜRETİM EMRİ — SERBEST BIRAKMA ÖN KONTROL ÖZETİ (liste kolonu)
--
--  Mockup: Ekranlar/Uretim/uretim_emri_listesi_v2.html (denetimli: "Ön kontrol 7/7 ✍" kolonu).
--  Kullanıcı 04.11.2026: "üretim emri ve üretim fişi listelerini bu mockuplara uygun yap".
--
--  Ön kontroller (ağaç sürümü, rota, malzeme, kapasite, izlenmeyenler) sunucuda hesaplanır
--  (UretimFisiUclari.OnKontrolAsync); listede her satır için yeniden koşturulmaz - SERBEST BIRAKMA
--  anında geçen / toplam özeti ve e-imza işareti emre yazılır ("7/7 ✍"). Onaylı ama henüz serbest
--  bırakılmamış emirde boş kalır; canlı sonuç emir kartı › Ön Kontroller sekmesindedir. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.uretim_emri add column if not exists on_kontrol varchar(20) not null default '';
comment on column public.uretim_emri.on_kontrol is
  'Serbest bırakma anındaki ön kontrol özeti: "geçen/toplam" (+ " ✍" e-imzalı ise). Boş = henüz serbest bırakılmadı. (1254)';

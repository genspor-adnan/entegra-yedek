\set ON_ERROR_STOP on
-- ============================================================================
--  1207 — bildirim: gönderime alınma anı (gonderim_bas)
--
--  Kod inceleme 30.10.2026 K37: "askıda kalan" kurtarma (durum 2'de takılı
--  satır) ekleme_tarihi'ne bakıyordu - gönderime alınma anı tutulmuyordu.
--  Eklendikten 2 dk sonra servis çökerken 2'de kalan satır 10 dk kuralına
--  girmiyor, bir sonraki yeniden başlatmaya kadar gitmiyordu; iki örnekte ise
--  yeni alınmış satır eski diye geri çevrilip SMS iki kez gidebiliyordu.
--  SiradakileriAlAsync bu kolonu damgalar, kurtarma buna bakar.
-- ============================================================================
begin;

alter table public.bildirim add column if not exists gonderim_bas timestamptz;
comment on column public.bildirim.gonderim_bas is '1207: satır gönderime alındığında (durum 2) damgalanır; askıda kalan kurtarması buna bakar.';

commit;

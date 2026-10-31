-- ============================================================================
--  1200 — Radyoloji raporu: uzmana gönderirken NOT
--
--  Kullanıcı 28.10.2026: "bildirim ve not ekle" (mockup
--  Ekranlar/Radyoloji/radyoloji_rapor_yazan_onaylayan.html, D bölümü).
--  Asistan "Uzmana Gönder"de uzmana kısa bir not bırakır ("sol memedeki
--  lezyona özellikle bakar mısınız?"); uzman raporu açınca bandın altında
--  sarı şerit olarak görür. Her gönderimde yeniden yazılır (boş = not yok).
--  Yalnız EKLEYİCİ.
-- ============================================================================
begin;

alter table public.radyoloji_rapor
    add column if not exists onay_notu varchar(500) not null default '';

comment on column public.radyoloji_rapor.onay_notu is
  '1200: Uzmana Gönder''de onaylayacak uzmana bırakılan not (her gönderimde yenilenir).';

commit;

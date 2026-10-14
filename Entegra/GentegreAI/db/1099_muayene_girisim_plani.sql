-- =============================================================================
--  1099  MUAYENE - "Hastaya ameliyat ya da girişim planlıyor musunuz?"
--
--  Mockup Ekranlar/Muayene/muayene_karti_v7.html (Değerlendirme / Sonuç),
--  kullanıcı onayı 14.10.2026. Sekmeli kartta Değerlendirme / Sonuç alt
--  grubuna, Çıkış Şekli'nin altına eklenir; mevcut alanlar değişmez.
--
--  NULL = cevaplanmadı (eski muayeneler), 1 = evet, 0 = hayır. Evet/hayır
--  "mantik" değil kod alanı: soru sorulmamışla "hayır" ayrı tutulmalı -
--  0 varsayılanı eski muayenelerin hepsini "hayır" diye işaretlerdi.
-- =============================================================================

alter table public.muayene
    add column if not exists girisim_plani smallint
        constraint ck_muayene_girisim_plani check (girisim_plani in (0, 1));

comment on column public.muayene.girisim_plani is
    'Hekim ameliyat / girişim planlıyor mu (1099): null cevaplanmadı, 1 evet, 0 hayır.';

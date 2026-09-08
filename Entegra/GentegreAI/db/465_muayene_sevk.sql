-- =====================================================================
-- 465 - SEVK / KONSÜLTASYON: NOT · AMBULANS · KONSÜLTASYON SORUSU
--
-- Mockup `muayene_karti.html` "Sevk / Konsültasyon" paneli: Karar · Sevk
-- edilen tesis · Klinik · SEVK NEDENİ / NOTU · AMBULANS, altında konsültasyon
-- isteği tablosu (Branş/Hekim · SORU · İstem · YANIT · Durum).
--
-- SEVK NOTU neden ayrı: `sevk_neden` kodlu bir SKRS alanı ("ileri tetkik",
-- "yatak yok"); karşı hekimin okuyacağı cümle ("STEMI ön tanısı, primer PCI
-- için 112 ile transfer") koda sığmıyor ve koda yazılınca e-Nabız'a geçersiz
-- değer gidiyordu.
--
-- AMBULANS sevkin bir parçasıdır: hastanın kendi imkânıyla mı gittiği yoksa
-- 112 ile mi taşındığı, sevk kâğıdında ve adli olayda sorulan ilk şeydir.
--
-- KONSÜLTASYON SORUSU alt muayenededir: konsültasyon isteği zaten yeni bir
-- muayene olarak açılıyor; sorulan soru o muayenenin `konsultasyon_soru`
-- alanında durur - isteyen hekimin cümlesi, cevaplayanın şikâyet alanına
-- karışmasın.
-- =====================================================================

alter table public.muayene
    add column if not exists sevk_notu          varchar(500) not null default '',
    add column if not exists ambulans           smallint     not null default 0,
    add column if not exists ambulans_zaman     timestamp,
    add column if not exists konsultasyon_soru  varchar(500) not null default '';

comment on column public.muayene.ambulans is
    'Sevk ulasimi: 0 belirtilmemis, 1 112 cagrildi, 2 kurum ambulansi, 3 hasta kendi imkani (465).';
comment on column public.muayene.konsultasyon_soru is
    'Konsultasyon isteginde ISTEYEN hekimin sorusu (465).';

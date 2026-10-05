-- 971 GÖZ ÖYKÜSÜ (mockup Ekranlar/Goz/goz_muayene_karti_v4.html "Şikâyet & göz öyküsü")
--
-- Göz öyküsü HASTANINDIR, muayenenin değil: ameliyat, lazer, travma, düzeltme (gözlük / lens),
--   ambliyopi, göz damlaları (uyumla) ve aile öyküsü bir sonraki ziyarette de geçerlidir.
--   Her muayenede yeniden yazdırmak yerine hasta başına tek satır tutulur; muayene ekranı
--   okur ve günceller (son güncelleyen / zaman kayıtlı).
--
-- Yapı jsonb: alanlar ekran sürümüyle büyüyecek (yeni bir öykü sorusu şema değişikliği
--   istemesin). Şikâyet ve hikâye genel muayenenin alanları olarak kalır (muayeneye özgü).

create table if not exists public.goz_hasta_oyku (
    hasta_id          integer primary key references public.taraf(id),
    veri              jsonb       not null default '{}'::jsonb,
    ekleyen           integer     not null default 0,
    ekleme_tarihi     timestamptz not null default now(),
    degistiren        integer,
    degistirme_tarihi timestamptz
);

comment on table public.goz_hasta_oyku is
  'Göz öyküsü (971): hasta başına tek satır jsonb - ameliyat, lazer, travma, düzeltme, ambliyopi, '
  'damlalar [{ad, goz, doz, uyum}], aile (glokom, amd, keratokonus, retina).';

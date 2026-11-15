-- 1348 - Başvuru kartı etiket çevirileri (16.11.2026): kullanıcı etiketleri kısalttı -
--   "Başvuru Tarihi / Saati" → "Başvuru Tarihi", "Kendi isteğiyle geldi (gönderen yok)" → "Kendi İsteği",
--   "e-Nabız Bildirimi" → "e-Nabız", "Teleradyoloji Bildirimi" → "Teleradyoloji".
--   Çeviri anahtarı metnin kendisidir; eski anahtarın İngilizcesi yeni anahtara taşınır, eskisi kalır (zararsız).
insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Başvuru Tarihi', 1, 'Encounter date'),
    ('etiket', 'Kendi İsteği',   1, 'Own request'),
    ('etiket', 'e-Nabız',        1, 'e-Nabiz'),
    ('etiket', 'Teleradyoloji',  1, 'Teleradiology')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin, degistirme_tarihi = now();

-- 1349 - Karşıt alan ipucu çevirisi (kod inceleme 16.11.2026): randevu kartı "Kendi İsteği" kutusunun üstünde
--   çıkan ipucu metni 1348'de unutulmuştu; İngilizce arayüzde Türkçe kalıyordu.
insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'İşaretlenince karşıt alan temizlenir', 1, 'Checking this clears the opposing field')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin, degistirme_tarihi = now();

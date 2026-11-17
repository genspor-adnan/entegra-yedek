-- 1358 - Kayıt Kabul ayar ekranlarının adı (17.11.2026): "Hasta Kartı Ayarları" → "Hasta Ayarları",
--   "Başvuru Kartı Ayarları" → "Başvuru Ayarları" (kullanıcı). Yetki matrisi adı + YZ rehber kataloğu.
update public.yetki set ad = 'Hasta Ayarları (Kayıt Kabul)'    where kod = 'kayit_kabul.hasta_ayar';
update public.yetki set ad = 'Başvuru Ayarları (Kayıt Kabul)'  where kod = 'kayit_kabul.ayar';
update public.ai_rehber_ekran set baslik = 'Hasta Ayarları', menu_ad = 'Hasta Ayarları',
       yol = 'Kayıt Kabul › Ayarlar › Hasta Ayarları' where kaynak = 'hasta-karti-ayarlar';
update public.ai_rehber_ekran set baslik = 'Başvuru Ayarları', menu_ad = 'Başvuru Ayarları',
       yol = 'Kayıt Kabul › Ayarlar › Başvuru Ayarları' where kaynak = 'basvuru-karti-ayarlar';

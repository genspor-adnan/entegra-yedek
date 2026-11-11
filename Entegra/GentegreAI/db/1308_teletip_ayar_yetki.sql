-- 1308 - Kurum Teletıp ayar ekranı yetkisi
--
-- Kullanıcı 11.11.2026: "kurum Teletıp ayar ekranını yap" (mockup teletip_mirth.html §5). Ekran: Teletıp gönderimi
-- açık / kapalı, kurum SKRS kodu, MEDULA tesis kodu, şube no, MSH-3 firma kodu, karakter seti, Mirth K1 adresi; Mirth
-- REST ve Bakanlık uçları yalnız görüntülenir. Yetki ekran bazlı: radyoloji.teletip.ayar - kurum kimliğini değiştirir
-- (yanlış SKRS mesajı başka kurumun hesabına düşürür), bu yüzden YALNIZ sistem yöneticisi rolüne (1) verilir; diğer
-- rollere rol ekranından açılır.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

insert into public.yetki (kod, ad, grup, tur, urun_modu, sira, aktif)
select 'radyoloji.teletip.ayar', 'Teletıp Ayarları (Radyoloji)', 'Radyoloji', 0, 2, 283, 1
 where not exists (select 1 from public.yetki where kod = 'radyoloji.teletip.ayar');
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1 from public.yetki y
 where y.kod = 'radyoloji.teletip.ayar'
   and not exists (select 1 from public.rol_yetki r where r.rol_id = 1 and r.yetki_id = y.id);
update public.rol r set yetki_surumu = yetki_surumu + 1
 where r.id = 1;

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama)
select 'teletip-ayar', '/teletip-ayar', 'Teletıp Ayarları', 'Radyoloji › Ayarlar › Teletıp Ayarları', 'Radyoloji',
       'Teletıp Ayarları', 'radyoloji.teletip.ayar', 2,
       'teletip ayar skrs medula tesis kodu firma kodu msh-3 mirth hl7 adres bakanlık teleradyoloji aç kapat',
       'Kurumun Teletıp kimliği (SKRS, MEDULA tesis, firma kodu) ve Mirth K1 bağlantısı; gönderimi açar / kapatır.'
 where not exists (select 1 from public.ai_rehber_ekran r where r.kaynak = 'teletip-ayar');

commit;

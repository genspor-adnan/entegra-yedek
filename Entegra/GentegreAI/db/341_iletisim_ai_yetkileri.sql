-- 341: "İLETİŞİM & AI" MENÜSÜ - Mesajlar ve Yapay Zeka yetkileri.
--
-- Kullanıcı: "ana sayfada mockup'taki gibi Ana Sayfa'dan sonra İletişim & AI
-- ana menüsü, altına Mesajlar ve Yapay Zeka alt menüleri - tüm modlar için."
--
-- Mockup karşılığı: Ekranlar/gentegre_data.js → MODULLER[0] ("İletişim & AI":
-- umesajlar.html + ai_asistan.html). Menü ürün moduna BAĞLI DEĞİL - hem
-- Gentegre AI (ERP) hem GenoTIP AI (HBYS) kurulumunda görünür.
--
-- Ekranlar yetkiye bağlı çizildiği için (Kabuk menüyü `yetki(kod)` ile süzer)
-- iki yetki kodu gerekiyor. Yönetici rolüne açılır; öteki roller Yetki
-- Matrisi'nden verilir.
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, sira) values
    ('mesaj', 'Mesajlar',    'kart', 0, 160),
    ('ai',    'Yapay Zeka',  'kart', 0, 161)
on conflict (kod) do nothing;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod in ('mesaj', 'ai')
on conflict (rol_id, yetki_id) do update
   set gor = 1, ekle = 1, degistir = 1, sil = 1;

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.yetki where kod in ('mesaj', 'ai');
    raise notice '341 tamam: % yetki (mesaj, ai) - Iletisim & AI menusu.', v_adet;
end $$;

-- 980 · MENÜ DÜZENİ: İKON GÖRSELİ
--
-- Kullanıcı 06.10.2026: "ikon da yükleyebilirim". İkon şimdiye kadar yalnız
-- emoji metniydi (varchar(16)); kurumun kendi logosunu/simgesini koyabilmesi
-- için alan metne çevriliyor ve küçük bir `data:` URL'i de kabul ediyor.
--
-- NEDEN AYRI DOSYA DEPOSU DEĞİL: menü ikonu 64x64 PNG, satır sayısı menü düğümü
-- kadar (yüzler mertebesinde) ve ikon menüyle BİRLİKTE okunuyor. Ayrı tabloya
-- koymak her menü çiziminde bir join daha demekti. Boyut sunucuda sınırlanıyor
-- (MenuDuzenUclari: 64 KB) - metin kolonu sınırsız diye sınırsız yüklenmesin.
alter table public.menu_duzen alter column ikon type text;

comment on column public.menu_duzen.ikon is
  'Emoji metni (ör. 📊) ya da küçük data: URL görseli (PNG/SVG, en çok 64 KB).';

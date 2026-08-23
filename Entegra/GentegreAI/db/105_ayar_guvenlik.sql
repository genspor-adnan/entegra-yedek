-- ============================================================================
--  Gentegre AI — Genel Ayarlar: Güvenlik sekmesi
--  105_ayar_guvenlik.sql
--
--  Bu dort ayari KimlikServisi ZATEN referans tablosundan okuyordu
--  (KimlikServisi.AyarAsync), ama satirlari yoktu: her giriste appsettings
--  varsayilani kullaniliyor ve kimse degeri goremiyor/degistiremiyordu.
--  Satirlar appsettings'teki DEGERLERLE aciliyor - davranis degismez.
--
--    guvenlik.jwt_dakika          erisim jetonu omru (appsettings: 30)
--    guvenlik.refresh_gun         "oturumu acik tut" omru (appsettings: 30)
--    guvenlik.parola_min_uzunluk  parola en az kac karakter (kodda: 8)
--    guvenlik.tek_oturum          1 ise kullanici tek yerden girebilir (kodda: 0)
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama) values
('guvenlik.jwt_dakika',         '30', 'sayi',   'firma', 'Oturum (erişim jetonu) süresi - dakika'),
('guvenlik.refresh_gun',        '30', 'sayi',   'firma', 'Oturumu açık tutma süresi - gün'),
('guvenlik.parola_min_uzunluk',  '8', 'sayi',   'firma', 'Parola en az kaç karakter olmalı'),
('guvenlik.tek_oturum',          '0', 'mantik', 'firma', 'Kullanıcı aynı anda tek yerden girebilsin')
on conflict (anahtar) do nothing;

insert into public.help (anahtar, dil, baslik, metin) values
('ayar.guvenlik.jwt_dakika', 0, 'Oturum süresi',
 'Kullanıcının erişim jetonu bu kadar dakika geçerlidir; süre dolunca arayüz '
 || 'sessizce yeniler (kullanıcı bir şey hissetmez).'
 || E'\n\n'
 || 'Kısa süre çalıntı jetonun ömrünü kısaltır ama yenileme isteğini sıklaştırır. '
 || 'Tipik aralık 15-60 dakikadır. Değişiklik AÇIK oturumları etkilemez, bir '
 || 'sonraki girişten/yenilemeden itibaren geçerlidir.'),

('ayar.guvenlik.refresh_gun', 0, 'Oturumu açık tutma',
 'Kullanıcı çıkış yapmazsa oturumun kaç gün boyunca yenilenebileceğini belirler. '
 || 'Bu süre dolunca yeniden kullanıcı adı/parola istenir.'
 || E'\n\n'
 || 'Ortak kullanılan bilgisayarlarda kısa (1-7 gün), kişisel cihazlarda uzun '
 || 'tutulur. Değişiklik yalnız yeni oturumlara uygulanır.'),

('ayar.guvenlik.parola_min_uzunluk', 0, 'En az parola uzunluğu',
 'Kullanıcı parolasını değiştirirken kabul edilecek en kısa parola.'
 || E'\n\n'
 || 'Yalnız YENİ parolalar denetlenir; mevcut kısa parolalar çalışmaya devam '
 || 'eder, kullanıcı parolasını değiştirdiğinde kural işler.'),

('ayar.guvenlik.tek_oturum', 0, 'Tek oturum',
 'Açık olduğunda bir kullanıcı aynı anda tek yerden girebilir: yeni giriş, '
 || 'kullanıcının önceki oturumlarını kapatır.'
 || E'\n\n'
 || 'Hesap paylaşımını engellemek istendiğinde açılır. Aynı kişi masaüstü ve '
 || 'telefondan birlikte çalışıyorsa kapalı bırakılmalıdır - aksi halde '
 || 'sürekli birbirini atarlar.')
on conflict (anahtar, dil) do update
   set baslik = excluded.baslik, metin = excluded.metin;

do $$
declare r record;
begin
    for r in select anahtar, deger from public.referans
              where anahtar like 'guvenlik.%' order by anahtar
    loop
        raise notice '105: % = %', r.anahtar, r.deger;
    end loop;
end $$;

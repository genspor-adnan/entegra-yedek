-- =====================================================================
--  657_kabuk_ceviri.sql
--  ANA MENÜ ve ÜST ŞERİT ÇEVİRİSİ (kullanıcı: "ana menü en son da
--  çevir").
--
--  656 liste/menü BAŞLIKLARINI çevirdi; kabuğun kendi metinleri açıkta
--  kaldı: sol menüdeki "Favori" ve "En Son" bölüm başlıkları, üst
--  şeritteki arama kutusu ve ikon ipuçları. Bunlar liste tanımlarından
--  değil bileşenden geliyor, bu yüzden menü taramasına girmemişlerdi.
--
--  Üst şerit metinleri istemcide artık `c(...)` ile sarıldı; sözlükte
--  karşılığı olmayan metin yine Türkçe görünür, dolayısıyla çeviri
--  eklenmesi bu dosyanın işi.
--
--  ALMANCA (dil 2) da yazılır: bu metinler kısa ve karşılıkları
--  tartışmasız ("Favoriten", "Zuletzt"). 656'da Almanca bilerek
--  atlanmıştı - orada 138 uzun ekran adı vardı ve uydurma çeviri,
--  yanlışı "var" gösterip bir daha bakılmamasına yol açardı.
-- =====================================================================

insert into public.ceviri (kapsam, anahtar, dil, metin)
select v.kapsam, v.tr, v.dil, v.karsilik
  from (values
    -- Sol menü bölüm başlıkları
    ('menu', 'Favori',                1::smallint, 'Favourites'),
    ('menu', 'Favori',                2,           'Favoriten'),
    ('menu', 'En Son',                1,           'Recent'),
    ('menu', 'En Son',                2,           'Zuletzt'),
    ('menu', 'Tümü',                  2,           'Alle'),
    -- Üst şerit
    ('etiket', 'Ana sayfa',           1, 'Home'),
    ('etiket', 'Ana sayfa',           2, 'Startseite'),
    ('etiket', 'Komut paleti',        1, 'Command palette'),
    ('etiket', 'Komut paleti',        2, 'Befehlspalette'),
    ('etiket', 'Ara ya da komut yaz…', 1, 'Search or type a command…'),
    ('etiket', 'Ara ya da komut yaz…', 2, 'Suchen oder Befehl eingeben…'),
    ('etiket', 'Çalışılan şube',      1, 'Active branch'),
    ('etiket', 'Çalışılan şube',      2, 'Aktive Filiale'),
    ('etiket', 'Bildirimler',         1, 'Notifications'),
    ('etiket', 'Bildirimler',         2, 'Benachrichtigungen'),
    ('etiket', 'Yardım',              1, 'Help'),
    ('etiket', 'Yardım',              2, 'Hilfe'),
    ('etiket', 'Oturumu kapat',       1, 'Sign out'),
    ('etiket', 'Oturumu kapat',       2, 'Abmelden'),
    ('etiket', 'Tema',                1, 'Theme'),
    ('etiket', 'Tema',                2, 'Design'),
    ('etiket', 'Dil',                 1, 'Language'),
    ('etiket', 'Dil',                 2, 'Sprache'),
    ('etiket', 'Sistem',              1, 'System'),
    ('etiket', 'Sistem',              2, 'System'),
    ('etiket', 'Gündüz',              1, 'Light'),
    ('etiket', 'Gündüz',              2, 'Hell'),
    ('etiket', 'Gece',                1, 'Dark'),
    ('etiket', 'Gece',                2, 'Dunkel'),
    ('etiket', 'salt okuma',          1, 'read only'),
    ('etiket', 'salt okuma',          2, 'schreibgeschützt'),
    ('etiket', 'Favorilere ekle',     1, 'Add to favourites'),
    ('etiket', 'Favorilere ekle',     2, 'Zu Favoriten hinzufügen'),
    ('etiket', 'Favorilerden çıkar',  1, 'Remove from favourites'),
    ('etiket', 'Favorilerden çıkar',  2, 'Aus Favoriten entfernen')
       ) v(kapsam, tr, dil, karsilik)
 where not exists (select 1 from public.ceviri c
                    where c.kapsam = v.kapsam and c.anahtar = v.tr and c.dil = v.dil);

do $kontrol$
begin
    raise notice '657 tamam: dil 1 toplam %, dil 2 toplam %',
        (select count(*) from public.ceviri where dil = 1),
        (select count(*) from public.ceviri where dil = 2);
end $kontrol$;

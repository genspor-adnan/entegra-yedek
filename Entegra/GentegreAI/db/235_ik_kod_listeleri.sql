-- 235: İK kod listeleri (kullanıcı: "ayarlar İK genel sekmesine Departman ve
-- pozisyon comboları ekle, düzenlenebilir olsun").
--
-- Departman listesi zaten vardı ('taraf.departman'); Pozisyon için liste yoktu
-- (taraf.gorev serbest metin). Liste açılıyor ve mevcut dolu görev değerleri
-- tohum olarak aktarılıyor - böylece ayar ekranında düzenlenebilir hale gelir.

-- kod_liste'de 'aktif' kolonu YOK (aktiflik kod_deger'de tutulur).
insert into public.kod_liste (kod, ad)
select 'taraf.gorev', 'Pozisyon'
 where not exists (select 1 from public.kod_liste where kod = 'taraf.gorev');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id,
       row_number() over (order by g.gorev),
       g.gorev,
       row_number() over (order by g.gorev) * 10,
       1, 0
  from public.kod_liste l
  cross join lateral (
       select distinct trim(t.gorev) as gorev
         from public.taraf t
        where t.personel = 1 and coalesce(trim(t.gorev), '') <> ''
  ) g
 where l.kod = 'taraf.gorev'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id);

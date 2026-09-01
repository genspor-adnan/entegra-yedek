-- 325: Prim / hakediş yetkileri ve eksik kod listesi.
--
-- 324 şemayı kurdu; ekranların açılabilmesi için yetki satırları gerekiyor.
-- İki ayrı izin var:
--   * prim              — planları ve hakedişleri görme/düzenleme
--   * prim.donem_kapat  — dönemi KAPATMA: kapanan satır dondurulur ve
--     yeniden hesaplanmaz, yani geri alınamaz bir işlemdir. Prim listesini
--     görebilen herkes dönem kapatamamalı.

insert into public.yetki (kod, ad, grup, tur, sira) values
    ('prim',             'Prim / hakedis',   'kart', 0, 140),
    ('prim.donem_kapat', 'Hakedis donemini kapat', 'kart', 1, 141)
on conflict (kod) do nothing;

-- Yönetici: yeni yetkiler de açık.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod in ('prim', 'prim.donem_kapat')
on conflict (rol_id, yetki_id) do update
   set gor = 1, ekle = 1, degistir = 1, sil = 1;

-- Salt okuyucu: hakedişi görür, dönem kapatamaz.
insert into public.rol_yetki (rol_id, yetki_id, gor)
select r.id, y.id, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'salt_okur' and y.kod = 'prim'
on conflict (rol_id, yetki_id) do nothing;

-- --------------------------------------------------------- kod listesi ---
insert into public.kod_liste (kod, ad)
select 'prim.hekim_tipi', 'Prim Hekim Tipi'
 where not exists (select 1 from public.kod_liste where kod = 'prim.hekim_tipi');

insert into public.kod_deger (liste_id, deger, ad)
select kl.id, v.deger, v.ad
  from (values (0, 'Tümü'), (1, 'İç hekim'), (2, 'Dış hekim')) v(deger, ad)
  join public.kod_liste kl on kl.kod = 'prim.hekim_tipi'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = kl.id and d.deger = v.deger);

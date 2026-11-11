-- 1307 - Teletıp Panosu ekran yetkisi
--
-- Kullanıcı 11.11.2026: "Mirth panosunu yap". Yetki kodu ekran bazlı (bir kod = bir menü ekranı; web testi
-- menuKoduTekEkran): pano `radyoloji.teletip.pano` - özet, Mirth kanal durumları, bağlantı testi, sorunluları toplu
-- yeniden gönder. `radyoloji.teletip` (gönderim listesi / kartı) olan rollere aynı haklarla verilir.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

insert into public.yetki (kod, ad, grup, tur, urun_modu, sira, aktif)
select 'radyoloji.teletip.pano', 'Teletıp Panosu (Radyoloji)', 'Radyoloji', 0, 2, 282, 1
 where not exists (select 1 from public.yetki where kod = 'radyoloji.teletip.pano');
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil
  from public.yetki ye join public.rol_yetki ry on ry.yetki_id = ye.id
  join public.yetki yn on yn.kod = 'radyoloji.teletip.pano'
 where ye.kod = 'radyoloji.teletip'
on conflict (rol_id, yetki_id) do nothing;
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1 from public.yetki y
 where y.kod = 'radyoloji.teletip.pano'
   and not exists (select 1 from public.rol_yetki r where r.rol_id = 1 and r.yetki_id = y.id);
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'radyoloji.teletip.pano');

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama)
select 'teletip-pano', '/teletip-pano', 'Teletıp Panosu', 'Radyoloji › Teletıp Panosu', 'Radyoloji',
       'Teletıp Panosu', 'radyoloji.teletip.pano', 2,
       'teletip pano mirth kanal kuyruk bağlantı testi bakanlık hl7 gönderim özeti',
       'Teletıp gönderiminin günlük özeti, kuyruk, Mirth kanal durumları; bağlantı testi ve sorunluları toplu yeniden gönder.'
 where not exists (select 1 from public.ai_rehber_ekran r where r.kaynak = 'teletip-pano');

commit;

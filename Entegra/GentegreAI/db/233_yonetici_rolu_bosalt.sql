-- 233: Yonetici rolunde YALNIZ sistem yoneticisi kalir (kullanici istegi).
--
-- 231 ile tum kullanicilar gecici olarak yoneticiye tasinmisti; bu dogru
-- kalici durum degil - 352 kisi tam yetkili gorunuyordu. Artik yalniz
-- 'admin' yonetici; digerleri YETKISIZ havuz rolune ('Rol Atanmamış')
-- gecer. Rol karti > Kullanicilar gridinden istenen role dagitilirlar.
--
-- Havuz rolu YETKISIZDIR (rol_yetki satiri yok): o kullanicilar giris yapsa
-- bile hicbir modul goremez.

begin;

insert into public.rol (kod, ad, sistem, aktif)
select 'atanmamis', 'Rol Atanmamış', 0, 1
 where not exists (select 1 from public.rol where kod = 'atanmamis');

-- Eski dagilim yedegi zaten _yedek_kullanici_rol_231'de (231).
update public.taraf_kullanici
   set rol_id = (select id from public.rol where kod = 'atanmamis')
 where kod <> 'admin'
   and rol_id = (select id from public.rol where kod = 'yonetici');

commit;

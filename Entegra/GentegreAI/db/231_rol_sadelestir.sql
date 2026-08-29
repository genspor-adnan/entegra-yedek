-- 231: Rol listesi sadelestirildi (kullanici istegi: "tum rolleri sil sadece
-- yonetim kalsin"). Delphi gocunden gelen 23 adet icerigi bos "Rol 10xx"
-- rolu + 'salt_okur' kaldirildi; yalniz 'yonetici' kaldi. Yeni rol yapisi
-- ekrandan kurulacak (rol karti > Kullanicilar sekmesi).
--
-- taraf_kullanici.rol_id NOT NULL + FK RESTRICT oldugu icin bagli kullanicilar
-- ONCE yoneticiye tasinir. Eski eslesme _yedek_rol_231 / _yedek_kullanici_rol_231
-- tablolarinda durur - gerekirse geri yazilabilir.

begin;

-- 1) Yedek (bir kez; tekrar calistirilirsa dokunulmaz).
create table if not exists public._yedek_rol_231 as
  select * from public.rol;
create table if not exists public._yedek_kullanici_rol_231 as
  select id as kullanici_id, rol_id from public.taraf_kullanici;

-- 2) Bagli kullanicilar yoneticiye.
update public.taraf_kullanici k
   set rol_id = (select id from public.rol where kod = 'yonetici')
 where k.rol_id <> (select id from public.rol where kod = 'yonetici');

-- 3) Rol agaci baglarini coz (self FK), sonra sil. rol_yetki / rol_alan_yetki
--    ON DELETE CASCADE ile birlikte gider.
update public.rol set ust_rol_id = null where kod <> 'yonetici';
delete from public.rol where kod <> 'yonetici';

commit;

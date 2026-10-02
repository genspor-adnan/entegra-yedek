-- =====================================================================
--  930_bashekim_sablon_yonet.sql
--  BAŞHEKİM DE MUAYENE ŞABLONLARINI YÖNETİR (kullanıcı).
--
--  929 muayene.sablon_yonet yetkisini yalnız yönetici rolüne vermişti.
--  Bölüm ortak şablonlar ve bölüm varsayılanı (⭐) tıbbi hizmet kararı -
--  başhekim rolüne de verilir. Standart rol tanımı (StandartRolUclari) da
--  aynı yetkiyi taşır; rol yeniden kurulunca kaybolmaz. Kurum rolü
--  zaten yetkiye sahipse dokunulmaz.
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r
  join public.yetki y on y.kod = 'muayene.sablon_yonet'
 where r.kod = 'bashekim'
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);

do $$ begin raise notice '930 tamam: bashekim muayene.sablon_yonet'; end $$;

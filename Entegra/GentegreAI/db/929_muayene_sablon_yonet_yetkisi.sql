-- =====================================================================
--  929_muayene_sablon_yonet_yetkisi.sql
--  DOKTOR YALNIZ KENDİ ŞABLONUNU DÜZENLER (kullanıcı).
--
--  Kural sunucuda (MuayeneSablonUclari.YazmaKuraliAsync): yetkisi olmayan
--  kullanıcı yalnız doktoru KENDİSİ olan şablonu ekler / değiştirir / siler;
--  bölüm ortak ya da başka doktorun şablonunu "Kopyala (bana)" ile kendine
--  alır. Bölüm ortak şablonları ve bölüm varsayılanını (⭐) yöneten kişi için
--  aksiyon yetkisi: muayene.sablon_yonet. Yönetici rolüne verilir; başhekim /
--  bölüm sorumlusu gibi rollere kurum Rol ekranından ekler.
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'muayene.sablon_yonet', 'Muayene şablonlarını yönet (bölüm ortak / başka doktor)',
       coalesce((select grup from public.yetki where kod = 'muayene'), 'Muayene'), 1, 90, 1
 where not exists (select 1 from public.yetki where kod = 'muayene.sablon_yonet');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r
  join public.yetki y on y.kod = 'muayene.sablon_yonet'
 where r.kod = 'yonetici'
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);

do $$ begin raise notice '929 tamam: muayene.sablon_yonet yetkisi (yonetici)'; end $$;

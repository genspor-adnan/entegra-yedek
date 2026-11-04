-- =============================================================================
--  1263 - ÜRETİM SORUMLUSU ROLÜNE uretim.ayar (Üretim › Ayarlar › Üretim Ayarları)
--
--  Kullanıcı (04.11.2026): "Üretim Sorumlusu rolüne uretim.ayar yetkisini ver".
--
--  1262 `uretim.ayar` kodunu `ayar`dan kopyaladı; Üretim Sorumlusu'nda (standart rol kodu erp_uretim) genel
--  ayar yetkisi yoktu, dolayısıyla üretim seviyesi / "emir kullan" ayarı da yoktu. Üretim seviyesi üretimin
--  kendi kararıdır: rol Gör + Değiştir alır (ekle / sil ekranda yok). Standart rol şablonu
--  (StandartRolUclari erp_uretim) da aynı kuralı taşır; rol yeniden kurulunca kaybolmaz. Kurum rolü yetkiye
--  zaten sahipse dokunulmaz (930 deseni). İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 0, 1, 0, 0
  from public.rol r
  join public.yetki y on y.kod = 'uretim.ayar'
 where r.kod = 'erp_uretim'
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);

update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'erp_uretim';

do $$ begin
  raise notice '1263 tamam: erp_uretim uretim.ayar (% rol)', (select count(*) from public.rol where kod = 'erp_uretim');
end $$;

-- 1365 - Radyolog rolü açık bayrakla (kod inceleme 17.11.2026).
--   SORUN: "radyolog" (kendi adına onay / e-imza, Uzmana Gönder ve "kimin adına" listeleri) rol KODUNDA 'radyolog'
--   geçmesiyle tanınıyordu - büyük/küçük harfe duyarlı, ad kalıbına bağlı: 'Radyolog' / 'rad_uzman' kodlu radyolog
--   onaylayamıyor, 'radyolog_sekreter' gibi bir rol radyolog sayılıyordu.
--   ÇÖZÜM: rol.radyolog bayrağı (rol kartında "Radyolog"). Mevcut roller bugünkü kuralla (harf duyarsız) işaretlenir -
--   bugün onaylayan kimse bu dosyayla onay hakkını kaybetmez; yanlış işaretleneni rol kartından kaldırın.
--   Tekrar çalıştırılabilir (yalnız sütun ilk kez eklenirken doldurulur).
do $$
begin
  if not exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'rol' and column_name = 'radyolog') then
    alter table public.rol add column radyolog smallint not null default 0;
    update public.rol set radyolog = 1
     where lower(kod) like '%radyolog%' or lower(kod) = 'teleradyoloji_hekim';
    raise notice '1365: % rol radyolog işaretlendi', (select count(*) from public.rol where radyolog = 1);
  end if;
end $$;
comment on column public.rol.radyolog is
  '1365: rol radyolog - rapor onayını kendi adına verir (rad.rapor_onayla ile birlikte); onay / e-imza "kimin adına" listelerinde görünür';

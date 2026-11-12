-- 1322 - e-Nabız hesabında boş kimlik alanları geçerli değerle doldurulur (1321'in devamı)
--
-- 1321 ana kaynağı e-Nabız hesabı yaptı; MEDULA tesis kodu yalnız kurum profilinden taşınmıştı. Değer MEDULA hesabında
-- (eski yer) ya da şubenin profilinde duruyorsa e-Nabız kartında alan BOŞ görünüyordu - kullanıcı "eksik" sanıyordu.
-- e-Nabız satırının (şubesi / kurum geneli) GEÇERLİ kimliği (fn_kurum_kimlik) boş alanlara bir kez yazılır; dolu alana
-- dokunulmaz. Bakanlık adı bilerek taşınmaz (boş = şube unvanı; kurum adı kopyalanırsa şube adı değişince eskir).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;
update public.entegrasyon_hesap h
   set ayarlar = coalesce(h.ayarlar, '{}'::jsonb)
                 || jsonb_build_object('medulaTesisKodu', (select k.tesis from public.fn_kurum_kimlik(coalesce(h.sube_id, 0)) k))
 where h.kod = 'ENABIZ' and btrim(coalesce(h.ayarlar ->> 'medulaTesisKodu', '')) = ''
   and coalesce((select k.tesis from public.fn_kurum_kimlik(coalesce(h.sube_id, 0)) k), '') <> '';
update public.entegrasyon_hesap h
   set kurum_kodu = (select k.skrs from public.fn_kurum_kimlik(coalesce(h.sube_id, 0)) k)
 where h.kod = 'ENABIZ' and btrim(coalesce(h.kurum_kodu, '')) = ''
   and coalesce((select k.skrs from public.fn_kurum_kimlik(coalesce(h.sube_id, 0)) k), '') <> '';
commit;

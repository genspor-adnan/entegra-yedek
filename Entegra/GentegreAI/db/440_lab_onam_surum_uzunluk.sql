-- =====================================================================
-- 440 - GENETİK ONAM SÜRÜM ALANI 20 KARAKTERE SIĞMIYOR
--
-- 439'da `onam_surum varchar(20)` açılmıştı; sahadaki onam formu adı
-- "Genetik test onamı v2" (21 karakter) bile sığmıyor ve kayıt
-- "Girilen deger alanin izin verdiginden uzun" ile reddediliyordu.
-- Onam formunun ADI ile SÜRÜMÜ birlikte yazılır (kurum formu değişince
-- hangi metne onay verildiği rapordan görünmeli), bu yüzden 20 hane
-- baştan yanlış ölçüydü.
-- =====================================================================

alter table public.lab_genetik_vaka
    alter column onam_surum type varchar(80);

do $$
begin
    raise notice '440 tamam: lab_genetik_vaka.onam_surum varchar(80)';
end $$;

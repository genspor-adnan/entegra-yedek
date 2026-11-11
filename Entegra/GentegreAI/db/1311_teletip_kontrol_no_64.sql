-- 1311 - teletip_gonderim.kontrol_no 64 karakter
--
-- KOS (1310) satırında kontrol numarası KOS'un SOP Instance UID'si - DICOM UID 64 karaktere kadar çıkar; sütun 40'tı
-- ("value too long for type character varying(40)", KOSUYOLU denemesi 11.11.2026: KOS Mirth'e gitti, sonuç yazılamadı).
--
-- Tekrar çalıştırılabilir. v_teletip_istem bu sütunu kullanmıyor; tür değişikliği görünümü etkilemez.
\set ON_ERROR_STOP on
begin;
alter table public.teletip_gonderim alter column kontrol_no type varchar(64);
commit;

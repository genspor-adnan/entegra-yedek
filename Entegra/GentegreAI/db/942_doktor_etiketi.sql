-- =====================================================================
--  942_doktor_etiketi.sql
--  RANDEVU TAKVİMİ "Hekim" görünüm düğmesi ve doktor seçicisinin başlığı
--  "Doktor" oldu (kullanıcı). Yalnız İngilizce sözlük eklenir.
--
--  Idempotent (`on conflict do update`).
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Doktor', 1, 'Doctor')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

do $$
begin
    raise notice '942 tamam: Doktor etiketi.';
end $$;

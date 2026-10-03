-- =====================================================================
--  939_doktor_personel_etiketi.sql
--  BAŞVURU KARTI "HEKİM / PERSONEL" ETİKETİ "DOKTOR / PERSONEL" OLDU
--  (kullanıcı). Etiket web'de (BasvuruSekmesi, önceki başvurular tablosu);
--  burada yalnız İngilizce sözlüğe yeni anahtar eklenir. Eski
--  'Hekim / Personel' satırı (851) durur.
--
--  Idempotent (`on conflict do update`).
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Doktor / Personel', 1, 'Doctor / staff')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

do $$
begin
    raise notice '939 tamam: Doktor / Personel çevirisi.';
end $$;

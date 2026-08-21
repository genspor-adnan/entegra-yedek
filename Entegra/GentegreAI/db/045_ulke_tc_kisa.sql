-- ============================================================================
--  Gentegre AI — Ulke referansinda Turkiye kisa ad
--  045_ulke_tc_kisa.sql
--
--  Kullanici: "ülke kısa TC olsun". public.ulke serbest metin (FK degil, taraf_adres.ulke
--  ile ad esitligiyle eslesir) - "TÜRKİYE CUMHURİYETİ" hicbir mevcut taraf_adres satirina
--  tam eslesmiyordu (legacy veri "Turkiye"/"TÜRKİYE"/vb cesitli yaziliyor), guvenle
--  kisaltilabilir.
-- ============================================================================
\set ON_ERROR_STOP on

update public.ulke set ad = 'TC' where id = 312 and ad = 'TÜRKİYE CUMHURİYETİ';

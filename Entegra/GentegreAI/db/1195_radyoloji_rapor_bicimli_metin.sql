-- =============================================================================
--  1195  RADYOLOJİ RAPORU: BİÇİMLİ METİN (font / punto / renk)
--
--  Kullanıcı (27.10.2026): "serbest bölümü formatlı yap.. font punto renk vb".
--  Bölümün düz metni (metin) AYNEN kalır - e-Nabız, Bakanlık HL7, teleradyoloji, arama düz metni kullanır.
--  Biçimli hali metin_html'de: sunucuda beyaz listeyle temizlenmiş HTML (yalnız biçim etiketleri ve
--  font-family / font-size / color / background-color / text-align stilleri). Çıktı varsa bunu basar.
--  Boş (null) = biçimsiz eski rapor - çıktı düz metni basar. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

alter table public.radyoloji_rapor_bolum add column if not exists metin_html text;
comment on column public.radyoloji_rapor_bolum.metin_html is
  'Bölümün biçimli hali (1195): sunucuda temizlenmiş HTML. Null = biçimsiz; düz metin her zaman metin kolonunda.';

commit;

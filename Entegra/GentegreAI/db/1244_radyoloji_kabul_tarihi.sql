-- =============================================================================
--  1244  RADYOLOJİ İSTEMİ KABUL ZAMANI
--
--  Kullanıcı 01.11.2026: "kabul bilgileri ilk istem oluştuğunda editler açık yani bu şekilde gelsin.. kaydedildiğinde
--  kabul bilgileri sağında kalem ikonu olsun ve alttaki bilgiler label olarak gelsin".
--  İstem kartı "kabul edildi mi" sorusunu bu alandan cevaplar: boşsa Kabul Bilgileri düzenlemede açılır; kart kabul
--  bilgilerini kaydedince dolar (RadyolojiUclari PUT); kabul ekranından açılan istem açılışta dolu doğar.
--  Akış şeridindeki "Kabul" adımının zamanı da budur.
--  Mevcut istemler: başvurudan OTOMATİK açılmamış (kabul ekranı / muayene / dış) ya da çekimi yapılmış olan
--  kabul edilmiş sayılır (ekleme zamanıyla); otomatik açılıp henüz çekilmemiş olan boş kalır.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

alter table public.radyoloji_istem add column if not exists kabul_tarihi timestamptz;
comment on column public.radyoloji_istem.kabul_tarihi is
  '1244: kabul bilgilerinin kaydedildiği an (boş = istem kartında Kabul Bilgileri düzenlemede açılır).';

update public.radyoloji_istem
   set kabul_tarihi = ekleme_tarihi
 where kabul_tarihi is null
   and (otomatik = 0 or durum >= 2 or coalesce(study_uid, '') <> '' or durum = 0);

commit;

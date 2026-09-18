-- ============================================================================
--  Gentegre AI — GÖNDEREN KURUMDAKİ HASTA DOSYA NUMARASI (PID-3)
--  816_telerad_dis_hasta_no.sql
--
--  Kullanıcı: *"ORU üreticisiyle devam et"*. Üretici yazılınca ortaya çıktı:
--  `PID-3` (hastane dosya numarası) için kaynağımız YOKTU.
--
--  Kılavuz 3.46 bunu iki yerde arıyor:
--    * "Sık yapılan hatalar": PACS hasta dosya numarası kullanıyorsa PID-3
--      boş bırakılamaz.
--    * §5.2 eşleştirme: TCKN DICOM'da yoksa eşleşme `HL7SKRS == KOSSKRS &&
--      HL7PatientID == DCMPatientID` dalından yürüyor - yani dosya numarası
--      tek eşleşme yolu olabiliyor.
--
--  `dis_hasta_kimlik` TCKN'dir, dosya numarası DEĞİLDİR: biri kişinin devlet
--  kimliği, öteki o hastanedeki kayıt numarası. Aynı kolona sıkıştırmak,
--  TCKN'si olmayan hastada (yabancı, yenidoğan) ikisini de kaybettirirdi.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.telerad_istek
    add column if not exists dis_hasta_no varchar(30) not null default '';

comment on column public.telerad_istek.dis_hasta_no is
  '816: hastanın GÖNDEREN KURUMDAKİ dosya/protokol numarası (HL7 PID-3). '
  'dis_hasta_kimlik TCKN''dir, bu ayrı alandır.';

do $$
begin
    raise notice '816 tamam: telerad_istek.dis_hasta_no (PID-3) eklendi.';
end $$;

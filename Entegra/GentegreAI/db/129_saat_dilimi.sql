-- ============================================================================
--  Gentegre AI — VERITABANI SAAT DILIMI
--  129_saat_dilimi.sql
--
--  PostgreSQL konteyneri UTC calisiyordu: `now()::timestamp` Turkiye saatinden
--  3 saat geri deger uretiyor, dolayisiyla ekleme_tarihi/degistirme_tarihi gibi
--  otomatik damgalar gecmise dusuyordu. Kullanici bunu belge kartinda gordu:
--  "saatim ilerde gorunuyor, geri alirsam ekleniyor" (ileri tarih kontrolu).
--
--  Veritabani oturumlarinin varsayilan dilimi Europe/Istanbul yapilir; boylece
--  now() ve now()::timestamp yerel saati verir. Uygulama tarafinda ayrica
--  Cekirdek/Saat.cs ile UTC'den kurulus dilimine cevrim yapilir - iki katman da
--  konteynerin TZ ayarindan bagimsiz calissin diye.
--
--  GECMIS KAYITLAR DOKUNULMAZ: hangi damganin UTC hangisinin yerel yazildigini
--  ayirt etmenin guvenli yolu yok; toplu +3 saat kaydirmak dogru kayitlari da
--  bozardi. Bu tarihten sonrasi dogru yazilir.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare v_db text := current_database();
begin
    execute format('alter database %I set timezone to %L', v_db, 'Europe/Istanbul');
    raise notice '129: % veritabani dilimi Europe/Istanbul yapildi (yeni baglantilarda gecerli)', v_db;
end $$;

-- Bu oturumda da hemen gecerli olsun (goc betiginin kalani icin).
set timezone to 'Europe/Istanbul';

do $$
begin
    raise notice '129 tamam: simdi = % (dilim %)', now()::timestamp, current_setting('TimeZone');
end $$;

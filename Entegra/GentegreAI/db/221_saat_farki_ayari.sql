-- ============================================================================
--  Gentegre AI — SAAT FARKI AYARI
--  221_saat_farki_ayari.sql
--
--  Islem gunlugu tarihleri sunucuda UTC tutulur; listede eklenen kayma sabit
--  "+3 saat" yerine genel.saat_farki ayarindan okunur (kullanici). Genel
--  Ayarlar > Genel'e "Saat farkı (UTC+)" combosu eklendi; varsayilan 3.
-- ============================================================================

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'genel.saat_farki', '3', 'sayi', 'firma',
       'Islem gunlugu vb. UTC tarihlere eklenen saat kaymasi'
where not exists (select 1 from public.referans where anahtar = 'genel.saat_farki');

do $$ begin
    raise notice '221 tamam: genel.saat_farki ayari.';
end $$;

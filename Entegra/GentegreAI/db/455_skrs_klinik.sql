-- =====================================================================
-- 455 - SKRS KLİNİK KODU (e-Nabız "Muayene Yapılan (Poli)Klinik")
--
-- USS'nin her paketinde klinik kodu var (101 Hasta Kayıt, 103 Muayene…) ve
-- bu kod SKRS'nin **KLİNİKLER** listesinden gelir. Kod tabanında "SKRS'de
-- klinik listesi yok" notu duruyordu; 499 liste Türkçe karakterle taranınca
-- liste çıktı - eşleme bu yüzden elle giriliyordu.
--
-- YENİ KOLON YOK (kullanıcı): SKRS kodu bölümün KENDİ KOD ALANINA yazılır
-- (`departman.kod`). Bölüm kodu zaten kurumun kimlik alanı; e-Nabız için
-- ikinci bir kod kolonu taşımak, iki yerde tutulan ve zamanla ayrışan bir
-- kod demekti.
--
-- ELLE EŞLEME İSTİSNA OLARAK KALIR: `enabiz_kod_esleme` (KLINIK) satırı
-- varsa o kazanır - kurum bir bölümü bilerek başka kliniğe bağlamış olabilir.
-- Satır yoksa bölümün kendi kodu okunur (sayısalsa; değilse kurumun kendi
-- kodlamasıdır, USS'ye gönderilmez).
-- =====================================================================

-- ---------------------------------------------------------------------
--  SKRS klinik listesi: senkron `kod_liste`/`kod_deger`e yazar
--  ('skrs.klinik'). Liste satırı burada açılıyor ki senkron çalışmadan
--  önce de kart lookup'ı boş ama GEÇERLİ bir liste görsün.
-- ---------------------------------------------------------------------
insert into public.kod_liste (kod, ad)
select 'skrs.klinik', 'SKRS Klinikleri'
 where not exists (select 1 from public.kod_liste where kod = 'skrs.klinik');

create or replace view public.v_skrs_klinik_lookup as
select d.deger as id,
       d.deger || ' - ' || d.ad as ad,
       d.aktif
  from public.kod_deger d
  join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'skrs.klinik' and d.dil = 0;

comment on view public.v_skrs_klinik_lookup is
    'SKRS klinik kodu secimi (455): departman kartindaki lookup.';

do $$
begin
    raise notice '455 tamam: skrs.klinik kod listesi · v_skrs_klinik_lookup (% kod)',
        (select count(*) from public.v_skrs_klinik_lookup);
end $$;

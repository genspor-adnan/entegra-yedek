-- =====================================================================
--  903_lab_ige_alerjen.sql
--  ALERJEN SPESİFİK IgE tetkiki (kantitatif seroloji).
--
--  Katalogda hiç alerjen/IgE tetkiki yoktu; hasta örneğinde (Selen Can)
--  "Alerjen Spesifik IgE" istenince istem açılamıyordu. Somut, sık istenen
--  bir alerjenle açıyoruz: EV TOZU AKARI (D. pteronyssinus, d1). İleride
--  başka alerjenler aynı kalıpla eklenir (her biri ayrı tetkik/LOINC).
--
--  KANTİTATİF: sonuç kU/L cinsinden sayıdır; referans < 0,35 (Sınıf 0,
--  negatif). Sonuç kültür değil, düz lab_sonuc akışından girilir.
-- =====================================================================

-- HİZMET (SKRS/SUT) EŞLEMESİ: tetkik katalogu hizmetle 1:1 - fiyat ve
--   faturalama hizmet kartından gelir. Ev tozu akarı spesifik IgE için SUT
--   905900 "Ev Tozu (Mite) Akarlarının Aranması" hizmeti hazır; koda göre
--   bağlanır (id makinede değişebilir).
insert into public.lab_tetkik
       (hizmet_id, kod, ad, kisa_ad, bolum, tur, numune_tipi, tup_tipi,
        birim, ondalik, loinc, yontem, deger_deseni, durum)
select (select id from public.hizmet where kod = '905900' order by id limit 1),
       'IGE-D1',
       'Alerjen Spesifik IgE - Ev Tozu Akarı (d1, D. pteronyssinus)',
       'sIgE d1', 97, 1, 1, 1,
       'kU/L', 2, '6018-1', 'ImmunoCAP / FEIA', '', 1
 where not exists (select 1 from public.lab_tetkik where kod = 'IGE-D1');

-- Zaten hizmetsiz eklenmişse (ilk kurulum) hizmeti sonradan bağla.
update public.lab_tetkik
   set hizmet_id = (select id from public.hizmet where kod = '905900' order by id limit 1)
 where kod = 'IGE-D1' and hizmet_id is null
   and exists (select 1 from public.hizmet where kod = '905900');

-- Referans: Sınıf 0 (negatif) sınırı < 0,35 kU/L. Panik değeri yok.
insert into public.lab_tetkik_referans
       (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, gebelik, alt, ust, metin,
        kaynak, gecerli_bas, sira)
select t.id, 0, 0, 0, 0, 0, 0.35,
       'Sınıf 0 (< 0,35 kU/L): negatif. 0,35-0,70 Sınıf 1 (düşük).',
       'ImmunoCAP', current_date, 1
  from public.lab_tetkik t
 where t.kod = 'IGE-D1'
   and not exists (select 1 from public.lab_tetkik_referans r where r.tetkik_id = t.id);

do $$
begin
    raise notice '903 tamam: IGE-D1 tetkik % , referans %',
        (select count(*) from public.lab_tetkik where kod = 'IGE-D1'),
        (select count(*) from public.lab_tetkik_referans r
           join public.lab_tetkik t on t.id = r.tetkik_id where t.kod = 'IGE-D1');
end $$;

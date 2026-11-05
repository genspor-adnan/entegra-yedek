-- =============================================================================
--  1264 - ÜRETİM EMRİ "Personel / Zaman" SATIRINDA OPERASYON SEÇİCİ
--
--  Kullanıcı (04.11.2026): "operasyon lookup yap" - zaman satırındaki operasyon alanı ham
--  sayı ("Operasyon (Id)") istiyordu; kullanıcı operasyonun kimliğini bilemez.
--
--  Görünüm emrin operasyonlarını "sıra. ad · iş merkezi" olarak verir; `ust_id` = emir -
--  kart, satırın seçeneklerini kendi emrinin operasyonlarına daraltır (KartAlani.UstBilgisi +
--  detaySecenekleri.ustSuzgec). Bitmiş operasyona da zaman yazılabilir (geç giriş), bu yüzden
--  durum süzülmez. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

drop view if exists public.v_uretim_operasyon_lookup;
create or replace view public.v_uretim_operasyon_lookup as
select o.id,
       o.sira::text as kod,
       o.sira::text || '. ' || o.ad
         || coalesce(' · ' || nullif(m.ad, ''), '') as ad,
       o.emir_id as ust_id,
       1::smallint as aktif
  from public.uretim_operasyon o
  left join public.is_merkezi m on m.id = o.is_merkezi_id;

comment on view public.v_uretim_operasyon_lookup is
  '1264: üretim emri zaman satırı operasyon seçici; ust_id = emir_id (kart emrine süzülür).';

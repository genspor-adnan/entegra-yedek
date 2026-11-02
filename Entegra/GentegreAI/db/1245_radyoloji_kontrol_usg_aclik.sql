-- =============================================================================
--  1245  USG ÇEKİM ÖNCESİ KONTROL: AÇLIK
--
--  Kullanıcı 02.11.2026: "usg için açlık sorusu ekle". USG'de (modalite 3) hiç kontrol sorusu yoktu; istem kartı
--  "Bu tetkik türü (USG) için kontrol sorusu tanımlı değil" diyordu.
--  ZORUNLU DEĞİL: sorular modalite bazında - soru tiroid / meme / Doppler dahil bütün USG'lerde çıkar; zorunlu olsa
--  açlık gerektirmeyen tetkikte de "Çekildi" (310 tetiği) engellenirdi. Batın / üst batın USG'de teknisyen yanıtlar.
--  İdempotent: aynı modalite + soru varsa eklenmez.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

insert into public.radyoloji_kontrol_soru (modalite, soru, yanit_tipi, zorunlu, sira)
select 3, 'Hasta aç mı? (batın USG için en az 6 saat)', 1, 0, 10
 where not exists (select 1 from public.radyoloji_kontrol_soru
                    where modalite = 3 and soru ilike 'Hasta aç mı%');

commit;

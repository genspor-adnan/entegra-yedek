-- =====================================================================
--  883_enabiz_radyoloji_sonuc.sql
--  409 RADYOLOJİ SONUÇ KAYIT PAKETİ
--  (KTS denetim maddeleri H10 "Radyoloji sonuç veri paketi gönderimi var
--   mı?" ve D19 — DHBS'de aynı soru)
--
--  Şema (rehber.enabiz.gov.tr, 19.09.2026):
--    RADYOLOJI_SONUC_KAYIT (VeriSeti, zorunlu)
--      RADYOLOJI_BILGISI (Grup, tekrarlı)
--        RADYOLOJI_LOINC          SKRS 39aef8d6-9b53-4b56-8c73-2f53b0599094
--        ISLEM_REFERANS_NUMARASI  102'de gönderilen referans (belge_satir.id)
--        RAPOR_ONAYLANMA_ZAMANI   datetime
--        RAPOR_SONUC_BILGISI (Grup, ZORUNLU, tekrarlı)
--          SONUC_BASLIK · SONUC_ACIKLAMA
--    HASTA_TAKIP_BILGISI / SYSTakipNo (zorunlu)
--
--  KAYNAK = ONAYLANMIŞ RAPOR (`radyoloji_rapor.id`). Tetik onaydadır,
--  raporun yazılması değil: onaylanmamış rapor hastanın dosyasına da
--  girmez, e-Nabız'a hiç girmemeli. 105 (lab sonucu) ile aynı kural.
--
--  RAPOR BÖLÜMLERİ SONUÇ GRUBUNA DÖNÜŞÜR: bizde rapor "Klinik Bilgi /
--  Teknik / Bulgular / Sonuç" bölümlerinden oluşuyor (809 Bakanlık
--  profili); 409'un `RAPOR_SONUC_BILGISI` grubu da başlık + açıklama
--  çiftleri istiyor. Bire bir eşleşiyor - metni tek parçaya yapıştırmak
--  bölümlerin adını kaybetmek olurdu.
--
--  YAZDIRILMAYAN BÖLÜM GÖNDERİLMEZ (`yazdir = 0`): rapor içindeki iç
--  notlar hastanın e-Nabız dosyasına düşmemeli.
-- =====================================================================

insert into public.enabiz_paket_turu
       (kod, ad, uss_paket_kodu, uss_surum, tetik_olay, sure_siniri_saat, zorunlu_alanlar, aktif)
select 'RADYOLOJI_SONUC', 'Radyoloji Sonuç Kayıt', '409', '2.2',
       'radyoloji_rapor_onaylandi', 24,
       '["HASTA_TAKIP_BILGISI/SYSTakipNo",
         "RADYOLOJI_SONUC_KAYIT/RADYOLOJI_BILGISI/RAPOR_SONUC_BILGISI/SONUC_ACIKLAMA"]'::jsonb,
       1
 where not exists (select 1 from public.enabiz_paket_turu t where t.kod = 'RADYOLOJI_SONUC');

-- ------------------------------------------------- LOINC eksik raporu ----
--  Paket LOINC'siz de gider (alan zorunlu değil) ama Bakanlık veri
--  kalitesi ölçümünde LOINC'siz radyoloji sonucu "eksik" sayılıyor.
--  Hangi hizmetlerin LOINC'i yok - kurum görebilsin.
create or replace view public.v_radyoloji_loinc_eksik as
select h.id           as hizmet_id,
       h.kod          as hizmet_kodu,
       h.ad           as hizmet_adi,
       count(i.id)    as istem_sayisi
  from public.hizmet h
  join public.radyoloji_istem i on i.hizmet_id = h.id
 where coalesce(h.loinc, '') = ''
 group by h.id, h.kod, h.ad;

comment on view public.v_radyoloji_loinc_eksik is
  '883: LOINC kodu olmayan radyoloji hizmetleri (409 paketinde '
  'RADYOLOJI_LOINC bos gider). 872 ile gelen loinc kolonu doldurulmali.';

do $$
declare v_eksik integer;
begin
    select count(*) into v_eksik from public.v_radyoloji_loinc_eksik;
    raise notice '883 tamam: 409 paket turu aktif (%), LOINC''siz radyoloji hizmeti: %',
        (select aktif from public.enabiz_paket_turu where kod = 'RADYOLOJI_SONUC'), v_eksik;
end $$;

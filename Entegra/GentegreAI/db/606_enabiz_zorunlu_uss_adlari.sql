-- =====================================================================
--  606_enabiz_zorunlu_uss_adlari.sql
--  ZORUNLU ALAN LİSTELERİ USS ADLARINA ÇEVRİLDİ.
--
--  605 ile paket üreticisi USS'nin gerçek alan adlarını ve yollarını yazmaya
--  başladı ("HASTA_KIMLIK_BILGILERI/AD"). `enabiz_paket_turu.zorunlu_alanlar`
--  ise hâlâ eski yer tutucu adları taşıyordu ("TesisKodu", "HastaKimlikNo").
--
--  İkisi uyuşmazsa üretici HER paketi "eksik alan" sayar: zorunlu listedeki ad
--  üretilen alanlar arasında hiç bulunmaz, paket durum 0'da kalır ve kuyruğa
--  hiç girmez. Yani bu dosya olmadan 605 sessizce gönderimi durdururdu.
--
--  Adlar kılavuzun zorunluluk tablosundan (rehber.enabiz.gov.tr) alındı -
--  dokuman/09_ENABIZ_USS_SEMASI.md.
-- =====================================================================

-- 101 Hasta Kayıt. Kılavuzda 18 zorunlu alan var; burada yalnız KAYNAKTAN
--   ÜRETİLEBİLENLER listeleniyor. ADRES_BILGISI, YATIS_BILGISI gibi grup
--   düğümleri ve SKRS eşlemesi kurulmamış alanlar (HASTA_TIPI, UYRUK,
--   SOSYAL_GUVENCE_DURUMU, VAKA_TURU) listeye ALINMADI: eşleme tablosu
--   dolmadan onları zorunlu tutmak, üretilebilir paketleri de kuyruğun
--   dışında bırakırdı. Eşlemeler girildikçe bu liste yeni bir dosyayla
--   genişletilir.
update public.enabiz_paket_turu
   set zorunlu_alanlar = '[
         "HASTA_KIMLIK_BILGILERI/HASTA_KIMLIK_NUMARASI",
         "HASTA_KIMLIK_BILGILERI/AD",
         "HASTA_KIMLIK_BILGILERI/SOYAD",
         "HASTA_BASVURU_BILGILERI/HIZMET_SUNUCU",
         "HASTA_BASVURU_BILGILERI/HASTANE_REFERANS_NUMARASI",
         "HASTA_BASVURU_BILGILERI/KABUL_ZAMANI",
         "HASTA_BASVURU_BILGILERI/KLINIK_KODU"
       ]'::jsonb
 where uss_paket_kodu = '101';

-- 103 Muayene. Takip numarası ZORUNLU: onsuz muayene hangi başvuruya
--   bağlanacağını bilemez.
update public.enabiz_paket_turu
   set zorunlu_alanlar = '[
         "HASTA_TAKIP_BILGISI/SYSTakipNo",
         "MUAYENE_BILGILERI/MUAYENE_BASLANGIC_TARIHI",
         "MUAYENE_BILGILERI/TANI_BILGISI/ICD10"
       ]'::jsonb
 where uss_paket_kodu = '103';

-- 106 Çıkış.
update public.enabiz_paket_turu
   set zorunlu_alanlar = '[
         "HASTA_TAKIP_BILGISI/SYSTakipNo",
         "HASTA_CIKIS_BILGILERI/CIKIS_ZAMANI"
       ]'::jsonb
 where uss_paket_kodu = '106';

-- 301 Silme: gövde alan tablosundan değil paketin takip numarasından
--   üretiliyor (605), zorunlu alan listesi BOŞ kalır.
update public.enabiz_paket_turu
   set zorunlu_alanlar = '[]'::jsonb
 where uss_paket_kodu = '301';

do $$
begin
    raise notice '606 tamam: % pakette zorunlu alanlar USS adlarina cevrildi',
        (select count(*) from public.enabiz_paket_turu
          where zorunlu_alanlar::text like '%/%' or uss_paket_kodu = '301');
end $$;

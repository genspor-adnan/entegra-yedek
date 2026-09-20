-- =====================================================================
--  880_enabiz_konsultasyon.sql
--  252 KONSÜLTASYON KAYIT PAKETİ (KTS denetim maddesi H2 / D20)
--
--  Eski denetimde bu madde **"Hatalı"** bulunmuştu: "Konsültasyon kayıt
--  paketi gönderiliyor mu?" - hayır.
--
--  PAKET NUMARASI VE ŞEMASI ARTIK ELİMİZDE. 876'da (ADSM paketi) "rehber
--  paketin adını veriyor, numarasını vermiyor" diye kapalı kurmuştuk;
--  meğer rehberin paket listesi menüde duruyormuş ve her paketin kendi
--  şema sayfası varmış. 19.09.2026'da tarayıcıdan okundu:
--
--    HASTA_KONSULTASYON_BILGILERI (VeriSeti, zorunlu)
--      KONSULTASYON_BILGISI (Grup, tekrarlı)
--        ISLEM_REFERANS_NUMARASI            string
--        KONSULTASYON_BASLAMA_ZAMANI        datetime
--        KONSULTASYON_BITIS_ZAMANI          datetime
--        KONSULTASYON_TALEBINI_YAPAN_HEKIM_KIMLIK_NUMARASI        string
--        KONSULTASYON_TALEBINE_CEVAP_VEREN_HEKIM_KIMLIK_NUMARASI  string
--        TANI_BILGISI (Grup, tekrarlı)
--          TANI_TURU  (SKRS 55894edb-1a8c-4f7f-a447-0119e61c14f1)
--          ICD10      (SKRS c3eaabad-8c4c-56ee-e043-14031b0a5530)
--        KONSULTASYON_NOTU_BILGISI (Grup, ZORUNLU, tekrarlı)
--          KONSULTASYON_NOTU_BASLIK      string
--          KONSULTASYON_NOTU_ACIKLAMA    string
--    HASTA_TAKIP_BILGISI / SYSTakipNo (zorunlu)
--
--  KAYNAK = KONSÜLTASYON MUAYENESİNİN KENDİSİ. Bizde konsültasyon ayrı bir
--  tablo değil, `ust_muayene_id` ile bağlı bir MUAYENE satırıdır (465):
--  soru isteyen hekimin cümlesi (`konsultasyon_soru`), yanıt cevaplayanın
--  kararı (`karar`) aynı satırda durur. Paket de oradan üretilir.
--
--  PAKET AÇIK KURULUR: numara ve eleman adları bilindiği için kapıya gerek
--  yok. Gönderim yine `enabiz.gonder` kuyruğunun kendi anahtarına bağlı.
-- =====================================================================

insert into public.enabiz_paket_turu
       (kod, ad, uss_paket_kodu, uss_surum, tetik_olay, sure_siniri_saat, zorunlu_alanlar, aktif)
select 'KONSULTASYON', 'Konsültasyon Kayıt', '252', '2.2',
       'konsultasyon_tamamlandi', 24,
       '["HASTA_TAKIP_BILGISI/SYSTakipNo",
         "HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI/KONSULTASYON_NOTU_BILGISI/KONSULTASYON_NOTU_ACIKLAMA"]'::jsonb,
       1
 where not exists (select 1 from public.enabiz_paket_turu t where t.kod = 'KONSULTASYON');

-- --------------------------------------------- 203: ADSM paketi (876) ----
--  876'da yer tutucu '000' ile kapalı kurulmuştu; numarası artık belli:
--  **203 Ağız ve Diş Sağlığı Veri Seti**. Numara yazılır ama paket
--  AÇILMAZ: 203'ün eleman adları (MUDAHALE, TEDAVI_EDILEN_DISIN_KODU,
--  MEVCUT_DIS_BILGISI...) SKRS kod sistemlerine bağlı ve bizim diş
--  işlemlerimizin o listelere eşlemesi henüz yok. Yanlış kodla gönderilen
--  paket, hastanın dosyasına yanlış müdahale yazmaktı.
update public.enabiz_paket_turu
   set uss_paket_kodu = '203',
       ad = 'Ağız ve Diş Sağlığı Veri Seti (ADSM)'
 where kod = 'ADSM_AGIZ_DIS' and uss_paket_kodu = '000';

comment on column public.enabiz_paket_turu.uss_paket_kodu is
  'USS paket numarasi (rehber.enabiz.gov.tr paket listesi). 880: 252 '
  'Konsultasyon acildi, 203 ADSM numarasi yazildi (elemanlari SKRS '
  'eslemesi bekledigi icin hala kapali).';

do $$
begin
    raise notice '880 tamam: 252 Konsultasyon (aktif %), ADSM paket kodu %',
        (select aktif from public.enabiz_paket_turu where kod = 'KONSULTASYON'),
        (select uss_paket_kodu from public.enabiz_paket_turu where kod = 'ADSM_AGIZ_DIS');
end $$;

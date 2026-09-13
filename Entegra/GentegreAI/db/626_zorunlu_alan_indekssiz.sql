-- =====================================================================
--  626_zorunlu_alan_indekssiz.sql
--  TEKRARLI GRUPLARIN ZORUNLU ALANLARI DA KONTROL EDİLİR.
--
--  Zorunluluk kontrolü tam yol eşitliğiyle yapılıyordu; tekrarlı grupta
--  üretilen yol indeks taşıdığı için ("TANI_BILGISI[1]/ICD10") şemadaki
--  yolla ("TANI_BILGISI/ICD10") eşleşmiyor ve DOLU alan EKSİK sayılıyordu:
--  103 paketi bütün alanları geçerliyken "Eksik Alan" durumunda kuyruğa
--  düştü ve gönderilemedi (gerçek vaka, paket 627).
--
--  Karşılaştırma indeks-duyarsız hale getirildi (`EnabizPaketUretici`).
--  102'nin zorunlu listesi bu yüzden boş bırakılmıştı - artık kılavuzdaki
--  gerçek zorunlular yazılabilir.
-- =====================================================================

update public.enabiz_paket_turu
   set zorunlu_alanlar = '[
         "HASTA_TAKIP_BILGISI/SYSTakipNo",
         "HASTA_ISLEM_BILGILERI/ISLEM_BILGISI/KLINIK_KODU",
         "HASTA_ISLEM_BILGILERI/ISLEM_BILGISI/ISLEM_TURU",
         "HASTA_ISLEM_BILGILERI/ISLEM_BILGISI/ISLEM_ZAMANI",
         "HASTA_ISLEM_BILGILERI/ISLEM_BILGISI/ISLEM_REFERANS_NUMARASI"
       ]'::jsonb
 where uss_paket_kodu = '102';

-- Eksik sayilmis paketler yeniden degerlendirilsin: alanlari zaten dolu,
-- yalnizca DURUMLARI yanlisti (0 = eksik alan). 1 = bekliyor.
update public.enabiz_paket p
   set durum = 1, degistirme_tarihi = now()
 where p.durum = 0
   and not exists (select 1 from public.enabiz_paket_alan a
                    where a.paket_id = p.id and a.gecerli = 0);

do $$
begin
    raise notice '626 tamam: % paket eksik-alan durumundan cikti',
        (select count(*) from public.enabiz_paket where durum = 1);
end $$;

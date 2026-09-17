-- =====================================================================
--  744_izin_onay_kutusu.sql
--  Gelen kutusu izin taleplerini de tanısın (739'da yalnız satınalma vardı).
--
--  739'daki `v_onay_kutusu` bilinmeyen türü "#id" diye gösteriyordu -
--  kaybolmuyordu ama onaylayacak kişi neye onay verdiğini kutudan
--  anlayamıyordu. İzin talebinde bu özellikle kötü: "kim, hangi tarihlerde,
--  kaç gün" sorusu kararın kendisidir.
-- =====================================================================

create or replace view public.v_onay_kutusu as
select v.adim_id                                as id,
       v.onay_id,
       v.kaynak_tur,
       v.kaynak_id,
       v.sube_id,
       v.akis_kod,
       v.akis_ad,
       v.olcu,
       v.olcu_adi,
       v.sira,
       v.adim_ad,
       v.rol,
       v.atanan_kullanici_id,
       v.durum,
       v.gerekce,
       v.baslama,
       v.termin,
       v.gecikme_gun,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.talep_no, ''), '#' || v.kaynak_id::text)
            when 904  then coalesce(nullif(z.izin_no, ''),
                                    'İzin #' || v.kaynak_id::text)
            else '#' || v.kaynak_id::text
       end                                      as kayit_no,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.gerekce, ''), 'Satınalma talebi')
            -- İZİNDE KONU = TÜR + TARİH ARALIĞI. Onaylayanın sorusu
            --   "hangi tarihlerde yok" - açıklama metni bunu söylemez.
            when 904  then case z.tur when 1 then 'Yıllık izin'
                                      when 2 then 'Mazeret izni'
                                      when 3 then 'Rapor'
                                      when 4 then 'Ücretsiz izin'
                                      else 'İzin' end
                           || ' · ' || to_char(z.baslangic_tarihi, 'DD.MM')
                           || '-' || to_char(z.bitis_tarihi, 'DD.MM.YYYY')
            else ''
       end                                      as konu,
       case v.kaynak_tur
            when 1241 then coalesce(d.ad, '')
            when 904  then coalesce(nullif(zp.gorev, ''), '')
            else ''
       end                                      as birim,
       case v.kaynak_tur
            when 1241 then coalesce(p.unvan, '')
            -- İZİNDE "TALEP EDEN" = izne çıkacak personel.
            when 904  then coalesce(zt.unvan, '')
            else ''
       end                                      as talep_eden
  from public.v_onay_bekleyen v
  left join public.satinalma_talep t
         on v.kaynak_tur = 1241 and t.id = v.kaynak_id
  left join public.departman d on d.id = t.departman_id
  left join public.taraf p     on p.id = t.isteyen_id
  left join public.personel_izin z
         on v.kaynak_tur = 904 and z.id = v.kaynak_id
  left join public.taraf zt          on zt.id = z.taraf_id
  left join public.taraf_personel zp on zp.id = z.taraf_id;

comment on view public.v_onay_kutusu is
  '739/744: butun modullerin bekleyen onaylari, kaydin konusu cozulmus '
  'halde. Izinde konu = tur + tarih araligi (onaylayanin sorusu budur).';

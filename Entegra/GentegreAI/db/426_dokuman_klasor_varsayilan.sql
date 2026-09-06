-- ============================================================================
--  426 - KURUMSAL KLASORLERE VARSAYILAN BELGE TURU
--
--  Klasore yuklenen dokumanin turu bos kaliyordu: tur bos olunca SURUMLU mu
--  degil mi bilinemiyor ve onay akisi hic baslamiyor. Kullaniciya her
--  yuklemede "bu hangi tur" diye sormak yerine klasorun kendi varsayilani
--  kullanilir - zaten "Kalite" klasorune prosedur, "Sozlesmeler"e sozlesme
--  konuyor.
-- ============================================================================

update public.dokuman_klasor k
   set varsayilan_tur_id = t.id,
       varsayilan_gizlilik = t.gizlilik
  from public.dokuman_turu t
 where k.varsayilan_tur_id is null
   and t.ad = case k.ad when 'Kalite'            then 'Prosedür'
                        when 'Sözleşmeler'       then 'Sözleşme'
                        when 'İnsan Kaynakları'  then 'İş Sözleşmesi'
                        when 'Kurumsal'          then 'Prosedür'
                   end;

-- =====================================================================
--  565_bolum_adi_bicim.sql
--  Bölüm adlarında kalan BÜYÜK HARF satırı düzeltilir.
--
--  563/564 görev (branş) adlarını biçimledi. Bölüm listesi zaten düzgün
--  yazılmıştı; SKRS dökümünde yalnız bir satır tamamı büyük kalmıştı:
--  "KULAK BURUN BOĞAZ".
--
--  "KVC Yoğun Bakım" DOKUNULMAZ: KVC bir kısaltmadır (kalp-damar cerrahisi),
--  büyük kalmalı - bu yüzden toplu `lower` yerine tek satır düzeltiliyor.
-- =====================================================================

update public.departman
   set ad = public.fn_tr_baslik(lower(ad))
 where ad = 'KULAK BURUN BOĞAZ';

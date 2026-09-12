-- =====================================================================
--  624_paket_alan_yol_genisletildi.sql
--  ALAN YOLU 60 KARAKTERE SIĞMIYOR.
--
--  `uss_alan` alan ADI için ölçülmüştü. 605'ten beri orada YOL duruyor
--  ("HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES") ve 623'ün tekrarlı
--  grupları yolu iyice uzattı:
--    HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[12]/ISLEM_HEKIM_BILGISI/
--    HEKIM_KIMLIK_NUMARASI   -> 77 karakter
--
--  Kalem sayısı arttıkça indeks de büyüyor; sınır iki basamağa takılacak
--  bir yer değil. `skrs_sistem` de GUID (36) için 60'tı, orada sorun yok
--  ama `skrs_kod` 30 karakter: SKRS kodları kısa, dokunulmuyor.
-- =====================================================================

alter table public.enabiz_paket_alan
  alter column uss_alan type varchar(200);

comment on column public.enabiz_paket_alan.uss_alan is
  '624: USS alan YOLU - "VERI_SETI/GRUP[n]/ALAN". Tekrarli grupta [n] '
  'indeks tasir; indeks govdeye yazilmaz, uretimde kimliktir.';

do $$
begin
    raise notice '624 tamam: uss_alan 200 karakter';
end $$;

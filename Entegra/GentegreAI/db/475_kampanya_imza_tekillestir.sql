-- =====================================================================
-- 475 - fn_taraf_kampanya İMZASI TEKİLLEŞTİRİLDİ
--
-- 468, kampanyayı sözleşmeye bağlarken üç parametreli bir sürüm yazdı ve
-- eski çağrılar kırılmasın diye iki parametreli sarmalayıcıyı da bıraktı.
-- İkisinin de sonraki parametreleri VARSAYILANLI olduğu için
-- `fn_taraf_kampanya(kurum)` çağrısı ikisine birden uyuyor:
--   "42725: function public.fn_taraf_kampanya(integer) is not unique"
-- Başvuru kartı bu yüzden 500 dönüyordu.
--
-- Sarmalayıcı DÜŞÜRÜLÜR: üç parametreli sürümün varsayılanları eski
-- çağrıları zaten karşılıyor (p_tarih = current_date, p_sozlesme_id = null).
-- =====================================================================

drop function if exists public.fn_taraf_kampanya(integer, date);

do $$
begin
    raise notice '475 tamam: fn_taraf_kampanya artik tek imza (integer, date, integer)';
end $$;

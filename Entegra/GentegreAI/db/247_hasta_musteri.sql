-- 247: Hasta aynı zamanda MÜŞTERİ (246 eki). Başvuru/fatura cari alanında
-- hasta seçilebilsin diye: cari listesi "musteri=1 or tedarikci=1 or aday=1"
-- süzdüğü için hastalar aramada çıkmıyordu.

update public.taraf set musteri = 1 where hasta = 1 and musteri <> 1;

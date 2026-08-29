-- 253: PASİF personel randevu alamaz (kullanıcı: "pasif personel randevu
-- verilemez, ayarlara gelemez").
--
-- 252'deki görünüm pasif personeli listeliyor, yalnız `aktif` kolonunu 0
-- döndürüyordu; randevu kartındaki hekim listesinde çıkmaya devam ediyordu.
-- Artık satır hiç gelmiyor. Geçmiş randevular etkilenmez - hekim_id kaydı
-- durur, yalnız YENİ randevuda o kişi seçilemez.

create or replace view public.v_hekim_lookup as
select t.id, t.unvan as ad, 1 as aktif
  from public.taraf t
 where t.personel = 1
   and t.randevu_verilebilir = 1
   and coalesce(t.durum, 1) = 1;

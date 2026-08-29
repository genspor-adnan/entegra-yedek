-- 267: taraf_adres.tur için varsayılan (266 aday hasta kartının devamı).
--
-- Aday hasta kartı tek adres satırı (İl / İlçe) yazıyor; adres TÜRÜ o ekranda
-- sorulmuyor. Kolon NOT NULL ve varsayılansızdı, insert "tur boş bırakılamaz"
-- ile düşüyordu. 1 = İş/Merkez adresi (kart kod listesindeki ilk tür).

alter table public.taraf_adres alter column tur set default 1;

update public.taraf_adres set tur = 1 where tur is null;

-- 273: kampanya_satir.doviz_cinsi boş kalabilsin (kullanıcı: "İskonto Tipi
-- yüzde seçersem döviz %" -> yüzde satırında döviz YOK).
--
-- Kolon NOT NULL'dı; kart yüzde satırında alanı boşaltınca sunucu
-- "dovizCinsi boş bırakılamaz" diyip kaydı reddediyordu. Döviz yalnız TUTAR
-- tipinde anlamlı - yüzde birimsizdir.

alter table public.kampanya_satir alter column doviz_cinsi drop not null;
alter table public.kampanya_satir alter column doviz_cinsi drop default;

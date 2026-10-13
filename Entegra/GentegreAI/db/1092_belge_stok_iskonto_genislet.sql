-- =============================================================================
--  1092  belge.stok_iskonto numeric(9,4) -> numeric(18,4)
--
--  Delphi FATBASLIK.STOKISK float; üretim fişinde (TUR 6) ADET olarak yeniden
--  kullanılıyor (UUretimWizard.pas: STOKISK := ADET). BILIM'de 12 belgede
--  100.000'i aşıyor (en büyük 390.000) - web kolonu en çok 99.999,9999 alıyordu,
--  aktarımın 500 bin satırlık tam yükleme denemesi (dokuman/18 §11.5-8) belge
--  43898'de "numeric field overflow" ile durdu. Web'de kolonu okuyan kod yok;
--  genişletmek veri kaybetmez, görünüm bağımlılığı yok.
-- =============================================================================

begin;

alter table public.belge alter column stok_iskonto type numeric(18,4);

commit;

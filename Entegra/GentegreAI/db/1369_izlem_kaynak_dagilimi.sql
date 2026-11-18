-- =============================================================================
--  1369  ÇIKIŞ İZLEMİNİN KAYNAK DAĞILIMI (stok/belge incelemesi 18.11.2026, bulgu 10)
--
--  Çıkış / transfer izlemi lotun giriş satırlarından FIFO ile `kalan` düşer. Belge düzenlenip silinince lot
--  bakiyesi geri alınıyor ama düşülen kalan giriş satırlarına geri verilmiyordu: birkaç düzenlemede kaynak satırın
--  kalanı 0'a iniyor, sonraki çıkışlar kaynak bulamıyor (donus_id 0) ve "bu çıkış hangi girişin malıydı" izi
--  (geri çağırma) kayboluyordu.
--
--  stok_izleme.kaynak_dagilim: çıkış satırının hangi giriş satırından ne kadar düştüğü, [{"id": <izlem>, "m": <miktar>}].
--  Geri alma (BelgeDeposu.KaynakKalaniIadeAsync) aynen iade eder. Eski satırlarda boş - dokunulmaz (bilgi yok).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.stok_izleme add column if not exists kaynak_dagilim jsonb;
comment on column public.stok_izleme.kaynak_dagilim is
  '1369: çıkış / transfer izleminin FIFO ile kalanını düştüğü giriş satırları [{id, m}] - geri almada iade edilir.';

-- =============================================================================
--  1000 - ROL KODU: kayit_kabul -> banko_gorevlisi
--
--  Kullanıcı (09.10.2026): "kayit_kabul rol kodu rename Banko_Gorevlisi".
--
--  Rolün ADI 984'te "Banko Görevlisi" olmuştu, kodu `kayit_kabul` kalmıştı.
--  Kod program referansıdır (StandartRolUclari hiyerarşisi, bu klasördeki
--  18 göç betiği, demo verisi) - bu yüzden rename EKRANDAN değil buradan
--  yapılır; rol kartında `kod` alanı kilitli (998).
--
--  KÜÇÜK HARF ZORUNLU: `ck_rol_kod` kısıtı `^[a-z0-9._-]+$` istiyor, yani
--  istenen "Banko_Gorevlisi" yazımı veritabanına giremez. Diğer rol kodları
--  da bu yazımda (`muhasebe_sorumlu`, `erp_alis`).
--
--  TETİK GEÇİCİ KAPATILIR: `fn_rol_sistem_koru` sistem rolünün kodunu
--  korur ("program bu koda bakıyor") - doğru kural, ama kodu bilinçli
--  değiştiren göç o kapıdan geçmek zorunda. Tetik aynı işlemde geri açılır.
--
--  SIRALAMA GÜVENLİ: sıfırdan kurulumda 020 seed'i `kayit_kabul` ekler,
--  aradaki göçler onu kullanır, bu betik en sonda rename eder. BUNDAN SONRA
--  yazılacak göçler `banko_gorevlisi` kullanmalı.
--
--  `kayit_kabul_sorumlu` (Banko Şefi) DOKUNULMADI: kullanıcı yalnız görevli
--  rolünü istedi, sorumlu rolünün kodu ayrı bir karar.
-- =============================================================================

begin;

alter table public.rol disable trigger tg_rol_sistem_koru_guncelle;

update public.rol set kod = 'banko_gorevlisi'
 where kod = 'kayit_kabul';

-- Üst rol bağı KODLA değil id ile tutulduğu için (ust_rol_id) ayrı düzeltme
--   gerekmiyor; `kayit_kabul_sorumlu` altındaki yeri korunur.

alter table public.rol enable trigger tg_rol_sistem_koru_guncelle;

commit;

-- Kontrol:
--   select id, kod, ad, sistem from rol where kod in ('banko_gorevlisi','kayit_kabul');

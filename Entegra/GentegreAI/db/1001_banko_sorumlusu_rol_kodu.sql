-- =============================================================================
--  1001 - ROL KODU: kayit_kabul_sorumlu -> banko_sorumlusu
--
--  Kullanıcı (09.10.2026): "kayit_kabul_sorumlu kodu da banko_sorumlusu olsun".
--  1000'de görevli rolü yeniden adlandırılmıştı; bu betik şefini hizalıyor.
--
--  Rolün ADI zaten "Banko Sorumlusu" (984). Kod program referansıdır:
--  `StandartRolUclari` kadro ağacında Hasta hizmetleri bölgesinin KÖKÜ bu
--  roldür - görevli, vezne, yatış ofisi, danışma, tıbbi sekreter ve 6 rol
--  daha üst rol olarak onu gösteriyor. Bu yüzden rename ekrandan değil
--  buradan yapılır (rol kartında `kod` alanı 998'den beri kilitli) ve
--  kaynak koddaki harita ile BİRLİKTE değişir.
--
--  Üst rol bağı `ust_rol_id` ile, yani ID ile tutulduğu için alt rollerin
--  bağı kendiliğinden korunur - ayrı düzeltme gerekmiyor.
--
--  Küçük harf zorunlu (`ck_rol_kod` -> `^[a-z0-9._-]+$`) ve
--  `fn_rol_sistem_koru` sistem rolünün kodunu koruduğu için tetik aynı
--  işlemde kapatılıp geri açılır - 1000'deki gerekçenin aynısı.
--
--  BUNDAN SONRAKİ göçler `banko_sorumlusu` kullanmalı; bu betikten önceki
--  göçler eski kodu kullanmaya devam eder ve sıfırdan kurulumda sıra
--  doğrudur (020 seed'i eski kodu ekler, rename en sonda).
-- =============================================================================

begin;

alter table public.rol disable trigger tg_rol_sistem_koru_guncelle;

update public.rol set kod = 'banko_sorumlusu'
 where kod = 'kayit_kabul_sorumlu';

alter table public.rol enable trigger tg_rol_sistem_koru_guncelle;

commit;

-- Kontrol:
--   select r.kod, r.ad, (select kod from rol u where u.id = r.ust_rol_id) ust
--     from rol r where r.kod in ('banko_sorumlusu', 'banko_gorevlisi');

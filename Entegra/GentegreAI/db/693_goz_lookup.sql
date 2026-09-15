-- 693: GÖZ KARTLARI — seçim görünümleri (lookup).
--
-- Kart alanlarındaki combo'lar `KodTablosu` ile beslenir ve sunucu yalnız
-- BEYAZ LİSTEDEKİ görünümlerden okur (istek metni asla SQL'e girmez). Göz
-- kartları dört seçim yapar: cihaz, tetkik (hizmet), postop protokolü ve
-- hastanın açık takip planı.
--
-- Neden ayrı görünüm, neden doğrudan tablo değil:
--  · Tetkik seçimi YALNIZ göz tetkiki olan hizmetleri göstermeli — hizmet
--    tablosunda on binlerce satır var ve "Toraks BT" göz kartında seçilebilir
--    olmamalı (radyolojideki `v_rad_tetkik_lookup` deseninin aynısı).
--  · Cihaz seçimi pasif cihazı göstermemeli: kapatılan bir OCT'ye çekim
--    yazılırsa, cihaz kapalıyken üretilmiş bir kayıt oluşur.
--  · Görünüm `id` + `ad` sözleşmesini sabitler; kart tarafı kolon adı
--    bilmez.

-- Cihaz: ad'ın içinde TÜR de var ("OCT · Topcon Maestro"). İki ayrı sütunla
--   comboda yalnız model görünüyordu ve aynı markanın iki cihazı ayırt
--   edilemiyordu.
create or replace view public.v_goz_cihaz_lookup as
select c.id,
       (case c.tur when 1 then 'Otoref' when 2 then 'Tonometre' when 3 then 'Pakimetre'
                   when 4 then 'OCT' when 5 then 'Görme alanı' when 6 then 'Fundus'
                   when 7 then 'Topografi' when 8 then 'Biyometri' when 9 then 'Endotel'
                   when 10 then 'USG' else '—' end)
       || ' · ' || c.ad                              as ad,
       c.sube_id,
       c.aktif
  from public.goz_cihaz c
 where c.aktif = 1;

comment on view public.v_goz_cihaz_lookup is
  'Göz kartlarında cihaz seçimi (693) - yalnız aktif cihazlar.';

-- Tetkik: yalnız `goz_tetkik = 1` işaretli hizmetler.
-- `hizmet` tablosunda `aktif` kolonu YOK, `durum` var (radyoloji lookup'ında
--   da öyle çözülmüş): pasif hizmet listede kalmasın ama görünüm kırılmasın.
create or replace view public.v_goz_tetkik_lookup as
select h.id,
       (coalesce(nullif(h.kod, '') || ' · ', '') || h.ad)::varchar(200) as ad,
       h.goz_tetkik_tur,
       case when coalesce(h.durum, 1) = 1 then 1 else 0 end as aktif
  from public.hizmet h
 where h.goz_tetkik = 1;

comment on view public.v_goz_tetkik_lookup is
  'Göz görüntüleme/tanısal testi olan hizmetler (693) - goz_goruntuleme YALNIZ bunlardan doğar.';

-- Postop protokolü: işlem kartında "hangi takip planı" seçimi.
create or replace view public.v_goz_protokol_lookup as
select p.id, p.ad, p.aktif
  from public.goz_islem_protokol p
 where p.aktif = 1;

comment on view public.v_goz_protokol_lookup is
  'Göz işlem/postop takip protokolleri (693).';

-- Hastalık takibi: göz muayenesi kartında "bu muayene hangi takibin parçası".
--   Ad'da hastalık + göz + evre birlikte: aynı hastanın iki gözünde iki ayrı
--   glokom takibi olabilir ve comboda ikisi de "Glokom" görünürdü.
create or replace view public.v_goz_takip_lookup as
select t.id,
       (case t.hastalik when 1 then 'Glokom' when 2 then 'Diyabetik retinopati'
                        when 3 then 'AMD' when 4 then 'Üveit' when 5 then 'Keratokonus'
                        when 6 then 'Ambliyopi' else '—' end)
       || ' · ' || (case t.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end)
       || case when t.evre = '' then '' else ' · ' || t.evre end  as ad,
       t.hasta_id,
       t.sube_id,
       t.durum as aktif
  from public.goz_hastalik_takip t
 where t.durum = 1;

comment on view public.v_goz_takip_lookup is
  'Hastanın açık göz hastalığı takip planları (693) - muayene karti buna bağlanır.';

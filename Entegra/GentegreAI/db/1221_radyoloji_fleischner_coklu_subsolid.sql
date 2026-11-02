-- =============================================================================
--  1221  FLEISCHNER ÖNERİSİ - ÇOKLU SUBSOLİD SEÇENEKLERİ + SEÇENEK UZUNLUĞU 600
--
--  Kullanıcı (01.11.2026): "Fleischner otomatik hesaplamayı ekle". Rapor ekranı öneriyi nodül tipi / sayısı / çapı /
--  solid komponent / risk grubundan seçer (web: sayfalar/radyoloji/fleischner.ts). 1220'nin seçeneklerinde ÇOKLU
--  SUBSOLİD nodülün iki önerisi yoktu; eklenince liste 400 karakteri aşıyor:
--    1) secenekler varchar(400) -> varchar(600) (şablon alanı + paket alanı),
--    2) iki seçenek SONA eklenir - sıra hesap içindir, mevcutların sırası DEĞİŞMEZ,
--    3) şablonlara uygulanmış "fleischner" alanı yalnız seçenekleri 1220'deki haliyle AYNIYSA güncellenir
--       (kurumun elle değiştirdiği alana dokunulmaz).
--  İdempotent.
-- =============================================================================

begin;

alter table public.radyoloji_sablon_alan      alter column secenekler type varchar(600);
alter table public.radyoloji_alan_paket_alan  alter column secenekler type varchar(600);

create temp table _f (eski varchar(600), yeni varchar(600)) on commit drop;
insert into _f values (
  'Rutin takip gerekmez|12. ayda isteğe bağlı BT|6-12. ayda BT, sonra 18-24. ayda BT düşünülebilir|'
  || '3-6. ayda BT, sonra 18-24. ayda BT|3. ayda BT, PET-BT ya da biyopsi düşünülmeli|'
  || '6-12. ayda BT, kalıcıysa 5 yıla kadar 2 yılda bir BT|3-6. ayda BT, kalıcı ve solid kısım 6 mm altıysa 5 yıl yıllık BT|'
  || 'Kriter uygulanmaz (tarama, kanser öyküsü, 35 yaş altı)',
  'Rutin takip gerekmez|12. ayda isteğe bağlı BT|6-12. ayda BT, sonra 18-24. ayda BT düşünülebilir|'
  || '3-6. ayda BT, sonra 18-24. ayda BT|3. ayda BT, PET-BT ya da biyopsi düşünülmeli|'
  || '6-12. ayda BT, kalıcıysa 5 yıla kadar 2 yılda bir BT|3-6. ayda BT, kalıcı ve solid kısım 6 mm altıysa 5 yıl yıllık BT|'
  || 'Kriter uygulanmaz (tarama, kanser öyküsü, 35 yaş altı)|'
  || '3-6. ayda BT, stabilse 2. ve 4. yılda BT düşünülebilir|3-6. ayda BT, sonraki yönetim en şüpheli nodüle göre');

update public.radyoloji_alan_paket_alan a set secenekler = f.yeni
  from _f f, public.radyoloji_alan_paket p
 where p.id = a.paket_id and p.kod = 'TORAKS-FLEISCHNER' and a.alan_kod = 'fleischner' and a.secenekler = f.eski;

update public.radyoloji_sablon_alan a set secenekler = f.yeni
  from _f f
 where a.alan_kod = 'fleischner' and a.secenekler = f.eski;

commit;

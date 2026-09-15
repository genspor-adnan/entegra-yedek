-- 696: YATAN HASTA — seçim görünümleri (lookup).
--
-- Kart alanlarındaki combo'lar `KodTablosu` ile beslenir ve sunucu yalnız BEYAZ
-- LİSTEDEKİ görünümlerden okur. Yatan hasta kartları iki seçim yapar: oda ve
-- yatak.
--
-- YATAK SEÇİMİNDE AD, KODUN KENDİSİ DEĞİL: "A-301/1 · tek kişilik · Dahiliye"
-- gibi okunur bir metin. Yalnız kod gösterilseydi kabul memuru odanın türünü
-- ve servisini bilmeden yatak seçerdi - oysa boş yatağın VERİLEBİLİR olup
-- olmadığını oda belirler.

create or replace view public.v_oda_lookup as
select o.id,
       (o.kod
        || case when o.ad = '' then '' else ' · ' || o.ad end
        || case o.tur when 1 then ' · tek kişilik' when 2 then ' · çift kişilik'
                      when 3 then ' · çok yataklı' when 4 then ' · suit'
                      when 5 then ' · yoğun bakım' when 6 then ' · doğum' else '' end
        || coalesce(' · ' || d.ad, ''))::varchar(200) as ad,
       o.sube_id,
       o.departman_id,
       o.aktif
  from public.oda o
  left join public.departman d on d.id = o.departman_id
 where o.aktif = 1;

comment on view public.v_oda_lookup is
  'Oda seçimi (696) - ad içinde oda türü ve servis: kural odanın, seçim onunla yapılır.';

-- YATAK LİSTESİ SEÇİMDE DOLUYU DA GÖSTERİR ama durumuyla birlikte: dolu yatağı
--   gizlemek "yer yok" dedirtir, oysa sebep (temizlik / arıza / dolu)
--   çözülebilir bir şey olabilir. Engelleme veritabanında zaten var
--   (ux_yatis_yatak_aktif): aynı yatağa ikinci aktif yatış yazılamaz.
create or replace view public.v_yatak_lookup as
select yk.id,
       (yk.kod
        || case o.tur when 1 then ' · tek kişilik' when 2 then ' · çift kişilik'
                      when 3 then ' · çok yataklı' when 4 then ' · suit'
                      when 5 then ' · yoğun bakım' when 6 then ' · doğum' else '' end
        || coalesce(' · ' || d.ad, '')
        || case yk.durum when 2 then ' · DOLU' when 3 then ' · rezerve'
                         when 4 then ' · temizlikte' when 5 then ' · kapalı' else '' end
       )::varchar(200) as ad,
       yk.sube_id,
       yk.oda_id,
       yk.durum,
       yk.aktif
  from public.yatak yk
  join public.oda o on o.id = yk.oda_id
  left join public.departman d on d.id = o.departman_id
 where yk.aktif = 1 and o.aktif = 1;

comment on view public.v_yatak_lookup is
  'Yatak seçimi (696) - dolu/temizlikte olan da SEBEBİYLE görünür; engelleme '
  'benzersiz indekste (aynı yatağa ikinci aktif yatış yazılamaz).';

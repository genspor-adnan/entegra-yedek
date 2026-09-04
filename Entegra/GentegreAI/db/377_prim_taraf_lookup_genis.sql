-- ============================================================================
--  377 - v_prim_taraf_lookup: TUM personel + dis hekim
--
--  375'te bu gorunum yalnizca PRIM ROLU ISARETLI kisileri tasiyordu ve plana
--  ekleme o listeyle SINIRLANIYORDU. Sonuc: kullanici jenerik aramada bir
--  personel secip Enter'ladiginda satir sessizce eklenmiyordu (21 kisi listede,
--  159 personel aramada).
--
--  ENGEL YANLIS YERDEYDI. Rol isaretlemesi AYRI BIR KART (personelin "Prim
--  Rolleri" sekmesi) ve sonradan da doldurulabilir; plan kurarken kisiyi
--  eklemeyi yasaklamak, kullaniciyi iki kart arasinda mekik dokumaya zorlar.
--
--  Yeni kural: plana HERKES eklenebilir; rolu isaretli olmayan kisi gridde
--  ACIKCA gorunur ("Prim Rolü" kolonu bos). Yani ayni bilgi engel olarak degil
--  UYARI olarak verilir - kullanici gorup karar verir.
-- ============================================================================

create or replace view public.v_prim_taraf_lookup as
select t.id,
       t.unvan as ad,
       case when coalesce(t.durum, 1) = 1 then 1 else 0 end as aktif
  from public.taraf t
  join public.taraf_personel p on p.id = t.id;

comment on view public.v_prim_taraf_lookup is
  'Prim planina eklenebilecek kisiler (377): TUM personel + dis hekim. '
  '375''te yalniz prim rolu isaretli olanlari tasiyordu ve bu, plana ekleme '
  'sirasinda sessiz bir engele donusuyordu; rol eksikligi artik gridde '
  '"Prim Rolü" kolonunda gorunur.';

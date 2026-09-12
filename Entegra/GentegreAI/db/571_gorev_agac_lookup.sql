-- =====================================================================
--  571_gorev_agac_lookup.sql
--  Görev kartındaki "Üst Görev" ağaç combosunun okuduğu görünüm.
--
--  `v_gorev_lookup` ZATEN VARDI ama onun `ust_id`si DEPARTMANI gösteriyor
--  ("bu görev hangi bölümde geçerli", 255). Ağaç combosu gerçek ÜST GÖREVİ
--  istiyor (570); ikisi ayrı sorudur, aynı görünüme sığmaz - bu yüzden ikinci
--  bir lookup açılır. Kolon sözleşmesi kod tablosu kaynaklarıyla aynı:
--  id · ad · aktif · ust_id.
-- =====================================================================

create or replace view public.v_gorev_agac_lookup as
select g.id,
       g.ad,
       case when g.durum = 1 then 1 else 0 end as aktif,
       g.ust_id
  from public.personel_gorev g;

comment on view public.v_gorev_agac_lookup is
  'Gorev AGAC secimi (570/571): ust_id gercek ust gorev - v_gorev_lookup departmana bakar.';

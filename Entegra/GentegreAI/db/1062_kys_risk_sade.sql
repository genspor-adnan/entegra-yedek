-- =============================================================================
--  1062  KURUMSAL KALİTE - RİSK LİSTESİ MOCKUP'A UYDU (Kalite2/risk_listesi.html)
--
--  Kullanıcı (12.10.2026): "risk listesini mockup gibi yap". Liste
--  No · Risk · Birim · O · Ş · Skor (renkli) · Sahibi + sağda kart.
--    skor_rozet: "skor|seviye" ("20|4") - liste skoru seviyenin renginde
--                kutu olarak çizer (web gridHucre bicim 'riskSkor').
--  sahip_adi: unvan yerine fn_taraf_ad (personelde unvan yalnız "Dr." önekidir,
--    940; ad boş görünüyordu).
--  Yeni kolon görünümün SONUNA eklenir (create or replace). İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_risk as
select r.id, r.no, r.surec, r.departman_id, coalesce(d.ad, '') as birim_adi, r.tanim,
       r.olasilik, r.siddet, r.skor,
       public.fn_kys_risk_seviye(r.skor) as seviye,
       case public.fn_kys_risk_seviye(r.skor) when 1 then 'Düşük' when 2 then 'Orta' when 3 then 'Yüksek' when 4 then 'Çok yüksek' end as seviye_adi,
       r.kontrol_onlem, r.sahip_id,
       coalesce(nullif(public.fn_taraf_ad(s.unvan, s.ad, s.soyad), ''), s.unvan, '')::varchar as sahip_adi,
       r.gozden_gecirme, (r.gozden_gecirme < current_date and r.durum in (1, 2))::int as gozden_gecirme_gecti,
       r.dof_id, r.durum,
       case r.durum when 1 then 'Açık' when 2 then 'Önlem uygulanıyor' when 3 then 'Kabul edildi' when 4 then 'Kapandı' else '' end as durum_adi,
       r.sube_id,
       (r.skor || '|' || public.fn_kys_risk_seviye(r.skor))::varchar(10) as skor_rozet
  from public.kalite_risk r
  left join public.departman d on d.id = r.departman_id
  left join public.taraf s on s.id = r.sahip_id;

commit;

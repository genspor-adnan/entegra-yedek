-- =============================================================================
--  1071  KURUMSAL KALİTE - İÇ DENETİM LİSTESİ MOCKUP FARKLARI (Kalite2/ic_denetim.html)
--
--  Kullanıcı (12.10.2026): "iç denetim listesini mockup gibi yap". Bulgu ve
--  Açılan DÖF boşsa "—" (mockup): bulgu_metin, dof_metin metin kolonları.
--  Yeni kolonlar görünümün SONUNA eklenir. İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_denetim as
select d.id, d.no, d.departman_id, coalesce(dp.ad, '')::varchar(100) as birim_adi,
       d.plan_tarih, d.gerceklesen, coalesce(d.gerceklesen, d.plan_tarih) as tarih,
       d.bas_denetci_id, coalesce(fn_taraf_ad(t.unvan, t.ad, t.soyad), '')::varchar(120) as bas_denetci_adi,
       d.ekip, d.kapsam,
       nullif(concat_ws(' · ',
         (select nullif(count(*), 0) || ' majör' from public.kalite_denetim_bulgu b where b.denetim_id = d.id and b.sinif = 1),
         (select nullif(count(*), 0) || ' minör' from public.kalite_denetim_bulgu b where b.denetim_id = d.id and b.sinif = 2),
         (select nullif(count(*), 0) || ' gözlem' from public.kalite_denetim_bulgu b where b.denetim_id = d.id and b.sinif = 3)), '')::varchar(80) as bulgu_ozet,
       (d.durum = 1 and d.plan_tarih < current_date) as gecikti,
       case when d.durum = 2 then 'Tamamlandı' when d.plan_tarih < current_date then 'Gecikti' else 'Planlı' end::varchar(20) as durum_adi,
       d.durum, d.sube_id,
       nullif(concat_ws(', ', nullif(fn_taraf_ad(t.unvan, t.ad, t.soyad), ''), nullif(d.ekip, '')), '')::varchar(400) as denetci,
       (select count(*) from public.kalite_dof f
          join public.kalite_denetim_bulgu b on b.id = f.kaynak_id
         where f.kaynak_tur = 1 and f.durum <> 9 and b.denetim_id = d.id)::int as dof_sayisi,
       coalesce(nullif(concat_ws(' · ',
         (select nullif(count(*), 0) || ' majör' from public.kalite_denetim_bulgu b where b.denetim_id = d.id and b.sinif = 1),
         (select nullif(count(*), 0) || ' minör' from public.kalite_denetim_bulgu b where b.denetim_id = d.id and b.sinif = 2),
         (select nullif(count(*), 0) || ' gözlem' from public.kalite_denetim_bulgu b where b.denetim_id = d.id and b.sinif = 3)), ''), '—')::varchar(80) as bulgu_metin,
       coalesce(nullif((select count(*) from public.kalite_dof f
          join public.kalite_denetim_bulgu b on b.id = f.kaynak_id
         where f.kaynak_tur = 1 and f.durum <> 9 and b.denetim_id = d.id), 0)::text, '—')::varchar(10) as dof_metin
  from public.kalite_denetim d
  left join public.departman dp on dp.id = d.departman_id
  left join public.taraf t on t.id = d.bas_denetci_id;

commit;

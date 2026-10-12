-- =============================================================================
--  1066  KURUMSAL KALİTE - TEDARİKÇİ DEĞERLENDİRME MOCKUP'A UYDU (Kalite2/tedarikci.html)
--
--  Kullanıcı (12.10.2026): "tedarikçiyi mockup gibi yap". Liste
--  Tedarikçi · Ne alıyoruz · Kalite · Teslim · Fiyat · Puan · Sonuç ·
--  Son değerlendirme · Uygunsuzluk; uygunsuzluk tek kolonda
--  "3 · DÖF-2026-018" (sayı + son DÖF), yoksa "—".
--  Yeni kolon görünümün SONUNA eklenir. İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_tedarikci as
select d.id, d.taraf_id,
       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as tedarikci_adi,
       d.ne_aliniyor, d.kalite, d.teslim, d.fiyat, d.puan, d.sonuc,
       case d.sonuc when 1 then 'Onaylı' when 2 then 'Şartlı' when 3 then 'Red' end as sonuc_adi,
       d.tarih,
       (d.tarih < current_date - interval '12 months')::int as vakti,
       coalesce(u.adet, 0)::int as uygunsuzluk,
       coalesce(u.son_no, '') as son_dof_no,
       d.aciklama, d.sube_id,
       (case when coalesce(u.adet, 0) = 0 then '—'
             else u.adet || coalesce(' · ' || u.son_no, '') end)::varchar(40) as uygunsuzluk_metin
  from public.taraf t
  join lateral (select x.* from public.kalite_tedarikci_deg x
                 where x.taraf_id = t.id order by x.tarih desc, x.id desc limit 1) d on true
  left join lateral (select count(*) as adet,
                            (array_agg(f.no order by f.id desc))[1] as son_no
                       from public.kalite_dof f
                      where f.kaynak_tur = 8 and f.kaynak_id = t.id and f.durum <> 9) u on true;

commit;

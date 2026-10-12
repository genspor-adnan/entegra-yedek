-- =============================================================================
--  1067  KURUMSAL KALİTE - KALİBRASYON MOCKUP'A UYDU (Kalite2/kalibrasyon.html)
--
--  Kullanıcı (12.10.2026): "kalibrasyonu mockup gibi yap". Liste No · Cihaz ·
--  Birim · Periyot ("12 ay") · Son kalibrasyon · Sonraki · Sonuç · Sertifika (📎).
--    periyot_adi     : "12 ay"
--    sertifika_sayisi: kalibrasyon / sertifika adlı demirbaş belgesi sayısı
--                      (kartın Sertifikalar sekmesi demirbaşın belgelerine yazar).
--  Yeni kolonlar görünümün SONUNA eklenir. İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_kalibrasyon as
select d.id,
       d.sube_id,
       d.kod                                  as no,
       d.ad,
       d.seri_no,
       d.departman_id,
       coalesce(dp.ad, '')::varchar(200)      as birim_adi,
       d.kalibrasyon_periyot_ay               as periyot_ay,
       d.son_kalibrasyon,
       x.sonraki,
       (x.sonraki - current_date)             as kalan_gun,
       (case when x.sonraki is null or x.sonraki < current_date then 3
             when x.sonraki <= current_date + 30 then 2
             else 1 end)::smallint            as durum,
       (case when x.sonraki is null then 'Kalibrasyon yok'
             when x.sonraki < current_date then 'Süresi geçti'
             when x.sonraki <= current_date + 30 then 'Yaklaşıyor'
             else 'Uygun' end)::varchar(20)   as durum_adi,
       sk.id                                  as son_kayit_id,
       sk.sonuc                               as son_sonuc,
       (case sk.sonuc when 0 then 'Açık' when 1 then 'Uygun' when 2 then 'Uygun değil'
                      when 3 then 'Şartlı uygun' else '' end)::varchar(20) as son_sonuc_adi,
       coalesce(fr.unvan, '')::varchar(200)   as firma_adi,
       (case when exists (select 1 from public.dokuman o
                           where o.kaynak = 'demirbas' and o.kaynak_id = d.id
                             and (o.ad ilike '%kalib%' or o.ad ilike '%sertifika%'
                                  or o.belge_turu ilike '%kalib%' or o.belge_turu ilike '%sertifika%'))
             then 1 else 0 end)::smallint     as sertifika,
       (d.kalibrasyon_periyot_ay || ' ay')::varchar(20) as periyot_adi,
       (select count(*) from public.dokuman o where o.kaynak = 'demirbas' and o.kaynak_id = d.id
           and (o.ad ilike '%kalib%' or o.ad ilike '%sertifika%' or o.belge_turu ilike '%kalib%' or o.belge_turu ilike '%sertifika%'))::integer as sertifika_sayisi
  from public.demirbas d
  left join public.departman dp on dp.id = d.departman_id
  left join lateral (
        select k.id, k.sonuc, k.firma_id
          from public.demirbas_kalibrasyon k
         where k.demirbas_id = d.id and k.tur = 1
         order by k.tarih desc, k.id desc
         limit 1) sk on true
  left join public.taraf fr on fr.id = sk.firma_id
 cross join lateral (
        select coalesce(d.kalibrasyon_gecerlilik,
                        case when d.son_kalibrasyon is not null and d.kalibrasyon_periyot_ay > 0
                             then (d.son_kalibrasyon + make_interval(months => d.kalibrasyon_periyot_ay))::date
                        end) as sonraki) x
 where d.durum <> 4
   and (d.kalibrasyon_periyot_ay > 0 or d.kalibrasyon_gecerlilik is not null or sk.id is not null);

commit;

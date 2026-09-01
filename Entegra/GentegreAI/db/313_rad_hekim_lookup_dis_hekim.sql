-- 313: Radyoloji hekim lookup'ina DIS HEKIMLER de girsin.
--
-- Bulgu (kabul akisi uctan uca testi): dis istemde secilen dis hekim
-- (radyoloji_istem.istek_hekim_id) istem KARTINDA bos gorunuyordu - kartin
-- "İsteyen Hekim" combosu v_rad_hekim_lookup'tan besleniyor ve o gorunum
-- yalniz IC hekimleri (hekim=1 ya da randevu verilebilir personel) tasiyordu.
-- Kayit dogruydu, ekran yanlis gosteriyordu.
--
-- Dis hekim (305) de istem yapabilen bir hekimdir; ayni listede "(dış)"
-- etiketiyle durmalari zaten 283'te ongorulmus (dis_mi bayragi) - eksik olan
-- yalniz taraf_personel.dis_hekim uzerinden gelen kayitlardi.

create or replace view public.v_rad_hekim_lookup as
select t.id,
       trim(coalesce(t.unvan, '')
            || case when coalesce(h.brans, '') <> '' then ' · ' || h.brans
                    when coalesce(kd.ad, '') <> '' then ' · ' || kd.ad else '' end
            || case when coalesce(h.dis_mi, 0) = 1
                      or coalesce(p.dis_hekim, 0) = 1 then ' (dış)' else '' end)::varchar(200) as ad,
       case when coalesce(t.durum, 1) = 1 then 1 else 0 end as aktif
  from public.taraf t
  left join public.taraf_hekim h on h.id = t.id
  left join public.taraf_personel p on p.id = t.id
  -- Dis hekimin bransi kod listesinde (305) - lookup adinda gorunsun ki
  --   ayni isimli iki hekim ayirt edilebilsin.
  left join public.kod_liste kl on kl.kod = 'hekim.brans'
  left join public.kod_deger kd on kd.liste_id = kl.id
                               and kd.deger::text = nullif(p.brans, '')
 where t.hekim = 1
    or (t.personel = 1 and t.randevu_verilebilir = 1)
    or coalesce(p.dis_hekim, 0) = 1;

comment on view public.v_rad_hekim_lookup is
  'Istem yapabilen hekimler (283): ic hekim/randevulu personel + DIS hekimler (313).';

-- 970 GÖZ MUAYENE LİSTESİ + KARTI (mockup Ekranlar/Goz/goz_muayene_listesi_v2.html · goz_muayene_karti_v2.html)
--
--   v_goz_muayene_ozet: liste kolonları, gösterge kutuları ve önizleme aynı tanımdan okur.
--     * görme: en iyi düzeltilmiş (BCVA) yoksa mevcut gözlükle, yoksa düzeltmesiz.
--     * görme düşüşü: aynı hastanın bir önceki göz muayenesine göre logMAR farkı ≥ 0,2
--       (Snellen'de ~2 sıra) - ondalık farkı 0,1 ile 0,9 arasında aynı anlamı taşımaz.
--     * GİB yüksek: gözün hedef GİB'i (ölçüm satırı ya da hastalık takibi) yoksa 21 üstü.
--     * dilatasyon bekliyor: dilate edildi, muayene kapanmadı, fundus henüz yazılmadı.
--     * kontrol gecikmiş: kontrol günü geçti, hastanın sonraki göz muayenesi yok.
--   Bayraklar bit: 1 = sağ (OD), 2 = sol (OS).

drop view if exists public.v_goz_muayene_ozet;
create view public.v_goz_muayene_ozet as
with g as (
    select gm.id, gm.hasta_id, m.muayene_tarihi as tarih
      from public.goz_muayene gm join public.muayene m on m.id = gm.muayene_id
)
select gm.id as goz_muayene_id,
       case when th.dogum_tarihi is null then null::int else extract(year from age(th.dogum_tarihi))::int end as yas,
       coalesce(th.cinsiyet, 0)::smallint as cinsiyet,
       coalesce(m.muayene_no, '')::varchar(40) as protokol,
       m.personel_id as hekim_id,
       (m.tamamlanma is not null) as tamamlandi,
       va.od as bcva_od, va.os as bcva_os,
       ova.od as onceki_bcva_od, ova.os as onceki_bcva_os,
       ((case when va.od > 0 and ova.od > 0 and (log(ova.od::numeric) - log(va.od::numeric)) >= 0.2 then 1 else 0 end)
      | (case when va.os > 0 and ova.os > 0 and (log(ova.os::numeric) - log(va.os::numeric)) >= 0.2 then 2 else 0 end))::smallint as gorme_dusus,
       gb.od as gib_od, gb.os as gib_os,
       coalesce(gb.hedef_od, tk.hedef_od) as hedef_od, coalesce(gb.hedef_os, tk.hedef_os) as hedef_os,
       ((case when gb.od > coalesce(gb.hedef_od, tk.hedef_od, 21) then 1 else 0 end)
      | (case when gb.os > coalesce(gb.hedef_os, tk.hedef_os, 21) then 2 else 0 end))::smallint as gib_yuksek,
       coalesce(tn.metin, '')::varchar(200) as tani,
       case when gm.kontrol_gun > 0 then (m.muayene_tarihi::date + gm.kontrol_gun) end as kontrol_tarihi,
       case when gm.kontrol_gun > 0 and m.muayene_tarihi::date + gm.kontrol_gun < (now() at time zone 'Europe/Istanbul')::date
                 and not exists (select 1 from g s where s.hasta_id = gm.hasta_id and s.tarih > m.muayene_tarihi)
            then 1 else 0 end::smallint as kontrol_gecikmis,
       case when gm.dilate = 1 and m.tamamlanma is null
                 and not exists (select 1 from public.goz_fundus f where f.goz_muayene_id = gm.id)
            then 1 else 0 end::smallint as dilatasyon_bekliyor,
       case when tk.glokom then 1 else 0 end::smallint as glokom,
       case when tk.retina then 1 else 0 end::smallint as retina,
       coalesce(tk.hastaliklar, '')::varchar(200) as takip_hastaliklar
  from public.goz_muayene gm
  join public.muayene m on m.id = gm.muayene_id
  left join public.taraf_hasta th on th.id = gm.hasta_id
  left join lateral (
        select max(x.deger) filter (where x.goz = 1) as od, max(x.deger) filter (where x.goz = 2) as os
          from (select distinct on (v.goz) v.goz, v.deger_ondalik as deger
                  from public.goz_gorme v
                 where v.goz_muayene_id = gm.id and v.goz in (1, 2) and v.tur in (1, 2, 4) and v.deger_ondalik is not null
                 order by v.goz, case v.tur when 4 then 0 when 2 then 1 else 2 end, v.zaman desc) x) va on true
  left join lateral (
        select max(x.deger) filter (where x.goz = 1) as od, max(x.deger) filter (where x.goz = 2) as os
          from (select distinct on (v.goz) v.goz, v.deger_ondalik as deger
                  from public.goz_gorme v
                  join g p on p.id = v.goz_muayene_id
                 where p.hasta_id = gm.hasta_id and p.tarih < m.muayene_tarihi
                   and v.goz in (1, 2) and v.tur in (1, 2, 4) and v.deger_ondalik is not null
                 order by v.goz, p.tarih desc, case v.tur when 4 then 0 when 2 then 1 else 2 end) x) ova on true
  left join lateral (
        select max(o.gib) filter (where o.goz = 1) as od, max(o.gib) filter (where o.goz = 2) as os,
               max(o.hedef_gib) filter (where o.goz = 1) as hedef_od, max(o.hedef_gib) filter (where o.goz = 2) as hedef_os
          from public.goz_tonometri o where o.goz_muayene_id = gm.id) gb on true
  left join lateral (
        select min(t.hedef_gib) filter (where t.goz in (1, 3)) as hedef_od,
               min(t.hedef_gib) filter (where t.goz in (2, 3)) as hedef_os,
               bool_or(t.hastalik = 1) as glokom, bool_or(t.hastalik in (2, 3)) as retina,
               string_agg(distinct case t.hastalik when 1 then 'Glokom' when 2 then 'Diyabetik retinopati' when 3 then 'AMD'
                                    when 4 then 'Üveit' when 5 then 'Keratokonus' when 6 then 'Ambliyopi' end, ', ') as hastaliklar
          from public.goz_hastalik_takip t where t.hasta_id = gm.hasta_id and t.durum = 1) tk on true
  left join lateral (
        select string_agg(t.icd_kod || coalesce(' ' || i.ad, ''), ' · ' order by t.sira, t.id) as metin
          from public.tani t left join public.icd i on i.kod = t.icd_kod
         where t.muayene_id = gm.muayene_id) tn on true;

comment on view public.v_goz_muayene_ozet is
  'Göz muayene listesi / göstergesi / önizlemesi (970): görme ve GİB sağ / sol, önceki görme, '
  'düşüş ve hedef üstü bayrakları (1 OD, 2 OS), tanı, kontrol, dilatasyon, hastalık takibi.';

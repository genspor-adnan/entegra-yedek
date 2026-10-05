-- 973 GÖZLÜK REÇETELERİ LİSTESİ (mockup Ekranlar/Goz/goz_gozluk_recete_listesi_v2.html)
--
--   v_goz_gozluk_ozet: liste uyarıları ve gösterge kutuları aynı tanımdan.
--     * sgk_erken: SGK'lı reçete, hastanın önceki SGK'lı imzalı reçetesinden 2 yıl geçmeden yazıldı.
--     * sgk_hak_dogdu: hastanın SON SGK'lı reçetesi ve 2 yıl son 30 günde doldu (hatırlatma listesi).
--     * anizometropi: iki göz sferik eşdeğer farkı ≥ 1,50 D.
--     * dilate: reçetenin muayenesi dilate - refraksiyon pupil genişken alınmış olabilir.

drop view if exists public.v_goz_gozluk_ozet;
create view public.v_goz_gozluk_ozet as
select r.id as recete_id,
       case when th.dogum_tarihi is null then null::int else extract(year from age(th.dogum_tarihi))::int end as yas,
       coalesce(th.cinsiyet, 0)::smallint as cinsiyet,
       coalesce(t.kod, '')::varchar(40) as hasta_no,
       coalesce(m.muayene_no, '')::varchar(40) as protokol,
       case when coalesce(r.sgk_hak, 0) = 1 and exists (
              select 1 from public.goz_gozluk_recetesi p
               where p.hasta_id = r.hasta_id and p.id <> r.id and p.durum >= 2 and coalesce(p.sgk_hak, 0) = 1
                 and p.ekleme_tarihi < r.ekleme_tarihi and p.ekleme_tarihi > r.ekleme_tarihi - interval '2 years')
            then 1 else 0 end::smallint as sgk_erken,
       case when coalesce(r.sgk_hak, 0) = 1 and r.durum >= 2
                 and r.ekleme_tarihi + interval '2 years' between now() - interval '30 days' and now()
                 and not exists (select 1 from public.goz_gozluk_recetesi s
                                  where s.hasta_id = r.hasta_id and s.ekleme_tarihi > r.ekleme_tarihi and s.durum >= 1)
            then 1 else 0 end::smallint as sgk_hak_dogdu,
       case when r.od_sph is not null and r.os_sph is not null
                 and abs((r.od_sph + coalesce(r.od_cyl, 0) / 2) - (r.os_sph + coalesce(r.os_cyl, 0) / 2)) >= 1.5
            then 1 else 0 end::smallint as anizometropi,
       coalesce(gm.dilate, 0)::smallint as dilate,
       case when r.durum between 2 and 3 and r.gecerlilik_bitis between current_date and current_date + 30 then 1 else 0 end::smallint as bitecek,
       concat_ws(' · ',
           case when coalesce(r.sgk_hak, 0) = 1 and exists (
                  select 1 from public.goz_gozluk_recetesi p
                   where p.hasta_id = r.hasta_id and p.id <> r.id and p.durum >= 2 and coalesce(p.sgk_hak, 0) = 1
                     and p.ekleme_tarihi < r.ekleme_tarihi and p.ekleme_tarihi > r.ekleme_tarihi - interval '2 years')
                then 'SGK 2 yıl dolmadı' end,
           case when r.od_sph is not null and r.os_sph is not null
                     and abs((r.od_sph + coalesce(r.od_cyl, 0) / 2) - (r.os_sph + coalesce(r.os_cyl, 0) / 2)) >= 1.5
                then 'anizometropi' end,
           case when coalesce(gm.dilate, 0) = 1 and r.durum = 1 then 'dilate refraksiyon' end,
           case when r.durum between 2 and 3 and r.gecerlilik_bitis between current_date and current_date + 30 then 'geçerlilik bitiyor' end
       )::varchar(200) as uyari
  from public.goz_gozluk_recetesi r
  join public.taraf t on t.id = r.hasta_id
  left join public.taraf_hasta th on th.id = r.hasta_id
  left join public.muayene m on m.id = r.muayene_id
  left join public.goz_muayene gm on gm.muayene_id = r.muayene_id;

comment on view public.v_goz_gozluk_ozet is
  'Gözlük reçeteleri listesi / göstergesi (973): yaş, H / P no, SGK 2 yıl, anizometropi, dilate, geçerlilik, uyarı.';

-- ============================================================================
--  Gentegre AI — PERSONEL LİSTESİ (gösterge şeridi, Bugün, kıdem, kalan izin)
--  963_personel_listesi.sql
--
--  Kullanıcı: "personel listesi için mockup yap" → "mockup uygun, uygula"
--  (Ekranlar/IK/personel_listesi.html).
--
--  v_personel_durum: personel başına TEK satır, listede ve gösterge şeridinde
--  aynı tanım kullanılsın diye. Liste kaynağı buna left join yapar; şerit
--  sayıları aynı görünümden sayılır - "4 kişi izinde" deyip süzünce 3 kişi
--  göstermek olmasın.
--
--    bugun_kod : 0 pasif · 1 çalışıyor · 2 izinde · 3 raporlu · 4 deneme süresinde
--    bugun     : ekrandaki metin ("İzinde · dönüş 08.10", "Raporlu · 10.10'a kadar")
--    kidem     : "21 yıl" / "6 ay" (işe giriş yoksa boş)
--    kalan_izin / hak_toplam : bu yılın yıllık izni (v_personel_izin_bakiye ile aynı formül)
--    onayda_talep : onay bekleyen izin + avans + masraf + belge talebi
--    eksik     : eksik özlük bilgisi ("TC, SGK sicil, işe giriş")
--    dogum_bu_ay / dogum_bugun : 0/1
--  Yalnız dev docker.
-- ============================================================================

create or replace view public.v_personel_durum as
select t.id as taraf_id,
       case when t.durum <> 1 then 0
            when iz.tur = 3 then 3
            when iz.id is not null then 2
            when p.deneme_suresi > 0 and p.ise_giris_tarihi is not null
                 and (p.ise_giris_tarihi + make_interval(months => p.deneme_suresi))::date > current_date then 4
            else 1 end::smallint as bugun_kod,
       case when t.durum <> 1 then
                 case when p.isten_cikis_tarihi is not null
                      then 'Ayrıldı · ' || to_char(p.isten_cikis_tarihi, 'DD.MM.YYYY') else 'Pasif' end
            when iz.tur = 3 then 'Raporlu · ' || to_char(iz.bitis_tarihi, 'DD.MM') || '''a kadar'
            when iz.id is not null then
                 case when iz.saat_bas is not null then 'İzinde · ' || iz.saat_bas || '–' || iz.saat_bit
                      when iz.gun < 1 then 'İzinde · yarım gün'
                      else 'İzinde · dönüş ' || to_char(iz.bitis_tarihi + 1, 'DD.MM') end
            when p.deneme_suresi > 0 and p.ise_giris_tarihi is not null
                 and (p.ise_giris_tarihi + make_interval(months => p.deneme_suresi))::date > current_date then
                 'Deneme · ' || ((p.ise_giris_tarihi + make_interval(months => p.deneme_suresi))::date - current_date)
                 || ' gün kaldı'
            else 'Çalışıyor' end::varchar(60) as bugun,
       case when p.ise_giris_tarihi is null then ''
            when date_part('year', age(current_date, p.ise_giris_tarihi)) >= 1
                 then date_part('year', age(current_date, p.ise_giris_tarihi))::int || ' yıl'
            else date_part('month', age(current_date, p.ise_giris_tarihi))::int || ' ay' end::varchar(20) as kidem,
       case when b.hak_gun is null then null
            else coalesce(b.hak_gun, 0) + b.devir_gun + b.ek_gun - b.kullanilan_gun - b.planlanan_gun - b.onayda_gun end as kalan_izin,
       case when b.hak_gun is null then null else coalesce(b.hak_gun, 0) + b.devir_gun + b.ek_gun end as hak_toplam,
       ((select count(*) from public.personel_izin x where x.taraf_id = t.id and x.durum = 1)
      + (select count(*) from public.personel_avans x where x.taraf_id = t.id and x.durum = 1)
      + (select count(*) from public.personel_masraf x where x.taraf_id = t.id and x.durum = 1)
      + (select count(*) from public.personel_belge_talep x where x.taraf_id = t.id and x.durum = 1))::int as onayda_talep,
       concat_ws(', ',
           case when coalesce(t.vkno, '') = '' then 'TC' end,
           case when coalesce(p.sgk_sicil_no, '') = '' then 'SGK sicil' end,
           case when p.ise_giris_tarihi is null then 'işe giriş' end,
           case when p.dogum_tarihi is null then 'doğum tarihi' end,
           case when t.departman is null then 'bölüm' end)::varchar(120) as eksik,
       case when p.dogum_tarihi is not null and extract(month from p.dogum_tarihi) = extract(month from current_date)
            then 1 else 0 end::smallint as dogum_bu_ay,
       case when p.dogum_tarihi is not null and to_char(p.dogum_tarihi, 'MMDD') = to_char(current_date, 'MMDD')
            then 1 else 0 end::smallint as dogum_bugun
  from public.taraf t
  left join public.taraf_personel p on p.id = t.id
  left join public.v_personel_izin_bakiye b on b.taraf_id = t.id
  left join lateral (
       select i.id, i.tur, i.bitis_tarihi, i.saat_bas, i.saat_bit, i.gun
         from public.personel_izin i
        where i.taraf_id = t.id and i.durum = 2
          and current_date between i.baslangic_tarihi and i.bitis_tarihi
        order by (i.tur = 3) desc, i.bitis_tarihi desc
        limit 1) iz on true
 where t.personel = 1;

comment on view public.v_personel_durum is
    '963: personel listesi Bugün / kıdem / kalan izin / onaydaki talep / eksik özlük - liste ve gösterge şeridi aynı tanımı okur';

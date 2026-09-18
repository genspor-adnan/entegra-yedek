-- ============================================================================
--  Gentegre AI — TELERADYOLOJİ İSTEK KARTI için lookup + kolay okunur alanlar
--  798_telerad_kart.sql
--
--  Kullanıcı: *"teleradyoloji istek kartını da yap"*.
--
--  Çalışma listesinde çift tık bir şey açmıyordu (797 faz 1'de kart yoktu).
--  Kart, kombo kutularını doldurmak için iki şeye ihtiyaç duyuyor: kurum
--  listesi ve radyolog listesi. Radyolog `v_rad_hekim_lookup`ta zaten var;
--  teleradyoloji kurumu için lookup YOK - cari listesinden seçtirmek yanlış
--  olurdu: her cari teleradyoloji kurumu değildir ve isteği olmayan bir
--  cariyi seçmek sessizce kırık kayıt üretir.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_telerad_kurum_lookup as
select k.id,
       -- AD + YÖN: aynı cari hem gönderen hem alıcı olabilir; combo'da hangi
       --   ilişkiden bahsettiğimiz görünsün.
       coalesce(t.unvan, '') ||
       case k.yon when 2 then ' (giden)' when 3 then ' (iki yön)' else '' end as ad,
       k.aktif
  from public.telerad_kurum k
  join public.taraf t on t.id = k.taraf_id;

comment on view public.v_telerad_kurum_lookup is
  '798: teleradyoloji kurumu secim listesi - cari listesi DEGIL, yalniz '
  'teleradyoloji iliskisi tanimlanmis kurumlar.';

do $$
declare v_kurum int;
begin
    select count(*) into v_kurum from public.v_telerad_kurum_lookup where aktif = 1;
    raise notice '798 tamam: telerad kurum lookup hazir (% aktif kurum).', v_kurum;
end $$;

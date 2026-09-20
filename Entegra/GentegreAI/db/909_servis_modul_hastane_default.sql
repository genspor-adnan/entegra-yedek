-- =====================================================================
--  909_servis_modul_hastane_default.sql
--  Teknik Servis (servis) modülü: YALNIZ HASTANEDE varsayılan açık;
--  diğer kurum tiplerinde OPSİYON (kullanıcı: "teknik servis sadece
--  hastanede default açık olsun diğerlerinde opsiyon").
--
--  kurum_tipi_modul.varsayilan:
--    1 = varsayılan AÇIK
--    2 = OPSİYONEL (modül listesinde görünür ama kapalı; Modüller
--        sekmesinden açılabilir)
--    0 = kapalı
--  fn_kurum_modul_acik yalnız 1'i açık sayar; 2 ve 0 kapalıdır.
-- =====================================================================

-- Eksik tipler için servis satırı aç (opsiyonel olarak).
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, 'servis', case when t.kod = 'hastane' then 1 else 2 end
  from public.kurum_tipi t
 where not exists (select 1 from public.kurum_tipi_modul m
                    where m.kurum_tipi = t.kod and m.modul = 'servis');

-- Mevcut satırları hizala: hastane=1, diğerleri=2.
update public.kurum_tipi_modul
   set varsayilan = case when kurum_tipi = 'hastane' then 1 else 2 end
 where modul = 'servis';

do $$
begin
    raise notice '909 tamam: servis hastane=% , opsiyonel(2)=% ',
        (select varsayilan from public.kurum_tipi_modul
          where modul='servis' and kurum_tipi='hastane'),
        (select count(*) from public.kurum_tipi_modul
          where modul='servis' and varsayilan=2);
end $$;
